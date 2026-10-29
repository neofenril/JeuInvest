class_name Batiment
extends Node2D
## Base des 3 bâtiments jouables : zone de toucher, contour lumineux au survol, enfoncement à l'appui,
## lumières (dessinées par le calque additif de la ville via dessiner_lumieres).

signal touche

var id := ""
var nom := ""
var zone := Rect2()          # zone de toucher (coordonnées locales), au moins égale à la façade
var contour: PackedVector2Array = []  # silhouette pour le contour lumineux
var nuit := 0.0              # 0 jour → 1 nuit (fixé par la ville)
var hiver := false
var annee := 1986
var _surbrillance := 0.0
var _base_y := 0.0


func _ready() -> void:
	_base_y = position.y


func contient(point_local: Vector2) -> bool:
	return zone.has_point(point_local)


func survoler(oui: bool) -> void:
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "_surbrillance", 1.0 if oui else 0.0, 0.12)
	t.tween_property(self, "position:y", _base_y - (6.0 if oui else 0.0), 0.12).set_trans(Tween.TRANS_SINE)
	t.tween_method(func(_v: float) -> void: queue_redraw(), 0.0, 1.0, 0.12)


func enfoncer() -> void:
	var t := create_tween()
	t.tween_property(self, "position:y", _base_y + 4.0, 0.06)
	t.tween_property(self, "position:y", _base_y - 6.0 * _surbrillance, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _dessiner_contour() -> void:
	if _surbrillance <= 0.01 or contour.size() < 3:
		return
	var pts := contour.duplicate()
	pts.append(contour[0])
	draw_polyline(pts, Color(Style.ACCENT, 0.35 * _surbrillance), 9.0, true)
	draw_polyline(pts, Color(Style.ACCENT, _surbrillance), 3.0, true)


## À surcharger : lumières non assombries la nuit (fenêtres, enseignes), en mélange additif.
func dessiner_lumieres(_ci: CanvasItem) -> void:
	pass


## Fenêtre allumée selon la nuit et un seuil propre à la fenêtre (elles s'allument une à une).
static func fenetre_allumee(nuit_v: float, seuil: float) -> float:
	return clampf((nuit_v - seuil) * 6.0, 0.0, 1.0)
