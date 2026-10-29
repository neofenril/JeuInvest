extends RefCounted
## Cadres pixel de l'interface (docs/16 §3.3) : grilles ui/… (data/pixel/ui/*.txt) agrandies ×3 au plus
## proche voisin, en StyleBoxTexture (marges ×3), filtre Nearest. Fabrique aussi les étiquettes et les
## boutons de l'interface PX0. Sans class_name : chargé par chemin. Aucune couleur écrite en dur : tout
## passe par PalettePixel.

const Polices := preload("res://scripts/pixel/ui/polices_px0.gd")
const ECHELLE := 3

## Marges 9-patch en texels (gauche, haut, droite, bas).
const MARGES := {
	"panneau": [6, 6, 6, 6],
	"carte_papier": [8, 8, 8, 8],
	"bouton_principal": [5, 5, 5, 7],
	"bouton_principal_enfonce": [5, 5, 5, 7],
	"bouton_secondaire": [5, 5, 5, 7],
	"bouton_secondaire_enfonce": [5, 5, 5, 7],
	"bouton_papier": [5, 5, 5, 7],
	"bouton_papier_enfonce": [5, 5, 5, 7],
	"pastille": [4, 4, 4, 4],
	"plaquette": [4, 4, 4, 4],
	"etiquette": [4, 4, 4, 4],
	"cadre_portrait": [2, 2, 2, 2],
	"tampon": [4, 4, 4, 4],
	"ticket": [6, 6, 6, 6],
}

static var _textures := {}
static var _styles := {}


## Charge les grilles de l'interface (une seule fois).
static func charger() -> void:
	if not GrillePixel.existe("ui/panneau"):
		GrillePixel.charger_dossier("ui")


static func couleur(nom: String) -> Color:
	return PalettePixel.couleur(nom)


## Image ui/<nom> agrandie ×k au plus proche voisin ; remplacements de couleurs facultatifs
## ({"creme": "nuit"} : identifiants de la palette).
static func texture(nom: String, k := ECHELLE, remplacer := {}) -> Texture2D:
	var cle := "%s|%d|%s" % [nom, k, str(remplacer)]
	if _textures.has(cle):
		return _textures[cle]
	var src := GrillePixel.image(nom if nom.contains("/") else "ui/" + nom)
	if src == null:
		return null
	var img := Image.new()
	img.copy_from(src)
	if not remplacer.is_empty():
		for y in img.get_height():
			for x in img.get_width():
				var c := img.get_pixel(x, y)
				if c.a == 0.0:
					continue
				var n := PalettePixel.nom_de(c)
				if remplacer.has(n):
					var r := PalettePixel.couleur(remplacer[n])
					r.a = c.a
					img.set_pixel(x, y, r)
	if k != 1:
		img.resize(img.get_width() * k, img.get_height() * k, Image.INTERPOLATE_NEAREST)
	var t := ImageTexture.create_from_image(img)
	_textures[cle] = t
	return t


## StyleBoxTexture du cadre ui/<nom>, marges ×3. Le ticket se répète en largeur (bord dentelé).
static func style(nom: String) -> StyleBoxTexture:
	if _styles.has(nom):
		return _styles[nom]
	var s := StyleBoxTexture.new()
	s.texture = texture(nom)
	var m: Array = MARGES[nom]
	s.texture_margin_left = m[0] * ECHELLE
	s.texture_margin_top = m[1] * ECHELLE
	s.texture_margin_right = m[2] * ECHELLE
	s.texture_margin_bottom = m[3] * ECHELLE
	if nom == "ticket":
		s.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	if nom.ends_with("_enfonce"):
		# contenu descendu de 1 texel
		s.content_margin_top = (m[1] + 1) * ECHELLE
		s.content_margin_bottom = (m[3] - 1) * ECHELLE
	_styles[nom] = s
	return s


## Panneau pixel (PanelContainer) au style ui/<nom>, filtre Nearest.
static func panneau(nom: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.add_theme_stylebox_override("panel", style(nom))
	return p


## Étiquette de texte. Les polices sont lissées (filtre linéaire), les cadres restent nets.
static func etiquette(texte: String, police: Font, taille: int, couleur_nom := "creme") -> Label:
	var l := Label.new()
	l.text = texte
	l.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	l.add_theme_font_override("font", police)
	l.add_theme_font_size_override("font_size", taille)
	l.add_theme_color_override("font_color", couleur(couleur_nom))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## Icône ui/<nom> ×3 (TextureRect net).
static func icone(nom: String, remplacer := {}, k := ECHELLE) -> TextureRect:
	var t := TextureRect.new()
	t.texture = texture(nom, k, remplacer)
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	t.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


## Bouton pixel : genre "principal" (ambre), "secondaire" (ardoise sombre) ou "papier" (crème).
static func bouton(genre: String, texte := "", icone_nom := "", taille_min := Vector2(80, 80)) -> Button:
	var b := Button.new()
	b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.custom_minimum_size = taille_min
	b.focus_mode = Control.FOCUS_NONE
	habiller_bouton(b, genre)
	if texte != "":
		b.text = texte
		b.add_theme_font_override("font", Polices.pixelify(600))
		b.add_theme_font_size_override("font_size", 32)
	if icone_nom != "":
		b.icon = texture(icone_nom, ECHELLE, _remplacements_icone(genre))
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER if texte == "" else HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_constant_override("h_separation", 12)
	return b


static func _remplacements_icone(genre: String) -> Dictionary:
	return {"creme": "nuit"} if genre == "principal" else {}


## Change le style d'un bouton (bascule active / inactive), icône comprise.
static func habiller_bouton(b: Button, genre: String, icone_nom := "") -> void:
	var normal := style("bouton_" + genre)
	var enfonce := style("bouton_" + genre + "_enfonce")
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", normal)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("pressed", enfonce)
	b.add_theme_stylebox_override("hover_pressed", enfonce)
	b.add_theme_stylebox_override("disabled", normal)
	var texte := "nuit" if genre == "principal" else ("encre" if genre == "papier" else "creme")
	for etat in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(etat, couleur(texte))
	if icone_nom != "":
		b.icon = texture(icone_nom, ECHELLE, _remplacements_icone(genre))
