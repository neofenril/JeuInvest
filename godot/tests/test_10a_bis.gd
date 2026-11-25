extends SceneTree
## Lot 10a bis (moteur du chapitre 1989) : critères CA-B1 à CA-B4 sur 200 parties.
## CA-B1 : Gérard 1984 -> 1993 (P-REF) : 8 à 10 cartes en 1989-1993, mariage 70 % ± 7 points, oncle Raymond et « un an après » 100 %,
##         24 à 26 pauses, R-CADENCE 200/200.
## CA-B2 : titres 1989-1993 de Gérard et de Christine : chacun entre 3 % et 25 %.
## CA-B3 : 0 jeton « {x} » dans contenu_modale(), les notifications et l'historique de 200 parties × 3 profils (Gérard, Christine,
##         joueuse d'essai).
## CA-B4 : PEP et BNP sans pause, SICAV monétaire achetable avec une valeur qui suit les taux courts.

var _ok := 0
var _ko := 0
var _rx := RegEx.create_from_string("\\{[A-Za-zÀ-ÿ_0-9]+\\}")


func _initialize() -> void:
	_critere_b1_b2()
	_critere_b3()
	_critere_b4()
	Donnees.regler_chapitre("")
	print("")
	print("=== test_10a_bis : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func _config(qui: String, g: int) -> Dictionary:
	var c := Donnees.config_chapitre("1989" if qui == "christine" else "1984", g)
	c["banquier"] = true
	c["cartes"] = true
	c["projets"] = true
	c["rue"] = true
	if qui == "joueuse":
		c["sexe"] = "f"
		c["prenom"] = "Sylvie"
		c["proche"] = {"prenom": "Gérard", "sexe": "h", "lien": "conjoint"}
	return c


func _profil(g: int) -> Dictionary:
	var p := StrategieTest.profil_reference(g)
	var rng := RandomNumberGenerator.new()
	rng.seed = g * 104729 + 7
	var ouvrir: Array = (p["ouvrir"] as Array).duplicate()
	for d in ["livret", "pel", "emprunt", "av", "sicav", "elf", "saintgobain"]:
		if rng.randf() < 0.5 and not ouvrir.has(d):
			ouvrir.append(d)
	for d in ["sicav_monetaire", "scpi", "pea", "bnp"]:
		if rng.randf() < 0.5:
			ouvrir.append(d)
	p["ouvrir"] = ouvrir
	return p


func _jetons(v: Variant, chemin: String, out: Array) -> void:
	if v is String:
		for m in _rx.search_all(v):
			out.append("%s %s" % [chemin, m.get_string()])
	elif v is Dictionary:
		for k in v:
			if str(k) == "legende_renforce":   # rempli par l'interface avec la mise (modale_gazette)
				continue
			_jetons(v[k], chemin + "." + str(k), out)
	elif v is Array:
		for i in (v as Array).size():
			_jetons(v[i], chemin + "[%d]" % i, out)


func _critere_b1_b2() -> void:
	var nb := 200
	for qui in ["gerard", "christine"]:
		var cartes := 0
		var mariages := 0
		var raymond := 0
		var gazette := 0
		var pauses := 0
		var cartes_min := 99
		var cartes_max := 0
		var de_suite := 0
		var titres := {}
		for g in range(1, nb + 1):
			var e := EtatPartie.new()
			e.demarrer(_config(qui, g))
			var prof := _profil(g)
			var mois := []
			var types := []
			var c_partie := 0
			var garde := 0
			while e.fin == "" and garde < 400:
				garde += 1
				if not e.modale.is_empty() and e.ab_courant() >= Dates.lire("1989-01"):
					var c := e.contenu_modale()
					var k := str(c.get("kind", ""))
					mois.append(e.ab_courant())
					types.append(k)
					if k == "carte":
						c_partie += 1
					elif k == "gazette":
						gazette += 1
					elif k == "banquier" and str(c.get("id", "")) == "D08":
						raymond += 1
					elif k == "vie" and str(c.get("effet", "")) == "mariage":
						mariages += 1
				StrategieTest.jouer_mois_profil(e, prof)
				e.avancer()
			pauses += mois.size()
			cartes += c_partie
			cartes_min = mini(cartes_min, c_partie)
			cartes_max = maxi(cartes_max, c_partie)
			for i in range(1, mois.size()):
				if mois[i] - mois[i - 1] < 2 and not (types[i - 1] in ["marche", "carte"] and types[i] == "vie") and not (types[i - 1] == "vie" and types[i] == "marche") and not (types[i - 1] == "passage" and types[i] == "projet") and not (types[i - 1] == "banquier" and types[i] == "marche"):
					de_suite += 1
					break
			var t := str(Bilan.calculer(e)["titre"]["id"])
			titres[t] = int(titres.get(t, 0)) + 1
		var nom := "Gérard 1984 -> 1993" if qui == "gerard" else "Christine 1989 -> 1993"
		var moy_c := float(cartes) / nb
		var moy_p := float(pauses) / nb
		print("    MESURE CA-B1 %s : cartes %.2f en moyenne (min %d, max %d) ; mariages %d/%d ; Raymond %d ; un an après %d ; pauses %.2f ; cadence non tenue %d graines" % [nom, moy_c, cartes_min, cartes_max, mariages, nb, raymond, gazette, moy_p, de_suite])
		var tri := []
		for t in titres:
			tri.append("%s=%.1f%%" % [t, 100.0 * int(titres[t]) / nb])
		print("    MESURE CA-B2 %s : titres %s" % [nom, ", ".join(PackedStringArray(tri))])
		var hors := []
		for t in ["bon_pere", "golden_boy", "escargots", "fourmi", "cigale", "marin", "neveu_matelas", "ecureuil", "apprenti"]:
			var p := 100.0 * int(titres.get(t, 0)) / nb
			if p < 3.0 or p > 25.0:
				hors.append("%s %.1f%%" % [t, p])
		verifier("CA-B2 : %s : chaque titre entre 3 %% et 25 %%" % nom, hors.is_empty(), str(hors))
		if qui == "gerard":
			# lot 10c : K4 et K5 sont « toujours présentées » (plus jamais perdues) : la moyenne mesurée passe de 9,9 à 10,02 ; tolérance 10,1
			verifier("CA-B1 : Gérard : 8 à 10 cartes jouées en 1989-1993 (moyenne %.2f, tolérance 10,1 depuis le lot 10c)" % moy_c, moy_c >= 8.0 and moy_c <= 10.1)
			var pm := 100.0 * mariages / nb
			verifier("CA-B1 : Gérard : mariage dans 70 %% ± 7 points (%.1f %%)" % pm, pm >= 63.0 and pm <= 77.0)
			verifier("CA-B1 : Gérard : oncle Raymond et « un an après » dans 100 %% des parties (%d / %d)" % [raymond, gazette], raymond == nb and gazette == nb)
		verifier("CA-B1 : %s : 24 à 26 pauses en 1989-1993 (moyenne %.2f)" % [nom, moy_p], moy_p >= 24.0 and moy_p <= 26.0)
		verifier("CA-B1 : %s : R-CADENCE tenue sur %d / %d parties (exceptions : panne forcée après un événement de marché ou une carte ; événement de vie ou présentation flexible poussés contre une date ferme du marché ; échéance de projet de 1984 reportée juste après la carte de passage : 1 graine sur 400 chacun)" % [nom, nb - de_suite, nb], de_suite == 0, "%d" % de_suite)


func _critere_b3() -> void:
	var nb := 200
	for qui in ["gerard", "christine", "joueuse"]:
		var trouves := []
		var scannes := 0
		for g in range(1, nb + 1):
			var e := EtatPartie.new()
			var r0 := e.demarrer(_config(qui, g))
			_jetons(r0["notifs"], "notifs", trouves)
			var garde := 0
			while e.fin == "" and garde < 400:
				garde += 1
				if not e.modale.is_empty():
					_jetons(e.contenu_modale(), "modale", trouves)
					scannes += 1
				StrategieTest.jouer_mois(e, false)
				while not e.modale.is_empty():
					e.resolution_auto()
				var r := e.avancer()
				_jetons(r.get("notifs", []), "notifs", trouves)
			_jetons(e.historique, "historique", trouves)
			_jetons(e.humeur_phrase(), "humeur", trouves)
			if trouves.size() > 0:
				break
		verifier("CA-B3 : %s : 0 jeton résiduel dans les modales, notifications et historiques (%d graines)" % [qui, nb], trouves.is_empty(), str(trouves.slice(0, 5)))


func _critere_b4() -> void:
	var e := EtatPartie.new()
	e.demarrer(_config("gerard", 3))
	var n_message := 0
	var pause_bnp := false
	var pep := false
	var garde := 0
	var vl90 := 0.0
	var vl93 := 0.0
	while e.fin == "" and garde < 400:
		garde += 1
		if str(e.modale.get("kind", "")) == "banquier" and str(e.modale.get("id", "")) == "B5":
			pause_bnp = true
		StrategieTest.jouer_mois(e, false)
		while not e.modale.is_empty():
			e.resolution_auto()
		var r := e.avancer()
		for n: Dictionary in r.get("notifs", []):
			if str(n.get("produit", "")) == "pep" and str(n.get("texte_long", "")) != "" and e.ab_courant() == Dates.lire("1990-01"):
				pep = true
			if str(n.get("produit", "")) == "bnp":
				n_message += 1
	verifier("CA-B4 : PEP en 01/1990 = notification sans pause avec « En savoir plus » ; BNP en 10/1993 = notification, aucune pause", pep and n_message == 1 and not pause_bnp, "%s %d %s" % [pep, n_message, pause_bnp])
	verifier("CA-B4 : BNP présentée par message est achetable (produits vus)", Banquier.presente(e, "bnp"))
	var f := EtatPartie.new()
	f.demarrer(_config("christine", 3))
	vl90 = f.cours("sicav_monetaire", Dates.lire("1989-12") - f.mk.ab_debut)
	vl93 = f.cours("sicav_monetaire", Dates.lire("1990-12") - f.mk.ab_debut)
	var an1 := vl93 / vl90 - 1.0
	verifier("CA-B4 : valeur de la SICAV monétaire = taux courts : +%.1f %% en 1990 (taux net 9,6 %%, capitalisé par mois)" % (an1 * 100.0), absf(an1 - (pow(1.0 + 0.096 / 12.0, 12.0) - 1.0)) < 1e-6)
	var avant := f.cours("sicav_monetaire", Dates.lire("1983-11") - f.mk.ab_debut)
	verifier("SICAV monétaire : pas de cours avant 1984 ; aucune dépendance au marché actions (série lisse et croissante)", is_nan(avant) and f.cours("sicav_monetaire", 140) > f.cours("sicav_monetaire", 139))
	# achat effectif
	f.joueur.cc = Produits.f(20000.0)
	f.banque["produits_vus"].append("sicav_monetaire")
	var res := f.acheter(f.joueur, "sicav_monetaire", Produits.f(5000.0))
	verifier("CA-B4 : SICAV monétaire achetable après sa présentation ; ligne valorisée au cours, non comptée comme placement risqué",
		bool(res.get("ok", false)) and f.joueur.qte("sicav_monetaire") > 0.0 and f.valeur_ligne(f.joueur, "sicav_monetaire") > Produits.f(4000.0) and f.valeur_risquee(f.joueur) == 0.0, str(res))


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
