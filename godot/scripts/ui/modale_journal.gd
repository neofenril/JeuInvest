class_name ModaleJournal
extends RefCounted
## Morceau de Modales (T9) : le journal d'un événement de marché (04 §3.5), ses petits journaux volants,
## ses choix (touches 1-3) et la confirmation de « Tout vendre ».

var m: Modales


func _init(modales: Modales) -> void:
	m = modales


## lecture_choix : relecture depuis l'historique (pas de décision : le choix fait, et FERMER).
func ouvrir(c: Dictionary, depart: Vector2, spectaculaire: bool, lecture_choix := "") -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	var lecture := lecture_choix != ""
	m.genre_courant = "info" if lecture else "journal"
	m.assombrir(0.6)
	var t := m.get_viewport_rect().size
	var p := PanelContainer.new()
	# Page de la Gazette : papier crème à bords déchirés (cadre pixel répété), docs/16 §5.4
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.add_theme_stylebox_override("panel", CadresPixel.style_marges("journal", 24 if compact else 36, 24 if compact else 33, 24 if compact else 36, 24 if compact else 33))
	p.custom_minimum_size = Vector2(minf(1200.0, t.x - 80.0), 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6 if compact else 10)
	p.add_child(v)
	# Bandeau : SPÉCIAL · nom du journal · prix
	var dj: Dictionary = m.donnees_demo.get("journal", {})
	var tete := HBoxContainer.new()
	var ruban := PanelContainer.new()
	ruban.add_theme_stylebox_override("panel", Style.boite(Style.ENCRE_ROUGE, 3, 12, 2))
	ruban.add_child(Style.label(str(dj.get("bandeau", "SPÉCIAL")), 22, Style.manchette(), PalettePixel.couleur("blanc_chaud")))
	ruban.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(ruban)
	var nom := Style.label(str(dj.get("nom", "LA GAZETTE")), 40 if compact else 52, Style.titre_journal(), Style.ENCRE)
	nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tete.add_child(nom)
	var prix := Style.label(str(dj.get("prix", "")), 22, Style.journal(), Style.ENCRE)
	prix.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(prix)
	v.add_child(tete)
	v.add_child(ModaleOutils.filet(Style.ENCRE, 3))
	var ligne_date := HBoxContainer.new()
	ligne_date.add_child(Style.label(str(c.get("date_journal", c.get("date", ""))).to_upper(), 20, Style.capitales(), Style.ENCRE))
	var ed := Style.label("ÉDITION SPÉCIALE", 20, Style.capitales(), Style.ENCRE_ROUGE)
	ed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ed.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ligne_date.add_child(ed)
	v.add_child(ligne_date)
	v.add_child(ModaleOutils.filet(Style.ENCRE, 1))
	# Manchette qui s'imprime
	var manchette := Style.label(str(c["titre"]).to_upper(), 50 if compact else 72, Style.manchette(), Style.ENCRE)
	manchette.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	manchette.add_theme_constant_override("line_spacing", -8)
	manchette.visible_ratio = 0.0
	v.add_child(manchette)
	var chapo := Style.label(str(c["texte"]), 24 if compact else 26, Style.journal(), Style.ENCRE)
	chapo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(chapo)
	v.add_child(_impact(c, p.custom_minimum_size.x))
	if lecture:
		var hl := HBoxContainer.new()
		hl.add_theme_constant_override("separation", 14)
		var lc := Style.label("VOTRE CHOIX : " + lecture_choix.to_upper(), 22, Style.capitales(), Style.ENCRE)
		lc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hl.add_child(lc)
		var bf := ModaleOutils.bouton_papier("FERMER", "", compact)
		bf.custom_minimum_size.x = 260
		bf.size_flags_horizontal = Control.SIZE_SHRINK_END
		bf.pressed.connect(m.fermer.bind("fermer"))
		hl.add_child(bf)
		v.add_child(hl)
		m.poser(p)
		m.fixer_largeurs(p)
		await m.centrer(p)
		if is_instance_valid(p):
			p.rotation = 0.0
			manchette.visible_ratio = 1.0
			m.apparaitre(p)
		return
	v.add_child(Style.label("QUE FAITES-VOUS ?", 20, Style.capitales(), Style.ENCRE))
	var zone_choix := HBoxContainer.new()
	zone_choix.add_theme_constant_override("separation", 14)
	zone_choix.name = "Choix"
	v.add_child(zone_choix)
	m.choix_journal = []
	var i := 1
	for ch in c["choix"]:
		var b := ModaleOutils.bouton_papier("%d   %s" % [i, str(ch["titre"]).to_upper()], str(ch.get("sous", "")), compact)
		b.disabled = bool(ch.get("desactive", false))
		b.pressed.connect(choisir.bind(str(ch["id"])))
		zone_choix.add_child(b)
		m.choix_journal.append(str(ch["id"]))
		i += 1
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)
	# Entrée : le journal jaillit du média en tournoyant, ou tombe simplement
	var cible_pos := p.position
	var cible_rot := 0.0   # au repos, la page est droite (pixels nets, docs/16 §5.4)
	m.boutons_actifs = false
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
	t2.tween_callback(func() -> void: m.boutons_actifs = true)
	t2.tween_property(zone_choix, "modulate:a", 1.0, 0.2)


## Pastille d'impact, toujours sur 2 lignes voulues (encadré aux coins doux, pas une gélule) :
## 1) ce qui a bougé (les placements en bourse), 2) ce que cela pèse sur le patrimoine total.
func _impact(c: Dictionary, largeur_page: float) -> PanelContainer:
	var compact := m.compact
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
	var largeur_pastille := largeur_page - (48.0 if compact else 72.0) - 44.0
	var seconde: Label
	if c.get("detient", false):
		var diff := float(impact.get("diff", 0.0))
		var depuis: String = Dates.MOIS[Dates.mois(int(impact.get("depuis", a))) - 1]
		ph.add_child(Style.label("VOS PLACEMENTS EN BOURSE", 20, Style.capitales(), Style.ENCRE))
		ph.add_child(ModaleOutils.fleche(diff >= 0.0, Style.ENCRE_ROUGE))
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
		var vert := PalettePixel.couleur("gain_papier")
		var lv := HBoxContainer.new()
		lv.add_theme_constant_override("separation", 10)
		var tl := Style.label("FACE À « TOUT AU LIVRET A »", 18, Style.capitales(), Style.ENCRE)
		tl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lv.add_child(tl)
		lv.add_child(ModaleOutils.fleche(ecart >= 0.0, vert if ecart >= 0.0 else Style.ENCRE_ROUGE))
		lv.add_child(Style.label(Format.ecart(ecart, a), 24, Style.chiffres(), vert if ecart >= 0.0 else Style.ENCRE_ROUGE))
		var mois_av: String = Dates.MOIS[Dates.mois(int(c.get("ab_avant", a))) - 1]
		var la := Style.label("(fin %s : %s)" % [mois_av, Format.ecart(ecart_av, a)], 20, Style.journal(), Style.ENCRE)
		la.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lv.add_child(la)
		pv.add_child(lv)
	return past


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
		poussiere.color = PalettePixel.couleur("pierre_claire")
		m.add_child(poussiere)
		m.move_child(poussiere, p.get_index())
		poussiere.emitting = true
		m.get_tree().create_timer(1.5).timeout.connect(poussiere.queue_free)
	manchette.create_tween().tween_property(manchette, "visible_ratio", 1.0, 0.35)


## Petits journaux qui jaillissent du média (effet 2, décor) avant le journal principal.
func volants(depart: Vector2, n: int) -> void:
	if Juice.animations_reduites:
		return
	var t := m.get_viewport_rect().size
	for i in n:
		var j := Control.new()
		j.size = Vector2(150, 100)
		j.pivot_offset = j.size / 2.0
		j.position = depart - j.size / 2.0
		j.scale = Vector2(0.2, 0.2)
		j.draw.connect(_dessiner_petit_journal.bind(j))
		j.mouse_filter = Control.MOUSE_FILTER_IGNORE
		m.add_child(j)
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


## Un choix du journal (bouton, touche, Échap) ; « Tout vendre » passe par une confirmation.
func choisir(id: String) -> void:
	if not m.boutons_actifs or m.courant == null:
		return
	if id == "vendre" and m.donnees_demo.has("_vente_totale"):
		_confirmer_vente()
		return
	m.fermer(id)


## « Tout vendre » : confirmation dans la modale (récapitulatif des frais et de l'impôt).
func _confirmer_vente() -> void:
	var zone := m.courant.find_child("Choix", true, false) as HBoxContainer
	if zone == null:
		m.fermer("vendre")
		return
	for c in zone.get_children():
		c.queue_free()
	var r: Dictionary = m.donnees_demo["_vente_totale"]
	var a: int = m.donnees_demo.get("_ab", 0)
	var txt := "Vous vendez %d ligne(s) pour %s. Frais : %s. Impôt : %s. Vous recevez %s." % [
		r["lignes"].size(), Format.montant(r["brut"], a), Format.montant(r["frais"], a), Format.montant(r["impot"], a), Format.montant(r["recu"], a)]
	var l := Style.label(txt, 22, Style.ui_gras(), Style.ENCRE)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.custom_minimum_size = Vector2(380, 0)
	zone.add_child(l)
	var ok := ModaleOutils.bouton_papier("CONFIRMER", "Tout vendre maintenant", m.compact)
	ok.pressed.connect(func() -> void: m.fermer("vendre"))
	zone.add_child(ok)
	var non := ModaleOutils.bouton_papier("JE RÉFLÉCHIS", "Revenir aux choix", m.compact)
	non.pressed.connect(func() -> void: m.fermer("rien"))
	zone.add_child(non)
