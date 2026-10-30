extends RefCounted
## Personnages de la rue, PX0 quater (grille fine 960 × 540) : générés en code, dans la palette, pour garder
## à l'écran la taille de PX0 ter avec 1,5 × plus de pixels (visage, mains, plis). Pas de class_name (preload).
## Gérard 36 × 63 (profil vers la droite, marche 4 images, repos 2), Sylvie 27 × 32 (buste de face, 3 humeurs
## + clignement). Lumière en haut à gauche ; 3 tons par matière ; contour « teinté » : le ton le plus sombre de
## la matière voisine (jamais de noir pur), encre seulement pour les pupilles.

const M := preload("res://scripts/pixel/matieres.gd")

const GERARD := Vector2i(36, 63)
const SYLVIE := Vector2i(27, 32)

## Matières : [éclairé, moyen, ombre, contour].
const VESTE := ["ciel", "bleu_vif", "bleu_ardoise", "bleu_nuit"]
const PANTALON := ["gris_pierre", "ardoise", "ardoise_sombre", "nuit"]
const PEAU := ["peau_claire", "peau_claire", "peau_ombre", "caramel"]
const CHEVEUX := ["caramel", "bois", "bois_sombre", "bois_sombre"]
const CHAUSSURE := ["bois", "bois_sombre", "bois_sombre", "encre"]
const PULL := ["lumiere", "or", "orange", "caramel"]
const CHEVEUX_S := ["caramel", "bois", "bois_sombre", "bois_sombre"]


# --- Pinceaux de volume --------------------------------------------------------------------------------

## Ellipse pleine ombrée (lumière en haut à gauche) : t = matière [clair, moyen, ombre, contour].
static func _ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, t: Array, decal := 0.0) -> void:
	for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
		for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
			var dx := (x + 0.5 - cx) / rx
			var dy := (y + 0.5 - cy) / ry
			if dx * dx + dy * dy > 1.0:
				continue
			var l := -(dx * 0.7 + dy * 0.7) + decal
			M.px(img, x, y, t[0] if l > 0.45 else (t[1] if l > -0.35 else t[2]))


## Membre (capsule de p0 à p1, rayon r), ombré selon le côté de l'axe (gauche éclairé).
static func _membre(img: Image, p0: Vector2, p1: Vector2, r: float, t: Array, sombre := false) -> void:
	var d := p1 - p0
	var lg := maxf(d.length(), 0.01)
	var n := Vector2(-d.y, d.x) / lg
	if n.x > 0.0:
		n = -n                                       # n pointe vers la gauche (côté éclairé)
	var mn := Vector2(minf(p0.x, p1.x) - r - 1, minf(p0.y, p1.y) - r - 1)
	var mx := Vector2(maxf(p0.x, p1.x) + r + 1, maxf(p0.y, p1.y) + r + 1)
	for y in range(int(mn.y), int(mx.y) + 1):
		for x in range(int(mn.x), int(mx.x) + 1):
			var p := Vector2(x + 0.5, y + 0.5)
			var tt := clampf((p - p0).dot(d) / (lg * lg), 0.0, 1.0)
			var q := p0 + d * tt
			var e := p - q
			if e.length() > r:
				continue
			var cote := e.dot(n) / r                   # 1 = bord éclairé, -1 = bord à l'ombre
			var nom: String = t[0] if cote > 0.35 else (t[1] if cote > -0.4 else t[2])
			if sombre:
				nom = t[1] if cote > 0.35 else t[2]
			M.px(img, x, y, nom)


static func _poly(img: Image, pts: PackedVector2Array, nom: String) -> void:
	var r := Rect2(pts[0], Vector2.ZERO)
	for p in pts:
		r = r.expand(p)
	for y in range(int(r.position.y) - 1, int(r.end.y) + 2):
		for x in range(int(r.position.x) - 1, int(r.end.x) + 2):
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), pts):
				M.px(img, x, y, nom)


## Contour teinté : chaque pixel transparent qui touche (4 voisins) un pixel opaque prend le ton de contour
## de la matière de ce pixel (table ton -> contour) ; les coins (diagonales seules) prennent l'ombre de la
## matière : anti-crénelage dans la palette.
static func contour_teinte(img: Image, table: Dictionary) -> void:
	var src := Image.new()
	src.copy_from(img)
	var l := img.get_width()
	var h := img.get_height()
	for y in h:
		for x in l:
			if src.get_pixel(x, y).a > 0.0:
				continue
			var trouve := ""
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var q: Vector2i = Vector2i(x, y) + d
				if q.x >= 0 and q.y >= 0 and q.x < l and q.y < h and src.get_pixel(q.x, q.y).a > 0.0:
					trouve = PalettePixel.nom_de(src.get_pixel(q.x, q.y))
					break
			if trouve != "":
				M.px(img, x, y, table.get(trouve, "encre"))


static func _table_contours() -> Dictionary:
	var t := {}
	for m in [VESTE, PANTALON, PEAU, CHEVEUX, CHAUSSURE, PULL]:
		for i in 3:
			t[m[i]] = m[3]
	t["blanc_chaud"] = "pierre_ombre"
	t["or"] = "orange"
	t["encre"] = "encre"
	t["brique_sombre"] = "caramel"
	return t


# --- Gérard ----------------------------------------------------------------------------------------------

## Pose : [genou proche, cheville proche, genou loin, cheville loin, coude proche, main proche, coude loin,
## main loin, abaissement du corps]. Origine du sprite (18, 62) au milieu des pieds.
const POSES := {
	"marche_1": [Vector2(22, 49), Vector2(25, 58), Vector2(15, 49), Vector2(11, 57), Vector2(15, 33), Vector2(12, 39), Vector2(21, 33), Vector2(24, 38), 1],
	"marche_2": [Vector2(19, 50), Vector2(18, 59), Vector2(18, 49), Vector2(15, 56), Vector2(18, 34), Vector2(18, 40), Vector2(18, 34), Vector2(19, 40), 0],
	"marche_3": [Vector2(15, 49), Vector2(11, 57), Vector2(22, 49), Vector2(25, 58), Vector2(21, 33), Vector2(24, 38), Vector2(15, 33), Vector2(12, 39), 1],
	"marche_4": [Vector2(18, 49), Vector2(15, 56), Vector2(19, 50), Vector2(18, 59), Vector2(19, 34), Vector2(20, 40), Vector2(17, 34), Vector2(16, 40), 0],
	"repos_1": [Vector2(19, 50), Vector2(19, 59), Vector2(17, 50), Vector2(16, 59), Vector2(17, 34), Vector2(16, 41), Vector2(19, 34), Vector2(20, 41), 0],
	"repos_2": [Vector2(19, 50), Vector2(19, 59), Vector2(17, 50), Vector2(16, 59), Vector2(17, 34), Vector2(16, 41), Vector2(19, 34), Vector2(20, 41), 0],
}


static func gerard(pose: String) -> Image:
	var p: Array = POSES[pose]
	var img := M.vide(GERARD.x, GERARD.y)
	var b: int = p[8]
	var tete := 1 if pose == "repos_2" else 0
	var hanche := Vector2(18, 39 + b)
	var epaule := Vector2(17.5, 26 + b)
	# Jambe et bras du fond (plus sombres)
	_jambe(img, hanche + Vector2(-1, 0), p[2] + Vector2(0, b * 0.5), p[3], true)
	_membre(img, epaule + Vector2(1, 1), p[6] + Vector2(0, b), 2.6, VESTE, true)
	_membre(img, p[6] + Vector2(0, b), p[7] + Vector2(0, b), 2.2, VESTE, true)
	_main(img, p[7] + Vector2(0, b), true)
	# Buste : blouson de travail (épaules arrondies, taille resserrée), col blanc, ceinture
	var buste := PackedVector2Array([Vector2(11, 25 + b), Vector2(24, 25 + b), Vector2(26, 29 + b), Vector2(25, 40 + b),
		Vector2(12, 40 + b), Vector2(10, 29 + b)])
	_poly(img, buste, VESTE[1])
	for y in range(25 + b, 41 + b):
		for x in range(9, 27):
			if img.get_pixel(x, y).a > 0.0 and PalettePixel.nom_de(img.get_pixel(x, y)) == VESTE[1]:
				if x <= 12 or (x <= 14 and y < 30 + b):
					M.px(img, x, y, VESTE[0])
				elif x >= 23:
					M.px(img, x, y, VESTE[2])
	M.rect(img, 12, 37 + b, 13, 1, VESTE[2])                          # bas du blouson
	M.rect(img, 12, 39 + b, 13, 2, "bois_sombre")                     # ceinture
	M.rect(img, 22, 39 + b, 2, 2, "or")
	# Jambe proche
	_jambe(img, hanche + Vector2(1, 0), p[0] + Vector2(0, b * 0.5), p[1], false)
	# Tête (au-dessus du col) et cou
	_tete_gerard(img, tete + b)
	M.rect(img, 19, 23 + b, 4, 2, "blanc_chaud")                      # col
	M.px(img, 22, 25 + b, "zinc_clair")
	# Bras proche (par-dessus le blouson) : manche, poignet, main
	_membre(img, epaule, p[4] + Vector2(0, b), 2.8, VESTE)
	_membre(img, p[4] + Vector2(0, b), p[5] + Vector2(0, b), 2.4, VESTE)
	var poignet: Vector2 = p[5] + Vector2(0, b)
	M.px(img, int(poignet.x), int(poignet.y) - 1, VESTE[2])
	_main(img, poignet, false)
	contour_teinte(img, _table_contours())
	# Pli du coude proche (ligne d'ombre) pour détacher le bras du blouson
	var c: Vector2 = p[4] + Vector2(0, b)
	M.px(img, int(c.x) + 2, int(c.y), VESTE[3])
	M.px(img, int(c.x) + 2, int(c.y) + 1, VESTE[2])
	return img


static func _jambe(img: Image, hanche: Vector2, genou: Vector2, cheville: Vector2, fond: bool) -> void:
	_membre(img, hanche, genou, 3.4, PANTALON, fond)
	_membre(img, genou, cheville, 3.0, PANTALON, fond)
	# Chaussure (vers la droite), semelle
	var x := int(cheville.x) - 3
	var y := int(cheville.y)
	M.rect(img, x, y, 9, 3, CHAUSSURE[1])
	M.rect(img, x + 6, y + 1, 4, 2, CHAUSSURE[1])
	M.rect(img, x + 1, y, 4, 1, CHAUSSURE[0] if not fond else CHAUSSURE[1])
	M.rect(img, x, y + 3, 10, 1, "encre" if not fond else "bois_sombre")


static func _main(img: Image, p: Vector2, fond: bool) -> void:
	var x := int(p.x)
	var y := int(p.y)
	var t := PEAU if not fond else ["peau_ombre", "peau_ombre", "caramel", "caramel"]
	M.rect(img, x - 1, y, 3, 3, t[1])
	M.px(img, x - 1, y, t[0])
	M.rect(img, x, y + 3, 2, 1, t[2])
	M.px(img, x + 1, y + 1, t[2])


static func _tete_gerard(img: Image, dy: int) -> void:
	var y0 := dy
	# Cou
	M.rect(img, 16, 19 + y0, 6, 5, "peau_ombre")
	M.rect(img, 16, 19 + y0, 2, 5, "peau_claire")
	# Crâne et visage
	_ellipse(img, 18.5, 11.5 + y0, 9.0, 10.0, PEAU, 0.6)
	_ellipse(img, 22.0, 16.0 + y0, 5.5, 4.5, PEAU, 0.4)                # mâchoire
	# Nez (en saillie), narine
	for q in [Vector2i(27, 10), Vector2i(27, 11), Vector2i(28, 11), Vector2i(28, 12), Vector2i(27, 12), Vector2i(28, 13), Vector2i(27, 13)]:
		M.px(img, q.x, q.y + y0, "peau_claire")
	M.px(img, 27, 14 + y0, "peau_ombre")
	M.px(img, 28, 13 + y0, "peau_ombre")
	# Ombre de la joue et de la mâchoire
	for q in [Vector2i(20, 18), Vector2i(21, 19), Vector2i(22, 20), Vector2i(23, 20), Vector2i(24, 19)]:
		M.px(img, q.x, q.y + y0, "peau_ombre")
	# Cheveux : calotte, frange courte, nuque, favori ; reflet en haut à gauche
	for y in range(0, 18):
		for x in range(8, 29):
			var dx := (x + 0.5 - 17.5) / 10.5
			var dyy := (y + 0.5 - 9.5) / 9.5
			if dx * dx + dyy * dyy > 1.0:
				continue
			var garde := y < 6 or (x < 14 and y < 17) or (x < 21 and y < 8 - maxi(0, x - 17)) or (x < 16 and y < 12)
			if not garde:
				continue
			var nom := "bois"
			if dx < -0.15 and dyy < -0.3:
				nom = "caramel"
			elif dx > 0.45 or dyy > 0.45 or (x < 11 and y > 9):
				nom = "bois_sombre"
			M.px(img, x, y + y0, nom)
	M.rect(img, 22, 5 + y0, 5, 1, "bois_sombre")                     # bord de la frange	M.rect(img, 12, 2 + y0, 4, 1, "terre_cuite_claire")              # reflet
	# Oreille
	_ellipse(img, 14.0, 12.5 + y0, 1.8, 2.8, ["peau_claire", "peau_ombre", "caramel", "caramel"])
	M.px(img, 14, 12 + y0, "caramel")
	# Sourcil, œil (blanc + pupille), paupière
	M.rect(img, 22, 7 + y0, 4, 1, "bois_sombre")
	M.px(img, 21, 8 + y0, "bois_sombre")
	M.rect(img, 23, 9 + y0, 1, 2, "blanc_chaud")
	M.rect(img, 24, 9 + y0, 1, 2, "encre")
	M.px(img, 25, 9 + y0, "peau_ombre")
	M.px(img, 23, 8 + y0, "peau_ombre")
	# Bouche et lèvre inférieure
	M.rect(img, 23, 16 + y0, 3, 1, "brique_sombre")
	M.px(img, 26, 15 + y0, "peau_ombre")
	M.px(img, 24, 17 + y0, "tuile")
	# Pommette éclairée
	M.px(img, 24, 13 + y0, "blanc_chaud")


# --- Sylvie à la fenêtre ------------------------------------------------------------------------------------

## Buste de face 27 × 32, accoudée : humeur 0 contente, 1 neutre, 2 contrariée.
static func sylvie(humeur: int) -> Image:
	var img := M.vide(SYLVIE.x, SYLVIE.y)
	# Cheveux longs (derrière)
	_ellipse(img, 13.0, 10.5, 10.5, 10.5, CHEVEUX_S, 0.2)
	M.rect(img, 3, 10, 5, 13, "bois")
	M.rect(img, 19, 10, 5, 13, "bois_sombre")
	M.rect(img, 3, 10, 2, 12, "caramel")
	# Pull jaune moutarde, épaules, bras croisés sur l'appui
	_ellipse(img, 13.0, 29.0, 13.0, 8.0, PULL, 0.3)
	M.rect(img, 0, 27, 27, 5, "or")
	M.rect(img, 1, 28, 25, 1, "orange")
	M.rect(img, 3, 29, 9, 2, "lumiere")
	M.rect(img, 15, 29, 9, 2, "or")
	M.rect(img, 11, 28, 5, 3, "peau_claire")                           # mains jointes
	M.rect(img, 11, 30, 5, 1, "peau_ombre")
	M.px(img, 13, 29, "peau_ombre")
	# Cou et visage
	M.rect(img, 11, 19, 5, 5, "peau_ombre")
	M.rect(img, 11, 19, 2, 5, "peau_claire")
	_ellipse(img, 13.5, 12.0, 7.0, 8.5, PEAU, 0.5)
	M.rect(img, 11, 23, 5, 1, "or")                                    # encolure
	# Frange
	for x in range(6, 21):
		var hh := 4 + int(absf(x - 13.5) / 3.0)
		M.rect(img, x, 3, 1, hh, "bois" if x < 15 else "bois_sombre")
	M.rect(img, 7, 3, 4, 1, "caramel")
	# Yeux (2 × 2 : blanc + pupille), joues
	var ye := 11
	for ex in [9, 15]:
		M.rect(img, ex, ye, 1, 2, "blanc_chaud")
		M.rect(img, ex + 1, ye, 2, 2, "encre")
		M.px(img, ex + 2, ye, "bleu_ardoise")
	# Nez
	M.px(img, 13, 14, "peau_ombre")
	M.px(img, 14, 15, "peau_ombre")
	match humeur:
		0:      # contente : sourcils hauts arqués, grand sourire, joues roses
			for q in [Vector2i(9, 9), Vector2i(10, 8), Vector2i(11, 8), Vector2i(12, 9), Vector2i(15, 9), Vector2i(16, 8), Vector2i(17, 8), Vector2i(18, 9)]:
				M.px(img, q.x, q.y, "bois_sombre")
			M.rect(img, 8, 14, 2, 1, "tuile")
			M.rect(img, 17, 14, 2, 1, "tuile")
			M.px(img, 10, 16, "brique_sombre")
			M.px(img, 17, 16, "brique_sombre")
			M.rect(img, 11, 17, 6, 1, "brique_sombre")
			M.rect(img, 12, 18, 4, 1, "tuile")
		1:      # neutre : sourcils droits, bouche droite
			M.rect(img, 9, 9, 4, 1, "bois_sombre")
			M.rect(img, 15, 9, 4, 1, "bois_sombre")
			M.rect(img, 11, 17, 5, 1, "brique_sombre")
		2:      # contrariée : sourcils froncés vers le nez, yeux plissés, bouche en arc tombant, ride
			for q in [Vector2i(9, 8), Vector2i(10, 9), Vector2i(11, 9), Vector2i(12, 10), Vector2i(18, 8), Vector2i(17, 9), Vector2i(16, 9), Vector2i(15, 10)]:
				M.px(img, q.x, q.y, "bois_sombre")
			M.rect(img, 9, 11, 4, 1, "peau_ombre")
			M.rect(img, 15, 11, 4, 1, "peau_ombre")
			M.px(img, 13, 9, "peau_ombre")
			M.px(img, 14, 9, "peau_ombre")
			M.rect(img, 11, 16, 5, 1, "brique_sombre")
			M.px(img, 10, 17, "brique_sombre")
			M.px(img, 16, 17, "brique_sombre")
	contour_teinte(img, _table_contours())
	return img


## Calque de clignement (paupières fermées), même taille que Sylvie.
static func sylvie_cligne() -> Image:
	var img := M.vide(SYLVIE.x, SYLVIE.y)
	for ex in [9, 15]:
		M.rect(img, ex, 11, 3, 1, "peau_claire")
		M.rect(img, ex, 12, 3, 1, "bois_sombre")
	return img


## Enregistre les images dans le catalogue (noms « ville/… » comme les anciennes grilles).
static func enregistrer() -> void:
	for pose in POSES:
		GrillePixel.enregistrer("ville/gerard_" + pose, gerard(pose), Vector2i(18, 62))
	var noms := ["sylvie_contente", "sylvie_neutre", "sylvie_contrariee"]
	for h in 3:
		GrillePixel.enregistrer("ville/" + noms[h], sylvie(h), Vector2i(13, 31))
	GrillePixel.enregistrer("ville/sylvie_cligne", sylvie_cligne(), Vector2i(13, 31))
