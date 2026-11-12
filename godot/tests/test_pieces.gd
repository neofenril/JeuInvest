extends SceneTree
## Tests des règles des pièces du mois (lot 02, V1 : D8, D10) : PiecesMois.plan, fonction pure. Headless :
##   Godot_console.exe --headless --path godot --script res://tests/test_pieces.gd
## Code de sortie 0 si tout passe, 1 sinon. Aucun accès à user://.

var _ok := 0
var _ko := 0
var _avril := Dates.lire("1987-04")
var _novembre := Dates.lire("1987-11")
var _decembre := Dates.lire("1987-12")


func _init() -> void:
	var debut := Time.get_ticks_msec()
	_tests_nombre()
	_tests_vitesse()
	_tests_textes()
	_tests_lignes()
	_tests_traces()
	print("test_pieces : %d OK, %d KO (%d ms)" % [_ok, _ko, Time.get_ticks_msec() - debut])
	quit(1 if _ko > 0 else 0)


func _verifier(cond: bool, nom: String, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  ", nom)
	else:
		_ko += 1
		print("KO  ", nom, ("  (" + detail + ")") if detail != "" else "")


## Montant en francs → euros internes.
func _e(francs: float) -> float:
	return francs / Format.TAUX_EURO


func _flux(revenus_f: float, frais_f: float, lignes: Array = []) -> Dictionary:
	return {"revenus": _e(revenus_f), "frais": _e(frais_f), "lignes": lignes}


func _ligne(id: String, nom: String, genre: String, francs: float, decembre := false) -> Dictionary:
	return {"id": id, "nom": nom, "genre": genre, "montant": _e(francs), "verse_en_decembre": decembre}


func _tests_nombre() -> void:
	var cas := {10.0: 1, 31.0: 1, 100.0: 2, 312.0: 2, 1000.0: 3, 10000.0: 4, 100000.0: 5, 1000000.0: 6, 1e8: 6}
	for f: float in cas:
		var p := PiecesMois.plan(_flux(f, 0.0), 1, false, _avril)
		var n: int = p["or"].get("n", 0)
		_verifier(n == cas[f], "nombre : %s F → %d pièce(s)" % [Format.nombre(f), cas[f]], str(n))
	var p999 := PiecesMois.plan(_flux(9.99, 9.99), 1, false, _avril)
	_verifier(p999["or"].is_empty() and p999["cuivre"].is_empty() and p999["raison"] == "sous_seuil", "seuil : 9,99 F de revenus et de frais → aucune pièce (sous_seuil)", str(p999))
	var p10 := PiecesMois.plan(_flux(10.0, 10.0), 1, false, _avril)
	_verifier(p10["or"].get("n", 0) == 1 and p10["cuivre"].get("n", 0) == 1 and p10["raison"] == "", "seuil : 10 F de revenus et de frais → 1 pièce d'or et 1 de cuivre", str(p10))
	var p9 := PiecesMois.plan(_flux(9.0, 45.0), 1, false, _avril)
	_verifier(p9["or"].is_empty() and p9["cuivre"].get("n", 0) == 2, "seuil : 9 F de revenus, 45 F de frais → cuivre seul (2 pièces)", str(p9))
	_verifier(PiecesMois.plan({}, 1, false, _avril)["raison"] == "pas_de_flux", "flux vide → raison pas_de_flux")


func _tests_vitesse() -> void:
	var f := _flux(312.0, 45.0)
	var attendus := [[0, false, "pause"], [3, false, "vitesse3"], [1, true, "saut"], [0, true, "saut"], [2, true, "saut"]]
	for a in attendus:
		var p := PiecesMois.plan(f, a[0], a[1], _avril)
		_verifier(p["or"].is_empty() and p["cuivre"].is_empty() and p["lignes"].is_empty() and p["raison"] == a[2],
			"rien à la vitesse %d%s (raison %s)" % [a[0], " pendant le saut" if a[1] else "", a[2]], str(p))
	for v in [1, 2]:
		var p := PiecesMois.plan(f, v, false, _avril)
		_verifier(p["or"].get("n", 0) == 2 and p["cuivre"].get("n", 0) == 2, "pièces à ×%d : 2 d'or (312 F), 2 de cuivre (45 F)" % v, str(p))


func _tests_textes() -> void:
	var nbsp := Format.ESPACE
	var livret := [_ligne("livret", "Livret A", "interets", 312.0, true)]
	var p := PiecesMois.plan(_flux(312.0, 0.0, livret), 1, false, _avril)
	var attendu := "+" + nbsp + "312" + nbsp + "F ce mois-ci\nversés en décembre"
	_verifier(p["or"].get("texte", "") == attendu, "texte (D7) : intérêts du Livret A en avril « + 312 F ce mois-ci » / « versés en décembre »", p["or"].get("texte", ""))
	var pn := PiecesMois.plan(_flux(312.0, 0.0, livret), 1, false, _novembre)
	_verifier(pn["or"].get("texte", "").ends_with("\nversés en décembre"), "texte : en novembre aussi (crédités au 31/12)", pn["or"].get("texte", ""))
	var livret_gros := [_ligne("livret", "Livret A", "interets", 12345.0, true)]
	var pg := PiecesMois.plan(_flux(12345.0, 0.0, livret_gros), 1, false, _avril)
	_verifier(pg["or"].get("texte", "") == "+" + nbsp + "12" + nbsp + "345" + nbsp + "F\nversés en décembre", "texte (D7) : montant long, « ce mois-ci » retiré plutôt que dépasser 20 caractères", pg["or"].get("texte", ""))
	var livret_dec := [_ligne("livret", "Livret A", "interets", 312.0, true)]
	var pd := PiecesMois.plan(_flux(312.0, 0.0, livret_dec), 1, false, _decembre)
	_verifier(pd["or"].get("texte", "") == "+" + nbsp + "312" + nbsp + "F", "texte : en décembre, « + 312 F » seul", pd["or"].get("texte", ""))
	var mixte := [_ligne("livret", "Livret A", "interets", 100.0, true), _ligne("emprunt", "Emprunt d'État", "coupon", 212.0, false)]
	var pm := PiecesMois.plan(_flux(312.0, 0.0, mixte), 1, false, _avril)
	_verifier(pm["or"].get("texte", "") == "+" + nbsp + "100" + nbsp + "F ce mois-ci\nversés en décembre" and pm["lignes"].size() == 1 and pm["or"].get("n", 0) == 2,
		"texte (D13, lot 04) : intérêts et coupon jamais mêlés : « + 100 F ce mois-ci / versés en décembre » et un cartouche pour le coupon ; pièces sur le total", str(pm))
	var mai := [_ligne("livret", "Livret A", "interets", 285.0, true), _ligne("elf", "Elf", "dividende", 120.0), _ligne("sg", "Saint-Gobain", "dividende", 102.0)]
	var pmai := PiecesMois.plan(_flux(507.0, 0.0, mai), 1, false, Dates.lire("1987-05"))
	_verifier(pmai["or"].get("texte", "") == "+" + nbsp + "285" + nbsp + "F ce mois-ci\nversés en décembre" and pmai["lignes"] == ["Elf" + nbsp + ":" + nbsp + "+" + nbsp + "120" + nbsp + "F", "Saint-Gobain" + nbsp + ":\n+" + nbsp + "102" + nbsp + "F"],
		"texte (D13) : mai 1987, « + 285 F ce mois-ci / versés en décembre », « Elf : + 120 F », « Saint-Gobain : » / « + 102 F » (plus de « + 507 F »)", str(pmai))
	var seuls := PiecesMois.plan(_flux(222.0, 0.0, [_ligne("elf", "Elf", "dividende", 120.0), _ligne("sg", "Saint-Gobain", "dividende", 102.0)]), 1, false, Dates.lire("1987-05"))
	_verifier(seuls["or"].get("texte", "x") == "" and seuls["lignes"].size() == 2 and seuls["or"].get("n", 0) == 2, "texte (D13) : dividendes seuls : pas de cartouche total, un par titre", str(seuls))
	var pc := PiecesMois.plan(_flux(0.0, 45.0), 1, false, _avril)
	_verifier(pc["cuivre"].get("texte", "") == Format.MOINS + nbsp + "45" + nbsp + "F de frais", "texte : « − 45 F de frais » (vrai signe moins)", pc["cuivre"].get("texte", ""))
	var gros := PiecesMois.plan(_flux(12345.0, 0.0), 1, false, _avril)
	_verifier(gros["or"].get("texte", "") == "+" + nbsp + "12" + nbsp + "345" + nbsp + "F", "texte : milliers séparés par une espace insécable", gros["or"].get("texte", ""))
	var tous := [p["or"]["texte"], pc["cuivre"]["texte"], gros["or"]["texte"]]
	var sans_fleche := true
	var sans_espace_simple_chiffre := true
	for t: String in tous:
		if t.contains("→"):
			sans_fleche = false
		if t.contains("+ ") or t.contains(" F"):
			sans_espace_simple_chiffre = false
	_verifier(sans_fleche, "texte : aucune « → »")
	_verifier(sans_espace_simple_chiffre, "texte : espaces insécables après « + » et avant « F »")


func _tests_lignes() -> void:
	var nbsp := Format.ESPACE
	var elf := [_ligne("elf", "Elf", "dividende", 840.0)]
	var p := PiecesMois.plan(_flux(840.0, 0.0, elf), 1, false, _avril)
	_verifier(p["lignes"] == ["Elf" + nbsp + ":" + nbsp + "+" + nbsp + "840" + nbsp + "F"], "lignes : dividende « Elf : + 840 F »", str(p["lignes"]))
	var coupon := [_ligne("emprunt", "Emprunt d'État", "coupon", 600.0)]
	var pc := PiecesMois.plan(_flux(600.0, 0.0, coupon), 1, false, _avril)
	_verifier(pc["lignes"].size() == 1 and str(pc["lignes"][0]).begins_with("Emprunt d'État" + nbsp + ":"), "lignes : coupon avec le nom de sa ligne", str(pc["lignes"]))
	var trois := [_ligne("elf", "Elf", "dividende", 840.0), _ligne("sg", "Saint-Gobain", "dividende", 300.0), _ligne("emprunt", "Emprunt d'État", "coupon", 600.0),
		_ligne("livret", "Livret A", "interets", 312.0, true)]
	var p3 := PiecesMois.plan(_flux(2052.0, 0.0, trois), 1, false, _avril)
	_verifier(p3["lignes"].size() == 3 and str(p3["lignes"][0]).begins_with("Elf") and str(p3["lignes"][1]).begins_with("Emprunt") and str(p3["lignes"][2]).begins_with("Saint-Gobain"),
		"lignes (D13, lot 04) : un cartouche par titre versant, les plus gros d'abord (intérêts exclus)", str(p3["lignes"]))
	var interets := [_ligne("livret", "Livret A", "interets", 312.0, true)]
	_verifier(PiecesMois.plan(_flux(312.0, 0.0, interets), 1, false, _avril)["lignes"].is_empty(), "lignes : aucune pour des intérêts seuls")
	var petit := [_ligne("elf", "Elf", "dividende", 8.0)]
	_verifier(PiecesMois.plan(_flux(312.0, 0.0, petit), 1, false, _avril)["lignes"].is_empty(), "lignes : dividende de 8 F (sous le seuil) non montré")
	var euros := PiecesMois.plan({"revenus": 50.0, "frais": 0.0, "lignes": []}, 1, false, Dates.lire("2003-04"))
	_verifier(euros["or"].get("n", 0) == 3 and str(euros["or"].get("texte", "")).ends_with("€"), "après 2002 : montant en euros, seuil et nombre comptés en francs (50 € ≈ 328 F → 3)", str(euros))
	# D7 (lot 03) : nom long sur sa ligne ; jamais plus de 2 lignes de 20 caractères dans un cartouche
	var long := [_ligne("emprunt", "Emprunt d'État", "coupon", 600.0), _ligne("sg", "Saint-Gobain", "dividende", 1234.0)]
	var pl := PiecesMois.plan(_flux(1834.0, 0.0, long), 1, false, _avril)
	_verifier(pl["lignes"] == ["Saint-Gobain" + nbsp + ":\n+" + nbsp + "1" + nbsp + "234" + nbsp + "F", "Emprunt d'État" + nbsp + ":\n+" + nbsp + "600" + nbsp + "F"],
		"lignes (D7) : « Saint-Gobain : » / « + 1 234 F » et « Emprunt d'État : » / « + 600 F » (plus de 20 caractères sur une ligne)", str(pl["lignes"]))
	var tres_long := [_ligne("x", "Fonds commun de placement", "coupon", 600.0)]
	var pt := PiecesMois.plan(_flux(600.0, 0.0, tres_long), 1, false, _avril)
	_verifier(pt["lignes"].size() == 1 and str(pt["lignes"][0]).begins_with("Fonds commun de p…"), "lignes (D7) : nom de plus de 18 caractères raccourci par « … »", str(pt["lignes"]))
	var trop := []
	for f: float in [10.0, 312.0, 9999.0, 12345.0, 123456.0, 1234567.0]:
		for decembre in [true, false]:
			var fl := [_ligne("livret", "Livret A", "interets", f, decembre), _ligne("elf", "Elf", "dividende", f), _ligne("sg", "Saint-Gobain", "dividende", f),
				_ligne("x", "Fonds commun de placement", "coupon", f)]
			var pp := PiecesMois.plan(_flux(f * 4.0, f, fl), 1, false, _avril)
			var cartouches: Array = [pp["or"].get("texte", ""), pp["cuivre"].get("texte", "")] + pp["lignes"]
			for c: String in cartouches:
				var morceaux := c.split("\n")
				if morceaux.size() > 2:
					trop.append(c)
				for m in morceaux:
					if m.length() > PiecesMois.MAX_CAR:
						trop.append(m)
	_verifier(trop.is_empty(), "cartouches (D7) : 2 lignes au plus, 20 caractères au plus, de 10 F à 1,2 MF", ", ".join(trop))
	_verifier(PiecesMois.plan(_flux(0.0, 45.0), 1, false, _avril)["cuivre"]["texte"].length() <= PiecesMois.MAX_CAR, "cartouche cuivre « − 45 F de frais » sur une ligne")


# --- Traces des cartes du foyer (lot 04, 03-V2, D11) : fonction pure et partie réelle --------------------------

const TRACES := preload("res://scripts/ville/traces_foyer.gd")


func _carte(id: String, choix: String) -> Dictionary:
	return {"id": id, "choix": choix}


func _tests_traces() -> void:
	var a85 := Dates.lire("1985-06")
	var a87 := Dates.lire("1987-05")
	var a88 := Dates.lire("1988-03")
	var cas := [
		["cartes éteintes : aucune trace", false, [_carte("C02", "a"), _carte("C10", "a")], a88, false, true, []],
		["C02 « a » : télévision", true, [_carte("C02", "a")], a85, false, false, ["tele"]],
		["C02 « b » : rien", true, [_carte("C02", "b")], a85, false, false, []],
		["C03 « a » : télévision et antenne", true, [_carte("C03", "a")], a85, false, false, ["tele", "antenne"]],
		["C03 « b » : rien", true, [_carte("C03", "b")], a85, false, false, []],
		["C04 (« b ») jusqu'à 12/1986 : poussette", true, [_carte("C04", "b")], a85, false, false, ["poussette"]],
		["C04 jumeaux : poussette double", true, [_carte("C04", "a")], Dates.lire("1986-12"), true, false, ["poussette_double"]],
		["C04 en 1987 : ni poussette ni tricycle", true, [_carte("C04", "a")], a87, false, false, []],
		["C04 dès 01/1988 : tricycle", true, [_carte("C04", "a")], Dates.lire("1988-01"), false, false, ["tricycle"]],
		["C04 jumeaux en 1988 : tricycles", true, [_carte("C04", "b")], a88, true, false, ["tricycles"]],
		["C10 « a » : chien", true, [_carte("C10", "a")], a87, false, false, ["chien"]],
		["C10 « b » : chien aussi", true, [_carte("C10", "b")], a87, false, false, ["chien"]],
		["C07 « a » avant 1988 : pas encore de diplôme", true, [_carte("C07", "a")], Dates.lire("1987-12"), false, false, []],
		["C07 « a » dès 01/1988 : diplôme", true, [_carte("C07", "a")], Dates.lire("1988-01"), false, false, ["diplome"]],
		["C07 « b » : pas de diplôme", true, [_carte("C07", "b")], a88, false, false, []],
		["notification « escargots » : escargot", true, [], a88, false, true, ["escargot"]],
		["tout ensemble, dans l'ordre", true, [_carte("C10", "a"), _carte("C03", "a"), _carte("C07", "a"), _carte("C04", "a")], a88, false, true,
			["tele", "antenne", "tricycle", "chien", "diplome", "escargot"]],
	]
	for c in cas:
		var r: PackedStringArray = TRACES.calculer(c[1], c[2], c[3], c[4], c[5])
		_verifier(Array(r) == c[6], "traces (D11) : " + str(c[0]), str(r))
	# Partie réelle : cartes éteintes (défaut) = aucune trace ; cartes allumées, C03 « a » jouée (fabriquée) = télé + antenne
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(7))
	_verifier(TRACES.de_partie(e).is_empty() and not e.cartes_actives(), "traces (D11) : partie par défaut (cartes éteintes) : aucune trace")
	(e.foyer["jouees"] as Array).append({"id": "C03", "choix": "a"})
	_verifier(TRACES.de_partie(e).is_empty(), "traces (D11) : cartes éteintes, même avec une carte inscrite : aucune trace")
	var c2 := Donnees.config_demo(7)
	c2["cartes"] = true
	var e2 := EtatPartie.new()
	e2.demarrer(c2)
	(e2.foyer["jouees"] as Array).append({"id": "C03", "choix": "a"})
	e2.historique.append({"m": e2.m, "source": "maison", "genre": "notif", "type": "escargots"})
	_verifier(e2.cartes_actives() and Array(TRACES.de_partie(e2)) == ["tele", "antenne", "escargot"], "traces (D11) : partie cartes allumées, C03 « a » et escargots", str(TRACES.de_partie(e2)))
	_verifier(TRACES.de_partie(null).is_empty(), "traces (D11) : partie absente : rien")