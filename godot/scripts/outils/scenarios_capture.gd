class_name ScenariosCapture
extends Node
## Scénarios des captures d'écran (--etape=, voir scripts/outils/capture.gd et outils/capture.ps1).
## Répartiteur : chaque famille d'étapes est un fichier de scripts/outils/scenarios/ (sans class_name) qui
## déclare const ETAPES et func jouer(etape) ; ce fichier-ci fournit les outils communs.
## Ajouter une étape : son nom dans ETAPES de la famille, son cas dans jouer(), et la liste de capture.ps1.
## Créé à la demande par principal.preparer_capture (enfant de la scène principale).

const FAMILLES := ["titre", "banque", "ville", "ecrans", "outils"]
const DOSSIER := "res://scripts/outils/scenarios/"

var jeu: Node   # scène principale (principal.gd)
var _famille: RefCounted


## Options de la ligne de commande (après « -- ») : --nom=valeur.
static func option(nom: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--" + nom + "="):
			return arg.split("=", true, 1)[1]
	return ""


## Vrai si le jeu est lancé pour une capture (--capture=…).
static func mode_capture() -> bool:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture"):
			return true
	return false


func preparer(etape: String) -> void:
	for nom in FAMILLES:
		var script: GDScript = load(DOSSIER + nom + ".gd")
		if etape in script.get_script_constant_map().get("ETAPES", []):
			_famille = script.new()
			_famille.set("sc", self)
			await _famille.jouer(etape)
			return
	partir_de_la_rue(etape)   # étape inconnue : la partie démarre dans la rue, comme les autres


## Départ commun des étapes hors écran titre : la rue, sans la carte du Livret A (sauf si l'étape la veut).
func partir_de_la_rue(etape: String) -> void:
	if etape not in ["presentation_livret", "presentation_livret_plus", "integrale"]:
		Partie.etat.resolution_auto()
	jeu.demarrer_direct(0)


func delai(s: float) -> void:
	await get_tree().create_timer(s).timeout


func attendre_que(condition: Callable, delai_max: float) -> void:
	var t := 0.0
	while not condition.call() and t < delai_max:
		await get_tree().process_frame
		t += get_process_delta_time()


# =====================================================================
# Avance rapide (copie temporaire de StrategieTest, voir lot 01 §2.2 ; passage prévu au lot 02)
# =====================================================================

## Joueur « actif » des captures : il ouvre chaque produit présenté et y place une partie de son argent,
## et range l'excédent du compte sur le Livret A (comme le joueur actif des tests).
func strategie_active(e: EtatPartie) -> void:
	if not e.modale.is_empty():
		var c := e.contenu_modale()
		if c["kind"] == "banquier" and not c.get("heritage", false):
			var r := e.resoudre_modale("ouvrir")
			var f := Produits.f
			match str(r.get("ouvrir", "")):
				"livret":
					e.deposer_livret(e.joueur, e.joueur.cc * 0.8)
				"pel":
					e.ouvrir_pel(f.call(2000.0), f.call(500.0))
				"emprunt":
					e.acheter_emprunt(minf(f.call(10000.0), e.joueur.cc * 0.8))
				"av":
					e.verser_av(minf(f.call(10000.0), e.joueur.cc * 0.8))
				"sicav":
					e.acheter(e.joueur, "sicav", minf(f.call(5000.0), e.joueur.cc * 0.8))
				"elf":
					e.acheter(e.joueur, "elf", minf(f.call(3000.0), e.joueur.cc * 0.8))
				"saintgobain":
					e.acheter(e.joueur, "saintgobain", f.call(3100.0))
		elif c["kind"] == "vie" and c["choix"].size() > 1 and c["choix"][0]["id"] == "vendre" and not c["choix"][0].get("desactive", false):
			e.resoudre_modale("vendre")   # un coup dur plus gros que le compte : on puise dans le Livret A
		else:
			e.resolution_auto()
	if e.joueur.cc < 0.0 and e.joueur.livret > 0.0:
		e.retirer_livret(e.joueur, minf(e.joueur.livret, -e.joueur.cc + e.salaire_base))
	if e.joueur.cc > e.salaire_base and Banquier.presente(e, "livret"):
		e.deposer_livret(e.joueur, minf(e.joueur.cc - e.salaire_base, e.place_livret(e.joueur)))


## Avance (sans animation) jusqu'au mois absolu « ab », en jouant de façon active ou passive.
func aller_a(ab: int, actif: bool) -> void:
	var e := Partie.etat
	var garde := 0
	while e.fin == "" and e.ab_courant() < ab and garde < 100:
		if actif:
			strategie_active(e)
		elif not e.modale.is_empty():
			e.resolution_auto()
		if not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
		garde += 1
	rafraichir_apres_saut()


## Avance jusqu'à ce que la modale « id » (présentation, krach p1e6, voiture, naissance) soit ouverte.
func aller_a_modale(id: String, actif: bool) -> void:
	var e := Partie.etat
	var garde := 0
	while e.fin == "" and garde < 100:
		if not e.modale.is_empty():
			var c := e.contenu_modale()
			var ident := str(e.modale.get("id", ""))
			if e.modale.get("kind", "") == "vie":
				ident = str(e.calendrier[int(e.modale["idx"])]["type"])
			if ident == id:
				break
			if actif:
				strategie_active(e)
			if not e.modale.is_empty():
				e.resolution_auto()
		elif actif:
			strategie_active(e)
		e.avancer()
		garde += 1
	rafraichir_apres_saut()
	Partie.rouvrir_modale()


func rafraichir_apres_saut() -> void:
	var e := Partie.etat
	jeu.ville.call("regler_mois", Dates.mois(e.ab_courant()), Dates.annee(e.ab_courant()))
	jeu.hud.maj(e, false)
	jeu.sequences.maj_media(false)


# =====================================================================
# Entrées simulées et mesures
# =====================================================================

func appuyer_bouton(racine: Node, texte: String) -> void:
	if racine == null:
		return
	for n in racine.find_children("*", "Button", true, false):
		var b := n as Button
		if b.text == texte:
			b.pressed.emit()
			return


## Clic gauche simulé (par défaut près du bord gauche de la fenêtre, à mi-hauteur : hors de toute pop-up).
## pos : coordonnées de la fenêtre (pixels).
func clic_dehors(pos := Vector2(-1, -1)) -> void:
	if pos.x < 0.0:
		pos = Vector2(20, get_window().size.y / 2.0)
	for appui in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = appui
		ev.position = pos
		ev.global_position = pos
		Input.parse_input_event(ev)
		await get_tree().process_frame


## Touche simulée (appui puis relâchement), comme au clavier.
func touche(code: Key) -> void:
	for appui in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = code
		ev.pressed = appui
		Input.parse_input_event(ev)
		await get_tree().process_frame


## Position dans la fenêtre (pixels) du centre d'un contrôle (étirement et facteur d'échelle compris).
func position_fenetre(c: Control) -> Vector2:
	return get_viewport().get_final_transform() * (c.get_global_transform_with_canvas() * (c.size / 2.0))


## Vitesse moyenne (unités par seconde) des nœuds mobiles sur 0,5 s (le passage d'un bord à l'autre est écarté).
func vitesse_mesuree(noeuds: Array) -> float:
	var x0: Array = []
	for n: Node2D in noeuds:
		x0.append(n.position.x)
	await get_tree().create_timer(0.5).timeout
	var total := 0.0
	var compte := 0
	for i in noeuds.size():
		var n: Node2D = noeuds[i]
		var dx := absf(n.position.x - float(x0[i]))
		if dx < 1000.0 and float(n.get("vitesse")) > 0.0 and n.get("arrete") != true:
			total += dx / 0.5
			compte += 1
	return total / maxf(1.0, compte)
