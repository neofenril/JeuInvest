extends Node
## Test de fumée de l'interface (lot 01), sans écran : vérifie le contrat logique ↔ affichage.
## Lancer : Godot_console.exe --headless --path godot res://tests/test_interface.tscn  (ou godot\outils\tests.ps1)
## a) La scène principale s'instancie et affiche l'écran titre, sans toucher à la sauvegarde du joueur.
## a bis) Lot 02 : bouton COURRIER (caché, repos, saut, inactif), touche N, arrêt du saut à l'ouverture d'une
##    fenêtre, badge des non-lus (= non_lues(), « 9+ », remis à zéro à la fermeture de l'historique).
## b) Hud, Modales et la fenêtre Banque affichent toute la démo (graine fixe), joueur actif puis passif
##    (StrategieTest) : chaque modale par la fonction que principal.gd utilise pour son genre, fermée par le choix
##    de la stratégie ; fenêtre Banque sur chaque produit détenu en décembre 1986 et juin 1988 ; historique avec
##    chaque filtre et 5 relectures ; relevé de décembre ; écran de fin.
## Toute erreur de script (champ renommé, fonction disparue…) est relevée par tests.ps1 dans la sortie.
## Aucun script du jeu n'est modifié ; seules des fonctions publiques (ou déjà appelées par principal.gd) sont utilisées.

const GRAINE := 7
const MOIS_BANQUE := ["1986-12", "1988-06"]

var _ko := 0
var _n := 0
var _chemin_test := ""
var hud: Hud
var modales: Modales
var _recu: Array = []


func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	_chemin_test = "user://test_interface_%d.sav" % OS.get_process_id()
	Partie.chemin_sauvegarde = _chemin_test   # avant toute instanciation : jamais la sauvegarde du joueur
	var empreinte_avant := FileAccess.get_sha256(Sauvegarde.CHEMIN)
	await _test_scene_principale(empreinte_avant)
	await _test_courrier()
	await _test_demo_complete(true)
	await _test_demo_complete(false)
	_verifier("sauvegarde du joueur (partie_en_cours.sav) intacte à la fin du test", FileAccess.get_sha256(Sauvegarde.CHEMIN) == empreinte_avant)
	Sauvegarde.effacer(_chemin_test)
	print("=== test_interface : %d vérifications, %s (%d ms) ===" % [_n, "OK" if _ko == 0 else "%d KO" % _ko, Time.get_ticks_msec() - t0])
	get_tree().quit(1 if _ko > 0 else 0)


# ---------------------------------------------------------------------
# a) Scène principale : écran titre
# ---------------------------------------------------------------------

func _test_scene_principale(empreinte_avant: String) -> void:
	var scene: Node = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	for i in 10:
		await get_tree().process_frame
	var bouton := ""
	for b: Button in scene.find_children("*", "Button", true, false):
		if b.is_visible_in_tree() and b.text in ["JOUER", "CONTINUER"]:
			bouton = b.text
	var hud_cache := true
	for n in scene.find_children("*", "Control", true, false):
		if n is Hud and (n as Control).is_visible_in_tree():
			hud_cache = false
	_verifier("scène principale : écran titre affiché (bouton JOUER visible, HUD caché, Partie prête)",
		bouton == "JOUER" and hud_cache and Partie.etat != null and Partie.etat.fin == "", "bouton « %s »" % bouton)
	_verifier("écran titre : aucune sauvegarde écrite (ni celle du joueur, ni celle du test)",
		FileAccess.get_sha256(Sauvegarde.CHEMIN) == empreinte_avant and not FileAccess.file_exists(_chemin_test) and Partie.chemin_sauvegarde == _chemin_test)
	scene.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	Juice.camera = null
	Juice.hud = null
	Juice.calque_effets = null
	_verifier("scène principale libérée proprement", not is_instance_valid(scene))


# ---------------------------------------------------------------------
# a bis) Bouton COURRIER, arrêts du saut, badge des non-lus (lot 02, CA-I1), dans la vraie scène
# ---------------------------------------------------------------------

func _test_courrier() -> void:
	var scene: Node = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await _images(5)
	scene.call("nouvelle_partie", Donnees.config_demo(GRAINE))   # A1 : jamais la graine aléatoire de principal._config()
	await _images(2)
	var h: Hud = scene.get("hud")
	var md: Modales = scene.get("modales")
	var e := Partie.etat
	_verifier("COURRIER : caché tant qu'aucune modale n'est résolue (carte du Livret A en attente)", h.etat_courrier() == "cache" and not h.b_courrier.visible, h.etat_courrier())
	e.resolution_auto()
	scene.call("demarrer_direct", 0)
	await _images(3)
	_verifier("COURRIER : visible au repos après la 1re modale résolue", h.etat_courrier() == "repos" and h.b_courrier.is_visible_in_tree(), h.etat_courrier())
	await _balayer_etiquettes(scene, h)
	await _touche(KEY_N)
	var par_n := Partie.saut_actif
	await _images(2)
	var etat_saut := h.etat_courrier()
	h.courrier_demande.emit()
	await _images(2)
	_verifier("COURRIER : la touche N lance le saut (état « saut »), un 2e appui (signal du bouton) l'arrête",
		par_n and etat_saut == "saut" and not Partie.saut_actif and h.etat_courrier() == "repos", "N %s, état %s, après %s" % [par_n, etat_saut, Partie.saut_actif])
	h.courrier_demande.emit()
	var lance := Partie.saut_actif
	scene.call("ouvrir_banque", "", -2.0)
	await _images(3)
	_verifier("COURRIER : ouvrir la Banque pendant un saut l'arrête ; bouton inactif fenêtre ouverte",
		lance and not Partie.saut_actif and h.etat_courrier() == "inactif" and md.genre_courant == "banque", "lancé %s, saut %s, état %s" % [lance, Partie.saut_actif, h.etat_courrier()])
	md.banque.fermer_demande.emit()
	await get_tree().create_timer(0.5).timeout
	md.confirmer("ESSAI", "Modale de contrôle.", "OUI", "NON")
	await _images(3)
	var inactif_modale := h.etat_courrier() == "inactif"
	h.courrier_demande.emit()
	_verifier("COURRIER : inactif avec une modale ouverte, sans effet au toucher", inactif_modale and not Partie.saut_actif)
	md.fermer("non")
	await get_tree().create_timer(0.4).timeout
	# Saut qui franchit des notifications connues, indépendantes de la vie : départ en janvier 1986 (joueur actif),
	# le saut franchit « Le Livret A baisse » (mai 1986) avant D07 (novembre 1986). Mois avancés à la main.
	StrategieTest.aller_a(e, Dates.lire("1986-01"), true)
	StrategieTest.jouer_mois(e, true)
	if not e.modale.is_empty():
		e.resolution_auto()
	h.maj(e, false)
	await _images(2)
	scene.call("demander_saut")
	var lance_1986 := Partie.saut_actif
	var franchis := []
	var garde := 0
	while Partie.saut_actif and garde < 12:
		Partie.avancer_un_mois()
		garde += 1
		for hh: Dictionary in e.historique_recent(""):
			if not bool(hh.get("lu", true)) and not (str(hh["titre"]) in franchis):
				franchis.append(str(hh["titre"]))
		if franchis.has("Le Livret A baisse"):
			break
	if Partie.saut_actif:
		scene.call("demander_saut")
	await _images(2)
	var n := e.non_lues()
	_verifier("badge : égal à non_lues() après un saut depuis janvier 1986 qui franchit « Le Livret A baisse » (%d non lue(s) : %s)" % [n, ", ".join(franchis)],
		lance_1986 and franchis.has("Le Livret A baisse") and n > 0 and h.texte_badge_affiche() == Hud.texte_badge(n), "« %s », %s" % [h.texte_badge_affiche(), Dates.texte(e.ab_courant())])
	await _vider_modale(e, md, scene)
	h.maj_badge(10)
	var neuf_plus := h.texte_badge_affiche()
	h.maj_badge(0)
	var absent := not h.badge_non_lus.visible
	h.maj_badge(e.non_lues())
	_verifier("badge : « 9+ » à 10, absent à 0", neuf_plus == "9+" and absent, neuf_plus)
	var avant_historique := e.non_lues()
	_verifier("précondition : non_lues() > 0 avant d'ouvrir l'historique (%d), badge affiché" % avant_historique,
		avant_historique > 0 and h.badge_non_lus.visible)
	scene.call("ouvrir_historique", "")
	await get_tree().create_timer(0.8).timeout
	var ouvert := md.genre_courant == "historique"
	md.fermer("fermer")
	await get_tree().create_timer(0.4).timeout
	_verifier("historique fermé : non_lues() == 0 et badge absent", ouvert and e.non_lues() == 0 and not h.badge_non_lus.visible, "ouvert %s, non lues %d" % [ouvert, e.non_lues()])
	StrategieTest.aller_a(e, Dates.lire("1988-12"), false)
	await _images(3)
	_verifier("COURRIER : inactif en décembre 1988 (%s)" % Dates.texte(e.ab_courant()), h.etat_courrier() == "inactif" and not Partie.saut_possible(), h.etat_courrier())
	Partie.sauvegarde_auto = false
	scene.queue_free()
	await _images(2)
	Juice.camera = null
	Juice.hud = null
	Juice.calque_effets = null


## C3 (passage 2) : toute la rue balayée (pas de 30 px d'art), panneau ouvert : aucune étiquette ni flèche
## chevauchée ou hors du rectangle libre, et pour maison / banque, flèche de bord ⇔ porte invisible (E1).
func _balayer_etiquettes(scene: Node, h: Hud) -> void:
	var ville: Node2D = scene.get("ville")
	h.basculer_panneau(true)
	await _images(2)
	var b: Vector2 = ville.call("bornes_rue")
	var decalage: float = ville.call("_cx_pour", 0.0)
	var n := 0
	var chev := 0
	var incoh := []
	var cx := b.x
	while cx <= b.y + 29.0:
		ville.call("centrer_sur", minf(cx, b.y) - decalage, 0.0)
		h.placer_etiquettes()
		n += 1
		chev += h.chevauchements_etiquettes()
		for id: String in ["maison", "banque"]:
			var fleche := str(h.etiquettes[id].get_meta("fleche", "")) != ""
			if fleche != (ville.call("porte_ecran", id) == Vector2(-1, -1)):
				incoh.append("%s à cx=%.0f" % [id, ville.call("position_camera")])
		cx += 30.0
	_verifier("étiquettes : rue balayée (%d positions, panneau ouvert) sans chevauchement ni sortie du rectangle libre" % n, n >= 10 and chev == 0, "%d" % chev)
	_verifier("étiquettes : flèche de bord de la maison et de la banque si et seulement si leur porte est invisible", incoh.is_empty(), str(incoh.slice(0, 4)))
	ville.call("revenir", 0.0)
	await _images(2)


## Modale arrivée pendant le saut (séquence de la ville puis carte) : fermée par le choix par défaut.
func _vider_modale(e: EtatPartie, md: Modales, scene: Node) -> void:
	var t0 := Time.get_ticks_msec()
	while not e.modale.is_empty() and Time.get_ticks_msec() - t0 < 15000:
		if md.ouverte() and md.genre_courant in ["appel", "journal", "courrier"] and md.courant.visible:
			await get_tree().create_timer(0.3).timeout
			var c := StrategieTest.choix_modale(e, false)
			if md.genre_courant == "journal":
				md.call("_on_choix_journal", c)
			else:
				md.fermer(c)
		await get_tree().process_frame
	t0 = Time.get_ticks_msec()
	while (bool(scene.get("sequences").get("occupe")) or md.ouverte()) and Time.get_ticks_msec() - t0 < 8000:
		await get_tree().process_frame
	Partie.changer_vitesse(0)


func _images(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _touche(code: Key) -> void:
	for appui in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = code
		ev.pressed = appui
		Input.parse_input_event(ev)
		await get_tree().process_frame


# ---------------------------------------------------------------------
# b) Démo complète affichée par le HUD, les modales et la fenêtre Banque
# ---------------------------------------------------------------------

func _test_demo_complete(actif: bool) -> void:
	var nom := "joueur actif" if actif else "joueur passif"
	var calque_hud := CanvasLayer.new()
	calque_hud.layer = 1
	add_child(calque_hud)
	hud = Hud.new()
	calque_hud.add_child(hud)
	var calque_effets := CanvasLayer.new()
	calque_effets.layer = 2
	add_child(calque_effets)
	var calque_modales := CanvasLayer.new()
	calque_modales.layer = 5
	add_child(calque_modales)
	modales = Modales.new()
	modales.donnees_demo = Donnees.charger("demo").duplicate(true)
	calque_modales.add_child(modales)
	modales.choix_fait.connect(func(g: String, id: String) -> void: _recu.append([g, id]))
	Juice.hud = calque_hud
	Juice.calque_effets = calque_effets
	await get_tree().process_frame
	hud.visible = true
	hud.afficher(true, false)

	Partie.nouvelle_partie(Donnees.config_demo(GRAINE))
	var e := Partie.etat
	var mois_hud := 0
	var vues := {}            # genre attendu -> nombre
	var ecarts_genre := []    # modales affichées sous un autre genre que prévu
	var ecarts_choix := []    # choix absent de la modale, ou mal transmis
	var banques := []         # résumés des visites de la fenêtre Banque
	var releve: Dictionary = {}
	var garde := 0
	while e.fin == "" and garde < 100:
		hud.maj(e, false)
		mois_hud += 1
		if not e.modale.is_empty():
			await _afficher_modale(e, actif, vues, ecarts_genre, ecarts_choix)
		else:
			StrategieTest.jouer_mois(e, actif)
		var a := e.ab_courant()
		if MOIS_BANQUE.any(func(d: String) -> bool: return Dates.lire(d) == a):
			banques.append(await _visiter_banque(e))
			if a == Dates.lire("1988-06"):
				await _verifier_historique(e, nom)
		if not e.modale.is_empty():
			e.resolution_auto()
		var res := e.avancer()
		for n: Dictionary in res.get("notifs", []):
			hud.notifier(n, e.ab_courant())
			if n.get("type", "") == "releve":
				releve = n
		garde += 1
	hud.maj(e, false)
	var af := e.ab_courant()
	var attendus := [Format.montant(e.joueur.cc, af), Format.montant(e.patrimoine(e.joueur), af), Format.entier(e.frais_payes(), af)]
	var affiches := [hud.l_cc.text, hud.l_patr.text, hud.l_frais.text]
	_verifier("%s : le HUD affiche les chiffres de l'état (compte, patrimoine, frais payés)" % nom, affiches == attendus, "%s / attendu %s" % [str(affiches), str(attendus)])
	_verifier("%s : démo jouée jusqu'au bout (décembre 1988, sans faillite), HUD mis à jour chaque mois (%d)" % [nom, mois_hud],
		e.fin == "fin" and e.ab_courant() == Dates.lire("1988-12") and mois_hud >= 60 and hud.l_cc.text != "", "%s, %s" % [e.fin, Dates.texte(e.ab_courant())])
	_verifier("%s : chaque modale affichée par la fonction de son genre (%s)" % [nom, str(vues)],
		ecarts_genre.is_empty() and int(vues.get("appel", 0)) >= 8 and int(vues.get("journal", 0)) >= 1 and int(vues.get("courrier", 0)) >= 1, str(ecarts_genre))
	_verifier("%s : chaque modale fermée par le choix de la stratégie, choix rangé dans l'historique" % nom, ecarts_choix.is_empty(), str(ecarts_choix))
	var n_produits := 0
	var banque_ok := banques.size() == 2
	for b: Dictionary in banques:
		n_produits += int(b["produits"])
		if not b["ok"]:
			banque_ok = false
	_verifier("%s : fenêtre Banque (fiche, « chaque mois », formulaire d'ordre) sur chaque produit détenu en déc. 1986 et juin 1988" % nom,
		banque_ok and (n_produits >= 8 if actif else n_produits >= 0), str(banques))
	if actif:
		var frais := float(releve.get("frais_total", 0.0))
		var releve_ok := false
		if frais > 0.0:
			modales.releve(releve, e.ab_courant())
			releve_ok = await _attendre_genre("info")
			_fermer("fermer")
		_verifier("%s : relevé de décembre affiché (frais payés depuis le début (cumul) : %s)" % [nom, Format.montant(frais, e.ab_courant())], releve_ok)
		# Lot 03, D6 (m9) : total = somme des valeurs affichées ; cas fabriqués dont les arrondis tombent mal
		for cas: Array in [[416.6, 41.6, 417, 42, 459], [100.0, 200.0, 100, 200, 300], [1234.4, 0.4, 1234, 0, 1234], [999.6, 0.6, 1000, 1, 1001]]:
			var nf := {"titre": "Relevé", "texte": "Relevé fabriqué (arrondis).", "frais_total": Produits.f(cas[0]), "manque": Produits.f(cas[1])}
			modales.releve(nf, e.ab_courant())
			var vu := await _attendre_genre("info")
			var lus := [_chiffres_case("Frais"), _chiffres_case("Manque"), _chiffres_case("Total")]
			_fermer("fermer")
			_verifier("%s : relevé %s F + %s F affiché %s (attendu %d + %d = %d, somme des affichés)" % [nom, cas[0], cas[1], lus, cas[2], cas[3], cas[4]],
				vu and lus == [cas[2], cas[3], cas[4]])
	var bilan := Bilan.calculer(e)
	modales.fin_demo(e)
	var fin_ok := await _attendre_genre("fin")
	_fermer("rejouer")
	_verifier("%s : écran de fin affiché, bilan calculé (%d rubriques)" % [nom, bilan.size()], fin_ok and not bilan.is_empty())
	# Nettoyage : le test suivant repart d'une interface neuve
	for i in 3:
		await get_tree().process_frame
	calque_hud.queue_free()
	calque_effets.queue_free()
	calque_modales.queue_free()
	Juice.hud = null
	Juice.calque_effets = null
	await get_tree().process_frame


## Affiche la modale en attente comme principal.gd (_on_modale → séquence du genre), la ferme par le choix de la
## stratégie, puis la stratégie la résout (même choix) et joue le mois.
func _afficher_modale(e: EtatPartie, actif: bool, vues: Dictionary, ecarts_genre: Array, ecarts_choix: Array) -> void:
	var c := e.contenu_modale()
	var choix := StrategieTest.choix_modale(e, actif)
	var pos := Vector2(960, 400)
	var genre := ""
	if c.get("kind", "") == "banquier":
		genre = "appel"
		modales.presentation(c, pos)
	elif c.get("kind", "") == "marche":
		genre = "journal"
		modales.donnees_demo["_vente_totale"] = e.devis_vente_totale(e.joueur)
		modales.donnees_demo["_ab"] = e.ab_courant()
		modales.journal(c, pos, c.get("gravite", "") == "majeure" and c.get("type", "") == "-")
	else:
		genre = "courrier"   # courrier de la vie, naissance comprise
		modales.courrier(c, pos, e)
	vues[genre] = int(vues.get(genre, 0)) + 1
	if not await _attendre_genre(genre):
		ecarts_genre.append("%s : « %s » affichée comme « %s »" % [Dates.texte_court(e.ab_courant()), str(c.get("titre", "")), modales.genre_courant])
	var ids: Array = c.get("choix", []).map(func(x: Dictionary) -> String: return str(x["id"]))
	if not (choix in ids):
		ecarts_choix.append("%s : choix « %s » absent de %s" % [str(c.get("titre", "")), choix, str(ids)])
	var r := _fermer(choix)
	if r != [genre, choix]:
		ecarts_choix.append("%s : choix_fait %s au lieu de %s" % [str(c.get("titre", "")), str(r), str([genre, choix])])
	var n_hist := e.historique.size()
	StrategieTest.jouer_mois(e, actif)
	if not e.modale.is_empty() or e.historique.size() != n_hist + 1 or str(e.historique[n_hist]["choix"]) != e.libelle_choix(c, choix):
		ecarts_choix.append("%s : historique « %s » au lieu de « %s »" % [str(c.get("titre", "")), str(e.historique[e.historique.size() - 1].get("choix", "")), e.libelle_choix(c, choix)])
	hud.maj(e, false)


## Fenêtre Banque sur chaque produit détenu : fiche, réglage « chaque mois », formulaire d'ordre.
func _visiter_banque(e: EtatPartie) -> Dictionary:
	var ok := true
	var vus := []
	for pid: String in Banquier.ordre_carnet():
		if not Banquier.detenu(e, pid):
			continue
		vus.append(pid)
		_recu.clear()
		modales.ouvrir_banque(e, pid, -2.0)
		var fiche_ok := await _attendre_genre("banque")
		var pb := modales.banque
		# Accesseurs publics de PanneauBanque (T15, lot PX2)
		var droite: Control = pb.zone_droite()
		if droite == null:
			ok = false
			vus.append("PanneauBanque.zone_droite() renvoie null")
			pb.fermer_demande.emit()
			break
		fiche_ok = fiche_ok and droite.get_child_count() > 0 and _textes(droite).size() >= 3
		pb.call("_afficher_automatique", pid)
		await get_tree().process_frame
		var auto_ok := droite.get_child_count() > 0 and _textes(droite).size() >= 2
		pb.fermer_demande.emit()
		var r1: Array = _recu.pop_back() if not _recu.is_empty() else []
		_recu.clear()
		modales.ouvrir_banque(e, pid, -1.0)
		var ordre_ok := await _attendre_genre("banque")
		pb = modales.banque
		# Accesseurs publics de PanneauBanque (T15, lot PX2)
		var b_ok: Button = pb.bouton_valider()
		var droite_ordre: Control = pb.zone_droite()
		if b_ok == null or droite_ordre == null:
			ok = false
			vus.append("PanneauBanque.%s renvoie null" % ("bouton_valider()" if b_ok == null else "zone_droite()"))
			pb.fermer_demande.emit()
			break
		ordre_ok = ordre_ok and is_instance_valid(b_ok) and droite_ordre.is_ancestor_of(b_ok)
		pb.fermer_demande.emit()
		var r2: Array = _recu.pop_back() if not _recu.is_empty() else []
		if not (fiche_ok and auto_ok and ordre_ok and r1 == ["banque", "fermer"] and r2 == ["banque", "fermer"]):
			ok = false
			vus.append("%s KO (fiche %s, chaque mois %s, ordre %s)" % [pid, fiche_ok, auto_ok, ordre_ok])
	return {"mois": Dates.texte_court(e.ab_courant()), "produits": vus.filter(func(x: String) -> bool: return not x.contains(" ")).size(), "ok": ok, "detail": vus}


## Historique : chaque filtre, puis 5 entrées relues comme Modales.relire_historique.
func _verifier_historique(e: EtatPartie, nom: String) -> void:
	var filtres_ok := true
	var detail := ""
	for f in ["", "maison", "banque", "media"]:
		modales.historique(e, f, 0)
		var ok := await _attendre_genre("historique")
		ok = ok and modales.historique_filtre == f
		detail += "%s : %d ; " % [f if f != "" else "tout", e.historique_recent(f).size()]
		if not ok:
			filtres_ok = false
		_fermer("fermer")
	_verifier("%s : historique ouvert avec chaque filtre (juin 1988)" % nom, filtres_ok, detail)
	# 5 entrées de genres variés : présentation, journal, courrier, relevé, notification
	var choisies := []
	var genres_pris := {}
	for h: Dictionary in e.historique_recent(""):
		var cle := str(h["genre"]) + ("_releve" if str(h["type"]) == "releve" else "")
		if not genres_pris.has(cle):
			genres_pris[cle] = true
			choisies.append(h)
	for h: Dictionary in e.historique_recent(""):
		if choisies.size() >= 5:
			break
		if not (h in choisies):
			choisies.append(h)
	choisies = choisies.slice(0, 5)
	var relues := 0
	for h: Dictionary in choisies:
		var a := e.ab_de(int(h["m"]))
		var c: Dictionary = h["contenu"]
		match str(h["genre"]):
			"appel":
				modales.presentation(c, Vector2(-1, -1), true, "HISTORIQUE · %s · VOTRE CHOIX : %s" % [Dates.texte(a).to_upper(), str(h["choix"]).to_upper()])
			"journal":
				modales.journal(c, Vector2(-1, -1), false, str(h["choix"]))
			"courrier":
				modales.courrier(c, Vector2(-1, -1), e, str(h["choix"]), a)
			_:
				if str(h["type"]) == "releve" and float(c.get("frais_total", 0.0)) > 0.0:
					modales.releve(c, a)
				else:
					modales.lecture_notification(h, a)
		if await _attendre_genre(modales.genre_courant) and modales.genre_courant in ["appel", "info"]:
			relues += 1
		_fermer("fermer")
	_verifier("%s : 5 entrées de l'historique relues en lecture seule (%s)" % [nom, str(genres_pris.keys())], relues == 5, "%d / 5" % relues)


## Attend que la modale soit posée et visible, comme un joueur qui ne peut toucher que ce qu'il voit (le courrier
## reste caché pendant le vol de l'enveloppe, 0,5 s) ; 2 s au plus. Vrai si elle est ouverte sous le genre attendu.
func _attendre_genre(genre: String) -> bool:
	var t0 := Time.get_ticks_msec()
	for i in 3:
		await get_tree().process_frame
	while Time.get_ticks_msec() - t0 < 2000 and not (modales.ouverte() and is_instance_valid(modales.courant) and modales.courant.visible):
		await get_tree().process_frame
	return modales.ouverte() and modales.genre_courant == genre and is_instance_valid(modales.courant) and modales.courant.visible


## Ferme la modale ouverte avec le choix id ; renvoie [genre, id] reçu par choix_fait (signal synchrone).
## Chiffres affichés dans la case « nom » de la fenêtre ouverte (grille des frais du relevé), -1 si absente.
func _chiffres_case(nom: String) -> int:
	if not is_instance_valid(modales.courant):
		return -1
	var l := modales.courant.find_child(nom, true, false) as Label
	if l == null:
		return -1
	var s := ""
	for ch in l.text:
		if ch >= "0" and ch <= "9":
			s += ch
	return int(s) if s != "" else -1


func _fermer(id: String) -> Array:
	_recu.clear()
	modales.fermer(id)
	return _recu.pop_back() if not _recu.is_empty() else []


func _textes(n: Node) -> Array:
	var out := []
	for c in n.find_children("*", "Label", true, false):
		if (c as Label).text.strip_edges() != "":
			out.append((c as Label).text)
	return out


func _verifier(nom: String, ok: bool, detail := "") -> void:
	_n += 1
	print(("OK  " if ok else "KO  ") + nom + ("  [" + detail + "]" if detail != "" else ""))
	if not ok:
		_ko += 1
