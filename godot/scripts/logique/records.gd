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
## Format 2 (lot 10a, M4) : un record de chapitre et des records de partie par chapitre de départ, une collection par
## chapitre. Sections : [meta] version=2 ; [chapitre_<id>] record_chapitre = {...}, records_partie = {"<annee_fin>": {...}} ;
## [collection_<id>] <id du titre> = {nombre, premiere} ; [parties] ids. Le format 1 (record et collection uniques) est
## migré à la lecture : son record devient le record de chapitre de « 1984 », sa collection celle de « 1984 ».
## Record de chapitre = écart face à Tata Livret à la fin des 5 ans du chapitre de départ ; record de partie = écart à la fin
## de la partie, rangé par chapitre de départ et année de fin (docs/40 §3.1).

const CHEMIN := "user://records.sav"
const VERSION := 2
const MARQUE_FIN := "; fin"
const IDS_MAX := 200
const CHAPITRE_V1 := "1984"


## { "chapitres": { id: { "record_chapitre": {} | {...}, "records_partie": { "AAAA": {...} }, "collection": { titre: {nombre, premiere} } } },
##   "record" / "collection" : ceux du chapitre par défaut (vue de compatibilité du lot 07) }
static func lire(chemin := CHEMIN) -> Dictionary:
	var d := _charger(chemin)
	var defaut := str(Donnees.index().get("chapitre_defaut", CHAPITRE_V1))
	var ch: Dictionary = (d["chapitres"] as Dictionary).get(defaut, _chapitre_vide())
	return {"chapitres": d["chapitres"], "record": ch["record_chapitre"], "collection": ch["collection"]}


## Compte la partie finie (bilan de Bilan.calculer) : chaque titre de bilan["titres"] (à défaut bilan["titre"]) va dans la
## collection de SON chapitre ; record de chapitre et record de partie si strictement meilleurs (égalité : l'ancien reste).
## Rien n'est écrit sans titre (abandon, faillite) ; avec record_possible faux (retours), seule la collection avance ; une
## partie (id_partie) déjà comptée ne l'est pas deux fois. date : « AAAA-MM-JJ » (défaut : aujourd'hui, horloge réelle).
## Renvoie {"ecrit", "deja_compte", "hors_record", "nouveau", "nouveau_chapitre", "nouveau_partie", "ancien", "record",
## "collection", "nouveau_titre", "nouveaux_titres": [{chapitre, id}]}.
static func enregistrer(bilan: Dictionary, id_partie: String, chemin := CHEMIN, date := "") -> Dictionary:
	var d := _charger(chemin)
	var titre: Dictionary = bilan.get("titre", {})
	var hors := not bool(bilan.get("record_possible", false)) or bool(bilan.get("hors_record", false))
	var chap := str(bilan.get("chapitre_depart", CHAPITRE_V1))
	var ch: Dictionary = _chapitre(d, chap)
	var r := {"ecrit": false, "deja_compte": false, "hors_record": hors, "nouveau": false, "nouveau_chapitre": false, "nouveau_partie": false,
		"ancien": (ch["record_chapitre"] as Dictionary).duplicate(true), "record": ch["record_chapitre"], "collection": ch["collection"],
		"nouveau_titre": false, "nouveaux_titres": []}
	if titre.is_empty():
		return r
	if id_partie != "" and (d["ids"] as Array).has(id_partie):
		r["deja_compte"] = true
		return r
	var jour := date if date != "" else Time.get_date_string_from_system()
	var titres: Array = bilan.get("titres", [])
	if titres.is_empty():
		titres = [titre]
	for t: Dictionary in titres:
		var cc: Dictionary = _chapitre(d, str(t.get("chapitre", chap)))
		var coll: Dictionary = cc["collection"]
		var tid := str(t["id"])
		var ligne: Dictionary = coll.get(tid, {})
		var nombre := int(ligne.get("nombre", 0)) + 1
		coll[tid] = {"nombre": nombre, "premiere": str(ligne.get("premiere", jour))}
		if nombre == 1:
			(r["nouveaux_titres"] as Array).append({"chapitre": str(t.get("chapitre", chap)), "id": tid})
			if tid == str(titre["id"]):
				r["nouveau_titre"] = true
	if not hors:
		var annee_fin := str(int(bilan.get("annee_fin", 0)))
		var rc: Dictionary = bilan.get("record_chapitre", {})
		var rp: Dictionary = bilan.get("record_partie", {})
		var pct := snappedf(float(bilan.get("ecart_tata_pct", 0.0)), 0.0001)
		if rc.is_empty():
			rc = {"ecart_pct": pct, "rang": _rang(bilan), "annee_fin": int(bilan.get("annee_fin", 0))}
		if rp.is_empty():
			rp = {"ecart_pct": pct, "rang": _rang(bilan), "annee_fin": int(bilan.get("annee_fin", 0))}
		var ancien: Dictionary = ch["record_chapitre"]
		var pct_c := snappedf(float(rc["ecart_pct"]), 0.0001)
		if ancien.is_empty() or pct_c > float(ancien["ecart_pct"]):
			r["nouveau"] = true
			r["nouveau_chapitre"] = true
			ch["record_chapitre"] = {"ecart_pct": pct_c, "rang": int(rc.get("rang", 0)), "annee_fin": int(rc.get("annee_fin", 0)),
				"titre_id": str(titre["id"]), "titre_nom": str(titre["nom"]), "prenom": str(bilan.get("prenom", "")),
				"patrimoine": float(bilan.get("nominal", {}).get("vous", 0.0)), "date_reelle": jour,
				"version_contenu": int(bilan.get("version_contenu", 1))}
		var parties: Dictionary = ch["records_partie"]
		var pct_p := snappedf(float(rp["ecart_pct"]), 0.0001)
		if not parties.has(annee_fin) or pct_p > float((parties[annee_fin] as Dictionary)["ecart_pct"]):
			r["nouveau_partie"] = true
			parties[annee_fin] = {"ecart_pct": pct_p, "rang": int(rp.get("rang", 0)), "annee_fin": int(rp.get("annee_fin", 0))}
	if id_partie != "":
		(d["ids"] as Array).append(id_partie)
		while (d["ids"] as Array).size() > IDS_MAX:
			(d["ids"] as Array).pop_front()
	r["record"] = ch["record_chapitre"]
	r["collection"] = ch["collection"]
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


static func _chapitre_vide() -> Dictionary:
	return {"record_chapitre": {}, "records_partie": {}, "collection": {}}


static func _vide() -> Dictionary:
	return {"chapitres": {}, "ids": []}


static func _chapitre(d: Dictionary, id: String) -> Dictionary:
	if not (d["chapitres"] as Dictionary).has(id):
		d["chapitres"][id] = _chapitre_vide()
	return d["chapitres"][id]


static func _charger(chemin: String) -> Dictionary:
	if not FileAccess.file_exists(chemin):
		return _vide()
	var texte := FileAccess.get_file_as_string(chemin)
	if not texte.strip_edges().ends_with(MARQUE_FIN) or not texte.begins_with("[meta]"):
		return _vide()
	var cf := ConfigFile.new()
	if cf.parse(texte) != OK:
		return _vide()
	var version := int(cf.get_value("meta", "version", -1))
	var d := _vide()
	if version == 1:
		var ch := _chapitre(d, CHAPITRE_V1)
		var rec := _lire_record(cf, "record")
		if not rec.is_empty():
			rec["annee_fin"] = 1988
			ch["record_chapitre"] = rec
		ch["collection"] = _lire_collection(cf, "collection")
	elif version == VERSION:
		for s in cf.get_sections():
			if s.begins_with("chapitre_"):
				var ch2 := _chapitre(d, s.trim_prefix("chapitre_"))
				ch2["record_chapitre"] = _lire_record(cf, s, "record_chapitre")
				var rp: Variant = cf.get_value(s, "records_partie", {})
				if rp is Dictionary:
					for k in rp:
						var v: Variant = rp[k]
						if v is Dictionary and (v as Dictionary).has("ecart_pct"):
							ch2["records_partie"][str(k)] = {"ecart_pct": float(v["ecart_pct"]), "rang": int(v.get("rang", 0)), "annee_fin": int(v.get("annee_fin", 0))}
			elif s.begins_with("collection_"):
				_chapitre(d, s.trim_prefix("collection_"))["collection"] = _lire_collection(cf, s)
	else:
		return _vide()
	var ids: Variant = cf.get_value("parties", "ids", [])
	if ids is Array:
		for x in ids:
			(d["ids"] as Array).append(str(x))
	return d


const CHAMPS_RECORD := ["ecart_pct", "rang", "titre_id", "titre_nom", "prenom", "patrimoine", "date_reelle"]


## Record d'une section : format 1 = clés à plat dans la section ; format 2 = un dictionnaire sous la clé « cle ».
static func _lire_record(cf: ConfigFile, section: String, cle := "") -> Dictionary:
	var rec := {}
	if not cf.has_section(section):
		return rec
	if cle != "":
		var v: Variant = cf.get_value(section, cle, {})
		if not (v is Dictionary) or not (v as Dictionary).has("ecart_pct"):
			return {}
		rec = (v as Dictionary).duplicate()
	else:
		for k in CHAMPS_RECORD:
			if not cf.has_section_key(section, k):
				return {}
			rec[k] = cf.get_value(section, k)
	if not rec.has("ecart_pct"):
		return {}
	rec["ecart_pct"] = float(rec["ecart_pct"])
	rec["rang"] = int(rec.get("rang", 0))
	rec["patrimoine"] = float(rec.get("patrimoine", 0.0))
	rec["annee_fin"] = int(rec.get("annee_fin", 0))
	for k in ["titre_id", "titre_nom", "prenom", "date_reelle"]:
		rec[k] = str(rec.get(k, ""))
	return rec


static func _lire_collection(cf: ConfigFile, section: String) -> Dictionary:
	var out := {}
	if cf.has_section(section):
		for id in cf.get_section_keys(section):
			var v: Variant = cf.get_value(section, id)
			if v is Dictionary and (v as Dictionary).has("nombre") and (v as Dictionary).has("premiere"):
				out[id] = {"nombre": int(v["nombre"]), "premiere": str(v["premiere"])}
	return out


static func _ecrire(d: Dictionary, chemin: String) -> bool:
	var cf := ConfigFile.new()
	cf.set_value("meta", "version", VERSION)
	for id in d["chapitres"]:
		var ch: Dictionary = d["chapitres"][id]
		cf.set_value("chapitre_" + id, "record_chapitre", ch["record_chapitre"])
		cf.set_value("chapitre_" + id, "records_partie", ch["records_partie"])
		for tid in ch["collection"]:
			cf.set_value("collection_" + id, tid, ch["collection"][tid])
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
