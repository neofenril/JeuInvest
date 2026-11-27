class_name Bilan
extends RefCounted
## Mini-bilan de fin de partie (03 §7.7-7.9, réduit) : les 4 patrimoines en € d'aujourd'hui,
## classement face aux témoins, objectif « battre l'inflation » (baguettes), étoiles, réplique, leçons.

const IDS := ["vous", "matelas", "livret", "indice"]


## Projets du foyer pour l'écran de fin : {"realises", "total", "liste": [{"id", "nom", "etat"}]} ; une ligne par projet
## (option choisie si elle l'a été, sinon le projet lui-même). Projets éteints : 0 sur 0, liste vide.
static func _projets(e: EtatPartie) -> Dictionary:
	var out := {"realises": 0, "total": 0, "liste": []}
	if not Projets.actif(e):
		return out
	# Lot 10d (A2) : tous les chapitres traversés (projets terminés rangés « 1984:P1 » en tête, puis ceux du chapitre courant) :
	# « réalisés » et « total » comptent sur la même base.
	var etats: Dictionary = e.projets["projets"]
	var cles: Array = etats.keys().filter(func(k: Variant) -> bool: return str(k).contains(":"))
	for p: Dictionary in Projets.donnees()["projets"]:
		if etats.has(str(p["id"])) and not cles.has(str(p["id"])):
			cles.append(str(p["id"]))
	for cle in etats.keys():
		if not cles.has(cle):
			cles.append(cle)
	for cle: String in cles:
		var s: Dictionary = etats[cle]
		var pid := cle.get_slice(":", 1) if cle.contains(":") else cle
		var chapitre := Projets.chapitre_de_cle(cle, s)   # les ids sont les mêmes d'un chapitre à l'autre
		var def := Projets._def(pid, chapitre)
		var id := pid
		var nom := str(def.get("titre", pid))
		if str(s["option"]) != "":
			var o: Dictionary = Projets._option(str(s["option"]), chapitre).get("option", {})
			id = str(o.get("id", s["option"]))
			nom = str(o.get("nom", nom))
		out["liste"].append({"id": id, "nom": nom, "etat": str(s["etat"])})
	out["total"] = (out["liste"] as Array).size()
	out["realises"] = Titres.projets_realises(e)
	return out


static func calculer(e: EtatPartie) -> Dictionary:
	var b := _calculer(e)
	_ajouts_chapitres(e, b)
	return b


static func _calculer(e: EtatPartie) -> Dictionary:
	var a := e.ab_courant()
	var nominal := {
		"vous": e.patrimoine(e.joueur),
		"matelas": e.patrimoine(e.temoins["matelas"]),
		"livret": e.patrimoine(e.temoins["livret"]),
		"indice": e.patrimoine(e.temoins["indice"]),
	}
	var auj := {}
	var bag := {}
	for k in IDS:
		auj[k] = Marche.euros_aujourdhui(nominal[k], a)
		bag[k] = nominal[k] / Marche.baguette(a)
	var classement := []
	for k in IDS:
		classement.append({"id": k, "valeur": auj[k], "nominal": nominal[k]})
	classement.sort_custom(func(x: Dictionary, y: Dictionary) -> bool: return x["valeur"] > y["valeur"])

	# Objectif « battre l'inflation » : patrimoine en baguettes >= baguettes mises de côté
	var atteint: bool = bag["vous"] >= e.bag_mis and e.fin != "faillite"
	var battus := {}
	var nb_battus := 0
	for k in ["matelas", "livret", "indice"]:
		battus[k] = nominal["vous"] > nominal[k]
		if battus[k]:
			nb_battus += 1
	var sang_froid: bool = e.stats["paniques"].is_empty()
	var temoins := Donnees.temoins()
	var etoiles := [
		{"ok": atteint, "regle": "Battre l'inflation : finir avec plus de baguettes que vous n'en avez mis de côté."},
		{"ok": battus["matelas"], "regle": "Battre %s (%s)" % [temoins["matelas"]["nom"], str(temoins["matelas"]["regle"]).to_lower()]},
		{"ok": battus["livret"], "regle": "Battre %s (%s)" % [temoins["livret"]["nom"], str(temoins["livret"]["regle"]).to_lower()]},
		{"ok": battus["indice"], "regle": "Battre %s (%s)" % [temoins["indice"]["nom"], str(temoins["indice"]["regle"]).to_lower()]},
		{"ok": sang_froid, "regle": "Sang-froid : ne jamais vendre en panique pendant une baisse."},
	]
	var nb_etoiles := 0
	for et in etoiles:
		if et["ok"]:
			nb_etoiles += 1

	# Réplique : le premier témoin s'il est devant vous ; sinon le deuxième vous félicite
	var replique: Dictionary
	if classement[0]["id"] == "vous":
		var second: String = classement[1]["id"]
		replique = {"temoin": second, "nom": temoins[second]["nom"], "texte": temoins[second]["derriere"]}
	else:
		var premier: String = classement[0]["id"]
		replique = {"temoin": premier, "nom": temoins[premier]["nom"], "texte": temoins[premier]["devant"]}

	# Leçons : celles des événements de marché vécus
	var lecons := []
	for c in e.choix:
		if str(c.get("lecon", "")) != "":
			lecons.append(c["lecon"])

	var rue := e.classement_rue()
	var phrases: Dictionary = Titres.donnees()["objectif"]
	return {
		"a": a, "fin": e.fin, "nominal": nominal, "auj": auj, "bag": bag, "classement": classement,
		"objectif": {"atteint": atteint, "bag_patrimoine": bag["vous"], "bag_mis": e.bag_mis,
			"phrase": str(phrases["atteint" if atteint else "non_atteint"])},
		# Lot 07-L : titre d'époque ({} si abandon ou faillite), écart final face à Tata Livret (le record), humeur, projets
		"titre": Titres.calculer(e), "ecart_tata_pct": 100.0 * Titres.ecart_tata(e), "prenom": e.prenom(),
		"humeur_fin": e.humeur_visible(), "humeur_phrase": e.humeur_phrase(), "projets": _projets(e),
		"retours": e.retours, "record_possible": e.retours == 0 and e.fin == "fin",
		"battus": battus, "nb_battus": nb_battus, "etoiles": etoiles, "nb_etoiles": nb_etoiles,
		"replique": replique, "lecons": lecons, "epargne_nette": e.epargne_nette,
		"frais": e.stats["frais"], "impots": e.stats["impots"], "interets": e.joueur.interets_total,
		"rue": rue, "replique_rue": Quartier.replique_rue(rue) if not rue.is_empty() else {},
		# Lot 09-L (D8) : chapitre de départ et années jouées (un seul bilan final ; un titre par chapitre au lot 10)
		"chapitre_depart": str(e.config_depart.get("chapitre", Donnees.index().get("chapitre_defaut", ""))),
		"annee_depart": Dates.annee(e.ab_de(e.m_depart)), "annee_fin": Dates.annee(e.ab_de(e.m_fin)),
	}


## Champs du lot 10a (M3/M4) ajoutés au bilan : un titre par chapitre traversé, record de chapitre (écart à la fin des 5 ans du
## chapitre de départ) et record de partie (écart à la fin de la partie), hors_record.
static func _ajouts_chapitres(e: EtatPartie, b: Dictionary) -> void:
	var titres := []
	for id: String in e.chapitres_traverses():
		if e.chapitres_bilan.has(id):
			var t: Dictionary = (e.chapitres_bilan[id]["titre"] as Dictionary).duplicate()
			t["chapitre"] = id
			titres.append(t)
	var dernier: Dictionary = b["titre"]
	if not dernier.is_empty():
		var d2 := dernier.duplicate()
		d2["chapitre"] = e.chapitre
		titres.append(d2)
	var rang := Quartier.rang_de(b["rue"]) if not (b["rue"] as Array).is_empty() else 0
	var partie := {"ecart_pct": b["ecart_tata_pct"], "rang": rang, "annee_fin": b["annee_fin"]}
	var depart: Dictionary = e.chapitres_bilan.get(e.chapitre_depart, {})
	var chap := partie.duplicate()
	if not depart.is_empty():
		chap = {"ecart_pct": float(depart["ecart_pct"]), "rang": int(depart["rang"]), "annee_fin": int(depart["annee_fin"])}
	b["titres"] = titres
	b["record_chapitre"] = chap
	b["record_partie"] = partie
	b["hors_record"] = not bool(b["record_possible"])
	b["version_contenu"] = int(Donnees.infos_chapitre(e.chapitre_depart).get("version_contenu", 1))

