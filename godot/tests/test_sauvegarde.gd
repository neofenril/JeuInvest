extends Node
## Tests de la sauvegarde au format 3 et de la migration douce (T14 ; feuille de route §2, CA-L5).
## Scène : l'autoload Partie est nécessaire (sauvegarde pendant un saut). Tout est synchrone dans _ready.
## Lancer : Godot_console.exe --headless --path godot res://tests/test_sauvegarde.tscn
## Fichiers : user://test_sauvegarde_<pid>.sav seulement (effacé à la fin) ; jamais partie_en_cours.sav.

var _ok := 0
var _ko := 0


func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	_tests_format2()
	_tests_migration()
	_tests_saut()
	Sauvegarde.effacer(_chemin())
	print("")
	print("=== test_sauvegarde : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	get_tree().quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		_ko += 1
		print("KO  ", nom, ("  [" + detail + "]") if detail != "" else "")


func _chemin() -> String:
	return "user://test_sauvegarde_%d.sav" % OS.get_process_id()


## Fichier au bon format (en-tête, empreinte) mais au contenu choisi.
func _ecrire_brut(chemin: String, version: int, d: Dictionary) -> void:
	var contenu := var_to_bytes(d)
	var h := HashingContext.new()
	h.start(HashingContext.HASH_SHA256)
	h.update(contenu)
	var f := FileAccess.open(chemin, FileAccess.WRITE)
	f.store_buffer("JCSV".to_ascii_buffer())
	f.store_32(version)
	f.store_buffer(h.finish())
	f.store_buffer(contenu)
	f.close()


func _partie(g: int, jusqu_a: String, actif: bool) -> EtatPartie:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(g))
	StrategieTest.aller_a(e, Dates.lire(jusqu_a), actif)
	return e


func _jusqu_au_bout(e: EtatPartie) -> void:
	var garde := 0
	while e.fin == "" and garde < 400:
		garde += 1
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()


# ---------------------------------------------------------------------

func _tests_format2() -> void:
	verifier("Format : Sauvegarde.VERSION = 3, EtatPartie.VERSION_ETAT = 3", Sauvegarde.VERSION == 3 and EtatPartie.VERSION_ETAT == 3)
	var e := _partie(7, "1986-03", true)
	var ancien := e.vers_dict()
	ancien["version_etat"] = 2
	ancien.erase("flux_mois")
	_ecrire_brut(_chemin(), 2, {"jeu": "JeuClaude", "version": 2, "resume": {"ab": e.ab_courant(), "date": "mars 1986", "patrimoine": 1.0, "prenom": "Gérard"},
		"partie": {"progression": 0.5, "vitesse_avant_modale": 1}, "etat": ancien})
	verifier("Sauvegarde du format 2 : ignorée proprement (lire() = {}, existe() faux : l'écran titre ne propose pas « Continuer »)",
		Sauvegarde.lire(_chemin()).is_empty() and not Sauvegarde.existe(_chemin()) and Sauvegarde.charger(Sauvegarde.lire(_chemin())) == null)
	# Même contenu d'état annoncé comme format 3 mais version d'état 2 : refusé aussi
	_ecrire_brut(_chemin(), 3, {"jeu": "JeuClaude", "version": 3, "resume": {}, "partie": {}, "etat": ancien})
	verifier("État de version 2 dans un fichier de format 3 : rechargement refusé proprement", Sauvegarde.charger(Sauvegarde.lire(_chemin())) == null)
	Sauvegarde.effacer(_chemin())


## Pour chaque champ de l'état sauvegardé : le retirer, recharger → valeur par défaut, et la partie va au bout.
func _tests_migration() -> void:
	var cas := []
	var e1 := _partie(7, "1987-06", true)
	cas.append(["juin 1987, sans modale", e1])
	var e2 := EtatPartie.new()
	e2.demarrer(Donnees.config_demo(11))
	StrategieTest.aller_a_modale(e2, "naissance", true)
	cas.append(["avril 1985, faire-part ouvert", e2])
	var ok_lu := true
	var ok_defaut := true
	var ok_fin := true
	var nb := 0
	var detail := ""
	for c in cas:
		var e: EtatPartie = c[1]
		var complet := e.vers_dict()
		var defaut := EtatPartie.defauts_etat(e.config_depart)
		for k in complet.keys():
			var d := complet.duplicate(true)
			d.erase(k)
			_ecrire_brut(_chemin(), 3, {"jeu": "JeuClaude", "version": 3, "resume": {}, "partie": {}, "etat": d})
			var lu := Sauvegarde.lire(_chemin())
			var r := Sauvegarde.charger(lu)
			nb += 1
			if lu.is_empty() or r == null:
				ok_lu = false
				detail += "%s : %s → illisible ; " % [c[0], k]
				continue
			var obtenu := r.vers_dict()
			var attendu: Variant = defaut.get(k, null)
			var bon := true
			match k:
				"version_etat":
					bon = int(obtenu["version_etat"]) == EtatPartie.VERSION_ETAT
				"config":
					bon = var_to_str(r.config_depart) == var_to_str(Donnees.config_demo())
				"banque":
					# _reparer retire de « en_file » ce qui n'est plus en file (la file par défaut est vide)
					var b1: Dictionary = obtenu["banque"].duplicate(true)
					var b2: Dictionary = (attendu as Dictionary).duplicate(true)
					b1.erase("en_file")
					b2.erase("en_file")
					bon = var_to_str(b1) == var_to_str(b2) and (obtenu["banque"]["en_file"] as Dictionary).is_empty()
				_:
					bon = var_to_str(obtenu[k]) == var_to_str(attendu)
			if not bon:
				ok_defaut = false
				detail += "%s : %s ≠ défaut ; " % [c[0], k]
			if not (lu["resume"] as Dictionary).has_all(["ab", "date", "patrimoine", "prenom"]):
				ok_lu = false
			_jusqu_au_bout(r)
			if r.fin == "":
				ok_fin = false
				detail += "%s : sans %s, la partie ne finit pas ; " % [c[0], k]
	Sauvegarde.effacer(_chemin())
	if detail != "":
		print("    ", detail.left(1500))
	verifier("Migration douce : sans chacun des %d champs (2 moments, dont une modale ouverte), la sauvegarde se recharge (résumé recalculé)" % (nb / 2), ok_lu and nb > 40, "%d rechargements" % nb)
	verifier("Migration douce : le champ retiré prend sa valeur par défaut (table unique EtatPartie.defauts_etat)", ok_defaut)
	verifier("Migration douce : chaque partie rechargée va jusqu'à la fin, sans erreur", ok_fin)
	# Sauvegarde complète : identique après rechargement (aucune valeur par défaut ne s'y mêle)
	var e3 := EtatPartie.depuis_dict(bytes_to_var(var_to_bytes(e1.vers_dict())))
	verifier("Sauvegarde complète : état identique après rechargement", e3 != null and var_to_str(e3.vers_dict()) == var_to_str(e1.vers_dict()))
	# Dictionnaire incomplet (clé nouvelle d'un lot futur absente de banque) : complété
	var d4 := e1.vers_dict()
	d4["banque"].erase("compteurs")
	d4["stats"].erase("utilises")
	var e4 := EtatPartie.depuis_dict(d4)
	verifier("Migration douce : clés absentes de banque et stats complétées", e4 != null and e4.banque.has("compteurs") and e4.stats.has("utilises")
		and int(e4.banque["interruptions"]) == int(e1.banque["interruptions"]))


## Sauvegarde automatique pendant un saut : la reprise repart sans saut, au même mois.
func _tests_saut() -> void:
	var chemin_avant := Partie.chemin_sauvegarde
	Partie.chemin_sauvegarde = _chemin()
	Partie.sauvegarde_auto = true
	Partie.nouvelle_partie(Donnees.config_demo(7))
	Partie.resoudre_modale("plus_tard")
	Partie.changer_vitesse(1)
	Partie.sauter_jusqu_au_prochain_arret()
	Partie._process(1.4)   # un mois traversé pendant le saut : sauvegarde automatique
	var m_sauve := Partie.etat.m
	var en_saut := Partie.saut_actif
	var non_lues := Partie.etat.non_lues()
	var d := Sauvegarde.lire(_chemin())
	Partie.arreter_saut()
	Partie.sauvegarde_auto = false
	Partie.nouvelle_partie(Donnees.config_demo(3))   # une autre partie entre-temps
	var repris := Partie.reprendre(d)
	verifier("Sauvegarde pendant un saut : reprise sans saut, au même mois, non lues conservées",
		en_saut and repris and not Partie.saut_actif and not Partie.etat.saut_en_cours and Partie.etat.m == m_sauve and m_sauve > Partie.etat.m_depart
		and Partie.vitesse == 0 and Partie.etat.non_lues() == non_lues,
		"mois %s, %d non lue(s)" % [Dates.texte_court(Partie.etat.ab_courant()), non_lues])
	Partie.chemin_sauvegarde = chemin_avant
	Sauvegarde.effacer(_chemin())
	verifier("Fichier de test effacé ; chemin du joueur rétabli", not FileAccess.file_exists(_chemin()) and Partie.chemin_sauvegarde == Sauvegarde.CHEMIN)
