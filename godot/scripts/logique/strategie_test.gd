class_name StrategieTest
extends RefCounted
## Joueurs automatiques des tests (et, au lot 02, des captures d'écran) : sans nœud ni interface.
## Reprend la stratégie de principal.gd (_strategie_active, _aller_a, _aller_a_modale), sans le rafraîchissement
## de l'écran (après un saut, l'appelant met lui-même l'affichage à jour), avec un seul écart : voir _placer.
## - Joueur actif : il ouvre chaque produit présenté et y place une partie de son argent, vend un placement
##   face à un coup dur plus gros que le compte, puise dans le Livret A si le compte est négatif et y range
##   l'excédent du compte (au-delà d'un mois de salaire).
## - Joueur passif : choix par défaut (EtatPartie.resolution_auto : « pas maintenant », payer, ne rien faire).

const GARDE := 100   # mois au plus par saut (la démo en compte 60)
const PLANCHER_F := 2500.0   # francs gardés sur le compte pour pouvoir acheter un produit qu'on vient d'ouvrir


## Choix que prend la stratégie pour la modale en attente ("" s'il n'y en a pas). Le choix par défaut est
## celui d'EtatPartie.resolution_auto (test_demo vérifie qu'ils coïncident).
static func choix_modale(e: EtatPartie, actif: bool) -> String:
	if e.modale.is_empty():
		return ""
	var c := e.contenu_modale()
	var choix: Array = c.get("choix", [])
	if actif:
		if c["kind"] == "banquier" and not c.get("heritage", false):
			return "ouvrir"
		if c["kind"] == "vie" and choix.size() > 1 and choix[0]["id"] == "vendre" and not choix[0].get("desactive", false):
			return "vendre"   # un coup dur plus gros que le compte : on puise dans le Livret A
	if c["kind"] == "banquier":
		return "compris" if c.get("heritage", false) else "plus_tard"
	if c["kind"] == "marche":
		return "rien" if c["detient"] else "ecart"
	var premier: String = choix[0]["id"]
	return "decouvert" if premier == "vendre" else premier


## Identifiant de la modale en attente : Dxx (présentation), id de l'événement de marché (p1e6 = krach),
## type de l'événement de vie (voiture, naissance…). "" s'il n'y en a pas.
static func id_modale(e: EtatPartie) -> String:
	if e.modale.is_empty():
		return ""
	if e.modale.get("kind", "") == "vie":
		return str(e.calendrier[int(e.modale["idx"])]["type"])
	return str(e.modale.get("id", ""))


## Joue le mois affiché : résout la modale en attente (actif : ouvre et achète, vend face à un gros courrier ;
## passif : resolution_auto), puis, pour le joueur actif, rééquilibre compte courant et Livret A.
static func jouer_mois(e: EtatPartie, actif: bool) -> void:
	if not e.modale.is_empty():
		if not actif:
			e.resolution_auto()
		else:
			match choix_modale(e, true):
				"ouvrir":
					var r := e.resoudre_modale("ouvrir")
					_placer(e, str(r.get("ouvrir", "")))
				"vendre":
					e.resoudre_modale("vendre")
				_:
					e.resolution_auto()
	if actif:
		_reequilibrer(e)


## Avance sans animation jusqu'au mois absolu ab (Dates.lire("1986-03")…), en jouant chaque mois.
static func aller_a(e: EtatPartie, ab: int, actif: bool) -> void:
	var garde := 0
	while e.fin == "" and e.ab_courant() < ab and garde < GARDE:
		jouer_mois(e, actif)
		if not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
		garde += 1


## Avance jusqu'à ce que la modale « id » (voir id_modale) soit ouverte, et s'y arrête (non résolue).
## Renvoie false si elle n'arrive pas avant la fin de la partie (ou avant GARDE mois).
static func aller_a_modale(e: EtatPartie, id: String, actif: bool) -> bool:
	var garde := 0
	while e.fin == "" and garde < GARDE:
		if not e.modale.is_empty():
			if id_modale(e) == id:
				return true
			jouer_mois(e, actif)
			if not e.modale.is_empty():
				e.resolution_auto()
		elif actif:
			jouer_mois(e, true)
		e.avancer()
		garde += 1
	return false


## Joueur actif : ce qu'il place dans le produit qu'il vient d'ouvrir.
## Seul écart avec principal._strategie_active (lot 01) : si le compte courant est sous PLANCHER_F (après un
## coup dur), il est d'abord porté à ce plancher depuis le Livret A ; sinon l'achat échoue faute de liquidités
## (graines 9 et 12 : PEL ou actions jamais détenus). Jamais déclenché avec la graine des captures.
static func _placer(e: EtatPartie, pid: String) -> void:
	var plancher := Produits.f(PLANCHER_F)
	if pid != "livret" and e.joueur.cc < plancher and e.joueur.livret > 0.0:
		e.retirer_livret(e.joueur, minf(e.joueur.livret, plancher - e.joueur.cc))
	match pid:
		"livret":
			e.deposer_livret(e.joueur, e.joueur.cc * 0.8)
		"pel":
			e.ouvrir_pel(Produits.f(2000.0), Produits.f(500.0))
		"emprunt":
			e.acheter_emprunt(minf(Produits.f(10000.0), e.joueur.cc * 0.8))
		"av":
			e.verser_av(minf(Produits.f(10000.0), e.joueur.cc * 0.8))
		"sicav":
			e.acheter(e.joueur, "sicav", minf(Produits.f(5000.0), e.joueur.cc * 0.8))
		"elf":
			e.acheter(e.joueur, "elf", minf(Produits.f(3000.0), e.joueur.cc * 0.8))
		"saintgobain":
			e.acheter(e.joueur, "saintgobain", Produits.f(3100.0))


## Joueur actif, chaque mois : compte négatif renfloué par le Livret A ; excédent (au-delà d'un salaire) rangé dessus.
static func _reequilibrer(e: EtatPartie) -> void:
	if e.joueur.cc < 0.0 and e.joueur.livret > 0.0:
		e.retirer_livret(e.joueur, minf(e.joueur.livret, -e.joueur.cc + e.salaire_base))
	if e.joueur.cc > e.salaire_base and Banquier.presente(e, "livret"):
		e.deposer_livret(e.joueur, minf(e.joueur.cc - e.salaire_base, e.place_livret(e.joueur)))
