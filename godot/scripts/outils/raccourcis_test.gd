class_name RaccourcisTest
extends Node
## Raccourcis de test (développement, captures) : F6 / F7 = naissance / jumeaux tout de suite,
## F8 ou triple toucher sur la date = saut au mois qui précède le prochain moment fort (data/demo.json).
## Créé par principal.gd seulement si Reglages.raccourcis_test() : dans la version du joueur, ce nœud
## n'existe pas et le triple toucher n'est relié à rien. F10 (format téléphone) : autoload Ecran.
## Ajouter un raccourci : une touche dans _unhandled_input ci-dessous, et la ligne d'aide d'EcranTitre.

var jeu: Node   # scène principale (principal.gd) : en_titre, demo, hud, modales, sequences


func installer(p_jeu: Node) -> void:
	jeu = p_jeu
	jeu.hud.raccourci_demo.connect(sauter_moment)


func _unhandled_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo or jeu.en_titre or jeu.modales.ouverte() or jeu.sequences.occupe:
		return
	match k.keycode:
		KEY_F8:
			sauter_moment()
		KEY_F6, KEY_F7:
			# Naissance (F6) ou jumeaux (F7) tout de suite
			Partie.forcer_naissance(k.keycode == KEY_F7)
		_:
			return
	get_viewport().set_input_as_handled()


## Saute au mois qui précède le prochain moment fort.
func sauter_moment() -> void:
	var e := Partie.etat
	if e == null or e.fin != "" or jeu.sequences.occupe or jeu.modales.ouverte():
		return
	for d in jeu.demo.get("moments", []):
		var mm := Dates.lire(d) - e.mk.ab_debut
		if mm > e.m + 1:
			Partie.sauter_jusqu_a(mm - 1)
			return
