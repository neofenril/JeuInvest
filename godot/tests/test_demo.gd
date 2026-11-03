extends SceneTree
## Tests headless de la démo V2 (12, 13, 11) : progression du banquier, cadence, produits (PEL, emprunt
## d'État, assurance-vie), frais, héritage, naissance scriptée, sauvegarde et rechargement.
## Lancer : Godot_console.exe --headless --path godot --script res://tests/test_demo.gd

const F := 6.55957

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_depart()
	_tests_progression()
	_tests_textes()
	_tests_pel_emprunt()
	_tests_assurance_vie()
	_tests_frais()
	_tests_heritage()
	_tests_naissance_scriptee()
	_tests_cadence()
	_tests_sauvegarde()
	_tests_historique()
	_tests_taux_pel()
	_tests_versements()
	_tests_repetitions()
	_tests_strategie()
	_effacer_fichiers_user()
	print("")
	print("=== %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


## Fichier de test dans user:// (dossier commun au jeu du joueur, à l'éditeur et à tous les worktrees) :
## nom unique par processus, effacé en fin de test. Jamais partie_en_cours.sav.
func fichier_user(nom: String) -> String:
	return "user://%s_%d.sav" % [nom, OS.get_process_id()]


func _effacer_fichiers_user() -> void:
	for nom in ["test_sauvegarde", "test_historique"]:
		Sauvegarde.effacer(fichier_user(nom))


func proche(a: float, b: float, tol := 1e-6) -> bool:
	return absf(a - b) <= tol * maxf(1.0, absf(b))


func fr(x: float) -> float:
	return x / F


func mt(e: EtatPartie, x: float) -> String:
	return Format.montant(x, e.ab_courant())


## Joueur passif : « pas maintenant » à chaque présentation, choix par défaut ailleurs.
func passif(e: EtatPartie, c: Dictionary) -> void:
	e.resolution_auto()


## Joueur actif : ouvre chaque produit présenté et y place une partie de son argent.
func actif(e: EtatPartie, c: Dictionary) -> void:
	if c["kind"] != "banquier" or c.get("heritage", false):
		e.resolution_auto()
		return
	var r := e.resoudre_modale("ouvrir")
	var p: String = r.get("ouvrir", "")
	match p:
		"livret":
			e.deposer_livret(e.joueur, e.joueur.cc * 0.8)
		"pel":
			e.ouvrir_pel(fr(2000.0), fr(500.0))
		"emprunt":
			e.acheter_emprunt(minf(fr(10000.0), e.joueur.cc * 0.8))
		"av":
			e.verser_av(minf(fr(10000.0), e.joueur.cc * 0.8))
		"sicav":
			e.acheter(e.joueur, "sicav", minf(fr(5000.0), e.joueur.cc * 0.8))
		"elf":
			e.acheter(e.joueur, "elf", minf(fr(3000.0), e.joueur.cc * 0.8))
		"saintgobain":
			e.acheter(e.joueur, "saintgobain", fr(3100.0))


## Chaque mois du joueur actif : il range l'excédent du compte sur le Livret A.
func actif_mois(e: EtatPartie) -> void:
	var garde := e.salaire_base
	if e.joueur.cc > garde and Banquier.presente(e, "livret"):
		e.deposer_livret(e.joueur, minf(e.joueur.cc - garde, e.place_livret(e.joueur)))


## Joue la démo jusqu'au bout. Renvoie { etat, modales: [{m, kind, id}], notifs, achetable_avant }.
func jouer(graine: int, sur_modale: Callable, chaque_mois := Callable(), arret := -1) -> Dictionary:
	var e := EtatPartie.new()
	var res := e.demarrer(Donnees.config_demo(graine))
	return continuer(e, res, sur_modale, chaque_mois, arret)


func continuer(e: EtatPartie, res: Dictionary, sur_modale: Callable, chaque_mois := Callable(), arret := -1) -> Dictionary:
	var modales := []
	var notifs: Array = res.get("notifs", []).duplicate()
	var achetable_avant := false
	var garde := 0
	while e.fin == "" and garde < 200:
		if arret >= 0 and e.m >= arret:
			break
		for pid in e.produits_achetables():
			if not Banquier.presente(e, pid):
				achetable_avant = true
		if not e.modale.is_empty():
			var c := e.contenu_modale()
			modales.append({"m": e.m, "kind": c["kind"], "id": str(c.get("id", c.get("effet", c.get("picto", "")))), "c": c})
			sur_modale.call(e, c)
		if chaque_mois.is_valid():
			chaque_mois.call(e)
		res = e.avancer()
		notifs.append_array(res["notifs"])
		garde += 1
	return {"etat": e, "modales": modales, "notifs": notifs, "achetable_avant": achetable_avant}


func mois_de(d: String, e: EtatPartie) -> int:
	return Dates.lire(d) - e.mk.ab_debut - e.m_depart


# ---------------------------------------------------------------------

func _tests_depart() -> void:
	var e := EtatPartie.new()
	var res := e.demarrer(Donnees.config_demo())
	verifier("Départ : janvier 1984, Gérard technicien, 26 ans", e.ab_courant() == Dates.ab(1984, 1) and e.prenom() == "Gérard" and int(e.sal["profils"]["technicien"]["age"]) + 6 == 26)
	var s84 := e.salaire_base * F
	verifier("Salaire de Gérard en janv. 1984 : entre jeune salarié et cadre, ≈ 6 800 F", s84 > 6500.0 and s84 < 7100.0, "%.0f F" % s84)
	verifier("Compte courant de départ ≈ 1,5 mois de salaire, aucun livret", proche(e.joueur.cc * F, 11000.0 + e.epargne_du_mois() * F, 1e-6) and e.joueur.livret == 0.0, "%.0f F" % (e.joueur.cc * F))
	var silhouettes := 0
	for pid in Banquier.ordre_carnet():
		if Banquier.etat_carte(e, pid) == "silhouette":
			silhouettes += 1
	verifier("Au départ : 9 cartes en silhouette, rien d'achetable, présentation du Livret A au 1er mois (R5, R7)",
		silhouettes == 9 and e.produits_achetables().is_empty() and res["modale"].get("kind", "") == "banquier" and res["modale"].get("id", "") == "D01")
	e.resoudre_modale("plus_tard")
	verifier("Après la présentation (même refusée) : seul le Livret A est achetable, carte « nouveau », 8 silhouettes",
		e.produits_achetables() == ["livret"] and Banquier.etat_carte(e, "livret") == "nouveau" and Banquier.nb_decouverts(e) == 1)
	var pas_de_pea := true
	for pid in Banquier.ordre_carnet():
		if pid.contains("pea"):
			pas_de_pea = false
	verifier("Aucun produit postérieur à la date jouée dans le carnet (pas de PEA)", pas_de_pea and Banquier.ordre_carnet().size() == 9)


func _tests_progression() -> void:
	var p := jouer(7, passif)
	var e: EtatPartie = p["etat"]
	var dates := {}
	for md in p["modales"]:
		if md["kind"] == "banquier":
			dates[md["id"]] = int(md["m"]) - e.m_depart
	var ordre := []
	for md in p["modales"]:
		if md["kind"] == "banquier":
			ordre.append(md["id"])
	print("    Joueur passif : ", ordre, " aux mois ", dates)
	verifier("Partie complète de 60 mois sans erreur (joueur passif)", e.fin == "fin" and e.ab_courant() == Dates.ab(1988, 12))
	verifier("Ordre d'introduction : Livret A, PEL, emprunt d'État, assurance-vie, SICAV, actions, Saint-Gobain, héritage",
		ordre == ["D01", "D02", "D03", "D04", "D05", "D06", "D07", "D08"], str(ordre))
	var mn := mois_de("1985-04", e)
	verifier("Dates limites tenues : PEL ≤ juillet 1984, emprunt ≤ févr. 1985, SICAV ≤ févr. 1986, actions ≤ août 1986",
		dates.get("D02", 99) <= 6 and dates.get("D03", 99) <= 13 and dates.get("D05", 99) <= 25 and dates.get("D06", 99) <= 31)
	verifier("Assurance-vie présentée dans les 3 mois qui suivent la naissance (R6)", dates.get("D04", 0) > mn and dates.get("D04", 99) <= mn + 3, "naissance %d, D04 %d" % [mn, dates.get("D04", -1)])
	verifier("Saint-Gobain : appel en novembre 1986 (date historique)", dates.get("D07", 0) == mois_de("1986-11", e))
	verifier("Les 6 familles vues avant le krach d'octobre 1987", dates.get("D06", 99) < mois_de("1987-10", e) and dates.get("D05", 99) < mois_de("1987-10", e))
	verifier("Aucun produit achetable avant sa présentation (R2)", not p["achetable_avant"])
	# Joueur actif : présentations plus tôt (R4)
	var a := jouer(7, actif, actif_mois)
	var ea: EtatPartie = a["etat"]
	var dates_a := {}
	var ordre_a := []
	for md in a["modales"]:
		if md["kind"] == "banquier":
			dates_a[md["id"]] = int(md["m"]) - ea.m_depart
			ordre_a.append(md["id"])
	print("    Joueur actif : ", ordre_a, " aux mois ", dates_a)
	verifier("Partie complète de 60 mois sans erreur (joueur actif, tous les produits ouverts)", ea.fin == "fin" and not ea.joueur.pel.is_empty() and not ea.joueur.av.is_empty() and not ea.joueur.emprunts.is_empty())
	verifier("R4 : deux comportements différents, présentations à des dates (ou dans un ordre) différentes", dates_a != dates or ordre_a != ordre)
	verifier("Actions toujours en dernier, Livret A toujours en premier", ordre_a[0] == "D01" and ordre_a.find("D06") > ordre_a.find("D05") and ordre_a.find("D06") > ordre_a.find("D04"))
	var avant := true
	for md in a["modales"]:
		if md["kind"] == "banquier" and md["id"] == "D04" and int(md["m"]) - ea.m_depart <= mn:
			avant = false
		if md["kind"] == "banquier" and md["id"] == "D07" and int(md["m"]) - ea.m_depart != mois_de("1986-11", ea):
			avant = false
	verifier("Aucune présentation avant sa date : assurance-vie après la naissance, Saint-Gobain en nov. 1986", avant)
	print("    Patrimoine final : passif %s, actif %s ; Tata Livret %s" % [mt(e, e.patrimoine(e.joueur)), mt(ea, ea.patrimoine(ea.joueur)), mt(ea, ea.patrimoine(ea.temoins["livret"]))])


func _tests_textes() -> void:
	var a := jouer(7, actif, actif_mois)
	var ok_mots := true
	var ok_franc := true
	var ok_ref := true
	var detail := ""
	for md in a["modales"]:
		if md["kind"] != "banquier":
			continue
		var c: Dictionary = md["c"]
		detail += "%s:%d " % [md["id"], int(c["mots"])]
		if int(c["mots"]) > 60:
			ok_mots = false
		if not str(c["texte"]).contains(Format.ESPACE + "F"):
			ok_franc = false
		if md["id"] != "D08" and md["id"] != "D01":
			var cp: Dictionary = c["comparatif"]
			if cp["ref"] == cp["produit"] or cp["ref"] == "cc" or cp["lignes"].size() != 4 or str(cp["frais"]) == "":
				ok_ref = false
	verifier("R3 : chaque présentation tient en 60 mots au plus", ok_mots, detail)
	verifier("R3 : chaque présentation chiffre en francs avec l'argent du joueur", ok_franc)
	verifier("R8 : chaque présentation (sauf le Livret A) se compare à un produit déjà présenté, sur 4 critères + frais", ok_ref)
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo())
	var c1 := e.contenu_modale()
	verifier("D01 : 12 600 F sur le compte → 945 F d'intérêts par an à 7,5 %", str(c1["texte"]).contains("12" + Format.ESPACE + "600" + Format.ESPACE + "F") and str(c1["texte"]).contains("945" + Format.ESPACE + "F") and c1["comparatif"]["ref"] == "cc", c1["texte"])
	# Comparatif : référence détenue en priorité
	var r: Array = a["modales"].filter(func(x: Dictionary) -> bool: return x["id"] == "D05")
	var c5: Dictionary = r[0]["c"]
	verifier("SICAV comparée à l'emprunt d'État détenu, « plus » de risque, « plus d'impôt » nulle part", c5["comparatif"]["ref"] == "emprunt" and c5["comparatif"]["ref_detenu"]
		and c5["comparatif"]["lignes"][1]["sens"] == "plus", str(c5["comparatif"]["lignes"]))


func _tests_pel_emprunt() -> void:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo())
	e.resoudre_modale("ouvrir")
	e.avancer()
	e.avancer()   # mars 1984
	var r := e.ouvrir_pel(fr(2000.0), fr(500.0))
	verifier("PEL ouvert en mars 1984 : taux fixé à 8,25 % prime comprise", r["ok"] and proche(float(e.joueur.pel["taux"]), 8.25))
	var cc0 := e.joueur.cc
	e.avancer()
	_resoudre(e)
	verifier("PEL : versement mensuel de 500 F prélevé automatiquement", proche(e.joueur.valeur_pel() * F, 2500.0, 1e-9))
	var d := Produits.devis_cloture_pel(e, e.joueur)
	verifier("PEL : clôture avant 4 ans = intérêts au taux réduit (2,75 % au lieu de 8,25 %)", d["anticipee"] and float(d["penalite"]) > 0.0 and proche(float(d["recu"]) - float(e.joueur.pel["verse"]), (float(e.joueur.pel["interets"]) + float(e.joueur.pel["courus"])) * 2.75 / 8.25))
	var e2 := EtatPartie.new()
	e2.demarrer(Donnees.config_demo())
	e2.joueur.cc += fr(20000.0)
	var b := e2.acheter_emprunt(fr(10000.0))
	verifier("Emprunt d'État acheté en 1984 : 13,4 % pour 10 ans", b["ok"] and proche(float(b["taux"]), 13.4))
	var coupon := 0.0
	var mois_coupon := -1
	for i in 12:
		_resoudre(e2)
		var rr := e2.avancer()
		for n in rr["notifs"]:
			if n["type"] == "coupon":
				coupon = float(n["montant"]) * F
				mois_coupon = e2.m
	_resoudre(e2)
	verifier("Coupon en janvier 1985 : 1 340 F, soit 1 125,60 F après 16 % d'impôt", absf(coupon - 1125.6) < 0.01 and mois_coupon - e2.m_depart == 12, "%.2f F reçus au mois %d" % [coupon, mois_coupon])
	var dv := Produits.devis_vente_emprunt(e2, e2.joueur, fr(10000.0), true)
	verifier("Revente de l'emprunt : au prix d'achat, plus les intérêts courus nets", dv["ok"] and proche(float(dv["nominal"]) * F, 10000.0) and float(dv["recu"]) >= float(dv["nominal"]))


func _resoudre(e: EtatPartie) -> void:
	var g := 0
	while not e.modale.is_empty() and g < 5:
		e.resolution_auto()
		g += 1


func _tests_assurance_vie() -> void:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo())
	_resoudre(e)
	while e.ab_courant() < Dates.lire("1985-04"):
		e.avancer()
		_resoudre(e)
	e.joueur.cc += fr(10000.0)
	var v := e.verser_av(fr(10000.0))
	verifier("Assurance-vie : 4 % de frais sur le versement (10 000 F → 9 600 F)", v["ok"] and proche(float(v["frais"]) * F, 400.0) and proche(e.joueur.valeur_av() * F, 9600.0))
	var d0 := Produits.devis_rachat_av(e, e.joueur, 0.0, true)
	verifier("Rachat immédiat : aucun gain, donc aucun impôt (on récupère 9 600 F)", proche(float(d0["impot"]), 0.0) and proche(float(d0["recu"]) * F, 9600.0))
	verifier("Exonération après 6 ans : contrat d'avril 1985 → avril 1991", int(d0["exoneration_ab"]) == Dates.lire("1991-04"), Dates.texte(int(d0["exoneration_ab"])))
	while e.ab_courant() < Dates.lire("1986-01"):
		e.avancer()
		_resoudre(e)
	var interets := (e.joueur.valeur_av() - fr(9600.0)) * F
	verifier("Intérêts crédités au 31/12/1985 au taux de 11,5 % (9 mois)", proche(interets, 9600.0 * 0.115 / 12.0 * 9.0, 1e-6), "%.2f F" % interets)
	var d1 := Produits.devis_rachat_av(e, e.joueur, 0.0, true)
	verifier("Rachat avant 2 ans : 45 % sur la part de gains seulement (gains = valeur − versements)",
		proche(float(d1["taux"]), 45.0) and proche(float(d1["gains"]), maxf(0.0, float(d1["dispo"]) - fr(10000.0))) and proche(float(d1["impot"]), float(d1["gains"]) * 0.45))
	while e.ab_courant() < Dates.lire("1987-06"):
		e.avancer()
		_resoudre(e)
	var d2 := Produits.devis_rachat_av(e, e.joueur, fr(1000.0))
	verifier("Rachat partiel de 2 à 4 ans : 25 % sur les gains contenus dans le retrait", proche(float(d2["taux"]), 25.0) and float(d2["gains"]) < fr(1000.0) and float(d2["gains"]) > 0.0,
		"gains %s, impôt %s" % [mt(e, d2["gains"]), mt(e, d2["impot"])])
	var avant := e.joueur.valeur_av() + float(e.joueur.av["courus"])
	e.racheter_av(fr(1000.0))
	verifier("Rachat partiel : la valeur baisse du montant retiré", proche(avant - e.joueur.valeur_av() - float(e.joueur.av["courus"]), fr(1000.0), 1e-6))


func _tests_frais() -> void:
	var a := Dates.ab(1986, 3)
	var p := Banquier.piles("sicav", fr(10000.0), a)
	verifier("3 piles (SICAV, 10 000 F, 7 %, 20 ans) : 38 697 / 28 594 / 23 032 F (11 §5.3 C)",
		absf(p["sans"] * F - 38697.0) < 1.0 and absf(p["produit"] * F - 28594.0) < 1.5 and absf(p["charge"] * F - 23032.0) < 1.5,
		"%.0f / %.0f / %.0f" % [p["sans"] * F, p["produit"] * F, p["charge"] * F])
	var pa := Banquier.piles("action", fr(2000.0), a, fr(50.0))
	verifier("3 piles (action, 2 000 F) : 50 F de courtage tout de suite, pile « plus chargé » plus basse", proche(pa["tout_de_suite"] * F, 50.0) and pa["charge"] < pa["produit"] and pa["produit"] < pa["sans"])
	var pv := Banquier.piles("av", fr(10000.0), a)
	verifier("3 piles (assurance-vie) : 4 % d'entrée ; plus chargé = + 1,5 %/an (arbitrage)", proche(pv["tout_de_suite"] * F, 400.0) and proche(pv["produit"] * F, 9600.0 * pow(1.07, 20), 1e-6) and proche(pv["charge"] * F, 9600.0 * pow(1.055, 20), 1e-6))
	# Jumeau sans frais et relevé de décembre (F02)
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo())
	_resoudre(e)
	e.joueur.cc += fr(10000.0)
	var d := e.acheter(e.joueur, "sicav", fr(10000.0))
	verifier("Achat de SICAV : 200 F de frais payés, coût total des frais = 200 F au jour de l'achat", proche(e.frais_payes() * F, 200.0) and proche(e.cout_frais_total(e.joueur) * F, 200.0, 1e-6) and e.manque_a_gagner() < fr(0.01),
		"%.4f F" % (e.cout_frais_total(e.joueur) * F))
	var releve := {}
	while e.ab_courant() < Dates.lire("1985-01"):
		var r := e.avancer()
		_resoudre(e)
		for n in r["notifs"]:
			if n["type"] == "releve":
				releve = n
	verifier("Relevé de décembre 1984 (F02) : frais de l'année = entrée + gestion, montants exacts du jumeau sans frais",
		not releve.is_empty() and float(releve["frais_annee"]) > fr(200.0) and proche(float(releve["frais_total"]), e.frais_payes(), 1e-9)
		and float(releve["manque"]) > 0.0 and str(releve["texte"]).contains("jamais existé"), str(releve.get("texte", "")))
	verifier("Jumeau sans frais : coût total = frais payés + gains qui n'ont jamais existé",
		proche(e.cout_frais_total(e.joueur), e.frais_payes() + e.manque_a_gagner(), 1e-9))
	# Courtage : avertissement au-delà de 2 % (F03) — 50 F sur 1 000 F = 5 %
	verifier("Courtage minimum : 50 F sur un ordre de 1 000 F = 5 % (> 2 %, F03)", Marche.frais_courtage(a, fr(1000.0)) / fr(1000.0) > float(Banquier.donnees()["frais_pedagogie"]["seuil_alerte"]))
	# Saint-Gobain pendant l'offre : sans courtage, 310 F
	var s := EtatPartie.new()
	s.demarrer(Donnees.config_demo())
	_resoudre(s)
	while s.ab_courant() < Dates.lire("1986-11"):
		s.avancer()
		_resoudre(s)
	var ds := s.devis_achat("saintgobain", fr(3100.0))
	verifier("Saint-Gobain à l'offre (nov. 1986) : 10 actions à 310 F, sans courtage", ds["ok"] and int(ds["qte"]) == 10 and float(ds["frais"]) == 0.0)


## Héritage « un seul pot » (retour du joueur du 27/10/2026, 11 §1.7.4) : un seul versement, 60 000 F en avril
## 1988 ; la carte compare la même somme passée par la succession (abattement 10 000 F, 55 % : 32 500 F nets).
func _tests_heritage() -> void:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo())
	var ecart_avant := 0.0
	var modale_d08 := false
	var extras := {}           # mois -> argent reçu en dehors du salaire, des dépenses et des événements de vie
	var garde := 0
	while e.fin == "" and garde < 100:
		_resoudre(e)
		if e.ab_courant() == Dates.lire("1988-03"):
			ecart_avant = e.ecart_livret()
		var en0 := e.epargne_nette
		var enfants0 := e.enfants
		var r := e.avancer()
		if e.fin != "":
			break
		var vie := 0.0
		for ev in e.calendrier:
			if int(ev["m"]) == e.m and ev.get("declenche", false) and ev["type"] != "naissance":
				vie += float(ev["montant"]) * (1.0 if e._type_vie(ev["type"])["effet"] == "gain" else -1.0)
		var extra := e.epargne_nette - en0 - e.epargne_du_mois() - vie
		if e.enfants == enfants0 and absf(extra) > fr(1.0):
			extras[Dates.texte_court(e.ab_courant())] = extra * F
		if e.ab_courant() == Dates.lire("1988-04"):
			modale_d08 = r["modale"].get("id", "") == "D08"
			verifier("Héritage (avril 1988) : la carte D08 arrive, l'écart avec Tata Livret ne bouge pas (même vie)",
				modale_d08 and absf(e.ecart_livret() - ecart_avant) < fr(500.0), "carte %s" % r["modale"].get("id", "?"))
			var c := e.contenu_modale()
			var tk := str(c["ticket"])
			verifier("Carte D08 : « par assurance-vie : 60 000 F / par succession : 32 500 F nets » (27 500 F de droits), bouton COMPRIS, ≤ 60 mots",
				c.get("heritage", false) and tk.contains("Si ça avait été par succession") and tk.contains("60" + Format.ESPACE + "000") and tk.contains("32" + Format.ESPACE + "500") and tk.contains("27" + Format.ESPACE + "500")
				and str(c["texte"]).contains("32" + Format.ESPACE + "500") and c["choix"].size() == 1 and int(c["mots"]) <= 60, "%s · %d mots" % [tk, int(c["mots"])])
			var h := Banquier.heritage_chiffres()
			verifier("Comparaison par succession (A) : (60 000 − 10 000) × 55 % = 27 500 F de droits, 32 500 F nets",
				absf(h["droits"] * F - 27500.0) < 0.01 and absf(h["net"] * F - 32500.0) < 0.01)
		garde += 1
	verifier("Un seul versement d'héritage dans toute la démo : 60 000 F en avril 1988, plus rien en septembre",
		extras.size() == 1 and extras.has(Dates.texte_court(Dates.lire("1988-04"))) and absf(float(extras.values()[0]) - 60000.0) < 0.5, str(extras))
	var d08bis := false
	for h in e.historique:
		if str(h["titre"]).contains("Succession"):
			d08bis = true
	verifier("Plus de message D08 bis (succession) dans l'historique", not d08bis)
	verifier("Héritage compté dans l'épargne : Tonton Matelas = épargne nette", proche(e.temoins["matelas"].cc, e.epargne_nette, 1e-9))


func _tests_naissance_scriptee() -> void:
	var jumeaux := 0
	var ok_budget := true
	var ok_date := true
	var detail := ""
	for g in range(1, 21):
		var e := EtatPartie.new()
		e.demarrer(Donnees.config_demo(g))
		var n := {}
		for ev in e.calendrier:
			if ev["type"] == "naissance":
				n = ev
		if n.is_empty() or e.ab_de(int(n["m"])) != Dates.lire("1985-04"):
			ok_date = false
			continue
		var nb := int(n["n"])
		if nb == 2:
			jumeaux += 1
		# Pire année de la démo (1984-1988) après la naissance
		for y in range(1985, 1989):
			var part := e.part_epargne(y, nb)
			if part < (0.05 if nb == 2 else 0.10) - 1e-9:
				ok_budget = false
				detail += "graine %d : %.1f %% en %d ; " % [g, part * 100.0, y]
	verifier("Naissance scriptée en avril 1985 pour les 20 graines, malgré « budget_positif_requis »", ok_date)
	verifier("Jumeaux : 3 à 7 sur 20 graines (1 chance sur 4, R14)", jumeaux >= 3 and jumeaux <= 7, "%d jumeaux sur 20" % jumeaux)
	verifier("Budget positif après la naissance : ≥ 10 % d'épargne avec un enfant, ≥ 5 % avec des jumeaux (A21, R14)", ok_budget, detail)
	# Le budget du mois reste positif dans une partie avec jumeaux
	var g_jum := -1
	for g in range(1, 21):
		var e := EtatPartie.new()
		e.demarrer(Donnees.config_demo(g))
		for ev in e.calendrier:
			if ev["type"] == "naissance" and int(ev["n"]) == 2:
				g_jum = g
		if g_jum > 0:
			break
	var p := jouer(g_jum, passif)
	var ej: EtatPartie = p["etat"]
	var faire_part := {}
	for md in p["modales"]:
		if md["kind"] == "vie" and md["c"].get("effet", "") == "naissance":
			faire_part = md["c"]
	verifier("Partie avec jumeaux (graine %d) : faire-part de 2 enfants, il reste de l'argent chaque mois" % g_jum,
		ej.enfants == 2 and int(faire_part.get("n", 0)) == 2 and float(faire_part.get("reste_apres", -1.0)) > 0.0,
		"reste %s par mois" % mt(ej, float(faire_part.get("reste_apres", 0.0))))


func _tests_cadence() -> void:
	var resume := ""
	var ok_un := true
	var ok_ecart := true
	var ok_cible := true
	for g in [7, 1, 2, 3, 11]:
		for strat in ["passif", "actif"]:
			var p := jouer(g, passif if strat == "passif" else actif, Callable() if strat == "passif" else actif_mois)
			var e: EtatPartie = p["etat"]
			var mois := []
			for md in p["modales"]:
				mois.append(int(md["m"]))
			var n := mois.size()
			for i in range(1, n):
				if mois[i] == mois[i - 1]:
					ok_un = false
			var liste: Array = e.banque["interruptions_liste"]
			for i in range(1, liste.size()):
				var x: Dictionary = liste[i]
				if int(x["m"]) - int(liste[i - 1]["m"]) < 2 and x.get("motif", "ecart") == "ecart":
					ok_ecart = false
			if n < 11 or n > 14:
				ok_cible = false
			resume += "g%d %s : %d ; " % [g, strat, n]
			if g == 7 and strat == "passif":
				var txt := ""
				for x in liste:
					txt += "%s %s (%s) · " % [Dates.texte_court(e.ab_de(int(x["m"]))), x["id"], x.get("motif", "")]
				print("    Interruptions (graine 7, passif) : ", txt)
				# Durée estimée à ×1 : 8 s par mois, plus 2 s d'animation et un temps de lecture par interruption
				var lecture := 0.0
				for x in liste:
					lecture += 2.0 + (40.0 if x["kind"] == "banquier" else 20.0)
				print("    Durée estimée à ×1 : %d min (60 mois × 8 s + %d interruptions)" % [int(round((60 * 8 + lecture) / 60.0)), liste.size()])
	print("    ", resume)
	verifier("Cadence : une interruption par mois au plus", ok_un)
	verifier("Cadence : au moins 2 mois entre deux interruptions (sauf marché, dates historiques, scripté)", ok_ecart)
	verifier("Cadence : 11 à 14 interruptions sur 60 mois (cible 12 à 14 ; 11 quand la graine ne tire aucune panne aléatoire)", ok_cible, resume)
	var distribution := {}
	var somme := 0
	for g in range(1, 41):
		var p := jouer(g, passif)
		var n: int = p["etat"].banque["interruptions_liste"].size()
		distribution[n] = int(distribution.get(n, 0)) + 1
		somme += n
	print("    Interruptions sur 40 graines (joueur passif) : ", distribution, ", moyenne %.1f" % (somme / 40.0))


func _ecrire_octets(chemin: String, octets: PackedByteArray) -> void:
	var f := FileAccess.open(chemin, FileAccess.WRITE)
	f.store_buffer(octets)
	f.close()


## Fichier au bon format (en-tête, empreinte) mais au contenu choisi.
func _ecrire_brut(chemin: String, version: int, d: Dictionary) -> void:
	var contenu := var_to_bytes(d)
	var h := HashingContext.new()
	h.start(HashingContext.HASH_SHA256)
	h.update(contenu)
	var f := FileAccess.open(chemin, FileAccess.WRITE)
	f.store_buffer("JCSV".to_ascii_buffer())
	f.store_32(version)
	f.store_buffer(h.finish())
	f.store_buffer(contenu)
	f.close()


func _etat_txt(e: EtatPartie) -> String:
	return var_to_str(e.vers_dict())


func _tests_sauvegarde() -> void:
	# Partie jouée d'une traite
	var ref := jouer(7, actif, actif_mois)
	var e_ref: EtatPartie = ref["etat"]
	# La même partie, sauvegardée et rechargée à plusieurs moments (dont un mois avec une modale ouverte)
	var ok := true
	var detail := ""
	for arret in [5, 15, 34, 46]:
		var p := EtatPartie.new()
		var res := p.demarrer(Donnees.config_demo(7))
		var debut := continuer(p, res, actif, actif_mois, arret)
		var e1: EtatPartie = debut["etat"]
		var octets := var_to_bytes(e1.vers_dict())
		var e2 := EtatPartie.depuis_dict(bytes_to_var(octets))
		if e2 == null:
			ok = false
			detail += "rechargement impossible au mois %d ; " % arret
			continue
		var avant := _etat_txt(e1)
		if _etat_txt(e2) != avant:
			ok = false
			detail += "état différent après rechargement au mois %d ; " % arret
		var modale_ouverte := not e2.modale.is_empty()
		var suite := continuer(e2, {"notifs": []}, actif, actif_mois)
		var e3: EtatPartie = suite["etat"]
		if _etat_txt(e3) != _etat_txt(e_ref):
			ok = false
			detail += "fin différente (arrêt au mois %d) ; " % arret
		else:
			detail += "mois %d%s : identique ; " % [arret, " (modale ouverte)" if modale_ouverte else ""]
	verifier("Sauvegarde : jouer N mois, sauvegarder, recharger, jouer encore = partie jouée d'une traite", ok, detail)
	# Fichier dans user:// : écriture, lecture, tolérance
	var chemin := fichier_user("test_sauvegarde")
	Sauvegarde.effacer(chemin)
	verifier("Sauvegarde absente : rien à reprendre, sans erreur", Sauvegarde.lire(chemin).is_empty() and not Sauvegarde.existe(chemin))
	var ecrit := Sauvegarde.ecrire(e_ref, {"vitesse": 2}, chemin)
	var lu := Sauvegarde.lire(chemin)
	var e4 := Sauvegarde.charger(lu)
	verifier("Sauvegarde dans user:// : écrite, relue, résumé (date, patrimoine) et réglages",
		ecrit and e4 != null and _etat_txt(e4) == _etat_txt(e_ref) and lu["resume"]["date"] == "décembre 1988" and int(lu["partie"]["vitesse"]) == 2 and proche(float(lu["resume"]["patrimoine"]), e_ref.patrimoine(e_ref.joueur)))
	# Fichier abîmé : un octet modifié au milieu, puis fichier tronqué, puis texte quelconque
	var f := FileAccess.open(chemin, FileAccess.READ)
	var octets := f.get_buffer(f.get_length())
	f.close()
	octets[octets.size() / 2] = (octets[octets.size() / 2] + 1) % 256
	_ecrire_octets(chemin, octets)
	verifier("Sauvegarde modifiée (un octet) : ignorée, sans erreur", Sauvegarde.lire(chemin).is_empty())
	_ecrire_octets(chemin, octets.slice(0, octets.size() / 3))
	verifier("Sauvegarde tronquée : ignorée", Sauvegarde.lire(chemin).is_empty())
	_ecrire_octets(chemin, "{ \"jeu\": \"JeuClaude\", n'importe quoi".to_utf8_buffer())
	verifier("Sauvegarde illisible (texte quelconque) : ignorée", Sauvegarde.lire(chemin).is_empty())
	_ecrire_brut(chemin, 0, {"jeu": "JeuClaude", "version": 0, "resume": {}, "partie": {}, "etat": {}})
	verifier("Sauvegarde d'une ancienne version : ignorée", Sauvegarde.lire(chemin).is_empty())
	var ancien := e_ref.vers_dict()
	ancien["version_etat"] = 1
	ancien.erase("historique")
	_ecrire_brut(chemin, 1, {"jeu": "JeuClaude", "version": 1, "resume": {"ab": 0}, "partie": {}, "etat": ancien})
	verifier("Sauvegarde au format 1 (sans historique) : ignorée proprement, nouvelle partie", Sauvegarde.lire(chemin).is_empty() and Sauvegarde.charger(Sauvegarde.lire(chemin)) == null)
	_ecrire_brut(chemin, Sauvegarde.VERSION, {"jeu": "JeuClaude", "version": Sauvegarde.VERSION, "resume": {}, "partie": {}, "etat": {"version_etat": 1}})
	verifier("Sauvegarde d'un état de version inconnue : ignorée proprement (format 3 : un champ absent prend sa valeur par défaut, voir test_sauvegarde)",
		Sauvegarde.lire(chemin).is_empty() and Sauvegarde.charger(Sauvegarde.lire(chemin)) == null)
	Sauvegarde.effacer(chemin)
	verifier("Effacer la sauvegarde", not FileAccess.file_exists(chemin))


# ---------------------------------------------------------------------
# Historique des pop-ups (retour du joueur du 27/10/2026)
# ---------------------------------------------------------------------

func _tests_historique() -> void:
	var p := jouer(7, actif, actif_mois)
	var e: EtatPartie = p["etat"]
	var h: Array = e.historique
	var nb_modales := 0
	var nb_notifs := 0
	for x in h:
		if x["genre"] == "notif":
			nb_notifs += 1
		else:
			nb_modales += 1
	verifier("Historique : chaque pop-up vue est rangée (%d modales, %d notifications)" % [nb_modales, nb_notifs],
		nb_modales == p["modales"].size() and nb_notifs == p["notifs"].size(), "modales vues %d, notifications reçues %d" % [p["modales"].size(), p["notifs"].size()])
	var recent := e.historique_recent()
	var ordre_ok := true
	for i in range(1, recent.size()):
		if int(recent[i]["m"]) > int(recent[i - 1]["m"]) or int(recent[i]["i"]) > int(recent[i - 1]["i"]):
			ordre_ok = false
	verifier("Historique antéchronologique : du plus récent (déc. 1988) au plus ancien (janv. 1984)", ordre_ok and recent.size() == h.size()
		and e.ab_de(int(recent[0]["m"])) == Dates.lire("1988-12") and e.ab_de(int(recent[recent.size() - 1]["m"])) == Dates.lire("1984-01"))
	var champs_ok := true
	var detail := ""
	for x in h:
		var res := str(x["resume"])
		if str(x["titre"]) == "" or res.length() > 112 or res.contains("\n") or not x["source"] in ["maison", "banque", "media"] or not x["contenu"] is Dictionary:
			champs_ok = false
			detail += "%s / %s ; " % [x["titre"], res]
		if x["genre"] != "notif" and str(x["choix"]) == "":
			champs_ok = false
			detail += "choix manquant : %s ; " % x["titre"]
	verifier("Chaque entrée : date, source, titre, résumé d'une ligne ; le choix fait pour chaque décision", champs_ok, detail)
	var n_src := 0
	var filtre_ok := true
	for s in ["maison", "banque", "media"]:
		var l := e.historique_recent(s)
		n_src += l.size()
		for x in l:
			if x["source"] != s:
				filtre_ok = false
	verifier("Filtre par source : maison + banque + média = tout, sans mélange", filtre_ok and n_src == h.size(),
		"maison %d, banque %d, média %d" % [e.historique_recent("maison").size(), e.historique_recent("banque").size(), e.historique_recent("media").size()])
	# Contenus précis : le Livret A (choix « Ouvrir un livret a »), l'héritage (montant, résumé), le krach (choix, montant en jeu)
	var d01 := {}
	var d08 := {}
	var krach := {}
	var releve := {}
	for x in h:
		if x["genre"] == "appel" and x["contenu"].get("id", "") == "D01":
			d01 = x
		if x["genre"] == "appel" and x["contenu"].get("heritage", false):
			d08 = x
		if x["genre"] == "journal" and x["contenu"].get("gravite", "") == "majeure":
			krach = x
		if x["type"] == "releve" and releve.is_empty():
			releve = x
	verifier("Entrée Livret A : banque, « M. Lefranc présente : Livret A », choix Ouvrir, contenu complet (texte, ticket, comparatif) pour la relecture",
		not d01.is_empty() and d01["source"] == "banque" and str(d01["titre"]).contains("Livret A") and str(d01["choix"]).begins_with("Ouvrir")
		and d01["contenu"].has("comparatif") and d01["contenu"].has("ticket") and e.ab_de(int(d01["m"])) == Dates.lire("1984-01"), str(d01.get("choix", "")))
	verifier("Entrée héritage : avril 1988, + 60 000 F, résumé hypothétique « par succession, il ne vous serait resté que 32 500 F », choix Compris",
		not d08.is_empty() and absf(float(d08["montant"]) * F - 60000.0) < 0.5 and str(d08["resume"]).contains("il ne vous serait resté que 32" + Format.ESPACE + "500") and d08["choix"] == "Compris"
		and e.ab_de(int(d08["m"])) == Dates.lire("1988-04"), str(d08.get("resume", "")))
	verifier("Entrée du krach : média, choix « Ne rien faire », montant en jeu sur les placements",
		not krach.is_empty() and krach["source"] == "media" and krach["choix"] == "Ne rien faire" and krach["a_montant"] and float(krach["montant"]) < 0.0,
		"%s %s" % [krach.get("choix", ""), mt(e, float(krach.get("montant", 0.0)))])
	verifier("Entrée relevé de décembre : banque, texte complet conservé (frais) pour la relecture", not releve.is_empty() and str(releve["contenu"].get("texte", "")).length() > 30)
	# Persistance : fichier écrit, relu, historique identique ; puis la partie continue d'en ajouter
	var q := EtatPartie.new()
	var res := q.demarrer(Donnees.config_demo(7))
	var debut := continuer(q, res, actif, actif_mois, q.m_depart + 30)
	var e1: EtatPartie = debut["etat"]
	var chemin := fichier_user("test_historique")
	Sauvegarde.ecrire(e1, {}, chemin)
	var e2 := Sauvegarde.charger(Sauvegarde.lire(chemin))
	verifier("Historique sauvegardé puis rechargé à l'identique (%d entrées au mois 30)" % e1.historique.size(),
		e2 != null and e1.historique.size() > 10 and var_to_str(e2.historique) == var_to_str(e1.historique))
	continuer(e2, {"notifs": []}, actif, actif_mois)
	verifier("Après rechargement, la partie continue : même historique final que la partie d'une traite",
		var_to_str(e2.historique) == var_to_str(e.historique), "%d / %d entrées" % [e2.historique.size(), e.historique.size()])
	Sauvegarde.effacer(chemin)
	print("    Historique (graine 7, joueur actif) : %d entrées ; 4 plus récentes : %s" % [h.size(), str(recent.slice(0, 4).map(func(x: Dictionary) -> String: return "%s · %s · %s" % [Dates.texte_court(e.ab_de(int(x["m"]))), x["titre"], x["resume"]]))])


# ---------------------------------------------------------------------
# PEL : le même taux affiché partout (défaut relevé sur les captures)
# ---------------------------------------------------------------------

func _tests_taux_pel() -> void:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo())
	e.resoudre_modale("ouvrir")
	var c2 := {}
	var garde := 0
	while garde < 20 and c2.is_empty():
		e.avancer()
		if not e.modale.is_empty() and e.modale.get("id", "") == "D02":
			c2 = e.contenu_modale()
			e.resoudre_modale("ouvrir")
		else:
			_resoudre(e)
		garde += 1
	var ab_d02 := e.ab_courant()
	e.ouvrir_pel(fr(2000.0), fr(500.0))
	var tp := Produits.taux_pel(ab_d02)
	var attendu := "%s %% + prime d'État ≈ %s %%" % [Format.nombre(float(tp[1]), 2), Banquier.taux_txt(float(tp[0]))]
	var mot_d02: String = c2["comparatif"]["lignes"][0]["mot"]
	verifier("Présentation du PEL (%s) : « %s » dans le comparatif, le même taux dans le texte" % [Dates.texte(ab_d02), attendu],
		mot_d02 == attendu and str(c2["texte"]).contains(Banquier.taux_txt(float(tp[0])) + " %"), "%s | %s" % [mot_d02, c2["texte"]])
	# Deux ans plus tard (l'offre du jour est tombée à 6 %) : le PEL détenu garde partout son taux d'ouverture
	while e.ab_courant() < Dates.lire("1986-12"):
		e.avancer()
		_resoudre(e)
	var long := Banquier.texte_taux_pel(e)
	var court := Banquier.texte_taux_pel(e, true)
	var v := Banquier.variables(e)
	var mot_fiche := Format.gabarit(str(Banquier.info_produit("pel")["mots"]["rendement"]), v)
	var t := Banquier.taux_txt(float(e.joueur.pel["taux"]))
	verifier("PEL détenu : fiche, ordre, carte et comparatif disent tous « %s » (carte : « %s »), jamais le taux du jour" % [long, court],
		long == attendu and mot_fiche == attendu and court == "≈ %s %% fixe" % t and not long.contains(Banquier.taux_txt(float(Produits.taux_pel(e.ab_courant())[0])) + " %"))
	verifier("Le calcul utilise le même taux : intérêts du PEL au taux prime comprise affiché (%s %%)" % t,
		proche(float(e.joueur.pel["taux"]), float(tp[0])) and proche(float(e.joueur.pel["taux_hp"]), float(tp[1])))
	var sans := EtatPartie.new()
	sans.demarrer(Donnees.config_demo())
	while sans.ab_courant() < Dates.lire("1986-12"):
		sans.avancer()
		_resoudre(sans)
	verifier("Sans PEL : l'offre du jour, écrite de la même façon (déc. 1986 : « 4,62 % + prime d'État ≈ 6 % »)", Banquier.texte_taux_pel(sans) == "4,62 % + prime d'État ≈ 6 %", Banquier.texte_taux_pel(sans))


# ---------------------------------------------------------------------
# Versements automatiques mensuels (11 §8, VP1 à VP11)
# ---------------------------------------------------------------------

## Une partie neuve, produits présentés (sans pop-up en attente), au mois ab.
func _partie_au(ab: int, presenter: Array) -> EtatPartie:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo())
	_resoudre(e)
	while e.ab_courant() < ab:
		e.avancer()
		_resoudre(e)
	for id in presenter:
		e.banque["presentes"][id] = e.m
	return e


func _avancer_propre(e: EtatPartie) -> Dictionary:
	var r := e.avancer()
	_resoudre(e)
	return r


func _tests_versements() -> void:
	var e := _partie_au(Dates.lire("1985-01"), ["D01", "D02", "D03", "D05", "D06"])
	verifier("Éligibilité (11 §8.1) : emprunt d'État et actions refusés, avec l'explication",
		not e.programmer_versement("emprunt", fr(500.0))["ok"] and not e.programmer_versement("elf", fr(500.0))["ok"]
		and str(e.programmer_versement("elf", fr(500.0))["msg"]).contains("50 F"))
	verifier("Minimum par produit : SICAV 300 F (200 F refusés), Livret A 100 F",
		not e.programmer_versement("sicav", fr(200.0))["ok"] and e.programmer_versement("livret", fr(100.0))["ok"])
	var e0 := _partie_au(Dates.lire("1984-03"), [])
	e0.banque["presentes"].erase("D04")
	verifier("Produit pas encore présenté (assurance-vie en mars 1984) : refusé", not e0.programmer_versement("av", fr(500.0))["ok"])
	# Livret A : versement, puis plafond (VP5)
	var l := _partie_au(Dates.lire("1985-01"), ["D01"])
	l.programmer_versement("livret", fr(500.0))
	var livret0 := l.joueur.livret
	var cc0 := l.joueur.cc
	_avancer_propre(l)
	verifier("Livret A : 500 F virés le mois suivant, du compte vers le livret (VP1)", proche((l.joueur.livret - livret0) * F, 500.0, 1e-9)
		and proche((cc0 + l.epargne_du_mois() - l.joueur.cc) * F, 500.0, 1e-6), "%.2f F" % ((l.joueur.livret - livret0) * F))
	l.joueur.livret = Marche.plafond_livret(l.ab_courant() + 1) - fr(300.0)
	l.joueur.cc += fr(5000.0)
	_avancer_propre(l)
	var plein := Marche.plafond_livret(l.ab_courant())
	verifier("Plafond du Livret A : versement réduit à la place restante (300 F au lieu de 500 F)", proche(l.joueur.livret, plein, 1e-6) and l.joueur.versements["livret"]["suspendu"] == "")
	var r := _avancer_propre(l)
	var msg_plein := false
	for n in r["notifs"]:
		if str(n["titre"]) == "Livret A plein" and n.get("persistant", false):
			msg_plein = true
	verifier("Livret A plein : plan suspendu, message persistant, l'argent reste sur le compte", l.joueur.versements["livret"]["suspendu"] == "plafond" and msg_plein and proche(l.joueur.livret, plein, 1e-6))
	# Compte insuffisant (VP3), suspension après 3 refus (VP4), réactivation
	var c := _partie_au(Dates.lire("1985-01"), ["D01"])
	c.programmer_versement("livret", fr(1000.0))
	var refus := 0
	var titres := []
	for k in 3:
		c.joueur.cc = fr(700.0) - c.epargne_du_mois()   # le mois suivant, après la paye, le compte n'aura que 700 F
		var liv := c.joueur.livret
		var rr := _avancer_propre(c)
		if proche(c.joueur.livret, liv, 1e-9):
			refus += 1
		for n in rr["notifs"]:
			if n.get("type", "") == "versement":
				titres.append(str(n["titre"]))
	verifier("Compte insuffisant : versement non fait, jamais de découvert ; après 3 refus de suite, plan suspendu (message persistant)",
		refus == 3 and c.joueur.cc >= 0.0 and c.joueur.versements["livret"]["suspendu"] == "refus" and titres == ["Versement non effectué", "Versement non effectué", "Versement automatique suspendu"], str(titres))
	verifier("Réactivation d'un toucher : le plan repart (effet le mois suivant)", c.reactiver_versement("livret")["ok"] and c.joueur.versements["livret"]["suspendu"] == "")
	# Frais sur chaque versement (VP7) : SICAV 2 %, assurance-vie 4 %, comptés dans les frais et le jumeau sans frais
	var s := _partie_au(Dates.lire("1986-03"), ["D01", "D04", "D05"])
	s.joueur.cc += fr(20000.0)
	var rs := s.programmer_versement("sicav", fr(500.0))
	var ra := s.programmer_versement("av", fr(500.0))
	var frais0 := s.frais_payes()
	var q0 := s.joueur.qte("sicav")
	_avancer_propre(s)
	var frais_entree := s.frais_payes() - frais0   # pas encore de frais de gestion : la SICAV vient d'être achetée
	verifier("Frais par versement : SICAV 10 F (2 %) + assurance-vie 20 F (4 %) sur 500 F chacun",
		absf(frais_entree * F - 30.0) < 0.6 and proche((s.joueur.qte("sicav") - q0) * s.cours("sicav") * F, 490.0, 1e-6) and proche(s.joueur.valeur_av() * F, 480.0, 1e-6),
		"frais d'entrée %.2f F, SICAV +%.2f F, AV %.2f F" % [frais_entree * F, (s.joueur.qte("sicav") - q0) * s.cours("sicav") * F, s.joueur.valeur_av() * F])
	verifier("Textes de M. Lefranc à l'activation : lissage du prix (VP-B) et frais du versement (VP-C : 10 F par mois, 120 F par an)",
		rs["textes"].size() == 2 and str(rs["textes"][1]).contains("120" + Format.ESPACE + "F") and str(ra["textes"][0]).contains("240" + Format.ESPACE + "F"), str(rs["textes"]))
	verifier("Jumeau sans frais : les frais des versements comptent dans le coût total", s.cout_frais_total(s.joueur) >= s.frais_payes() - fr(0.01))
	# Relevé et historique groupés
	var releve := {}
	while s.ab_courant() < Dates.lire("1987-01"):
		var rr2 := _avancer_propre(s)
		for n in rr2["notifs"]:
			if n["type"] == "releve":
				releve = n
	var n_vers := 0
	for h in s.historique:
		if h.get("type", "") == "versement":
			n_vers += 1
	verifier("Relevé de décembre : « Versements automatiques de l'année » avec le détail par produit", str(releve.get("texte", "")).contains("Versements automatiques de l'année")
		and str(releve.get("texte", "")).contains("SICAV : 9 versements"), str(releve.get("texte", "")))
	verifier("Historique groupé : les 2 réglages, pas une ligne par versement mensuel (18 versements)", n_vers == 2, "%d entrées « versement »" % n_vers)
	# PEL : 3 600 F par an (VP6)
	var pe := _partie_au(Dates.lire("1984-03"), ["D02"])
	pe.ouvrir_pel(fr(300.0), fr(300.0))
	var anniv := pe.m + 12
	var notes := []
	while pe.m < anniv:
		if pe.m == anniv - 5 or pe.m == anniv - 4:
			pe.joueur.cc = -pe.epargne_du_mois() + fr(100.0)   # le mois suivant, le compte n'aura que 100 F : versement reporté
		var rr3 := _avancer_propre(pe)
		for n in rr3["notifs"]:
			if n.get("type", "") in ["versement", "info"]:
				notes.append(str(n["titre"]))
	verifier("PEL : 2 versements reportés (compte insuffisant), puis à la date anniversaire le manque est prélevé (3 600 F par an)",
		notes.count("Versement du PEL reporté") == 2 and notes.has("PEL : versement annuel complété") and proche(float(pe.joueur.pel["verse"]) * F, 3600.0 + 300.0 - 300.0, 1e-6), "%s · versé %.0f F" % [str(notes), float(pe.joueur.pel.get("verse", 0.0)) * F])
	var pc := _partie_au(Dates.lire("1984-03"), ["D02"])
	pc.ouvrir_pel(fr(300.0), fr(300.0))
	var anniv2 := pc.m + 12
	var clos := false
	while pc.m < anniv2:
		if pc.m >= anniv2 - 3:
			pc.joueur.cc = -pc.epargne_du_mois() + fr(100.0)
		var rr4 := _avancer_propre(pc)
		for n in rr4["notifs"]:
			if str(n["titre"]) == "PEL clos":
				clos = true
	verifier("PEL : moins de 3 600 F dans l'année et compte insuffisant : plan clos (taux réduit), message persistant", clos and pc.joueur.pel.is_empty())
	var pn := _partie_au(Dates.lire("1984-03"), ["D02"])
	pn.ouvrir_pel(fr(300.0), fr(300.0))
	verifier("PEL : le versement obligatoire se règle comme un plan (300, 500, 1 000 F), minimum 300 F",
		not pn.programmer_versement("pel", fr(200.0))["ok"] and pn.programmer_versement("pel", fr(500.0))["ok"] and proche(float(pn.joueur.pel["mensuel"]) * F, 500.0) and Versements.total_mensuel(pn) * F > 499.0)
	# VP-A : une fois, 3 mois après le premier produit éligible détenu
	var a := jouer(7, actif, actif_mois)
	var n_vpa := 0
	var m_vpa := -1
	for n in a["notifs"]:
		if str(n["titre"]) == "Épargner sans y penser":
			n_vpa += 1
			m_vpa = 1
	verifier("VP-A « Épargner sans y penser » : une seule fois, en message persistant (sans pause)", n_vpa == 1 and m_vpa == 1)
	# Sauvegarde : les plans et leurs compteurs sont rechargés à l'identique
	var sv := _partie_au(Dates.lire("1986-03"), ["D01", "D05"])
	sv.joueur.cc += fr(10000.0)
	sv.programmer_versement("sicav", fr(300.0))
	sv.programmer_versement("livret", fr(200.0))
	_avancer_propre(sv)
	var sv2 := EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(sv.vers_dict())))
	for k in 6:
		_avancer_propre(sv)
		_avancer_propre(sv2)
	verifier("Sauvegarde : versements automatiques rechargés, la suite est identique", _etat_txt(sv) == _etat_txt(sv2) and sv2.joueur.versements.size() == 2)


# ---------------------------------------------------------------------
# Événements de vie : pas deux fois le même événement aléatoire en 24 mois (retour du coordinateur)
# ---------------------------------------------------------------------

func _tests_repetitions() -> void:
	var ecart := int(Donnees.vie()["ecartRepetitionMois"])
	var ok := true
	var forces := 0
	var detail := ""
	for g in range(1, 41):
		for config in [Donnees.config_demo(g), {"periode": "P1", "profil": "jeune", "graine_vie": g}]:
			var e := EtatPartie.new()
			e.demarrer(config)
			var cal: Array = e.calendrier.filter(func(x: Dictionary) -> bool: return x["type"] != "naissance")
			for i in cal.size():
				if cal[i].get("force", false):
					forces += 1
				for j in range(i + 1, cal.size()):
					var x: Dictionary = cal[i]
					var z: Dictionary = cal[j]
					if x["type"] == z["type"] and absi(int(x["m"]) - int(z["m"])) < ecart and not (x.get("force", false) and z.get("force", false)):
						ok = false
						detail += "graine %d : %s aux mois %d et %d ; " % [g, x["type"], int(x["m"]), int(z["m"])]
	verifier("Événements de vie : jamais le même événement aléatoire à moins de %d mois (40 graines, démo et P1 entière), coïncidences forcées gardées (%d)" % [ecart, forces],
		ok and forces > 0, detail)
	var e7 := EtatPartie.new()
	e7.demarrer(Donnees.config_demo(11))
	var pannes := e7.calendrier.filter(func(x: Dictionary) -> bool: return x["type"] == "voiture").map(func(x: Dictionary) -> String: return Dates.texte_court(e7.ab_de(int(x["m"]))))
	var m_force := -1
	for x in e7.calendrier:
		if x["type"] == "voiture" and x.get("force", false):
			m_force = int(x["m"])
	var proches := e7.calendrier.filter(func(x: Dictionary) -> bool: return x["type"] == "voiture" and absi(int(x["m"]) - m_force) < 24)
	verifier("Graine des captures (11) : une seule panne dans les 24 mois autour de celle du krach (plus de seconde panne en janv. 1988)", m_force >= 0 and proches.size() == 1, str(pannes))

# ---------------------------------------------------------------------
# StrategieTest (lot 01) : joueurs automatiques partagés par les tests et les captures
# ---------------------------------------------------------------------

func _tests_strategie() -> void:
	# Joueur actif sur 20 graines : démo finie sans faillite, au moins 7 des 9 produits détenus à un moment
	var sans_faillite := 0
	var min_detenus := 99
	var detail := ""
	for g in range(1, 21):
		var e := EtatPartie.new()
		e.demarrer(Donnees.config_demo(g))
		var detenus := {}
		var garde := 0
		while e.fin == "" and garde < 100:
			StrategieTest.aller_a(e, e.ab_courant() + 1, true)
			for pid in Banquier.ordre_carnet():
				if Banquier.detenu(e, pid):
					detenus[pid] = true
			garde += 1
		if e.fin == "fin" and e.ab_courant() == Dates.lire("1988-12"):
			sans_faillite += 1
		else:
			detail += "graine %d : fin « %s » en %s ; " % [g, e.fin, Dates.texte(e.ab_courant())]
		min_detenus = mini(min_detenus, detenus.size())
		if detenus.size() < 7:
			detail += "graine %d : %d produits détenus %s ; " % [g, detenus.size(), str(detenus.keys())]
	verifier("StrategieTest, joueur actif sur 20 graines : démo finie sans faillite, au moins 7 des 9 produits détenus (minimum %d)" % min_detenus,
		sans_faillite == 20 and min_detenus >= 7, detail)
	# Le choix par défaut annoncé (choix_modale) est bien celui d'EtatPartie.resolution_auto
	var ok_choix := true
	var n_modales := 0
	var detail_choix := ""
	for g in range(1, 6):
		var e := EtatPartie.new()
		e.demarrer(Donnees.config_demo(g))
		var garde := 0
		while e.fin == "" and garde < 100:
			if not e.modale.is_empty():
				var c := e.contenu_modale()
				var attendu := StrategieTest.choix_modale(e, false)
				e.resolution_auto()
				n_modales += 1
				var vu: String = e.historique[e.historique.size() - 1]["choix"]
				if vu != e.libelle_choix(c, attendu):
					ok_choix = false
					detail_choix += "graine %d, %s : « %s » au lieu de « %s » ; " % [g, str(c.get("titre", "")), vu, e.libelle_choix(c, attendu)]
			e.avancer()
			garde += 1
	verifier("StrategieTest.choix_modale (joueur passif) = choix de resolution_auto (%d modales, 5 graines)" % n_modales, ok_choix and n_modales > 50, detail_choix)
	# Sauts : mois exact, modale du krach, présentation du PEL, identifiant inconnu
	var e1 := EtatPartie.new()
	e1.demarrer(Donnees.config_demo(7))
	StrategieTest.aller_a(e1, Dates.lire("1986-03"), true)
	var e1p := EtatPartie.new()
	e1p.demarrer(Donnees.config_demo(7))
	StrategieTest.aller_a(e1p, Dates.lire("1986-03"), false)
	verifier("StrategieTest.aller_a(1986-03) arrive exactement en mars 1986 (joueur actif et passif)",
		e1.ab_courant() == Dates.lire("1986-03") and e1p.ab_courant() == Dates.lire("1986-03") and e1.fin == "" and e1p.fin == "",
		"%s / %s" % [Dates.texte(e1.ab_courant()), Dates.texte(e1p.ab_courant())])
	var e2 := EtatPartie.new()
	e2.demarrer(Donnees.config_demo(7))
	var trouve_krach := StrategieTest.aller_a_modale(e2, "p1e6", true)
	var c2 := e2.contenu_modale()
	verifier("StrategieTest.aller_a_modale(« p1e6 », actif) s'arrête sur la modale du krach (octobre 1987, non résolue)",
		trouve_krach and StrategieTest.id_modale(e2) == "p1e6" and c2.get("kind", "") == "marche" and c2.get("gravite", "") == "majeure" and e2.ab_courant() == Dates.lire("1987-10"),
		"%s, %s" % [Dates.texte(e2.ab_courant()), str(c2.get("titre", "?"))])
	var e3 := EtatPartie.new()
	e3.demarrer(Donnees.config_demo(7))
	var trouve_pel := StrategieTest.aller_a_modale(e3, "D02", false)
	verifier("StrategieTest.aller_a_modale(« D02 », passif) s'arrête sur la présentation du PEL (au plus tard en juillet 1984)",
		trouve_pel and e3.modale.get("id", "") == "D02" and e3.contenu_modale().get("kind", "") == "banquier" and e3.ab_courant() <= Dates.lire("1984-07"),
		Dates.texte(e3.ab_courant()))
	var e4 := EtatPartie.new()
	e4.demarrer(Donnees.config_demo(7))
	var t0 := Time.get_ticks_msec()
	var trouve_inconnu := StrategieTest.aller_a_modale(e4, "inconnu", true)
	verifier("StrategieTest.aller_a_modale(id inconnu) renvoie false, sans boucle infinie (partie menée jusqu'à la fin)",
		not trouve_inconnu and e4.fin == "fin", "%s, %d ms" % [e4.fin, Time.get_ticks_msec() - t0])
	var e5 := EtatPartie.new()
	e5.demarrer(Donnees.config_demo(7))
	StrategieTest.aller_a(e5, Dates.lire("2050-01"), false)
	verifier("StrategieTest.aller_a au-delà de la démo : s'arrête à la fin de la partie (décembre 1988)", e5.fin == "fin" and e5.ab_courant() == Dates.lire("1988-12"))
