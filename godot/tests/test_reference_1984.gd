extends SceneTree
## Lot 09-L, L0 / CA-L1 : non-régression au bit près de 1984-1988, figée AVANT la migration vers les chapitres
## (état de main après le lot 08b). Ce test appelle Donnees.config_demo, qui reste un alias pour toujours ; ses valeurs
## attendues (REFERENCE ci-dessous) ne doivent plus jamais changer pendant le lot 09.
## Chaque partie est résumée par une ligne : patrimoine final (8 décimales, euros internes), frais, impôts, nombre
## d'interruptions, titre, rang du joueur dans le classement final, nombre d'entrées d'historique et empreinte md5 de la
## suite des textes de l'historique.
## Régénérer (seulement si un changement de règle est voulu et validé) :
##   Godot_console --headless --path godot --script res://tests/test_reference_1984.gd -- --figer

const REFERENCE := {
	"integrale_g7_actif": "fin=fin patrimoine=26242.45879351 frais=132.64355118 impots=10.46605823 interruptions=11 titre=apprenti rang=2 historique=34 md5=9a56551223a515d5ee4ae08e55f08e39",
	"integrale_g7_passif": "fin=fin patrimoine=22205.06363415 frais=0.00000000 impots=0.00000000 interruptions=11 titre=neveu_matelas rang=3 historique=25 md5=32ef5c32838274d7b5a931ef9828df9b",
	"tout_allume_g7_actif_alterner": "fin=fin patrimoine=17406.22626259 frais=119.21486975 impots=17.58231861 interruptions=27 titre=bon_pere rang=2 historique=78 md5=279cd4b9b77fdac90d090893bc43b152",
	"tout_allume_g7_passif_depenser": "fin=fin patrimoine=10664.67302928 frais=0.00000000 impots=0.00000000 interruptions=26 titre=escargots rang=4 historique=68 md5=5a0c49ba6d0742248057cf80b8cb1a26",
	"tout_peugeot_g7": "fin=fin patrimoine=33220.89197550 frais=363.62366541 impots=193.22729996 interruptions=27 titre=apprenti rang=1 historique=73 md5=d7f0d15829060c61fff8dfb36add81af",
	"profil_bon_pere_g7": "fin=fin patrimoine=16864.02192955 frais=288.72760741 impots=261.26583987 interruptions=27 titre=bon_pere rang=2 historique=74 md5=6c6a79a9abc0c45f60197df4e5333cf1",
	"profil_golden_boy_g7": "fin=fin patrimoine=20745.72727897 frais=491.78599433 impots=46.21831483 interruptions=26 titre=golden_boy rang=2 historique=72 md5=feca2014128e8e0db4bff433485fa14b",
	"profil_escargots_g7": "fin=fin patrimoine=14647.00163974 frais=0.00000000 impots=0.00000000 interruptions=26 titre=escargots rang=3 historique=67 md5=575fb0ab922304f179ef0391ea59e766",
	"profil_fourmi_g7": "fin=fin patrimoine=21426.75972760 frais=0.00000000 impots=0.00000000 interruptions=26 titre=fourmi rang=3 historique=70 md5=5f39d932908f9676368d4d6301e630b1",
	"profil_cigale_g7": "fin=fin patrimoine=14365.68190511 frais=0.00000000 impots=0.00000000 interruptions=26 titre=cigale rang=3 historique=68 md5=ff8d67780547e64436f203384dfc8644",
	"profil_marin_g7": "fin=fin patrimoine=20428.07360492 frais=325.85764530 impots=0.00000000 interruptions=26 titre=marin rang=2 historique=72 md5=df53b9f3891b1a6e5039481672bf08d2",
	"profil_neveu_matelas_g7": "fin=fin patrimoine=13911.83709643 frais=0.00000000 impots=0.00000000 interruptions=26 titre=neveu_matelas rang=3 historique=70 md5=d394b12ceccb7702e492965cdc845e6d",
	"profil_ecureuil_g7": "fin=fin patrimoine=15871.09110855 frais=0.00000000 impots=0.00000000 interruptions=26 titre=ecureuil rang=3 historique=68 md5=4361cf9059671b3156c4a17f1ebce941",
	"profil_apprenti_g7": "fin=fin patrimoine=19057.19176822 frais=121.54247422 impots=0.00000000 interruptions=26 titre=apprenti rang=2 historique=69 md5=e47c4afb130d8cb2ad5ee85b6b5baebf",
	"pref_g01": "fin=fin patrimoine=12989.06313624 frais=76.98719809 impots=27.11460530 interruptions=27 titre=fourmi rang=2 historique=76 md5=bb87e88c6081a3d8533f3af841f3527f",
	"pref_g02": "fin=fin patrimoine=14713.21732221 frais=108.78650203 impots=72.21593711 interruptions=26 titre=apprenti rang=2 historique=73 md5=1385218a386047cad22569f577570903",
	"pref_g03": "fin=fin patrimoine=17602.51850253 frais=105.76423801 impots=72.99939913 interruptions=27 titre=bon_pere rang=2 historique=75 md5=cc51721d7746790eea1bae5da4a9c9dd",
	"pref_g04": "fin=fin patrimoine=12870.97758596 frais=397.70564463 impots=51.81853630 interruptions=25 titre=marin rang=2 historique=68 md5=9b8f1b1cab114718a881743f05fc4c2d",
	"pref_g05": "fin=fin patrimoine=15113.91745735 frais=217.66400054 impots=0.00000000 interruptions=26 titre=marin rang=2 historique=76 md5=57a334e26d7677bf75eb29b9c263d436",
	"pref_g06": "fin=fin patrimoine=17084.91869957 frais=480.60326859 impots=0.00000000 interruptions=27 titre=bon_pere rang=2 historique=75 md5=42796ab32375ed5fcdb9d66f7ce744e4",
	"pref_g07": "fin=fin patrimoine=12688.05827619 frais=0.00000000 impots=0.00000000 interruptions=27 titre=ecureuil rang=3 historique=71 md5=7993235eaa9b6097cacbed9a4f23ad04",
	"pref_g08": "fin=fin patrimoine=21539.46711335 frais=73.42678330 impots=30.27699671 interruptions=27 titre=apprenti rang=2 historique=76 md5=fc680b451c252b158e66d947a7ec70b3",
	"pref_g09": "fin=fin patrimoine=12184.16641937 frais=129.57828973 impots=0.00000000 interruptions=27 titre=fourmi rang=2 historique=72 md5=0afc8eef25bba39e97737f146c029b24",
	"pref_g10": "fin=fin patrimoine=8491.85751670 frais=112.47450333 impots=12.95384116 interruptions=26 titre=fourmi rang=3 historique=73 md5=f1f49d661851dadbf442f4a2cbf94b60",
	"pref_g11": "fin=fin patrimoine=17717.34362206 frais=0.00000000 impots=0.00000000 interruptions=27 titre=escargots rang=3 historique=73 md5=b0fc0b790fa3ed0213dae57701c1f83d",
	"pref_g12": "fin=fin patrimoine=14461.44477988 frais=110.82218441 impots=10.79478402 interruptions=27 titre=golden_boy rang=2 historique=73 md5=d8420632645e2d635d0d1a248bce26f0",
	"pref_g13": "fin=fin patrimoine=25657.16950328 frais=552.57922851 impots=178.03478386 interruptions=26 titre=fourmi rang=2 historique=72 md5=6f9b9bfb30d28d30bef80ad6e941c381",
	"pref_g14": "fin=fin patrimoine=16230.16446437 frais=0.00000000 impots=0.00000000 interruptions=26 titre=ecureuil rang=3 historique=73 md5=b918ab73b2d809dbd8195498788a1ebc",
	"pref_g15": "fin=fin patrimoine=11317.04897830 frais=0.00000000 impots=0.00000000 interruptions=26 titre=escargots rang=4 historique=72 md5=69683c7cace0ca8db9e9bcbb0a1ae883",
	"pref_g16": "fin=fin patrimoine=11555.25909493 frais=55.34119125 impots=20.53117077 interruptions=26 titre=escargots rang=4 historique=72 md5=1611c6f1e887fb30814a3530b8806a66",
	"pref_g17": "fin=fin patrimoine=14580.74147251 frais=0.00000000 impots=0.00000000 interruptions=25 titre=neveu_matelas rang=3 historique=70 md5=a482337848072394fb0d58cfb82d750f",
	"pref_g18": "fin=fin patrimoine=15692.56362781 frais=0.00000000 impots=0.00000000 interruptions=25 titre=fourmi rang=3 historique=71 md5=cd9c2bbcd1c4e77bc43f4f80c42a6522",
	"pref_g19": "fin=fin patrimoine=21698.70654381 frais=89.40729723 impots=62.61616470 interruptions=27 titre=fourmi rang=2 historique=73 md5=907dd863143522ecdf72b3c30ef87c29",
	"pref_g20": "fin=fin patrimoine=20311.37616290 frais=226.06049692 impots=0.00000000 interruptions=27 titre=apprenti rang=2 historique=72 md5=37f71a79be13981beb6cbfdb6cc2db5b",
}

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	var figer := OS.get_cmdline_user_args().has("--figer")
	var lignes := _toutes_les_parties()
	if figer:
		print("const REFERENCE := {")
		for nom: String in lignes:
			print("\t\"%s\": \"%s\"," % [nom, lignes[nom]])
		print("}")
	else:
		verifier("La table de référence couvre toutes les parties (%d)" % lignes.size(), REFERENCE.size() == lignes.size(), "%d attendues" % REFERENCE.size())
		for nom: String in lignes:
			verifier("1984-1988 au bit près : %s" % nom, str(REFERENCE.get(nom, "")) == lignes[nom], "obtenu : %s / attendu : %s" % [lignes[nom], str(REFERENCE.get(nom, "(absent)"))])
	_remettre_strategie()
	print("")
	print("=== test_reference_1984 : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom)
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _remettre_strategie() -> void:
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "moins_cher"
	StrategieTest.politique_echeance = "auto"
	StrategieTest.strategie = ""


func _toutes_les_parties() -> Dictionary:
	var out := {}
	# Mois par mois, avec les stratégies de base (cartes, projets et rue éteints, comme le test d'origine).
	out["integrale_g7_actif"] = _resume(_mois_par_mois(7, true, false, "epargner", ""))
	out["integrale_g7_passif"] = _resume(_mois_par_mois(7, false, false, "epargner", ""))
	# Cartes, projets et rue allumés.
	out["tout_allume_g7_actif_alterner"] = _resume(_mois_par_mois(7, true, true, "alterner", ""))
	out["tout_allume_g7_passif_depenser"] = _resume(_mois_par_mois(7, false, true, "depenser", ""))
	out["tout_peugeot_g7"] = _resume(_mois_par_mois(7, true, true, "alterner", "peugeot"))
	# Les 9 profils de titres (cartes, projets, rue allumés).
	for pid: String in StrategieTest.PROFILS_TITRES:
		out["profil_%s_g7" % pid] = _resume(_profil(7, StrategieTest.PROFILS_TITRES[pid]))
	# 20 parties de la population de référence.
	for g in range(1, 21):
		out["pref_g%02d" % g] = _resume(_profil(g, StrategieTest.profil_reference(g)))
	return out


func _mois_par_mois(g: int, actif: bool, tout: bool, cartes: String, strategie: String) -> EtatPartie:
	StrategieTest.politique_cartes = cartes
	StrategieTest.politique_projets = "moins_cher"
	StrategieTest.politique_echeance = "auto"
	StrategieTest.strategie = strategie
	var cfg := Donnees.config_demo(g)
	if tout:
		cfg["cartes"] = true
		cfg["projets"] = true
		cfg["rue"] = true
	var e := EtatPartie.new()
	e.demarrer(cfg)
	var garde := 0
	while e.fin == "" and garde < 400:
		garde += 1
		StrategieTest.jouer_mois(e, actif)
		if not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
	_remettre_strategie()
	return e


func _profil(g: int, profil: Dictionary) -> EtatPartie:
	var cfg := Donnees.config_demo(g)
	cfg["cartes"] = true
	cfg["projets"] = true
	cfg["rue"] = true
	var e := EtatPartie.new()
	e.demarrer(cfg)
	StrategieTest.jouer_partie_profil(e, profil)
	return e


func _resume(e: EtatPartie) -> String:
	var b := Bilan.calculer(e)
	var rang := 0
	for i in (b["classement"] as Array).size():
		if str(b["classement"][i]["id"]) == "vous":
			rang = i + 1
	var titre := str((b["titre"] as Dictionary).get("id", "-"))
	var textes := ""
	for h: Dictionary in e.historique:
		textes += "%d|%s|%s|%s\n" % [int(h.get("m", 0)), str(h.get("type", "")), str(h.get("titre", "")), str(h.get("resume", ""))]
	return "fin=%s patrimoine=%.8f frais=%.8f impots=%.8f interruptions=%d titre=%s rang=%d historique=%d md5=%s" % [
		e.fin, e.patrimoine(e.joueur), float(e.stats["frais"]), float(e.stats["impots"]),
		(e.banque["interruptions_liste"] as Array).size(), titre, rang, e.historique.size(), textes.md5_text()]
