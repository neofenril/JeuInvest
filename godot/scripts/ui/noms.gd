class_name Noms
extends RefCounted
## Noms et repères de chapitre affichés par l'interface (lot 10b, I4) : lus dans les données du chapitre actif,
## jamais écrits en dur (le banquier de 1984 s'appelle M. Lefranc, celui d'un autre chapitre autrement).
## Textes identiques à ceux de 1984-1988 tant que les données le sont.


## Nom du banquier tel que le chapitre l'écrit (« M. LEFRANC »), repli neutre.
static func banquier_brut() -> String:
	var nom := str(Donnees.infos_chapitre().get("banquier", {}).get("nom", ""))
	return nom if nom != "" else "LE BANQUIER"


## « M. Lefranc » : première lettre de chaque mot en capitale, le reste en minuscules (les abréviations « M. » gardent leur forme).
static func banquier() -> String:
	var mots := banquier_brut().split(" ", false)
	var sortie: Array = []
	for m in mots:
		if m.length() <= 2 and m.ends_with("."):
			sortie.append(m)
		else:
			sortie.append(m.substr(0, 1).to_upper() + m.substr(1).to_lower())
	return " ".join(PackedStringArray(sortie))


## Mois du krach (« 1987-10 ») lu dans le krach.json du premier chapitre ouvert qui en a un ; "" sinon.
static func mois_krach(actif := false) -> String:
	if actif:   # « un an après » : le krach / la vitrine du chapitre en cours (1987 pour 1984, le Golfe en 1990 pour 1989)
		var ida := Donnees.chapitre_actif()
		if FileAccess.file_exists("%s/%s/krach.json" % [Donnees.racine_chapitres, ida]):
			var ma := str(Donnees._charger_dans(ida, "krach").get("mois_krach", ""))
			if ma != "":
				return ma
	for c: Dictionary in Donnees.chapitres():
		var id := str(c["id"])
		if FileAccess.file_exists("%s/%s/krach.json" % [Donnees.racine_chapitres, id]):
			var m := str(Donnees._charger_dans(id, "krach").get("mois_krach", ""))
			if m != "":
				return m
	return ""


## Année du krach (0 si aucun).
static func annee_krach() -> int:
	var m := mois_krach()
	return Dates.annee(Dates.lire(m)) if m != "" else 0


## « octobre 1987 » (ou en majuscules) ; "" si aucun krach.
static func texte_mois_krach(majuscules := false, actif := false) -> String:
	var m := mois_krach(actif)
	return Dates.texte(Dates.lire(m), majuscules) if m != "" else ""


## Préfixe du portrait du proche (conjoint) selon son genre dans foyer_visuel() : Sylvie (f, défaut) ou le conjoint homme.
static func portrait_proche(e: EtatPartie) -> String:
	if e == null:
		return "portrait_sylvie_"
	var p: Dictionary = e.foyer_visuel().get("proche", {})
	return "portrait_proche_h_" if str(p.get("sexe", "f")) == "h" else "portrait_sylvie_"


## Préfixe du portrait de la joueuse (« portrait_joueuse_ » + contente | neutre | fachee) ; "" pour un joueur : aucun portrait du joueur
## n'existe pour Gérard (les écrans de 1984-1988 restent identiques).
static func portrait_joueuse(e: EtatPartie) -> String:
	if e == null:
		return ""
	return "portrait_joueuse_" if str(e.foyer_visuel().get("joueur", {}).get("sexe", "h")) == "f" else ""


## Définition d'un produit pour le joueur : sans la mention technique « Présenté par un message… » des produits en mode message.
static func definition(info: Dictionary) -> String:
	return str(info.get("definition", "")).split(" Présenté par un message")[0].strip_edges()


## Années d'une partie écrites en lettres (« cinq ans », « dix ans »), sinon en chiffres.
static func duree_texte(nb_annees: int) -> String:
	var mots := {1: "un an", 2: "deux ans", 3: "trois ans", 4: "quatre ans", 5: "cinq ans", 6: "six ans", 7: "sept ans", 8: "huit ans", 9: "neuf ans", 10: "dix ans"}
	return str(mots.get(nb_annees, "%d ans" % nb_annees))


## « 1984-1988 » : années de début et de fin d'un chapitre de l'index (id inconnu : id seul).
static func annees_chapitre(id: String) -> String:
	for c: Dictionary in Donnees.chapitres(true):
		if str(c["id"]) == id:
			return "%d-%d" % [Dates.annee(Dates.lire(str(c["debut"]))), Dates.annee(Dates.lire(str(c["fin"])))]
	return id


## Titres d'époque de chaque chapitre ouvert : [{id, annees, titres: [{id, nom, ordre}]}] (titres.json de chaque chapitre, sans changer
## le chapitre actif) ; sert à la collection et à l'écran titre quand plusieurs chapitres sont ouverts.
static func titres_par_chapitre() -> Array:
	var out: Array = []
	for c: Dictionary in Donnees.chapitres():
		var id := str(c["id"])
		var liste: Array = Donnees._charger_dans(id, "titres").get("titres", [])
		var titres: Array = []
		for i in liste.size():
			titres.append({"id": str(liste[i]["id"]), "nom": str(liste[i]["nom"]), "ordre": i + 1})
		out.append({"id": id, "annees": annees_chapitre(id), "titres": titres})
	return out


## Année de départ du chapitre actif (1984 pour le chapitre 1984).
static func annee_depart_chapitre() -> int:
	var d := str(Donnees.infos_chapitre().get("config", {}).get("debut", ""))
	return Dates.annee(Dates.lire(d)) if d != "" else Donnees.premiere_annee()
