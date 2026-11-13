extends Node
## Recette 03-V2 (testeur), CA-V2 : routage des contenus de modale par Sequences.jouer_modale.
## - carte (vraie partie cartes allumées) : sortie par la porte, repli sur le courrier (pas de Modales.carte), choix, la partie continue ;
## - contenu « projet » et contenu « gazette » (modèle : un vrai contenu de courrier dont on change le kind) : passent aussi par
##   le courrier (genre_courant), la séquence se termine, la partie avance ensuite.
## Durée de la sortie (carte) mesurée. Graine fixe, sauvegarde dans un fichier jetable.

const GRAINE := 7

var ok := 0
var ko := 0
var scene: Node
var modales: Modales


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		ko += 1
		print("KO  ", nom, "  [", detail, "]")


func _ready() -> void:
	Partie.chemin_sauvegarde = "user://recette_routage_%d.sav" % OS.get_process_id()
	await _test()
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	print("=== recette routage : %d OK, %d KO ===" % [ok, ko])
	get_tree().quit(1 if ko > 0 else 0)


func _images(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _attendre(cond: Callable, max_s: float) -> bool:
	var t0 := Time.get_ticks_msec()
	while not cond.call() and Time.get_ticks_msec() - t0 < int(max_s * 1000.0):
		await get_tree().process_frame
	return cond.call()


func _mois_passe(ab0: int) -> bool:
	return Partie.etat.ab_courant() > ab0


func _test() -> void:
	scene = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await _images(5)
	modales = scene.get("modales")
	var cfg := Donnees.config_demo(GRAINE)
	cfg["cartes"] = true
	scene.set("_ignorer_modales", true)
	Partie.nouvelle_partie(cfg)
	scene.set("_ignorer_modales", false)
	scene.call("_apres_mise_en_place")
	Partie.etat.resolution_auto()
	scene.call("demarrer_direct", 0)
	await _images(10)
	var e := Partie.etat
	# 1. Avance logique jusqu'à la première carte (comme la capture carte_sortie)
	var garde := 0
	var carte := false
	while e.fin == "" and garde < 100:
		if not e.modale.is_empty():
			if str(e.contenu_modale().get("kind", "")) == "carte":
				carte = true
				break
			StrategieTest.jouer_mois(e, true)
			if not e.modale.is_empty():
				e.resolution_auto()
		else:
			StrategieTest.jouer_mois(e, true)
		e.avancer()
		garde += 1
	verifier("une carte du foyer arrive (cartes allumées)", carte)
	if not carte:
		return
	var ab0 := e.ab_courant()
	var seq = scene.get("sequences")
	var t0 := Time.get_ticks_msec()
	Partie.rouvrir_modale()
	var ouverte := await _attendre(func() -> bool: return modales.ouverte(), 5.0)
	var duree := (Time.get_ticks_msec() - t0) / 1000.0
	verifier("carte : la séquence ouvre le courrier (repli) en ≤ 1 s", ouverte and modales.genre_courant == "courrier" and duree <= 1.0, "genre=%s %.2f s" % [modales.genre_courant, duree])
	var pris := ""
	for ch: Dictionary in e.contenu_modale().get("choix", []):
		if not bool(ch.get("desactive", false)):
			pris = str(ch["id"])
			break
	modales.fermer(pris)
	await _attendre(func() -> bool: return not seq.occupe and e.modale.is_empty(), 10.0)
	verifier("carte : choix pris, modale du moteur vide, séquence finie", e.modale.is_empty() and not seq.occupe and e.cartes_jouees().size() >= 1)
	Partie.changer_vitesse(1)
	var avance := await _attendre(func() -> bool: return _mois_passe(ab0) or not e.modale.is_empty(), 15.0)
	verifier("carte : la partie continue après le choix", avance)
	Partie.changer_vitesse(0)
	if not e.modale.is_empty():
		e.resolution_auto()
	await _images(5)
	# 2. kind projet puis gazette : modèle = un contenu de courrier réel
	var modele := {}
	var g := 0
	while modele.is_empty() and e.fin == "" and g < 60:
		if not e.modale.is_empty():
			var c := e.contenu_modale()
			if str(c.get("kind", "")) == "vie":
				modele = c.duplicate(true)
				break
			StrategieTest.jouer_mois(e, true)
			if not e.modale.is_empty():
				e.resolution_auto()
		else:
			StrategieTest.jouer_mois(e, true)
		e.avancer()
		g += 1
	verifier("modèle de courrier (vie) trouvé", not modele.is_empty())
	if modele.is_empty():
		return
	# on referme proprement le vrai courrier avant les contenus fabriqués
	e.resolution_auto()
	await _images(5)
	for kind in ["projet", "gazette"]:
		var c2: Dictionary = modele.duplicate(true)
		c2["kind"] = kind
		c2["id"] = "T_" + kind
		var t1 := Time.get_ticks_msec()
		seq.jouer_modale(c2)
		var o := await _attendre(func() -> bool: return modales.ouverte(), 5.0)
		var d := (Time.get_ticks_msec() - t1) / 1000.0
		verifier("%s : repli sur le courrier (appel=courrier)" % kind, o and modales.genre_courant == "courrier", "genre=%s %.2f s" % [modales.genre_courant, d])
		modales.fermer("fermer")
		var fini := await _attendre(func() -> bool: return not seq.occupe, 10.0)
		verifier("%s : la séquence se termine, ville de nouveau interactive" % kind, fini and not modales.ouverte())
		var a1 := e.ab_courant()
		Partie.changer_vitesse(1)
		var av := await _attendre(func() -> bool: return _mois_passe(a1) or not e.modale.is_empty(), 15.0)
		verifier("%s : la partie avance ensuite" % kind, av)
		Partie.changer_vitesse(0)
		if not e.modale.is_empty():
			e.resolution_auto()
		await _images(5)
