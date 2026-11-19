extends SceneTree
## Lot 10c-logique : pilote carrière K4 « Le poste itinérant » et K5 « Le congé formation » (docs/42, docs/47 §6, lot_10c.md).
## CA-C1 aucune carte K en 1984-1988 ; CA-C2 K4 et K5 toujours présentées, 4 mois d'écart ; CA-C3 revenu_mois = épargne après - avant,
## R-MIROIR, K5 : 10 mois à 90 % puis + 8 % en 01/1992 ; CA-C4 aucune option dominante (mesure) ; CA-C5 statut prenant, années tendues
## sauvegardées, aucun titre lié ; CA-C9 textes sans genre en dur (Gérard, Christine, joueuse d'essai) ; version 0.7 / code 11.

var _ok := 0
var _ko := 0
var _nb_ecarts := 0
const NB := 200
const NB_MESURE := 100   # R-MIROIR et CA-C4 : 2 à 4 parties de plus par graine (durée du test)


func _initialize() -> void:
	Donnees.regler_chapitre("1989")
	_donnees()
	_regles()
	_parties()
	_mesure_c4()
	Donnees.regler_chapitre("")
	print("")
	print("=== test_carriere : %d OK, %d KO (%d écarts signalés) ===" % [_ok, _ko, _nb_ecarts])
	quit(1 if _ko > 0 else 0)


func _config(qui: String, g: int) -> Dictionary:
	var c := Donnees.config_chapitre("1984" if qui == "gerard" else "1989", g)
	c["banquier"] = true
	c["cartes"] = true
	c["projets"] = true
	c["rue"] = true
	return c


## Même P-REF que test_chapitre_1989 (décisions de 1984 + produits de 1989).
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


## Une partie entière ; c4 / c5 : choix imposé à K4 / K5 ("a" ou "b"). Renvoie { e, k4, k5 } (mois, contenu affiché, mois suivant).
func _jouer(qui: String, g: int, c4: String, c5: String, profil: Dictionary) -> Dictionary:
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "moins_cher"
	StrategieTest.politique_echeance = "auto"
	StrategieTest.strategie = ""
	var e := EtatPartie.new()
	e.demarrer(_config(qui, g))
	var out := {"k4": {}, "k5": {}}
	var garde := 0
	var attente := ""
	while e.fin == "" and garde < 400:
		garde += 1
		if attente != "" and not out[attente].has("suite"):
			out[attente]["suite"] = {"m": e.m, "epargne": e.epargne_du_mois(), "base": e.salaire_base - float(e.depenses()["total"]), "enfants": e.enfants,
				"revenu": Foyer.revenu_mois(e)}
			attente = ""
		if str(e.modale.get("kind", "")) == "carte" and str(e.modale.get("id", "")) in ["K4", "K5"]:
			var k := "k4" if str(e.modale["id"]) == "K4" else "k5"
			var choix := c4 if k == "k4" else c5
			var cont := e.contenu_modale()
			out[k] = {"m": e.m, "ab": e.ab_courant(), "contenu": cont, "choix": choix, "salaire": e.salaire_base, "humeur_avant": int(e.foyer["humeur"]),
				"statut_avant": e.statut_carriere(), "metier_avant": e.metier(), "revenu_avant": Foyer.revenu_mois(e)}
			e.resoudre_modale(choix)
			out[k]["humeur_apres"] = int(e.foyer["humeur"])
			out[k]["statut_apres"] = e.statut_carriere()
			out[k]["metier_apres"] = e.metier()
			out[k]["revenu_effets"] = (e.foyer["revenus"] as Array).duplicate(true)
			attente = k
		if profil.is_empty():
			StrategieTest.jouer_mois(e, false)
			var essais := 0
			while not e.modale.is_empty() and essais < 6:
				essais += 1
				e.resolution_auto()
		else:
			StrategieTest.jouer_mois_profil(e, profil)
		e.avancer()
	out["e"] = e
	return out


# =====================================================================
# Données et textes
# =====================================================================

func _donnees() -> void:
	var fo := Donnees.charger_dans("1989", "foyer")
	var f84 := Donnees.charger_dans("1984", "foyer")
	var sans_k := true
	for id in f84["cartes"]:
		sans_k = sans_k and not str(id).begins_with("K") and not bool(f84["cartes"][id].get("carriere", false))
	for cr: Dictionary in f84["creneaux"]:
		sans_k = sans_k and not bool(cr.get("carriere", false))
	verifier("CA-C1 : aucune carte ni créneau de carrière dans les données de 1984-1988", sans_k)
	var cr: Array = fo["creneaux"]
	var t2: Dictionary = cr[1]
	var t5: Dictionary = cr[4]
	verifier("D2 : créneaux T2 = K4 et T5 = K5, fixes (jamais remplacés), marqués carrière ; H03, H07, H08 retirées",
		t2["id"] == "T2" and t2["candidates"] == ["K4"] and bool(t2["fixe"]) and bool(t2["carriere"]) and t5["id"] == "T5" and t5["candidates"] == ["K5"] and bool(t5["fixe"])
		and bool(t5["carriere"]) and not fo["cartes"].has("H03") and not fo["cartes"].has("H07") and not fo["cartes"].has("H08"))
	var k4: Dictionary = fo["cartes"]["K4"]
	var k5: Dictionary = fo["cartes"]["K5"]
	verifier("D4 : natures « neutre » aux 4 choix (aucun effet sur fourmi ou cigale), humeur -1 / 0, prix 0",
		[k4["a"], k4["b"], k5["a"], k5["b"]].all(func(c: Dictionary) -> bool: return c["nature"] == "neutre" and float(c["prix_F"]) == 0.0)
		and int(k4["a"]["humeur"]) == -1 and int(k4["b"]["humeur"]) == 0 and int(k5["a"]["humeur"]) == -1 and int(k5["b"]["humeur"]) == 0)
	verifier("D4 : K5 a = 90 % pendant 10 mois (-10 %, des_rel 1, jusqua_rel 10) puis + 8 % en 01/1992 ; K4 a = + 2,5 % (réglé par CA-C4) et statut prenant",
		k5["a"]["revenu"][0]["pct"] == -10 and k5["a"]["revenu"][0]["jusqua_rel"] == 10 and k5["a"]["revenu"][1]["pct"] == 8 and k5["a"]["revenu"][1]["des"] == "1992-01"
		and k4["a"]["revenu"][0]["pct"] == 2.5 and k4["a"]["statut"] == "prenant" and k5["a"]["statut"] == "normal")
	var longs := []
	for id in ["K4", "K5"]:
		for t in ["texte", "pourquoi"]:
			if fo["cartes"][id][t].replace(Format.ESPACE, " ").split(" ", false).size() > 30:
				longs.append(id + "." + t)
	verifier("Textes de K4 et K5 ≤ 30 mots", longs.is_empty(), str(longs))
	var pr: Variant = ProjectSettings.get_setting("application/config/version")
	var presets := FileAccess.get_file_as_string("res://export_presets.cfg")
	var projet := FileAccess.get_file_as_string("res://project.godot")
	verifier("CA-C6 : version 0.7 / code 11 (project.godot, 4 lignes d'export_presets.cfg), fichiers sans BOM",
		str(pr) == "0.7" and presets.contains("version/code=11") and presets.contains("version/name=\"0.7\"") and presets.contains("file_version=\"0.7.0.0\"")
		and presets.contains("product_version=\"0.7.0.0\"") and not presets.contains("0.6.2") and not projet.begins_with("﻿") and not presets.begins_with("﻿")
		and FileAccess.get_file_as_bytes("res://project.godot")[0] != 0xEF and FileAccess.get_file_as_bytes("res://export_presets.cfg")[0] != 0xEF)


## Statut prenant, compteur d'années tendues, métier, textes sans genre, sauvegarde (CA-C5, CA-C9).
func _regles() -> void:
	var e := _neuve("christine", 3)
	# Usure de janvier : prenant = -1 quelle que soit l'humeur ; normal = usure positive seulement
	var essais := [[true, 2, 1], [true, 0, -1], [true, -3, -3], [true, -2, -3], [false, 2, 1], [false, 0, 0], [false, -2, -2]]
	var ok := true
	var detail := ""
	for x: Array in essais:
		var t := _neuve("christine", 3)
		t.foyer["statut"] = "prenant" if x[0] else "normal"
		t.foyer["humeur"] = x[1]
		Foyer.debut_mois(t, [])
		if int(t.foyer["humeur"]) != x[2]:
			ok = false
			detail += "%s %d -> %d (attendu %d) " % [str(x[0]), x[1], int(t.foyer["humeur"]), x[2]]
	verifier("CA-C5 : statut prenant = -1 chaque janvier quelle que soit l'humeur (borne -3) ; normal : usure positive seulement", ok, detail)
	var t1 := _neuve("christine", 3)
	t1.foyer["statut"] = "prenant"
	t1.foyer["humeur"] = -2
	Foyer.debut_mois(t1, [])
	var t2 := _neuve("christine", 3)
	t2.foyer["humeur"] = -2
	Foyer.debut_mois(t2, [])
	var t3 := _neuve("christine", 3)
	t3.foyer["statut"] = "prenant"
	t3.foyer["humeur"] = 1
	t3.foyer["annees_tendues"] = 2
	Foyer.debut_mois(t3, [])
	verifier("CA-C5 : année tendue = fâché(e) au 31/12 ET statut prenant ; une année calme en efface une ; aucun effet ailleurs",
		int(t1.foyer["annees_tendues"]) == 1 and int(t2.foyer["annees_tendues"]) == 0 and int(t3.foyer["annees_tendues"]) == 1)
	# Sauvegarde et relecture
	t1.foyer["metier"] = ["A", "B"]
	t1.foyer["revenus"] = [{"pct": 15.0, "m_des": 5, "m_jusqua": -1}]
	var relu := EtatPartie.depuis_dict(t1.vers_dict())
	verifier("CA-C5 : annees_tendues, statut, revenus et metier sauvegardés et relus",
		relu != null and int(relu.foyer["annees_tendues"]) == 1 and relu.statut_carriere() == "prenant" and relu.foyer["metier"] == ["A", "B"] and (relu.foyer["revenus"] as Array).size() == 1
		and is_equal_approx(Foyer.revenu_mois(relu, 5), relu.salaire_base * 0.15))
	# Sauvegarde ancienne (sans les clés) : migration douce
	var ancien := _neuve("christine", 3).vers_dict()
	for k in ["revenus", "statut", "annees_tendues", "metier", "derniere_cause_type"]:
		(ancien["foyer"] as Dictionary).erase(k)
	var rel2 := EtatPartie.depuis_dict(ancien)
	verifier("Migration douce : une sauvegarde sans clés de carrière se relit (statut normal, 0 année tendue, revenu nul)",
		rel2 != null and rel2.statut_carriere() == "normal" and int(rel2.foyer["annees_tendues"]) == 0 and Foyer.revenu_mois(rel2) == 0.0)
	# metier() : profil, puis choix, forme féminine
	var g := _neuve("gerard", 3)
	verifier("metier() : « Technicien » (profil de Gérard) ; avec sexe féminin « Technicienne »", g.metier() == "Technicien" and _avec_sexe(g, "f").metier() == "Technicienne")
	verifier("metier() de Christine : « Employée de bureau »", e.metier() == "Employée de bureau")


func _neuve(qui: String, g: int) -> EtatPartie:
	var e := EtatPartie.new()
	e.demarrer(_config(qui, g))
	return e


func _avec_sexe(e: EtatPartie, s: String) -> EtatPartie:
	e.config_depart["sexe"] = s
	return e


# =====================================================================
# Parties
# =====================================================================

func _parties() -> void:
	var rendus := {}
	for qui in ["gerard", "christine"]:
		var nom := "Gérard 1984 -> 1993" if qui == "gerard" else "Christine 1989 -> 1993"
		var k4_ok := 0
		var k5_ok := 0
		var faillites := 0
		var ecart_min := 99
		var pas_avant_1989 := 0
		var identite := 0
		var mirroir := 0
		var k5_ok_profil := 0
		var statut_ok := 0
		var titres_diff := 0
		var cause_ok := 0
		var rendu_ok := 0
		var nb := 0
		var nm := 0
		var avertissement_ok := 0
		for g in range(1, NB + 1):
			var r := _jouer(qui, g, "a", "a", _profil(g))
			var e: EtatPartie = r["e"]
			if int(e.stats.get("faillite_m", -1)) >= 0:
				faillites += 1
				continue
			nb += 1
			var cr: Dictionary = e.foyer["creneaux"]
			var j4: bool = cr["T2"]["etat"] == "joue" and cr["T2"]["jouee"] == "K4"
			var j5: bool = cr["T5"]["etat"] == "joue" and cr["T5"]["jouee"] == "K5"
			k4_ok += 1 if j4 else 0
			k5_ok += 1 if j5 else 0
			# aucun K avant 1989 (Gérard)
			for j: Dictionary in e.foyer["jouees"]:
				if str(j["id"]).begins_with("K") and int(j["ab"]) < Dates.lire("1989-01"):
					pas_avant_1989 += 1
			# moments de carrière : 4 mois d'écart
			var ms := []
			for j: Dictionary in e.foyer["jouees"]:
				if bool(j.get("carriere", false)):
					ms.append(int(j["m"]))
			ms.sort()
			for i in range(1, ms.size()):
				ecart_min = mini(ecart_min, ms[i] - ms[i - 1])
			if j4 and j5:
				var k4: Dictionary = r["k4"]
				var k5: Dictionary = r["k5"]
				var ca: Dictionary = k4["contenu"]["choix"][0]
				var cb: Dictionary = k4["contenu"]["choix"][1]
				var c5a: Dictionary = k5["contenu"]["choix"][0]
				# CA-C3 : epargne_apres - epargne_avant == revenu_mois, et le mois suivant le flux le confirme
				var s4: Dictionary = k4["suite"]
				var s5: Dictionary = k5["suite"]
				var egal := absf((float(ca["epargne_apres"]) - float(ca["epargne_avant"])) - float(ca["revenu_mois"])) < 0.005 / Format.TAUX_EURO \
					and float(cb["revenu_mois"]) == 0.0 and absf(float(ca["revenu_mois"]) - (float(s4["revenu"]) - float(k4["revenu_avant"]))) < 1e-9 and bool(k4["contenu"]["carriere"])
				var egal5 := absf(float(c5a["revenu_mois"]) - (float(s5["revenu"]) - float(k5["revenu_avant"]))) < 1e-9 and float(c5a["revenu_mois"]) < 0.0
				var suivi := absf((float(s4["epargne"]) - float(s4["base"])) - float(s4["revenu"])) < 1e-9 and absf(float(ca["epargne_apres"]) - float(s4["epargne"])) < 1e-9 * maxf(1.0, absf(float(s4["epargne"])))
				identite += 1 if (egal and egal5 and suivi) else 0
				# K5 a : 10 mois à 90 %, puis + 8 % exactement en 01/1992
				var base5 := float(k5["salaire"])
				var m5 := int(k5["m"])
				var eff5: Array = (k5["revenu_effets"] as Array).slice((k5["revenu_effets"] as Array).size() - 2)   # les deux effets de K5 a (le 1er est celui de K4 a avant)
				# 10 mois exactement à -10 %, puis + 8 % dès 01/1992 (ou dès le mois qui suit le congé s'il court plus loin : K5 après 02/1991)
				var m_jan92 := Dates.lire("1992-01") - e.mk.ab_debut
				var n90 := 0
				for d in range(m5, m5 + 16):
					n90 += 1 if _pct(eff5, d) < 0.0 else 0
				var debut_gain := maxi(m_jan92, m5 + 11)
				var bon5: bool = n90 == 10 and _pct(eff5, m5) == 0.0 and _pct(eff5, m5 + 1) == -10.0 and _pct(eff5, m5 + 10) == -10.0 and _pct(eff5, debut_gain) == 8.0 \
					and _pct(eff5, m5 + 11) == (8.0 if m5 + 11 >= m_jan92 else 0.0) and (m5 + 11 > m_jan92 or debut_gain == m_jan92)
				k5_ok_profil += 1 if bon5 and base5 > 0.0 else 0
				# statut : prenant après K4 a, normal après K5 a ; humeur -1 ; cause carriere
				statut_ok += 1 if (k4["statut_apres"] == "prenant" and k5["statut_apres"] == "normal" and int(k4["humeur_apres"]) == clampi(int(k4["humeur_avant"]) - 1, -3, 3)) else 0
				var causes: Array = e.foyer["jouees"].filter(func(x: Dictionary) -> bool: return str(x.get("cause", "")) == "carriere")
				cause_ok += 1 if causes.size() == 2 else 0
				avertissement_ok += 1 if (str(ca["avertissement"]) != "" and not str(ca["avertissement"]).contains("{") and str(cb["avertissement"]) == "") else 0
				# textes rendus : aucun gabarit résiduel, métier de la carte
				var ctx := [str(k4["contenu"]["texte"]), str(k5["contenu"]["texte"]), str(ca["avertissement"]), str(k4["metier_apres"]), str(k5["metier_apres"])]
				var propre := true
				for tx: String in ctx:
					propre = propre and Gabarits.residuels(tx).is_empty() and not tx.contains("{")
				rendu_ok += 1 if (propre and str(k4["metier_apres"]) != "" and str(k5["metier_apres"]) != "") else 0
				if g == 1:
					rendus[qui] = [k4["contenu"]["texte"], k5["contenu"]["texte"], ca["avertissement"], k4["metier_apres"], k5["metier_apres"], k4["contenu"]["choix"][0]["titre"]]
			# R-MIROIR : Tata et Tonton ont le même écart que le joueur (même flux)
			if g > NB_MESURE:
				continue
			nm += 1
			var rm := _jouer(qui, g, "b", "b", {})["e"] as EtatPartie
			var ra := _jouer(qui, g, "a", "b", {})["e"] as EtatPartie
			var dm := float(ra.hist["matelas"][ra.m_fin]) - float(rm.hist["matelas"][rm.m_fin])
			var dl := float(ra.hist["livret"][ra.m_fin]) - float(rm.hist["livret"][rm.m_fin])
			mirroir += 1 if (dm > 0.0 and dl > 0.0 and absf(float(ra.hist["j"][ra.m_fin]) - float(rm.hist["j"][rm.m_fin]) - dl) / maxf(dl, 1.0) < 0.5) else 0
			var tb := str(Bilan.calculer(rm)["titre"]["id"])
			var ta := str(Bilan.calculer(ra)["titre"]["id"])
			titres_diff += 1 if (ta != tb and not (ta in ["bon_pere", "golden_boy", "ecureuil", "escargots", "apprenti", "marin", "neveu_matelas", "fourmi", "cigale"])) else 0
		verifier("CA-C1 : %s : aucune carte K avant 1989 (%d graines)" % [nom, NB], pas_avant_1989 == 0, str(pas_avant_1989))
		verifier("CA-C2 : %s : K4 présentée dans %d / %d parties, K5 dans %d / %d (hors faillite : %d)" % [nom, k4_ok, nb, k5_ok, nb, faillites], k4_ok == nb and k5_ok == nb and nb >= NB * 95 / 100)
		verifier("CA-C2 : %s : jamais deux moments de carrière à moins de 4 mois (écart minimal %d)" % [nom, ecart_min], ecart_min >= 4)
		verifier("CA-C3 : %s : épargne après - avant == revenu_mois (K4 a, K5 a), confirmé par le flux du mois suivant" % nom, identite == nb, "%d / %d" % [identite, nb])
		verifier("CA-C3 : %s : K5 a : 10 mois à 90 %% (-10 %%), puis + 8 %% exactement en 01/1992" % nom, k5_ok_profil == nb, "%d / %d" % [k5_ok_profil, nb])
		verifier("CA-C3 : %s : R-MIROIR : Tata et Tonton reçoivent l'écart de revenu du joueur (K4 a contre K4 b)" % nom, mirroir == nm, "%d / %d" % [mirroir, nb])
		verifier("CA-C5 : %s : statut prenant après K4 a, normal après K5 a ; humeur -1 ; deux causes « carriere » dans les cartes jouées" % nom, statut_ok == nb and cause_ok == nb, "%d %d / %d" % [statut_ok, cause_ok, nb])
		verifier("CA-C5 : %s : aucun titre ni aucune étoile ne dépend de K4 / K5 (natures neutres, %d graines comparées)" % [nom, nm], titres_diff == 0, str(titres_diff))
		verifier("CA-C9 : %s : textes, avertissement et métiers rendus sans gabarit résiduel" % nom, rendu_ok == nb and avertissement_ok == nb, "%d %d / %d" % [rendu_ok, avertissement_ok, nb])
	print("    RENDU Gérard : %s" % str(rendus.get("gerard", [])))
	print("    RENDU Christine : %s" % str(rendus.get("christine", [])))
	# Joueuse d'essai : texte brut de K4 / K5 pour le profil technicien, rendu avec une joueuse (sexe f, proche Gérard)
	var e := _neuve("gerard", 1)
	var c4: Dictionary = Donnees.charger_dans("1989", "foyer")["cartes"]["K4"]
	var c5: Dictionary = Donnees.charger_dans("1989", "foyer")["cartes"]["K5"]
	var ctx := Gabarits.profil({"prenom": "Sylvie", "sexe": "f"}, {"prenom": "Gérard", "sexe": "h", "lien": "conjoint"}, [])
	var t4 := Gabarits.rendre(Foyer.texte_carte(e, c4), ctx)
	var t5 := Gabarits.rendre(Foyer.texte_carte(e, c5), ctx)
	var av := Gabarits.rendre(Foyer._remplir(e, str(c4["a"]["avertissement"]), c4), ctx)
	print("    RENDU joueuse : %s | %s | %s | %s" % [t4, t5, av, _avec_sexe(_neuve("gerard", 1), "f").metier()])
	verifier("CA-C9 : joueuse d'essai : « technico-commerciale itinérante », aucun jeton résiduel, « Gérard vous verra moins »",
		t4.contains("technico-commerciale itinérante") and av.begins_with("Gérard vous verra moins") and Gabarits.residuels(t4 + t5 + av).is_empty() and not t4.contains("{") and not t5.contains("{"), t4 + " / " + av)


func _pct(effets: Array, m: int) -> float:
	var s := 0.0
	for x: Dictionary in effets:
		if m >= int(x["m_des"]) and (int(x["m_jusqua"]) < 0 or m <= int(x["m_jusqua"])):
			s += float(x["pct"])
	return s


# =====================================================================
# CA-C4 : aucune option dominante (mesure)
# =====================================================================

func _mesure_c4() -> void:
	for qui in ["gerard", "christine"]:
		var nom := "Gérard" if qui == "gerard" else "Christine"
		for carte in ["K4", "K5"]:
			var pat_a := 0
			var hum_b := 0
			var ecarts := []
			var n := 0
			for g in range(1, NB_MESURE + 1):
				var p := _profil(g)
				var base := _jouer(qui, g, "b", "b", p)["e"] as EtatPartie
				var avec := _jouer(qui, g, "a" if carte == "K4" else "b", "a" if carte == "K5" else "b", p)["e"] as EtatPartie
				if base.fin != "fin" or avec.fin != "fin":
					continue
				n += 1
				var pb := float(base.hist["j"][base.m_fin])
				var pa := float(avec.hist["j"][avec.m_fin])
				if pa > pb:
					pat_a += 1
				# humeur : b gagne si l'humeur finale de a est plus basse
				if int(avec.foyer["humeur"]) < int(base.foyer["humeur"]):
					hum_b += 1
				ecarts.append(absf(pa - pb) / maxf(absf(pb), 1.0))
			ecarts.sort()
			var med := 100.0 * float(ecarts[ecarts.size() / 2])
			print("    MESURE CA-C4 %s %s (%d graines P-REF) : a bat b en patrimoine dans %.0f %% des graines, b bat a en humeur dans %.0f %% ; écart médian de patrimoine %.1f %%"
				% [nom, carte, n, 100.0 * pat_a / n, 100.0 * hum_b / n, med])
			verifier("CA-C4 : %s %s : aucune option dominante (a meilleure en patrimoine dans au moins une graine, b meilleure en humeur dans au moins une)" % [nom, carte], pat_a > 0 and hum_b > 0)
			if med < 5.0 or med > 10.0:
				_nb_ecarts += 1
				print("    ECART CA-C4 %s %s : écart médian de patrimoine %.1f %% hors de 5 à 10 %% (point d'arrêt : réglage par les montants seulement)" % [nom, carte, med])


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
