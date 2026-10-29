class_name RuePx0
extends Node2D
## Le monde de la preuve de concept pixel (lot PX0, docs/16 §2.6 et §5.1), en px d'art.
## Repères (y vers le bas) : bas des façades = SOL (312), trottoir 312-320, chaussée 320-336,
## jardinet x 0-24, maison de Gérard x 24-120 (96 × 124, cheminée à y 188), platane glissé entre la
## maison et la façade voisine (haussmannienne, boulangerie au rez-de-chaussée), immeubles de fond pâles,
## décor habillé de x -480 à 816.
##
## Jour / nuit : chaque élément est dessiné à partir des images de GrillePixel ; pendant le fondu, la
## version nuit est posée sur la version jour avec un alpha croissant, élément par élément (ordre de
## superposition respecté). Fondu terminé : une seule version. Fenêtres allumées (couleur lumiere,
## émissive) : opérations « nuit seulement ». Halos : calque additif (3 disques pixellisés).

const Facades := preload("res://scripts/pixel/facades.gd")

const SOL := 312
const TROTTOIR := 8
const CHAUSSEE := 16
const BAS_CHAUSSEE := SOL + TROTTOIR + CHAUSSEE          # 336
const MONDE_GAUCHE := -480
const MONDE_DROITE := 816
const HAUTEUR_CIEL := 440
const MAISON := Rect2(24, 188, 96, 124)
const ZONE := Rect2(0, 188, 256, 148)                   # cheminée → bas de la chaussée, jardinet → façade voisine
const TAILLE_GERARD := Vector2i(16, 28)
const FONDU := 3.0
const PIEDS := 317                                       # y des pieds des passants (milieu du trottoir)
const CADENCE_MARCHE := 8.0                              # images par seconde, 1 px d'art par image
const CADENCE_REPOS := 2.0
const GERARD_MIN := 34
const GERARD_MAX := 112
const PORTE_X := 87                                      # milieu de la porte de la maison
const HUMEURS := ["sylvie_contente", "sylvie_neutre", "sylvie_contrariee"]
const HALOS := [[22, 0.08], [14, 0.18], [8, 0.30]]       # rayon, alpha (docs/16 §2.4)

var _melange := 0.0          # 0 = jour, 1 = nuit
var _nuit := false
var _humeur := 0
var _fige := false
var _lumieres_visibles := true
var _tween: Tween = null
var _couches: Array = []
var _mobiles: Array = []
var _lumieres: Node2D = null
var _planche: Node2D = null
var _rng := RandomNumberGenerator.new()

# Animation
var _gerard: Mobile
var _sylvie: Mobile
var _r5: Mobile
var _nuages: Array = []
var _arbres: Array = []
var _g_x := 60.0
var _g_dir := 1
var _g_image := 0
var _g_repos := 0.0          # temps de repos restant devant la porte
var _g_passe_porte := false
var _g_t := 0.0
var _r5_x := -560.0
var _r5_attente := 0.0
var _r5_t := 0.0
var _r5_image := 0
var _nuage_t := 0.0
var _arbre_t := 0.0
var _arbre_image := 0
var _cligne_t := 3.0
var _cligne_fin := 0.0
var _nuage_n := 0
static var _fenetres := {}   # nom d'image du décor -> fenêtres (Rect2i locaux), remplies par generer_decor()


## Élément fixe dessiné en version jour et nuit. ops : {"image": nom, "pos": Vector2i, "repeter_x": int,
## "nuit": bool} ou {"rect": Rect2i, "couleur": nom, "nuit": bool} (nuit = seulement la nuit).
class Couche extends Node2D:
	var rue: RuePx0
	var ops: Array = []

	func image(nom: String, pos: Vector2i, repeter_x := 0) -> void:
		ops.append({"image": nom, "pos": pos, "repeter_x": repeter_x, "nuit": false})
		queue_redraw()

	func rect(r: Rect2i, couleur: String, nuit := false) -> void:
		ops.append({"rect": r, "couleur": couleur, "nuit": nuit})
		queue_redraw()

	func _draw() -> void:
		var m := rue.melange()
		for op in ops:
			if op["nuit"]:
				if m > 0.0:
					_op(op, PalettePixel.NUIT, m)
				continue
			if m < 1.0:
				_op(op, PalettePixel.JOUR, 1.0)
			if m > 0.0:
				_op(op, PalettePixel.NUIT, m)

	func _op(op: Dictionary, variante: int, alpha: float) -> void:
		var teinte := Color(1, 1, 1, alpha)
		if op.has("rect"):
			draw_rect(Rect2(op["rect"]), PalettePixel.couleur_alpha(op["couleur"], alpha, variante))
			return
		var tex := GrillePixel.texture(op["image"], variante)
		if tex == null:
			return
		var pos: Vector2i = op["pos"] - GrillePixel.origine(op["image"])
		var l := tex.get_width()
		var fin: int = pos.x + maxi(int(op["repeter_x"]), l)
		var x := pos.x
		while x < fin:
			if x + l <= fin:
				draw_texture(tex, Vector2(x, pos.y), teinte)
			else:
				var reste := fin - x
				draw_texture_rect_region(tex, Rect2(x, pos.y, reste, tex.get_height()), Rect2(0, 0, reste, tex.get_height()), teinte)
			x += l


## Élément animé : une ou plusieurs images posées par leur origine (décalage), plus des rectangles
## « nuit seulement » (phares). La position du nœud est toujours entière.
class Mobile extends Node2D:
	var rue: RuePx0
	var parts: Array = []        # [nom, Vector2i décalage]
	var nuit_rects: Array = []   # [Rect2i, couleur]

	func poser(liste: Array) -> void:
		parts = liste
		queue_redraw()

	func _draw() -> void:
		var m := rue.melange()
		for p in parts:
			if m < 1.0:
				_img(p, PalettePixel.JOUR, 1.0)
			if m > 0.0:
				_img(p, PalettePixel.NUIT, m)
		if m > 0.0:
			for r in nuit_rects:
				draw_rect(Rect2(r[0]), PalettePixel.couleur_alpha(r[1], m, PalettePixel.NUIT))

	func _img(p: Array, variante: int, alpha: float) -> void:
		var tex := GrillePixel.texture(p[0], variante)
		if tex != null:
			draw_texture(tex, Vector2(p[1] - GrillePixel.origine(p[0])), Color(1, 1, 1, alpha))


## Halos de lumière (calque additif) : disques pixellisés couleur lumiere.
class Halos extends Node2D:
	var centres: Array = []      # Vector2i

	func _draw() -> void:
		for c in centres:
			for h in RuePx0.HALOS:
				var nom := "decor/halo_%d" % h[0]
				draw_texture(GrillePixel.texture(nom), Vector2(c - GrillePixel.origine(nom)), Color(1, 1, 1, h[1]))


func _init() -> void:
	name = "RuePx0"


func _ready() -> void:
	_rng.seed = 84
	if not GrillePixel.existe("matiere/ciel"):
		MatieresPixel.generer_tout()
	if not GrillePixel.existe("ville/gerard_marche_1"):
		GrillePixel.charger_dossier("ville")
	generer_decor()
	_construire()
	preparer_capture()


# --- Génération des images du décor (catalogue « decor/… », « miroir/… ») ---------------------------

## Bâtiments de premier plan : [x gauche, type, largeur, étages, rez-de-chaussée, graine].
const BATIMENTS := [
	[-480, "haussmann", 112, 4, "boulangerie", 18],
	[-368, "brique", 112, 3, "tabac", 11],
	[-256, "haussmann", 112, 4, "porte", 12],
	[-104, "haussmann", 104, 3, "pharmacie", 13],
	[152, "haussmann", 112, 4, "boulangerie", 14],
	[264, "brique", 96, 3, "magasin", 15],
	[360, "haussmann", 112, 5, "porte", 16],
	[512, "haussmann", 104, 4, "tabac", 17],
	[616, "brique", 104, 3, "boulangerie", 19],
	[720, "haussmann", 96, 4, "porte", 20],
]
## Arbres glissés entre deux bâtiments : [x du milieu, graine].
const PLATANES := [[-124, 31], [136, 3], [492, 37]]
const REVERBERES := [-150, 6, 300, 600]
const POTELETS := [-60, -44, 170, 186, 340, 356]


static func generer_decor() -> void:
	if GrillePixel.existe("decor/maison"):
		return
	var maison: Dictionary = Facades.maison_gerard(7)
	GrillePixel.enregistrer("decor/maison", maison["image"], Vector2i(0, Facades.MAISON_H - 1))
	_fenetres["decor/maison"] = maison["fenetres"]
	for i in BATIMENTS.size():
		var b: Array = BATIMENTS[i]
		var r: Dictionary = Facades.haussmann(b[2], b[3], b[5], b[4]) if b[1] == "haussmann" else Facades.immeuble_brique(b[2], b[3], b[5], b[4])
		var img: Image = r["image"]
		GrillePixel.enregistrer("decor/batiment_%d" % i, img, Vector2i(0, img.get_height() - 1))
		_fenetres["decor/batiment_%d" % i] = r["fenetres"]
	# Immeubles de fond (plus hauts, pâlis), sauf derrière la maison (toit et cheminée sur le ciel)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1984
	var x := MONDE_GAUCHE - 16
	var k := 0
	while x < MONDE_DROITE:
		var l := rng.randi_range(72, 120)
		var et := rng.randi_range(5, 6)
		if x + l > -6 and x < 150:
			x = 150
			continue
		var r2: Dictionary = Facades.haussmann(l, et, 500 + k, "porte")
		var pale := MatieresPixel.palir(r2["image"])
		GrillePixel.enregistrer("decor/fond_%d" % k, pale, Vector2i(0, pale.get_height() - 1))
		_fenetres["decor/fond_%d" % k] = r2["fenetres"]
		k += 1
		x += l + rng.randi_range(-8, 6)
	for i in PLATANES.size():
		for im in 2:
			GrillePixel.enregistrer("decor/platane_%d_%d" % [i, im], Facades.platane(PLATANES[i][1], im))
	for im in 2:
		GrillePixel.enregistrer("decor/arbre_jardin_%d" % im, Facades.arbre(30, 52, 41, im))
	GrillePixel.enregistrer("decor/massif", Facades.massif(30, 16, 5))
	GrillePixel.enregistrer("decor/grille_maison", Facades.grille_basse(124, [78, 14]), Vector2i(0, 15))
	GrillePixel.enregistrer("decor/carotte", Facades.carotte_tabac(), Vector2i(0, 0))
	GrillePixel.enregistrer("decor/chaise", Facades.chaise_bistrot())
	GrillePixel.enregistrer("decor/gueridon", Facades.gueridon())
	GrillePixel.enregistrer("decor/potelet", Facades.potelet())
	GrillePixel.enregistrer("decor/plaque", Facades.plaque_rue(), Vector2i(0, 0))
	GrillePixel.enregistrer("decor/nuage_1", MatieresPixel.nuage(56, 16, 2))
	GrillePixel.enregistrer("decor/nuage_2", MatieresPixel.nuage(40, 12, 9))
	for h in HALOS:
		GrillePixel.enregistrer("decor/halo_%d" % h[0], MatieresPixel.disque(h[0], "lumiere"), Vector2i(h[0], h[0]))
	# Miroirs des figurines (marche vers la gauche) : retournées au pixel près
	for n in GrillePixel.noms():
		if n.begins_with("ville/gerard_"):
			var img := Image.new()
			img.copy_from(GrillePixel.image(n))
			img.flip_x()
			var o := GrillePixel.origine(n)
			GrillePixel.enregistrer("miroir/" + n.get_file(), img, Vector2i(img.get_width() - 1 - o.x, o.y))


## Fenêtres (rectangles locaux) d'une image du décor.
static func fenetres(nom: String) -> Array:
	return _fenetres.get(nom, [])


# --- Construction de la scène ----------------------------------------------------------------------

func _construire() -> void:
	var largeur := MONDE_DROITE - MONDE_GAUCHE
	# Ciel (plan 0)
	var ciel := _couche("Ciel")
	ciel.rect(Rect2i(MONDE_GAUCHE, SOL + TROTTOIR - HAUTEUR_CIEL - 400, largeur, 400), "bleu_nuit")
	ciel.image("matiere/ciel", Vector2i(MONDE_GAUCHE, SOL + TROTTOIR - 1), largeur)
	for i in 70:
		var ex := _rng.randi_range(MONDE_GAUCHE, MONDE_DROITE)
		var ey := _rng.randi_range(-60, 150)
		ciel.rect(Rect2i(ex, ey, 1, 1), "blanc_chaud", true)        # étoiles (nuit)
	# Nuages
	for i in 3:
		var n := _mobile("Nuage%d" % (i + 1))
		n.poser([["decor/nuage_%d" % (i % 2 + 1), Vector2i.ZERO]])
		_nuages.append(n)
	# Immeubles de fond (pâles) et leurs fenêtres allumées la nuit
	var fond := _couche("Fond")
	var rng := RandomNumberGenerator.new()
	rng.seed = 1984
	var x := MONDE_GAUCHE - 16
	var k := 0
	while x < MONDE_DROITE:
		var l := rng.randi_range(72, 120)
		var _et := rng.randi_range(5, 6)
		if x + l > -6 and x < 150:
			x = 150
			continue
		fond.image("decor/fond_%d" % k, Vector2i(x, SOL - 1))
		var img := GrillePixel.image("decor/fond_%d" % k)
		_allumer(fond, fenetres("decor/fond_%d" % k), Vector2i(x, SOL - img.get_height()), 0.22, 600 + k)
		k += 1
		x += l + rng.randi_range(-8, 6)
	# Arbres glissés entre les bâtiments (derrière les façades : seul l'espace libre les montre)
	for i in PLATANES.size():
		var a := _mobile("Platane%d" % i)
		a.position = Vector2(PLATANES[i][0], SOL - 1)
		a.poser([["decor/platane_%d_0" % i, Vector2i.ZERO]])
		_arbres.append([a, "decor/platane_%d_" % i])
	var aj := _mobile("ArbreJardin")
	aj.position = Vector2(10, 300)
	aj.poser([["decor/arbre_jardin_0", Vector2i.ZERO]])
	_arbres.append([aj, "decor/arbre_jardin_"])
	# Bâtiments de premier plan
	var rue := _couche("Batiments")
	for i in BATIMENTS.size():
		var b: Array = BATIMENTS[i]
		var nom := "decor/batiment_%d" % i
		rue.image(nom, Vector2i(b[0], SOL - 1))
		var h := GrillePixel.image(nom).get_height()
		_allumer(rue, fenetres(nom), Vector2i(b[0], SOL - h), 0.4, 700 + i)
		if b[4] == "tabac":
			rue.image("decor/carotte", Vector2i(b[0] + b[2] - 12, SOL - 52))
	rue.image("decor/plaque", Vector2i(156, SOL - 74))
	# Maison de Gérard : toutes ses fenêtres s'allument la nuit
	var maison := _couche("Maison")
	maison.image("decor/maison", Vector2i(int(MAISON.position.x), SOL - 1))
	_allumer(maison, fenetres("decor/maison"), Vector2i(MAISON.position), 1.0, 0)
	# Sylvie à sa fenêtre (au-dessus de la lumière de la pièce)
	_sylvie = _mobile("Sylvie")
	var fs: Rect2i = Facades.FENETRE_SYLVIE
	_sylvie.position = Vector2(MAISON.position.x + fs.position.x + 9, MAISON.position.y + fs.position.y + fs.size.y - 2)
	_maj_sylvie()
	# Jardinet : massif, grille basse et portillon
	var jardin := _couche("Jardin")
	jardin.image("decor/massif", Vector2i(13, 300))
	jardin.image("decor/grille_maison", Vector2i(0, SOL - 1))
	# Sol : trottoir, chaussée, trottoir d'en face, puis remplissage sous la frise
	var sol := _couche("Sol")
	sol.image("matiere/trottoir", Vector2i(MONDE_GAUCHE, SOL), largeur)
	sol.image("matiere/chaussee", Vector2i(MONDE_GAUCHE, SOL + TROTTOIR), largeur)
	sol.image("matiere/trottoir", Vector2i(MONDE_GAUCHE, BAS_CHAUSSEE), largeur)
	sol.rect(Rect2i(MONDE_GAUCHE, BAS_CHAUSSEE + TROTTOIR, largeur, 400), "ardoise_sombre")
	# Mobilier : terrasse du tabac, potelets, réverbères (lanternes allumées la nuit)
	var mob := _couche("Mobilier")
	for i in BATIMENTS.size():
		if BATIMENTS[i][4] == "tabac":
			var bx: int = BATIMENTS[i][0]
			mob.image("decor/chaise", Vector2i(bx + 14, 317))
			mob.image("decor/gueridon", Vector2i(bx + 20, 317))
			mob.image("decor/chaise", Vector2i(bx + 26, 317))
	for px0 in POTELETS:
		mob.image("decor/potelet", Vector2i(px0, 318))
	var centres: Array = []
	for rx in REVERBERES:
		mob.image("ville/reverbere", Vector2i(rx, 316))
		var o := GrillePixel.origine("ville/reverbere")
		var coin := Vector2i(rx, 316) - o
		mob.rect(Rect2i(coin + Vector2i(1, 5), Vector2i(5, 2)), "lumiere", true)
		mob.rect(Rect2i(coin + Vector2i(2, 7), Vector2i(3, 3)), "lumiere", true)
		centres.append(coin + Vector2i(4, 7))
	# Gérard, puis la R5 sur la chaussée
	_gerard = _mobile("Gerard")
	_r5 = _mobile("R5")
	_r5.nuit_rects = [[Rect2i(20, -10, 2, 2), "lumiere"]]
	# Calque des lumières (mélange additif), visible la nuit seulement
	_lumieres = Node2D.new()
	_lumieres.name = "Lumieres"
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_lumieres.material = mat
	_lumieres.z_index = 50
	add_child(_lumieres)
	var halos := Halos.new()
	halos.centres = centres
	halos.use_parent_material = true
	_lumieres.add_child(halos)
	_maj_lumieres()


## Ajoute des fenêtres allumées (nuit seulement) : part = proportion allumée (1 = toutes).
func _allumer(c: Couche, fenetres: Array, coin: Vector2i, part: float, graine: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	for f in fenetres:
		var r: Rect2i = f
		if part >= 1.0 or rng.randf() < part:
			c.rect(Rect2i(coin + r.position, r.size), "lumiere", true)


func _couche(n: String) -> Couche:
	var c := Couche.new()
	c.name = n
	c.rue = self
	add_child(c)
	_couches.append(c)
	return c


func _mobile(n: String) -> Mobile:
	var m := Mobile.new()
	m.name = n
	m.rue = self
	add_child(m)
	_mobiles.append(m)
	return m


func melange() -> float:
	return _melange


func _set_melange(v: float) -> void:
	_melange = clampf(v, 0.0, 1.0)
	for c in _couches:
		c.queue_redraw()
	for m in _mobiles:
		m.queue_redraw()
	_maj_lumieres()


func _maj_lumieres() -> void:
	if _lumieres != null:
		_lumieres.visible = _lumieres_visibles and _melange > 0.0
		_lumieres.modulate = Color(1, 1, 1, _melange)


# --- Animation -------------------------------------------------------------------------------------

func _process(delta: float) -> void:
	if _fige:
		return
	_animer_gerard(delta)
	_animer_r5(delta)
	# Nuages : 1 px d'art toutes les 0,5 s (le premier) et 0,8 s (le second), retour à gauche
	_nuage_t += delta
	if _nuage_t >= 0.5:
		_nuage_t -= 0.5
		_nuage_n += 1
		for i in _nuages.size():
			var n: Mobile = _nuages[i]
			if i == 0 or _nuage_n % 3 != 0:
				n.position.x += 1
			if n.position.x > MONDE_DROITE:
				n.position.x = MONDE_GAUCHE
	# Arbres : 2 images à 1 im/s
	_arbre_t += delta
	if _arbre_t >= 1.0:
		_arbre_t -= 1.0
		_arbre_image = 1 - _arbre_image
		_maj_arbres()
	# Sylvie cligne des yeux toutes les 3 à 6 s (120 ms)
	_cligne_t -= delta
	if _cligne_t <= 0.0:
		_cligne_fin = 0.12
		_cligne_t = _rng.randf_range(3.0, 6.0)
		_maj_sylvie()
	elif _cligne_fin > 0.0:
		_cligne_fin -= delta
		if _cligne_fin <= 0.0:
			_maj_sylvie()


func _animer_gerard(delta: float) -> void:
	if _g_repos > 0.0:
		_g_repos -= delta
		_g_t += delta
		if _g_t >= 1.0 / CADENCE_REPOS:
			_g_t -= 1.0 / CADENCE_REPOS
			_g_image = 1 - _g_image
			_maj_gerard()
		if _g_repos <= 0.0:
			_g_image = 0
			_g_t = 0.0
			_maj_gerard()
		return
	_g_t += delta
	while _g_t >= 1.0 / CADENCE_MARCHE:
		_g_t -= 1.0 / CADENCE_MARCHE
		_g_image = (_g_image + 1) % 4
		_g_x += _g_dir
		if _g_x >= GERARD_MAX or _g_x <= GERARD_MIN:
			_g_dir = -_g_dir
		if int(_g_x) == PORTE_X:
			_g_passe_porte = not _g_passe_porte
			if _g_passe_porte:
				_g_repos = 3.0                          # une fois sur deux, il s'arrête devant sa porte
				_g_image = 0
				_g_t = 0.0
				break
	_maj_gerard()


func _maj_gerard() -> void:
	_gerard.position = Vector2(int(_g_x), PIEDS)
	var dossier := "ville/" if _g_dir > 0 else "miroir/"
	var nom := ("gerard_repos_%d" % (_g_image + 1)) if _g_repos > 0.0 else ("gerard_marche_%d" % (_g_image + 1))
	_gerard.poser([[dossier + nom, Vector2i.ZERO]])


func _animer_r5(delta: float) -> void:
	if _r5_attente > 0.0:
		_r5_attente -= delta
		return
	_r5_x += 36.0 * delta
	_r5_t += delta
	if _r5_t >= 1.0 / 8.0:
		_r5_t -= 1.0 / 8.0
		_r5_image = (_r5_image + 1) % 4
	if _r5_x > MONDE_DROITE + 60:
		_r5_x = MONDE_GAUCHE - 60
		_r5_attente = 4.0
	_maj_r5()


func _maj_r5() -> void:
	_r5.position = Vector2(int(_r5_x), 333)
	var roue := "ville/r5_roue_%d" % (_r5_image % 2 + 1)
	var bas := Vector2i(0, -1) if _r5_image == 3 else Vector2i.ZERO      # caisse abaissée 1 image sur 4
	_r5.poser([["ville/r5_caisse", bas], [roue, Vector2i(-14, 0)], [roue, Vector2i(14, 0)]])
	_r5.nuit_rects = [[Rect2i(20, -10 + bas.y, 2, 2), "lumiere"]]


func _maj_arbres() -> void:
	for a in _arbres:
		(a[0] as Mobile).poser([[a[1] + str(_arbre_image), Vector2i.ZERO]])


func _maj_sylvie() -> void:
	var parts := [["ville/" + HUMEURS[_humeur], Vector2i.ZERO]]
	if _cligne_fin > 0.0:
		parts.append(["ville/sylvie_cligne", Vector2i.ZERO])
	_sylvie.poser(parts)


# --- API (lot PX0 §2.4) ----------------------------------------------------------------------------

## Zone qui doit toujours être visible (px d'art) : du haut de la cheminée au bas de la chaussée,
## du jardinet à la façade voisine.
func zone_utile() -> Rect2:
	return ZONE


## Passe en nuit (ou en jour) avec un fondu de « fondu » secondes (0 = immédiat).
func regler_nuit(nuit: bool, fondu := FONDU) -> void:
	_nuit = nuit
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var cible := 1.0 if nuit else 0.0
	if fondu <= 0.0:
		_set_melange(cible)
		return
	_tween = create_tween()
	_tween.tween_method(_set_melange, _melange, cible, fondu * absf(cible - _melange))


func est_nuit() -> bool:
	return _nuit


## Vrai quand aucun fondu n'est en cours.
func fondu_termine() -> bool:
	return _melange == (1.0 if _nuit else 0.0)


## Humeur de Sylvie à la fenêtre : 0 contente, 1 neutre, 2 contrariée.
func regler_humeur_sylvie(h: int) -> void:
	_humeur = clampi(h, 0, 2)
	_maj_sylvie()


func humeur_sylvie() -> int:
	return _humeur


## Arrête (ou relance) ce qui bouge : marche, voiture, nuages, arbres, clignements. Le fondu continue.
func figer(f: bool) -> void:
	_fige = f
	if f and _cligne_fin > 0.0:
		_cligne_fin = 0.0
		_maj_sylvie()


func est_fige() -> bool:
	return _fige


## Pose déterministe pour les captures : Gérard devant la maison (marche, image 2), nuages et R5 placés.
func preparer_capture() -> void:
	_g_x = 60.0
	_g_dir = 1
	_g_image = 1
	_g_repos = 0.0
	_g_t = 0.0
	_g_passe_porte = true
	_maj_gerard()
	_r5_x = 214.0
	_r5_attente = 0.0
	_r5_image = 0
	_maj_r5()
	_nuages[0].position = Vector2(-120, 58)
	_nuages[1].position = Vector2(170, 44)
	_nuages[2].position = Vector2(390, 70)
	_arbre_image = 0
	_maj_arbres()
	_cligne_fin = 0.0
	_cligne_t = 3.0
	_maj_sylvie()


## Affiche ou masque le calque additif (masqué pendant le contrôle de palette).
func afficher_lumieres(v: bool) -> void:
	_lumieres_visibles = v
	_maj_lumieres()


## Point d'ancrage de l'étiquette « MA MAISON » : sur la chaussée, sous le milieu de la maison.
func point_etiquette_maison() -> Vector2:
	return Vector2(MAISON.get_center().x, SOL + TROTTOIR + CHAUSSEE / 2.0)


func taille_gerard() -> Vector2i:
	return TAILLE_GERARD


## Position (px d'art) des pieds de Gérard (ajout, pour l'interface et les tests).
func position_gerard() -> Vector2i:
	return Vector2i(int(_g_x), PIEDS)


## Planche des sprites (étape « planche ») : fond crème couvrant la vue, sprites agrandis ×2 en px d'art
## (×6 à l'écran en 1080), rangés de gauche à droite.
func afficher_planche(v: bool, vue: Rect2) -> void:
	if _planche != null:
		_planche.queue_free()
		_planche = null
	if not v:
		return
	_planche = Node2D.new()
	_planche.name = "Planche"
	_planche.z_index = 100
	add_child(_planche)
	var fond := Couche.new()
	fond.rue = self
	fond.rect(Rect2i(vue.position.floor(), vue.size.ceil()), "creme")
	_planche.add_child(fond)
	var marge := 10
	var x := int(vue.position.x) + marge
	var y := int(vue.position.y) + 36
	var hauteur_rangee := 0
	for n in sprites_planche():
		var tex := GrillePixel.texture(n)
		var t := tex.get_size() * 2
		if x + t.x > vue.end.x - marge and x > int(vue.position.x) + marge:
			x = int(vue.position.x) + marge
			y += hauteur_rangee + 10
			hauteur_rangee = 0
		var s := Sprite2D.new()
		s.texture = tex
		s.centered = false
		s.scale = Vector2(2, 2)
		s.position = Vector2(x, y)
		_planche.add_child(s)
		x += int(t.x) + 10
		hauteur_rangee = maxi(hauteur_rangee, int(t.y))


## Sprites montrés sur la planche : Gérard (marche 4, repos 2), Sylvie (3 humeurs), M. Lefranc
## (3 expressions), R5 (2 images de roue, montées), réverbère.
func sprites_planche() -> PackedStringArray:
	if not GrillePixel.existe("planche/r5_1"):
		for i in 2:
			var c := GrillePixel.image("ville/r5_caisse")
			var img := Image.new()
			img.copy_from(c)
			var roue := GrillePixel.image("ville/r5_roue_%d" % (i + 1))
			MatieresPixel.coller(img, roue, 6, 12)
			MatieresPixel.coller(img, roue, 34, 12)
			GrillePixel.enregistrer("planche/r5_%d" % (i + 1), img)
	return PackedStringArray([
		"ville/gerard_marche_1", "ville/gerard_marche_2", "ville/gerard_marche_3", "ville/gerard_marche_4",
		"ville/gerard_repos_1", "ville/gerard_repos_2", "ville/sylvie_contente", "ville/sylvie_neutre",
		"ville/sylvie_contrariee", "ville/reverbere", "ville/lefranc_affable", "ville/lefranc_grave",
		"ville/lefranc_yeux_fermes", "planche/r5_1", "planche/r5_2",
	])


## Lignes « PX0 … » propres au monde (imprimées par px0.gd avec --px0-controle).
func lignes_controle() -> PackedStringArray:
	var maison := GrillePixel.taille("decor/maison")
	return PackedStringArray([
		"PX0 animation gerard marche=4 repos=2 cadence=%d" % int(CADENCE_MARCHE),
		"PX0 maison=%dx%d" % [maison.x, maison.y],
		"PX0 rue zone=%dx%d decor=%d..%d batiments=%d platanes=%d reverberes=%d nuit=%s humeur=%d" % [
			int(ZONE.size.x), int(ZONE.size.y), MONDE_GAUCHE, MONDE_DROITE, BATIMENTS.size() + 1,
			PLATANES.size(), REVERBERES.size(), "oui" if _nuit else "non", _humeur],
		"PX0 gerard pieds=%d,%d" % [int(_g_x), PIEDS],
	])
