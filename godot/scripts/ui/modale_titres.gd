class_name ModaleTitres
extends RefCounted
## Morceau de Modales : la collection des titres d'époque (lot 07-I, docs/29 §3). Fenêtre de lecture : une grille 3 × 3,
## les titres obtenus avec leur nombre et leur première date, les autres en « ??? » sans aucun indice sur la condition.
## Échap, clic extérieur et FERMER la ferment. Ouverte depuis l'écran titre (bouton TITRES, touche T).

var m: Modales
var infos := {}   # contrôles : tuiles, obtenus, non_obtenus


func _init(modales: Modales) -> void:
	m = modales


## date « AAAA-MM-JJ » → « jj/mm/aaaa »
static func date_texte(iso: String) -> String:
	var p := iso.split("-")
	return "%s/%s/%s" % [p[2], p[1], p[0]] if p.size() == 3 else iso


## records : Records.lire() ; tous : Titres.tous() (9 × {id, nom, ordre}). par_chapitre : [{id, annees, titres}] quand plusieurs chapitres
## sont ouverts (lot 10b, I7 ; docs/40 §3.4) : un onglet par chapitre, chacun avec sa collection ; sinon la fenêtre de toujours.
func ouvrir(records: Dictionary, tous: Array, par_chapitre: Array = []) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "titres"
	m.assombrir(0.65)
	var multi := par_chapitre.size() > 1
	var coll: Dictionary = records.get("collection", {})
	if multi:
		tous = par_chapitre[0]["titres"]
		coll = _collection(records, str(par_chapitre[0]["id"]))
	var p := PanelContainer.new()
	p.name = "Collection"
	var sf := Style.panneau(22)
	sf.content_margin_left = 24 if compact else 36
	sf.content_margin_right = 24 if compact else 36
	sf.content_margin_top = 12 if compact else 24
	sf.content_margin_bottom = 12 if compact else 24
	p.add_theme_stylebox_override("panel", sf)
	var vue := m.get_viewport_rect().size
	var largeur := minf(1260.0 if not compact else 1356.0, vue.x - 40.0)
	var interieur := largeur - (48.0 if compact else 72.0)
	p.custom_minimum_size = Vector2(largeur, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10 if compact else 16)
	p.add_child(v)
	# En-tête : titre, compteur, FERMER à droite (une ligne au téléphone)
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 18)
	var lt := Style.label("LES TITRES D'ÉPOQUE", 28 if compact else 36, Style.capitales(), Style.TEXTE)
	tete.add_child(lt)
	var lc := Style.label("", 22 if compact else 24, Style.ui_gras(), Style.ACCENT)
	lc.name = "Compteur"
	lc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(lc)
	var fermer := Style.bouton("FERMER", false, 78 if compact else 81)
	fermer.custom_minimum_size.x = 200
	fermer.pressed.connect(m.fermer.bind("fermer"))
	tete.add_child(fermer)
	v.add_child(tete)
	# Onglets par chapitre (plusieurs chapitres ouverts seulement)
	var onglets: Array = []
	if multi:
		var rangee := HBoxContainer.new()
		rangee.name = "Onglets"
		rangee.add_theme_constant_override("separation", 10)
		var groupe := ButtonGroup.new()
		for c: Dictionary in par_chapitre:
			var b := Button.new()
			b.name = "Onglet_%s" % str(c["id"])
			b.text = str(c["annees"])
			b.toggle_mode = true
			b.button_group = groupe
			b.theme_type_variation = "BoutonBascule"
			b.focus_mode = Control.FOCUS_NONE
			b.custom_minimum_size = Vector2(240, 72 if compact else 81)
			b.set_pressed_no_signal(onglets.is_empty())
			onglets.append(b)
			rangee.add_child(b)
		v.add_child(rangee)
	if not compact:
		v.add_child(Style.label("Un titre par partie terminée, selon votre façon de jouer.", 20, Style.ui(), Style.TEXTE_2))
	# Grille 3 × 3, dans l'ordre 1 → 9
	var ecart := 12 if compact else 18
	var grille := GridContainer.new()
	grille.name = "Grille"
	grille.columns = 3
	grille.add_theme_constant_override("h_separation", ecart)
	grille.add_theme_constant_override("v_separation", ecart)
	var lt_tuile := floorf((interieur - 2.0 * ecart) / 3.0)
	var ht_tuile := (120.0 if multi else 138.0) if compact else 168.0   # téléphone avec onglets : la rangée d'onglets prend la place
	var remplir := func(liste: Array, c: Dictionary) -> void:
		for n in grille.get_children():
			grille.remove_child(n)
			n.queue_free()
		var n_obt := 0
		for t: Dictionary in liste:
			var id := str(t["id"])
			var ligne: Dictionary = c.get(id, {})
			var ok := not ligne.is_empty()
			if ok:
				n_obt += 1
			grille.add_child(_tuile(t, ligne, ok, lt_tuile, ht_tuile, compact))
		lc.text = "%d SUR %d OBTENUS" % [n_obt, liste.size()]
		infos = {"tuiles": liste.size(), "obtenus": n_obt, "non_obtenus": liste.size() - n_obt, "onglets": onglets.size()}
	remplir.call(tous, coll)
	for i in onglets.size():
		(onglets[i] as Button).pressed.connect(func() -> void:
			remplir.call(par_chapitre[i]["titres"], _collection(records, str(par_chapitre[i]["id"]))))
	v.add_child(grille)
	if compact and not multi:
		v.add_child(Style.label("Un titre par partie terminée, selon votre façon de jouer.", 20, Style.ui(), Style.TEXTE_2))
	m.poser(p)
	await m.centrer(p)
	m.apparaitre(p)


## Collection d'un chapitre dans Records.lire() ({} sans données).
static func _collection(records: Dictionary, id: String) -> Dictionary:
	return ((records.get("chapitres", {}) as Dictionary).get(id, {}) as Dictionary).get("collection", {})


func _tuile(t: Dictionary, ligne: Dictionary, ok: bool, larg: float, haut: float, compact: bool) -> Control:
	var pc := PanelContainer.new()
	pc.name = "Tuile_%s" % str(t["id"])
	pc.custom_minimum_size = Vector2(larg, haut)
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.set_border_width_all(3)
	sb.set_content_margin_all(12)
	if ok:
		sb.bg_color = Color(Style.PANNEAU_OPAQUE, 0.95)
		sb.border_color = PalettePixel.couleur("zinc_clair")
	else:
		sb.bg_color = Color(0, 0, 0, 0)
		sb.border_color = Color(PalettePixel.couleur("zinc_clair"), 0.45)
	pc.add_theme_stylebox_override("panel", sb)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	pc.add_child(h)
	var num := PanelContainer.new()
	num.custom_minimum_size = Vector2(36, 36)
	num.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var nb := StyleBoxFlat.new()
	nb.bg_color = Style.ENCRE
	num.add_theme_stylebox_override("panel", nb)
	var ln := Style.label(str(int(t["ordre"])), 22, Style.ui_gras(), Style.TEXTE)
	ln.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num.add_child(ln)
	h.add_child(num)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	col.custom_minimum_size.x = larg - 24.0 - 48.0
	h.add_child(col)
	if ok:
		var nom := Style.label(str(t["nom"]).to_upper(), 22 if compact else 24, Style.ui_gras(), Style.TEXTE)
		nom.name = "Nom"
		nom.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nom.custom_minimum_size.x = larg - 24.0 - 48.0
		nom.max_lines_visible = 2
		nom.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		col.add_child(nom)
		var n := int(ligne.get("nombre", 1))
		col.add_child(Style.label("Obtenu %d fois" % n if n > 1 else "Obtenu 1 fois", 20, Style.ui(), Style.TEXTE))
		col.add_child(Style.label("1re fois : %s" % date_texte(str(ligne.get("premiere", ""))), 20, Style.ui(), Style.TEXTE_2))
	else:
		var q := Style.label("???", 24, Style.ui_gras(), Style.TEXTE_2)
		q.name = "Inconnu"
		col.add_child(q)
	return pc
