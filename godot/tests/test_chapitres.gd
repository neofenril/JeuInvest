extends Node
## Lot 09-L, L8 : socle des chapitres (données par chapitre, chapitre actif, fin de partie, décor par date, export,
## sauvegardes de main, fenêtre de marché, salaires 2022-2025) et MESURE debut_libre.
## Scène : l'autoload Partie relaie le signal chapitre_change. Tout est synchrone dans _ready.
## Lancer : Godot_console.exe --headless --path godot res://tests/test_chapitres.tscn
## Jeu d'essai : res://tests/donnees/chapitres (chapitres « 1984 » et « 1989 »), jamais res://data/chapitres.

const RACINE_REELLE := "res://data/chapitres"
const RACINE_ESSAI := "res://tests/donnees/chapitres"
const SAUVEGARDES := "res://tests/donnees/sauvegardes"

## Sauvegardes écrites par main (b76a922 + test_reference_1984) : graine 7, cartes / projets / rue allumés, joueur actif ;
## fin de la partie reprise et jouée jusqu'au bout (résolution automatique des modales). Chiffres produits par main.
const SAUVEGARDES_MAIN := {
	"0686": "date=1986-06 fin=fin patrimoine=18987.54215522 frais=122.12299452 impots=5.20695408 interruptions=26 historique=84 md5=e39529eee9c30b55475c19ef44ce4472",
	"1087": "date=1987-10 fin=fin patrimoine=17379.41877421 frais=122.12299452 impots=10.46605823 interruptions=27 historique=83 md5=6d5bb60a456fd96817eaab6576574f7f",
	"0688": "date=1988-06 fin=fin patrimoine=17584.75903783 frais=119.21486975 impots=17.58231861 interruptions=27 historique=77 md5=738fa8cfda229ff8b24e1aea14bda3ce",
}

var _ok := 0
var _ko := 0
var _emissions: Array = []


func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_resolution()
	_tests_cache()
	_tests_index()
	_tests_config()
	_tests_bascule()
	_tests_sauvegarde()
	_tests_export()
	_tests_marche()
	_tests_salaires()
	_mesure_debut_libre()
	_restaurer()
	print("")
	print("=== test_chapitres : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	get_tree().quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _restaurer() -> void:
	Donnees.racine_chapitres = RACINE_REELLE
	Donnees.regler_chapitre("")
	Donnees.vider_cache()
	StrategieTest.politique_cartes = "epargner"


func _essai() -> void:
	Donnees.racine_chapitres = RACINE_ESSAI
	Donnees.regler_chapitre("")
	Donnees.vider_cache()


func _reel() -> void:
	_restaurer()


func _json(chemin: String) -> Dictionary:
	var f := FileAccess.open(chemin, FileAccess.READ)
	var d: Variant = JSON.parse_string(f.get_as_text())
	return d if d is Dictionary else {}


# ---------------------------------------------------------------------

func _tests_resolution() -> void:
	_reel()
	var banque := Donnees.charger("banque")
	verifier("Résolution : « banque » vient du chapitre 1984", str(banque) == str(_json(RACINE_REELLE + "/1984/banque.json")) and not banque.is_empty())
	verifier("Résolution : « series » vient du monde (res://data)", str(Donnees.charger("series")) == str(_json("res://data/series.json")) and not Donnees.series().is_empty())
	verifier("Résolution : salaires, regles, rythme, periode_p1 viennent du monde",
		not Donnees.salaires().is_empty() and not Donnees.regles().is_empty() and not Donnees.charger("rythme").is_empty() and not Donnees.periode("P1").is_empty())
	verifier("Alias « demo » = « chapitre » (même dictionnaire)", Donnees.charger("demo") == Donnees.charger("chapitre") and Donnees.charger("demo").has("config"))
	verifier("chapitre.json porte l'id du chapitre", str(Donnees.charger("chapitre").get("id", "")) == "1984")
	verifier("infos_chapitre() = chapitre actif ; infos_chapitre(\"1984\") idem", Donnees.infos_chapitre() == Donnees.infos_chapitre("1984") and str(Donnees.infos_chapitre()["banquier"]["nom"]) == "M. LEFRANC")
	_essai()
	verifier("Jeu d'essai : le chapitre par défaut est 1984 (index)", str(Donnees.infos_chapitre()["banquier"]["nom"]) == "M. ESSAI-1984")
	verifier("Jeu d'essai : un fichier absent du chapitre se lit dans le monde (rythme)", not Donnees.charger("rythme").is_empty())
	_reel()


func _tests_cache() -> void:
	_essai()
	Donnees.regler_chapitre("1984")
	var a := str(Donnees.charger("chapitre")["banquier"]["nom"])
	Donnees.regler_chapitre("1989")
	var b := str(Donnees.charger("chapitre")["banquier"]["nom"])
	var titres_b: Dictionary = Donnees.charger("titres")
	Donnees.regler_chapitre("1984")
	var a2 := str(Donnees.charger("chapitre")["banquier"]["nom"])
	verifier("Cache par chapitre : deux chapitres, même nom de fichier, contenus différents", a == "M. ESSAI-1984" and b == "M. ESSAI-1989" and a2 == a, "%s / %s / %s" % [a, b, a2])
	Donnees.regler_chapitre("1989")
	verifier("Cache par chapitre : le contenu 1989 reste en cache sans mélange", Donnees.charger("titres") == titres_b and str(Donnees.charger("chapitre")["id"]) == "1989")
	_reel()


func _tests_index() -> void:
	_reel()
	var tous := Donnees.chapitres(true)
	verifier("chapitres() : un seul chapitre réel, ouvert", Donnees.chapitres().size() == 1 and tous.size() == 1 and str(Donnees.chapitres()[0]["id"]) == "1984" and str(Donnees.chapitres()[0]["marche"]) == "P1")
	verifier("premiere_annee = 1977 ; derniere_annee = 1988", Donnees.premiere_annee() == 1977 and Donnees.derniere_annee() == 1988)
	verifier("chapitre_de aux bornes : 1983-12 vide, 1984-01 et 1988-12 = 1984, 1989-01 vide",
		Donnees.chapitre_de(Dates.lire("1983-12")) == "" and Donnees.chapitre_de(Dates.lire("1984-01")) == "1984"
		and Donnees.chapitre_de(Dates.lire("1988-12")) == "1984" and Donnees.chapitre_de(Dates.lire("1989-01")) == "")
	verifier("theme_a : « 1980 » à toute date (1977-01, 1984-01, 1988-12, 1989-01)",
		Donnees.theme_a(Dates.lire("1977-01")) == "1980" and Donnees.theme_a(Dates.lire("1984-01")) == "1980"
		and Donnees.theme_a(Dates.lire("1988-12")) == "1980" and Donnees.theme_a(Dates.lire("1989-01")) == "1980")
	_essai()
	verifier("Jeu d'essai ouvert : derniere_annee = 1993, chapitre_de(1989-01) = 1989, 1994-01 vide",
		Donnees.derniere_annee() == 1993 and Donnees.chapitre_de(Dates.lire("1989-01")) == "1989" and Donnees.chapitre_de(Dates.lire("1994-01")) == "")
	verifier("Jeu d'essai : theme_a change au 1er janvier 1989",
		Donnees.theme_a(Dates.lire("1988-12")) == "1980" and Donnees.theme_a(Dates.lire("1989-01")) == "essai")
	var idx := Donnees.index()
	(idx["chapitres"][1] as Dictionary)["ouvert"] = false
	verifier("Chapitre fermé : jamais joué (derniere_annee = 1988, chapitre_de(1989-01) vide, chapitres() = 1, chapitres(true) = 2)",
		Donnees.derniere_annee() == 1988 and Donnees.chapitre_de(Dates.lire("1989-01")) == "" and Donnees.chapitres().size() == 1 and Donnees.chapitres(true).size() == 2)
	var c := Donnees.config_chapitre("1989", 3)
	verifier("Fin bornée par la dernière année ouverte (chapitre 1989 fermé : fin 1988-12)", str(c["fin"]) == "1988-12", str(c["fin"]))
	(idx["chapitres"][1] as Dictionary)["ouvert"] = true
	verifier("Chapitre rouvert : fin 1993-12 conservée", str(Donnees.config_chapitre("1989", 3)["fin"]) == "1993-12")
	_reel()


## Copie figée de l'ancienne Donnees.config_demo(g) (avant le lot 09).
func _ancienne_config_demo(g: int) -> Dictionary:
	return {"periode": "P1", "profil": "technicien", "debut": "1984-01", "fin": "1988-12", "banquier": true, "naissances_aleatoires": false,
		"graine_vie": g, "naissance": {"d": "1985-04", "jumeaux_proba": 0.25},
		"cc_depart": 11000.0 / Format.TAUX_EURO, "livret_depart": 0.0 / Format.TAUX_EURO}


func _tests_config() -> void:
	_reel()
	var ok := true
	for g in [1, 7, 11, 40]:
		var nouvelle := Donnees.config_chapitre("1984", g)
		var chap: Variant = nouvelle.get("chapitre", "")
		nouvelle.erase("chapitre")
		ok = ok and var_to_str(nouvelle) == var_to_str(_ancienne_config_demo(g)) and str(chap) == "1984" and var_to_str(Donnees.config_demo(g)) == var_to_str(Donnees.config_chapitre("1984", g))
	verifier("config_chapitre(\"1984\", g) = ancienne config_demo(g) (+ « chapitre ») ; config_demo = alias", ok)
	verifier("config_demo(-1) : graine de test du chapitre (11)", int(Donnees.config_demo(-1)["graine_vie"]) == 11)


func _jouer(e: EtatPartie) -> void:
	var garde := 0
	while e.fin == "" and garde < 400:
		garde += 1
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()


func _config_essai(debut: String, fin: String, g := 3) -> Dictionary:
	var c := Donnees.config_chapitre("1984", g)
	c["debut"] = debut
	c["fin"] = fin
	return c


func _sur_signal(ancien: String, nouveau: String, e: EtatPartie) -> void:
	_emissions.append([ancien, nouveau, e.ab_courant()])


func _tests_bascule() -> void:
	_essai()
	var e := EtatPartie.new()
	_emissions = []
	e.chapitre_change.connect(func(a: String, n: String) -> void: _sur_signal(a, n, e))
	e.demarrer(_config_essai("1988-07", "1989-06"))
	verifier("Bascule : départ en 1988-07 dans le chapitre 1984 (fin de partie à 1989-06, avant derniere_annee = 1993)",
		e.chapitre == "1984" and Donnees.chapitre == "1984" and e.m_fin == Dates.lire("1989-06") - e.mk.ab_debut)
	var avant_janvier := true
	while e.fin == "":
		while not e.modale.is_empty():
			e.resolution_auto()
		if e.ab_courant() == Dates.lire("1988-12"):
			avant_janvier = e.chapitre == "1984" and _emissions.is_empty()
		e.avancer()
	verifier("Bascule : jusqu'en décembre 1988, chapitre 1984 et aucun signal", avant_janvier)
	verifier("Bascule : chapitre_change émis une fois, 1984 -> 1989, en janvier 1989", _emissions.size() == 1 and _emissions[0][0] == "1984" and _emissions[0][1] == "1989" and _emissions[0][2] == Dates.lire("1989-01"), str(_emissions))
	verifier("Bascule : chapitre actif 1989 à la fin, fichier du nouveau chapitre lu", e.chapitre == "1989" and Donnees.chapitre == "1989" and str(Donnees.infos_chapitre()["banquier"]["nom"]) == "M. ESSAI-1989" and e.fin == "fin")
	# Relais par l'autoload Partie
	_essai()
	var recu: Array = []
	Partie.chapitre_change.connect(func(a: String, n: String) -> void: recu.append([a, n]))
	Partie.nouvelle_partie(_config_essai("1988-11", "1989-03"))
	Partie.sauter_jusqu_a(Partie.etat.m_fin, true)
	verifier("Partie.chapitre_change relaie le signal du moteur (une fois)", recu.size() == 1 and recu[0] == ["1984", "1989"], str(recu))
	# Données réelles : jamais d'émission
	_reel()
	var r := EtatPartie.new()
	var n_reel := [0]
	r.chapitre_change.connect(func(_a: String, _n: String) -> void: n_reel[0] += 1)
	r.demarrer(Donnees.config_demo(7))
	_jouer(r)
	verifier("Données réelles : aucune bascule en 1984-1988, fin en 1988-12", n_reel[0] == 0 and r.chapitre == "1984" and r.fin == "fin" and Dates.annee(r.ab_courant()) == 1988 and Dates.mois(r.ab_courant()) == 12)
	# Fin bornée à la dernière année par config_chapitre (config.fin au-delà)
	var c := Donnees.config_chapitre("1984", 7)
	c["fin"] = "1992-12"
	var e2 := EtatPartie.new()
	e2.demarrer(c)
	verifier("Fin de partie = min(config.fin, décembre de derniere_annee) pour une partie par chapitres", e2.m_fin == Dates.lire("1988-12") - e2.mk.ab_debut)
	var b := Bilan.calculer(r)
	verifier("Bilan : chapitre_depart, annee_depart, annee_fin", b["chapitre_depart"] == "1984" and b["annee_depart"] == 1984 and b["annee_fin"] == 1988, "%s %d %d" % [b["chapitre_depart"], b["annee_depart"], b["annee_fin"]])
	Partie.etat = null


func _tests_sauvegarde() -> void:
	# Sauvegarde écrite par la branche : relue avec le chapitre de départ « 1984 », chapitre actif recalculé depuis la date.
	_reel()
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(7))
	StrategieTest.aller_a(e, Dates.lire("1986-06"), true)
	var chemin := "user://test_chapitres_%d.sav" % OS.get_process_id()
	Sauvegarde.ecrire(e, {"id_partie": "essai"}, chemin)
	var d := Sauvegarde.lire(chemin)
	Sauvegarde.effacer(chemin)
	var e2 := Sauvegarde.charger(d)
	verifier("Sauvegarde de la branche : relue avec chapitre « 1984 » (départ et actif)", e2 != null and e2.chapitre == "1984" and str(e2.config_depart["chapitre"]) == "1984")
	var d2: Dictionary = d["etat"].duplicate(true)
	(d2["config"] as Dictionary).erase("chapitre")
	var e3 := EtatPartie.depuis_dict(d2)
	verifier("Migration D7 : « chapitre » absent de config_depart = chapitre 1984", e3 != null and e3.chapitre == "1984")
	# Reprise à travers une bascule (jeu d'essai) : chapitre actif recalculé depuis la date
	_essai()
	var f := EtatPartie.new()
	f.demarrer(_config_essai("1988-10", "1989-12"))
	StrategieTest.aller_a(f, Dates.lire("1989-02"), true)
	var df := f.vers_dict()
	_essai()   # une partie lancée ailleurs a pu laisser un autre chapitre actif
	Donnees.regler_chapitre("1984")
	var f2 := EtatPartie.depuis_dict(df)
	verifier("Reprise après la bascule : chapitre actif recalculé depuis la date (1989), données du chapitre 1989", f2 != null and f2.chapitre == "1989" and Donnees.chapitre == "1989" and not df.has("chapitre"))
	_reel()
	# Sauvegardes écrites par main : mêmes chiffres jusqu'à la fin
	for cle: String in SAUVEGARDES_MAIN:
		var d3 := Sauvegarde.lire("%s/sauvegarde_main_%s.sav" % [SAUVEGARDES, cle])
		var g := Sauvegarde.charger(d3)
		if g == null:
			verifier("Sauvegarde de main %s relue" % cle, false)
			continue
		var depart := Dates.texte(g.ab_courant())
		var date := "%d-%02d" % [Dates.annee(g.ab_courant()), Dates.mois(g.ab_courant())]
		_jouer(g)
		var attendu: String = SAUVEGARDES_MAIN[cle]
		var obtenu := _ligne(g, date)
		verifier("Sauvegarde de main %s (%s) : mêmes chiffres que main jusqu'à la fin, chapitre 1984" % [cle, depart], obtenu == attendu and g.chapitre == "1984", "obtenu : %s" % obtenu)


func _ligne(e: EtatPartie, date: String) -> String:
	var textes := ""
	for h: Dictionary in e.historique:
		textes += "%d|%s|%s|%s\n" % [int(h.get("m", 0)), str(h.get("type", "")), str(h.get("titre", "")), str(h.get("resume", ""))]
	return "date=%s fin=%s patrimoine=%.8f frais=%.8f impots=%.8f interruptions=%d historique=%d md5=%s" % [date, e.fin,
		e.patrimoine(e.joueur), float(e.stats["frais"]), float(e.stats["impots"]), (e.banque["interruptions_liste"] as Array).size(),
		e.historique.size(), textes.md5_text()]


func _tests_export() -> void:
	var f := FileAccess.open("res://export_presets.cfg", FileAccess.READ)
	var nb := 0
	var bons := 0
	if f != null:
		for l in f.get_as_text().split("\n"):
			if l.begins_with("include_filter="):
				nb += 1
				if l.contains("data/chapitres/*/*.json") and l.contains("data/chapitres/*.json") and l.contains("data/themes/*.json") and l.contains("data/*.json") and l.contains("data/pixel/*/*.txt"):
					bons += 1
	verifier("Export : les deux préréglages incluent data/chapitres/*/*.json, data/themes/*.json (piège H18)", nb == 2 and bons == 2, "%d include_filter, %d complets" % [nb, bons])


func _tests_marche() -> void:
	_reel()
	var mk := Marche.pour_periode("P1")
	verifier("Marche P1 : fenêtre lue dans periode_p1.json (193 cases, 192 mois, fin 1993 depuis le lot 10a)", mk.n_cases == 193 and mk.nb_mois() == 192 and mk.indice.size() == 193 and (mk.prix["elf"] as PackedFloat64Array).size() == 193)
	var p := Donnees.periode("P1").duplicate(true)
	p.erase("fin")
	var sans := Marche.new(p)
	verifier("Marche sans champ « fin » : 15 ans par défaut (mêmes tirages que P1)", sans.n_cases == 181 and sans.indice.slice(0, 181) == mk.indice.slice(0, 181))
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(7))
	verifier("hist dimensionné sur la fenêtre (192) ; limite d'historique HISTORIQUE_MAX = 1200", (e.hist["j"] as Array).size() == 192 and EtatPartie.HISTORIQUE_MAX == 1200)
	p["fin"] = 1993
	var long := Marche.new(p)
	var sain := long.n_cases == 193 and long.nb_mois() == 192
	for k in long.n_cases:
		if is_nan(long.indice[k]) or long.indice[k] <= 0.0:
			sain = false
	verifier("Marche d'essai sur 16 ans (fin 1993) : 193 cases, indice sain", sain, "%d cases" % long.n_cases)


func _tests_salaires() -> void:
	_reel()
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(7))
	verifier("Salaires : valeur_table(technicien, 2023) = 2530, 2025 = 2700, smn 2025 = 2870",
		is_equal_approx(e.valeur_table("technicien", 2023), 2530.0) and is_equal_approx(e.valeur_table("technicien", 2025), 2700.0) and is_equal_approx(e.valeur_table("smn", 2025), 2870.0))
	var t := {}
	for r: Dictionary in e.sal["table"]:
		t[int(r["annee"])] = r
	verifier("Ligne 2023 conforme à D10", t.has(2023) and int(t[2023]["smn"]) == 2735 and int(t[2023]["jeune"]) == 1480 and int(t[2023]["cadre"]) == 4550 and int(t[2023]["heritier"]) == 2400 and int(t[2023]["capital"]) == 47000)
	verifier("Ligne 2025 corrigée conforme à D10", int(t[2025]["jeune"]) == 1610 and int(t[2025]["cadre"]) == 4890 and int(t[2025]["heritier"]) == 2600 and int(t[2025]["capital"]) == 52000)
	var ep := func(a: int, pr: String) -> int: return int(e._params_depenses(a)["epargne"][pr])
	verifier("Dépenses : épargne du technicien 2021 = 18, 2022 = 16, 2023 = 16, 2024 = 18",
		ep.call(2021, "technicien") == 18 and ep.call(2022, "technicien") == 16 and ep.call(2023, "technicien") == 16 and ep.call(2024, "technicien") == 18)
	verifier("Dépenses 2022 = 2010 moins 2 points pour chaque profil ; 2024 = 2010",
		ep.call(2022, "jeune") == 4 and ep.call(2022, "cadre") == 13 and ep.call(2022, "heritier") == 10 and ep.call(2024, "jeune") == 6 and ep.call(2024, "cadre") == 15 and ep.call(2024, "heritier") == 12)


## Mesure non bloquante : une partie démarrée librement en 1986-01 avec cartes, projets et rue allumés (lot 13, saisie d'une année).
func _mesure_debut_libre() -> void:
	_reel()
	var nb := 20
	var finies := 0
	var cartes := 0
	var naissances := 0
	var etats := {}
	var jean := 0
	for g in range(1, nb + 1):
		StrategieTest.politique_cartes = "alterner"
		var c := Donnees.config_demo(g)
		c["debut"] = "1986-01"
		c["cartes"] = true
		c["projets"] = true
		c["rue"] = true
		var e := EtatPartie.new()
		e.demarrer(c)
		var garde := 0
		while e.fin == "" and garde < 400:
			garde += 1
			StrategieTest.jouer_mois(e, true)
			if not e.modale.is_empty():
				e.resolution_auto()
			e.avancer()
		if e.fin == "fin":
			finies += 1
		cartes += (e.foyer.get("jouees", []) as Array).size()
		if e.enfants > 0:
			naissances += 1
		for pid: String in e.projets.get("projets", {}):
			var et := str(e.projets["projets"][pid]["etat"])
			etats[et] = int(etats.get(et, 0)) + 1
		if not e.classement_rue().is_empty():
			jean += 1
	StrategieTest.politique_cartes = "epargner"
	print("MESURE debut_libre : %d parties de 1986-01 à 1988-12 (cartes, projets, rue allumés) : terminées %d / %d ; cartes jouées en moyenne %.1f (8 à 10 sur 1984-1988) ; naissance scriptée d'avril 1985 sautée : enfants dans %d parties ; projets par état %s ; rue visible dans %d parties" % [nb, finies, nb, float(cartes) / nb, naissances, str(etats), jean])
