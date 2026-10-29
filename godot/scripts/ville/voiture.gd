extends Node2D
## Voiture de profil (09 §2.2) : caisse carrée des années 1980 (R5, 205), vitres, 2 roues qui tournent.
## Origine = point de contact au sol, au centre. scale.x = -1 pour rouler vers la gauche.

var couleur := Color("c8382e")
var vitesse := 150.0          # unités par seconde (0 = garée)
var ville: Node = null
var capot := 0.0              # 0 fermé → 1 ouvert (panne)
var bosse := 0.0              # 0 → 1 : avant cabossé (accrochage de la panne)
var sans_enjoliveur := false  # l'enjoliveur avant s'est fait la malle
var _roue := 0.0
const BORNE := 1700.0


func _process(delta: float) -> void:
	if vitesse == 0.0 or ville == null or ville.facteur_trafic <= 0.0:
		return
	var v: float = vitesse * ville.facteur_trafic
	position.x += v * delta * signf(scale.x)
	_roue += v * delta / 12.0
	if position.x > BORNE:
		position.x = -BORNE
	elif position.x < -BORNE:
		position.x = BORNE
	queue_redraw()


func _draw() -> void:
	var sombre := couleur.darkened(0.2)
	draw_rect(Rect2(-60, -4, 124, 8), Color(0, 0, 0, 0.25))
	# Caisse basse et habitacle
	Dessin.arrondi(self, Rect2(-66, -42, 132, 30), couleur, 7)
	draw_rect(Rect2(-66, -20, 132, 8), sombre)
	Dessin.poly(self, [Vector2(-44, -40), Vector2(-32, -66), Vector2(30, -66), Vector2(48, -40)], couleur)
	Dessin.poly(self, [Vector2(-30, -42), Vector2(-21, -61), Vector2(-2, -61), Vector2(-2, -42)], Color("a9cbe0"))
	Dessin.poly(self, [Vector2(4, -42), Vector2(4, -61), Vector2(26, -61), Vector2(40, -42)], Color("a9cbe0"))
	# Pare-chocs, phares, feux
	draw_rect(Rect2(-70, -24, 10, 8), Color("2f3138"))
	draw_rect(Rect2(-66, -38, 5, 8), Color("c0302a"))
	if bosse > 0.01:
		# Avant enfoncé : pare-chocs de travers, phare éteint et fêlé, tôle froissée
		draw_set_transform(Vector2(60, -20), 0.35 * bosse)
		draw_rect(Rect2(-4 * bosse, -4, 10, 8), Color("2f3138"))
		draw_set_transform(Vector2.ZERO)
		draw_rect(Rect2(60, -38, 6, 8), Color("8a8a80"))
		draw_line(Vector2(60, -37), Vector2(66, -31), Color("2f3138"), 1.5)
		Dessin.poly(self, [Vector2(66, -42), Vector2(66, -30), Vector2(66 - 9 * bosse, -36)], couleur.darkened(0.35))
	else:
		draw_rect(Rect2(60, -24, 10, 8), Color("2f3138"))
		draw_rect(Rect2(60, -38, 6, 8), Color("f6f0c8"))
	# Capot qui se soulève (panne)
	if capot > 0.01:
		draw_set_transform(Vector2(14, -42), -capot * 0.7)
		draw_rect(Rect2(0, -4, 52, 6), sombre)
		draw_set_transform(Vector2.ZERO)
	# Roues
	for rx in [-38.0, 40.0]:
		var c := Vector2(rx, -12)
		draw_circle(c, 13, Color("23242a"))
		if sans_enjoliveur and rx > 0.0:
			draw_circle(c, 6, Color("4a4c52"))
			continue
		draw_circle(c, 6, Color("9a9ea8"))
		for k in 3:
			var a := _roue + k * TAU / 3.0
			draw_line(c, c + Vector2.from_angle(a) * 6.0, Color("55585f"), 2.0)


func dessiner_lumieres(ci: CanvasItem, nuit: float) -> void:
	if nuit < 0.3:
		return
	var a := (nuit - 0.3) / 0.7
	var phare := Vector2(66 * signf(scale.x), -34)
	ci.draw_colored_polygon(PackedVector2Array([phare, phare + Vector2(150 * signf(scale.x), -18), phare + Vector2(150 * signf(scale.x), 30)]), Color(1, 0.95, 0.75, 0.18 * a))
	Dessin.halo(ci, phare, 14, Color(1, 0.95, 0.75, 0.7 * a))
