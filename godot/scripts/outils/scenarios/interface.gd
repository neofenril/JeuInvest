extends RefCounted
## Étapes de capture et contrôles de l'interface pixel (lot PX2, lignes « UI ») :
## - planche_cadres : tous les cadres 9-patch et les icônes sur un fond uni ; chaque bloc T × T est uniforme ;
## - cibles : parcours des écrans (titre, rue, carte, journal, courrier, relevé, fin, info, confirmation,
##   menu, historique, fenêtre Banque) : cibles tactiles, textes qui débordent, plus petite taille Pixelify ;
## - hud : bouton HISTORIQUE (taille en px physiques, jamais recouvert, panneau ouvert et fermé) ;
## - polices_jeu : planche des polices du jeu (accents français, tnum d'Atkinson).

const ETAPES := ["planche_cadres", "cibles", "hud", "polices_jeu", "etiquettes_bord", "etiquettes_aller", "etiquettes_banque", "etiquettes_gazette",
	"courrier_repos", "courrier_saut", "courrier_saut_pause", "courrier_inactif", "courrier_bulle", "notifs_saut", "badge_non_lus", "historique_nouveau",
	"etiquettes_balayage", "pastille_signe", "bulle"]
const MOIS_COURRIER := "1986-01"   # départ des étapes du bouton COURRIER (prochain arrêt : novembre 1986, D07)
const ACCENTS := "ÉÈÊÀÇÔŒÙÎ àéèêçôœùî « » ‹ › · − ×"   # « → » : absent des polices, plus jamais affiché (F1-L)

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
		"etiquettes_balayage":
			await _balayage(jeu)
		"pastille_signe":
			await _pastille_signe(jeu)
		"bulle":
			await _bulle(jeu)
		_:
			await _courrier(etape, jeu)


# =====================================================================
# Bouton COURRIER, notifications du saut, badge des non-lus (lot 02, CA-I2, CA-I3, CA-I5, CA-I6)
# =====================================================================

func _courrier(etape: String, jeu: Node) -> void:
	sc.partir_de_la_rue(etape)
	var hud: Hud = jeu.hud
	var ville: Node2D = jeu.ville
	var modales: Modales = jeu.modales
	var e := Partie.etat
	sc.aller_a(Dates.lire(MOIS_COURRIER), true)
	StrategieTest.jouer_mois(e, true)   # la modale du mois d'arrivée, s'il y en a une, est résolue : saut possible
	if not e.modale.is_empty():
		e.resolution_auto()
	sc.rafraichir_apres_saut()
	Partie.changer_vitesse(0 if etape == "courrier_saut_pause" else 1)
	await sc.delai(1.0)
	match etape:
		"courrier_repos":
			var p: Control = hud.etiquettes["banque"]
			var y0 := p.position.y
			hud.sauter_etiquette("banque")
			var decale := p.position.y == y0 - 3.0
			await sc.delai(0.3)
			print("UI sauter_etiquette decale=%s retour=%s" % ["oui" if decale else "non", "oui" if p.position.y == y0 else "non"])
			Partie.changer_vitesse(0)
			await sc.delai(0.6)
		"courrier_saut", "courrier_saut_pause", "notifs_saut", "badge_non_lus", "historique_nouveau":
			jeu.demander_saut()
			print("UI saut depart=%s vitesse=%d saut=%s" % [Dates.texte(e.ab_courant()), Partie.vitesse, "oui" if Partie.saut_actif else "non"])
			await sc.delai(1.6)
			if etape == "notifs_saut":
				# En 1986, les notifications sont rares : 4 notifications de plus, rangées dans le vrai historique
				# pendant le saut (donc non lues) et diffusées comme par Partie (notif_recue puis mois_passe), pour
				# montrer la pile de 3, la 4e qui pousse la plus ancienne vers HISTORIQUE et le badge qui compte la
				# fiche à son arrivée. Image « _vol » pendant le vol, image finale après.
				var modeles := e.historique_recent("").filter(func(h: Dictionary) -> bool: return h["genre"] == "notif").slice(0, 4)
				for h: Dictionary in modeles:
					var n: Dictionary = (h["contenu"] as Dictionary).duplicate(true)
					n["pendant_saut"] = true
					e.historiser_evenement(n)
					hud.notifier(n, e.ab_courant())
					await sc.delai(0.12)
				hud.maj_badge(e.non_lues())   # comme principal._on_mois après les notifications du mois
				var avant := hud.texte_badge_affiche()
				await sc.delai(0.05)
				var en_vol := hud.find_child("FicheVolante", true, false) != null
				await RenderingServer.frame_post_draw
				var chemin := ScenariosCapture.option("capture").replace(".png", "_vol.png")
				if chemin.is_relative_path():
					chemin = ProjectSettings.globalize_path("res://").path_join(chemin)
				sc.get_viewport().get_texture().get_image().save_png(chemin)
				await sc.delai(0.6)
				print("UI notifs historisees=%d fiche_en_vol=%s badge_pendant_vol=« %s » badge_apres=« %s »" % [modeles.size(), "oui" if en_vol else "non", avant, hud.texte_badge_affiche()])
				print("UI badge n=%s = non_lues=%d (notifs_saut, après l'arrivée de la fiche)" % [hud.texte_badge_affiche(), e.non_lues()])
			print("UI saut anime=%s gel=%.2f badge_pause=%s vitesse=%d saut=%s trafic=%.2f bouton=%s mois=%s" % ["oui" if ville.get("anime") else "non", float(ville.get("gel")),
				"oui" if hud.badge_pause.visible and hud.badge_pause.text == "EN PAUSE" else "non", Partie.vitesse, "oui" if Partie.saut_actif else "non",
				float(ville.get("facteur_trafic")), hud.etat_courrier(), Dates.texte(e.ab_courant())])
			if etape == "notifs_saut":
				_notifs_compactes(hud)
			elif etape in ["badge_non_lus", "historique_nouveau"]:
				await sc.attendre_que(func() -> bool: return e.non_lues() >= 3 or not Partie.saut_actif, 6.0)
				jeu.demander_saut()   # nouvel appui : le saut s'arrête, la vitesse d'avant revient
				Partie.changer_vitesse(0)
				await sc.delai(0.6)
				print("UI badge n=%s = non_lues=%d (saut arrêté : %s, vitesse %d)" % [hud.texte_badge_affiche(), e.non_lues(), "oui" if not Partie.saut_actif else "non", Partie.vitesse])
				if etape == "historique_nouveau":
					jeu.ouvrir_historique("")
					await sc.delai(1.2)
					var nouveaux := modales.courant.find_children("Nouveau", "Label", true, false).size() if modales.ouverte() else 0
					var pastilles := modales.courant.find_children("Nouveautes", "Control", true, false).size() if modales.ouverte() else 0
					print("UI historique_nouveau etiquettes=%d pastilles=%d non_lues=%d" % [nouveaux, pastilles, e.non_lues()])
		"courrier_inactif":
			jeu.ouvrir_banque("", -2.0)
			await sc.delai(1.2)
			print("UI courrier inactif bouton=%s modale=%s" % [hud.etat_courrier(), modales.genre_courant])
		"courrier_bulle":
			Partie.changer_vitesse(0)
			await sc.delai(0.3)
			hud.montrer_bulle_courrier()   # forcée (comme --bulle-courrier) : jamais lue ni écrite en capture
			await sc.delai(0.8)
			var b := hud.find_child("BulleCourrier", true, false) as Control
			print("UI bulle visible=%s dans_libre=%s" % ["oui" if b != null and b.is_visible_in_tree() else "non",
				"oui" if b != null and hud.rect_libre().grow(1.0).encloses(b.get_global_rect()) else "non"])
	var r := hud.b_courrier.get_global_rect()
	var echelle := sc.get_viewport().get_final_transform().get_scale().x
	print("UI courrier etat=%s taille=%dx%d px libelle=%s dans_barre=%s" % [hud.etat_courrier(), roundi(r.size.x * echelle), roundi(r.size.y * echelle),
		"oui" if (hud.b_courrier.get_node("Contenu").get_child(1) as Control).visible else "non",
		"oui" if hud.barre.get_global_rect().grow(1.0).encloses(r) else "non"])
	_mesurer(etape, hud)


## Notifications compactes du saut : une ligne chacune, dans le rectangle libre (CA-I5).
func _notifs_compactes(hud: Hud) -> void:
	var libre := hud.rect_libre()
	var n := 0
	var une_ligne := true
	var dedans := true
	for c in hud.notifs.get_children():
		if not c.has_meta("compacte") or (c as Control).is_queued_for_deletion():
			continue
		n += 1
		var p := c as Control
		if p.size.y > 78.0:
			une_ligne = false
		if not libre.grow(1.0).encloses(p.get_global_rect()):
			dedans = false
	print("UI notifs compactes=%d une_ligne=%s dans_libre=%s badge=%s non_lues=%d" % [n, "oui" if une_ligne else "non", "oui" if dedans else "non", hud.texte_badge_affiche(), Partie.etat.non_lues()])


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


## C3 (passage 2) : toute la rue balayée par pas de 30 px d'art, panneau ouvert (PC) : aucune étiquette ni
## flèche chevauchée, toutes dans le rectangle libre, et pour maison / banque flèche ⇔ porte invisible.
## Captures : cadrage de pieces_glisse (maison presque entière au bord gauche, image « _glisse »), puis
## celui de pieces_or (entre les deux portes ; au téléphone, banque entière), image finale.
func _balayage(jeu: Node) -> void:
	sc.partir_de_la_rue("etiquettes_balayage")
	var hud: Hud = jeu.hud
	var ville: Node2D = jeu.ville
	await sc.delai(1.0)
	hud.basculer_panneau(not Ecran.compact())
	await sc.delai(0.4)
	var b: Vector2 = ville.call("bornes_rue")
	var decalage: float = ville.call("_cx_pour", 0.0)
	var n := 0
	var chev := 0
	var hors := 0
	var incoh := 0
	var cx := b.x
	while cx <= b.y + 29.0:
		ville.call("centrer_sur", minf(cx, b.y) - decalage, 0.0)
		hud.placer_etiquettes()
		n += 1
		var m := _mesure_etiquettes(hud, ville)
		chev += m[0]
		hors += m[1]
		incoh += m[2]
		if m[0] + m[1] + m[2] > 0 and chev + hors + incoh <= 6:
			print("UI etiquettes ecart cx=%.0f chevauchements=%d hors_libre=%d incoherences=%d" % [ville.call("position_camera"), m[0], m[1], m[2]])
		cx += 30.0
	print("UI etiquettes balayage positions=%d chevauchements=%d hors_libre=%d incoherences=%d" % [n, chev, hors, incoh])
	var maison: Node2D = ville.get("maison")
	var banque: Node2D = ville.get("banque")
	var milieu: float = (maison.position.x + maison.call("porte").get_center().x + banque.position.x + banque.call("porte").get_center().x) / 2.0
	for cadrage: Array in [["glisse", milieu - 150.0], ["milieu", milieu]]:
		ville.call("centrer_sur", float(cadrage[1]), 0.0)
		hud.placer_etiquettes()
		await sc.delai(0.6)
		var m2 := _mesure_etiquettes(hud, ville)
		print("UI etiquettes cadrage=%s chevauchements=%d hors_libre=%d incoherences=%d fleches=%s" % [cadrage[0], m2[0], m2[1], m2[2],
			str(["maison", "media", "banque"].map(func(id: String) -> String: return "%s:%s" % [id, str(hud.etiquettes[id].get_meta("fleche", "")) if str(hud.etiquettes[id].get_meta("fleche", "")) != "" else "non"]))])
		if cadrage[0] == "glisse":
			await RenderingServer.frame_post_draw
			var chemin := ScenariosCapture.option("capture").replace(".png", "_glisse.png")
			if chemin.is_relative_path():
				chemin = ProjectSettings.globalize_path("res://").path_join(chemin)
			sc.get_viewport().get_texture().get_image().save_png(chemin)


## C7 (passage 2) : écart forcé de + 198 F à − 4 F (roulement de 0,6 s), vérifié à chaque image : le signe du
## chiffre affiché, la couleur et la flèche de la pastille vont ensemble. La capture montre l'état final (− 4 F).
func _pastille_signe(jeu: Node) -> void:
	sc.partir_de_la_rue("pastille_signe")
	var hud: Hud = jeu.hud
	var a := Partie.etat.ab_courant()
	await sc.delai(1.0)
	hud.rouler_ecart(Produits.f(-4.0), Produits.f(198.0), a, 0.0, false)
	await sc.get_tree().process_frame
	var images := 0
	var incoherences := 0
	var signes := {}
	hud.rouler_ecart(Produits.f(198.0), Produits.f(-4.0), a, 0.6)
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 900:
		await sc.get_tree().process_frame
		images += 1
		signes[hud.l_ecart.text.left(1)] = true
		if not hud.pastille_coherente():
			incoherences += 1
	print("UI pastille signe images=%d incoherences=%d textes_vus=%s final=« %s »" % [images, incoherences, str(signes.keys()), hud.l_ecart.text])


## [chevauchements, hors du rectangle libre, incohérences flèche / porte] des étiquettes à l'instant.
func _mesure_etiquettes(hud: Hud, ville: Node2D) -> Array:
	var libre := hud.rect_libre()
	var rects: Array = []
	var chev := 0
	var hors := 0
	var incoh := 0
	for id: String in ["maison", "media", "banque"]:
		var p: Control = hud.etiquettes[id]
		var r := Rect2(p.position, p.size)
		if not libre.grow(1.0).encloses(r):
			hors += 1
		for q: Rect2 in rects:
			if r.grow(4.0).intersects(q):
				chev += 1
		rects.append(r)
		if id != "media":
			var fleche := str(p.get_meta("fleche", "")) != ""
			var porte_cachee: bool = ville.call("porte_ecran", id) == Vector2(-1, -1)
			if fleche != porte_cachee:
				incoh += 1
	return [chev, hors, incoh]


# =====================================================================
# Bulle et pictos d'humeur (lot 03, I4, CA-I4)
# =====================================================================

## Une bulle « Sylvie est ravie » ancrée sur Sylvie (ville.point_sylvie, 03-V) ou à défaut sur la porte de la
## maison ; une bulle ancrée hors champ (cachée) ; une bulle trop haute pour tenir au-dessus de son ancre
## (pointe vers le haut, texte coupé en 2 lignes) ; les 3 pictos d'humeur à ×3 et agrandis à ×6.
func _bulle(jeu: Node) -> void:
	sc.partir_de_la_rue("bulle")
	var ville: Node2D = jeu.ville
	var hud: Hud = jeu.hud
	Partie.changer_vitesse(0)
	await sc.delai(1.5)
	var sylvie := ville.has_method("point_sylvie")
	var ancre := func() -> Vector2: return ville.call("point_sylvie") if ville.has_method("point_sylvie") else ville.call("porte_ecran", "maison")
	var calque: Node = Juice.calque_effets
	var b1 := Bulle.montrer(calque, "Sylvie est ravie", ancre, 60.0, "humeur_contente")
	var b2 := Bulle.montrer(calque, "Ancre hors champ : cachée", func() -> Vector2: return Vector2(-1, -1), 60.0)
	var libre := hud.rect_libre()
	var a3 := (libre.position + Vector2(libre.size.x * 0.75, 30.0)).round()
	var b3 := Bulle.montrer(calque, "Une bulle trop près du haut passe sous son ancre, et un texte trop long tient sur deux lignes au plus, coupé proprement à la fin.", func() -> Vector2: return a3, 60.0)
	# Pictos d'humeur : ×3 (taille du jeu) et ×6 (pour les relire)
	var planche := CadresPixel.panneau("panneau")
	planche.name = "Pictos"
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 18)
	planche.add_child(hb)
	for nom: String in ["humeur_contente", "humeur_neutre", "humeur_fachee"]:
		var v := VBoxContainer.new()
		v.alignment = BoxContainer.ALIGNMENT_CENTER
		var ligne := HBoxContainer.new()
		ligne.add_theme_constant_override("separation", 12)
		var i3 := CadresPixel.icone(nom)
		i3.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ligne.add_child(i3)
		ligne.add_child(CadresPixel.icone(nom, {}, 6))
		v.add_child(ligne)
		var l := Style.label(nom.trim_prefix("humeur_").replace("fachee", "fâchée"), 20, Style.ui(), Style.TEXTE)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(l)
		hb.add_child(v)
	calque.add_child(planche)
	await sc.get_tree().process_frame
	planche.position = ((Vector2(libre.position.x + 24.0, libre.end.y - planche.get_combined_minimum_size().y - 24.0)) / 3.0).round() * 3.0
	await sc.delai(0.8)
	# Contrôles
	var bornes := libre.grow(1.0)
	var a1: Vector2 = ancre.call()
	var bout1 := b1.bout_pointe()
	var bout3 := b3.bout_pointe()
	var dans := bornes.encloses(b1.rect_total()) and bornes.encloses(b3.rect_total())
	var vise1 := absf(bout1.x - a1.x) <= 12.0 and (a1.y - bout1.y) >= 0.0 and (a1.y - bout1.y) <= 9.0
	var vise3 := absf(bout3.x - a3.x) <= 12.0 and (bout3.y - a3.y) >= 0.0 and (bout3.y - a3.y) <= 9.0
	var lignes3 := b3.texte_label.text.count("\n") + 1
	print("UI bulle ancre=%s a=%s bout=%s pointe=%s vise=%s dans_libre=%s" % ["point_sylvie" if sylvie else "porte_maison", a1, bout1, "bas" if b1.pointe_vers_bas else "haut", "oui" if vise1 else "non", "oui" if dans else "non"])
	print("UI bulle_haute a=%s bout=%s pointe=%s vise=%s lignes=%d texte=« %s »" % [a3, bout3, "bas" if b3.pointe_vers_bas else "haut", "oui" if vise3 else "non", lignes3, b3.texte_label.text.replace("\n", " / ")])
	print("UI bulle_cachee cachee_hors_champ=%s" % ("oui" if not b2.visible else "non"))
	print("UI bulle souris=%s (mouse_filter IGNORE partout)" % ("ignore" if [b1, b3].all(func(b: Bulle) -> bool: return b.find_children("*", "Control", true, false).all(func(c: Control) -> bool: return c.mouse_filter == Control.MOUSE_FILTER_IGNORE) and b.mouse_filter == Control.MOUSE_FILTER_IGNORE) else "non"))
	if not vise1 or not vise3 or not dans or b2.visible or b3.pointe_vers_bas or lignes3 > 2:
		print("UI bulle incoherences=1")
	_mesurer("bulle", b1)
	_mesurer("bulle_haute", b3)
	_mesurer("pictos", planche)
	print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d" % [_pix_min, _atk_min, _chiffres_pixelify])


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
			"source_maison", "source_banque", "source_media", "piece", "calendrier", "chevron_gauche", "chevron_droite",
			"bulle_pointe", "humeur_contente", "humeur_neutre", "humeur_fachee"]:
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
	var tailles := modales.courant.find_children("*", "Control", true, false).filter(func(c: Node) -> bool: return c is CarteProduit).map(func(c: Node) -> int: return int(c.get("taille_min_dessinee")))
	print("UI tuiles taille_min=%d (cartes %d ; m10 : aucun texte de tuile sous 20 px)" % [tailles.min() if not tailles.is_empty() else 0, tailles.size()])
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
	print("UI fleches_texte=%d (« → » affichés en texte ; 0 depuis F1-L)" % _fleches)


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
	if texte.contains("→"):
		_fleches += 1
		print("UI fleche_en_texte « %s »" % texte.left(40).replace("\n", " "))
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
	# C4 : barre haute en pause puis pendant un saut (le saut est arrêté avant la capture)
	var e := Partie.etat
	var format := "%dx%d%s" % [sc.get_window().size.x, sc.get_window().size.y, " tel" if Ecran.telephone_simule else ""]
	Partie.changer_vitesse(0)
	await sc.delai(0.3)
	print("UI barre format=%s etat=pause %s" % [format, hud.etat_barre()])
	StrategieTest.jouer_mois(e, true)
	if not e.modale.is_empty():
		e.resolution_auto()
	jeu.demander_saut()
	await sc.delai(0.4)
	print("UI barre format=%s etat=%s %s" % [format, "saut" if Partie.saut_actif else "SAUT_IMPOSSIBLE", hud.etat_barre()])
	if Partie.saut_actif:
		jeu.demander_saut()
	Partie.changer_vitesse(0)
	await sc.delai(0.4)


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
