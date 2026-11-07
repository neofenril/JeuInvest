extends Node
## Autoload « Juice » : effets de « game feel » (09 §3) : secousse, compteurs qui roulent, pop,
## montants flottants, pièces volantes. Les scènes enregistrent la caméra, le HUD et le calque d'effets.

const ARC_PIECE := 120.0       # pièces du mois (lot 02, D8) : hauteur de l'arc, px virtuels
const DUREE_PIECE := 0.9
const DECALAGE_PIECE := 0.08
const TEXEL := 3.0             # un texel de l'interface = 3 px virtuels (CadresPixel)

var pieces_creees := 0                   # nœuds Piece créés depuis le lancement (contrôles des captures)
var derniere_arrivee := Vector2(-1, -1)  # position de la dernière pièce arrivée (contrôles)
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


## Facteur de durée des effets selon la vitesse du jeu (×2 : 0,75 ; ×3 : 0,5 ; saut « jusqu'au prochain
## courrier » : comme ×3, quelle que soit la vitesse d'avant l'appui, lot 02).
func duree(d: float) -> float:
	if Partie.saut_actif:
		return d * 0.5
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
		# Caméra de la rue pixel (PX1) : décalage en px d'art entiers, 4 px au plus
		var o := (d * 0.4).round().clamp(Vector2(-4, -4), Vector2(4, 4))
		if camera.offset != o:
			camera.offset = o
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
	# Contour épais et presque opaque : lisible sur la brique, les arbres et le ciel (cuivre sur brique, lot 02)
	l.add_theme_constant_override("outline_size", 10)
	l.add_theme_color_override("font_outline_color", Color(Style.ENCRE, 0.9))
	calque_effets.add_child(l)
	l.position = pos - Vector2(l.get_minimum_size().x / 2.0, 20)
	var t := l.create_tween().set_parallel(true)
	t.tween_property(l, "position:y", l.position.y - 60.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(l, "modulate:a", 0.0, 0.3).set_delay(0.6)
	t.chain().tween_callback(l.queue_free)


## Pièces qui volent de « depart » à « arrivee » (écran logique) le long d'une courbe (effet 6).
## Jamais pendant un saut (la rue file à ×6) : le rappel d'arrivée est appelé tout de suite.
func pieces(depart: Vector2, arrivee: Vector2, n: int, a_chaque_arrivee := Callable(), cuivre := false) -> void:
	if calque_effets == null or animations_reduites or Partie.saut_actif:
		if a_chaque_arrivee.is_valid():
			a_chaque_arrivee.call()
		return
	for i in n:
		var p := Piece.new()
		p.cuivre = cuivre
		calque_effets.add_child(p)
		pieces_creees += 1
		p.position = depart
		p.voler(depart, arrivee, 0.55, 0.05 * i, a_chaque_arrivee)


## Pièces du mois (lot 02, D8) : depart et arrivee sont des Callable -> Vector2 (écran logique) relus à chaque
## image (la rue peut glisser pendant le vol : la pièce arrive quand même au bon endroit). Arc de ARC_PIECE px
## au-dessus du milieu, DUREE_PIECE s, pièces décalées de DECALAGE_PIECE s, positions arrondies au texel (3 px).
## a_chaque_depart / a_chaque_arrivee : appelés pour chaque pièce (saut d'une flèche de bord, montant flottant).
## Rien pendant un saut ni en animations réduites (les rappels d'arrivée sont alors appelés tout de suite).
func pieces_suivies(depart: Callable, arrivee: Callable, n: int, cuivre := false, a_chaque_arrivee := Callable(), a_chaque_depart := Callable()) -> void:
	if calque_effets == null or animations_reduites or Partie.saut_actif:
		for i in n:
			if a_chaque_arrivee.is_valid():
				a_chaque_arrivee.call()
		return
	for i in n:
		var p := Piece.new()
		p.cuivre = cuivre
		p.visible = false
		calque_effets.add_child(p)
		pieces_creees += 1
		var t := p.create_tween()
		t.tween_interval(DECALAGE_PIECE * i)
		t.tween_callback(_piece_part.bind(p, depart, arrivee, a_chaque_depart))
		t.tween_method(_piece_suit.bind(p, depart, arrivee), 0.0, 1.0, DUREE_PIECE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		t.tween_callback(_piece_arrive.bind(p, arrivee, a_chaque_arrivee))


func _piece_part(p: Piece, depart: Callable, arrivee: Callable, a_chaque_depart: Callable) -> void:
	_piece_suit(0.0, p, depart, arrivee)
	p.visible = true
	if a_chaque_depart.is_valid():
		a_chaque_depart.call()


func _piece_suit(u: float, p: Piece, depart: Callable, arrivee: Callable) -> void:
	var d: Vector2 = depart.call()
	var a: Vector2 = arrivee.call()
	var c := (d + a) / 2.0 + Vector2(0, -ARC_PIECE)
	var pos := d.lerp(c, u).lerp(c.lerp(a, u), u)
	p.position = (pos / TEXEL).round() * TEXEL


func _piece_arrive(p: Piece, arrivee: Callable, a_chaque_arrivee: Callable) -> void:
	var a: Vector2 = arrivee.call()
	p.position = (a / TEXEL).round() * TEXEL
	derniere_arrivee = p.position
	if a_chaque_arrivee.is_valid():
		a_chaque_arrivee.call()
	p.queue_free()
