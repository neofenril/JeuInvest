extends Node2D
## Accessoire pixel des séquences (lot PX1) : une ou plusieurs images du catalogue (« objet/… »), animées à
## « cadence » images par seconde, posées à des positions entières (pos), jamais tournées ni agrandies.
## une_fois : libéré après la dernière image. alpha : transparence d'affichage (fondu de sortie).

var rue: Node2D
var images: Array = []
var cadence := 0.0
var une_fois := false
var image := 0:
	set(v):
		image = v
		queue_redraw()
var alpha := 1.0:
	set(v):
		alpha = v
		queue_redraw()
var pos := Vector2.ZERO:
	set(v):
		pos = v
		var p := v.round()
		if position != p:
			position = p
var _t := 0.0


func _process(delta: float) -> void:
	if cadence <= 0.0 or images.size() < 2:
		return
	_t += delta
	if _t >= 1.0 / cadence:
		_t -= 1.0 / cadence
		if une_fois and image >= images.size() - 1:
			liberer()
			return
		image = (image + 1) % images.size()


func liberer() -> void:
	if rue != null:
		rue.call("oublier", self)
	queue_free()


func _draw() -> void:
	if rue == null or images.is_empty():
		return
	rue.image(self, String(images[clampi(image, 0, images.size() - 1)]), Vector2i.ZERO, alpha)
