class_name RuePx0
extends Node2D
## Le monde de la preuve de concept pixel (lot PX0, docs/16 §2.6 et §5.1), en px d'art.
## Repères (y vers le bas) : bas des façades = SOL (312), trottoir 312-320, chaussée 320-336,
## jardinet x 0-24, maison de Gérard x 24-120 (96 × 124, cheminée à y 188).
## Étape A : squelette (ciel en bandes, trottoirs, chaussée, mécanisme jour / nuit, planche) ;
## étape B : maison, voisins, platane, réverbère, Gérard, Sylvie, R5.
##
## Jour / nuit : chaque élément est dessiné par une Couche à partir des images de GrillePixel ;
## pendant le fondu, la version nuit est posée sur la version jour avec un alpha croissant
## (élément par élément, pour respecter l'ordre de superposition). Fondu terminé : une seule version.

const SOL := 312
const TROTTOIR := 8
const CHAUSSEE := 16
const BAS_CHAUSSEE := SOL + TROTTOIR + CHAUSSEE          # 336
const MONDE_GAUCHE := -480
const MONDE_DROITE := 800                               # décor sur 1 280 px d'art
const HAUTEUR_CIEL := 440                               # ciel de y = SOL + 8 - 440 à SOL + 8
const MAISON := Rect2(24, 188, 96, 124)
const ZONE := Rect2(0, 188, 256, 148)                   # cheminée → bas de la chaussée, jardinet → façade voisine
const TAILLE_GERARD := Vector2i(16, 28)
const FONDU := 3.0

var _melange := 0.0          # 0 = jour, 1 = nuit
var _nuit := false
var _humeur := 0
var _fige := false
var _lumieres_visibles := true
var _tween: Tween = null
var _couches: Array = []
var _lumieres: Node2D = null
var _planche: Node2D = null


## Élément dessiné en version jour et nuit. ops : liste de dictionnaires
## {"image": nom, "pos": Vector2i, "repeter_x": int (largeur à couvrir, 0 = une fois)}
## ou {"rect": Rect2i, "couleur": nom de palette}.
class Couche extends Node2D:
	var rue: RuePx0
	var ops: Array = []

	func image(nom: String, pos: Vector2i, repeter_x := 0) -> void:
		ops.append({"image": nom, "pos": pos, "repeter_x": repeter_x})
		queue_redraw()

	func rect(r: Rect2i, couleur: String) -> void:
		ops.append({"rect": r, "couleur": couleur})
		queue_redraw()

	func _draw() -> void:
		var m := rue.melange()
		for op in ops:
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


func _init() -> void:
	name = "RuePx0"


func _ready() -> void:
	if not GrillePixel.existe("matiere/ciel"):
		MatieresPixel.generer_tout()
	_construire()
	set_process(false)


func _construire() -> void:
	var largeur := MONDE_DROITE - MONDE_GAUCHE
	# Ciel (plan 0) : de haut en bas jusqu'au bas du trottoir (caché par les façades)
	var ciel := _couche("Ciel")
	ciel.rect(Rect2i(MONDE_GAUCHE, SOL + TROTTOIR - HAUTEUR_CIEL - 400, largeur, 400), "bleu_nuit")
	ciel.image("matiere/ciel", Vector2i(MONDE_GAUCHE, SOL + TROTTOIR - 1), largeur)
	# Étape B : immeubles de fond, façade voisine, platane, maison, réverbère (couches entre ciel et sol)
	# Sol : trottoir, chaussée, trottoir d'en face, puis remplissage sous la frise
	var sol := _couche("Sol")
	sol.image("matiere/trottoir", Vector2i(MONDE_GAUCHE, SOL), largeur)
	sol.image("matiere/chaussee", Vector2i(MONDE_GAUCHE, SOL + TROTTOIR), largeur)
	sol.image("matiere/trottoir", Vector2i(MONDE_GAUCHE, BAS_CHAUSSEE), largeur)
	sol.rect(Rect2i(MONDE_GAUCHE, BAS_CHAUSSEE + TROTTOIR, largeur, 400), "ardoise_sombre")
	# Calque des lumières (mélange additif), visible la nuit seulement
	_lumieres = Node2D.new()
	_lumieres.name = "Lumieres"
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_lumieres.material = mat
	_lumieres.z_index = 50
	add_child(_lumieres)
	_maj_lumieres()


func _couche(n: String) -> Couche:
	var c := Couche.new()
	c.name = n
	c.rue = self
	add_child(c)
	_couches.append(c)
	return c


func melange() -> float:
	return _melange


func _set_melange(v: float) -> void:
	_melange = clampf(v, 0.0, 1.0)
	for c in _couches:
		c.queue_redraw()
	_maj_lumieres()


func _maj_lumieres() -> void:
	if _lumieres != null:
		_lumieres.visible = _lumieres_visibles and _melange > 0.0
		_lumieres.modulate = Color(1, 1, 1, _melange)


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


## Humeur de Sylvie à la fenêtre : 0 contente, 1 neutre, 2 contrariée (dessin : étape B).
func regler_humeur_sylvie(h: int) -> void:
	_humeur = clampi(h, 0, 2)


func humeur_sylvie() -> int:
	return _humeur


## Arrête (ou relance) ce qui bouge : marche, voiture, nuages, clignements. Le fondu jour / nuit continue.
func figer(f: bool) -> void:
	_fige = f


func est_fige() -> bool:
	return _fige


## Pose déterministe pour les captures (Gérard devant la maison, nuages et R5 placés : étape B).
func preparer_capture() -> void:
	pass


## Affiche ou masque le calque additif (masqué pendant le contrôle de palette).
func afficher_lumieres(v: bool) -> void:
	_lumieres_visibles = v
	_maj_lumieres()


## Point d'ancrage de l'étiquette « MA MAISON » : sur la chaussée, sous le milieu de la maison.
func point_etiquette_maison() -> Vector2:
	return Vector2(MAISON.get_center().x, SOL + TROTTOIR + CHAUSSEE / 2.0)


func taille_gerard() -> Vector2i:
	return TAILLE_GERARD


## Planche des sprites (étape « planche ») : fond crème couvrant la vue, sprites de data/pixel/ville
## agrandis ×2 en px d'art (×6 à l'écran en 1080), rangés de gauche à droite.
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
	var marge := 12
	var x := int(vue.position.x) + marge
	var y := int(vue.position.y) + 40
	var hauteur_rangee := 0
	for n in sprites_planche():
		var tex := GrillePixel.texture(n)
		var t := tex.get_size() * 2
		if x + t.x > vue.end.x - marge and x > int(vue.position.x) + marge:
			x = int(vue.position.x) + marge
			y += hauteur_rangee + 12
			hauteur_rangee = 0
		var s := Sprite2D.new()
		s.texture = tex
		s.centered = false
		s.scale = Vector2(2, 2)
		s.position = Vector2(x, y)
		_planche.add_child(s)
		x += int(t.x) + 12
		hauteur_rangee = maxi(hauteur_rangee, int(t.y))


## Sprites montrés sur la planche, dans l'ordre (étape B : Gérard 4 + 2, Sylvie 3 humeurs, M. Lefranc, R5).
func sprites_planche() -> PackedStringArray:
	var liste := PackedStringArray()
	for n in GrillePixel.noms():
		if n.begins_with("ville/"):
			liste.append(n)
	return liste


## Lignes « PX0 … » propres au monde (imprimées par px0.gd avec --px0-controle).
func lignes_controle() -> PackedStringArray:
	return PackedStringArray([
		"PX0 rue zone=%dx%d sprites_ville=%d nuit=%s" % [int(ZONE.size.x), int(ZONE.size.y), sprites_planche().size(), "oui" if _nuit else "non"],
	])
