extends Node
## Autoload « Ecran » : format d'affichage et échelle de l'interface (09 §4.1, lot PX2 §2.3).
## - Base virtuelle 1920 × 1080 (étirement canvas_items / expand). L'interface est dessinée en texels de
##   3 px virtuels (grille 640 × 360 de docs/16 §3.3) ; content_scale_factor est réglé pour qu'un texel
##   fasse un nombre ENTIER T de pixels physiques (échelle = T / 3 px physiques par px virtuel) :
##   PC : T = max(2, floor(côté court / 324)) (360 à 10 % près, pour les fenêtres agrandies) → 720p et
##   1366 × 768 : 2 ; 1080p (et 1920 × 1009) : 3 ; 1440p : 4. Fenêtre d'au moins 1152 × 648 (min_size).
##   Mobile (PX2 §9.1) : T = clamp(T_dp, 2, T_max), T_dp = plus petit entier tel qu'un bouton de REF_CIBLE
##   px virtuels fasse 48 dp, T_max = floor(3 × min(h / 648, l / 1280)) : la zone virtuelle ne descend
##   jamais sous 1280 × 648 (zone minimale de conception). cible_min = min(48 dp, REF_CIBLE).
## - dp : 1 dp = dpi / 160 px physiques (DisplayServer.screen_get_dpi() sur mobile, 1 sur PC).
## - F10 (PC) : téléphone simulé, fenêtre 1440 × 648 à 240 dpi (la zone exacte d'un 2400 × 1080 à
##   400 dpi : T = 3, échelle 1) ; second format « 169 » : 1280 × 720 à 320 dpi. Calculés comme un mobile. Raccourci de test : absent de la version du joueur (Reglages.raccourcis_test()) ;
##   --telephone des captures reste actif.
## - « compact » : zone logique < 1600 de large ou < 900 de haut (téléphone) → mise en page resserrée.

signal format_change

const BASE := Vector2(1920, 1080)
const TEXEL := 3.0                         # px virtuels par texel d'interface
const HAUTEUR_GRILLE := 360                # grille d'interface 640 × 360
const REF_CIBLE := 84.0                    # hauteur des boutons dessinés : 28 texels (px virtuels)
const DP_CIBLE := 48.0
const FENETRE_TELEPHONE := Vector2i(1440, 648)
const DPI_TELEPHONE := 240.0
const FENETRE_TELEPHONE_169 := Vector2i(1280, 720)
const DPI_TELEPHONE_169 := 320.0
const FENETRE_MIN_PC := Vector2i(1152, 648)
const ZONE_MIN := Vector2(1280, 648)        # zone virtuelle minimale de conception (mobile)

var telephone_simule := false
var format_telephone := ""                   # "" (1440 × 648) ou "169" (1280 × 720)
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
		# REF_CIBLE × T / TEXEL ≥ 48 dp, plafonné pour garder une zone d'au moins 1280 × 648
		var t_dp := ceili(DP_CIBLE * dp_pour(dpi, true) * TEXEL / REF_CIBLE - 0.0001)
		var t_max := floori(TEXEL * minf(taille_physique.y / ZONE_MIN.y, taille_physique.x / ZONE_MIN.x) + 0.0001)
		return maxi(1, mini(maxi(t_dp, 2), t_max))
	# Tolérance de 10 % : une fenêtre agrandie sur un écran 1080p (1920 × 1009, barre des tâches) garde T = 3.
	return maxi(2, floori(float(mini(taille_physique.x, taille_physique.y)) / (HAUTEUR_GRILLE * 0.9)))


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
	var c := ceilf(physique / maxf(0.0001, echelle))
	return minf(c, REF_CIBLE) if mobile else c


# =====================================================================
# État courant
# =====================================================================

func _mobile() -> bool:
	return telephone_simule or OS.has_feature("mobile")


func _dpi() -> float:
	if telephone_simule:
		return DPI_TELEPHONE_169 if format_telephone == "169" else DPI_TELEPHONE
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
	var fen := get_window()
	var taille_phys := fen.size
	if taille_phys.x <= 0 or taille_phys.y <= 0:
		return
	_t = facteur_texel_pour(taille_phys, _dpi(), _mobile())
	_echelle = _t / TEXEL
	var f := facteur_contenu_pour(taille_phys, _dpi(), _mobile())
	# Étirement désactivé (project.godot garde canvas_items, ignoré ici) :
	# le facteur s'applique tel quel, sans arrondi de la zone logique.
	if not _mobile() and fen.min_size != FENETRE_MIN_PC:
		fen.min_size = FENETRE_MIN_PC
	elif _mobile() and not OS.has_feature("mobile") and fen.min_size != Vector2i.ZERO:
		fen.min_size = Vector2i.ZERO
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


## Bascule entre le format PC et le téléphone simulé (F10) ; format « 169 » : 1280 × 720 à 320 dpi.
func basculer_telephone(format := "") -> void:
	if OS.has_feature("mobile"):
		return
	var fen := get_window()
	if not telephone_simule:
		_fenetre_pc = fen.size
		if fen.mode != Window.MODE_WINDOWED:
			fen.mode = Window.MODE_WINDOWED
		telephone_simule = true
		format_telephone = format
		fen.min_size = Vector2i.ZERO
		fen.size = FENETRE_TELEPHONE_169 if format == "169" else FENETRE_TELEPHONE
	else:
		telephone_simule = false
		fen.size = _fenetre_pc
	_appliquer()
	fen.move_to_center()
	format_change.emit()
