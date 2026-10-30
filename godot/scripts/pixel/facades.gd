extends RefCounted
## Façades et décor de la rue de briques (lot PX0 bis, docs/16 §8), générés en code dans la palette
## « Rue 84 » (59 couleurs). Pas de class_name : chargé par preload("res://scripts/pixel/facades.gd").
## Chaque bâtiment est déterministe (graine) et renvoie {"image": Image, "fenetres": [Rect2i]} : les
## vitres (coordonnées locales) s'allument la nuit (couleur lumiere, posée par RuePx0).
## Règles de dessin : lumière en haut à gauche ; contour des bâtiments dans le ton le plus sombre de
## leur matière ; encadrements et appuis en pierre claire (1 ligne claire + 1 ligne d'ombre portée en
## aplat) ; ombres portées en aplat du ton sombre de la surface touchée ; calme en haut, détails en bas.
## Échelle (§8.3) : 1 m ≈ 24 px ; étage 50, rez-de-chaussée 60, fenêtre 24 × 32, porte 22 × 44.

const M := preload("res://scripts/pixel/matieres.gd")

const H_RDC := 60
const H_ETAGE := 50
## Portes : [corps, ombre, éclat].
const PORTES := {
	"sarcelle": ["sarcelle", "vert_sombre", "ciel"],
	"bleu": ["bleu_vif", "bleu_ardoise", "ciel"],
	"rouge": ["rouge_auvent", "brique_sombre", "tuile"],
	"bois": ["bois", "bois_sombre", "caramel"],
	"vert": ["vert", "vert_sombre", "vert_clair"],
}
## Ombre portée sur chaque matière (§8.2 : aplat du ton sombre de la surface touchée).
const OMBRE_SUR := {"vive": "brique", "classique": "brique_sombre", "sombre": "bois_sombre", "claire": "pierre_ombre"}


# --- Maison de Gérard : maison de ville en brique, 152 × 172 (cheminée comprise) ---------------------

const MAISON_L := 152
const MAISON_H := 172
const FENETRE_SYLVIE := Rect2i(14, 66, 26, 32)     # fenêtre de l'étage, à gauche (26 × 32)
const PORTE := Rect2i(65, 120, 22, 44)             # porte (sans l'imposte, posée au-dessus)
const Y_MURS := 56                                 # bas du toit (gouttière)
const Y_BANDEAU := 108


static func maison_gerard(graine := 7) -> Dictionary:
	var img := M.vide(MAISON_L, MAISON_H)
	var fen: Array = []
	# Murs de brique vive (x 4..147, y 56..163), soubassement de pierre (y 164..171)
	M.coller(img, M.brique(144, 108, graine, "vive"), 4, Y_MURS)
	M.rect(img, 4, Y_MURS, 1, 108, "brique_claire")          # arête éclairée à gauche
	M.rect(img, 147, Y_MURS, 1, 108, "brique_sombre")        # contour sombre à droite
	_chaine_angle(img, 4, Y_MURS, 108, true)
	_chaine_angle(img, 142, Y_MURS, 108, false)
	usure(img, 4, 146, 144, 18, "brique", graine)
	M.rect(img, 2, 164, 148, 8, "pierre")
	M.rect(img, 2, 164, 148, 1, "pierre_claire")
	M.rect(img, 2, 171, 148, 1, "pierre_ombre")
	for x in range(2, 150, 12):
		M.rect(img, x, 165, 1, 6, "pierre_ombre")
	# Bandeau de pierre entre les niveaux
	_bandeau(img, 2, Y_BANDEAU, 148, "brique")
	# Toit de tuiles rouges en croupe (y 10..55), débord sur toute la largeur
	_toit_trapeze(img, 0, 12, MAISON_L, 44, 0.62, "tuiles", graine + 1)
	# Cheminée de brique (x 108..121) avec chapeau de pierre et deux mitrons
	M.coller(img, M.brique(14, 30, graine + 2, "classique"), 108, 6)
	M.rect(img, 108, 6, 1, 30, "brique_vive")
	M.rect(img, 121, 6, 1, 30, "brique_sombre")
	M.rect(img, 106, 3, 18, 3, "pierre")
	M.rect(img, 106, 3, 18, 1, "pierre_claire")
	M.rect(img, 107, 6, 16, 1, "brique_sombre")
	for mx in [110, 116]:
		M.rect(img, mx, 0, 4, 3, "terre_cuite_claire")
		M.rect(img, mx + 3, 0, 1, 3, "tuile")
	# Gouttière (zinc) et ombre portée du débord sur la brique
	M.rect(img, 0, 54, MAISON_L, 1, "zinc_clair")
	M.rect(img, 0, 55, MAISON_L, 1, "gris_pierre")
	M.rect(img, 5, 56, 142, 2, "brique")
	M.rect(img, 5, 58, 142, 1, "brique_sombre")
	M.rect(img, 6, 56, 2, 108, "gris_pierre")                # descente d'eau pluviale
	M.rect(img, 6, 56, 1, 108, "zinc_clair")
	for y in range(64, 160, 24):
		M.rect(img, 5, y, 4, 1, "ardoise")
	# Étage : fenêtre de Sylvie (ouverte), fenêtre du milieu, fenêtre de droite avec jardinière
	_fenetre_sylvie(img, FENETRE_SYLVIE.position.x, FENETRE_SYLVIE.position.y, fen)
	fenetre(img, 64, 66, 24, 32, fen, "vive", "rideaux")
	fenetre(img, 112, 66, 24, 32, fen, "vive", "")
	_jardiniere(img, 110, 96, 28, graine)
	# Rez-de-chaussée : deux fenêtres, la porte au milieu
	fenetre(img, 16, 124, 24, 32, fen, "vive", "voilage")
	fenetre(img, 112, 124, 24, 32, fen, "vive", "")
	porte(img, PORTE.position.x, PORTE.position.y, "sarcelle", fen, true)
	# Seuil : deux marches de pierre
	M.rect(img, 61, 164, 30, 4, "pierre_claire")
	M.rect(img, 61, 167, 30, 1, "pierre")
	M.rect(img, 58, 168, 36, 4, "pierre_claire")
	M.rect(img, 58, 171, 36, 1, "pierre_ombre")
	# Boîte aux lettres jaune (La Poste) à droite de la porte, numéro émaillé au-dessus
	_boite_murale(img, 94, 130)
	M.rect(img, 94, 116, 9, 7, "blanc_chaud")
	M.rect(img, 95, 117, 7, 5, "bleu_vif")
	M.texte(img, 97, 117, "7", "blanc_chaud")
	# Applique murale au-dessus de la boîte (allumée la nuit : op de RuePx0)
	return {"image": img, "fenetres": fen}


## Chaîne d'angle en pierre claire (harpes alternées 4 / 6 px de large, assises de 6 px).
static func _chaine_angle(img: Image, x: int, y: int, h: int, gauche: bool) -> void:
	for j in h:
		var k := j / 6
		var lw := 4 if k % 2 == 0 else 6
		var x0 := x if gauche else x + 6 - lw
		var nom := "pierre_ombre" if j % 6 == 5 else ("pierre_claire" if j % 6 == 0 else "pierre")
		M.rect(img, x0, y + j, lw, 1, nom)
		if gauche:
			M.px(img, x0, y + j, "pierre_claire" if j % 6 != 5 else "pierre_ombre")
		else:
			M.px(img, x0 + lw - 1, y + j, "pierre_ombre")


## Bandeau de pierre (3 px) avec ombre portée en aplat sur le mur (ombre).
static func _bandeau(img: Image, x: int, y: int, l: int, ombre: String) -> void:
	M.rect(img, x, y, l, 1, "pierre_claire")
	M.rect(img, x, y + 1, l, 1, "pierre")
	M.rect(img, x, y + 2, l, 1, "pierre_ombre")
	M.rect(img, x + 1, y + 3, l - 2, 1, ombre)


## Toit en trapèze (croupe vue de face) : bas de largeur l en (x, y + h - 1), retrait de pente px par
## rang ; tuiles ou ardoise ; rives sombres, faîtage.
static func _toit_trapeze(img: Image, x: int, y: int, l: int, h: int, pente: float, matiere: String, graine: int) -> void:
	var tex := M.tuiles(l, h, graine) if matiere == "tuiles" else M.ardoise(l, h, graine)
	var rive := "brique_sombre" if matiere == "tuiles" else "nuit"
	var arete := "terre_cuite_claire" if matiere == "tuiles" else "ardoise"
	for j in h:
		var retrait := int((h - 1 - j) * pente)
		for i in range(retrait, l - retrait):
			img.set_pixel(x + i, y + j, tex.get_pixel(i, j))
		M.px(img, x + retrait, y + j, rive)
		M.px(img, x + retrait + 1, y + j, arete)
		M.px(img, x + l - 1 - retrait, y + j, rive)
	var r0 := int((h - 1) * pente)
	M.rect(img, x + r0, y - 2, l - 2 * r0, 2, "brique" if matiere == "tuiles" else "gris_pierre")
	M.rect(img, x + r0, y - 2, l - 2 * r0, 1, rive)
	M.rect(img, x, y + h - 1, l, 1, rive)


## Fenêtre l × h (24 × 32) : linteau et appui de pierre claire, dormant blanc, croisée, 4 carreaux à
## reflet de ciel ; sur = matière du mur (ombre portée de l'appui). style : "", "rideaux", "voilage",
## "volets" (persiennes sarcelle). Les 4 carreaux s'allument la nuit (la croisée reste visible).
static func fenetre(img: Image, x: int, y: int, l: int, h: int, fen: Array, sur := "brique", style := "") -> void:
	var ombre: String = OMBRE_SUR.get(sur, "brique_sombre")
	# Linteau (3 px) et clé
	M.rect(img, x - 3, y - 4, l + 6, 4, "pierre_claire")
	M.rect(img, x - 3, y - 1, l + 6, 1, "pierre")
	M.rect(img, x + l / 2 - 2, y - 5, 4, 5, "pierre_claire")
	M.rect(img, x + l / 2 + 1, y - 5, 1, 5, "pierre")
	M.rect(img, x - 3, y - 5, l / 2 - 1, 1, "pierre_claire")
	# Volets persiennes ouverts
	if style == "volets":
		for v in [x - 11, x + l + 1]:
			M.rect(img, v, y, 10, h, "sarcelle")
			for j in range(y + 2, y + h - 1, 2):
				M.rect(img, v + 1, j, 8, 1, "vert_sombre")
			M.cadre(img, v, y, 10, h, "vert_sombre")
	# Dormant blanc (2 px) et embrasure
	M.rect(img, x, y, l, h, "blanc_chaud")
	M.rect(img, x + l - 1, y, 1, h, "zinc_clair")
	var gl := Rect2i(x + 2, y + 2, l - 4, h - 4)
	var mx := x + l / 2 - 1
	var ty := y + h * 2 / 5
	var carreaux := [
		Rect2i(gl.position.x, gl.position.y, mx - gl.position.x, ty - gl.position.y),
		Rect2i(mx + 2, gl.position.y, gl.end.x - mx - 2, ty - gl.position.y),
		Rect2i(gl.position.x, ty + 1, mx - gl.position.x, gl.end.y - ty - 1),
		Rect2i(mx + 2, ty + 1, gl.end.x - mx - 2, gl.end.y - ty - 1),
	]
	for k in carreaux.size():
		var c: Rect2i = carreaux[k]
		_vitre(img, c, k)
		fen.append(c)
	if style == "rideaux":
		for k in [0, 2]:
			var c: Rect2i = carreaux[k]
			M.rect(img, c.position.x + 1, c.position.y + 1, 3, c.size.y - 1, "creme")
			M.rect(img, c.position.x + 3, c.position.y + 1, 1, c.size.y - 1, "pierre_claire")
		for k in [1, 3]:
			var c: Rect2i = carreaux[k]
			M.rect(img, c.end.x - 3, c.position.y + 1, 3, c.size.y - 1, "creme")
			M.rect(img, c.end.x - 3, c.position.y + 1, 1, c.size.y - 1, "pierre_claire")
	elif style == "voilage":
		for k in [2, 3]:
			var c: Rect2i = carreaux[k]
			M.rect(img, c.position.x, c.position.y + 2, c.size.x, c.size.y - 2, "creme")
			for i in range(c.position.x, c.end.x, 2):
				M.px(img, i, c.position.y + 2, "blanc_chaud")
	# Croisée (meneau 2 px, traverse 1 px)
	M.rect(img, mx, y + 1, 2, h - 2, "blanc_chaud")
	M.rect(img, x + 1, ty, l - 2, 1, "blanc_chaud")
	M.px(img, mx + 1, ty + 4, "or")                                  # espagnolette
	# Appui de pierre et ombre portée en aplat, coulures sous l'appui
	M.rect(img, x - 3, y + h, l + 6, 2, "pierre_claire")
	M.rect(img, x - 3, y + h + 1, l + 6, 1, "pierre")
	M.rect(img, x - 2, y + h + 2, l + 4, 1, ombre)
	for i in 3:
		var cx := x + 2 + ((x * 7 + y * 3 + i * 11) % maxi(1, l - 4))
		var lg := 3 + (x + y + i * 5) % 7
		for j in lg:
			if j < 3 or M.trame(cx, y + h + 3 + j, 1.0 - float(j) / lg):
				M.px(img, cx, y + h + 3 + j, ombre)


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


## Fenêtre ouverte de Sylvie (26 × 32) : pièce sombre, rideaux, battants ouverts vers l'intérieur.
## Sylvie (buste 18 × 21) est posée par RuePx0 ; la pièce s'allume la nuit derrière elle.
static func _fenetre_sylvie(img: Image, x: int, y: int, fen: Array) -> void:
	var l := FENETRE_SYLVIE.size.x
	var h := FENETRE_SYLVIE.size.y
	M.rect(img, x - 3, y - 4, l + 6, 4, "pierre_claire")
	M.rect(img, x - 3, y - 1, l + 6, 1, "pierre")
	M.rect(img, x + l / 2 - 2, y - 5, 4, 5, "pierre_claire")
	M.rect(img, x + l / 2 + 1, y - 5, 1, 5, "pierre")
	M.rect(img, x, y, l, h, "blanc_chaud")
	M.rect(img, x + l - 1, y, 1, h, "zinc_clair")
	M.rect(img, x + 2, y + 2, l - 4, h - 2, "nuit")
	M.rect(img, x + 2, y + 2, l - 4, 3, "encre")                     # ombre du linteau dans la pièce
	# Rideaux crème noués, battants vitrés repliés contre l'embrasure
	for c in [[x + 2, 1], [x + l - 6, -1]]:
		var cx: int = c[0]
		M.rect(img, cx, y + 2, 4, 14, "creme")
		M.rect(img, cx + (3 if c[1] > 0 else 0), y + 2, 1, 14, "pierre_claire")
		M.rect(img, cx + (1 if c[1] > 0 else 1), y + 16, 2, 2, "rouge_auvent")
		M.rect(img, cx + (0 if c[1] > 0 else 2), y + 18, 2, 10, "creme")
	M.rect(img, x + 2, y + 2, 1, h - 2, "bleu_ardoise")
	M.rect(img, x + l - 3, y + 2, 1, h - 2, "bleu_ardoise")
	fen.append(Rect2i(x + 6, y + 5, l - 12, h - 5))
	# Appui
	M.rect(img, x - 3, y + h, l + 6, 2, "pierre_claire")
	M.rect(img, x - 3, y + h + 1, l + 6, 1, "pierre")
	M.rect(img, x - 2, y + h + 2, l + 4, 1, "brique")


## Jardinière de géraniums (l × 6) posée sur un appui.
static func _jardiniere(img: Image, x: int, y: int, l: int, graine: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine + 40
	M.rect(img, x, y, l, 5, "terre_cuite_claire")
	M.rect(img, x, y + 4, l, 1, "tuile")
	M.rect(img, x, y, l, 1, "tuile")
	for i in range(x + 1, x + l - 1, 2):
		M.px(img, i, y - 1, "feuille" if (i / 2) % 2 == 0 else "feuille_vive")
		M.px(img, i + 1, y - 2, "feuille")
	for i in range(x + 2, x + l - 2, 5):
		var dy := rng.randi_range(-1, 0)
		M.rect(img, i, y - 4 + dy, 2, 2, "rouge_auvent")
		M.px(img, i, y - 4 + dy, "tuile")


## Porte 22 × 44 (couleur de PORTES) avec imposte vitrée de 7 px au-dessus, encadrement de pierre
## claire ; vitre de l'imposte et du haut de la porte allumées la nuit.
static func porte(img: Image, x: int, y: int, couleur: String, fen: Array, imposte := true) -> void:
	var t: Array = PORTES.get(couleur, PORTES["bois"])
	var l := 22
	var h := 44
	var haut := y - (8 if imposte else 0)
	# Encadrement
	M.rect(img, x - 3, haut - 4, l + 6, h + (8 if imposte else 0) + 4, "pierre_claire")
	M.rect(img, x + l + 2, haut - 4, 1, h + (8 if imposte else 0) + 4, "pierre")
	M.rect(img, x - 3, haut - 4, l + 6, 1, "blanc_chaud")
	if imposte:
		M.rect(img, x, haut, l, 7, "bleu_nuit")
		for i in range(x + 3, x + l, 4):
			M.rect(img, i, haut, 1, 7, "blanc_chaud")
		M.rect(img, x, haut + 7, l, 1, "blanc_chaud")
		M.px(img, x + l - 3, haut + 1, "ciel")
		fen.append(Rect2i(x, haut, l, 7))
	# Vantail
	M.rect(img, x, y, l, h, t[0])
	M.rect(img, x, y, 1, h, t[2])
	M.rect(img, x + l - 1, y, 1, h, t[1])
	# Vitre haute à grille
	M.rect(img, x + 4, y + 4, l - 8, 12, "bleu_nuit")
	M.cadre(img, x + 3, y + 3, l - 6, 14, t[1])
	M.rect(img, x + l / 2 - 1, y + 4, 1, 12, t[1])
	M.px(img, x + l - 6, y + 5, "ciel")
	M.px(img, x + l - 7, y + 6, "ciel")
	fen.append(Rect2i(x + 4, y + 4, l - 8, 12))
	# Panneaux moulurés
	for py in [y + 20, y + 32]:
		M.cadre(img, x + 3, py, l - 6, 10, t[1])
		M.rect(img, x + 4, py + 1, l - 8, 1, t[2])
	M.rect(img, x + l - 5, y + 24, 2, 2, "or")                        # poignée
	M.rect(img, x + 6, y + 18, 8, 1, "or")                            # fente à lettres


## Boîte aux lettres murale jaune (La Poste), 9 × 12.
static func _boite_murale(img: Image, x: int, y: int) -> void:
	M.rect(img, x, y, 9, 12, "or")
	M.rect(img, x, y, 9, 2, "or")
	M.rect(img, x + 1, y + 1, 7, 1, "blanc_chaud")
	M.rect(img, x + 8, y, 1, 12, "orange")
	M.rect(img, x, y + 11, 9, 1, "orange")
	M.rect(img, x + 2, y + 4, 5, 1, "encre")
	M.cadre(img, x - 1, y - 1, 11, 14, "bois_sombre")
	M.rect(img, x, y + 13, 9, 1, "brique")                            # ombre portée sur la brique


# --- Immeubles de la rue -----------------------------------------------------------------------------

## Bâtiment de la rue. cfg : l (largeur), etages (au-dessus du rez-de-chaussée), brique (vive,
## classique, sombre, claire), toit ("ardoise", "tuiles", "plat", "pignon"), h_toit, rdc ("porte",
## "boutique", "garage", "aveugle"), porte (couleur), auvent (couleur), enseigne (texte), pub (texte),
## aveugle (sans fenêtre aux étages), graine. Renvoie {"image", "fenetres"}.
static func batiment(cfg: Dictionary) -> Dictionary:
	var l: int = cfg.get("l", 120)
	var etages: int = cfg.get("etages", 2)
	var toit: String = cfg.get("toit", "ardoise")
	var h_toit: int = cfg.get("h_toit", 36 if toit in ["ardoise", "tuiles"] else (16 if toit == "plat" else 44))
	var graine: int = cfg.get("graine", 1)
	var var_brique: String = cfg.get("brique", "classique")
	var ombre: String = OMBRE_SUR.get(var_brique, "brique_sombre")
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var h: int = h_toit + etages * H_ETAGE + H_RDC
	var img := M.vide(l, h)
	var fen: Array = []
	var y_murs := h_toit
	# Murs (l'acrotère d'un toit plat est en brique jusqu'en haut)
	var y_brique := 0 if toit == "plat" else y_murs
	M.coller(img, M.brique(l, h - y_brique, graine, var_brique), 0, y_brique)
	var t: Array = M.BRIQUES[var_brique]
	M.rect(img, 0, y_murs, 1, h - y_murs, t[1])
	M.rect(img, l - 1, y_murs, 1, h - y_murs, t[3] if var_brique != "claire" else "pierre_ombre")
	usure(img, 0, h - 22, l, 16, ombre, graine)
	# Toit
	match toit:
		"tuiles", "ardoise":
			_toit_trapeze(img, 0, 2, l, h_toit - 2, 0.55 if toit == "tuiles" else 0.4, toit, graine + 3)
			M.rect(img, 1, h_toit, l - 2, 2, ombre)
			if toit == "ardoise" and h_toit >= 30:
				var nl := maxi(1, (l - 40) / 44)
				for i in nl:
					_lucarne(img, int((i + 0.5) * l / float(nl)) - 7, h_toit - 24, fen)
			_souche(img, l - 26 if rng.randf() < 0.5 else 14, 0, graine)
		"plat":
			# Acrotère de brique et chaperon, corniche à denticules
			M.rect(img, 0, 0, l, 4, "pierre_claire")
			M.rect(img, 0, 3, l, 1, "pierre")
			M.rect(img, 1, 4, l - 2, 1, ombre)
			M.rect(img, 0, h_toit - 5, l, 5, "pierre")
			M.rect(img, 0, h_toit - 5, l, 1, "pierre_claire")
			for x in range(2, l - 2, 4):
				M.rect(img, x, h_toit - 3, 2, 2, "pierre_claire")
			M.rect(img, 0, h_toit - 1, l, 1, "pierre_ombre")
			M.rect(img, 1, h_toit, l - 2, 1, ombre)
		"pignon":
			_pignon_redents(img, l, h_toit, var_brique, graine)
	# Étages
	var aveugle: bool = cfg.get("aveugle", false)
	var n := maxi(1, (l - 8) / 40)
	var xs: Array = []
	for i in n:
		xs.append(int(round((i + 0.5) * l / float(n))) - 12)
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
				style = "volets" if l - xs[i] > 36 and xs[i] > 12 else ""
			fenetre(img, xs[i], y0 + 10, 24, 32, fen, var_brique, style)
			if rng.randf() < 0.2:
				_jardiniere(img, xs[i] - 2, y0 + 40, 28, graine + i)
	if aveugle and cfg.has("pub"):
		_pub_peinte(img, 5, y_murs + 12, mini(l - 10, 56), etages * H_ETAGE - 30, String(cfg["pub"]), graine)
	# Bandeau au-dessus du rez-de-chaussée
	var y_rdc := h - H_RDC
	_bandeau(img, 0, y_rdc - 4, l, ombre)
	match String(cfg.get("rdc", "porte")):
		"boutique":
			_boutique(img, y_rdc, l, cfg, fen, rng)
		"garage":
			_garage(img, y_rdc, l, cfg, fen)
		"aveugle":
			porte(img, l - 34, y_rdc + 12, String(cfg.get("porte", "bois")), fen, false)
		_:
			var px := 10 if rng.randf() < 0.5 else l - 34
			porte(img, px, y_rdc + 12, String(cfg.get("porte", "bois")), fen, true)
			for x in xs:
				if absi(x + 12 - (px + 11)) > 26:
					fenetre(img, x, y_rdc + 14, 24, 32, fen, var_brique, "voilage" if rng.randf() < 0.5 else "")
	# Soubassement
	M.rect(img, 0, h - 6, l, 6, "pierre")
	M.rect(img, 0, h - 6, l, 1, "pierre_claire")
	M.rect(img, 0, h - 1, l, 1, "pierre_ombre")
	return {"image": img, "fenetres": fen}


## Pignon à redents (« pas de moineaux », pignon du Nord) : triangle à gradins de brique, couverts de
## pierre claire, petit oculus.
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
		# chaperon de chaque gradin (côté gauche éclairé)
		M.rect(img, x0 - 1, y0, pas_x + 1, 2, "pierre_claire")
		M.rect(img, l - x0 - pas_x, y0, pas_x + 1, 2, "pierre_claire")
		M.rect(img, l - x0 - pas_x, y0 + 1, pas_x + 1, 1, "pierre")
	var xs := marches * pas_x
	var ys := h_toit - marches * pas_y
	M.rect(img, xs - 1, ys - 4, l - 2 * xs + 2, 4, "brique")
	M.rect(img, xs - 2, ys - 6, l - 2 * xs + 4, 2, "pierre_claire")
	# oculus
	var cx := l / 2
	var cy := h_toit - 2 * pas_y + 2
	M.rect(img, cx - 4, cy - 4, 8, 8, "pierre_claire")
	M.rect(img, cx - 3, cy - 3, 6, 6, "bleu_nuit")
	M.rect(img, cx - 3, cy - 3, 6, 1, "encre")


## Lucarne de toit d'ardoise (14 × 24) : joues d'ardoise, fronton, fenêtre 8 × 12.
static func _lucarne(img: Image, x: int, y: int, fen: Array) -> void:
	for j in 6:
		var r := 6 - j
		M.rect(img, x + r, y + j, 14 - 2 * r, 1, "ardoise_sombre" if j % 2 == 0 else "ardoise")
		M.px(img, x + r, y + j, "nuit")
		M.px(img, x + 13 - r, y + j, "nuit")
	M.rect(img, x, y + 6, 14, 18, "ardoise")
	M.rect(img, x + 13, y + 6, 1, 18, "nuit")
	M.rect(img, x + 2, y + 8, 10, 14, "blanc_chaud")
	M.rect(img, x + 3, y + 9, 8, 12, "bleu_ardoise")
	M.rect(img, x + 3, y + 9, 8, 1, "bleu_nuit")
	M.rect(img, x + 6, y + 9, 2, 12, "blanc_chaud")
	M.px(img, x + 9, y + 10, "ciel")
	fen.append(Rect2i(x + 3, y + 9, 3, 12))
	fen.append(Rect2i(x + 8, y + 9, 3, 12))


## Souche de cheminée (12 × 22) : brique, chapeau de pierre, mitrons.
static func _souche(img: Image, x: int, y: int, graine: int) -> void:
	M.coller(img, M.brique(12, 20, graine + 9, "classique"), x, y + 4)
	M.rect(img, x, y + 4, 1, 20, "brique_vive")
	M.rect(img, x + 11, y + 4, 1, 20, "brique_sombre")
	M.rect(img, x - 1, y + 2, 14, 2, "pierre_claire")
	M.rect(img, x, y + 4, 12, 1, "brique_sombre")
	M.rect(img, x + 2, y, 3, 2, "terre_cuite_claire")
	M.rect(img, x + 7, y, 3, 2, "tuile")


## Devanture de boutique (rez-de-chaussée de 60) : enseigne peinte, auvent rayé, vitrine garnie, porte.
static func _boutique(img: Image, y: int, l: int, cfg: Dictionary, fen: Array, rng: RandomNumberGenerator) -> void:
	var peinture: String = cfg.get("devanture", "sarcelle")
	var auvent: String = cfg.get("auvent", "rouge_auvent")
	var enseigne: String = cfg.get("enseigne", "")
	# Coffrage de bois peint
	M.rect(img, 3, y + 2, l - 6, H_RDC - 2, peinture)
	M.rect(img, 3, y + 2, 1, H_RDC - 2, "ciel" if peinture == "sarcelle" else "blanc_chaud")
	M.rect(img, l - 4, y + 2, 1, H_RDC - 2, "nuit")
	# Enseigne peinte (fond bleu nuit, lettres or)
	M.rect(img, 5, y + 3, l - 10, 11, "bleu_nuit")
	M.cadre(img, 5, y + 3, l - 10, 11, "or")
	if enseigne != "":
		var e := 2 if M.largeur_texte(enseigne, 2) <= l - 18 else 1
		var tw := M.largeur_texte(enseigne, e)
		M.texte(img, (l - tw) / 2, y + 4 + (11 - 5 * e) / 2, enseigne, "or", e)
	# Vitrine et porte
	var vx := 8
	var vl := l - 44
	var vy := y + 18
	var vh := 30
	M.rect(img, vx - 2, vy - 2, vl + 4, vh + 4, "bois_sombre")
	M.rect(img, vx, vy, vl, vh, "bleu_ardoise")
	M.rect(img, vx, vy, vl, 2, "bleu_nuit")
	for i in 5:
		M.px(img, vx + vl - 4 - i, vy + 3 + i, "ciel")
		M.px(img, vx + vl - 5 - i, vy + 3 + i, "ciel")
	fen.append(Rect2i(vx, vy, vl, vh))
	# Étal : cageots de fruits et légumes sur le rebord
	var couleurs := ["orange", "feuille_vive", "rouge_auvent", "or", "feuille", "tuile"]
	for i in range(vx + 2, vx + vl - 8, 9):
		var c: String = couleurs[rng.randi_range(0, couleurs.size() - 1)]
		M.rect(img, i, vy + vh - 7, 8, 3, c)
		M.rect(img, i, vy + vh - 7, 8, 1, "blanc_chaud" if c == "or" else c)
		M.rect(img, i, vy + vh - 4, 8, 4, "bois")
		M.rect(img, i, vy + vh - 4, 8, 1, "caramel")
		M.px(img, i + 7, vy + vh - 3, "bois_sombre")
	M.rect(img, vx, vy + vh + 2, vl, H_RDC - (vy - y) - vh - 2, peinture)
	M.rect(img, vx + 2, vy + vh + 4, vl - 4, 1, "nuit")
	# Porte vitrée
	var px := l - 32
	M.rect(img, px - 1, y + 16, 24, H_RDC - 16, "bois_sombre")
	M.rect(img, px + 3, y + 20, 16, 22, "bleu_nuit")
	M.rect(img, px + 3, y + 20, 16, 1, "encre")
	M.px(img, px + 15, y + 22, "ciel")
	M.px(img, px + 14, y + 23, "ciel")
	fen.append(Rect2i(px + 3, y + 21, 16, 21))
	M.rect(img, px + 17, y + 44, 2, 3, "or")
	M.rect(img, px + 1, y + H_RDC - 2, 20, 2, "pierre")
	# Auvent rayé (dépasse de 2 px), bord festonné, ombre portée en aplat sur la vitrine
	var ay := y + 15
	for j in 9:
		var g := 1 - j / 4
		for i in range(g, l - g):
			var bande := (i / 5) % 2 == 0
			M.px(img, i, ay + j, auvent if bande else "blanc_chaud")
		if j == 0:
			M.rect(img, g, ay, l - 2 * g, 1, "brique_sombre" if auvent == "rouge_auvent" else "nuit")
	for i in range(0, l):
		if (i / 5) % 2 == 0 and i % 5 != 4:
			M.px(img, i, ay + 9, auvent)
	M.rect(img, 3, ay + 10, l - 6, 3, "nuit")
	for i in range(3, l - 3):
		if (i / 5) % 2 == 1:
			M.px(img, i, ay + 10, "bleu_nuit" if i % 5 != 4 else "nuit")


## Porte de garage à lames (sarcelle), rez-de-chaussée.
static func _garage(img: Image, y: int, l: int, cfg: Dictionary, fen: Array) -> void:
	var gl := mini(l - 20, 52)
	var gx := 8
	M.rect(img, gx - 3, y + 6, gl + 6, H_RDC - 6, "pierre_claire")
	M.rect(img, gx, y + 10, gl, H_RDC - 10, String(cfg.get("porte_garage", "sarcelle")))
	for j in range(y + 12, y + H_RDC, 4):
		M.rect(img, gx, j, gl, 1, "vert_sombre")
	M.rect(img, gx, y + 10, gl, 2, "nuit")
	M.rect(img, gx + gl / 2 - 3, y + 40, 6, 2, "zinc_clair")
	if l - gl - 16 > 24:
		porte(img, l - 30, y + 12, String(cfg.get("porte", "bois")), fen, false)


## Publicité peinte d'époque (sans marque réelle) sur un pignon aveugle : fond crème passé, lettres
## brique et bleu, une tasse fumante ; la peinture s'écaille par endroits (la brique réapparaît).
static func _pub_peinte(img: Image, x: int, y: int, l: int, h: int, texte: String, graine: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine + 77
	var pub := M.vide(l, h)
	M.rect(pub, 0, 0, l, h, "creme")
	M.cadre(pub, 2, 2, l - 4, h - 4, "brique")
	M.cadre(pub, 3, 3, l - 6, h - 6, "brique")
	var lignes := texte.split("|")
	var ty := 8
	for k in lignes.size():
		var t: String = lignes[k]
		var e := 2 if k == 0 and M.largeur_texte(t, 2) <= l - 10 else 1
		var tw := M.largeur_texte(t, e)
		M.texte(pub, (l - tw) / 2, ty, t, "brique" if k == 0 else "bleu_ardoise", e)
		ty += 5 * e + 5
	# Tasse : soucoupe, bol, anse, vapeur
	var cx := l / 2
	var cy := ty + 14
	if cy + 12 < h:
		M.rect(pub, cx - 10, cy + 8, 20, 2, "bleu_ardoise")
		M.rect(pub, cx - 7, cy, 14, 8, "blanc_chaud")
		M.cadre(pub, cx - 7, cy, 14, 8, "bleu_ardoise")
		M.rect(pub, cx - 6, cy + 1, 12, 2, "bois")
		M.cadre(pub, cx + 7, cy + 2, 4, 4, "bleu_ardoise")
		for v in [-3, 1]:
			for j in 6:
				M.px(pub, cx + v + (j / 2) % 2, cy - 2 - j, "pierre")
	# Écaillage : la brique réapparaît (trame irrégulière)
	for i in l * h / 70:
		var ex := rng.randi_range(0, l - 3)
		var ey := rng.randi_range(0, h - 2)
		pub.fill_rect(Rect2i(ex, ey, rng.randi_range(1, 3), 1), Color.TRANSPARENT)
	M.coller(img, pub, x, y)


# --- Muret, végétation ---------------------------------------------------------------------------------

## Muret de briques à chaperon crénelé (l × h + 6) : chaperon de pierre, créneaux de brique (6 px tous
## les 10 px) coiffés de pierre claire, piliers de 8 px aux extrémités ; pied usé.
static func muret(l: int, h: int, graine := 9) -> Image:
	var img := M.vide(l, h + 6)
	M.coller(img, M.brique(l, h, graine, "classique"), 0, 6)
	M.rect(img, 0, 6, l, 2, "pierre_claire")
	M.rect(img, 0, 8, l, 1, "pierre")
	M.rect(img, 0, 9, l, 1, "brique_sombre")
	for x in range(3, l - 6, 10):
		M.rect(img, x, 2, 6, 4, "brique")
		M.rect(img, x, 2, 6, 1, "pierre_claire")
		M.rect(img, x + 5, 3, 1, 3, "brique_sombre")
		M.px(img, x, 3, "brique_vive")
	for p in [0, l - 8]:
		M.coller(img, M.brique(8, h + 2, graine + p, "vive"), p, 4)
		M.rect(img, p, 0, 8, 3, "pierre_claire")
		M.rect(img, p, 2, 8, 1, "pierre")
		M.rect(img, p, 3, 8, 1, "brique_sombre")
		M.rect(img, p + 7, 4, 1, h + 2, "brique_sombre")
		M.rect(img, p, 4, 1, h + 2, "brique_claire")
	usure(img, 0, h - 2, l, 8, "brique_sombre", graine)
	return img


## Portail métallique gris-vert (l × h) : cadre, barreaux, traverses, serrure ; contour encre.
static func portail(l: int, h: int) -> Image:
	var img := M.vide(l, h)
	M.cadre(img, 0, 0, l, h, "ombre_froide")
	M.rect(img, 1, 1, l - 2, 1, "bleu_gris")
	for x in range(2, l - 1, 3):
		M.rect(img, x, 1, 1, h - 2, "bleu_gris")
		M.px(img, x, 1, "zinc_clair")
	for y in [h / 3, h * 2 / 3]:
		M.rect(img, 1, y, l - 2, 2, "ombre_froide")
		M.rect(img, 1, y, l - 2, 1, "bleu_gris")
	M.rect(img, 1, h - 4, l - 2, 3, "bleu_gris")
	M.rect(img, 1, h - 2, l - 2, 1, "ombre_froide")
	M.rect(img, l / 2 - 1, h / 2 - 2, 3, 4, "nuit")
	M.px(img, l / 2, h / 2 - 1, "or")
	return img


## Armoire technique de rue (l × h) gris-vert : portes à panneaux, ouïes d'aération, étiquette jaune.
static func armoire(l: int, h: int) -> Image:
	var img := M.vide(l, h)
	M.rect(img, 0, 0, l, h, "bleu_gris")
	M.rect(img, 0, 0, l, 2, "zinc_clair")
	M.rect(img, l - 2, 0, 2, h, "ombre_froide")
	M.rect(img, l / 2, 3, 1, h - 5, "ombre_froide")
	for y in range(5, 12, 2):
		M.rect(img, 3, y, l / 2 - 5, 1, "ombre_froide")
	M.rect(img, l / 2 + 3, 6, 5, 4, "or")
	M.px(img, l / 2 + 5, 7, "encre")
	M.rect(img, l / 2 - 3, h / 2, 1, 3, "nuit")
	M.rect(img, 0, h - 2, l, 2, "ombre_froide")
	M.contour(img, "encre")
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
const PP_L := 360
const PP_H := 430
const PP_TRONC := 316


static func arbre_premier_plan(graine := 61) -> Dictionary:
	var r := {}
	for im in 2:
		var img := M.vide(PP_L, PP_H)
		var rng := RandomNumberGenerator.new()
		rng.seed = graine
		# Tronc (évasé au pied), écorce
		var bois := M.vide(PP_L, PP_H)
		for y in range(110, PP_H):
			var ev := maxi(0, (y - (PP_H - 24)) / 3)
			var x0 := PP_TRONC - ev
			var lw := 24 + 2 * ev
			M.rect(bois, x0, y, lw, 1, "bois")
			M.rect(bois, x0, y, 5, 1, "caramel")
			M.rect(bois, x0 + lw - 7, y, 7, 1, "bois_sombre")
		for k in 40:
			var y := rng.randi_range(112, PP_H - 4)
			M.rect(bois, PP_TRONC + rng.randi_range(6, 14), y, rng.randi_range(2, 5), 1, "bois_sombre")
		# Branche arquée (courbe de Bézier), épaisseur 11 → 3, dessus éclairé
		var p0 := Vector2(PP_TRONC + 8, 160)
		var p1 := Vector2(PP_TRONC - 120, 20)
		var p2 := Vector2(30, 100)
		for s in 600:
			var tt := s / 600.0
			var p := p0.lerp(p1, tt).lerp(p1.lerp(p2, tt), tt)
			var ep := int(lerpf(12.0, 3.0, tt))
			var x := int(p.x)
			var y := int(p.y) - ep / 2
			M.rect(bois, x, y, 1, ep, "bois")
			M.px(bois, x, y, "caramel")
			M.rect(bois, x, y + ep - 2, 1, 2, "bois_sombre")
		# Rameau secondaire vers le haut
		for s in 200:
			var tt := s / 200.0
			var p := Vector2(PP_TRONC - 40, 70).lerp(Vector2(PP_TRONC - 10, 0), tt)
			M.rect(bois, int(p.x), int(p.y), int(lerpf(6, 2, tt)), 1, "bois")
		M.contour(bois, "bois_sombre")
		M.coller(img, bois, 0, 0)
		# Masses de feuillage le long de la branche et en haut du tronc
		var masses := [[110, -10, 260, 180], [20, 20, 190, 130], [0, 60, 130, 100], [220, 30, 140, 170], [150, 80, 140, 90]]
		for m in masses:
			var f := arbre_ete(m[2], m[3], graine + m[0], im, false, -0.25)
			M.coller(img, f, m[0], m[1])
		r["image%d" % im] = img
	return r
