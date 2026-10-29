extends Node
## Scène principale de la tranche de démonstration (09 §5) : la ville, le HUD, les modales, l'écran titre.
## Aucun changement de scène : l'écran titre est la ville au crépuscule, « Jouer » plonge vers la maison.
## Ce script orchestre les séquences (appel du banquier, krach, courrier, petite news) : une seule
## « vedette » à la fois, chaque animation de bâtiment dure 2 s au plus et se passe d'un toucher (A34).

var demo: Dictionary
var ville: Node2D
var hud: Hud
var modales: Modales
var titre: Control
var ciel: ColorRect
var calque_hud: CanvasLayer
var en_titre := true
var _occupe := false
var _file: Array = []
var _passer := false
var _attrape: Control
var _max_patr := 0.0
var _pluie_jusqua := -1
var _bouton_jouer: Button
var _bouton_nouvelle: Button
var _l_reprise: Label
var _tween_titre: Tween
var _ignorer_modales := false     # pendant la mise en place d'une partie : la modale en attente sera rouverte
var _dernier_releve: Dictionary = {}


func _ready() -> void:
	demo = Donnees.charger("demo")
	modales_init()
	Partie.mois_passe.connect(_on_mois)
	Partie.notif_recue.connect(_on_notif)
	Partie.modale_ouverte.connect(_on_modale)
	Partie.partie_finie.connect(_on_fin)
	Partie.vitesse_changee.connect(func(v: int) -> void: hud.maj_vitesse(v))
	Partie.argent_change.connect(func() -> void: hud.maj(Partie.etat, true, 0.4))
	hud.vitesse_demandee.connect(_on_vitesse_demandee)
	hud.marche_demande.connect(func() -> void: _ouvrir_banque("", -1.0))
	hud.menu_demande.connect(_ouvrir_menu)
	hud.comparaison_demandee.connect(_expliquer_comparaison)
	hud.frais_demandes.connect(_detail_frais)
	hud.notif_touchee.connect(_on_notif_touchee)
	hud.historique_demande.connect(func() -> void: _ouvrir_historique(""))
	hud.raccourci_demo.connect(_sauter_moment)
	hud.batiment_touche.connect(_on_batiment)
	hud.disposition_changee.connect(func() -> void: _recadrer(0.3))
	ville.batiment_touche.connect(_on_batiment)
	Ecran.format_change.connect(func() -> void: _recadrer(0.0))
	# Sauvegarde : un seul emplacement ; les captures d'écran utilisent un fichier à part. Pas de sauvegarde
	# automatique tant qu'on est sur l'écran titre (sinon une partie neuve passerait pour une partie en cours).
	Partie.sauvegarde_auto = false
	if _mode_capture():
		var etape := _option_capture("etape")
		Partie.chemin_sauvegarde = "user://capture_reprise.sav" if etape in ["sauver_fermer", "reprise"] else "user://capture.sav"
		if etape != "reprise":
			Sauvegarde.effacer(Partie.chemin_sauvegarde)
	var sauvee := Sauvegarde.lire(Partie.chemin_sauvegarde)
	if sauvee.is_empty() or not _reprendre(sauvee):
		_nouvelle_partie()
	_entrer_titre()


func _option_capture(nom: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--" + nom + "="):
			return arg.split("=", true, 1)[1]
	return ""


func _mode_capture() -> bool:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture"):
			return true
	return false


## Fermeture du jeu (croix de la fenêtre, mise en arrière-plan sur mobile) : la partie est sauvegardée.
func _notification(what: int) -> void:
	if what in [NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_GO_BACK_REQUEST]:
		if Partie.etat != null and not en_titre:
			Partie.sauvegarder()


func modales_init() -> void:
	# Ciel (plan 0, shader)
	var calque_ciel := CanvasLayer.new()
	calque_ciel.layer = -10
	add_child(calque_ciel)
	ciel = ColorRect.new()
	ciel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ciel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/ciel.gdshader")
	ciel.material = mat
	calque_ciel.add_child(ciel)
	# Ville
	ville = Node2D.new()
	ville.set_script(load("res://scripts/ville/ville.gd"))
	add_child(ville)
	ville.set("ciel_mat", mat)
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
	titre = _creer_titre()
	calque_titre.add_child(titre)
	var calque_modales := CanvasLayer.new()
	calque_modales.layer = 5
	add_child(calque_modales)
	modales = Modales.new()
	modales.donnees_demo = demo
	calque_modales.add_child(modales)
	# Attrape-toucher : passer une animation de bâtiment (A34)
	_attrape = Control.new()
	_attrape.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_attrape.mouse_filter = Control.MOUSE_FILTER_STOP
	_attrape.visible = false
	_attrape.gui_input.connect(_on_attrape)
	calque_modales.add_child(_attrape)
	Juice.camera = ville.get("camera")
	Juice.hud = calque_hud
	Juice.calque_effets = calque_effets


## Configuration d'une nouvelle partie : graine de vie tirée au hasard (graine fixe pour les captures).
func _config() -> Dictionary:
	return Donnees.config_demo(-1 if _mode_capture() else randi_range(1, 2147483646))


func _nouvelle_partie() -> void:
	_max_patr = 0.0
	_pluie_jusqua = -1
	_ignorer_modales = true
	Partie.nouvelle_partie(_config())
	_ignorer_modales = false
	_apres_mise_en_place()


## Reprise de la partie sauvegardée (sans la rouvrir : l'écran titre propose « Continuer »).
func _reprendre(d: Dictionary) -> bool:
	_max_patr = 0.0
	_pluie_jusqua = -1
	_ignorer_modales = true
	var ok := Partie.reprendre(d)
	_ignorer_modales = false
	if ok:
		_apres_mise_en_place()
	return ok


func _apres_mise_en_place() -> void:
	var e := Partie.etat
	ville.call("regler_mois", Dates.mois(e.ab_courant()), Dates.annee(e.ab_courant()))
	_maj_media(false)
	hud.maj(e, false)
	hud.maj_vitesse(0)
	hud.point_banque(false)
	if _bouton_jouer != null:
		_maj_titre()


# =====================================================================
# Écran titre
# =====================================================================

func _creer_titre() -> Control:
	var racine := Control.new()
	racine.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	racine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	racine.theme = Style.theme()
	var degrade := TextureRect.new()
	var g := Gradient.new()
	g.set_color(0, Color(0.05, 0.06, 0.1, 0.0))
	g.set_color(1, Color(0.05, 0.06, 0.1, 0.85))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	degrade.texture = tex
	degrade.stretch_mode = TextureRect.STRETCH_SCALE
	degrade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	degrade.anchor_left = 0
	degrade.anchor_right = 1
	degrade.anchor_top = 0.55
	degrade.anchor_bottom = 1
	degrade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	racine.add_child(degrade)
	var v := VBoxContainer.new()
	v.anchor_left = 0.5
	v.anchor_right = 0.5
	v.anchor_top = 1
	v.anchor_bottom = 1
	v.grow_horizontal = Control.GROW_DIRECTION_BOTH
	v.grow_vertical = Control.GROW_DIRECTION_BEGIN
	v.offset_bottom = -40
	v.alignment = BoxContainer.ALIGNMENT_END
	v.add_theme_constant_override("separation", 14)
	racine.add_child(v)
	var acc := Style.label(str(demo["titre"]["accroche"]).to_upper(), 36, Style.neon(), Style.TEXTE)
	acc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	acc.add_theme_color_override("font_shadow_color", Color(Style.ACCENT, 0.45))
	acc.add_theme_constant_override("shadow_outline_size", 10)
	acc.add_theme_constant_override("shadow_offset_x", 0)
	acc.add_theme_constant_override("shadow_offset_y", 0)
	v.add_child(acc)
	var sous := Style.label(str(demo["titre"]["sous_titre"]), 24, Style.ui(), Style.TEXTE_2)
	sous.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sous)
	# « Continuer » (avec la date de jeu et le patrimoine) si une partie est sauvegardée, sinon « Jouer » ;
	# « Nouvelle partie » demande confirmation quand une sauvegarde existe.
	var boutons := HBoxContainer.new()
	boutons.alignment = BoxContainer.ALIGNMENT_CENTER
	boutons.add_theme_constant_override("separation", 24)
	_bouton_jouer = Style.bouton("JOUER", true, 96)
	_bouton_jouer.custom_minimum_size = Vector2(380, 96)
	_bouton_jouer.add_theme_font_override("font", Style.neon())
	_bouton_jouer.add_theme_font_size_override("font_size", 40)
	_bouton_jouer.pressed.connect(_jouer)
	boutons.add_child(_bouton_jouer)
	_bouton_nouvelle = Style.bouton("NOUVELLE PARTIE", false, 96)
	_bouton_nouvelle.custom_minimum_size = Vector2(340, 96)
	_bouton_nouvelle.add_theme_font_size_override("font_size", 26)
	_bouton_nouvelle.pressed.connect(_demander_nouvelle_partie)
	boutons.add_child(_bouton_nouvelle)
	v.add_child(boutons)
	_l_reprise = Style.label("", 22, Style.chiffres(), Style.TEXTE)
	_l_reprise.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_l_reprise)
	var aide := Style.label("F10 : format téléphone   ·   F8 : moment suivant   ·   F6 / F7 : naissance / jumeaux", 20, Style.ui(), Color(Style.TEXTE_2, 0.8))
	aide.anchor_left = 0
	aide.anchor_top = 1
	aide.anchor_bottom = 1
	aide.offset_left = 24
	aide.offset_top = -44
	aide.visible = not OS.has_feature("mobile")
	racine.add_child(aide)
	return racine


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
	_maj_titre()
	_bouton_jouer.grab_focus.call_deferred()


## Boutons de l'écran titre selon la présence d'une sauvegarde.
func _maj_titre() -> void:
	var d := Sauvegarde.lire(Partie.chemin_sauvegarde)
	var reprise := not d.is_empty() and Partie.etat != null and Partie.etat.fin == ""
	_bouton_jouer.text = "CONTINUER" if reprise else "JOUER"
	_bouton_nouvelle.visible = reprise
	_l_reprise.visible = reprise
	if reprise:
		var r: Dictionary = d["resume"]
		_l_reprise.text = "Partie en cours : %s · %s · patrimoine %s" % [str(r.get("prenom", "")), Dates.texte(int(r["ab"])), Format.montant(float(r["patrimoine"]), int(r["ab"]))]


func _demander_nouvelle_partie() -> void:
	if not en_titre or modales.ouverte():
		return
	if Sauvegarde.existe(Partie.chemin_sauvegarde):
		modales.confirmer("NOUVELLE PARTIE", "Une partie est en cours (%s). Commencer une nouvelle partie l'effacera définitivement." % _l_reprise.text.trim_prefix("Partie en cours : "),
			"EFFACER ET RECOMMENCER", "GARDER MA PARTIE")
		var r: Array = await modales.choix_fait
		if r[1] != "oui":
			_bouton_jouer.grab_focus.call_deferred()
			return
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	_nouvelle_partie()
	_jouer()


func _jouer() -> void:
	if not en_titre or modales.ouverte():
		return
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
	Partie.changer_vitesse(int(demo.get("vitesse_depart", 1)))
	Partie.sauvegarder()
	Partie.rouvrir_modale()


## Démarrage direct sans titre (captures, rejouer).
func _demarrer_direct(vitesse := 0) -> void:
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
	Partie.changer_vitesse(vitesse)
	Partie.rouvrir_modale()


func _recadrer(duree := 0.0) -> void:
	if ville == null:
		return
	if en_titre:
		ville.call("cadrer", Rect2(Vector2.ZERO, Ecran.taille()), duree)
	else:
		ville.call("cadrer", hud.rect_libre(), duree)


# =====================================================================
# Boucle : ville vivante, gel de la pause, horloge de la banque
# =====================================================================

func _process(delta: float) -> void:
	var e := Partie.etat
	ville.set("anime", en_titre or Partie.vitesse > 0 or _occupe)
	var gel_cible := 1.0 if (not en_titre and Partie.vitesse == 0 and not modales.ouverte() and not _occupe) else 0.0
	ville.set("gel", move_toward(float(ville.get("gel")), gel_cible, delta / 0.3))
	if e != null:
		ville.get("banque").set("aiguille", Partie.progression_mois())
		ville.get("banque").queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo or en_titre or modales.ouverte() or _occupe:
		return
	match k.keycode:
		KEY_SPACE, KEY_P:
			Partie.basculer_pause()
		KEY_1, KEY_2, KEY_3:
			Partie.changer_vitesse(k.keycode - KEY_0)
		KEY_M, KEY_B:
			_ouvrir_banque("", -2.0)
		KEY_H:
			_ouvrir_historique("")
		KEY_F8:
			_sauter_moment()
		KEY_F6, KEY_F7:
			# Débogage : naissance (F6) ou jumeaux (F7) tout de suite
			Partie.forcer_naissance(k.keycode == KEY_F7)
		_:
			return
	get_viewport().set_input_as_handled()


func _on_vitesse_demandee(v: int) -> void:
	if _occupe or modales.ouverte():
		return
	if v == -1:
		Partie.basculer_pause()
	elif v == -2:
		Partie.changer_vitesse(1 + (Partie.vitesse % 3) if Partie.vitesse > 0 else 1)
	else:
		Partie.changer_vitesse(v)


## Raccourci de démonstration : saute au mois qui précède le prochain moment fort.
func _sauter_moment() -> void:
	var e := Partie.etat
	if e == null or e.fin != "" or _occupe or modales.ouverte():
		return
	for d in demo.get("moments", []):
		var mm := Dates.lire(d) - e.mk.ab_debut
		if mm > e.m + 1:
			Partie.sauter_jusqu_a(mm - 1)
			return


# =====================================================================
# Mois, notifications, modales du moteur
# =====================================================================

func _on_mois(res: Dictionary) -> void:
	var e := Partie.etat
	if e == null:
		return
	var anime: bool = not res.get("saut", false) and not en_titre
	var a := e.ab_courant()
	ville.call("regler_mois", Dates.mois(a), Dates.annee(a))
	hud.maj(e, anime)
	_maj_media(anime)
	var patr := e.patrimoine(e.joueur)
	_max_patr = maxf(_max_patr, patr)
	ville.set("pluie", patr < 0.85 * _max_patr or e.m <= _pluie_jusqua)
	# Salaire : 3 pièces de la banque vers le compte (en ×1 seulement)
	if anime and Partie.vitesse == 1 and e.m > e.m_depart:
		var depart: Vector2 = ville.call("ecran_batiment", ville.get("banque"), Vector2(0, -150))
		Juice.pieces(depart, _cible_argent(), 3)


func _cible_argent() -> Vector2:
	var l: Label = hud.l_patr if hud.compact else hud.l_cc
	return l.get_global_rect().get_center()


## Écran du toit du média : 30 derniers mois de l'indice (jamais le futur) et bandeau LED.
func _maj_media(anime: bool) -> void:
	var e := Partie.etat
	var media: Node = ville.get("media")
	var pts := PackedFloat64Array()
	for m in range(e.m - 29, e.m + 1):
		pts.append(e.indice(m))
	media.set("points_indice", pts)
	var a := e.ab_courant()
	var nom := e.mk.nom_indice(a)
	media.set("nom_ecran", "CAC 40" if nom.contains("CAC") else "INDICE")
	media.set("valeur_ecran", Format.nombre(e.indice(), 0))
	var v := e.indice() / e.indice(e.m - 1) - 1.0
	media.set("ticker", "%s : %s (%s) · LA GAZETTE, TOUTE L'ACTUALITÉ DE LA BOURSE · " % [nom.to_upper(), Format.nombre(e.indice(), 0), Format.pct(v)])
	media.set("trace_rouge", false)
	if anime and not Juice.animations_reduites:
		media.set("trace", 0.0)
		create_tween().tween_property(media, "trace", 1.0, minf(0.6, 0.4 * hud._duree_mois()))
	else:
		media.set("trace", 1.0)


func _on_notif(n: Dictionary) -> void:
	var e := Partie.etat
	var a := e.ab_courant()
	var type: String = n.get("type", "")
	if _ignorer_modales or en_titre:
		return
	if n.get("source", "") == "media":
		_petite_news(n)
		return
	var depart := Vector2(-1, -1)
	if n.get("source", "") == "maison":
		depart = ville.call("ecran_batiment", ville.get("maison"), Vector2(0, -150))
		_clignoter_maison()
		if n.has("montant"):
			Juice.flottant(Format.montant(float(n["montant"]), a, false, true), _cible_argent() + Vector2(0, 40), Style.GAIN if float(n["montant"]) > 0.0 else Style.PERTE)
	elif n.get("source", "") == "banque":
		var b: Vector2 = ville.call("ecran_batiment", ville.get("banque"), Vector2(0, -150))
		if type == "releve":
			_dernier_releve = n
		if type in ["interets", "releve", "coupon"] and float(n.get("montant", 0.0)) > 0.0:
			Juice.pieces(b, _cible_argent(), 5)
		ville.get("banque").call("ondes", 1)
		depart = b
	hud.notifier(n, a, depart)


## Toucher une notification : le relevé de décembre ouvre le détail des frais (13 §3.4).
func _on_notif_touchee(n: Dictionary) -> void:
	if n.get("type", "") != "releve" or float(n.get("frais_total", 0.0)) <= 0.0 or _occupe or modales.ouverte() or en_titre:
		return
	Partie.bloquee = true
	modales.releve(n, Partie.etat.ab_courant())
	await modales.choix_fait
	Partie.bloquee = false


## Toucher le compteur « Frais payés » : ce que les frais ont coûté, frais payés et gains manqués.
func _detail_frais() -> void:
	if en_titre or _occupe or modales.ouverte():
		return
	var e := Partie.etat
	var a := e.ab_courant()
	var n := {"titre": "Vos frais depuis le début", "frais_total": e.frais_payes(), "manque": e.manque_a_gagner(),
		"texte": "Droits d'entrée de la SICAV et de l'assurance-vie, courtage des actions, frais de gestion de la SICAV (prélevés chaque jour dans sa valeur) : %s au total. Tata Livret, elle, n'a payé aucun frais." % Format.entier(e.frais_payes(), a)}
	if e.frais_payes() <= 0.005:
		n["texte"] = "Vous n'avez payé aucun frais pour l'instant : le Livret A, le PEL et l'emprunt d'État n'en ont pas. La SICAV, l'assurance-vie et les actions en ont."
	Partie.bloquee = true
	modales.releve(n, a)
	await modales.choix_fait
	Partie.bloquee = false


func _on_modale(c: Dictionary) -> void:
	if _ignorer_modales or en_titre:
		return
	if c.get("kind", "") == "banquier":
		_vedette(_sequence_banquier.bind(c))
	elif c.get("kind", "") == "marche":
		_vedette(_sequence_journal.bind(c))
	elif c.get("effet", "") == "naissance":
		_vedette(_sequence_naissance.bind(c))
	else:
		_vedette(_sequence_courrier.bind(c))


func _on_fin(_bilan: Dictionary) -> void:
	_vedette(_sequence_fin)


# =====================================================================
# File des « vedettes » (une seule animation majeure à la fois)
# =====================================================================

func _vedette(f: Callable) -> void:
	_file.append(f)
	if not _occupe:
		_suivante()


func _suivante() -> void:
	if _file.is_empty():
		_occupe = false
		ville.set("interactif", not en_titre)
		return
	_occupe = true
	ville.set("interactif", false)
	var f: Callable = _file.pop_front()
	await f.call()
	_suivante()


func _attendre(d: float) -> void:
	var t := 0.0
	while t < d and not _passer:
		await get_tree().process_frame
		t += get_process_delta_time()


func _on_attrape(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		_passer = true


func _debut_animation(b: Node) -> void:
	_passer = Juice.animations_reduites
	_attrape.visible = true
	ville.call("viser", b, 0.35 * float(not Juice.animations_reduites))


func _fin_animation() -> void:
	_attrape.visible = false


## Effet 1 : l'appel du banquier (≤ 2 s, passable d'un toucher), puis la carte de présentation (13 §1)
## ou la carte « nouvelle » (héritage). « Ouvrir » ouvre la fenêtre Banque sur le formulaire du produit,
## avec un montant d'exemple seulement (12 §2.3).
func _sequence_banquier(c: Dictionary) -> void:
	var e := Partie.etat
	var banque: Node = ville.get("banque")
	await _sonnerie_banque()
	modales.presentation(c, ville.call("ecran_batiment", banque, Vector2(0, -200)))
	var r: Array = await modales.choix_fait
	var choix: String = r[1]
	if choix == "fermer":
		choix = "plus_tard"
	var res := Partie.resoudre_modale(choix)
	create_tween().tween_property(banque, "appel", 0.0, 0.4)
	ville.call("revenir")
	hud.point_banque(true)
	hud.maj(e, true, 0.4)
	if res.has("ouvrir"):
		await _ouvrir_banque(str(res["ouvrir"]), float(res.get("montant", -1.0)), true)


## Relire une présentation passée depuis la fiche du carnet (12 §2.4) : la carte en lecture seule.
func _relire(id: String) -> void:
	var e := Partie.etat
	modales.fermer("relire")
	await get_tree().create_timer(0.3).timeout
	var c := Banquier.contenu(e, id)
	var p := int(e.banque["presentes"].get(id, e.m))
	c["date"] = Dates.texte(e.ab_de(p))
	Partie.bloquee = true
	modales.presentation(c, Vector2(-1, -1), true)
	await modales.choix_fait
	Partie.bloquee = false
	var pid: String = Banquier.donnees()["presentations"].get(id, {}).get("produits", ["livret"])[0]
	_ouvrir_banque(pid, -2.0, true)


## Le téléphone sonne à la banque, le signal file vers la maison (1,9 s au plus).
func _sonnerie_banque() -> void:
	var banque: Node = ville.get("banque")
	_debut_animation(banque)
	var t := create_tween()
	t.tween_property(banque, "appel", 1.0, 0.2)
	await _attendre(0.2)
	banque.set("combine_visible", 1.0)
	banque.call("ondes", 3)
	var s := create_tween()
	for salve in 2:
		for k in 4:
			s.tween_property(banque, "sonnerie", deg_to_rad(12.0 if k % 2 == 0 else -12.0), 0.06).set_trans(Tween.TRANS_SINE)
		s.tween_property(banque, "sonnerie", 0.0, 0.06)
		s.tween_interval(0.12)
	await _attendre(0.7)
	var sig := create_tween()
	sig.tween_method(func(u: float) -> void: ville.set("signal_t", u), 0.0, 1.35, 0.6)
	await _attendre(0.5)
	_clignoter_maison()
	await _attendre(0.3)
	banque.set("combine_visible", 0.0)
	ville.set("signal_t", -1.0)
	_fin_animation()


func _clignoter_maison() -> void:
	var maison: Node = ville.get("maison")
	var t := create_tween()
	for k in 3:
		t.tween_property(maison, "flash", 1.0, 0.06)
		t.tween_property(maison, "flash", 0.0, 0.08)


## Effet 2 : le média s'emballe, les journaux jaillissent, puis le journal en modale.
func _sequence_journal(c: Dictionary) -> void:
	var e := Partie.etat
	var media: Node = ville.get("media")
	var krach: bool = c.get("gravite", "") == "majeure" and c.get("type", "") == "-"
	_debut_animation(media)
	var ecran_media: Vector2 = ville.call("ecran_batiment", media, Vector2(0, -470))
	if krach:
		_pluie_jusqua = e.m + 1
		ville.set("pluie", true)
		create_tween().tween_property(ville, "krach", 1.0, 0.8).set_trans(Tween.TRANS_SINE)
		media.set("flash_ticker", true)
		media.set("gresillement", 1.0)
		media.set("trace_rouge", true)
		media.set("trace", 0.0)
		create_tween().tween_property(media, "trace", 1.0, 0.8)
		media.call("ondes", Color(1, 0.3, 0.25), 3)
		for p in ville.get("passants"):
			p.set("arrete", true)
			p.scale.x = 1.0 if p.position.x < 0.0 else -1.0
		Juice.secouer(0.2)
		await _attendre(0.8)
		modales.journaux_volants(ecran_media, 2)
		await _attendre(0.5)
	else:
		media.call("ondes", Color.WHITE, 2)
		await _attendre(0.6)
	_fin_animation()
	modales.donnees_demo["_vente_totale"] = e.devis_vente_totale(e.joueur)
	modales.donnees_demo["_ab"] = e.ab_courant()
	modales.journal(c, ecran_media, krach and not _passer)
	var r: Array = await modales.choix_fait
	var res := Partie.resoudre_modale(r[1])
	media.set("flash_ticker", false)
	media.set("ticker", str(c["titre"]).to_upper() + " · ")
	for p in ville.get("passants"):
		p.set("arrete", false)
	create_tween().tween_property(ville, "krach", 0.25, 1.5)
	ville.call("revenir")
	hud.maj(e, true, 0.4)
	if res.has("ouvrir_achat"):
		var produit: String = res["ouvrir_achat"]
		if e.joueur.lignes.has("saintgobain"):
			produit = "saintgobain"
		await _ouvrir_banque(produit, float(res.get("montant_suggere", 0.0)), true)


## Effet 4 : un courrier arrive (panne de voiture : la voiture s'encastre d'abord dans le potelet),
## le drapeau se lève, l'enveloppe s'envole.
func _sequence_courrier(c: Dictionary) -> void:
	var e := Partie.etat
	var maison: Node = ville.get("maison")
	var voiture: Node2D = ville.get("voiture_maison")
	_debut_animation(maison)
	var crash: Dictionary = {}
	if c.get("picto", "") == "voiture":
		crash = await _crash_voiture(voiture)
	else:
		await _attendre(0.8)
	var td := create_tween()
	td.tween_property(maison, "drapeau", 1.0, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	td.parallel().tween_method(func(_v: float) -> void: maison.queue_redraw(), 0.0, 1.0, 0.2)
	await _attendre(0.25)
	_fin_animation()
	var boite: Vector2 = ville.call("ecran_batiment", maison, Vector2(172, -90))
	modales.courrier(c, boite, e)
	var r: Array = await modales.choix_fait
	Partie.resoudre_modale(r[1])
	var tr := create_tween()
	tr.tween_interval(1.0)
	tr.tween_property(maison, "drapeau", 0.0, 0.3)
	tr.parallel().tween_method(func(_v: float) -> void: maison.queue_redraw(), 0.0, 1.0, 0.3)
	tr.tween_property(voiture, "capot", 0.0, 0.3)
	tr.parallel().tween_method(func(_v: float) -> void: voiture.queue_redraw(), 0.0, 1.0, 0.3)
	if not crash.is_empty():
		_reparer_voiture(voiture, crash)
	ville.call("revenir")
	hud.maj(e, true, 0.5)


## Panne de voiture, version burlesque (≤ 2 s, passable d'un toucher) : le moteur tousse, la voiture
## part toute seule et percute le potelet (« BONK ! »), secousse, capot qui saute, fumée, l'enjoliveur
## s'enfuit en roulant, le triangle se pose. Renvoie de quoi tout remettre en place après le courrier.
func _crash_voiture(voiture: Node2D) -> Dictionary:
	var potelet: Node2D = ville.get("potelet")
	var x0 := voiture.position.x
	var etat := {"x0": x0, "accessoires": []}
	if Juice.animations_reduites:
		voiture.set("capot", 1.0)
		voiture.queue_redraw()
		await _attendre(0.3)
		return etat
	# 1. Deux hoquets du moteur, petit nuage à l'échappement
	_fumee(voiture, Vector2(-74, -16), 8)
	var t := create_tween()
	for k in 2:
		t.tween_property(voiture, "scale:y", 0.9, 0.07)
		t.tween_property(voiture, "scale:y", 1.0, 0.08)
	await _attendre(0.3)
	# 2. Embardée jusqu'au potelet
	var contact := potelet.position.x - 8.0 - 70.0
	var te := create_tween()
	te.tween_property(voiture, "position:x", contact, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	te.parallel().tween_property(voiture, "rotation", -0.04, 0.22)
	await _attendre(0.22)
	# 3. Choc
	Juice.secouer(0.4)
	var tc := create_tween().set_parallel(true)
	tc.tween_property(voiture, "position:x", contact - 14.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tc.tween_property(voiture, "rotation", 0.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tc.tween_property(voiture, "scale", Vector2(0.9, 1.06), 0.06)
	tc.chain().tween_property(voiture, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	var tp := create_tween()
	tp.tween_property(potelet, "rotation", 0.5, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	voiture.set("bosse", 1.0)
	voiture.set("sans_enjoliveur", true)
	var tk := create_tween()
	tk.tween_property(voiture, "capot", 1.0, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tk.parallel().tween_method(func(_v: float) -> void: voiture.queue_redraw(), 0.0, 1.0, 0.18)
	_fumee(voiture, Vector2(50, -48), 28)
	# Étoile de bande dessinée au point de choc
	var boum: Node2D = ville.call("ajouter_accessoire", "boum", Vector2(potelet.position.x + 30.0, -232), false)
	boum.scale = Vector2(0.1, 0.1)
	boum.rotation = 0.12
	var tb := create_tween()
	tb.tween_property(boum, "scale", Vector2(0.95, 0.95), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tb.tween_property(boum, "scale", Vector2(0.8, 0.8), 0.1)
	tb.tween_interval(0.55)
	tb.tween_property(boum, "modulate:a", 0.0, 0.25)
	tb.tween_callback(boum.queue_free)
	# L'enjoliveur s'échappe et traverse la rue en roulant
	var enj: Node2D = ville.call("ajouter_accessoire", "enjoliveur", voiture.position + Vector2(40, -12))
	var depart_enj := enj.position
	var tj := create_tween().set_parallel(true)
	tj.tween_property(enj, "position:x", depart_enj.x + 560.0, 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tj.tween_property(enj, "position:y", -64.0, 1.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tj.tween_property(enj, "rotation", TAU * 4.0, 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tj.chain().tween_property(enj, "modulate:a", 0.0, 0.3)
	tj.chain().tween_callback(enj.queue_free)
	await _attendre(0.5)
	# 4. Le triangle se pose derrière la voiture
	var tri: Node2D = ville.call("ajouter_accessoire", "triangle", Vector2(x0 - 120.0, -116))
	tri.scale = Vector2(0.1, 0.1)
	create_tween().tween_property(tri, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	etat["accessoires"] = [tri]
	await _attendre(0.45)
	return etat


## Après le courrier : la dépanneuse est passée, tout revient en place.
func _reparer_voiture(voiture: Node2D, crash: Dictionary) -> void:
	var potelet: Node2D = ville.get("potelet")
	var t := create_tween().set_parallel(true)
	t.tween_interval(1.0)
	t.chain().tween_property(voiture, "position:x", float(crash["x0"]), 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(potelet, "rotation", 0.0, 0.4)
	for a: Node2D in crash.get("accessoires", []):
		if is_instance_valid(a):
			t.tween_property(a, "modulate:a", 0.0, 0.4)
	t.chain().tween_callback(_voiture_neuve.bind(voiture))
	for a: Node2D in crash.get("accessoires", []):
		if is_instance_valid(a):
			t.tween_callback(a.queue_free)


const ROSE := Color("f7b6c8")
const BLEU := Color("a9d4f5")


## Effet 5 : naissance. Une cigogne traverse le ciel et dépose le paquet (deux pour des jumeaux) sur
## le rebord de la fenêtre de Gérard, qui s'allume ; confettis doux. 2 s au plus, passable d'un toucher.
func _sequence_naissance(c: Dictionary) -> void:
	var e := Partie.etat
	var maison: Node2D = ville.get("maison")
	_debut_animation(maison)
	var n := int(c.get("n", 1))
	var couleurs := []
	for s in c.get("sexes", []):
		couleurs.append(ROSE if s == "F" else BLEU)
	var paquets: Array = []
	if not Juice.animations_reduites:
		# Rebord de la fenêtre de Gérard (en haut à droite) : les paquets s'y posent
		var rebord := maison.position + Vector2(66, -136)
		var cig: Node2D = ville.call("ajouter_accessoire", "cigogne", Vector2(-1150, -620), false)
		cig.set("paquets", n)
		cig.set("couleurs_paquets", couleurs)
		cig.scale = Vector2(1.3, 1.3)
		var attache: Vector2 = cig.get("attache") * 1.3
		var lacher := Vector2(rebord.x, -540) - attache
		var tv := create_tween()
		tv.tween_property(cig, "position", lacher, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tv.tween_property(cig, "position", Vector2(420, -800), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tv.parallel().tween_property(cig, "modulate:a", 0.0, 0.3).set_delay(0.5)
		tv.tween_callback(cig.queue_free)
		await _attendre(0.75)
		# Lâcher : les paquets descendent en se balançant jusqu'au rebord
		cig.set("paquets", 0)
		for i in n:
			var dx := 0.0 if n == 1 else (-17.0 if i == 0 else 17.0)
			var p: Node2D = ville.call("ajouter_accessoire", "paquet", lacher + attache + Vector2(dx * 12.0 * 1.3 / 17.0, 0), false)
			p.set("couleur", couleurs[i] if i < couleurs.size() else ROSE)
			p.scale = Vector2(1.1, 1.1)
			p.queue_redraw()
			var arrivee := rebord + Vector2(dx, -36)
			var tp := create_tween().set_parallel(true)
			tp.tween_property(p, "position", arrivee, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tp.tween_property(p, "scale", Vector2.ONE, 0.6)
			var tr := create_tween()
			tr.tween_property(p, "rotation", 0.35 * (1.0 if i == 0 else -1.0), 0.18).set_trans(Tween.TRANS_SINE)
			tr.tween_property(p, "rotation", -0.22 * (1.0 if i == 0 else -1.0), 0.22).set_trans(Tween.TRANS_SINE)
			tr.tween_property(p, "rotation", 0.0, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			paquets.append(p)
		await _attendre(0.6)
		# Arrivée : la fenêtre s'allume, confettis
		var tf := create_tween()
		tf.tween_property(maison, "flash", 1.0, 0.15)
		_confettis(rebord + Vector2(0, -30))
		for p: Node2D in paquets:
			var ts := create_tween()
			ts.tween_property(p, "scale", Vector2(1.15, 0.85), 0.08)
			ts.tween_property(p, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await _attendre(0.5)
	else:
		maison.set("flash", 1.0)
	_fin_animation()
	var fenetre: Vector2 = ville.call("ecran_batiment", maison, Vector2(66, -170))
	modales.courrier(c, fenetre, e)
	var r: Array = await modales.choix_fait
	Partie.resoudre_modale(r[1])
	var fin_t := create_tween().set_parallel(true)
	fin_t.tween_property(maison, "flash", 0.0, 0.6).set_delay(0.6)
	for p: Node2D in paquets:
		if is_instance_valid(p):
			fin_t.tween_property(p, "modulate:a", 0.0, 0.5).set_delay(0.6)
	fin_t.chain().tween_callback(_liberer.bind(paquets))
	ville.call("revenir")
	hud.maj(e, true, 0.5)


func _liberer(noeuds: Array) -> void:
	for nd: Node in noeuds:
		if is_instance_valid(nd):
			nd.queue_free()


## Confettis pastel, doux : peu nombreux, ils retombent lentement en tournoyant.
func _confettis(pos: Vector2) -> void:
	if Juice.animations_reduites:
		return
	var img := Image.create(10, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	var p := CPUParticles2D.new()
	p.texture = ImageTexture.create_from_image(img)
	p.position = pos
	p.one_shot = true
	p.explosiveness = 0.9
	p.amount = 46
	p.lifetime = 1.8
	p.direction = Vector2(0, -1)
	p.spread = 75.0
	p.initial_velocity_min = 140.0
	p.initial_velocity_max = 300.0
	p.gravity = Vector2(0, 260)
	p.damping_min = 40.0
	p.damping_max = 80.0
	p.angular_velocity_min = -360.0
	p.angular_velocity_max = 360.0
	p.scale_amount_min = 1.1
	p.scale_amount_max = 1.9
	var g := Gradient.new()
	g.set_color(0, ROSE)
	g.set_color(1, BLEU)
	g.add_point(0.25, Color("fff1a8"))
	g.add_point(0.5, Color("bfeccf"))
	g.add_point(0.75, Color("d9c7f5"))
	p.color_initial_ramp = g
	var fondu := Gradient.new()
	fondu.set_color(0, Color(1, 1, 1, 1))
	fondu.set_color(1, Color(1, 1, 1, 0))
	fondu.add_point(0.7, Color(1, 1, 1, 1))
	p.color_ramp = fondu
	ville.get("_avant").add_child(p)
	p.emitting = true
	get_tree().create_timer(2.2).timeout.connect(p.queue_free)


func _voiture_neuve(voiture: Node2D) -> void:
	voiture.set("bosse", 0.0)
	voiture.set("sans_enjoliveur", false)
	voiture.queue_redraw()


func _fumee(voiture: Node2D, decalage := Vector2(50, -48), nombre := 24) -> void:
	if Juice.animations_reduites:
		return
	var p := CPUParticles2D.new()
	p.texture = ville.call("_texture_rond", 24)
	p.position = voiture.position + decalage
	p.one_shot = true
	p.amount = nombre
	p.lifetime = 1.5
	p.explosiveness = 0.5
	p.direction = Vector2(0.2, -1)
	p.spread = 35.0
	p.initial_velocity_min = 50.0
	p.initial_velocity_max = 110.0
	p.gravity = Vector2(10, -30)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.2
	var grossit := Curve.new()
	grossit.add_point(Vector2(0, 0.5))
	grossit.add_point(Vector2(1, 1.8))
	p.scale_amount_curve = grossit
	var grad := Gradient.new()
	grad.set_color(0, Color(0.3, 0.3, 0.33, 0.9))
	grad.set_color(1, Color(0.6, 0.6, 0.63, 0.0))
	p.color_ramp = grad
	ville.add_child(p)
	p.emitting = true
	get_tree().create_timer(2.0).timeout.connect(p.queue_free)


## Effet 3 : petite news sans pause (onde blanche, bandeau LED, notification qui vole du média).
func _petite_news(n: Dictionary) -> void:
	var media: Node = ville.get("media")
	media.call("ondes", Color.WHITE, 1)
	media.set("ticker", str(n.get("titre", "")).to_upper() + " · " + str(n.get("texte", "")).to_upper() + " · ")
	var depart: Vector2 = ville.call("ecran_batiment", media, Vector2(0, -470))
	hud.notifier(n, Partie.etat.ab_courant(), depart)


func _sequence_fin() -> void:
	var e := Partie.etat
	ville.set("pluie", false)
	modales.fin_demo(e)
	var r: Array = await modales.choix_fait
	if r[1] == "quitter":
		get_tree().quit()
		return
	_nouvelle_partie()
	_demarrer_direct(int(demo.get("vitesse_depart", 1)))


# =====================================================================
# Bâtiments, marché, menu
# =====================================================================

func _on_batiment(id: String) -> void:
	if en_titre or _occupe or modales.ouverte():
		return
	var e := Partie.etat
	var a := e.ab_courant()
	match id:
		"banque":
			_ouvrir_banque("", -2.0)
		"maison":
			var dep: Dictionary = e.depenses()
			var coussin := (maxf(0.0, e.joueur.cc) + e.joueur.livret) / float(dep["total"])
			var lignes_foyer := [
				"Salaire du mois : " + Format.montant(e.salaire_base, a),
				"Loyer : " + Format.montant(float(dep["loyer"]), a) + "   ·   Vie courante : " + Format.montant(float(dep["vie"]), a),
				"Il reste chaque mois : " + Format.montant(e.epargne_du_mois(), a),
				"Coussin de sécurité : %s mois de dépenses (on conseille 3 mois)." % Format.nombre(coussin, 1),
				"Prix de la baguette : " + Format.montant(Marche.baguette(a), a, true)]
			if e.enfants > 0:
				lignes_foyer.insert(2, "Enfants : %d (compris dans la vie courante : %s par mois)" % [e.enfants, Format.montant(float(dep["enfants"]), a)])
			var auto := Versements.total_mensuel(e) if e.banquier_actif() else 0.0
			if auto > 0.005:
				lignes_foyer.insert(lignes_foyer.size() - 2, "Versements automatiques : %s par mois, partis le 1er, avant les dépenses." % Format.entier(auto, a))
			Partie.bloquee = true
			modales.info("MON FOYER · " + e.prenom().to_upper(), lignes_foyer, ville.call("ecran_batiment", ville.get("maison"), Vector2(0, -150)), "COURRIERS REÇUS  ›")
			var r: Array = await modales.choix_fait
			Partie.bloquee = false
			if r[1] == "extra":
				_ouvrir_historique("maison")
		"media":
			# « Les nouvelles » (09 §2.1) : l'historique, filtré sur le média
			_ouvrir_historique("media")


## Toucher la pastille « VS TOUT AU LIVRET A » : ce que fait la référence, et l'écart du moment.
func _expliquer_comparaison() -> void:
	if en_titre or _occupe or modales.ouverte():
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
	Partie.bloquee = true
	modales.info("VOS CHOIX FACE À « TOUT AU LIVRET A »", [
		"Repère : le même salaire, les mêmes dépenses et les mêmes coups durs que vous, mais tout l'argent reste sur le compte courant et le Livret A (dans la limite du plafond). C'est le réflexe de beaucoup d'épargnants.",
		"Avec ce choix : %s.   Vous : %s." % [Format.montant(tata, a), Format.montant(e.patrimoine(e.joueur), a)],
		verdict,
		"La courbe bleue de « Mon argent » suit ce repère mois après mois."])
	await modales.choix_fait
	Partie.bloquee = false


func _info(titre_info: String, lignes: Array, b: Node) -> void:
	Partie.bloquee = true
	modales.info(titre_info, lignes, ville.call("ecran_batiment", b, Vector2(0, -150)))
	await modales.choix_fait
	Partie.bloquee = false


## La fenêtre Banque (13 §2) : carnet, fiche, ordre. montant < -1,5 : ouvrir sur la fiche (pas sur l'ordre).
func _ouvrir_banque(produit: String, montant: float, depuis_sequence := false) -> void:
	if modales.ouverte() or (_occupe and not depuis_sequence):
		return
	var e := Partie.etat
	if e == null or e.fin != "":
		return
	Partie.bloquee = true
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
		await _ouvrir_historique("banque", 0, true)
	hud.maj(e, true, 0.4)
	Partie.sauvegarder()


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


func _ouvrir_menu() -> void:
	if modales.ouverte() or _occupe:
		return
	Partie.bloquee = true
	modales.menu()
	var r: Array = await modales.choix_fait
	Partie.bloquee = false
	if r[1] == "quitter":
		Partie.sauvegarder()
		get_tree().quit()
	elif r[1] == "historique":
		await get_tree().create_timer(0.25).timeout
		_ouvrir_historique("")


# =====================================================================
# Historique des pop-ups (retour du joueur du 27/10/2026)
# =====================================================================

## Ouvre l'historique (filtre : "" | maison | banque | media). Toucher une ligne la relit en lecture seule,
## puis l'historique revient avec le même filtre et le même défilement. Le temps est en pause.
func _ouvrir_historique(filtre: String, defilement := 0, depuis_banque := false) -> void:
	if en_titre or (_occupe and not depuis_banque) or (modales.ouverte() and not depuis_banque):
		return
	var e := Partie.etat
	if e == null:
		return
	Partie.bloquee = true
	while true:
		modales.historique(e, filtre, defilement)
		var r: Array = await modales.choix_fait
		var id: String = r[1]
		if not id.begins_with("ouvrir:"):
			break
		filtre = modales.historique_filtre
		defilement = modales.historique_defilement
		await get_tree().create_timer(0.2).timeout
		await _relire_historique(int(id.split(":")[1]))
		await get_tree().create_timer(0.2).timeout
	Partie.bloquee = false


## Relit une entrée de l'historique telle qu'elle est apparue (chiffres d'alors), sans rejouer la décision.
func _relire_historique(i: int) -> void:
	var e := Partie.etat
	if i < 0 or i >= e.historique.size():
		return
	var h: Dictionary = e.historique[i]
	var a := e.ab_de(int(h["m"]))
	var c: Dictionary = h["contenu"]
	match str(h["genre"]):
		"appel":
			var bandeau := "HISTORIQUE · %s · VOTRE CHOIX : %s" % [Dates.texte(a).to_upper(), str(h["choix"]).to_upper()]
			modales.presentation(c, Vector2(-1, -1), true, bandeau)
		"journal":
			modales.journal(c, Vector2(-1, -1), false, str(h["choix"]))
		"courrier":
			modales.courrier(c, Vector2(-1, -1), e, str(h["choix"]), a)
		_:
			if str(h["type"]) == "releve" and float(c.get("frais_total", 0.0)) > 0.0:
				modales.releve(c, a)
			else:
				modales.lecture_notification(h, a)
	await modales.choix_fait


# =====================================================================
# Captures d'écran (outil de vérification du rendu, scripts/outils/capture.gd)
# =====================================================================

func preparer_capture(etape: String) -> void:
	var e := Partie.etat
	match etape:
		"titre":
			await get_tree().create_timer(3.0).timeout
			return
		"titre_continuer", "titre_confirmer":
			# Une partie sauvegardée en mars 1986 : l'écran titre propose « Continuer »
			_aller_a(Dates.lire("1986-03"), true)
			Partie.sauvegarde_auto = true
			Partie.sauvegarder()
			Partie.sauvegarde_auto = false
			_reprendre(Sauvegarde.lire(Partie.chemin_sauvegarde))
			_maj_titre()
			await get_tree().create_timer(3.0).timeout
			if etape == "titre_confirmer":
				_demander_nouvelle_partie()
				await get_tree().create_timer(0.8).timeout
			return
		"jouer":
			await get_tree().create_timer(2.6).timeout
			_jouer()
			await get_tree().create_timer(2.0).timeout
			return
		"sauver_fermer":
			# 1er lancement : on joue jusqu'à la présentation du PEL, puis on ferme la fenêtre pendant la carte
			e.resolution_auto()
			_demarrer_direct(0)
			_aller_a_modale("D02", false)
			await _attendre_que(func() -> bool: return modales.genre_courant == "appel", 8.0)
			await get_tree().create_timer(1.5).timeout
			notification(NOTIFICATION_WM_CLOSE_REQUEST)
			var d := Sauvegarde.lire(Partie.chemin_sauvegarde)
			print("Fermeture : sauvegarde %s, %s, modale en attente %s, patrimoine %s" % ["écrite" if not d.is_empty() else "ABSENTE",
				d.get("resume", {}).get("date", "?"), d.get("etat", {}).get("modale", {}).get("id", "aucune"), Format.montant(float(d.get("resume", {}).get("patrimoine", 0.0)), e.ab_courant())])
			return
		"reprise":
			# 2e lancement : l'écran titre propose « Continuer » ; la carte du PEL est rouverte à l'identique
			await get_tree().create_timer(2.5).timeout
			print("Titre : bouton %s, %s" % [_bouton_jouer.text, _l_reprise.text])
			_jouer()
			await _attendre_que(func() -> bool: return modales.genre_courant == "appel", 8.0)
			await get_tree().create_timer(1.8).timeout
			print("Reprise : %s, modale %s, cc %s" % [Dates.texte(Partie.etat.ab_courant()), Partie.etat.modale.get("id", "aucune"), Format.montant(Partie.etat.joueur.cc, Partie.etat.ab_courant())])
			return
	# Les autres étapes partent de la rue, sans la carte du Livret A (sauf si l'étape la veut)
	if etape not in ["presentation_livret", "presentation_livret_plus", "integrale"]:
		e.resolution_auto()
	_demarrer_direct(0)
	match etape:
		"presentation_livret", "presentation_livret_plus":
			await _attendre_que(func() -> bool: return modales.genre_courant == "appel", 8.0)
			await get_tree().create_timer(1.8).timeout
			if etape == "presentation_livret_plus":
				_appuyer_bouton(modales.courant, "En savoir plus ›")
				await get_tree().create_timer(0.6).timeout
		"presentation_av", "presentation_sicav", "presentation_emprunt", "heritage":
			var id: String = {"presentation_av": "D04", "presentation_sicav": "D05", "presentation_emprunt": "D03", "heritage": "D08"}[etape]
			_aller_a_modale(id, true)
			await _attendre_que(func() -> bool: return modales.genre_courant == "appel", 8.0)
			await get_tree().create_timer(1.8).timeout
			print("Carte %s : %d mots, comparée à %s" % [id, int(e.contenu_modale().get("mots", 0)), str(e.contenu_modale().get("comparatif", {}).get("ref", "-"))])
		"carnet", "banque_ordre", "f01":
			_aller_a(Dates.lire("1986-12") if etape == "carnet" else Dates.lire("1986-04"), true)
			if etape == "carnet":
				_ouvrir_banque("sicav", -2.0)
				await get_tree().create_timer(3.0).timeout
			elif etape == "banque_ordre":
				_ouvrir_banque("elf", Produits.f(1000.0))
				await get_tree().create_timer(3.0).timeout
			else:
				_ouvrir_banque("sicav", Produits.f(5000.0))
				await get_tree().create_timer(0.8).timeout
				modales.banque.call("_confirmer")
				await get_tree().create_timer(3.4).timeout
				print("F01 : frais payés %s, f01_vu %s" % [Format.montant(e.frais_payes(), e.ab_courant()), e.banque.get("f01_vu", false)])
		"releve", "releve_notif":
			_aller_a(Dates.lire("1985-12"), true)
			hud.basculer_panneau(true)
			Partie.changer_vitesse(3)
			await _attendre_que(func() -> bool: return Partie.etat.ab_courant() >= Dates.lire("1986-01"), 8.0)
			await get_tree().create_timer(0.8).timeout
			if etape == "releve":
				Partie.changer_vitesse(0)
				_on_notif_touchee(_dernier_releve)
				await get_tree().create_timer(0.8).timeout
			print("Relevé : ", _dernier_releve.get("texte", "?"))
		"rue", "rue_nuit", "foyer", "marche_banque":
			_aller_a(Dates.lire("1987-05"), true)
			ville.set("phase", 0.72 if etape == "rue_nuit" else 0.18)
			Partie.changer_vitesse(1)
			await get_tree().create_timer(2.6).timeout
			if etape == "foyer":
				_on_batiment("maison")
				await get_tree().create_timer(0.6).timeout
			elif etape == "marche_banque":
				_on_batiment("banque")
				await get_tree().create_timer(0.8).timeout
		"pause", "panneau":
			_aller_a(Dates.lire("1988-01"), true)
			if etape == "panneau":
				Partie.programmer_versement("livret", Produits.f(500.0))
				hud.basculer_panneau(true)
			await get_tree().create_timer(1.0).timeout
		"historique", "historique_filtre", "historique_entree", "historique_journal", "historique_courrier":
			# Une partie jouée jusqu'en juin 1988, avec un versement automatique sur la SICAV depuis avril 1986
			_aller_a(Dates.lire("1986-04"), true)
			e.programmer_versement("sicav", Produits.f(300.0))
			_aller_a(Dates.lire("1988-06"), true)
			_ouvrir_historique("")
			await get_tree().create_timer(1.0).timeout
			if etape == "historique_filtre":
				var bf := modales.courant.find_child("Filtre_banque", true, false) as Button
				bf.button_pressed = true   # comme un toucher : le bouton s'allume et la liste se filtre
				await get_tree().create_timer(0.6).timeout
			elif etape != "historique":
				var cible := -1
				for h: Dictionary in e.historique_recent(""):
					var ok := false
					match etape:
						"historique_entree":
							ok = h["genre"] == "appel" and h["contenu"].get("heritage", false)
						"historique_journal":
							ok = h["genre"] == "journal"
						"historique_courrier":
							ok = h["genre"] == "courrier"
					if ok:
						cible = int(h["i"])
						break
				modales.historique_defilement = 0
				modales.fermer("ouvrir:%d" % cible)
				await get_tree().create_timer(1.6).timeout
			print("Historique : %d entrées (maison %d, banque %d, média %d) ; 5 plus récentes : %s" % [e.historique.size(), e.historique_recent("maison").size(),
				e.historique_recent("banque").size(), e.historique_recent("media").size(), str(e.historique_recent("").slice(0, 5).map(func(h: Dictionary) -> String: return "%s %s" % [Dates.texte_court(e.ab_de(int(h["m"]))), h["titre"]]))])
		"carnet_pel", "automatique", "automatique_pel":
			_aller_a(Dates.lire("1986-12"), true)
			_ouvrir_banque("sicav" if etape == "automatique" else "pel", -2.0)
			await get_tree().create_timer(1.2).timeout
			if etape == "automatique":
				modales.banque.call("_afficher_automatique", "sicav")
				await get_tree().create_timer(0.3).timeout
				modales.banque.call("_regler_automatique", "sicav", Produits.f(500.0))
			elif etape == "automatique_pel":
				modales.banque.call("_afficher_automatique", "pel")
			await get_tree().create_timer(1.0).timeout
			print("PEL : %s ; carte : %s" % [Banquier.texte_taux_pel(e), Banquier.texte_taux_pel(e, true)])
		"krach", "krach_anim", "courrier":
			_aller_a_modale("p1e6", true)
			if etape == "krach_anim":
				await _attendre_que(func() -> bool: return _occupe, 15.0)
				await get_tree().create_timer(1.05).timeout
				return
			await _attendre_que(func() -> bool: return modales.genre_courant == "journal", 15.0)
			await get_tree().create_timer(1.6).timeout
			if etape == "courrier":
				modales.call("_on_choix_journal", "rien")
				Partie.changer_vitesse(3)
				await _attendre_que(func() -> bool: return modales.genre_courant == "courrier", 15.0)
				await get_tree().create_timer(1.3).timeout
		"comparaison", "comparaison_info":
			_aller_a(Dates.lire("1988-06"), true)
			hud.basculer_panneau(true)
			print("Écart Livret A en %s : %s (vous %s, Tata Livret %s)" % [Dates.texte(e.ab_courant()), Format.ecart(e.ecart_livret(), e.ab_courant()),
				Format.montant(e.patrimoine(e.joueur), e.ab_courant()), Format.montant(e.patrimoine(e.temoins["livret"]), e.ab_courant())])
			await get_tree().create_timer(1.0).timeout
			if etape == "comparaison_info":
				_expliquer_comparaison()
				await get_tree().create_timer(0.8).timeout
		"crash_anim", "crash_fin", "crash_courrier":
			_aller_a_modale("voiture", true)
			var attente_crash: float = {"crash_anim": 0.62, "crash_fin": 1.3, "crash_courrier": 3.6}[etape]
			await get_tree().create_timer(attente_crash).timeout
		"naissance_anim", "naissance_pose", "naissance":
			_aller_a_modale("naissance", true)
			var attente_n: float = {"naissance_anim": 0.5, "naissance_pose": 1.45, "naissance": 3.6}[etape]
			await get_tree().create_timer(attente_n).timeout
			print("Naissance : %s, %d enfant(s), reste %s par mois" % [Partie.etat.contenu_modale().get("titre", "?"), Partie.etat.enfants, Format.montant(Partie.etat.epargne_du_mois(), Partie.etat.ab_courant())])
		"jumeaux_anim", "jumeaux_pose", "jumeaux":
			_aller_a(Dates.lire("1984-05"), true)
			ville.set("phase", 0.18)
			Partie.forcer_naissance(true)
			var attente_j: float = {"jumeaux_anim": 0.5, "jumeaux_pose": 1.45, "jumeaux": 3.6}[etape]
			await get_tree().create_timer(attente_j).timeout
		"news":
			_aller_a(Dates.lire("1988-05"), true)
			Partie.changer_vitesse(2)
			await _attendre_que(func() -> bool: return Partie.etat.ab_courant() >= Dates.lire("1988-06"), 15.0)
			await get_tree().create_timer(0.9).timeout
		"fin":
			_aller_a(Dates.lire("1988-11"), true)
			Partie.changer_vitesse(3)
			await _attendre_que(func() -> bool: return modales.genre_courant == "fin", 15.0)
			await get_tree().create_timer(3.4).timeout
		"polices":
			_verifier_polices()
		"trafic":
			_aller_a(Dates.lire("1987-05"), true)
			for v in [1, 2, 3, 0]:
				Partie.changer_vitesse(v)
				await get_tree().create_timer(1.2).timeout
				var v_voitures: float = await _vitesse_mesuree(ville.get("_voitures"))
				var v_passants: float = await _vitesse_mesuree(ville.get("passants"))
				print("Trafic à la vitesse %d : voitures %.0f u/s, passants %.0f u/s (facteur %.2f)" % [v, v_voitures, v_passants, float(ville.get("facteur_trafic"))])
		"clic_dehors":
			_aller_a(Dates.lire("1984-03"), true)
			_on_batiment("maison")
			await get_tree().create_timer(0.6).timeout
			await _clic_dehors(Vector2(get_window().size) / 2.0)
			print("Clic dedans · foyer toujours ouvert : %s" % [modales.genre_courant == "info"])
			await _clic_dehors()
			print("Clic dehors · foyer (maison) fermé : %s, temps débloqué : %s" % [not modales.ouverte(), not Partie.bloquee])
			_on_batiment("media")
			await get_tree().create_timer(0.6).timeout
			await _clic_dehors()
			print("Clic dehors · nouvelles (média) fermé : %s" % [not modales.ouverte()])
			_on_batiment("banque")
			await get_tree().create_timer(0.8).timeout
			await _clic_dehors(Vector2(6, 6))
			print("Clic dehors · banque fermée : %s, temps débloqué : %s" % [not modales.ouverte(), not Partie.bloquee])
			_ouvrir_menu()
			await get_tree().create_timer(0.4).timeout
			await _clic_dehors()
			print("Clic dehors · menu fermé : %s" % [not modales.ouverte()])
			_aller_a_modale("D02", false)
			await _attendre_que(func() -> bool: return modales.genre_courant == "appel", 8.0)
			await get_tree().create_timer(1.2).timeout
			await _clic_dehors(Vector2(6, 6))
			await get_tree().create_timer(0.3).timeout
			print("Clic dehors · carte du banquier fermée : %s (« pas maintenant », PEL présenté : %s)" % [modales.genre_courant != "appel", Banquier.presente(Partie.etat, "pel")])
			_aller_a_modale("p1e6", true)
			await _attendre_que(func() -> bool: return modales.genre_courant == "journal", 15.0)
			await get_tree().create_timer(1.6).timeout
			await _clic_dehors(Vector2(6, 6))
			await get_tree().create_timer(0.1).timeout
			print("Clic dehors · journal du krach toujours ouvert : %s" % [modales.genre_courant == "journal"])
		"fps":
			_aller_a(Dates.lire("1987-11"), true)
			ville.set("pluie", true)
			ville.set("krach", 1.0)
			Partie.changer_vitesse(1)
			await get_tree().create_timer(1.0).timeout
			var n0 := Engine.get_frames_drawn()
			var t1 := Time.get_ticks_msec()
			await get_tree().create_timer(3.0).timeout
			print("Images par seconde (moyenne sur 3 s) : %.1f" % ((Engine.get_frames_drawn() - n0) * 1000.0 / (Time.get_ticks_msec() - t1)))
		"integrale":
			await _integrale()
		"f10":
			print("F10 avant : fenêtre %s, zone logique %s, compact %s" % [get_window().size, Ecran.taille(), Ecran.compact()])
			for i in 2:
				var ev := InputEventKey.new()
				ev.keycode = KEY_F10
				ev.pressed = true
				Input.parse_input_event(ev)
				await get_tree().create_timer(0.6).timeout
				print("F10 n° %d : fenêtre %s, facteur %s, zone logique %s, compact %s, panneau visible %s" % [
					i + 1, get_window().size, get_window().content_scale_factor, Ecran.taille(), Ecran.compact(), hud.panneau.visible])


## Joueur « actif » des captures : il ouvre chaque produit présenté et y place une partie de son argent,
## et range l'excédent du compte sur le Livret A (comme le joueur actif des tests).
func _strategie_active(e: EtatPartie) -> void:
	if not e.modale.is_empty():
		var c := e.contenu_modale()
		if c["kind"] == "banquier" and not c.get("heritage", false):
			var r := e.resoudre_modale("ouvrir")
			var f := Produits.f
			match str(r.get("ouvrir", "")):
				"livret":
					e.deposer_livret(e.joueur, e.joueur.cc * 0.8)
				"pel":
					e.ouvrir_pel(f.call(2000.0), f.call(500.0))
				"emprunt":
					e.acheter_emprunt(minf(f.call(10000.0), e.joueur.cc * 0.8))
				"av":
					e.verser_av(minf(f.call(10000.0), e.joueur.cc * 0.8))
				"sicav":
					e.acheter(e.joueur, "sicav", minf(f.call(5000.0), e.joueur.cc * 0.8))
				"elf":
					e.acheter(e.joueur, "elf", minf(f.call(3000.0), e.joueur.cc * 0.8))
				"saintgobain":
					e.acheter(e.joueur, "saintgobain", f.call(3100.0))
		elif c["kind"] == "vie" and c["choix"].size() > 1 and c["choix"][0]["id"] == "vendre" and not c["choix"][0].get("desactive", false):
			e.resoudre_modale("vendre")   # un coup dur plus gros que le compte : on puise dans le Livret A
		else:
			e.resolution_auto()
	if e.joueur.cc < 0.0 and e.joueur.livret > 0.0:
		e.retirer_livret(e.joueur, minf(e.joueur.livret, -e.joueur.cc + e.salaire_base))
	if e.joueur.cc > e.salaire_base and Banquier.presente(e, "livret"):
		e.deposer_livret(e.joueur, minf(e.joueur.cc - e.salaire_base, e.place_livret(e.joueur)))


## Avance (sans animation) jusqu'au mois absolu « ab », en jouant de façon active ou passive.
func _aller_a(ab: int, actif: bool) -> void:
	var e := Partie.etat
	var garde := 0
	while e.fin == "" and e.ab_courant() < ab and garde < 100:
		if actif:
			_strategie_active(e)
		elif not e.modale.is_empty():
			e.resolution_auto()
		if not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()
		garde += 1
	_rafraichir_apres_saut()


## Avance jusqu'à ce que la modale « id » (présentation, krach p1e6, voiture, naissance) soit ouverte.
func _aller_a_modale(id: String, actif: bool) -> void:
	var e := Partie.etat
	var garde := 0
	while e.fin == "" and garde < 100:
		if not e.modale.is_empty():
			var c := e.contenu_modale()
			var ident := str(e.modale.get("id", ""))
			if e.modale.get("kind", "") == "vie":
				ident = str(e.calendrier[int(e.modale["idx"])]["type"])
			if ident == id:
				break
			if actif:
				_strategie_active(e)
			if not e.modale.is_empty():
				e.resolution_auto()
		elif actif:
			_strategie_active(e)
		e.avancer()
		garde += 1
	_rafraichir_apres_saut()
	Partie.rouvrir_modale()


func _rafraichir_apres_saut() -> void:
	var e := Partie.etat
	ville.call("regler_mois", Dates.mois(e.ab_courant()), Dates.annee(e.ab_courant()))
	hud.maj(e, false)
	_maj_media(false)


func _appuyer_bouton(racine: Node, texte: String) -> void:
	if racine == null:
		return
	for n in racine.find_children("*", "Button", true, false):
		var b := n as Button
		if b.text == texte:
			b.pressed.emit()
			return


## Toute la démo à ×3, réponses automatiques par l'interface : présentations (une sur deux ouverte, avec un
## achat), banque, journal, courrier, jusqu'à la fin. Vérifie l'enchaînement complet sans erreur.
func _integrale() -> void:
	Partie.changer_vitesse(3)
	var vus := {}
	var n_appels := 0
	var t0 := Time.get_ticks_msec()
	while modales.genre_courant != "fin" and Time.get_ticks_msec() - t0 < 330000:
		await get_tree().create_timer(0.3).timeout
		var g := modales.genre_courant
		if g == "" or not modales.ouverte():
			if not _occupe and Partie.vitesse != 3 and Partie.etat.fin == "" and Partie.etat.modale.is_empty():
				Partie.changer_vitesse(3)
			continue
		vus[g] = int(vus.get(g, 0)) + 1
		await get_tree().create_timer(1.0).timeout
		match g:
			"appel":
				n_appels += 1
				if Partie.etat.modale.get("id", "") == "D08":
					modales.fermer("compris")
				else:
					modales.fermer("ouvrir" if n_appels % 2 == 1 else "plus_tard")
			"banque":
				var pb: PanneauBanque = modales.banque
				if pb.get("_b_ok") != null and is_instance_valid(pb.get("_b_ok")) and pb.get("_droite").is_ancestor_of(pb.get("_b_ok")):
					pb.call("_part", 0.25)
					pb.call("_confirmer")
					await get_tree().create_timer(2.6).timeout
				pb.fermer_demande.emit()
			"journal":
				modales.call("_on_choix_journal", "rien")
			"courrier":
				modales.fermer(str(Partie.etat.contenu_modale()["choix"][0]["id"]))
			"info", "confirmer", "menu":
				modales.fermer("fermer")
	var e := Partie.etat
	print("Intégrale : modales vues %s, fin = %s, mois = %s, patrimoine = %s, interruptions = %d, frais = %s, durée %.0f s à ×3" % [vus, e.fin, Dates.texte(e.ab_courant()),
		Format.montant(e.patrimoine(e.joueur), e.ab_courant()), int(e.banque.get("interruptions", 0)), Format.montant(e.frais_payes(), e.ab_courant()), (Time.get_ticks_msec() - t0) / 1000.0])


## Clic gauche simulé (par défaut près du bord gauche de la fenêtre, à mi-hauteur : hors de toute pop-up).
func _clic_dehors(pos := Vector2(-1, -1)) -> void:
	if pos.x < 0.0:
		pos = Vector2(20, get_window().size.y / 2.0)
	for appui in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = appui
		ev.position = pos
		ev.global_position = pos
		Input.parse_input_event(ev)
		await get_tree().process_frame


## Vitesse moyenne (unités par seconde) des nœuds mobiles sur 0,5 s (le passage d'un bord à l'autre est écarté).
func _vitesse_mesuree(noeuds: Array) -> float:
	var x0: Array = []
	for n: Node2D in noeuds:
		x0.append(n.position.x)
	await get_tree().create_timer(0.5).timeout
	var total := 0.0
	var compte := 0
	for i in noeuds.size():
		var n: Node2D = noeuds[i]
		var dx := absf(n.position.x - float(x0[i]))
		if dx < 1000.0 and float(n.get("vitesse")) > 0.0 and n.get("arrete") != true:
			total += dx / 0.5
			compte += 1
	return total / maxf(1.0, compte)


func _attendre_que(condition: Callable, delai: float) -> void:
	var t := 0.0
	while not condition.call() and t < delai:
		await get_tree().process_frame
		t += get_process_delta_time()


## Vérifie que les chiffres de Bahnschrift sont à chasse fixe (tnum) : tous les chiffres ont la même avance.
func _verifier_polices() -> void:
	var f := Style.chiffres()
	var largeurs := []
	for ch in "0123456789":
		largeurs.append(snappedf(f.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, 48).x, 0.01))
	var base := (f as FontVariation).base_font as SystemFont
	var sans := []
	for ch in "0123456789":
		sans.append(snappedf(base.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, 48).x, 0.01))
	print("Police des chiffres : ", base.get_font_name(), " (", base.get_font_style_name(), ")")
	print("Avances avec tnum : ", largeurs)
	print("Avances sans tnum : ", sans)
	print("Chasse fixe : ", "OUI" if largeurs.min() == largeurs.max() else "NON")
	var polices := {"ui": Style.ui(), "manchette": Style.manchette(), "titre_journal": Style.titre_journal(),
		"journal": Style.journal(), "led": Style.led()}
	for nom in polices:
		var p: Font = polices[nom]
		print("Police %s : %s" % [nom, p.get_font_name()])
