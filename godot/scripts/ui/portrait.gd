class_name Portrait
extends Control
## Portrait pixel de M. Lefranc (docs/16 §5.3) : grille 48 × 48 « ville/lefranc_affable » ou
## « ville/lefranc_grave » (data/pixel/ville/lefranc.txt, lecture seule), agrandie à un nombre entier de
## texels, dans un cadre crème. Pendant qu'il parle (bouche > 0), il cligne et la tête bouge d'un texel.
## Grille absente : cadre crème vide, sans erreur.

var bouche := 0.0
var expression := "affable"     # « affable » ou « grave » (décès, krach)


func _init() -> void:
	custom_minimum_size = Vector2(120, 120)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


static func _texture(nom: String) -> Texture2D:
	if not GrillePixel.existe("ville/" + nom):
		GrillePixel.charger_dossier("ville")
	return GrillePixel.texture("ville/" + nom) if GrillePixel.existe("ville/" + nom) else null


func _draw() -> void:
	var cote := minf(size.x, size.y)
	var k := maxf(1.0, floorf(cote / 52.0))           # texels entiers ; 2 texels de cadre de chaque côté
	var cadre := Rect2(Vector2.ZERO, Vector2(52, 52) * k)
	draw_rect(cadre, PalettePixel.couleur("encre"))
	draw_rect(cadre.grow(-k), PalettePixel.couleur("pierre_claire"))
	draw_rect(cadre.grow(-2.0 * k), PalettePixel.couleur("creme"))
	var nom := "lefranc_" + expression
	if bouche > 0.0 and fmod(Time.get_ticks_msec() / 1000.0, 2.4) < 0.12:
		nom = "lefranc_yeux_fermes"
	var t := _texture(nom)
	if t == null:
		return
	var decalage := Vector2(0, -k) if bouche > 0.6 else Vector2.ZERO
	draw_texture_rect(t, Rect2(Vector2(2, 2) * k + decalage, Vector2(48, 48) * k), false)
