class_name Banquier
extends RefCounted
## M. Lefranc, fil conducteur de la démo V2 (12 §2, 13 §1-5, 11 §2.5 et §4.0) : déclencheurs des
## présentations, textes chiffrés avec l'argent du joueur, comparatif « par rapport à ce que vous
## connaissez », états des cartes du carnet, messages de la banque, relevé de décembre, piles des frais.
## Aucune dépendance aux nœuds. L'état propre au banquier vit dans EtatPartie.banque (sauvegardé).

const CRITERES := [["rendement", "Rendement"], ["risque", "Risque"], ["dispo", "Disponible"], ["fisc", "Fiscalité"]]


static func donnees() -> Dictionary:
	return Donnees.charger("banque")


static func etat_initial() -> Dictionary:
	return {"actif": true, "presentes": {}, "en_file": {}, "nouveaux": [], "messages": [], "interruptions": 0,
		"derniere_interruption": -99, "f01_vu": false, "naissance_m": -1, "frais_annee": 0.0, "interets_annee": 0.0,
		"interruptions_liste": [], "versements_annee": {}, "vpa_vu": false, "premier_eligible_m": -1}


static func info_produit(pid: String) -> Dictionary:
	return donnees()["produits"].get(pid, {})


static func couleur(pid: String) -> Color:
	var fam: String = info_produit(pid).get("famille", "cc")
	return Color(str(donnees()["familles"].get(fam, "8c96a8")))


static func presentation_de(pid: String) -> String:
	return str(info_produit(pid).get("presentation", ""))


## Le produit a été présenté par M. Lefranc (présentation vue au moins une fois : 12 R2).
static func presente(e: EtatPartie, pid: String) -> bool:
	if pid == "cc":
		return true
	return e.banque.get("presentes", {}).has(presentation_de(pid))


static func ordre_carnet() -> Array:
	return donnees()["ordre_carnet"]


static func nb_decouverts(e: EtatPartie) -> int:
	var n := 0
	for pid in ordre_carnet():
		if presente(e, pid):
			n += 1
	return n


## Le joueur détient-il ce produit ?
static func detenu(e: EtatPartie, pid: String) -> bool:
	var w := e.joueur
	match pid:
		"cc":
			return true
		"livret":
			return w.livret > Produits.f(1.0)
		"pel":
			return not w.pel.is_empty()
		"emprunt":
			return not w.emprunts.is_empty()
		"av":
			return not w.av.is_empty()
	return w.lignes.has(pid)


static func nb_detenus(e: EtatPartie) -> int:
	var n := 0
	for pid in ordre_carnet():
		if detenu(e, pid):
			n += 1
	return n


## Valeur actuelle d'un produit détenu (euros).
static func valeur(e: EtatPartie, pid: String) -> float:
	var w := e.joueur
	match pid:
		"cc":
			return w.cc
		"livret":
			return w.livret
		"pel":
			return w.valeur_pel()
		"emprunt":
			return w.valeur_emprunts()
		"av":
			return w.valeur_av()
	return e.valeur_ligne(w, pid)


## État d'une carte du carnet (13 §2.2) : silhouette | nouveau | presente | detenu.
static func etat_carte(e: EtatPartie, pid: String) -> String:
	if not presente(e, pid):
		return "silhouette"
	if detenu(e, pid):
		return "detenu"
	if e.banque.get("nouveaux", []).has(pid):
		return "nouveau"
	return "presente"


static func marquer_vu(e: EtatPartie, pid: String) -> void:
	e.banque.get("nouveaux", []).erase(pid)


# =====================================================================
# Déclencheurs (12 §2.2), évalués chaque mois
# =====================================================================

static func _proposer(e: EtatPartie, id: String, echeance: int, historique := false) -> void:
	var b := e.banque
	if b["presentes"].has(id) or b["en_file"].has(id):
		return
	b["en_file"][id] = true
	e.file.append({"kind": "banquier", "id": id, "m": e.m, "prio": 1 if historique else 3, "source": "banque",
		"echeance": echeance, "historique": historique})


static func _vu(e: EtatPartie, id: String) -> bool:
	return e.banque["presentes"].has(id)


## Ancienneté (mois) du plus ancien produit à taux fixe détenu (PEL, emprunt d'État), -1 si aucun.
static func anciennete_taux_fixe(e: EtatPartie) -> int:
	var w := e.joueur
	var a := -1
	if not w.pel.is_empty():
		a = maxi(a, e.m - int(w.pel["ouvert_m"]))
	for t in w.emprunts:
		a = maxi(a, e.m - int(t["m"]))
	return a


## Une naissance est-elle au programme de la partie (déjà arrivée ou à venir) ?
static func naissance_prevue(e: EtatPartie) -> bool:
	for ev in e.calendrier:
		if ev["type"] == "naissance":
			return true
	return false


static func verifier(e: EtatPartie) -> void:
	var dd: Dictionary = donnees()["declencheurs"]
	var rel := e.m - e.m_depart
	var w := e.joueur
	var dep := float(e.depenses()["total"])
	_proposer(e, "D01", e.m_depart)
	if _vu(e, "D01"):
		var d2: Dictionary = dd["D02"]
		if w.livret >= float(d2["coussin_livret_mois"]) * dep or rel >= int(d2["echeance"]):
			_proposer(e, "D02", e.m_depart + int(d2["echeance"]))
	if _vu(e, "D02"):
		var d3: Dictionary = dd["D03"]
		if nb_detenus(e) >= int(d3["produits_detenus"]) or w.cc >= float(d3["cc_mois_salaire"]) * e.salaire_base or rel >= int(d3["echeance"]):
			_proposer(e, "D03", e.m_depart + int(d3["echeance"]))
	var mn := int(e.banque.get("naissance_m", -1))
	if mn >= 0:
		var d4: Dictionary = dd["D04"]
		if e.m >= mn + int(d4["apres_naissance_mois"]):
			_proposer(e, "D04", mn + int(d4["echeance_apres_naissance"]))
	if _vu(e, "D03"):
		var d5: Dictionary = dd["D05"]
		if anciennete_taux_fixe(e) >= int(d5["taux_fixe_depuis_mois"]) or rel >= int(d5["echeance"]):
			_proposer(e, "D05", e.m_depart + int(d5["echeance"]))
	# Les actions en dernier (12 §2.2) : après la SICAV et après l'assurance-vie si un enfant est né
	if _vu(e, "D05") and (_vu(e, "D04") or not naissance_prevue(e)):
		var d6: Dictionary = dd["D06"]
		var sicav_age := e.m - int(w.lignes["sicav"].get("depuis", e.m)) if w.lignes.has("sicav") else -1
		if sicav_age >= int(d6["sicav_depuis_mois"]) or rel >= int(d6["echeance"]):
			_proposer(e, "D06", e.m_depart + int(d6["echeance"]))
	# Dates historiques
	for id in donnees()["presentations"]:
		var h: String = donnees()["presentations"][id].get("historique", "")
		if h != "" and Dates.lire(h) == e.ab_courant():
			_proposer(e, id, e.m, true)


# =====================================================================
# Textes chiffrés (11 §4.0) et comparatif (12 R8, 13 §1.1)
# =====================================================================

static func taux_txt(x: float) -> String:
	var s := Format.nombre(x, 2)
	if s.ends_with(",00"):
		return s.left(s.length() - 3)
	if s.ends_with("0"):
		return s.left(s.length() - 1)
	return s


## Montant d'exemple rond : part × base, arrondi au pas (francs), borné (euros en sortie).
static func exemple(base_eur: float, part: float, pas_F: float, mini_F: float, maxi_F: float) -> float:
	var v := floorf(base_eur * Format.TAUX_EURO * part / pas_F) * pas_F
	return clampf(v, mini_F, maxi_F) / Format.TAUX_EURO


static func liquide(e: EtatPartie) -> float:
	return maxf(0.0, e.joueur.cc) + e.joueur.livret


static func coussin_mois(e: EtatPartie) -> float:
	return liquide(e) / maxf(1e-6, float(e.depenses()["total"]))


static func prenoms_enfants(e: EtatPartie) -> String:
	for ev in e.calendrier:
		if ev["type"] == "naissance" and ev.get("declenche", false):
			return " et ".join(PackedStringArray(ev.get("prenoms", [])))
	return "votre enfant"


static func jumeaux(e: EtatPartie) -> bool:
	return e.enfants >= 2


## Produit à taux fixe détenu (emprunt d'État d'abord, référence de la SICAV, puis PEL) : [nom, taux] ;
## sinon le Livret A.
static func produit_fixe(e: EtatPartie) -> Array:
	var w := e.joueur
	if not w.emprunts.is_empty():
		return ["emprunt d'État", float(w.emprunts[0]["taux"])]
	if not w.pel.is_empty():
		return ["PEL", float(w.pel["taux"])]
	return ["Livret A", Marche.taux_livret(e.ab_courant())]


static func variables(e: EtatPartie) -> Dictionary:
	var a := e.ab_courant()
	var y := Dates.annee(a)
	var mt := func(eur: float) -> String: return Format.entier(eur, a)
	var v := {}
	v["prenom"] = e.prenom()
	v["conjointe"] = str(donnees().get("conjointe", "Sylvie"))
	var cc_ex := exemple(maxf(0.0, e.joueur.cc), 1.0, 100.0, 100.0, 1e9)
	v["cc"] = mt.call(cc_ex)
	var tl := Marche.taux_livret(a)
	v["taux_livret"] = taux_txt(tl)
	v["interets_cc"] = mt.call(cc_ex * tl / 100.0)
	v["inflation"] = str(int(round(Marche.inflation(y))))
	v["plafond"] = mt.call(Marche.plafond_livret(a))
	# PEL : versement d'exemple d'environ 30 % de l'épargne du mois (300 à 1 000 F)
	var tp: Array = Produits.taux_pel(a)
	v["taux_pel"] = taux_txt(float(tp[0]))
	var mens := exemple(maxf(0.0, e.epargne_du_mois()), 0.3, 100.0, 300.0, 1000.0)
	v["v"] = mt.call(mens)
	var i := pow(1.0 + float(tp[0]) / 100.0, 1.0 / 12.0) - 1.0
	v["fv_pel"] = mt.call(mens * (pow(1.0 + i, 48) - 1.0) / i)
	# Emprunt d'État
	var te := Produits.taux_emprunt(y)
	v["taux_emprunt"] = taux_txt(te)
	var m_emp := exemple(liquide(e), 0.5, 1000.0, 1000.0, 10000.0)
	v["m_emprunt"] = mt.call(m_emp)
	v["coupon"] = mt.call(m_emp * te / 100.0)
	v["coupon_net"] = mt.call(m_emp * te / 100.0 * (1.0 - float(Produits.params()["emprunt"]["impot_coupons"]) / 100.0))
	v["annee10"] = str(y + 10)
	# Assurance-vie
	v["enfants"] = prenoms_enfants(e)
	v["e"] = mt.call(exemple(e.patrimoine(e.joueur), 1.0, 1000.0, 1000.0, 1e9))
	v["taux_av_an_dernier"] = taux_txt(Produits.taux_av(y - 1))
	v["taux_av"] = taux_txt(Produits.taux_av(y - 1))
	# SICAV
	var fixe := produit_fixe(e)
	v["produit_fixe"] = fixe[0]
	v["taux_fixe"] = taux_txt(float(fixe[1]))
	var m_sicav := exemple(liquide(e), 0.2, 1000.0, 1000.0, 10000.0)
	v["m_sicav"] = mt.call(m_sicav)
	v["frais_m"] = mt.call(m_sicav * 0.02)
	# Actions : un ordre d'exemple d'environ 10 % de l'épargne disponible (1 000 à 5 000 F)
	var m_act := exemple(liquide(e), 0.1, 1000.0, 1000.0, 5000.0)
	var courtage := Marche.frais_courtage(a, m_act)
	v["m_action"] = mt.call(m_act)
	v["courtage_m"] = mt.call(courtage)
	v["pct_courtage"] = Format.nombre(courtage / m_act * 100.0, 1) + Format.ESPACE + "%"
	# Saint-Gobain
	var m_sg := exemple(liquide(e), 0.2, 1000.0, 1000.0, 10000.0)
	v["m_sg"] = mt.call(m_sg)
	v["nb_sg"] = str(int(floor(m_sg * Format.TAUX_EURO / 310.0)))
	# PEL : le même taux partout (celui du plan détenu, sinon celui d'un plan ouvert ce mois-ci)
	v["taux_pel_detail"] = texte_taux_pel(e)
	# Héritage : un seul pot, comparé à la même somme passée par la succession
	var hr := heritage_chiffres()
	v["av_montant"] = mt.call(hr["av"])
	v["droits"] = mt.call(hr["droits"])
	v["succ_net"] = mt.call(hr["net"])
	var p04 := int(e.banque.get("presentes", {}).get("D04", -1))
	v["annee_d04"] = str(Dates.annee(e.ab_de(p04))) if p04 >= 0 else "1985"
	return v


## Héritage de tante Odette (euros) : { av, droits, net } — les 60 000 F de l'assurance-vie, et ce qu'il en
## serait resté par succession (abattement du neveu, puis droits au taux du neveu).
static func heritage_chiffres() -> Dictionary:
	var h: Dictionary = donnees()["heritage"]
	var av := Produits.f(float(h["av"]["montant_F"]))
	var cs: Dictionary = h["comparaison_succession"]
	var droits := maxf(0.0, av - Produits.f(float(cs["abattement_F"]))) * float(cs["droits_pct"]) / 100.0
	return {"av": av, "droits": droits, "net": av - droits}


## Taux du PEL, écrit de la même façon partout (11 §1.7.1) : « 6,30 % + prime d'État ≈ 8,25 % ».
## Celui du plan détenu s'il y en a un, sinon celui d'un plan ouvert à la date courante.
## court : « ≈ 8,25 % garanti » (carte du carnet). Le calcul des intérêts utilise le taux prime comprise.
static func texte_taux_pel(e: EtatPartie, court := false) -> String:
	var t := taux_pel_joueur(e)
	if court:
		return "≈ %s %% fixe" % taux_txt(t[0])
	return "%s %% + prime d'État ≈ %s %%" % [Format.nombre(t[1], 2), taux_txt(t[0])]


## [taux prime comprise, taux hors prime] du PEL détenu, sinon de l'offre du mois.
static func taux_pel_joueur(e: EtatPartie) -> Array:
	var w := e.joueur
	if not w.pel.is_empty():
		return [float(w.pel["taux"]), float(w.pel.get("taux_hp", Produits.taux_pel(e.ab_de(int(w.pel["ouvert_m"])))[1]))]
	var tp := Produits.taux_pel(e.ab_courant())
	return [float(tp[0]), float(tp[1])]


## Montant d'exemple proposé dans le formulaire d'ordre après « Ouvrir » (12 §2.3 : rien d'autre n'est prérempli).
static func montant_exemple(e: EtatPartie, pid: String) -> float:
	match pid:
		"livret":
			return exemple(maxf(0.0, e.joueur.cc), 1.0, 100.0, 100.0, 1e9)
		"pel":
			return exemple(liquide(e), 0.15, 100.0, 300.0, 5000.0)
		"emprunt":
			return exemple(liquide(e), 0.5, 1000.0, 1000.0, 10000.0)
		"av":
			return exemple(liquide(e), 0.3, 1000.0, 1000.0, 20000.0)
		"sicav", "saintgobain":
			return exemple(liquide(e), 0.2, 1000.0, 1000.0, 10000.0)
	return exemple(liquide(e), 0.1, 1000.0, 1000.0, 5000.0)


static func _remplir(t: String, v: Dictionary, id: String) -> String:
	# Le montant {m} dépend de la présentation
	var cle_m := {"D03": "m_emprunt", "D05": "m_sicav", "D06": "m_action", "D07": "m_sg"}
	if cle_m.has(id):
		t = t.replace("{m}", str(v[cle_m[id]]))
	return Format.gabarit(t, v)


## Nombre de mots d'un texte (chaque nombre compte pour un mot, comme le décompte de 11 §4.0).
static func nb_mots(t: String) -> int:
	var n := 0
	var propre := t.replace("’", " ").replace("'", " ").replace(Format.ESPACE, "")
	for mot in propre.split(" ", false):
		var garde := false
		for c in mot:
			if c.to_lower() != c.to_upper() or (c >= "0" and c <= "9"):
				garde = true
				break
		if garde:
			n += 1
	return n


## Produit de référence du comparatif : le premier détenu de la liste, sinon le premier déjà présenté.
static func produit_reference(e: EtatPartie, compare: Array) -> String:
	for pid in compare:
		if detenu(e, pid):
			return pid
	for pid in compare:
		if presente(e, pid):
			return pid
	return compare[0] if not compare.is_empty() else "cc"


static func notes(pid: String, annee: int) -> Dictionary:
	var info := info_produit(pid)
	var n: Dictionary = info.get("notes", {}).duplicate()
	if annee == 1984 and info.has("notes_1984"):
		n.merge(info["notes_1984"], true)
	return n


## Taux du moment d'un produit à taux (celui du joueur s'il le détient) ; -1 pour un produit sans taux.
static func taux_actuel(e: EtatPartie, pid: String) -> float:
	var a := e.ab_courant()
	var w := e.joueur
	match pid:
		"cc":
			return 0.0
		"livret":
			return Marche.taux_livret(a)
		"pel":
			return float(w.pel["taux"]) if not w.pel.is_empty() else float(Produits.taux_pel(a)[0])
		"emprunt":
			return float(w.emprunts[0]["taux"]) if not w.emprunts.is_empty() else Produits.taux_emprunt(Dates.annee(a))
		"av":
			return Produits.taux_av(Dates.annee(a) - 1)
	return -1.0


static func comparatif(e: EtatPartie, id: String) -> Dictionary:
	var pr: Dictionary = donnees()["presentations"][id]
	var pid: String = pr["produits"][0]
	var ref := produit_reference(e, pr.get("compare", ["livret"]))
	var y := Dates.annee(e.ab_courant())
	var v := variables(e)
	var np := notes(pid, y)
	var nr := notes(ref, y)
	var mp: Dictionary = info_produit(pid).get("mots", {})
	var mr: Dictionary = info_produit(ref).get("mots", {})
	var lignes := []
	var tp := taux_actuel(e, pid)
	var tr := taux_actuel(e, ref)
	for c in CRITERES:
		var k: String = c[0]
		var a := int(np.get(k, 0))
		var b := int(nr.get(k, 0))
		var sens := "pareil"
		if k == "fisc":
			sens = "moins d'impôt" if a > b else ("plus d'impôt" if a < b else "pareil")
		elif k == "rendement" and tp >= 0.0 and tr >= 0.0:
			# Deux taux connus : on compare les vrais chiffres (le PEL d'août 1984 rapporte moins que le Livret A)
			sens = "plus" if tp > tr + 0.001 else ("moins" if tp < tr - 0.001 else "pareil")
		elif a > b:
			sens = "plus"
		elif a < b:
			sens = "moins"
		lignes.append({"critere": c[1], "cle": k, "note": a, "mot": Format.gabarit(str(mp.get(k, "")), v),
			"note_ref": b, "mot_ref": Format.gabarit(str(mr.get(k, "")), v), "sens": sens})
	return {"produit": pid, "nom": str(info_produit(pid).get("court", pid)), "ref": ref, "ref_nom": str(info_produit(ref).get("court", ref)),
		"ref_detenu": detenu(e, ref) and ref != "cc", "lignes": lignes,
		"frais": str(info_produit(pid).get("frais", "")), "frais_ref": str(info_produit(ref).get("frais", ""))}


## Contenu d'une carte du banquier (présentation D01-D07 ou nouvelle D08), prêt à afficher.
static func contenu(e: EtatPartie, id: String) -> Dictionary:
	var a := e.ab_courant()
	var v := variables(e)
	var c := {"kind": "banquier", "id": id, "source": "banque", "ab": a, "date": Dates.texte(a)}
	if id == "D08":
		var h: Dictionary = donnees()["heritage"]["D08"]
		c["titre"] = h["titre"]
		c["texte"] = Format.gabarit(h["texte"], v)
		var tk := []
		for t in h["ticket"]:
			tk.append(Format.gabarit(str(t), v))
		c["ticket"] = tk
		c["heritage"] = true
		c["montant"] = heritage_chiffres()["av"]
		c["resume"] = Format.gabarit(str(h.get("resume", "")), v)
		c["choix"] = [{"id": "compris", "titre": "COMPRIS"}]
		c["mots"] = nb_mots(c["texte"])
		return c
	var pr: Dictionary = donnees()["presentations"][id]
	var cle_texte := "texte"
	if id == "D02" and e.joueur.livret < 3.0 * float(e.depenses()["total"]) and pr.has("texte_sans_coussin"):
		cle_texte = "texte_sans_coussin"
	c["texte"] = _remplir(pr[cle_texte], v, id)
	c["mots"] = nb_mots(c["texte"])
	c["note"] = str(donnees()["phrase_coussin"]) if pr.get("risque", false) and coussin_mois(e) < 3.0 else ""
	var tk2 := []
	for t in pr["ticket"]:
		tk2.append(_remplir(str(t), v, id))
	c["ticket"] = tk2
	c["ticket_succession"] = bool(pr.get("ticket_succession", false))
	if c["ticket_succession"]:
		c["ligne_enfant"] = Format.gabarit(pr["ligne_jumeaux"] if jumeaux(e) else pr["ligne_enfant"], v)
	c["plus"] = _remplir(str(pr.get("plus", "")), v, id)
	c["titre"] = pr["titre"]
	c["bouton"] = pr.get("bouton", "OUVRIR")
	c["produits"] = pr["produits"]
	c["couleur"] = couleur(pr["produits"][0])
	c["comparatif"] = comparatif(e, id)
	# « NOUVEAU PRODUIT · k sur 9 » : rang du produit dans la découverte
	c["rang"] = nb_decouverts(e) + pr["produits"].size()
	c["total"] = ordre_carnet().size()
	c["choix"] = [{"id": "ouvrir", "titre": pr.get("bouton", "OUVRIR")}, {"id": "plus_tard", "titre": "PAS MAINTENANT"}]
	return c


## Résolution d'une carte : la présentation est vue (le produit devient achetable), « Ouvrir » renvoie le produit.
static func resoudre(e: EtatPartie, id: String, choix_id: String) -> Dictionary:
	var b := e.banque
	b["presentes"][id] = e.m
	b["en_file"].erase(id)
	var r := {"choix": choix_id, "kind": "banquier", "id": id}
	if id == "D08":
		return r
	var produits: Array = donnees()["presentations"][id]["produits"]
	for pid in produits:
		if not b["nouveaux"].has(pid):
			b["nouveaux"].append(pid)
	if choix_id == "ouvrir":
		r["ouvrir"] = produits[0]
		r["montant"] = montant_exemple(e, produits[0])
	return r


# =====================================================================
# Messages de la banque (sans pause : 13 §5.1) et héritage scripté
# =====================================================================

static func _message(e: EtatPartie, notifs: Array, titre: String, texte: String, persistant: bool, montant := 0.0) -> void:
	var n := {"type": "message", "source": "banque", "cls": "neutre", "titre": titre, "texte": texte, "persistant": persistant}
	if absf(montant) > 0.004:
		n["montant"] = montant
		n["cls"] = "gain" if montant > 0.0 else "perte"
	notifs.append(n)
	if persistant:
		var liste: Array = e.banque["messages"]
		liste.append({"m": e.m, "titre": titre, "texte": texte})
		while liste.size() > 5:
			liste.pop_front()


static func messages_du_mois(e: EtatPartie, notifs: Array) -> void:
	var a := e.ab_courant()
	var d: Dictionary = donnees()["messages"]
	var v := variables(e)
	var w := e.joueur
	for b in d["baisses_livret"]:
		if Dates.lire(b["d"]) != a:
			continue
		var base := w.livret if w.livret >= Produits.f(1000.0) else Produits.f(10000.0)
		var vals := {"depuis": b["depuis"], "ancien": taux_txt(float(b["ancien"])), "nouveau": taux_txt(float(b["nouveau"])),
			"inflation": v["inflation"], "base": ("vos " if w.livret >= Produits.f(1000.0) else "") + Format.entier(base, a),
			"perte": Format.entier(base * (float(b["ancien"]) - float(b["nouveau"])) / 100.0, a)}
		var t := Format.gabarit(d["baisse_texte"], vals)
		if not w.pel.is_empty() or not w.emprunts.is_empty():
			t += Format.gabarit(d["baisse_fixe"], v)
		_message(e, notifs, d["baisse_titre"], t, false)
	if Dates.lire(d["plafond"]["d"]) == a:
		_message(e, notifs, d["plafond"]["titre"], d["plafond"]["texte"], false)
	var p04 := int(e.banque["presentes"].get("D04", -1))
	if p04 >= 0 and e.m == p04 + 1:
		_message(e, notifs, d["D04bis"]["titre"], d["D04bis"]["texte"], true)
	# Après le krach (mois suivant un événement « - » majeur), si le joueur a des placements en bourse
	for ev in e.per.get("evenements", []):
		if ev["type"] == "-" and Dates.lire(ev["d"]) + 1 == a and e.valeur_risquee(w) > Produits.EPS:
			var m0 := e.m - 2
			var v0 := 0.0
			for id in w.lignes:
				var p0 := e.cours(id, m0)
				v0 += w.qte(id) * (e.cours(id) if is_nan(p0) else p0)
			var x := (e.valeur_risquee(w) / v0 - 1.0) * 100.0 if v0 > 0.0 else 0.0
			var vals2 := v.duplicate()
			vals2["x"] = Format.nombre(absf(x), 0)
			_message(e, notifs, d["L17"]["titre"], Format.gabarit(d["L17"]["texte"], vals2), true)
	# Héritage de tante Odette (11 §1.7.4) : un seul versement, l'assurance-vie ; les témoins vivent la même vie
	var h: Dictionary = donnees()["heritage"]
	if Dates.lire(h["av"]["d"]) == a:
		e.recevoir_tous(heritage_chiffres()["av"])
		e.journaliser("Héritage de tante Odette (assurance-vie)")
		_proposer(e, "D08", e.m, true)
	# Versements automatiques (11 §8) : proposition VP-A, plafond du Livret A relevé
	Versements.messages_du_mois(e, notifs, v)


## Relevé de décembre (L21 et F02 fusionnés, 13 §3.4) : intérêts de l'année, frais de l'année, et depuis
## le début les frais payés plus les gains qu'ils auraient produits (jumeau sans frais, 11 §5.2 formule 7).
static func releve(e: EtatPartie) -> Dictionary:
	var a := e.ab_courant()
	var d: Dictionary = donnees()["messages"]
	var b := e.banque
	var interets := float(b.get("interets_annee", 0.0))
	var frais_annee := float(b.get("frais_annee", 0.0))
	var t := ""
	if interets > Produits.EPS:
		t = Format.gabarit(d["releve_interets"], {"interets": Format.entier(interets, a)})
	else:
		t = d["releve_sans_interets"]
	if frais_annee > Produits.EPS:
		t += Format.gabarit(d["releve_frais"], {"frais_annee": Format.entier(frais_annee, a),
			"frais_total": Format.entier(e.frais_payes(), a), "manque": Format.entier(e.manque_a_gagner(), a)})
	elif e.frais_payes() <= Produits.EPS:
		t += d["releve_sans_frais"]
	var vers: Dictionary = b.get("versements_annee", {})
	t += Versements.texte_releve(e, vers)
	var n := {"type": "releve", "source": "banque", "cls": "gain" if interets > Produits.EPS else "neutre",
		"titre": Format.gabarit(d["releve_titre"], {"annee": str(Dates.annee(a))}), "texte": t,
		"interets": interets, "frais_annee": frais_annee, "frais_total": e.frais_payes(), "manque": e.manque_a_gagner(),
		"versements_annee": vers.duplicate(true)}
	if interets > Produits.EPS:
		n["montant"] = interets
	b["interets_annee"] = 0.0
	b["frais_annee"] = 0.0
	b["versements_annee"] = {}
	return n


# =====================================================================
# Historique des pop-ups : titre et résumé d'une ligne d'une carte du banquier
# =====================================================================

static func titre_historique(c: Dictionary) -> String:
	if c.get("heritage", false):
		return "Tante Odette : l'assurance-vie"
	var pids: Array = c.get("produits", [])
	var noms := []
	for pid in pids:
		noms.append(str(info_produit(pid).get("court", pid)))
	return "M. Lefranc présente : " + ", ".join(PackedStringArray(noms))


static func resume_historique(c: Dictionary) -> String:
	if c.get("heritage", false):
		return str(c.get("resume", ""))
	var tk: Array = c.get("ticket", [])
	if c.get("ticket_succession", false) and tk.size() >= 5:
		return "%s %s par succession, %s par assurance-vie" % [str(tk[0]).trim_suffix(" :"), tk[2], tk[4]]
	return " → ".join(PackedStringArray(tk.map(func(x: Variant) -> String: return str(x))))


# =====================================================================
# Pédagogie des frais : les 3 piles sur 20 ans (13 §3.3, 11 §5.2-5.3)
# =====================================================================

## type : sicav | av | action. montant : somme investie (euros, frais compris). frais_achat : frais réellement
## payés à l'achat (courtage d'une action). a : date (devise et courtage). Renvoie les 3 valeurs à 20 ans.
static func piles(type: String, montant: float, a: int, frais_achat := -1.0) -> Dictionary:
	var fp: Dictionary = donnees()["frais_pedagogie"]
	var r := float(fp["r"])
	var n := int(fp["annees"])
	var p: Dictionary = fp.get(type, fp["sicav"])
	var sans := montant * pow(1.0 + r, n)
	var produit := 0.0
	var charge := 0.0
	var tout_de_suite := 0.0
	if type == "action":
		var fa := frais_achat if frais_achat >= 0.0 else Marche.frais_courtage(a, montant)
		tout_de_suite = fa
		var v2 := (montant - fa) * pow(1.0 + r, n)
		produit = v2 - Marche.frais_courtage(a, v2)
		var v3 := (montant - fa) * pow(1.0 + r - float(p["f3"]), n)
		charge = v3 - Marche.frais_courtage(a, v3)
	else:
		tout_de_suite = montant * float(p["e"])
		produit = montant * (1.0 - float(p["e"])) * pow(1.0 + r - float(p["f"]), n)
		charge = montant * (1.0 - float(p["e3"])) * pow(1.0 + r - float(p["f3"]), n)
	return {"type": type, "montant": montant, "sans": sans, "produit": produit, "charge": charge, "tout_de_suite": tout_de_suite,
		"cout_produit": sans - produit, "cout_charge": sans - charge, "nom3": p.get("nom3", "PLUS CHARGÉ"), "detail3": p.get("detail3", ""),
		"annees": n, "r": r}
