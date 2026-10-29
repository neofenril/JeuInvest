class_name MatieresPixel
extends RefCounted
## Générateurs de matières pixel de la rue de briques (docs/16 §2.4, §4.4 et §8, révision PX0 bis) :
## ciel d'été en bandes tramées (Bayer 4 × 4), cumulus en volumes, skyline lointaine bleutée, brique à
## joints (4 variantes), ardoise, tuiles, dalles du trottoir, goudron de la chaussée ; et les « pinceaux »
## (px, rect, cadre, coller, contour, recolorer, lointain, disque, texte) utilisés par facades.gd.
## Règles : uniquement des couleurs de PalettePixel (jour) ; images opaques ou transparentes (alpha 0
## ou 1) ; déterministes (même graine, même image : RandomNumberGenerator à graine fixe, jamais randi()).
## Les variantes nuit et orage sont obtenues par GrillePixel / PalettePixel.convertir.

## Matrice de Bayer 4 × 4 (seuils 0 à 15).
const BAYER := [
	[0, 8, 2, 10],
	[12, 4, 14, 6],
	[3, 11, 1, 9],
	[15, 7, 13, 5],
]

## Bandes du ciel de jour, du bas (horizon) vers le haut : [couleur, hauteur en px d'art]. La dernière
## bande remplit le reste. Rampe d'été de docs/16 §8.2 : ciel_haut → ciel_vif → ciel → ciel_clair
## (horizon posé au sol de la rue, y 296).
const BANDES_CIEL := [
	["ciel_clair", 60],
	["ciel", 64],
	["ciel_vif", 76],
	["ciel_haut", 0],
]
const TRAME_CIEL := 8          # hauteur des transitions tramées entre deux bandes
const DALLE := 12              # largeur d'une dalle du trottoir
const TIRET := 20              # tirets de la ligne médiane (20 peints, 14 vides)
const TIRET_VIDE := 14

## Briques : [corps, éclat, ombre, joint]. Rang de 3 px (2 de brique + 1 de joint), brique de 6 px
## (5 + 1 joint vertical), en quinconce.
const BRIQUES := {
	"vive": ["brique_vive", "brique_claire", "brique", "brique"],
	"classique": ["brique", "brique_vive", "brique_sombre", "brique_sombre"],
	"sombre": ["brique_sombre", "brique", "bois_sombre", "bois_sombre"],
	"claire": ["pierre", "pierre_claire", "pierre_ombre", "pierre_claire"],
}


static func _c(nom: String) -> Color:
	return PalettePixel.couleur(nom)


## Vrai si le seuil de Bayer en (x, y) est sous t (0 à 1) : sert à tramer une transition.
static func trame(x: int, y: int, t: float) -> bool:
	return float(BAYER[y & 3][x & 3]) + 0.5 < t * 16.0


# --- Ciel, nuages, lointain ------------------------------------------------------------------------

## Ciel en bandes : l'horizon est la dernière rangée de l'image. Les transitions entre bandes sont
## tramées sur TRAME_CIEL px. Le motif ne dépend que de (x mod 4) : l'image se répète en largeur.
static func ciel(largeur: int, hauteur: int, _graine := 0) -> Image:
	var img := Image.create_empty(largeur, hauteur, false, Image.FORMAT_RGBA8)
	var limites: Array = []   # [distance, couleur du dessous, couleur du dessus]
	var d := 0
	for i in BANDES_CIEL.size() - 1:
		d += int(BANDES_CIEL[i][1])
		limites.append([d, BANDES_CIEL[i][0], BANDES_CIEL[i + 1][0]])
	for y in hauteur:
		var dist := hauteur - 1 - y     # 0 = horizon
		var nom: String = BANDES_CIEL[BANDES_CIEL.size() - 1][0]
		var acc := 0
		for i in BANDES_CIEL.size() - 1:
			acc += int(BANDES_CIEL[i][1])
			if dist < acc:
				nom = BANDES_CIEL[i][0]
				break
		var c_base := _c(nom)
		var lim: Array = []
		for l in limites:
			if absi(dist - int(l[0])) <= TRAME_CIEL / 2:
				lim = l
				break
		for x in largeur:
			var c := c_base
			if not lim.is_empty():
				var t := (float(dist - int(lim[0])) + TRAME_CIEL / 2.0 + 0.5) / float(TRAME_CIEL + 1)
				c = _c(lim[2]) if trame(x, y, t) else _c(lim[1])
			img.set_pixel(x, y, c)
	return img


## Cumulus de largeur l × h : boules empilées sur une base plate, chacune éclairée en haut à gauche
## (nuage), volume (nuage_ombre), dessous (nuage_creux). Les petites boules du devant sont posées après
## les grosses : leur arête éclairée découpe l'ombre des grosses (effet « chou-fleur »).
static func cumulus(l: int, h: int, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := vide(l, h)
	var boules: Array = []   # [cx, cy, r]
	var n := maxi(4, l / 13)
	for i in n:
		var t := (i + 0.5) / float(n)
		var bombe := 1.0 - absf(t - 0.45) * 1.5
		var r := maxi(4, int(h * 0.42 * bombe) + rng.randi_range(-2, 2))
		var cx := int(l * (0.1 + 0.8 * t)) + rng.randi_range(-3, 3)
		var cy := h - 4 - int(r * 0.75) - rng.randi_range(0, 3)
		boules.append([cx, cy, r])
	# Petites boules du devant, plus bas
	for i in maxi(2, l / 30):
		var r := rng.randi_range(maxi(3, h / 7), maxi(4, h / 5))
		boules.append([rng.randi_range(r + 2, l - r - 3), h - 3 - r, r])
	boules.sort_custom(func(a, b): return a[2] > b[2])
	for b in boules:
		var cx: int = b[0]
		var cy: int = b[1]
		var r: int = b[2]
		for y in range(maxi(0, cy - r), mini(h, cy + r + 1)):
			for x in range(maxi(0, cx - r - 2), mini(l, cx + r + 3)):
				var dx := x - cx
				var dy := y - cy
				if dx * dx * 0.8 + dy * dy > r * r + r * 0.6:
					continue
				var q := (dx * 0.55 + dy) / float(r)
				var nom := "nuage" if q < 0.05 else ("nuage_ombre" if q < 0.7 else "nuage_creux")
				px(img, x, y, nom)
	# Base plate (dessous) : bande de nuage_creux, ourlée de nuage_ombre, bords arrondis
	var g := int(l * 0.07)
	var d := l - int(l * 0.08)
	for y in range(h - 4, h):
		var retrait := (y - (h - 4)) * 2
		for x in range(g + retrait, d - retrait):
			px(img, x, y, "nuage_creux" if y >= h - 2 else "nuage_ombre")
	return img


## Skyline lointaine (plan 0,15) de l × h : silhouettes plates sans fenêtre, en 3 plans (lointain_clair
## au fond : tours ; lointain : immeubles, grues, pylône ; lointain_sombre devant : toits bas, usine).
static func skyline(l: int, h: int, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := vide(l, h)
	# Fond : tours hautes et fines
	var x := rng.randi_range(0, 30)
	while x < l:
		var w := rng.randi_range(12, 30)
		var th := rng.randi_range(h / 3, h - 10)
		rect(img, x, h - th, w, th, "lointain_clair")
		if rng.randf() < 0.35:
			rect(img, x + w / 2, h - th - 10, 1, 10, "lointain_clair")      # antenne
		elif rng.randf() < 0.5:
			rect(img, x + 2, h - th - 4, w - 4, 4, "lointain_clair")         # édicule
		x += w + rng.randi_range(10, 60)
	# Milieu : immeubles, grues, pylône
	x = rng.randi_range(0, 20)
	var grues := 0
	var pylone := false
	while x < l:
		var w := rng.randi_range(22, 56)
		var bh := rng.randi_range(h / 5, h / 2)
		rect(img, x, h - bh, w, bh, "lointain")
		if rng.randf() < 0.3:
			for k in range(x + 2, x + w - 6, 8):                          # sheds en dents de scie
				for j in 4:
					rect(img, k, h - bh - j, 6 - j, 1, "lointain")
		x += w + rng.randi_range(4, 30)
		if grues < 2 and x > l * (0.2 + grues * 0.45) and x < l - 80:
			_grue(img, x + 10, h, rng.randi_range(h - 30, h - 6), rng.randi() % 2 == 0)
			grues += 1
			x += 30
		elif not pylone and x > l * 0.55 and x < l - 40:
			_pylone(img, x + 8, h, h * 2 / 3)
			pylone = true
			x += 30
	# Devant : bâtiments bas, cheminée d'usine
	x = rng.randi_range(0, 40)
	while x < l:
		var w := rng.randi_range(30, 80)
		var bh := rng.randi_range(10, h / 4)
		rect(img, x, h - bh, w, bh, "lointain_sombre")
		if rng.randf() < 0.25:
			rect(img, x + w - 8, h - bh - 30, 4, 30, "lointain_sombre")
			rect(img, x + w - 9, h - bh - 31, 6, 2, "lointain_sombre")
		x += w + rng.randi_range(0, 50)
	return img


## Grue à tour : mât en treillis 3 px, flèche et contre-flèche, câble et crochet (couleur lointain).
static func _grue(img: Image, x: int, bas: int, haut: int, vers_gauche: bool) -> void:
	var y0 := bas - haut
	rect(img, x, y0, 1, haut, "lointain")
	rect(img, x + 2, y0, 1, haut, "lointain")
	for y in range(y0, bas, 4):
		px(img, x + 1, y, "lointain")
		px(img, x + 1, y + 2, "lointain")
	var s := -1 if vers_gauche else 1
	var fleche := 56
	for i in fleche:
		px(img, x + 1 + s * i, y0, "lointain")
		if i % 4 == 0:
			px(img, x + 1 + s * i, y0 + 1, "lointain")
	rect(img, x + 1 + s * fleche - (1 if s < 0 else 0), y0 + 1, 1, 1, "lointain")
	for i in 16:
		px(img, x + 1 - s * i, y0, "lointain")
	rect(img, x + 1 - s * 15 - (2 if s > 0 else 0), y0 + 1, 3, 3, "lointain")     # contrepoids
	rect(img, x - 1, y0 - 5, 5, 5, "lointain")                                   # cabine et pointe
	var cx := x + 1 + s * 38
	rect(img, cx, y0 + 1, 1, 18, "lointain")
	rect(img, cx - 1, y0 + 19, 3, 2, "lointain")


## Pylône électrique : treillis qui s'affine, deux consoles.
static func _pylone(img: Image, x: int, bas: int, haut: int) -> void:
	for j in haut:
		var e := 1 + j * 7 / haut
		var y := bas - 1 - j
		px(img, x - e, y, "lointain")
		px(img, x + e, y, "lointain")
		if j % 6 == 0:
			rect(img, x - e, y, 2 * e + 1, 1, "lointain")
		elif (j % 6) < 3:
			px(img, x - e + (j % 6) * e / 2, y, "lointain")
	var y0 := bas - haut
	rect(img, x - 9, y0 + 6, 19, 1, "lointain")
	rect(img, x - 7, y0 + 14, 15, 1, "lointain")
	rect(img, x, y0 - 3, 1, 3, "lointain")


# --- Sol -------------------------------------------------------------------------------------------

## Trottoir de dalles (12 px) suivi de la bordure (2 px) : joints dalle_ombre tous les 12 px, en
## quinconce sur deux rangs, quelques dalles tachées ; bordure : arête éclairée puis face.
static func trottoir(largeur: int, hauteur := 14, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := Image.create_empty(largeur, hauteur, false, Image.FORMAT_RGBA8)
	var corps := hauteur - 2
	var milieu := corps / 2
	var taches := {}
	for i in largeur / 40:
		taches[Vector2i(rng.randi_range(0, largeur / DALLE), rng.randi_range(0, 1))] = true
	for y in hauteur:
		for x in largeur:
			var nom := "dalle"
			if y < corps:
				var rang := 0 if y < milieu else 1
				var xx := x + (DALLE / 2 if rang == 1 else 0)
				if y == milieu - 1 or y == corps - 1:
					nom = "dalle_ombre"
				elif xx % DALLE == 0:
					nom = "dalle_ombre"
				elif taches.has(Vector2i(xx / DALLE, rang)) and trame(x, y, 0.3):
					nom = "dalle_ombre"
			elif y == corps:
				nom = "zinc_clair"
			else:
				nom = "goudron" if (x % 24) == 0 else "goudron_clair"
			img.set_pixel(x, y, _c(nom))
	return img


## Chaussée de goudron (22 px) : ombre du caniveau, grain clair tramé, reprises d'enrobé, ligne médiane
## en tirets blanc_chaud (le passage piéton est posé par la rue).
static func chaussee(largeur: int, hauteur := 22, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := Image.create_empty(largeur, hauteur, false, Image.FORMAT_RGBA8)
	var goudron := _c("goudron")
	var clair := _c("goudron_clair")
	for y in hauteur:
		for x in largeur:
			var c := goudron
			if y <= 1:
				c = _c("ardoise_sombre") if y == 0 else _c("ardoise")
			elif trame(x + y * 3, y, 0.06):
				c = clair
			img.set_pixel(x, y, c)
	var n := maxi(1, largeur / 140)
	for i in n:
		var l := rng.randi_range(14, 34)
		var hh := rng.randi_range(2, 3)
		var x0 := rng.randi_range(0, maxi(0, largeur - l))
		var y0 := rng.randi_range(4, hauteur - hh - 2)
		img.fill_rect(Rect2i(x0, y0, l, hh), clair if i % 2 == 0 else _c("ardoise"))
	var ym := hauteur / 2
	for x in largeur:
		if x % (TIRET + TIRET_VIDE) < TIRET:
			img.set_pixel(x, ym, _c("blanc_chaud"))
			img.set_pixel(x, ym + 1, _c("blanc_chaud"))
	return img


## Bord d'en face (sous la chaussée) : bordure puis dalles, h px.
static func bord_en_face(largeur: int, hauteur := 8) -> Image:
	var img := Image.create_empty(largeur, hauteur, false, Image.FORMAT_RGBA8)
	for y in hauteur:
		for x in largeur:
			var nom := "dalle"
			if y == 0:
				nom = "goudron_clair"
			elif y == 1:
				nom = "zinc_clair"
			elif (x + 6) % DALLE == 0 or y == 5:
				nom = "dalle_ombre"
			img.set_pixel(x, y, _c(nom))
	return img


## Rectangle uni d'une couleur de la palette (fonds, remplissages).
static func uni(largeur: int, hauteur: int, nom: String) -> Image:
	var img := Image.create_empty(largeur, hauteur, false, Image.FORMAT_RGBA8)
	img.fill(_c(nom))
	return img


# --- Pinceaux (dessin au pixel sur une Image, couleurs de la palette) --------------------------------

## Image transparente.
static func vide(largeur: int, hauteur: int) -> Image:
	var img := Image.create_empty(maxi(1, largeur), maxi(1, hauteur), false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	return img


static func px(img: Image, x: int, y: int, nom: String) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, _c(nom))


static func rect(img: Image, x: int, y: int, l: int, h: int, nom: String) -> void:
	var r := Rect2i(x, y, l, h).intersection(Rect2i(0, 0, img.get_width(), img.get_height()))
	if r.size.x > 0 and r.size.y > 0:
		img.fill_rect(r, _c(nom))


## Cadre de 1 px.
static func cadre(img: Image, x: int, y: int, l: int, h: int, nom: String) -> void:
	rect(img, x, y, l, 1, nom)
	rect(img, x, y + h - 1, l, 1, nom)
	rect(img, x, y, 1, h, nom)
	rect(img, x + l - 1, y, 1, h, nom)


## Copie les pixels opaques de src en (x, y).
static func coller(img: Image, src: Image, x: int, y: int) -> void:
	img.blend_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), Vector2i(x, y))


## Contour intérieur : chaque pixel opaque qui touche (4 voisins) un pixel transparent ou le bord
## prend la couleur nom (bas = false : le bord inférieur n'est pas tracé).
static func contour(img: Image, nom: String, bas := true) -> void:
	var src := Image.new()
	src.copy_from(img)
	var l := img.get_width()
	var h := img.get_height()
	var c := _c(nom)
	for y in h:
		for x in l:
			if src.get_pixel(x, y).a == 0.0:
				continue
			var bord := false
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var q: Vector2i = Vector2i(x, y) + d
				if d.y == 1 and not bas and q.y >= h:
					continue
				if q.x < 0 or q.y < 0 or q.x >= l or q.y >= h or src.get_pixel(q.x, q.y).a == 0.0:
					bord = true
					break
			if bord:
				img.set_pixel(x, y, c)


## Remplace des couleurs de la palette par d'autres (recoloration d'un motif).
static func recolorer(img: Image, table: Dictionary) -> Image:
	var copie := Image.new()
	copie.copy_from(img)
	var cles := {}
	for de in table:
		cles[PalettePixel.cle(_c(de))] = _c(table[de])
	for y in copie.get_height():
		for x in copie.get_width():
			var c := copie.get_pixel(x, y)
			if c.a > 0.0:
				var k := PalettePixel.cle(c)
				if cles.has(k):
					copie.set_pixel(x, y, cles[k])
	return copie


## Plan intermédiaire (0,4) : ramène chaque couleur à 3 tons bleutés selon sa luminance
## (perspective atmosphérique : lointain_sombre, lointain, lointain_clair).
static func lointain(img: Image) -> Image:
	var copie := Image.new()
	copie.copy_from(img)
	var sombre := _c("lointain_sombre")
	var moyen := _c("lointain")
	var clair := _c("lointain_clair")
	for y in copie.get_height():
		for x in copie.get_width():
			var c := copie.get_pixel(x, y)
			if c.a == 0.0:
				continue
			var lum := 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
			copie.set_pixel(x, y, sombre if lum < 0.2 else (moyen if lum < 0.5 else clair))
	return copie


## Disque plein pixellisé (halos de lumière) de rayon r, couleur nom.
static func disque(r: int, nom: String) -> Image:
	var img := vide(2 * r + 1, 2 * r + 1)
	for y in 2 * r + 1:
		for x in 2 * r + 1:
			var dx := x - r
			var dy := y - r
			if dx * dx + dy * dy <= r * r + r:
				px(img, x, y, nom)
	return img


## Lettres capitales 3 × 5 (enseignes peintes). Inconnue : espace.
const GLYPHES := {
	"A": ["010", "101", "111", "101", "101"], "B": ["110", "101", "110", "101", "110"],
	"C": ["011", "100", "100", "100", "011"], "D": ["110", "101", "101", "101", "110"],
	"E": ["111", "100", "110", "100", "111"], "F": ["111", "100", "110", "100", "100"],
	"G": ["011", "100", "101", "101", "011"], "H": ["101", "101", "111", "101", "101"],
	"I": ["111", "010", "010", "010", "111"], "L": ["100", "100", "100", "100", "111"],
	"N": ["101", "111", "111", "101", "101"], "O": ["010", "101", "101", "101", "010"],
	"P": ["110", "101", "110", "100", "100"], "R": ["110", "101", "110", "101", "101"],
	"S": ["011", "100", "010", "001", "110"], "T": ["111", "010", "010", "010", "010"],
	"U": ["101", "101", "101", "101", "111"], "V": ["101", "101", "101", "101", "010"],
	"É": ["010", "111", "110", "100", "111"], "Z": ["111", "001", "010", "100", "111"],
	"M": ["101", "111", "111", "101", "101"],
}


## Écrit un texte en capitales 3 × 5 (espacement 1), renvoie la largeur écrite.
static func texte(img: Image, x: int, y: int, t: String, nom: String, echelle := 1) -> int:
	var cx := x
	for ch in t:
		var g: Array = GLYPHES.get(ch, [])
		if not g.is_empty():
			for j in 5:
				for i in 3:
					if String(g[j])[i] == "1":
						rect(img, cx + i * echelle, y + j * echelle, echelle, echelle, nom)
		cx += 4 * echelle
	return cx - x - echelle


static func largeur_texte(t: String, echelle := 1) -> int:
	return t.length() * 4 * echelle - echelle


# --- Matières de construction --------------------------------------------------------------------

## Brique à joints visibles (docs/16 §8.2) : rangs de 3 px (2 de brique + 1 de joint), briques de 6 px
## en quinconce, quelques briques éclairées ou sombres. Variantes : vive, classique, sombre, claire.
static func brique(largeur: int, hauteur: int, graine := 0, variante := "classique") -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var t: Array = BRIQUES.get(variante, BRIQUES["classique"])
	var corps := _c(t[0])
	var eclat := _c(t[1])
	var ombre := _c(t[2])
	var joint := _c(t[3])
	var img := Image.create_empty(maxi(1, largeur), maxi(1, hauteur), false, Image.FORMAT_RGBA8)
	var marquees := {}
	for i in largeur * hauteur / 30:
		marquees[Vector2i(rng.randi_range(0, largeur / 6 + 1), rng.randi_range(0, hauteur / 3 + 1))] = 1 if rng.randf() < 0.6 else 2
	for y in hauteur:
		var r := y / 3
		var dec := 3 if r % 2 == 1 else 0
		for x in largeur:
			var c := corps
			if y % 3 == 2 or (x + dec) % 6 == 5:
				c = joint
			else:
				var m: int = marquees.get(Vector2i((x + dec) / 6, r), 0)
				if m == 1:
					c = eclat
				elif m == 2:
					c = ombre
			img.set_pixel(x, y, c)
	return img


## Ardoise de toit (rampe ardoise / ardoise_sombre / nuit) : rangs de 4 px, ardoises de 6 px décalées,
## bord bas de chaque rang éclairé, ombre du rang du dessus.
static func ardoise(largeur: int, hauteur: int, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := vide(largeur, hauteur)
	var claires := {}
	for i in largeur * hauteur / 50:
		claires[Vector2i(rng.randi_range(0, largeur / 6 + 1), rng.randi_range(0, hauteur / 4 + 1))] = true
	for y in hauteur:
		var r := y / 4
		var dec := 3 if r % 2 == 1 else 0
		for x in largeur:
			var nom := "ardoise_sombre"
			var yy := y % 4
			if yy == 0:
				nom = "nuit"
			elif (x + dec) % 6 == 0:
				nom = "nuit"
			elif yy == 3 or claires.has(Vector2i((x + dec) / 6, r)):
				nom = "ardoise"
			px(img, x, y, nom)
	return img


## Tuiles mécaniques rouges (rampe terre_cuite_claire / tuile / brique) : rangs de 4 px, côtes tous
## les 6 px, lèvre claire en haut, ombre du rang du dessus en bas ; quelques tuiles plus sombres.
static func tuiles(largeur: int, hauteur: int, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := vide(largeur, hauteur)
	var sombres := {}
	for r in hauteur / 4 + 1:
		for t in largeur / 6 + 2:
			if rng.randf() < 0.1:
				sombres[Vector2i(r, t)] = true
	for y in hauteur:
		var r := y / 4
		var yy := y % 4
		var dec := 3 if r % 2 == 1 else 0
		for x in largeur:
			var xm := (x + dec) % 6
			var sombre := sombres.has(Vector2i(r, (x + dec) / 6))
			var nom := "brique" if sombre else "tuile"
			if yy == 3:
				nom = "brique_sombre" if xm == 0 else "brique"
			elif xm == 0:
				nom = "brique"
			elif yy == 0 or xm == 1:
				nom = "tuile" if sombre else "terre_cuite_claire"
			px(img, x, y, nom)
	return img


## Génère et enregistre dans GrillePixel les matières standard de la rue (noms « matiere/… »).
## Renvoie les noms enregistrés.
static func generer_tout(graine := 1) -> PackedStringArray:
	GrillePixel.enregistrer("matiere/ciel", ciel(64, 480, graine), Vector2i(0, 479))
	GrillePixel.enregistrer("matiere/trottoir", trottoir(1280, 14, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/chaussee", chaussee(1280, 22, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/bord_en_face", bord_en_face(1280, 8), Vector2i.ZERO)
	for v in BRIQUES:
		GrillePixel.enregistrer("matiere/brique_" + v, brique(48, 30, graine, v), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/ardoise", ardoise(48, 32, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/tuiles", tuiles(48, 32, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/skyline", skyline(1600, 200, graine + 83), Vector2i(0, 199))
	for i in 3:
		var t: Array = [[150, 56], [112, 44], [80, 32]][i]
		GrillePixel.enregistrer("matiere/cumulus_%d" % (i + 1), cumulus(t[0], t[1], graine * 10 + i), Vector2i.ZERO)
	var noms := PackedStringArray()
	for n in GrillePixel.noms():
		if n.begins_with("matiere/"):
			noms.append(n)
	return noms
