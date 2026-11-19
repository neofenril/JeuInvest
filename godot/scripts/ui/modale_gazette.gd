class_name ModaleGazette
extends ModaleCarte
## « Le krach, un an après » (lot 06, 05-I R6 ; docs/24 §2.5, lot_06 E6 et A6 ; contrat lot_05 §4.3) : la fiche de la Gazette d'octobre 1988,
## trois barres horizontales (vendu, rien, renforcé : JAMAIS triées), la barre du choix du joueur en ambre, cadre encre 2 t et « VOTRE CHOIX »,
## aucune couleur de gain ou de perte, aucun écart calculé : le joueur compare les longueurs, le texte du moteur dit le reste.
## Même grammaire que la carte de dilemme (papier crème, liseré de la source média, apparition sur place, sans animation) ; ni Échap ni
## clic extérieur ; J'AI COMPRIS (touche 1 ou Entrée) émet choix_fait("gazette", "ok") ; conclure : fondu ≤ 0,2 s, rien d'autre.

var barres_vues: Array = []      # [{id, titre, valeur_txt, choisi}] dans l'ordre affiché (lu par les captures et les tests)
var base_txt := ""
var n_entourees := 0
var _zone_barres: Array = []     # Controls de barre (dessin)


func _init(modales: Modales) -> void:
	super(modales)
	genre_emis = "gazette"


## Dessin d'une barre : rectangle plein (graphique lisse), contour encre, gris d'ardoise ou ambre si choisie ; valeur ≤ 0 : pas de barre ;
## repère `base` en pointillé encre.
func _dessiner_barre(c: Control, valeur: float, maxi: float, base: float, choisie: bool) -> void:
	var h := floorf(c.size.y / 3.0) * 3.0
	var w := floorf(c.size.x / 3.0) * 3.0
	var y := floorf((c.size.y - h) / 2.0)
	if valeur > 0.0 and maxi > 0.0:
		var lw := maxf(3.0, floorf(w * valeur / maxi / 3.0) * 3.0)
		c.draw_rect(Rect2(0, y, lw, h), PalettePixel.couleur("ambre") if choisie else PalettePixel.couleur("ardoise"))
		c.draw_rect(Rect2(0, y, lw, h), Style.ENCRE, false, 3.0)
	c.draw_rect(Rect2(0, y, 3, h), Style.ENCRE)   # axe à 0
	if base > 0.0 and maxi > 0.0:
		var bx := floorf(w * base / maxi / 3.0) * 3.0
		var k := 0.0
		while k < c.size.y:
			c.draw_rect(Rect2(bx, k, 3, minf(6.0, c.size.y - k)), Style.ENCRE)
			k += 9.0


func ouvrir(c: Dictionary, depart: Vector2, lecture := false) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "info" if lecture else "gazette"
	m.carte_en_cours = true
	phase = "entree"
	refus = 0
	_passer = false
	boutons.clear()
	choix.clear()
	ordre.clear()
	barres_vues.clear()
	n_entourees = 0
	m.assombrir(0.45 if lecture else 0.6)
	var a := int(c.get("ab", Partie.etat.ab_courant() if Partie.etat != null else 0))
	var vue := m.get_viewport_rect().size
	var largeur := floorf(minf(1356.0 if compact else 1176.0, vue.x - 30.0) / 3.0) * 3.0
	var interieur := largeur - 66.0
	_panel = PanelContainer.new()
	_panel.name = "PapierGazette"
	_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_panel.add_theme_stylebox_override("panel", Style.papier("media", 30.0, 18.0 if compact else 24.0))
	_panel.custom_minimum_size = Vector2(largeur, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4 if compact else 8)
	_panel.add_child(v)
	v.add_child(Style.label("LA GAZETTE · " + str(c.get("date", "")).to_upper(), 20, Style.capitales(), Style.TEXTE_PAPIER_2))
	var titre := Style.label(str(c.get("titre", "")).to_upper(), 36 if compact else 48, Style.capitales(), Style.ENCRE)
	titre.name = "Titre"
	titre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titre.custom_minimum_size.x = interieur
	v.add_child(titre)
	var zone_texte := VBoxContainer.new()
	zone_texte.name = "Defilant"
	zone_texte.add_theme_constant_override("separation", 4)
	_texte = Style.label(str(c.get("texte", "")), 22 if compact else 24, Style.ui(), Style.ENCRE)
	_texte.name = "Texte"
	_texte.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texte.custom_minimum_size.x = interieur
	zone_texte.add_child(_texte)
	var mention := str(c.get("mention", ""))
	if mention != "":
		var lm := Style.label(mention, 22, Style.ui(), Style.TEXTE_PAPIER_2)
		lm.name = "Mention"
		lm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lm.custom_minimum_size.x = interieur
		zone_texte.add_child(lm)
	v.add_child(zone_texte)
	# Graphique : légende, repère « au krach », 3 lignes
	var base := float(c.get("base", 0.0))
	var barres: Array = c.get("barres", [])
	var maxi := base
	for b: Dictionary in barres:
		maxi = maxf(maxi, float(b.get("valeur", 0.0)))
	var tete := HBoxContainer.new()
	var mois_k := Noms.texte_mois_krach(true)
	var de_mois := ("D'" if mois_k.left(1) in ["A", "E", "I", "O", "U"] else "DE ") + mois_k
	var lt := Style.label("VOS PLACEMENTS EN BOURSE %s, UN AN APRÈS" % de_mois, 20, Style.capitales(), Style.TEXTE_PAPIER_2)
	lt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lt.clip_text = true
	lt.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	lt.custom_minimum_size.x = 60
	tete.add_child(lt)
	base_txt = ""
	if base > 0.0:
		base_txt = "au krach : %s" % Format.entier(base, a)
		var lb := Style.label(base_txt, 20, Style.ui(), Style.ENCRE)
		lb.name = "RepereBase"
		tete.add_child(lb)
	v.add_child(tete)
	var graphique := VBoxContainer.new()
	graphique.name = "Graphique"
	graphique.add_theme_constant_override("separation", 6 if compact else 9)
	var col_titre := 330.0 if compact else 240.0   # téléphone : « VOTRE CHOIX » à côté du titre (une seule ligne par barre)
	var col_valeur := 150.0 if compact else 180.0
	var haut_ligne := 48.0 if compact else 60.0
	for b: Dictionary in barres:
		var choisi := bool(b.get("choisi", false))
		var ligne := PanelContainer.new()
		ligne.name = "Ligne_" + str(b.get("id", ""))
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.set_border_width_all(6 if choisi else 0)
		sb.border_color = Style.ENCRE
		sb.content_margin_left = 6
		sb.content_margin_right = 6
		ligne.add_theme_stylebox_override("panel", sb)
		var h := HBoxContainer.new()
		h.custom_minimum_size.y = haut_ligne
		h.add_theme_constant_override("separation", 12)
		var ct: BoxContainer = HBoxContainer.new() if compact else VBoxContainer.new()
		ct.custom_minimum_size.x = col_titre
		ct.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ct.add_theme_constant_override("separation", 9 if compact else 0)
		var ltitre := Style.label(str(b.get("titre", "")), 22, Style.ui_gras(), Style.ENCRE)
		ltitre.name = "TitreBarre"
		ct.add_child(ltitre)
		if choisi:
			n_entourees += 1
			var pc := PanelContainer.new()
			pc.name = "VotreChoix"
			pc.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			var sv := StyleBoxFlat.new()
			sv.bg_color = PalettePixel.couleur("ambre")
			sv.set_border_width_all(3)
			sv.border_color = Style.ENCRE
			sv.content_margin_left = 6
			sv.content_margin_right = 6
			pc.add_theme_stylebox_override("panel", sv)
			pc.add_child(Style.label("VOTRE CHOIX", 20, Style.capitales(), Style.ENCRE))
			ct.add_child(pc)
		elif str(b.get("id", "")) == "renforce" and str(c.get("legende_renforce", "")) != "" and float(c.get("mise", 0.0)) > 0.0:
			var ll := Style.label(Format.gabarit(str(c["legende_renforce"]), {"mise": Format.entier(float(c["mise"]), a)}), 20, Style.ui(), Style.TEXTE_PAPIER_2)
			ll.name = "LegendeRenforce"
			ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # recette R-RUE M3 : à la ligne plutôt que coupée
			ll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			ll.custom_minimum_size.x = 60   # la colonne garde sa largeur : les barres des 3 lignes restent alignées
			ct.add_child(ll)
		h.add_child(ct)
		var zone := Control.new()
		zone.name = "Barre"
		zone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		zone.custom_minimum_size = Vector2(60, 27 if compact else 30)
		zone.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
		zone.draw.connect(_dessiner_barre.bind(zone, float(b.get("valeur", 0.0)), maxi, base, choisi))
		h.add_child(zone)
		_zone_barres.append(zone)
		var valeur_txt := Format.entier(float(b.get("valeur", 0.0)), a)
		var lv := Style.label(valeur_txt, 26, Style.ui_gras(), Style.ENCRE)
		lv.name = "ValeurBarre"
		lv.custom_minimum_size.x = col_valeur
		lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(lv)
		ligne.add_child(h)
		graphique.add_child(ligne)
		barres_vues.append({"id": str(b.get("id", "")), "titre": str(b.get("titre", "")), "valeur_txt": valeur_txt, "choisi": choisi})
	v.add_child(graphique)
	var garde := str(c.get("garde_fou", ""))
	if garde != "":
		var lg := Style.label(garde, 20, Style.ui(), Style.TEXTE_PAPIER_2)
		lg.name = "GardeFou"
		v.add_child(lg)
	# Bouton J'AI COMPRIS (touche 1 ou Entrée)
	var ch0: Dictionary = (c.get("choix", [{"id": "ok", "titre": "J'AI COMPRIS"}]) as Array)[0]
	choix[str(ch0["id"])] = ch0
	ordre.append(str(ch0["id"]))
	var b := Style.bouton("FERMER" if lecture else "1  " + str(ch0.get("titre", "J'AI COMPRIS")), true, 78 if compact else 81)
	b.name = "Choix_" + str(ch0["id"])
	b.focus_mode = Control.FOCUS_NONE
	b.size_flags_horizontal = Control.SIZE_SHRINK_END
	b.custom_minimum_size.x = 360
	if lecture:
		b.pressed.connect(m.fermer.bind("fermer"))   # relecture depuis l'historique : lecture seule
	else:
		b.pressed.connect(choisir.bind(str(ch0["id"])))
	boutons[str(ch0["id"])] = b
	v.add_child(b)
	_suite = null   # pas de « Toucher pour continuer » : la fiche se ferme avec son bouton
	_p = Control.new()
	_p.name = "Carte"
	_p.mouse_filter = Control.MOUSE_FILTER_STOP
	_p.add_child(_panel)
	m.poser(_p)
	_p.visible = false
	await m.get_tree().process_frame
	await m.get_tree().process_frame
	if not is_instance_valid(_p):
		return
	_panel.reset_size()
	# Trop haute pour l'écran (téléphone) : seul le texte du moteur défile, les barres et le bouton restent visibles
	var trop := _panel.size.y - (vue.y - 12.0)
	if trop > 0.0:
		var zt := _panel.find_child("Defilant", true, false) as Control
		if zt != null and not (zt.get_parent() is ScrollContainer):
			var defile := ScrollContainer.new()
			defile.name = "DefilementCorps"
			defile.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
			defile.custom_minimum_size = Vector2(zt.size.x, maxf(66.0, zt.size.y - trop))
			var parent := zt.get_parent()
			var indice := zt.get_index()
			parent.remove_child(zt)
			defile.add_child(zt)
			parent.add_child(defile)
			parent.move_child(defile, indice)
			await m.get_tree().process_frame
			await m.get_tree().process_frame
			if not is_instance_valid(_p):
				return
			_panel.reset_size()
	var s := (_panel.size / 3.0).ceil() * 3.0
	_panel.size = s
	_p.size = s
	_p.position = (((vue - s) / 2.0).max(Vector2(0, 6)) / 3.0).round() * 3.0
	if lecture:
		_p.visible = true
		return
	await _entree(depart, _p.position, s)
	if is_instance_valid(_p) and phase == "entree":
		phase = "attente"


## Conclusion : rien à montrer, la carte disparaît par fondu (≤ 0,2 s).
func conclure(_r: Dictionary, arrivee: Vector2) -> void:
	phase = "conclusion"
	await _ranger(arrivee)


## Pas de « toucher pour passer » : la fiche attend J'AI COMPRIS.
func passer() -> void:
	pass
