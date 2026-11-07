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
signal courrier_demande          # bouton COURRIER (lot 02) : lancer ou arrêter le saut « jusqu'au prochain courrier »

const HAUT := 102.0             # 34 texels : boutons de 84 px (28 texels) et marges du cadre
const BAS := 96.0               # 32 texels (lot_px2 §9.1) : bouton HISTORIQUE de 90 px à l'intérieur
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
# Bouton COURRIER (lot 02, D1-D3) et badge des non-lus (D5)
var filet_courrier: Control
var b_courrier: Button
var _contenu_courrier: BoxContainer
var _icone_courrier: TextureRect
var _l_courrier: Label
var _etat_courrier := "cache"
var _image_saut := -1                 # image du saut affichée (fond × 2 + chevrons)
var _debloque_e: EtatPartie = null    # partie pour laquelle le déblocage a été calculé
var _debloque_n := -1                 # taille de l'historique au dernier calcul
var _debloque := false
var _bulle: Control = null
var _bulle_faite := false
var badge_non_lus: Control
var _n_non_lus := 0
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
	if ville != null and ville.has_signal("camera_bougee"):
		ville.connect("camera_bougee", placer_etiquettes)
	# A6 (recette PX1) : aucun bouton du HUD ne prend le focus, sinon les flèches ← → (défilement de la rue)
	# serviraient à la navigation entre boutons au lieu d'atteindre la ville. Le HUD se pilote au toucher,
	# à la souris et par ses raccourcis (Espace, P, 1-3, M/B, H).
	for n in find_children("*", "BaseButton", true, false):
		(n as BaseButton).focus_mode = Control.FOCUS_NONE
		if n is Button:
			Style.garder_police(n as Button)
	_disposer()


# =====================================================================
# Construction
# =====================================================================

func _creer_barre() -> void:
	barre = PanelContainer.new()
	barre.name = "BarreHaute"
	barre.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	barre.add_theme_stylebox_override("panel", CadresPixel.style_marges("panneau", 15, 6, 15, 12))
	barre.self_modulate = Color(1, 1, 1, 0.97)
	barre.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	barre.offset_bottom = HAUT
	add_child(barre)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 15)
	barre.add_child(h)
	date = DateVolets.new()
	date.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	date.triple_touche.connect(func() -> void: raccourci_demo.emit())
	h.add_child(date)
	# Lot 02 (D1) : le bloc BAGUETTE a quitté la barre (prix dans « Mon foyer », « = N baguettes » dans « Mon argent »)
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
	# Bouton COURRIER (lot 02, D1) : contrôle du temps, à droite des vitesses après un filet vertical d'1 texel
	filet_courrier = Control.new()
	filet_courrier.custom_minimum_size = Vector2(9, 66)
	filet_courrier.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	filet_courrier.mouse_filter = Control.MOUSE_FILTER_IGNORE
	filet_courrier.draw.connect(func() -> void: filet_courrier.draw_rect(Rect2(3, 0, 3, filet_courrier.size.y), Style.PANNEAU_SURVOL))
	h.add_child(filet_courrier)
	_creer_courrier()
	h.add_child(b_courrier)
	badge_pause = Style.label("EN PAUSE", 28, Style.neon(), Style.GEL)
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
	carte_cc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	carte_cc.add_theme_stylebox_override("panel", CadresPixel.style_marges("plaquette", 15, 3, 15, 3))
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
	menu.name = "Menu"
	menu.custom_minimum_size = Vector2(84, 84)
	menu.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	menu.focus_mode = Control.FOCUS_NONE
	CadresPixel.habiller_bouton(menu, "secondaire", "menu")
	menu.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu.pressed.connect(func() -> void: menu_demande.emit())
	h.add_child(menu)


## Pastille permanente « VS TOUT AU LIVRET A » : flèche (▲ devant, ▼ derrière, = à égalité), montant
## signé et couleur : trois indices, pas seulement le rouge et le vert. Un toucher l'explique.
func _creer_pastille_livret() -> void:
	pastille_livret = PanelContainer.new()
	pastille_livret.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pastille_livret.mouse_filter = Control.MOUSE_FILTER_STOP
	pastille_livret.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pastille_livret.custom_minimum_size = Vector2(0, 78)
	pastille_livret.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
	pastille_livret.add_theme_stylebox_override("panel", Style.pastille(c if sens != 0 else Style.PANNEAU_SURVOL, 0, 3))
	l_ecart.add_theme_color_override("font_color", c if sens != 0 else Style.TEXTE)
	fleche_ecart.queue_redraw()


static func _couleur_sens(sens: int) -> Color:
	return Style.GAIN if sens > 0 else (Style.PERTE if sens < 0 else Style.TEXTE_2)


## Flèche pixel 8 × 8 (▲ gain, ▼ perte) ou signe « = » en blocs de 3 px.
func _dessiner_fleche_ecart() -> void:
	var m := (fleche_ecart.size / 2.0 / 3.0).floor() * 3.0
	var c := _couleur_sens(_sens_ecart)
	if _sens_ecart != 0:
		var tex := CadresPixel.texture("fleche_haut" if _sens_ecart > 0 else "fleche_bas")
		fleche_ecart.draw_texture(tex, m - tex.get_size() / 2.0)
	else:
		fleche_ecart.draw_rect(Rect2(m + Vector2(-9, -6), Vector2(18, 3)), c)
		fleche_ecart.draw_rect(Rect2(m + Vector2(-9, 3), Vector2(18, 3)), c)


func _on_pastille_livret(event: InputEvent) -> void:
	var b := event as InputEventMouseButton
	if b != null and b.pressed and b.button_index == MOUSE_BUTTON_LEFT:
		comparaison_demandee.emit()


func _dessiner_separateur() -> void:
	var x := floorf(separateur.size.x / 6.0) * 3.0
	separateur.draw_rect(Rect2(x, 6, 3, separateur.size.y - 12), Style.PANNEAU_SURVOL)


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


# =====================================================================
# Bouton COURRIER (lot 02, docs/17 §1) : « jusqu'au prochain appel, courrier ou journal »
# =====================================================================

## Bouton secondaire de la barre ; son contenu (icône 16 × 16 et libellé) est posé par-dessus, en ligne sur PC,
## en colonne sur téléphone (libellé Atkinson gras 20 sous l'icône) ; il descend d'1 texel à l'appui.
func _creer_courrier() -> void:
	b_courrier = Button.new()
	b_courrier.name = "Courrier"
	b_courrier.focus_mode = Control.FOCUS_NONE
	b_courrier.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b_courrier.tooltip_text = "Avancer jusqu'au prochain appel, courrier ou journal (N)"
	b_courrier.visible = false
	CadresPixel.habiller_bouton(b_courrier, "secondaire")
	b_courrier.pressed.connect(func() -> void: courrier_demande.emit())
	_contenu_courrier = BoxContainer.new()
	_contenu_courrier.name = "Contenu"
	_contenu_courrier.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_contenu_courrier.alignment = BoxContainer.ALIGNMENT_CENTER
	b_courrier.add_child(_contenu_courrier)
	_icone_courrier = CadresPixel.icone("courrier")
	_icone_courrier.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_icone_courrier.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_contenu_courrier.add_child(_icone_courrier)
	_l_courrier = Style.label("COURRIER", 28, Style.capitales())
	_l_courrier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_l_courrier.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_contenu_courrier.add_child(_l_courrier)
	b_courrier.button_down.connect(_poser_contenu_courrier.bind(true))
	b_courrier.button_up.connect(_poser_contenu_courrier.bind(false))


## Libellé, disposition et taille du bouton selon le format (appelé par _disposer et les replis de la barre).
func _disposer_courrier(avec_libelle: bool) -> void:
	_contenu_courrier.vertical = compact
	_contenu_courrier.add_theme_constant_override("separation", -9 if compact else 9)
	var police := Style.ui_gras() if compact else Style.capitales()
	_l_courrier.add_theme_font_override("font", police)
	_l_courrier.add_theme_font_size_override("font_size", 20 if compact else 28)
	_l_courrier.visible = avec_libelle
	var lib := _l_courrier.get_minimum_size() if avec_libelle else Vector2.ZERO
	var largeur := 84.0
	if avec_libelle:
		largeur = (maxf(48.0, lib.x) + 30.0) if compact else (48.0 + 9.0 + lib.x + 33.0)
	b_courrier.custom_minimum_size = Vector2(maxf(largeur, Style.cible_min()), maxf(84.0, Style.cible_min()))
	_poser_contenu_courrier(false)


## Contenu dans la face du bouton (marges du cadre 9-patch) ; enfoncé : 1 texel plus bas.
func _poser_contenu_courrier(enfonce: bool) -> void:
	var haut := 3.0 if compact and _l_courrier.visible else 6.0
	_contenu_courrier.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_contenu_courrier.offset_left = 12.0
	_contenu_courrier.offset_right = -12.0
	_contenu_courrier.offset_top = haut + (3.0 if enfonce else 0.0)
	_contenu_courrier.offset_bottom = -18.0 + (3.0 if enfonce else 0.0)


## État du bouton COURRIER (D2) pour la partie e ; occupe : écran titre, fenêtre ou modale ouverte, séquence.
## Caché tant qu'aucune modale n'a été résolue (une entrée d'historique appel, journal ou courrier existe) ;
## saut en cours ; inactif si le saut est impossible (Partie.saut_possible : modale en attente, temps bloqué,
## décembre 1988) ; repos sinon.
func etat_courrier_pour(e: EtatPartie, occupe: bool) -> String:
	if e == null:
		return "cache"
	if e != _debloque_e or e.historique.size() != _debloque_n:
		if e != _debloque_e:
			_debloque = false
		_debloque_e = e
		_debloque_n = e.historique.size()
		if not _debloque:
			for h: Dictionary in e.historique:
				if str(h.get("genre", "")) in ["appel", "journal", "courrier"]:
					_debloque = true
					break
	if not _debloque:
		return "cache"
	if Partie.saut_actif:
		return "saut"
	if occupe or not Partie.saut_possible():
		return "inactif"
	return "repos"


func etat_courrier() -> String:
	return _etat_courrier


## Applique l'état du bouton : "cache", "repos", "saut" (fond ambre qui pulse, chevrons qui avancent),
## "inactif" (icône et libellé à 40 %, aucun effet au toucher). Première apparition en jeu : glissement 0,3 s.
func maj_courrier(etat: String) -> void:
	if etat == _etat_courrier:
		return
	var apparait := _etat_courrier == "cache" and etat != "cache"
	_etat_courrier = etat
	b_courrier.visible = etat != "cache"
	filet_courrier.visible = b_courrier.visible
	b_courrier.disabled = etat == "inactif"
	b_courrier.mouse_default_cursor_shape = Control.CURSOR_ARROW if etat == "inactif" else Control.CURSOR_POINTING_HAND
	_contenu_courrier.modulate.a = 0.4 if etat == "inactif" else 1.0
	_image_saut = -1
	if etat != "saut":
		CadresPixel.habiller_bouton(b_courrier, "secondaire")
		_icone_courrier.texture = CadresPixel.texture("courrier")
		_l_courrier.add_theme_color_override("font_color", Style.TEXTE)
	else:
		_animer_saut()
	if apparait and is_visible_in_tree() and not Juice.animations_reduites:
		_contenu_courrier.position.x += 60.0
		b_courrier.modulate.a = 0.0
		var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(b_courrier, "modulate:a", 1.0, 0.3)
		t.tween_property(_contenu_courrier, "position:x", _contenu_courrier.position.x - 60.0, 0.3)
	_replier_barre.call_deferred()


## Saut actif : 2 images de fond (ambre, lumière) à 2 im/s et 2 images de chevrons à 4 im/s, sans alpha.
func _animer_saut() -> void:
	var ms := Time.get_ticks_msec()
	var image := (int(ms / 500) % 2) * 2 + int(ms / 250) % 2
	if image == _image_saut:
		return
	var fond_change := _image_saut < 0 or (image / 2) != (_image_saut / 2)
	_image_saut = image
	if fond_change:
		var remplacer := {"ambre": "lumiere"} if image >= 2 else {}
		for etat: String in ["normal", "hover", "disabled"]:
			b_courrier.add_theme_stylebox_override(etat, CadresPixel.style("bouton_principal", remplacer))
		for etat: String in ["pressed", "hover_pressed"]:
			b_courrier.add_theme_stylebox_override(etat, CadresPixel.style("bouton_principal_enfonce", remplacer))
		_l_courrier.add_theme_color_override("font_color", Style.ENCRE_ACCENT)
	_icone_courrier.texture = CadresPixel.texture("courrier_b" if image % 2 == 1 else "courrier", CadresPixel.ECHELLE, {"blanc_chaud": "nuit"})


## Bulle unique de la première apparition (D3), non bloquante : [COMPRIS] ou le premier appui sur COURRIER.
func montrer_bulle_courrier() -> void:
	if _bulle != null or not b_courrier.is_visible_in_tree():
		return
	_bulle_faite = true
	var p := PanelContainer.new()
	p.name = "BulleCourrier"
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.add_theme_stylebox_override("panel", Style.papier("banque", 24.0, 18.0))
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	p.add_child(v)
	var l := Style.label("Rien à faire ce mois-ci ? COURRIER fait filer le temps jusqu'au prochain appel, courrier ou journal.", 22, Style.ui(), Style.ENCRE)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(minf(480.0, rect_libre().size.x - 120.0), 0)
	v.add_child(l)
	var ok := Style.bouton("COMPRIS")
	ok.theme_type_variation = "BoutonPapier"
	ok.focus_mode = Control.FOCUS_NONE
	ok.size_flags_horizontal = Control.SIZE_SHRINK_END
	ok.pressed.connect(fermer_bulle_courrier)
	v.add_child(ok)
	var pointe := Control.new()
	pointe.name = "Pointe"
	pointe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pointe.draw.connect(_dessiner_pointe.bind(pointe))
	p.add_child(pointe)
	add_child(p)
	_bulle = p
	_placer_bulle.call_deferred()


func _placer_bulle() -> void:
	if _bulle == null or not is_instance_valid(_bulle):
		return
	_bulle.reset_size()
	var r := b_courrier.get_global_rect()
	var libre := rect_libre()
	var x := clampf(r.get_center().x - 90.0, libre.position.x + 12.0, libre.end.x - _bulle.size.x - 12.0)
	_bulle.position = Vector2(roundf(x / 3.0) * 3.0, roundf((HAUT + 27.0) / 3.0) * 3.0)
	var pointe := _bulle.get_node("Pointe") as Control
	pointe.set_meta("x", roundf((r.get_center().x - _bulle.position.x) / 3.0) * 3.0)
	pointe.queue_redraw()


## Pointe en escalier (encre puis crème) au-dessus de la bulle, vers le bouton.
func _dessiner_pointe(pointe: Control) -> void:
	var x: float = pointe.get_meta("x", 90.0) - pointe.position.x
	for k in 4:
		var w := 6.0 + 6.0 * k
		pointe.draw_rect(Rect2(x - w / 2.0 - 3.0, -15.0 + 3.0 * k, w + 6.0, 3.0), Style.ENCRE)
		pointe.draw_rect(Rect2(x - w / 2.0, -12.0 + 3.0 * k, w, 3.0), Style.JOURNAL)


## Ferme la bulle (COMPRIS, appui sur COURRIER ou N) ; elle ne revient plus (préférence locale, D3).
func fermer_bulle_courrier() -> void:
	if _bulle == null:
		return
	if is_instance_valid(_bulle):
		_bulle.queue_free()
	_bulle = null
	Reglages.marquer_bulle_vue("courrier")


## La bulle s'affiche au premier passage au repos du bouton dans la partie, si le joueur ne l'a jamais vue.
func _verifier_bulle() -> void:
	if _bulle_faite or _etat_courrier != "repos" or not is_visible_in_tree():
		return
	_bulle_faite = true
	if Reglages.bulle_a_montrer("courrier"):
		montrer_bulle_courrier()


## Replis de la barre quand elle manque de largeur (D1) : d'abord la variation du patrimoine, puis le libellé
## du bouton COURRIER (icône seule, 84 × 84). Jamais le bouton lui-même.
func _replier_barre() -> void:
	if barre == null:
		return
	var h := barre.get_child(0) as HBoxContainer
	var dispo := Ecran.taille().x - 30.0
	var long := not compact and Ecran.taille().x >= 1900.0
	l_titre_cc.text = "COMPTE COURANT" if long else "COMPTE"
	l_titre_livret.text = "VS TOUT AU LIVRET A" if long else "VS LIVRET A"
	l_var.visible = not compact
	var replie := compact and Ecran.taille().x < 1400.0
	badge_pause.set_meta("replie", replie)
	badge_pause.visible = not replie   # mesuré visible (pire cas), réglé selon la vitesse à la fin
	_disposer_courrier(true)
	# Avant les replis de D1, le titre court « COMPTE » (repli existant des fenêtres étroites)
	if h.get_combined_minimum_size().x > dispo:
		l_titre_cc.text = "COMPTE"
	if h.get_combined_minimum_size().x > dispo:
		l_var.visible = false
	# Téléphone : le badge « EN PAUSE » se replie avant le libellé (le bouton lecture et le cadre de gel le disent)
	if compact and h.get_combined_minimum_size().x > dispo:
		badge_pause.set_meta("replie", true)
		badge_pause.visible = false
	if h.get_combined_minimum_size().x > dispo:
		_disposer_courrier(false)
	if h.get_combined_minimum_size().x > dispo:
		l_titre_livret.text = "VS LIVRET A"
	badge_pause.visible = (Partie.vitesse == 0 or Partie.saut_actif) and not badge_pause.get_meta("replie", false)


# =====================================================================
# Badge des non-lus sur HISTORIQUE (lot 02, D5, docs/17 §2.2)
# =====================================================================

## Nombre affiché (0 : badge absent ; au-delà de 9 : « 9+ »).
func maj_badge(n: int) -> void:
	_n_non_lus = maxi(0, n)
	badge_non_lus.visible = _n_non_lus > 0
	badge_non_lus.set_meta("texte", texte_badge(_n_non_lus))
	badge_non_lus.queue_redraw()


static func texte_badge(n: int) -> String:
	return "9+" if n > 9 else str(n)


func texte_badge_affiche() -> String:
	return str(badge_non_lus.get_meta("texte", "")) if badge_non_lus.visible else ""


## Le badge saute d'1 texel (2 images, 0,12 s) : arrivée d'une fiche non lue.
func sauter_badge() -> void:
	var y0 := float(badge_non_lus.get_meta("y0", badge_non_lus.position.y))
	badge_non_lus.set_meta("y0", y0)
	badge_non_lus.position.y = y0 - 3.0
	var t := create_tween()
	t.tween_interval(0.12)
	t.tween_callback(func() -> void: badge_non_lus.position.y = y0)


## Pastille ambre en escalier, contour encre d'1 texel, chiffre Atkinson gras encre (badge, onglets du classeur).
static func dessiner_pastille(c: Control, texte: String, taille_police := 22) -> void:
	var r := Rect2(Vector2.ZERO, (c.size / 3.0).floor() * 3.0)
	var encre := Style.ENCRE
	c.draw_rect(Rect2(r.position.x + 3, r.position.y, r.size.x - 6, r.size.y), encre)
	c.draw_rect(Rect2(r.position.x, r.position.y + 3, r.size.x, r.size.y - 6), encre)
	c.draw_rect(Rect2(r.position.x + 6, r.position.y + 3, r.size.x - 12, r.size.y - 6), Style.ACCENT)
	c.draw_rect(Rect2(r.position.x + 3, r.position.y + 6, r.size.x - 6, r.size.y - 12), Style.ACCENT)
	var police := Style.ui_gras()
	var w := police.get_string_size(texte, HORIZONTAL_ALIGNMENT_LEFT, -1, taille_police)
	var base := (r.size.y + police.get_ascent(taille_police) - police.get_descent(taille_police)) / 2.0
	c.draw_string(police, Vector2(roundf((r.size.x - w.x) / 2.0), roundf(base)), texte, HORIZONTAL_ALIGNMENT_LEFT, -1, taille_police, encre)


## Étiquette (ou flèche de bord) d'un bâtiment qui saute d'1 texel (3 px) puis revient : 2 images, 0,12 s
## (§3.3 : appelé par Sequences.pieces_du_mois quand une pièce passe par la flèche de bord).
func sauter_etiquette(id: String) -> void:
	var p: Control = etiquettes.get(id)
	if p == null:
		return
	var y0 := p.position.y
	p.position.y = y0 - 3.0
	var t := p.create_tween()
	t.tween_interval(0.12)
	t.tween_callback(_retour_etiquette.bind(p, y0))


func _retour_etiquette(p: Control, y0: float) -> void:
	if is_instance_valid(p) and p.position.y == y0 - 3.0:
		p.position.y = y0


func _creer_bas() -> void:
	bas = PanelContainer.new()
	bas.name = "Frise"
	bas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bas.add_theme_stylebox_override("panel", CadresPixel.style_marges("panneau", 12, 3, 24, 3))
	bas.self_modulate = Color(1, 1, 1, 0.97)
	bas.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bas.offset_top = -BAS
	bas.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bas)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 24)
	bas.add_child(hb)
	frise = Frise.new()
	frise.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frise.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(frise)
	# Historique des pop-ups : accès global, au début de la frise du temps (la barre haute est pleine) ;
	# bouton agrandi (PX2 §2.3) : icône de classeur + libellé, 96 px de haut, au moins 222 de large.
	b_historique = Button.new()
	b_historique.name = "Historique"
	b_historique.text = "HISTORIQUE"
	b_historique.custom_minimum_size = Vector2(222, 90.0)
	b_historique.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b_historique.focus_mode = Control.FOCUS_NONE
	CadresPixel.habiller_bouton(b_historique, "secondaire", "historique")
	b_historique.add_theme_constant_override("h_separation", 12)
	for etat: String in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var sbh: StyleBoxTexture = b_historique.get_theme_stylebox(etat).duplicate()
		var enfonce := etat.contains("pressed")
		sbh.content_margin_left = 18
		sbh.content_margin_right = 24
		sbh.content_margin_top = 12 if enfonce else 9
		sbh.content_margin_bottom = 18 if enfonce else 21
		b_historique.add_theme_stylebox_override(etat, sbh)
	b_historique.tooltip_text = "Tout ce qui vous est arrivé : appels, nouvelles, courriers (touche H)"
	b_historique.pressed.connect(func() -> void: historique_demande.emit())
	hb.add_child(b_historique)
	hb.move_child(b_historique, 0)   # à gauche : à droite, le panneau « Mon argent » le couvrirait
	# Badge des non-lus (D5) : 12 × 12 texels sur le coin haut droit du bouton (moitié dehors à droite), dans
	# les bornes de la frise ; il fait partie du bouton (pas une cible à part)
	badge_non_lus = Control.new()
	badge_non_lus.name = "BadgeNonLus"
	badge_non_lus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_non_lus.size = Vector2(36, 36)
	badge_non_lus.visible = false
	badge_non_lus.draw.connect(func() -> void: Hud.dessiner_pastille(badge_non_lus, str(badge_non_lus.get_meta("texte", ""))))
	b_historique.add_child(badge_non_lus)
	b_historique.resized.connect(_placer_badge)


func _placer_badge() -> void:
	var dy := bas.get_global_rect().position.y - b_historique.get_global_rect().position.y
	var y0 := roundf(maxf(-18.0, dy) / 3.0) * 3.0
	badge_non_lus.position = Vector2(roundf((b_historique.size.x - 18.0) / 3.0) * 3.0, y0)
	badge_non_lus.set_meta("y0", y0)


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
	var titre := Style.label("MON ARGENT", 28, Style.capitales(), Style.TEXTE)
	titre.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(titre)
	tete.add_child(_ressort())
	var fermer := Style.bouton("REPLIER")
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
	lc.name = "LigneCoussin"
	lc.add_theme_constant_override("separation", 12)
	lc.add_child(Style.label("COUSSIN", 20, Style.capitales(), Style.TEXTE_2))
	jauge = Control.new()
	jauge.custom_minimum_size = Vector2(0, 21)
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
	languette.name = "Languette"
	languette.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	languette.add_theme_font_size_override("font_size", 20)
	languette.add_theme_font_override("font", Style.petites_capitales())
	var sl := CadresPixel.style_marges("panneau", 6, 12, 6, 18)
	languette.add_theme_stylebox_override("normal", sl)
	languette.add_theme_stylebox_override("hover", sl)
	languette.add_theme_stylebox_override("pressed", CadresPixel.style_marges("panneau", 6, 15, 6, 15))
	languette.pressed.connect(func() -> void: basculer_panneau(true))
	add_child(languette)


func _trait_legende(c: Color, pointille: bool) -> Control:
	var t := Control.new()
	t.custom_minimum_size = Vector2(30, 24)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.draw.connect(_dessiner_trait.bind(t, c, pointille))
	return t


func _dessiner_trait(t: Control, c: Color, pointille: bool) -> void:
	var y := floorf(t.size.y / 6.0) * 3.0
	if pointille:
		for k in int(t.size.x / 9.0):
			t.draw_rect(Rect2(k * 9.0, y, 6, 3), c)
	else:
		t.draw_rect(Rect2(0, y, t.size.x, 3), c)


func _ligne_budget(grille: GridContainer, titre: String) -> Label:
	var t := Style.label(titre, 24, Style.ui(), Style.TEXTE_2)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grille.add_child(t)
	var v := Style.label("", 24, Style.chiffres())
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	grille.add_child(v)
	return v


## Étiquettes des bâtiments, posées sur la chaussée (PX0) ; cible tactile d'au moins Style.cible_min().
## Bâtiment hors de l'écran (rue large de PX1, si la ville sait le dire) : flèche de bord « ‹ LA GAZETTE »
## ou « MA BANQUE › » qui, touchée, fait glisser la caméra vers lui (ville.aller_vers).
func _creer_etiquettes() -> void:
	for id in ["maison", "media", "banque"]:
		var p := PanelContainer.new()
		p.name = "Etiquette_" + id
		p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		p.add_theme_stylebox_override("panel", Style.etiquette_batiment())
		p.self_modulate = Color(1, 1, 1, 0.94)
		p.mouse_filter = Control.MOUSE_FILTER_STOP
		p.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		p.custom_minimum_size = Vector2(0, Style.cible_min())
		# Flèche de bord : chevrons en sprite 8 × 8 texels (C6), masqués quand le bâtiment est visible
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 12)
		hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cg := CadresPixel.icone("chevron_gauche")
		cg.name = "ChevronGauche"
		cg.visible = false
		hb.add_child(cg)
		var l := Style.label(NOMS_SOURCES[id], 28, Style.capitales(), Style.TEXTE)
		l.name = "Nom"
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.size_flags_vertical = Control.SIZE_FILL
		hb.add_child(l)
		var cd := CadresPixel.icone("chevron_droite")
		cd.name = "ChevronDroite"
		cd.visible = false
		hb.add_child(cd)
		p.add_child(hb)
		p.gui_input.connect(_on_etiquette.bind(id))
		if id == "banque":
			p.draw.connect(_dessiner_point_banque.bind(p))
		add_child(p)
		etiquettes[id] = p


func _dessiner_point_banque(p: PanelContainer) -> void:
	if not _point_banque:
		return
	var c := Vector2(p.size.x - 6, 6)
	p.draw_rect(Rect2(c - Vector2(12, 12), Vector2(24, 24)), Style.ENCRE)
	p.draw_rect(Rect2(c - Vector2(9, 9), Vector2(18, 18)), Style.ALERTE)


func _on_etiquette(event: InputEvent, id: String) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
		var p: Control = etiquettes[id]
		if p.get_meta("fleche", "") != "" and ville != null and ville.has_method("aller_vers"):
			ville.call("aller_vers", id)
		else:
			batiment_touche.emit(id)


## Place les étiquettes (PX2 §2.4, §9.1 point 3, C8) : la ville donne le point, l'interface a le dernier
## mot. Bâtiment visible : étiquette au point, ramenée entièrement dans rect_libre() (8 px de marge).
## Bâtiment caché : flèche de bord à 16 px du bord du rectangle libre (donc à gauche du panneau ouvert),
## à la hauteur de l'étiquette, bornée elle aussi ; deux flèches du même côté s'empilent.
## Lot 02, passage 2 (E1, E2) : maison et banque sont « vues » si leur porte l'est (ville.porte_ecran, même
## règle que les pièces du mois) ; la Gazette (sans porte) si elle est entière (est_visible). Les flèches de bord
## sont posées d'abord (empilées), puis les étiquettes en place ; une étiquette qui en touche une autre est
## poussée à côté (8 px, vers le centre d'abord), faute de place au-dessus. Jamais de chevauchement, jamais masquée.
func placer_etiquettes() -> void:
	if ville == null:
		return
	var libre := rect_libre()
	var occupes := {"gauche": [], "droite": []}
	var poses: Array = []   # Rect2 déjà posés (flèches puis étiquettes)
	var en_place: Array = []
	var points := {}
	for id in etiquettes:
		var p: PanelContainer = etiquettes[id]
		var point: Vector2
		if ville.has_method("point_etiquette"):
			point = ville.call("point_etiquette", id)
		else:
			var b: Node2D = ville.call("batiment", id)
			point = ville.call("position_ecran", b.position + Vector2(0, 56))
		points[id] = point
		var cote := ""
		if not batiment_vu(id):
			cote = "gauche" if point.x < libre.get_center().x else "droite"
		if cote != str(p.get_meta("fleche", "")):
			p.set_meta("fleche", cote)
			p.find_child("ChevronGauche", true, false).visible = cote == "gauche"
			p.find_child("ChevronDroite", true, false).visible = cote == "droite"
			p.reset_size()
		if cote == "":
			en_place.append(id)
			continue
		var s := p.size
		var x := libre.position.x + 16.0 if cote == "gauche" else libre.end.x - s.x - 16.0
		var y := clampf(point.y, libre.position.y + 8.0, libre.end.y - s.y - 8.0)
		# Empilement : on remonte au-dessus d'une flèche déjà posée du même côté
		for r: Rect2 in occupes[cote]:
			if Rect2(x, y, s.x, s.y).intersects(r.grow(4.0)):
				y = r.position.y - s.y - 8.0
		y = maxf(y, libre.position.y + 8.0)
		occupes[cote].append(Rect2(x, y, s.x, s.y))
		p.position = _au_texel(Vector2(x, y))
		poses.append(Rect2(p.position, s))
	en_place.sort_custom(func(a: String, b: String) -> bool: return points[a].x < points[b].x)
	for id: String in en_place:
		var p: PanelContainer = etiquettes[id]
		var s := p.size
		var base := Vector2(points[id].x - s.x / 2.0, points[id].y)
		p.position = _place_libre(base, s, libre, poses)
		poses.append(Rect2(p.position, s))


## Vrai si le bâtiment est vu (pas de flèche de bord) : porte visible pour maison et banque (repli : est_visible).
func batiment_vu(id: String) -> bool:
	if ville == null:
		return true
	if id != "media" and ville.has_method("porte_ecran"):
		return ville.call("porte_ecran", id) != Vector2(-1, -1)
	return not ville.has_method("est_visible") or bool(ville.call("est_visible", id))


static func _au_texel(v: Vector2) -> Vector2:
	return Vector2(roundf(v.x / 3.0) * 3.0, floorf(v.y / 3.0) * 3.0)


## Position la plus proche de « base » (taille s) dans le rectangle libre, sans toucher les rectangles posés
## (marge 8 px) : à côté d'un obstacle (vers le centre d'abord), puis au-dessus, puis plus haut encore.
func _place_libre(base: Vector2, s: Vector2, libre: Rect2, poses: Array) -> Vector2:
	var bornes := Rect2(libre.position + Vector2(8, 8), libre.size - s - Vector2(16, 16))
	var depart := base.clamp(bornes.position, bornes.end)
	var candidats: Array = [depart]
	var ys: Array = [depart.y]
	for r: Rect2 in poses:
		ys.append(r.position.y - s.y - 8.0)
	for y: float in ys:
		candidats.append(Vector2(depart.x, y))
		for r: Rect2 in poses:
			candidats.append(Vector2(r.end.x + 8.0, y))
			candidats.append(Vector2(r.position.x - s.x - 8.0, y))
	var centre := libre.get_center().x
	candidats.sort_custom(func(a: Vector2, b: Vector2) -> bool: return Hud._cout(a, depart, centre) < Hud._cout(b, depart, centre))
	for c: Vector2 in candidats:
		var q := _au_texel(c)
		if not libre.grow(-4.0).encloses(Rect2(q, s)):
			continue
		var libre_ici := true
		for r: Rect2 in poses:
			if Rect2(q, s).grow(4.0).intersects(r):
				libre_ici = false
				break
		if libre_ici:
			return q
	return _au_texel(depart)   # aucune place (ne doit pas arriver) : la position naturelle


## Coût d'un candidat : distance à la position naturelle ; monter coûte plus cher que glisser (E2).
static func _cout(c: Vector2, depart: Vector2, centre: float) -> float:
	var vers_centre := 0.0 if absf(c.x - centre) <= absf(depart.x - centre) else 30.0
	return absf(c.x - depart.x) + 3.0 * absf(c.y - depart.y) + vers_centre


## Contrôle (C2) : paires d'étiquettes ou flèches qui se recouvrent (l'une agrandie de 4 px : il faut au moins
## 4 px d'écart) + étiquettes hors du rectangle libre.
func chevauchements_etiquettes() -> int:
	var libre := rect_libre()
	var rects: Array = []
	var n := 0
	for id in etiquettes:
		var p: Control = etiquettes[id]
		var r := Rect2(p.position, p.size)
		if not libre.grow(1.0).encloses(r):
			n += 1
		for q: Rect2 in rects:
			if r.grow(4.0).intersects(q):
				n += 1
		rects.append(r)
	return n


# =====================================================================
# Disposition (PC / téléphone)
# =====================================================================

func _disposer() -> void:
	compact = Ecran.compact()
	# Barre haute : elle tient dans la largeur (1728 px virtuels pour une fenêtre PC de 1152 × 648,
	# 1280 au téléphone 16:9) : badge « EN PAUSE » replié, puis variation et libellé COURRIER (_replier_barre).
	var largeur := Ecran.taille().x
	(barre.get_child(0) as HBoxContainer).add_theme_constant_override("separation", 9 if largeur < 2000.0 else 15)
	# Téléphone : mêmes blocs, libellés courts et chiffres un peu plus petits
	l_titre_cc.text = "COMPTE" if compact or largeur < 1900.0 else "COMPTE COURANT"
	l_cc.add_theme_font_size_override("font_size", 28 if compact else 32)
	l_patr.add_theme_font_size_override("font_size", 38 if compact else 44)
	l_var.visible = not compact
	separateur.custom_minimum_size = Vector2(40 if compact else 56, 60)
	l_titre_livret.text = "VS LIVRET A" if compact or largeur < 1900.0 else "VS TOUT AU LIVRET A"
	l_ecart.add_theme_font_size_override("font_size", 26 if compact else 30)
	l_ecart_note.visible = not compact
	for g in ["pause", "x1", "x2", "x3"]:
		boutons[g].visible = not compact
	b_lecture.visible = compact
	b_cycle.visible = compact
	conteneur.vertical = not compact
	courbe.compacte = compact
	courbe.custom_minimum_size = Vector2(0, 64 if compact else 110)
	_trouver_replier().visible = compact
	panneau_ouvert = not compact
	_placer_panneau()
	placer_etiquettes.call_deferred()
	_replier_barre()
	_placer_badge.call_deferred()
	_placer_bulle.call_deferred()


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


## Le panneau « Mon argent » tient entre la barre haute et la frise (lot_px2 §9.1) : la courbe absorbe la
## place restante ; si cela ne suffit pas, on replie dans l'ordre la ligne baguette, le coussin, puis la
## légende de la répartition. Le bouton BANQUE et les frais restent toujours visibles. Pas de défilement.
func _alleger_panneau() -> void:
	if panneau == null:
		return
	var coussin := panneau.find_child("LigneCoussin", true, false) as Control
	l_bag.visible = true
	coussin.visible = true
	repart.legende = true
	var sb := panneau.get_theme_stylebox("panel")
	var dispo := get_viewport_rect().size.y - HAUT - BAS - 24.0 - sb.content_margin_top - sb.content_margin_bottom
	for etape in 3:
		if conteneur.get_combined_minimum_size().y <= dispo + 0.5:
			break
		match etape:
			0:
				l_bag.visible = false
			1:
				coussin.visible = false
			2:
				repart.legende = false


## Vrai si le contenu du panneau dépasse sa place (contrôle « UI panneau … contenu_coupe »).
func panneau_coupe() -> bool:
	var sb := panneau.get_theme_stylebox("panel")
	return conteneur.get_combined_minimum_size().y > panneau.size.y - sb.content_margin_top - sb.content_margin_bottom + 0.5


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
	_alleger_panneau.call_deferred()
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
	# Variation sur 12 mois (ou depuis le début de la tranche)
	var m0 := maxi(e.m_depart, e.m - 12)
	var ref: float = e.hist["j"][m0]
	if e.m > e.m_depart and ref > 0.0:
		var v := patr / ref - 1.0
		l_var.text = ("+" if v >= 0.0 else "") + Format.pct(v, 0).trim_prefix("+")
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
	languette.text = texte_languette(Format.nombre(Format.en_devise(patr, Format.devise(a)) / 1000.0, 0), Format.devise(a))
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
	_alleger_panneau.call_deferred()


## Languette repliée (téléphone) : « MON / ARGENT / 82 k F » ; le montant et son unité restent sur la même
## ligne (espaces insécables) si elle tient dans la languette, sinon « 1 234 / k F » (jamais un « F » seul, m11).
func texte_languette(milliers: String, devise: String) -> String:
	var ligne := milliers + Format.ESPACE + "k" + Format.ESPACE + devise
	var police := languette.get_theme_font("font")
	var place := LARGEUR_LANGUETTE - 12.0
	if police == null or police.get_string_size(ligne, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x <= place:
		return "MON\nARGENT\n\n" + ligne
	return "MON\nARGENT\n\n%s\nk%s%s" % [milliers, Format.ESPACE, devise]


func _duree_mois() -> float:
	return Partie.duree_mois_s()


## Boutons du temps, badge et cadre de gel. Pendant un saut « jusqu'au prochain courrier » (lot 02, vitesse
## effective) : aucun bouton de vitesse enfoncé, pas de cadre de gel, le badge affiche « » ×6 » en ambre ;
## à la fin du saut, retour à l'affichage de v (Partie.vitesse, inchangée pendant le saut).
func maj_vitesse(v: int) -> void:
	var saut := Partie.saut_actif
	for i in 4:
		var g: String = ["pause", "x1", "x2", "x3"][i]
		boutons[g].set_pressed_no_signal(i == v and not saut)
		boutons[g].queue_redraw()
	if v > 0:
		b_cycle.vitesse_cycle = v
	b_lecture.queue_redraw()
	b_cycle.queue_redraw()
	var texte := "» ×6" if saut else "EN PAUSE"
	if badge_pause.text != texte:
		badge_pause.text = texte
		badge_pause.add_theme_font_override("font", Style.police_pour(Style.neon(), 28, texte))   # chiffre : Atkinson
		badge_pause.add_theme_color_override("font_color", Style.ACCENT if saut else Style.GEL)
		badge_pause.add_theme_color_override("font_shadow_color", Color(Style.ACCENT if saut else Style.GEL, 0.6))
	badge_pause.visible = (v == 0 or saut) and not badge_pause.get_meta("replie", false)
	var t := create_tween()
	t.tween_property(self, "_gel", 1.0 if v == 0 and not saut else 0.0, 0.3)
	t.parallel().tween_method(func(_x: float) -> void: cadre_gel.queue_redraw(), 0.0, 1.0, 0.3)


func _process(_delta: float) -> void:
	frise.position_mois = (Partie.etat.m + Partie.progression_mois()) if Partie.etat != null else 0.0
	if ville != null and not ville.has_signal("camera_bougee"):
		placer_etiquettes()
	badge_pause.modulate.a = 0.75 + 0.25 * sin(Time.get_ticks_msec() / 300.0)
	if _etat_courrier == "saut":
		_animer_saut()
	_verifier_bulle()
	frise.fantomes = Partie.saut_actif


func _dessiner_gel() -> void:
	if _gel <= 0.01:
		return
	var r := Rect2(Vector2.ZERO, cadre_gel.size).grow(-3)
	cadre_gel.draw_rect(r, Color(Style.GEL, 0.55 * _gel), false, 6.0)
	cadre_gel.draw_rect(r.grow(-6), Color(Style.GEL, 0.15 * _gel), false, 6.0)


func _dessiner_jauge() -> void:
	# Jauge pixel : contour encre, fond ardoise sombre, remplissage au texel, repère des 3 mois
	var r := Rect2(Vector2.ZERO, (jauge.size / 3.0).floor() * 3.0)
	jauge.draw_rect(r, Style.ENCRE)
	jauge.draw_rect(r.grow(-3), Style.PANNEAU_ELEVE)
	var k := clampf(_coussin / 6.0, 0.0, 1.0)
	var c := Style.GAIN if _coussin >= 3.0 else Style.ALERTE
	if k > 0.0:
		jauge.draw_rect(Rect2(3, 3, maxf(6.0, roundf((r.size.x - 6.0) * k / 3.0) * 3.0), r.size.y - 6.0), c)
	var x3 := roundf(r.size.x * 0.5 / 3.0) * 3.0
	jauge.draw_rect(Rect2(x3 - 1.5, -3, 3, r.size.y + 6), Style.TEXTE)


# =====================================================================
# Notifications (3 au maximum, empilées en haut à gauche)
# =====================================================================

## depart : position d'écran d'où la notification s'envole (bâtiment source), ou (-1, -1).
func notifier(n: Dictionary, a: int, depart := Vector2(-1, -1)) -> void:
	if n.get("pendant_saut", false):
		_notifier_compacte(n)
		return
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
		# m1 : l'indication passe à la ligne et tient dans le cadre de la notification
		var ind := Style.label("Message de M. Lefranc · touchez pour le fermer (rangé dans l'historique)", 20, Style.ui(), Style.SOURCES["banque"])
		ind.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ind.custom_minimum_size = Vector2(320, 0)
		v.add_child(ind)
	elif n.get("type", "") == "releve" and float(n.get("frais_total", 0.0)) > 0.0:
		var indr := Style.label("Touchez pour voir le détail des frais", 20, Style.ui(), Style.CUIVRE)
		indr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		indr.custom_minimum_size = Vector2(320, 0)
		v.add_child(indr)
	notifs.add_child(p)
	_liste_notifs.push_front(p)
	while _liste_notifs.size() > 3:
		_evacuer(_liste_notifs.pop_back())
	p.gui_input.connect(_clic_notif.bind(p, n))
	await get_tree().process_frame
	if not is_instance_valid(p):
		return
	_empiler(p, depart)
	if persistant:
		point_banque(true)
		return
	# Une notification ordinaire reste un mois à ×1 (13 §5.2), moins en accéléré. Pendant un saut,
	# duree_mois_s() renvoie la durée du saut (rythme.json > saut, ≈ 1,3 s) : la notification reste 3 s (borne).
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
	# Les notifications restent dans le rectangle libre, au-dessus de la frise : les plus anciennes partent
	var place := rect_libre().size.y - 32.0
	var total := 0.0
	for c: Control in _liste_notifs:
		if is_instance_valid(c):
			total += c.size.y + 10.0
	while total > place and _liste_notifs.size() > 1:
		var vieille: Control = _liste_notifs.pop_back()
		if is_instance_valid(vieille):
			total -= vieille.size.y + 10.0
			_evacuer(vieille)
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


## Notification reçue pendant un saut (D6, docs/17 §2.2) : une ligne, pastille de la source et titre de
## 40 caractères au plus ; 3 au plus, la 4e pousse la plus ancienne vers HISTORIQUE (fiche volante).
func _notifier_compacte(n: Dictionary) -> void:
	var source: String = n.get("source", "banque")
	var nom_coul: String = Style.NOMS_PALETTE_SOURCES.get(source, "or")
	var p := PanelContainer.new()
	p.name = "NotifCompacte"
	p.set_meta("compacte", source)
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.add_theme_stylebox_override("panel", CadresPixel.style_marges("notification", 18, 9, 21, 15, {} if nom_coul == "or" else {"or": nom_coul}))
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	p.add_child(h)
	var pic := CadresPixel.icone("source_" + source if source in Style.NOMS_PALETTE_SOURCES else "source_banque", {"creme": nom_coul}, 2)
	pic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(pic)
	h.add_child(Style.label(titre_court(str(n.get("titre", ""))), 22, Style.ui_gras()))
	notifs.add_child(p)
	_liste_notifs.push_front(p)
	while _liste_notifs.size() > 3:
		_evacuer(_liste_notifs.pop_back())
	p.gui_input.connect(_clic_notif.bind(p, n))
	await get_tree().process_frame
	if not is_instance_valid(p):
		return
	_empiler(p, Vector2(-1, -1))
	await get_tree().create_timer(clampf(Partie.duree_mois_s(maxi(1, Partie.vitesse)), 3.0, 8.0) + 0.4).timeout
	_retirer(p)


## Titre d'une notification compacte : 40 caractères au plus, coupé par « … ».
static func titre_court(t: String) -> String:
	return t if t.length() <= 40 else t.left(39).strip_edges() + "…"


## Notification poussée hors de la pile : une compacte se réduit en fiche qui vole vers HISTORIQUE.
func _evacuer(vieille: Control) -> void:
	if not is_instance_valid(vieille):
		return
	if vieille.has_meta("compacte"):
		_envoler_fiche(vieille.get_global_rect().position + Vector2(9, vieille.size.y / 2.0 - 12.0), str(vieille.get_meta("compacte")))
	vieille.queue_free()


## Fiche 8 × 8 texels de la couleur de la source, en arc (0,4 s) jusqu'au bouton HISTORIQUE ; puis le badge saute.
func _envoler_fiche(depart: Vector2, source: String) -> void:
	if Juice.animations_reduites or not b_historique.is_visible_in_tree():
		sauter_badge()
		return
	var fiche := Control.new()
	fiche.name = "FicheVolante"
	fiche.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fiche.size = Vector2(24, 24)
	fiche.draw.connect(_dessiner_fiche.bind(fiche, Style.SOURCES.get(source, Style.ACCENT)))
	add_child(fiche)
	var arrivee := b_historique.get_global_rect().get_center() - Vector2(12, 12)
	_vol_fiche(0.0, fiche, depart, arrivee)
	var t := fiche.create_tween()
	t.tween_method(_vol_fiche.bind(fiche, depart, arrivee), 0.0, 1.0, 0.4)
	t.tween_callback(sauter_badge)
	t.tween_callback(fiche.queue_free)


func _vol_fiche(k: float, fiche: Control, depart: Vector2, arrivee: Vector2) -> void:
	var p := depart.lerp(arrivee, k) - Vector2(0, 120.0 * 4.0 * k * (1.0 - k))
	fiche.position = (p / 3.0).round() * 3.0


func _dessiner_fiche(fiche: Control, couleur: Color) -> void:
	fiche.draw_rect(Rect2(0, 0, 24, 24), Style.ENCRE)
	fiche.draw_rect(Rect2(3, 3, 18, 18), couleur)
	fiche.draw_rect(Rect2(6, 9, 12, 3), Style.JOURNAL)


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
