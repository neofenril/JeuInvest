extends Node2D
## Plans lointains de la ville (09 §2.3) : « nuages » (0,08), « horizon » (0,15, silhouette de Paris),
## « lointain » (0,4, immeubles haussmanniens et palais Brongniart). Le facteur de parallaxe est appliqué par Ville.

@export var genre := "lointain"
var parallaxe := 0.4
var _derive := 0.0

const SOL := -160.0
const CIEL_BAS := Color("eeddb8")


func _ready() -> void:
	parallaxe = {"nuages": 0.08, "horizon": 0.15, "lointain": 0.4}.get(genre, 1.0)


func _process(delta: float) -> void:
	if genre == "nuages":
		_derive = fmod(_derive + delta * 9.0, 4400.0)
		queue_redraw()


func _draw() -> void:
	match genre:
		"nuages":
			_nuages()
		"horizon":
			_horizon()
		"lointain":
			_lointain()


func _nuages() -> void:
	var c := Color(1, 1, 1, 0.82)
	var ombre := Color(0.86, 0.88, 0.95, 0.82)
	var liste := [[-1500.0, -960.0, 1.0], [-700.0, -1030.0, 0.7], [100.0, -930.0, 1.2], [900.0, -1010.0, 0.8], [1700.0, -950.0, 1.0], [-2300.0, -990.0, 0.9]]
	for n in liste:
		var x: float = fmod(n[0] + _derive + 2200.0, 4400.0) - 2200.0
		var y: float = n[1]
		var k: float = n[2]
		draw_rect(Rect2(x - 90 * k, y - 4 * k, 200 * k, 34 * k), ombre)
		draw_circle(Vector2(x - 60 * k, y), 34 * k, ombre)
		draw_circle(Vector2(x + 100 * k, y + 4 * k), 30 * k, ombre)
		draw_circle(Vector2(x - 20 * k, y - 22 * k), 46 * k, c)
		draw_circle(Vector2(x + 45 * k, y - 30 * k), 40 * k, c)
		draw_rect(Rect2(x - 70 * k, y - 20 * k, 160 * k, 26 * k), c)


func _horizon() -> void:
	var c := Color("9aa5bd")
	var c2 := Color("8e9bb5")
	# Toits continus
	var pts := [Vector2(-2600, SOL)]
	var x := -2600.0
	var i := 0
	while x < 2600.0:
		var h := 300.0 + 40.0 * sin(i * 1.7) + 25.0 * sin(i * 0.6)
		pts.append(Vector2(x, SOL - h))
		pts.append(Vector2(x + 70, SOL - h))
		x += 70.0 + 30.0 * absf(sin(i * 2.3))
		i += 1
	pts.append(Vector2(2600, SOL))
	Dessin.poly(self, pts, c)
	# Dôme (Invalides) et tour Montparnasse
	draw_circle(Vector2(-140, SOL - 380), 46, c2)
	draw_rect(Rect2(-186, SOL - 380, 92, 60), c2)
	draw_rect(Rect2(-144, SOL - 450, 8, 30), c2)
	draw_rect(Rect2(700, SOL - 760, 96, 460), c2)
	draw_rect(Rect2(770, SOL - 760, 26, 460), c2.darkened(0.08))
	# Tour Eiffel
	var ex := -760.0
	var b := SOL - 300.0
	Dessin.poly(self, [Vector2(ex - 95, b), Vector2(ex - 52, b - 150), Vector2(ex - 22, b - 420), Vector2(ex - 8, b - 640),
		Vector2(ex + 8, b - 640), Vector2(ex + 22, b - 420), Vector2(ex + 52, b - 150), Vector2(ex + 95, b),
		Vector2(ex + 50, b), Vector2(ex, b - 70), Vector2(ex - 50, b)], c2)
	draw_rect(Rect2(ex - 62, b - 160, 124, 14), c2)
	draw_rect(Rect2(ex - 34, b - 400, 68, 10), c2)
	draw_rect(Rect2(ex - 2, b - 700, 4, 64), c2)


func _lointain() -> void:
	var murs := [Color("c9b79c"), Color("b9a58a"), Color("c4b08f")]
	var toit := Dessin.lointain(Color("6e7a8c"), CIEL_BAS, 0.3)
	var x := -2400.0
	var i := 0
	while x < 2400.0:
		var w := 170.0 + 60.0 * absf(sin(i * 1.9))
		var h := 380.0 + 70.0 * absf(sin(i * 1.3 + 0.5))
		if absf(x - 280.0) < 200.0:
			x += 30.0
			i += 1
			continue
		var c := Dessin.lointain(murs[i % 3], CIEL_BAS, 0.3)
		draw_rect(Rect2(x, SOL - h, w, h), c)
		draw_rect(Rect2(x + w - 18, SOL - h, 18, h), c.darkened(0.12))
		# Toit mansardé et cheminées
		Dessin.poly(self, [Vector2(x - 6, SOL - h), Vector2(x + w + 6, SOL - h), Vector2(x + w - 16, SOL - h - 48), Vector2(x + 16, SOL - h - 48)], toit)
		draw_rect(Rect2(x + 26, SOL - h - 70, 16, 24), toit.darkened(0.1))
		draw_rect(Rect2(x + w - 50, SOL - h - 66, 14, 20), toit.darkened(0.1))
		# Fenêtres et balcon filant
		var fen := c.darkened(0.14)
		var cols := int(w / 44.0)
		for r in range(1, int(h / 64.0)):
			for k in cols:
				draw_rect(Rect2(x + 16 + k * 44, SOL - h + 10 + r * 60, 20, 32), fen)
		draw_rect(Rect2(x, SOL - h + 120, w, 6), c.darkened(0.2))
		x += w + 8.0
		i += 1
	# Palais Brongniart (la Bourse de Paris)
	var pb := Dessin.lointain(Color("d8cdb6"), CIEL_BAS, 0.3)
	var px := 100.0
	draw_rect(Rect2(px, SOL - 300, 360, 300), pb)
	draw_rect(Rect2(px - 12, SOL - 330, 384, 34), pb.darkened(0.08))
	draw_rect(Rect2(px + 20, SOL - 352, 320, 24), pb.darkened(0.04))
	for k in 9:
		var cx := px + 22 + k * 40
		draw_rect(Rect2(cx, SOL - 296, 16, 250), pb.lightened(0.08))
		draw_rect(Rect2(cx + 10, SOL - 296, 6, 250), pb.darkened(0.12))
	draw_rect(Rect2(px - 20, SOL - 46, 400, 46), pb.darkened(0.06))
