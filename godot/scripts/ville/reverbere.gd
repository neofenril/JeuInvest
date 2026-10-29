extends Node2D
## Réverbère du premier plan (origine au pied). Son halo est dessiné par le calque de lumière.

const FONTE := Color("33373f")


func _draw() -> void:
	draw_rect(Rect2(-10, -6, 20, 8), FONTE)
	draw_rect(Rect2(-4, -250, 8, 246), FONTE)
	draw_rect(Rect2(-6, -120, 12, 6), FONTE.lightened(0.1))
	draw_line(Vector2(0, -246), Vector2(26, -262), FONTE, 5.0, true)
	Dessin.poly(self, [Vector2(14, -262), Vector2(40, -262), Vector2(34, -244), Vector2(20, -244)], FONTE)
	draw_rect(Rect2(20, -246, 14, 6), Color("e8dcb8"))


func dessiner_lumieres(ci: CanvasItem, nuit: float) -> void:
	if nuit < 0.2:
		return
	var a := clampf((nuit - 0.2) * 2.0, 0.0, 1.0)
	var p := Vector2(27, -242)
	Dessin.halo(ci, p, 120, Color(1.0, 0.82, 0.48, 0.35 * a))
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-8, 0), p + Vector2(8, 0), p + Vector2(70, 240), p + Vector2(-70, 240)]), Color(1.0, 0.85, 0.5, 0.07 * a))
	ci.draw_circle(p, 6, Color(1.0, 0.92, 0.7, a))
