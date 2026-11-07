class_name EcranTitre
extends Control
## Écran titre (09 §5) posé sur la ville au crépuscule : accroche, sous-titre, JOUER / CONTINUER,
## NOUVELLE PARTIE et ligne de reprise. N'agit jamais sur Partie : il émet des signaux que la scène
## principale traite (principal.gd : jouer, demander_nouvelle_partie).

signal jouer_demande
signal nouvelle_partie_demandee

var bouton_jouer: Button
var bouton_nouvelle: Button
var l_reprise: Label
var l_aide: Label


## Construit l'écran (à appeler avant de l'ajouter à l'arbre). demo : data/demo.json.
func construire(demo: Dictionary) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = Style.theme()
	var degrade := TextureRect.new()
	var g := Gradient.new()
	g.set_color(0, Color(Style.PANNEAU_OPAQUE, 0.0))
	g.set_color(1, Color(Style.PANNEAU_OPAQUE, 0.85))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	degrade.texture = tex
	degrade.stretch_mode = TextureRect.STRETCH_SCALE
	degrade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	degrade.anchor_left = 0
	degrade.anchor_right = 1
	degrade.anchor_top = 0.55
	degrade.anchor_bottom = 1
	degrade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(degrade)
	var v := VBoxContainer.new()
	v.anchor_left = 0.5
	v.anchor_right = 0.5
	v.anchor_top = 1
	v.anchor_bottom = 1
	v.grow_horizontal = Control.GROW_DIRECTION_BOTH
	v.grow_vertical = Control.GROW_DIRECTION_BEGIN
	v.offset_bottom = -40
	v.alignment = BoxContainer.ALIGNMENT_END
	v.add_theme_constant_override("separation", 14)
	add_child(v)
	var acc := Style.label(str(demo["titre"]["accroche"]).to_upper(), 48, Style.neon(), Style.TEXTE)
	acc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	acc.add_theme_color_override("font_shadow_color", Color(Style.ACCENT, 0.45))
	acc.add_theme_constant_override("shadow_outline_size", 10)
	acc.add_theme_constant_override("shadow_offset_x", 0)
	acc.add_theme_constant_override("shadow_offset_y", 0)
	# Accroche et sous-titre sur une plaque sombre pixel : lisibles même sur la façade de la Gazette
	# (téléphone, rue de briques de PX1)
	var plaque := CadresPixel.panneau("panneau")
	plaque.add_theme_stylebox_override("panel", CadresPixel.style_marges("panneau", 36, 15, 36, 21))
	plaque.self_modulate = Color(1, 1, 1, 0.94)
	plaque.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vp := VBoxContainer.new()
	vp.add_theme_constant_override("separation", 6)
	plaque.add_child(vp)
	vp.add_child(acc)
	var sous := Style.label(str(demo["titre"]["sous_titre"]), 24, Style.ui(), Style.TEXTE_2)
	sous.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vp.add_child(sous)
	v.add_child(plaque)
	# « Continuer » (avec la date de jeu et le patrimoine) si une partie est sauvegardée, sinon « Jouer » ;
	# « Nouvelle partie » demande confirmation quand une sauvegarde existe (principal.gd).
	var boutons := HBoxContainer.new()
	boutons.alignment = BoxContainer.ALIGNMENT_CENTER
	boutons.add_theme_constant_override("separation", 24)
	bouton_jouer = Style.bouton("JOUER", true, 96)
	bouton_jouer.custom_minimum_size = Vector2(380, 96)
	bouton_jouer.add_theme_font_override("font", Style.neon())
	bouton_jouer.add_theme_font_size_override("font_size", 40)
	bouton_jouer.pressed.connect(func() -> void: jouer_demande.emit())
	boutons.add_child(bouton_jouer)
	bouton_nouvelle = Style.bouton("NOUVELLE PARTIE", false, 96)
	bouton_nouvelle.custom_minimum_size = Vector2(340, 96)
	bouton_nouvelle.add_theme_font_size_override("font_size", 28)
	bouton_nouvelle.pressed.connect(func() -> void: nouvelle_partie_demandee.emit())
	boutons.add_child(bouton_nouvelle)
	v.add_child(boutons)
	l_reprise = Style.label("", 22, Style.chiffres(), Style.TEXTE)
	l_reprise.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l_reprise)
	# Aide des raccourcis de test : jamais dans la version du joueur, jamais sur mobile
	l_aide = Style.label("F10 : format téléphone   ·   F8 : moment suivant   ·   F6 / F7 : naissance / jumeaux", 20, Style.ui(), Color(Style.TEXTE_2, 0.8))
	l_aide.add_theme_color_override("font_outline_color", Style.PANNEAU_OPAQUE)
	l_aide.add_theme_constant_override("outline_size", 6)
	l_aide.anchor_left = 0
	l_aide.anchor_top = 1
	l_aide.anchor_bottom = 1
	l_aide.offset_left = 24
	l_aide.offset_top = -44
	l_aide.visible = Reglages.raccourcis_test() and not OS.has_feature("mobile")
	add_child(l_aide)


## Boutons selon la sauvegarde lue (sauvee) et l'état de la partie (en_cours : chargée et pas finie).
func maj(sauvee: Dictionary, en_cours: bool) -> void:
	var reprise := not sauvee.is_empty() and en_cours
	bouton_jouer.text = "CONTINUER" if reprise else "JOUER"
	bouton_nouvelle.visible = reprise
	l_reprise.visible = reprise
	if reprise:
		# Résumé lu avec garde : un format de sauvegarde différent (format 3, lot 02) peut ne pas avoir
		# « ab » ou « patrimoine » ; on masque alors la ligne plutôt que d'échouer.
		var r: Dictionary = sauvee.get("resume", {}) if sauvee.get("resume", {}) is Dictionary else {}
		if r.has("ab") and r.has("patrimoine"):
			var ab := int(r.get("ab", 0))
			l_reprise.text = "Partie en cours : %s · %s · patrimoine %s" % [str(r.get("prenom", "")), Dates.texte(ab), Format.montant(float(r.get("patrimoine", 0.0)), ab)]
		else:
			l_reprise.text = "Partie en cours : partie sauvegardée"
			l_reprise.visible = false


## Texte de la partie en cours, sans le préfixe (pour la confirmation d'effacement).
func texte_reprise() -> String:
	return l_reprise.text.trim_prefix("Partie en cours : ")


func donner_focus() -> void:
	bouton_jouer.grab_focus.call_deferred()
