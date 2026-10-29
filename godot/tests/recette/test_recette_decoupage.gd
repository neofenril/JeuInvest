extends Node
## Recette du lot 01 (testeur) : chemins de principal.gd découpé que les captures n'empruntent pas
## (appels dynamiques via `jeu: Node`) : raccourcis présents / absents, journal « Renforcer » → banque,
## menu → historique, écran de fin → « Rejouer autrement ». Lancer avec ou sans « -- --joueur ».

var ok := 0
var ko := 0


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		ok += 1
		print("OK  ", nom)
	else:
		ko += 1
		print("KO  ", nom, "  [", detail, "]")


func _ready() -> void:
	Partie.chemin_sauvegarde = "user://recette_decoupage_%d.sav" % OS.get_process_id()
	await _test()
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	print("=== recette découpage (raccourcis_test=%s) : %d OK, %d KO ===" % [Reglages.raccourcis_test(), ok, ko])
	get_tree().quit(1 if ko > 0 else 0)


func _attendre(cond: Callable, max_s: float) -> bool:
	var t0 := Time.get_ticks_msec()
	while not cond.call() and Time.get_ticks_msec() - t0 < int(max_s * 1000.0):
		await get_tree().process_frame
	return cond.call()


func _pause(s: float) -> void:
	await get_tree().create_timer(s).timeout


func _test() -> void:
	var scene: Node = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	for i in 10:
		await get_tree().process_frame
	var dev := Reglages.raccourcis_test()
	var n_racc := 0
	for c in scene.get_children():
		if c is RaccourcisTest:
			n_racc += 1
	verifier("RaccourcisTest créé si et seulement si raccourcis_test", n_racc == (1 if dev else 0), "%d nœud(s)" % n_racc)
	var hud: Hud = scene.hud
	verifier("triple toucher relié si et seulement si raccourcis_test", hud.raccourci_demo.get_connections().size() == (1 if dev else 0))
	var titre: EcranTitre = scene.titre
	verifier("ligne d'aide du titre visible si et seulement si raccourcis_test", titre.l_aide.visible == dev)
	verifier("une seule Sequences, enfant de la scène", scene.sequences != null and scene.sequences.get_parent() == scene)
	var modales: Modales = scene.modales

	# Jouer : la carte du Livret A (modale en attente) arrive après la plongée
	scene.jouer()
	await _attendre(func() -> bool: return modales.genre_courant == "appel", 8.0)
	verifier("jouer : HUD visible, carte du banquier rouverte", not scene.en_titre and hud.visible and modales.genre_courant == "appel", modales.genre_courant)
	await _pause(0.8)
	modales.fermer("plus_tard")
	await _attendre(func() -> bool: return not scene.sequences.occupe, 5.0)
	Partie.changer_vitesse(0)

	# Journal du krach, choix « Renforcer » : la séquence rappelle jeu.ouvrir_banque
	var e := Partie.etat
	var garde := 0
	while e.fin == "" and garde < 100 and str(e.modale.get("id", "")) != "p1e6":
		if not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
		garde += 1
	Partie.rouvrir_modale()
	await _attendre(func() -> bool: return modales.genre_courant == "journal", 10.0)
	await _pause(2.5)
	var ids: Array = e.contenu_modale().get("choix", []).map(func(x: Dictionary) -> String: return str(x["id"]))
	var renf := ""
	for id in ids:
		if id in ["renforcer", "soldes", "suivre", "souscrire"]:
			renf = id
	modales.call("_on_choix_journal", renf)
	await _attendre(func() -> bool: return modales.genre_courant == "banque", 6.0)
	verifier("krach « %s » : la fenêtre Banque s'ouvre (Sequences → jeu.ouvrir_banque)" % renf, modales.genre_courant == "banque", "genre %s, choix %s" % [modales.genre_courant, str(ids)])
	if modales.genre_courant == "banque":
		modales.banque.fermer_demande.emit()
	await _attendre(func() -> bool: return not scene.sequences.occupe and not modales.ouverte(), 6.0)
	verifier("après la banque : plus de vedette, temps débloqué", not scene.sequences.occupe and not Partie.bloquee)

	# Menu → historique
	scene.ouvrir_menu()
	await _attendre(func() -> bool: return modales.genre_courant == "menu", 3.0)
	modales.fermer("historique")
	await _attendre(func() -> bool: return modales.genre_courant == "historique", 3.0)
	verifier("menu → historique", modales.genre_courant == "historique", modales.genre_courant)
	modales.fermer("fermer")
	await _attendre(func() -> bool: return not modales.ouverte(), 3.0)

	# Fin → « Rejouer autrement » : Sequences rappelle jeu.nouvelle_partie et jeu.demarrer_direct
	var m_avant := Partie.etat.m
	Partie.abandonner()
	await _attendre(func() -> bool: return modales.genre_courant == "fin", 6.0)
	verifier("abandon : écran de fin", modales.genre_courant == "fin", modales.genre_courant)
	await _pause(0.5)
	modales.fermer("rejouer")
	await _attendre(func() -> bool: return Partie.etat.fin == "" and Partie.etat.m < m_avant, 6.0)
	verifier("rejouer : nouvelle partie démarrée dans la rue", Partie.etat.fin == "" and Partie.etat.m < m_avant and not scene.en_titre and hud.visible,
		"fin « %s », m %d → %d" % [Partie.etat.fin, m_avant, Partie.etat.m])
	await _attendre(func() -> bool: return modales.genre_courant == "appel", 8.0)
	verifier("rejouer : la carte du Livret A revient", modales.genre_courant == "appel", modales.genre_courant)
	Partie.changer_vitesse(0)
	scene.queue_free()
	await get_tree().process_frame
	Juice.camera = null
	Juice.hud = null
	Juice.calque_effets = null
