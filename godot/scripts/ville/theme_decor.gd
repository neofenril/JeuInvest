class_name ThemeDecor
extends RefCounted
## Tables de thèmes du décor (lot 09-V) : data/themes/<id>.json, une table par tranche de 10 ans (docs/36 §10.6).
## Les clés commençant par « _ » sont des notes. Thème inconnu ou fichier absent : table vide (= rue actuelle)
## et un avertissement. Le choix du thème selon la date est fait par Donnees.theme_a (logique), pas ici.

const DOSSIER := "res://data/themes/"


static func table(id: String) -> Dictionary:
	var chemin := DOSSIER + id + ".json"
	if id == "" or not FileAccess.file_exists(chemin):
		push_warning("ThemeDecor : thème « %s » inconnu, rue actuelle conservée" % id)
		return {}
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(chemin))
	if not d is Dictionary:
		push_warning("ThemeDecor : thème « %s » illisible" % id)
		return {}
	var t := {}
	for k in d:
		if not String(k).begins_with("_"):
			t[k] = d[k]
	return t