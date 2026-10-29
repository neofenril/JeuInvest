extends RefCounted
## Voitures de la rue de briques (lot PX0 bis, docs/16 §8.3 : ≈ 72 × 30, roues de 12 px), de profil,
## tournées vers la droite, dessinées en code dans la palette. Pas de class_name (preload).
## caisse(modele) renvoie {"image", "origine", "roues": [x, x], "phare": Rect2i, "feu": Rect2i} ;
## les roues (roue(image)) sont posées à part pour tourner (2 images). Contour encre, jamais de noir pur.

const M := preload("res://scripts/pixel/matieres.gd")

## Modèles : profil de la caisse (polygone), vitres, roues, couleurs [corps, éclat, ombre].
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
		"couleurs": ["gris_pierre", "zinc_clair", "ardoise"],
		"pare_chocs": "ardoise_sombre",
	},
}


static func _dans(poly: Array, x: int, y: int) -> bool:
	return Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), PackedVector2Array(poly))


## Caisse sans les roues (passages de roue creusés), origine au milieu du bas.
static func caisse(modele: String) -> Dictionary:
	var m: Dictionary = MODELES[modele]
	var t: Vector2i = m["taille"]
	var c: Array = m["couleurs"]
	var img := M.vide(t.x, t.y)
	var profil: Array = m["profil"]
	var bas := int(profil[0].y)
	var roues: Array = m["roues"]
	var cy := t.y - 7                                  # centre des roues (roue de 12, bas en t.y - 1)
	for y in t.y:
		for x in t.x:
			if not _dans(profil, x, y):
				continue
			var arche := false
			for rx in roues:
				var dx: float = x + 0.5 - rx
				var dy: float = y + 0.5 - cy
				if dx * dx + dy * dy < 8.0 * 8.0:
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
		for k in 4:
			M.px(img, vx - k, int(v[0].y) + 1 + k, "blanc_chaud")
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
	M.contour(img, "encre")
	# Intérieur des passages de roue (ombre)
	for rx in roues:
		for y in range(cy - 8, cy + 1):
			for x in range(rx - 8, rx + 9):
				var dx: float = x + 0.5 - rx
				var dy: float = y + 0.5 - cy
				var d := dx * dx + dy * dy
				if d >= 8.0 * 8.0 and d < 9.2 * 9.2 and x >= 0 and x < t.x and img.get_pixel(x, y).a > 0.0:
					M.px(img, x, y, "encre")
	return {"image": img, "origine": Vector2i(t.x / 2, t.y - 1), "roues": roues, "phare": phare, "feu": feu}


## Roue de 12 px : pneu encre / nuit, jante grise, 4 écrous qui tournent (image 0 ou 1).
static func roue(image := 0) -> Image:
	var img := M.vide(12, 12)
	for y in 12:
		for x in 12:
			var dx := x - 5.5
			var dy := y - 5.5
			var d := dx * dx + dy * dy
			if d > 36.0:
				continue
			var nom := "nuit"
			if d > 26.0:
				nom = "encre"
			elif d > 13.0:
				nom = "nuit"
			elif d > 6.0:
				nom = "gris_pierre"
			else:
				nom = "zinc_clair"
			M.px(img, x, y, nom)
	M.rect(img, 5, 5, 2, 2, "ardoise")
	var ecrous := [Vector2i(5, 3), Vector2i(5, 8), Vector2i(3, 5), Vector2i(8, 6)] if image % 2 == 0 \
		else [Vector2i(3, 3), Vector2i(8, 3), Vector2i(3, 8), Vector2i(8, 8)]
	for e in ecrous:
		M.px(img, e.x, e.y, "ardoise_sombre")
	M.px(img, 3, 2, "ardoise")          # reflet du pneu en haut à gauche
	M.px(img, 2, 3, "ardoise")
	return img
