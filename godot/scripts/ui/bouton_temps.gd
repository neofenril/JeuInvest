class_name BoutonTemps
extends Button
## Bouton de contrôle du temps, bouton pixel avec icône 16 × 16 (data/pixel/ui/icones.txt) :
## « pause », « x1 », « x2 », « x3 » ; sur téléphone « lecture » (lecture / pause) et « cycle » (×1 → ×2 → ×3).
## Bascule : actif = bouton ambre, icône nuit.

var genre := "x1"
var vitesse_cycle := 1


func _init(g: String = "x1") -> void:
	genre = g
	custom_minimum_size = Vector2(84, 84)
	toggle_mode = genre != "lecture" and genre != "cycle"
	theme_type_variation = "BoutonBascule"
	focus_mode = Control.FOCUS_NONE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pivot_offset = Vector2(42, 42)
	button_down.connect(func() -> void: create_tween().tween_property(self, "scale", Vector2.ONE * 0.95, 0.06))
	button_up.connect(func() -> void: create_tween().tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))


func _draw() -> void:
	var actif := button_pressed
	var nom := ""
	match genre:
		"pause":
			nom = "pause"
		"x1":
			nom = "lecture"
		"x2":
			nom = "x2"
		"x3":
			nom = "x3"
		"lecture":
			nom = "lecture" if Partie.vitesse == 0 else "pause"
		"cycle":
			var t := "×%d" % vitesse_cycle
			var police := Style.chiffres()
			var w := police.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 34).x
			draw_string(police, Vector2((size.x - w) / 2.0, size.y / 2.0 + 9.0), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Style.TEXTE)
			return
	var tex := CadresPixel.texture(nom, CadresPixel.ECHELLE, {"creme": "nuit"} if actif else {})
	# Le contenu descend d'un texel quand le bouton est enfoncé (relief du cadre) ; coordonnées au texel
	var p := ((size - tex.get_size()) / 2.0 / 3.0).floor() * 3.0 + Vector2(0, 3 if actif else -3)
	draw_texture(tex, p)
