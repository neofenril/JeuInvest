extends RefCounted
## Étapes de capture et contrôles de l'interface pixel (lot PX2, lignes « UI ») :
## - planche_cadres : tous les cadres 9-patch et les icônes sur un fond uni ; chaque bloc T × T est uniforme ;
## - cibles : parcours des écrans (titre, rue, carte, journal, courrier, relevé, fin, info, confirmation,
##   menu, historique, fenêtre Banque) : cibles tactiles, textes qui débordent, plus petite taille Pixelify ;
## - hud : bouton HISTORIQUE (taille en px physiques, jamais recouvert, panneau ouvert et fermé) ;
## - polices_jeu : planche des polices du jeu (accents français, tnum d'Atkinson).

const ETAPES := ["planche_cadres", "cibles", "hud", "polices_jeu", "etiquettes_bord", "etiquettes_aller", "etiquettes_banque", "etiquettes_gazette",
	"courrier_repos", "courrier_saut", "courrier_saut_pause", "courrier_inactif", "courrier_bulle", "notifs_saut", "badge_non_lus", "historique_nouveau",
	"etiquettes_balayage", "pastille_signe", "bulle",
	"carte", "carte_refus", "carte_conclusion", "carte_jumeaux", "carte_relue", "bulle_humeur", "etiquette_humeur",
	"mon_foyer", "mon_foyer_eteint", "banque_fermee",
	"projet_choix", "projet_conclusion", "projet_jour_j", "projet_confirmation", "projet_jour_j_conclusion", "etiquette_projet", "foyer_projet", "banque_guichet",
	"rue_bloc", "rue_pastille", "rue_eteinte", "rue_notifs", "historique_rue", "krach_jours", "krach_sans_jours"]
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
		"carte", "carte_refus", "carte_conclusion", "carte_jumeaux", "carte_relue":
			await _carte(etape, jeu)
		"bulle_humeur", "etiquette_humeur":
			await _humeur(etape, jeu)
		"mon_foyer", "mon_foyer_eteint":
			await _mon_foyer(etape, jeu)
		"banque_fermee":
			await _banque_fermee(jeu)
		"projet_choix", "projet_conclusion", "projet_jour_j", "projet_confirmation", "projet_jour_j_conclusion", "etiquette_projet", "foyer_projet", "banque_guichet":
			await _projet(etape, jeu)
		"rue_bloc", "rue_pastille", "rue_eteinte":
			await _rue(etape, jeu)
		"rue_notifs":
			await _rue_notifs(jeu)
		"historique_rue":
			await _historique_rue(jeu)
		"krach_jours", "krach_sans_jours":
			await _krach_jours(etape, jeu)
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
	var decalage: float = ville.call("cx_pour", 0.0)
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
# Carte de dilemme (lot 04, 03-I2 : I1, CA-I2)
# =====================================================================

## Nouvelle partie de capture (graine fixe) avec les cartes allumées, dans la rue, temps arrêté.
func partie_cartes(jeu: Node) -> void:
	var cfg := Donnees.config_demo(-1)
	cfg["cartes"] = true
	jeu.nouvelle_partie(cfg)
	Partie.etat.resolution_auto()   # carte du Livret A
	jeu.demarrer_direct(0)


## Avance (joueur actif, sans animation) jusqu'à la carte « id » ("" : la première) ; false si elle n'arrive pas.
func jusqu_a_carte(id := "", politique := "epargner") -> bool:
	var e := Partie.etat
	StrategieTest.politique_cartes = politique
	var garde := 0
	var ok := false
	while e.fin == "" and garde < 200:
		garde += 1
		if e.modale.get("kind", "") == "carte" and (id == "" or str(e.modale.get("id", "")) == id):
			ok = true
			break
		StrategieTest.jouer_mois(e, true)
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	sc.rafraichir_apres_saut()
	return ok


## Ce que fait la séquence de la ville (contrat §4.3) : carte, choix, résolution, conclusion.
func jouer_carte(jeu: Node, choix_id: String) -> Dictionary:
	var modales: Modales = jeu.modales
	var porte: Vector2 = jeu.ville.call("porte_ecran", "maison")
	modales.carte(Partie.etat.contenu_modale(), porte)
	await sc.attendre_que(func() -> bool: return modales.etat_carte().phase == "attente", 5.0)
	var r := {}
	var attente := func(_g: String, id: String) -> void:
		r.merge(Partie.resoudre_modale(id))
	modales.choix_fait.connect(attente, CONNECT_ONE_SHOT)
	modales.etat_carte().choisir(choix_id)
	if not r.is_empty():
		await modales.conclure_carte(r, porte)
	return r


func _carte(etape: String, jeu: Node) -> void:
	var modales: Modales = jeu.modales
	partie_cartes(jeu)
	var e := Partie.etat
	if etape == "carte_jumeaux":
		e.forcer_naissance(true)   # moteur seul (sans le courrier animé du faire-part)
		e.resolution_auto()
	var voulue := "C04" if etape == "carte_jumeaux" else "C01"
	var ok := jusqu_a_carte(voulue)
	print("UI carte_etape %s carte=%s ok=%s mois=%s" % [etape, str(e.modale.get("id", "")), "oui" if ok else "non", Dates.texte(e.ab_courant())])
	if not ok:
		return
	if etape == "carte_refus":
		# Disponible ramené à 5 000 F : le Club Med (9 000 F) n'est plus payable, le camping l'est
		e.joueur.livret = 0.0
		e.joueur.cc = Produits.f(5000.0)
		jeu.hud.maj(e, false)
	var porte: Vector2 = jeu.ville.call("porte_ecran", "maison")
	var c := e.contenu_modale()
	match etape:
		"carte", "carte_refus", "carte_jumeaux":
			modales.carte(c, porte)
			await sc.attendre_que(func() -> bool: return modales.etat_carte().phase == "attente", 5.0)
			await sc.delai(0.4)
			var mc := modales.etat_carte()
			if etape == "carte_refus":
				var b: Button = mc.boutons.get("a")
				var ouverte_avant: bool = e.modale.get("kind", "") == "carte"
				# Toucher (clic simulé) puis touche 1 sur le choix désactivé : sans effet
				await sc.clic_dehors(sc.position_fenetre(b))
				await sc.touche(KEY_1)
				await sc.delai(0.2)
				print("UI carte refus=%s (touchers comptés %d, modale %s, phase %s, desactive=%s)" % ["ignore" if ouverte_avant and e.modale.get("kind", "") == "carte" and mc.phase == "attente" else "ACCEPTE",
					mc.refus, str(e.modale.get("id", "")), mc.phase, str(c["choix"][0].get("desactive", false))])
			# Échap et clic extérieur : sans effet
			await sc.touche(KEY_ESCAPE)
			await sc.clic_dehors()
			await sc.delai(0.4)
			print("UI carte echap_clic=%s (Échap et clic extérieur sans effet)" % ("ignores" if modales.genre_courant == "carte" else "FERMENT incoherences=1"))
			print("UI carte titre=« %s » choix=%s disponible=« %s »" % [str(c.get("titre", "")), ", ".join(PackedStringArray(mc.ordre)), (modales.courant.find_child("Disponible", true, false) as Label).text])
			_mesurer(etape, modales.courant)
			print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d" % [_pix_min, _atk_min, _chiffres_pixelify])
		"carte_conclusion":
			modales.carte(c, porte)
			await sc.attendre_que(func() -> bool: return modales.etat_carte().phase == "attente", 5.0)
			var r := {}
			var attente := func(_g: String, id: String) -> void:
				r.merge(Partie.resoudre_modale(id))
			modales.choix_fait.connect(attente, CONNECT_ONE_SHOT)
			e.foyer["humeur"] = 1   # le choix « a » (+1) rend Sylvie contente : notification « humeur » → bulle après le rangement
			await sc.touche(KEY_1)
			if r.is_empty():
				print("UI carte conclusion=absente (choix refusé)")
				return
			modales.conclure_carte(r, porte)
			await sc.delai(1.0)
			var lq := modales.courant.find_child("Consequence", true, false) as Label if modales.courant != null else null
			print("UI carte consequence=« %s » = r=« %s » egal=%s" % [lq.text if lq != null else "?", str(r.get("consequence", "")), "oui" if lq != null and lq.text == str(r.get("consequence", "")) else "non"])
			_mesurer(etape, modales.courant)
			print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d" % [_pix_min, _atk_min, _chiffres_pixelify])
			await RenderingServer.frame_post_draw
			var nom_png := "res://captures/l4_carte_conclusion_vue%s.png" % ("_tel" if Ecran.compact() else "")
			sc.get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(nom_png))
			# La bulle d'humeur née de cette carte n'apparaît qu'après le rangement (CA-I3)
			var avant: Bulle = jeu.derniere_bulle if is_instance_valid(jeu.derniere_bulle) else null
			await sc.attendre_que(func() -> bool: return not modales.carte_en_cours, 8.0)
			await sc.delai(0.3)
			var apres: Bulle = jeu.derniere_bulle if is_instance_valid(jeu.derniere_bulle) else null
			print("UI bulle apres_carte=%s texte=« %s »" % ["oui" if apres != null and apres != avant else "non", apres.texte_label.text if apres != null else ""])
		"carte_relue":
			await jouer_carte(jeu, "a")
			await sc.delai(0.3)
			var i := e.historique.size() - 1
			while i >= 0 and str(e.historique[i]["genre"]) != "carte":
				i -= 1
			modales.relire_historique(e, i)
			await sc.delai(0.8)
			var lc := modales.courant.find_child("ChoixPris", true, false) as Label if modales.courant != null else null
			print("UI carte_relue choix=« %s »" % (lc.text if lc != null else "?"))
			_mesurer(etape, modales.courant)


# =====================================================================
# Projets (lot 05, 04-I : P1 à P5 ; contenus fabriqués sur le contrat lot_04 §4.2)
# =====================================================================

static func _f(francs: float) -> float:
	return Produits.f(francs)


## Contenu fabriqué de l'étape « choix » (P1, mars 1984). long : « sous » de plus de 2 lignes sur la 3e option (cas P2C).
static func fabriquer_choix(long := false) -> Dictionary:
	var sous3 := "Apport comptant, la vieille 4L en reprise"
	if long:
		sous3 = "Un PEL ouvert en 1984 verse chaque année une prime d'État et un taux fixe : l'apport vient de ce plan, qu'il faut garder au moins quatre ans."
	return {"kind": "projet", "etape": "choix", "source": "maison", "date": "MARS 1984", "ab": Dates.lire("1984-03"), "id": "P1",
		"titre": "Un projet pour 1986", "texte": "Sylvie et vous voulez vous offrir quelque chose d'ici avril 1986. Lequel ?",
		"choix": [
			{"id": "P1A", "titre": "Le salon et la chaîne hi-fi", "montant": _f(12000.0), "echeance_txt": "avril 1986", "icone": "salon", "sous": "Canapé, fauteuils et une vraie chaîne"},
			{"id": "P1B", "titre": "La Grèce pour les 30 ans de Sylvie", "montant": _f(16000.0), "echeance_txt": "avril 1986", "icone": "grece", "sous": "Deux semaines dans les Cyclades, à deux"},
			{"id": "P1C", "titre": "La Super 5 neuve", "montant": _f(30000.0), "echeance_txt": "avril 1986", "icone": "auto", "sous": sous3}]}


static func _vente_sicav() -> Dictionary:
	return {"id": "sicav", "nom": "SICAV Avenir", "vendu": _f(4145.0), "net": _f(4100.0), "frais": _f(0.0), "impot": _f(45.0), "penalite": 0.0,
		"texte_penalite": "Impôt sur la plus-value : 45 F.", "ecart_verse": _f(-300.0), "texte_ecart": "SICAV : 4 100 F, soit 300 F de moins que vos versements."}


static func _vente_pel() -> Dictionary:
	return {"id": "pel", "nom": "Plan d'épargne-logement", "vendu": _f(6250.0), "net": _f(5100.0), "frais": 0.0, "impot": 0.0, "penalite": _f(1150.0),
		"texte_penalite": "Prime d'État perdue : 1 150 F. Le PEL est clos avant 4 ans : seuls les intérêts au taux réduit sont versés.", "ecart_verse": _f(900.0),
		"texte_ecart": "PEL : 5 100 F, soit 900 F de plus que vos versements."}


## Les 3 cas du jour J (docs/24 §1.2) : "a" disponible suffisant, "b" manque couvert par les ventes, "c" rien ne suffit.
static func fabriquer_jour_j(cas: String) -> Dictionary:
	var c := {"kind": "projet", "etape": "echeance", "source": "maison", "date": "AVRIL 1986", "ab": Dates.lire("1986-04"), "id": "P1C",
		"titre": "Le jour J : La Super 5 neuve", "texte": "C'est le moment : La Super 5 neuve, 30 000 F.", "montant": _f(30000.0), "icone": "auto"}
	var realiser := {"id": "realiser", "titre": "Réaliser", "desactive": false, "sous": ""}
	var vendre := {"id": "realiser_en_vendant", "titre": "Réaliser en vendant", "desactive": false, "sous": ""}
	var reporter := {"id": "reporter", "titre": "Reporter de 4 mois", "desactive": false, "sous": "Nouvelle date : août 1986"}
	var renoncer := {"id": "renoncer", "titre": "Renoncer", "desactive": false, "sous": "Le projet est abandonné"}
	match cas:
		"a":
			c.merge({"disponible": _f(35000.0), "manque": 0.0, "ventes": [], "apres_ventes": _f(35000.0)})
			realiser["sous"] = "Le compte et le Livret A suffisent"
			vendre["desactive"] = true
			vendre["sous"] = "Rien à vendre : tout est disponible"
		"b":
			c.merge({"disponible": _f(21400.0), "manque": _f(8600.0), "ventes": [_vente_sicav(), _vente_pel()], "apres_ventes": _f(30600.0)})
			realiser["desactive"] = true
			realiser["sous"] = "Il manque 8 600 F sur le compte et le Livret A"
			vendre["sous"] = "Il faut vendre pour 8 600 F"
		_:
			c.merge({"disponible": _f(12000.0), "manque": _f(18000.0), "ventes": [_vente_sicav()], "apres_ventes": _f(16100.0)})
			realiser["desactive"] = true
			realiser["sous"] = "Il manque 18 000 F sur le compte et le Livret A"
			vendre["desactive"] = true
			vendre["sous"] = "Même en vendant, il manque 13 900 F"
	c["choix"] = [realiser, vendre, reporter, renoncer]
	return c


static func fabriquer_projet_en_cours() -> Dictionary:
	return {"id": "P1C", "nom": "La Super 5 neuve", "icone": "auto", "montant": _f(30000.0), "m_echeance": 0, "echeance_txt": "avril 1986", "mois_restants": 14,
		"report_utilise": false, "reportable": true, "disponible": _f(21400.0), "revendable": _f(4100.0), "atteint": false}


static func fabriquer_projets_passes() -> Array:
	return [{"id": "P1A", "nom": "Le salon et la chaîne hi-fi", "icone": "salon", "montant": _f(12000.0), "statut": "realise", "m": 0, "ab": Dates.lire("1986-04")},
		{"id": "P2B", "nom": "La Grèce pour les 30 ans de Sylvie", "icone": "grece", "montant": _f(16000.0), "statut": "realise_apres_report", "m": 0, "ab": Dates.lire("1987-08")},
		{"id": "P2C", "nom": "Le petit T3", "icone": "", "montant": _f(60000.0), "statut": "abandonne", "m": 0, "ab": Dates.lire("1988-02")}]


func _projet(etape: String, jeu: Node) -> void:
	var modales: Modales = jeu.modales
	var hud: Hud = jeu.hud
	var cas := ScenariosCapture.option("cas")
	if cas == "":
		cas = "b"
	partie_cartes(jeu)
	var e := Partie.etat
	if etape in ["foyer_projet", "etiquette_projet", "banque_guichet"]:
		jusqu_a_carte("C04")
		while not e.modale.is_empty():
			e.resolution_auto()
		sc.rafraichir_apres_saut()
	var porte: Vector2 = jeu.ville.call("porte_ecran", "maison")
	match etape:
		"projet_choix", "projet_conclusion":
			var c := fabriquer_choix(ScenariosCapture.option("long") == "oui")
			modales.projet(c, porte)
			await sc.attendre_que(func() -> bool: return modales.etat_projet().phase == "attente", 5.0)
			await sc.delai(0.3)
			var mp := modales.etat_projet()
			var recu := {}
			var coup := func(g: String, id: String) -> void: recu["id"] = id; recu["g"] = g
			modales.choix_fait.connect(coup)
			await sc.touche(KEY_ESCAPE)
			await sc.clic_dehors()
			await sc.delai(0.3)
			print("UI projet echap_clic=%s (ni Échap ni clic extérieur)" % ("ignores" if modales.genre_courant == "projet" and recu.is_empty() else "FERMENT incoherences=1"))
			print("UI projet choix options=%d = c=%d egal=%s ids=%s" % [mp.ordre.size(), (c["choix"] as Array).size(), "oui" if mp.ordre.size() == 3 else "non incoherences=1", ", ".join(PackedStringArray(mp.ordre))])
			var lignes_c: Array = []
			for id: String in mp.ordre:
				var b: Button = mp.boutons[id]
				lignes_c.append("%s | %s | %s" % [(b.find_child("TitreChoix", true, false) as Label).text, (b.find_child("Montant", true, false) as Label).text, (b.find_child("Echeance", true, false) as Label).text])
			for l in lignes_c:
				print("UI projet option « %s »" % l)
			await sc.touche(KEY_2)
			print("UI projet touche_2=%s" % str(recu.get("id", "AUCUN")))
			modales.choix_fait.disconnect(coup)
			if etape == "projet_conclusion":
				modales.conclure_projet({"choix": "P1B", "kind": "projet", "etape": "choix", "montant": _f(16000.0), "consequence": "C'est décidé : la Grèce, pour avril 1986."}, porte)
				await sc.delai(1.0)
			_mesurer(etape, modales.courant)
			print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d" % [_pix_min, _atk_min, _chiffres_pixelify])
		"projet_jour_j", "projet_confirmation", "projet_jour_j_conclusion":
			var c := fabriquer_jour_j(cas)
			modales.projet(c, porte)
			await sc.attendre_que(func() -> bool: return modales.etat_projet().phase == "attente", 5.0)
			await sc.delai(0.3)
			var mp := modales.etat_projet()
			var recu := {}
			var coup := func(g: String, id: String) -> void: recu["id"] = id
			modales.choix_fait.connect(coup)
			for id: String in mp.ordre:
				var ch: Dictionary = mp.choix[id]
				if bool(ch.get("desactive", false)):
					var avant := mp.refus
					mp.choisir(id)
					print("UI projet refus=%s (%s désactivé, raison « %s »)" % ["ignore" if mp.refus == avant + 1 and recu.is_empty() else "ACCEPTE incoherences=1", id, str(ch.get("sous", ""))])
			print("UI projet jour_j cas=%s boutons=%s bandeau=%s" % [cas, ", ".join(PackedStringArray(mp.ordre)),
				", ".join(PackedStringArray(modales.courant.find_children("Valeur", "Label", true, false).map(func(l: Node) -> String: return (l as Label).text)))])
			if etape == "projet_confirmation":
				mp.choisir("realiser_en_vendant")
				await sc.delai(0.4)
				var noms: Array = modales.courant.find_children("NomVente", "Label", true, false).map(func(l: Node) -> String: return (l as Label).text)
				var attendu: Array = []
				for i in (c["ventes"] as Array).size():
					attendu.append("%d  %s" % [i + 1, str(c["ventes"][i]["nom"])])
				var tot := modales.courant.find_child("TotalVentes", true, false) as Label
				print("UI projet confirmation ventes=%s = plan=%s egal=%s total=%s emis_avant_confirmer=%s" % [str(noms), str(attendu), "oui" if noms == attendu else "non incoherences=1",
					tot.text if tot != null else "?", "OUI incoherences=1" if not recu.is_empty() else "non"])
				await sc.touche(KEY_ESCAPE)
				print("UI projet echap_confirmation=%s" % ("retour" if not mp.en_confirmation and modales.genre_courant == "projet" else "AUTRE incoherences=1"))
				mp.choisir("realiser_en_vendant")
				await sc.delai(0.3)
			elif etape == "projet_jour_j_conclusion":
				mp.choisir("renoncer")
				modales.conclure_projet({"choix": "renoncer", "kind": "projet", "etape": "echeance", "montant": 0.0, "consequence": "Projet abandonné.", "ventes": []}, porte)
				await sc.delai(0.8)
			modales.choix_fait.disconnect(coup)
			_mesurer(etape, modales.courant)
			print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d" % [_pix_min, _atk_min, _chiffres_pixelify])
		"etiquette_projet":
			var texte := hud.maj_projet(e, fabriquer_projet_en_cours())
			await sc.delai(0.6)
			hud.placer_etiquettes()
			await sc.delai(0.3)
			print("UI etiquette_projet texte=« %s » attendu=« %s » chevauchements=%d" % [texte, "%s / %s" % [Format.nombre(Format.en_devise(_f(21400.0), "F")), Format.entier(_f(30000.0), e.ab_courant())], hud.chevauchements_etiquettes()])
			var sans := hud.maj_projet(e, {"_aucun": true})
			print("UI etiquette_projet sans_projet_ligne=« %s »" % ("" if sans == "" else sans))
			hud.maj_projet(e, fabriquer_projet_en_cours())
			await sc.delai(0.3)
			print("UI etiquette_projet chevauchements_apres=%d" % hud.chevauchements_etiquettes())
			_mesurer(etape, hud)
		"foyer_projet":
			var fab := {"projet": fabriquer_projet_en_cours(), "passes": fabriquer_projets_passes()}
			hud.maj_projet(e, fabriquer_projet_en_cours())
			Partie.changer_vitesse(0)
			modales.foyer(e, porte, fab)
			await sc.attendre_que(func() -> bool: return modales.genre_courant == "info" and modales.courant != null, 5.0)
			await sc.delai(0.8)
			var mf := modales.etat_foyer()
			var lp: Array = mf.lignes_projet.map(func(l: Label) -> String: return l.text)
			var ls: Array = mf.lignes_passes.map(func(l: Label) -> String: return l.text)
			for l in lp:
				print("UI foyer projet « %s »" % l)
			for l in ls:
				print("UI foyer passe « %s »" % l)
			var attendu_p: Array = ModaleFoyer.textes_projet(fab["projet"], e.ab_courant())
			print("UI foyer projet_egal=%s (lignes %d, attendues %d)" % ["oui" if lp == attendu_p else "non incoherences=1", lp.size(), attendu_p.size()])
			_mesurer(etape, modales.courant)
			print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d" % [_pix_min, _atk_min, _chiffres_pixelify])
		"banque_guichet":
			# Le moteur 04-L fournit la ligne ; sans lui, une ligne fabriquée vérifie la mise en page
			jeu.ouvrir_banque("elf", -2.0)
			await sc.delai(1.0)
			var pb: PanneauBanque = modales.banque
			var ligne := pb.ligne_projet()
			var vue := modales.courant.find_child("LigneProjetGuichet", true, false) as Label
			print("UI guichet ligne=« %s » visible=%s (moteur : %s)" % [vue.text if vue != null else "?", str(vue.visible) if vue != null else "?", "04-L" if e.has_method("ligne_projet_guichet") else "absent"])
			if ligne == "":
				pb.ligne_fab = "Projet : la Super 5, avril 1986 (dans 14 mois) · 30 000 F"
				pb.call("_maj_carnet")
				await sc.delai(0.3)
			_mesurer(etape, modales.courant)
			pb.call("_afficher_ordre", "elf", "a", -1.0)
			await sc.delai(0.5)
			var lo := modales.courant.find_child("LigneProjetOrdre", true, false) as Label
			print("UI guichet ordre ligne=%s" % (("« %s »" % lo.text) if lo != null else "absente (téléphone ou pas de projet)"))
			print("UI guichet taille fenetre=%s min=%s ligne_en_tete=%s" % [str(pb.size), str(pb.get_combined_minimum_size()), str(pb._l_projet.visible)])
			_mesurer(etape + "_ordre", modales.courant)


# =====================================================================
# La rue (lot 06, 05-I : R1 à R7 ; contenus fabriqués conformes à lot_05 §4.3)
# =====================================================================

## classement_rue() fabriqué (patrimoines en francs ; Jean-Mi négatif après sa liquidation).
static func fabriquer_classement(negatif := true) -> Array:
	return [{"id": "livret", "nom": "Tata Livret", "initiale": "T", "patrimoine": 165300.0, "rang": 1, "vous": false, "reference": true},
		{"id": "vous", "nom": "Vous", "initiale": "G", "patrimoine": 160749.0, "rang": 2, "vous": true, "reference": false},
		{"id": "matelas", "nom": "Tonton Matelas", "initiale": "M", "patrimoine": 139800.0, "rang": 3, "vous": false, "reference": false},
		{"id": "jeanmi", "nom": "Jean-Mi", "initiale": "J", "patrimoine": -12400.0 if negatif else 98000.0, "rang": 4, "vous": false, "reference": false}]


static func fabriquer_jeanmi() -> Dictionary:
	return {"etape": "liquide", "etape_texte": "Liquidé : la bourse l'a ruiné", "patrimoine": -12400.0, "dette": 26041.0, "regle": "Achète à crédit"}


func _rue(etape: String, jeu: Node) -> void:
	var hud: Hud = jeu.hud
	sc.partir_de_la_rue(etape)
	var e := Partie.etat
	Partie.changer_vitesse(0)
	await sc.delai(0.6)
	if etape == "rue_eteinte":
		hud.maj_rue_eteinte(e)
		await sc.delai(0.4)
		print("UI rue eteinte bloc=%s rang=%s languette_texte=« %s »" % ["cache" if not hud.bloc_rue.visible else "VISIBLE incoherences=1", "cache" if not hud._languette_rang.visible else "VISIBLE incoherences=1", hud.languette.text.replace("\n", " ")])
		_mesurer(etape, hud)
		return
	var cl := fabriquer_classement()
	var rang := hud.maj_rue(e, cl, fabriquer_jeanmi())
	hud.basculer_panneau(etape == "rue_bloc" or not hud.compact)
	await sc.delai(0.8)
	var l := hud.bloc_rue.lignes_texte
	var signe := false
	for x: Dictionary in l:
		if bool(x["negatif"]):
			signe = str(x["montant"]).begins_with(Format.MOINS)
	var ordre_ok := l.size() == 4 and l.map(func(x: Dictionary) -> String: return str(x["id"])) == cl.map(func(x: Dictionary) -> String: return str(x["id"]))
	print("UI rue rang=%d lignes=%d negatif_signe=%s panneau_coupe=%s ordre=%s trois_colonnes=%s" % [rang, l.size(), "oui" if signe else "non", "oui incoherences=1" if hud.panneau_coupe() and hud.panneau.visible else "non", "oui" if ordre_ok else "non incoherences=1", str(hud.panneau_a_trois_colonnes())])
	for x: Dictionary in l:
		print("UI rue ligne rang=%s %s montant=%s vous=%s%s" % [BlocRue.rang_texte(int(x["rang"])), x["nom"], x["montant"], str(x["vous"]), (" etape=« %s »" % x["etape"]) if str(x["etape"]) != "" else ""])
	if etape == "rue_pastille":
		print("UI rue languette rang=« %s » sous=« %s » visible=%s" % [(hud._languette_rang.get_child(1) as Label).text, (hud._languette_rang.get_child(2) as Label).text, str(hud.languette.is_visible_in_tree())])
		_mesurer(etape, hud)
		hud.languette.pressed.emit()
		await sc.delai(0.5)
		print("UI rue languette_ouvre_panneau=%s" % ("oui" if hud.panneau.visible else "non incoherences=1"))
		hud.basculer_panneau(false)
		await sc.delai(0.3)
	else:
		_mesurer(etape, hud)


static func fabriquer_voisin(id: String) -> Dictionary:
	match id:
		"court":
			return {"type": "voisin", "source": "rue", "cls": "neutre", "id": "V02", "qui": "matelas", "titre": "Tonton Matelas", "cle": false, "long": false,
				"texte": "Une banque ? Et si elle saute ? Moi, c'est sous le matelas."}
		"long":
			return {"type": "voisin", "source": "rue", "cls": "neutre", "id": "V01", "qui": "lopez", "titre": "Mme Lopez", "cle": true, "long": true,
				"texte": "Vous connaissez vos voisins ?",
				"texte_long": "Vous connaissez vos voisins ? Tata Livret met tout sur son Livret A. Tonton Matelas garde tout sur son compte. Jean-Mi, vendeur chez Peugeot, attend le bon tuyau. Mêmes revenus, mêmes dépenses que vous : seule change la façon de placer."}
		"persistant":
			return {"type": "voisin", "source": "rue", "cls": "neutre", "id": "V07", "qui": "jeanmi", "titre": "Jean-Mi", "cle": true, "long": false, "persistant": true,
				"texte": "Tuyau du café : Peugeot ne peut que monter. J'ai tout mis, et même plus !"}
		"rang":
			return {"type": "rang", "source": "rue", "cls": "gain", "titre": "Dans la rue", "texte": "Vous repassez devant Jean-Mi.", "rang": 2}
		_:
			return {"type": "kiosque", "source": "media", "cls": "neutre", "titre": "LA GAZETTE", "texte": "Les Bleus sacrés champions d'Europe", "id": "K01"}


func _rue_notifs(jeu: Node) -> void:
	var hud: Hud = jeu.hud
	var modales: Modales = jeu.modales
	sc.partir_de_la_rue("rue_notifs")
	var e := Partie.etat
	Partie.changer_vitesse(0)
	await sc.delai(0.5)
	var a := e.ab_courant()
	var vus: Array = []
	for k in ["court", "long", "rang"]:
		var n := fabriquer_voisin(k)
		hud.notifier(n, a)
		vus.append(n)
		await sc.delai(0.5)
	# Les plus anciennes partent quand la place manque : chaque toast affiché porte le texte COURT de sa notification
	var textes: Array = hud.notifs.find_children("TexteNotif", "Label", true, false).map(func(l: Node) -> String: return (l as Label).text)
	var attendus: Array = vus.map(func(n: Dictionary) -> String: return str(n["texte"]))
	var inclus := not textes.is_empty()
	for t: String in textes:
		inclus = inclus and attendus.has(t)
	var long_affiche := textes.has(str(fabriquer_voisin("long")["texte"]))
	print("UI rue_notifs toasts=%d textes_courts=%s lire=%s" % [textes.size(), "egaux" if inclus else "DIFFERENTS incoherences=1", ("oui" if hud.notifs.find_child("Lire", true, false) != null else "NON incoherences=1") if long_affiche else "sans objet (toast long parti)"])
	hud.notifier(fabriquer_voisin("persistant"), a)
	await sc.delai(0.5)
	print("UI rue_notifs source=« %s » liseré_bleu=%s" % [Hud.NOMS_SOURCES["rue"], "oui" if Style.NOMS_PALETTE_SOURCES["rue"] == "bleu_vif" else "non"])
	# La notification persistante reste affichée, sans pause : on laisse passer plus de 3 mois de temps de jeu (accéléré)
	Partie.changer_vitesse(3)
	var t_attente := 0.0
	while e.ab_courant() - a < 3 and t_attente < 14.0 and e.modale.is_empty():
		await sc.delai(0.25)
		t_attente += 0.25
	var reste := false
	for p: Control in hud._liste_notifs:
		if is_instance_valid(p) and p.find_child("IndicationPersistante", true, false) != null:
			reste = true
	print("UI rue_notifs persistante=%s mois_ecoules=%d pause=%s" % ["reste" if reste else "PARTIE incoherences=1", e.ab_courant() - a, "oui incoherences=1" if Partie.vitesse == 0 else "non"])
	Partie.changer_vitesse(0)
	# Relecture longue : texte ENTIER
	var nl := fabriquer_voisin("long")
	jeu.toucher_notif(nl)
	await sc.attendre_que(func() -> bool: return modales.genre_courant == "info" and modales.courant != null, 4.0)
	await sc.delai(0.6)
	var lt := modales.courant.find_child("TexteLecture", true, false) as Label
	print("UI rue_notifs relecture_longue=%s (%d mots) == texte_long egal=%s" % ["lue" if lt != null else "ABSENTE", str(lt.text if lt != null else "").split(" ", false).size(), "oui" if lt != null and lt.text == str(nl["texte_long"]) else "non incoherences=1"])
	_mesurer("rue_notifs_relecture", modales.courant)
	print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d" % [_pix_min, _atk_min, _chiffres_pixelify])
	await RenderingServer.frame_post_draw
	sc.get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://captures/l6_rue_relecture%s.png" % ("_tel" if Ecran.compact() else "")))
	modales.fermer("fermer")
	await sc.delai(0.4)
	hud.notifier(fabriquer_voisin("kiosque"), a)
	await sc.delai(0.8)


## Partie de capture (graine fixe) avec cartes, projets et rue allumés, dans la rue, temps arrêté.
func partie_tout_allume(jeu: Node) -> void:
	var cfg := Donnees.config_demo(-1)
	cfg["cartes"] = true
	cfg["projets"] = true
	cfg["rue"] = true
	jeu.nouvelle_partie(cfg)
	Partie.etat.resolution_auto()
	jeu.demarrer_direct(0)


## Le Lundi noir (CA-U5) : la modale du krach du vrai moteur (rue allumée) avec le tableau des 7 jours ; sans la rue : modale inchangée.
func _krach_jours(etape: String, jeu: Node) -> void:
	var modales: Modales = jeu.modales
	if etape == "krach_sans_jours":
		sc.partir_de_la_rue(etape)
	else:
		partie_tout_allume(jeu)
	var e := Partie.etat
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.aller_a_modale(e, "p1e6", true)
	sc.rafraichir_apres_saut()
	var c := e.contenu_modale()
	var jours: Array = c.get("jours", [])
	modales.donnees_demo["_vente_totale"] = e.devis_vente_totale(e.joueur)
	modales.donnees_demo["_ab"] = e.ab_courant()
	modales.journal(c, Vector2(960, 400), false)
	await sc.attendre_que(func() -> bool: return modales.genre_courant == "journal" and modales.courant != null, 5.0)
	await sc.delai(2.0)
	var mj: ModaleJournal = modales._journal
	var attendu: Array = jours.map(func(j: Dictionary) -> String: return "%s|%s|%s" % [ModaleJournal.texte_jour(str(j["jour"])), ModaleJournal.texte_indice(float(j["indice"])), ModaleJournal.texte_variation(float(j.get("variation", 0.0)), j == jours[0])])
	var lus: Array = mj.lignes_jours.map(func(l: Array) -> String: return "|".join(PackedStringArray(l)))
	var vue := sc.get_viewport().get_visible_rect()
	var choix := modales.courant.find_child("Choix", true, false) as Control
	var visibles := choix != null and vue.grow(1.0).encloses(choix.get_global_rect())
	for b in choix.find_children("*", "Button", true, false) if choix != null else []:
		visibles = visibles and vue.grow(1.0).encloses((b as Button).get_global_rect())
	if jours.is_empty():
		print("UI krach_jours sans_jours tableau=%s choix_visibles=%s (modale inchangée)" % ["ABSENT" if modales.courant.find_child("TableauJours", true, false) == null else "PRESENT incoherences=1", "oui" if visibles else "non incoherences=1"])
	else:
		print("UI krach_jours cases=%d choix_visibles=%s lignes=%d == jours=%d egal=%s cumul=%s certitude=« %s »" % [mj.cases, "oui" if visibles else "non incoherences=1", lus.size(), jours.size(), "oui" if lus == attendu else "non incoherences=1",
			ModaleJournal.texte_cumul(jours), ModaleJournal.phrase_certitude(jours)])
		for l in lus:
			print("UI krach_jours ligne « %s »" % l)
	_mesurer(etape, modales.courant)
	print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d" % [_pix_min, _atk_min, _chiffres_pixelify])


## Historique : onglet LA RUE avec les vraies notifications de la rue (partie menée jusqu'à fin 1986), relecture de la plus longue.
func _historique_rue(jeu: Node) -> void:
	var modales: Modales = jeu.modales
	var cfg := Donnees.config_demo(-1)
	cfg["cartes"] = true
	cfg["projets"] = true
	cfg["rue"] = true
	jeu.nouvelle_partie(cfg)
	Partie.etat.resolution_auto()
	jeu.demarrer_direct(0)
	var e := Partie.etat
	StrategieTest.politique_cartes = "epargner"
	var garde := 0
	while e.fin == "" and e.ab_courant() < Dates.lire("1987-01") and garde < 100:
		garde += 1
		StrategieTest.jouer_mois(e, true)
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	sc.rafraichir_apres_saut()
	var rue := e.historique_recent("rue")
	var autres := 0
	for h: Dictionary in rue:
		if str(h["source"]) != "rue":
			autres += 1
	print("UI historique_rue entrees=%d autres_sources=%d non_lues=%d genres=%s" % [rue.size(), autres, e.non_lues("rue"), str(rue.map(func(h: Dictionary) -> String: return str(h["genre"])).slice(0, 4))])
	jeu.ouvrir_historique("rue")
	await sc.attendre_que(func() -> bool: return modales.genre_courant == "historique", 5.0)
	await sc.delai(1.0)
	var filtre := modales.courant.find_child("Filtre_rue", true, false) as Button
	print("UI historique_rue onglet=%s actif=%s libelle=« %s »" % ["present" if filtre != null else "ABSENT incoherences=1", str(filtre.button_pressed) if filtre != null else "?", filtre.text if filtre != null else ""])
	_mesurer("historique_rue", modales.courant)
	print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d" % [_pix_min, _atk_min, _chiffres_pixelify])


## « Mon foyer » (lot 04, I3, CA-I4) : après 3 cartes jouées (politique alternée), humeur au choix
## (--humeur=contente|neutre|fachee). mon_foyer_eteint : partie sans cartes (bloc du foyer seul).
func _mon_foyer(etape: String, jeu: Node) -> void:
	var modales: Modales = jeu.modales
	var e: EtatPartie
	if etape == "mon_foyer_eteint":
		sc.partir_de_la_rue(etape)
		e = Partie.etat
		sc.aller_a(Dates.lire("1986-06"), true)
	else:
		partie_cartes(jeu)
		e = Partie.etat
		var garde := 0
		StrategieTest.politique_cartes = "alterner"
		while e.fin == "" and e.cartes_jouees().size() < 4 and garde < 200:
			garde += 1
			StrategieTest.jouer_mois(e, true)
			while not e.modale.is_empty():
				e.resolution_auto()
			e.avancer()
		while not e.modale.is_empty():
			e.resolution_auto()
		var voulu: int = {"contente": 2, "neutre": 0, "fachee": -2}.get(ScenariosCapture.option("humeur"), 0)
		if ScenariosCapture.option("humeur") != "":
			e.foyer["humeur"] = voulu
		sc.rafraichir_apres_saut()
	Partie.changer_vitesse(0)
	await sc.delai(0.8)
	jeu.toucher_batiment("maison")
	await sc.attendre_que(func() -> bool: return modales.genre_courant == "info" and modales.courant != null, 5.0)
	await sc.delai(0.8)
	var mf := modales.etat_foyer()
	var jouees: Array = e.cartes_jouees()
	var attendues: Array = []
	for k in mini(ModaleFoyer.NB_CARTES, jouees.size()):
		attendues.append(ModaleFoyer.texte_carte(jouees[jouees.size() - 1 - k], e.ab_de(int(jouees[jouees.size() - 1 - k].get("m", e.m)))))
	var lues: Array = mf.lignes_cartes.map(func(l: Label) -> String: return l.text)
	print("UI foyer cartes=%d = attendues=%d egal=%s" % [lues.size(), attendues.size(), "oui" if lues == attendues else "non incoherences=1"])
	print("UI foyer phrase=« %s » = humeur_phrase=« %s » egal=%s" % [mf.l_phrase.text if mf.l_phrase != null else "-", e.humeur_phrase(), "oui" if (mf.l_phrase == null and not e.cartes_actives()) or (mf.l_phrase != null and mf.l_phrase.text == e.humeur_phrase() + ".") else "non incoherences=1"])
	print("UI foyer cause=« %s » = derniere_cause=« %s »" % [mf.l_cause.text if mf.l_cause != null else "-", e.derniere_cause_humeur()])
	for l in lues:
		print("UI foyer carte « %s »" % l)
	var nombres := 0
	for l in modales.courant.find_children("*", "Label", true, false):
		var t := (l as Label).text
		if t.begins_with("Sylvie") or t.begins_with("«"):
			nombres += 1 if RegEx.create_from_string("[0-9]").search(t) != null else 0
	print("UI foyer chiffres_dans_humeur=%d (attendu 0 : jamais de nombre ni de jauge)" % nombres)
	_mesurer(etape, modales.courant)
	print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d" % [_pix_min, _atk_min, _chiffres_pixelify])
	# Fermeture : clic extérieur, Échap, [×]
	var ferme := {}
	var coup := func(_g: String, id: String) -> void: ferme["id"] = id
	modales.choix_fait.connect(coup)
	await sc.clic_dehors()
	await sc.delai(0.5)
	var r1 := str(ferme.get("id", "AUCUNE"))
	jeu.toucher_batiment("maison")
	await sc.delai(1.0)
	await sc.touche(KEY_ESCAPE)
	await sc.delai(0.5)
	var r2 := str(ferme.get("id", "AUCUNE"))
	jeu.toucher_batiment("maison")
	await sc.delai(1.0)
	(modales.courant.find_child("Fermer", true, false) as Button).pressed.emit()
	await sc.delai(0.5)
	print("UI foyer fermeture clic=%s echap=%s croix=%s" % [r1, r2, str(ferme.get("id", "AUCUNE"))])
	modales.choix_fait.disconnect(coup)
	# Réouvrir pour l'image finale
	jeu.toucher_batiment("maison")
	await sc.delai(1.0)


## Banque fermée pendant une carte (lot 04, I4, CA-I5).
func _banque_fermee(jeu: Node) -> void:
	var hud: Hud = jeu.hud
	var modales: Modales = jeu.modales
	partie_cartes(jeu)
	var e := Partie.etat
	if not jusqu_a_carte("C01"):
		print("UI banque_fermee carte=absente incoherences=1")
		return
	await sc.delai(0.5)
	var fermee_carte: bool = jeu.banque_fermee()
	hud.maj_banque_fermee(fermee_carte)
	var phrase_if := Hud.PHRASE_BANQUE_FERMEE
	# Le moteur refuse un ordre pendant la carte (04-L) : même phrase ; sans 04-L, l'ordre passe (écart signalé)
	var refus: Dictionary = e.acheter(e.joueur, "elf", Produits.f(1000.0)) if e.has_method("ordres_bloques") else {}
	var msg := str(refus.get("msg", "(moteur sans ordres_bloques)"))
	print("UI banque_fermee grise=%s phrase_visible=%s phrase=« %s » msg_moteur=« %s » egale=%s" % [str(hud.b_marche.disabled), str(hud.l_banque_fermee.visible), phrase_if, msg,
		"oui" if msg == phrase_if else ("sans objet (04-L absent)" if refus.is_empty() else "NON incoherences=1")])
	jeu.ouvrir_banque("", -2.0)
	await sc.delai(0.3)
	print("UI banque_fermee ouverte=%s (touche ou bâtiment : sans effet)" % ("OUI incoherences=1" if modales.genre_courant == "banque" else "non"))
	# Après la carte, la BANQUE se rouvre
	e.resolution_auto()
	hud.maj_banque_fermee(jeu.banque_fermee())
	print("UI banque_fermee apres_carte grise=%s" % str(hud.b_marche.disabled))
	# Image : carte de nouveau en attente
	if jusqu_a_carte("C03"):
		hud.maj_banque_fermee(jeu.banque_fermee())
		await sc.delai(0.6)


## Humeur de Sylvie (lot 04, I2, CA-I3) : bulle née d'une carte (après le rangement), picto de l'étiquette.
## etiquette_humeur : les 3 états (option --humeur=contente|neutre|fachee pour l'image, défaut fâchée).
func _humeur(etape: String, jeu: Node) -> void:
	var hud: Hud = jeu.hud
	partie_cartes(jeu)
	var e := Partie.etat
	if not jusqu_a_carte("C01"):
		print("UI humeur carte=absente incoherences=1")
		return
	if etape == "etiquette_humeur":
		var ecarts := 0
		for h: int in [2, 0, -2]:
			e.foyer["humeur"] = h
			var vu := hud.maj_humeur(e)
			if vu != e.humeur_visible():
				ecarts += 1
			print("UI etiquette humeur=%d picto=%d visible=%d" % [h, vu, e.humeur_visible()])
		var voulu: int = {"contente": 2, "neutre": 0, "fachee": -2}.get(ScenariosCapture.option("humeur"), -2)
		e.foyer["humeur"] = voulu
		hud.maj_humeur(e)
		e.foyer["actif"] = false
		var eteint := hud.maj_humeur(e)
		e.foyer["actif"] = true
		hud.maj_humeur(e)
		print("UI etiquette eteintes picto=%d (attendu -1) incoherences=%d" % [eteint, ecarts + (0 if eteint == -1 else 1)])
		await sc.delai(1.0)
		_mesurer(etape, hud)
		return
	# Bulle : humeur à +1 (neutre) ; le Club Med (+1) la rend contente → notification « humeur »
	e.foyer["humeur"] = 1
	hud.maj_humeur(e)
	jeu.derniere_bulle = null
	var modales: Modales = jeu.modales
	var porte: Vector2 = jeu.ville.call("porte_ecran", "maison")
	modales.carte(e.contenu_modale(), porte)
	await sc.attendre_que(func() -> bool: return modales.etat_carte().phase == "attente", 5.0)
	var r := {}
	var attente := func(_g: String, id: String) -> void:
		r.merge(Partie.resoudre_modale(id))
	modales.choix_fait.connect(attente, CONNECT_ONE_SHOT)
	modales.etat_carte().choisir("a")
	await sc.get_tree().process_frame
	var pendant := is_instance_valid(jeu.derniere_bulle)
	await modales.conclure_carte(r, porte)
	await sc.get_tree().process_frame
	await sc.get_tree().process_frame
	var b: Bulle = jeu.derniere_bulle if is_instance_valid(jeu.derniere_bulle) else null
	var empilee := hud.notifs.find_children("*", "Label", true, false).any(func(l: Node) -> bool: return (l as Label).text == (b.texte_label.text if b != null else "§"))
	print("UI bulle apres_carte=%s (pendant la carte : %s) texte=« %s » notif_empilee=%s" % ["oui" if b != null and not pendant else "non", "oui" if pendant else "non",
		b.texte_label.text if b != null else "", "OUI incoherences=1" if empilee else "aucune"])
	await sc.delai(0.6)
	if b != null:
		var libre := hud.rect_libre().grow(1.0)
		print("UI bulle_humeur ancre=%s dans_libre=%s duree=%.1f picto=%d humeur=%d" % ["point_sylvie" if jeu.ville.has_method("point_sylvie") else "porte_maison",
			"oui" if libre.encloses(b.rect_total()) else "non", b.duree, hud.maj_humeur(e), e.humeur_visible()])


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
			"bulle_pointe", "humeur_contente", "humeur_neutre", "humeur_fachee", "aimant",
			"portrait_sylvie_contente", "portrait_sylvie_neutre", "portrait_sylvie_fachee",
			"salon", "grece", "voiture", "club_med", "break", "maison", "source_rue"]:
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
