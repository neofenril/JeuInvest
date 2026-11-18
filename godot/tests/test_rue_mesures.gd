extends SceneTree
## Lot 08b, T3 : mesure du dosage de la rue (docs/27 §2.3) et de l'arc de Jean-Mi. Logique pure, sans nœud.
## Parties : population de référence P-REF (200 graines, StrategieTest.profil_reference) et les 3 modes de test_rue_moteur
## (passif, actif, tout sur Peugeot) sur 40 graines, cartes, projets et rue allumés.
## Imprime par mode une ligne RUE et une ligne JEANMI (étapes vues). Bloquant : CA-R5 (les 5 passages ★ dans 100 % des
## parties, au plus une notification rue ou kiosque par mois, voisins espacés de 2 mois, rien un mois de pause, rang tous les
## 6 mois) et CA-R6 (20 à 30 notifications par partie en moyenne, passages non ★ abandonnés ≤ 3 en moyenne). Non bloquant :
## étape de Jean-Mi vue dans moins de 80 % des parties où il l'a atteinte (CA-R7). Le dosage n'est jamais modifié par ce test.
## Lancer : Godot_console --headless --path godot --script res://tests/test_rue_mesures.gd

const ETOILES := ["V01", "V07", "V09", "V13", "V16"]
const ETAPES := ["attend", "position", "porsche", "liquide", "rembourse"]

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	var jm_atteint := {}
	var jm_vu := {}
	for e in ETAPES:
		jm_atteint[e] = 0
		jm_vu[e] = 0
	var groupes := [{"nom": "P-REF", "n": 200, "mode": "ref"}, {"nom": "passif", "n": 40, "mode": "passif"},
		{"nom": "actif", "n": 40, "mode": "actif"}, {"nom": "peugeot", "n": 40, "mode": "peugeot"}]
	for gr: Dictionary in groupes:
		var m := _mesurer(gr, jm_atteint, jm_vu)
		print("RUE mode=%s parties=%d notifs_rue_kiosque moy=%.1f min=%d max=%d jeanmi moy=%.1f etoiles_livrees=%d/%d abandonnes_non_etoile moy=%.2f max_par_mois=%d ecart_voisin_min=%d mois_pause_violes=%d rang_trop_proche=%d" % [
			gr["nom"], gr["n"], m["moy"], m["min"], m["max"], m["jm_moy"], m["etoiles"], gr["n"], m["aband_moy"], m["max_mois"], m["ecart_voisin"], m["pause"], m["rang_proche"]])
		var nom := str(gr["nom"])
		verifier("CA-R5 (%s) : 5 / 5 passages ★ livrés dans 100 %% des parties" % nom, m["etoiles"] == gr["n"], "%d / %d" % [m["etoiles"], gr["n"]])
		verifier("CA-R5 (%s) : au plus une notification rue ou kiosque par mois" % nom, m["max_mois"] <= 1, "max %d" % m["max_mois"])
		verifier("CA-R5 (%s) : voisins espacés d'au moins 2 mois" % nom, m["ecart_voisin"] >= 2, "min %d" % m["ecart_voisin"])
		verifier("CA-R5 (%s) : aucune notification un mois qui ouvre une interruption avec pause" % nom, m["pause"] == 0, "%d" % m["pause"])
		verifier("CA-R5 (%s) : notification de rang au plus tous les 6 mois" % nom, m["rang_proche"] == 0, "%d" % m["rang_proche"])
		verifier("CA-R6 (%s) : en moyenne 20 à 30 notifications rue + kiosque par partie" % nom, m["moy"] >= 20.0 and m["moy"] <= 30.0, "%.1f" % m["moy"])
		verifier("CA-R6 (%s) : passages non ★ abandonnés <= 3 en moyenne" % nom, m["aband_moy"] <= 3.0, "%.2f" % m["aband_moy"])
	var s := ""
	var faibles: Array = []
	for e in ETAPES:
		var a := int(jm_atteint[e])
		var part := 100.0 * float(jm_vu[e]) / float(a) if a > 0 else 0.0
		s += "%s=%.0f%% (%d/%d) " % [e, part, jm_vu[e], a]
		if a > 0 and part < 80.0:
			faibles.append(e)
	print("JEANMI etapes_vues=%s" % s.strip_edges())
	if not faibles.is_empty():
		print("ALERTE (CA-R7, non bloquant) : étapes de Jean-Mi vues dans moins de 80 %% des parties où il les atteint : %s" % str(faibles))
	StrategieTest.strategie = ""
	StrategieTest.politique_cartes = "epargner"
	StrategieTest.politique_projets = "moins_cher"
	print("")
	print("=== test_rue_mesures : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _config(g: int) -> Dictionary:
	var c := Donnees.config_demo(g)
	c["rue"] = true
	c["cartes"] = true
	c["projets"] = true
	return c


## Joue les parties du groupe et agrège le dosage ; jm_atteint / jm_vu : par étape de Jean-Mi, nombre de parties qui l'atteignent
## et nombre où une notification de Jean-Mi a paru pendant cette étape.
func _mesurer(gr: Dictionary, jm_atteint: Dictionary, jm_vu: Dictionary) -> Dictionary:
	var total := 0
	var mn := 9999
	var mx := 0
	var jm_total := 0
	var etoiles := 0
	var aband := 0
	var max_mois := 0
	var ecart_voisin := 9999
	var pause := 0
	var rang_proche := 0
	var mode := str(gr["mode"])
	for g in range(1, int(gr["n"]) + 1):
		StrategieTest.strategie = "peugeot" if mode == "peugeot" else ""
		StrategieTest.politique_cartes = ["epargner", "depenser", "alterner"][g % 3]
		StrategieTest.politique_projets = ["moins_cher", "milieu", "plus_cher"][g % 3]
		var e := EtatPartie.new()
		var res := e.demarrer(_config(g))
		var profil := StrategieTest.profil_reference(g) if mode == "ref" else {}
		var n_rue := 0
		var n_jm := 0
		var dernier_voisin := -99
		var dernier_rang := -99
		var etapes_atteintes := {}
		var etapes_vues := {}
		var garde := 0
		while true:
			# notifications du mois qui vient d'être entré (res) : compte, espacement, pauses
			var ce_mois := 0
			for n: Dictionary in res.get("notifs", []):
				var t := str(n.get("type", ""))
				if t not in ["voisin", "rang", "kiosque"]:
					continue
				ce_mois += 1
				var ab := e.ab_courant()
				if not (res.get("modale", {}) as Dictionary).is_empty():
					pause += 1
				if t == "voisin":
					ecart_voisin = mini(ecart_voisin, ab - dernier_voisin)
					dernier_voisin = ab
					if str(n.get("qui", "")) == "jeanmi":
						n_jm += 1
						etapes_vues[str(e.jeanmi.get("etape", ""))] = true
				elif t == "rang":
					if ab - dernier_rang < 6:
						rang_proche += 1
					dernier_rang = ab
			n_rue += ce_mois
			max_mois = maxi(max_mois, ce_mois)
			etapes_atteintes[str(e.jeanmi.get("etape", ""))] = true
			if e.fin != "" or garde >= 200:
				break
			garde += 1
			if mode == "ref":
				StrategieTest.jouer_mois_profil(e, profil)
			else:
				StrategieTest.jouer_mois(e, mode != "passif")
				while not e.modale.is_empty():
					e.resolution_auto()
			res = e.avancer()
		total += n_rue
		mn = mini(mn, n_rue)
		mx = maxi(mx, n_rue)
		jm_total += n_jm
		var vus := {}
		for h: Dictionary in e.historique:
			if h["genre"] == "voisin":
				vus[str((h["contenu"] as Dictionary).get("id", ""))] = true
		var tout := true
		for id in ETOILES:
			if not vus.has(id):
				tout = false
		if tout:
			etoiles += 1
		for id in e.quartier["abandonnes"]:
			if not ETOILES.has(str(id)):
				aband += 1
		for et in etapes_atteintes:
			if jm_atteint.has(et):
				jm_atteint[et] += 1
				if etapes_vues.has(et):
					jm_vu[et] += 1
	StrategieTest.strategie = ""
	var n := float(gr["n"])
	return {"moy": float(total) / n, "min": mn, "max": mx, "jm_moy": float(jm_total) / n, "etoiles": etoiles, "aband_moy": float(aband) / n,
		"max_mois": max_mois, "ecart_voisin": ecart_voisin, "pause": pause, "rang_proche": rang_proche}
