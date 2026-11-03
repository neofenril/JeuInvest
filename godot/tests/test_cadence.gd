extends SceneTree
## Tests de la cadence V3 (docs/15 §0.1 R-CADENCE, anticipation, budgets ; feuille de route §2, CA-L4) et de
## R-MIROIR pour Tata Livret et Tonton Matelas. Logique pure : aucun nœud.
## Lancer : Godot_console.exe --headless --path godot --script res://tests/test_cadence.gd
## Imprime le nombre d'interruptions et leur liste par graine et par stratégie (comparaison avec main).

const F := 6.55957

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_cadence()
	_tests_anticipation()
	_tests_miroir()
	print("")
	print("=== test_cadence : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


## Partie entière avec StrategieTest (actif ou passif).
func jouer(g: int, actif: bool) -> EtatPartie:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(g))
	StrategieTest.aller_a(e, Dates.lire("1989-01"), actif)
	return e


func _m(e: EtatPartie, d: String) -> int:
	return Dates.lire(d) - e.mk.ab_debut


# ---------------------------------------------------------------------
# CA-L4 : 40 graines × 2 stratégies
# ---------------------------------------------------------------------

func _tests_cadence() -> void:
	var ok_un := true          # une interruption par mois au plus
	var ok_suite := true       # jamais deux mois de suite, sauf marché → panne forcée
	var ok_dates := true       # dates imposées
	var ok_budget := true      # classiques ≤ 15 ; cartes, projets, Gazette : 0 (pas encore de contenu)
	var ok_anticip := true     # aucune flexible au mois qui précède une datée
	var ok_fin := true
	var total := 0
	var nb := 0
	var mini := 99
	var maxi := 0
	var distribution := {}
	var detail_ko := ""
	var budget_cl := Cadence.budget("classiques")
	for actif in [false, true]:
		for g in range(1, 41):
			var e := jouer(g, actif)
			if e.fin != "fin":
				ok_fin = false
			var liste: Array = e.banque["interruptions_liste"]
			var n := liste.size()
			total += n
			nb += 1
			mini = mini if mini < n else n
			maxi = maxi if maxi > n else n
			distribution[n] = int(distribution.get(n, 0)) + 1
			var txt := ""
			for x: Dictionary in liste:
				txt += "%s %s%s · " % [Dates.texte_court(e.ab_de(int(x["m"]))), x["id"], "" if x["datee"] else "*"]
			print("    g%d %s (%d) : %s" % [g, "actif" if actif else "passif", n, txt])
			for i in range(1, n):
				var p: Dictionary = liste[i - 1]
				var x: Dictionary = liste[i]
				var dm := int(x["m"]) - int(p["m"])
				if dm == 0:
					ok_un = false
				if dm == 1 and not (p["kind"] == "marche" and x["kind"] == "vie" and x["motif"] == "scripte"):
					ok_suite = false
					detail_ko += "g%d %s : %s puis %s ; " % [g, Dates.texte_court(e.ab_de(int(x["m"]))), p["id"], x["id"]]
			# Anticipation : aucune interruption flexible au mois qui précède une interruption datée
			var datees := {}
			for x: Dictionary in liste:
				if x["datee"]:
					datees[int(x["m"])] = true
			for x: Dictionary in liste:
				if not x["datee"] and datees.has(int(x["m"]) + 1):
					ok_anticip = false
					detail_ko += "g%d : %s flexible en %s, veille d'une datée ; " % [g, x["id"], Dates.texte_court(e.ab_de(int(x["m"])))]
			# Dates imposées
			var at := {}
			for x: Dictionary in liste:
				at[str(x["id"])] = int(x["m"])
			var d02 := int(e.banque["presentes"].get("D02", 999))
			var conditions := {
				"PEL présenté au plus tard en 07/1984": d02 <= _m(e, "1984-07"),
				"naissance en 04/1985": int(at.get("naissance", -1)) == _m(e, "1985-04"),
				"Saint-Gobain en 11/1986": int(at.get("D07", -1)) == _m(e, "1986-11"),
				"krach en 10/1987": int(at.get("p1e6", -1)) == _m(e, "1987-10"),
				"panne en 11/1987": _panne_forcee(liste, _m(e, "1987-11")),
				"héritage en 04/1988": int(at.get("D08", -1)) == _m(e, "1988-04"),
			}
			for k in conditions:
				if not conditions[k]:
					ok_dates = false
					detail_ko += "g%d %s : %s manqué ; " % [g, "actif" if actif else "passif", k]
			var c: Dictionary = e.banque.get("compteurs", {})
			if int(c.get("classiques", 99)) > budget_cl or int(c.get("classiques", 0)) != n or int(c.get("cartes", 0)) != 0 \
					or int(c.get("projets", 0)) != 0 or int(c.get("gazette", 0)) != 0 or int(e.banque["interruptions"]) != n:
				ok_budget = false
	var resume := "%d parties, %d interruptions en tout, de %d à %d (moyenne %.2f), répartition %s" % [nb, total, mini, maxi, float(total) / nb, str(distribution)]
	print("    Cadence : ", resume)
	if detail_ko != "":
		print("    ", detail_ko.left(2000))
	verifier("Cadence (40 graines × actif / passif) : parties jouées jusqu'au bout", ok_fin)
	verifier("Cadence : une interruption par mois au plus", ok_un)
	verifier("Cadence : jamais deux mois de suite, sauf krach → panne forcée", ok_suite)
	verifier("Cadence : dates imposées (PEL ≤ 07/1984, naissance 04/1985, Saint-Gobain 11/1986, krach 10/1987, panne 11/1987, héritage 04/1988)", ok_dates)
	verifier("Cadence : classiques ≤ %d ; compteurs des cartes, projets et Gazette prêts et vides" % budget_cl, ok_budget, resume)
	verifier("Cadence : aucune interruption flexible au mois qui précède une interruption datée", ok_anticip)


func _panne_forcee(liste: Array, mm: int) -> bool:
	for x: Dictionary in liste:
		if int(x["m"]) == mm and x["kind"] == "vie" and x["motif"] == "scripte":
			return true
	return false


# ---------------------------------------------------------------------
# Règles unitaires de Cadence
# ---------------------------------------------------------------------

func _tests_anticipation() -> void:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(7))
	var m_naiss := _m(e, "1985-04")
	verifier("Anticipation : la naissance scriptée (04/1985) est connue dès le départ, le mois d'avant non",
		Cadence.date_connue(e, m_naiss) and not Cadence.date_connue(e, m_naiss - 1))
	verifier("Anticipation : le krach (10/1987), Saint-Gobain (11/1986) et l'héritage (04/1988) sont connus",
		Cadence.date_connue(e, _m(e, "1987-10")) and Cadence.date_connue(e, _m(e, "1986-11")) and Cadence.date_connue(e, _m(e, "1988-04")))
	# Après le Livret A, la date limite du PEL (07/1984) est connue, sauf pour le PEL lui-même
	e.resolution_auto()
	var m_pel := _m(e, "1984-07")
	var it_pel := {"kind": "banquier", "id": "D02", "m": e.m, "echeance": m_pel}
	verifier("Anticipation : date limite du PEL connue (07/1984) ; elle ne retient pas le PEL lui-même",
		Cadence.date_connue(e, m_pel) and not Cadence.date_connue(e, m_pel, it_pel))
	var vie := {"kind": "vie", "idx": 0, "m": 0}
	var pres := {"kind": "banquier", "id": "D03", "m": 0, "echeance": 999}
	var marche := {"kind": "marche", "id": "x", "m": 0}
	var carte := {"kind": "carte", "id": "C01", "m": 0}
	var choix := {"kind": "projet", "id": "P1", "m": 0}
	var ech := {"kind": "projet", "id": "P1", "m": 0, "echeance_projet": true}
	var gaz := {"kind": "gazette", "id": "G", "m": 0}
	var ordre := [marche, ech, vie, pres, choix, carte]
	var ok_ordre := true
	for i in range(1, ordre.size()):
		if Cadence.rang(e, ordre[i - 1]) >= Cadence.rang(e, ordre[i]):
			ok_ordre = false
	verifier("Priorités : marché > échéance de projet > vie aléatoire > présentation > choix de projet > carte", ok_ordre)
	verifier("Budgets : catégories (classique, cartes, projets, Gazette)",
		Cadence.categorie(vie) == "classiques" and Cadence.categorie(carte) == "cartes" and Cadence.categorie(choix) == "projets" and Cadence.categorie(gaz) == "gazette")


# ---------------------------------------------------------------------
# R-MIROIR (docs/15 §0.1) : même salaire, mêmes événements de vie, mêmes dépenses que Gérard
# ---------------------------------------------------------------------

## Joueur passif (il ne place jamais rien) : son patrimoine, agios rendus et courriers en attente comptés,
## est celui de Tonton Matelas chaque mois ; Tata Livret = Tonton Matelas + les intérêts du Livret A.
func _tests_miroir() -> void:
	var ok_matelas := true
	var ok_tata := true
	var ecart_max := 0.0
	var detail := ""
	for g in range(1, 41):
		var e := EtatPartie.new()
		e.demarrer(Donnees.config_demo(g))
		var garde := 0
		while e.fin == "" and garde < 80:
			garde += 1
			while not e.modale.is_empty():
				e.resolution_auto()
			var mat: Portefeuille = e.temoins["matelas"]
			var tata: Portefeuille = e.temoins["livret"]
			var d1 := absf(e.patrimoine(e.joueur) + e.joueur.agios + e.vie_en_attente() - e.patrimoine(mat))
			var d2 := absf(e.patrimoine(tata) - (e.patrimoine(mat) + tata.interets_total))
			ecart_max = maxf(ecart_max, d1)
			if d1 > 0.01:
				if ok_matelas:
					detail += "g%d %s : écart %.2f F ; " % [g, Dates.texte_court(e.ab_courant()), d1 * F]
				ok_matelas = false
			if d2 > 0.01:
				ok_tata = false
			e.avancer()
	verifier("R-MIROIR : un joueur qui ne place rien a, chaque mois, le patrimoine de Tonton Matelas (même salaire, mêmes dépenses, mêmes coups durs, même héritage ; 40 graines)", ok_matelas, "écart max %.4f F %s" % [ecart_max * F, detail])
	verifier("R-MIROIR : Tata Livret = Tonton Matelas + intérêts du Livret A crédités (même vie, seul le placement diffère)", ok_tata)
