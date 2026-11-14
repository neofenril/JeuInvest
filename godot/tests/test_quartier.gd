extends SceneTree
## Tests de Quartier (lot 05-L phase A) : Jean-Mi (docs/19, docs/26), classement, notifications, textes.
## Logique pure sur données fabriquées (miroir sans salaire). Lancer : Godot_console --headless --path godot --script res://tests/test_quartier.gd

const MOTS_INTERDITS := ["achetez", "vendez", "c'est le moment", "auriez dû"]
const PEUGEOT := {
	"1986-08": 470, "1986-09": 520, "1986-10": 540, "1986-11": 570, "1986-12": 600,
	"1987-01": 660, "1987-02": 700, "1987-03": 740, "1987-04": 725, "1987-05": 700, "1987-06": 690,
	"1987-07": 710, "1987-08": 710, "1987-09": 680, "1987-10": 500, "1987-11": 440, "1987-12": 450,
	"1988-01": 480, "1988-02": 520, "1988-03": 550, "1988-04": 590, "1988-05": 620, "1988-06": 630,
	"1988-07": 650, "1988-08": 640, "1988-09": 680, "1988-10": 720, "1988-11": 770, "1988-12": 800}

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_donnees()
	_tests_jeanmi()
	_tests_levier()
	_tests_classement()
	_tests_notifications()
	_tests_budgets_extremes()
	_tests_textes()
	print("")
	print("=== test_quartier : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _proche(a: float, b: float, rel: float) -> bool:
	return absf(a - b) <= rel * absf(b) + 1e-9


## Trajectoire de Jean-Mi du 08/1986 au 12/1988 sur la série de docs/19 §1.2, miroir fabriqué : 37 500 F, sans salaire.
## Renvoie {"ab": {"etat", "compte", "patrimoine", "evts"}}.
func _trajectoire() -> Dictionary:
	var etat := Quartier.jeanmi_initial()
	var compte := 37500.0
	var out := {}
	var plan := Quartier.plan_jeanmi()
	for ab in range(Dates.lire("1986-09"), Dates.lire("1988-12") + 1):
		var cle := "%d-%02d" % [Dates.annee(ab), Dates.mois(ab)]
		var prec := "%d-%02d" % [Dates.annee(ab - 1), Dates.mois(ab - 1)]
		var r := Quartier.pas_mensuel(etat, ab, float(PEUGEOT[cle]), float(PEUGEOT[prec]), compte, plan)
		etat = r["etat"]
		compte += float(r["mouvement"])
		out[cle] = {"etat": etat.duplicate(true), "compte": compte, "patrimoine": Quartier.patrimoine_jeanmi(etat, compte),
			"evts": r["evenements"], "mouvement": r["mouvement"]}
	return out


func _tests_donnees() -> void:
	var r := Quartier.donnees_rue()
	verifier("rue.json : éteinte par défaut", r["actif"] == false)
	verifier("14 passages (V01-V10, V13-V16), uniques", r["passages"].size() == 14)
	var cles: Array = []
	for p in r["passages"]:
		if p["cle"]:
			cles.append(p["id"])
	verifier("5 passages ★ : V01, V07, V09, V13, V16", cles == ["V01", "V07", "V09", "V13", "V16"], str(cles))
	verifier("11 titres de kiosque, sans « LUNDI NOIR » ni « CAC 40 »", r["kiosque"].size() == 11
		and not str(r["kiosque"]).contains("LUNDI") and not str(r["kiosque"]).contains("CAC"))
	var ok_mots := true
	for p in r["passages"]:
		if _mots(str(p["texte"])) > 15 and not str(p["id"]) in ["V14", "V15"]:
			ok_mots = false
		if p["long"] and _mots(str(p["texte_long"])) > 60:
			ok_mots = false
	verifier("Textes de notification ≤ 15 mots (long ≤ 60)", ok_mots)
	var j := Quartier.donnees_jeanmi()
	verifier("jeanmi : nom, initiale, règle, répliques, plan", j["nom"] == "Jean-Mi" and j["initiale"] == "J"
		and j.has("regle") and j.has("devant") and j.has("derriere") and j["plan"].has("voiture"))
	verifier("Témoins existants intacts", Donnees.temoins().has("matelas") and Donnees.temoins().has("livret")
		and Donnees.temoins().has("indice"))
	verifier("Mensualité 2 897 F (110 000 F, 48 mois, 12 %)", Quartier.mensualite() == 2897.0, str(Quartier.mensualite()))


func _mots(t: String) -> int:
	var n := 0
	for m in t.split(" ", false):
		for c in m:
			if c.to_lower() != c.to_upper() or c.is_valid_int():
				n += 1
				break
	return n


func _tests_jeanmi() -> void:
	var tr := _trajectoire()
	var s0: Dictionary = tr["1986-09"]
	verifier("09/1986 : couverture 30 000 F, position 150 000 F, compte 7 500 F",
		s0["etat"]["etape"] == "position" and _proche(s0["etat"]["couverture"], 30000.0, 1e-9)
		and _proche(s0["etat"]["position"], 150000.0, 1e-6) and _proche(s0["compte"], 7500.0, 1e-9))
	verifier("09/1986 : patrimoine inchangé par l'ouverture", _proche(s0["patrimoine"], 37500.0, 1e-9))
	verifier("Événement « ouverture » en 09/1986", s0["evts"] == ["ouverture"])
	verifier("03/1987 : équité 78 359 F (gains 54 659, reports 6 300)", _proche(tr["1987-03"]["etat"]["equite"], 78359.0, 0.001),
		str(tr["1987-03"]["etat"]["equite"]))
	var a: Dictionary = tr["1987-04"]
	verifier("04/1987 : Porsche à crédit, étape porsche, événement achat_voiture", a["etat"]["etape"] == "porsche"
		and a["evts"].has("achat_voiture") and _proche(a["etat"]["credit"], 110000.0, 1e-9) and _proche(a["etat"]["voiture"], 140000.0, 1e-9))
	var delta := float(a["patrimoine"]) - float(tr["1987-03"]["patrimoine"])
	var gain_04 := 150000.0 * (725.0 / 740.0 - 1.0) - 150000.0 * 0.007
	verifier("04/1987 : achat sans effet sur le patrimoine (seuls gain et report du mois)", absf(delta - gain_04) < 0.01, str(delta))
	verifier("08/1987 : renfort, position 200 000 F", tr["1987-08"]["evts"].has("renfort")
		and _proche(tr["1987-08"]["etat"]["position"], 200000.0, 1e-6))
	var s9: Dictionary = tr["1987-09"]
	verifier("09/1987 : couverture restante 26 900 F ±1 %", _proche(s9["etat"]["equite"], 26900.0, 0.01), str(s9["etat"]["equite"]))
	verifier("09/1987 : crédit restant dû 100 833 F ±1 F", absf(s9["etat"]["credit"] - 100833.0) < 1.5, str(s9["etat"]["credit"]))
	verifier("09/1987 : 5 mensualités payées", s9["etat"]["mensualites"] == 5)
	verifier("09/1987 : patrimoine 49 082 F (S = 49 082, docs/26 §0 n°4)", _proche(s9["patrimoine"], 49082.0, 0.005), str(s9["patrimoine"]))
	var s10: Dictionary = tr["1987-10"]
	var lev: Dictionary = s10["etat"]["levier"]
	verifier("10/1987 : liquidation, étape liquide", s10["evts"].has("liquidation") and s10["etat"]["etape"] == "liquide"
		and s10["etat"]["position"] == 0.0 and s10["etat"]["equite"] == 0.0)
	verifier("10/1987 : perte 52 941 F ±1 %", _proche(lev["perte"], 52941.0, 0.01), str(lev["perte"]))
	verifier("10/1987 : dette 26 041 F ±1 %", _proche(s10["etat"]["dette"], 26041.0, 0.01), str(s10["etat"]["dette"]))
	var n := Quartier.levier_valeurs(lev)
	verifier("couverture + dette = perte, au franc près", n["couverture"] + n["dette"] == n["perte"], str(n))
	verifier("10/1987 : pas de report (équité = couverture + gain)", absf(float(lev["couverture"]) - float(s9["etat"]["equite"])) < 1e-6)
	var s11: Dictionary = tr["1987-11"]
	var part_bourse := float(s11["etat"]["equite"]) - float(s11["etat"]["dette"])
	verifier("11/1987 : la part « bourse » vaut −26 041 F ±1 %, comptée une seule fois", _proche(part_bourse, -26041.0, 0.01)
		and s11["etat"]["equite"] == 0.0, str(part_bourse))
	verifier("12/1987 : remboursement 1 000 F, étape rembourse", tr["1987-12"]["evts"].has("remboursement")
		and tr["1987-12"]["etat"]["etape"] == "rembourse")
	verifier("02/1988 : Porsche vendue, crédit soldé, 10 mensualités", tr["1988-02"]["evts"].has("vente_voiture")
		and tr["1988-02"]["etat"]["credit"] == 0.0 and tr["1988-02"]["etat"]["voiture"] == 0.0
		and tr["1988-02"]["etat"]["mensualites"] == 10)
	var s12: Dictionary = tr["1988-12"]
	verifier("12/1988 : dette restante ≈ 13 041 F", absf(s12["etat"]["dette"] - 13041.0) < 5.0, str(s12["etat"]["dette"]))
	verifier("12/1988 : patrimoine ≈ −47 712 F (docs/19 §2.5)", absf(s12["patrimoine"] + 47712.0) < 100.0, str(s12["patrimoine"]))
	# J1 : face à un Tata fabriqué (37 500 F + 4,5 %/an), devant de 03 à 09/1987
	var j1 := true
	var marge := 1e12
	for cle in ["1987-03", "1987-04", "1987-05", "1987-06", "1987-07", "1987-08", "1987-09"]:
		var mois := Dates.lire(cle) - Dates.lire("1986-08")
		var tata := 37500.0 * (1.0 + 0.045 * mois / 12.0)
		marge = minf(marge, float(tr[cle]["patrimoine"]) - tata)
		if float(tr[cle]["patrimoine"]) <= tata:
			j1 = false
	verifier("J1 sur miroir fabriqué : Jean-Mi devant un Tata fabriqué de 03 à 09/1987", j1, "marge min %.0f F" % marge)
	verifier("J2 sur miroir fabriqué : très en dessous de Tata en 12/1988", float(s12["patrimoine"]) < 37500.0 * 1.08 * 0.9)
	# Compte courant négatif toléré, patrimoine conservé à la vente
	verifier("Vente de la Porsche : mouvement = −mensualité − remboursement + prix − solde (91 199 F)", absf(float(tr["1988-02"]["mouvement"]) - (-2897.0 - 1000.0 + 91000.0 - 91199.0)) < 5.0,
		str(tr["1988-02"]["mouvement"]))
	# Compte négatif : couverture = plancher de temoins.json (lot 05-L B2 : couverture_min), jamais plus
	var r0 := Quartier.pas_mensuel(Quartier.jeanmi_initial(), Dates.lire("1986-09"), 520.0, 470.0, -500.0)
	var cmin := float(Quartier.plan_jeanmi().get("couverture_min", 0.0))
	verifier("Compte négatif à l'ouverture : couverture = le plancher du plan (couverture_min), position = levier × couverture", absf(float(r0["etat"]["couverture"]) - cmin) < 1e-9 and absf(float(r0["etat"]["position"]) - cmin * float(Quartier.plan_jeanmi()["levier"])) < 1e-9)
	# Avant l'ouverture : rien ne bouge
	var r1 := Quartier.pas_mensuel(Quartier.jeanmi_initial(), Dates.lire("1986-08"), 470.0, 440.0, 37500.0)
	verifier("08/1986 : Jean-Mi attend (mouvement 0)", r1["etat"]["etape"] == "attend" and r1["mouvement"] == 0.0)


func _tests_levier() -> void:
	var gab := str(Quartier.donnees_rue()["levier"])
	var sans := gab
	for k in ["{couverture}", "{position}", "{baisse}", "{perte}", "{dette}"]:
		sans = sans.replace(k, "")
	var chiffre := false
	for c in sans:
		if c.is_valid_int():
			chiffre = true
	verifier("Gabarit du levier : aucun chiffre en dur", not chiffre)
	var tr := _trajectoire()
	var lev: Dictionary = tr["1987-10"]["etat"]["levier"]
	var phrase := Quartier.phrase_levier(lev)
	# Recalcul indépendant, chiffres écrits à la main depuis docs/26 §2.2 (série de docs/19)
	var equite := 30000.0
	var pos := 150000.0
	var prec := 520.0
	for cle in ["1986-10", "1986-11", "1986-12", "1987-01", "1987-02", "1987-03", "1987-04", "1987-05", "1987-06", "1987-07", "1987-08", "1987-09"]:
		var c := float(PEUGEOT[cle])
		if cle == "1987-04":
			equite -= 30000.0
		if cle == "1987-08":
			pos = 200000.0
		equite += pos * (c / prec - 1.0) - pos * 0.007
		prec = c
	var perte := 200000.0 * (1.0 - 500.0 / 680.0)
	var couv_r := roundi(equite)
	var perte_r := roundi(perte)
	var f := func(x: int) -> String: return Format.nombre(x, 0) + Format.ESPACE + "F"
	var attendu := gab.replace("{couverture}", f.call(couv_r)).replace("{position}", f.call(200000)) \
		.replace("{baisse}", "26,5" + Format.ESPACE + "%").replace("{perte}", f.call(perte_r)).replace("{dette}", f.call(perte_r - couv_r))
	verifier("Phrase du levier == recalcul indépendant", phrase == attendu, phrase)
	verifier("Phrase : couverture 26 901 F, perte 52 941 F, dette 26 040 F (docs/26 §2.2)", couv_r == 26901 and perte_r == 52941
		and phrase.contains("26" + Format.ESPACE + "040" + Format.ESPACE + "F"), "%d %d" % [couv_r, perte_r])
	verifier("Phrase sans accolade restante", not phrase.contains("{") and phrase != "")
	verifier("Phrase du levier vide sans perte", Quartier.phrase_levier({}) == "")
	# V13 long : phrase + 2 phrases fixes ≤ 60 mots
	var v13: Dictionary = {}
	for p in Quartier.donnees_rue()["passages"]:
		if p["id"] == "V13":
			v13 = p
	var long_t := str(v13["texte_long"]).replace("{levier}", phrase)
	verifier("V13 long ≤ 60 mots", _mots(long_t) <= 60, str(_mots(long_t)))


func _p(j: float, l: float, m: float, jm: float) -> Dictionary:
	return {"vous": j, "livret": l, "matelas": m, "jeanmi": jm}


func _tests_classement() -> void:
	var c := Quartier.classement(_p(100.0, 120.0, 90.0, -5.0))
	verifier("Classement : 4 lignes triées, rangs 1-4", c.size() == 4 and c[0]["id"] == "livret" and c[1]["id"] == "vous"
		and c[2]["id"] == "matelas" and c[3]["id"] == "jeanmi" and c[3]["rang"] == 4)
	verifier("Classement : patrimoine négatif conservé", c[3]["patrimoine"] == -5.0)
	verifier("Classement : reference vrai pour Tata seulement", c[0]["reference"] and not c[1]["reference"] and c[1]["vous"])
	var ex := Quartier.classement(_p(100.0, 100.0, 100.0, 100.0))
	verifier("Égalité : le joueur devant, puis Tata, Matelas, Jean-Mi", ex[0]["id"] == "vous" and ex[1]["id"] == "livret"
		and ex[2]["id"] == "matelas" and ex[3]["id"] == "jeanmi")
	verifier("Relation à Jean-Mi : égalité = devant", Quartier.relation_jeanmi(ex) == "devant")
	var c2 := Quartier.classement(_p(50.0, 120.0, 90.0, 80.0))
	verifier("Relation : derrière, rang 4, champs du contrat", Quartier.relation_jeanmi(c2) == "derriere" and Quartier.rang_de(c2) == 4
		and c2[0].has("initiale") and c2[0].has("nom"))
	var rp := Quartier.replique_rue(c)
	verifier("Réplique : le voisin juste devant le joueur (Tata, « devant »)", rp["qui"] == "livret"
		and rp["texte"] == Donnees.temoins()["livret"]["devant"])
	var rp1 := Quartier.replique_rue(Quartier.classement(_p(500.0, 120.0, 90.0, -5.0)))
	verifier("Réplique : joueur 1er, le voisin juste derrière (« derriere »)", rp1["qui"] == "livret"
		and rp1["texte"] == Donnees.temoins()["livret"]["derriere"])
	var rpj := Quartier.replique_rue(Quartier.classement(_p(500.0, 120.0, 90.0, 300.0)))
	verifier("Réplique de Jean-Mi : jamais enviable (non vide)", rpj["qui"] == "jeanmi" and rpj["texte"] != "")


## Simule 60 mois (01/1984 -> 12/1988). pauses : mois (ab) à pause ; relations : fonction ab -> relation.
func _simuler(pauses: Callable, relation: Callable, declencheurs := {}) -> Dictionary:
	var q := Quartier.quartier_initial()
	var tout: Array = []
	for ab in range(Dates.lire("1984-01"), Dates.lire("1988-12") + 1):
		var ctx := {"pause": pauses.call(ab), "relation": relation.call(ab), "rang": 2,
			"declencheurs": declencheurs.get(ab, []), "projet_id": "P1C", "valeurs": {}}
		var r := Quartier.notifications_du_mois(ab, q, ctx)
		q = r["etat"]
		for n in r["notifs"]:
			tout.append({"ab": ab, "n": n, "pause": ctx["pause"]})
	return {"q": q, "notifs": tout}


func _verifier_budgets(nom: String, s: Dictionary) -> void:
	var par_mois := {}
	var dernier_voisin := -1000
	var dernier_rang := -1000
	var ok_voisin := true
	var ok_mois := true
	var ok_pause := true
	var ok_rang := true
	var ok_premier := true
	for x in s["notifs"]:
		var ab: int = x["ab"]
		var n: Dictionary = x["n"]
		par_mois[ab] = int(par_mois.get(ab, 0)) + 1
		if x["pause"]:
			ok_pause = false
		if n["type"] == "voisin":
			if ab - dernier_voisin < 2:
				ok_voisin = false
			dernier_voisin = ab
		if n["type"] == "rang":
			if ab - dernier_rang < 6:
				ok_rang = false
			if ab < Dates.lire("1986-10"):
				ok_premier = false
			dernier_rang = ab
	for k in par_mois:
		if par_mois[k] > 1:
			ok_mois = false
	verifier(nom + " : ≤ 1 voisin tous les 2 mois", ok_voisin)
	verifier(nom + " : ≤ 1 notification rue ou kiosque par mois", ok_mois)
	verifier(nom + " : aucune un mois à pause", ok_pause)
	verifier(nom + " : rang ≤ 1 tous les 6 mois, pas avant 10/1986", ok_rang and ok_premier)


func _tests_notifications() -> void:
	var pause := func(ab: int) -> bool: return ab % 5 == 3
	var rel := func(ab: int) -> String: return "devant" if int(ab / 3.0) % 2 == 0 else "derriere"
	var s := _simuler(pause, rel, {Dates.lire("1985-06"): ["achat_action"], Dates.lire("1986-04"): ["projet_realise"]})
	_verifier_budgets("Pauses 1 mois sur 5", s)
	var ids: Array = []
	var types := {}
	var kio: Array = []
	for x in s["notifs"]:
		types[x["n"]["type"]] = int(types.get(x["n"]["type"], 0)) + 1
		if x["n"]["type"] == "voisin":
			ids.append(x["n"]["id"])
		if x["n"]["type"] == "kiosque":
			kio.append(x["n"]["id"])
	for cle in ["V01", "V07", "V09", "V13", "V16"]:
		verifier("Passage ★ %s jamais abandonné" % cle, ids.has(cle))
	verifier("Réactives R01 et R02 dites, avec le texte du projet", ids.has("R01") and ids.has("R02"))
	for x in s["notifs"]:
		if x["n"].get("id", "") == "R02":
			verifier("R02 : texte propre au projet P1C", x["n"]["texte"] == "Belle Super 5 ! La 4L va manquer à la rue.")
	verifier("Rang : des notifications (cls gain/perte, source rue)", types.has("rang"))
	var ok_rang := true
	for x in s["notifs"]:
		if x["n"]["type"] == "rang" and (x["n"]["source"] != "rue" or not x["n"]["cls"] in ["gain", "perte"]):
			ok_rang = false
	verifier("Rang : champs du contrat", ok_rang)
	# kiosque : chaque titre une fois, à sa date ou 1 mois après
	var rue := Quartier.donnees_rue()
	var ok_k := true
	for x in s["notifs"]:
		if x["n"]["type"] == "kiosque":
			for k in rue["kiosque"]:
				if k["id"] == x["n"]["id"]:
					var d: int = x["ab"] - Dates.lire(str(k["mois"]))
					if d < 0 or d > 1:
						ok_k = false
	verifier("Kiosque : à sa date ou 1 mois après", ok_k)
	verifier("Kiosque : aucun titre en double", _uniques(kio))
	var q: Dictionary = s["q"]
	verifier("Kiosque : titres vus + abandonnés = 11", q["kiosque_vus"].size() + q["kiosque_abandonnes"].size() == 11,
		"vus %d, abandonnés %d" % [q["kiosque_vus"].size(), q["kiosque_abandonnes"].size()])
	print("INFO passages abandonnés : ", q["abandonnes"], " ; kiosque abandonnés : ", q["kiosque_abandonnes"])
	# Structure d'une notification de voisin et de kiosque
	var vn: Dictionary = {}
	var kn: Dictionary = {}
	for x in s["notifs"]:
		if x["n"]["type"] == "voisin" and vn.is_empty() and x["n"]["id"] == "V01":
			vn = x["n"]
		if x["n"]["type"] == "kiosque" and kn.is_empty():
			kn = x["n"]
	verifier("Voisin V01 : champs du contrat, long", vn["source"] == "rue" and vn["cls"] == "neutre" and vn["qui"] == "lopez"
		and vn["titre"] == "Mme Lopez" and vn["cle"] and vn["long"] and vn.has("texte_long") and vn.has("texte"))
	verifier("Kiosque : champs du contrat", kn["source"] == "media" and kn["titre"] == "LA GAZETTE" and kn["cls"] == "neutre")
	# Priorité d'un même mois : rang avant ★ (relation qui change le mois d'une ★)
	var q0 := Quartier.quartier_initial()
	q0["relation"] = "devant"
	q0["passages_vus"] = ["V01", "V02", "V03", "V04", "V05", "V06"]
	var r := Quartier.notifications_du_mois(Dates.lire("1986-10"), q0, {"pause": false, "relation": "derriere", "rang": 3})
	verifier("Priorité : le rang passe avant le passage ★ de 09/1986 en retard", r["notifs"].size() == 1 and r["notifs"][0]["type"] == "rang")
	var r2 := Quartier.notifications_du_mois(Dates.lire("1986-11"), r["etat"], {"pause": false, "relation": "derriere", "rang": 3})
	verifier("Mois suivant : le passage ★ en retard (V07)", r2["notifs"].size() == 1 and r2["notifs"][0]["id"] == "V07")
	# Réactive avant passage ordinaire
	var q1 := Quartier.quartier_initial()
	q1["passages_vus"] = ["V01"]
	var r3 := Quartier.notifications_du_mois(Dates.lire("1984-05"), q1, {"pause": false, "declencheurs": ["achat_action"]})
	verifier("Priorité : la réactive avant V02 (passage ordinaire)", r3["notifs"][0]["id"] == "R01")
	# V13 : texte long rempli avec le levier fourni
	var q2 := Quartier.quartier_initial()
	q2["passages_vus"] = ["V01", "V02", "V03", "V04", "V05", "V06", "V07", "V08", "V09", "V10"]
	q2["kiosque_vus"] = ["K01"]
	var r4 := Quartier.notifications_du_mois(Dates.lire("1987-12"), q2, {"pause": false, "valeurs": {"levier": "LEVIER"}})
	verifier("V13 : texte_long contient la phrase du levier fournie", r4["notifs"][0]["id"] == "V13"
		and str(r4["notifs"][0]["texte_long"]).contains("LEVIER") and not str(r4["notifs"][0]["texte_long"]).contains("{"))
	# Lefranc supprimé
	verifier("Réaction de M. Lefranc supprimée", not str(Quartier.donnees_rue()["reactives"]).contains("lefranc"))


func _uniques(a: Array) -> bool:
	var vus := {}
	for x in a:
		if vus.has(x):
			return false
		vus[x] = true
	return true


func _tests_budgets_extremes() -> void:
	# Quasi tous les mois à pause (sauf 1 sur 4) et relation qui change tous les mois : budgets toujours tenus, ★ jamais perdus
	var pause := func(ab: int) -> bool: return ab % 3 != 2
	var rel := func(ab: int) -> String: return "devant" if ab % 2 == 0 else "derriere"
	var s := _simuler(pause, rel)
	_verifier_budgets("Pauses 2 mois sur 3", s)
	var ids: Array = []
	for x in s["notifs"]:
		if x["n"]["type"] == "voisin":
			ids.append(x["n"]["id"])
	var etoiles := true
	for cle in ["V01", "V07", "V09", "V13", "V16"]:
		if not ids.has(cle):
			etoiles = false
	verifier("Pauses 2 mois sur 3 : les 5 ★ arrivent quand même", etoiles, str(ids))
	# Aucun mois sans pause : rien, jamais d'erreur
	var s2 := _simuler(func(_ab: int) -> bool: return true, rel)
	verifier("Toujours en pause : aucune notification", s2["notifs"].is_empty())
	# Un état n'est jamais modifié en place
	var q := Quartier.quartier_initial()
	var avant := var_to_str(q)
	Quartier.notifications_du_mois(Dates.lire("1984-02"), q, {"pause": false})
	verifier("L'état d'entrée n'est pas modifié", var_to_str(q) == avant)
	# Sérialisation
	var q2: Dictionary = Quartier.notifications_du_mois(Dates.lire("1984-02"), q, {"pause": false})["etat"]
	verifier("État sérialisable (var_to_bytes)", bytes_to_var(var_to_bytes(q2)) == q2)
	var j := Quartier.jeanmi_initial()
	verifier("État de Jean-Mi sérialisable", bytes_to_var(var_to_bytes(j)) == j)


func _tous_les_textes(x: Variant, out: Array) -> void:
	if x is String:
		out.append(x)
	elif x is Dictionary:
		for k in x:
			_tous_les_textes(x[k], out)
	elif x is Array:
		for v in x:
			_tous_les_textes(v, out)


func _tests_textes() -> void:
	var textes: Array = []
	_tous_les_textes(Donnees.charger("rue"), textes)
	_tous_les_textes(Donnees.charger("krach"), textes)
	_tous_les_textes(Donnees.temoins()["jeanmi"], textes)
	var fautif := ""
	for t in textes:
		for m in MOTS_INTERDITS:
			if str(t).to_lower().contains(m):
				fautif = str(t)
	verifier("Aucun « achetez », « vendez », « c'est le moment », « auriez dû » dans rue / krach / jeanmi", fautif == "", fautif)
	verifier("%d textes contrôlés" % textes.size(), textes.size() > 40)
