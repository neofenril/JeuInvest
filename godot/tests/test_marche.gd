extends SceneTree
## Lot 10a-moteur, CA-M2 : marché prolongé jusqu'en 12/1993.
## - 1978-01 à 1988-12 : cours de l'indice et de chaque titre identiques au bit près à ceux de main (empreinte md5 des
##   133 cases, décembre 1977 compris, relevée sur main avant la prolongation) ;
## - 1989-1993 : fins d'année = series.json (A), ancrages de docs/37 §3 atteints, BNP disponible dès 10/1993 à 240 F.

const MD5_MAIN := {
	"indice": "d4e811692985bc3913eabe68cd27c131", "elf": "871c757f03d2bab81b58a3340aa43478",
	"loreal": "e4b950df754f4f35b87b5820e2364611", "peugeot": "3ad7d25b13e63b128b986a07e00217eb",
	"saintgobain": "7deffeadac230d09f2ca8169a28f5b2d", "sicav": "624dff030d169de649fd0e9b0b6d3492",
}

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var mk := Marche.pour_periode("P1")
	var identiques := true
	for id: String in MD5_MAIN:
		var s: PackedFloat64Array = mk.indice if id == "indice" else mk.prix[id]
		var h := s.slice(0, 133).to_byte_array().hex_encode().md5_text()
		var egal: bool = h == MD5_MAIN[id]
		identiques = identiques and egal
		verifier("CA-M2 : %s, 1978-01 à 1988-12, identique à main au bit près" % id, egal, "md5 %s" % h)
	print("MARCHE identiques=%d per 132 mois" % (1 if identiques else 0))
	verifier("Marche P1 : fin 1993 (193 cases)", mk.n_cases == 193 and mk.nb_mois() == 192)
	var annuel: Dictionary = Donnees.series()["annuel"]
	var ok_fins := true
	for y in range(1989, 1994):
		var k := Dates.ab(y, 12) - mk.ab0
		var attendu := float(annuel[str(y)][0])
		if absf(mk.indice[k] - attendu) > 0.01:
			ok_fins = false
	verifier("1989-1993 : l'indice de fin d'année = series.json (A)", ok_fins)
	var anc_ok := true
	for a: Array in mk.periode["ancragesIndice"]:
		var k := Dates.lire(a[0]) - mk.ab0
		if absf(mk.indice[k] - float(a[1])) > 0.01 * float(a[1]) / 100.0:
			anc_ok = false
	verifier("Tous les ancrages mensuels de l'indice (dont docs/37 §3) sont atteints", anc_ok)
	var a_1990_08 := mk.valeur_indice(Dates.lire("1990-08") - mk.ab_debut)
	var a_1990_09 := mk.valeur_indice(Dates.lire("1990-09") - mk.ab_debut)
	verifier("Fins de mois du Golfe : 1 640 (08/1990) et 1 472 (09/1990)", absf(a_1990_08 - 1640.0) < 1.0 and absf(a_1990_09 - 1472.0) < 1.0)
	var bnp: PackedFloat64Array = mk.prix["bnp"]
	var k_oct := Dates.lire("1993-10") - mk.ab0
	var avant_nan := true
	for k in range(0, k_oct):
		if not is_nan(bnp[k]):
			avant_nan = false
	verifier("BNP : pas de cours avant 10/1993, 240 F en 10/1993, environ 290 F en 12/1993",
		avant_nan and absf(bnp[k_oct] - Format.vers_euros(240.0, "F")) < 0.01 and absf(bnp[k_oct + 2] - Format.vers_euros(290.0, "F")) < 0.01)
	verifier("BNP : disponible à partir de 10/1993 seulement", not mk.disponible("bnp", Dates.lire("1993-09")) and mk.disponible("bnp", Dates.lire("1993-10")))
	var sain := true
	for id: String in ["elf", "loreal", "peugeot", "saintgobain", "sicav"]:
		var s: PackedFloat64Array = mk.prix[id]
		for k in range(Dates.lire("1989-01") - mk.ab0, 193):
			if is_nan(s[k]) or s[k] <= 0.0:
				sain = false
	verifier("Cours de 1989 à 1993 sains (non nuls) pour les 5 titres et la SICAV", sain)
	# Dividende nul implicite : BNP ne verse rien en 1993, verse en 1994 ; Peugeot inchangé
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(3))
	verifier("Dividende nul implicite : BNP nul en 1993 (disponible après mai), versant en 1994 ; Saint-Gobain 1987 versant",
		e.dividende_nul("bnp", 1993) and not e.dividende_nul("bnp", 1994) and not e.dividende_nul("saintgobain", 1987))
	print("")
	print("=== test_marche : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
