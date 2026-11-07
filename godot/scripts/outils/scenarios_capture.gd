class_name ScenariosCapture
extends Node
## Scénarios des captures d'écran (--etape=, voir scripts/outils/capture.gd et outils/capture.ps1).
## Répartiteur : chaque famille d'étapes est un fichier de scripts/outils/scenarios/ (sans class_name) qui
## déclare const ETAPES et func jouer(etape) ; ce fichier-ci fournit les outils communs.
## Ajouter une étape : son nom dans ETAPES de la famille, son cas dans jouer(), et la liste de capture.ps1.
## Créé à la demande par principal.preparer_capture (enfant de la scène principale).

const FAMILLES := ["titre", "banque", "ville", "ecrans", "outils", "interface"]
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
	if etape not in ["presentation_livret", "presentation_livret_plus", "integrale", "integrale_saut"]:
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
# Avance rapide : joueurs automatiques de StrategieTest (lot 02, T13), puis rafraîchissement de l'écran
# =====================================================================

## Avance (sans animation) jusqu'au mois absolu « ab », en jouant de façon active ou passive.
func aller_a(ab: int, actif: bool) -> void:
	StrategieTest.aller_a(Partie.etat, ab, actif)
	rafraichir_apres_saut()


## Avance jusqu'à ce que la modale « id » (présentation, krach p1e6, voiture, naissance) soit ouverte, puis la rouvre.
func aller_a_modale(id: String, actif: bool) -> void:
	StrategieTest.aller_a_modale(Partie.etat, id, actif)
	rafraichir_apres_saut()
	Partie.rouvrir_modale()


## Compatibilité : scripts/outils/scenarios/ville.gd (fichier de dev-ville au lot 02) appelle encore
## sc.strategie_active(e). Délègue à StrategieTest (aucune copie de stratégie ici) ; à retirer quand
## ville.gd appellera StrategieTest.jouer_mois directement.
func strategie_active(e: EtatPartie) -> void:
	StrategieTest.jouer_mois(e, true)


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
		pos = Vector2(6, get_window().size.y / 2.0)   # tout au bord : l'historique du téléphone laisse 15 px de chaque côté
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
