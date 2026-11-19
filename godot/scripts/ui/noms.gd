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
static func mois_krach() -> String:
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
static func texte_mois_krach(majuscules := false) -> String:
	var m := mois_krach()
	return Dates.texte(Dates.lire(m), majuscules) if m != "" else ""


## Année de départ du chapitre actif (1984 pour le chapitre 1984).
static func annee_depart_chapitre() -> int:
	var d := str(Donnees.infos_chapitre().get("config", {}).get("debut", ""))
	return Dates.annee(Dates.lire(d)) if d != "" else Donnees.premiere_annee()
