class_name PiecesMois
extends RefCounted
## Règles des pièces du mois (lot 02, D8 et D10 ; docs/15 §1.1) : fonctions pures, sans nœud, éprouvées par
## tests/test_pieces.gd. L'animation est dans Sequences.pieces_du_mois et Juice.pieces_suivies.
## - Or = revenus du mois (intérêts, coupons, dividendes), de la banque vers la maison ; cuivre = frais, de la
##   maison vers la banque. Seuil : 10 F chacun. Nombre de pièces = 1 + arrondi(log10(montant / 10 F)), de 1 à 6.
## - Jamais en pause, à ×3 ni pendant un saut (la rue file trop vite pour suivre une pièce).
## - Textes (cartouches, lot 03 D7 : 2 lignes au plus, MAX_CAR caractères chacune, séparées par « \n ») :
##   « + 312 F » ; « + 312 F ce mois-ci » / « versés en décembre » (toutes les lignes de revenus sont créditées
##   au 31/12 et le mois écoulé n'est pas décembre) ; « Elf : + 840 F » (coupons, dividendes : 2 cartouches au
##   plus, les plus gros ; nom long : « Emprunt d'État : » / « + 600 F ») ; « − 45 F de frais ». Espaces
##   insécables, vrai signe moins.

const SEUIL_F := 10.0
const MAX_PIECES := 6
const MAX_LIGNES := 2
const MAX_CAR := 20
const GENRES_REVENUS := ["interets", "coupon", "dividende"]
const GENRES_LIGNES := ["coupon", "dividende"]


## Nombre de pièces pour un montant en francs (0 sous le seuil).
static func nombre(montant_f: float) -> int:
	if montant_f + 1e-6 < SEUIL_F:
		return 0
	return clampi(1 + roundi(log(maxf(montant_f, SEUIL_F) / SEUIL_F) / log(10.0)), 1, MAX_PIECES)


## Montant interne (euros) exprimé en francs (seuils et nombre de pièces, quelle que soit la date).
static func en_francs(eur: float) -> float:
	return Format.en_devise(eur, "F")


## flux : res["flux"] du moteur ({revenus, frais, lignes}) ; vitesse : Partie.vitesse ; en_saut : saut en cours
## (ou mois franchi pendant un saut) ; ab : mois ÉCOULÉ dont c'est le flux (devise et règle de décembre).
## Renvoie {"or": {"n", "texte"} ou {}, "cuivre": {"n", "texte"} ou {}, "lignes": [String] (≤ 2),
## "raison": "" si au moins une pièce, sinon pas_de_flux | saut | pause | vitesse3 | sous_seuil}.
static func plan(flux: Dictionary, vitesse: int, en_saut: bool, ab: int) -> Dictionary:
	var r := {"or": {}, "cuivre": {}, "lignes": [], "raison": ""}
	if flux.is_empty():
		r["raison"] = "pas_de_flux"
	elif en_saut:
		r["raison"] = "saut"
	elif vitesse <= 0:
		r["raison"] = "pause"
	elif vitesse >= 3:
		r["raison"] = "vitesse3"
	if r["raison"] != "":
		return r
	var revenus := float(flux.get("revenus", 0.0))
	var frais := float(flux.get("frais", 0.0))
	var lignes: Array = flux.get("lignes", [])
	var n_or := nombre(en_francs(revenus))
	if n_or > 0:
		var texte := "+" + Format.ESPACE + Format.entier(revenus, ab)
		if _verses_en_decembre(lignes, ab):
			var avec := texte + " ce mois-ci"
			texte = (avec if avec.length() <= MAX_CAR else texte) + "\nversés en décembre"
		r["or"] = {"n": n_or, "texte": texte}
		r["lignes"] = _lignes(lignes, ab)
	var n_cu := nombre(en_francs(frais))
	if n_cu > 0:
		var moins := Format.MOINS + Format.ESPACE + Format.entier(frais, ab)
		r["cuivre"] = {"n": n_cu, "texte": moins + (" de frais" if (moins + " de frais").length() <= MAX_CAR else "\nde frais")}
	if n_or == 0 and n_cu == 0:
		r["raison"] = "sous_seuil"
	return r


## Vrai si toutes les lignes de revenus sont créditées en décembre et que le mois écoulé n'est pas décembre.
static func _verses_en_decembre(lignes: Array, ab: int) -> bool:
	if Dates.mois(ab) == 12:
		return false
	var vues := 0
	for l: Dictionary in lignes:
		if str(l.get("genre", "")) in GENRES_REVENUS:
			vues += 1
			if not bool(l.get("verse_en_decembre", false)):
				return false
	return vues > 0


## « Elf : + 840 F » pour les coupons et dividendes au-dessus du seuil, les plus gros d'abord, 2 au plus. Au-delà
## de MAX_CAR caractères, le nom passe sur sa ligne (« Emprunt d'État : » / « + 600 F »), raccourci par « … » si besoin.
static func _lignes(lignes: Array, ab: int) -> Array:
	var retenues: Array = []
	for l: Dictionary in lignes:
		if str(l.get("genre", "")) in GENRES_LIGNES and nombre(en_francs(float(l.get("montant", 0.0)))) > 0:
			retenues.append(l)
	retenues.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["montant"]) > float(b["montant"]))
	var textes: Array = []
	for l: Dictionary in retenues.slice(0, MAX_LIGNES):
		var nom := str(l.get("nom", l.get("id", "")))
		var montant := "+" + Format.ESPACE + Format.entier(float(l["montant"]), ab)
		var une := nom + Format.ESPACE + ":" + Format.ESPACE + montant
		if une.length() <= MAX_CAR:
			textes.append(une)
		else:
			if nom.length() + 2 > MAX_CAR:
				nom = nom.left(MAX_CAR - 3) + "…"
			textes.append(nom + Format.ESPACE + ":\n" + montant)
	return textes
