extends Node
## Autoload « Partie » : porte la partie en cours (EtatPartie) et fait avancer le temps.
## L'interface écoute les signaux et appelle les actions ; la logique reste dans scripts/logique/.
##
## Pause automatique quand une modale s'ouvre ; après une modale de marché, le jeu reste en pause,
## après les autres, il reprend à la vitesse précédente (03 §3.2).
## Sauvegarde automatique (si sauvegarde_auto) : à chaque mois, après chaque choix et chaque ordre, et à la
## fermeture du jeu. L'état du moteur contient la modale en attente : elle est rouverte à la reprise.

signal partie_commencee
signal mois_passe(resultat: Dictionary)     # après chaque mois (et au premier mois)
signal notif_recue(n: Dictionary)             # une par notification ; n["source"] = maison | banque | media
signal modale_ouverte(contenu: Dictionary)  # contenu prêt à afficher (EtatPartie.contenu_modale)
signal modale_fermee(resultat: Dictionary)
signal vitesse_changee(vitesse: int)
signal partie_finie(bilan: Dictionary)
signal argent_change                        # après un ordre du joueur (achat, vente, livret)
signal saut_change(actif: bool)             # début et fin du saut « jusqu'au prochain courrier »

var etat: EtatPartie = null
var vitesse := 0            # 0 = pause, 1 à 3 = ×1 à ×3
var bloquee := false        # l'interface peut figer le temps (formulaire d'achat ouvert, menu…)
var sauvegarde_auto := false
var chemin_sauvegarde := Sauvegarde.CHEMIN
var _progression := 0.0     # avancement du mois en cours (0 → 1)
var _vitesse_avant_modale := 1   # 0 possible : pause → saut → modale → pause
## Saut « jusqu'au prochain courrier » (P4, docs/15 §1.2) : le temps passe à rythme.json > saut jusqu'au mois
## d'une interruption avec pause. Pendant le saut, vitesse garde la vitesse d'avant l'appui (0 à 3), rétablie
## après la modale (sauf modale de marché : pause, règle existante). Jamais sauvegardé : une reprise repart sans saut.
var saut_actif := false
var _vitesse_avant_saut := 0


## config : voir EtatPartie.demarrer (periode, profil, graine_vie, sans_vie, debut, fin, banquier…).
func nouvelle_partie(config: Dictionary = {}) -> void:
	config = config.duplicate()
	if not config.has("graine_vie"):
		config["graine_vie"] = randi_range(1, 2147483646)  # seul tirage non déterministe
	_finir_saut()
	etat = EtatPartie.new()
	var res := etat.demarrer(config)
	_progression = 0.0
	vitesse = 0
	_vitesse_avant_modale = 1
	partie_commencee.emit()
	_diffuser(res)


## Reprend une partie sauvegardée (Sauvegarde.lire). Renvoie false si elle est inutilisable.
## La modale en attente n'est pas rouverte ici : l'interface appelle rouvrir_modale() quand elle est prête.
func reprendre(d: Dictionary) -> bool:
	var e := Sauvegarde.charger(d)
	if e == null:
		return false
	_finir_saut()
	etat = e
	var p: Dictionary = d.get("partie", {})
	_progression = clampf(float(p.get("progression", 0.0)), 0.0, 0.999)
	_vitesse_avant_modale = clampi(int(p.get("vitesse_avant_modale", 1)), 0, 3)
	vitesse = 0
	partie_commencee.emit()
	mois_passe.emit({"notifs": [], "modale": {}, "fin": etat.fin, "m": etat.m, "saut": true})
	return true


## Après une reprise : la modale qui attendait un choix est présentée de nouveau.
func rouvrir_modale() -> void:
	if etat != null and not etat.modale.is_empty() and etat.fin == "":
		_finir_saut()
		_regler_vitesse(0)
		modale_ouverte.emit(etat.contenu_modale())


func sauvegarder() -> bool:
	if not sauvegarde_auto or etat == null:
		return false
	if etat.fin != "":
		Sauvegarde.effacer(chemin_sauvegarde)
		return false
	return Sauvegarde.ecrire(etat, {"progression": _progression, "vitesse_avant_modale": _vitesse_avant_modale}, chemin_sauvegarde)


func en_cours() -> bool:
	return etat != null and etat.fin == ""


## Choix de vitesse du joueur. Pendant un saut, il l'arrête d'abord (le joueur reprend la main).
func changer_vitesse(v: int) -> void:
	arreter_saut()
	_regler_vitesse(v)


func _regler_vitesse(v: int) -> void:
	vitesse = clampi(v, 0, 3)
	vitesse_changee.emit(vitesse)


## Pause / lecture. Pendant un saut : arrête le saut et met en pause.
func basculer_pause() -> void:
	if saut_actif:
		arreter_saut()
		if vitesse > 0:
			_vitesse_avant_modale = vitesse
		_regler_vitesse(0)
		return
	if vitesse == 0:
		_regler_vitesse(_vitesse_avant_modale if _vitesse_avant_modale > 0 else 1)
	else:
		_vitesse_avant_modale = vitesse
		_regler_vitesse(0)


# ---------- Saut « jusqu'au prochain courrier » (P4, docs/15 §1.2) ----------

## Possible si une partie est en cours, sans modale en attente, temps non bloqué par l'interface, avant le
## dernier mois (décembre 1988), et si aucun saut n'est déjà en cours.
func saut_possible() -> bool:
	return en_cours() and etat.modale.is_empty() and not bloquee and not saut_actif and etat.m < etat.m_fin


## Lance le saut : on avance mois par mois (chaque mois traité normalement : salaire, versements, notifications)
## jusqu'au mois d'une modale, qui l'arrête. Aucun calcul à l'avance. Faux si impossible (voir saut_possible).
func sauter_jusqu_au_prochain_arret() -> bool:
	if not saut_possible():
		return false
	_vitesse_avant_saut = vitesse
	saut_actif = true
	etat.saut_en_cours = true
	saut_change.emit(true)
	return true


## Arrête le saut (nouvel appui) : retour à la vitesse d'avant l'appui, qui n'a pas changé. Sans effet hors saut.
func arreter_saut() -> void:
	if not saut_actif:
		return
	_finir_saut()


func _finir_saut() -> void:
	if etat != null:
		etat.saut_en_cours = false
	if not saut_actif:
		return
	saut_actif = false
	saut_change.emit(false)


## Avancement du mois en cours, de 0 à 1 (pour animer la frise entre deux mois).
## Stocké en fraction : changer de vitesse ou mettre en pause ne fait pas sauter le curseur.
func progression_mois() -> float:
	return clampf(_progression, 0.0, 1.0)


## Durée d'un mois en secondes à la vitesse v (1 à 3 ; la pause compte comme ×1). Réglage : data/rythme.json.
## Pendant un saut : rythme.json > saut.duree_mois_s, quelle que soit v.
func duree_mois_s(v: int = -1) -> float:
	var r: Dictionary = Donnees.charger("rythme")
	if saut_actif:
		return float(r["saut"]["duree_mois_s"])
	if v < 0:
		v = vitesse
	return float(r["duree_mois_s"][clampi(v, 1, 3)])


## Facteur de vitesse du trafic de la rue à la vitesse v (0 en pause). Réglage : data/rythme.json.
## Pendant un saut : rythme.json > saut.trafic, quelle que soit v.
func facteur_trafic(v: int = -1) -> float:
	var r: Dictionary = Donnees.charger("rythme")
	if saut_actif:
		return float(r["saut"]["trafic"])
	if v < 0:
		v = vitesse
	return float(r["trafic"][clampi(v, 0, 3)])


func _process(delta: float) -> void:
	if not en_cours() or (vitesse == 0 and not saut_actif) or bloquee or not etat.modale.is_empty():
		return
	_progression += delta / duree_mois_s(vitesse)
	if _progression >= 1.0:
		_progression = fmod(_progression, 1.0)
		avancer_un_mois()


## Saut rapide (démonstration, F8) : avance sans animation jusqu'au mois m_cible, sans dépasser
## une modale. Les notifications sautées ne sont pas diffusées ; un seul mois_passe final (« saut »).
## resoudre_auto : les modales rencontrées sont résolues par défaut (captures d'écran).
func sauter_jusqu_a(m_cible: int, resoudre_auto := false) -> void:
	if not en_cours():
		return
	arreter_saut()
	var res := {}
	while etat.m < m_cible and etat.fin == "":
		if not etat.modale.is_empty():
			if not resoudre_auto:
				break
			etat.resolution_auto()
		res = etat.avancer()
	_progression = 0.0
	if res.is_empty():
		return
	res["saut"] = true
	res["notifs"] = []
	_diffuser(res)


## Avance d'un mois tout de suite (bouton « mois suivant », tests).
func avancer_un_mois() -> void:
	if not en_cours():
		return
	_diffuser(etat.avancer())


## Pendant un saut : n["pendant_saut"] et res["pendant_saut"] sont vrais ; le saut s'arrête AU mois d'une
## modale (saut_actif faux quand modale_ouverte est émis) ou à la fin de la partie.
func _diffuser(res: Dictionary) -> void:
	var pendant := saut_actif
	res["pendant_saut"] = pendant
	for n in res.get("notifs", []):
		n["pendant_saut"] = pendant
		notif_recue.emit(n)
	mois_passe.emit(res)
	var avec_modale: bool = not res.get("modale", {}).is_empty()
	if avec_modale:
		if saut_actif:
			_vitesse_avant_modale = _vitesse_avant_saut   # 0 si le saut est parti de la pause
		else:
			_vitesse_avant_modale = vitesse if vitesse > 0 else _vitesse_avant_modale
	if avec_modale or res.get("fin", "") != "":
		_finir_saut()
	sauvegarder()
	if avec_modale:
		_regler_vitesse(0)
		modale_ouverte.emit(etat.contenu_modale())
	if res.get("fin", "") != "":
		_regler_vitesse(0)
		partie_finie.emit(Bilan.calculer(etat))


func resoudre_modale(choix_id: String) -> Dictionary:
	if etat == null or etat.modale.is_empty():
		return {}
	var kind: String = etat.modale["kind"]
	var r := etat.resoudre_modale(choix_id)
	modale_fermee.emit(r)
	argent_change.emit()
	sauvegarder()
	if kind != "marche":
		_regler_vitesse(_vitesse_avant_modale)
	return r


# ---------- Actions du joueur (au cours du mois affiché) ----------

func _apres(r: Dictionary) -> Dictionary:
	if r.get("ok", false):
		argent_change.emit()
		sauvegarder()
	return r


func acheter(id: String, budget: float) -> Dictionary:
	return _apres(etat.acheter(etat.joueur, id, budget))


func vendre(id: String, montant: float, tout := false) -> Dictionary:
	return _apres(etat.vendre(etat.joueur, id, montant, tout))


func deposer_livret(montant: float) -> Dictionary:
	return _apres(etat.deposer_livret(etat.joueur, montant))


func retirer_livret(montant: float) -> Dictionary:
	return _apres(etat.retirer_livret(etat.joueur, montant))


func ouvrir_pel(depot: float, mensuel: float) -> Dictionary:
	return _apres(etat.ouvrir_pel(depot, mensuel))


func verser_pel(montant: float) -> Dictionary:
	return _apres(etat.verser_pel(montant))


func cloturer_pel() -> Dictionary:
	return _apres(etat.cloturer_pel())


func acheter_emprunt(montant: float) -> Dictionary:
	return _apres(etat.acheter_emprunt(montant))


func vendre_emprunt(montant: float, tout := false) -> Dictionary:
	return _apres(etat.vendre_emprunt(montant, tout))


func verser_av(montant: float) -> Dictionary:
	return _apres(etat.verser_av(montant))


func racheter_av(montant: float, tout := false) -> Dictionary:
	return _apres(etat.racheter_av(montant, tout))


func programmer_versement(pid: String, montant: float) -> Dictionary:
	return _reglage(etat.programmer_versement(pid, montant))


func arreter_versement(pid: String) -> Dictionary:
	return _reglage(etat.arreter_versement(pid))


func reactiver_versement(pid: String) -> Dictionary:
	return _reglage(etat.reactiver_versement(pid))


## Réglage d'un versement automatique : rien ne bouge sur le compte avant le mois suivant, mais on sauvegarde.
func _reglage(r: Dictionary) -> Dictionary:
	if r.get("ok", false):
		argent_change.emit()
		sauvegarder()
	return r


## Débogage (F6 / F7) : une naissance tout de suite, en courrier (pause automatique comme une modale).
func forcer_naissance(jumeaux: bool) -> void:
	if not en_cours():
		return
	arreter_saut()
	var md := etat.forcer_naissance(jumeaux)
	if not md.is_empty():
		_vitesse_avant_modale = vitesse if vitesse > 0 else _vitesse_avant_modale
		_regler_vitesse(0)
		modale_ouverte.emit(etat.contenu_modale())


func abandonner() -> void:
	if en_cours():
		arreter_saut()
		etat.abandonner()
		_regler_vitesse(0)
		partie_finie.emit(Bilan.calculer(etat))
