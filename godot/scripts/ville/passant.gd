extends Node2D
## Figurine qui marche sur le trottoir (lot PX1) : marche 4 images (8 im/s à l'allure ×1), repos 2 images,
## ombre au sol, position entière. Vitesse × facteur de trafic de la rue (accélérée avec le jeu, arrêtée en
## pause). Modes : passant qui fait le tour de la rue ; va-et-vient (Gérard devant sa porte, arrêt d'une
## fois sur deux devant la porte) ; sortie (voisin qui traverse : libéré quand il quitte la vue) ; pose fixe
## (M. Lefranc qui fume). qui : gerard, tata, matelas, jeanmi, jeanmi_velo, lopez, lefranc, passant_1..3.

const RUE := preload("res://scripts/ville/rue.gd")

var rue: Node2D
var qui := "passant_1"
var vitesse := 24.0           # px d'art par seconde à l'allure ×1
var sens := 1                 # 1 : vers la droite
var arrete := false           # arrêté (krach : les passants regardent la Gazette)
var va_et_vient := Vector2.ZERO
var porte_x := -1
var sortie := false
var pose_fixe := ""           # "fume" : M. Lefranc devant la banque
var x_monde := 0.0:
	set(v):
		x_monde = v
		var xi := roundi(v)
		if position.x != xi:
			position.x = xi
var _t := 0.0
var _image := 0
var _repos := 0.0
var _passe_porte := false
var _nom_dessine := ""


func _process(delta: float) -> void:
	if rue == null:
		return
	if pose_fixe != "":
		if rue.anime:
			_t += delta
			if _t >= 0.5:
				_t -= 0.5
				_image = 1 - _image
		_maj()
		return
	var f: float = rue.get("facteur")
	if arrete or not rue.anime or f <= 0.0:
		if arrete and _repos <= 0.0:
			_image = 0
		_maj()
		return
	if _repos > 0.0:
		_repos -= delta * f
		_t += delta
		if _t >= 0.5:
			_t -= 0.5
			_image = 1 - _image
		if _repos <= 0.0:
			_image = 0
			_t = 0.0
		_maj()
		return
	var x := x_monde + vitesse * f * delta * sens
	_t += delta * 8.0 * f
	while _t >= 1.0:
		_t -= 1.0
		_image = (_image + 1) % 4
	if va_et_vient != Vector2.ZERO:
		if x >= va_et_vient.y:
			sens = -1
		elif x <= va_et_vient.x:
			sens = 1
		if porte_x >= 0 and int(x) != int(x_monde) and mini(int(x), int(x_monde)) < porte_x and maxi(int(x), int(x_monde)) >= porte_x:
			_passe_porte = not _passe_porte
			if _passe_porte:
				_repos = 3.0
				_image = 0
				_t = 0.0
	elif sortie:
		var v: Rect2 = rue.get("vue")
		if (sens > 0 and x > v.end.x + 50.0) or (sens < 0 and x < v.position.x - 50.0):
			rue.call("oublier", self)
			queue_free()
			return
	else:
		if x > RUE.DROITE + 60:
			x = RUE.GAUCHE - 60
		elif x < RUE.GAUCHE - 60:
			x = RUE.DROITE + 60
	x_monde = x
	_maj()


func _nom() -> String:
	var dossier := "ville/" if sens > 0 else "miroir/"
	if qui == "jeanmi_velo":
		return ("objet/" if sens > 0 else "miroir/") + "velo_%d" % (_image % 2 + 1)
	if pose_fixe == "fume":
		return dossier + "%s_fume_%d" % [qui, _image % 2 + 1]
	if _repos > 0.0 or arrete:
		return dossier + "%s_repos_%d" % [qui, _image % 2 + 1]
	return dossier + "%s_marche_%d" % [qui, _image + 1]


func _maj() -> void:
	var n := _nom()
	if n != _nom_dessine:
		_nom_dessine = n
		queue_redraw()


## Pose déterministe (captures).
func poser_capture(x: float, s: int) -> void:
	sens = s
	_image = 1
	_repos = 0.0
	_t = 0.0
	_passe_porte = true
	x_monde = x
	_maj()


## Au-dessus de la tête (px d'art du monde).
func point_tete() -> Vector2:
	return position + Vector2(0, -70)


func _draw() -> void:
	if rue == null:
		return
	if qui == "jeanmi_velo":
		rue.rect(self, Rect2i(-28, -1, 56, 4), "dalle_ombre")
	else:
		rue.rect(self, Rect2i(-11, -1, 22, 4), "dalle_ombre")
		rue.rect(self, Rect2i(-8, 3, 16, 1), "dalle_ombre")
	rue.image(self, _nom(), Vector2i.ZERO)
