extends Node2D
## Passant en « gélule » (09 §2.2) : corps arrondi à 2 couleurs, tête ronde, rebond de marche.
## Années 1986-1988 : épaulettes (corps plus large en haut) et walkman (point jaune).

var corps := Color("3f6fb5")
var bas := Color("2d3446")
var peau := Color("f1c9a5")
var cheveux := Color("4a3426")
var vitesse := 50.0
var walkman := false
var ville: Node = null
var arrete := false           # le passant s'arrête et regarde le média (krach)
var _phase := 0.0
const BORNE := 1700.0


func _process(delta: float) -> void:
	if ville == null or ville.facteur_trafic <= 0.0:
		return
	if arrete:
		_phase = 0.0
		queue_redraw()
		return
	# Les passants suivent le trafic à moitié : ils pressent le pas sans courir.
	var f: float = ville.facteur_trafic
	var v: float = vitesse * (f if f <= 1.0 else 1.0 + (f - 1.0) * 0.5)
	position.x += v * delta * signf(scale.x)
	_phase += delta * v / 9.0
	if position.x > BORNE:
		position.x = -BORNE
	elif position.x < -BORNE:
		position.x = BORNE
	queue_redraw()


func _draw() -> void:
	var rebond := absf(sin(_phase)) * 3.0
	var pas := sin(_phase) * 7.0
	draw_rect(Rect2(-14, -3, 28, 6), Color(0, 0, 0, 0.2))
	# Jambes
	draw_line(Vector2(-4, -24 - rebond), Vector2(-4 + pas, 0), bas, 7.0, true)
	draw_line(Vector2(4, -24 - rebond), Vector2(4 - pas, 0), bas.darkened(0.15), 7.0, true)
	# Corps en gélule, épaulettes
	var y0 := -60.0 - rebond
	Dessin.arrondi(self, Rect2(-13, y0, 26, 40), corps, 12)
	Dessin.arrondi(self, Rect2(-16, y0, 32, 12), corps.lightened(0.06), 6)
	draw_rect(Rect2(4, y0 + 6, 9, 30), corps.darkened(0.2))
	if walkman:
		draw_circle(Vector2(10, y0 + 30), 4, Color("ffd34d"))
		draw_line(Vector2(10, y0 + 28), Vector2(4, y0 - 6), Color("2a2a2a"), 1.5)
	# Tête (levée vers le média quand le passant est arrêté)
	var tete := Vector2(1, y0 - 12) + (Vector2(2, -3) if arrete else Vector2.ZERO)
	draw_circle(tete, 11, peau)
	draw_arc(tete, 11, PI * 1.05, PI * 1.95, 12, cheveux, 7.0)
	draw_circle(tete + Vector2(5, -1), 1.6, Color("2a2a2a"))
