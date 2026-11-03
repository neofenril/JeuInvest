extends Batiment
## La banque (docs/16 §8.4, 270 × 285) : horloge du fronton (aiguille = progression du mois, écrite par
## principal.gd), fenêtre du banquier (M. Lefranc pendant l'appel, combiné qui sonne, ondes), distributeur
## de billets à partir de 1986.

const E := preload("res://scripts/pixel/edifices.gd")

var aiguille := 0.0           # 0 → 1 : un tour de cadran par mois
var appel := 0.0:             # > 0 : M. Lefranc à sa fenêtre
	set(v):
		appel = v
		queue_redraw()
var combine_visible := 0.0
var sonnerie := 0.0           # angle (compatibilité) : le combiné tremble de ±1 px
var _aiguille_dessinee := -1


func _ready() -> void:
	super._ready()
	id = "banque"
	nom = "MA BANQUE"
	load("res://scripts/pixel/voisins.gd").enregistrer("lefranc")


func _process(_delta: float) -> void:
	var a := roundi(aiguille * 60.0)
	if a != _aiguille_dessinee:
		_aiguille_dessinee = a
		queue_redraw()
	if combine_visible > 0.0:
		queue_redraw()


## Ondes depuis la fenêtre du banquier (n salves).
func ondes(nombre := 3) -> void:
	for i in nombre:
		get_tree().create_timer(0.18 * i).timeout.connect(_onde)


func _onde() -> void:
	if rue == null:
		return
	var p := position + Vector2(coin_image() + E.FENETRE_BANQUIER.position + Vector2i(E.FENETRE_BANQUIER.size.x / 2, -2))
	var o: Node2D = rue.ajouter(["objet/onde_or_0", "objet/onde_or_1", "objet/onde_or_2"], p, 9.0)
	o.set("une_fois", true)


## Point des ondes et du combiné (fenêtre du banquier), coordonnées locales.
func point_fenetre() -> Vector2:
	return Vector2(coin_image() + E.FENETRE_BANQUIER.get_center())


func _dessiner_dessus(d: Vector2i) -> void:
	var c := coin_image() + d
	if annee >= 1986:
		rue.image(self, "edifice/distributeur", c + E.DISTRIBUTEUR)
	# Aiguille de l'horloge (pixels entiers)
	var h := c + E.HORLOGE
	var ang := aiguille * TAU
	for k in E.RAYON_HORLOGE - 2:
		var p := h + Vector2i(roundi(sin(ang) * k), -roundi(cos(ang) * k))
		rue.rect(self, Rect2i(p, Vector2i.ONE), "nuit")
	rue.rect(self, Rect2i(h, Vector2i.ONE), "brique_sombre")
	# M. Lefranc à sa fenêtre pendant l'appel, combiné à l'oreille
	if appel > 0.0:
		var f: Rect2i = E.FENETRE_BANQUIER
		rue.image_region(self, "miroir/lefranc_repos_1", c + f.position + Vector2i(4, 14), Rect2i(0, 0, 36, 36), appel)
		if combine_visible > 0.0:
			var tremble := 0 if sonnerie == 0.0 else (1 if Time.get_ticks_msec() / 60 % 2 == 0 else -1)
			rue.image(self, "objet/combine", c + Vector2i(f.position.x + f.size.x / 2 - 9 + tremble, f.position.y + 22))
