extends RefCounted
## Façades et décor de la rue générés en code (docs/16 §1.3, §2.2, §2.4, §4.4), dans la palette « Rue 84 ».
## Pas de class_name (lot PX0 §2) : chargé par preload("res://scripts/pixel/facades.gd").
## Chaque générateur est déterministe (graine) et renvoie {"image": Image, "fenetres": [Rect2i]} :
## les fenêtres (coordonnées locales) s'allument la nuit (couleur lumiere, posée par RuePx0).
## Règles de dessin : lumière en haut à gauche ; contour des bâtiments dans le ton le plus sombre de
## leur matière ; corniches et appuis = 1 ligne claire + 1 ligne sombre (ombre portée) ; calme en haut,
## détails en bas.

const M := preload("res://scripts/pixel/matieres.gd")


# --- Maison de Gérard : pavillon en meulière, 96 × 124 (cheminée comprise) -------------------------

const MAISON_L := 96
const MAISON_H := 124
const FENETRE_SYLVIE := Rect2i(16, 54, 18, 22)     # fenêtre de l'étage, à gauche
const PORTE := Rect2i(56, 84, 14, 28)


static func maison_gerard(graine := 7) -> Dictionary:
	var img := M.vide(MAISON_L, MAISON_H)
	var fen: Array = []
	# Murs en meulière, x 4..91, y 46..115
	M.coller(img, M.meuliere(88, 70, graine), 4, 46)
	# Chaînes d'angle en brique (harpes alternées 4 / 6 px)
	for y in range(46, 116):
		var k := (y - 46) / 4
		var lw := 4 if k % 2 == 0 else 6
		var jy := (y - 46) % 4
		for x in lw:
			var nom := "brique_sombre" if jy == 3 else ("tuile" if jy == 0 else "brique")
			M.px(img, 4 + x, y, nom)
			M.px(img, 91 - x, y, "brique_sombre" if jy == 3 or x == 0 else "brique")
	# Bandeau de brique entre les étages
	M.rect(img, 4, 80, 88, 1, "tuile")
	M.rect(img, 4, 81, 88, 1, "brique")
	M.rect(img, 4, 82, 88, 1, "brique_sombre")
	# Soubassement de pierre (y 112..123), arête éclairée
	M.rect(img, 2, 112, 92, 12, "pierre_ombre")
	M.rect(img, 2, 112, 92, 1, "pierre")
	for x in range(2, 94, 7):
		M.rect(img, x, 113 + (x / 7) % 2 * 5, 1, 5, "bois")
	M.rect(img, 2, 118, 92, 1, "bois")
	# Toit de tuiles mécaniques en trapèze (y 12..45), débord sur toute la largeur en bas
	var tuiles := M.tuiles(96, 34, graine + 1)
	for j in 34:
		var retrait := (33 - j) / 2
		for i in range(retrait, 96 - retrait):
			img.set_pixel(i, 12 + j, tuiles.get_pixel(i, j))
		M.px(img, retrait, 12 + j, "brique_sombre")
		M.px(img, 95 - retrait, 12 + j, "brique_sombre")
		if j > 0 and (33 - j) % 2 == 1:
			M.px(img, retrait + 1, 12 + j, "terre_cuite_claire")   # rive éclairée (côté gauche)
	# Faîtage : tuiles faîtières
	M.rect(img, 16, 11, 64, 2, "brique")
	for x in range(16, 80, 4):
		M.px(img, x, 11, "tuile")
		M.px(img, x + 1, 11, "tuile")
	M.rect(img, 16, 10, 64, 1, "brique_sombre")
	# Gouttière (zinc) et ombre portée du débord sur le mur
	M.rect(img, 0, 44, 96, 1, "zinc_clair")
	M.rect(img, 0, 45, 96, 1, "ardoise")
	M.rect(img, 4, 46, 88, 2, "pierre_ombre")
	M.rect(img, 4, 48, 88, 1, "caramel")
	# Lucarne au milieu du toit (x 41..54)
	_lucarne_maison(img, 41, 18, fen)
	# Cheminée de brique à droite, poteries
	var ch := M.brique(10, 18, graine + 2)
	M.coller(img, ch, 70, 4)
	M.rect(img, 70, 4, 1, 18, "tuile")
	M.rect(img, 79, 4, 1, 18, "brique_sombre")
	M.rect(img, 68, 3, 14, 2, "gris_pierre")
	M.rect(img, 68, 3, 14, 1, "zinc_clair")
	M.rect(img, 68, 5, 14, 1, "ardoise")
	M.rect(img, 72, 0, 2, 3, "orange")
	M.px(img, 72, 0, "terre_cuite_claire")
	M.rect(img, 76, 0, 2, 3, "orange")
	M.px(img, 77, 0, "brique")
	M.px(img, 77, 1, "brique")
	# Fenêtres de l'étage (Sylvie à gauche), du rez-de-chaussée, de la cuisine
	_fenetre_maison(img, FENETRE_SYLVIE.position.x, FENETRE_SYLVIE.position.y, 18, 22, true, fen)
	_fenetre_maison(img, 60, 54, 18, 22, false, fen)
	_fenetre_maison(img, 16, 88, 18, 22, false, fen)
	_fenetre_maison(img, 78, 90, 8, 12, false, fen, false)
	# Porte d'entrée et marquise
	_porte_maison(img, fen)
	# Boîte aux lettres à droite de la porte
	M.rect(img, 72, 94, 5, 5, "vert_sombre")
	M.rect(img, 72, 94, 5, 1, "vert")
	M.rect(img, 73, 96, 3, 1, "encre")
	M.cadre(img, 71, 93, 7, 7, "nuit")
	M.rect(img, 72, 100, 5, 1, "pierre_ombre")
	# Numéro de rue émaillé (plaque bleue 5 × 4) au-dessus de la boîte
	M.rect(img, 73, 87, 4, 3, "bleu_vif")
	M.px(img, 74, 88, "blanc_chaud")
	M.px(img, 75, 88, "blanc_chaud")
	return {"image": img, "fenetres": fen}


static func _lucarne_maison(img: Image, x: int, y: int, fen: Array) -> void:
	# Fronton triangulaire de tuiles, joues en meulière claire, fenêtre 8 × 10
	for j in 8:
		var r := 7 - j
		M.rect(img, x + r, y + j, 14 - 2 * r, 1, "tuile" if j % 3 != 2 else "brique")
		M.px(img, x + r, y + j, "brique_sombre")
		M.px(img, x + 13 - r, y + j, "brique_sombre")
	M.rect(img, x + 1, y + 8, 12, 14, "pierre")
	M.rect(img, x + 1, y + 8, 1, 14, "pierre_claire")
	M.rect(img, x + 12, y + 8, 1, 14, "pierre_ombre")
	M.rect(img, x, y + 7, 14, 1, "brique_sombre")
	M.rect(img, x + 3, y + 10, 8, 10, "blanc_chaud")
	M.rect(img, x + 4, y + 11, 6, 8, "bleu_ardoise")
	M.rect(img, x + 4, y + 11, 6, 1, "bleu_nuit")
	M.rect(img, x + 7, y + 11, 1, 8, "blanc_chaud")
	M.px(img, x + 9, y + 12, "ciel_clair")
	M.rect(img, x + 2, y + 20, 10, 1, "pierre_claire")
	M.rect(img, x + 2, y + 21, 10, 1, "pierre_ombre")
	fen.append(Rect2i(x + 4, y + 11, 6, 8))


static func _fenetre_maison(img: Image, x: int, y: int, l: int, h: int, sylvie: bool, fen: Array, volets := true) -> void:
	# Linteau de brique en éventail
	M.rect(img, x - 1, y - 3, l + 2, 3, "brique")
	M.rect(img, x - 1, y - 3, l + 2, 1, "tuile")
	for i in range(x, x + l, 3):
		M.rect(img, i, y - 2, 1, 2, "brique_sombre")
	# Volets battants ouverts (persiennes bleu-vert) de part et d'autre
	if volets:
		for v in [x - 9, x + l]:
			M.rect(img, v, y, 9, h, "vert_sombre")
			for j in range(y + 2, y + h - 1, 2):
				M.rect(img, v + 1, j, 7, 1, "vert")
			M.cadre(img, v, y, 9, h, "nuit")
			M.rect(img, v + 1, y + 1, 1, h - 2, "vert")       # arête éclairée à gauche
			M.px(img, v if v > x else v + 8, y + 3, "encre")   # pentures
			M.px(img, v if v > x else v + 8, y + h - 4, "encre")
	# Dormant blanc
	M.rect(img, x, y, l, h, "blanc_chaud")
	if sylvie:
		# Fenêtre ouverte : pièce sombre, rideaux crème ; Sylvie est posée par RuePx0 (buste 12 × 14)
		M.rect(img, x + 1, y + 1, l - 2, h - 2, "bleu_nuit")
		M.rect(img, x + 1, y + 1, l - 2, 1, "nuit")
		M.rect(img, x + 1, y + 1, 2, h - 2, "creme")
		M.rect(img, x + l - 3, y + 1, 2, h - 2, "creme")
		M.rect(img, x + 2, y + 1, 1, h - 2, "pierre_claire")
		M.rect(img, x + l - 2, y + 1, 1, h - 2, "pierre_claire")
		fen.append(Rect2i(x + 3, y + 1, l - 6, h - 2))
	else:
		var gl := Rect2i(x + 1, y + 1, l - 2, h - 2)
		M.rect(img, gl.position.x, gl.position.y, gl.size.x, gl.size.y, "bleu_ardoise")
		M.rect(img, gl.position.x, gl.position.y, gl.size.x, 1, "bleu_nuit")
		M.rect(img, gl.position.x, gl.position.y, 1, gl.size.y, "bleu_nuit")
		# Petits bois : meneau central et traverses
		var mx := x + l / 2
		M.rect(img, mx, y, 1, h, "blanc_chaud")
		for t in range(y + h / 3, y + h - 2, h / 3):
			M.rect(img, x, t, l, 1, "blanc_chaud")
		# Reflets en diagonale (2 px) en haut à droite de chaque battant
		for bx in [mx - 2, x + l - 3]:
			M.px(img, bx, y + 2, "ciel_clair")
			M.px(img, bx - 1, y + 3, "ciel_clair")
		fen.append(gl)
	# Appui : ligne claire + ombre portée
	M.rect(img, x - 1, y + h, l + 2, 1, "pierre_claire")
	M.rect(img, x, y + h + 1, l, 1, "pierre_ombre")


static func _porte_maison(img: Image, fen: Array) -> void:
	var x := PORTE.position.x
	var y := PORTE.position.y
	var l := PORTE.size.x
	var h := PORTE.size.y
	# Encadrement de pierre claire
	M.rect(img, x - 2, y - 1, l + 4, h + 1, "pierre_claire")
	M.rect(img, x + l + 1, y - 1, 1, h + 1, "pierre_ombre")
	# Porte de bois : panneau vitré en haut avec grille de fer, panneaux moulurés en bas
	M.rect(img, x, y, l, h, "bois")
	M.cadre(img, x, y, l, h, "bois_sombre")
	M.rect(img, x + 1, y + 1, 1, h - 2, "caramel")
	M.rect(img, x + 3, y + 3, l - 6, 10, "bleu_nuit")
	for j in range(y + 4, y + 13, 3):
		M.rect(img, x + 3, j, l - 6, 1, "encre")
	for i in range(x + 4, x + l - 3, 3):
		M.rect(img, i, y + 3, 1, 10, "encre")
	fen.append(Rect2i(x + 3, y + 3, l - 6, 10))
	M.cadre(img, x + 3, y + 15, l - 6, 5, "bois_sombre")
	M.cadre(img, x + 3, y + 21, l - 6, 5, "bois_sombre")
	M.rect(img, x + 4, y + 16, l - 8, 1, "caramel")
	M.rect(img, x + 4, y + 22, l - 8, 1, "caramel")
	M.px(img, x + l - 3, y + 15, "or")
	# Seuil (deux marches)
	M.rect(img, x - 3, y + h, l + 6, 2, "gris_pierre")
	M.rect(img, x - 3, y + h, l + 6, 1, "zinc_clair")
	M.rect(img, x - 5, y + h + 2, l + 10, 2, "gris_pierre")
	M.rect(img, x - 5, y + h + 2, l + 10, 1, "zinc_clair")
	# Marquise : verrière en éventail sur consoles de fer
	var mx := x - 5
	var my := y - 8
	var ml := l + 10
	for j in 6:
		var r := maxi(0, 2 - j)
		M.rect(img, mx + r, my + j, ml - 2 * r, 1, "ciel_clair" if j % 2 == 0 else "zinc_clair")
	M.rect(img, mx, my + 5, ml, 1, "encre")
	for i in range(mx + 2, mx + ml - 1, 4):
		M.rect(img, i, my + 1, 1, 4, "ardoise_sombre")
	M.rect(img, mx + 2, my, ml - 4, 1, "ardoise_sombre")
	M.px(img, mx, my + 6, "encre")
	M.px(img, mx + ml - 1, my + 6, "encre")
	M.rect(img, mx + 1, my + 6, ml - 2, 1, "pierre_ombre")     # ombre portée de la marquise
	M.px(img, mx + 1, my + 7, "encre")
	M.px(img, mx + ml - 2, my + 7, "encre")


# --- Immeuble haussmannien ------------------------------------------------------------------------
# rdc : "porte" (porte cochère), "boulangerie" (auvent rayé), "pharmacie" (croix verte), "tabac".

static func haussmann(largeur: int, etages: int, graine := 0, rdc := "porte") -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var h_rdc := 38
	var h_etage := 28
	var h_comble := 30
	var h := h_comble + 5 + etages * h_etage + h_rdc
	var img := M.vide(largeur, h)
	var fen: Array = []
	var y_corniche := h_comble
	var y_etages := h_comble + 5
	var y_rdc := h - h_rdc
	# Façade de pierre de taille, refends au rez-de-chaussée
	M.coller(img, M.pierre_taille(largeur, h - y_etages, graine), 0, y_etages)
	M.coller(img, M.pierre_taille(largeur, h_rdc, graine, true), 0, y_rdc)
	# Travées
	var n := maxi(2, (largeur - 8) / 22)
	var tw := float(largeur) / n
	var xs: Array = []
	for i in n:
		xs.append(int(round(i * tw + tw / 2.0)) - 4)
	# Étages
	for e in etages:
		var y0 := y_etages + e * h_etage
		var balcon_filant := e == 0 or e == etages - 1
		# Cordon sous chaque étage
		M.rect(img, 0, y0 + h_etage - 2, largeur, 1, "blanc_chaud")
		M.rect(img, 0, y0 + h_etage - 1, largeur, 1, "pierre")
		for x in xs:
			var lit := _fenetre_haussmann(img, x, y0 + 6, 8, 18, not balcon_filant, rng)
			fen.append(lit)
		if balcon_filant:
			_balcon(img, 1, y0 + 19, largeur - 2)
	# Corniche
	M.rect(img, 0, y_corniche, largeur, 1, "blanc_chaud")
	M.rect(img, 0, y_corniche + 1, largeur, 2, "pierre_claire")
	for x in range(1, largeur, 3):
		M.px(img, x, y_corniche + 2, "pierre")                # modillons
	M.rect(img, 0, y_corniche + 3, largeur, 1, "pierre_ombre")
	M.rect(img, 0, y_corniche + 4, largeur, 1, "pierre")
	# Comble à la Mansart (zinc), lucarnes et souches de cheminée
	var zinc := M.zinc(largeur, h_comble, graine)
	for j in range(8, h_comble):
		var retrait := (h_comble - 1 - j) / 6
		for i in range(retrait, largeur - retrait):
			img.set_pixel(i, j, zinc.get_pixel(i, j))
		M.px(img, retrait, j, "ardoise")
		M.px(img, largeur - 1 - retrait, j, "ardoise_sombre")
	M.rect(img, 3, 8, largeur - 6, 1, "zinc_clair")
	M.rect(img, 3, 7, largeur - 6, 1, "ardoise")
	for x in xs:
		_lucarne_zinc(img, x - 1, 13, fen)
	for c in [rng.randi_range(4, 10), largeur - rng.randi_range(14, 20)]:
		_souche(img, c, 0, rng)
	# Rez-de-chaussée
	match rdc:
		"boulangerie":
			_boutique(img, y_rdc, largeur, "bleu_ardoise", true, fen, rng)
		"pharmacie":
			_boutique(img, y_rdc, largeur, "vert_sombre", false, fen, rng)
			_croix_pharmacie(img, largeur - 9, y_rdc + 2)
		"tabac":
			_boutique(img, y_rdc, largeur, "rouge_auvent", false, fen, rng, true)
		_:
			_porte_cochere(img, y_rdc, largeur, xs, fen)
	# Bandeau au-dessus du rez-de-chaussée (forte corniche)
	M.rect(img, 0, y_rdc - 2, largeur, 1, "blanc_chaud")
	M.rect(img, 0, y_rdc - 1, largeur, 1, "pierre_claire")
	M.rect(img, 0, y_rdc, largeur, 1, "pierre_ombre")
	# Contour : arêtes de la façade
	M.rect(img, 0, y_etages, 1, h - y_etages, "pierre_claire")
	M.rect(img, largeur - 1, y_etages, 1, h - y_etages, "pierre_ombre")
	return {"image": img, "fenetres": fen}


## Fenêtre haussmannienne 8 × 18 : embrasure sombre, deux battants, imposte, appui, garde-corps.
static func _fenetre_haussmann(img: Image, x: int, y: int, l: int, h: int, garde_corps: bool, _rng: RandomNumberGenerator) -> Rect2i:
	# Encadrement mouluré et linteau à clé
	M.rect(img, x - 1, y - 2, l + 2, 2, "blanc_chaud")
	M.rect(img, x + l / 2 - 1, y - 3, 2, 3, "blanc_chaud")
	M.rect(img, x - 1, y, 1, h, "blanc_chaud")
	M.rect(img, x + l, y, 1, h, "pierre")
	M.rect(img, x, y, l, h, "bleu_ardoise")
	M.rect(img, x, y, l, 1, "nuit")
	M.rect(img, x, y, 1, h, "nuit")
	M.rect(img, x + l / 2, y, 1, h, "creme")
	M.rect(img, x, y + 5, l, 1, "creme")
	M.px(img, x + l - 2, y + 7, "ciel_clair")
	M.px(img, x + l - 3, y + 8, "ciel_clair")
	M.px(img, x + 2, y + 7, "ciel")
	if garde_corps:
		M.rect(img, x, y + h - 5, l, 1, "nuit")
		for i in range(x, x + l, 2):
			M.rect(img, i, y + h - 4, 1, 3, "nuit")
	M.rect(img, x - 1, y + h, l + 2, 1, "blanc_chaud")
	M.rect(img, x, y + h + 1, l, 1, "pierre_ombre")
	return Rect2i(x + 1, y + 1, l - 1, h - 1)


static func _balcon(img: Image, x: int, y: int, l: int) -> void:
	M.rect(img, x, y, l, 1, "encre")
	for i in range(x, x + l, 2):
		M.rect(img, i, y + 1, 1, 3, "nuit")
	for i in range(x + 1, x + l, 4):
		M.px(img, i, y + 2, "nuit")
	M.rect(img, x - 1, y + 4, l + 2, 1, "blanc_chaud")
	M.rect(img, x - 1, y + 5, l + 2, 1, "pierre")
	M.rect(img, x, y + 6, l, 1, "pierre_ombre")


static func _lucarne_zinc(img: Image, x: int, y: int, fen: Array) -> void:
	# Lucarne de pierre 10 × 14 à fronton cintré
	M.rect(img, x + 2, y - 2, 6, 1, "pierre_claire")
	M.rect(img, x + 1, y - 1, 8, 1, "pierre_claire")
	M.rect(img, x, y, 10, 14, "pierre_claire")
	M.rect(img, x + 9, y, 1, 14, "pierre_ombre")
	M.rect(img, x, y, 10, 1, "blanc_chaud")
	M.rect(img, x + 2, y + 3, 6, 9, "bleu_ardoise")
	M.rect(img, x + 2, y + 3, 6, 1, "nuit")
	M.rect(img, x + 5, y + 3, 1, 9, "creme")
	M.rect(img, x + 1, y + 12, 8, 1, "blanc_chaud")
	M.rect(img, x + 1, y + 13, 8, 1, "pierre_ombre")
	fen.append(Rect2i(x + 2, y + 4, 6, 8))


static func _souche(img: Image, x: int, y: int, rng: RandomNumberGenerator) -> void:
	M.coller(img, M.brique(10, 9, rng.randi()), x, y + 2)
	M.rect(img, x, y + 2, 1, 9, "tuile")
	M.rect(img, x + 9, y + 2, 1, 9, "brique_sombre")
	M.rect(img, x - 1, y + 2, 12, 1, "pierre_claire")
	M.rect(img, x - 1, y + 3, 12, 1, "pierre_ombre")
	for p in range(x + 1, x + 9, 3):
		M.rect(img, p, y, 2, 2, "orange")
		M.px(img, p, y, "terre_cuite_claire")


## Devanture de commerce : bandeau peint, auvent rayé (boulangerie) ou vitrine à rideaux (café).
static func _boutique(img: Image, y: int, l: int, peinture: String, auvent: bool, fen: Array, rng: RandomNumberGenerator, cafe := false) -> void:
	var h := img.get_height() - y
	# Devanture de bois peint
	M.rect(img, 2, y + 3, l - 4, h - 3, peinture)
	M.rect(img, 2, y + 3, l - 4, 1, "blanc_chaud")
	M.rect(img, 2, y + 3, 1, h - 3, "blanc_chaud")
	M.rect(img, l - 3, y + 3, 1, h - 3, "nuit")
	# Bandeau d'enseigne (sans texte : filet or)
	M.rect(img, 4, y + 5, l - 8, 6, "nuit")
	M.rect(img, 5, y + 7, l - 10, 1, "or")
	M.rect(img, 5, y + 9, l - 10, 1, "ambre" if peinture == "vert_sombre" else "or")
	# Vitrine et porte
	var vx := 6
	var vl := l - 26
	var vy := y + 14
	var vh := h - 18
	M.rect(img, vx - 1, vy - 1, vl + 2, vh + 2, "blanc_chaud")
	M.rect(img, vx, vy, vl, vh, "bleu_ardoise")
	M.rect(img, vx, vy, vl, 2, "bleu_nuit")
	for k in 3:
		M.px(img, vx + vl - 3 - k, vy + 2 + k, "ciel_clair")
	fen.append(Rect2i(vx, vy, vl, vh))
	if cafe:
		# Rideaux bistrot à mi-hauteur
		M.rect(img, vx, vy + vh / 2, vl, vh - vh / 2, "creme")
		for i in range(vx, vx + vl, 3):
			M.px(img, i, vy + vh / 2, "blanc_chaud")
		M.rect(img, vx, vy + vh / 2 - 1, vl, 1, "or")
	elif auvent:
		# Pains sur l'étagère
		for i in range(vx + 2, vx + vl - 4, 6):
			M.rect(img, i, vy + vh - 6, 4, 2, "caramel")
			M.rect(img, i, vy + vh - 6, 3, 1, "terre_cuite_claire")
		M.rect(img, vx, vy + vh - 4, vl, 1, "bois")
	else:
		# Pharmacie : flacons
		for i in range(vx + 2, vx + vl - 3, 5):
			M.rect(img, i, vy + vh - 7, 2, 4, "blanc_chaud" if (i / 5) % 2 == 0 else "gain_papier")
	# Soubassement de la vitrine
	M.rect(img, vx, vy + vh + 1, vl, h - (vy - y) - vh - 1, "nuit")
	# Porte vitrée
	var px0 := l - 17
	M.rect(img, px0, y + 13, 11, h - 13, "bois_sombre")
	M.rect(img, px0 + 2, y + 15, 7, h - 22, "bleu_ardoise")
	M.rect(img, px0 + 2, y + 15, 7, 1, "bleu_nuit")
	M.px(img, px0 + 7, y + 17, "ciel_clair")
	fen.append(Rect2i(px0 + 2, y + 16, 7, h - 23))
	M.px(img, px0 + 1, y + 25, "or")
	if auvent:
		# Auvent rayé rouge et blanc, bord festonné, ombre portée
		var ay := y + 12
		for j in 5:
			for i in range(1, l - 1):
				var bande := ((i + j / 2) / 3) % 2 == 0
				M.px(img, i, ay + j, "rouge_auvent" if bande else "blanc_chaud")
		for i in range(1, l - 1):
			if (i / 3) % 2 == 0:
				M.px(img, i, ay + 5, "rouge_auvent")
		M.rect(img, 1, ay - 1, l - 2, 1, "brique_sombre")
		M.rect(img, 2, ay + 6, l - 4, 2, "nuit")


static func _croix_pharmacie(img: Image, x: int, y: int) -> void:
	# Croix verte (émissive, couleur gain) sur potence, contour encre
	M.rect(img, x - 1, y + 2, 9, 3, "encre")
	M.rect(img, x + 2, y - 1, 3, 9, "encre")
	M.rect(img, x, y + 3, 7, 1, "gain")
	M.rect(img, x + 3, y, 1, 7, "gain")
	M.rect(img, x + 3, y + 8, 1, 2, "encre")


static func _porte_cochere(img: Image, y: int, l: int, xs: Array, fen: Array) -> void:
	var h := img.get_height() - y
	var cx := l / 2
	var pl := 18
	var px0 := cx - pl / 2
	# Arc et vantaux de bois
	M.rect(img, px0 - 2, y + 6, pl + 4, h - 6, "blanc_chaud")
	M.rect(img, px0, y + 8, pl, h - 8, "bois")
	M.rect(img, px0 + 2, y + 6, pl - 4, 2, "bois")
	M.rect(img, px0, y + 8, pl, 1, "bois_sombre")
	M.rect(img, cx, y + 8, 1, h - 8, "bois_sombre")
	for v in [px0 + 2, cx + 2]:
		M.cadre(img, v, y + 11, pl / 2 - 4, 10, "bois_sombre")
		M.cadre(img, v, y + 23, pl / 2 - 4, h - 26, "bois_sombre")
		M.rect(img, v + 1, y + 12, 1, 8, "caramel")
	M.px(img, cx - 2, y + 22, "or")
	M.px(img, cx + 2, y + 22, "or")
	# Fenêtres du rez-de-chaussée à grilles
	for x in xs:
		if absi(x + 4 - cx) < pl / 2 + 6:
			continue
		M.rect(img, x - 1, y + 9, 10, 20, "blanc_chaud")
		M.rect(img, x, y + 10, 8, 18, "bleu_ardoise")
		M.rect(img, x, y + 10, 8, 1, "bleu_nuit")
		for i in range(x, x + 8, 2):
			M.rect(img, i, y + 10, 1, 18, "nuit")
		M.rect(img, x - 1, y + 28, 10, 1, "blanc_chaud")
		M.rect(img, x, y + 29, 8, 1, "pierre_ombre")
		fen.append(Rect2i(x, y + 10, 8, 18))


# --- Immeuble de brique (faubourg) -----------------------------------------------------------------

static func immeuble_brique(largeur: int, etages: int, graine := 0, rdc := "tabac") -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var h_rdc := 38
	var h_etage := 26
	var h_toit := 18
	var h := h_toit + etages * h_etage + h_rdc
	var img := M.vide(largeur, h)
	var fen: Array = []
	M.coller(img, M.brique(largeur, h - h_toit, graine), 0, h_toit)
	# Toit d'ardoise à faible pente avec débord
	var ard := M.ardoise(largeur + 4, h_toit, graine)
	for j in range(6, h_toit):
		var retrait := (h_toit - 1 - j) / 3
		for i in range(retrait, largeur - retrait):
			img.set_pixel(i, j, ard.get_pixel(i, j))
		M.px(img, retrait, j, "ardoise")
	M.rect(img, 2, 6, largeur - 4, 1, "gris_pierre")
	M.rect(img, 0, h_toit - 1, largeur, 1, "zinc_clair")
	M.rect(img, 0, h_toit, largeur, 2, "brique_sombre")
	_souche(img, largeur - 16, 0, rng)
	var n := maxi(2, (largeur - 8) / 20)
	var tw := float(largeur) / n
	for e in etages:
		var y0 := h_toit + e * h_etage
		for i in n:
			var x := int(round(i * tw + tw / 2.0)) - 4
			# Linteau de pierre, fenêtre à petits carreaux, appui
			M.rect(img, x - 1, y0 + 5, 10, 2, "pierre_claire")
			M.rect(img, x - 1, y0 + 6, 10, 1, "pierre")
			M.rect(img, x, y0 + 7, 8, 14, "blanc_chaud")
			M.rect(img, x + 1, y0 + 8, 6, 12, "bleu_ardoise")
			M.rect(img, x + 1, y0 + 8, 6, 1, "bleu_nuit")
			M.rect(img, x + 4, y0 + 8, 1, 12, "blanc_chaud")
			M.rect(img, x + 1, y0 + 13, 6, 1, "blanc_chaud")
			M.px(img, x + 6, y0 + 9, "ciel_clair")
			M.rect(img, x - 1, y0 + 21, 10, 1, "pierre_claire")
			M.rect(img, x, y0 + 22, 8, 1, "brique_sombre")
			fen.append(Rect2i(x + 1, y0 + 9, 6, 11))
			# Jardinière de géraniums sur certaines fenêtres
			if rng.randf() < 0.4:
				M.rect(img, x, y0 + 19, 8, 2, "bois")
				for k in range(x, x + 8, 2):
					M.px(img, k, y0 + 18, "rouge_auvent")
					M.px(img, k + 1, y0 + 18, "vert")
	var y_rdc := h - h_rdc
	M.rect(img, 0, y_rdc - 1, largeur, 1, "pierre_claire")
	M.rect(img, 0, y_rdc, largeur, 1, "pierre_ombre")
	if rdc == "tabac":
		_boutique(img, y_rdc, largeur, "rouge_auvent", false, fen, rng, true)
	else:
		_boutique(img, y_rdc, largeur, "bois", rdc == "boulangerie", fen, rng)
	M.rect(img, 0, h_toit, 1, h - h_toit, "tuile")
	M.rect(img, largeur - 1, h_toit, 1, h - h_toit, "brique_sombre")
	return {"image": img, "fenetres": fen}


## Carotte de tabac (losange rouge sur potence), 9 × 16.
static func carotte_tabac() -> Image:
	var img := M.vide(9, 16)
	M.rect(img, 0, 0, 9, 1, "encre")
	M.rect(img, 4, 0, 1, 3, "encre")
	for j in 13:
		var d := 4 - absi(6 - j) * 4 / 6
		M.rect(img, 4 - d, 3 + j, 2 * d + 1, 1, "rouge_auvent")
		M.px(img, 4 - d - 1, 3 + j, "encre")
		M.px(img, 4 + d + 1, 3 + j, "encre")
		if j > 0 and j < 12:
			M.px(img, 4 - d, 3 + j, "perte" if j < 6 else "rouge_auvent")
	M.rect(img, 1, 9, 7, 1, "brique_sombre")
	M.rect(img, 1, 12, 7, 1, "brique_sombre")
	return img


# --- Végétation -----------------------------------------------------------------------------------

## Platane d'automne 40 × 64 : tronc à écorce de platane (taches), houppier en grappes ombrées
## (or éclairé, orange, rouge à l'ombre, contour brique sombre). image 0 / 1 : feuillage décalé de 1 px.
static func platane(graine := 3, image := 0) -> Image:
	return arbre(40, 64, graine, image)


## Arbre d'automne de taille l × h (le platane fait 40 × 64) : mêmes règles, grappes mises à l'échelle.
static func arbre(l: int, h: int, graine := 3, image := 0) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := M.vide(l, h)
	var sx := l / 40.0
	var sy := h / 64.0
	var cx0 := l / 2 - 2
	# Tronc et branches
	var tl := maxi(3, int(5 * sx))
	var ty := int(30 * sy)
	M.rect(img, cx0, ty, tl, h - ty, "bois")
	M.rect(img, cx0, ty, 1, h - ty, "pierre")
	M.rect(img, cx0 + tl - 1, ty, 1, h - ty, "bois_sombre")
	for k in 6:
		var yy := rng.randi_range(ty + 4, h - 4)
		M.rect(img, cx0 + 1 + rng.randi_range(0, maxi(0, tl - 3)), yy, 2, 2, "pierre_claire" if k % 2 == 0 else "pierre")
	M.rect(img, cx0 - 2, h - 2, tl + 4, 2, "bois_sombre")
	for b in [[cx0 + 1, ty, -1], [cx0 + tl - 2, ty, 1]]:
		for j in int(8 * sy):
			M.px(img, b[0] + b[2] * (j / 2), b[1] - j, "bois")
	# Grappes du houppier
	var grappes: Array = []
	var centres := [[20, 14, 12], [10, 20, 9], [30, 20, 9], [14, 9, 8], [27, 9, 8], [20, 26, 9], [7, 28, 6], [33, 28, 6]]
	var s := minf(sx, sy)
	for c in centres:
		grappes.append([int(c[0] * sx) + rng.randi_range(-1, 1), int(c[1] * sy) + rng.randi_range(-1, 1), maxi(3, int(c[2] * s))])
	var feuillage := M.vide(l, h)
	var decal := image % 2
	for g in grappes:
		var cx: int = g[0] + decal
		var cy: int = g[1]
		var r: int = g[2]
		for y in range(cy - r, cy + r + 1):
			for x in range(cx - r - 1, cx + r + 2):
				var dx := x - cx
				var dy := y - cy
				var d2 := dx * dx * 0.8 + dy * dy
				if d2 > r * r:
					continue
				if x < 0 or y < 0 or x >= l or y >= h:
					continue
				# Éclairage en haut à gauche : projection sur (-1, -1)
				var lum := (-dx - dy) / float(r) + rng.randf_range(-0.25, 0.25)
				var nom := "orange"
				if lum > 0.55:
					nom = "or"
				elif lum > -0.15:
					nom = "orange"
				elif lum > -0.75:
					nom = "rouge_auvent"
				else:
					nom = "brique"
				M.px(feuillage, x, y, nom)
	# Trous dans le feuillage (on voit les branches) et contour
	for k in 5:
		var tx := rng.randi_range(int(8 * sx), int(30 * sx))
		var trou_y := rng.randi_range(int(12 * sy), int(30 * sy))
		M.rect(feuillage, tx, trou_y, 2, 1, "brique")
	M.contour(feuillage, "brique_sombre")
	M.coller(img, feuillage, 0, 0)
	# Quelques feuilles éclairées en grappes de 2 (pas de bruit d'un pixel)
	for k in 6:
		var fx := rng.randi_range(int(6 * sx), int(32 * sx))
		var fy := rng.randi_range(int(4 * sy), int(30 * sy))
		if feuillage.get_pixel(fx, fy).a > 0.0 and feuillage.get_pixel(fx + 1, fy).a > 0.0:
			M.px(img, fx, fy, "terre_cuite_claire")
			M.px(img, fx + 1, fy, "terre_cuite_claire")
	return img


## Massif du jardinet (hortensia et buis d'automne) : l × h, grappes vertes et rouille.
static func massif(l: int, h: int, graine := 5) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	var img := M.vide(l, h)
	for k in l / 4 + 2:
		var cx := rng.randi_range(3, l - 4)
		var cy := rng.randi_range(h / 2, h - 3)
		var r := rng.randi_range(3, 5)
		for y in range(cy - r, cy + r + 1):
			for x in range(cx - r, cx + r + 1):
				if (x - cx) * (x - cx) + (y - cy) * (y - cy) > r * r or x < 0 or y < 0 or x >= l or y >= h:
					continue
				var lum := (-(x - cx) - (y - cy)) / float(r)
				M.px(img, x, y, "vert_clair" if lum > 0.6 else ("vert" if lum > -0.3 else "vert_sombre"))
	# Fleurs d'hortensia (bleu vif / ciel) par grappes de 2 × 2
	for k in l / 6 + 1:
		var fx := rng.randi_range(2, l - 4)
		var fy := rng.randi_range(h / 2, h - 5)
		if img.get_pixel(fx, fy).a > 0.0:
			M.rect(img, fx, fy, 2, 2, "bleu_vif" if k % 2 == 0 else "orange")
			M.px(img, fx, fy, "ciel" if k % 2 == 0 else "or")
	M.contour(img, "vert_sombre", false)
	return img


# --- Mobilier ---------------------------------------------------------------------------------------

## Muret de meulière surmonté d'une grille basse (lances), longueur l, hauteur 14.
## portillon : [x, largeur] d'un portillon plus haut entre deux piliers (ou []).
static func grille_basse(l: int, portillon: Array, graine := 9) -> Image:
	var img := M.vide(l, 16)
	# Muret (y 10..15)
	M.coller(img, M.meuliere(l, 6, graine), 0, 10)
	M.rect(img, 0, 9, l, 1, "pierre_claire")
	M.rect(img, 0, 10, l, 1, "pierre_ombre")
	# Grille : barreaux tous les 3 px, lisses haute et basse, lances
	for x in range(1, l - 1, 3):
		M.rect(img, x, 2, 1, 7, "nuit")
		M.px(img, x, 1, "encre")
	M.rect(img, 0, 3, l, 1, "nuit")
	M.rect(img, 0, 7, l, 1, "nuit")
	if portillon.size() == 2:
		var px0: int = portillon[0]
		var pl: int = portillon[1]
		img.fill_rect(Rect2i(px0, 0, pl, 10), Color.TRANSPARENT)
		for x in range(px0 + 2, px0 + pl - 2, 2):
			M.rect(img, x, 1, 1, 8, "nuit")
		M.rect(img, px0 + 1, 2, pl - 2, 1, "nuit")
		M.rect(img, px0 + 1, 8, pl - 2, 1, "nuit")
		M.rect(img, px0 + 1, 10, pl - 2, 6, "gris_pierre")
		M.rect(img, px0 + 1, 10, pl - 2, 1, "zinc_clair")
		# Piliers de pierre avec chapeau
		for p in [px0 - 3, px0 + pl]:
			M.rect(img, p, 0, 3, 16, "pierre")
			M.rect(img, p, 0, 1, 16, "pierre_claire")
			M.rect(img, p + 2, 0, 1, 16, "pierre_ombre")
			M.rect(img, p - 1, 0, 5, 1, "pierre_claire")
	return img


## Chaise de bistrot 4 × 8 et guéridon 5 × 8.
static func chaise_bistrot() -> Image:
	var img := M.vide(4, 8)
	M.rect(img, 0, 0, 1, 8, "encre")
	M.rect(img, 0, 4, 4, 1, "encre")
	M.rect(img, 3, 4, 1, 4, "encre")
	M.rect(img, 1, 3, 3, 1, "bois")
	return img


static func gueridon() -> Image:
	var img := M.vide(5, 8)
	M.rect(img, 0, 0, 5, 1, "zinc_clair")
	M.rect(img, 0, 1, 5, 1, "ardoise")
	M.rect(img, 2, 2, 1, 5, "encre")
	M.rect(img, 1, 7, 3, 1, "encre")
	return img


## Potelet parisien 3 × 9.
static func potelet() -> Image:
	var img := M.vide(3, 9)
	M.rect(img, 0, 1, 3, 8, "vert_sombre")
	M.rect(img, 0, 1, 1, 8, "vert")
	M.rect(img, 1, 0, 1, 1, "vert_sombre")
	M.rect(img, 0, 3, 3, 1, "or")
	return img


## Plaque de rue émaillée (bleu vif, liseré vert, filet blanc, lettres suggérées) 16 × 7.
static func plaque_rue() -> Image:
	var img := M.vide(16, 7)
	M.rect(img, 0, 0, 16, 7, "vert_sombre")
	M.rect(img, 1, 1, 14, 5, "bleu_vif")
	M.cadre(img, 1, 1, 14, 5, "blanc_chaud")
	for x in range(3, 13, 2):
		M.px(img, x, 3, "blanc_chaud")
	M.rect(img, 4, 4, 8, 1, "blanc_chaud")
	return img
