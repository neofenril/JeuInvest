extends SceneTree
## Recette du testeur, lot 03-foyer (moteur des dilemmes du foyer, P2). Logique pure, aucun fichier écrit.
## Mesures indépendantes de test_foyer / test_cadence : boucle de jeu propre au testeur qui OBSERVE chaque modale ouverte
## (au lieu de relire la liste tenue par Cadence), contrôle l'argent de chaque carte (joueur, Livret A, témoins),
## la politique de choix, la cadence (1 par mois, pas deux mois de suite, rien la veille d'une datée), les dates
## imposées contre la même graine cartes éteintes, C00, escargots, C07, humeur ; détail de 2 cartes pour un recalcul
## à la main ; refus d'un choix désactivé ; cartes éteintes : aucune notification d'humeur ni d'escargots.
## Lancer : Godot_console.exe --headless --path godot --script res://tests/recette/test_recette_foyer.gd

const F := 6.55957
const GRAINES := 40
const MOTIFS_IMPOSES := ["scripte", "historique", "marche"]

var _ok := 0
var _ko := 0


func _initialize() -> void:
	_parties()
	_detail_main()
	_refus_et_blocage()
	_eteint_sans_notif()
	StrategieTest.politique_cartes = "epargner"
	print("")
	print("=== test_recette_foyer : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _partie(g: int, cartes: bool) -> EtatPartie:
	var c := Donnees.config_demo(g)
	c["cartes"] = cartes
	var e := EtatPartie.new()
	e.demarrer(c)
	return e


func _ordre_creneaux() -> Dictionary:
	var o := {}
	var i := 0
	for cr: Dictionary in Foyer.donnees()["creneaux"]:
		o[str(cr["id"])] = i
		i += 1
	return o


## Dates imposées d'une partie (motifs scripte / historique / marche) : "m:id".
func _imposees(liste: Array) -> Array:
	var out := []
	for x: Dictionary in liste:
		if str(x.get("motif", "")) in MOTIFS_IMPOSES:
			out.append("%d:%s" % [int(x["m"]), str(x["id"])])
	return out


func _parties() -> void:
	var ordre := _ordre_creneaux()
	var ko := {"nb": "", "obs": "", "mois": "", "suite": "", "veille": "", "imposees": "", "argent": "", "politique": "",
		"miroir": "", "c00": "", "fachee": "", "escargots": "", "c07": "", "humeur": "", "histo": ""}
	var exceptions_suite := {}
	var repartition := {}
	var c00_par := {}
	var nb_cartes_tot := 0
	var nb_parties := 0
	var nb_c06a := 0
	var nb_c07a := 0
	var nb_c07b := 0
	var nb_humeur := 0
	var nb_carte_vie := 0
	for politique in ["depenser", "epargner", "alterner"]:
		repartition[politique] = {}
		c00_par[politique] = 0
		for g in range(1, GRAINES + 1):
			StrategieTest.politique_cartes = politique
			var e := _partie(g, true)
			var obs := []
			var fachee := false
			var c06a_m := -1
			var notif_esc := []
			var sal_dec := 0.0
			var sal_jan := 0.0
			var garde := 0
			while e.fin == "" and garde < 120:
				garde += 1
				if e.humeur_visible() == 2:
					fachee = true
				if not e.modale.is_empty():
					var kind := str(e.modale["kind"])
					obs.append({"m": e.m, "kind": kind})
					if kind == "carte":
						var c := e.contenu_modale()
						var id := str(c["id"])
						if id == "C00" and e.humeur_visible() != 2:
							ko["c00"] += "%s g%d C00 humeur %d ; " % [politique, g, e.humeur_visible()]
						# politique attendue, recalculée ici : depenser = plus cher payable, epargner = moins cher payable
						var payables := (c["choix"] as Array).filter(func(x: Dictionary) -> bool: return not x["desactive"])
						var pol: String = politique
						if pol == "alterner":
							pol = "depenser" if e.cartes_jouees().size() % 2 == 0 else "epargner"
						var attendu := ""
						if payables.size() == 1:
							attendu = str(payables[0]["id"])
						elif payables.size() == 2:
							var x0: Dictionary = payables[0]
							var x1: Dictionary = payables[1]
							if pol == "depenser":
								attendu = str(x0["id"]) if float(x0["montant"]) <= float(x1["montant"]) else str(x1["id"])
							else:
								attendu = str(x0["id"]) if float(x0["montant"]) > float(x1["montant"]) else str(x1["id"])
						var choix := StrategieTest.choix_modale(e, true)
						if choix != attendu:
							ko["politique"] += "%s g%d %s : %s au lieu de %s ; " % [politique, g, id, choix, attendu]
						var dispo0 := e.joueur.cc + e.joueur.livret
						var t0 := {}
						for k in e.temoins:
							t0[k] = e.temoins[k].cc
						var h_avant := e.humeur_visible()
						var nh0 := e.historique.size()
						var r := e.resoudre_modale(choix)
						if r.is_empty():
							ko["argent"] += "%s g%d %s refusé ; " % [politique, g, id]
							break
						var mt := float(r["montant"])
						var dispo1 := e.joueur.cc + e.joueur.livret
						if absf(dispo1 - (dispo0 + mt)) > 1e-6 or dispo1 < -0.005 and mt < 0.0:
							ko["argent"] += "%s g%d %s : %.2f -> %.2f (%.2f) ; " % [politique, g, id, dispo0 * F, dispo1 * F, mt * F]
						for k in e.temoins:
							var dt := float(e.temoins[k].cc) - float(t0[k])
							var att := 0.0 if c["type"] == "placement" else mt
							if absf(dt - att) > 1e-6:
								ko["miroir"] += "%s g%d %s %s ; " % [politique, g, id, k]
						# humeur : une notification « humeur » si et seulement si l'état visible change
						var nh := (r["notifs"] as Array).filter(func(n: Dictionary) -> bool: return n["type"] == "humeur")
						if (h_avant != e.humeur_visible()) != (nh.size() == 1) or nh.size() > 1 \
								or (nh.size() == 1 and int(nh[0]["humeur"]) != e.humeur_visible()) or int(r["humeur_avant"]) != h_avant:
							ko["humeur"] += "%s g%d %s ; " % [politique, g, id]
						nb_humeur += nh.size()
						# historique : 1 entrée carte (+ la bulle éventuelle), source maison, montant
						var nouv := e.historique.slice(nh0)
						var hc := nouv.filter(func(h: Dictionary) -> bool: return h["genre"] == "carte")
						if hc.size() != 1 or hc[0]["source"] != "maison" or absf(float(hc[0]["montant"]) - mt) > 1e-9:
							ko["histo"] += "%s g%d %s ; " % [politique, g, id]
						if id == "C06" and choix == "a":
							c06a_m = e.m
				# comme StrategieTest.aller_a : la stratégie résout la modale restante puis rééquilibre
				StrategieTest.jouer_mois(e, true)
				if not e.modale.is_empty():
					e.resolution_auto()
				if e.ab_courant() == Dates.lire("1987-12"):
					sal_dec = e.salaire_base
				var res := e.avancer()
				if e.ab_courant() == Dates.lire("1988-01"):
					sal_jan = e.salaire_base
				for n: Dictionary in res["notifs"]:
					if n.get("type", "") == "escargots":
						notif_esc.append({"m": e.m, "montant": float(n["montant"]), "persistant": n.get("persistant", false), "persistante": n.has("persistante")})
			nb_parties += 1
			var liste: Array = e.banque["interruptions_liste"]
			var nb_cartes := obs.filter(func(x: Dictionary) -> bool: return x["kind"] == "carte").size()
			nb_cartes_tot += nb_cartes
			repartition[politique][nb_cartes] = int(repartition[politique].get(nb_cartes, 0)) + 1
			if e.fin != "fin" or nb_cartes < 8 or nb_cartes > 10 or nb_cartes != int(e.banque["compteurs"]["cartes"]):
				ko["nb"] += "%s g%d : %d cartes (%s) ; " % [politique, g, nb_cartes, e.fin]
			# observé = liste de Cadence (mêmes mois, même nombre)
			var mo := obs.map(func(x: Dictionary) -> int: return int(x["m"]))
			var ml := liste.map(func(x: Dictionary) -> int: return int(x["m"]))
			if mo != ml:
				ko["obs"] += "%s g%d ; " % [politique, g]
			for i in range(1, mo.size()):
				var dm := int(mo[i]) - int(mo[i - 1])
				if dm <= 0:
					ko["mois"] += "%s g%d m%d ; " % [politique, g, mo[i]]
				if dm == 1:
					var cle := "%s:%s -> %s:%s" % [liste[i - 1]["kind"], liste[i - 1]["id"], liste[i]["kind"], liste[i]["id"]]
					exceptions_suite[cle] = int(exceptions_suite.get(cle, 0)) + 1
					# 04-L (lot_04 §13 A3, D2 b) : seule autre exception admise = une interruption « vie » le mois qui suit une carte
					if liste[i - 1]["kind"] == "carte" and liste[i]["kind"] == "vie":
						nb_carte_vie += 1
					elif not (liste[i - 1]["kind"] == "marche" and liste[i]["motif"] == "scripte"):
						ko["suite"] += "%s g%d %s ; " % [politique, g, cle]
			# rien (carte) la veille d'une interruption datée
			for x: Dictionary in liste:
				if x["kind"] != "carte":
					continue
				for y: Dictionary in liste:
					if y["datee"] and int(y["m"]) == int(x["m"]) + 1 and y["kind"] != "vie":
						ko["veille"] += "%s g%d %s m%d ; " % [politique, g, x["id"], int(x["m"])]
			# dates imposées : mêmes que la même graine cartes éteintes (joueur actif)
			var off := _partie(g, false)
			StrategieTest.aller_a(off, Dates.lire("1989-01"), true)
			var imp_on := _imposees(liste)
			var imp_off := _imposees(off.banque["interruptions_liste"])
			var d02 := int(e.banque["presentes"].get("D02", 999))
			if imp_on != imp_off or d02 > Dates.lire("1984-07") - e.mk.ab_debut:
				ko["imposees"] += "%s g%d %s / %s D02=%d ; " % [politique, g, str(imp_on), str(imp_off), d02]
			# C00
			var jouees := e.cartes_jouees()
			var n00 := 0
			for i in jouees.size():
				if jouees[i]["id"] == "C00":
					n00 += 1
					if jouees[i]["creneau"] == "S4" or (i > 0 and jouees[i - 1]["id"] == "C00"):
						ko["c00"] += "%s g%d %s ; " % [politique, g, str(jouees.map(func(x: Dictionary) -> String: return x["id"]))]
			if n00 > 2:
				ko["c00"] += "%s g%d %d C00 ; " % [politique, g, n00]
			if n00 > 0:
				c00_par[politique] = int(c00_par[politique]) + 1
			if politique == "epargner" and (not fachee or n00 == 0):
				ko["fachee"] += "g%d ; " % g
			# créneaux joués dans l'ordre des données
			for i in range(1, jouees.size()):
				if int(ordre[str(jouees[i]["creneau"])]) <= int(ordre[str(jouees[i - 1]["creneau"])]):
					ko["c00"] += "%s g%d ordre ; " % [politique, g]
			# escargots
			if c06a_m >= 0:
				nb_c06a += 1
				if notif_esc.size() != 1 or int(notif_esc[0]["m"]) != c06a_m + 9 or absf(float(notif_esc[0]["montant"]) * F - 800.0) > 0.005 \
						or not notif_esc[0]["persistant"] or notif_esc[0]["persistante"]:
					ko["escargots"] += "%s g%d %s ; " % [politique, g, str(notif_esc)]
			elif not notif_esc.is_empty():
				ko["escargots"] += "%s g%d sans prêt ; " % [politique, g]
			# C07 : salaire de janvier 1988 = décembre × indexation (× 1,04 si inscrit)
			var c07 := jouees.filter(func(x: Dictionary) -> bool: return x["id"] == "C07")
			var facteur := 1.0
			if not c07.is_empty() and c07[0]["choix"] == "a":
				facteur = 1.04
				nb_c07a += 1
			elif not c07.is_empty():
				nb_c07b += 1
			var att_jan := sal_dec * e.smn(1988) / e.smn(1987) * facteur
			if sal_dec <= 0.0 or absf(sal_jan - att_jan) > 1e-6:
				ko["c07"] += "%s g%d %.2f / %.2f ; " % [politique, g, sal_jan * F, att_jan * F]
	print("    RECETTE cartes : %d parties, %.2f cartes en moyenne ; par politique %s" % [nb_parties, float(nb_cartes_tot) / nb_parties, str(repartition)])
	print("    RECETTE C00 : graines avec C00 %s ; C06 prêtée %d fois ; C07 inscrit %d, refusé %d ; bulles d'humeur après carte %d" % [str(c00_par), nb_c06a, nb_c07a, nb_c07b, nb_humeur])
	print("    RECETTE deux mois de suite (toutes) : %s" % str(exceptions_suite))
	print("    RECETTE carte -> vie (exception D2 b) : %d cas sur %d parties" % [nb_carte_vie, nb_parties])
	verifier("FO2 : 8 à 10 cartes OBSERVÉES par partie (120 parties), = compteur « cartes », parties finies", ko["nb"] == "", ko["nb"].left(400))
	verifier("FO2 : modales observées = liste de Cadence (mêmes mois)", ko["obs"] == "", ko["obs"].left(300))
	verifier("FO2 : une interruption par mois au plus", ko["mois"] == "", ko["mois"].left(300))
	verifier("FO2 : jamais deux mois de suite, hors krach → panne et carte → vie (D2 b, 04-L)", ko["suite"] == "", ko["suite"].left(300))
	verifier("FO2 : aucune carte au mois qui précède une interruption datée (hors « vie » : exception carte → vie)", ko["veille"] == "", ko["veille"].left(300))
	verifier("FO2 : dates imposées (scripte, historique, marché) identiques à la même graine cartes éteintes ; PEL ≤ 07/1984", ko["imposees"] == "", ko["imposees"].left(400))
	verifier("FO3 : compte + Livret A = avant + montant, jamais sous 0 après une dépense de carte", ko["argent"] == "", ko["argent"].left(300))
	verifier("FO4 : politique de choix recalculée (depenser / epargner / alterner) = choix de StrategieTest", ko["politique"] == "", ko["politique"].left(300))
	verifier("FO4 : R-MIROIR au centime (conso et revenu recopiés, placement non)", ko["miroir"] == "", ko["miroir"].left(300))
	verifier("FO3 : C00 seulement fâchée, ≤ 2, jamais en S4 ni deux fois de suite ; créneaux dans l'ordre", ko["c00"] == "", ko["c00"].left(400))
	verifier("FO3 : epargner : Sylvie fâchée et C00 dans 40 graines sur 40", ko["fachee"] == "", ko["fachee"])
	verifier("FO5 : C06 prêtée → 1 notification escargots à + 9 mois, 800 F, persistant (sans « persistante ») ; sinon aucune", ko["escargots"] == "" and nb_c06a > 0, "%d prêts ; %s" % [nb_c06a, ko["escargots"].left(300)])
	verifier("FO4 : salaire de 01/1988 = 12/1987 × indexation, × 1,04 seulement si C07 « S'inscrire »", ko["c07"] == "" and nb_c07a > 0, "%d inscrits ; %s" % [nb_c07a, ko["c07"].left(300)])
	verifier("FO7 : bulle « humeur » dans le retour de resoudre_modale si et seulement si l'état visible change", ko["humeur"] == "", ko["humeur"].left(300))
	verifier("FO7 : une entrée d'historique « carte », source maison, montant du choix", ko["histo"] == "", ko["histo"].left(300))


## Détail des 2 premières cartes avec de l'argent (graine 3, depenser) pour un recalcul à la main dans le rapport.
func _detail_main() -> void:
	StrategieTest.politique_cartes = "depenser"
	var e := _partie(3, true)
	var vues := 0
	var garde := 0
	var ok := true
	while e.fin == "" and garde < 120 and vues < 2:
		garde += 1
		if e.modale.get("kind", "") == "carte":
			var c := e.contenu_modale()
			var choix := StrategieTest.choix_modale(e, true)
			var a := e.ab_courant()
			var cc0 := e.joueur.cc
			var lv0 := e.joueur.livret
			var tl0: float = e.temoins["livret"].cc
			var taux := Marche.taux_livret(a)
			var reste := e.m_fin - e.m
			var r := e.resoudre_modale(choix)
			var mt := float(r["montant"])
			if absf(mt) > 0.0:
				vues += 1
				var vf := -mt * pow(1.0 + taux / 100.0, float(reste) / 12.0)
				print("RECETTE detail %s %s choix=%s prix=%.2f cc=%.2f->%.2f livret=%.2f->%.2f temoin_livret_cc=%.2f->%.2f taux=%s mois_restants=%d vf=%.2f" % [
					Dates.texte(a), c["id"], choix, -mt * F, cc0 * F, e.joueur.cc * F, lv0 * F, e.joueur.livret * F, tl0 * F,
					float(e.temoins["livret"].cc) * F, str(taux), reste, vf * F])
				print("RECETTE detail consequence=%s" % r["consequence"])
				if not str(r["consequence"]).contains(Format.entier(vf, a)):
					ok = false
			continue
		StrategieTest.jouer_mois(e, true)
		if not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	verifier("Détail (graine 3, depenser) : 2 cartes avec de l'argent imprimées pour le recalcul à la main", vues == 2 and ok)


## Choix désactivé : contenu (manque, sous), refus sans effet ; carte à deux dépenses vidée en cours d'ouverture.
func _refus_et_blocage() -> void:
	StrategieTest.politique_cartes = "epargner"
	var e := _partie(7, true)
	var trouve := false
	var garde := 0
	while e.fin == "" and garde < 120:
		garde += 1
		if e.modale.get("kind", "") == "carte":
			var c := e.contenu_modale()
			var ch: Array = c["choix"]
			if float(ch[0]["montant"]) < 0.0 and float(ch[1]["montant"]) < 0.0:
				trouve = true
				break
			e.resoudre_modale(StrategieTest.choix_modale(e, true))
			continue
		StrategieTest.jouer_mois(e, true)
		if not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	if not trouve:
		verifier("Refus : carte à deux dépenses trouvée (graine 7)", false)
		return
	var b := EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(e.vers_dict())))
	var id := str(b.modale["id"])
	b.joueur.livret = 0.0
	b.joueur.cc = Produits.f(1000.0)
	var c := b.contenu_modale()
	var a := b.ab_courant()
	var x0: Dictionary = c["choix"][0]
	var manque_att := -float(x0["montant"]) - Produits.f(1000.0)
	var sous_att := Format.gabarit(str(Foyer.donnees()["manque"]), {"x": Format.entier(manque_att, a)})
	var r := b.resoudre_modale("a")
	verifier("Refus : choix « a » non payable : desactive, manque = prix − disponible, « %s », resoudre_modale → {} sans effet" % sous_att,
		x0["desactive"] and absf(float(x0["manque"]) - manque_att) < 1e-9 and str(x0["sous"]) == sous_att and r.is_empty()
		and not b.modale.is_empty() and absf(b.joueur.cc - Produits.f(1000.0)) < 1e-9 and absf(float(c["disponible"]) - Produits.f(1000.0)) < 1e-9,
		"%s : %s" % [id, str(x0)])
	# Carte ouverte, puis plus rien sur le compte ni le Livret (achat pendant la carte) : les deux choix désactivés
	b.joueur.cc = 0.0
	var r2 := b.resolution_auto()
	var r3 := b.avancer()
	print("RECETTE blocage %s : resolution_auto vide=%s modale_ouverte=%s avancer_bloque=%s" % [id, str(r2.is_empty()), str(not b.modale.is_empty()), str(int(r3["m"]) == b.m and not b.modale.is_empty())])
	verifier("INFO blocage (non exigé par le contrat) : carte à deux dépenses ouverte puis disponible = 0 : resolution_auto refuse et la partie ne peut plus avancer",
		true, "vide=%s ouverte=%s" % [str(r2.is_empty()), str(not b.modale.is_empty())])


## Cartes éteintes (défaut) : 40 graines × 2 stratégies : aucune modale carte, aucune notification humeur / escargots / historique carte.
func _eteint_sans_notif() -> void:
	var ko := ""
	for g in range(1, 41):
		for actif in [true, false]:
			var e := EtatPartie.new()
			e.demarrer(Donnees.config_demo(g))
			var garde := 0
			while e.fin == "" and garde < 120:
				garde += 1
				if e.modale.get("kind", "") == "carte":
					ko += "g%d carte ; " % g
				StrategieTest.jouer_mois(e, actif)
				if not e.modale.is_empty():
					e.resolution_auto()
				var r := e.avancer()
				for n: Dictionary in r["notifs"]:
					if n.get("type", "") in ["humeur", "escargots"]:
						ko += "g%d %s ; " % [g, n["type"]]
			if e.historique.any(func(h: Dictionary) -> bool: return h["genre"] == "carte" or h.get("type", "") in ["humeur", "escargots"]) \
					or e.cartes_actives() or not e.cartes_jouees().is_empty():
				ko += "g%d historique ; " % g
	verifier("FO1 : cartes éteintes (défaut), 40 graines × 2 stratégies : aucune carte, aucune bulle d'humeur ni escargots", ko == "", ko.left(300))
