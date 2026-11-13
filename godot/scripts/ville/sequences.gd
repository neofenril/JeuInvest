class_name Sequences
extends Node
## Séquences animées de la rue pixel (lot PX1 §4.4, 09 §5), enfant de la scène principale : appel du banquier,
## journal (et krach), courrier (et panne burlesque de la voiture), naissance, petite news, fin, journal
## lumineux de la Gazette. Une seule « vedette » à la fois (file) ; chaque animation de bâtiment dure 2,6 s au
## plus et se passe d'un toucher (A34) ; la caméra glisse vers le bâtiment qui parle puis revient (revenir).
## Tout est en pixels entiers : accessoires du catalogue (objet/…), jamais tournés ni agrandis.
## Avec --controle, chaque séquence imprime « RUE sequence <nom> duree=<s> camera=<départ>-><arrivée> ».
## Ajouter une séquence : une fonction _sequence_x(c) ici, lancée par vedette() depuis jouer_modale().

const RUE := preload("res://scripts/ville/rue.gd")
const PIECE_COTE := 24.0                 # pièce 8 × 8 texels de 3 px virtuels
const ARCS_PIECES := [120.0, 180.0, 240.0, 300.0, 360.0, 420.0, 480.0, 60.0, 0.0]   # essayés dans cet ordre (arc_pieces)
const ECART_FLOTTANTS := 6.0             # entre deux cartouches empilés (px virtuels)
const PORTE_IMAGE_S := 0.08              # porte de la maison : 3 images (carte du foyer)

var _piles: Array = []                   # piles de cartouches à l'écran : [rectangle balayé, fin (s)] (m3 de 03-V)

var jeu: Node          # scène principale (principal.gd) : en_titre, pluie_jusqua, demo, ouvrir_banque, nouvelle_partie, demarrer_direct
var ville: Node2D
var hud: Hud
var modales: Modales
var occupe := false    # une vedette est en cours (lu par principal.gd et les scénarios de capture)
var derniere := {}     # dernière séquence jouée : {nom, duree, camera} (contrôles des captures)
var _file: Array = []
var _passer := false
var _t_passe := -1.0
var _attrape: Control
var _controle := false


## Confettis pixel (carrés 2 × 2 de la palette), positions entières, retombent puis disparaissent.
class Confettis extends Node2D:
	var rue: Node2D
	var bouts: Array = []        # [pos, vitesse, couleur]
	var age := 0.0
	const COULEURS := ["or", "neon_rose", "ciel_clair", "feuille_eclat", "blanc_chaud", "lumiere"]

	func lancer(n: int) -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 85
		for i in n:
			var a := rng.randf_range(-PI * 0.9, -PI * 0.1)
			bouts.append([Vector2.ZERO, Vector2(cos(a), sin(a)) * rng.randf_range(40.0, 110.0), COULEURS[i % COULEURS.size()]])

	func _process(delta: float) -> void:
		age += delta
		for b in bouts:
			b[1].y += 140.0 * delta
			b[1] *= 1.0 - 1.5 * delta
			b[0] += b[1] * delta
		if age > 1.8:
			rue.call("oublier", self)
			queue_free()
		queue_redraw()

	func _draw() -> void:
		for b in bouts:
			var p: Vector2 = b[0]
			var r := Rect2i(Vector2i(p.round()), Vector2i(2, 2))
			var c: String = b[2]
			if PalettePixel.emissive(c):
				rue.emissif(self, r, c)
			else:
				rue.rect(self, r, c)


## Références passées par principal.gd ; l'attrape-toucher (passer une animation, A34) va dans le calque des modales.
func installer(p_jeu: Node, p_ville: Node2D, p_hud: Hud, p_modales: Modales, calque_modales: CanvasLayer) -> void:
	jeu = p_jeu
	ville = p_ville
	hud = p_hud
	modales = p_modales
	_controle = "--controle" in OS.get_cmdline_user_args()
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
	elif c.get("kind", "") == "carte":
		vedette(_sequence_carte.bind(c))
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
		passer()


## Passe l'animation en cours (toucher, A34).
func passer() -> void:
	if not _passer:
		_passer = true
		_t_passe = Time.get_ticks_msec() / 1000.0


func _debut_animation(b: Node, duree_cam := 0.45) -> void:
	_passer = Juice.animations_reduites
	_t_passe = -1.0
	_attrape.visible = true
	ville.call("viser", b, duree_cam * float(not Juice.animations_reduites))


func _fin_animation(nom: String, t0: float, cameras: String) -> void:
	_attrape.visible = false
	var duree := Time.get_ticks_msec() / 1000.0 - t0
	derniere = {"nom": nom, "duree": duree, "camera": cameras}
	if _controle:
		print("RUE sequence %s duree=%.2f camera=%s" % [nom, duree, cameras])
		if _t_passe >= 0.0:
			print("RUE passee %s delai=%.2f" % [nom, Time.get_ticks_msec() / 1000.0 - _t_passe])
	if _passer and not Juice.animations_reduites:
		ville.call("revenir", 0.25)


func _maintenant() -> float:
	return Time.get_ticks_msec() / 1000.0


## Nom du bâtiment devant lequel est la caméra (maison, banque, media).
func _camera() -> String:
	var meilleur := "maison"
	var ecart := INF
	var cx: float = ville.call("position_camera")
	for id in ["maison", "banque", "media"]:
		var b: Node2D = ville.call("batiment", id)
		var d: float = absf(float(ville.call("cx_pour", b.position.x)) - cx)
		if d < ecart:
			ecart = d
			meilleur = id
	return meilleur


## Point d'écran d'un bâtiment (px virtuels), ramené au bord de l'écran s'il est hors champ (les cartes et les
## pièces entrent alors par le bord).
func _depart(b: Node2D, decalage := Vector2.ZERO) -> Vector2:
	var p: Vector2 = ville.call("position_ecran", b.position + decalage)
	var t := ville.get_viewport_rect().size
	return Vector2(clampf(p.x, 8.0, t.x - 8.0), clampf(p.y, 8.0, t.y - 8.0))


func _rue() -> Node2D:
	return ville.get("rue")


# =====================================================================
# Journal lumineux de la Gazette
# =====================================================================

## Journal lumineux : 30 derniers mois de l'indice (jamais le futur) et bandeau défilant.
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
	media.set("ticker_rouge", false)
	if anime and not Juice.animations_reduites:
		media.set("trace", 0.0)
		create_tween().tween_property(media, "trace", 1.0, minf(0.6, 0.4 * hud._duree_mois()))
	else:
		media.set("trace", 1.0)


# =====================================================================
# Séquences
# =====================================================================

## Effet 1 : l'appel du banquier (≤ 2,6 s, passable d'un toucher) : la caméra glisse vers la banque, M. Lefranc
## décroche, le combiné sonne, ondes ; le signal file vers la maison, la caméra le suit, la fenêtre de Gérard
## clignote ; puis la carte de présentation (13 §1) ou la carte « nouvelle » (héritage).
func _sequence_banquier(c: Dictionary) -> void:
	var e := Partie.etat
	var banque: Node = ville.get("banque")
	await _sonnerie_banque()
	modales.presentation(c, _depart(banque, Vector2(0, -150)))
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


func _sonnerie_banque() -> void:
	var t0 := _maintenant()
	var cam0 := _camera()
	var banque: Node2D = ville.get("banque")
	var maison: Node2D = ville.get("maison")
	_debut_animation(banque, 0.5)
	await _attendre(0.5)
	var cam1 := _camera()
	banque.set("appel", 1.0)
	banque.set("combine_visible", 1.0)
	banque.set("sonnerie", 1.0)
	banque.call("ondes", 3)
	await _attendre(0.8)
	banque.set("sonnerie", 0.0)
	# Le signal file de la fenêtre du banquier à celle de Gérard ; la caméra le suit
	var depart: Vector2 = banque.position + banque.call("point_fenetre")
	var arrivee: Vector2 = maison.position + maison.call("point_fenetre")
	var sig: Node2D = _rue().call("ajouter", ["objet/signal"], depart, 0.0)
	if not _passer:
		var milieu := (depart + arrivee) / 2.0 + Vector2(0, -140)
		var ts := create_tween()
		ts.tween_method(_poser_signal.bind(sig, depart, milieu, arrivee), 0.0, 1.0, 0.7)
		ville.call("revenir", 0.7)
		await _attendre(0.7)
		clignoter_maison()
		await _attendre(0.3)
	if is_instance_valid(sig):
		sig.call("liberer")
	banque.set("combine_visible", 0.0)
	_fin_animation("banquier", t0, "%s->%s->%s" % [cam0, cam1, _camera() if not _passer else "maison"])


func _poser_signal(u: float, sig: Node2D, depart: Vector2, milieu: Vector2, arrivee: Vector2) -> void:
	if is_instance_valid(sig):
		sig.set("pos", depart.lerp(milieu, u).lerp(milieu.lerp(arrivee, u), u))


func clignoter_maison() -> void:
	var maison: Node = ville.get("maison")
	var t := create_tween()
	for k in 3:
		t.tween_property(maison, "flash", 1.0, 0.05)
		t.tween_property(maison, "flash", 0.0, 0.05)


## Effet 2 : la caméra glisse vers la Gazette, le journal lumineux s'emballe (au krach : orage, pluie, écran
## rouge qui grésille, passants arrêtés, secousse, journaux qui volent), puis le journal en modale.
func _sequence_journal(c: Dictionary) -> void:
	var e := Partie.etat
	var media: Node2D = ville.get("media")
	var krach: bool = c.get("gravite", "") == "majeure" and c.get("type", "") == "-"
	var t0 := _maintenant()
	var cam0 := _camera()
	_debut_animation(media, 0.45)
	var ecran_media := _depart(media, Vector2(0, -300))
	if krach:
		jeu.pluie_jusqua = e.m + 1
		ville.set("pluie", true)
		create_tween().tween_property(ville, "krach", 1.0, 0.8).set_trans(Tween.TRANS_SINE)
		media.set("flash_ticker", true)
		media.set("gresillement", 1.0)
		media.set("trace_rouge", true)
		media.set("ticker_rouge", true)
		media.set("trace", 0.0)
		create_tween().tween_property(media, "trace", 1.0, 0.8)
		media.call("ondes", PalettePixel.couleur("perte"), 3)
		for p in ville.get("passants") + [_rue().get("gerard")]:
			p.set("arrete", true)
		Juice.secouer(0.2)
		await _attendre(0.8)
		ecran_media = _depart(media, Vector2(0, -300))
		modales.journaux_volants(ecran_media, 2)
		await _attendre(0.5)
	else:
		await _attendre(0.45)
		media.call("ondes", Color.WHITE, 2)
		await _attendre(0.55)
		ecran_media = _depart(media, Vector2(0, -300))
	_fin_animation("journal_krach" if krach else "journal", t0, "%s->%s" % [cam0, _camera()])
	modales.donnees_demo["_vente_totale"] = e.devis_vente_totale(e.joueur)
	modales.donnees_demo["_ab"] = e.ab_courant()
	modales.journal(c, ecran_media, krach and not _passer)
	var r: Array = await modales.choix_fait
	var res := Partie.resoudre_modale(r[1])
	media.set("flash_ticker", false)
	media.set("ticker", str(c["titre"]).to_upper() + " · ")
	for p in ville.get("passants") + [_rue().get("gerard")]:
		p.set("arrete", false)
	create_tween().tween_property(ville, "krach", 0.0, 1.5)
	ville.call("revenir")
	hud.maj(e, true, 0.4)
	if res.has("ouvrir_achat"):
		var produit: String = res["ouvrir_achat"]
		if e.joueur.lignes.has("saintgobain"):
			produit = "saintgobain"
		await jeu.ouvrir_banque(produit, float(res.get("montant_suggere", 0.0)), true)


## Effet 4 : un courrier arrive (panne de voiture : la voiture s'encastre d'abord dans le potelet) ; la boîte
## aux lettres s'ouvre, l'enveloppe en sort, puis le courrier en modale.
func _sequence_courrier(c: Dictionary) -> void:
	var e := Partie.etat
	var maison: Node2D = ville.get("maison")
	var voiture: Node2D = ville.get("voiture_maison")
	var t0 := _maintenant()
	var cam0 := _camera()
	_debut_animation(maison, 0.35)
	var crash: Dictionary = {}
	var nom := "courrier"
	if c.get("picto", "") == "voiture":
		nom = "crash"
		crash = await _crash_voiture(voiture)
	else:
		await _attendre(0.7)
	var td := create_tween()
	td.tween_property(maison, "drapeau", 1.0, 0.2)
	var boite: Vector2 = maison.position + maison.call("point_boite")
	var env: Node2D = _rue().call("ajouter", ["objet/enveloppe"], boite)
	if not _passer:
		create_tween().tween_property(env, "pos", boite + Vector2(6, -30), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await _attendre(0.3)
	_fin_animation(nom, t0, "%s->%s" % [cam0, _camera()])
	if is_instance_valid(env):
		env.call("liberer")
	modales.courrier(c, _depart(maison, maison.call("point_boite")), e)
	var r: Array = await modales.choix_fait
	Partie.resoudre_modale(r[1])
	var tr := create_tween()
	tr.tween_interval(1.0)
	tr.tween_property(maison, "drapeau", 0.0, 0.3)
	tr.tween_property(voiture, "capot", 0.0, 0.3)
	if not crash.is_empty():
		_reparer_voiture(voiture, crash)
	ville.call("revenir")
	hud.maj(e, true, 0.5)


## Carte de dilemme du foyer (lot 04, §4.3 ; docs/17 §3.1, §4.1) : la caméra glisse sur la maison, la porte s'ouvre
## en 3 images (sortie ≤ 1 s, passable d'un toucher), puis Modales.carte (03-I2) part de la porte ; sans elle,
## repli permanent sur le courrier. Un choix refusé (désactivé : resoudre_modale rend {}) laisse la carte ouverte
## (le courrier est rouvert). Puis conclure_carte si elle existe, et la porte se referme.
func _sequence_carte(c: Dictionary) -> void:
	var e := Partie.etat
	var maison: Node2D = ville.get("maison")
	var t0 := _maintenant()
	var cam0 := _camera()
	_debut_animation(maison, 0.35)
	await _attendre(0.35)
	for k in [1, 2, 3]:
		maison.set("porte_ouverte", k)
		await _attendre(PORTE_IMAGE_S)
	maison.set("porte_ouverte", 3)
	var sortie := _maintenant() - t0
	_fin_animation("carte", t0, "%s->%s" % [cam0, _camera()])
	_trace("RUE carte sortie=%.2f porte=3 carte=%s" % [sortie, "modales" if modales.has_method("carte") else "courrier"])
	var porte := _point_porte_maison()
	var avec_carte := modales.has_method("carte")
	var res := {}
	while res.is_empty():
		if avec_carte:
			if res.is_empty() and not modales.ouverte():
				modales.call("carte", Partie.etat.contenu_modale(), porte)
		else:
			modales.courrier(Partie.etat.contenu_modale(), porte, e)
		var r: Array = await modales.choix_fait
		res = Partie.resoudre_modale(str(r[1]))
		if Partie.etat.modale.is_empty() and res.is_empty():
			break                                      # carte fermée ailleurs (filet du moteur) : rien à rouvrir
	_trace("RUE carte choix=%s montant=%s" % [str(res.get("choix", "")), str(res.get("montant", ""))])
	if avec_carte and modales.has_method("conclure_carte") and not res.is_empty():
		await modales.call("conclure_carte", res, porte)
	for k in [2, 1, 0]:
		maison.set("porte_ouverte", k)
		await get_tree().create_timer(PORTE_IMAGE_S).timeout
	ville.call("revenir")
	hud.maj(e, true, 0.5)


## Porte de la maison à l'écran (départ et rangement de la carte), ramenée au bord si elle est hors champ.
func _point_porte_maison() -> Vector2:
	var p: Vector2 = ville.call("porte_ecran", "maison")
	if p.x >= 0.0:
		return p
	var maison: Node2D = ville.get("maison")
	return _depart(maison, (maison.call("porte") as Rect2).get_center())


## Panne de voiture, version burlesque (≤ 2,6 s, passable d'un toucher) : le moteur tousse, la voiture part
## toute seule et percute le potelet (« BONK »), secousse, capot qui saute, fumée, l'enjoliveur s'enfuit en
## roulant, le triangle se pose. Renvoie de quoi tout remettre en place après le courrier.
func _crash_voiture(voiture: Node2D) -> Dictionary:
	var potelet: Node2D = ville.get("potelet")
	var rue := _rue()
	var x0: float = voiture.get("x_monde")
	var etat := {"x0": x0, "accessoires": []}
	if Juice.animations_reduites or _passer:
		voiture.set("capot", 1.0)
		potelet.set("images", ["objet/potelet_1"])
		await _attendre(0.2)
		return etat
	var arriere := voiture.position + Vector2(-70, -10)
	# 1. Deux hoquets du moteur, petits nuages à l'échappement
	for k in 2:
		voiture.set("hoquet", 2)
		_fumee(arriere, 1)
		await _attendre(0.08)
		voiture.set("hoquet", 0)
		await _attendre(0.08)
	if _passer:
		return etat
	# 2. Embardée jusqu'au potelet
	var contact := potelet.position.x - 70.0 - 4.0
	var te := create_tween()
	te.tween_property(voiture, "x_monde", contact, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await _attendre(0.25)
	# 3. Choc : secousse, recul, potelet plié, capot, fumée, « BONK », enjoliveur
	Juice.secouer(0.4)
	create_tween().tween_property(voiture, "x_monde", contact - 10.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	potelet.set("images", ["objet/potelet_1"])
	voiture.set("bosse", 1.0)
	voiture.set("sans_enjoliveur", true)
	create_tween().tween_property(voiture, "capot", 1.0, 0.18)
	_fumee(voiture.position + Vector2(56, -50), 3)
	var boum: Node2D = rue.call("ajouter", ["objet/bonk"], Vector2(potelet.position.x + 6, potelet.position.y - 58))
	var tb := create_tween()
	tb.tween_interval(0.75)
	tb.tween_property(boum, "alpha", 0.0, 0.2)
	tb.tween_callback(boum.call.bind("liberer"))
	var enj: Node2D = rue.call("ajouter", ["objet/enjoliveur_0", "objet/enjoliveur_1"], voiture.position + Vector2(44, -4), 10.0, true)
	var tj := create_tween().set_parallel(true)
	tj.tween_property(enj, "pos", enj.position + Vector2(300, 28), 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tj.chain().tween_property(enj, "alpha", 0.0, 0.3)
	tj.chain().tween_callback(enj.call.bind("liberer"))
	await _attendre(0.5)
	# 4. Le triangle se pose derrière la voiture
	var tri: Node2D = rue.call("ajouter", ["objet/triangle"], Vector2(contact - 100.0, RUE.Y_GAREE - 2), 0.0, true)
	etat["accessoires"] = [tri]
	await _attendre(0.4)
	return etat


## Après le courrier : la dépanneuse est passée, tout revient en place.
func _reparer_voiture(voiture: Node2D, crash: Dictionary) -> void:
	var potelet: Node2D = ville.get("potelet")
	var t := create_tween()
	t.tween_interval(1.0)
	t.tween_property(voiture, "x_monde", float(crash["x0"]), 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(_voiture_neuve.bind(voiture, potelet, crash))


func _voiture_neuve(voiture: Node2D, potelet: Node2D, crash: Dictionary) -> void:
	potelet.set("images", ["objet/potelet_0"])
	potelet.queue_redraw()
	voiture.set("bosse", 0.0)
	voiture.set("sans_enjoliveur", false)
	for a in crash.get("accessoires", []):
		if is_instance_valid(a):
			a.call("liberer")


func _fumee(p: Vector2, n: int) -> void:
	if Juice.animations_reduites:
		return
	for i in n:
		var f: Node2D = _rue().call("ajouter", ["objet/fumee_0", "objet/fumee_1", "objet/fumee_2"], p + Vector2(i * 6, -i * 4), 5.0)
		f.set("une_fois", true)
		create_tween().tween_property(f, "pos", p + Vector2(10 + i * 8, -26 - i * 6), 0.6)


## Effet 5 : naissance. Une cigogne traverse le ciel et dépose le paquet (deux pour des jumeaux) sur le rebord de
## la fenêtre de Gérard, qui s'allume ; confettis pixel. 2,6 s au plus, passable d'un toucher.
func _sequence_naissance(c: Dictionary) -> void:
	var e := Partie.etat
	var maison: Node2D = ville.get("maison")
	var rue := _rue()
	var t0 := _maintenant()
	var cam0 := _camera()
	_debut_animation(maison, 0.35)
	var n := int(c.get("n", 1))
	var noms := []
	for s in c.get("sexes", []):
		noms.append("objet/paquet_rose" if s == "F" else "objet/paquet_bleu")
	var paquets: Array = []
	var rebord: Vector2 = maison.position + maison.call("point_rebord")
	if not Juice.animations_reduites:
		var v: Rect2 = rue.get("vue")
		var cig: Node2D = rue.call("ajouter", ["objet/cigogne_1", "objet/cigogne_2"], Vector2(v.position.x - 30, v.position.y + 90), 6.0)
		var lacher := Vector2(rebord.x, rebord.y - 110)
		var tv := create_tween()
		tv.tween_property(cig, "pos", lacher + Vector2(0, -14), 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tv.tween_property(cig, "pos", Vector2(v.end.x + 60, v.position.y + 40), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tv.tween_callback(cig.call.bind("liberer"))
		await _attendre(0.75)
		for i in n:
			var dx := 0.0 if n == 1 else (-9.0 if i == 0 else 9.0)
			var p: Node2D = rue.call("ajouter", [noms[i] if i < noms.size() else "objet/paquet_rose"], lacher + Vector2(dx, 0))
			var tp := create_tween()
			tp.tween_property(p, "pos", rebord + Vector2(dx, -15), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			paquets.append(p)
		await _attendre(0.6)
		for p in paquets:
			p.set("pos", rebord + Vector2(p.position.x - rebord.x, -15))
		create_tween().tween_property(maison, "flash", 1.0, 0.15)
		_confettis(rebord + Vector2(0, -20))
		await _attendre(0.5)
	else:
		maison.set("flash", 1.0)
	_fin_animation("naissance", t0, "%s->%s" % [cam0, _camera()])
	modales.courrier(c, _depart(maison, maison.call("point_fenetre")), e)
	var r: Array = await modales.choix_fait
	Partie.resoudre_modale(r[1])
	var fin_t := create_tween().set_parallel(true)
	fin_t.tween_property(maison, "flash", 0.0, 0.6).set_delay(0.6)
	for p in paquets:
		if is_instance_valid(p):
			fin_t.tween_property(p, "alpha", 0.0, 0.5).set_delay(0.6)
	fin_t.chain().tween_callback(_liberer.bind(paquets))
	ville.call("revenir")
	hud.maj(e, true, 0.5)


func _liberer(noeuds: Array) -> void:
	for nd in noeuds:
		if is_instance_valid(nd):
			nd.call("liberer")


func _confettis(pos: Vector2) -> void:
	if Juice.animations_reduites:
		return
	var cf := Confettis.new()
	cf.rue = _rue()
	cf.position = pos.round()
	cf.lancer(40)
	(_rue().get("effets") as Node2D).add_child(cf)


## Effet 3 : petite news sans pause (ondes de la Gazette, bandeau, notification qui part de la Gazette) ; la
## caméra ne bouge pas.
func petite_news(n: Dictionary) -> void:
	var media: Node2D = ville.get("media")
	var cam := _camera()
	media.call("ondes", Color.WHITE, 1)
	media.set("ticker", str(n.get("titre", "")).to_upper() + " · " + str(n.get("texte", "")).to_upper() + " · ")
	hud.notifier(n, Partie.etat.ab_courant(), _depart(media, Vector2(0, -300)))
	derniere = {"nom": "petite_news", "duree": 0.0, "camera": "%s->%s" % [cam, cam]}
	if _controle:
		print("RUE sequence petite_news duree=0.00 camera=%s->%s" % [cam, cam])


# =====================================================================
# Pièces du mois (lot 02, P4 « le mois utile » : D8, D9, D10)
# =====================================================================

## Appelé par principal.gd à chaque mois_passe (par has_method). Or : revenus du mois, de la porte de la banque à
## celle de la maison ; cuivre : frais, de la maison vers la banque. Un bâtiment dont la porte n'est pas à
## l'écran : départ ou arrivée au bord intérieur de sa flèche de bord, qui saute (hud.sauter_etiquette). Aucune
## porte à l'écran : pas de pièce, seulement le montant flottant près du compteur COMPTE. Rien en pause, à ×3,
## pendant un saut, après un saut de test (F8), à l'écran titre ni quand une séquence arrive (une seule vedette).
func pieces_du_mois(res: Dictionary) -> void:
	var raison := ""
	var p := {}
	if typeof(res.get("flux")) != TYPE_DICTIONARY:
		raison = "pas_de_flux"
	elif res.get("saut", false):
		raison = "saut_test"
	elif jeu == null or jeu.en_titre or Partie.etat == null:
		raison = "titre"
	else:
		p = PiecesMois.plan(res["flux"], Partie.vitesse, Partie.saut_actif or bool(res.get("pendant_saut", false)), Partie.etat.ab_courant() - 1)
		raison = p["raison"]
		if raison == "" and (occupe or not (res.get("modale", {}) as Dictionary).is_empty() or str(res.get("fin", "")) != ""):
			raison = "sequence"
	if raison == "" and _lieu_pieces("maison") != "maison" and _lieu_pieces("banque") != "banque":
		raison = "hors_champ"
		_flottants_compte(p)
	if raison != "":
		_trace("RUE pieces aucune raison=%s" % raison)
		return
	var delai := 0.0
	if not p["or"].is_empty():
		_lancer_pieces(p["or"], p["lignes"], false)
		delai = 0.6
	if not p["cuivre"].is_empty():
		if delai > 0.0:
			get_tree().create_timer(delai).timeout.connect(_lancer_pieces.bind(p["cuivre"], [], true))
		else:
			_lancer_pieces(p["cuivre"], [], true)


func _lancer_pieces(regle: Dictionary, lignes: Array, cuivre: bool) -> void:
	var de := "maison" if cuivre else "banque"
	var vers := "banque" if cuivre else "maison"
	var n: int = regle["n"]
	_trace("RUE pieces genre=%s n=%d depart=%s arrivee=%s montant=%s" % ["cuivre" if cuivre else "or", n, _lieu_pieces(de), _lieu_pieces(vers), str(regle["texte"]).replace("\n", " / ")])
	var couleur := Style.CUIVRE if cuivre else Style.GAIN
	var etat := {"arrivees": 0}
	if cuivre:
		# Les frais partent de la maison : le montant s'affiche au départ
		_flottants_pile([[str(regle["texte"]), couleur]], _point_pieces(de))
	var arc := arc_pieces(_point_pieces(de), _point_pieces(vers))
	_trace("RUE pieces arc=%d" % roundi(arc))
	Juice.pieces_suivies(_point_pieces.bind(de), _point_pieces.bind(vers), n, cuivre,
		_piece_arrivee.bind(vers, regle, lignes, couleur, cuivre, etat, n), _piece_depart.bind(de), arc)


## Hauteur d'arc des pièces (lot 03, m1) : la plus proche de Juice.ARC_PIECE dont la courbe ne touche aucune
## enseigne dorée (pièce de PIECE_COTE px, marge d'une pièce : la rue peut glisser un peu pendant le vol) et dont
## le sommet reste dans le rectangle libre ; arcs plus hauts d'abord, puis plus bas. Aucun ne convient : l'arc
## qui touche le moins d'enseignes.
func arc_pieces(d: Vector2, a: Vector2) -> float:
	var rects := enseignes_ecran(PIECE_COTE)
	var haut := (hud.rect_libre() if hud != null else ville.get_viewport_rect()).position.y + PIECE_COTE / 2.0
	var meilleur := Juice.ARC_PIECE
	var moins := 1 << 30
	for arc: float in ARCS_PIECES:
		var touche := 0
		for k in 33:
			var p := Juice.point_arc(d, a, arc, k / 32.0)
			if p.y < haut:
				touche += 1
			for r: Rect2 in rects:
				if r.has_point(p):
					touche += 1
		if touche == 0:
			return arc
		if touche < moins:
			moins = touche
			meilleur = arc
	return meilleur


## Enseignes dorées de la rue en px d'écran logiques, agrandies de « marge » px de chaque côté.
func enseignes_ecran(marge := 0.0) -> Array:
	var r: Array = []
	for e: Rect2 in RUE.enseignes():
		var p0: Vector2 = ville.call("position_ecran", e.position)
		var p1: Vector2 = ville.call("position_ecran", e.end)
		r.append(Rect2(p0, p1 - p0).grow(marge))
	return r


func _piece_depart(id: String) -> void:
	_sauter_si_fleche(id)


func _piece_arrivee(id: String, regle: Dictionary, lignes: Array, couleur: Color, cuivre: bool, etat: Dictionary, n: int) -> void:
	etat["arrivees"] = int(etat["arrivees"]) + 1
	_sauter_si_fleche(id)
	if etat["arrivees"] == 1 and not cuivre:
		# L'argent qui a travaillé arrive à la maison : le montant, puis un cartouche par coupon ou dividende
		var textes: Array = [[str(regle["texte"]), couleur]]
		for k in lignes.size():
			_trace("RUE pieces ligne texte=%s" % str(lignes[k]).replace("\n", " / "))
			textes.append([str(lignes[k]), couleur])
		_flottants_pile(textes, _point_pieces(id))
	if etat["arrivees"] == n and _controle:
		var cible := _point_pieces(id)
		print("RUE pieces arrivee genre=%s lieu=%s ecart=%d" % ["cuivre" if cuivre else "or", _lieu_pieces(id), roundi(Juice.derniere_arrivee.distance_to(cible))])


## Où partent ou arrivent les pièces d'un bâtiment : son nom (porte à l'écran), « fleche_gauche » ou
## « fleche_droite » (flèche de bord du HUD), sinon "" (ni l'un ni l'autre : bord de l'écran).
func _lieu_pieces(id: String) -> String:
	var porte: Vector2 = ville.call("porte_ecran", id) if ville.has_method("porte_ecran") else Vector2(-1, -1)
	if porte.x >= 0.0:
		return id
	var et: Control = hud.etiquettes.get(id) if hud != null else null
	if et != null and et.is_visible_in_tree() and str(et.get_meta("fleche", "")) != "":
		return "fleche_" + str(et.get_meta("fleche", ""))
	return ""


## Point d'écran (relu à chaque image) : porte, bord intérieur de la flèche de bord (milieu du côté tourné vers
## le centre du rectangle libre), sinon le bâtiment ramené au bord de l'écran.
func _point_pieces(id: String) -> Vector2:
	var lieu := _lieu_pieces(id)
	if lieu == id:
		return ville.call("porte_ecran", id)
	if lieu.begins_with("fleche_"):
		var r: Rect2 = (hud.etiquettes[id] as Control).get_global_rect()
		return Vector2(r.end.x if lieu == "fleche_gauche" else r.position.x, r.get_center().y)
	return _depart(ville.call("batiment", id))


func _sauter_si_fleche(id: String) -> void:
	if _lieu_pieces(id).begins_with("fleche_") and hud != null and hud.has_method("sauter_etiquette"):
		hud.call("sauter_etiquette", id)


## Cartouches empilés au-dessus d'un point (textes : [[texte, couleur]], le premier en haut, les suivants 0,3 s
## après l'un l'autre), la pile entière (montée comprise) gardée dans le rectangle libre du HUD (lot 03, D7).
## Lot 04 (m1, m3 de 03-V) : la pile évite le panneau INDICE de la Gazette et les piles encore à l'écran (or et
## cuivre du même mois) : elle monte, puis descend, puis glisse de côté jusqu'à une place libre.
func _flottants_pile(textes: Array, pos: Vector2, au_dessus := 36.0) -> void:
	var vrais: Array = textes.filter(func(t: Array) -> bool: return str(t[0]) != "")
	if vrais.is_empty():
		return
	textes = vrais
	var libre: Rect2 = (hud.rect_libre() if hud != null else ville.get_viewport_rect()).grow(-6.0)
	var tailles: Array = []
	var largeur := 0.0
	var hauteur := -ECART_FLOTTANTS
	for t in textes:
		var s: Vector2 = Juice.taille_flottant(str(t[0]))
		tailles.append(s)
		largeur = maxf(largeur, s.x)
		hauteur += s.y + ECART_FLOTTANTS
	# Juice.flottant : haut du cartouche à p.y − 20, puis montée de MONTEE_FLOTTANT
	var haut_min := libre.position.y + Juice.MONTEE_FLOTTANT + 20.0
	var haut_max := maxf(haut_min, libre.end.y - hauteur + 20.0)
	var x_min := libre.position.x + largeur / 2.0
	var x_max := maxf(x_min, libre.end.x - largeur / 2.0)
	var p0 := pos + Vector2(0, -au_dessus)
	p0 = Vector2(clampf(p0.x, x_min, x_max), clampf(p0.y, haut_min, haut_max))
	var maintenant := _maintenant()
	_piles = _piles.filter(func(z: Array) -> bool: return float(z[1]) > maintenant)
	var obstacles: Array = []
	for z in _piles:
		obstacles.append(z[0])
	if ville.has_method("panneau_indice_ecran"):
		obstacles.append((ville.call("panneau_indice_ecran") as Rect2).grow(4.0))
	var p := p0
	for c: Vector2 in _places_pile(p0, Vector2(x_min, x_max), Vector2(haut_min, haut_max)):
		var libre_ici := true
		for o: Rect2 in obstacles:
			if _balayage_pile(c, largeur, hauteur).intersects(o):
				libre_ici = false
				break
		if libre_ici:
			p = c
			break
	_piles.append([_balayage_pile(p, largeur, hauteur), maintenant + 0.3 * (textes.size() - 1) + 1.0])
	var y := p.y
	for k in textes.size():
		var ici := Vector2(p.x, y)
		if k == 0:
			Juice.flottant(str(textes[k][0]), ici, textes[k][1])
		else:
			get_tree().create_timer(0.3 * k).timeout.connect(Juice.flottant.bind(str(textes[k][0]), ici, textes[k][1]))
		y += (tailles[k] as Vector2).y + ECART_FLOTTANTS


## Rectangle balayé par une pile (départ et montée) dont le premier cartouche part de p.
func _balayage_pile(p: Vector2, largeur: float, hauteur: float) -> Rect2:
	return Rect2(p.x - largeur / 2.0, p.y - 20.0 - Juice.MONTEE_FLOTTANT, largeur, hauteur + Juice.MONTEE_FLOTTANT)


## Places essayées pour une pile, dans l'ordre : la place voulue, plus haut, plus bas, puis de côté.
func _places_pile(p0: Vector2, xs: Vector2, ys: Vector2) -> Array:
	var r: Array = [p0]
	# Plus haut d'abord (le bas de l'écran porte les étiquettes des bâtiments), puis de côté, puis plus bas
	for k in range(1, 50):
		if p0.y - 12.0 * k >= ys.x:
			r.append(Vector2(p0.x, p0.y - 12.0 * k))
	var bas: Array = []
	for k in range(1, 40):
		if p0.y + 12.0 * k <= ys.y:
			bas.append(Vector2(p0.x, p0.y + 12.0 * k))
	for k in range(1, 30):
		for sens in [-1.0, 1.0]:
			var x: float = p0.x + sens * 40.0 * k
			if x >= xs.x and x <= xs.y:
				for dy in [0.0, -60.0, -120.0, 60.0, 120.0]:
					var y := clampf(p0.y + dy, ys.x, ys.y)
					r.append(Vector2(x, y))
	return r + bas

## Ni maison ni banque à l'écran : seulement les montants, près du compteur COMPTE (D8).
func _flottants_compte(p: Dictionary) -> void:
	if hud == null:
		return
	var l: Label = hud.l_cc if hud.l_cc != null and hud.l_cc.is_visible_in_tree() else hud.l_patr
	# Sous le compteur, dans la rue : les cartouches montent et s'effacent sans recouvrir le chiffre
	var r := l.get_global_rect()
	var libre: Rect2 = hud.rect_libre()
	var pos := Vector2(r.get_center().x, maxf(r.end.y, libre.position.y) + 100.0)
	var textes: Array = []
	if not p.get("or", {}).is_empty():
		textes.append([str(p["or"]["texte"]), Style.GAIN])
		for t in p.get("lignes", []):
			textes.append([str(t), Style.GAIN])
	if not p.get("cuivre", {}).is_empty():
		textes.append([str(p["cuivre"]["texte"]), Style.CUIVRE])
	for t in textes:
		_trace("RUE pieces flottant compte texte=%s" % str(t[0]).replace("\n", " / "))
	_flottants_pile(textes, pos, 0.0)


func _trace(t: String) -> void:
	if _controle:
		print(t)


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
