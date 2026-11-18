class_name Titres
extends RefCounted
## Titre d'époque de fin de partie (lot 07-L ; docs/28 §1 à §3, lot_07.md D1 à D3). Fonctions statiques, sans nœud.
## Données : data/titres.json (ordre, seuils, textes) ; natures des choix de cartes : data/foyer.json > nature.
## - grandeurs(e) : les mesures de la partie (docs/28 §1.1), tenues dans EtatPartie.stats_titre (sauvegardé) ou relues
##   dans l'état final ; evaluer(g) : fonction pure sur ces grandeurs (testable sur des grandeurs fabriquées) ;
##   calculer(e) : {} tant que la partie n'est pas allée à son terme (abandon, faillite : ni titre, ni record).
## - Aucun titre ne demande « Renforcer » ni ne récompense une vente ; Jean-Mi n'entre dans aucune condition.

const EPS := 0.005


static func donnees() -> Dictionary:
	return Donnees.charger("titres")


static func parametres() -> Dictionary:
	return donnees()["parametres"]


## Les 9 titres dans l'ordre d'évaluation : [{"id", "nom", "ordre"}] (ordre de 1 à 9).
static func tous() -> Array:
	var out: Array = []
	var liste: Array = donnees()["titres"]
	for i in liste.size():
		out.append({"id": str(liste[i]["id"]), "nom": str(liste[i]["nom"]), "ordre": i + 1})
	return out


# =====================================================================
# Statistiques tenues pendant la partie (EtatPartie.stats_titre)
# =====================================================================

## État de départ : somme des parts du compte courant (un point par fin de mois), nombre de mois, produits détenus au
## moins un mois, valeur brute des actions et SICAV vendues par ordre du joueur dans la fenêtre du krach, projets
## abandonnés alors que RÉALISER (ou RÉALISER EN VENDANT) était possible.
static func stats_initiales() -> Dictionary:
	return {"somme_cc": 0.0, "nb_mois": 0, "produits": [], "ventes_krach": 0.0, "abandons_evitables": []}


## Produits détenus à l'instant (ids : livret, pel, emprunt, av, sicav, elf…). Le compte courant n'en est pas un.
static func produits_maintenant(e: EtatPartie) -> Array:
	var w := e.joueur
	var out: Array = []
	if w.livret > EPS:
		out.append("livret")
	if w.valeur_pel() > EPS:
		out.append("pel")
	if not w.emprunts.is_empty():
		out.append("emprunt")
	if w.valeur_av() > EPS:
		out.append("av")
	for id in w.lignes:
		if w.qte(str(id)) > 0.0:
			out.append(str(id))
	return out


## Appelé par EtatPartie._stats_mois (une fois par mois) : part du compte courant et produits détenus.
static func noter_mois(e: EtatPartie, patrimoine: float) -> void:
	var s := e.stats_titre
	if patrimoine > EPS:
		s["somme_cc"] = float(s.get("somme_cc", 0.0)) + e.joueur.cc / patrimoine
		s["nb_mois"] = int(s.get("nb_mois", 0)) + 1
	var prod: Array = s.get("produits", [])
	for id in produits_maintenant(e):
		if not prod.has(id):
			prod.append(id)
	s["produits"] = prod


## Vente d'actions ou de SICAV par ordre du joueur (EtatPartie.vendre, hors ventes forcées d'un coup dur ou d'un projet).
static func noter_vente(e: EtatPartie, id: String, brut: float) -> void:
	var a := e.ab_courant()
	var f: Array = parametres()["fenetre_vente_krach"]
	if a < Dates.lire(str(f[0])) or a > Dates.lire(str(f[1])):
		return
	var t := str(e.produit(id).get("type", ""))
	if t != "action" and t != "sicav":
		return
	e.stats_titre["ventes_krach"] = float(e.stats_titre.get("ventes_krach", 0.0)) + brut


## Appelé par Projets.resoudre quand le joueur renonce au jour J : evitable = RÉALISER ou RÉALISER EN VENDANT était actif.
static func noter_abandon(e: EtatPartie, pid: String, evitable: bool) -> void:
	if not evitable:
		return
	var l: Array = e.stats_titre.get("abandons_evitables", [])
	if not l.has(pid):
		l.append(pid)
	e.stats_titre["abandons_evitables"] = l


# =====================================================================
# Grandeurs (docs/28 §1.1)
# =====================================================================

## patrimoine(joueur) / patrimoine(Tata Livret) − 1, nominal, au mois courant (le même nombre pour le record).
static func ecart_tata(e: EtatPartie) -> float:
	var t := e.patrimoine(e.temoins["livret"])
	if t <= EPS:
		return 0.0
	return e.patrimoine(e.joueur) / t - 1.0


## Nombre de projets à l'état realise ou realise_apres_report (0 si les projets sont éteints).
static func projets_realises(e: EtatPartie) -> int:
	var n := 0
	var etats: Dictionary = e.projets.get("projets", {})
	for pid in etats:
		if str(etats[pid].get("etat", "")) in ["realise", "realise_apres_report"]:
			n += 1
	return n


## Choix de cartes faits, par nature : {"epargne": n, "depense": n, "neutre": n}. Un choix grisé n'est pas fait et la
## sortie « Pas les moyens ce mois-ci » (choix « aucun ») ne compte pas.
static func natures_choisies(e: EtatPartie) -> Dictionary:
	var r := {"epargne": 0, "depense": 0, "neutre": 0}
	for j: Dictionary in Foyer.cartes_jouees(e):
		var k := str(j.get("choix", ""))
		if k != "a" and k != "b":
			continue
		var nat := str(Foyer.carte(str(j["id"])).get(k, {}).get("nature", "neutre"))
		r[nat] = int(r.get(nat, 0)) + 1
	return r


## Part des actions et SICAV dans le patrimoine au krach (0 si exemple, sans ligne, ou instantané absent).
static func part_risquee_krach(e: EtatPartie) -> float:
	var inst := e.instantane_k
	if inst.is_empty() or bool(inst.get("exemple", false)) or (inst.get("lignes", []) as Array).is_empty():
		return 0.0
	var patr := float(inst.get("patrimoine", 0.0))
	if patr <= EPS:
		return 0.0
	return Krach.base(inst) / patr


## Concentration au krach (lot 08b) : valeur de la plus grosse ligne d'action (une SICAV est diversifiée : elle ne compte
## pas) divisée par la valeur de toutes les lignes risquées ; 0 si exemple, sans ligne ou instantané absent.
static func ligne_max_krach(e: EtatPartie) -> float:
	var inst := e.instantane_k
	if inst.is_empty() or bool(inst.get("exemple", false)) or (inst.get("lignes", []) as Array).is_empty():
		return 0.0
	var base := Krach.base(inst)
	if base <= EPS:
		return 0.0
	var m := 0.0
	for l: Dictionary in inst["lignes"]:
		if str(l.get("type", "")) != "sicav":
			m = maxf(m, float(l["qte"]) * float(l["cours"]))
	return m / base


## Choix « vendre » au krach, ou ventes par ordre dans la fenêtre dépassant vente_apres_krach × la valeur au krach.
static func a_vendu_krach(e: EtatPartie) -> bool:
	var inst := e.instantane_k
	if inst.is_empty():
		return false
	if str(inst.get("choix", "")) == "vendre" and not bool(inst.get("exemple", false)):
		return true
	var p := float(parametres().get("vente_apres_krach", 0.0))
	if p <= 0.0 or bool(inst.get("exemple", false)) or (inst.get("lignes", []) as Array).is_empty():
		return false
	var base := Krach.base(inst)
	return base > 0.0 and float(e.stats_titre.get("ventes_krach", 0.0)) > p * base


## Les grandeurs de la partie (docs/28 §1.1), prêtes pour evaluer().
static func grandeurs(e: EtatPartie) -> Dictionary:
	var s := e.stats_titre
	var nat := natures_choisies(e)
	var etats: Dictionary = e.projets.get("projets", {})
	var evitable := false
	for pid in s.get("abandons_evitables", []):
		if str(etats.get(pid, {}).get("etat", "")) == "abandonne":
			evitable = true
	var produits: Array = (s.get("produits", []) as Array).duplicate()
	for id in produits_maintenant(e):
		if not produits.has(id):
			produits.append(id)
	produits.sort()
	var escargots := false
	for j: Dictionary in Foyer.cartes_jouees(e):
		if str(j["id"]) == str(Foyer.donnees()["escargots"]["carte"]) and str(j["choix"]) == str(Foyer.donnees()["escargots"]["choix"]):
			escargots = true
	var n := int(s.get("nb_mois", 0))
	return {"ecart_tata": ecart_tata(e), "projets_realises": projets_realises(e), "humeur_fin": e.humeur_visible(),
		"abandon_evitable": evitable, "part_risquee_krach": part_risquee_krach(e), "ligne_max_krach": ligne_max_krach(e), "a_vendu_krach": a_vendu_krach(e),
		"escargots": escargots, "nb_epargne": int(nat["epargne"]), "nb_depense": int(nat["depense"]),
		"produits_detenus": produits, "cc_moyen": float(s.get("somme_cc", 0.0)) / float(n) if n > 0 else 0.0}


# =====================================================================
# Évaluation (docs/28 §1.2)
# =====================================================================

## Fonction pure : le premier titre, dans l'ordre de titres.json, dont la condition est vraie.
## {"id", "nom", "pourquoi", "ordre"} ; le dernier de la liste (« apprenti ») est le titre par défaut.
static func evaluer(g: Dictionary) -> Dictionary:
	var p := parametres()
	var liste: Array = donnees()["titres"]
	for i in liste.size():
		var t: Dictionary = liste[i]
		if i == liste.size() - 1 or _condition(str(t["id"]), g, p):
			return {"id": str(t["id"]), "nom": str(t["nom"]), "pourquoi": str(t["pourquoi"]), "ordre": i + 1}
	return {}


static func _condition(id: String, g: Dictionary, p: Dictionary) -> bool:
	var ecart := float(g["ecart_tata"])
	var epargne := int(g["nb_epargne"])
	var depense := int(g["nb_depense"])
	var humeur := int(g["humeur_fin"])
	var part := float(g["part_risquee_krach"])
	match id:
		"bon_pere":
			var h_ok := humeur != 2 if str(p.get("bon_pere_humeur", "pas_fachee")) == "pas_fachee" else humeur == 0
			return ecart > float(p["ecart_min"]) and int(g["projets_realises"]) == 2 and h_ok
		"golden_boy":
			return part >= float(p["part_risquee"]) and bool(g["a_vendu_krach"])
		"escargots":
			return bool(g["escargots"]) and ecart < 0.0
		"fourmi":
			return epargne >= int(p["cartes_min"]) and epargne - depense >= int(p["cartes_ecart"]) \
				and (humeur == 2 or bool(g["abandon_evitable"]))
		"cigale":
			return depense >= int(p.get("cigale_min", p["cartes_min"])) \
				and depense - epargne >= int(p.get("cigale_ecart", p["cartes_ecart"])) and humeur == 0
		"marin":
			return part >= float(p["part_risquee"]) and not bool(g["a_vendu_krach"]) and ecart > 0.0 \
				and float(g.get("ligne_max_krach", 0.0)) <= float(p.get("marin_ligne_max", 1.0)) + 1e-9
		"neveu_matelas":
			return float(g["cc_moyen"]) >= float(p["cc_moyen_min"])
		"ecureuil":
			for x in g["produits_detenus"]:
				if not (p["produits_surs"] as Array).has(str(x)):
					return false
			return true
	return true


## Titre de la partie : {} si elle n'est pas allée à son terme (abandon, faillite, en cours), sinon evaluer(grandeurs).
static func calculer(e: EtatPartie) -> Dictionary:
	if e.fin != "fin":
		return {}
	return evaluer(grandeurs(e))
