extends SceneTree
## Tests du lot 07-L : titres d'époque (docs/28), natures des choix de cartes, grandeurs, une stratégie par titre.
## CA-T2 (9 titres atteints, lignes « TITRE … »), CA-T3 (réaliser un projet n'abaisse jamais le rang), CA-T4 (pédagogie),
## CA-T5 (conditions aux bornes sur grandeurs fabriquées, humeur 0 = contente, 2 = fâchée), CA-T6 (natures, mesure NATURES).
## Logique pure, aucun fichier user:// ; l'écriture du record est testée par test_records.
## Lancer : Godot_console --headless --path godot --script res://tests/test_titres.gd

var _ok := 0
var _ko := 0

## docs/28 §2, recopié : carte -> [nature du choix a, nature du choix b].
const NATURES := {
	"C00": ["depense", "epargne"], "C01": ["depense", "epargne"], "C02": ["depense", "epargne"], "C03": ["depense", "epargne"],
	"C04": ["depense", "epargne"], "C05": ["depense", "epargne"], "C06": ["neutre", "neutre"], "C07": ["neutre", "neutre"],
	"C08": ["depense", "epargne"], "C09": ["depense", "epargne"], "C10": ["depense", "epargne"], "C11": ["depense", "epargne"],
	"C12": ["depense", "epargne"], "C13": ["depense", "epargne"], "C14": ["epargne", "neutre"], "C15": ["depense", "epargne"]}

## Graine de chaque stratégie dédiée (une graine fixe qui atteint le titre ; les autres graines sont mesurées par test_titres_mesures).
const GRAINES := {"bon_pere": 3, "golden_boy": 1, "escargots": 1, "fourmi": 1, "cigale": 1, "marin": 1, "neveu_matelas": 1,
	"ecureuil": 1, "apprenti": 2}


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_donnees()
	_tests_conditions()
	_tests_grandeurs()
	_tests_strategies()
	_tests_rang()
	_tests_natures_mesure()
	print("")
	print("=== test_titres : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _config(g: int) -> Dictionary:
	var c := Donnees.config_demo(g)
	c["cartes"] = true
	c["projets"] = true
	c["rue"] = true
	return c


func _nouvelle(g: int) -> EtatPartie:
	var e := EtatPartie.new()
	e.demarrer(_config(g))
	return e


func _jouer(g: int, profil: Dictionary) -> EtatPartie:
	var e := _nouvelle(g)
	StrategieTest.jouer_partie_profil(e, profil)
	return e


func _mots(t: String) -> int:
	var n := 0
	for m in t.replace(" ", " ").split(" ", false):
		var alnum := false
		for ch in m:
			if ch.to_upper() != ch.to_lower() or (ch >= "0" and ch <= "9"):
				alnum = true
		if alnum:
			n += 1
	return n


# ---------------------------------------------------------------------
# Données : titres.json et natures
# ---------------------------------------------------------------------

func _tests_donnees() -> void:
	var tous := Titres.tous()
	var ids := tous.map(func(t: Dictionary) -> String: return str(t["id"]))
	verifier("CA-T4/D1 : 9 titres, dans l'ordre de docs/28 §1.2 (neveu 7e, écureuil 8e)",
		ids == ["bon_pere", "golden_boy", "escargots", "fourmi", "cigale", "marin", "neveu_matelas", "ecureuil", "apprenti"]
		and int(tous[6]["ordre"]) == 7 and int(tous[7]["ordre"]) == 8, str(ids))
	var interdits := ["achetez", "vendez", "c'est le moment", "auriez dû", "vous auriez", "renforcez"]
	var texte_tout := ""   # textes affichés seulement (les commentaires « _… » citent les mots interdits)
	for t: Dictionary in Titres.donnees()["titres"]:
		texte_tout += (str(t["nom"]) + " " + str(t["pourquoi"]) + " ").to_lower()
	for k in Titres.donnees()["objectif"]:
		texte_tout += str(Titres.donnees()["objectif"][k]).to_lower() + " "
	var sans_interdit := true
	for mot: String in interdits:
		if texte_tout.contains(mot):
			sans_interdit = false
	verifier("CA-T4 : titres.json ne contient ni « achetez », ni « vendez », ni « c'est le moment », ni « auriez dû »", sans_interdit)
	var noms_sans_chiffre := true
	var pourquoi_courts := true
	var pires := 0
	for t: Dictionary in Titres.donnees()["titres"]:
		for ch in str(t["nom"]):
			if ch >= "0" and ch <= "9":
				noms_sans_chiffre = false
		pires = maxi(pires, _mots(str(t["pourquoi"])))
		if _mots(str(t["pourquoi"])) > 15 or str(t["pourquoi"]) == "":
			pourquoi_courts = false
	verifier("CA-T4 : noms sans chiffre", noms_sans_chiffre)
	verifier("CA-T4 : « pourquoi » de 15 mots au plus", pourquoi_courts, "maximum %d" % pires)
	var o: Dictionary = Titres.donnees()["objectif"]
	verifier("D9 : deux phrases de l'inflation, factuelles, sans étoile ni « vous auriez dû »",
		str(o["atteint"]) != "" and str(o["non_atteint"]) != "" and not (str(o["atteint"]) + str(o["non_atteint"])).to_lower().contains("étoile")
		and not (str(o["atteint"]) + str(o["non_atteint"])).to_lower().contains("auriez"))
	# CA-T6 : natures
	var nb := 0
	var egal := true
	var valides := true
	var detail := ""
	var cartes: Dictionary = Foyer.donnees()["cartes"]
	for id: String in NATURES:
		for i in 2:
			var k: String = ["a", "b"][i]
			var nat := str(cartes[id][k].get("nature", ""))
			nb += 1
			if not (nat in ["epargne", "depense", "neutre"]):
				valides = false
			if nat != NATURES[id][i]:
				egal = false
				detail += "%s %s=%s ; " % [id, k, nat]
	verifier("CA-T6 : 16 cartes, 32 choix, chacun avec une nature valide", cartes.size() == 16 and nb == 32 and valides)
	verifier("CA-T6 : natures == tableau de docs/28 §2 (C06 et C07 neutres ; C14 a = épargne, b = neutre)", egal, detail)
	var p := Titres.parametres()
	verifier("D2 : paramètres de docs/28 §1.2 (cartes_min est celui de la mesure D3 : 5, ou 4 si elle l'exige)",
		is_equal_approx(float(p["ecart_min"]), 0.075) and is_equal_approx(float(p["part_risquee"]), 0.30) and int(p["cartes_ecart"]) == 3
		and is_equal_approx(float(p["cc_moyen_min"]), 0.60) and is_equal_approx(float(p["marin_ligne_max"]), 0.60) and p["produits_surs"] == ["livret", "pel"] and is_equal_approx(float(p["vente_apres_krach"]), 0.50)
		and int(p["cartes_min"]) in [4, 5])


# ---------------------------------------------------------------------
# CA-T5 : evaluer sur grandeurs fabriquées
# ---------------------------------------------------------------------

## Grandeurs d'un joueur « apprenti » (aucune condition vraie), modifiées par m.
func _g(m := {}) -> Dictionary:
	var g := {"ecart_tata": 0.0, "projets_realises": 1, "humeur_fin": 1, "abandon_evitable": false, "part_risquee_krach": 0.0,
		"a_vendu_krach": false, "escargots": false, "nb_epargne": 3, "nb_depense": 3, "produits_detenus": ["livret", "sicav"], "cc_moyen": 0.10}
	g.merge(m, true)
	return g


func _titre(m := {}) -> String:
	return str(Titres.evaluer(_g(m))["id"])


func _tests_conditions() -> void:
	verifier("Base fabriquée : aucune condition vraie -> apprenti", _titre() == "apprenti")
	# 1 bon père
	var bp := {"ecart_tata": 0.10, "projets_realises": 2, "humeur_fin": 1}
	verifier("1 bon_pere : écart 10 %, 2 projets, humeur neutre", _titre(bp) == "bon_pere")
	verifier("1 bon_pere : écart 0,075 pile = non (strictement supérieur)", _titre({"ecart_tata": 0.075, "projets_realises": 2}) != "bon_pere")
	verifier("1 bon_pere : 0,0751 = oui", _titre({"ecart_tata": 0.0751, "projets_realises": 2}) == "bon_pere")
	verifier("1 bon_pere : un seul projet = non ; humeur fâchée (2) = non ; contente (0) = oui",
		_titre({"ecart_tata": 0.10, "projets_realises": 1}) != "bon_pere" and _titre({"ecart_tata": 0.10, "projets_realises": 2, "humeur_fin": 2}) != "bon_pere"
		and _titre({"ecart_tata": 0.10, "projets_realises": 2, "humeur_fin": 0}) == "bon_pere")
	# 2 golden boy, 6 marin : le même seuil de 30 %
	verifier("2 golden_boy : part 0,30 pile et vente = oui ; 0,2999 = non",
		_titre({"part_risquee_krach": 0.30, "a_vendu_krach": true}) == "golden_boy" and _titre({"part_risquee_krach": 0.2999, "a_vendu_krach": true}) != "golden_boy")
	verifier("2 golden_boy : a vendu mais n'avait pas 30 % -> pas golden_boy, pas marin",
		_titre({"part_risquee_krach": 0.10, "a_vendu_krach": true, "ecart_tata": 0.05}) == "apprenti")
	verifier("2 > 1 : « bon père » l'emporte sur « golden boy » (le titre juge la partie entière)",
		_titre({"ecart_tata": 0.10, "projets_realises": 2, "part_risquee_krach": 0.5, "a_vendu_krach": true}) == "bon_pere")
	verifier("6 marin : 0,30 pile, n'a pas vendu, écart > 0 ; écart 0 pile = non",
		_titre({"part_risquee_krach": 0.30, "ecart_tata": 0.001}) == "marin" and _titre({"part_risquee_krach": 0.30, "ecart_tata": 0.0}) != "marin")
	verifier("6 marin : vendre ne le donne jamais (a_vendu_krach -> golden_boy, pas marin)",
		_titre({"part_risquee_krach": 0.5, "a_vendu_krach": true, "ecart_tata": 0.1}) == "golden_boy")
	# lot 08b : marin_ligne_max (concentration), cigale_min / cigale_ecart, bon_pere_humeur (paramètres facultatifs)
	var m := {"part_risquee_krach": 0.5, "ecart_tata": 0.01}
	verifier("6 marin (08b) : plus grosse ligne 0,60 pile = oui ; 0,61 = non (tout sur une action) ; 0 (SICAV seule) = oui",
		_titre(m.merged({"ligne_max_krach": 0.60})) == "marin" and _titre(m.merged({"ligne_max_krach": 0.61})) != "marin" and _titre(m.merged({"ligne_max_krach": 0.0})) == "marin")
	var p := Titres.parametres()
	var sauve := p.duplicate(true)
	p["cigale_min"] = 4
	p["cigale_ecart"] = 2
	var cig := _titre({"nb_depense": 4, "nb_epargne": 2, "humeur_fin": 0}) == "cigale"
	p.erase("cigale_min")
	p.erase("cigale_ecart")
	var cig_avant := _titre({"nb_depense": 4, "nb_epargne": 2, "humeur_fin": 0}) != "cigale"
	p["bon_pere_humeur"] = "contente"
	var bp_c := _titre({"ecart_tata": 0.10, "projets_realises": 2, "humeur_fin": 1}) != "bon_pere" and _titre({"ecart_tata": 0.10, "projets_realises": 2, "humeur_fin": 0}) == "bon_pere"
	p.erase("bon_pere_humeur")
	for k in sauve:
		p[k] = sauve[k]
	verifier("08b : cigale_min / cigale_ecart propres à la cigale (absents = cartes_min / cartes_ecart) ; bon_pere_humeur « contente » exige l'humeur contente", cig and cig_avant and bp_c)
	# 3 escargots
	verifier("3 escargots : prêté et écart < 0 = oui ; écart 0 pile = non ; écart > 0 = non",
		_titre({"escargots": true, "ecart_tata": -0.001}) == "escargots" and _titre({"escargots": true, "ecart_tata": 0.0}) != "escargots"
		and _titre({"escargots": true, "ecart_tata": 0.05}) != "escargots")
	# 4 fourmi, 5 cigale : seuils 5 et écart 3
	var f := {"nb_epargne": 5, "nb_depense": 2, "humeur_fin": 2}
	verifier("4 fourmi : 5 épargnes, écart 3, fâchée = oui", _titre(f) == "fourmi")
	verifier("4 fourmi : 4 épargnes (écart 3 pourtant) = non", _titre({"nb_epargne": 4, "nb_depense": 1, "humeur_fin": 2}) != "fourmi")
	verifier("4 fourmi : 5 épargnes mais écart 2 = non", _titre({"nb_epargne": 5, "nb_depense": 3, "humeur_fin": 2}) != "fourmi")
	verifier("4 fourmi : humeur neutre sans abandon évitable = non ; avec abandon évitable = oui",
		_titre({"nb_epargne": 5, "nb_depense": 2, "humeur_fin": 1}) != "fourmi" and _titre({"nb_epargne": 5, "nb_depense": 2, "humeur_fin": 1, "abandon_evitable": true}) == "fourmi")
	verifier("5 cigale : 5 dépenses, écart 3, contente (0) = oui ; 4 dépenses = non ; écart 2 = non",
		_titre({"nb_depense": 5, "nb_epargne": 2, "humeur_fin": 0}) == "cigale" and _titre({"nb_depense": 4, "nb_epargne": 1, "humeur_fin": 0}) != "cigale"
		and _titre({"nb_depense": 5, "nb_epargne": 3, "humeur_fin": 0}) != "cigale")
	verifier("Humeur : 0 = contente, 2 = fâchée (la cigale exige 0, la fourmi accepte 2)",
		_titre({"nb_depense": 6, "nb_epargne": 1, "humeur_fin": 0}) == "cigale" and _titre({"nb_depense": 6, "nb_epargne": 1, "humeur_fin": 2}) != "cigale"
		and _titre({"nb_depense": 6, "nb_epargne": 1, "humeur_fin": 1}) != "cigale"
		and _titre({"nb_epargne": 6, "nb_depense": 1, "humeur_fin": 2}) == "fourmi" and _titre({"nb_epargne": 6, "nb_depense": 1, "humeur_fin": 0}) != "fourmi")
	# 7 neveu, 8 écureuil
	verifier("7 neveu : cc_moyen 0,60 pile = oui ; 0,5999 = non", _titre({"cc_moyen": 0.60}) == "neveu_matelas" and _titre({"cc_moyen": 0.5999}) != "neveu_matelas")
	verifier("7 avant 8 : compte courant seul (aucun produit) -> neveu_matelas, pas écureuil",
		_titre({"cc_moyen": 0.95, "produits_detenus": []}) == "neveu_matelas")
	verifier("8 écureuil : livret et PEL seuls = oui ; avec un autre produit = non",
		_titre({"produits_detenus": ["livret", "pel"]}) == "ecureuil" and _titre({"produits_detenus": ["livret"]}) == "ecureuil"
		and _titre({"produits_detenus": ["livret", "pel", "av"]}) == "apprenti" and _titre({"produits_detenus": ["livret", "elf"]}) == "apprenti")
	verifier("Ordre : un titre plus haut prend le pas (escargots avant fourmi, golden avant escargots)",
		_titre({"escargots": true, "ecart_tata": -0.05, "nb_epargne": 6, "nb_depense": 1, "humeur_fin": 2}) == "escargots"
		and _titre({"escargots": true, "ecart_tata": -0.05, "part_risquee_krach": 0.5, "a_vendu_krach": true}) == "golden_boy")
	var t := Titres.evaluer(_g())
	verifier("evaluer renvoie id, nom, pourquoi, ordre", t.keys().size() == 4 and int(t["ordre"]) == 9 and str(t["nom"]) != "" and str(t["pourquoi"]) != "")
	# D2 : calculer ne juge que les parties allées à leur terme
	var e := _nouvelle(1)
	verifier("calculer : {} tant que la partie n'est pas finie", Titres.calculer(e).is_empty())
	e.fin = "faillite"
	verifier("calculer : {} après une faillite ; {} après un abandon", Titres.calculer(e).is_empty() and _abandonnee().is_empty())


func _abandonnee() -> Dictionary:
	var e := _nouvelle(1)
	e.abandonner()
	return Titres.calculer(e)


# ---------------------------------------------------------------------
# Grandeurs relues sur de vraies parties
# ---------------------------------------------------------------------

## Joue (joueur passif ou profil donné) jusqu'à la modale du krach ouverte ; null si elle n'arrive pas.
func _vers_krach(g: int, profil: Dictionary) -> EtatPartie:
	var e := _nouvelle(g)
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		if e.modale.get("kind", "") == "marche" and e._est_krach(e.evenement(str(e.modale["id"]))):
			return e
		StrategieTest.jouer_mois_profil(e, profil)
		e.avancer()
	return null


func _clone(e: EtatPartie) -> EtatPartie:
	return EtatPartie.depuis_dict(e.vers_dict())


func _vers_mois(e: EtatPartie, d: String, profil: Dictionary) -> void:
	var garde := 0
	while e.fin == "" and e.ab_courant() < Dates.lire(d) and garde < 100:
		garde += 1
		StrategieTest.jouer_mois_profil(e, profil)
		e.avancer()


func _tests_grandeurs() -> void:
	var passif := {"ouvrir": [], "cartes": "epargner"}
	var bourse: Dictionary = (StrategieTest.PROFILS_TITRES["marin"] as Dictionary).duplicate(true)
	# Exemple de krach : joueur sans action ni SICAV -> part risquée 0 (docs/28 §0.5) ; instantané pris même rue éteinte
	var e0 := _vers_krach(1, passif)
	var ok0 := e0 != null
	var inst0: Dictionary = e0.instantane_k if ok0 else {}
	verifier("L2 : instantané du krach pris, avec le patrimoine du joueur, exemple pour un joueur sans action ni SICAV",
		ok0 and not inst0.is_empty() and bool(inst0["exemple"]) and is_equal_approx(float(inst0["patrimoine"]), e0.patrimoine(e0.joueur)))
	verifier("CA-T5 : exemple de krach -> part risquée 0 (même avec 10 000 F de SICAV d'exemple)", ok0 and Titres.part_risquee_krach(e0) == 0.0 and not Titres.a_vendu_krach(e0))
	var eteint := EtatPartie.new()
	var c := _config(1)
	c["rue"] = false
	eteint.demarrer(c)
	var garde := 0
	while eteint.fin == "" and garde < 200 and not (eteint.modale.get("kind", "") == "marche" and eteint._est_krach(eteint.evenement(str(eteint.modale["id"])))):
		garde += 1
		StrategieTest.jouer_mois_profil(eteint, passif)
		eteint.avancer()
	verifier("L2/CA-T8 : rue éteinte : l'instantané est pris (titres), mais instantane_krach() reste vide pour l'interface ; ni notification ni gazette",
		not eteint.instantane_k.is_empty() and eteint.instantane_krach().is_empty() and eteint.mois_gazette() == -1)
	# Joueur investi : part risquée mesurée sur la base de l'instantané
	var e1 := _vers_krach(1, bourse)
	var inst1: Dictionary = e1.instantane_k if e1 != null else {}
	var part := Titres.part_risquee_krach(e1) if e1 != null else -1.0
	verifier("Part risquée = Krach.base(instantané) / patrimoine de l'instantané (joueur investi, pas un exemple)",
		e1 != null and not bool(inst1["exemple"]) and is_equal_approx(part, Krach.base(inst1) / float(inst1["patrimoine"])) and part > 0.3, "%.3f" % part)
	# a_vendu_krach : ordre en 12/1987 > 50 % ; vente forcée (projet, coup dur) non ; vente hors fenêtre non ; petite vente non
	var oui := _clone(e1)
	oui.resoudre_modale("rien")
	_vers_mois(oui, "1987-12", bourse)
	var avant := oui.valeur_risquee(oui.joueur)
	oui.vendre(oui.joueur, "sicav", 0.0, true)
	verifier("CA-T5 : vente par ordre de toute la SICAV en 12/1987 (> 50 % de la valeur au krach) -> a_vendu_krach", avant > 0.0 and Titres.a_vendu_krach(oui), "valeur vendue %.0f / base %.0f" % [avant, Krach.base(oui.instantane_k)])
	var forcee := _clone(e1)
	forcee.resoudre_modale("rien")
	_vers_mois(forcee, "1987-12", bourse)
	forcee.vendre(forcee.joueur, "sicav", 0.0, true, true)
	verifier("CA-T5 : même vente mais forcée (vente automatique d'un projet, coup dur) -> a_vendu_krach faux", not Titres.a_vendu_krach(forcee))
	var petite := _clone(e1)
	petite.resoudre_modale("rien")
	_vers_mois(petite, "1987-12", bourse)
	petite.vendre(petite.joueur, "sicav", 0.2 * Krach.base(petite.instantane_k), false)
	verifier("CA-T5 : vente de 20 % seulement -> a_vendu_krach faux", not Titres.a_vendu_krach(petite))
	var tard := _clone(e1)
	tard.resoudre_modale("rien")
	_vers_mois(tard, "1988-05", bourse)
	tard.vendre(tard.joueur, "sicav", 0.0, true)
	verifier("CA-T5 : vente après la fenêtre (05/1988) -> a_vendu_krach faux", not Titres.a_vendu_krach(tard))
	var choix_vendre := _clone(e1)
	choix_vendre.resoudre_modale("vendre")
	verifier("CA-T5 : choix « Tout vendre » -> a_vendu_krach", Titres.a_vendu_krach(choix_vendre))
	# Abandon évitable
	var ea := _nouvelle(1)
	var profil_p1 := {"projets": "moins_cher", "ouvrir": ["D01"], "livret": true, "jour_j": {"P1": "renoncer"}}
	var evitable := _jusqu_jour_j(ea, profil_p1)
	var ea_ok := evitable
	if ea_ok:
		ea.resoudre_modale("renoncer")
	verifier("CA-T5 : renoncer alors que RÉALISER était actif -> abandon_evitable", ea_ok and bool(Titres.grandeurs(ea)["abandon_evitable"]))
	var eb := _nouvelle(1)
	var eb_ok := _jusqu_jour_j(eb, profil_p1)
	if eb_ok:
		eb.joueur.cc = 0.0
		eb.joueur.livret = 0.0
		eb.joueur.lignes.clear()
		var peut := false
		for x: Dictionary in eb.contenu_modale()["choix"]:
			if str(x["id"]) in ["realiser", "realiser_en_vendant"] and not bool(x["desactive"]):
				peut = true
		eb_ok = not peut
		eb.resoudre_modale("renoncer")
	verifier("CA-T5 : renoncer faute d'argent (RÉALISER et RÉALISER EN VENDANT grisés) -> abandon_evitable faux", eb_ok and not bool(Titres.grandeurs(eb)["abandon_evitable"]))
	# Natures : « aucun » (Pas les moyens) ne compte pas
	var en := _nouvelle(1)
	en.foyer["jouees"] = [{"id": "C01", "choix": "a"}, {"id": "C01", "choix": "aucun"}, {"id": "C02", "choix": "b"}, {"id": "C06", "choix": "a"}, {"id": "C14", "choix": "b"}]
	var nat := Titres.natures_choisies(en)
	verifier("CA-T5 : natures comptées (dépense, épargne, neutres) ; « aucun » ignoré", nat["depense"] == 1 and nat["epargne"] == 1 and nat["neutre"] == 2, str(nat))
	# Humeur : la valeur cachée 3 = contente (0), -3 = fâchée (2)
	en.foyer["humeur"] = 3
	var h0 := int(Titres.grandeurs(en)["humeur_fin"])
	en.foyer["humeur"] = -3
	var h2 := int(Titres.grandeurs(en)["humeur_fin"])
	verifier("Humeur de Sylvie : contente = 0, fâchée = 2 (Foyer.humeur_visible fait foi)", h0 == 0 and h2 == 2)


## Joue (profil) jusqu'à la modale du jour J du projet P1, non résolue.
func _jusqu_jour_j(e: EtatPartie, profil: Dictionary) -> bool:
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		if e.modale.get("kind", "") == "projet" and str(e.modale.get("etape", "")) == "echeance":
			return true
		StrategieTest.jouer_mois_profil(e, profil)
		e.avancer()
	return false


# ---------------------------------------------------------------------
# CA-T2 : une stratégie dédiée par titre
# ---------------------------------------------------------------------

func _tests_strategies() -> void:
	var ids := ["bon_pere", "golden_boy", "escargots", "fourmi", "cigale", "marin", "neveu_matelas", "ecureuil", "apprenti"]
	for id: String in ids:
		var g: int = GRAINES[id]
		var e := _jouer(g, StrategieTest.PROFILS_TITRES[id])
		var b := Bilan.calculer(e)
		var t: Dictionary = b["titre"]
		print("TITRE %s strategie=%s graine=%d -> %s (écart %.1f %%, projets %d/%d, rang %d)" % [id, id, g, str(t.get("id", "?")), float(b["ecart_tata_pct"]),
			int(b["projets"]["realises"]), int(b["projets"]["total"]), e.rang_rue()])
		verifier("CA-T2 : stratégie « %s » (graine %d) -> titre %s, partie menée à son terme" % [id, g, id], e.fin == "fin" and str(t.get("id", "")) == id)
		if id == "bon_pere":
			var options: Array = b["projets"]["liste"].map(func(x: Dictionary) -> String: return str(x["id"]))
			verifier("CA-T3 : bon_pere atteint avec les 2 projets les plus chers réalisés (P1C, P2C)",
				options == ["P1C", "P2C"] and int(b["projets"]["realises"]) == 2 and float(b["ecart_tata_pct"]) > 2.0, str(options))
	# Renforcer et ne rien faire comptent ensemble pour le marin (docs/28 §1.2) ; aucun titre ne demande « Renforcer »
	var pr: Dictionary = (StrategieTest.PROFILS_TITRES["marin"] as Dictionary).duplicate(true)
	pr["krach"] = "renforcer"
	var er := _jouer(1, pr)
	verifier("CA-T4 : « Renforcer » au krach donne le même titre que « Ne rien faire » (marin), jamais un autre", str(Titres.calculer(er)["id"]) == "marin"
		and str(er.instantane_k["choix"]) == "renforcer")
	# Aucun titre n'est attribué pour une vente : la vente au krach ne mène qu'au titre 2 (ou à un titre qui juge autre chose)
	var gv := _g({"part_risquee_krach": 0.9, "a_vendu_krach": true, "ecart_tata": 0.3, "projets_realises": 1})
	verifier("CA-T4 : avec une vente au krach, jamais « marin » (le titre du sang-froid)", str(Titres.evaluer(gv)["id"]) != "marin")


# ---------------------------------------------------------------------
# CA-T3 : réaliser un projet n'abaisse jamais le rang par rapport à y renoncer (40 graines)
# ---------------------------------------------------------------------

func _tests_rang() -> void:
	var base := {"cartes": "alterner", "escargots": "refuser", "projets": "moins_cher", "ouvrir": ["D01"], "livret": true}
	var variantes := {"renoncer_P1": {"P1": "renoncer"}, "renoncer_P2": {"P2": "renoncer"}, "renoncer_tout": {"P1": "renoncer", "P2": "renoncer"}}
	var pire := 0
	var lignes_ko := 0
	var realises_ok := true
	for g in range(1, 41):
		var a := _jouer(g, base)
		var ra := a.rang_rue()
		if int(Bilan.calculer(a)["projets"]["realises"]) != 2:
			realises_ok = false
		var ligne := "RANG graine=%d realiser=%d" % [g, ra]
		for nom: String in variantes:
			var p := base.duplicate(true)
			p["jour_j"] = variantes[nom]
			var r := _jouer(g, p).rang_rue()
			ligne += " %s=%d" % [nom, r]
			if ra > r:
				lignes_ko += 1
				pire = maxi(pire, ra - r)
		print(ligne)
	verifier("CA-T3 (CA-5.2) : sur 40 graines, réaliser les projets n'abaisse jamais le rang dans la rue par rapport à y renoncer (1 ou 2 projets)", lignes_ko == 0, "%d cas pires, écart max %d" % [lignes_ko, pire])
	verifier("CA-T3 : la stratégie « réaliser » réalise bien les 2 projets sur les 40 graines", realises_ok)


# ---------------------------------------------------------------------
# CA-T6 : mesure NATURES (D3)
# ---------------------------------------------------------------------

func _tests_natures_mesure() -> void:
	var sous5 := {}
	for politique in ["epargner", "depenser"]:
		var min_n := 99
		var max_n := 0
		var compte := 0
		for g in range(1, 41):
			var e := _jouer(g, {"cartes": politique, "escargots": "refuser", "ouvrir": ["D01"], "livret": true})
			var nat := Titres.natures_choisies(e)
			var n := int(nat["depense" if politique == "depenser" else "epargne"])
			min_n = mini(min_n, n)
			max_n = maxi(max_n, n)
			if n < 5:
				compte += 1
		sous5[politique] = compte
		print("NATURES politique=%s %s_min=%d %s_max=%d sous5=%d/40" % [politique, "depenses" if politique == "depenser" else "epargnes", min_n,
			"depenses" if politique == "depenser" else "epargnes", max_n, compte])
	var attendu := 4 if int(sous5["depenser"]) > 4 else 5   # « plus de 10 % des 40 graines » (D3)
	verifier("CA-T6 : cartes_min cohérent avec la règle D3 (4 si « depenser » donne moins de 5 dépenses sur plus de 10 % des graines, sinon 5)",
		int(Titres.parametres()["cartes_min"]) == attendu, "sous5 depenser = %d/40, cartes_min = %d" % [int(sous5["depenser"]), int(Titres.parametres()["cartes_min"])])
