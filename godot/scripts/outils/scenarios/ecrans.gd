extends RefCounted
## Étapes de capture : écrans et fenêtres (Mon foyer, banque depuis la rue, pause, panneau « Mon argent »,
## historique, comparaison au Livret A, journal du krach, courrier, fin, fermeture par un clic à côté).

const ETAPES := ["foyer", "marche_banque", "pause", "panneau", "historique", "historique_filtre", "historique_entree", "historique_journal",
	"historique_courrier", "comparaison", "comparaison_info", "krach", "courrier", "fin", "clic_dehors"]

var sc: ScenariosCapture


func jouer(etape: String) -> void:
	var jeu := sc.jeu
	var e: EtatPartie = Partie.etat
	var modales: Modales = jeu.modales
	var hud: Hud = jeu.hud
	var ville: Node2D = jeu.ville
	sc.partir_de_la_rue(etape)
	match etape:
		"foyer", "marche_banque":
			sc.aller_a(Dates.lire("1987-05"), true)
			ville.set("phase", 0.18)
			Partie.changer_vitesse(1)
			await sc.delai(2.6)
			if etape == "foyer":
				jeu.toucher_batiment("maison")
				await sc.delai(0.6)
			else:
				jeu.toucher_batiment("banque")
				await sc.delai(0.8)
		"pause", "panneau":
			sc.aller_a(Dates.lire("1988-01"), true)
			if etape == "panneau":
				Partie.programmer_versement("livret", Produits.f(500.0))
				hud.basculer_panneau(true)
			await sc.delai(1.0)
		"historique", "historique_filtre", "historique_entree", "historique_journal", "historique_courrier":
			await _historique(etape, e, jeu, modales)
		"krach", "courrier":
			sc.aller_a_modale("p1e6", true)
			await sc.attendre_que(func() -> bool: return modales.genre_courant == "journal", 15.0)
			await sc.delai(1.6)
			if etape == "courrier":
				modales.call("_on_choix_journal", "rien")
				Partie.changer_vitesse(3)
				await sc.attendre_que(func() -> bool: return modales.genre_courant == "courrier", 15.0)
				await sc.delai(1.3)
		"comparaison", "comparaison_info":
			sc.aller_a(Dates.lire("1988-06"), true)
			hud.basculer_panneau(true)
			print("Écart Livret A en %s : %s (vous %s, Tata Livret %s)" % [Dates.texte(e.ab_courant()), Format.ecart(e.ecart_livret(), e.ab_courant()),
				Format.montant(e.patrimoine(e.joueur), e.ab_courant()), Format.montant(e.patrimoine(e.temoins["livret"]), e.ab_courant())])
			await sc.delai(1.0)
			if etape == "comparaison_info":
				jeu.expliquer_comparaison()
				await sc.delai(0.8)
		"fin":
			sc.aller_a(Dates.lire("1988-11"), true)
			Partie.changer_vitesse(3)
			await sc.attendre_que(func() -> bool: return modales.genre_courant == "fin", 15.0)
			await sc.delai(3.4)
		"clic_dehors":
			await _clic_dehors(jeu, modales)


## Une partie jouée jusqu'en juin 1988, avec un versement automatique sur la SICAV depuis avril 1986.
func _historique(etape: String, e: EtatPartie, jeu: Node, modales: Modales) -> void:
	sc.aller_a(Dates.lire("1986-04"), true)
	e.programmer_versement("sicav", Produits.f(300.0))
	sc.aller_a(Dates.lire("1988-06"), true)
	jeu.ouvrir_historique("")
	await sc.delai(1.0)
	if etape == "historique_filtre":
		var bf := modales.courant.find_child("Filtre_banque", true, false) as Button
		bf.button_pressed = true   # comme un toucher : le bouton s'allume et la liste se filtre
		await sc.delai(0.6)
	elif etape != "historique":
		var cible := -1
		for h: Dictionary in e.historique_recent(""):
			var ok := false
			match etape:
				"historique_entree":
					ok = h["genre"] == "appel" and h["contenu"].get("heritage", false)
				"historique_journal":
					ok = h["genre"] == "journal"
				"historique_courrier":
					ok = h["genre"] == "courrier"
			if ok:
				cible = int(h["i"])
				break
		modales.historique_defilement = 0
		modales.fermer("ouvrir:%d" % cible)
		await sc.delai(1.6)
	print("Historique : %d entrées (maison %d, banque %d, média %d) ; 5 plus récentes : %s" % [e.historique.size(), e.historique_recent("maison").size(),
		e.historique_recent("banque").size(), e.historique_recent("media").size(), str(e.historique_recent("").slice(0, 5).map(func(h: Dictionary) -> String: return "%s %s" % [Dates.texte_court(e.ab_de(int(h["m"]))), h["titre"]]))])


## Fermeture des pop-ups par un clic à côté (ou pas : journal du krach).
func _clic_dehors(jeu: Node, modales: Modales) -> void:
	sc.aller_a(Dates.lire("1984-03"), true)
	jeu.toucher_batiment("maison")
	await sc.delai(0.6)
	await sc.clic_dehors(Vector2(sc.get_window().size) / 2.0)
	print("Clic dedans · foyer toujours ouvert : %s" % [modales.genre_courant == "info"])
	await sc.clic_dehors()
	print("Clic dehors · foyer (maison) fermé : %s, temps débloqué : %s" % [not modales.ouverte(), not Partie.bloquee])
	jeu.toucher_batiment("media")
	await sc.delai(0.6)
	await sc.clic_dehors()
	print("Clic dehors · nouvelles (média) fermé : %s" % [not modales.ouverte()])
	jeu.toucher_batiment("banque")
	await sc.delai(0.8)
	await sc.clic_dehors(Vector2(6, 6))
	print("Clic dehors · banque fermée : %s, temps débloqué : %s" % [not modales.ouverte(), not Partie.bloquee])
	jeu.ouvrir_menu()
	await sc.delai(0.4)
	await sc.clic_dehors()
	print("Clic dehors · menu fermé : %s" % [not modales.ouverte()])
	sc.aller_a_modale("D02", false)
	await sc.attendre_que(func() -> bool: return modales.genre_courant == "appel", 8.0)
	await sc.delai(1.2)
	await sc.clic_dehors(Vector2(6, 6))
	await sc.delai(0.3)
	print("Clic dehors · carte du banquier fermée : %s (« pas maintenant », PEL présenté : %s)" % [modales.genre_courant != "appel", Banquier.presente(Partie.etat, "pel")])
	sc.aller_a_modale("p1e6", true)
	await sc.attendre_que(func() -> bool: return modales.genre_courant == "journal", 15.0)
	await sc.delai(1.6)
	await sc.clic_dehors(Vector2(6, 6))
	await sc.delai(0.1)
	print("Clic dehors · journal du krach toujours ouvert : %s" % [modales.genre_courant == "journal"])
