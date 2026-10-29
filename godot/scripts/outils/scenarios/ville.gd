extends RefCounted
## Étapes de capture : la rue et ses animations (jour, nuit, trafic, panne de voiture, naissance, jumeaux,
## petite news, krach du média, images par seconde).

const ETAPES := ["rue", "rue_nuit", "trafic", "crash_anim", "crash_fin", "crash_courrier", "naissance_anim", "naissance_pose", "naissance",
	"jumeaux_anim", "jumeaux_pose", "jumeaux", "news", "krach_anim", "fps"]

var sc: ScenariosCapture


func jouer(etape: String) -> void:
	var jeu := sc.jeu
	var ville: Node2D = jeu.ville
	sc.partir_de_la_rue(etape)
	match etape:
		"rue", "rue_nuit":
			sc.aller_a(Dates.lire("1987-05"), true)
			ville.set("phase", 0.72 if etape == "rue_nuit" else 0.18)
			Partie.changer_vitesse(1)
			await sc.delai(2.6)
		"trafic":
			sc.aller_a(Dates.lire("1987-05"), true)
			for v in [1, 2, 3, 0]:
				Partie.changer_vitesse(v)
				await sc.delai(1.2)
				var v_voitures: float = await sc.vitesse_mesuree(ville.get("_voitures"))
				var v_passants: float = await sc.vitesse_mesuree(ville.get("passants"))
				print("Trafic à la vitesse %d : voitures %.0f u/s, passants %.0f u/s (facteur %.2f)" % [v, v_voitures, v_passants, float(ville.get("facteur_trafic"))])
		"crash_anim", "crash_fin", "crash_courrier":
			sc.aller_a_modale("voiture", true)
			var attente_crash: float = {"crash_anim": 0.62, "crash_fin": 1.3, "crash_courrier": 3.6}[etape]
			await sc.delai(attente_crash)
		"naissance_anim", "naissance_pose", "naissance":
			sc.aller_a_modale("naissance", true)
			var attente_n: float = {"naissance_anim": 0.5, "naissance_pose": 1.45, "naissance": 3.6}[etape]
			await sc.delai(attente_n)
			print("Naissance : %s, %d enfant(s), reste %s par mois" % [Partie.etat.contenu_modale().get("titre", "?"), Partie.etat.enfants, Format.montant(Partie.etat.epargne_du_mois(), Partie.etat.ab_courant())])
		"jumeaux_anim", "jumeaux_pose", "jumeaux":
			sc.aller_a(Dates.lire("1984-05"), true)
			ville.set("phase", 0.18)
			Partie.forcer_naissance(true)
			var attente_j: float = {"jumeaux_anim": 0.5, "jumeaux_pose": 1.45, "jumeaux": 3.6}[etape]
			await sc.delai(attente_j)
		"news":
			sc.aller_a(Dates.lire("1988-05"), true)
			Partie.changer_vitesse(2)
			await sc.attendre_que(func() -> bool: return Partie.etat.ab_courant() >= Dates.lire("1988-06"), 15.0)
			await sc.delai(0.9)
		"krach_anim":
			sc.aller_a_modale("p1e6", true)
			await sc.attendre_que(func() -> bool: return jeu.sequences.occupe, 15.0)
			await sc.delai(1.05)
		"fps":
			sc.aller_a(Dates.lire("1987-11"), true)
			ville.set("pluie", true)
			ville.set("krach", 1.0)
			Partie.changer_vitesse(1)
			await sc.delai(1.0)
			var n0 := Engine.get_frames_drawn()
			var t1 := Time.get_ticks_msec()
			await sc.delai(3.0)
			print("Images par seconde (moyenne sur 3 s) : %.1f" % ((Engine.get_frames_drawn() - n0) * 1000.0 / (Time.get_ticks_msec() - t1)))
