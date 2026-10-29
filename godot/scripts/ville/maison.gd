extends Batiment
## La maison du personnage (09 §2.3) : murs crème, toit de tuiles, volets, fenêtre de Gérard,
## boîte aux lettres à drapeau rouge (courrier), cheminée qui fume en hiver.

const MURS := Color("e8d3b0")
const TOIT := Color("b5553c")
const VOLETS := Color("3f7f8c")
const VITRE := Color("9cc3d9")
const LUMIERE := Color("ffd27a")

var drapeau := 0.0          # 0 baissé → 1 levé
var flash := 0.0            # clignotement de la fenêtre (appel du banquier)
var _fumee: CPUParticles2D

const FENETRES := [Rect2(-96, -196, 60, 56), Rect2(36, -196, 60, 56), Rect2(-104, -112, 64, 58)]
const SEUILS := [0.35, 0.15, 0.55]   # la fenêtre 1 (en haut à droite) est celle de Gérard


func _ready() -> void:
	super._ready()
	id = "maison"
	nom = "MA MAISON"
	zone = Rect2(-170, -330, 370, 340)
	contour = PackedVector2Array([Vector2(-140, 0), Vector2(-140, -222), Vector2(-160, -222), Vector2(-108, -300),
		Vector2(108, -300), Vector2(160, -222), Vector2(140, -222), Vector2(140, 0)])
	_fumee = CPUParticles2D.new()
	_fumee.position = Vector2(76, -330)
	_fumee.amount = 14
	_fumee.lifetime = 3.0
	_fumee.direction = Vector2(0.3, -1)
	_fumee.spread = 12.0
	_fumee.initial_velocity_min = 18.0
	_fumee.initial_velocity_max = 28.0
	_fumee.gravity = Vector2(6, -4)
	_fumee.scale_amount_min = 8.0
	_fumee.scale_amount_max = 14.0
	var courbe := Curve.new()
	courbe.add_point(Vector2(0, 0.6))
	courbe.add_point(Vector2(1, 1.6))
	_fumee.scale_amount_curve = courbe
	var grad := Gradient.new()
	grad.set_color(0, Color(0.85, 0.85, 0.88, 0.55))
	grad.set_color(1, Color(0.85, 0.85, 0.88, 0.0))
	_fumee.color_ramp = grad
	_fumee.emitting = false
	add_child(_fumee)


func regler_hiver(oui: bool) -> void:
	hiver = oui
	_fumee.emitting = oui
	queue_redraw()


func _draw() -> void:
	Dessin.ombre_sol(self, -140, 150, 0, 16)
	# Murs (face + côté droit plus sombre) et soubassement
	Dessin.volume(self, Rect2(-140, -222, 280, 222), MURS, 26)
	draw_rect(Rect2(-140, -24, 280, 24), MURS.darkened(0.12))
	draw_rect(Rect2(-140, -222, 280, 12), MURS.darkened(0.22))
	# Cheminée
	Dessin.volume(self, Rect2(62, -336, 30, 70), Color("a0503a"), 10)
	draw_rect(Rect2(58, -342, 38, 10), Color("8a4432"))
	# Toit épais (face + avancée sombre)
	Dessin.poly(self, [Vector2(-160, -222), Vector2(160, -222), Vector2(108, -300), Vector2(-108, -300)], TOIT)
	Dessin.poly(self, [Vector2(108, -300), Vector2(160, -222), Vector2(132, -222)], TOIT.darkened(0.2))
	draw_rect(Rect2(-164, -232, 328, 12), TOIT.darkened(0.25))
	for k in 5:
		draw_line(Vector2(-150 + k * 4, -238 - k * 14), Vector2(150 - k * 4, -238 - k * 14), TOIT.darkened(0.12), 2.0)
	if hiver:
		Dessin.poly(self, [Vector2(-108, -300), Vector2(108, -300), Vector2(122, -280), Vector2(-122, -280)], Color(0.97, 0.98, 1.0))
		draw_rect(Rect2(58, -346, 38, 6), Color(0.97, 0.98, 1.0))
	# Fenêtres et volets
	for i in FENETRES.size():
		var r: Rect2 = FENETRES[i]
		draw_rect(r.grow(5), MURS.darkened(0.3))
		draw_rect(r, VITRE)
		draw_rect(Rect2(r.position.x + r.size.x / 2.0 - 2, r.position.y, 4, r.size.y), MURS.lightened(0.3))
		draw_rect(Rect2(r.position.x, r.position.y + r.size.y * 0.45, r.size.x, 4), MURS.lightened(0.3))
		draw_rect(Rect2(r.position.x - 22, r.position.y - 2, 16, r.size.y + 4), VOLETS)
		draw_rect(Rect2(r.end.x + 6, r.position.y - 2, 16, r.size.y + 4), VOLETS.darkened(0.15))
		draw_rect(Rect2(r.position.x - 8, r.end.y + 4, r.size.x + 16, 6), MURS.darkened(0.25))
	# Porte, marche, numéro
	draw_rect(Rect2(14, -124, 66, 124), MURS.darkened(0.3))
	draw_rect(Rect2(20, -118, 54, 118), Color("7a4a30"))
	draw_rect(Rect2(26, -110, 42, 40), Color("8a5a3c"))
	draw_circle(Vector2(64, -58), 4, Style.OR)
	draw_rect(Rect2(8, -6, 78, 8), Color("b9b2a5"))
	# Haie
	draw_circle(Vector2(-118, -12), 22, Color("4f8f4a"))
	draw_circle(Vector2(-84, -10), 18, Color("5a9a52"))
	_boite_aux_lettres()
	_dessiner_contour()


func _boite_aux_lettres() -> void:
	var b := Vector2(172, 0)
	draw_rect(Rect2(b.x - 3, b.y - 70, 6, 70), Color("3d3f46"))
	Dessin.arrondi(self, Rect2(b.x - 22, b.y - 100, 44, 34), Color("e8b931"), 8)
	draw_rect(Rect2(b.x - 12, b.y - 90, 24, 4), Color("5a4a1a"))
	# Drapeau rouge : tourne autour de son pivot (baissé à l'horizontale, levé à la verticale)
	var pivot := Vector2(b.x + 22, b.y - 80)
	var ang := lerpf(0.0, -PI / 2.0, drapeau)
	var dir := Vector2.from_angle(ang)
	var normale := Vector2(-dir.y, dir.x)
	draw_line(pivot, pivot + dir * 30.0, Color("3d3f46"), 4.0, true)
	Dessin.poly(self, [pivot + dir * 18.0, pivot + dir * 32.0, pivot + dir * 32.0 - normale * 14.0, pivot + dir * 18.0 - normale * 14.0], Color("e63b2e"))


func dessiner_lumieres(ci: CanvasItem) -> void:
	for i in FENETRES.size():
		var r: Rect2 = FENETRES[i]
		var a := Batiment.fenetre_allumee(nuit, SEUILS[i])
		if i == 1:
			a = maxf(a, flash)
		if a > 0.01:
			ci.draw_rect(r, Color(LUMIERE, 0.5 * a))
			Dessin.halo(ci, r.get_center(), 80, Color(LUMIERE, 0.22 * a))
