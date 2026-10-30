extends RefCounted
## Étapes de capture et contrôles de l'interface pixel (lot PX2, lignes « UI ») :
## - planche_cadres : tous les cadres 9-patch et les icônes sur un fond uni ; chaque bloc T × T est uniforme ;
## - cibles : parcours des écrans (titre, rue, carte, journal, courrier, relevé, fin, info, confirmation,
##   menu, historique, fenêtre Banque) : cibles tactiles, textes qui débordent, plus petite taille Pixelify ;
## - hud : bouton HISTORIQUE (taille en px physiques, jamais recouvert, panneau ouvert et fermé) ;
## - polices_jeu : planche des polices du jeu (accents français, tnum d'Atkinson).

const ETAPES := ["planche_cadres", "cibles", "hud", "polices_jeu"]
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
			"source_maison", "source_banque", "source_media", "piece", "calendrier"]:
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
	print("UI polices pixelify_min=%d atkinson=%s" % [_pix_min, "oui" if PolicesPixel.est_atkinson(hud.l_patr.get_theme_font("font")) and PolicesPixel.est_atkinson(hud.l_cc.get_theme_font("font")) else "non"])


## Cibles tactiles visibles sous « racine » (boutons et contrôles marqués « cible »), en px physiques.
func _mesurer(nom: String, racine: Node) -> void:
	if racine == null:
		print("UI cibles ecran=%s n=0 min=0 sous_seuil=1 (écran absent)" % nom)
		return
	var echelle := sc.get_viewport().get_final_transform().get_scale().x
	var seuil := 80.0 if (Ecran.telephone_simule or OS.has_feature("mobile")) else 40.0
	var vue := sc.get_viewport().get_visible_rect()
	var n := 0
	var mini := 99999.0
	var sous := []
	var debord := []
	for c in racine.find_children("*", "Control", true, false) + [racine]:
		var ctl := c as Control
		if ctl == null or not ctl.is_visible_in_tree():
			continue
		var r := ctl.get_global_rect()
		if not vue.intersects(r):
			continue
		# Défilement : seules les lignes visibles comptent
		var defile := _defilement_parent(ctl)
		if defile != null and not defile.get_global_rect().intersects(r.grow(-minf(2.0, minf(r.size.x, r.size.y) / 2.0 - 0.01)).abs()):
			continue
		var cible := (ctl is BaseButton and ctl.mouse_filter != Control.MOUSE_FILTER_IGNORE and not (ctl as BaseButton).disabled) or ctl.has_meta("cible")
		if cible:
			n += 1
			var cote := minf(r.size.x, r.size.y) * echelle
			mini = minf(mini, cote)
			if cote < seuil - 0.01:
				sous.append("%s %s %dx%d" % [ctl.get_class(), _nom(ctl), roundi(r.size.x * echelle), roundi(r.size.y * echelle)])
		# Débordements : texte plus large que sa boîte sans retour à la ligne ni ellipse
		if ctl is Label:
			var l := ctl as Label
			if l.text != "" and l.autowrap_mode == TextServer.AUTOWRAP_OFF and not l.clip_text and l.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING \
					and l.get_minimum_size().x > l.size.x + 1.0:
				debord.append("Label « %s »" % l.text.left(24))
			_police(l)
		elif ctl is Button and (ctl as Button).text != "":
			var b := ctl as Button
			if not b.clip_text and b.get_minimum_size().x > b.size.x + 1.0:
				debord.append("Button « %s »" % b.text.left(24))
			_police(b)
	# Fenêtre hors de l'écran
	if racine is Control and racine != sc.jeu.hud and racine != sc.jeu.titre and not vue.grow(1.0).encloses((racine as Control).get_global_rect()):
		debord.append("fenêtre hors écran %s" % str((racine as Control).get_global_rect()))
	print("UI cibles ecran=%s n=%d min=%d sous_seuil=%d%s" % [nom, n, roundi(mini if n > 0 else 0.0), sous.size(), "" if sous.is_empty() else " (" + ", ".join(sous) + ")"])
	print("UI debordements=%d ecran=%s%s" % [debord.size(), nom, "" if debord.is_empty() else " (" + ", ".join(debord) + ")"])


func _police(c: Control) -> void:
	var f: Font = c.get_theme_font("font")
	if PolicesPixel.est_pixelify(f):
		var t := c.get_theme_font_size("font_size")
		if t < PolicesPixel.TAILLE_MIN_PIXELIFY:
			print("UI pixelify_petit taille=%d %s %s" % [t, c.get_class(), _nom(c) if c is Button else "« %s »" % (c as Label).text.left(20)])
		_pix_min = mini(_pix_min, t)


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
	hud.basculer_panneau(not Ecran.compact())
	# On retire les notifications de contrôle avant la capture
	for c in hud.notifs.get_children():
		c.queue_free()
	hud.point_banque(false)
	await sc.delai(0.6)
	_mesurer("hud", hud)


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
