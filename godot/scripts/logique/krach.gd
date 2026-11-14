class_name Krach
extends RefCounted
## Le Lundi noir et « Le krach, un an après » (lot 05-L, phase A ; lot_05.md D10, docs/15 §5.2, docs/19 §4.2).
## Fonctions statiques, sans état. Les montants sont dans l'unité de l'appelant (euros internes du moteur) : aucune
## conversion ici. Données : data/krach.json. Aucun « vous auriez dû » : trois chiffres, le choix réel entouré.

const MINIMUM_SICAV := 1.0   # budget minimal d'un achat de SICAV (comme EtatPartie.devis_achat)


static func donnees() -> Dictionary:
	return Donnees.charger("krach")


## Les 7 jours du Lundi noir (variation calculée sur les indices stockés, au dixième) : [{"jour", "indice", "variation" (%, 0.0 le 1er jour), "certitude" ("A"|"C")}].
static func jours(k: Dictionary = {}) -> Array:
	var d := k if not k.is_empty() else donnees()
	var out: Array = []
	var prec := 0.0
	for j in d["jours"]:
		var x: Dictionary = j.duplicate(true)
		var i := float(x["indice"])
		x["variation"] = 0.0 if out.is_empty() else snappedf((i / prec - 1.0) * 100.0, 0.1)
		prec = i
		out.append(x)
	return out


## Instantané pris à l'ouverture de la modale du krach (lecture seule d'une EtatPartie) :
## {"ab", "cc", "montant_renforcer" (part proposée par « Renforcer » du compte courant), "choix" ("" jusqu'à la
## résolution), "exemple": false, "lignes": [{"id", "nom", "type" ("action"|"sicav"), "qte", "cout", "cours"}]}.
## cours = cours du mois du krach (fin 10/1987). Si "lignes" est vide : utiliser instantane_exemple.
static func instantane(e: EtatPartie) -> Dictionary:
	var lignes: Array = []
	for id in e.joueur.lignes:
		var p := e.cours(id)
		if is_nan(p):
			continue
		lignes.append({"id": str(id), "nom": e.nom_ligne(id), "type": str(e.produit(id).get("type", "")),
			"qte": e.joueur.qte(id), "cout": e.joueur.cout(id), "cours": p})
	var part := float(Donnees.regles()["partSuggeree"])
	return {"ab": e.ab_courant(), "cc": e.joueur.cc, "montant_renforcer": maxf(0.0, part * e.joueur.cc),
		"choix": "", "exemple": false, "lignes": lignes}


## Exemple pour un joueur sans action ni SICAV : montant (unité de l'appelant, ex. 10 000 F convertis) de SICAV
## acheté au cours du krach ; « Renforcer » ajouterait krach.json > un_an_apres.exemple.renfort_part de ce montant.
static func instantane_exemple(id_sicav: String, cours: float, montant: float, ab: int, k: Dictionary = {}) -> Dictionary:
	var d := k if not k.is_empty() else donnees()
	return {"ab": ab, "cc": 0.0, "montant_renforcer": montant * float(d["un_an_apres"]["exemple"]["renfort_part"]),
		"choix": "", "exemple": true,
		"lignes": [{"id": id_sicav, "nom": id_sicav, "type": "sicav", "qte": montant / cours, "cout": montant, "cours": cours}]}


## Complète l'instantané avec le choix fait à la résolution : "vendre" | "rien" | "renforcer" (autre : aucun entouré).
static func completer(inst: Dictionary, choix_id: String) -> Dictionary:
	var i := inst.duplicate(true)
	i["choix"] = choix_id
	return i


## Valeur au cours du krach des lignes de l'instantané.
static func base(inst: Dictionary) -> float:
	var s := 0.0
	for l in inst["lignes"]:
		s += float(l["qte"]) * float(l["cours"])
	return s


## Les 3 barres. ctx (cours / taux / dividendes au 10/1988, fournis par l'appelant) :
##  "cours_fin" {id: cours fin 10/1988}, "dividendes" {id: dividende NET par titre versé entre 11/1987 et 10/1988},
##  "taux_impot" (part, ex. 0,16), "courtage" (Callable brut → frais, actions seulement ; absent = 0),
##  "entree_sicav" (part, ex. 0,02), "facteur_livret" (capital placé 11/1987 → 10/1988 au Livret A, ex. 1,04).
## Renvoie {"base", "vendu", "rien", "renforce", "mise" (argent ajouté par « Renforcer », frais compris)}.
##  vendu : lignes vendues au cours du krach, frais de courtage et impôt sur la plus-value du moteur, puis Livret A ;
##  rien : mêmes lignes au cours de 10/1988, dividendes reçus compris ;
##  renforce : rien + les titres achetés avec le montant proposé au cours du krach (mêmes proportions, frais compris),
##    dividendes compris. L'argent du renfort vient du compte courant : il n'est pas déduit de la barre (« mise »).
static func calculer(inst: Dictionary, ctx: Dictionary) -> Dictionary:
	var fin: Dictionary = ctx.get("cours_fin", {})
	var div: Dictionary = ctx.get("dividendes", {})
	var taux_impot := float(ctx.get("taux_impot", 0.0))
	var entree := float(ctx.get("entree_sicav", 0.0))
	var courtage: Callable = ctx.get("courtage", Callable())
	var facteur := float(ctx.get("facteur_livret", 1.0))
	var total_base := base(inst)

	var vendu := 0.0
	var rien := 0.0
	var extra := 0.0
	var mise := 0.0
	for l in inst["lignes"]:
		var id := str(l["id"])
		var qte := float(l["qte"])
		var p := float(l["cours"])
		var action: bool = l["type"] == "action"
		var brut := qte * p
		var frais := _courtage(courtage, brut) if action else 0.0
		var net := brut - frais
		var pv := net - float(l["cout"])
		vendu += net - maxf(0.0, pv) * taux_impot
		var pf := float(fin.get(id, p))
		var dv := float(div.get(id, 0.0))
		rien += qte * (pf + dv)
		if total_base > 0.0 and float(inst["montant_renforcer"]) > 0.0:
			var budget := float(inst["montant_renforcer"]) * brut / total_base
			var q := 0.0
			var depense := 0.0
			if action:
				q = floorf(budget / p)
				while q > 0.0 and q * p + _courtage(courtage, q * p) > budget + 1e-9:
					q -= 1.0
				depense = q * p + (_courtage(courtage, q * p) if q > 0.0 else 0.0)
			elif budget >= MINIMUM_SICAV:
				q = budget * (1.0 - entree) / p
				depense = budget
			extra += q * (pf + dv)
			mise += depense
	return {"base": total_base, "vendu": vendu * facteur, "rien": rien, "renforce": rien + extra, "mise": mise}


static func _courtage(c: Callable, brut: float) -> float:
	return float(c.call(brut)) if c.is_valid() and brut > 0.0 else 0.0


## Contenu de la modale « Le krach, un an après » (10/1988), contrat lot_05.md §4.3. ab : mois courant.
static func contenu_gazette(inst: Dictionary, ctx: Dictionary, ab: int, k: Dictionary = {}) -> Dictionary:
	var d := k if not k.is_empty() else donnees()
	var u: Dictionary = d["un_an_apres"]
	var r := calculer(inst, ctx)
	var cible := ""
	if not bool(inst.get("exemple", false)):
		cible = {"vendre": "vendu", "rien": "rien", "renforcer": "renforce"}.get(str(inst.get("choix", "")), "")
	var barres: Array = []
	for id in ["vendu", "rien", "renforce"]:
		barres.append({"id": id, "titre": str(u["titres_barres"][id]), "valeur": float(r[id]), "choisi": id == cible})
	return {"kind": "gazette", "source": "media", "date": Dates.texte(ab, true), "ab": ab,
		"titre": str(u["titre"]), "texte": str(u["texte"]), "garde_fou": str(u["garde_fou"]),
		"legende_renforce": str(u["legende_renforce"]), "mise": float(r["mise"]),
		"mention": str(u["mention"]) if bool(inst.get("exemple", false)) else "",
		"base": float(r["base"]), "barres": barres,
		"choix": [{"id": "ok", "titre": str(u["bouton"])}]}
