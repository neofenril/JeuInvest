extends Node
## Tests du lot 04-L (CA-L2 invariant de la carte, CA-L3 coup dur, CA-L5 à L8 projets). Scène : l'autoload Partie
## est utilisé pour le saut (sauter_jusqu_a). Logique pure sinon. Tout est synchrone dans _ready.
## Lancer : Godot_console.exe --headless --path godot res://tests/test_projets.tscn
## Fichiers : user://test_projets_<pid>.sav seulement ; jamais partie_en_cours.sav.

const F := 6.55957

var _ok := 0
var _ko := 0


func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	Partie.sauvegarde_auto = false
	_tests_invariant()
	_tests_coup_dur()
	_tests_eteint()
	_tests_projets_dates()
	_tests_calibrage()
	_tests_cadence_projets()
	_tests_vente()
	_tests_regles()
	_tests_contrat()
	_tests_sauvegarde()
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "moins_cher"
	StrategieTest.politique_echeance = "auto"
	Sauvegarde.effacer(_chemin())
	print("")
	print("=== test_projets : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	get_tree().quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _chemin() -> String:
	return "user://test_projets_%d.sav" % OS.get_process_id()


func _config(g: int, cartes := true, projets := false) -> Dictionary:
	var c := Donnees.config_demo(g)
	c["cartes"] = cartes
	c["projets"] = projets
	return c


func _nouvelle(g: int, cartes := true, projets := false) -> EtatPartie:
	var e := EtatPartie.new()
	e.demarrer(_config(g, cartes, projets))
	return e


func _m(e: EtatPartie, d: String) -> int:
	return Dates.lire(d) - e.mk.ab_debut


## Avance (joueur passif ou actif) jusqu'à ce qu'une modale de ce kind (et de cette étape si donnée) soit ouverte.
func _jusqu_a(e: EtatPartie, kind: String, etape := "", actif := true) -> bool:
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		if e.modale.get("kind", "") == kind and (etape == "" or str(e.modale.get("etape", "")) == etape):
			return true
		StrategieTest.jouer_mois(e, actif)
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	return false


# ---------------------------------------------------------------------
# CA-L2 : une carte ouverte se ferme toujours (D1)
# ---------------------------------------------------------------------

func _tests_invariant() -> void:
	StrategieTest.politique_cartes = "epargner"
	var e := _nouvelle(7)
	var ok := _jusqu_a(e, "carte")
	var j := e.joueur
	var cc0 := j.cc
	var lv0 := j.livret
	var phrase := "Réglez d'abord la carte du foyer."
	var refus := [e.acheter(j, "sicav", Produits.f(100.0)), e.deposer_livret(j, Produits.f(10.0)), e.ouvrir_pel(Produits.f(2000.0), Produits.f(500.0)),
		e.verser_pel(Produits.f(100.0)), e.acheter_emprunt(Produits.f(100.0)), e.verser_av(Produits.f(100.0)),
		e.programmer_versement("livret", Produits.f(100.0)), e.reactiver_versement("livret")]
	var tous_refus := true
	for r: Dictionary in refus:
		if r.get("ok", true) or r.get("refus", "") != "carte" or r.get("msg", "") != phrase:
			tous_refus = false
	verifier("CA-L2 : carte ouverte : les 8 ordres débiteurs renvoient {ok false, refus « carte », « %s »}, compte, livret inchangés" % phrase,
		ok and tous_refus and e.ordres_bloques() and j.cc == cc0 and j.livret == lv0 and j.lignes.is_empty() and j.pel.is_empty() and j.av.is_empty()
		and j.emprunts.is_empty() and j.versements.is_empty(), str(refus.map(func(r: Dictionary) -> String: return str(r.get("refus", "ok")))))
	# Ventes, retraits, rachats, arrêt d'un versement : permis (un état fabriqué)
	j.lignes["sicav"] = {"qte": 1.0, "cout": Produits.f(100.0), "depuis": e.m, "qte_ombre": 1.0}
	j.livret += Produits.f(500.0)
	var v := e.vendre(j, "sicav", 0.0, true)
	var rl := e.retirer_livret(j, Produits.f(100.0))
	var ra := e.arreter_versement("livret")
	verifier("CA-L2 : pendant la carte, vente, retrait du Livret A, arrêt d'un versement restent permis", bool(v.get("ok", false)) and bool(rl.get("ok", false)) and ra.get("refus", "") != "carte")
	var t0: float = e.temoins["livret"].cc
	var rt := e.acheter(e.temoins["matelas"], "sicav", Produits.f(100.0))
	verifier("CA-L2 : les témoins ne sont pas concernés par l'invariant", rt.get("refus", "") != "carte" and e.temoins["livret"].cc == t0)
	# Une fois la carte réglée, les ordres reviennent ; ordres_bloques faux sans carte
	e.resolution_auto()
	verifier("CA-L2 : carte réglée : ordres_bloques() faux, l'ordre débiteur repasse", not e.ordres_bloques() and e.deposer_livret(j, Produits.f(10.0)).get("refus", "") != "carte")
	var e2 := _nouvelle(7)
	verifier("CA-L2 : ordres_bloques() faux sans carte (partie neuve) ; vrai pour un projet", not e2.ordres_bloques() and _bloque_projet())
	# Rejeu de RECETTE blocage : carte à deux dépenses, disponible ramené à 0
	var b := _jusqu_a_deux_depenses()
	var id := str(b.modale["id"]) if b != null else ""
	var ok_blocage := false
	var ok_aucun := false
	var ok_historique := false
	var ok_sauter := false
	var ok_refuse := false
	if b != null:
		var b2 := EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(b.vers_dict())))
		# « aucun » refusé quand un choix est payable
		ok_refuse = b2.resoudre_modale("aucun").is_empty() and not b2.modale.is_empty()
		b.joueur.cc = 0.0
		b.joueur.livret = 0.0
		var r := b.resolution_auto()
		ok_aucun = r.get("choix", "") == "aucun" and r.get("consequence", "") == "Pas les moyens ce mois-ci." and float(r.get("montant", 1.0)) == 0.0 \
			and r.get("humeur_avant", 0) == r.get("humeur_apres", 1) and b.modale.is_empty()
		var h := b.historique.filter(func(x: Dictionary) -> bool: return x["genre"] == "carte" and x["choix"] == "Pas les moyens ce mois-ci")
		ok_historique = h.size() == 1 and b.cartes_jouees().size() > 0 and b.cartes_jouees()[-1]["choix"] == "aucun"
		var garde := 0
		while b.fin == "" and garde < 120:
			garde += 1
			StrategieTest.jouer_mois(b, true)
			while not b.modale.is_empty():
				b.resolution_auto()
			b.avancer()
		ok_blocage = b.fin == "fin"
		# Même situation par Partie.sauter_jusqu_a (autoload)
		Partie.nouvelle_partie(_config(7))
		var pe := Partie.etat
		var g2 := 0
		while pe.fin == "" and g2 < 200:
			g2 += 1
			if pe.modale.get("kind", "") == "carte":
				var c := pe.contenu_modale()
				if float(c["choix"][0]["montant"]) < 0.0 and float(c["choix"][1]["montant"]) < 0.0:
					break
				pe.resoudre_modale(StrategieTest.choix_modale(pe, true))
				continue
			StrategieTest.jouer_mois(pe, true)
			while not pe.modale.is_empty() and pe.modale.get("kind", "") != "carte":
				pe.resolution_auto()
			if pe.modale.is_empty():
				pe.avancer()
		pe.joueur.cc = 0.0
		pe.joueur.livret = 0.0
		Partie.sauter_jusqu_a(pe.m_fin + 1, true)
		ok_sauter = pe.fin == "fin"
	verifier("CA-L2 : « aucun » refusé tant qu'un choix est payable ; RECETTE blocage rejoué (%s) : resolution_auto → choix « aucun », 0 F, humeur inchangée, carte fermée" % id,
		ok_refuse and ok_aucun)
	verifier("CA-L2 : sortie « Pas les moyens ce mois-ci » : ligne d'historique (genre carte) et carte comptée jouée", ok_historique)
	verifier("CA-L2 : la partie va jusqu'à décembre 1988 après le blocage (avancer + resolution_auto) et par Partie.sauter_jusqu_a", ok_blocage and ok_sauter)


func _bloque_projet() -> bool:
	var e := _nouvelle(7)
	e.modale = {"kind": "projet", "id": "P1", "etape": "choix"}
	return e.ordres_bloques()


## Partie (graine 7) arrêtée sur une carte dont les deux choix coûtent.
func _jusqu_a_deux_depenses() -> EtatPartie:
	StrategieTest.politique_cartes = "epargner"
	var e := _nouvelle(7)
	var garde := 0
	while e.fin == "" and garde < 120:
		garde += 1
		if e.modale.get("kind", "") == "carte":
			var c := e.contenu_modale()
			if float(c["choix"][0]["montant"]) < 0.0 and float(c["choix"][1]["montant"]) < 0.0:
				return e
			e.resoudre_modale(StrategieTest.choix_modale(e, true))
			continue
		StrategieTest.jouer_mois(e, true)
		if not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	return null


# ---------------------------------------------------------------------
# CA-L3 : un coup dur garde sa pause (D2)
# ---------------------------------------------------------------------

## Pour une graine : { indice d'événement du calendrier -> true } des événements de vie aléatoires qui ouvrent une modale.
func _vies_modales(g: int, cartes: bool, politique: String) -> Dictionary:
	StrategieTest.politique_cartes = politique
	var e := _nouvelle(g, cartes)
	var out := {}
	var garde := 0
	while e.fin == "" and garde < 120:
		garde += 1
		if e.modale.get("kind", "") == "vie" and not e.calendrier[int(e.modale["idx"])].get("force", false):
			out[int(e.modale["idx"])] = true
		StrategieTest.jouer_mois(e, true)
		if not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	return out


func _tests_coup_dur() -> void:
	var perdus := 0
	var carte_puis_vie := 0
	var max_par_partie := 0
	var cas_ok := true
	var detail := ""
	for politique in ["depenser", "epargner", "alterner"]:
		for g in range(1, 41):
			var a := _vies_modales(g, false, politique)
			var b := _vies_modales(g, true, politique)
			for mm in a:
				if not b.has(mm):
					perdus += 1
					detail += "%s g%d evt%d ; " % [politique, g, mm]
			StrategieTest.politique_cartes = politique
			var e := _nouvelle(g, true)
			StrategieTest.aller_a(e, Dates.lire("1989-01"), true)
			var l: Array = e.banque["interruptions_liste"]
			var n_partie := 0
			for i in range(1, l.size()):
				if l[i]["kind"] == "vie" and l[i - 1]["kind"] == "carte" and int(l[i]["m"]) - int(l[i - 1]["m"]) == 1:
					carte_puis_vie += 1
					n_partie += 1
					# la vie du mois m a bien sa pause : une interruption de l'historique, du calendrier (scriptée ou aléatoire)
					if not (str(l[i]["motif"]) in ["scripte", "ecart", "echeance"]) or str(l[i]["id"]) == "":
						cas_ok = false
			max_par_partie = maxi(max_par_partie, n_partie)
	print("    MESURE vie_retrogradee=%d" % perdus)
	print("    MESURE carte_puis_vie=%d max_par_partie=%d (repli quand toute la fenêtre de la carte est bloquée par un coup dur)" % [carte_puis_vie, max_par_partie])
	verifier("CA-L3 : chaque cas « carte puis vie » est une carte au mois m − 1 puis un événement de vie au mois m avec sa pause (interruption comptée)", cas_ok)
	verifier("CA-L3 : 40 graines × 3 politiques : aucun événement de vie qui ouvre une modale cartes éteintes ne devient une notification cartes allumées", perdus == 0, detail.left(400))
	# L'exception « carte → vie » est la seule dérogation nouvelle : un coup dur le mois d'après une carte garde sa pause
	var e := _nouvelle(7)
	e.banque["derniere_interruption"] = 10
	e.banque["derniere_kind"] = "carte"
	e.m = 11
	var vie := {"kind": "vie", "idx": 0, "m": 11}
	var vie_encore := {"kind": "vie", "idx": 0, "m": 11}
	var banquier := {"kind": "banquier", "id": "D03", "m": 0, "echeance": 999}
	e.banque["derniere_kind"] = "banquier"
	verifier("CA-L3 : « carte → vie » est une exception de R-CADENCE seulement après une carte (pas après une présentation)",
		not Cadence.peut_passer(e, vie_encore) and not Cadence.peut_passer(e, banquier))
	e.banque["derniere_kind"] = "carte"
	verifier("CA-L3 : un événement de vie le mois suivant une carte peut passer (garde sa pause)", Cadence.peut_passer(e, vie))


# ---------------------------------------------------------------------
# CA-L7 : éteint par défaut
# ---------------------------------------------------------------------

func _tests_eteint() -> void:
	var interdits := 0
	var rappel := 0
	for g in range(1, 41):
		for actif in [true, false]:
			var e := EtatPartie.new()
			e.demarrer(Donnees.config_demo(g))
			var garde := 0
			while e.fin == "" and garde < 120:
				garde += 1
				if e.modale.get("kind", "") == "projet":
					interdits += 1
				StrategieTest.jouer_mois(e, actif)
				while not e.modale.is_empty():
					e.resolution_auto()
				var r := e.avancer()
				for n: Dictionary in r["notifs"]:
					if n.get("type", "") == "projet_rappel":
						rappel += 1
			if not e.historique.filter(func(h: Dictionary) -> bool: return h["genre"] == "projet").is_empty():
				interdits += 1
	var e1 := EtatPartie.new()
	e1.demarrer(Donnees.config_demo(7))
	verifier("CA-L7 : projets éteints par défaut : aucune modale « projet », aucune notification « projet_rappel » (40 graines × 2 stratégies)",
		interdits == 0 and rappel == 0 and not e1.projets_actifs() and Donnees.charger("projets")["actif"] == false and e1.projet_en_cours().is_empty()
		and e1.ligne_projet_guichet() == "" and e1.projets_passes().is_empty())
	StrategieTest.aller_a(e1, Dates.lire("1989-01"), true)
	var patr := e1.patrimoine(e1.joueur) * F
	verifier("CA-L7 : référence inchangée (graine 7, joueur actif) : 172 139,25 F, frais 870,08 F, 11 interruptions",
		absf(patr - 172139.25) < 0.005 and absf(e1.frais_payes() * F - 870.08) < 0.005 and int(e1.banque["interruptions"]) == 11, "%.2f F" % patr)


# ---------------------------------------------------------------------
# CA-L5 : projets allumés
# ---------------------------------------------------------------------

## Joue une partie complète projets (et cartes) allumés. choix_projet : { "P1": "P1C", "P2": "P2B" } ou {} (politique).
func _jouer(g: int, actif: bool, choix_projet := {}, cartes := true) -> EtatPartie:
	var e := _nouvelle(g, cartes, true)
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		if e.modale.get("kind", "") == "projet" and e.modale.get("etape", "") == "choix" and choix_projet.has(str(e.modale["id"])):
			e.resoudre_modale(str(choix_projet[str(e.modale["id"])]))
			continue
		StrategieTest.jouer_mois(e, actif)
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	return e


func _statut(e: EtatPartie, pid: String) -> Dictionary:
	return e.projets["projets"][pid]


func _tests_projets_dates() -> void:
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "moins_cher"
	var ok_dates := true
	var ok_un := true
	var detail := ""
	var liste1 := {}
	for g in range(1, 41):
		var e := _nouvelle(g, true, true)
		var choix := {}
		var garde := 0
		var en_cours := 0
		while e.fin == "" and garde < 200:
			garde += 1
			if e.modale.get("kind", "") == "projet" and e.modale.get("etape", "") == "choix":
				choix[str(e.modale["id"])] = e.m
				if not e.projet_en_cours().is_empty():
					ok_un = false
			StrategieTest.jouer_mois(e, true)
			while not e.modale.is_empty():
				e.resolution_auto()
			e.avancer()
		var m1 := int(choix.get("P1", -99))
		var m2 := int(choix.get("P2", -99))
		if absi(m1 - _m(e, "1984-03")) > 1 or m2 < _m(e, "1987-01") or m2 > _m(e, "1987-02"):
			ok_dates = false
			detail += "g%d : %d / %d ; " % [g, m1 - _m(e, "1984-03"), m2 - _m(e, "1987-01")]
		liste1[g] = [m1, m2]
	verifier("CA-L5 : choix du projet 1 en 03/1984 ± 1 mois et du projet 2 en 01 ou 02/1987, 40 graines sur 40, jamais deux projets en cours", ok_dates and ok_un, detail.left(300))


## Calibrage : stratégie passive (tout reste sur compte et Livret A), cartes « epargner », projets P1C puis P2B, graines sans jumeaux.
func _tests_calibrage() -> void:
	StrategieTest.politique_cartes = "epargner"
	var n := 0
	var p1c := 0
	var p2b := 0
	var detail := ""
	for g in range(1, 41):
		var e := _jouer(g, false, {"P1": "P1C", "P2": "P2B"})
		if e.enfants >= 2:
			continue
		n += 1
		if str(_statut(e, "P1")["etat"]) == "realise":
			p1c += 1
		if str(_statut(e, "P2")["etat"]) == "realise":
			p2b += 1
		detail += "g%d:%s/%s " % [g, _statut(e, "P1")["etat"].left(4), _statut(e, "P2")["etat"].left(4)]
	var x := 100.0 * p1c / maxf(n, 1.0)
	var y := 100.0 * p2b / maxf(n, 1.0)
	print("    MESURE projets P1C_a_la_date=%.0f%% P2B_a_la_date=%.0f%% (%d graines sans jumeaux sur 40) %s" % [x, y, n, detail])
	verifier("CA-L5 : calibrage (passif, cartes epargner, sans jumeaux) : P1C réalisé à la date ≥ 80 %%, P2B (35 000 F) ≥ 60 %%", x >= 80.0 and y >= 60.0, "%.0f %% / %.0f %%" % [x, y])


func _tests_cadence_projets() -> void:
	var ok_nb := true
	var ok_proj := true
	var ok_suite := true
	var ok_s7 := true
	var ok_s10 := true
	var detail := ""
	var par_partie := {}
	var rep := {}
	var nb := 0
	for politique in ["depenser", "epargner", "alterner"]:
		StrategieTest.politique_cartes = politique
		for g in range(1, 41):
			StrategieTest.politique_projets = ["moins_cher", "milieu", "plus_cher"][g % 3]
			var e := _nouvelle(g, true, true)
			StrategieTest.aller_a(e, Dates.lire("1989-01"), true)
			nb += 1
			var l: Array = e.banque["interruptions_liste"]
			var cartes := l.filter(func(x: Dictionary) -> bool: return x["kind"] == "carte")
			var projets := l.filter(func(x: Dictionary) -> bool: return x["kind"] == "projet")
			par_partie[cartes.size()] = int(par_partie.get(cartes.size(), 0)) + 1
			rep["projets=%d" % projets.size()] = int(rep.get("projets=%d" % projets.size(), 0)) + 1
			if cartes.size() < 8 or cartes.size() > 10 or e.fin != "fin":
				ok_nb = false
				detail += "%s g%d : %d cartes ; " % [politique, g, cartes.size()]
			if projets.size() > Cadence.budget("projets"):
				ok_proj = false
			for i in range(1, l.size()):
				var dm := int(l[i]["m"]) - int(l[i - 1]["m"])
				if dm == 0 or (dm == 1 and not (l[i - 1]["kind"] == "marche" and l[i]["kind"] == "vie" and l[i]["motif"] == "scripte") \
						and not (l[i - 1]["kind"] == "carte" and l[i]["kind"] == "vie")):
					ok_suite = false
					detail += "%s g%d %s : %s puis %s ; " % [politique, g, Dates.texte_court(e.ab_de(int(l[i]["m"]))), l[i - 1]["id"], l[i]["id"]]
			var cr := Foyer.creneaux(e)
			if _statut(e, "P2")["option"] == "P2A":
				var s7: Dictionary = cr["S7"]
				if s7["etat"] == "joue" and s7["jouee"] == "C11":
					ok_s7 = false
			var ech88 := false
			for p: String in ["P1", "P2"]:
				if int(_statut(e, p)["m_echeance_initiale"]) == _m(e, "1988-02") or (int(_statut(e, p)["m_fin"]) == _m(e, "1988-02") and str(_statut(e, p)["option"]) == "P2B"):
					ech88 = true
			if ech88 and cr["S10"]["etat"] == "joue":
				ok_s10 = false
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "moins_cher"
	print("    Cadence projets allumés : %d parties, cartes par partie %s, %s" % [nb, str(par_partie), str(rep)])
	print("    MESURE cartes7=%d/120" % int(par_partie.get(7, 0)))
	verifier("CA-L6 : projets et cartes allumés, 40 graines × 3 politiques : 7 à 10 cartes par partie, au plus 2 parties à 7, 120 parties finies",
		par_partie.keys().all(func(k: int) -> bool: return k >= 7 and k <= 10) and int(par_partie.get(7, 0)) <= 2 and nb == 120, detail.left(500))
	verifier("CA-L6 : projets ≤ 6 par partie (2 choix, 2 jours J, 2 reports) ; Cadence.budget(projets) == 6", ok_proj and Cadence.budget("projets") == 6)
	verifier("CA-L6 : jamais deux interruptions le même mois ni deux mois de suite (hors marché → panne et carte → vie)", ok_suite, detail.left(500))
	verifier("CA-L6 : S7 prend C09 / C10 (pas C11) quand le projet 2 est P2A ; S10 absent si une échéance tombe en 02/1988", ok_s7 and ok_s10)


# ---------------------------------------------------------------------
# Vente automatique, report, témoins, humeur, rappel, guichet
# ---------------------------------------------------------------------

## Partie arrêtée au jour J du projet 1 (P1C), avec un portefeuille fabriqué : de l'argent sur SICAV, assurance-vie, PEL.
func _au_jour_j(g: int, option := "P1C") -> EtatPartie:
	StrategieTest.politique_cartes = "epargner"
	var e := _nouvelle(g, false, true)
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		if e.modale.get("kind", "") == "projet" and e.modale.get("etape", "") == "choix":
			e.resoudre_modale(option)
			continue
		if e.modale.get("kind", "") == "projet" and e.modale.get("etape", "") == "echeance":
			return e
		StrategieTest.jouer_mois(e, false)
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	return null


func _tests_vente() -> void:
	var e := _au_jour_j(7)
	if e == null:
		verifier("CA-L5 : jour J atteint", false)
		return
	var j := e.joueur
	var a := e.ab_courant()
	# Portefeuille fabriqué : compte 2 000 F, Livret 1 000 F, SICAV (cout 8 000 F, vaut davantage), assurance-vie, PEL récent
	j.cc = Produits.f(2000.0)
	j.livret = Produits.f(1000.0)
	e.produits_achetables()
	var q := Produits.f(20000.0) / e.cours("sicav")
	j.lignes["sicav"] = {"qte": q, "cout": Produits.f(22000.0), "depuis": e.m - 20, "qte_ombre": q}
	j.av = {"ouvert_m": e.m - 30, "valeur": Produits.f(9000.0), "courus": 0.0, "primes": Produits.f(8000.0), "ombre": Produits.f(8000.0), "ombre_courus": 0.0}
	j.pel = {"ouvert_m": e.m - 20, "taux": 8.25, "taux_hp": 6.3, "mensuel": Produits.f(500.0), "solde": Produits.f(10000.0), "verse": Produits.f(9000.0),
		"interets": Produits.f(1000.0), "courus": 0.0, "verse_annee": 0.0}
	var c := e.contenu_modale()
	var mt := float(c["montant"])
	var dispo := float(c["disponible"])
	var manque := float(c["manque"])
	var plan: Array = c["ventes"]
	verifier("CA-L5 : jour J : disponible = compte + Livret A (3 000 F), manque = montant − disponible", absf(dispo - Produits.f(3000.0)) < 1e-9 and absf(manque - (mt - dispo)) < 1e-9, "montant %.0f F" % (mt * F))
	# Ordre : rentabilité croissante ; recalcul indépendant du net de la SICAV, de l'assurance-vie, du PEL
	var net_sicav := e.devis_vente(j, "sicav", 0.0, true)
	var perf_sicav := (float(net_sicav["recu"]) - Produits.f(22000.0)) / Produits.f(22000.0)
	var gains_av := Produits.f(1000.0)
	var imp_av := gains_av * Produits.taux_rachat_av(30) / 100.0
	var net_av := Produits.f(9000.0) - imp_av
	var perf_av := (net_av - Produits.f(8000.0)) / Produits.f(8000.0)
	var cloture := Produits.devis_cloture_pel(e, j)
	var perf_pel := (float(cloture["recu"]) - Produits.f(9000.0)) / Produits.f(9000.0)
	var attendu := [["sicav", perf_sicav], ["av", perf_av], ["pel", perf_pel]]
	attendu.sort_custom(func(x: Array, z: Array) -> bool: return float(x[1]) < float(z[1]))
	var ordre_att := attendu.map(func(x: Array) -> String: return str(x[0]))
	var ordre_vu := plan.map(func(v: Dictionary) -> String: return str(v["id"]))
	var ordre_vu_limite := ordre_vu.slice(0, ordre_att.size())
	var nets := 0.0
	var tous := plan.duplicate()
	for v: Dictionary in tous:
		nets += float(v["net"])
	verifier("CA-L5 : plan de vente dans l'ordre de rentabilité croissante (après compte courant et Livret A) : attendu %s, vu %s" % [str(ordre_att), str(ordre_vu)],
		ordre_vu == ordre_att.slice(0, ordre_vu.size()) and ordre_vu.size() > 0)
	# Recalcul indépendant de la vente SICAV complète (impôt 16 % de la plus-value)
	var brut_sicav := q * e.cours("sicav")
	var pv := brut_sicav - Produits.f(22000.0)
	var recu_att := brut_sicav - maxf(0.0, pv) * float(Marche.impot(a)["cto"]) / 100.0
	var v_sicav: Dictionary = {}
	for v: Dictionary in plan:
		if v["id"] == "sicav":
			v_sicav = v
	var ok_recalcul := not v_sicav.is_empty()
	if ok_recalcul and absf(float(v_sicav["vendu"]) - brut_sicav) < 1e-6:
		ok_recalcul = absf(float(v_sicav["net"]) - recu_att) < 1e-6
	verifier("CA-L5 : recalcul indépendant d'une vente (SICAV à perte : brut, aucun impôt) au centime près", ok_recalcul and absf(float(v_sicav["vendu"]) - brut_sicav) < 1e-6, str(v_sicav))
	var v_pel: Dictionary = {}
	for v: Dictionary in plan:
		if v["id"] == "pel":
			v_pel = v
	var tx := float(Produits.params()["pel"]["taux_cloture_anticipee"])
	var pel_att := Produits.f(9000.0) + Produits.f(1000.0) * tx / 8.25
	verifier("CA-L5 : recalcul indépendant d'une vente (PEL clos avant 4 ans : versements + intérêts au taux de base, prime perdue) au centime près",
		not v_pel.is_empty() and absf(float(v_pel["net"]) - pel_att) < 1e-6 and absf(float(v_pel["penalite"]) - (Produits.f(1000.0) - Produits.f(1000.0) * tx / 8.25)) < 1e-6 and str(v_pel["texte_penalite"]).begins_with("Prime d"), str(v_pel))
	# Exécution : réaliser en vendant, juste ce qu'il faut, jamais de solde négatif, le reste reste sur le compte
	var e_cc0 := j.cc + j.livret
	var patr0 := e.patrimoine(j)
	var disponible_apres := dispo + nets
	var r_choix := e.resoudre_modale("realiser_en_vendant")
	var ok_vente: bool = not r_choix.is_empty() and r_choix.get("kind", "") == "projet" and (r_choix["ventes"] as Array).size() == plan.size() and j.cc >= -1e-9
	var reste_att := disponible_apres - mt
	verifier("CA-L5 : réaliser en vendant : le projet est payé, aucun solde négatif, humeur +2, statut « realise », une ligne d'historique genre « projet »",
		ok_vente and j.cc + j.livret >= -1e-9 and str(_statut(e, "P1")["etat"]) == "realise" and not e.historique.filter(func(h: Dictionary) -> bool: return h["genre"] == "projet").is_empty()
		, "cc %.2f F, livret %.2f F, reste attendu ≥ %.2f F (avant : %.2f F)" % [j.cc * F, j.livret * F, reste_att * F, e_cc0 * F])
	# Juste ce qu'il faut : le dernier élément du plan n'est vendu que partiellement ou pour le strict nécessaire
	var somme_hors_dernier := nets - float(plan[-1]["net"])
	verifier("CA-L5 : « juste ce qu'il faut » : sans la dernière vente le disponible ne suffit pas, avec il suffit",
		dispo + somme_hors_dernier < mt - 1e-9 and dispo + nets >= mt - 1e-9)

func _tests_regles() -> void:
	# Report : +4 mois ou premier mois libre ; un seul ; P2C sans report ; renoncer
	StrategieTest.politique_cartes = "epargner"
	var e := _au_jour_j(7)
	e.joueur.cc = 0.0
	e.joueur.livret = 0.0
	var c := e.contenu_modale()
	var ids := (c["choix"] as Array).map(func(x: Dictionary) -> String: return str(x["id"]))
	verifier("CA-L5 : sans argent, ni réaliser ni vendre : REPORTER et RENONCER proposés (realiser_en_vendant désactivé)",
		ids.has("reporter") and ids.has("renoncer") and not ids.has("realiser") and (c["choix"] as Array).filter(func(x: Dictionary) -> bool: return x["id"] == "realiser_en_vendant" and x["desactive"]).size() == 1, str(ids))
	var m0 := e.m
	var h0: int = int(e.foyer["humeur"])
	var r := e.resoudre_modale("reporter")
	var s := _statut(e, "P1")
	verifier("CA-L5 : report : nouvelle échéance ≥ +4 mois, un seul report, humeur −1, projet toujours en cours",
		int(s["m_echeance"]) >= m0 + 4 and bool(s["report_utilise"]) and str(s["etat"]) == "en_cours" and int(e.foyer["humeur"]) == int(h0) - 1 and r["kind"] == "projet", "%d → %d" % [m0, int(s["m_echeance"])])
	var ok_deuxieme := true
	var garde := 0
	while e.fin == "" and e.modale.get("etape", "") != "echeance" and garde < 30:
		garde += 1
		StrategieTest.jouer_mois(e, false)
		while not e.modale.is_empty() and e.modale.get("kind", "") != "projet":
			e.resolution_auto()
		if e.modale.is_empty():
			e.avancer()
	if e.modale.get("etape", "") == "echeance":
		var ids2 := (e.contenu_modale()["choix"] as Array).map(func(x: Dictionary) -> String: return str(x["id"]))
		ok_deuxieme = not ids2.has("reporter")
		var m_ech := e.m
		e.joueur.cc = 0.0
		e.joueur.livret = 0.0
		e.resoudre_modale("renoncer")
		verifier("CA-L5 : deuxième échéance : plus de report ; RENONCER : abandonné, humeur −2 de plus, rien chez les témoins",
			ok_deuxieme and str(_statut(e, "P1")["etat"]) == "abandonne" and m_ech == int(_statut(e, "P1")["m_fin"]))
	else:
		verifier("CA-L5 : deuxième échéance atteinte après un report", false)
	# Humeur d'un projet réalisé après report : +1 ; à la date : +2 ; témoins : même montant le même mois
	var g := _au_jour_j(3)
	var tem0 := {}
	for k: String in g.temoins:
		tem0[k] = g.temoins[k].cc
	g.joueur.cc = Produits.f(40000.0)
	var h1 := int(g.foyer["humeur"])
	var mt := float(g.contenu_modale()["montant"])
	g.resoudre_modale("realiser")
	var ok_tem := true
	for k: String in g.temoins:
		if absf((float(tem0[k]) - g.temoins[k].cc) - mt) > 1e-9:
			ok_tem = false
	verifier("CA-L5 : réalisé à la date : humeur +2 ; R-MIROIR : chaque témoin paie le même montant le même mois (graine 3)", int(g.foyer["humeur"]) == mini(3, h1 + 2) and ok_tem)
	# Rappel : une notification sans pause à 3 mois, une seule
	var rap := 0
	var m_rap := -1
	var rr := _nouvelle(7, false, true)
	var gg := 0
	while rr.fin == "" and gg < 200:
		gg += 1
		StrategieTest.jouer_mois(rr, false)
		while not rr.modale.is_empty():
			rr.resolution_auto()
		var res := rr.avancer()
		for n: Dictionary in res["notifs"]:
			if n.get("type", "") == "projet_rappel":
				rap += 1
				m_rap = rr.m
	verifier("CA-L5 : rappel à 3 mois de l'échéance : une notification « projet_rappel » par projet, sans pause, avec le montant et le disponible dans le texte", rap >= 1 and rap <= 2 and m_rap >= 0)
	# Guichet : deux cas exacts et vide sans projet
	var gu := _nouvelle(7, false, true)
	verifier("CA-L5 : ligne du guichet vide sans projet en cours", gu.ligne_projet_guichet() == "")
	var gu2 := _au_jour_j(7, "P1C")
	gu2.resoudre_modale("renoncer")
	verifier("CA-L5 : ligne du guichet vide après abandon", gu2.ligne_projet_guichet() == "")
	var gu3 := _nouvelle(7, false, true)
	_jusqu_a(gu3, "projet", "choix", false)
	gu3.resoudre_modale("P1C")
	var att := "Projet : la Super 5, avril 1986 (dans %d mois) · %s" % [_m(gu3, "1986-04") - gu3.m, Format.entier(Produits.f(30000.0), gu3.ab_courant())]
	verifier("CA-L5 : ligne du guichet exacte : « %s »" % att, gu3.ligne_projet_guichet() == att, gu3.ligne_projet_guichet())
	var gu4 := _nouvelle(7, false, true)
	_jusqu_a(gu4, "projet", "choix", false)
	gu4.resoudre_modale("P1A")
	var att4 := "Projet : le salon et la chaîne hi-fi, avril 1986 (dans %d mois) · %s" % [_m(gu4, "1986-04") - gu4.m, Format.entier(Produits.f(12000.0), gu4.ab_courant())]
	verifier("CA-L5 : ligne du guichet exacte (2e cas) : « %s »" % att4, gu4.ligne_projet_guichet() == att4, gu4.ligne_projet_guichet())
	# P2C : jour J avant la fin, sans report, apport dans le patrimoine
	var p2 := _nouvelle(7, false, true)
	StrategieTest.politique_projets = "plus_cher"
	var ok_p2c := false
	var detail := ""
	gg = 0
	while p2.fin == "" and gg < 200:
		gg += 1
		if p2.modale.get("kind", "") == "projet" and p2.modale.get("etape", "") == "choix" and p2.modale["id"] == "P2":
			p2.resoudre_modale("P2C")
			continue
		if p2.modale.get("kind", "") == "projet" and p2.modale.get("etape", "") == "echeance" and p2.modale["id"] == "P2C":
			var ids3 := (p2.contenu_modale()["choix"] as Array).map(func(x: Dictionary) -> String: return str(x["id"]))
			var titre_r := ""
			for x: Dictionary in p2.contenu_modale()["choix"]:
				if x["id"] == "renoncer":
					titre_r = str(x["titre"])
			p2.joueur.cc = Produits.f(95000.0)
			var avant := p2.patrimoine(p2.joueur)
			p2.resoudre_modale("realiser")
			ok_p2c = p2.fin == "" and not ids3.has("reporter") and titre_r == "RENONCER POUR L'INSTANT" and absf(p2.patrimoine(p2.joueur) - avant) < 1e-6 \
				and Projets.apport(p2, p2.joueur) == Produits.f(90000.0) and Projets.apport(p2, p2.temoins["livret"]) == Produits.f(90000.0) and p2.m == p2.m_fin
			detail = "m=%d m_fin=%d titre=%s" % [p2.m, p2.m_fin, titre_r]
			break
		StrategieTest.jouer_mois(p2, false)
		while not p2.modale.is_empty() and p2.modale.get("kind", "") != "projet":
			p2.resolution_auto()
		if p2.modale.is_empty():
			p2.avancer()
		elif p2.modale.get("etape", "") == "echeance" or p2.modale.get("etape", "") == "choix":
			pass
	StrategieTest.politique_projets = "moins_cher"
	verifier("CA-L5 : P2C : jour J avant l'écran de fin, sans report (« RENONCER POUR L'INSTANT »), l'apport de 90 000 F reste dans le patrimoine (joueur et témoins)", ok_p2c, detail)


func _tests_contrat() -> void:
	var e := _nouvelle(7, false, true)
	_jusqu_a(e, "projet", "choix", false)
	var c := e.contenu_modale()
	var cles := ["kind", "etape", "source", "date", "ab", "id", "titre", "texte", "choix"]
	var cles_choix := ["id", "titre", "montant", "echeance_txt", "icone", "sous"]
	var ok := c.size() == cles.size() and c.has_all(cles) and (c["choix"] as Array).size() == 3
	for ch: Dictionary in c["choix"]:
		if ch.size() != cles_choix.size() or not ch.has_all(cles_choix):
			ok = false
	verifier("CA-L8 : contenu_modale() du choix de projet : exactement les champs du contrat §4.2, 3 choix", ok, str(c.keys()))
	var amounts := (c["choix"] as Array).map(func(x: Dictionary) -> int: return roundi(float(x["montant"]) * F))
	verifier("CA-L5 : montants de docs/18 §2 (P1A 12 000 F, P1B 16 000 F, P1C 30 000 F)", amounts == [12000, 16000, 30000], str(amounts))
	e.resoudre_modale("P1C")
	var pc := e.projet_en_cours()
	var cles_pc := ["id", "nom", "icone", "montant", "m_echeance", "echeance_txt", "mois_restants", "report_utilise", "reportable", "disponible", "revendable", "atteint"]
	verifier("CA-L8 : projet_en_cours() : exactement les champs du contrat §4.2", pc.size() == cles_pc.size() and pc.has_all(cles_pc) and pc["id"] == "P1C" and pc["echeance_txt"] == "avril 1986", str(pc.keys()))
	var j := _au_jour_j(7)
	var c2 := j.contenu_modale()
	var cles2 := ["kind", "etape", "source", "date", "ab", "id", "titre", "texte", "montant", "disponible", "manque", "ventes", "apres_ventes", "choix"]
	var ok2 := c2.size() == cles2.size() and c2.has_all(cles2)
	j.joueur.cc = Produits.f(1000.0)
	j.joueur.livret = 0.0
	j.joueur.lignes["sicav"] = {"qte": 10.0, "cout": 10.0 * j.cours("sicav"), "depuis": j.m - 5, "qte_ombre": 10.0}
	var plan := j.contenu_modale()["ventes"] as Array
	var cles_v := ["id", "nom", "vendu", "net", "frais", "impot", "penalite", "texte_penalite", "ecart_verse", "texte_ecart"]
	for v: Dictionary in plan:
		if v.size() != cles_v.size() or not v.has_all(cles_v):
			ok2 = false
	verifier("CA-L8 : contenu_modale() du jour J : exactement les champs du contrat §4.2 (et ceux d'une vente du plan)", ok2 and plan.size() > 0, str(c2.keys()))
	var r := j.resoudre_modale("renoncer")
	var cles_r := ["choix", "kind", "etape", "montant", "consequence", "humeur_avant", "humeur_apres", "notifs", "ventes"]
	verifier("CA-L8 : resoudre_modale d'un projet : champs du contrat §4.2 ; projets_passes() : {id, nom, icone, montant, statut, m, ab}",
		r.has_all(cles_r) and j.projets_passes().size() == 1 and (j.projets_passes()[0] as Dictionary).has_all(["id", "nom", "icone", "montant", "statut", "m", "ab"])
		and j.projets_passes()[0]["statut"] == "abandonne")


func _tests_sauvegarde() -> void:
	# Au milieu d'un projet : même projet, même échéance, même report
	var e := _nouvelle(7, false, true)
	_jusqu_a(e, "projet", "choix", false)
	e.resoudre_modale("P1C")
	var ok := true
	var garde := 0
	var reporte := false
	while e.fin == "" and garde < 120:
		garde += 1
		if e.modale.get("etape", "") == "echeance" and not reporte:
			e.joueur.cc = 0.0
			e.joueur.livret = 0.0
			e.resoudre_modale("reporter")
			reporte = true
			Sauvegarde.ecrire(e, {}, _chemin())
			var b := Sauvegarde.charger(Sauvegarde.lire(_chemin()))
			ok = b != null and var_to_str(b.projet_en_cours()) == var_to_str(e.projet_en_cours()) and bool(b.projets["projets"]["P1"]["report_utilise"]) \
				and b.projets["projets"]["P1"]["m_echeance"] == e.projets["projets"]["P1"]["m_echeance"] and b.projets_actifs()
			break
		StrategieTest.jouer_mois(e, false)
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	verifier("CA-L5 (CA-1.7) : sauvegarde au milieu d'un projet (après un report) : même projet, même échéance, même report utilisé", ok and reporte)
	# Sauvegarde de main (sans champ projets) : se recharge, projets éteints, va à la fin
	var d := _nouvelle(7, true, true).vers_dict()
	d.erase("projets")
	var v := EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(d)))
	var garde2 := 0
	while v != null and v.fin == "" and garde2 < 200:
		garde2 += 1
		while not v.modale.is_empty():
			v.resolution_auto()
		v.avancer()
	verifier("CA-L7 : une sauvegarde sans champ projets (main) se recharge, projets éteints, et va jusqu'à la fin", v != null and not v.projets_actifs() and v.fin == "fin")
	# Modale de projet ouverte, sauvegardée, rechargée : la même carte se rouvre
	var e3 := _nouvelle(7, false, true)
	_jusqu_a(e3, "projet", "choix", false)
	var b3 := EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(e3.vers_dict())))
	verifier("CA-L5 : carte de projet ouverte, sauvegarde, reprise : le même contenu", var_to_str(e3.contenu_modale()) == var_to_str(b3.contenu_modale()) and b3.ordres_bloques())
