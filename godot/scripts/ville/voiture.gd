extends Node2D
## Voiture d'époque (lot PX1) : caisse + 2 roues qui tournent (2 images), suspension (caisse relevée 1 image
## sur 4), ombre au sol, phares et feux la nuit ; position entière. Vitesse × facteur de trafic de la rue ;
## vitesse 0 : garée (la voiture de Gérard : capot, enjoliveur, hoquets du moteur pendant la panne).
## modele : r5, 205, 4l, fourgonnette, 944 ; sens 1 : vers la droite (images miroir sinon).

const RUE := preload("res://scripts/ville/rue.gd")

var rue: Node2D
var modele := "r5"
var vitesse := 60.0
var sens := 1
var arrete := false
var capot := 0.0:
	set(v):
		capot = v
		queue_redraw()
var bosse := 0.0
var sans_enjoliveur := false
var hoquet := 0:              # caisse abaissée de n px (moteur qui tousse)
	set(v):
		hoquet = v
		queue_redraw()
var panneau := false:         # panneau « À VENDRE » (Porsche de Jean-Mi)
	set(v):
		panneau = v
		queue_redraw()
var x_monde := 0.0:
	set(v):
		x_monde = v
		var xi := roundi(v)
		if position.x != xi:
			position.x = xi
var _t := 0.0
var _image := 0
var _attente := 0.0


func _process(delta: float) -> void:
	if rue == null or vitesse <= 0.0 or arrete or not rue.anime:
		return
	var f: float = rue.get("facteur")
	if f <= 0.0:
		return
	if _attente > 0.0:
		_attente -= delta * f
		return
	var x := x_monde + vitesse * f * delta * sens
	_t += delta * 8.0 * f
	if _t >= 1.0:
		_t -= floorf(_t)
		_image = (_image + 1) % 4
		queue_redraw()
	if x > RUE.DROITE + 120:
		x = RUE.GAUCHE - 120
	elif x < RUE.GAUCHE - 120:
		x = RUE.DROITE + 120
	x_monde = x


func _info() -> Dictionary:
	return RUE.voiture_info(modele)


## Point du phare avant (px d'art du monde) pour le halo de nuit.
func point_phare() -> Vector2i:
	var v := _info()
	if v.is_empty():
		return Vector2i(position)
	var o: Vector2i = v["origine"]
	var ph: Rect2i = v["phare"]
	var p: Vector2i = ph.position - o + Vector2i(2, 1)
	if sens < 0:
		p.x = -p.x
	return Vector2i(position) + p


func _draw() -> void:
	var v := _info()
	if rue == null or v.is_empty():
		return
	var o: Vector2i = v["origine"]
	var t: Vector2i = v["taille"]
	rue.rect(self, Rect2i(-t.x / 2 + 4, -3, t.x - 4, 5), "ombre_froide")
	var bas := (-1 if _image == 3 and vitesse > 0.0 else 0) + hoquet
	var dossier := "rue/" if sens > 0 else "miroir/"
	rue.image(self, dossier + "voiture_" + modele, Vector2i(0, bas))
	var roue := "rue/roue_%d" % (_image % 2 + 1)
	for rx in v["roues"]:
		var x: int = int(rx) - o.x
		if sens < 0:
			x = -x
		rue.image(self, roue, Vector2i(x, 0))
	if capot > 0.0:
		rue.image(self, "objet/capot", Vector2i(t.x / 2 - 34 if sens > 0 else -t.x / 2, -t.y + 14 + bas - int(capot * 4.0)))
	if panneau:
		rue.image(self, "objet/a_vendre", Vector2i(-10 * sens, -t.y + 26))
	if rue.get("melange") > 0.0:
		var ph: Rect2i = v["phare"]
		var fe: Rect2i = v["feu"]
		for e in [[ph, "lumiere"], [fe, "ambre"]]:
			var r: Rect2i = e[0]
			var p: Vector2i = r.position - o + Vector2i(0, bas)
			if sens < 0:
				p.x = -p.x - r.size.x
			rue.emissif(self, Rect2i(p, r.size), e[1], rue.get("melange"))
