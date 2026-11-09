class_name Reglages
extends RefCounted
## Réglages de développement (lot 01, §2.1). Sans état.
## Les raccourcis de test (ligne d'aide du titre, F6 / F7, F8, triple toucher sur la date, F10) n'existent
## que dans l'éditeur ou en ligne de commande : jamais dans la version du joueur (exe, APK).


## Vrai seulement dans l'éditeur / en ligne de commande (développement, tests, captures).
static func raccourcis_test() -> bool:
	if OS.has_feature("template"):            # toute version exportée : exe, APK (même en debug)
		return false
	if "--joueur" in OS.get_cmdline_user_args():   # simuler la version du joueur depuis l'éditeur
		return false
	return bool(ProjectSettings.get_setting("jeuclaude/raccourcis_test", true))


# =====================================================================
# Préférences locales du joueur (lot 02, D3) : user://preferences.cfg, pas dans la sauvegarde.
# Jamais lues ni écrites en mode capture (--capture=…) ni dans les tests (sans écran, --headless).
# =====================================================================

const PREFERENCES := "user://preferences.cfg"


static func _preferences_actives() -> bool:
	if DisplayServer.get_name() == "headless":
		return false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture"):
			return false
	return true


## Vrai si la bulle d'aide « nom » n'a jamais été vue. En capture : seulement avec l'option --bulle-<nom>.
static func bulle_a_montrer(nom: String) -> bool:
	if not _preferences_actives():
		return ("--bulle-" + nom) in OS.get_cmdline_user_args()
	var cfg := ConfigFile.new()
	if cfg.load(PREFERENCES) != OK:
		return true
	return not bool(cfg.get_value("bulles", nom, false))


static func marquer_bulle_vue(nom: String) -> void:
	if not _preferences_actives():
		return
	var cfg := ConfigFile.new()
	cfg.load(PREFERENCES)   # absent la première fois : on part d'un fichier vide
	cfg.set_value("bulles", nom, true)
	cfg.save(PREFERENCES)
