class_name Versements
extends RefCounted
## Versements automatiques mensuels (11 §8, règles VP1 à VP11) : un ordre permanent qui verse chaque mois le
## même montant du compte courant vers le Livret A, l'assurance-vie ou la SICAV ; le PEL garde son versement
## obligatoire (pel.mensuel, 3 600 F par an au moins). Aucune dépendance aux nœuds.
## Plans : EtatPartie.joueur.versements (pid -> { montant, depuis, refus, suspendu }), dans l'ordre de création.
## Comptes de l'année (relevé de décembre) : EtatPartie.banque.versements_annee (pid -> { nb, total, frais }).
## Historique : une entrée à chaque réglage (programmé, modifié, arrêté, réactivé) et chaque incident ; les
## versements réussis n'y figurent pas un par un, mais groupés dans le relevé de décembre.

const EPS := 0.005


static func params() -> Dictionary:
	return Banquier.donnees()["versements"]


static func eligible(pid: String) -> bool:
	return params()["eligibles"].has(pid)


## Le produit accepte-t-il un réglage de versement mensuel (plans éligibles et PEL) ?
static func reglable(pid: String) -> bool:
	return eligible(pid) or pid == "pel"


static func minimum(pid: String) -> float:
	if pid == "pel":
		return Produits.f(float(Produits.params()["pel"]["mensuel_min_F"]))
	return Produits.f(float(params()["eligibles"].get(pid, {}).get("min_F", 100.0)))


static func frais_pct(pid: String) -> float:
	return float(params()["eligibles"].get(pid, {}).get("frais_pct", 0.0))


## Montants proposés (euros) : 100, 200, 300, 500, 1 000 F au-dessus du minimum du produit (VP10).
static func montants(pid: String) -> Array:
	var liste: Array = params()["pel_montants_F"] if pid == "pel" else params()["montants_F"]
	var out := []
	for x in liste:
		var v := Produits.f(float(x))
		if v >= minimum(pid) - EPS:
			out.append(v)
	return out


## Bulle (?) d'un produit sans versement automatique (emprunt d'État, actions), ou du PEL.
static func texte_non_eligible(pid: String) -> String:
	var ne: Dictionary = params()["non_eligibles"]
	if ne.has(pid):
		return str(ne[pid])
	if str(Banquier.info_produit(pid).get("type", "")) == "action":
		return str(ne["action"])
	return ""


static func nom(pid: String) -> String:
	if pid == "livret":
		return "le Livret A"
	if pid == "pel":
		return "le PEL"
	if pid == "av":
		return "l'assurance-vie"
	return "la SICAV"


## Plan du joueur sur pid ({} si aucun). Le PEL est rendu sous la même forme.
static func plan(e: EtatPartie, pid: String) -> Dictionary:
	if pid == "pel":
		if e.joueur.pel.is_empty():
			return {}
		return {"montant": float(e.joueur.pel["mensuel"]), "depuis": int(e.joueur.pel["ouvert_m"]), "refus": 0, "suspendu": ""}
	return e.joueur.versements.get(pid, {})


static func actif(e: EtatPartie, pid: String) -> bool:
	var p := plan(e, pid)
	return not p.is_empty() and str(p.get("suspendu", "")) == ""


## Total des versements automatiques actifs, par mois (PEL compris) : la ligne du budget (VP11).
static func total_mensuel(e: EtatPartie) -> float:
	var s := 0.0
	if not e.joueur.pel.is_empty():
		s += float(e.joueur.pel["mensuel"])
	for pid in e.joueur.versements:
		if str(e.joueur.versements[pid].get("suspendu", "")) == "":
			s += float(e.joueur.versements[pid]["montant"])
	return s


# =====================================================================
# Réglages du joueur (VP10) : effet le mois suivant
# =====================================================================

static func programmer(e: EtatPartie, pid: String, montant: float) -> Dictionary:
	var a := e.ab_courant()
	if not reglable(pid):
		return {"ok": false, "msg": texte_non_eligible(pid)}
	if not Banquier.presente(e, pid):
		return {"ok": false, "msg": "M. Lefranc ne vous a pas encore présenté ce produit."}
	if montant < minimum(pid) - EPS:
		return {"ok": false, "msg": "Au moins %s par mois." % Format.montant(minimum(pid), a)}
	var v := _vars(e, pid, montant)
	if pid == "pel":
		if e.joueur.pel.is_empty():
			return {"ok": false, "msg": "Ouvrez d'abord un PEL."}
		e.joueur.pel["mensuel"] = montant
		_historiser(e, "modifie", v)
		return {"ok": true, "montant": montant, "textes": []}
	var existant: Dictionary = e.joueur.versements.get(pid, {})
	var cle := "modifie" if not existant.is_empty() else "programme"
	if existant.is_empty():
		e.joueur.versements[pid] = {"montant": montant, "depuis": e.m, "refus": 0, "suspendu": ""}
	else:
		existant["montant"] = montant
		existant["refus"] = 0
		existant["suspendu"] = ""
	_historiser(e, cle, v)
	# Textes de M. Lefranc à l'activation : lissage du prix (VP-B, SICAV), frais de chaque versement (VP-C)
	var textes := []
	if pid == "sicav":
		textes.append(str(params()["VPB"]))
	if frais_pct(pid) > 0.0:
		textes.append(Format.gabarit(str(params()["VPC"]), v))
	return {"ok": true, "montant": montant, "textes": textes}


static func arreter(e: EtatPartie, pid: String) -> Dictionary:
	if not e.joueur.versements.has(pid):
		return {"ok": false, "msg": "Aucun versement automatique sur ce produit."}
	var montant := float(e.joueur.versements[pid]["montant"])
	e.joueur.versements.erase(pid)
	_historiser(e, "arrete", _vars(e, pid, montant))
	return {"ok": true}


static func reactiver(e: EtatPartie, pid: String) -> Dictionary:
	var p: Dictionary = e.joueur.versements.get(pid, {})
	if p.is_empty():
		return {"ok": false, "msg": "Aucun versement automatique sur ce produit."}
	if pid == "livret" and e.place_livret(e.joueur) <= EPS:
		return {"ok": false, "msg": "Le Livret A est plein : rien à verser pour l'instant."}
	p["suspendu"] = ""
	p["refus"] = 0
	_historiser(e, "reactive", _vars(e, pid, float(p["montant"])))
	return {"ok": true}


static func _vars(e: EtatPartie, pid: String, montant: float) -> Dictionary:
	var a := e.ab_courant()
	var fr := montant * frais_pct(pid) / 100.0
	return {"v": Format.entier(montant, a), "produit": nom(pid), "debut": Dates.texte(a + 1), "pid": pid, "montant": montant,
		"e_pct": Format.nombre(frais_pct(pid), 0), "frais_v": Format.entier(fr, a), "frais_an": Format.entier(12.0 * fr, a),
		"plafond": Format.entier(Marche.plafond_livret(a), a)}


static func _historiser(e: EtatPartie, cle: String, v: Dictionary) -> void:
	var t: Dictionary = params()[cle]
	e.historiser_evenement({"type": "versement", "source": "banque", "cls": "neutre", "produit": v["pid"],
		"titre": str(t["titre"]), "texte": Format.gabarit(str(t["texte"]), v)})


# =====================================================================
# Exécution (VP1 à VP9), au début du mois, après le salaire et le versement du PEL
# =====================================================================

## Compte de l'année pour le relevé de décembre.
static func noter(e: EtatPartie, pid: String, montant: float, frais: float) -> void:
	var va: Dictionary = e.banque.get("versements_annee", {})
	var c: Dictionary = va.get(pid, {"nb": 0, "total": 0.0, "frais": 0.0})
	c["nb"] = int(c["nb"]) + 1
	c["total"] = float(c["total"]) + montant
	c["frais"] = float(c["frais"]) + frais
	va[pid] = c
	e.banque["versements_annee"] = va


static func executer(e: EtatPartie, notifs: Array) -> void:
	var w := e.joueur
	_controle_pel(e, notifs)
	for pid in w.versements.keys():
		var p: Dictionary = w.versements[pid]
		if str(p.get("suspendu", "")) != "" or int(p.get("depuis", 0)) >= e.m:
			continue
		var v := float(p["montant"])
		var vars := _vars(e, pid, v)
		# VP5 : Livret A plafonné (les intérêts du 31/12 peuvent dépasser le plafond)
		if pid == "livret":
			var place := e.place_livret(w)
			if place <= EPS:
				p["suspendu"] = "plafond"
				_msg(e, notifs, "suspendu_plafond", vars, true)
				continue
			v = minf(v, place)
		# VP3 : tout ou rien, jamais de découvert (le compte, dépenses du mois déjà réglées, reste positif)
		if w.cc - v < -EPS:
			p["refus"] = int(p.get("refus", 0)) + 1
			if int(p["refus"]) >= int(params()["refus_max"]):
				p["suspendu"] = "refus"
				_msg(e, notifs, "suspendu_refus", vars, true)
			else:
				_msg(e, notifs, "refus", vars, false)
			continue
		p["refus"] = 0
		var frais := 0.0
		match pid:
			"livret":
				w.cc -= v
				w.livret += v
			"av":
				var r := Produits.verser_av(e, w, v)
				frais = float(r.get("frais", 0.0))
				e._noter_frais(w, frais)
			"sicav":
				# Achat à la valeur liquidative du mois, en fractions de part (VP8) ; frais d'entrée et jumeau sans frais
				var d := e.acheter(w, "sicav", v)
				frais = float(d.get("frais", 0.0))
		noter(e, pid, v, frais)
		e._noter_utilise(pid)
	e._enregistrer_hist()


## VP6 : à chaque date anniversaire du PEL, 3 600 F de versements sur les 12 derniers mois ; sinon le manque
## est prélevé si le compte le permet, et le plan est clos dans le cas contraire.
static func _controle_pel(e: EtatPartie, notifs: Array) -> void:
	var w := e.joueur
	if w.pel.is_empty():
		return
	var age := e.m - int(w.pel["ouvert_m"])
	if age <= 0 or age % 12 != 0:
		return
	var a := e.ab_courant()
	var mini := Produits.f(float(params()["pel_min_annuel_F"]))
	var manque := mini - float(w.pel.get("verse_annee", 0.0))
	w.pel["verse_annee"] = 0.0
	if manque <= EPS:
		return
	if w.cc - manque >= -EPS:
		w.cc -= manque
		w.pel["solde"] = float(w.pel["solde"]) + manque
		w.pel["verse"] = float(w.pel["verse"]) + manque
		_msg(e, notifs, "pel_regularise", {"manque": Format.entier(manque, a)}, false)
	else:
		var d := Produits.cloturer_pel(e, w)
		_msg(e, notifs, "pel_clos", {"manque": Format.entier(manque, a), "recu": Format.entier(float(d.get("recu", 0.0)), a)}, true)


static func _msg(e: EtatPartie, notifs: Array, cle: String, v: Dictionary, persistant: bool) -> void:
	var t: Dictionary = params()[cle]
	Banquier._message(e, notifs, str(t["titre"]), Format.gabarit(str(t["texte"]), v), persistant)
	notifs[notifs.size() - 1]["type"] = "versement"


# =====================================================================
# Messages du mois (VP-A, plafond relevé) et relevé de décembre
# =====================================================================

static func messages_du_mois(e: EtatPartie, notifs: Array, v: Dictionary) -> void:
	var b := e.banque
	var w := e.joueur
	var a := e.ab_courant()
	# VP-A : une fois, 3 mois après le premier produit éligible détenu, si aucun plan n'est actif
	if int(b.get("premier_eligible_m", -1)) < 0:
		for pid in params()["eligibles"]:
			if Banquier.detenu(e, pid):
				b["premier_eligible_m"] = e.m
				break
	var p0 := int(b.get("premier_eligible_m", -1))
	if not bool(b.get("vpa_vu", false)) and p0 >= 0 and e.m >= p0 + int(params()["vpa_apres_mois"]) and w.versements.is_empty():
		b["vpa_vu"] = true
		var ex := Banquier.exemple(maxf(0.0, e.epargne_du_mois()), 0.4, 100.0, 100.0, 1000.0)
		var vals := v.duplicate()
		vals["v"] = Format.entier(ex, a)
		vals["v12"] = Format.entier(12.0 * ex, a)
		var t: Dictionary = params()["VPA"]
		Banquier._message(e, notifs, str(t["titre"]), Format.gabarit(str(t["texte"]), vals), true)
		notifs[notifs.size() - 1]["type"] = "versement"
	# VP5 : plafond du Livret A relevé alors que le plan est suspendu « plafond » (jamais réactivé d'office)
	var pl: Dictionary = w.versements.get("livret", {})
	if not pl.is_empty() and str(pl.get("suspendu", "")) == "plafond" and Marche.plafond_livret(a) > Marche.plafond_livret(a - 1) + EPS:
		_msg(e, notifs, "plafond_releve", {"plafond": Format.entier(Marche.plafond_livret(a), a)}, true)


## Phrase ajoutée au relevé de décembre : total de l'année et détail par produit (« Livret A 12 × 500 F »).
static func texte_releve(e: EtatPartie, vers: Dictionary) -> String:
	if vers.is_empty():
		return ""
	var a := e.ab_courant()
	var total := 0.0
	var parts := []
	for pid in vers:
		var c: Dictionary = vers[pid]
		total += float(c["total"])
		var court := str(Banquier.info_produit(pid).get("court", pid))
		var n := int(c["nb"])
		parts.append("%s : %d versement%s, %s" % [court, n, "s" if n > 1 else "", Format.entier(float(c["total"]), a)])
	return Format.gabarit(str(params()["releve"]), {"total": Format.entier(total, a), "detail": ", ".join(PackedStringArray(parts))})
