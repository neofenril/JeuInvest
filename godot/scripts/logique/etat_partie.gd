class_name EtatPartie
extends RefCounted
## Moteur d'une partie : état, déroulé d'un mois (03 §3.3), ordres, événements, témoins.
## Port de jeu/js/moteur.js, réduit au périmètre de la démo. Aucune dépendance aux nœuds.
## Montants internes en euros courants. m = index du mois dans la période (0 = janvier 1978 en P1).
##
## Chaque notification et chaque modale porte une « source » (maison | banque | media) : le bâtiment
## de la ville que l'interface anime.
##
## Démo V2 (config « banquier ») : les produits n'existent pour le joueur qu'après leur présentation par
## M. Lefranc (Banquier), la cadence des interruptions suit 13 §5.3, la naissance et l'héritage sont scriptés.

const EPS := 0.005
const VERSION_ETAT := 2          # 2 : historique des pop-ups, versements automatiques (préparés)
const HISTORIQUE_MAX := 600

# --- Configuration ---
var id_periode := "P1"
var profil := "jeune"
var graine_vie := 1
var sans_vie := false
var config_depart: Dictionary = {}
var naissances_aleatoires := true
var naissance_scriptee: Dictionary = {}   # { d: "AAAA-MM", jumeaux_proba }

# --- Données ---
var mk: Marche
var per: Dictionary
var regles: Dictionary
var sal: Dictionary
var vie: Dictionary

# --- État ---
var m := 0
var m_depart := 0
var m_fin := 179
var salaire_base := 0.0
var joueur := Portefeuille.new()
var temoins: Dictionary = {}      # "matelas" | "livret" | "indice" -> Portefeuille
var calendrier: Array = []        # événements de vie tirés au départ : { m, type, M, montant, resolu… }
var file: Array = []              # modales en attente : { kind, id | idx, m, prio, source, … }
var modale: Dictionary = {}       # modale ouverte ({} si aucune)
var choix: Array = []             # choix faits face aux événements de marché
var panique: Array = []           # fenêtres de 3 mois après un événement « - »
var epargne_nette := 0.0          # = patrimoine de Tonton Matelas
var bag_mis := 0.0                # baguettes mises de côté (objectif « battre l'inflation »)
var decouvert_mois := 0
var enfants := 0                  # chaque enfant ajoute une part du salaire aux dépenses (03 §6.2)
var fin := ""                     # "" | "fin" | "faillite" | "abandon"
var hist: Dictionary = {}         # séries mensuelles : j, mis, matelas, livret, indice
var stats: Dictionary = {}
var journal: Array = []
var banque: Dictionary = {"actif": false}   # état du banquier (Banquier.etat_initial) en démo V2
## Historique des pop-ups (retour du joueur du 27/10/2026), du plus ancien au plus récent : chaque
## notification et chaque modale résolue, avec le contenu complet pour la relecture (voir _historiser).
var historique: Array = []
## Flux du dernier changement de mois (P4, docs/15 §1.1) : revenus (intérêts acquis, coupons, dividendes) et
## frais (gestion, versements automatiques) du joueur. Voir flux_du_mois().
var flux_mois: Dictionary = {}
## Vrai pendant le saut « jusqu'au prochain courrier » (réglé par l'autoload Partie, jamais sauvegardé) :
## les entrées d'historique créées pendant ce temps sont « non lues ».
var saut_en_cours := false


# =====================================================================
# Création
# =====================================================================

## config : { periode, profil, graine_vie, sans_vie, debut: "AAAA-MM", fin: "AAAA-MM", cc_depart, livret_depart,
## banquier: bool, naissance: { d, jumeaux_proba }, naissances_aleatoires: bool }.
## debut / fin permettent de jouer une tranche de la période. Renvoie le résultat du premier mois.
func demarrer(config: Dictionary = {}) -> Dictionary:
	_configurer(config)
	m = m_depart
	salaire_base = valeur_table(profil, Dates.annee(ab_courant()))
	temoins = {"matelas": Portefeuille.new(), "livret": Portefeuille.new(), "indice": Portefeuille.new()}
	for k in ["j", "mis", "matelas", "livret", "indice"]:
		var serie := []
		serie.resize(180)
		serie.fill(0.0)
		hist[k] = serie
	stats = {"ordres": 0, "frais": 0.0, "impots": 0.0, "agios": 0.0, "paniques": [], "ventes_forcees": [],
		"somme_part_cc": 0.0, "somme_part_livret": 0.0, "nb_mois": 0, "faillite_m": -1, "utilises": []}
	banque = Banquier.etat_initial() if bool(config.get("banquier", false)) else {"actif": false}
	calendrier = _tirer_calendrier()
	# État de départ garni (démonstration) : le joueur a un compte et un livret ; les témoins reçoivent
	# le même capital en argent (03 §7.8) et le placent selon leur règle. Compté comme épargne.
	var cc0 := float(config.get("cc_depart", 0.0))
	var livret0 := float(config.get("livret_depart", 0.0))
	if cc0 + livret0 > 0.0:
		joueur.cc += cc0
		joueur.livret += livret0
		for k in temoins:
			temoins[k].cc += cc0 + livret0
		_compter_epargne(cc0 + livret0, ab_courant())
	flux_mois = _flux_vide()
	var res := _entrer_mois(true)
	_historiser_notifs(res["notifs"], m)
	res["flux"] = flux_du_mois()
	return res


## Lit la configuration et charge les données (aussi utilisé au rechargement d'une sauvegarde).
func _configurer(config: Dictionary) -> void:
	config_depart = config.duplicate(true)
	id_periode = config.get("periode", "P1")
	profil = config.get("profil", "jeune")
	graine_vie = int(config.get("graine_vie", 1))
	sans_vie = bool(config.get("sans_vie", false))
	naissances_aleatoires = bool(config.get("naissances_aleatoires", true))
	naissance_scriptee = config.get("naissance", {})
	mk = Marche.pour_periode(id_periode)
	per = mk.periode
	regles = Donnees.regles()
	sal = Donnees.salaires()
	vie = Donnees.vie()
	m_depart = Dates.lire(config["debut"]) - mk.ab_debut if config.has("debut") else 0
	m_fin = Dates.lire(config["fin"]) - mk.ab_debut if config.has("fin") else 179
	m_depart = clampi(m_depart, 0, 179)
	m_fin = clampi(m_fin, m_depart, 179)


func banquier_actif() -> bool:
	return bool(banque.get("actif", false))


# =====================================================================
# Accès de base
# =====================================================================

func ab_courant() -> int:
	return mk.ab_debut + m


func ab_de(mois: int) -> int:
	return mk.ab_debut + mois


func cours(id: String, mois: int = -999) -> float:
	return mk.cours(id, m if mois == -999 else mois)


func indice(mois: int = -999) -> float:
	return mk.valeur_indice(m if mois == -999 else mois)


func produit(id: String) -> Dictionary:
	if id == "livret":
		return {"id": "livret", "type": "livret", "nom": "Livret A", "court": "Livret A"}
	if id == "cc":
		return {"id": "cc", "type": "cc", "nom": "Compte courant", "court": "Compte courant"}
	if id in ["pel", "emprunt", "av"]:
		var info := Banquier.info_produit(id).duplicate()
		info["id"] = id
		return info
	return mk.infos.get(id, {})


## L'offre publique d'un produit (Saint-Gobain, 11/1986) est-elle ouverte à la date courante ?
func en_offre(id: String) -> bool:
	var o: Dictionary = produit(id).get("offre", {})
	if o.is_empty():
		return false
	for d in o.get("mois", []):
		if Dates.lire(d) == ab_courant():
			return true
	return false


## Produits proposés au joueur à la date courante. Démo V2 : seulement ceux que M. Lefranc a présentés.
func produits_achetables() -> Array:
	var out := []
	if banquier_actif():
		for id in Banquier.ordre_carnet():
			if Banquier.presente(self, id) and (id in ["livret", "pel", "emprunt", "av"] or mk.disponible(id, ab_courant())):
				out.append(id)
		return out
	for id in per.get("achetables", ["livret"]):
		if id == "livret" or mk.disponible(id, ab_courant()):
			out.append(id)
	return out


func tous() -> Array:
	return [joueur, temoins["matelas"], temoins["livret"], temoins["indice"]]


func prenom() -> String:
	return sal["profils"][profil]["prenoms"].get(id_periode, "")


func journaliser(texte: String) -> void:
	_journaliser(texte)


## Argent reçu par tous (héritage) : la même vie pour le joueur et les témoins.
func recevoir_tous(montant: float) -> void:
	for w in tous():
		w.cc += montant
	_compter_epargne(montant, ab_courant())
	_enregistrer_hist()


# =====================================================================
# Salaires et dépenses
# =====================================================================

## Valeur de la table des salaires (colonne champ) à l'année x, en euros, interpolée géométriquement.
func valeur_table(champ: String, x: float) -> float:
	var t: Array = sal["table"]
	var v := func(r: Dictionary) -> float: return Format.vers_euros(float(r[champ]), r["devise"])
	if x <= float(t[0]["annee"]):
		return v.call(t[0])
	for i in range(t.size() - 1):
		var a0 := float(t[i]["annee"])
		var a1 := float(t[i + 1]["annee"])
		if x >= a0 and x <= a1:
			var v0: float = v.call(t[i])
			var v1: float = v.call(t[i + 1])
			return v0 * pow(v1 / v0, (x - a0) / (a1 - a0))
	return v.call(t[t.size() - 1])


func smn(annee: int) -> float:
	return valeur_table("smn", annee)


func _params_depenses(annee: int) -> Dictionary:
	var p: Dictionary = sal["depenses"][0]
	for d in sal["depenses"]:
		if int(d["de"]) <= annee:
			p = d
	return p


## Dépenses du mois (03 §5.2) : { loyer, vie, enfants, total }. La vie courante comprend le coût des enfants.
func depenses(a: int = -1) -> Dictionary:
	if a < 0:
		a = ab_courant()
	var p := _params_depenses(Dates.annee(a))
	var part_loyer := (float(p["loyer"]) + float(sal["ajustLoyer"][profil])) / 100.0
	var loyer := salaire_base * part_loyer
	var cout_enfants := enfants * cout_mensuel_enfant()
	var vie_courante := salaire_base * (1.0 - float(p["epargne"][profil]) / 100.0 - part_loyer) + cout_enfants
	return {"loyer": loyer, "vie": vie_courante, "enfants": cout_enfants, "total": loyer + vie_courante}


## Coût mensuel d'un enfant (part du salaire, allocations déduites : 03 §6.2).
func cout_mensuel_enfant() -> float:
	return salaire_base * float(vie.get("naissance", {}).get("cout_mensuel_par_enfant", 0.09))


func epargne_du_mois() -> float:
	return salaire_base - float(depenses()["total"])


## Part du salaire qu'il reste possible d'épargner (A21), avec nb enfants à l'année donnée.
func part_epargne(annee: int, nb_enfants: int) -> float:
	var p := _params_depenses(annee)
	return (float(p["epargne"][profil]) - nb_enfants * float(vie["naissance"]["cout_mensuel_par_enfant"]) * 100.0) / 100.0


# =====================================================================
# Valorisation
# =====================================================================

func valeur_ligne(w: Portefeuille, id: String, mois: int = -999) -> float:
	var p := cours(id, mois)
	return 0.0 if is_nan(p) else w.qte(id) * p


func valeur_risquee(w: Portefeuille, mois: int = -999) -> float:
	var s := 0.0
	for id in w.lignes:
		s += valeur_ligne(w, id, mois)
	return s


func patrimoine(w: Portefeuille, mois: int = -999) -> float:
	return w.cc + w.livret + valeur_risquee(w, mois) + w.valeur_epargne()


## Plus-value latente d'une ligne (valeur − coût de revient, frais d'achat compris).
func plus_value_latente(w: Portefeuille, id: String) -> float:
	return valeur_ligne(w, id) - w.cout(id)


func _compter_epargne(flux: float, a: int) -> void:
	epargne_nette += flux
	bag_mis += flux / Marche.baguette(a)


## Écart entre le patrimoine du joueur et celui de Tata Livret (03 §7.8) : la même vie (salaire,
## dépenses, coups durs), mais tout sur le compte courant et le Livret A, dans la limite du plafond.
## Positif : les choix du joueur ont fait mieux que « tout au Livret A ». mois = -999 : maintenant.
## Les courriers en attente sont comptés comme déjà payés (ou encaissés) : les témoins, eux, règlent
## tout de suite ; sans cela l'écart sauterait le temps d'ouvrir la lettre.
func ecart_livret(mois: int = -999) -> float:
	if mois == -999 or mois == m:
		return patrimoine(joueur) + vie_en_attente() - patrimoine(temoins["livret"])
	return float(hist["j"][mois]) - float(hist["livret"][mois])


## Somme signée des événements de vie déclenchés mais pas encore réglés par le joueur (courriers ouverts
## ou en file) : négative pour une facture, positive pour une prime.
func vie_en_attente() -> float:
	var s := 0.0
	for e in calendrier:
		if e.get("declenche", false) and not e.get("resolu", false) and e["type"] != "naissance":
			s += float(e.get("montant", 0.0)) * (1.0 if _type_vie(e["type"])["effet"] == "gain" else -1.0)
	return s


# =====================================================================
# Jumeau sans frais (11 §5.2, formule 7)
# =====================================================================

## Facteur cumulé des frais de gestion de la SICAV jusqu'à la fin du mois (case m + 1 de la VL).
func _facteur_gestion(mois: int) -> float:
	return pow(1.0 - float(regles["sicav"]["gestion"]) / 100.0 / 12.0, mois + 1)


## Cours « sans frais » : la SICAV sans ses frais de gestion ; une action à son cours.
func cours_sans_frais(id: String, mois: int = -999) -> float:
	var mm := m if mois == -999 else mois
	var p := cours(id, mm)
	if produit(id).get("type", "") == "sicav":
		return p / _facteur_gestion(mm)
	return p


func valeur_ombre_ligne(w: Portefeuille, id: String) -> float:
	if not w.lignes.has(id):
		return 0.0
	var p := cours_sans_frais(id)
	return 0.0 if is_nan(p) else float(w.lignes[id].get("qte_ombre", w.lignes[id]["qte"])) * p


## Ce que les frais ont coûté depuis le début : frais payés plus les gains qu'ils auraient produits.
func cout_frais_total(w: Portefeuille) -> float:
	var s := w.ombre_realise
	for id in w.lignes:
		s += valeur_ombre_ligne(w, id) - valeur_ligne(w, id)
	if not w.av.is_empty():
		s += float(w.av["ombre"]) + float(w.av["ombre_courus"]) - float(w.av["valeur"]) - float(w.av["courus"])
	return s


func frais_payes() -> float:
	return float(stats.get("frais", 0.0))


func manque_a_gagner() -> float:
	return maxf(0.0, cout_frais_total(joueur) - frais_payes())


func _noter_frais(w: Portefeuille, frais: float) -> void:
	if w != joueur or frais <= 0.0:
		return
	stats["frais"] += frais
	if banquier_actif():
		banque["frais_annee"] = float(banque.get("frais_annee", 0.0)) + frais


func _noter_utilise(id: String) -> void:
	var u: Array = stats.get("utilises", [])
	if not u.has(id):
		u.append(id)
	stats["utilises"] = u


# =====================================================================
# Ordres : achat
# =====================================================================

## Devis d'achat pour un budget (frais compris) : { ok, id, prix, qte, brut, frais, total, msg }.
func devis_achat(id: String, budget: float) -> Dictionary:
	var pr := produit(id)
	var a := ab_courant()
	var p := cours(id)
	var d := {"ok": false, "id": id, "prix": p, "qte": 0.0, "brut": 0.0, "frais": 0.0, "total": 0.0, "msg": ""}
	if pr.is_empty() or is_nan(p) or not mk.disponible(id, a):
		d["msg"] = "Produit indisponible."
		return d
	budget = maxf(0.0, budget)
	match pr["type"]:
		"sicav":
			if budget < 1.0:
				d["msg"] = "Montant trop faible."
				return d
			d["frais"] = budget * float(regles["sicav"]["entree"]) / 100.0
			d["brut"] = budget - float(d["frais"])
			d["qte"] = float(d["brut"]) / p
		"action":
			var offre := en_offre(id)
			var f := Marche.frais(a)
			var taux := 0.0 if offre else float(f["taux"]) / 100.0
			var q := int(floor(budget / (p * (1.0 + taux))))
			while q > 0 and q * p + (0.0 if offre else Marche.frais_courtage(a, q * p)) > budget + 1e-9:
				q -= 1
			if q <= 0:
				d["msg"] = "Il faut au moins %s pour une action%s." % [Format.montant(p + (0.0 if offre else Marche.frais_courtage(a, p)), a, true), "" if offre else " (frais compris)"]
				return d
			d["qte"] = float(q)
			d["brut"] = q * p
			d["frais"] = 0.0 if offre else Marche.frais_courtage(a, q * p)
			d["offre"] = offre
		_:
			d["msg"] = "Ce produit ne s'achète pas ainsi."
			return d
	d["total"] = float(d["brut"]) + float(d["frais"])
	d["ok"] = true
	return d


func acheter(w: Portefeuille, id: String, budget: float) -> Dictionary:
	var d := devis_achat(id, budget)
	if not d["ok"]:
		return d
	w.cc -= float(d["total"])
	if not w.lignes.has(id):
		w.lignes[id] = {"qte": 0.0, "cout": 0.0, "depuis": m, "qte_ombre": 0.0}
	w.lignes[id]["qte"] += float(d["qte"])
	w.lignes[id]["cout"] += float(d["total"])
	w.lignes[id]["qte_ombre"] = float(w.lignes[id].get("qte_ombre", 0.0)) + float(d["total"]) / cours_sans_frais(id)
	w.frais += float(d["frais"])
	if w == joueur:
		stats["ordres"] += 1
		_noter_frais(w, float(d["frais"]))
		_noter_utilise(id)
		_enregistrer_hist()
	return d


# =====================================================================
# Ordres : vente
# =====================================================================

## Devis de vente : { ok, id, prix, qte, brut, frais, pv, taux, impot, recu, perf, msg }.
## Plus-value = vente nette de frais − prix de revient moyen ; impôt au taux du compte-titres (03 §7.4).
func devis_vente(w: Portefeuille, id: String, montant: float, tout := false) -> Dictionary:
	var pr := produit(id)
	var a := ab_courant()
	var p := cours(id)
	var d := {"ok": false, "id": id, "prix": p, "qte": 0.0, "brut": 0.0, "frais": 0.0, "pv": 0.0,
		"taux": 0.0, "impot": 0.0, "recu": 0.0, "perf": 0.0, "msg": ""}
	var detenu := w.qte(id)
	if detenu <= 0.0 or is_nan(p):
		d["msg"] = "Vous ne détenez pas ce produit."
		return d
	var q: float
	if tout:
		q = detenu
	elif pr["type"] == "action":
		q = minf(detenu, ceilf(maxf(0.0, montant) / p - 1e-9))
	else:
		q = minf(detenu, maxf(0.0, montant) / p)
	if q <= 0.0:
		d["msg"] = "Indiquez un montant."
		return d
	if detenu - q < 1e-6:
		q = detenu
	d["qte"] = q
	d["brut"] = q * p
	if pr["type"] == "action":
		d["frais"] = Marche.frais_courtage(a, float(d["brut"]))
	var net: float = float(d["brut"]) - float(d["frais"])
	var cout_part := w.cout(id) * q / detenu
	d["pv"] = net - cout_part
	d["taux"] = float(Marche.impot(a)["cto"])
	d["impot"] = maxf(0.0, float(d["pv"])) * float(d["taux"]) / 100.0
	d["recu"] = net - float(d["impot"])
	d["perf"] = float(d["brut"]) / cout_part - 1.0 if cout_part > 0.0 else 0.0
	d["ok"] = true
	return d


## forcee : vente pour payer un coup dur (ne compte pas comme une panique).
func vendre(w: Portefeuille, id: String, montant: float, tout := false, forcee := false) -> Dictionary:
	var d := devis_vente(w, id, montant, tout)
	if not d["ok"]:
		return d
	var l: Dictionary = w.lignes[id]
	var frac: float = float(d["qte"]) / float(l["qte"])
	var cout_part: float = float(l["cout"]) * frac
	# Jumeau sans frais : la part vendue de l'ombre, au cours sans frais, sans courtage
	var ombre_vendue := frac * float(l.get("qte_ombre", l["qte"])) * cours_sans_frais(id)
	w.ombre_realise += ombre_vendue - (float(d["brut"]) - float(d["frais"]))
	l["qte_ombre"] = float(l.get("qte_ombre", l["qte"])) * (1.0 - frac)
	l["qte"] -= float(d["qte"])
	l["cout"] -= cout_part
	if float(l["qte"]) < 1e-9:
		w.lignes.erase(id)
	w.cc += float(d["recu"])
	w.frais += float(d["frais"])
	w.impots += float(d["impot"])
	if w == joueur:
		stats["ordres"] += 1
		_noter_frais(w, float(d["frais"]))
		stats["impots"] += float(d["impot"])
		if forcee:
			stats["ventes_forcees"].append({"m": m, "id": id, "perf": d["perf"]})
		else:
			_noter_vente_panique(float(d["brut"]))
		_enregistrer_hist()
	return d


## Vend toutes les lignes risquées (actions, SICAV) : { lignes, brut, frais, impot, recu }.
func devis_vente_totale(w: Portefeuille) -> Dictionary:
	var r := {"lignes": [], "brut": 0.0, "frais": 0.0, "impot": 0.0, "recu": 0.0}
	for id in w.lignes:
		var d := devis_vente(w, id, 0.0, true)
		if d["ok"]:
			r["lignes"].append(d)
			for k in ["brut", "frais", "impot", "recu"]:
				r[k] += float(d[k])
	return r


func vente_totale(w: Portefeuille) -> Dictionary:
	var r := devis_vente_totale(w)
	for d in r["lignes"]:
		vendre(w, d["id"], 0.0, true)
	return r


# =====================================================================
# Livret A
# =====================================================================

## Dépôt refusé au-delà du plafond daté (03 §7.3) : { ok, montant, refus, max, msg }.
func deposer_livret(w: Portefeuille, montant: float) -> Dictionary:
	var a := ab_courant()
	var plaf := Marche.plafond_livret(a)
	montant = maxf(0.0, montant)
	if montant <= 0.0:
		return {"ok": false, "msg": "Indiquez un montant."}
	if w.livret + montant > plaf + EPS:
		var reste := maxf(0.0, plaf - w.livret)
		return {"ok": false, "refus": "plafond", "max": reste,
			"msg": "Refusé : le Livret A est plafonné à %s. Vous pouvez encore déposer %s." % [Format.montant(plaf, a), Format.montant(reste, a)]}
	w.cc -= montant
	w.livret += montant
	if w == joueur:
		_noter_utilise("livret")
		_enregistrer_hist()
	return {"ok": true, "montant": montant}


func retirer_livret(w: Portefeuille, montant: float) -> Dictionary:
	montant = minf(maxf(0.0, montant), w.livret)
	if montant <= 0.0:
		return {"ok": false, "msg": "Rien à retirer."}
	w.livret -= montant
	w.cc += montant
	if w == joueur:
		_enregistrer_hist()
	return {"ok": true, "montant": montant}


func place_livret(w: Portefeuille) -> float:
	return maxf(0.0, Marche.plafond_livret(ab_courant()) - w.livret)


# =====================================================================
# PEL, emprunt d'État, assurance-vie (démo V2) : ordres du joueur
# =====================================================================

func ouvrir_pel(depot: float, mensuel: float) -> Dictionary:
	var r := Produits.ouvrir_pel(self, joueur, depot, mensuel)
	return _apres_ordre(r, "pel")


func verser_pel(montant: float) -> Dictionary:
	return _apres_ordre(Produits.verser_pel(self, joueur, montant), "pel")


func cloturer_pel() -> Dictionary:
	return _apres_ordre(Produits.cloturer_pel(self, joueur), "")


func acheter_emprunt(montant: float) -> Dictionary:
	return _apres_ordre(Produits.acheter_emprunt(self, joueur, montant), "emprunt")


func vendre_emprunt(montant: float, tout := false) -> Dictionary:
	var r := Produits.vendre_emprunt(self, joueur, montant, tout)
	if r.get("ok", false):
		stats["impots"] += float(r["impot"])
	return _apres_ordre(r, "")


func verser_av(montant: float) -> Dictionary:
	var r := Produits.verser_av(self, joueur, montant)
	if r.get("ok", false):
		_noter_frais(joueur, float(r["frais"]))
	return _apres_ordre(r, "av")


func racheter_av(montant: float, tout := false) -> Dictionary:
	var r := Produits.racheter_av(self, joueur, montant, tout)
	if r.get("ok", false):
		stats["impots"] += float(r["impot"])
	return _apres_ordre(r, "")


func _apres_ordre(r: Dictionary, utilise: String) -> Dictionary:
	if r.get("ok", false):
		stats["ordres"] += 1
		if utilise != "":
			_noter_utilise(utilise)
		_enregistrer_hist()
	return r


# =====================================================================
# Le temps
# =====================================================================

## Passe au mois suivant. Renvoie { notifs, modale, fin, m }. Ne fait rien si une modale est ouverte.
## res["flux"] : flux du changement de mois (voir flux_du_mois).
func avancer() -> Dictionary:
	if fin != "" or not modale.is_empty():
		return {"notifs": [], "modale": modale, "fin": fin, "m": m, "flux": _flux_vide()}
	flux_mois = _flux_vide()
	var notifs := []
	_fin_de_mois(notifs)
	_historiser_notifs(notifs, m)
	if m >= m_fin:
		_allouer_temoins()
		_enregistrer_hist()
		fin = "fin"
		return {"notifs": notifs, "modale": {}, "fin": fin, "m": m, "flux": flux_du_mois()}
	m += 1
	var res := _entrer_mois(false)
	_historiser_notifs(res["notifs"], m)
	res["notifs"] = notifs + res["notifs"]
	res["flux"] = flux_du_mois()
	return res


# =====================================================================
# Flux du mois (P4 « Le mois utile », docs/15 §1.1)
# =====================================================================
# Un changement de mois = la fin du mois écoulé (intérêts acquis, frais de gestion) puis l'entrée dans le
# nouveau (coupons, versements automatiques). Les variations de cours n'en font pas partie. Joueur seulement.
# { revenus, frais (euros, ≥ 0), lignes: [{ id, nom, genre (interets | coupon | dividende | frais |
#   frais_versement), montant (≥ 0), verse_en_decembre }] }. verse_en_decembre : intérêts acquis ce mois-ci
# mais crédités au 31/12 (Livret A, PEL, assurance-vie, hors décembre). Le moteur ne verse pas de dividende
# (les cours des actions sont des cours de bourse) : aucune ligne « dividende » pour l'instant.

const GENRES_REVENUS := ["interets", "coupon", "dividende"]


static func _flux_vide() -> Dictionary:
	return {"revenus": 0.0, "frais": 0.0, "lignes": []}


## Même contenu que res["flux"] du dernier changement de mois (copie).
func flux_du_mois() -> Dictionary:
	if flux_mois.is_empty():
		return _flux_vide()
	return flux_mois.duplicate(true)


## Compte un mouvement du mois du joueur (appelé par le moteur, Produits et Versements).
func noter_flux(genre: String, id: String, montant: float, verse_en_decembre := false) -> void:
	if montant <= 0.0:
		return
	if flux_mois.is_empty():
		flux_mois = _flux_vide()
	var revenu := GENRES_REVENUS.has(genre)
	flux_mois["revenus" if revenu else "frais"] = float(flux_mois["revenus" if revenu else "frais"]) + montant
	for l: Dictionary in flux_mois["lignes"]:
		if l["id"] == id and l["genre"] == genre:
			l["montant"] = float(l["montant"]) + montant
			return
	flux_mois["lignes"].append({"id": id, "nom": nom_ligne(id), "genre": genre, "montant": montant,
		"verse_en_decembre": verse_en_decembre})


## Nom court d'une ligne (« Livret A », « SICAV », « Elf »).
func nom_ligne(id: String) -> String:
	var court := str(Banquier.info_produit(id).get("court", ""))
	if court != "":
		return court
	var p := produit(id)
	return str(p.get("court", p.get("nom", id)))


func abandonner() -> void:
	if fin == "":
		fin = "abandon"


## Intérêts du Livret A sur le solde de fin de mois, crédités au 31/12 (03 §7.3) ; PEL et assurance-vie
## de même ; frais de gestion de la SICAV (déjà dans la valeur liquidative) comptés dans les frais payés.
func _fin_de_mois(notifs: Array) -> void:
	var a := ab_courant()
	var decembre := Dates.mois(a) == 12
	var t := Marche.taux_livret(a) / 100.0 / 12.0
	var interets_joueur := 0.0
	noter_flux("interets", "livret", joueur.livret * t, not decembre)
	for w in tous():
		w.livret_int += w.livret * t
		if decembre:
			var i: float = w.livret_int
			w.livret += i
			w.interets_total += i
			w.livret_int = 0.0
			if w == joueur:
				interets_joueur = i
	var g := float(regles["sicav"]["gestion"]) / 100.0 / 12.0
	for id in joueur.lignes:
		if produit(id).get("type", "") == "sicav":
			var gestion := valeur_ligne(joueur, id) * g / (1.0 - g)
			_noter_frais(joueur, gestion)
			noter_flux("frais", id, gestion)
	var credite := Produits.fin_de_mois(self, joueur)
	if banquier_actif():
		banque["interets_annee"] = float(banque.get("interets_annee", 0.0)) + interets_joueur + credite
		if decembre:
			_enregistrer_hist()
			notifs.append(Banquier.releve(self))
	elif interets_joueur > EPS:
		notifs.append({"type": "interets", "source": "banque", "cls": "gain", "montant": interets_joueur,
			"titre": "Intérêts du Livret A",
			"texte": "Les intérêts de l'année %d sont versés sur votre livret : %s." % [Dates.annee(a), Format.montant(interets_joueur, a, false, true)]})


## Ordre de traitement d'un mois (03 §3.3), réduit au périmètre de la démo.
func _entrer_mois(initial: bool) -> Dictionary:
	var a := ab_courant()
	var y := Dates.annee(a)
	var res := {"notifs": [], "modale": {}, "fin": "", "m": m}
	var notifs: Array = res["notifs"]

	# 2-3. Salaire (indexé en janvier) et dépenses, pour le joueur et les 3 témoins
	if not initial and Dates.mois(a) == 1:
		salaire_base *= smn(y) / smn(y - 1)
	var flux := epargne_du_mois()
	for w in tous():
		w.cc += flux
	_compter_epargne(flux, a)
	if initial and profil == "heritier":
		# Simplification du socle : le capital de départ est versé en argent (pas d'« actions de grand-père »).
		var capital := valeur_table("capital", y)
		for w in tous():
			w.cc += capital
		_compter_epargne(capital, a)

	# 6. Agios et faillite (joueur seulement : les témoins n'en ont pas, A23)
	if joueur.cc < -EPS:
		var ag := -joueur.cc * Marche.taux_agios(a) / 100.0 / 12.0
		joueur.cc -= ag
		joueur.agios += ag
		stats["agios"] += ag
	var seuil := -float(regles["decouvertTolereM"]) * salaire_base
	if joueur.cc < seuil - EPS:
		decouvert_mois += 1
		notifs.append({"type": "decouvert", "source": "banque", "cls": "perte",
			"titre": "Découvert : %d mois sur %d" % [decouvert_mois, int(regles["failliteMois"])],
			"texte": "Votre compte dépasse le découvert autorisé. Au bout de %d mois, c'est la faillite." % int(regles["failliteMois"])})
	else:
		decouvert_mois = 0
	if decouvert_mois >= int(regles["failliteMois"]):
		fin = "faillite"
		res["fin"] = fin
		stats["faillite_m"] = m
		_allouer_temoins()
		_enregistrer_hist()
		return res

	# 7. Produits : versement du PEL, coupons (démo V2) ; sinon produits datés annoncés par la banque
	if banquier_actif():
		var coupons := Produits.entree_mois(self, joueur, notifs, true)
		banque["interets_annee"] = float(banque.get("interets_annee", 0.0)) + coupons
		Versements.executer(self, notifs)
	else:
		for pr in per["produits"]:
			if pr.has("dispo") and Dates.lire(pr["dispo"]) == a and per.get("achetables", []).has(pr["id"]):
				notifs.append({"type": "nouveau", "source": "banque", "cls": "neutre", "produit": pr["id"],
					"titre": "Nouveau · %d" % y, "texte": pr.get("texteNouveau", pr["nom"] + " est disponible.")})

	# 8. Événements de marché, de contexte, puis de vie
	for ev in per.get("evenements", []):
		if Dates.lire(ev["d"]) != a:
			continue
		_journaliser(ev["titre"])
		var source: String = ev.get("source", "media")
		if ev["type"] == "-silencieux":
			notifs.append({"type": "silencieux", "source": source, "cls": "perte", "titre": ev["titre"], "texte": ev["texte"]})
			continue
		if ev["type"] == "-":
			panique.append({"id": ev["id"], "m0": m, "fin": m + 2, "v0": valeur_risquee(joueur), "vendu": 0.0, "panique": false})
		file.append({"kind": "marche", "id": ev["id"], "m": m, "prio": 0, "source": source})
	for c in per.get("contexte", []):
		if Dates.lire(c["d"]) == a:
			notifs.append({"type": "info", "source": c.get("source", "media"), "cls": "neutre", "titre": c["titre"], "texte": c["texte"]})
			_journaliser(c["titre"])
	for idx in calendrier.size():
		if int(calendrier[idx]["m"]) == m:
			_declencher_vie(idx, notifs)

	# Banquier : messages, héritage, présentations à proposer
	if banquier_actif():
		Banquier.messages_du_mois(self, notifs)
		Banquier.verifier(self)

	# Les témoins placent leur excédent
	_allouer_temoins()

	# 9. Rappel à 12 mois
	for c in choix:
		if int(c["m"]) + 12 == m:
			notifs.append({"type": "rappel", "source": "media", "cls": "neutre", "evt": c["id"],
				"titre": "Il y a un an…", "texte": texte_rappel(c)})

	_stats_mois()
	_enregistrer_hist()

	# Au plus une modale par mois : priorité marché > date historique > vie > présentation
	if modale.is_empty() and not file.is_empty():
		if banquier_actif():
			modale = _choisir_cadence(notifs)
		else:
			file.sort_custom(_avant_dans_file)
			modale = file.pop_front()
		res["modale"] = modale
	return res


static func _avant_dans_file(x: Dictionary, z: Dictionary) -> bool:
	if x["prio"] != z["prio"]:
		return x["prio"] < z["prio"]
	return x["m"] < z["m"]


## Rang d'une modale en attente (13 §5.3, règle 1) : marché, date historique, événement scripté,
## présentation à sa date limite, événement de vie, présentation.
func _rang(it: Dictionary) -> float:
	match it["kind"]:
		"marche":
			return 0.0
		"banquier":
			if it.get("historique", false):
				return 1.0
			return 2.5 if m >= int(it.get("echeance", 1 << 30)) else 4.0
		"vie":
			return 2.0 if it.get("force", false) else 3.0
	return 5.0


## Cadence des interruptions (13 §5.3) : une par mois au plus ; au moins « ecart_min » mois entre deux,
## sauf marché, dates historiques, événements scriptés et présentations à leur date limite ; les
## événements de vie aléatoires sans décision qui ne peuvent pas passer deviennent des notifications
## (et toujours au-delà du plafond d'interruptions). Les présentations attendent le mois suivant.
func _choisir_cadence(notifs: Array) -> Dictionary:
	var cad: Dictionary = Banquier.donnees()["cadence"]
	var tri := file.duplicate()
	tri.sort_custom(_avant_cadence)
	var ecart_ok := m - int(banque["derniere_interruption"]) >= int(cad["ecart_min"])
	var plafond_atteint := int(banque["interruptions"]) >= int(cad["plafond_interruptions"])
	var choisi := {}
	for it in tri:
		var mineur: bool = it["kind"] == "vie" and not it.get("force", false) and not it.get("decision", false)
		if mineur and plafond_atteint:
			continue
		var libre: bool = it["kind"] == "marche" or it.get("historique", false) or it.get("force", false) or ecart_ok \
			or m >= int(it.get("echeance", 1 << 30))
		if libre:
			choisi = it
			break
	if not choisi.is_empty():
		file.erase(choisi)
	for it in file.duplicate():
		if it["kind"] == "vie" and not it.get("force", false) and not it.get("decision", false):
			file.erase(it)
			_vie_en_notification(int(it["idx"]), notifs)
	if not choisi.is_empty():
		banque["interruptions"] = int(banque["interruptions"]) + 1
		banque["derniere_interruption"] = m
		var quoi := str(choisi.get("id", ""))
		if choisi.has("idx"):
			quoi = str(calendrier[int(choisi["idx"])]["type"])
		var motif := "ecart"
		if not ecart_ok:
			if choisi["kind"] == "marche":
				motif = "marche"
			elif choisi.get("historique", false):
				motif = "historique"
			elif choisi.get("force", false):
				motif = "scripte"
			else:
				motif = "echeance"
		banque["interruptions_liste"].append({"m": m, "kind": choisi["kind"], "id": quoi, "motif": motif})
	return choisi


func _avant_cadence(x: Dictionary, z: Dictionary) -> bool:
	var rx := _rang(x)
	var rz := _rang(z)
	if rx != rz:
		return rx < rz
	return int(x["m"]) < int(z["m"])


# =====================================================================
# Événements de vie
# =====================================================================

## Calendrier des 15 ans tiré au départ avec la graine de vie : il ne dépend pas des choix du joueur.
func _tirer_calendrier() -> Array:
	var cal := []
	if sans_vie:
		return cal
	var rng := Hasard.new(graine_vie)
	var types: Dictionary = vie["types"]
	var ids := types.keys()
	for an in 15:
		var liste := []
		for id in ids:
			if rng.u() < float(types[id]["freq"]):
				liste.append(id)
		if liste.is_empty():
			var pool: Array = vie["pool"]
			liste.append(pool[int(rng.u() * pool.size())])
		for i in range(liste.size() - 1, 0, -1):
			var j := int(rng.u() * (i + 1))
			var tmp: Variant = liste[i]
			liste[i] = liste[j]
			liste[j] = tmp
		liste = liste.slice(0, int(vie["parAn"]["max"]))
		var mois_libres := range(1, 12) if an == 0 else range(12)
		for id in liste:
			var mo: int = mois_libres.pop_at(int(rng.u() * mois_libres.size()))
			var r1 := rng.u()
			rng.u()
			rng.u()  # toujours 3 tirages par événement : séquence stable
			var t: Dictionary = types[id]
			var e := {"m": an * 12 + mo, "type": id}
			var bornes: Array = t["coutM"] if t["effet"] == "cout" else t["gainM"]
			e["M"] = lerpf(float(bornes[0]), float(bornes[1]), r1)
			cal.append(e)
	# Coïncidence forcée : panne de voiture le mois suivant un événement « - » (après le 12e mois)
	var krachs := []
	for ev in per.get("evenements", []):
		if ev["type"] == "-" and Dates.lire(ev["d"]) - mk.ab_debut > int(vie["coincidenceApresMois"]):
			krachs.append(ev)
	if not krachs.is_empty() and types.has("voiture"):
		var ev: Dictionary = krachs[int(rng.u() * krachs.size())]
		var bornes: Array = types["voiture"]["coutM"]
		cal.append({"m": mini(179, Dates.lire(ev["d"]) - mk.ab_debut + 1), "type": "voiture",
			"M": lerpf(float(bornes[0]), float(bornes[1]), rng.u()), "force": true})
	cal = _espacer_repetitions(cal)
	# Tranche de jeu : seuls les mois après le premier mois joué comptent
	cal = cal.filter(func(e: Dictionary) -> bool: return e["m"] > m_depart and e["m"] <= m_fin)
	if naissances_aleatoires:
		cal.append_array(_tirer_naissances(cal))
	if not naissance_scriptee.is_empty():
		var n := _naissance_de_scenario()
		if int(n["m"]) > m_depart and int(n["m"]) <= m_fin:
			cal.append(n)
	cal.sort_custom(func(x: Dictionary, z: Dictionary) -> bool: return x["m"] < z["m"])
	return cal


## Pas deux fois le même événement aléatoire à moins de « ecartRepetitionMois » mois (evenements_vie.json) :
## les événements forcés (coïncidence après un krach) sont gardés, l'aléatoire trop proche est retiré.
## Aucun tirage supplémentaire : la suite des nombres aléatoires ne change pas.
func _espacer_repetitions(cal: Array) -> Array:
	var ecart := int(vie.get("ecartRepetitionMois", 0))
	if ecart <= 0:
		return cal
	var tri := cal.duplicate()
	tri.sort_custom(func(x: Dictionary, z: Dictionary) -> bool: return x["m"] < z["m"])
	var gardes: Array = tri.filter(func(x: Dictionary) -> bool: return x.get("force", false))
	for x: Dictionary in tri:
		if x.get("force", false):
			continue
		var trop_proche := false
		for g: Dictionary in gardes:
			if g["type"] == x["type"] and absi(int(g["m"]) - int(x["m"])) < ecart:
				trop_proche = true
				break
		if not trop_proche:
			gardes.append(x)
	return gardes


## Naissance scriptée de la démo (12 §3.2) : date fixe, jumeaux tirés par la graine (1 fois sur 4 dans la
## démo, 12 R14). Le budget a été calibré pour rester positif : la règle « budget_positif_requis » du
## tirage aléatoire ne s'applique pas à l'événement scripté.
func _naissance_de_scenario() -> Dictionary:
	var rng := Hasard.new(graine_vie + 1000003)
	var u_jum := rng.u()
	var tirages := [rng.u(), rng.u(), rng.u(), rng.u()]
	var n := 2 if u_jum < float(naissance_scriptee.get("jumeaux_proba", 0.0)) else 1
	var e := _nouvelle_naissance(Dates.lire(naissance_scriptee["d"]) - mk.ab_debut, n, tirages)
	e["force"] = true
	e["scriptee"] = true
	return e


## Naissances (tirées avec une graine décalée : le calendrier des autres événements ne change pas).
## Une naissance par année au plus, si l'âge s'y prête, 2 enfants au maximum (03 §6.2) ; jumeaux possibles.
## cal : événements déjà retenus dans la tranche (leurs mois sont évités).
func _tirer_naissances(cal: Array) -> Array:
	var out := []
	var p: Dictionary = vie.get("naissance", {})
	if p.is_empty():
		return out
	var rng := Hasard.new(graine_vie + 1000003)
	var age0 := int(sal["profils"][profil].get("age", 25))
	var bornes_age: Array = p["age"]
	var max_enf := int(p["max_enfants"])
	var prevus := 0
	var pris := {}
	for e in cal:
		pris[int(e["m"])] = true
	for an in 15:
		# Toujours le même nombre de tirages par année : séquence stable
		var u_naiss := rng.u()
		var u_mois := rng.u()
		var u_jum := rng.u()
		var tirages := [rng.u(), rng.u(), rng.u(), rng.u()]
		var age := age0 + an
		if u_naiss >= float(p["freq"]) or prevus >= max_enf or age < int(bornes_age[0]) or age > int(bornes_age[1]):
			continue
		var n := 2 if u_jum < float(p["jumeaux_proba"]) and prevus + 2 <= max_enf else 1
		if bool(p.get("budget_positif_requis", false)) and _marge_budget(an, prevus + n) < 0.0:
			if n == 2 and _marge_budget(an, prevus + 1) >= 0.0:
				n = 1
			else:
				continue
		var libres := []
		for mo in range(1 if an == 0 else 0, 12):
			var mm := an * 12 + mo
			if not pris.has(mm) and mm > m_depart and mm <= m_fin:
				libres.append(mm)
		if libres.is_empty():
			continue
		var mois_n: int = libres[int(u_mois * libres.size())]
		pris[mois_n] = true
		out.append(_nouvelle_naissance(mois_n, n, tirages))
		prevus += n
	return out


## Épargne possible restante (en points de salaire) de l'année an à la fin de la période, avec nb enfants.
func _marge_budget(an: int, nb: int) -> float:
	var pire := INF
	var k_enfant := float(vie["naissance"]["cout_mensuel_par_enfant"]) * 100.0
	for k in range(an, 15):
		var p := _params_depenses(Dates.annee(mk.ab_debut) + k)
		pire = minf(pire, float(p["epargne"][profil]) - nb * k_enfant)
	return pire


## Événement « naissance » de n enfants (1 ou 2) au mois m. tirages : 4 nombres dans [0, 1[ (sexe et prénom).
func _nouvelle_naissance(mois_n: int, n: int, tirages: Array) -> Dictionary:
	var noms: Dictionary = vie["naissance"]["prenoms"]
	var prenoms := []
	var sexes := []
	for i in n:
		var sexe := "F" if float(tirages[2 * i]) < 0.5 else "G"
		var liste: Array = noms[sexe]
		var prenom_i: String = liste[int(float(tirages[2 * i + 1]) * liste.size())]
		if prenoms.has(prenom_i):
			prenom_i = liste[(liste.find(prenom_i) + 1) % liste.size()]
		prenoms.append(prenom_i)
		sexes.append(sexe)
	return {"m": mois_n, "type": "naissance", "M": 0.0, "n": n, "prenoms": prenoms, "sexes": sexes}


## Touche de débogage (F6 / F7) : une naissance tout de suite (jumeaux si demandé), en courrier.
## Renvoie la modale ouverte ({} si une autre modale est déjà en cours : la naissance attend son tour).
func forcer_naissance(jumeaux: bool) -> Dictionary:
	if fin != "":
		return {}
	var rng := Hasard.new(graine_vie * 31 + m * 7 + calendrier.size())
	var e := _nouvelle_naissance(m, 2 if jumeaux else 1, [rng.u(), rng.u(), rng.u(), rng.u()])
	e["force"] = true
	calendrier.append(e)
	_declencher_vie(calendrier.size() - 1, [])
	if modale.is_empty() and not file.is_empty():
		file.sort_custom(_avant_dans_file)
		modale = file.pop_front()
		if banquier_actif():
			banque["interruptions"] = int(banque["interruptions"]) + 1
			banque["derniere_interruption"] = m
		return modale
	return {}


## Paramètres d'un type d'événement de vie (la naissance a sa propre section).
func _type_vie(id: String) -> Dictionary:
	if id == "naissance":
		return vie["naissance"]
	return vie["types"][id]


func texte_vie(e: Dictionary) -> String:
	var t := _type_vie(e["type"])
	if e["type"] == "naissance":
		var prenoms: Array = e.get("prenoms", [])
		var noms := " et ".join(PackedStringArray(prenoms))
		var gabarit: String = t["texte_jumeaux"] if int(e.get("n", 1)) >= 2 else t["texte"]
		return Format.gabarit(gabarit, {"prenoms": noms, "cout": Format.montant(float(e.get("montant", 0.0)), ab_courant())})
	return Format.gabarit(t["texte"], {"montant": Format.montant(float(e.get("montant", 0.0)), ab_courant())})


func titre_vie(e: Dictionary) -> String:
	var t := _type_vie(e["type"])
	if e["type"] == "naissance" and int(e.get("n", 1)) >= 2:
		return t["titre_jumeaux"]
	return t["titre"]


func _declencher_vie(idx: int, notifs: Array) -> void:
	var e: Dictionary = calendrier[idx]
	var t := _type_vie(e["type"])
	if t.get("effet", "") == "naissance":
		# Les dépenses augmentent dès le mois suivant, pour le joueur comme pour les témoins (même vie)
		var n := int(e.get("n", 1))
		e["montant"] = n * cout_mensuel_enfant()
		e["depenses_avant"] = float(depenses()["total"])
		e["reste_avant"] = epargne_du_mois()
		enfants += n
		e["depenses_apres"] = float(depenses()["total"])
		e["reste_apres"] = epargne_du_mois()
		e["declenche"] = true
		e["resolu"] = false
		_journaliser(titre_vie(e))
		if banquier_actif() and int(banque.get("naissance_m", -1)) < 0:
			banque["naissance_m"] = m
		file.append({"kind": "vie", "idx": idx, "m": m, "prio": 1, "source": t.get("source", "maison"), "force": true})
		return
	var montant: float = float(e["M"]) * salaire_base
	e["montant"] = montant
	var seuil := float(regles["seuilCourrierM"]) * salaire_base
	_journaliser(t["titre"])
	var courrier := false
	# Les témoins paient ou encaissent tout de suite
	var signe := -1.0 if t["effet"] == "cout" else 1.0
	for k in temoins:
		temoins[k].cc += signe * montant
	_compter_epargne(signe * montant, ab_courant())
	if t.get("courrier", false):
		courrier = true
	elif t["effet"] == "cout":
		courrier = montant > seuil + EPS or joueur.cc < montant
	else:
		courrier = montant > seuil + EPS
	e["declenche"] = true
	if courrier:
		file.append({"kind": "vie", "idx": idx, "m": m, "prio": 1, "source": t.get("source", "maison"),
			"force": bool(e.get("force", false)), "decision": t["effet"] == "cout" and joueur.cc < montant})
	else:
		_vie_en_notification(idx, notifs)


## Un événement de vie réglé tout de suite, en simple notification (sans pause).
func _vie_en_notification(idx: int, notifs: Array) -> void:
	var e: Dictionary = calendrier[idx]
	var t := _type_vie(e["type"])
	var signe := -1.0 if t["effet"] == "cout" else 1.0
	var montant := float(e["montant"])
	joueur.cc += signe * montant
	e["resolu"] = true
	_enregistrer_hist()
	notifs.append({"type": "vie", "source": t.get("source", "maison"), "cls": "gain" if signe > 0 else "perte",
		"picto": t.get("picto", ""), "montant": signe * montant, "evt_vie": idx,
		"titre": t["titre"], "texte": texte_vie(e)})


# =====================================================================
# Événements de marché
# =====================================================================

func evenement(id: String) -> Dictionary:
	for ev in per.get("evenements", []):
		if ev["id"] == id:
			return ev
	return {}


## Variation des placements risqués du joueur sur la fenêtre de l'événement (mêmes quantités).
func impact_marche(ev: Dictionary) -> Dictionary:
	var f := int(ev.get("fenetre", 1))
	var m0 := maxi(-1, m - f)
	var v0 := 0.0
	var v1 := 0.0
	for id in joueur.lignes:
		var p0 := cours(id, m0)
		if is_nan(p0):
			p0 = cours(id)
		v0 += joueur.qte(id) * p0
		v1 += joueur.qte(id) * cours(id)
	# Effet sur le patrimoine total : le compte et le Livret A ne bougent pas avec la bourse
	var patr := patrimoine(joueur)
	var patr_avant := patr - (v1 - v0)
	return {"v0": v0, "v1": v1, "diff": v1 - v0, "pct": v1 / v0 - 1.0 if v0 > 0.0 else 0.0,
		"depuis": ab_de(m0), "indice_pct": indice(m) / indice(m0) - 1.0,
		"pct_patrimoine": (v1 - v0) / patr_avant if patr_avant > 0.0 else 0.0}


## Choix proposés (03 §6.1) : [{ id, titre, sous, desactive? }].
func choix_marche(ev: Dictionary) -> Array:
	var detient := valeur_risquee(joueur) > EPS
	if ev["type"] == "-":
		if not detient:
			return [{"id": "ecart", "titre": "Rester à l'écart", "sous": "Garder mon argent"},
				{"id": "soldes", "titre": "Profiter des soldes", "sous": "Acheter pendant la baisse"}]
		return [{"id": "vendre", "titre": "Tout vendre", "sous": "Sauver ce qui reste"},
			{"id": "rien", "titre": "Ne rien faire", "sous": "Attendre l'éclaircie"},
			{"id": "renforcer", "titre": "Renforcer", "sous": "Acheter en solde"}]
	if ev["type"] == "+opportunite":
		return [{"id": "souscrire", "titre": "Souscrire", "sous": "Ouvrir le marché"},
			{"id": "rien", "titre": "Ne rien faire", "sous": "Passer mon tour"}]
	return [{"id": "encaisser", "titre": "Encaisser mes gains", "sous": "Vendre mes placements" if detient else "Rien à encaisser", "desactive": not detient},
		{"id": "rien", "titre": "Ne rien faire", "sous": "Garder le cap"},
		{"id": "suivre", "titre": "Suivre la foule", "sous": "Acheter aussi"}]


func texte_rappel(c: Dictionary) -> String:
	var v := indice(int(c["m"]) + 12) / float(c["indice"]) - 1.0
	var a := ab_courant()
	var actions := {"vendre": "tout vendu", "encaisser": "encaissé vos gains", "rien": "gardé le cap",
		"renforcer": "acheté", "suivre": "suivi la foule", "souscrire": "eu l'occasion d'acheter",
		"soldes": "eu l'occasion d'acheter", "ecart": "choisi de rester à l'écart"}
	var date := Dates.texte(a)
	var t := "%s. Il y a un an, pendant « %s », vous avez %s. Depuis, %s a fait %s." % [
		date.left(1).to_upper() + date.substr(1), c["titre"], actions.get(c["choix"], "choisi"), mk.nom_indice(a, false), Format.pct(v)]
	var vendu: bool = c["choix"] in ["vendre", "encaisser"]
	var achat: bool = c["choix"] in ["renforcer", "suivre", "souscrire", "soldes"]
	if vendu:
		t += " Rester investi aurait payé." if v > 0 else " Cette fois, vendre vous a protégé."
	elif achat:
		t += " Acheter à ce moment-là a payé." if v > 0 else " Acheter si tôt n'a pas encore payé."
	else:
		t += " Garder son calme a payé." if v > 0 else " La patience est parfois longue."
	if c.get("lecon", "") != "":
		t += " " + str(c["lecon"])
	return t


func _noter_vente_panique(brut: float) -> void:
	for w in panique:
		if m >= int(w["m0"]) and m <= int(w["fin"]):
			w["vendu"] += brut
			if not w["panique"] and float(w["v0"]) > 0.0 and float(w["vendu"]) > 0.5 * float(w["v0"]):
				w["panique"] = true
				stats["paniques"].append({"m": m, "id": w["id"]})


# =====================================================================
# Modales
# =====================================================================

## Contenu de la modale ouverte, prêt à afficher : { kind, source, titre, texte, choix, … }.
func contenu_modale() -> Dictionary:
	if modale.is_empty():
		return {}
	var a := ab_courant()
	if modale["kind"] == "banquier":
		return Banquier.contenu(self, str(modale["id"]))
	if modale["kind"] == "marche":
		var ev := evenement(modale["id"])
		var m_avant := maxi(m_depart, m - int(ev.get("fenetre", 1)))
		return {"kind": "marche", "source": modale["source"], "date": Dates.texte(a, true), "ab": a,
			"date_journal": ev.get("date_journal", Dates.texte(a)), "produit": ev.get("produit", ""),
			"titre": ev["titre"], "texte": ev["texte"], "gravite": ev.get("gravite", ""), "type": ev["type"],
			"impact": impact_marche(ev), "detient": valeur_risquee(joueur) > EPS, "choix": choix_marche(ev),
			"ecart_livret": ecart_livret(), "ecart_livret_avant": ecart_livret(m_avant), "ab_avant": ab_de(m_avant)}
	var e: Dictionary = calendrier[int(modale["idx"])]
	var t := _type_vie(e["type"])
	var montant: float = e["montant"]
	if t.get("effet", "") == "naissance":
		return {"kind": "vie", "effet": "naissance", "source": modale["source"], "date": Dates.texte(a, true),
			"titre": titre_vie(e), "texte": texte_vie(e), "montant": 0.0, "cout_mensuel": montant,
			"n": int(e.get("n", 1)), "prenoms": e.get("prenoms", []), "sexes": e.get("sexes", []),
			"depenses_avant": e["depenses_avant"], "depenses_apres": e["depenses_apres"],
			"reste_avant": e["reste_avant"], "reste_apres": e["reste_apres"], "picto": "jumeaux" if int(e.get("n", 1)) >= 2 else t.get("picto", "bebe"),
			"choix": [{"id": "ok", "titre": "Bienvenue !" if int(e.get("n", 1)) == 1 else "Bienvenue à tous les deux !", "sous": ""}]}
	var ch := []
	if t["effet"] == "gain":
		ch = [{"id": "encaisser", "titre": "Encaisser", "sous": Format.montant(montant, a, false, true)}]
	elif joueur.cc >= montant:
		ch = [{"id": "payer", "titre": "Payer", "sous": Format.montant(-montant, a)}]
	else:
		var a_vendre := joueur.livret > EPS or valeur_risquee(joueur) > EPS
		ch = [{"id": "vendre", "titre": "Vendre un placement", "sous": "Livret A d'abord, puis la SICAV", "desactive": not a_vendre},
			{"id": "decouvert", "titre": "Passer à découvert", "sous": "Agios de %s %% par an" % Format.nombre(Marche.taux_agios(a), 0)}]
	return {"kind": "vie", "source": modale["source"], "date": Dates.texte(a, true), "titre": t["titre"],
		"texte": texte_vie(e), "montant": montant if t["effet"] == "gain" else -montant, "picto": t.get("picto", ""), "choix": ch}


## Résout la modale ouverte avec le choix id. Renvoie le résultat utile à l'interface :
## { choix, vente? (récapitulatif de la vente totale), ouvrir_achat?, montant_suggere?, ouvrir? }.
func resoudre_modale(choix_id: String) -> Dictionary:
	if modale.is_empty():
		return {}
	var item := modale
	var vu := contenu_modale()   # tel que le joueur l'a vu, pour l'historique
	var r := {"choix": choix_id, "kind": item["kind"]}
	if item["kind"] == "banquier":
		r = Banquier.resoudre(self, str(item["id"]), choix_id)
	elif item["kind"] == "marche":
		var ev := evenement(item["id"])
		choix.append({"id": ev["id"], "m": item["m"], "choix": choix_id, "indice": indice(int(item["m"])),
			"titre": ev["titre"], "type": ev["type"], "lecon": ev.get("lecon", "")})
		if choix_id in ["vendre", "encaisser"]:
			if ev["type"] == "-":
				for w in panique:
					if w["id"] == ev["id"] and not w["panique"]:
						w["panique"] = true
						stats["paniques"].append({"m": m, "id": ev["id"], "tout_vendu": true})
			r["vente"] = vente_totale(joueur)
		elif choix_id in ["renforcer", "soldes", "suivre", "souscrire"]:
			r["ouvrir_achat"] = ev.get("produit", _fonds_indiciel())
			r["montant_suggere"] = maxf(0.0, float(regles["partSuggeree"]) * joueur.cc)
	else:
		var e: Dictionary = calendrier[int(item["idx"])]
		var t := _type_vie(e["type"])
		var montant: float = e["montant"]
		e["resolu"] = true
		e["choix"] = choix_id
		if t["effet"] == "naissance":
			pass   # rien à payer : le coût passe dans les dépenses de chaque mois
		elif t["effet"] == "gain":
			joueur.cc += montant
		else:
			if choix_id == "vendre":
				_liberer_liquidites(montant - joueur.cc)
			joueur.cc -= montant
		_enregistrer_hist()
	modale = {}
	_historiser_modale(vu, choix_id)
	return r


## Choix par défaut (tests, mode accéléré) : ne rien faire, payer, encaisser, « pas maintenant ».
func resolution_auto() -> Dictionary:
	var c := contenu_modale()
	if c.is_empty():
		return {}
	if c["kind"] == "banquier":
		return resoudre_modale("compris" if c.get("heritage", false) else "plus_tard")
	if c["kind"] == "marche":
		return resoudre_modale("rien" if c["detient"] else "ecart")
	var premier: String = c["choix"][0]["id"]
	return resoudre_modale("decouvert" if premier == "vendre" else premier)


## Retire du Livret A puis vend la SICAV pour obtenir au moins « besoin » sur le compte courant.
func _liberer_liquidites(besoin: float) -> void:
	if besoin <= EPS:
		return
	var r := minf(joueur.livret, besoin)
	if r > 0.0:
		retirer_livret(joueur, r)
		besoin -= r
	for id in joueur.lignes.keys():
		if besoin <= EPS:
			break
		var val := valeur_ligne(joueur, id)
		var d := vendre(joueur, id, besoin * 1.25, val <= besoin * 1.25, true)
		if d["ok"]:
			besoin -= float(d["recu"])


# =====================================================================
# Témoins (03 §7.8) : même vie que le joueur, règles fixes, ni agios ni faillite
# =====================================================================

func _fonds_indiciel() -> String:
	for pr in per["produits"]:
		if pr["type"] == "sicav" or pr["type"] == "etf":
			if mk.disponible(pr["id"], ab_courant()):
				return pr["id"]
	return "sicav"


func _allouer_temoins() -> void:
	var plaf := Marche.plafond_livret(ab_courant())
	var l: Portefeuille = temoins["livret"]
	if l.cc < -EPS:
		var r := minf(l.livret, -l.cc)
		l.livret -= r
		l.cc += r
	elif l.cc > EPS:
		var d := minf(l.cc, maxf(0.0, plaf - l.livret))
		l.livret += d
		l.cc -= d
	_allouer_cousin(temoins["indice"])


## Cousin Indice : coussin de 3 mois de dépenses sur le livret, tout le reste dans le fonds indiciel ;
## il ne vend que si son coussin est vide.
func _allouer_cousin(c: Portefeuille) -> void:
	var plaf := Marche.plafond_livret(ab_courant())
	if c.cc < -EPS:
		var r := minf(c.livret, -c.cc)
		c.livret -= r
		c.cc += r
		if c.cc < -EPS:
			for id in c.lignes.keys():
				if c.cc >= -EPS:
					break
				var besoin := -c.cc * 1.05 + 20.0
				vendre(c, id, besoin, valeur_ligne(c, id) <= besoin, true)
		return
	var cible := minf(float(regles["coussinMois"]) * float(depenses()["total"]), plaf)
	var d := minf(c.cc, maxf(0.0, cible - c.livret))
	c.livret += d
	c.cc -= d
	if c.cc > EPS:
		acheter(c, _fonds_indiciel(), c.cc)


# =====================================================================
# Statistiques et historique
# =====================================================================

func _stats_mois() -> void:
	var patr := patrimoine(joueur)
	if patr > EPS:
		stats["somme_part_cc"] += maxf(0.0, joueur.cc) / patr
		stats["somme_part_livret"] += joueur.livret / patr
		stats["nb_mois"] += 1


func _enregistrer_hist() -> void:
	if hist.is_empty():
		return
	hist["j"][m] = patrimoine(joueur)
	hist["mis"][m] = epargne_nette
	hist["matelas"][m] = patrimoine(temoins["matelas"])
	hist["livret"][m] = patrimoine(temoins["livret"])
	hist["indice"][m] = patrimoine(temoins["indice"])


func _journaliser(texte: String) -> void:
	journal.append({"m": m, "texte": texte})
	if journal.size() > 50:
		journal.pop_front()


# =====================================================================
# Historique des pop-ups (retour du joueur du 27/10/2026)
# =====================================================================
# Une entrée : { m, source (maison | banque | media), genre (appel | journal | courrier | notif), type,
# titre, resume (une ligne), choix (libellé du choix fait, "" sinon), montant, a_montant, suffixe,
# contenu (de quoi rouvrir la pop-up en lecture seule : contenu de modale ou notification) }.

const GENRES_MODALE := {"banquier": "appel", "marche": "journal", "vie": "courrier"}
## Genres et sources possibles d'une entrée (V3, docs/15 §8) : « carte », « projet », « voisin », « gazette » et la
## source « rue » n'ont encore aucune entrée (lots 03 à 05).
const GENRES_HISTORIQUE := ["appel", "journal", "courrier", "notif", "carte", "projet", "voisin", "gazette"]
const SOURCES_HISTORIQUE := ["maison", "banque", "media", "rue"]


## Chaque entrée porte « lu » : faux si elle a été créée pendant un saut (notification franchie sans être vue).
func _ajouter_historique(entree: Dictionary) -> void:
	entree["lu"] = not saut_en_cours
	historique.append(entree)
	while historique.size() > HISTORIQUE_MAX:
		historique.pop_front()


func _historiser_notifs(notifs: Array, mois: int) -> void:
	for n: Dictionary in notifs:
		_ajouter_historique({"m": mois, "source": str(n.get("source", "banque")), "genre": "notif", "type": str(n.get("type", "")),
			"titre": str(n.get("titre", "")), "resume": resume_texte(str(n.get("texte", ""))), "choix": "",
			"montant": float(n.get("montant", 0.0)), "a_montant": n.has("montant"), "suffixe": "", "contenu": n.duplicate(true)})


## c : contenu de la modale tel qu'affiché (contenu_modale), juste avant sa résolution.
func _historiser_modale(c: Dictionary, choix_id: String) -> void:
	if c.is_empty():
		return
	var kind := str(c.get("kind", ""))
	var e := {"m": m, "source": str(c.get("source", "maison")), "genre": GENRES_MODALE.get(kind, "notif"), "type": kind,
		"titre": str(c.get("titre", "")), "resume": resume_texte(str(c.get("texte", ""))), "choix": libelle_choix(c, choix_id),
		"montant": 0.0, "a_montant": false, "suffixe": "", "contenu": c.duplicate(true)}
	match kind:
		"banquier":
			e["titre"] = Banquier.titre_historique(c)
			e["resume"] = Banquier.resume_historique(c)
			if c.get("heritage", false):
				e["montant"] = float(c.get("montant", 0.0))
				e["a_montant"] = true
		"marche":
			if c.get("detient", false):
				e["montant"] = float(c.get("impact", {}).get("diff", 0.0))
				e["a_montant"] = true
				e["suffixe"] = "en Bourse"
		"vie":
			if c.get("effet", "") == "naissance":
				e["montant"] = -float(c.get("cout_mensuel", 0.0))
				e["a_montant"] = true
				e["suffixe"] = "par mois"
			else:
				e["montant"] = float(c.get("montant", 0.0))
				e["a_montant"] = true
	e["contenu"]["choix_fait"] = e["choix"]
	_ajouter_historique(e)


## Libellé du choix fait face à une modale (pour l'historique) : le texte du bouton, en minuscules.
static func libelle_choix(c: Dictionary, choix_id: String) -> String:
	match choix_id:
		"plus_tard", "fermer":
			return "Pas maintenant"
		"compris":
			return "Compris"
		"ouvrir":
			return "Ouvrir"
	for ch: Dictionary in c.get("choix", []):
		if str(ch.get("id", "")) == choix_id:
			return str(ch.get("titre", choix_id))
	return choix_id


## Résumé d'une ligne : la première phrase, coupée proprement au-delà de n caractères.
static func resume_texte(t: String, n := 110) -> String:
	t = t.strip_edges().trim_prefix("« ").trim_suffix(" »")
	# Première phrase (la suivante aussi si la première est trop courte, comme « Octobre 1988. »)
	var debut := 0
	while true:
		var fin_phrase := -1
		for sep in [". ", "! ", "? "]:
			var i := t.find(sep, debut)
			if i > 0 and (fin_phrase < 0 or i < fin_phrase):
				fin_phrase = i + 1
		if fin_phrase < 0:
			break
		if fin_phrase >= 30:
			t = t.left(fin_phrase)
			break
		debut = fin_phrase + 1
	if t.length() > n:
		var coupe := t.left(n).rfind(" ")
		t = t.left(coupe if coupe > n / 2 else n).trim_suffix(",").trim_suffix(" :") + "…"
	return t


## Historique du plus récent au plus ancien (antéchronologique), filtré par source ("" = tout).
## Chaque entrée renvoyée porte son indice « i » dans historique (pour la rouvrir).
func historique_recent(source := "") -> Array:
	var out := []
	for i in range(historique.size() - 1, -1, -1):
		var h: Dictionary = historique[i]
		if source == "" or h["source"] == source:
			var copie := h.duplicate()
			copie["i"] = i
			out.append(copie)
	return out


## Nombre d'entrées d'historique créées pendant un saut et pas encore vues (badge du bouton HISTORIQUE),
## filtrées par source ("" = toutes).
func non_lues(source := "") -> int:
	var n := 0
	for h: Dictionary in historique:
		if not bool(h.get("lu", true)) and (source == "" or h.get("source", "") == source):
			n += 1
	return n


## Marque comme vues les entrées non lues de la source ("" = toutes).
func marquer_lues(source := "") -> void:
	for h: Dictionary in historique:
		if source == "" or h.get("source", "") == source:
			h["lu"] = true


# =====================================================================
# Versements automatiques mensuels (11 §8) : réglés depuis la fiche du produit, exécutés au début du mois
# =====================================================================

## Crée ou modifie le plan de pid (PEL : change le versement obligatoire). Effet le mois suivant.
func programmer_versement(pid: String, montant: float) -> Dictionary:
	return Versements.programmer(self, pid, montant)


func arreter_versement(pid: String) -> Dictionary:
	return Versements.arreter(self, pid)


func reactiver_versement(pid: String) -> Dictionary:
	return Versements.reactiver(self, pid)


## Entrée d'historique sans pop-up (réglage d'un versement automatique, par exemple).
func historiser_evenement(n: Dictionary) -> void:
	_historiser_notifs([n], m)


# =====================================================================
# Sauvegarde : tout l'état, sans les données (rechargées depuis data/) ni le marché (déterministe)
# =====================================================================

const CHAMPS_ETAT := ["m", "m_depart", "m_fin", "salaire_base", "calendrier", "file", "modale", "choix", "panique",
	"epargne_nette", "bag_mis", "decouvert_mois", "enfants", "fin", "hist", "stats", "journal", "banque", "historique"]


func vers_dict() -> Dictionary:
	var d := {"version_etat": VERSION_ETAT, "config": config_depart.duplicate(true), "joueur": joueur.vers_dict(), "temoins": {}}
	for k in temoins:
		d["temoins"][k] = temoins[k].vers_dict()
	for k in CHAMPS_ETAT:
		var v: Variant = get(k)
		d[k] = v.duplicate(true) if (v is Dictionary or v is Array) else v
	return d


## Recrée une partie à partir d'une sauvegarde. Renvoie null si le contenu est inutilisable.
static func depuis_dict(d: Dictionary) -> EtatPartie:
	if int(d.get("version_etat", -1)) != VERSION_ETAT or not d.get("config", null) is Dictionary:
		return null
	for k in CHAMPS_ETAT + ["joueur", "temoins"]:
		if not d.has(k):
			return null
	var e := EtatPartie.new()
	e._configurer(d["config"])
	e.joueur.depuis_dict(d["joueur"])
	e.temoins = {}
	for k in ["matelas", "livret", "indice"]:
		var w := Portefeuille.new()
		if d["temoins"].has(k):
			w.depuis_dict(d["temoins"][k])
		e.temoins[k] = w
	for k in CHAMPS_ETAT:
		var v: Variant = d[k]
		e.set(k, v.duplicate(true) if (v is Dictionary or v is Array) else v)
	return e
