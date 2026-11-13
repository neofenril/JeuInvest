class_name ModaleProjet
extends ModaleCarte
## Morceau de Modales (lot 05, 04-I ; docs/24 §1.1-1.2, lot_05 D12 ; contrat lot_04 §4.2) : les cartes du projet du foyer,
## même grammaire que la carte de dilemme (papier crème, liseré maison, apparition sur place, sans animation).
## - étape « choix » : 3 boutons de même style (touche, icône, nom, montant et échéance, « sous »), touches 1 / 2 / 3 ;
## - étape « echeance » (le jour J) : bandeau montant / sans rien vendre / il manque / après les ventes, liste courte des
##   ventes, 4 boutons en grille 2 × 2 (désactivés : hachurés, avec leur raison), touches 1 à 4 ;
## - « realiser_en_vendant » : écran de confirmation dans la carte (liste des ventes du moteur, total, ce qui reste),
##   CONFIRMER / RETOUR ; choix_fait("projet", id) n'est émis qu'au CONFIRMER ; Échap = RETOUR dans cet écran seulement ;
## - conclusion comme conclure_carte (ligne r["consequence"], tampon CHOISI, 3 s passable, fondu).

const LARGEUR_PC := 1176.0
const LARGEUR_TEL := 1356.0
const MAX_VENTES_PC := 4
const MAX_VENTES_TEL := 2
const SEUIL_SOUS_PC := 84          # caractères : au-delà, « sous » passe en note sous les boutons
const SEUIL_SOUS_TEL := 60
const PHRASE_VENTES := "de ce qui rapporte le moins à ce qui rapporte le plus"   # D7 bis, provisoire (K3) ; c["phrase_ventes"] la remplace

var etape := ""
var contenu: Dictionary = {}
var en_confirmation := false
var _confirme := false
var _principal: Control = null        # tout ce qui est visible hors confirmation
var _confirm: Control = null          # écran de confirmation
var _t_entete: Label = null


func _init(modales: Modales) -> void:
	super(modales)
	genre_emis = "projet"


## Hauteur des boutons : la plus grande des mises en page, jamais sous le minimum de l'étape (docs/24 §1.1-1.2).
func _ajuster_boutons(compact: bool) -> void:
	var haut := 0.0
	for k: String in boutons:
		var b: Button = boutons[k]
		var vb := b.get_node("Contenu") as Control
		for l in vb.find_children("*", "Label", true, false):
			var lab := l as Label
			if lab.autowrap_mode != TextServer.AUTOWRAP_OFF:
				lab.custom_minimum_size.x = maxf(60.0, b.size.x - 42.0 - (96.0 if etape != "echeance" else 0.0))
		haut = maxf(haut, vb.get_combined_minimum_size().y + 27.0)
	var mini := (84.0 if compact else 96.0) if etape == "echeance" else (180.0 if compact else 195.0)
	for k: String in boutons:
		(boutons[k] as Button).custom_minimum_size.y = maxf(mini, ceilf(haut / 3.0) * 3.0)


func ouvrir(c: Dictionary, depart: Vector2) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "projet"
	m.carte_en_cours = true
	phase = "entree"
	refus = 0
	_passer = false
	_confirme = false
	en_confirmation = false
	boutons.clear()
	choix.clear()
	ordre.clear()
	contenu = c
	etape = str(c.get("etape", "choix"))
	m.assombrir(0.6)
	var a := int(c.get("ab", Partie.etat.ab_courant() if Partie.etat != null else 0))
	var vue := m.get_viewport_rect().size
	var largeur := floorf(minf(LARGEUR_TEL if compact else LARGEUR_PC, vue.x - 30.0) / 3.0) * 3.0
	_panel = PanelContainer.new()
	_panel.name = "PapierProjet"
	_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_panel.add_theme_stylebox_override("panel", Style.papier("tuile", 30.0, 18.0 if compact else 24.0))
	_panel.custom_minimum_size = Vector2(largeur, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6 if compact else 12)
	_panel.add_child(v)
	var interieur := largeur - 66.0
	var l_source := Style.label("MA MAISON · " + str(c.get("date", "")).to_upper(), 20, Style.capitales(), Style.TEXTE_PAPIER_2)
	l_source.name = "Source"
	if not compact:
		v.add_child(l_source)   # téléphone : la ligne passe dans la colonne de l'en-tête (la hauteur est comptée : 648 px)
	# En-tête : portrait de Sylvie (toujours ×3), icône du projet, titre, texte
	var tete := HBoxContainer.new()
	tete.name = "Entete"
	tete.add_theme_constant_override("separation", 18 if compact else 24)
	var portrait := CadresPixel.icone("portrait_sylvie_" + ModaleCarte.nom_humeur(ModaleCarte._humeur_actuelle()))
	portrait.name = "Portrait"
	portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	tete.add_child(portrait)
	var colonne := VBoxContainer.new()
	colonne.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	colonne.add_theme_constant_override("separation", 4)
	if compact:
		colonne.add_child(l_source)
	var l_titre := HBoxContainer.new()
	l_titre.add_theme_constant_override("separation", 12)
	if etape == "echeance":
		var nom_icone := str(c.get("icone", ""))
		if nom_icone == "" and Partie.etat != null and Partie.etat.has_method("projet_en_cours"):
			nom_icone = str(Partie.etat.projet_en_cours().get("icone", ""))   # le contenu du jour J ne porte pas l'icône
		l_titre.add_child(_icone(nom_icone, str(c.get("titre", ""))))
	_t_entete = Style.label(str(c.get("titre", "")).to_upper(), 32 if compact else 40, Style.capitales(), Style.ENCRE)
	_t_entete.name = "Titre"
	_t_entete.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_t_entete.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_t_entete.custom_minimum_size.x = interieur - 144.0 - 24.0 - (60.0 if etape == "echeance" else 0.0)
	l_titre.add_child(_t_entete)
	colonne.add_child(l_titre)
	_texte = Style.label(str(c.get("texte", "")), 22 if compact else 24, Style.ui(), Style.ENCRE)
	_texte.name = "Texte"
	_texte.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texte.custom_minimum_size.x = interieur - 144.0 - 24.0
	_texte.max_lines_visible = 1 if (compact and etape == "echeance") else 3
	_texte.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	colonne.add_child(_texte)
	tete.add_child(colonne)
	v.add_child(tete)
	# Corps principal (hors confirmation)
	_principal = VBoxContainer.new()
	_principal.name = "Principal"
	_principal.add_theme_constant_override("separation", 6 if compact else 12)
	v.add_child(_principal)
	if etape == "echeance":
		_construire_echeance(c, a, compact, interieur)
	else:
		_construire_choix(c, a, compact, interieur)
	_suite = Style.label("Toucher pour continuer  ›", 20, Style.ui(), Style.TEXTE_PAPIER_2)
	_suite.name = "Suite"
	_suite.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_suite.modulate.a = 0.0
	_suite.visible = not compact   # téléphone : montré seulement à la conclusion (place)
	v.add_child(_suite)
	if etape == "echeance" and _a_confirmation(c):
		_confirm = _construire_confirmation(c, a, compact, interieur)
		_confirm.visible = false
		v.add_child(_confirm)
	_p = Control.new()
	_p.name = "Carte"
	_p.mouse_filter = Control.MOUSE_FILTER_STOP
	_p.add_child(_panel)
	_panel.gui_input.connect(_on_toucher)
	m.poser(_p)
	_p.visible = false
	await m.get_tree().process_frame
	await m.get_tree().process_frame
	if not is_instance_valid(_p):
		return
	_ajuster_boutons(compact)
	await m.get_tree().process_frame
	if not is_instance_valid(_p):
		return
	_panel.reset_size()
	var s1 := _panel.size
	var s2 := s1
	if _confirm != null:
		# La carte garde la même taille dans l'écran de confirmation : on mesure l'autre forme, on prend la plus grande
		_basculer(true)
		await m.get_tree().process_frame
		await m.get_tree().process_frame
		if not is_instance_valid(_p):
			return
		_panel.reset_size()
		s2 = _panel.size
		_basculer(false)
		_panel.custom_minimum_size = Vector2(largeur, maxf(s1.y, s2.y))
		await m.get_tree().process_frame
		if not is_instance_valid(_p):
			return
		_panel.reset_size()
	var s := (_panel.size / 3.0).ceil() * 3.0
	_panel.size = s
	_p.size = s
	_p.position = (((vue - s) / 2.0).max(Vector2(0, 6)) / 3.0).round() * 3.0
	await _entree(depart, _p.position, s)
	if is_instance_valid(_p) and phase == "entree":
		phase = "attente"


# =====================================================================
# Étape « choix » : 3 options de même style
# =====================================================================

func _construire_choix(c: Dictionary, a: int, compact: bool, interieur: float) -> void:
	var rangee := HBoxContainer.new()
	rangee.name = "Choix"
	rangee.add_theme_constant_override("separation", 15 if compact else 18)
	var k := 0
	var notes: Array[String] = []
	var largeur_b := (interieur - 2.0 * (15.0 if compact else 18.0)) / 3.0
	for ch: Dictionary in c.get("choix", []):
		k += 1
		var id := str(ch.get("id", ""))
		choix[id] = ch
		ordre.append(id)
		var sous := str(ch.get("sous", ""))
		var long := sous.length() > (SEUIL_SOUS_TEL if compact else SEUIL_SOUS_PC)
		if long:
			notes.append("(%d) %s" % [k, sous])
		var b := _bouton_choix_projet(ch, str(k), a, compact, largeur_b, long, k)
		boutons[id] = b
		rangee.add_child(b)
	_principal.add_child(rangee)
	for n in notes:
		var ln := Style.label(n, 20, Style.ui(), Style.TEXTE_PAPIER_2)
		ln.name = "Note"
		ln.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ln.custom_minimum_size.x = interieur
		ln.max_lines_visible = 3
		_principal.add_child(ln)
	if c.has("disponible"):
		var ld := Style.label(("Aujourd'hui : %s" if compact else "Aujourd'hui, sans rien vendre : %s (compte et Livret A)") % Format.entier(float(c["disponible"]), a), 20, Style.ui(), Style.TEXTE_PAPIER_2)
		ld.name = "Disponible"
		_principal.add_child(ld)


func _bouton_choix_projet(ch: Dictionary, numero: String, a: int, compact: bool, largeur: float, long: bool, rang: int) -> Button:
	var b := Button.new()
	b.name = "Choix_" + str(ch.get("id", ""))
	b.focus_mode = Control.FOCUS_NONE
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	CadresPixel.habiller_bouton(b, "papier")
	var vb := VBoxContainer.new()
	vb.name = "Contenu"
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", 2)
	var l1 := HBoxContainer.new()
	l1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l1.add_theme_constant_override("separation", 9)
	l1.add_child(_touche(numero))
	var ic := _icone(str(ch.get("icone", "")), str(ch.get("titre", "")))
	l1.add_child(ic)
	var t := Style.label(str(ch.get("titre", "")), 22 if compact else 24, Style.ui_gras(), Style.ENCRE)
	t.name = "TitreChoix"
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.max_lines_visible = 2
	t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	t.custom_minimum_size.x = maxf(60.0, largeur - 42.0 - 30.0 - 48.0 - 18.0)
	l1.add_child(t)
	vb.add_child(l1)
	var l2 := HBoxContainer.new()
	l2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l2.add_theme_constant_override("separation", 6)
	var lm := Style.label(Format.entier(float(ch.get("montant", 0.0)), a), 28 if compact else 30, Style.ui_gras(), Style.ENCRE)
	lm.name = "Montant"
	l2.add_child(lm)
	var le := Style.label("· " + str(ch.get("echeance_txt", "")), 20, Style.ui(), Style.ENCRE)
	le.name = "Echeance"
	le.size_flags_vertical = Control.SIZE_SHRINK_END
	l2.add_child(le)
	vb.add_child(l2)
	var sous := str(ch.get("sous", ""))
	if sous != "":
		var ls := Style.label(sous, 20, Style.ui(), Style.TEXTE_PAPIER_2)
		ls.name = "Sous"
		ls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ls.max_lines_visible = 2
		ls.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		ls.custom_minimum_size.x = maxf(60.0, largeur - 42.0)
		if long:
			ls.text = _tronquer(sous, 40 if compact else 56) + " … (%d)" % rang
		vb.add_child(ls)
	b.add_child(vb)
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.offset_left = 21
	vb.offset_right = -21
	vb.offset_top = 12
	vb.offset_bottom = -15
	b.custom_minimum_size = Vector2(0, 180.0 if compact else 195.0)
	b.pressed.connect(choisir.bind(str(ch.get("id", ""))))
	return b


# =====================================================================
# Étape « echeance » : le jour J
# =====================================================================

func _construire_echeance(c: Dictionary, a: int, compact: bool, interieur: float) -> void:
	var ventes: Array = c.get("ventes", [])
	# Bandeau : 4 cases (la 4e absente sans ventes)
	var bandeau := HBoxContainer.new()
	bandeau.name = "Bandeau"
	bandeau.add_theme_constant_override("separation", 0)
	var manque := float(c.get("manque", 0.0))
	var cases: Array = [["LE PROJET", Format.entier(float(c.get("montant", 0.0)), a), ""],
		["SANS RIEN VENDRE", Format.entier(float(c.get("disponible", 0.0)), a), "compte et Livret A"],
		["IL MANQUE", Format.entier(manque, a) if manque > 0.004 else "rien", ""]]
	if not ventes.is_empty():
		cases.append(["APRÈS LES VENTES", Format.entier(float(c.get("apres_ventes", 0.0)), a), ""])
	var noms := ["Montant", "Disponible", "Manque", "ApresVentes"]
	for i in cases.size():
		var pc := PanelContainer.new()
		pc.name = "Case" + noms[i]
		pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.set_border_width_all(0)
		sb.border_width_left = 3 if i > 0 else 0
		sb.border_width_top = 3
		sb.border_width_bottom = 3
		sb.border_width_right = 3 if i == cases.size() - 1 else 0
		sb.border_color = Style.ENCRE
		sb.content_margin_left = 12
		sb.content_margin_right = 12
		sb.content_margin_top = 6
		sb.content_margin_bottom = 6
		pc.add_theme_stylebox_override("panel", sb)
		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 0)
		cv.add_child(Style.label(str(cases[i][0]), 20, Style.capitales(), Style.TEXTE_PAPIER_2))
		var lv := Style.label(str(cases[i][1]), 28 if compact else 30, Style.ui_gras(), Style.ENCRE)
		lv.name = "Valeur"
		cv.add_child(lv)
		if str(cases[i][2]) != "" and not compact:
			cv.add_child(Style.label(str(cases[i][2]), 20, Style.ui(), Style.TEXTE_PAPIER_2))
		pc.add_child(cv)
		bandeau.add_child(pc)
	_principal.add_child(bandeau)
	# Ventes, version courte
	var bloc := VBoxContainer.new()
	bloc.name = "Ventes"
	bloc.add_theme_constant_override("separation", 2)
	if ventes.is_empty():
		var lr := Style.label("Rien à vendre : tout est disponible.", 20, Style.ui(), Style.TEXTE_PAPIER_2)
		lr.name = "RienAVendre"
		bloc.add_child(lr)
	else:
		var phrase := str(c.get("phrase_ventes", PHRASE_VENTES))
		var lt := Style.label("SI VOUS VENDEZ (%s)" % phrase, 20, Style.capitales(), Style.TEXTE_PAPIER_2)
		lt.name = "TitreVentes"
		lt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lt.custom_minimum_size.x = interieur
		bloc.add_child(lt)
		var maxi := MAX_VENTES_TEL if compact else MAX_VENTES_PC
		var n := 0
		for vt: Dictionary in ventes:
			if n >= maxi:
				break
			n += 1
			bloc.add_child(_ligne_vente(vt, a, compact))
		if ventes.size() > maxi:
			var lp := Style.label("+ %d autres placements : détail à l'étape suivante" % (ventes.size() - maxi), 20, Style.ui(), Style.TEXTE_PAPIER_2)
			lp.name = "PlusDeVentes"
			bloc.add_child(lp)
	_principal.add_child(bloc)
	# 4 boutons, grille 2 × 2 (la case vide reste vide)
	var grille := GridContainer.new()
	grille.name = "Choix"
	grille.columns = 2
	grille.add_theme_constant_override("h_separation", 12 if compact else 18)
	grille.add_theme_constant_override("v_separation", 12 if compact else 18)
	var k := 0
	var largeur_b := (interieur - (12.0 if compact else 18.0)) / 2.0
	for ch: Dictionary in c.get("choix", []):
		k += 1
		var id := str(ch.get("id", ""))
		choix[id] = ch
		ordre.append(id)
		var b := _bouton_jour_j(ch, k, a, compact, largeur_b)
		boutons[id] = b
		grille.add_child(b)
	_principal.add_child(grille)


## Ligne courte d'une vente : nom, net, écart signé avec les versements (sprite ▲ / ▼), coût de la vente.
func _ligne_vente(vt: Dictionary, a: int, compact: bool) -> Control:
	var h := HBoxContainer.new()
	h.name = "Vente"
	h.add_theme_constant_override("separation", 12)
	var ln := Style.label(str(vt.get("nom", "")), 22, Style.ui(), Style.ENCRE)
	ln.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ln.clip_text = true
	ln.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	ln.custom_minimum_size.x = 60
	h.add_child(ln)
	var lnet := Style.label(Format.entier(float(vt.get("net", 0.0)), a), 22, Style.ui_gras(), Style.ENCRE)
	lnet.custom_minimum_size.x = 120
	lnet.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.add_child(lnet)
	var ecart := float(vt.get("ecart_verse", 0.0))
	var he := HBoxContainer.new()
	he.custom_minimum_size.x = 150 if compact else 200
	he.alignment = BoxContainer.ALIGNMENT_END
	if absf(ecart) > 0.004:
		var fl := CadresPixel.icone("fleche_haut" if ecart > 0.0 else "fleche_bas", {"gain": "gain_papier", "perte": "perte_papier"})
		fl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		he.add_child(fl)
	var le := Style.label(("= 0 F" if absf(ecart) <= 0.004 else Format.ecart(ecart, a)), 22, Style.ui(), Style.GAIN_PAPIER if ecart > 0.004 else (Style.ENCRE_ROUGE if ecart < -0.004 else Style.ENCRE))
	he.add_child(le)
	h.add_child(he)
	var cout := float(vt.get("frais", 0.0)) + float(vt.get("impot", 0.0)) + float(vt.get("penalite", 0.0))
	var lc := Style.label(Format.entier(cout, a), 22, Style.ui(), Style.ENCRE)
	lc.custom_minimum_size.x = 100
	lc.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.add_child(lc)
	return h


func _bouton_jour_j(ch: Dictionary, rang: int, a: int, compact: bool, largeur: float) -> Button:
	var b := Button.new()
	b.name = "Choix_" + str(ch.get("id", ""))
	b.focus_mode = Control.FOCUS_NONE
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	CadresPixel.habiller_bouton(b, "papier")
	var desactive := bool(ch.get("desactive", false))
	b.disabled = desactive
	var vb := VBoxContainer.new()
	vb.name = "Contenu"
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", 0)
	var l1 := HBoxContainer.new()
	l1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l1.add_theme_constant_override("separation", 12)
	var touche := Style.label(str(rang), 24, Style.ui_gras(), Style.TEXTE_PAPIER_2)
	touche.name = "Touche"
	l1.add_child(touche)
	var t := Style.label(str(ch.get("titre", "")).to_upper(), 28, Style.capitales(), Style.ENCRE)
	t.name = "TitreChoix"
	t.clip_text = true
	t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.custom_minimum_size.x = 60
	l1.add_child(t)
	vb.add_child(l1)
	var sous := str(ch.get("sous", ""))
	if sous != "":
		var ls := Style.label(sous, 20, Style.ui(), Style.ENCRE_ROUGE if desactive else Style.TEXTE_PAPIER_2)
		ls.name = "Sous"
		ls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ls.max_lines_visible = 2
		ls.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		ls.custom_minimum_size.x = maxf(60.0, largeur - 42.0)
		vb.add_child(ls)
	b.add_child(vb)
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.offset_left = 21
	vb.offset_right = -21
	vb.offset_top = 9
	vb.offset_bottom = -12
	b.custom_minimum_size = Vector2(0, 84.0 if compact else 96.0)
	if desactive:
		var h := Control.new()
		h.name = "Hachures"
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		h.draw.connect(_dessiner_hachures.bind(h))
		b.add_child(h)
		b.gui_input.connect(_on_desactive)
	else:
		b.pressed.connect(choisir.bind(str(ch.get("id", ""))))
	return b


# =====================================================================
# Confirmation de RÉALISER EN VENDANT (dans la même carte)
# =====================================================================

func _a_confirmation(c: Dictionary) -> bool:
	for ch: Dictionary in c.get("choix", []):
		if str(ch.get("id", "")) == "realiser_en_vendant":
			return true
	return false


func _construire_confirmation(c: Dictionary, a: int, compact: bool, interieur: float) -> Control:
	var v := VBoxContainer.new()
	v.name = "Confirmation"
	v.add_theme_constant_override("separation", 6 if compact else 10)
	v.add_child(Style.label("CONFIRMER LES VENTES", 28, Style.capitales(), Style.ENCRE))
	var lp := Style.label("Ventes, %s." % str(c.get("phrase_ventes", PHRASE_VENTES)), 20, Style.ui(), Style.TEXTE_PAPIER_2)
	lp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lp.custom_minimum_size.x = interieur
	v.add_child(lp)
	var defile := ScrollContainer.new()
	defile.name = "Defilant"
	defile.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	defile.custom_minimum_size = Vector2(interieur, 120.0 if compact else 300.0)
	var liste := VBoxContainer.new()
	liste.add_theme_constant_override("separation", 6)
	liste.custom_minimum_size.x = interieur - 24.0
	var n := 0
	var total := 0.0
	for vt: Dictionary in c.get("ventes", []):
		n += 1
		total += float(vt.get("net", 0.0))
		if n > 1:
			liste.add_child(ModaleOutils.filet(Color(Style.ENCRE, 0.45), 3))
		var r1 := HBoxContainer.new()
		var tn := Style.label("%d  %s" % [n, str(vt.get("nom", ""))], 22, Style.ui_gras(), Style.ENCRE)
		tn.name = "NomVente"
		tn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r1.add_child(tn)
		var tm := Style.label(Format.entier(float(vt.get("net", 0.0)), a), 24, Style.ui_gras(), Style.ENCRE)
		tm.name = "NetVente"
		r1.add_child(tm)
		liste.add_child(r1)
		var te := Style.label(str(vt.get("texte_ecart", "")), 20, Style.ui(), Style.ENCRE)
		te.name = "EcartVente"
		te.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		te.custom_minimum_size.x = interieur - 48.0
		liste.add_child(te)
		if str(vt.get("texte_penalite", "")) != "":
			var tpn := Style.label(str(vt["texte_penalite"]), 20, Style.ui(), Style.TEXTE_PAPIER_2)
			tpn.name = "PenaliteVente"
			tpn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			tpn.custom_minimum_size.x = interieur - 48.0
			liste.add_child(tpn)
	defile.add_child(liste)
	v.add_child(defile)
	v.add_child(ModaleOutils.filet(Style.ENCRE, 3))
	var rt := HBoxContainer.new()
	var tt := Style.label("TOTAL DES VENTES (net)", 24, Style.ui_gras(), Style.ENCRE)
	tt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rt.add_child(tt)
	var tv := Style.label(Format.entier(total, a), 24, Style.ui_gras(), Style.ENCRE)
	tv.name = "TotalVentes"
	rt.add_child(tv)
	v.add_child(rt)
	var apres := float(c.get("apres_ventes", 0.0))
	var montant := float(c.get("montant", 0.0))
	var la := Style.label("Avec votre compte et votre Livret A : %s pour un projet de %s." % [Format.entier(apres, a), Format.entier(montant, a)], 22, Style.ui(), Style.ENCRE)
	la.name = "AvecCompte"
	la.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	la.custom_minimum_size.x = interieur
	v.add_child(la)
	var reste := apres - montant
	var lr := Style.label("Ce qui reste va sur votre compte%s." % ((" : " + Format.entier(reste, a)) if reste > 0.004 else ""), 22, Style.ui(), Style.ENCRE)
	lr.name = "Reste"
	v.add_child(lr)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 12 if compact else 18)
	var bc := ModaleOutils.bouton_papier("1  CONFIRMER", "", compact)
	bc.name = "Confirmer"
	bc.pressed.connect(_confirmer_ventes)
	hb.add_child(bc)
	var br := ModaleOutils.bouton_papier("2  RETOUR", "", compact)
	br.name = "Retour"
	br.pressed.connect(_retour)
	hb.add_child(br)
	v.add_child(hb)
	return v


func _basculer(confirmation: bool) -> void:
	en_confirmation = confirmation
	_principal.visible = not confirmation
	_confirm.visible = confirmation
	if _texte != null:
		_texte.visible = not confirmation


func _confirmer_ventes() -> void:
	if phase != "attente" or not en_confirmation:
		return
	_confirme = true
	choisir("realiser_en_vendant")
	_confirme = false


func _retour() -> void:
	if phase == "attente" and en_confirmation:
		_basculer(false)


## Échap : RETOUR dans l'écran de confirmation seulement (sans effet ailleurs, A39).
func echap() -> void:
	_retour()


## RÉALISER EN VENDANT ouvre d'abord la confirmation ; le choix n'est émis qu'au CONFIRMER.
func choisir(id: String) -> void:
	if phase != "attente" or not choix.has(id):
		return
	if etape == "echeance" and id == "realiser_en_vendant" and not _confirme:
		if bool(choix[id].get("desactive", false)):
			refus += 1
			return
		if _confirm != null:
			_basculer(true)
		return
	super.choisir(id)


## Touches 1 à 4 ; dans la confirmation : 1 = CONFIRMER, 2 = RETOUR.
func choisir_rang(n: int) -> void:
	if en_confirmation:
		if n == 0:
			_confirmer_ventes()
		elif n == 1:
			_retour()
		return
	super.choisir_rang(n)


## Conclusion : la carte reprend sa forme principale (l'écran de confirmation disparaît).
func conclure(r: Dictionary, arrivee: Vector2) -> void:
	if is_instance_valid(_suite):
		_suite.visible = true
	if en_confirmation and _confirm != null and is_instance_valid(_p):
		_basculer(false)
	await super.conclure(r, arrivee)


# =====================================================================
# Petits éléments
# =====================================================================

## Icône du projet : sprite 16 × 16 ×3 (48 px) ; absente : l'initiale dans un carré encre 48 × 48.
func _icone(nom: String, titre: String) -> Control:
	CadresPixel.charger()
	if nom != "" and GrillePixel.existe("ui/" + nom):
		var r := CadresPixel.icone(nom)
		r.name = "IconeProjet"
		r.custom_minimum_size = Vector2(48, 48)
		r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		return r
	var pc := PanelContainer.new()
	pc.name = "IconeProjet"
	pc.custom_minimum_size = Vector2(48, 48)
	pc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = Style.ENCRE
	pc.add_theme_stylebox_override("panel", sb)
	var li := Style.label(titre.strip_edges().left(1).to_upper(), 28, Style.capitales(), PalettePixel.couleur("creme"))
	li.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	li.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pc.add_child(li)
	return pc


## Numéro de touche : Atkinson gras 24 dans un carré encre 30 × 30.
func _touche(numero: String) -> Control:
	var pc := PanelContainer.new()
	pc.name = "Touche"
	pc.custom_minimum_size = Vector2(30, 30)
	pc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = Style.ENCRE
	pc.add_theme_stylebox_override("panel", sb)
	var l := Style.label(numero, 24, Style.ui_gras(), PalettePixel.couleur("creme"))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pc.add_child(l)
	return pc


static func _tronquer(t: String, n: int) -> String:
	if t.length() <= n:
		return t
	var coupe := t.left(n)
	var i := coupe.rfind(" ")
	return coupe.left(i) if i > 20 else coupe


## Relecture d'un projet depuis l'historique (lecture seule) : titre, choix pris, montant, conséquence.
func lecture_projet(h: Dictionary, a: int) -> void:
	await lecture(h, a)
