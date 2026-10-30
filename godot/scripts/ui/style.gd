class_name Style
extends RefCounted
## Direction artistique de l'interface (docs/16 §3, lot PX2) : couleurs de la palette « Rue 84 »
## (PalettePixel, 40 premières couleurs), polices embarquées (PolicesPixel : Pixelify Sans pour les titres
## et boutons, jamais sous 28 px ; Atkinson Hyperlegible Next pour les chiffres et les textes), cadres
## pixel en 9-patch (CadresPixel) et thème. Tout est construit en code et mis en cache.
## Les noms (constantes devenues variables statiques, fonctions) sont ceux de la V2 : la ville vectorielle
## et le reste de l'interface s'en servent sans changement.

# --- HUD ---
static var PANNEAU := PalettePixel.couleur_alpha("nuit", 0.94)
static var PANNEAU_OPAQUE := PalettePixel.couleur("nuit")
static var PANNEAU_ELEVE := PalettePixel.couleur("ardoise_sombre")
static var PANNEAU_SURVOL := PalettePixel.couleur("ardoise")
static var FILET := PalettePixel.couleur("ardoise")
static var TEXTE := PalettePixel.couleur("creme")
static var TEXTE_2 := PalettePixel.couleur("zinc_clair")
static var GAIN := PalettePixel.couleur("gain")
static var PERTE := PalettePixel.couleur("perte")
static var OR := PalettePixel.couleur("or")
static var OR_OMBRE := PalettePixel.couleur("caramel")
static var GEL := PalettePixel.couleur("gel")
static var ALERTE := PalettePixel.couleur("lumiere")
static var ACCENT := PalettePixel.couleur("ambre")
static var ENCRE_ACCENT := PalettePixel.couleur("nuit")

# --- Papier ---
static var JOURNAL := PalettePixel.couleur("creme")
static var ENCRE := PalettePixel.couleur("encre")
static var ENCRE_ROUGE := PalettePixel.couleur("perte_papier")
static var COURRIER := PalettePixel.couleur("blanc_chaud")
static var GAIN_PAPIER := PalettePixel.couleur("gain_papier")
static var TEXTE_PAPIER_2 := PalettePixel.couleur("pierre_ombre")

# --- Catégories (barre de répartition, familles du carnet) ---
static var CATEGORIES := {
	"cc": PalettePixel.couleur("gris_pierre"), "livret": PalettePixel.couleur("ciel"), "pel": PalettePixel.couleur("bleu_vif"),
	"emprunt": PalettePixel.couleur("or"), "av": PalettePixel.couleur("neon_rose"), "sicav": PalettePixel.couleur("vert_clair"),
	"action": PalettePixel.couleur("orange"),
}

# --- Frais (13 §3.1) : cuivre, jamais le rouge des pertes ---
static var CUIVRE := PalettePixel.couleur("cuivre")
static var CUIVRE_LISERE := PalettePixel.couleur("bois")
static var SILHOUETTE := PalettePixel.couleur("encre")

# --- Sources des messages (liseré des notifications, onglets, lignes de l'historique) ---
static var SOURCES := {
	"maison": PalettePixel.couleur("orange"), "banque": PalettePixel.couleur("or"), "media": PalettePixel.couleur("neon_rose"),
}
## Noms de palette des sources (substitution des cadres et des icônes).
const NOMS_PALETTE_SOURCES := {"maison": "orange", "banque": "or", "media": "neon_rose"}

static var _polices: Dictionary = {}
static var _theme: Theme = null


# =====================================================================
# Polices (embarquées)
# =====================================================================

## Chiffres, date, compteurs : Atkinson, chiffres à chasse fixe (tnum).
static func chiffres() -> Font:
	return PolicesPixel.atkinson(600)


static func ui() -> Font:
	return PolicesPixel.atkinson(400)


static func ui_gras() -> Font:
	return PolicesPixel.atkinson(700)


## Titres en capitales : Pixelify (Style.label passe en petites capitales Atkinson sous 28 px).
static func capitales() -> Font:
	return PolicesPixel.pixelify(600)


## Petites capitales espacées (titres de moins de 28 px) : Atkinson grasse.
static func petites_capitales() -> Font:
	return PolicesPixel.atkinson(700, 2)


static func led() -> Font:
	return PolicesPixel.doto(700)


## Manchettes : Pixelify grasse.
static func manchette() -> Font:
	return PolicesPixel.pixelify(700)


## Nom du journal, enseignes : Pixelify grasse.
static func titre_journal() -> Font:
	return PolicesPixel.pixelify(700)


static func journal() -> Font:
	return PolicesPixel.atkinson(400)


static func neon() -> Font:
	return PolicesPixel.pixelify(700)


## Police sûre pour une taille : Pixelify sous 28 px devient des petites capitales Atkinson.
static func police_pour(police: Font, taille: int) -> Font:
	if police != null and taille < PolicesPixel.TAILLE_MIN_PIXELIFY and PolicesPixel.est_pixelify(police):
		return petites_capitales()
	return police


# =====================================================================
# Boîtes simples (aplats à angles droits) et cadres pixel (9-patch)
# =====================================================================

static func boite(fond: Color, _coins := 18, marge_h := 20, marge_v := 16) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fond
	s.content_margin_left = marge_h
	s.content_margin_right = marge_h
	s.content_margin_top = marge_v
	s.content_margin_bottom = marge_v
	s.anti_aliasing = false
	return s


static func bordure(s: StyleBoxFlat, couleur: Color, gauche := 0, haut := 0, droite := 0, bas := 0) -> StyleBoxFlat:
	s.border_color = couleur
	s.border_width_left = gauche
	s.border_width_top = haut
	s.border_width_right = droite
	s.border_width_bottom = bas
	return s


## Ombre portée en aplat (pas de flou, docs/16 §2.4) : décalage seulement.
static func ombre(s: StyleBoxFlat, couleur: Color, _taille: int, decalage := Vector2.ZERO) -> StyleBoxFlat:
	s.shadow_color = Color(ENCRE, minf(couleur.a, 0.5))
	s.shadow_size = 1
	s.shadow_offset = Vector2(0, 6) if decalage == Vector2.ZERO else Vector2(roundf(decalage.x / 3.0) * 3.0, maxf(3.0, roundf(decalage.y / 3.0) * 3.0))
	return s


## Panneau sombre pixel (barre haute, frise, « Mon argent », fenêtres) ; « coins » est ignoré.
static func panneau(_coins := 18) -> StyleBox:
	var s := CadresPixel.style_marges("panneau", 21, 18, 21, 24)
	s.modulate_color = Color(1, 1, 1, 0.97)
	return s


static func carte(couleur_categorie := Color.TRANSPARENT) -> StyleBox:
	var s := CadresPixel.style_marges("panneau", 18, 15, 18, 21)
	if couleur_categorie.a > 0.0:
		s.modulate_color = Color(1, 1, 1, 1)
	return s


## Papier crème au liseré de la source (carte du banquier, courrier, relectures).
static func papier(source := "banque", marge_h := 30.0, marge_v := 24.0) -> StyleBox:
	var nom: String = NOMS_PALETTE_SOURCES.get(source, source)
	return CadresPixel.style_marges("carte_papier", marge_h + 6.0, marge_v, marge_h, marge_v + 6.0, {} if nom == "or" else {"or": nom})


static func bouton_principal(etat := "normal") -> StyleBox:
	var s: StyleBoxTexture = CadresPixel.style("bouton_principal_enfonce" if etat == "appui" else "bouton_principal").duplicate()
	_marges_bouton(s, etat == "appui")
	if etat == "desactive":
		s.modulate_color = Color(1, 1, 1, 0.45)
	return s


static func bouton_secondaire(etat := "normal") -> StyleBox:
	var nom := "bouton_secondaire"
	if etat == "actif":
		nom = "bouton_principal_enfonce"
	elif etat == "appui":
		nom = "bouton_secondaire_enfonce"
	var s: StyleBoxTexture = CadresPixel.style(nom).duplicate()
	_marges_bouton(s, etat == "appui" or etat == "actif")
	return s


static func bouton_papier(etat := "normal") -> StyleBox:
	var s: StyleBoxTexture = CadresPixel.style("bouton_papier_enfonce" if etat == "appui" else "bouton_papier").duplicate()
	_marges_bouton(s, etat == "appui")
	return s


static func _marges_bouton(s: StyleBoxTexture, enfonce: bool) -> void:
	s.content_margin_left = 24
	s.content_margin_right = 24
	s.content_margin_top = 15 if enfonce else 12
	s.content_margin_bottom = 18 if enfonce else 21


static func boite_notification(source: String) -> StyleBox:
	var nom: String = NOMS_PALETTE_SOURCES.get(source, "or")
	return CadresPixel.style_marges("notification", 24, 15, 18, 21, {} if nom == "or" else {"or": nom})


static func etiquette_batiment() -> StyleBox:
	return CadresPixel.style_marges("etiquette", 18, 6, 18, 6)


## Pastille (pilule en escalier) au contour de la couleur donnée (gain, perte, cuivre, encre rouge…).
static func pastille(couleur: Color, _coins := 999, marge_v := 8) -> StyleBox:
	var nom := PalettePixel.nom_de(couleur)
	if nom == "" or not PalettePixel.existe(nom):
		nom = "gain"
	return CadresPixel.style_marges("pastille", 21, marge_v, 21, marge_v, {} if nom == "gain" else {"gain": nom})


# =====================================================================
# Thème global
# =====================================================================

static func theme() -> Theme:
	if _theme != null:
		return _theme
	var t := Theme.new()
	t.default_font = ui()
	t.default_font_size = 24
	t.set_color("font_color", "Label", TEXTE)
	# Boutons : secondaire par défaut (ardoise sombre), texte Pixelify 28
	t.set_stylebox("normal", "Button", bouton_secondaire())
	t.set_stylebox("hover", "Button", bouton_secondaire())
	t.set_stylebox("pressed", "Button", bouton_secondaire("appui"))
	t.set_stylebox("hover_pressed", "Button", bouton_secondaire("actif"))
	t.set_stylebox("disabled", "Button", bouton_secondaire())
	t.set_stylebox("focus", "Button", _focus())
	t.set_color("font_color", "Button", TEXTE)
	t.set_color("font_hover_color", "Button", PalettePixel.couleur("blanc_chaud"))
	t.set_color("font_pressed_color", "Button", TEXTE)
	t.set_color("font_hover_pressed_color", "Button", ENCRE_ACCENT)
	t.set_color("font_focus_color", "Button", TEXTE)
	t.set_color("font_disabled_color", "Button", Color(TEXTE, 0.4))
	t.set_font("font", "Button", capitales())
	t.set_font_size("font_size", "Button", 28)
	# Bouton principal (variation) : ambre, texte nuit
	t.set_type_variation("BoutonPrincipal", "Button")
	t.set_stylebox("normal", "BoutonPrincipal", bouton_principal())
	t.set_stylebox("hover", "BoutonPrincipal", bouton_principal())
	t.set_stylebox("pressed", "BoutonPrincipal", bouton_principal("appui"))
	t.set_stylebox("hover_pressed", "BoutonPrincipal", bouton_principal("appui"))
	t.set_stylebox("disabled", "BoutonPrincipal", bouton_principal("desactive"))
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		t.set_color(c, "BoutonPrincipal", ENCRE_ACCENT)
	t.set_color("font_disabled_color", "BoutonPrincipal", Color(ENCRE_ACCENT, 0.5))
	# Bouton papier (variation) : crème, texte encre
	t.set_type_variation("BoutonPapier", "Button")
	t.set_stylebox("normal", "BoutonPapier", bouton_papier())
	t.set_stylebox("hover", "BoutonPapier", bouton_papier())
	t.set_stylebox("pressed", "BoutonPapier", bouton_papier("appui"))
	t.set_stylebox("hover_pressed", "BoutonPapier", bouton_papier("appui"))
	t.set_stylebox("disabled", "BoutonPapier", bouton_papier())
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		t.set_color(c, "BoutonPapier", ENCRE)
	t.set_color("font_disabled_color", "BoutonPapier", Color(ENCRE, 0.45))
	# Bouton bascule (onglets, vitesses) : l'état « pressed » est l'état actif (ambre)
	t.set_type_variation("BoutonBascule", "Button")
	t.set_stylebox("pressed", "BoutonBascule", bouton_secondaire("actif"))
	t.set_stylebox("hover_pressed", "BoutonBascule", bouton_secondaire("actif"))
	t.set_color("font_pressed_color", "BoutonBascule", ENCRE_ACCENT)
	t.set_color("font_hover_pressed_color", "BoutonBascule", ENCRE_ACCENT)
	# Panneaux
	t.set_stylebox("panel", "PanelContainer", panneau())
	t.set_stylebox("panel", "Panel", panneau())
	# Curseur
	var piste := boite(PANNEAU_ELEVE, 0, 0, 6)
	bordure(piste, ENCRE, 3, 3, 3, 3)
	t.set_stylebox("slider", "HSlider", piste)
	var rempli := boite(ACCENT, 0, 0, 6)
	bordure(rempli, ENCRE, 3, 3, 3, 3)
	t.set_stylebox("grabber_area", "HSlider", rempli)
	t.set_stylebox("grabber_area_highlight", "HSlider", rempli)
	t.set_icon("grabber", "HSlider", _carre(36, TEXTE))
	t.set_icon("grabber_highlight", "HSlider", _carre(36, PalettePixel.couleur("blanc_chaud")))
	t.set_constant("center_grabber", "HSlider", 1)
	# Barre de défilement : rail sombre, poignée ardoise, à angles droits
	t.set_stylebox("scroll", "VScrollBar", boite(Color(ENCRE, 0.35), 0, 6, 6))
	var poignee := boite(PANNEAU_SURVOL, 0, 6, 6)
	t.set_stylebox("grabber", "VScrollBar", poignee)
	t.set_stylebox("grabber_highlight", "VScrollBar", boite(PalettePixel.couleur("gris_pierre"), 0, 6, 6))
	t.set_stylebox("grabber_pressed", "VScrollBar", boite(PalettePixel.couleur("gris_pierre"), 0, 6, 6))
	_theme = t
	return t


## Cadre de focus (clavier) : 1 texel blanc chaud (docs/16 §3.3).
static func _focus() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	bordure(s, PalettePixel.couleur("blanc_chaud"), 3, 3, 3, 3)
	s.expand_margin_left = 3
	s.expand_margin_right = 3
	s.expand_margin_top = 3
	s.expand_margin_bottom = 3
	return s


## Poignée carrée pixel (contour encre de 1 texel).
static func _carre(d: int, c: Color) -> ImageTexture:
	var img := Image.create(d, d, false, Image.FORMAT_RGBA8)
	img.fill(ENCRE)
	img.fill_rect(Rect2i(3, 3, d - 6, d - 6), c)
	return ImageTexture.create_from_image(img)


# =====================================================================
# Raccourcis pour créer des nœuds
# =====================================================================

## Libellé. Pixelify sous 28 px est remplacée par des petites capitales Atkinson (lisibilité, docs/16 §3.1).
static func label(texte: String, taille := 24, police: Font = null, couleur := TEXTE) -> Label:
	var l := Label.new()
	l.text = texte
	l.add_theme_font_size_override("font_size", taille)
	var p := police_pour(police, taille)
	if p != null:
		l.add_theme_font_override("font", p)
	l.add_theme_color_override("font_color", couleur)
	return l


## Côté minimal d'une cible tactile en px virtuels (Ecran.cible_min, 48 dp sur mobile).
static func cible_min() -> float:
	var ecran: Node = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("Ecran") if Engine.get_main_loop() is SceneTree else null
	return float(ecran.call("cible_min")) if ecran != null else 72.0


## Bouton pixel ; hauteur au moins la cible tactile minimale.
static func bouton(texte: String, principal := false, hauteur := 84) -> Button:
	var b := Button.new()
	b.text = texte
	var cote := maxf(float(hauteur), cible_min())
	b.custom_minimum_size = Vector2(cote, cote)
	if principal:
		b.theme_type_variation = "BoutonPrincipal"
	b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.focus_mode = Control.FOCUS_ALL
	return b


## Teinte plus sombre de 20 % (ombre des volumes de la ville).
static func ombre_de(c: Color) -> Color:
	return c.darkened(0.2)
