extends SceneTree
## Lot 10d-logique : correctifs de la recette finale du lot 10.
## A1 : aucune notification d'humeur ne garde de gabarit ({Proche}, {e_p}…) : rendus à l'émission (Foyer._regler_humeur).
## A2 : « Projets : x sur y réalisés » à l'écran de fin d'une partie de dix ans : réalisés et total sur la même base.
## M2 / M3 : textes de données (guillemets imbriqués, durée annoncée).

var _ok := 0
var _ko := 0


func _initialize() -> void:
	_a1()
	_a2()
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
func _jouer(chapitre: String, g: int, jusqu_1989 := false) -> EtatPartie:
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "moins_cher"
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
