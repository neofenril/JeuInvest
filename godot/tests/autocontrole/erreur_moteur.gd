extends SceneTree
## Ligne d'erreur du moteur VOLONTAIRE (« ERROR: … », comme une ressource introuvable ou un push_error), pour
## vérifier que tests.ps1 la détecte (option -Autocontrole, T17). Quitte avec le code 0 : seul l'examen de la
## sortie permet de voir le problème. Hors de la découverte normale (ni « test_* », ni dans tests/).


func _initialize() -> void:
	print("Autocontrôle : ligne « ERROR: » volontaire du moteur, puis sortie avec le code 0.")
	push_error("Autocontrôle : erreur du moteur volontaire.")
	quit(0)
