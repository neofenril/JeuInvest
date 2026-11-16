extends Node
## Tests du lot 07-L : record personnel et collection (Records), écriture à la fin d'une partie (Partie), compatibilité des
## sauvegardes d'avant le lot. CA-T7 (fichier absent / tronqué / autre version, meilleur écart, égalité, hors record,
## double fin, abandon, faillite, sauvegarde_auto faux), CA-T8 (reprise d'une sauvegarde de la base 0.5 et de main 0.4).
## Scène : l'autoload Partie est utilisé. Tout est synchrone dans _ready.
## Fichiers : user://test_records_<pid>.sav et user://test_records_<pid>_rec.sav seulement (effacés) ; jamais records.sav
## du joueur ni partie_en_cours.sav (l'empreinte de records.sav est contrôlée par tests.ps1).
## Lancer : Godot_console.exe --headless --path godot res://tests/test_records.tscn

var _ok := 0
var _ko := 0
var _bilans: Array = []


func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	Partie.sauvegarde_auto = false
	Partie.chemin_sauvegarde = _chemin_partie()
	Partie.chemin_records = _chemin()
	Partie.partie_finie.connect(_sur_fin)
	Records.effacer(_chemin())
	_tests_fichier()
	_tests_regles()
	_tests_partie()
	_tests_compatibilite()
	Partie.partie_finie.disconnect(_sur_fin)
	Partie.sauvegarde_auto = false
	Partie.chemin_sauvegarde = Sauvegarde.CHEMIN
	Partie.chemin_records = Records.CHEMIN
	Records.effacer(_chemin())
	Records.effacer(_chemin_b())
	Sauvegarde.effacer(_chemin_partie())
	print("")
	print("=== test_records : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	get_tree().quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _sur_fin(b: Dictionary) -> void:
	_bilans.append(b)


func _pid() -> int:
	return OS.get_process_id()


func _chemin() -> String:
	return "user://test_records_%d_rec.sav" % _pid()


func _chemin_b() -> String:
	return "user://test_records_%d_b_rec.sav" % _pid()


func _chemin_partie() -> String:
	return "user://test_records_%d.sav" % _pid()


## Bilan fabriqué (seuls les champs lus par Records.enregistrer).
func _bilan(titre_id: String, pct: float, possible := true, rang := 2) -> Dictionary:
	var nom := "Titre " + titre_id
	return {"titre": {"id": titre_id, "nom": nom, "pourquoi": "p", "ordre": 1} if titre_id != "" else {}, "ecart_tata_pct": pct, "record_possible": possible,
		"prenom": "Gérard", "nominal": {"vous": 123456.5}, "rue": [{"id": "vous", "rang": rang}, {"id": "livret", "rang": 1}]}


func _texte(chemin: String) -> String:
	return FileAccess.get_file_as_string(chemin)


func _ecrire_brut(chemin: String, t: String) -> void:
	var f := FileAccess.open(chemin, FileAccess.WRITE)
	f.store_string(t)
	f.close()


# ---------------------------------------------------------------------
# Format et tolérance du fichier
# ---------------------------------------------------------------------

func _tests_fichier() -> void:
	var c := _chemin()
	verifier("CA-T7 : fichier absent -> record et collection vides, sans erreur", Records.lire(c) == {"record": {}, "collection": {}})
	var r := Records.enregistrer(_bilan("bon_pere", 8.2), "p1", c, "2026-11-14")
	verifier("Première fin : écrit, nouveau record, nouveau titre, pas de record ancien, pas hors record",
		r["ecrit"] and r["nouveau"] and r["nouveau_titre"] and r["ancien"].is_empty() and not r["hors_record"] and not r["deja_compte"])
	var texte := _texte(c)
	verifier("D7 : fichier texte [meta] version=1, [record], [collection], [parties], dernière ligne « ; fin »",
		texte.begins_with("[meta]") and texte.contains("version=1") and texte.contains("[record]") and texte.contains("[collection]")
		and texte.contains("[parties]") and texte.strip_edges().ends_with("; fin") and Records.VERSION == 1 and Records.CHEMIN == "user://records.sav")
	var l := Records.lire(c)
	var rec: Dictionary = l["record"]
	verifier("lire : record complet (écart, rang, titre, prénom, patrimoine, date réelle AAAA-MM-JJ)",
		is_equal_approx(float(rec["ecart_pct"]), 8.2) and int(rec["rang"]) == 2 and rec["titre_id"] == "bon_pere" and rec["titre_nom"] == "Titre bon_pere"
		and rec["prenom"] == "Gérard" and is_equal_approx(float(rec["patrimoine"]), 123456.5) and rec["date_reelle"] == "2026-11-14", str(rec))
	verifier("lire : collection {titre: {nombre 1, première date}}", l["collection"] == {"bon_pere": {"nombre": 1, "premiere": "2026-11-14"}}, str(l["collection"]))
	verifier("enregistrer renvoie le record et la collection à jour", r["record"] == l["record"] and r["collection"] == l["collection"])
	# Date par défaut : horloge réelle
	var cb := _chemin_b()
	Records.enregistrer(_bilan("fourmi", 1.0), "x", cb)
	var d := str(Records.lire(cb)["record"]["date_reelle"])
	var regex := RegEx.create_from_string("^\\d{4}-\\d{2}-\\d{2}$")
	verifier("Date réelle par défaut au format AAAA-MM-JJ", regex.search(d) != null, d)
	# Fichier tronqué, vide, illisible, autre version : vide, aucune erreur
	var complet := _texte(c)
	var vide_attendu := {"record": {}, "collection": {}}
	_ecrire_brut(cb, complet.substr(0, complet.length() >> 1))
	var tronque := Records.lire(cb) == vide_attendu
	_ecrire_brut(cb, complet.substr(0, complet.find("[collection]") + 8))
	tronque = tronque and Records.lire(cb) == vide_attendu
	_ecrire_brut(cb, "")
	tronque = tronque and Records.lire(cb) == vide_attendu
	verifier("CA-T7 : fichier tronqué (au milieu, au milieu d'une ligne) ou vide -> vide, sans erreur", tronque)
	_ecrire_brut(cb, "n'importe quoi\n\u0001\u0002 [ ] = ;;")
	verifier("CA-T7 : fichier illisible -> vide, sans erreur", Records.lire(cb) == vide_attendu)
	_ecrire_brut(cb, complet.replace("version=1", "version=2"))
	verifier("CA-T7 : autre version -> vide, sans erreur", Records.lire(cb) == vide_attendu)
	var avec_nouveau := Records.enregistrer(_bilan("cigale", 3.0), "y", cb)
	verifier("Après un fichier invalide, un nouvel enregistrement repart de zéro (nouveau record)", avec_nouveau["nouveau"] and avec_nouveau["ancien"].is_empty()
		and Records.lire(cb)["collection"].size() == 1)
	Records.effacer(cb)
	verifier("effacer : fichier et temporaire supprimés", not FileAccess.file_exists(cb) and not FileAccess.file_exists(cb + ".tmp"))


# ---------------------------------------------------------------------
# Règles du record et de la collection
# ---------------------------------------------------------------------

func _tests_regles() -> void:
	var c := _chemin_b()
	Records.effacer(c)
	var r1 := Records.enregistrer(_bilan("bon_pere", 5.0, true, 2), "a", c, "2026-01-01")
	verifier("Record 1 (5 %) : nouveau", r1["nouveau"])
	var r2 := Records.enregistrer(_bilan("fourmi", 2.0), "b", c, "2026-02-02")
	var l2 := Records.lire(c)
	verifier("CA-T7 : écart moins bon -> record inchangé ; la collection compte la partie (2 titres)", not r2["nouveau"] and l2["record"]["titre_id"] == "bon_pere"
		and is_equal_approx(float(l2["record"]["ecart_pct"]), 5.0) and l2["collection"].size() == 2 and r2["nouveau_titre"] and r2["ancien"]["titre_id"] == "bon_pere")
	var r3 := Records.enregistrer(_bilan("cigale", 5.0, true, 1), "c", c, "2026-03-03")
	var l3 := Records.lire(c)
	verifier("CA-T7 : égalité -> l'ancien record reste (titre, date, rang)", not r3["nouveau"] and l3["record"]["titre_id"] == "bon_pere" and l3["record"]["date_reelle"] == "2026-01-01"
		and int(l3["record"]["rang"]) == 2)
	verifier("Égalité à un ulp près (même valeur relue du fichier) : toujours l'ancien", not Records.enregistrer(_bilan("fourmi", 5.0 + 1e-9), "c2", c, "2026-03-04")["nouveau"])
	var r4 := Records.enregistrer(_bilan("marin", 9.5, true, 1), "d", c, "2026-04-04")
	var l4 := Records.lire(c)
	verifier("CA-T7 : meilleur écart -> nouveau record (ancien rendu), titre, rang et date mis à jour", r4["nouveau"] and r4["ancien"]["titre_id"] == "bon_pere" and l4["record"]["titre_id"] == "marin"
		and int(l4["record"]["rang"]) == 1 and l4["record"]["date_reelle"] == "2026-04-04")
	var r5 := Records.enregistrer(_bilan("marin", 50.0, false), "e", c, "2026-05-05")
	var l5 := Records.lire(c)
	verifier("CA-T7 : record_possible faux (retours) -> record inchangé, collection mise à jour (marin 2 fois), hors_record vrai",
		r5["hors_record"] and not r5["nouveau"] and l5["record"]["titre_id"] == "marin" and is_equal_approx(float(l5["record"]["ecart_pct"]), 9.5)
		and int(l5["collection"]["marin"]["nombre"]) == 2 and l5["collection"]["marin"]["premiere"] == "2026-04-04" and not r5["nouveau_titre"])
	var avant := _texte(c)
	var r6 := Records.enregistrer(_bilan("marin", 99.0), "d", c, "2026-06-06")
	verifier("CA-T7 : même id_partie compté deux fois -> deja_compte, aucune écriture (fichier identique)", r6["deja_compte"] and not r6["ecrit"] and _texte(c) == avant)
	var r7 := Records.enregistrer(_bilan("", 99.0), "z", c, "2026-07-07")
	verifier("CA-T7 : sans titre (abandon, faillite) -> rien écrit", not r7["ecrit"] and _texte(c) == avant)
	var absent := _chemin()
	Records.effacer(absent)
	Records.enregistrer(_bilan("", 1.0), "z", absent)
	verifier("CA-T7 : sans titre et sans fichier -> aucun fichier créé", not FileAccess.file_exists(absent))
	var r8 := Records.enregistrer(_bilan("apprenti", 1.0), "", c, "2026-08-08")
	verifier("id_partie vide : compté (pas d'identifiant à mémoriser)", r8["ecrit"] and not r8["deja_compte"])
	Records.effacer(c)
	for i in 205:
		Records.enregistrer(_bilan("apprenti", 0.0), "id%d" % i, c, "2026-09-09")
	var d := Records._charger(c)
	verifier("[parties] : les 200 derniers identifiants seulement (205 parties jouées)", (d["ids"] as Array).size() == 200 and d["ids"][0] == "id5" and d["ids"][199] == "id204"
		and int(d["collection"]["apprenti"]["nombre"]) == 205)
	Records.effacer(c)


# ---------------------------------------------------------------------
# Écriture à la fin d'une partie (Partie, D8)
# ---------------------------------------------------------------------

func _config(g: int) -> Dictionary:
	var cfg := Donnees.config_demo(g)
	cfg["cartes"] = true
	cfg["projets"] = true
	cfg["rue"] = true
	return cfg


## Joue la partie de Partie.etat jusqu'à sa fin selon le profil (par Partie.avancer_un_mois : signaux et fin comprises).
func _jouer_jusqu_au_bout(profil: Dictionary) -> void:
	var garde := 0
	while Partie.etat.fin == "" and garde < 400:
		garde += 1
		StrategieTest.jouer_mois_profil(Partie.etat, profil)
		Partie.avancer_un_mois()


func _partie(g: int, titre: String, retours := 0) -> Dictionary:
	_bilans.clear()
	Partie.nouvelle_partie(_config(g))
	Partie.etat.retours = retours
	_jouer_jusqu_au_bout(StrategieTest.PROFILS_TITRES[titre])
	return _bilans[_bilans.size() - 1] if not _bilans.is_empty() else {}


func _tests_partie() -> void:
	var c := _chemin()
	Records.effacer(c)
	# sauvegarde_auto faux : rien n'est écrit
	Partie.sauvegarde_auto = false
	var b0 := _partie(3, "bon_pere")
	verifier("CA-T7 : sauvegarde_auto faux -> aucune écriture, bilan[\"record\"] = {ecrit false, hors_record false, nouveau false}",
		not FileAccess.file_exists(c) and not b0.is_empty() and b0["record"]["ecrit"] == false and b0["record"]["hors_record"] == false and b0["record"]["nouveau"] == false
		and b0["record"]["nouveau_titre"] == false and str(b0["titre"]["id"]) == "bon_pere")
	# Vraie partie du joueur
	Partie.sauvegarde_auto = true
	var b1 := _partie(3, "bon_pere")
	var rec1: Dictionary = Records.lire(c)["record"]
	verifier("Fin d'une vraie partie : records.sav écrit, bilan[\"record\"] = résultat d'enregistrer (nouveau record, nouveau titre)",
		FileAccess.file_exists(c) and b1["record"]["ecrit"] and b1["record"]["nouveau"] and b1["record"]["nouveau_titre"] and rec1["titre_id"] == "bon_pere"
		and is_equal_approx(float(rec1["ecart_pct"]), snappedf(float(b1["ecart_tata_pct"]), 0.0001)) and int(rec1["rang"]) == int(Quartier.rang_de(b1["rue"])),
		"écart %.2f %%, rang %d" % [float(rec1["ecart_pct"]), int(rec1["rang"])])
	verifier("bilan : titre, écart en %, prénom, humeur, projets, retours, record_possible, phrase de l'inflation",
		b1["titre"]["id"] == "bon_pere" and b1["prenom"] != "" and b1["humeur_fin"] in [0, 1, 2] and b1["humeur_phrase"] != "" and b1["projets"]["total"] == 2
		and b1["projets"]["realises"] == 2 and b1["retours"] == 0 and b1["record_possible"] == true and str(b1["objectif"]["phrase"]) != ""
		and is_equal_approx(float(b1["ecart_tata_pct"]), 100.0 * Titres.ecart_tata(Partie.etat)))
	var avant := _texte(c)
	Partie._emettre_fin()
	var b1bis: Dictionary = _bilans[_bilans.size() - 1]
	verifier("CA-T7 : partie_finie émis une seconde fois pour la même partie -> deja_compte, fichier inchangé", b1bis["record"]["deja_compte"] and not b1bis["record"]["ecrit"] and _texte(c) == avant)
	# retours > 0 : hors record, la collection avance quand même
	var b2 := _partie(1, "golden_boy", 1)
	var l2 := Records.lire(c)
	verifier("CA-T7 : partie avec retour en arrière (retours = 1) : record inchangé (même avec un meilleur écart), collection mise à jour, hors_record vrai",
		b2["record_possible"] == false and b2["record"]["hors_record"] and not b2["record"]["nouveau"] and l2["record"]["titre_id"] == "bon_pere"
		and float(b2["ecart_tata_pct"]) > float(l2["record"]["ecart_pct"]) and l2["collection"].has("golden_boy"), "écart de la partie %.1f %% contre record %.1f %%" % [float(b2["ecart_tata_pct"]), float(l2["record"]["ecart_pct"])])
	var b3 := _partie(1, "golden_boy")
	var l3 := Records.lire(c)
	verifier("Même graine sans retour : nouveau record (golden_boy), nombre 2 dans la collection, plus « nouveau titre »",
		b3["record"]["nouveau"] and not b3["record"]["nouveau_titre"] and l3["record"]["titre_id"] == "golden_boy" and int(l3["collection"]["golden_boy"]["nombre"]) == 2
		and b3["record"]["ancien"]["titre_id"] == "bon_pere")
	var b4 := _partie(2, "apprenti")
	verifier("Partie moins bonne : record inchangé, titre ajouté à la collection (3 titres)",
		not b4["record"]["nouveau"] and b4["record"]["nouveau_titre"] and Records.lire(c)["record"]["titre_id"] == "golden_boy" and Records.lire(c)["collection"].size() == 3)
	# Abandon et faillite : ni titre, ni record, ni collection
	avant = _texte(c)
	_bilans.clear()
	Partie.nouvelle_partie(_config(5))
	Partie.abandonner()
	var ba: Dictionary = _bilans[_bilans.size() - 1]
	verifier("CA-T7 : abandon -> aucun titre, aucune écriture, record_possible faux", ba["titre"].is_empty() and not ba["record"]["ecrit"] and not ba["record_possible"] and _texte(c) == avant)
	_bilans.clear()
	Partie.nouvelle_partie(_config(5))
	Partie.etat.fin = "faillite"
	Partie._emettre_fin()
	var bf: Dictionary = _bilans[_bilans.size() - 1]
	verifier("CA-T7 : faillite -> aucun titre, aucune écriture", bf["titre"].is_empty() and not bf["record"]["ecrit"] and not bf["record_possible"] and _texte(c) == avant)
	# Identifiant de partie
	_bilans.clear()
	Partie.nouvelle_partie(_config(7))
	var id1 := Partie.id_partie
	Partie.nouvelle_partie(_config(7))
	var id2 := Partie.id_partie
	verifier("Partie.id_partie créé à chaque nouvelle partie (graine + date-heure réelle), distinct d'une partie à l'autre", id1 != "" and id2 != "" and id1 != id2 and id1.begins_with("7-"), id1)
	Partie.sauvegarde_auto = false
	Sauvegarde.effacer(_chemin_partie())


# ---------------------------------------------------------------------
# CA-T8 : sauvegardes d'avant le lot, repères de non-régression
# ---------------------------------------------------------------------

## Reprise d'une sauvegarde fabriquée (champs retirés) puis partie jusqu'à la fin.
func _reprise(g: int, retire: Array) -> Dictionary:
	var e := EtatPartie.new()
	e.demarrer(_config(g))
	var profil: Dictionary = StrategieTest.PROFILS_TITRES["apprenti"]
	var garde := 0
	while e.fin == "" and e.ab_courant() < Dates.lire("1986-06") and garde < 100:
		garde += 1
		StrategieTest.jouer_mois_profil(e, profil)
		e.avancer()
	var dd := e.vers_dict()
	for k: String in retire:
		dd.erase(k)
	_bilans.clear()
	var ok := Partie.reprendre({"etat": dd, "partie": {}})
	if not ok:
		return {}
	_jouer_jusqu_au_bout(profil)
	return {"id": Partie.id_partie, "retours": Partie.etat.retours, "bilan": _bilans[_bilans.size() - 1] if not _bilans.is_empty() else {},
		"fin": Partie.etat.fin}


func _tests_compatibilite() -> void:
	Partie.sauvegarde_auto = false
	var r05 := _reprise(4, ["retours", "stats_titre"])
	verifier("CA-T8 : sauvegarde de la base 0.5 (sans retours ni stats_titre) : reprise, partie jusqu'à la fin, retours = 0, id_partie créé, titre non vide",
		not r05.is_empty() and r05["fin"] == "fin" and r05["retours"] == 0 and r05["id"] != "" and not r05["bilan"]["titre"].is_empty() and r05["bilan"]["record_possible"],
		str(r05.get("bilan", {}).get("titre", {}).get("id", "?")))
	var r04 := _reprise(4, ["retours", "stats_titre", "foyer", "projets", "jeanmi", "quartier", "instantane_k"])
	verifier("CA-T8 : sauvegarde de main 0.4 (sans cartes, projets, rue, titres) : reprise, fin, retours = 0, id_partie créé, titre non vide, instantane_krach() vide",
		not r04.is_empty() and r04["fin"] == "fin" and r04["retours"] == 0 and r04["id"] != "" and not r04["bilan"]["titre"].is_empty() and Partie.etat.instantane_krach().is_empty()
		and r04["bilan"]["projets"]["total"] == 0, str(r04.get("bilan", {}).get("titre", {}).get("id", "?")))
	# Reprise d'une sauvegarde avec id_partie : conservé
	var e := EtatPartie.new()
	e.demarrer(_config(4))
	Partie.reprendre({"etat": e.vers_dict(), "partie": {"id_partie": "4-fixe"}})
	var conserve := Partie.id_partie == "4-fixe"
	Partie.sauvegarde_auto = true
	Partie.sauvegarder()
	var relu := Sauvegarde.lire(_chemin_partie())
	Partie.sauvegarde_auto = false
	verifier("Reprise : un id_partie existant est conservé ; il est sauvegardé avec les réglages de la partie (pas dans l'état du jeu)",
		conserve and str(relu.get("partie", {}).get("id_partie", "")) == "4-fixe" and not (relu["etat"]["config"] as Dictionary).has("id_partie"))
	# Référence de test_logique : l'instantané pris rue éteinte ne change rien à la partie (même fin qu'avec la rue allumée, hors rue)
	var a := EtatPartie.new()
	var ca := _config(6)
	ca["rue"] = false
	a.demarrer(ca)
	StrategieTest.jouer_partie_profil(a, StrategieTest.PROFILS_TITRES["apprenti"])
	var b := EtatPartie.new()
	var cb := _config(6)
	cb["rue"] = true
	b.demarrer(cb)
	StrategieTest.jouer_partie_profil(b, StrategieTest.PROFILS_TITRES["apprenti"])
	verifier("Rue éteinte ou allumée : même patrimoine du joueur et des témoins, même titre (l'instantané n'a aucun effet de jeu)",
		a.patrimoine(a.joueur) == b.patrimoine(b.joueur) and a.patrimoine(a.temoins["livret"]) == b.patrimoine(b.temoins["livret"])
		and Titres.calculer(a)["id"] == Titres.calculer(b)["id"] and a.instantane_krach().is_empty() and not b.instantane_krach().is_empty())
