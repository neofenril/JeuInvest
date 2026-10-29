class_name Courbe
extends Control
## Courbe vivante du patrimoine (09 §3, effet 9) : aire en dégradé, trait en 3 passes, tête qui pulse,
## 4 graduations rondes, axe à partir de 0 (04 §7.6).
## Courbe de référence « tout au Livret A » (témoin Tata Livret, 03 §7.8) : trait bleu ; l'écart entre
## les deux courbes est teinté (vert devant, rouge derrière) et chiffré à côté de la tête.
## Le dernier segment se trace progressivement ; l'axe se recadre en douceur.

const COULEUR_REF := Color("4ea8de")

var valeurs: Array = []        # patrimoine, un point par mois
var mis: Array = []            # argent mis de côté (gardé pour mémoire, plus tracé)
var ref: Array = []            # référence « tout au Livret A »
var ab_dernier := 0            # mois absolu du dernier point (devise de l'écart)
var ab_premier := 0            # mois absolu du premier point
var progression := 1.0         # tracé du dernier segment (0 → 1)
var couleur := Style.ACCENT
var tete_gain := true
var compacte := false
var total_mois := 12            # nombre de mois de la tranche (largeur de l'axe)
## Écart affiché au bout de la courbe : exactement la valeur de la pastille « VS TOUT AU LIVRET A »
## (EtatPartie.ecart_livret, courriers en attente compris). NAN : calculé à partir des deux courbes.
var ecart_impose := NAN
var _max_affiche := 1.0
var _t := 0.0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 200)


func regler(v: Array, m: Array, ab0: int, anime_s: float, reference: Array = []) -> void:
	var avant := valeurs.size()
	valeurs = v
	mis = m
	ref = reference
	ab_premier = ab0
	ab_dernier = ab0 + maxi(0, v.size() - 1)
	if v.size() >= 2:
		tete_gain = float(v[v.size() - 1]) >= float(v[v.size() - 2])
	var haut := 1.0
	for x in v:
		haut = maxf(haut, float(x))
	for x in reference:
		haut = maxf(haut, float(x))
	var cible := _arrondi_haut(haut * 1.08)
	if anime_s > 0.0 and v.size() > avant and not Juice.animations_reduites:
		progression = 0.0
		var t := create_tween().set_parallel(true)
		t.tween_property(self, "progression", 1.0, anime_s).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		t.tween_property(self, "_max_affiche", cible, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	else:
		progression = 1.0
		_max_affiche = cible


## Arrondi « rond » vers le haut (1, 2, 2,5, 5 × 10^n), en francs pour les graduations.
static func _arrondi_haut(eur: float) -> float:
	var f := maxf(1.0, eur * Format.TAUX_EURO)
	var p := pow(10.0, floor(log(f) / log(10.0)))
	for k in [1.0, 2.0, 2.5, 4.0, 5.0, 8.0, 10.0]:
		if k * p >= f:
			return k * p / Format.TAUX_EURO
	return 10.0 * p / Format.TAUX_EURO


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var gauche := 8.0
	var haut := 34.0
	var zone := Rect2(gauche, haut, size.x - gauche - 16.0, size.y - haut - 26.0)
	var police := Style.chiffres()
	# Graduations (téléphone : la zone est basse, 2 intervalles et seule la valeur du haut est écrite,
	# au-dessus de la ligne, là où la courbe ne passe pas)
	var n_grad := 2 if compacte else 4
	for i in n_grad + 1:
		var v := _max_affiche * i / float(n_grad)
		var y := zone.end.y - zone.size.y * i / float(n_grad)
		draw_line(Vector2(zone.position.x, y), Vector2(zone.end.x, y), Color(1, 1, 1, 0.06 if i > 0 else 0.15), 1.0)
		if i > 0 and (not compacte or i == n_grad):
			draw_string(police, Vector2(zone.position.x + 4, y - 6), Format.montant(v, ab_premier), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(Style.TEXTE_2, 0.8))
	var n := valeurs.size()
	if n < 2:
		return
	var total := maxi(n - 1, total_mois)
	var pts := PackedVector2Array()
	var pts_ref := PackedVector2Array()
	for i in n:
		var x := zone.position.x + zone.size.x * i / float(total)
		pts.append(Vector2(x, zone.end.y - zone.size.y * clampf(float(valeurs[i]) / _max_affiche, 0.0, 1.05)))
		if i < ref.size():
			pts_ref.append(Vector2(x, zone.end.y - zone.size.y * clampf(float(ref[i]) / _max_affiche, 0.0, 1.05)))
	pts[n - 1] = pts[n - 2].lerp(pts[n - 1], progression)
	var avec_ref := pts_ref.size() == n
	if avec_ref:
		pts_ref[n - 1] = pts_ref[n - 2].lerp(pts_ref[n - 1], progression)
	# Aire sous la courbe (couleurs par sommet : accent en haut, transparent en bas)
	var aire := PackedVector2Array(pts)
	var couleurs := PackedColorArray()
	for p in pts:
		couleurs.append(Color(couleur, 0.22 if avec_ref else 0.30))
	aire.append(Vector2(pts[n - 1].x, zone.end.y))
	aire.append(Vector2(pts[0].x, zone.end.y))
	couleurs.append(Color(couleur, 0.0))
	couleurs.append(Color(couleur, 0.0))
	draw_polygon(aire, couleurs)
	# Écart avec « tout au Livret A » : bande verte (devant) ou rouge (derrière), puis le trait bleu
	if avec_ref:
		for i in n - 1:
			_bande(pts[i], pts[i + 1], pts_ref[i], pts_ref[i + 1])
		draw_polyline(pts_ref, Color(COULEUR_REF, 0.25), 7.0, true)
		draw_polyline(pts_ref, COULEUR_REF, 2.5, true)
	# Trait en 3 passes
	draw_polyline(pts, Color(couleur, 0.12), 14.0, true)
	draw_polyline(pts, Color(couleur, 0.25), 7.0, true)
	draw_polyline(pts, couleur, 3.0, true)
	if avec_ref:
		_ecart_tete(pts[n - 1], pts_ref[n - 1], zone, police)
	# Tête qui pulse
	var tete := pts[n - 1]
	var c_tete := Style.GAIN if tete_gain else Style.PERTE
	var pulse := 0.5 + 0.5 * sin(_t * TAU / 1.2)
	draw_circle(tete, 14.0 + 4.0 * pulse, Color(c_tete, 0.18))
	draw_circle(tete, 9.0, Color(c_tete, 0.45))
	draw_circle(tete, 5.0, Color.WHITE)
	# Années sous l'axe
	for i in n:
		var a := ab_premier + i
		if Dates.mois(a) == 1:
			var x := zone.position.x + zone.size.x * i / float(total)
			draw_string(police, Vector2(x - 20, size.y - 2), str(Dates.annee(a)), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(Style.TEXTE_2, 0.8))


## Bande entre la courbe du joueur (a0 → a1) et la référence (r0 → r1) sur un mois ; coupée en deux
## si les courbes se croisent. En y écran, « au-dessus » = valeur plus grande.
func _bande(a0: Vector2, a1: Vector2, r0: Vector2, r1: Vector2) -> void:
	var d0 := r0.y - a0.y
	var d1 := r1.y - a1.y
	if absf(d0) < 0.01 and absf(d1) < 0.01:
		return
	if d0 * d1 < 0.0:
		var k := d0 / (d0 - d1)
		var x := a0.lerp(a1, k)
		_poly_ecart(PackedVector2Array([a0, x, r0]), d0)
		_poly_ecart(PackedVector2Array([x, a1, r1]), d1)
	elif absf(d0) < 0.01:
		_poly_ecart(PackedVector2Array([a0, a1, r1]), d1)
	elif absf(d1) < 0.01:
		_poly_ecart(PackedVector2Array([a0, a1, r0]), d0)
	else:
		_poly_ecart(PackedVector2Array([a0, a1, r1, r0]), d0 if absf(d0) > absf(d1) else d1)


func _poly_ecart(poly: PackedVector2Array, signe: float) -> void:
	# Aire (formule du lacet) : un polygone aplati ferait échouer la triangulation
	var aire := 0.0
	for i in poly.size():
		aire += poly[i].cross(poly[(i + 1) % poly.size()])
	if absf(aire) < 1.0:
		return
	draw_colored_polygon(poly, Color(Style.GAIN if signe > 0.0 else Style.PERTE, 0.30))


## Écart chiffré à côté de la tête : petit trait vertical entre les deux courbes et montant signé.
func _ecart_tete(tete: Vector2, tete_ref: Vector2, zone: Rect2, police: Font) -> void:
	if valeurs.size() != ref.size():
		return
	var ecart := float(valeurs[valeurs.size() - 1]) - float(ref[ref.size() - 1]) if is_nan(ecart_impose) else ecart_impose
	var c := Style.GAIN if ecart > 0.0 else (Style.PERTE if ecart < 0.0 else Style.TEXTE_2)
	draw_line(tete, tete_ref, Color(c, 0.9), 2.0, true)
	var txt := Format.ecart(ecart, ab_dernier)
	var taille := 18 if compacte else 20
	var largeur := police.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
	var y := clampf((tete.y + tete_ref.y) / 2.0 + 7.0, zone.position.y + 14.0, zone.end.y - 4.0)
	var x := tete.x + 16.0
	if x + largeur > zone.end.x + 12.0:
		x = tete.x - 16.0 - largeur
	draw_string_outline(police, Vector2(x, y), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, taille, 6, Color(Style.PANNEAU_OPAQUE, 0.9))
	draw_string(police, Vector2(x, y), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, taille, c)
