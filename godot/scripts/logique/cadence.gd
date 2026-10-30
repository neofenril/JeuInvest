class_name Cadence
extends RefCounted
## Cadence des interruptions avec pause de la démo (docs/15 §0.1 ; remplace 13 §5.3, règles 1 et 2). Extraite
## d'EtatPartie au lot 02. Fonctions statiques sur une partie, sans nœud. Réglages : data/rythme.json > cadence.
##
## - R-CADENCE : au plus une interruption par mois, jamais deux mois de suite, toutes catégories confondues.
##   Seule exception : un événement de marché, puis la panne forcée du mois suivant.
## - Priorité quand plusieurs candidats attendent : marché > date historique (Saint-Gobain, héritage, naissance,
##   panne forcée) > échéance de projet > présentation à sa date limite > événement de vie aléatoire >
##   présentation > choix de projet > carte de dilemme. Le perdant reste en file et glisse au premier mois libre ;
##   un événement de vie aléatoire sans décision qui ne peut pas passer devient une notification (13 §5.3).
## - Anticipation sans fuite : une interruption flexible (présentation avant sa date limite, événement de vie
##   aléatoire, carte, choix de projet) ne part pas au mois m si m + 1 porte une interruption datée connue
##   (marché, date historique, naissance scriptée, panne forcée, date limite d'une présentation non faite,
##   échéance de projet). Rien ne se voit à l'écran.
##   Écart volontaire avec la lettre de docs/15 §0.1 : l'anticipation vaut aussi pour les événements de vie
##   aléatoires (sinon une naissance ou une date limite tomberait le mois suivant d'une interruption).
## - Budgets par catégorie (classiques ≤ 15 ; cartes, projets, Gazette : compteurs prêts, encore vides).
##
## État (dans EtatPartie.banque, sauvegardé) : interruptions (nombre de classiques), derniere_interruption (m),
## derniere_kind, interruptions_liste [{ m, kind, id, motif, rang, datee, categorie }], compteurs { categorie -> n }.

const CATEGORIES := ["classiques", "cartes", "projets", "gazette"]


static func params() -> Dictionary:
	return Donnees.charger("rythme")["cadence"]


static func budget(categorie: String) -> int:
	return int(params()["budgets"].get(categorie, 0))


static func compteurs_vides() -> Dictionary:
	var c := {}
	for k in CATEGORIES:
		c[k] = 0
	return c


## Catégorie de budget d'une interruption en attente (kind : marche | banquier | vie | carte | projet | gazette).
static func categorie(it: Dictionary) -> String:
	match str(it.get("kind", "")):
		"carte":
			return "cartes"
		"projet":
			return "projets"
		"gazette":
			return "gazette"
	return "classiques"


## Rang de priorité (le plus petit passe d'abord). Un projet porte « echeance_projet » (échéance) ou non (choix).
static func rang(e: EtatPartie, it: Dictionary) -> float:
	match str(it.get("kind", "")):
		"marche":
			return 0.0
		"gazette":
			return 1.0
		"banquier":
			if it.get("historique", false):
				return 1.0
			return 2.5 if e.m >= int(it.get("echeance", 1 << 30)) else 4.0
		"vie":
			return 1.0 if it.get("force", false) else 3.0
		"projet":
			return 2.0 if it.get("echeance_projet", false) else 5.0
		"carte":
			return 6.0
	return 7.0


## Interruption datée (elle doit passer à son mois) : rang ≤ 2,5. Les autres sont flexibles.
static func datee(e: EtatPartie, it: Dictionary) -> bool:
	return rang(e, it) <= 2.5


## Le mois mm porte-t-il une interruption datée connue (données, calendrier, file) ? sauf : l'interruption
## candidate elle-même (une présentation n'est pas retenue par sa propre date limite).
static func date_connue(e: EtatPartie, mm: int, sauf: Dictionary = {}) -> bool:
	if mm > e.m_fin:
		return false
	var ab := e.ab_de(mm)
	for ev in e.per.get("evenements", []):
		if Dates.lire(ev["d"]) == ab and ev["type"] != "-silencieux":
			return true
	for ev: Dictionary in e.calendrier:
		if int(ev["m"]) == mm and ev.get("force", false) and not ev.get("declenche", false):
			return true
	if e.banquier_actif():
		var dates := Banquier.dates_connues(e)
		for id in dates:
			if int(dates[id]) == mm and str(sauf.get("id", "")) != str(id):
				return true
	for it: Dictionary in e.file:
		if it == sauf:
			continue
		if int(it.get("echeance", -1)) == mm or (it.get("echeance_projet", false) and int(it.get("m_echeance", -1)) == mm):
			return true
	return false


## La candidate peut-elle passer ce mois-ci ? (R-CADENCE, exception marché → panne, anticipation)
static func peut_passer(e: EtatPartie, it: Dictionary) -> bool:
	if it["kind"] == "marche":
		return true
	var b := e.banque
	var derniere := int(b.get("derniere_interruption", -99))
	if it["kind"] == "vie" and it.get("force", false) and derniere == e.m - 1 and str(b.get("derniere_kind", "")) == "marche":
		return true   # la panne forcée qui suit le krach
	if e.m - derniere < int(params()["ecart_min"]):
		return false
	if not datee(e, it) and date_connue(e, e.m + 1, it):
		return false
	return true


## Choisit l'interruption du mois parmi e.file (au plus une) et la retire de la file ; les événements de vie
## aléatoires sans décision qui ne passent pas deviennent des notifications. Renvoie {} si aucune.
static func choisir(e: EtatPartie, notifs: Array) -> Dictionary:
	var tri := e.file.duplicate()
	tri.sort_custom(func(x: Dictionary, z: Dictionary) -> bool: return _avant(e, x, z))
	var plafond_atteint := int(e.banque.get("interruptions", 0)) >= int(params()["plafond_interruptions"])
	var choisi := {}
	for it: Dictionary in tri:
		if _vie_mineure(it) and plafond_atteint:
			continue
		if peut_passer(e, it):
			choisi = it
			break
	if not choisi.is_empty():
		e.file.erase(choisi)
	for it: Dictionary in e.file.duplicate():
		if _vie_mineure(it):
			e.file.erase(it)
			e._vie_en_notification(int(it["idx"]), notifs)
	if not choisi.is_empty():
		noter(e, choisi)
	return choisi


static func _avant(e: EtatPartie, x: Dictionary, z: Dictionary) -> bool:
	var rx := rang(e, x)
	var rz := rang(e, z)
	if rx != rz:
		return rx < rz
	return int(x["m"]) < int(z["m"])


static func _vie_mineure(it: Dictionary) -> bool:
	return it["kind"] == "vie" and not it.get("force", false) and not it.get("decision", false)


## Compte une interruption ouverte ce mois-ci (aussi pour une naissance forcée par le débogage).
static func noter(e: EtatPartie, it: Dictionary) -> void:
	var b := e.banque
	var cat := categorie(it)
	var c: Dictionary = b.get("compteurs", compteurs_vides())
	c[cat] = int(c.get(cat, 0)) + 1
	b["compteurs"] = c
	if cat == "classiques":
		b["interruptions"] = int(b.get("interruptions", 0)) + 1
	var quoi := str(it.get("id", ""))
	if it.has("idx"):
		quoi = str(e.calendrier[int(it["idx"])]["type"])
	var motif := "ecart"
	if it["kind"] == "marche":
		motif = "marche"
	elif it.get("historique", false):
		motif = "historique"
	elif it.get("force", false):
		motif = "scripte"
	elif datee(e, it):
		motif = "echeance"
	var liste: Array = b.get("interruptions_liste", [])
	liste.append({"m": e.m, "kind": it["kind"], "id": quoi, "motif": motif, "rang": rang(e, it), "datee": datee(e, it), "categorie": cat})
	b["interruptions_liste"] = liste
	b["derniere_interruption"] = e.m
	b["derniere_kind"] = str(it["kind"])
