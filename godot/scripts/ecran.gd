extends Node
## Autoload « Ecran » : format d'affichage et échelle de l'interface (09 §4.1, lot PX2 §2.3).
## - Base virtuelle 1920 × 1080 (étirement canvas_items / expand). L'interface est dessinée en texels de
##   3 px virtuels (grille 640 × 360 de docs/16 §3.3) ; content_scale_factor est réglé pour qu'un texel
##   fasse un nombre ENTIER T de pixels physiques (échelle = T / 3 px physiques par px virtuel) :
##   PC : T = max(1, floor(hauteur physique / 324)) (360 à 10 % près, pour les fenêtres agrandies)
##   → 720p et 1366 × 768 : 2 ; 1080p (et 1920 × 1061) : 3 ; 1440p : 4.
##   Mobile : T = le plus petit entier tel qu'une cible de REF_CIBLE px virtuels fasse au moins 48 dp.
## - dp : 1 dp = dpi / 160 px physiques (DisplayServer.screen_get_dpi() sur mobile, 1 sur PC).
## - F10 (PC) : téléphone simulé, fenêtre 1600 × 720 à 267 dpi (20:9, 6,5 pouces ; 1 dp = 1,67 px),
##   calculé comme un mobile. Raccourci de test : absent de la version du joueur (Reglages.raccourcis_test()) ;
##   --telephone des captures reste actif.
## - « compact » : zone logique < 1600 de large ou < 900 de haut (téléphone) → mise en page resserrée.

signal format_change

const BASE := Vector2(1920, 1080)
const TEXEL := 3.0                         # px virtuels par texel d'interface
const HAUTEUR_GRILLE := 360                # grille d'interface 640 × 360
const REF_CIBLE := 84.0                    # hauteur des boutons dessinés : 28 texels (px virtuels)
const DP_CIBLE := 48.0
const FENETRE_TELEPHONE := Vector2i(1600, 720)
const DPI_TELEPHONE := 267.0

var telephone_simule := false
var _fenetre_pc := Vector2i(1600, 900)
var _t := 3
var _echelle := 1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.size_changed.connect(_on_taille)
	_appliquer.call_deferred()


# =====================================================================
# Calculs purs (testés par tests/test_ecran.gd)
# =====================================================================

## Pixels physiques par dp.
static func dp_pour(dpi: float, mobile: bool) -> float:
	return maxf(1.0, dpi) / 160.0 if mobile else 1.0


## Facteur texel T (pixels physiques par texel d'interface), toujours entier ≥ 1.
static func facteur_texel_pour(taille_physique: Vector2i, dpi: float, mobile: bool) -> int:
	if mobile:
		# REF_CIBLE × T / TEXEL ≥ 48 dp
		var t_min := DP_CIBLE * dp_pour(dpi, true) * TEXEL / REF_CIBLE
		return maxi(1, ceili(t_min - 0.0001))
	# Tolérance de 10 % : une fenêtre agrandie sur un écran 1080p (1920 × 1061, barre des tâches) garde T = 3.
	return maxi(1, floori(float(mini(taille_physique.x, taille_physique.y)) / (HAUTEUR_GRILLE * 0.9)))


## Pixels physiques par pixel virtuel.
static func echelle_pour(taille_physique: Vector2i, dpi: float, mobile: bool) -> float:
	return facteur_texel_pour(taille_physique, dpi, mobile) / TEXEL


## content_scale_factor à appliquer à la fenêtre (étirement « expand » de la base 1920 × 1080).
static func facteur_contenu_pour(taille_physique: Vector2i, dpi: float, mobile: bool) -> float:
	# Étirement « disabled » (réglé par _appliquer) : le facteur est appliqué tel quel, l'échelle finale vaut
	# exactement T / 3 et la zone logique taille_physique × 3 / T (1366 × 768 → 2049 × 1152).
	return echelle_pour(taille_physique, dpi, mobile)


## Côté minimal d'une cible tactile, en px virtuels, pour une échelle et un dp donnés.
static func cible_min_pour(echelle: float, dp_px: float, mobile: bool) -> float:
	var physique := DP_CIBLE * dp_px if mobile else 48.0
	return ceilf(physique / maxf(0.0001, echelle))


# =====================================================================
# État courant
# =====================================================================

func _mobile() -> bool:
	return telephone_simule or OS.has_feature("mobile")


func _dpi() -> float:
	if telephone_simule:
		return DPI_TELEPHONE
	return float(DisplayServer.screen_get_dpi()) if OS.has_feature("mobile") else 96.0


func facteur_texel() -> int:
	return _t


## Pixels physiques par pixel virtuel.
func echelle() -> float:
	return _echelle


## Pixels physiques par dp.
func dp() -> float:
	return dp_pour(_dpi(), _mobile())


## Côté minimal d'une cible tactile en px virtuels (48 dp sur mobile et téléphone simulé ; 48 px physiques sur PC).
func cible_min() -> float:
	return cible_min_pour(_echelle, dp(), _mobile())


## Taille logique visible (après étirement et facteur d'échelle).
func taille() -> Vector2:
	return get_tree().root.get_visible_rect().size


func compact() -> bool:
	var t := taille()
	return t.x < 1600.0 or t.y < 900.0


func _appliquer() -> void:
	# La vitrine PX0 (scenes/px0.tscn) règle elle-même sa fenêtre : on n'y touche pas.
	var scene := get_tree().current_scene
	if scene != null and scene.scene_file_path == "res://scenes/px0.tscn":
		return
	var fen := get_window()
	var taille_phys := fen.size
	if taille_phys.x <= 0 or taille_phys.y <= 0:
		return
	_t = facteur_texel_pour(taille_phys, _dpi(), _mobile())
	_echelle = _t / TEXEL
	var f := facteur_contenu_pour(taille_phys, _dpi(), _mobile())
	# Étirement désactivé pour la scène du jeu (project.godot garde canvas_items pour la vitrine PX0) :
	# le facteur s'applique tel quel, sans arrondi de la zone logique.
	if fen.content_scale_mode != Window.CONTENT_SCALE_MODE_DISABLED:
		fen.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	if absf(fen.content_scale_factor - f) > 0.0001:
		fen.content_scale_factor = f


func _on_taille() -> void:
	_appliquer()
	format_change.emit()


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k != null and k.pressed and not k.echo and k.keycode == KEY_F10 and Reglages.raccourcis_test():
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
		telephone_simule = true
		fen.size = FENETRE_TELEPHONE
	else:
		telephone_simule = false
		fen.size = _fenetre_pc
	_appliquer()
	fen.move_to_center()
	format_change.emit()
