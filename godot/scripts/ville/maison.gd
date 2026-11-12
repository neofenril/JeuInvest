extends Batiment
## Maison de Gérard (PX0 quater, 228 × 258) : Sylvie à sa fenêtre (3 humeurs + clignement), fenêtre de
## Gérard qui s'allume (flash : appel, naissance), boîte aux lettres jaune qui s'ouvre (drapeau : courrier).

const F := preload("res://scripts/pixel/facades.gd")
const HUMEURS := ["sylvie_contente", "sylvie_neutre", "sylvie_contrariee"]
const FENETRE_GERARD := Rect2i(168, 99, 36, 48)       # dans l'image (coin haut gauche)
const BOITE := Rect2i(142, 198, 13, 18)

var flash := 0.0:
	set(v):
		flash = v
		queue_redraw()
var drapeau := 0.0:
	set(v):
		drapeau = v
		queue_redraw()
var humeur := 1
var anime := true
var _cligne_t := 3.0
var _cligne := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	super._ready()
	id = "maison"
	nom = "MA MAISON"
	_rng.seed = 31


func _process(delta: float) -> void:
	if not anime:
		return
	_cligne_t -= delta
	if _cligne_t <= 0.0:
		_cligne = 0.12
		_cligne_t = _rng.randf_range(3.0, 6.0)
		queue_redraw()
	elif _cligne > 0.0:
		_cligne -= delta
		if _cligne <= 0.0:
			queue_redraw()


## Clignement immédiat (changement d'humeur).
func cligner() -> void:
	_cligne = 0.15
	queue_redraw()


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
	rue.image(self, "ville/" + HUMEURS[clampi(humeur, 0, 2)], ps)
	if _cligne > 0.0:
		rue.image(self, "ville/sylvie_cligne", ps)
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
