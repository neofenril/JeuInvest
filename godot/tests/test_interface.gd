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
const MOIS_BANQUE := ["1986-12", "1987-04", "1988-06"]   # lot 05 : avril 1987 = un projet est en cours (ligne du guichet)

var _ko := 0
var _n := 0
var _chemin_test := ""
var hud: Hud
var modales: Modales
var _recu: Array = []
var _ordres_refuses := 0       # lot 05 : refus d'ordres débiteurs constatés pendant une carte ou un projet
var _projets_choisis := 0
var _etiquettes_vues := 0
var _rue_mois := 0
var _krach_tableaux := 0
var _gazettes_vues := 0
var _guichets_vus := 0
var _ventes_conformes := 0
var _div_vus := {}        # lot 03 (I6) : « reçus » / « versé » -> nombre de fiches d'action vérifiées


func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	_chemin_test = "user://test_interface_%d.sav" % OS.get_process_id()
	Partie.chemin_sauvegarde = _chemin_test   # avant toute instanciation : jamais la sauvegarde du joueur
	Partie.chemin_records = "user://test_interface_records_%d.sav" % OS.get_process_id()   # ni ses records (lot 07)
	var empreinte_avant := FileAccess.get_sha256(Sauvegarde.CHEMIN)
	await _test_scene_principale(empreinte_avant)
	await _test_courrier()
	await _test_dix_ans()
	await _test_chapitre_2()
	await _test_enveloppes()
	await _test_demo_complete(true)
	await _test_demo_complete(false)
	await _test_demo_complete(true, true)    # lot 04 : toute la démo avec les cartes du foyer allumées
	await _test_demo_complete(false, true)
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
	# Lot 04-05 (D9, D11, CA-M9) : une nouvelle partie du joueur (hors mode capture) a les cartes et les projets allumés
	var cfg: Dictionary = scene.call("_config")
	_verifier("principal._config() hors capture : \"cartes\", \"projets\" et \"rue\" vrais", cfg.get("cartes", false) == true and cfg.get("projets", false) == true and cfg.get("rue", false) == true, str(cfg.keys()))
	# Lot 09-I (CA-I5) : la config du joueur porte le chapitre de départ et la fin bornée par la dernière année implémentée
	print("INTERFACE _config chapitre=%s fin=%s" % [cfg.get("chapitre", "?"), cfg.get("fin", "?")])
	_verifier("principal._config() : chapitre « 1984 » et fin = décembre de la dernière année ouverte (1993 avec le chapitre 1989)", str(cfg.get("chapitre", "")) == "1984" and str(cfg.get("fin", "")) == "%d-12" % Donnees.derniere_annee(), str(cfg.get("chapitre", "")) + " " + str(cfg.get("fin", "")))
	# Lot 08 : la pop-up de début s'ouvre à une nouvelle partie (JOUER, REJOUER), temps figé, pas à la reprise
	Reglages.intro_force = true
	scene.call("nouvelle_partie")
	scene.call("demarrer_direct", 0)
	var md: Modales = scene.get("modales")
	var ouv := false
	for i in 120:
		await get_tree().process_frame
		if md.genre_courant == "intro":
			ouv = true
			break
	_verifier("Intro : ouverte après une nouvelle partie / REJOUER, temps figé", ouv and Partie.bloquee)
	var ei := Partie.etat
	var txd := str(ModaleIntro.textes(ei)["blocs"][0]["texte"])
	_verifier("Intro : {depart} = depart_F.cc de chapitre.json (11 000 F), {salaire} = salaire de la partie", txd.contains(Format.montant(float(Donnees.infos_chapitre()["depart_F"]["cc"]) / Format.TAUX_EURO, ei.ab_courant())) and txd.contains(Format.montant(ei.salaire_base, ei.ab_courant())), txd)
	await _touche(KEY_ENTER)
	await get_tree().create_timer(0.6).timeout
	_verifier("Intro : COMMENCER (Entrée) ferme la fenêtre et rend le temps", md.genre_courant == "" and not Partie.bloquee)
	# Lot 09-I (CA-I3, CA-I5) : thème choisi par la date, signal de changement de chapitre branché sans erreur
	var vl: Node = scene.get("ville")
	_verifier("Thème : la ville est au thème de la date (« 1980 »)", vl.has_method("theme_actuel") and str(vl.call("theme_actuel")) == Donnees.theme_a(Partie.etat.ab_courant()) and str(vl.call("theme_actuel")) == "1980")
	scene.set("demo", {})
	Partie.chapitre_change.emit("1984", "1984")
	_verifier("chapitre_change : _on_chapitre_change rafraîchit les textes du chapitre et garde le thème", (scene.get("demo") as Dictionary).has("banquier") and str(vl.call("theme_actuel")) == "1980")
	scene.set("_reprise", true)
	scene.call("demarrer_direct", 0)
	await get_tree().create_timer(0.4).timeout
	_verifier("Intro : pas de pop-up à la reprise d'une partie", md.genre_courant != "intro")
	Reglages.intro_force = false
	Partie.sauvegarde_auto = false
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
	var decalage: float = ville.call("cx_pour", 0.0)
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


# ---------------------------------------------------------------------
# a ter) Lot 10b, étape 1 : frise et courbe sur 10 ans, carnet au-delà de 9 produits, noms lus dans les données
# ---------------------------------------------------------------------

func _test_dix_ans() -> void:
	var neuve := Frise.new()
	_verifier("Frise neuve : m_fin n'est plus à 0 avant le premier Hud.maj (M2 de 09-I)", neuve.m_fin < neuve.m_debut)
	neuve.free()
	_verifier("Années écrites (docs/40 §1.1.3) : toutes à 70 px par an et plus, les paires sous 70 px, 1 sur 5 sous 35 px ; débuts de chapitre toujours",
		Frise.annee_ecrite(1985, 185.0, false) and not Frise.annee_ecrite(1985, 60.0, false) and Frise.annee_ecrite(1986, 60.0, false)
		and not Frise.annee_ecrite(1986, 30.0, false) and Frise.annee_ecrite(1990, 30.0, false) and Frise.annee_ecrite(1989, 30.0, true))
	_verifier("Noms : banquier lu dans chapitre.json (« M. Lefranc », « M. LEFRANC »), krach 1987-10, chapitre de départ 1984",
		Noms.banquier() == "M. Lefranc" and Noms.banquier_brut() == "M. LEFRANC" and Noms.annee_krach() == 1987 and Noms.texte_mois_krach() == "octobre 1987" and Noms.annee_depart_chapitre() == 1984,
		"%s %s %d" % [Noms.banquier(), Noms.texte_mois_krach(), Noms.annee_depart_chapitre()])
	var scene: Node = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await _images(5)
	scene.call("nouvelle_partie", Donnees.config_demo(GRAINE))
	await _images(3)
	var h: Hud = scene.get("hud")
	var md: Modales = scene.get("modales")
	var e := Partie.etat
	e.resolution_auto()
	scene.call("demarrer_direct", 0)
	await _images(3)
	h.maj(e, false)
	_verifier("Frise : m_debut / m_fin posés par Hud.maj depuis la partie, aucune coupure pour un seul chapitre",
		h.frise.m_debut == e.m_depart and h.frise.m_fin == e.m_fin and h.frise.m_fin - h.frise.m_debut + 1 == 60 and h.frise.coupures.is_empty() and h.courbe.coupures.is_empty())
	# Carnet à 9 produits : grille 3 × 3 complète (silhouettes comprises), inchangée
	scene.call("ouvrir_banque", "", -2.0)
	await _images(3)
	var g9 := md.courant.find_child("GrilleCarnet", true, false) as GridContainer if is_instance_valid(md.courant) else null
	_verifier("Carnet à 9 produits : grille 3 colonnes, 9 cartes (silhouettes comprises), pas de défilement",
		g9 != null and g9.columns == 3 and g9.get_child_count() == 9 and md.courant.find_child("Defilant", true, false) == null, "" if g9 == null else "%d colonnes, %d cartes" % [g9.columns, g9.get_child_count()])
	md.banque.fermer_demande.emit()
	await get_tree().create_timer(0.5).timeout
	# Carnet à 13 produits (4 copies fabriquées en mémoire, retirées ensuite) : produits vus seulement, 4 colonnes au PC
	var d := Banquier.donnees()
	var cat := Donnees.charger("produits")   # lot 10a : les produits vivent dans le catalogue du monde, l'identité dans produits_vus
	var ordre_avant: Array = (d["ordre_carnet"] as Array).duplicate()
	for i in 4:
		var pid := "fab%d" % i
		var p: Dictionary = (cat["elf"] as Dictionary).duplicate(true)
		p["court"] = "FAB %d" % (i + 1)
		p["presentation"] = pid
		cat[pid] = p
		d["ordre_carnet"].append(pid)
		Banquier.produits_vus(e).append(pid)
	var vus := 0
	for pid in d["ordre_carnet"]:
		if Banquier.presente(e, pid):
			vus += 1
	scene.call("ouvrir_banque", "", -2.0)
	await _images(3)
	var g13 := md.courant.find_child("GrilleCarnet", true, false) as GridContainer if is_instance_valid(md.courant) else null
	var attendu_col := 3 if Ecran.compact() else 4
	_verifier("Carnet à 13 produits : produits vus seulement (%d), %d colonnes, défilement seulement au téléphone" % [vus, attendu_col],
		g13 != null and g13.columns == attendu_col and g13.get_child_count() == vus and (md.courant.find_child("Defilant", true, false) != null) == Ecran.compact(),
		"" if g13 == null else "%d colonnes, %d cartes" % [g13.columns, g13.get_child_count()])
	md.banque.fermer_demande.emit()
	await get_tree().create_timer(0.5).timeout
	for i in 4:
		cat.erase("fab%d" % i)
		Banquier.produits_vus(e).erase("fab%d" % i)
	d["ordre_carnet"] = ordre_avant
	Partie.sauvegarde_auto = false
	scene.queue_free()
	await _images(2)
	Juice.camera = null
	Juice.hud = null
	Juice.calque_effets = null


# ---------------------------------------------------------------------
# a quater) Lot 10b, étape 2 : passage de chapitre, vitrine en courbe, bilan à deux titres, choix du départ, PEA / SCPI / PEP
# (jeu d'essai tests/donnees/chapitres : chapitres « 1984 » et « 1989 » ouverts)
# ---------------------------------------------------------------------

func _monter_modales() -> Array:
	var calque := CanvasLayer.new()
	calque.layer = 5
	add_child(calque)
	var md := Modales.new()
	md.donnees_demo = Donnees.charger("demo").duplicate(true)
	calque.add_child(md)
	Juice.hud = calque
	return [calque, md]


func _boutons_texte(racine: Node, texte: String) -> Array:
	var out: Array = []
	for b: Button in racine.find_children("*", "Button", true, false):
		if b.text == texte and b.is_visible_in_tree():
			out.append(b)
	return out


func _test_chapitre_2() -> void:
	var racine_avant := Donnees.racine_chapitres
	Donnees.racine_chapitres = "res://tests/donnees/chapitres"
	Donnees.regler_chapitre("")
	Donnees.vider_cache()
	# Partie 1984 -> 1993 sur le jeu d'essai : on garde la carte de passage (1989-01) et la vitrine (1989-11) avant de les résoudre
	var e := EtatPartie.new()
	var cfg := Donnees.config_chapitre("1984", 3)
	cfg["banquier"] = true
	cfg["rue"] = true
	e.demarrer(cfg)
	var passage := {}
	var vitrine := {}
	var garde := 0
	while e.fin == "" and garde < 400:
		garde += 1
		while not e.modale.is_empty():
			var c0 := e.contenu_modale()
			if str(c0.get("kind", "")) == "passage" and passage.is_empty():
				passage = c0
			if str(c0.get("kind", "")) == "marche" and c0.has("courbe") and vitrine.is_empty():
				vitrine = c0
			e.resolution_auto()
		e.avancer()
	var env := _monter_modales()
	var md: Modales = env[1]
	# Carte de passage (version A)
	md.passage(passage, Vector2(-1, -1))
	await _images(8)
	var pp := md.etat_passage()
	var ab_p := Dates.lire("1989-01")
	_verifier("Passage : carte ouverte, titre « JANVIER 1989 », chiffres == contenu_modale (patrimoine, écart, rang), un seul bouton CONTINUER",
		md.genre_courant == "passage" and str(pp.infos.get("titre", "")) == "JANVIER 1989" and (pp.infos["valeurs"] as Array)[0] == Format.montant(float(passage["patrimoine"]), ab_p)
		and (pp.infos["valeurs"] as Array)[1] == ModaleReleveFin.pct_texte(float(passage["ecart_tata_pct"])) and int(pp.infos.get("boutons", 0)) == 1 and md.courant.find_children("*", "Button", true, false).size() == 1,
		str(pp.infos))
	_verifier("Passage : aucun titre révélé (promesse « Votre titre d'époque 1984-1988 vous attend au bilan final. »), texte d'attente == contenu",
		str(pp.infos.get("promesse", "")) == "Votre titre d'époque 1984-1988 vous attend au bilan final." and str(pp.infos.get("attente", "")) == str(passage["texte_attente"]), str(pp.infos.get("promesse", "")))
	var ferme := []
	md.choix_fait.connect(func(g: String, i: String) -> void: ferme.append([g, i]))
	await _touche(KEY_ESCAPE)
	var apres_echap := md.genre_courant == "passage"
	await _touche(KEY_ENTER)
	await _images(3)
	_verifier("Passage : Échap sans effet, Entrée ferme avec « continuer »", apres_echap and ferme == [["passage", "continuer"]], str(ferme))
	await get_tree().create_timer(0.4).timeout
	# Vitrine en courbe : 3 points, mention fixe, pas de tableau des jours
	md.journal(vitrine, Vector2(-1, -1), false)
	await _images(10)
	var cv: CourbeVitrine = md._journal.courbe_vue
	var lm := md.courant.find_child("Mention", true, false) as Label if is_instance_valid(md.courant) else null
	_verifier("Vitrine : courbe de %d points (valeurs == contenu), mention fixe == contenu, aucun tableau des jours" % (vitrine["courbe"] as Array).size(),
		cv != null and cv.lues.size() == (vitrine["courbe"] as Array).size() and cv.lues[0][1] == ModaleJournal.texte_indice(float(vitrine["courbe"][0]["valeur"]))
		and lm != null and lm.text == str(vitrine["mention"]) and md._journal.lignes_jours.is_empty(), str(cv.lues) if cv != null else "pas de courbe")
	md.fermer("fermer")
	await get_tree().create_timer(0.4).timeout
	# Bilan final 1984 -> 1993 : deux plaques == bilan[titres], deux records, courbe sur toute la durée
	var chemin_rec := "user://test_interface_chap2_%d.sav" % OS.get_process_id()
	var b := Bilan.calculer(e)
	b["record"] = Records.enregistrer(b, "test_chap2", chemin_rec, "2026-11-19")
	md.dernier_bilan = b
	var avant_records := Partie.chemin_records
	Partie.chemin_records = chemin_rec
	Partie.etat = e
	md.fin_demo(e)
	await _images(12)
	var fin := md.etat_fin()
	var noms_plaques := []
	for t: Dictionary in b["titres"]:
		var pl := md.courant.find_child("PlaqueTitre_%s" % str(t["chapitre"]), true, false) if is_instance_valid(md.courant) else null
		var nom := pl.find_child("NomTitre", true, false) as Label if pl != null else null
		noms_plaques.append(nom.text if nom != null else "?")
	var attendus := (b["titres"] as Array).map(func(t: Dictionary) -> String: return str(t["nom"]).to_upper())
	_verifier("Bilan 1984 -> 1993 : %d plaques de titre == bilan[titres] (noms, une par chapitre)" % (b["titres"] as Array).size(),
		(b["titres"] as Array).size() == 2 and int(fin.infos_fin.get("plaques", 0)) == 2 and noms_plaques == attendus, "%s / %s" % [str(noms_plaques), str(attendus)])
	_verifier("Bilan : deux lignes de record (chapitre, partie) == bilan, nouveaux à la 1re partie ; durée « dix ans »",
		fin.infos_fin.get("records", []) == ["nouveau", "nouveau"]
		and _tous_textes(md.courant).any(func(t: String) -> bool: return t.contains("RECORD DE CHAPITRE") and t.contains("1984-1988"))
		and _tous_textes(md.courant).any(func(t: String) -> bool: return t.contains("RECORD DE PARTIE") and t.contains("1984-1993")) and _tous_textes(md.courant).any(func(t: String) -> bool: return t.contains("DIX ANS")),
		str(fin.infos_fin.get("records", [])))
	md.fermer("quitter")
	await get_tree().create_timer(0.4).timeout
	Partie.chemin_records = avant_records
	Records.effacer(chemin_rec)
	# Collection et écran titre par chapitre
	var par_chapitre := Noms.titres_par_chapitre()
	md.titres(Records.lire(chemin_rec), Titres.tous(), par_chapitre)
	await _images(6)
	_verifier("Collection : un onglet par chapitre ouvert (%d), 9 tuiles chacun" % par_chapitre.size(), md.etat_titres().infos.get("onglets", 0) == par_chapitre.size() and par_chapitre.size() == 2 and md.etat_titres().infos.get("tuiles", 0) == 9,
		str(md.etat_titres().infos))
	md.fermer("fermer")
	await get_tree().create_timer(0.4).timeout
	# Choix du départ : une carte par chapitre ouvert, touche 2 = 1989
	var cartes := ChoixDepart.cartes()
	md.choix_depart(cartes)
	await _images(6)
	var recu := []
	md.choix_fait.connect(func(g: String, i: String) -> void: recu.append([g, i]))
	var ok_cartes: bool = cartes.size() == 2 and cartes[0]["id"] == "1984" and cartes[1]["id"] == "1989" and cartes[0]["titre"] == "JANVIER 1984" and cartes[1]["titre"] == "JANVIER 1989"
	await _touche(KEY_2)
	await _images(3)
	_verifier("Choix du départ : 2 cartes (1984, 1989) lues dans les données, la touche 2 choisit 1989", ok_cartes and recu.has(["depart", "1989"]), str(cartes))
	await get_tree().create_timer(0.4).timeout
	# Le foyer de la partie : portrait du conjoint selon le genre
	_verifier("Noms.portrait_proche : Sylvie (f) pour Gérard ; conjoint homme pour une joueuse avec proche h",
		Noms.portrait_proche(e) == "portrait_sylvie_" and Noms.portrait_proche(null) == "portrait_sylvie_" and CadresPixel.texture("portrait_proche_h_neutre") != null)
	e = null
	env[0].queue_free()
	await _images(2)
	Donnees.racine_chapitres = racine_avant
	Donnees.regler_chapitre("")
	Donnees.vider_cache()


func _tous_textes(racine: Node) -> Array:
	var out: Array = []
	for l: Label in racine.find_children("*", "Label", true, false):
		out.append(l.text)
	return out


## PEA, SCPI et PEP dans la fenêtre Banque, sur le vrai moteur (1992-08 du jeu d'essai : le PEA existe depuis 07/1992).
func _test_enveloppes() -> void:
	var racine_avant := Donnees.racine_chapitres
	Donnees.racine_chapitres = "res://tests/donnees/chapitres"
	Donnees.regler_chapitre("")
	Donnees.vider_cache()
	Partie.chemin_sauvegarde = _chemin_test
	Partie.sauvegarde_auto = false
	var cfg := Donnees.config_chapitre("1984", 5)
	cfg["banquier"] = true
	Partie.nouvelle_partie(cfg)
	var e := Partie.etat
	StrategieTest.aller_a(e, Dates.lire("1989-06"), true)   # GARDE : 100 mois par saut
	StrategieTest.aller_a(e, Dates.lire("1992-08"), true)
	e.joueur.cc = Produits.f(60000.0)
	var env := _monter_modales()
	var md: Modales = env[1]
	# Produits injectés dans le carnet de la partie (le jeu d'essai n'a pas ceux de 1989)
	var d := Banquier.donnees()
	var ordre_avant: Array = (d["ordre_carnet"] as Array).duplicate()
	for pid in ["scpi", "pea", "pep", "elf"]:
		if not (d["ordre_carnet"] as Array).has(pid):
			d["ordre_carnet"].append(pid)
		if not Banquier.produits_vus(e).has(pid):
			Banquier.produits_vus(e).append(pid)
	md.ouvrir_banque(e, "scpi", -2.0)
	await _images(10)
	var fiche := md.banque.zone_droite()
	_verifier("SCPI : fiche avec « Vous avez » == texte du moteur (rien), boutons ACHETER par parts (1, 5, 10)",
		fiche.find_child("VousAvez", true, false) != null and (fiche.find_child("VousAvez", true, false) as Label).text == PanneauEnveloppes.texte_scpi(e) and _boutons_texte(fiche, "5 PARTS").size() == 1)
	_boutons_texte(fiche, "5 PARTS")[0].pressed.emit()
	await _images(4)
	var l_scpi := md.banque.zone_droite().find_child("VousAvez", true, false) as Label
	_verifier("SCPI : achat de 5 parts : 5 parts au moteur, ligne == valeur de revente (valeur_scpi), tuile du carnet == valeur de revente",
		int(Enveloppes.parts(e.joueur)) == 5 and l_scpi != null and l_scpi.text == PanneauEnveloppes.texte_scpi(e) and l_scpi.text.contains(Format.montant(Enveloppes.valeur_scpi(e.joueur, e.ab_courant()), e.ab_courant()))
		and (md.banque._cartes["scpi"] as CarteProduit).ligne1 == Format.entier(Enveloppes.valeur_scpi(e.joueur, e.ab_courant()), e.ab_courant()), l_scpi.text if l_scpi != null else "?")
	(md.banque.zone_droite().find_child("Rangee_VENDRE", true, false).find_children("*", "Button", true, false)[0] as Button).pressed.emit()
	await _images(4)
	var ventes := e.ventes_differees()
	var l_vente := md.banque.zone_droite().find_child("VenteEnCours", true, false)
	var texte_vente := ""
	for l: Label in l_vente.find_children("*", "Label", true, false) if l_vente != null else []:
		texte_vente = l.text
	_verifier("SCPI : vente différée de 1 part visible avec son mois d'exécution (+ 3 mois) et un bouton ANNULER",
		ventes.size() == 1 and int(ventes[0]["parts"]) == 1 and texte_vente.contains(Dates.texte(e.ab_de(int(ventes[0]["m_execution"])))) and int(ventes[0]["m_execution"]) == e.m + 3
		and _boutons_texte(md.banque.zone_droite(), "ANNULER").size() == 1, texte_vente)
	_boutons_texte(md.banque.zone_droite(), "ANNULER")[0].pressed.emit()
	await _images(4)
	_verifier("SCPI : ANNULER supprime la vente en cours", e.ventes_differees().is_empty() and md.banque.zone_droite().find_child("VenteEnCours", true, false) == null)
	# PEA : ouvrir, verser, acheter un titre éligible dans l'enveloppe
	md.banque.call("_choisir", "pea")
	await _images(4)
	var ouvrir := _boutons_texte(md.banque.zone_droite(), "OUVRIR UN PEA")
	_verifier("PEA : sans plan, bouton OUVRIR UN PEA", ouvrir.size() == 1)
	ouvrir[0].pressed.emit()
	await _images(4)
	_verifier("PEA : plan ouvert au moteur, versements proposés", Enveloppes.a_pea(e.joueur) and _boutons_texte(md.banque.zone_droite(), Format.entier(Produits.f(5000.0), e.ab_courant())).size() >= 1, "%s ; %s ; PEA dispo %s ; boutons %s" % [str(e.joueur.pea), Dates.texte(e.ab_courant()), Enveloppes.pea_disponible(e.ab_courant()), str(md.banque.zone_droite().find_children("*", "Button", true, false).map(func(x: Button) -> String: return x.text))])
	var b5 := _boutons_texte(md.banque.zone_droite(), Format.entier(Produits.f(5000.0), e.ab_courant()))
	b5[0].pressed.emit()
	await _images(4)
	_verifier("PEA : versement de 5 000 F : espèces du PEA == versement", is_equal_approx(float(e.joueur.pea["cc"]), Produits.f(5000.0)), str(e.joueur.pea.get("cc", "?")))
	var ba := md.banque.zone_droite().find_child("AcheterPea", true, false) as Button
	if ba != null:
		ba.pressed.emit()
		await _images(4)
	_verifier("PEA : achat d'un titre éligible DANS l'enveloppe (Partie.acheter(..., \"pea\")) : ligne portée par le PEA", not (e.joueur.pea["lignes"] as Dictionary).is_empty() and e.enveloppe((e.joueur.pea["lignes"] as Dictionary).keys()[0]) == "pea",
		str((md.banque.zone_droite().find_child("MessageEnveloppe", true, false) as Label).text) if md.banque.zone_droite().find_child("MessageEnveloppe", true, false) != null else "pas de message ; bouton %s" % str(ba))
	# PEP : message, aucun bouton d'achat
	md.banque.call("_choisir", "pep")
	await _images(4)
	_verifier("PEP : fiche d'information sans bouton d'achat (ni ACHETER, ni OUVRIR, ni VERSER)",
		_boutons_texte(md.banque.zone_droite(), "ACHETER").is_empty() and _boutons_texte(md.banque.zone_droite(), "VERSER").is_empty() and md.banque.zone_droite().find_child("TexteLong", true, false) != null)
	md.banque.fermer_demande.emit()
	await get_tree().create_timer(0.4).timeout
	d["ordre_carnet"] = ordre_avant
	env[0].queue_free()
	Partie.nouvelle_partie(Donnees.config_demo(GRAINE))
	Partie.sauvegarde_auto = false
	await _images(2)
	Donnees.racine_chapitres = racine_avant
	Donnees.regler_chapitre("")
	Donnees.vider_cache()


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

func _test_demo_complete(actif: bool, cartes := false) -> void:
	var nom := ("joueur actif" if actif else "joueur passif") + (", cartes allumées" if cartes else "")
	var cartes_vues := 0
	var ecarts_etiquette: Array = []
	var ecarts_rue: Array = []
	_rue_mois = 0
	_krach_tableaux = 0
	_gazettes_vues = 0
	_ordres_refuses = 0
	_projets_choisis = 0
	_ventes_conformes = 0
	_etiquettes_vues = 0
	_guichets_vus = 0
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

	var config_partie := Donnees.config_demo(GRAINE)
	# Lot 05 : le joueur actif choisit le projet le plus cher et vend pour le réaliser (la vente passe par la confirmation)
	StrategieTest.politique_projets = "plus_cher" if (actif and cartes) else "moins_cher"
	StrategieTest.politique_echeance = "vendre" if (actif and cartes) else "auto"
	if cartes:
		config_partie["cartes"] = true
		config_partie["projets"] = true   # lot 05 : le vrai moteur des projets (04-L)
		config_partie["rue"] = true       # lot 06 : la rue (05-L) : Jean-Mi, classement, notifications, krach
	Partie.nouvelle_partie(config_partie)
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
		if cartes:
			var pe := e.projet_en_cours()
			var vu_p := (hud.etiquettes["maison"].find_child("LigneProjet", true, false) as Label)
			var attendu_p := "" if pe.is_empty() else "%s / %s" % [Format.nombre(Format.en_devise(float(pe["disponible"]), Format.devise(e.ab_courant()))), Format.entier(float(pe["montant"]), e.ab_courant())]
			if (vu_p.text if vu_p.visible else "") != attendu_p:
				ecarts_etiquette.append("%s : « %s » au lieu de « %s »" % [Dates.texte_court(e.ab_courant()), vu_p.text, attendu_p])
			elif attendu_p != "":
				_etiquettes_vues += 1
			# Lot 06 : bloc LA RUE et rang de la languette == classement_rue() / rang_rue()
			var cl := e.classement_rue()
			var lt := hud.bloc_rue.lignes_texte
			var ok_rue := cl.size() == 4 and lt.size() == cl.size() and hud.bloc_rue.visible
			for i in mini(cl.size(), lt.size()):
				ok_rue = ok_rue and str(lt[i]["id"]) == str(cl[i]["id"]) and int(lt[i]["rang"]) == int(cl[i]["rang"]) and str(lt[i]["montant"]) == BlocRue.texte_patrimoine(float(cl[i]["patrimoine"]), e.ab_courant()) and bool(lt[i]["vous"]) == bool(cl[i]["vous"])
			ok_rue = ok_rue and (hud._languette_rang.get_child(1) as Label).text == BlocRue.rang_texte(e.rang_rue())
			if ok_rue:
				_rue_mois += 1
			else:
				ecarts_rue.append("%s : %s / %s" % [Dates.texte_court(e.ab_courant()), str(lt), str(cl)])
		if not e.modale.is_empty():
			if e.modale.get("kind", "") == "carte":
				cartes_vues += 1
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
	var banque_ok := banques.size() == 3
	for b: Dictionary in banques:
		n_produits += int(b["produits"])
		if not b["ok"]:
			banque_ok = false
	_verifier("%s : fenêtre Banque (fiche, « chaque mois », formulaire d'ordre) sur chaque produit détenu en déc. 1986, avril 1987 et juin 1988" % nom,
		banque_ok and (n_produits >= 8 if actif else n_produits >= 0), str(banques))
	if cartes:
		_verifier("%s : %d cartes du foyer affichées par Modales.carte, chacune fermée par un choix, rangée dans l'historique, sans blocage" % [nom, cartes_vues],
			cartes_vues >= 8 and cartes_vues <= 10 and int(vues.get("carte", 0)) == cartes_vues and ecarts_genre.is_empty() and ecarts_choix.is_empty(), "%s %s" % [str(ecarts_genre), str(ecarts_choix)])
	if cartes:
		await _verifier_projets(nom, e)
	StrategieTest.politique_projets = "moins_cher"
	StrategieTest.politique_echeance = "auto"
	if cartes:
		_verifier("%s : « Le krach, un an après » (octobre 1988) par Modales.gazette : 3 barres == c[barres], Échap sans effet, touche 1 (%d)" % [nom, _gazettes_vues], _gazettes_vues == 1)
		_verifier("%s : le krach (rue allumée) porte le tableau des 7 jours du Lundi noir == c[jours] (%d)" % [nom, _krach_tableaux], _krach_tableaux == 1)
		_verifier("%s : classement permanent : bloc LA RUE (4 lignes : id, rang, montant, « vous ») et rang de la languette == classement_rue() / rang_rue() chaque mois (%d mois)" % [nom, _rue_mois], _rue_mois >= 55 and ecarts_rue.is_empty(), str(ecarts_rue.slice(0, 2)))
		_verifier("%s : vrai moteur des projets : %d choix de projet (projet_en_cours()[id] == option choisie), ventes faites == plan (%d), %d refus d'ordres pendant une carte ou un projet avec la phrase de l'interface, étiquette == projet_en_cours() (%d mois), ligne du guichet == ligne_projet_guichet() (%d fiches)" % [nom, _projets_choisis, _ventes_conformes, _ordres_refuses, _etiquettes_vues, _guichets_vus],
			_projets_choisis >= 2 and int(vues.get("projet", 0)) >= 3 and _ordres_refuses >= 10 and ecarts_etiquette.is_empty() and ecarts_genre.is_empty() and ecarts_choix.is_empty() and (not actif or _guichets_vus >= 1), "%s %s %s" % [str(ecarts_etiquette), str(ecarts_genre), str(ecarts_choix)])
	if actif and not cartes:
		_verifier("%s : fiche d'une action : « Dividende : versé en mai… » avant le 1er versement, « Dividendes reçus » après (%s)" % [nom, str(_div_vus)],
			int(_div_vus.get("versé", 0)) >= 1 and int(_div_vus.get("reçus", 0)) >= 1, str(_div_vus))
		# Notifications de dividendes (dont dividende_nul, cls « neutre ») : notifications ordinaires de la banque
		var nul := Banquier.notif_dividende_nul(e, "peugeot")
		hud.notifier(nul, e.ab_courant())
		await get_tree().process_frame
		var textes_nul := hud.notifs.find_children("*", "Label", true, false).map(func(l: Node) -> String: return (l as Label).text)
		_verifier("%s : notification « dividende_nul » (cls %s) affichée comme une notification de la banque (« %s »)" % [nom, str(nul["cls"]), str(nul["titre"])],
			str(nul["titre"]) != "" and textes_nul.has(str(nul["titre"])) and textes_nul.has(str(nul["texte"])), str(textes_nul))
		# D14 (lot 04) : le montant à droite d'une notification de dividende s'écrit à l'unité, comme son texte
		var ndiv := {"type": "dividende", "source": "banque", "cls": "gain", "montant": Produits.f(175.92), "titre": "Vos actions vous versent un dividende", "texte": "Vous touchez 176 F."}
		hud.notifier(ndiv, e.ab_courant())
		await get_tree().process_frame
		var attendu_div := Format.ecart(Produits.f(175.92), e.ab_courant())
		var textes_div := hud.notifs.find_children("*", "Label", true, false).map(func(l: Node) -> String: return (l as Label).text)
		_verifier("%s : notification de dividende : montant à droite « %s » (à l'unité)" % [nom, attendu_div], textes_div.has(attendu_div), str(textes_div))
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
	# Lot 06 (A7, CA-U7) : rue allumée : 4 barres == bilan["rue"], rang, réplique ; rue éteinte : l'écran de fin de main (aucune pastille de rang)
	var mfin := modales.etat_fin()
	# Lot 07-I (CA-T14) : le titre d'époque affiché == bilan["titre"] (nom et « pourquoi »), aucune étoile ni « Cousin Indice »
	var t_bilan: Dictionary = bilan.get("titre", {})
	var nl_t := modales.courant.find_child("NomTitre", true, false) as Label
	var pl_t := modales.courant.find_child("PourquoiTitre", true, false) as Label
	var etoile_t := false
	for lb: Node in modales.courant.find_children("*", "Label", true, false):
		var tl := (lb as Label).text.to_lower()
		etoile_t = etoile_t or tl.contains("étoile") or tl.contains("cousin indice")
	_verifier("%s : écran de fin : titre affiché == bilan[titre] (« %s »), pourquoi == bilan, aucune étoile" % [nom, str(t_bilan.get("nom", ""))],
		((nl_t == null and t_bilan.is_empty()) or (nl_t != null and nl_t.text == str(t_bilan["nom"]).to_upper() and pl_t != null and pl_t.text == "« %s »" % str(t_bilan["pourquoi"]))) and not etoile_t,
		"%s / %s" % [nl_t.text if nl_t != null else "-", str(t_bilan.get("nom", "-"))])
	var rue_bilan: Array = bilan.get("rue", [])
	if cartes:
		var lus_f: Array = mfin.barres_fin.lignes.map(func(l: Array) -> String: return "%s|%s" % [str(l[0]), Format.entier(float(l[1]), e.ab_courant())]) if mfin.barres_fin != null else []
		var att_f: Array = rue_bilan.map(func(l: Dictionary) -> String: return "%d %s|%s" % [int(l["rang"]), str(l["nom"]).to_upper(), Format.entier(float(l["patrimoine"]) / Format.TAUX_EURO, e.ab_courant())])
		var rep_ok: bool = (modales.courant.find_child("TexteReplique", true, false) != null) == (not bilan.get("replique_rue", {}).is_empty())
		_verifier("%s : écran de fin à 4 barres == bilan[rue] (%d lignes, rang %s), réplique == replique_rue, « Projets : n sur 2 », visage de Sylvie" % [nom, lus_f.size(), str(mfin.infos_rue.get("rang", "?"))],
			rue_bilan.size() == 4 and lus_f == att_f and rep_ok and int(mfin.infos_rue.get("rang", 0)) == e.rang_rue() and mfin.infos_rue.has("projets") and bool(mfin.infos_rue.get("visage", false)), "%s / %s" % [str(lus_f), str(att_f)])
	else:
		_verifier("%s : rue éteinte : écran de fin inchangé (2 barres, aucune pastille de rang)" % nom, rue_bilan.is_empty() and mfin.barres_fin == null and modales.courant.find_child("PastilleRang", true, false) == null)
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
	if c.get("kind", "") == "carte":
		_verifier_ordres_bloques(e, ecarts_choix, str(c.get("titre", "")))
		await _afficher_carte(e, c, choix, vues, ecarts_genre, ecarts_choix)
		return
	if c.get("kind", "") == "gazette":
		await _afficher_gazette(e, c, vues, ecarts_genre, ecarts_choix)
		return
	if c.get("kind", "") == "projet":
		_verifier_ordres_bloques(e, ecarts_choix, str(c.get("titre", "")))
		await _afficher_projet(e, c, choix, vues, ecarts_genre, ecarts_choix)
		return
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
	if genre == "journal" and c.has("jours"):
		# Lot 06 (A5, CA-U5) : le tableau du Lundi noir == c["jours"] (7 lignes arrondies à 5 points), absent sans « jours »
		var jr: Array = c["jours"]
		var lus: Array = modales._journal.lignes_jours.map(func(l: Array) -> String: return "|".join(PackedStringArray(l)))
		var att: Array = jr.map(func(j: Dictionary) -> String: return "%s|%s|%s" % [ModaleJournal.texte_jour(str(j["jour"])), ModaleJournal.texte_indice(float(j["indice"])), ModaleJournal.texte_variation(float(j.get("variation", 0.0)), j == jr[0])])
		if jr.size() == 7 and lus == att and modales._journal.cases in [7, 8]:
			_krach_tableaux += 1
		else:
			ecarts_choix.append("krach : tableau %s au lieu de %s" % [str(lus), str(att)])
	elif genre == "journal" and modales.courant.find_child("TableauJours", true, false) != null:
		ecarts_choix.append("%s : tableau du Lundi noir présent sans « jours »" % str(c.get("titre", "")))
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


## Carte du foyer comme la séquence de la ville : Modales.carte, choix, résolution, conclusion (passée d'un toucher), rangement.
func _afficher_carte(e: EtatPartie, c: Dictionary, choix: String, vues: Dictionary, ecarts_genre: Array, ecarts_choix: Array) -> void:
	var titre := str(c.get("titre", ""))
	modales.carte(c, Vector2(960, 400))
	var t := 0.0
	var mc := modales.etat_carte()
	while mc.phase != "attente" and t < 5.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	vues["carte"] = int(vues.get("carte", 0)) + 1
	if modales.genre_courant != "carte" or mc.phase != "attente":
		ecarts_genre.append("%s : « %s » affichée comme « %s » (phase %s)" % [Dates.texte_court(e.ab_courant()), titre, modales.genre_courant, mc.phase])
		return
	# Mise en page de la carte : cibles tactiles, polices, dans l'écran (lot 04, I1)
	var vue := get_viewport().get_visible_rect()
	for b in modales.courant.find_children("*", "Button", true, false):
		var bb := b as Button
		if not bb.disabled and minf(bb.size.x, bb.size.y) < Style.cible_min() - 0.5:
			ecarts_choix.append("%s : bouton « %s » sous la cible minimale (%s)" % [titre, bb.name, str(bb.size)])
	for l in modales.courant.find_children("*", "Label", true, false):
		var lab := l as Label
		var fnt := lab.get_theme_font("font")
		var tl := lab.get_theme_font_size("font_size")
		if (PolicesPixel.est_atkinson(fnt) and tl < 20) or (PolicesPixel.est_pixelify(fnt) and (tl < 28 or Style.a_chiffre(lab.text))):
			ecarts_choix.append("%s : police de « %s » (%d)" % [titre, lab.text.left(20), tl])
	if not vue.grow(1.0).encloses(modales.courant.get_global_rect()):
		ecarts_choix.append("%s : carte hors de l'écran %s" % [titre, str(modales.courant.get_global_rect())])
	_recu.clear()
	mc.choisir(choix)
	var r: Array = _recu.pop_back() if not _recu.is_empty() else []
	if r != ["carte", choix]:
		ecarts_choix.append("%s : choix_fait %s au lieu de %s" % [titre, str(r), str(["carte", choix])])
	var n_hist := e.historique.size()
	var res := e.resoudre_modale(choix)
	if res.is_empty() or str(res.get("choix", "")) != choix:
		ecarts_choix.append("%s : résolution %s" % [titre, str(res)])
		return
	if e.historique.size() < n_hist + 1 or str(e.historique[n_hist]["genre"]) != "carte":
		ecarts_choix.append("%s : carte absente de l'historique" % titre)
	modales.conclure_carte(res, Vector2(960, 400))
	t = 0.0
	while mc.phase != "conclusion" and t < 3.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	var lq := modales.courant.find_child("Consequence", true, false) as Label if modales.courant != null else null
	if lq != null and str(res.get("consequence", "")) != "" and lq.text != str(res["consequence"]):
		ecarts_choix.append("%s : conséquence affichée « %s »" % [titre, lq.text])
	mc.passer()
	await modales.carte_rangee
	hud.maj(e, false)


## Lot 05 (04-I) : cartes de projet sur contenus fabriqués (contrat lot_04 §4.2) : choix, jour J, confirmation, étiquette,
## BANQUE fermée, « Mon foyer ». Les captures de la famille interface utilisent les mêmes fabricants.
func _verifier_projets(nom: String, e: EtatPartie) -> void:
	var scen: GDScript = load("res://scripts/outils/scenarios/interface.gd")
	var pos := Vector2(960, 400)
	var attendre_phase := func(mp: ModaleProjet, phase: String) -> bool:
		var t := 0.0
		while mp.phase != phase and t < 5.0:
			await get_tree().process_frame
			t += get_process_delta_time()
		return mp.phase == phase
	var mp := modales.etat_projet()
	# Choix : 3 options, touche 2, ni Échap ni clic extérieur, la carte reste affichée
	var c: Dictionary = scen.call("fabriquer_choix")
	modales.projet(c, pos)
	var ok: bool = await attendre_phase.call(mp, "attente")
	_recu.clear()
	await _touche(KEY_ESCAPE)
	var apres_echap := _recu.is_empty() and modales.genre_courant == "projet"
	var tit: Array = mp.ordre.map(func(id: String) -> String: return str((mp.boutons[id].find_child("TitreChoix", true, false) as Label).text))
	var attendus: Array = c["choix"].map(func(x: Dictionary) -> String: return str(x["titre"]))
	await _touche(KEY_2)
	var r: Array = _recu.pop_back() if not _recu.is_empty() else []
	_verifier("%s : projet, choix : 3 options (noms == contenu), touche 2 émet [projet, P1B], Échap sans effet, la carte reste affichée" % nom,
		ok and mp.ordre.size() == 3 and tit == attendus and apres_echap and r == ["projet", "P1B"] and modales.genre_courant == "projet", "%s %s %s" % [str(tit), str(r), modales.genre_courant])
	modales.conclure_projet({"choix": "P1B", "kind": "projet", "etape": "choix", "montant": 0.0, "consequence": "C'est décidé."}, pos)
	await attendre_phase.call(mp, "conclusion")
	var lq := modales.courant.find_child("Consequence", true, false) as Label if modales.courant != null else null
	var conseq_ok := lq != null and lq.text == "C'est décidé."
	mp.passer()
	await modales.carte_rangee
	_verifier("%s : projet, conclusion : ligne de conséquence affichée, passée d'un toucher, carte rangée" % nom, conseq_ok and modales.genre_courant == "" and not modales.carte_en_cours)
	# Jour J, cas B : RÉALISER désactivé et sans effet, confirmation de RÉALISER EN VENDANT == plan, Échap = RETOUR, CONFIRMER émet
	c = scen.call("fabriquer_jour_j", "b")
	modales.projet(c, pos)
	ok = await attendre_phase.call(mp, "attente")
	_recu.clear()
	var refus_avant := mp.refus
	mp.choisir("realiser")
	var refus_ok := mp.refus == refus_avant + 1 and _recu.is_empty()
	mp.choisir("realiser_en_vendant")
	var noms: Array = modales.courant.find_children("NomVente", "Label", true, false).map(func(l: Node) -> String: return (l as Label).text)
	var plan: Array = []
	for i in (c["ventes"] as Array).size():
		plan.append("%d  %s" % [i + 1, str(c["ventes"][i]["nom"])])
	var conf_ok: bool = mp.en_confirmation and noms == plan and _recu.is_empty()
	await _touche(KEY_ESCAPE)
	var retour_ok: bool = not mp.en_confirmation and modales.genre_courant == "projet" and _recu.is_empty()
	mp.choisir("realiser_en_vendant")
	mp.choisir_rang(0)   # 1 = CONFIRMER
	r = _recu.pop_back() if not _recu.is_empty() else []
	_verifier("%s : jour J (cas B) : choix désactivé sans effet, confirmation listant le plan, Échap = RETOUR, CONFIRMER émet realiser_en_vendant (%s)" % [nom, str(r)],
		ok and refus_ok and conf_ok and retour_ok and r == ["projet", "realiser_en_vendant"], "%s %s %s %s" % [refus_ok, conf_ok, retour_ok, str(noms)])
	modales.conclure_projet({"choix": "realiser_en_vendant", "kind": "projet", "etape": "echeance", "montant": 0.0, "consequence": "Fait.", "ventes": []}, pos)
	await attendre_phase.call(mp, "conclusion")
	mp.passer()
	await modales.carte_rangee
	# Jour J, cas A : rien à vendre (pas de 4e case), RÉALISER EN VENDANT désactivé
	c = scen.call("fabriquer_jour_j", "a")
	modales.projet(c, pos)
	await attendre_phase.call(mp, "attente")
	var sans_ventes: bool = modales.courant.find_child("RienAVendre", true, false) != null and modales.courant.find_child("CaseApresVentes", true, false) == null
	var vendre_off: bool = bool(mp.choix["realiser_en_vendant"].get("desactive", false)) and mp.boutons["realiser_en_vendant"].disabled
	_verifier("%s : jour J (cas A) : « Rien à vendre », pas de case APRÈS LES VENTES, RÉALISER EN VENDANT désactivé" % nom, sans_ventes and vendre_off)
	mp.choisir("renoncer")
	_recu.clear()
	modales.conclure_projet({"choix": "renoncer", "kind": "projet", "etape": "echeance", "montant": 0.0, "consequence": "Abandonné.", "ventes": []}, pos)
	await attendre_phase.call(mp, "conclusion")
	mp.passer()
	await modales.carte_rangee
	# Étiquette MA MAISON : 2e ligne == contrat ; absente sans projet
	var pr: Dictionary = scen.call("fabriquer_projet_en_cours")
	var texte := hud.maj_projet(e, pr)
	var attendu_t := "%s / %s" % [Format.nombre(Format.en_devise(float(pr["disponible"]), Format.devise(e.ab_courant()))), Format.entier(float(pr["montant"]), e.ab_courant())]
	var sans := hud.maj_projet(e, {"_aucun": true})
	_verifier("%s : étiquette MA MAISON : 2e ligne « %s » == disponible / montant du projet, absente sans projet" % [nom, attendu_t], texte == attendu_t and sans == "", "%s / %s" % [texte, sans])
	# Rue éteinte : ni bloc ni rang (le panneau et la languette redeviennent ceux de main) ; puis la rue revient
	hud.maj_rue_eteinte(null)
	var eteint_ok := not hud.bloc_rue.visible and not hud._languette_rang.visible and hud.bloc_rue.lignes_texte.is_empty() and not hud.panneau_a_trois_colonnes()
	hud.maj_rue(e)
	_verifier("%s : rue éteinte : bloc LA RUE et rang cachés ; rallumée : bloc de retour" % nom, eteint_ok and hud.bloc_rue.visible and hud.bloc_rue.lignes_texte.size() == 4)
	# Notifications de la rue (lot 06, A3) : toast = texte court, « Lire › » si long, relecture = texte_long, persistante jusqu'au toucher
	var scen_r: GDScript = scen
	var nl: Dictionary = scen_r.call("fabriquer_voisin", "long")
	hud.notifier(nl, e.ab_courant())
	await get_tree().create_timer(0.7).timeout
	var tx := hud.notifs.find_children("TexteNotif", "Label", true, false).map(func(l: Node) -> String: return (l as Label).text)
	var toast_ok: bool = tx.has(str(nl["texte"])) and hud.notifs.find_child("Lire", true, false) != null
	var np: Dictionary = scen_r.call("fabriquer_voisin", "persistant")
	hud.notifier(np, e.ab_courant())
	await get_tree().create_timer(0.7).timeout
	var pers_ok := hud.notifs.find_child("IndicationPersistante", true, false) != null
	modales.lecture_notification({"source": "rue", "contenu": nl, "titre": str(nl["titre"])}, e.ab_courant())
	await _attendre_genre("info")
	var lt := modales.courant.find_child("TexteLecture", true, false) as Label
	var lecture_ok := lt != null and lt.text == str(nl["texte_long"])
	_fermer("fermer")
	_verifier("%s : notifications de la rue : toast == texte court + « Lire › », relecture == texte_long, notification persistante gardée jusqu'au toucher" % nom, toast_ok and pers_ok and lecture_ok, "%s %s %s" % [toast_ok, pers_ok, lecture_ok])
	# BANQUE fermée : bouton grisé et phrase ; rouverte ensuite
	var ferme := hud.maj_banque_fermee(true)
	var phrase_ok := hud.l_banque_fermee.text == "Réglez d'abord la carte du foyer." and hud.l_banque_fermee.visible and hud.b_marche.disabled
	hud.maj_banque_fermee(false)
	_verifier("%s : BANQUE grisée avec « Réglez d'abord la carte du foyer. » pendant une carte, rouverte ensuite" % nom, ferme and phrase_ok and not hud.b_marche.disabled and not hud.l_banque_fermee.visible)
	# « Mon foyer » : projet en cours et projets passés == contenus
	var fab := {"projet": pr, "passes": scen.call("fabriquer_projets_passes")}
	modales.foyer(e, pos, fab)
	await _attendre_genre("info")
	var mf := modales.etat_foyer()
	var lp: Array = mf.lignes_projet.map(func(l: Label) -> String: return l.text)
	var ls: Array = mf.lignes_passes.map(func(l: Label) -> String: return l.text)
	var passes_ok := ls.size() == 3 and str(ls[0]).begins_with("abandonné") and str(ls[1]).begins_with("réalisé après report") and str(ls[2]).begins_with("réalisé ·")
	var sans_jauge := true
	var chiffres_humeur: Array = []
	for l in [mf.l_phrase]:   # la cause est une citation du moteur (elle peut citer un montant)
		if l != null and RegEx.create_from_string("[0-9]").search((l as Label).text) != null:
			chiffres_humeur.append((l as Label).text)
	sans_jauge = chiffres_humeur.is_empty()
	_fermer("fermer")
	_verifier("%s : « Mon foyer » : projet en cours == contrat (%d lignes), 3 projets passés avec leur mot, aucun nombre d'humeur" % [nom, lp.size()],
		lp == ModaleFoyer.textes_projet(pr, e.ab_courant()) and passes_ok and sans_jauge, "%s | %s | %s %s" % [str(lp), str(ls), str(passes_ok), str(sans_jauge)])
	hud.maj_projet(e, {"_aucun": true})

## « Le krach, un an après » comme la séquence de la ville : Modales.gazette, 3 barres == c["barres"] (jamais triées), Échap sans effet,
## J'AI COMPRIS (touche 1) émet [gazette, ok], résolution du moteur, fondu.
func _afficher_gazette(e: EtatPartie, c: Dictionary, vues: Dictionary, ecarts_genre: Array, ecarts_choix: Array) -> void:
	modales.gazette(c, Vector2(960, 400))
	var mg := modales.etat_gazette()
	var t := 0.0
	while mg.phase != "attente" and t < 5.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	vues["gazette"] = int(vues.get("gazette", 0)) + 1
	if modales.genre_courant != "gazette" or mg.phase != "attente":
		ecarts_genre.append("gazette : affichée comme « %s »" % modales.genre_courant)
		return
	var ab := e.ab_courant()
	var ids: Array = mg.barres_vues.map(func(b: Dictionary) -> String: return str(b["id"]))
	var vals: Array = mg.barres_vues.map(func(b: Dictionary) -> String: return str(b["valeur_txt"]))
	var attendues: Array = c["barres"].map(func(b: Dictionary) -> String: return Format.entier(float(b["valeur"]), ab))
	var choisies: int = c["barres"].filter(func(b: Dictionary) -> bool: return bool(b["choisi"])).size()
	if ids != ["vendu", "rien", "renforce"] or vals != attendues or mg.n_entourees != choisies or mg.n_entourees > 1:
		ecarts_choix.append("gazette : barres %s %s (entourées %d / %d)" % [str(ids), str(vals), mg.n_entourees, choisies])
	_recu.clear()
	await _touche(KEY_ESCAPE)
	if not _recu.is_empty() or modales.genre_courant != "gazette":
		ecarts_choix.append("gazette : Échap a fermé la fiche")
	await _touche(KEY_1)
	var r: Array = _recu.pop_back() if not _recu.is_empty() else []
	if r != ["gazette", "ok"]:
		ecarts_choix.append("gazette : choix_fait %s" % str(r))
	var res := e.resoudre_modale("ok")
	if res.is_empty():
		ecarts_choix.append("gazette : résolution refusée")
	modales.conclure_gazette(res, Vector2(960, 400))
	await modales.carte_rangee
	_gazettes_vues += 1
	hud.maj(e, false)


## Carte ou projet ouvert : le moteur refuse les ordres débiteurs (« Réglez d'abord la carte du foyer. ») et l'interface dit la même phrase.
func _verifier_ordres_bloques(e: EtatPartie, ecarts: Array, titre: String) -> void:
	var cc0 := e.joueur.cc
	var r0 := e.acheter(e.joueur, "elf", Produits.f(500.0))
	if not e.ordres_bloques() or r0.get("ok", true) or str(r0.get("msg", "")) != Hud.PHRASE_BANQUE_FERMEE or str(r0.get("refus", "")) != "carte" or e.joueur.cc != cc0:
		ecarts.append("%s : ordres_bloques()=%s, achat %s" % [titre, str(e.ordres_bloques()), str(r0)])
	else:
		_ordres_refuses += 1


## Projet du foyer joué comme la séquence de la ville : Modales.projet, choix, confirmation éventuelle, résolution, conclusion.
## Vérifie sur le vrai moteur : le choix fixe projet_en_cours()["id"], les ventes faites égalent le plan, le compte ne passe pas sous 0.
func _afficher_projet(e: EtatPartie, c: Dictionary, choix: String, vues: Dictionary, ecarts_genre: Array, ecarts_choix: Array) -> void:
	var titre := str(c.get("titre", ""))
	var pos := Vector2(960, 400)
	modales.projet(c, pos)
	var mp := modales.etat_projet()
	var t := 0.0
	while mp.phase != "attente" and t < 5.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	vues["projet"] = int(vues.get("projet", 0)) + 1
	if modales.genre_courant != "projet" or mp.phase != "attente":
		ecarts_genre.append("%s : « %s » affiché comme « %s »" % [Dates.texte_court(e.ab_courant()), titre, modales.genre_courant])
		return
	var plan: Array = e.plan_vente_projet() if str(c.get("etape", "")) == "echeance" else []
	if str(c.get("etape", "")) == "choix":
		for ch: Dictionary in c["choix"]:
			if str(ch["id"]) == "P2B" and absf(float(ch["montant"]) - Produits.f(35000.0)) > 0.01:
				ecarts_choix.append("P2B à %s au lieu de 35 000 F" % str(ch["montant"]))
	_recu.clear()
	mp.choisir(choix)
	if mp.en_confirmation:
		var noms: Array = modales.courant.find_children("NomVente", "Label", true, false).map(func(l: Node) -> String: return (l as Label).text)
		var attendus: Array = []
		for i in plan.size():
			attendus.append("%d  %s" % [i + 1, str(plan[i]["nom"])])
		if noms != attendus or not _recu.is_empty():
			ecarts_choix.append("%s : confirmation %s au lieu du plan %s" % [titre, str(noms), str(attendus)])
		mp.choisir_rang(0)
	var r: Array = _recu.pop_back() if not _recu.is_empty() else []
	if r != ["projet", choix]:
		ecarts_choix.append("%s : choix_fait %s au lieu de %s" % [titre, str(r), str(["projet", choix])])
	var res := e.resoudre_modale(choix)
	if res.is_empty() or str(res.get("choix", "")) != choix:
		ecarts_choix.append("%s : résolution %s" % [titre, str(res)])
		return
	if str(c.get("etape", "")) == "choix":
		var pe := e.projet_en_cours()
		if str(pe.get("id", "")) != choix:
			ecarts_choix.append("%s : projet_en_cours()[id] = %s au lieu de %s" % [titre, str(pe.get("id", "")), choix])
		else:
			_projets_choisis += 1
	elif choix == "realiser_en_vendant":
		var faites: Array = res.get("ventes", [])
		var ok_plan := faites.size() == plan.size()
		for i in mini(faites.size(), plan.size()):
			ok_plan = ok_plan and str(faites[i].get("id", "")) == str(plan[i].get("id", "")) and absf(float(faites[i].get("net", 0.0)) - float(plan[i].get("net", 0.0))) < 0.5
		if not ok_plan or e.joueur.cc < -0.01:
			ecarts_choix.append("%s : ventes faites %s != plan %s (compte %s)" % [titre, str(faites.size()), str(plan.size()), str(e.joueur.cc)])
		else:
			_ventes_conformes += 1
	modales.conclure_projet(res, pos)
	t = 0.0
	while mp.phase != "conclusion" and t < 3.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	var lq := modales.courant.find_child("Consequence", true, false) as Label if modales.courant != null else null
	if lq != null and str(res.get("consequence", "")) != "" and lq.text != str(res["consequence"]):
		ecarts_choix.append("%s : conséquence affichée « %s »" % [titre, lq.text])
	mp.passer()
	await modales.carte_rangee
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
		var lg := modales.courant.find_child("LigneProjetGuichet", true, false) as Label
		var attendu_g := e.ligne_projet_guichet()
		if lg == null or (lg.text if lg.visible else "") != attendu_g:
			ok = false
			vus.append("%s KO (ligne du guichet « %s » au lieu de « %s »)" % [pid, lg.text if lg != null else "?", attendu_g])
		elif attendu_g != "":
			_guichets_vus += 1
		# Lot 03 (I6) : ligne des dividendes, seulement pour une action, d'après la logique
		var ld := droite.find_child("Dividendes", true, false) as Label
		var attendu := ""
		if e.mois_dividende(pid) > 0:
			# 03-R : le texte de la fiche est écrit par la logique (Banquier.texte_fiche_dividende, CA-I7)
			attendu = Banquier.texte_fiche_dividende(e, pid)
		var lu := ld.text if ld != null else ""
		if lu != attendu:
			ok = false
			vus.append("%s KO (dividendes « %s » au lieu de « %s »)" % [pid, lu, attendu])
		elif attendu != "":
			var cle_div := "reçus" if attendu.begins_with("Dividendes reçus") else "versé"
			_div_vus[cle_div] = int(_div_vus.get(cle_div, 0)) + 1
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


## Fenêtre de confirmation du saut (0.5.1) : case, AVANCER, ANNULER, Échap ; la préférence ne s'écrit jamais en test.
func _verifier_confirmation_saut() -> void:
	var recu: Array = []
	var c := ConfirmationSaut.new()
	add_child(c)
	c.valide.connect(func(ne_plus: bool) -> void: recu.append("valide:%s" % ne_plus))
	c.annule.connect(func() -> void: recu.append("annule"))
	c.cocher(true)
	c.b_avancer.pressed.emit()
	c.b_avancer.pressed.emit()   # un seul signal malgré le double appui
	_verifier("Confirmation du saut : AVANCER avec la case cochée émet valide(true), une seule fois", recu == ["valide:true"], str(recu))
	c.queue_free()
	recu.clear()
	var c2 := ConfirmationSaut.new()
	add_child(c2)
	c2.valide.connect(func(ne_plus: bool) -> void: recu.append("valide:%s" % ne_plus))
	c2.annule.connect(func() -> void: recu.append("annule"))
	var esc := InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	c2._input(esc)
	_verifier("Confirmation du saut : Échap = ANNULER, sans lancer le saut", recu == ["annule"], str(recu))
	c2.queue_free()
	_verifier("Confirmation du saut : en test, la préférence locale n'est jamais lue (pas de fenêtre) ni écrite", not Reglages.confirmation_a_montrer("saut"))
	var avant := FileAccess.get_modified_time(Reglages.PREFERENCES)
	Reglages.ne_plus_confirmer("saut")
	_verifier("Confirmation du saut : ne_plus_confirmer sans écran n'écrit rien", FileAccess.get_modified_time(Reglages.PREFERENCES) == avant and not Reglages.confirmation_a_montrer("saut"))
	_verifier("Conclusion d'une carte ou d'un projet : ligne de conséquence 0,8 s au plus", ModaleCarte.DUREE_CONSEQUENCE <= 0.8, str(ModaleCarte.DUREE_CONSEQUENCE))


## Pop-up de début de partie : jamais en test (option --intro absente) ; ouverte à la main, elle se ferme par Entrée.
func _verifier_intro() -> void:
	_verifier("Intro : jamais affichée en test sans l'option --intro", not Reglages.intro_a_montrer())
	var recu: Array = []
	var cb := func(g: String, id: String) -> void: recu.append("%s:%s" % [g, id])
	modales.choix_fait.connect(cb)
	var ei := EtatPartie.new()
	ei.demarrer(Donnees.config_demo(1))
	var tx := ModaleIntro.textes(ei)
	_verifier("Intro : gabarits {salaire} et {depart} remplis depuis les données (" + str(tx["blocs"][0]["texte"]).substr(0, 0) + "salaire 6 790 F, départ 11 000 F)", str(tx["blocs"][0]["texte"]).contains(Format.montant(ei.salaire_base, ei.ab_courant())) and str(tx["blocs"][0]["texte"]).contains("11" + String.chr(160) + "000") and not str(tx["blocs"][0]["texte"]).contains("{"), str(tx["blocs"][0]["texte"]))
	modales.intro(ei)
	var ok := await _attendre_genre("intro")
	await _touche(KEY_ENTER)
	await get_tree().create_timer(0.5).timeout
	modales.choix_fait.disconnect(cb)
	_verifier("Intro : la fenêtre s'ouvre (%d blocs) et Entrée émet commencer" % int(modales.etat_intro().infos.get("blocs", 0)), ok and recu == ["intro:commencer"] and int(modales.etat_intro().infos.get("blocs", 0)) >= 3, str(recu))


## Historique : chaque filtre, puis 5 entrées relues comme Modales.relire_historique.
func _verifier_historique(e: EtatPartie, nom: String) -> void:
	var filtres_ok := true
	var detail := ""
	_verifier_confirmation_saut()
	await _verifier_intro()
	for f in ["", "maison", "banque", "media"]:
		modales.historique(e, f, 0)
		var ok := await _attendre_genre("historique")
		ok = ok and modales.historique_filtre == f
		# Recette R-RUE A1 : le nombre de chaque onglet est entier et visible (texte non coupé)
		for bt: Button in modales.find_children("Filtre_*", "Button", true, false):
			var police: Font = bt.get_theme_font("font")
			var largeur := police.get_string_size(bt.text, HORIZONTAL_ALIGNMENT_LEFT, -1, bt.get_theme_font_size("font_size")).x
			var place := bt.size.x - 30.0 - (bt.icon.get_width() + 9.0 if bt.icon != null else 0.0)
			if largeur > place or not bt.text.split(" ")[-1].is_valid_int():
				ok = false
				detail += "onglet coupé %s (%d > %d) ; " % [bt.text, int(largeur), int(place)]
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
