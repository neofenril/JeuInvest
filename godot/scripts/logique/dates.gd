class_name Dates
extends RefCounted
## Dates en « mois absolu » : ab = année × 12 + (mois − 1). Écrites "AAAA-MM" dans les données.

const MOIS := ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août",
	"septembre", "octobre", "novembre", "décembre"]
const MOIS_COURTS := ["janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août",
	"sept.", "oct.", "nov.", "déc."]


static func ab(annee: int, mois: int) -> int:
	return annee * 12 + mois - 1


## "1987-10" -> mois absolu.
static func lire(s: String) -> int:
	var p := s.split("-")
	return ab(int(p[0]), int(p[1]))


@warning_ignore("integer_division")
static func annee(a: int) -> int:
	return a / 12


static func mois(a: int) -> int:
	return a % 12 + 1


## "octobre 1987" (ou "OCTOBRE 1987").
static func texte(a: int, majuscules := false) -> String:
	var t := "%s %d" % [MOIS[mois(a) - 1], annee(a)]
	return t.to_upper() if majuscules else t


## "oct. 1987"
static func texte_court(a: int) -> String:
	return "%s %d" % [MOIS_COURTS[mois(a) - 1], annee(a)]


## "2 ans et 3 mois"
@warning_ignore("integer_division")
static func duree(nb_mois: int) -> String:
	var a := nb_mois / 12
	var m := nb_mois % 12
	var t: PackedStringArray = []
	if a > 0:
		t.append("%d %s" % [a, "ans" if a > 1 else "an"])
	if m > 0:
		t.append("%d mois" % m)
	return " et ".join(t) if t.size() > 0 else "0 mois"
