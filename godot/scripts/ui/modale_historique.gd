class_name ModaleHistorique
extends RefCounted
## Morceau de Modales (T9) : l'historique des pop-ups (retour du joueur du 27/10/2026) et la relecture
## d'une notification. Le filtre et le défilement courants restent dans la façade (lus par principal.gd).

const NOMS_SOURCES := {"maison": "MA MAISON", "banque": "MA BANQUE", "media": "LA GAZETTE"}

var m: Modales
var _defile: ScrollContainer = null
var _appui := Vector2(-1, -1)


func _init(modales: Modales) -> void:
	m = modales


## Tout ce qui est apparu au joueur, du plus récent au plus ancien : date, source (couleur et pictogramme),
## titre, résumé d'une ligne, choix fait ou montant. Filtre par source ; toucher une ligne la rouvre en
## lecture seule (fermeture avec l'id « ouvrir:<indice> »). On ne superpose pas deux fenêtres : la relecture
## remplace l'historique, qui revient ensuite au même filtre et au même défilement.
func ouvrir(e: EtatPartie, filtre := "", defilement := 0) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "historique"
	m.historique_filtre = filtre
	m.assombrir(0.45)
	var t := m.get_viewport_rect().size
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.panneau(20))
	var largeur := minf(1500.0, t.x - 30.0)
	p.custom_minimum_size = Vector2(largeur, t.y - (24.0 if compact else 80.0))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6 if compact else 12)
	p.add_child(v)
	# En-tête : titre, nombre d'entrées, croix
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 16)
	var lt := Style.label("HISTORIQUE", 22 if compact else 24, Style.capitales(), Style.TEXTE)
	lt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(lt)
	var ls := Style.label("tout ce qui vous est arrivé, du plus récent au plus ancien", 18 if compact else 20, Style.ui(), Style.TEXTE_2)
	ls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ls.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ls.clip_text = true
	ls.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	tete.add_child(ls)
	if not compact:
		var lp := Style.label("le temps est en pause", 20, Style.ui(), Style.GEL)
		lp.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tete.add_child(lp)
	var x := Button.new()
	x.custom_minimum_size = Vector2(72 if compact else 80, 64 if compact else 72)
	x.draw.connect(ModaleOutils.dessiner_croix.bind(x))
	x.pressed.connect(m.fermer.bind("fermer"))
	tete.add_child(x)
	v.add_child(tete)
	# Filtres : tout, maison, banque, média (avec le nombre d'entrées)
	var filtres := HBoxContainer.new()
	filtres.add_theme_constant_override("separation", 8)
	var groupe := ButtonGroup.new()
	for f in ["", "maison", "banque", "media"]:
		var n := e.historique_recent(f).size()
		var b := Button.new()
		b.text = ("TOUT" if f == "" else str(NOMS_SOURCES[f])) + "  " + str(n)
		b.toggle_mode = true
		b.button_group = groupe
		b.theme_type_variation = "BoutonBascule"
		b.custom_minimum_size = Vector2(0, 60 if compact else 64)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_override("font", Style.capitales())
		b.add_theme_font_size_override("font_size", 18 if compact else 20)
		if f != "":
			b.add_theme_color_override("font_color", Style.SOURCES[f])
			b.add_theme_color_override("font_hover_color", Style.SOURCES[f].lightened(0.2))
		b.set_pressed_no_signal(f == filtre)
		b.toggled.connect(_on_filtre_bascule.bind(e, f))
		b.name = "Filtre_" + (f if f != "" else "tout")
		filtres.add_child(b)
	v.add_child(filtres)
	# Liste défilante
	_defile = ScrollContainer.new()
	_defile.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_defile.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_defile.custom_minimum_size = Vector2(largeur - 40.0, 0)
	v.add_child(_defile)
	var liste := VBoxContainer.new()
	liste.add_theme_constant_override("separation", 6 if compact else 8)
	liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	liste.name = "Liste"
	_defile.add_child(liste)
	_remplir(e, liste, largeur - 64.0)
	v.add_child(Style.label("Touchez une ligne pour la relire telle qu'elle est apparue (sans rejouer la décision).", 16 if compact else 18, Style.ui(), Style.TEXTE_2))
	m.poser(p)
	await m.centrer(p)
	if not is_instance_valid(p):
		return
	_defile.scroll_vertical = defilement
	m.apparaitre(p)


func _on_filtre_bascule(allume: bool, e: EtatPartie, f: String) -> void:
	if allume:
		_filtrer(e, f)


func _filtrer(e: EtatPartie, f: String) -> void:
	m.historique_filtre = f
	if _defile == null or not is_instance_valid(_defile):
		return
	var liste := _defile.get_node("Liste") as VBoxContainer
	for c in liste.get_children():
		liste.remove_child(c)
		c.queue_free()
	_remplir(e, liste, _defile.custom_minimum_size.x - 24.0)
	_defile.scroll_vertical = 0


func _remplir(e: EtatPartie, liste: VBoxContainer, largeur: float) -> void:
	var entrees := e.historique_recent(m.historique_filtre)
	if entrees.is_empty():
		liste.add_child(Style.label("Rien pour l'instant : les appels, les nouvelles et les courriers se rangeront ici.", 22, Style.ui(), Style.TEXTE_2))
		return
	for h: Dictionary in entrees:
		liste.add_child(_ligne(e, h, largeur))


func _ligne(e: EtatPartie, h: Dictionary, largeur: float) -> Control:
	var compact := m.compact
	var a := e.ab_de(int(h["m"]))
	var source := str(h["source"])
	var coul: Color = Style.SOURCES.get(source, Style.ACCENT)
	var p := PanelContainer.new()
	var s := Style.boite(Style.PANNEAU_ELEVE, 12, 14, 6 if compact else 8)
	Style.bordure(s, coul, 6, 0, 0, 0)
	p.add_theme_stylebox_override("panel", s)
	p.mouse_filter = Control.MOUSE_FILTER_PASS   # le glisser fait défiler la liste ; un toucher bref ouvre
	p.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	p.custom_minimum_size = Vector2(largeur, 76 if compact else 84)
	p.gui_input.connect(_on_ligne.bind(int(h["i"])))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 14)
	hb.mouse_filter = Control.MOUSE_FILTER_PASS
	p.add_child(hb)
	hb.add_child(ModaleOutils.pictogramme_source(source, 48.0 if compact else 52.0))
	var date := Style.label(Dates.texte_court(a), 18 if compact else 20, Style.chiffres(), Style.TEXTE_2)
	date.custom_minimum_size.x = 96 if compact else 110
	date.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(date)
	var vt := VBoxContainer.new()
	vt.add_theme_constant_override("separation", -2)
	vt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vt.mouse_filter = Control.MOUSE_FILTER_PASS
	var titre := Style.label(str(h["titre"]), 20 if compact else 22, Style.ui_gras(), Style.TEXTE)
	var resume := Style.label(str(h["resume"]), 17 if compact else 19, Style.ui(), Style.TEXTE_2)
	for l: Label in [titre, resume]:
		l.clip_text = true
		l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		l.custom_minimum_size.x = 10
		vt.add_child(l)
	hb.add_child(vt)
	# À droite : le choix fait et le montant en jeu
	var vd := VBoxContainer.new()
	vd.add_theme_constant_override("separation", -2)
	vd.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vd.custom_minimum_size.x = 200 if compact else 250
	if str(h.get("choix", "")) != "":
		var lc := Style.label(str(h["choix"]), 17 if compact else 19, Style.ui_gras(), Style.ACCENT)
		lc.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lc.clip_text = true
		lc.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		vd.add_child(lc)
	if h.get("a_montant", false):
		var mt := float(h["montant"])
		var txt := Format.montant(mt, a, false, true)
		if str(h.get("suffixe", "")) != "":
			txt += " " + str(h["suffixe"])
		var lm := Style.label(txt, 18 if compact else 20, Style.chiffres(), Style.GAIN if mt > 0.0 else (Style.PERTE if mt < 0.0 else Style.TEXTE_2))
		lm.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lm.clip_text = true
		lm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		vd.add_child(lm)
	hb.add_child(vd)
	return p


## Toucher bref (sans glisser) sur une ligne : la rouvrir. Le glisser est laissé au défilement.
func _on_ligne(ev: InputEvent, i: int) -> void:
	var b := ev as InputEventMouseButton
	if b == null or b.button_index != MOUSE_BUTTON_LEFT:
		return
	if b.pressed:
		_appui = b.global_position
	elif _appui.x >= 0.0 and b.global_position.distance_to(_appui) < 14.0:
		_appui = Vector2(-1, -1)
		m.historique_defilement = _defile.scroll_vertical if is_instance_valid(_defile) else 0
		m.fermer("ouvrir:%d" % i)


## Relecture d'une notification de l'historique (message du banquier, nouvelle, petit courrier…).
func lecture_notification(h: Dictionary, a: int) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "info"
	m.assombrir(0.45)
	var n: Dictionary = h.get("contenu", {})
	var source := str(h.get("source", "banque"))
	var coul: Color = Style.SOURCES.get(source, Style.ACCENT)
	var p := PanelContainer.new()
	var s := Style.boite(Style.PANNEAU_ELEVE, 18, 28, 20)
	Style.bordure(s, coul, 10, 0, 0, 0)
	Style.ombre(s, Color(0, 0, 0, 0.6), 20, Vector2(0, 8))
	p.add_theme_stylebox_override("panel", s)
	p.custom_minimum_size = Vector2(minf(980.0, m.get_viewport_rect().size.x - 60.0), 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 14)
	tete.add_child(ModaleOutils.pictogramme_source(source, 52.0))
	var src := Style.label(str(NOMS_SOURCES.get(source, "")) + " · " + Dates.texte(a).to_upper(), 20, Style.capitales(), coul)
	src.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	src.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(src)
	v.add_child(tete)
	var titre := Style.label(str(n.get("titre", h.get("titre", ""))), 30 if not compact else 26, Style.ui_gras())
	titre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(titre)
	var texte := Style.label(str(n.get("texte", "")), 24 if not compact else 22, Style.ui(), Style.TEXTE)
	texte.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(texte)
	if h.get("a_montant", false):
		var mt := float(h["montant"])
		v.add_child(Style.label(Format.montant(mt, a, false, true), 30, Style.chiffres(), Style.GAIN if mt >= 0.0 else Style.PERTE))
	var ok := Style.bouton("FERMER")
	ok.pressed.connect(m.fermer.bind("fermer"))
	v.add_child(ok)
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)
	if is_instance_valid(p):
		m.apparaitre(p)
