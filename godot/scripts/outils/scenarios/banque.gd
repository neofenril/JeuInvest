extends RefCounted
## Étapes de capture : la banque (cartes du banquier, héritage, carnet, ordres, frais, relevé, versements automatiques).

const ETAPES := ["presentation_livret", "presentation_livret_plus", "presentation_av", "presentation_sicav", "presentation_emprunt",
	"heritage", "carnet", "banque_ordre", "f01", "releve", "releve_notif", "carnet_pel", "automatique", "automatique_pel"]

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
