extends RefCounted
## Figurines de la rue (lot PX1, docs/15 et docs/16 §1.2) : voisins, passants, enfants, poussettes, vélo,
## panneau « À VENDRE ». Générées en code dans la palette, sur le gabarit de Gérard (36 × 63, profil vers
## la droite, marche 4 images, repos 2), avec les pinceaux de personnages.gd. Pas de class_name (preload).
## Chaque personnage a une silhouette et une couleur signature (proposition de dev-ville, jugée par le joueur
## sur la planche) :
## - Tata Livret : cardigan vert, jupe grise, chignon gris, lunettes, sac à main ;
## - Tonton Matelas : béret, pull marron, ventre, moustache blanche, pantalon de velours ;
## - Jean-Mi : blouson rouge, jean, coupe « mulet » blonde, moustache (variante à vélo) ;
## - Mme Lopez : blouse bleue longue, fichu rouge, balai ;
## - M. Lefranc : costume bleu nuit, cravate bordeaux, lunettes, moustache grise (variante qui fume) ;
## - 3 passants génériques (imper beige et chapeau, manteau orange, ado au walkman).

const M := preload("res://scripts/pixel/matieres.gd")
const P := preload("res://scripts/pixel/personnages.gd")

const TAILLE := Vector2i(36, 63)
const ENFANT := Vector2i(22, 36)
const PEAU := ["peau_claire", "peau_claire", "peau_ombre", "caramel"]
const CHAUSSURE := ["bois", "bois_sombre", "bois_sombre", "encre"]

## Réglages : veste, bas (4 tons : éclairé, moyen, ombre, contour), jupe, cheveux, coiffure, extras.
const PERSOS := {
	"tata": {"veste": ["vert_clair", "vert", "vert_sombre", "feuille_profonde"], "bas": ["gris_pierre", "ardoise", "ardoise_sombre", "nuit"],
		"jupe": true, "jambes": ["pierre_claire", "pierre", "pierre_ombre", "bois"], "cheveux": ["blanc_chaud", "zinc_clair", "gris_pierre", "ardoise"],
		"coiffure": "chignon", "lunettes": true, "sac": "bois", "col": "creme"},
	"matelas": {"veste": ["caramel", "bois", "bois_sombre", "bois_sombre"], "bas": ["pierre", "pierre_ombre", "bois", "bois_sombre"],
		"cheveux": ["zinc_clair", "gris_pierre", "ardoise", "ardoise"], "coiffure": "beret", "beret": "bleu_nuit",
		"moustache": "blanc_chaud", "ventre": true, "col": "pierre_claire"},
	"jeanmi": {"veste": ["tuile", "rouge_auvent", "brique_sombre", "brique_sombre"], "bas": ["ciel", "bleu_vif", "bleu_ardoise", "bleu_nuit"],
		"cheveux": ["lumiere", "or", "caramel", "bois"], "coiffure": "mulet", "moustache": "caramel", "col": "blanc_chaud"},
	"lopez": {"veste": ["ciel", "bleu_vif", "bleu_ardoise", "bleu_nuit"], "bas": ["ciel", "bleu_vif", "bleu_ardoise", "bleu_nuit"],
		"jupe": true, "longue": true, "jambes": ["peau_claire", "peau_claire", "peau_ombre", "caramel"],
		"cheveux": ["bois", "bois_sombre", "nuit", "nuit"], "coiffure": "fichu", "fichu": ["tuile", "rouge_auvent", "brique_sombre"],
		"balai": true, "col": "blanc_chaud"},
	"lefranc": {"veste": ["bleu_ardoise", "bleu_nuit", "nuit", "encre"], "bas": ["bleu_ardoise", "bleu_nuit", "nuit", "encre"],
		"cheveux": ["zinc_clair", "gris_pierre", "ardoise", "ardoise"], "coiffure": "degarni", "lunettes": true,
		"moustache": "gris_pierre", "cravate": "brique_sombre", "col": "blanc_chaud", "chaussure": ["ardoise", "nuit", "nuit", "encre"]},
	"passant_1": {"veste": ["pierre_claire", "pierre", "pierre_ombre", "bois"], "bas": ["ardoise", "ardoise_sombre", "nuit", "encre"],
		"cheveux": ["bois", "bois_sombre", "nuit", "nuit"], "coiffure": "chapeau", "chapeau": ["ardoise", "ardoise_sombre", "nuit"], "col": "blanc_chaud", "long_manteau": true},
	"passant_2": {"veste": ["terre_cuite_claire", "orange", "tuile", "brique"], "bas": ["bleu_nuit", "bleu_nuit", "nuit", "encre"],
		"jupe": true, "jambes": ["peau_claire", "peau_claire", "peau_ombre", "caramel"], "cheveux": ["tuile", "brique", "brique_sombre", "brique_sombre"],
		"coiffure": "long", "sac": "bleu_vif", "col": "creme"},
	"passant_3": {"veste": ["ciel", "sarcelle", "vert_sombre", "nuit"], "bas": ["ciel", "bleu_vif", "bleu_ardoise", "bleu_nuit"],
		"cheveux": ["nuit", "nuit", "encre", "encre"], "coiffure": "court", "walkman": true, "col": "blanc_chaud",
		"chaussure": ["blanc_chaud", "zinc_clair", "gris_pierre", "ardoise"]},
}
const NOMS := ["tata", "matelas", "jeanmi", "lopez", "lefranc", "passant_1", "passant_2", "passant_3"]


static func _table(cfg: Dictionary) -> Dictionary:
	var t := {}
	for cle in ["veste", "bas", "jambes", "cheveux"]:
		if cfg.has(cle):
			var m: Array = cfg[cle]
			for i in 3:
				t[m[i]] = m[3]
	for m in [PEAU, CHAUSSURE, cfg.get("chaussure", CHAUSSURE)]:
		for i in 3:
			t[m[i]] = m[3]
	t["blanc_chaud"] = "pierre_ombre"
	t["creme"] = "pierre_ombre"
	t["or"] = "orange"
	t["encre"] = "encre"
	t["nuit"] = "encre"
	t["brique_sombre"] = "nuit"
	t["rouge_auvent"] = "brique_sombre"
	t["tuile"] = "brique_sombre"
	t["bleu_nuit"] = "encre"
	t["bois"] = "bois_sombre"
	t["bois_sombre"] = "encre"
	return t


## Figurine 36 × 63 d'un personnage (cfg de PERSOS) dans une pose de personnages.gd (marche_1..4, repos_1..2)
## ou « fume » (repos, main à la bouche, cigarette).
static func figurine(cfg: Dictionary, pose: String) -> Image:
	var fume := pose.begins_with("fume")
	var p: Array = P.POSES["repos_1" if fume else pose]
	var img := M.vide(TAILLE.x, TAILLE.y)
	var b: int = p[8]
	var tete := 1 if pose == "repos_2" else 0
	var veste: Array = cfg["veste"]
	var bas: Array = cfg["bas"]
	var jambes: Array = cfg.get("jambes", bas)
	var chauss: Array = cfg.get("chaussure", CHAUSSURE)
	var hanche := Vector2(18, 39 + b)
	var epaule := Vector2(17.5, 26 + b)
	# Balai (derrière le bras du fond)
	if cfg.get("balai", false):
		var mx: Vector2 = p[7] + Vector2(0, b)
		for j in 34:
			M.px(img, int(mx.x) + 3 - j / 9, int(mx.y) - 8 + j, "bois")
		M.rect(img, int(mx.x) - 5, int(mx.y) + 24, 8, 4, "or")
		M.rect(img, int(mx.x) - 5, int(mx.y) + 27, 8, 1, "orange")
	# Jambe et bras du fond
	_jambe(img, hanche + Vector2(-1, 0), p[2] + Vector2(0, b * 0.5), p[3], true, jambes, chauss)
	P._membre(img, epaule + Vector2(1, 1), p[6] + Vector2(0, b), 2.6, veste, true)
	P._membre(img, p[6] + Vector2(0, b), p[7] + Vector2(0, b), 2.2, veste, true)
	P._main(img, p[7] + Vector2(0, b), true)
	if cfg.has("sac"):
		var s: Vector2 = p[7] + Vector2(0, b)
		M.rect(img, int(s.x) - 4, int(s.y) + 3, 9, 7, String(cfg["sac"]))
		M.rect(img, int(s.x) - 4, int(s.y) + 9, 9, 1, "bois_sombre")
		M.px(img, int(s.x) - 2, int(s.y) + 2, "bois_sombre")
		M.px(img, int(s.x) + 2, int(s.y) + 2, "bois_sombre")
	# Buste
	var bas_buste := 40 + b
	if cfg.get("long_manteau", false) or cfg.get("longue", false):
		bas_buste = 48 + b
	var ventre := 3 if cfg.get("ventre", false) else 0
	var buste := PackedVector2Array([Vector2(11, 25 + b), Vector2(24, 25 + b), Vector2(26 + ventre, 31 + b), Vector2(25 + ventre, bas_buste),
		Vector2(12, bas_buste), Vector2(10, 29 + b)])
	P._poly(img, buste, veste[1])
	for y in range(25 + b, bas_buste + 1):
		for x in range(9, 31):
			if img.get_pixel(x, y).a > 0.0 and PalettePixel.nom_de(img.get_pixel(x, y)) == veste[1]:
				if x <= 12 or (x <= 14 and y < 30 + b):
					M.px(img, x, y, veste[0])
				elif x >= 23 + ventre:
					M.px(img, x, y, veste[2])
	# Jupe (trapèze jusqu'au genou) ou ceinture
	if cfg.get("jupe", false) and not cfg.get("longue", false):
		P._poly(img, PackedVector2Array([Vector2(12, 39 + b), Vector2(25, 39 + b), Vector2(27, 50 + b), Vector2(10, 50 + b)]), bas[1])
		M.rect(img, 11, 49 + b, 16, 1, bas[2])
		M.rect(img, 12, 39 + b, 2, 10, bas[0])
	elif cfg.get("longue", false):
		P._poly(img, PackedVector2Array([Vector2(12, 39 + b), Vector2(25, 39 + b), Vector2(27, 51 + b), Vector2(10, 51 + b)]), veste[1])
		M.rect(img, 11, 50 + b, 16, 1, veste[2])
		M.rect(img, 15, 30 + b, 1, 20, veste[2])
		for y in [33, 39, 45]:
			M.px(img, 17, y + b, "blanc_chaud")
	elif not cfg.get("long_manteau", false):
		M.rect(img, 12, 37 + b, 13 + ventre, 1, veste[2])
		M.rect(img, 12, 39 + b, 13 + ventre, 2, "bois_sombre")
	else:
		M.rect(img, 12, 47 + b, 14, 1, veste[2])
		M.rect(img, 13, 38 + b, 12, 1, veste[2])
	# Cravate, walkman
	if cfg.has("cravate"):
		M.rect(img, 21, 25 + b, 2, 9, String(cfg["cravate"]))
		M.px(img, 21, 34 + b, String(cfg["cravate"]))
	if cfg.get("walkman", false):
		M.rect(img, 11, 36 + b, 4, 3, "or")
		M.px(img, 12, 37 + b, "encre")
	# Jambe proche
	_jambe(img, hanche + Vector2(1, 0), p[0] + Vector2(0, b * 0.5), p[1], false, jambes, chauss)
	if cfg.get("jupe", false) and not cfg.get("longue", false):
		P._poly(img, PackedVector2Array([Vector2(14, 41 + b), Vector2(25, 41 + b), Vector2(27, 50 + b), Vector2(12, 50 + b)]), bas[1])
		M.rect(img, 11, 49 + b, 16, 1, bas[2])
	elif cfg.get("longue", false):
		P._poly(img, PackedVector2Array([Vector2(14, 42 + b), Vector2(25, 42 + b), Vector2(27, 51 + b), Vector2(12, 51 + b)]), veste[1])
		M.rect(img, 11, 50 + b, 16, 1, veste[2])
	# Tête, col
	_tete(img, tete + b, cfg)
	M.rect(img, 19, 23 + b, 4, 2, String(cfg.get("col", "blanc_chaud")))
	# Bras proche
	if fume:
		var coude := Vector2(21, 33 + b)
		var main := Vector2(25, 22 + b)
		P._membre(img, epaule, coude, 2.8, veste)
		P._membre(img, coude, main, 2.4, veste)
		P._main(img, main, false)
		M.rect(img, 27, 21 + b, 4, 1, "blanc_chaud")
		M.px(img, 31, 21 + b, "orange" if pose == "fume_1" else "tuile")
	else:
		P._membre(img, epaule, p[4] + Vector2(0, b), 2.8, veste)
		P._membre(img, p[4] + Vector2(0, b), p[5] + Vector2(0, b), 2.4, veste)
		P._main(img, p[5] + Vector2(0, b), false)
	P.contour_teinte(img, _table(cfg))
	if fume:
		var f := 0 if pose == "fume_1" else 1
		M.px(img, 31, 18 + b - f, "zinc_clair")
		M.px(img, 32 - f, 16 + b - f, "gris_pierre")
		M.px(img, 31 + f, 14 + b - f, "zinc_clair")
	return img


static func _jambe(img: Image, hanche: Vector2, genou: Vector2, cheville: Vector2, fond: bool, t: Array, ch: Array) -> void:
	P._membre(img, hanche, genou, 3.4, t, fond)
	P._membre(img, genou, cheville, 3.0, t, fond)
	var x := int(cheville.x) - 3
	var y := int(cheville.y)
	M.rect(img, x, y, 9, 3, ch[1])
	M.rect(img, x + 6, y + 1, 4, 2, ch[1])
	M.rect(img, x + 1, y, 4, 1, ch[0] if not fond else ch[1])
	M.rect(img, x, y + 3, 10, 1, "encre" if not fond else "bois_sombre")


## Tête de profil (vers la droite) : visage de Gérard, coiffure et accessoires du personnage.
static func _tete(img: Image, y0: int, cfg: Dictionary) -> void:
	var ch: Array = cfg["cheveux"]
	M.rect(img, 16, 19 + y0, 6, 5, "peau_ombre")
	M.rect(img, 16, 19 + y0, 2, 5, "peau_claire")
	P._ellipse(img, 18.5, 11.5 + y0, 9.0, 10.0, PEAU, 0.6)
	P._ellipse(img, 22.0, 16.0 + y0, 5.5, 4.5, PEAU, 0.4)
	for q in [Vector2i(27, 10), Vector2i(27, 11), Vector2i(28, 11), Vector2i(28, 12), Vector2i(27, 12), Vector2i(28, 13), Vector2i(27, 13)]:
		M.px(img, q.x, q.y + y0, "peau_claire")
	M.px(img, 27, 14 + y0, "peau_ombre")
	M.px(img, 28, 13 + y0, "peau_ombre")
	var coiffure: String = cfg.get("coiffure", "court")
	# Cheveux (calotte) selon la coiffure
	for y in range(0, 21):
		for x in range(6, 30):
			var dx := (x + 0.5 - 17.5) / 10.5
			var dyy := (y + 0.5 - 9.5) / 9.5
			var dedans := dx * dx + dyy * dyy <= 1.0
			var garde := false
			match coiffure:
				"degarni":
					garde = dedans and ((x < 14 and y > 4 and y < 15) or (y >= 2 and y < 5 and x < 18))
				"mulet":
					garde = (dedans and (y < 6 or (x < 15 and y < 17) or (x < 21 and y < 8))) or (x >= 8 and x < 15 and y >= 15 and y < 24)
				"long":
					garde = (dedans and (y < 6 or (x < 16 and y < 18) or (x < 22 and y < 7))) or (x >= 7 and x < 16 and y >= 16 and y < 28)
				"chignon":
					garde = dedans and (y < 6 or (x < 14 and y < 16) or (x < 20 and y < 7))
				_:
					garde = dedans and (y < 6 or (x < 14 and y < 17) or (x < 21 and y < 8 - maxi(0, x - 17)) or (x < 16 and y < 12))
			if not garde:
				continue
			var nom: String = ch[1]
			if dx < -0.15 and dyy < -0.3:
				nom = ch[0]
			elif dx > 0.45 or dyy > 0.45 or (x < 11 and y > 9):
				nom = ch[2]
			M.px(img, x, y + y0, nom)
	if coiffure == "chignon":
		P._ellipse(img, 10.0, 6.0 + y0, 4.0, 4.0, [ch[0], ch[1], ch[2], ch[3]], 0.3)
	# Oreille
	if coiffure != "fichu":
		P._ellipse(img, 14.0, 12.5 + y0, 1.8, 2.8, ["peau_claire", "peau_ombre", "caramel", "caramel"])
		M.px(img, 14, 12 + y0, "caramel")
	# Sourcil, œil, bouche
	M.rect(img, 22, 7 + y0, 4, 1, ch[2] if coiffure != "degarni" else "gris_pierre")
	M.rect(img, 23, 9 + y0, 1, 2, "blanc_chaud")
	M.rect(img, 24, 9 + y0, 1, 2, "encre")
	M.px(img, 23, 8 + y0, "peau_ombre")
	M.rect(img, 23, 16 + y0, 3, 1, "brique_sombre")
	M.px(img, 24, 17 + y0, "tuile")
	M.px(img, 24, 13 + y0, "blanc_chaud")
	if cfg.has("moustache"):
		M.rect(img, 22, 14 + y0, 6, 2, String(cfg["moustache"]))
		M.px(img, 27, 15 + y0, "peau_ombre")
	if cfg.get("lunettes", false):
		M.cadre(img, 22, 8 + y0, 5, 4, "nuit")
		M.rect(img, 16, 9 + y0, 6, 1, "nuit")
	match coiffure:
		"beret":
			var b: String = cfg.get("beret", "bleu_nuit")
			M.rect(img, 8, 0 + y0, 21, 5, b)
			M.rect(img, 6, 3 + y0, 25, 3, b)
			M.rect(img, 9, 0 + y0, 8, 1, "bleu_ardoise")
			M.rect(img, 17, -1 + y0 if y0 > 0 else 0, 2, 1, b)
			M.rect(img, 6, 5 + y0, 25, 1, "nuit")
		"chapeau":
			var c: Array = cfg["chapeau"]
			M.rect(img, 9, 0 + y0, 18, 5, c[0])
			M.rect(img, 9, 3 + y0, 18, 2, c[2])
			M.rect(img, 5, 5 + y0, 27, 2, c[1])
			M.rect(img, 5, 6 + y0, 27, 1, c[2])
		"fichu":
			var f: Array = cfg["fichu"]
			for y in range(0, 20):
				for x in range(6, 26):
					var dx2 := (x + 0.5 - 16.5) / 10.0
					var dy2 := (y + 0.5 - 9.0) / 9.5
					if dx2 * dx2 + dy2 * dy2 <= 1.0 and (y < 7 or x < 17):
						M.px(img, x, y + y0, f[0] if (x + y) % 5 != 0 else f[1])
			M.rect(img, 6, 13 + y0, 3, 6, f[1])
			M.rect(img, 4, 18 + y0, 4, 3, f[2])
	if cfg.get("walkman", false):
		M.rect(img, 13, 1 + y0, 10, 1, "ardoise")
		M.rect(img, 12, 9 + y0, 4, 5, "or")


# --- Enfants, poussettes, vélo, panneau ----------------------------------------------------------------------

## Enfant 22 × 36 (profil vers la droite) : couleur du pull, 2 images de marche.
static func enfant(pull: Array, cheveux: Array, image := 0) -> Image:
	var img := M.vide(ENFANT.x, ENFANT.y)
	var j := 1 if image % 2 == 0 else -1
	P._membre(img, Vector2(10, 22), Vector2(10 - 2 * j, 33), 2.2, ["ardoise", "ardoise_sombre", "nuit", "encre"], true)
	P._membre(img, Vector2(11, 22), Vector2(11 + 2 * j, 33), 2.2, ["gris_pierre", "ardoise", "ardoise_sombre", "nuit"])
	M.rect(img, 7 - 2 * j, 33, 5, 2, "bois_sombre")
	M.rect(img, 9 + 2 * j, 33, 6, 2, "bois")
	P._poly(img, PackedVector2Array([Vector2(6, 14), Vector2(15, 14), Vector2(16, 24), Vector2(6, 24)]), pull[1])
	M.rect(img, 6, 14, 2, 10, pull[0])
	M.rect(img, 14, 15, 2, 9, pull[2])
	P._membre(img, Vector2(11, 16), Vector2(12 + j, 22), 1.8, pull)
	P._ellipse(img, 11.5, 8.0, 6.5, 7.0, PEAU, 0.6)
	for y in range(1, 9):
		for x in range(5, 18):
			var dx := (x + 0.5 - 11.0) / 7.0
			var dy := (y + 0.5 - 7.0) / 6.5
			if dx * dx + dy * dy <= 1.0 and (y < 5 or x < 10):
				M.px(img, x, y, cheveux[1] if dx > -0.3 else cheveux[0])
	M.px(img, 15, 7, "encre")
	M.px(img, 15, 11, "brique_sombre")
	M.px(img, 16, 8, "peau_ombre")
	P.contour_teinte(img, {pull[0]: pull[3], pull[1]: pull[3], pull[2]: pull[3], "peau_claire": "caramel",
		"peau_ombre": "caramel", cheveux[0]: cheveux[2], cheveux[1]: cheveux[2], "ardoise": "nuit", "gris_pierre": "nuit",
		"ardoise_sombre": "nuit", "bois": "bois_sombre", "bois_sombre": "encre"})
	return img


## Poussette (simple 40 × 31 ou double 60 × 31), capote vers la gauche, guidon à droite.
static func poussette(double := false) -> Image:
	var l := 60 if double else 40
	var img := M.vide(l, 31)
	var n := 2 if double else 1
	for k in n:
		var x0 := 2 + k * 22
		P._poly(img, PackedVector2Array([Vector2(x0, 10), Vector2(x0 + 20, 10), Vector2(x0 + 18, 21), Vector2(x0 + 3, 21)]), "bleu_ardoise")
		M.rect(img, x0, 10, 20, 2, "bleu_vif")
		P._ellipse(img, x0 + 7.0, 9.0, 7.0, 7.0, ["bleu_vif", "bleu_ardoise", "bleu_nuit", "encre"], 0.3)
		M.rect(img, x0, 9, 16, 2, "bleu_nuit")
		M.rect(img, x0 + 11, 8, 7, 3, "creme")
	M.rect(img, 4, 21, l - 10, 2, "zinc_clair")
	for j in 10:
		M.px(img, l - 8 + j / 3, 10 - j, "gris_pierre")
	M.rect(img, l - 6, 0, 5, 2, "nuit")
	for rx in [8, l - 12] + ([l / 2 - 2] if double else []):
		P._ellipse(img, float(rx), 26.0, 4.5, 4.5, ["gris_pierre", "ardoise", "nuit", "encre"], 0.0)
		M.px(img, rx, 26, "zinc_clair")
	P.contour_teinte(img, {"bleu_ardoise": "bleu_nuit", "bleu_vif": "bleu_nuit", "bleu_nuit": "encre", "creme": "pierre_ombre",
		"zinc_clair": "ardoise", "gris_pierre": "nuit", "ardoise": "nuit", "nuit": "encre"})
	return img


## Jean-Mi à vélo (64 × 72, origine au milieu du bas) : 2 images de pédalage.
static func velo(image := 0) -> Image:
	var img := M.vide(64, 72)
	var r1 := Vector2(14, 60)
	var r2 := Vector2(50, 60)
	for c in [r1, r2]:
		for a in 48:
			var ang := a * TAU / 48.0
			M.px(img, int(c.x + cos(ang) * 10.5), int(c.y + sin(ang) * 10.5), "encre")
			M.px(img, int(c.x + cos(ang) * 9.5), int(c.y + sin(ang) * 9.5), "ardoise")
		for a in 4:
			var ang2 := a * PI / 4.0 + image * PI / 8.0
			for t in 9:
				M.px(img, int(c.x + cos(ang2) * t), int(c.y + sin(ang2) * t), "gris_pierre")
				M.px(img, int(c.x - cos(ang2) * t), int(c.y - sin(ang2) * t), "gris_pierre")
	var pedalier := Vector2(31, 60)
	var selle := Vector2(26, 40)
	var guidon := Vector2(46, 36)
	for seg in [[r1, pedalier], [pedalier, selle], [selle, r1], [pedalier, guidon + Vector2(-1, 6)], [selle + Vector2(2, 0), guidon + Vector2(-2, 6)], [guidon + Vector2(-1, 6), r2]]:
		var a0: Vector2 = seg[0]
		var a1: Vector2 = seg[1]
		for t in 40:
			var q := a0.lerp(a1, t / 39.0)
			M.rect(img, int(q.x), int(q.y), 2, 1, "rouge_auvent")
	M.rect(img, 22, 38, 9, 2, "nuit")
	M.rect(img, 44, 34, 6, 2, "nuit")
	# Cycliste (Jean-Mi) : jambes vers les pédales, buste penché, tête
	var cfg: Dictionary = PERSOS["jeanmi"]
	var veste: Array = cfg["veste"]
	var bas: Array = cfg["bas"]
	var ang_p := image * PI
	var pied1 := pedalier + Vector2(cos(ang_p), sin(ang_p)) * 6.0
	var pied2 := pedalier - Vector2(cos(ang_p), sin(ang_p)) * 6.0
	var hanche := selle + Vector2(0, -3)
	P._membre(img, hanche, (hanche + pied2) / 2.0 + Vector2(5, -3), 3.0, bas, true)
	P._membre(img, (hanche + pied2) / 2.0 + Vector2(5, -3), pied2, 2.6, bas, true)
	P._poly(img, PackedVector2Array([hanche + Vector2(-4, 2), hanche + Vector2(4, 2), Vector2(38, 18), Vector2(31, 14)]), veste[1])
	P._membre(img, Vector2(34, 18), guidon, 2.4, veste)
	P._membre(img, hanche, (hanche + pied1) / 2.0 + Vector2(5, -3), 3.2, bas)
	P._membre(img, (hanche + pied1) / 2.0 + Vector2(5, -3), pied1, 2.8, bas)
	M.rect(img, int(pied1.x) - 2, int(pied1.y), 7, 2, "bois")
	var tete := M.vide(36, 30)
	_tete(tete, 2, cfg)
	M.coller(img, tete, 19, -1)
	P.contour_teinte(img, _table(cfg))
	return img


## Panneau « À VENDRE » (posé dans la vitre de la Porsche) : carton blanc, lettres rouges.
static func panneau_vendre() -> Image:
	var img := M.vide(29, 15)
	M.rect(img, 0, 0, 29, 15, "blanc_chaud")
	M.cadre(img, 0, 0, 29, 15, "pierre_ombre")
	M.texte(img, 3, 1, "A", "rouge_auvent")
	M.texte(img, 9, 1, "VEN", "rouge_auvent")
	M.texte(img, 9, 8, "DRE", "rouge_auvent")
	M.px(img, 4, 0, "rouge_auvent")
	return img


## Enregistre les images d'un personnage (ville/<nom>_marche_1..4, _repos_1..2, + miroirs « miroir/… »).
static func enregistrer(nom: String) -> void:
	if GrillePixel.existe("miroir/%s_marche_1" % nom):
		return
	if nom == "jeanmi_velo":
		enregistrer_objets()
		return
	if nom == "gerard":
		if not GrillePixel.existe("ville/gerard_marche_1"):
			P.enregistrer()
		_miroirs("gerard", P.POSES.keys())
		return
	var cfg: Dictionary = PERSOS[nom]
	var poses: Array = P.POSES.keys()
	if nom == "lefranc":
		poses = poses + ["fume_1", "fume_2"]
	for pose in poses:
		GrillePixel.enregistrer("ville/%s_%s" % [nom, pose], figurine(cfg, pose), Vector2i(18, 62))
	_miroirs(nom, poses)


static func _miroirs(nom: String, poses: Array) -> void:
	for pose in poses:
		var n := "ville/%s_%s" % [nom, pose]
		if GrillePixel.existe("miroir/%s_%s" % [nom, pose]):
			continue
		var img := Image.new()
		img.copy_from(GrillePixel.image(n))
		img.flip_x()
		var o := GrillePixel.origine(n)
		GrillePixel.enregistrer("miroir/%s_%s" % [nom, pose], img, Vector2i(img.get_width() - 1 - o.x, o.y))


## Objets de la planche et des voisins : enfants, poussettes, vélo, panneau (« objet/… »).
static func enregistrer_objets() -> void:
	if GrillePixel.existe("objet/velo_1"):
		return
	for i in 2:
		GrillePixel.enregistrer("objet/enfant_a_%d" % (i + 1), enfant(["lumiere", "or", "orange", "caramel"], ["caramel", "bois", "bois_sombre"], i))
		GrillePixel.enregistrer("objet/enfant_b_%d" % (i + 1), enfant(["ciel", "bleu_vif", "bleu_ardoise", "bleu_nuit"], ["bois", "bois_sombre", "nuit"], i))
		var v := velo(i)
		GrillePixel.enregistrer("objet/velo_%d" % (i + 1), v)
		var mv := Image.new()
		mv.copy_from(v)
		mv.flip_x()
		GrillePixel.enregistrer("miroir/velo_%d" % (i + 1), mv)
	GrillePixel.enregistrer("objet/poussette", poussette(false))
	GrillePixel.enregistrer("objet/poussette_double", poussette(true))
	GrillePixel.enregistrer("objet/a_vendre", panneau_vendre(), Vector2i(14, 14))
