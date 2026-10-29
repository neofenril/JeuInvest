extends SceneTree
## Script fautif VOLONTAIRE, pour vérifier que tests.ps1 détecte les erreurs de script (option -Autocontrole).
## Il se compile sans erreur, provoque une erreur à l'exécution, puis quitte avec le code 0 : seul l'examen
## de la sortie permet de voir le problème. Hors de la découverte normale (ni « test_* », ni dans tests/).
## Lancer : powershell -File godot\outils\tests.ps1 -Autocontrole


func _initialize() -> void:
	print("Autocontrôle : erreur de script volontaire, puis sortie avec le code 0.")
	quit(0)
	_fautive()


func _fautive() -> void:
	var d: Dictionary = {}
	var absent: Variant = d.get("absent")
	absent.methode_inexistante()   # appel sur une valeur nulle : SCRIPT ERROR à l'exécution
