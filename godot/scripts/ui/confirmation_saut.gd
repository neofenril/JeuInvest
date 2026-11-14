class_name ConfirmationSaut
extends Control
## Fenêtre de confirmation du saut « jusqu'au prochain événement » (bouton COURRIER, touche N), au premier appui :
## ce que va faire le bouton, AVANCER / ANNULER (Échap) et la case « Ne plus afficher ce message ».
## La préférence est locale (Reglages, user://preferences.cfg), jamais lue ni écrite en capture ni en test.

signal valide(ne_plus_afficher: bool)
signal annule

const TITRE := "AVANCER JUSQU'AU PROCHAIN ÉVÈNEMENT ?"
const TEXTE := "Le temps va défiler, mois après mois, jusqu'à la prochaine décision, le prochain courrier ou le prochain journal. Vous pourrez arrêter à tout moment."
const LIBELLE_CASE := "Ne plus afficher ce message"

var case_cochee := false
var b_avancer: Button
var b_annuler: Button
var _case: Control
var _fini := false


func _init() -> void:
	name = "ConfirmationSaut"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var fond := ColorRect.new()
	fond.color = Color(0.0, 0.0, 0.0, 0.55)
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fond)
	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centre)
	var p := PanelContainer.new()
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.add_theme_stylebox_override("panel", Style.papier("banque", 30.0, 24.0))
	centre.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	p.add_child(v)
	var largeur := 780.0
	var t := Style.label(TITRE, 30, Style.capitales(), Style.ENCRE)
	t.name = "Titre"
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.custom_minimum_size.x = largeur
	v.add_child(t)
	var l := Style.label(TEXTE, 24, Style.ui(), Style.ENCRE)
	l.name = "Explication"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = largeur
	v.add_child(l)
	v.add_child(_fabriquer_case())
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 18)
	v.add_child(h)
	b_avancer = Style.bouton("AVANCER", true)
	b_avancer.name = "Avancer"
	b_avancer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_avancer.pressed.connect(_avancer)
	h.add_child(b_avancer)
	b_annuler = Style.bouton("ANNULER")
	b_annuler.name = "Annuler"
	b_annuler.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_annuler.pressed.connect(_annuler)
	h.add_child(b_annuler)
	b_avancer.grab_focus.call_deferred()


## Case à cocher : un carré pixel de la hauteur d'une cible tactile, suivi du libellé ; tout est cliquable.
func _fabriquer_case() -> Control:
	var ligne := HBoxContainer.new()
	ligne.name = "Case"
	ligne.add_theme_constant_override("separation", 14)
	ligne.mouse_filter = Control.MOUSE_FILTER_STOP
	ligne.custom_minimum_size.y = maxf(60.0, Style.cible_min())
	var carre := Control.new()
	carre.name = "Carre"
	carre.custom_minimum_size = Vector2(45, 45)
	carre.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	carre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	carre.draw.connect(_dessiner_case.bind(carre))
	ligne.add_child(carre)
	var lb := Style.label(LIBELLE_CASE, 24, Style.ui(), Style.ENCRE)
	lb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ligne.add_child(lb)
	ligne.gui_input.connect(_clic_case)
	_case = ligne
	return ligne


func _dessiner_case(carre: Control) -> void:
	carre.draw_rect(Rect2(0, 0, 45, 45), Style.ENCRE)
	carre.draw_rect(Rect2(3, 3, 39, 39), Style.JOURNAL)
	if case_cochee:
		for k in 4:   # coche en escalier, au pixel (3 px)
			carre.draw_rect(Rect2(9 + 6 * k, 21 + 6 * k, 9, 9), Style.ENCRE)
		for k in 5:
			carre.draw_rect(Rect2(21 + 6 * k, 27 - 6 * k, 9, 9), Style.ENCRE)


func _clic_case(ev: InputEvent) -> void:
	var b := ev as InputEventMouseButton
	if b != null and b.pressed and b.button_index == MOUSE_BUTTON_LEFT:
		cocher(not case_cochee)


func cocher(oui: bool) -> void:
	case_cochee = oui
	(_case.get_node("Carre") as Control).queue_redraw()


func _avancer() -> void:
	if _fini:
		return
	_fini = true
	valide.emit(case_cochee)


func _annuler() -> void:
	if _fini:
		return
	_fini = true
	annule.emit()


func _input(ev: InputEvent) -> void:
	var k := ev as InputEventKey
	if k != null and k.pressed and not k.echo:
		if k.keycode == KEY_ESCAPE:
			_annuler()
			get_viewport().set_input_as_handled()
		elif k.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_1]:
			_avancer()
			get_viewport().set_input_as_handled()
		elif k.keycode == KEY_2:
			_annuler()
			get_viewport().set_input_as_handled()
