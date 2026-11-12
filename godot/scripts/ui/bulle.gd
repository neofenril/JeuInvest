class_name Bulle
extends Control
## Bulle de BD pixel (lot 03, I4 ; docs/16 §3.3 « 16 × 16 + pointe 6 × 4 », docs/15 §2.1, docs/17 §4.1) :
## petite phrase non bloquante au-dessus d'un personnage ou d'un bâtiment (Sylvie, passants).
## - ancre : Callable -> Vector2 (point d'écran logique visé), relue à chaque image ; Vector2(-1, -1) = la
##   bulle se cache tant que l'ancre est hors champ, et revient quand l'ancre revient ;
## - bornée au rectangle libre du HUD (Hud.rect_libre()) si un Hud est dans l'arbre, sinon à l'écran ;
## - au-dessus de l'ancre, pointe vers le bas ; sous l'ancre, pointe vers le haut quand la place manque ;
## - texte Atkinson (≥ 20 px virtuels), 2 lignes au plus (coupé aux mots, « … » si plus long) ;
## - portrait facultatif (nom d'une image de GrillePixel, ×3, docs/16 §3 : 32 × 32) ;
## - disparaît après « duree » secondes (fondu), ou par fermer().
## Aucun appelant dans le lot 03 (préparation de la vague 3).

const TAILLE_TEXTE := 22
const LARGEUR_TEXTE_MAX := 420.0     # px virtuels : au-delà, retour à la ligne (2 lignes au plus)
const TEXEL := 3.0                   # 1 texel d'interface = 3 px virtuels (CadresPixel.ECHELLE)
const POINTE := Vector2(18, 12)      # 6 × 4 texels
const RECOUVREMENT := 3.0            # la 1re rangée de la pointe recouvre le bord de la bulle
const ECART_ANCRE := 3.0             # entre le bout de la pointe et l'ancre
const COIN := 6.0                    # la pointe reste à 2 texels des coins arrondis
const MARGE_LIBRE := 6.0             # distance minimale au bord du rectangle libre

var ancre: Callable
var duree := 4.0
var reste := 4.0
## Rectangle de bornage imposé (tests) ; vide : Hud.rect_libre() ou l'écran.
var borne := Rect2()
## État lu par les tests et les captures.
var pointe_vers_bas := true
var cadre: PanelContainer
var pointe: TextureRect
var texte_label: Label
var _hud: Node = null
var _fermeture := false

static var _tex_haut: Texture2D = null


## Crée la bulle sous « parent » (un CanvasLayer ou un Control plein écran à l'origine).
static func montrer(parent: Node, texte: String, ancre_: Callable, duree_ := 4.0, portrait := "") -> Bulle:
	var b := Bulle.new()
	b.ancre = ancre_
	b.duree = duree_
	b.reste = duree_
	b._construire(texte, portrait)
	parent.add_child(b)
	b._hud = _trouver_hud(b)
	b._placer()
	b.modulate.a = 0.0
	b.create_tween().tween_property(b, "modulate:a", 1.0, 0.15)
	return b


## Ferme la bulle (fondu de 0,2 s puis libération).
func fermer() -> void:
	if _fermeture or not is_inside_tree():
		return
	_fermeture = true
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_callback(queue_free)


func _construire(texte: String, portrait: String) -> void:
	name = "Bulle"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cadre = PanelContainer.new()
	cadre.name = "Cadre"
	cadre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cadre.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cadre.add_theme_stylebox_override("panel", CadresPixel.style_marges("bulle", 15, 9, 15, 12))
	add_child(cadre)
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_theme_constant_override("separation", 12)
	cadre.add_child(h)
	if portrait != "":
		var nom := portrait if portrait.contains("/") else "ui/" + portrait
		CadresPixel.charger()
		if GrillePixel.existe(nom):
			var r := CadresPixel.icone(nom)
			r.name = "Portrait"
			r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			h.add_child(r)
	texte_label = Style.label(lignes_bulle(texte, Style.ui(), TAILLE_TEXTE, LARGEUR_TEXTE_MAX), TAILLE_TEXTE, Style.ui(), Style.ENCRE)
	texte_label.name = "Texte"
	texte_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texte_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(texte_label)
	pointe = TextureRect.new()
	pointe.name = "Pointe"
	pointe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pointe.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pointe.texture = CadresPixel.texture("bulle_pointe")
	pointe.size = POINTE
	add_child(pointe)


## Coupe le texte en 2 lignes au plus de largeur ≤ largeur (aux espaces) ; « … » si le texte est plus long.
static func lignes_bulle(texte: String, police: Font, taille: int, largeur: float) -> String:
	var mots := texte.strip_edges().split(" ", false)
	var lignes: Array[String] = []
	var courante := ""
	var i := 0
	while i < mots.size():
		var essai := mots[i] if courante == "" else courante + " " + mots[i]
		if courante == "" or police.get_string_size(essai, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x <= largeur:
			courante = essai
			i += 1
		else:
			lignes.append(courante)
			courante = ""
			if lignes.size() == 2:
				break
	if courante != "" and lignes.size() < 2:
		lignes.append(courante)
	if i < mots.size():
		var points := "…" if police.has_char(0x2026) else "..."
		var der := lignes[lignes.size() - 1]
		while der.contains(" ") and police.get_string_size(der + points, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > largeur:
			der = der.substr(0, der.rfind(" "))
		lignes[lignes.size() - 1] = der + points
	return "\n".join(lignes)


## Le HUD du jeu (repéré par le nom de sa classe, sans dépendre du script : la bulle se charge aussi
## dans les tests sans autoload).
static func _trouver_hud(n: Node) -> Node:
	if not n.is_inside_tree():
		return null
	for c in n.get_tree().root.find_children("*", "Control", true, false):
		var s: Script = c.get_script()
		if s != null and s.get_global_name() == &"Hud" and c.has_method("rect_libre"):
			return c
	return null


## Rectangle où la bulle doit tenir (px virtuels).
func rect_bornage() -> Rect2:
	if borne.has_area():
		return borne
	if _hud != null and is_instance_valid(_hud):
		var r: Rect2 = _hud.call("rect_libre")
		return r.grow(-MARGE_LIBRE)
	return get_viewport_rect().grow(-MARGE_LIBRE)


## Rectangle de la bulle avec sa pointe (px virtuels, coordonnées d'écran).
func rect_total() -> Rect2:
	var r := Rect2(global_position, cadre.size)
	return r.merge(Rect2(global_position + pointe.position, POINTE))


## Bout de la pointe (px virtuels, coordonnées d'écran).
func bout_pointe() -> Vector2:
	var p := global_position + pointe.position + Vector2(POINTE.x / 2.0, 0.0)
	return p + Vector2(0.0, POINTE.y) if pointe_vers_bas else p


func _process(delta: float) -> void:
	_placer()
	if _fermeture:
		return
	reste -= delta
	if reste <= 0.0:
		fermer()


func _placer() -> void:
	if not is_inside_tree():
		return
	if not ancre.is_valid():
		visible = false
		return
	var a: Vector2 = ancre.call()
	if a.x < 0.0 and a.y < 0.0:
		visible = false
		return
	visible = true
	var s := cadre.get_combined_minimum_size()
	s = (s / TEXEL).ceil() * TEXEL
	cadre.size = s
	size = s
	var libre := rect_bornage()
	var saillie := POINTE.y - RECOUVREMENT
	# Au-dessus de l'ancre si la place le permet, sinon dessous
	var y := a.y - ECART_ANCRE - saillie - s.y
	pointe_vers_bas = y >= libre.position.y
	if not pointe_vers_bas:
		y = a.y + ECART_ANCRE + saillie
	y = clampf(y, libre.position.y, maxf(libre.position.y, libre.end.y - s.y))
	var x := clampf(a.x - s.x / 2.0, libre.position.x, maxf(libre.position.x, libre.end.x - s.x))
	var pos := (Vector2(x, y) / TEXEL).round() * TEXEL
	global_position = pos
	# Pointe : sous ou sur le cadre, alignée sur l'ancre autant que les coins le permettent
	var px := clampf(a.x - pos.x - POINTE.x / 2.0, COIN, maxf(COIN, s.x - COIN - POINTE.x))
	px = roundf(px / TEXEL) * TEXEL
	if pointe_vers_bas:
		pointe.texture = CadresPixel.texture("bulle_pointe")
		pointe.position = Vector2(px, s.y - RECOUVREMENT)
	else:
		pointe.texture = _texture_haut()
		pointe.position = Vector2(px, -saillie)


static func _texture_haut() -> Texture2D:
	if _tex_haut == null:
		var img := CadresPixel.texture("bulle_pointe").get_image()
		img.flip_y()
		_tex_haut = ImageTexture.create_from_image(img)
	return _tex_haut
