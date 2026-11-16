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
		g.name = "GrilleFrais"
		g.columns = 2
		for ligne in lignes_frais(frais, manque, a):
			var t := Style.label(str(ligne[0]), 22, Style.ui(), Style.TEXTE_2)
			t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			g.add_child(t)
			var lv := Style.label(str(ligne[1]), 22, Style.chiffres(), Style.CUIVRE)
			lv.name = str(ligne[2])
			g.add_child(lv)
		v.add_child(g)
		v.add_child(Style.label("Les frais paient un service (le gérant, l'agent de change, l'assureur) : c'est un prix, pas une faute.", 18, Style.ui(), Style.TEXTE_2))
	var ok := Style.bouton("FERMER")
	ok.pressed.connect(m.fermer.bind("fermer"))
	v.add_child(ok)
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)


## Lignes de la grille des frais : [libellé, montant affiché, nom du nœud]. D6 (m9) : le total est la
## somme des valeurs affichées (chaque terme arrondi à l'unité comme `Format.entier`), pour que
## « 417 F + 42 F » donne « 459 F » à l'écran, même si le total exact (458,2 F) s'arrondit à 458.
static func lignes_frais(frais: float, manque: float, a: int) -> Array:
	var dev := Format.devise(a)
	var total := Format.vers_euros(arrondi_affiche(frais, a) + arrondi_affiche(manque, a), dev)
	return [["Frais payés (entrée, courtage, gestion)", Format.entier(frais, a), "Frais"],
		["Gains que cet argent aurait produits", Format.entier(manque, a), "Manque"],
		["Total", Format.entier(total, a), "Total"]]


## Valeur (dans la devise de la date a) que `Format.entier` affiche pour ce montant : même arrondi
## (« %.0f » sur la valeur absolue, signe remis), pour additionner exactement ce que le joueur lit.
static func arrondi_affiche(eur: float, a: int) -> float:
	var v := Format.en_devise(eur, Format.devise(a))
	var r := float("%.0f" % absf(v))
	return -r if v < 0.0 else r


## Écran de fin à 4 barres (lot 06, 05-I R7 ; docs/24 §2.6, lot_06 A7) quand la rue est allumée : classement_rue() à la place des barres
## « Vous et Tata Livret » ; barres de Vous (ambre), Tata (couleur de sa courbe, soulignée référence), Tonton et Jean-Mi (zinc clair) ;
## valeur négative : pas de barre ; rang en pastille neutre « 2e DE LA RUE SUR 4 » ; réplique du voisin le plus proche (replique_rue).
## `fab_rue` : classement fabriqué (captures et tests) ; `infos_rue` : ce que l'écran affiche (lu par les captures et les tests).
var fab_rue: Array = []
var infos_rue := {}
var barres_fin: Barres = null


func _bloc_rue(bloc: VBoxContainer, barres: Barres, classement: Array, compact: bool, a: int) -> void:
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 12)
	var lt := Style.label("LA RUE : VOUS ET VOS VOISINS", 20, Style.capitales(), Style.TEXTE_2)
	lt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lt.clip_text = true
	lt.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lt.custom_minimum_size.x = 60
	tete.add_child(lt)
	var rang := BlocRue._rang_de(classement)
	var pc := PanelContainer.new()
	pc.name = "PastilleRang"
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.set_border_width_all(3)
	sb.border_color = Style.TEXTE_2
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	pc.add_theme_stylebox_override("panel", sb)
	var lr := Style.label("%s DE LA RUE SUR %d" % [BlocRue.rang_texte(rang), classement.size()], 28 if not compact else 24, Style.ui_gras(), Style.TEXTE)
	lr.name = "TexteRang"
	pc.add_child(lr)
	tete.add_child(pc)
	bloc.add_child(tete)
	var lignes: Array = []
	var ref := -1
	for i in classement.size():
		var l: Dictionary = classement[i]
		var id := str(l.get("id", ""))
		var col: Color = Style.ACCENT if bool(l.get("vous", false)) else (Courbe.COULEUR_REF if id == "livret" else PalettePixel.couleur("zinc_clair"))
		lignes.append(["%d %s" % [int(l.get("rang", 0)), str(l.get("nom", "")).to_upper()], float(l.get("patrimoine", 0.0)) / Format.TAUX_EURO, col])
		if bool(l.get("reference", false)):
			ref = i
	barres.taille_libelle = 20
	barres.largeur_libelle = 250.0
	barres.ligne_reference = ref
	barres.custom_minimum_size = Vector2(bloc.custom_minimum_size.x, 4.0 * (42.0 if compact else 48.0))
	barres.regler(lignes, a)
	barres_fin = barres


func fin_demo(e: EtatPartie) -> void:
	infos_rue = {}
	barres_fin = null
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
	# Lot 06 (A7, non ★) : le visage de Sylvie de « Mon foyer » (humeur du moment), quand les cartes sont allumées
	if e.has_method("cartes_actives") and e.cartes_actives():
		var visage := CadresPixel.icone("portrait_sylvie_" + ModaleCarte.nom_humeur(e.humeur_visible()), {}, 2 if compact else 3)   # recette R-RUE M6 : plus petit au téléphone, la réplique remonte
		visage.name = "VisageSylvie"
		visage.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lp.add_child(visage)
		infos_rue["visage"] = true
	var lpt := Style.label("VOTRE PATRIMOINE", 20, Style.capitales(), Style.TEXTE_2)
	lpt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lp.add_child(lpt)
	var patr := e.patrimoine(e.joueur)
	var val := Style.label(Format.montant(0.0, a), 52 if compact else 68, Style.chiffres(), Style.TEXTE)
	lp.add_child(val)
	v.add_child(lp)
	# Vous et Tata Livret : 2 barres, l'écart en pastille ; à droite, la courbe des cinq ans (PC)
	var ligne := HBoxContainer.new()
	ligne.name = "Defilant"
	ligne.add_theme_constant_override("separation", 24)
	v.add_child(ligne)
	var bloc := VBoxContainer.new()
	bloc.add_theme_constant_override("separation", 6)
	bloc.custom_minimum_size.x = interieur if compact else interieur * 0.5
	ligne.add_child(bloc)
	var barres := Barres.new()
	var classement: Array = fab_rue if not fab_rue.is_empty() else (e.classement_rue() if e.has_method("classement_rue") else [])
	var tata := e.patrimoine(e.temoins["livret"])
	if classement.is_empty():
		bloc.add_child(Style.label("VOUS ET TATA LIVRET (TOUT AU LIVRET A)", 18, Style.capitales(), Style.TEXTE_2))
		barres.custom_minimum_size = Vector2(bloc.custom_minimum_size.x, 96 if compact else 110)
		barres.regler([["VOUS", patr, Style.ACCENT], ["TATA LIVRET", tata, Courbe.COULEUR_REF]], a)
	else:
		_bloc_rue(bloc, barres, classement, compact, a)
	bloc.add_child(barres)
	if not classement.is_empty():
		var rep: Dictionary = Quartier.replique_rue(classement)
		if not rep.is_empty() and str(rep.get("texte", "")) != "":
			var hr := HBoxContainer.new()
			hr.name = "RepliqueRue"
			hr.add_theme_constant_override("separation", 9)
			hr.add_child(BlocRue.pastille(str(rep.get("qui", "")), str({"jeanmi": "J", "livret": "T", "matelas": "M"}.get(str(rep.get("qui", "")), str(rep.get("nom", "?")).left(1))), 30.0))
			var lr := Style.label("%s : « %s »" % [str(rep["nom"]), str(rep["texte"])], 22, Style.ui(), Style.TEXTE)
			lr.name = "TexteReplique"
			lr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lr.custom_minimum_size.x = bloc.custom_minimum_size.x - 50.0
			lr.max_lines_visible = 2
			lr.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			hr.add_child(lr)
			bloc.add_child(hr)
		infos_rue.merge({"rang": BlocRue._rang_de(classement), "total": classement.size(), "replique": not rep.is_empty()}, true)
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
	# Lot 06 (A7, non ★) : « Projets : n sur 2 réalisés » (projets_passes), quand les projets sont allumés
	if e.has_method("projets_actifs") and bool(e.call("projets_actifs")):
		var realises := 0
		for pp: Dictionary in e.projets_passes():
			if str(pp.get("statut", "")).begins_with("realise"):
				realises += 1
		var lproj := Style.label("Projets : %d sur %d réalisés" % [realises, Projets.donnees()["projets"].size()], 22 if compact else 24, Style.ui(), Style.TEXTE)
		lproj.name = "ProjetsRealises"
		v.add_child(lproj)
		infos_rue["projets"] = realises
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
