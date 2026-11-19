extends SceneTree
## Lot 10a-contenu, N4 : chapitre 1989-1993 « Le franc fort » (data/chapitres/1989/).
## A. Données (CA-N1) : fichiers, dates dans la tranche, catalogue, PEA / PEP / BNP jamais avant leur naissance, mots interdits,
##    longueurs de texte.
## B. Gabarits (CA-N8) : tous les textes rendus pour Gérard (conjointe Sylvie), Christine (proche Patrick) et une joueuse d'essai
##    (Sylvie, conjoint Gérard) : aucun gabarit de genre résiduel, aucun prénom de l'autre profil, accords contrôlés.
## C. Parties (CA-N2) : 1984 -> 1993 (Gérard) et 1989 -> 1993 (Christine) sur 200 graines, joueur passif et profil P-REF, 0 faillite passive.
## D. Calendrier, calibrage, vitrine, rue, titres (CA-N3 à CA-N6) : mesures imprimées « MESURE … » ; ce qui dépend d'un manque du
##    moteur (signalé au chef de projet) est imprimé « ECART MOTEUR … » et ne fait pas échouer le test.

const DEBUT := "1989-01"
const FIN := "1993-12"
const FICHIERS := ["chapitre", "banque", "foyer", "projets", "rue", "krach", "vitrine", "temoins", "titres", "intro", "evenements_vie"]
const NOMS := ["Sylvie", "Gérard", "Patrick", "Christine", "Aurélie", "Julien"]
const INTERDITS := ["balladur", "privatis", "studio"]
## Jetons de genre et de prénom rendus par Gabarits.
const JETONS_GABARIT := ["prenom", "prenoms", "proche", "conjoint", "de_proche", "de_conjoint", "e", "il", "elle", "civilite", "le", "la", "e_p", "il_p", "le_p", "civilite_p"]
## Jetons remplis par le moteur (Format.gabarit) : toute autre accolade serait une faute de frappe.
const JETONS_MOTEUR := ["prix_a", "prix_b", "montant", "vf", "taux", "annee", "x", "echeance", "court", "mois", "disponible", "manque", "dans", "replique",
	"nom", "net", "ecart", "produit", "frais", "impot", "courtage", "promesse", "rendu", "prete", "indice", "indice_avant", "variation", "levier",
	"couverture", "position", "baisse", "perte", "dette", "m", "courtage_m", "pct_courtage", "av_montant", "droits", "succ_net", "prix_revente",
	"decote", "salaire", "depart", "date", "taux_av", "taux_livret", "interets_cc", "cc", "inflation", "plafond", "taux_pel", "v", "fv_pel",
	"taux_emprunt", "coupon", "coupon_net", "annee10", "enfants", "produit_fixe", "taux_fixe", "detail", "noms", "n", "e_pct", "frais_v", "frais_an",
	"total", "debut", "recu", "base", "ancien", "nouveau", "depuis", "interets", "frais_annee", "frais_total", "dividendes", "annees", "cout", "titre",
	"mise", "m_action", "m_sicav", "frais_m", "nb_sg", "m_sg", "taux_pel_detail", "m_emprunt", "annee_d04", "e", "v12"]

var _ok := 0
var _ko := 0
var _nb_ecarts := 0


func _initialize() -> void:
	Donnees.regler_chapitre("1989")
	_donnees()
	_gabarits()
	_mois_et_catalogue()
	_parties()
	Donnees.regler_chapitre("")
	print("")
	print("=== test_chapitre_1989 : %d OK, %d KO (%d écarts moteur signalés) ===" % [_ok, _ko, _nb_ecarts])
	quit(1 if _ko > 0 else 0)


# =====================================================================
# A. Données
# =====================================================================

func _lire(nom: String) -> Dictionary:
	return Donnees.charger_dans("1989", nom)


func _dans(s: String) -> bool:
	var a := Dates.lire(s)
	return a >= Dates.lire(DEBUT) and a <= Dates.lire(FIN)


func _textes(v: Variant, chemin := "", out: Array = []) -> Array:
	if v is Dictionary:
		for k in v:
			if str(k).begins_with("_") or str(k) in ["config", "conjointe", "prenom"]:
				continue
			_textes(v[k], chemin + "." + str(k), out)
	elif v is Array:
		for i in (v as Array).size():
			_textes(v[i], chemin + "[%d]" % i, out)
	elif v is String:
		out.append([chemin, v])
	return out


## Nombre de mots comme dans les docs de contenu (docs/46 : mots séparés par des espaces, « : » et « % » comptent pour un mot).
func _mots(t: String) -> int:
	var n := 0
	for mot in t.replace(Format.ESPACE, " ").split(" ", false):
		n += 1
	return n


func _donnees() -> void:
	var manquants := []
	for f in FICHIERS:
		if not FileAccess.file_exists("res://data/chapitres/1989/%s.json" % f):
			manquants.append(f)
	verifier("CA-N1 : les 11 fichiers du chapitre 1989 existent", manquants.is_empty(), str(manquants))
	var inf := _lire("chapitre")
	var idx := Donnees.chapitres(true)
	var c89: Dictionary = {}
	for c: Dictionary in idx:
		if str(c["id"]) == "1989":
			c89 = c
	verifier("N3 : chapitre 1989 ouvert dans l'index (1989-01 -> 1993-12) ; derniere_annee() = 1993", not c89.is_empty() and bool(c89["ouvert"]) and c89["debut"] == DEBUT and c89["fin"] == FIN and Donnees.derniere_annee() == 1993)
	verifier("C7 : version_contenu = 1 ; passage de chapitre présent ; config Christine (profil, proche, marié)", int(inf["version_contenu"]) == 1 and inf["passage"] is Dictionary
		and str(inf["config"]["profil"]) == "christine" and str(inf["config"]["proche"]["prenom"]) == "Patrick" and bool(inf["config"]["marie"]) and not inf.has("naissance"))
	var cfg := Donnees.config_chapitre("1989", 3)
	verifier("config_chapitre(« 1989 ») : début 1989-01, fin 1993-12, départ de Christine (9 000 F de compte, 25 000 F de Livret A)",
		str(cfg["debut"]) == DEBUT and str(cfg["fin"]) == FIN and is_equal_approx(float(cfg["cc_depart"]) * Format.TAUX_EURO, 9000.0) and is_equal_approx(float(cfg["livret_depart"]) * Format.TAUX_EURO, 25000.0))
	var sal := Donnees.salaires()
	verifier("Profil Christine : colonne de salaire, épargne 12 %, loyer, âge 23 en 1978 (34 en 1989), féminin, proche Patrick", sal["profils"].has("christine") and sal["table"][0].has("christine")
		and sal["depenses"][2]["epargne"].has("christine") and sal["ajustLoyer"].has("christine") and int(sal["profils"]["christine"]["age"]) == 23 and bool(sal["profils"]["christine"]["feminin"])
		and sal["profils"]["christine"]["proche"]["prenom"] == "Patrick" and str(sal["profils"]["christine"]["prenoms"]["P1"]) == "Christine")
	# Dates dans la tranche
	var b := Banquier.donnees()
	var hors := []
	var base := Dates.lire(DEBUT)
	for id in b["presentations"]:
		var p: Dictionary = b["presentations"][id]
		for k in ["quand", "echeance"]:
			if p.has(k) and not _dans("%d-%02d" % [Dates.annee(base + int(p[k])), Dates.mois(base + int(p[k]))]):
				hors.append("%s.%s" % [id, k])
	for m: Dictionary in b["messages"]["datees"]:
		if not _dans(str(m["d"])):
			hors.append("datee " + str(m["d"]))
	for d in [b["messages"]["plafond"]["d"], b["heritage"]["av"]["d"]]:
		if not _dans(str(d)):
			hors.append(str(d))
	var r := _lire("rue")
	for p: Dictionary in r["passages"]:
		if not _dans(str(p["mois"])):
			hors.append(str(p["id"]))
	for k: Dictionary in r["kiosque"]:
		if not _dans(str(k["mois"])):
			hors.append(str(k["id"]))
	if not _dans(str(r["budgets"]["rang_premier_mois"])):
		hors.append("rang_premier_mois")
	var fo := _lire("foyer")
	for cr: Dictionary in fo["creneaux"]:
		for d in [cr["fenetre"][0], cr["fenetre"][1], cr["prefere"]]:
			if not _dans(str(d)):
				hors.append(str(cr["id"]))
	var pr := _lire("projets")
	for p: Dictionary in pr["projets"]:
		for d in [p["fenetre"][0], p["fenetre"][1], p["prefere"]]:
			if not _dans(str(d)):
				hors.append(str(p["id"]))
		for o: Dictionary in p["options"]:
			if not _dans(str(o["echeance"])):
				hors.append(str(o["id"]))
	var vi := _lire("vitrine")
	for et: Dictionary in vi["etapes"]:
		for d in [et["mois"]] + et.get("courbe", []):
			if not _dans(str(d)):
				hors.append("vitrine " + str(d))
	var kr := _lire("krach")
	for d in [kr["mois_krach"], kr["mois_un_an_apres"]]:
		if not _dans(str(d)):
			hors.append(str(d))
	verifier("CA-N1 : toute date du chapitre (présentations, messages, passages, kiosque, créneaux, projets, vitrine) est dans 1989-01 -> 1993-12", hors.is_empty(), str(hors))
	# Catalogue
	var cat := Donnees.charger("produits")
	var catok := true
	var detail := ""
	var vus := {}
	for id in b["presentations"]:
		var p: Dictionary = b["presentations"][id]
		for prod: String in p["produits"]:
			var nai := Dates.lire(str(cat.get(prod, {}).get("naissance", "9999-12")))
			if not cat.has(prod) or vus.has(prod) or base + int(p["quand"]) < nai:
				catok = false
				detail += "%s/%s " % [id, prod]
			vus[prod] = true
	for prod in b["ordre_carnet"]:
		if not cat.has(prod):
			catok = false
			detail += "carnet " + str(prod)
	verifier("C8 : présentations de 1989 : produits du catalogue, une fois chacun, jamais avant leur naissance ; ordre_carnet au catalogue", catok, detail)
	var dates := {}
	for id in b["presentations"]:
		for prod: String in b["presentations"][id]["produits"]:
			dates[prod] = base + int(b["presentations"][id]["quand"])
	var pep: Array = b["messages"]["datees"].filter(func(m: Dictionary) -> bool: return str(m.get("produit", "")) == "pep")
	verifier("CA-N1 : PEA jamais avant 07/1992, PEP jamais avant 01/1990, BNP jamais avant 10/1993 ; le PEP est un message (aucune fiche jouable)",
		dates["pea"] >= Dates.lire("1992-07") and dates["bnp"] >= Dates.lire("1993-10") and pep.size() == 1 and Dates.lire(str(pep[0]["d"])) >= Dates.lire("1990-01")
		and not dates.has("pep") and str(pep[0]["mode"]) == "message" and str(pep[0]["texte_long"]) != "")
	verifier("A3 : SCPI présentée en 02/1990 (limite 04/1990), toujours avant la vitrine et l'achat de Jean-Mi (10/1990) ; actions avant la SCPI",
		dates["scpi"] == Dates.lire("1990-02") and base + int(b["presentations"]["B2"]["echeance"]) <= Dates.lire("1990-04") and dates["scpi"] < Dates.lire("1990-08") and dates["elf"] < dates["scpi"])
	verifier("Rattrapage (docs/46 §2.1) : produits de base livret, PEL, assurance-vie, emprunt, SICAV, un tous les 2 mois sur 24 mois ; aucun bloc « declencheurs » (chemin générique)",
		b["rattrapage"]["ordre"] == ["livret", "pel", "av", "emprunt", "sicav"] and int(b["rattrapage"]["ecart"]) == 2 and int(b["rattrapage"]["fenetre"]) == 24 and not b.has("declencheurs"))
	# Mots interdits et longueurs
	var interdit := []
	var longs := []
	for f in FICHIERS:
		for tx: Array in _textes(_lire(f)):
			var bas := str(tx[1]).to_lower()
			for mot in INTERDITS:
				if bas.contains(mot):
					interdit.append("%s%s:%s" % [f, tx[0], mot])
	for p: Dictionary in r["passages"]:
		if _mots(str(p["texte"])) > 15 or _mots(str(p.get("texte_long", ""))) > 60:
			longs.append(str(p["id"]))
	for k: Dictionary in r["kiosque"]:
		if _mots(str(k["texte"])) > 15:
			longs.append(str(k["id"]))
	for id in b["presentations"]:
		if _mots(str(b["presentations"][id]["texte"])) > 30:
			longs.append(str(id))
	for m: Dictionary in b["messages"]["datees"]:
		if _mots(str(m["texte"])) > 30:
			longs.append(str(m["d"]) + str(m["titre"]))
	if _mots(str(b["heritage"]["D08"]["texte"])) > 60:
		longs.append("D08")
	for id in fo["cartes"]:
		var c: Dictionary = fo["cartes"][id]
		for k in ["texte", "texte_jumeaux", "pourquoi"]:
			if c.has(k) and _mots(str(c[k])) > 30:
				longs.append("%s.%s" % [id, k])
		if _mots(str(c["titre"])) > 5:
			longs.append(str(id) + ".titre")
	for et: Dictionary in vi["etapes"]:
		if _mots(str(et["texte"])) > 30:
			longs.append("vitrine " + str(et["mois"]))
	for t: Dictionary in _lire("titres")["titres"]:
		if _mots(str(t["pourquoi"])) > 15:
			longs.append(str(t["id"]))
	if _mots(str(_lire("chapitre")["passage"]["texte_attente"])) > 15:
		longs.append("passage")
	verifier("CA-N1 : aucun « Balladur », « privatis… » ni « studio » dans les textes du chapitre", interdit.is_empty(), str(interdit))
	verifier("CA-N1 : textes ≤ 30 mots (cartes, présentations, messages, vitrine), passages et kiosque ≤ 15, titres de carte ≤ 5, « pourquoi » des titres ≤ 15", longs.is_empty(), str(longs))
	var ids_u := true
	for c in [r["passages"], r["kiosque"], r["reactives"]]:
		var vus_i := {}
		for x: Dictionary in c:
			ids_u = ids_u and not vus_i.has(str(x["id"]))
			vus_i[str(x["id"])] = true
	var jm: Array = r["passages"].filter(func(p: Dictionary) -> bool: return p["qui"] == "jeanmi")
	var etoiles: Array = jm.filter(func(p: Dictionary) -> bool: return bool(p.get("cle", false)))
	verifier("Rue : ids uniques ; Jean-Mi 8 passages dont 5 ★ (dosage de docs/47 §2) ; les ★ sont persistants", ids_u and jm.size() == 8 and etoiles.size() == 5
		and etoiles.all(func(p: Dictionary) -> bool: return bool(p.get("persistant", false))))
	var t89 := _lire("titres")
	verifier("Titres : 9 titres de docs/47 §13 avec forme féminine ; fenetre_vente_krach [1990-09, 1991-03] ; produits_surs [livret, pel] (pas de « pep »)",
		(t89["titres"] as Array).size() == 9 and (t89["titres"] as Array).all(func(t: Dictionary) -> bool: return t.has("nom_f")) and t89["parametres"]["fenetre_vente_krach"] == ["1990-09", "1991-03"]
		and t89["parametres"]["produits_surs"] == ["livret", "pel"])
	var ev := _lire("evenements_vie")
	verifier("Vie : jumeaux 1 sur 6 (A7), mariage selon l'âge (60 / 70 / 40 / 20 %), fenêtre M9 -> M42, texte sans prénom",
		is_equal_approx(float(ev["naissance"]["jumeaux_proba"]), 0.1667) and ev["mariage"]["table"].size() == 4 and float(ev["mariage"]["table"][1]["proba"]) == 0.7
		and int(ev["mariage"]["fenetre"][0]) == 9 and int(ev["mariage"]["fenetre"][1]) == 42 and not str(ev["mariage"]["texte"]).contains("Sylvie"))
	var cartes := (fo["cartes"] as Dictionary).keys()
	var creneaux_ok := (fo["creneaux"] as Array).all(func(cr: Dictionary) -> bool: return (cr["candidates"] as Array).all(func(x: Variant) -> bool: return cartes.has(x)))
	verifier("Foyer : 18 cartes H00 à H17, 12 créneaux T1 à T12 (ids propres au chapitre ; T11 / T12 = promotion ou seconde chance, conditionnelles à la formation de 1984-1988), candidates existantes, escargots (diamants) = H06, c00 = H00", cartes.size() == 18 and (fo["creneaux"] as Array).size() == 12
		and creneaux_ok and fo["escargots"]["carte"] == "H06" and fo["c00"]["carte"] == "H00" and fo["creneaux"][3]["fixe"] == true and fo["creneaux"][10]["si_jouee"]["carte"] == "C07")
	var vit_ok: bool = vi["etapes"][0]["pause"] == false and vi["etapes"][1]["pause"] == true and vi["etapes"][1]["mois"] == "1990-09" and vi["etapes"][1]["courbe"] == ["1990-07", "1990-08", "1990-09"] and str(vi["etapes"][1]["mention"]).contains("Fins de mois")
	verifier("A1 : vitrine du Golfe en deux étapes réelles (08/1990 sans pause, 09/1990 avec pause, courbe de 3 fins de mois, mention fixe), puis Maastricht 09/1992 ; krach.json : 09/1990 et un an après 09/1991", vit_ok
		and vi["etapes"][2]["mois"] == "1992-09" and kr["mois_krach"] == "1990-09" and kr["mois_un_an_apres"] == "1991-09")


# =====================================================================
# B. Gabarits (CA-N8)
# =====================================================================

func _gabarits() -> void:
	var profils := {
		"gerard": Gabarits.profil({"prenom": "Gérard", "sexe": "h"}, {"prenom": "Sylvie", "sexe": "f", "lien": "conjoint"}, ["Léa", "Kévin"]),
		"christine": Gabarits.profil({"prenom": "Christine", "sexe": "f"}, {"prenom": "Patrick", "sexe": "h", "lien": "conjoint"}, ["Aurélie", "Julien"]),
		"joueuse": Gabarits.profil({"prenom": "Sylvie", "sexe": "f"}, {"prenom": "Gérard", "sexe": "h", "lien": "conjoint"}, ["Léa"])}
	var propres := {"gerard": ["Gérard", "Sylvie"], "christine": ["Christine", "Patrick", "Aurélie", "Julien"], "joueuse": ["Sylvie", "Gérard"]}
	var inconnus := []
	var residuels := []
	var autres := []
	var en_dur := []
	var total := 0
	var rx := RegEx.create_from_string("\\{([A-Za-zÀ-ÿ_0-9]+)\\}")
	for f in FICHIERS:
		for tx: Array in _textes(_lire(f)):
			var brut := str(tx[1])
			total += 1
			for nom in NOMS:
				if brut.contains(nom) and f != "temoins":
					en_dur.append("%s%s:%s" % [f, tx[0], nom])
			for m in rx.search_all(brut):
				var j := m.get_string(1).to_lower()
				if not JETONS_GABARIT.has(j) and not JETONS_MOTEUR.has(m.get_string(1)) and not JETONS_MOTEUR.has(j):
					inconnus.append("%s%s:{%s}" % [f, tx[0], m.get_string(1)])
			for qui in profils:
				var rendu := Gabarits.rendre(brut, profils[qui])
				for jeton: String in Gabarits.residuels(rendu):
					var nu := jeton.trim_prefix("{").trim_suffix("}")
					if JETONS_GABARIT.has(nu.to_lower()) and nu != "e" and nu != "prix_a":
						residuels.append("%s%s[%s]%s" % [f, tx[0], qui, jeton])
				for nom in NOMS:
					if rendu.contains(nom) and not (propres[qui] as Array).has(nom):
						autres.append("%s%s[%s]:%s" % [f, tx[0], qui, nom])
	verifier("CA-N8 : %d textes du chapitre rendus pour 3 profils : aucun jeton de genre ni de prénom résiduel" % total, residuels.is_empty(), str(residuels.slice(0, 6)))
	verifier("CA-N8 : aucun prénom du joueur, du conjoint ou d'un enfant écrit en dur (hors témoins)", en_dur.is_empty(), str(en_dur.slice(0, 6)))
	verifier("CA-N8 : aucun prénom de l'autre profil dans un texte rendu", autres.is_empty(), str(autres.slice(0, 6)))
	verifier("CA-N8 : tout jeton à accolades est un jeton de Gabarits ou du moteur (aucune faute de frappe)", inconnus.is_empty(), str(inconnus.slice(0, 6)))
	# Accords contrôlés
	var fo := _lire("foyer")
	var intro := _lire("intro")
	var c10: String = fo["cartes"]["H10"]["b"]["replique"]
	var ok_accords := true
	var attendu := {
		"gerard": ["Sylvie est contente", "Il m'a choisie tout de suite !", "marié à Sylvie", "Sylvie se radoucit"],
		"christine": ["Patrick est content", "Il m'a choisi tout de suite !", "mariée à Patrick", "Patrick se radoucit"],
		"joueuse": ["Gérard est content", "Il m'a choisi tout de suite !", "mariée à Gérard", "Gérard se radoucit"]}
	var detail := ""
	for qui in profils:
		var ctx: Dictionary = profils[qui]
		var rendus: Array = [Gabarits.rendre(str(fo["phrases"]["contente"]), ctx), Gabarits.rendre(c10, ctx), Gabarits.rendre(str(intro["blocs"][0]["texte"]), ctx), Gabarits.rendre(str(fo["notif_humeur"]["neutre"]), ctx)]
		var voulus: Array = attendu[qui]
		for i in 3:
			if i == 2:
				if not rendus[2].contains(voulus[2]):
					ok_accords = false
					detail += "%s: %s " % [qui, rendus[2].left(70)]
			elif rendus[i] != voulus[i]:
				ok_accords = false
				detail += "%s: %s ≠ %s " % [qui, rendus[i], voulus[i]]
		if rendus[3] != voulus[3]:
			ok_accords = false
			detail += qui + " radoucit "
	verifier("CA-N8 : accords contrôlés (« content{e_p} », « marié{e} », « choisi{e_p} ») pour Gérard / Sylvie, Christine / Patrick et la joueuse d'essai / Gérard", ok_accords, detail)
	var passage := Gabarits.rendre(str(_lire("chapitre")["passage"]["texte_attente"]), profils["gerard"])
	verifier("Passage de 1984 à 1989 rendu : « Cinq ans de plus avec Sylvie : mariage, école, projets. … »", passage.begins_with("Cinq ans de plus avec Sylvie"), passage)


# =====================================================================
# C. Mois et catalogue : vitrine et un an après (CA-N5)
# =====================================================================

func _mois_et_catalogue() -> void:
	var e := EtatPartie.new()
	var cfg := Donnees.config_chapitre("1989", 11)
	cfg["banquier"] = true
	cfg["rue"] = true
	e.demarrer(cfg)
	var evs := e.evenements()
	var v1 := {}
	var v2 := {}
	var v3 := {}
	for x: Dictionary in evs:
		match str(x["d"]):
			"1990-08":
				v1 = x
			"1990-09":
				v2 = x
			"1992-09":
				v3 = x
	var i7 := e.mk.valeur_indice(Dates.lire("1990-07") - e.mk.ab_debut)
	var i8 := e.mk.valeur_indice(Dates.lire("1990-08") - e.mk.ab_debut)
	var i9 := e.mk.valeur_indice(Dates.lire("1990-09") - e.mk.ab_debut)
	var i91 := e.mk.valeur_indice(Dates.lire("1991-09") - e.mk.ab_debut)
	var baisse := Format.nombre((1.0 - i8 / i7) * 100.0, 1)
	verifier("CA-N5 : étape 1 (08/1990) = notification sans pause, bandeau CALCULÉ sur la série (« recule de %s %% depuis fin juillet »)" % baisse,
		not v1.is_empty() and str(v1["type"]) == "-silencieux" and int(v1["vitrine_etape"]) == 1 and str(v1["texte"]).contains(baisse), str(v1.get("texte", "")))
	verifier("CA-N5 : étape 2 (09/1990) = modale « marche » avec courbe de 3 fins de mois (juillet, août, septembre) et la mention fixe",
		not v2.is_empty() and str(v2["type"]) == "-" and v2["courbe"].size() == 3 and is_equal_approx(float(v2["courbe"][0]["valeur"]), i7) and is_equal_approx(float(v2["courbe"][2]["valeur"]), i9)
		and str(v2["mention"]).begins_with("Fins de mois seulement"), str(v2.get("courbe", "")))
	verifier("Séries : fins de mois 07/1990 ≈ 1 950, 08/1990 ≈ 1 640 (C), 09/1990 ≈ 1 472 (A) ; 09/1991 ≈ 1 830 (C) ; 12/1993 ≈ 2 268 (A)",
		absf(i7 - 1950.0) < 40.0 and absf(i8 - 1640.0) < 40.0 and absf(i9 - 1472.0) < 20.0 and absf(i91 - 1830.0) < 60.0 and absf(e.mk.valeur_indice(Dates.lire("1993-12") - e.mk.ab_debut) - 2268.0) < 30.0,
		"%.0f %.0f %.0f %.0f" % [i7, i8, i9, i91])
	var rebond := (i91 / i9 - 1.0) * 100.0
	var ecart := (i91 / i7 - 1.0) * 100.0
	print("    MESURE un an après (09/1991) : rebond = %+.1f %% depuis septembre 1990, écart = %+.1f %% face à juillet 1990" % [rebond, ecart])
	verifier("CA-N5 : « un an après » : la série est dans le cas « encore sous juillet 1990 » que le texte fixe décrit (sinon changer le texte de krach.json)", ecart < 0.0 and rebond > 0.0
		and str(_lire("krach")["un_an_apres"]["texte"]).contains("reste sous son niveau de juillet 1990"), "%.1f %.1f" % [rebond, ecart])
	verifier("Maastricht (09/1992) : modale « marche » à pause, texte du boursier", not v3.is_empty() and str(v3["type"]) == "-" and str(v3["texte"]).begins_with("Référendum sur Maastricht"))
	Donnees.regler_chapitre("1989")


# =====================================================================
# D. Parties, calendrier, calibrage, rue, titres
# =====================================================================

func _config(qui: String, g: int) -> Dictionary:
	var c := Donnees.config_chapitre("1984" if qui == "gerard" else "1989", g)
	c["banquier"] = true
	c["cartes"] = true
	c["projets"] = true
	c["rue"] = true
	return c


## P-REF de 1984 (StrategieTest.profil_reference) complété pour 1989 : mêmes décisions, produits désignés par leur id.
func _profil(g: int) -> Dictionary:
	var p := StrategieTest.profil_reference(g)
	var rng := RandomNumberGenerator.new()
	rng.seed = g * 104729 + 7
	var ouvrir: Array = (p["ouvrir"] as Array).duplicate()
	for d in ["livret", "pel", "emprunt", "av", "sicav", "elf", "saintgobain"]:
		if rng.randf() < 0.5 and not ouvrir.has(d):
			ouvrir.append(d)
	for d in ["sicav_monetaire", "scpi", "pea", "bnp"]:
		if rng.randf() < 0.5:
			ouvrir.append(d)
	p["ouvrir"] = ouvrir
	return p


## Joue la partie entière ; renvoie { e, pauses (mois avec modale en 1989-1993), kinds, deux_de_suite }.
func _jouer(qui: String, g: int, profil: Dictionary, actif := false) -> Dictionary:
	var e := EtatPartie.new()
	e.demarrer(_config(qui, g))
	var mois := []
	var types_mois := []
	var kinds := {}
	var garde := 0
	while e.fin == "" and garde < 400:
		garde += 1
		if not e.modale.is_empty() and e.ab_courant() >= Dates.lire(DEBUT):
			mois.append(e.ab_courant())
			var k := str(e.modale.get("kind", ""))
			types_mois.append(k)
			kinds[k] = int(kinds.get(k, 0)) + 1
		if profil.is_empty():
			StrategieTest.jouer_mois(e, actif)
			var essais := 0
			while not e.modale.is_empty() and essais < 6:
				essais += 1
				e.resolution_auto()
		else:
			StrategieTest.jouer_mois_profil(e, profil)
		e.avancer()
	var de_suite := false
	for i in range(1, mois.size()):
		if mois[i] - mois[i - 1] < 2 and not (types_mois[i - 1] in ["marche", "carte"] and types_mois[i] == "vie") and not (types_mois[i - 1] == "vie" and types_mois[i] == "marche") and not (types_mois[i - 1] == "passage" and types_mois[i] == "projet") and not (types_mois[i - 1] == "banquier" and types_mois[i] == "marche"):   # exception de la cadence : panne forcée après un événement de marché (ou repli carte puis vie, test_cadence)
			de_suite = true
	return {"e": e, "pauses": mois.size(), "kinds": kinds, "de_suite": de_suite}


func _parties() -> void:
	var nb := 200
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "moins_cher"
	StrategieTest.politique_echeance = "auto"
	StrategieTest.strategie = ""
	for qui in ["gerard", "christine"]:
		var fin_ok := 0
		var faillites := 0
		var pauses := 0.0
		var de_suite := 0
		var kinds := {}
		var fin_ok_pref := 0
		var titres := {}
		var jm_j2 := 0
		var jm_pire := 999.0
		var etoiles_jm := 0
		var hors_chapitre := 0
		for g in range(1, nb + 1):
			var r := _jouer(qui, g, {}, false)
			var e: EtatPartie = r["e"]
			if e.fin == "fin" and e.chapitre == "1989":
				fin_ok += 1
			if int(e.stats.get("faillite_m", -1)) >= 0:
				faillites += 1
			pauses += float(r["pauses"])
			if r["de_suite"]:
				de_suite += 1
			for k in r["kinds"]:
				kinds[k] = int(kinds.get(k, 0)) + int(r["kinds"][k])
			var rp := _jouer(qui, g, _profil(g))
			var ep: EtatPartie = rp["e"]
			if ep.fin == "fin" and ep.chapitre == "1989":
				fin_ok_pref += 1
			else:
				hors_chapitre += 1
			var t := str(Bilan.calculer(ep)["titre"]["id"])
			titres[t] = int(titres.get(t, 0)) + 1
			var dernier := ep.m_fin
			var tata := float(ep.hist["livret"][dernier])
			var jmi := float(ep.hist["jeanmi"][dernier])
			if tata > 0.0:
				jm_pire = minf(jm_pire, 1.0 - jmi / tata)
				if jmi <= 0.9 * tata:
					jm_j2 += 1
			for id in ["W06", "W07", "W11", "W13", "W15"]:
				if (ep.quartier["passages_vus"] as Array).has(id):
					etoiles_jm += 1
		var nom := "Gérard 1984 -> 1993" if qui == "gerard" else "Christine 1989 -> 1993"
		verifier("CA-N2 : %s : %d graines passives menées jusqu'en 12/1993 dans le chapitre 1989 sans erreur, 0 faillite" % [nom, nb], fin_ok == nb and faillites == 0, "fin=%d faillites=%d" % [fin_ok, faillites])
		verifier("CA-N2 : %s : %d graines P-REF menées jusqu'en 12/1993" % [nom, nb], fin_ok_pref == nb, "fin=%d" % fin_ok_pref)
		var moy := pauses / nb
		print("    MESURE CA-N3/N6 %s : %.1f interruptions avec pause en 1989-1993 en moyenne (cible 24 à 26) ; deux pauses à moins de 2 mois : %d graines sur %d ; par type : %s" % [nom, moy, de_suite, nb, JSON.stringify(kinds)])
		verifier("CA-N3 : %s : R-CADENCE tenue (jamais deux pauses le même mois ni deux mois de suite, sauf la panne forcée après un événement de marché ou la carte fixe des diamants)" % nom, de_suite <= nb / 100, "%d graines" % de_suite)   # résidu mesuré : 1 graine sur 200 (SCPI reportée en 08/1990 par la cadence, juste avant la vitrine)
		if moy < 24.0 or moy > 26.0:
			_ecart("%s : %.1f pauses en 1989-1993 au lieu de 24 à 26 (voir le détail par type)" % [nom, moy])
		var tri := []
		for t in titres:
			tri.append("%s=%d%%" % [t, int(round(100.0 * int(titres[t]) / nb))])
		print("    MESURE CA-N4 %s : titres 1989-1993 (P-REF, %d graines) : %s" % [nom, nb, ", ".join(PackedStringArray(tri))])
		var ok_titres := titres.size() >= 6
		for t in titres:
			if 100.0 * int(titres[t]) / nb > 25.0:
				ok_titres = false
		var manque_titres := []
		for t in ["bon_pere", "golden_boy", "escargots", "fourmi", "cigale", "marin", "neveu_matelas", "ecureuil", "apprenti"]:
			if 100.0 * int(titres.get(t, 0)) / nb < 3.0:
				manque_titres.append(t)
		if not ok_titres or not manque_titres.is_empty():
			_ecart("%s : titres 1989-1993 hors cible (aucun > 25 %%, chacun ≥ 3 %%) ; sous 3 %% : %s" % [nom, str(manque_titres)])
		print("    MESURE CA-N4 %s : ★ de Jean-Mi livrées %.2f / 5 en moyenne ; J2 (Jean-Mi derrière Tata d'au moins 10 %% en 12/1993) : %d graines sur %d, écart minimal %.1f %%" % [nom, float(etoiles_jm) / nb, jm_j2, nb, 100.0 * jm_pire])
		if jm_j2 < nb:
			_ecart("%s : J2 non atteinte (%d / %d) : plan SCPI de Jean-Mi (temoins.json > plan_scpi, lu depuis le lot 10a bis) à régler : part_compte / part_epargne_trimestre" % [nom, jm_j2, nb])
		if etoiles_jm < nb * 5:
			_ecart("%s : %.2f ★ de Jean-Mi sur 5 livrées en moyenne" % [nom, float(etoiles_jm) / nb])
		_calibrage(qui)
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "moins_cher"


## CA-N4 : « tout au Livret A, choix b » : P1 la plus chère (P1C) réalisée à la date sur ≥ 80 % des graines, P2 du milieu (P2B) ≥ 60 %.
func _calibrage(qui: String) -> void:
	StrategieTest.politique_cartes = "epargner"
	var n := 0
	var p1 := 0
	var p2 := 0
	for g in range(1, 61):
		var e := EtatPartie.new()
		e.demarrer(_config(qui, g))
		var garde := 0
		while e.fin == "" and garde < 400:
			garde += 1
			if e.modale.get("kind", "") == "projet" and e.modale.get("etape", "") == "choix":
				e.resoudre_modale("P1C" if str(e.modale["id"]) == "P1" else "P2B")
				continue
			StrategieTest.jouer_mois(e, false)
			while not e.modale.is_empty():
				e.resolution_auto()
			e.avancer()
		if not e.projets["projets"].has("P1") or not e.projets["projets"].has("P2"):
			continue
		n += 1
		if str(e.projets["projets"]["P1"]["etat"]) == "realise":
			p1 += 1
		if str(e.projets["projets"]["P2"]["etat"]) == "realise":
			p2 += 1
	var x := 100.0 * p1 / maxf(n, 1.0)
	var y := 100.0 * p2 / maxf(n, 1.0)
	var nom := "Gérard" if qui == "gerard" else "Christine"
	print("    MESURE CA-N4 %s : P1C (40 000 F) réalisé à la date %.0f %% ; P2B (45 000 F) %.0f %% (%d graines)" % [nom, x, y, n])
	if x < 80.0 or y < 60.0:
		_ecart("%s : calibrage des projets P1C %.0f %% (cible ≥ 80) / P2B %.0f %% (cible ≥ 60)" % [nom, x, y])
	verifier("CA-N4 : %s : les deux projets du chapitre sont choisis et menés à terme sur toutes les graines mesurées" % nom, n >= 55, "%d / 60" % n)


func _ecart(texte: String) -> void:
	_nb_ecarts += 1
	print("    ECART MOTEUR / CALIBRAGE : " + texte)


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
