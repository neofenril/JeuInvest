extends Node2D
## « Ma rue » (09 §2) : diorama en aplats, 4 plans de parallaxe, 3 bâtiments jouables, trafic, ciel,
## cycle jour et nuit (60 s, figé en pause), saisons, particules (neige, feuilles, pluie, fumée).
## Monde : x de −2 600 à 2 600, y négatif vers le haut, sol des bâtiments à y = −160.
## Zone utile (toujours visible) : 1 400 × 700 centrée, alignée sur le bas (y = 0).

signal batiment_touche(id: String)

const ZONE := Rect2(-700, -790, 1400, 780)
const ZONE_TITRE := Rect2(-800, -980, 1600, 1000)
const CYCLE := 60.0
const NUIT_TEINTE := Color("5a5f8c")
const COUCHANT_TEINTE := Color("ffd9c2")

var anime := true                 # trafic et ciel animés (faux en pause)
var facteur_trafic := 1.0
var interactif := false
var mode_titre := false
var phase := 0.12                 # 0 → 1 : position dans le cycle jour/nuit
var nuit := 0.0
var krach := 0.0                  # ciel d'orage (0 → 1)
var gel := 0.0                    # pause
var signal_t := -1.0              # signal banque → maison (0 → 1 ; < 0 : inactif)
var pluie: bool = false:
	set = _set_pluie

var ciel_mat: ShaderMaterial
var camera: Camera2D
var maison: Batiment
var media: Batiment
var banque: Batiment
var voiture_maison: Node2D
var potelet: Node2D
var passants: Array = []

var _fond: Node2D
var _trafic: Node2D
var _lum_bat: Node2D
var _dessus: Node2D
var _lum_avant: Node2D
var _avant: Node2D                 # au-dessus de tout (cigogne, étoile « BONK »), teinté comme la rue
var _plans: Array = []
var _rue: Node2D
var _voitures: Array = []
var _reverberes: Array = []
var _survol: Batiment = null
var _neige: CPUParticles2D
var _pluie: CPUParticles2D
var _feuilles: Array = []
var _cadre_pos := Vector2.ZERO
var _cadre_zoom := 1.0
var _cam_tween: Tween
var _t_titre := 0.0
var _vise := false


func _ready() -> void:
	_fond = Node2D.new()
	_fond.name = "Fond"
	add_child(_fond)
	for g in ["nuages", "horizon", "lointain"]:
		var p := Node2D.new()
		p.set_script(load("res://scripts/ville/plan_fond.gd"))
		p.set("genre", g)
		_fond.add_child(p)
		_plans.append(p)
	_rue = Node2D.new()
	_rue.set_script(load("res://scripts/ville/rue.gd"))
	_fond.add_child(_rue)
	maison = _batiment("res://scripts/ville/maison.gd", Vector2(-480, -160))
	media = _batiment("res://scripts/ville/media.gd", Vector2(0, -160))
	banque = _batiment("res://scripts/ville/banque.gd", Vector2(470, -160))
	# Lumières des bâtiments (mélange additif, non assombries la nuit)
	_lum_bat = _calque_lumiere(_dessiner_lumieres_bat)
	_dessus = Node2D.new()
	_dessus.draw.connect(_dessiner_dessus)
	add_child(_dessus)
	# Trafic, passants, réverbères (triés par profondeur)
	_trafic = Node2D.new()
	_trafic.y_sort_enabled = true
	add_child(_trafic)
	_avant = Node2D.new()
	_creer_trafic()
	_lum_avant = _calque_lumiere(_dessiner_lumieres_avant)
	add_child(_avant)
	# Particules
	_feuilles = [_creer_feuilles(Vector2(-720, -330)), _creer_feuilles(Vector2(730, -330))]
	camera = Camera2D.new()
	camera.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
	add_child(camera)
	camera.make_current()
	_neige = _creer_neige()
	_pluie = _creer_pluie()
	camera.add_child(_neige)
	camera.add_child(_pluie)


func _batiment(chemin: String, pos: Vector2) -> Batiment:
	var b := Node2D.new()
	b.set_script(load(chemin))
	b.position = pos
	_fond.add_child(b)
	return b as Batiment


func _calque_lumiere(dessin: Callable) -> Node2D:
	var n := Node2D.new()
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	n.material = mat
	n.draw.connect(dessin)
	add_child(n)
	return n


func _creer_trafic() -> void:
	voiture_maison = _voiture(Vector2(-470, -122), Color("ece8df"), 0.0, 1.0)
	potelet = ajouter_accessoire("potelet", Vector2(-352, -118))
	_voitures.append(_voiture(Vector2(-900, -84), Color("c8382e"), 170.0, 1.0))
	_voitures.append(_voiture(Vector2(500, -84), Color("23366b"), 140.0, 1.0))
	_voitures.append(_voiture(Vector2(200, -40), Color("e0b23a"), 160.0, -1.0))
	_voitures.append(_voiture(Vector2(-1300, -40), Color("ece8df"), 190.0, -1.0))
	var tenues := [[Color("3f6fb5"), Color("2d3446"), Color("f1c9a5"), Color("4a3426")],
		[Color("d9486a"), Color("343a4f"), Color("e0b48e"), Color("1f1a17")],
		[Color("6a9f58"), Color("3b3f4a"), Color("c99a72"), Color("6b4a32")],
		[Color("e8a33d"), Color("2a3142"), Color("f3d2b4"), Color("b88a3a")],
		[Color("7d5ba6"), Color("2d3446"), Color("8d5f3e"), Color("1f1a17")],
		[Color("d0d4da"), Color("41495c"), Color("f1c9a5"), Color("6b4a32")]]
	var places := [[-1100.0, -126.0, 46.0, 1.0], [-250.0, -126.0, 38.0, -1.0], [620.0, -126.0, 52.0, 1.0],
		[-600.0, -4.0, 55.0, -1.0], [300.0, -4.0, 44.0, 1.0], [1100.0, -4.0, 50.0, -1.0]]
	for i in places.size():
		var p := Node2D.new()
		p.set_script(load("res://scripts/ville/passant.gd"))
		var t: Array = tenues[i]
		p.set("corps", t[0])
		p.set("bas", t[1])
		p.set("peau", t[2])
		p.set("cheveux", t[3])
		p.set("vitesse", places[i][2])
		p.set("walkman", i % 2 == 0)
		p.set("ville", self)
		p.position = Vector2(places[i][0], places[i][1])
		p.scale = Vector2(places[i][3], 1.0)
		_trafic.add_child(p)
		passants.append(p)
	for x in [-1150.0, -560.0, 20.0, 560.0, 1150.0]:
		var r := Node2D.new()
		r.set_script(load("res://scripts/ville/reverbere.gd"))
		r.position = Vector2(x, -20)
		_trafic.add_child(r)
		_reverberes.append(r)


func _voiture(pos: Vector2, c: Color, v: float, sens: float) -> Node2D:
	var n := Node2D.new()
	n.set_script(load("res://scripts/ville/voiture.gd"))
	n.set("couleur", c)
	n.set("vitesse", v)
	n.set("ville", self)
	n.position = pos
	n.scale = Vector2(sens, 1.0)
	_trafic.add_child(n)
	return n


## Accessoire animé (scripts/ville/accessoire.gd) : dans la rue (trié en profondeur avec le trafic)
## ou au premier plan (dans_la_rue = false : cigogne, étoile « BONK »).
func ajouter_accessoire(genre: String, pos: Vector2, dans_la_rue := true) -> Node2D:
	var n := Node2D.new()
	n.set_script(load("res://scripts/ville/accessoire.gd"))
	n.set("genre", genre)
	n.position = pos
	(_trafic if dans_la_rue else _avant).add_child(n)
	return n


static func _texture_rond(d: int) -> ImageTexture:
	var img := Image.create(d, d, false, Image.FORMAT_RGBA8)
	var r := d / 2.0
	for y in d:
		for x in d:
			img.set_pixel(x, y, Color(1, 1, 1, clampf(r - Vector2(x + 0.5 - r, y + 0.5 - r).length(), 0.0, 1.0)))
	return ImageTexture.create_from_image(img)


func _creer_neige() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.texture = _texture_rond(8)
	p.amount = 60
	p.lifetime = 9.0
	p.preprocess = 9.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.direction = Vector2(0.2, 1)
	p.spread = 20.0
	p.gravity = Vector2(8, 30)
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 60.0
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.1
	p.color = Color(1, 1, 1, 0.9)
	p.local_coords = false
	p.emitting = false
	return p


func _creer_pluie() -> CPUParticles2D:
	var img := Image.create(3, 22, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	var p := CPUParticles2D.new()
	p.texture = ImageTexture.create_from_image(img)
	p.amount = 120
	p.lifetime = 1.0
	p.preprocess = 1.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.direction = Vector2(-0.18, 1)
	p.spread = 2.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 1100.0
	p.initial_velocity_max = 1300.0
	p.particle_flag_align_y = true
	p.color = Color(0.75, 0.82, 0.95, 0.45)
	p.local_coords = false
	p.emitting = false
	return p


func _creer_feuilles(pos: Vector2) -> CPUParticles2D:
	var img := Image.create(10, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	var p := CPUParticles2D.new()
	p.texture = ImageTexture.create_from_image(img)
	p.position = pos
	p.amount = 6
	p.lifetime = 5.0
	p.preprocess = 5.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 60.0
	p.gravity = Vector2(12, 40)
	p.initial_velocity_min = 5.0
	p.initial_velocity_max = 20.0
	p.angular_velocity_min = -180.0
	p.angular_velocity_max = 180.0
	p.color = Color("e39b4b")
	p.emitting = false
	_fond.add_child(p)
	return p


func _set_pluie(v: bool) -> void:
	pluie = v
	if _pluie != null:
		_pluie.emitting = v


## Saison et époque selon le mois du jeu.
func regler_mois(mois: int, annee: int) -> void:
	var hiver := mois == 12 or mois <= 2
	_rue.call("regler_saison", mois, annee)
	maison.call("regler_hiver", hiver)
	for b in [media, banque]:
		b.hiver = hiver
		b.annee = annee
		b.queue_redraw()
	maison.annee = annee
	_neige.emitting = hiver
	for f in _feuilles:
		f.emitting = mois >= 9 and mois <= 11


# =====================================================================
# Temps qui passe : ciel, teinte, parallaxe
# =====================================================================

func _process(delta: float) -> void:
	if mode_titre:
		_t_titre += delta
		camera.position.x = _cadre_pos.x + sin(_t_titre * TAU / 20.0) * 380.0
	elif anime:
		phase = fmod(phase + delta / CYCLE, 1.0)
	var jc := _jour_couchant(phase)
	var jour := jc.x
	nuit = 1.0 - jour
	var teinte := Color.WHITE.lerp(NUIT_TEINTE, nuit).lerp(COUCHANT_TEINTE, jc.y * 0.45)
	teinte = teinte.lerp(Color(0.72, 0.64, 0.7), krach * 0.45)
	teinte = teinte.lerp(Color(0.86, 0.92, 1.05), gel * 0.35)
	_fond.modulate = teinte
	_trafic.modulate = teinte
	_avant.modulate = teinte
	if ciel_mat != null:
		ciel_mat.set_shader_parameter("jour", jour)
		ciel_mat.set_shader_parameter("couchant", jc.y)
		ciel_mat.set_shader_parameter("krach", krach)
		ciel_mat.set_shader_parameter("gel", gel)
	for b in [maison, media, banque]:
		b.nuit = nuit
	for p in _plans:
		p.position.x = camera.position.x * (1.0 - float(p.get("parallaxe")))
	# Trafic : suit la vitesse du jeu (data/rythme.json), freine jusqu'à l'arrêt en pause.
	# Pendant une séquence de bâtiment (anime mais temps en pause), la rue garde l'allure ×1.
	var cible := 0.0
	if mode_titre:
		cible = 1.0
	elif anime:
		cible = Partie.facteur_trafic(maxi(1, Partie.vitesse))
	var rythme := Donnees.charger("rythme")
	var transition := maxf(0.05, float(rythme.get("transition_trafic_s", 0.6)))
	var plus_rapide: float = float(rythme["trafic"].max())
	facteur_trafic = move_toward(facteur_trafic, cible, delta * plus_rapide / transition)
	_lum_bat.queue_redraw()
	_dessus.queue_redraw()
	_lum_avant.queue_redraw()


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


func _dessiner_lumieres_bat() -> void:
	for b in [maison, media, banque]:
		_lum_bat.draw_set_transform(b.position)
		b.dessiner_lumieres(_lum_bat)
	_lum_bat.draw_set_transform(Vector2.ZERO)


func _dessiner_dessus() -> void:
	_dessus.draw_set_transform(banque.position)
	banque.call("dessiner_silhouette", _dessus)
	_dessus.draw_set_transform(Vector2.ZERO)


func _dessiner_lumieres_avant() -> void:
	for r in _reverberes:
		_lum_avant.draw_set_transform(r.position)
		r.call("dessiner_lumieres", _lum_avant, nuit)
	for v in _voitures:
		_lum_avant.draw_set_transform(v.position)
		v.call("dessiner_lumieres", _lum_avant, nuit)
	_lum_avant.draw_set_transform(Vector2.ZERO)
	# Signal lumineux banque → maison (appel du banquier)
	if signal_t >= 0.0:
		var a := banque.position + Vector2(0, -420)
		var b := maison.position + Vector2(60, -240)
		var c := (a + b) / 2.0 + Vector2(0, -260)
		for i in 5:
			var u := clampf(signal_t - i * 0.07, 0.0, 1.0)
			if u <= 0.0 or u >= 1.0:
				continue
			var p := a.lerp(c, u).lerp(c.lerp(b, u), u)
			Dessin.halo(_lum_avant, p, 22, Color(Style.OR, 0.7))
			_lum_avant.draw_circle(p, 6, Color(1, 0.95, 0.8))


# =====================================================================
# Caméra : cadrage de la zone utile dans le rectangle libre de l'écran
# =====================================================================

## libre : rectangle de l'écran (coordonnées logiques) non couvert par le HUD.
func cadrer(libre: Rect2, duree := 0.0) -> void:
	var zone := ZONE_TITRE if mode_titre else ZONE
	var z := minf(libre.size.x / zone.size.x, libre.size.y / zone.size.y)
	var ecran := get_viewport_rect().size
	var ancre_monde := Vector2(zone.get_center().x, zone.end.y)
	var ancre_ecran := Vector2(libre.get_center().x, libre.end.y)
	_cadre_zoom = z
	_cadre_pos = ancre_monde - (ancre_ecran - ecran / 2.0) / z
	if _vise:
		return
	_aller(_cadre_pos, z, duree)
	var visible := ecran / z
	for p in [_neige, _pluie]:
		p.emission_rect_extents = Vector2(visible.x * 0.7, 20)
		p.position = Vector2(0, -visible.y / 2.0 - 40)


func _aller(pos: Vector2, z: float, duree: float, trans := Tween.TRANS_CUBIC) -> Tween:
	if _cam_tween != null and _cam_tween.is_valid():
		_cam_tween.kill()
	if duree <= 0.0 or Juice.animations_reduites:
		camera.position = pos
		camera.zoom = Vector2.ONE * z
		return null
	_cam_tween = create_tween().set_parallel(true).set_trans(trans).set_ease(Tween.EASE_IN_OUT)
	_cam_tween.tween_property(camera, "position", pos, duree)
	_cam_tween.tween_property(camera, "zoom", Vector2.ONE * z, duree)
	return _cam_tween


## La caméra désigne la source : glisse et zoome de 6 % vers le bâtiment.
func viser(b: Batiment, duree := 0.35, zoom_en_plus := 1.06) -> void:
	_vise = true
	var centre := b.position + Vector2(0, b.zone.get_center().y)
	var cible := _cadre_pos.lerp(centre, 0.35)
	_aller(cible, _cadre_zoom * zoom_en_plus, duree)


func revenir(duree := 0.35) -> void:
	_vise = false
	_aller(_cadre_pos, _cadre_zoom, duree)


## Plongée vers la maison (bouton Jouer).
func plonger_vers_maison(duree := 0.8) -> Tween:
	_vise = true
	var cible := maison.position + Vector2(40, -150)
	return _aller(cible, _cadre_zoom * 1.6, duree, Tween.TRANS_QUART)


func position_ecran(monde: Vector2) -> Vector2:
	return get_canvas_transform() * monde


func ecran_batiment(b: Batiment, decalage := Vector2.ZERO) -> Vector2:
	return position_ecran(b.position + decalage)


# =====================================================================
# Toucher et survol des bâtiments
# =====================================================================

func _unhandled_input(event: InputEvent) -> void:
	if not interactif:
		if _survol != null:
			_survol.survoler(false)
			_survol = null
		return
	if event is InputEventMouseMotion:
		var b := _batiment_sous(get_global_mouse_position())
		if b != _survol:
			if _survol != null:
				_survol.survoler(false)
			_survol = b
			if b != null:
				b.survoler(true)
	elif (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
		var pos: Vector2 = get_canvas_transform().affine_inverse() * event.position
		var b2 := _batiment_sous(pos)
		if b2 != null:
			b2.enfoncer()
			batiment_touche.emit(b2.id)
			get_viewport().set_input_as_handled()


func _batiment_sous(monde: Vector2) -> Batiment:
	for b in [media, banque, maison]:
		if b.contient(monde - b.position):
			return b
	return null


func batiment(id: String) -> Batiment:
	return {"maison": maison, "media": media, "banque": banque}.get(id, null)
