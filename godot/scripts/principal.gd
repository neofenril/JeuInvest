extends Node
## Scène principale de la tranche de démonstration (09 §5) : la ville, le HUD, les modales, l'écran titre.
## Aucun changement de scène : l'écran titre est la ville au crépuscule, « Jouer » plonge vers la maison.
## Ce script crée les calques et les nœuds, câble les signaux, met en place / reprend la partie et réagit
## aux signaux de Partie. Il délègue :
## - l'écran titre à EcranTitre (scripts/ui/ecran_titre.gd) ;
## - les animations de la ville (banquier, krach, courrier, naissance, news, fin) à Sequences (scripts/ville/sequences.gd) ;
## - les raccourcis de test (F6-F8, triple toucher) à RaccourcisTest, créé seulement si Reglages.raccourcis_test() ;
## - les étapes de capture à ScenariosCapture (scripts/outils/scenarios_capture.gd + scenarios/*.gd).

var demo: Dictionary
var ville: Node2D
var hud: Hud
var modales: Modales
var titre: EcranTitre
var sequences: Sequences
var confirmation_saut: ConfirmationSaut = null   # fenêtre « Avancer jusqu'au prochain événement ? » (0.5.1)
var calque_hud: CanvasLayer
var en_titre := true
var pluie_jusqua := -1            # la pluie du krach dure jusqu'à ce mois (Sequences)
var dernier_releve: Dictionary = {}
var derniere_bulle: Bulle = null   # dernière bulle d'humeur (captures et tests)
var _max_patr := 0.0
var _tween_titre: Tween
var _ignorer_modales := false     # pendant la mise en place d'une partie : la modale en attente sera rouverte


func _ready() -> void:
	demo = Donnees.infos_chapitre()
	modales_init()
	Partie.mois_passe.connect(_on_mois)
	Partie.notif_recue.connect(_on_notif)
	Partie.modale_ouverte.connect(_on_modale)
	Partie.partie_finie.connect(_on_fin)
	Partie.chapitre_change.connect(_on_chapitre_change)
	Partie.vitesse_changee.connect(func(v: int) -> void: hud.maj_vitesse(v))
	Partie.saut_change.connect(func(_actif: bool) -> void: hud.maj_vitesse(Partie.vitesse))
	Partie.argent_change.connect(func() -> void: hud.maj(Partie.etat, true, 0.4))
	hud.vitesse_demandee.connect(_on_vitesse_demandee)
	hud.marche_demande.connect(func() -> void: ouvrir_banque("", -1.0))
	hud.menu_demande.connect(ouvrir_menu)
	hud.comparaison_demandee.connect(expliquer_comparaison)
	hud.frais_demandes.connect(_detail_frais)
	hud.notif_touchee.connect(toucher_notif)
	hud.historique_demande.connect(func() -> void: ouvrir_historique(""))
	hud.courrier_demande.connect(demander_saut)
	hud.batiment_touche.connect(toucher_batiment)
	hud.disposition_changee.connect(func() -> void: _recadrer(0.3))
	ville.batiment_touche.connect(toucher_batiment)
	Ecran.format_change.connect(func() -> void: _recadrer(0.0))
	titre.jouer_demande.connect(jouer)
	titre.nouvelle_partie_demandee.connect(demander_nouvelle_partie)
	if Reglages.raccourcis_test():
		var raccourcis := RaccourcisTest.new()
		add_child(raccourcis)
		raccourcis.installer(self)
	# Sauvegarde : un seul emplacement ; les captures d'écran utilisent un fichier à part. Pas de sauvegarde
	# automatique tant qu'on est sur l'écran titre (sinon une partie neuve passerait pour une partie en cours).
	Partie.sauvegarde_auto = false
	if ScenariosCapture.mode_capture():
		# T17 : un fichier par processus (effacé à la sortie) ; sauver_fermer / reprise (deux lancements) : un par
		# copie du projet (worktree), pour que deux séries lancées en même temps n'écrivent jamais le même fichier.
		var etape := ScenariosCapture.option("etape")
		var duo := etape in ["sauver_fermer", "reprise"]
		Partie.chemin_sauvegarde = ("user://capture_reprise_%s.sav" % ProjectSettings.globalize_path("res://").md5_text().left(12)) if duo else ("user://capture_%d.sav" % OS.get_process_id())
		Partie.chemin_records = "user://capture_records_%d.sav" % OS.get_process_id()   # lot 07 : records.sav du joueur jamais touché en capture
		tree_exiting.connect(func() -> void: Records.effacer(Partie.chemin_records))
		print("Capture : sauvegarde de la partie dans %s" % Partie.chemin_sauvegarde)
		if etape != "reprise":
			Sauvegarde.effacer(Partie.chemin_sauvegarde)
		if not duo:
			tree_exiting.connect(func() -> void: Sauvegarde.effacer(Partie.chemin_sauvegarde))
	var sauvee := Sauvegarde.lire(Partie.chemin_sauvegarde)
	if sauvee.is_empty() or not reprendre(sauvee):
		nouvelle_partie()
	_entrer_titre()


## Fermeture du jeu (croix de la fenêtre, mise en arrière-plan sur mobile) : la partie est sauvegardée.
func _notification(what: int) -> void:
	if what in [NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_GO_BACK_REQUEST]:
		if Partie.etat != null and not en_titre:
			Partie.sauvegarder()


func modales_init() -> void:
	# Ville (le ciel est peint par la rue pixel : plus de ciel vectoriel ni de shader, lot 02 I7)
	ville = Node2D.new()
	ville.set_script(load("res://scripts/ville/ville.gd"))
	add_child(ville)
	# HUD, effets, titre, modales
	calque_hud = CanvasLayer.new()
	calque_hud.layer = 1
	add_child(calque_hud)
	hud = Hud.new()
	hud.ville = ville
	calque_hud.add_child(hud)
	var calque_effets := CanvasLayer.new()
	calque_effets.layer = 2
	add_child(calque_effets)
	var calque_titre := CanvasLayer.new()
	calque_titre.layer = 4
	add_child(calque_titre)
	titre = EcranTitre.new()
	titre.construire(demo)
	titre.titres_demande.connect(ouvrir_titres)
	calque_titre.add_child(titre)
	var calque_modales := CanvasLayer.new()
	calque_modales.layer = 5
	add_child(calque_modales)
	modales = Modales.new()
	modales.donnees_demo = demo
	calque_modales.add_child(modales)
	# Séquences animées (et attrape-toucher pour passer une animation de bâtiment, A34)
	sequences = Sequences.new()
	sequences.name = "Sequences"
	add_child(sequences)
	sequences.installer(self, ville, hud, modales, calque_modales)
	Juice.camera = ville.get("camera")
	Juice.hud = calque_hud
	Juice.calque_effets = calque_effets


## Configuration d'une nouvelle partie : graine de vie tirée au hasard (graine fixe pour les captures).
func _config(id := "") -> Dictionary:
	var c := Donnees.config_chapitre(id if id != "" else str(Donnees.index()["chapitre_defaut"]), -1 if ScenariosCapture.mode_capture() else randi_range(1, 2147483646))
	# Lot 04 (D9, I5) et lot 05 (D11, P6) : les cartes du foyer et les projets sont allumés pour toute nouvelle partie du
	# joueur ; éteints en capture (aucune étape existante ne change : `integrale` reste la référence), sauf étape qui les demande.
	if not ScenariosCapture.mode_capture():
		c["cartes"] = true
		c["projets"] = true
		c["rue"] = true       # lot 06 (E8, A1) : Jean-Mi, classement, notifications de la rue, krach détaillé
	return c


## config : partie imposée (tests : graine fixe) ; vide : graine de vie tirée au hasard.
var _reprise := false   # partie reprise depuis la sauvegarde : pas de pop-up de début

func nouvelle_partie(config := {}) -> void:
	_reprise = false
	_max_patr = 0.0
	pluie_jusqua = -1
	_ignorer_modales = true
	Partie.nouvelle_partie(_config() if config.is_empty() else config)
	_ignorer_modales = false
	_apres_mise_en_place()


## Reprise de la partie sauvegardée (sans la rouvrir : l'écran titre propose « Continuer »).
func reprendre(d: Dictionary) -> bool:
	_max_patr = 0.0
	pluie_jusqua = -1
	_ignorer_modales = true
	var ok := Partie.reprendre(d)
	_reprise = ok
	_ignorer_modales = false
	if ok:
		_apres_mise_en_place()
	return ok


func _apres_mise_en_place() -> void:
	var e := Partie.etat
	ville.call("regler_mois", Dates.mois(e.ab_courant()), Dates.annee(e.ab_courant()))
	sequences.maj_media(false)
	hud.maj(e, false)
	hud.maj_vitesse(0)
	hud.maj_badge(e.non_lues())
	hud.point_banque(false)
	_regler_theme(true)
	_regler_foyer(true)
	if titre != null:
		maj_titre()


# =====================================================================
# Écran titre (construit par EcranTitre) : entrée, « Jouer », nouvelle partie
# =====================================================================

func _entrer_titre() -> void:
	en_titre = true
	ville.set("mode_titre", true)
	ville.set("interactif", false)
	ville.set("phase", 0.585)
	hud.visible = false
	titre.visible = true
	titre.modulate.a = 1.0
	_recadrer(0.0)
	var media: Node = ville.get("media")
	media.set("titre", 0.0)
	media.set("titre_lettres", 0.0)
	_tween_titre = create_tween()
	_tween_titre.tween_interval(0.4)
	_tween_titre.tween_property(media, "titre", 1.0, 0.5)
	_tween_titre.tween_property(media, "titre_lettres", 9.5, 1.6)
	maj_titre()
	titre.donner_focus()


## Boutons de l'écran titre selon la présence d'une sauvegarde.
func maj_titre() -> void:
	titre.maj(Sauvegarde.lire(Partie.chemin_sauvegarde), Partie.etat != null and Partie.etat.fin == "")
	titre.maj_palmares(Records.lire(Partie.chemin_records), Titres.tous().size(), Noms.titres_par_chapitre())


## Collection des titres (écran titre : bouton TITRES, touche T). Lecture seule.
func ouvrir_titres() -> void:
	if not en_titre or modales.ouverte():
		return
	modales.titres(Records.lire(Partie.chemin_records), Titres.tous(), Noms.titres_par_chapitre())
	await modales.choix_fait
	titre.donner_focus()


func demander_nouvelle_partie() -> void:
	if not en_titre or modales.ouverte():
		return
	if Sauvegarde.existe(Partie.chemin_sauvegarde):
		modales.confirmer("NOUVELLE PARTIE", "Une partie est en cours (%s). Commencer une nouvelle partie l'effacera définitivement." % titre.texte_reprise(),
			"EFFACER ET RECOMMENCER", "GARDER MA PARTIE")
		var r: Array = await modales.choix_fait
		if r[1] != "oui":
			titre.donner_focus()
			return
	var id := await _demander_depart()
	if id == "":
		titre.donner_focus()
		return
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	nouvelle_partie(_config(id))
	_depart_fait = true
	jouer()


## Choix du départ (lot 10b, I9) quand plusieurs chapitres sont ouverts : l'id du chapitre, "" si le joueur revient en arrière.
var _depart_fait := false

func _demander_depart() -> String:
	var cartes := ChoixDepart.cartes()
	if cartes.size() < 2:
		return str(Donnees.index()["chapitre_defaut"])
	modales.choix_depart(cartes)
	var r: Array = await modales.choix_fait
	return "" if str(r[1]) == "retour" else str(r[1])


func jouer() -> void:
	if not en_titre or modales.ouverte():
		return
	if not _reprise and not _depart_fait:
		var id := await _demander_depart()
		if id == "":
			titre.donner_focus()
			return
		if Partie.etat == null or id != Partie.etat.chapitre_depart:
			nouvelle_partie(_config(id))
	_depart_fait = false
	en_titre = false
	var media: Node = ville.get("media")
	if _tween_titre != null and _tween_titre.is_valid():
		_tween_titre.kill()
	var t := create_tween().set_parallel(true)
	t.tween_property(titre, "modulate:a", 0.0, 0.3)
	t.tween_property(media, "titre", 0.0, 0.5)
	# Plongée vers la maison, et le jour se lève en accéléré
	var tw: Tween = ville.call("plonger_vers_maison", 0.8)
	var tp := create_tween()
	tp.tween_method(func(p: float) -> void: ville.set("phase", fmod(p, 1.0)), 0.585, 1.1, 1.3)
	if tw != null:
		await tw.finished
	titre.visible = false
	ville.set("mode_titre", false)
	ville.call("revenir", 0.0)
	_recadrer(0.5)
	hud.visible = true
	hud.afficher(true)
	ville.set("interactif", true)
	Partie.sauvegarde_auto = true
	await _intro_nouvelle_partie()
	Partie.changer_vitesse(int(demo.get("vitesse_depart", 1)))
	Partie.sauvegarder()
	Partie.rouvrir_modale()


## Démarrage direct sans titre (captures, rejouer).
func demarrer_direct(vitesse := 0) -> void:
	en_titre = false
	titre.visible = false
	if _tween_titre != null and _tween_titre.is_valid():
		_tween_titre.kill()
	var media: Node = ville.get("media")
	media.set("titre", 0.0)
	ville.set("mode_titre", false)
	ville.set("phase", 0.15)
	ville.call("revenir", 0.0)
	hud.visible = true
	hud.afficher(true, false)
	_recadrer(0.0)
	ville.set("interactif", true)
	Partie.sauvegarde_auto = true
	await _intro_nouvelle_partie()
	Partie.changer_vitesse(vitesse)
	Partie.rouvrir_modale()


## Pop-up de début d'une nouvelle partie (JOUER, NOUVELLE PARTIE, REJOUER AUTREMENT) : jamais à la reprise.
func _intro_nouvelle_partie() -> void:
	# Nouvelle partie (ni reprise) : « qui vous êtes, quel est l'objectif », temps figé derrière
	if Reglages.intro_a_montrer() and not _reprise and Partie.etat != null and Partie.etat.fin == "":
		Partie.bloquee = true
		modales.intro(Partie.etat)
		await modales.choix_fait
		Partie.bloquee = false
		# Relisible dans l'HISTORIQUE (source maison, déjà lue : pas comptée dans les non-lues)
		var tx := ModaleIntro.textes(Partie.etat)
		Partie.etat.historiser_evenement({"source": "maison", "type": "intro", "titre": str(tx["titre_historique"]),
			"texte": " ".join(PackedStringArray((tx["blocs"] as Array).map(func(b: Dictionary) -> String: return "%s : %s" % [str(b["titre"]).capitalize(), str(b["texte"])])))})


func _recadrer(duree := 0.0) -> void:
	if ville == null:
		return
	if en_titre:
		ville.call("cadrer", Rect2(Vector2.ZERO, Ecran.taille()), duree)
	else:
		ville.call("cadrer", hud.rect_libre(), duree)


# =====================================================================
# Boucle : ville vivante, gel de la pause, horloge de la banque ; touches de jeu
# =====================================================================

func _process(delta: float) -> void:
	var e := Partie.etat
	# Vitesse effective (lot 02, §3.1) : un saut lancé depuis la pause garde Partie.vitesse == 0, la rue vit quand même
	var tourne := Partie.saut_actif or Partie.vitesse > 0
	ville.set("anime", en_titre or tourne or sequences.occupe)
	var gel_cible := 1.0 if (not en_titre and not tourne and not modales.ouverte() and not sequences.occupe) else 0.0
	ville.set("gel", move_toward(float(ville.get("gel")), gel_cible, delta / 0.3))
	if e != null:
		ville.get("banque").set("aiguille", Partie.progression_mois())
		ville.get("banque").queue_redraw()
	hud.maj_courrier(hud.etat_courrier_pour(e, _occupe()))
	hud.maj_banque_fermee(banque_fermee())


## Une carte du foyer ou un projet attend : la BANQUE est fermée (lot 04, I4). Le moteur
## (EtatPartie.ordres_bloques, 04-L) fait foi quand il existe ; sinon, une modale de kind « carte ».
func banque_fermee() -> bool:
	var e := Partie.etat
	if e == null or e.fin != "":
		return false
	if e.has_method("ordres_bloques"):
		return bool(e.call("ordres_bloques"))
	return e.modale.get("kind", "") in ["carte", "projet"]


## Écran titre, fenêtre ou modale ouverte, séquence animée : le joueur ne peut pas lancer de saut.
func _occupe() -> bool:
	return en_titre or modales.ouverte() or sequences.occupe or confirmation_saut != null


## Bouton COURRIER ou touche N (D1, D4) : lance le saut « jusqu'au prochain courrier », ou l'arrête.
func demander_saut() -> void:
	hud.fermer_bulle_courrier()
	if Partie.saut_actif:
		Partie.arreter_saut()
	elif hud.etat_courrier_pour(Partie.etat, _occupe()) == "repos":
		if Reglages.confirmation_a_montrer("saut"):
			_confirmer_saut()
		else:
			Partie.sauter_jusqu_au_prochain_arret()


## Correctif 0.5.1 : au premier appui, une fenêtre dit ce que va faire le bouton (case « Ne plus afficher »).
## Le temps est figé derrière ; AVANCER lance le saut, ANNULER / Échap ne change rien.
func _confirmer_saut() -> void:
	if confirmation_saut != null:
		return
	var c := ConfirmationSaut.new()
	confirmation_saut = c
	hud.add_child(c)
	Partie.bloquee = true
	c.valide.connect(func(ne_plus: bool) -> void:
		if ne_plus:
			Reglages.ne_plus_confirmer("saut")
		_fermer_confirmation_saut()
		Partie.sauter_jusqu_au_prochain_arret())
	c.annule.connect(_fermer_confirmation_saut)


func _fermer_confirmation_saut() -> void:
	if confirmation_saut != null:
		confirmation_saut.queue_free()
		confirmation_saut = null
	Partie.bloquee = false


## Une fenêtre s'ouvre (D4) : le saut s'arrête, puis le temps est figé derrière elle.
func _bloquer() -> void:
	Partie.arreter_saut()
	Partie.bloquee = true


## Touches de jeu (toujours actives). Les raccourcis de test (F6-F8) sont dans RaccourcisTest, F10 dans Ecran.
func _unhandled_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo or en_titre or modales.ouverte() or sequences.occupe or confirmation_saut != null:
		return
	match k.keycode:
		KEY_SPACE, KEY_P:
			Partie.basculer_pause()
		KEY_1, KEY_2, KEY_3:
			Partie.changer_vitesse(k.keycode - KEY_0)
		KEY_M, KEY_B:
			ouvrir_banque("", -2.0)
		KEY_H:
			ouvrir_historique("")
		KEY_N:
			demander_saut()
		_:
			return
	get_viewport().set_input_as_handled()


func _on_vitesse_demandee(v: int) -> void:
	if sequences.occupe or modales.ouverte():
		return
	if v == -1:
		Partie.basculer_pause()
	elif v == -2 and Partie.saut_actif:
		Partie.arreter_saut()   # D4 : pendant un saut, le cycle de vitesse arrête seulement le saut
	elif v == -2:
		Partie.changer_vitesse(1 + (Partie.vitesse % 3) if Partie.vitesse > 0 else 1)
	else:
		Partie.changer_vitesse(v)


# =====================================================================
# Mois, notifications, modales du moteur
# =====================================================================

## Décor choisi par la date (tranches de 10 ans, lot 09). La ville ignore un thème identique et diffère le changement
## pendant une séquence animée. `premier` : démarrage ou reprise, journal de capture « THEME <id> » (la ville ne
## journalise que les changements effectifs).
func _regler_theme(premier := false) -> void:
	if Partie.etat == null or not ville.has_method("regler_theme"):
		return
	var id := Donnees.theme_a(Partie.etat.ab_courant())
	var avant := str(ville.call("theme_actuel")) if ville.has_method("theme_actuel") else ""
	ville.call("regler_theme", id)
	if premier and avant == id and "--controle" in OS.get_cmdline_user_args():
		print("THEME %s" % id)


## Le mois courant entre dans un autre chapitre (Partie.chapitre_change ; jamais émis avec les données réelles avant le lot 10).
## La carte de passage (version A, docs/40) arrive par Sequences ; ici : textes, décor et foyer du chapitre.
func _on_chapitre_change(_ancien: String, _nouveau: String) -> void:
	demo = Donnees.infos_chapitre()
	modales.donnees_demo = demo
	_regler_theme()
	_regler_foyer()


## Foyer visible dans la ville (lot 10b, I10) : ville.regler_foyer_visuel(foyer_visuel()) au démarrage, à la reprise et à chaque
## changement (janvier, naissance, mariage) ; idempotent, appelé seulement quand le foyer change.
var _dernier_foyer: Dictionary = {}

func _regler_foyer(force := false) -> void:
	if Partie.etat == null or not ville.has_method("regler_foyer_visuel"):
		return
	var d: Dictionary = Partie.etat.foyer_visuel()
	if force or d != _dernier_foyer:
		_dernier_foyer = d.duplicate(true)
		ville.call("regler_foyer_visuel", d)


func _on_mois(res: Dictionary) -> void:
	var e := Partie.etat
	if e == null:
		return
	var anime: bool = not res.get("saut", false) and not res.get("pendant_saut", false) and not en_titre
	var a := e.ab_courant()
	ville.call("regler_mois", Dates.mois(a), Dates.annee(a))
	_regler_theme()
	_regler_foyer()
	hud.maj(e, anime)
	sequences.maj_media(anime)
	var patr := e.patrimoine(e.joueur)
	_max_patr = maxf(_max_patr, patr)
	ville.set("pluie", patr < 0.85 * _max_patr or e.m <= pluie_jusqua)
	hud.maj_badge(e.non_lues())
	# Pièces du mois (lot 02, §3.2, D9) : Sequences (dev-ville) si elle les sait ; sinon les pièces du salaire
	if sequences.has_method("pieces_du_mois"):
		if not en_titre:
			sequences.call("pieces_du_mois", res)
	elif anime and Partie.vitesse == 1 and e.m > e.m_depart:
		var depart: Vector2 = ville.call("ecran_batiment", ville.get("banque"), Vector2(0, -150))
		Juice.pieces(depart, _cible_argent(), 3)


func _cible_argent() -> Vector2:
	var l: Label = hud.l_patr if hud.compact else hud.l_cc
	return l.get_global_rect().get_center()


func _on_notif(n: Dictionary) -> void:
	var e := Partie.etat
	var a := e.ab_courant()
	var type: String = n.get("type", "")
	if _ignorer_modales or en_titre:
		return
	if n.get("source", "") == "media":
		sequences.petite_news(n)
		return
	if type == "humeur":
		_bulle_humeur(n)   # lot 04 (I2) : une bulle à la fenêtre de Sylvie, pas de carte de notification
		return
	var depart := Vector2(-1, -1)
	if n.get("source", "") == "maison":
		depart = ville.call("ecran_batiment", ville.get("maison"), Vector2(0, -150))
		sequences.clignoter_maison()
		if n.has("montant"):
			Juice.flottant(Format.montant(float(n["montant"]), a, false, true), _cible_argent() + Vector2(0, 40), Style.GAIN if float(n["montant"]) > 0.0 else Style.PERTE)
	elif n.get("source", "") == "banque":
		var b: Vector2 = ville.call("ecran_batiment", ville.get("banque"), Vector2(0, -150))
		if type == "releve":
			dernier_releve = n
		if type in ["interets", "releve", "coupon"] and float(n.get("montant", 0.0)) > 0.0 and not sequences.has_method("pieces_du_mois"):
			Juice.pieces(b, _cible_argent(), 5)
		ville.get("banque").call("ondes", 1)
		depart = b
	hud.notifier(n, a, depart)


## Humeur de Sylvie (notification type « humeur ») : bulle de 4 s ancrée sur sa fenêtre (03-V2 : point_sylvie,
## sinon la porte de la maison) ; née d'une carte, elle attend la fin du rangement. Le picto de l'étiquette suit.
func _bulle_humeur(n: Dictionary) -> void:
	if modales.carte_en_cours:
		await modales.carte_rangee
	var ancre := func() -> Vector2: return ville.call("point_sylvie") if ville.has_method("point_sylvie") else ville.call("porte_ecran", "maison")
	derniere_bulle = Bulle.montrer(Juice.calque_effets, str(n.get("titre", "")), ancre, 4.0)
	hud.maj_humeur(Partie.etat)


## Toucher une notification : le relevé de décembre ouvre le détail des frais (13 §3.4).
func toucher_notif(n: Dictionary) -> void:
	if str(n.get("source", "")) == "rue" and str(n.get("type", "")) in ["voisin", "rang"] and not sequences.occupe and not modales.ouverte() and not en_titre:
		# Lot 06 (A3) : la rue se relit en lecture seule (voisin long : texte entier) ; le temps est en pause derrière la carte
		_bloquer()
		modales.lecture_notification({"source": "rue", "contenu": n, "titre": str(n.get("titre", ""))}, Partie.etat.ab_courant())
		await modales.choix_fait
		Partie.bloquee = false
		return
	if n.get("type", "") != "releve" or float(n.get("frais_total", 0.0)) <= 0.0 or sequences.occupe or modales.ouverte() or en_titre:
		return
	_bloquer()
	modales.releve(n, Partie.etat.ab_courant())
	await modales.choix_fait
	Partie.bloquee = false


## Toucher le compteur « Frais payés » : ce que les frais ont coûté, frais payés et gains manqués.
func _detail_frais() -> void:
	if en_titre or sequences.occupe or modales.ouverte():
		return
	var e := Partie.etat
	var a := e.ab_courant()
	var n := {"titre": "Vos frais depuis le début", "frais_total": e.frais_payes(), "manque": e.manque_a_gagner(),
		"texte": "Droits d'entrée de la SICAV et de l'assurance-vie, courtage des actions, frais de gestion de la SICAV (prélevés chaque jour dans sa valeur) : %s au total. Tata Livret, elle, n'a payé aucun frais." % Format.entier(e.frais_payes(), a)}
	if e.frais_payes() <= 0.005:
		n["texte"] = "Vous n'avez payé aucun frais pour l'instant : le Livret A, le PEL et l'emprunt d'État n'en ont pas. La SICAV, l'assurance-vie et les actions en ont."
	_bloquer()
	modales.releve(n, a)
	await modales.choix_fait
	Partie.bloquee = false


func _on_modale(c: Dictionary) -> void:
	if _ignorer_modales or en_titre:
		return
	sequences.jouer_modale(c)


func _on_fin(_bilan: Dictionary) -> void:
	sequences.fin()


# =====================================================================
# Bâtiments, comparaison, fenêtre Banque, menu
# =====================================================================

func toucher_batiment(id: String) -> void:
	if en_titre or sequences.occupe or modales.ouverte():
		return
	var e := Partie.etat
	match id:
		"banque":
			ouvrir_banque("", -2.0)
		"maison":
			# Lot 04 (I3) : « Mon foyer », la porte du frigo (ModaleFoyer)
			_bloquer()
			modales.foyer(e, ville.call("ecran_batiment", ville.get("maison"), Vector2(0, -150)))
			var r: Array = await modales.choix_fait
			Partie.bloquee = false
			if r[1] == "extra":
				ouvrir_historique("maison")
		"media":
			# « Les nouvelles » (09 §2.1) : l'historique, filtré sur le média
			ouvrir_historique("media")


## Toucher la pastille « VS TOUT AU LIVRET A » : ce que fait la référence, et l'écart du moment.
func expliquer_comparaison() -> void:
	if en_titre or sequences.occupe or modales.ouverte():
		return
	var e := Partie.etat
	var a := e.ab_courant()
	var ecart := e.ecart_livret()
	var tata := e.patrimoine(e.temoins["livret"])
	var verdict := "Vous êtes à égalité."
	if Format.en_devise(ecart, Format.devise(a)) >= 0.5:
		verdict = "Vos choix font mieux : %s de plus." % Format.ecart(ecart, a).trim_prefix("+")
	elif Format.en_devise(ecart, Format.devise(a)) <= -0.5:
		verdict = "Vos choix font moins bien : %s de moins." % Format.ecart(-ecart, a).trim_prefix("+")
	_bloquer()
	modales.info("VOS CHOIX FACE À « TOUT AU LIVRET A »", [
		"Repère : le même salaire, les mêmes dépenses et les mêmes coups durs que vous, mais tout l'argent reste sur le compte courant et le Livret A (dans la limite du plafond). C'est le réflexe de beaucoup d'épargnants.",
		"Avec ce choix : %s.   Vous : %s." % [Format.montant(tata, a), Format.montant(e.patrimoine(e.joueur), a)],
		verdict,
		"La courbe bleue de « Mon argent » suit ce repère mois après mois."])
	await modales.choix_fait
	Partie.bloquee = false


## La fenêtre Banque (13 §2) : carnet, fiche, ordre. montant < -1,5 : ouvrir sur la fiche (pas sur l'ordre).
func ouvrir_banque(produit: String, montant: float, depuis_sequence := false) -> void:
	if banque_fermee() and not depuis_sequence and not en_titre:
		_dire_banque_fermee()   # lot 04 (I4) : touche, bouton ou bâtiment : sans effet, la phrase est montrée
		return
	if modales.ouverte() or (sequences.occupe and not depuis_sequence):
		return
	var e := Partie.etat
	if e == null or e.fin != "":
		return
	_bloquer()
	hud.point_banque(false)
	var depart: Vector2 = ville.call("ecran_batiment", ville.get("banque"), Vector2(0, -150))
	modales.ouvrir_banque(e, produit, montant, depart)
	modales.banque.ordre_passe.connect(_on_ordre)
	modales.banque.relire.connect(_relire)
	modales.banque.historique_demande.connect(func() -> void: modales.fermer("historique"))
	var r: Array = await modales.choix_fait
	if r[1] != "relire":
		Partie.bloquee = false
	if r[1] == "historique":
		await get_tree().create_timer(0.25).timeout
		await ouvrir_historique("banque", 0, true)
	hud.maj(e, true, 0.4)
	Partie.sauvegarder()


## La phrase de la banque fermée, en bulle au-dessus de l'étiquette MA BANQUE (3 s).
func _dire_banque_fermee() -> void:
	var eb: Control = hud.etiquettes["banque"]
	var ancre := func() -> Vector2: return eb.get_global_rect().get_center() + Vector2(0, -eb.size.y / 2.0)
	derniere_bulle = Bulle.montrer(Juice.calque_effets, Hud.PHRASE_BANQUE_FERMEE, ancre, 3.0)


## Relire une présentation passée depuis la fiche du carnet (12 §2.4) : la carte en lecture seule.
func _relire(id: String) -> void:
	var e := Partie.etat
	modales.fermer("relire")
	await get_tree().create_timer(0.3).timeout
	var c := Banquier.contenu(e, id)
	var p := int(e.banque["presentes"].get(id, e.m))
	c["date"] = Dates.texte(e.ab_de(p))
	_bloquer()
	modales.presentation(c, Vector2(-1, -1), true)
	await modales.choix_fait
	Partie.bloquee = false
	var pid: String = Banquier.donnees()["presentations"].get(id, {}).get("produits", ["livret"])[0]
	ouvrir_banque(pid, -2.0, true)


## Pièces d'or vers la banque (ou depuis), pièces de cuivre pour les frais vers le compteur « Frais payés ».
func _on_ordre(pos: Vector2, _montant: float, achat: bool, frais: float) -> void:
	var banque: Vector2 = ville.call("ecran_batiment", ville.get("banque"), Vector2(0, -150))
	if achat:
		Juice.pieces(pos, banque, 3)
	else:
		Juice.pieces(banque, pos, 3)
	if frais > 0.0 and Partie.vitesse != 3:
		var cible: Vector2 = hud.l_frais.get_global_rect().get_center() if hud.panneau.visible else hud.languette.get_global_rect().get_center()
		Juice.pieces(pos, cible, 2, Callable(), true)


func ouvrir_menu() -> void:
	if modales.ouverte() or sequences.occupe:
		return
	_bloquer()
	modales.menu()
	var r: Array = await modales.choix_fait
	Partie.bloquee = false
	if r[1] == "quitter":
		Partie.sauvegarder()
		get_tree().quit()
	elif r[1] == "historique":
		await get_tree().create_timer(0.25).timeout
		ouvrir_historique("")


# =====================================================================
# Historique des pop-ups (retour du joueur du 27/10/2026)
# =====================================================================

## Ouvre l'historique (filtre : "" | maison | banque | media). Toucher une ligne la relit en lecture seule,
## puis l'historique revient avec le même filtre et le même défilement. Le temps est en pause.
func ouvrir_historique(filtre: String, defilement := 0, depuis_banque := false) -> void:
	if en_titre or (sequences.occupe and not depuis_banque) or (modales.ouverte() and not depuis_banque):
		return
	var e := Partie.etat
	if e == null:
		return
	_bloquer()
	while true:
		modales.historique(e, filtre, defilement)
		var r: Array = await modales.choix_fait
		var id: String = r[1]
		if not id.begins_with("ouvrir:"):
			break
		filtre = modales.historique_filtre
		defilement = modales.historique_defilement
		await get_tree().create_timer(0.2).timeout
		if modales.relire_historique(e, int(id.split(":")[1])):   # relecture en lecture seule (ModaleHistorique)
			await modales.choix_fait
		await get_tree().create_timer(0.2).timeout
	# D5 : les nouveautés sont vues à la fermeture finale (après les relectures) ; le badge disparaît
	e.marquer_lues()
	hud.maj_badge(0)
	Partie.bloquee = false
	Partie.sauvegarder()


## Captures d'écran (--etape=, autoload Capture) : les scénarios sont dans ScenariosCapture.
func preparer_capture(etape: String) -> void:
	var sc := ScenariosCapture.new()
	sc.jeu = self
	add_child(sc)
	await sc.preparer(etape)
