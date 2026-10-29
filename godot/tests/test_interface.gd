extends Node
## Test de fumée de l'interface (lot 01), sans écran : vérifie le contrat logique ↔ affichage.
## Lancer : Godot_console.exe --headless --path godot res://tests/test_interface.tscn  (ou godot\outils\tests.ps1)
## a) La scène principale s'instancie et affiche l'écran titre, sans toucher à la sauvegarde du joueur.
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
		# Accès interne à PanneauBanque, toléré au lot 01 ; à remplacer par des accesseurs publics au lot 02 (T15).
		# Champ introuvable (renommé ?) : la vérification échoue avec un message clair, sans erreur de script.
		var droite: Control = pb.get("_droite")
		if droite == null:
			ok = false
			vus.append("PanneauBanque : champ interne _droite introuvable (renommé ?), voir T15")
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
		# Accès interne à PanneauBanque, toléré au lot 01 ; à remplacer par des accesseurs publics au lot 02 (T15).
		var b_ok: Variant = pb.get("_b_ok")
		var droite_ordre: Control = pb.get("_droite")
		if b_ok == null or droite_ordre == null:
			ok = false
			vus.append("PanneauBanque : champ interne %s introuvable (renommé ?), voir T15" % ("_b_ok" if b_ok == null else "_droite"))
			pb.fermer_demande.emit()
			break
		ordre_ok = ordre_ok and is_instance_valid(b_ok) and droite_ordre.is_ancestor_of(b_ok)
		pb.fermer_demande.emit()
		var r2: Array = _recu.pop_back() if not _recu.is_empty() else []
		if not (fiche_ok and auto_ok and ordre_ok and r1 == ["banque", "fermer"] and r2 == ["banque", "fermer"]):
			ok = false
			vus.append("%s KO (fiche %s, chaque mois %s, ordre %s)" % [pid, fiche_ok, auto_ok, ordre_ok])
	return {"mois": Dates.texte_court(e.ab_courant()), "produits": vus.filter(func(x: String) -> bool: return not x.contains(" ")).size(), "ok": ok, "detail": vus}


## Historique : chaque filtre, puis 5 entrées relues comme principal._relire_historique.
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
