class_name Bilan
extends RefCounted
## Mini-bilan de fin de partie (03 §7.7-7.9, réduit) : les 4 patrimoines en € d'aujourd'hui,
## classement face aux témoins, objectif « battre l'inflation » (baguettes), étoiles, réplique, leçons.

const IDS := ["vous", "matelas", "livret", "indice"]


static func calculer(e: EtatPartie) -> Dictionary:
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

	return {
		"a": a, "fin": e.fin, "nominal": nominal, "auj": auj, "bag": bag, "classement": classement,
		"objectif": {"atteint": atteint, "bag_patrimoine": bag["vous"], "bag_mis": e.bag_mis},
		"battus": battus, "nb_battus": nb_battus, "etoiles": etoiles, "nb_etoiles": nb_etoiles,
		"replique": replique, "lecons": lecons, "epargne_nette": e.epargne_nette,
		"frais": e.stats["frais"], "impots": e.stats["impots"], "interets": e.joueur.interets_total,
	}
