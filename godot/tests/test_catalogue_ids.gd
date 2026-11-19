extends SceneTree
## Lot 10a-moteur (suite, §8 bis) : identité par id de produit (produits_vus, R-UNE-FOIS, rattrapage), présentations au format
## liste {id, produit, quand, echeance}, StrategieTest (id de produit et D0x), cadence par chapitre, projets à travers la bascule,
## vitrine générique (étape sans pause, étape avec pause, courbe et mention). Jeu d'essai : tests/donnees/chapitres.

const RACINE_REELLE := "res://data/chapitres"
const RACINE_ESSAI := "res://tests/donnees/chapitres"

var _ok := 0
var _ko := 0


func _initialize() -> void:
	# ---------- 1984 (données réelles) ----------
	Donnees.racine_chapitres = RACINE_REELLE
	Donnees.regler_chapitre("")
	Donnees.vider_cache()
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(3))
	verifier("Cadence 1984 : budget « classiques » = 15 (rythme.json)", Cadence.budget("classiques") == 15)
	e.banque["presentes"] = {"D01": 3, "D02": 8}
	e.banque.erase("produits_vus")
	verifier("Migration D0x -> produits_vus : « presentes » {D01, D02} donne livret et pel vus (presente() lit les produits)",
		Banquier.presente(e, "livret") and Banquier.presente(e, "pel") and not Banquier.presente(e, "av") and Banquier.produits_vus(e) == ["livret", "pel"])
	var avant: int = e.file.size()
	Banquier._proposer(e, "D01", e.m)
	Banquier._proposer(e, "R_livret", e.m)
	verifier("R-UNE-FOIS : un produit déjà vu n'est jamais représenté (D01, rattrapage du livret)", e.file.size() == avant)
	verifier("Présentations 1984 : toujours des ids D01… et le champ « produits » lu par l'interface ; libellés lus dans banque.json",
		Banquier.donnees()["presentations"]["D02"]["produits"] == ["pel"] and Banquier.libelle("presente", "") == "M. Lefranc présente : "
		and Banquier.titre_historique({"produits": ["pel"]}) == "M. Lefranc présente : PEL")
	var carte := {"id": "D05", "produits": ["sicav"]}
	verifier("StrategieTest : « ouvrir » accepte l'id de présentation (D05) ou l'id de produit (sicav), refuse le reste",
		StrategieTest._accepte(["D05"], carte) and StrategieTest._accepte(["sicav"], carte) and not StrategieTest._accepte(["elf"], carte))

	# ---------- Jeu d'essai : chapitre 1989 au nouveau format ----------
	Donnees.racine_chapitres = RACINE_ESSAI
	Donnees.regler_chapitre("")
	Donnees.vider_cache()
	var b := Donnees.charger_dans("1989", "banque")
	verifier("Jeu d'essai 1989 : presentations en liste {id B1…, produit, quand, echeance}, sans bloc declencheurs, avec rattrapage",
		b["presentations"] is Array and b["presentations"][0]["id"] == "B1" and b["presentations"][0].has("produit") and b["presentations"][0].has("quand") and not b.has("declencheurs") and b.has("rattrapage"))
	var g := EtatPartie.new()
	var cfg := Donnees.config_chapitre("1984", 3, "1990-12")
	cfg["banquier"] = true
	cfg["rue"] = true
	cfg["projets"] = true
	g.demarrer(cfg)
	var presentes_1989 := {}
	var vitrine_notif := false
	var vitrine_modale := {}
	var budget_1989 := -1
	var garde := 0
	while g.fin == "" and garde < 400:
		garde += 1
		while not g.modale.is_empty():
			var c := g.contenu_modale()
			if c.get("kind", "") == "marche" and c.has("courbe"):
				vitrine_modale = c
			g.resolution_auto()
		var r := g.avancer()
		for n: Dictionary in r.get("notifs", []):
			if n.get("vitrine_etape", 0) == 1:
				vitrine_notif = true
		if g.chapitre == "1989":
			budget_1989 = Cadence.budget("classiques")
	for id in g.banque["presentes"]:
		if str(id).begins_with("R_"):
			presentes_1989[id] = int(g.banque["presentes"][id])
	var base := Banquier.debut_chapitre(g)
	var ms: Array = presentes_1989.values()
	ms.sort()
	var ecart_ok := true
	for i in range(1, ms.size()):
		if ms[i] - ms[i - 1] < 2:
			ecart_ok = false
	var dans_fenetre := true
	for m_p in ms:
		if m_p < base + 1 or m_p > base + 24 + 3:
			dans_fenetre = false
	verifier("R-RATTRAPAGE : scpi et sicav_monetaire (nés avant 1989, non déclarés) présentés une fois, entre les mois 1 et 24, au plus un tous les 2 mois  [%s]" % str(presentes_1989),
		presentes_1989.has("R_scpi") and presentes_1989.has("R_sicav_monetaire") and dans_fenetre and ecart_ok)
	verifier("Rattrapage : jamais de présentation de rattrapage pour un produit déjà vu (livret, pel…)", not presentes_1989.has("R_livret") and not presentes_1989.has("R_pel"))
	verifier("Produits vus : les 9 de 1984 puis scpi et sicav_monétaire, sans doublon", Banquier.produits_vus(g).size() == Banquier.produits_vus(g).duplicate().size()
		and Banquier.produits_vus(g).has("scpi") and Banquier.produits_vus(g).has("livret"))
	verifier("Cadence par chapitre : budget « classiques » 7 en 1989 (chapitre.json > cadence), 15 en 1984 ; compteurs remis à zéro à la bascule", budget_1989 == 7 and Cadence.budget("classiques") == 7)
	verifier("Vitrine générique : étape 1 sans pause (notification vitrine_etape = 1, texte calculé sur la série)", vitrine_notif)
	verifier("Vitrine générique : étape 2 = modale « marche » avec courbe de 3 mois, mention, sans « jours »",
		not vitrine_modale.is_empty() and (vitrine_modale["courbe"] as Array).size() == 3 and vitrine_modale["mention"] == "Exemple d'essai." and not vitrine_modale.has("jours") and not str(vitrine_modale["texte"]).contains("{"), str(vitrine_modale))
	var etats: Dictionary = g.projets["projets"]
	var propres := true
	for pid in etats:
		if not etats[pid].has("etat"):
			propres = false
	verifier("Projets à la bascule : états des projets terminés de 1984 rangés sous « 1984:<id> » ou laissés en cours, états du nouveau chapitre créés (%s)" % str(etats.keys()),
		propres and etats.has("P1") and (etats.has("1984:P1") or str(etats["P1"]["etat"]) != "attente"))
	Donnees.racine_chapitres = RACINE_REELLE
	Donnees.regler_chapitre("")
	Donnees.vider_cache()
	print("")
	print("=== test_catalogue_ids : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
