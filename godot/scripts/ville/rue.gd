extends Node2D
## La rue (plan 3) : trottoirs, chaussée, immeubles de décor (pour les écrans larges), kiosque,
## cabine téléphonique, arbres selon la saison. Les 3 bâtiments jouables sont des nœuds à part.

const SOL := -160.0
const GAUCHE := -2600.0
const LARGEUR := 5200.0

var mois := 9            # mois du jeu (1-12) : saison des arbres
var annee := 1986        # variantes d'époque (09 §2.5)
var neige := false

const ARBRES := [-720.0, 730.0, -1390.0, 1400.0]


func regler_saison(m: int, a: int) -> void:
	if m == mois and a == annee:
		return
	mois = m
	annee = a
	neige = m == 12 or m <= 2
	queue_redraw()


func _draw() -> void:
	# Immeubles de décor (hors zone utile, visibles sur les écrans larges)
	_immeuble(-1340, 300, 440, Color("cdb592"), false)
	_cafe(-1020, 250, 330)
	_immeuble(780, 270, 410, Color("d3bc98"), true)
	_immeuble(1070, 280, 360, Color("c7ae8c"), false)
	_immeuble(-1660, 300, 380, Color("d0bb9a"), true)
	_immeuble(1370, 300, 430, Color("cbb391"), true)
	# Trottoir du fond, chaussée, trottoir de devant
	draw_rect(Rect2(GAUCHE, SOL, LARGEUR, 40), Color("a8a296"))
	draw_rect(Rect2(GAUCHE, SOL, LARGEUR, 3), Color("bdb7ab"))
	draw_rect(Rect2(GAUCHE, SOL + 36, LARGEUR, 6), Color("7e786e"))
	draw_rect(Rect2(GAUCHE, -118, LARGEUR, 92), Color("4a4a52"))
	draw_rect(Rect2(GAUCHE, -118, LARGEUR, 10), Color("414149"))
	var x := GAUCHE
	while x < GAUCHE + LARGEUR:
		draw_rect(Rect2(x, -74, 54, 4), Color("e8e2d0"))
		x += 110.0
	draw_rect(Rect2(GAUCHE, -28, LARGEUR, 6), Color("7e786e"))
	draw_rect(Rect2(GAUCHE, -22, LARGEUR, 900), Color("9c968c"))
	for k in range(int(LARGEUR / 120.0)):
		draw_rect(Rect2(GAUCHE + k * 120.0, -22, 2, 900), Color("8f897f"))
	draw_rect(Rect2(GAUCHE, 40, LARGEUR, 900), Color("8a857c"))
	# Mobilier
	_kiosque(-226)
	_cabine(205)
	for ax in ARBRES:
		_arbre(ax)


func _immeuble(x0: float, w: float, h: float, c: Color, balcons: bool) -> void:
	Dessin.ombre_sol(self, x0, x0 + w, SOL, 10)
	Dessin.volume(self, Rect2(x0, SOL - h, w, h), c, 22)
	Dessin.poly(self, [Vector2(x0 - 8, SOL - h), Vector2(x0 + w + 8, SOL - h), Vector2(x0 + w - 18, SOL - h - 56), Vector2(x0 + 18, SOL - h - 56)], Color("6e7a8c"))
	draw_rect(Rect2(x0 + 30, SOL - h - 84, 20, 30), Color("6e7a8c").darkened(0.15))
	var cols := int((w - 40) / 62.0)
	for r in range(int((h - 90) / 80.0)):
		for k in cols:
			var fx := x0 + 30 + k * 62
			var fy := SOL - h + 30 + r * 80
			draw_rect(Rect2(fx, fy, 30, 48), Color("8fb3c9"))
			draw_rect(Rect2(fx, fy, 30, 6), c.darkened(0.15))
			if balcons and r % 2 == 0:
				draw_rect(Rect2(fx - 6, fy + 46, 42, 5), Color("3d3f46"))
	draw_rect(Rect2(x0, SOL - 70, w, 70), c.darkened(0.08))
	draw_rect(Rect2(x0 + w / 2.0 - 24, SOL - 62, 48, 62), Color("5a4636"))


func _cafe(x0: float, w: float, h: float) -> void:
	var c := Color("d9c3a0")
	_immeuble(x0, w, h, c, true)
	# Rez-de-chaussée : vitrine, auvent rayé, enseigne
	draw_rect(Rect2(x0 + 10, SOL - 74, w - 20, 74), Color("7a2e2e"))
	draw_rect(Rect2(x0 + 22, SOL - 62, w - 44, 50), Color("e9cf8f"))
	for k in 8:
		var col := Color("c8382e") if k % 2 == 0 else Color("f3ece0")
		draw_rect(Rect2(x0 + k * w / 8.0, SOL - 104, w / 8.0, 26), col)
	Dessin.poly(self, [Vector2(x0, SOL - 78), Vector2(x0 + w, SOL - 78), Vector2(x0 + w + 12, SOL - 70), Vector2(x0 - 12, SOL - 70)], Color("a32a22"))
	Dessin.texte(self, Style.titre_journal(), Vector2(x0 + w / 2.0, SOL - 112), "CAFÉ DU COMMERCE", 22, Color("3a2a1a"))
	# Terrasse : 2 tables rondes
	for tx in [x0 + 50, x0 + w - 60]:
		draw_rect(Rect2(tx - 3, SOL + 6, 6, 26), Color("3d3f46"))
		draw_rect(Rect2(tx - 22, SOL + 2, 44, 6), Color("cfcfcf"))


func _kiosque(cx: float) -> void:
	var vert := Color("2f6b4f")
	Dessin.ombre_sol(self, cx - 46, cx + 46, SOL + 20, 8)
	Dessin.volume(self, Rect2(cx - 44, SOL - 110, 88, 130), vert, 16)
	# Dôme et pointe
	Dessin.poly(self, [Vector2(cx - 54, SOL - 110), Vector2(cx + 54, SOL - 110), Vector2(cx + 30, SOL - 146), Vector2(cx - 30, SOL - 146)], vert.darkened(0.15))
	draw_circle(Vector2(cx, SOL - 150), 16, vert.darkened(0.1))
	draw_rect(Rect2(cx - 2, SOL - 180, 4, 18), vert.darkened(0.3))
	# Journaux et affiche Minitel « 3615 » (1986+)
	draw_rect(Rect2(cx - 34, SOL - 96, 68, 40), Color("efe6d2"))
	for k in 3:
		draw_rect(Rect2(cx - 30, SOL - 90 + k * 12, 60, 4), Color("8a8577"))
	if annee >= 1986:
		draw_rect(Rect2(cx - 34, SOL - 48, 68, 50), Color("1d3f8a"))
		Dessin.texte(self, Style.chiffres(), Vector2(cx, SOL - 14), "3615", 26, Color("ffd34d"))
	Dessin.texte(self, Style.ui_gras(), Vector2(cx, SOL - 120), "PRESSE", 14, Color("e8d9a8"))


func _cabine(cx: float) -> void:
	var c := Color("d8dde3")
	Dessin.ombre_sol(self, cx - 26, cx + 26, SOL + 18, 8)
	Dessin.volume(self, Rect2(cx - 26, SOL - 120, 52, 138), c, 10)
	draw_rect(Rect2(cx - 20, SOL - 98, 40, 96), Color("9cc3d9"))
	draw_rect(Rect2(cx - 26, SOL - 132, 52, 16), Color("2a5aa8"))
	Dessin.texte(self, Style.ui_gras(), Vector2(cx, SOL - 119), "TÉLÉCARTE" if annee >= 1986 else "TÉLÉPHONE", 10, Color.WHITE)
	draw_rect(Rect2(cx - 8, SOL - 76, 16, 24), Color("3d3f46"))


func _arbre(x: float) -> void:
	var tronc := Color("6b4a32")
	Dessin.ombre_sol(self, x - 40, x + 40, SOL + 22, 6)
	draw_rect(Rect2(x - 9, SOL - 120, 18, 142), tronc)
	draw_rect(Rect2(x + 2, SOL - 120, 7, 142), tronc.darkened(0.2))
	var hiver := mois == 12 or mois <= 2
	if hiver:
		# Branches nues
		for b in [[-1, -110, -46, -170], [1, -100, 42, -176], [-1, -150, -24, -214], [1, -146, 26, -220], [0, -120, 0, -230]]:
			draw_line(Vector2(x, SOL + b[1]), Vector2(x + b[2], SOL + b[3]), tronc, 6.0, true)
		if neige:
			for b in [[-46, -170], [42, -176], [-24, -214], [26, -220], [0, -230]]:
				draw_circle(Vector2(x + b[0], SOL + b[1] - 3), 6, Color(1, 1, 1, 0.95))
		return
	var feuillage := Color("6dbe6a")
	if mois >= 9 and mois <= 11:
		feuillage = Color("e39b4b")
	elif mois >= 3 and mois <= 4:
		feuillage = Color("8fd17a")
	var ombre := feuillage.darkened(0.2)
	draw_circle(Vector2(x + 14, SOL - 150), 62, ombre)
	draw_circle(Vector2(x - 30, SOL - 160), 54, feuillage)
	draw_circle(Vector2(x + 26, SOL - 196), 52, feuillage)
	draw_circle(Vector2(x - 6, SOL - 214), 44, feuillage.lightened(0.08))
	draw_circle(Vector2(x + 34, SOL - 146), 44, feuillage)
