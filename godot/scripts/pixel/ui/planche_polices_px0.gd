extends Control
## Planche des polices (étape « polices », lot PX0 CA-I1) : Pixelify Sans, Atkinson Hyperlegible Next,
## Jersey 10 et Doto à 28, 32, 48 et 72 px virtuels, à gauche sur panneau nuit, à droite sur papier crème.
## L'échantillon complet est écrit à 28 et 32 px sur les deux fonds ; à 48 et 72 px (trop large pour une
## demi-largeur), des extraits partagés entre les deux fonds (capitales et minuscules accentuées, « »,
## montant, 1lI 0O 8B). La couverture complète des glyphes est aussi contrôlée par le code (lignes_controle).
## Sans class_name : chargé par chemin.

const Polices := preload("res://scripts/pixel/ui/polices_px0.gd")
const Cadres := preload("res://scripts/pixel/ui/cadres_px0.gd")

const ECHANTILLON := "ÉÈÊÀÇÔŒÙÎ àéèêçôœùî « » 0123456789 1lI 0O 8B 69 395 F"
# 48 et 72 px : extraits partagés entre les deux fonds (nuit, crème)
const GRAND_48 := ["ÉÈÊÀÇÔŒÙÎ", "àéèêçôœùî « »"]
const GRAND_72 := ["69 395 F", "1lI 0O 8B"]


func _init() -> void:
	name = "PlanchePolices"
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP


func construire() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fond := ColorRect.new()
	fond.color = PalettePixel.couleur("encre")
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fond)
	var v := VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 12
	v.offset_right = -12
	v.offset_top = 6
	v.offset_bottom = -6
	v.add_theme_constant_override("separation", 3)
	add_child(v)
	v.add_child(Cadres.etiquette("PLANCHE DES POLICES · 28, 32, 48 et 72 px virtuels · à gauche sur panneau nuit, à droite sur papier crème",
		Polices.atkinson(700), 20, "gris_pierre"))
	var polices := [
		["Pixelify Sans (titres, étiquettes, boutons)", Polices.pixelify(500)],
		["Atkinson Hyperlegible Next (chiffres, textes)", Polices.atkinson(400)],
		["Jersey 10 (variante date et patrimoine)", Polices.jersey()],
		["Doto (journal lumineux, Minitel)", Polices.doto(600)],
	]
	for p in polices:
		var bande := HBoxContainer.new()
		bande.add_theme_constant_override("separation", 6)
		bande.size_flags_vertical = Control.SIZE_EXPAND_FILL
		bande.add_child(_moitie(p[0], p[1], true))
		bande.add_child(_moitie(p[0], p[1], false))
		v.add_child(bande)


func _moitie(nom: String, police: Font, nuit: bool) -> PanelContainer:
	var pan := Cadres.panneau("panneau" if nuit else "carte_papier")
	var st: StyleBoxTexture = Cadres.style("panneau" if nuit else "carte_papier").duplicate()
	st.content_margin_left = 27
	st.content_margin_right = 21
	st.content_margin_top = 9
	st.content_margin_bottom = 12
	pan.add_theme_stylebox_override("panel", st)
	pan.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var texte := "creme" if nuit else "encre"
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.add_child(Cadres.etiquette(nom, Polices.atkinson(700), 20, "gris_pierre" if nuit else "ardoise"))
	for t in [28, 32]:
		var l := Cadres.etiquette(ECHANTILLON, police, t, texte)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(300, 0)
		v.add_child(l)
	var grand := HBoxContainer.new()
	grand.add_theme_constant_override("separation", 30)
	var l48 := Cadres.etiquette(GRAND_48[0] if nuit else GRAND_48[1], police, 48, texte)
	l48.size_flags_vertical = Control.SIZE_SHRINK_END
	grand.add_child(l48)
	grand.add_child(Cadres.etiquette(GRAND_72[0] if nuit else GRAND_72[1], police, 72, texte))
	v.add_child(grand)
	pan.add_child(v)
	return pan
