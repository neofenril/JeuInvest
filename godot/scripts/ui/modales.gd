class_name Modales
extends Control
## Les papiers et cartes posés devant la ville (calque 5) : journal (04 §3.5), courrier (04 §3.6),
## carte de présentation du banquier (13 §1), fenêtre Banque (13 §2), fin de démonstration (13 §4.3),
## confirmation, panneaux d'information, historique des pop-ups.
## Chaque modale émet choix_fait(genre, id) à sa fermeture.
##
## Façade (lot PX2, T9) : l'état commun, le fond assombri, la fermeture, le clavier et l'API publique ;
## chaque écran est construit par un morceau (RefCounted, référence « m » vers cette façade) :
## ModaleJournal, ModaleCourrier, ModaleBanquier, ModaleReleveFin, ModaleSimples, ModaleHistorique ;
## outils communs (boutons papier, filets, flèches, croix, pictogrammes) : ModaleOutils.

signal choix_fait(genre: String, id: String)

var fond: ColorRect
var courant: Control = null
var genre_courant := ""
var compact := false
var banque: PanneauBanque = null
var donnees_demo: Dictionary = {}
var historique_filtre := ""
var historique_defilement := 0
# État partagé avec les morceaux
var boutons_actifs := true          # journal : les choix ne répondent qu'après l'arrivée de la page
var choix_journal: Array = []       # journal : ids des choix (touches 1, 2, 3)
var choix_exterieur := "plus_tard"  # carte du banquier : id d'un clic à côté ou d'Échap
var parler := 0.0                   # carte du banquier : temps de parole restant (bouche du portrait)
var portrait: Portrait = null

var _journal: ModaleJournal
var _courrier: ModaleCourrier
var _banquier: ModaleBanquier
var _releve_fin: ModaleReleveFin
var _simples: ModaleSimples
var _historique: ModaleHistorique


func _init() -> void:
	_journal = ModaleJournal.new(self)
	_courrier = ModaleCourrier.new(self)
	_banquier = ModaleBanquier.new(self)
	_releve_fin = ModaleReleveFin.new(self)
	_simples = ModaleSimples.new(self)
	_historique = ModaleHistorique.new(self)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = Style.theme()
	fond = ColorRect.new()
	fond.color = Color(Style.ENCRE, 0.0)
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fond.gui_input.connect(_on_fond)
	add_child(fond)
	get_tree().node_added.connect(_garde_cible)


## Garde-fou des fenêtres (PX2 §2.3) : tout bouton posé sous les modales (fenêtre Banque comprise) a
## un côté d'au moins Style.cible_min() ; Pixelify sous 28 px devient des petites capitales Atkinson.
func _garde_cible(n: Node) -> void:
	var b := n as Button
	if b == null or not is_ancestor_of(b):
		return
	var c := Style.cible_min()
	b.custom_minimum_size = Vector2(maxf(b.custom_minimum_size.x, c), maxf(b.custom_minimum_size.y, c))
	Style.garder_police(b)   # chiffres en Atkinson, Pixelify jamais sous 28 px


# =====================================================================
# API publique (appelée par principal.gd, Sequences, les tests et les captures)
# =====================================================================

## lecture_choix : relecture depuis l'historique (pas de décision : le choix fait, et FERMER).
func journal(c: Dictionary, depart: Vector2, spectaculaire: bool, lecture_choix := "") -> void:
	await _journal.ouvrir(c, depart, spectaculaire, lecture_choix)


## Petits journaux qui jaillissent du média (effet 2, décor) avant le journal principal.
func journaux_volants(depart: Vector2, n: int) -> void:
	_journal.volants(depart, n)


## lecture_choix / ab_lecture : relecture depuis l'historique (le choix fait et la date d'alors, FERMER).
func courrier(c: Dictionary, depart: Vector2, e: EtatPartie, lecture_choix := "", ab_lecture := -1) -> void:
	await _courrier.ouvrir(c, depart, e, lecture_choix, ab_lecture)


## c : Banquier.contenu (kind « banquier »). lecture : relecture depuis le carnet (un seul bouton Fermer).
func presentation(c: Dictionary, depart: Vector2, lecture := false, bandeau := "") -> void:
	await _banquier.ouvrir(c, depart, lecture, bandeau)


func ouvrir_banque(e: EtatPartie, produit: String, montant: float, depart := Vector2(-1, -1)) -> void:
	compact = Ecran.compact()
	genre_courant = "banque"
	assombrir(0.4)
	banque = PanneauBanque.new()
	add_child(banque)
	banque.construire(e, produit, montant)
	banque.fermer_demande.connect(func() -> void: fermer("fermer"))
	courant = banque
	banque.visible = false
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(banque):
		return
	banque.visible = true
	banque.reset_size()
	var t := get_viewport_rect().size
	var cible := Vector2((t.x - banque.size.x) / 2.0, maxf(6.0, (t.y - banque.size.y) / 2.0))
	banque.position = cible
	banque.pivot_offset = banque.size / 2.0
	if not Juice.animations_reduites:
		banque.scale = Vector2(0.7, 0.7)
		banque.modulate.a = 0.0
		if depart.x >= 0.0:
			banque.pivot_offset = depart - cible
		var tw := banque.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(banque, "scale", Vector2.ONE, 0.3)
		tw.tween_property(banque, "modulate:a", 1.0, 0.2)


func confirmer(titre: String, texte: String, oui: String, non: String) -> void:
	await _simples.confirmer(titre, texte, oui, non)


## Relevé de décembre ouvert depuis sa notification (13 §3.4) : les 3 piles avec les vrais chiffres du joueur.
func releve(n: Dictionary, a: int) -> void:
	await _releve_fin.releve(n, a)


func fin_demo(e: EtatPartie) -> void:
	await _releve_fin.fin_demo(e)


## extra : libellé d'un second bouton (ferme avec l'id « extra »), "" pour aucun.
func info(titre: String, lignes: Array, depart := Vector2(-1, -1), extra := "") -> void:
	await _simples.info(titre, lignes, depart, extra)


func menu() -> void:
	await _simples.menu()


## Historique des pop-ups (filtre "" | maison | banque | media) ; toucher une ligne ferme avec « ouvrir:<i> ».
func historique(e: EtatPartie, filtre := "", defilement := 0) -> void:
	await _historique.ouvrir(e, filtre, defilement)


## Relecture d'une notification de l'historique (message du banquier, nouvelle, petit courrier…).
func lecture_notification(h: Dictionary, a: int) -> void:
	await _historique.lecture_notification(h, a)


func ouverte() -> bool:
	return courant != null


func fermer(id := "") -> void:
	if courant == null:
		return
	var p := courant
	var g := genre_courant
	courant = null
	genre_courant = ""
	assombrir(0.0)
	# Enveloppe encore en vol (courrier fermé avant d'être posé, T16) : elle disparaît avec lui.
	if p.has_meta("enveloppe"):
		var env: Node = (p.get_meta("enveloppe") as WeakRef).get_ref()
		if env != null:
			env.queue_free()
	var t := p.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(p, "position:y", p.position.y + 120.0, 0.3)
	t.tween_property(p, "rotation", p.rotation + deg_to_rad(8.0), 0.3)
	t.tween_property(p, "modulate:a", 0.0, 0.3)
	t.chain().tween_callback(p.queue_free)
	choix_fait.emit(g, id)


## Choix d'un journal (bouton, touche 1-3, Échap) ; appelé aussi par les captures et la recette.
func _on_choix_journal(id: String) -> void:
	_journal.choisir(id)


# =====================================================================
# Outils communs aux morceaux
# =====================================================================

func assombrir(a: float) -> void:
	fond.mouse_filter = Control.MOUSE_FILTER_STOP if a > 0.0 else Control.MOUSE_FILTER_IGNORE
	create_tween().tween_property(fond, "color:a", a, 0.2)


## Pose la feuille construite : elle devient la modale courante.
func poser(p: Control) -> void:
	add_child(p)
	courant = p


## Les libellés à retour à la ligne d'une colonne pleine largeur reçoivent une largeur explicite :
## sans elle, leur hauteur minimale est calculée pour une largeur nulle (panneau démesuré).
func fixer_largeurs(p: PanelContainer) -> void:
	var sb := p.get_theme_stylebox("panel")
	var largeur := p.custom_minimum_size.x - sb.content_margin_left - sb.content_margin_right
	for n in p.find_children("*", "Label", true, false):
		var l := n as Label
		if l.autowrap_mode != TextServer.AUTOWRAP_OFF and l.custom_minimum_size.x <= 0.0 and l.get_parent() is VBoxContainer:
			l.custom_minimum_size.x = largeur
		elif l.autowrap_mode != TextServer.AUTOWRAP_OFF and l.custom_minimum_size.x <= 0.0:
			l.custom_minimum_size.x = largeur * 0.6


## Attend la mise en page (les libellés à retour à la ligne ne se mesurent qu'après), puis centre.
func centrer(p: Control) -> void:
	p.mouse_filter = Control.MOUSE_FILTER_STOP   # un clic sur la feuille elle-même ne la ferme pas
	p.visible = false
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(p):
		return
	p.visible = true
	p.reset_size()
	var t := get_viewport_rect().size
	p.position = (t - p.size) / 2.0
	p.pivot_offset = p.size / 2.0


## Entrée simple (relectures) : la feuille grossit légèrement en apparaissant.
func apparaitre(p: Control) -> void:
	if Juice.animations_reduites:
		return
	p.pivot_offset = p.size / 2.0
	p.scale = Vector2(0.92, 0.92)
	p.modulate.a = 0.0
	var tw := p.create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(p, "scale", Vector2.ONE, 0.25)
	tw.tween_property(p, "modulate:a", 1.0, 0.15)


# =====================================================================
# Fond, frémissement, bouche du portrait, clavier
# =====================================================================

## Clic ou toucher en dehors de la modale (sur le fond assombri) : ferme les pop-ups de consultation
## comme leur croix ou leur bouton Fermer. Le journal, le courrier et la fin exigent un choix
## explicite (sinon on esquiverait la décision) : la feuille frémit pour le rappeler.
## Le toucher arrive ici en clic émulé (emulate_mouse_from_touch, réglage par défaut).
func _on_fond(event: InputEvent) -> void:
	var b := event as InputEventMouseButton
	if b == null or not b.pressed or b.button_index != MOUSE_BUTTON_LEFT or courant == null:
		return
	fond.accept_event()
	match genre_courant:
		"appel":
			fermer(choix_exterieur)
		"info", "historique":
			fermer("fermer")
		"menu":
			fermer("reprendre")
		"confirmer":
			fermer("non")
		"banque":
			banque.fermer_demande.emit()
		_:
			_fremir(courant)


func _fremir(p: Control) -> void:
	if Juice.animations_reduites or p.has_meta("fremit") or (genre_courant == "journal" and not boutons_actifs):
		return
	p.set_meta("fremit", true)
	var r0 := p.rotation
	var t := p.create_tween()
	for k in 4:
		t.tween_property(p, "rotation", r0 + deg_to_rad(1.2 if k % 2 == 0 else -1.2), 0.05)
	t.tween_property(p, "rotation", r0, 0.05)
	t.tween_callback(func() -> void: p.remove_meta("fremit"))


func _process(delta: float) -> void:
	if portrait != null and is_instance_valid(portrait):
		parler = maxf(0.0, parler - delta)
		portrait.bouche = (0.5 + 0.5 * sin(Time.get_ticks_msec() / 45.0)) if parler > 0.0 else 0.0
		portrait.queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo or courant == null:
		return
	if genre_courant == "journal" and boutons_actifs:
		var n := k.keycode - KEY_1
		if n >= 0 and n < choix_journal.size():
			_on_choix_journal(choix_journal[n])
			get_viewport().set_input_as_handled()
		elif k.keycode == KEY_ESCAPE:
			_on_choix_journal("rien" if choix_journal.has("rien") else "ecart")
			get_viewport().set_input_as_handled()
	elif k.keycode == KEY_ESCAPE and genre_courant in ["appel", "info", "menu", "banque", "confirmer", "historique"]:
		if genre_courant == "banque":
			banque.fermer_demande.emit()
		else:
			fermer({"appel": choix_exterieur, "confirmer": "non", "menu": "reprendre"}.get(genre_courant, "fermer"))
		get_viewport().set_input_as_handled()
