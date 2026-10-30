class_name ModaleBanquier
extends RefCounted
## Morceau de Modales (T9) : la carte de présentation de M. Lefranc (13 §1) et la carte « nouvelle »
## (héritage, D08) : portrait qui parle, texte, ticket chiffré, comparatif, « En savoir plus ».

var m: Modales
var _carte_retournee := false


func _init(modales: Modales) -> void:
	m = modales


## Portrait réduit : le dessin du portrait est fait pour 120 px, on l'échelonne dans une boîte.
func _mini_portrait(taille: float) -> Control:
	var boite := Control.new()
	boite.custom_minimum_size = Vector2(taille, taille)
	boite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boite.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	m.portrait = Portrait.new()
	m.portrait.size = Vector2(120, 120)
	m.portrait.scale = Vector2.ONE * taille / 120.0
	boite.add_child(m.portrait)
	return boite


## c : Banquier.contenu (kind « banquier »). lecture : relecture depuis le carnet (un seul bouton Fermer).
func ouvrir(c: Dictionary, depart: Vector2, lecture := false, bandeau := "") -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "appel"
	_carte_retournee = false
	var heritage: bool = c.get("heritage", false)
	m.choix_exterieur = "fermer" if lecture else ("compris" if heritage else "plus_tard")
	m.assombrir(0.5)
	var vue := m.get_viewport_rect().size
	var a: int = c.get("ab", 0)
	var p := PanelContainer.new()
	var s := Style.boite(Style.PANNEAU_ELEVE, 22, 22 if compact else 30, 14 if compact else 22)
	Style.bordure(s, Style.ACCENT, 2, 2, 2, 2)
	Style.ombre(s, Color(0, 0, 0, 0.7), 24, Vector2(0, 10))
	p.add_theme_stylebox_override("panel", s)
	p.custom_minimum_size = Vector2(minf(1320.0, vue.x - 60.0), 0)
	var interieur := p.custom_minimum_size.x - (44.0 if compact else 60.0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6 if compact else 12)
	p.add_child(v)
	# En-tête : portrait, nom, date, rang ; tuile du produit ; croix
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 16)
	tete.add_child(_mini_portrait(64.0 if compact else 104.0))
	var vt := VBoxContainer.new()
	vt.add_theme_constant_override("separation", -2)
	vt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vt.add_child(Style.label(str(m.donnees_demo.get("banquier", {}).get("nom", "M. LEFRANC")) + " · votre banquier", 24 if compact else 28, Style.ui_gras()))
	var sous := "Banque · " + str(c.get("date", ""))
	if lecture:
		sous += " · relecture"
	vt.add_child(Style.label(sous, 18 if compact else 20, Style.ui(), Style.TEXTE_2))
	var rang := "UNE NOUVELLE" if heritage else "NOUVEAU PRODUIT · %d sur %d" % [int(c.get("rang", 1)), int(c.get("total", 9))]
	if lecture:
		rang = bandeau if bandeau != "" else "RELECTURE · CHIFFRES D'AUJOURD'HUI"
	vt.add_child(Style.label(rang, 16 if compact else 18, Style.capitales(), Style.ACCENT))
	tete.add_child(vt)
	var tuile := PanelContainer.new()
	var st := Style.boite(Color(c.get("couleur", Style.ACCENT), 0.22), 10, 16, 8)
	Style.bordure(st, c.get("couleur", Style.ACCENT), 8, 0, 0, 0)
	tuile.add_theme_stylebox_override("panel", st)
	tuile.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tuile.add_child(Style.label(str(c.get("titre", "")), 22 if compact else 26, Style.capitales(), Style.TEXTE))
	tete.add_child(tuile)
	var x := Button.new()
	x.custom_minimum_size = Vector2(72, 72)
	x.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	x.draw.connect(ModaleOutils.dessiner_croix.bind(x))
	x.pressed.connect(func() -> void: m.fermer(m.choix_exterieur))
	tete.add_child(x)
	v.add_child(tete)
	v.add_child(ModaleOutils.filet(Style.FILET, 2))
	# Corps : le texte à gauche, l'argent du joueur et le comparatif à droite
	var corps := HBoxContainer.new()
	corps.add_theme_constant_override("separation", 22 if compact else 36)
	v.add_child(corps)
	var largeur_g := floorf(interieur * (0.44 if compact else 0.43))
	var largeur_d := interieur - largeur_g - (22.0 if compact else 36.0)
	var gauche := VBoxContainer.new()
	gauche.add_theme_constant_override("separation", 8)
	corps.add_child(gauche)
	var texte := Style.label("« " + str(c.get("texte", "")) + " »", 21 if compact else 26, Style.ui(), Style.TEXTE)
	texte.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texte.custom_minimum_size.x = largeur_g
	texte.visible_ratio = 0.0
	texte.name = "Texte"
	gauche.add_child(texte)
	if str(c.get("note", "")) != "":
		var note := Style.label(str(c["note"]), 18 if compact else 20, Style.ui_gras(), Style.ALERTE)
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note.custom_minimum_size.x = largeur_g
		gauche.add_child(note)
	var droite := VBoxContainer.new()
	droite.add_theme_constant_override("separation", 4 if compact else 8)
	droite.custom_minimum_size.x = largeur_d
	corps.add_child(droite)
	droite.add_child(Style.label("AVEC VOTRE ARGENT", 16 if compact else 18, Style.capitales(), Style.TEXTE_2))
	droite.add_child(_ticket(c, a, largeur_d))
	if c.has("comparatif"):
		droite.add_child(_comparatif(c["comparatif"], largeur_d))
	v.add_child(_pied(c, p, texte, lecture, heritage))
	m.poser(p)
	await m.centrer(p)
	if not is_instance_valid(p):
		return
	# Entrée : la carte se déplie depuis la banque, puis M. Lefranc parle (1 s au plus)
	var cible := p.position
	var duree_texte := minf(1.0, texte.text.length() * 0.012)
	m.parler = 0.35 + duree_texte
	if not Juice.animations_reduites and depart.x >= 0.0:
		p.pivot_offset = p.size / 2.0
		p.scale = Vector2(0.6, 0.6)
		p.position = depart - p.size / 2.0
		p.modulate.a = 0.0
		var tw := p.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(p, "position", cible, 0.35)
		tw.tween_property(p, "scale", Vector2.ONE, 0.35)
		tw.tween_property(p, "modulate:a", 1.0, 0.2)
	var tt := texte.create_tween()
	tt.tween_interval(0.3)
	tt.tween_property(texte, "visible_ratio", 1.0, duree_texte)


## Pied : 3 choix de même poids (13 §1.1), « En savoir plus » retourne la carte.
func _pied(c: Dictionary, p: Control, texte: Label, lecture: bool, heritage: bool) -> HBoxContainer:
	var compact := m.compact
	var pied := HBoxContainer.new()
	pied.add_theme_constant_override("separation", 16)
	if lecture or heritage:
		var ok := Style.bouton("FERMER" if lecture else "COMPRIS", false, 72 if compact else 80)
		ok.custom_minimum_size.x = 360
		ok.pressed.connect(func() -> void: m.fermer(m.choix_exterieur))
		pied.add_child(ok)
	else:
		var ouvrir_b := Style.bouton(str(c.get("bouton", "OUVRIR")), false, 72 if compact else 80)
		ouvrir_b.custom_minimum_size.x = 340 if compact else 380
		ouvrir_b.pressed.connect(m.fermer.bind("ouvrir"))
		pied.add_child(ouvrir_b)
		var tard := Style.bouton("PAS MAINTENANT", false, 72 if compact else 80)
		tard.custom_minimum_size.x = 340 if compact else 380
		tard.pressed.connect(m.fermer.bind("plus_tard"))
		pied.add_child(tard)
	var ressort := Control.new()
	ressort.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pied.add_child(ressort)
	if str(c.get("plus", "")) != "":
		var plus := Button.new()
		plus.text = "En savoir plus ›"
		plus.flat = true
		plus.custom_minimum_size = Vector2(0, 64)
		plus.add_theme_color_override("font_color", Style.ACCENT)
		plus.add_theme_color_override("font_hover_color", Style.ACCENT.lightened(0.2))
		plus.add_theme_font_size_override("font_size", 22)
		plus.pressed.connect(_retourner_carte.bind(p, texte, plus, c))
		pied.add_child(plus)
	return pied


## Le ticket chiffré (13 §1.3) : un montant clé avec l'argent du joueur ; à 2 colonnes pour la succession.
func _ticket(c: Dictionary, a: int, largeur: float) -> Control:
	var compact := m.compact
	var tk: Array = c.get("ticket", [])
	var p := PanelContainer.new()
	var s := Style.boite(Style.PANNEAU, 12, 18, 8 if compact else 12)
	Style.bordure(s, Style.OR, 2, 2, 2, 2)
	p.add_theme_stylebox_override("panel", s)
	var taille := 26 if compact else 32
	if c.get("heritage", false) and tk.size() >= 6:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 24)
		# Colonne 1 : l'argent reçu (vert). Colonne 2 : l'hypothèse « si ça avait été par succession »,
		# atténuée et barrée, pour ne jamais laisser croire à un second versement.
		var largeur_col := (largeur - 36.0 - 24.0) / 2.0
		for k in 2:
			var col := VBoxContainer.new()
			col.add_theme_constant_override("separation", -2)
			col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			col.custom_minimum_size.x = largeur_col
			if k == 1:
				col.modulate.a = 0.75
			var t0 := Style.label(str(tk[3 * k]).to_upper(), 16, Style.capitales(), Style.TEXTE_2)
			t0.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			t0.custom_minimum_size.x = largeur_col
			col.add_child(t0)
			var lm := Style.label(str(tk[3 * k + 1]), taille, Style.chiffres(), Style.GAIN if k == 0 else Style.TEXTE_2)
			lm.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			if k == 1:
				lm.draw.connect(ModaleOutils.barrer.bind(lm))
			col.add_child(lm)
			var t2 := Style.label(str(tk[3 * k + 2]), 18, Style.ui(), Style.TEXTE_2)
			t2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			t2.custom_minimum_size.x = largeur_col
			col.add_child(t2)
			h.add_child(col)
		p.add_child(h)
		return p
	if c.get("ticket_succession", false) and tk.size() >= 5:
		var vv := VBoxContainer.new()
		vv.add_theme_constant_override("separation", 2)
		vv.add_child(Style.label(str(tk[0]), 18 if compact else 20, Style.ui(), Style.TEXTE))
		var h2 := HBoxContainer.new()
		h2.add_theme_constant_override("separation", 24)
		for k in 2:
			var col2 := VBoxContainer.new()
			col2.add_theme_constant_override("separation", -2)
			col2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			col2.add_child(Style.label(str(tk[1 + 2 * k]).to_upper(), 16, Style.capitales(), Style.TEXTE_2))
			col2.add_child(Style.label(str(tk[2 + 2 * k]), taille, Style.chiffres(), Style.TEXTE_2 if k == 0 else Style.GAIN))
			h2.add_child(col2)
		vv.add_child(h2)
		var le := Style.label(str(c.get("ligne_enfant", "")), 18, Style.ui(), Style.TEXTE_2)
		le.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		le.custom_minimum_size.x = largeur - 40.0
		vv.add_child(le)
		p.add_child(vv)
		return p
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 14)
	hb.add_child(Style.label(str(tk[0]) if tk.size() > 0 else "", taille, Style.chiffres(), Style.TEXTE))
	var fl := Style.label("›", taille, Style.ui_gras(), Style.OR)
	hb.add_child(fl)
	var suite := Style.label(str(tk[1]) if tk.size() > 1 else "", 20 if compact else 24, Style.ui_gras(), Style.TEXTE)
	suite.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	suite.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	suite.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	suite.custom_minimum_size.x = largeur * 0.45
	hb.add_child(suite)
	p.add_child(hb)
	return p


## « Par rapport à ce que vous connaissez » (12 R8) : 4 critères en pastilles et en mots, et les frais.
func _comparatif(cp: Dictionary, largeur: float) -> Control:
	var compact := m.compact
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	var ref_nom := str(cp["ref_nom"])
	var titre := "PAR RAPPORT À VOTRE " + ref_nom.to_upper() + " (vous en avez)" if cp["ref_detenu"] else "PAR RAPPORT AU " + ref_nom.to_upper()
	if cp["ref"] == "cc":
		titre = "PAR RAPPORT À VOTRE COMPTE COURANT"
	var lt := Style.label(titre, 16 if compact else 18, Style.capitales(), Style.TEXTE_2)
	lt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lt.custom_minimum_size.x = largeur
	v.add_child(lt)
	var g := GridContainer.new()
	g.columns = 6
	g.add_theme_constant_override("h_separation", 8 if compact else 12)
	g.add_theme_constant_override("v_separation", 0 if compact else 2)
	var fs := 18 if compact else 20
	for h in ["", str(cp["nom"]), "", ref_nom, "", ""]:
		g.add_child(Style.label(h, 16, Style.ui_gras(), Style.TEXTE_2))
	var couleur: Color = Banquier.couleur(str(cp["produit"]))
	var couleur_ref: Color = Banquier.couleur(str(cp["ref"]))
	for l in cp["lignes"]:
		g.add_child(Style.label(str(l["critere"]), fs, Style.ui(), Style.TEXTE_2))
		g.add_child(Pastilles.creer(int(l["note"]), couleur))
		g.add_child(Style.label(str(l["mot"]), fs, Style.ui(), Style.TEXTE))
		g.add_child(Pastilles.creer(int(l["note_ref"]), couleur_ref))
		g.add_child(Style.label(str(l["mot_ref"]), fs, Style.ui(), Style.TEXTE))
		var sens := Style.label(str(l["sens"]), fs, Style.ui_gras(), Style.TEXTE_2)
		sens.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sens.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		g.add_child(sens)
	v.add_child(g)
	var lf := Style.label("Frais : %s   ·   %s : %s" % [str(cp["frais"]), ref_nom, str(cp["frais_ref"])], fs, Style.ui_gras(), Style.CUIVRE)
	lf.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lf.custom_minimum_size.x = largeur
	v.add_child(lf)
	if int(cp["lignes"][0]["note"]) >= 3 and str(cp["lignes"][0]["mot"]).ends_with("*"):
		v.add_child(Style.label("* espéré, jamais garanti ; le passé ne prédit rien.", 16, Style.ui(), Style.TEXTE_2))
	return v


## « En savoir plus » (13 §1.4) : la carte se retourne et montre la réplique détaillée.
func _retourner_carte(p: Control, texte: Label, bouton: Button, c: Dictionary) -> void:
	_carte_retournee = not _carte_retournee
	var nouveau := "« " + str(c["plus"] if _carte_retournee else c["texte"]) + " »"
	bouton.text = "‹ Retour" if _carte_retournee else "En savoir plus ›"
	if Juice.animations_reduites:
		texte.text = nouveau
		return
	p.pivot_offset = p.size / 2.0
	var t := p.create_tween()
	t.tween_property(p, "scale:x", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_callback(func() -> void: texte.text = nouveau)
	t.tween_property(p, "scale:x", 1.0, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
