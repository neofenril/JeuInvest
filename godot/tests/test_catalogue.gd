extends SceneTree
## Lot 10a-moteur, CA-M3 / C8 : catalogue des produits du monde (data/produits.json).
## - le catalogue reproduit champ pour champ les fiches et paramètres de l'ancien banque.json de 1984 (copie de main :
##   tests/donnees/banque_1984_avant_catalogue.json) ;
## - ids uniques, type connu, naissance valide, produits des présentations et du carnet présents au catalogue,
##   présentation datée jamais avant la naissance du produit, un produit au plus une fois par présentation.

const TYPES := ["cc", "livret", "pel", "emprunt", "av", "sicav", "action", "pea", "scpi", "message"]
const MODES := ["jouable", "message", "silhouette"]

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var cat := Donnees.charger("produits")
	var ids := []
	for id in cat:
		if not str(id).begins_with("_"):
			ids.append(id)
	verifier("Catalogue : %d produits (cc, livret, pel, emprunt, av, sicav, 4 actions, BNP, SICAV monétaire, PEA, SCPI, PEP)" % ids.size(), ids.size() == 15)
	var champs_ok := true
	var detail := ""
	for id: String in ids:
		var p: Dictionary = cat[id]
		var ok_p := TYPES.has(str(p.get("type", ""))) and MODES.has(str(p.get("mode_defaut", ""))) and p.has("nom") and p.has("court") and p.has("famille") \
			and p.has("notes") and p.has("mots") and Dates.lire(str(p.get("naissance", "0000-00"))) > 0 and ["A", "B", "C"].has(str(p.get("certitude", "")))
		if p.has("fin"):
			ok_p = ok_p and Dates.lire(str(p["fin"])) >= Dates.lire(str(p["naissance"]))
		if not ok_p:
			champs_ok = false
			detail += id + " "
	verifier("C8 : chaque produit a un type connu, un mode, des notes, des mots, une naissance valide et une certitude", champs_ok, detail)

	# Comparaison champ à champ avec l'ancien banque.json
	var f := FileAccess.open("res://tests/donnees/banque_1984_avant_catalogue.json", FileAccess.READ)
	var ancien: Dictionary = JSON.parse_string(f.get_as_text())
	var egal := true
	var diff := ""
	for id: String in ancien["produits"]:
		var a: Dictionary = ancien["produits"][id]
		var n: Dictionary = cat.get(id, {})
		for k in a:
			if not n.has(k) or JSON.stringify(n[k]) != JSON.stringify(a[k]):
				egal = false
				diff += "%s.%s " % [id, k]
	verifier("CA-M3 : le catalogue reproduit champ pour champ les 10 fiches de 1984 (texte, notes, mots, frais)", egal, diff)
	var par_ok := true
	for k in ancien["parametres"]:
		if JSON.stringify(Produits.params().get(k, null)) != JSON.stringify(ancien["parametres"][k]):
			par_ok = false
			diff += "param " + k
	verifier("CA-M3 : Produits.params() = anciens parametres (pel, av, emprunt, succession)", par_ok, diff)
	verifier("Produits.params() renvoie le même dictionnaire à chaque appel", Produits.params() == Produits.params() and is_same(Produits.params(), Produits.params()))
	verifier("Banquier.info_produit lit le catalogue", Banquier.info_produit("pel")["court"] == "PEL" and Banquier.info_produit("n_importe_quoi").is_empty())

	# Présentations et carnet du chapitre 1984
	var b := Banquier.donnees()
	var pres_ok := true
	var detail_p := ""
	for pid: String in b["presentations"]:
		var pr: Dictionary = b["presentations"][pid]
		var vus := {}
		for prod: String in pr["produits"]:
			if not cat.has(prod) or vus.has(prod):
				pres_ok = false
				detail_p += "%s/%s " % [pid, prod]
			vus[prod] = true
			var h := str(pr.get("historique", ""))
			if h != "" and cat.has(prod) and Dates.lire(h) < Dates.lire(str(cat[prod]["naissance"])):
				pres_ok = false
				detail_p += "date %s/%s " % [pid, prod]
	verifier("C8 : chaque présentation de 1984 cite des produits du catalogue, une seule fois, jamais avant leur naissance", pres_ok, detail_p)
	var carnet_ok := true
	for prod in b["ordre_carnet"]:
		if not cat.has(prod):
			carnet_ok = false
	verifier("C8 : tout produit de l'ordre_carnet existe au catalogue", carnet_ok)
	var tout_present := true
	var vus_globaux := {}
	for pid: String in b["presentations"]:
		for prod: String in b["presentations"][pid]["produits"]:
			if vus_globaux.has(prod):
				tout_present = false
			vus_globaux[prod] = true
	verifier("C8 : un produit est présenté au plus une fois par chapitre", tout_present)
	# Types connus du moteur pour les nouveaux produits
	verifier("PEA, SCPI et PEP : types « pea », « scpi », « message » ; PEA né le 1992-07, PEP le 1990-01 (docs/46)",
		cat["pea"]["type"] == "pea" and cat["pea"]["naissance"] == "1992-07" and cat["scpi"]["type"] == "scpi" and cat["pep"]["type"] == "message" and cat["pep"]["naissance"] == "1990-01")
	verifier("BNP : action née en 10/1993 ; SCPI : paramètres de docs/47 §3.1 en données (part 1 000 F, frais 10 %, délai 3 mois)",
		cat["bnp"]["type"] == "action" and cat["bnp"]["naissance"] == "1993-10" and float(Produits.params()["scpi"]["part_F"]) == 1000.0
		and float(Produits.params()["scpi"]["frais_entree_pct"]) == 10.0 and int(Produits.params()["scpi"]["delai_vente_mois"]) == 3)
	print("")
	print("=== test_catalogue : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
