class_name Gabarits
extends RefCounted
## Textes sans genre ni prénom en dur (lot 10a, M9 ; lot_10a.md §1 bis). Un seul rendu pour tout le jeu :
## Gabarits.rendre(texte, contexte) ; le contexte vient de Gabarits.contexte(etat) ou de Gabarits.profil(...).
## Le genre vient du PROFIL (sexe du joueur, sexe du proche), jamais du prénom. Logique pure, sans nœud.
##
## Jetons (la casse de la première lettre est conservée : {Proche} -> « Sylvie », {Elle} -> « Elle ») :
##   {prenom}        prénom du joueur                       {prenoms}   prénoms des enfants, joints par « et »
##   {proche}        prénom du proche (conjoint ou ami)     {conjoint}  idem (alias lisible pour un couple)
##   {de_proche}     « de Sylvie » / « d'Odette » (élision) {de_conjoint} idem
##   {e}             e muet du joueur (« ravi{e} »)         {il}        pronom du joueur : il / elle
##   {elle}          pronom du proche : elle / il           {civilite}  Monsieur / Madame (joueur)
##   {le}            article du joueur : le / la            {la}        article du proche : la / le
## Les autres jetons du jeu ({montant}, {taux}, …) sont laissés tels quels : Format.gabarit les remplit ensuite.
## Un jeton inconnu reste intact (le test de chaque chapitre repère tout « {x} » résiduel).

const VOYELLES := "aeiouyâàäéèêëîïôöûùüœAEIOUYÂÀÄÉÈÊËÎÏÔÖÛÙÜŒHh"


## Profil de rendu : joueur {prenom, sexe "h"|"f"}, proche {prenom, sexe, lien "conjoint"|"ami"} (ou {}), prénoms des enfants.
static func profil(joueur: Dictionary, proche: Dictionary = {}, enfants: Array = []) -> Dictionary:
	return {"joueur": {"prenom": str(joueur.get("prenom", "")), "sexe": _sexe(joueur.get("sexe", "h"))},
		"proche": proche.duplicate(true), "enfants": enfants.duplicate()}


static func _sexe(s: Variant) -> String:
	return "f" if str(s).to_lower() in ["f", "femme", "feminin", "féminin"] else "h"


## Contexte d'une partie. Joueur : sexe de la config (« sexe »), sinon du profil (« sexe » ou « feminin »), sinon homme.
## Proche : config / profil « proche » {prenom, sexe, lien}, à défaut la conjointe de la banque (prénom du chapitre) de
## sexe opposé à celui du joueur (le conjoint change de genre avec le joueur).
static func contexte(e: EtatPartie) -> Dictionary:
	var prof: Dictionary = e.sal["profils"].get(e.profil, {})
	var sexe: Variant = e.config_depart.get("sexe", prof.get("sexe", "f" if bool(prof.get("feminin", false)) else "h"))
	var proche: Dictionary = e.config_depart.get("proche", prof.get("proche", {}))
	if proche.is_empty():
		var nom := str(Banquier.donnees().get("conjointe", ""))
		if nom != "":
			proche = {"prenom": nom, "sexe": "h" if _sexe(sexe) == "f" else "f", "lien": "conjoint"}
	var enfants := []
	for ev in e.calendrier:
		if ev["type"] == "naissance" and ev.get("declenche", false):
			enfants.append_array(ev.get("prenoms", []))
	return profil({"prenom": e.prenom(), "sexe": sexe}, proche, enfants)


static func _elision(prenom: String) -> String:
	if prenom == "":
		return ""
	return ("d'" if VOYELLES.contains(prenom.left(1)) else "de ") + prenom


static func _maj(s: String) -> String:
	return s.left(1).to_upper() + s.substr(1) if s != "" else s


## Remplace les jetons de genre et de prénom ; renvoie le texte (les jetons étrangers restent intacts).
static func rendre(texte: String, ctx: Dictionary) -> String:
	if not texte.contains("{"):
		return texte
	var j: Dictionary = ctx.get("joueur", {})
	var p: Dictionary = ctx.get("proche", {})
	var h := _sexe(j.get("sexe", "h")) == "h"
	var ph := _sexe(p.get("sexe", "f")) == "h"
	var pp := str(p.get("prenom", ""))
	var valeurs := {
		"prenom": str(j.get("prenom", "")), "prenoms": " et ".join(PackedStringArray(ctx.get("enfants", []))),
		"proche": pp, "conjoint": pp, "de_proche": _elision(pp), "de_conjoint": _elision(pp),
		"e": "" if h else "e", "il": "il" if h else "elle", "elle": "il" if ph else "elle",
		"civilite": "Monsieur" if h else "Madame", "le": "le" if h else "la", "la": "le" if ph else "la",
	}
	var sortie := texte
	for cle: String in valeurs:
		sortie = sortie.replace("{" + cle + "}", str(valeurs[cle]))
		var maj := _maj(cle)
		if maj != cle:
			sortie = sortie.replace("{" + maj + "}", _maj(str(valeurs[cle])))
	return sortie


## Jetons de genre ou de prénom restants dans un texte déjà rendu (contrôle des chapitres) : [«{proche}», …].
static func residuels(texte: String) -> Array:
	var out := []
	var rx := RegEx.create_from_string("\\{[A-Za-zÀ-ÿ_]+\\}")
	for m in rx.search_all(texte):
		out.append(m.get_string())
	return out
