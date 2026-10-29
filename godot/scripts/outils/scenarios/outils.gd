extends RefCounted
## Étapes de capture : vérifications techniques (polices, F10, partie intégrale, raccourcis de test).

const ETAPES := ["polices", "f10", "integrale", "raccourcis"]

var sc: ScenariosCapture


func jouer(etape: String) -> void:
	var jeu := sc.jeu
	var hud: Hud = jeu.hud
	sc.partir_de_la_rue(etape)
	match etape:
		"polices":
			_verifier_polices()
		"integrale":
			await _integrale(jeu)
		"f10":
			var fen := sc.get_window()
			print("F10 avant : fenêtre %s, zone logique %s, compact %s" % [fen.size, Ecran.taille(), Ecran.compact()])
			for i in 2:
				var ev := InputEventKey.new()
				ev.keycode = KEY_F10
				ev.pressed = true
				Input.parse_input_event(ev)
				await sc.delai(0.6)
				print("F10 n° %d : fenêtre %s, facteur %s, zone logique %s, compact %s, panneau visible %s" % [
					i + 1, fen.size, fen.content_scale_factor, Ecran.taille(), Ecran.compact(), hud.panneau.visible])
		"raccourcis":
			await _raccourcis(jeu)


## Toute la démo à ×3, réponses automatiques par l'interface : présentations (une sur deux ouverte, avec un
## achat), banque, journal, courrier, jusqu'à la fin. Vérifie l'enchaînement complet sans erreur.
func _integrale(jeu: Node) -> void:
	var modales: Modales = jeu.modales
	Partie.changer_vitesse(3)
	var vus := {}
	var n_appels := 0
	var t0 := Time.get_ticks_msec()
	while modales.genre_courant != "fin" and Time.get_ticks_msec() - t0 < 330000:
		await sc.delai(0.3)
		var g := modales.genre_courant
		if g == "" or not modales.ouverte():
			if not jeu.sequences.occupe and Partie.vitesse != 3 and Partie.etat.fin == "" and Partie.etat.modale.is_empty():
				Partie.changer_vitesse(3)
			continue
		vus[g] = int(vus.get(g, 0)) + 1
		await sc.delai(1.0)
		match g:
			"appel":
				n_appels += 1
				if Partie.etat.modale.get("id", "") == "D08":
					modales.fermer("compris")
				else:
					modales.fermer("ouvrir" if n_appels % 2 == 1 else "plus_tard")
			"banque":
				var pb: PanneauBanque = modales.banque
				if pb.get("_b_ok") != null and is_instance_valid(pb.get("_b_ok")) and pb.get("_droite").is_ancestor_of(pb.get("_b_ok")):
					pb.call("_part", 0.25)
					pb.call("_confirmer")
					await sc.delai(2.6)
				pb.fermer_demande.emit()
			"journal":
				modales.call("_on_choix_journal", "rien")
			"courrier":
				modales.fermer(str(Partie.etat.contenu_modale()["choix"][0]["id"]))
			"info", "confirmer", "menu":
				modales.fermer("fermer")
	var e := Partie.etat
	print("Intégrale : modales vues %s, fin = %s, mois = %s, patrimoine = %s, interruptions = %d, frais = %s, durée %.0f s à ×3" % [vus, e.fin, Dates.texte(e.ab_courant()),
		Format.montant(e.patrimoine(e.joueur), e.ab_courant()), int(e.banque.get("interruptions", 0)), Format.montant(e.frais_payes(), e.ab_courant()), (Time.get_ticks_msec() - t0) / 1000.0])


## Raccourcis de test (lot 01) : en mars 1984, de vrais événements d'entrée (clavier, clic sur la date du HUD).
## Avec raccourcis_test=vrai : F8 et le triple toucher sautent au moment suivant, F6 fait naître un enfant,
## F10 bascule le format. Version du joueur (exe, APK, ou « -- --joueur ») : rien de tout cela. Les touches
## de jeu (2, Espace, M, H) marchent dans les deux cas.
func _raccourcis(jeu: Node) -> void:
	var modales: Modales = jeu.modales
	var hud: Hud = jeu.hud
	sc.aller_a(Dates.lire("1984-03"), true)
	await sc.delai(1.0)
	var actif := Reglages.raccourcis_test()
	print("Raccourcis · raccourcis_test=%s" % ("vrai" if actif else "faux"))
	# Touches de jeu
	await sc.touche(KEY_2)
	var v2 := Partie.vitesse
	await sc.touche(KEY_SPACE)
	var v_pause := Partie.vitesse
	await sc.touche(KEY_M)
	await sc.delai(0.8)
	var banque_ouverte := modales.genre_courant == "banque"
	if banque_ouverte:
		modales.banque.fermer_demande.emit()
	await sc.delai(0.6)
	await sc.touche(KEY_H)
	await sc.delai(0.8)
	var histo_ouvert := modales.genre_courant == "historique"
	if histo_ouvert:
		modales.fermer("fermer")
	await sc.delai(0.6)
	Partie.changer_vitesse(0)
	print("Raccourcis · touches de jeu : 2 → vitesse %d ; Espace → vitesse %d ; M → banque ouverte %s ; H → historique ouvert %s ; mois %s" % [
		v2, v_pause, banque_ouverte, histo_ouvert, Dates.texte(Partie.etat.ab_courant())])
	# F8 : moment suivant
	var avant := Dates.texte(Partie.etat.ab_courant())
	await sc.touche(KEY_F8)
	await sc.delai(0.3)
	print("Raccourcis · F8 : %s → %s" % [avant, Dates.texte(Partie.etat.ab_courant())])
	await _degager(jeu)
	# Triple toucher sur la date du HUD (trois clics en moins de 0,7 s)
	avant = Dates.texte(Partie.etat.ab_courant())
	var pos := sc.position_fenetre(hud.date)
	for i in 3:
		await sc.clic_dehors(pos)
	await sc.delai(0.3)
	print("Raccourcis · triple toucher (fenêtre %s) : %s → %s" % [pos.round(), avant, Dates.texte(Partie.etat.ab_courant())])
	await _degager(jeu)
	# F6 : naissance
	var enfants := Partie.etat.enfants
	await sc.touche(KEY_F6)
	await sc.delai(0.3)
	var naissance: bool = not Partie.etat.modale.is_empty() and Partie.etat.contenu_modale().get("effet", "") == "naissance"
	print("Raccourcis · F6 : enfants %d → %d (carte de naissance : %s)" % [enfants, Partie.etat.enfants, naissance])
	# F10 : format téléphone, puis retour au format PC
	var fen := sc.get_window()
	var format_avant := "téléphone" if Ecran.telephone_simule else "PC"
	var taille_avant := fen.size
	await sc.touche(KEY_F10)
	await sc.delai(0.6)
	var format_apres := "téléphone" if Ecran.telephone_simule else "PC"
	print("Raccourcis · F10 : format %s → %s (fenêtre %s → %s)" % [format_avant, format_apres, taille_avant, fen.size])
	if Ecran.telephone_simule:
		await sc.touche(KEY_F10)
		await sc.delai(0.6)
	await _degager(jeu)
	print("Raccourcis · bilan : raccourcis_test=%s ; mois final %s ; enfants %d ; format %s" % ["vrai" if actif else "faux",
		Dates.texte(Partie.etat.ab_courant()), Partie.etat.enfants, "téléphone" if Ecran.telephone_simule else "PC"])


## Ferme ce qu'un raccourci a ouvert (carte du banquier, courrier, journal…) et remet le temps en pause.
func _degager(jeu: Node) -> void:
	var modales: Modales = jeu.modales
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 15000:
		await sc.delai(0.3)
		if not modales.ouverte():
			if not jeu.sequences.occupe and Partie.etat.modale.is_empty():
				break
			continue
		await sc.delai(0.5)
		match modales.genre_courant:
			"appel":
				modales.fermer("plus_tard")
			"journal":
				modales.call("_on_choix_journal", "rien")
			"courrier":
				modales.fermer(str(Partie.etat.contenu_modale()["choix"][0]["id"]))
			"banque":
				modales.banque.fermer_demande.emit()
			_:
				modales.fermer("fermer")
	Partie.changer_vitesse(0)


## Vérifie que les chiffres de Bahnschrift sont à chasse fixe (tnum) : tous les chiffres ont la même avance.
func _verifier_polices() -> void:
	var f := Style.chiffres()
	var largeurs := []
	for ch in "0123456789":
		largeurs.append(snappedf(f.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, 48).x, 0.01))
	var base := (f as FontVariation).base_font as SystemFont
	var sans := []
	for ch in "0123456789":
		sans.append(snappedf(base.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, 48).x, 0.01))
	print("Police des chiffres : ", base.get_font_name(), " (", base.get_font_style_name(), ")")
	print("Avances avec tnum : ", largeurs)
	print("Avances sans tnum : ", sans)
	print("Chasse fixe : ", "OUI" if largeurs.min() == largeurs.max() else "NON")
	var polices := {"ui": Style.ui(), "manchette": Style.manchette(), "titre_journal": Style.titre_journal(),
		"journal": Style.journal(), "led": Style.led()}
	for nom in polices:
		var p: Font = polices[nom]
		print("Police %s : %s" % [nom, p.get_font_name()])
