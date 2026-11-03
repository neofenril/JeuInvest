extends Batiment
## La Gazette (docs/16 §8.4, 225 × 318) : journal lumineux du toit (ambre ; rouge et grésillement au krach) :
## nom et valeur de l'indice, courbe des 30 derniers mois (jamais le futur), bandeau défilant, en lettres
## pixel 3 × 5 ; néon rose sous l'enseigne peinte ; enseigne du titre lettre à lettre sur l'écran titre.
## Propriétés écrites par Sequences (maj_media) et principal.gd (titre, titre_lettres).

const E := preload("res://scripts/pixel/edifices.gd")
const MOT_TITRE := "JEUCLAUDE"

var points_indice: PackedFloat64Array = []:
	set(v):
		points_indice = v
		_sale = true
var nom_ecran := "INDICE":
	set(v):
		nom_ecran = v
		_sale = true
var valeur_ecran := "":
	set(v):
		valeur_ecran = v
		_sale = true
var trace := 1.0:
	set(v):
		trace = v
		_sale = true
var trace_rouge := false:
	set(v):
		trace_rouge = v
		_sale = true
var ticker := "LA GAZETTE · TOUTE L'ACTUALITÉ DE LA BOURSE · ":
	set(v):
		ticker = v
		_ticker_sale = true
var ticker_rouge := false
var flash_ticker := false
var gresillement := 0.0
var titre := 0.0
var titre_lettres := 9.0
var anime := true
var _sale := true
var _ticker_sale := true
var _tex_ecran: ImageTexture
var _tex_ticker: ImageTexture
var _defil := 0.0
var _t := 0.0
var _eteint := false
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	super._ready()
	id = "media"
	nom = "LA GAZETTE"
	_rng.seed = 1987
	# Zone de toucher : la façade et l'enseigne du titre au-dessus
	zone = Rect2(zone.position.x, zone.position.y - 36, zone.size.x, zone.size.y + 36)


func _process(delta: float) -> void:
	_t += delta
	if anime:
		_defil += delta * 30.0
	gresillement = maxf(0.0, gresillement - delta * 0.5)
	_eteint = gresillement > 0.0 and _rng.randf() < gresillement * 0.35
	queue_redraw()


## Ondes depuis le toit (blanches pour une news, rouges pour un krach).
func ondes(couleur: Color, nombre := 3) -> void:
	var nom_c := "perte" if couleur.r > 0.8 and couleur.g < 0.6 else "blanc_chaud"
	for i in nombre:
		get_tree().create_timer(0.18 * i).timeout.connect(_onde.bind(nom_c))


func _onde(c: String) -> void:
	if rue == null:
		return
	var o: Node2D = rue.ajouter(["objet/onde_%s_0" % c, "objet/onde_%s_1" % c, "objet/onde_%s_2" % c], position + position_antenne(), 9.0)
	o.set("une_fois", true)


## Haut du journal lumineux (coordonnées locales).
func position_antenne() -> Vector2:
	return Vector2(coin_image() + Vector2i(E.GAZETTE.x / 2, -2))


func _couleur() -> String:
	return "perte" if trace_rouge or ticker_rouge else "ambre"


func _construire_ecran() -> void:
	_sale = false
	var r: Rect2i = E.ECRAN
	var img := MatieresPixel.vide(r.size.x, r.size.y)
	var c := _couleur()
	var nom_t := MatieresPixel.normaliser(nom_ecran)
	MatieresPixel.texte(img, 3, 2, nom_t, c)
	var val := MatieresPixel.normaliser(valeur_ecran).replace(" ", "")
	MatieresPixel.texte(img, r.size.x - 3 - MatieresPixel.largeur_texte(val), 2, val, c)
	var n := points_indice.size()
	if n >= 2:
		var mini := points_indice[0]
		var maxi := points_indice[0]
		for v in points_indice:
			mini = minf(mini, v)
			maxi = maxf(maxi, v)
		var marge := (maxi - mini) * 0.08 + 0.001
		mini -= marge
		maxi += marge
		var zone_c := Rect2i(4, 10, r.size.x - 8, 15)
		var pts: Array = []
		for i in n:
			var px := zone_c.position.x + int(round(zone_c.size.x * i / float(n - 1)))
			var py := zone_c.end.y - 1 - int(round((zone_c.size.y - 1) * (points_indice[i] - mini) / (maxi - mini)))
			pts.append(Vector2i(px, py))
		var dernier: Vector2i = pts[n - 2]
		pts[n - 1] = Vector2i(Vector2(dernier).lerp(Vector2(pts[n - 1]), clampf(trace, 0.0, 1.0)).round())
		for i in n - 1:
			_ligne(img, pts[i], pts[i + 1], c if (i < n - 2 or not trace_rouge) else "perte")
		var tete: Vector2i = pts[n - 1]
		MatieresPixel.rect(img, tete.x - 1, tete.y - 1, 3, 3, "perte" if trace_rouge else "lumiere")
	_tex_ecran = ImageTexture.create_from_image(img)


static func _ligne(img: Image, a: Vector2i, b: Vector2i, c: String) -> void:
	var d := b - a
	var pas := maxi(absi(d.x), absi(d.y))
	for k in pas + 1:
		var p := Vector2(a).lerp(Vector2(b), k / float(maxi(1, pas))).round()
		MatieresPixel.px(img, int(p.x), int(p.y), c)


func _construire_ticker() -> void:
	_ticker_sale = false
	var t := MatieresPixel.normaliser(ticker)
	var img := MatieresPixel.vide(maxi(4, MatieresPixel.largeur_texte(t) + 4), 5)
	MatieresPixel.texte(img, 0, 0, t, "ambre")
	var rouge := MatieresPixel.vide(img.get_width(), 5)
	MatieresPixel.texte(rouge, 0, 0, t, "perte")
	_tex_ticker = ImageTexture.create_from_image(img)
	set_meta("ticker_rouge", ImageTexture.create_from_image(rouge))


func _dessiner_dessus(d: Vector2i) -> void:
	var c := coin_image() + d
	var r: Rect2i = E.ECRAN
	var o := c + r.position
	# Néon rose (il grésille au krach)
	if not _eteint:
		rue.image(self, "edifice/neon_gazette", c + E.NEON)
	# Journal lumineux
	if _sale:
		_construire_ecran()
	if _ticker_sale:
		_construire_ticker()
	if not _eteint:
		draw_texture(_tex_ecran, Vector2(o))
		var y_t := o.y + 28
		if flash_ticker:
			if fmod(_t * 4.0, 1.0) < 0.6:
				var f := "*** FLASH ***"
				var img_f := MatieresPixel.largeur_texte(f)
				_texte_direct(f, Vector2i(o.x + (r.size.x - img_f) / 2, y_t), "perte")
		else:
			var tex: ImageTexture = get_meta("ticker_rouge") if ticker_rouge else _tex_ticker
			var total := tex.get_width() + r.size.x
			var x0 := r.size.x - 4 - (int(_defil) % total)
			var gauche := maxi(0, -x0 + 3)
			var droite := mini(tex.get_width(), r.size.x - 3 - x0)
			if droite > gauche:
				draw_texture_rect_region(tex, Rect2(o.x + x0 + gauche, y_t, droite - gauche, 5), Rect2(gauche, 0, droite - gauche, 5))
	# Enseigne du titre (écran titre) : lettres qui s'allument une à une
	if titre > 0.01:
		var ct := c + Vector2i((E.GAZETTE.x - 125) / 2, -36)
		rue.image(self, "edifice/cadre_titre", ct, minf(1.0, titre * 2.0))
		var n := clampi(int(titre_lettres), 0, MOT_TITRE.length())
		var x := ct.x + (125 - MatieresPixel.largeur_texte(MOT_TITRE, 3)) / 2
		for i in MOT_TITRE.length():
			var col := ("ambre" if i < 3 else "neon_rose") if i < n else "ardoise"
			_texte_direct(MOT_TITRE[i], Vector2i(x, ct.y + 5), col, 3, titre if i < n else titre * 0.6)
			x += 12


## Texte pixel dessiné directement (rectangles), couleur de la palette (émissive ou variante du moment).
func _texte_direct(t: String, pos: Vector2i, couleur: String, echelle := 1, alpha := 1.0) -> void:
	var cx := pos.x
	for ch in t:
		var g: Array = MatieresPixel.GLYPHES.get(ch, [])
		for j in g.size():
			for i in 3:
				if String(g[j])[i] == "1":
					var rr := Rect2i(cx + i * echelle, pos.y + j * echelle, echelle, echelle)
					if PalettePixel.emissive(couleur):
						rue.emissif(self, rr, couleur, alpha)
					else:
						rue.rect(self, rr, couleur, alpha)
		cx += 4 * echelle
