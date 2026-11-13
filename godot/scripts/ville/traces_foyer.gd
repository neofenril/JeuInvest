extends RefCounted
## Traces des cartes du foyer sur la maison (lot 04, 03-V2, D11 ; docs/15 §7) : fonctions pures, sans nœud, lues
## par ville.traces_foyer / suivre_foyer et éprouvées par tests/test_pieces.gd. Pas de class_name (preload).
## Règles (décisions des cartes jouées, contrat de 03-foyer `cartes_jouees()`) :
## - tele : C02 « a » ou C03 « a » (lueur bleue de télévision le soir) ; antenne : C03 « a » ;
## - poussette / poussette_double (jumeaux) : C04 jouée, quel que soit le choix, jusqu'à 12/1986 ;
## - tricycle / tricycles (jumeaux) : C04 jouée, à partir de 01/1988 (rien en 1987) ;
## - chien (niche et chien) : C10 jouée, l'un ou l'autre choix ;
## - diplome : C07 « a », à partir de 01/1988 ;
## - escargot : l'historique contient une notification « escargots » (C06 prêtée, jamais rendue en entier).
## Cartes éteintes : aucune trace.

const ORDRE := ["tele", "antenne", "poussette", "poussette_double", "tricycle", "tricycles", "chien", "diplome", "escargot"]


## Traces présentes, dans l'ordre de ORDRE. jouees : [{id, choix, …}] ; ab : mois courant (Dates) ;
## escargots : une notification « escargots » a été reçue.
static func calculer(actives: bool, jouees: Array, ab: int, jumeaux: bool, escargots: bool) -> PackedStringArray:
	var t := {}
	if not actives:
		return PackedStringArray()
	var fin_poussette := Dates.lire("1986-12")
	var debut_1988 := Dates.lire("1988-01")
	for c: Dictionary in jouees:
		var id := str(c.get("id", ""))
		var choix := str(c.get("choix", ""))
		match id:
			"C02":
				if choix == "a":
					t["tele"] = true
			"C03":
				if choix == "a":
					t["tele"] = true
					t["antenne"] = true
			"C04":
				if ab <= fin_poussette:
					t["poussette_double" if jumeaux else "poussette"] = true
				elif ab >= debut_1988:
					t["tricycles" if jumeaux else "tricycle"] = true
			"C10":
				t["chien"] = true
			"C07":
				if choix == "a" and ab >= debut_1988:
					t["diplome"] = true
	if escargots:
		t["escargot"] = true
	var r := PackedStringArray()
	for n in ORDRE:
		if t.has(n):
			r.append(n)
	return r


## Les mêmes traces lues dans une partie (null : aucune).
static func de_partie(e: EtatPartie) -> PackedStringArray:
	if e == null:
		return PackedStringArray()
	var esc := false
	for h: Dictionary in e.historique:
		if str(h.get("type", "")) == "escargots":
			esc = true
			break
	return calculer(e.cartes_actives(), e.cartes_jouees(), e.ab_courant(), Banquier.jumeaux(e), esc)
