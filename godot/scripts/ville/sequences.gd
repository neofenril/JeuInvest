class_name Sequences
extends Node
## Séquences animées de la ville (09 §5), enfant de la scène principale : appel du banquier, journal,
## courrier (et panne de voiture), naissance, petite news, fin, écran du média. Une seule « vedette » à la
## fois (file) ; chaque animation de bâtiment dure 2 s au plus et se passe d'un toucher (A34).
## Ajouter une séquence : une fonction _sequence_x(c) ici, lancée par vedette() depuis jouer_modale().

const ROSE := Color("f7b6c8")
const BLEU := Color("a9d4f5")

var jeu: Node          # scène principale (principal.gd) : en_titre, pluie_jusqua, demo, ouvrir_banque, nouvelle_partie, demarrer_direct
var ville: Node2D
var hud: Hud
var modales: Modales
var occupe := false    # une vedette est en cours (lu par principal.gd et les scénarios de capture)
var _file: Array = []
var _passer := false
var _attrape: Control


## Références passées par principal.gd ; l'attrape-toucher (passer une animation, A34) va dans le calque des modales.
func installer(p_jeu: Node, p_ville: Node2D, p_hud: Hud, p_modales: Modales, calque_modales: CanvasLayer) -> void:
	jeu = p_jeu
	ville = p_ville
	hud = p_hud
	modales = p_modales
	_attrape = Control.new()
	_attrape.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_attrape.mouse_filter = Control.MOUSE_FILTER_STOP
	_attrape.visible = false
	_attrape.gui_input.connect(_on_attrape)
	calque_modales.add_child(_attrape)


## Modale ouverte par le moteur : la séquence qui l'amène.
func jouer_modale(c: Dictionary) -> void:
	if c.get("kind", "") == "banquier":
		vedette(_sequence_banquier.bind(c))
	elif c.get("kind", "") == "marche":
		vedette(_sequence_journal.bind(c))
	elif c.get("effet", "") == "naissance":
		vedette(_sequence_naissance.bind(c))
	else:
		vedette(_sequence_courrier.bind(c))


func fin() -> void:
	vedette(_sequence_fin)


# =====================================================================
# File des « vedettes » (une seule animation majeure à la fois)
# =====================================================================

func vedette(f: Callable) -> void:
	_file.append(f)
	if not occupe:
		_suivante()


func _suivante() -> void:
	if _file.is_empty():
		occupe = false
		ville.set("interactif", not jeu.en_titre)
		return
	occupe = true
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


# =====================================================================
# Écran du toit du média
# =====================================================================

## Écran du toit du média : 30 derniers mois de l'indice (jamais le futur) et bandeau LED.
func maj_media(anime: bool) -> void:
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


# =====================================================================
# Séquences
# =====================================================================

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
		await jeu.ouvrir_banque(str(res["ouvrir"]), float(res.get("montant", -1.0)), true)


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
	clignoter_maison()
	await _attendre(0.3)
	banque.set("combine_visible", 0.0)
	ville.set("signal_t", -1.0)
	_fin_animation()


func clignoter_maison() -> void:
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
		jeu.pluie_jusqua = e.m + 1
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
		await jeu.ouvrir_banque(produit, float(res.get("montant_suggere", 0.0)), true)


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
func petite_news(n: Dictionary) -> void:
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
	jeu.nouvelle_partie()
	jeu.demarrer_direct(int(jeu.demo.get("vitesse_depart", 1)))
