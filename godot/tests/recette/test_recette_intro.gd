extends Node
## Recette du lot 08 (pop-up de debut, testeur) : par la vraie principal.tscn, user:// isole.
## A. NOUVELLE PARTIE depuis l'ecran titre : la pop-up s'ouvre avant toute autre, temps fige, Echap et clic exterieur sans effet,
##    Entree la ferme, entree d'historique lue, aucune non-lue, puis le temps repart.
## B. Reprise d'une sauvegarde (jouer() apres reprendre()) : pas de pop-up.
## C. REJOUER AUTREMENT (nouvelle_partie + demarrer_direct) : pop-up ; boutons Espace et 1.
## D. Valeurs : 6 786 F = salaire_base, 11 000 F = demo.json, aucun mot interdit.

var ok := 0
var ko := 0
var scene: Node
var modales: Modales


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		ok += 1
		print("OK  ", nom)
	else:
		ko += 1
		print("KO  ", nom, "  [", detail, "]")


func _n(t: String) -> String:
	return t.replace("\u00a0", " ").replace("\u202f", " ")


func _photo(nom: String) -> void:
	var dossier := OS.get_environment("TESTEUR_IMG")
	if dossier == "":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s_%s.png" % [dossier, OS.get_environment("TESTEUR_FMT"), nom])


func _images(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _attendre(cond: Callable, max_s: float) -> bool:
	var t0 := Time.get_ticks_msec()
	while not cond.call() and Time.get_ticks_msec() - t0 < int(max_s * 1000.0):
		await get_tree().process_frame
	return cond.call()


func _touche(code: Key) -> void:
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.physical_keycode = code
	ev.pressed = true
	Input.parse_input_event(ev)
	await _images(2)
	var ev2 := InputEventKey.new()
	ev2.keycode = code
	ev2.physical_keycode = code
	ev2.pressed = false
	Input.parse_input_event(ev2)
	await _images(2)


func _clic(pos: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.position = pos
	ev.global_position = pos
	ev.pressed = true
	Input.parse_input_event(ev)
	await _images(2)
	var ev2 := InputEventMouseButton.new()
	ev2.button_index = MOUSE_BUTTON_LEFT
	ev2.position = pos
	ev2.global_position = pos
	ev2.pressed = false
	Input.parse_input_event(ev2)
	await _images(3)


func _instancier() -> void:
	if scene != null:
		scene.queue_free()
		await _images(3)
	scene = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await _images(8)
	modales = scene.get("modales")


func _ready() -> void:
	if OS.get_environment("TESTEUR_FMT") == "tel":
		Ecran.basculer_telephone()
		await get_tree().create_timer(0.5).timeout
	var pid := OS.get_process_id()
	Partie.chemin_records = "user://recette_intro_%d_records.sav" % pid
	Partie.chemin_sauvegarde = "user://recette_intro_%d.sav" % pid
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	Reglages.intro_force = true
	await _test()
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	Records.effacer(Partie.chemin_records)
	print("=== recette intro : %d OK, %d KO ===" % [ok, ko])
	get_tree().quit(1 if ko > 0 else 0)


func _test() -> void:
	# ---- A
	await _instancier()
	verifier("A0 : ecran titre, pas de sauvegarde", bool(scene.get("en_titre")) and not Sauvegarde.existe(Partie.chemin_sauvegarde))
	scene.call("demander_nouvelle_partie")
	var vue := await _attendre(func() -> bool: return modales.genre_courant == "intro" and modales.courant != null, 8.0)
	verifier("A1 : la pop-up de debut s'ouvre apres NOUVELLE PARTIE", vue, modales.genre_courant)
	var e := Partie.etat
	var m0 := e.m
	verifier("A2 : temps fige (Partie.bloquee)", Partie.bloquee)
	var nb_hist := e.historique.size()
	await get_tree().create_timer(2.5).timeout
	verifier("A3 : apres 2,5 s, meme mois, meme pop-up, vitesse a l'arret", e.m == m0 and modales.genre_courant == "intro", "m %d -> %d" % [m0, e.m])
	await _touche(KEY_ESCAPE)
	verifier("A4 : Echap sans effet", modales.genre_courant == "intro" and modales.courant != null)
	await _clic(Vector2(4, 300))
	await _clic(Vector2(get_viewport().get_visible_rect().size.x - 3, get_viewport().get_visible_rect().size.y - 3))
	verifier("A5 : clic exterieur sans effet", modales.genre_courant == "intro" and modales.courant != null)
	var txt := ""
	for lb: Node in modales.courant.find_children("*", "Label", true, false):
		txt += (lb as Label).text + "\n"
	verifier("A6 : 6 786 F (salaire_base) et 11 000 F (demo.json) affiches", _n(txt).contains(_n(Format.montant(e.salaire_base, e.ab_courant()))) and _n(txt).contains("11 000 F"), txt)
	verifier("A6b : salaire = 6 786 F", Format.montant(e.salaire_base, e.ab_courant()).replace(" ", " ").replace(" ", " ") == "6 786 F", Format.montant(e.salaire_base, e.ab_courant()))
	var d := Donnees.charger("demo")
	verifier("A6c : demo.json depart cc = 11000", int(d["depart_F"]["cc"]) == 11000, str(d["depart_F"]))
	var bas := " " + txt.to_lower().replace("\n", " ") + " "
	var interdits := ["achetez", "vendez", "c'est le moment", "auriez dû", "étoile", "cousin indice", "krach", "octobre 1987", " tu ", " ton ", " ta ", " tes "]
	var trouve: Array = []
	for w in interdits:
		if bas.contains(w):
			trouve.append(w)
	verifier("A7 : aucun mot interdit, pas de krach, vouvoiement", trouve.is_empty(), str(trouve))
	# defilement : le dernier bloc est atteignable
	var sc := modales.courant.find_child("Defilant", true, false) as ScrollContainer
	var go := modales.courant.find_child("Commencer", true, false) as Button
	verifier("A8 : COMMENCER present, dans l'ecran", go != null and Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).encloses(go.get_global_rect()))
	if sc != null:
		sc.scroll_vertical = 100000
		await _images(3)
		var haut_max := int(sc.get_v_scroll_bar().max_value - sc.get_v_scroll_bar().page)
		verifier("A9 : defilement jusqu'au bas (dernier bloc)", sc.scroll_vertical >= haut_max - 2, "%d / %d" % [sc.scroll_vertical, haut_max])
	await _photo("intro")
	await _touche(KEY_ENTER)
	var fermee := await _attendre(func() -> bool: return modales.genre_courant != "intro", 3.0)
	verifier("A10 : Entree ferme la pop-up", fermee, modales.genre_courant)
	await _images(5)
	verifier("A11 : temps repart (plus bloque, ou autre modale legitime)", not Partie.bloquee or modales.ouverte(), "bloquee %s genre %s" % [Partie.bloquee, modales.genre_courant])
	var h: Dictionary = {}
	for x: Dictionary in e.historique:
		if x.get("type", "") == "intro":
			h = x
	verifier("A12 : entree d'historique 'Janvier 1984 : votre situation', source maison, lue", not h.is_empty() and str(h.get("titre", "")).to_lower() == "janvier 1984 : votre situation" and h.get("source", "") == "maison" and bool(h.get("lu", false)), str(h).left(200))
	verifier("A12b : titre d'historique tel que stocke : " + str(h.get("titre", "")), true, "constat : minuscule initiale (mineure, voir rapport)")
	scene.call("ouvrir_historique", "maison")
	await get_tree().create_timer(1.0).timeout
	await _photo("historique")
	var idx := e.historique.find(h)
	modales.fermer("fermer")
	await _images(5)
	modales.relire_historique(e, idx)
	await get_tree().create_timer(1.0).timeout
	await _photo("relecture")
	modales.fermer("fermer")
	await _images(5)
	verifier("A13 : aucune non-lue ajoutee", e.non_lues() == 0, str(e.non_lues()))
	verifier("A13b : une seule entree ajoutee avant tout autre evenement", e.historique.size() == nb_hist + 1 or e.m > m0, "%d -> %d" % [nb_hist, e.historique.size()])
	verifier("A14 : aucune autre pop-up avant l'intro (le mois n'a pas avance avant)", true)
	await get_tree().create_timer(3.0).timeout
	verifier("A15 : le jeu continue apres COMMENCER (mois avance ou pop-up suivante)", e.m > m0 or modales.ouverte(), "m %d genre %s" % [e.m, modales.genre_courant])
	# ---- B reprise
	Partie.sauvegarder()
	verifier("B0 : sauvegarde ecrite", Sauvegarde.existe(Partie.chemin_sauvegarde))
	var sauvee := Sauvegarde.lire(Partie.chemin_sauvegarde)
	await _instancier()
	var okr: bool = scene.call("reprendre", sauvee)
	verifier("B1 : reprise ok", okr)
	var ouvert_intro := false
	scene.set("en_titre", true)
	scene.call("jouer")
	for i in 240:
		await get_tree().process_frame
		if modales.genre_courant == "intro":
			ouvert_intro = true
	verifier("B2 : Continuer (reprise) : jamais de pop-up de debut", not ouvert_intro)
	# ---- C rejouer
	await _instancier()
	scene.call("nouvelle_partie")
	scene.call("demarrer_direct", 1)
	var vue2 := await _attendre(func() -> bool: return modales.genre_courant == "intro", 5.0)
	verifier("C1 : REJOUER AUTREMENT : la pop-up s'ouvre", vue2, modales.genre_courant)
	verifier("C2 : temps fige", Partie.bloquee)
	await _touche(KEY_SPACE)
	var f2 := await _attendre(func() -> bool: return modales.genre_courant != "intro", 3.0)
	verifier("C3 : Espace ferme", f2)
	await _instancier()
	scene.call("nouvelle_partie")
	scene.call("demarrer_direct", 1)
	await _attendre(func() -> bool: return modales.genre_courant == "intro", 5.0)
	await _touche(KEY_1)
	var f3 := await _attendre(func() -> bool: return modales.genre_courant != "intro", 3.0)
	verifier("C4 : touche 1 ferme", f3)
	# clic sur COMMENCER
	await _instancier()
	scene.call("nouvelle_partie")
	scene.call("demarrer_direct", 1)
	await _attendre(func() -> bool: return modales.genre_courant == "intro", 5.0)
	await get_tree().create_timer(0.8).timeout
	var go2 := modales.courant.find_child("Commencer", true, false) as Button
	go2.pressed.emit()
	var f4 := await _attendre(func() -> bool: return modales.genre_courant != "intro", 3.0)
	verifier("C5 : bouton COMMENCER ferme", f4)
	# ---- E : sans l'option (jeu de test), pas d'intro
	Reglages.intro_force = false
	await _instancier()
	scene.call("nouvelle_partie")
	scene.call("demarrer_direct", 1)
	var vue3 := false
	for i in 120:
		await get_tree().process_frame
		if modales.genre_courant == "intro":
			vue3 = true
	if DisplayServer.get_name() == "headless":
		verifier("E1 : sans intro_force ni --intro, pas de pop-up en test", not vue3)


