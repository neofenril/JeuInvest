extends RefCounted
## Voitures de la rue de briques (lot PX0 bis, docs/16 §8.3 : ≈ 72 × 30, roues de 12 px), de profil,
## tournées vers la droite, dessinées en code dans la palette. Pas de class_name (preload).
## caisse(modele) renvoie {"image", "origine", "roues": [x, x], "phare": Rect2i, "feu": Rect2i} ;
## les roues (roue(image)) sont posées à part pour tourner (2 images). Contour encre, jamais de noir pur.

const M := preload("res://scripts/pixel/matieres.gd")

## Modèles : profil de la caisse (polygone), vitres, roues, couleurs [corps, éclat, ombre].
## Agrandissement PX0 ter (cadrage plus serré : voitures ≈ 1/7 de la largeur de la vue).
const ECHELLE := 1.3
const ROUE := 16

const MODELES := {
	# Renault 5 rouge : hayon presque vertical, pare-chocs en plastique gris foncé
	"r5": {
		"taille": Vector2i(72, 30),
		"profil": [Vector2(1, 24), Vector2(1, 13), Vector2(5, 12), Vector2(10, 3), Vector2(45, 3), Vector2(55, 12),
			Vector2(69, 14), Vector2(71, 16), Vector2(71, 24)],
		"vitres": [[Vector2(12, 5), Vector2(25, 5), Vector2(25, 12), Vector2(9, 12)],
			[Vector2(28, 5), Vector2(44, 5), Vector2(51, 12), Vector2(28, 12)]],
		"roues": [15, 57],
		"couleurs": ["rouge_auvent", "tuile", "brique"],
		"pare_chocs": "ardoise_sombre",
	},
	# Peugeot 205 grise : malle courte, lunette inclinée
	"205": {
		"taille": Vector2i(70, 32),
		"profil": [Vector2(1, 26), Vector2(1, 15), Vector2(4, 13), Vector2(12, 4), Vector2(41, 4), Vector2(52, 14),
			Vector2(67, 16), Vector2(69, 18), Vector2(69, 26)],
		"vitres": [[Vector2(14, 6), Vector2(27, 6), Vector2(27, 13), Vector2(9, 13)],
			[Vector2(30, 6), Vector2(40, 6), Vector2(48, 13), Vector2(30, 13)]],
		"roues": [14, 56],
		"couleurs": ["bleu_gris", "zinc_clair", "ombre_froide"],
		"pare_chocs": "ardoise_sombre",
	},
}


static func _dans(poly: Array, x: int, y: int) -> bool:
	return Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), PackedVector2Array(poly))


## Caisse sans les roues (passages de roue creusés), origine au milieu du bas.
static func caisse(modele: String) -> Dictionary:
	var m0: Dictionary = MODELES[modele]
	var k := ECHELLE
	var m := {"pare_chocs": m0["pare_chocs"], "couleurs": m0["couleurs"]}
	m["taille"] = Vector2i(roundi(m0["taille"].x * k), roundi(m0["taille"].y * k))
	m["profil"] = (m0["profil"] as Array).map(func(p): return (p * k).round())
	m["vitres"] = (m0["vitres"] as Array).map(func(v): return (v as Array).map(func(p): return (p * k).round()))
	m["roues"] = (m0["roues"] as Array).map(func(x): return roundi(x * k))
	var t: Vector2i = m["taille"]
	var c: Array = m["couleurs"]
	var img := M.vide(t.x, t.y)
	var profil: Array = m["profil"]
	var bas := int(profil[0].y)
	var roues: Array = m["roues"]
	var ra := ROUE / 2.0 + 2.0                         # rayon du passage de roue
	var cy := t.y - ROUE / 2 - 1                       # centre des roues (bas en t.y - 1)
	for y in t.y:
		for x in t.x:
			if not _dans(profil, x, y):
				continue
			var arche := false
			for rx in roues:
				var dx: float = x + 0.5 - rx
				var dy: float = y + 0.5 - cy
				if dx * dx + dy * dy < ra * ra:
					arche = true
			if arche:
				continue
			var nom: String = c[0]
			if y >= bas - 3:
				nom = c[2]                              # bas de caisse dans l'ombre
			M.px(img, x, y, nom)
	# Arête éclairée (ligne de caisse) et reflet du toit
	var ligne := int(profil[2].y) + 3
	for x in t.x:
		if img.get_pixel(x, ligne).a > 0.0:
			M.px(img, x, ligne, c[1])
	for x in range(int(profil[3].x) + 2, int(profil[4].x) - 2):
		M.px(img, x, int(profil[3].y) + 1, c[1])
	# Vitres : ciel clair, reflet, montants
	for v in m["vitres"]:
		for y in t.y:
			for x in t.x:
				if _dans(v, x, y):
					M.px(img, x, y, "ciel_clair" if y > int(v[0].y) + 1 else "ciel")
		var vx := int(v[1].x) - 4
		for e in 4:
			M.px(img, vx - e, int(v[0].y) + 1 + e, "blanc_chaud")
	# Portière, poignée, rétroviseur
	var porte_x := int(m["vitres"][1][0].x) - 1
	M.rect(img, porte_x, int(profil[2].y) + 1, 1, bas - int(profil[2].y) - 4, c[2])
	var avant := int(m["vitres"][1][2].x) + 1
	M.rect(img, avant, int(profil[2].y) + 1, 1, bas - int(profil[2].y) - 4, c[2])
	M.rect(img, avant - 6, ligne + 2, 3, 1, "encre")
	M.rect(img, avant - 2, int(m["vitres"][1][2].y) - 2, 3, 2, c[2])
	# Pare-chocs, phare, feu arrière
	M.rect(img, 0, bas - 5, 6, 3, m["pare_chocs"])
	M.rect(img, t.x - 6, bas - 5, 6, 3, m["pare_chocs"])
	var phare := Rect2i(t.x - 3, int(profil[7].y) + 1, 2, 3)
	M.rect(img, phare.position.x, phare.position.y, phare.size.x, phare.size.y, "blanc_chaud")
	var feu := Rect2i(1, int(profil[1].y) + 1, 2, 3)
	M.rect(img, feu.position.x, feu.position.y, feu.size.x, feu.size.y, "orange")
	# Face avant vue de trois-quarts (à l'ombre : le soleil est en haut à gauche) : calandre, phare rond
	var fx := t.x - 8
	var fy := int(profil[7].y)
	for y in range(fy, bas - 2):
		for x in range(fx, t.x):
			if img.get_pixel(x, y).a > 0.0:
				M.px(img, x, y, c[2])
	M.rect(img, fx, fy, 8, 1, c[1])
	M.rect(img, fx + 1, fy + 2, 4, 4, "blanc_chaud")
	M.rect(img, fx + 2, fy + 3, 2, 2, "zinc_clair")
	for y in range(fy + 7, bas - 4, 2):
		M.rect(img, fx + 1, y, 6, 1, "nuit")
	M.rect(img, fx - 1, fy, 1, bas - fy - 2, c[1])
	phare = Rect2i(fx + 1, fy + 2, 4, 4)
	M.contour(img, "encre")
	# Intérieur des passages de roue (ombre)
	for rx in roues:
		for y in range(cy - int(ra), cy + 1):
			for x in range(rx - int(ra), rx + int(ra) + 1):
				var dx: float = x + 0.5 - rx
				var dy: float = y + 0.5 - cy
				var d := dx * dx + dy * dy
				if d >= ra * ra and d < (ra + 1.2) * (ra + 1.2) and x >= 0 and x < t.x and img.get_pixel(x, y).a > 0.0:
					M.px(img, x, y, "encre")
	return {"image": img, "origine": Vector2i(t.x / 2, t.y - 1), "roues": roues, "phare": phare, "feu": feu}


## Roue de 12 px : pneu encre / nuit, jante grise, 4 écrous qui tournent (image 0 ou 1).
static func roue(image := 0) -> Image:
	var n := ROUE
	var img := M.vide(n, n)
	var c := (n - 1) / 2.0
	var r := n / 2.0
	for y in n:
		for x in n:
			var dx := x - c
			var dy := y - c
			var d := sqrt(dx * dx + dy * dy)
			if d > r:
				continue
			var nom := "nuit"
			if d > r - 1.2:
				nom = "encre"
			elif d > r * 0.62:
				nom = "nuit"
			elif d > r * 0.4:
				nom = "gris_pierre"
			else:
				nom = "zinc_clair"
			M.px(img, x, y, nom)
	var m := n / 2
	M.rect(img, m - 1, m - 1, 2, 2, "ardoise")
	var ecrous := [Vector2i(m - 1, m - 3), Vector2i(m, m + 2), Vector2i(m - 3, m), Vector2i(m + 2, m - 1)] if image % 2 == 0 \
		else [Vector2i(m - 3, m - 3), Vector2i(m + 2, m - 3), Vector2i(m - 3, m + 2), Vector2i(m + 2, m + 2)]
	for e in ecrous:
		M.px(img, e.x, e.y, "ardoise_sombre")
	M.px(img, 3, 2, "ardoise")          # reflet du pneu en haut à gauche
	M.px(img, 2, 3, "ardoise")
	M.px(img, 4, 1, "ardoise")
	return img
