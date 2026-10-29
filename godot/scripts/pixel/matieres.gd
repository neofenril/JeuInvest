class_name MatieresPixel
extends RefCounted
## Générateurs de matières pixel (docs/16 §2.3, §2.4, §4.4) : ciel en bandes tramé (Bayer 4 × 4),
## trottoir, chaussée, meulière, tuiles, pierre de taille, brique, ardoise, zinc, nuages ; et les
## « pinceaux » (px, rect, cadre, coller, contour, recolorer, palir, disque) utilisés par facades.gd.
## Règles : uniquement des couleurs de PalettePixel (jour) ; images opaques ou transparentes
## (alpha 0 ou 1) ; déterministes (même graine, même image : RandomNumberGenerator à graine fixe,
## jamais randi()). Les variantes nuit et orage sont obtenues par GrillePixel / PalettePixel.convertir.

## Matrice de Bayer 4 × 4 (seuils 0 à 15).
const BAYER := [
	[0, 8, 2, 10],
	[12, 4, 14, 6],
	[3, 11, 1, 9],
	[15, 7, 13, 5],
]

## Bandes du ciel de jour, du bas (horizon) vers le haut : [couleur, hauteur en px d'art].
## La dernière bande remplit le reste. 5 bandes de la rampe 18 → 21, crème à l'horizon (docs/16 §2.3).
## Réglées sur la rue (horizon au bas du trottoir, y 320) : crème visible entre les bâtiments, ciel clair
## à hauteur des toits, ciel au-dessus, bleu ardoise puis bleu nuit sous la barre haute.
const BANDES_CIEL := [
	["creme", 64],
	["ciel_clair", 76],
	["ciel", 150],
	["bleu_ardoise", 40],
	["bleu_nuit", 0],
]
const TRAME_CIEL := 8          # hauteur des transitions tramées entre deux bandes
const LARGEUR_DALLE := 24      # dalles du trottoir
const LARGEUR_BORDURE := 32    # pierres de la bordure


static func _c(nom: String) -> Color:
	return PalettePixel.couleur(nom)


## Vrai si le seuil de Bayer en (x, y) est sous t (0 à 1) : sert à tramer une transition.
static func trame(x: int, y: int, t: float) -> bool:
	return float(BAYER[y & 3][x & 3]) + 0.5 < t * 16.0


## Ciel en bandes : l'horizon est la dernière rangée de l'image. Les transitions entre bandes sont
## tramées sur TRAME_CIEL px. Le motif ne dépend que de (x mod 4) : l'image se répète en largeur.
static func ciel(largeur: int, hauteur: int, _graine := 0) -> Image:
	var img := Image.create_empty(largeur, hauteur, false, Image.FORMAT_RGBA8)
	# Limites des bandes, en distance depuis l'horizon
	var limites: Array = []   # [distance, couleur du dessous, couleur du dessus]
	var d := 0
	for i in BANDES_CIEL.size() - 1:
		d += int(BANDES_CIEL[i][1])
		limites.append([d, BANDES_CIEL[i][0], BANDES_CIEL[i + 1][0]])
	for y in hauteur:
		var dist := hauteur - 1 - y     # 0 = horizon
		# bande de base
		var nom: String = BANDES_CIEL[BANDES_CIEL.size() - 1][0]
		var acc := 0
		for i in BANDES_CIEL.size() - 1:
			acc += int(BANDES_CIEL[i][1])
			if dist < acc:
				nom = BANDES_CIEL[i][0]
				break
		var c_base := _c(nom)
		# transition tramée la plus proche
		var lim: Array = []
		for l in limites:
			if absi(dist - int(l[0])) <= TRAME_CIEL / 2:
				lim = l
				break
		for x in largeur:
			var c := c_base
			if not lim.is_empty():
				# t = part de la couleur du dessus (0 au bas de la transition, 1 en haut)
				var t := (float(dist - int(lim[0])) + TRAME_CIEL / 2.0 + 0.5) / float(TRAME_CIEL + 1)
				c = _c(lim[2]) if trame(x, y, t) else _c(lim[1])
			img.set_pixel(x, y, c)
	return img


## Trottoir vu de face (hauteur 8 conseillée) : arête éclairée, dalles à joints, bordure de pierre,
## ombre du caniveau. Graine : décalage des joints.
static func trottoir(largeur: int, hauteur := 8, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var decalage := rng.randi_range(0, LARGEUR_DALLE - 1)
	var dec_bordure := rng.randi_range(0, LARGEUR_BORDURE - 1)
	var img := Image.create_empty(largeur, hauteur, false, Image.FORMAT_RGBA8)
	var h := maxi(hauteur, 4)
	for y in hauteur:
		for x in largeur:
			var nom := "gris_pierre"
			if y == 0:
				nom = "zinc_clair"                   # arête éclairée (lumière en haut)
			elif y < h - 3:
				nom = "ardoise" if (x + decalage) % LARGEUR_DALLE == 0 else "gris_pierre"
				if y == h - 4 and (x + decalage) % LARGEUR_DALLE != 0:
					nom = "gris_pierre"
			elif y == h - 3:
				nom = "zinc_clair"                   # dessus de la bordure
			elif y == h - 2:
				nom = "ardoise" if (x + dec_bordure) % LARGEUR_BORDURE == 0 else "gris_pierre"
			else:
				nom = "ardoise_sombre"               # ombre portée dans le caniveau
			img.set_pixel(x, y, _c(nom))
	return img


## Chaussée vue de face (hauteur 16 conseillée) : caniveau, enrobé ardoise tramé finement
## d'ardoise sombre (grande surface), quelques reprises d'enrobé (graine), bord inférieur sombre.
static func chaussee(largeur: int, hauteur := 16, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := Image.create_empty(largeur, hauteur, false, Image.FORMAT_RGBA8)
	var ardoise := _c("ardoise")
	var sombre := _c("ardoise_sombre")
	for y in hauteur:
		for x in largeur:
			var c := ardoise
			if y == 0 or y == hauteur - 1:
				c = sombre
			elif trame(x, y, 0.07):
				c = sombre                           # grain régulier (1 pixel sur 16)
			img.set_pixel(x, y, c)
	# Reprises d'enrobé : rectangles d'ardoise sombre (un seul ton, pas d'arête : ce n'est pas un objet)
	var n := maxi(1, largeur / 160)
	for i in n:
		var l := rng.randi_range(12, 28)
		var hh := rng.randi_range(2, 4)
		var x0 := rng.randi_range(0, maxi(0, largeur - l))
		var y0 := rng.randi_range(3, maxi(3, hauteur - hh - 2))
		for y in range(y0, mini(hauteur - 1, y0 + hh)):
			for x in range(x0, mini(largeur, x0 + l)):
				img.set_pixel(x, y, sombre)
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


## Copie une zone d'une matière (répétée si besoin) dans le rectangle donné, seulement là où masque
## (facultatif) est opaque.
static func remplir(img: Image, x: int, y: int, l: int, h: int, matiere: Image) -> void:
	var ml := matiere.get_width()
	var mh := matiere.get_height()
	for j in h:
		for i in l:
			var c := matiere.get_pixel(i % ml, j % mh)
			if c.a > 0.0 and x + i >= 0 and y + j >= 0 and x + i < img.get_width() and y + j < img.get_height():
				img.set_pixel(x + i, y + j, c)


## Contour intérieur : chaque pixel opaque qui touche (4 voisins) un pixel transparent ou le bord
## prend la couleur nom. bords : "tous" ou "cotes" (gauche, droite, haut seulement).
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


## Remplace une couleur de la palette par une autre (recoloration d'un motif).
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


## Lointain : ramène chaque couleur à 3 tons pâles selon sa luminance (immeubles de fond).
static func palir(img: Image) -> Image:
	var copie := Image.new()
	copie.copy_from(img)
	var sombre := _c("ardoise")
	var moyen := _c("gris_pierre")
	var clair := _c("zinc_clair")
	for y in copie.get_height():
		for x in copie.get_width():
			var c := copie.get_pixel(x, y)
			if c.a == 0.0:
				continue
			var lum := 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
			copie.set_pixel(x, y, sombre if lum < 0.42 else (moyen if lum < 0.72 else clair))
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


# --- Matières de construction --------------------------------------------------------------------

## Meulière (pavillon de Gérard) : pierres ocre irrégulières, joints rouges, arête claire en haut
## (lumière en haut à gauche), ombre en bas des grosses pierres.
static func meuliere(largeur: int, hauteur: int, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := uni(largeur, hauteur, "caramel")   # joints de rocaillage brun-rouge
	var y := 0
	while y < hauteur:
		var hh := rng.randi_range(4, 6)
		var x := -rng.randi_range(0, 6)
		while x < largeur:
			var w := rng.randi_range(5, 10)
			var r := rng.randf()
			var base := "pierre"
			var clair := "pierre_claire"
			var ombre := "pierre_ombre"
			if r < 0.12:
				base = "pierre_ombre"
				clair = "pierre"
				ombre = "bois"
			elif r < 0.4:
				base = "terre_cuite_claire"
				clair = "pierre_claire"
				ombre = "caramel"
			for j in hh - 1:
				for i in w - 1:
					var nom := base
					if j == 0 and i < w - 2:
						nom = clair
					elif j == hh - 2 and hh >= 4 and i > 0:
						nom = ombre
					elif i == w - 2 and j > 0 and w >= 6:
						nom = ombre
					px(img, x + i, y + j, nom)
			x += w
		y += hh
	return img


## Tuiles mécaniques (tuiles de Marseille) : rangs de 4 px, côtes verticales tous les 6 px,
## lèvre claire en haut, ombre du rang du dessus en bas ; quelques tuiles plus sombres.
static func tuiles(largeur: int, hauteur: int, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := vide(largeur, hauteur)
	var rangs := hauteur / 4 + 1
	var sombres := {}
	for r in rangs:
		for t in largeur / 6 + 2:
			if rng.randf() < 0.1:
				sombres[Vector2i(r, t)] = true
	for y in hauteur:
		var r := y / 4
		var yy := y % 4
		var dec := 3 if r % 2 == 1 else 0
		for x in largeur:
			var xm := (x + dec) % 6
			var t := (x + dec) / 6
			var sombre := sombres.has(Vector2i(r, t))
			var base := "brique" if sombre else "tuile"
			var clair := "tuile" if sombre else "terre_cuite_claire"
			var ombre := "brique_sombre" if sombre else "brique"
			var nom := base
			if yy == 3:
				nom = "brique_sombre"
			elif xm == 0:
				nom = ombre
			elif yy == 0 or xm == 1:
				nom = clair
			px(img, x, y, nom)
	return img


## Zinc (toits à la Mansart) : joints debout tous les 4 px (arête claire + ombre), corps gris bleu.
static func zinc(largeur: int, hauteur: int, _graine := 0) -> Image:
	var img := vide(largeur, hauteur)
	for y in hauteur:
		for x in largeur:
			var nom := "gris_pierre"
			if x % 4 == 0:
				nom = "zinc_clair"
			elif x % 4 == 1:
				nom = "ardoise"
			elif y % 12 == 11:
				nom = "ardoise"
			px(img, x, y, nom)
	return img


## Ardoise : rangs de 3 px, ardoises de 6 px décalées, quelques ardoises éclairées.
static func ardoise(largeur: int, hauteur: int, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := vide(largeur, hauteur)
	for y in hauteur:
		var r := y / 3
		for x in largeur:
			var dec := 3 if r % 2 == 1 else 0
			var nom := "ardoise"
			if y % 3 == 2 or (x + dec) % 6 == 0:
				nom = "ardoise_sombre"
			px(img, x, y, nom)
	for i in largeur * hauteur / 60:
		var x := rng.randi_range(0, largeur - 1) / 6 * 6
		var y := rng.randi_range(0, hauteur - 1) / 3 * 3
		for k in range(1, 5):
			px(img, x + k + (3 if (y / 3) % 2 == 1 else 0), y, "gris_pierre")
	return img


## Pierre de taille (immeubles haussmanniens) : assises de 5 px, joints fins, harpage décalé.
static func pierre_taille(largeur: int, hauteur: int, _graine := 0, refends := false) -> Image:
	var img := vide(largeur, hauteur)
	for y in hauteur:
		var r := y / 5
		for x in largeur:
			var nom := "pierre_claire"
			if y % 5 == 4:
				nom = "pierre_ombre" if refends else "pierre"
			elif refends and y % 5 == 0:
				nom = "blanc_chaud" if x % 3 != 0 else "pierre_claire"
			elif not refends and (x + (7 if r % 2 == 1 else 0)) % 14 == 0:
				nom = "pierre"
			px(img, x, y, nom)
	return img


## Brique : briques de 6 × 3, joints sombres, quelques briques claires.
static func brique(largeur: int, hauteur: int, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := vide(largeur, hauteur)
	var claires := {}
	for i in largeur * hauteur / 40:
		claires[Vector2i(rng.randi_range(0, largeur / 6 + 1), rng.randi_range(0, hauteur / 3 + 1))] = true
	for y in hauteur:
		var r := y / 3
		var dec := 3 if r % 2 == 1 else 0
		for x in largeur:
			var nom := "brique"
			if y % 3 == 2 or (x + dec) % 6 == 5:
				nom = "brique_sombre"
			elif claires.has(Vector2i((x + dec) / 6, r)):
				nom = "tuile"
			px(img, x, y, nom)
	return img


## Nuage en marches d'escalier, 3 tons (blanc chaud, ciel clair dessous, zinc clair en bordure basse).
static func nuage(largeur: int, hauteur: int, graine := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := vide(largeur, hauteur)
	# marches : rectangles empilés, plus étroits vers le haut
	var marches := maxi(2, hauteur / 4)
	var g := 0
	var d := largeur
	for m in marches:
		var y0 := hauteur - (m + 1) * (hauteur / marches)
		if m == marches - 1:
			y0 = 0
		var y1 := hauteur - m * (hauteur / marches)
		rect(img, g, y0, d - g, y1 - y0, "blanc_chaud")
		g += rng.randi_range(2, maxi(3, largeur / (marches * 2)))
		d -= rng.randi_range(2, maxi(3, largeur / (marches * 2)))
		if d - g < 6:
			break
	# ombre : 2 rangées du bas et bord droit de chaque marche
	for y in hauteur:
		for x in largeur:
			if img.get_pixel(x, y).a == 0.0:
				continue
			var droite_vide := x + 1 >= largeur or img.get_pixel(x + 1, y).a == 0.0
			if y >= hauteur - 2:
				img.set_pixel(x, y, _c("ciel_clair"))
			elif droite_vide:
				img.set_pixel(x, y, _c("ciel_clair"))
	for x in largeur:
		if img.get_pixel(x, hauteur - 1).a > 0.0:
			img.set_pixel(x, hauteur - 1, _c("zinc_clair"))
	return img


## Génère et enregistre dans GrillePixel les matières standard de la ville (noms « matiere/… »).
## Renvoie les noms enregistrés.
static func generer_tout(graine := 1) -> PackedStringArray:
	GrillePixel.enregistrer("matiere/ciel", ciel(64, 440, graine), Vector2i(0, 439))
	GrillePixel.enregistrer("matiere/trottoir", trottoir(1280, 8, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/chaussee", chaussee(1280, 16, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/meuliere", meuliere(48, 32, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/tuiles", tuiles(48, 32, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/zinc", zinc(48, 32, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/ardoise", ardoise(48, 32, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/pierre_taille", pierre_taille(48, 32, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/brique", brique(48, 32, graine), Vector2i.ZERO)
	return PackedStringArray(["matiere/ciel", "matiere/trottoir", "matiere/chaussee", "matiere/meuliere",
		"matiere/tuiles", "matiere/zinc", "matiere/ardoise", "matiere/pierre_taille", "matiere/brique"])
