class_name Style
extends RefCounted
## Direction artistique (09 §2.6-2.8) : palette, polices système, boîtes (StyleBoxFlat) et thème.
## Tout est construit en code (aucune ressource externe) et mis en cache.

# --- HUD ---
const PANNEAU := Color(0.086, 0.118, 0.18, 0.88)      # #161E2E α 0,88
const PANNEAU_OPAQUE := Color("161e2e")
const PANNEAU_ELEVE := Color("1f2a3f")
const PANNEAU_SURVOL := Color("26334c")
const FILET := Color("2e3b55")
const TEXTE := Color("edeae0")
const TEXTE_2 := Color("9aa6bd")
const GAIN := Color("46e08a")
const PERTE := Color("ff5c5c")
const OR := Color("f2c14e")
const OR_OMBRE := Color("b8862b")
const GEL := Color("7fd6ff")
const ALERTE := Color("ffc94d")
const ACCENT := Color("ffb547")                       # P1 : ambre
const ENCRE_ACCENT := Color("14100a")

# --- Papier ---
const JOURNAL := Color("f7f3ea")                      # années 1980 (04 §7.3)
const ENCRE := Color("1b1a17")
const ENCRE_ROUGE := Color("b3261e")
const COURRIER := Color("fbf8f1")

# --- Catégories (barre de répartition, familles du carnet : data/banque.json) ---
const CATEGORIES := {
	"cc": Color("8c96a8"), "livret": Color("4ea8de"), "pel": Color("8f8cf2"), "emprunt": Color("d9b44a"),
	"av": Color("c48bd6"), "sicav": Color("5cc8a0"), "action": Color("ff8a65"),
}

# --- Frais (13 §3.1) : cuivre, jamais le rouge des pertes ---
const CUIVRE := Color("c77b4a")
const CUIVRE_LISERE := Color("8a4f2b")
const SILHOUETTE := Color("0f1522")

# --- Sources des messages (bord gauche des notifications) ---
const SOURCES := {
	"maison": Color("f28c5b"), "banque": Color("c9a24a"), "media": Color("ff6fa8"),
}

static var _polices: Dictionary = {}
static var _theme: Theme = null


# =====================================================================
# Polices
# =====================================================================

static func _systeme(noms: PackedStringArray, poids: int, msdf := false) -> SystemFont:
	var f := SystemFont.new()
	f.font_names = noms
	f.font_weight = poids
	f.multichannel_signed_distance_field = msdf
	f.allow_system_fallback = true
	return f


## Chiffres, date, compteurs : Bahnschrift, chiffres à chasse fixe (tnum).
static func chiffres() -> Font:
	if not _polices.has("chiffres"):
		var base := _systeme(PackedStringArray(["Bahnschrift", "Roboto Condensed", "sans-serif-condensed", "sans-serif"]), 600, true)
		var v := FontVariation.new()
		v.base_font = base
		var ts := TextServerManager.get_primary_interface()
		v.opentype_features = {ts.name_to_tag("tnum"): 1}
		v.variation_opentype = {ts.name_to_tag("wght"): 600}
		_polices["chiffres"] = v
	return _polices["chiffres"]


static func ui() -> Font:
	if not _polices.has("ui"):
		_polices["ui"] = _systeme(PackedStringArray(["Segoe UI", "Roboto", "sans-serif"]), 400)
	return _polices["ui"]


static func ui_gras() -> Font:
	if not _polices.has("ui_gras"):
		_polices["ui_gras"] = _systeme(PackedStringArray(["Segoe UI", "Roboto", "sans-serif"]), 600)
	return _polices["ui_gras"]


## Titres en capitales espacées (titres de panneaux).
static func capitales() -> Font:
	if not _polices.has("capitales"):
		var v := FontVariation.new()
		v.base_font = ui_gras()
		v.spacing_glyph = 2
		_polices["capitales"] = v
	return _polices["capitales"]


static func led() -> Font:
	if not _polices.has("led"):
		_polices["led"] = _systeme(PackedStringArray(["Consolas", "Lucida Console", "monospace"]), 700)
	return _polices["led"]


## Manchettes des années 1980 : Impact, capitales serrées (04 §7.3).
static func manchette() -> Font:
	if not _polices.has("manchette"):
		_polices["manchette"] = _systeme(PackedStringArray(["Impact", "Arial Black", "sans-serif-condensed", "sans-serif"]), 800, true)
	return _polices["manchette"]


## Nom du journal, enseignes : Rockwell, sinon Georgia.
static func titre_journal() -> Font:
	if not _polices.has("titre_journal"):
		_polices["titre_journal"] = _systeme(PackedStringArray(["Rockwell", "Georgia", "serif"]), 700, true)
	return _polices["titre_journal"]


static func journal() -> Font:
	if not _polices.has("journal"):
		_polices["journal"] = _systeme(PackedStringArray(["Georgia", "serif"]), 400)
	return _polices["journal"]


static func neon() -> Font:
	if not _polices.has("neon"):
		var v := FontVariation.new()
		v.base_font = _systeme(PackedStringArray(["Bahnschrift", "Roboto Condensed", "sans-serif-condensed", "sans-serif"]), 700, true)
		v.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 700}
		v.spacing_glyph = 6
		_polices["neon"] = v
	return _polices["neon"]


# =====================================================================
# Boîtes
# =====================================================================

static func boite(fond: Color, coins := 18, marge_h := 20, marge_v := 16) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fond
	s.set_corner_radius_all(coins)
	s.content_margin_left = marge_h
	s.content_margin_right = marge_h
	s.content_margin_top = marge_v
	s.content_margin_bottom = marge_v
	s.anti_aliasing = true
	s.corner_detail = 8
	return s


static func bordure(s: StyleBoxFlat, couleur: Color, gauche := 0, haut := 0, droite := 0, bas := 0) -> StyleBoxFlat:
	s.border_color = couleur
	s.border_width_left = gauche
	s.border_width_top = haut
	s.border_width_right = droite
	s.border_width_bottom = bas
	return s


static func ombre(s: StyleBoxFlat, couleur: Color, taille: int, decalage := Vector2.ZERO) -> StyleBoxFlat:
	s.shadow_color = couleur
	s.shadow_size = taille
	s.shadow_offset = decalage
	return s


## Panneau du HUD : lumière d'en haut (bordure haute plus claire), ombre portée.
static func panneau(coins := 18) -> StyleBoxFlat:
	var s := boite(PANNEAU, coins)
	bordure(s, Color(1, 1, 1, 0.09), 1, 2, 1, 1)
	return ombre(s, Color(0, 0, 0, 0.6), 18, Vector2(0, 8))


static func carte(couleur_categorie := Color.TRANSPARENT) -> StyleBoxFlat:
	var s := boite(PANNEAU_ELEVE, 14, 18, 14)
	bordure(s, Color(1, 1, 1, 0.10), 1, 2, 1, 1)
	if couleur_categorie.a > 0.0:
		s.border_width_left = 6
		s.border_color = couleur_categorie
	return ombre(s, Color(0, 0, 0, 0.5), 10, Vector2(0, 6))


static func bouton_principal(etat := "normal") -> StyleBoxFlat:
	var fond := ACCENT
	if etat == "survol":
		fond = ACCENT.lightened(0.08)
	elif etat == "desactive":
		fond = Color(ACCENT, 0.35)
	var s := boite(fond, 16, 28, 14)
	var bas := 1 if etat == "appui" else 4
	bordure(s, ACCENT.darkened(0.3), 0, 0, 0, bas)
	if etat == "appui":
		s.content_margin_top = 17
	if etat == "survol":
		ombre(s, Color(ACCENT, 0.35), 14, Vector2(0, 4))
	elif etat != "desactive":
		ombre(s, Color(0, 0, 0, 0.4), 6, Vector2(0, 4))
	return s


static func bouton_secondaire(etat := "normal") -> StyleBoxFlat:
	var fond := Color(1, 1, 1, 0.06)
	if etat == "survol":
		fond = Color(1, 1, 1, 0.12)
	elif etat == "appui":
		fond = Color(1, 1, 1, 0.03)
	elif etat == "actif":
		fond = Color(ACCENT, 0.9)
	var s := boite(fond, 16, 24, 12)
	return bordure(s, Color(1, 1, 1, 0.2) if etat != "actif" else ACCENT.darkened(0.3), 2, 2, 2, 2)


static func boite_notification(source: String) -> StyleBoxFlat:
	var s := boite(Color(PANNEAU_ELEVE, 0.95), 14, 18, 12)
	bordure(s, SOURCES.get(source, ACCENT), 6, 0, 0, 0)
	return ombre(s, Color(0, 0, 0, 0.6), 16, Vector2(0, 6))


static func etiquette_batiment() -> StyleBoxFlat:
	var s := boite(Color(PANNEAU_OPAQUE, 0.85), 999, 16, 6)
	bordure(s, Color(1, 1, 1, 0.14), 1, 1, 1, 1)
	return ombre(s, Color(0, 0, 0, 0.5), 8, Vector2(0, 4))


static func pastille(couleur: Color, coins := 999, marge_v := 8) -> StyleBoxFlat:
	var s := boite(Color(couleur, 0.16), coins, 20, marge_v)
	return bordure(s, couleur, 2, 2, 2, 2)


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
	# Boutons : secondaire par défaut
	t.set_stylebox("normal", "Button", bouton_secondaire())
	t.set_stylebox("hover", "Button", bouton_secondaire("survol"))
	t.set_stylebox("pressed", "Button", bouton_secondaire("appui"))
	t.set_stylebox("hover_pressed", "Button", bouton_secondaire("actif"))
	t.set_stylebox("disabled", "Button", bouton_secondaire("appui"))
	t.set_stylebox("focus", "Button", _focus())
	t.set_color("font_color", "Button", TEXTE)
	t.set_color("font_hover_color", "Button", TEXTE)
	t.set_color("font_pressed_color", "Button", ENCRE_ACCENT)
	t.set_color("font_hover_pressed_color", "Button", ENCRE_ACCENT)
	t.set_color("font_disabled_color", "Button", Color(TEXTE, 0.4))
	t.set_font("font", "Button", ui_gras())
	t.set_font_size("font_size", "Button", 24)
	# Bouton principal (variation)
	t.set_type_variation("BoutonPrincipal", "Button")
	t.set_stylebox("normal", "BoutonPrincipal", bouton_principal())
	t.set_stylebox("hover", "BoutonPrincipal", bouton_principal("survol"))
	t.set_stylebox("pressed", "BoutonPrincipal", bouton_principal("appui"))
	t.set_stylebox("disabled", "BoutonPrincipal", bouton_principal("desactive"))
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(c, "BoutonPrincipal", ENCRE_ACCENT)
	t.set_color("font_disabled_color", "BoutonPrincipal", Color(ENCRE_ACCENT, 0.5))
	# Bouton bascule (onglets, vitesses) : l'état « pressed » est l'état actif
	t.set_type_variation("BoutonBascule", "Button")
	t.set_stylebox("pressed", "BoutonBascule", bouton_secondaire("actif"))
	t.set_stylebox("hover_pressed", "BoutonBascule", bouton_secondaire("actif"))
	# Panneaux
	t.set_stylebox("panel", "PanelContainer", panneau())
	t.set_stylebox("panel", "Panel", panneau())
	# Curseur
	var piste := boite(FILET, 6, 0, 4)
	t.set_stylebox("slider", "HSlider", piste)
	var rempli := boite(ACCENT, 6, 0, 4)
	t.set_stylebox("grabber_area", "HSlider", rempli)
	t.set_stylebox("grabber_area_highlight", "HSlider", rempli)
	t.set_icon("grabber", "HSlider", _rond(34, TEXTE))
	t.set_icon("grabber_highlight", "HSlider", _rond(38, Color.WHITE))
	t.set_constant("center_grabber", "HSlider", 1)
	# Barre de défilement discrète
	t.set_stylebox("scroll", "VScrollBar", boite(Color(1, 1, 1, 0.04), 6, 4, 4))
	t.set_stylebox("grabber", "VScrollBar", boite(Color(1, 1, 1, 0.25), 6, 4, 4))
	_theme = t
	return t


static func _focus() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.draw_center = false
	s.set_corner_radius_all(18)
	bordure(s, Color.WHITE, 3, 3, 3, 3)
	s.expand_margin_left = 4
	s.expand_margin_right = 4
	s.expand_margin_top = 4
	s.expand_margin_bottom = 4
	return s


static func _rond(d: int, c: Color) -> ImageTexture:
	var img := Image.create(d, d, false, Image.FORMAT_RGBA8)
	var r := d / 2.0
	for y in d:
		for x in d:
			var dist := Vector2(x + 0.5 - r, y + 0.5 - r).length()
			var a := clampf(r - dist, 0.0, 1.0)
			img.set_pixel(x, y, Color(c, a))
	return ImageTexture.create_from_image(img)


# =====================================================================
# Raccourcis pour créer des nœuds
# =====================================================================

static func label(texte: String, taille := 24, police: Font = null, couleur := TEXTE) -> Label:
	var l := Label.new()
	l.text = texte
	l.add_theme_font_size_override("font_size", taille)
	if police != null:
		l.add_theme_font_override("font", police)
	l.add_theme_color_override("font_color", couleur)
	return l


static func bouton(texte: String, principal := false, hauteur := 80) -> Button:
	var b := Button.new()
	b.text = texte
	b.custom_minimum_size = Vector2(0, hauteur)
	if principal:
		b.theme_type_variation = "BoutonPrincipal"
	b.focus_mode = Control.FOCUS_ALL
	return b


## Teinte plus sombre de 20 % (ombre des volumes de la ville).
static func ombre_de(c: Color) -> Color:
	return c.darkened(0.2)
