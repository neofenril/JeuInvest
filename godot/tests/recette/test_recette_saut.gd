extends Node
## Recette du lot 02-I (testeur) : saut « jusqu'au prochain courrier » et fenêtres ouvertes par le joueur (D4).
## Pour chaque fenêtre (Banque, historique, menu, Mon foyer, comparaison, détail des frais, Les nouvelles) :
## saut lancé (depuis ×1 ou depuis la pause), fenêtre ouverte → saut arrêté, temps bloqué, bouton inactif,
## touche N sans effet ; fenêtre fermée → vitesse d'avant l'appui, saut non relancé, bouton au repos.
## Puis : cycle de vitesse pendant un saut (arrêt seul, même vitesse), pause pendant un saut, sauvegarde
## pendant un saut puis reprise (sans saut). Graine fixe. Aucun script du jeu modifié.

const GRAINE := 11

var ok := 0
var ko := 0
var scene: Node
var hud: Hud
var modales: Modales


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		ok += 1
		print("OK  ", nom)
	else:
		ko += 1
		print("KO  ", nom, "  [", detail, "]")


func _ready() -> void:
	Partie.chemin_sauvegarde = "user://recette_saut_%d.sav" % OS.get_process_id()
	await _test()
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	print("=== recette saut : %d OK, %d KO ===" % [ok, ko])
	get_tree().quit(1 if ko > 0 else 0)


func _images(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _attendre(cond: Callable, max_s: float) -> bool:
	var t0 := Time.get_ticks_msec()
	while not cond.call() and Time.get_ticks_msec() - t0 < int(max_s * 1000.0):
		await get_tree().process_frame
	return cond.call()


func _touche_n() -> void:
	var ev := InputEventKey.new()
	ev.keycode = KEY_N
	ev.pressed = true
	Input.parse_input_event(ev)
	await _images(2)
	var ev2 := InputEventKey.new()
	ev2.keycode = KEY_N
	ev2.pressed = false
	Input.parse_input_event(ev2)
	await _images(1)


func _demarrer() -> void:
	scene = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await _images(5)
	hud = scene.get("hud")
	modales = scene.get("modales")
	scene.set("_ignorer_modales", true)
	Partie.nouvelle_partie(Donnees.config_demo(GRAINE))
	scene.set("_ignorer_modales", false)
	scene.call("_apres_mise_en_place")
	Partie.etat.resolution_auto()
	scene.call("demarrer_direct", 0)
	await _attendre(func() -> bool: return hud.etat_courrier() == "repos", 5.0)


## Ouvre la fenêtre « nom » pendant un saut lancé depuis la vitesse v, puis la ferme.
func _fenetre(nom: String, ouvrir: Callable, v: int) -> void:
	await _attendre(func() -> bool: return not modales.ouverte() and not scene.sequences.occupe and Partie.saut_possible(), 5.0)
	Partie.changer_vitesse(v)
	scene.call("demander_saut")
	var lance := Partie.saut_actif
	ouvrir.call()
	var ouverte := await _attendre(func() -> bool: return modales.ouverte(), 3.0)
	await _images(3)
	var arrete := not Partie.saut_actif
	var bloque := Partie.bloquee
	var etat := hud.etat_courrier()
	await _touche_n()
	var n_sans_effet := not Partie.saut_actif
	verifier("%s (depuis %s) : saut arrêté à l'ouverture, temps bloqué, bouton inactif, N sans effet" % [nom, "pause" if v == 0 else "×%d" % v],
		lance and ouverte and arrete and bloque and etat == "inactif" and n_sans_effet,
		"lancé %s, ouverte %s (%s), arrêté %s, bloqué %s, état %s, N %s" % [lance, ouverte, modales.genre_courant, arrete, bloque, etat, n_sans_effet])
	await get_tree().create_timer(0.6).timeout
	if modales.genre_courant == "banque":
		modales.banque.fermer_demande.emit()
	else:
		modales.fermer("fermer")
	await _attendre(func() -> bool: return not modales.ouverte() and not Partie.bloquee, 4.0)
	await _images(3)
	verifier("%s : à la fermeture, vitesse d'avant l'appui (%d), saut non relancé, bouton au repos" % [nom, v],
		Partie.vitesse == v and not Partie.saut_actif and not Partie.bloquee and hud.etat_courrier() == "repos",
		"vitesse %d, saut %s, bloqué %s, état %s" % [Partie.vitesse, Partie.saut_actif, Partie.bloquee, hud.etat_courrier()])


func _test() -> void:
	await _demarrer()
	verifier("départ : bouton COURRIER au repos (graine %d, %s)" % [GRAINE, Dates.texte(Partie.etat.ab_courant())], hud.etat_courrier() == "repos", hud.etat_courrier())
	await _fenetre("Banque", func() -> void: scene.call("ouvrir_banque", "", -2.0), 1)
	await _fenetre("historique", func() -> void: scene.call("ouvrir_historique", ""), 0)
	await _fenetre("menu", func() -> void: scene.call("ouvrir_menu"), 2)
	await _fenetre("Mon foyer", func() -> void: scene.call("toucher_batiment", "maison"), 1)
	await _fenetre("comparaison", func() -> void: scene.call("expliquer_comparaison"), 0)
	await _fenetre("détail des frais", func() -> void: hud.frais_demandes.emit(), 1)
	await _fenetre("Les nouvelles (média)", func() -> void: scene.call("toucher_batiment", "media"), 0)

	# Cycle de vitesse (téléphone) pendant un saut : arrêt seul, la vitesse ne change pas au même toucher
	Partie.changer_vitesse(2)
	scene.call("demander_saut")
	var lance := Partie.saut_actif
	hud.vitesse_demandee.emit(-2)
	await _images(2)
	verifier("cycle de vitesse pendant un saut : saut arrêté, vitesse inchangée (×2)", lance and not Partie.saut_actif and Partie.vitesse == 2,
		"lancé %s, saut %s, vitesse %d" % [lance, Partie.saut_actif, Partie.vitesse])

	# Pause pendant un saut lancé à ×1 : saut arrêté, pause
	Partie.changer_vitesse(1)
	scene.call("demander_saut")
	lance = Partie.saut_actif
	hud.vitesse_demandee.emit(0)
	await _images(2)
	verifier("pause pendant un saut : saut arrêté, pause", lance and not Partie.saut_actif and Partie.vitesse == 0, "lancé %s, saut %s, vitesse %d" % [lance, Partie.saut_actif, Partie.vitesse])

	# Sauvegarde pendant un saut puis reprise : pas de saut à la reprise, même mois
	Partie.changer_vitesse(0)
	scene.call("demander_saut")
	await get_tree().create_timer(1.6).timeout
	var en_saut := Partie.saut_actif
	var m := Partie.etat.m
	Partie.sauvegarde_auto = true
	Partie.sauvegarder()
	Partie.sauvegarde_auto = false
	Partie.arreter_saut()
	var sauvee := Sauvegarde.lire(Partie.chemin_sauvegarde)
	scene.queue_free()
	await _images(3)
	Juice.camera = null
	Juice.hud = null
	Juice.calque_effets = null
	scene = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await _images(5)
	hud = scene.get("hud")
	modales = scene.get("modales")
	var repris := not sauvee.is_empty() and bool(scene.call("reprendre", sauvee))
	await _images(5)
	verifier("sauvegarde pendant un saut puis reprise : même mois, sans saut",
		en_saut and repris and Partie.etat.m == m and not Partie.saut_actif,
		"en saut %s, repris %s, mois %d / %d, saut %s" % [en_saut, repris, Partie.etat.m, m, Partie.saut_actif])
	# Fin propre : rien d'ouvert, scène libérée
	Partie.changer_vitesse(0)
	if modales.ouverte():
		modales.fermer("plus_tard")
	await _attendre(func() -> bool: return not scene.sequences.occupe and not modales.ouverte(), 5.0)
	await get_tree().create_timer(0.5).timeout
	scene.queue_free()
	await _images(3)
	Juice.camera = null
	Juice.hud = null
	Juice.calque_effets = null
