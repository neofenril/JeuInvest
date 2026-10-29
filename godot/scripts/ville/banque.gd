extends Batiment
## La banque (09 §2.3) : pierre claire, colonnes, fronton avec horloge (un tour par mois de jeu),
## enseigne dorée, fenêtre du banquier (M. Lefranc), distributeur à écran vert (1986+).
## Pendant un appel : silhouette au téléphone, combiné qui sonne au-dessus du toit, ondes.

const PIERRE := Color("e9e2d3")
const FRONTON := Color("d6ccb8")
const PORTE := Color("5a3e2b")
const ENSEIGNE := Color("b08a2e")
const LUMIERE := Color("ffd27a")
const COLONNES := [-146.0, -56.0, 56.0, 146.0]
const FEN_GAUCHE := Rect2(-124, -214, 46, 70)
const FEN_BANQUIER := Rect2(78, -214, 46, 70)
const COMBINE := Vector2(0, -410)

var aiguille := 0.0            # 0 → 1 : avancement du mois (horloge)
var appel := 0.0               # 0 → 1 : fenêtre du banquier allumée, silhouette
var sonnerie := 0.0            # angle du combiné (radians)
var combine_visible := 0.0
var _ondes: Array = []
var _t := 0.0


func _ready() -> void:
	super._ready()
	id = "banque"
	nom = "MA BANQUE"
	zone = Rect2(-210, -420, 420, 430)
	contour = PackedVector2Array([Vector2(-200, 0), Vector2(-200, -30), Vector2(-180, -30), Vector2(-180, -262),
		Vector2(-196, -262), Vector2(-196, -292), Vector2(0, -354), Vector2(196, -292), Vector2(196, -262),
		Vector2(180, -262), Vector2(180, -30), Vector2(200, -30), Vector2(200, 0)])


func _process(delta: float) -> void:
	_t += delta
	for o in _ondes:
		o["age"] += delta
	_ondes = _ondes.filter(func(o: Dictionary) -> bool: return o["age"] < 0.6)


func ondes(nombre := 3) -> void:
	for i in nombre:
		_ondes.append({"age": -0.15 * i})


func _draw() -> void:
	Dessin.ombre_sol(self, -200, 210, 0, 18)
	# Marches
	for k in 3:
		draw_rect(Rect2(-200 + k * 8, -10 - k * 10, 400 - k * 16, 10), PIERRE.darkened(0.08 + k * 0.03))
	# Murs
	Dessin.volume(self, Rect2(-180, -262, 360, 232), PIERRE, 24)
	for k in 6:
		draw_rect(Rect2(-180, -230 + k * 34, 336, 2), PIERRE.darkened(0.07))
	# Fenêtre de gauche, distributeur, porte, fenêtre du banquier
	draw_rect(FEN_GAUCHE.grow(5), PIERRE.darkened(0.25))
	draw_rect(FEN_GAUCHE, Color("6f8191"))
	draw_rect(FEN_BANQUIER.grow(5), PIERRE.darkened(0.25))
	draw_rect(FEN_BANQUIER, Color("6f8191"))
	if annee >= 1986:
		draw_rect(Rect2(-126, -122, 50, 56), Color("3d3f46"))
		draw_rect(Rect2(-120, -116, 38, 22), Color("0f3a22"))
		draw_rect(Rect2(-116, -88, 30, 4), Color("8a8f98"))
	draw_circle(Vector2(0, -170), 36, PIERRE.darkened(0.25))
	draw_rect(Rect2(-36, -170, 72, 140), PIERRE.darkened(0.25))
	draw_circle(Vector2(0, -170), 30, PORTE)
	draw_rect(Rect2(-30, -170, 60, 140), PORTE)
	draw_rect(Rect2(-2, -170, 4, 140), PORTE.darkened(0.3))
	draw_circle(Vector2(-8, -100), 3, Style.OR)
	draw_circle(Vector2(8, -100), 3, Style.OR)
	# Colonnes (2 tons)
	for cx in COLONNES:
		draw_rect(Rect2(cx - 15, -250, 30, 208), Color("f3eee4"))
		draw_rect(Rect2(cx + 3, -250, 12, 208), Color("f3eee4").darkened(0.18))
		draw_rect(Rect2(cx - 21, -262, 42, 14), FRONTON)
		draw_rect(Rect2(cx - 21, -44, 42, 14), FRONTON.darkened(0.08))
	# Entablement, enseigne, fronton, horloge
	draw_rect(Rect2(-196, -292, 392, 32), FRONTON)
	draw_rect(Rect2(-196, -264, 392, 4), FRONTON.darkened(0.2))
	Dessin.texte(self, Style.titre_journal(), Vector2(0, -267), "B A N Q U E", 26, ENSEIGNE)
	Dessin.poly(self, [Vector2(-204, -292), Vector2(204, -292), Vector2(0, -356)], FRONTON.darkened(0.06))
	Dessin.poly(self, [Vector2(-160, -298), Vector2(160, -298), Vector2(0, -346)], FRONTON)
	if hiver:
		Dessin.poly(self, [Vector2(-204, -292), Vector2(0, -356), Vector2(204, -292), Vector2(190, -292), Vector2(0, -348), Vector2(-190, -292)], Color(0.97, 0.98, 1.0))
	var h := Vector2(0, -318)
	draw_circle(h, 16, Color("3d3f46"))
	draw_circle(h, 13, Color("f6f1e4"))
	var ang := -PI / 2.0 + aiguille * TAU
	draw_line(h, h + Vector2.from_angle(ang) * 10.0, Color("2a2a2a"), 2.5, true)
	draw_line(h, h + Vector2.from_angle(-PI / 2.0 + aiguille * TAU / 12.0) * 6.0, Color("2a2a2a"), 3.0, true)
	_dessiner_contour()


func dessiner_lumieres(ci: CanvasItem) -> void:
	var a := Batiment.fenetre_allumee(nuit, 0.45)
	if a > 0.01:
		ci.draw_rect(FEN_GAUCHE, Color(LUMIERE, 0.45 * a))
	var b := maxf(Batiment.fenetre_allumee(nuit, 0.25), appel)
	if b > 0.01:
		ci.draw_rect(FEN_BANQUIER, Color(LUMIERE, 0.5 * b))
		Dessin.halo(ci, FEN_BANQUIER.get_center(), 80, Color(LUMIERE, 0.25 * b))
	if annee >= 1986:
		ci.draw_rect(Rect2(-120, -116, 38, 22), Color(0.2, 0.9, 0.45, 0.55))
		var texte_atm := "RETRAIT" if fmod(_t, 4.0) < 2.0 else "CODE ?"
		ci.draw_string(Style.led(), Vector2(-117, -100), texte_atm, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.5, 1.0, 0.6, 0.9))
	# Combiné qui sonne et ondes
	if combine_visible > 0.01:
		ci.draw_set_transform(position + COMBINE, sonnerie, Vector2.ONE * (0.7 + 0.3 * combine_visible))
		var c := Color(Style.OR, combine_visible)
		Dessin.halo(ci, Vector2.ZERO, 60, Color(Style.OR, 0.4 * combine_visible))
		ci.draw_rect(Rect2(-30, -8, 60, 14), c)
		ci.draw_circle(Vector2(-30, 4), 14, c)
		ci.draw_circle(Vector2(30, 4), 14, c)
		ci.draw_rect(Rect2(-40, 4, 22, 10), c)
		ci.draw_rect(Rect2(18, 4, 22, 10), c)
		ci.draw_set_transform(position)
	for o in _ondes:
		var age: float = o["age"]
		if age < 0.0:
			continue
		var k := age / 0.6
		ci.draw_arc(COMBINE, 50.0 + 110.0 * k, -PI * 0.85, -PI * 0.15, 24, Color(Style.OR, (1.0 - k) * 0.9), 5.0, true)


## Silhouette du banquier au téléphone, dessinée par-dessus la fenêtre allumée.
func dessiner_silhouette(ci: CanvasItem) -> void:
	if appel <= 0.01:
		return
	var c := Color(0.12, 0.1, 0.14, appel)
	var f := FEN_BANQUIER
	ci.draw_circle(Vector2(f.get_center().x, f.position.y + 26), 11, c)
	ci.draw_rect(Rect2(f.position.x + 8, f.position.y + 40, f.size.x - 16, 30), c)
	ci.draw_rect(Rect2(f.get_center().x + 6, f.position.y + 18, 8, 22), c)
