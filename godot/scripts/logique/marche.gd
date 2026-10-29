class_name Marche
extends RefCounted
## Marché d'une période : cours générés de façon déterministe (03 §7.1-7.3), séries datées
## (Livret A, IPC, baguette, impôts, frais, agios). Port de jeu/js/marche.js.
## Tableaux de N cases : case 0 = décembre précédant la période, case m + 1 = cours de fin du mois m.

const N := 181
const SIGMA_NORMAL := 0.045
const SIGMA_CRISE := 0.10

static var _cache: Dictionary = {}
static var _ipc_an: Dictionary = {}

var periode: Dictionary
var ab_debut: int        # janvier de la première année
var ab0: int             # décembre précédent (case 0)
var indice := PackedFloat64Array()
var prix: Dictionary = {}    # id -> PackedFloat64Array (NAN avant la disponibilité)
var infos: Dictionary = {}   # id -> description du produit


## Marché d'une période, généré une seule fois.
static func pour_periode(id: String) -> Marche:
	if not _cache.has(id):
		_cache[id] = Marche.new(Donnees.periode(id))
	return _cache[id]


static func vider_cache() -> void:
	_cache.clear()


func _init(p: Dictionary) -> void:
	periode = p
	var debut := int(p["debut"])
	ab_debut = Dates.ab(debut, 1)
	ab0 = ab_debut - 1
	var rng := Hasard.new(int(p["graine"]))
	var annuel: Dictionary = Donnees.series()["annuel"]

	# Indice : ancrages durs = clôtures annuelles, puis points mensuels de la période
	var anc := {}
	var annuels := {}
	for y in range(debut - 1, debut + 15):
		var i := Dates.ab(y, 12) - ab0
		anc[i] = log(float(annuel[str(y)][0]))
		annuels[i] = true
	for a in p.get("ancragesIndice", []):
		var i := Dates.lire(a[0]) - ab0
		if i >= 0 and i < N and not annuels.has(i):
			anc[i] = log(float(a[1]))
	var crise := {}
	for d in p.get("moisCrise", []):
		crise[Dates.lire(d) - ab0] = true
	var sigma_indice := func(i: int) -> float: return SIGMA_CRISE if crise.has(i) else SIGMA_NORMAL
	var log_i := _pont(_trier(anc), sigma_indice, rng)
	indice.resize(N)
	for k in N:
		indice[k] = exp(float(log_i[k]))

	# Actions : ln P = beta × ln I + résidu (pont brownien entre les ancrages propres)
	for pr in p["produits"]:
		infos[pr["id"]] = pr
		if pr["type"] != "action":
			continue
		var beta := float(pr["beta"])
		var pts := {}
		for a in pr["ancrages"]:
			var i := Dates.lire(a[0]) - ab0
			pts[i] = log(Format.vers_euros(float(a[1]), pr.get("devise", "€"))) - beta * float(log_i[i])
		var sig := float(pr["volSpe"]) / sqrt(12.0)
		var resid := _pont(_trier(pts), func(_i: int) -> float: return sig, rng)
		var serie := PackedFloat64Array()
		serie.resize(N)
		for k in N:
			serie[k] = NAN if resid[k] == null else exp(beta * float(log_i[k]) + float(resid[k]))
		prix[pr["id"]] = serie

	# Fonds : VL(m) = VL(m-1) × I(m)/I(m-1) × (1 + d/12) × (1 − f/12)
	for pr in p["produits"]:
		if pr["type"] == "sicav":
			var gestion := float(Donnees.regles()["sicav"]["gestion"])
			prix[pr["id"]] = _fonds(0, Format.vers_euros(float(pr["vl0"]), pr.get("devise", "€")), gestion, annuel)


## Pont brownien en log entre des points [[i, x], ...] triés ; cases hors des points = null.
func _pont(points: Array, sigma: Callable, rng: Hasard) -> Array:
	var x := []
	x.resize(N)
	for p in range(points.size() - 1):
		var i0: int = points[p][0]
		var x0: float = points[p][1]
		var i1: int = points[p + 1][0]
		var x1: float = points[p + 1][1]
		var n := i1 - i0
		var w: Array[float] = [0.0]
		for j in range(1, n + 1):
			w.append(w[j - 1] + float(sigma.call(i0 + j)) * rng.student4())
		x[i0] = x0
		for j in range(1, n):
			var t := float(j) / n
			x[i0 + j] = x0 + (x1 - x0) * t + w[j] - t * w[n]
		x[i1] = x1
	return x


func _trier(d: Dictionary) -> Array:
	var cles := d.keys()
	cles.sort()
	var out := []
	for k in cles:
		out.append([int(k), float(d[k])])
	return out


func _fonds(debut_i: int, vl_debut: float, gestion: float, annuel: Dictionary) -> PackedFloat64Array:
	var vl := PackedFloat64Array()
	vl.resize(N)
	vl.fill(NAN)
	vl[debut_i] = vl_debut
	for i in range(debut_i + 1, N):
		var d := float(annuel[str(Dates.annee(ab0 + i))][1]) / 100.0
		vl[i] = vl[i - 1] * indice[i] / indice[i - 1] * (1.0 + d / 12.0) * (1.0 - gestion / 100.0 / 12.0)
	return vl


# ---------- Accès aux cours ----------

## Cours de fin du mois m (0 = janvier de la première année ; -1 = décembre précédent). NAN si indisponible.
func cours(id: String, m: int) -> float:
	if not prix.has(id):
		return NAN
	var serie: PackedFloat64Array = prix[id]
	return serie[clampi(m + 1, 0, N - 1)]


func valeur_indice(m: int) -> float:
	return indice[clampi(m + 1, 0, N - 1)]


## Nom de l'indice à la date a (court : « CAC 40 » ; sinon : « le CAC 40 »).
func nom_indice(a: int, court := true) -> String:
	var v: Variant = Donnees.en_vigueur(periode.get("nomsIndice", []), a)
	if v == null:
		return "l'indice"
	return v[1] if court else v[2]


func disponible(id: String, a: int) -> bool:
	if not infos.has(id):
		return false
	var pr: Dictionary = infos[id]
	return not pr.has("dispo") or Dates.lire(pr["dispo"]) <= a


# ---------- Séries datées (statiques) ----------

static func taux_livret(a: int) -> float:
	var v: Variant = Donnees.en_vigueur(Donnees.series()["livretTaux"], a)
	return float(v[1]) if v != null else 0.0


static func plafond_livret(a: int) -> float:
	var v: Variant = Donnees.en_vigueur(Donnees.series()["livretPlafond"], a)
	if v == null:
		return INF
	return Format.vers_euros(float(v[1]), v[2] if v.size() > 2 else "€")


static func rdt_dividende(annee: int) -> float:
	return float(Donnees.series()["annuel"][str(annee)][1])


static func inflation(annee: int) -> float:
	return float(Donnees.series()["inflation"].get(str(annee), 0.0))


## IPC annuel, base 100 en 2025 (valeur placée en janvier).
static func ipc_annee(y: int) -> float:
	if _ipc_an.is_empty():
		_ipc_an[2025] = 100.0
		for k in range(2025, 1976, -1):
			_ipc_an[k - 1] = _ipc_an[k] / (1.0 + inflation(k) / 100.0)
		_ipc_an[2026] = 100.0 * (1.0 + inflation(2025) / 100.0)
	return _ipc_an[clampi(y, 1976, 2026)]


## IPC du mois, interpolé géométriquement entre deux janviers.
static func ipc(a: int) -> float:
	var y := Dates.annee(a)
	var f := (Dates.mois(a) - 1) / 12.0
	return ipc_annee(y) * pow(ipc_annee(y + 1) / ipc_annee(y), f)


static func euros_aujourdhui(eur: float, a: int) -> float:
	return eur * 100.0 / ipc(a)


## Prix de la baguette en euros, interpolé linéairement entre les points de janvier.
static func baguette(a: int) -> float:
	var pts: Array = Donnees.series()["baguette"]
	var x := Dates.annee(a) + (Dates.mois(a) - 1) / 12.0
	for i in range(pts.size() - 1):
		var y0 := float(pts[i][0])
		var y1 := float(pts[i + 1][0])
		if x >= y0 and x <= y1:
			var v0 := Format.vers_euros(float(pts[i][1]), pts[i][2] if pts[i].size() > 2 else "€")
			var v1 := Format.vers_euros(float(pts[i + 1][1]), pts[i + 1][2] if pts[i + 1].size() > 2 else "€")
			return v0 + (v1 - v0) * (x - y0) / (y1 - y0)
	var der: Array = pts[pts.size() - 1]
	return Format.vers_euros(float(der[1]), der[2] if der.size() > 2 else "€")


## Taux d'imposition en vigueur : { cto, pea5 }.
static func impot(a: int) -> Dictionary:
	return Donnees.regle_datee(Donnees.regles()["impots"], a)


## Barème de courtage en vigueur : { taux, min }.
static func frais(a: int) -> Dictionary:
	return Donnees.regle_datee(Donnees.regles()["frais"], a)


## Frais de courtage d'un ordre d'actions : max(minimum, taux × montant).
static func frais_courtage(a: int, brut: float) -> float:
	if brut <= 0.0:
		return 0.0
	var f := frais(a)
	return maxf(float(f["min"]), float(f["taux"]) / 100.0 * brut)


static func taux_agios(a: int) -> float:
	return float(Donnees.regle_datee(Donnees.regles()["agios"], a)["taux"])
