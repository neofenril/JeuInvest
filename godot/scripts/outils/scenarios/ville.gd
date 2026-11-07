extends RefCounted
## Étapes de capture : la rue et ses animations (lot PX1). Avec --controle, les lignes « RUE … » de la recette
## (lot_px1 §5) ; --rue-sans-hud masque le HUD ; --rue-facteur=N force N ; --rue-passer=s simule un toucher
## s secondes après le début de la séquence ; --rue-borderless : fenêtre sans bordure en (0, 0) à la taille de
## --resolution (formats exacts). En téléphone simulé (--telephone), la fenêtre passe à 1600 × 720 (format de
## PX2 : 20:9, facteur 1,7).

const ETAPES := ["rue", "rue_nuit", "trafic", "crash_anim", "crash_fin", "crash_courrier", "naissance_anim", "naissance_pose", "naissance",
	"jumeaux_anim", "jumeaux_pose", "jumeaux", "news", "krach_anim", "fps",
	"rue_banque", "rue_gazette", "rue_libre", "defilement", "saison_hiver", "saison_automne", "saison_printemps", "pluie",
	"banquier_anim", "banquier_signal", "journal_anim", "courrier_anim", "jouer_repos", "sylvie_0", "sylvie_1", "sylvie_2", "planche_personnages", "voisins"]
const PX0 := preload("res://scripts/pixel/px0.gd")
const RUE := preload("res://scripts/ville/rue.gd")
const VILLE := preload("res://scripts/ville/ville.gd")

var sc: ScenariosCapture
var _controle := false


func jouer(etape: String) -> void:
	var jeu := sc.jeu
	var ville: Node2D = jeu.ville
	var rue: Node2D = ville.get("rue")
	_controle = "--controle" in OS.get_cmdline_user_args()
	await _regler_fenetre(ville)
	if etape == "jouer_repos":
		# « Jouer » depuis l'écran titre, la carte du Livret A déjà réglée : la maison au repos (CA-V10)
		Partie.etat.resolution_auto()
		await sc.attendre_que(func() -> bool: return rue.call("images_pretes"), 12.0)
		await sc.delai(1.5)
		if _controle:
			print("RUE titre premier_plan=%s" % ("visible" if rue.call("premier_plan_visible") else "masque"))
		sc.jeu.jouer()
		await sc.delai(2.4)
		if _controle:
			print("RUE jouer camera=%d repos_maison=%s" % [int(ville.call("position_camera")), "oui" if ville.call("est_visible", "maison") else "non"])
		return
	sc.partir_de_la_rue(etape)
	await sc.attendre_que(func() -> bool: return rue.call("images_pretes"), 12.0)
	if ScenariosCapture.option("rue-sans-hud") != "" or "--rue-sans-hud" in OS.get_cmdline_user_args() or etape in ["planche_personnages", "rue_libre"]:
		jeu.hud.visible = false
	var passer := float(ScenariosCapture.option("rue-passer")) if ScenariosCapture.option("rue-passer") != "" else -1.0
	if passer > 0.0:
		_passer_apres(passer)
	match etape:
		"rue", "rue_nuit", "rue_libre", "pluie":
			sc.aller_a(Dates.lire("1987-05"), true)
			ville.set("phase", 0.72 if etape == "rue_nuit" else 0.18)
			ville.set("pluie", etape == "pluie")
			Partie.changer_vitesse(1)
			await sc.delai(2.6)
			if _controle:
				await _controle_palette(ville, "rue_nuit" if etape == "rue_nuit" else "rue")
				_lignes_rue(ville)
				if etape == "rue_libre":
					await _controle_grille(ville)
		"rue_banque", "rue_gazette":
			sc.aller_a(Dates.lire("1987-05"), true)
			ville.set("phase", 0.18)
			Partie.changer_vitesse(1)
			await sc.delai(1.0)
			var id := "banque" if etape == "rue_banque" else "media"
			var t: Tween = ville.call("aller_vers", id, 0.5)
			if t != null and t.is_valid():
				await t.finished
			await sc.delai(1.0)
			if _controle:
				_lignes_rue(ville)
				_cadrage(ville, id)
				print("RUE visible %s=%s" % [id, "oui" if ville.call("est_visible", id) else "non"])
		"defilement":
			sc.aller_a(Dates.lire("1987-05"), true)
			ville.set("phase", 0.18)
			Partie.changer_vitesse(1)
			await sc.delai(1.0)
			await _defilement(ville)
		"saison_hiver", "saison_automne", "saison_printemps":
			var d: String = {"saison_hiver": "1985-01", "saison_automne": "1986-10", "saison_printemps": "1987-04"}[etape]
			sc.aller_a(Dates.lire(d), true)
			await sc.delai(0.2)
			await sc.attendre_que(func() -> bool: return rue.call("images_pretes"), 12.0)
			ville.set("phase", 0.18)
			Partie.changer_vitesse(1)
			await sc.delai(2.6)
			if _controle:
				print("RUE saison %s=%s" % [etape, rue.get("saison")])
		"sylvie_0", "sylvie_1", "sylvie_2":
			sc.aller_a(Dates.lire("1987-05"), true)
			ville.set("phase", 0.18)
			Partie.changer_vitesse(1)
			ville.call("regler_humeur_sylvie", int(etape.right(1)))
			await sc.delai(1.0)
			ville.get("maison").set("_cligne_t", 99.0)
			ville.get("maison").set("_cligne", 0.0)
			await sc.delai(0.5)
			if _controle:
				print("RUE sylvie humeur=%d" % int(ville.call("humeur_sylvie")))
		"planche_personnages":
			sc.aller_a(Dates.lire("1987-05"), true)
			ville.set("phase", 0.18)
			Partie.changer_vitesse(0)
			ville.set("gel", 0.0)
			await sc.delai(0.3)
			_planche(ville)
			await sc.delai(0.5)
		"voisins":
			sc.aller_a(Dates.lire("1987-05"), true)
			ville.set("phase", 0.18)
			Partie.changer_vitesse(1)
			await sc.delai(0.5)
			var tata: Node2D = ville.call("faire_passer", "tata", 1, 2.2)
			var jm: Node2D = ville.call("faire_passer", "jeanmi", -1, 2.6)
			await sc.delai(3.4)
			if _controle:
				var taille: Vector2 = ville.get_viewport_rect().size
				for n in [["tata", tata], ["jeanmi", jm]]:
					var p: Vector2 = ville.call("point_tete", n[1]) if is_instance_valid(n[1]) else Vector2(-1, -1)
					var dedans := Rect2(Vector2.ZERO, taille).has_point(p)
					print("RUE point_tete %s=%d,%d ecran=%s" % [n[0], int(p.x), int(p.y), "oui" if dedans else "non"])
		"trafic":
			sc.aller_a(Dates.lire("1987-05"), true)
			for v in [1, 2, 3, 0]:
				Partie.changer_vitesse(v)
				await sc.delai(1.2)
				var v_voitures: float = await sc.vitesse_mesuree(ville.get("_voitures"))
				var v_passants: float = await sc.vitesse_mesuree(ville.get("passants"))
				print("Trafic à la vitesse %d : voitures %.0f u/s, passants %.0f u/s (facteur %.2f)" % [v, v_voitures, v_passants, float(ville.get("facteur_trafic"))])
				if _controle:
					print("RUE trafic vitesse=%d voitures=%.1f passants=%.1f facteur=%.2f attendu=%.2f" % [v, v_voitures, v_passants,
						float(ville.get("facteur_trafic")), Partie.facteur_trafic(v) if v > 0 else 0.0])
		"crash_anim", "crash_fin", "crash_courrier":
			sc.aller_a_modale("voiture", true)
			var attente_crash: float = {"crash_anim": 0.95, "crash_fin": 1.5, "crash_courrier": 3.6}[etape]
			await sc.delai(attente_crash)
		"naissance_anim", "naissance_pose", "naissance":
			sc.aller_a_modale("naissance", true)
			var attente_n: float = {"naissance_anim": 0.9, "naissance_pose": 1.6, "naissance": 3.6}[etape]
			await sc.delai(attente_n)
			print("Naissance : %s, %d enfant(s), reste %s par mois" % [Partie.etat.contenu_modale().get("titre", "?"), Partie.etat.enfants, Format.montant(Partie.etat.epargne_du_mois(), Partie.etat.ab_courant())])
		"jumeaux_anim", "jumeaux_pose", "jumeaux":
			sc.aller_a(Dates.lire("1984-05"), true)
			ville.set("phase", 0.18)
			Partie.forcer_naissance(true)
			var attente_j: float = {"jumeaux_anim": 1.5, "jumeaux_pose": 1.75, "jumeaux": 3.6}[etape]
			await sc.delai(attente_j)
		"banquier_anim", "banquier_signal":
			sc.aller_a_modale("D03", true)
			await sc.attendre_que(func() -> bool: return jeu.sequences.occupe, 5.0)
			await sc.delai(1.0 if etape == "banquier_anim" else 1.65)
		"journal_anim":
			# Journal ordinaire (la démo n'en a pas d'autre que le krach) : contenu du krach, gravité ordinaire
			_jusqua_modale("p1e6")
			var c: Dictionary = Partie.etat.contenu_modale().duplicate(true)
			c["gravite"] = "moyenne"
			jeu.sequences.vedette(jeu.sequences._sequence_journal.bind(c))
			await sc.delai(1.6)
		"courrier_anim":
			# Courrier ordinaire (sans panne) : contenu de la panne, pictogramme d'enveloppe
			_jusqua_modale("voiture")
			var cc: Dictionary = Partie.etat.contenu_modale().duplicate(true)
			cc["picto"] = "enveloppe"
			jeu.sequences.vedette(jeu.sequences._sequence_courrier.bind(cc))
			await sc.delai(1.6)
		"news":
			sc.aller_a(Dates.lire("1988-05"), true)
			Partie.changer_vitesse(2)
			await sc.attendre_que(func() -> bool: return Partie.etat.ab_courant() >= Dates.lire("1988-06"), 15.0)
			await sc.delai(0.9)
		"krach_anim":
			sc.aller_a_modale("p1e6", true)
			await sc.attendre_que(func() -> bool: return jeu.sequences.occupe, 15.0)
			await sc.delai(1.05)
			if _controle:
				await sc.attendre_que(func() -> bool: return float(ville.get("krach")) >= 1.0, 3.0)
				await _controle_palette(ville, "krach_anim")
		"fps":
			sc.aller_a(Dates.lire("1987-11"), true)
			ville.set("pluie", true)
			ville.set("krach", 1.0)
			Partie.changer_vitesse(1)
			await sc.delai(1.0)
			var n0 := Engine.get_frames_drawn()
			var t1 := Time.get_ticks_msec()
			await sc.delai(3.0)
			print("Images par seconde (moyenne sur 3 s) : %.1f" % ((Engine.get_frames_drawn() - n0) * 1000.0 / (Time.get_ticks_msec() - t1)))


# --- Fenêtre ------------------------------------------------------------------------------------------

func _regler_fenetre(ville: Node2D) -> void:
	var fen := sc.get_window()
	if Ecran.telephone_simule:
		fen.size = Ecran.FENETRE_TELEPHONE_169 if Ecran.format_telephone == "169" else Ecran.FENETRE_TELEPHONE   # téléphones de référence (Ecran, lot_px2 §9.1)
		fen.move_to_center()
	elif "--rue-borderless" in OS.get_cmdline_user_args():
		var t := fen.size
		for arg in OS.get_cmdline_args():
			if "x" in arg and arg.split("x").size() == 2 and arg.split("x")[0].is_valid_int() and arg.split("x")[1].is_valid_int():
				t = Vector2i(int(arg.split("x")[0]), int(arg.split("x")[1]))
		fen.mode = Window.MODE_WINDOWED
		fen.borderless = true
		fen.position = Vector2i.ZERO
		fen.size = t
	var f := ScenariosCapture.option("rue-facteur")
	if f.is_valid_int():
		(ville.get("vue") as VuePixel).forcer_facteur(int(f))
	for i in 4:
		await sc.get_tree().process_frame
	sc.get_viewport().gui_release_focus()


# --- Contrôles ----------------------------------------------------------------------------------------

func _images(n: int) -> void:
	for i in n:
		await RenderingServer.frame_post_draw


func _controle_palette(ville: Node2D, etape: String) -> void:
	var rue: Node2D = ville.get("rue")
	await sc.attendre_que(func() -> bool: return rue.call("variante_nom") != "fondu", 8.0)
	var nom: String = rue.call("variante_nom")
	rue.call("afficher_lumieres", false)
	await _images(2)
	var img: Image = (ville.get("vue") as VuePixel).image_monde()
	rue.call("afficher_lumieres", true)
	var variante: int = {"jour": PalettePixel.JOUR, "nuit": PalettePixel.NUIT, "orage": PalettePixel.ORAGE}.get(nom, PalettePixel.JOUR)
	print("RUE palette etape=%s variante=%s pixels=%d hors_palette=%d" % [etape, nom, img.get_width() * img.get_height(), PalettePixel.compter_hors_palette(img, variante)])


func _controle_grille(ville: Node2D) -> void:
	var vue: VuePixel = ville.get("vue")
	var fen := sc.get_window()
	var tv := vue.taille_vue()
	print("RUE fenetre=%dx%d facteur=%d reduction=%.3f vue=%dx%d gerard_ecran=%d" % [fen.size.x, fen.size.y, vue.facteur(), vue.reduction(),
		tv.x, tv.y, roundi(63.0 * vue.px_physiques_par_art())])
	await _images(2)
	var r: Vector2i = PX0.controler_blocs(vue.image_monde(), vue.facteur())
	print("RUE grille blocs=%d irreguliers=%d" % [r.x, r.y])


func _lignes_rue(ville: Node2D) -> void:
	var b: Vector2 = ville.call("bornes_rue")
	print("RUE rue largeur=%d bornes=%d..%d gazette=%d maison=%d banque=%d camera=%d" % [RUE.DROITE - RUE.GAUCHE, int(b.x), int(b.y),
		int(ville.get("media").position.x), int(ville.get("maison").position.x), int(ville.get("banque").position.x), int(ville.call("position_camera"))])
	_cadrage(ville, "maison")
	for id in ["maison", "banque", "media"]:
		var p: Vector2 = ville.call("point_etiquette", id)
		print("RUE etiquette %s=%d,%d visible=%s" % [id, int(p.x), int(p.y), "oui" if ville.call("est_visible", id) else "non"])


func _cadrage(ville: Node2D, id: String) -> void:
	var b: Batiment = ville.call("batiment", id)
	var l: Rect2 = ville.call("libre_monde")
	print("RUE cadrage %s haut=%d bas=%d libre=%d..%d gauche=%d droite=%d libre_x=%d..%d" % [id, int(b.position.y - b.taille().y), int(b.position.y),
		int(l.position.y), int(l.end.y), int(b.position.x - b.taille().x / 2.0), int(b.position.x + b.taille().x / 2.0), int(l.position.x), int(l.end.x)])


# --- Défilement -----------------------------------------------------------------------------------------

func _fenetre_px(virtuel: Vector2) -> Vector2:
	return sc.get_viewport().get_final_transform() * virtuel


func _souris(bouton: MouseButton, appui: bool, virtuel: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = bouton
	ev.pressed = appui
	ev.position = _fenetre_px(virtuel)
	ev.global_position = ev.position
	if bouton == MOUSE_BUTTON_LEFT and appui:
		ev.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(ev)
	await sc.get_tree().process_frame


func _glisser(depart: Vector2, dx: float) -> void:
	await _souris(MOUSE_BUTTON_LEFT, true, depart)
	var pas := 12
	var precedent := _fenetre_px(depart)
	for i in pas:
		var ev := InputEventMouseMotion.new()
		var p := _fenetre_px(depart + Vector2(dx * (i + 1) / pas, 0))
		ev.position = p
		ev.global_position = p
		ev.relative = p - precedent
		ev.button_mask = MOUSE_BUTTON_MASK_LEFT
		precedent = p
		Input.parse_input_event(ev)
		await sc.get_tree().process_frame
	await _souris(MOUSE_BUTTON_LEFT, false, depart + Vector2(dx, 0))


func _defilement(ville: Node2D) -> void:
	var touches: Array = []
	var cb := func(id: String) -> void: touches.append(id)
	ville.batiment_touche.connect(cb)
	var rue_y: float = (ville.call("position_ecran", Vector2(0, RUE.SOL + 60)) as Vector2).y
	var maison_x: float = (ville.call("ecran_batiment", ville.get("maison"), Vector2.ZERO) as Vector2).x
	# 1. Glisser de 600 px virtuels vers la gauche
	var avant: float = ville.call("position_camera")
	await _glisser(Vector2(maison_x + 300.0, rue_y), -600.0)
	await sc.delai(0.6)
	var apres: float = ville.call("position_camera")
	print("RUE defilement avant=%d apres=%d touche=%s" % [int(avant), int(apres), "non" if touches.is_empty() else ",".join(touches)])
	# 2. Molette
	avant = ville.call("position_camera")
	await _souris(MOUSE_BUTTON_WHEEL_UP, true, Vector2(600, rue_y))
	await _souris(MOUSE_BUTTON_WHEEL_UP, false, Vector2(600, rue_y))
	await sc.delai(0.5)
	print("RUE molette avant=%d apres=%d" % [int(avant), int(ville.call("position_camera"))])
	# 3. Flèche →
	avant = ville.call("position_camera")
	sc.get_viewport().gui_release_focus()
	await sc.touche(KEY_RIGHT)
	await sc.delai(0.5)
	print("RUE fleche avant=%d apres=%d" % [int(avant), int(ville.call("position_camera"))])
	# 4. interactif = false : rien ne bouge
	ville.set("interactif", false)
	avant = ville.call("position_camera")
	await _glisser(Vector2(600, rue_y), -600.0)
	await sc.delai(0.5)
	print("RUE inactif avant=%d apres=%d" % [int(avant), int(ville.call("position_camera"))])
	ville.set("interactif", true)
	# 5. Toucher bref sur la banque
	var t: Tween = ville.call("aller_vers", "banque", 0.0)
	await sc.delai(0.2)
	touches.clear()
	var pb: Vector2 = ville.call("ecran_batiment", ville.get("banque"), Vector2(0, -150))
	await _souris(MOUSE_BUTTON_LEFT, true, pb)
	await _souris(MOUSE_BUTTON_LEFT, false, pb)
	await sc.delai(0.3)
	print("RUE toucher banque=%s" % ("oui" if "banque" in touches else "non"))
	ville.batiment_touche.disconnect(cb)


func _passer_apres(s: float) -> void:
	await sc.attendre_que(func() -> bool: return sc.jeu.sequences.occupe, 20.0)
	await sc.delai(s)
	var centre := sc.get_window().size / 2
	await sc.clic_dehors(Vector2(centre))


## Avance jusqu'à la modale id sans la rouvrir (la séquence est lancée par l'étape).
func _jusqua_modale(id: String) -> void:
	var e := Partie.etat
	var garde := 0
	while e.fin == "" and garde < 100:
		if not e.modale.is_empty():
			var ident := str(e.modale.get("id", ""))
			if e.modale.get("kind", "") == "vie":
				ident = str(e.calendrier[int(e.modale["idx"])]["type"])
			if ident == id:
				break
			sc.strategie_active(e)
			if not e.modale.is_empty():
				e.resolution_auto()
		else:
			sc.strategie_active(e)
		e.avancer()
		garde += 1
	sc.rafraichir_apres_saut()


# --- Planche des personnages ------------------------------------------------------------------------------

class Planche extends Node2D:
	var rue: Node2D
	var vue: Rect2
	var elements: Array = []     # [nom, position (coin haut gauche), échelle, étiquette]

	func _draw() -> void:
		draw_rect(Rect2(vue.position.floor(), vue.size.ceil()), PalettePixel.couleur("creme"))
		for e in elements:
			var tex := GrillePixel.texture(e[0])
			if tex == null:
				continue
			var k: int = e[2]
			draw_texture_rect(tex, Rect2(e[1], tex.get_size() * k), false)
			var t: String = e[3]
			if t != "":
				var x := int(e[1].x) + int(tex.get_width() * k) / 2 - MatieresPixel.largeur_texte(t) / 2
				var cx := x
				for ch in t:
					var g: Array = MatieresPixel.GLYPHES.get(ch, [])
					for j in g.size():
						for i in 3:
							if String(g[j])[i] == "1":
								draw_rect(Rect2(cx + i, int(e[1].y) + tex.get_height() * k + 3 + j, 1, 1), PalettePixel.couleur("encre"))
					cx += 4


func _planche(ville: Node2D) -> void:
	var rue: Node2D = ville.get("rue")
	var V := load("res://scripts/pixel/voisins.gd")
	for n in VILLE.PERSONNAGES:
		V.enregistrer(n)
	V.enregistrer_objets()
	var vue: Rect2 = rue.get("vue")
	var p := Planche.new()
	p.rue = rue
	p.vue = vue
	p.z_index = 100
	var o := vue.position + Vector2(12, 10)
	var noms := {"gerard": "GERARD", "tata": "TATA LIVRET", "matelas": "TONTON MATELAS", "jeanmi": "JEAN-MI", "lopez": "MME LOPEZ",
		"lefranc": "M. LEFRANC", "passant_1": "PASSANT 1", "passant_2": "PASSANTE 2", "passant_3": "PASSANT 3"}
	var x := 0.0
	for n in VILLE.PERSONNAGES:
		p.elements.append(["ville/%s_marche_1" % n, o + Vector2(x, 0), 2, noms[n]])
		x += 104.0
	x = 0.0
	var y2 := 158.0
	var rang2 := [["ville/lefranc_fume_1", 2, "FUME"], ["ville/lefranc_repos_1", 2, "REPOS"], ["objet/velo_1", 2, "JEAN-MI A VELO"],
		["objet/enfant_a_1", 2, "ENFANT"], ["objet/enfant_b_2", 2, "ENFANT"], ["objet/poussette", 2, "POUSSETTE"], ["objet/poussette_double", 2, "DOUBLE"]]
	for e in rang2:
		p.elements.append([e[0], o + Vector2(x, y2 + 144 - GrillePixel.taille(e[0]).y * int(e[1])), e[1], e[2]])
		x += GrillePixel.taille(e[0]).x * int(e[1]) + 18.0
	x = 0.0
	var y3 := 330.0
	for m in ["944", "r5", "205", "4l", "fourgonnette"]:
		var img := Image.new()
		img.copy_from(GrillePixel.image("rue/voiture_" + m))
		var info: Dictionary = RUE.voiture_info(m)
		for rx in info["roues"]:
			MatieresPixel.coller(img, GrillePixel.image("rue/roue_1"), int(rx) - 12, img.get_height() - 24)
		if m == "944":
			MatieresPixel.coller(img, GrillePixel.image("objet/a_vendre"), img.get_width() / 2 + 2, 6)
		GrillePixel.enregistrer("planche/" + m, img)
		var t := GrillePixel.taille("planche/" + m)
		p.elements.append(["planche/" + m, o + Vector2(x, y3 + 60 - t.y), 1, m.to_upper()])
		x += t.x + 14.0
	p.elements.append(["objet/a_vendre", o + Vector2(x + 4, y3 + 20), 3, "A VENDRE"])
	rue.add_child(p)
	print("RUE planche elements=%d" % p.elements.size())
