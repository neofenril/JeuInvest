class_name Portefeuille
extends RefCounted
## Avoirs d'un épargnant (le joueur ou un témoin). Montants en euros courants.

var cc := 0.0               # compte courant
var livret := 0.0           # Livret A
var livret_int := 0.0       # intérêts de l'année en cours, crédités le 31/12
var interets_total := 0.0
var lignes: Dictionary = {} # id du produit -> { "qte", "cout" (frais compris), "depuis", "qte_ombre" (jumeau sans frais) }
var frais := 0.0
var impots := 0.0
var agios := 0.0
# Démo V2 (11 §1.7) : produits d'épargne à taux garanti
var pel: Dictionary = {}       # {} ou { ouvert_m, taux, taux_hp, mensuel, solde, verse, interets, courus }
var emprunts: Array = []       # tranches { m, taux, nominal }
var av: Dictionary = {}        # {} ou { ouvert_m, valeur, courus, primes, ombre, ombre_courus }
var ombre_realise := 0.0       # jumeau sans frais : écart déjà réalisé lors des ventes (11 §5.2, formule 7)
# Versements automatiques mensuels (11 §8), hors PEL (dont le versement est dans pel.mensuel) :
# pid -> { montant, depuis, refus (refus de suite), suspendu ("" | "refus" | "plafond") }, dans l'ordre de création.
var versements: Dictionary = {}


func qte(id: String) -> float:
	return float(lignes[id]["qte"]) if lignes.has(id) else 0.0


func cout(id: String) -> float:
	return float(lignes[id]["cout"]) if lignes.has(id) else 0.0


func valeur_pel() -> float:
	return float(pel.get("solde", 0.0))


func valeur_emprunts() -> float:
	var s := 0.0
	for t in emprunts:
		s += float(t["nominal"])
	return s


func valeur_av() -> float:
	return float(av.get("valeur", 0.0))


## Épargne à taux garanti hors Livret A (PEL, emprunts d'État, assurance-vie), sans les intérêts courus.
func valeur_epargne() -> float:
	return valeur_pel() + valeur_emprunts() + valeur_av()


const CHAMPS := ["cc", "livret", "livret_int", "interets_total", "lignes", "frais", "impots", "agios", "pel", "emprunts", "av", "ombre_realise", "versements"]


## Sauvegarde : copie profonde de tous les champs.
func vers_dict() -> Dictionary:
	var d := {}
	for k in CHAMPS:
		var v: Variant = get(k)
		d[k] = v.duplicate(true) if (v is Dictionary or v is Array) else v
	return d


func depuis_dict(d: Dictionary) -> void:
	for k in CHAMPS:
		if d.has(k):
			var v: Variant = d[k]
			set(k, v.duplicate(true) if (v is Dictionary or v is Array) else v)
