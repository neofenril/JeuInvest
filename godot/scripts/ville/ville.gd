extends Node2D
## « Ma rue » en pixel art (lot PX1, docs/16 §9) : la rue de briques de PX0 quater, plus large que l'écran.
## La rue (scripts/ville/rue.gd) est rendue dans le SubViewport d'une VuePixel plein écran, dans un CanvasLayer
## sous le HUD : 540 px d'art de haut sur tous les écrans, rendue à N entier ≥ 2 puis réduite (§2.3).
## La caméra glisse vers le bâtiment qui parle (viser, aller_vers) puis revient ; le joueur fait défiler la rue
## (glisser, molette, flèches ← →, inertie courte). La ville ne calcule rien : elle lit Partie et montre.
## API conservée : lot_px1 §2.1 ; ajouts : §2.2.

signal batiment_touche(id: String)
signal camera_bougee

const RUE := preload("res://scripts/ville/rue.gd")
const PERSONNAGES := ["gerard", "tata", "matelas", "jeanmi", "lopez", "lefranc", "passant_1", "passant_2", "passant_3"]
const CYCLE := 60.0
const SEUIL_TOUCHER := 14.0
const HAUT_MAISON := 140.0               # haut de la cheminée (144) moins une marge
const INERTIE_MAX_S := 0.35
const BAS_MAX := 504.0                   # bas du rectangle libre au plus (haut de la frise à 1080p)

var anime := true
var facteur_trafic := 1.0
var interactif := false
var mode_titre := false
var phase := 0.12
var nuit := 0.0
var krach := 0.0
var gel := 0.0
var signal_t := -1.0                     # compatibilité (le signal est un accessoire des séquences)
var pluie: bool = false:
	set(v):
		pluie = v
		if rue != null:
			rue.call("regler_pluie", v)
var ciel_mat: ShaderMaterial             # accepté, ignoré (le ciel est dans la rue)
var camera: Camera2D
var maison: Batiment
var media: Batiment
var banque: Batiment
var voiture_maison: Node2D
var potelet: Node2D
var passants: Array = []
var _voitures: Array = []
var vue: VuePixel
var rue: Node2D

var _calque: CanvasLayer
var _libre := Rect2(0, 0, 1920, 1080)
var _cx := 114.0
var _cy := 0.0
var _haut := HAUT_MAISON
var _repos_cx := 114.0
var _repos_auto := true
var _avant := NAN
var _vise := false
var _cam_tween: Tween
var _appui := false
var _appui_pos := Vector2.ZERO
var _glisse := false
var _vitesse_glisse := 0.0
var _inertie := 0.0
var _frein := 0.0
var _survol: Batiment = null
var _humeur := 1


func _ready() -> void:
	_calque = CanvasLayer.new()
	_calque.name = "CalqueRue"
	_calque.layer = -5
	add_child(_calque)
	vue = VuePixel.new()
	vue.mode_reduction = true
	_calque.add_child(vue)
	rue = Node2D.new()
	rue.set_script(RUE)
	vue.monde.add_child(rue)
	camera = vue.camera
	maison = rue.get("maison")
	banque = rue.get("banque")
	media = rue.get("media")
	voiture_maison = rue.get("voiture_maison")
	potelet = rue.get("potelet")
	passants = rue.get("passants")
	_voitures = rue.get("voitures")
	vue.vue_change.connect(_recalculer)
	_recalculer()


# =====================================================================
# Temps : jour / nuit, orage, gel, trafic
# =====================================================================

func _process(delta: float) -> void:
	if anime and not mode_titre:
		phase = fmod(phase + delta / CYCLE, 1.0)
	var jc := _jour_couchant(phase)
	nuit = 1.0 - jc.x
	rue.call("regler_ciel", nuit, krach)
	vue.teinter(Color.WHITE.lerp(PalettePixel.couleur("gel"), clampf(gel, 0.0, 1.0) * 0.35))
	var cible := 0.0
	if mode_titre:
		cible = 1.0
	elif anime:
		cible = Partie.facteur_trafic(maxi(1, Partie.vitesse))
	var rythme := Donnees.charger("rythme")
	var transition := maxf(0.05, float(rythme.get("transition_trafic_s", 0.6)))
	var plus_rapide: float = float(rythme["trafic"].max())
	facteur_trafic = move_toward(facteur_trafic, cible, delta * plus_rapide / transition)
	rue.set("facteur", facteur_trafic)
	rue.set("anime", anime)
	maison.set("anime", anime)
	media.set("anime", anime)
	if _inertie != 0.0:
		_cx += _inertie * delta
		_inertie = move_toward(_inertie, 0.0, _frein * delta)
		_repos_cx = _cx
		_appliquer()
		_repos_cx = _cx


## (jour, couchant) selon la phase du cycle.
static func _jour_couchant(p: float) -> Vector2:
	if p < 0.5:
		return Vector2(1, 0)
	if p < 0.6:
		var k := (p - 0.5) / 0.1
		return Vector2(1.0 - k, sin(k * PI))
	if p < 0.85:
		return Vector2(0, 0)
	if p < 0.95:
		var k2 := (p - 0.85) / 0.1
		return Vector2(k2, sin(k2 * PI) * 0.6)
	return Vector2(1, 0)


## Saison et époque selon le mois du jeu.
func regler_mois(mois: int, annee: int) -> void:
	rue.call("regler_saison", mois, annee)


# =====================================================================
# Caméra
# =====================================================================

## Rectangle libre (laissé par le HUD) en px d'art, dans la vue.
func _libre_art() -> Rect2:
	var a := vue.art_par_virtuel()
	return Rect2(_libre.position * a, _libre.size * a)


## y de la caméra pour que « haut » (px d'art du monde) soit sous le haut du rectangle libre, le sol
## restant au-dessus de son bas.
func _cy_pour(haut: float) -> float:
	var la := _libre_art()
	var y_bas := clampf(haut - 4.0 + la.size.y, RUE.SOL + 4.0, BAS_MAX)
	return y_bas - la.end.y


## x du centre de la vue qui met x_monde au milieu du rectangle libre.
func _cx_pour(x_monde: float) -> float:
	var la := _libre_art()
	return x_monde - la.get_center().x + vue.taille_vue().x / 2.0


## x mini et maxi du centre de la vue (px d'art).
func bornes_rue() -> Vector2:
	var demi := vue.taille_vue().x / 2.0
	var a := RUE.GAUCHE + 200.0 + demi
	var b := RUE.DROITE - 200.0 - demi
	if a > b:
		a = (a + b) / 2.0
		b = a
	return Vector2(a, b)


func position_camera() -> float:
	return _cx


func _recalculer() -> void:
	if _repos_auto:
		_repos_cx = _cx_pour(maison.position.x)
	if not _vise and (_cam_tween == null or not _cam_tween.is_valid()):
		_cy = _cy_pour(_haut)
	_appliquer()


func _appliquer() -> void:
	var b := bornes_rue()
	_cx = clampf(_cx, b.x, b.y)
	var tv := vue.taille_vue()
	var p := Vector2(roundf(_cx - tv.x / 2.0), roundf(_cy))
	rue.set("vue", Rect2(p, Vector2(tv)))
	if camera.position != p:
		camera.position = p
		camera_bougee.emit()


func _aller(cx: float, haut: float, duree: float, trans := Tween.TRANS_CUBIC) -> Tween:
	if _cam_tween != null and _cam_tween.is_valid():
		_cam_tween.kill()
	_inertie = 0.0
	_haut = haut
	var b := bornes_rue()
	var cible := Vector2(clampf(cx, b.x, b.y), _cy_pour(haut))
	if duree <= 0.0 or Juice.animations_reduites:
		_cx = cible.x
		_cy = cible.y
		_appliquer()
		_cam_tween = create_tween()
		_cam_tween.tween_interval(0.0)
		return _cam_tween
	_cam_tween = create_tween().set_trans(trans).set_ease(Tween.EASE_IN_OUT)
	_cam_tween.tween_method(_poser_camera, Vector2(_cx, _cy), cible, duree)
	return _cam_tween


func _poser_camera(p: Vector2) -> void:
	_cx = p.x
	_cy = p.y
	_appliquer()


## libre : rectangle de l'écran (px virtuels) non couvert par le HUD. Le sol au-dessus de son bas, la
## cheminée de la maison sous son haut ; la position horizontale est gardée (la maison reste centrée tant que
## le joueur n'a pas fait défiler la rue).
func cadrer(libre: Rect2, duree := 0.0) -> void:
	_libre = libre
	if mode_titre:
		_aller(media.position.x, media.position.y - media.taille().y - 40.0, 0.0)
		return
	if _repos_auto:
		_repos_cx = _cx_pour(maison.position.x)
	if _vise:
		return
	_aller(_repos_cx, HAUT_MAISON, duree)


## Glisse horizontalement pour centrer b dans le rectangle libre (pas de zoom : zoom_en_plus ignoré).
func viser(b: Batiment, duree := 0.35, _zoom_en_plus := 1.06) -> void:
	if b == null:
		return
	if not _vise:
		_avant = _cx
	_vise = true
	_aller(_cx_pour(b.position.x), minf(HAUT_MAISON, b.position.y - b.taille().y), duree)


## Glisse vers un bâtiment sans changer la position de repos.
func aller_vers(id: String, duree := 0.5) -> Tween:
	var b := batiment(id)
	if b == null:
		return _aller(_cx, _haut, 0.0)
	if not _vise:
		_avant = _cx
	_vise = true
	return _aller(_cx_pour(b.position.x), minf(HAUT_MAISON, b.position.y - b.taille().y), duree)


## Revient à la position d'avant le dernier viser / aller_vers (ou à la maison).
func revenir(duree := 0.35) -> void:
	_vise = false
	if _repos_auto:
		_repos_cx = _cx_pour(maison.position.x)
	var x := _repos_cx if is_nan(_avant) else _avant
	_avant = NAN
	_aller(x, HAUT_MAISON, duree)


## Écran titre → jeu : la caméra glisse de la Gazette vers la maison.
func plonger_vers_maison(duree := 0.8) -> Tween:
	_vise = false
	_avant = NAN
	_repos_auto = true
	_repos_cx = _cx_pour(maison.position.x)
	return _aller(_repos_cx, HAUT_MAISON, duree, Tween.TRANS_QUART)


func position_ecran(monde: Vector2) -> Vector2:
	return vue.monde_vers_ecran(monde)


func ecran_batiment(b: Batiment, decalage := Vector2.ZERO) -> Vector2:
	return position_ecran(b.position + decalage)


func batiment(id: String) -> Batiment:
	return {"maison": maison, "media": media, "banque": banque}.get(id, null)


## Point de l'étiquette d'un bâtiment (px virtuels) : sur la chaussée, sous son milieu.
func point_etiquette(id: String) -> Vector2:
	var b := batiment(id)
	if b == null:
		return Vector2(-1, -1)
	return position_ecran(Vector2(b.position.x, RUE.SOL + 56))


## Vrai si le bâtiment est entièrement dans le rectangle libre.
func est_visible(id: String) -> bool:
	var b := batiment(id)
	if b == null:
		return false
	var t := b.taille()
	var r := Rect2(b.position.x - t.x / 2.0, b.position.y - t.y, t.x, t.y)
	var la := _libre_art()
	var libre_monde := Rect2(camera.position + la.position, la.size).grow(1.0)
	return libre_monde.encloses(r)


## Rectangle libre en px d'art du monde (contrôles des captures).
func libre_monde() -> Rect2:
	var la := _libre_art()
	return Rect2(camera.position + la.position, la.size)


# =====================================================================
# Sylvie, voisins
# =====================================================================

func regler_humeur_sylvie(h: int) -> void:
	_humeur = clampi(h, 0, 2)
	maison.set("humeur", _humeur)
	maison.call("cligner")


func humeur_sylvie() -> int:
	return _humeur


## Un personnage traverse la rue sur le trottoir, d'un bord de la vue à l'autre (sens 1 : de gauche à droite),
## puis il est libéré. Aucune règle de jeu : le moment du passage est décidé ailleurs (lot 05).
func faire_passer(qui: String, sens := 1, vitesse := 1.0) -> Node2D:
	var v: Rect2 = rue.get("vue")
	var x := v.position.x - 40.0 if sens > 0 else v.end.x + 40.0
	var p: Node2D = rue.call("ajouter_passant", qui, x, signi(sens) if sens != 0 else 1, 30.0 * maxf(0.05, vitesse), RUE.PIEDS + 4)
	p.set("sortie", true)
	return p


## Au-dessus de la tête d'un personnage (px virtuels).
func point_tete(n: Node2D) -> Vector2:
	if n == null or not is_instance_valid(n):
		return Vector2(-1, -1)
	return position_ecran(n.position + Vector2(0, -70))


# =====================================================================
# Toucher, survol, défilement
# =====================================================================

func _unhandled_input(event: InputEvent) -> void:
	if not interactif:
		if _survol != null:
			_survol.survoler(false)
			_survol = null
		_appui = false
		return
	var mb := event as InputEventMouseButton
	if mb != null:
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_appui = true
				_glisse = false
				_appui_pos = mb.position
				_vitesse_glisse = 0.0
				_inertie = 0.0
			elif _appui:
				_appui = false
				if not _glisse:
					var b := _batiment_sous(vue.ecran_vers_monde(mb.position))
					if b != null:
						b.enfoncer()
						batiment_touche.emit(b.id)
						get_viewport().set_input_as_handled()
				else:
					_lancer(_vitesse_glisse)
					get_viewport().set_input_as_handled()
		elif mb.pressed and mb.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_LEFT]:
			_lancer(-600.0)
			get_viewport().set_input_as_handled()
		elif mb.pressed and mb.button_index in [MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_RIGHT]:
			_lancer(600.0)
			get_viewport().set_input_as_handled()
		return
	var mm := event as InputEventMouseMotion
	if mm != null:
		if _appui and (mm.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			if not _glisse and (mm.position - _appui_pos).length() >= SEUIL_TOUCHER:
				_glisse = true
				_manuel()
				_cx -= (mm.position.x - _appui_pos.x) * vue.art_par_virtuel().x
			elif _glisse:
				var dx := -mm.relative.x * vue.art_par_virtuel().x
				_cx += dx
				var dt := maxf(1.0 / 120.0, get_process_delta_time())
				_vitesse_glisse = lerpf(_vitesse_glisse, dx / dt, 0.5)
			if _glisse:
				_repos_cx = _cx
				_appliquer()
				_repos_cx = _cx
				get_viewport().set_input_as_handled()
			return
		var b2 := _batiment_sous(vue.ecran_vers_monde(mm.position))
		if b2 != _survol:
			if _survol != null:
				_survol.survoler(false)
			_survol = b2
			if b2 != null:
				b2.survoler(true)
		return
	var k := event as InputEventKey
	if k != null and k.pressed and k.keycode in [KEY_LEFT, KEY_RIGHT]:
		_lancer(-700.0 if k.keycode == KEY_LEFT else 700.0)
		get_viewport().set_input_as_handled()


## Défilement manuel : la position choisie devient la position de repos.
func _manuel() -> void:
	if _cam_tween != null and _cam_tween.is_valid():
		_cam_tween.kill()
	_vise = false
	_avant = NAN
	_repos_auto = false


## Inertie courte (≤ 0,35 s) à partir d'une vitesse en px d'art par seconde.
func _lancer(v: float) -> void:
	_manuel()
	_inertie = clampf(v, -1600.0, 1600.0)
	_frein = absf(_inertie) / INERTIE_MAX_S


func _batiment_sous(monde: Vector2) -> Batiment:
	for b in [media, banque, maison]:
		if b.contient(monde - b.position):
			return b
	return null
