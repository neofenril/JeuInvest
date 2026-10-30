extends Control
## HUD pixel de la preuve de concept (lot PX0 §2.5, docs/16 §3.4 et §5.1) : barre haute (date à volets,
## baguette, boutons du temps, compte courant, patrimoine, pastille « vs tout au Livret A », menu), frise
## (bouton HISTORIQUE, rail 1984 → 1988, curseur en mai 1987) et étiquette « MA MAISON » posée sur la
## chaussée. Sans class_name : chargé par chemin. Aucune partie lue : valeurs de v3_rue.png ci-dessous.

const Polices := preload("res://scripts/pixel/ui/polices_px0.gd")
const Cadres := preload("res://scripts/pixel/ui/cadres_px0.gd")

const HAUT := 96.0           # bande de la barre haute (px virtuels), comme hud.gd
const BAS := 72.0            # bande de la frise
const OMBRE := 6.0           # ombre portée des panneaux (2 texels)
const LARGEUR_COMPACTE := 1700.0   # en dessous (téléphone) : barre resserrée

# Valeurs de la capture v3_rue.png (partie réelle, mai 1987). Lire une partie en cours toucherait
# user:// : refusé pour PX0 (lot PX0 §2.5). Les mêmes chiffres rendent le montage avant / après comparable.
const MOIS := "MAI"
const ANNEE := "1987"
const BAGUETTE := "2,85 F"
const COMPTE := "8 875 F"
const PATRIMOINE := "69 395 F"
const EVOLUTION := "+26 %"
const ECART_LIVRET := "+3 916 F"
const FRISE_DEBUT := 1984          # janvier 1984
const FRISE_FIN := 1988            # décembre 1988 (le rail s'arrête au 1er janvier 1989)
const CURSEUR_MOIS := 40           # mai 1987 = 3 ans et 4 mois après janvier 1984

# Tailles (px virtuels). Atkinson : chiffres et petits textes ; Pixelify : jamais sous 28.
const T_LEGENDE := 20
const T_DATE := 44
const T_DATE_JERSEY := 60
const T_BAGUETTE := 28
const T_COMPTE := 32
const T_PATRIMOINE := 44
const T_PATRIMOINE_JERSEY := 56
const T_EVOLUTION := 22
const T_ECART := 30
const T_FRISE := 20

var vue: VuePixel
var rue: RuePx0

var barre: Panel
var contenu_haut: HBoxContainer
var frise: Panel
var contenu_bas: HBoxContainer
var rail: Control
var etiquette: PanelContainer

var l_mois: Label
var l_annee: Label
var bloc_baguette: VBoxContainer
var b_temps: Array[Button] = []
var l_cc_legende: Label
var l_cc: Label
var l_patr: Label
var l_evolution: Label
var l_ecart_legende: Label
var l_ecart: Label
var b_menu: Button
var b_historique: Button

var _compact := false
var _jersey := false
var _vitesse := 1          # 0 pause, 1 lecture, 2 ×2, 3 ×3 (visuel seulement ; pause fige la rue)
var menu_demande: Callable = Callable()


func _init() -> void:
	name = "HudPx0"
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func construire(v: VuePixel, r: RuePx0) -> void:
	vue = v
	rue = r
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_construire_barre()
	_construire_frise()
	_construire_etiquette()
	vue.regler_marges(HAUT, BAS)
	if vue.has_signal("vue_change"):
		vue.vue_change.connect(_placer_etiquette)
	resized.connect(mettre_en_page)
	get_viewport().size_changed.connect(mettre_en_page)
	mettre_en_page.call_deferred()


# --- Barre haute -----------------------------------------------------------------------------------

func _construire_barre() -> void:
	barre = Panel.new()
	barre.name = "BarreHaute"
	barre.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	barre.add_theme_stylebox_override("panel", Cadres.style("panneau"))
	barre.self_modulate = Color(1, 1, 1, 0.94)
	barre.mouse_filter = Control.MOUSE_FILTER_STOP
	barre.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	barre.offset_bottom = HAUT + OMBRE
	add_child(barre)

	contenu_haut = HBoxContainer.new()
	contenu_haut.name = "Contenu"
	contenu_haut.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	contenu_haut.offset_left = 15
	contenu_haut.offset_right = -15
	contenu_haut.offset_top = 6
	contenu_haut.offset_bottom = HAUT - 6
	contenu_haut.add_theme_constant_override("separation", 18)
	contenu_haut.alignment = BoxContainer.ALIGNMENT_BEGIN
	add_child(contenu_haut)

	# Date à volets : deux plaquettes « calendrier » avec charnière
	var date := HBoxContainer.new()
	date.add_theme_constant_override("separation", 6)
	date.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	l_mois = _plaquette(date, MOIS)
	l_annee = _plaquette(date, ANNEE)
	contenu_haut.add_child(date)

	bloc_baguette = VBoxContainer.new()
	bloc_baguette.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bloc_baguette.add_theme_constant_override("separation", 0)
	bloc_baguette.add_child(Cadres.etiquette("BAGUETTE", Polices.atkinson(700), T_LEGENDE, "gris_pierre"))
	bloc_baguette.add_child(Cadres.etiquette(_n(BAGUETTE), Polices.atkinson(700), T_BAGUETTE, "creme"))
	contenu_haut.add_child(bloc_baguette)

	contenu_haut.add_child(_ressort())

	var temps := HBoxContainer.new()
	temps.add_theme_constant_override("separation", 9)
	temps.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for i in 4:
		var icones := ["pause", "lecture", "x2", "x3"]
		var b := Cadres.bouton("secondaire", "", icones[i])
		b.name = "Temps_" + icones[i]
		b.pressed.connect(_choisir_vitesse.bind(i))
		temps.add_child(b)
		b_temps.append(b)
	contenu_haut.add_child(temps)

	contenu_haut.add_child(_ressort())

	var compte := VBoxContainer.new()
	compte.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	compte.add_theme_constant_override("separation", 0)
	l_cc_legende = Cadres.etiquette("COMPTE COURANT", Polices.atkinson(700), T_LEGENDE, "gris_pierre")
	l_cc_legende.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	compte.add_child(l_cc_legende)
	l_cc = Cadres.etiquette(_n(COMPTE), Polices.atkinson(700), T_COMPTE, "creme")
	l_cc.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	compte.add_child(l_cc)
	contenu_haut.add_child(compte)

	var sep := ColorRect.new()
	sep.color = Cadres.couleur("ardoise_sombre")
	sep.custom_minimum_size = Vector2(3, 60)
	sep.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenu_haut.add_child(sep)

	var patr := VBoxContainer.new()
	patr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	patr.add_theme_constant_override("separation", 0)
	patr.add_child(Cadres.etiquette("PATRIMOINE", Polices.atkinson(700), T_LEGENDE, "gris_pierre"))
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 9)
	l_patr = Cadres.etiquette(_n(PATRIMOINE), Polices.atkinson(700), T_PATRIMOINE, "creme")
	ligne.add_child(l_patr)
	var evo := HBoxContainer.new()
	evo.add_theme_constant_override("separation", 3)
	evo.size_flags_vertical = Control.SIZE_SHRINK_END
	var f1 := Cadres.icone("fleche_haut")
	f1.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	evo.add_child(f1)
	l_evolution = Cadres.etiquette(_n(EVOLUTION), Polices.atkinson(700), T_EVOLUTION, "gain")
	evo.add_child(l_evolution)
	ligne.add_child(evo)
	patr.add_child(ligne)
	contenu_haut.add_child(patr)

	var pastille := Cadres.panneau("pastille")
	var st: StyleBoxTexture = Cadres.style("pastille").duplicate()
	st.content_margin_left = 18
	st.content_margin_right = 18
	st.content_margin_top = 6
	st.content_margin_bottom = 6
	pastille.add_theme_stylebox_override("panel", st)
	pastille.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pastille.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 0)
	l_ecart_legende = Cadres.etiquette("VS TOUT AU LIVRET A", Polices.atkinson(700), T_LEGENDE, "creme")
	pv.add_child(l_ecart_legende)
	var pl := HBoxContainer.new()
	pl.add_theme_constant_override("separation", 6)
	var f2 := Cadres.icone("fleche_haut")
	f2.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pl.add_child(f2)
	l_ecart = Cadres.etiquette(_n(ECART_LIVRET), Polices.atkinson(700), T_ECART, "gain")
	pl.add_child(l_ecart)
	pv.add_child(pl)
	pastille.add_child(pv)
	contenu_haut.add_child(pastille)

	b_menu = Cadres.bouton("secondaire", "", "menu")
	b_menu.name = "Menu"
	b_menu.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b_menu.pressed.connect(_menu)
	contenu_haut.add_child(b_menu)
	_choisir_vitesse(1)


func _plaquette(parent: Control, texte: String) -> Label:
	var p := Cadres.panneau("plaquette")
	var st: StyleBoxTexture = Cadres.style("plaquette").duplicate()
	st.content_margin_left = 15
	st.content_margin_right = 15
	st.content_margin_top = 3
	st.content_margin_bottom = 3
	p.add_theme_stylebox_override("panel", st)
	p.custom_minimum_size = Vector2(0, 72)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := Cadres.etiquette(texte, Polices.atkinson(700), T_DATE, "creme")
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Charnière des volets : filet sombre au milieu, derrière les chiffres
	var charniere := ColorRect.new()
	charniere.color = Cadres.couleur("nuit")
	charniere.show_behind_parent = true
	charniere.mouse_filter = Control.MOUSE_FILTER_IGNORE
	charniere.anchor_left = 0.0
	charniere.anchor_right = 1.0
	charniere.anchor_top = 0.5
	charniere.anchor_bottom = 0.5
	charniere.offset_left = -12
	charniere.offset_right = 12
	charniere.offset_top = -1.5
	charniere.offset_bottom = 1.5
	l.add_child(charniere)
	p.add_child(l)
	parent.add_child(p)
	return l


func _menu() -> void:
	if menu_demande.is_valid():
		menu_demande.call()


## Vrai si le bouton pause est actif (la rue reste figée).
func en_pause() -> bool:
	return _vitesse == 0


func _ressort() -> Control:
	var c := Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


func _choisir_vitesse(i: int) -> void:
	_vitesse = i
	var icones := ["pause", "lecture", "x2", "x3"]
	for k in b_temps.size():
		Cadres.habiller_bouton(b_temps[k], "principal" if k == i else "secondaire", icones[k])
	# En compact : un seul bouton de vitesse (lecture), qui affiche la vitesse courante
	if rue != null:
		rue.figer(i == 0)


# --- Frise -----------------------------------------------------------------------------------------

func _construire_frise() -> void:
	frise = Panel.new()
	frise.name = "Frise"
	frise.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frise.add_theme_stylebox_override("panel", Cadres.style("panneau"))
	frise.self_modulate = Color(1, 1, 1, 0.94)
	frise.mouse_filter = Control.MOUSE_FILTER_STOP
	frise.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	frise.offset_top = -BAS
	frise.offset_bottom = OMBRE
	add_child(frise)

	contenu_bas = HBoxContainer.new()
	contenu_bas.name = "ContenuFrise"
	contenu_bas.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	contenu_bas.offset_left = 12
	contenu_bas.offset_right = -24
	contenu_bas.offset_top = -BAS + 6
	contenu_bas.offset_bottom = -3
	contenu_bas.add_theme_constant_override("separation", 24)
	add_child(contenu_bas)

	b_historique = Cadres.bouton("secondaire", "HISTORIQUE", "historique", Vector2(0, 60))
	b_historique.name = "Historique"
	b_historique.add_theme_font_size_override("font_size", 28)
	# Marges intérieures resserrées : le bouton tient dans la bande de 72 px (60 de haut, comme hud.gd)
	for etat: String in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var sb: StyleBoxTexture = b_historique.get_theme_stylebox(etat).duplicate()
		var enfonce := etat.contains("pressed")
		sb.content_margin_left = 15
		sb.content_margin_right = 21
		sb.content_margin_top = 9 if enfonce else 6
		sb.content_margin_bottom = 6 if enfonce else 9
		b_historique.add_theme_stylebox_override(etat, sb)
	b_historique.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	contenu_bas.add_child(b_historique)

	rail = Rail.new()
	rail.hud = self
	rail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenu_bas.add_child(rail)


## Rail de la frise : années, piquets, partie écoulée en 2 tons (ambre / orange), curseur calendrier,
## drapeau de fin. Coordonnées arrondies au texel (3 px virtuels).
class Rail extends Control:
	var hud

	func _draw() -> void:
		var w := size.x
		var cy := roundf(size.y * 0.66 / 3.0) * 3.0
		var debut := 6.0
		var fin := w - 36.0
		var mois_total := float((FRISE_FIN - FRISE_DEBUT + 1) * 12)
		var xc := _t(debut + (fin - debut) * CURSEUR_MOIS / mois_total)
		var police: Font = Polices.atkinson(700)
		# piste
		draw_rect(Rect2(debut - 3, cy - 6, fin - debut + 6, 15), PalettePixel.couleur("encre"))
		draw_rect(Rect2(debut, cy - 3, fin - debut, 9), PalettePixel.couleur("ardoise_sombre"))
		draw_rect(Rect2(debut, cy - 3, xc - debut, 6), PalettePixel.couleur("ambre"))
		draw_rect(Rect2(debut, cy + 3, xc - debut, 3), PalettePixel.couleur("orange"))
		# années
		for a in range(FRISE_DEBUT, FRISE_FIN + 1):
			var x := _t(debut + (fin - debut) * float((a - FRISE_DEBUT) * 12) / mois_total)
			var passe: bool = (a - FRISE_DEBUT) * 12 <= CURSEUR_MOIS
			draw_rect(Rect2(x, cy - 15, 3, 9), PalettePixel.couleur("gris_pierre" if passe else "ardoise"))
			draw_string(police, Vector2(x + 6, cy - 12), str(a), HORIZONTAL_ALIGNMENT_LEFT, -1, T_FRISE,
				PalettePixel.couleur("creme" if passe else "gris_pierre"))
		# drapeau de fin, curseur
		var drapeau: Texture2D = Cadres.texture("drapeau")
		draw_texture(drapeau, Vector2(_t(fin), cy + 6 - drapeau.get_height()))
		var curseur: Texture2D = Cadres.texture("curseur")
		draw_texture(curseur, Vector2(_t(xc - curseur.get_width() / 2.0), cy - curseur.get_height() / 2.0))

	func _t(x: float) -> float:
		return roundf(x / 3.0) * 3.0


# --- Étiquette « MA MAISON » ----------------------------------------------------------------------

func _construire_etiquette() -> void:
	etiquette = Cadres.panneau("etiquette")
	etiquette.name = "EtiquetteMaison"
	var st: StyleBoxTexture = Cadres.style("etiquette").duplicate()
	st.content_margin_left = 18
	st.content_margin_right = 18
	st.content_margin_top = 3
	st.content_margin_bottom = 3
	etiquette.add_theme_stylebox_override("panel", st)
	etiquette.self_modulate = Color(1, 1, 1, 0.94)
	etiquette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	etiquette.add_child(Cadres.etiquette("MA MAISON", Polices.pixelify(500), 28, "creme"))
	add_child(etiquette)
	move_child(etiquette, 0)    # sous les bandes du HUD


func _placer_etiquette() -> void:
	if etiquette == null or vue == null or rue == null:
		return
	etiquette.size = etiquette.get_combined_minimum_size()
	var p := vue.monde_vers_ecran(rue.point_etiquette_maison())
	etiquette.position = (p - etiquette.size / 2.0).round()


## Centre de l'étiquette (px virtuels) et bande de la chaussée à l'écran (y haut, y bas).
func controle_etiquette() -> Dictionary:
	var c := etiquette.position + etiquette.size / 2.0
	var haut := vue.monde_vers_ecran(Vector2(0, RuePx0.SOL + RuePx0.TROTTOIR)).y
	var bas := vue.monde_vers_ecran(Vector2(0, RuePx0.BAS_CHAUSSEE)).y
	var cible := vue.monde_vers_ecran(rue.point_etiquette_maison())
	return {"centre": c, "haut": haut, "bas": bas, "cible": cible}


# --- Mise en page ----------------------------------------------------------------------------------

func mettre_en_page() -> void:
	var compact := get_viewport_rect().size.x < LARGEUR_COMPACTE
	_compact = compact
	bloc_baguette.visible = not compact
	b_temps[2].visible = not compact
	b_temps[3].visible = not compact
	l_cc_legende.text = "COMPTE" if compact else "COMPTE COURANT"
	l_ecart_legende.text = "VS LIVRET A" if compact else "VS TOUT AU LIVRET A"
	contenu_haut.add_theme_constant_override("separation", 15 if compact else 18)
	_appliquer_polices()
	rail.queue_redraw()
	_placer_etiquette()


func est_compact() -> bool:
	return _compact


## Police des chiffres de la date et du patrimoine : Atkinson (défaut) ou Jersey 10 (touche P).
func regler_jersey(j: bool) -> void:
	_jersey = j
	_appliquer_polices()


func jersey() -> bool:
	return _jersey


func _appliquer_polices() -> void:
	var f_date: Font = Polices.jersey() if _jersey else Polices.atkinson(700)
	var t_date := T_DATE_JERSEY if _jersey else T_DATE
	for l in [l_mois, l_annee]:
		l.add_theme_font_override("font", f_date)
		l.add_theme_font_size_override("font_size", t_date)
	l_patr.add_theme_font_override("font", Polices.jersey() if _jersey else Polices.atkinson(700))
	l_patr.add_theme_font_size_override("font_size", T_PATRIMOINE_JERSEY if _jersey else T_PATRIMOINE)


## Espaces insécables dans les montants (comme Format).
static func _n(s: String) -> String:
	return s.replace(" ", Format.ESPACE)


# --- Contrôles -------------------------------------------------------------------------------------

## Textes du HUD (barre, frise, étiquette), visibles.
func textes() -> Array:
	var out := []
	for racine in [contenu_haut, contenu_bas, etiquette]:
		_collecter(racine, out)
	return out


func _collecter(n: Node, out: Array) -> void:
	if n is CanvasItem and not n.is_visible_in_tree():
		return
	if n is Label or (n is Button and n.text != ""):
		out.append(n)
	for c in n.get_children():
		_collecter(c, out)


## « PX0 hud … » : plus petite taille en Pixelify, tailles du compte et du patrimoine, textes hors de
## leur bande (coupés) et chevauchements entre textes.
func lignes_controle() -> PackedStringArray:
	var pix_min := 999
	var hors := 0
	var chevauche := 0
	var rects := []
	var noms_hors := []
	var ecran := get_viewport_rect()
	# Tous les éléments (textes, boutons, rail) dans leur bande
	var elements: Array = textes() + b_temps.filter(func(b: Button) -> bool: return b.is_visible_in_tree()) + [b_menu, rail]
	for c in elements:
		var r: Rect2 = c.get_global_rect()
		var bande := Rect2(0, 0, ecran.size.x, HAUT) if contenu_haut.is_ancestor_of(c) else (
			Rect2(0, ecran.size.y - BAS, ecran.size.x, BAS) if contenu_bas.is_ancestor_of(c) else ecran)
		if not bande.encloses(r.grow(-0.5)) or (c is Label and c.get_minimum_size().x > r.size.x + 0.5):
			hors += 1
			noms_hors.append(String(c.name) if not (c is Label) else String(c.text).left(12))
	for t in textes():
		var c := t as Control
		var f: Font = c.get_theme_font("font")
		var taille: int = c.get_theme_font_size("font_size")
		if Polices.est_pixelify(f):
			pix_min = mini(pix_min, taille)
		var r := c.get_global_rect()
		for autre in rects:
			if r.grow(-1.0).intersects(autre):
				chevauche += 1
		rects.append(r)
	var e := controle_etiquette()
	var dans: bool = e["centre"].y >= e["haut"] and e["centre"].y <= e["bas"] and absf(e["centre"].x - e["cible"].x) <= 1.0
	var valeurs := []
	for l in [l_mois, l_annee, l_cc, l_patr, l_evolution, l_ecart]:
		valeurs.append(String(l.text).replace(Format.ESPACE, " "))
	return PackedStringArray([
		"PX0 hud pixelify_min=%d compte=%d patrimoine=%d" % [pix_min, l_cc.get_theme_font_size("font_size"), l_patr.get_theme_font_size("font_size")],
		"PX0 hud mise_en_page=%s textes=%d hors_bande=%d%s chevauchements=%d police_chiffres=%s" % ["compacte" if _compact else "pc", rects.size(), hors, "" if noms_hors.is_empty() else " (" + ", ".join(noms_hors) + ")", chevauche, "jersey" if _jersey else "atkinson"],
		"PX0 hud valeurs=%s baguette=%s frise=%d-%d curseur=mai_%d" % ["|".join(valeurs), "visible" if bloc_baguette.visible else "masquee", FRISE_DEBUT, FRISE_FIN, FRISE_DEBUT + floori(CURSEUR_MOIS / 12.0)],
		"PX0 etiquette maison centre=%d,%d chaussee_y=%d-%d sur_chaussee=%s" % [roundi(e["centre"].x), roundi(e["centre"].y), roundi(e["haut"]), roundi(e["bas"]), "oui" if dans else "non"],
	])
