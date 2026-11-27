class_name ModaleReleveFin
extends RefCounted
## Morceau de Modales (T9) : le relevé de décembre (13 §3.4, détail des frais) et l'écran de fin de
## démonstration (13 §4.3 : patrimoine, Tata Livret, courbe des cinq ans, frais, phrase de synthèse).

var m: Modales
var bilan_force: Dictionary = {}   # captures : champs du bilan fabriqués, fusionnés sur le bilan réel
var infos_fin: Dictionary = {}     # contrôles : titre, pourquoi, record, projets, humeur


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
	v.add_child(Style.label(str(n.get("titre", "")).to_upper() + " · " + Noms.banquier_brut(), 22, Style.capitales(), Style.TEXTE_2))
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
	var lt := Style.label("LA RUE : VOUS ET VOS VOISINS", 24 if compact else 20, Style.capitales(), Style.TEXTE_2)
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
	var lr := Style.label("%s DE LA RUE SUR %d" % [BlocRue.rang_texte(rang), classement.size()], 28 if not compact else 26, Style.ui_gras(), Style.TEXTE)
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
	barres.taille_libelle = 26 if compact else 20
	barres.taille_valeur = 28 if compact else 24
	barres.largeur_libelle = 250.0 if not compact else 330.0
	barres.ligne_reference = ref
	barres.custom_minimum_size = Vector2(bloc.custom_minimum_size.x, 4.0 * (60.0 if compact else 48.0))
	barres.regler(lignes, a)
	barres_fin = barres


## Bilan de la fin : celui de Partie.partie_finie (avec le record écrit), sinon calculé ; bilan_force (captures) fusionné dessus.
func _bilan(e: EtatPartie) -> Dictionary:
	var b: Dictionary = m.dernier_bilan.duplicate(true) if not m.dernier_bilan.is_empty() else Bilan.calculer(e)
	if not b.has("record"):
		b["record"] = {"ecrit": false, "hors_record": not bool(b.get("record_possible", false)), "nouveau": false, "nouveau_titre": false}
	b.merge(bilan_force.duplicate(true), true)
	return b


## « + 12 % » / « − 3 % » (entier, signe) ; « 0 % » sans signe.
static func pct_texte(x: float) -> String:
	var n := roundi(x)
	if n == 0:
		return "0\u00A0%"
	return ("+ %d\u00A0%%" % n) if n > 0 else ("− %d\u00A0%%" % absi(n))


## Fin de partie (docs/29 §1) : titre d'époque, foyer, 4 barres, comparaison avec Tata Livret, record, détail.
func fin_demo(e: EtatPartie) -> void:
	infos_rue = {}
	infos_fin = {}
	barres_fin = null
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "fin"
	m.assombrir(0.65)
	var a := e.ab_courant()
	var b := _bilan(e)
	var titre_b: Dictionary = b.get("titre", {})
	var rec: Dictionary = b.get("record", {})
	var pct := float(b.get("ecart_tata_pct", 0.0))
	var vue := m.get_viewport_rect().size
	var p := PanelContainer.new()
	var sf := Style.panneau(22)
	# M5 : plusieurs titres (dix ans) au PC : plaques larges et basses, foyer étroit, courbe qui prend la hauteur restante ;
	# tout doit tenir sans défilement dans la zone la plus basse (972 px à 1152 × 648)
	var serre := not compact and (b.get("titres", []) as Array).size() > 1
	sf.content_margin_left = 20 if compact else 40
	sf.content_margin_right = 20 if compact else 40
	sf.content_margin_top = 8 if compact or serre else 30
	sf.content_margin_bottom = 8 if compact or serre else 30
	p.add_theme_stylebox_override("panel", sf)
	var largeur := (vue.x - 24.0) if compact else minf(1500.0, vue.x - 60.0)   # téléphone : toute la largeur libre
	p.custom_minimum_size = Vector2(largeur, (vue.y - 12.0) if compact else 0.0)
	var interieur := largeur - (40.0 if compact else 80.0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6 if compact else (6 if serre else 12))
	p.add_child(v)
	# En-tête : Atkinson gras (il contient un chiffre : jamais Pixelify)
	var duree := _duree(b)
	var titre := Style.label("%s · %s DE LA VIE DE %s" % [Dates.texte(a).to_upper(), duree.to_upper(), e.prenom().to_upper()], 28 if compact else 36, Style.ui_gras(), Style.ACCENT)
	if serre:
		titre.add_theme_font_size_override("font_size", 32)
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(titre)
	var val := Style.label(Format.montant(0.0, a), 52 if compact else 60, Style.chiffres(), Style.TEXTE)
	val.name = "Patrimoine"
	var patr := e.patrimoine(e.joueur)
	# Plusieurs chapitres : au PC les deux lignes de record (chapitre, partie) se rangent sous la plaque de leur titre ; au téléphone elles vont dans le récap
	_records_separes = []
	_etats_records = []
	var multi := (b.get("titres", []) as Array).size() > 1 and not bool(rec.get("hors_record", false))
	var plaques_l := (interieur - 18.0 - FOYER_ETROIT) if serre else 870.0
	var ligne_record := _lignes_records(b, rec, compact, (interieur - 24.0) if compact else (floorf((plaques_l - 14.0) / 2.0) - 54.0 if serre else floorf((870.0 - 14.0) / 2.0) - 60.0))
	var foyer := _bloc_foyer(e, b, compact, interieur - 24.0 - 40.0 - 110.0, serre)
	var plaque: Control = _plaques(b, rec, compact, foyer, plaques_l if not compact else interieur - 24.0) if not titre_b.is_empty() else null
	infos_fin = {"titre": str(titre_b.get("nom", "")), "pourquoi": plaque != null and str(titre_b.get("pourquoi", "")) != ""}
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 24)
	var bloc := VBoxContainer.new()
	bloc.add_theme_constant_override("separation", 2 if serre else 6)
	var gauche := 870.0 if not compact else interieur - 24.0
	var droite_l := interieur - gauche - 24.0   # PC : colonne de droite
	bloc.custom_minimum_size.x = gauche
	var barres := Barres.new()
	var classement: Array = fab_rue if not fab_rue.is_empty() else (e.classement_rue() if e.has_method("classement_rue") else [])
	var details_rue: Array = []   # réplique et argent mis de côté : sous les barres au PC, dans la zone qui défile au téléphone
	if classement.is_empty():
		bloc.add_child(Style.label("VOUS ET TATA LIVRET (TOUT AU LIVRET A)", 18, Style.capitales(), Style.TEXTE_2))
		barres.custom_minimum_size = Vector2(bloc.custom_minimum_size.x, 96 if compact else 110)
		barres.regler([["VOUS", patr, Style.ACCENT], ["TATA LIVRET", e.patrimoine(e.temoins["livret"]), Courbe.COULEUR_REF]], a)
	else:
		_bloc_rue(bloc, barres, classement, compact, a)
		if serre:
			barres.custom_minimum_size.y = 4.0 * 44.0
	bloc.add_child(barres)
	if not classement.is_empty():
		var rep: Dictionary = Quartier.replique_rue(classement)
		if not rep.is_empty() and str(rep.get("texte", "")) != "":
			var hr := HBoxContainer.new()
			hr.name = "RepliqueRue"
			hr.add_theme_constant_override("separation", 9)
			hr.add_child(BlocRue.pastille(str(rep.get("qui", "")), str({"jeanmi": "J", "livret": "T", "matelas": "M"}.get(str(rep.get("qui", "")), str(rep.get("nom", "?")).left(1))), 30.0))
			var lr := Style.label("%s : « %s »" % [str(rep["nom"]), str(rep["texte"])], 26 if compact else 22, Style.ui(), Style.TEXTE)
			lr.name = "TexteReplique"
			lr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lr.custom_minimum_size.x = (interieur - 24.0 - 56.0) if compact else gauche - 50.0
			lr.max_lines_visible = 3 if compact else 2
			lr.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			hr.add_child(lr)
			details_rue.append(hr)
		infos_rue.merge({"rang": BlocRue._rang_de(classement), "total": classement.size(), "replique": not rep.is_empty()}, true)
	details_rue.append(Style.label("Argent mis de côté en %s : " % duree + Format.montant(e.epargne_nette, a), 24 if compact else 18, Style.ui(), Style.TEXTE_2))
	var comparaison := _bloc_comparaison_livret(e, a, pct, (interieur - 24.0 - 640.0 - 24.0 - 80.0) if compact else droite_l - 110.0)
	var courbe := _courbe_cinq_ans(e, duree, 110.0 if serre else 150.0, serre)
	# Détail : frais, produits, exemple, phrase de synthèse
	var detail: Array = _lignes_detail(e, a, compact, interieur)
	if serre and not detail.is_empty():
		# dix ans au PC : « Argent mis de côté » rejoint la ligne des frais et des produits (une ligne de hauteur gagnée)
		var mis: Control = details_rue.pop_back()
		var infos := detail[0] as Control
		mis.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		infos.add_child(mis)
		infos.move_child(mis, 1)
	var boutons := HBoxContainer.new()
	boutons.add_theme_constant_override("separation", 16)
	var rejouer := Style.bouton("REJOUER AUTREMENT", true, 72 if compact else (68 if serre else 80))
	rejouer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rejouer.pressed.connect(m.fermer.bind("rejouer"))
	var quitter := Style.bouton("QUITTER", false, 72 if compact else (68 if serre else 80))
	quitter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quitter.pressed.connect(m.fermer.bind("quitter"))
	boutons.add_child(rejouer)
	boutons.add_child(quitter)
	if not compact:
		# PC : bande titre + foyer, puis deux colonnes (la rue | le patrimoine, la comparaison, le record, la courbe), puis le détail
		var bande := HBoxContainer.new()
		bande.add_theme_constant_override("separation", 18)
		v.add_child(bande)
		if plaque != null:
			plaque.custom_minimum_size.x = plaques_l
			bande.add_child(plaque)
		foyer.custom_minimum_size.x = interieur - 18.0 - plaques_l if plaque != null else interieur
		bande.add_child(foyer)
		ligne.name = "Defilant"
		v.add_child(ligne)
		for c: Control in details_rue:
			bloc.add_child(c)
		ligne.add_child(bloc)
		var droite := VBoxContainer.new()
		droite.add_theme_constant_override("separation", 3 if serre else 8)
		droite.custom_minimum_size.x = droite_l
		var lp := HBoxContainer.new()
		lp.add_child(Style.label("VOTRE PATRIMOINE", 20, Style.capitales(), Style.TEXTE_2))
		val.add_theme_font_size_override("font_size", 52)
		val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lp.add_child(val)
		droite.add_child(lp)
		droite.add_child(comparaison)
		if ligne_record != null and not multi:
			droite.add_child(ligne_record)
		droite.add_child(courbe)
		ligne.add_child(droite)
		for c: Control in detail:
			v.add_child(c)
		v.add_child(boutons)
	else:
		# Téléphone (recette 0.6, « l'écran de fin est petit ») : toute la largeur, une seule zone qui défile avec le récap en
		# premier et en gros (titre, patrimoine, comparaison, record, rue), le décoratif (portrait réduit, courbe) à la fin.
		var defile := ScrollContainer.new()
		defile.name = "Defilant"
		defile.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		defile.size_flags_vertical = Control.SIZE_EXPAND_FILL
		defile.custom_minimum_size = Vector2(0, 96)
		var dv := VBoxContainer.new()
		dv.add_theme_constant_override("separation", 10)
		dv.custom_minimum_size.x = interieur - 24.0
		defile.add_child(dv)
		if plaque != null and not multi:
			dv.add_child(plaque)
		elif plaque == null:
			dv.add_child(foyer)
		var lp := HBoxContainer.new()
		lp.add_theme_constant_override("separation", 24)
		var lpv := VBoxContainer.new()
		lpv.add_theme_constant_override("separation", 0)
		lpv.add_child(Style.label("VOTRE PATRIMOINE", 24, Style.capitales(), Style.TEXTE_2))
		lpv.add_child(val)
		lp.add_child(lpv)
		comparaison.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lp.add_child(comparaison)
		dv.add_child(lp)
		if ligne_record != null:
			dv.add_child(ligne_record)
		if plaque != null and multi:
			dv.add_child(plaque)   # plusieurs titres : le récap (patrimoine, écart, records) passe d'abord, les plaques ensuite
		bloc.custom_minimum_size.x = interieur - 24.0
		dv.add_child(bloc)
		if plaque != null and foyer.has_meta("ligne"):
			var lf := foyer.get_meta("ligne") as Label
			lf.get_parent().remove_child(lf)
			lf.custom_minimum_size.x = interieur - 24.0
			dv.add_child(lf)
		for c: Control in details_rue:
			dv.add_child(c)
		var liste := _liste_projets(b, true, 24)
		if liste != null:
			dv.add_child(liste)
		for c: Control in detail:
			dv.add_child(c)
		dv.add_child(courbe)
		v.add_child(defile)
		v.add_child(boutons)
	infos_fin["record"] = _etat_record(rec)
	if multi:
		infos_fin["records"] = _etats_records
	infos_fin["plaques"] = maxi(1, (b.get("titres", []) as Array).size()) if not titre_b.is_empty() else 0
	infos_fin["projets"] = "%d/%d" % [int((b.get("projets", {}) as Dictionary).get("realises", 0)), int((b.get("projets", {}) as Dictionary).get("total", 0))]
	infos_fin["humeur"] = int(b.get("humeur_fin", 1))
	infos_fin["collection"] = bool(rec.get("nouveau_titre", false))
	infos_fin["pct"] = pct_texte(pct)
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


## Frais, produits découverts, exemple (frais nuls), phrase d'inflation et phrase de synthèse.
func _lignes_detail(e: EtatPartie, a: int, compact: bool, interieur: float) -> Array:
	var out: Array = []
	var frais := e.frais_payes()
	var infos: BoxContainer = VBoxContainer.new() if compact else HBoxContainer.new()
	infos.add_theme_constant_override("separation", 30)
	var lf := Style.label("Frais payés : %s  ·  Tata Livret : 0 F" % Format.entier(frais, a), 26 if compact else 24, Style.chiffres(), Style.CUIVRE)
	lf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	infos.add_child(lf)
	var utilises: Array = e.stats.get("utilises", [])
	var lprod := Style.label("Produits découverts %d/%d · utilisés %d/%d" % [Banquier.nb_decouverts(e), Banquier.ordre_carnet().size(), utilises.size(), Banquier.ordre_carnet().size()], 26 if compact else 24, Style.ui(), Style.TEXTE)
	infos.add_child(lprod)
	out.append(infos)
	if frais <= 0.005:
		var ex := Banquier.piles("sicav", Produits.f(10000.0), a)
		var lx := Style.label("Exemple : 10 000 F placés 20 ans à 7 %% par an (une hypothèse, pas une promesse) : %s sans frais, %s avec une SICAV à 2 %% + 1,5 %%/an, %s avec une plus chargée." % [
			Format.entier(ex["sans"], a), Format.entier(ex["produit"], a), Format.entier(ex["charge"], a)], 22 if compact else 20, Style.ui(), Style.TEXTE_2)
		lx.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lx.custom_minimum_size.x = interieur - (24.0 if compact else 0.0)
		out.append(lx)
	var phrase := Style.label(_phrase_synthese(e, a), 26 if compact else 24, Style.ui(), Style.TEXTE)
	phrase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phrase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	phrase.custom_minimum_size.x = interieur - (24.0 if compact else 0.0)
	out.append(phrase)
	return out


var _etats_records: Array = []      # états des deux lignes de record (chapitre, partie), recopiés dans infos_fin
var _records_separes: Array = []   # PC, plusieurs chapitres : [ligne du record de chapitre, ligne du record de partie] (rangées sous les plaques)


## Durée jouée en lettres (« cinq ans », « dix ans ») d'après les années du bilan ; cinq ans sans ces champs.
func _duree(b: Dictionary) -> String:
	if not b.has("annee_depart") or not b.has("annee_fin"):
		return "cinq ans"
	return Noms.duree_texte(int(b["annee_fin"]) - int(b["annee_depart"]) + 1)


## Une plaque de titre par chapitre traversé (bilan["titres"], lot 10b I7 ; docs/40 §2) ; un seul titre : la plaque de toujours.
## PC : les plaques côte à côte dans la largeur de la plaque unique ; téléphone : l'une sous l'autre (le portrait reste dans la 1re).
func _plaques(b: Dictionary, rec: Dictionary, compact: bool, foyer: Control, largeur: float) -> Control:
	var titres: Array = b.get("titres", [])
	if titres.size() <= 1:
		return _plaque_titre(b, rec, compact, foyer, largeur)
	var nouveaux: Array = rec.get("nouveaux_titres", [])
	var boite: BoxContainer = VBoxContainer.new() if compact else HBoxContainer.new()
	boite.name = "PlaquesTitres"
	boite.add_theme_constant_override("separation", 10 if compact else 14)
	var l_une := largeur if compact else floorf((largeur - 14.0 * (titres.size() - 1)) / titres.size())
	for t: Dictionary in titres:
		var est_nouveau := 0
		for nv: Dictionary in nouveaux:
			if str(nv.get("id", "")) == str(t.get("id", "")) and str(nv.get("chapitre", "")) == str(t.get("chapitre", "")):
				est_nouveau = 1
		var pl := _plaque_titre(b, rec, compact, foyer, l_une, t, Noms.annees_chapitre(str(t.get("chapitre", ""))), est_nouveau)
		pl.name = "PlaqueTitre_%s" % str(t.get("chapitre", ""))
		pl.custom_minimum_size.x = l_une
		var k := boite.get_child_count()
		if k < _records_separes.size():
			(pl.find_child("ColPlaque", true, false) as Control).add_child(_records_separes[k])
		boite.add_child(pl)
	return boite


## Plaque du titre d'époque : nom, « pourquoi » ; au téléphone, le portrait et la ligne du foyer y sont repliés.
func _plaque_titre(b: Dictionary, rec: Dictionary, compact: bool, foyer: Control, largeur: float, t_force := {}, annees := "", nouveau := -1) -> Control:
	var t: Dictionary = t_force if not t_force.is_empty() else b["titre"]
	var pc := PanelContainer.new()
	pc.name = "PlaqueTitre"
	pc.add_theme_stylebox_override("panel", Style.carte())
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	pc.add_child(h)
	if compact and foyer.has_meta("portrait") and (foyer.get_meta("portrait") as Control).get_parent() != null:
		var portrait: Control = foyer.get_meta("portrait")
		portrait.get_parent().remove_child(portrait)
		portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		h.add_child(portrait)
	var col_w := largeur - 54.0 - (110.0 if compact else 0.0)
	var col := VBoxContainer.new()
	col.name = "ColPlaque"
	col.add_theme_constant_override("separation", 4)
	col.custom_minimum_size.x = col_w
	h.add_child(col)
	var ligne1 := HBoxContainer.new()
	ligne1.add_theme_constant_override("separation", 14)
	var l1 := Style.label("VOTRE TITRE D'ÉPOQUE" + ((" · " + annees) if annees != "" else ""), 24 if compact else 20, Style.capitales(), Style.ACCENT)
	l1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ligne1.add_child(l1)
	ligne1.custom_minimum_size.x = col_w
	var badge: PanelContainer = null
	if (bool(rec.get("nouveau_titre", false)) if nouveau < 0 else nouveau == 1):
		var nv := PanelContainer.new()
		nv.name = "NouveauCollection"
		nv.add_theme_stylebox_override("panel", _plaque_ambre(4))
		nv.add_child(Style.label("NOUVEAU DANS LA COLLECTION" if annees == "" else "NOUVEAU", 24 if compact else 20, Style.capitales(), Style.ENCRE))
		var police := Style.capitales()
		var entier_l: float = police.get_string_size(l1.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + police.get_string_size("NOUVEAU", HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 30.0 + 24.0
		if annees == "" or (not compact and entier_l <= col_w):
			ligne1.add_child(nv)
		else:
			badge = nv   # plaque étroite : le badge passe sous le nom
	col.add_child(ligne1)
	var nom := Style.label(str(t.get("nom", "")).to_upper(), 40 if compact else (32 if annees != "" else 48), Style.neon(), Style.TEXTE)
	nom.name = "NomTitre"
	nom.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nom.custom_minimum_size.x = col_w
	nom.max_lines_visible = 2
	col.add_child(nom)
	var pq := Style.label("« %s »" % str(t.get("pourquoi", "")), 26 if compact else (22 if annees != "" else 24), Style.ui(), Style.TEXTE)
	pq.name = "PourquoiTitre"
	pq.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pq.custom_minimum_size.x = col_w
	col.add_child(pq)
	if badge != null:
		badge.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		col.add_child(badge)
	return pc


const FOYER_ETROIT := 380.0   # PC, plusieurs titres : largeur de la carte du foyer à côté des deux plaques


## Le foyer : portrait de Sylvie (humeur de fin), phrase d'humeur, projets réalisés, une ligne par projet (PC).
## `etroit` (PC, plusieurs titres) : portrait à côté de l'humeur, liste des projets en dessous sur toute la largeur, sans coupure.
## Au téléphone : le portrait et une ligne « humeur · projets » sont repris par la plaque du titre (méta « portrait », « ligne »).
func _bloc_foyer(e: EtatPartie, b: Dictionary, compact: bool, larg_ligne: float, etroit := false) -> Control:
	var pc := PanelContainer.new()
	pc.name = "BlocFoyer"
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.set_border_width_all(3)
	sb.border_color = PalettePixel.couleur("zinc_clair")
	sb.set_content_margin_all(12)
	pc.add_theme_stylebox_override("panel", sb)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	pc.add_child(h)
	var proj: Dictionary = b.get("projets", {})
	var total := int(proj.get("total", 0))
	var realises := int(proj.get("realises", 0))
	var visage: Control = null
	if e.has_method("cartes_actives") and e.cartes_actives():
		visage = CadresPixel.icone(Noms.portrait_proche(e) + ModaleCarte.nom_humeur(int(b.get("humeur_fin", e.humeur_visible()))), {}, 2 if compact or etroit else 3)   # téléphone : plus petit, le récap passe avant
		visage.name = "VisageSylvie"
		visage.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		infos_rue["visage"] = true
	var phrase_projets := ""
	if total > 0:
		phrase_projets = "Projets : %d sur %d réalisé%s" % [realises, total, "" if realises <= 1 else "s"]
		infos_rue["projets"] = realises
	var humeur := str(b.get("humeur_phrase", ""))
	if compact:
		var ligne := Style.label(" · ".join(PackedStringArray([humeur, phrase_projets].filter(func(s: String) -> bool: return s != ""))), 26 if compact else 20, Style.ui(), Style.TEXTE)
		ligne.name = "LigneFoyer"
		ligne.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ligne.custom_minimum_size.x = larg_ligne
		pc.set_meta("ligne", ligne)
		if visage != null:
			pc.set_meta("portrait", visage)
			h.add_child(visage)
		var col0 := VBoxContainer.new()
		col0.add_child(ligne)
		var lp := _liste_projets(b, false)
		if lp != null:
			col0.add_child(lp)
		h.add_child(col0)
		return pc
	if visage != null:
		h.add_child(visage)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(col)
	col.add_child(Style.label("LE FOYER", 20, Style.capitales(), Style.TEXTE_2))
	if humeur != "":
		var lh := Style.label(humeur, 22, Style.ui(), Style.TEXTE)
		lh.name = "HumeurFin"
		col.add_child(lh)
	if phrase_projets != "":
		var lpj := Style.label(phrase_projets, 22, Style.ui_gras(), Style.TEXTE)
		lpj.name = "ProjetsRealises"
		col.add_child(lpj)
	var liste := _liste_projets(b, true, 20, FOYER_ETROIT - 30.0 if etroit else 0.0)
	if liste != null:
		if etroit:
			var pile := VBoxContainer.new()
			pile.add_theme_constant_override("separation", 8)
			pc.remove_child(h)
			pc.add_child(pile)
			pile.add_child(h)
			pile.add_child(liste)
		else:
			col.add_child(liste)
	return pc


## Pastille pleine ambre (texte encre) : récompense, jamais une cible.
static func _plaque_ambre(marge_v: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Style.ACCENT
	sb.content_margin_left = 15
	sb.content_margin_right = 15
	sb.content_margin_top = marge_v
	sb.content_margin_bottom = marge_v
	return sb


## Une ligne par projet : nom court et état en mots (réalisé, reporté, abandonné), jamais par la couleur seule.
## `largeur` > 0 : la ligne passe à la ligne dans cette largeur au lieu d'être coupée.
func _liste_projets(b: Dictionary, avec: bool, taille := 20, largeur := 0.0) -> Control:
	var proj: Dictionary = b.get("projets", {})
	var liste: Array = proj.get("liste", [])
	if liste.is_empty() or not avec:
		return null
	var col := VBoxContainer.new()
	col.name = "ListeProjets"
	for it: Dictionary in liste:
		var etat := str(it.get("etat", ""))
		var mot := "réalisé" if etat.begins_with("realise") else ("abandonné" if etat.begins_with("abandon") else "pas réalisé")
		var l := Style.label("%s : %s" % [str(it.get("nom", "")), mot], taille, Style.ui(), Style.TEXTE_2 if taille <= 20 else Style.TEXTE)
		if largeur > 0.0:
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.custom_minimum_size.x = largeur
		else:
			l.clip_text = true
			l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			l.custom_minimum_size.x = 60
		col.add_child(l)
	return col


func _etat_record(rec: Dictionary) -> String:
	if bool(rec.get("hors_record", false)):
		return "hors"
	if bool(rec.get("nouveau", false)):
		return "nouveau"
	if not (rec.get("record", {}) as Dictionary).is_empty():
		return "ancien"
	return "aucun"


## Records d'une partie qui traverse plusieurs chapitres (lot 10b I7 ; docs/40 §3) : deux lignes légendées, « record de chapitre »
## (écart à la fin des 5 ans du chapitre de départ) et « record de partie » (écart à la fin de la partie, rangé par année de fin) ;
## un seul chapitre, ou hors record : la ligne unique de toujours.
func _lignes_records(b: Dictionary, rec: Dictionary, compact: bool, larg: float) -> Control:
	if (b.get("titres", []) as Array).size() <= 1 or bool(rec.get("hors_record", false)):
		return _ligne_record(rec, compact, larg)
	var boite := VBoxContainer.new()
	boite.name = "LignesRecords"
	boite.add_theme_constant_override("separation", 10 if compact else 8)
	var chap := str(b.get("chapitre_depart", ""))
	var l1 := _ligne_record(rec, compact, larg, false, not compact)
	var leg1 := Style.label("RECORD DE CHAPITRE · " + Noms.annees_chapitre(chap), 20, Style.capitales(), Style.TEXTE_2)
	boite.add_child(leg1)
	if l1 != null:
		boite.add_child(l1)
	var stock: Dictionary = Records.lire(Partie.chemin_records)
	var parties: Dictionary = ((stock.get("chapitres", {}) as Dictionary).get(chap, {}) as Dictionary).get("records_partie", {})
	var rp: Dictionary = parties.get(str(int(b.get("annee_fin", 0))), b.get("record_partie", {}))
	var rec2 := {"hors_record": false, "nouveau": bool(rec.get("nouveau_partie", false)), "record": rp, "ancien": {}, "sans_suffixe": true}
	var l2 := _ligne_record(rec2, compact, larg, false, not compact)
	var leg2 := Style.label("RECORD DE PARTIE · %d-%d" % [int(b.get("annee_depart", 0)), int(b.get("annee_fin", 0))], 20, Style.capitales(), Style.TEXTE_2)
	boite.add_child(leg2)
	if l2 != null:
		boite.add_child(l2)
	_etats_records = [_etat_record(rec), _etat_record(rec2)]
	if not compact:
		# PC : une ligne sous chaque plaque (chapitre sous le titre du 1er chapitre, partie sous le dernier) : _plaques les range
		var c1 := VBoxContainer.new()
		var c2 := VBoxContainer.new()
		for n in [leg1, l1]:
			if n != null:
				boite.remove_child(n)
				c1.add_child(n)
		for n in [leg2, l2]:
			if n != null:
				boite.remove_child(n)
				c2.add_child(n)
		_records_separes = [c1, c2]
		boite.free()
		return null
	return boite


## Ligne du record (docs/29 §1.4), états exclusifs ; null quand il n'y a rien à dire.
## `fleche_collee` : la flèche précède le texte sur la même ligne au lieu d'occuper une ligne à elle seule.
func _ligne_record(rec: Dictionary, compact: bool, larg: float, en_ligne := false, fleche_collee := false) -> Control:
	var etat := _etat_record(rec)
	if etat == "aucun":
		return null
	var r: Dictionary = rec.get("record", {})
	var h: BoxContainer = HBoxContainer.new() if (compact or en_ligne) else VBoxContainer.new()   # PC : colonne étroite, la pastille puis le texte
	h.name = "LigneRecord"
	h.add_theme_constant_override("separation", 12 if compact else 4)
	var t := 28 if compact else 24
	if etat == "hors":
		var pc := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.set_border_width_all(3)
		sb.border_color = PalettePixel.couleur("zinc_clair")
		sb.set_content_margin_all(8)
		pc.add_theme_stylebox_override("panel", sb)
		var lh := Style.label("Partie rejouée depuis une sauvegarde : hors record", 26 if compact else 22, Style.ui(), Style.TEXTE)
		lh.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lh.custom_minimum_size.x = larg - 50.0
		pc.add_child(lh)
		h.add_child(pc)
		return h
	var x := float(r.get("ecart_pct", 0.0))
	var positif := roundi(x) > 0
	var c := Style.TEXTE
	if etat == "nouveau":
		var nv := PanelContainer.new()
		nv.name = "NouveauRecord"
		nv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nv.add_theme_stylebox_override("panel", _plaque_ambre(6))
		nv.add_child(Style.label("NOUVEAU RECORD !", 28, Style.neon(), Style.ENCRE))
		h.add_child(nv)
	else:
		c = Style.TEXTE_2
		h.add_child(Style.label("Votre record :", t - 2, Style.ui(), Style.TEXTE_2))
	var cible: BoxContainer = h
	if fleche_collee:
		cible = HBoxContainer.new()
		cible.add_theme_constant_override("separation", 8)
		h.add_child(cible)
	if roundi(x) != 0:
		cible.add_child(ModaleOutils.fleche(positif, c))
	var texte := "%s face à Tata Livret" % pct_texte(x)
	if etat == "nouveau":
		var ancien: Dictionary = rec.get("ancien", {})
		if ancien.is_empty():
			if not bool(rec.get("sans_suffixe", false)):
				texte += " · votre premier résultat enregistré"
		else:
			texte += " (ancien : %s)" % pct_texte(float(ancien.get("ecart_pct", 0.0)))
	else:
		var tn := str(r.get("titre_nom", ""))
		if int(r.get("rang", 0)) > 0:
			texte += " (%s de la rue%s)" % [BlocRue.rang_texte(int(r["rang"])), (", " + tn) if tn != "" else ""]
		elif tn != "":
			texte += " (%s)" % tn
	var l := Style.label(texte, t - (2 if etat != "nouveau" else 0), Style.ui_gras() if etat == "nouveau" else Style.ui(), c)
	l.name = "TexteRecord"
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = (larg - 60.0 - 300.0) if (compact or en_ligne) else larg - (50.0 if fleche_collee else 20.0)
	cible.add_child(l)
	return h


## « Cinq ans en un coup d'œil » (PC seulement) : la courbe du joueur et celle de Tata Livret.
## `serre` (dix ans au PC) : légende sur la ligne du titre, la courbe prend toute la hauteur qui reste dans la colonne.
func _courbe_cinq_ans(e: EtatPartie, duree := "cinq ans", haut := 150.0, serre := false) -> VBoxContainer:
	var droite := VBoxContainer.new()
	droite.name = "BlocCourbe"
	droite.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var titre := Style.label("%s EN UN COUP D'ŒIL" % duree.to_upper(), 18, Style.capitales(), Style.TEXTE_2)
	var leg := HBoxContainer.new()
	leg.name = "LegendeCourbe"
	leg.add_theme_constant_override("separation", 18)
	if serre:
		droite.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var tete := HBoxContainer.new()
		titre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tete.add_child(titre)
		tete.add_child(leg)
		droite.add_child(tete)
	else:
		droite.add_child(titre)
	var courbe := Courbe.new()
	courbe.name = "CourbeFin"
	courbe.custom_minimum_size = Vector2(0, haut)
	if serre:
		courbe.size_flags_vertical = Control.SIZE_EXPAND_FILL
	courbe.total_mois = e.m_fin - e.m_depart
	var vals: Array = e.hist["j"].slice(e.m_depart, e.m + 1)
	var ref: Array = e.hist["livret"].slice(e.m_depart, e.m + 1)
	courbe.regler(vals, [], e.ab_de(e.m_depart), 0.0, ref)
	courbe.ecart_impose = e.ecart_livret()
	droite.add_child(courbe)
	leg.add_child(Style.label("— Vous", 22 if m.compact else 18, Style.ui(), Style.ACCENT))
	leg.add_child(Style.label("— Tata Livret", 22 if m.compact else 18, Style.ui(), Courbe.COULEUR_REF))
	if not serre:
		droite.add_child(leg)
	return droite


## Une seule phrase de synthèse, choisie par règle, jamais de reproche (13 §4.3).
func _phrase_synthese(e: EtatPartie, a: int) -> String:
	var ecart := e.ecart_livret()
	var x := Format.ecart(absf(ecart), a).trim_prefix("+")
	if Format.en_devise(ecart, Format.devise(a)) >= 0.5:
		var an_krach := Noms.annee_krach()
		if an_krach > 0:
			return "« Vos placements ont fait mieux que le Livret A de %s, krach de %d compris. »" % [x, an_krach]
		return "« Vos placements ont fait mieux que le Livret A de %s. »" % x
	if Format.en_devise(ecart, Format.devise(a)) <= -0.5:
		return "« Cette fois, le Livret A a fait mieux de %s. Les frais et le krach sont passés par là : rejouez pour voir ce qui change. »" % x
	return "« Vous avez fait comme Tata Livret : sûr et sans frais. Et si vous essayiez autre chose ? »"


## Fin de démo (12 §3.5) : une seule comparaison, avec « tout au Livret A » (Tata Livret).
func _bloc_comparaison_livret(e: EtatPartie, a: int, pct := 0.0, larg := 400.0) -> PanelContainer:
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
		verdict = "VOUS : %s de plus que Tata Livret (%s)" % [Format.ecart(ecart, a).trim_prefix("+"), pct_texte(pct)]
	elif sens < 0:
		verdict = "VOUS : %s de moins que Tata Livret (%s)" % [Format.ecart(-ecart, a).trim_prefix("+"), pct_texte(pct)]
	var lv := Style.label(verdict, 28 if m.compact else 24, Style.chiffres(), c)
	lv.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lv.custom_minimum_size.x = larg
	h.add_child(lv)
	p.add_child(h)
	return p
