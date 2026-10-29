extends SceneTree
## Tests headless de la logique (aucune scène, aucun nœud d'interface).
## Lancer depuis la racine du dépôt (après un premier --import) :
##   outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/test_logique.gd
## Code de sortie : 0 si tout passe, 1 sinon.

const F := 6.55957  # francs par euro

# Valeurs de référence calculées par la V1 web (jeu/js, exécutée dans Edge headless) : le portage doit
# redonner exactement les mêmes cours. Cases du tableau : 0 = déc. 1977, m + 1 = mois m.
const REF_U := [0.9797282677609473, 0.3067522644996643, 0.484205421525985, 0.817934412509203, 0.5094283693470061]
const REF_CASES := [1, 12, 40, 100, 117, 118, 150, 180]
const REF_INDICE := [229.90679835267173, 335.50000000000006, 410.00000000000017, 1033.4484634985122,
	1309.9999999999998, 1033.0, 2087.1883292510292, 1857.7999999999993]
const REF_SICAV := [153.4982941431794, 231.2771832738939, 307.5195932157287, 919.1494156249686,
	1192.2355886523349, 941.7786324737685, 1983.2470214442124, 1853.660752340349]
const REF_PEUGEOT := [54.52027794016318, 64.02858723971238, 39.59319836045264, 66.71215977619435,
	75.50658297371349, 59.841857258249235, 131.0390136277837, 106.71431206618729]

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_hasard_et_format()
	_tests_marche()
	_tests_salaire_et_livret()
	_tests_sicav_et_fiscalite()
	_tests_partie_complete()
	_tests_calendrier_et_evenements()
	_tests_faillite_et_tranche()
	_tests_comparaison_livret()
	_tests_naissance()
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


func proche(a: float, b: float, tol := 1e-6) -> bool:
	return absf(a - b) <= tol * maxf(1.0, absf(b))


## Joue une partie jusqu'au bout. strategie(e, res) est appelée chaque mois avant la résolution auto.
func jouer(config: Dictionary, strategie := Callable()) -> Dictionary:
	var e := EtatPartie.new()
	var res := e.demarrer(config)
	var modales := []
	var notifs: Array = res["notifs"].duplicate()
	var garde := 0
	while e.fin == "" and garde < 400:
		if strategie.is_valid():
			strategie.call(e, res)
		if not e.modale.is_empty():
			var c := e.contenu_modale()
			c["m"] = e.m
			modales.append(c)
			e.resolution_auto()
		res = e.avancer()
		notifs.append_array(res["notifs"])
		garde += 1
	return {"etat": e, "modales": modales, "notifs": notifs}


# ---------------------------------------------------------------------

func _tests_hasard_et_format() -> void:
	var r := Hasard.new(12345)
	var ok := true
	for i in REF_U.size():
		# GDScript lit les littéraux flottants à 1 ulp près : on compare à 1e-15
		if not proche(r.u(), REF_U[i], 1e-15):
			ok = false
	verifier("Hasard : mulberry32 identique à la V1 (graine 12345)", ok)
	var a := Hasard.new(7)
	var b := Hasard.new(7)
	var memes := true
	var dans := true
	for i in 1000:
		var x := a.u()
		if x != b.u():
			memes = false
		if x < 0.0 or x >= 1.0:
			dans = false
	verifier("Hasard : même graine = même suite, valeurs dans [0, 1[", memes and dans)
	verifier("Format : 1 000 F", Format.montant(1000.0 / F, Dates.ab(1985, 1)) == "1 000 F", Format.montant(1000.0 / F, Dates.ab(1985, 1)))
	verifier("Format : nombre négatif à 2 décimales", Format.nombre(-1234.5, 2) == "−1 234,50", Format.nombre(-1234.5, 2))
	verifier("Format : pourcentage signé", Format.pct(0.0525) == "+5,3 %", Format.pct(0.0525))
	verifier("Dates : octobre 1987", Dates.texte(Dates.lire("1987-10")) == "octobre 1987")
	var a85 := Dates.ab(1985, 1)
	var sp := Format.ESPACE
	verifier("Format : écart signé arrondi au franc", Format.ecart(-102.45 / F, a85) == "−102" + sp + "F" and Format.ecart(1234.6 / F, a85) == "+1" + sp + "235" + sp + "F" and Format.ecart(0.2 / F, a85) == "0" + sp + "F",
		"%s ; %s ; %s" % [Format.ecart(-102.45 / F, a85), Format.ecart(1234.6 / F, a85), Format.ecart(0.2 / F, a85)])


func _tests_marche() -> void:
	Marche.vider_cache()
	var mk := Marche.pour_periode("P1")
	var ok := true
	var detail := ""
	for y in range(1977, 1993):
		var v := mk.indice[Dates.ab(y, 12) - mk.ab0]
		var c := float(Donnees.series()["annuel"][str(y)][0])
		if not proche(v, c, 1e-9):
			ok = false
			detail += "%d : %f au lieu de %f ; " % [y, v, c]
	verifier("CA-10 : l'indice passe par les 16 clôtures annuelles", ok, detail)
	var m_krach := Dates.lire("1987-10") - mk.ab_debut
	var chute := mk.valeur_indice(m_krach) / mk.valeur_indice(m_krach - 1) - 1.0
	verifier("Krach : 1 310 fin sept. 1987 -> 1 033 fin oct. 1987", proche(mk.valeur_indice(m_krach), 1033.0) and proche(mk.valeur_indice(m_krach - 1), 1310.0), Format.pct(chute))
	var ok_ref := true
	for i in REF_CASES.size():
		var k: int = REF_CASES[i]
		if not proche(mk.indice[k], REF_INDICE[i], 1e-9) or not proche(mk.prix["sicav"][k], REF_SICAV[i], 1e-9) or not proche(mk.prix["peugeot"][k], REF_PEUGEOT[i], 1e-9):
			ok_ref = false
	verifier("Portage : indice, SICAV et Peugeot identiques à la V1 web (8 dates)", ok_ref)
	var avant := mk.indice.duplicate()
	var sicav_avant: PackedFloat64Array = mk.prix["sicav"].duplicate()
	Marche.vider_cache()
	var mk2 := Marche.pour_periode("P1")
	verifier("CA-11 : deux générations donnent des cours identiques", avant == mk2.indice and sicav_avant == mk2.prix["sicav"])
	var elf_fin: float = mk2.prix["elf"][180] * F
	var loreal_fin: float = mk2.prix["loreal"][180] * F
	verifier("Données corrigées par le boursier : Elf 360 F et L'Oréal 1 020 F fin 1992", proche(elf_fin, 360.0, 1e-6) and proche(loreal_fin, 1020.0, 1e-6))
	verifier("Saint-Gobain indisponible avant l'offre de nov. 1986, 310 F en nov. et déc. 1986", is_nan(mk2.cours("saintgobain", Dates.lire("1986-10") - mk2.ab_debut))
		and proche(mk2.cours("saintgobain", Dates.lire("1986-11") - mk2.ab_debut) * F, 310.0) and proche(mk2.cours("saintgobain", Dates.lire("1986-12") - mk2.ab_debut) * F, 310.0))
	# VL de la SICAV : formule de 03 §7.3 sur un mois
	var r: float = mk2.prix["sicav"][1] / mk2.prix["sicav"][0]
	var attendu := mk2.indice[1] / mk2.indice[0] * (1.0 + 0.05 / 12.0) * (1.0 - 0.015 / 12.0)
	verifier("SICAV : VL(m) = VL(m-1) × I(m)/I(m-1) × (1 + d/12) × (1 − 1,5 %/12)", proche(r, attendu, 1e-12) and proche(mk2.prix["sicav"][0] * F, 1000.0))
	verifier("Nom de l'indice : CAC 40 à partir de juin 1988 seulement",
		mk2.nom_indice(Dates.lire("1988-05")) == "Indice de la Bourse de Paris" and mk2.nom_indice(Dates.lire("1988-06")) == "CAC 40")
	verifier("IPC et baguette identiques à la V1 (juin 1985)", proche(Marche.ipc(Dates.ab(1985, 6)), 48.45473579855285, 1e-9) and proche(Marche.baguette(Dates.ab(1985, 6)), 0.4032276505929517, 1e-9))
	verifier("Livret A : 6,5 % en 1978, 8,5 % en 1982, 4,5 % en 1987", Marche.taux_livret(Dates.ab(1978, 1)) == 6.5 and Marche.taux_livret(Dates.ab(1982, 6)) == 8.5 and Marche.taux_livret(Dates.ab(1987, 1)) == 4.5)
	verifier("CA-16 : frais de 50 F sur 1 000 F et de 130 F sur 10 000 F en 1985",
		proche(Marche.frais_courtage(Dates.ab(1985, 6), 1000.0 / F) * F, 50.0, 1e-4) and proche(Marche.frais_courtage(Dates.ab(1985, 6), 10000.0 / F) * F, 130.0, 1e-9))


func _tests_salaire_et_livret() -> void:
	var e := EtatPartie.new()
	e.demarrer({"profil": "jeune", "sans_vie": true})
	var attendu := 1300.0 * pow(2200.0 / 1300.0, 3.0 / 5.0)
	verifier("Salaire du jeune salarié en janv. 1978 (interpolation géométrique)", proche(e.salaire_base * F, attendu, 1e-9), "%.2f F" % (e.salaire_base * F))
	var dep := e.depenses()
	verifier("Dépenses 1978 : loyer 17 % (1970-79 : 14 % + 3 pts) et épargne 10 %", proche(dep["loyer"], e.salaire_base * 0.17) and proche(e.epargne_du_mois(), e.salaire_base * 0.10))
	var s0 := e.salaire_base
	for i in 12:
		e.avancer()
	verifier("Indexation en janvier 1979 : × SMN(1979) / SMN(1978)", proche(e.salaire_base, s0 * e.smn(1979) / e.smn(1978), 1e-12))

	# CA-13 : plafond du livret (38 000 F en janvier 1978)
	var e2 := EtatPartie.new()
	e2.demarrer({"sans_vie": true})
	e2.joueur.cc = 100000.0 / F
	var r1 := e2.deposer_livret(e2.joueur, 38000.0 / F)
	var r2 := e2.deposer_livret(e2.joueur, 1000.0 / F)
	verifier("CA-13 : dépôt au-delà du plafond daté refusé", r1["ok"] and not r2["ok"] and r2.get("refus", "") == "plafond", r2.get("msg", ""))

	# CA-14 : 10 000 F déposés le 1er janvier 1982 valent 10 850 F au 31 décembre 1982
	var e3 := EtatPartie.new()
	e3.demarrer({"sans_vie": true})
	while e3.ab_courant() < Dates.ab(1982, 1):
		e3.avancer()
	e3.joueur.livret = 0.0
	e3.joueur.livret_int = 0.0
	e3.joueur.cc += 10000.0 / F
	e3.deposer_livret(e3.joueur, 10000.0 / F)
	while e3.ab_courant() < Dates.ab(1983, 1):
		e3.avancer()
	verifier("CA-14 : Livret A 10 000 F -> 10 850 F en 1982", proche(e3.joueur.livret * F, 10850.0, 1e-9), "%.2f F" % (e3.joueur.livret * F))


func _tests_sicav_et_fiscalite() -> void:
	var e := EtatPartie.new()
	e.demarrer({"sans_vie": true})
	e.joueur.cc = 2000.0 / F
	var d := e.acheter(e.joueur, "sicav", 1000.0 / F)
	verifier("SICAV : 2 % de frais d'entrée (1 000 F -> 980 F investis)", d["ok"] and proche(d["frais"] * F, 20.0) and proche(e.valeur_ligne(e.joueur, "sicav") * F, 980.0), "%.2f F de frais" % (d["frais"] * F))
	verifier("SICAV : le compte courant est débité de 1 000 F", proche(e.joueur.cc * F, 1000.0))
	# Avance jusqu'en décembre 1986 (forte hausse) puis vend tout
	while e.ab_courant() < Dates.ab(1986, 12):
		e.avancer()
	var dv := e.devis_vente(e.joueur, "sicav", 0.0, true)
	var pv_attendue: float = dv["brut"] - 1000.0 / F
	verifier("Vente SICAV : sans frais, plus-value = vente − coût (frais d'achat inclus)", dv["ok"] and dv["frais"] == 0.0 and proche(dv["pv"], pv_attendue), "PV %s" % Format.montant(dv["pv"], e.ab_courant()))
	verifier("Fiscalité : plus-value taxée à 16 % sur compte-titres en 1986", dv["taux"] == 16.0 and proche(dv["impot"], pv_attendue * 0.16) and proche(dv["recu"], dv["brut"] - dv["impot"]))
	var cc_avant := e.joueur.cc
	e.vendre(e.joueur, "sicav", 0.0, true)
	verifier("Vente totale : ligne soldée, argent reçu sur le compte courant", not e.joueur.lignes.has("sicav") and proche(e.joueur.cc - cc_avant, dv["recu"]))
	# Moins-value : pas d'impôt
	var e2 := EtatPartie.new()
	e2.demarrer({"sans_vie": true})
	while e2.ab_courant() < Dates.ab(1987, 9):
		e2.avancer()
	e2.joueur.cc = 5000.0 / F
	e2.acheter(e2.joueur, "sicav", 5000.0 / F)
	e2.avancer()
	if not e2.modale.is_empty():
		e2.resolution_auto()
	var dv2 := e2.devis_vente(e2.joueur, "sicav", 0.0, true)
	verifier("Moins-value après le krach : aucun impôt", dv2["pv"] < 0.0 and dv2["impot"] == 0.0, "PV %s" % Format.montant(dv2["pv"], e2.ab_courant()))


func _tests_partie_complete() -> void:
	# Joueur passif, sans événements de vie, 3 profils : ordre des témoins (CA-20) et invariants (CA-19)
	for profil in ["jeune", "cadre", "heritier"]:
		var j := jouer({"profil": profil, "sans_vie": true})
		var e: EtatPartie = j["etat"]
		var b := Bilan.calculer(e)
		var auj: Dictionary = b["auj"]
		verifier("CA-20 (%s) : Cousin Indice > Tata Livret > Tonton Matelas" % profil, auj["indice"] > auj["livret"] and auj["livret"] > auj["matelas"],
			"Cousin %s, Tata %s, Tonton %s (en € d'aujourd'hui)" % [Format.nombre(auj["indice"]), Format.nombre(auj["livret"]), Format.nombre(auj["matelas"])])
	# Partie complète avec événements de vie, joueur actif
	var plafond_depasse := [false]
	var strat := func(e: EtatPartie, _res: Dictionary) -> void:
		var l: Portefeuille = e.temoins["livret"]
		if l.livret > Marche.plafond_livret(e.ab_courant()) + l.interets_total + 0.01:
			plafond_depasse[0] = true
		# Le joueur met 30 % de son compte en SICAV et 30 % sur le livret chaque mois
		if e.joueur.cc > 100.0 and e.modale.is_empty():
			e.acheter(e.joueur, "sicav", e.joueur.cc * 0.3)
			e.deposer_livret(e.joueur, minf(e.joueur.cc * 0.3, e.place_livret(e.joueur)))
	var j := jouer({"profil": "jeune", "graine_vie": 2024}, strat)
	var e: EtatPartie = j["etat"]
	verifier("Partie P1 complète : 180 mois, fin normale", e.fin == "fin" and e.m == 179, "fin = %s, m = %d" % [e.fin, e.m])
	var matelas: Portefeuille = e.temoins["matelas"]
	verifier("CA-19 : Tonton Matelas = somme exacte des épargnes nettes", proche(matelas.cc, e.epargne_nette, 1e-9) and e.patrimoine(matelas) == matelas.cc,
		"%s" % Format.montant(matelas.cc, e.ab_courant()))
	verifier("CA-19 : Tata Livret ne dépose jamais au-delà du plafond", not plafond_depasse[0])
	var nb_marche := 0
	var m_marche := -1
	var source_marche := ""
	var sources_vie_ok := true
	for c in j["modales"]:
		if c["kind"] == "marche":
			nb_marche += 1
			m_marche = c["m"]
			source_marche = c["source"]
		elif c["source"] != "maison":
			sources_vie_ok = false
	verifier("Krach : une seule modale de marché, en octobre 1987, source « media »",
		nb_marche == 1 and m_marche == Dates.lire("1987-10") - e.mk.ab_debut and source_marche == "media")
	verifier("Courriers de vie : source « maison »", sources_vie_ok)
	var b := Bilan.calculer(e)
	verifier("Mini-bilan : 4 patrimoines classés, réplique et leçon du krach", b["classement"].size() == 4 and b["replique"]["texte"] != "" and b["lecons"].size() == 1,
		"vous %s ; Cousin %s ; Tata %s ; Tonton %s ; %d étoile(s)" % [Format.montant(b["nominal"]["vous"], b["a"]), Format.montant(b["nominal"]["indice"], b["a"]),
			Format.montant(b["nominal"]["livret"], b["a"]), Format.montant(b["nominal"]["matelas"], b["a"]), b["nb_etoiles"]])
	var hist_ok := true
	for k in ["j", "matelas", "livret", "indice"]:
		if hist_ok and e.hist[k][179] <= 0.0:
			hist_ok = false
	verifier("Historique mensuel rempli pour les 4 courbes", hist_ok and proche(e.hist["j"][179], e.patrimoine(e.joueur)))
	var sources_ok := true
	for n in j["notifs"]:
		if not n.get("source", "") in ["maison", "banque", "media"]:
			sources_ok = false
	verifier("Chaque notification porte une source (maison | banque | media)", sources_ok and j["notifs"].size() > 10, "%d notifications" % j["notifs"].size())


func _tests_calendrier_et_evenements() -> void:
	var cal_txt := func(e: EtatPartie) -> String:
		var s := ""
		for ev in e.calendrier:
			s += "%d:%s:%.6f:%.2f|" % [ev["m"], ev["type"], ev["M"], ev.get("montant", 0.0)]
		return s
	var passif := jouer({"graine_vie": 31337})
	var acheteur := func(e: EtatPartie, _r: Dictionary) -> void:
		if e.joueur.cc > 200.0:
			e.acheter(e.joueur, "sicav", e.joueur.cc * 0.5)
	var actif := jouer({"graine_vie": 31337}, acheteur)
	var ca: String = cal_txt.call(passif["etat"])
	var cb: String = cal_txt.call(actif["etat"])
	verifier("CA-12 : même graine de vie = même calendrier (dates et montants), quels que soient les choix", ca == cb and passif["etat"].calendrier.size() >= 10,   # 10 et non 12 depuis l'écart de 24 mois entre deux événements identiques
		"%d événements de vie" % passif["etat"].calendrier.size())
	var autre := jouer({"graine_vie": 4242})
	verifier("Graines différentes = calendriers différents", cal_txt.call(autre["etat"]) != ca)
	var e: EtatPartie = passif["etat"]
	var m_krach := Dates.lire("1987-10") - e.mk.ab_debut
	var voiture := false
	var premier_mois_calme := true
	for ev in e.calendrier:
		if ev.get("force", false) and ev["type"] == "voiture" and ev["m"] == m_krach + 1:
			voiture = true
		if ev["m"] == 0:
			premier_mois_calme = false
	verifier("Coïncidence forcée : panne de voiture en novembre 1987 ; rien au 1er mois", voiture and premier_mois_calme)
	var notif_vie := 0
	var courrier_vie := 0
	for n in passif["notifs"]:
		if n["type"] == "vie":
			notif_vie += 1
	for c in passif["modales"]:
		if c["kind"] == "vie":
			courrier_vie += 1
	verifier("Événements de vie : en notification (petits montants) ou en courrier, tous résolus",
		notif_vie + courrier_vie == e.calendrier.size() and notif_vie > 0, "%d notifications, %d courriers" % [notif_vie, courrier_vie])
	var rappel := false
	for n in passif["notifs"]:
		if n["type"] == "rappel" and str(n["texte"]).contains("Octobre 1988") and str(n["texte"]).contains("le CAC 40"):
			rappel = true
	verifier("Rappel à 12 mois en octobre 1988, avec la variation du CAC 40", rappel)

	# Choix du krach : Tout vendre = panique ; Renforcer = formulaire d'achat prérempli
	var e2 := EtatPartie.new()
	e2.demarrer({"sans_vie": true, "debut": "1987-06"})
	e2.joueur.cc = 20000.0 / F
	e2.acheter(e2.joueur, "sicav", 10000.0 / F)
	while e2.modale.is_empty() and e2.fin == "":
		e2.avancer()
	var c := e2.contenu_modale()
	var ids := []
	for ch in c["choix"]:
		ids.append(ch["id"])
	verifier("Modale du krach : manchette, date, impact négatif, 3 choix", c["titre"].begins_with("Lundi noir") and c["date"] == "OCTOBRE 1987" and c["impact"]["pct"] < -0.15 and ids == ["vendre", "rien", "renforcer"],
		"impact %s" % Format.pct(c["impact"]["pct"]))
	var imp: Dictionary = c["impact"]
	var patr_avant := e2.patrimoine(e2.joueur) - float(imp["diff"])
	verifier("Impact du krach sur le patrimoine total : moindre que sur la bourse, même montant",
		float(imp["pct_patrimoine"]) < 0.0 and float(imp["pct_patrimoine"]) > float(imp["pct"]) and proche(float(imp["pct_patrimoine"]) * patr_avant, float(imp["diff"]), 1e-6),
		"bourse %s, patrimoine %s" % [Format.pct(imp["pct"]), Format.pct(imp["pct_patrimoine"])])
	var e3 := EtatPartie.new()
	e3.demarrer({"sans_vie": true, "debut": "1987-06"})
	e3.joueur.cc = 20000.0 / F
	e3.acheter(e3.joueur, "sicav", 10000.0 / F)
	while e3.modale.is_empty():
		e3.avancer()
	var r := e3.resoudre_modale("vendre")
	verifier("« Tout vendre » : SICAV vendue, panique comptée (étoile sang-froid perdue)", r.has("vente") and e3.joueur.lignes.is_empty() and e3.stats["paniques"].size() == 1)
	var r2 := e2.resoudre_modale("renforcer")
	verifier("« Renforcer » : ouvre l'achat de la SICAV prérempli à 25 % du compte", r2.get("ouvrir_achat", "") == "sicav" and proche(r2["montant_suggere"], 0.25 * e2.joueur.cc))
	var vide := EtatPartie.new()
	vide.demarrer({"sans_vie": true, "debut": "1987-09"})
	while vide.modale.is_empty():
		vide.avancer()
	var ids2 := []
	for ch in vide.contenu_modale()["choix"]:
		ids2.append(ch["id"])
	verifier("Krach sans placement : Rester à l'écart / Profiter des soldes", ids2 == ["ecart", "soldes"])


func _tests_faillite_et_tranche() -> void:
	var e := EtatPartie.new()
	e.demarrer({"sans_vie": true})
	for i in 20:
		e.avancer()
	var n := 0
	var res := {}
	while e.fin == "" and n < 5:
		e.joueur.cc = -3.0 * e.salaire_base
		res = e.avancer()
		n += 1
	verifier("CA-18 : faillite après 3 mois au-delà du découvert toléré", e.fin == "faillite" and n == 3 and res["fin"] == "faillite", "%d mois" % n)
	# Tranche sans banquier (ancienne démo) : état de départ garni, Saint-Gobain annoncé par la banque
	var cfg := {"periode": "P1", "profil": "jeune", "graine_vie": 1, "debut": "1986-09", "fin": "1988-12", "cc_depart": 6000.0 / F, "livret_depart": 24000.0 / F}
	var d := jouer(cfg)
	var ed: EtatPartie = d["etat"]
	var nouveau_banque := false
	for nd in d["notifs"]:
		if nd["type"] == "nouveau" and nd["source"] == "banque" and nd.get("produit", "") == "saintgobain":
			nouveau_banque = true
	var courrier_nov := false
	for cm in d["modales"]:
		if cm["kind"] == "vie" and ed.ab_de(cm["m"]) == Dates.lire("1987-11"):
			courrier_nov = true
	verifier("Tranche sans banquier : départ garni (Tonton = épargne), Saint-Gobain annoncé par la banque, courrier en nov. 1987",
		proche(ed.temoins["matelas"].cc, ed.epargne_nette, 1e-9) and nouveau_banque and courrier_nov and ed.fin == "fin",
		"patrimoine final %s" % Format.montant(ed.patrimoine(ed.joueur), ed.ab_courant()))
	var t := jouer({"graine_vie": 5, "debut": "1986-01", "fin": "1988-12"})
	var et: EtatPartie = t["etat"]
	verifier("Tranche 1986-1988 : démarre en janv. 1986, finit en déc. 1988", et.fin == "fin" and et.ab_courant() == Dates.ab(1988, 12) and et.m_depart == 96)
	var hors_tranche := false
	for ev in et.calendrier:
		if ev["m"] <= 96 or ev["m"] > 131:
			hors_tranche = true
	verifier("Tranche : aucun événement de vie hors de la tranche ni au premier mois", not hors_tranche and et.calendrier.size() > 0)


func _config_demo() -> Dictionary:
	return Donnees.config_demo()


## Résout les modales ouvertes (présentations du banquier : « pas maintenant »).
func _resoudre(e: EtatPartie) -> void:
	var garde := 0
	while not e.modale.is_empty() and garde < 5:
		e.resolution_auto()
		garde += 1


## Comparaison « tout au Livret A » (témoin Tata Livret, 03 §7.8) : indicateur du tableau de bord.
func _tests_comparaison_livret() -> void:
	var e := EtatPartie.new()
	e.demarrer(_config_demo())
	verifier("Écart Livret A : nul au premier mois (même capital, même salaire)", absf(e.ecart_livret()) < 1e-6 and absf(e.ecart_livret(e.m)) < 1e-6)
	# Joueur qui imite Tata Livret (tout sur le livret dans la limite du plafond, coups durs payés
	# en puisant dans le livret) : l'écart reste nul tous les mois, événements de vie compris.
	var imite := EtatPartie.new()
	imite.demarrer({"profil": "cadre", "graine_vie": 2024, "cc_depart": 1000.0, "livret_depart": 0.0})
	var avec_naissance := false
	for ev in imite.calendrier:
		if ev["type"] == "naissance":
			avec_naissance = true
	var max_ecart := 0.0
	var garde := 0
	var nb_vie := 0
	while imite.fin == "" and garde < 400:
		if not imite.modale.is_empty():
			var c := imite.contenu_modale()
			var ids := []
			for ch in c["choix"]:
				ids.append(ch["id"])
			nb_vie += 1
			imite.resoudre_modale("vendre" if ids.has("vendre") else str(ids[0]))
		if imite.joueur.cc > 0.0:
			imite.deposer_livret(imite.joueur, minf(imite.joueur.cc, imite.place_livret(imite.joueur)))
		elif imite.joueur.cc < 0.0:
			imite.retirer_livret(imite.joueur, -imite.joueur.cc)
		max_ecart = maxf(max_ecart, absf(imite.ecart_livret()))
		imite.avancer()
		garde += 1
	verifier("Écart Livret A : nul tous les mois pour un joueur qui fait comme Tata Livret (180 mois, événements de vie)",
		imite.fin == "fin" and max_ecart < 0.01 and nb_vie > 5 and avec_naissance and imite.enfants == 1,
		"écart maximal %s, %d courriers dont une naissance" % [Format.montant(max_ecart, imite.ab_courant(), true), nb_vie])
	# Joueur qui laisse tout sur son compte (sans événements de vie) : il perd exactement les intérêts
	var dort := EtatPartie.new()
	dort.demarrer({"sans_vie": true, "cc_depart": 2000.0})
	var g_dort := 0
	while dort.fin == "" and g_dort < 400:
		if not dort.modale.is_empty():
			dort.resolution_auto()
		dort.avancer()
		g_dort += 1
	var tata: Portefeuille = dort.temoins["livret"]
	verifier("Écart Livret A : tout laisser sur le compte coûte exactement les intérêts du livret",
		dort.ecart_livret() < 0.0 and proche(dort.ecart_livret(), dort.joueur.interets_total - tata.interets_total, 1e-9),
		"écart %s" % Format.montant(dort.ecart_livret(), dort.ab_courant()))
	verifier("Écart Livret A : l'historique mensuel donne la même valeur", proche(dort.ecart_livret(dort.m), dort.ecart_livret(), 1e-9))
	# Courrier ouvert (panne de nov. 1987) : l'écart compte déjà la facture, il ne saute pas au paiement
	var cr := EtatPartie.new()
	cr.demarrer(_config_demo())
	while cr.fin == "" and cr.ab_courant() < Dates.lire("1987-11"):
		if not cr.modale.is_empty():
			cr.resolution_auto()
		cr.avancer()
	var ouvert: bool = cr.modale.get("kind", "") == "vie"
	var ecart_ouvert := cr.ecart_livret()
	cr.resolution_auto()
	verifier("Écart Livret A : stable pendant un courrier (la facture en attente est comptée)",
		ouvert and proche(ecart_ouvert, cr.ecart_livret(), 1e-9), "%s puis %s" % [Format.ecart(ecart_ouvert, cr.ab_courant()), Format.ecart(cr.ecart_livret(), cr.ab_courant())])
	# Krach : la modale du journal rappelle l'écart avant et après
	var k := EtatPartie.new()
	k.demarrer({"sans_vie": true, "debut": "1987-06", "cc_depart": 3000.0})
	k.acheter(k.joueur, "sicav", 2500.0)
	while k.modale.is_empty() and k.fin == "":
		k.avancer()
	var ck := k.contenu_modale()
	verifier("Journal du krach : écart Livret A avant (septembre) et après (octobre), en baisse",
		ck.has("ecart_livret") and float(ck["ecart_livret"]) < float(ck["ecart_livret_avant"]) and float(ck["ecart_livret"]) < 0.0 and ck["ab_avant"] == Dates.lire("1987-09"),
		"%s → %s" % [Format.montant(ck["ecart_livret_avant"], k.ab_courant()), Format.montant(ck["ecart_livret"], k.ab_courant())])


func _tests_naissance() -> void:
	# Naissance forcée (touche F6) : courrier de la maison, dépenses + 9 % du salaire, rien à payer
	var e := EtatPartie.new()
	e.demarrer(_config_demo())
	_resoudre(e)
	e.avancer()
	_resoudre(e)
	var dep0 := float(e.depenses()["total"])
	var flux0 := e.epargne_du_mois()
	var md := e.forcer_naissance(false)
	var c := e.contenu_modale()
	verifier("Naissance forcée : courrier « maison », 1 enfant, un prénom, un seul bouton",
		not md.is_empty() and c["kind"] == "vie" and c["effet"] == "naissance" and c["source"] == "maison" and c["n"] == 1 and c["prenoms"].size() == 1 and c["choix"].size() == 1,
		"%s · %s" % [c["titre"], c["texte"]])
	verifier("Naissance : dépenses + 9 % du salaire, reste du mois diminué d'autant",
		e.enfants == 1 and proche(float(e.depenses()["total"]) - dep0, 0.09 * e.salaire_base, 1e-9) and proche(flux0 - e.epargne_du_mois(), 0.09 * e.salaire_base, 1e-9)
		and proche(float(c["cout_mensuel"]), 0.09 * e.salaire_base, 1e-9))
	var cc0 := e.joueur.cc
	e.resoudre_modale("ok")
	var tonton0: float = e.temoins["matelas"].cc
	e.avancer()
	_resoudre(e)
	verifier("Naissance : rien à payer tout de suite ; le mois suivant, le joueur et les témoins épargnent moins (même vie)",
		proche(e.joueur.cc - cc0, flux0 - 0.09 * e.salaire_base, 1e-6) and proche(e.temoins["matelas"].cc - tonton0, flux0 - 0.09 * e.salaire_base, 1e-6)
		and proche(e.temoins["matelas"].cc, e.epargne_nette, 1e-9))
	# Jumeaux (touche F7) : deux prénoms différents, coût mensuel par enfant
	var j := EtatPartie.new()
	j.demarrer(_config_demo())
	_resoudre(j)
	j.avancer()
	_resoudre(j)
	var dep_j := float(j.depenses()["total"])
	j.forcer_naissance(true)
	var cj := j.contenu_modale()
	verifier("Jumeaux : 2 enfants, 2 prénoms différents, titre et texte adaptés, dépenses + 2 × 9 %",
		j.enfants == 2 and cj["n"] == 2 and cj["prenoms"][0] != cj["prenoms"][1] and cj["titre"] == "Des jumeaux !" and str(cj["texte"]).contains(" et ")
		and proche(float(j.depenses()["total"]) - dep_j, 0.18 * j.salaire_base, 1e-9),
		"%s · %s" % [cj["titre"], cj["texte"]])
	# Tirage : jamais avant 25 ans, 2 enfants au plus, environ 1,5 % de jumeaux
	var t := EtatPartie.new()
	t.demarrer({"profil": "cadre", "sans_vie": true})
	t.sans_vie = false
	t.vie = Donnees.vie().duplicate(true)
	t.vie["naissance"]["freq"] = 1.0
	t.vie["naissance"]["budget_positif_requis"] = false
	var naissances := 0
	var jumeaux := 0
	var trop_jeune := false
	var trop := false
	var age0 := int(t.sal["profils"]["cadre"]["age"])
	for g in 4000:
		t.graine_vie = g + 1
		var enf := 0
		var premiere := true
		for ev in t._tirer_naissances([]):
			enf += int(ev["n"])
			if age0 + floori(float(ev["m"]) / 12.0) < 25:
				trop_jeune = true
			if premiere:
				naissances += 1
				if int(ev["n"]) == 2:
					jumeaux += 1
				premiere = false
		if enf > 2:
			trop = true
	var part := float(jumeaux) / naissances
	verifier("Tirage des naissances : jamais avant 25 ans, 2 enfants au plus, ≈ 1,5 % de jumeaux",
		not trop_jeune and not trop and part > 0.008 and part < 0.024, "%d jumeaux sur %d premières naissances (%s)" % [jumeaux, naissances, Format.pct(part, 2)])
	# Profil « jeune » des années 1980 (8 % d'épargne) : une naissance rendrait le budget négatif, pas de tirage
	var jeune := EtatPartie.new()
	jeune.demarrer({"profil": "jeune", "sans_vie": true, "debut": "1984-01"})
	jeune.sans_vie = false
	jeune.vie = Donnees.vie().duplicate(true)
	jeune.vie["naissance"]["freq"] = 1.0
	verifier("Tirage des naissances : aucune si le budget du mois deviendrait négatif (décision 05 de la V1)", jeune._tirer_naissances([]).is_empty())
