extends Node
## Autoload « Ecran » : format d'affichage (09 §4.1).
## - Facteur d'échelle : 1,0 sur PC, 1,7 sur téléphone, 1,25 sur tablette (détecté sur mobile).
## - F10 (PC) : simule un téléphone 20:9 (fenêtre 1200 × 540 et facteur 1,7, soit ≈ 1410 × 635 logiques).
## - « compact » : largeur logique < 1600 (téléphone) → mise en page resserrée du HUD.

signal format_change

const FACTEUR_TELEPHONE := 1.7
const FACTEUR_TABLETTE := 1.25
const FENETRE_TELEPHONE := Vector2i(1200, 540)

var telephone_simule := false
var _fenetre_pc := Vector2i(1600, 900)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.size_changed.connect(_on_taille)
	if OS.has_feature("mobile"):
		get_tree().root.content_scale_factor = _facteur_mobile()


func _facteur_mobile() -> float:
	var ecran := DisplayServer.screen_get_size()
	var dpi := maxf(1.0, float(DisplayServer.screen_get_dpi()))
	var cote_court_pouces := minf(ecran.x, ecran.y) / dpi
	if cote_court_pouces < 3.5:
		return FACTEUR_TELEPHONE
	return FACTEUR_TABLETTE


## Taille logique visible (après étirement et facteur d'échelle).
func taille() -> Vector2:
	return get_tree().root.get_visible_rect().size


func compact() -> bool:
	return taille().x < 1600.0


func _on_taille() -> void:
	format_change.emit()


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k != null and k.pressed and not k.echo and k.keycode == KEY_F10:
		basculer_telephone()
		get_viewport().set_input_as_handled()


## Bascule entre le format PC et le téléphone simulé (F10).
func basculer_telephone() -> void:
	if OS.has_feature("mobile"):
		return
	var fen := get_window()
	if not telephone_simule:
		_fenetre_pc = fen.size
		if fen.mode != Window.MODE_WINDOWED:
			fen.mode = Window.MODE_WINDOWED
		fen.size = FENETRE_TELEPHONE
		fen.content_scale_factor = FACTEUR_TELEPHONE
		telephone_simule = true
	else:
		fen.size = _fenetre_pc
		fen.content_scale_factor = 1.0
		telephone_simule = false
	fen.move_to_center()
	format_change.emit()
