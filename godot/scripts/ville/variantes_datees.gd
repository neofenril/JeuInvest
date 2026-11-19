extends RefCounted
## Variantes datées du décor (lot 10b-ville, V2 ; docs/40 §1.3) : fonction pure. Les dates vivent dans les données
## du thème (data/themes/<id>.json > variantes_datees : [{"debut": "AAAA-MM", "fin": "AAAA-MM" ou "" (sans fin), "effet": …}]),
## jamais dans le code. Aucune variante avant 01/1989 dans le thème « 1980 » : la rue de 1984-1988 reste identique.
## Rien n'annonce un événement de marché (A5) : des détails de la vie de la rue seulement.

const EFFETS := ["bonne_annee", "bicentenaire", "citadine_1990", "panneaux_vote", "citadine_1993"]


## Jetons des variantes actives le mois ab (Dates) : « bonne_annee:1990 » porte l'année affichée.
static func actives(liste: Array, ab: int) -> PackedStringArray:
	var r := PackedStringArray()
	for v in liste:
		if typeof(v) != TYPE_DICTIONARY:
			continue
		var effet := str(v.get("effet", ""))
		if not effet in EFFETS:
			continue
		var debut := str(v.get("debut", ""))
		if debut == "" or ab < Dates.lire(debut):
			continue
		var fin := str(v.get("fin", ""))
		if fin != "" and ab > Dates.lire(fin):
			continue
		var jeton := "%s:%d" % [effet, Dates.annee(ab)] if effet == "bonne_annee" else effet
		if not jeton in r:
			r.append(jeton)
	return r
