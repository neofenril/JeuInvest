extends Node2D
## Monde de la rue du jeu (lot PX1, docs/16 §9) en px d'art de la grille 960 × 540 (×2 à 1080p), rendu dans le
## SubViewport de la VuePixel de ville.gd. Repères : sol des façades SOL (402), trottoir 402-428, chaussée
## 428-518 ; décor habillé de GAUCHE à DROITE (3 420 px). De gauche à droite : immeubles, la Gazette (x -795),
## immeubles, la maison de Gérard (x 0-228), muret et jardin, épicerie à auvent rouge, pignon, la banque
## (x 678-948), immeubles. La ville ne calcule rien : elle montre l'état que ville.gd lui transmet.
##
## Jour / nuit / orage : chaque image est dessinée dans la variante de palette du moment ; pendant un fondu,
## la variante d'arrivée est posée par-dessus avec un alpha (variantes()), opération par opération. Fondu
## terminé : une seule variante (contrôle de palette exact). Lumières (fenêtres, globes) : opérations « nuit
## seulement » ; halos : calque additif (3 disques). Saisons : feuillages recolorés (printemps, automne, hiver
## aux branches nues), neige sur les toits et au sol en hiver.

const Facades := preload("res://scripts/pixel/facades.gd")
const Vehicules := preload("res://scripts/pixel/vehicules.gd")
const Personnages := preload("res://scripts/pixel/personnages.gd")
const Voisins := preload("res://scripts/pixel/voisins.gd")
const Edifices := preload("res://scripts/pixel/edifices.gd")

const SOL := 402
const TROTTOIR := 26
const CHAUSSEE := 90
const BAS_CHAUSSEE := SOL + TROTTOIR + CHAUSSEE          # 518
const GAUCHE := -1560
const DROITE := 1860
const HAUTEUR_CIEL := 720
const PIEDS := 414
const Y_VOIE_LOIN := 472
const Y_VOIE_PROCHE := 503
const Y_GAREE := 455
const MAISON_X := 0
const GAZETTE_X := -795
const BANQUE_X := 678
const PASSAGES := [Rect2i(255, 436, 105, 68), Rect2i(1150, 436, 105, 68)]
const HALOS := [[45, 0.08], [28, 0.16], [15, 0.28]]
const HALOS_PHARE := [[15, 0.12], [7, 0.3]]
const PREMIER_PLAN_MARGE := 36
const GLOBE := Rect2i(3, 12, 9, 6)
const QUANTUM := 32.0                                     # pas des fondus (redessins limités)

## Immeubles : [x gauche de l'image, réglages de Facades.batiment()].
const BATIMENTS := [
	[-1560, {"l": 180, "brique": "claire", "etages": 2, "toit": "ardoise", "rdc": "porte", "porte": "vert", "graine": 31, "retour": "droite"}],
	[-1380, {"l": 225, "brique": "classique", "etages": 3, "toit": "plat", "rdc": "boutique", "enseigne": "CAFE", "auvent": "vert", "devanture": "bois", "graine": 32}],
	[-1155, {"l": 165, "brique": "vive", "etages": 1, "toit": "tuiles", "rdc": "porte", "porte": "rouge", "graine": 21}],
	[-990, {"l": 195, "brique": "sombre", "etages": 2, "toit": "ardoise", "rdc": "porte", "porte": "bleu", "graine": 33}],
	[-570, {"l": 179, "brique": "vive", "etages": 2, "toit": "tuiles", "rdc": "porte", "porte": "sarcelle", "graine": 41, "retour": "gauche"}],
	[-375, {"l": 180, "brique": "claire", "etages": 1, "toit": "plat", "rdc": "boutique", "enseigne": "LIBRAIRIE", "auvent": "sarcelle", "devanture": "bois", "graine": 42}],
	[-195, {"l": 195, "brique": "sombre", "etages": 2, "toit": "ardoise", "h_toit": 60, "rdc": "porte", "porte": "bleu", "graine": 22}],
	[354, {"l": 192, "brique": "claire", "etages": 1, "toit": "plat", "rdc": "boutique", "enseigne": "EPICERIE", "auvent": "rouge_auvent", "devanture": "sarcelle", "graine": 23}],
	[546, {"l": 116, "brique": "classique", "etages": 2, "toit": "pignon", "h_toit": 45, "aveugle": true, "pub": "CHOCOLAT|AU LAIT", "rdc": "garage", "graine": 24, "retour": "gauche"}],
	[948, {"l": 186, "brique": "sombre", "etages": 3, "toit": "plat", "rdc": "porte", "porte": "rouge", "graine": 26}],
	[1134, {"l": 174, "brique": "claire", "etages": 1, "toit": "tuiles", "rdc": "boutique", "enseigne": "BOULANGERIE", "auvent": "sarcelle", "devanture": "bois", "graine": 27}],
	[1308, {"l": 164, "brique": "classique", "etages": 2, "toit": "ardoise", "rdc": "porte", "porte": "vert", "graine": 28, "retour": "gauche"}],
	[1488, {"l": 180, "brique": "vive", "etages": 2, "toit": "plat", "rdc": "boutique", "enseigne": "TABAC", "auvent": "rouge_auvent", "devanture": "rouge_auvent", "graine": 29}],
	[1668, {"l": 192, "brique": "claire", "etages": 2, "toit": "ardoise", "rdc": "porte", "porte": "sarcelle", "graine": 30}],
]
## Immeubles de fond (bleutés) : [x gauche, largeur, étages, toit, graine] ; jamais derrière la maison.
const FONDS := [[-1490, 150, 2, "plat", 51], [-1240, 165, 3, "ardoise", 52], [-1020, 150, 3, "plat", 53],
	[-470, 165, 2, "ardoise", 54], [-300, 150, 3, "plat", 55], [380, 126, 3, "ardoise", 56],
	[1000, 150, 3, "plat", 57], [1350, 165, 3, "ardoise", 58], [1600, 135, 3, "plat", 59]]
## Modèles d'arbres (générés en tâche de fond) : [largeur, hauteur, graine] ; arbres : [x du milieu, modèle, devant].
const ARBRE_MODELES := [[225, 324, 3], [210, 315, 41], [180, 300, 37], [165, 255, 47]]
const ARBRES := [[300, 0, true], [-225, 1, false], [640, 2, false], [1080, 1, false], [-1100, 3, false], [1590, 2, false], [-1300, 3, false]]
const LAMPADAIRES := [348, -560, -1080, 1060, 1600, -1480]
const MURET := Rect2i(228, 357, 126, 45)
const ARMOIRE := Rect2i(309, 360, 27, 42)
const PORTAIL := Rect2i(255, 354, 42, 48)
const SAISONS_FEUILLES := {
	"printemps": {"feuille_eclat": "vert_clair", "feuille_vive": "vert_clair", "feuille": "vert", "feuille_sombre": "vert_sombre", "feuille_profonde": "vert_sombre"},
	"automne": {"feuille_eclat": "or", "feuille_vive": "or", "feuille": "orange", "feuille_sombre": "tuile", "feuille_profonde": "brique"},
}

var anime := true
var facteur := 1.0          # facteur de trafic (posé par ville.gd)
var melange := 0.0           # 0 jour → 1 nuit (quantifié)
var orage := 0.0             # 0 → 1 ciel de krach (variante orage)
var saison := "ete"
var annee := 1986
var vue := Rect2(0, 0, 960, 540)      # rectangle visible (px d'art du monde), posé par ville.gd
var lumieres_visibles := true

var maison: Node2D
var banque: Node2D
var media: Node2D
var voiture_maison: Node2D
var potelet: Node2D
var gerard: Node2D
var passants: Array = []
var voitures: Array = []
var effets: Node2D           # accessoires des séquences (au-dessus de la rue)
var trafic: Node2D           # passants, voitures (triés en y)

var _variantes: Array = [[PalettePixel.JOUR, 1.0]]
var _dessinables: Array = []
var _couches: Array = []
var _nuages: Array = []
var _nuages_x: Array = []
var _skyline: Node2D
var _arbres: Array = []      # [Mobile, nom de base]
var _premier_plan: Node2D
var _feuilles: Array = []
var _halos: Node2D
var _halos_phares: Node2D
var _lumieres: Node2D
var _meteo: Node2D
var _rng := RandomNumberGenerator.new()
var _nuage_t := 0.0
var _arbre_t := 0.0
var _arbre_image := 0
var _prechauffe: Array = []
static var _fenetres := {}
static var _auvents := {}
static var _voitures := {}
static var _taches: Array = []      # [identifiant WorkerThreadPool, résultats {nom: [Image, origine]}]
var _saison_demandee := {}


## Élément fixe : liste d'opérations (image, répétée en x ; rectangle de couleur), dessinées dans les variantes
## du moment. quand : "" toujours, "nuit" lumières (variante nuit, alpha = melange), "hiver" neige.
class Couche extends Node2D:
	var rue: Node2D
	var ops: Array = []

	func image(nom: String, pos: Vector2i, repeter_x := 0, quand := "") -> void:
		ops.append({"image": nom, "pos": pos, "repeter_x": repeter_x, "quand": quand})

	func rect(r: Rect2i, couleur: String, quand := "") -> void:
		ops.append({"rect": r, "couleur": couleur, "quand": quand})

	func _draw() -> void:
		var m: float = rue.melange
		var hiver: bool = rue.saison == "hiver"
		for op in ops:
			var q: String = op["quand"]
			if q == "nuit":
				if m > 0.0:
					_op(op, PalettePixel.NUIT, m)
				continue
			if q == "hiver" and not hiver:
				continue
			for v in rue.variantes():
				_op(op, v[0], v[1])

	func _op(op: Dictionary, variante: int, alpha: float) -> void:
		if op.has("rect"):
			draw_rect(Rect2(op["rect"]), PalettePixel.couleur_alpha(op["couleur"], alpha, variante))
			return
		var nom: String = op["image"]
		if not GrillePixel.existe(nom):
			return
		var tex := GrillePixel.texture(nom, variante)
		var pos: Vector2i = op["pos"] - GrillePixel.origine(nom)
		var l := tex.get_width()
		var fin: int = pos.x + maxi(int(op["repeter_x"]), l)
		var x := pos.x
		var teinte := Color(Color.WHITE, alpha)
		while x < fin:
			if x + l <= fin:
				draw_texture(tex, Vector2(x, pos.y), teinte)
			else:
				var reste := fin - x
				draw_texture_rect_region(tex, Rect2(x, pos.y, reste, tex.get_height()), Rect2(0, 0, reste, tex.get_height()), teinte)
			x += l


## Élément animé simple : parties [nom, décalage], ombres [Rect2i, couleur].
class Mobile extends Node2D:
	var rue: Node2D
	var parts: Array = []
	var ombres: Array = []

	func poser(liste: Array) -> void:
		if liste != parts:
			parts = liste
			queue_redraw()

	func _draw() -> void:
		for o in ombres:
			rue.rect(self, o[0], o[1])
		for p in parts:
			rue.image(self, p[0], p[1])


## Halos de lumière (calque additif) : disques pixellisés couleur lumiere.
class Halos extends Node2D:
	var centres: Array = []
	var rayons: Array = []

	func _draw() -> void:
		for c in centres:
			for h in rayons:
				var nom := "decor/halo_%d" % h[0]
				draw_texture(GrillePixel.texture(nom), Vector2(Vector2i(c) - GrillePixel.origine(nom)), Color(Color.WHITE, h[1]))


## Pluie (traits de 1 × 3 à 1 × 5) et neige (flocons 2 × 2), à positions entières, dans la vue.
class Meteo extends Node2D:
	var rue: Node2D
	var pluie := false
	var neige := false
	var gouttes: Array = []      # [x, y, longueur] relatifs à la vue
	var flocons: Array = []      # [x, y, phase]
	var _rng := RandomNumberGenerator.new()

	func _init() -> void:
		_rng.seed = 7
		for i in 170:
			gouttes.append([_rng.randf_range(0, 1400), _rng.randf_range(0, 560), _rng.randi_range(3, 5)])
		for i in 90:
			flocons.append([_rng.randf_range(0, 1400), _rng.randf_range(0, 560), _rng.randf_range(0, TAU)])

	func avancer(delta: float) -> void:
		var l: float = maxf(rue.vue.size.x, 960.0) + 40.0
		var h: float = rue.vue.size.y + 20.0
		if pluie:
			for g in gouttes:
				g[1] += 330.0 * delta
				g[0] -= 80.0 * delta
				if g[1] > h:
					g[1] -= h + 10.0
					g[0] = _rng.randf_range(0, l)
				if g[0] < -10.0:
					g[0] += l
		if neige:
			for f in flocons:
				f[2] += delta
				f[1] += 22.0 * delta
				f[0] += sin(f[2] * 1.3) * 8.0 * delta
				if f[1] > h:
					f[1] -= h + 10.0
					f[0] = _rng.randf_range(0, l)
		queue_redraw()

	func _draw() -> void:
		var o := Vector2i(rue.vue.position)
		if pluie:
			for g in gouttes:
				var p := o + Vector2i(int(g[0]), int(g[1]))
				rue.rect(self, Rect2i(p.x, p.y, 1, g[2]), "zinc_clair" if int(g[2]) > 3 else "gris_pierre")
		if neige:
			for f in flocons:
				var q := o + Vector2i(int(f[0]), int(f[1]))
				rue.rect(self, Rect2i(q.x, q.y, 2, 2), "blanc_chaud")


func _init() -> void:
	name = "Rue"


func _ready() -> void:
	_rng.seed = 84
	generer()
	_construire()


# --- Génération des images (catalogue « rue/… ») -------------------------------------------------------------

## Génère toutes les images de la rue (une seule fois par lancement). Renvoie la durée en ms.
static func generer() -> int:
	var t0 := Time.get_ticks_msec()
	if GrillePixel.existe("rue/maison"):
		return 0
	if not GrillePixel.existe("matiere/ciel"):
		MatieresPixel.generer_tout()
	Personnages.enregistrer()
	Voisins.enregistrer("gerard")
	for n in ["passant_1", "passant_2", "passant_3"]:
		Voisins.enregistrer(n)
	Edifices.enregistrer_objets()
	GrillePixel.enregistrer("ville/lampadaire", Facades.lampadaire(), Vector2i(7, 125))
	GrillePixel.enregistrer("ville/bouche_incendie", Facades.bouche_incendie(), Vector2i(6, 20))
	GrillePixel.enregistrer("ville/boite_poste", Facades.boite_poste(), Vector2i(6, 35))
	var m: Dictionary = Facades.maison_gerard(7)
	_poser("rue/maison", m, Vector2i(Facades.MAISON_L / 2, Facades.MAISON_H - 1))
	var b: Dictionary = Edifices.banque()
	_poser("rue/banque", b, Vector2i(Edifices.BANQUE.x / 2, Edifices.BANQUE.y - 1))
	var g: Dictionary = Edifices.gazette()
	_poser("rue/gazette", g, Vector2i(Edifices.GAZETTE.x / 2, Edifices.GAZETTE.y - 1))
	for i in BATIMENTS.size():
		var r: Dictionary = Facades.batiment(BATIMENTS[i][1])
		var img: Image = r["image"]
		_poser("rue/batiment_%d" % i, r, Vector2i(0, img.get_height() - 1))
		_auvents["rue/batiment_%d" % i] = r["auvent"]
	for i in FONDS.size():
		var f: Array = FONDS[i]
		var r2: Dictionary = Facades.batiment({"l": f[1], "etages": f[2], "toit": f[3], "rdc": "porte", "brique": "classique", "graine": f[4]})
		var pale := MatieresPixel.lointain(r2["image"])
		GrillePixel.enregistrer("rue/fond_%d" % i, pale, Vector2i(0, pale.get_height() - 1))
		_fenetres["rue/fond_%d" % i] = r2["fenetres"]
	# Arbres : générés en tâche de fond (≈ 0,4 s chacun), enregistrés dès qu'ils sont prêts (_process)
	PalettePixel.couleur("encre")
	for k in ARBRE_MODELES.size():
		for im in 2:
			_tache(_tache_arbre.bind(k, im))
	_tache(_tache_premier_plan)
	GrillePixel.enregistrer("rue/muret", Facades.muret(MURET.size.x, MURET.size.y - 6, 9), Vector2i(0, MURET.size.y - 1))
	GrillePixel.enregistrer("rue/haie", Facades.haie(120, 27, 5), Vector2i(0, 26))
	GrillePixel.enregistrer("rue/portail", Facades.portail(PORTAIL.size.x, PORTAIL.size.y), Vector2i(0, PORTAIL.size.y - 1))
	GrillePixel.enregistrer("rue/armoire", Facades.armoire(ARMOIRE.size.x, ARMOIRE.size.y), Vector2i(0, ARMOIRE.size.y - 1))
	GrillePixel.enregistrer("rue/plaque", Facades.plaque(), Vector2i(0, 0))
	for im in 2:
		var fe := MatieresPixel.vide(3, 3)
		MatieresPixel.rect(fe, 0, 1, 2, 1, "feuille_vive" if im == 0 else "feuille")
		MatieresPixel.px(fe, 1 + im, 0, "feuille_eclat" if im == 0 else "feuille_vive")
		MatieresPixel.px(fe, 2 - im, 2, "feuille_profonde")
		GrillePixel.enregistrer("rue/feuille_%d" % im, fe, Vector2i(1, 1))
	for h in HALOS + HALOS_PHARE:
		if not GrillePixel.existe("decor/halo_%d" % h[0]):
			GrillePixel.enregistrer("decor/halo_%d" % h[0], MatieresPixel.disque(h[0], "lumiere"), Vector2i(h[0], h[0]))
	for modele in ["r5", "205", "4l", "fourgonnette", "944"]:
		var v: Dictionary = Vehicules.caisse(modele)
		var img2: Image = v["image"]
		GrillePixel.enregistrer("rue/voiture_" + modele, img2, v["origine"])
		var mir := Image.new()
		mir.copy_from(img2)
		mir.flip_x()
		var o: Vector2i = v["origine"]
		GrillePixel.enregistrer("miroir/voiture_" + modele, mir, Vector2i(img2.get_width() - 1 - o.x, o.y))
		_voitures[modele] = {"roues": v["roues"], "phare": v["phare"], "feu": v["feu"], "taille": img2.get_size(), "origine": o}
	for i in 2:
		GrillePixel.enregistrer("rue/roue_%d" % (i + 1), Vehicules.roue(i), Vector2i(Vehicules.ROUE / 2, Vehicules.ROUE - 1))
	return Time.get_ticks_msec() - t0


static func _tache(f: Callable) -> void:
	var res := {}
	_taches.append([WorkerThreadPool.add_task(f.bind(res)), res])


static func _tache_arbre(k: int, im: int, res: Dictionary) -> void:
	var a: Array = ARBRE_MODELES[k]
	var img := Facades.arbre_ete(a[0], a[1], a[2], im)
	res["rue/arbre_m%d_%d_ete" % [k, im]] = [img, Vector2i(img.get_width() / 2, img.get_height() - 1)]


static func _tache_premier_plan(res: Dictionary) -> void:
	var pp: Dictionary = Facades.arbre_premier_plan(61)
	for im in 2:
		res["rue/premier_plan_%d_ete" % im] = [pp["image%d" % im], Vector2i(Facades.PP_TRONC, 0)]


static func _tache_saison(noms: Array, table: Dictionary, trames: Dictionary, saison_cible: String, res: Dictionary) -> void:
	for n in noms:
		res[String(n[0]).trim_suffix("ete") + saison_cible] = [recolorer(n[1], table, trames), n[2]]


## Enregistre les images des tâches terminées ; vrai si quelque chose a changé.
static func _recolter() -> bool:
	var change := false
	for t in _taches.duplicate():
		if WorkerThreadPool.is_task_completed(t[0]):
			WorkerThreadPool.wait_for_task_completion(t[0])
			var res: Dictionary = t[1]
			for nom in res:
				GrillePixel.enregistrer(nom, res[nom][0], res[nom][1])
			_taches.erase(t)
			change = true
	return change


## Vrai quand aucune image n'est en cours de génération (captures, tests).
func images_pretes() -> bool:
	return _taches.is_empty()


static func _poser(nom: String, r: Dictionary, origine: Vector2i) -> void:
	GrillePixel.enregistrer(nom, r["image"], origine)
	_fenetres[nom] = r["fenetres"]


static func fenetres(nom: String) -> Array:
	return _fenetres.get(nom, [])


static func voiture_info(modele: String) -> Dictionary:
	return _voitures.get(modele, {})


## Recolore une image (table nom -> nom ; "" = transparent ; densité de trame par cible optionnelle).
static func recolorer(img: Image, table: Dictionary, trames := {}) -> Image:
	var src := Image.new()
	src.copy_from(img)
	src.convert(Image.FORMAT_RGBA8)
	var cles := {}
	for de in table:
		cles[PalettePixel.cle(PalettePixel.couleur(de))] = de
	var d := src.get_data()
	var l := src.get_width()
	var i := 0
	var n := d.size()
	while i < n:
		if d[i + 3] != 0:
			var k := (d[i] << 16) | (d[i + 1] << 8) | d[i + 2]
			var de = cles.get(k)
			if de != null:
				var vers: String = table[de]
				var px := (i / 4) % l
				var py := (i / 4) / l
				if trames.has(de) and not MatieresPixel.trame(px, py, float(trames[de])):
					vers = ""
				if vers == "":
					d[i + 3] = 0
				else:
					var c := PalettePixel.couleur(vers)
					d[i] = c.r8
					d[i + 1] = c.g8
					d[i + 2] = c.b8
		i += 4
	return Image.create_from_data(src.get_width(), src.get_height(), false, Image.FORMAT_RGBA8, d)


## Neige sur une image : le dessus de chaque colonne (toits, cheminées, corniches) reçoit 2 à 3 px de neige.
static func neige_sur(img: Image) -> Image:
	var l := img.get_width()
	var h := img.get_height()
	var n := MatieresPixel.vide(l, h)
	for x in l:
		for y in h:
			if img.get_pixel(x, y).a > 0.0:
				var e := 2 + int((x * 7) % 5 == 0)
				MatieresPixel.rect(n, x, maxi(0, y - 1), 1, e, "blanc_chaud")
				MatieresPixel.px(n, x, y - 1 + e, "zinc_clair" if (x % 3) != 0 else "blanc_chaud")
				break
	return n


# --- Construction de la scène ------------------------------------------------------------------------------

func _construire() -> void:
	var largeur := DROITE - GAUCHE
	var marge := 1400
	# Ciel (plan 0) et étoiles (nuit seulement)
	var ciel := _couche("Ciel")
	ciel.rect(Rect2i(GAUCHE - marge, SOL - HAUTEUR_CIEL - 400, largeur + 2 * marge, 401), "ciel_haut")
	ciel.image("matiere/ciel", Vector2i(GAUCHE - marge, SOL - 1), largeur + 2 * marge)
	for i in 120:
		ciel.rect(Rect2i(_rng.randi_range(GAUCHE - marge, DROITE + marge), _rng.randi_range(-200, 200), 1, 1), "blanc_chaud", "nuit")
	# Cumulus (plan 0,1, dérive lente)
	for i in 9:
		var n := _mobile("Nuage%d" % i)
		n.poser([["matiere/cumulus_%d" % ([1, 2, 3, 2, 1, 3, 2, 1, 3][i]), Vector2i.ZERO]])
		_nuages.append(n)
		_nuages_x.append(float(GAUCHE + i * 420 + _rng.randi_range(-60, 60)))
		n.position.y = [36, 69, 45, 105, 45, 20, 90, 60, 30][i]
	# Skyline (plan 0,15)
	_skyline = _couche("Skyline")
	(_skyline as Couche).image("matiere/skyline", Vector2i(GAUCHE - marge, SOL - 1), largeur + 2 * marge)
	# Immeubles de fond
	var fond := _couche("Fond")
	for i in FONDS.size():
		var nom := "rue/fond_%d" % i
		var x: int = FONDS[i][0]
		fond.image(nom, Vector2i(x, SOL - 1))
		fond.image("neige/" + nom, Vector2i(x, SOL - 1), 0, "hiver")
		_allumer(fond, fenetres(nom), Vector2i(x, SOL - GrillePixel.taille(nom).y), 0.2, 600 + i)
	# Arbres derrière les bâtiments
	for i in ARBRES.size():
		if not ARBRES[i][2]:
			_arbre(i)
	# Immeubles de la rue (ceux qui avancent, « retour », en dernier)
	var rue_c := _couche("Batiments")
	var ordre: Array = []
	for i in BATIMENTS.size():
		if not BATIMENTS[i][1].has("retour"):
			ordre.append(i)
	for i in BATIMENTS.size():
		if BATIMENTS[i][1].has("retour"):
			ordre.append(i)
	for i in ordre:
		var nom2 := "rue/batiment_%d" % i
		var bx: int = BATIMENTS[i][0]
		rue_c.image(nom2, Vector2i(bx, SOL - 1))
		rue_c.image("neige/" + nom2, Vector2i(bx, SOL - 1), 0, "hiver")
		_allumer(rue_c, fenetres(nom2), Vector2i(bx, SOL - GrillePixel.taille(nom2).y), 0.35, 700 + i)
	for i in ARBRES.size():
		if ARBRES[i][2]:
			_arbre(i)
	# Bâtiments jouables
	media = _batiment("res://scripts/ville/media.gd", "rue/gazette", GAZETTE_X + Edifices.GAZETTE.x / 2)
	banque = _batiment("res://scripts/ville/banque.gd", "rue/banque", BANQUE_X + Edifices.BANQUE.x / 2)
	maison = _batiment("res://scripts/ville/maison.gd", "rue/maison", MAISON_X + Facades.MAISON_L / 2)
	# Haie et muret
	var jardin := _couche("Muret")
	jardin.image("rue/haie", Vector2i(MURET.position.x + 3, SOL - 24))
	jardin.image("rue/muret", Vector2i(MURET.position.x, SOL - 1))
	jardin.image("rue/portail", Vector2i(PORTAIL.position.x, SOL - 1))
	jardin.rect(Rect2i(MURET.position.x, MURET.position.y + 9, MURET.size.x, 2), "blanc_chaud", "hiver")
	# Sol
	var sol := _couche("Sol")
	sol.image("matiere/trottoir", Vector2i(GAUCHE - 200, SOL), largeur + 400)
	sol.image("matiere/chaussee", Vector2i(GAUCHE - 200, SOL + TROTTOIR), largeur + 400)
	for pp: Rect2i in PASSAGES:
		sol.rect(Rect2i(pp.position.x - 6, SOL + TROTTOIR + 41, pp.size.x + 12, 2), "goudron")
		for y in range(pp.position.y, pp.end.y, 10):
			var r := (y - pp.position.y) / 5
			sol.rect(Rect2i(pp.position.x - r, y, pp.size.x, 6), "blanc_chaud")
			sol.rect(Rect2i(pp.position.x - r, y, pp.size.x, 1), "zinc_clair")
			sol.rect(Rect2i(pp.position.x - r, y + 5, pp.size.x, 1), "dalle")
	for i in BATIMENTS.size():
		var au: Vector2i = _auvents.get("rue/batiment_%d" % i, Vector2i(-1, -1))
		if au.x >= 0:
			for j in 12:
				sol.rect(Rect2i(BATIMENTS[i][0] + au.x + 6 + j, SOL + j, au.y - au.x - 8, 1), "dalle_ombre")
	sol.rect(Rect2i(GAUCHE - 200, BAS_CHAUSSEE, largeur + 400, 400), "goudron_sombre")
	sol.rect(Rect2i(GAUCHE - 200, SOL, largeur + 400, 2), "dalle_ombre")
	# Neige au sol (hiver) : trottoir couvert, bord bosselé, congères le long des bordures
	for x in range(GAUCHE - 200, DROITE + 200, 6):
		var hb := 18 + (x * 13 % 7)
		sol.rect(Rect2i(x, SOL, 6, hb), "blanc_chaud", "hiver")
		sol.rect(Rect2i(x, SOL + hb, 6, 1), "zinc_clair", "hiver")
		sol.rect(Rect2i(x, SOL + TROTTOIR + 1, 6, 3 + (x * 7 % 3)), "zinc_clair", "hiver")
		sol.rect(Rect2i(x, BAS_CHAUSSEE - 6 - (x * 5 % 3), 6, 6), "zinc_clair", "hiver")
	# Mobilier : lampadaires (globes allumés la nuit), poteau d'incendie, boîte aux lettres
	var mob := _couche("Mobilier")
	var centres: Array = []
	mob.image("rue/armoire", Vector2i(ARMOIRE.position.x, SOL + 1))
	var yl := SOL + 18
	for lx in LAMPADAIRES:
		for k in 40:
			mob.rect(Rect2i(lx + 4 + k, yl - k / 8, 1, 2), "dalle_ombre")
		mob.image("ville/lampadaire", Vector2i(lx, yl))
		if lx == LAMPADAIRES[0]:
			mob.image("rue/plaque", Vector2i(lx - 16, yl - 92))
		var coin := Vector2i(lx, yl) - GrillePixel.origine("ville/lampadaire")
		mob.rect(Rect2i(coin + GLOBE.position + Vector2i(0, -2), Vector2i(GLOBE.size.x, 2)), "blanc_chaud", "hiver")
		mob.rect(Rect2i(coin + GLOBE.position, GLOBE.size), "lumiere", "nuit")
		centres.append(coin + GLOBE.get_center())
	mob.rect(Rect2i(-36, yl - 1, 16, 3), "dalle_ombre")
	mob.image("ville/bouche_incendie", Vector2i(-33, yl))
	mob.rect(Rect2i(566, yl - 1, 16, 3), "dalle_ombre")
	mob.image("ville/boite_poste", Vector2i(570, yl))
	# Trafic (trié en y) : voiture de Gérard, potelet, voitures, passants, Gérard
	trafic = Node2D.new()
	trafic.name = "Trafic"
	trafic.y_sort_enabled = true
	add_child(trafic)
	voiture_maison = _voiture("205", -60.0, Y_GAREE, 0.0, 1)
	potelet = Node2D.new()
	potelet.set_script(load("res://scripts/ville/accessoire.gd"))
	potelet.set("rue", self)
	potelet.set("images", ["objet/potelet_0"])
	potelet.position = Vector2(150, Y_GAREE - 6)
	trafic.add_child(potelet)
	_dessinables.append(potelet)
	voitures.append(_voiture("r5", -300.0, Y_VOIE_PROCHE, 72.0, 1))
	voitures.append(_voiture("4l", 1200.0, Y_VOIE_PROCHE, 64.0, 1))
	voitures.append(_voiture("205", 700.0, Y_VOIE_LOIN, 60.0, -1))
	voitures.append(_voiture("fourgonnette", -900.0, Y_VOIE_LOIN, 56.0, -1))
	var places := [[-420.0, 22.0, 1, "passant_1", 0], [520.0, 26.0, -1, "passant_2", 6], [-1100.0, 30.0, 1, "passant_3", 10]]
	for p in places:
		passants.append(ajouter_passant(String(p[3]), float(p[0]), int(p[2]), float(p[1]), PIEDS + int(p[4])))
	gerard = ajouter_passant("gerard", 66.0, 1, 8.0, PIEDS)
	gerard.set("va_et_vient", Vector2(30, 204))
	gerard.set("porte_x", 113)
	# Effets des séquences (cigogne, paquets, ondes, fumée…), météo, feuilles, premier plan
	effets = Node2D.new()
	effets.name = "Effets"
	effets.z_index = 20
	add_child(effets)
	_meteo = Meteo.new()
	_meteo.name = "Meteo"
	_meteo.rue = self
	_meteo.z_index = 30
	add_child(_meteo)
	for i in 3:
		var fe := _mobile("Feuille%d" % i)
		fe.z_index = 35
		_feuilles.append([fe, 0.0, 0.0, i * 2.1])
	_premier_plan = _mobile("PremierPlan")
	_premier_plan.z_index = 40
	# Lumières (additif), visibles la nuit
	_lumieres = Node2D.new()
	_lumieres.name = "Lumieres"
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_lumieres.material = mat
	_lumieres.z_index = 50
	add_child(_lumieres)
	_halos = Halos.new()
	_halos.rayons = HALOS
	_halos.centres = centres
	_halos.use_parent_material = true
	_lumieres.add_child(_halos)
	_halos_phares = Halos.new()
	_halos_phares.rayons = HALOS_PHARE
	_halos_phares.use_parent_material = true
	_lumieres.add_child(_halos_phares)
	_maj_arbres()
	_maj_lumieres()
	preparer_capture()
	# Préchauffage des variantes nuit et orage (une texture par image, pour éviter un à-coup au crépuscule)
	for n in GrillePixel.noms():
		if n.begins_with("rue/") or n.begins_with("matiere/") or n.begins_with("ville/"):
			_prechauffe.append([n, PalettePixel.NUIT])
	for n in GrillePixel.noms():
		if n.begins_with("rue/") or n.begins_with("matiere/"):
			_prechauffe.append([n, PalettePixel.ORAGE])


func _batiment(chemin: String, image: String, x: int) -> Node2D:
	var b := Node2D.new()
	b.set_script(load(chemin))
	b.set("rue", self)
	b.set("image_nom", image)
	b.position = Vector2(x, SOL)
	add_child(b)
	_dessinables.append(b)
	return b


func _voiture(modele: String, x: float, y: int, vitesse: float, sens: int) -> Node2D:
	var v := Node2D.new()
	v.set_script(load("res://scripts/ville/voiture.gd"))
	v.set("rue", self)
	v.set("modele", modele)
	v.set("vitesse", vitesse)
	v.set("sens", sens)
	v.set("x_monde", x)
	v.position.y = y
	trafic.add_child(v)
	_dessinables.append(v)
	return v


## Ajoute une figurine qui marche sur le trottoir (qui : gerard, passant_1..3, voisins de docs/15).
func ajouter_passant(qui: String, x: float, sens: int, vitesse: float, y := PIEDS) -> Node2D:
	Voisins.enregistrer(qui)
	var p := Node2D.new()
	p.set_script(load("res://scripts/ville/passant.gd"))
	p.set("rue", self)
	p.set("qui", qui)
	p.set("vitesse", vitesse)
	p.set("sens", sens)
	p.set("x_monde", x)
	p.position.y = y
	trafic.add_child(p)
	_dessinables.append(p)
	return p


## Accessoire des séquences (images animées à cadence im/s), au-dessus de la rue ou dans le trafic.
func ajouter(images: Array, pos: Vector2, cadence := 0.0, dans_la_rue := false) -> Node2D:
	var a := Node2D.new()
	a.set_script(load("res://scripts/ville/accessoire.gd"))
	a.set("rue", self)
	a.set("images", images)
	a.set("cadence", cadence)
	a.set("pos", pos)
	(trafic if dans_la_rue else effets).add_child(a)
	_dessinables.append(a)
	return a


func oublier(n: Node) -> void:
	_dessinables.erase(n)


func _arbre(i: int) -> void:
	var a := _mobile("Arbre%d" % i)
	a.position = Vector2(ARBRES[i][0], SOL - 1)
	_arbres.append([a, "rue/arbre_m%d_" % ARBRES[i][1]])


func _allumer(c: Couche, liste: Array, coin: Vector2i, part: float, graine: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	for f in liste:
		var r: Rect2i = f
		if part >= 1.0 or rng.randf() < part:
			c.rect(Rect2i(coin + r.position, r.size), "lumiere", "nuit")


func _couche(n: String) -> Couche:
	var c := Couche.new()
	c.name = n
	c.rue = self
	add_child(c)
	_couches.append(c)
	_dessinables.append(c)
	return c


func _mobile(n: String) -> Mobile:
	var m := Mobile.new()
	m.name = n
	m.rue = self
	add_child(m)
	_dessinables.append(m)
	return m


# --- Variantes et dessin --------------------------------------------------------------------------------------

## Variantes à dessiner, dans l'ordre, avec leur alpha : [[variante, alpha], …].
func variantes() -> Array:
	return _variantes


## Règle le mélange jour / nuit et l'orage (valeurs quantifiées ; redessin seulement si elles changent).
func regler_ciel(nuit_v: float, orage_v: float) -> void:
	var m := roundf(clampf(nuit_v, 0.0, 1.0) * QUANTUM) / QUANTUM
	var o := roundf(clampf(orage_v, 0.0, 1.0) * QUANTUM) / QUANTUM
	if m == melange and o == orage:
		return
	melange = m
	orage = o
	var v: Array = []
	if m < 1.0 and o < 1.0:
		v.append([PalettePixel.JOUR, 1.0])
	if o > 0.0 and m < 1.0:
		v.append([PalettePixel.ORAGE, o if not v.is_empty() else 1.0])
	if m > 0.0:
		v.append([PalettePixel.NUIT, m if not v.is_empty() else 1.0])
	_variantes = v
	redessiner_tout()
	_maj_lumieres()


func redessiner_tout() -> void:
	for d in _dessinables:
		if is_instance_valid(d):
			d.queue_redraw()


## Variante dominante (contrôles) : "jour", "nuit" ou "orage".
func variante_nom() -> String:
	if melange >= 1.0:
		return "nuit"
	if orage >= 1.0:
		return "orage"
	return "jour" if melange == 0.0 and orage == 0.0 else "fondu"


func image(ci: CanvasItem, nom: String, pos: Vector2i, alpha := 1.0) -> void:
	if not GrillePixel.existe(nom):
		return
	var o := Vector2(pos - GrillePixel.origine(nom))
	for v in _variantes:
		ci.draw_texture(GrillePixel.texture(nom, v[0]), o, Color(Color.WHITE, v[1] * alpha))


## Partie src d'une image, coin haut gauche en pos (bustes aux fenêtres).
func image_region(ci: CanvasItem, nom: String, pos: Vector2i, src: Rect2i, alpha := 1.0) -> void:
	if not GrillePixel.existe(nom):
		return
	for v in _variantes:
		ci.draw_texture_rect_region(GrillePixel.texture(nom, v[0]), Rect2(pos, src.size), Rect2(src), Color(Color.WHITE, v[1] * alpha))


func rect(ci: CanvasItem, r: Rect2i, couleur: String, alpha := 1.0) -> void:
	for v in _variantes:
		ci.draw_rect(Rect2(r), PalettePixel.couleur_alpha(couleur, v[1] * alpha, v[0]))


## Couleur émissive (identique dans toutes les variantes) : un seul passage.
func emissif(ci: CanvasItem, r: Rect2i, couleur: String, alpha := 1.0) -> void:
	ci.draw_rect(Rect2(r), PalettePixel.couleur_alpha(couleur, alpha))


## Lumière « nuit seulement » (vitres allumées) : variante nuit, alpha = melange × part.
func lumiere_nuit(ci: CanvasItem, r: Rect2i, part := 1.0) -> void:
	if melange > 0.0:
		ci.draw_rect(Rect2(r), PalettePixel.couleur_alpha("lumiere", melange * part, PalettePixel.NUIT))


func _maj_lumieres() -> void:
	if _lumieres != null:
		_lumieres.visible = lumieres_visibles and melange > 0.0
		_lumieres.modulate = Color(Color.WHITE, melange)


func afficher_lumieres(v: bool) -> void:
	lumieres_visibles = v
	_maj_lumieres()


# --- Saisons, météo -----------------------------------------------------------------------------------------

## Saison (été = référence) et année (variantes d'époque).
func regler_saison(mois: int, p_annee: int) -> void:
	var s := "ete"
	if mois == 12 or mois <= 2:
		s = "hiver"
	elif mois <= 5:
		s = "printemps"
	elif mois >= 9:
		s = "automne"
	annee = p_annee
	if s != saison:
		saison = s
		_preparer_saison(s)
		_maj_arbres()
		redessiner_tout()
	_meteo.neige = s == "hiver"
	for b in [maison, banque, media]:
		b.set("annee", p_annee)
		b.set("hiver", s == "hiver")
		b.queue_redraw()


func _preparer_saison(s: String) -> void:
	if s == "hiver" and not GrillePixel.existe("neige/rue/maison"):
		for n in GrillePixel.noms():
			if n.begins_with("rue/batiment_") or n.begins_with("rue/fond_") or n in ["rue/maison", "rue/banque", "rue/gazette"]:
				GrillePixel.enregistrer("neige/" + n, neige_sur(GrillePixel.image(n)), GrillePixel.origine(n))
	if s == "ete" or _saison_demandee.has(s) or not _taches.is_empty():
		return
	_saison_demandee[s] = true
	var table: Dictionary = SAISONS_FEUILLES.get(s, {})
	var trames := {}
	if s == "hiver":
		table = {"feuille_eclat": "blanc_chaud", "feuille_vive": "bois", "feuille": "bois", "feuille_sombre": "bois_sombre", "feuille_profonde": "bois_sombre"}
		trames = {"feuille_eclat": 0.35, "feuille_vive": 0.08, "feuille": 0.16, "feuille_sombre": 0.3, "feuille_profonde": 0.3}
	var noms: Array = []
	for n in GrillePixel.noms():
		if (n.begins_with("rue/arbre_") or n.begins_with("rue/premier_plan_")) and n.ends_with("_ete"):
			noms.append([n, GrillePixel.image(n), GrillePixel.origine(n)])
	_tache(_tache_saison.bind(noms, table, trames, s))


func regler_pluie(v: bool) -> void:
	_meteo.pluie = v
	_meteo.queue_redraw()


func _maj_arbres() -> void:
	var s := saison if GrillePixel.existe("rue/premier_plan_0_" + saison) else "ete"
	for a in _arbres:
		(a[0] as Mobile).poser([[a[1] + "%d_%s" % [_arbre_image, s], Vector2i.ZERO]])
	_premier_plan.poser([["rue/premier_plan_%d_%s" % [_arbre_image, s], Vector2i(0, -585)]])


# --- Animation ----------------------------------------------------------------------------------------------

func _process(delta: float) -> void:
	_placer_plans()
	if not _taches.is_empty() and _recolter():
		if _taches.is_empty() and saison != "ete":
			_preparer_saison(saison)
		_maj_arbres()
		for a in _arbres:
			(a[0] as Mobile).queue_redraw()
		_premier_plan.queue_redraw()
	if _taches.is_empty() and not _prechauffe.is_empty():
		var p: Array = _prechauffe.pop_front()
		if GrillePixel.existe(p[0]):
			GrillePixel.texture(p[0], p[1])
	if not anime:
		return
	_meteo.avancer(delta)
	_animer_feuilles(delta)
	_nuage_t += delta
	if _nuage_t >= 1.4:
		_nuage_t -= 1.4
		for i in _nuages_x.size():
			_nuages_x[i] += 1.0
			if _nuages_x[i] > DROITE + 900:
				_nuages_x[i] = GAUCHE - 900
	_arbre_t += delta
	if _arbre_t >= 1.0:
		_arbre_t -= 1.0
		_arbre_image = 1 - _arbre_image
		_maj_arbres()
	var phares: Array = []
	if melange > 0.0:
		for v in voitures:
			phares.append(v.call("point_phare"))
	_halos_phares.centres = phares
	_halos_phares.queue_redraw()


## Plans en parallaxe (nuages 0,1 ; skyline 0,15) et arbre de premier plan contre le bord droit de la vue.
func _placer_plans() -> void:
	var cx := vue.get_center().x
	for i in _nuages.size():
		var n: Node2D = _nuages[i]
		var x := roundi(_nuages_x[i] + cx * 0.9)
		if n.position.x != x:
			n.position.x = x
	if _skyline != null:
		var sx := roundi(cx * 0.85)
		if _skyline.position.x != sx:
			_skyline.position.x = sx
	var p := Vector2(int(vue.end.x) - PREMIER_PLAN_MARGE, 495)
	if _premier_plan.position != p:
		_premier_plan.position = p


func _animer_feuilles(delta: float) -> void:
	var visibles := saison in ["automne", "ete"]
	for f in _feuilles:
		var m: Mobile = f[0]
		m.visible = visibles
		f[3] += delta
		if f[2] <= 0.0 or f[2] > SOL + 10:
			f[1] = _premier_plan.position.x - _rng.randi_range(45, 390)
			f[2] = _rng.randi_range(60, 165)
		f[1] -= (14.0 + 6.0 * sin(f[3] * 1.7)) * delta
		f[2] += (10.0 + 7.0 * sin(f[3] * 2.3)) * delta
		m.position = Vector2(int(f[1] + 4.0 * sin(f[3] * 2.0)), int(f[2]))
		m.poser([["rue/feuille_%d" % (int(f[3] * 3.0) % 2), Vector2i.ZERO]])


## Pose déterministe pour les captures (nuages, Gérard, feuilles).
func preparer_capture() -> void:
	for i in _nuages_x.size():
		_nuages_x[i] = float(GAUCHE + i * 420 + [0, 40, -30, 60, 10, -50, 30, 0, 20][i])
	if gerard != null:
		gerard.call("poser_capture", 66.0, 1)
	_arbre_image = 0
	_maj_arbres()
	_placer_plans()
	var poses_f := [Vector2(-105, 225), Vector2(-255, 318), Vector2(-375, 180)]
	for i in _feuilles.size():
		var fe: Array = _feuilles[i]
		fe[1] = _premier_plan.position.x + poses_f[i].x
		fe[2] = poses_f[i].y
		fe[3] = i * 2.1


func figurines_planche() -> Array:
	return ["gerard", "tata", "matelas", "jeanmi", "lopez", "lefranc", "passant_1", "passant_2", "passant_3"]
