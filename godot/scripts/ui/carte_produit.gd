class_name CarteProduit
extends Control
## Une carte du carnet du banquier (13 §2.2), dessinée en code : détenue (couleur pleine, valeur),
## présentée (couleur atténuée, date), nouvelle (badge « NOUVEAU » et reflet), à découvrir (silhouette en
## pointillés, « ? » et un indice de besoin, jamais une date).

signal touchee(pid: String)

var pid := ""
var nom := ""
var couleur := Style.ACCENT
var etat := "silhouette"
var ligne1 := ""
var ligne2 := ""
var indice := ""
var cadenas := false
var calendrier := false   # versement automatique actif (11 §8, VP11)
var choisie := false
var compacte := false
var remplissage := 1.0   # déblocage animé : la couleur monte de bas en haut
var _t := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_mode = Control.FOCUS_NONE


func _ready() -> void:
	custom_minimum_size = Vector2(140, 116) if compacte else Vector2(170, 128)


func _gui_input(event: InputEvent) -> void:
	var b := event as InputEventMouseButton
	if b != null and b.pressed and b.button_index == MOUSE_BUTTON_LEFT:
		touchee.emit(pid)
		accept_event()


func _process(delta: float) -> void:
	if etat == "nouveau":
		_t += delta
		queue_redraw()


func _regler_remplissage(u: float) -> void:
	remplissage = u
	queue_redraw()


## Déblocage animé (13 §2.3) : la carte se retourne, la couleur la remplit, le badge apparaît.
func reveler(delai := 0.0) -> void:
	if Juice.animations_reduites:
		return
	pivot_offset = size / 2.0
	remplissage = 0.0
	var t := create_tween()
	t.tween_interval(delai)
	t.tween_property(self, "scale:x", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
	t.tween_property(self, "scale:x", 1.0, 0.15).set_trans(Tween.TRANS_SINE)
	t.tween_method(_regler_remplissage, 0.0, 1.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_callback(Juice.pop.bind(self))


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var ui := Style.ui()
	var gras := Style.ui_gras()
	var fs := 18 if compacte else 20
	if etat == "silhouette":
		Dessin.arrondi(self, r, Style.SILHOUETTE, 12)
		_pointilles(r.grow(-2), Style.FILET)
		Dessin.texte(self, Style.neon(), Vector2(r.size.x / 2.0, r.size.y * 0.42), "?", 44 if not compacte else 38, Color(Style.TEXTE_2, 0.7))
		draw_multiline_string(ui, Vector2(8, r.size.y * 0.62), indice, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16, 16 if compacte else 17, 2, Style.TEXTE_2)
	else:
		var plein := etat == "detenu"
		Dessin.arrondi(self, r, Style.PANNEAU_ELEVE, 12)
		var fond := Color(couleur, 0.32 if plein else 0.16)
		var h := r.size.y * remplissage
		Dessin.arrondi(self, Rect2(0, r.size.y - h, r.size.x, h), fond, 12)
		Dessin.arrondi(self, Rect2(0, 0, 7, r.size.y), Color(couleur, 1.0 if plein else 0.55), 4)
		draw_multiline_string(gras, Vector2(16, 26), nom.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 22, fs, 2, Style.TEXTE)
		var y2 := r.size.y - 38.0
		if plein:
			draw_string(Style.chiffres(), Vector2(16, y2), ligne1, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 22, 22 if compacte else 24, Style.TEXTE)
			draw_string(ui, Vector2(16, y2 + 24), ligne2, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 22, 16, Style.TEXTE_2)
		elif etat != "nouveau":
			draw_string(ui, Vector2(16, y2 + 4), ligne1, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 22, 16, Style.TEXTE_2)
			draw_string(ui, Vector2(16, y2 + 24), ligne2, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 22, 16, Style.TEXTE_2)
		if cadenas:
			_cadenas(Vector2(r.size.x - 22, r.size.y - 26))
		if calendrier and etat != "nouveau":
			_calendrier(Vector2(r.size.x - 24, r.size.y - 62))
		if etat == "nouveau":
			_badge(Vector2(14, r.size.y - 36))
			# Reflet qui passe toutes les 4 s
			var k := fmod(_t, 4.0) / 0.6
			if k < 1.0:
				var x := -40.0 + (r.size.x + 80.0) * k
				draw_colored_polygon(PackedVector2Array([Vector2(x, 0), Vector2(x + 26, 0), Vector2(x - 14, r.size.y), Vector2(x - 40, r.size.y)]), Color(1, 1, 1, 0.10))
	if choisie:
		var s := StyleBoxFlat.new()
		s.draw_center = false
		s.set_corner_radius_all(12)
		s.set_border_width_all(3)
		s.border_color = Style.TEXTE
		draw_style_box(s, r)


func _pointilles(r: Rect2, c: Color) -> void:
	var coins := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
	for i in 4:
		draw_dashed_line(coins[i], coins[(i + 1) % 4], c, 2.0, 8.0)


## Badge « NOUVEAU » et son étoile, coin haut gauche en « coin ».
func _badge(coin: Vector2) -> void:
	var txt := "NOUVEAU"
	var police := Style.capitales()
	var l := police.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	var b := Rect2(coin.x, coin.y, l + 34, 24)
	Dessin.arrondi(self, b, Style.ALERTE, 12)
	draw_string(police, Vector2(b.position.x + 8, b.position.y + 18), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Style.ENCRE_ACCENT)
	var c := Vector2(b.end.x - 13, b.get_center().y)
	var pts := PackedVector2Array()
	for i in 8:
		pts.append(c + Vector2.from_angle(-PI / 2.0 + i * TAU / 8.0) * (7.0 if i % 2 == 0 else 2.5))
	draw_colored_polygon(pts, Style.ENCRE_ACCENT)


## Petit calendrier (versement automatique chaque mois) : page, reliure et une case cochée.
func _calendrier(c: Vector2) -> void:
	var r := Rect2(c.x - 11, c.y - 9, 22, 20)
	Dessin.arrondi(self, r, Style.GEL, 3)
	draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 6), Style.GEL.darkened(0.35))
	draw_line(Vector2(r.position.x + 6, r.position.y - 3), Vector2(r.position.x + 6, r.position.y + 3), Style.TEXTE, 2.0)
	draw_line(Vector2(r.end.x - 6, r.position.y - 3), Vector2(r.end.x - 6, r.position.y + 3), Style.TEXTE, 2.0)
	draw_polyline(PackedVector2Array([c + Vector2(-5, 3), c + Vector2(-1, 7), c + Vector2(6, -1)]), Style.SILHOUETTE, 2.5, true)


func _cadenas(c: Vector2) -> void:
	draw_arc(c + Vector2(0, -4), 6.0, PI, TAU, 12, Style.TEXTE_2, 2.5, true)
	Dessin.arrondi(self, Rect2(c.x - 9, c.y - 4, 18, 14), Style.TEXTE_2, 3)
