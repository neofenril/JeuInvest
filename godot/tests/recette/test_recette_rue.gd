extends Node
## Recette du lot 05-L (testeur) : la rue et le krach, mesures INDEPENDANTES de celles du developpeur.
## Parties jouees par StrategieTest (passif, actif, « tout sur Peugeot »), rue + cartes + projets allumes, 40 graines :
## J1 / J2, rangs de Jean-Mi face a un joueur passif, regles des notifications, 5 passages cle ; patrimoine de Jean-Mi
## (voiture, dette comptee une fois) recalcule par differences avec Tonton Matelas ; 7 jours du Lundi noir ; 3 barres de
## « Le krach, un an apres » recalculees face au MOTEUR REEL (Livret A, cours, dividendes, achats) ; sauvegarde ; saut ;
## bilan. Aucun script du jeu modifie. Fichiers : user://recette_rue_<pid>.sav seulement.

const F := 6.55957
const ETOILES := ["V01", "V07", "V09", "V13", "V16"]

var ok := 0
var ko := 0


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		ok += 1
		print("OK  ", nom)
	else:
		ko += 1
		print("KO  ", nom, "  [", detail, "]")


func _ready() -> void:
	Partie.chemin_sauvegarde = "user://recette_rue_%d.sav" % OS.get_process_id()
	_t_eteint()
	_t_parties()
	_t_jeanmi()
	_t_krach_jours()
	_t_barres()
	_t_sauvegarde()
	await _t_saut()
	_t_bilan()
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	Sauvegarde.effacer(_chemin())
	StrategieTest.strategie = ""
	print("=== recette rue : %d OK, %d KO ===" % [ok, ko])
	get_tree().quit(1 if ko > 0 else 0)


func _chemin() -> String:
	return "user://recette_rue_t_%d.sav" % OS.get_process_id()


func _cfg(g: int, rue := true) -> Dictionary:
	var c := Donnees.config_demo(g)
	c["rue"] = rue
	c["cartes"] = true
	c["projets"] = true
	return c


func _reglages(g: int, mode: String) -> void:
	StrategieTest.strategie = "peugeot" if mode == "peugeot" else ""
	StrategieTest.politique_cartes = ["epargner", "depenser", "alterner"][g % 3]
	StrategieTest.politique_projets = ["moins_cher", "milieu", "plus_cher"][g % 3]


## Une partie complete ; suivi : un element par mois.
func _jouer(g: int, mode: String, rue := true) -> Dictionary:
	_reglages(g, mode)
	var actif := mode != "passif"
	var e := EtatPartie.new()
	var res := e.demarrer(_cfg(g, rue))
	var suivi: Array = [_ligne(e, res)]
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		StrategieTest.jouer_mois(e, actif)
		while not e.modale.is_empty():
			e.resolution_auto()
		res = e.avancer()
		suivi.append(_ligne(e, res))
	StrategieTest.strategie = ""
	return {"e": e, "suivi": suivi}


func _ligne(e: EtatPartie, res: Dictionary) -> Dictionary:
	var pat := {}
	var rang := {}
	for l: Dictionary in e.classement_rue():
		pat[l["id"]] = float(l["patrimoine"])
		rang[l["id"]] = int(l["rang"])
	return {"ab": e.ab_courant(), "pause": not (res.get("modale", {}) as Dictionary).is_empty(),
		"notifs": (res.get("notifs", []) as Array).duplicate(true), "pat": pat, "rang": rang}


func _mm(ab: int) -> String:
	return "%02d/%d" % [Dates.mois(ab), Dates.annee(ab)]


# ---------------------------------------------------------------------
# Rue eteinte par defaut
# ---------------------------------------------------------------------

func _t_eteint() -> void:
	verifier("defaut : rue.json > actif = false ; Donnees.config_demo ne contient pas « rue »",
		Donnees.charger("rue")["actif"] == false and not Donnees.config_demo(7).has("rue"))
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(7))
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.aller_a(e, Dates.lire("1989-01"), true)
	var patr := e.patrimoine(e.joueur) * F
	print("RECETTE eteint graine7 actif patrimoine=%.2f frais=%.2f interruptions=%d rue_active=%s" % [patr, e.frais_payes() * F, int(e.banque["interruptions"]), str(e.rue_active())])
	verifier("rue eteinte : reference graine 7 actif 172 139,25 F / 870,08 F (D5) / 11 interruptions ; accesseurs vides",
		absf(patr - 172139.25) < 0.005 and absf(e.frais_payes() * F - 870.08) < 0.005 and int(e.banque["interruptions"]) == 11
		and not e.rue_active() and e.classement_rue().is_empty() and e.jeanmi_resume().is_empty())
	# Allumer la rue ne change pas l'argent du joueur (passif, 12 graines) : la rue ne touche que des notifications et une modale a lire
	var ident := true
	var det := ""
	for g in range(1, 13):
		var a := _jouer(g, "passif", false)
		var b := _jouer(g, "passif", true)
		var pa := (a["e"] as EtatPartie).patrimoine((a["e"] as EtatPartie).joueur)
		var pb := (b["e"] as EtatPartie).patrimoine((b["e"] as EtatPartie).joueur)
		if absf(pa - pb) > 1e-6:
			ident = false
			det += "g%d %.2f / %.2f ; " % [g, pa * F, pb * F]
	verifier("rue allumee ou eteinte : meme patrimoine final du joueur passif (12 graines)", ident, det)


# ---------------------------------------------------------------------
# J1, J2, rangs, notifications (3 modes x 40 graines)
# ---------------------------------------------------------------------

func _t_parties() -> void:
	var j1_min := 1e18
	var j1_mois := ""
	var j1_ok := true
	var j2_ok := true
	var j2_ecart_min := 1e18
	var dernier_ok := true
	var mat_ok := true
	var fin_ok := true
	var voisin_ok := true
	var mois_ok := true
	var pause_ok := true
	var rang_ok := true
	var kio_ok := true
	var etoiles_ok := true
	var gaz_ok := true
	var det := ""
	var pass_premier := {}   # passif : premier mois ou Jean-Mi est devant le joueur
	var pass_retour := {}    # passif : premier mois apres 09/1987 ou le joueur est de nouveau devant
	var rang_notifs_passif := {}
	var abandons := 0
	var nb := 0
	var kio_total := 0
	var kio_absents := 0
	for mode in ["passif", "actif", "peugeot"]:
		for g in range(1, 41):
			var p := _jouer(g, mode)
			nb += 1
			var e: EtatPartie = p["e"]
			var suivi: Array = p["suivi"]
			if e.fin != "fin":
				fin_ok = false
			var d_voisin := -99
			var d_rang := -99
			var vus := {}
			for x: Dictionary in suivi:
				var ab := int(x["ab"])
				if ab >= Dates.lire("1987-03") and ab <= Dates.lire("1987-09"):
					var marge := float(x["pat"]["jeanmi"]) - float(x["pat"]["livret"])   # classement_rue : deja en francs
					if marge < j1_min:
						j1_min = marge
						j1_mois = _mm(ab)
					if marge <= 0.0:
						j1_ok = false
						det += "J1 %s g%d %s ; " % [mode, g, _mm(ab)]
				if ab == Dates.lire("1988-12"):
					var jm := float(x["pat"]["jeanmi"])
					var ta := float(x["pat"]["livret"])
					j2_ecart_min = minf(j2_ecart_min, 1.0 - jm / ta)
					if jm > 0.9 * ta:
						j2_ok = false
						det += "J2 %s g%d ; " % [mode, g]
					if int(x["rang"]["jeanmi"]) != 4:
						dernier_ok = false
						det += "dernier %s g%d rang=%d ; " % [mode, g, int(x["rang"]["jeanmi"])]
					if float(x["pat"]["matelas"]) >= ta:
						mat_ok = false
				var n_rue := 0
				for n: Dictionary in x["notifs"]:
					var t := str(n.get("type", ""))
					if not t in ["voisin", "rang", "kiosque"]:
						continue
					n_rue += 1
					if bool(x["pause"]):
						pause_ok = false
						det += "pause %s g%d %s ; " % [mode, g, _mm(ab)]
					if t == "voisin":
						if ab - d_voisin < 2:
							voisin_ok = false
							det += "voisin %s g%d %s ; " % [mode, g, _mm(ab)]
						d_voisin = ab
						vus[str(n["id"])] = ab
					elif t == "rang":
						if ab - d_rang < 6 or ab < Dates.lire("1986-10"):
							rang_ok = false
							det += "rang %s g%d %s ; " % [mode, g, _mm(ab)]
						d_rang = ab
						if mode == "passif":
							rang_notifs_passif[g] = (rang_notifs_passif.get(g, []) as Array) + [_mm(ab) + (" perte" if n["cls"] == "perte" else " gain")]
					else:
						var kid := str(n["id"])
						if vus.has("K_" + kid):
							kio_ok = false
						vus["K_" + kid] = ab
				if n_rue > 1:
					mois_ok = false
					det += "mois %s g%d %s ; " % [mode, g, _mm(ab)]
			# kiosque : chaque titre au plus une fois, a sa date ou 1 mois apres, sinon absent (compte)
			for k in Donnees.charger("rue")["kiosque"]:
				kio_total += 1
				var mk := Dates.lire(str(k["mois"]))
				if vus.has("K_" + str(k["id"])):
					var dk: int = int(vus["K_" + str(k["id"])]) - mk
					if dk < 0 or dk > 1:
						kio_ok = false
				else:
					kio_absents += 1
			# les 5 passages cle dans l'historique, source rue, genre voisin
			var vus_h := {}
			for h: Dictionary in e.historique:
				if h["genre"] == "voisin":
					if h["source"] != "rue":
						etoiles_ok = false
					vus_h[str((h["contenu"] as Dictionary).get("id", ""))] = true
			for id in ETOILES:
				if not vus_h.has(id):
					etoiles_ok = false
					det += "etoile %s %s g%d ; " % [id, mode, g]
			abandons += (e.quartier["abandonnes"] as Array).size()
			for id in ETOILES:
				if (e.quartier["abandonnes"] as Array).has(id):
					etoiles_ok = false
			var gz := e.historique.filter(func(h: Dictionary) -> bool: return h["type"] == "gazette" and h["genre"] == "gazette" and h["source"] == "media")
			if gz.size() != 1 or int(gz[0]["m"]) != Dates.lire("1988-10") - e.mk.ab_debut:
				gaz_ok = false
				det += "gazette %s g%d ; " % [mode, g]
			# Jean-Mi face au joueur passif
			if mode == "passif":
				var prem := ""
				var ret := ""
				for x: Dictionary in suivi:
					var ab := int(x["ab"])
					if prem == "" and float(x["pat"]["jeanmi"]) > float(x["pat"]["vous"]) + 1e-9:
						prem = _mm(ab)
						pass_premier[prem] = int(pass_premier.get(prem, 0)) + 1
					if prem != "" and ret == "" and ab > Dates.lire("1987-09") and float(x["pat"]["vous"]) >= float(x["pat"]["jeanmi"]):
						ret = _mm(ab)
						pass_retour[ret] = int(pass_retour.get(ret, 0)) + 1
				if prem == "":
					pass_premier["jamais"] = int(pass_premier.get("jamais", 0)) + 1
				if ret == "":
					pass_retour["jamais"] = int(pass_retour.get("jamais", 0)) + 1
	print("RECETTE J1 marge_min=%.0f F mois=%s ; J2 ecart_min=%.1f %% (%d parties)" % [j1_min, j1_mois, 100.0 * j2_ecart_min, nb])
	print("RECETTE passif : Jean-Mi passe devant le joueur (premier mois) ", pass_premier, " ; le joueur repasse devant apres 09/1987 ", pass_retour)
	print("RECETTE passif : notifications de rang (graines 1-6) ", [rang_notifs_passif.get(1), rang_notifs_passif.get(2), rang_notifs_passif.get(3), rang_notifs_passif.get(4), rang_notifs_passif.get(5), rang_notifs_passif.get(6)])
	print("RECETTE passages abandonnes moyenne=%.2f par partie ; titres de kiosque absents %d sur %d" % [float(abandons) / nb, kio_absents, kio_total])
	if det != "":
		print("    ", det.left(1200))
	verifier("parties finies (40 graines x 3 strategies)", fin_ok)
	verifier("J1 : Jean-Mi devant Tata chaque mois de 03 a 09/1987", j1_ok)
	verifier("J2 : en 12/1988 Jean-Mi derriere Tata d'au moins 10 %, dernier (rang 4), Tonton Matelas derriere Tata", j2_ok and dernier_ok and mat_ok)
	verifier("notifications : 1 voisin tous les 2 mois, 1 notification rue ou kiosque par mois", voisin_ok and mois_ok)
	verifier("notifications : aucune un mois qui ouvre une interruption avec pause", pause_ok)
	verifier("notifications : rang tous les 6 mois au plus, pas avant 10/1986 ; kiosque a sa date ou +1 mois, une fois", rang_ok and kio_ok)
	verifier("5 passages cle (V01 V07 V09 V13 V16) toujours dans l'historique (genre voisin, source rue), jamais abandonnes", etoiles_ok)
	verifier("« un an apres » : une fois, 10/1988, genre gazette source media, 120 parties", gaz_ok)
	# Jean-Mi face au joueur passif : la phrase attendue du plan
	verifier("joueur passif : Jean-Mi est devant le joueur au plus tard en 10/1986 (40 graines ; avant : le joueur depensier est deja derriere le miroir)", not pass_premier.has("jamais") and (pass_premier.keys().size() == pass_premier.keys().filter(func(k: String) -> bool: return k in ["01/1986", "10/1986"]).size()), str(pass_premier))
	verifier("joueur passif : le joueur repasse devant Jean-Mi au plus tard en 10/1987 (40 graines)", pass_retour.size() == 1 and pass_retour.has("10/1987"), str(pass_retour))


# ---------------------------------------------------------------------
# Patrimoine de Jean-Mi : voiture comprise, dette comptee une seule fois (differences avec Tonton Matelas)
# ---------------------------------------------------------------------

func _t_jeanmi() -> void:
	var ok_achat := true
	var ok_liq := true
	var ok_dette := true
	var ok_vente := true
	var ok_formule := true
	var det := ""
	var n := 0
	for g in range(1, 41):
		_reglages(g, "passif")
		var e := EtatPartie.new()
		e.demarrer(_cfg(g))
		var ecart := {}   # ab -> (Jean-Mi - Matelas) en F
		var etat := {}    # ab -> copie de l'etat de Jean-Mi
		var cours := {}
		var garde := 0
		while e.fin == "" and garde < 200:
			garde += 1
			StrategieTest.jouer_mois(e, false)
			while not e.modale.is_empty():
				e.resolution_auto()
			e.avancer()
			var ab := e.ab_courant()
			ecart[ab] = (e.patrimoine_jeanmi() - e.patrimoine(e.temoins["matelas"])) * F
			etat[ab] = e.jeanmi.duplicate(true)
			cours[ab] = e.cours("peugeot")
			var w: Portefeuille = e.temoins["jeanmi"]
			# patrimoine = compte + apport garde + equite + voiture - credit - dette, une seule fois la dette
			var attendu := (w.cc + Projets.apport(e, w)) * F + float(e.jeanmi["equite"]) + float(e.jeanmi["voiture"]) - float(e.jeanmi["credit"]) - float(e.jeanmi["dette"])
			if absf(attendu - e.patrimoine_jeanmi() * F) > 0.01 or float(e.jeanmi["equite"]) < -1e-6:
				ok_formule = false
				det += "formule g%d %s ; " % [g, _mm(ab)]
		n += 1
		var a04 := Dates.lire("1987-04")
		var a09 := Dates.lire("1987-09")
		var a10 := Dates.lire("1987-10")
		var a11 := Dates.lire("1987-11")
		# 04/1987 : la voiture est neutre a l'achat : la difference ne bouge que du gain - report du mois
		var pos03: float = float(etat[Dates.lire("1987-03")]["position"])
		var gain04 := pos03 * (float(cours[a04]) / float(cours[Dates.lire("1987-03")]) - 1.0) - pos03 * 0.007
		var d04 := float(ecart[a04]) - float(ecart[Dates.lire("1987-03")])
		if absf(d04 - gain04) > 1.0:
			ok_achat = false
			det += "achat g%d : %.2f au lieu de %.2f ; " % [g, d04, gain04]
		# 10/1987 : liquidation : perte = position x (1 - c10/c09) ; decote voiture ; interets du credit ; rien d'autre
		var pos09: float = float(etat[a09]["position"])
		var perte := pos09 * (1.0 - float(cours[a10]) / float(cours[a09]))
		var decote := float(etat[a09]["voiture"]) - float(etat[a10]["voiture"])
		var interets := float(etat[a09]["credit"]) * 0.12 / 12.0
		var d10 := float(ecart[a10]) - float(ecart[a09])
		var attendu10 := -perte - decote - interets
		if absf(d10 - attendu10) > 1.0:
			ok_liq = false
			det += "liquidation g%d : %.2f au lieu de %.2f ; " % [g, d10, attendu10]
		# 11/1987 : plus de position, dette = perte - couverture, comptee une fois
		var dette_att := maxf(0.0, perte - float(etat[a09]["equite"]))
		if absf(float(etat[a10]["dette"]) - dette_att) > 1.0 or absf(float(etat[a11]["dette"]) - dette_att) > 1.0:
			ok_dette = false
			det += "dette g%d : %.2f au lieu de %.2f ; " % [g, float(etat[a10]["dette"]), dette_att]
		if float(etat[a10]["equite"]) != 0.0 or float(etat[a10]["position"]) != 0.0:
			ok_dette = false
		# 12/1988 : voiture vendue, credit solde
		var a_fin := Dates.lire("1988-12")
		if float(etat[a_fin]["voiture"]) != 0.0 or float(etat[a_fin]["credit"]) > 0.5 or str(etat[a_fin]["voiture_etat"]) != "vendue":
			ok_vente = false
			det += "vente g%d ; " % g
	print("RECETTE jeanmi %d graines : identites de patrimoine verifiees" % n)
	verifier("patrimoine de Jean-Mi = compte + apport + equite + voiture - credit - dette, equite jamais negative (40 graines, chaque mois)", ok_formule, det.left(300))
	verifier("04/1987 : achat de la Porsche neutre pour le patrimoine (difference avec Matelas = gain - report)", ok_achat, det.left(300))
	verifier("10/1987 : la baisse du patrimoine de Jean-Mi = perte + decote de la voiture + interets du credit (dette comptee UNE fois)", ok_liq, det.left(300))
	verifier("11/1987 : dette = perte - couverture, equite et position a zero", ok_dette, det.left(300))
	verifier("12/1988 : voiture vendue, credit solde", ok_vente, det.left(300))


# ---------------------------------------------------------------------
# Lundi noir : 7 jours
# ---------------------------------------------------------------------

func _t_krach_jours() -> void:
	var attendu_i := [1240.0, 1119.7, 1050.0, 1085.0, 1045.0, 1020.0, 990.0]
	var attendu_v := [0.0, -9.7, -6.2, 3.3, -3.7, -2.4, -2.9]
	for rue in [true, false]:
		_reglages(7, "passif")
		var e := EtatPartie.new()
		e.demarrer(_cfg(7, rue))
		var vus := 0
		var autres := 0
		var jours: Array = []
		var garde := 0
		while e.fin == "" and garde < 200:
			garde += 1
			StrategieTest.jouer_mois(e, false)   # resout les modales deja ouvertes : relever AVANT
			e.avancer()
			if not e.modale.is_empty():
				var c := e.contenu_modale()
				if c.has("jours"):
					if str(c["kind"]) == "marche" and str(e.modale["id"]) == "p1e6":
						vus += 1
						jours = c["jours"]
					else:
						autres += 1
		if rue:
			var ok_j := jours.size() == 7 and vus == 1 and autres == 0
			var det := ""
			for i in jours.size():
				if absf(float(jours[i]["indice"]) - attendu_i[i]) > 1e-6:
					ok_j = false
				var var_att: float = attendu_v[i]
				# recalcul : variation = indice / veille - 1, au dixieme
				if i > 0:
					var_att = snappedf((attendu_i[i] / attendu_i[i - 1] - 1.0) * 100.0, 0.1)
				if absf(float(jours[i]["variation"]) - var_att) > 0.0001 or absf(var_att - attendu_v[i]) > 0.0001:
					ok_j = false
					det += "%d : %s / %s ; " % [i, str(jours[i]["variation"]), str(var_att)]
			var noms := ["vendredi 16 octobre", "lundi 19 octobre", "mardi 20 octobre", "mercredi 21 octobre", "jeudi 22 octobre", "vendredi 23 octobre", "lundi 26 octobre"]
			for i in jours.size():
				if str(jours[i]["jour"]) != noms[i] or str(jours[i]["certitude"]) != ("A" if i < 2 else "C"):
					ok_j = false
			verifier("Lundi noir : 7 jours (1 240 / 1 119,7 / 1 050 / 1 085 / 1 045 / 1 020 / 990), variations -9,7 -6,2 +3,3 -3,7 -2,4 -2,9 recalculees, certitudes A A C C C C C ; aucune autre modale ne porte « jours »", ok_j, det)
		else:
			verifier("rue eteinte : pas de « jours » dans la modale du krach", vus == 0 and autres == 0)


# ---------------------------------------------------------------------
# « Le krach, un an apres » : 3 barres recalculees face au moteur reel
# ---------------------------------------------------------------------

## Jusqu'a la modale « un an apres ». variante : "rien" | "vendre" | "renforcer". Portefeuille fabrique en 09/1987 si avec_lignes.
func _jusqu_gazette(g: int, variante: String, avec_lignes: bool, injecte_f := 0.0) -> Dictionary:
	_reglages(g, "passif")
	var e := EtatPartie.new()
	e.demarrer(_cfg(g))
	var garde := 0
	var out := {"div0": 0.0}
	var fait := false
	while e.fin == "" and garde < 200:
		garde += 1
		if avec_lignes and not fait and e.ab_courant() == Dates.lire("1987-09") and e.modale.is_empty():
			e.joueur.cc += 40000.0 / F
			e.acheter(e.joueur, "sicav", 9000.0 / F)
			e.acheter(e.joueur, "elf", 6000.0 / F)
			e.acheter(e.joueur, "peugeot", 4000.0 / F)
			fait = true
		while not e.modale.is_empty():
			var k := str(e.modale.get("kind", ""))
			if k == "gazette":
				var val := 0.0
				for id in e.joueur.lignes:
					val += e.valeur_ligne(e.joueur, id)
				out["gazette"] = e.contenu_modale()
				out["lignes_val"] = val
				out["div"] = e.dividendes_recus() - float(out["div0"])
				out["livret"] = e.joueur.livret + e.joueur.livret_int
				out["sicav"] = e.cours(e._fonds_indiciel())
				out["e"] = e
				return out
			if k == "marche" and str(e.modale["id"]) == "p1e6":
				var inst := e.instantane_krach()
				out["inst"] = inst
				out["div0"] = e.dividendes_recus()
				out["sicav_krach"] = e.cours(e._fonds_indiciel())
				var cc0 := e.joueur.cc
				var choix: String = variante if (inst["lignes"] as Array).size() > 0 and not bool(inst["exemple"]) else "ecart"
				e.resoudre_modale(choix)
				if variante == "vendre" and avec_lignes:
					out["recu"] = e.joueur.cc - cc0
					e.deposer_livret(e.joueur, float(out["recu"]))
				elif variante == "renforcer" and avec_lignes:
					var tot := Krach.base(inst)
					for l in inst["lignes"]:
						e.acheter(e.joueur, str(l["id"]), float(inst["montant_renforcer"]) * float(l["qte"]) * float(l["cours"]) / tot)
				if injecte_f > 0.0:
					e.joueur.livret += injecte_f / F
			else:
				e.resolution_auto()
		StrategieTest.jouer_mois(e, false)
		e.avancer()
	return out


func _t_barres() -> void:
	# Cas 1 : exemple (aucune ligne) : 10 000 F de SICAV, 3 barres
	var a := _jusqu_gazette(7, "rien", false)
	var b := _jusqu_gazette(7, "rien", false, 10000.0)
	var gz: Dictionary = a["gazette"]
	var bar := {}
	for br: Dictionary in gz["barres"]:
		bar[br["id"]] = float(br["valeur"]) * F
	var vl: float = float(a["sicav"]) / float(a["sicav_krach"])
	var rien := 10000.0 * vl
	var renforce := rien + 5000.0 * 0.98 * vl
	# Livret A : 12 fins de mois (10/1987 a 09/1988), interets credites en decembre (_fin_de_mois du moteur)
	var cap := 10000.0
	var acq := 0.0
	for mm in range(Dates.lire("1987-10"), Dates.lire("1988-10")):
		acq += cap * Marche.taux_livret(mm) / 100.0 / 12.0
		if Dates.mois(mm) == 12:
			cap += acq
			acq = 0.0
	var vendu := cap + acq
	var reel_livret := (float(b["livret"]) - float(a["livret"])) * F
	print("RECETTE exemple barres moteur vendu=%.2f rien=%.2f renforce=%.2f ; attendu vendu=%.2f (Livret A reel du moteur %.2f) rien=%.2f renforce=%.2f" % [bar["vendu"], bar["rien"], bar["renforce"], vendu, reel_livret, rien, renforce])
	verifier("exemple : mention non vide, 3 barres dans l'ordre, aucune choisie, base 10 000 F",
		str(gz["mention"]) != "" and (gz["barres"] as Array).size() == 3 and gz["barres"][0]["id"] == "vendu" and gz["barres"][1]["id"] == "rien" and gz["barres"][2]["id"] == "renforce"
		and not (gz["barres"][0]["choisi"] or gz["barres"][1]["choisi"] or gz["barres"][2]["choisi"]) and absf(float(gz["base"]) * F - 10000.0) < 0.01)
	verifier("exemple : « Rien fait » = 10 000 F x valeur liquidative 10/1988 / 10/1987 (recalcul independant, au centime)", absf(bar["rien"] - rien) < 0.01, "%.2f / %.2f" % [bar["rien"], rien])
	verifier("exemple : « Renforce » = Rien fait + 5 000 F net de 2 % de frais d'entree (recalcul independant, au centime)", absf(bar["renforce"] - renforce) < 0.01, "%.2f / %.2f" % [bar["renforce"], renforce])
	verifier("exemple : le Livret A du moteur donne bien le meme resultat que le recalcul 12 mois (controle du test)", absf(reel_livret - vendu) < 0.05, "%.2f / %.2f" % [reel_livret, vendu])
	verifier("exemple : « Tout vendu » = 10 000 F placees au Livret A jusqu'en 10/1988 comme le moteur (12 fins de mois)", absf(bar["vendu"] - vendu) < 0.05, "barre %.2f F, moteur %.2f F, ecart %.2f F" % [bar["vendu"], reel_livret, bar["vendu"] - reel_livret])
	# Cas 2 : portefeuille fabrique (SICAV + Elf + Peugeot), trois choix reels, comparaison a l'etat reel du moteur
	for g in [3, 12]:
		var r := _jusqu_gazette(g, "rien", true)
		var v := _jusqu_gazette(g, "vendre", true)
		var n := _jusqu_gazette(g, "renforcer", true)
		var bb := {}
		for br: Dictionary in (r["gazette"]["barres"] as Array):
			bb[br["id"]] = float(br["valeur"]) * F
		var reel_rien := (float(r["lignes_val"]) + float(r["div"])) * F
		var reel_renf := (float(n["lignes_val"]) + float(n["div"])) * F
		var reel_vendu := (float(v["livret"]) - float(r["livret"])) * F
		verifier("g%d portefeuille (3 lignes) : « Rien fait » = valeur des lignes en 10/1988 + dividendes nets recus (etat reel du moteur, au centime)" % g, absf(bb["rien"] - reel_rien) < 0.01, "%.2f / %.2f" % [bb["rien"], reel_rien])
		verifier("g%d portefeuille : « Renforce » = etat reel apres achats proportionnels de « Renforcer » (au centime)" % g, absf(bb["renforce"] - reel_renf) < 0.01, "%.2f / %.2f" % [bb["renforce"], reel_renf])
		verifier("g%d portefeuille : « Tout vendu » = produit de la vente totale du moteur place au Livret A (etat reel, 1 F pres)" % g, absf(bb["vendu"] - reel_vendu) < 1.0, "barre %.2f F, moteur %.2f F, ecart %.2f F" % [bb["vendu"], reel_vendu, bb["vendu"] - reel_vendu])
		var choisi := {}
		for xx in [["rien", r], ["vendre", v], ["renforcer", n]]:
			for br: Dictionary in (xx[1]["gazette"]["barres"] as Array):
				if br["choisi"]:
					choisi[xx[0]] = br["id"]
		verifier("g%d : la barre du choix reel est entouree (vendre -> vendu, rien -> rien, renforcer -> renforce)" % g, choisi == {"rien": "rien", "vendre": "vendu", "renforcer": "renforce"}, str(choisi))


# ---------------------------------------------------------------------
# Sauvegarde
# ---------------------------------------------------------------------

func _jusqu(e: EtatPartie, ab_cible: int) -> void:
	var garde := 0
	while e.fin == "" and e.ab_courant() < ab_cible and garde < 200:
		garde += 1
		StrategieTest.jouer_mois(e, false)
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()


func _suite(e: EtatPartie) -> Array:
	var rec: Array = []
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		StrategieTest.jouer_mois(e, false)
		while not e.modale.is_empty():
			e.resolution_auto()
		var res := e.avancer()
		for n: Dictionary in res.get("notifs", []):
			if str(n.get("type", "")) in ["voisin", "rang", "kiosque"]:
				rec.append([e.ab_courant(), str(n.get("id", n.get("type", "")))])
	return rec


func _t_sauvegarde() -> void:
	for cible in ["1986-11", "1987-11"]:
		_reglages(5, "passif")
		var e := EtatPartie.new()
		e.demarrer(_cfg(5))
		_jusqu(e, Dates.lire(cible))
		var ecrit := Sauvegarde.ecrire(e, {}, _chemin())
		var e2 := Sauvegarde.charger(Sauvegarde.lire(_chemin()))
		var meme := e2 != null and var_to_str(e.jeanmi) == var_to_str(e2.jeanmi) and var_to_str(e.quartier) == var_to_str(e2.quartier) \
			and var_to_str(e.instantane_k) == var_to_str(e2.instantane_k) and e2.rue_active() and absf(e.patrimoine_jeanmi() - e2.patrimoine_jeanmi()) < 1e-9
		verifier("sauvegarde en %s : Jean-Mi, quartier, instantane identiques apres reprise" % cible, ecrit and meme)
		if e2 == null:
			continue
		var s1 := _suite(e)
		var s2 := _suite(e2)
		verifier("sauvegarde en %s : meme fin (notifications, Jean-Mi, quartier, patrimoine, historique)" % cible,
			var_to_str(s1) == var_to_str(s2) and var_to_str(e.jeanmi) == var_to_str(e2.jeanmi) and var_to_str(e.quartier) == var_to_str(e2.quartier)
			and absf(e.patrimoine(e.joueur) - e2.patrimoine(e2.joueur)) < 1e-9 and e.historique.size() == e2.historique.size() and e.fin == "fin" and e2.fin == "fin",
			"%d / %d notifications" % [s1.size(), s2.size()])
	# l'instantane du krach survit a une sauvegarde faite apres le krach (11/1987) avec des lignes
	var r := _jusqu_gazette(3, "rien", true)
	verifier("instantane du krach non vide apres le krach avec un portefeuille (3 lignes), pas d'exemple", not (r["inst"] as Dictionary).is_empty() and not bool(r["inst"]["exemple"]) and (r["inst"]["lignes"] as Array).size() == 3)
	# sauvegarde d'une partie ou la rue etait allumee, perdue de ses cles « quartier » / « instantane_k » (migration douce)
	_reglages(5, "passif")
	var e3 := EtatPartie.new()
	e3.demarrer(_cfg(5))
	_jusqu(e3, Dates.lire("1987-11"))
	var d := e3.vers_dict()
	d.erase("instantane_k")
	var q: Dictionary = (d["quartier"] as Dictionary).duplicate(true)
	for cle in ["kiosque_abandonnes", "abandonnes", "gazette_vue", "gazette_ajoutee", "evts"]:
		q.erase(cle)
	d["quartier"] = q
	var e4 := EtatPartie.depuis_dict(d)
	var fin_ok := e4 != null
	if fin_ok:
		_suite(e4)
		fin_ok = e4.fin == "fin"
	verifier("sauvegarde allumee sans instantane ni quelques cles du quartier : se recharge et va jusqu'a la fin", fin_ok)


# ---------------------------------------------------------------------
# Saut « jusqu'au prochain courrier » : les 5 passages cle ne sont pas perdus ; saut = pas a pas
# ---------------------------------------------------------------------

func _t_saut() -> void:
	var ok_saut := true
	var det := ""
	for g in [2, 9, 17, 25, 33]:
		_reglages(g, "passif")
		var pas := _jouer(g, "passif")
		var e_pas: EtatPartie = pas["e"]
		Partie.nouvelle_partie(_cfg(g))
		var e: EtatPartie = Partie.etat
		var garde := 0
		while e.fin == "" and garde < 400:
			garde += 1
			if not e.modale.is_empty():
				StrategieTest.jouer_mois(e, false)
				continue
			if Partie.sauter_jusqu_au_prochain_arret():
				var tours := 0
				while Partie.saut_actif and tours < 400:
					tours += 1
					Partie._process(1.4)
			else:
				break
		var a := _signature(e)
		var b := _signature(e_pas)
		if a != b or (e.fin != "fin" and e.m < e.m_fin):
			ok_saut = false
			det += "g%d %d / %d entrees, fin=%s m=%d/%d ; " % [g, a.size(), b.size(), e.fin, e.m, e.m_fin]
			for i in mini(a.size(), b.size()):
				if var_to_str(a[i]) != var_to_str(b[i]):
					print("    DIFF saut g%d : %s / pas a pas %s" % [g, str(a[i]), str(b[i])])
					break
		var vus := {}
		for h: Dictionary in e.historique:
			if h["genre"] == "voisin":
				vus[str((h["contenu"] as Dictionary).get("id", ""))] = true
		for id in ETOILES:
			if not vus.has(id):
				ok_saut = false
				det += "etoile %s g%d (saut) ; " % [id, g]
	verifier("saut COURRIER : memes notifications de la rue (mois, id) que pas a pas, 5 passages cle dans l'historique (5 graines)", ok_saut, det)


func _signature(e: EtatPartie) -> Array:
	var s: Array = []
	for h: Dictionary in e.historique:
		if h["source"] in ["rue", "media"] or h["genre"] in ["voisin", "gazette"]:
			s.append([int(h["m"]), str(h["genre"]), str(h["source"]), str((h["contenu"] as Dictionary).get("id", h["type"]))])
	return s


# ---------------------------------------------------------------------
# Bilan
# ---------------------------------------------------------------------

func _t_bilan() -> void:
	var ok_b := true
	var det := ""
	var vus := {}
	for g in range(1, 41):
		var p := _jouer(g, ["passif", "actif", "peugeot"][g % 3])
		var e: EtatPartie = p["e"]
		var b := Bilan.calculer(e)
		var cl := e.classement_rue()
		var rue: Array = b["rue"]
		var rep: Dictionary = b["replique_rue"]
		if rue.size() != 4 or var_to_str(rue) != var_to_str(cl):
			ok_b = false
			det += "classement g%d ; " % g
			continue
		# 4 rangs 1..4 distincts, tri decroissant, egalite : le joueur devant
		for i in 4:
			if int(rue[i]["rang"]) != i + 1:
				ok_b = false
			if i > 0 and float(rue[i]["patrimoine"]) > float(rue[i - 1]["patrimoine"]) + 1e-9:
				ok_b = false
		var moi := 0
		for i in 4:
			if rue[i]["id"] == "vous":
				moi = i
		var cible_i := moi - 1 if moi > 0 else moi + 1
		var voisin: Dictionary = rue[cible_i]
		var t: Dictionary = Donnees.temoins()[voisin["id"]]
		var texte := str(t["devant" if moi > 0 else "derriere"])
		vus[str(voisin["id"]) + ("_devant" if moi > 0 else "_derriere")] = true
		if str(rep.get("qui", "")) != str(voisin["id"]) or str(rep.get("nom", "")) != str(voisin["nom"]) or str(rep.get("texte", "")) != texte or texte == "":
			ok_b = false
			det += "replique g%d ; " % g
	print("RECETTE bilan repliques vues : ", vus.keys())
	verifier("bilan : « rue » = classement_rue() (4 lignes, rangs 1 a 4), « replique_rue » = voisin juste devant le joueur (sinon juste derriere), texte devant / derriere (40 graines)", ok_b, det.left(300))
	var e_off: EtatPartie = (_jouer(4, "passif", false))["e"]
	var b_off := Bilan.calculer(e_off)
	verifier("bilan rue eteinte : « rue » vide et « replique_rue » vide", (b_off["rue"] as Array).is_empty() and (b_off["replique_rue"] as Dictionary).is_empty())
