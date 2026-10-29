class_name Piles
extends Control
## Les 3 piles de pièces de la pédagogie des frais (13 §3.3) : sans frais / ce produit / produit plus chargé,
## sur 20 ans, avec l'argent du joueur (Banquier.piles). Un compteur d'années va de 0 à 20 en 2 s, les piles
## montent ensemble et leurs montants roulent ; à la fin, l'écart avec la pile « sans frais » apparaît en
## pièces fantômes (contour cuivre) : « gains qui n'ont jamais existé ».

var donnees: Dictionary = {}
var ab := 0
var titres := ["SANS FRAIS", "CE PRODUIT", "PLUS CHARGÉ"]
var details := ["", "", ""]
var progression := 1.0
var fantomes := 1.0
var compacte := false
var _ellipse := PackedVector2Array()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 340)
	for i in 28:
		_ellipse.append(Vector2.from_angle(i * TAU / 28.0))


func regler(p: Dictionary, a: int, t: Array, d: Array, anime := true) -> void:
	donnees = p
	ab = a
	titres = t
	details = d
	if anime and not Juice.animations_reduites:
		progression = 0.0
		fantomes = 0.0
		var tw := create_tween()
		tw.tween_property(self, "progression", 1.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(self, "fantomes", 1.0, 0.4)
	else:
		progression = 1.0
		fantomes = 1.0
	queue_redraw()


func _process(_delta: float) -> void:
	if progression < 1.0 or fantomes < 1.0:
		queue_redraw()


## Valeur d'une pile à l'instant t (0 → 1) : croissance géométrique de la mise de départ à la valeur finale.
func _valeur(depart: float, final: float, t: float) -> float:
	if depart <= 0.0:
		return final * t
	return depart * pow(final / depart, t)


func _piece(c: Vector2, rx: float, ry: float, face: Color, bord: Color) -> void:
	var bas := PackedVector2Array()
	var haut := PackedVector2Array()
	for v in _ellipse:
		bas.append(c + Vector2(v.x * rx, v.y * ry + ry * 0.55))
		haut.append(c + Vector2(v.x * rx, v.y * ry))
	draw_colored_polygon(bas, bord)
	draw_colored_polygon(haut, face)
	var reflet := PackedVector2Array()
	for v in _ellipse:
		reflet.append(c + Vector2(v.x * rx * 0.55 - rx * 0.12, v.y * ry * 0.45 - ry * 0.1))
	draw_colored_polygon(reflet, Color(1, 1, 1, 0.18))


func _fantome(c: Vector2, rx: float, ry: float, couleur: Color) -> void:
	var pts := PackedVector2Array()
	for v in _ellipse:
		pts.append(c + Vector2(v.x * rx, v.y * ry))
	pts.append(pts[0])
	draw_polyline(pts, couleur, 2.0, true)


func _draw() -> void:
	if donnees.is_empty():
		return
	var police := Style.chiffres()
	var ui := Style.ui()
	var caps := Style.capitales()
	var montant := float(donnees["montant"])
	var finales := [float(donnees["sans"]), float(donnees["produit"]), float(donnees["charge"])]
	var departs := [montant, montant - float(donnees["tout_de_suite"]), montant - float(donnees["tout_de_suite"])]
	var maxi: float = finales[0]
	var t := clampf(progression, 0.0, 1.0)
	var bas_texte := 74.0 if not compacte else 64.0
	# Une bande réservée en haut pour « DANS 20 ANS » : le montant de la pile la plus haute reste dessous (v2_f01)
	var haut_chiffre := 70.0 if compacte else 100.0
	var zone_h := size.y - bas_texte - haut_chiffre
	var col := size.x / 3.0
	var rx := minf(46.0, col * 0.3)
	var ry := rx * 0.3
	var pas := ry * 1.25
	var sol := size.y - bas_texte - ry
	var annees := int(round(t * float(donnees.get("annees", 20))))
	draw_string(caps, Vector2(4, 18), "DANS %d AN%s" % [annees, "S" if annees > 1 else ""], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Style.TEXTE_2)
	for k in 3:
		var cx := col * (k + 0.5)
		var v := _valeur(float(departs[k]), float(finales[k]), t)
		var h := zone_h * v / maxi
		var n := maxi(1, int(h / pas))
		for i in n:
			_piece(Vector2(cx, sol - i * pas), rx, ry, Style.OR, Style.OR_OMBRE)
		var y_haut := sol - (n - 1) * pas - ry
		# Pièces fantômes : les gains qui n'ont jamais existé (écart avec la pile sans frais)
		if k > 0 and fantomes > 0.0:
			var n0 := int(zone_h * float(finales[0]) / maxi / pas)
			for i in range(n, n0):
				_fantome(Vector2(cx, sol - i * pas), rx, ry, Color(Style.CUIVRE, 0.75 * fantomes))
			if n0 > n:
				y_haut = sol - (n0 - 1) * pas - ry
		var txt := Format.entier(v, ab)
		Dessin.texte(self, police, Vector2(cx, y_haut - 10.0), txt, 26 if compacte else 30, Style.TEXTE)
		# Légende sous la pile
		var y := size.y - bas_texte + (22.0 if not compacte else 18.0)
		Dessin.texte(self, caps, Vector2(cx, y), str(titres[k]), 16 if compacte else 18, Style.TEXTE)
		if str(details[k]) != "":
			Dessin.texte(self, ui, Vector2(cx, y + (22.0 if not compacte else 20.0)), str(details[k]), 16 if compacte else 18, Style.TEXTE_2)
		if k > 0 and fantomes > 0.5:
			var cout := float(finales[0]) - float(finales[k])
			var phrase := ("les frais coûtent " if k == 1 else "ils coûteraient ") + Format.entier(cout, ab)
			Dessin.texte(self, ui, Vector2(cx, y + (44.0 if not compacte else 39.0)), phrase, 16 if compacte else 18, Style.CUIVRE)
