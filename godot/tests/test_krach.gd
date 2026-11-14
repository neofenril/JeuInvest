extends SceneTree
## Tests de Krach (lot 05-L phase A) : 7 jours du Lundi noir, instantané, 3 barres « un an après ».
## Barres recalculées à la main (chiffres écrits dans le test) sur 2 portefeuilles fabriqués et l'exemple, puis
## comparées au moteur réel (EtatPartie : devis de vente totale, devis d'achat).
## Lancer : Godot_console --headless --path godot --script res://tests/test_krach.gd

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_jours()
	_tests_barres_fabriquees()
	_tests_exemple()
	_tests_contenu()
	_tests_moteur()
	print("")
	print("=== test_krach : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _proche(a: float, b: float, tol := 1e-6) -> bool:
	return absf(a - b) <= tol


func _courtage(brut: float) -> float:
	return maxf(5.0, 0.01 * brut)


func _mots(t: String) -> int:
	return t.split(" ", false).size()


func _tests_jours() -> void:
	var j := Krach.jours()
	var d := Krach.donnees()
	verifier("7 jours du Lundi noir", j.size() == 7 and d["jours"].size() == 7)
	var egal := true
	for i in 7:
		if j[i]["jour"] != d["jours"][i]["jour"] or j[i]["indice"] != d["jours"][i]["indice"] or j[i]["certitude"] != d["jours"][i]["certitude"]:
			egal = false
	verifier("Jours == krach.json (jour, indice, certitude)", egal)
	verifier("Variation 0,0 le 1er jour, −9,7 % le lundi 19 (A)", j[0]["variation"] == 0.0 and _proche(j[1]["variation"], -9.7))
	var attendu := [0.0, -9.7, -6.2, 3.3, -3.7, -2.4, -2.9]
	var ok := true
	for i in 7:
		if not _proche(j[i]["variation"], attendu[i], 0.001):
			ok = false
	verifier("Variations calculées par le code, au dixième (docs/26 §3.2)", ok, str(j.map(func(x): return x["variation"])))
	verifier("Certitudes A, A, C×5", j[0]["certitude"] == "A" and j[1]["certitude"] == "A" and j[6]["certitude"] == "C")
	verifier("Indice du 19/10 : 1 119,7 ; 1er jour : vendredi 16 octobre", j[1]["indice"] == 1119.7 and j[0]["jour"] == "vendredi 16 octobre")
	verifier("Libellé de l'indice : jamais « CAC 40 »", not str(d["indice_nom"]).contains("CAC") and d["arrondi_points"] == 5)


## Portefeuille 1 : SICAV en perte + action en gain.
func _inst1(choix := "") -> Dictionary:
	return {"ab": Dates.lire("1987-10"), "cc": 5600.0, "montant_renforcer": 1400.0, "choix": choix, "exemple": false,
		"lignes": [
			{"id": "s", "nom": "S", "type": "sicav", "qte": 100.0, "cout": 6000.0, "cours": 50.0},
			{"id": "a", "nom": "A", "type": "action", "qte": 20.0, "cout": 1500.0, "cours": 100.0}]}


func _ctx(cours_fin: Dictionary, div: Dictionary, facteur: float, impot := 0.2) -> Dictionary:
	return {"cours_fin": cours_fin, "dividendes": div, "taux_impot": impot, "courtage": Callable(self, "_courtage"),
		"entree_sicav": 0.02, "facteur_livret": facteur}


func _tests_barres_fabriquees() -> void:
	# Portefeuille 1, à la main :
	#  vendu : SICAV 100×50 = 5 000, moins-value (cout 6 000) : pas d'impôt -> 5 000 ;
	#          action 20×100 = 2 000, courtage max(5 ; 1 %) = 20, net 1 980, plus-value 480, impôt 20 % = 96 -> 1 884 ;
	#          total 6 884 × 1,03 = 7 090,52
	#  rien : 100×70 + 20×(130 + 4) = 7 000 + 2 680 = 9 680
	#  renforcé : base 7 000 ; SICAV 1 000 -> 1 000×0,98/50 = 19,6 parts × 70 = 1 372 ;
	#          action 400 : 4 titres + courtage 5 = 405 > 400 -> 3 titres (305) × 134 = 402 ; extra 1 774 -> 11 454 ; mise 1 305
	var r := Krach.calculer(_inst1(), _ctx({"s": 70.0, "a": 130.0}, {"a": 4.0}, 1.03))
	verifier("Portefeuille 1 : base 7 000", _proche(r["base"], 7000.0))
	verifier("Portefeuille 1 : tout vendu 7 090,52", _proche(r["vendu"], 7090.52), str(r["vendu"]))
	verifier("Portefeuille 1 : rien fait 9 680", _proche(r["rien"], 9680.0), str(r["rien"]))
	verifier("Portefeuille 1 : renforcé 11 454 (titres entiers, frais compris)", _proche(r["renforce"], 11454.0), str(r["renforce"]))
	verifier("Portefeuille 1 : mise 1 305", _proche(r["mise"], 1305.0), str(r["mise"]))
	# Portefeuille 2 : une action en gain, aucun renfort possible
	var i2 := {"ab": 0, "cc": 0.0, "montant_renforcer": 0.0, "choix": "", "exemple": false,
		"lignes": [{"id": "b", "nom": "B", "type": "action", "qte": 10.0, "cout": 1000.0, "cours": 200.0}]}
	#  vendu : 2 000 - courtage 20 = 1 980 ; plus-value 980 ; impôt 196 -> 1 784 ; rien : 10×150 = 1 500 ; renforcé = rien
	var r2 := Krach.calculer(i2, _ctx({"b": 150.0}, {}, 1.0))
	verifier("Portefeuille 2 : 1 784 / 1 500 / 1 500", _proche(r2["vendu"], 1784.0) and _proche(r2["rien"], 1500.0)
		and _proche(r2["renforce"], 1500.0) and r2["mise"] == 0.0, str(r2))
	# Portefeuille 3 : deux SICAV, cours fin absent (= cours du krach), sans impôt
	var i3 := {"ab": 0, "cc": 400.0, "montant_renforcer": 100.0, "choix": "", "exemple": false,
		"lignes": [{"id": "x", "nom": "X", "type": "sicav", "qte": 10.0, "cout": 300.0, "cours": 20.0},
			{"id": "y", "nom": "Y", "type": "sicav", "qte": 5.0, "cout": 100.0, "cours": 20.0}]}
	#  base 300 ; vendu 300 ×1,01 = 303 ; rien 300 (cours fin = cours) ; renforcé : x 66,67 -> ×0,98/20... total 100×0,98 = 98 parts-valeur
	var r3 := Krach.calculer(i3, _ctx({}, {}, 1.01))
	verifier("Portefeuille 3 : 303 / 300 / 398", _proche(r3["vendu"], 303.0) and _proche(r3["rien"], 300.0)
		and _proche(r3["renforce"], 398.0), str(r3))
	# Sans Callable de courtage : frais nuls
	var r4 := Krach.calculer(i2, {"cours_fin": {"b": 150.0}, "taux_impot": 0.0})
	verifier("Sans courtage ni impôt : vendu = valeur au krach", _proche(r4["vendu"], 2000.0))


func _tests_exemple() -> void:
	# 10 000 de SICAV à 50 : 200 parts ; renfort 50 % = 5 000.
	var inst := Krach.instantane_exemple("sicav", 50.0, 10000.0, Dates.lire("1987-10"))
	verifier("Exemple : instantané marqué, 1 ligne SICAV, renfort 5 000", inst["exemple"] and inst["lignes"].size() == 1
		and _proche(inst["lignes"][0]["qte"], 200.0) and _proche(inst["montant_renforcer"], 5000.0))
	var r := Krach.calculer(inst, _ctx({"sicav": 60.0}, {}, 1.04, 0.16))
	#  vendu 10 000 × 1,04 = 10 400 ; rien 200 × 60 = 12 000 ; renforcé : 5 000×0,98/50 = 98 parts × 60 = 5 880 -> 17 880
	verifier("Exemple : 10 400 / 12 000 / 17 880", _proche(r["vendu"], 10400.0) and _proche(r["rien"], 12000.0)
		and _proche(r["renforce"], 17880.0) and _proche(r["mise"], 5000.0), str(r))
	var c := Krach.contenu_gazette(Krach.completer(inst, "rien"), _ctx({"sicav": 60.0}, {}, 1.04, 0.16), Dates.lire("1988-10"))
	var choisis: Array = c["barres"].filter(func(b): return b["choisi"])
	verifier("Exemple : mention non vide, aucune barre entourée", c["mention"] != "" and choisis.is_empty(), c["mention"])


func _tests_contenu() -> void:
	var ab := Dates.lire("1988-10")
	var c := Krach.contenu_gazette(Krach.completer(_inst1(), "renforcer"), _ctx({"s": 70.0, "a": 130.0}, {"a": 4.0}, 1.03), ab)
	verifier("Contenu : clés du contrat", c["kind"] == "gazette" and c["source"] == "media" and c["ab"] == ab
		and c["date"] == "OCTOBRE 1988" and c["titre"] == "LE KRACH, UN AN APRÈS" and c.has("texte") and c.has("mention")
		and c.has("base") and c["choix"] == [{"id": "ok", "titre": "J'AI COMPRIS"}])
	verifier("Contenu : 3 barres dans l'ordre vendu, rien, renforcé", c["barres"].map(func(b): return b["id"]) == ["vendu", "rien", "renforce"])
	var choisis: Array = c["barres"].filter(func(b): return b["choisi"])
	verifier("Contenu : un seul choix entouré (renforcé), mention vide", choisis.size() == 1 and choisis[0]["id"] == "renforce" and c["mention"] == "")
	for ch in ["vendre", "rien"]:
		var cc := Krach.contenu_gazette(Krach.completer(_inst1(), ch), _ctx({"s": 70.0, "a": 130.0}, {}, 1.0), ab)
		var e: Array = cc["barres"].filter(func(b): return b["choisi"])
		verifier("Choix %s : barre entourée correspondante" % ch, e.size() == 1 and e[0]["id"] == {"vendre": "vendu", "rien": "rien"}[ch])
	var cn := Krach.contenu_gazette(Krach.completer(_inst1(), "ecart"), _ctx({"s": 70.0, "a": 130.0}, {}, 1.0), ab)
	verifier("Choix hors des 3 : aucune barre entourée", cn["barres"].filter(func(b): return b["choisi"]).is_empty())
	var u: Dictionary = Krach.donnees()["un_an_apres"]
	verifier("Texte « un an après » ≤ 50 mots (blancs comptés), sans « vous auriez dû »", _mots(u["texte"]) <= 50
		and not str(u["texte"]).to_lower().contains("auriez dû"), str(_mots(u["texte"])))
	verifier("Barres : valeurs == calculer()", _proche(c["barres"][1]["valeur"], 9680.0) and _proche(c["barres"][2]["valeur"], 11454.0))


func _tests_moteur() -> void:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(7))
	StrategieTest.aller_a(e, Dates.lire("1986-06"), false)
	while not e.modale.is_empty():
		e.resolution_auto()
	e.joueur.cc += Produits.f(20000.0)
	for id in ["elf", "peugeot"]:
		verifier("Achat d'action %s" % id, e.acheter(e.joueur, id, Produits.f(5000.0))["ok"])
	verifier("Achat de SICAV", e.acheter(e.joueur, "sicav", Produits.f(5000.0))["ok"])
	var avant := var_to_bytes(e.vers_dict()).hex_encode().sha256_text()
	var inst := Krach.instantane(e)
	var apres := var_to_bytes(e.vers_dict()).hex_encode().sha256_text()
	verifier("Instantané en lecture seule (état identique)", avant == apres)
	verifier("Instantané : 3 lignes, types, quantités et cours du moteur", inst["lignes"].size() == 3 and not inst["exemple"]
		and inst["choix"] == "")
	var ok_l := true
	for l in inst["lignes"]:
		if l["qte"] != e.joueur.qte(l["id"]) or l["cours"] != e.cours(l["id"]) or l["cout"] != e.joueur.cout(l["id"]):
			ok_l = false
		if l["type"] != str(e.produit(l["id"])["type"]):
			ok_l = false
	verifier("Instantané : champs recopiés du moteur", ok_l)
	verifier("Instantané : montant du renfort = 25 % du compte courant", _proche(inst["montant_renforcer"], 0.25 * e.joueur.cc, 1e-9))
	# « Tout vendu » (sans Livret A) == somme reçue de la vente totale du moteur
	var a := e.ab_courant()
	var ctx := {"cours_fin": {}, "dividendes": {}, "taux_impot": float(Marche.impot(a)["cto"]) / 100.0,
		"courtage": func(b: float) -> float: return Marche.frais_courtage(a, b),
		"entree_sicav": float(Donnees.regles()["sicav"]["entree"]) / 100.0, "facteur_livret": 1.0}
	var r := Krach.calculer(inst, ctx)
	var recu := float(e.devis_vente_totale(e.joueur)["recu"])
	verifier("Tout vendu == vente totale du moteur (frais et impôt)", _proche(r["vendu"], recu, 1e-6), "%f / %f" % [r["vendu"], recu])
	# « Renforcé » : l'argent dépensé == somme des devis d'achat du moteur, aux mêmes proportions
	var total := 0.0
	var base_v := Krach.base(inst)
	for l in inst["lignes"]:
		var budget := float(inst["montant_renforcer"]) * float(l["qte"]) * float(l["cours"]) / base_v
		var d := e.devis_achat(l["id"], budget)
		if d["ok"]:
			total += float(d["total"])
	verifier("Mise du renfort == devis d'achat du moteur", _proche(r["mise"], total, 1e-6), "%f / %f" % [r["mise"], total])
	verifier("Sans variation de cours : rien fait == valeur au krach", _proche(r["rien"], base_v, 1e-6))
