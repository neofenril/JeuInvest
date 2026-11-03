extends SceneTree
## Tests de la rue pixel du jeu (lot PX1, CA-V2) : ville.gd seule (Node2D + script), API conservée et ajouts
## (lot_px1 §2.1, §2.2), repères de la rue, caméra et bornes, saisons et météo, Sylvie, voisins, durée de
## génération, règle « N entier puis réduction » (§2.3). Headless :
##   Godot_console.exe --headless --path godot --script res://tests/test_rue.gd
## Code de sortie 0 si tout passe, 1 sinon. Aucun accès à user://. Les autoloads (Partie, Juice) sont lus à
## l'exécution par ville.gd ; ce script-ci ne les nomme pas.

const RUE := preload("res://scripts/ville/rue.gd")
const VILLE_GD := "res://scripts/ville/ville.gd"
const METHODES := ["cadrer", "viser", "revenir", "plonger_vers_maison", "position_ecran", "ecran_batiment", "batiment", "regler_mois",
	"point_etiquette", "est_visible", "aller_vers", "position_camera", "bornes_rue", "regler_humeur_sylvie", "humeur_sylvie",
	"faire_passer", "point_tete"]
const PROPRIETES := ["anime", "interactif", "mode_titre", "facteur_trafic", "phase", "nuit", "krach", "gel", "pluie", "ciel_mat",
	"camera", "maison", "banque", "media", "voiture_maison", "potelet", "passants"]
const FORMATS := [[Vector2i(1280, 720), 2, 0.667], [Vector2i(1366, 768), 2, 0.711], [Vector2i(1600, 720), 2, 0.667],
	[Vector2i(1920, 1080), 2, 1.0], [Vector2i(2560, 1440), 3, 0.889], [Vector2i(3840, 2160), 4, 1.0]]

var _ok := 0
var _ko := 0


func _verifier(cond: bool, nom: String, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  " + nom)
	else:
		_ko += 1
		print("KO  " + nom + ("" if detail == "" else " (" + detail + ")"))


func _images(n: int) -> void:
	for i in n:
		await process_frame


func _initialize() -> void:
	var debut := Time.get_ticks_msec()
	await process_frame
	# Règle de rendu (§2.3) : fonction pure
	for f in FORMATS:
		var r: Vector2 = VuePixel.facteur_et_reduction(f[0])
		_verifier(int(r.x) == f[1] and absf(r.y - f[2]) < 0.0015, "rendu : %dx%d → N=%d R=%.3f" % [f[0].x, f[0].y, f[1], f[2]], "N=%d R=%.3f" % [int(r.x), r.y])
	# Génération et instanciation de ville.gd seule
	var t0 := Time.get_ticks_msec()
	var ville := Node2D.new()
	ville.set_script(load(VILLE_GD))
	root.add_child(ville)
	var ms := Time.get_ticks_msec() - t0
	print("RUE generation_ms=%d" % ms)
	_verifier(ms <= 2000, "génération de la rue ≤ 2 000 ms (≈ 1,3 s mesurée : façades de fond, skyline, arbres en tâche de fond)", "%d ms" % ms)
	await _images(3)
	# API (§2.1, §2.2)
	for m in METHODES:
		_verifier(ville.has_method(m), "API : méthode %s" % m)
	var manquantes: Array = []
	for p in PROPRIETES:
		if not p in ville:
			manquantes.append(p)
	_verifier(manquantes.is_empty(), "API : %d propriétés présentes" % PROPRIETES.size(), ", ".join(manquantes))
	_verifier(ville.has_signal("batiment_touche") and ville.has_signal("camera_bougee"), "API : signaux batiment_touche et camera_bougee")
	var consts: Dictionary = (ville.get_script() as Script).get_script_constant_map()
	_verifier(consts.has("PERSONNAGES") and consts["PERSONNAGES"].size() == 9, "API : PERSONNAGES (9)")
	_verifier(ville.get("camera") is Camera2D, "API : camera est une Camera2D")
	# Bâtiments
	var ids := ["media", "maison", "banque"]
	var xs: Array = []
	for id in ids:
		var b: Node2D = ville.call("batiment", id)
		_verifier(b != null and b is Batiment and int(b.position.y) == RUE.SOL, "bâtiment %s : Batiment, pied au sol (y = %d)" % [id, RUE.SOL])
		xs.append(b.position.x if b != null else 0.0)
	_verifier(xs[0] < xs[1] and xs[1] < xs[2], "rue : Gazette < maison < banque", str(xs))
	var dg: float = xs[1] - xs[0]
	var db: float = xs[2] - xs[1]
	_verifier(dg >= 600.0 and dg <= 900.0 and db >= 600.0 and db <= 900.0, "rue : distances maison-Gazette et maison-banque entre 600 et 900", "%d / %d" % [dg, db])
	_verifier(RUE.DROITE - RUE.GAUCHE >= 2880, "rue : longueur habillée ≥ 2 880 px (%d)" % (RUE.DROITE - RUE.GAUCHE))
	_verifier(GrillePixel.taille("rue/banque") == Vector2i(270, 285) and GrillePixel.taille("rue/gazette") == Vector2i(225, 318) and GrillePixel.taille("rue/maison") == Vector2i(228, 258),
		"tailles : banque 270 × 285, Gazette 225 × 318, maison 228 × 258")
	# Caméra : cadrage, aller_vers / revenir, bornes
	var ecran: Vector2 = root.get_visible_rect().size
	ville.call("cadrer", Rect2(Vector2(0, ecran.y * 0.09), Vector2(ecran.x * 0.73, ecran.y * 0.84)), 0.0)
	await _images(2)
	var repos: float = ville.call("position_camera")
	_verifier(ville.call("est_visible", "maison"), "caméra : la maison est entière au repos", "libre %s, vue %s" % [str(ville.call("libre_monde")), str(ville.get("rue").get("vue"))])
	var t: Tween = ville.call("aller_vers", "banque", 0.0)
	_verifier(t != null, "caméra : aller_vers renvoie un Tween")
	await _images(2)
	_verifier(absf(float(ville.call("position_camera")) - repos) > 100.0, "caméra : aller_vers déplace la vue vers la banque")
	ville.call("revenir", 0.0)
	await _images(2)
	_verifier(absf(float(ville.call("position_camera")) - repos) < 1.0, "caméra : revenir ramène au repos", "%f / %f" % [ville.call("position_camera"), repos])
	ville.call("viser", ville.call("batiment", "media"), 0.0)
	await _images(1)
	ville.call("revenir", 0.0)
	await _images(1)
	_verifier(absf(float(ville.call("position_camera")) - repos) < 1.0, "caméra : viser puis revenir ramène au repos")
	var bornes: Vector2 = ville.call("bornes_rue")
	for d in [10000.0, -10000.0]:
		ville.set("_cx", float(ville.call("position_camera")) + d)
		ville.call("_appliquer")
		var x: float = ville.call("position_camera")
		_verifier(x >= bornes.x - 0.01 and x <= bornes.y + 0.01, "caméra : défilement de %+d px, reste dans les bornes" % int(d), "%f hors de %s" % [x, str(bornes)])
	var p: Vector2 = ville.call("point_etiquette", "maison")
	_verifier(p is Vector2, "point_etiquette renvoie un Vector2")
	var tw: Tween = ville.call("plonger_vers_maison", 0.0)
	_verifier(tw != null, "plonger_vers_maison renvoie un Tween")
	# Écran titre (recette A1) : enseigne du titre entière dans la vue, arbre de premier plan retiré
	ville.set("mode_titre", true)
	ville.call("cadrer", Rect2(Vector2.ZERO, ecran), 0.0)
	await _images(2)
	var med: Node2D = ville.call("batiment", "media")
	var enseigne := Rect2(med.position.x - 63, med.position.y - med.call("taille").y - 36, 125, 34)
	var vue_t: Rect2 = ville.get("rue").get("vue")
	_verifier(vue_t.encloses(enseigne), "titre : enseigne de la Gazette entière dans la vue", "%s / %s" % [str(enseigne), str(vue_t)])
	_verifier(not ville.get("rue").call("premier_plan_visible"), "titre : arbre de premier plan retiré")
	ville.set("mode_titre", false)
	ville.call("cadrer", Rect2(Vector2(0, ecran.y * 0.09), Vector2(ecran.x * 0.73, ecran.y * 0.84)), 0.0)
	await _images(2)
	_verifier(ville.get("rue").call("premier_plan_visible"), "jeu : arbre de premier plan de retour")
	# Saisons, temps, météo aux bornes
	for mois in range(1, 13):
		ville.call("regler_mois", mois, 1986)
	await _images(1)
	_verifier(ville.get("rue").get("saison") == "hiver", "saisons : décembre = hiver")
	ville.call("regler_mois", 10, 1986)
	_verifier(ville.get("rue").get("saison") == "automne", "saisons : octobre = automne")
	for v in [0.0, 1.0]:
		ville.set("phase", 0.7 if v > 0.0 else 0.1)
		ville.set("krach", v)
		ville.set("gel", v)
		ville.set("pluie", v > 0.0)
		await _images(2)
	_verifier(ville.get("rue").get("melange") == 1.0, "nuit : mélange à 1 en pleine nuit (phase 0,7)")
	_verifier(ville.get("rue").call("variante_nom") == "nuit", "nuit : variante nuit seule")
	ville.set("phase", 0.1)
	await _images(2)
	_verifier(ville.get("rue").call("variante_nom") == "orage", "krach : variante orage seule de jour")
	ville.set("krach", 0.0)
	ville.set("gel", 0.0)
	ville.set("pluie", false)
	# Sylvie
	_verifier(int(ville.call("humeur_sylvie")) == 1, "Sylvie : humeur neutre par défaut")
	for h in 3:
		ville.call("regler_humeur_sylvie", h)
		_verifier(int(ville.call("humeur_sylvie")) == h, "Sylvie : humeur %d relue" % h)
	# Voisins : chacun traverse et est libéré à la sortie
	var noeuds: Array = []
	for qui in consts["PERSONNAGES"]:
		noeuds.append(ville.call("faire_passer", qui, 1 if noeuds.size() % 2 == 0 else -1, 40.0))
	var tout := true
	for n in noeuds:
		tout = tout and n is Node2D
	_verifier(tout, "voisins : faire_passer renvoie un nœud pour les 9 personnages")
	var attente := 0
	while attente < 240:
		var restants := noeuds.filter(func(n: Variant) -> bool: return is_instance_valid(n))
		if restants.is_empty():
			break
		await process_frame
		attente += 1
	for i in noeuds.size():
		_verifier(not is_instance_valid(noeuds[i]), "voisins : %s libéré à la sortie" % consts["PERSONNAGES"][i])
	# Palette : objets et personnages générés dans les 3 variantes
	var hors := 0
	for n in GrillePixel.noms():
		if n.begins_with("objet/") or n.begins_with("edifice/") or n.begins_with("ville/") or n in ["rue/banque", "rue/gazette", "rue/maison"]:
			for v in [PalettePixel.JOUR, PalettePixel.NUIT, PalettePixel.ORAGE]:
				hors += PalettePixel.compter_hors_palette(GrillePixel.image(n, v), v)
	_verifier(hors == 0, "palette : images de la rue, objets, édifices dans les 3 variantes", "%d pixels hors palette" % hors)
	var garde := 0
	while not ville.get("rue").call("images_pretes") and garde < 600:
		await process_frame
		garde += 1
	_verifier(ville.get("rue").call("images_pretes"), "arbres : tâches de fond terminées")
	_verifier(GrillePixel.existe("rue/arbre_m0_0_ete") and GrillePixel.existe("rue/arbre_m3_1_ete") and GrillePixel.existe("rue/premier_plan_1_ete"), "arbres : 4 modèles × 2 images et premier plan enregistrés")
	_verifier(GrillePixel.existe("neige/rue/maison") and GrillePixel.existe("neige/rue/banque"), "hiver : neige sur les toits générée")
	_verifier(GrillePixel.existe("rue/arbre_m0_0_automne"), "automne : feuillages recolorés")
	ville.queue_free()
	await _images(2)
	print("test_rue : %d OK, %d KO (%d ms)" % [_ok, _ko, Time.get_ticks_msec() - debut])
	quit(1 if _ko > 0 else 0)
