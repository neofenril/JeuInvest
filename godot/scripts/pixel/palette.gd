class_name PalettePixel
extends RefCounted
## Palette « Rue 84 » (docs/16 §2.3 et §8.2, + 8 couleurs PX0 ter) : 67 couleurs, en 3 variantes (jour, nuit, orage).
## Les 40 premières (§2.3) ne changent jamais (l'interface s'en sert) ; les 19 suivantes (§8.2, révision
## du 2026-10-29 : ciel d'été, nuages, lointain, briques vives, feuillage d'été, goudron, sarcelle, dalles)
## sont ajoutées à la suite, pour le monde seulement, et ne sont pas émissives.
## Seul fichier de scripts/pixel/ où des couleurs sont écrites en dur : tout le reste passe par
## PalettePixel.couleur("nom"). Les variantes nuit et orage sont des tables de substitution couleur
## par couleur ; les couleurs émissives (lumières, néon, écrans, couleurs de l'interface) ne changent pas.
## Comparaisons exactes en 8 bits (R, G, B), l'alpha n'entre jamais dans la clé.

const JOUR := 0
const NUIT := 1
const ORAGE := 2

const _NOMS := [
	"encre", "nuit", "ardoise_sombre", "ardoise", "gris_pierre", "zinc_clair", "creme", "blanc_chaud",
	"pierre_ombre", "pierre", "pierre_claire", "brique_sombre", "brique", "tuile", "terre_cuite_claire",
	"bois_sombre", "bois", "bleu_nuit", "bleu_ardoise", "ciel", "ciel_clair", "vert_sombre", "vert",
	"vert_clair", "orange", "rouge_auvent", "bleu_vif", "peau_claire", "peau_ombre", "caramel",
	"lumiere", "neon_rose", "ambre", "or", "gain", "perte", "gel", "cuivre", "gain_papier", "perte_papier",
	# docs/16 §8.2 (n° 41 à 59)
	"ciel_haut", "ciel_vif", "nuage", "nuage_ombre", "nuage_creux", "lointain_clair", "lointain",
	"lointain_sombre", "brique_vive", "brique_claire", "feuille_sombre", "feuille", "feuille_vive",
	"feuille_eclat", "goudron", "goudron_clair", "sarcelle", "dalle", "dalle_ombre",
	# PX0 ter (n° 60 à 67, retour du joueur du 2026-10-29 : « approche-toi encore plus » de rue_pixel_v2)
	"brique_brune", "ombre_froide", "goudron_sombre", "feuille_profonde", "mousse", "nuage_soleil",
	"bleu_gris", "vitre_reflet",
]

# Valeurs exactes de docs/16 §2.3 puis §8.2, dans l'ordre de _NOMS.
const _HEX_JOUR := [
	"1C1626", "2D2840", "46415C", "6B6880", "9C98A6", "C9C6CC", "F3E9D2", "FFF9EC",
	"8C735A", "BFA27C", "E2CBA0", "6E2E2E", "A8483A", "D06A45", "E9A070",
	"4E3226", "7A5034", "283A6B", "3F5C96", "6FA4D8", "A9D4EE", "2F5240", "4F8A4B",
	"8DBF5A", "E2803A", "C7323F", "2F7FD1", "F4D0AE", "D49A74", "A8714E",
	"FFD97A", "FF5FA2", "FFB547", "F2C14E", "46E08A", "FF5C5C", "7FD6FF", "C77B4A", "1B6E3E", "B3261E",
	"3C8AD6", "5DAAE8", "F7FBFF", "CFE2F2", "A3C3E0", "B4CCE0", "8DA9C8",
	"6A86A8", "C4573A", "DE7A4E", "23542A", "3E8C34", "6DBB3C",
	"A9DC54", "5E626C", "7C808A", "2F7C80", "BDB7AD", "9E978C",
	"8E4A32", "4F5B78", "4A4E5A", "1A3F2A", "6E8A3A", "FFF3D2", "7A90AC", "9CCBF0",
]
const _HEX_NUIT := [
	"120F1E", "1B1A30", "262842", "363A5C", "4A4E72", "5F6488", "6E7092", "7A7EA0",
	"3E3A52", "575470", "6A6884", "32223A", "4A2E48", "5C3A50", "6A5266",
	"241C2C", "36283A", "141C40", "1E2C5A", "22345E", "34466E", "16243A", "22364A",
	"34485A", "64404E", "52263E", "1E3268", "6E6480", "5A4A66", "46344A",
	"FFD97A", "FF5FA2", "FFB547", "6E5A5A", "46E08A", "FF5C5C", "7FD6FF", "C77B4A", "1B6E3E", "B3261E",
	"1A2C58", "203A66", "7C80A2", "5A6488", "44507A", "3E4870", "323C64",
	"283258", "563048", "66424C", "142236", "1E3444", "2C4450",
	"3C5258", "2A2C46", "383C5A", "18344A", "50547A", "44466A",
	"40283A", "22264A", "202238", "0F1A2C", "263A3A", "8A8AA6", "2E3A5E", "3A4C78",
]
const _HEX_ORAGE := [
	"1A1418", "2A2230", "3A3440", "565060", "7A7280", "9A929C", "B8AA9E", "C8BCB0",
	"6A5650", "8E7868", "A89280", "522628", "7E3A34", "9A5040", "AE7A60",
	"3A2624", "5A3C30", "22283E", "364056", "5A5A6E", "7A7484", "26362E", "3E5A3E",
	"66804C", "A0603A", "8E2C34", "34507E", "B4988A", "96705E", "7A5444",
	"FFD97A", "FF5FA2", "FFB547", "B08A48", "46E08A", "FF5C5C", "7FD6FF", "C77B4A", "1B6E3E", "B3261E",
	"4A5266", "565C70", "B4B0B8", "9894A0", "7E7C8C", "8A8696", "706E80",
	"5E5C6E", "8E4636", "A6644A", "22342A", "3A5634", "5A7A40",
	"7A9450", "4C4A54", "64626C", "36545A", "8C8482", "76706E",
	"6E4234", "4A4A5A", "3E3C46", "1C2A24", "5E6E44", "C4BEB8", "6C7080", "8C94A4",
]
const _EMISSIVES := ["lumiere", "neon_rose", "ambre", "gain", "perte", "gel", "cuivre", "gain_papier", "perte_papier"]

static var _couleurs: Array = []      # [variante] -> Dictionary nom -> Color
static var _inverse: Array = []       # [variante] -> Dictionary clé RGB (int) -> nom (premier nom en cas d'égalité)
static var _rgb: Array = []           # [variante] -> Dictionary nom -> clé RGB


static func _preparer() -> void:
	if not _couleurs.is_empty():
		return
	for tableau in [_HEX_JOUR, _HEX_NUIT, _HEX_ORAGE]:
		var couleurs := {}
		var inverse := {}
		var rgb := {}
		for i in _NOMS.size():
			var c := Color("#" + String(tableau[i]))
			couleurs[_NOMS[i]] = c
			var k := cle(c)
			rgb[_NOMS[i]] = k
			if not inverse.has(k):
				inverse[k] = _NOMS[i]
		_couleurs.append(couleurs)
		_inverse.append(inverse)
		_rgb.append(rgb)


## Clé de comparaison : R, G, B en 8 bits (0xRRGGBB), sans l'alpha.
static func cle(c: Color) -> int:
	return c.to_rgba32() >> 8


## Les 67 identifiants, dans l'ordre de docs/16 §2.3, §8.2, puis PX0 ter (n° 60 à 67).
static func noms() -> PackedStringArray:
	return PackedStringArray(_NOMS)


static func existe(nom: String) -> bool:
	return _NOMS.has(nom)


## Couleur d'un identifiant ; nom inconnu : push_error et magenta (bien visible).
static func couleur(nom: String, variante := JOUR) -> Color:
	_preparer()
	var v := clampi(variante, JOUR, ORAGE)
	if not _couleurs[v].has(nom):
		push_error("PalettePixel : couleur inconnue « %s »" % nom)
		return Color.MAGENTA
	return _couleurs[v][nom]


## Couleur avec un alpha (affichage seulement : halos, voiles ; jamais dans les images).
static func couleur_alpha(nom: String, alpha: float, variante := JOUR) -> Color:
	var c := couleur(nom, variante)
	c.a = alpha
	return c


static func emissive(nom: String) -> bool:
	return _EMISSIVES.has(nom)


static func contient(c: Color, variante := JOUR) -> bool:
	_preparer()
	return _inverse[clampi(variante, JOUR, ORAGE)].has(cle(c))


## Identifiant d'une couleur de la palette ("" si hors palette).
static func nom_de(c: Color, variante := JOUR) -> String:
	_preparer()
	return _inverse[clampi(variante, JOUR, ORAGE)].get(cle(c), "")


## Table de substitution clé RGB de « de » -> Color de « vers ».
static func _table(de: int, vers: int) -> Dictionary:
	_preparer()
	var t := {}
	for nom in _NOMS:
		var k: int = _rgb[de][nom]
		if not t.has(k):
			t[k] = _couleurs[vers][nom]
	return t


## Copie de l'image où chaque couleur de la variante « de » est remplacée par celle de « vers ».
## L'alpha est conservé ; une couleur hors palette est laissée telle quelle (le contrôle la signalera).
static func convertir(img: Image, de := JOUR, vers := NUIT) -> Image:
	var copie := Image.new()
	copie.copy_from(img)
	if copie.get_format() != Image.FORMAT_RGBA8:
		copie.convert(Image.FORMAT_RGBA8)
	if de == vers:
		return copie
	var t := _table(clampi(de, JOUR, ORAGE), clampi(vers, JOUR, ORAGE))
	# Table en octets : clé -> [r, g, b]
	var octets := {}
	for k in t:
		var c: Color = t[k]
		octets[k] = PackedByteArray([c.r8, c.g8, c.b8])
	var d := copie.get_data()
	var n := d.size()
	var i := 0
	while i < n:
		if d[i + 3] != 0:
			var k := (d[i] << 16) | (d[i + 1] << 8) | d[i + 2]
			var o = octets.get(k)
			if o != null:
				d[i] = o[0]
				d[i + 1] = o[1]
				d[i + 2] = o[2]
		i += 4
	return Image.create_from_data(copie.get_width(), copie.get_height(), false, Image.FORMAT_RGBA8, d)


## Nombre de pixels d'alpha > 0 dont le RGB n'est pas dans la variante.
static func compter_hors_palette(img: Image, variante := JOUR) -> int:
	_preparer()
	var inverse: Dictionary = _inverse[clampi(variante, JOUR, ORAGE)]
	var copie := img
	if img.get_format() != Image.FORMAT_RGBA8:
		copie = Image.new()
		copie.copy_from(img)
		copie.convert(Image.FORMAT_RGBA8)
	var d := copie.get_data()
	var n := d.size()
	var hors := 0
	var i := 0
	while i < n:
		if d[i + 3] != 0:
			if not inverse.has((d[i] << 16) | (d[i + 1] << 8) | d[i + 2]):
				hors += 1
		i += 4
	return hors
