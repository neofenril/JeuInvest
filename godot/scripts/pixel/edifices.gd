extends RefCounted
## Bâtiments jouables de la rue (lot PX1, docs/16 §8.4) et petits objets des séquences, générés en code dans
## la palette avec les pinceaux de facades.gd. Pas de class_name (preload).
## - Banque 270 × 285 : brique vive, pilastres et encadrements de pierre claire, fronton à horloge (aiguille
##   dessinée à part), enseigne « BANQUE » dorée, porte de bois à deux battants, fenêtre du banquier,
##   distributeur (image à part, posée à partir de 1986).
## - La Gazette 225 × 318 : brique sombre, journal lumineux sur le toit (écran dessiné à part), enseigne peinte
##   « LA GAZETTE » au 1er étage et néon rose (à part, il grésille), vitrine des rotatives.
## Repères (coordonnées dans l'image, haut gauche) exportés en constantes pour les séquences.

const M := preload("res://scripts/pixel/matieres.gd")
const F := preload("res://scripts/pixel/facades.gd")

const BANQUE := Vector2i(270, 285)
const HORLOGE := Vector2i(135, 29)            # centre du cadran
const RAYON_HORLOGE := 11
const FENETRE_BANQUIER := Rect2i(196, 200, 44, 56)
const DISTRIBUTEUR := Vector2i(80, 206)        # coin haut gauche du distributeur

const GAZETTE := Vector2i(225, 318)
const ECRAN := Rect2i(25, 3, 175, 34)          # intérieur du journal lumineux
const NEON := Vector2i(42, 200)                # coin haut gauche du néon rose (sous l'enseigne)
const ROTATIVE := Rect2i(14, 244, 126, 62)


# --- Banque ---------------------------------------------------------------------------------------------

static func banque(graine := 91) -> Dictionary:
	var img := M.vide(BANQUE.x, BANQUE.y)
	var fen: Array = []
	var l := BANQUE.x
	# Murs de brique vive sous l'entablement
	M.coller(img, M.brique(l - 8, BANQUE.y - 62, graine, "vive"), 4, 62)
	F.usure(img, 4, 245, l - 8, 30, "brique", graine)
	# Pilastres de pierre aux angles
	for x in [0, l - 14]:
		M.rect(img, x, 56, 14, BANQUE.y - 56, "pierre")
		M.rect(img, x, 56, 3, BANQUE.y - 56, "pierre_claire")
		M.rect(img, x + 12, 56, 2, BANQUE.y - 56, "pierre_ombre")
		for y in range(66, BANQUE.y - 9, 12):
			M.rect(img, x + 2, y, 11, 1, "pierre_ombre")
	F.ombre_portee(img, 14, 62, 3, BANQUE.y - 70, "brique")
	# Entablement et corniche à denticules
	M.rect(img, 0, 46, l, 16, "pierre")
	M.rect(img, 0, 46, l, 2, "blanc_chaud")
	M.rect(img, 0, 48, l, 2, "pierre_claire")
	for x in range(3, l - 3, 6):
		M.rect(img, x, 53, 3, 4, "pierre_claire")
		M.rect(img, x + 3, 53, 1, 4, "pierre_ombre")
	M.rect(img, 0, 59, l, 3, "pierre_ombre")
	F.ombre_portee(img, 16, 62, l - 32, 5, "brique")
	# Fronton triangulaire et horloge
	var base_g := 62
	var base_d := l - 62
	for y in range(4, 46):
		var k := float(y - 4) / 42.0
		var x0 := int(lerpf(HORLOGE.x - 2, base_g, k))
		var x1 := int(lerpf(HORLOGE.x + 2, base_d, k))
		M.rect(img, x0, y, x1 - x0, 1, "pierre")
		M.px(img, x0, y, "blanc_chaud")
		M.px(img, x0 + 1, y, "pierre_claire")
		M.px(img, x1 - 1, y, "pierre_ombre")
		M.px(img, x1 - 2, y, "pierre_ombre")
	M.rect(img, base_g, 44, base_d - base_g, 2, "pierre_ombre")
	var c := HORLOGE
	for y in range(-RAYON_HORLOGE - 2, RAYON_HORLOGE + 3):
		for x in range(-RAYON_HORLOGE - 2, RAYON_HORLOGE + 3):
			var d := sqrt(x * x + y * y)
			if d <= RAYON_HORLOGE + 2.2:
				M.px(img, c.x + x, c.y + y, "bois_sombre" if d > RAYON_HORLOGE + 0.8 else ("or" if d > RAYON_HORLOGE - 0.6 else "blanc_chaud"))
	for h in 12:
		var a := h * TAU / 12.0
		M.px(img, c.x + roundi(sin(a) * (RAYON_HORLOGE - 2)), c.y - roundi(cos(a) * (RAYON_HORLOGE - 2)), "nuit" if h % 3 == 0 else "gris_pierre")
	# Étage : trois hautes fenêtres à volets
	for x in [44, 117, 190]:
		F.fenetre(img, x, 80, 36, 54, fen, "vive", "rideaux" if x == 117 else "")
	# Bandeau et enseigne « BANQUE » dorée
	M.rect(img, 4, 150, l - 8, 26, "pierre")
	M.rect(img, 4, 150, l - 8, 2, "blanc_chaud")
	M.rect(img, 4, 174, l - 8, 2, "pierre_ombre")
	var tw := M.largeur_texte("BANQUE", 3)
	M.rect(img, (l - tw) / 2 - 8, 154, tw + 16, 19, "bleu_nuit")
	M.cadre(img, (l - tw) / 2 - 8, 154, tw + 16, 19, "or")
	M.texte(img, (l - tw) / 2 + 1, 157, "BANQUE", "bois_sombre", 3)
	M.texte(img, (l - tw) / 2, 156, "BANQUE", "or", 3)
	F.ombre_portee(img, 16, 176, l - 32, 4, "brique")
	# Rez-de-chaussée : fenêtre du guichet, porte à deux battants sous arc, fenêtre du banquier
	F.fenetre(img, 30, 200, 44, 56, fen, "vive", "voilage")
	F.fenetre(img, FENETRE_BANQUIER.position.x, FENETRE_BANQUIER.position.y, FENETRE_BANQUIER.size.x, FENETRE_BANQUIER.size.y, fen, "vive", "")
	_porte_double(img, 110, 192, 50, 84)
	F._marches(img, 104, 276, 62, 1)
	F._soubassement(img, 0, BANQUE.y - 9, l, 9)
	# Plaque de cuivre près de la porte
	M.rect(img, 168, 214, 10, 7, "or")
	M.rect(img, 169, 216, 8, 1, "orange")
	M.rect(img, 169, 218, 8, 1, "orange")
	return {"image": img, "fenetres": fen}


static func _porte_double(img: Image, x: int, y: int, l: int, h: int) -> void:
	# Encadrement de pierre en arc
	M.rect(img, x - 7, y - 4, l + 14, h + 4, "pierre")
	M.rect(img, x - 7, y - 4, 3, h + 4, "pierre_claire")
	M.rect(img, x + l + 5, y - 4, 2, h + 4, "pierre_ombre")
	for i in range(-7, l + 7):
		var t := (i + 0.5 - l / 2.0) / (l / 2.0 + 7.0)
		var dy := int(10.0 * (1.0 - t * t))
		M.rect(img, x + i, y - 4 - dy, 1, dy, "pierre")
		M.px(img, x + i, y - 4 - dy, "blanc_chaud")
	M.rect(img, x + l / 2 - 3, y - 16, 6, 10, "pierre_claire")
	M.rect(img, x, y, l, h, "nuit")
	for k in 2:
		var bx := x + 2 + k * (l / 2)
		var bl := l / 2 - 3
		M.rect(img, bx, y + 2, bl, h - 2, "bois")
		M.rect(img, bx, y + 2, 1, h - 2, "caramel")
		M.rect(img, bx + bl - 1, y + 2, 1, h - 2, "bois_sombre")
		for py in [y + 8, y + 34, y + 58]:
			M.rect(img, bx + 4, py, bl - 8, 20, "bois")
			M.rect(img, bx + 4, py, bl - 8, 1, "caramel")
			M.rect(img, bx + 4, py, 1, 20, "caramel")
			M.rect(img, bx + 4, py + 19, bl - 8, 1, "bois_sombre")
			M.rect(img, bx + bl - 5, py, 1, 20, "bois_sombre")
	M.rect(img, x + l / 2 - 4, y + 44, 2, 6, "or")
	M.rect(img, x + l / 2 + 2, y + 44, 2, 6, "or")


## Distributeur de billets (à partir de 1986) : 18 × 34, écran ambre, clavier, fente.
static func distributeur() -> Image:
	var img := M.vide(18, 34)
	M.rect(img, 0, 0, 18, 34, "gris_pierre")
	M.rect(img, 0, 0, 18, 2, "zinc_clair")
	M.rect(img, 16, 0, 2, 34, "ardoise")
	M.rect(img, 3, 4, 11, 8, "nuit")
	M.rect(img, 4, 5, 9, 6, "ambre")
	M.rect(img, 5, 6, 5, 1, "nuit")
	M.rect(img, 5, 8, 7, 1, "nuit")
	for j in 3:
		for i in 3:
			M.rect(img, 4 + i * 3, 15 + j * 3, 2, 2, "zinc_clair")
	M.rect(img, 3, 26, 11, 2, "encre")
	M.texte(img, 3, 28, "CB", "bleu_vif")
	M.cadre(img, 0, 0, 18, 34, "ardoise_sombre")
	return img


# --- La Gazette ---------------------------------------------------------------------------------------------

static func gazette(graine := 93) -> Dictionary:
	var img := M.vide(GAZETTE.x, GAZETTE.y)
	var fen: Array = []
	var l := GAZETTE.x
	var y_toit := 54
	# Journal lumineux : cadre, pieds (l'écran est dessiné à part)
	M.rect(img, ECRAN.position.x - 4, 0, ECRAN.size.x + 8, ECRAN.size.y + 7, "ardoise_sombre")
	M.rect(img, ECRAN.position.x - 4, 0, ECRAN.size.x + 8, 1, "gris_pierre")
	M.rect(img, ECRAN.position.x - 4, 0, 1, ECRAN.size.y + 7, "ardoise")
	M.rect(img, ECRAN.position.x - 1, ECRAN.position.y - 1, ECRAN.size.x + 2, ECRAN.size.y + 2, "nuit")
	M.rect(img, ECRAN.position.x, ECRAN.position.y, ECRAN.size.x, ECRAN.size.y, "encre")
	for px in [52, 172]:
		M.rect(img, px, ECRAN.size.y + 7, 4, y_toit - ECRAN.size.y - 7, "ardoise")
		M.rect(img, px, ECRAN.size.y + 7, 1, y_toit - ECRAN.size.y - 7, "gris_pierre")
		for j in range(ECRAN.size.y + 9, y_toit, 4):
			M.px(img, px + 4 + (j / 4) % 2, j, "ardoise_sombre")
	# Corps : brique sombre, toit plat à corniche
	M.coller(img, M.brique(l, GAZETTE.y - y_toit, graine, "sombre"), 0, y_toit)
	M.rect(img, 0, y_toit, 1, GAZETTE.y - y_toit, "brique")
	M.rect(img, l - 1, y_toit, 1, GAZETTE.y - y_toit, "nuit")
	F.usure(img, 0, GAZETTE.y - 34, l, 24, "bois_sombre", graine)
	M.rect(img, 0, y_toit, l, 6, "pierre")
	M.rect(img, 0, y_toit, l, 1, "blanc_chaud")
	M.rect(img, 0, y_toit + 5, l, 1, "pierre_ombre")
	var yc := y_toit + 14
	M.rect(img, 0, yc, l, 10, "pierre")
	M.rect(img, 0, yc, l, 2, "pierre_claire")
	for x in range(3, l - 3, 6):
		M.rect(img, x, yc + 4, 3, 3, "pierre_claire")
		M.rect(img, x + 3, yc + 4, 1, 3, "pierre_ombre")
	M.rect(img, 0, yc + 8, l, 2, "pierre_ombre")
	F.ombre_portee(img, 1, yc + 10, l - 2, 4, "bois_sombre")
	# 2e étage : trois fenêtres
	for x in [30, 95, 160]:
		F.fenetre(img, x, 96, 36, 48, fen, "sombre", "")
	# 1er étage : enseigne peinte « LA GAZETTE » (fond crème passé, lettres bleu nuit, filets brique)
	F._bandeau(img, 0, 152, l, "bois_sombre")
	var tw := M.largeur_texte("LA GAZETTE", 3)
	var ex := (l - tw) / 2 - 10
	M.rect(img, ex, 166, tw + 20, 27, "creme")
	M.cadre(img, ex + 2, 168, tw + 16, 23, "brique")
	M.texte(img, ex + 11, 172, "LA GAZETTE", "pierre_ombre", 3)
	M.texte(img, ex + 10, 171, "LA GAZETTE", "bleu_nuit", 3)
	for i in 30:
		var px := ex + (i * 37) % (tw + 18)
		var py := 167 + (i * 11) % 24
		M.px(img, px, py, "pierre_claire")
	# Rez-de-chaussée : bandeau, vitrine des rotatives, porte
	F._bandeau(img, 0, 222, l, "bois_sombre")
	var r := ROTATIVE
	M.rect(img, r.position.x - 4, r.position.y - 4, r.size.x + 8, r.size.y + 8, "ardoise_sombre")
	M.rect(img, r.position.x - 4, r.position.y - 4, r.size.x + 8, 1, "gris_pierre")
	M.rect(img, r.position.x, r.position.y, r.size.x, r.size.y, "bleu_nuit")
	# Rotative : bâti, cylindres, bande de papier
	M.rect(img, r.position.x + 8, r.position.y + 40, r.size.x - 16, 20, "ardoise")
	M.rect(img, r.position.x + 8, r.position.y + 40, r.size.x - 16, 2, "gris_pierre")
	for k in 4:
		var cx := r.position.x + 22 + k * 28
		for y in range(-8, 9):
			for x in range(-8, 9):
				var d := x * x + y * y
				if d <= 64:
					M.px(img, cx + x, r.position.y + 30 + y, "zinc_clair" if (x < -2 and y < -2) else ("gris_pierre" if d < 36 else "ardoise"))
		M.px(img, cx, r.position.y + 30, "nuit")
	for x in range(r.position.x + 6, r.end.x - 6):
		var yb := r.position.y + 20 + int(3.0 * sin(x * 0.2))
		M.rect(img, x, yb, 1, 2, "blanc_chaud")
	for k in 3:
		M.rect(img, r.position.x + 10 + k * 40, r.position.y + 6, 26, 4, "creme")
		M.rect(img, r.position.x + 10 + k * 40, r.position.y + 6, 26, 1, "blanc_chaud")
	for i in 10:
		M.px(img, r.end.x - 8 - i, r.position.y + 3 + i, "vitre_reflet")
	F.porte(img, 170, 240, "rouge", fen, true, "sombre")
	F._soubassement(img, 0, GAZETTE.y - 9, l, 9)
	return {"image": img, "fenetres": fen}


## Néon rose sous l'enseigne (tube 141 × 5 : vague et deux étoiles), émissif.
static func neon() -> Image:
	var img := M.vide(141, 7)
	for x in 141:
		var y := 3 + roundi(1.5 * sin(x * 0.3))
		M.px(img, x, y, "neon_rose")
	for sx in [3, 137]:
		M.rect(img, sx - 1, 1, 3, 5, "neon_rose")
		M.rect(img, sx - 2, 3, 5, 1, "neon_rose")
	return img


## Enseigne du titre (écran titre) : cadre et pieds, 125 × 30 (les lettres sont dessinées à part).
static func cadre_titre() -> Image:
	var img := M.vide(125, 34)
	M.rect(img, 0, 0, 125, 25, "nuit")
	M.cadre(img, 0, 0, 125, 25, "ardoise")
	M.rect(img, 1, 1, 123, 1, "gris_pierre")
	for px in [24, 98]:
		M.rect(img, px, 25, 3, 9, "ardoise")
	return img


# --- Petits objets des séquences ----------------------------------------------------------------------------

static func _bonk() -> Image:
	var img := M.vide(64, 34)
	var c := Vector2(32, 17)
	for y in 34:
		for x in 64:
			var v := Vector2(x + 0.5, y + 0.5) - c
			var a := atan2(v.y * 1.8, v.x)
			var r := 15.0 + 6.0 * (1.0 if int(round(a / (TAU / 14.0))) % 2 == 0 else 0.0)
			var d := Vector2(v.x, v.y * 1.8).length()
			if d <= r:
				M.px(img, x, y, "or" if d > r - 3.0 else "blanc_chaud")
	M.texte(img, 15, 11, "BONK", "rouge_auvent", 2)
	M.texte(img, 16, 12, "BONK", "brique_sombre", 2)
	M.texte(img, 15, 11, "BONK", "rouge_auvent", 2)
	M.contour(img, "brique_sombre")
	return img


static func _cigogne(image: int) -> Image:
	var img := M.vide(44, 26)
	# Corps, cou, tête, bec orange, pattes repliées
	for y in range(9, 17):
		for x in range(8, 30):
			var dx := (x + 0.5 - 19.0) / 11.0
			var dy := (y + 0.5 - 13.0) / 4.0
			if dx * dx + dy * dy <= 1.0:
				M.px(img, x, y, "blanc_chaud" if dy < 0.3 else "zinc_clair")
	M.rect(img, 29, 9, 6, 2, "blanc_chaud")
	M.rect(img, 33, 7, 4, 4, "blanc_chaud")
	M.px(img, 35, 8, "encre")
	M.rect(img, 37, 9, 7, 1, "orange")
	M.rect(img, 37, 10, 5, 1, "tuile")
	M.rect(img, 1, 14, 8, 1, "orange")
	# Ailes (2 images : hautes / basses), pointes noires
	if image == 0:
		for i in 14:
			M.rect(img, 12 + i, 9 - i / 2, 2, 3, "blanc_chaud" if i < 9 else "nuit")
	else:
		for i in 14:
			M.rect(img, 12 + i, 13 + i / 2, 2, 3, "zinc_clair" if i < 9 else "nuit")
	M.contour(img, "gris_pierre")
	return img


static func _paquet(couleur: String) -> Image:
	var img := M.vide(14, 16)
	M.rect(img, 6, 0, 2, 4, "creme")
	P2.ellipse(img, 7.0, 10.0, 6.5, 5.5, "blanc_chaud", "creme")
	M.rect(img, 1, 8, 12, 2, couleur)
	M.rect(img, 5, 6, 4, 2, couleur)
	M.rect(img, 9, 11, 3, 3, "peau_claire")
	M.contour(img, "pierre_ombre")
	return img


class P2:
	static func ellipse(img: Image, cx: float, cy: float, rx: float, ry: float, nom: String, ombre: String) -> void:
		for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
			for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
				var dx := (x + 0.5 - cx) / rx
				var dy := (y + 0.5 - cy) / ry
				if dx * dx + dy * dy <= 1.0:
					M.px(img, x, y, nom if dx + dy < 0.5 else ombre)


static func _anneau(r: int, nom: String) -> Image:
	var img := M.vide(2 * r + 1, r + 1)
	for y in r + 1:
		for x in 2 * r + 1:
			var d := Vector2(x - r, y - r).length()
			if absf(d - r) < 0.75 and y < r - r / 3:
				M.px(img, x, y, nom)
	return img


## Enregistre les objets des séquences (« objet/… ») : origine au milieu du bas sauf mention.
static func enregistrer_objets() -> void:
	if GrillePixel.existe("objet/bonk"):
		return
	GrillePixel.enregistrer("objet/bonk", _bonk(), Vector2i(32, 17))
	for i in 2:
		GrillePixel.enregistrer("objet/cigogne_%d" % (i + 1), _cigogne(i), Vector2i(22, 13))
	GrillePixel.enregistrer("objet/paquet_rose", _paquet("neon_rose"), Vector2i(7, 0))
	GrillePixel.enregistrer("objet/paquet_bleu", _paquet("ciel"), Vector2i(7, 0))
	for c in ["or", "blanc_chaud", "perte"]:
		for k in 3:
			var r: int = [7, 12, 17][k]
			GrillePixel.enregistrer("objet/onde_%s_%d" % [c, k], _anneau(r, c), Vector2i(r, r))
	# Combiné du téléphone (12 × 6)
	var comb := M.vide(13, 6)
	M.rect(comb, 0, 0, 4, 4, "encre")
	M.rect(comb, 9, 0, 4, 4, "encre")
	M.rect(comb, 2, 3, 9, 2, "encre")
	M.rect(comb, 1, 0, 2, 1, "ardoise")
	M.rect(comb, 10, 0, 2, 1, "ardoise")
	GrillePixel.enregistrer("objet/combine", comb, Vector2i(6, 5))
	# Potelet droit / plié (8 × 30), bande blanche
	for k in 2:
		var p := M.vide(16, 30)
		for y in 30:
			var dx := 0 if k == 0 else int(maxf(0.0, (18.0 - y) * 0.45))
			M.rect(p, 4 + dx, y, 7, 1, "ardoise_sombre")
			M.px(p, 4 + dx, y, "gris_pierre")
			M.px(p, 10 + dx, y, "nuit")
			if y >= 4 and y < 8:
				M.rect(p, 5 + dx, y, 5, 1, "blanc_chaud")
		M.rect(p, 3, 0 if k == 0 else 0, 9 if k == 0 else 0, 2, "ardoise")
		GrillePixel.enregistrer("objet/potelet_%d" % k, p, Vector2i(7, 29))
	# Triangle de signalisation (17 × 15)
	var tri := M.vide(17, 15)
	for y in 13:
		var w := y * 8 / 12
		M.rect(tri, 8 - w, y, 2 * w + 1, 1, "rouge_auvent")
		if y > 4 and y < 11:
			var w2 := (y - 4) * 4 / 7
			M.rect(tri, 8 - w2, y, 2 * w2 + 1, 1, "blanc_chaud")
	M.rect(tri, 2, 13, 13, 2, "ardoise_sombre")
	GrillePixel.enregistrer("objet/triangle", tri)
	# Enjoliveur qui roule (2 images)
	for k in 2:
		var e := M.vide(11, 11)
		P2.ellipse(e, 5.5, 5.5, 5.2, 5.2, "zinc_clair", "gris_pierre")
		if k == 0:
			M.rect(e, 5, 1, 1, 9, "ardoise")
		else:
			M.rect(e, 1, 5, 9, 1, "ardoise")
		GrillePixel.enregistrer("objet/enjoliveur_%d" % k, e)
	# Fumée (3 tailles)
	for k in 3:
		var r := 3 + k * 3
		var f := M.vide(2 * r + 1, 2 * r + 1)
		P2.ellipse(f, r + 0.5, r + 0.5, r, r, "zinc_clair", "gris_pierre")
		GrillePixel.enregistrer("objet/fumee_%d" % k, f, Vector2i(r, r))
	# Enveloppe (15 × 10)
	var env := M.vide(15, 10)
	M.rect(env, 0, 0, 15, 10, "creme")
	M.cadre(env, 0, 0, 15, 10, "pierre_ombre")
	for i in 7:
		M.px(env, i, i * 5 / 7, "pierre_ombre")
		M.px(env, 14 - i, i * 5 / 7, "pierre_ombre")
	M.rect(env, 6, 5, 3, 2, "rouge_auvent")
	GrillePixel.enregistrer("objet/enveloppe", env, Vector2i(7, 5))
	# Capot ouvert (posé sur l'avant de la voiture de Gérard)
	var cap := M.vide(34, 16)
	for y in 16:
		M.rect(cap, 2 + y, 15 - y, 22, 1, "bleu_gris" if y > 1 else "zinc_clair")
	M.contour(cap, "encre")
	GrillePixel.enregistrer("objet/capot", cap, Vector2i(2, 15))
	var sig := M.vide(7, 7)
	M.rect(sig, 2, 0, 3, 7, "or")
	M.rect(sig, 0, 2, 7, 3, "or")
	M.rect(sig, 1, 1, 5, 5, "lumiere")
	M.px(sig, 3, 3, "blanc_chaud")
	GrillePixel.enregistrer("objet/signal", sig, Vector2i(3, 3))
	GrillePixel.enregistrer("edifice/distributeur", distributeur(), Vector2i.ZERO)
	GrillePixel.enregistrer("edifice/neon_gazette", neon(), Vector2i.ZERO)
	GrillePixel.enregistrer("edifice/cadre_titre", cadre_titre(), Vector2i.ZERO)
