extends RefCounted
## Étapes de capture et contrôles de l'interface pixel (lot PX2, lignes « UI ») :
## - planche_cadres : tous les cadres 9-patch et les icônes sur un fond uni ; chaque bloc T × T est uniforme ;
## - cibles : parcours des écrans (titre, rue, carte, journal, courrier, relevé, fin, info, confirmation,
##   menu, historique, fenêtre Banque) : cibles tactiles, textes qui débordent, plus petite taille Pixelify ;
## - hud : bouton HISTORIQUE (taille en px physiques, jamais recouvert, panneau ouvert et fermé) ;
## - polices_jeu : planche des polices du jeu (accents français, tnum d'Atkinson).

const ETAPES := ["planche_cadres", "cibles", "hud", "polices_jeu", "etiquettes_bord", "etiquettes_aller", "etiquettes_banque", "etiquettes_gazette"]
const ACCENTS := "ÉÈÊÀÇÔŒÙÎ àéèêçôœùî « » ‹ › · − ×"   # « → » : absent des polices, affiché « › » (Style.sans_fleche)

var sc: ScenariosCapture
var _pix_min := 999


func jouer(etape: String) -> void:
	var jeu := sc.jeu
	match etape:
		"planche_cadres":
			await _planche_cadres()
		"cibles":
			await _cibles(jeu)
		"hud":
			sc.partir_de_la_rue(etape)
			sc.aller_a(Dates.lire("1988-01"), true)
			await sc.delai(1.0)
			await _hud(jeu)
		"polices_jeu":
			await _polices_jeu()
		"etiquettes_bord", "etiquettes_aller", "etiquettes_banque", "etiquettes_gazette":
			await _etiquettes(etape, jeu)


# =====================================================================
# Étiquettes et flèches de bord bornées au rectangle libre (C8)
# =====================================================================

func _etiquettes(etape: String, jeu: Node) -> void:
	sc.partir_de_la_rue(etape)
	var hud: Hud = jeu.hud
	var ville: Node2D = jeu.ville
	await sc.delai(1.2)
	match etape:
		"etiquettes_banque":
			ville.call("aller_vers", "banque", 0.3)
			await sc.delai(0.8)
		"etiquettes_gazette":
			ville.call("aller_vers", "media", 0.3)
			await sc.delai(0.8)
		"etiquettes_aller":
			var f: Control = hud.etiquettes["banque"]
			print("UI aller avant banque cachee=%s mode=%s" % ["non" if ville.call("est_visible", "banque") else "oui", "fleche" if str(f.get_meta("fleche", "")) != "" else "sous"])
			await sc.clic_dehors(sc.position_fenetre(f))   # vrai toucher simulé au centre de la flèche
			await sc.delai(1.2)
			print("UI aller banque visible=%s" % ["oui" if ville.call("est_visible", "banque") else "non"])
	hud.placer_etiquettes()
	await sc.get_tree().process_frame
	var libre := hud.rect_libre()
	for id in ["maison", "media", "banque"]:
		var p: Control = hud.etiquettes[id]
		var mode := "fleche" if str(p.get_meta("fleche", "")) != "" else "sous"
		print("UI etiquette %s mode=%s dans_libre=%s rect=%s libre=%s" % [id, mode, "oui" if libre.encloses(p.get_global_rect()) else "non", str(p.get_global_rect()), str(libre)])
	await sc.delai(1.5)   # glissement de la caméra terminé avant la capture et la sortie


# =====================================================================
# Planche des cadres (CA-I5)
# =====================================================================

func _planche_cadres() -> void:
	var calque := CanvasLayer.new()
	calque.layer = 20
	sc.add_child(calque)
	var fond := ColorRect.new()
	fond.color = PalettePixel.couleur("vert")
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	calque.add_child(fond)
	var cadres: Array = CadresPixel.MARGES.keys()
	var x := 30.0
	var y := 30.0
	var places: Array = []   # Rect2 en px virtuels (positions et tailles multiples de 3)
	var vue := sc.get_viewport().get_visible_rect().size
	for nom: String in cadres:
		var p := Panel.new()
		p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		p.add_theme_stylebox_override("panel", CadresPixel.style(nom))
		var taille := Vector2(150, 105)
		if x + taille.x > vue.x - 30.0:
			x = 30.0
			y += 135.0
		p.position = Vector2(x, y)
		p.size = taille
		calque.add_child(p)
		places.append(Rect2(p.position, taille))
		x += taille.x + 30.0
	y += 135.0
	x = 30.0
	for nom: String in ["pause", "lecture", "x2", "x3", "menu", "historique", "fleche_haut", "fleche_bas", "curseur", "drapeau", "croix",
			"source_maison", "source_banque", "source_media", "piece", "calendrier", "chevron_gauche", "chevron_droite"]:
		var t := CadresPixel.texture(nom)
		var r := TextureRect.new()
		r.texture = t
		r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if x + t.get_width() > vue.x - 30.0:
			x = 30.0
			y += 66.0
		r.position = Vector2(x, y)
		calque.add_child(r)
		places.append(Rect2(r.position, t.get_size()))
		x += t.get_width() + 30.0
	for i in 4:
		await sc.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img := sc.get_viewport().get_texture().get_image()
	var t_fac := Ecran.facteur_texel()
	var irreguliers := 0
	var blocs := 0
	var echelle := sc.get_viewport().get_final_transform().get_scale().x
	var fautifs := {}
	for i in places.size():
		var r: Rect2 = places[i]
		var o := (r.position * echelle).round()
		var n := (r.size * echelle / t_fac).floor()
		for by in int(n.y):
			for bx in int(n.x):
				var x0 := int(o.x) + bx * t_fac
				var y0 := int(o.y) + by * t_fac
				if x0 + t_fac > img.get_width() or y0 + t_fac > img.get_height():
					continue
				blocs += 1
				var c0 := img.get_pixel(x0, y0)
				var ok := true
				for dy in t_fac:
					for dx in t_fac:
						if not img.get_pixel(x0 + dx, y0 + dy).is_equal_approx(c0):
							ok = false
				if not ok:
					irreguliers += 1
					fautifs[i] = int(fautifs.get(i, 0)) + 1
	print("UI cadres facteur_texel=%d irreguliers=%d (blocs %d, cadres %d, icônes %d, fenêtre %s, échelle %.5f, zone %s)%s" % [t_fac, irreguliers, blocs, cadres.size(),
		places.size() - cadres.size(), sc.get_window().size, echelle, Ecran.taille(), "" if fautifs.is_empty() else " fautifs " + str(fautifs)])


# =====================================================================
# Cibles tactiles, débordements, tailles Pixelify (CA-I6, CA-I8, CA-I9)
# =====================================================================

func _cibles(jeu: Node) -> void:
	var modales: Modales = jeu.modales
	var hud: Hud = jeu.hud
	var e: EtatPartie = Partie.etat
	await sc.delai(2.5)
	_mesurer("titre", jeu.titre)
	modales.confirmer("NOUVELLE PARTIE", "Une partie est en cours. Commencer une nouvelle partie l'effacera définitivement.", "EFFACER ET RECOMMENCER", "GARDER MA PARTIE")
	await sc.delai(0.8)
	_mesurer("confirmation", modales.courant)
	modales.fermer("non")
	await sc.delai(0.5)
	jeu.demarrer_direct(0)
	await sc.attendre_que(func() -> bool: return modales.genre_courant == "appel", 8.0)
	await sc.delai(1.8)
	_mesurer("carte_banquier", modales.courant)
	modales.fermer("plus_tard")
	await sc.attendre_que(func() -> bool: return not jeu.sequences.occupe and not modales.ouverte(), 6.0)
	Partie.changer_vitesse(0)
	await sc.delai(0.6)
	hud.basculer_panneau(true)
	await sc.delai(0.4)
	_mesurer("rue_panneau_ouvert", hud)
	hud.basculer_panneau(false)
	await sc.delai(0.4)
	_mesurer("rue_panneau_ferme", hud)
	hud.basculer_panneau(not Ecran.compact())
	jeu.ouvrir_menu()
	await sc.delai(0.6)
	_mesurer("menu", modales.courant)
	modales.fermer("reprendre")
	await sc.delai(0.6)
	jeu.toucher_batiment("maison")
	await sc.delai(0.8)
	_mesurer("info", modales.courant)
	modales.fermer("fermer")
	await sc.delai(0.6)
	# Fenêtre Banque : carnet et fiche, ordre, CHAQUE MOIS
	sc.aller_a(Dates.lire("1986-12"), true)
	jeu.ouvrir_banque("sicav", -2.0)
	await sc.delai(1.5)
	_mesurer("banque_carnet_fiche", modales.courant)
	modales.banque.call("_afficher_ordre", "sicav", "a", -1.0)
	await sc.delai(0.6)
	_mesurer("banque_ordre", modales.courant)
	modales.banque.call("_afficher_automatique", "sicav")
	await sc.delai(0.6)
	_mesurer("banque_chaque_mois", modales.courant)
	modales.banque.fermer_demande.emit()
	await sc.delai(0.8)
	# Relevé (détail des frais)
	jeu.call("_detail_frais")
	await sc.delai(0.8)
	_mesurer("releve", modales.courant)
	modales.fermer("fermer")
	await sc.delai(0.6)
	# Journal du krach, puis le courrier qui suit
	sc.aller_a_modale("p1e6", true)
	await sc.attendre_que(func() -> bool: return modales.genre_courant == "journal", 15.0)
	await sc.delai(1.8)
	_mesurer("journal_krach", modales.courant)
	modales.call("_on_choix_journal", "rien")
	Partie.changer_vitesse(3)
	await sc.attendre_que(func() -> bool: return modales.genre_courant == "courrier", 15.0)
	await sc.delai(1.4)
	_mesurer("courrier", modales.courant)
	modales.fermer(str(e.contenu_modale()["choix"][0]["id"]) if not e.modale.is_empty() else "fermer")
	Partie.changer_vitesse(0)
	await sc.delai(1.0)
	# Carte de l'héritage (D08, la plus haute)
	sc.aller_a_modale("D08", true)
	await sc.attendre_que(func() -> bool: return modales.genre_courant == "appel", 10.0)
	await sc.delai(1.8)
	_mesurer("carte_heritage", modales.courant)
	modales.fermer("compris")
	await sc.attendre_que(func() -> bool: return not jeu.sequences.occupe and not modales.ouverte(), 6.0)
	Partie.changer_vitesse(0)
	# Historique : onglets et lignes
	sc.aller_a(Dates.lire("1988-06"), true)
	jeu.ouvrir_historique("")
	await sc.delai(1.2)
	_mesurer("historique", modales.courant)
	modales.fermer("fermer")
	await sc.delai(0.6)
	# Fin de la démonstration
	sc.aller_a(Dates.lire("1988-11"), true)
	Partie.changer_vitesse(3)
	await sc.attendre_que(func() -> bool: return modales.genre_courant == "fin", 20.0)
	await sc.delai(2.0)
	_mesurer("fin", modales.courant)
	print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d atkinson=%s" % [_pix_min, _atk_min, _chiffres_pixelify, "oui" if PolicesPixel.est_atkinson(hud.l_patr.get_theme_font("font")) and PolicesPixel.est_atkinson(hud.l_cc.get_theme_font("font")) else "non"])
	print("UI fleches_texte=%d (« → » ou « › » affichés en texte ; attendu 0 après F1-L)" % _fleches)


## Contrôles d'un écran (racine : fenêtre, HUD ou titre) : cibles tactiles (px physiques ; seuil :
## Style.cible_min() au téléphone, 40 px sur PC), textes qui débordent, conteneurs plus grands que leur
## place (hors_cadre), éléments hors de l'écran (hors_ecran), fenêtre et boutons visibles, polices.
func _mesurer(nom: String, racine: Node) -> void:
	if racine == null:
		print("UI cibles ecran=%s n=0 min=0 sous_seuil=1 (écran absent)" % nom)
		return
	var echelle := sc.get_viewport().get_final_transform().get_scale().x
	var mobile := Ecran.telephone_simule or OS.has_feature("mobile")
	var seuil := (Style.cible_min() * echelle - 0.5) if mobile else 40.0
	var vue := sc.get_viewport().get_visible_rect()
	var fenetre: bool = racine is Control and racine != sc.jeu.hud and racine != sc.jeu.titre
	var n := 0
	var mini := 99999.0
	var sous := []
	var debord := []
	var hors_cadre := []
	var hors_ecran := []
	var boutons_caches := []
	for c in racine.find_children("*", "Control", true, false) + [racine]:
		var ctl := c as Control
		if ctl == null or not ctl.is_visible_in_tree():
			continue
		var r := ctl.get_global_rect()
		var defile := _defilement_parent(ctl)
		var anime := _anime(ctl, racine)
		# Hors écran (hors défilement et animations) ; contrôles vides ou plein écran ignorés
		if defile == null and not anime and ctl.size.x > 1.0 and ctl.size.y > 1.0 and not vue.grow(1.0).encloses(r):
			hors_ecran.append("%s %s %s" % [ctl.get_class(), _nom(ctl), str(r)])
		# Conteneur plus grand que sa place : contenu coupé ou débordant (M1)
		if defile == null and ctl is Container and not (ctl is ScrollContainer):
			var besoin := ctl.get_combined_minimum_size()
			if besoin.y > ctl.size.y + 1.0 or besoin.x > ctl.size.x + 1.0:
				hors_cadre.append("%s %s besoin %dx%d place %dx%d" % [ctl.get_class(), _nom(ctl), roundi(besoin.x), roundi(besoin.y), roundi(ctl.size.x), roundi(ctl.size.y)])
		if defile == null and not anime and ctl.get_parent() is PanelContainer and ctl.get_parent() != racine.get_parent():
			var pr := (ctl.get_parent() as Control).get_global_rect()
			if not pr.grow(1.0).encloses(r):
				hors_cadre.append("%s dépasse de son cadre %s" % [_nom(ctl), _nom(ctl.get_parent())])
		if not vue.intersects(r):
			if fenetre and ctl is BaseButton and not (ctl as BaseButton).disabled:
				boutons_caches.append(_nom(ctl))
			continue
		# Défilement : seules les lignes visibles comptent
		if defile != null and not defile.get_global_rect().intersects(r.grow(-minf(2.0, minf(r.size.x, r.size.y) / 2.0 - 0.01)).abs()):
			continue
		if fenetre and ctl is BaseButton and not (ctl as BaseButton).disabled and defile == null and not vue.grow(1.0).encloses(r):
			boutons_caches.append(_nom(ctl))
		var cible := (ctl is BaseButton and ctl.mouse_filter != Control.MOUSE_FILTER_IGNORE and not (ctl as BaseButton).disabled) or ctl.has_meta("cible")
		if cible:
			n += 1
			# Taille au repos (sans l'échelle d'une animation en cours, ex. carte du carnet qui se retourne)
			var cote := minf(ctl.size.x, ctl.size.y) * echelle
			mini = minf(mini, cote)
			if cote < seuil - 0.01:
				sous.append("%s %s %dx%d" % [ctl.get_class(), _nom(ctl), roundi(ctl.size.x * echelle), roundi(ctl.size.y * echelle)])
		# Débordements : texte plus large que sa boîte sans retour à la ligne ni ellipse
		if ctl is Label:
			var l := ctl as Label
			if l.text != "" and l.autowrap_mode == TextServer.AUTOWRAP_OFF and not l.clip_text and l.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING \
					and l.get_minimum_size().x > l.size.x + 1.0:
				debord.append("Label « %s »" % l.text.left(24))
			_police(l, l.text)
		elif ctl is Button and (ctl as Button).text != "":
			var b := ctl as Button
			if not b.clip_text and b.get_minimum_size().x > b.size.x + 1.0:
				debord.append("Button « %s »" % b.text.left(24))
			_police(b, b.text)
	# HUD : le panneau « Mon argent » ne descend jamais sur la frise (M1 de la recette PX2)
	var hud: Hud = sc.jeu.hud
	if racine == hud and hud.panneau.is_visible_in_tree() and hud.panneau.get_global_rect().end.y > hud.bas.get_global_rect().position.y - 6.0 + 0.5:
		hors_cadre.append("panneau « Mon argent » sur la frise (bas %d, frise %d)" % [roundi(hud.panneau.get_global_rect().end.y), roundi(hud.bas.get_global_rect().position.y)])
	if fenetre and not vue.grow(1.0).encloses((racine as Control).get_global_rect()):
		hors_ecran.append("fenêtre %s" % str((racine as Control).get_global_rect()))
	if fenetre or racine == sc.jeu.titre:
		print("UI fenetre %s dans_ecran=%s boutons_visibles=%s%s" % [nom, "oui" if not fenetre or vue.grow(1.0).encloses((racine as Control).get_global_rect()) else "non",
			"oui" if boutons_caches.is_empty() else "non", "" if boutons_caches.is_empty() else " (" + ", ".join(boutons_caches) + ")"])
	print("UI cibles ecran=%s n=%d min=%d sous_seuil=%d%s" % [nom, n, roundi(mini if n > 0 else 0.0), sous.size(), "" if sous.is_empty() else " (" + ", ".join(sous) + ")"])
	print("UI debordements=%d hors_cadre=%d hors_ecran=%d ecran=%s%s" % [debord.size(), hors_cadre.size(), hors_ecran.size(), nom,
		"" if (debord + hors_cadre + hors_ecran).is_empty() else " (" + ", ".join((debord + hors_cadre + hors_ecran).slice(0, 6)) + ")"])


## Vrai si le contrôle ou un parent jusqu'à la racine est en cours d'animation (échelle ≠ 1 ou rotation).
func _anime(c: Node, racine: Node) -> bool:
	var p := c
	while p != null and p != racine.get_parent():
		if p is Control and ((p as Control).scale != Vector2.ONE or absf((p as Control).rotation) > 0.0001):
			return true
		p = p.get_parent()
	return false


var _atk_min := 999
var _chiffres_pixelify := 0
var _fleches := 0


func _police(c: Control, texte: String) -> void:
	var f: Font = c.get_theme_font("font")
	var t := c.get_theme_font_size("font_size")
	if texte.contains("→") or texte.contains("›") or texte.contains("‹"):
		_fleches += 1
	if PolicesPixel.est_pixelify(f):
		if t < PolicesPixel.TAILLE_MIN_PIXELIFY:
			print("UI pixelify_petit taille=%d %s %s" % [t, c.get_class(), texte.left(20)])
		_pix_min = mini(_pix_min, t)
		var re := RegEx.create_from_string("[0-9]")
		if re.search(texte) != null:
			_chiffres_pixelify += 1
			print("UI chiffres_en_pixelify « %s »" % texte.left(30).replace("\n", " "))
	elif PolicesPixel.est_atkinson(f):
		if t < 20:
			print("UI atkinson_petit taille=%d « %s »" % [t, texte.left(30).replace("\n", " ")])
		_atk_min = mini(_atk_min, t)

func _defilement_parent(c: Node) -> ScrollContainer:
	var p := c.get_parent()
	while p != null:
		if p is ScrollContainer:
			return p
		p = p.get_parent()
	return null


func _nom(c: Control) -> String:
	if c is Button and (c as Button).text != "":
		return "« %s »" % (c as Button).text.left(16).replace("\n", " ")
	return String(c.name)


# =====================================================================
# HUD : bouton HISTORIQUE (CA-I7)
# =====================================================================

func _hud(jeu: Node) -> void:
	var hud: Hud = jeu.hud
	var echelle := sc.get_viewport().get_final_transform().get_scale().x
	# Trois notifications (une par source), panneau ouvert puis fermé
	var a := Partie.etat.ab_courant()
	for s: String in ["maison", "banque", "media"]:
		hud.notifier({"source": s, "titre": "Essai " + s, "texte": "Notification de contrôle du HUD.", "montant": 120.0, "persistant": true}, a)
	await sc.delai(0.8)
	var etats := []
	for ouvert: bool in [true, false]:
		hud.basculer_panneau(ouvert)
		await sc.delai(0.5)
		var r := hud.b_historique.get_global_rect()
		var recouvert := false
		var autres: Array = [hud.panneau, hud.languette] + Array(hud.notifs.get_children())
		for c: Control in autres:
			if c.is_visible_in_tree() and c.get_global_rect().intersects(r):
				recouvert = true
		etats.append(recouvert)
		print("UI historique hauteur=%d largeur=%d recouvert=%s panneau=%s" % [roundi(r.size.y * echelle), roundi(r.size.x * echelle), "oui" if recouvert else "non", "ouvert" if ouvert else "ferme"])
	# A6 (recette PX1) : aucun bouton du HUD ne garde les flèches pour la navigation au clavier
	var focalisables := 0
	for n in hud.find_children("*", "BaseButton", true, false):
		if (n as BaseButton).focus_mode != Control.FOCUS_NONE:
			focalisables += 1
	var proprio := sc.get_viewport().gui_get_focus_owner()
	print("UI focus hud_focalisables=%d focus=%s" % [focalisables, "aucun" if proprio == null else String(proprio.name)])
	# C2 : panneau « Mon argent » ouvert, après la fin de l'animation de bascule : borné par la frise, rien de coupé
	hud.basculer_panneau(true)
	await sc.delai(0.8)
	_panneau(hud)
	hud.basculer_panneau(not Ecran.compact())
	await sc.delai(0.6)
	# On retire les notifications de contrôle avant la capture
	for c in hud.notifs.get_children():
		c.queue_free()
	hud.point_banque(false)
	await sc.delai(0.6)
	_mesurer("hud", hud)


## « UI panneau … » : bas du panneau ≤ haut de la frise − 6, aucun enfant visible hors du cadre (CA-C2).
func _panneau(hud: Hud) -> void:
	var rp := hud.panneau.get_global_rect()
	var frise_y := hud.bas.get_global_rect().position.y
	var coupe := hud.panneau_coupe()
	for n in hud.panneau.find_children("*", "Control", true, false):
		var c := n as Control
		if c.is_visible_in_tree() and c.size.x > 0.0 and not rp.grow(1.0).encloses(c.get_global_rect()):
			coupe = true
	print("UI panneau ouvert=%s bas=%d frise=%d recouvre=%s contenu_coupe=%s rect=%s rect_libre=%s" % ["oui" if hud.panneau.is_visible_in_tree() else "non",
		roundi(rp.end.y), roundi(frise_y), "oui" if rp.end.y > frise_y - 6.0 + 0.5 else "non", "oui" if coupe else "non", str(rp), str(hud.rect_libre())])


# =====================================================================
# Planche des polices du jeu (CA-I8)
# =====================================================================

func _polices_jeu() -> void:
	sc.partir_de_la_rue("polices_jeu")
	var calque := CanvasLayer.new()
	calque.layer = 20
	sc.add_child(calque)
	var p := PanelContainer.new()
	p.theme = Style.theme()
	p.add_theme_stylebox_override("panel", Style.panneau())
	p.position = Vector2(30, 30)
	calque.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	p.add_child(v)
	var lignes := [
		["Pixelify 28 · titres", Style.capitales(), 28], ["Pixelify 48 · " + ACCENTS, Style.manchette(), 48],
		["Atkinson 24 · " + ACCENTS, Style.ui(), 24], ["Atkinson 20 gras · " + ACCENTS, Style.ui_gras(), 20],
		["Chiffres : 0123456789 · 81 862 F · −4 284 F · +612 F", Style.chiffres(), 32], ["Doto · INDICE 1 018", Style.led(), 28],
		["Petites capitales · COMPTE COURANT · PATRIMOINE", Style.petites_capitales(), 18],
	]
	for l: Array in lignes:
		v.add_child(Style.label(str(l[0]), int(l[2]), l[1] as Font))
	await sc.delai(0.5)
	var manque_p := PolicesPixel.manquants(PolicesPixel.PIXELIFY, ACCENTS.replace(" ", ""))
	var manque_a := PolicesPixel.manquants(PolicesPixel.ATKINSON, ACCENTS.replace(" ", ""))
	print("UI polices_jeu pixelify_manquants=« %s » atkinson_manquants=« %s » tnum_atkinson=%s systemfont=0" % [manque_p, manque_a, "oui" if PolicesPixel.tnum_atkinson() else "non"])
