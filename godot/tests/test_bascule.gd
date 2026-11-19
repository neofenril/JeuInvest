extends SceneTree
## Lot 10a-moteur, M0 / CA-M4 : bascule de chapitre sur le jeu d'essai (tests/donnees/chapitres : chapitres « 1984 » et
## « 1989 », tous deux ouverts ; le second est un clone du premier avec une carte de passage).
## Une partie 1984-01 -> 1989-12 : chapitre_change émis une fois, AVANT la modale « passage » ; état conservé à travers la
## bascule (humeur, projets, Jean-Mi, banque, effets de salaire) ; un titre par chapitre ; bilan["titre"] = titre du dernier
## chapitre ; records de chapitre et de partie ; chapitres_bilan sauvegardé ; mesure de la taille de l'historique.

const RACINE_REELLE := "res://data/chapitres"
const RACINE_ESSAI := "res://tests/donnees/chapitres"

var _ok := 0
var _ko := 0
var _journal: Array = []


func _initialize() -> void:
	Donnees.racine_chapitres = RACINE_ESSAI
	Donnees.regler_chapitre("")
	Donnees.vider_cache()
	var e := EtatPartie.new()
	e.chapitre_change.connect(func(a: String, n: String) -> void: _journal.append(["signal", a, n, e.ab_courant(), str(e.modale.get("kind", ""))]))
	var cfg := Donnees.config_chapitre("1984", 3, "1989-12")
	cfg["banquier"] = true
	cfg["rue"] = true
	e.demarrer(cfg)
	var avant := {}
	var apres := {}
	var passage := {}
	var garde := 0
	while e.fin == "" and garde < 400:
		garde += 1
		while not e.modale.is_empty():
			if str(e.modale.get("kind", "")) == "passage":
				passage = e.contenu_modale()
				_journal.append(["passage", e.ab_courant()])
			e.resolution_auto()
		if e.ab_courant() == Dates.lire("1988-12"):
			avant = _etat(e)
		if e.ab_courant() == Dates.lire("1989-01") and apres.is_empty():
			apres = _etat(e)
		e.avancer()
	verifier("Partie 1984-01 -> 1989-12 sans erreur, menée à son terme", e.fin == "fin" and e.chapitre == "1989")
	var signaux := _journal.filter(func(x: Array) -> bool: return x[0] == "signal")
	verifier("chapitre_change émis une fois (1984 -> 1989), en janvier 1989", signaux.size() == 1 and signaux[0][1] == "1984" and signaux[0][2] == "1989" and signaux[0][3] == Dates.lire("1989-01"), str(_journal))
	verifier("chapitre_change AVANT la modale « passage » (modale vide à l'émission, passage résolu ensuite en 1989-01)",
		signaux[0][4] == "" and _journal.size() >= 2 and _journal[0][0] == "signal" and _journal[1][0] == "passage" and _journal[1][1] == Dates.lire("1989-01"), str(_journal))
	verifier("Carte de passage : annee, chapitre, nom, patrimoine, écart, rang, texte, fin_partie, choix « continuer »",
		passage.get("kind", "") == "passage" and int(passage["annee"]) == 1989 and passage["chapitre"] == "1989" and passage["nom_chapitre"] == "Essai deux"
		and float(passage["patrimoine"]) > 0.0 and passage.has("ecart_tata_pct") and passage.has("rang") and passage["fin_partie"] == "1993-12"
		and passage["choix"] == [{"id": "continuer", "titre": "CONTINUER"}], str(passage))
	verifier("Texte de passage rendu par Gabarits (aucun jeton résiduel) : « Gérard, la suite : Sylvie et vous. »", passage["texte_attente"] == "Gérard, la suite : Sylvie et vous.", str(passage.get("texte_attente", "")))
	verifier("État conservé à travers la bascule : humeur, projets, Jean-Mi (dette), produits vus par la banque, effets de salaire",
		avant["humeur"] == apres["humeur"] and avant["projets"] == apres["projets"] and float(apres["dette_jeanmi"]) > 0.0 and float(apres["dette_jeanmi"]) <= float(avant["dette_jeanmi"])
		and avant["vus"] == apres["vus"] and avant["salaires"] == apres["salaires"], "%s / %s" % [str(avant), str(apres)])
	verifier("chapitres_traverses() = [1984, 1989] ; chapitre_depart = 1984", e.chapitres_traverses() == ["1984", "1989"] and e.chapitre_depart == "1984")
	verifier("chapitres_bilan : le chapitre 1984 est terminé avec son titre, son écart et son année de fin (1988)",
		e.chapitres_bilan.has("1984") and e.chapitres_bilan["1984"]["titre"].has("id") and int(e.chapitres_bilan["1984"]["annee_fin"]) == 1988)
	var b := Bilan.calculer(e)
	verifier("Bilan : un titre par chapitre traversé (2), bilan[\"titre\"] = titre du dernier chapitre",
		b["titres"].size() == 2 and b["titres"][0]["chapitre"] == "1984" and b["titres"][1]["chapitre"] == "1989" and b["titre"]["id"] == b["titres"][1]["id"], str(b["titres"]))
	verifier("Bilan : record de chapitre = écart à la fin de 1988 ; record de partie = écart à la fin de 1989 ; chapitre_depart / annee_depart / annee_fin",
		is_equal_approx(float(b["record_chapitre"]["ecart_pct"]), float(e.chapitres_bilan["1984"]["ecart_pct"])) and int(b["record_chapitre"]["annee_fin"]) == 1988
		and is_equal_approx(float(b["record_partie"]["ecart_pct"]), float(b["ecart_tata_pct"])) and int(b["record_partie"]["annee_fin"]) == 1989
		and b["chapitre_depart"] == "1984" and int(b["annee_depart"]) == 1984 and int(b["annee_fin"]) == 1989 and not b["hors_record"])
	# Sauvegarde : chapitres_bilan relu
	var d := e.vers_dict()
	verifier("Sauvegarde : chapitres_bilan dans l'état sauvegardé", d.has("chapitres_bilan") and (d["chapitres_bilan"] as Dictionary).has("1984"))
	# Sauvegarde écrite en 1990 (jeu d'essai) puis relue : chapitre, produits vus, ventes différées, PEA, chapitres_bilan, version_contenu
	var chemin := "user://test_bascule_%d.sav" % OS.get_process_id()
	var h := EtatPartie.new()
	h.demarrer(Donnees.config_chapitre("1984", 3, "1990-12"))
	StrategieTest.aller_a(h, Dates.lire("1990-02"), true)
	h.joueur.cc = Produits.f(50000.0)
	h.acheter(h.joueur, "scpi", Produits.f(10000.0))
	h.vendre_scpi(3)
	h.ouvrir_pea()   # refusé : le PEA n'existe qu'à partir de 07/1992 (sauvegarde sans PEA)
	var ecrit := Sauvegarde.ecrire(h, {}, chemin)
	var lu := Sauvegarde.lire(chemin)
	var h2 := Sauvegarde.charger(lu) if not lu.is_empty() else null
	verifier("Sauvegarde 1990 relue : chapitre 1989, chapitres_bilan, ventes différées, parts de SCPI, produits vus, version_contenu",
		ecrit and h2 != null and h2.chapitre == "1989" and h2.chapitres_bilan.has("1984") and h2.ventes_differees().size() == 1 and int(Enveloppes.parts(h2.joueur)) == 10
		and h2.banque.get("presentes", {}) == h.banque.get("presentes", {}) and int(lu["etat"].get("version_contenu", 0)) == 1 and h2.chapitres_traverses() == ["1984", "1989"])
	Sauvegarde.effacer(chemin)
	# Taille de l'historique d'une partie de 6 ans (mesure pour HISTORIQUE_MAX)
	print("MESURE historique : %d entrées sur 72 mois (jeu d'essai, banquier et rue allumés)" % e.historique.size())
	verifier("HISTORIQUE_MAX (%d) couvre une partie de 10 ans (≈ %d entrées sur 6 ans, ×2 = %d, ×3 de marge)" % [EtatPartie.HISTORIQUE_MAX, e.historique.size(), e.historique.size() * 2], e.historique.size() * 2 * 3 < EtatPartie.HISTORIQUE_MAX)
	# Bascule des données : le nouveau chapitre est celui des données chargées
	verifier("Données du chapitre 1989 chargées après la bascule", Donnees.chapitre == "1989" and str(Donnees.infos_chapitre()["banquier"]["nom"]) == "M. ESSAI-1989")
	Donnees.racine_chapitres = RACINE_REELLE
	Donnees.regler_chapitre("")
	Donnees.vider_cache()
	print("")
	print("=== test_bascule : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func _etat(e: EtatPartie) -> Dictionary:
	return {"humeur": int(e.foyer.get("humeur", 0)), "projets": JSON.stringify((e.projets.get("projets", {}) as Dictionary).keys()),
		"dette_jeanmi": snappedf(float(e.jeanmi.get("dette", 0.0)), 0.001), "vus": JSON.stringify((e.banque.get("presentes", {}) as Dictionary).keys()).replace("1984:D08", "D08"),   # lot 10a bis : marqueurs rangés par chapitre
		"salaires": JSON.stringify(e.foyer.get("salaires", []))}


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
