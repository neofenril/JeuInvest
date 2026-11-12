extends RefCounted
## Étapes de capture : la banque (cartes du banquier, héritage, carnet, ordres, frais, relevé, versements automatiques).

const ETAPES := ["presentation_livret", "presentation_livret_plus", "presentation_av", "presentation_sicav", "presentation_emprunt",
	"heritage", "carnet", "banque_ordre", "f01", "releve", "releve_notif", "carnet_pel", "automatique", "automatique_pel",
	"fiche_dividendes", "fiche_dividendes_avant"]

var sc: ScenariosCapture


func jouer(etape: String) -> void:
	var jeu := sc.jeu
	var e: EtatPartie = Partie.etat
	var modales: Modales = jeu.modales
	var hud: Hud = jeu.hud
	sc.partir_de_la_rue(etape)
	match etape:
		"presentation_livret", "presentation_livret_plus":
			await sc.attendre_que(func() -> bool: return modales.genre_courant == "appel", 8.0)
			await sc.delai(1.8)
			if etape == "presentation_livret_plus":
				sc.appuyer_bouton(modales.courant, "En savoir plus ›")
				await sc.delai(0.6)
		"presentation_av", "presentation_sicav", "presentation_emprunt", "heritage":
			var id: String = {"presentation_av": "D04", "presentation_sicav": "D05", "presentation_emprunt": "D03", "heritage": "D08"}[etape]
			sc.aller_a_modale(id, true)
			await sc.attendre_que(func() -> bool: return modales.genre_courant == "appel", 8.0)
			await sc.delai(1.8)
			print("Carte %s : %d mots, comparée à %s" % [id, int(e.contenu_modale().get("mots", 0)), str(e.contenu_modale().get("comparatif", {}).get("ref", "-"))])
		"carnet", "banque_ordre", "f01":
			sc.aller_a(Dates.lire("1986-12") if etape == "carnet" else Dates.lire("1986-04"), true)
			if etape == "carnet":
				jeu.ouvrir_banque("sicav", -2.0)
				await sc.delai(3.0)
			elif etape == "banque_ordre":
				jeu.ouvrir_banque("elf", Produits.f(1000.0))
				await sc.delai(3.0)
			else:
				jeu.ouvrir_banque("sicav", Produits.f(5000.0))
				await sc.delai(0.8)
				modales.banque.call("_confirmer")
				await sc.delai(3.4)
				print("F01 : frais payés %s, f01_vu %s" % [Format.montant(e.frais_payes(), e.ab_courant()), e.banque.get("f01_vu", false)])
		"releve", "releve_notif":
			sc.aller_a(Dates.lire("1985-12"), true)
			hud.basculer_panneau(true)
			Partie.changer_vitesse(3)
			await sc.attendre_que(func() -> bool: return Partie.etat.ab_courant() >= Dates.lire("1986-01"), 8.0)
			await sc.delai(0.8)
			if etape == "releve":
				Partie.changer_vitesse(0)
				# CA-I2 (D6) : frais et manque à gagner fabriqués dont les arrondis tombent mal (416,6 + 41,6 = 458,2)
				var n: Dictionary = jeu.dernier_releve.duplicate()
				n["frais_total"] = Produits.f(416.6)
				n["manque"] = Produits.f(41.6)
				n["texte"] = "Relevé fabriqué pour la capture (arrondis) : 416,60 F de frais et 41,60 F de gains manqués, soit 458,20 F exactement."
				jeu.toucher_notif(n)
				await sc.delai(0.8)
				var chiffres := func(nom: String) -> String:
					var l := modales.courant.find_child(nom, true, false) if is_instance_valid(modales.courant) else null
					if l == null:
						return "?"
					var t := ""
					for ch in (l as Label).text:
						if ch >= "0" and ch <= "9":
							t += ch
					return t
				print("UI releve frais=%s manque=%s total=%s" % [chiffres.call("Frais"), chiffres.call("Manque"), chiffres.call("Total")])
			print("Relevé : ", jeu.dernier_releve.get("texte", "?"))
		"fiche_dividendes", "fiche_dividendes_avant":
			# Lot 03 (I6, CA-I6) : fiche d'Elf avant tout dividende (avril 1986 : le joueur actif a déjà touché
			# celui de mai 1986 en avril 1987), puis en juin 1987 (Elf achetée au plus tard en avril 1987)
			sc.aller_a(Dates.lire("1986-04" if etape == "fiche_dividendes_avant" else "1987-04"), true)
			if not e.joueur.lignes.has("elf"):
				e.acheter(e.joueur, "elf", minf(Produits.f(3000.0), e.joueur.cc * 0.8))
			if etape == "fiche_dividendes":
				sc.aller_a(Dates.lire("1987-06"), true)
			hud.maj(e, false)
			jeu.ouvrir_banque("elf", -2.0)
			await sc.delai(1.5)
			var ld: Label = modales.courant.find_child("Dividendes", true, false) as Label if is_instance_valid(modales.courant) else null
			var logique: String = ("Dividendes reçus : " + Format.entier(e.dividendes_recus("elf"), e.ab_courant())) if e.dividendes_recus("elf") > 0.0 \
				else "Dividende versé chaque année en " + Dates.MOIS[e.mois_dividende("elf") - 1]
			var lu := ld.text if ld != null else "(absente)"
			print("UI fiche dividendes=%s = logique=%s%s" % [lu, logique, "" if lu == logique else " incoherences=1"])
			print("Fiche Elf : %s, %s actions" % [Dates.texte(e.ab_courant()), Format.nombre(e.joueur.qte("elf"), 0)])
			var mesure: RefCounted = load("res://scripts/outils/scenarios/interface.gd").new()
			mesure.set("sc", sc)
			mesure.call("_mesurer", etape, modales.courant)
			print("UI polices pixelify_min=%d atkinson_min=%d chiffres_pixelify=%d" % [int(mesure.get("_pix_min")), int(mesure.get("_atk_min")), int(mesure.get("_chiffres_pixelify"))])
		"carnet_pel", "automatique", "automatique_pel":
			sc.aller_a(Dates.lire("1986-12"), true)
			jeu.ouvrir_banque("sicav" if etape == "automatique" else "pel", -2.0)
			await sc.delai(1.2)
			if etape == "automatique":
				modales.banque.call("_afficher_automatique", "sicav")
				await sc.delai(0.3)
				modales.banque.call("_regler_automatique", "sicav", Produits.f(500.0))
			elif etape == "automatique_pel":
				modales.banque.call("_afficher_automatique", "pel")
			await sc.delai(1.0)
			print("PEL : %s ; carte : %s" % [Banquier.texte_taux_pel(e), Banquier.texte_taux_pel(e, true)])
