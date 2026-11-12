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
	"faire_passer", "point_tete", "porte_ecran", "centrer_sur", "a_la_maison", "calme", "cx_pour", "point_sylvie"]
const SEUIL_GENERATION_MS := 2000
const PROPRIETES := ["anime", "interactif", "mode_titre", "facteur_trafic", "phase", "nuit", "krach", "gel", "pluie",
	"camera", "maison", "banque", "media", "voiture_maison", "potelet", "passants"]
const FORMATS := [[Vector2i(1280, 720), 2, 0.667], [Vector2i(1366, 768), 2, 0.711], [Vector2i(1600, 720), 2, 0.667],
	[Vector2i(1920, 1080), 2, 1.0], [Vector2i(2560, 1440), 3, 0.889], [Vector2i(3840, 2160), 4, 1.0], [Vector2i(1440, 648), 2, 0.600]]

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


## Seconde mesure de D9 : la génération est refaite pour de bon (le catalogue ne garde que ce qui est généré une
## fois par lancement : « rue/maison », le ciel et la skyline sont oubliés), dans une seconde ville, puis celle-ci
## est libérée (elle attend ses tâches de fond à la sortie). Renvoie la durée en ms.
func _relancer_generation() -> int:
	for n in ["rue/maison", "matiere/ciel", "matiere/skyline"]:
		GrillePixel._images.erase(n)
	var t0 := Time.get_ticks_msec()
	var v2 := Node2D.new()
	v2.set_script(load(VILLE_GD))
	root.add_child(v2)
	var ms2 := Time.get_ticks_msec() - t0
	await _images(2)
	v2.queue_free()
	await _images(2)
	return ms2


func _initialize() -> void:
	var debut := Time.get_ticks_msec()
	await process_frame
	# Règle de rendu (§2.3) : fonction pure
	for f in FORMATS:
		var r: Vector2 = VuePixel.facteur_et_reduction(f[0])
		_verifier(int(r.x) == f[1] and absf(r.y - f[2]) < 0.0015, "rendu : %dx%d → N=%d R=%.3f" % [f[0].x, f[0].y, f[1], f[2]], "N=%d R=%.3f" % [int(r.x), r.y])
	# Téléphone de référence (PX2, 1440 × 648) : Gérard (63 px d'art) ≈ 76 px à l'écran (lot 02, V6)
	var tel: Vector2 = VuePixel.facteur_et_reduction(Vector2i(1440, 648))
	var gerard_tel := roundi(63.0 * tel.x * tel.y)
	print("RUE fenetre=1440x648 facteur=%d reduction=%.3f gerard_ecran=%d" % [int(tel.x), tel.y, gerard_tel])
	_verifier(absi(gerard_tel - 76) <= 1, "téléphone 1440 × 648 : Gérard ≈ 76 px à l'écran (± 1)", str(gerard_tel))
	# Génération et instanciation de ville.gd seule
	var t0 := Time.get_ticks_msec()
	var ville := Node2D.new()
	ville.set_script(load(VILLE_GD))
	root.add_child(ville)
	var ms := Time.get_ticks_msec() - t0
	print("RUE generation_ms=%d" % ms)
	# D9 (lot 03) : la mesure est vérifiée à la fin du test ; si elle dépasse le seuil (machine chargée), une seule
	# relance et la plus courte des deux compte.
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
	# V8 (lot 03) : ciel vectoriel retiré pour de bon : ni shader ni propriété ciel_mat
	_verifier(not "ciel_mat" in ville and not FileAccess.file_exists("res://shaders/ciel.gdshader"), "API : ciel_mat et shaders/ciel.gdshader retirés ensemble (V8)")
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
	# Portes (pièces du mois, lot 02) : celle de la maison à l'écran au repos ; celle de la banque après aller_vers
	ville.call("revenir", 0.0)
	await _images(2)
	var pm: Vector2 = ville.call("porte_ecran", "maison")
	_verifier(pm.x >= 0.0 and ville.call("a_la_maison"), "portes : porte de la maison à l'écran au repos (caméra à la maison)", str(pm))
	# D10 (lot 03) : cx_pour public = ancien calcul (x − milieu du libre en px d'art + demi-vue)
	var vue: VuePixel = ville.get("vue")
	var a_v: Vector2 = vue.art_par_virtuel()
	var libre_v: Rect2 = ville.get("_libre")
	var la := Rect2(libre_v.position * a_v, libre_v.size * a_v)
	var ecarts_cx: Array = []
	for xm: float in [-683.0, 114.0, 813.0]:
		var attendu: float = xm - la.get_center().x + vue.taille_vue().x / 2.0
		var lu: float = ville.call("cx_pour", xm)
		if absf(lu - attendu) > 0.001 or absf(lu - float(ville.call("_cx_pour", xm))) > 0.001:
			ecarts_cx.append("%d : %f au lieu de %f" % [xm, lu, attendu])
	_verifier(ecarts_cx.is_empty(), "D10 : cx_pour(x) = ancien calcul sur 3 valeurs (Gazette, maison, banque)", ", ".join(ecarts_cx))
	# point_sylvie (lot 03, vague 3) : au-dessus de la fenêtre de Sylvie quand la maison est visible
	var maison_b: Node2D = ville.call("batiment", "maison")
	var fs: Rect2 = maison_b.call("fenetre_sylvie")
	var haut_fenetre: Vector2 = maison_b.position + Vector2(fs.get_center().x, fs.position.y)
	var ps: Vector2 = ville.call("point_sylvie")
	var ps_monde: Vector2 = vue.ecran_vers_monde(ps) if ps.x >= 0.0 else Vector2(-9999, -9999)
	_verifier(Rect2(Vector2.ZERO, ecran).has_point(ps) and absf(ps_monde.x - haut_fenetre.x) <= 8.0 and ps_monde.y <= haut_fenetre.y and ps_monde.y >= haut_fenetre.y - 8.0,
		"point_sylvie : dans l'écran, au-dessus de la fenêtre de Sylvie (± 8 px d'art), maison visible", "%s → monde %s, fenêtre %s" % [str(ps), str(ps_monde), str(haut_fenetre)])
	ville.call("aller_vers", "banque", 0.0)
	await _images(2)
	var pb: Vector2 = ville.call("porte_ecran", "banque")
	_verifier(pb.x >= 0.0 and not ville.call("a_la_maison"), "portes : porte de la banque à l'écran après aller_vers ; caméra plus à la maison", str(pb))
	_verifier((ville.call("porte_ecran", "media") as Vector2).x < 0.0, "portes : la Gazette n'a pas de porte de pièces")
	_verifier(ville.call("point_sylvie") == Vector2(-1, -1), "point_sylvie : (-1, -1) quand la maison est hors champ (caméra sur la banque)", str(ville.call("point_sylvie")))
	_verifier(consts.get("RETOUR_AUTO_S", 0.0) == 10.0 and consts.get("RETOUR_DUREE_S", 0.0) == 0.8, "D7 : retour automatique après 10 s, glissement de 0,8 s")
	ville.set("interactif", true)
	await _images(30)
	_verifier(float(ville.call("calme")) == 0.0, "D7 : temps à l'arrêt (aucune partie) : le compteur de retour n'avance pas")
	ville.set("interactif", false)
	ville.call("revenir", 0.0)
	await _images(2)
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
	# A3 : chargement d'une partie en hiver, avant la fin des tâches de fond : jamais un arbre d'été sous la neige
	var rue: Node2D = ville.get("rue")
	ville.call("regler_mois", 1, 1988)
	await _images(1)
	var noms_arbres: Array = []
	for a in rue.get("_arbres"):
		noms_arbres.append(String(a[0].parts[0][0]))
	noms_arbres.append(String(rue.get("_premier_plan").parts[0][0]))
	_verifier(noms_arbres.all(func(n: String) -> bool: return n.ends_with("_hiver")), "hiver (A3) : arbres et premier plan demandés en feuillage d'hiver", ", ".join(noms_arbres))
	ville.call("regler_mois", 5, 1987)
	# A11 : tâches de fond et préchauffage terminés, la première nuit et le premier orage ne créent plus rien en direct
	var t_attente := Time.get_ticks_msec()
	var t_arbres := -1
	while not rue.call("images_pretes") and Time.get_ticks_msec() - t_attente < 20000:
		await process_frame
		if t_arbres < 0 and GrillePixel.existe("rue/arbre_m3_1_hiver") and GrillePixel.existe("rue/premier_plan_1_hiver"):
			t_arbres = Time.get_ticks_msec() - debut
	print("RUE arbres_depuis_debut_ms=%d taches_et_prechauffage_ms=%d" % [t_arbres, Time.get_ticks_msec() - t_attente])
	_verifier(rue.call("images_pretes"), "arbres et préchauffage : tâches de fond terminées")
	var sans_texture: Array = []
	for n in GrillePixel.noms():
		if n.begins_with("rue/") or n.begins_with("matiere/") or n.begins_with("neige/") or n.begins_with("ville/"):
			for v in [PalettePixel.JOUR, PalettePixel.NUIT, PalettePixel.ORAGE]:
				if not GrillePixel.texture_prete(n, v):
					sans_texture.append("%s|%d" % [n, v])
	_verifier(sans_texture.is_empty(), "préchauffage (A11) : textures jour, nuit et orage de la rue toutes créées", "%d manquantes, ex. %s" % [sans_texture.size(), ", ".join(sans_texture.slice(0, 4))])
	var pire := 0
	for reglage in [[0.7, 0.0], [0.1, 1.0], [0.1, 0.0], [0.4, 0.6]]:
		ville.set("phase", reglage[0])
		ville.set("krach", reglage[1])
		var t_prec := Time.get_ticks_usec()
		for i in 8:
			await process_frame
			var t_im := Time.get_ticks_usec()
			pire = maxi(pire, t_im - t_prec)
			t_prec = t_im
	print("RUE image_max_ms=%.1f (première nuit, premier orage, fondus, après préchauffage)" % (pire / 1000.0))
	_verifier(pire <= 50000, "première nuit et premier orage : aucune image > 50 ms (A11)", "%.1f ms" % (pire / 1000.0))
	ville.set("krach", 0.0)
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
	_verifier(GrillePixel.existe("rue/arbre_m0_0_ete") and GrillePixel.existe("rue/arbre_m3_1_ete") and GrillePixel.existe("rue/premier_plan_1_ete"), "arbres : 4 modèles × 2 images et premier plan enregistrés")
	_verifier(GrillePixel.existe("neige/rue/maison") and GrillePixel.existe("neige/rue/banque") and GrillePixel.existe("neige/rue/fond_0"), "hiver : neige sur les toits générée")
	_verifier(GrillePixel.existe("rue/arbre_m0_0_automne") and GrillePixel.existe("rue/premier_plan_1_hiver"), "automne, hiver : feuillages recolorés")
	# D9 (lot 03) : durée de génération, meilleure de 2 mesures (relance seulement si la 1re dépasse le seuil ;
	# --rue-relance la force pour l'éprouver)
	var ms_retenue := ms
	if ms > SEUIL_GENERATION_MS or "--rue-relance" in OS.get_cmdline_user_args():
		var ms2: int = await _relancer_generation()
		ms_retenue = mini(ms, ms2)
		print("RUE generation_ms=%d relance_ms=%d retenue_ms=%d seuil_ms=%d" % [ms, ms2, ms_retenue, SEUIL_GENERATION_MS])
	else:
		print("RUE generation_ms=%d relance=non retenue_ms=%d seuil_ms=%d" % [ms, ms_retenue, SEUIL_GENERATION_MS])
	_verifier(ms_retenue <= SEUIL_GENERATION_MS, "génération de la rue ≤ 2 000 ms, meilleure de 2 mesures si la 1re dépasse (≈ 1,3 s à vide ; D9)", "%d ms" % ms_retenue)
	ville.queue_free()
	await _images(2)
	# Sortie propre : une rue quittée pendant que ses tâches de fond tournent les attend (blocage à la sortie, PX1-bis)
	var rue2 := Node2D.new()
	rue2.set_script(RUE)
	root.add_child(rue2)
	RUE._tache(func(res: Dictionary) -> void:
		OS.delay_msec(300)
		res["test/sortie"] = [Image.create_empty(2, 2, false, Image.FORMAT_RGBA8), Vector2i.ZERO])
	var t_sortie := Time.get_ticks_msec()
	rue2.queue_free()
	await _images(2)
	_verifier(RUE._taches.is_empty() and GrillePixel.existe("test/sortie"), "sortie : tâches de fond attendues et récoltées quand la rue quitte l'arbre", "%d en cours après %d ms" % [RUE._taches.size(), Time.get_ticks_msec() - t_sortie])
	print("test_rue : %d OK, %d KO (%d ms)" % [_ok, _ko, Time.get_ticks_msec() - debut])
	quit(1 if _ko > 0 else 0)
