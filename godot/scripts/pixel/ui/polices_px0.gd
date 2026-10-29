extends RefCounted
## Polices embarquées de l'interface pixel (docs/16 §3.2, lot PX0 §2.5). Sans class_name : chargé par chemin.
## FontFile importées en niveaux de gris, sans hinting ni sous-pixel, sans MSDF, sans repli système
## (réglages des .ttf.import) ; graisses par FontVariation (axe « wght »). Aucune SystemFont.
##   Pixelify Sans : titres, étiquettes, boutons, jamais sous 28 px virtuels (TAILLE_MIN_PIXELIFY).
##   Atkinson Hyperlegible Next : chiffres (avec « tnum » : chiffres de même largeur), textes longs,
##   et tout texte de moins de 28 px.
##   Jersey 10 : variante de la date et du patrimoine (touche P). Doto : planche des polices seulement.

const PIXELIFY := "res://polices/pixelify_sans/PixelifySans-Variable.ttf"
const ATKINSON := "res://polices/atkinson_hyperlegible_next/AtkinsonHyperlegibleNext-Variable.ttf"
const JERSEY := "res://polices/jersey_10/Jersey10-Regular.ttf"
const DOTO := "res://polices/doto/Doto-Variable.ttf"
const TAILLE_MIN_PIXELIFY := 28

static var _cache := {}


static func _base(chemin: String) -> FontFile:
	if not _cache.has(chemin):
		_cache[chemin] = load(chemin)
	return _cache[chemin]


static func _variation(chemin: String, graisse: int, chiffres_fixes: bool) -> Font:
	var k := "%s|%d|%s" % [chemin, graisse, chiffres_fixes]
	if not _cache.has(k):
		var v := FontVariation.new()
		v.base_font = _base(chemin)
		if graisse > 0:
			v.variation_opentype = {"wght": graisse}
		if chiffres_fixes:
			v.opentype_features = {"tnum": 1}
		_cache[k] = v
	return _cache[k]


## Titres, étiquettes, boutons (graisse 400 à 700).
static func pixelify(graisse := 500) -> Font:
	return _variation(PIXELIFY, graisse, false)


## Chiffres et textes (graisse 200 à 800), chiffres tabulaires.
static func atkinson(graisse := 400) -> Font:
	return _variation(ATKINSON, graisse, true)


static func jersey() -> Font:
	return _variation(JERSEY, 0, true)


static func doto(graisse := 700) -> Font:
	return _variation(DOTO, graisse, false)


static func est_pixelify(f: Font) -> bool:
	var fv := f as FontVariation
	return fv != null and fv.base_font == _base(PIXELIFY)


## Nombre de polices chargées (les 4 fichiers).
static func chargees() -> int:
	var n := 0
	for c in [PIXELIFY, ATKINSON, JERSEY, DOTO]:
		if _base(c) != null:
			n += 1
	return n


## Vrai si les chiffres d'Atkinson ont tous la même largeur avec « tnum ».
static func tnum_atkinson() -> bool:
	var f := atkinson(700)
	var l := f.get_string_size("0", HORIZONTAL_ALIGNMENT_LEFT, -1, 40).x
	for ch in "123456789":
		if absf(f.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, 40).x - l) > 0.01:
			return false
	return f.get_string_size("1111", HORIZONTAL_ALIGNMENT_LEFT, -1, 40).x == f.get_string_size("0000", HORIZONTAL_ALIGNMENT_LEFT, -1, 40).x


## Caractères du texte absents de la police (renvoie les caractères manquants).
static func manquants(chemin: String, texte: String) -> String:
	var f := _base(chemin)
	var m := ""
	for ch in texte:
		if ch != " " and not f.has_char(ch.unicode_at(0)) and not m.contains(ch):
			m += ch
	return m


static func chemins() -> PackedStringArray:
	return PackedStringArray([PIXELIFY, ATKINSON, JERSEY, DOTO])
