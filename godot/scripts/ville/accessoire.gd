extends Node2D
## Petits accessoires de la rue, dessinés en aplats et animés par les séquences de principal.gd
## (position, rotation, échelle, transparence par Tween) :
## - potelet : borne de trottoir parisienne (origine au sol ; la rotation la fait pencher) ;
## - triangle : triangle de signalisation (origine au sol) ;
## - enjoliveur : celui qui s'échappe de la roue (origine au centre) ;
## - boum : étoile de bande dessinée « BONK ! » (origine au centre) ;
## - cigogne : vole vers la droite en battant des ailes, porte 0, 1 ou 2 paquets au bec ;
## - paquet : bébé emmailloté (origine au nœud, en haut : il se balance autour).

const BLANC := Color("f6f4ee")
const NOIR := Color("26272c")
const ORANGE := Color("e8703a")
const PEAU := Color("f3cfb0")

var genre := "potelet"
var paquets := 0                       # cigogne : paquets portés
var couleurs_paquets: Array = []       # cigogne : couleur de chaque paquet
var couleur := Color("f7b6c8")         # paquet : couleur du lange
var texte := "BONK !"
var _battement := 0.0


func _ready() -> void:
	set_process(genre == "cigogne")


func _process(delta: float) -> void:
	_battement += delta * 16.0
	queue_redraw()


## Point d'attache des paquets sous le bec de la cigogne (coordonnées locales).
var attache := Vector2(62, 22)


func _draw() -> void:
	match genre:
		"potelet":
			_potelet()
		"triangle":
			_triangle()
		"enjoliveur":
			draw_circle(Vector2.ZERO, 9.0, Color("c9ced6"))
			draw_circle(Vector2.ZERO, 9.0, Color("8d939c"), false, 2.0, true)
			for k in 4:
				draw_line(Vector2.ZERO, Vector2.from_angle(k * TAU / 4.0) * 8.0, Color("8d939c"), 2.0)
			draw_circle(Vector2.ZERO, 2.5, Color("6d727a"))
		"boum":
			_boum()
		"cigogne":
			_cigogne()
		"paquet":
			_paquet(Vector2.ZERO, couleur)


func _potelet() -> void:
	var c := Color("4a3b2c")
	draw_rect(Rect2(-12, -3, 24, 5), Color(0, 0, 0, 0.22))
	Dessin.arrondi(self, Rect2(-7, -52, 14, 52), c, 5)
	draw_rect(Rect2(-5, -52, 3, 50), c.lightened(0.15))
	draw_rect(Rect2(-8, -40, 16, 5), Style.OR_OMBRE)
	draw_circle(Vector2(0, -54), 8.0, c)
	draw_circle(Vector2(-2, -56), 3.0, c.lightened(0.25))


func _triangle() -> void:
	draw_line(Vector2(-10, 0), Vector2(0, -12), Color("3a3c42"), 3.0)
	draw_line(Vector2(10, 0), Vector2(0, -12), Color("3a3c42"), 3.0)
	var pts := PackedVector2Array([Vector2(0, -52), Vector2(24, -10), Vector2(-24, -10)])
	draw_colored_polygon(pts, Color("d8322a"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -38), Vector2(13, -16), Vector2(-13, -16)]), Color("fbf3e6"))


func _boum() -> void:
	var pts := PackedVector2Array()
	for k in 24:
		var r := 58.0 if k % 2 == 0 else 34.0
		pts.append(Vector2.from_angle(k * TAU / 24.0 - 0.1) * Vector2(r * 1.25, r))
	draw_colored_polygon(pts, Color("ffd23f"))
	pts.append(pts[0])
	draw_polyline(pts, Color("d8322a"), 4.0, true)
	var police := Style.manchette()
	var taille := 30
	var largeur := police.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
	draw_string_outline(police, Vector2(-largeur / 2.0, 11), texte, HORIZONTAL_ALIGNMENT_LEFT, -1, taille, 6, Color.WHITE)
	draw_string(police, Vector2(-largeur / 2.0, 11), texte, HORIZONTAL_ALIGNMENT_LEFT, -1, taille, Color("d8322a"))


## Cigogne de profil, tournée vers la droite : corps blanc, rémiges noires, long bec et pattes orange.
func _cigogne() -> void:
	var aile := sin(_battement)
	# Pattes tendues vers l'arrière
	draw_line(Vector2(-34, 6), Vector2(-86, 14), ORANGE, 3.0, true)
	draw_line(Vector2(-34, 2), Vector2(-88, 6), ORANGE.darkened(0.15), 3.0, true)
	# Aile du fond (plus sombre)
	_aile(Vector2(-6, -6), -aile * 0.9 - 0.2, BLANC.darkened(0.12), NOIR.lightened(0.1))
	# Corps et queue
	draw_colored_polygon(PackedVector2Array([Vector2(-30, -4), Vector2(-52, -10), Vector2(-50, 4), Vector2(-30, 6)]), NOIR)
	draw_set_transform(Vector2(-4, 0), -0.08, Vector2(1.0, 0.46))
	draw_circle(Vector2.ZERO, 36.0, BLANC)
	draw_set_transform(Vector2.ZERO)
	# Cou, tête, bec
	draw_line(Vector2(24, -4), Vector2(40, -14), BLANC, 11.0, true)
	draw_circle(Vector2(44, -16), 9.0, BLANC)
	draw_circle(Vector2(47, -19), 1.8, NOIR)
	draw_colored_polygon(PackedVector2Array([Vector2(50, -20), Vector2(84, -10), Vector2(50, -11)]), ORANGE)
	# Aile de devant
	_aile(Vector2(-4, -8), aile * 0.9 + 0.1, BLANC, NOIR)
	# Paquets suspendus au bec par un lange noué
	if paquets > 0:
		var bec := Vector2(66, -13)
		for i in paquets:
			var dx := 0.0 if paquets == 1 else (-12.0 if i == 0 else 12.0)
			draw_line(bec, attache + Vector2(dx, 0), Color("d9d2c3"), 2.0, true)
			var c: Color = couleurs_paquets[i] if i < couleurs_paquets.size() else Color("f7b6c8")
			_paquet(attache + Vector2(dx, 0), c, 0.85)


func _aile(base: Vector2, angle: float, c: Color, pointe: Color) -> void:
	var dir := Vector2.from_angle(-PI / 2.0 + angle)
	var lat := Vector2(-dir.y, dir.x)
	var p0 := base + lat * 18.0
	var p1 := base - lat * 22.0
	var bout := base + dir * 62.0 - lat * 14.0
	draw_colored_polygon(PackedVector2Array([p0, p1, bout]), c)
	draw_colored_polygon(PackedVector2Array([base + dir * 40.0 - lat * 2.0, base + dir * 34.0 - lat * 20.0, bout]), pointe)


## Bébé emmailloté : lange arrondi, visage, nœud en haut (point d'attache = p).
func _paquet(p: Vector2, c: Color, echelle := 1.0) -> void:
	var e := echelle
	draw_circle(p + Vector2(0, 3) * e, 5.0 * e, c.darkened(0.15))
	Dessin.arrondi(self, Rect2(p + Vector2(-17, 6) * e, Vector2(34, 30) * e), c, int(12 * e))
	draw_rect(Rect2(p + Vector2(-17, 22) * e, Vector2(34, 4) * e), c.darkened(0.1))
	draw_circle(p + Vector2(0, 15) * e, 8.0 * e, PEAU)
	draw_arc(p + Vector2(0, 15) * e, 9.0 * e, PI * 1.1, PI * 1.9, 10, c.lightened(0.25), 3.0 * e)
	draw_circle(p + Vector2(-3, 15) * e, 1.2 * e, NOIR)
	draw_circle(p + Vector2(3, 15) * e, 1.2 * e, NOIR)
	draw_arc(p + Vector2(0, 17) * e, 2.5 * e, 0.3, PI - 0.3, 6, Color("c0705a"), 1.2 * e)
