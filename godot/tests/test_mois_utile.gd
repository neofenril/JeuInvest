extends Node
## Tests de P4 « Le mois utile » (docs/15 §1 ; feuille de route §2, CA-L2 et CA-L3) : flux du mois, saut
## « jusqu'au prochain courrier », notifications non lues. Scène : l'autoload Partie est nécessaire.
## Lancer : Godot_console.exe --headless --path godot res://tests/test_mois_utile.tscn
## Tout se joue de façon synchrone dans _ready (aucune image ne passe : Partie._process n'avance pas seul).

const F := 6.55957

var _ok := 0
var _ko := 0


func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_flux()
	_brancher()
	_tests_saut()
	_tests_saut_details()
	print("")
	print("=== test_mois_utile : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	get_tree().quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


# ---------------------------------------------------------------------
# CA-L2 : flux du mois (docs/15 CA-4.3)
# ---------------------------------------------------------------------

## Le joueur actif programme aussi des versements automatiques (assurance-vie, SICAV, Livret A) dès que
## possible, pour que les frais de versement apparaissent dans le flux.
func _programmer_versements(e: EtatPartie) -> void:
	for pid in ["av", "sicav", "livret"]:
		if Banquier.presente(e, pid) and Banquier.detenu(e, pid) and not e.joueur.versements.has(pid):
			e.programmer_versement(pid, Produits.f(300.0 if pid != "livret" else 100.0))


func _somme_lignes(fl: Dictionary, revenus: bool) -> float:
	var s := 0.0
	for l: Dictionary in fl["lignes"]:
		if EtatPartie.GENRES_REVENUS.has(l["genre"]) == revenus:
			s += float(l["montant"])
	return s


func _tests_flux() -> void:
	var tol := 1.0 / F   # un franc
	var ok_revenus := true
	var ok_frais := true
	var ok_gestion := true
	var ok_lignes := true
	var ok_decembre := true
	var ok_releve := true
	var ok_copie := true
	var ecart_rev := 0.0
	var ecart_frais := 0.0
	var nb_mois := 0
	var nb_releves := 0
	var genres := {}
	var detail_ko := ""
	for g in [7, 11, 23]:
		var e := EtatPartie.new()
		var res := e.demarrer(Donnees.config_demo(g))
		var acc_int := 0.0      # intérêts acquis depuis le dernier relevé
		var acc_coupon := _somme_genre(res["flux"], "coupon")
		var garde := 0
		while e.fin == "" and garde < 80:
			garde += 1
			StrategieTest.jouer_mois(e, true)
			while not e.modale.is_empty():
				e.resolution_auto()
			_programmer_versements(e)
			# Attendu, calculé sur l'état du joueur avant le changement de mois (formules du moteur)
			var a := e.ab_courant()
			var w := e.joueur
			var att_int := w.livret * Marche.taux_livret(a) / 1200.0
			if not w.pel.is_empty():
				att_int += float(w.pel["solde"]) * float(w.pel["taux"]) / 1200.0
			if not w.av.is_empty():
				att_int += float(w.av["valeur"]) * Produits.taux_av(Dates.annee(a)) / 1200.0
			var gm := float(e.regles["sicav"]["gestion"]) / 1200.0
			var att_gestion := 0.0
			for id in w.lignes:
				if e.produit(id).get("type", "") == "sicav":
					att_gestion += e.valeur_ligne(w, id) * gm / (1.0 - gm)
			var att_coupon := 0.0
			for t: Dictionary in w.emprunts:
				var age := e.m + 1 - int(t["m"])
				if age > 0 and age % 12 == 0:
					att_coupon += float(t["nominal"]) * float(t["taux"]) / 100.0 * (1.0 - float(Produits.params()["emprunt"]["impot_coupons"]) / 100.0)
			var frais_avant := e.frais_payes()
			var r := e.avancer()
			nb_mois += 1
			if r.get("fin", "") != "":
				att_coupon = 0.0   # fin de partie (ou faillite) : pas de coupon dans un mois suivant
			var fl: Dictionary = r["flux"]
			for l: Dictionary in fl["lignes"]:
				genres[l["genre"]] = true
				if l["genre"] == "interets" and bool(l["verse_en_decembre"]) != (Dates.mois(a) != 12):
					ok_decembre = false
			var d_rev := absf(float(fl["revenus"]) - (att_int + att_coupon))
			var d_frais := absf(float(fl["frais"]) - (e.frais_payes() - frais_avant))
			ecart_rev = maxf(ecart_rev, d_rev)
			ecart_frais = maxf(ecart_frais, d_frais)
			if d_rev > tol:
				ok_revenus = false
				detail_ko += "g%d %s revenus %.2f F au lieu de %.2f F ; " % [g, Dates.texte_court(a), float(fl["revenus"]) * F, (att_int + att_coupon) * F]
			if d_frais > tol:
				ok_frais = false
				detail_ko += "g%d %s frais %.2f F au lieu de %.2f F ; " % [g, Dates.texte_court(a), float(fl["frais"]) * F, (e.frais_payes() - frais_avant) * F]
			if absf(_somme_genre(fl, "frais") - att_gestion) > tol:
				ok_gestion = false
			if absf(_somme_lignes(fl, true) - float(fl["revenus"])) > 1e-6 or absf(_somme_lignes(fl, false) - float(fl["frais"])) > 1e-6:
				ok_lignes = false
			if var_to_str(e.flux_du_mois()) != var_to_str(fl):
				ok_copie = false
			# Relevé de décembre : ses intérêts de l'année = intérêts acquis de janvier à décembre + coupons de l'année
			acc_int += _somme_genre(fl, "interets")
			for n: Dictionary in r["notifs"]:
				if n.get("type", "") == "releve":
					nb_releves += 1
					if absf(float(n["interets"]) - (acc_int + acc_coupon)) > tol:
						ok_releve = false
						detail_ko += "g%d relevé %s : %.2f F au lieu de %.2f F ; " % [g, Dates.texte_court(a), float(n["interets"]) * F, (acc_int + acc_coupon) * F]
					acc_int = 0.0
					acc_coupon = 0.0
			acc_coupon += _somme_genre(fl, "coupon")
	var resume := "%d mois, écart max revenus %.4f F, frais %.4f F, %d relevés, genres %s" % [nb_mois, ecart_rev * F, ecart_frais * F, nb_releves, str(genres.keys())]
	print("    Flux : ", resume)
	if detail_ko != "":
		print("    ", detail_ko.left(1500))
	verifier("Flux : 3 graines × 60 mois, revenus = intérêts acquis (Livret A, PEL, assurance-vie) + coupons nets, au franc près", ok_revenus and nb_mois >= 180, resume)
	verifier("Flux : frais = frais payés du mois dans le moteur (gestion de la SICAV + frais des versements automatiques), au franc près", ok_frais)
	verifier("Flux : lignes « frais » = frais de gestion de la SICAV du mois", ok_gestion)
	verifier("Flux : revenus et frais = somme de leurs lignes", ok_lignes)
	verifier("Flux : intérêts « versés en décembre » sauf en décembre", ok_decembre)
	verifier("Flux : relevé de décembre = somme des revenus de l'année (intérêts acquis et coupons)", ok_releve and nb_releves == 15)
	verifier("Flux : les 4 genres présents (intérêts, coupon, frais, frais de versement)", genres.has("interets") and genres.has("coupon") and genres.has("frais") and genres.has("frais_versement"), str(genres.keys()))
	verifier("Flux : flux_du_mois() = res[\"flux\"] du dernier mois", ok_copie)
	var e2 := EtatPartie.new()
	var r0 := e2.demarrer(Donnees.config_demo(7))
	verifier("Flux : premier mois et mois bloqué par une modale sans mouvement (aucune ligne)",
		r0["flux"]["lignes"].is_empty() and e2.avancer()["flux"]["lignes"].is_empty() and not e2.modale.is_empty())


# ---------------------------------------------------------------------
# CA-L3 : saut « jusqu'au prochain courrier » (docs/15 CA-4.1, 4.2, 4.4)
# ---------------------------------------------------------------------

var _evts: Array = []   # signaux de Partie, dans l'ordre


func _brancher() -> void:
	Partie.saut_change.connect(func(a: bool) -> void: _evts.append({"s": "saut", "actif": a, "m": Partie.etat.m}))
	Partie.modale_ouverte.connect(func(_c: Dictionary) -> void: _evts.append({"s": "modale", "m": Partie.etat.m, "saut": Partie.saut_actif}))
	Partie.mois_passe.connect(func(r: Dictionary) -> void: _evts.append({"s": "mois", "m": int(r.get("m", -1)), "pendant": bool(r.get("pendant_saut", false))}))
	Partie.notif_recue.connect(func(n: Dictionary) -> void: _evts.append({"s": "notif", "m": Partie.etat.m, "pendant": bool(n.get("pendant_saut", false)), "titre": str(n.get("titre", ""))}))
	Partie.partie_finie.connect(func(_b: Dictionary) -> void: _evts.append({"s": "fin", "m": Partie.etat.m}))


## État comparable d'une partie, sans les marques « lu » de l'historique (seule différence voulue du saut).
func _empreinte(e: EtatPartie) -> String:
	var d := e.vers_dict()
	for h: Dictionary in d["historique"]:
		h.erase("lu")
	return var_to_str(d)


## La même partie jouée sans saut, mois par mois, avec les mêmes choix (joueur passif).
func _reference(g: int) -> EtatPartie:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(g))
	var garde := 0
	while e.fin == "" and garde < 200:
		garde += 1
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	return e


func _tests_saut() -> void:
	var ok_arret := true        # chaque arrêt au mois exact d'une modale (ou à la fin), jamais sans
	var ok_modale := true       # chaque modale rencontrée pendant un saut l'arrête, saut_actif faux à l'émission
	var ok_mois := true         # mois consécutifs, tous « pendant_saut »
	var ok_vitesse := true      # pendant le saut : vitesse d'avant ; après la modale : vitesse d'avant (marché : pause)
	var ok_rythme := true       # durée 1,33 s et trafic 7 pendant le saut
	var ok_notifs := true       # notifications franchies : dans l'historique, dans l'ordre, non lues
	var ok_lues := true         # non_lues() exact, marquer_lues() → 0
	var ok_identique := true    # même partie qu'en avançant mois par mois
	var ok_dec := true          # saut impossible en décembre 1988 et après la fin
	var nb_sauts := 0
	var nb_arrets_modale := 0
	var nb_franchies := 0
	var par_vitesse := {0: 0, 1: 0, 3: 0}
	var detail_ko := ""
	var r := Donnees.charger("rythme")
	for g in range(1, 41):
		var v_depart: int = [0, 1, 3][g % 3]
		Partie.nouvelle_partie(Donnees.config_demo(g))
		var e := Partie.etat
		var franchies: Array = []     # titres des notifications franchies depuis le dernier marquer_lues
		var garde := 0
		var arret_par_modale := false
		var v_avant := -1
		while e.fin == "" and garde < 200:
			garde += 1
			if not e.modale.is_empty():
				var kind: String = e.modale["kind"]
				Partie.resoudre_modale(StrategieTest.choix_modale(e, false))
				if arret_par_modale:
					var v_att := 0 if kind == "marche" else v_avant
					if Partie.vitesse != v_att:
						ok_vitesse = false
						detail_ko += "g%d %s : vitesse %d après la modale %s au lieu de %d ; " % [g, Dates.texte_court(e.ab_courant()), Partie.vitesse, kind, v_att]
					par_vitesse[v_avant] = int(par_vitesse[v_avant]) + 1
				arret_par_modale = false
				continue
			Partie.changer_vitesse(v_depart)
			v_avant = Partie.vitesse
			if e.m >= e.m_fin:
				if Partie.saut_possible() or Partie.sauter_jusqu_au_prochain_arret():
					ok_dec = false
				Partie.avancer_un_mois()
				continue
			var m0 := e.m
			var n0 := _evts.size()
			if not Partie.sauter_jusqu_au_prochain_arret():
				ok_arret = false
				detail_ko += "g%d %s : saut refusé ; " % [g, Dates.texte_court(e.ab_courant())]
				break
			nb_sauts += 1
			if Partie.saut_possible():
				ok_dec = false   # pas de second saut pendant un saut
			if not is_equal_approx(Partie.duree_mois_s(), float(r["saut"]["duree_mois_s"])) or not is_equal_approx(Partie.facteur_trafic(v_avant), float(r["saut"]["trafic"])) \
					or not is_equal_approx(Partie.duree_mois_s(1), float(r["saut"]["duree_mois_s"])):
				ok_rythme = false
			var pas := 0
			while Partie.saut_actif and pas < 100:
				Partie._process(1.4)
				pas += 1
				if Partie.saut_actif and Partie.vitesse != v_avant:
					ok_vitesse = false
			# Analyse des signaux du saut
			var tranche: Array = _evts.slice(n0)
			var mois_vus: Array = []
			var arrets: Array = []
			var modales: Array = []
			var fin_vue := false
			for x: Dictionary in tranche:
				match x["s"]:
					"mois":
						mois_vus.append(int(x["m"]))
						if not x["pendant"]:
							ok_mois = false
					"notif":
						if not x["pendant"]:
							ok_notifs = false
						franchies.append(x["titre"])
						nb_franchies += 1
					"saut":
						if not x["actif"]:
							arrets.append(int(x["m"]))
					"modale":
						modales.append(int(x["m"]))
						if x["saut"]:
							ok_modale = false
					"fin":
						fin_vue = true
			# Fin de partie : le dernier changement de mois (décembre 1988 → fin) garde m = m_fin
			var consecutifs := mois_vus.duplicate()
			if fin_vue and consecutifs.size() >= 2 and consecutifs[-1] == e.m_fin and consecutifs[-2] == e.m_fin:
				consecutifs.pop_back()
			for i in consecutifs.size():
				if consecutifs[i] != m0 + 1 + i:
					ok_mois = false
					detail_ko += "g%d : mois %s depuis %d ; " % [g, str(mois_vus), m0]
					break
			var m_arret: int = arrets[0] if arrets.size() == 1 else -1
			if arrets.size() != 1 or mois_vus.is_empty() or m_arret != mois_vus[mois_vus.size() - 1]:
				ok_arret = false
				detail_ko += "g%d : arrêts %s, mois %s ; " % [g, str(arrets), str(mois_vus)]
			elif modales.size() == 1 and modales[0] == m_arret and not e.modale.is_empty():
				arret_par_modale = true
				nb_arrets_modale += 1
			elif not (fin_vue and modales.is_empty() and e.fin != ""):
				ok_arret = false
				detail_ko += "g%d %s : arrêt sans modale ; " % [g, Dates.texte_court(e.ab_de(m_arret))]
			# Historique : les notifications franchies, dans l'ordre, non lues
			var non_lus: Array = []
			for h: Dictionary in e.historique:
				if not bool(h.get("lu", true)):
					non_lus.append(str(h["titre"]))
			if non_lus != franchies:
				ok_notifs = false
				detail_ko += "g%d : %d non lues dans l'historique, %d franchies ; " % [g, non_lus.size(), franchies.size()]
			if e.non_lues() != franchies.size():
				ok_lues = false
			var par_source := 0
			for s in EtatPartie.SOURCES_HISTORIQUE:
				par_source += e.non_lues(s)
			if par_source != e.non_lues():
				ok_lues = false
			if nb_sauts % 3 == 0:
				e.marquer_lues()
				if e.non_lues() != 0:
					ok_lues = false
				franchies.clear()
		if Partie.saut_possible() or Partie.sauter_jusqu_au_prochain_arret():
			ok_dec = false
		if _empreinte(e) != _empreinte(_reference(g)):
			ok_identique = false
			detail_ko += "g%d : partie différente de la référence ; " % g
	var resume := "%d sauts, %d arrêts sur une modale, %d notifications franchies ; retours vérifiés : pause %d, ×1 %d, ×3 %d" % [nb_sauts, nb_arrets_modale, nb_franchies, par_vitesse[0], par_vitesse[1], par_vitesse[3]]
	print("    Saut : ", resume)
	if detail_ko != "":
		print("    ", detail_ko.left(1500))
	verifier("Saut (40 graines, appui après chaque interruption) : chaque arrêt au mois exact d'une modale (ou à la fin), aucun arrêt sans modale", ok_arret and nb_arrets_modale > 300, resume)
	verifier("Saut : saut_actif est faux quand modale_ouverte est émis", ok_modale)
	verifier("Saut : chaque mois traversé est diffusé (mois consécutifs, res[\"pendant_saut\"])", ok_mois)
	verifier("Saut : aucun mois sauté sans son traitement (salaire, versements, historique) : partie identique à la partie jouée mois par mois", ok_identique)
	verifier("Saut : vitesse d'avant gardée pendant le saut et rétablie après la modale (×1 → ×1, pause → pause, ×3 → ×3 ; marché : pause)", ok_vitesse and int(par_vitesse[0]) > 0 and int(par_vitesse[1]) > 0)
	verifier("Saut : un mois dure saut.duree_mois_s et le trafic vaut saut.trafic, quelle que soit la vitesse", ok_rythme)
	verifier("Saut : notifications franchies toutes dans l'historique, dans l'ordre, lu = false, n[\"pendant_saut\"] vrai", ok_notifs and nb_franchies > 0)
	verifier("Saut : non_lues() exact (au total et par source), marquer_lues() → 0", ok_lues)
	verifier("Saut : impossible en décembre 1988, pendant un saut et après la fin", ok_dec)


func _tests_saut_details() -> void:
	# Arrêt par un nouvel appui ; un 2e arrêt est sans effet
	Partie.nouvelle_partie(Donnees.config_demo(7))
	var e := Partie.etat
	Partie.resoudre_modale("plus_tard")
	Partie.changer_vitesse(2)
	var n0 := _evts.size()
	var parti := Partie.sauter_jusqu_au_prochain_arret()
	Partie.arreter_saut()
	Partie.arreter_saut()
	var emissions := _evts.slice(n0).filter(func(x: Dictionary) -> bool: return x["s"] == "saut")
	verifier("Saut : arreter_saut() rend la vitesse d'avant (×2) ; un 2e appel est sans effet",
		parti and not Partie.saut_actif and Partie.vitesse == 2 and emissions.size() == 2 and not e.saut_en_cours, str(emissions))
	# Un choix de vitesse pendant le saut l'arrête ; la pause aussi
	Partie.sauter_jusqu_au_prochain_arret()
	Partie.changer_vitesse(3)
	var ok1 := not Partie.saut_actif and Partie.vitesse == 3
	Partie.sauter_jusqu_au_prochain_arret()
	Partie.basculer_pause()
	verifier("Saut : changer de vitesse ou mettre en pause pendant le saut l'arrête", ok1 and not Partie.saut_actif and Partie.vitesse == 0)
	# Temps bloqué par l'interface : pas de saut ; modale en attente : pas de saut
	Partie.bloquee = true
	var bloque := Partie.saut_possible()
	Partie.bloquee = false
	Partie.forcer_naissance(false)
	verifier("Saut : impossible quand le temps est bloqué (fenêtre ouverte) ou qu'une modale attend",
		not bloque and not e.modale.is_empty() and not Partie.saut_possible() and not Partie.sauter_jusqu_au_prochain_arret())
	Partie.resoudre_modale(StrategieTest.choix_modale(e, false))
	# Décembre 1988 atteint sans saut : le bouton est inactif
	StrategieTest.aller_a(e, Dates.lire("1988-12"), false)
	while not e.modale.is_empty():
		e.resolution_auto()
	verifier("Saut : impossible en décembre 1988 (dernier mois)", e.ab_courant() == Dates.lire("1988-12") and e.fin == "" and not Partie.saut_possible() and not Partie.sauter_jusqu_au_prochain_arret())


func _somme_genre(fl: Dictionary, genre: String) -> float:
	var s := 0.0
	for l: Dictionary in fl.get("lignes", []):
		if l["genre"] == genre:
			s += float(l["montant"])
	return s
