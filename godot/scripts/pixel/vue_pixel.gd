class_name VuePixel
extends Control
## Rendu de la ville en vrais pixels (docs/16 §2.1) : le monde est rendu dans un SubViewport de
## ceil(taille_physique / N) px d'art, puis affiché par un TextureRect (filtre Nearest) à l'origine,
## de taille taille_vue × N / échelle_finale en px virtuels. L'échelle finale (étirement canvas_items et
## facteur d'interface 1,7 du téléphone) s'annule : il reste exactement N × N pixels physiques par
## pixel d'art. Les réglages pixel (snap, filtre Nearest) sont posés sur le SubViewport, pas dans
## project.godot.
##
## N = max(1, floor(hauteur_physique / 540)) : la vue fait ≈ 540 px d'art de haut (PX0 quater) ;
## forçable (forcer_facteur). La caméra (Camera2D, ancrée en haut à gauche) est arrondie au pixel d'art.
## Recalcul automatique à chaque changement de taille de fenêtre ou de facteur d'interface.

signal facteur_change(n: int)
signal vue_change          ## après chaque recalcul (taille, facteur, échelle, cadrage)

## PX0 quater : la rue a sa grille fine (≈ 540 px d'art de haut ; 960 × 540 à ×2 en 1080p). L'interface
## garde sa propre grille 640 × 360 en px virtuels (elle ne lit que monde_vers_ecran et marges_art).
const HAUTEUR_ART := 540

var monde: Node2D        ## racine du monde, dans le SubViewport, coordonnées en px d'art
var camera: Camera2D

var _sv: SubViewport
var _rect: TextureRect
var _facteur := 1
var _force := 0
var _taille_vue := Vector2i(640, 360)
var _echelle := 1.0
var _echelle_xy := Vector2.ONE
var _marge_haut := 96.0
var _marge_bas := 72.0
var _zone := Rect2()
var _a_zone := false
var _signature := ""
## PX1 (arbitrage D4, lot_px1 §2.3) : la vue montre toujours HAUTEUR_ART px d'art de haut ; le monde est
## rendu à N = max(2, ceil(h / 540)) dans le SubViewport (caméra zoomée ×N : blocs N × N nets), puis
## l'image est réduite (filtre linéaire) d'un rapport R = h / (540 × N) ≤ 1, jamais agrandie. Faux : ancienne
## règle de la vitrine PX0 (retirée au lot 02), N = floor(h / 540), sans réduction ; plus utilisée par le jeu.
var mode_reduction := false
var _reduction := 1.0


## (N, R) de la règle PX1 pour une taille physique : N entier ≥ 2, R = h / (540 × N) ≤ 1. Fonction pure.
static func facteur_et_reduction(physique: Vector2i) -> Vector2:
	var n := maxi(2, ceili(physique.y / float(HAUTEUR_ART)))
	return Vector2(n, physique.y / (float(HAUTEUR_ART) * n))


func _init() -> void:
	name = "VuePixel"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sv = SubViewport.new()
	_sv.name = "Ville"
	_sv.disable_3d = true
	_sv.transparent_bg = false
	_sv.snap_2d_transforms_to_pixel = true
	_sv.snap_2d_vertices_to_pixel = true
	_sv.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_sv.gui_disable_input = true
	_sv.size = _taille_vue
	add_child(_sv)
	monde = Node2D.new()
	monde.name = "Monde"
	_sv.add_child(monde)
	camera = Camera2D.new()
	camera.name = "Camera"
	camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	camera.position_smoothing_enabled = false
	camera.enabled = true
	_sv.add_child(camera)
	_rect = TextureRect.new()
	_rect.name = "Image"
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_rect.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(_rect)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.texture = _sv.get_texture()
	recalculer()


func _process(_delta: float) -> void:
	if _signature_courante() != _signature:
		recalculer()


func _signature_courante() -> String:
	return "%s|%s|%d" % [str(get_window().size), str(get_viewport_rect().size), _force]


## Recalcule N, la taille de la vue, l'image affichée et la caméra (appelé automatiquement).
func recalculer() -> void:
	if not is_inside_tree():
		return
	_signature = _signature_courante()
	var physique := Vector2(get_window().size)
	if physique.y <= 0.0 or get_viewport_rect().size.y <= 0.0:
		return
	# Échelle réelle de l'étirement, axe par axe : en 1366 × 768, la zone virtuelle fait 1920,9 × 1080 et
	# Godot n'applique pas exactement le même rapport aux deux axes ; une seule échelle décale ~18 colonnes.
	_echelle_xy = get_viewport().get_final_transform().get_scale()
	if _echelle_xy.x <= 0.0 or _echelle_xy.y <= 0.0:
		_echelle_xy = Vector2.ONE * (physique.y / get_viewport_rect().size.y)
	_echelle = _echelle_xy.y
	if mode_reduction:
		_recalculer_reduction(physique)
		return
	var n := _force if _force > 0 else maxi(1, floori(physique.y / float(HAUTEUR_ART)))
	_taille_vue = Vector2i(ceili(physique.x / n), ceili(physique.y / n))
	_sv.size = _taille_vue
	_rect.position = Vector2.ZERO
	_rect.size = Vector2(_taille_vue * n) / _echelle_xy
	var change := n != _facteur
	_facteur = n
	_appliquer_camera()
	if change:
		facteur_change.emit(n)
	vue_change.emit()


func _recalculer_reduction(physique: Vector2) -> void:
	var fr := facteur_et_reduction(Vector2i(physique))
	var n := _force if _force > 0 else int(fr.x)
	_reduction = physique.y / (float(HAUTEUR_ART) * n)
	_taille_vue = Vector2i(ceili(HAUTEUR_ART * physique.x / physique.y), HAUTEUR_ART)
	_sv.size = _taille_vue * n
	camera.zoom = Vector2(n, n)
	_rect.position = Vector2.ZERO
	_rect.size = Vector2(_taille_vue * n) * _reduction / _echelle_xy
	_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if _reduction > 0.999 else CanvasItem.TEXTURE_FILTER_LINEAR
	var change := n != _facteur
	_facteur = n
	if change:
		facteur_change.emit(n)
	vue_change.emit()


## Rapport de réduction R (1 hors mode_reduction).
func reduction() -> float:
	return _reduction if mode_reduction else 1.0


## Pixels physiques par pixel d'art (N × R).
func px_physiques_par_art() -> float:
	return float(_facteur) * reduction()


## Teinte d'affichage (gel de la pause) : modulate de l'image affichée, jamais dans le SubViewport.
func teinter(c: Color) -> void:
	_rect.modulate = c


func facteur() -> int:
	return _facteur


## Taille de la vue en px d'art.
func taille_vue() -> Vector2i:
	return _taille_vue


## Pixels physiques par pixel virtuel (étirement × facteur d'interface).
func echelle() -> float:
	return _echelle


## Force N (0 = automatique).
func forcer_facteur(n: int) -> void:
	_force = maxi(0, n)
	recalculer()


## Hauteur des bandes du HUD (barre haute, frise), en px virtuels. Défaut : 96 et 72.
func regler_marges(haut_virtuel: float, bas_virtuel: float) -> void:
	_marge_haut = haut_virtuel
	_marge_bas = bas_virtuel
	_appliquer_camera()
	vue_change.emit()


## Hauteur des bandes du HUD en px d'art (haut, bas).
func marges_art() -> Vector2:
	return Vector2(_marge_haut, _marge_bas) * _echelle_xy.y / px_physiques_par_art()


## Cadre la zone : son bas posé sur le haut de la frise, centrée en largeur, arrondi au pixel d'art.
func cadrer(zone: Rect2) -> void:
	_zone = zone
	_a_zone = true
	_appliquer_camera()
	vue_change.emit()


func _appliquer_camera() -> void:
	if not _a_zone:
		return
	var bas_libre := float(_taille_vue.y) - marges_art().y
	camera.position = Vector2(roundf(_zone.get_center().x - _taille_vue.x / 2.0), ceilf(_zone.end.y - bas_libre))


## Coin haut gauche de la vue, en px d'art du monde.
func origine_vue() -> Vector2:
	return camera.position


## px d'art du monde → px virtuels de l'interface.
func monde_vers_ecran(p: Vector2) -> Vector2:
	return (p - camera.position) * px_physiques_par_art() / _echelle_xy


## px virtuels de l'interface → px d'art du monde.
func ecran_vers_monde(p: Vector2) -> Vector2:
	return p * _echelle_xy / px_physiques_par_art() + camera.position


## px d'art par px virtuel, axe par axe.
func art_par_virtuel() -> Vector2:
	return _echelle_xy / px_physiques_par_art()


## Image du SubViewport, avant agrandissement (taille_vue).
func image_monde() -> Image:
	return _sv.get_texture().get_image()


## Contrôle des pixels nets (repris de la vitrine PX0, lot 02) : renvoie (blocs complets, blocs non uniformes)
## pour des blocs n × n alignés sur l'origine. Voie rapide : réduction puis agrandissement au plus proche
## voisin, comparés à l'original ; en cas d'écart, comptage exact bloc par bloc.
static func controler_blocs(img: Image, n: int) -> Vector2i:
	var src := Image.new()
	src.copy_from(img)
	src.convert(Image.FORMAT_RGBA8)
	var bx := src.get_width() / n
	var by := src.get_height() / n
	if bx == 0 or by == 0:
		return Vector2i.ZERO
	src.crop(bx * n, by * n)
	if n == 1:
		return Vector2i(bx * by, 0)
	var aller := Image.new()
	aller.copy_from(src)
	aller.resize(bx, by, Image.INTERPOLATE_NEAREST)
	aller.resize(bx * n, by * n, Image.INTERPOLATE_NEAREST)
	if aller.get_data() == src.get_data():
		return Vector2i(bx * by, 0)
	var d := src.get_data()
	var l := bx * n
	var irreguliers := 0
	for j in by:
		for i in bx:
			var ref := d.decode_u32(((j * n) * l + i * n) * 4)
			var ok := true
			for y in n:
				var base := ((j * n + y) * l + i * n) * 4
				for x in n:
					if d.decode_u32(base + x * 4) != ref:
						ok = false
						break
				if not ok:
					break
			if not ok:
				irreguliers += 1
	return Vector2i(bx * by, irreguliers)
