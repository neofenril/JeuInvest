class_name ModaleFoyer
extends RefCounted
## Morceau de Modales (lot 04, 03-I2 I3) : « Mon foyer », la porte du frigo (docs/17 §4.4). Papier crème où les
## éléments sont aimantés : portrait 48 × 48 de Sylvie selon l'humeur, une phrase (jamais de nombre ni de jauge),
## la dernière cause, le bloc du foyer, les 4 dernières cartes, un bouton vers l'historique MA MAISON.
## Colonne des projets : place réservée (04-I), rien d'affiché. Téléphone : une seule colonne qui défile. Lecture seule ; ferme au clic extérieur, à Échap (genre « info ») et par [×].
## Renvoie choix_fait("info", "fermer" | "extra") ; « extra » ouvre l'historique filtré MA MAISON.

const NB_CARTES := 4

var m: Modales
var onglet_foyer: Control = null
var onglet_cartes: Control = null
var portrait: TextureRect = null
var l_phrase: Label = null
var l_cause: Label = null
var lignes_cartes: Array = []        # un Label par carte (texte lisible par les tests)


func _init(modales: Modales) -> void:
	m = modales


## Lignes du bloc « Le foyer » : [libellé, valeur] (mêmes chiffres que l'ancien panneau d'information).
static func lignes_foyer(e: EtatPartie) -> Array:
	var a := e.ab_courant()
	var dep: Dictionary = e.depenses()
	var coussin := (maxf(0.0, e.joueur.cc) + e.joueur.livret) / float(dep["total"])
	var l: Array = [["Salaire du mois", Format.montant(e.salaire_base, a)],
		["Loyer", Format.montant(float(dep["loyer"]), a)],
		["Vie courante", Format.montant(float(dep["vie"]), a)]]
	if e.enfants > 0:
		l.append(["Enfants (%d)" % e.enfants, Format.montant(float(dep["enfants"]), a)])
	var auto := Versements.total_mensuel(e) if e.banquier_actif() else 0.0
	if auto > 0.005:
		l.append(["Versements automatiques", Format.entier(auto, a)])
	l.append(["Il reste chaque mois", Format.montant(e.epargne_du_mois(), a)])
	l.append(["Coussin de sécurité", "%s mois" % Format.nombre(coussin, 1)])
	l.append(["Baguette", Format.montant(Marche.baguette(a), a, true)])
	return l


## Texte d'une ligne de carte jouée : « Vacances 87 · L'île de Ré · − 7 000 F ».
static func texte_carte(c: Dictionary, a: int) -> String:
	return "%s · %s · %s" % [str(c.get("titre", "")), str(c.get("libelle", "")), Format.ecart(float(c.get("montant", 0.0)), a)]


func ouvrir(e: EtatPartie, depart: Vector2) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "info"
	m.assombrir(0.45)
	var a := e.ab_courant()
	var cartes := e.has_method("cartes_actives") and e.cartes_actives()
	var vue := m.get_viewport_rect().size
	var p := PanelContainer.new()
	p.name = "MonFoyer"
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.add_theme_stylebox_override("panel", Style.papier("tuile", 30.0, 18.0 if compact else 24.0))
	var largeur := floorf(minf(1280.0, vue.x - 60.0) / 3.0) * 3.0
	p.custom_minimum_size = Vector2(largeur, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8 if compact else 12)
	p.add_child(v)
	# En-tête : titre, date, [×]
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 12)
	var titre := Style.label("MON FOYER · " + e.prenom().to_upper(), 28 if compact else 34, Style.capitales(), Style.ENCRE)
	titre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titre.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(titre)
	tete.add_child(Style.label(Dates.texte(a).to_upper(), 20, Style.capitales(), Style.TEXTE_PAPIER_2))
	var croix := Button.new()
	croix.name = "Fermer"
	croix.focus_mode = Control.FOCUS_NONE
	croix.custom_minimum_size = Vector2(maxf(72.0, Style.cible_min()), maxf(72.0, Style.cible_min()))
	CadresPixel.habiller_bouton(croix, "papier", "croix")
	croix.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	croix.expand_icon = false
	croix.pressed.connect(m.fermer.bind("fermer"))
	tete.add_child(croix)
	v.add_child(tete)
	# Téléphone : une colonne qui défile (version jouable, lot 04 §12.3) ; PC : deux colonnes
	var corps: BoxContainer = VBoxContainer.new() if compact else HBoxContainer.new()
	corps.name = "Defilant"
	corps.add_theme_constant_override("separation", 14 if compact else 30)
	v.add_child(corps)
	# Colonne gauche : humeur et foyer
	onglet_foyer = VBoxContainer.new()
	onglet_foyer.name = "ColonneFoyer"
	onglet_foyer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	onglet_foyer.add_theme_constant_override("separation", 8)
	corps.add_child(onglet_foyer)
	var interieur := largeur - 66.0
	var col := (interieur - 30.0) / 2.0 if not compact else interieur
	if cartes:
		var hh := HBoxContainer.new()
		hh.add_theme_constant_override("separation", 18)
		portrait = CadresPixel.icone("portrait_sylvie_" + ModaleCarte.nom_humeur(e.humeur_visible()), {}, 2 if compact else 3)
		portrait.name = "Portrait"
		portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		hh.add_child(portrait)
		var hv := VBoxContainer.new()
		hv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l_phrase = Style.label(e.humeur_phrase() + ".", 26 if compact else 30, Style.ui_gras(), Style.ENCRE)
		l_phrase.name = "Phrase"
		l_phrase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l_phrase.custom_minimum_size.x = col - 48.0 * (2.0 if compact else 3.0) - 18.0
		hv.add_child(l_phrase)
		var cause := e.derniere_cause_humeur()
		if cause != "":
			l_cause = Style.label("« %s »" % cause, 22 if compact else 24, Style.ui(), Style.TEXTE_PAPIER_2)
			l_cause.name = "Cause"
			l_cause.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l_cause.custom_minimum_size.x = l_phrase.custom_minimum_size.x
			hv.add_child(l_cause)
		hh.add_child(hv)
		onglet_foyer.add_child(hh)
	onglet_foyer.add_child(Style.label("LE FOYER", 20, Style.capitales(), Style.TEXTE_PAPIER_2))
	var g := GridContainer.new()
	g.name = "BlocFoyer"
	g.columns = 2
	g.add_theme_constant_override("h_separation", 18)
	g.add_theme_constant_override("v_separation", 2)
	for ligne: Array in lignes_foyer(e):
		var lt := Style.label(str(ligne[0]), 22 if compact else 24, Style.ui(), Style.TEXTE_PAPIER_2)
		lt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		g.add_child(lt)
		var lv := Style.label(str(ligne[1]), 22 if compact else 24, Style.chiffres(), Style.ENCRE)
		lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		g.add_child(lv)
	onglet_foyer.add_child(g)
	# Colonne droite : projets (réservée, vague 4) et cartes du foyer
	onglet_cartes = VBoxContainer.new()
	onglet_cartes.name = "ColonneCartes"
	onglet_cartes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	onglet_cartes.add_theme_constant_override("separation", 8)
	corps.add_child(onglet_cartes)
	lignes_cartes.clear()
	if cartes:
		onglet_cartes.add_child(Style.label("CARTES DU FOYER (les %d dernières)" % NB_CARTES, 20, Style.capitales(), Style.TEXTE_PAPIER_2))
		var jouees: Array = e.cartes_jouees()
		if jouees.is_empty():
			var lv0 := Style.label("Aucune carte pour l'instant.", 22 if compact else 24, Style.ui(), Style.TEXTE_PAPIER_2)
			lv0.name = "AucuneCarte"
			onglet_cartes.add_child(lv0)
		for k in mini(NB_CARTES, jouees.size()):
			var c: Dictionary = jouees[jouees.size() - 1 - k]
			var rang := HBoxContainer.new()
			rang.add_theme_constant_override("separation", 12)
			var am := CadresPixel.icone("aimant", {}, 2)
			am.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			rang.add_child(am)
			var lc := Style.label(texte_carte(c, e.ab_de(int(c.get("m", e.m)))), 22 if compact else 24, Style.ui(), Style.ENCRE)
			lc.name = "Carte_%d" % k
			lc.clip_text = true
			lc.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			lc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lc.custom_minimum_size.x = 60
			lc.tooltip_text = lc.text
			rang.add_child(lc)
			rang.add_child(CadresPixel.icone("humeur_" + str(c.get("picto", "neutre"))))
			onglet_cartes.add_child(rang)
			lignes_cartes.append(lc)
	var bh := ModaleOutils.bouton_papier("TOUS LES COURRIERS DE LA MAISON  ›", "", compact)
	bh.name = "Historique"
	bh.pressed.connect(m.fermer.bind("extra"))
	v.add_child(bh)
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)
	if is_instance_valid(p):
		m.apparaitre(p)
