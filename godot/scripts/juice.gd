extends Node
## Autoload « Juice » : effets de « game feel » (09 §3) : secousse, compteurs qui roulent, pop,
## montants flottants, pièces volantes. Les scènes enregistrent la caméra, le HUD et le calque d'effets.

var animations_reduites := false   # option câblée en constante dans la tranche (09 §5.1)
var trauma := 0.0
var camera: Camera2D = null
var hud: CanvasLayer = null
var calque_effets: CanvasLayer = null
var _bruit := FastNoiseLite.new()
var _t := 0.0


func _ready() -> void:
	_bruit.frequency = 0.5
	process_mode = Node.PROCESS_MODE_ALWAYS


## Facteur de durée des effets selon la vitesse du jeu (×2 : 0,75 ; ×3 : 0,5).
func duree(d: float) -> float:
	match Partie.vitesse:
		2:
			return d * 0.75
		3:
			return d * 0.5
	return d


func secouer(q: float) -> void:
	if animations_reduites:
		return
	trauma = minf(1.0, trauma + q)
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(60)


func _process(delta: float) -> void:
	_t += delta * 40.0
	trauma = maxf(0.0, trauma - 1.6 * delta)
	var d := Vector2(_bruit.get_noise_2d(_t, 0.0), _bruit.get_noise_2d(0.0, _t)) * 20.0 * trauma * trauma
	if camera != null:
		camera.offset = d
	if hud != null:
		hud.offset = d * 0.3


## Compteur qui roule de « de » à « a », puis pop (09 §3, effet 5).
func rouler(label: Label, de: float, a: float, formater: Callable, duree_s := 0.6, couleur_pop := Color.TRANSPARENT) -> void:
	if label.has_meta("tween_roule"):
		var ancien: Tween = label.get_meta("tween_roule")
		if ancien != null and ancien.is_valid():
			ancien.kill()
	if animations_reduites or absf(a - de) < 0.005 or duree_s <= 0.0:
		label.text = formater.call(a)
		return
	var t := label.create_tween()
	label.set_meta("tween_roule", t)
	t.tween_method(func(v: float) -> void: label.text = formater.call(v), de, a, duree_s) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_callback(func() -> void: pop(label, couleur_pop))


func pop(c: Control, couleur := Color.TRANSPARENT) -> void:
	if animations_reduites:
		return
	c.pivot_offset = c.size / 2.0
	var t := c.create_tween()
	t.tween_property(c, "scale", Vector2.ONE * 1.10, 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(c, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if couleur.a > 0.0:
		c.modulate = Color(couleur.r * 1.2, couleur.g * 1.2, couleur.b * 1.2)
		var t2 := c.create_tween()
		t2.tween_property(c, "modulate", Color.WHITE, 0.6)


## Montant flottant qui monte de 60 px et s'efface (position en coordonnées d'écran logiques).
func flottant(texte: String, pos: Vector2, couleur: Color) -> void:
	if calque_effets == null:
		return
	var l := Style.label(texte, 30, Style.chiffres(), couleur)
	l.add_theme_constant_override("outline_size", 6)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
	calque_effets.add_child(l)
	l.position = pos - Vector2(l.get_minimum_size().x / 2.0, 20)
	var t := l.create_tween().set_parallel(true)
	t.tween_property(l, "position:y", l.position.y - 60.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(l, "modulate:a", 0.0, 0.3).set_delay(0.6)
	t.chain().tween_callback(l.queue_free)


## Pièces qui volent de « depart » à « arrivee » (écran logique) le long d'une courbe (effet 6).
func pieces(depart: Vector2, arrivee: Vector2, n: int, a_chaque_arrivee := Callable(), cuivre := false) -> void:
	if calque_effets == null or animations_reduites:
		if a_chaque_arrivee.is_valid():
			a_chaque_arrivee.call()
		return
	for i in n:
		var p := Piece.new()
		p.cuivre = cuivre
		calque_effets.add_child(p)
		p.position = depart
		p.voler(depart, arrivee, 0.55, 0.05 * i, a_chaque_arrivee)
