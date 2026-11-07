class_name CarteProduit
extends Control
## Une carte du carnet du banquier (13 §2.2), dessinée en code : détenue (couleur pleine, valeur),
## présentée (couleur atténuée, date), nouvelle (badge « NOUVEAU » et reflet), à découvrir (silhouette en
## pointillés, « ? » et un indice de besoin, jamais une date).

signal touchee(pid: String)

var pid := ""
var nom := ""
var couleur := Style.ACCENT
var etat := "silhouette"
var ligne1 := ""
var ligne2 := ""
var indice := ""
var cadenas := false
var calendrier := false   # versement automatique actif (11 §8, VP11)
var choisie := false
var compacte := false
var remplissage := 1.0   # déblocage animé : la couleur monte de bas en haut
var taille_min_dessinee := 999   # plus petite taille de police du dernier dessin (contrôle « UI tuiles », m10)
var _t := 0.0

const TAILLE_MIN := 20
## Noms abrégés quand la tuile est trop étroite pour le nom en 20 px (téléphone).
const ABREGES := {"ASSURANCE-VIE": "ASS.-VIE", "SAINT-GOBAIN": "ST-GOBAIN"}


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_mode = Control.FOCUS_NONE


func _ready() -> void:
	custom_minimum_size = Vector2(140, 116) if compacte else Vector2(170, 128)
	set_meta("cible", true)   # cible tactile (contrôle « UI cibles »)


func _gui_input(event: InputEvent) -> void:
	var b := event as InputEventMouseButton
	if b != null and b.pressed and b.button_index == MOUSE_BUTTON_LEFT:
		touchee.emit(pid)
		accept_event()


func _process(delta: float) -> void:
	if etat == "nouveau":
		_t += delta
		queue_redraw()


func _regler_remplissage(u: float) -> void:
	remplissage = u
	queue_redraw()


## Déblocage animé (13 §2.3) : la carte se retourne, la couleur la remplit, le badge apparaît.
func reveler(delai := 0.0) -> void:
	if Juice.animations_reduites:
		return
	pivot_offset = size / 2.0
	remplissage = 0.0
	var t := create_tween()
	t.tween_interval(delai)
	t.tween_property(self, "scale:x", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
	t.tween_property(self, "scale:x", 1.0, 0.15).set_trans(Tween.TRANS_SINE)
	t.tween_method(_regler_remplissage, 0.0, 1.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_callback(Juice.pop.bind(self))


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var ui := Style.ui()
	var gras := Style.ui_gras()
	var fs := TAILLE_MIN   # m10 (recette PX2) : aucun texte de tuile sous 20 px ; on raccourcit plutôt
	taille_min_dessinee = 999
	if etat == "silhouette":
		draw_rect(r, Style.SILHOUETTE)
		_pointilles(r.grow(-2), Style.FILET)
		# Indice en bas (jusqu'à 3 lignes de 20 px), le « ? » centré dans la place restante au-dessus
		var lignes_indice := _lignes(ui, indice, r.size.x - 12.0, fs, 3)
		var y0 := r.size.y - 12.0 - 22.0 * (lignes_indice.size() - 1)
		Dessin.texte(self, Style.neon(), Vector2(r.size.x / 2.0, (y0 - 20.0) / 2.0 + 2.0), "?", 38 if compacte else 44, Color(Style.TEXTE_2, 0.7))
		for i in lignes_indice.size():
			_ecrire(ui, Vector2(6, y0 + i * 22.0), lignes_indice[i], fs, Style.TEXTE_2, r.size.x - 12.0, HORIZONTAL_ALIGNMENT_CENTER)
	else:
		var plein := etat == "detenu"
		draw_rect(r, Style.ENCRE)
		draw_rect(r.grow(-3), Style.PANNEAU_ELEVE)
		var fond := Color(couleur, 0.32 if plein else 0.16)
		var h := r.size.y * remplissage
		if h > 6.0:
			draw_rect(Rect2(3, roundf((r.size.y - h) / 3.0) * 3.0, r.size.x - 6, h - 3), fond)
		draw_rect(Rect2(3, 3, 6, r.size.y - 6), Color(couleur, 1.0 if plein else 0.55))
		# Cadenas et calendrier en colonne dans le coin haut droit, jamais sur un chiffre (m2) : le nom leur laisse la place
		# Calendrier dans le coin haut droit (le nom lui laisse la place, quitte à rapetisser), cadenas en bas à
		# droite (la 2e ligne lui laisse la place) : jamais sur un chiffre ni coupé (m2)
		var icones := 30.0 if calendrier and etat != "nouveau" else 0.0
		var place := r.size.x - 22.0 - icones
		var lignes_nom := _lignes(gras, nom.to_upper(), place, fs, 2)
		if "…" in "".join(lignes_nom) and ABREGES.has(nom.to_upper()):
			lignes_nom = _lignes(gras, ABREGES[nom.to_upper()], place, fs, 2)   # « ASS.-VIE » comme la légende de « Mon argent »
		for i in lignes_nom.size():
			_ecrire(gras, Vector2(16, 26 + i * 24.0), lignes_nom[i], fs, Style.TEXTE, place)
		var y2 := r.size.y - 38.0
		if plein:
			_ecrire(Style.chiffres(), Vector2(16, y2), ligne1, 22 if compacte else 24, Style.TEXTE, r.size.x - 22.0)
			var place2 := r.size.x - 22.0 - (26.0 if cadenas else 0.0)
			_ecrire(ui, Vector2(16, y2 + 24), raccourcir(ui, ligne2, place2, fs), fs, Style.TEXTE_2, place2)
		elif etat != "nouveau":
			_ecrire(ui, Vector2(16, y2 + 2), raccourcir(ui, ligne1, r.size.x - 22.0, fs), fs, Style.TEXTE_2, r.size.x - 22.0)
			_ecrire(ui, Vector2(16, y2 + 24), raccourcir(ui, ligne2, r.size.x - 22.0, fs), fs, Style.TEXTE_2, r.size.x - 22.0)
		if cadenas:
			_cadenas(Vector2(r.size.x - 18, r.size.y - 22))
		if calendrier and etat != "nouveau":
			_calendrier(Vector2(r.size.x - 21, 21))
		if etat == "nouveau":
			_badge(Vector2(14, r.size.y - 36))
			# Reflet qui passe toutes les 4 s
			var k := fmod(_t, 4.0) / 0.6
			if k < 1.0:
				var x := -40.0 + (r.size.x + 80.0) * k
				draw_colored_polygon(PackedVector2Array([Vector2(x, 0), Vector2(x + 26, 0), Vector2(x - 14, r.size.y), Vector2(x - 40, r.size.y)]), Color(Style.TEXTE, 0.10))
	if choisie:
		var s := StyleBoxFlat.new()
		s.draw_center = false
		s.set_border_width_all(6)
		s.border_color = Style.TEXTE
		draw_style_box(s, r)


func _pointilles(r: Rect2, c: Color) -> void:
	var coins := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
	for i in 4:
		draw_dashed_line(coins[i], coins[(i + 1) % 4], c, 2.0, 8.0)


## Badge « NOUVEAU » et son étoile, coin haut gauche en « coin ».
func _badge(coin: Vector2) -> void:
	var txt := "NOUVEAU"
	var police := Style.petites_capitales()
	var l := police.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, TAILLE_MIN).x
	var place := size.x - coin.x - 6.0
	var etoile := l + 34.0 <= place   # tuile étroite (téléphone) : le mot entier, sans l'étoile
	var b := Rect2(coin.x if etoile else maxf(6.0, coin.x - 8.0), coin.y - 6.0, l + (34.0 if etoile else 12.0), 30)
	draw_rect(b, Style.ALERTE)
	_ecrire(police, Vector2(b.position.x + 6, b.position.y + 22), txt, TAILLE_MIN, Style.ENCRE_ACCENT)
	if not etoile:
		return
	var c := Vector2(b.end.x - 13, b.get_center().y)
	var pts := PackedVector2Array()
	for i in 8:
		pts.append(c + Vector2.from_angle(-PI / 2.0 + i * TAU / 8.0) * (7.0 if i % 2 == 0 else 2.5))
	draw_colored_polygon(pts, Style.ENCRE_ACCENT)


## Petit calendrier (versement automatique chaque mois) : page, reliure et une case cochée.
func _calendrier(c: Vector2) -> void:
	# Icône pixel 12 × 12 (data/pixel/ui/icones.txt), ×2
	var t := CadresPixel.texture("calendrier", 2)
	draw_texture(t, (c - t.get_size() / 2.0).round())


func _cadenas(c: Vector2) -> void:
	draw_arc(c + Vector2(0, -4), 6.0, PI, TAU, 12, Style.TEXTE_2, 2.5, true)
	Dessin.arrondi(self, Rect2(c.x - 9, c.y - 4, 18, 14), Style.TEXTE_2, 3)


## Écrit une ligne (taille ≥ TAILLE_MIN) et retient la plus petite taille dessinée (contrôle « UI tuiles »).
func _ecrire(police: Font, pos: Vector2, texte: String, taille: int, couleur: Color, largeur := -1.0, alignement := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	if texte == "":
		return
	taille_min_dessinee = mini(taille_min_dessinee, taille)
	draw_string(police, pos, texte, alignement, largeur, taille, couleur)


## m10 : un texte trop long pour la tuile est raccourci, jamais rapetissé sous 20 px : « 4,5 % cette année »
## devient « 4,5 %/an », « 11 % fixe » « 11 %/an », « ≈ 8,25 % fixe » « ≈ 8,25 % » ; en dernier recours, « … ».
static func raccourcir(police: Font, texte: String, largeur: float, taille: int) -> String:
	var t := texte
	if police.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x <= largeur:
		return t
	if t.contains(" cette année"):
		t = t.replace(" cette année", "/an")
	elif t.contains(" fixe"):
		t = t.replace(" fixe", "" if t.begins_with("≈") else "/an")
	if t.ends_with("/an") and police.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > largeur:
		t = t.trim_suffix("/an")   # « 11,5 % » : le taux seul, la fiche dit le reste
	while t.length() > 1 and police.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x > largeur:
		t = t.left(t.length() - (2 if t.ends_with("…") else 1)).strip_edges() + "…"
	return t


## Lignes d'un texte coupé aux espaces et après les traits d'union, au plus n lignes (la dernière raccourcie).
func _lignes(police: Font, texte: String, largeur: float, taille: int, n: int) -> PackedStringArray:
	var morceaux := PackedStringArray()
	for mot in texte.split(" ", false):
		var parties := mot.split("-")
		for i in parties.size():
			morceaux.append(parties[i] + ("-" if i < parties.size() - 1 else ""))
	var lignes := PackedStringArray()
	var courante := ""
	for m: String in morceaux:
		var essai := m if courante == "" else (courante + m if courante.ends_with("-") else courante + " " + m)
		if courante == "" or police.get_string_size(essai, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x <= largeur:
			courante = essai
		else:
			lignes.append(courante)
			courante = m
	if courante != "":
		lignes.append(courante)
	if lignes.size() > n:
		var reste := " ".join(lignes.slice(n - 1))
		lignes = lignes.slice(0, n - 1)
		lignes.append(reste)
	for i in lignes.size():
		lignes[i] = raccourcir(police, lignes[i], largeur, taille)
	return lignes
