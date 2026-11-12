extends Batiment
## Maison de Gérard (PX0 quater, 228 × 258) : Sylvie à sa fenêtre (3 humeurs + clignement), fenêtre de
## Gérard qui s'allume (flash : appel, naissance), boîte aux lettres jaune qui s'ouvre (drapeau : courrier).
## Lot 04 (03-V2, docs/17 §4.2) : chaque humeur a un visage, une posture et une fenêtre (contente : coucou toutes
## les 8 s réelles, pot de géraniums, jamais de clignement ; neutre : clignement toutes les 3 à 5 s ; fâchée : bras
## croisés, rideau gauche tiré, clignement). Changement d'humeur (changer_humeur) : clignement, puis la nouvelle
## image. Traces des cartes à la façade (traces, D11) : lueur bleue de télévision le soir, antenne, diplôme sur
## l'appui à droite, escargot sur le mur ; porte d'entrée en 3 images (porte_ouverte 0 à 3, sortie de la carte).

const F := preload("res://scripts/pixel/facades.gd")
const HUMEURS := ["sylvie_contente", "sylvie_neutre", "sylvie_contrariee"]
const FENETRE_GERARD := Rect2i(168, 99, 36, 48)       # dans l'image (coin haut gauche)
const BOITE := Rect2i(142, 198, 13, 18)
const FENETRE_TELE := Rect2i(24, 186, 36, 48)         # fenêtre du salon (rez-de-chaussée, à gauche)
const COUCOU_TOUS_S := 8.0
const COUCOU_DUREE_S := 0.5
const CLIGNE_CHANGEMENT_S := 0.15
const POS_GERANIUMS := Vector2i(16, 147)              # sur l'appui de Sylvie, à gauche (coin bas gauche)
const POS_RIDEAU := Vector2i(26, 106)                 # rideau gauche tiré (coin haut gauche)
const POS_DIPLOME := Vector2i(59, 147)                # sur l'appui de Sylvie, à droite (milieu du bas)
const POS_ANTENNE := Vector2i(150, 16)                # contre la cheminée (milieu du bas)
const POS_ESCARGOT := Vector2i(142, 166)              # sur le mur de l'étage, entre deux fenêtres (Gérard ne le cache jamais)

var flash := 0.0:
	set(v):
		flash = v
		queue_redraw()
var drapeau := 0.0:
	set(v):
		drapeau = v
		queue_redraw()
var humeur := 1:                                        # humeur affichée (0 contente, 1 neutre, 2 fâchée)
	set(v):
		humeur = clampi(v, 0, 2)
		_suivante = humeur
		queue_redraw()
var traces := PackedStringArray():                      # traces des cartes (ville.suivre_foyer)
	set(v):
		if v != traces:
			traces = v
			queue_redraw()
var porte_ouverte := 0:                                 # 0 fermée … 3 grande ouverte
	set(v):
		porte_ouverte = clampi(v, 0, 3)
		queue_redraw()
var anime := true
var _suivante := 1
var _cligne_t := 3.0
var _cligne := 0.0
var _coucou_t := 0.0
var _coucou := 0                                        # 0 sans, 1 ou 2 : image de la main levée
var _tele_t := 0.0
var _tele := 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	super._ready()
	id = "maison"
	nom = "MA MAISON"
	_rng.seed = 31


func _process(delta: float) -> void:
	# Changement d'humeur : le clignement se finit, puis la nouvelle image (même gelée : c'est un retour d'état)
	if _cligne > 0.0:
		_cligne -= delta
		if _cligne <= 0.0:
			_cligne = 0.0
			if _suivante != humeur:
				humeur = _suivante
			queue_redraw()
	if not anime:
		return
	if humeur == 0:
		# Contente : jamais de clignement (yeux déjà fermés en ^) ; coucou toutes les 8 s réelles, 2 images en 0,5 s
		_coucou_t += delta
		var c := 0
		if _coucou_t >= COUCOU_TOUS_S:
			var dans := _coucou_t - COUCOU_TOUS_S
			if dans < COUCOU_DUREE_S:
				c = 1 if dans < COUCOU_DUREE_S / 2.0 else 2
			else:
				_coucou_t = 0.0
		if c != _coucou:
			_coucou = c
			queue_redraw()
	else:
		_coucou_t = 0.0
		if _coucou != 0:
			_coucou = 0
			queue_redraw()
		_cligne_t -= delta
		if _cligne_t <= 0.0:
			_cligne = 0.12
			_cligne_t = _rng.randf_range(3.0, 5.0)
			queue_redraw()
	if "tele" in traces:
		# Lueur de télévision : 3 intensités qui alternent (images, pas de fondu continu)
		_tele_t += delta
		if _tele_t >= 0.22:
			_tele_t = 0.0
			_tele = (_tele + 1 + _rng.randi_range(0, 1)) % 3
			if float(rue.get("melange")) > 0.0:
				queue_redraw()


## Clignement immédiat (compatibilité).
func cligner() -> void:
	_cligne = CLIGNE_CHANGEMENT_S
	queue_redraw()


## Nouvelle humeur : clignement, puis la nouvelle image ; rien si l'humeur ne change pas.
func changer_humeur(h: int) -> void:
	h = clampi(h, 0, 2)
	if h == _suivante:
		return
	_suivante = h
	_cligne = CLIGNE_CHANGEMENT_S
	queue_redraw()


## Humeur visée (affichée après le clignement en cours).
func humeur_visee() -> int:
	return _suivante


## Image de Sylvie dessinée en ce moment (contrôles des captures).
func image_sylvie() -> String:
	if humeur == 0 and _coucou > 0:
		return "ville/sylvie_contente_coucou_%d" % _coucou
	return "ville/" + HUMEURS[clampi(humeur, 0, 2)]


## Rebord de la fenêtre de Gérard (milieu de l'appui), coordonnées locales.
func point_rebord() -> Vector2:
	return Vector2(coin_image() + Vector2i(FENETRE_GERARD.get_center().x, FENETRE_GERARD.end.y))


func point_fenetre() -> Vector2:
	return Vector2(coin_image() + FENETRE_GERARD.get_center())


## Porte d'entrée (arrivée des pièces d'or, départ des pièces de cuivre), rectangle local.
func porte() -> Rect2:
	return Rect2(Vector2(coin_image() + F.PORTE.position), Vector2(F.PORTE.size))


func point_boite() -> Vector2:
	return Vector2(coin_image() + BOITE.get_center())


func point_sylvie() -> Vector2:
	var fs: Rect2i = F.FENETRE_SYLVIE
	return Vector2(coin_image() + Vector2i(fs.position.x + fs.size.x / 2, fs.position.y))


## Fenêtre de Sylvie, rectangle local (ville.point_sylvie).
func fenetre_sylvie() -> Rect2:
	var fs: Rect2i = F.FENETRE_SYLVIE
	return Rect2(Vector2(coin_image() + fs.position), Vector2(fs.size))


func _dessiner_dessus(d: Vector2i) -> void:
	var c := coin_image() + d
	var fs: Rect2i = F.FENETRE_SYLVIE
	var ps := c + Vector2i(fs.position.x + fs.size.x / 2, fs.end.y - 1)
	rue.image(self, image_sylvie(), ps)
	if _cligne > 0.0:
		rue.image(self, "ville/sylvie_cligne", ps)     # aussi depuis « contente » quand l'humeur change
	match humeur:
		0:
			rue.image(self, "ville/geraniums", c + POS_GERANIUMS)
		2:
			rue.image(self, "ville/rideau_tire", c + POS_RIDEAU)
	_dessiner_traces(c)
	_dessiner_porte(c)
	if flash > 0.0:
		var fg := Rect2i(c + FENETRE_GERARD.position + Vector2i(3, 4), FENETRE_GERARD.size - Vector2i(5, 4))
		rue.emissif(self, fg, "lumiere", flash)
	if drapeau > 0.0:
		var b := c + BOITE.position
		var h := roundi(drapeau * 4.0)
		rue.rect(self, Rect2i(b.x + 2, b.y + 5 - h, 9, 2), "or")
		rue.rect(self, Rect2i(b.x + 2, b.y + 4 - h, 9, 1), "lumiere")
		if drapeau > 0.5:
			rue.rect(self, Rect2i(b.x + 3, b.y + 7 - h, 7, 3), "creme")


func _dessiner_traces(c: Vector2i) -> void:
	if traces.is_empty():
		return
	if "tele" in traces:
		var m := float(rue.get("melange"))
		if m > 0.0:
			var r := Rect2i(c + FENETRE_TELE.position + Vector2i(4, 4), FENETRE_TELE.size - Vector2i(8, 6))
			# Couleurs de jour, non assombries : la lueur éclaire (3 tons de bleu qui alternent)
			draw_rect(Rect2(r), PalettePixel.couleur_alpha(["ciel", "ciel_vif", "bleu_vif"][_tele], m * 0.95))
			draw_rect(Rect2(r.position + Vector2i(0, r.size.y - 5), Vector2i(r.size.x, 5)), PalettePixel.couleur_alpha("ciel_clair", m * 0.9))
	if "antenne" in traces:
		rue.image(self, "objet/antenne", c + POS_ANTENNE)
	if "diplome" in traces:
		rue.image(self, "objet/diplome", c + POS_DIPLOME)
	if "escargot" in traces:
		rue.image(self, "objet/escargot", c + POS_ESCARGOT)


## Porte en 3 images : entrebâillée, à moitié, grande ouverte (vantail en fuite à droite, entrée sombre).
func _dessiner_porte(c: Vector2i) -> void:
	if porte_ouverte <= 0:
		return
	var p := Rect2i(c + F.PORTE.position, F.PORTE.size)
	var ouvert: int = [0, 6, 15, 26][porte_ouverte]
	rue.rect(self, Rect2i(p.position, Vector2i(ouvert, p.size.y)), "nuit")
	rue.rect(self, Rect2i(p.position + Vector2i(0, p.size.y - 3), Vector2i(ouvert, 3)), "bois_sombre")
	rue.lumiere_nuit(self, Rect2i(p.position + Vector2i(1, 2), Vector2i(maxi(0, ouvert - 2), p.size.y - 5)), 0.8)
	var vantail := p.size.x - ouvert
	rue.rect(self, Rect2i(p.position + Vector2i(ouvert, 0), Vector2i(vantail, p.size.y)), "sarcelle")
	rue.rect(self, Rect2i(p.position + Vector2i(ouvert, 0), Vector2i(1, p.size.y)), "ombre_froide")
	rue.rect(self, Rect2i(p.position + Vector2i(p.size.x - 2, 0), Vector2i(2, p.size.y)), "bleu_ardoise")
	if vantail > 6:
		rue.rect(self, Rect2i(p.position + Vector2i(ouvert + 2, p.size.y / 2), Vector2i(2, 2)), "or")
