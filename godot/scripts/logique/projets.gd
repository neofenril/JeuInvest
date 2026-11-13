class_name Projets
extends RefCounted
## P1 « Les projets du foyer » (docs/15 §3 ; lot 04, partie 04-L : D6 à D8, contrat §4.2). Fonctions statiques sur une
## partie (comme Foyer et Cadence), sans nœud. Données : data/projets.json. L'état vit dans EtatPartie.projets
## (sauvegardé) ; etat_partie.gd ne contient que les points d'appel et des accesseurs d'une ligne.
##
## - Éteint par défaut (D6) : projets.actif est lu au démarrage (config.projets, sinon projets.json > actif) et gardé
##   dans la sauvegarde ; une sauvegarde sans champ projets reste sans projets. Démo avec le banquier seulement (Cadence).
## - Deux projets au plus, un seul en cours : la carte de choix (kind « projet », etape « choix », rang 5, datée au
##   dernier mois de sa fenêtre) entre en file au mois préféré si aucun projet n'est en cours ; le choix fixe l'option
##   et son échéance. Au mois de l'échéance, la carte « Le jour J » (etape « echeance », rang 2, datée) entre en file.
## - Échéance : RÉALISER (disponible = compte + Livret A suffisant), RÉALISER EN VENDANT (disponible + ventes
##   suffisantes), REPORTER (une fois, + report_mois ou premier mois libre ; jamais pour P2C), RENONCER.
## - Vente automatique (décision du joueur du 2026-11-13) : compte courant, Livret A, puis le reste par rentabilité
##   croissante (projets.json > _ordre_vente), juste ce qu'il faut, avec les frais, impôts et pénalités du moteur.
## - R-MIROIR : à la réalisation, les témoins paient le même montant le même mois (compte courant, négatif permis ;
##   le Livret A suit à la répartition du mois suivant) ; rien à l'abandon. P2C : l'apport reste dans le patrimoine.
## - Humeur (Foyer) : réalisé + 2 (+ 1 après un report), reporté − 1, abandonné − 2.
## - Rappel : notification sans pause (type projet_rappel) rappel_mois avant l'échéance initiale, une par projet.

const EPS := 0.005


static func donnees() -> Dictionary:
	return Donnees.charger("projets")


static func _def(pid: String) -> Dictionary:
	for p: Dictionary in donnees()["projets"]:
		if str(p["id"]) == pid:
			return p
	return {}


## Option (« P1C ») et son projet (« P1 ») : { option, projet }.
static func _option(oid: String) -> Dictionary:
	for p: Dictionary in donnees()["projets"]:
		for o: Dictionary in p["options"]:
			if str(o["id"]) == oid:
				return {"option": o, "projet": p}
	return {}


static func _mois_de(e: EtatPartie, d: String) -> int:
	return Dates.lire(d) - e.mk.ab_debut


static func montant_option(o: Dictionary) -> float:
	return Produits.f(float(o["montant_F"]))


# =====================================================================
# État
# =====================================================================

## État de départ (appelé par EtatPartie.demarrer).
static func etat_initial(_e: EtatPartie, config: Dictionary) -> Dictionary:
	var d := donnees()
	var p := {"actif": bool(config.get("projets", d.get("actif", false))), "projets": {}, "apports": {}}
	for x: Dictionary in d["projets"]:
		p["projets"][str(x["id"])] = _etat_vide()
	return p


static func _etat_vide() -> Dictionary:
	return {"etat": "attente", "option": "", "m_choix": -1, "m_echeance": -1, "m_echeance_initiale": -1,
		"report_utilise": false, "rappel_fait": false, "m_fin": -1}


## Après le rechargement d'une sauvegarde : sans champ projets (main, 0.4.1 et avant), les projets restent éteints.
static func apres_chargement(e: EtatPartie, avait_projets: bool) -> void:
	if not avait_projets:
		e.projets["actif"] = false
	for x: Dictionary in donnees()["projets"]:
		var pid := str(x["id"])
		var s: Dictionary = e.projets.get("projets", {}).get(pid, {})
		var vide := _etat_vide()
		vide.merge(s, true)
		if not e.projets.has("projets"):
			e.projets["projets"] = {}
		e.projets["projets"][pid] = vide
	if not e.projets.has("apports"):
		e.projets["apports"] = {}


## Les projets s'ouvrent-ils dans cette partie ? (drapeau de la partie et démo avec le banquier)
static func actif(e: EtatPartie) -> bool:
	return bool(e.projets.get("actif", false)) and e.banquier_actif()


static func _etats(e: EtatPartie) -> Dictionary:
	return e.projets.get("projets", {})


## Projet en cours (choix fait, échéance pas encore réglée) : id du projet (« P1 ») ou "".
static func _pid_en_cours(e: EtatPartie) -> String:
	var etats := _etats(e)
	for pid: String in etats:
		if str(etats[pid]["etat"]) in ["en_cours", "echeance"]:
			return pid
	return ""


## L'option oid (« P2A ») a-t-elle été choisie (projet en cours ou passé) ? Projets éteints : non.
static func option_choisie(e: EtatPartie, oid: String) -> bool:
	if not actif(e):
		return false
	var etats := _etats(e)
	for pid: String in etats:
		if str(etats[pid]["option"]) == oid:
			return true
	return false


## Une échéance du projet en cours tombe-t-elle au mois mm (index de période) ? Projets éteints : non.
static func echeance_en(e: EtatPartie, mm: int) -> bool:
	if not actif(e):
		return false
	var pid := _pid_en_cours(e)
	return pid != "" and str(_etats(e)[pid]["etat"]) == "en_cours" and int(_etats(e)[pid]["m_echeance"]) == mm


## Une interruption datée au mois mm ferait-elle perdre toute sa fenêtre à la carte de choix d'un projet encore à venir ?
static func choix_condamne(e: EtatPartie, mm: int) -> bool:
	if not actif(e):
		return false
	for p: Dictionary in donnees()["projets"]:
		if str(_etats(e)[str(p["id"])]["etat"]) != "attente":
			continue
		var touche := false
		var libre := false
		for x in range(maxi(e.m, _mois_de(e, p["fenetre"][0])), _mois_de(e, p["fenetre"][1]) + 1):
			if absi(x - mm) <= 1:
				touche = true
			else:
				libre = true
		if touche and not libre:
			return true
	return false


## Apport gardé dans le patrimoine (P2C réalisé) du portefeuille w (euros).
static func apport(e: EtatPartie, w: Portefeuille) -> float:
	var ap: Dictionary = e.projets.get("apports", {})
	if ap.is_empty():
		return 0.0
	return float(ap.get(_cle_portefeuille(e, w), 0.0))


static func _cle_portefeuille(e: EtatPartie, w: Portefeuille) -> String:
	if w == e.joueur:
		return "joueur"
	for k: String in e.temoins:
		if e.temoins[k] == w:
			return k
	return ""


# =====================================================================
# Chaque mois (avant Foyer.preparer et Cadence.choisir)
# =====================================================================

## Rappel, carte de choix et carte du jour J mises en file. Rien si les projets sont éteints.
static func preparer(e: EtatPartie, notifs: Array) -> void:
	if not actif(e):
		return
	var etats := _etats(e)
	var en_cours := ""   # un seul projet à la fois : choix en attente, en cours ou jour J
	for pid0: String in etats:
		if str(etats[pid0]["etat"]) in ["choix", "en_cours", "echeance"]:
			en_cours = pid0
	for p: Dictionary in donnees()["projets"]:
		var pid := str(p["id"])
		var s: Dictionary = etats[pid]
		match str(s["etat"]):
			"attente":
				if en_cours == "" and e.m >= _mois_de(e, p["prefere"]):
					e.file.append({"kind": "projet", "id": pid, "etape": "choix", "m": e.m, "prio": 5, "source": "maison",
						"echeance": maxi(e.m, _mois_de(e, p["fenetre"][1]))})
					s["etat"] = "choix"
					en_cours = pid
			"en_cours":
				var o: Dictionary = _option(str(s["option"]))["option"]
				if not bool(s["rappel_fait"]) and e.m >= int(s["m_echeance_initiale"]) - int(donnees()["rappel_mois"]) and e.m < int(s["m_echeance"]):
					s["rappel_fait"] = true
					notifs.append(_notif_rappel(e, s, o))
				if e.m >= int(s["m_echeance"]):
					e.file.append({"kind": "projet", "id": str(o["id"]), "projet": pid, "etape": "echeance", "echeance_projet": true,
						"m_echeance": int(s["m_echeance"]), "m": e.m, "prio": 2, "source": "maison"})
					s["etat"] = "echeance"


static func _notif_rappel(e: EtatPartie, s: Dictionary, o: Dictionary) -> Dictionary:
	var a := e.ab_courant()
	var t: Dictionary = donnees()["textes"]
	var vals := _vals(e, o, int(s["m_echeance"]))
	var cle := "rappel_texte_atteint" if disponible(e) >= montant_option(o) - EPS else "rappel_texte"
	return {"type": "projet_rappel", "source": "maison", "cls": "neutre", "projet": str(o["id"]),
		"titre": Format.gabarit(str(t["rappel_titre"]), vals), "texte": Format.gabarit(str(t[cle]), vals),
		"montant": montant_option(o), "ab": a}


## Valeurs des gabarits pour l'option o, échéance mm.
static func _vals(e: EtatPartie, o: Dictionary, mm: int) -> Dictionary:
	var a := e.ab_courant()
	var ab_ech := e.ab_de(mm)
	return {"nom": str(o["nom"]), "court": str(o["court"]), "replique": str(o.get("replique_realise", "")), "montant": Format.entier(montant_option(o), a),
		"echeance": Dates.texte(ab_ech), "mois": Dates.MOIS[Dates.mois(ab_ech) - 1], "disponible": Format.entier(disponible(e), a),
		"prenoms": Banquier.prenoms_enfants(e)}


# =====================================================================
# Argent : disponible, revendable, plan de vente
# =====================================================================

## Disponible sans rien vendre : compte courant + Livret A.
static func disponible(e: EtatPartie) -> float:
	return e.joueur.cc + e.joueur.livret


## Lignes revendables du joueur, vendues en entier ce mois-ci, dans l'ordre de vente : rentabilité croissante.
## [{ id, genre (sicav | action | emprunt | av | pel), net, verse, perf }]
static func _lignes(e: EtatPartie) -> Array:
	var w := e.joueur
	var out := []
	for id: String in w.lignes:
		var d := e.devis_vente(w, id, 0.0, true)
		if d["ok"]:
			out.append({"id": id, "genre": "action" if e.produit(id).get("type", "") == "action" else "sicav", "net": float(d["recu"]), "verse": w.cout(id)})
	if w.valeur_emprunts() > EPS:
		var d2 := Produits.devis_vente_emprunt(e, w, 0.0, true)
		if d2["ok"]:
			out.append({"id": "emprunt", "genre": "emprunt", "net": float(d2["recu"]), "verse": w.valeur_emprunts()})
	if not w.av.is_empty():
		var d3 := Produits.devis_rachat_av(e, w, 0.0, true)
		if d3["ok"]:
			out.append({"id": "av", "genre": "av", "net": float(d3["recu"]), "verse": float(w.av["primes"])})
	if not w.pel.is_empty():
		var d4 := Produits.devis_cloture_pel(e, w)
		if d4["ok"]:
			out.append({"id": "pel", "genre": "pel", "net": float(d4["recu"]), "verse": float(w.pel["verse"])})
	for l: Dictionary in out:
		l["perf"] = (float(l["net"]) - float(l["verse"])) / float(l["verse"]) if float(l["verse"]) > EPS else 0.0
	out.sort_custom(func(x: Dictionary, z: Dictionary) -> bool: return _avant_vente(x, z))
	return out


## Ordre de vente : rentabilité croissante ; à égalité, ordre « egalite » de projets.json, puis l'identifiant.
static func _avant_vente(x: Dictionary, z: Dictionary) -> bool:
	if absf(float(x["perf"]) - float(z["perf"])) > 1e-9:
		return float(x["perf"]) < float(z["perf"])
	var egalite: Array = donnees()["egalite"]
	var gx := egalite.find(x["genre"])
	var gz := egalite.find(z["genre"])
	if gx != gz:
		return gx < gz
	return str(x["id"]) < str(z["id"])


## Valeur nette de revente de tous les placements (frais, impôts et pénalités déduits).
static func revendable(e: EtatPartie) -> float:
	var s := 0.0
	for l: Dictionary in _lignes(e):
		s += float(l["net"])
	return s


## Ventes nécessaires pour payer « besoin » au-delà du disponible, dans l'ordre (contrat §4.2). Chaque élément :
## { id, nom, vendu (brut), net, frais, impot, penalite, texte_penalite, ecart_verse, texte_ecart } (+ clés internes
## « _genre », « _montant », « _tout » pour l'exécution). Si les placements ne suffisent pas : toutes les lignes.
static func plan_vente(e: EtatPartie, besoin: float) -> Array:
	var out := []
	if besoin <= EPS:
		return out
	var reste := besoin
	for l: Dictionary in _lignes(e):
		if reste <= EPS:
			break
		var v := _vente_ligne(e, l, reste)
		if v.is_empty():
			continue
		out.append(v)
		reste -= float(v["net"])
	return out


## Vente d'une ligne : en entier si son net ne dépasse pas « besoin », sinon juste ce qu'il faut.
static func _vente_ligne(e: EtatPartie, l: Dictionary, besoin: float) -> Dictionary:
	var w := e.joueur
	var a := e.ab_courant()
	var id := str(l["id"])
	var tout := float(l["net"]) <= besoin + EPS
	var v := {"id": id, "nom": e.nom_ligne(id), "vendu": 0.0, "net": 0.0, "frais": 0.0, "impot": 0.0, "penalite": 0.0,
		"texte_penalite": "", "ecart_verse": 0.0, "texte_ecart": "", "_genre": str(l["genre"]), "_montant": 0.0, "_tout": tout}
	var verse_part := 0.0
	var pen: Dictionary = donnees()["penalites"]
	match str(l["genre"]):
		"action", "sicav":
			var d := e.devis_vente(w, id, 0.0, true)
			if not tout:
				d = _devis_partiel_titre(e, id, besoin)
				tout = float(d["qte"]) >= w.qte(id) - 1e-9
				v["_tout"] = tout
			v["vendu"] = float(d["brut"])
			v["net"] = float(d["recu"])
			v["frais"] = float(d["frais"])
			v["impot"] = float(d["impot"])
			v["_montant"] = float(d["brut"])
			verse_part = w.cout(id) * float(d["qte"]) / w.qte(id)
			if str(l["genre"]) == "action":
				var perte := float(d["pv"]) <= 0.0
				var f := Marche.frais(a)
				var courtage := "%s%s%%, minimum %s" % [Banquier.taux_txt(float(f["taux"])), Format.ESPACE, Format.entier(float(f["min"]), a)]
				v["texte_penalite"] = Format.gabarit(str(pen["action_perte" if perte else "action"]), {"frais": Format.entier(float(v["frais"]), a), "courtage": courtage,
					"impot": Format.entier(float(v["impot"]), a)})
			elif float(v["impot"]) > EPS:
				v["texte_penalite"] = Format.gabarit(str(pen["sicav"]), {"impot": Format.entier(float(v["impot"]), a)})
		"emprunt":
			var mt := w.valeur_emprunts() if tout else besoin
			var d2 := Produits.devis_vente_emprunt(e, w, mt, tout)
			v["vendu"] = float(d2["nominal"])
			v["net"] = float(d2["recu"])
			v["impot"] = float(d2["impot"])
			v["_montant"] = float(d2["nominal"])
			verse_part = float(d2["nominal"])
			v["texte_penalite"] = str(pen["emprunt"])
		"av":
			var d3 := Produits.devis_rachat_av(e, w, 0.0, true)
			if not tout:
				d3 = _devis_partiel_av(e, besoin)
				tout = bool(d3["tout"])
				v["_tout"] = tout
			v["vendu"] = float(d3["montant"])
			v["net"] = float(d3["recu"])
			v["impot"] = float(d3["impot"])
			v["_montant"] = float(d3["montant"])
			verse_part = float(d3["montant"]) - float(d3["gains"])
			if float(d3["impot"]) > EPS:
				v["texte_penalite"] = Format.gabarit(str(pen["av"]), {"taux": Banquier.taux_txt(float(d3["taux"])) + Format.ESPACE + "%",
					"x": Format.entier(float(d3["impot"]), a)})
		"pel":
			var d4 := Produits.devis_cloture_pel(e, w)
			v["_tout"] = true
			v["vendu"] = float(d4["recu"]) + float(d4["penalite"])
			v["net"] = float(d4["recu"])
			v["penalite"] = float(d4["penalite"])
			verse_part = float(w.pel["verse"])
			if bool(d4["anticipee"]):
				v["texte_penalite"] = Format.gabarit(str(pen["pel"]), {"x": Format.entier(float(d4["penalite"]), a)})
			else:
				v["texte_penalite"] = str(pen["pel_apres"])
		_:
			return {}
	v["ecart_verse"] = float(v["net"]) - verse_part
	var cle := "ecart_egal"
	if float(v["ecart_verse"]) <= -0.5 / Format.TAUX_EURO:
		cle = "ecart_moins"
	elif float(v["ecart_verse"]) >= 0.5 / Format.TAUX_EURO:
		cle = "ecart_plus"
	v["texte_ecart"] = Format.gabarit(str(pen[cle]), {"produit": str(v["nom"]), "net": Format.entier(float(v["net"]), a),
		"ecart": Format.entier(absf(float(v["ecart_verse"])), a)})
	return v


## Actions : titres entiers, le moins possible pour recevoir au moins « besoin » ; SICAV : le montant brut juste suffisant.
static func _devis_partiel_titre(e: EtatPartie, id: String, besoin: float) -> Dictionary:
	var w := e.joueur
	var p := e.cours(id)
	var detenu := w.qte(id)
	if e.produit(id).get("type", "") == "action":
		var q := maxi(1, int(floor(besoin / p)))
		while float(q) < detenu:
			var d := e.devis_vente(w, id, q * p)
			if float(d["recu"]) >= besoin - 1e-9:
				return d
			q += 1
		return e.devis_vente(w, id, 0.0, true)
	var brut := besoin
	for _i in 60:
		var d2 := e.devis_vente(w, id, brut)
		if float(d2["recu"]) >= besoin - 1e-9 or float(d2["qte"]) >= detenu - 1e-9:
			return d2
		brut *= besoin / maxf(float(d2["recu"]), 1e-9) * (1.0 + 1e-9)
	return e.devis_vente(w, id, 0.0, true)


## Assurance-vie : rachat partiel juste suffisant (seule la part de gains est imposée).
static func _devis_partiel_av(e: EtatPartie, besoin: float) -> Dictionary:
	var w := e.joueur
	var mt := besoin
	for _i in 60:
		var d := Produits.devis_rachat_av(e, w, mt)
		if float(d["recu"]) >= besoin - 1e-9 or bool(d["tout"]):
			return d
		mt *= besoin / maxf(float(d["recu"]), 1e-9) * (1.0 + 1e-9)
	return Produits.devis_rachat_av(e, w, 0.0, true)


## Exécute un plan de vente (ordres du moteur : frais, impôts, pénalités) ; renvoie les ventes faites (mêmes champs).
static func _executer_plan(e: EtatPartie, plan: Array) -> Array:
	var faites := []
	for v: Dictionary in plan:
		var cc0 := e.joueur.cc
		match str(v["_genre"]):
			"action", "sicav":
				e.vendre(e.joueur, str(v["id"]), float(v["_montant"]), bool(v["_tout"]), true)
			"emprunt":
				e.vendre_emprunt(float(v["_montant"]), bool(v["_tout"]))
			"av":
				e.racheter_av(float(v["_montant"]), bool(v["_tout"]))
			"pel":
				e.cloturer_pel()
		var fait := _sans_internes(v)
		fait["recu"] = e.joueur.cc - cc0
		faites.append(fait)
	return faites


static func _sans_internes(v: Dictionary) -> Dictionary:
	var out := {}
	for k: String in v:
		if not k.begins_with("_"):
			out[k] = v[k]
	return out


# =====================================================================
# Modales (kind « projet ») : contenu, choix, résolution
# =====================================================================

static func _item_etape(e: EtatPartie) -> String:
	return str(e.modale.get("etape", ""))


## Contenu de la modale « projet » ouverte (contrat §4.2).
static func contenu(e: EtatPartie) -> Dictionary:
	var a := e.ab_courant()
	var t: Dictionary = donnees()["textes"]
	if _item_etape(e) == "choix":
		var p := _def(str(e.modale["id"]))
		var ch := []
		for o: Dictionary in p["options"]:
			ch.append({"id": str(o["id"]), "titre": str(o["nom"]), "montant": montant_option(o),
				"echeance_txt": Dates.texte(Dates.lire(str(o["echeance"]))), "icone": str(o["icone"]), "sous": str(o.get("sous", ""))})
		var echeance_p := Dates.texte(Dates.lire(str(p["options"][0]["echeance"])))
		return {"kind": "projet", "etape": "choix", "source": str(e.modale.get("source", "maison")), "date": Dates.texte(a, true), "ab": a,
			"id": str(p["id"]), "titre": str(p["titre"]),
			"texte": Format.gabarit(str(p["texte"]), {"echeance": echeance_p, "prenoms": Banquier.prenoms_enfants(e)}), "choix": ch}
	var pid := str(e.modale.get("projet", ""))
	var s: Dictionary = _etats(e)[pid]
	var o: Dictionary = _option(str(s["option"]))["option"]
	var mt := montant_option(o)
	var dispo := disponible(e)
	var manque := maxf(0.0, mt - dispo)
	var ventes := plan_vente(e, manque)
	var nets := 0.0
	for v: Dictionary in ventes:
		nets += float(v["net"])
	var vals := _vals(e, o, int(s["m_echeance"]))
	vals["manque"] = Format.entier(manque, a)
	var cle_texte := "echeance_texte_manque" if manque > EPS else "echeance_texte_suffisant"
	return {"kind": "projet", "etape": "echeance", "source": str(e.modale.get("source", "maison")), "date": Dates.texte(a, true), "ab": a,
		"id": str(o["id"]), "titre": Format.gabarit(str(t["echeance_titre"]), vals), "texte": Format.gabarit(str(t[cle_texte]), vals),
		"montant": mt, "disponible": dispo, "manque": manque, "ventes": ventes.map(func(v: Dictionary) -> Dictionary: return _sans_internes(v)),
		"apres_ventes": dispo + nets, "choix": _choix_echeance(e, s, o, dispo, dispo + nets)}


static func _reportable(e: EtatPartie, s: Dictionary, o: Dictionary) -> bool:
	return bool(o.get("reportable", true)) and not bool(s["report_utilise"]) and _mois_report(e) >= 0


## Nouvelle échéance d'un report : + report_mois, ou le premier mois libre suivant (aucune interruption datée connue
## au mois d'avant, au mois même ni au mois d'après, et qui ne condamne pas la fenêtre d'un créneau de carte).
static func _mois_report(e: EtatPartie) -> int:
	var mm := e.m + int(donnees()["report_mois"])
	var sauf := e.modale
	# Jamais deux projets en cours : le report doit finir avant la fenêtre du choix du projet suivant (sinon il serait perdu)
	var limite := e.m_fin
	for p: Dictionary in donnees()["projets"]:
		if str(_etats(e)[str(p["id"])]["etat"]) == "attente":
			limite = mini(limite, _mois_de(e, p["fenetre"][0]) - 1)
	while mm <= limite and (Cadence.date_ferme(e, mm - 1, sauf) or Cadence.date_ferme(e, mm, sauf) or Cadence.date_ferme(e, mm + 1, sauf) or Foyer.fenetre_condamnee(e, mm)):
		mm += 1
	return mm if mm <= limite else -1

static func _choix_echeance(e: EtatPartie, s: Dictionary, o: Dictionary, dispo: float, apres: float) -> Array:
	var a := e.ab_courant()
	var b: Dictionary = donnees()["boutons"]
	var mt := montant_option(o)
	var ch := []
	if dispo >= mt - EPS:
		ch.append({"id": "realiser", "titre": str(b["realiser"]["titre"]), "desactive": false, "sous": str(b["realiser"]["sous"])})
	else:
		var possible := apres >= mt - EPS
		var cle := "sous" if possible else "sous_impossible"
		var manque := mt - dispo if possible else mt - apres
		ch.append({"id": "realiser_en_vendant", "titre": str(b["realiser_en_vendant"]["titre"]), "desactive": not possible,
			"sous": Format.gabarit(str(b["realiser_en_vendant"][cle]), {"manque": Format.entier(manque, a)})})
	var reportable := bool(o.get("reportable", true))
	if reportable and _reportable(e, s, o):
		ch.append({"id": "reporter", "titre": str(b["reporter"]["titre"]), "desactive": false,
			"sous": Format.gabarit(str(b["reporter"]["sous"]), {"echeance": Dates.texte(e.ab_de(_mois_report(e)))})})
	ch.append({"id": "renoncer", "titre": str(b["renoncer"]["titre"] if reportable else b["renoncer"]["titre_sans_report"]), "desactive": false,
		"sous": str(b["renoncer"]["sous"])})
	return ch


static func choix_valide(e: EtatPartie, choix_id: String) -> bool:
	var c := contenu(e)
	for ch: Dictionary in c.get("choix", []):
		if str(ch["id"]) == choix_id and not bool(ch.get("desactive", false)):
			return true
	return false


## Choix par défaut (D8) : l'option la moins chère ; au jour J : réaliser si le disponible suffit, sinon reporter si
## possible, sinon renoncer (jamais de vente sans le joueur).
static func choix_auto(e: EtatPartie) -> String:
	return choix_politique(e, "moins_cher", "auto")


## Politiques de test (StrategieTest) : choix moins_cher | plus_cher | milieu ; échéance auto (D8) | vendre (réaliser en
## vendant si c'est possible).
static func choix_politique(e: EtatPartie, politique: String, echeance: String) -> String:
	var c := contenu(e)
	var ch: Array = c.get("choix", [])
	if c.get("etape", "") == "choix":
		var tri := ch.duplicate()
		tri.sort_custom(func(x: Dictionary, z: Dictionary) -> bool: return float(x["montant"]) < float(z["montant"]))
		match politique:
			"plus_cher":
				return str(tri[tri.size() - 1]["id"])
			"milieu":
				return str(tri[floori(tri.size() / 2.0)]["id"])
		return str(tri[0]["id"])
	var ids := {}
	for x: Dictionary in ch:
		if not bool(x.get("desactive", false)):
			ids[str(x["id"])] = true
	if ids.has("realiser"):
		return "realiser"
	if echeance == "vendre" and ids.has("realiser_en_vendant"):
		return "realiser_en_vendant"
	if ids.has("reporter"):
		return "reporter"
	return "renoncer"


## Résout la modale « projet » ouverte (choix déjà validé). vu : contenu affiché (complété pour l'historique).
static func resoudre(e: EtatPartie, choix_id: String, vu: Dictionary) -> Dictionary:
	var notifs := []
	var avant := Foyer.humeur_visible(e)
	var t: Dictionary = donnees()["textes"]
	var r := {"choix": choix_id, "kind": "projet", "etape": _item_etape(e), "montant": 0.0, "consequence": "", "humeur_avant": avant,
		"humeur_apres": avant, "notifs": notifs, "ventes": []}
	if _item_etape(e) == "choix":
		var pid := str(e.modale["id"])
		var s: Dictionary = _etats(e)[pid]
		var o: Dictionary = _option(choix_id)["option"]
		s["etat"] = "en_cours"
		s["option"] = choix_id
		s["m_choix"] = e.m
		s["m_echeance"] = _mois_de(e, str(o["echeance"]))
		s["m_echeance_initiale"] = s["m_echeance"]
		r["montant"] = montant_option(o)
		r["consequence"] = Format.gabarit(str(t["consequence_choix"]), _vals(e, o, int(s["m_echeance"])))
	else:
		var pid2 := str(e.modale["projet"])
		var s2: Dictionary = _etats(e)[pid2]
		var o2: Dictionary = _option(str(s2["option"]))["option"]
		var mt := montant_option(o2)
		var h: Dictionary = donnees()["humeur"]
		var vals := _vals(e, o2, int(s2["m_echeance"]))
		match choix_id:
			"realiser", "realiser_en_vendant":
				if choix_id == "realiser_en_vendant":
					r["ventes"] = _executer_plan(e, plan_vente(e, mt - disponible(e)))
				_payer(e, o2, mt)
				var apres_report := bool(s2["report_utilise"])
				s2["etat"] = "realise_apres_report" if apres_report else "realise"
				s2["m_fin"] = e.m
				r["montant"] = -mt
				r["consequence"] = Format.gabarit(str(t["consequence_realise" if str(vals["replique"]) != "" else "consequence_realise_sans_replique"]), vals)
				var d := int(h["realise_apres_report"] if apres_report else h["realise"])
				Foyer._regler_humeur(e, int(e.foyer.get("humeur", 0)) + d, str(r["consequence"]), notifs)
			"reporter":
				s2["m_echeance"] = _mois_report(e)
				s2["report_utilise"] = true
				s2["etat"] = "en_cours"
				r["consequence"] = Format.gabarit(str(t["consequence_reporte"]), _vals(e, o2, int(s2["m_echeance"])))
				Foyer._regler_humeur(e, int(e.foyer.get("humeur", 0)) + int(h["reporte"]), str(r["consequence"]), notifs)
			_:
				s2["etat"] = "abandonne"
				s2["m_fin"] = e.m
				r["consequence"] = str(t["consequence_abandonne_p2c" if bool(o2.get("dans_patrimoine", false)) else "consequence_abandonne"])
				Foyer._regler_humeur(e, int(e.foyer.get("humeur", 0)) + int(h["abandonne"]), str(r["consequence"]), notifs)
	r["humeur_apres"] = Foyer.humeur_visible(e)
	e._enregistrer_hist()
	vu["consequence"] = r["consequence"]
	vu["montant_choisi"] = r["montant"]
	vu["ventes_faites"] = r["ventes"]
	return r


## Paiement de la réalisation : joueur (compte courant puis Livret A) et témoins (R-MIROIR, compte courant). Un
## apport gardé dans le patrimoine (P2C) passe du compte à la ligne « apport » au lieu d'être dépensé.
static func _payer(e: EtatPartie, o: Dictionary, mt: float) -> void:
	var garde := bool(o.get("dans_patrimoine", false)) and bool(donnees().get("p2c_dans_patrimoine", true))
	e.joueur.cc -= mt
	if e.joueur.cc < 0.0 and e.joueur.livret > 0.0:
		e.retirer_livret(e.joueur, minf(e.joueur.livret, -e.joueur.cc))
	for k: String in e.temoins:
		e.temoins[k].cc -= mt
	if garde:
		var ap: Dictionary = e.projets.get("apports", {})
		for k2 in ["joueur", "matelas", "livret", "indice"]:
			ap[k2] = float(ap.get(k2, 0.0)) + mt
		e.projets["apports"] = ap
	else:
		e._compter_epargne(-mt, e.ab_courant())


## Entrée d'historique d'un projet (appelé par EtatPartie._historiser_modale) : genre « projet », montant, conséquence.
static func completer_historique(entree: Dictionary, c: Dictionary) -> void:
	entree["genre"] = "projet"
	entree["montant"] = float(c.get("montant_choisi", 0.0))
	entree["a_montant"] = str(c.get("etape", "")) == "echeance" and absf(float(c.get("montant_choisi", 0.0))) > 0.0
	entree["resume"] = EtatPartie.resume_texte(str(c.get("consequence", "")))


# =====================================================================
# Lecture (contrat §4.2, vague 4)
# =====================================================================

static func projet_en_cours(e: EtatPartie) -> Dictionary:
	if not actif(e):
		return {}
	var pid := _pid_en_cours(e)
	if pid == "":
		return {}
	var s: Dictionary = _etats(e)[pid]
	var o: Dictionary = _option(str(s["option"]))["option"]
	var mt := montant_option(o)
	var dispo := disponible(e)
	return {"id": str(o["id"]), "nom": str(o["nom"]), "icone": str(o["icone"]), "montant": mt, "m_echeance": int(s["m_echeance"]),
		"echeance_txt": Dates.texte(e.ab_de(int(s["m_echeance"]))), "mois_restants": maxi(0, int(s["m_echeance"]) - e.m),
		"report_utilise": bool(s["report_utilise"]), "reportable": _reportable(e, s, o),
		"disponible": dispo, "revendable": revendable(e), "atteint": dispo >= mt - EPS}


static func projets_passes(e: EtatPartie) -> Array:
	var out := []
	if not actif(e):
		return out
	for p: Dictionary in donnees()["projets"]:
		var s: Dictionary = _etats(e)[str(p["id"])]
		if str(s["etat"]) in ["realise", "realise_apres_report", "abandonne"]:
			var o: Dictionary = _option(str(s["option"]))["option"]
			out.append({"id": str(o["id"]), "nom": str(o["nom"]), "icone": str(o["icone"]), "montant": montant_option(o),
				"statut": str(s["etat"]), "m": int(s["m_fin"]), "ab": e.ab_de(int(s["m_fin"]))})
	return out


## « Projet : la Super 5, avril 1986 (dans 14 mois) · 30 000 F » ; "" sans projet en cours.
static func ligne_guichet(e: EtatPartie) -> String:
	var p := projet_en_cours(e)
	if p.is_empty():
		return ""
	var t: Dictionary = donnees()["textes"]
	var o: Dictionary = _option(str(p["id"]))["option"]
	var n := int(p["mois_restants"])
	var dans := str(t["ce_mois"]) if n <= 0 else (str(t["dans_mois_un"]) if n == 1 else Format.gabarit(str(t["dans_mois"]), {"n": str(n)}))
	return Format.gabarit(str(t["guichet_reporte" if bool(p["report_utilise"]) else "guichet"]), {"court": str(o["court"]), "echeance": str(p["echeance_txt"]), "dans": dans,
		"montant": Format.entier(float(p["montant"]), e.ab_courant())})


## Ventes nécessaires pour le projet en cours ([] si le disponible suffit ou sans projet).
static func plan_vente_projet(e: EtatPartie) -> Array:
	var p := projet_en_cours(e)
	if p.is_empty():
		return []
	return plan_vente(e, float(p["montant"]) - float(p["disponible"])).map(func(v: Dictionary) -> Dictionary: return _sans_internes(v))
