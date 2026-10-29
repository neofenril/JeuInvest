class_name Modales
extends Control
## Les papiers et cartes posés devant la ville (calque 5) : journal (04 §3.5), courrier (04 §3.6),
## carte de présentation du banquier (13 §1), fenêtre Banque (13 §2), fin de démonstration (13 §4.3),
## confirmation, panneaux d'information.
## Chaque modale émet choix_fait(genre, id) à sa fermeture.

signal choix_fait(genre: String, id: String)

var fond: ColorRect
var courant: Control = null
var genre_courant := ""
var compact := false
var _boutons_actifs := true
var _choix_journal: Array = []
var _parler := 0.0
var _portrait: Portrait = null
var _choix_exterieur := "plus_tard"
var banque: PanneauBanque = null
var _carte_retournee := false
var donnees_demo: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = Style.theme()
	fond = ColorRect.new()
	fond.color = Color(0, 0, 0, 0)
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fond.gui_input.connect(_on_fond)
	add_child(fond)


## Clic ou toucher en dehors de la modale (sur le fond assombri) : ferme les pop-ups de consultation
## comme leur croix ou leur bouton Fermer. Le journal, le courrier et la fin exigent un choix
## explicite (sinon on esquiverait la décision) : la feuille frémit pour le rappeler.
## Le toucher arrive ici en clic émulé (emulate_mouse_from_touch, réglage par défaut).
func _on_fond(event: InputEvent) -> void:
	var b := event as InputEventMouseButton
	if b == null or not b.pressed or b.button_index != MOUSE_BUTTON_LEFT or courant == null:
		return
	fond.accept_event()
	match genre_courant:
		"appel":
			fermer(_choix_exterieur)
		"info", "historique":
			fermer("fermer")
		"menu":
			fermer("reprendre")
		"confirmer":
			fermer("non")
		"banque":
			banque.fermer_demande.emit()
		_:
			_fremir(courant)


func _fremir(p: Control) -> void:
	if Juice.animations_reduites or p.has_meta("fremit") or (genre_courant == "journal" and not _boutons_actifs):
		return
	p.set_meta("fremit", true)
	var r0 := p.rotation
	var t := p.create_tween()
	for k in 4:
		t.tween_property(p, "rotation", r0 + deg_to_rad(1.2 if k % 2 == 0 else -1.2), 0.05)
	t.tween_property(p, "rotation", r0, 0.05)
	t.tween_callback(func() -> void: p.remove_meta("fremit"))


func ouverte() -> bool:
	return courant != null


func _assombrir(a: float) -> void:
	fond.mouse_filter = Control.MOUSE_FILTER_STOP if a > 0.0 else Control.MOUSE_FILTER_IGNORE
	create_tween().tween_property(fond, "color:a", a, 0.2)


## Les libellés à retour à la ligne d'une colonne pleine largeur reçoivent une largeur explicite :
## sans elle, leur hauteur minimale est calculée pour une largeur nulle (panneau démesuré).
func _fixer_largeurs(p: PanelContainer) -> void:
	var sb := p.get_theme_stylebox("panel")
	var largeur := p.custom_minimum_size.x - sb.content_margin_left - sb.content_margin_right
	for n in p.find_children("*", "Label", true, false):
		var l := n as Label
		if l.autowrap_mode != TextServer.AUTOWRAP_OFF and l.custom_minimum_size.x <= 0.0 and l.get_parent() is VBoxContainer:
			l.custom_minimum_size.x = largeur
		elif l.autowrap_mode != TextServer.AUTOWRAP_OFF and l.custom_minimum_size.x <= 0.0:
			l.custom_minimum_size.x = largeur * 0.6


## Attend la mise en page (les libellés à retour à la ligne ne se mesurent qu'après), puis centre.
func _centrer(p: Control) -> void:
	p.mouse_filter = Control.MOUSE_FILTER_STOP   # un clic sur la feuille elle-même ne la ferme pas
	p.visible = false
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(p):
		return
	p.visible = true
	p.reset_size()
	var t := get_viewport_rect().size
	p.position = (t - p.size) / 2.0
	p.pivot_offset = p.size / 2.0


func fermer(id := "") -> void:
	if courant == null:
		return
	var p := courant
	var g := genre_courant
	courant = null
	genre_courant = ""
	_assombrir(0.0)
	var t := p.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(p, "position:y", p.position.y + 120.0, 0.3)
	t.tween_property(p, "rotation", p.rotation + deg_to_rad(8.0), 0.3)
	t.tween_property(p, "modulate:a", 0.0, 0.3)
	t.chain().tween_callback(p.queue_free)
	choix_fait.emit(g, id)


func _process(delta: float) -> void:
	if _portrait != null and is_instance_valid(_portrait):
		_parler = maxf(0.0, _parler - delta)
		_portrait.bouche = (0.5 + 0.5 * sin(Time.get_ticks_msec() / 45.0)) if _parler > 0.0 else 0.0
		_portrait.queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo or courant == null:
		return
	if genre_courant == "journal" and _boutons_actifs:
		var n := k.keycode - KEY_1
		if n >= 0 and n < _choix_journal.size():
			_on_choix_journal(_choix_journal[n])
			get_viewport().set_input_as_handled()
		elif k.keycode == KEY_ESCAPE:
			_on_choix_journal("rien" if _choix_journal.has("rien") else "ecart")
			get_viewport().set_input_as_handled()
	elif k.keycode == KEY_ESCAPE and genre_courant in ["appel", "info", "menu", "banque", "confirmer", "historique"]:
		if genre_courant == "banque":
			banque.fermer_demande.emit()
		else:
			fermer({"appel": _choix_exterieur, "confirmer": "non", "menu": "reprendre"}.get(genre_courant, "fermer"))
		get_viewport().set_input_as_handled()


# =====================================================================
# Journal (événement de marché)
# =====================================================================

## lecture_choix : relecture depuis l'historique (pas de décision : le choix fait, et FERMER).
func journal(c: Dictionary, depart: Vector2, spectaculaire: bool, lecture_choix := "") -> void:
	compact = Ecran.compact()
	var lecture := lecture_choix != ""
	genre_courant = "info" if lecture else "journal"
	_assombrir(0.6)
	var t := get_viewport_rect().size
	var p := PanelContainer.new()
	var s := Style.boite(Style.JOURNAL, 2, 24 if compact else 36, 18 if compact else 28)
	Style.ombre(s, Color(0, 0, 0, 0.7), 30, Vector2(6, 14))
	p.add_theme_stylebox_override("panel", s)
	p.custom_minimum_size = Vector2(minf(1100.0, t.x - 80.0), 0)
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/papier.gdshader")
	p.material = mat
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6 if compact else 10)
	p.add_child(v)
	# Bandeau : SPÉCIAL · nom du journal · prix
	var tete := HBoxContainer.new()
	var ruban := PanelContainer.new()
	ruban.add_theme_stylebox_override("panel", Style.boite(Style.ENCRE_ROUGE, 3, 12, 2))
	ruban.add_child(Style.label(str(donnees_demo.get("journal", {}).get("bandeau", "SPÉCIAL")), 22, Style.manchette(), Color.WHITE))
	ruban.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(ruban)
	var nom := Style.label(str(donnees_demo.get("journal", {}).get("nom", "LA GAZETTE")), 40 if compact else 52, Style.titre_journal(), Style.ENCRE)
	nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tete.add_child(nom)
	var prix := Style.label(str(donnees_demo.get("journal", {}).get("prix", "")), 22, Style.journal(), Style.ENCRE)
	prix.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(prix)
	v.add_child(tete)
	v.add_child(_filet(Style.ENCRE, 3))
	var ligne_date := HBoxContainer.new()
	ligne_date.add_child(Style.label(str(c.get("date_journal", c.get("date", ""))).to_upper(), 20, Style.capitales(), Style.ENCRE))
	var ed := Style.label("ÉDITION SPÉCIALE", 20, Style.capitales(), Style.ENCRE_ROUGE)
	ed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ed.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ligne_date.add_child(ed)
	v.add_child(ligne_date)
	v.add_child(_filet(Style.ENCRE, 1))
	# Manchette qui s'imprime
	var manchette := Style.label(str(c["titre"]).to_upper(), 50 if compact else 72, Style.manchette(), Style.ENCRE)
	manchette.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	manchette.add_theme_constant_override("line_spacing", -8)
	manchette.visible_ratio = 0.0
	v.add_child(manchette)
	var chapo := Style.label(str(c["texte"]), 24 if compact else 26, Style.journal(), Style.ENCRE)
	chapo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(chapo)
	# Pastille d'impact
	# Pastille d'impact, toujours sur 2 lignes voulues (encadré aux coins doux, pas une gélule) :
	# 1) ce qui a bougé (les placements en bourse), 2) ce que cela pèse sur le patrimoine total.
	var impact: Dictionary = c.get("impact", {})
	var past := PanelContainer.new()
	past.add_theme_stylebox_override("panel", Style.pastille(Style.ENCRE_ROUGE, 14, 10))
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 2)
	past.add_child(pv)
	var ph := HBoxContainer.new()
	ph.add_theme_constant_override("separation", 14)
	pv.add_child(ph)
	var a: int = c.get("ab", 0)
	var largeur_pastille := p.custom_minimum_size.x - (48.0 if compact else 72.0) - 44.0
	var seconde: Label
	if c.get("detient", false):
		var diff := float(impact.get("diff", 0.0))
		var depuis: String = Dates.MOIS[Dates.mois(int(impact.get("depuis", a))) - 1]
		ph.add_child(Style.label("VOS PLACEMENTS EN BOURSE", 20, Style.capitales(), Style.ENCRE))
		ph.add_child(_fleche(diff >= 0.0, Style.ENCRE_ROUGE))
		ph.add_child(Style.label("%s  (%s)" % [Format.montant(diff, a, false, true), Format.pct(float(impact.get("pct", 0.0)), 0)], 24, Style.chiffres(), Style.ENCRE_ROUGE))
		var l_depuis := Style.label("depuis " + depuis, 20, Style.journal(), Style.ENCRE)
		l_depuis.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ph.add_child(l_depuis)
		seconde = Style.label("Sur votre patrimoine total : %s. Votre compte et votre Livret A, eux, ne bougent pas." % Format.pct(float(impact.get("pct_patrimoine", 0.0)), 0), 20, Style.ui(), Style.ENCRE)
	else:
		ph.add_child(Style.label("Vous n'avez pas de placements en bourse : votre argent est à l'abri.", 22, Style.ui_gras(), Style.ENCRE))
		seconde = Style.label("Mais les prix sont soldés : l'indice a fait %s en un mois." % Format.pct(float(impact.get("indice_pct", 0.0)), 0), 20, Style.ui(), Style.ENCRE)
	seconde.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	seconde.custom_minimum_size.x = largeur_pastille
	pv.add_child(seconde)
	# Rappel de l'écart avec « tout au Livret A » (même vie, sans bourse) : avant et après l'événement
	if c.has("ecart_livret"):
		var ecart := float(c["ecart_livret"])
		var ecart_av := float(c.get("ecart_livret_avant", 0.0))
		var vert := Color("2f6b45")
		var lv := HBoxContainer.new()
		lv.add_theme_constant_override("separation", 10)
		var tl := Style.label("FACE À « TOUT AU LIVRET A »", 18, Style.capitales(), Style.ENCRE)
		tl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lv.add_child(tl)
		lv.add_child(_fleche(ecart >= 0.0, vert if ecart >= 0.0 else Style.ENCRE_ROUGE))
		lv.add_child(Style.label(Format.ecart(ecart, a), 24, Style.chiffres(), vert if ecart >= 0.0 else Style.ENCRE_ROUGE))
		var mois_av: String = Dates.MOIS[Dates.mois(int(c.get("ab_avant", a))) - 1]
		var la := Style.label("(fin %s : %s)" % [mois_av, Format.ecart(ecart_av, a)], 20, Style.journal(), Style.ENCRE)
		la.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lv.add_child(la)
		pv.add_child(lv)
	v.add_child(past)
	if lecture:
		var hl := HBoxContainer.new()
		hl.add_theme_constant_override("separation", 14)
		var lc := Style.label("VOTRE CHOIX : " + lecture_choix.to_upper(), 22, Style.capitales(), Style.ENCRE)
		lc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hl.add_child(lc)
		var bf := _bouton_papier("FERMER", "", compact)
		bf.custom_minimum_size.x = 260
		bf.size_flags_horizontal = Control.SIZE_SHRINK_END
		bf.pressed.connect(fermer.bind("fermer"))
		hl.add_child(bf)
		v.add_child(hl)
		add_child(p)
		courant = p
		_fixer_largeurs(p)
		await _centrer(p)
		if is_instance_valid(p):
			p.rotation = deg_to_rad(-1.0)
			manchette.visible_ratio = 1.0
			_apparaitre(p)
		return
	v.add_child(Style.label("QUE FAITES-VOUS ?", 20, Style.capitales(), Style.ENCRE))
	var zone_choix := HBoxContainer.new()
	zone_choix.add_theme_constant_override("separation", 14)
	zone_choix.name = "Choix"
	v.add_child(zone_choix)
	_choix_journal = []
	var i := 1
	for ch in c["choix"]:
		var b := _bouton_papier("%d   %s" % [i, str(ch["titre"]).to_upper()], str(ch.get("sous", "")), compact)
		b.disabled = bool(ch.get("desactive", false))
		b.pressed.connect(_on_choix_journal.bind(str(ch["id"])))
		zone_choix.add_child(b)
		_choix_journal.append(str(ch["id"]))
		i += 1
	add_child(p)
	courant = p
	_fixer_largeurs(p)
	await _centrer(p)
	# Entrée : le journal jaillit du média en tournoyant, ou tombe simplement
	var cible_pos := p.position
	var cible_rot := deg_to_rad(-1.5)
	_boutons_actifs = false
	zone_choix.modulate.a = 0.5
	var tw := p.create_tween().set_parallel(true)
	if Juice.animations_reduites:
		p.modulate.a = 0.0
		tw.tween_property(p, "modulate:a", 1.0, 0.15)
	elif spectaculaire:
		p.position = depart - p.size / 2.0
		p.scale = Vector2(0.2, 0.2)
		p.rotation = -TAU
		tw.tween_property(p, "position", cible_pos, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(p, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(p, "rotation", cible_rot, 0.7).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	else:
		p.scale = Vector2(1.8, 1.8)
		p.rotation = deg_to_rad(-12.0)
		p.modulate.a = 0.0
		tw.tween_property(p, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(p, "rotation", cible_rot, 0.45).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tw.tween_property(p, "modulate:a", 1.0, 0.15)
	tw.chain().tween_callback(_impact_journal.bind(p, manchette, spectaculaire))
	var t2 := p.create_tween()
	t2.tween_interval(1.0)
	t2.tween_callback(func() -> void: _boutons_actifs = true)
	t2.tween_property(zone_choix, "modulate:a", 1.0, 0.2)


func _impact_journal(p: Control, manchette: Label, spectaculaire: bool) -> void:
	Juice.secouer(0.5 if spectaculaire else 0.25)
	if not Juice.animations_reduites:
		var poussiere := CPUParticles2D.new()
		poussiere.position = p.position + Vector2(p.size.x / 2.0, p.size.y)
		poussiere.one_shot = true
		poussiere.explosiveness = 1.0
		poussiere.amount = 28
		poussiere.lifetime = 0.9
		poussiere.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		poussiere.emission_rect_extents = Vector2(p.size.x / 2.0, 6)
		poussiere.direction = Vector2(0, -1)
		poussiere.spread = 70.0
		poussiere.initial_velocity_min = 60.0
		poussiere.initial_velocity_max = 160.0
		poussiere.gravity = Vector2(0, 200)
		poussiere.scale_amount_min = 3.0
		poussiere.scale_amount_max = 6.0
		poussiere.color = Color("d8ccb0")
		add_child(poussiere)
		move_child(poussiere, p.get_index())
		poussiere.emitting = true
		get_tree().create_timer(1.5).timeout.connect(poussiere.queue_free)
	manchette.create_tween().tween_property(manchette, "visible_ratio", 1.0, 0.35)


## Petits journaux qui jaillissent du média (effet 2, décor) avant le journal principal.
func journaux_volants(depart: Vector2, n: int) -> void:
	if Juice.animations_reduites:
		return
	var t := get_viewport_rect().size
	for i in n:
		var j := Control.new()
		j.size = Vector2(150, 100)
		j.pivot_offset = j.size / 2.0
		j.position = depart - j.size / 2.0
		j.scale = Vector2(0.2, 0.2)
		j.draw.connect(_dessiner_petit_journal.bind(j))
		j.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(j)
		var cible := Vector2(t.x * (0.25 + 0.5 * i / maxf(1.0, n - 1.0)), t.y * (0.3 + 0.15 * (i % 2))) - j.size / 2.0
		var tw := j.create_tween().set_parallel(true)
		tw.tween_property(j, "position", cible, 0.5).set_delay(0.12 * i).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(j, "scale", Vector2(0.9, 0.9), 0.5).set_delay(0.12 * i)
		tw.tween_property(j, "rotation", TAU * (1.0 if i % 2 == 0 else -1.0), 0.5).set_delay(0.12 * i)
		tw.tween_property(j, "modulate:a", 0.0, 0.25).set_delay(0.12 * i + 0.45)
		tw.chain().tween_callback(j.queue_free)


func _dessiner_petit_journal(j: Control) -> void:
	j.draw_rect(Rect2(Vector2.ZERO, j.size), Style.JOURNAL)
	j.draw_rect(Rect2(10, 10, j.size.x - 20, 14), Style.ENCRE)
	for k in 5:
		j.draw_rect(Rect2(10, 34 + k * 12, j.size.x - 20 - (k % 2) * 30, 5), Color(Style.ENCRE, 0.5))


func _on_choix_journal(id: String) -> void:
	if not _boutons_actifs or courant == null:
		return
	if id == "vendre" and donnees_demo.has("_vente_totale"):
		_confirmer_vente()
		return
	fermer(id)


## « Tout vendre » : confirmation dans la modale (récapitulatif des frais et de l'impôt).
func _confirmer_vente() -> void:
	var zone := courant.find_child("Choix", true, false) as HBoxContainer
	if zone == null:
		fermer("vendre")
		return
	for c in zone.get_children():
		c.queue_free()
	var r: Dictionary = donnees_demo["_vente_totale"]
	var a: int = donnees_demo.get("_ab", 0)
	var txt := "Vous vendez %d ligne(s) pour %s. Frais : %s. Impôt : %s. Vous recevez %s." % [
		r["lignes"].size(), Format.montant(r["brut"], a), Format.montant(r["frais"], a), Format.montant(r["impot"], a), Format.montant(r["recu"], a)]
	var l := Style.label(txt, 22, Style.ui_gras(), Style.ENCRE)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.custom_minimum_size = Vector2(380, 0)
	zone.add_child(l)
	var ok := _bouton_papier("CONFIRMER", "Tout vendre maintenant", compact)
	ok.pressed.connect(func() -> void: fermer("vendre"))
	zone.add_child(ok)
	var non := _bouton_papier("JE RÉFLÉCHIS", "Revenir aux choix", compact)
	non.pressed.connect(func() -> void: fermer("rien"))
	zone.add_child(non)


func _bouton_papier(titre: String, sous: String, petit: bool) -> Button:
	var b := Button.new()
	b.text = titre + ("\n" + sous if sous != "" else "")
	b.custom_minimum_size = Vector2(0, 80 if petit else 96)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.focus_mode = Control.FOCUS_ALL
	b.add_theme_font_override("font", Style.ui_gras())
	b.add_theme_font_size_override("font_size", 22 if petit else 24)
	var n := Style.boite(Color("2a2722"), 10, 16, 8)
	Style.bordure(n, Color("000000"), 0, 0, 0, 4)
	var h := Style.boite(Style.ENCRE_ROUGE, 10, 16, 8)
	Style.bordure(h, Style.ENCRE_ROUGE.darkened(0.3), 0, 0, 0, 4)
	b.add_theme_stylebox_override("normal", n)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("pressed", h)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("disabled", Style.boite(Color("2a2722", 0.4), 10, 16, 8))
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(k, Style.JOURNAL)
	return b


func _filet(c: Color, epaisseur: int) -> ColorRect:
	var r := ColorRect.new()
	r.color = c
	r.custom_minimum_size = Vector2(0, epaisseur)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


## Petite flèche ▲ / ▼ dessinée (pas de caractère Unicode, 09 §3).
func _fleche(haut: bool, c: Color) -> Control:
	var f := Control.new()
	f.custom_minimum_size = Vector2(18, 24)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	f.draw.connect(_dessiner_fleche.bind(f, haut, c))
	return f


func _dessiner_fleche(f: Control, haut: bool, c: Color) -> void:
	var m := f.size / 2.0
	var pts := PackedVector2Array([m + Vector2(-8, 5), m + Vector2(8, 5), m + Vector2(0, -8)]) if haut else PackedVector2Array([m + Vector2(-8, -5), m + Vector2(8, -5), m + Vector2(0, 8)])
	f.draw_colored_polygon(pts, c)


# =====================================================================
# Courrier (événement de vie)
# =====================================================================

## lecture_choix / ab_lecture : relecture depuis l'historique (le choix fait et la date d'alors, FERMER).
func courrier(c: Dictionary, depart: Vector2, e: EtatPartie, lecture_choix := "", ab_lecture := -1) -> void:
	compact = Ecran.compact()
	var lecture := lecture_choix != ""
	genre_courant = "info" if lecture else "courrier"
	_assombrir(0.6)
	var a := ab_lecture if lecture else e.ab_courant()
	var montant := float(c.get("montant", 0.0))
	var naissance: bool = c.get("effet", "") == "naissance"
	var bonne := montant > 0.0
	var p := PanelContainer.new()
	var s := Style.boite(Style.COURRIER, 6, 28, 22 if compact else 28)
	Style.bordure(s, Color("f2a7c3") if naissance else (Style.GAIN if bonne else Style.PERTE), 10, 0, 0, 0)
	Style.ombre(s, Color(0, 0, 0, 0.6), 24, Vector2(4, 10))
	p.add_theme_stylebox_override("panel", s)
	p.custom_minimum_size = Vector2(780, 0)
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/papier.gdshader")
	mat.set_shader_parameter("bruit", 0.03)
	mat.set_shader_parameter("fibres", 0.0)
	p.material = mat
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8 if compact else 12)
	p.add_child(v)
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 12)
	var env := Control.new()
	env.custom_minimum_size = Vector2(40, 30)
	env.draw.connect(_dessiner_enveloppe.bind(env, Color("6b6458")))
	env.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(env)
	var lt := Style.label(("FAIRE-PART · " if naissance else "COURRIER · ") + Dates.texte(a).to_upper(), 20, Style.capitales(), Color("6b6458"))
	lt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(lt)
	var timbre := Control.new()
	timbre.custom_minimum_size = Vector2(96, 104)
	timbre.draw.connect(_dessiner_timbre.bind(timbre, str(c.get("picto", ""))))
	tete.add_child(timbre)
	v.add_child(tete)
	var titre := Style.label(str(c["titre"]).to_upper(), 34, Style.ui_gras(), Style.ENCRE)
	titre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(titre)
	var txt := Style.label(str(c["texte"]), 26, Style.ui(), Style.ENCRE)
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(txt)
	# Situation du compte
	var cc := e.joueur.cc
	var info: Label
	if lecture:
		var t_lec := "Votre choix : " + lecture_choix
		if not naissance and absf(montant) > 0.004:
			t_lec += "  ·  " + Format.montant(montant, a, false, true)
		info = Style.label(t_lec, 24, Style.ui_gras(), Color("4a463e"))
	elif naissance:
		var reste := float(c.get("reste_apres", 0.0))
		var t_info := "Dépenses du mois : %s → %s.  Il vous restera %s par mois." % [
			Format.montant(float(c.get("depenses_avant", 0.0)), a), Format.montant(float(c.get("depenses_apres", 0.0)), a), Format.montant(reste, a)]
		if reste < 0.0:
			t_info += " Le budget du mois devient négatif : il faudra puiser dans l'épargne."
		info = Style.label(t_info, 24, Style.ui_gras() if reste < 0.0 else Style.ui(), Style.ENCRE_ROUGE if reste < 0.0 else Color("4a463e"))
	elif bonne:
		info = Style.label("Versée sur votre compte courant.", 24, Style.ui(), Color("2f6b45"))
	elif cc >= -montant:
		var dep := float(e.depenses()["total"])
		var c0 := (maxf(0.0, cc) + e.joueur.livret) / dep
		var c1 := (maxf(0.0, cc + montant) + e.joueur.livret) / dep
		info = Style.label("Compte courant : %s.  Votre coussin passe de %s à %s mois." % [Format.montant(cc, a), Format.nombre(c0, 1), Format.nombre(c1, 1)], 24, Style.ui(), Color("4a463e"))
	else:
		info = Style.label("Compte courant : %s.  Il manque %s." % [Format.montant(cc, a), Format.montant(-montant - cc, a)], 24, Style.ui_gras(), Style.ENCRE_ROUGE)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(info)
	var boutons: BoxContainer = VBoxContainer.new() if c["choix"].size() > 1 and not lecture else HBoxContainer.new()
	boutons.add_theme_constant_override("separation", 10)
	if lecture:
		var bf := _bouton_papier("FERMER", "", compact)
		bf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bf.pressed.connect(fermer.bind("fermer"))
		boutons.add_child(bf)
		v.add_child(boutons)
		add_child(p)
		courant = p
		_fixer_largeurs(p)
		await _centrer(p)
		if is_instance_valid(p):
			p.rotation = deg_to_rad(1.0)
			_apparaitre(p)
		return
	for ch in c["choix"]:
		var titre_b := str(ch["titre"]).to_upper()
		if ch["id"] == "payer":
			titre_b = "PAYER " + Format.montant(-montant, a)
		var texte_b := titre_b + ("\n" + str(ch.get("sous", "")) if ch["id"] != "payer" and ch.get("sous", "") != "" else "")
		var b: Button = Style.bouton(texte_b, true) if ch == c["choix"][0] else _bouton_papier(texte_b, "", false)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.disabled = bool(ch.get("desactive", false))
		b.pressed.connect(fermer.bind(str(ch["id"])))
		boutons.add_child(b)
	v.add_child(boutons)
	add_child(p)
	courant = p
	_fixer_largeurs(p)
	await _centrer(p)
	# Entrée : l'enveloppe vole de la maison vers le centre, puis la lettre glisse du bas
	var cible := p.position
	p.rotation = deg_to_rad(1.0)
	if Juice.animations_reduites:
		p.modulate.a = 0.0
		p.create_tween().tween_property(p, "modulate:a", 1.0, 0.15)
		return
	p.visible = false
	var enveloppe := Control.new()
	enveloppe.size = Vector2(180, 120)
	enveloppe.pivot_offset = enveloppe.size / 2.0
	enveloppe.position = depart - enveloppe.size / 2.0
	enveloppe.scale = Vector2(0.3, 0.3)
	enveloppe.draw.connect(_dessiner_grande_enveloppe.bind(enveloppe))
	add_child(enveloppe)
	var centre := get_viewport_rect().size / 2.0 - enveloppe.size / 2.0
	var tw := enveloppe.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(enveloppe, "position", centre, 0.5)
	tw.tween_property(enveloppe, "scale", Vector2(1.6, 1.6), 0.5)
	tw.tween_property(enveloppe, "rotation", deg_to_rad(-6.0), 0.5)
	tw.chain().tween_callback(enveloppe.queue_free)
	tw.chain().tween_callback(func() -> void: p.visible = true)
	p.position = cible + Vector2(0, 160)
	p.modulate.a = 0.0
	var tl := p.create_tween().set_parallel(true)
	tl.tween_property(p, "position", cible, 0.35).set_delay(0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tl.tween_property(p, "modulate:a", 1.0, 0.2).set_delay(0.5)


func _dessiner_enveloppe(c: Control, couleur: Color) -> void:
	var r := Rect2(Vector2(2, 2), c.size - Vector2(4, 4))
	c.draw_rect(r, couleur, false, 2.5)
	c.draw_polyline(PackedVector2Array([r.position, r.get_center() + Vector2(0, 2), Vector2(r.end.x, r.position.y)]), couleur, 2.5, true)


func _dessiner_grande_enveloppe(c: Control) -> void:
	var r := Rect2(Vector2.ZERO, c.size)
	c.draw_rect(r, Color("f3ead6"))
	c.draw_colored_polygon(PackedVector2Array([r.position, Vector2(r.end.x, 0), r.get_center() + Vector2(0, 8)]), Color("e3d6b8"))
	c.draw_rect(Rect2(r.end.x - 46, 10, 34, 40), Color("c8382e"))
	c.draw_rect(r, Color("b9ab8c"), false, 2.0)


## Bébé emmailloté pour le timbre du faire-part (lange, visage, nœud).
func _dessiner_bebe(t: Control, c: Vector2, lange: Color, k: float) -> void:
	t.draw_circle(c + Vector2(0, -15) * k, 5 * k, lange.darkened(0.15))
	Dessin.arrondi(t, Rect2(c + Vector2(-18, -12) * k, Vector2(36, 30) * k), lange, int(12 * k))
	t.draw_circle(c + Vector2(0, -2) * k, 9 * k, Color("f3cfb0"))
	t.draw_circle(c + Vector2(-3, -3) * k, 1.4 * k, Color("26272c"))
	t.draw_circle(c + Vector2(3, -3) * k, 1.4 * k, Color("26272c"))
	t.draw_arc(c, 3.0 * k, 0.3, PI - 0.3, 6, Color("c0705a"), 1.4 * k)


## Timbre dentelé avec un pictogramme (voiture, dent, billet, bébé, jumeaux).
func _dessiner_timbre(t: Control, picto: String) -> void:
	var r := Rect2(Vector2(6, 6), t.size - Vector2(12, 12))
	t.draw_rect(r, Color("fffaf0"))
	var k := 0.0
	while k < r.size.x:
		t.draw_circle(Vector2(r.position.x + k, r.position.y), 3.5, Style.COURRIER)
		t.draw_circle(Vector2(r.position.x + k, r.end.y), 3.5, Style.COURRIER)
		k += 10.0
	k = 0.0
	while k < r.size.y:
		t.draw_circle(Vector2(r.position.x, r.position.y + k), 3.5, Style.COURRIER)
		t.draw_circle(Vector2(r.end.x, r.position.y + k), 3.5, Style.COURRIER)
		k += 10.0
	var interieur := r.grow(-8)
	t.draw_rect(interieur, Color("d9e6ef"))
	var c := interieur.get_center()
	match picto:
		"voiture":
			Dessin.arrondi(t, Rect2(c.x - 26, c.y - 4, 52, 16), Color("c8382e"), 4)
			t.draw_colored_polygon(PackedVector2Array([c + Vector2(-16, -4), c + Vector2(-9, -16), c + Vector2(12, -16), c + Vector2(18, -4)]), Color("c8382e"))
			t.draw_circle(c + Vector2(-14, 13), 6, Color("23242a"))
			t.draw_circle(c + Vector2(15, 13), 6, Color("23242a"))
			for i in 3:
				t.draw_circle(c + Vector2(26 + i * 4, -6 - i * 8), 4 + i, Color(0.4, 0.4, 0.45, 0.7))
		"coeur":
			t.draw_circle(c + Vector2(-8, -4), 10, Color("c8382e"))
			t.draw_circle(c + Vector2(8, -4), 10, Color("c8382e"))
			t.draw_colored_polygon(PackedVector2Array([c + Vector2(-17, 0), c + Vector2(17, 0), c + Vector2(0, 20)]), Color("c8382e"))
		"bebe":
			_dessiner_bebe(t, c, Color("f7b6c8"), 1.0)
		"jumeaux":
			_dessiner_bebe(t, c + Vector2(-13, 2), Color("f7b6c8"), 0.75)
			_dessiner_bebe(t, c + Vector2(13, 2), Color("a9d4f5"), 0.75)
		_:
			t.draw_rect(Rect2(c.x - 24, c.y - 12, 48, 26), Color("5c9a62"))
			t.draw_circle(c + Vector2(0, 1), 8, Color("d6ecd2"))
	t.draw_string(Style.chiffres(), Vector2(r.position.x + 8, r.end.y - 8), "2,20 F", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("6b6458"))


# =====================================================================
# Carte de présentation de M. Lefranc (13 §1) et carte « nouvelle » (héritage, D08)
# =====================================================================

## Portrait réduit : le dessin du portrait est fait pour 120 px, on l'échelonne dans une boîte.
func _mini_portrait(taille: float) -> Control:
	var boite := Control.new()
	boite.custom_minimum_size = Vector2(taille, taille)
	boite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boite.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_portrait = Portrait.new()
	_portrait.size = Vector2(120, 120)
	_portrait.scale = Vector2.ONE * taille / 120.0
	boite.add_child(_portrait)
	return boite


## c : Banquier.contenu (kind « banquier »). lecture : relecture depuis le carnet (un seul bouton Fermer).
func presentation(c: Dictionary, depart: Vector2, lecture := false, bandeau := "") -> void:
	compact = Ecran.compact()
	genre_courant = "appel"
	_carte_retournee = false
	var heritage: bool = c.get("heritage", false)
	_choix_exterieur = "fermer" if lecture else ("compris" if heritage else "plus_tard")
	_assombrir(0.5)
	var vue := get_viewport_rect().size
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
	vt.add_child(Style.label(str(donnees_demo.get("banquier", {}).get("nom", "M. LEFRANC")) + " · votre banquier", 24 if compact else 28, Style.ui_gras()))
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
	x.draw.connect(_dessiner_croix.bind(x))
	x.pressed.connect(func() -> void: fermer(_choix_exterieur))
	tete.add_child(x)
	v.add_child(tete)
	v.add_child(_filet(Style.FILET, 2))
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
	# Pied : 3 choix de même poids (13 §1.1), « En savoir plus » retourne la carte
	var pied := HBoxContainer.new()
	pied.add_theme_constant_override("separation", 16)
	if lecture or heritage:
		var ok := Style.bouton("FERMER" if lecture else "COMPRIS", false, 72 if compact else 80)
		ok.custom_minimum_size.x = 360
		ok.pressed.connect(func() -> void: fermer(_choix_exterieur))
		pied.add_child(ok)
	else:
		var ouvrir := Style.bouton(str(c.get("bouton", "OUVRIR")), false, 72 if compact else 80)
		ouvrir.custom_minimum_size.x = 340 if compact else 380
		ouvrir.pressed.connect(fermer.bind("ouvrir"))
		pied.add_child(ouvrir)
		var tard := Style.bouton("PAS MAINTENANT", false, 72 if compact else 80)
		tard.custom_minimum_size.x = 340 if compact else 380
		tard.pressed.connect(fermer.bind("plus_tard"))
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
	v.add_child(pied)
	add_child(p)
	courant = p
	await _centrer(p)
	if not is_instance_valid(p):
		return
	# Entrée : la carte se déplie depuis la banque, puis M. Lefranc parle (1 s au plus)
	var cible := p.position
	var duree_texte := minf(1.0, texte.text.length() * 0.012)
	_parler = 0.35 + duree_texte
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


## Le ticket chiffré (13 §1.3) : un montant clé avec l'argent du joueur ; à 2 colonnes pour la succession.
func _ticket(c: Dictionary, a: int, largeur: float) -> Control:
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
				lm.draw.connect(_barrer.bind(lm))
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
	var fl := Style.label("→", taille, Style.ui(), Style.OR)
	hb.add_child(fl)
	var suite := Style.label(str(tk[1]) if tk.size() > 1 else "", 20 if compact else 24, Style.ui_gras(), Style.TEXTE)
	suite.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	suite.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	suite.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	suite.custom_minimum_size.x = largeur * 0.45
	hb.add_child(suite)
	p.add_child(hb)
	return p


## Trait en travers d'un montant hypothétique (somme qui n'a pas été versée).
func _barrer(l: Label) -> void:
	var y := l.size.y * 0.55
	l.draw_line(Vector2(0, y), Vector2(l.size.x, y), Color(Style.TEXTE_2, 0.9), 3.0, true)


## « Par rapport à ce que vous connaissez » (12 R8) : 4 critères en pastilles et en mots, et les frais.
func _comparatif(cp: Dictionary, largeur: float) -> Control:
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


func _dessiner_croix(b: Button) -> void:
	var m := b.size / 2.0
	b.draw_line(m + Vector2(-12, -12), m + Vector2(12, 12), Style.TEXTE, 4.0, true)
	b.draw_line(m + Vector2(12, -12), m + Vector2(-12, 12), Style.TEXTE, 4.0, true)


# =====================================================================
# Fenêtre Banque (carnet, fiche, ordre)
# =====================================================================

func ouvrir_banque(e: EtatPartie, produit: String, montant: float, depart := Vector2(-1, -1)) -> void:
	compact = Ecran.compact()
	genre_courant = "banque"
	_assombrir(0.4)
	banque = PanneauBanque.new()
	add_child(banque)
	banque.construire(e, produit, montant)
	banque.fermer_demande.connect(func() -> void: fermer("fermer"))
	courant = banque
	banque.visible = false
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(banque):
		return
	banque.visible = true
	banque.reset_size()
	var t := get_viewport_rect().size
	var cible := Vector2((t.x - banque.size.x) / 2.0, maxf(6.0, (t.y - banque.size.y) / 2.0))
	banque.position = cible
	banque.pivot_offset = banque.size / 2.0
	if not Juice.animations_reduites:
		banque.scale = Vector2(0.7, 0.7)
		banque.modulate.a = 0.0
		if depart.x >= 0.0:
			banque.pivot_offset = depart - cible
		var tw := banque.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(banque, "scale", Vector2.ONE, 0.3)
		tw.tween_property(banque, "modulate:a", 1.0, 0.2)


# =====================================================================
# Confirmation (nouvelle partie)
# =====================================================================

func confirmer(titre: String, texte: String, oui: String, non: String) -> void:
	compact = Ecran.compact()
	genre_courant = "confirmer"
	_assombrir(0.55)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.panneau(18))
	p.custom_minimum_size = Vector2(minf(820.0, get_viewport_rect().size.x - 60.0), 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	p.add_child(v)
	v.add_child(Style.label(titre, 24, Style.capitales(), Style.TEXTE_2))
	var l := Style.label(texte, 24, Style.ui(), Style.TEXTE)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(l)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 16)
	var b_non := Style.bouton(non, true)
	b_non.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_non.pressed.connect(fermer.bind("non"))
	var b_oui := Style.bouton(oui)
	b_oui.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_oui.pressed.connect(fermer.bind("oui"))
	hb.add_child(b_non)
	hb.add_child(b_oui)
	v.add_child(hb)
	add_child(p)
	courant = p
	_fixer_largeurs(p)
	await _centrer(p)
	b_non.grab_focus.call_deferred()


## Relevé de décembre ouvert depuis sa notification (13 §3.4) : les 3 piles avec les vrais chiffres du joueur.
func releve(n: Dictionary, a: int) -> void:
	compact = Ecran.compact()
	genre_courant = "info"
	_assombrir(0.45)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.panneau(18))
	var largeur := minf(1100.0, get_viewport_rect().size.x - 60.0)
	p.custom_minimum_size = Vector2(largeur, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8 if compact else 12)
	p.add_child(v)
	v.add_child(Style.label(str(n.get("titre", "")).to_upper() + " · M. LEFRANC", 22, Style.capitales(), Style.TEXTE_2))
	var l := Style.label(str(n.get("texte", "")), 20 if compact else 24, Style.ui(), Style.TEXTE)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = largeur - 40.0
	v.add_child(l)
	var frais := float(n.get("frais_total", 0.0))
	if frais > 0.0:
		var manque := float(n.get("manque", 0.0))
		v.add_child(Style.label("CE QUE LES FRAIS ONT COÛTÉ DEPUIS LE DÉBUT", 18, Style.capitales(), Style.TEXTE_2))
		var g := GridContainer.new()
		g.columns = 2
		for ligne in [["Frais payés (entrée, courtage, gestion)", Format.entier(frais, a)], ["Gains que cet argent aurait produits", Format.entier(manque, a)], ["Total", Format.entier(frais + manque, a)]]:
			var t := Style.label(str(ligne[0]), 22, Style.ui(), Style.TEXTE_2)
			t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			g.add_child(t)
			g.add_child(Style.label(str(ligne[1]), 22, Style.chiffres(), Style.CUIVRE))
		v.add_child(g)
		v.add_child(Style.label("Les frais paient un service (le gérant, l'agent de change, l'assureur) : c'est un prix, pas une faute.", 18, Style.ui(), Style.TEXTE_2))
	var ok := Style.bouton("FERMER")
	ok.pressed.connect(fermer.bind("fermer"))
	v.add_child(ok)
	add_child(p)
	courant = p
	_fixer_largeurs(p)
	await _centrer(p)


# =====================================================================
# Fin de démonstration, panneaux simples, menu
# =====================================================================

func fin_demo(e: EtatPartie) -> void:
	compact = Ecran.compact()
	genre_courant = "fin"
	_assombrir(0.65)
	var a := e.ab_courant()
	var vue := get_viewport_rect().size
	var p := PanelContainer.new()
	var sf := Style.panneau(22)
	sf.content_margin_left = 28 if compact else 40
	sf.content_margin_right = 28 if compact else 40
	sf.content_margin_top = 16 if compact else 30
	sf.content_margin_bottom = 16 if compact else 30
	p.add_theme_stylebox_override("panel", sf)
	var largeur := minf(1500.0, vue.x - 60.0)
	p.custom_minimum_size = Vector2(largeur, 0)
	var interieur := largeur - (56.0 if compact else 80.0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6 if compact else 12)
	p.add_child(v)
	var titre := Style.label("%s · CINQ ANS DE LA VIE DE %s" % [Dates.texte(a).to_upper(), e.prenom().to_upper()], 28 if compact else 38, Style.neon(), Style.ACCENT)
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titre.add_theme_color_override("font_shadow_color", Color(Style.ACCENT, 0.5))
	titre.add_theme_constant_override("shadow_outline_size", 10)
	titre.add_theme_constant_override("shadow_offset_x", 0)
	titre.add_theme_constant_override("shadow_offset_y", 0)
	v.add_child(titre)
	var lp := HBoxContainer.new()
	lp.alignment = BoxContainer.ALIGNMENT_CENTER
	lp.add_theme_constant_override("separation", 20)
	var lpt := Style.label("VOTRE PATRIMOINE", 20, Style.capitales(), Style.TEXTE_2)
	lpt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lp.add_child(lpt)
	var patr := e.patrimoine(e.joueur)
	var val := Style.label(Format.montant(0.0, a), 52 if compact else 68, Style.chiffres(), Style.TEXTE)
	lp.add_child(val)
	v.add_child(lp)
	# Vous et Tata Livret : 2 barres, l'écart en pastille ; à droite, la courbe des cinq ans (PC)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 24)
	v.add_child(ligne)
	var bloc := VBoxContainer.new()
	bloc.add_theme_constant_override("separation", 6)
	bloc.custom_minimum_size.x = interieur if compact else interieur * 0.5
	ligne.add_child(bloc)
	bloc.add_child(Style.label("VOUS ET TATA LIVRET (TOUT AU LIVRET A)", 18, Style.capitales(), Style.TEXTE_2))
	var tata := e.patrimoine(e.temoins["livret"])
	var barres := Barres.new()
	barres.custom_minimum_size = Vector2(bloc.custom_minimum_size.x, 96 if compact else 110)
	barres.regler([["VOUS", patr, Style.ACCENT], ["TATA LIVRET", tata, Courbe.COULEUR_REF]], a)
	bloc.add_child(barres)
	bloc.add_child(Style.label("Argent mis de côté en cinq ans : " + Format.montant(e.epargne_nette, a), 18, Style.ui(), Style.TEXTE_2))
	bloc.add_child(_bloc_comparaison_livret(e, a))
	if not compact:
		var droite := VBoxContainer.new()
		droite.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		droite.add_child(Style.label("CINQ ANS EN UN COUP D'ŒIL", 18, Style.capitales(), Style.TEXTE_2))
		var courbe := Courbe.new()
		courbe.custom_minimum_size = Vector2(0, 250)
		courbe.total_mois = e.m_fin - e.m_depart
		var vals: Array = e.hist["j"].slice(e.m_depart, e.m + 1)
		var ref: Array = e.hist["livret"].slice(e.m_depart, e.m + 1)
		courbe.regler(vals, [], e.ab_de(e.m_depart), 0.0, ref)
		courbe.ecart_impose = e.ecart_livret()
		droite.add_child(courbe)
		var leg := HBoxContainer.new()
		leg.add_theme_constant_override("separation", 18)
		leg.add_child(Style.label("— Vous", 18, Style.ui(), Style.ACCENT))
		leg.add_child(Style.label("— Tata Livret", 18, Style.ui(), Courbe.COULEUR_REF))
		droite.add_child(leg)
		ligne.add_child(droite)
	# Frais, produits découverts et utilisés
	var frais := e.frais_payes()
	var infos := HBoxContainer.new()
	infos.add_theme_constant_override("separation", 30)
	var lf := Style.label("Frais payés : %s  ·  Tata Livret : 0 F" % Format.entier(frais, a), 22 if compact else 24, Style.chiffres(), Style.CUIVRE)
	lf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	infos.add_child(lf)
	var utilises: Array = e.stats.get("utilises", [])
	infos.add_child(Style.label("Produits découverts %d/%d · utilisés %d/%d" % [Banquier.nb_decouverts(e), Banquier.ordre_carnet().size(), utilises.size(), Banquier.ordre_carnet().size()], 22 if compact else 24, Style.ui(), Style.TEXTE))
	v.add_child(infos)
	if frais <= 0.005:
		var ex := Banquier.piles("sicav", Produits.f(10000.0), a)
		var lx := Style.label("Exemple : 10 000 F placés 20 ans à 7 %% par an (une hypothèse, pas une promesse) : %s sans frais, %s avec une SICAV à 2 %% + 1,5 %%/an, %s avec une plus chargée." % [
			Format.entier(ex["sans"], a), Format.entier(ex["produit"], a), Format.entier(ex["charge"], a)], 18 if compact else 20, Style.ui(), Style.TEXTE_2)
		lx.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lx.custom_minimum_size.x = interieur
		v.add_child(lx)
	var phrase := Style.label(_phrase_synthese(e, a), 20 if compact else 24, Style.ui(), Style.TEXTE)
	phrase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phrase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	phrase.custom_minimum_size.x = interieur
	v.add_child(phrase)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 16)
	var rejouer := Style.bouton("REJOUER AUTREMENT", true, 72 if compact else 80)
	rejouer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rejouer.pressed.connect(fermer.bind("rejouer"))
	var quitter := Style.bouton("QUITTER", false, 72 if compact else 80)
	quitter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quitter.pressed.connect(fermer.bind("quitter"))
	hb.add_child(rejouer)
	hb.add_child(quitter)
	v.add_child(hb)
	add_child(p)
	courant = p
	await _centrer(p)
	if not is_instance_valid(p):
		return
	p.scale = Vector2(0.85, 0.85)
	p.modulate.a = 0.0
	var tw := p.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(p, "scale", Vector2.ONE, 0.4)
	tw.tween_property(p, "modulate:a", 1.0, 0.25)
	Juice.rouler(val, 0.0, patr, func(x: float) -> String: return Format.montant(x, a), 1.5, Style.GAIN)
	barres.animer(0.6)


## Une seule phrase de synthèse, choisie par règle, jamais de reproche (13 §4.3).
func _phrase_synthese(e: EtatPartie, a: int) -> String:
	var ecart := e.ecart_livret()
	var x := Format.ecart(absf(ecart), a).trim_prefix("+")
	if Format.en_devise(ecart, Format.devise(a)) >= 0.5:
		return "« Vos placements ont fait mieux que le Livret A de %s, krach de 1987 compris. »" % x
	if Format.en_devise(ecart, Format.devise(a)) <= -0.5:
		return "« Cette fois, le Livret A a fait mieux de %s. Les frais et le krach sont passés par là : rejouez pour voir ce qui change. »" % x
	return "« Vous avez fait comme Tata Livret : sûr et sans frais. Et si vous essayiez autre chose ? »"


## Fin de démo (12 §3.5) : une seule comparaison, avec « tout au Livret A » (Tata Livret).
func _bloc_comparaison_livret(e: EtatPartie, a: int) -> PanelContainer:
	var ecart := e.ecart_livret()
	var sens := 0
	if Format.en_devise(ecart, Format.devise(a)) >= 0.5:
		sens = 1
	elif Format.en_devise(ecart, Format.devise(a)) <= -0.5:
		sens = -1
	var c := Style.GAIN if sens > 0 else (Style.PERTE if sens < 0 else Style.TEXTE_2)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.pastille(c, 14, 8))
	var h := HBoxContainer.new()
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_theme_constant_override("separation", 12)
	if sens != 0:
		h.add_child(_fleche(sens > 0, c))
	var verdict := "VOUS : à égalité avec Tata Livret"
	if sens > 0:
		verdict = "VOUS : %s de plus que Tata Livret" % Format.ecart(ecart, a).trim_prefix("+")
	elif sens < 0:
		verdict = "VOUS : %s de moins que Tata Livret" % Format.ecart(-ecart, a).trim_prefix("+")
	h.add_child(Style.label(verdict, 24 if compact else 28, Style.chiffres(), c))
	p.add_child(h)
	return p


## extra : libellé d'un second bouton (ferme avec l'id « extra »), "" pour aucun.
func info(titre: String, lignes: Array, depart := Vector2(-1, -1), extra := "") -> void:
	genre_courant = "info"
	_assombrir(0.35)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.panneau(18))
	p.custom_minimum_size = Vector2(minf(720.0, get_viewport_rect().size.x - 60.0), 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	v.add_child(Style.label(titre, 24, Style.capitales(), Style.TEXTE_2))
	for l in lignes:
		var lab := Style.label(str(l), 24, Style.ui(), Style.TEXTE)
		lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(lab)
	if extra != "":
		var bx := Style.bouton(extra)
		bx.pressed.connect(fermer.bind("extra"))
		v.add_child(bx)
	var ok := Style.bouton("FERMER")
	ok.pressed.connect(fermer.bind("fermer"))
	v.add_child(ok)
	add_child(p)
	courant = p
	_fixer_largeurs(p)
	await _centrer(p)
	var cible := p.position
	if depart.x >= 0.0 and not Juice.animations_reduites:
		p.scale = Vector2(0.6, 0.6)
		p.position = depart - p.size * 0.3
		p.modulate.a = 0.0
		var tw := p.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(p, "position", cible, 0.3)
		tw.tween_property(p, "scale", Vector2.ONE, 0.3)
		tw.tween_property(p, "modulate:a", 1.0, 0.2)


func menu() -> void:
	genre_courant = "menu"
	_assombrir(0.5)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.panneau(18))
	p.custom_minimum_size = Vector2(460, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	p.add_child(v)
	v.add_child(Style.label("MENU", 24, Style.capitales(), Style.TEXTE_2))
	var rep := Style.bouton("REPRENDRE", true)
	rep.pressed.connect(fermer.bind("reprendre"))
	v.add_child(rep)
	var hi := Style.bouton("HISTORIQUE")
	hi.pressed.connect(fermer.bind("historique"))
	v.add_child(hi)
	var q := Style.bouton("QUITTER LE JEU")
	q.pressed.connect(fermer.bind("quitter"))
	v.add_child(q)
	add_child(p)
	courant = p
	_fixer_largeurs(p)
	await _centrer(p)


## Entrée simple (relectures) : la feuille grossit légèrement en apparaissant.
func _apparaitre(p: Control) -> void:
	if Juice.animations_reduites:
		return
	p.pivot_offset = p.size / 2.0
	p.scale = Vector2(0.92, 0.92)
	p.modulate.a = 0.0
	var tw := p.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(p, "scale", Vector2.ONE, 0.25)
	tw.tween_property(p, "modulate:a", 1.0, 0.15)


# =====================================================================
# Historique des pop-ups (retour du joueur du 27/10/2026)
# =====================================================================

const NOMS_SOURCES := {"maison": "MA MAISON", "banque": "MA BANQUE", "media": "LA GAZETTE"}
var historique_filtre := ""
var historique_defilement := 0
var _hist_defile: ScrollContainer = null
var _hist_appui := Vector2(-1, -1)


## Tout ce qui est apparu au joueur, du plus récent au plus ancien : date, source (couleur et pictogramme),
## titre, résumé d'une ligne, choix fait ou montant. Filtre par source ; toucher une ligne la rouvre en
## lecture seule (fermeture avec l'id « ouvrir:<indice> »). On ne superpose pas deux fenêtres : la relecture
## remplace l'historique, qui revient ensuite au même filtre et au même défilement.
func historique(e: EtatPartie, filtre := "", defilement := 0) -> void:
	compact = Ecran.compact()
	genre_courant = "historique"
	historique_filtre = filtre
	_assombrir(0.45)
	var t := get_viewport_rect().size
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
	x.draw.connect(_dessiner_croix.bind(x))
	x.pressed.connect(fermer.bind("fermer"))
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
	_hist_defile = ScrollContainer.new()
	_hist_defile.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_hist_defile.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_hist_defile.custom_minimum_size = Vector2(largeur - 40.0, 0)
	v.add_child(_hist_defile)
	var liste := VBoxContainer.new()
	liste.add_theme_constant_override("separation", 6 if compact else 8)
	liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	liste.name = "Liste"
	_hist_defile.add_child(liste)
	_remplir_historique(e, liste, largeur - 64.0)
	v.add_child(Style.label("Touchez une ligne pour la relire telle qu'elle est apparue (sans rejouer la décision).", 16 if compact else 18, Style.ui(), Style.TEXTE_2))
	add_child(p)
	courant = p
	await _centrer(p)
	if not is_instance_valid(p):
		return
	_hist_defile.scroll_vertical = defilement
	_apparaitre(p)


func _on_filtre_bascule(allume: bool, e: EtatPartie, f: String) -> void:
	if allume:
		_filtrer_historique(e, f)


func _filtrer_historique(e: EtatPartie, f: String) -> void:
	historique_filtre = f
	if _hist_defile == null or not is_instance_valid(_hist_defile):
		return
	var liste := _hist_defile.get_node("Liste") as VBoxContainer
	for c in liste.get_children():
		liste.remove_child(c)
		c.queue_free()
	_remplir_historique(e, liste, _hist_defile.custom_minimum_size.x - 24.0)
	_hist_defile.scroll_vertical = 0


func _remplir_historique(e: EtatPartie, liste: VBoxContainer, largeur: float) -> void:
	var entrees := e.historique_recent(historique_filtre)
	if entrees.is_empty():
		liste.add_child(Style.label("Rien pour l'instant : les appels, les nouvelles et les courriers se rangeront ici.", 22, Style.ui(), Style.TEXTE_2))
		return
	for h: Dictionary in entrees:
		liste.add_child(_ligne_historique(e, h, largeur))


func _ligne_historique(e: EtatPartie, h: Dictionary, largeur: float) -> Control:
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
	p.gui_input.connect(_on_ligne_historique.bind(int(h["i"])))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 14)
	hb.mouse_filter = Control.MOUSE_FILTER_PASS
	p.add_child(hb)
	hb.add_child(_pictogramme_source(source, 48.0 if compact else 52.0))
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
func _on_ligne_historique(ev: InputEvent, i: int) -> void:
	var b := ev as InputEventMouseButton
	if b == null or b.button_index != MOUSE_BUTTON_LEFT:
		return
	if b.pressed:
		_hist_appui = b.global_position
	elif _hist_appui.x >= 0.0 and b.global_position.distance_to(_hist_appui) < 14.0:
		_hist_appui = Vector2(-1, -1)
		historique_defilement = _hist_defile.scroll_vertical if is_instance_valid(_hist_defile) else 0
		fermer("ouvrir:%d" % i)


## Pastille ronde de la source, avec son pictogramme dessiné (maison, banque à colonnes, journal).
func _pictogramme_source(source: String, d: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(d, d)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(_dessiner_pictogramme.bind(c, source))
	return c


func _dessiner_pictogramme(c: Control, source: String) -> void:
	var m := c.size / 2.0
	var r := minf(c.size.x, c.size.y) / 2.0
	var coul: Color = Style.SOURCES.get(source, Style.ACCENT)
	c.draw_circle(m, r, Color(coul, 0.22))
	c.draw_arc(m, r - 1.0, 0.0, TAU, 32, coul, 2.0, true)
	var k := r / 24.0
	var blanc := Style.TEXTE
	match source:
		"maison":
			c.draw_colored_polygon(PackedVector2Array([m + Vector2(-13, -1) * k, m + Vector2(0, -13) * k, m + Vector2(13, -1) * k]), coul)
			c.draw_rect(Rect2(m + Vector2(-9, -1) * k, Vector2(18, 13) * k), blanc)
			c.draw_rect(Rect2(m + Vector2(-3, 4) * k, Vector2(6, 8) * k), coul)
		"banque":
			c.draw_colored_polygon(PackedVector2Array([m + Vector2(-14, -6) * k, m + Vector2(0, -14) * k, m + Vector2(14, -6) * k]), coul)
			for i in 4:
				c.draw_rect(Rect2(m + Vector2(-11 + i * 6.5, -4) * k, Vector2(3.5, 13) * k), blanc)
			c.draw_rect(Rect2(m + Vector2(-14, 10) * k, Vector2(28, 3) * k), blanc)
		_:
			c.draw_rect(Rect2(m + Vector2(-12, -11) * k, Vector2(24, 22) * k), blanc)
			c.draw_rect(Rect2(m + Vector2(-9, -8) * k, Vector2(18, 4) * k), coul)
			for i in 3:
				c.draw_rect(Rect2(m + Vector2(-9, -1 + i * 4) * k, Vector2(18 - (i % 2) * 6, 2) * k), Color(Style.ENCRE, 0.7))


## Relecture d'une notification de l'historique (message du banquier, nouvelle, petit courrier…).
func lecture_notification(h: Dictionary, a: int) -> void:
	compact = Ecran.compact()
	genre_courant = "info"
	_assombrir(0.45)
	var n: Dictionary = h.get("contenu", {})
	var source := str(h.get("source", "banque"))
	var coul: Color = Style.SOURCES.get(source, Style.ACCENT)
	var p := PanelContainer.new()
	var s := Style.boite(Style.PANNEAU_ELEVE, 18, 28, 20)
	Style.bordure(s, coul, 10, 0, 0, 0)
	Style.ombre(s, Color(0, 0, 0, 0.6), 20, Vector2(0, 8))
	p.add_theme_stylebox_override("panel", s)
	p.custom_minimum_size = Vector2(minf(980.0, get_viewport_rect().size.x - 60.0), 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 14)
	tete.add_child(_pictogramme_source(source, 52.0))
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
	ok.pressed.connect(fermer.bind("fermer"))
	v.add_child(ok)
	add_child(p)
	courant = p
	_fixer_largeurs(p)
	await _centrer(p)
	if is_instance_valid(p):
		_apparaitre(p)
