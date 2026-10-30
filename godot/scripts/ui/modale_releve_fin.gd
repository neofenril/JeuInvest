class_name ModaleReleveFin
extends RefCounted
## Morceau de Modales (T9) : le relevé de décembre (13 §3.4, détail des frais) et l'écran de fin de
## démonstration (13 §4.3 : patrimoine, Tata Livret, courbe des cinq ans, frais, phrase de synthèse).

var m: Modales


func _init(modales: Modales) -> void:
	m = modales


## Relevé de décembre ouvert depuis sa notification (13 §3.4) : les 3 piles avec les vrais chiffres du joueur.
func releve(n: Dictionary, a: int) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "info"
	m.assombrir(0.45)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.panneau(18))
	var largeur := minf(1100.0, m.get_viewport_rect().size.x - 60.0)
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
	ok.pressed.connect(m.fermer.bind("fermer"))
	v.add_child(ok)
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)


func fin_demo(e: EtatPartie) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "fin"
	m.assombrir(0.65)
	var a := e.ab_courant()
	var vue := m.get_viewport_rect().size
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
		ligne.add_child(_courbe_cinq_ans(e))
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
	rejouer.pressed.connect(m.fermer.bind("rejouer"))
	var quitter := Style.bouton("QUITTER", false, 72 if compact else 80)
	quitter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quitter.pressed.connect(m.fermer.bind("quitter"))
	hb.add_child(rejouer)
	hb.add_child(quitter)
	v.add_child(hb)
	m.poser(p)
	await m.centrer(p)
	if not is_instance_valid(p):
		return
	p.scale = Vector2(0.85, 0.85)
	p.modulate.a = 0.0
	var tw := p.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(p, "scale", Vector2.ONE, 0.4)
	tw.tween_property(p, "modulate:a", 1.0, 0.25)
	Juice.rouler(val, 0.0, patr, func(x: float) -> String: return Format.montant(x, a), 1.5, Style.GAIN)
	barres.animer(0.6)


## « Cinq ans en un coup d'œil » (PC seulement) : la courbe du joueur et celle de Tata Livret.
func _courbe_cinq_ans(e: EtatPartie) -> VBoxContainer:
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
	return droite


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
		h.add_child(ModaleOutils.fleche(sens > 0, c))
	var verdict := "VOUS : à égalité avec Tata Livret"
	if sens > 0:
		verdict = "VOUS : %s de plus que Tata Livret" % Format.ecart(ecart, a).trim_prefix("+")
	elif sens < 0:
		verdict = "VOUS : %s de moins que Tata Livret" % Format.ecart(-ecart, a).trim_prefix("+")
	h.add_child(Style.label(verdict, 24 if m.compact else 28, Style.chiffres(), c))
	p.add_child(h)
	return p
