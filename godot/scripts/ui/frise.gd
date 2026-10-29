class_name Frise
extends Control
## Frise de la tranche (04 §4, 09 §4.2) : années graduées, passé rempli à l'accent, curseur continu,
## marqueurs passés (◆ événement de marché) et à venir (★ nouveauté en mystère, drapeau de fin).
## On ne voyage pas dans le temps : la frise ne réagit pas au clic.

var m_debut := 0
var m_fin := 179
var ab_debut := 0                 # mois absolu du mois 0 de la période
var position_mois := 0.0          # m + progression du mois
var marqueurs: Array = []         # { m, type: "marche" | "nouveau", passe: bool }

const MARGE := 36.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 56)


func _x(m: float) -> float:
	var total := float(m_fin - m_debut + 1)
	return MARGE + (size.x - 2.0 * MARGE) * clampf((m - m_debut) / total, 0.0, 1.0)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var y := size.y * 0.66
	var x0 := _x(m_debut)
	var x1 := _x(m_fin + 1)
	var xc := _x(position_mois)
	Dessin.arrondi(self, Rect2(x0, y - 4, x1 - x0, 8), Style.FILET, 4)
	Dessin.arrondi(self, Rect2(x0, y - 4, maxf(8.0, xc - x0), 8), Style.ACCENT, 4)
	# Graduation par année et par trimestre
	var police := Style.chiffres()
	for m in range(m_debut, m_fin + 1):
		var a := ab_debut + m
		var x := _x(m)
		if Dates.mois(a) == 1 or m == m_debut:
			draw_rect(Rect2(x - 1, y - 16, 2, 12), Style.TEXTE_2)
			draw_string(police, Vector2(x + 6, y - 10), str(Dates.annee(a)), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Style.TEXTE_2)
		elif Dates.mois(a) % 3 == 1:
			draw_rect(Rect2(x - 1, y - 9, 2, 5), Color(Style.TEXTE_2, 0.5))
	# Marqueurs
	for mq in marqueurs:
		var x := _x(float(mq["m"]) + 0.5)
		if mq["type"] == "marche" and mq["passe"]:
			_losange(Vector2(x, y + 15), Style.PERTE)
		elif mq["type"] == "nouveau":
			_etoile(Vector2(x, y + 15), 9.0, Style.ALERTE, mq["passe"])
	_drapeau(Vector2(x1 + 4, y))
	# Curseur
	draw_circle(Vector2(xc, y + 2), 15, Color(0, 0, 0, 0.35))
	draw_circle(Vector2(xc, y), 13, Style.ACCENT)
	draw_circle(Vector2(xc, y), 7, Color.WHITE)


func _losange(c: Vector2, couleur: Color) -> void:
	var pts := PackedVector2Array([c + Vector2(0, -9), c + Vector2(9, 0), c + Vector2(0, 9), c + Vector2(-9, 0)])
	draw_colored_polygon(pts, Style.TEXTE)
	pts.append(pts[0])
	draw_polyline(pts, couleur, 3.0, true)


func _etoile(c: Vector2, r: float, couleur: Color, pleine: bool) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var rr := r if i % 2 == 0 else r * 0.45
		pts.append(c + Vector2.from_angle(-PI / 2.0 + i * PI / 5.0) * rr)
	if pleine:
		draw_colored_polygon(pts, couleur)
	else:
		pts.append(pts[0])
		draw_polyline(pts, couleur, 2.0, true)


func _drapeau(c: Vector2) -> void:
	draw_line(c + Vector2(0, 12), c + Vector2(0, -20), Style.TEXTE_2, 3.0, true)
	draw_colored_polygon(PackedVector2Array([c + Vector2(1, -20), c + Vector2(20, -14), c + Vector2(1, -7)]), Style.TEXTE_2)
