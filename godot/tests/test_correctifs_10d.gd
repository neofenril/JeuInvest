extends SceneTree
## Lot 10d-logique : correctifs de la recette finale du lot 10.
## A1 : aucune notification d'humeur ne garde de gabarit ({Proche}, {e_p}…) : rendus à l'émission (Foyer._regler_humeur).
## A2 : « Projets : x sur y réalisés » à l'écran de fin d'une partie de dix ans : réalisés et total sur la même base.
## M2 / M3 : textes de données (guillemets imbriqués, durée annoncée).
## Tour 2 : N1 (liste des projets de dix ans, projet encore en cours à la bascule), M6 (jamais « 0 F » pour une carte).
## N2 (ordre sur PEA / SCPI) : scène test_ordre_banque.tscn.

var _ok := 0
var _ko := 0


func _initialize() -> void:
	_a1()
	_a2()
	_n1()
	_n1_reporte()
	_m6()
	_textes()
	print("")
	print("=== test_correctifs_10d : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func _config(chapitre: String, g: int) -> Dictionary:
	var c := Donnees.config_chapitre(chapitre, g)
	c["banquier"] = true
	c["cartes"] = true
	c["projets"] = true
	c["rue"] = true
	return c


## Joue jusqu'à la fin (ou jusqu'à l'entrée dans le chapitre 1989 si jusqu_1989).
func _jouer(chapitre: String, g: int, jusqu_1989 := false, projets := "moins_cher") -> EtatPartie:
	Donnees.regler_chapitre("")
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = projets
	StrategieTest.politique_echeance = "auto"
	StrategieTest.strategie = ""
	var e := EtatPartie.new()
	e.demarrer(_config(chapitre, g))
	var garde := 0
	while e.fin == "" and garde < 400:
		garde += 1
		if jusqu_1989 and e.chapitre == "1989":
			break
		StrategieTest.jouer_mois(e, false)
		var essais := 0
		while not e.modale.is_empty() and essais < 6:
			essais += 1
			e.resolution_auto()
		e.avancer()
	return e


func _a1() -> void:
	var cas := {"Christine": null, "Gérard": null}
	Donnees.regler_chapitre("1989")
	var c := EtatPartie.new()
	c.demarrer(_config("1989", 5))
	cas["Christine"] = c
	Donnees.regler_chapitre("")
	cas["Gérard"] = _jouer("1984", 5, true)
	Donnees.regler_chapitre("1989")
	for nom in cas:
		var e: EtatPartie = cas[nom]
		var nb := 0
		var propres := true
		var detail := ""
		for valeur in [-2, -1, 0, 1, 2]:
			for cause in ["", "{Proche} a bien compris."]:
				e.foyer["humeur"] = 0
				var notifs := []
				Foyer._regler_humeur(e, valeur, cause, notifs)
				for n: Dictionary in notifs:
					nb += 1
					var t := str(n["titre"]) + " | " + str(n["texte"])
					if t.contains("{") or t.contains("}"):
						propres = false
						detail = t
		verifier("A1 %s (chapitre %s) : %d notifications d'humeur, aucun « { » dans titre ni texte" % [nom, e.chapitre, nb], nb > 0 and propres, detail)
	Donnees.regler_chapitre("")


func _a2() -> void:
	var tout_ok := true
	var detail := ""
	var vu_cumul := false
	for g in range(1, 13):
		var e := _jouer("1984", g)
		var b := Bilan.calculer(e)
		var p: Dictionary = b["projets"]
		var realises := int(p["realises"])
		var total := int(p["total"])
		var liste: Array = p["liste"]
		var reels := (e.projets["projets"] as Dictionary).size()
		if realises > total or total != liste.size() or total != reels:
			tout_ok = false
			detail = "graine %d : %d sur %d (liste %d, états %d)" % [g, realises, total, liste.size(), reels]
		if realises > 2:
			vu_cumul = true
	verifier("A2 : partie de dix ans, réalisés <= total, total = liste affichée = tous les projets traversés", tout_ok, detail)
	verifier("A2 : au moins une graine réalise plus de 2 projets (le défaut « 4 sur 2 » est exercé)", vu_cumul)
	var e5 := EtatPartie.new()
	var c5 := Donnees.config_demo(11)
	c5["banquier"] = true
	c5["cartes"] = true
	c5["projets"] = true
	e5.demarrer(c5)
	verifier("A2 : partie de cinq ans (démo 1984-1988) : total 2, inchangé", int(Bilan.calculer(e5)["projets"]["total"]) == 2)


## Noms des options d'un chapitre, par projet : { "P1": [noms], "P2": [noms] }, lus dans ses données.
func _noms(chapitre: String) -> Dictionary:
	var out := {}
	for p: Dictionary in Donnees.charger_dans(chapitre, "projets")["projets"]:
		out[str(p["id"])] = (p["options"] as Array).map(func(o: Dictionary) -> String: return str(o["nom"]))
	return out


## La liste de fin d'une partie de dix ans : 4 projets distincts (P1, P2 de 1984 puis de 1989), noms de leur chapitre,
## statuts égaux à l'état, total = réalisés + autres. Renvoie "" si tout est juste, sinon le détail.
func _juger_liste(e: EtatPartie) -> String:
	var p: Dictionary = Bilan.calculer(e)["projets"]
	var liste: Array = p["liste"]
	var etats: Dictionary = e.projets["projets"]
	var n84 := _noms("1984")
	var n89 := _noms("1989")
	var attendu := [["1984:P1", n84["P1"]], ["1984:P2", n84["P2"]], ["P1", n89["P1"]], ["P2", n89["P2"]]]
	if liste.size() != 4 or int(p["total"]) != 4:
		return "liste de %d, total %d" % [liste.size(), int(p["total"])]
	var noms := {}
	var autres := 0
	for i in 4:
		var x: Dictionary = liste[i]
		var s: Dictionary = etats[attendu[i][0]]
		noms[x["nom"]] = true
		if str(s["option"]) != "" and not (attendu[i][1] as Array).has(x["nom"]):
			return "ligne %d : « %s » n'est pas un projet de %s" % [i, x["nom"], attendu[i][0]]
		if str(x["etat"]) != str(s["etat"]):
			return "ligne %d : statut %s au lieu de %s" % [i, x["etat"], s["etat"]]
		if not str(x["etat"]) in ["realise", "realise_apres_report"]:
			autres += 1
	if noms.size() != 4:
		return "doublons : %s" % str(noms.keys())
	if int(p["realises"]) + autres != int(p["total"]):
		return "%d réalisés + %d autres != %d" % [int(p["realises"]), autres, int(p["total"])]
	return ""


func _n1() -> void:
	var detail := ""
	var nb := 0
	for pol in ["moins_cher", "plus_cher", "milieu"]:
		for g in [1, 7, 31, 5]:
			var e := _jouer("1984", g, false, pol)
			nb += 1
			var d := _juger_liste(e)
			if d != "" and detail == "":
				detail = "%s g%d : %s" % [pol, g, d]
	verifier("N1 : Gérard 1984-1993, %d parties : 4 projets distincts (2 de 1984 puis 2 de 1989), statuts et total justes" % nb, detail == "", detail)


## Un projet de 1984 dont le jour J tombe après la bascule (cadence : échéance repoussée en 1989) garde son nom et son
## montant, puis est archivé et le P2 de 1989 s'ouvre à son tour. Le retard est forcé en déplaçant m_echeance.
func _n1_reporte() -> void:
	Donnees.regler_chapitre("")
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "plus_cher"
	StrategieTest.politique_echeance = "auto"
	StrategieTest.strategie = ""
	var e := EtatPartie.new()
	e.demarrer(_config("1984", 7))
	var vu := {}
	var retarde := false
	var garde := 0
	while e.fin == "" and garde < 400:
		garde += 1
		var p2: Dictionary = e.projets["projets"].get("P2", {})
		if not retarde and e.chapitre == "1984" and str(p2.get("etat", "")) == "en_cours":
			retarde = true
			p2["m_echeance"] = Dates.lire("1989-03") - e.mk.ab_debut
		if e.chapitre == "1989" and not vu.has("bascule"):
			var pc := Projets.projet_en_cours(e)
			vu["bascule"] = {"nom": str(pc.get("nom", "")), "montant": float(pc.get("montant", 0.0)) * Format.TAUX_EURO}
		if str(e.modale.get("kind", "")) == "projet" and str(e.modale.get("etape", "")) == "echeance" and e.chapitre == "1989" and not vu.has("echeance"):
			vu["echeance"] = {"montant": float(e.contenu_modale()["montant"]) * Format.TAUX_EURO}
			e.joueur.cc += 200000.0 / Format.TAUX_EURO
			e.resoudre_modale("realiser")
		StrategieTest.jouer_mois(e, false)
		e.avancer()
	var nom84 := "L'apport pour un T3"
	var b: Dictionary = vu.get("bascule", {})
	verifier("N1 bascule : le projet encore en cours en 1989 reste celui de 1984 (apport pour un T3, 90 000 F)",
		retarde and str(b.get("nom", "")) == nom84 and absf(float(b.get("montant", 0.0)) - 90000.0) < 1.0, str(b))
	verifier("N1 bascule : son jour J demande 90 000 F, pas les 110 000 F de la maison de 1989",
		absf(float((vu.get("echeance", {}) as Dictionary).get("montant", 0.0)) - 90000.0) < 1.0, str(vu))
	var p2_89: Dictionary = e.projets["projets"].get("P2", {})
	verifier("N1 bascule : ensuite le projet 2 de 1989 est bien proposé et choisi", str(p2_89.get("option", "")) != "" and not p2_89.has("chapitre"), str(p2_89))
	var d := _juger_liste(e)
	var liste: Array = Bilan.calculer(e)["projets"]["liste"]
	verifier("N1 bascule : liste de fin juste, le projet retardé sous son nom de 1984", d == "" and liste.size() > 1 and str(liste[1]["nom"]) == nom84,
		d + " " + str(liste.map(func(x: Dictionary) -> String: return str(x["nom"]))))


## M6 : l'historique d'une carte de carrière montre le revenu par mois ; une carte sans montant n'affiche jamais « 0 F ».
func _m6() -> void:
	Donnees.regler_chapitre("1989")
	var vus := {}
	for choix in ["a", "b"]:
		var e := EtatPartie.new()
		e.demarrer(_config("1989", 7))
		var garde := 0
		while e.fin == "" and garde < 100 and not vus.has(choix):
			garde += 1
			var essais := 0
			while not e.modale.is_empty() and essais < 6 and not vus.has(choix):
				essais += 1
				if str(e.modale.get("kind", "")) == "carte" and str(e.modale.get("id", "")) == "K4":
					var attendu := float(e.contenu_modale()["choix"][0 if choix == "a" else 1]["revenu_mois"])
					e.resoudre_modale(choix)
					var h: Dictionary = e.historique.filter(func(x: Dictionary) -> bool: return str(x["genre"]) == "carte")[-1]
					var j: Dictionary = e.cartes_jouees()[-1]
					vus[choix] = {"attendu": attendu, "h": h, "txt": Foyer.montant_joue_txt(j, e.ab_courant())}
				else:
					e.resolution_auto()
			e.avancer()
	var a: Dictionary = vus.get("a", {})
	var b: Dictionary = vus.get("b", {})
	var ok_a: bool = not a.is_empty() and float(a["attendu"]) > 0.0 and bool(a["h"]["a_montant"]) and str(a["h"]["suffixe"]) == "par mois" \
		and is_equal_approx(float(a["h"]["montant"]), float(a["attendu"])) and str(a["txt"]).begins_with("+") and str(a["txt"]).ends_with(" / mois")
	verifier("M6 : K4 acceptée : historique « revenu par mois » et texte « %s »" % str(a.get("txt", "?")), ok_a, str(a.get("attendu", "")))
	verifier("M6 : K4 refusée (aucun montant) : ni montant dans l'historique ni « 0 F »",
		not b.is_empty() and not bool(b["h"]["a_montant"]) and str(b["txt"]) == "", str(b.get("txt", "?")))
	Donnees.regler_chapitre("")


func _lire(chemin: String) -> String:
	return FileAccess.get_file_as_string(chemin)


func _textes() -> void:
	var t89 := _lire("res://data/chapitres/1989/titres.json")
	verifier("M2 : plus de guillemets imbriqués dans les titres de 1989", not t89.contains("« Revendables"))
	for chap in ["1984", "1989"]:
		var inf := _lire("res://data/chapitres/%s/intro.json" % chap)
		verifier("M3 : intro %s ne parle plus de « Cinq ans de vie, de 1984 à 1988 »" % chap, not inf.contains("de 1984 à 1988"))
	var ch := _lire("res://data/chapitres/1984/chapitre.json")
	verifier("M3 : le sous-titre du départ n'est plus « Démonstration »", not ch.contains("Démonstration ·"))
	var f89 := _lire("res://data/chapitres/1989/foyer.json")
	verifier("K4 : avertissement « La garde du soir est déduite. »", f89.contains("La garde du soir est déduite.") and not f89.contains("Garde et frais de route"))
	var b89 := _lire("res://data/chapitres/1989/banque.json")
	verifier("SCPI : phrase « taux affiché » dans « En savoir plus »", b89.contains("Le taux affiché est calculé sur le prix payé, frais d'entrée compris ; vous revendez environ 10 % sous ce prix, même sans crise."))


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
