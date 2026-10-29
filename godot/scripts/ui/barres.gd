class_name Barres
extends Control
## Barres horizontales comparées (écran de fin, 13 §4.3) : « VOUS » et « TATA LIVRET », même échelle,
## course de 1,5 s puis le montant au bout de chaque barre.

var lignes: Array = []      # [libellé, valeur (euros), couleur]
var ab := 0
var avance := 1.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func regler(l: Array, a: int) -> void:
	lignes = l
	ab = a
	avance = 0.0 if not Juice.animations_reduites else 1.0
	queue_redraw()


func animer(delai := 0.0) -> void:
	if Juice.animations_reduites:
		avance = 1.0
		queue_redraw()
		return
	var t := create_tween()
	t.tween_interval(delai)
	t.tween_method(_regler_avance, 0.0, 1.0, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _regler_avance(u: float) -> void:
	avance = u
	queue_redraw()


func _draw() -> void:
	if lignes.is_empty():
		return
	var maxi := 1.0
	for l in lignes:
		maxi = maxf(maxi, float(l[1]))
	var caps := Style.capitales()
	var police := Style.chiffres()
	var gauche := 170.0
	var h := size.y / lignes.size()
	var epaisseur := minf(34.0, h * 0.6)
	for i in lignes.size():
		var l: Array = lignes[i]
		var y := h * i + (h - epaisseur) / 2.0
		draw_string(caps, Vector2(0, y + epaisseur * 0.72), str(l[0]), HORIZONTAL_ALIGNMENT_LEFT, gauche - 10.0, 18, Style.TEXTE)
		var place := size.x - gauche - 150.0
		var w := place * float(l[1]) / maxi * avance
		Dessin.arrondi(self, Rect2(gauche, y, place, epaisseur), Color(1, 1, 1, 0.05), 8)
		if w > 2.0:
			Dessin.arrondi(self, Rect2(gauche, y, w, epaisseur), l[2], 8)
		draw_string(police, Vector2(gauche + w + 12.0, y + epaisseur * 0.78), Format.entier(float(l[1]) * avance, ab), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Style.TEXTE)
