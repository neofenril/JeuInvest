extends Node
## Autoload « Capture » : outil de capture d'écran, inactif sauf si la ligne de commande contient
## --capture=<fichier.png> (après le séparateur « -- »). Il attend quelques images, enregistre
## la fenêtre en PNG puis quitte. Chemin relatif = relatif au dossier du projet (godot/).
##
## Options : --capture=captures/x.png  --frames=30 (images à attendre)  --attente=0 (secondes en plus)
##           --etape=krach : appelle preparer_capture("krach") de la scène courante (qui met le jeu
##                           dans l'état voulu) avant la capture
##           --telephone   : bascule en téléphone simulé (comme F10) avant la capture
## Exemple : Godot_console.exe --path godot --resolution 1280x720 -- --capture=captures/titre.png --etape=titre

var _options := {}


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var kv := arg.substr(2).split("=", true, 1)
			_options[kv[0]] = kv[1] if kv.size() > 1 else "1"
	if not _options.has("capture"):
		set_process(false)
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	_capturer.call_deferred()


func _delai_depasse() -> void:
	push_error("Capture : délai dépassé")
	get_tree().quit(2)


func _capturer() -> void:
	# Garde-fou : on quitte quoi qu'il arrive au bout de 420 s (l'intégrale de 60 mois à ×3 dure environ 3 min)
	get_tree().create_timer(420.0, true, false, true).timeout.connect(_delai_depasse)
	for i in 3:
		await get_tree().process_frame
	if _options.has("telephone"):
		Ecran.basculer_telephone()
		for i in 5:
			await get_tree().process_frame
	var scene := get_tree().current_scene
	if _options.has("etape") and scene != null and scene.has_method("preparer_capture"):
		await scene.preparer_capture(_options["etape"])
	for i in maxi(1, int(_options.get("frames", "30"))):
		await get_tree().process_frame
	var attente := float(_options.get("attente", "0"))
	if attente > 0.0:
		await get_tree().create_timer(attente).timeout
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var chemin: String = _options["capture"]
	if chemin.is_relative_path():
		chemin = ProjectSettings.globalize_path("res://").path_join(chemin)
	DirAccess.make_dir_recursive_absolute(chemin.get_base_dir())
	var err := image.save_png(chemin)
	if err == OK:
		print("Capture enregistrée : %s (%d × %d), zone logique %s" % [chemin, image.get_width(), image.get_height(), str(Ecran.taille())])
		get_tree().quit(0)
	else:
		push_error("Capture impossible (%s) : %s" % [error_string(err), chemin])
		get_tree().quit(1)
