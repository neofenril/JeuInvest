class_name Portrait
extends Control
## Portrait du banquier M. Lefranc en formes simples (09 §3.1) : visage, cheveux, larges lunettes,
## moustache, col et cravate large des années 1980. La bouche s'ouvre pendant qu'il parle.

var bouche := 0.0


func _init() -> void:
	custom_minimum_size = Vector2(120, 120)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var c := size / 2.0
	var r := minf(size.x, size.y) / 2.0
	draw_circle(c, r, Color("2e3b55"))
	draw_circle(c, r - 3, Color("3a4a6a"))
	# Épaules, veste, col, cravate
	var bas := c.y + r
	draw_colored_polygon(PackedVector2Array([Vector2(c.x - 50, bas - 8), Vector2(c.x - 40, c.y + 30), Vector2(c.x + 40, c.y + 30), Vector2(c.x + 50, bas - 8), Vector2(c.x, bas)]), Color("2c3347"))
	draw_colored_polygon(PackedVector2Array([Vector2(c.x - 16, c.y + 28), Vector2(c.x, c.y + 42), Vector2(c.x + 16, c.y + 28), Vector2(c.x, c.y + 56)]), Color("f3efe6"))
	draw_colored_polygon(PackedVector2Array([Vector2(c.x - 7, c.y + 36), Vector2(c.x + 7, c.y + 36), Vector2(c.x + 11, c.y + 58), Vector2(c.x, c.y + 64), Vector2(c.x - 11, c.y + 58)]), Color("b3261e"))
	# Cou et visage
	draw_rect(Rect2(c.x - 9, c.y + 14, 18, 18), Color("e3b48e"))
	draw_circle(c + Vector2(0, -4), 30, Color("f1c9a5"))
	draw_circle(c + Vector2(-30, -2), 6, Color("e3b48e"))
	draw_circle(c + Vector2(30, -2), 6, Color("e3b48e"))
	# Cheveux (raie sur le côté)
	draw_arc(c + Vector2(0, -6), 29, PI * 1.02, PI * 1.98, 20, Color("5b4330"), 12.0, true)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-28, -14), c + Vector2(-6, -34), c + Vector2(18, -32), c + Vector2(-10, -24)]), Color("5b4330"))
	# Larges lunettes
	for dx in [-12.0, 12.0]:
		Dessin.arrondi(self, Rect2(c.x + dx - 10, c.y - 12, 20, 15), Color(0.85, 0.92, 1.0, 0.35), 5)
		draw_rect(Rect2(c.x + dx - 10, c.y - 12, 20, 15), Color("2a2a2a"), false, 2.5)
	draw_line(c + Vector2(-2, -6), c + Vector2(2, -6), Color("2a2a2a"), 2.5)
	draw_circle(c + Vector2(-12, -5), 2.2, Color("2a2a2a"))
	draw_circle(c + Vector2(12, -5), 2.2, Color("2a2a2a"))
	# Moustache et bouche
	draw_colored_polygon(PackedVector2Array([c + Vector2(-14, 10), c + Vector2(0, 6), c + Vector2(14, 10), c + Vector2(10, 14), c + Vector2(0, 11), c + Vector2(-10, 14)]), Color("5b4330"))
	var h := 2.0 + 6.0 * bouche
	draw_rect(Rect2(c.x - 6, c.y + 15, 12, h), Color("7a2a24"))
