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
	g.set_color(0, Color(0.05, 0.06, 0.1, 0.0))
	g.set_color(1, Color(0.05, 0.06, 0.1, 0.85))
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
	var acc := Style.label(str(demo["titre"]["accroche"]).to_upper(), 36, Style.neon(), Style.TEXTE)
	acc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	acc.add_theme_color_override("font_shadow_color", Color(Style.ACCENT, 0.45))
	acc.add_theme_constant_override("shadow_outline_size", 10)
	acc.add_theme_constant_override("shadow_offset_x", 0)
	acc.add_theme_constant_override("shadow_offset_y", 0)
	v.add_child(acc)
	var sous := Style.label(str(demo["titre"]["sous_titre"]), 24, Style.ui(), Style.TEXTE_2)
	sous.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sous)
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
	bouton_nouvelle.add_theme_font_size_override("font_size", 26)
	bouton_nouvelle.pressed.connect(func() -> void: nouvelle_partie_demandee.emit())
	boutons.add_child(bouton_nouvelle)
	v.add_child(boutons)
	l_reprise = Style.label("", 22, Style.chiffres(), Style.TEXTE)
	l_reprise.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l_reprise)
	# Aide des raccourcis de test : jamais dans la version du joueur, jamais sur mobile
	l_aide = Style.label("F10 : format téléphone   ·   F8 : moment suivant   ·   F6 / F7 : naissance / jumeaux", 20, Style.ui(), Color(Style.TEXTE_2, 0.8))
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
		var r: Dictionary = sauvee["resume"]
		l_reprise.text = "Partie en cours : %s · %s · patrimoine %s" % [str(r.get("prenom", "")), Dates.texte(int(r["ab"])), Format.montant(float(r["patrimoine"]), int(r["ab"]))]


## Texte de la partie en cours, sans le préfixe (pour la confirmation d'effacement).
func texte_reprise() -> String:
	return l_reprise.text.trim_prefix("Partie en cours : ")


func donner_focus() -> void:
	bouton_jouer.grab_focus.call_deferred()
