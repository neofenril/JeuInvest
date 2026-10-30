class_name ModaleOutils
extends RefCounted
## Outils communs aux morceaux de Modales (T9) : bouton papier, filet, flèche, croix, pictogramme de source,
## trait en travers. Fonctions statiques, sans état.


static func bouton_papier(titre: String, sous: String, petit: bool) -> Button:
	var b := Button.new()
	b.text = titre + ("\n" + sous if sous != "" else "")
	b.custom_minimum_size = Vector2(0, 80 if petit else 96)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.focus_mode = Control.FOCUS_ALL
	b.add_theme_font_override("font", Style.ui_gras())
	b.add_theme_font_size_override("font_size", 22 if petit else 24)
	var n := Style.boite(Color("2a2722"), 10, 16, 8)
	Style.bordure(n, Color("000000"), 0, 0, 0, 4)
	var h := Style.boite(Style.ENCRE_ROUGE, 10, 16, 8)
	Style.bordure(h, Style.ENCRE_ROUGE.darkened(0.3), 0, 0, 0, 4)
	b.add_theme_stylebox_override("normal", n)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("pressed", h)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("disabled", Style.boite(Color("2a2722", 0.4), 10, 16, 8))
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(k, Style.JOURNAL)
	return b


static func filet(c: Color, epaisseur: int) -> ColorRect:
	var r := ColorRect.new()
	r.color = c
	r.custom_minimum_size = Vector2(0, epaisseur)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


## Petite flèche ▲ / ▼ dessinée (pas de caractère Unicode, 09 §3).
static func fleche(haut: bool, c: Color) -> Control:
	var f := Control.new()
	f.custom_minimum_size = Vector2(18, 24)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	f.draw.connect(_dessiner_fleche.bind(f, haut, c))
	return f


static func _dessiner_fleche(f: Control, haut: bool, c: Color) -> void:
	var m := f.size / 2.0
	var pts := PackedVector2Array([m + Vector2(-8, 5), m + Vector2(8, 5), m + Vector2(0, -8)]) if haut else PackedVector2Array([m + Vector2(-8, -5), m + Vector2(8, -5), m + Vector2(0, 8)])
	f.draw_colored_polygon(pts, c)


static func dessiner_croix(b: Button) -> void:
	var m := b.size / 2.0
	b.draw_line(m + Vector2(-12, -12), m + Vector2(12, 12), Style.TEXTE, 4.0, true)
	b.draw_line(m + Vector2(12, -12), m + Vector2(-12, 12), Style.TEXTE, 4.0, true)


## Trait en travers d'un montant hypothétique (somme qui n'a pas été versée).
static func barrer(l: Label) -> void:
	var y := l.size.y * 0.55
	l.draw_line(Vector2(0, y), Vector2(l.size.x, y), Color(Style.TEXTE_2, 0.9), 3.0, true)


## Pastille ronde de la source, avec son pictogramme dessiné (maison, banque à colonnes, journal).
static func pictogramme_source(source: String, d: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(d, d)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(_dessiner_pictogramme.bind(c, source))
	return c


static func _dessiner_pictogramme(c: Control, source: String) -> void:
	var m := c.size / 2.0
	var r := minf(c.size.x, c.size.y) / 2.0
	var coul: Color = Style.SOURCES.get(source, Style.ACCENT)
	c.draw_circle(m, r, Color(coul, 0.22))
	c.draw_arc(m, r - 1.0, 0.0, TAU, 32, coul, 2.0, true)
	var k := r / 24.0
	var blanc := Style.TEXTE
	match source:
		"maison":
			c.draw_colored_polygon(PackedVector2Array([m + Vector2(-13, -1) * k, m + Vector2(0, -13) * k, m + Vector2(13, -1) * k]), coul)
			c.draw_rect(Rect2(m + Vector2(-9, -1) * k, Vector2(18, 13) * k), blanc)
			c.draw_rect(Rect2(m + Vector2(-3, 4) * k, Vector2(6, 8) * k), coul)
		"banque":
			c.draw_colored_polygon(PackedVector2Array([m + Vector2(-14, -6) * k, m + Vector2(0, -14) * k, m + Vector2(14, -6) * k]), coul)
			for i in 4:
				c.draw_rect(Rect2(m + Vector2(-11 + i * 6.5, -4) * k, Vector2(3.5, 13) * k), blanc)
			c.draw_rect(Rect2(m + Vector2(-14, 10) * k, Vector2(28, 3) * k), blanc)
		_:
			c.draw_rect(Rect2(m + Vector2(-12, -11) * k, Vector2(24, 22) * k), blanc)
			c.draw_rect(Rect2(m + Vector2(-9, -8) * k, Vector2(18, 4) * k), coul)
			for i in 3:
				c.draw_rect(Rect2(m + Vector2(-9, -1 + i * 4) * k, Vector2(18 - (i % 2) * 6, 2) * k), Color(Style.ENCRE, 0.7))
