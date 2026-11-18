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

## Cartes de dilemme (P2, lot 03-foyer) : politique des deux joueurs, actif comme passif. epargner (défaut, = resolution_auto :
## le choix le moins cher payable), depenser (le plus cher payable), alterner (dépenser puis épargner, tour à tour).
static var politique_cartes := "epargner"
## Projets (P1, lot 04, D8) : choix de l'option (moins_cher par défaut = resolution_auto, plus_cher, milieu) et jour J
## (auto = resolution_auto : réaliser si le disponible suffit, sinon reporter, sinon renoncer ; vendre : réaliser en
## vendant quand c'est possible).
## Stratégie de bourse du joueur actif : "" (celle de la démo) ou "peugeot" (lot 05-L B6 : « tout sur Peugeot sans crédit » :
## dès 03/1986, tout le disponible au-delà d'un mois de dépenses achète des Peugeot ; les présentations restent refusées).
static var strategie := ""
static var politique_projets := "moins_cher"
static var politique_echeance := "auto"


## Choix que prend la stratégie pour la modale en attente ("" s'il n'y en a pas). Le choix par défaut est
## celui d'EtatPartie.resolution_auto (test_demo vérifie qu'ils coïncident).
static func choix_modale(e: EtatPartie, actif: bool) -> String:
	if e.modale.is_empty():
		return ""
	var c := e.contenu_modale()
	var choix: Array = c.get("choix", [])
	if c["kind"] == "carte":
		return Foyer.choix_politique(e, politique_cartes)
	if c["kind"] == "projet":
		return Projets.choix_politique(e, politique_projets, politique_echeance)
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
		if e.modale.get("kind", "") in ["carte", "projet"]:
			e.resoudre_modale(choix_modale(e, actif))
		elif not actif or strategie == "peugeot":
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
	if actif and strategie == "peugeot":
		_tout_peugeot(e)
	elif actif:
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

# =====================================================================
# Lot 07-L : une stratégie scriptée par titre d'époque (docs/28 §7, CA-T2)
# =====================================================================
# Un profil décrit tout le jeu d'un joueur automatique ; il se joue avec jouer_partie_profil(e, profil), indépendamment
# des réglages statiques ci-dessus. Clés (toutes facultatives) :
#   cartes "epargner" | "depenser" | "alterner" ; escargots "preter" | "refuser" ;
#   projets "moins_cher" | "plus_cher" | "milieu" ; jour_j {"P1": "auto" | "vendre" | "renoncer", "P2": …} ;
#   krach "rien" | "vendre" | "renforcer" ; ouvrir : présentations acceptées (["D01", "D05"]…), les autres sont remises à plus tard ;
#   livret : true = l'excédent du compte courant (au-delà de reserve × salaire) va au Livret A ;
#   bourse {"part": 0.4, "depuis": "1985-01"} : dès cette date, la part du patrimoine en SICAV puis actions est portée à part.

## Profil de chaque titre : celui du chemin « normal » pour l'obtenir (docs/28 §7).
const PROFILS_TITRES := {
	"bon_pere": {"cartes": "alterner", "escargots": "refuser", "projets": "plus_cher", "jour_j": {"P1": "vendre", "P2": "vendre"},
		"krach": "rien", "ouvrir": ["D01", "D05", "D06"], "livret": true, "bourse": {"part": 0.4, "depuis": "1985-01"}},
	"golden_boy": {"cartes": "alterner", "escargots": "refuser", "projets": "moins_cher", "jour_j": {"P1": "renoncer"},
		"krach": "vendre", "ouvrir": ["D01", "D05", "D06"], "livret": true, "bourse": {"part": 0.5, "depuis": "1986-01"}},
	"escargots": {"cartes": "alterner", "escargots": "preter", "projets": "moins_cher", "ouvrir": ["D01"], "livret": true},
	"fourmi": {"cartes": "epargner", "escargots": "refuser", "projets": "moins_cher", "jour_j": {"P2": "renoncer"},
		"ouvrir": ["D01"], "livret": true},
	"cigale": {"cartes": "depenser", "escargots": "refuser", "projets": "moins_cher", "ouvrir": ["D01"], "livret": true},
	"marin": {"cartes": "alterner", "escargots": "refuser", "projets": "moins_cher", "jour_j": {"P1": "renoncer"},
		"krach": "rien", "ouvrir": ["D01", "D05", "D06"], "livret": true, "bourse": {"part": 0.4, "depuis": "1986-01"}},
	"neveu_matelas": {"cartes": "alterner", "escargots": "refuser", "projets": "moins_cher", "ouvrir": []},
	"ecureuil": {"cartes": "alterner", "escargots": "refuser", "projets": "moins_cher", "ouvrir": ["D01"], "livret": true},
	"apprenti": {"cartes": "alterner", "escargots": "refuser", "projets": "moins_cher", "jour_j": {"P2": "renoncer"},
		"krach": "rien", "ouvrir": ["D01", "D05"], "livret": true, "bourse": {"part": 0.15, "depuis": "1986-01"}},
}


## Clés facultatives ajoutées au lot 08b : bourse.produit "sicav" | "elf" | "une_action" (avec bourse.action = id de l'action,
## toute la part risquée sur ce seul titre ; absent = SICAV puis Elf comme avant) ; vente_apres : true = vend toutes les actions
## et SICAV en 12/1987 par ordre, puis n'y retouche plus.

## Tirage pondéré : poids = liste de [valeur, poids].
static func _tirer(rng: RandomNumberGenerator, poids: Array) -> Variant:
	var total := 0.0
	for p: Array in poids:
		total += float(p[1])
	var x := rng.randf() * total
	for p: Array in poids:
		x -= float(p[1])
		if x < 0.0:
			return p[0]
	return (poids[poids.size() - 1] as Array)[0]


## Profil de joueur « plausible » (population de référence P-REF, lot 08b §4.1), tiré de façon déterministe de la graine g
## par un générateur propre (jamais le hasard de la partie). Lois de tirage : certitude C.
static func profil_reference(g: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = g * 7919 + 13
	var cartes: String = _tirer(rng, [["epargner", 30], ["alterner", 40], ["depenser", 30]])
	var escargots: String = _tirer(rng, [["preter", 15], ["refuser", 85]])
	var projets: String = _tirer(rng, [["moins_cher", 40], ["milieu", 20], ["plus_cher", 40]])
	var jour_j := {}
	for pid in ["P1", "P2"]:
		jour_j[pid] = _tirer(rng, [["auto", 70], ["vendre", 15], ["renoncer", 15]])
	var ouvrir: Array = []
	if rng.randf() < 0.9:
		ouvrir.append("D01")
	for d in ["D02", "D03", "D04", "D05", "D06", "D07"]:
		if rng.randf() < 0.5:
			ouvrir.append(d)
	var livret := rng.randf() < 0.8
	var part: float = _tirer(rng, [[0.0, 30], [0.15, 25], [0.30, 20], [0.45, 15], [0.60, 10]])
	var depuis_ab := Dates.lire("1984-06") + rng.randi_range(0, Dates.lire("1986-06") - Dates.lire("1984-06"))
	var depuis := "%d-%02d" % [Dates.annee(depuis_ab), Dates.mois(depuis_ab)]
	var produit: String = _tirer(rng, [["sicav", 50], ["elf", 20], ["une_action", 30]])
	var action: String = ["elf", "loreal", "peugeot"][rng.randi_range(0, 2)]
	var krach: String = _tirer(rng, [["rien", 55], ["vendre", 30], ["renforcer", 15]])
	var vente_apres := rng.randf() < 0.1
	var p := {"cartes": cartes, "escargots": escargots, "projets": projets, "jour_j": jour_j, "krach": krach,
		"ouvrir": ouvrir, "livret": livret, "vente_apres": vente_apres}
	if part > 0.0:
		p["bourse"] = {"part": part, "depuis": depuis, "produit": produit, "action": action}
		# un joueur ne peut acheter que ce qu'on lui a présenté : il a accepté la présentation de son produit
		var d_prod := "D05" if produit == "sicav" else "D06"
		if not ouvrir.has(d_prod):
			ouvrir.append(d_prod)
	return p


## Joue la partie entière selon le profil (mois par mois, jusqu'à la fin).
static func jouer_partie_profil(e: EtatPartie, profil: Dictionary) -> void:
	var garde := 0
	while e.fin == "" and garde < 400:
		garde += 1
		jouer_mois_profil(e, profil)
		e.avancer()


## Le mois affiché : modale en attente résolue selon le profil, puis ordres du mois (sans passer au mois suivant).
static func jouer_mois_profil(e: EtatPartie, profil: Dictionary) -> void:
	var essais := 0
	while not e.modale.is_empty() and essais < 5:
		essais += 1
		if e.resoudre_modale(_choix_profil(e, profil)).is_empty() and not e.modale.is_empty():
			e.resolution_auto()
	_ordres_profil(e, profil)


static func _choix_profil(e: EtatPartie, profil: Dictionary) -> String:
	var c := e.contenu_modale()
	var choix: Array = c.get("choix", [])
	match str(c["kind"]):
		"carte":
			if str(c["id"]) == str(Foyer.donnees()["escargots"]["carte"]):
				var voulu := "a" if str(profil.get("escargots", "refuser")) == "preter" else "b"
				if Foyer.choix_valide(e, voulu):
					return voulu
			return Foyer.choix_politique(e, str(profil.get("cartes", "epargner")))
		"projet":
			if str(c.get("etape", "")) == "echeance":
				var pid := str(Projets._option(str(c["id"]))["projet"]["id"])
				var j := str((profil.get("jour_j", {}) as Dictionary).get(pid, "auto"))
				if j == "renoncer":
					return "renoncer"
				return Projets.choix_politique(e, str(profil.get("projets", "moins_cher")), j)
			return Projets.choix_politique(e, str(profil.get("projets", "moins_cher")), "auto")
		"banquier":
			if c.get("heritage", false):
				return "compris"
			return "ouvrir" if (profil.get("ouvrir", []) as Array).has(str(c["id"])) else "plus_tard"
		"marche":
			var ev := e.evenement(str(e.modale["id"]))
			if e._est_krach(ev) and c.get("detient", false):
				var voulu := str(profil.get("krach", "rien"))
				for x: Dictionary in choix:
					if str(x["id"]) == voulu and not bool(x.get("desactive", false)):
						return voulu
	return choix_modale(e, true)


## Ordres du mois d'un profil : compte renfloué, bourse portée à la part voulue, excédent au Livret A.
static func _ordres_profil(e: EtatPartie, profil: Dictionary) -> void:
	var j := e.joueur
	var reserve := 0.5 * e.salaire_base
	if j.cc < 0.0 and j.livret > 0.0:
		e.retirer_livret(j, minf(j.livret, -j.cc + e.salaire_base))
	var b: Dictionary = profil.get("bourse", {})
	var vendu := false
	if bool(profil.get("vente_apres", false)) and e.ab_courant() >= Dates.lire("1987-12"):
		vendu = true
		if e.ab_courant() == Dates.lire("1987-12"):
			for id in j.lignes.keys():
				if j.qte(str(id)) > 0.0:
					e.vendre(j, str(id), 0.0, true)
	if not b.is_empty() and not vendu and e.ab_courant() >= Dates.lire(str(b["depuis"])):
		var produit := ""
		var candidats: Array = ["sicav", "elf"]
		match str(b.get("produit", "")):
			"sicav":
				candidats = ["sicav"]
			"elf":
				candidats = ["elf"]
			"une_action":
				candidats = [str(b.get("action", "elf"))]
		for id in candidats:
			if Banquier.presente(e, id) and not is_nan(e.cours(id)):
				produit = id
				break
		var manque := float(b["part"]) * e.patrimoine(j) - e.valeur_risquee(j)
		if produit != "" and manque > Produits.f(500.0):
			var dispo := maxf(0.0, j.cc - reserve)
			if dispo < manque and j.livret > 0.0:
				e.retirer_livret(j, minf(j.livret, manque - dispo))
			var budget := minf(manque, maxf(0.0, j.cc - reserve))
			if budget > Produits.f(200.0):
				e.acheter(j, produit, budget)
	if bool(profil.get("livret", false)) and Banquier.presente(e, "livret") and j.cc > reserve:
		e.deposer_livret(j, minf(j.cc - reserve, e.place_livret(j)))


## « Tout sur Peugeot sans crédit » : dès 03/1986, tout ce qui dépasse un mois de dépenses sur le compte courant achète
## des Peugeot (titres entiers, frais compris) ; jamais d'achat à crédit (le compte ne devient pas négatif par un ordre).
static func _tout_peugeot(e: EtatPartie) -> void:
	if e.ab_courant() < Dates.lire("1986-03"):
		return
	var budget := e.joueur.cc - float(e.depenses()["total"])
	if budget > 0.0:
		e.acheter(e.joueur, "peugeot", budget)
