extends Node
## Lot 10a-moteur : actions PEA de l'autoload Partie (acheter / vendre avec enveloppe, verser_pea, retirer_pea avant et après 5 ans).

var _ok := 0
var _ko := 0


func _ready() -> void:
	Partie.sauvegarde_auto = false
	var c := Donnees.config_demo(5)
	c["debut"] = "1992-07"
	c["fin"] = "1993-12"
	c.erase("chapitre")
	c["sans_vie"] = true
	c["banquier"] = false
	c["rue"] = false
	Partie.nouvelle_partie(c)
	var e := Partie.etat
	e.joueur.cc = Produits.f(3000000.0)
	verifier("Partie.ouvrir_pea ; Partie.verser_pea plafonné à 600 000 F", Partie.ouvrir_pea() and Partie.verser_pea(Produits.f(700000.0))["ok"]
		and absf(float(e.joueur.pea["verse"]) - Produits.f(600000.0)) < 0.01 and not Partie.verser_pea(100.0)["ok"])
	verifier("Partie.acheter(enveloppe=pea) : éligible oui (elf), non éligible refusé (sicav_monetaire)", Partie.acheter("elf", Produits.f(20000.0), "pea")["ok"]
		and e.enveloppe("elf") == "pea" and not Partie.acheter("sicav_monetaire", 1000.0, "pea")["ok"])
	verifier("Partie.vendre(enveloppe=pea) : ligne soldée dans l'enveloppe", Partie.vendre("elf", 0.0, true, "pea")["ok"] and e.enveloppe("elf") == "")
	var cc := e.joueur.cc
	var r := Partie.retirer_pea(Produits.f(1000.0))
	verifier("Partie.retirer_pea avant 5 ans = clôture du plan", r["ok"] and r["cloture"] and e.joueur.pea.is_empty() and e.joueur.cc > cc)
	Partie.ouvrir_pea()
	Partie.verser_pea(Produits.f(10000.0))
	e.joueur.pea["ouvert_m"] = e.m - 61
	var r2 := Partie.retirer_pea(Produits.f(1000.0))
	verifier("Partie.retirer_pea après 5 ans : retrait libre, le plan continue", r2["ok"] and not r2["cloture"] and not e.joueur.pea.is_empty())
	print("")
	print("=== test_partie_pea : %d OK, %d KO ===" % [_ok, _ko])
	get_tree().quit(1 if _ko > 0 else 0)


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])