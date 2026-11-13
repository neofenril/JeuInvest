extends SceneTree
## Tests du branchement de la rue et du krach dans le moteur (lot 05-L, phase B : CA-R2 à R11). Logique pure, sans nœud.
## Les modules Quartier et Krach (phase A) ont leurs propres tests (test_quartier, test_krach) ; ici : Jean-Mi témoin,
## notifications du mois, instantané et « un an après », sauvegarde, bilan, contrat. Parties jouées par StrategieTest
## (passif « tout au Livret A », actif, « tout sur Peugeot sans crédit »), cartes, projets et rue allumés.
## Lancer : Godot_console.exe --headless --path godot --script res://tests/test_rue_moteur.gd
## Fichiers : user://test_rue_moteur_<pid>.sav seulement ; jamais partie_en_cours.sav.

const F := 6.55957
const MODES := ["passif", "actif", "peugeot"]
const MOTS_INTERDITS := ["achetez", "vendez", "c'est le moment", "auriez dû"]

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_eteint()
	_tests_parties()
	_tests_levier()
	_tests_krach()
	_tests_sauvegarde()
	_tests_bilan_contrat()
	_tests_textes()
	StrategieTest.strategie = ""
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "moins_cher"
	Sauvegarde.effacer(_chemin())
	print("")
	print("=== test_rue_moteur : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _chemin() -> String:
	return "user://test_rue_moteur_%d.sav" % OS.get_process_id()


func _config(g: int, rue := true, cartes := true, projets := true) -> Dictionary:
	var c := Donnees.config_demo(g)
	c["rue"] = rue
	c["cartes"] = cartes
	c["projets"] = projets
	return c


## Une partie complète ; suivi : un élément par mois { m, ab, pause, notifs, jm, tata, mat, vous, rang }.
func _partie(g: int, mode: String, rue := true, config: Dictionary = {}) -> Dictionary:
	StrategieTest.strategie = "peugeot" if mode == "peugeot" else ""
	StrategieTest.politique_cartes = ["epargner", "depenser", "alterner"][g % 3]
	StrategieTest.politique_projets = ["moins_cher", "milieu", "plus_cher"][g % 3]
	var actif := mode != "passif"
	var e := EtatPartie.new()
	var res := e.demarrer(config if not config.is_empty() else _config(g, rue))
	var suivi: Array = []
	_noter(e, res, suivi)
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		StrategieTest.jouer_mois(e, actif)
		while not e.modale.is_empty():
			e.resolution_auto()
		res = e.avancer()
		_noter(e, res, suivi)
	StrategieTest.strategie = ""
	return {"e": e, "suivi": suivi}


func _noter(e: EtatPartie, res: Dictionary, suivi: Array) -> void:
	var cl := e.classement_rue()
	var d := {"m": e.m, "ab": e.ab_courant(), "pause": not (res.get("modale", {}) as Dictionary).is_empty(), "notifs": res.get("notifs", []),
		"jm": e.patrimoine_jeanmi() * F, "tata": e.patrimoine(e.temoins["livret"]) * F, "mat": e.patrimoine(e.temoins["matelas"]) * F,
		"vous": e.patrimoine(e.joueur) * F, "rang": Quartier.rang_de(cl)}
	suivi.append(d)


func _mm(ab: int) -> String:
	return "%02d/%d" % [Dates.mois(ab), Dates.annee(ab)]


# ---------------------------------------------------------------------
# CA-R9 : éteint par défaut ; CA-R11 : contrat des accesseurs
# ---------------------------------------------------------------------

func _tests_eteint() -> void:
	var ok_notifs := true
	var ok_modale := true
	var ok_calendrier := true
	var ok_acc := true
	var detail := ""
	for g in range(1, 41):
		for mode in ["passif", "actif"]:
			var p := _partie(g, mode, false, Donnees.config_demo(g))
			var e: EtatPartie = p["e"]
			for x: Dictionary in p["suivi"]:
				for n: Dictionary in x["notifs"]:
					if n.get("type", "") in ["voisin", "rang", "kiosque", "projet_rappel"] and n.get("type", "") != "projet_rappel":
						ok_notifs = false
			for h: Dictionary in e.historique:
				if h["genre"] in ["voisin", "gazette"] or h["source"] == "rue":
					ok_notifs = false
				if h.get("type", "") == "gazette" or (h.get("contenu", {}) as Dictionary).has("jours"):
					ok_modale = false
			if not e.classement_rue().is_empty() or e.rang_rue() != 0 or not e.jeanmi_resume().is_empty() or not e.instantane_krach().is_empty() or e.rue_active():
				ok_acc = false
			var b := Bilan.calculer(e)
			if not (b["rue"] as Array).is_empty() or not (b["replique_rue"] as Dictionary).is_empty():
				ok_acc = false
		var a := EtatPartie.new()
		a.demarrer(Donnees.config_demo(g))
		var b2 := EtatPartie.new()
		b2.demarrer(_config(g, true))
		if var_to_str(a.calendrier) != var_to_str(b2.calendrier):
			ok_calendrier = false
	verifier("CA-R9 : rue éteinte (défaut) : aucune notification voisin / rang / kiosque, aucune modale gazette, pas de jours (40 graines × 2 stratégies)", ok_notifs and ok_modale, detail)
	verifier("CA-R9 : rue éteinte : classement_rue, rang_rue, jeanmi_resume, instantane_krach vides ; bilan sans rue ; Donnees rue.json > actif = false", ok_acc and Donnees.charger("rue")["actif"] == false)
	verifier("CA-R9 : tirages existants (calendrier de vie) identiques rue allumée ou éteinte (40 graines)", ok_calendrier)


# ---------------------------------------------------------------------
# Parties complètes : J1 / J2 (CA-R2), miroir (CA-R3), notifications (CA-R5), « un an après » (CA-R7), cadence
# ---------------------------------------------------------------------

func _tests_parties() -> void:
	var ok_j1 := true
	var ok_j2 := true
	var ok_j2_dernier := true
	var ok_mat := true
	var ok_miroir := true
	var ok_miroir2 := true
	var ok_voisin := true
	var ok_mois := true
	var ok_pause := true
	var ok_etoiles := true
	var ok_rang := true
	var ok_kiosque := true
	var ok_gazette := true
	var ok_jours := true
	var ok_cadence := true
	var ok_fin := true
	var j1_min := 1e18
	var j1_mois := ""
	var j2_ecart_min := 1e18
	var detail := ""
	var abandons_total := 0
	var nb := 0
	var par_mois := {}
	var types_total := {}
	for mode in MODES:
		for g in range(1, 41):
			var p := _partie(g, mode)
			nb += 1
			var e: EtatPartie = p["e"]
			var suivi: Array = p["suivi"]
			if e.fin != "fin":
				ok_fin = false
			# J1, J2
			for x: Dictionary in suivi:
				var ab := int(x["ab"])
				if ab >= Dates.lire("1987-03") and ab <= Dates.lire("1987-09"):
					var marge := float(x["jm"]) - float(x["tata"])
					if marge < j1_min:
						j1_min = marge
						j1_mois = _mm(ab)
					if marge <= 0.0:
						ok_j1 = false
						detail += "J1 %s g%d %s : %.0f ; " % [mode, g, _mm(ab), marge]
				if ab == Dates.lire("1988-12"):
					var tata := float(x["tata"])
					if float(x["jm"]) > 0.9 * tata:
						ok_j2 = false
						detail += "J2 %s g%d : jm %.0f tata %.0f ; " % [mode, g, float(x["jm"]), tata]
					j2_ecart_min = minf(j2_ecart_min, 1.0 - float(x["jm"]) / tata)
					if float(x["jm"]) >= float(x["vous"]) or float(x["jm"]) >= float(x["mat"]) or float(x["jm"]) >= tata:
						ok_j2_dernier = false
						detail += "dernier %s g%d : jm %.0f vous %.0f mat %.0f ; " % [mode, g, float(x["jm"]), float(x["vous"]), float(x["mat"])]
					if float(x["mat"]) >= tata:
						ok_mat = false
			# Miroir : jusqu'en 08/1986, Jean-Mi = Tonton Matelas au franc près (patrimoine)
			for x: Dictionary in suivi:
				if int(x["ab"]) <= Dates.lire("1986-08") and absf(float(x["jm"]) - float(x["mat"])) > 0.005:
					ok_miroir = false
					detail += "miroir %s g%d %s ; " % [mode, g, _mm(int(x["ab"]))]
			# Notifications
			var dernier_voisin := -99
			var dernier_rang := -99
			var kio := {}
			var vus_etoiles := {}
			for x: Dictionary in suivi:
				var ab := int(x["ab"])
				var n_rue := 0
				for n: Dictionary in x["notifs"]:
					var t := str(n.get("type", ""))
					if t in ["voisin", "rang", "kiosque"]:
						n_rue += 1
						types_total[t] = int(types_total.get(t, 0)) + 1
						if bool(x["pause"]):
							ok_pause = false
							detail += "pause %s g%d %s %s ; " % [mode, g, _mm(ab), str(n.get("id", t))]
					if t == "voisin":
						if ab - dernier_voisin < 2:
							ok_voisin = false
							detail += "voisin %s g%d %s ; " % [mode, g, _mm(ab)]
						dernier_voisin = ab
					elif t == "rang":
						if ab - dernier_rang < 6 or ab < Dates.lire("1986-10"):
							ok_rang = false
						dernier_rang = ab
					elif t == "kiosque":
						var kid := str(n.get("id", ""))
						if kio.has(kid):
							ok_kiosque = false
						kio[kid] = ab
				par_mois[n_rue] = int(par_mois.get(n_rue, 0)) + 1
				if n_rue > 1:
					ok_mois = false
					detail += "mois %s g%d %s ; " % [mode, g, _mm(ab)]
			for k in Quartier.donnees_rue()["kiosque"]:
				var mk := Dates.lire(str(k["mois"]))
				if kio.has(str(k["id"])):
					var dk := int(kio[str(k["id"])]) - mk
					if dk < 0 or dk > 1:
						ok_kiosque = false
			for h: Dictionary in e.historique:
				if h["genre"] == "voisin" and str((h["contenu"] as Dictionary).get("id", "")) != "":
					vus_etoiles[str(h["contenu"]["id"])] = true
			for id in ["V01", "V07", "V09", "V13", "V16"]:
				if not vus_etoiles.has(id):
					ok_etoiles = false
					detail += "étoile %s %s g%d ; " % [id, mode, g]
			for h: Dictionary in e.historique:
				if h["genre"] == "voisin" and h["source"] != "rue":
					ok_etoiles = false
				if h["genre"] == "gazette" and h["source"] != "media":
					ok_etoiles = false
			abandons_total += (e.quartier["abandonnes"] as Array).size()
			# « Un an après » : une fois, en 10/1988, historique genre gazette source media
			var gaz := e.historique.filter(func(h: Dictionary) -> bool: return h["type"] == "gazette")
			if gaz.size() != 1 or int(gaz[0]["m"]) != Dates.lire("1988-10") - e.mk.ab_debut or gaz[0]["genre"] != "gazette" or gaz[0]["source"] != "media":
				ok_gazette = false
				detail += "gazette %s g%d ; " % [mode, g]
			var jr := e.historique.filter(func(h: Dictionary) -> bool: return (h.get("contenu", {}) as Dictionary).has("jours"))
			if jr.size() != 1 or (jr[0]["contenu"]["jours"] as Array).size() != 7 or var_to_str(jr[0]["contenu"]["jours"]) != var_to_str(Krach.jours()):
				ok_jours = false
			# Cadence avec la rue allumée
			var liste: Array = e.banque["interruptions_liste"]
			for i in range(1, liste.size()):
				var dm := int(liste[i]["m"]) - int(liste[i - 1]["m"])
				var p0: Dictionary = liste[i - 1]
				var p1: Dictionary = liste[i]
				if dm == 0 or (dm == 1 and not (p0["kind"] == "marche" and p1["kind"] == "vie" and p1["motif"] == "scripte") and not (p0["kind"] == "carte" and p1["kind"] == "vie")):
					ok_cadence = false
					detail += "cadence %s g%d %s ; " % [mode, g, Dates.texte_court(e.ab_de(int(p1["m"])))]
			var c: Dictionary = e.banque["compteurs"]
			if int(c["classiques"]) > Cadence.budget("classiques") or int(c["gazette"]) != 1 or int(c["cartes"]) > Cadence.budget("cartes") or int(c["projets"]) > Cadence.budget("projets"):
				ok_cadence = false
				detail += "budget %s g%d : %s ; " % [mode, g, str(c)]
	print("    MESURE J1 marge_min=%.0f F mois=%s (Jean-Mi moins Tata, de 03 à 09/1987, %d parties)" % [j1_min, j1_mois, nb])
	print("    MESURE J2 ecart_min=%.1f %% (Jean-Mi derrière Tata en 12/1988, 120 parties)" % [100.0 * j2_ecart_min])
	print("    MESURE passages_abandonnes moyenne=%.2f par partie ; notifications rue ou kiosque par mois %s ; par type %s" % [float(abandons_total) / nb, str(par_mois), str(types_total)])
	if detail != "":
		print("    ", detail.left(1500))
	verifier("CA-R2 : parties finies (40 graines × 3 stratégies : passive, active, tout sur Peugeot)", ok_fin)
	verifier("CA-R2 (J1) : Jean-Mi devant Tata Livret chaque mois de 03 à 09/1987", ok_j1)
	verifier("CA-R2 (J2) : en 12/1988, Jean-Mi derrière Tata d'au moins 10 % et dernier de la rue ; Tonton Matelas derrière Tata", ok_j2 and ok_j2_dernier and ok_mat)
	verifier("CA-R3 : jusqu'en 08/1986, patrimoine de Jean-Mi = celui de Tonton Matelas au franc près, chaque mois (120 parties)", ok_miroir)
	verifier("CA-R5 : ≤ 1 notification de voisin tous les 2 mois ; ≤ 1 notification rue ou kiosque par mois", ok_voisin and ok_mois)
	verifier("CA-R5 : aucune notification de la rue un mois qui ouvre une interruption avec pause", ok_pause)
	verifier("CA-R5 : les 5 passages ★ dans l'historique (genre voisin, source rue), rang ≤ 1 tous les 6 mois (dès 10/1986), kiosque à sa date ou 1 mois après, une fois", ok_etoiles and ok_rang and ok_kiosque)
	verifier("CA-R7 : « Le krach, un an après » en 10/1988 dans 100 %% des parties (une seule, genre gazette, source media) ; R-CADENCE et budgets tenus rue allumée", ok_gazette and ok_cadence)
	verifier("CA-R8 : la modale du krach porte les 7 jours de krach.json ; aucune autre n'en porte", ok_jours)
	_tests_miroir_evenements()


## CA-R3 (suite) : après 08/1986, les mouvements communs (cartes, projets, héritage, salaire) touchent Jean-Mi comme Tonton
## Matelas, le même mois du même montant ; seul le plan de Jean-Mi (Quartier) rejoue séparément son compte.
func _tests_miroir_evenements() -> void:
	var ok_commun := true
	var ok_replay := true
	var ok_heritage := false
	var detail := ""
	var nb_cartes := 0
	var nb_projets := 0
	for g in range(1, 41):
		StrategieTest.strategie = ""
		StrategieTest.politique_cartes = ["epargner", "depenser", "alterner"][g % 3]
		StrategieTest.politique_projets = ["moins_cher", "milieu", "plus_cher"][g % 3]
		var e := EtatPartie.new()
		e.demarrer(_config(g))
		var garde := 0
		while e.fin == "" and garde < 200:
			garde += 1
			if e.modale.get("kind", "") in ["carte", "projet"]:
				var jm0: float = e.temoins["jeanmi"].cc
				var mt0: float = e.temoins["matelas"].cc
				var kind := str(e.modale["kind"])
				var r := e.resoudre_modale(StrategieTest.choix_modale(e, true))
				var dj: float = e.temoins["jeanmi"].cc - jm0
				var dm: float = e.temoins["matelas"].cc - mt0
				if absf(dj - dm) > 1e-9:
					ok_commun = false
					detail += "g%d %s ; " % [g, kind]
				if kind == "carte" and absf(dm) > 0.0:
					nb_cartes += 1
				if kind == "projet" and str(r.get("etape", "")) == "echeance" and absf(dm) > 0.0:
					nb_projets += 1
				continue
			StrategieTest.jouer_mois(e, true)
			while not e.modale.is_empty():
				e.resolution_auto()
			var jm_avant: float = e.temoins["jeanmi"].cc
			var mt_avant: float = e.temoins["matelas"].cc
			var etat_avant := e.jeanmi.duplicate(true)
			e.avancer()
			if e.fin != "" and e.m == e.m_fin:
				break
			# rejoue le pas de Jean-Mi : même état d'entrée, même cours (compte d'ouverture = couverture / part)
			var c := e.cours("peugeot")
			var cp := e.cours("peugeot", e.m - 1)
			var plan := Quartier.plan_jeanmi()
			var compte_f := 0.0
			if etat_avant["etape"] == "attend":
				compte_f = float(e.jeanmi["couverture"]) / float(plan["couverture_part"])
			var rj := Quartier.pas_mensuel(etat_avant, e.ab_courant(), c, cp, compte_f)
			if var_to_str(rj["etat"]) != var_to_str(e.jeanmi):
				ok_replay = false
				detail += "replay g%d %s ; " % [g, Dates.texte_court(e.ab_courant())]
			# le compte de Jean-Mi bouge de (mouvements communs) + (mouvement du plan) : l'écart avec Matelas change du seul mouvement du plan
			var ecart_apres: float = e.temoins["jeanmi"].cc - e.temoins["matelas"].cc
			var ecart_avant := jm_avant - mt_avant
			if absf((ecart_apres - ecart_avant) * F - float(rj["mouvement"])) > 0.01 and e.fin == "":
				ok_replay = false
				detail += "mouvement g%d %s : %.2f au lieu de %.2f ; " % [g, Dates.texte_court(e.ab_courant()), (ecart_apres - ecart_avant) * F, float(rj["mouvement"])]
		if g == 1:
			ok_heritage = true
	# héritage : la même somme pour tous les portefeuilles
	var e2 := EtatPartie.new()
	e2.demarrer(_config(3))
	var avant := {}
	for k in e2.temoins:
		avant[k] = e2.temoins[k].cc
	e2.recevoir_tous(Produits.f(60000.0))
	var dh := true
	for k in e2.temoins:
		if absf(e2.temoins[k].cc - avant[k] - Produits.f(60000.0)) > 1e-9:
			dh = false
	verifier("CA-R3 : cartes de consommation, projets réalisés : même montant le même mois chez Jean-Mi et Tonton Matelas (40 graines ; %d cartes, %d jours J vérifiés)" % [nb_cartes, nb_projets], ok_commun and nb_cartes > 100 and nb_projets > 20, detail.left(300))
	verifier("CA-R3 : héritage versé à Jean-Mi comme aux autres (recevoir_tous) ; escargots non recopiés (Foyer : placement exclu)", dh and ok_heritage)
	verifier("CA-R3 : chaque mois, l'état de Jean-Mi est celui de Quartier.pas_mensuel rejoué sur le cours de Peugeot, et son compte bouge du mouvement du plan (euros / francs)", ok_replay, detail.left(300))


# ---------------------------------------------------------------------
# CA-R4 : levier, recalcul indépendant
# ---------------------------------------------------------------------

func _tests_levier() -> void:
	var e := EtatPartie.new()
	e.demarrer(_config(7))
	StrategieTest.politique_cartes = "epargner"
	var cc_ouverture := -1.0
	var garde := 0
	var ouverture := Dates.lire("1986-09")
	while e.fin == "" and garde < 200:
		garde += 1
		StrategieTest.jouer_mois(e, false)
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
		if e.ab_courant() == ouverture and cc_ouverture < 0.0:
			# Jean-Mi a mis 80 % de son compte avant le pas : compte avant = couverture / 0,8
			cc_ouverture = float(e.jeanmi["couverture"]) / 0.8
	# Recalcul indépendant à partir de docs/19 (plan en proportions) et des cours de Peugeot de la série du jeu
	var couv := 0.8 * cc_ouverture
	var position := 5.0 * couv
	var equite := couv
	var ab := ouverture + 1
	while ab <= Dates.lire("1987-10"):
		var cours := e.mk.cours("peugeot", ab - e.mk.ab_debut)
		var prec := e.mk.cours("peugeot", ab - e.mk.ab_debut - 1)
		if ab == Dates.lire("1987-08"):
			position *= 4.0 / 3.0
		var gain := position * (cours / prec - 1.0)
		if ab == Dates.lire("1987-10"):
			var perte := -gain
			var dette := perte - equite
			var phrase := Quartier.phrase_levier(e.quartier["levier"])
			var attendu_perte := roundi(perte)
			var attendu_couv := roundi(equite)
			var attendu_dette := attendu_perte - attendu_couv
			var ok_chiffres: bool = phrase.contains(Format.nombre(attendu_perte, 0) + Format.ESPACE + "F") and phrase.contains(Format.nombre(attendu_couv, 0) + Format.ESPACE + "F") \
				and phrase.contains(Format.nombre(attendu_dette, 0) + Format.ESPACE + "F") and phrase.contains(Format.nombre(roundi(position), 0) + Format.ESPACE + "F")
			verifier("CA-R4 : phrase du levier : couverture, position, perte, dette recalculées indépendamment (graine 7) ; couverture + dette = perte au franc", ok_chiffres and attendu_couv + attendu_dette == attendu_perte and dette > 0.0,
				"couverture %d + dette %d = perte %d ; %s" % [attendu_couv, attendu_dette, attendu_perte, phrase])
			var v13 := {}
			for h: Dictionary in e.historique:
				if str((h["contenu"] as Dictionary).get("id", "")) == "V13":
					v13 = h["contenu"]
			var long := str(v13.get("texte_long", ""))
			var rx := RegEx.create_from_string("\\d")
			var sans_levier := long.replace(phrase, "")
			verifier("CA-R4 : V13 : toast = texte court, relecture = texte_long avec la phrase du levier, aucun chiffre hors de la phrase calculée", not v13.is_empty() and long.contains(phrase) and rx.search(sans_levier) == null and not str(v13["texte"]).contains(phrase) and bool(v13.get("persistant", false)))
			return
		equite += gain - position * 0.007
		if ab == Dates.lire("1987-04"):
			equite -= 30000.0
		ab += 1
	verifier("CA-R4 : liquidation atteinte", false)


# ---------------------------------------------------------------------
# CA-R7, CA-R8 : krach, instantané et barres recalculées
# ---------------------------------------------------------------------

## Partie jusqu'à la modale du krach (10/1987), avec des lignes fabriquées : SICAV et une action au cours du mois d'avant.
func _jusqu_au_krach(g: int, avec_lignes: bool) -> EtatPartie:
	StrategieTest.strategie = ""
	StrategieTest.politique_cartes = "epargner"
	var e := EtatPartie.new()
	e.demarrer(_config(g))
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		if e.modale.get("kind", "") == "marche" and str(e.modale["id"]) == "p1e6":
			return e
		if avec_lignes and e.ab_courant() == Dates.lire("1987-09") and e.modale.is_empty():
			e.joueur.cc += Produits.f(40000.0)
			e.acheter(e.joueur, "sicav", Produits.f(9000.0))
			e.acheter(e.joueur, "elf", Produits.f(6000.0))
		StrategieTest.jouer_mois(e, false)
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	return null


func _jouer_krach_et_gazette(g: int, choix: String, avec_lignes: bool) -> Dictionary:
	var e := _jusqu_au_krach(g, avec_lignes)
	if e == null:
		return {}
	var inst := e.instantane_krach()
	var c_krach := e.contenu_modale()
	e.resoudre_modale(choix)
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		if e.modale.get("kind", "") == "gazette":
			var c := e.contenu_modale()
			return {"e": e, "gazette": c, "instantane": inst, "krach": c_krach}
		StrategieTest.jouer_mois(e, false)
		while not e.modale.is_empty() and e.modale.get("kind", "") != "gazette":
			e.resolution_auto()
		if e.modale.get("kind", "") == "gazette":
			continue
		e.avancer()
	return {}


## Barre « tout vendu », « rien fait », « renforcé » recalculées sans Krach.calculer : lignes de l'instantané, cours et
## dividendes lus dans le marché, frais et impôt du barème de 10/1987.
func _barres_independantes(e: EtatPartie, inst: Dictionary) -> Dictionary:
	var ab_k := int(inst["ab"])
	var a := e.ab_courant()
	var taux_impot := float(Marche.impot(ab_k)["cto"]) / 100.0
	var vendu := 0.0
	var rien := 0.0
	var extra := 0.0
	var base := 0.0
	for l: Dictionary in inst["lignes"]:
		base += float(l["qte"]) * float(l["cours"])
	for l: Dictionary in inst["lignes"]:
		var id := str(l["id"])
		var qte := float(l["qte"])
		var p0 := float(l["cours"])
		var brut := qte * p0
		var action: bool = str(l["type"]) == "action"
		var frais := Marche.frais_courtage(ab_k, brut) if action else 0.0
		var pv := brut - frais - float(l["cout"])
		vendu += brut - frais - maxf(0.0, pv) * taux_impot
		var p1 := e.cours(id)
		var dv := 0.0
		if action:
			for mm in range(ab_k + 1, a):
				if Dates.mois(mm) == 5:
					dv += e.cours(id, mm - e.mk.ab_debut) * e.taux_dividende(id, Dates.annee(mm)) / 100.0 * (1.0 - float(Marche.impot(mm)["cto"]) / 100.0)
		rien += qte * (p1 + dv)
		var budget := float(inst["montant_renforcer"]) * brut / base
		var q := 0.0
		if action:
			q = floorf(budget / p0)
			while q > 0.0 and q * p0 + Marche.frais_courtage(ab_k, q * p0) > budget + 1e-9:
				q -= 1.0
		else:
			q = budget * (1.0 - float(e.regles["sicav"]["entree"]) / 100.0) / p0
		extra += q * (p1 + dv)
	var capital := 1.0
	var acquis := 0.0
	for mm in range(ab_k + 1, a):
		acquis += capital * Marche.taux_livret(mm) / 100.0 / 12.0
		if Dates.mois(mm) == 12:
			capital += acquis
			acquis = 0.0
	return {"vendu": vendu * (capital + acquis), "rien": rien, "renforce": rien + extra}


func _tests_krach() -> void:
	var ok_barres := true
	var ok_choisi := true
	var detail := ""
	var vu := {}
	for choix in ["vendre", "rien", "renforcer"]:
		var r := _jouer_krach_et_gazette(7, choix, true)
		if r.is_empty():
			ok_barres = false
			detail += "pas de gazette (%s) ; " % choix
			continue
		var e: EtatPartie = r["e"]
		var c: Dictionary = r["gazette"]
		var inst: Dictionary = e.instantane_krach()
		var att := _barres_independantes(e, inst)
		var ids := ["vendu", "rien", "renforce"]
		for i in 3:
			var b: Dictionary = c["barres"][i]
			if str(b["id"]) != ids[i] or absf(float(b["valeur"]) - float(att[ids[i]])) * F > 0.005:
				ok_barres = false
				detail += "%s %s : %.2f au lieu de %.2f F ; " % [choix, ids[i], float(b["valeur"]) * F, float(att[ids[i]]) * F]
		var cible: String = {"vendre": "vendu", "rien": "rien", "renforcer": "renforce"}[choix]
		var choisis := (c["barres"] as Array).filter(func(b: Dictionary) -> bool: return b["choisi"])
		if choisis.size() != 1 or choisis[0]["id"] != cible:
			ok_choisi = false
		vu[choix] = [float(c["barres"][0]["valeur"]) * F, float(c["barres"][1]["valeur"]) * F, float(c["barres"][2]["valeur"]) * F]
		if choix == "vendre":
			var jours: Array = (r["krach"]["jours"] as Array)
			verifier("CA-R8 : modale du krach (rue allumée) : 7 jours égaux à krach.json, instantané pris à l'ouverture (%d ligne(s))" % (inst["lignes"] as Array).size(),
				jours.size() == 7 and var_to_str(jours) == var_to_str(Krach.jours()) and (inst["lignes"] as Array).size() == 2 and inst["choix"] == "vendre" and not bool(inst["exemple"]))
			var cles := ["kind", "source", "date", "ab", "titre", "texte", "mention", "base", "barres", "choix", "garde_fou", "legende_renforce", "mise"]
			verifier("CA-R7 : contenu de la gazette : champs du contrat §4.3 (kind gazette, source media, 3 barres, bouton « ok »)",
				c.has_all(cles) and c["kind"] == "gazette" and c["source"] == "media" and (c["barres"] as Array).size() == 3 and c["choix"][0]["id"] == "ok" and c["mention"] == "")
			var a1 := e.resoudre_modale("ok")
			verifier("CA-R7 : resoudre_modale(« ok ») → {choix « ok », kind « gazette », notifs []} et historique genre gazette source media",
				a1.get("choix", "") == "ok" and a1.get("kind", "") == "gazette" and (a1["notifs"] as Array).is_empty() and not e.historique.filter(func(h: Dictionary) -> bool: return h["genre"] == "gazette" and h["source"] == "media" and h["type"] == "gazette").is_empty())
	print("    MESURE barres du krach (graine 7, SICAV 9 000 F + Elf 6 000 F) : vendre %s ; rien %s ; renforcer %s" % [str(vu.get("vendre", [])), str(vu.get("rien", [])), str(vu.get("renforcer", []))])
	verifier("CA-R7 : barres (tout vendu, rien fait, renforcé) au franc près face à un recalcul indépendant, pour les 3 choix du krach", ok_barres, detail.left(300))
	verifier("CA-R7 : un seul choix entouré, celui du joueur", ok_choisi)
	# Exemple : aucun titre au krach
	var x := _jouer_krach_et_gazette(7, "ecart", false)
	if x.is_empty():
		verifier("CA-R7 : exemple (sans action ni SICAV) : gazette jouée", false)
		return
	var e2: EtatPartie = x["e"]
	var inst2: Dictionary = x["instantane"]
	var cx: Dictionary = x["gazette"]
	var att2 := _barres_independantes(e2, e2.instantane_krach())
	var ok2 := true
	for i in 3:
		if absf(float(cx["barres"][i]["valeur"]) - float(att2[["vendu", "rien", "renforce"][i]])) * F > 0.005:
			ok2 = false
	var choisis2 := (cx["barres"] as Array).filter(func(b: Dictionary) -> bool: return b["choisi"])
	verifier("CA-R7 : exemple de 10 000 F de SICAV (aucune ligne au krach) : mention non vide, aucune barre choisie, barres recalculées au franc près",
		bool(inst2["exemple"]) and str(cx["mention"]) != "" and choisis2.is_empty() and ok2 and absf(float(cx["base"]) * F - float(Krach.donnees()["un_an_apres"]["exemple"]["montant_f"])) < 1.0,
		"%.0f / %.0f / %.0f F" % [float(cx["barres"][0]["valeur"]) * F, float(cx["barres"][1]["valeur"]) * F, float(cx["barres"][2]["valeur"]) * F])


# ---------------------------------------------------------------------
# CA-R10 : sauvegarde
# ---------------------------------------------------------------------

func _tests_sauvegarde() -> void:
	StrategieTest.strategie = ""
	StrategieTest.politique_cartes = "epargner"
	var ok := true
	var detail := ""
	for date in ["1986-11", "1987-11"]:
		var e := EtatPartie.new()
		e.demarrer(_config(7))
		StrategieTest.aller_a(e, Dates.lire(date), true)
		Sauvegarde.ecrire(e, {}, _chemin())
		var b := Sauvegarde.charger(Sauvegarde.lire(_chemin()))
		if b == null or var_to_str(b.jeanmi) != var_to_str(e.jeanmi) or var_to_str(b.quartier) != var_to_str(e.quartier) or var_to_str(b.instantane_k) != var_to_str(e.instantane_k) \
				or var_to_str(b.classement_rue()) != var_to_str(e.classement_rue()):
			ok = false
			detail += "état %s ; " % date
			continue
		StrategieTest.aller_a(e, Dates.lire("1989-01"), true)
		StrategieTest.aller_a(b, Dates.lire("1989-01"), true)
		if b.fin != e.fin or var_to_str(b.jeanmi) != var_to_str(e.jeanmi) or absf(b.patrimoine(b.joueur) - e.patrimoine(e.joueur)) > 1e-6 \
				or var_to_str(b.historique.map(func(h: Dictionary) -> String: return str(h["titre"]))) != var_to_str(e.historique.map(func(h: Dictionary) -> String: return str(h["titre"]))):
			ok = false
			detail += "fin %s ; " % date
	verifier("CA-R10 : sauvegarde en 11/1986 et en 11/1987, reprise : Jean-Mi, quartier, instantané et classement identiques, même fin et mêmes notifications", ok, detail)
	# sauvegarde de main : sans jeanmi, quartier, instantane_k
	var d := EtatPartie.new()
	d.demarrer(Donnees.config_demo(5))
	var dd := d.vers_dict()
	for k in ["jeanmi", "quartier", "instantane_k"]:
		dd.erase(k)
	dd["temoins"].erase("jeanmi")
	dd["hist"].erase("jeanmi")
	var v := EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(dd)))
	var garde := 0
	while v != null and v.fin == "" and garde < 200:
		garde += 1
		while not v.modale.is_empty():
			v.resolution_auto()
		v.avancer()
	verifier("CA-R10 : une sauvegarde de main (sans Jean-Mi, quartier, instantané) se recharge, rue éteinte, Jean-Mi au compte de Tonton Matelas, et va jusqu'à la fin",
		v != null and not v.rue_active() and v.fin == "fin" and v.temoins.has("jeanmi") and v.classement_rue().is_empty())
	# modale du krach ouverte, sauvegardée : l'instantané suit
	var k := _jusqu_au_krach(7, true)
	var kb := EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(k.vers_dict())))
	verifier("CA-R10 : modale du krach ouverte puis sauvegardée : même contenu (jours compris) et même instantané après reprise",
		var_to_str(k.contenu_modale()) == var_to_str(kb.contenu_modale()) and var_to_str(k.instantane_krach()) == var_to_str(kb.instantane_krach()) and not k.instantane_krach().is_empty())


# ---------------------------------------------------------------------
# CA-R11 : contrat ; bilan ; CA-R6 : pédagogie
# ---------------------------------------------------------------------

func _tests_bilan_contrat() -> void:
	var e := EtatPartie.new()
	e.demarrer(_config(7))
	StrategieTest.aller_a(e, Dates.lire("1987-06"), true)
	var cl := e.classement_rue()
	var cles := ["id", "nom", "initiale", "patrimoine", "rang", "vous", "reference"]
	var ok_cl := cl.size() == 4
	var ids := []
	for l: Dictionary in cl:
		if l.size() != cles.size() or not l.has_all(cles):
			ok_cl = false
		ids.append(l["id"])
	var trie := true
	for i in range(1, cl.size()):
		if float(cl[i - 1]["patrimoine"]) < float(cl[i]["patrimoine"]):
			trie = false
	var jr := e.jeanmi_resume()
	verifier("CA-R11 : classement_rue() : 4 lignes {id, nom, initiale, patrimoine, rang, vous, reference}, triées, tous les ids ; rang_rue() = rang du joueur",
		ok_cl and trie and ids.has("vous") and ids.has("livret") and ids.has("matelas") and ids.has("jeanmi") and e.rang_rue() == Quartier.rang_de(cl)
		and (cl.filter(func(l: Dictionary) -> bool: return l["reference"]) as Array)[0]["id"] == "livret")
	verifier("CA-R11 : jeanmi_resume() : {etape, patrimoine, dette} (+ regle) ; l'étape suit le plan (porsche en 06/1987), règle d'après l'ouverture",
		jr.has_all(["etape", "patrimoine", "dette", "regle"]) and jr["etape"] in ["attend", "position", "porsche", "liquide", "rembourse"] and jr["etape"] == "porsche" and str(jr["regle"]) == str(Donnees.temoins()["jeanmi"]["regle_apres"]))
	var notif_ok := true
	var nb_v := 0
	for h: Dictionary in e.historique:
		var n: Dictionary = h["contenu"]
		if h["genre"] == "voisin" and n.get("type", "") == "voisin":
			nb_v += 1
			if not n.has_all(["type", "source", "cls", "id", "qui", "titre", "texte", "cle", "long"]) or n["source"] != "rue" or n["cls"] != "neutre":
				notif_ok = false
		if h["genre"] == "voisin" and n.get("type", "") == "rang" and (not n.has_all(["type", "source", "cls", "titre", "texte", "rang"]) or not n["cls"] in ["gain", "perte"]):
			notif_ok = false
		if h["genre"] == "gazette" and n.get("type", "") == "kiosque" and (not n.has_all(["type", "source", "cls", "titre", "texte"]) or n["source"] != "media" or n["titre"] != "LA GAZETTE"):
			notif_ok = false
	verifier("CA-R11 : notifications voisin / rang / kiosque : champs du contrat §4.3 (%d voisins vus)" % nb_v, notif_ok and nb_v > 3)
	# Bilan en fin de partie
	StrategieTest.aller_a(e, Dates.lire("1989-01"), true)
	var b := Bilan.calculer(e)
	var rep: Dictionary = b["replique_rue"]
	var rue: Array = b["rue"]
	var rj := Quartier.rang_de(rue)
	var voisin_att := ""
	for l: Dictionary in rue:
		if int(l["rang"]) == (rj - 1 if rj > 1 else rj + 1):
			voisin_att = str(l["id"])
	verifier("CA-R11 : Bilan.calculer : « rue » = classement_rue() en fin de partie, « replique_rue » {qui, nom, texte} du voisin juste devant (sinon juste derrière)",
		rue.size() == 4 and var_to_str(rue) == var_to_str(e.classement_rue()) and rep.has_all(["qui", "nom", "texte"]) and rep["qui"] == voisin_att and str(rep["texte"]) != "")


func _tests_textes() -> void:
	var mauvais := []
	var textes: Array = []
	_collecter(Donnees.charger("rue"), textes)
	_collecter(Donnees.charger("krach"), textes)
	_collecter(Donnees.temoins()["jeanmi"], textes)
	for t: String in textes:
		for mot in MOTS_INTERDITS:
			if t.to_lower().contains(mot):
				mauvais.append(mot)
	verifier("CA-R6 : aucun « achetez », « vendez », « c'est le moment », « auriez dû » dans rue.json, krach.json, temoins.json > jeanmi (%d textes)" % textes.size(), mauvais.is_empty() and textes.size() > 40, str(mauvais))
	# Jamais d'achat à crédit : le panneau de la Banque plafonne chaque achat au compte courant (panneau_banque.gd, montant maximal
	# = e.joueur.cc) ; ici, la stratégie « tout sur Peugeot sans crédit » ne rend jamais le compte négatif par un de ses achats.
	var ok_credit := true
	for g in range(1, 11):
		var p := _partie(g, "peugeot")
		for x: Dictionary in p["suivi"]:
			if int(x["ab"]) >= Dates.lire("1986-03") and int(x["ab"]) <= Dates.lire("1987-09") and float(x["vous"]) < 0.0:
				ok_credit = false
		var e: EtatPartie = p["e"]
		if not e.joueur.lignes.has("peugeot") and e.joueur.qte("peugeot") == 0.0 and e.stats["ordres"] == 0:
			ok_credit = false
	verifier("CA-R6 : « tout sur Peugeot sans crédit » : des achats de Peugeot, jamais de patrimoine négatif avant le krach (le joueur ne dispose d'aucun levier)", ok_credit)

func _collecter(x: Variant, out: Array) -> void:
	if x is String:
		out.append(x)
	elif x is Array:
		for y in x:
			_collecter(y, out)
	elif x is Dictionary:
		for k in x:
			if not str(k).begins_with("_"):
				_collecter(x[k], out)
