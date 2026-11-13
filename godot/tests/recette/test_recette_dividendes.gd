extends SceneTree
## Recette du testeur, lot 03-L (dividendes). Logique pure, aucun fichier écrit.
## Recalcul « à la main » depuis les JSON bruts (FileAccess + JSON, sans Donnees ni Marche) des dividendes de mai 1987,
## règle « détenu au début du mois », achat / vente dans le mois de détachement, Peugeot divNul (notification neutre),
## témoins, décomposition de l'aller-retour D5, relevé d'un joueur sans intérêts mais avec dividendes.
## Lancer : Godot_console.exe --headless --path godot --script res://tests/recette/test_recette_dividendes.gd

const F := 6.55957
const TITRES := ["elf", "loreal", "peugeot", "saintgobain"]

var _ok := 0
var _ko := 0


func _initialize() -> void:
	_recalcul_mai_1987()
	_detenu_au_debut()
	_peugeot_1986()
	_temoins()
	_aller_retour()
	_releve_sans_interets()
	print("")
	print("=== test_recette_dividendes : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _json(nom: String) -> Dictionary:
	var f := FileAccess.open("res://data/%s.json" % nom, FileAccess.READ)
	var v: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	return v


func _brut_produit(id: String) -> Dictionary:
	for p: Dictionary in _json("periode_p1")["produits"]:
		if p["id"] == id:
			return p
	return {}


func _partie(d: String) -> EtatPartie:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(7))
	StrategieTest.aller_a(e, Dates.lire(d), false)
	while not e.modale.is_empty():
		e.resolution_auto()
	return e


func _mois(e: EtatPartie) -> Dictionary:
	while not e.modale.is_empty():
		e.resolution_auto()
	return e.avancer()


func _lignes_div(r: Dictionary) -> Array:
	return (r["flux"]["lignes"] as Array).filter(func(l: Dictionary) -> bool: return l["genre"] == "dividende")


func _notifs(r: Dictionary, type: String) -> Array:
	return (r["notifs"] as Array).filter(func(n: Dictionary) -> bool: return n.get("type", "") == type)


## Scénario du compte rendu : graine 7, joueur passif jusqu'en avril 1987, 5 000 F de chaque titre.
func _recalcul_mai_1987() -> void:
	var series := _json("series")
	var regles := _json("regles")
	var rdt := float(series["annuel"]["1987"][1])
	var cto := -1.0
	for r: Dictionary in regles["impots"]:
		if int(r["de"]) <= 1987:
			cto = float(r["cto"])
	var mois_def := int(regles["dividendes"]["mois"])
	var e := _partie("1987-04")
	e.joueur.cc += Produits.f(5000.0 * 4 + 1000.0)
	var qtes := {}
	for id in TITRES:
		var p_avr := e.cours(id) * F
		# quantité recalculée : courtage 1,3 % minimum 50 F (regles.json > frais)
		var q := int(floor(5000.0 / (p_avr * 1.013)))
		while q > 0 and q * p_avr + maxf(50.0, q * p_avr * 0.013) > 5000.0 + 1e-6:
			q -= 1
		var d := e.acheter(e.joueur, id, Produits.f(5000.0))
		qtes[id] = q
		print("    %s avril 1987 : cours %.2f F, qte %d (moteur %d), payé %.2f F" % [id, p_avr, q, int(d["qte"]), float(d["total"]) * F])
	var r := _mois(e)
	var total := 0.0
	var impot := 0.0
	var ok := Dates.texte(e.ab_courant()) == "mai 1987" and mois_def == 5
	var det := ""
	for id in TITRES:
		var bp := _brut_produit(id)
		var taux := maxf(0.0, rdt + float(bp.get("ecartDiv", 0.0)))
		var p_mai := e.cours(id) * F
		var brut := float(qtes[id]) * p_mai * taux / 100.0
		var net := brut * (1.0 - cto / 100.0)
		total += net
		impot += brut * cto / 100.0
		var vu := 0.0
		for l: Dictionary in _lignes_div(r):
			if l["id"] == id:
				vu = float(l["montant"]) * F
		det += "%s %d × %.2f F × %.1f %% × %.2f = %.2f (moteur %.2f) ; " % [id, qtes[id], p_mai, taux, 1.0 - cto / 100.0, net, vu]
		if absf(vu - net) > 0.005:
			ok = false
	print("    ", det)
	print("RECETTE mai1987 total_net=%.2f impot=%.2f notif_montant=%.2f notif_impot=%.2f" % [total, impot, float(_notifs(r, "dividende")[0]["montant"]) * F, float(_notifs(r, "dividende")[0]["impot"]) * F])
	verifier("Recalcul à la main mai 1987 (JSON bruts, quantités recalculées) = moteur au centime", ok, "total %.2f F, impôt %.2f F" % [total, impot])
	verifier("Montants attendus du compte rendu : Elf 196,35 / L'Oréal 74,88 / Peugeot 118,66 / Saint-Gobain 142,38, total 532,27, impôt 101,39",
		absf(total - 532.27) < 0.006 and absf(impot - 101.39) < 0.006)
	print("    Texte de la 1re notification : ", str(_notifs(r, "dividende")[0]["texte"]))


## Détenu au début du mois de détachement : acheté en mai → rien ; détenu en avril, vendu en mai → versé ; acheté fin avril → versé.
func _detenu_au_debut() -> void:
	var a := _partie("1987-04")
	a.joueur.cc += Produits.f(20000.0)
	a.acheter(a.joueur, "elf", Produits.f(5000.0))
	var r := _mois(a)                       # entrée en mai : versement
	var verse := a.dividendes_recus("elf")
	var v := a.vendre(a.joueur, "elf", 0.0, true)   # vendu en mai, après le versement
	var cc_apres := a.dividendes_recus("elf")
	verifier("Détenu en avril, vendu en mai : dividende gardé (versé à l'entrée du mois, la vente ne le reprend pas)",
		verse > 0.0 and v["ok"] and cc_apres == verse and _lignes_div(r).size() == 1)
	var b := _partie("1987-05")
	b.joueur.cc += Produits.f(20000.0)
	b.acheter(b.joueur, "elf", Produits.f(5000.0))
	var vus := []
	for i in 3:
		var rr := _mois(b)
		if not _lignes_div(rr).is_empty() or not _notifs(rr, "dividende").is_empty():
			vus.append(Dates.texte_court(b.ab_courant()))
	verifier("Acheté en mai 1987 : rien en mai, juin, juillet (ni ligne ni notification)", vus.is_empty() and b.dividendes_recus() == 0.0, str(vus))
	# Achat en mai puis vente en mai : aucune trace
	var c := _partie("1987-05")
	c.joueur.cc += Produits.f(20000.0)
	c.acheter(c.joueur, "elf", Produits.f(5000.0))
	c.vendre(c.joueur, "elf", 0.0, true)
	var rc := _mois(c)
	verifier("Acheté et revendu en mai : rien en juin", _lignes_div(rc).is_empty() and c.dividendes_recus() == 0.0)


## Peugeot détenu en mai 1986 (divNul) : notification neutre, pas de ligne ; Elf détenu en même temps verse.
func _peugeot_1986() -> void:
	var e := _partie("1986-04")
	e.joueur.cc += Produits.f(20000.0)
	e.acheter(e.joueur, "peugeot", Produits.f(5000.0))
	e.acheter(e.joueur, "elf", Produits.f(5000.0))
	var h0 := e.historique.size()
	var r := _mois(e)
	var nul := _notifs(r, "dividende_nul")
	var div := _notifs(r, "dividende")
	print("    Mai 1986 : ", str(nul), " | ", str(div))
	# 03-R (D1) : une seule notification, de type dividende, qui nomme Peugeot (champ nuls)
	var t: String = str(div[0]["texte"]) if div.size() == 1 else ""
	var mots := Banquier.nb_mots(t)
	print("RECETTE 03R mai1986 notifs_dividende=%d notifs_nul=%d mots=%d (espaces : %d) texte=%s" % [div.size(), nul.size(), mots, t.split(" ", false).size(), t])
	verifier("03-R Peugeot + Elf mai 1986 : une seule notification (dividende), aucune dividende_nul, aucune ligne Peugeot",
		nul.is_empty() and div.size() == 1 and _lignes_div(r).size() == 1 and _lignes_div(r)[0]["id"] == "elf")
	verifier("03-R notification unique : premier, explication + « Peugeot : rien cette année. » en fin, nuls = [Peugeot]",
		div.size() == 1 and bool(div[0]["premier"]) and t.contains("Un dividende, c'est") and t.ends_with("Peugeot : rien cette année.")
		and div[0].get("nuls", null) == [{"id": "peugeot", "nom": "Peugeot"}], str(div[0].get("nuls", "absent")) if div.size() == 1 else "")
	verifier("03-R notification unique ≤ 60 mots", mots > 0 and mots <= 60, "%d mots" % mots)
	var ajout_hist := e.historique.slice(h0).filter(func(h: Dictionary) -> bool: return str(h.get("type", "")).begins_with("dividende"))
	verifier("03-R une seule entrée d'historique « dividende » pour mai 1986", ajout_hist.size() == 1, str(ajout_hist.size()))
	verifier("Mai 1986 : pas d'interruption ni de modale ouverte par ces notifications", e.modale.is_empty() or e.modale.get("kind", "") != "dividende")
	# Peugeot seul : notification nul, la 1re vraie notification de dividende restera « premier » plus tard
	var p := _partie("1986-04")
	p.joueur.cc += Produits.f(20000.0)
	p.acheter(p.joueur, "peugeot", Produits.f(5000.0))
	var rp := _mois(p)
	verifier("dividende_nul (Peugeot seul) rangée dans l'historique (source banque)",
		p.historique.any(func(h: Dictionary) -> bool: return h["type"] == "dividende_nul" and h["source"] == "banque"))
	StrategieTest.aller_a(p, Dates.lire("1987-04"), false)
	var rp2 := _mois(p)
	var d2 := _notifs(rp2, "dividende")
	verifier("Peugeot seul : nul en 1986, puis 1er vrai dividende en mai 1987 avec premier = true, nuls = []",
		_notifs(rp, "dividende_nul").size() == 1 and _notifs(rp, "dividende").is_empty() and d2.size() == 1 and bool(d2[0]["premier"])
		and d2[0].get("nuls", null) == [] and not str(d2[0]["texte"]).contains("rien cette année"))


## Témoins : aucun ne détient d'action en direct → aucun dividende (comparaison Livret A inchangée).
func _temoins() -> void:
	var e := _partie("1987-04")
	var lignes := {}
	for k in e.temoins:
		lignes[k] = (e.temoins[k] as Portefeuille).lignes.keys()
	var cc0 := {}
	for k in e.temoins:
		cc0[k] = (e.temoins[k] as Portefeuille).impots
	_mois(e)
	var ok := true
	for k in e.temoins:
		if (e.temoins[k] as Portefeuille).impots != cc0[k]:
			ok = false
	verifier("Témoins : lignes détenues %s ; aucun impôt de dividende en mai 1987" % str(lignes), ok)


## D5 décomposé : gain net = dividende net − frais − variation de cours.
func _aller_retour() -> void:
	var a := _partie("1987-04")
	a.joueur.cc += Produits.f(11000.0)
	var p_avr := a.cours("elf") * F
	var d := a.acheter(a.joueur, "elf", Produits.f(10000.0))
	_mois(a)
	var p_mai := a.cours("elf") * F
	var div := a.dividendes_recus("elf") * F
	_mois(a)
	var p_juin := a.cours("elf") * F
	var v := a.vendre(a.joueur, "elf", 0.0, true)
	var q := float(d["qte"])
	print("RECETTE D5 qte=%d cours avr=%.2f mai=%.2f juin=%.2f ; achat frais=%.2f ; vente frais=%.2f impot_pv=%.2f ; variation=%.2f ; dividende_net=%.2f ; gain=%.2f" % [
		int(q), p_avr, p_mai, p_juin, float(d["frais"]) * F, float(v["frais"]) * F, float(v["impot"]) * F, q * (p_juin - p_avr), div,
		div + float(v["recu"]) * F - float(d["total"]) * F])
	verifier("D5 : gain net = −1 064,84 F (compte rendu)", absf(div + float(v["recu"]) * F - float(d["total"]) * F + 1064.84) < 0.006)


## Relevé de décembre d'un joueur sans Livret A ni intérêts mais avec des dividendes.
func _releve_sans_interets() -> void:
	var e := _partie("1987-04")
	e.joueur.cc += e.joueur.livret
	e.joueur.livret = 0.0
	e.joueur.cc += Produits.f(6000.0)
	e.acheter(e.joueur, "elf", Produits.f(5000.0))
	var rel := {}
	while e.fin == "" and rel.is_empty():
		var r := _mois(e)
		for n: Dictionary in _notifs(r, "releve"):
			rel = n
	print("    Relevé 1987 (sans livret) : ", str(rel.get("texte", "")))
	var t := str(rel.get("texte", ""))
	# 03-R (D2, cas 2) : une seule phrase « Pas d'intérêts cette année, mais … de dividendes versés par vos actions, après impôt. »
	var net := Format.entier(float(e.stats.get("dividendes", {}).get("elf", 0.0)), e.ab_courant())
	verifier("03-R relevé cas 2 : « Pas d'intérêts cette année, mais %s de dividendes versés par vos actions, après impôt. » en tête" % net,
		t.begins_with("Pas d'intérêts cette année, mais %s de dividendes versés par vos actions, après impôt." % net))
	verifier("03-R relevé cas 2 : ni « Aucun intérêt », ni « compte courant », ni « Vos actions vous ont versé »",
		not t.contains("Aucun intérêt") and not t.contains("resté sur le compte courant") and not t.contains("Vos actions vous ont versé"))
	# Anomalie mineure m1 de la recette 03-L : corrigée en 03-R (attendu false).
	var contradiction := t.contains("resté sur le compte courant") and t.contains("dividendes")
	print("RECETTE m1 releve_contradiction=%s" % str(contradiction))
	verifier("03-R m1 levée : releve_contradiction = false", not contradiction)
