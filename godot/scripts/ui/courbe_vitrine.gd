class_name CourbeVitrine
extends Control
## Courbe de fins de mois d'une vitrine (lot 10b, I6 ; docs/47 §1) : 3 points reliés, un repère carré par point, valeur arrondie à 5 points
## (comme le tableau du Lundi noir) au-dessus et mois en dessous. Dessinée sur le papier de la Gazette (encre). Rien n'est calculé ici :
## les points viennent de contenu_modale()["courbe"] ([{mois: "AAAA-MM", valeur}]).

var points: Array = []
var compacte := false
var lues: Array = []   # [[mois, valeur]] affichés (contrôles)


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 150)


func regler(courbe: Array, compact: bool) -> void:
	points = courbe
	compacte = compact
	custom_minimum_size = Vector2(0, 96 if compact else 160)
	lues.clear()
	for p: Dictionary in courbe:
		lues.append([_mois(p), ModaleJournal.texte_indice(float(p["valeur"]))])
	queue_redraw()


static func _mois(p: Dictionary) -> String:
	return Dates.texte_court(Dates.lire(str(p["mois"])))


func _draw() -> void:
	var n := points.size()
	if n < 2:
		return
	var police := Style.chiffres()
	var t_val := 22
	var t_mois := 20
	var bas := size.y - float(t_mois) - 8.0
	var haut := float(t_val) + 12.0
	var mini := INF
	var maxi := -INF
	for p: Dictionary in points:
		mini = minf(mini, float(p["valeur"]))
		maxi = maxf(maxi, float(p["valeur"]))
	var etendue := maxf(maxi - mini, 1.0)
	var marge := 90.0
	var pts := PackedVector2Array()
	for i in n:
		var x := marge + (size.x - 2.0 * marge) * i / float(n - 1)
		var y := bas - (bas - haut) * (float(points[i]["valeur"]) - mini) / etendue
		pts.append(Vector2(x, y))
	draw_line(Vector2(marge - 40.0, bas + 4.0), Vector2(size.x - marge + 40.0, bas + 4.0), Color(Style.ENCRE, 0.35), 2.0)
	draw_polyline(pts, Style.ENCRE, 4.0, false)
	for i in n:
		draw_rect(Rect2(pts[i] - Vector2(7, 7), Vector2(14, 14)), Style.ENCRE_ROUGE if i == _creux() else Style.ENCRE)
		var v := ModaleJournal.texte_indice(float(points[i]["valeur"]))
		var lv := police.get_string_size(v, HORIZONTAL_ALIGNMENT_LEFT, -1, t_val).x
		draw_string(police, Vector2(pts[i].x - lv / 2.0, pts[i].y - 14.0), v, HORIZONTAL_ALIGNMENT_LEFT, -1, t_val, Style.ENCRE)
		var m := _mois(points[i])
		var lm := police.get_string_size(m, HORIZONTAL_ALIGNMENT_LEFT, -1, t_mois).x
		draw_string(police, Vector2(pts[i].x - lm / 2.0, size.y - 2.0), m, HORIZONTAL_ALIGNMENT_LEFT, -1, t_mois, Style.TEXTE_PAPIER_2)


## Indice du point le plus bas (le « creux » : repère rouge).
func _creux() -> int:
	var k := 0
	for i in points.size():
		if float(points[i]["valeur"]) < float(points[k]["valeur"]):
			k = i
	return k
