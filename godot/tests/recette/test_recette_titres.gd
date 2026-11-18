extends Node
## Recette du lot 07-L (testeur) : record face a Tata Livret recalcule independamment, ecriture unique, fichier
## corrompu, 9 titres par leur strategie, vente apres le krach, textes, reprise d'une sauvegarde 0.5.1 du joueur.
## Tout est ecrit dans user://recette_titres_<pid>_* (jamais records.sav ni partie_en_cours.sav).
## Variable d'environnement TESTEUR_SAV_JOUEUR : chemin d'une COPIE de partie_en_cours.sav (0.5.1), facultatif.

var ok := 0
var ko := 0
var rec := "user://recette_titres_%d_records.sav" % OS.get_process_id()
var sav := "user://recette_titres_%d_partie.sav" % OS.get_process_id()
var dossier := ProjectSettings.globalize_path("user://")

const P := StrategieTest.PROFILS_TITRES


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		ok += 1
		print("OK  ", nom)
	else:
		ko += 1
		print("KO  ", nom, "  [", detail, "]")


func _config(g: int) -> Dictionary:
	var c := Donnees.config_demo(g)
	c["cartes"] = true
	c["projets"] = true
	c["rue"] = true
	return c


func _ready() -> void:
	var vrai_rec := FileAccess.file_exists("user://records.sav")
	var vrai_sav_avant := FileAccess.get_sha256("user://partie_en_cours.sav") if FileAccess.file_exists("user://partie_en_cours.sav") else ""
	Partie.sauvegarde_auto = true
	Partie.chemin_records = rec
	Partie.chemin_sauvegarde = sav
	Records.effacer(rec)
	_record()
	_corrompu()
	_titres()
	_vente_krach()
	_textes()
	_reprise_joueur()
	Partie.sauvegarde_auto = false
	verifier("records.sav du joueur : meme etat avant / apres (existe=%s)" % vrai_rec, FileAccess.file_exists("user://records.sav") == vrai_rec)
	var vrai_sav_apres := FileAccess.get_sha256("user://partie_en_cours.sav") if FileAccess.file_exists("user://partie_en_cours.sav") else ""
	verifier("partie_en_cours.sav du joueur inchangee", vrai_sav_avant == vrai_sav_apres)
	Records.effacer(rec)
	Sauvegarde.effacer(sav)
	print("=== recette titres : %d OK, %d KO ===" % [ok, ko])
	get_tree().quit(1 if ko > 0 else 0)


## Joue une partie complete par Partie (emission reelle de partie_finie) ; renvoie le bilan emis.
func _partie(g: int, profil: Dictionary, avant_fin := Callable()) -> Dictionary:
	var recu := {"n": 0, "b": {}}
	var f := func(b: Dictionary) -> void:
		recu["n"] += 1
		recu["b"] = b
	Partie.partie_finie.connect(f)
	Partie.nouvelle_partie(_config(g))
	var garde := 0
	while Partie.etat.fin == "" and garde < 400:
		garde += 1
		StrategieTest.jouer_mois_profil(Partie.etat, profil)
		if avant_fin.is_valid():
			avant_fin.call()
		Partie.avancer_un_mois()
	Partie.partie_finie.disconnect(f)
	recu["b"]["_n_emissions"] = recu["n"]
	return recu["b"]


func _ecart_independant(e: EtatPartie, b: Dictionary) -> float:
	var vous := e.patrimoine(e.joueur)
	var tata := e.patrimoine(e.temoins["livret"])
	var pct := 100.0 * (vous / tata - 1.0)
	return pct


func _record() -> void:
	# Trois parties : P1 bon_pere g3, P2 cigale g1, P3 apprenti g2 ; puis rejeu de P1 (egalite)
	var suite := [["bon_pere", 3], ["cigale", 1], ["apprenti", 2], ["bon_pere", 3]]
	var meilleur := -1e9
	var meilleur_titre := ""
	var ecarts: Array = []
	var date_record := ""
	for i in suite.size():
		var id: String = suite[i][0]
		var b := _partie(int(suite[i][1]), P[id])
		var e := Partie.etat
		var pct := _ecart_independant(e, b)
		ecarts.append(pct)
		var r := Records.lire(rec)
		var ancien_meilleur := meilleur
		var strictement := snappedf(pct, 0.0001) > meilleur
		if strictement:
			meilleur = snappedf(pct, 0.0001)
			meilleur_titre = str(b["titre"]["id"])
		print("RECORD partie %d (%s g%d) ecart_independant=%.4f %% bilan=%.4f %% record_fichier=%s" % [i + 1, id, suite[i][1], pct, float(b["ecart_tata_pct"]),
			str(r["record"].get("ecart_pct", "aucun"))])
		verifier("RECORD %d : ecart du bilan == recalcul independant (patrimoine / Tata - 1)" % (i + 1), absf(pct - float(b["ecart_tata_pct"])) < 0.0001, "%f vs %f" % [pct, b["ecart_tata_pct"]])
		verifier("RECORD %d : fin emise une seule fois" % (i + 1), int(b["_n_emissions"]) == 1)
		verifier("RECORD %d : record fichier = meilleur ecart des parties jouees (%.4f)" % [i + 1, meilleur], absf(float(r["record"].get("ecart_pct", -1e9)) - meilleur) < 0.0002)
		verifier("RECORD %d : titre du record = titre de la partie du meilleur ecart" % (i + 1), str(r["record"].get("titre_id", "")) == meilleur_titre)
		if i == 1:
			date_record = str(r["record"].get("date_reelle", ""))
		if i == 3:
			verifier("RECORD 4 : egalite exacte avec le record -> pas de nouveau record (bilan.record.nouveau faux)", absf(pct - ecarts[0]) < 1e-9 and not bool(b["record"]["nouveau"]),
				"%f vs %f nouveau=%s" % [pct, ecarts[0], b["record"]["nouveau"]])
		if i == 2:
			verifier("RECORD 3 : partie moins bonne -> record inchange, nouveau faux", ancien_meilleur >= snappedf(pct, 0.0001) and not bool(b["record"]["nouveau"]))
	var coll: Dictionary = Records.lire(rec)["collection"]
	verifier("COLLECTION : bon_pere obtenu 2 fois, cigale 1, apprenti 1 (une ecriture par partie)", int(coll.get("bon_pere", {}).get("nombre", 0)) == 2
		and int(coll.get("cigale", {}).get("nombre", 0)) == 1 and int(coll.get("apprenti", {}).get("nombre", 0)) == 1, str(coll))
	# Egalite via l'API avec une date differente : l'ancien record garde sa date
	var d0 := Records.lire(rec)["record"] as Dictionary
	var fake := {"titre": {"id": "apprenti", "nom": "x"}, "record_possible": true, "ecart_tata_pct": float(d0["ecart_pct"]), "prenom": "Z", "nominal": {"vous": 1.0}, "rue": []}
	var r2 := Records.enregistrer(fake, "id-egalite", rec, "2001-01-01")
	verifier("EGALITE (API) : ancien record conserve (date et prenom inchanges)", not bool(r2["nouveau"]) and str(Records.lire(rec)["record"]["date_reelle"]) == str(d0["date_reelle"])
		and str(Records.lire(rec)["record"]["prenom"]) == str(d0["prenom"]))
	fake["ecart_tata_pct"] = float(d0["ecart_pct"]) + 0.01
	var r3 := Records.enregistrer(fake, "id-mieux", rec, "2002-02-02")
	verifier("MEILLEUR de 0,01 point -> nouveau record", bool(r3["nouveau"]) and str(Records.lire(rec)["record"]["date_reelle"]) == "2002-02-02")
	# Double fin (meme id_partie)
	var avant := FileAccess.get_sha256(rec)
	var b_dbl := Bilan.calculer(Partie.etat)
	b_dbl["record"] = {}
	var coll_avant := (Records.lire(rec)["collection"] as Dictionary).duplicate(true)
	Partie._emettre_fin()
	Partie._emettre_fin()
	verifier("DOUBLE partie_finie (meme id_partie) : fichier identique, une seule ecriture", FileAccess.get_sha256(rec) == avant and Records.lire(rec)["collection"] == coll_avant)
	var rr := Records.enregistrer(Bilan.calculer(Partie.etat), Partie.id_partie, rec)
	verifier("DOUBLE : Records.enregistrer -> deja_compte", bool(rr["deja_compte"]) and not bool(rr["ecrit"]))
	# Abandon : aucune ecriture
	Records.effacer(rec)
	Partie.nouvelle_partie(_config(5))
	for k in 12:
		StrategieTest.jouer_mois_profil(Partie.etat, P["apprenti"])
		Partie.avancer_un_mois()
	Partie.abandonner()
	verifier("ABANDON : aucune ecriture de records.sav", not FileAccess.file_exists(rec))
	# sauvegarde_auto faux
	Partie.sauvegarde_auto = false
	var bf := _partie(3, P["bon_pere"])
	verifier("sauvegarde_auto faux : fin jouee, aucune ecriture", not FileAccess.file_exists(rec) and not bool(bf["record"]["ecrit"]) and bf["titre"]["id"] == "bon_pere")
	Partie.sauvegarde_auto = true
	# Retours = 1 force, puis rechargement : hors record, collection avancee
	Records.effacer(rec)
	Partie.nouvelle_partie(_config(3))
	var garde := 0
	var recharge := false
	while Partie.etat.fin == "" and garde < 400:
		garde += 1
		StrategieTest.jouer_mois_profil(Partie.etat, P["bon_pere"])
		if Partie.etat.m >= Partie.etat.m_depart + 20 and not recharge:
			Partie.etat.retours = 1
			var idavant := Partie.id_partie
			Partie.sauvegarder()
			var d := Sauvegarde.lire(sav)
			var okr := Partie.reprendre(d)
			recharge = true
			verifier("RETOURS : reprise ok, id_partie conserve, retours = 1 relu", okr and Partie.id_partie == idavant and Partie.etat.retours == 1, "%s / %s" % [idavant, Partie.id_partie])
		Partie.avancer_un_mois()
	var bh := Bilan.calculer(Partie.etat)
	var rl := Records.lire(rec)
	verifier("RETOURS=1 apres rechargement : record_possible faux, aucun record, collection mise a jour",
		not bool(bh["record_possible"]) and rl["record"].is_empty() and not (rl["collection"] as Dictionary).is_empty() and FileAccess.file_exists(rec), str(rl))
	Records.effacer(rec)


func _ecrire_texte(chemin: String, t: String) -> void:
	var f := FileAccess.open(chemin, FileAccess.WRITE)
	f.store_string(t)
	f.close()


func _corrompu() -> void:
	Records.effacer(rec)
	var bon := {"titre": {"id": "apprenti", "nom": "A"}, "record_possible": true, "ecart_tata_pct": 3.5, "prenom": "G", "nominal": {"vous": 100.0}, "rue": []}
	Records.enregistrer(bon, "a", rec, "2020-01-01")
	var txt := FileAccess.get_file_as_string(rec)
	var cas := {"absent": null, "tronque": txt.substr(0, txt.length() / 2), "sans_fin": txt.replace("; fin", ""), "vide": "", "binaire": "\u0001\u0002\u0003zz{{{", "autre_version": txt.replace("version=1", "version=7"),
		"record_incomplet": "[meta]\nversion=1\n[record]\necart_pct=2.0\n; fin\n"}
	if OS.get_environment("TESTEUR_ANALYSEUR") != "":   # imprime 2 lignes ERROR du moteur (anomalie A1) : hors suite par defaut
		cas["section_cassee"] = "[meta]\nversion=1\n[record\nbidule=\n; fin\n"
	for nom: String in cas:
		Records.effacer(rec)
		if cas[nom] != null:
			_ecrire_texte(rec, str(cas[nom]))
		var r := Records.lire(rec)
		verifier("CORROMPU %s : lire = vide sans erreur" % nom, (r["record"] as Dictionary).is_empty() and (r["collection"] as Dictionary).is_empty(), str(r))
		var w := Records.enregistrer(bon, "b", rec, "2020-01-02")
		verifier("CORROMPU %s : on peut ensuite ecrire un nouveau record" % nom, bool(w["ecrit"]) and bool(w["nouveau"]))
	Records.effacer(rec)


func _titres() -> void:
	var ids := ["bon_pere", "golden_boy", "escargots", "fourmi", "cigale", "marin", "neveu_matelas", "ecureuil", "apprenti"]
	var graines := {"bon_pere": 3, "golden_boy": 1, "escargots": 1, "fourmi": 1, "cigale": 1, "marin": 1, "neveu_matelas": 1, "ecureuil": 1, "apprenti": 2}
	Partie.sauvegarde_auto = false
	for id: String in ids:
		var b := _partie(int(graines[id]), P[id])
		var e := Partie.etat
		var g := Titres.grandeurs(e)
		var nb_vente_auto := float(e.stats_titre.get("ventes_krach", 0.0))
		print("TITRE %s strategie=%s graine=%d -> %s ecart=%.2f %% projets=%d/%d epargne=%d depense=%d humeur=%d part_krach=%.2f vendu=%s ventes_krach=%.0f" % [id, id, graines[id],
			b["titre"]["id"], b["ecart_tata_pct"], b["projets"]["realises"], b["projets"]["total"], g["nb_epargne"], g["nb_depense"], g["humeur_fin"], g["part_risquee_krach"], g["a_vendu_krach"], nb_vente_auto])
		verifier("TITRE %s atteint par sa strategie" % id, str(b["titre"]["id"]) == id and e.fin == "fin")
		# Conditions verifiees sur l'etat reel
		var cond := false
		match id:
			"bon_pere": cond = g["ecart_tata"] > 0.075 and g["projets_realises"] == 2 and g["humeur_fin"] != 2 and nb_vente_auto == 0.0
			"golden_boy": cond = g["part_risquee_krach"] >= 0.30 and g["a_vendu_krach"]
			"escargots": cond = g["escargots"] and g["ecart_tata"] < 0.0
			"fourmi": cond = g["nb_epargne"] >= 5 and g["nb_epargne"] - g["nb_depense"] >= 3 and (g["humeur_fin"] == 2 or g["abandon_evitable"])
			"cigale": cond = g["nb_depense"] >= 5 and g["nb_depense"] - g["nb_epargne"] >= 3 and g["humeur_fin"] == 0
			"marin": cond = g["part_risquee_krach"] >= 0.30 and not g["a_vendu_krach"] and g["ecart_tata"] > 0.0
			"neveu_matelas": cond = g["cc_moyen"] >= 0.30
			"ecureuil": cond = true
			"apprenti": cond = true
		verifier("TITRE %s : conditions de docs/28 verifiees sur les grandeurs reelles" % id, cond, str(g))
	# Ordre 7 / 8 : compte courant seul -> neveu, pas ecureuil
	var gg := {"ecart_tata": 0.0, "projets_realises": 0, "humeur_fin": 1, "abandon_evitable": false, "part_risquee_krach": 0.0, "a_vendu_krach": false, "escargots": false,
		"nb_epargne": 0, "nb_depense": 0, "produits_detenus": [], "cc_moyen": 0.9}
	verifier("ORDRE 7 avant 8 : compte courant seul (aucun produit, cc 90 %) -> neveu_matelas", Titres.evaluer(gg)["id"] == "neveu_matelas")
	gg["cc_moyen"] = 0.29
	verifier("cc_moyen 0,29 aucun produit -> ecureuil (derniere condition avant defaut)", Titres.evaluer(gg)["id"] == "ecureuil")
	gg["ecart_tata"] = 0.075
	gg["projets_realises"] = 2
	verifier("bon_pere : ecart 0,075 pile = non (seuil du lot 08b)", Titres.evaluer(gg)["id"] != "bon_pere")
	gg["ecart_tata"] = 0.0751
	verifier("bon_pere : ecart 0,0751 + 2 projets + humeur != 2 = oui", Titres.evaluer(gg)["id"] == "bon_pere")
	gg["humeur_fin"] = 2
	verifier("bon_pere : humeur 2 (fachee) = non", Titres.evaluer(gg)["id"] != "bon_pere")
	var f := {"ecart_tata": -0.1, "projets_realises": 0, "humeur_fin": 2, "abandon_evitable": false, "part_risquee_krach": 0.0, "a_vendu_krach": false, "escargots": false,
		"nb_epargne": 5, "nb_depense": 2, "produits_detenus": ["livret", "sicav"], "cc_moyen": 0.1}
	verifier("fourmi : epargne 5, ecart 3, humeur 2 = oui", Titres.evaluer(f)["id"] == "fourmi")
	f["nb_depense"] = 3
	verifier("fourmi : epargne 5, ecart 2 = non", Titres.evaluer(f)["id"] != "fourmi")
	f["nb_depense"] = 1
	f["nb_epargne"] = 4
	verifier("fourmi : epargne 4 (ecart 3) = non", Titres.evaluer(f)["id"] != "fourmi")
	f["nb_epargne"] = 5
	f["humeur_fin"] = 1
	verifier("fourmi : humeur neutre et pas d'abandon evitable = non", Titres.evaluer(f)["id"] != "fourmi")
	f["abandon_evitable"] = true
	verifier("fourmi : abandon evitable suffit", Titres.evaluer(f)["id"] == "fourmi")
	var c := {"ecart_tata": -0.1, "projets_realises": 0, "humeur_fin": 0, "abandon_evitable": false, "part_risquee_krach": 0.0, "a_vendu_krach": false, "escargots": false,
		"nb_epargne": 1, "nb_depense": 5, "produits_detenus": ["livret", "sicav"], "cc_moyen": 0.1}
	verifier("cigale : depense 5, ecart 4, humeur 0 (contente) = oui", Titres.evaluer(c)["id"] == "cigale")
	c["humeur_fin"] = 2
	verifier("cigale : humeur 2 (fachee) = non", Titres.evaluer(c)["id"] != "cigale")


func _vente_krach() -> void:
	# Marin g1 jusqu'a 12/1987 puis vente par ordre de x % de chaque ligne risquee
	var res := {}
	for taux in [1.0, 0.3]:
		var e := EtatPartie.new()
		e.demarrer(_config(1))
		var garde := 0
		while e.fin == "" and e.ab_courant() < Dates.lire("1987-12") and garde < 400:
			garde += 1
			StrategieTest.jouer_mois_profil(e, P["marin"])
			e.avancer()
		StrategieTest.jouer_mois_profil(e, P["marin"])
		var vendu := 0.0
		var ids: Array = e.joueur.lignes.keys()
		for id in ids:
			var t := str(e.produit(str(id)).get("type", ""))
			if t == "action" or t == "sicav":
				var d := e.vendre(e.joueur, str(id), 0.0, true) if taux >= 1.0 else e.vendre(e.joueur, str(id), taux * e.joueur.qte(str(id)) * e.cours(str(id)), false)
				vendu += float(d.get("brut", 0.0))
		var base := Krach.base(e.instantane_k)
		print("VENTE_KRACH date=%s taux=%.1f vendu=%.0f base_krach=%.0f ratio=%.2f stats=%.0f a_vendu=%s" % [Dates.texte(e.ab_courant()), taux, vendu, base, vendu / maxf(base, 1.0), float(e.stats_titre["ventes_krach"]), Titres.a_vendu_krach(e)])
		if taux >= 1.0:
			verifier("VENTE apres le krach (12/1987, 100 % des lignes risquees, > 50 %) -> a_vendu_krach vrai", Titres.a_vendu_krach(e) and base > 0.0, str(base))
			res["tout"] = Titres.a_vendu_krach(e)
		else:
			verifier("VENTE 30 % (< 50 %) -> a_vendu_krach faux", not Titres.a_vendu_krach(e) and base > 0.0, str(base))


func _mots(t: String) -> int:
	var n := 0
	for m in t.split(" ", false):
		for ch in m:
			if ch.to_upper() != ch.to_lower() or (ch >= "0" and ch <= "9"):
				n += 1
				break
	return n


func _textes() -> void:
	var d := Titres.donnees()
	var interdits := ["achetez", "vendez", "c'est le moment", "auriez dû", "auriez du", "il faut ", "tu ", "ton ", "ta ", "tes ", "étoile", "cousin indice", "renforcez"]
	var tout_ok := true
	var mots_ok := true
	var vous := 0
	var chiffre_nom := false
	for t: Dictionary in d["titres"]:
		var txt := (str(t["nom"]) + " " + str(t["pourquoi"])).to_lower()
		for w in interdits:
			if (" " + txt + " ").contains(" " + w) and w != "ton ":
				tout_ok = false
				print("  mot interdit ", w, " dans ", t["id"])
		var nm := _mots(str(t["pourquoi"]))
		print("MOTS ", t["id"], " alnum=", nm, " brut=", str(t["pourquoi"]).split(" ", false).size())
		if nm > 15:
			mots_ok = false
		for ch in str(t["nom"]):
			if ch >= "0" and ch <= "9":
				chiffre_nom = true
		if str(t["pourquoi"]).to_lower().contains("vous") or str(t["pourquoi"]).to_lower().contains("votre"):
			vous += 1
	verifier("TEXTES : aucun mot interdit, pas de tutoiement ni etoile", tout_ok)
	verifier("TEXTES : pourquoi <= 15 mots (comptage alphanumerique)", mots_ok)
	verifier("TEXTES : noms sans chiffre", not chiffre_nom)
	var ph: Dictionary = d["objectif"]
	for k in ph:
		var s := str(ph[k]).to_lower()
		verifier("TEXTES objectif %s : pas d'etoile, vouvoiement" % k, not s.contains("étoile") and s.contains("votre"))
	print("TEXTES : %d titres sur 9 parlent a la 2e personne (vous/votre)" % vous)
	for k in ["gerant", "gérant"]:
		pass


func _reprise_joueur() -> void:
	var chemin := OS.get_environment("TESTEUR_SAV_JOUEUR")
	if chemin == "" or not FileAccess.file_exists(chemin):
		print("(pas de sauvegarde joueur copiee : etape sautee)")
		return
	var d := Sauvegarde.lire(chemin)
	verifier("REPRISE 0.5.1 : sauvegarde du joueur lisible", not d.is_empty())
	if d.is_empty():
		return
	print("REPRISE : partie du joueur reprise en ", d["resume"]["date"], " id_partie dans le fichier = '", d["partie"].get("id_partie", ""), "'")
	verifier("REPRISE : id_partie absent du fichier 0.5.1", str(d["partie"].get("id_partie", "")) == "")
	Records.effacer(rec)
	Partie.sauvegarde_auto = true
	var recu := {"b": {}, "n": 0}
	var f := func(b: Dictionary) -> void:
		recu["b"] = b
		recu["n"] += 1
	Partie.partie_finie.connect(f)
	var okr := Partie.reprendre(d)
	verifier("REPRISE : Partie.reprendre ok, id_partie cree, retours 0", okr and Partie.id_partie != "" and Partie.etat.retours == 0, Partie.id_partie)
	var d2 := Sauvegarde.lire(sav)
	verifier("REPRISE : id_partie sauvegarde dans le fichier de reprise", str(d2.get("partie", {}).get("id_partie", "")) == Partie.id_partie)
	var garde := 0
	while Partie.etat.fin == "" and garde < 400:
		garde += 1
		StrategieTest.jouer_mois(Partie.etat, true)
		Partie.avancer_un_mois()
	Partie.partie_finie.disconnect(f)
	var b: Dictionary = recu["b"]
	print("REPRISE : fin ", Partie.etat.fin, " titre=", b.get("titre", {}).get("id", "?"), " ecart=", b.get("ecart_tata_pct", 0.0), " record=", b.get("record", {}))
	verifier("REPRISE : partie menee a la fin, titre non vide, fin emise 1 fois, record ecrit", Partie.etat.fin == "fin" and not (b["titre"] as Dictionary).is_empty() and int(recu["n"]) == 1
		and bool(b["record"]["ecrit"]) and bool(b["record_possible"]))
	Records.effacer(rec)

