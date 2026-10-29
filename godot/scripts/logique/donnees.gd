class_name Donnees
extends RefCounted
## Chargement (avec cache) des fichiers de données éditables de res://data/*.json.
## Attention : JSON lit tous les nombres en float ; convertir avec int() quand il faut un entier.

static var _cache: Dictionary = {}


static func charger(nom: String) -> Dictionary:
	if _cache.has(nom):
		return _cache[nom]
	var chemin := "res://data/%s.json" % nom
	var f := FileAccess.open(chemin, FileAccess.READ)
	if f == null:
		push_error("Données introuvables : %s" % chemin)
		return {}
	var json := JSON.new()
	if json.parse(f.get_as_text()) != OK:
		push_error("JSON invalide dans %s, ligne %d : %s" % [chemin, json.get_error_line(), json.get_error_message()])
		return {}
	var d: Dictionary = json.data
	_cache[nom] = d
	return d


static func vider_cache() -> void:
	_cache.clear()


static func series() -> Dictionary:
	return charger("series")


static func regles() -> Dictionary:
	return charger("regles")


static func salaires() -> Dictionary:
	return charger("salaires")


static func vie() -> Dictionary:
	return charger("evenements_vie")


static func temoins() -> Dictionary:
	return charger("temoins")


static func periode(id: String) -> Dictionary:
	return charger("periode_" + id.to_lower())


## Configuration de la démo V2 (data/demo.json) prête pour EtatPartie.demarrer. graine < 0 : graine de test.
static func config_demo(graine := -1) -> Dictionary:
	var demo := charger("demo")
	var c: Dictionary = demo["config"].duplicate(true)
	c["graine_vie"] = graine if graine >= 0 else int(demo.get("graine_test", 1))
	c["naissance"] = demo.get("naissance", {}).duplicate(true)
	c["cc_depart"] = float(demo["depart_F"]["cc"]) / Format.TAUX_EURO
	c["livret_depart"] = float(demo["depart_F"]["livret"]) / Format.TAUX_EURO
	return c


## Élément en vigueur à la date a dans une liste triée [["AAAA-MM", valeur, ...], ...] (null si aucun).
static func en_vigueur(liste: Array, a: int) -> Variant:
	var v: Variant = null
	for x in liste:
		if Dates.lire(x[0]) <= a:
			v = x
		else:
			break
	return v


## Dernière règle dont le champ "de" (année entière ou "AAAA-MM") est atteint à la date a.
static func regle_datee(liste: Array, a: int) -> Dictionary:
	var r: Dictionary = liste[0]
	for x in liste:
		var de: Variant = x["de"]
		var debut: int = Dates.lire(de) if de is String else Dates.ab(int(de), 1)
		if debut <= a:
			r = x
	return r
