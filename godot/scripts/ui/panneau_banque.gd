class_name PanneauBanque
extends PanelContainer
## La fenêtre Banque (13 §2) : à gauche le carnet du banquier (compte courant en bandeau, grille 3 × 3 des
## 9 produits de la démo, 4 états), à droite la fiche du produit choisi, puis son formulaire d'ordre, puis
## l'encart des frais (F01, 13 §3.3) à la première souscription avec frais. On ne superpose jamais deux
## fenêtres : la colonne de droite change de contenu. Le temps est en pause pendant l'ouverture.

signal fermer_demande
signal ordre_passe(position_ecran: Vector2, montant: float, achat: bool, frais: float)
signal relire(id_presentation: String)
signal historique_demande   # l'historique des pop-ups, filtré sur la banque (remplace l'ancien onglet Messages)

var e: EtatPartie
var produit := ""
var mode := "a"           # a : déposer, acheter, verser, prêter, ouvrir ; b : retirer, vendre, racheter, clôturer
var montant := 0.0
var compact := false

var _cartes: Dictionary = {}
var _droite: VBoxContainer
var _l_decouverts: Label
var _jauge: Control
var _l_cc: Label
var _b_messages: Button
var _l_titre: Label
# Formulaire d'ordre
var _l_montant: Label
var _ligne_montant: Control
var _slider: HSlider
var _recap: GridContainer
var _l_alerte: Label
var _bande_frais: PanelContainer
var _b_ok: Button
var _b_mode_a: Button
var _b_mode_b: Button
var _mensuel := 0.0
var _maj_en_cours := false
var _largeur_droite := 780.0


func construire(etat: EtatPartie, id: String, montant_initial: float) -> void:
	e = etat
	compact = Ecran.compact()
	theme = Style.theme()
	add_theme_stylebox_override("panel", Style.panneau(20))
	var t := Ecran.taille()
	custom_minimum_size = Vector2(minf(1760.0, t.x - 30.0), 0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6 if compact else 12)
	add_child(v)
	# En-tête : titre, produits découverts, messages, croix
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 16)
	_l_titre = Style.label("", 22 if compact else 24, Style.capitales(), Style.TEXTE)
	_l_titre.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(_l_titre)
	_l_decouverts = Style.label("", 20, Style.ui(), Style.TEXTE_2)
	_l_decouverts.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(_l_decouverts)
	_jauge = Control.new()
	_jauge.custom_minimum_size = Vector2(120 if compact else 180, 14)
	_jauge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_jauge.draw.connect(_dessiner_jauge)
	tete.add_child(_jauge)
	var pause := Style.label("" if compact else "le temps est en pause", 20, Style.ui(), Style.GEL)
	pause.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pause.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(pause)
	_b_messages = Button.new()
	_b_messages.custom_minimum_size = Vector2(0, 64 if compact else 72)
	_b_messages.add_theme_font_size_override("font_size", 20)
	_b_messages.pressed.connect(func() -> void: historique_demande.emit())
	tete.add_child(_b_messages)
	var x := Button.new()
	x.custom_minimum_size = Vector2(72 if compact else 80, 64 if compact else 72)
	x.draw.connect(_dessiner_croix.bind(x))
	x.pressed.connect(func() -> void: fermer_demande.emit())
	tete.add_child(x)
	v.add_child(tete)
	# Corps : carnet à gauche, fiche ou ordre à droite
	var corps := HBoxContainer.new()
	corps.add_theme_constant_override("separation", 18 if compact else 28)
	v.add_child(corps)
	var gauche := VBoxContainer.new()
	gauche.add_theme_constant_override("separation", 6 if compact else 10)
	corps.add_child(gauche)
	var bandeau := PanelContainer.new()
	bandeau.add_theme_stylebox_override("panel", Style.boite(Color(1, 1, 1, 0.05), 10, 14, 6))
	var hb := HBoxContainer.new()
	hb.add_child(Style.label("COMPTE COURANT", 18, Style.capitales(), Style.TEXTE_2))
	_l_cc = Style.label("", 22, Style.chiffres(), Style.TEXTE)
	_l_cc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_l_cc.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hb.add_child(_l_cc)
	bandeau.add_child(hb)
	gauche.add_child(bandeau)
	var grille := GridContainer.new()
	grille.columns = 3
	grille.add_theme_constant_override("h_separation", 8 if compact else 12)
	grille.add_theme_constant_override("v_separation", 8 if compact else 12)
	for pid in Banquier.ordre_carnet():
		var c := CarteProduit.new()
		c.pid = pid
		c.compacte = compact
		c.touchee.connect(_on_carte)
		grille.add_child(c)
		_cartes[pid] = c
	gauche.add_child(grille)
	_droite = VBoxContainer.new()
	_droite.add_theme_constant_override("separation", 6 if compact else 10)
	_droite.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	corps.add_child(_droite)
	var largeur_grille := 3.0 * (140.0 if compact else 170.0) + 2.0 * (8.0 if compact else 12.0)
	_largeur_droite = custom_minimum_size.x - 40.0 - largeur_grille - (18.0 if compact else 28.0)
	# Pied : la simplification historique (A40)
	var pied := Style.label("Simplifié : en 1984, le Livret A s'ouvrait à la Caisse d'épargne ou à la Poste ; la banque de la rue regroupe ici tous les guichets.", 16 if compact else 18, Style.ui(), Color(Style.TEXTE_2, 0.85))
	pied.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pied.custom_minimum_size.x = custom_minimum_size.x - 40.0
	v.add_child(pied)
	_maj_carnet()
	var depart := id if id != "" else _premier_produit()
	if id != "" and Banquier.presente(e, id) and montant_initial > -1.5:
		_choisir(depart)
		_afficher_ordre(depart, "a", montant_initial)
	else:
		_choisir(depart)
	_reveler_nouveaux()


func _premier_produit() -> String:
	for pid in Banquier.ordre_carnet():
		if Banquier.etat_carte(e, pid) == "nouveau":
			return pid
	for pid in Banquier.ordre_carnet():
		if Banquier.presente(e, pid):
			return pid
	return "livret"


func _reveler_nouveaux() -> void:
	var reveles: Array = e.banque.get("reveles", [])
	var k := 0
	for pid in Banquier.ordre_carnet():
		if Banquier.presente(e, pid) and not reveles.has(pid):
			reveles.append(pid)
			_cartes[pid].call_deferred("reveler", 0.25 + 0.15 * k)
			k += 1
	e.banque["reveles"] = reveles


# =====================================================================
# Carnet
# =====================================================================

func _maj_carnet() -> void:
	var a := e.ab_courant()
	_l_titre.text = "LA BANQUE · " + Dates.texte(a).to_upper()
	_l_decouverts.text = "Produits découverts : %d sur %d" % [Banquier.nb_decouverts(e), Banquier.ordre_carnet().size()]
	_l_cc.text = Format.entier(e.joueur.cc, a) + " · 0 %"
	_b_messages.text = "HISTORIQUE"
	_jauge.queue_redraw()
	for pid in _cartes:
		var c: CarteProduit = _cartes[pid]
		var info := Banquier.info_produit(pid)
		c.etat = Banquier.etat_carte(e, pid)
		c.nom = str(info.get("court", pid))
		c.couleur = Banquier.couleur(pid)
		c.indice = str(info.get("indice", ""))
		c.cadenas = false
		c.calendrier = Versements.actif(e, pid)
		match c.etat:
			"detenu":
				c.ligne1 = Format.entier(Banquier.valeur(e, pid), a)
				c.ligne2 = _sous_titre(pid)
				c.cadenas = pid == "pel" or (pid == "av" and e.m - int(e.joueur.av["ouvert_m"]) < 72)
			"presente", "nouveau":
				var p := int(e.banque["presentes"].get(Banquier.presentation_de(pid), e.m))
				c.ligne1 = "présentée en"
				c.ligne2 = Dates.texte_court(e.ab_de(p))
		c.choisie = pid == produit
		c.queue_redraw()


func _sous_titre(pid: String) -> String:
	var a := e.ab_courant()
	match pid:
		"livret":
			return Banquier.taux_txt(Marche.taux_livret(a)) + " %"
		"pel":
			return Banquier.texte_taux_pel(e, true)
		"emprunt":
			return Banquier.taux_txt(float(e.joueur.emprunts[0]["taux"])) + " % fixe"
		"av":
			return Banquier.taux_txt(Produits.taux_av(Dates.annee(a))) + " % cette année"
	var pv := e.plus_value_latente(e.joueur, pid)
	return ("▲ " if pv >= 0.0 else "▼ ") + Format.montant(pv, a, false, true)


func _on_carte(pid: String) -> void:
	_choisir(pid)


func _choisir(pid: String) -> void:
	produit = pid
	if Banquier.presente(e, pid):
		Banquier.marquer_vu(e, pid)
		_afficher_fiche(pid)
	else:
		_afficher_silhouette(pid)
	_maj_carnet()


func _vider() -> void:
	for c in _droite.get_children():
		_droite.remove_child(c)
		c.queue_free()


func _texte(t: String, taille: int, police: Font = null, couleur := Style.TEXTE) -> Label:
	var l := Style.label(t, taille, police if police != null else Style.ui(), couleur)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = _largeur_droite
	return l


# =====================================================================
# Fiche d'un produit (13 §2.2)
# =====================================================================

func _afficher_silhouette(pid: String) -> void:
	_vider()
	_droite.add_child(_texte("À DÉCOUVRIR", 20, Style.capitales(), Style.TEXTE_2))
	_droite.add_child(_texte(str(Banquier.info_produit(pid).get("indice", "")), 30, Style.ui_gras()))
	_droite.add_child(_texte("M. Lefranc vous en parlera le moment venu.", 24, Style.ui(), Style.TEXTE_2))


func _afficher_fiche(pid: String) -> void:
	_vider()
	var a := e.ab_courant()
	var info := Banquier.info_produit(pid)
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 12)
	var barre := ColorRect.new()
	barre.color = Banquier.couleur(pid)
	barre.custom_minimum_size = Vector2(8, 40)
	tete.add_child(barre)
	var nom := Style.label(str(info.get("nom", pid)), 26 if compact else 30, Style.ui_gras())
	nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tete.add_child(nom)
	var id_pres := Banquier.presentation_de(pid)
	var p := int(e.banque["presentes"].get(id_pres, e.m))
	var relire_b := Button.new()
	relire_b.text = "Relire la présentation"
	relire_b.flat = true
	relire_b.custom_minimum_size = Vector2(0, 56)
	relire_b.add_theme_color_override("font_color", Style.ACCENT)
	relire_b.add_theme_font_size_override("font_size", 20)
	relire_b.pressed.connect(func() -> void: relire.emit(id_pres))
	tete.add_child(relire_b)
	_droite.add_child(tete)
	_droite.add_child(_texte("Présenté par M. Lefranc en %s. %s" % [Dates.texte(e.ab_de(p)), str(info.get("definition", ""))], 18 if compact else 20, Style.ui(), Style.TEXTE_2))
	# Les 4 critères et les frais, en valeur absolue (pas de comparaison ici)
	var g := GridContainer.new()
	g.columns = 3
	g.add_theme_constant_override("h_separation", 16)
	g.add_theme_constant_override("v_separation", 0 if compact else 4)
	var v := Banquier.variables(e)
	var notes := Banquier.notes(pid, Dates.annee(a))
	var mots: Dictionary = info.get("mots", {})
	for c in Banquier.CRITERES:
		g.add_child(Style.label(c[1], 20, Style.ui(), Style.TEXTE_2))
		g.add_child(Pastilles.creer(int(notes.get(c[0], 0)), Banquier.couleur(pid)))
		g.add_child(Style.label(Format.gabarit(str(mots.get(c[0], "")), v), 20, Style.ui(), Style.TEXTE))
	g.add_child(Style.label("Frais", 20, Style.ui(), Style.TEXTE_2))
	g.add_child(Control.new())
	g.add_child(Style.label(str(info.get("frais", "")), 20, Style.ui_gras(), Style.CUIVRE))
	_droite.add_child(g)
	if int(notes.get("risque", 1)) >= 2:
		_droite.add_child(_texte("* espéré, jamais garanti ; le passé ne prédit rien.", 16, Style.ui(), Style.TEXTE_2))
	_droite.add_child(_texte(_vous_avez(pid), 22 if compact else 24, Style.chiffres()))
	var auto := _ligne_automatique(pid)
	if auto != "":
		_droite.add_child(_texte(auto, 18 if compact else 20, Style.ui_gras(), Style.GEL))
	var boutons := HBoxContainer.new()
	boutons.add_theme_constant_override("separation", 12)
	var libelles := _libelles_modes(pid)
	var ba := Style.bouton(libelles[0], true, 72 if compact else 80)
	ba.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ba.pressed.connect(_afficher_ordre.bind(pid, "a", -1.0))
	boutons.add_child(ba)
	var bb := Style.bouton(libelles[1], false, 72 if compact else 80)
	bb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bb.disabled = not Banquier.detenu(e, pid)
	bb.pressed.connect(_afficher_ordre.bind(pid, "b", -1.0))
	boutons.add_child(bb)
	# Versement automatique mensuel (11 §8, VP10) : sur chaque produit, même non éligible (la vue explique pourquoi)
	var bc := Style.bouton("CHAQUE MOIS", false, 72 if compact else 80)
	bc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bc.pressed.connect(_afficher_automatique.bind(pid))
	bc.name = "BoutonChaqueMois"
	boutons.add_child(bc)
	_droite.add_child(boutons)


func _vous_avez(pid: String) -> String:
	var a := e.ab_courant()
	var w := e.joueur
	if not Banquier.detenu(e, pid):
		return "Vous avez : rien pour l'instant."
	match pid:
		"livret":
			return "Vous avez : %s (plafond %s)." % [Format.montant(w.livret, a), Format.montant(Marche.plafond_livret(a), a)]
		"pel":
			return "Vous avez : %s à %s · %s par mois · 4 ans en %s." % [Format.montant(w.valeur_pel(), a), Banquier.texte_taux_pel(e),
				Format.entier(float(w.pel["mensuel"]), a), Dates.texte(e.ab_de(int(w.pel["ouvert_m"]) + 48))]
		"emprunt":
			var t: Array = []
			for tr in w.emprunts:
				t.append("%s à %s %%" % [Format.montant(float(tr["nominal"]), a), Banquier.taux_txt(float(tr["taux"]))])
			return "Vous avez prêté : " + ", ".join(PackedStringArray(t)) + "."
		"av":
			var d := Produits.devis_rachat_av(e, w, 0.0, true)
			return "Vous avez : %s · sans impôt sur les gains à partir de %s." % [Format.montant(w.valeur_av(), a), Dates.texte(int(d["exoneration_ab"]))]
	var q := w.qte(pid)
	var pr := e.produit(pid)
	var quantite := ("%d actions" % int(round(q))) if pr.get("type", "") == "action" else ("%s parts" % Format.nombre(q, 2))
	return "Vous avez : %s = %s (%s)." % [quantite, Format.montant(e.valeur_ligne(w, pid), a), Format.montant(e.plus_value_latente(w, pid), a, false, true)]


## État du versement automatique en une ligne (VP11), "" s'il n'y en a pas.
func _ligne_automatique(pid: String) -> String:
	var a := e.ab_courant()
	var p := Versements.plan(e, pid)
	if p.is_empty():
		return ""
	var t := "Chaque mois, automatiquement : %s" % Format.entier(float(p["montant"]), a)
	match str(p.get("suspendu", "")):
		"refus":
			t += " · suspendu (compte insuffisant)"
		"plafond":
			t += " · suspendu (Livret A plein)"
	return t


# =====================================================================
# Versement automatique mensuel (11 §8, VP10) : réglage dans la colonne de droite
# =====================================================================

func _afficher_automatique(pid: String, textes: Array = []) -> void:
	produit = pid
	_vider()
	var a := e.ab_courant()
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 12)
	var retour := Button.new()
	retour.text = "‹ Fiche"
	retour.custom_minimum_size = Vector2(120, 56)
	retour.add_theme_font_size_override("font_size", 20)
	retour.pressed.connect(_afficher_fiche.bind(pid))
	tete.add_child(retour)
	var nom := Style.label(str(Banquier.info_produit(pid).get("nom", pid)), 24 if compact else 28, Style.ui_gras())
	nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nom.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(nom)
	_droite.add_child(tete)
	_droite.add_child(_texte("VERSEMENT AUTOMATIQUE · LE 1ER DU MOIS, JUSTE APRÈS LA PAYE", 18 if compact else 20, Style.capitales(), Style.GEL))
	if not Versements.reglable(pid):
		_droite.add_child(_texte(Versements.texte_non_eligible(pid), 22 if compact else 24, Style.ui(), Style.TEXTE))
		return
	if pid == "pel" and e.joueur.pel.is_empty():
		_droite.add_child(_texte("Le versement mensuel du PEL se choisit à son ouverture (au moins 300 F par mois, 3 600 F par an).", 22 if compact else 24, Style.ui(), Style.TEXTE))
		return
	var p := Versements.plan(e, pid)
	var etat_txt := "Aucun versement automatique pour l'instant."
	if not p.is_empty():
		etat_txt = _ligne_automatique(pid) + "."
	_droite.add_child(_texte(etat_txt, 22 if compact else 24, Style.chiffres(), Style.TEXTE))
	if pid == "pel":
		_droite.add_child(_texte(Versements.texte_non_eligible("pel"), 18 if compact else 20, Style.ui(), Style.TEXTE_2))
	# Montants proposés (VP10) : un toucher programme ou modifie le plan, effet le mois suivant
	var lp := HBoxContainer.new()
	lp.add_theme_constant_override("separation", 8)
	var gp := ButtonGroup.new()
	for v in Versements.montants(pid):
		var b := Button.new()
		b.text = Format.entier(float(v), a)
		b.toggle_mode = true
		b.button_group = gp
		b.theme_type_variation = "BoutonBascule"
		b.custom_minimum_size = Vector2(0, 64 if compact else 72)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.set_pressed_no_signal(not p.is_empty() and absf(float(p["montant"]) - float(v)) < 0.01)
		b.pressed.connect(_regler_automatique.bind(pid, float(v)))
		lp.add_child(b)
	_droite.add_child(lp)
	var fp := Versements.frais_pct(pid)
	if fp > 0.0:
		_droite.add_child(_texte("Frais d'entrée : %s %% sur chaque versement." % Format.nombre(fp, 0), 18 if compact else 20, Style.ui_gras(), Style.CUIVRE))
	if pid != "pel" and not p.is_empty():
		var hb := HBoxContainer.new()
		hb.add_theme_constant_override("separation", 12)
		if str(p.get("suspendu", "")) != "":
			var re := Style.bouton("RÉACTIVER", true, 64 if compact else 72)
			re.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			re.pressed.connect(_reactiver_automatique.bind(pid))
			hb.add_child(re)
		var ar := Style.bouton("ARRÊTER", false, 64 if compact else 72)
		ar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ar.pressed.connect(_arreter_automatique.bind(pid))
		hb.add_child(ar)
		_droite.add_child(hb)
	for t in textes:
		_droite.add_child(_texte("« %s »" % str(t), 18 if compact else 20, Style.ui(), Style.TEXTE))
	if textes.is_empty() and pid == "pel":
		_droite.add_child(_texte("Effet le mois suivant. Si le compte ne suffit pas, le versement est reporté. À chaque anniversaire, le PEL doit avoir reçu 3 600 F dans l'année : le manque est prélevé si le compte le permet, sinon le plan est clos.", 16 if compact else 18, Style.ui(), Style.TEXTE_2))
	elif textes.is_empty():
		_droite.add_child(_texte("Effet le mois suivant. Jamais de découvert : si le compte ne suffit pas, le versement n'est pas fait (suspendu après 3 refus de suite)." + (" " + str(Versements.params()["simplifie_sicav"]) if pid == "sicav" else ""), 16 if compact else 18, Style.ui(), Style.TEXTE_2))
	_maj_carnet()


func _regler_automatique(pid: String, v: float) -> void:
	var r := Partie.programmer_versement(pid, v)
	if not r.get("ok", false):
		_afficher_automatique(pid, [str(r.get("msg", ""))])
		return
	_afficher_automatique(pid, r.get("textes", []))


func _arreter_automatique(pid: String) -> void:
	Partie.arreter_versement(pid)
	_afficher_automatique(pid)


func _reactiver_automatique(pid: String) -> void:
	var r := Partie.reactiver_versement(pid)
	_afficher_automatique(pid, [] if r.get("ok", false) else [str(r.get("msg", ""))])


func _libelles_modes(pid: String) -> Array:
	match Banquier.info_produit(pid).get("type", ""):
		"livret":
			return ["DÉPOSER", "RETIRER"]
		"pel":
			return ["VERSER" if not e.joueur.pel.is_empty() else "OUVRIR UN PEL", "CLÔTURER"]
		"emprunt":
			return ["PRÊTER", "REVENDRE"]
		"av":
			return ["VERSER", "RETIRER"]
	return ["ACHETER", "VENDRE"]


func _type() -> String:
	return str(Banquier.info_produit(produit).get("type", ""))


# =====================================================================
# Formulaire d'ordre (04 §3.4, repris de l'ancien marché)
# =====================================================================

func _afficher_ordre(pid: String, m: String, montant_initial := -1.0) -> void:
	produit = pid
	mode = m
	_vider()
	var a := e.ab_courant()
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 12)
	var retour := Button.new()
	retour.text = "‹ Fiche"
	retour.custom_minimum_size = Vector2(120, 56)
	retour.add_theme_font_size_override("font_size", 20)
	retour.pressed.connect(_afficher_fiche.bind(pid))
	tete.add_child(retour)
	var nom := Style.label(str(Banquier.info_produit(pid).get("nom", pid)), 24 if compact else 28, Style.ui_gras())
	nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nom.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(nom)
	tete.add_child(_info_prix(a))
	_droite.add_child(tete)
	var libelles := _libelles_modes(pid)
	var modes := HBoxContainer.new()
	modes.add_theme_constant_override("separation", 8)
	var gm := ButtonGroup.new()
	_b_mode_a = _bouton_mode(gm, libelles[0], "a")
	_b_mode_b = _bouton_mode(gm, libelles[1], "b")
	_b_mode_b.disabled = not Banquier.detenu(e, pid)
	modes.add_child(_b_mode_a)
	modes.add_child(_b_mode_b)
	_droite.add_child(modes)
	_b_mode_a.set_pressed_no_signal(m == "a")
	_b_mode_b.set_pressed_no_signal(m == "b")
	var cloture := _type() == "pel" and m == "b"
	var lm := HBoxContainer.new()
	lm.add_child(Style.label("MONTANT", 20, Style.capitales(), Style.TEXTE_2))
	_l_montant = Style.label("", 40 if not compact else 34, Style.chiffres())
	_l_montant.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_l_montant.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lm.add_child(_l_montant)
	_ligne_montant = lm
	_droite.add_child(lm)
	_slider = HSlider.new()
	_slider.custom_minimum_size = Vector2(0, 44)
	_slider.step = 0.0
	_slider.value_changed.connect(_on_slider)
	_droite.add_child(_slider)
	var rapides := HBoxContainer.new()
	rapides.add_theme_constant_override("separation", 8)
	for k in [[0.10, "10 %"], [0.25, "25 %"], [0.5, "50 %"], [1.0, "Tout"]]:
		var r := Button.new()
		r.text = k[1]
		r.custom_minimum_size = Vector2(0, 60 if compact else 72)
		r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.pressed.connect(_part.bind(float(k[0])))
		rapides.add_child(r)
	_droite.add_child(rapides)
	lm.visible = not cloture
	_slider.visible = not cloture
	rapides.visible = not cloture
	# PEL : versement mensuel choisi à l'ouverture
	if _type() == "pel" and m == "a" and e.joueur.pel.is_empty():
		var lp := HBoxContainer.new()
		lp.add_theme_constant_override("separation", 8)
		lp.add_child(Style.label("PUIS PAR MOIS", 18, Style.capitales(), Style.TEXTE_2))
		var gp := ButtonGroup.new()
		var choix_mens: Array = Produits.params()["pel"]["mensuels_F"]
		_mensuel = Produits.f(float(choix_mens[1]))
		for mf in choix_mens:
			var b := Button.new()
			b.text = Format.montant(Produits.f(float(mf)), a)
			b.toggle_mode = true
			b.button_group = gp
			b.theme_type_variation = "BoutonBascule"
			b.custom_minimum_size = Vector2(0, 56)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.set_pressed_no_signal(absf(Produits.f(float(mf)) - _mensuel) < 0.01)
			b.pressed.connect(_choisir_mensuel.bind(Produits.f(float(mf))))
			lp.add_child(b)
		_droite.add_child(lp)
	_recap = GridContainer.new()
	_recap.columns = 2
	_recap.add_theme_constant_override("v_separation", 0)
	_droite.add_child(_recap)
	_bande_frais = PanelContainer.new()
	_bande_frais.add_theme_stylebox_override("panel", Style.pastille(Style.CUIVRE, 12, 6))
	_bande_frais.visible = false
	_droite.add_child(_bande_frais)
	_l_alerte = _texte("", 18 if compact else 20, Style.ui_gras(), Style.ALERTE)
	_droite.add_child(_l_alerte)
	_b_ok = Style.bouton("", true, 72 if compact else 80)
	_b_ok.pressed.connect(_confirmer)
	_droite.add_child(_b_ok)
	var maxi := _maximum()
	_slider.max_value = maxf(0.01, maxi)
	var v0 := montant_initial if montant_initial >= 0.0 else maxi * 0.25
	_regler_montant(minf(v0, maxi))
	_maj_carnet()


func _choisir_mensuel(v: float) -> void:
	_mensuel = v
	_rafraichir()


func _info_prix(a: int) -> Label:
	var t := ""
	match _type():
		"livret":
			t = "%s %% · plafond %s" % [Banquier.taux_txt(Marche.taux_livret(a)), Format.montant(Marche.plafond_livret(a), a)]
		"pel":
			t = Banquier.texte_taux_pel(e)
		"emprunt":
			t = "%s %% sur 10 ans" % Banquier.taux_txt(Produits.taux_emprunt(Dates.annee(a)))
		"av":
			t = "%s %% l'an dernier" % Banquier.taux_txt(Produits.taux_av(Dates.annee(a) - 1))
		_:
			var p := e.cours(produit)
			var p0 := e.cours(produit, e.m - 1)
			t = Format.montant(p, a, true) + (" l'action" if _type() == "action" else " la part")
			if e.en_offre(produit):
				t += " · offre publique"
			elif not is_nan(p0) and p0 > 0.0:
				t += " · " + Format.pct(p / p0 - 1.0) + " ce mois"
	var l := Style.label(t, 20, Style.chiffres(), Style.TEXTE_2)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l


func _bouton_mode(groupe: ButtonGroup, texte: String, m: String) -> Button:
	var o := Button.new()
	o.text = texte
	o.toggle_mode = true
	o.button_group = groupe
	o.theme_type_variation = "BoutonBascule"
	o.custom_minimum_size = Vector2(0, 60 if compact else 72)
	o.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	o.pressed.connect(func() -> void: _afficher_ordre(produit, m, -1.0))
	return o


func _detenu() -> float:
	match _type():
		"livret":
			return e.joueur.livret
		"pel":
			return e.joueur.valeur_pel()
		"emprunt":
			return e.joueur.valeur_emprunts()
		"av":
			return e.joueur.valeur_av() + float(e.joueur.av.get("courus", 0.0))
	return e.valeur_ligne(e.joueur, produit)


func _maximum() -> float:
	if mode == "b":
		return _detenu()
	if _type() == "livret":
		return maxf(0.0, minf(e.joueur.cc, e.place_livret(e.joueur)))
	return maxf(0.0, e.joueur.cc)


func _part(k: float) -> void:
	_regler_montant(_maximum() * k)


func _on_slider(v: float) -> void:
	if not _maj_en_cours:
		_regler_montant(v)


## Arrondi à 10 F près (sauf « Tout ») ; actions : montant calé sur ce qui est réellement investi.
func _regler_montant(v: float) -> void:
	var maxi := _maximum()
	var f := v * Format.TAUX_EURO
	if v < maxi - 0.01:
		f = floor(f / 10.0) * 10.0
	montant = minf(maxi, f / Format.TAUX_EURO)
	if _type() == "action":
		if mode == "a":
			var d := e.devis_achat(produit, montant)
			if d["ok"]:
				montant = minf(maxi, float(d["total"]))
		else:
			var dv := e.devis_vente(e.joueur, produit, montant, montant >= _detenu() - 0.01)
			if dv["ok"]:
				montant = minf(maxi, float(dv["brut"]))
	_maj_en_cours = true
	_slider.value = montant
	_maj_en_cours = false
	_rafraichir()


func _ligne(titre: String, valeur: String, couleur := Style.TEXTE) -> void:
	var t := Style.label(titre, 20 if compact else 22, Style.ui(), Style.TEXTE_2)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_recap.add_child(t)
	var v := Style.label(valeur, 20 if compact else 22, Style.chiffres(), couleur)
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_recap.add_child(v)


func _rafraichir() -> void:
	var a := e.ab_courant()
	_l_montant.text = Format.montant(montant, a)
	for c in _recap.get_children():
		_recap.remove_child(c)
		c.queue_free()
	for c in _bande_frais.get_children():
		_bande_frais.remove_child(c)
		c.queue_free()
	_bande_frais.visible = false
	_l_alerte.text = ""
	_l_alerte.add_theme_color_override("font_color", Style.ALERTE)
	var ok := montant > 0.005
	var texte_ok := ""
	var reste := e.joueur.cc
	var achat := mode == "a"
	match _type():
		"livret":
			if achat:
				reste -= montant
				_ligne("Sans frais ni impôt", "")
				texte_ok = "DÉPOSER " + Format.montant(montant, a)
			else:
				reste += montant
				texte_ok = "RETIRER " + Format.montant(montant, a)
		"pel":
			if achat:
				_ligne("Taux garanti", Banquier.texte_taux_pel(e))
				if e.joueur.pel.is_empty():
					_ligne("Puis chaque mois, automatiquement", Format.montant(_mensuel, a))
					ok = ok and montant >= Produits.f(float(Produits.params()["pel"]["mensuel_min_F"])) - 0.005
					texte_ok = "OUVRIR AVEC " + Format.montant(montant, a)
				else:
					texte_ok = "VERSER " + Format.montant(montant, a)
				reste -= montant
				_l_alerte.text = "Bloqué : un retrait ferme le plan ; avant 4 ans, la prime de l'État est perdue."
			else:
				var d := Produits.devis_cloture_pel(e, e.joueur)
				ok = d["ok"]
				if ok:
					_ligne("Vous récupérez", Format.montant(d["recu"], a))
					if d["anticipee"]:
						_ligne("Intérêts perdus (avant 4 ans)", Format.MOINS + Format.montant(d["penalite"], a), Style.ALERTE)
						_l_alerte.text = "Le plan aura 4 ans en %s : avant, il est clos au taux réduit, sans la prime." % Dates.texte(int(d["echeance_ab"]))
					reste += float(d["recu"])
					texte_ok = "CLÔTURER LE PEL"
		"emprunt":
			if achat:
				var te := Produits.taux_emprunt(Dates.annee(a))
				_ligne("Taux fixe pendant 10 ans", Banquier.taux_txt(te) + " %")
				_ligne("Coupon chaque année, après 16 % d'impôt", Format.montant(montant * te / 100.0 * 0.84, a))
				reste -= montant
				texte_ok = "PRÊTER " + Format.montant(montant, a)
			else:
				var dv := Produits.devis_vente_emprunt(e, e.joueur, montant, montant >= _detenu() - 0.01)
				ok = dv["ok"]
				if ok:
					_ligne("Revendu au prix d'achat", Format.montant(dv["nominal"], a))
					_ligne("Intérêts courus, après impôt", Format.montant(float(dv["couru"]) - float(dv["impot"]), a, false, true))
					reste += float(dv["recu"])
					texte_ok = "REVENDRE POUR " + Format.montant(dv["recu"], a)
		"av":
			if achat:
				var fr := montant * float(Produits.params()["av"]["entree"]) / 100.0
				_ligne("Frais d'entrée (4 %)", Format.montant(fr, a, true), Style.CUIVRE)
				_ligne("Placé sur le contrat", Format.montant(montant - fr, a))
				reste -= montant
				texte_ok = "VERSER " + Format.montant(montant, a)
			else:
				var dr := Produits.devis_rachat_av(e, e.joueur, montant, montant >= _detenu() - 0.01)
				ok = dr["ok"]
				if ok:
					_ligne("Dont gains", Format.montant(dr["gains"], a))
					_ligne("Impôt sur les gains (%s %%)" % Format.nombre(dr["taux"], 0), Format.MOINS + Format.montant(dr["impot"], a))
					_l_alerte.text = "Impôt sur les gains retirés : %s %% (contrat de %s). 0 %% à partir de %s." % [Format.nombre(dr["taux"], 0), Dates.duree(int(dr["age"])), Dates.texte(int(dr["exoneration_ab"]))]
					reste += float(dr["recu"])
					texte_ok = "RETIRER POUR " + Format.montant(dr["recu"], a)
		_:
			if achat:
				var d := e.devis_achat(produit, montant)
				if d["ok"]:
					if _type() == "action":
						_ligne("%d actions × %s" % [int(d["qte"]), Format.montant(d["prix"], a, true)], Format.montant(d["brut"], a))
						_ligne("Frais de courtage" if not d.get("offre", false) else "Sans courtage (offre publique)", Format.montant(d["frais"], a, true), Style.CUIVRE)
						_avertir_frais(float(d["frais"]), float(d["total"]), a)
					else:
						_ligne("Placé dans la SICAV", Format.montant(d["brut"], a))
						_ligne("Frais d'entrée (2 %)", Format.montant(d["frais"], a, true), Style.CUIVRE)
					reste -= float(d["total"])
					texte_ok = "ACHETER POUR " + Format.montant(d["total"], a)
				else:
					ok = false
					_ligne(str(d["msg"]) if montant > 0.005 else "Choisissez un montant.", "")
					texte_ok = "ACHETER"
			else:
				var dv := e.devis_vente(e.joueur, produit, montant, montant >= _detenu() - 0.01)
				if dv["ok"]:
					_ligne("Vous vendez", Format.montant(dv["brut"], a))
					if float(dv["frais"]) > 0.0:
						_ligne("Frais de courtage", Format.MOINS + Format.montant(dv["frais"], a, true), Style.CUIVRE)
					_ligne("Plus-value", Format.montant(dv["pv"], a, false, true), Style.GAIN if float(dv["pv"]) >= 0.0 else Style.PERTE)
					_ligne("Impôt sur la plus-value (%s %%)" % Format.nombre(dv["taux"], 0), Format.MOINS + Format.montant(dv["impot"], a))
					texte_ok = "VENDRE POUR " + Format.montant(dv["recu"], a)
					reste += float(dv["recu"])
				else:
					ok = false
					texte_ok = "VENDRE"
	_ligne("Reste sur le compte", Format.montant(reste, a))
	# Garde-fou non bloquant : coussin sous 3 mois
	var dep := float(e.depenses()["total"])
	var livret_apres := e.joueur.livret
	if _type() == "livret":
		livret_apres += montant if achat else -montant
	var coussin := (maxf(0.0, reste) + livret_apres) / dep
	if ok and achat and coussin < 3.0 and _l_alerte.text == "":
		_l_alerte.text = "Attention : votre coussin de sécurité passerait à %s mois de dépenses." % Format.nombre(coussin, 1)
	_b_ok.text = texte_ok
	_b_ok.disabled = not ok


## Avertissement F03 (13 §3.4) : un ordre d'actions dont les frais dépassent 2 % du montant.
func _avertir_frais(frais: float, total: float, a: int) -> void:
	if total <= 0.0 or frais / total <= float(Banquier.donnees()["frais_pedagogie"]["seuil_alerte"]):
		return
	var part := frais / total
	var hausse := (1.0 + part) / (1.0 - part) - 1.0
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	var l := Style.label("Petit ordre, gros frais : %s, soit %s. L'action devra monter d'environ %s avant de vous rapporter 1 F." % [
		Format.montant(frais, a, true), Format.pct(part, 1).trim_prefix("+"), Format.pct(hausse, 1).trim_prefix("+")], 18, Style.ui_gras(), Style.CUIVRE)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = _largeur_droite - 260.0
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(l)
	var seuil: float = float(Marche.frais(a)["min"]) / float(Banquier.donnees()["frais_pedagogie"]["seuil_alerte"])
	if e.joueur.cc >= float(seuil):
		var g := Button.new()
		g.text = "Grouper : " + Format.montant(float(seuil), a)
		g.custom_minimum_size = Vector2(220, 56)
		g.add_theme_font_size_override("font_size", 18)
		g.pressed.connect(_regler_montant.bind(float(seuil)))
		h.add_child(g)
	_bande_frais.add_child(h)
	_bande_frais.visible = true


func _confirmer() -> void:
	var r: Dictionary
	var achat := mode == "a"
	var tout := montant >= _detenu() - 0.01
	var frais := 0.0
	var type := _type()
	match type:
		"livret":
			r = Partie.deposer_livret(montant) if achat else Partie.retirer_livret(montant)
		"pel":
			if achat:
				r = Partie.ouvrir_pel(montant, _mensuel) if e.joueur.pel.is_empty() else Partie.verser_pel(montant)
			else:
				r = Partie.cloturer_pel()
		"emprunt":
			r = Partie.acheter_emprunt(montant) if achat else Partie.vendre_emprunt(montant, tout)
		"av":
			r = Partie.verser_av(montant) if achat else Partie.racheter_av(montant, tout)
			if achat:
				frais = float(r.get("frais", 0.0))
		_:
			r = Partie.acheter(produit, montant) if achat else Partie.vendre(produit, montant, tout)
			frais = float(r.get("frais", 0.0))
	if not r.get("ok", false):
		Juice.secouer(0.15)
		var x0 := _ligne_montant.position.x
		var t := _ligne_montant.create_tween()
		for k in 4:
			t.tween_property(_ligne_montant, "position:x", x0 + (10.0 if k % 2 == 0 else -10.0), 0.04)
		t.tween_property(_ligne_montant, "position:x", x0, 0.04)
		_l_alerte.text = str(r.get("msg", "Ordre refusé."))
		_l_alerte.add_theme_color_override("font_color", Style.PERTE)
		return
	ordre_passe.emit(_b_ok.get_global_rect().get_center(), montant, achat, frais)
	var texte_fait := "C'EST FAIT !"
	if type in ["sicav", "action"]:
		texte_fait = "ACHETÉ !" if achat else "VENDU !"
	var vert := Style.boite(Style.GAIN, 16, 28, 14)
	_b_ok.add_theme_stylebox_override("normal", vert)
	_b_ok.add_theme_stylebox_override("disabled", vert)
	_b_ok.add_theme_stylebox_override("hover", vert)
	_b_ok.text = texte_fait
	_b_ok.disabled = true
	Juice.pop(_b_ok)
	_maj_carnet()
	# Première souscription d'un produit avec frais : la confirmation s'agrandit (F01)
	if achat and frais > 0.0 and type in ["sicav", "action", "av"] and not bool(e.banque.get("f01_vu", false)):
		e.banque["f01_vu"] = true
		var montant_total := float(r.get("total", r.get("montant", montant)))
		var t2 := create_tween()
		t2.tween_interval(0.7)
		t2.tween_callback(_afficher_f01.bind(type, montant_total, frais))
		return
	var t3 := create_tween()
	t3.tween_interval(1.1)
	t3.tween_callback(_afficher_fiche.bind(produit))


# =====================================================================
# Encart des frais (F01, 13 §3.3)
# =====================================================================

func _afficher_f01(type: String, montant_total: float, frais: float) -> void:
	_vider()
	var a := e.ab_courant()
	var nom := str(Banquier.info_produit(produit).get("nom", produit))
	var tete := HBoxContainer.new()
	var l1 := Style.label("C'EST FAIT : %s · %s" % [Format.montant(montant_total, a), nom], 20 if compact else 22, Style.ui_gras(), Style.GAIN)
	l1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tete.add_child(l1)
	tete.add_child(Style.label("Frais payés tout de suite : " + Format.montant(frais, a, true), 20 if compact else 22, Style.chiffres(), Style.CUIVRE))
	_droite.add_child(tete)
	var phrase := "« Un mot sur les frais, dont on parle trop peu. Voici vos %s dans 20 ans, si le placement rapportait 7 %% par an avant frais (une hypothèse, pas une promesse). »" % Format.entier(montant_total, a)
	_droite.add_child(_texte(phrase, 18 if compact else 22, Style.ui(), Style.TEXTE))
	var piles := Piles.new()
	piles.compacte = compact
	piles.custom_minimum_size = Vector2(_largeur_droite, 230 if compact else 330)
	var p := Banquier.piles(type, montant_total, a, frais)
	var titre2: String = {"sicav": "CETTE SICAV", "av": "CE CONTRAT", "action": "CET ORDRE"}.get(type, "CE PRODUIT")
	var detail2: String = {"sicav": "2 % + 1,5 %/an", "av": "4 % à l'entrée", "action": "courtage " + Format.entier(frais, a)}.get(type, "")
	_droite.add_child(piles)
	piles.regler(p, a, ["SANS FRAIS", titre2, p["nom3"]], ["", detail2, p["detail3"]])
	var bas := HBoxContainer.new()
	bas.add_theme_constant_override("separation", 12)
	var l2 := _texte("Les pièces en pointillé : des gains qui n'ont jamais existé. Un frais annuel se prend chaque année sur tout le capital, gains compris.", 16 if compact else 18, Style.ui(), Style.TEXTE_2)
	l2.custom_minimum_size.x = _largeur_droite - 230.0
	l2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bas.add_child(l2)
	var ok := Style.bouton("COMPRIS", true, 64 if compact else 72)
	ok.custom_minimum_size.x = 210
	ok.pressed.connect(_afficher_fiche.bind(produit))
	bas.add_child(ok)
	_droite.add_child(bas)


# =====================================================================
# Dessins
# =====================================================================

func _dessiner_jauge() -> void:
	var r := Rect2(Vector2.ZERO, _jauge.size)
	Dessin.arrondi(_jauge, r, Style.FILET, 7)
	var k := float(Banquier.nb_decouverts(e)) / float(Banquier.ordre_carnet().size())
	if k > 0.0:
		Dessin.arrondi(_jauge, Rect2(r.position, Vector2(maxf(14.0, r.size.x * k), r.size.y)), Style.ACCENT, 7)


func _dessiner_croix(b: Button) -> void:
	var m := b.size / 2.0
	b.draw_line(m + Vector2(-12, -12), m + Vector2(12, 12), Style.TEXTE, 4.0, true)
	b.draw_line(m + Vector2(12, -12), m + Vector2(-12, 12), Style.TEXTE, 4.0, true)
