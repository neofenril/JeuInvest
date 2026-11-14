extends SceneTree
## Lot 07-L, CA-T10 (mesure, non bloquante) : répartition des 9 titres sur 40 graines × les stratégies existantes de
## StrategieTest (joueur actif ou passif ; cartes epargner / depenser / alterner ; projets moins_cher + jour J auto ou
## plus_cher + vendre ; plus « tout sur Peugeot »). Imprime une ligne REPARTITION par combinaison et les ALERTES pour le
## game designer (un titre au-dessus de 50 % des parties « alterner » ; « bon père » jamais obtenu hors stratégie dédiée).
## Seules vérifications bloquantes : toutes les parties vont à leur terme et reçoivent un titre (sauf faillite).
## Lancer : Godot_console --headless --path godot --script res://tests/test_titres_mesures.gd

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	var ids: Array = Titres.tous().map(func(t: Dictionary) -> String: return str(t["id"]))
	var total_alterner := {}
	var total_tout := {}
	var nb_alterner := 0
	var nb_tout := 0
	var sans_titre := 0
	var inachevees := 0
	var alertes_combo := []
	var combos := []
	for actif in [true, false]:
		for cartes in ["epargner", "depenser", "alterner"]:
			for projets in ["moins_cher", "plus_cher"]:
				combos.append({"actif": actif, "cartes": cartes, "projets": projets, "strategie": ""})
	combos.append({"actif": true, "cartes": "alterner", "projets": "moins_cher", "strategie": "peugeot"})
	for c: Dictionary in combos:
		var compte := {}
		for g in range(1, 41):
			var e := _partie(g, c)
			if e.fin == "":
				inachevees += 1
			var t := Titres.calculer(e)
			if t.is_empty():
				sans_titre += 1
				continue
			var id := str(t["id"])
			compte[id] = int(compte.get(id, 0)) + 1
			total_tout[id] = int(total_tout.get(id, 0)) + 1
			nb_tout += 1
			if c["cartes"] == "alterner":
				total_alterner[id] = int(total_alterner.get(id, 0)) + 1
				nb_alterner += 1
		var nb_combo := 0
		for id2 in compte:
			nb_combo += int(compte[id2])
		if c["cartes"] == "alterner":
			for id2 in compte:
				if nb_combo > 0 and float(compte[id2]) / float(nb_combo) > 0.5:
					alertes_combo.append("%s %s %s%s : %s = %d / %d" % ["actif" if c["actif"] else "passif", c["cartes"], c["projets"],
						" " + str(c["strategie"]) if c["strategie"] != "" else "", id2, int(compte[id2]), nb_combo])
		print("REPARTITION %s cartes=%s projets=%s%s : %s" % ["actif" if c["actif"] else "passif", c["cartes"], c["projets"],
			" strategie=" + str(c["strategie"]) if c["strategie"] != "" else "", _ligne(compte, ids)])
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "moins_cher"
	StrategieTest.politique_echeance = "auto"
	StrategieTest.strategie = ""
	print("REPARTITION TOTALE (%d parties) : %s" % [nb_tout, _ligne(total_tout, ids)])
	print("REPARTITION ALTERNER (%d parties) : %s" % [nb_alterner, _ligne(total_alterner, ids)])
	var alertes := 0
	for id: String in ids:
		var n := int(total_alterner.get(id, 0))
		if nb_alterner > 0 and float(n) / float(nb_alterner) > 0.5:
			alertes += 1
			print("ALERTE : le titre « %s » dépasse 50 %% des parties « alterner » (%d / %d) : titre trop facile, rejouabilité faible" % [id, n, nb_alterner])
	for a in alertes_combo:
		alertes += 1
		print("ALERTE (une combinaison « alterner » au-dessus de 50 %%) : %s" % a)
	if int(total_tout.get("bon_pere", 0)) == 0:
		alertes += 1
		print("ALERTE : « bon_pere » n'est jamais obtenu hors stratégie dédiée (sur %d parties)" % nb_tout)
	print("MESURE alertes=%d titres_obtenus=%d/9" % [alertes, total_tout.size()])
	verifier("Toutes les parties vont à leur terme (aucune inachevée)", inachevees == 0, "%d inachevées" % inachevees)
	verifier("Toutes les parties menées à terme reçoivent un titre", sans_titre == 0, "%d sans titre (faillite)" % sans_titre)
	print("")
	print("=== test_titres_mesures : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _ligne(compte: Dictionary, ids: Array) -> String:
	var s := ""
	for id: String in ids:
		s += "%s=%d " % [id, int(compte.get(id, 0))]
	return s.strip_edges()


func _partie(g: int, c: Dictionary) -> EtatPartie:
	StrategieTest.politique_cartes = str(c["cartes"])
	StrategieTest.politique_projets = str(c["projets"])
	StrategieTest.politique_echeance = "vendre" if c["projets"] == "plus_cher" else "auto"
	StrategieTest.strategie = str(c["strategie"])
	var cfg := Donnees.config_demo(g)
	cfg["cartes"] = true
	cfg["projets"] = true
	cfg["rue"] = true
	var e := EtatPartie.new()
	e.demarrer(cfg)
	var garde := 0
	while e.fin == "" and garde < 400:
		garde += 1
		StrategieTest.jouer_mois(e, bool(c["actif"]))
		if not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	return e
