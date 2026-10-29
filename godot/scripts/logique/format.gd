class_name Format
extends RefCounted
## Monnaie et nombres à la française. Montants internes en euros ; conversion en francs à l'affichage.

const TAUX_EURO := 6.55957
const MOINS := "−"           # vrai signe moins
const ESPACE := " "     # espace insécable (séparateur de milliers et avant l'unité)


static func vers_euros(v: float, devise: String) -> float:
	return v / TAUX_EURO if devise == "F" else v


static func en_devise(eur: float, devise: String) -> float:
	return eur * TAUX_EURO if devise == "F" else eur


## Devise affichée à la date a : franc avant 2002, euro ensuite.
static func devise(a: int) -> String:
	return "F" if a < Dates.ab(2002, 1) else "€"


## 1234.5 -> "1 234,50" (dec = 2) ; signe moins typographique.
static func nombre(x: float, dec := 0) -> String:
	var v := absf(x)
	var s: String = ("%." + str(dec) + "f") % v
	var parties := s.split(".")
	var e := parties[0]
	var out := ""
	var n := e.length()
	for i in n:
		if i > 0 and (n - i) % 3 == 0:
			out += ESPACE
		out += e[i]
	if dec > 0:
		out += "," + parties[1]
	if x < 0.0 and v >= 0.5 * pow(10.0, -dec):
		out = MOINS + out
	return out


## Montant en euros internes affiché dans la devise de la date a.
## prix : toujours 2 décimales ; signe : « + » devant les gains.
static func montant(eur: float, a: int, prix := false, signe := false) -> String:
	var dev := devise(a)
	var v := en_devise(eur, dev)
	var av := absf(v)
	var s: String
	if av >= 1e7:
		s = nombre(v / 1e6, 1) + ESPACE + "M"
	elif prix or av < 1000.0:
		s = nombre(v, 2)
	else:
		s = nombre(v, 0)
	if signe and v > 0.004:
		s = "+" + s
	return s + ESPACE + dev


## Montant arrondi à l'unité, sans décimales (textes du banquier : « 945 F », « 12 600 F »).
static func entier(eur: float, a: int) -> String:
	var v := en_devise(eur, devise(a))
	if absf(v) >= 1e7:
		return montant(eur, a)
	return nombre(v, 0) + ESPACE + devise(a)


## Écart signé arrondi à l'unité (« +1 234 F », « −102 F », « 0 F ») : indicateurs de comparaison.
static func ecart(eur: float, a: int) -> String:
	var v := en_devise(eur, devise(a))
	if absf(v) >= 1e7:
		return montant(eur, a, false, true)
	var s := nombre(v, 0)
	if v >= 0.5:
		s = "+" + s
	return s + ESPACE + devise(a)


## 0.0525 -> "+5,3 %"
static func pct(x: float, dec := 1) -> String:
	var s := nombre(x * 100.0, dec)
	if x > 0.0 and absf(x * 100.0) >= 0.5 * pow(10.0, -dec):
		s = "+" + s
	return s + ESPACE + "%"


## Remplace {cle} par vals[cle] dans un texte.
static func gabarit(t: String, vals: Dictionary) -> String:
	var s := t
	for k in vals:
		s = s.replace("{" + str(k) + "}", str(vals[k]))
	return s
