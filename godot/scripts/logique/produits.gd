class_name Produits
extends RefCounted
## Produits d'épargne de la démo V2 (11 §1.7) : PEL, emprunt d'État 10 ans, assurance-vie fonds en francs.
## Fonctions statiques qui agissent sur un portefeuille d'une partie (aucun nœud). Montants en euros.
## Simplifications (bulles « Simplifié » des fiches) : prime du PEL comprise dans le taux, clôture avant 4 ans
## au taux du CEL ; emprunt revendu au prix d'achat plus les intérêts courus (A13) ; assurance-vie : intérêts
## crédités au 31/12, rachat imposé sur la part de gains selon l'âge du contrat (A42).

const EPS := 0.005


static func params() -> Dictionary:
	return Donnees.charger("banque").get("parametres", {})


static func f(francs: float) -> float:
	return francs / Format.TAUX_EURO


# =====================================================================
# Taux datés
# =====================================================================

## Taux du PEL ouvert à la date a : [taux prime comprise, taux hors prime] (%).
static func taux_pel(a: int) -> Array:
	var v: Variant = Donnees.en_vigueur(params()["pel"]["taux"], a)
	if v == null:
		v = params()["pel"]["taux"][0]
	return [float(v[1]), float(v[2])]


## Taux net du fonds en francs crédité pour l'année (%).
static func taux_av(annee: int) -> float:
	var t: Dictionary = params()["av"]["taux"]
	if t.has(str(annee)):
		return float(t[str(annee)])
	var cles := t.keys()
	cles.sort()
	return float(t[cles[0]]) if annee < int(cles[0]) else float(t[cles[cles.size() - 1]])


## Taux de l'emprunt d'État 10 ans acheté l'année donnée (taux long, series.json).
static func taux_emprunt(annee: int) -> float:
	return float(Donnees.series()["annuel"][str(annee)][2])


## Prélèvement (%) sur les gains d'un rachat d'assurance-vie pour un contrat de « age » mois.
static func taux_rachat_av(age: int) -> float:
	var t := 0.0
	for x in params()["av"]["rachat"]:
		if age >= int(x[0]):
			t = float(x[1])
	return t


# =====================================================================
# PEL
# =====================================================================

static func ouvrir_pel(e: EtatPartie, w: Portefeuille, depot: float, mensuel: float) -> Dictionary:
	var p: Dictionary = params()["pel"]
	var a := e.ab_courant()
	if not w.pel.is_empty():
		return {"ok": false, "msg": "Vous avez déjà un PEL."}
	if depot < f(float(p["mensuel_min_F"])) - EPS:
		return {"ok": false, "msg": "Un PEL s'ouvre avec %s au moins." % Format.montant(f(float(p["mensuel_min_F"])), a)}
	if depot > w.cc + EPS:
		return {"ok": false, "msg": "Le compte courant ne suffit pas."}
	var t := taux_pel(a)
	w.cc -= depot
	w.pel = {"ouvert_m": e.m, "taux": t[0], "taux_hp": t[1], "mensuel": maxf(mensuel, f(float(p["mensuel_min_F"]))),
		"solde": depot, "verse": depot, "interets": 0.0, "courus": 0.0, "verse_annee": depot}
	return {"ok": true, "montant": depot}


static func verser_pel(e: EtatPartie, w: Portefeuille, montant: float) -> Dictionary:
	if w.pel.is_empty():
		return {"ok": false, "msg": "Pas de PEL ouvert."}
	var plaf := f(float(params()["pel"]["plafond_F"]))
	montant = minf(montant, maxf(0.0, plaf - float(w.pel["verse"])))
	if montant <= EPS:
		return {"ok": false, "msg": "Indiquez un montant."}
	if montant > w.cc + EPS:
		return {"ok": false, "msg": "Le compte courant ne suffit pas."}
	w.cc -= montant
	w.pel["solde"] = float(w.pel["solde"]) + montant
	w.pel["verse"] = float(w.pel["verse"]) + montant
	w.pel["verse_annee"] = float(w.pel.get("verse_annee", 0.0)) + montant
	return {"ok": true, "montant": montant}


## Clôture : avant 4 ans, les intérêts sont recalculés au taux réduit (sans prime).
static func devis_cloture_pel(e: EtatPartie, w: Portefeuille) -> Dictionary:
	if w.pel.is_empty():
		return {"ok": false, "msg": "Pas de PEL ouvert."}
	var p: Dictionary = params()["pel"]
	var age := e.m - int(w.pel["ouvert_m"])
	var interets := float(w.pel["interets"]) + float(w.pel["courus"])
	var anticipee := age < int(p["duree_mois"])
	var garde := interets
	if anticipee:
		garde = interets * float(p["taux_cloture_anticipee"]) / float(w.pel["taux"])
	var recu := float(w.pel["verse"]) + garde
	return {"ok": true, "recu": recu, "penalite": interets - garde, "anticipee": anticipee, "age": age,
		"echeance_ab": e.ab_de(int(w.pel["ouvert_m"]) + int(p["duree_mois"]))}


static func cloturer_pel(e: EtatPartie, w: Portefeuille) -> Dictionary:
	var d := devis_cloture_pel(e, w)
	if not d["ok"]:
		return d
	w.cc += float(d["recu"])
	w.pel = {}
	return d


# =====================================================================
# Emprunt d'État
# =====================================================================

static func acheter_emprunt(e: EtatPartie, w: Portefeuille, montant: float) -> Dictionary:
	if montant <= EPS:
		return {"ok": false, "msg": "Indiquez un montant."}
	if montant > w.cc + EPS:
		return {"ok": false, "msg": "Le compte courant ne suffit pas."}
	var t := taux_emprunt(Dates.annee(e.ab_courant()))
	w.cc -= montant
	w.emprunts.append({"m": e.m, "taux": t, "nominal": montant})
	return {"ok": true, "montant": montant, "taux": t}


## Revente (au prix d'achat) d'un montant de nominal, des tranches les plus anciennes aux plus récentes,
## avec les intérêts courus depuis le dernier coupon, imposés comme le coupon.
static func devis_vente_emprunt(e: EtatPartie, w: Portefeuille, montant: float, tout := false) -> Dictionary:
	var total := w.valeur_emprunts()
	if total <= EPS:
		return {"ok": false, "msg": "Vous n'avez pas d'emprunt d'État."}
	var reste := total if tout else minf(maxf(0.0, montant), total)
	if reste <= EPS:
		return {"ok": false, "msg": "Indiquez un montant."}
	var taux_impot := float(params()["emprunt"]["impot_coupons"]) / 100.0
	var couru := 0.0
	var parts := []
	for t in w.emprunts:
		if reste <= EPS:
			break
		var part := minf(reste, float(t["nominal"]))
		var mois := (e.m - int(t["m"])) % 12
		couru += part * float(t["taux"]) / 100.0 * mois / 12.0
		parts.append(part)
		reste -= part
	var nominal := total if tout else minf(maxf(0.0, montant), total)
	var impot := couru * taux_impot
	return {"ok": true, "nominal": nominal, "couru": couru, "impot": impot, "recu": nominal + couru - impot, "parts": parts}


static func vendre_emprunt(e: EtatPartie, w: Portefeuille, montant: float, tout := false) -> Dictionary:
	var d := devis_vente_emprunt(e, w, montant, tout)
	if not d["ok"]:
		return d
	var parts: Array = d["parts"]
	for i in parts.size():
		w.emprunts[i]["nominal"] = float(w.emprunts[i]["nominal"]) - float(parts[i])
	w.emprunts = w.emprunts.filter(func(t: Dictionary) -> bool: return float(t["nominal"]) > EPS)
	w.cc += float(d["recu"])
	w.impots += float(d["impot"])
	return d


# =====================================================================
# Assurance-vie (fonds en francs)
# =====================================================================

static func verser_av(e: EtatPartie, w: Portefeuille, montant: float) -> Dictionary:
	if montant <= EPS:
		return {"ok": false, "msg": "Indiquez un montant."}
	if montant > w.cc + EPS:
		return {"ok": false, "msg": "Le compte courant ne suffit pas."}
	var frais := montant * float(params()["av"]["entree"]) / 100.0
	if w.av.is_empty():
		w.av = {"ouvert_m": e.m, "valeur": 0.0, "courus": 0.0, "primes": 0.0, "ombre": 0.0, "ombre_courus": 0.0}
	w.cc -= montant
	w.av["valeur"] = float(w.av["valeur"]) + montant - frais
	w.av["primes"] = float(w.av["primes"]) + montant
	w.av["ombre"] = float(w.av["ombre"]) + montant
	w.frais += frais
	return {"ok": true, "montant": montant, "frais": frais, "net": montant - frais}


## Rachat : seule la part de gains du retrait est imposée, au taux de l'âge du contrat (11 §1.7.2).
static func devis_rachat_av(e: EtatPartie, w: Portefeuille, montant: float, tout := false) -> Dictionary:
	if w.av.is_empty():
		return {"ok": false, "msg": "Pas d'assurance-vie."}
	var dispo := float(w.av["valeur"]) + float(w.av["courus"])
	montant = dispo if tout else minf(maxf(0.0, montant), dispo)
	if montant <= EPS:
		return {"ok": false, "msg": "Indiquez un montant."}
	var age := e.m - int(w.av["ouvert_m"])
	var gains_total := maxf(0.0, dispo - float(w.av["primes"]))
	var gains := montant * gains_total / dispo if dispo > 0.0 else 0.0
	var taux := taux_rachat_av(age)
	var impot := gains * taux / 100.0
	var exo := 0
	for x in params()["av"]["rachat"]:
		if float(x[1]) == 0.0:
			exo = int(x[0])
	return {"ok": true, "montant": montant, "dispo": dispo, "gains": gains, "taux": taux, "impot": impot, "recu": montant - impot,
		"age": age, "exoneration_ab": e.ab_de(int(w.av["ouvert_m"]) + exo), "tout": tout or montant >= dispo - EPS}


static func racheter_av(e: EtatPartie, w: Portefeuille, montant: float, tout := false) -> Dictionary:
	var d := devis_rachat_av(e, w, montant, tout)
	if not d["ok"]:
		return d
	var x := float(d["montant"]) / float(d["dispo"])
	var ombre_part := x * (float(w.av["ombre"]) + float(w.av["ombre_courus"]))
	w.ombre_realise += ombre_part - float(d["montant"])
	if d["tout"]:
		w.av = {}
	else:
		for k in ["valeur", "courus", "ombre", "ombre_courus"]:
			w.av[k] = float(w.av[k]) * (1.0 - x)
		w.av["primes"] = maxf(0.0, float(w.av["primes"]) - (float(d["montant"]) - float(d["gains"])))
	w.cc += float(d["recu"])
	w.impots += float(d["impot"])
	return d


# =====================================================================
# Le temps
# =====================================================================

## Fin du mois : intérêts courus du PEL et de l'assurance-vie, crédités au 31/12. Renvoie les intérêts crédités.
static func fin_de_mois(e: EtatPartie, w: Portefeuille) -> float:
	var a := e.ab_courant()
	var decembre := Dates.mois(a) == 12
	var credite := 0.0
	var du_joueur := w == e.joueur
	if not w.pel.is_empty():
		var acquis := float(w.pel["solde"]) * float(w.pel["taux"]) / 100.0 / 12.0
		w.pel["courus"] = float(w.pel["courus"]) + acquis
		if du_joueur:
			e.noter_flux("interets", "pel", acquis, not decembre)
		if decembre:
			var i := float(w.pel["courus"])
			w.pel["solde"] = float(w.pel["solde"]) + i
			w.pel["interets"] = float(w.pel["interets"]) + i
			w.pel["courus"] = 0.0
			credite += i
	if not w.av.is_empty():
		var t := taux_av(Dates.annee(a)) / 100.0 / 12.0
		w.av["courus"] = float(w.av["courus"]) + float(w.av["valeur"]) * t
		if du_joueur:
			e.noter_flux("interets", "av", float(w.av["valeur"]) * t, not decembre)
		w.av["ombre_courus"] = float(w.av["ombre_courus"]) + float(w.av["ombre"]) * t
		if decembre:
			var i2 := float(w.av["courus"])
			w.av["valeur"] = float(w.av["valeur"]) + i2
			w.av["ombre"] = float(w.av["ombre"]) + float(w.av["ombre_courus"])
			w.av["courus"] = 0.0
			w.av["ombre_courus"] = 0.0
			credite += i2
	return credite


## Début du mois : versement automatique du PEL, coupons des emprunts d'État (à la date anniversaire).
## Renvoie les notifications et le total des coupons nets.
static func entree_mois(e: EtatPartie, w: Portefeuille, notifs: Array, avec_notifs: bool) -> float:
	var a := e.ab_courant()
	if not w.pel.is_empty() and int(w.pel["ouvert_m"]) < e.m:
		var v := minf(float(w.pel["mensuel"]), maxf(0.0, f(float(params()["pel"]["plafond_F"])) - float(w.pel["verse"])))
		if v > EPS and w.cc >= v:
			w.cc -= v
			w.pel["solde"] = float(w.pel["solde"]) + v
			w.pel["verse"] = float(w.pel["verse"]) + v
			w.pel["verse_annee"] = float(w.pel.get("verse_annee", 0.0)) + v
			if w == e.joueur and e.banquier_actif():
				Versements.noter(e, "pel", v, 0.0)
		elif v > EPS and avec_notifs:
			notifs.append({"type": "info", "source": "banque", "cls": "neutre", "titre": "Versement du PEL reporté",
				"texte": "Le compte courant ne suffisait pas pour le versement de %s ce mois-ci." % Format.entier(v, a)})
	var net_total := 0.0
	var taux_impot := float(params()["emprunt"]["impot_coupons"]) / 100.0
	for t in w.emprunts:
		var age := e.m - int(t["m"])
		if age > 0 and age % 12 == 0:
			var coupon := float(t["nominal"]) * float(t["taux"]) / 100.0
			var impot := coupon * taux_impot
			w.cc += coupon - impot
			w.impots += impot
			net_total += coupon - impot
			if w == e.joueur:
				e.noter_flux("coupon", "emprunt", coupon - impot)
	if net_total > EPS and avec_notifs:
		notifs.append({"type": "coupon", "source": "banque", "cls": "gain", "montant": net_total, "titre": "Coupon de l'emprunt d'État",
			"texte": "L'État vous verse les intérêts de l'année, après 16 %% d'impôt : %s sur votre compte courant." % Format.montant(net_total, a, false, true)})
	return net_total
