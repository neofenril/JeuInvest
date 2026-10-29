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
