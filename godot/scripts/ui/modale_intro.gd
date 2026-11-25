class_name ModaleIntro
extends RefCounted
## Morceau de Modales : pop-up de début de nouvelle partie (docs/32 : « qui on est, quel est l'objectif »). Sobre, sans animation ;
## texte lu dans data/intro.json (gabarits {salaire}, {depart}). Bouton COMMENCER (Entrée, Espace ou 1) ; ni Échap ni clic extérieur ;
## pas de « Ne plus afficher » (décision du game designer).

var m: Modales
var infos := {}   # contrôles : blocs, taille minimale du texte


func _init(modales: Modales) -> void:
	m = modales


## Valeurs des gabarits, lues dans la partie et les données (jamais écrites en dur).
static func gabarits(e: EtatPartie) -> Dictionary:
	var a := e.ab_courant()
	return {"salaire": Format.montant(e.salaire_base, a), "depart": Format.montant(float(Donnees.infos_chapitre()["depart_F"]["cc"]) / Format.TAUX_EURO, a), "date": Dates.texte(a), "DATE": Dates.texte(a).to_upper()}


## Textes finis (titre, blocs) : pour la fenêtre et pour l'entrée de l'historique.
static func textes(e: EtatPartie) -> Dictionary:
	var d := Donnees.charger("intro")
	var g := gabarits(e)
	var blocs: Array = []
	for b: Dictionary in d["blocs"]:
		blocs.append({"titre": str(b.get("titre", "")), "texte": Format.gabarit(str(e.rendre(str(b.get("texte", "")))), g)})
	return {"titre": Format.gabarit(str(e.rendre(str(d.get("titre", "")))), g), "sous_titre": str(e.rendre(str(d.get("sous_titre", "")))), "bouton": str(d.get("bouton", "COMMENCER")),
		"titre_historique": Format.gabarit(str(e.rendre(str(d.get("titre_historique", "")))), g), "blocs": blocs}


func ouvrir(e: EtatPartie) -> void:
	var d := textes(e)
	infos = {}
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "intro"
	m.assombrir(0.65)
	var vue := m.get_viewport_rect().size
	var p := PanelContainer.new()
	p.name = "Intro"
	var sf := Style.panneau(22)
	sf.content_margin_left = 24 if compact else 40
	sf.content_margin_right = 24 if compact else 40
	sf.content_margin_top = 12 if compact else 28
	sf.content_margin_bottom = 12 if compact else 28
	p.add_theme_stylebox_override("panel", sf)
	var largeur := (vue.x - 40.0) if compact else minf(1000.0, vue.x - 60.0)
	var haut := (vue.y - 16.0) if compact else minf(780.0, vue.y - 60.0)
	p.custom_minimum_size = Vector2(largeur, haut)
	var interieur := largeur - (48.0 if compact else 80.0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10 if compact else 16)
	p.add_child(v)
	var titre := Style.label(str(d["titre"]), 36 if compact else 44, Style.neon(), Style.ACCENT)
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(titre)
	# « Qui vous êtes » : le portrait de la joueuse (3 humeurs dessinées ; ici neutre) ; aucun pour un joueur (1984-1988 inchangé)
	var pj := Noms.portrait_joueuse(e)
	if pj != "":
		var portrait := CadresPixel.icone(pj + "neutre", {}, 2 if compact else 3)
		portrait.name = "PortraitJoueuse"
		portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v.add_child(portrait)
		infos["portrait"] = true
	if str(d["sous_titre"]) != "":
		var st := Style.label(str(d["sous_titre"]), 26, Style.ui(), Style.TEXTE_2)
		st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(st)
	var defile := ScrollContainer.new()
	defile.name = "Defilant"
	defile.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	defile.size_flags_vertical = Control.SIZE_EXPAND_FILL
	defile.custom_minimum_size = Vector2(0, 96)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	col.custom_minimum_size.x = interieur - 24.0
	defile.add_child(col)
	var n := 0
	for b: Dictionary in d["blocs"]:
		var lt := Style.label(str(b.get("titre", "")), 26, Style.capitales(), Style.ACCENT)
		col.add_child(lt)
		var lx := Style.label(str(b.get("texte", "")), 26 if compact else 28, Style.ui(), Style.TEXTE)
		lx.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lx.custom_minimum_size.x = interieur - 24.0
		col.add_child(lx)
		n += 1
	v.add_child(defile)
	var go := Style.bouton(str(d["bouton"]), true, 72 if compact else 84)
	go.name = "Commencer"
	go.pressed.connect(m.fermer.bind("commencer"))
	v.add_child(go)
	infos["blocs"] = n
	m.poser(p)
	await m.centrer(p)
	go.grab_focus.call_deferred()
