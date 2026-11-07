class_name Piece
extends Node2D
## Pièce pixel 8 × 8 texels (grille ui/piece, ×3 ; docs/16 §3.4) ; rotation simulée par scale.x.
## Or pour l'argent, cuivre pour les frais (13 §3.2) : substitution de couleurs de la palette.

var cuivre := false
var _t := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _draw() -> void:
	var tex := CadresPixel.texture("piece", 3, {"or": "cuivre", "lumiere": "terre_cuite_claire", "caramel": "bois"} if cuivre else {})
	draw_texture(tex, -tex.get_size() / 2.0)


func _process(delta: float) -> void:
	_t += delta
	scale.x = maxf(0.15, absf(cos(_t * 12.0)))


func voler(depart: Vector2, arrivee: Vector2, duree: float, delai: float, a_l_arrivee: Callable) -> void:
	visible = false
	var controle := (depart + arrivee) / 2.0 + Vector2(0, -120)
	var deplacer := func(u: float) -> void: position = depart.lerp(controle, u).lerp(controle.lerp(arrivee, u), u)
	var arriver := func() -> void:
		if a_l_arrivee.is_valid():
			a_l_arrivee.call()
		queue_free()
	var t := create_tween()
	t.tween_interval(delai)
	t.tween_callback(func() -> void: visible = true)
	t.tween_method(deplacer, 0.0, 1.0, duree).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(arriver)
