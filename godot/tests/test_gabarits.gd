extends SceneTree
## Lot 10a-moteur, M9 : Gabarits (textes sans prénom ni genre en dur). Règles de rendu, élision, majuscules, jetons
## étrangers conservés, contexte d'une partie (Gérard / Sylvie ; joueuse d'essai « Sylvie » avec conjoint « Gérard »).

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var gerard := Gabarits.profil({"prenom": "Gérard", "sexe": "h"}, {"prenom": "Sylvie", "sexe": "f", "lien": "conjoint"}, ["Léa", "Tom"])
	var joueuse := Gabarits.profil({"prenom": "Sylvie", "sexe": "f"}, {"prenom": "Gérard", "sexe": "h", "lien": "conjoint"}, ["Léa"])
	var odette := Gabarits.profil({"prenom": "Christine", "sexe": "f"}, {"prenom": "Odette", "sexe": "f", "lien": "ami"})
	verifier("{prenom} et {conjoint} : Gérard / Sylvie", Gabarits.rendre("{prenom} et {conjoint}", gerard) == "Gérard et Sylvie")
	verifier("Joueuse : {prenom} et {conjoint} = Sylvie / Gérard (aucun prénom de l'autre profil)", Gabarits.rendre("{prenom} et {conjoint}", joueuse) == "Sylvie et Gérard")
	verifier("{e} : « ravi » pour un homme, « ravie » pour une femme", Gabarits.rendre("ravi{e}", gerard) == "ravi" and Gabarits.rendre("ravi{e}", joueuse) == "ravie")
	verifier("{il}, {elle}, {civilite}, {le}, {la}", Gabarits.rendre("{il} / {elle} / {civilite} / {le} / {la}", gerard) == "il / elle / Monsieur / le / la"
		and Gabarits.rendre("{il} / {elle} / {civilite} / {le} / {la}", joueuse) == "elle / il / Madame / la / le")
	verifier("{de_conjoint} : « de Sylvie », « d'Odette » (élision), « d'Hélène »", Gabarits.rendre("{de_conjoint}", gerard) == "de Sylvie" and Gabarits.rendre("{de_proche}", odette) == "d'Odette"
		and Gabarits.rendre("{de_proche}", Gabarits.profil({"prenom": "X"}, {"prenom": "Hélène", "sexe": "f"})) == "d'Hélène")
	verifier("Majuscule conservée : « {Proche} vous verra moins » et « {Elle} »", Gabarits.rendre("{Proche} vous verra moins", gerard) == "Sylvie vous verra moins"
		and Gabarits.rendre("{Il} sourit.", joueuse) == "Elle sourit." and Gabarits.rendre("{Elle} sourit.", gerard) == "Elle sourit.")
	verifier("{prenoms} : enfants joints par « et »", Gabarits.rendre("Bienvenue à {prenoms} !", gerard) == "Bienvenue à Léa et Tom !")
	verifier("Jetons étrangers laissés intacts ({montant}, {taux}) ; texte sans accolade renvoyé tel quel",
		Gabarits.rendre("{prenom} : {montant} à {taux} %", gerard) == "Gérard : {montant} à {taux} %" and Gabarits.rendre("Sans jeton.", gerard) == "Sans jeton.")
	verifier("residuels : repère les jetons non rendus", Gabarits.residuels(Gabarits.rendre("{prenom} {inconnu}", gerard)) == ["{inconnu}"] and Gabarits.residuels("rien").is_empty())
	verifier("Proche absent : {conjoint} rendu vide, aucune erreur", Gabarits.rendre("[{conjoint}]", Gabarits.profil({"prenom": "A"})) == "[]")
	# Contexte d'une vraie partie : Gérard, conjointe Sylvie (banque de 1984)
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(3))
	var ctx := Gabarits.contexte(e)
	verifier("contexte(partie 1984) : joueur Gérard (h), proche Sylvie (f, conjoint)", ctx["joueur"]["prenom"] == "Gérard" and ctx["joueur"]["sexe"] == "h"
		and ctx["proche"]["prenom"] == "Sylvie" and ctx["proche"]["sexe"] == "f" and ctx["proche"]["lien"] == "conjoint")
	var cfg := Donnees.config_demo(3)
	cfg["sexe"] = "f"
	cfg["proche"] = {"prenom": "Patrick", "sexe": "h", "lien": "conjoint"}
	var f := EtatPartie.new()
	f.demarrer(cfg)
	var cf := Gabarits.contexte(f)
	verifier("contexte(config joueuse, proche Patrick) : le genre vient du profil, pas du prénom", cf["joueur"]["sexe"] == "f" and cf["proche"]["prenom"] == "Patrick"
		and Gabarits.rendre("{civilite} {prenom}, {conjoint} et vous", cf) == "Madame Gérard, Patrick et vous")
	print("")
	print("=== test_gabarits : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
