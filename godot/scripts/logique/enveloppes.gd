class_name Enveloppes
extends RefCounted
## Types de produits du lot 10a (M5) : PEA (enveloppe), SCPI (parts, loyers trimestriels, vente différée), produits « message »
## (PEP). Fonctions statiques sur un EtatPartie et un Portefeuille ; aucune dépendance aux nœuds. Tous les paramètres sont
## dans le catalogue (data/produits.json > parametres.pea / parametres.scpi) et dans data/series.json (plafond du PEA) et
## data/regles.json (impôts : cto avant 5 ans, pea5 après). Montants en euros internes (francs convertis par Produits.f).
##
## PEA : w.pea = {} ou { ouvert_m, verse, cc, lignes: { id: { qte, cout, depuis } } }. Versements en numéraire seulement
## (verser_pea) jusqu'au plafond de la date ; achats et ventes de titres éligibles dans l'enveloppe (produit du compte PEA,
## ni courtage nouveau ni impôt dans l'enveloppe) ; retrait avant 5 ans = clôture du plan (impôt du compte-titres sur le gain),
## après 5 ans = retrait libre au taux « pea5 » de la date (0 en 1992-1997).
## SCPI : w.scpi = {} ou { parts, cout, depuis, dernier_loyer } ; w.ventes_differees = [ { produit, parts, m_ordre,
## m_execution, estime } ]. Une vente de parts est exécutée exactement `delai_vente_mois` mois plus tard au prix de revente
## du mois d'exécution ; annulable avant. Jamais utilisée par la vente automatique des projets (hors w.lignes), jamais
## recopiée chez les témoins (R-MIROIR ne la voit pas).

const EPS := 0.005


# =====================================================================
# PEA
# =====================================================================

static func params_pea() -> Dictionary:
	return Produits.params().get("pea", {})


static func a_pea(w: Portefeuille) -> bool:
	return not w.pea.is_empty()


## Plafond des versements à la date a (euros) ; 0 si le PEA n'existe pas encore.
static func plafond_pea(a: int) -> float:
	var v: Variant = Donnees.en_vigueur(Donnees.series().get("peaPlafond", []), a)
	if v == null:
		return 0.0
	return Format.vers_euros(float(v[1]), v[2] if (v as Array).size() > 2 else "€")


static func pea_disponible(a: int) -> bool:
	return a >= Dates.lire(str(Donnees.produit("pea").get("naissance", "9999-12")))


## Ouvre le plan (une fois). Refus avant 07/1992 ou si déjà ouvert.
static func ouvrir_pea(e: EtatPartie, w: Portefeuille) -> Dictionary:
	if not pea_disponible(e.ab_courant()):
		return {"ok": false, "msg": "Le PEA n'existe pas encore."}
	if a_pea(w):
		return {"ok": false, "msg": "Vous avez déjà un PEA."}
	w.pea = {"ouvert_m": e.m, "verse": 0.0, "cc": 0.0, "lignes": {}}
	return {"ok": true}


## Versement en numéraire du compte courant vers le PEA, dans la limite du plafond et du compte.
static func verser_pea(e: EtatPartie, w: Portefeuille, montant: float) -> Dictionary:
	if not a_pea(w):
		return {"ok": false, "msg": "Ouvrez d'abord un PEA."}
	var reste := plafond_pea(e.ab_courant()) - float(w.pea["verse"])
	var v := minf(maxf(0.0, montant), minf(reste, maxf(0.0, w.cc)))
	if v <= EPS:
		return {"ok": false, "msg": "Versement impossible (plafond atteint ou compte insuffisant)."}
	w.cc -= v
	w.pea["cc"] = float(w.pea["cc"]) + v
	w.pea["verse"] = float(w.pea["verse"]) + v
	return {"ok": true, "verse": v}


## Le titre est-il éligible au PEA (action ou SICAV actions, jamais une SICAV monétaire) ?
static func eligible_pea(e: EtatPartie, id: String) -> bool:
	var pr := e.produit(id)
	var cat := Donnees.produit(id)
	var types: Array = params_pea().get("eligibles", ["action", "sicav"])
	return types.has(str(pr.get("type", ""))) and bool(cat.get("pea_eligible", true))


## Achat dans l'enveloppe : le budget vient des espèces du PEA (versements en numéraire), jamais du compte courant.
static func acheter_pea(e: EtatPartie, w: Portefeuille, id: String, budget: float) -> Dictionary:
	if not a_pea(w):
		return {"ok": false, "msg": "Ouvrez d'abord un PEA."}
	if not eligible_pea(e, id):
		return {"ok": false, "msg": "Ce produit n'est pas éligible au PEA."}
	var d := e.devis_achat(id, minf(maxf(0.0, budget), float(w.pea["cc"])))
	if not d["ok"]:
		return d
	w.pea["cc"] = float(w.pea["cc"]) - float(d["total"])
	var lignes: Dictionary = w.pea["lignes"]
	if not lignes.has(id):
		lignes[id] = {"qte": 0.0, "cout": 0.0, "depuis": e.m}
	lignes[id]["qte"] = float(lignes[id]["qte"]) + float(d["qte"])
	lignes[id]["cout"] = float(lignes[id]["cout"]) + float(d["total"])
	w.frais += float(d["frais"])
	if w == e.joueur:
		e.stats["ordres"] += 1
		e._noter_frais(w, float(d["frais"]))
		e._noter_utilise(id)
		e._enregistrer_hist()
	return d


## Vente d'une ligne du PEA : le produit reste dans l'enveloppe (espèces du PEA), sans impôt tant que le plan vit.
static func vendre_pea(e: EtatPartie, w: Portefeuille, id: String, montant: float, tout := false) -> Dictionary:
	if not a_pea(w) or not (w.pea["lignes"] as Dictionary).has(id):
		return {"ok": false, "msg": "Vous ne détenez pas ce produit dans le PEA."}
	var l: Dictionary = w.pea["lignes"][id]
	var p := e.cours(id)
	if is_nan(p) or float(l["qte"]) <= 0.0:
		return {"ok": false, "msg": "Produit indisponible."}
	var q := float(l["qte"]) if tout else minf(float(l["qte"]), maxf(0.0, montant) / p)
	if q <= 0.0:
		return {"ok": false, "msg": "Indiquez un montant."}
	var frac := q / float(l["qte"])
	var brut := q * p
	var frais := Marche.frais_courtage(e.ab_courant(), brut) if str(e.produit(id).get("type", "")) == "action" else 0.0
	l["cout"] = float(l["cout"]) * (1.0 - frac)
	l["qte"] = float(l["qte"]) - q
	if float(l["qte"]) < 1e-9:
		(w.pea["lignes"] as Dictionary).erase(id)
	w.pea["cc"] = float(w.pea["cc"]) + brut - frais
	w.frais += frais
	if w == e.joueur:
		e.stats["ordres"] += 1
		e._noter_frais(w, frais)
		e._enregistrer_hist()
	return {"ok": true, "brut": brut, "frais": frais, "recu": brut - frais}


## Valeur du PEA : espèces + titres au cours.
static func valeur_pea(e: EtatPartie, w: Portefeuille, mois: int = -999) -> float:
	if not a_pea(w):
		return 0.0
	var s := float(w.pea["cc"])
	for id in w.pea["lignes"]:
		var p := e.cours(id, mois)
		if not is_nan(p):
			s += float(w.pea["lignes"][id]["qte"]) * p
	return s


## Ancienneté du plan en mois.
static func age_pea(e: EtatPartie, w: Portefeuille) -> int:
	return e.m - int(w.pea.get("ouvert_m", e.m)) if a_pea(w) else 0


## Retrait d'un montant. Avant 5 ans : clôture du plan (tout est vendu, impôt du compte-titres sur le gain de l'ensemble) ;
## après 5 ans : retrait libre, impôt « pea5 » de la date sur la part de gain retirée, le plan continue.
## Renvoie { ok, cloture, recu, impot, gain }.
static func retirer_pea(e: EtatPartie, w: Portefeuille, montant: float) -> Dictionary:
	if not a_pea(w):
		return {"ok": false, "msg": "Vous n'avez pas de PEA."}
	var a := e.ab_courant()
	var valeur := valeur_pea(e, w)
	if valeur <= EPS:
		return {"ok": false, "msg": "Le PEA est vide."}
	var duree := int(params_pea().get("duree_exoneration_mois", 60))
	var gain_total := valeur - float(w.pea["verse"])
	if age_pea(e, w) < duree:
		var taux := float(Marche.impot(a)["cto"])
		var impot := maxf(0.0, gain_total) * taux / 100.0
		var recu := valeur - impot
		w.frais += 0.0
		for id in (w.pea["lignes"] as Dictionary).keys():
			var p := e.cours(id)
			if not is_nan(p) and str(e.produit(id).get("type", "")) == "action":
				var fr := Marche.frais_courtage(a, float(w.pea["lignes"][id]["qte"]) * p)
				recu -= fr
				w.frais += fr
		w.cc += recu
		w.impots += impot
		if w == e.joueur:
			e.stats["impots"] += impot
			e._enregistrer_hist()
		w.pea = {}
		return {"ok": true, "cloture": true, "recu": recu, "impot": impot, "gain": gain_total}
	# Après la durée : retrait des espèces du PEA (les titres se vendent d'abord par vendre_pea)
	var v := minf(maxf(0.0, montant), float(w.pea["cc"]))
	if v <= EPS:
		return {"ok": false, "msg": "Vendez d'abord des titres du PEA."}
	var pea5: Variant = Marche.impot(a).get("pea5", null)
	var part_gain := maxf(0.0, gain_total) / maxf(valeur, EPS)
	var impot2 := v * part_gain * float(pea5 if pea5 != null else Marche.impot(a)["cto"]) / 100.0
	w.pea["cc"] = float(w.pea["cc"]) - v
	w.cc += v - impot2
	w.impots += impot2
	if w == e.joueur:
		e.stats["impots"] += impot2
		e._enregistrer_hist()
	return {"ok": true, "cloture": false, "recu": v - impot2, "impot": impot2, "gain": gain_total}


# =====================================================================
# SCPI
# =====================================================================

static func params_scpi() -> Dictionary:
	return Produits.params().get("scpi", {})


## Valeur de revente d'une part à la date a (euros) : dernière valeur datée atteinte, sinon la première.
static func prix_revente(a: int) -> float:
	var liste: Array = params_scpi()["revente_F"]
	var v: Variant = Donnees.en_vigueur(liste, a)
	if v == null:
		v = liste[0]
	return Produits.f(float(v[1]))


static func taux_loyer(a: int) -> float:
	var liste: Array = params_scpi()["loyer_pct"]
	var v: Variant = Donnees.en_vigueur(liste, a)
	if v == null:
		v = liste[0]
	return float(v[1])


static func prix_part() -> float:
	return Produits.f(float(params_scpi()["part_F"]))


static func parts(w: Portefeuille) -> float:
	return float(w.scpi.get("parts", 0.0))


## Parts déjà promises à une vente différée.
static func parts_en_vente(w: Portefeuille) -> float:
	var s := 0.0
	for v: Dictionary in w.ventes_differees:
		s += float(v["parts"])
	return s


## Valeur de la ligne : parts × valeur de revente datée (c''est elle que « Mon argent » affiche : les frais se voient tout de suite).
static func valeur_scpi(w: Portefeuille, a: int) -> float:
	return parts(w) * prix_revente(a)


static func acheter_scpi(e: EtatPartie, w: Portefeuille, budget: float) -> Dictionary:
	if e.ab_courant() < Dates.lire(str(Donnees.produit("scpi").get("naissance", "9999-12"))):
		return {"ok": false, "msg": "Produit indisponible."}
	var n := floorf(minf(maxf(0.0, budget), maxf(0.0, w.cc)) / prix_part() + 1e-9)
	if n < 1.0:
		return {"ok": false, "msg": "Il faut au moins le prix d'une part (%s)." % Format.montant(prix_part(), e.ab_courant(), true)}
	var total := n * prix_part()
	var frais := total * float(params_scpi()["frais_entree_pct"]) / 100.0
	w.cc -= total
	w.frais += frais
	if w.scpi.is_empty():
		w.scpi = {"parts": 0.0, "cout": 0.0, "depuis": e.m, "dernier_loyer": -1}
	w.scpi["parts"] = float(w.scpi["parts"]) + n
	w.scpi["cout"] = float(w.scpi["cout"]) + total
	if w == e.joueur:
		e.stats["ordres"] += 1
		e._noter_frais(w, frais)
		e._noter_utilise("scpi")
		e._enregistrer_hist()
	return {"ok": true, "parts": n, "total": total, "frais": frais}


## Crée une vente différée de `n` parts (libres : celles déjà en vente ne comptent pas). Renvoie { ok, vente?, msg? }.
static func vendre_scpi(e: EtatPartie, w: Portefeuille, n: int) -> Dictionary:
	var libres := parts(w) - parts_en_vente(w)
	if n < 1 or float(n) > libres + 1e-9:
		return {"ok": false, "msg": "Vous ne détenez pas autant de parts à vendre."}
	var delai := int(params_scpi()["delai_vente_mois"])
	var v := {"produit": "scpi", "parts": n, "m_ordre": e.m, "m_execution": e.m + delai, "estime": float(n) * prix_revente(e.ab_courant())}
	w.ventes_differees.append(v)
	return {"ok": true, "vente": v}


static func annuler_vente(w: Portefeuille, index: int) -> bool:
	if index < 0 or index >= w.ventes_differees.size():
		return false
	w.ventes_differees.remove_at(index)
	return true


## À l'entrée dans le mois (joueur seulement) : exécute les ventes différées échues (prix du mois d''exécution), puis verse
## les loyers trimestriels (mars, juin, septembre, décembre) au compte courant, imposés au taux de la convention du jeu.
## Renvoie le total des loyers nets (euros).
static func entree_mois(e: EtatPartie, w: Portefeuille, notifs: Array) -> float:
	var a := e.ab_courant()
	var restantes := []
	for v: Dictionary in w.ventes_differees:
		if int(v["m_execution"]) <= e.m:
			var n := minf(float(v["parts"]), parts(w))
			if n > 0.0:
				var recu := n * prix_revente(a)
				w.cc += recu
				w.scpi["parts"] = float(w.scpi["parts"]) - n
				w.scpi["cout"] = float(w.scpi["cout"]) * (1.0 - n / (n + float(w.scpi["parts"])))
				if float(w.scpi["parts"]) < 1e-9:
					w.scpi = {}
				v["recu"] = recu
				notifs.append({"type": "scpi", "source": "banque", "cls": "neutre", "produit": "scpi", "montant": recu,
					"titre": "Vente de parts de SCPI", "texte": "Votre vente de %d part(s) est exécutée : %s." % [int(n), Format.montant(recu, a)]})
		else:
			restantes.append(v)
	w.ventes_differees = restantes
	if w.scpi.is_empty() or Dates.mois(a) % int(params_scpi()["periodicite_loyers_mois"]) != 0:
		return 0.0
	var brut := parts(w) * prix_part() * taux_loyer(a) / 100.0 / 12.0 * float(params_scpi()["periodicite_loyers_mois"])
	var impot := brut * float(params_scpi()["impot_loyers_pct"]) / 100.0
	w.cc += brut - impot
	w.impots += impot
	w.scpi["dernier_loyer"] = e.m
	if w == e.joueur:
		e.stats["impots"] += impot
	return brut - impot


# =====================================================================
# Produits « message » (PEP)
# =====================================================================

## Notification sans pause d'un produit en mode « message » : fiche courte dans la notification, « En savoir plus » dans
## n["long"] / n["texte_long"] (mécanisme existant). Aucune fiche jouable (le produit n'est pas achetable).
static func notif_message(pid: String) -> Dictionary:
	var cat := Donnees.produit(pid)
	if cat.is_empty() or str(cat.get("mode_defaut", "")) != "message":
		return {}
	var long := str(cat.get("texte_long", cat.get("definition", "")))
	return {"type": "message", "source": "banque", "cls": "neutre", "produit": pid, "titre": str(cat.get("nom", pid)),
		"texte": str(cat.get("definition", "")), "persistant": false, "long": long, "texte_long": long}
