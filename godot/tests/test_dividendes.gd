extends SceneTree
## Tests des dividendes des actions (lot 03, partie 03-L : D1 à D5, CA-L2, CA-L4, CA-L5, CA-L6).
## Logique pure : aucun nœud. Lancer : Godot_console.exe --headless --path godot --script res://tests/test_dividendes.gd
## Fichiers : user://test_dividendes_<pid>.sav seulement (effacé à la fin) ; jamais partie_en_cours.sav.
## Imprime la mesure D5 (« DIVIDENDES aller_retour … ») et la référence de partie complète (« DIVIDENDES integrale … »).

const F := 6.55957
const TITRES := ["elf", "loreal", "peugeot", "saintgobain"]

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_regle()
	_tests_cas_particuliers()
	_tests_notifications()
	_tests_une_notification()
	_tests_releve()
	_tests_fiche()
	_tests_sauvegarde()
	_mesure_aller_retour()
	_reference_integrale()
	Sauvegarde.effacer(_chemin())
	print("")
	print("=== test_dividendes : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _chemin() -> String:
	return "user://test_dividendes_%d.sav" % OS.get_process_id()


# ---------------------------------------------------------------------
# Outils
# ---------------------------------------------------------------------

## Partie de la démo (graine 7), joueur passif (aucune action) jusqu'au mois d ; la modale du mois est résolue.
func _partie(d: String, g := 7) -> EtatPartie:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(g))
	StrategieTest.aller_a(e, Dates.lire(d), false)
	while not e.modale.is_empty():
		e.resolution_auto()
	return e


## Copie indépendante d'une partie (même chemin que la sauvegarde, sans fichier).
func _copie(e: EtatPartie) -> EtatPartie:
	return EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(e.vers_dict())))


## Passe un mois (modales résolues par le joueur passif). Renvoie le résultat d'avancer().
func _mois(e: EtatPartie) -> Dictionary:
	while not e.modale.is_empty():
		e.resolution_auto()
	return e.avancer()


## Achète pour environ montant_F francs de chacun des titres (argent ajouté au compte avant).
func _acheter(e: EtatPartie, ids: Array, montant_F: float) -> void:
	e.joueur.cc += Produits.f(montant_F * ids.size() + 1000.0)
	for id in ids:
		if not e.acheter(e.joueur, id, Produits.f(montant_F))["ok"]:
			push_error("Achat impossible : %s" % id)


## Produit dans les données brutes (periode_p1.json), sans passer par le moteur.
func _donnee(id: String) -> Dictionary:
	for p: Dictionary in Donnees.periode("P1")["produits"]:
		if p["id"] == id:
			return p
	return {}


## Net attendu recalculé depuis les données : qte × cours du mois × (rendement de marché + écart) × (1 − impôt).
func _net_attendu(e: EtatPartie, id: String) -> float:
	var a := e.ab_courant()
	var p := _donnee(id)
	var annee := Dates.annee(a)
	if (p.get("divNul", []) as Array).has(float(annee)):
		return 0.0
	var rdt := float(Donnees.series()["annuel"][str(annee)][1])
	var taux := maxf(0.0, rdt + float(p.get("ecartDiv", 0.0))) / 100.0
	var impot := float(Donnees.regle_datee(Donnees.regles()["impots"], a)["cto"]) / 100.0
	return e.joueur.qte(id) * e.cours(id) * taux * (1.0 - impot)


func _lignes_div(r: Dictionary) -> Array:
	return (r["flux"]["lignes"] as Array).filter(func(l: Dictionary) -> bool: return l["genre"] == "dividende")


func _notifs(r: Dictionary, type: String) -> Array:
	return (r["notifs"] as Array).filter(func(n: Dictionary) -> bool: return n.get("type", "") == type)


# ---------------------------------------------------------------------
# CA-L2 : la règle (D1, D2, D3)
# ---------------------------------------------------------------------

func _tests_regle() -> void:
	var a := _partie("1987-04")
	_acheter(a, TITRES, 5000.0)
	a.acheter(a.joueur, "sicav", Produits.f(5000.0))
	var b := _copie(a)
	b.joueur.lignes = {}   # même partie, sans aucune ligne : aucun dividende
	var cc0 := a.joueur.cc
	var impots0 := a.joueur.impots
	var stats_impots0 := float(a.stats["impots"])
	var ombre0 := a.joueur.ombre_realise
	var r := _mois(a)
	_mois(b)
	verifier("Mai 1987 atteint pour les deux parties", Dates.texte(a.ab_courant()) == "mai 1987" and b.m == a.m)
	var lignes := _lignes_div(r)
	var ok_net := true
	var detail := ""
	var total := 0.0
	var brut_total := 0.0
	for id in TITRES:
		var att := _net_attendu(a, id)
		var vu := 0.0
		for l: Dictionary in lignes:
			if l["id"] == id:
				vu = float(l["montant"])
		total += att
		brut_total += att / 0.84
		detail += "%s %.2f F (attendu %.2f F) ; " % [id, vu * F, att * F]
		if att <= 0.0 or absf(vu - att) * F > 0.01:
			ok_net = false
	verifier("CA-L2 : Elf, L'Oréal, Peugeot, Saint-Gobain en mai 1987 : net = valeur de la ligne × (rendement 1987 + écart) × 0,84, au centime près (recalculé depuis les données)",
		ok_net and lignes.size() == 4, detail)
	verifier("CA-L2 : SICAV : aucun versement de plus (pas de ligne « dividende » pour elle)",
		lignes.filter(func(l: Dictionary) -> bool: return l["id"] == "sicav").is_empty())
	verifier("CA-L2 : compte courant crédité du net (écart avec la même partie sans actions = total net)",
		absf((a.joueur.cc - b.joueur.cc) - total) * F < 0.01, "%.2f F crédités, %.2f F attendus" % [(a.joueur.cc - b.joueur.cc) * F, total * F])
	verifier("CA-L2 : impôt de 16 % ajouté aux impôts du portefeuille et aux statistiques",
		absf((a.joueur.impots - impots0) - brut_total * 0.16) * F < 0.01 and absf((float(a.stats["impots"]) - stats_impots0) - brut_total * 0.16) * F < 0.01,
		"%.2f F" % ((a.joueur.impots - impots0) * F))
	# D3 : le jumeau sans frais reçoit le dividende de ses parts « sans frais » (qte_ombre > qte : courtage payé)
	var att_ombre := 0.0
	for id in TITRES:
		var l: Dictionary = a.joueur.lignes[id]
		att_ombre += (float(l["qte_ombre"]) - float(l["qte"])) * a.cours(id) * a.taux_dividende(id, 1987) / 100.0 * 0.84
	verifier("D3 : jumeau sans frais : l'écart de dividendes (parts « sans frais » − parts réelles) va au manque à gagner",
		att_ombre > 0.0 and absf((a.joueur.ombre_realise - ombre0) - att_ombre) * F < 0.001, "%.4f F" % (att_ombre * F))
	verifier("CA-L4 : dividendes_recus(\"elf\") = cumul net ; dividendes_recus() = total",
		absf(a.dividendes_recus("elf") - _net_attendu(a, "elf")) * F < 0.01 and absf(a.dividendes_recus() - total) * F < 0.01 and a.dividendes_recus("livret") == 0.0)
	var mois_elf := int(_donnee("elf").get("moisDiv", Donnees.regles()["dividendes"]["mois"]))
	verifier("CA-L4 : mois_dividende(\"elf\") = moisDiv d'Elf dans les données (mai par défaut) ; 0 pour le Livret A et la SICAV",
		a.mois_dividende("elf") == mois_elf and mois_elf == 5 and a.mois_dividende("livret") == 0 and a.mois_dividende("sicav") == 0)
	# Aucun versement un autre mois : de juin 1987 à la fin, seulement en mai 1988
	var mois_vus := []
	while a.fin == "":
		var rr := _mois(a)
		if not _lignes_div(rr).is_empty() or not _notifs(rr, "dividende").is_empty():
			mois_vus.append(Dates.texte_court(a.ab_courant()))
	verifier("CA-L2 : aucun versement un autre mois (de juin 1987 à la fin : mai 1988 seulement)", mois_vus == ["mai 1988"], str(mois_vus))


# ---------------------------------------------------------------------
# CA-L2 : vendu en avril, divNul, moisDiv (fabriqués), plancher
# ---------------------------------------------------------------------

func _tests_cas_particuliers() -> void:
	# Titre acheté en mars et vendu en avril : rien en mai
	var e := _partie("1987-03")
	_acheter(e, ["elf"], 5000.0)
	_mois(e)
	e.vendre(e.joueur, "elf", 0.0, true)
	var r := _mois(e)
	verifier("CA-L2 : titre vendu en avril : rien en mai (ni ligne ni notification)",
		Dates.mois(e.ab_courant()) == 5 and _lignes_div(r).is_empty() and _notifs(r, "dividende").is_empty() and e.dividendes_recus() == 0.0)
	# Titre acheté en mai : rien ce mois-là (détenu au début du mois seulement, docs/20 B3), versé l'année suivante
	var e2 := _partie("1987-05")
	_acheter(e2, ["elf"], 5000.0)
	StrategieTest.aller_a(e2, Dates.lire("1988-04"), false)
	verifier("docs/20 : action achetée au mois de détachement : rien avant le mois de détachement suivant", e2.dividendes_recus() == 0.0)
	var r2 := _mois(e2)
	verifier("docs/20 : … puis versement en mai 1988", _lignes_div(r2).size() == 1 and e2.dividendes_recus("elf") > 0.0)
	# divNul fabriqué : Elf ne verse rien en 1987, L'Oréal verse : une seule notification (03-R, D1) qui nomme Elf
	var info: Dictionary = e.mk.infos["elf"]
	var e3 := _partie("1987-04")
	_acheter(e3, ["elf", "loreal"], 5000.0)
	info["divNul"] = [1987.0]
	var r3 := _mois(e3)
	info.erase("divNul")
	var div3 := _notifs(r3, "dividende")
	verifier("CA-L2 : année listée dans divNul (fabriquée pour Elf en 1987) : 0 pour Elf, L'Oréal verse quand même",
		_lignes_div(r3).size() == 1 and _lignes_div(r3)[0]["id"] == "loreal" and e3.dividendes_recus("elf") == 0.0)
	verifier("divNul + un titre versant (03-R, D1) : pas de notification « dividende_nul » à part ; la notification du dividende nomme Elf (nuls)",
		_notifs(r3, "dividende_nul").is_empty() and div3.size() == 1 and div3[0]["nuls"] == [{"id": "elf", "nom": "Elf"}]
		and str(div3[0]["texte"]).ends_with(" Elf : rien cette année."), str(div3[0]["texte"]) if div3.size() == 1 else "")
	verifier("Peugeot dans les données : divNul = [1984, 1985, 1986] (docs/20 B2), taux_dividende nul ces années-là, 3,6 % en 1987",
		e3.taux_dividende("peugeot", 1985) == 0.0 and e3.taux_dividende("peugeot", 1986) == 0.0 and is_equal_approx(e3.taux_dividende("peugeot", 1987), 3.6)
		and is_equal_approx(e3.taux_dividende("elf", 1987), 5.1) and is_equal_approx(e3.taux_dividende("loreal", 1987), 2.1))
	# moisDiv fabriqué : L'Oréal en septembre
	var e4 := _partie("1987-04")
	_acheter(e4, ["loreal"], 5000.0)
	var info_l: Dictionary = e4.mk.infos["loreal"]
	info_l["moisDiv"] = 9.0
	var mois_vus := []
	for i in 7:
		var rr := _mois(e4)
		if not _lignes_div(rr).is_empty():
			mois_vus.append(Dates.texte_court(e4.ab_courant()))
	var md := e4.mois_dividende("loreal")
	info_l.erase("moisDiv")
	verifier("CA-L2 : moisDiv surchargé (fabriqué : L'Oréal en septembre) : versement en septembre 1987 seulement", mois_vus == ["sept. 1987"] and md == 9, str(mois_vus))
	# Plancher à 0 : un écart très négatif ne donne jamais un dividende négatif
	var ecart0 := float(info_l["ecartDiv"])
	info_l["ecartDiv"] = -10.0
	var t := e4.taux_dividende("loreal", 1987)
	info_l["ecartDiv"] = ecart0
	verifier("Plancher : rendement + écart < 0 → taux 0 (jamais de dividende négatif)", t == 0.0)


# ---------------------------------------------------------------------
# CA-L4 : ce que voit le joueur (D4)
# ---------------------------------------------------------------------

func _tests_notifications() -> void:
	var a := _partie("1987-04")
	_acheter(a, TITRES, 5000.0)
	var b := _copie(a)
	b.joueur.lignes = {}
	var r := _mois(a)
	_mois(b)
	var n := _notifs(r, "dividende")
	var nd: Dictionary = n[0] if n.size() == 1 else {}
	var net := a.dividendes_recus()
	verifier("CA-L4 : une seule notification « dividende » le mois du versement, banque, gain, montant = net total, brut, impôt, 4 lignes",
		n.size() == 1 and nd["source"] == "banque" and nd["cls"] == "gain" and absf(float(nd["montant"]) - net) < 1e-9
		and absf(float(nd["brut"]) - float(nd["impot"]) - net) < 1e-9 and (nd["lignes"] as Array).size() == 4 and nd.has("titre") and nd.has("texte"))
	verifier("CA-L4 : sans pause : aucune modale ouverte par elle, mêmes interruptions qu'une partie sans actions",
		a.modale.is_empty() == b.modale.is_empty() and int(a.banque["interruptions"]) == int(b.banque["interruptions"]) and not nd.get("persistant", false))
	verifier("CA-L4 : la 1re de la partie : premier = true, texte qui explique le dividende, détail « … et 2 autres », taux de 16 %",
		nd.get("premier", false) and str(nd["texte"]).begins_with("Un dividende, c'est") and str(nd["texte"]).contains(" et 2 autres)")
		and str(nd["texte"]).contains("16" + Format.ESPACE + "%"), str(nd.get("texte", "")))
	StrategieTest.aller_a(a, Dates.lire("1988-04"), false)
	var r2 := _mois(a)
	var n2 := _notifs(r2, "dividende")
	verifier("CA-L4 : la suivante (mai 1988) : premier = false, « Dividendes de mai : … »",
		n2.size() == 1 and not n2[0]["premier"] and str(n2[0]["texte"]).begins_with("Dividendes de mai : "), str(n2[0]["texte"]) if n2.size() == 1 else "")
	# Détail à 1 et 2 titres ; total écrit = somme des montants écrits (D6)
	var c := _partie("1987-04")
	_acheter(c, ["elf", "loreal"], 5000.0)
	var n3: Dictionary = _notifs(_mois(c), "dividende")[0]
	var l3: Array = n3["lignes"]
	var somme := 0.0
	for l: Dictionary in l3:
		somme += roundf(float(l["net"]) * F)
	verifier("D4 : deux titres nommés « Elf … F et L'Oréal … F », total écrit = somme des montants écrits",
		str(n3["texte"]).contains("Elf ") and str(n3["texte"]).contains(" et L'Oréal ") and str(n3["texte"]).contains(Format.nombre(somme) + Format.ESPACE + "F"), str(n3["texte"]))
	# Textes : ≤ 60 mots, sans flèche, espaces insécables
	var msg: Dictionary = Banquier.donnees()["messages"]
	var ok_txt := true
	var det := ""
	for k in ["dividendes_titre", "dividendes_premier", "dividendes", "dividendes_nul", "releve_dividendes", "releve_avoir_fiscal"]:
		var tx := str(msg[k])
		var mots := Banquier.nb_mots(tx)
		det += "%s %d ; " % [k, mots]
		if mots > 60 or tx.contains("→") or tx.contains(" %") or tx.contains(" F "):
			ok_txt = false
	for tx in [str(nd.get("texte", "")), str(n2[0]["texte"]) if n2.size() == 1 else ""]:
		if Banquier.nb_mots(tx) > 60 or tx.contains("→") or tx.contains(" %") or RegEx.create_from_string("[0-9] F\\b").search(tx) != null:
			ok_txt = false
	verifier("CA-L4 : textes des dividendes ≤ 60 mots, aucun « → », espaces insécables de Format avant % et F", ok_txt, det)
	verifier("Historique : la notification est rangée (source banque, type dividende, montant)",
		a.historique.any(func(h: Dictionary) -> bool: return h["type"] == "dividende" and h["source"] == "banque" and h["a_montant"]))


# ---------------------------------------------------------------------
# 03-R, CA-R2 : une seule notification de dividende par mois (D1)
# ---------------------------------------------------------------------

func _notifs_div(r: Dictionary) -> Array:
	return (r["notifs"] as Array).filter(func(n: Dictionary) -> bool: return n.get("type", "") in ["dividende", "dividende_nul"])


func _tests_une_notification() -> void:
	# (a) Elf et Peugeot détenues en avril 1986 : Peugeot est en divNul en 1986
	var a := _partie("1986-04")
	_acheter(a, ["elf", "peugeot"], 5000.0)
	var ra := _mois(a)
	var na := _notifs_div(ra)
	var ta := str(na[0]["texte"]) if na.size() == 1 else ""
	print("    CA-R2 (a) mai 1986, Elf + Peugeot : « %s » (%d mots)" % [ta, Banquier.nb_mots(ta)])
	verifier("CA-R2 (a) : Elf et Peugeot en mai 1986 : une seule notification, « dividende », premier, explication et « Peugeot : rien cette année », nuls = [Peugeot]",
		na.size() == 1 and na[0]["type"] == "dividende" and na[0]["premier"] and ta.contains("Un dividende, c'est") and ta.contains("Peugeot : rien cette année")
		and na[0]["nuls"] == [{"id": "peugeot", "nom": "Peugeot"}] and Banquier.nb_mots(ta) <= 60, ta)
	var entrees := a.historique.filter(func(h: Dictionary) -> bool: return int(h["m"]) == a.m and h["source"] == "banque" and str(h["type"]) in ["dividende", "dividende_nul"])
	verifier("CA-R2 (d) : une seule entrée d'historique (banque) pour les dividendes de mai 1986", entrees.size() == 1)
	# (b) Peugeot seule : une seule notification « dividende_nul »
	var b := _partie("1986-04")
	_acheter(b, ["peugeot"], 5000.0)
	var nb := _notifs_div(_mois(b))
	var tb := str(nb[0]["texte"]) if nb.size() == 1 else ""
	print("    CA-R2 (b) mai 1986, Peugeot seule : « %s » (%d mots)" % [tb, Banquier.nb_mots(tb)])
	verifier("CA-R2 (b) : Peugeot seule en mai 1986 : une seule notification, « dividende_nul »",
		nb.size() == 1 and nb[0]["type"] == "dividende_nul" and nb[0]["id"] == "peugeot" and tb.begins_with("Peugeot ") and Banquier.nb_mots(tb) <= 60, tb)
	# (c) Elf seule : nuls vide, pas de « rien cette année »
	var c := _partie("1986-04")
	_acheter(c, ["elf"], 5000.0)
	var nc := _notifs_div(_mois(c))
	var tc := str(nc[0]["texte"]) if nc.size() == 1 else ""
	print("    CA-R2 (c) mai 1986, Elf seule : « %s » (%d mots)" % [tc, Banquier.nb_mots(tc)])
	verifier("CA-R2 (c) : Elf seule : une notification, nuls == [], texte sans « rien cette année »",
		nc.size() == 1 and nc[0]["type"] == "dividende" and nc[0]["nuls"] == [] and not tc.contains("rien cette année") and Banquier.nb_mots(tc) <= 60, tc)
	# Pire cas fabriqué : 3 titres versants + 1 nul, texte « premier » (L'Oréal en divNul en 1987)
	var p := _partie("1987-04")
	_acheter(p, TITRES, 5000.0)
	var info: Dictionary = p.mk.infos["loreal"]
	info["divNul"] = [1987.0]
	var np := _notifs_div(_mois(p))
	info.erase("divNul")
	var tp := str(np[0]["texte"]) if np.size() == 1 else ""
	print("    CA-R2 pire cas (3 versants + 1 nul, premier) : « %s » (%d mots)" % [tp, Banquier.nb_mots(tp)])
	verifier("CA-R2 : pire cas fabriqué (3 titres versants + 1 nul, 1re notification) : une notification, ≤ 60 mots",
		np.size() == 1 and np[0]["premier"] and (np[0]["lignes"] as Array).size() == 3 and tp.contains("L'Oréal : rien cette année") and Banquier.nb_mots(tp) <= 60, "%d mots" % Banquier.nb_mots(tp))


# ---------------------------------------------------------------------
# CA-L4 : relevé de décembre
# ---------------------------------------------------------------------

func _releve(r: Dictionary) -> Dictionary:
	var n := _notifs(r, "releve")
	return n[0] if n.size() == 1 else {}


func _tests_releve() -> void:
	var a := _partie("1987-04")
	_acheter(a, ["elf", "saintgobain"], 5000.0)
	var nets := 0.0
	var rel := {}
	while a.fin == "" and rel.is_empty():
		var r := _mois(a)
		for n: Dictionary in _notifs(r, "dividende"):
			nets += float(n["montant"])
		rel = _releve(r)
	# Joueur passif sans Livret A avec des actions : 0 intérêt, des dividendes (cas 2 de 03-R, D2)
	var phrase := "Pas d'intérêts cette année, mais "
	verifier("CA-L4 : relevé de décembre 1987 : n[\"dividendes\"] = somme des nets de l'année, phrase présente, avec l'avoir fiscal (1re année)",
		absf(float(rel.get("dividendes", -1.0)) - nets) < 1e-9 and nets > 0.0 and str(rel["texte"]).begins_with(phrase + Format.entier(nets, a.ab_courant()) + " de dividendes")
		and str(rel["texte"]).contains("avoir fiscal") and rel["cls"] == "gain", str(rel.get("texte", "")))
	var rel2 := {}
	while a.fin == "" and rel2.is_empty():
		rel2 = _releve(_mois(a))
	if rel2.is_empty():
		rel2 = {"texte": "", "dividendes": -1.0}
	verifier("Relevé de décembre 1988 : phrase des dividendes, sans répéter l'avoir fiscal",
		float(rel2["dividendes"]) > 0.0 and str(rel2["texte"]).begins_with(phrase) and not str(rel2["texte"]).contains("avoir fiscal"), str(rel2["texte"]))
	# Une année sans dividende : joueur passif, décembre 1987
	var p := _partie("1987-11")
	var rel3 := {}
	while p.fin == "" and rel3.is_empty():
		rel3 = _releve(_mois(p))
	verifier("CA-L4 : relevé d'une année sans dividende : n[\"dividendes\"] = 0, phrase absente",
		float(rel3.get("dividendes", -1.0)) == 0.0 and not str(rel3["texte"]).contains("dividendes"))
	_tests_releve_4_cas()


## 03-R, CA-R3 : relevé fabriqué dans les 4 cas (intérêts 0 / > 0, dividendes 0 / > 0), décembre 1987.
func _tests_releve_4_cas() -> void:
	var base := _partie("1987-12")
	var msg: Dictionary = Banquier.donnees()["messages"]
	var a := base.ab_courant()
	var i_eur := Produits.f(1234.4)
	var d_eur := Produits.f(345.6)
	var vals_i := {"interets": Format.entier(i_eur, a)}
	var vals_d := {"dividendes": Format.entier(d_eur, a)}
	var avoir := Format.gabarit(str(msg["releve_avoir_fiscal"]), {"taux": "16"})
	var cas := [[0.0, 0.0], [0.0, d_eur], [i_eur, 0.0], [i_eur, d_eur]]
	var attendus := [str(msg["releve_sans_interets"]),
		Format.gabarit(str(msg["releve_dividendes_sans_interets"]), vals_d) + avoir,
		Format.gabarit(str(msg["releve_interets"]), vals_i),
		Format.gabarit(str(msg["releve_interets"]), vals_i) + Format.gabarit(str(msg["releve_dividendes"]), vals_d) + avoir]
	var ok := true
	var ok_champs := true
	var detail := ""
	for k in 4:
		var e := _copie(base)
		e.banque["interets_annee"] = cas[k][0]
		e.banque["dividendes_annee"] = cas[k][1]
		var n := Banquier.releve(e)
		var t := str(n["texte"])
		print("    CA-R3 cas %d : « %s »" % [k + 1, t])
		if not t.begins_with(attendus[k]) or (k == 1 and (t.contains("Aucun intérêt") or t.contains("Vos actions vous ont versé"))):
			ok = false
			detail += "cas %d : %s ; " % [k + 1, t]
		if float(n["dividendes"]) != cas[k][1] or float(n["interets"]) != cas[k][0] or n["cls"] != ("neutre" if k == 0 else "gain"):
			ok_champs = false
	verifier("CA-R3 : relevé en 4 cas : (1) nouveau texte sans intérêt ni dividende ; (2) une seule phrase « Pas d'intérêts cette année, mais … » + avoir fiscal, jamais « Aucun intérêt » ni la phrase des dividendes en plus ; (3) et (4) inchangés",
		ok, detail)
	verifier("CA-R3 : champs dividendes, interets et cls du relevé inchangés dans les 4 cas", ok_champs)
	verifier("CA-R3 : textes du relevé ≤ 60 mots une fois assemblés (cas 4, le plus long)", Banquier.nb_mots(attendus[3]) <= 60, "%d mots" % Banquier.nb_mots(attendus[3]))


# ---------------------------------------------------------------------
# 03-R, CA-R4 : phrase de la fiche d'une action (D4)
# ---------------------------------------------------------------------

func _tests_fiche() -> void:
	var regle := "Dividende : versé en mai, si l'entreprise en distribue cette année-là."
	var e := _partie("1986-04")
	_acheter(e, ["elf", "peugeot"], 5000.0)
	var avant := Banquier.texte_fiche_dividende(e, "elf")
	_mois(e)
	var apres := Banquier.texte_fiche_dividende(e, "elf")
	var peugeot := Banquier.texte_fiche_dividende(e, "peugeot")
	print("    CA-R4 fiche Elf avant : « %s » ; après mai 1986 : « %s » ; Peugeot 1986 : « %s »" % [avant, apres, peugeot])
	verifier("CA-R4 : fiche d'Elf avant tout versement et de Peugeot en 1986 (année sans dividende) : « %s »" % regle, avant == regle and peugeot == regle)
	verifier("CA-R4 : fiche d'Elf après versement : « Dividendes reçus : » + Format.entier(dividendes_recus)",
		apres == "Dividendes reçus : " + Format.entier(e.dividendes_recus("elf"), e.ab_courant()) and e.dividendes_recus("elf") > 0.0, apres)
	var vides := true
	for id in ["livret", "sicav", "pel", "emprunt", "av", "cc"]:
		if Banquier.texte_fiche_dividende(e, id) != "":
			vides = false
	verifier("CA-R4 : texte vide pour le Livret A, la SICAV, le PEL, l'emprunt d'État, l'assurance-vie", vides)
	var msg: Dictionary = Banquier.donnees()["messages"]
	var ok_mots := true
	for k: String in msg:
		if k.begins_with("fiche_") or k.begins_with("dividendes"):
			var t := str(msg[k]).to_lower()
			for mot in ["chaque année", "régulier", "toujours"]:
				if t.contains(mot):
					ok_mots = false
	verifier("CA-R4 : aucune clé fiche_* ni dividendes* ne contient « chaque année », « régulier » ou « toujours » (docs/22 §1)", ok_mots)


# ---------------------------------------------------------------------
# CA-L5 : sauvegarde
# ---------------------------------------------------------------------

func _tests_sauvegarde() -> void:
	var a := _partie("1987-04")
	_acheter(a, TITRES, 5000.0)
	Sauvegarde.ecrire(a, {}, _chemin())
	var b := Sauvegarde.charger(Sauvegarde.lire(_chemin()))
	var ra := _mois(a)
	var rb := _mois(b)
	verifier("CA-L5 : sauvegarde en avril, reprise : versement de mai identique (compte, cumul, notification)",
		b != null and a.joueur.cc == b.joueur.cc and a.dividendes_recus() == b.dividendes_recus() and a.dividendes_recus() > 0.0
		and var_to_str(_notifs(ra, "dividende")) == var_to_str(_notifs(rb, "dividende")))
	# Sauvegarde de la 0.4 : sans les nouveaux champs (retirés), après un premier dividende
	var d := a.vers_dict()
	d["stats"].erase("dividendes")
	d["stats"].erase("dividende_vu")
	d["banque"].erase("dividendes_annee")
	d["banque"].erase("avoir_fiscal_vu")
	var c := EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(d)))
	var ok_defauts: bool = c != null and (c.stats["dividendes"] as Dictionary).is_empty() and c.stats["dividende_vu"] == false \
		and float(c.banque["dividendes_annee"]) == 0.0 and c.banque["avoir_fiscal_vu"] == false
	var notifs_fin := []
	while c != null and c.fin == "":
		notifs_fin.append_array(_notifs(_mois(c), "dividende"))
	verifier("CA-L5 : sauvegarde sans les nouveaux champs : rechargée avec les défauts, va jusqu'à la fin, dividendes versés ensuite",
		ok_defauts and c.fin == "fin" and notifs_fin.size() == 1 and c.dividendes_recus() > 0.0)
	Sauvegarde.effacer(_chemin())


# ---------------------------------------------------------------------
# CA-L6 : mesures (D5, référence intégrale)
# ---------------------------------------------------------------------

## D5 : achat d'Elf en avril 1987 (10 000 F), revente en juin 1987 : gain net, frais et impôt compris.
func _mesure_aller_retour() -> void:
	var a := _partie("1987-04")
	a.joueur.cc += Produits.f(11000.0)
	var b := _copie(a)
	var d := a.acheter(a.joueur, "elf", Produits.f(10000.0))
	_mois(a)
	_mois(b)
	var div := a.dividendes_recus("elf")
	_mois(a)
	_mois(b)
	var v := a.vendre(a.joueur, "elf", 0.0, true)
	var gain := a.joueur.cc - b.joueur.cc
	print("DIVIDENDES aller_retour elf 1987-04 1987-06 gain_net=%s F (dividende net %s F, achat %s F, revente nette %s F, cours %s → %s F)" % [
		Format.nombre(gain * F, 2), Format.nombre(div * F, 2), Format.nombre(float(d["total"]) * F, 2), Format.nombre(float(v["recu"]) * F, 2),
		Format.nombre(float(d["prix"]) * F, 2), Format.nombre(float(v["prix"]) * F, 2)])
	verifier("D5 : mesure de l'aller-retour Elf avril → juin 1987 imprimée (dividende touché, revente faite)", div > 0.0 and v["ok"] and Dates.texte(a.ab_courant()) == "juin 1987")


## L6 : partie complète de référence, StrategieTest (graine des tests de test_demo : 7), joueur actif et passif.
func _reference_integrale() -> void:
	for actif in [true, false]:
		var e := EtatPartie.new()
		e.demarrer(Donnees.config_demo(7))
		StrategieTest.aller_a(e, Dates.lire("1989-01"), actif)
		var a := e.ab_courant()
		var par_titre := {}
		for id in (e.stats["dividendes"] as Dictionary):
			par_titre[id] = Format.nombre(e.dividendes_recus(id) * F, 2)
		print("DIVIDENDES integrale graine=7 joueur=%s fin=%s patrimoine=%s F frais=%s F interruptions=%d dividendes_nets=%s F %s" % [
			"actif" if actif else "passif", e.fin, Format.nombre(e.patrimoine(e.joueur) * F, 2), Format.nombre(e.frais_payes() * F, 2),
			int(e.banque.get("interruptions", 0)), Format.nombre(e.dividendes_recus() * F, 2), str(par_titre)])
		verifier("L6 : partie complète %s jusqu'à la fin%s" % ["active" if actif else "passive", ", avec des dividendes" if actif else ", sans action ni dividende"],
			e.fin == "fin" and Dates.texte(a) == "décembre 1988" and ((e.dividendes_recus() > 0.0) == actif))
