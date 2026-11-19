extends SceneTree
## Lot 10a-moteur, CA-M5 : records v2 (double record chapitre / partie, collection par chapitre, migration du format 1,
## idempotence, fichiers tronqués ou illisibles). Jamais d'écriture du vrai fichier : chemins user://test_records_v2_<pid>*.

var _ok := 0
var _ko := 0


func _chemin(suffixe := "") -> String:
	return "user://test_records_v2_%d%s.sav" % [OS.get_process_id(), suffixe]


func _bilan(chap: String, annee_fin: int, titres: Array, pct_partie: float, pct_chapitre: float, possible := true) -> Dictionary:
	var liste := []
	for i in titres.size():
		liste.append({"chapitre": titres[i][0], "id": titres[i][1], "nom": "Titre " + str(titres[i][1]), "pourquoi": "p", "ordre": i + 1})
	var dernier: Dictionary = liste[liste.size() - 1]
	return {"titre": dernier, "titres": liste, "chapitre_depart": chap, "annee_fin": annee_fin, "ecart_tata_pct": pct_partie,
		"record_chapitre": {"ecart_pct": pct_chapitre, "rang": 2, "annee_fin": 1988}, "record_partie": {"ecart_pct": pct_partie, "rang": 1, "annee_fin": annee_fin},
		"hors_record": not possible, "record_possible": possible, "prenom": "Gérard", "nominal": {"vous": 1000.0}, "rue": []}


func _initialize() -> void:
	var c := _chemin()
	Records.effacer(c)
	# Partie 1984 -> 1993 : 2 titres (un par chapitre), écart 12 % en 1988, 20 % en 1993
	var b1 := _bilan("1984", 1993, [["1984", "bon_pere"], ["1989", "fourmi"]], 20.0, 12.0)
	var r1 := Records.enregistrer(b1, "p1", c, "2026-11-19")
	var l1 := Records.lire(c)
	var ch: Dictionary = l1["chapitres"]["1984"]
	verifier("Double record : record de chapitre 12 % (à la fin de 1988), record de partie 20 % rangé sous 1993",
		r1["nouveau_chapitre"] and r1["nouveau_partie"] and is_equal_approx(float(ch["record_chapitre"]["ecart_pct"]), 12.0)
		and is_equal_approx(float(ch["records_partie"]["1993"]["ecart_pct"]), 20.0) and int(ch["records_partie"]["1993"]["annee_fin"]) == 1993)
	verifier("Un titre par chapitre traversé : bon_pere dans la collection de 1984, fourmi dans celle de 1989",
		ch["collection"].has("bon_pere") and not ch["collection"].has("fourmi") and l1["chapitres"]["1989"]["collection"].has("fourmi")
		and r1["nouveaux_titres"].size() == 2)
	verifier("lire : vue de compatibilité « record » / « collection » = chapitre par défaut", l1["record"] == ch["record_chapitre"] and l1["collection"] == ch["collection"])
	# Idempotence
	var avant := FileAccess.get_file_as_string(c)
	var r2 := Records.enregistrer(b1, "p1", c, "2026-11-20")
	verifier("Idempotence : la même partie n'est pas comptée deux fois, fichier identique", r2["deja_compte"] and not r2["ecrit"] and FileAccess.get_file_as_string(c) == avant)
	# Records séparés : partie finie en 1988 (5 ans) -> record de partie sous « 1988 », record de chapitre comparé
	var b2 := _bilan("1984", 1988, [["1984", "marin"]], 15.0, 15.0)
	var r3 := Records.enregistrer(b2, "p2", c, "2026-11-21")
	var l3 := Records.lire(c)
	verifier("Partie en 5 ans : nouveau record de chapitre (15 > 12) ; records de partie séparés par année de fin (1988 et 1993)",
		r3["nouveau_chapitre"] and r3["nouveau_partie"] and is_equal_approx(float(l3["chapitres"]["1984"]["record_chapitre"]["ecart_pct"]), 15.0)
		and l3["chapitres"]["1984"]["records_partie"].has("1988") and l3["chapitres"]["1984"]["records_partie"].has("1993"))
	var b3 := _bilan("1984", 1993, [["1984", "fourmi"], ["1989", "fourmi"]], 18.0, 9.0)
	var r4 := Records.enregistrer(b3, "p3", c, "2026-11-22")
	var l4 := Records.lire(c)
	verifier("Moins bon : ni record de chapitre ni record de partie 1993 (20 % reste) ; la collection compte quand même",
		not r4["nouveau_chapitre"] and not r4["nouveau_partie"] and is_equal_approx(float(l4["chapitres"]["1984"]["records_partie"]["1993"]["ecart_pct"]), 20.0)
		and int(l4["chapitres"]["1984"]["collection"]["fourmi"]["nombre"]) == 1 and int(l4["chapitres"]["1989"]["collection"]["fourmi"]["nombre"]) == 2)
	var b4 := _bilan("1989", 1993, [["1989", "cigale"]], 40.0, 40.0)
	var r5 := Records.enregistrer(b4, "p4", c, "2026-11-23")
	var l5 := Records.lire(c)
	verifier("Départ en 1989 : records rangés sous « 1989 », indépendants de ceux de 1984",
		r5["nouveau_chapitre"] and is_equal_approx(float(l5["chapitres"]["1989"]["record_chapitre"]["ecart_pct"]), 40.0)
		and is_equal_approx(float(l5["chapitres"]["1984"]["record_chapitre"]["ecart_pct"]), 15.0))
	var b5 := _bilan("1989", 1993, [["1989", "cigale"]], 90.0, 90.0, false)
	var r6 := Records.enregistrer(b5, "p5", c, "2026-11-24")
	verifier("Hors record (retours) : collection mise à jour, aucun record", r6["hors_record"] and not r6["nouveau_chapitre"] and not r6["nouveau_partie"]
		and int(Records.lire(c)["chapitres"]["1989"]["collection"]["cigale"]["nombre"]) == 2)
	# Migration d'un fichier v1 (copie fabriquée à la main)
	var cv1 := _chemin("_v1")
	var v1 := "[meta]\n\nversion=1\n\n[record]\n\necart_pct=8.2\nrang=2\ntitre_id=\"bon_pere\"\ntitre_nom=\"Le bon père\"\nprenom=\"Gérard\"\npatrimoine=123456.5\ndate_reelle=\"2026-11-14\"\n\n[collection]\n\nbon_pere={\n\"nombre\": 2,\n\"premiere\": \"2026-11-14\"\n}\nfourmi={\n\"nombre\": 1,\n\"premiere\": \"2026-11-15\"\n}\n\n[parties]\n\nids=[\"a\", \"b\"]\n\n; fin\n"
	_ecrire(cv1, v1)
	var lv := Records.lire(cv1)
	var m: Dictionary = lv["chapitres"].get("1984", {})
	verifier("Migration v1 : record conservé comme record de chapitre de 1984 (8,2 %, titre, date), collection conservée (2 titres)",
		not m.is_empty() and is_equal_approx(float(m["record_chapitre"]["ecart_pct"]), 8.2) and m["record_chapitre"]["titre_id"] == "bon_pere" and m["record_chapitre"]["date_reelle"] == "2026-11-14"
		and int(m["record_chapitre"]["annee_fin"]) == 1988 and int(m["collection"]["bon_pere"]["nombre"]) == 2 and m["collection"].has("fourmi"))
	var rm := Records.enregistrer(_bilan("1984", 1988, [["1984", "marin"]], 5.0, 5.0), "a", cv1, "2026-11-25")
	verifier("Migration v1 : un id de partie déjà compté (v1) reste compté", rm["deja_compte"])
	var rm2 := Records.enregistrer(_bilan("1984", 1988, [["1984", "marin"]], 5.0, 5.0), "nouvelle", cv1, "2026-11-25")
	var texte := FileAccess.get_file_as_string(cv1)
	verifier("Migration v1 : à la première écriture le fichier passe en version 2 sans perdre le record (8,2 % reste devant 5 %)",
		rm2["ecrit"] and texte.contains("version=2") and not rm2["nouveau_chapitre"] and is_equal_approx(float(Records.lire(cv1)["chapitres"]["1984"]["record_chapitre"]["ecart_pct"]), 8.2))
	# Fichiers invalides
	var ci := _chemin("_inv")
	var complet := FileAccess.get_file_as_string(c)
	var vide := {"chapitres": {}, "record": {}, "collection": {}}
	_ecrire(ci, complet.substr(0, complet.length() >> 1))
	var ok_inv := Records.lire(ci) == vide
	_ecrire(ci, "")
	ok_inv = ok_inv and Records.lire(ci) == vide
	_ecrire(ci, "n'importe quoi\n\u0001 [ ] = ;;")
	ok_inv = ok_inv and Records.lire(ci) == vide
	_ecrire(ci, complet.replace("version=2", "version=7"))
	ok_inv = ok_inv and Records.lire(ci) == vide
	verifier("Fichiers tronqué, vide, illisible, version inconnue : vides, sans erreur", ok_inv)
	verifier("Jamais d'écriture du vrai fichier : les chemins de test sont des user://test_records_v2_*", c != Records.CHEMIN and ci != Records.CHEMIN)
	for p in [c, cv1, ci]:
		Records.effacer(p)
	print("")
	print("=== test_records_v2 : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func _ecrire(chemin: String, t: String) -> void:
	var f := FileAccess.open(chemin, FileAccess.WRITE)
	f.store_string(t)
	f.close()


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
