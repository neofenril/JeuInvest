class_name Piece
extends Node2D
## Pièce dessinée (09 §3, effet 6) : disque, liseré, reflet ; rotation simulée par scale.x.
## Or pour l'argent, cuivre pour les frais (13 §3.2).

var cuivre := false
var _t := 0.0


func _draw() -> void:
	var fond := Style.CUIVRE_LISERE if cuivre else Style.OR_OMBRE
	var face := Style.CUIVRE if cuivre else Style.OR
	draw_circle(Vector2.ZERO, 14.0, fond)
	draw_circle(Vector2(0, -1), 12.0, face)
	draw_arc(Vector2(0, -1), 8.0, 0.0, TAU, 24, fond, 2.0, true)
	draw_circle(Vector2(-4, -5), 3.0, Color(1, 1, 1, 0.5))


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
