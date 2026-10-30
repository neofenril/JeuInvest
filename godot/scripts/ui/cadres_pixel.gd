class_name CadresPixel
extends RefCounted
## Cadres pixel de l'interface (docs/16 §3.3 ; repris de PX0, lot PX2) : grilles ui/… (data/pixel/ui/*.txt)
## agrandies ×3 (un texel = 3 px virtuels = T px physiques entiers, voir Ecran) au plus proche voisin, en
## StyleBoxTexture (marges ×3), filtre Nearest. Fabrique aussi les icônes et habille les boutons.
## Aucune couleur écrite en dur : tout passe par PalettePixel ; les variantes de couleur (liseré de la
## source, pastille gain / perte, icône sombre) sont des substitutions de noms de la palette.

const ECHELLE := 3

## Marges 9-patch en texels (gauche, haut, droite, bas).
const MARGES := {
	"panneau": [6, 6, 6, 6],
	"carte_papier": [8, 8, 8, 8],
	"journal": [8, 8, 8, 8],
	"notification": [6, 6, 6, 6],
	"ligne": [4, 4, 4, 4],
	"onglet": [4, 4, 4, 4],
	"onglet_actif": [4, 4, 4, 4],
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
## Cadres dont le bord varie le long de l'axe horizontal : motif répété, jamais étiré.
const REPETES := ["ticket", "journal"]

static var _textures := {}
static var _styles := {}


## Charge les grilles de l'interface (une seule fois).
static func charger() -> void:
	if not GrillePixel.existe("ui/panneau"):
		GrillePixel.charger_dossier("ui")


static func couleur(nom: String) -> Color:
	return PalettePixel.couleur(nom)


## Image ui/<nom> agrandie ×k au plus proche voisin ; remplacements de couleurs facultatifs
## ({"creme": "nuit"} : noms de la palette ; l'alpha de chaque texel est gardé).
static func texture(nom: String, k := ECHELLE, remplacer := {}) -> Texture2D:
	var cle := "%s|%d|%s" % [nom, k, str(remplacer)]
	if _textures.has(cle):
		return _textures[cle]
	charger()
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


## StyleBoxTexture du cadre ui/<nom>, marges ×3 (partagé : le dupliquer avant de le modifier).
static func style(nom: String, remplacer := {}) -> StyleBoxTexture:
	var cle := nom + str(remplacer)
	if _styles.has(cle):
		return _styles[cle]
	var s := StyleBoxTexture.new()
	s.texture = texture(nom, ECHELLE, remplacer)
	var m: Array = MARGES[nom]
	s.texture_margin_left = m[0] * ECHELLE
	s.texture_margin_top = m[1] * ECHELLE
	s.texture_margin_right = m[2] * ECHELLE
	s.texture_margin_bottom = m[3] * ECHELLE
	if nom in REPETES:
		s.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	if nom.ends_with("_enfonce"):
		# contenu descendu de 1 texel
		s.content_margin_top = (m[1] + 1) * ECHELLE
		s.content_margin_bottom = (m[3] - 1) * ECHELLE
	_styles[cle] = s
	return s


## Copie du cadre avec des marges de contenu choisies (px virtuels, multiples de 3 conseillés).
static func style_marges(nom: String, gauche: float, haut: float, droite: float, bas: float, remplacer := {}) -> StyleBoxTexture:
	var s: StyleBoxTexture = style(nom, remplacer).duplicate()
	s.content_margin_left = gauche
	s.content_margin_top = haut
	s.content_margin_right = droite
	s.content_margin_bottom = bas
	return s


## Panneau pixel (PanelContainer) au style ui/<nom>, filtre Nearest.
static func panneau(nom: String, remplacer := {}) -> PanelContainer:
	var p := PanelContainer.new()
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.add_theme_stylebox_override("panel", style(nom, remplacer))
	return p


## Icône ui/<nom> ×k (TextureRect net).
static func icone(nom: String, remplacer := {}, k := ECHELLE) -> TextureRect:
	var t := TextureRect.new()
	t.texture = texture(nom, k, remplacer)
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	t.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


## Remplacements d'une icône crème selon le fond du bouton (sombre sur ambre, encre sur papier).
static func remplacements_icone(genre: String) -> Dictionary:
	if genre == "principal":
		return {"creme": "nuit"}
	if genre == "papier":
		return {"creme": "encre"}
	return {}


## Couleur du texte d'un bouton selon son genre.
static func couleur_texte(genre: String) -> Color:
	return couleur("nuit" if genre == "principal" else ("encre" if genre == "papier" else "creme"))


## Habille un bouton : genre "principal" (ambre), "secondaire" (ardoise sombre) ou "papier" (crème).
static func habiller_bouton(b: Button, genre: String, icone_nom := "") -> void:
	b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var normal := style("bouton_" + genre)
	var enfonce := style("bouton_" + genre + "_enfonce")
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", normal)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("pressed", enfonce)
	b.add_theme_stylebox_override("hover_pressed", enfonce)
	b.add_theme_stylebox_override("disabled", normal)
	var c := couleur_texte(genre)
	for etat in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(etat, c)
	b.add_theme_color_override("font_disabled_color", Color(c, 0.45))
	if icone_nom != "":
		b.icon = texture(icone_nom, ECHELLE, remplacements_icone(genre))
