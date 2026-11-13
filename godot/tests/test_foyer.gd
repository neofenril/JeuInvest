extends SceneTree
## Tests de P2 « Les dilemmes du foyer » (docs/15 §2 ; lot 03, partie 03-foyer : CA-FO1, FO3 à FO7 ; CA-FO2 dans
## test_cadence). Logique pure : aucun nœud. Lancer : Godot_console.exe --headless --path godot --script res://tests/test_foyer.gd
## Fichiers : user://test_foyer_<pid>.sav seulement (effacé à la fin) ; jamais partie_en_cours.sav.

const F := 6.55957
## Référence de 03-L (test_dividendes, graine 7, StrategieTest actif) : rien ne doit changer cartes éteintes (CA-FO1).
const REF_PATRIMOINE_F := 172139.25
const REF_FRAIS_F := 869.97
const REF_INTERRUPTIONS := 11

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_eteint()
	_tests_donnees()
	_tests_humeur()
	_tests_parties()
	_tests_contrat()
	_tests_salaire()
	_tests_escargots()
	_tests_sauvegarde()
	StrategieTest.politique_cartes = "epargner"
	Sauvegarde.effacer(_chemin())
	print("")
	print("=== test_foyer : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _chemin() -> String:
	return "user://test_foyer_%d.sav" % OS.get_process_id()


func _config(g: int, cartes := true) -> Dictionary:
	var c := Donnees.config_demo(g)
	c["cartes"] = cartes
	return c


func _nouvelle(g: int, cartes := true) -> EtatPartie:
	var e := EtatPartie.new()
	e.demarrer(_config(g, cartes))
	return e


## Avance (joueur actif, politique donnée) jusqu'à ce qu'une carte soit ouverte ; false si la partie finit avant.
func _jusqu_a_carte(e: EtatPartie, politique := "epargner", id := "") -> bool:
	StrategieTest.politique_cartes = politique
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		if e.modale.get("kind", "") == "carte" and (id == "" or str(e.modale["id"]) == id):
			return true
		StrategieTest.jouer_mois(e, true)
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	return false


# ---------------------------------------------------------------------
# CA-FO1 : éteint par défaut
# ---------------------------------------------------------------------

func _tests_eteint() -> void:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(7))
	verifier("CA-FO1 : foyer.json > actif = false ; une partie de la démo par défaut n'a pas de cartes",
		Foyer.donnees()["actif"] == false and not e.cartes_actives() and not e.foyer["actif"] and (e.foyer["creneaux"] as Dictionary).is_empty())
	StrategieTest.aller_a(e, Dates.lire("1989-01"), true)
	var a := e.ab_courant()
	var cartes := (e.banque["interruptions_liste"] as Array).filter(func(x: Dictionary) -> bool: return x["kind"] == "carte")
	var humeur := e.historique.filter(func(h: Dictionary) -> bool: return h["type"] in ["humeur", "escargots"] or h["genre"] == "carte")
	var patr := e.patrimoine(e.joueur) * F
	verifier("CA-FO1 : partie intégrale (graine 7, joueur actif) identique à la référence de 03-L : patrimoine 172 139,25 F, frais 869,97 F, 11 interruptions",
		e.fin == "fin" and absf(patr - REF_PATRIMOINE_F) < 0.005 and absf(e.frais_payes() * F - REF_FRAIS_F) < 0.005
		and int(e.banque["interruptions"]) == REF_INTERRUPTIONS and cartes.is_empty() and humeur.is_empty(),
		"%s, frais %s, %d interruptions" % [Format.montant(e.patrimoine(e.joueur), a), Format.montant(e.frais_payes(), a), int(e.banque["interruptions"])])
	verifier("CA-FO1 : l'humeur existe quand même (naissance + 1, invisible) : neutre, sans notification", e.humeur_visible() == 1 and int(e.foyer["humeur"]) >= 0)


# ---------------------------------------------------------------------
# CA-FO5 (textes) : données
# ---------------------------------------------------------------------

func _tests_donnees() -> void:
	var d := Foyer.donnees()
	var interdits := ["auriez dû", "devriez", "conseil", "il faut"]
	var rx_montant := RegEx.create_from_string("[0-9][0-9  ]*\\s?F\\b")
	var e := _nouvelle(7)
	e.enfants = 2   # variante jumeaux et prénoms : textes les plus longs
	var ok_mots := true
	var ok_interdits := true
	var ok_montants := true
	var ok_choix := true
	var detail := ""
	var textes := [str(d["consequence_depense"]), str(d["manque"]), str(d["escargots"]["texte"])]
	for t in d["notif_humeur"].values():
		textes.append(str(t))
	for id: String in d["cartes"]:
		var c: Dictionary = d["cartes"][id]
		for cle in ["texte", "texte_jumeaux"]:
			if not c.has(cle):
				continue
			var brut := str(c[cle])
			if rx_montant.search(brut) != null:
				ok_montants = false
				detail += "%s : montant en dur ; " % id
			var plein := Foyer._remplir(e, brut, c).replace(Banquier.prenoms_enfants(e), "Julie et Thomas")
			if Banquier.nb_mots(plein) > 30:
				ok_mots = false
				detail += "%s : %d mots ; " % [id, Banquier.nb_mots(plein)]
		if Banquier.nb_mots(str(c["titre"])) > 5:
			ok_mots = false
			detail += "%s : titre trop long ; " % id
		textes.append_array([str(c["texte"]), str(c.get("texte_jumeaux", "")), str(c["pourquoi"]), str(c["a"].get("replique", "")), str(c["b"].get("replique", ""))])
		# Chaque carte a au moins un choix à 0 F ou un revenu, sauf les cartes à deux dépenses (docs/15 §2.2 : remplacées si aucune n'est payable)
		for k in ["a", "b"]:
			if not c[k].has_all(["libelle", "prix_F", "sens", "humeur"]):
				ok_choix = false
	for t: String in textes:
		for mot in interdits:
			if t.to_lower().contains(mot):
				ok_interdits = false
				detail += "« %s » ; " % mot
	verifier("CA-FO5 : textes de carte ≤ 30 mots (variante jumeaux et prénoms comprises), titres ≤ 5 mots", ok_mots, detail)
	_tests_textes_lot04(d)
	verifier("CA-FO5 : aucun texte ne contient « auriez dû », « devriez », « conseil », « il faut »", ok_interdits, detail)
	verifier("CA-FO5 : aucun montant écrit en dur dans un texte de carte (gabarits {prix_a}, {prix_b} seulement)", ok_montants, detail)
	verifier("FO1 : 16 cartes C00-C15, 10 créneaux, chaque choix complet (libellé, prix, sens, humeur)",
		(d["cartes"] as Dictionary).size() == 16 and (d["creneaux"] as Array).size() == 10 and ok_choix)
	var prix := {"C02": 5500, "C04": 2200, "C07": 2500}
	var ok_prix := true
	for id in prix:
		if int(d["cartes"][id]["a"]["prix_F"]) != prix[id]:
			ok_prix = false
	verifier("D12 : prix retenus du banquier (C02 5 500 F, C04 2 200 / 3 800 F, C07 2 500 F, C09 location 600 F)",
		ok_prix and int(d["cartes"]["C04"]["a"]["prix_jumeaux_F"]) == 3800 and int(d["cartes"]["C09"]["b"]["prix_F"]) == 600)


## Lot 04 (D3, D4, CA-L4) : répliques de docs/23 G1.2, aucun chiffre hors gabarits, C10, bulles, ligne après C14.
func _tests_textes_lot04(d: Dictionary) -> void:
	var rx_gab := RegEx.create_from_string("\\{[^}]*\\}")
	var rx_chiffre := RegEx.create_from_string("\\d")
	var nb := 0
	var ok_mots := true
	var ok_chiffres := true
	var detail := ""
	for id: String in d["cartes"]:
		var c: Dictionary = d["cartes"][id]
		for k in ["a", "b"]:
			if c[k].has("replique"):
				nb += 1
				var n := Banquier.nb_mots(str(c[k]["replique"]))
				if n < 2 or n > 10:
					ok_mots = false
					detail += "%s %s : %d mots ; " % [id, k, n]
		for cle in ["texte", "texte_jumeaux", "pourquoi"]:
			if c.has(cle) and rx_chiffre.search(rx_gab.sub(str(c[cle]), "", true)) != null:
				ok_chiffres = false
				detail += "%s %s : chiffre ; " % [id, cle]
		for k in ["a", "b"]:
			if c[k].has("replique") and rx_chiffre.search(rx_gab.sub(str(c[k]["replique"]), "", true)) != null:
				ok_chiffres = false
				detail += "%s %s réplique : chiffre ; " % [id, k]
	verifier("CA-L4 : 32 répliques de Sylvie (docs/23 G1.2), chacune de 2 à 10 mots (docs/23 G1.2 en annonce 8 : C10 b et C12 b en font 9)", nb == 32 and ok_mots, "%d répliques ; %s" % [nb, detail])
	verifier("CA-L4 : aucun chiffre hors gabarits {…} dans texte, texte_jumeaux, pourquoi, replique", ok_chiffres, detail)
	var e := _nouvelle(7)
	e.enfants = 1
	var c10: Dictionary = d["cartes"]["C10"]
	verifier("CA-L4 : C10 : requiert_enfant, texte_jumeaux (docs/23 G1.5) ; bulle « Sylvie se radoucit » en remontant de fâchée ; gabarit consequence_revenu",
		bool(c10.get("requiert_enfant", false)) and c10.has("texte_jumeaux") and str(d["notif_humeur"]["neutre"]) == "Sylvie se radoucit"
		and str(d["gabarits"]["consequence_revenu"]).contains("{montant}") and str(d["gabarits"]["consequence_revenu"]).contains("{replique}"))
	# C14 « Tout vendre » : « + 1 200 F sur votre compte. « Pas mon fauteuil ! » »
	e.modale = {"kind": "carte", "id": "C14", "creneau": "S9", "m": e.m, "prio": 6, "source": "maison"}
	var r := e.resoudre_modale("a")
	var att := "+ %s sur votre compte. « Pas mon fauteuil ! »" % Format.entier(Produits.f(1200.0), e.ab_courant())
	verifier("CA-L4 : C14 « a » : conséquence « + 1 200 F sur votre compte. « Pas mon fauteuil ! » » (montant au format)", str(r.get("consequence", "")) == att, str(r.get("consequence", "")))

# ---------------------------------------------------------------------
# CA-FO7 : humeur
# ---------------------------------------------------------------------

func _tests_humeur() -> void:
	var e := _nouvelle(7)
	var attendu := {-3: 2, -2: 2, -1: 1, 0: 1, 1: 1, 2: 0, 3: 0}
	var ok := true
	for h in attendu:
		e.foyer["humeur"] = h
		if e.humeur_visible() != attendu[h]:
			ok = false
	verifier("CA-FO7 : humeur_visible suit les seuils (≥ 2 contente = 0, ≤ −2 fâchée = 2, sinon neutre = 1)", ok)
	e.foyer["humeur"] = 0
	var n1 := []
	Foyer._regler_humeur(e, 1, "x", n1)
	var n2 := []
	Foyer._regler_humeur(e, 2, "Agadir, quel rêve !", n2)
	var n3 := []
	Foyer._regler_humeur(e, 5, "", n3)
	var n4 := []
	Foyer._regler_humeur(e, 1, "", n4)
	var n5 := []
	Foyer._regler_humeur(e, -2, "Encore Palavas…", n5)
	verifier("CA-FO7 : notification « humeur » seulement quand l'état visible change (bornée à +3), titre, bulle, source maison",
		n1.is_empty() and n2.size() == 1 and n2[0]["titre"] == "Sylvie est ravie" and n2[0]["humeur"] == 0 and n2[0]["bulle"] and n2[0]["source"] == "maison"
		and n3.is_empty() and int(e.foyer["humeur"]) == -2 and n4.size() == 1 and n4[0]["titre"] == "Sylvie va bien" and n5.size() == 1 and n5[0]["titre"] == "Sylvie fait la tête",
		str([n2, n4, n5]))
	verifier("CA-FO7 : humeur_phrase et derniere_cause_humeur (≤ 10 mots)",
		e.humeur_phrase() == "Sylvie fait la tête" and e.derniere_cause_humeur() == "Encore Palavas…")
	# Usure du 1er janvier sur le positif seulement (D15) ; parties sans cartes : rien d'autre ne bouge l'humeur en 1984
	var f := _nouvelle(7, false)
	f.foyer["humeur"] = 3
	StrategieTest.aller_a(f, Dates.lire("1985-01"), false)
	var g := _nouvelle(7, false)
	g.foyer["humeur"] = -2
	StrategieTest.aller_a(g, Dates.lire("1985-01"), false)
	verifier("Humeur (D15) : usure d'un pas vers 0 le 1er janvier pour une humeur positive (+3 → +2), aucune pour une négative (−2 reste −2)",
		int(f.foyer["humeur"]) == 2 and int(g.foyer["humeur"]) == -2, "%d, %d" % [int(f.foyer["humeur"]), int(g.foyer["humeur"])])


# ---------------------------------------------------------------------
# CA-FO3, FO4, FO5 (conséquence), FO6 (diversité) : parties complètes, cartes allumées
# ---------------------------------------------------------------------

func _tests_parties() -> void:
	var ok_fachee := true
	var ok_c00 := true
	var ok_payable := true
	var ok_miroir := true
	var ok_c06 := true
	var ok_cons := true
	var ok_refus := true
	var nb_refus := 0
	var nb_cons := 0
	var detail := ""
	var detail_c00 := ""
	var detail_miroir := ""
	var graines_c00 := {}
	var sans_c00 := {}
	var jeux := {}
	var fins_fachees := {}
	var plus_long := {}
	var alertes := []
	for politique in ["epargner", "depenser", "alterner"]:
		graines_c00[politique] = 0
		sans_c00[politique] = []
		fins_fachees[politique] = 0
		plus_long[politique] = 0
		for g in range(1, 41):
			StrategieTest.politique_cartes = politique
			var e := _nouvelle(g)
			var fachee := false
			var garde := 0
			var dernier_m := -1
			var serie := 0
			var serie_max := 0
			while e.fin == "" and garde < 200:
				garde += 1
				if e.humeur_visible() == 2:
					fachee = true
				if e.m != dernier_m:
					dernier_m = e.m
					serie = serie + 1 if e.humeur_visible() == 2 else 0
					serie_max = maxi(serie_max, serie)
				if e.modale.get("kind", "") == "carte":
					var c := e.contenu_modale()
					var choix := Foyer.choix_politique(e, politique)
					var dispo := Foyer.disponible(e)
					if c["id"] == "C00" and e.humeur_visible() != 2:
						ok_c00 = false
						detail_c00 += "g%d : C00 sans que Sylvie soit fâchée ; " % g
					# Refus d'un choix désactivé (s'il y en a un)
					for x: Dictionary in c["choix"]:
						if x["desactive"]:
							nb_refus += 1
							var cc0 := e.joueur.cc
							if not e.resoudre_modale(x["id"]).is_empty() or e.modale.is_empty() or e.joueur.cc != cc0:
								ok_refus = false
					var t0 := {}
					for k in e.temoins:
						t0[k] = e.temoins[k].cc
					var a := e.ab_courant()
					var r := e.resoudre_modale(choix)
					if r.is_empty():
						ok_payable = false
						break
					var mt := float(r["montant"])
					if mt < 0.0 and dispo + mt < -0.005:
						ok_payable = false
					if Foyer.disponible(e) < -0.005 and dispo + mt >= 0.0:
						ok_payable = false
					for k in e.temoins:
						var dt := float(e.temoins[k].cc) - float(t0[k])
						var att := 0.0 if c["type"] == "placement" else mt
						if absf(dt - att) > 1e-6:
							ok_miroir = false
							detail_miroir += "g%d %s : témoin %s %.2f F au lieu de %.2f F ; " % [g, c["id"], k, dt * F, att * F]
					if c["type"] == "conso" and mt < 0.0:
						nb_cons += 1
						var taux := Marche.taux_livret(a)
						var vf := -mt * pow(1.0 + taux / 100.0, float(e.m_fin - e.m) / 12.0)
						if not str(r["consequence"]).contains(Format.entier(vf, a)) or not str(r["consequence"]).contains(Banquier.taux_txt(taux) + Format.ESPACE + "%"):
							ok_cons = false
							detail += "%s : %s ; " % [c["id"], r["consequence"]]
					continue
				StrategieTest.jouer_mois(e, true)
				while not e.modale.is_empty() and e.modale.get("kind", "") != "carte":
					e.resolution_auto()
				if e.modale.is_empty():
					e.avancer()
			if e.humeur_visible() == 2:
				fins_fachees[politique] = int(fins_fachees[politique]) + 1
			plus_long[politique] = maxi(int(plus_long[politique]), serie_max)
			if politique == "alterner" and serie_max > 24:
				alertes.append("    ALERTE humeur alterner graine=%d mois=%d" % [g, serie_max])
			var jouees := e.cartes_jouees()
			var ids := jouees.map(func(x: Dictionary) -> String: return str(x["id"]))
			jeux["%s %d" % [politique, g]] = ids
			var c00 := ids.count("C00")
			var cr := jouees.filter(func(x: Dictionary) -> bool: return x["id"] == "C00").map(func(x: Dictionary) -> String: return str(x["creneau"]))
			var suite := false
			for i in range(1, jouees.size()):
				if jouees[i]["id"] == "C00" and jouees[i - 1]["id"] == "C00":
					suite = true
			if c00 > 0:
				graines_c00[politique] = int(graines_c00[politique]) + 1
			else:
				(sans_c00[politique] as Array).append(g)
			if c00 > 2 or cr.has("S4") or suite:
				ok_c00 = false
				detail_c00 += "%s g%d : C00 %d fois %s %s ; " % [politique, g, c00, str(cr), str(ids)]
			if politique == "epargner" and (not fachee or c00 == 0):
				ok_fachee = false
			if ids.has("C06"):
				var c06 := jouees.filter(func(x: Dictionary) -> bool: return x["id"] == "C06")[0] as Dictionary
				var esc := e.historique.filter(func(h: Dictionary) -> bool: return h["type"] == "escargots")
				if c06["choix"] == "a" and (esc.size() != 1 or int(esc[0]["m"]) != int(c06["m"]) + 9 or absf(float(esc[0]["montant"]) * F - 800.0) > 0.01):
					ok_c06 = false
				if c06["choix"] == "b" and not esc.is_empty():
					ok_c06 = false
	for politique in graines_c00:
		print("    MESURE C00 (%s) : C00 jouée dans %d graines sur 40 ; sans C00 : %s ; finissent fâchées : %d ; plus long séjour fâché : %d mois" % [politique, int(graines_c00[politique]), str(sans_c00[politique]), int(fins_fachees[politique]), int(plus_long[politique])])
	for al: String in alertes:
		print(al)
	verifier("CA-FO3 : « epargner » rend Sylvie fâchée au moins une fois et déclenche C00, dans 40 graines sur 40 (D15)",
		ok_fachee and int(graines_c00["epargner"]) == 40, "%d / 40" % int(graines_c00["epargner"]))
	verifier("CA-FO3 (règles de C00, 3 politiques) : seulement si Sylvie est fâchée, 2 fois au plus, jamais deux créneaux de suite, jamais en S4",
		ok_c00, detail_c00.left(600))
	verifier("CA-FO3 : « depenser » : compte + Livret A jamais sous 0 à cause d'une carte (choix non payable désactivé)", ok_payable)
	verifier("CA-FO3 : un choix désactivé est refusé par resoudre_modale (renvoie {}, la carte reste ouverte, rien n'est payé)", ok_refus, "%d refus essayés" % nb_refus)
	verifier("CA-FO4 (R-MIROIR) : après chaque carte conso ou revenu, les 3 témoins ont le même mouvement le même mois (au centime) ; après C06, aucun", ok_miroir, detail_miroir.left(400))
	verifier("CA-FO5 : C06 prêtée → notification « escargots » à + 9 mois, 800 F rendus ; refusée → rien", ok_c06)
	verifier("CA-FO5 : ligne de conséquence au franc près (taux du Livret A du mois, mois restants jusqu'à la fin)", ok_cons and nb_cons > 100, "%d lignes vérifiées" % nb_cons)
	# CA-FO6 : au moins 2 cartes différentes entre deux graines, sur 10 graines
	var ok_div := true
	for g in range(1, 10):
		var x: Array = jeux["depenser %d" % g]
		var y: Array = jeux["depenser %d" % (g + 1)]
		var diff := 0
		for id in x:
			if not y.has(id):
				diff += 1
		if diff < 1 and x == y:
			ok_div = false
	var tous := {}
	for k in jeux:
		for id in jeux[k]:
			tous[id] = int(tous.get(id, 0)) + 1
	var differentes := 0
	for g in range(1, 11):
		for h in range(g + 1, 11):
			if jeux["depenser %d" % g] != jeux["depenser %d" % h]:
				differentes += 1
	verifier("CA-FO6 : sur 10 graines, des parties différentes (au moins 2 cartes différentes entre deux graines)", differentes > 0 and ok_div, "%d paires différentes sur 45 ; cartes jouées (120 parties) %s" % [differentes, str(tous)])
	# Fâchée « epargner » et C00 : rappel de la mesure
	var ex: Array = jeux["epargner 7"]
	print("    Graine 7 epargner : ", ex, " · depenser : ", jeux["depenser 7"])


# ---------------------------------------------------------------------
# CA-FO7 : contrat de la modale, de la résolution, de l'historique
# ---------------------------------------------------------------------

func _tests_contrat() -> void:
	var e := _nouvelle(7)
	var ok := _jusqu_a_carte(e)
	var c := e.contenu_modale()
	var cles := ["kind", "source", "date", "ab", "id", "creneau", "titre", "texte", "type", "disponible", "choix"]
	var cles_choix := ["id", "titre", "montant", "humeur", "picto", "desactive", "manque", "sous"]
	var ok_cles := c.size() == cles.size() and c.has_all(cles) and (c["choix"] as Array).size() == 2
	for ch: Dictionary in c.get("choix", []):
		if ch.size() != cles_choix.size() or not ch.has_all(cles_choix) or not ch["picto"] in ["contente", "neutre", "fachee"]:
			ok_cles = false
	verifier("CA-FO7 : contenu_modale() d'une carte : exactement les champs du contrat (§5.3 bis), 2 choix",
		ok and ok_cles and c["kind"] == "carte" and c["source"] == "maison" and c["type"] in ["conso", "placement", "revenu"], str(c.keys()))
	var avant := e.humeur_visible()
	var r := e.resoudre_modale(Foyer.choix_auto(e))
	verifier("CA-FO7 : resoudre_modale → {choix, kind, montant, consequence, humeur_avant, humeur_apres} (+ notifs)",
		r.has_all(["choix", "kind", "montant", "consequence", "humeur_avant", "humeur_apres"]) and r["kind"] == "carte" and int(r["humeur_avant"]) == avant
		and int(r["humeur_apres"]) == e.humeur_visible() and e.modale.is_empty())
	var h: Array = e.historique.filter(func(x: Dictionary) -> bool: return x["genre"] == "carte")
	verifier("CA-FO7 : historique genre « carte », source maison, titre, libellé du choix, montant, ligne de conséquence",
		h.size() == 1 and h[0]["source"] == "maison" and h[0]["titre"] == c["titre"] and h[0]["choix"] != "" and h[0]["a_montant"]
		and absf(float(h[0]["montant"]) - float(r["montant"])) < 1e-9 and str(h[0]["contenu"]["consequence"]) == str(r["consequence"]), str(h))
	var j := e.cartes_jouees()
	verifier("CA-FO7 : cartes_jouees() : {id, creneau, titre, choix, libelle, montant, humeur_effet, picto, m, ab}",
		j.size() == 1 and (j[0] as Dictionary).has_all(["id", "creneau", "titre", "choix", "libelle", "montant", "humeur_effet", "picto", "m", "ab"]) and j[0]["id"] == c["id"])
	var liste: Array = e.banque["interruptions_liste"]
	verifier("Créneaux : la carte est une interruption de Cadence (catégorie « cartes », rang 6, non datée), hors du compteur des classiques",
		int(e.banque["compteurs"]["cartes"]) == 1 and liste[-1]["kind"] == "carte" and float(liste[-1]["rang"]) == 6.0 and not liste[-1]["datee"]
		and int(e.banque["interruptions"]) == int(e.banque["compteurs"]["classiques"]))


# ---------------------------------------------------------------------
# CA-FO4 : cours du soir (C07), salaire + 4 % pour le joueur et les témoins
# ---------------------------------------------------------------------

func _tests_salaire() -> void:
	var trouve := false
	for g in range(1, 41):
		var e := _nouvelle(g)
		if not _jusqu_a_carte(e, "epargner", "C07"):
			e = _nouvelle(g)
			if not _jusqu_a_carte(e, "depenser", "C07"):
				continue
		trouve = true
		e.joueur.cc += Produits.f(10000.0)   # les deux choix sont payables quelle que soit la politique qui a mené ici
		var b := EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(e.vers_dict())))
		e.resoudre_modale("a")
		b.resoudre_modale("b")
		StrategieTest.aller_a(e, Dates.lire("1987-12"), false)
		StrategieTest.aller_a(b, Dates.lire("1987-12"), false)
		var avant := e.salaire_base / b.salaire_base
		var t_e: float = e.temoins["matelas"].cc
		var t_b: float = b.temoins["matelas"].cc
		StrategieTest.aller_a(e, Dates.lire("1988-01"), false)
		StrategieTest.aller_a(b, Dates.lire("1988-01"), false)
		var gain_e: float = e.temoins["matelas"].cc - t_e
		var gain_b: float = b.temoins["matelas"].cc - t_b
		verifier("CA-FO4 : C07 choisie : salaire + 4 % dès janvier 1988 (pas avant), le même pour les témoins (salaire commun)",
			is_equal_approx(avant, 1.0) and absf(e.salaire_base / b.salaire_base - 1.04) < 1e-9 and gain_e > gain_b,
			"graine %d, rapport %.4f, épargne du mois de Tonton Matelas %.0f F contre %.0f F" % [g, e.salaire_base / b.salaire_base, gain_e * F, gain_b * F])
		break
	if not trouve:
		verifier("CA-FO4 : C07 tirée dans au moins une graine", false)


# ---------------------------------------------------------------------
# CA-FO5 : escargots, 100 % des graines où C06 est prêtée
# ---------------------------------------------------------------------

func _tests_escargots() -> void:
	var nb := 0
	var ok := true
	for g in range(1, 41):
		var e := _nouvelle(g)
		if not _jusqu_a_carte(e, "epargner", "C06"):
			ok = false
			continue
		e.joueur.cc += Produits.f(10000.0)
		var m0 := e.m
		var t0: float = e.temoins["livret"].cc
		e.resoudre_modale("a")
		nb += 1
		var miroir_ok := absf(e.temoins["livret"].cc - t0) < 1e-9
		var notif := {}
		var garde := 0
		while e.fin == "" and notif.is_empty() and garde < 30:
			garde += 1
			StrategieTest.jouer_mois(e, false)
			while not e.modale.is_empty():
				e.resolution_auto()
			var r := e.avancer()
			for n: Dictionary in r["notifs"]:
				if n.get("type", "") == "escargots":
					notif = n
					notif["m"] = e.m
		if notif.is_empty() or int(notif["m"]) != m0 + 9 or absf(float(notif["montant"]) * F - 800.0) > 0.01 or not notif.get("persistant", false) or notif.has("persistante") \
				or notif["source"] != "maison" or notif["cls"] != "perte" or not miroir_ok:
			ok = false
	verifier("CA-FO5 (CA-2.4) : C06 prêtée → notification persistante « escargots » à + 9 mois, 800 F rendus, dans 100 % des graines (40)", ok and nb == 40, "%d prêts" % nb)


# ---------------------------------------------------------------------
# CA-FO6 : sauvegarde, migration, tirages
# ---------------------------------------------------------------------

func _tests_sauvegarde() -> void:
	var e := _nouvelle(11)
	_jusqu_a_carte(e, "depenser")
	Sauvegarde.ecrire(e, {}, _chemin())
	var b := Sauvegarde.charger(Sauvegarde.lire(_chemin()))
	var c1 := e.contenu_modale()
	var c2 := b.contenu_modale() if b != null else {}
	var choix := Foyer.choix_politique(e, "depenser")
	e.resoudre_modale(choix)
	b.resoudre_modale(choix)
	verifier("CA-FO6 (CA-2.7) : carte ouverte, sauvegarde, reprise : la même carte se rouvre, un seul paiement",
		var_to_str(c1) == var_to_str(c2) and e.joueur.cc == b.joueur.cc and e.joueur.livret == b.joueur.livret and b.cartes_jouees().size() == e.cartes_jouees().size(),
		"%s %s" % [c1.get("id", ""), c1.get("creneau", "")])
	# Sauvegarde de la 0.4 : sans champ foyer, même si la configuration demandait les cartes
	var d := _nouvelle(7).vers_dict()
	d.erase("foyer")
	var v := EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(d)))
	var cartes_vues := 0
	var garde := 0
	while v != null and v.fin == "" and garde < 200:
		garde += 1
		if v.modale.get("kind", "") == "carte":
			cartes_vues += 1
		while not v.modale.is_empty():
			v.resolution_auto()
		v.avancer()
	verifier("CA-FO6 : sauvegarde sans champ foyer (0.4) : rechargée, cartes éteintes, va jusqu'à la fin",
		v != null and not v.cartes_actives() and v.fin == "fin" and cartes_vues == 0)
	# Tirages existants identiques, cartes allumées ou non
	var ok := true
	for g in range(1, 41):
		var x := _nouvelle(g, true)
		var y := _nouvelle(g, false)
		if var_to_str(x.calendrier) != var_to_str(y.calendrier):
			ok = false
	verifier("CA-FO6 : tirages existants (calendrier de vie, naissance) identiques cartes allumées ou éteintes (40 graines)", ok)
