class_name ModaleFoyer
extends RefCounted
## Morceau de Modales (lot 04, 03-I2 I3 ; lot 05, 04-I P4 ; docs/17 §4.4, docs/24 §1.4) : « Mon foyer », la porte du frigo.
## Papier crème où les éléments sont aimantés : portrait 48 × 48 de Sylvie selon l'humeur, une phrase (jamais de nombre ni
## de jauge), la dernière cause, le PROJET EN COURS (barre à 2 segments), les PROJETS PASSÉS, les 4 dernières cartes, le bloc
## du foyer, un bouton vers l'historique MA MAISON.
## PC : deux colonnes (humeur + foyer | projet + cartes). Téléphone : une seule colonne qui défile, dans l'ordre
## humeur → projet → passés → cartes → foyer. Lecture seule ; ferme au clic extérieur, à Échap (genre « info ») et par [×].
## Renvoie choix_fait("info", "fermer" | "extra") ; « extra » ouvre l'historique filtré MA MAISON.

const NB_CARTES := 4

var m: Modales
var onglet_foyer: Control = null      # colonne de gauche (PC)
var onglet_cartes: Control = null     # colonne de droite (PC)
var portrait: TextureRect = null
var l_phrase: Label = null
var l_cause: Label = null
var lignes_cartes: Array = []         # un Label par carte (texte lisible par les tests)
var lignes_projet: Array = []         # lignes du bloc PROJET EN COURS (texte lisible par les tests)
var lignes_passes: Array = []         # lignes des projets passés
var barre_projet: Control = null


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


## Lignes du bloc PROJET EN COURS (docs/24 §1.4) : [nom · échéance · dans N mois, « … sans rien vendre · + … placés »,
## « Il manque … sans rien vendre. » si disponible < montant].
static func textes_projet(p: Dictionary, a: int) -> Array:
	var l: Array = []
	var restants := int(p.get("mois_restants", 0))
	l.append("%s · %s · dans %s" % [str(p.get("nom", "")), str(p.get("echeance_txt", "")), Dates.duree(restants) if restants > 0 else "ce mois-ci"])
	l.append("%s sans rien vendre · + %s placés" % [Format.entier(float(p.get("disponible", 0.0)), a), Format.entier(float(p.get("revendable", 0.0)), a)])
	var manque := float(p.get("montant", 0.0)) - float(p.get("disponible", 0.0))
	if manque > 0.004:
		l.append("Il manque %s sans rien vendre." % Format.entier(manque, a))
	return l


static func mot_statut(statut: String) -> String:
	return {"realise": "réalisé", "realise_apres_report": "réalisé après report", "abandonne": "abandonné"}.get(statut, statut)


## Ligne d'un projet passé : « réalisé · Le salon et la chaîne hi-fi · avril 1986 · 12 000 F ».
static func texte_passe(p: Dictionary, a_courant: int) -> String:
	var ab := int(p.get("ab", a_courant))
	return "%s · %s · %s · %s" % [mot_statut(str(p.get("statut", ""))), str(p.get("nom", "")), Dates.texte(ab), Format.entier(float(p.get("montant", 0.0)), a_courant)]


## fab : contenus fabriqués (captures et tests) {"projet": projet_en_cours(), "passes": projets_passes()} ; vide en jeu.
func ouvrir(e: EtatPartie, depart: Vector2, fab := {}) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "info"
	m.assombrir(0.45)
	var a := e.ab_courant()
	var cartes := e.has_method("cartes_actives") and e.cartes_actives()
	var projets := not fab.is_empty() or (e.has_method("projets_actifs") and bool(e.call("projets_actifs")))
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
	# Corps : deux colonnes (PC) ou une seule qui défile (téléphone, version jouable)
	var corps: BoxContainer = VBoxContainer.new() if compact else HBoxContainer.new()
	corps.name = "Defilant"
	corps.add_theme_constant_override("separation", 14 if compact else 30)
	v.add_child(corps)
	var interieur := largeur - 66.0
	var col := (interieur - 30.0) / 2.0 if not compact else interieur
	onglet_foyer = VBoxContainer.new()
	onglet_foyer.name = "ColonneFoyer"
	onglet_foyer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	onglet_foyer.add_theme_constant_override("separation", 8)
	onglet_cartes = VBoxContainer.new()
	onglet_cartes.name = "ColonneCartes"
	onglet_cartes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	onglet_cartes.add_theme_constant_override("separation", 8)
	# Colonne de destination des blocs : PC gauche / droite, téléphone : tout dans la colonne unique, dans l'ordre voulu
	var haut: Control = onglet_foyer
	var droite: Control = onglet_foyer if compact else onglet_cartes
	if cartes:
		haut.add_child(_bloc_humeur(e, col, compact))
	if projets:
		droite.add_child(_bloc_projet(e, fab, a, col, compact))
		droite.add_child(_bloc_passes(e, fab, a, compact))
	if cartes:
		droite.add_child(_bloc_cartes(e, a, compact, col))
	haut.add_child(_bloc_foyer(e, compact))
	corps.add_child(onglet_foyer)
	if not compact:
		corps.add_child(onglet_cartes)
	var bh := ModaleOutils.bouton_papier("TOUS LES COURRIERS DE LA MAISON  ›", "", compact)
	bh.name = "Historique"
	bh.pressed.connect(m.fermer.bind("extra"))
	v.add_child(bh)
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)
	if is_instance_valid(p):
		m.apparaitre(p)


func _bloc_humeur(e: EtatPartie, col: float, compact: bool) -> Control:
	var hh := HBoxContainer.new()
	hh.name = "BlocHumeur"
	hh.add_theme_constant_override("separation", 18)
	portrait = CadresPixel.icone(Noms.portrait_proche(e) + ModaleCarte.nom_humeur(e.humeur_visible()))
	portrait.name = "Portrait"
	portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	hh.add_child(portrait)
	var hv := VBoxContainer.new()
	hv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l_phrase = Style.label(e.humeur_phrase() + ".", 26 if compact else 30, Style.ui_gras(), Style.ENCRE)
	l_phrase.name = "Phrase"
	l_phrase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l_phrase.custom_minimum_size.x = col - 144.0 - 18.0
	hv.add_child(l_phrase)
	var cause := e.derniere_cause_humeur()
	if cause != "":
		l_cause = Style.label("« %s »" % cause, 22 if compact else 24, Style.ui(), Style.TEXTE_PAPIER_2)
		l_cause.name = "Cause"
		l_cause.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l_cause.custom_minimum_size.x = l_phrase.custom_minimum_size.x
		hv.add_child(l_cause)
	hh.add_child(hv)
	return hh


func _bloc_foyer(e: EtatPartie, compact: bool) -> Control:
	var v := VBoxContainer.new()
	v.name = "BlocFoyerTitre"
	v.add_theme_constant_override("separation", 4)
	v.add_child(Style.label("LE FOYER", 20, Style.capitales(), Style.TEXTE_PAPIER_2))
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
	v.add_child(g)
	return v


## PROJET EN COURS : nom, échéance, barre à 2 segments (disponible plein, revendable hachuré), « Il manque … ».
func _bloc_projet(e: EtatPartie, fab: Dictionary, a: int, col: float, compact: bool) -> Control:
	var v := VBoxContainer.new()
	v.name = "BlocProjet"
	v.add_theme_constant_override("separation", 4)
	v.add_child(Style.label("PROJET EN COURS", 20, Style.capitales(), Style.TEXTE_PAPIER_2))
	lignes_projet.clear()
	var pr: Dictionary = fab.get("projet", {}) if not fab.is_empty() else (e.call("projet_en_cours") if e.has_method("projet_en_cours") else {})
	if pr.is_empty():
		var l0 := Style.label("Aucun projet en cours.", 20, Style.ui(), Style.TEXTE_PAPIER_2)
		l0.name = "AucunProjet"
		v.add_child(l0)
		return v
	var textes := textes_projet(pr, a)
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 12)
	tete.add_child(_icone_projet(str(pr.get("icone", "")), str(pr.get("nom", ""))))
	var l1 := Style.label(str(textes[0]), 22, Style.ui_gras(), Style.ENCRE)
	l1.name = "ProjetNom"
	l1.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l1.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	l1.custom_minimum_size.x = maxf(60.0, col - 48.0 - 12.0)
	tete.add_child(l1)
	v.add_child(tete)
	lignes_projet.append(l1)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 12)
	barre_projet = Control.new()
	barre_projet.name = "BarreProjet"
	barre_projet.custom_minimum_size = Vector2(maxf(120.0, col - 150.0), 24)
	barre_projet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barre_projet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	barre_projet.set_meta("montant", float(pr.get("montant", 0.0)))
	barre_projet.set_meta("disponible", float(pr.get("disponible", 0.0)))
	barre_projet.set_meta("revendable", float(pr.get("revendable", 0.0)))
	barre_projet.draw.connect(_dessiner_barre.bind(barre_projet))
	hb.add_child(barre_projet)
	var lm := Style.label(Format.entier(float(pr.get("montant", 0.0)), a), 22, Style.ui_gras(), Style.ENCRE)
	lm.name = "ProjetMontant"
	lm.custom_minimum_size.x = 130
	lm.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hb.add_child(lm)
	v.add_child(hb)
	for i in range(1, textes.size()):
		var li := Style.label(str(textes[i]), 20, Style.ui(), Style.ENCRE if i == textes.size() - 1 and textes.size() == 3 else Style.TEXTE_PAPIER_2)
		li.name = "ProjetLigne%d" % i
		li.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		li.custom_minimum_size.x = col
		v.add_child(li)
		lignes_projet.append(li)
	return v


## Barre : plein ambre = disponible, hachuré ambre = revendable, vide ardoise sombre, trait encre = objectif ; s'arrête au trait.
func _dessiner_barre(c: Control) -> void:
	var w := floorf(c.size.x / 3.0) * 3.0
	var h := 24.0
	var montant := maxf(1.0, float(c.get_meta("montant")))
	var dispo := clampf(float(c.get_meta("disponible")) / montant, 0.0, 1.0)
	var rev := clampf((float(c.get_meta("disponible")) + float(c.get_meta("revendable"))) / montant, 0.0, 1.0)
	var encre := Style.ENCRE
	var ambre := PalettePixel.couleur("ambre")
	c.draw_rect(Rect2(0, 0, w, h), PalettePixel.couleur("ardoise_sombre"))
	var xp := floorf(w * dispo / 3.0) * 3.0
	c.draw_rect(Rect2(0, 0, xp, h), ambre)
	var xr := floorf(w * rev / 3.0) * 3.0
	var y := 0.0
	while y < h:
		var x := xp + (3.0 if int(y / 3.0) % 2 == 0 else 0.0)
		while x < xr:
			c.draw_rect(Rect2(x, y, minf(3.0, xr - x), 3), ambre)
			x += 6.0
		y += 3.0
	c.draw_rect(Rect2(0, 0, w, h), encre, false, 3.0)
	c.draw_rect(Rect2(w - 3.0, 0, 3, h), encre)   # trait de l'objectif


func _bloc_passes(e: EtatPartie, fab: Dictionary, a: int, compact: bool) -> Control:
	var v := VBoxContainer.new()
	v.name = "BlocPasses"
	v.add_theme_constant_override("separation", 4)
	var passes: Array = fab.get("passes", []) if not fab.is_empty() else (e.call("projets_passes") if e.has_method("projets_passes") else [])
	lignes_passes.clear()
	if passes.is_empty():
		return v
	v.add_child(Style.label("PROJETS PASSÉS", 20, Style.capitales(), Style.TEXTE_PAPIER_2))
	for k in passes.size():
		var pp: Dictionary = passes[passes.size() - 1 - k]
		var rang := HBoxContainer.new()
		rang.add_theme_constant_override("separation", 9)
		rang.add_child(_glyphe_statut(str(pp.get("statut", ""))))
		var lt := Style.label(texte_passe(pp, a), 20 if compact else 22, Style.ui(), Style.ENCRE)
		lt.name = "Passe_%d" % k
		lt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lt.custom_minimum_size.x = 60
		rang.add_child(lt)
		v.add_child(rang)
		lignes_passes.append(lt)
	return v


## ✓ réalisé · ↻ réalisé après report · ✗ abandonné : sprites dessinés (les glyphes manquent aux polices), toujours avec le mot.
func _glyphe_statut(statut: String) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(24, 24)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(_dessiner_glyphe.bind(c, statut))
	return c


func _dessiner_glyphe(c: Control, statut: String) -> void:
	var col := Style.GAIN_PAPIER if statut != "abandonne" else Style.ENCRE_ROUGE
	match statut:
		"abandonne":
			c.draw_line(Vector2(3, 3), Vector2(21, 21), col, 3.0)
			c.draw_line(Vector2(21, 3), Vector2(3, 21), col, 3.0)
		"realise_apres_report":
			c.draw_arc(Vector2(12, 12), 8.0, 0.4, 5.6, 14, col, 3.0)
			c.draw_rect(Rect2(15, 2, 6, 6), col)
		_:
			c.draw_line(Vector2(3, 12), Vector2(9, 18), col, 3.0)
			c.draw_line(Vector2(9, 18), Vector2(21, 5), col, 3.0)


func _bloc_cartes(e: EtatPartie, a: int, compact: bool, col: float) -> Control:
	var v := VBoxContainer.new()
	v.name = "BlocCartes"
	v.add_theme_constant_override("separation", 8)
	v.add_child(Style.label("CARTES DU FOYER (les %d dernières)" % NB_CARTES, 20, Style.capitales(), Style.TEXTE_PAPIER_2))
	lignes_cartes.clear()
	var jouees: Array = e.cartes_jouees()
	if jouees.is_empty():
		var lv0 := Style.label("Aucune carte pour l'instant.", 22 if compact else 24, Style.ui(), Style.TEXTE_PAPIER_2)
		lv0.name = "AucuneCarte"
		v.add_child(lv0)
	for k in mini(NB_CARTES, jouees.size()):
		var c: Dictionary = jouees[jouees.size() - 1 - k]
		var rang := HBoxContainer.new()
		rang.add_theme_constant_override("separation", 12)
		var am := CadresPixel.icone("aimant")
		am.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		rang.add_child(am)
		var lc := Style.label(texte_carte(c, e.ab_de(int(c.get("m", e.m)))), 22 if compact else 24, Style.ui(), Style.ENCRE)
		lc.name = "Carte_%d" % k
		# Jamais de montant coupé (recette R-MAISON m2) : le titre long passe à la ligne, le montant reste lisible en fin de ligne
		lc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lc.custom_minimum_size.x = maxf(60.0, col - 24.0 - 48.0 - 24.0)   # la colonne garde sa largeur : le texte ne se replie qu'à son bord
		rang.add_child(lc)
		rang.add_child(CadresPixel.icone("humeur_" + str(c.get("picto", "neutre"))))
		v.add_child(rang)
		lignes_cartes.append(lc)
	return v


## Icône du projet : sprite 16 × 16 ×3 ; absente : l'initiale dans un carré encre 48 × 48.
func _icone_projet(nom: String, titre: String) -> Control:
	CadresPixel.charger()
	if nom != "" and GrillePixel.existe("ui/" + nom):
		var r := CadresPixel.icone(nom)
		r.custom_minimum_size = Vector2(48, 48)
		r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		return r
	var pc := PanelContainer.new()
	pc.custom_minimum_size = Vector2(48, 48)
	pc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = Style.ENCRE
	pc.add_theme_stylebox_override("panel", sb)
	var li := Style.label(titre.strip_edges().left(1).to_upper(), 28, Style.capitales(), PalettePixel.couleur("creme"))
	li.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	li.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pc.add_child(li)
	return pc
