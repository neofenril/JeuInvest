class_name Foyer
extends RefCounted
## P2 « Les dilemmes du foyer » et l'humeur de Sylvie (docs/15 §2 ; lot 03, partie 03-foyer : D11 à D14).
## Fonctions statiques sur une partie (comme Cadence), sans nœud. Données : data/foyer.json. L'état vit dans
## EtatPartie.foyer (sauvegardé) ; etat_partie.gd ne contient que les points d'appel.
##
## - Éteint par défaut (D11) : foyer.actif est lu au démarrage (config.cartes, sinon foyer.json > actif) et gardé dans
##   la sauvegarde. Éteint, aucun créneau ne s'ouvre ; l'humeur existe quand même (naissance, érosion), invisible.
## - Humeur cachée de min à max ; 3 états visibles (0 contente, 1 neutre, 2 fâchée : codage de ville.regler_humeur_sylvie) ;
##   notification « humeur » (bulle) seulement quand l'état visible change.
## - Créneaux (D14) : la carte du créneau entre dans e.file (kind « carte », rang 6 de Cadence) au mois préféré, ou
##   plus tôt dans la fenêtre si le mois préféré est déjà connu comme bloqué (interruption datée connue à p − 1, p
##   ou p + 1 : le mois le plus tardif non bloqué avant p) ; elle y reste tant qu'elle ne passe pas (R-CADENCE,
##   anticipation) et la fenêtre finie, le créneau est abandonné. La carte réelle est choisie chaque mois tant
##   qu'elle attend : C00 si Sylvie est fâchée (2 fois au plus, jamais sur deux créneaux de suite ni sur un créneau
##   fixe), sinon la candidate tirée au démarrage, sinon une remplaçante ; aucune carte jouable (enfant requis, ou
##   aucun choix payable) : abandon.
## - Paiement : compte courant puis Livret A ; un choix plus cher que compte + Livret A est désactivé et refusé.
## - R-MIROIR : cartes « conso » et « revenu » recopiées chez les témoins le même mois, du même montant (un témoin
##   peut passer en négatif) ; « placement » (escargots) non ; l'effet sur le salaire est commun (salaire_base).
## - Hasard : candidates tirées au démarrage avec la graine de vie décalée (aucun tirage existant ne change).

const EPS := 0.005
const DECALAGE_GRAINE := 2000003
const PICTOS := {1: "contente", 0: "neutre", -1: "fachee"}


static func donnees() -> Dictionary:
	return Donnees.charger("foyer")


static func carte(id: String) -> Dictionary:
	return donnees()["cartes"].get(id, {})


# =====================================================================
# État
# =====================================================================

## État de départ (appelé par EtatPartie.demarrer, après le calendrier).
static func etat_initial(e: EtatPartie, config: Dictionary) -> Dictionary:
	var d := donnees()
	var f := {"actif": bool(config.get("cartes", d.get("actif", false))), "humeur": int(d["humeur"]["depart"]),
		"creneaux": {}, "c00": 0, "escargots": {}, "salaire": {}, "jouees": [], "derniere_cause": ""}
	if f["actif"]:
		f["creneaux"] = _tirer_creneaux(e)
	return f


## Candidates tirées au démarrage (graine de vie décalée, un tirage par créneau : séquence stable). Une carte
## déjà tirée par un créneau précédent n'est plus candidate ; les autres candidates servent de remplaçantes.
static func _tirer_creneaux(e: EtatPartie) -> Dictionary:
	var rng := Hasard.new(e.graine_vie + DECALAGE_GRAINE)
	var out := {}
	var tirees := []
	for cr: Dictionary in donnees()["creneaux"]:
		var u := rng.u()
		var cand: Array = (cr["candidates"] as Array).duplicate()
		if cr.has("si_projet") and _projet_choisi(e, str(cr["si_projet"])):
			cand.append_array(cr.get("candidates_si_projet", []))
		var dispo := cand.filter(func(x: Variant) -> bool: return not tirees.has(x))
		if dispo.is_empty():
			dispo = cand
		var id: String = dispo[int(u * dispo.size())]
		tirees.append(id)
		var autres := dispo.filter(func(x: Variant) -> bool: return x != id)
		out[cr["id"]] = {"etat": "attente", "carte": id, "remplacantes": autres, "jouee": "", "m": -1, "abandon": ""}
	return out


## Les cartes s'ouvrent-elles dans cette partie ? (drapeau de la partie et démo avec le banquier, donc Cadence)
static func actif(e: EtatPartie) -> bool:
	return bool(e.foyer.get("actif", false)) and e.banquier_actif()


## Après le rechargement d'une sauvegarde : une sauvegarde sans champ foyer (0.4 et avant) reste sans cartes (D11).
static func apres_chargement(e: EtatPartie, avait_foyer: bool) -> void:
	if not avait_foyer:
		e.foyer["actif"] = false
		e.foyer["creneaux"] = {}


# =====================================================================
# Projets (lot 04) : conditions toujours fausses tant qu'ils n'existent pas (D14)
# =====================================================================

static func _projet_choisi(_e: EtatPartie, _id: String) -> bool:
	return false


static func _echeance_projet_en(_e: EtatPartie, _ab: int) -> bool:
	return false


# =====================================================================
# Humeur
# =====================================================================

## 0 contente, 1 neutre, 2 fâchée.
static func humeur_visible(e: EtatPartie) -> int:
	return visible_de(int(e.foyer.get("humeur", 0)))


static func visible_de(h: int) -> int:
	var p: Dictionary = donnees()["humeur"]
	if h >= int(p["contente"]):
		return 0
	if h <= int(p["fachee"]):
		return 2
	return 1


static func _cle_visible(v: int) -> String:
	return ["contente", "neutre", "fachee"][v]


static func humeur_phrase(e: EtatPartie) -> String:
	return str(donnees()["phrases"][_cle_visible(humeur_visible(e))])


## Règle la valeur cachée (bornée) ; notification (bulle) si l'état visible change et que les cartes sont allumées.
static func _regler_humeur(e: EtatPartie, valeur: int, cause: String, notifs: Array) -> void:
	var p: Dictionary = donnees()["humeur"]
	var avant := humeur_visible(e)
	e.foyer["humeur"] = clampi(valeur, int(p["min"]), int(p["max"]))
	if cause != "":
		e.foyer["derniere_cause"] = cause
	var apres := humeur_visible(e)
	if apres == avant or not actif(e):
		return
	var t: Dictionary = donnees()["notif_humeur"]
	var titre := str(t[_cle_visible(apres)])
	if apres == 1 and avant == 0:
		titre = str(t["neutre_depuis_contente"])
	notifs.append({"type": "humeur", "source": "maison", "cls": "neutre", "humeur": apres, "titre": titre,
		"texte": str(e.foyer.get("derniere_cause", "")) if cause != "" else humeur_phrase(e) + ".", "bulle": true})


## Naissance : humeur + naissance (appelé par EtatPartie._declencher_vie).
static func apres_naissance(e: EtatPartie, notifs: Array) -> void:
	_regler_humeur(e, int(e.foyer.get("humeur", 0)) + int(donnees()["humeur"]["naissance"]), str(donnees()["cause_naissance"]), notifs)


# =====================================================================
# Début du mois
# =====================================================================

## Salaire : effet d'une carte (C07 : + 4 % dès 01/1988), appliqué une fois au mois prévu, juste après
## l'indexation de janvier. Commun au joueur et aux témoins (salaire_base est partagé : R-MIROIR).
static func ajuster_salaire(e: EtatPartie) -> void:
	var s: Dictionary = e.foyer.get("salaire", {})
	if s.is_empty() or bool(s.get("applique", false)) or e.m < int(s["m_des"]):
		return
	e.salaire_base *= 1.0 + float(s["pct"]) / 100.0
	s["applique"] = true


## Érosion de l'humeur chaque 1er janvier, issue des escargots. Appelé à l'entrée dans le mois (hors premier mois).
static func debut_mois(e: EtatPartie, notifs: Array) -> void:
	if Dates.mois(e.ab_courant()) == 1:
		var h := int(e.foyer.get("humeur", 0))
		var pas := int(donnees()["humeur"]["erosion"])
		if h != 0:
			_regler_humeur(e, h - signi(h) * mini(pas, absi(h)), "", notifs)
	var esc: Dictionary = e.foyer.get("escargots", {})
	if not esc.is_empty() and not bool(esc.get("fait", false)) and e.m >= int(esc["m_issue"]):
		var d: Dictionary = donnees()["escargots"]
		var a := e.ab_courant()
		var rendu := float(esc["rendu"])
		e.joueur.cc += rendu
		esc["fait"] = true
		notifs.append({"type": "escargots", "source": "maison", "cls": "perte", "persistante": true, "persistant": true,
			"montant": rendu, "titre": str(d["titre"]),
			"texte": Format.gabarit(str(d["texte"]), {"rendu": Format.entier(rendu, a), "prete": Format.entier(float(esc["prete"]), a)})})


# =====================================================================
# Créneaux (avant le choix de Cadence, chaque mois)
# =====================================================================

static func _mois_de(e: EtatPartie, d: String) -> int:
	return Dates.lire(d) - e.mk.ab_debut


## Interruption datée connue à mm − 1, mm ou mm + 1 (le créneau ne pourrait pas partir à mm).
static func _bloque(e: EtatPartie, mm: int) -> bool:
	return Cadence.date_connue(e, mm - 1) or Cadence.date_connue(e, mm) or Cadence.date_connue(e, mm + 1)


## Mois à partir duquel la carte du créneau attend dans la file (D14).
static func _depart(e: EtatPartie, cr: Dictionary) -> int:
	var deb := _mois_de(e, cr["fenetre"][0])
	var p := _mois_de(e, cr["prefere"])
	if not _bloque(e, p):
		return p
	for mm in range(p - 1, deb - 1, -1):
		if not _bloque(e, mm):
			return mm
	return p


static func _item_en_file(e: EtatPartie, sid: String) -> Dictionary:
	for it: Dictionary in e.file:
		if it.get("kind", "") == "carte" and str(it.get("creneau", "")) == sid:
			return it
	return {}


## Met à jour la file : créneaux qui s'ouvrent, carte réelle de chaque créneau en attente, abandons.
static func preparer(e: EtatPartie) -> void:
	if not actif(e):
		return
	var etats: Dictionary = e.foyer["creneaux"]
	for cr: Dictionary in donnees()["creneaux"]:
		var sid := str(cr["id"])
		var s: Dictionary = etats.get(sid, {})
		if s.is_empty() or s["etat"] in ["joue", "abandonne"]:
			continue
		var fin := _mois_de(e, cr["fenetre"][1])
		var it := _item_en_file(e, sid)
		if s["etat"] == "attente":
			if cr.has("sauf_echeance_projet") and _echeance_projet_en(e, Dates.lire(cr["sauf_echeance_projet"])):
				s["etat"] = "abandonne"
				s["abandon"] = "projet"
				continue
			if e.m > fin:
				s["etat"] = "abandonne"
				s["abandon"] = "fenetre"
				continue
			if e.m < _mois_de(e, cr["fenetre"][0]) or e.m < _depart(e, cr):
				continue
			it = {"kind": "carte", "id": "", "creneau": sid, "m": e.m, "prio": 6, "source": "maison"}
			e.file.append(it)
			s["etat"] = "en_file"
		elif it.is_empty():
			continue   # ouverte (modale en cours)
		if e.m > fin:
			e.file.erase(it)
			s["etat"] = "abandonne"
			s["abandon"] = "fenetre"
			continue
		var id := _carte_pour(e, cr, s)
		if id == "":
			e.file.erase(it)
			s["etat"] = "abandonne"
			s["abandon"] = "non_payable"
			continue
		it["id"] = id


## Carte réelle du créneau ce mois-ci ("" : aucune jouable).
static func _carte_pour(e: EtatPartie, cr: Dictionary, s: Dictionary) -> String:
	var c00: Dictionary = donnees()["c00"]
	if humeur_visible(e) == 2 and int(e.foyer.get("c00", 0)) < int(c00["max"]) and not bool(cr.get("fixe", false)) \
			and not _precedent_c00(e, str(cr["id"])):
		return str(c00["carte"])
	var liste := [str(s["carte"])]
	for x in s.get("remplacantes", []):
		liste.append(str(x))
	for id: String in liste:
		var c := carte(id)
		if c.is_empty() or (bool(c.get("requiert_enfant", false)) and e.enfants <= 0):
			continue
		if _payable(e, c, "a") or _payable(e, c, "b"):
			return id
	return ""


## Le créneau joué juste avant (dans l'ordre des créneaux) était-il C00 ?
static func _precedent_c00(e: EtatPartie, sid: String) -> bool:
	var prec: Dictionary = {}
	for cr: Dictionary in donnees()["creneaux"]:
		if str(cr["id"]) == sid:
			break
		var s: Dictionary = e.foyer["creneaux"].get(str(cr["id"]), {})
		if s.get("etat", "") == "joue":
			prec = s
	return str(prec.get("jouee", "")) == str(donnees()["c00"]["carte"])


# =====================================================================
# Choix d'une carte
# =====================================================================

## Prix du choix en euros (≥ 0), variante jumeaux comprise.
static func prix(e: EtatPartie, c: Dictionary, k: String) -> float:
	var ch: Dictionary = c[k]
	var f := float(ch["prix_F"])
	if ch.has("prix_jumeaux_F") and Banquier.jumeaux(e):
		f = float(ch["prix_jumeaux_F"])
	return Produits.f(f)


## Montant signé du choix (dépense < 0, revenu > 0).
static func montant(e: EtatPartie, c: Dictionary, k: String) -> float:
	var p := prix(e, c, k)
	return p if str(c[k]["sens"]) == "revenu" else -p


## Argent mobilisable pour une carte : compte courant + Livret A.
static func disponible(e: EtatPartie) -> float:
	return e.joueur.cc + e.joueur.livret


static func _payable(e: EtatPartie, c: Dictionary, k: String) -> bool:
	return montant(e, c, k) >= 0.0 or -montant(e, c, k) <= disponible(e) + EPS


static func _picto(h: Variant) -> String:
	if h is String:
		return "contente"   # « zero » : la réconciliation
	return str(PICTOS.get(clampi(int(h), -1, 1), "neutre"))


static func _remplir(e: EtatPartie, t: String, c: Dictionary) -> String:
	var a := e.ab_courant()
	return Format.gabarit(t, {"prix_a": Format.entier(prix(e, c, "a"), a), "prix_b": Format.entier(prix(e, c, "b"), a),
		"prenoms": Banquier.prenoms_enfants(e)})


static func texte_carte(e: EtatPartie, c: Dictionary) -> String:
	var t := str(c.get("texte_jumeaux", c["texte"])) if Banquier.jumeaux(e) else str(c["texte"])
	return _remplir(e, t, c)


## Contenu de la modale « carte » ouverte (contrat du lot 03 §5.3 bis).
static func contenu(e: EtatPartie) -> Dictionary:
	var it := e.modale
	var id := str(it.get("id", ""))
	var c := carte(id)
	var a := e.ab_courant()
	var dispo := disponible(e)
	var ch := []
	for k in ["a", "b"]:
		var mt := montant(e, c, k)
		var desactive := not _payable(e, c, k)
		var manque := maxf(0.0, -mt - dispo) if desactive else 0.0
		var sous := Format.ecart(mt, a)
		if desactive:
			sous = Format.gabarit(str(donnees()["manque"]), {"x": Format.entier(manque, a)})
		var h: Variant = c[k]["humeur"]
		ch.append({"id": k, "titre": str(c[k]["libelle"]), "montant": mt, "humeur": h if h is String else int(h),
			"picto": _picto(h), "desactive": desactive, "manque": manque, "sous": sous})
	return {"kind": "carte", "source": str(it.get("source", "maison")), "date": Dates.texte(a, true), "ab": a, "id": id,
		"creneau": str(it.get("creneau", "")), "titre": str(c["titre"]), "texte": texte_carte(e, c), "type": str(c["type"]),
		"disponible": dispo, "choix": ch}


static func choix_valide(e: EtatPartie, choix_id: String) -> bool:
	var c := carte(str(e.modale.get("id", "")))
	return not c.is_empty() and choix_id in ["a", "b"] and _payable(e, c, choix_id)


## Choix par défaut (resolution_auto) : le moins cher payable (le plus grand montant signé).
static func choix_auto(e: EtatPartie) -> String:
	return choix_politique(e, "epargner")


## Politiques de test (StrategieTest) : depenser (le plus cher payable), epargner (le moins cher), alterner.
static func choix_politique(e: EtatPartie, politique: String) -> String:
	var c := carte(str(e.modale.get("id", "")))
	if politique == "alterner":
		politique = "depenser" if (e.foyer.get("jouees", []) as Array).size() % 2 == 0 else "epargner"
	var ma := montant(e, c, "a")
	var mb := montant(e, c, "b")
	var pa := _payable(e, c, "a")
	var pb := _payable(e, c, "b")
	if not pa:
		return "b"
	if not pb:
		return "a"
	if politique == "depenser":
		return "a" if ma <= mb else "b"
	return "a" if ma > mb else "b"


## Ligne de conséquence (D13).
static func consequence(e: EtatPartie, c: Dictionary, k: String) -> String:
	var mt := montant(e, c, k)
	var a := e.ab_courant()
	if str(c["type"]) == "conso" and mt < -EPS:
		var taux := Marche.taux_livret(a)
		var vf := -mt * pow(1.0 + taux / 100.0, float(e.m_fin - e.m) / 12.0)
		return Format.gabarit(str(donnees()["consequence_depense"]), {"taux": Banquier.taux_txt(taux), "montant": Format.entier(-mt, a),
			"vf": Format.entier(vf, a), "annee": str(Dates.annee(e.ab_de(e.m_fin)))})
	if str(c["type"]) == "conso" and c[k].has("replique"):
		return str(c[k]["replique"])
	return _remplir(e, str(c["pourquoi"]), c)


## Résout la carte ouverte : paiement, R-MIROIR, humeur, effets (salaire, escargots), historique.
## vu : contenu affiché (complété de la conséquence et du montant pour l'historique).
static func resoudre(e: EtatPartie, choix_id: String, vu: Dictionary) -> Dictionary:
	var it := e.modale
	var id := str(it.get("id", ""))
	var c := carte(id)
	var a := e.ab_courant()
	var mt := montant(e, c, choix_id)
	var notifs := []
	# Paiement : compte courant puis Livret A
	e.joueur.cc += mt
	if e.joueur.cc < 0.0 and e.joueur.livret > 0.0 and mt < 0.0:
		e.retirer_livret(e.joueur, minf(e.joueur.livret, -e.joueur.cc))
	# R-MIROIR : la même dépense (ou rentrée) chez les témoins, sauf un placement
	if str(c["type"]) != "placement" and absf(mt) > 0.0:
		for k in e.temoins:
			e.temoins[k].cc += mt
		e._compter_epargne(mt, a)
	var ch: Dictionary = c[choix_id]
	if ch.has("salaire"):
		e.foyer["salaire"] = {"pct": float(ch["salaire"]["pct"]), "m_des": _mois_de(e, ch["salaire"]["des"]), "applique": false}
	var esc: Dictionary = donnees()["escargots"]
	if id == str(esc["carte"]) and choix_id == str(esc["choix"]):
		e.foyer["escargots"] = {"m_pret": e.m, "m_issue": e.m + int(esc["delai"]), "prete": -mt, "rendu": Produits.f(float(esc["rendu_F"])), "fait": false}
	if id == str(donnees()["c00"]["carte"]):
		e.foyer["c00"] = int(e.foyer.get("c00", 0)) + 1
	# Humeur
	var avant := humeur_visible(e)
	var h: Variant = ch["humeur"]
	var cause := str(ch.get("replique", ch["libelle"]))
	if h is String:
		_regler_humeur(e, 0, cause, notifs)
	elif int(h) != 0:
		_regler_humeur(e, int(e.foyer.get("humeur", 0)) + int(h), cause, notifs)
	var cons := consequence(e, c, choix_id)
	var s: Dictionary = e.foyer["creneaux"].get(str(it.get("creneau", "")), {})
	if not s.is_empty():
		s["etat"] = "joue"
		s["jouee"] = id
		s["m"] = e.m
	(e.foyer["jouees"] as Array).append({"id": id, "creneau": str(it.get("creneau", "")), "titre": str(c["titre"]), "choix": choix_id,
		"libelle": str(ch["libelle"]), "montant": mt, "humeur_effet": h if h is String else int(h), "picto": _picto(h), "m": e.m, "ab": a})
	e._enregistrer_hist()
	vu["consequence"] = cons
	vu["montant_choisi"] = mt
	return {"choix": choix_id, "kind": "carte", "montant": mt, "consequence": cons, "humeur_avant": avant,
		"humeur_apres": humeur_visible(e), "notifs": notifs}


## Entrée d'historique d'une carte (appelé par EtatPartie._historiser_modale) : montant du choix, ligne de conséquence.
static func completer_historique(entree: Dictionary, c: Dictionary) -> void:
	entree["montant"] = float(c.get("montant_choisi", 0.0))
	entree["a_montant"] = true
	entree["resume"] = EtatPartie.resume_texte(str(c.get("consequence", "")))


# =====================================================================
# Lecture (vague 3)
# =====================================================================

## Cartes jouées, de la plus ancienne à la plus récente (copie).
static func cartes_jouees(e: EtatPartie) -> Array:
	return (e.foyer.get("jouees", []) as Array).duplicate(true)


## Résumé des créneaux (tests et compte rendu) : { Sid: { etat, carte (tirée), jouee, m, abandon } }.
static func creneaux(e: EtatPartie) -> Dictionary:
	return (e.foyer.get("creneaux", {}) as Dictionary).duplicate(true)
