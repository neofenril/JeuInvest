class_name Quartier
extends RefCounted
## La rue (lot 05-L, phase A) : Jean-Mi, classement, notifications des voisins, du rang et du kiosque.
## Fonctions statiques, sans état propre ni nœud : l'état est un Dictionary tenu par l'appelant (EtatPartie, phase B).
## Toutes les sommes d'argent de ce module sont en FRANCS (le plan de Jean-Mi est écrit en F) : l'appelant convertit
## (Format.TAUX_EURO) le compte courant en entrée et le mouvement en sortie. Données : data/rue.json et
## data/temoins.json > jeanmi (docs/19, lot_05.md D3-D9). Les fonctions acceptent des données fabriquées (tests).

const ESPACE := " "
const LOIN := -1000   # « jamais eu lieu »


# ---------------------------------------------------------------------
# Données
# ---------------------------------------------------------------------

static func donnees_rue() -> Dictionary:
	return Donnees.charger("rue")


static func donnees_jeanmi() -> Dictionary:
	return Donnees.temoins()["jeanmi"]


static func plan_jeanmi() -> Dictionary:
	return donnees_jeanmi()["plan"]


## Nom, initiale d'un voisin : temoins.json (matelas, livret, jeanmi) ou rue.json > personnages (lopez, lefranc).
static func voisin(qui: String, rue: Dictionary = {}) -> Dictionary:
	var t := Donnees.temoins()
	if t.has(qui):
		return {"nom": str(t[qui]["nom"]), "initiale": str(t[qui]["initiale"])}
	var r := rue if not rue.is_empty() else donnees_rue()
	var p: Dictionary = r["personnages"].get(qui, {"nom": qui, "initiale": qui.left(1).to_upper()})
	return {"nom": str(p["nom"]), "initiale": str(p["initiale"])}


# ---------------------------------------------------------------------
# Jean-Mi : état et pas mensuel (D3, D4)
# ---------------------------------------------------------------------

## État initial : « attend le bon tuyau » (compte courant = celui du miroir, géré par l'appelant).
## etape : attend | position | porsche | liquide | rembourse. equite : compte de bourse (couverture ± gains, reports déduits).
## credit : capital restant dû de la Porsche ; voiture : sa valeur de marché ; dette : dette de bourse.
## levier : photo de la liquidation {couverture (fin du mois d'avant), position, baisse (-0,265), perte, dette}.
static func jeanmi_initial() -> Dictionary:
	return {"etape": "attend", "couverture": 0.0, "position": 0.0, "equite": 0.0, "dette": 0.0,
		"credit": 0.0, "voiture": 0.0, "voiture_etat": "", "mensualites": 0, "levier": {}}


## Mensualité du crédit (arrondie au franc : 2 897 F pour 110 000 F, 48 mois, 12 %).
static func mensualite(plan: Dictionary = {}) -> float:
	var v: Dictionary = (plan if not plan.is_empty() else plan_jeanmi())["voiture"]
	var i := float(v["taux"]) / 12.0
	var n := int(v["duree_mois"])
	if i <= 0.0:
		return roundf(float(v["credit"]) / n)
	return roundf(float(v["credit"]) * i / (1.0 - pow(1.0 + i, -n)))


static func valeur_voiture(plan: Dictionary, ab: int) -> float:
	var x: Variant = Donnees.en_vigueur(plan["voiture"]["decote"], ab)
	return 0.0 if x == null else float(x[1])


## Un mois de la vie de Jean-Mi. cours / cours_prec : Peugeot, fin de ce mois et du mois précédent ; compte_f : son
## compte courant avant le pas (sert seulement à fixer la couverture le mois d'ouverture). Renvoie
## {"etat": nouvel état, "mouvement": variation à appliquer à son compte courant (F), "evenements": [String]} ;
## événements : ouverture, renfort, achat_voiture, liquidation, vente_voiture, remboursement.
## Le compte de bourse (équité) ne passe PAS par le compte courant : couverture, gains, reports et apport de la
## Porsche y restent ; seuls la mise en couverture, les mensualités, la vente de la voiture, les remboursements
## et un éventuel reliquat de liquidation touchent le compte courant. Patrimoine conservé à chaque étape.
static func pas_mensuel(etat: Dictionary, ab: int, cours: float, cours_prec: float, compte_f: float,
		plan: Dictionary = {}) -> Dictionary:
	var p := plan if not plan.is_empty() else plan_jeanmi()
	var s := etat.duplicate(true)
	var mouvement := 0.0
	var evts: Array = []
	var m_liq := Dates.lire(str(p["liquidation"]))

	# Ouverture de la position : la couverture sort du compte courant ; achat à la clôture du mois.
	if s["etape"] == "attend":
		if ab >= Dates.lire(str(p["ouverture"])):
			var couv := maxf(float(p.get("couverture_min", 0.0)), maxf(0.0, float(p["couverture_part"]) * compte_f))   # plancher : voir temoins.json > _plan
			s["couverture"] = couv
			s["equite"] = couv
			s["position"] = couv * float(p["levier"])
			s["etape"] = "position"
			mouvement -= couv
			evts.append("ouverture")
		return {"etat": s, "mouvement": mouvement, "evenements": evts}

	# Position au règlement mensuel : gain du mois, coût du report ; liquidation d'office au mois du krach.
	if float(s["position"]) > 0.0:
		var r: Dictionary = p["renfort"]
		if ab == Dates.lire(str(r["mois"])):
			s["position"] = float(s["position"]) * (1.0 + float(r["part"]))
			evts.append("renfort")
		var gain := 0.0
		if cours_prec > 0.0:
			gain = float(s["position"]) * (cours / cours_prec - 1.0)
		if ab == m_liq:
			var fin := float(s["equite"]) + gain
			s["levier"] = {"couverture": float(s["equite"]), "position": float(s["position"]),
				"baisse": cours / cours_prec - 1.0 if cours_prec > 0.0 else 0.0, "perte": -gain,
				"dette": maxf(0.0, -fin)}
			if fin >= 0.0:
				mouvement += fin
			else:
				s["dette"] = -fin
			s["equite"] = 0.0
			s["position"] = 0.0
			s["etape"] = "liquide"
			evts.append("liquidation")
		else:
			s["equite"] = float(s["equite"]) + gain - float(s["position"]) * float(p["report_mensuel"])

	# Porsche à crédit : apport pris sur les gains, mensualités dès le mois suivant, vente à la décote.
	var v: Dictionary = p["voiture"]
	var m_achat := Dates.lire(str(v["achat"]))
	var m_vente := Dates.lire(str(v["vente"]))
	if ab == m_achat and s["voiture_etat"] == "":
		s["equite"] = float(s["equite"]) - float(v["apport"])
		s["credit"] = float(v["credit"])
		s["voiture_etat"] = "possedee"
		s["mensualites"] = 0
		if s["etape"] == "position":
			s["etape"] = "porsche"
		evts.append("achat_voiture")
	elif s["voiture_etat"] == "possedee":
		var du := float(s["credit"]) * (1.0 + float(v["taux"]) / 12.0)
		var paye := minf(mensualite(p), du)
		s["credit"] = du - paye
		s["mensualites"] = int(s["mensualites"]) + 1
		mouvement -= paye
		if ab >= m_vente:
			var prix := valeur_voiture(p, ab)
			mouvement += prix - float(s["credit"])
			s["credit"] = 0.0
			s["voiture_etat"] = "vendue"
			evts.append("vente_voiture")
	s["voiture"] = valeur_voiture(p, ab) if s["voiture_etat"] == "possedee" else 0.0

	# Remboursement de la dette de bourse.
	var rem: Dictionary = p["remboursement"]
	if float(s["dette"]) > 0.0 and ab >= Dates.lire(str(rem["debut"])):
		var pay := minf(float(rem["mensuel"]), float(s["dette"]))
		s["dette"] = float(s["dette"]) - pay
		mouvement -= pay
		s["etape"] = "rembourse"
		evts.append("remboursement")
	return {"etat": s, "mouvement": mouvement, "evenements": evts}


## Patrimoine de Jean-Mi (D3) : compte courant + équité du compte de bourse + voiture (valeur de marché)
## − capital restant dû − dette de bourse. Négatif possible.
static func patrimoine_jeanmi(etat: Dictionary, compte_f: float) -> float:
	return compte_f + float(etat["equite"]) + float(etat["voiture"]) - float(etat["credit"]) - float(etat["dette"])


## Nombres de la phrase du levier, arrondis au franc de façon cohérente : dette = perte − couverture.
## {} si pas de perte ou si la couverture a suffi (pas de dette).
static func levier_valeurs(levier: Dictionary) -> Dictionary:
	if levier.is_empty() or float(levier["perte"]) <= 0.0:
		return {}
	var perte := roundi(float(levier["perte"]))
	var couv := roundi(float(levier["couverture"]))
	var dette := perte - couv
	if dette <= 0:
		return {}
	return {"couverture": couv, "position": roundi(float(levier["position"])), "perte": perte, "dette": dette,
		"baisse_pct": absf(float(levier["baisse"])) * 100.0}


static func _f(x: float) -> String:
	return Format.nombre(x, 0) + Format.ESPACE + "F"


## Phrase du levier (V13) : gabarit rue.json > levier, remplie avec les chiffres du moteur. "" si non applicable.
static func phrase_levier(levier: Dictionary, rue: Dictionary = {}) -> String:
	var n := levier_valeurs(levier)
	if n.is_empty():
		return ""
	var r := rue if not rue.is_empty() else donnees_rue()
	return Format.gabarit(str(r["levier"]), {
		"couverture": _f(n["couverture"]), "position": _f(n["position"]),
		"baisse": Format.nombre(n["baisse_pct"], 1) + Format.ESPACE + "%",
		"perte": _f(n["perte"]), "dette": _f(n["dette"])})


# ---------------------------------------------------------------------
# Classement (D9) et réplique de fin de partie
# ---------------------------------------------------------------------

const _ORDRE := ["vous", "livret", "matelas", "jeanmi"]   # ordre de départage (égalité : le joueur devant)


## patrimoines : {"vous", "livret", "matelas", "jeanmi"} → 4 lignes triées, patrimoine décroissant
## (égalité : le joueur devant, puis ordre fixe). Contrat lot_05.md §4.3.
static func classement(patrimoines: Dictionary, rue: Dictionary = {}) -> Array:
	var r := rue if not rue.is_empty() else donnees_rue()
	var lignes: Array = []
	for id in _ORDRE:
		var nom: String
		var ini: String
		if id == "vous":
			nom = str(r["classement"]["vous"]["nom"])
			ini = str(r["classement"]["vous"]["initiale"])
		else:
			var vo := voisin(id, r)
			nom = vo["nom"]
			ini = vo["initiale"]
		lignes.append({"id": id, "nom": nom, "initiale": ini, "patrimoine": float(patrimoines[id]),
			"rang": 0, "vous": id == "vous", "reference": id == "livret"})
	lignes.sort_custom(_devant)

	for i in lignes.size():
		lignes[i]["rang"] = i + 1
	return lignes


static func _devant(a: Dictionary, b: Dictionary) -> bool:
	if absf(float(a["patrimoine"]) - float(b["patrimoine"])) > 1e-9:
		return float(a["patrimoine"]) > float(b["patrimoine"])
	return _ORDRE.find(a["id"]) < _ORDRE.find(b["id"])


static func rang_de(classement_: Array, id := "vous") -> int:
	for l in classement_:
		if l["id"] == id:
			return int(l["rang"])
	return 0


## « devant » : le joueur est devant Jean-Mi (égalité comprise) ; « derriere » sinon.
static func relation_jeanmi(classement_: Array) -> String:
	return "devant" if rang_de(classement_, "vous") < rang_de(classement_, "jeanmi") else "derriere"


## Réplique de l'écran de fin : le voisin juste devant le joueur, sinon celui juste derrière.
## {"qui", "nom", "texte"} (texte = `devant` ou `derriere` de temoins.json).
static func replique_rue(classement_: Array) -> Dictionary:
	var rj := rang_de(classement_, "vous")
	if rj == 0:
		return {}
	var cible_rang := rj - 1 if rj > 1 else rj + 1
	var cle := "devant" if rj > 1 else "derriere"
	for l in classement_:
		if int(l["rang"]) == cible_rang:
			var t: Dictionary = Donnees.temoins().get(l["id"], {})
			return {"qui": l["id"], "nom": l["nom"], "texte": str(t.get(cle, ""))}
	return {}


# ---------------------------------------------------------------------
# Notifications du mois (D7, D8, D9)
# ---------------------------------------------------------------------

## État du quartier (sauvegardé par l'appelant). attente : réactives déclenchées par le joueur {id: mois déclenché}.
## relation : dernière relation annoncée (« devant » au départ : égalité = joueur devant).
static func quartier_initial() -> Dictionary:
	return {"passages_vus": [], "abandonnes": [], "reactives_vues": [], "attente": {},
		"dernier_voisin": LOIN, "dernier_rang": LOIN, "relation": "devant",
		"kiosque_vus": [], "kiosque_abandonnes": []}


## Priorité à égalité de mois : passage ★ (0), réactive du joueur (1), passage ordinaire (2).
static func _classe(c: Dictionary) -> int:
	if c["cle"]:
		return 0
	return 1 if str(c["src"]["id"]).begins_with("R") else 2


static func _avant(a: Dictionary, b: Dictionary) -> bool:
	if _classe(a) != _classe(b):
		return _classe(a) < _classe(b)
	if a["depuis"] != b["depuis"]:
		return a["depuis"] < b["depuis"]
	return str(a["src"]["id"]) < str(b["src"]["id"])


static func _notif_voisin(c: Dictionary, ctx: Dictionary, r: Dictionary) -> Dictionary:
	var src: Dictionary = c["src"]
	var vals: Dictionary = ctx.get("valeurs", {})
	var texte := str(src["texte"])
	var projet := str(ctx.get("projet_id", ""))
	if src.has("par_projet") and src["par_projet"].has(projet):
		texte = str(src["par_projet"][projet])
	var n := {"type": "voisin", "source": "rue", "cls": "neutre", "id": str(src["id"]), "qui": str(src["qui"]),
		"titre": str(src.get("titre", voisin(str(src["qui"]), r)["nom"])), "texte": Format.gabarit(texte, vals),
		"cle": bool(src.get("cle", false)), "long": bool(src.get("long", false))}
	if bool(src.get("persistant", false)):
		n["persistant"] = true   # reste à l'écran jusqu'au toucher, sans pause (idée du game designer, lot 05-L B3)
	if n["long"]:
		n["texte_long"] = Format.gabarit(str(src.get("texte_long", "")), vals)
	return n


## Sélection des notifications de rue du mois ab (à appeler CHAQUE mois, y compris pendant un saut).
## ctx : {"pause": bool (le mois ouvre une interruption avec pause), "declencheurs": [String] (événements du joueur ce
## mois : "achat_action", "projet_realise"), "projet_id": String, "relation": "devant"|"derriere" (relation_jeanmi),
## "rang": int (rang du joueur), "valeurs": {b0, b1, levier} (gabarits)}.
## Renvoie {"notifs": [0 ou 1 notification], "etat": quartier mis à jour}. Règles : au plus 1 notification rue ou
## kiosque par mois, aucune un mois de pause ; 1 voisin (passage ou réactive) tous les 2 mois ; passage non clé
## abandonné après 2 mois de retard, passages ★ jamais ; rang tous les 6 mois, dès 10/1986 ; kiosque à sa date
## ou 1 mois après. Priorité (docs/27 §2.3) : rang, passage ★, réactive, passage ordinaire, kiosque.
static func notifications_du_mois(ab: int, q_in: Dictionary, ctx: Dictionary, rue: Dictionary = {}) -> Dictionary:
	var r := rue if not rue.is_empty() else donnees_rue()
	var b: Dictionary = r["budgets"]
	var q := q_in.duplicate(true)

	for d in ctx.get("declencheurs", []):
		for re in r["reactives"]:
			var id := str(re["id"])
			if re["declencheur"] == d and not q["reactives_vues"].has(id) and not q["attente"].has(id) \
					and not q["abandonnes"].has(id):
				q["attente"][id] = ab

	var cands: Array = []
	for p in r["passages"]:
		var id := str(p["id"])
		if not q["passages_vus"].has(id) and not q["abandonnes"].has(id) and Dates.lire(str(p["mois"])) <= ab:
			cands.append({"src": p, "depuis": Dates.lire(str(p["mois"])), "cle": bool(p.get("cle", false))})
	for re in r["reactives"]:
		var id := str(re["id"])
		if q["reactives_vues"].has(id) or q["abandonnes"].has(id):
			continue
		var depuis := LOIN
		if re["declencheur"] == "mois":
			depuis = Dates.lire(str(re["mois"]))
		elif q["attente"].has(id):
			depuis = int(q["attente"][id])
		if depuis != LOIN and depuis <= ab:
			cands.append({"src": re, "depuis": depuis, "cle": false})
	var vivants: Array = []
	for c in cands:
		if not c["cle"] and ab - int(c["depuis"]) > int(b["decalage_max"]):
			q["abandonnes"].append(str(c["src"]["id"]))
		else:
			vivants.append(c)
	vivants.sort_custom(_avant)

	var kio: Array = []
	for k in r["kiosque"]:
		var id := str(k["id"])
		var mk := Dates.lire(str(k["mois"]))
		if q["kiosque_vus"].has(id) or q["kiosque_abandonnes"].has(id) or mk > ab:
			continue
		if ab - mk > int(b["kiosque_decalage_max"]):
			q["kiosque_abandonnes"].append(id)
		else:
			kio.append(k)

	var notifs: Array = []
	if not ctx.get("pause", false):
		var relation := str(ctx.get("relation", q["relation"]))
		var rang_ok: bool = ab >= Dates.lire(str(b["rang_premier_mois"])) \
			and ab - int(q["dernier_rang"]) >= int(b["rang_ecart_mois"]) and relation != q["relation"]
		if rang_ok:
			var devant := relation == "devant"
			notifs.append({"type": "rang", "source": "rue", "cls": "gain" if devant else "perte",
				"titre": str(r["classement"]["titre_rang"]),
				"texte": str(r["rang"]["vous_devant" if devant else "jeanmi_devant"]),
				"rang": int(ctx.get("rang", 0))})
			q["relation"] = relation
			q["dernier_rang"] = ab
		elif not vivants.is_empty() and ab - int(q["dernier_voisin"]) >= int(b["voisin_ecart_mois"]):
			var c: Dictionary = vivants[0]
			notifs.append(_notif_voisin(c, ctx, r))
			q["dernier_voisin"] = ab
			var id := str(c["src"]["id"])
			if str(id).begins_with("R"):
				q["reactives_vues"].append(id)
				q["attente"].erase(id)
			else:
				q["passages_vus"].append(id)
		elif not kio.is_empty():
			var k: Dictionary = kio[0]
			notifs.append({"type": "kiosque", "source": "media", "cls": "neutre",
				"titre": str(r["classement"]["titre_kiosque"]), "texte": str(k["texte"]), "id": str(k["id"])})
			q["kiosque_vus"].append(str(k["id"]))
	return {"notifs": notifs, "etat": q}
