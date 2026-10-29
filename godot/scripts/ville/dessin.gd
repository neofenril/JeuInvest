class_name Dessin
extends RefCounted
## Petits outils de dessin de la ville (style « diorama en aplats », 09 §2.2) :
## volumes à 2 tons, ombres portées, rectangles arrondis, halos, textes.

const OMBRE := Color(0, 0, 0, 0.25)


static func rect(ci: CanvasItem, r: Rect2, c: Color) -> void:
	ci.draw_rect(r, c)


## Volume à 2 tons : face éclairée + côté droit 20 % plus sombre (largeur « cote »).
static func volume(ci: CanvasItem, r: Rect2, c: Color, cote := 0.0) -> void:
	ci.draw_rect(r, c)
	if cote > 0.0:
		ci.draw_rect(Rect2(r.end.x - cote, r.position.y, cote, r.size.y), c.darkened(0.2))


static func arrondi(ci: CanvasItem, r: Rect2, c: Color, rayon := 6) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(rayon)
	s.anti_aliasing = true
	s.corner_detail = 6
	ci.draw_style_box(s, r)


## Ombre portée au sol, vers la droite (la lumière vient de la gauche).
static func ombre_sol(ci: CanvasItem, x0: float, x1: float, y := 0.0, profondeur := 16.0) -> void:
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x0, y), Vector2(x1, y), Vector2(x1 + profondeur * 2.2, y + profondeur), Vector2(x0 + profondeur * 2.2, y + profondeur)]), OMBRE)


static func poly(ci: CanvasItem, pts: Array, c: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array(pts), c)


static var _tex_halo: GradientTexture2D = null


## Halo radial lisse (texture en dégradé radial), à dessiner dans un calque en mélange additif.
static func halo(ci: CanvasItem, centre: Vector2, rayon: float, c: Color, _pas := 7) -> void:
	if _tex_halo == null:
		var g := Gradient.new()
		g.set_color(0, Color(1, 1, 1, 1))
		g.set_color(1, Color(1, 1, 1, 0))
		g.add_point(0.35, Color(1, 1, 1, 0.45))
		_tex_halo = GradientTexture2D.new()
		_tex_halo.gradient = g
		_tex_halo.fill = GradientTexture2D.FILL_RADIAL
		_tex_halo.fill_from = Vector2(0.5, 0.5)
		_tex_halo.fill_to = Vector2(0.5, 0.0)
		_tex_halo.width = 128
		_tex_halo.height = 128
	ci.draw_texture_rect(_tex_halo, Rect2(centre - Vector2(rayon, rayon), Vector2(rayon, rayon) * 2.0), false, c)


## Texte centré horizontalement sur x (y = ligne de base).
static func texte(ci: CanvasItem, police: Font, centre: Vector2, txt: String, taille: int, c: Color) -> void:
	var largeur := police.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
	ci.draw_string(police, Vector2(centre.x - largeur / 2.0, centre.y), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, taille, c)


## Texte néon : plusieurs passes floues autour du tracé, puis le cœur clair.
static func neon(ci: CanvasItem, police: Font, centre: Vector2, txt: String, taille: int, c: Color, intensite := 1.0) -> void:
	if intensite <= 0.01:
		return
	var largeur := police.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
	var p := Vector2(centre.x - largeur / 2.0, centre.y)
	for r: float in [10.0, 6.0, 3.0]:
		for a in 8:
			var d := Vector2.from_angle(a * TAU / 8.0) * r
			ci.draw_string(police, p + d, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, taille, Color(c, 0.05 * intensite))
	ci.draw_string(police, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, taille, Color(c, 0.9 * intensite))
	ci.draw_string(police, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, taille, Color(c.lightened(0.6), 0.6 * intensite))


## Mélange vers la couleur du ciel (perspective atmosphérique).
static func lointain(c: Color, ciel: Color, part: float) -> Color:
	return c.lerp(ciel, part)
