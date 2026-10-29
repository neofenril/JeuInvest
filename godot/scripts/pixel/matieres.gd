class_name MatieresPixel
extends RefCounted
## Générateurs de matières pixel (docs/16 §2.3, §2.4, §4.4) : ciel en bandes tramé (Bayer 4 × 4),
## trottoir, chaussée ; plus tard meulière, tuiles, pierre, brique, ardoise, zinc.
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
const BANDES_CIEL := [
	["creme", 12],
	["ciel_clair", 46],
	["ciel", 110],
	["bleu_ardoise", 112],
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


## Génère et enregistre dans GrillePixel les matières standard de la ville (noms « matiere/… »).
## Renvoie les noms enregistrés.
static func generer_tout(graine := 1) -> PackedStringArray:
	GrillePixel.enregistrer("matiere/ciel", ciel(64, 440, graine), Vector2i(0, 439))
	GrillePixel.enregistrer("matiere/trottoir", trottoir(1280, 8, graine), Vector2i.ZERO)
	GrillePixel.enregistrer("matiere/chaussee", chaussee(1280, 16, graine), Vector2i.ZERO)
	return PackedStringArray(["matiere/ciel", "matiere/trottoir", "matiere/chaussee"])
