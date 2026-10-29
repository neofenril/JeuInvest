extends RefCounted
## Étapes de capture : écran titre, « Jouer », sauvegarde à la fermeture et reprise.
## (Pas de départ dans la rue : ces étapes partent de l'écran titre.)

const ETAPES := ["titre", "titre_continuer", "titre_confirmer", "jouer", "sauver_fermer", "reprise"]

var sc: ScenariosCapture


func jouer(etape: String) -> void:
	var jeu := sc.jeu
	var e: EtatPartie = Partie.etat
	var modales: Modales = jeu.modales
	match etape:
		"titre":
			await sc.delai(3.0)
		"titre_continuer", "titre_confirmer":
			# Une partie sauvegardée en mars 1986 : l'écran titre propose « Continuer »
			sc.aller_a(Dates.lire("1986-03"), true)
			Partie.sauvegarde_auto = true
			Partie.sauvegarder()
			Partie.sauvegarde_auto = false
			jeu.reprendre(Sauvegarde.lire(Partie.chemin_sauvegarde))
			jeu.maj_titre()
			await sc.delai(3.0)
			if etape == "titre_confirmer":
				jeu.demander_nouvelle_partie()
				await sc.delai(0.8)
		"jouer":
			await sc.delai(2.6)
			jeu.jouer()
			await sc.delai(2.0)
		"sauver_fermer":
			# 1er lancement : on joue jusqu'à la présentation du PEL, puis on ferme la fenêtre pendant la carte
			e.resolution_auto()
			jeu.demarrer_direct(0)
			sc.aller_a_modale("D02", false)
			await sc.attendre_que(func() -> bool: return modales.genre_courant == "appel", 8.0)
			await sc.delai(1.5)
			jeu.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
			var d := Sauvegarde.lire(Partie.chemin_sauvegarde)
			print("Fermeture : sauvegarde %s, %s, modale en attente %s, patrimoine %s" % ["écrite" if not d.is_empty() else "ABSENTE",
				d.get("resume", {}).get("date", "?"), d.get("etat", {}).get("modale", {}).get("id", "aucune"), Format.montant(float(d.get("resume", {}).get("patrimoine", 0.0)), e.ab_courant())])
		"reprise":
			# 2e lancement : l'écran titre propose « Continuer » ; la carte du PEL est rouverte à l'identique
			await sc.delai(2.5)
			var titre: EcranTitre = jeu.titre
			print("Titre : bouton %s, %s" % [titre.bouton_jouer.text, titre.l_reprise.text])
			jeu.jouer()
			await sc.attendre_que(func() -> bool: return modales.genre_courant == "appel", 8.0)
			await sc.delai(1.8)
			print("Reprise : %s, modale %s, cc %s" % [Dates.texte(Partie.etat.ab_courant()), Partie.etat.modale.get("id", "aucune"), Format.montant(Partie.etat.joueur.cc, Partie.etat.ab_courant())])
