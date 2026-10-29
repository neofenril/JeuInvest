class_name BoutonTemps
extends Button
## Bouton de contrôle du temps, icône dessinée (pas de caractère Unicode, 09 §3) :
## « pause », « x1 », « x2 », « x3 » ; sur téléphone « lecture » (▶ / ❚❚) et « cycle » (×1 → ×2 → ×3).

var genre := "x1"
var vitesse_cycle := 1


func _init(g: String = "x1") -> void:
	genre = g
	custom_minimum_size = Vector2(80, 80)
	toggle_mode = genre != "lecture" and genre != "cycle"
	theme_type_variation = "BoutonBascule"
	focus_mode = Control.FOCUS_NONE
	pivot_offset = Vector2(40, 40)
	button_down.connect(func() -> void: create_tween().tween_property(self, "scale", Vector2.ONE * 0.95, 0.06))
	button_up.connect(func() -> void: create_tween().tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))


func _draw() -> void:
	var c := Style.ENCRE_ACCENT if button_pressed else Style.TEXTE
	var m := size / 2.0
	match genre:
		"pause":
			_pause(m, c)
		"x1":
			_triangles(m, 1, c)
		"x2":
			_triangles(m, 2, c)
		"x3":
			_triangles(m, 3, c)
		"lecture":
			if Partie.vitesse == 0:
				_triangles(m, 1, c)
			else:
				_pause(m, c)
		"cycle":
			var t := "×%d" % vitesse_cycle
			Dessin.texte(self, Style.chiffres(), m + Vector2(0, 12), t, 34, c)


func _pause(m: Vector2, c: Color) -> void:
	Dessin.arrondi(self, Rect2(m.x - 12, m.y - 15, 8, 30), c, 2)
	Dessin.arrondi(self, Rect2(m.x + 4, m.y - 15, 8, 30), c, 2)


func _triangles(m: Vector2, n: int, c: Color) -> void:
	var w := 18.0 if n > 1 else 24.0
	var h := 26.0 if n > 1 else 30.0
	var total := w * n - (n - 1) * 4.0
	var x0 := m.x - total / 2.0
	for i in n:
		var x := x0 + i * (w - 4.0)
		draw_colored_polygon(PackedVector2Array([Vector2(x, m.y - h / 2.0), Vector2(x + w, m.y), Vector2(x, m.y + h / 2.0)]), c)
