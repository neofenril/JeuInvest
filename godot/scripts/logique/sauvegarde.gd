class_name Sauvegarde
extends RefCounted
## Sauvegarde de la partie en cours (demande du joueur du 27/10/2026) : un seul emplacement, dans user://
## (dossier des données de l'application, valable aussi sur Android).
## Format binaire de Godot (var_to_bytes) : les nombres sont restitués au bit près, condition pour que la
## partie reprise suive exactement la même suite d'événements (le format texte perd parfois 1 ulp).
## Fichier : « JCSV » + version (32 bits) + empreinte SHA-256 du contenu + contenu. Tolérant : fichier
## absent, tronqué, modifié ou d'une autre version = pas de sauvegarde, sans erreur. Écriture dans un
## fichier temporaire puis remplacement.

const CHEMIN := "user://partie_en_cours.sav"
const VERSION := 2   # 2 (27/10/2026) : historique des pop-ups, versements automatiques ; les sauvegardes 1 sont ignorées
const MAGIQUE := "JCSV"
const SIGNATURE := "JeuClaude"


static func _empreinte(octets: PackedByteArray) -> PackedByteArray:
	var h := HashingContext.new()
	h.start(HashingContext.HASH_SHA256)
	h.update(octets)
	return h.finish()


## Écrit l'état de la partie. partie : réglages de l'interface à restaurer (vitesse…). Renvoie true si écrit.
static func ecrire(etat: EtatPartie, partie: Dictionary = {}, chemin := CHEMIN) -> bool:
	if etat == null:
		return false
	var a := etat.ab_courant()
	var d := {"jeu": SIGNATURE, "version": VERSION, "ecrite_le": Time.get_datetime_string_from_system(),
		"resume": {"ab": a, "date": Dates.texte(a), "patrimoine": etat.patrimoine(etat.joueur), "prenom": etat.prenom()},
		"partie": partie.duplicate(true), "etat": etat.vers_dict()}
	var contenu := var_to_bytes(d)
	var tmp := chemin + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_buffer(MAGIQUE.to_ascii_buffer())
	f.store_32(VERSION)
	f.store_buffer(_empreinte(contenu))
	f.store_buffer(contenu)
	f.close()
	if FileAccess.file_exists(chemin):
		DirAccess.remove_absolute(chemin)
	return DirAccess.rename_absolute(tmp, chemin) == OK


## Contenu de la sauvegarde ({} si absente, corrompue ou d'une autre version).
static func lire(chemin := CHEMIN) -> Dictionary:
	var source := chemin
	if not FileAccess.file_exists(source):
		source = chemin + ".tmp"
		if not FileAccess.file_exists(source):
			return {}
	var f := FileAccess.open(source, FileAccess.READ)
	if f == null:
		return {}
	var taille := f.get_length()
	if taille < 4 + 4 + 32 + 8:
		f.close()
		return {}
	var magique := f.get_buffer(4).get_string_from_ascii()
	var version := f.get_32()
	var empreinte := f.get_buffer(32)
	var contenu := f.get_buffer(taille - 40)
	f.close()
	if magique != MAGIQUE or version != VERSION or _empreinte(contenu) != empreinte:
		return {}
	var v: Variant = bytes_to_var(contenu)
	if not v is Dictionary:
		return {}
	var d: Dictionary = v
	if d.get("jeu", "") != SIGNATURE or int(d.get("version", -1)) != VERSION or not d.get("etat", null) is Dictionary:
		return {}
	if not d.get("resume", null) is Dictionary or not d.get("partie", null) is Dictionary:
		return {}
	return d


static func existe(chemin := CHEMIN) -> bool:
	return not lire(chemin).is_empty()


## Recrée la partie sauvegardée (null si la sauvegarde est inutilisable).
static func charger(d: Dictionary) -> EtatPartie:
	if d.is_empty():
		return null
	return EtatPartie.depuis_dict(d["etat"])


static func effacer(chemin := CHEMIN) -> void:
	for p in [chemin, chemin + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)
