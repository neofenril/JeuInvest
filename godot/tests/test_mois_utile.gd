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


func _somme_genre(fl: Dictionary, genre: String) -> float:
	var s := 0.0
	for l: Dictionary in fl.get("lignes", []):
		if l["genre"] == genre:
			s += float(l["montant"])
	return s
