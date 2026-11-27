extends Node
## Lot 10d (N2) : « OUVRIR » sur chaque présentation du banquier, puis la vraie fenêtre Banque comme la scène principale
## l'ouvre (ouvrir_banque(r.ouvrir, r.montant)). Avant correction : PEA et SCPI (aucun cours) ouvraient le formulaire
## d'ordre commun : SCRIPT ERROR dans Format.nombre (NaN), que tests.ps1 compte en échec.

var _ko := 0


func _ready() -> void:
	for chapitre in ["1984", "1989"]:
		await _parcourir(chapitre)
	Donnees.regler_chapitre("")
	print("=== test_ordre_banque : %s ===" % ("OK" if _ko == 0 else "%d KO" % _ko))
	get_tree().quit(1 if _ko > 0 else 0)


func _parcourir(chapitre: String) -> void:
	Donnees.regler_chapitre(chapitre)
	var c := Donnees.config_chapitre(chapitre, 7)
	c["banquier"] = true
	c["cartes"] = true
	c["projets"] = true
	c["rue"] = true
	var e := EtatPartie.new()
	e.demarrer(c)
	var vus := []
	var faux := []
	var garde := 0
	while e.fin == "" and garde < 400:
		garde += 1
		var essais := 0
		while not e.modale.is_empty() and essais < 6:
			essais += 1
			if str(e.modale.get("kind", "")) != "banquier":
				e.resolution_auto()
				continue
			var r := e.resoudre_modale("ouvrir")
			if not r.has("ouvrir"):
				if not e.modale.is_empty():
					e.resolution_auto()
				continue
			var pid := str(r["ouvrir"])
			vus.append(pid)
			var pb := PanneauBanque.new()
			add_child(pb)
			pb.construire(e, pid, float(r.get("montant", -1.0)))
			await get_tree().process_frame
			var formulaire := pb.bouton_valider() != null
			if formulaire != Banquier.a_un_ordre(pid):
				faux.append("%s (formulaire %s)" % [pid, formulaire])
			pb.queue_free()
			await get_tree().process_frame
		StrategieTest.jouer_mois(e, false)
		e.avancer()
	_verifier("N2 chapitre %s : %d présentations ouvertes (%s) : formulaire d'ordre prérempli seulement pour les produits qui en ont un" % [chapitre, vus.size(), ", ".join(vus)],
		not vus.is_empty() and faux.is_empty() and (chapitre != "1989" or (vus.has("pea") and vus.has("scpi"))), str(faux))


func _verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
