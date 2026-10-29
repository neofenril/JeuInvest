extends Node
## Test de l'autoload Partie (boucle du temps, pause sur modale, signaux), dans une vraie scène.
## Lancer : Godot_console.exe --headless --path godot res://tests/test_partie.tscn
## À ×3 (durée lue dans data/rythme.json), on attend 3,5 mois de jeu : 3 mois diffusés, puis la pause
## automatique sur le krach.

var _mois := 0
var _notifs := 0
var _modales := 0
var _ko := 0


func _ready() -> void:
	Partie.mois_passe.connect(func(_r: Dictionary) -> void: _mois += 1)
	Partie.notif_recue.connect(func(_n: Dictionary) -> void: _notifs += 1)
	Partie.modale_ouverte.connect(func(_c: Dictionary) -> void: _modales += 1)
	Partie.nouvelle_partie({"graine_vie": 1, "sans_vie": true, "debut": "1987-08"})
	_verifier("premier mois diffusé", _mois == 1)
	var d3 := Partie.duree_mois_s(3)
	_verifier("durées des mois lues dans rythme.json et décroissantes", Partie.duree_mois_s(1) > Partie.duree_mois_s(2) and Partie.duree_mois_s(2) > d3 and d3 > 0.0, "%s / %s / %s s" % [Partie.duree_mois_s(1), Partie.duree_mois_s(2), d3])
	_verifier("trafic : arrêté en pause, plus rapide en accéléré", Partie.facteur_trafic(0) == 0.0 and Partie.facteur_trafic(3) > Partie.facteur_trafic(2) and Partie.facteur_trafic(2) > Partie.facteur_trafic(1))
	Partie.changer_vitesse(3)
	await get_tree().create_timer(d3 * 0.5).timeout
	Partie.changer_vitesse(0)
	var p_avant := Partie.progression_mois()
	Partie.changer_vitesse(1)
	_verifier("pause et changement de vitesse sans saut de la frise", absf(Partie.progression_mois() - p_avant) < 0.001 and p_avant > 0.3, "%.3f" % p_avant)
	Partie.changer_vitesse(3)
	await get_tree().create_timer(d3 * 3.0).timeout
	# août (départ) + septembre, octobre (krach : pause) => 3 mois, puis plus rien
	_verifier("3 mois à ×3 en 3,5 mois de jeu, puis pause sur la modale du krach", _mois == 3 and _modales == 1 and Partie.vitesse == 0, "mois %d, modales %d, vitesse %d" % [_mois, _modales, Partie.vitesse])
	var r := Partie.resoudre_modale("ecart")
	_verifier("après une modale de marché, le jeu reste en pause", r["choix"] == "ecart" and Partie.vitesse == 0)
	var a := Partie.acheter("sicav", 100.0)
	var d := Partie.deposer_livret(50.0)
	_verifier("actions du joueur via l'autoload", a["ok"] and d["ok"])
	await _test_fenetre_banque_pel()
	print("=== test_partie : %s ===" % ("OK" if _ko == 0 else "%d KO" % _ko))
	get_tree().quit(1 if _ko > 0 else 0)


## Fenêtre Banque réelle (nœuds) : un PEL ouvert à 8,25 % en mars 1984, regardé en décembre 1986 (offre du jour :
## 6 %). Carte, fiche, formulaire d'ordre et réglage du versement : tous les textes donnent le même taux.
func _test_fenetre_banque_pel() -> void:
	Partie.nouvelle_partie(Donnees.config_demo())
	var e := Partie.etat
	e.resoudre_modale("plus_tard")
	e.avancer()
	e.avancer()
	e.banque["presentes"]["D02"] = e.m
	e.ouvrir_pel(1000.0 / 6.55957 * 2.0, 500.0 / 6.55957)
	while e.ab_courant() < Dates.lire("1986-12"):
		e.avancer()
		while not e.modale.is_empty():
			e.resolution_auto()
	var pb := PanneauBanque.new()
	add_child(pb)
	pb.construire(e, "pel", -2.0)
	await get_tree().process_frame
	var textes := _textes(pb)
	textes.append(str(pb.get("_cartes")["pel"].ligne2))
	pb.call("_afficher_ordre", "pel", "a", -1.0)
	await get_tree().process_frame
	textes.append_array(_textes(pb))
	pb.call("_afficher_automatique", "pel")
	await get_tree().process_frame
	textes.append_array(_textes(pb))
	var avec_taux := textes.filter(func(t: String) -> bool: return t.contains("prime d'État ≈") or t.begins_with("≈ "))
	var faux := textes.filter(func(t: String) -> bool: return t.contains("6 %") or t.contains("4,62") or (t.contains("% fixe") and not t.begins_with("≈ ")))
	var ok := avec_taux.size() >= 3
	for t: String in avec_taux:
		if not t.contains("8,25 %"):
			ok = false
	_verifier("fenêtre Banque : le PEL affiche 8,25 % partout (carte, fiche, ordre), jamais l'offre du jour", ok and faux.is_empty(), str(avec_taux) + (" FAUX : " + str(faux) if not faux.is_empty() else ""))
	pb.queue_free()


func _textes(n: Node) -> Array:
	var out := []
	for c in n.find_children("*", "Label", true, false):
		out.append((c as Label).text)
	for c in n.find_children("*", "Button", true, false):
		out.append((c as Button).text)
	return out


func _verifier(nom: String, ok: bool, detail := "") -> void:
	print(("OK  " if ok else "KO  ") + nom + ("  [" + detail + "]" if detail != "" else ""))
	if not ok:
		_ko += 1
