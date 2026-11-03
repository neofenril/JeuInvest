class_name Batiment
extends Node2D
## Base des 3 bâtiments jouables de la rue pixel (lot PX1) : façade (image du catalogue, dans les variantes de
## palette du moment), vitres allumées la nuit, neige en hiver, contour d'1 px d'art couleur or au survol,
## enfoncement d'1 px à l'appui. position = milieu du pied de la façade, au niveau du sol (y = SOL).
## zone : rectangle de toucher en coordonnées locales (la façade entière).

signal touche

const RUE := preload("res://scripts/ville/rue.gd")

var id := ""
var nom := ""
var zone := Rect2()
var rue: Node2D               # monde (rue.gd) : dessin dans les variantes
var image_nom := ""
var nuit := 0.0               # compatibilité (lu par la ville)
var hiver := false
var annee := 1986
var _survol := false
var _enfonce := 0
var _taille := Vector2i.ZERO
var _vitres: Array = []       # Rect2i locaux (coin haut gauche de l'image = origine)


func _ready() -> void:
	_taille = GrillePixel.taille(image_nom)
	zone = Rect2(-_taille.x / 2, -_taille.y, _taille.x, _taille.y)
	var coin := coin_image()
	for r in RUE.fenetres(image_nom):
		_vitres.append(Rect2i(coin + r.position, r.size))


## Coin haut gauche de l'image, en coordonnées locales.
func coin_image() -> Vector2i:
	return Vector2i(-_taille.x / 2, -_taille.y)


func taille() -> Vector2i:
	return _taille


func contient(point_local: Vector2) -> bool:
	return zone.has_point(point_local)


func survoler(oui: bool) -> void:
	if oui == _survol:
		return
	_survol = oui
	if oui and not GrillePixel.existe("contour/" + image_nom):
		GrillePixel.enregistrer("contour/" + image_nom, _contour(GrillePixel.image(image_nom)), GrillePixel.origine(image_nom) + Vector2i(1, 1))
	queue_redraw()


func enfoncer() -> void:
	_enfonce = 1
	queue_redraw()
	get_tree().create_timer(0.12).timeout.connect(_relever)


func _relever() -> void:
	_enfonce = 0
	queue_redraw()


func _draw() -> void:
	var d := Vector2i(0, _enfonce)
	if _survol and GrillePixel.existe("contour/" + image_nom):
		var tex := GrillePixel.texture("contour/" + image_nom)
		draw_texture(tex, Vector2(d - GrillePixel.origine("contour/" + image_nom)))
	rue.image(self, image_nom, d)
	for r in _vitres:
		rue.lumiere_nuit(self, Rect2i(r.position + d, r.size))
	if hiver:
		rue.image(self, "neige/" + image_nom, d)
	_dessiner_dessus(d)


## À surcharger : éléments animés posés sur la façade (d = décalage d'enfoncement).
func _dessiner_dessus(_d: Vector2i) -> void:
	pass


## Compatibilité (ancienne ville) : les lumières sont désormais dans la rue.
func dessiner_lumieres(_ci: CanvasItem) -> void:
	pass


static func fenetre_allumee(nuit_v: float, seuil: float) -> float:
	return clampf((nuit_v - seuil) * 6.0, 0.0, 1.0)


## Contour extérieur d'1 px couleur or (image agrandie de 1 px de chaque côté).
static func _contour(img: Image) -> Image:
	var l := img.get_width()
	var h := img.get_height()
	var src := Image.new()
	src.copy_from(img)
	src.convert(Image.FORMAT_RGBA8)
	var d := src.get_data()
	var sortie := MatieresPixel.vide(l + 2, h + 2)
	var c := PalettePixel.couleur("or")
	for y in range(-1, h + 1):
		for x in range(-1, l + 1):
			if x >= 0 and y >= 0 and x < l and y < h and d[(y * l + x) * 4 + 3] != 0:
				continue
			var voisin := false
			for v in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var q: Vector2i = Vector2i(x, y) + v
				if q.x >= 0 and q.y >= 0 and q.x < l and q.y < h and d[(q.y * l + q.x) * 4 + 3] != 0:
					voisin = true
					break
			if voisin:
				sortie.set_pixel(x + 1, y + 1, c)
	return sortie
