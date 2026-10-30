class_name DateVolets
extends Control
## Date à volets (09 §3, effet 8 ; habillage pixel PX0 / PX2) : deux plaquettes « calendrier » pixel
## (mois, année) avec charnière, chiffres en Atkinson grasse. Au changement de mois, le volet se plie
## (0,09 s) puis se rouvre (0,14 s, rebond) ; l'année suit en janvier.

signal triple_touche

const MOIS := ["JANV", "FÉVR", "MARS", "AVR", "MAI", "JUIN", "JUIL", "AOÛT", "SEPT", "OCT", "NOV", "DÉC"]
const TAILLE := 44

var mois_txt := "SEPT"
var annee_txt := "1986"
var _pli_mois := 1.0
var _pli_annee := 1.0
var _touches: Array = []


func _init() -> void:
	custom_minimum_size = Vector2(270, 72)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func regler(a: int, anime := true) -> void:
	var m: String = MOIS[Dates.mois(a) - 1]
	var y := str(Dates.annee(a))
	if not anime or Juice.animations_reduites:
		mois_txt = m
		annee_txt = y
		queue_redraw()
		return
	if m != mois_txt:
		_plier("_pli_mois", func() -> void: mois_txt = m, 0.0)
	if y != annee_txt:
		_plier("_pli_annee", func() -> void: annee_txt = y, 0.05)


func _plier(prop: String, changer: Callable, delai: float) -> void:
	var t := create_tween()
	t.tween_interval(delai)
	t.tween_property(self, prop, 0.0, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_callback(changer)
	t.tween_property(self, prop, 1.0, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_method(func(_v: float) -> void: queue_redraw(), 0.0, 1.0, 0.14)
	var t2 := create_tween()
	t2.tween_method(func(_v: float) -> void: queue_redraw(), 0.0, 1.0, delai + 0.1)


func _draw() -> void:
	_case(Rect2(0, 0, 138, 72), mois_txt, _pli_mois)
	_case(Rect2(144, 0, 126, 72), annee_txt, _pli_annee)


func _case(r: Rect2, txt: String, pli: float) -> void:
	draw_style_box(CadresPixel.style("plaquette"), r)
	var police := Style.chiffres()
	var w := police.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, TAILLE).x
	var centre := r.get_center()
	draw_set_transform(centre, 0.0, Vector2(1.0, maxf(0.02, pli)))
	draw_string(police, Vector2(-w / 2.0, TAILLE * 0.36), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, TAILLE, Style.TEXTE)
	draw_set_transform(Vector2.ZERO)
	if pli < 0.99:
		draw_rect(Rect2(r.position.x + 3, centre.y, r.size.x - 6, r.size.y / 2.0 - 3), Color(Style.ENCRE, 0.35))
	# Charnière : filet sombre au milieu, attaches ardoise sur les bords
	draw_rect(Rect2(r.position.x + 6, roundf(centre.y / 3.0) * 3.0 - 1.5, r.size.x - 12, 3), PalettePixel.couleur("nuit"))
	draw_rect(Rect2(r.position.x - 3, roundf(centre.y / 3.0) * 3.0 - 6, 6, 12), Style.PANNEAU_SURVOL)
	draw_rect(Rect2(r.end.x - 3, roundf(centre.y / 3.0) * 3.0 - 6, 6, 12), Style.PANNEAU_SURVOL)


## Triple toucher sur la date : raccourci de démonstration (09 §5.1, n° 14).
func _gui_input(event: InputEvent) -> void:
	var appui: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed)
	if not appui:
		return
	var maintenant := Time.get_ticks_msec()
	_touches.append(maintenant)
	_touches = _touches.filter(func(t: int) -> bool: return maintenant - t < 700)
	if _touches.size() >= 3:
		_touches.clear()
		triple_touche.emit()
