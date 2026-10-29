class_name Hud
extends Control
## Tableau de bord superposé à la ville (09 §4.2-4.3) : barre haute (date à volets, temps, compte,
## patrimoine), frise, panneau « Mon argent » (courbe, répartition, budget, coussin, marché),
## notifications, étiquettes des bâtiments, cadre « gel » de la pause.
## Une seule mise en page : sur téléphone (compact), le panneau se replie en languette.

signal vitesse_demandee(v: int)
signal marche_demande
signal menu_demande
signal raccourci_demo
signal batiment_touche(id: String)
signal disposition_changee
signal comparaison_demandee
signal frais_demandes
signal notif_touchee(n: Dictionary)
signal historique_demande

const HAUT := 96.0
const BAS := 72.0
const LARGEUR_PANNEAU := 500.0
const LARGEUR_PANNEAU_COMPACT := 900.0
const LARGEUR_LANGUETTE := 104.0
const NOMS_SOURCES := {"maison": "MA MAISON", "banque": "MA BANQUE", "media": "LA GAZETTE"}

var ville: Node2D = null
var compact := false
var panneau_ouvert := true

var barre: PanelContainer
var date: DateVolets
var boutons: Dictionary = {}
var b_lecture: BoutonTemps
var b_cycle: BoutonTemps
var badge_pause: Label
var boite_baguette: VBoxContainer
var l_baguette: Label
var carte_cc: PanelContainer
var boite_cc: VBoxContainer
var l_titre_cc: Label
var l_cc: Label
var separateur: Control
var l_patr: Label
var l_var: Label
var pastille_livret: PanelContainer
var l_titre_livret: Label
var l_ecart: Label
var fleche_ecart: Control
var _ecart_affiche := 0.0
var _sens_ecart := 0
var l_ecart_note: Label
var bas: PanelContainer
var frise: Frise
var panneau: PanelContainer
var conteneur: BoxContainer
var l_bag: Label
var courbe: Courbe
var repart: Repartition
var l_salaire: Label
var l_depenses: Label
var l_reste: Label
var l_auto: Label
var jauge: Control
var l_coussin: Label
var l_frais: Label
var _frais_affiches := 0.0
var _point_banque := false
var b_marche: Button
var b_historique: Button
var languette: Button
var notifs: Control
var etiquettes: Dictionary = {}
var cadre_gel: Control
var _gel := 0.0
var _coussin := 0.0
var _cc_affiche := 0.0
var _patr_affiche := 0.0
var _liste_notifs: Array = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = Style.theme()
	cadre_gel = Control.new()
	cadre_gel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cadre_gel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cadre_gel.draw.connect(_dessiner_gel)
	add_child(cadre_gel)
	_creer_etiquettes()
	_creer_barre()
	_creer_bas()
	_creer_panneau()
	notifs = Control.new()
	notifs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notifs.position = Vector2(16, HAUT + 16)
	add_child(notifs)
	Ecran.format_change.connect(_disposer)
	_disposer()


# =====================================================================
# Construction
# =====================================================================

func _creer_barre() -> void:
	barre = PanelContainer.new()
	var s := Style.boite(Style.PANNEAU, 0, 20, 8)
	Style.bordure(s, Color(1, 1, 1, 0.08), 0, 0, 0, 1)
	Style.ombre(s, Color(0, 0, 0, 0.45), 14, Vector2(0, 4))
	barre.add_theme_stylebox_override("panel", s)
	barre.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	barre.offset_bottom = HAUT
	add_child(barre)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 16)
	barre.add_child(h)
	date = DateVolets.new()
	date.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	date.triple_touche.connect(func() -> void: raccourci_demo.emit())
	h.add_child(date)
	boite_baguette = _bloc("BAGUETTE", 20)
	l_baguette = Style.label("", 30, Style.chiffres())
	boite_baguette.add_child(l_baguette)
	h.add_child(boite_baguette)
	h.add_child(_ressort())
	var temps := HBoxContainer.new()
	temps.add_theme_constant_override("separation", 10)
	temps.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for g in ["pause", "x1", "x2", "x3"]:
		var b := BoutonTemps.new(g)
		var v: int = ["pause", "x1", "x2", "x3"].find(g)
		b.pressed.connect(func() -> void: vitesse_demandee.emit(v))
		temps.add_child(b)
		boutons[g] = b
	b_lecture = BoutonTemps.new("lecture")
	b_lecture.pressed.connect(func() -> void: vitesse_demandee.emit(-1))
	temps.add_child(b_lecture)
	b_cycle = BoutonTemps.new("cycle")
	b_cycle.pressed.connect(func() -> void: vitesse_demandee.emit(-2))
	temps.add_child(b_cycle)
	h.add_child(temps)
	badge_pause = Style.label("EN PAUSE", 24, Style.neon(), Style.GEL)
	badge_pause.add_theme_color_override("font_shadow_color", Color(Style.GEL, 0.6))
	badge_pause.add_theme_constant_override("shadow_outline_size", 12)
	badge_pause.add_theme_constant_override("shadow_offset_x", 0)
	badge_pause.add_theme_constant_override("shadow_offset_y", 0)
	badge_pause.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge_pause.custom_minimum_size = Vector2(150, 0)
	h.add_child(badge_pause)
	h.add_child(_ressort())
	# Argent (retour joueur du 27/10/2026) : le compte courant dans sa propre carte, nettement séparé
	# du patrimoine par un filet vertical, puis l'écart avec « tout au Livret A » en pastille.
	var argent := HBoxContainer.new()
	argent.add_theme_constant_override("separation", 0)
	argent.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(argent)
	carte_cc = PanelContainer.new()
	var scc := Style.boite(Color(1, 1, 1, 0.05), 12, 16, 4)
	Style.bordure(scc, Color(1, 1, 1, 0.12), 1, 1, 1, 1)
	carte_cc.add_theme_stylebox_override("panel", scc)
	carte_cc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	carte_cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boite_cc = _bloc("COMPTE COURANT", 18)
	l_titre_cc = boite_cc.get_child(0) as Label
	l_cc = Style.label("", 32, Style.chiffres())
	l_cc.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	boite_cc.add_child(l_cc)
	carte_cc.add_child(boite_cc)
	argent.add_child(carte_cc)
	separateur = Control.new()
	separateur.custom_minimum_size = Vector2(56, 64)
	separateur.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	separateur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	separateur.draw.connect(_dessiner_separateur)
	argent.add_child(separateur)
	var bp := _bloc("PATRIMOINE", 20)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 12)
	ligne.alignment = BoxContainer.ALIGNMENT_END
	l_patr = Style.label("", 44, Style.chiffres())
	l_var = Style.label("", 20, Style.chiffres(), Style.TEXTE_2)
	l_var.size_flags_vertical = Control.SIZE_SHRINK_END
	ligne.add_child(l_patr)
	ligne.add_child(l_var)
	bp.add_child(ligne)
	argent.add_child(bp)
	var marge := Control.new()
	marge.custom_minimum_size = Vector2(18, 0)
	marge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	argent.add_child(marge)
	_creer_pastille_livret()
	argent.add_child(pastille_livret)
	var menu := Button.new()
	menu.custom_minimum_size = Vector2(80, 80)
	menu.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	menu.focus_mode = Control.FOCUS_NONE
	menu.draw.connect(_dessiner_menu.bind(menu))
	menu.pressed.connect(func() -> void: menu_demande.emit())
	h.add_child(menu)


## Pastille permanente « VS TOUT AU LIVRET A » : flèche (▲ devant, ▼ derrière, = à égalité), montant
## signé et couleur : trois indices, pas seulement le rouge et le vert. Un toucher l'explique.
func _creer_pastille_livret() -> void:
	pastille_livret = PanelContainer.new()
	pastille_livret.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pastille_livret.mouse_filter = Control.MOUSE_FILTER_STOP
	pastille_livret.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pastille_livret.custom_minimum_size = Vector2(0, 72)
	pastille_livret.gui_input.connect(_on_pastille_livret)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", -4)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	pastille_livret.add_child(v)
	l_titre_livret = Style.label("VS TOUT AU LIVRET A", 16, Style.capitales(), Style.TEXTE_2)
	v.add_child(l_titre_livret)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 8)
	fleche_ecart = Control.new()
	fleche_ecart.custom_minimum_size = Vector2(22, 30)
	fleche_ecart.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fleche_ecart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fleche_ecart.draw.connect(_dessiner_fleche_ecart)
	ligne.add_child(fleche_ecart)
	l_ecart = Style.label("0 F", 30, Style.chiffres())
	ligne.add_child(l_ecart)
	v.add_child(ligne)
	_styler_pastille(0)


func _styler_pastille(sens: int) -> void:
	var c := _couleur_sens(sens)
	var s := Style.boite(Color(c, 0.14), 14, 14, 2)
	Style.bordure(s, Color(c, 0.85), 2, 2, 2, 2)
	pastille_livret.add_theme_stylebox_override("panel", s)
	l_ecart.add_theme_color_override("font_color", c if sens != 0 else Style.TEXTE)
	fleche_ecart.queue_redraw()


static func _couleur_sens(sens: int) -> Color:
	return Style.GAIN if sens > 0 else (Style.PERTE if sens < 0 else Style.TEXTE_2)


func _dessiner_fleche_ecart() -> void:
	var m := fleche_ecart.size / 2.0
	var c := _couleur_sens(_sens_ecart)
	if _sens_ecart > 0:
		fleche_ecart.draw_colored_polygon(PackedVector2Array([m + Vector2(-10, 7), m + Vector2(10, 7), m + Vector2(0, -10)]), c)
	elif _sens_ecart < 0:
		fleche_ecart.draw_colored_polygon(PackedVector2Array([m + Vector2(-10, -7), m + Vector2(10, -7), m + Vector2(0, 10)]), c)
	else:
		fleche_ecart.draw_rect(Rect2(m + Vector2(-9, -6), Vector2(18, 4)), c)
		fleche_ecart.draw_rect(Rect2(m + Vector2(-9, 3), Vector2(18, 4)), c)


func _on_pastille_livret(event: InputEvent) -> void:
	var b := event as InputEventMouseButton
	if b != null and b.pressed and b.button_index == MOUSE_BUTTON_LEFT:
		comparaison_demandee.emit()


func _dessiner_separateur() -> void:
	var x := separateur.size.x / 2.0
	separateur.draw_line(Vector2(x, 4), Vector2(x, separateur.size.y - 4), Color(1, 1, 1, 0.22), 2.0)


func _bloc(titre: String, taille: int) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", -2)
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var l := Style.label(titre, taille, Style.capitales(), Style.TEXTE_2)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_child(l)
	return v


func _ressort() -> Control:
	var c := Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


## Icône de l'historique (36 px) : une feuille avec trois lignes et des puces aux couleurs des 3 sources.
static func _icone_historique() -> ImageTexture:
	var img := Image.create(36, 36, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := Style.TEXTE
	img.fill_rect(Rect2i(4, 2, 28, 3), c)
	img.fill_rect(Rect2i(4, 31, 28, 3), c)
	img.fill_rect(Rect2i(4, 2, 3, 32), c)
	img.fill_rect(Rect2i(29, 2, 3, 32), c)
	var sources := ["maison", "banque", "media"]
	for k in 3:
		img.fill_rect(Rect2i(10, 9 + k * 8, 4, 4), Style.SOURCES[sources[k]])
		img.fill_rect(Rect2i(16, 10 + k * 8, 10, 2), c)
	return ImageTexture.create_from_image(img)


func _dessiner_menu(b: Button) -> void:
	var m := b.size / 2.0
	for k in 3:
		Dessin.arrondi(b, Rect2(m.x - 16, m.y - 12 + k * 10, 32, 4), Style.TEXTE, 2)


func _creer_bas() -> void:
	bas = PanelContainer.new()
	var s := Style.boite(Style.PANNEAU, 0, 12, 4)
	Style.bordure(s, Color(1, 1, 1, 0.1), 0, 1, 0, 0)
	bas.add_theme_stylebox_override("panel", s)
	bas.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bas.offset_top = -BAS
	bas.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bas)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 12)
	bas.add_child(hb)
	frise = Frise.new()
	frise.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(frise)
	# Historique des pop-ups : accès global, au bout de la frise du temps (la barre haute est pleine)
	b_historique = Button.new()
	b_historique.text = "HISTORIQUE"
	b_historique.custom_minimum_size = Vector2(0, 60)
	b_historique.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b_historique.focus_mode = Control.FOCUS_NONE
	b_historique.icon = _icone_historique()
	b_historique.add_theme_font_size_override("font_size", 18)
	b_historique.add_theme_font_override("font", Style.capitales())
	b_historique.add_theme_constant_override("h_separation", 10)
	var sb := Style.bouton_secondaire()
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	sb.content_margin_left = 14
	sb.content_margin_right = 16
	b_historique.add_theme_stylebox_override("normal", sb)
	b_historique.tooltip_text = "Tout ce qui vous est arrivé : appels, nouvelles, courriers (touche H)"
	b_historique.pressed.connect(func() -> void: historique_demande.emit())
	hb.add_child(b_historique)
	hb.move_child(b_historique, 0)   # à gauche : à droite, le panneau « Mon argent » le couvrirait


func _creer_panneau() -> void:
	panneau = PanelContainer.new()
	panneau.add_theme_stylebox_override("panel", Style.panneau())
	panneau.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panneau)
	conteneur = BoxContainer.new()
	conteneur.add_theme_constant_override("separation", 24)
	panneau.add_child(conteneur)
	var col_a := VBoxContainer.new()
	col_a.add_theme_constant_override("separation", 8)
	col_a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_a.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var col_b := VBoxContainer.new()
	col_b.add_theme_constant_override("separation", 10)
	col_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conteneur.add_child(col_a)
	conteneur.add_child(col_b)
	var tete := HBoxContainer.new()
	tete.add_child(Style.label("MON ARGENT", 20, Style.capitales(), Style.TEXTE_2))
	tete.add_child(_ressort())
	var fermer := Button.new()
	fermer.text = "Replier"
	fermer.custom_minimum_size = Vector2(120, 56)
	fermer.add_theme_font_size_override("font_size", 20)
	fermer.focus_mode = Control.FOCUS_NONE
	fermer.pressed.connect(func() -> void: basculer_panneau(false))
	fermer.name = "Replier"
	tete.add_child(fermer)
	col_a.add_child(tete)
	l_bag = Style.label("", 24, Style.ui(), Style.TEXTE_2)
	col_a.add_child(l_bag)
	courbe = Courbe.new()
	courbe.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col_a.add_child(courbe)
	var legende := HBoxContainer.new()
	legende.add_theme_constant_override("separation", 24)
	legende.add_child(_trait_legende(Style.ACCENT, false))
	legende.add_child(Style.label("Vos choix", 20, Style.ui(), Style.TEXTE))
	legende.add_child(_trait_legende(Courbe.COULEUR_REF, false))
	legende.add_child(Style.label("Tout au Livret A", 20, Style.ui(), Style.TEXTE))
	col_a.add_child(legende)
	l_ecart_note = Style.label("Même salaire, mêmes dépenses, mêmes coups durs : seul le placement change.", 18, Style.ui(), Style.TEXTE_2)
	l_ecart_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l_ecart_note.custom_minimum_size = Vector2(LARGEUR_PANNEAU - 50.0, 0)
	col_a.add_child(l_ecart_note)
	col_a.add_child(Style.label("RÉPARTITION", 20, Style.capitales(), Style.TEXTE_2))
	repart = Repartition.new()
	col_a.add_child(repart)
	col_b.add_child(Style.label("CE MOIS-CI", 20, Style.capitales(), Style.TEXTE_2))
	var grille := GridContainer.new()
	grille.columns = 2
	grille.add_theme_constant_override("h_separation", 16)
	grille.add_theme_constant_override("v_separation", 2)
	l_salaire = _ligne_budget(grille, "Salaire")
	l_depenses = _ligne_budget(grille, "Dépenses")
	l_reste = _ligne_budget(grille, "Reste")
	# Versements automatiques (11 §8, VP11) : ce qui part du reste chaque mois, avant toute autre décision
	l_auto = _ligne_budget(grille, "Dont versements auto")
	col_b.add_child(grille)
	var lc := HBoxContainer.new()
	lc.add_theme_constant_override("separation", 12)
	lc.add_child(Style.label("COUSSIN", 20, Style.capitales(), Style.TEXTE_2))
	jauge = Control.new()
	jauge.custom_minimum_size = Vector2(0, 18)
	jauge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	jauge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	jauge.draw.connect(_dessiner_jauge)
	lc.add_child(jauge)
	l_coussin = Style.label("", 24, Style.chiffres())
	lc.add_child(l_coussin)
	col_b.add_child(lc)
	# Frais payés depuis le début (13 §3.2), en cuivre ; le toucher ouvre le détail
	var lf := HBoxContainer.new()
	lf.mouse_filter = Control.MOUSE_FILTER_STOP
	lf.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	lf.gui_input.connect(_on_frais)
	var tf := Style.label("FRAIS PAYÉS", 20, Style.capitales(), Style.TEXTE_2)
	tf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tf.mouse_filter = Control.MOUSE_FILTER_PASS
	lf.add_child(tf)
	l_frais = Style.label("0 F", 24, Style.chiffres(), Style.CUIVRE)
	l_frais.mouse_filter = Control.MOUSE_FILTER_PASS
	lf.add_child(l_frais)
	lf.name = "LigneFrais"
	col_b.add_child(lf)
	b_marche = Style.bouton("BANQUE  ·  carnet et guichet", true)
	b_marche.pressed.connect(func() -> void: marche_demande.emit())
	col_b.add_child(b_marche)
	languette = Button.new()
	languette.focus_mode = Control.FOCUS_NONE
	languette.add_theme_font_size_override("font_size", 20)
	languette.add_theme_font_override("font", Style.capitales())
	var sl := Style.panneau(16)
	sl.content_margin_left = 6
	sl.content_margin_right = 6
	languette.add_theme_stylebox_override("normal", sl)
	var slh := Style.panneau(16)
	slh.bg_color = Style.PANNEAU_ELEVE
	languette.add_theme_stylebox_override("hover", slh)
	languette.add_theme_stylebox_override("pressed", slh)
	languette.pressed.connect(func() -> void: basculer_panneau(true))
	add_child(languette)


func _trait_legende(c: Color, pointille: bool) -> Control:
	var t := Control.new()
	t.custom_minimum_size = Vector2(30, 24)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.draw.connect(_dessiner_trait.bind(t, c, pointille))
	return t


func _dessiner_trait(t: Control, c: Color, pointille: bool) -> void:
	var y := t.size.y / 2.0
	if pointille:
		t.draw_dashed_line(Vector2(0, y), Vector2(t.size.x, y), c, 2.0, 6.0)
	else:
		t.draw_line(Vector2(0, y), Vector2(t.size.x, y), c, 3.0, true)


func _ligne_budget(grille: GridContainer, titre: String) -> Label:
	var t := Style.label(titre, 24, Style.ui(), Style.TEXTE_2)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grille.add_child(t)
	var v := Style.label("", 24, Style.chiffres())
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	grille.add_child(v)
	return v


func _creer_etiquettes() -> void:
	for id in ["maison", "media", "banque"]:
		var p := PanelContainer.new()
		p.add_theme_stylebox_override("panel", Style.etiquette_batiment())
		p.mouse_filter = Control.MOUSE_FILTER_STOP
		p.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var l := Style.label(NOMS_SOURCES[id], 20, Style.capitales(), Style.TEXTE)
		p.add_child(l)
		p.gui_input.connect(_on_etiquette.bind(id))
		if id == "banque":
			p.draw.connect(_dessiner_point_banque.bind(p))
		add_child(p)
		etiquettes[id] = p


func _dessiner_point_banque(p: PanelContainer) -> void:
	if not _point_banque:
		return
	var c := Vector2(p.size.x - 4, 4)
	p.draw_circle(c, 11, Color(0, 0, 0, 0.5))
	p.draw_circle(c, 9, Style.ALERTE)


func _on_etiquette(event: InputEvent, id: String) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
		batiment_touche.emit(id)


# =====================================================================
# Disposition (PC / téléphone)
# =====================================================================

func _disposer() -> void:
	compact = Ecran.compact()
	boite_baguette.visible = not compact
	# Téléphone : mêmes blocs, libellés courts et chiffres un peu plus petits
	l_titre_cc.text = "COMPTE" if compact else "COMPTE COURANT"
	l_cc.add_theme_font_size_override("font_size", 28 if compact else 32)
	l_patr.add_theme_font_size_override("font_size", 38 if compact else 44)
	l_var.visible = not compact
	separateur.custom_minimum_size = Vector2(40 if compact else 56, 60)
	l_titre_livret.text = "VS LIVRET A" if compact else "VS TOUT AU LIVRET A"
	l_ecart.add_theme_font_size_override("font_size", 26 if compact else 30)
	l_ecart_note.visible = not compact
	for g in ["pause", "x1", "x2", "x3"]:
		boutons[g].visible = not compact
	b_lecture.visible = compact
	b_cycle.visible = compact
	conteneur.vertical = not compact
	courbe.compacte = compact
	courbe.custom_minimum_size = Vector2(0, 110 if compact else 190)
	_trouver_replier().visible = compact
	panneau_ouvert = not compact
	_placer_panneau()


func _trouver_replier() -> Button:
	return panneau.find_child("Replier", true, false) as Button


func basculer_panneau(ouvrir: bool) -> void:
	panneau_ouvert = ouvrir
	_placer_panneau()
	if ouvrir and compact and not Juice.animations_reduites:
		panneau.pivot_offset = Vector2(panneau.size.x, panneau.size.y / 2.0)
		panneau.scale = Vector2(0.6, 0.6)
		panneau.modulate.a = 0.0
		var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(panneau, "scale", Vector2.ONE, 0.3)
		t.tween_property(panneau, "modulate:a", 1.0, 0.3)


func _placer_panneau() -> void:
	var largeur := LARGEUR_PANNEAU_COMPACT if compact else LARGEUR_PANNEAU
	panneau.anchor_left = 1.0
	panneau.anchor_right = 1.0
	panneau.anchor_top = 0.0
	panneau.anchor_bottom = 1.0
	panneau.offset_left = -largeur - 12.0
	panneau.offset_right = -12.0
	panneau.offset_top = HAUT + 12.0
	panneau.offset_bottom = -BAS - 12.0
	panneau.visible = panneau_ouvert
	languette.visible = compact and not panneau_ouvert
	languette.anchor_left = 1.0
	languette.anchor_right = 1.0
	languette.anchor_top = 0.0
	languette.anchor_bottom = 1.0
	languette.offset_left = -LARGEUR_LANGUETTE - 8.0
	languette.offset_right = -8.0
	languette.offset_top = HAUT + 12.0
	languette.offset_bottom = -BAS - 12.0
	disposition_changee.emit()


## Rectangle de l'écran laissé libre pour la ville (le panneau replié ne compte pas).
func rect_libre() -> Rect2:
	var t := get_viewport_rect().size
	var droite := LARGEUR_LANGUETTE + 16.0 if compact else LARGEUR_PANNEAU + 24.0
	return Rect2(0, HAUT, t.x - droite, t.y - HAUT - BAS)


# =====================================================================
# Mise à jour
# =====================================================================

func maj(e: EtatPartie, anime := true, duree_roule := 0.6) -> void:
	var a := e.ab_courant()
	var fmt := func(v: float) -> String: return Format.montant(v, a)
	date.regler(a, anime)
	var cc := e.joueur.cc
	var patr := e.patrimoine(e.joueur)
	var d := duree_roule if anime else 0.0
	Juice.rouler(l_cc, _cc_affiche, cc, fmt, d, Style.GAIN if cc > _cc_affiche else Style.PERTE)
	Juice.rouler(l_patr, _patr_affiche, patr, fmt, d)
	l_cc.add_theme_color_override("font_color", Style.PERTE if cc < 0.0 else Style.TEXTE)
	_cc_affiche = cc
	_patr_affiche = patr
	# Écart avec « tout au Livret A » (même vie, tout sur compte + Livret A : témoin Tata Livret)
	var ecart := e.ecart_livret()
	var sens := 0
	if Format.en_devise(ecart, Format.devise(a)) >= 0.5:
		sens = 1
	elif Format.en_devise(ecart, Format.devise(a)) <= -0.5:
		sens = -1
	Juice.rouler(l_ecart, _ecart_affiche, ecart, func(v: float) -> String: return Format.ecart(v, a), d)
	_ecart_affiche = ecart
	if sens != _sens_ecart:
		_sens_ecart = sens
		_styler_pastille(sens)
		if anime:
			Juice.pop(pastille_livret)
	l_baguette.text = Format.montant(Marche.baguette(a), a, true)
	# Variation sur 12 mois (ou depuis le début de la tranche)
	var m0 := maxi(e.m_depart, e.m - 12)
	var ref: float = e.hist["j"][m0]
	if e.m > e.m_depart and ref > 0.0:
		var v := patr / ref - 1.0
		l_var.text = ("▲ " if v >= 0.0 else "▼ ") + Format.pct(v, 0)
		l_var.add_theme_color_override("font_color", Style.GAIN if v >= 0.0 else Style.PERTE)
	else:
		l_var.text = ""
	l_bag.text = "= %s baguettes" % Format.nombre(patr / Marche.baguette(a), 0)
	# Courbe
	var vals: Array = e.hist["j"].slice(e.m_depart, e.m + 1)
	# Courrier en attente : compté comme réglé (les témoins ont déjà payé), comme l'indicateur d'écart
	if not vals.is_empty():
		vals[vals.size() - 1] = float(vals[vals.size() - 1]) + e.vie_en_attente()
	var mis: Array = e.hist["mis"].slice(e.m_depart, e.m + 1)
	var tata: Array = e.hist["livret"].slice(e.m_depart, e.m + 1)
	courbe.total_mois = e.m_fin - e.m_depart
	courbe.ecart_impose = ecart   # même valeur que la pastille (bug de l'étiquette en bout de courbe)
	courbe.regler(vals, mis, e.ab_de(e.m_depart), minf(0.6, 0.4 * _duree_mois()) if anime else 0.0, tata)
	courbe.couleur = Style.ACCENT
	# Répartition
	var actions := 0.0
	var sicav := 0.0
	for id in e.joueur.lignes:
		if e.produit(id).get("type", "") == "action":
			actions += e.valeur_ligne(e.joueur, id)
		else:
			sicav += e.valeur_ligne(e.joueur, id)
	repart.regler({"cc": maxf(0.0, cc), "livret": e.joueur.livret, "pel": e.joueur.valeur_pel(), "emprunt": e.joueur.valeur_emprunts(),
		"av": e.joueur.valeur_av(), "sicav": sicav, "action": actions}, anime)
	# Frais payés depuis le début
	var frais := e.frais_payes()
	Juice.rouler(l_frais, _frais_affiches, frais, func(x: float) -> String: return Format.entier(x, a), d, Style.CUIVRE)
	_frais_affiches = frais
	# Budget et coussin
	var dep: Dictionary = e.depenses()
	l_salaire.text = Format.montant(e.salaire_base, a, false, true)
	l_depenses.text = Format.MOINS + Format.montant(float(dep["total"]), a)
	l_reste.text = Format.montant(e.epargne_du_mois(), a, false, true)
	l_reste.add_theme_color_override("font_color", Style.GAIN if e.epargne_du_mois() >= 0.0 else Style.PERTE)
	var auto := Versements.total_mensuel(e) if e.banquier_actif() else 0.0
	l_auto.text = Format.MOINS + Format.entier(auto, a)
	l_auto.add_theme_color_override("font_color", Style.GEL)
	l_auto.visible = auto > 0.005
	var titre_auto := l_auto.get_parent().get_child(l_auto.get_index() - 1) as Label
	titre_auto.visible = l_auto.visible
	_coussin = (maxf(0.0, cc) + e.joueur.livret) / float(dep["total"])
	l_coussin.text = Format.nombre(_coussin, 1) + " mois"
	jauge.queue_redraw()
	languette.text = "MON\nARGENT\n\n%s k\n%s" % [Format.nombre(Format.en_devise(patr, Format.devise(a)) / 1000.0, 0), Format.devise(a)]
	# Frise
	frise.m_debut = e.m_depart
	frise.m_fin = e.m_fin
	frise.ab_debut = e.mk.ab_debut
	var mq := []
	for ev in e.per.get("evenements", []):
		var mm := Dates.lire(ev["d"]) - e.mk.ab_debut
		mq.append({"m": mm, "type": "marche", "passe": mm <= e.m})
	for pr in e.per["produits"]:
		if pr.has("dispo") and e.per.get("achetables", []).has(pr["id"]):
			var mp := Dates.lire(pr["dispo"]) - e.mk.ab_debut
			if mp >= e.m_depart and mp <= e.m_fin:
				mq.append({"m": mp, "type": "nouveau", "passe": mp <= e.m})
	frise.marqueurs = mq


func _duree_mois() -> float:
	return Partie.duree_mois_s()


func maj_vitesse(v: int) -> void:
	for i in 4:
		var g: String = ["pause", "x1", "x2", "x3"][i]
		boutons[g].set_pressed_no_signal(i == v)
		boutons[g].queue_redraw()
	if v > 0:
		b_cycle.vitesse_cycle = v
	b_lecture.queue_redraw()
	b_cycle.queue_redraw()
	badge_pause.visible = v == 0
	var t := create_tween()
	t.tween_property(self, "_gel", 1.0 if v == 0 else 0.0, 0.3)
	t.parallel().tween_method(func(_x: float) -> void: cadre_gel.queue_redraw(), 0.0, 1.0, 0.3)


func _process(_delta: float) -> void:
	frise.position_mois = (Partie.etat.m + Partie.progression_mois()) if Partie.etat != null else 0.0
	if ville != null:
		for id in etiquettes:
			var p: PanelContainer = etiquettes[id]
			var b: Batiment = ville.call("batiment", id)
			var ecran: Vector2 = ville.call("position_ecran", b.position + Vector2(0, 56))
			p.position = ecran - Vector2(p.size.x / 2.0, 0)
	badge_pause.modulate.a = 0.75 + 0.25 * sin(Time.get_ticks_msec() / 300.0)


func _dessiner_gel() -> void:
	if _gel <= 0.01:
		return
	var r := Rect2(Vector2.ZERO, cadre_gel.size).grow(-3)
	cadre_gel.draw_rect(r, Color(Style.GEL, 0.55 * _gel), false, 6.0)
	cadre_gel.draw_rect(r.grow(-6), Color(Style.GEL, 0.15 * _gel), false, 6.0)


func _dessiner_jauge() -> void:
	var r := Rect2(Vector2.ZERO, jauge.size)
	Dessin.arrondi(jauge, r, Style.FILET, 9)
	var k := clampf(_coussin / 6.0, 0.0, 1.0)
	var c := Style.GAIN if _coussin >= 3.0 else Style.ALERTE
	if k > 0.0:
		Dessin.arrondi(jauge, Rect2(r.position, Vector2(maxf(18.0, r.size.x * k), r.size.y)), c, 9)
	var x3 := r.size.x * 0.5
	jauge.draw_rect(Rect2(x3 - 1, -4, 2, r.size.y + 8), Style.TEXTE)


# =====================================================================
# Notifications (3 au maximum, empilées en haut à gauche)
# =====================================================================

## depart : position d'écran d'où la notification s'envole (bâtiment source), ou (-1, -1).
func notifier(n: Dictionary, a: int, depart := Vector2(-1, -1)) -> void:
	var source: String = n.get("source", "banque")
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.boite_notification(source))
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.custom_minimum_size = Vector2(520 if not compact else 500, 0)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	p.add_child(h)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var src := Style.label(NOMS_SOURCES.get(source, "") + " · " + Dates.texte(a), 20, Style.capitales(), Style.SOURCES.get(source, Style.ACCENT))
	v.add_child(src)
	v.add_child(Style.label(str(n.get("titre", "")), 24, Style.ui_gras()))
	var texte := Style.label(str(n.get("texte", "")), 20, Style.ui(), Style.TEXTE_2)
	texte.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texte.custom_minimum_size = Vector2(320, 0)
	v.add_child(texte)
	h.add_child(v)
	if n.has("montant"):
		var mt := float(n["montant"])
		var l := Style.label(Format.montant(mt, a, false, true), 26, Style.chiffres(), Style.GAIN if mt >= 0.0 else Style.PERTE)
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(l)
	var persistant: bool = n.get("persistant", false)
	if persistant:
		v.add_child(Style.label("Message de M. Lefranc · touchez pour le fermer (rangé dans l'historique)", 16, Style.ui(), Style.SOURCES["banque"]))
	elif n.get("type", "") == "releve" and float(n.get("frais_total", 0.0)) > 0.0:
		v.add_child(Style.label("Touchez pour voir le détail des frais", 16, Style.ui(), Style.CUIVRE))
	notifs.add_child(p)
	_liste_notifs.push_front(p)
	while _liste_notifs.size() > 3:
		var vieille: Control = _liste_notifs.pop_back()
		vieille.queue_free()
	p.gui_input.connect(_clic_notif.bind(p, n))
	await get_tree().process_frame
	if not is_instance_valid(p):
		return
	_empiler(p, depart)
	if persistant:
		point_banque(true)
		return
	# Une notification ordinaire reste un mois à ×1 (13 §5.2), moins en accéléré
	var vie := clampf(Partie.duree_mois_s(maxi(1, Partie.vitesse)), 3.0, 8.0)
	await get_tree().create_timer(vie + 0.4).timeout
	_retirer(p)


func _clic_notif(ev: InputEvent, p: Control, n: Dictionary) -> void:
	var b := ev as InputEventMouseButton
	if b != null and b.pressed and b.button_index == MOUSE_BUTTON_LEFT:
		_retirer(p)
		notif_touchee.emit(n)


func _on_frais(ev: InputEvent) -> void:
	var b := ev as InputEventMouseButton
	if b != null and b.pressed and b.button_index == MOUSE_BUTTON_LEFT:
		frais_demandes.emit()


## Point de notification sur l'étiquette « MA BANQUE » (13 §1.5) : jusqu'à la prochaine ouverture du carnet.
func point_banque(oui: bool) -> void:
	_point_banque = oui
	var et: PanelContainer = etiquettes.get("banque")
	if et != null:
		et.queue_redraw()


func _empiler(nouvelle: Control, depart: Vector2) -> void:
	var y := 0.0
	for c: Control in _liste_notifs:
		if not is_instance_valid(c):
			continue
		var cible := Vector2(0, y)
		if c == nouvelle:
			if depart.x >= 0.0 and not Juice.animations_reduites:
				c.position = depart - notifs.position - c.size * 0.25
				c.scale = Vector2(0.5, 0.5)
				var t := c.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				t.tween_property(c, "position", cible, 0.4)
				t.tween_property(c, "scale", Vector2.ONE, 0.4)
			else:
				c.position = cible + Vector2(-40, 0)
				c.modulate.a = 0.0
				var t2 := c.create_tween().set_parallel(true)
				t2.tween_property(c, "position", cible, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				t2.tween_property(c, "modulate:a", 1.0, 0.2)
		else:
			c.create_tween().tween_property(c, "position", cible, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		y += c.size.y + 10.0


func _retirer(p: Control) -> void:
	if not is_instance_valid(p) or not _liste_notifs.has(p):
		return
	_liste_notifs.erase(p)
	var t := p.create_tween()
	t.tween_property(p, "modulate:a", 0.0, 0.25)
	t.tween_callback(p.queue_free)
	_empiler(null, Vector2(-1, -1))


## Montrer ou cacher le HUD (écran titre), avec glissement depuis les bords (0,3 s en décalé).
func afficher(oui: bool, anime := true) -> void:
	visible = true
	var elements := [[barre, Vector2(0, -HAUT - 30)], [bas, Vector2(0, BAS + 30)], [panneau, Vector2(560, 0)], [languette, Vector2(140, 0)]]
	var i := 0
	for el in elements:
		var c: Control = el[0]
		var dec: Vector2 = el[1]
		if not anime:
			c.modulate.a = 1.0 if oui else 0.0
			continue
		var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT if oui else Tween.EASE_IN)
		var base := c.position
		if oui:
			c.position = base + dec
			c.modulate.a = 0.0
			t.tween_property(c, "position", base, 0.3).set_delay(0.08 * i)
			t.tween_property(c, "modulate:a", 1.0, 0.2).set_delay(0.08 * i)
		else:
			t.tween_property(c, "modulate:a", 0.0, 0.2)
		i += 1
	for id in etiquettes:
		etiquettes[id].modulate.a = 1.0 if oui else 0.0
	cadre_gel.visible = oui
	notifs.visible = oui
