class_name EcranTitre
extends Control
## Écran titre (09 §5) posé sur la ville au crépuscule : accroche, sous-titre, JOUER / CONTINUER,
## NOUVELLE PARTIE et ligne de reprise. N'agit jamais sur Partie : il émet des signaux que la scène
## principale traite (principal.gd : jouer, demander_nouvelle_partie).

signal jouer_demande
signal nouvelle_partie_demandee
signal titres_demande   # bouton TITRES ou touche T (lot 07-I)

var bouton_jouer: Button
var bouton_nouvelle: Button
var l_reprise: Label
var l_aide: Label
var rangee_palmares: HBoxContainer   # « Meilleur résultat… » + bouton TITRES ; absente sans records.sav
var l_palmares: Label
var bouton_titres: Button


## Construit l'écran (à appeler avant de l'ajouter à l'arbre). demo : data/chapitres/<id>/chapitre.json.
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
	# Palmarès (lot 07-I, docs/29 §2) : phrase du meilleur résultat sur une plaque + bouton TITRES « n / 9 »
	rangee_palmares = HBoxContainer.new()
	rangee_palmares.name = "Palmares"
	rangee_palmares.alignment = BoxContainer.ALIGNMENT_CENTER
	rangee_palmares.add_theme_constant_override("separation", 18)
	rangee_palmares.visible = false
	var plaque_p := CadresPixel.panneau("panneau")
	plaque_p.name = "PlaquePalmares"
	plaque_p.add_theme_stylebox_override("panel", CadresPixel.style_marges("panneau", 18, 9, 18, 9))
	plaque_p.self_modulate = Color(1, 1, 1, 0.94)
	plaque_p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l_palmares = Style.label("", 22, Style.ui_gras(), Style.TEXTE)
	l_palmares.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l_palmares.custom_minimum_size.x = 900
	plaque_p.add_child(l_palmares)
	rangee_palmares.add_child(plaque_p)
	bouton_titres = Style.bouton("TITRES", false, 81)
	bouton_titres.name = "BoutonTitres"
	bouton_titres.custom_minimum_size = Vector2(230, 81)
	bouton_titres.add_theme_font_size_override("font_size", 28)
	bouton_titres.pressed.connect(func() -> void: titres_demande.emit())
	rangee_palmares.add_child(bouton_titres)
	v.add_child(rangee_palmares)
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


## Palmarès selon Records.lire() : absent sans collection ; phrase seule si un record existe ; TITRES « n / 9 » toujours.
func maj_palmares(records: Dictionary, nb_titres: int, par_chapitre: Array = []) -> void:
	if par_chapitre.size() > 1:
		_palmares_chapitres(records, par_chapitre)
		return
	var coll: Dictionary = records.get("collection", {})
	var rec: Dictionary = records.get("record", {})
	rangee_palmares.visible = not coll.is_empty() or not rec.is_empty()
	l_palmares.get_parent().visible = not rec.is_empty()
	if not rec.is_empty():
		var x := float(rec.get("ecart_pct", 0.0))
		var rang := int(rec.get("rang", 0))
		var t := "Meilleur résultat : %s face à Tata Livret" % ModaleReleveFin.pct_texte(x)
		if rang > 0:
			t += " · %s de la rue" % BlocRue.rang_texte(rang)
		t += " · %s" % str(rec.get("titre_nom", ""))
		l_palmares.text = t
	else:
		l_palmares.text = ""
	bouton_titres.text = "TITRES  %d / %d" % [coll.size(), nb_titres]


## Plusieurs chapitres ouverts (lot 10b, I7 ; docs/40 §3.2) : une ligne « Départ 1984 : meilleur résultat » par chapitre de départ qui a un
## record, puis une ligne par record de partie (« 1984 › 1993 »), le tout sur la même plaque ; TITRES « obtenus / total » sur tous les chapitres.
func _palmares_chapitres(records: Dictionary, par_chapitre: Array) -> void:
	var chapitres: Dictionary = records.get("chapitres", {})
	var lignes: Array = []
	var obtenus := 0
	var total := 0
	for c: Dictionary in par_chapitre:
		var id := str(c["id"])
		var d: Dictionary = chapitres.get(id, {})
		total += (c["titres"] as Array).size()
		obtenus += (d.get("collection", {}) as Dictionary).size()
		var rc: Dictionary = d.get("record_chapitre", {})
		if not rc.is_empty():
			var t := "Départ %s · meilleur résultat : %s face à Tata Livret" % [str(c["annees"]).left(4), ModaleReleveFin.pct_texte(float(rc.get("ecart_pct", 0.0)))]
			if int(rc.get("rang", 0)) > 0:
				t += " · %s de la rue" % BlocRue.rang_texte(int(rc["rang"]))
			lignes.append(t + " · %s" % str(rc.get("titre_nom", "")))
		var rp: Dictionary = d.get("records_partie", {})
		var annees: Array = rp.keys()
		annees.sort()
		for fin in annees:
			var r: Dictionary = rp[fin]
			lignes.append("Départ %s, partie jusqu'en %s : %s face à Tata Livret%s" % [str(c["annees"]).left(4), str(fin), ModaleReleveFin.pct_texte(float(r.get("ecart_pct", 0.0))),
				(" · %s de la rue" % BlocRue.rang_texte(int(r["rang"]))) if int(r.get("rang", 0)) > 0 else ""])
	rangee_palmares.visible = obtenus > 0 or not lignes.is_empty()
	l_palmares.get_parent().visible = not lignes.is_empty()
	l_palmares.text = "\n".join(PackedStringArray(lignes))
	bouton_titres.text = "TITRES  %d / %d" % [obtenus, total]


func _unhandled_input(ev: InputEvent) -> void:
	var k := ev as InputEventKey
	if k != null and k.pressed and not k.echo and k.keycode == KEY_T and is_visible_in_tree() and rangee_palmares != null and rangee_palmares.visible:
		titres_demande.emit()
		get_viewport().set_input_as_handled()


## Texte de la partie en cours, sans le préfixe (pour la confirmation d'effacement).
func texte_reprise() -> String:
	return l_reprise.text.trim_prefix("Partie en cours : ")


func donner_focus() -> void:
	bouton_jouer.grab_focus.call_deferred()
