class_name Records
extends RefCounted
## Record personnel et collection des titres d'époque (lot 07-L ; lot_07.md D4 à D8). Fichier « user://records.sav » au
## format texte (ConfigFile), conservé d'une partie à l'autre, jamais lu ni écrit par la sauvegarde de la partie :
##   [meta] version
##   [record] ecart_pct, rang, titre_id, titre_nom, prenom, patrimoine, date_reelle (« AAAA-MM-JJ »)
##   [collection] <id du titre> = {"nombre": n, "premiere": "AAAA-MM-JJ"}
##   [parties] ids = identifiants des parties déjà comptées (les 200 derniers : une fin rejouée n'est pas comptée deux fois)
## Dernière ligne « ; fin » : un fichier tronqué ne l'a pas et est traité comme absent, sans passer par l'analyseur.
## Tolérant : fichier absent, tronqué, illisible ou d'une autre version = vide, jamais d'erreur ni d'effet sur la partie.
## Le record est le meilleur écart final en % face à Tata Livret (décision du joueur, 13/11) ; égalité : l'ancien reste.

const CHEMIN := "user://records.sav"
const VERSION := 1
const MARQUE_FIN := "; fin"
const IDS_MAX := 200


## {"record": {} | {ecart_pct, rang, titre_id, titre_nom, prenom, patrimoine, date_reelle}, "collection": {id: {nombre, premiere}}}
static func lire(chemin := CHEMIN) -> Dictionary:
	var d := _charger(chemin)
	return {"record": d["record"], "collection": d["collection"]}


## Compte la partie finie (bilan de Bilan.calculer) : titre dans la collection, record si strictement meilleur.
## Rien n'est écrit sans titre (abandon, faillite) ; avec record_possible faux (retours), seule la collection avance ; une
## partie (id_partie) déjà comptée ne l'est pas deux fois. date : « AAAA-MM-JJ » (défaut : aujourd'hui, horloge réelle).
## Renvoie {"ecrit", "deja_compte", "hors_record", "nouveau", "ancien", "record", "collection", "nouveau_titre"}.
static func enregistrer(bilan: Dictionary, id_partie: String, chemin := CHEMIN, date := "") -> Dictionary:
	var d := _charger(chemin)
	var titre: Dictionary = bilan.get("titre", {})
	var hors := not bool(bilan.get("record_possible", false))
	var r := {"ecrit": false, "deja_compte": false, "hors_record": hors, "nouveau": false, "ancien": d["record"].duplicate(true),
		"record": d["record"], "collection": d["collection"], "nouveau_titre": false}
	if titre.is_empty():
		return r
	if id_partie != "" and (d["ids"] as Array).has(id_partie):
		r["deja_compte"] = true
		return r
	var jour := date if date != "" else Time.get_date_string_from_system()
	var coll: Dictionary = d["collection"]
	var tid := str(titre["id"])
	var ligne: Dictionary = coll.get(tid, {})
	var nombre := int(ligne.get("nombre", 0)) + 1
	coll[tid] = {"nombre": nombre, "premiere": str(ligne.get("premiere", jour))}
	r["nouveau_titre"] = nombre == 1
	if not hors:
		var pct := snappedf(float(bilan.get("ecart_tata_pct", 0.0)), 0.0001)
		var ancien: Dictionary = d["record"]
		if ancien.is_empty() or pct > float(ancien["ecart_pct"]):
			r["nouveau"] = true
			d["record"] = {"ecart_pct": pct, "rang": _rang(bilan), "titre_id": tid, "titre_nom": str(titre["nom"]),
				"prenom": str(bilan.get("prenom", "")), "patrimoine": float(bilan.get("nominal", {}).get("vous", 0.0)), "date_reelle": jour}
	if id_partie != "":
		(d["ids"] as Array).append(id_partie)
		while (d["ids"] as Array).size() > IDS_MAX:
			(d["ids"] as Array).pop_front()
	r["record"] = d["record"]
	r["collection"] = coll
	r["ecrit"] = _ecrire(d, chemin)
	return r


## Efface le fichier (tests seulement : à ne jamais appeler sur le chemin du joueur).
static func effacer(chemin: String) -> void:
	for p in [chemin, chemin + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)


## Rang du joueur dans la rue (1 à 4) ; 0 si la rue est éteinte (classement vide).
static func _rang(bilan: Dictionary) -> int:
	var rue: Array = bilan.get("rue", [])
	return Quartier.rang_de(rue) if not rue.is_empty() else 0


static func _vide() -> Dictionary:
	return {"record": {}, "collection": {}, "ids": []}


static func _charger(chemin: String) -> Dictionary:
	if not FileAccess.file_exists(chemin):
		return _vide()
	var texte := FileAccess.get_file_as_string(chemin)
	if not texte.strip_edges().ends_with(MARQUE_FIN) or not texte.begins_with("[meta]"):
		return _vide()
	var cf := ConfigFile.new()
	if cf.parse(texte) != OK or int(cf.get_value("meta", "version", -1)) != VERSION:
		return _vide()
	var d := _vide()
	var rec := {}
	if cf.has_section("record"):
		for k in ["ecart_pct", "rang", "titre_id", "titre_nom", "prenom", "patrimoine", "date_reelle"]:
			if not cf.has_section_key("record", k):
				rec = {}
				break
			rec[k] = cf.get_value("record", k)
		if not rec.is_empty():
			rec["ecart_pct"] = float(rec["ecart_pct"])
			rec["rang"] = int(rec["rang"])
			rec["patrimoine"] = float(rec["patrimoine"])
			for k in ["titre_id", "titre_nom", "prenom", "date_reelle"]:
				rec[k] = str(rec[k])
	d["record"] = rec
	if cf.has_section("collection"):
		for id in cf.get_section_keys("collection"):
			var v: Variant = cf.get_value("collection", id)
			if v is Dictionary and (v as Dictionary).has("nombre") and (v as Dictionary).has("premiere"):
				d["collection"][id] = {"nombre": int(v["nombre"]), "premiere": str(v["premiere"])}
	var ids: Variant = cf.get_value("parties", "ids", [])
	if ids is Array:
		for x in ids:
			(d["ids"] as Array).append(str(x))
	return d


static func _ecrire(d: Dictionary, chemin: String) -> bool:
	var cf := ConfigFile.new()
	cf.set_value("meta", "version", VERSION)
	var rec: Dictionary = d["record"]
	for k in rec:
		cf.set_value("record", k, rec[k])
	for id in d["collection"]:
		cf.set_value("collection", id, d["collection"][id])
	cf.set_value("parties", "ids", d["ids"])
	var tmp := chemin + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(cf.encode_to_text() + "\n" + MARQUE_FIN + "\n")
	f.close()
	if FileAccess.file_exists(chemin):
		DirAccess.remove_absolute(chemin)
	return DirAccess.rename_absolute(tmp, chemin) == OK
