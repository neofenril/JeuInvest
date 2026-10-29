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

var etat: EtatPartie = null
var vitesse := 0            # 0 = pause, 1 à 3 = ×1 à ×3
var bloquee := false        # l'interface peut figer le temps (formulaire d'achat ouvert, menu…)
var sauvegarde_auto := false
var chemin_sauvegarde := Sauvegarde.CHEMIN
var _progression := 0.0     # avancement du mois en cours (0 → 1)
var _vitesse_avant_modale := 1


## config : voir EtatPartie.demarrer (periode, profil, graine_vie, sans_vie, debut, fin, banquier…).
func nouvelle_partie(config: Dictionary = {}) -> void:
	config = config.duplicate()
	if not config.has("graine_vie"):
		config["graine_vie"] = randi_range(1, 2147483646)  # seul tirage non déterministe
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
	etat = e
	var p: Dictionary = d.get("partie", {})
	_progression = clampf(float(p.get("progression", 0.0)), 0.0, 0.999)
	_vitesse_avant_modale = clampi(int(p.get("vitesse_avant_modale", 1)), 1, 3)
	vitesse = 0
	partie_commencee.emit()
	mois_passe.emit({"notifs": [], "modale": {}, "fin": etat.fin, "m": etat.m, "saut": true})
	return true


## Après une reprise : la modale qui attendait un choix est présentée de nouveau.
func rouvrir_modale() -> void:
	if etat != null and not etat.modale.is_empty() and etat.fin == "":
		changer_vitesse(0)
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


func changer_vitesse(v: int) -> void:
	vitesse = clampi(v, 0, 3)
	vitesse_changee.emit(vitesse)


func basculer_pause() -> void:
	if vitesse == 0:
		changer_vitesse(_vitesse_avant_modale if _vitesse_avant_modale > 0 else 1)
	else:
		_vitesse_avant_modale = vitesse
		changer_vitesse(0)


## Avancement du mois en cours, de 0 à 1 (pour animer la frise entre deux mois).
## Stocké en fraction : changer de vitesse ou mettre en pause ne fait pas sauter le curseur.
func progression_mois() -> float:
	return clampf(_progression, 0.0, 1.0)


## Durée d'un mois en secondes à la vitesse v (1 à 3 ; la pause compte comme ×1). Réglage : data/rythme.json.
func duree_mois_s(v: int = -1) -> float:
	if v < 0:
		v = vitesse
	return float(Donnees.charger("rythme")["duree_mois_s"][clampi(v, 1, 3)])


## Facteur de vitesse du trafic de la rue à la vitesse v (0 en pause). Réglage : data/rythme.json.
func facteur_trafic(v: int = -1) -> float:
	if v < 0:
		v = vitesse
	return float(Donnees.charger("rythme")["trafic"][clampi(v, 0, 3)])


func _process(delta: float) -> void:
	if not en_cours() or vitesse == 0 or bloquee or not etat.modale.is_empty():
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


func _diffuser(res: Dictionary) -> void:
	for n in res.get("notifs", []):
		notif_recue.emit(n)
	mois_passe.emit(res)
	if not res.get("modale", {}).is_empty():
		_vitesse_avant_modale = vitesse if vitesse > 0 else _vitesse_avant_modale
	sauvegarder()
	if not res.get("modale", {}).is_empty():
		changer_vitesse(0)
		modale_ouverte.emit(etat.contenu_modale())
	if res.get("fin", "") != "":
		changer_vitesse(0)
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
		changer_vitesse(_vitesse_avant_modale)
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
	var md := etat.forcer_naissance(jumeaux)
	if not md.is_empty():
		_vitesse_avant_modale = vitesse if vitesse > 0 else _vitesse_avant_modale
		changer_vitesse(0)
		modale_ouverte.emit(etat.contenu_modale())


func abandonner() -> void:
	if en_cours():
		etat.abandonner()
		changer_vitesse(0)
		partie_finie.emit(Bilan.calculer(etat))
