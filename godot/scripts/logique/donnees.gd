class_name Donnees
extends RefCounted
## Chargement (avec cache) des fichiers de données éditables de res://data/*.json.
## Attention : JSON lit tous les nombres en float ; convertir avec int() quand il faut un entier.

## Chapitres (lot 09) : une tranche de 5 ans de contenu = un dossier <racine_chapitres>/<id>/. Un fichier de chapitre
## REMPLACE le fichier de res://data/ du même nom (jamais de fusion). Le « monde » (series, regles, salaires, rythme,
## periode_*) reste dans res://data/. Les tests déplacent racine_chapitres vers un jeu d'essai.
static var racine_chapitres := "res://data/chapitres"
## Chapitre actif ; "" = index.chapitre_defaut (les tests qui lisent titres, foyer… sans partie lancée continuent de marcher).
static var chapitre := ""
static var _cache: Dictionary = {}


## Change le chapitre actif (le cache est indexé par chapitre : rien à vider).
static func regler_chapitre(id: String) -> void:
	chapitre = id


## Chapitre réellement lu : l'actif, sinon celui par défaut de l'index.
static func chapitre_actif() -> String:
	if chapitre != "":
		return chapitre
	return str(index().get("chapitre_defaut", ""))


## data/<nom>.json du chapitre actif, sinon du monde. « demo » = « chapitre » (alias permanent).
static func charger(nom: String) -> Dictionary:
	return _charger_dans(chapitre_actif(), nom)


static func _charger_dans(id: String, nom: String) -> Dictionary:
	if nom == "demo":
		nom = "chapitre"
	var cle := "%s|%s|%s" % [racine_chapitres, id, nom]
	if _cache.has(cle):
		return _cache[cle]
	var chemin := "%s/%s/%s.json" % [racine_chapitres, id, nom]
	if id == "" or not FileAccess.file_exists(chemin):
		chemin = "res://data/%s.json" % nom
	var d := _lire(chemin)
	if not d.is_empty():
		_cache[cle] = d
	return d


## Lit et analyse un fichier JSON ; erreur seulement si le fichier manque ou est invalide.
static func _lire(chemin: String) -> Dictionary:
	var f := FileAccess.open(chemin, FileAccess.READ)
	if f == null:
		push_error("Données introuvables : %s" % chemin)
		return {}
	var json := JSON.new()
	if json.parse(f.get_as_text()) != OK:
		push_error("JSON invalide dans %s, ligne %d : %s" % [chemin, json.get_error_line(), json.get_error_message()])
		return {}
	var d: Dictionary = json.data
	return d


static func vider_cache() -> void:
	_cache.clear()


## Index des chapitres (<racine_chapitres>/index.json).
static func index() -> Dictionary:
	var cle := "%s|index" % racine_chapitres
	if _cache.has(cle):
		return _cache[cle]
	var d := _lire("%s/index.json" % racine_chapitres)
	if not d.is_empty():
		_cache[cle] = d
	return d


## Chapitres déclarés [{id, nom, debut, fin, marche, ouvert}] ; seuls les ouverts par défaut.
static func chapitres(tous := false) -> Array:
	var out := []
	for c: Dictionary in index().get("chapitres", []):
		if tous or bool(c.get("ouvert", false)):
			out.append(c)
	return out


## Chapitre ouvert qui contient le mois absolu ab ("" si aucun).
static func chapitre_de(ab: int) -> String:
	for c: Dictionary in chapitres():
		if Dates.lire(str(c["debut"])) <= ab and ab <= Dates.lire(str(c["fin"])):
			return str(c["id"])
	return ""


static func premiere_annee() -> int:
	return int(index().get("premiere_annee", 0))


## Fin du dernier chapitre ouvert (1988 aujourd'hui) ; calculée, jamais écrite.
static func derniere_annee() -> int:
	var a := 0
	for c: Dictionary in chapitres():
		a = maxi(a, Dates.annee(Dates.lire(str(c["fin"]))))
	return a


## Décor de la rue à la date ab : dernière ligne de index.themes dont « de » est atteint (la première avant).
static func theme_a(ab: int) -> String:
	var themes: Array = index().get("themes", [])
	if themes.is_empty():
		return ""
	var t := str(themes[0]["theme"])
	for x: Dictionary in themes:
		if Dates.lire(str(x["de"])) <= ab:
			t = str(x["theme"])
	return t


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


## chapitre.json du chapitre id (défaut : l'actif) : banquier, journal, titre, moments, vitesse_depart…
static func infos_chapitre(id := "") -> Dictionary:
	return _charger_dans(id if id != "" else chapitre_actif(), "chapitre")


## Configuration d'un chapitre (chapitre.json) prête pour EtatPartie.demarrer ; « chapitre » = chapitre de départ.
## fin : "" = décembre de derniere_annee() (partie qui traverse les chapitres ouverts) ; sinon borne explicite
## « AAAA-MM » (config_demo : 1988-12). graine < 0 : graine de test.
static func config_chapitre(id: String, graine := -1, fin := "") -> Dictionary:
	var demo := infos_chapitre(id)
	var c: Dictionary = demo["config"].duplicate(true)
	c["chapitre"] = id
	c["graine_vie"] = graine if graine >= 0 else int(demo.get("graine_test", 1))
	c["naissance"] = demo.get("naissance", {}).duplicate(true)
	c["cc_depart"] = float(demo["depart_F"]["cc"]) / Format.TAUX_EURO
	c["livret_depart"] = float(demo["depart_F"]["livret"]) / Format.TAUX_EURO
	if fin != "":
		c["fin"] = fin
	elif derniere_annee() > 0:
		c["fin"] = "%d-12" % derniere_annee()
	return c


## Alias permanent : la démo 1984-1988 (fin figée en 1988-12 : tests et captures, même quand d'autres chapitres s'ouvrent).
static func config_demo(graine := -1) -> Dictionary:
	return config_chapitre("1984", graine, "1988-12")


## Entrée du catalogue des produits du monde (data/produits.json) ; {} si absent.
static func produit(id: String) -> Dictionary:
	return charger("produits").get(id, {})


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
