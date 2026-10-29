class_name Pastilles
extends Control
## Note de 1 à 3 en pastilles (13 §1.1) : ●●○. La couleur ne porte jamais seule le sens (le mot est à côté).

var note := 0
var couleur := Style.ACCENT


static func creer(n: int, c: Color) -> Pastilles:
	var p := Pastilles.new()
	p.note = n
	p.couleur = c
	return p


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(66, 28)
	size_flags_vertical = Control.SIZE_SHRINK_CENTER


func _draw() -> void:
	var y := size.y / 2.0
	for i in 3:
		var c := Vector2(10.0 + i * 22.0, y)
		if i < note:
			draw_circle(c, 8.0, couleur)
		else:
			draw_arc(c, 7.0, 0.0, TAU, 20, Color(Style.TEXTE_2, 0.6), 2.0, true)
