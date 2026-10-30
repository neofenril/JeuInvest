extends RefCounted
## Façades et décor de la rue de briques, PX0 quater (grille fine 960 × 540 : tout est 1,5 × plus grand en
## pixels qu'en PX0 ter, les matières gardent la même taille de motif → plus de détails, traits plus fins).
## Générés en code dans la palette « Rue 84 ». Pas de class_name : preload("res://scripts/pixel/facades.gd").
## Chaque bâtiment est déterministe (graine) et renvoie {"image", "fenetres": [Rect2i], "auvent": Vector2i}
## (vitres allumées la nuit ; étendue de l'auvent pour son ombre au sol, posée par RuePx0).
## Relief (« mini 3D » de rue_pixel_v2) : lumière en haut à gauche, face éclairée / face à l'ombre ;
## retours de façade (pan de mur latéral en perspective légère) ; toits avec épaisseur, gouttière et
## sous-face ; corniches, bandeaux, linteaux et appuis en saillie avec ombre portée tramée ; embrasures
## (fenêtres et portes en retrait) ; marches ; auvents en volume ; cheminées avec joue à l'ombre.
## Échelle : 1 m ≈ 36 px ; étage 75, rez-de-chaussée 90, fenêtre 36 × 48, porte 33 × 66.

const M := preload("res://scripts/pixel/matieres.gd")

const H_RDC := 90
const H_ETAGE := 75
const FEN := Vector2i(36, 48)
## Portes : [corps, ombre, éclat].
const PORTES := {
	"sarcelle": ["sarcelle", "vert_sombre", "ciel"],
	"bleu": ["bleu_vif", "bleu_ardoise", "ciel"],
	"rouge": ["rouge_auvent", "brique_sombre", "tuile"],
	"bois": ["bois", "bois_sombre", "caramel"],
	"vert": ["vert", "vert_sombre", "vert_clair"],
}
## Ombre portée sur chaque matière (aplat du ton sombre de la surface touchée).
const OMBRE_SUR := {"vive": "brique", "classique": "brique_sombre", "sombre": "bois_sombre", "claire": "pierre_ombre"}
## Pan de mur latéral à l'ombre (retour droit) ou éclairé (retour gauche) : variante de brique.
const COTE_OMBRE := {"vive": "classique", "classique": "sombre", "sombre": "sombre", "claire": "claire"}


# --- Ombres tramées -----------------------------------------------------------------------------------

## Ombre portée sous une saillie : h rangées, de pleine (en haut) à légère (en bas), tramée ; seulement
## sur les pixels déjà opaques.
static func ombre_portee(img: Image, x: int, y: int, l: int, h: int, nom: String) -> void:
	for j in h:
		var dens := 1.0 - float(j) / h
		for i in l:
			var px := x + i
			var py := y + j
			if px < 0 or py < 0 or px >= img.get_width() or py >= img.get_height():
				continue
			if img.get_pixel(px, py).a > 0.0 and (j == 0 or M.trame(px, py, dens)):
				M.px(img, px, py, nom)


# --- Maison de Gérard : maison de ville en brique, 228 × 258 (cheminée comprise) ---------------------

const MAISON_L := 228
const MAISON_H := 258
const FENETRE_SYLVIE := Rect2i(21, 99, 39, 48)     # fenêtre de l'étage, à gauche
const PORTE := Rect2i(97, 180, 33, 66)             # porte (sans l'imposte, posée au-dessus)
const Y_MURS := 84                                 # bas du toit (gouttière)
const Y_BANDEAU := 160


static func maison_gerard(graine := 7) -> Dictionary:
	var img := M.vide(MAISON_L, MAISON_H)
	var fen: Array = []
	# Murs de brique vive (x 6..221, y 84..245), soubassement de pierre (y 246..257)
	M.coller(img, M.brique(216, 162, graine, "vive"), 6, Y_MURS)
	M.rect(img, 221, Y_MURS, 1, 162, "brique_sombre")
	_chaine_angle(img, 6, Y_MURS, 162, true)
	_chaine_angle(img, 212, Y_MURS, 162, false)
	usure(img, 6, 222, 88, 24, "brique", graine)
	usure(img, 136, 222, 86, 24, "brique", graine + 1)
	_soubassement(img, 3, 246, 222, 12)
	_bandeau(img, 3, Y_BANDEAU, 222, "brique")
	# Toit de tuiles en croupe avec épaisseur, gouttière et sous-face
	_toit_trapeze(img, 0, 16, MAISON_L, 64, 0.6, "tuiles", graine + 1, "brique")
	# Cheminée avec joue à l'ombre, chapeau en saillie, mitrons
	_cheminee(img, 158, 0, 20, 48, graine + 2)
	# Descente d'eau pluviale (cylindre : arête claire, corps, ombre), colliers
	M.rect(img, 10, 86, 4, 160, "gris_pierre")
	M.rect(img, 10, 86, 1, 160, "zinc_clair")
	M.rect(img, 13, 86, 1, 160, "ardoise")
	for y in range(96, 240, 36):
		M.rect(img, 9, y, 6, 2, "ardoise")
	# Étage : fenêtre de Sylvie, fenêtre du milieu à rideaux, fenêtre de droite à jardinière
	_fenetre_sylvie(img, FENETRE_SYLVIE.position.x, FENETRE_SYLVIE.position.y, fen)
	fenetre(img, 96, 99, FEN.x, FEN.y, fen, "vive", "rideaux")
	fenetre(img, 168, 99, FEN.x, FEN.y, fen, "vive", "")
	_jardiniere(img, 165, 145, 42, graine)
	# Rez-de-chaussée : deux fenêtres, la porte au milieu sous sa marquise
	fenetre(img, 24, 186, FEN.x, FEN.y, fen, "vive", "voilage")
	fenetre(img, 168, 186, FEN.x, FEN.y, fen, "vive", "")
	porte(img, PORTE.position.x, PORTE.position.y, "sarcelle", fen, true, "vive")
	_marquise(img, PORTE.position.x - 8, PORTE.position.y - 22, PORTE.size.x + 16)
	_marches(img, PORTE.position.x - 6, 246, PORTE.size.x + 12, 2)
	# Boîte aux lettres jaune (La Poste) à droite de la porte, numéro émaillé au-dessus
	_boite_murale(img, 142, 198)
	M.rect(img, 141, 178, 15, 12, "blanc_chaud")
	M.rect(img, 142, 179, 13, 10, "bleu_vif")
	M.rect(img, 141, 189, 15, 1, "pierre_ombre")
	M.texte(img, 146, 181, "7", "blanc_chaud")
	return {"image": img, "fenetres": fen, "auvent": Vector2i(-1, -1)}


## Chaîne d'angle en pierre claire en saillie (harpes 6 / 9 px, assises de 9 px) : arête éclairée,
## lit d'ombre sous chaque pierre.
static func _chaine_angle(img: Image, x: int, y: int, h: int, gauche: bool) -> void:
	for j in h:
		var k := j / 9
		var lw := 6 if k % 2 == 0 else 9
		var x0 := x if gauche else x + 9 - lw
		var r := j % 9
		var nom := "pierre_ombre" if r == 8 else ("pierre_claire" if r <= 1 else "pierre")
		M.rect(img, x0, y + j, lw, 1, nom)
		M.px(img, x0, y + j, "blanc_chaud" if r < 8 and gauche else ("pierre_claire" if r < 8 else "pierre_ombre"))
		M.px(img, x0 + lw - 1, y + j, "pierre_ombre")
		if r == 8 and gauche:
			M.px(img, x0 + lw, y + j, "brique")


## Bandeau de pierre en saillie (5 px) et ombre portée tramée sur le mur (ombre).
static func _bandeau(img: Image, x: int, y: int, l: int, ombre: String) -> void:
	M.rect(img, x, y, l, 2, "pierre_claire")
	M.rect(img, x, y, l, 1, "blanc_chaud")
	M.rect(img, x, y + 2, l, 2, "pierre")
	M.rect(img, x, y + 4, l, 1, "pierre_ombre")
	ombre_portee(img, x + 1, y + 5, l - 2, 3, ombre)


static func _soubassement(img: Image, x: int, y: int, l: int, h: int) -> void:
	M.rect(img, x, y, l, h, "pierre")
	M.rect(img, x, y, l, 2, "pierre_claire")
	M.rect(img, x, y + h - 2, l, 2, "pierre_ombre")
	for i in range(x, x + l, 18):
		M.rect(img, i, y + 2, 1, h - 4, "pierre_ombre")
		M.px(img, i + 1, y + 2, "pierre_claire")


## Toit en trapèze (croupe vue de face) avec épaisseur : tuiles ou ardoise, rives en relief (gauche
## éclairée, droite à l'ombre), faîtage, puis bord des tuiles (3 px), gouttière (3 px) et ombre de la
## sous-face tramée sur le mur (ombre).
static func _toit_trapeze(img: Image, x: int, y: int, l: int, h: int, pente: float, matiere: String, graine: int, ombre: String) -> void:
	var tex := M.tuiles(l, h, graine) if matiere == "tuiles" else M.ardoise(l, h, graine)
	var sombre := "brique_sombre" if matiere == "tuiles" else "nuit"
	var clair := "terre_cuite_claire" if matiere == "tuiles" else "gris_pierre"
	for j in h:
		var retrait := int((h - 1 - j) * pente)
		for i in range(retrait, l - retrait):
			img.set_pixel(x + i, y + j, tex.get_pixel(i, j))
		M.px(img, x + retrait, y + j, sombre)
		M.px(img, x + retrait + 1, y + j, clair)
		M.px(img, x + retrait + 2, y + j, clair)
		M.px(img, x + l - 1 - retrait, y + j, sombre)
		M.px(img, x + l - 2 - retrait, y + j, sombre)
	var r0 := int((h - 1) * pente)
	M.rect(img, x + r0, y - 3, l - 2 * r0, 3, "brique" if matiere == "tuiles" else "ardoise")
	M.rect(img, x + r0, y - 3, l - 2 * r0, 1, clair)
	M.rect(img, x + r0, y - 4, l - 2 * r0, 1, sombre)
	# Épaisseur : bord des tuiles, gouttière, sous-face
	var yb := y + h
	M.rect(img, x, yb - 3, l, 3, "brique" if matiere == "tuiles" else "ardoise_sombre")
	for i in range(x, x + l, 6):
		M.px(img, i, yb - 1, sombre)
	M.rect(img, x, yb, l, 1, "zinc_clair")
	M.rect(img, x, yb + 1, l, 2, "gris_pierre")
	M.rect(img, x, yb + 3, l, 1, "ardoise")
	ombre_portee(img, x + 2, yb + 4, l - 4, 6, ombre)


## Cheminée en volume (l × h) : face de brique, joue droite à l'ombre (5 px), chapeau de pierre en
## saillie avec sous-face, deux mitrons.
static func _cheminee(img: Image, x: int, y: int, l: int, h: int, graine: int) -> void:
	M.coller(img, M.brique(l, h - 6, graine, "classique"), x, y + 6)
	M.coller(img, M.brique(5, h - 6, graine + 1, "sombre"), x + l, y + 8)
	M.rect(img, x, y + 6, 1, h - 6, "brique_vive")
	M.rect(img, x + l + 4, y + 8, 1, h - 8, "nuit")
	M.rect(img, x - 3, y + 3, l + 10, 3, "pierre")
	M.rect(img, x - 3, y + 3, l + 10, 1, "pierre_claire")
	M.rect(img, x - 3, y + 6, l + 10, 1, "pierre_ombre")
	ombre_portee(img, x, y + 7, l + 5, 3, "brique_sombre")
	for mx in [x + 3, x + l - 6]:
		M.rect(img, mx, y - 1, 5, 4, "terre_cuite_claire")
		M.rect(img, mx + 3, y - 1, 2, 4, "tuile")
		M.rect(img, mx, y - 1, 5, 1, "tuile")


## Fenêtre l × h (36 × 48) en relief : linteau de pierre en saillie (clé), embrasure (ombre en haut et à
## gauche, tableau éclairé à droite), dormant blanc, croisée, 4 carreaux à reflets, appui en saillie et son
## ombre tramée, coulures. sur = variante de la brique du mur. style : "", "rideaux", "voilage", "volets".
static func fenetre(img: Image, x: int, y: int, l: int, h: int, fen: Array, sur := "vive", style := "") -> void:
	var ombre: String = OMBRE_SUR.get(sur, "brique_sombre")
	var t: Array = M.BRIQUES.get(sur, M.BRIQUES["vive"])
	# Volets persiennes ouverts (avec leur ombre sur le mur)
	if style == "volets":
		for v in [x - 17, x + l + 2]:
			M.rect(img, v, y, 15, h, "sarcelle")
			for j in range(y + 3, y + h - 2, 3):
				M.rect(img, v + 1, j, 13, 1, "vert_sombre")
				M.rect(img, v + 1, j + 1, 13, 1, "ciel" if v < x else "sarcelle")
			M.cadre(img, v, y, 15, h, "vert_sombre")
			ombre_portee(img, v + 15, y + 2, 2, h - 2, ombre)
	# Embrasure : fond d'ombre, tableau droit éclairé
	M.rect(img, x, y, l, h, ombre)
	M.rect(img, x + l - 2, y, 2, h, t[1])
	# Dormant blanc en retrait (3 px en haut, 3 à gauche)
	var d := Rect2i(x + 3, y + 4, l - 5, h - 4)
	M.rect(img, d.position.x, d.position.y, d.size.x, d.size.y, "blanc_chaud")
	M.rect(img, d.end.x - 1, d.position.y, 1, d.size.y, "zinc_clair")
	var gl := Rect2i(d.position.x + 2, d.position.y + 2, d.size.x - 4, d.size.y - 3)
	var mx := gl.position.x + gl.size.x / 2 - 1
	var ty := gl.position.y + gl.size.y * 2 / 5
	var carreaux := [
		Rect2i(gl.position.x, gl.position.y, mx - gl.position.x, ty - gl.position.y),
		Rect2i(mx + 2, gl.position.y, gl.end.x - mx - 2, ty - gl.position.y),
		Rect2i(gl.position.x, ty + 2, mx - gl.position.x, gl.end.y - ty - 2),
		Rect2i(mx + 2, ty + 2, gl.end.x - mx - 2, gl.end.y - ty - 2),
	]
	for k in carreaux.size():
		_vitre(img, carreaux[k], k)
		fen.append(carreaux[k])
	if style == "rideaux":
		for k in 4:
			var c: Rect2i = carreaux[k]
			var gx := c.position.x + 1 if k % 2 == 0 else c.end.x - 5
			M.rect(img, gx, c.position.y + 1, 4, c.size.y - 1, "creme")
			M.rect(img, gx + (3 if k % 2 == 0 else 0), c.position.y + 1, 1, c.size.y - 1, "pierre_claire")
	elif style == "voilage":
		for k in [2, 3]:
			var c: Rect2i = carreaux[k]
			M.rect(img, c.position.x, c.position.y + 3, c.size.x, c.size.y - 3, "creme")
			for i in range(c.position.x, c.end.x, 2):
				M.px(img, i, c.position.y + 3, "blanc_chaud")
				M.px(img, i + 1, c.position.y + 6, "pierre_claire")
	# Croisée (meneau 2 px, traverse 2 px), espagnolette
	M.rect(img, mx, d.position.y + 1, 2, d.size.y - 2, "blanc_chaud")
	M.rect(img, mx + 1, d.position.y + 1, 1, d.size.y - 2, "zinc_clair")
	M.rect(img, d.position.x + 1, ty, d.size.x - 2, 2, "blanc_chaud")
	M.rect(img, mx, ty + 6, 2, 2, "or")
	# Ombre de l'embrasure sur le dormant (haut et gauche)
	M.rect(img, d.position.x, d.position.y, d.size.x, 1, "pierre_claire")
	M.rect(img, d.position.x, d.position.y, 1, d.size.y, "pierre_claire")
	# Linteau en saillie et clé
	M.rect(img, x - 5, y - 7, l + 10, 7, "pierre")
	M.rect(img, x - 5, y - 7, l + 10, 2, "pierre_claire")
	M.rect(img, x - 5, y - 7, l + 10, 1, "blanc_chaud")
	M.rect(img, x - 5, y - 1, l + 10, 1, "pierre_ombre")
	M.rect(img, x + l / 2 - 4, y - 10, 8, 10, "pierre_claire")
	M.rect(img, x + l / 2 + 3, y - 10, 1, 10, "pierre_ombre")
	M.rect(img, x + l / 2 - 4, y - 10, 8, 1, "blanc_chaud")
	ombre_portee(img, x + l + 5, y - 6, 2, 6, ombre)
	# Appui en saillie, ombre tramée, coulures
	M.rect(img, x - 5, y + h, l + 10, 2, "blanc_chaud")
	M.rect(img, x - 5, y + h + 2, l + 10, 2, "pierre")
	M.rect(img, x - 5, y + h + 4, l + 10, 1, "pierre_ombre")
	ombre_portee(img, x - 3, y + h + 5, l + 8, 4, ombre)
	for i in 3:
		var cx := x + 3 + ((x * 7 + y * 3 + i * 11) % maxi(1, l - 6))
		var lg := 5 + (x + y + i * 5) % 9
		for j in lg:
			if M.trame(cx, y + h + 9 + j, 1.0 - float(j) / lg):
				M.px(img, cx, y + h + 9 + j, ombre)


## Vitre (carreau) : fond bleu ardoise assombri en haut (ombre du linteau), reflet du ciel en bandes
## diagonales (vitre_reflet, ciel), éclat dans le coin ; k varie le reflet d'un carreau à l'autre.
static func _vitre(img: Image, c: Rect2i, k: int) -> void:
	for y in c.size.y:
		for x in c.size.x:
			var nom := "bleu_ardoise"
			var d := x + y + k * 3
			if y == 0 or x == 0:
				nom = "bleu_nuit"
			elif y < 3 and M.trame(c.position.x + x, c.position.y + y, 0.5):
				nom = "bleu_nuit"
			elif (d % 14) < 3 and y > 1:
				nom = "vitre_reflet"
			elif (d % 14) == 3 and y > 1:
				nom = "ciel"
			elif y > c.size.y * 0.6 and M.trame(c.position.x + x, c.position.y + y, 0.25):
				nom = "ciel"
			M.px(img, c.position.x + x, c.position.y + y, nom)
	M.px(img, c.end.x - 2, c.position.y + 1, "blanc_chaud")
	M.px(img, c.end.x - 3, c.position.y + 1, "vitre_reflet")


## Usure du pied d'un mur (l × h à partir de (x, y), bas = y + h - 1) : salissures tramées qui montent
## depuis le sol, plaques de mousse, fissures en zigzag.
static func usure(img: Image, x: int, y: int, l: int, h: int, ombre: String, graine: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine + 501
	for j in h:
		var dens := 0.55 * (float(j) / h)
		for i in l:
			if img.get_pixel(x + i, y + j).a > 0.0 and M.trame(x + i, y + j, dens * (0.6 + 0.4 * sin((x + i) * 0.21 + graine))):
				M.px(img, x + i, y + j, ombre)
	for k in maxi(1, l / 30):
		var mx := x + rng.randi_range(0, l - 6)
		for i in rng.randi_range(3, 7):
			var hh := rng.randi_range(1, 3)
			M.rect(img, mx + i, y + h - hh, 1, hh, "mousse" if (i + k) % 3 != 0 else "feuille_profonde")
	for k in maxi(1, l / 60):
		var fx := x + rng.randi_range(4, l - 4)
		var fy := y - rng.randi_range(4, 30)
		for j in rng.randi_range(6, 14):
			M.px(img, fx + int(sin(j * 1.3) * 1.2), fy + j, ombre)



## Fenêtre ouverte de Sylvie (39 × 48) : embrasure profonde, pièce sombre, rideaux noués, battants vitrés
## repliés ; Sylvie (buste 27 × 32) est posée par RuePx0 ; la pièce s'allume la nuit derrière elle.
static func _fenetre_sylvie(img: Image, x: int, y: int, fen: Array) -> void:
	var l := FENETRE_SYLVIE.size.x
	var h := FENETRE_SYLVIE.size.y
	M.rect(img, x, y, l, h, "brique")
	M.rect(img, x + l - 2, y, 2, h, "brique_claire")
	M.rect(img, x + 3, y + 4, l - 5, h - 4, "blanc_chaud")
	M.rect(img, x + 5, y + 6, l - 9, h - 6, "nuit")
	M.rect(img, x + 5, y + 6, l - 9, 4, "encre")
	for c in [[x + 5, 1], [x + l - 10, -1]]:
		var cx: int = c[0]
		M.rect(img, cx, y + 6, 6, 20, "creme")
		M.rect(img, cx + (5 if c[1] > 0 else 0), y + 6, 1, 20, "pierre_claire")
		M.rect(img, cx + 1, y + 24, 4, 3, "rouge_auvent")
		M.rect(img, cx + (0 if c[1] > 0 else 3), y + 27, 3, 15, "creme")
	M.rect(img, x + 5, y + 6, 2, h - 6, "bleu_ardoise")
	M.rect(img, x + l - 6, y + 6, 2, h - 6, "bleu_ardoise")
	fen.append(Rect2i(x + 11, y + 10, l - 21, h - 10))
	M.rect(img, x - 5, y - 7, l + 10, 7, "pierre")
	M.rect(img, x - 5, y - 7, l + 10, 2, "pierre_claire")
	M.rect(img, x - 5, y - 7, l + 10, 1, "blanc_chaud")
	M.rect(img, x - 5, y - 1, l + 10, 1, "pierre_ombre")
	M.rect(img, x + l / 2 - 4, y - 10, 8, 10, "pierre_claire")
	M.rect(img, x + l / 2 + 3, y - 10, 1, 10, "pierre_ombre")
	M.rect(img, x - 5, y + h, l + 10, 2, "blanc_chaud")
	M.rect(img, x - 5, y + h + 2, l + 10, 2, "pierre")
	M.rect(img, x - 5, y + h + 4, l + 10, 1, "pierre_ombre")
	ombre_portee(img, x - 3, y + h + 5, l + 8, 4, "brique")


## Jardinière de géraniums (l × 8) posée sur un appui, avec son ombre.
static func _jardiniere(img: Image, x: int, y: int, l: int, graine: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine + 40
	M.rect(img, x, y, l, 7, "terre_cuite_claire")
	M.rect(img, x, y, l, 1, "blanc_chaud")
	M.rect(img, x, y + 5, l, 2, "tuile")
	M.rect(img, x + l - 2, y, 2, 7, "tuile")
	for i in range(x + 1, x + l - 1, 2):
		M.px(img, i, y - 1, "feuille" if (i / 2) % 2 == 0 else "feuille_vive")
		M.px(img, i + 1, y - 2, "feuille_profonde")
		M.px(img, i, y - 3, "feuille_vive")
	for i in range(x + 2, x + l - 3, 6):
		var dy := rng.randi_range(-1, 0)
		M.rect(img, i, y - 6 + dy, 3, 3, "rouge_auvent")
		M.px(img, i, y - 6 + dy, "tuile")
		M.px(img, i + 2, y - 4 + dy, "brique_sombre")


## Porte 33 × 66 en retrait (couleur de PORTES) : encadrement de pierre en saillie, embrasure d'ombre,
## vantail à panneaux biseautés (arêtes claires en haut à gauche, sombres en bas à droite), imposte vitrée.
static func porte(img: Image, x: int, y: int, couleur: String, fen: Array, imposte := true, sur := "vive") -> void:
	var t: Array = PORTES.get(couleur, PORTES["bois"])
	var ombre: String = OMBRE_SUR.get(sur, "brique_sombre")
	var l := 33
	var h := 66
	var hi := 11 if imposte else 0
	var haut := y - hi
	# Encadrement (5 px) : montant gauche éclairé, droit à l'ombre, linteau
	M.rect(img, x - 5, haut - 6, l + 10, h + hi + 6, "pierre")
	M.rect(img, x - 5, haut - 6, 3, h + hi + 6, "pierre_claire")
	M.rect(img, x - 5, haut - 6, l + 10, 2, "blanc_chaud")
	M.rect(img, x + l + 3, haut - 6, 2, h + hi + 6, "pierre_ombre")
	ombre_portee(img, x + l + 5, haut - 4, 3, h + hi + 4, ombre)
	# Embrasure (retrait de 3 px : ombre en haut et à gauche)
	M.rect(img, x, haut, l, h + hi, "nuit")
	var ix := x + 3
	var il := l - 4
	if imposte:
		M.rect(img, ix, haut + 3, il, hi - 4, "bleu_nuit")
		for i in range(ix + 4, ix + il, 5):
			M.rect(img, i, haut + 3, 1, hi - 4, "blanc_chaud")
		M.rect(img, ix, haut + hi - 1, il, 2, "blanc_chaud")
		M.px(img, ix + il - 3, haut + 4, "vitre_reflet")
		fen.append(Rect2i(ix, haut + 3, il, hi - 4))
	# Vantail
	var vy := y + 2
	var vh := h - 2
	M.rect(img, ix, vy, il, vh, t[0])
	M.rect(img, ix, vy, 1, vh, t[2])
	M.rect(img, ix + il - 1, vy, 1, vh, t[1])
	# Vitre haute à grille
	M.rect(img, ix + 5, vy + 5, il - 10, 17, "bleu_nuit")
	M.rect(img, ix + 5, vy + 5, il - 10, 1, t[1])
	M.rect(img, ix + il / 2, vy + 5, 1, 17, t[1])
	M.rect(img, ix + 5, vy + 13, il - 10, 1, t[1])
	M.px(img, ix + il - 8, vy + 7, "vitre_reflet")
	M.px(img, ix + il - 9, vy + 8, "vitre_reflet")
	fen.append(Rect2i(ix + 5, vy + 6, il - 10, 16))
	# Panneaux biseautés
	for py in [vy + 28, vy + 46]:
		var pl := il - 10
		M.rect(img, ix + 5, py, pl, 14, t[0])
		M.rect(img, ix + 5, py, pl, 1, t[2])
		M.rect(img, ix + 5, py, 1, 14, t[2])
		M.rect(img, ix + 5, py + 13, pl, 1, t[1])
		M.rect(img, ix + 5 + pl - 1, py, 1, 14, t[1])
	M.rect(img, ix + il - 6, vy + 36, 3, 3, "or")
	M.px(img, ix + il - 6, vy + 36, "lumiere")
	M.rect(img, ix + 8, vy + 24, 12, 2, "or")
	M.rect(img, ix + 8, vy + 25, 12, 1, "orange")


## Marquise au-dessus d'une porte (l × 10) : toit de zinc en pente vue d'en dessous, consoles, ombre.
static func _marquise(img: Image, x: int, y: int, l: int) -> void:
	for j in 6:
		var r := maxi(0, 3 - j)
		M.rect(img, x + r, y + j, l - 2 * r, 1, "zinc_clair" if j < 2 else ("gris_pierre" if j < 5 else "ardoise"))
	M.rect(img, x, y + 6, l, 2, "ardoise_sombre")
	M.rect(img, x, y + 6, l, 1, "nuit")
	for c in [x + 2, x + l - 4]:
		M.rect(img, c, y + 8, 2, 6, "nuit")
		M.px(img, c + 1, y + 14, "nuit")
	ombre_portee(img, x + 3, y + 8, l - 4, 5, "nuit")


## Marches de seuil (n), chacune : dessus éclairé, nez, contremarche, ombre.
static func _marches(img: Image, x: int, y: int, l: int, n: int) -> void:
	for k in n:
		var mx := x - k * 4
		var ml := l + k * 8
		var my := y + k * 6
		M.rect(img, mx, my, ml, 6, "pierre")
		M.rect(img, mx, my, ml, 2, "blanc_chaud")
		M.rect(img, mx, my + 2, ml, 1, "pierre_claire")
		M.rect(img, mx, my + 5, ml, 1, "pierre_ombre")
		M.rect(img, mx + ml - 1, my, 1, 6, "pierre_ombre")


## Boîte aux lettres murale jaune (La Poste), 13 × 18, en volume (joue droite, ombre portée).
static func _boite_murale(img: Image, x: int, y: int) -> void:
	M.rect(img, x, y, 13, 18, "or")
	M.rect(img, x, y, 13, 3, "lumiere")
	M.rect(img, x, y, 2, 18, "lumiere")
	M.rect(img, x + 11, y, 2, 18, "orange")
	M.rect(img, x, y + 16, 13, 2, "orange")
	M.rect(img, x + 3, y + 6, 7, 2, "encre")
	M.rect(img, x + 3, y + 8, 7, 1, "orange")
	M.rect(img, x + 4, y + 11, 3, 2, "bleu_vif")
	M.cadre(img, x - 1, y - 1, 15, 20, "bois_sombre")
	ombre_portee(img, x + 14, y + 1, 2, 19, "brique")
	ombre_portee(img, x, y + 19, 15, 2, "brique")


# --- Immeubles de la rue -----------------------------------------------------------------------------

## Bâtiment de la rue. cfg : l (largeur de façade), etages, brique (vive, classique, sombre, claire),
## toit ("ardoise", "tuiles", "plat", "pignon"), h_toit, rdc ("porte", "boutique", "garage", "aveugle"),
## porte, auvent, devanture, enseigne, pub, aveugle, graine ; retour ("gauche" / "droite") et cote
## (largeur du pan de mur latéral vu en perspective, 16 par défaut). Renvoie {"image", "fenetres",
## "auvent", "facade_x"} (facade_x : décalage de la façade dans l'image, = cote si retour gauche).
static func batiment(cfg: Dictionary) -> Dictionary:
	var l: int = cfg.get("l", 180)
	var etages: int = cfg.get("etages", 2)
	var toit: String = cfg.get("toit", "ardoise")
	var h_toit: int = cfg.get("h_toit", 54 if toit in ["ardoise", "tuiles"] else (24 if toit == "plat" else 66))
	var graine: int = cfg.get("graine", 1)
	var var_brique: String = cfg.get("brique", "classique")
	var ombre: String = OMBRE_SUR.get(var_brique, "brique_sombre")
	var retour: String = cfg.get("retour", "")
	var cote: int = cfg.get("cote", 16) if retour != "" else 0
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var h: int = h_toit + etages * H_ETAGE + H_RDC
	var fac := M.vide(l, h)
	var fen: Array = []
	var y_murs := h_toit
	var y_brique := 0 if toit == "plat" else y_murs
	M.coller(fac, M.brique(l, h - y_brique, graine, var_brique), 0, y_brique)
	var t: Array = M.BRIQUES[var_brique]
	M.rect(fac, 0, y_murs, 1, h - y_murs, t[1])
	M.rect(fac, l - 1, y_murs, 1, h - y_murs, t[3])
	usure(fac, 0, h - 30, l, 22, ombre, graine)
	match toit:
		"tuiles", "ardoise":
			_toit_trapeze(fac, 0, 4, l, h_toit - 8, 0.55 if toit == "tuiles" else 0.4, toit, graine + 3, ombre)
			if toit == "ardoise" and h_toit >= 45:
				var nl := maxi(1, (l - 60) / 66)
				for i in nl:
					_lucarne(fac, int((i + 0.5) * l / float(nl)) - 11, h_toit - 40, fen)
			_cheminee(fac, l - 40 if rng.randf() < 0.5 else 20, 0, 16, 26, graine)
		"plat":
			M.rect(fac, 0, 0, l, 6, "pierre")
			M.rect(fac, 0, 0, l, 2, "pierre_claire")
			M.rect(fac, 0, 0, l, 1, "blanc_chaud")
			M.rect(fac, 0, 5, l, 1, "pierre_ombre")
			ombre_portee(fac, 1, 6, l - 2, 3, ombre)
			var yc := h_toit - 10
			M.rect(fac, 0, yc, l, 10, "pierre")
			M.rect(fac, 0, yc, l, 2, "pierre_claire")
			M.rect(fac, 0, yc, l, 1, "blanc_chaud")
			for x in range(3, l - 3, 6):
				M.rect(fac, x, yc + 4, 3, 3, "pierre_claire")
				M.rect(fac, x + 3, yc + 4, 1, 3, "pierre_ombre")
			M.rect(fac, 0, yc + 8, l, 2, "pierre_ombre")
			ombre_portee(fac, 1, yc + 10, l - 2, 4, ombre)
		"pignon":
			_pignon_redents(fac, l, h_toit, var_brique, graine)
	# Étages
	var aveugle: bool = cfg.get("aveugle", false)
	var n := maxi(1, (l - 12) / 60)
	var xs: Array = []
	for i in n:
		xs.append(int(round((i + 0.5) * l / float(n))) - FEN.x / 2)
	for e in etages:
		var y0 := y_murs + e * H_ETAGE
		if aveugle:
			continue
		for i in xs.size():
			var style := ""
			var r := rng.randf()
			if r < 0.25:
				style = "rideaux"
			elif r < 0.4:
				style = "volets" if l - xs[i] > 56 and xs[i] > 18 else ""
			fenetre(fac, xs[i], y0 + 16, FEN.x, FEN.y, fen, var_brique, style)
			if rng.randf() < 0.2:
				_jardiniere(fac, xs[i] - 3, y0 + 61, 42, graine + i)
	if aveugle and cfg.has("pub"):
		_pub_peinte(fac, 8, y_murs + 18, mini(l - 16, 90), etages * H_ETAGE - 40, String(cfg["pub"]), graine)
	var y_rdc := h - H_RDC
	_bandeau(fac, 0, y_rdc - 6, l, ombre)
	var auvent := Vector2i(-1, -1)
	match String(cfg.get("rdc", "porte")):
		"boutique":
			auvent = _boutique(fac, y_rdc, l, cfg, fen, rng)
		"garage":
			_garage(fac, y_rdc, l, cfg, fen)
		"aveugle":
			porte(fac, l - 50, y_rdc + 18, String(cfg.get("porte", "bois")), fen, false, var_brique)
		_:
			var px := 16 if rng.randf() < 0.5 else l - 50
			porte(fac, px, y_rdc + 22, String(cfg.get("porte", "bois")), fen, true, var_brique)
			for x in xs:
				if absi(x + FEN.x / 2 - (px + 16)) > 40:
					fenetre(fac, x, y_rdc + 22, FEN.x, FEN.y, fen, var_brique, "voilage" if rng.randf() < 0.5 else "")
	_soubassement(fac, 0, h - 9, l, 9)
	# Composition : façade + pan de mur latéral en perspective
	var img := M.vide(l + cote, h)
	var fx := cote if retour == "gauche" else 0
	if cote > 0:
		_retour(img, 0 if retour == "gauche" else l, h, y_murs, cote, var_brique, retour == "gauche", toit, graine)
	M.coller(img, fac, fx, 0)
	var dec: Array = []
	for f in fen:
		dec.append(Rect2i(f.position + Vector2i(fx, 0), f.size))
	if auvent.x >= 0:
		auvent += Vector2i(fx, fx)
	return {"image": img, "fenetres": dec, "auvent": auvent, "facade_x": fx}


## Pan de mur latéral (retour) vu en perspective légère : largeur cote, le haut fuit vers le bas en
## s'éloignant de la façade (point de fuite au niveau de la rue). Gauche : face éclairée ; droite : à l'ombre.
## Couronnement sombre (rive du toit ou chaperon), soubassement qui fuit aussi.
static func _retour(img: Image, x0: int, h: int, y_murs: int, cote: int, var_brique: String, gauche: bool, toit: String, graine: int) -> void:
	var v := var_brique if gauche else String(COTE_OMBRE.get(var_brique, "sombre"))
	var tex := M.brique(cote, h, graine + 31, v)
	var haut0 := 0 if toit == "plat" else y_murs - 6
	for k in cote:
		var dist := (cote - 1 - k) if gauche else k        # 0 = contre la façade
		var x := x0 + k
		var yh := haut0 + int(dist * 0.5)
		for y in range(yh, h - 1 - dist / 6):
			img.set_pixel(x, y, tex.get_pixel(k, y))
		# couronnement (rive ou chaperon) et soubassement en fuite
		M.px(img, x, yh, "nuit" if not gauche else "pierre_claire")
		M.px(img, x, yh + 1, "ardoise_sombre" if not gauche else "pierre")
		M.px(img, x, yh + 2, "nuit" if not gauche else "pierre_ombre")
		for y in range(h - 9 - dist / 6, h - 1 - dist / 6):
			M.px(img, x, y, "pierre_ombre" if not gauche else "pierre")
		if not gauche:
			# léger dégradé tramé : plus sombre loin de la façade
			for y in range(yh + 3, h - 9 - dist / 6):
				if M.trame(x, y, float(dist) / cote * 0.5):
					M.px(img, x, y, "ombre_froide")
	# arête verticale entre façade et retour
	var xa := x0 + cote - 1 if gauche else x0
	M.rect(img, xa, haut0 + 2, 1, h - haut0 - 3, "pierre_claire" if gauche else "nuit")


## Pignon à redents (« pas de moineaux », pignon du Nord) : gradins de brique coiffés de pierre en saillie
## (dessus éclairé, ombre dessous), oculus en retrait.
static func _pignon_redents(img: Image, l: int, h_toit: int, var_brique: String, graine: int) -> void:
	var marches := 5
	var pas_x := l / (2 * marches + 1)
	var pas_y := h_toit / marches
	var mur := M.brique(l, h_toit, graine + 5, var_brique)
	for m in marches:
		var x0 := m * pas_x
		var y0 := h_toit - (m + 1) * pas_y
		var lw := l - 2 * x0
		for j in pas_y:
			for i in lw:
				img.set_pixel(x0 + i, y0 + j, mur.get_pixel(x0 + i, y0 + j))
		for xx in [x0 - 2, l - x0 - pas_x]:
			M.rect(img, xx, y0, pas_x + 2, 3, "pierre")
			M.rect(img, xx, y0, pas_x + 2, 1, "blanc_chaud")
			M.rect(img, xx, y0 + 3, pas_x + 2, 1, "pierre_ombre")
	var xs := marches * pas_x
	var ys := h_toit - marches * pas_y
	M.rect(img, xs - 1, ys - 6, l - 2 * xs + 2, 6, "brique")
	M.rect(img, xs - 3, ys - 9, l - 2 * xs + 6, 3, "pierre_claire")
	var cx := l / 2
	var cy := h_toit - 2 * pas_y + 3
	_ellipse_simple(img, cx, cy, 7, "pierre_claire")
	_ellipse_simple(img, cx, cy, 5, "nuit")
	M.px(img, cx + 2, cy - 2, "bleu_ardoise")


static func _ellipse_simple(img: Image, cx: int, cy: int, r: int, nom: String) -> void:
	for y in range(cy - r, cy + r + 1):
		for x in range(cx - r, cx + r + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r:
				M.px(img, x, y, nom)


## Lucarne de toit (22 × 36) en volume : fronton, joue droite à l'ombre, fenêtre 12 × 18.
static func _lucarne(img: Image, x: int, y: int, fen: Array) -> void:
	for j in 9:
		var r := 9 - j
		M.rect(img, x + r, y + j, 22 - 2 * r, 1, "ardoise_sombre" if j % 3 != 0 else "ardoise")
		M.px(img, x + r, y + j, "gris_pierre")
		M.px(img, x + 21 - r, y + j, "nuit")
	M.rect(img, x, y + 9, 22, 27, "pierre")
	M.rect(img, x, y + 9, 2, 27, "pierre_claire")
	M.rect(img, x + 18, y + 9, 4, 27, "pierre_ombre")
	M.rect(img, x + 22, y + 11, 3, 25, "nuit")
	M.rect(img, x + 4, y + 13, 13, 19, "blanc_chaud")
	M.rect(img, x + 5, y + 14, 11, 17, "bleu_ardoise")
	M.rect(img, x + 5, y + 14, 11, 2, "bleu_nuit")
	M.rect(img, x + 10, y + 14, 2, 17, "blanc_chaud")
	M.px(img, x + 14, y + 17, "vitre_reflet")
	fen.append(Rect2i(x + 5, y + 14, 5, 17))
	fen.append(Rect2i(x + 12, y + 14, 4, 17))
	M.rect(img, x - 1, y + 32, 24, 2, "pierre_claire")
	M.rect(img, x - 1, y + 34, 24, 1, "pierre_ombre")


## Devanture de boutique (rez-de-chaussée de 90) : coffrage peint, enseigne à lettres dorées, auvent rayé en
## volume (lambrequin festonné, sous-face sombre, joues), vitrine en retrait garnie, porte vitrée.
## Renvoie l'étendue x de l'auvent (pour son ombre au sol).
static func _boutique(img: Image, y: int, l: int, cfg: Dictionary, fen: Array, rng: RandomNumberGenerator) -> Vector2i:
	var peinture: String = cfg.get("devanture", "sarcelle")
	var auvent: String = cfg.get("auvent", "rouge_auvent")
	var enseigne: String = cfg.get("enseigne", "")
	M.rect(img, 4, y + 2, l - 8, H_RDC - 2, peinture)
	M.rect(img, 4, y + 2, 2, H_RDC - 2, "ciel" if peinture == "sarcelle" else "blanc_chaud")
	M.rect(img, l - 6, y + 2, 2, H_RDC - 2, "nuit")
	# Enseigne
	M.rect(img, 7, y + 4, l - 14, 17, "bleu_nuit")
	M.cadre(img, 7, y + 4, l - 14, 17, "or")
	M.rect(img, 7, y + 20, l - 14, 1, "nuit")
	if enseigne != "":
		var e := 3 if M.largeur_texte(enseigne, 3) <= l - 26 else 2
		var tw := M.largeur_texte(enseigne, e)
		M.texte(img, (l - tw) / 2 + 1, y + 6 + (15 - 5 * e) / 2 + 1, enseigne, "bois_sombre", e)
		M.texte(img, (l - tw) / 2, y + 6 + (15 - 5 * e) / 2, enseigne, "or", e)
	# Vitrine en retrait
	var vx := 13
	var vl := l - 68
	var vy := y + 40
	var vh := 38
	M.rect(img, vx - 3, vy - 3, vl + 6, vh + 6, "bois_sombre")
	M.rect(img, vx - 3, vy - 3, vl + 6, 1, "bois")
	M.rect(img, vx, vy, vl, vh, "bleu_ardoise")
	M.rect(img, vx, vy, vl, 3, "nuit")
	M.rect(img, vx, vy, 2, vh, "nuit")
	for i in 8:
		M.px(img, vx + vl - 6 - i, vy + 4 + i, "vitre_reflet")
		M.px(img, vx + vl - 7 - i, vy + 4 + i, "ciel")
	fen.append(Rect2i(vx, vy, vl, vh))
	var couleurs := ["orange", "feuille_vive", "rouge_auvent", "or", "feuille", "tuile"]
	for i in range(vx + 3, vx + vl - 12, 13):
		var c: String = couleurs[rng.randi_range(0, couleurs.size() - 1)]
		M.rect(img, i, vy + vh - 11, 12, 5, c)
		M.rect(img, i, vy + vh - 11, 12, 1, "blanc_chaud" if c == "or" else ("feuille_eclat" if c.begins_with("feuille") else "terre_cuite_claire"))
		for k in range(i + 1, i + 11, 3):
			M.px(img, k, vy + vh - 9, "brique_sombre" if c != "feuille" else "feuille_profonde")
		M.rect(img, i, vy + vh - 6, 12, 6, "bois")
		M.rect(img, i, vy + vh - 6, 12, 1, "caramel")
		M.rect(img, i + 11, vy + vh - 6, 1, 6, "bois_sombre")
	M.rect(img, vx, vy + vh + 3, vl, H_RDC - (vy - y) - vh - 3, peinture)
	M.rect(img, vx + 3, vy + vh + 5, vl - 6, 1, "nuit")
	# Porte vitrée en retrait
	var px := l - 48
	M.rect(img, px - 2, y + 30, 36, H_RDC - 30, "bois_sombre")
	M.rect(img, px + 2, y + 34, 28, H_RDC - 34, "nuit")
	M.rect(img, px + 5, y + 36, 22, 32, "bleu_nuit")
	M.px(img, px + 22, y + 39, "vitre_reflet")
	M.px(img, px + 21, y + 40, "vitre_reflet")
	fen.append(Rect2i(px + 5, y + 37, 22, 31))
	M.rect(img, px + 24, y + 66, 2, 5, "or")
	M.rect(img, px - 2, y + H_RDC - 3, 36, 3, "pierre")
	M.rect(img, px - 2, y + H_RDC - 3, 36, 1, "blanc_chaud")
	# Auvent : sous-face sombre (vue d'en bas), lambrequin rayé qui s'élargit, festons, joues
	var ay := y + 23
	var ah := 16
	for j in ah:
		var g := 2 - j / 6
		for i in range(g, l - g):
			var bande := ((i + j / 4) / 8) % 2 == 0
			var nom := auvent if bande else "blanc_chaud"
			if j < 2:
				nom = "brique_sombre" if auvent == "rouge_auvent" else "nuit"
			elif not bande and j > ah - 5:
				nom = "creme"
			elif bande and j > ah - 5:
				nom = "brique" if auvent == "rouge_auvent" else (auvent if auvent != "vert" else "vert_sombre")
			M.px(img, i, ay + j, nom)
	for i in range(0, l):
		if (i / 8) % 2 == 0 and not (i % 8 in [0, 7]):
			M.px(img, i, ay + ah, auvent)
			if i % 8 in [2, 3, 4, 5]:
				M.px(img, i, ay + ah + 1, auvent)
	for c in [0, l - 3]:
		M.rect(img, c, ay - 1, 3, ah + 1, "nuit")
	ombre_portee(img, 6, ay + ah + 2, l - 12, 7, "nuit")
	return Vector2i(0, l)


## Porte de garage à lames en relief (chaque lame : arête claire, corps, ombre) dans un encadrement.
static func _garage(img: Image, y: int, l: int, cfg: Dictionary, fen: Array) -> void:
	var gl := mini(l - 30, 78)
	var gx := 12
	var c: String = cfg.get("porte_garage", "sarcelle")
	M.rect(img, gx - 5, y + 8, gl + 10, H_RDC - 8, "pierre")
	M.rect(img, gx - 5, y + 8, 3, H_RDC - 8, "pierre_claire")
	M.rect(img, gx - 5, y + 8, gl + 10, 2, "blanc_chaud")
	M.rect(img, gx + gl + 3, y + 8, 2, H_RDC - 8, "pierre_ombre")
	M.rect(img, gx, y + 14, gl, H_RDC - 14, c)
	for j in range(y + 16, y + H_RDC, 6):
		M.rect(img, gx, j, gl, 1, "ciel" if c == "sarcelle" else "pierre_claire")
		M.rect(img, gx, j + 4, gl, 1, "vert_sombre")
		M.rect(img, gx, j + 5, gl, 1, "nuit")
	M.rect(img, gx, y + 14, gl, 3, "nuit")
	M.rect(img, gx + gl / 2 - 5, y + 60, 10, 3, "zinc_clair")
	M.rect(img, gx + gl / 2 - 5, y + 62, 10, 1, "ardoise")
	if l - gl - 24 > 36:
		porte(img, l - 46, y + 22, String(cfg.get("porte", "bois")), fen, false)


## Publicité peinte d'époque (sans marque réelle) sur un pignon aveugle : fond crème passé, lettres brique
## et bleu, une tasse fumante ; la peinture s'écaille (la brique réapparaît).
static func _pub_peinte(img: Image, x: int, y: int, l: int, h: int, texte: String, graine: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine + 77
	var pub := M.vide(l, h)
	M.rect(pub, 0, 0, l, h, "creme")
	M.cadre(pub, 3, 3, l - 6, h - 6, "brique")
	M.cadre(pub, 4, 4, l - 8, h - 8, "brique")
	var lignes := texte.split("|")
	var ty := 11
	for k in lignes.size():
		var t: String = lignes[k]
		var e := 3 if k == 0 and M.largeur_texte(t, 3) <= l - 14 else 2
		var tw := M.largeur_texte(t, e)
		M.texte(pub, (l - tw) / 2, ty, t, "brique" if k == 0 else "bleu_ardoise", e)
		ty += 5 * e + 6
	var cx := l / 2
	var cy := ty + 20
	if cy + 18 < h:
		M.rect(pub, cx - 15, cy + 12, 30, 3, "bleu_ardoise")
		M.rect(pub, cx - 10, cy, 20, 12, "blanc_chaud")
		M.cadre(pub, cx - 10, cy, 20, 12, "bleu_ardoise")
		M.rect(pub, cx - 9, cy + 1, 18, 3, "bois")
		M.cadre(pub, cx + 10, cy + 3, 5, 6, "bleu_ardoise")
		for v in [-5, 1]:
			for j in 9:
				M.px(pub, cx + v + (j / 3) % 2, cy - 3 - j, "pierre")
	for i in l * h / 60:
		var ex := rng.randi_range(0, l - 3)
		var ey := rng.randi_range(0, h - 2)
		pub.fill_rect(Rect2i(ex, ey, rng.randi_range(1, 4), 1), Color.TRANSPARENT)
	M.coller(img, pub, x, y)


# --- Muret, portail, armoire, mobilier --------------------------------------------------------------------

## Muret de briques (l × h + 9) à chaperon en relief (dessus éclairé, nez, ombre tramée) et créneaux de
## brique (dessus, joue à l'ombre), piliers de 12 px à chapeau ; pied usé.
static func muret(l: int, h: int, graine := 9) -> Image:
	var img := M.vide(l + 3, h + 9)
	M.coller(img, M.brique(l, h, graine, "classique"), 0, 9)
	M.rect(img, 0, 9, l, 3, "pierre_claire")
	M.rect(img, 0, 9, l, 1, "blanc_chaud")
	M.rect(img, 0, 12, l, 2, "pierre")
	M.rect(img, 0, 14, l, 1, "pierre_ombre")
	ombre_portee(img, 0, 15, l, 3, "brique_sombre")
	for x in range(5, l - 10, 15):
		M.rect(img, x, 3, 9, 6, "brique")
		M.rect(img, x, 3, 9, 1, "brique_claire")
		M.rect(img, x, 3, 1, 6, "brique_vive")
		M.rect(img, x + 9, 4, 2, 5, "brique_sombre")
	for p in [0, l - 12]:
		M.coller(img, M.brique(12, h + 3, graine + p, "vive"), p, 6)
		M.rect(img, p - 1, 1, 15, 5, "pierre")
		M.rect(img, p - 1, 1, 15, 2, "pierre_claire")
		M.rect(img, p - 1, 0, 15, 1, "blanc_chaud")
		M.rect(img, p - 1, 5, 15, 1, "pierre_ombre")
		M.rect(img, p + 10, 6, 2, h + 3, "brique_sombre")
		M.rect(img, p + 12, 7, 2, h + 2, "nuit")
		M.rect(img, p, 6, 1, h + 3, "brique_claire")
	usure(img, 0, h - 3, l, 12, "brique_sombre", graine)
	return img


## Portail métallique gris-vert (l × h) : cadre, barreaux à pointes, traverses en relief, serrure.
static func portail(l: int, h: int) -> Image:
	var img := M.vide(l, h)
	M.cadre(img, 0, 3, l, h - 3, "ombre_froide")
	for x in range(3, l - 2, 4):
		M.rect(img, x, 2, 2, h - 4, "bleu_gris")
		M.px(img, x, 2, "zinc_clair")
		M.rect(img, x, 0, 2, 2, "ombre_froide")
		M.rect(img, x + 2, 3, 1, h - 5, "ombre_froide")
	for y in [h / 3, h * 2 / 3]:
		M.rect(img, 1, y, l - 2, 3, "bleu_gris")
		M.rect(img, 1, y, l - 2, 1, "zinc_clair")
		M.rect(img, 1, y + 3, l - 2, 1, "ombre_froide")
	M.rect(img, 1, h - 6, l - 2, 5, "bleu_gris")
	M.rect(img, 1, h - 6, l - 2, 1, "zinc_clair")
	M.rect(img, l / 2 - 2, h / 2 - 3, 4, 6, "nuit")
	M.px(img, l / 2 - 1, h / 2 - 2, "or")
	return img


## Armoire technique de rue (l × h) gris-vert en volume : face, dessus visible, joue droite à l'ombre,
## portes à panneaux, ouïes, étiquette jaune.
static func armoire(l: int, h: int) -> Image:
	var img := M.vide(l + 4, h + 2)
	M.rect(img, 0, 2, l, h, "bleu_gris")
	M.rect(img, 2, 0, l, 2, "zinc_clair")
	M.rect(img, l, 1, 4, h, "ombre_froide")
	M.rect(img, 0, 2, 1, h, "zinc_clair")
	M.rect(img, l / 2, 5, 1, h - 7, "ombre_froide")
	for y in range(8, 20, 3):
		M.rect(img, 4, y, l / 2 - 7, 1, "ombre_froide")
		M.rect(img, 4, y + 1, l / 2 - 7, 1, "zinc_clair")
	M.rect(img, l / 2 + 4, 9, 7, 6, "or")
	M.px(img, l / 2 + 7, 11, "encre")
	M.rect(img, l / 2 - 4, h / 2, 2, 5, "nuit")
	M.rect(img, 0, h - 1, l + 4, 3, "ombre_froide")
	M.contour(img, "nuit")
	return img


## Lampadaire noir à cloche (15 × 126) : fût cylindrique (arête claire, corps, ombre), bagues, socle évasé,
## crosse, cloche en volume, globe crème (allumé la nuit par la rue : globe = Rect2i(4, 12, 7, 6)).
static func lampadaire() -> Image:
	var img := M.vide(15, 126)
	# Cloche
	for j in 9:
		var r := 2 + j * 5 / 8
		M.rect(img, 7 - r, 2 + j, 2 * r + 1, 1, "nuit")
		M.px(img, 7 - r, 2 + j, "ardoise")
		M.px(img, 7 - r + 1, 2 + j, "ardoise")
	M.rect(img, 6, 0, 3, 2, "nuit")
	M.px(img, 7, 0, "ardoise")
	M.rect(img, 0, 11, 15, 1, "encre")
	# Globe
	M.rect(img, 3, 12, 9, 6, "creme")
	M.rect(img, 3, 12, 2, 6, "blanc_chaud")
	M.rect(img, 10, 12, 2, 6, "pierre_claire")
	M.rect(img, 4, 18, 7, 2, "nuit")
	# Fût
	for y in range(20, 112):
		M.rect(img, 5, y, 5, 1, "nuit")
		M.px(img, 5, y, "ardoise")
		M.px(img, 6, y, "ardoise_sombre")
		M.px(img, 9, y, "encre")
	for y in [34, 72]:
		M.rect(img, 4, y, 7, 3, "nuit")
		M.rect(img, 4, y, 7, 1, "ardoise")
	# Socle
	for j in 14:
		var r := 3 + j / 3
		M.rect(img, 7 - r, 112 + j, 2 * r + 1, 1, "nuit")
		M.px(img, 7 - r, 112 + j, "ardoise")
		M.px(img, 7 + r, 112 + j, "encre")
	M.rect(img, 1, 124, 13, 2, "ardoise_sombre")
	return img


## Poteau d'incendie rouge (12 × 21) en volume : chapeau, bouchons latéraux, corps cylindrique.
static func bouche_incendie() -> Image:
	var img := M.vide(12, 21)
	M.rect(img, 3, 0, 6, 2, "rouge_auvent")
	M.rect(img, 2, 2, 8, 3, "rouge_auvent")
	M.rect(img, 1, 5, 10, 2, "brique_sombre")
	M.rect(img, 2, 7, 8, 12, "rouge_auvent")
	M.rect(img, 0, 9, 12, 4, "rouge_auvent")
	M.rect(img, 0, 9, 1, 4, "brique_sombre")
	M.rect(img, 11, 9, 1, 4, "brique_sombre")
	for y in 21:
		for x in 12:
			if img.get_pixel(x, y).a > 0.0 and PalettePixel.nom_de(img.get_pixel(x, y)) == "rouge_auvent":
				if x <= 3:
					M.px(img, x, y, "tuile")
				elif x >= 8:
					M.px(img, x, y, "brique")
	M.rect(img, 1, 19, 10, 2, "brique_sombre")
	M.px(img, 3, 1, "terre_cuite_claire")
	M.contour(img, "brique_sombre")
	return img


## Boîte aux lettres de rue (La Poste) sur pied, 15 × 36 : caisson jaune en volume, fente, oiseau bleu.
static func boite_poste() -> Image:
	var img := M.vide(15, 36)
	M.rect(img, 0, 2, 13, 17, "or")
	M.rect(img, 2, 0, 13, 2, "lumiere")
	M.rect(img, 13, 1, 2, 17, "orange")
	M.rect(img, 0, 2, 2, 17, "lumiere")
	M.rect(img, 3, 6, 8, 2, "encre")
	M.rect(img, 3, 8, 8, 1, "orange")
	M.rect(img, 5, 11, 4, 3, "bleu_vif")
	M.px(img, 8, 11, "ciel")
	M.rect(img, 0, 18, 15, 1, "orange")
	M.contour(img, "caramel")
	M.rect(img, 5, 19, 4, 15, "nuit")
	M.rect(img, 5, 19, 1, 15, "ardoise")
	M.rect(img, 3, 34, 8, 2, "nuit")
	return img


## Plaque de rue bleue émaillée (« RUE DES ÉPARGNANTS », illisible à cette taille), 33 × 13.
static func plaque() -> Image:
	var img := M.vide(33, 13)
	M.rect(img, 0, 0, 33, 13, "blanc_chaud")
	M.rect(img, 1, 1, 31, 11, "bleu_vif")
	M.cadre(img, 2, 2, 29, 9, "blanc_chaud")
	for x in range(5, 28, 3):
		M.rect(img, x, 5, 2, 3, "blanc_chaud")
	M.rect(img, 1, 12, 32, 1, "bleu_ardoise")
	M.rect(img, 32, 1, 1, 12, "bleu_ardoise")
	return img


## Haie basse (l × h) : grappes de feuillage d'été, contour feuille_sombre.
static func haie(l: int, h: int, graine := 5) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := M.vide(l, h)
	for k in l / 3 + 3:
		var cx := rng.randi_range(2, l - 3)
		var cy := rng.randi_range(h / 2, h - 3)
		var r := rng.randi_range(3, 5)
		for y in range(cy - r, cy + r + 1):
			for x in range(cx - r, cx + r + 1):
				if (x - cx) * (x - cx) + (y - cy) * (y - cy) > r * r or x < 0 or y < 0 or x >= l or y >= h:
					continue
				var lum := (-(x - cx) - (y - cy)) / float(r)
				M.px(img, x, y, "feuille_vive" if lum > 0.5 else ("feuille" if lum > -0.4 else "feuille_sombre"))
	M.rect(img, 0, h - 1, l, 1, "feuille_sombre")
	M.contour(img, "feuille_sombre", false)
	return img


## Grand arbre feuillu d'été (l × h) : tronc et branches (bois), houppier en grosses grappes éclairées
## en haut à gauche, 4 verts (feuille_eclat, feuille_vive, feuille, feuille_sombre), contour sombre.
## image 0 / 1 : feuillage décalé de 1 px (balancement). tronc_bas : le tronc descend jusqu'en bas.
static func arbre_ete(l: int, h: int, graine := 3, image := 0, avec_tronc := true, ombre := 0.0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := M.vide(l, h)
	var cx0 := l / 2
	var tl := maxi(6, l / 10)
	var ty := int(h * 0.45) if avec_tronc else h
	# Tronc et branches maîtresses
	M.rect(img, cx0 - tl / 2, ty, tl, h - ty, "bois")
	M.rect(img, cx0 - tl / 2, ty, 2, h - ty, "caramel")
	M.rect(img, cx0 + tl / 2 - 2, ty, 2, h - ty, "bois_sombre")
	if avec_tronc:
		M.rect(img, cx0 - tl / 2 - 2, h - 3, tl + 4, 3, "bois")
		M.rect(img, cx0 - tl / 2 - 2, h - 1, tl + 4, 1, "bois_sombre")
	for b in ([[-1, 0.22], [1, 0.26], [-1, 0.3]] if avec_tronc else []):
		var bx: int = cx0
		var by := ty + int((h - ty) * 0.15)
		for j in int(h * b[1]):
			var x := bx + int(b[0]) * (j * 2 / 3)
			var y := by - j
			M.rect(img, x - 1, y, 3, 1, "bois")
			M.px(img, x + 1, y, "bois_sombre")
	# Houppier : grosses masses (gabarit 100 × 140) remplies de petites grappes de feuilles, chacune
	# éclairée en haut à gauche ; les grappes du bas, posées après, découpent l'ombre de celles du haut.
	var sx := l / 100.0
	var sy := h / 140.0
	var gabarit := [[50, 40, 30], [26, 52, 22], [74, 50, 23], [36, 22, 20], [64, 20, 20], [50, 66, 22],
		[16, 74, 15], [84, 72, 15], [32, 78, 16], [68, 80, 16], [50, 12, 14]]
	var feuillage := M.vide(l, h)
	var decal := image % 2
	var s := minf(sx, sy)
	var gx := 50.0 * sx
	var gy := 45.0 * sy
	var gr := 45.0 * s
	var grappes: Array = []
	for c in gabarit:
		var cx: float = c[0] * sx
		var cy: float = c[1] * sy
		var rr: float = c[2] * s
		for k in maxi(2, int(rr * rr / 22.0)):
			var a := rng.randf() * TAU
			var d := sqrt(rng.randf()) * rr * 0.8
			grappes.append([int(cx + cos(a) * d), int(cy + sin(a) * d), maxi(3, int(rng.randf_range(4.0, 7.5) * s))])
	grappes.sort_custom(func(a, b): return a[1] < b[1])
	for g in grappes:
		var cx: int = g[0] + decal
		var cy: int = g[1]
		var r: int = g[2]
		for y in range(cy - r, cy + r + 1):
			for x in range(cx - r - 1, cx + r + 2):
				var dx := x - cx
				var dy := y - cy
				if dx * dx * 0.85 + dy * dy > r * r or x < 0 or y < 0 or x >= l or y >= h:
					continue
				var local := (-dx * 0.7 - dy) / float(r)
				var globale := (-(x - gx) * 0.5 - (y - gy)) / gr
				var lum := 0.55 * local + 0.6 * globale + ombre
				var nom := "feuille"
				if lum > 0.85:
					nom = "feuille_eclat"
				elif lum > 0.2:
					nom = "feuille_vive"
				elif lum > -0.45:
					nom = "feuille"
				else:
					nom = "feuille_sombre"
				M.px(feuillage, x, y, nom)
	M.contour(feuillage, "feuille_sombre")
	M.coller(img, feuillage, 0, 0)
	return img

## Arbre de premier plan (plan 1,15, PX0 ter) : grand tronc à droite et branche arquée qui passe
## au-dessus de la scène vers la gauche, chargée de masses de feuillage (plus sombres : à contre-jour).
## Image PP_L × PP_H ; le tronc occupe x PP_TRONC..PP_TRONC + 24 ; renvoie {"image0", "image1"} (2 images
## de balancement du feuillage).
const PP_L := 540
const PP_H := 645
const PP_TRONC := 474


static func arbre_premier_plan(graine := 61) -> Dictionary:
	var r := {}
	for im in 2:
		var img := M.vide(PP_L, PP_H)
		var rng := RandomNumberGenerator.new()
		rng.seed = graine
		# Tronc (évasé au pied), écorce
		var bois := M.vide(PP_L, PP_H)
		for y in range(165, PP_H):
			var ev := maxi(0, (y - (PP_H - 36)) / 3)
			var x0 := PP_TRONC - ev
			var lw := 36 + 2 * ev
			M.rect(bois, x0, y, lw, 1, "bois")
			M.rect(bois, x0, y, 7, 1, "caramel")
			M.rect(bois, x0 + 7, y, 2, 1, "terre_cuite_claire" if y % 7 < 2 else "caramel")
			M.rect(bois, x0 + lw - 10, y, 10, 1, "bois_sombre")
			M.rect(bois, x0 + lw - 4, y, 4, 1, "nuit")
		for k in 70:
			var y := rng.randi_range(168, PP_H - 4)
			var bx := PP_TRONC + rng.randi_range(8, 24)
			M.rect(bois, bx, y, rng.randi_range(2, 6), 1, "bois_sombre")
			M.px(bois, bx, y - 1, "caramel")
		# Branche arquée (courbe de Bézier), épaisseur 11 → 3, dessus éclairé
		var p0 := Vector2(PP_TRONC + 12, 240)
		var p1 := Vector2(PP_TRONC - 180, 30)
		var p2 := Vector2(45, 150)
		for s in 900:
			var tt := s / 900.0
			var p := p0.lerp(p1, tt).lerp(p1.lerp(p2, tt), tt)
			var ep := int(lerpf(18.0, 4.0, tt))
			var x := int(p.x)
			var y := int(p.y) - ep / 2
			M.rect(bois, x, y, 1, ep, "bois")
			M.px(bois, x, y, "caramel")
			M.px(bois, x, y + 1, "caramel")
			M.rect(bois, x, y + ep - 3, 1, 3, "bois_sombre")
		# Rameau secondaire vers le haut
		for s in 200:
			var tt := s / 200.0
			var p := Vector2(PP_TRONC - 60, 105).lerp(Vector2(PP_TRONC - 15, 0), tt)
			M.rect(bois, int(p.x), int(p.y), int(lerpf(9, 3, tt)), 1, "bois")
		M.contour(bois, "bois_sombre")
		M.coller(img, bois, 0, 0)
		# Masses de feuillage le long de la branche et en haut du tronc
		var masses := [[165, -15, 390, 270], [30, 30, 285, 195], [0, 90, 195, 150], [330, 45, 210, 255], [225, 120, 210, 135]]
		for m in masses:
			var f := arbre_ete(m[2], m[3], graine + m[0], im, false, -0.25)
			M.coller(img, f, m[0], m[1])
		r["image%d" % im] = img
	return r
