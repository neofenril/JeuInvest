class_name Frise
extends Control
## Frise de la tranche (04 §4, 09 §4.2 ; habillage pixel PX2) : rail en 2 tons, années graduées, passé en
## ambre, curseur « petit calendrier » pixel, marqueurs passés (losange : événement de marché) et à venir
## (étoile : nouveauté en mystère), drapeau de fin pixel. Coordonnées arrondies au texel (3 px virtuels).
## On ne voyage pas dans le temps : la frise ne réagit pas au clic.

var m_debut := 0
var m_fin := 179
var ab_debut := 0                 # mois absolu du mois 0 de la période
var position_mois := 0.0          # m + progression du mois
var marqueurs: Array = []         # { m, type: "marche" | "nouveau", passe: bool }

const MARGE := 36.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 66)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _x(m: float) -> float:
	var total := float(m_fin - m_debut + 1)
	return MARGE + (size.x - 2.0 * MARGE) * clampf((m - m_debut) / total, 0.0, 1.0)


static func _t(v: float) -> float:
	return roundf(v / 3.0) * 3.0


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var y := _t(size.y * 0.6)
	var x0 := _t(_x(m_debut))
	var x1 := _t(_x(m_fin + 1))
	var xc := _t(_x(position_mois))
	# Rail : contour encre, fond ardoise sombre, passé ambre sur orange (2 tons)
	draw_rect(Rect2(x0 - 3, y - 6, x1 - x0 + 6, 15), Style.ENCRE)
	draw_rect(Rect2(x0, y - 3, x1 - x0, 9), Style.PANNEAU_ELEVE)
	draw_rect(Rect2(x0, y - 3, maxf(0.0, xc - x0), 6), Style.ACCENT)
	draw_rect(Rect2(x0, y + 3, maxf(0.0, xc - x0), 3), PalettePixel.couleur("orange"))
	# Graduation par année et par trimestre
	var police := Style.chiffres()
	for m in range(m_debut, m_fin + 1):
		var a := ab_debut + m
		var x := _t(_x(m))
		var passe := m <= position_mois
		if Dates.mois(a) == 1 or m == m_debut:
			draw_rect(Rect2(x, y - 18, 3, 12), Style.TEXTE_2 if passe else Style.PANNEAU_SURVOL)
			draw_string(police, Vector2(x + 6, y - 12), str(Dates.annee(a)), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Style.TEXTE if passe else Style.TEXTE_2)
		elif Dates.mois(a) % 3 == 1:
			draw_rect(Rect2(x, y - 12, 3, 6), Color(Style.TEXTE_2, 0.5))
	# Marqueurs
	for mq in marqueurs:
		var x := _t(_x(float(mq["m"]) + 0.5))
		if mq["type"] == "marche" and mq["passe"]:
			_losange(Vector2(x, y + 21), Style.PERTE)
		elif mq["type"] == "nouveau":
			_etoile(Vector2(x, y + 21), Style.ALERTE, mq["passe"])
	var drapeau := CadresPixel.texture("drapeau")
	draw_texture(drapeau, Vector2(x1 + 3, y + 9 - drapeau.get_height()))
	# Curseur : petit calendrier pixel
	var curseur := CadresPixel.texture("curseur")
	draw_texture(curseur, Vector2(_t(xc - curseur.get_width() / 2.0), _t(y - curseur.get_height() / 2.0 + 1.5)))


## Losange pixel (marche d'escalier de 3 px), contour de la couleur, cœur crème.
func _losange(c: Vector2, couleur: Color) -> void:
	for k in 4:
		var w := 3.0 + 6.0 * k
		draw_rect(Rect2(c.x - w / 2.0, c.y - 12 + 3 * k, w, 3), couleur)
		draw_rect(Rect2(c.x - w / 2.0, c.y + 9 - 3 * k, w, 3), couleur)
	draw_rect(Rect2(c.x - 4.5, c.y - 3, 9, 6), Style.TEXTE)


## Étoile pixel (croix et diagonales en blocs de 3 px) ; vide si à venir.
func _etoile(c: Vector2, couleur: Color, pleine: bool) -> void:
	var blocs := [Vector2(0, -3), Vector2(0, -2), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(-3, 0), Vector2(-2, 0), Vector2(-1, 0),
		Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0), Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1), Vector2(-2, 2), Vector2(2, 2)]
	for b: Vector2 in blocs:
		var interieur := absf(b.x) + absf(b.y) <= 1.0
		if pleine or not interieur:
			draw_rect(Rect2(c + b * 3.0 - Vector2(1.5, 1.5), Vector2(3, 3)), couleur)
