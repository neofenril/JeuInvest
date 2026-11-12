extends Node
## Recette du lot 03-I (testeur) : ligne des dividendes de la fiche d'une action (I6, CA-I6).
## 1) Rejoue la partie de l'étape de capture `fiche_dividendes` (graine des captures, StrategieTest actif,
##    Elf achetée en avril 1987 si besoin, juin 1987) et recalcule « à la main » les dividendes nets d'Elf
##    depuis les JSON bruts (quantité détenue à l'entrée de chaque mois de mai × cours de mai × taux × (1 − impôt)).
## 2) Texte de la fiche : rien pour un produit qui n'est pas une action, ni pour une action non détenue ou vendue ;
##    Peugeot (divNul 1984-1986) : ce que dit la fiche avant et après la notification « Pas de dividende cette année ».
## Logique seule (EtatPartie neuve, Partie et la sauvegarde ne sont pas touchées).

const F := 6.55957

var ok := 0
var ko := 0


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _ready() -> void:
	_fiche_juin_1987()
	_textes()
	print("")
	print("=== test_recette_fiche_dividendes : %d OK, %d KO ===" % [ok, ko])
	get_tree().quit(1 if ko > 0 else 0)


func _json(nom: String) -> Dictionary:
	var f := FileAccess.open("res://data/%s.json" % nom, FileAccess.READ)
	var v: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	return v


func _brut(id: String) -> Dictionary:
	for p: Dictionary in _json("periode_p1")["produits"]:
		if p["id"] == id:
			return p
	return {}


func _cto(annee: int) -> float:
	var cto := -1.0
	for r: Dictionary in _json("regles")["impots"]:
		if int(r["de"]) <= annee:
			cto = float(r["cto"])
	return cto


## Même chemin que l'étape `fiche_dividendes` (scenarios/banque.gd) : partir_de_la_rue (resolution_auto), puis
## StrategieTest.aller_a(1987-04, actif), Elf achetée si absente, aller_a(1987-06, actif). Mois par mois pour
## relever la quantité d'Elf détenue juste avant l'entrée de chaque mois de mai.
func _fiche_juin_1987() -> void:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(-1))
	e.resolution_auto()
	var series := _json("series")
	var bp := _brut("elf")
	var mois_div := e.mois_dividende("elf")
	var attendu := 0.0
	var detail := ""
	var achat_force := false
	while e.ab_courant() < Dates.lire("1987-06") and e.fin == "":
		if e.ab_courant() == Dates.lire("1987-04") and not e.joueur.lignes.has("elf"):
			e.acheter(e.joueur, "elf", minf(Produits.f(3000.0), e.joueur.cc * 0.8))
			achat_force = true
		# un mois de StrategieTest.aller_a, en notant la quantité détenue à l'instant du passage au mois suivant
		StrategieTest.jouer_mois(e, true)
		if not e.modale.is_empty():
			e.resolution_auto()
		var q := e.joueur.qte("elf")
		e.avancer()
		if Dates.mois(e.ab_courant()) == mois_div and q > 0.0:
			var an := Dates.annee(e.ab_courant())
			var taux := maxf(0.0, float(series["annuel"][str(an)][1]) + float(bp.get("ecartDiv", 0.0)))
			if (bp.get("divNul", []) as Array).has(an) or (bp.get("divNul", []) as Array).has(float(an)):
				taux = 0.0
			var cours := e.cours("elf") * F
			var net := q * cours * taux / 100.0 * (1.0 - _cto(an) / 100.0)
			attendu += net
			detail += "%s : %d × %.2f F × %.2f %% × %.2f = %.2f F ; " % [Dates.texte(e.ab_courant()), int(q), cours, taux, 1.0 - _cto(an) / 100.0, net]
	var moteur := e.dividendes_recus("elf") * F
	print("RECETTE fiche_dividendes %s achat_force=%s qte_elf=%d moteur=%.2f F recalcul=%.2f F" % [Dates.texte(e.ab_courant()), str(achat_force), int(e.joueur.qte("elf")), moteur, attendu])
	print("    ", detail)
	var texte := PanneauBanque.texte_dividendes(e, "elf")
	verifier("Fiche d'Elf en juin 1987 (partie de l'étape fiche_dividendes) : « Dividendes reçus : 192 F »", texte == "Dividendes reçus : 192" + Format.ESPACE + "F", texte)
	verifier("Recalcul à la main (JSON bruts) = cumul du moteur au centime", absf(moteur - attendu) < 0.006, "%.2f / %.2f" % [moteur, attendu])


func _textes() -> void:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(7))
	StrategieTest.aller_a(e, Dates.lire("1986-04"), false)
	while not e.modale.is_empty():
		e.resolution_auto()
	e.joueur.cc += Produits.f(20000.0)
	e.acheter(e.joueur, "peugeot", Produits.f(5000.0))
	e.acheter(e.joueur, "elf", Produits.f(5000.0))
	var autres := []
	for pid in ["livret", "sicav", "av", "pel", "loreal"]:
		var t := PanneauBanque.texte_dividendes(e, pid)
		if t != "":
			autres.append("%s : %s" % [pid, t])
	verifier("Aucune ligne de dividende pour un produit qui n'est pas une action, ni pour une action non détenue (L'Oréal)", autres.is_empty(), str(autres))
	var avant := PanneauBanque.texte_dividendes(e, "peugeot")
	verifier("Peugeot détenue en avril 1986 : « Dividende versé chaque année en mai »", avant == "Dividende versé chaque année en mai", avant)
	var nul := false
	while e.ab_courant() < Dates.lire("1986-06"):
		while not e.modale.is_empty():
			e.resolution_auto()
		var r := e.avancer()
		for n: Dictionary in r["notifs"]:
			if n.get("type", "") == "dividende_nul" and n.get("id", "") == "peugeot":
				nul = true
	var apres := PanneauBanque.texte_dividendes(e, "peugeot")
	print("RECETTE peugeot_1986 notif_nul=%s fiche_juin_1986=« %s » elf=« %s »" % [str(nul), apres, PanneauBanque.texte_dividendes(e, "elf")])
	verifier("Elf détenue en mai 1986 : « Dividendes reçus : … » en juin 1986", PanneauBanque.texte_dividendes(e, "elf").begins_with("Dividendes reçus : "))
	e.vendre(e.joueur, "elf", 0.0, true)
	verifier("Elf vendue : plus de ligne de dividende (action non détenue)", PanneauBanque.texte_dividendes(e, "elf") == "")
