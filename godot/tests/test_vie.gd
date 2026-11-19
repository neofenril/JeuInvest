extends SceneTree
## Lot 10a-moteur, CA-M7 : vie. Effets de salaire en liste (le CNAM de 1984 donne le même résultat ; deux effets cumulés ;
## « jusqua » rend le salaire exact), mariage selon l'âge et la situation (fréquence sur 400 graines dans ± 5 points des
## probabilités de docs/47 §4.1, fenêtre M9-M42, jamais dans les 9 mois après une naissance), jumeaux par chapitre
## (1/6 sur 600 naissances ancrées, ± 3 points), foyer_visuel(). Le bloc « mariage » est injecté dans le cache de données :
## le chapitre 1984 n'en a pas (aucun tirage de 1984 ne bouge, test_reference_1984).

var _ok := 0
var _ko := 0

const MARIAGE := {"table": [{"age_max": 29, "proba": 0.6}, {"age_max": 39, "proba": 0.7}, {"age_max": 49, "proba": 0.4}, {"age_max": 999, "proba": 0.2}],
	"fenetre": [9, 42], "vie_commune_ans": 2, "apres_naissance_mois": 9, "effet": "mariage", "titre": "Mariage",
	"texte": "Après {annees} ans ensemble, {conjoint} et vous avez dit oui.", "bouton": "OUI", "source": "maison", "picto": "mariage"}


func _config(g: int, age: int, proche := {"prenom": "Sylvie", "sexe": "f", "lien": "conjoint"}) -> Dictionary:
	var c := Donnees.config_demo(g)
	c["age"] = age
	c["proche"] = proche
	return c


func _initialize() -> void:
	# ---------- Effets de salaire ----------
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(3))
	var base := e.salaire_base
	Foyer.ajouter_effet_salaire(e, {"pct": 4.0, "des": "1984-03"})
	Foyer.ajouter_effet_salaire(e, {"pct": 10.0, "des_rel": 4})
	Foyer.ajuster_salaire(e)
	verifier("Effets de salaire : rien avant leur mois de départ", is_equal_approx(e.salaire_base, base))
	e.m = Dates.lire("1984-03") - e.mk.ab_debut
	Foyer.ajuster_salaire(e)
	verifier("Effet « des » : +4 % en 03/1984 (le CNAM de 1984 : même calcul qu'avant)", is_equal_approx(e.salaire_base, base * 1.04))
	e.m += 2
	Foyer.ajuster_salaire(e)
	Foyer.ajuster_salaire(e)
	verifier("Deux effets cumulés (+4 % puis +10 % « des_rel » 4 mois après la carte), chacun appliqué une seule fois", is_equal_approx(e.salaire_base, base * 1.04 * 1.10), str(e.salaire_base / base))
	var f := EtatPartie.new()
	f.demarrer(Donnees.config_demo(3))
	var b2 := f.salaire_base
	Foyer.ajouter_effet_salaire(f, {"pct": -30.0, "des": "1984-02", "jusqua": "1984-04"})
	var m0 := f.m_depart
	f.m = Dates.lire("1984-02") - f.mk.ab_debut
	Foyer.ajuster_salaire(f)
	var pendant := f.salaire_base
	f.m = Dates.lire("1984-04") - f.mk.ab_debut
	Foyer.ajuster_salaire(f)
	var dernier := f.salaire_base
	f.m = Dates.lire("1984-05") - f.mk.ab_debut
	Foyer.ajuster_salaire(f)
	m0 += 0
	verifier("« jusqua » : -30 % de 02/1984 à 04/1984 inclus, salaire exact rendu en 05/1984",
		is_equal_approx(pendant, b2 * 0.7) and is_equal_approx(dernier, b2 * 0.7) and is_equal_approx(f.salaire_base, b2), "%f / %f" % [f.salaire_base, b2])
	var g := EtatPartie.new()
	g.demarrer(Donnees.config_demo(3))
	g.foyer["salaire"] = {"pct": 4.0, "m_des": 48, "applique": false}   # ancien format (sauvegardes 0.6.x)
	var bg := g.salaire_base
	g.m = 48
	Foyer.ajuster_salaire(g)
	verifier("Ancien champ unique « salaire » toujours lu (migration douce)", is_equal_approx(g.salaire_base, bg * 1.04))

	# ---------- Mariage ----------
	var vie := Donnees.vie()
	var tranches := [[25, 0.6], [35, 0.7], [45, 0.4], [55, 0.2]]
	var vie_sans := not vie.has("mariage")
	vie["mariage"] = MARIAGE.duplicate(true)
	var detail := ""
	var tranches_ok := true
	var fenetre_ok := true
	for tr in tranches:
		var n := 0
		for graine in 400:
			var s := EtatPartie.new()
			s.demarrer(_config(graine, int(tr[0])))
			for ev in s.calendrier:
				if ev["type"] == "mariage":
					n += 1
					var rel: int = int(ev["m"]) - s.m_depart
					if rel < 9 or rel > 42:
						fenetre_ok = false
		var freq := float(n) / 400.0
		detail += "âge %d : %.3f (attendu %.2f) ; " % [tr[0], freq, tr[1]]
		if absf(freq - float(tr[1])) > 0.05:
			tranches_ok = false
	print("MARIAGE " + detail)
	verifier("Mariage : fréquence sur 400 graines dans ± 5 points de docs/47 §4.1 pour chaque tranche d'âge (60 / 70 / 40 / 20 %)", tranches_ok, detail)
	verifier("Mariage : toujours dans la fenêtre M9 à M42", fenetre_ok)
	var avec_marie := 0
	for graine in 40:
		var cfg := _config(graine, 35)
		cfg["marie"] = true
		var s2 := EtatPartie.new()
		s2.demarrer(cfg)
		for ev in s2.calendrier:
			if ev["type"] == "mariage":
				avec_marie += 1
		var cfg3 := _config(graine, 35, {"prenom": "Odette", "sexe": "f", "lien": "ami"})
		var s3 := EtatPartie.new()
		s3.demarrer(cfg3)
		for ev in s3.calendrier:
			if ev["type"] == "mariage":
				avec_marie += 1
	verifier("Mariage : aucun pour un joueur déjà marié ni pour un proche « ami » (célibataire, R-SEUL)", avec_marie == 0)
	var ok_naiss := true
	var nb_mar := 0
	for graine in 200:
		var s4 := EtatPartie.new()
		var c4 := _config(graine, 35)
		c4["naissance"] = {"d": "1984-06", "jumeaux_proba": 0.0}
		s4.demarrer(c4)
		for ev in s4.calendrier:
			if ev["type"] == "mariage":
				nb_mar += 1
				for ev2 in s4.calendrier:
					if ev2["type"] == "naissance" and int(ev2["m"]) <= int(ev["m"]) and int(ev["m"]) < int(ev2["m"]) + 9:
						ok_naiss = false
	verifier("Mariage : jamais dans les 9 mois après une naissance (naissance fixée à M5 : %d mariages tirés sur 200 graines)" % nb_mar, ok_naiss and nb_mar > 0)
	# Déroulé d'un mariage : état civil, modale « ok », texte rendu sans jeton
	var h := EtatPartie.new()
	var graine_h := -1
	for graine in 200:
		var t := EtatPartie.new()
		t.demarrer(_config(graine, 35))
		for ev in t.calendrier:
			if ev["type"] == "mariage":
				graine_h = graine
		if graine_h >= 0:
			break
	h.demarrer(_config(graine_h, 35))
	var vu := {}
	var garde := 0
	while h.fin == "" and garde < 400:
		garde += 1
		while not h.modale.is_empty():
			if h.modale.get("kind", "") == "vie" and h.calendrier[int(h.modale["idx"])]["type"] == "mariage":
				vu = h.contenu_modale()
			h.resolution_auto()
		h.avancer()
	verifier("Mariage joué : foyer marie, modale « ok » avec texte rendu (« Après N ans ensemble, Sylvie et vous avez dit oui. »), aucun jeton résiduel",
		bool(h.foyer.get("marie", false)) and not vu.is_empty() and vu["texte"].begins_with("Après ") and vu["texte"].contains("Sylvie et vous") and Gabarits.residuels(str(vu["texte"])).is_empty() and vu["choix"][0]["id"] == "ok", str(vu))
	verifier("foyer_visuel() : joueur {Gérard, h}, proche Sylvie conjoint, marié, âge de départ 35 + années écoulées",
		h.foyer_visuel()["marie"] and h.foyer_visuel()["proche"]["prenom"] == "Sylvie" and h.foyer_visuel()["joueur"]["sexe"] == "h" and int(h.foyer_visuel()["joueur"]["age"]) == 35 + (h.m - h.m_depart) / 12, str(h.foyer_visuel()))
	if vie_sans:
		vie.erase("mariage")

	# ---------- Jumeaux par chapitre ----------
	var n_jum := 0
	var n_tot := 600
	var proba_1989 := 1.0 / 6.0
	for graine in n_tot:
		var s5 := EtatPartie.new()
		var c5 := Donnees.config_demo(graine)
		c5["naissance"] = {"d": "1985-04", "jumeaux_proba": proba_1989}
		s5.demarrer(c5)
		for ev in s5.calendrier:
			if ev["type"] == "naissance" and ev.get("scriptee", false) and int(ev["n"]) == 2:
				n_jum += 1
	var freq_j := float(n_jum) / float(n_tot)
	verifier("Jumeaux ancrés : paramètre du chapitre (1/6) = %.3f sur %d naissances (± 3 points) ; 1984 garde 1/4 (chapitre.json)" % [freq_j, n_tot],
		absf(freq_j - proba_1989) <= 0.03 and is_equal_approx(float(Donnees.infos_chapitre("1984")["naissance"]["jumeaux_proba"]), 0.25), str(freq_j))
	print("")
	print("=== test_vie : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
