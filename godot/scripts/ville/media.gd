extends Batiment
## Le média « La Gazette » (09 §2.3) : tour bleu nuit, enseigne néon, écran lumineux sur le toit
## (courbe de l'indice), bandeau LED qui défile, antenne qui clignote et émet des ondes.
## Pendant l'écran titre, une grande enseigne « JEUCLAUDE » s'allume au-dessus du toit.

const FACADE := Color("3b4a63")
const NEON := Color("ff6fa8")
const AMBRE := Color("ffb547")
const ECRAN := Color("0e1a12")
const LUMIERE := Color("ffd27a")

var points_indice: PackedFloat64Array = []
var nom_ecran := "INDICE"
var valeur_ecran := ""
var trace := 1.0                  # progression du dernier segment (0 → 1)
var trace_rouge := false
var ticker := "LA GAZETTE · TOUTE L'ACTUALITÉ DE LA BOURSE · "
var ticker_rouge := false
var flash_ticker := false
var gresillement := 0.0
var titre := 0.0                  # intensité de l'enseigne JEUCLAUDE
var titre_lettres := 9.0
var _defil := 0.0
var _t := 0.0
var _ondes: Array = []            # { age, couleur }
var _seuils: Array = []
var _titre_dessine := 0.0

const ANTENNE := Vector2(112, -606)
const ECRAN_RECT := Rect2(-118, -528, 236, 108)
const COURBE_RECT := Rect2(-108, -500, 216, 72)
const TICKER_RECT := Rect2(-136, -148, 272, 30)


func _ready() -> void:
	super._ready()
	id = "media"
	nom = "LA GAZETTE"
	zone = Rect2(-170, -620, 340, 630)
	contour = PackedVector2Array([Vector2(-150, 0), Vector2(-150, -408), Vector2(-128, -408), Vector2(-128, -536),
		Vector2(128, -536), Vector2(128, -408), Vector2(150, -408), Vector2(150, 0)])
	var rng := Hasard.new(1987)
	for i in 16:
		_seuils.append(0.1 + 0.6 * rng.u())


func _process(delta: float) -> void:
	_t += delta
	_defil += delta * 70.0
	for o in _ondes:
		o["age"] += delta
	_ondes = _ondes.filter(func(o: Dictionary) -> bool: return o["age"] < 0.9)
	gresillement = maxf(0.0, gresillement - delta * 0.5)
	if absf(titre - _titre_dessine) > 0.02 or (titre == 0.0 and _titre_dessine != 0.0):
		_titre_dessine = titre
		queue_redraw()


## Émet des ondes depuis l'antenne (blanches pour une news, rouges pour un krach).
func ondes(couleur: Color, nombre := 3) -> void:
	for i in nombre:
		_ondes.append({"age": -0.18 * i, "couleur": couleur})


func position_antenne() -> Vector2:
	return ANTENNE


func _draw() -> void:
	Dessin.ombre_sol(self, -150, 160, 0, 18)
	# Corps de la tour
	Dessin.volume(self, Rect2(-150, -400, 300, 400), FACADE, 30)
	draw_rect(Rect2(-156, -410, 312, 12), FACADE.darkened(0.3))
	draw_rect(Rect2(-150, -24, 300, 24), FACADE.darkened(0.15))
	# Fenêtres (éteintes ; la lumière est dessinée à part)
	for r in 4:
		for c in 4:
			var f := Rect2(-118 + c * 62, -326 + r * 46, 44, 30)
			draw_rect(f, Color("26324a"))
			draw_rect(Rect2(f.position.x, f.end.y, f.size.x, 4), FACADE.lightened(0.15))
	# Enseigne (plaque) et bandeau LED
	Dessin.arrondi(self, Rect2(-138, -394, 276, 54), Color("232c3d"), 6)
	draw_rect(TICKER_RECT.grow(4), Color("1a1f29"))
	draw_rect(TICKER_RECT, Color("0b0b0b"))
	# Entrée : marquise et portes vitrées
	draw_rect(Rect2(-64, -114, 128, 12), Color("2a3550"))
	draw_rect(Rect2(-48, -102, 96, 102), Color("55607a"))
	draw_rect(Rect2(-42, -96, 40, 96), Color("1e2738"))
	draw_rect(Rect2(2, -96, 40, 96), Color("1e2738"))
	# Toit : pieds de l'écran, cadre, écran
	draw_rect(Rect2(-90, -420, 10, 20), Color("2a2e36"))
	draw_rect(Rect2(80, -420, 10, 20), Color("2a2e36"))
	Dessin.arrondi(self, ECRAN_RECT.grow(10), Color("22262e"), 6)
	draw_rect(ECRAN_RECT, ECRAN)
	var y := ECRAN_RECT.position.y
	while y < ECRAN_RECT.end.y:
		draw_rect(Rect2(ECRAN_RECT.position.x, y, ECRAN_RECT.size.x, 1), Color(0, 0, 0, 0.35))
		y += 3.0
	if hiver:
		draw_rect(Rect2(-156, -414, 312, 6), Color(0.97, 0.98, 1.0))
		draw_rect(Rect2(-128, -542, 256, 5), Color(0.97, 0.98, 1.0))
	# Antenne râteau
	var base := Vector2(ANTENNE.x, -400)
	draw_line(base, ANTENNE, Color("4a4f58"), 4.0, true)
	for k in 3:
		var hy := -560.0 + k * 34.0
		var lg := 32.0 - k * 7.0
		draw_line(Vector2(ANTENNE.x - lg, hy), Vector2(ANTENNE.x + lg, hy), Color("4a4f58"), 3.0, true)
	# Enseigne du titre (écran titre)
	if titre > 0.01:
		draw_rect(Rect2(-184, -604, 12, 68), Color("6a6f80"))
		draw_rect(Rect2(172, -604, 12, 68), Color("6a6f80"))
		var a := minf(1.0, titre * 2.0)
		Dessin.arrondi(self, Rect2(-338, -768, 676, 166), Color(0.62, 0.56, 0.74, a), 16)
		Dessin.arrondi(self, Rect2(-330, -760, 660, 150), Color(0.08, 0.06, 0.1, 0.95 * a), 12)
	_dessiner_contour()


func dessiner_lumieres(ci: CanvasItem) -> void:
	# Fenêtres allumées une à une
	for r in 4:
		for c in 4:
			var a := Batiment.fenetre_allumee(nuit, _seuils[r * 4 + c])
			if a > 0.01:
				var f := Rect2(-118 + c * 62, -326 + r * 46, 44, 30)
				ci.draw_rect(f, Color(LUMIERE, 0.45 * a))
	# Enseigne néon (grésille pendant un krach)
	var bruit := 0.85 + 0.15 * sin(_t * 23.0) * sin(_t * 7.0)
	if gresillement > 0.0 and fmod(_t * 13.0, 1.0) < gresillement * 0.6:
		bruit = 0.15
	Dessin.neon(ci, Style.neon(), Vector2(0, -355), "LA GAZETTE", 34, NEON, bruit * (0.75 + 0.25 * nuit))
	_ecran(ci)
	_bandeau(ci)
	# Lampe rouge de l'antenne
	var clign := 0.5 + 0.5 * sin(_t * 3.0)
	Dessin.halo(ci, ANTENNE, 22, Color(1, 0.2, 0.2, 0.6 * clign))
	ci.draw_circle(ANTENNE, 5, Color(1, 0.3, 0.3, 0.6 + 0.4 * clign))
	# Ondes
	for o in _ondes:
		var age: float = o["age"]
		if age < 0.0:
			continue
		var k := age / 0.9
		var col: Color = o["couleur"]
		ci.draw_arc(ANTENNE, 20.0 + 150.0 * k, -PI * 0.82, -PI * 0.18, 24, Color(col, (1.0 - k) * 0.9), 5.0, true)
	# Enseigne du titre : lettres qui s'allument une à une
	if titre > 0.01:
		var mot := "JEUCLAUDE"
		var n := clampi(int(titre_lettres), 0, mot.length())
		var police := Style.neon()
		var taille := 104
		var largeur := police.get_string_size(mot, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
		var x := -largeur / 2.0
		for i in mot.length():
			var lettre := mot[i]
			var lw := police.get_string_size(lettre, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
			var allume := titre if i < n else 0.08 * titre
			var col := AMBRE if i < 3 else NEON
			Dessin.neon(ci, police, Vector2(x + lw / 2.0, -644), lettre, taille, col, allume)
			x += lw + police.get_spacing(TextServer.SPACING_GLYPH)


func _ecran(ci: CanvasItem) -> void:
	var police := Style.chiffres()
	ci.draw_string(police, ECRAN_RECT.position + Vector2(8, 22), nom_ecran, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(AMBRE, 0.95))
	if valeur_ecran != "":
		var w := police.get_string_size(valeur_ecran, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		ci.draw_string(police, Vector2(ECRAN_RECT.end.x - 8 - w, ECRAN_RECT.position.y + 22), valeur_ecran, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(AMBRE, 0.95))
	var n := points_indice.size()
	if n < 2:
		return
	var mini := points_indice[0]
	var maxi := points_indice[0]
	for v in points_indice:
		mini = minf(mini, v)
		maxi = maxf(maxi, v)
	var marge := (maxi - mini) * 0.1 + 1.0
	mini -= marge
	maxi += marge
	var pts := PackedVector2Array()
	for i in n:
		var px := COURBE_RECT.position.x + COURBE_RECT.size.x * i / float(n - 1)
		var py := COURBE_RECT.end.y - COURBE_RECT.size.y * (points_indice[i] - mini) / (maxi - mini)
		pts.append(Vector2(px, py))
	# Dernier segment en cours de tracé
	pts[n - 1] = pts[n - 2].lerp(pts[n - 1], clampf(trace, 0.0, 1.0))
	var couleur := AMBRE
	ci.draw_polyline(pts, Color(couleur, 0.25), 8.0, true)
	ci.draw_polyline(pts, Color(couleur, 0.95), 3.0, true)
	var tete := pts[n - 1]
	var col_tete := Color(1.0, 0.3, 0.25) if trace_rouge else couleur
	if trace_rouge:
		ci.draw_line(pts[n - 2], tete, Color(1.0, 0.3, 0.25, 0.95), 4.0, true)
	Dessin.halo(ci, tete, 16, Color(col_tete, 0.6))
	ci.draw_circle(tete, 4, col_tete.lightened(0.3))


func _bandeau(ci: CanvasItem) -> void:
	var police := Style.led()
	var taille := 20
	var avance := police.get_string_size("M", HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
	var texte := ticker
	var col := Color(1.0, 0.25, 0.2) if ticker_rouge else AMBRE
	if flash_ticker:
		if fmod(_t * 5.0, 1.0) > 0.5:
			return
		Dessin.texte(ci, police, Vector2(0, TICKER_RECT.end.y - 8), "*** FLASH ***", taille, Color(1.0, 0.25, 0.2))
		return
	var total := texte.length() * avance
	var depart := TICKER_RECT.end.x - fmod(_defil, total + TICKER_RECT.size.x)
	for i in texte.length():
		var x := depart + i * avance
		if x < TICKER_RECT.position.x or x + avance > TICKER_RECT.end.x:
			continue
		ci.draw_string(police, Vector2(x, TICKER_RECT.end.y - 8), texte[i], HORIZONTAL_ALIGNMENT_LEFT, -1, taille, col)
