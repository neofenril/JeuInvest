class_name RuePx0
extends Node2D
## Le monde de la preuve de concept pixel, révision PX0 bis (docs/lots/lot_px0_bis.md, docs/16 §8), en
## px d'art. Rue de briques en plein jour d'été. Repères (y vers le bas) : sol des façades SOL (296),
## trottoir de dalles 296-308, bordure 308-310, chaussée 310-332, bord d'en face 332-340.
## Maison de Gérard x 0-152 (152 × 172, cheminée à y 124) ; voisine de brique sombre à gauche ; muret à
## chaperon, arbre et lampadaire à droite ; épicerie à auvent rouge ; pignon aveugle à publicité peinte ;
## décor habillé de x -520 à 1040. Plans : ciel et cumulus, skyline bleutée (0,15), immeubles de fond
## bleutés (0,4), arbres, rue, sol, mobilier et voitures, arbre de premier plan (1,15, posé contre le bord
## droit de la vue, quel que soit le format).
##
## Jour / nuit : chaque élément est dessiné à partir des images de GrillePixel ; pendant le fondu, la
## version nuit est posée sur la version jour avec un alpha croissant, élément par élément (ordre de
## superposition respecté). Fondu terminé : une seule version. Lumières (couleur lumiere, émissive) :
## opérations « nuit seulement » ; halos : calque additif (3 disques pixellisés).

const Facades := preload("res://scripts/pixel/facades.gd")
const Vehicules := preload("res://scripts/pixel/vehicules.gd")

const SOL := 296
const TROTTOIR := 14                                     # 12 de dalles + 2 de bordure
const CHAUSSEE := 22
const BAS_CHAUSSEE := SOL + TROTTOIR + CHAUSSEE          # 332
const MONDE_GAUCHE := -520
const MONDE_DROITE := 1040
const HAUTEUR_CIEL := 480
const MAISON := Rect2(0, 124, 152, 172)
const ZONE := Rect2(-130, 124, 462, 212)                # voisine de gauche → épicerie, cheminée → bas de la chaussée
const TAILLE_GERARD := Vector2i(24, 42)
const FONDU := 3.0
const PIEDS := 304                                       # y des pieds des passants (milieu du trottoir)
const CADENCE_MARCHE := 8.0                              # images par seconde, 1 px d'art par image
const CADENCE_REPOS := 2.0
const GERARD_MIN := 20
const GERARD_MAX := 136
const PORTE_X := 76                                      # milieu de la porte de la maison
const HUMEURS := ["sylvie_contente", "sylvie_neutre", "sylvie_contrariee"]
const HALOS := [[30, 0.08], [19, 0.16], [10, 0.28]]      # rayon, alpha (docs/16 §2.4)
const HALOS_PHARE := [[10, 0.12], [5, 0.3]]              # phares : 2 disques plus petits
const DERIVE_NUAGES := 2.0                               # secondes par px d'art
const Y_VOITURE := 331                                   # bas des roues, voie proche
const Y_VOITURE_GAREE := 321                             # bas des roues, le long du trottoir
const VITESSE_VOITURE := 36.0                            # px d'art par seconde
const PASSAGE_PIETON := Rect2i(168, 312, 60, 19)
const PREMIER_PLAN_MARGE := 24                           # tronc à cette distance du bord droit de la vue

## Bâtiments de la rue : [x gauche, réglages de Facades.batiment()].
const BATIMENTS := [
	[-520, {"l": 120, "brique": "claire", "etages": 2, "toit": "ardoise", "rdc": "porte", "porte": "vert", "graine": 31}],
	[-400, {"l": 150, "brique": "classique", "etages": 3, "toit": "plat", "rdc": "boutique", "enseigne": "CAFE", "auvent": "vert", "devanture": "bois", "graine": 32}],
	[-250, {"l": 120, "brique": "vive", "etages": 1, "toit": "tuiles", "rdc": "porte", "porte": "rouge", "graine": 21}],
	[-130, {"l": 130, "brique": "sombre", "etages": 2, "toit": "ardoise", "h_toit": 40, "rdc": "porte", "porte": "bleu", "graine": 22}],
	[204, {"l": 128, "brique": "claire", "etages": 1, "toit": "plat", "rdc": "boutique", "enseigne": "EPICERIE", "auvent": "rouge_auvent", "devanture": "sarcelle", "graine": 23}],
	[332, {"l": 88, "brique": "classique", "etages": 3, "toit": "pignon", "h_toit": 30, "aveugle": true, "pub": "CHOCOLAT|AU LAIT", "rdc": "garage", "graine": 24}],
	[440, {"l": 120, "brique": "vive", "etages": 2, "toit": "ardoise", "rdc": "porte", "porte": "sarcelle", "graine": 25}],
	[560, {"l": 124, "brique": "sombre", "etages": 3, "toit": "plat", "rdc": "porte", "porte": "rouge", "graine": 26}],
	[684, {"l": 116, "brique": "claire", "etages": 1, "toit": "tuiles", "rdc": "boutique", "enseigne": "BOULANGERIE", "auvent": "sarcelle", "devanture": "bois", "graine": 27}],
	[800, {"l": 120, "brique": "classique", "etages": 2, "toit": "ardoise", "rdc": "porte", "porte": "vert", "graine": 28}],
	[920, {"l": 120, "brique": "vive", "etages": 2, "toit": "plat", "rdc": "boutique", "enseigne": "TABAC", "auvent": "rouge_auvent", "devanture": "rouge_auvent", "graine": 29}],
]
## Immeubles de fond (plan 0,4, bleutés) : [x gauche, largeur, étages, toit, graine].
const FONDS := [
	[-470, 100, 2, "plat", 51], [-300, 110, 2, "ardoise", 52], [236, 84, 2, "ardoise", 54],
	[500, 100, 3, "plat", 56], [740, 110, 2, "ardoise", 57], [890, 90, 2, "plat", 58],
]
## Arbres derrière les bâtiments : [x du milieu, largeur, hauteur, graine].
const ARBRES := [[178, 96, 150, 3], [-150, 110, 170, 41], [430, 92, 146, 37], [690, 100, 160, 43], [-380, 90, 120, 47]]
const LAMPADAIRES := [190, -300, 560, 900]
const MURET := Rect2i(152, 268, 52, 28)

var _melange := 0.0          # 0 = jour, 1 = nuit
var _nuit := false
var _humeur := 0
var _fige := false
var _lumieres_visibles := true
var _tween: Tween = null
var _couches: Array = []
var _mobiles: Array = []
var _lumieres: Node2D = null
var _planche: Node2D = null
var _rng := RandomNumberGenerator.new()

# Animation
var _gerard: Mobile
var _sylvie: Mobile
var _voiture: Mobile
var _premier_plan: Mobile
var _halo_phare: Halos
var _nuages: Array = []
var _arbres: Array = []
var _g_x := 60.0
var _g_dir := 1
var _g_image := 0
var _g_repos := 0.0          # temps de repos restant devant la porte
var _g_passe_porte := false
var _g_t := 0.0
var _v_x := -560.0
var _v_attente := 0.0
var _v_t := 0.0
var _v_image := 0
var _nuage_t := 0.0
var _arbre_t := 0.0
var _arbre_image := 0
var _cligne_t := 3.0
var _cligne_fin := 0.0
static var _fenetres := {}   # nom d'image du décor -> fenêtres (Rect2i locaux), remplies par generer_decor()
static var _voitures := {}   # modèle -> {"roues", "phare", "feu", "taille"}


## Élément fixe dessiné en version jour et nuit. ops : {"image": nom, "pos": Vector2i, "repeter_x": int,
## "nuit": bool} ou {"rect": Rect2i, "couleur": nom, "nuit": bool} (nuit = seulement la nuit).
class Couche extends Node2D:
	var rue: RuePx0
	var ops: Array = []

	func image(nom: String, pos: Vector2i, repeter_x := 0) -> void:
		ops.append({"image": nom, "pos": pos, "repeter_x": repeter_x, "nuit": false})
		queue_redraw()

	func rect(r: Rect2i, couleur: String, nuit := false) -> void:
		ops.append({"rect": r, "couleur": couleur, "nuit": nuit})
		queue_redraw()

	func _draw() -> void:
		var m := rue.melange()
		for op in ops:
			if op["nuit"]:
				if m > 0.0:
					_op(op, PalettePixel.NUIT, m)
				continue
			if m < 1.0:
				_op(op, PalettePixel.JOUR, 1.0)
			if m > 0.0:
				_op(op, PalettePixel.NUIT, m)

	func _op(op: Dictionary, variante: int, alpha: float) -> void:
		var teinte := Color(1, 1, 1, alpha)
		if op.has("rect"):
			draw_rect(Rect2(op["rect"]), PalettePixel.couleur_alpha(op["couleur"], alpha, variante))
			return
		var tex := GrillePixel.texture(op["image"], variante)
		if tex == null:
			return
		var pos: Vector2i = op["pos"] - GrillePixel.origine(op["image"])
		var l := tex.get_width()
		var fin: int = pos.x + maxi(int(op["repeter_x"]), l)
		var x := pos.x
		while x < fin:
			if x + l <= fin:
				draw_texture(tex, Vector2(x, pos.y), teinte)
			else:
				var reste := fin - x
				draw_texture_rect_region(tex, Rect2(x, pos.y, reste, tex.get_height()), Rect2(0, 0, reste, tex.get_height()), teinte)
			x += l


## Élément animé : ombres au sol (rectangles jour et nuit), une ou plusieurs images posées par leur
## origine (décalage), plus des rectangles « nuit seulement » (phares, globes). Position toujours entière.
class Mobile extends Node2D:
	var rue: RuePx0
	var ombres: Array = []       # [Rect2i, couleur], dessinées avant les images
	var parts: Array = []        # [nom, Vector2i décalage]
	var nuit_rects: Array = []   # [Rect2i, couleur]

	func poser(liste: Array) -> void:
		parts = liste
		queue_redraw()

	func _draw() -> void:
		var m := rue.melange()
		for o in ombres:
			if m < 1.0:
				draw_rect(Rect2(o[0]), PalettePixel.couleur(o[1], PalettePixel.JOUR))
			if m > 0.0:
				draw_rect(Rect2(o[0]), PalettePixel.couleur_alpha(o[1], m, PalettePixel.NUIT))
		for p in parts:
			if m < 1.0:
				_img(p, PalettePixel.JOUR, 1.0)
			if m > 0.0:
				_img(p, PalettePixel.NUIT, m)
		if m > 0.0:
			for r in nuit_rects:
				draw_rect(Rect2(r[0]), PalettePixel.couleur_alpha(r[1], m, PalettePixel.NUIT))

	func _img(p: Array, variante: int, alpha: float) -> void:
		var tex := GrillePixel.texture(p[0], variante)
		if tex != null:
			draw_texture(tex, Vector2(p[1] - GrillePixel.origine(p[0])), Color(1, 1, 1, alpha))


## Halos de lumière (calque additif) : disques pixellisés couleur lumiere.
class Halos extends Node2D:
	var centres: Array = []      # Vector2i
	var rayons: Array = RuePx0.HALOS

	func _draw() -> void:
		for c in centres:
			for h in rayons:
				var nom := "decor/halo_%d" % h[0]
				draw_texture(GrillePixel.texture(nom), Vector2(c - GrillePixel.origine(nom)), Color(1, 1, 1, h[1]))


func _init() -> void:
	name = "RuePx0"


func _ready() -> void:
	_rng.seed = 84
	if not GrillePixel.existe("matiere/ciel"):
		MatieresPixel.generer_tout()
	if not GrillePixel.existe("ville/gerard_marche_1"):
		GrillePixel.charger_dossier("ville")
	generer_decor()
	_construire()
	preparer_capture()


# --- Génération des images du décor (catalogue « decor/… », « miroir/… ») ---------------------------

static func generer_decor() -> void:
	if GrillePixel.existe("decor/maison"):
		return
	var maison: Dictionary = Facades.maison_gerard(7)
	GrillePixel.enregistrer("decor/maison", maison["image"], Vector2i(0, Facades.MAISON_H - 1))
	_fenetres["decor/maison"] = maison["fenetres"]
	for i in BATIMENTS.size():
		var r: Dictionary = Facades.batiment(BATIMENTS[i][1])
		var img: Image = r["image"]
		GrillePixel.enregistrer("decor/batiment_%d" % i, img, Vector2i(0, img.get_height() - 1))
		_fenetres["decor/batiment_%d" % i] = r["fenetres"]
	# Immeubles de fond : mêmes générateurs, ramenés aux 3 tons du lointain
	for i in FONDS.size():
		var f: Array = FONDS[i]
		var r2: Dictionary = Facades.batiment({"l": f[1], "etages": f[2], "toit": f[3], "rdc": "porte", "brique": "classique", "graine": f[4]})
		var pale := MatieresPixel.lointain(r2["image"])
		GrillePixel.enregistrer("decor/fond_%d" % i, pale, Vector2i(0, pale.get_height() - 1))
		_fenetres["decor/fond_%d" % i] = r2["fenetres"]
	for i in ARBRES.size():
		var a: Array = ARBRES[i]
		for im in 2:
			GrillePixel.enregistrer("decor/arbre_%d_%d" % [i, im], Facades.arbre_ete(a[1], a[2], a[3], im))
	var pp: Dictionary = Facades.arbre_premier_plan(61)
	GrillePixel.enregistrer("decor/premier_plan_tronc", pp["tronc"], Vector2i(0, 0))
	GrillePixel.enregistrer("decor/premier_plan_0", pp["houppier"], Vector2i(0, 0))
	GrillePixel.enregistrer("decor/premier_plan_1", pp["houppier_2"], Vector2i(0, 0))
	GrillePixel.enregistrer("decor/muret", Facades.muret(MURET.size.x, MURET.size.y - 6, 9), Vector2i(0, MURET.size.y - 1))
	GrillePixel.enregistrer("decor/haie", Facades.haie(48, 16, 5), Vector2i(0, 15))
	# Plaque de rue bleue émaillée « RUE DES ÉPARGNANTS » (illisible à cette taille : simple plaque)
	var plaque := MatieresPixel.vide(22, 9)
	MatieresPixel.rect(plaque, 0, 0, 22, 9, "blanc_chaud")
	MatieresPixel.rect(plaque, 1, 1, 20, 7, "bleu_vif")
	MatieresPixel.cadre(plaque, 2, 2, 18, 5, "blanc_chaud")
	for x in range(4, 18, 2):
		MatieresPixel.px(plaque, x, 4, "blanc_chaud")
	MatieresPixel.rect(plaque, 1, 8, 20, 1, "bleu_ardoise")
	GrillePixel.enregistrer("decor/plaque", plaque, Vector2i(0, 0))
	for h in HALOS + HALOS_PHARE:
		GrillePixel.enregistrer("decor/halo_%d" % h[0], MatieresPixel.disque(h[0], "lumiere"), Vector2i(h[0], h[0]))
	# Voitures (caisses et roues)
	for modele in ["r5", "205"]:
		var v: Dictionary = Vehicules.caisse(modele)
		GrillePixel.enregistrer("decor/voiture_" + modele, v["image"], v["origine"])
		_voitures[modele] = {"roues": v["roues"], "phare": v["phare"], "feu": v["feu"], "taille": (v["image"] as Image).get_size(), "origine": v["origine"]}
	for i in 2:
		GrillePixel.enregistrer("decor/roue_%d" % (i + 1), Vehicules.roue(i), Vector2i(6, 11))
	# Miroirs des figurines (marche vers la gauche) : retournées au pixel près
	for n in GrillePixel.noms():
		if n.begins_with("ville/gerard_"):
			var img := Image.new()
			img.copy_from(GrillePixel.image(n))
			img.flip_x()
			var o := GrillePixel.origine(n)
			GrillePixel.enregistrer("miroir/" + n.get_file(), img, Vector2i(img.get_width() - 1 - o.x, o.y))


## Fenêtres (rectangles locaux) d'une image du décor.
static func fenetres(nom: String) -> Array:
	return _fenetres.get(nom, [])


# --- Construction de la scène ----------------------------------------------------------------------

func _construire() -> void:
	var largeur := MONDE_DROITE - MONDE_GAUCHE
	# Ciel (plan 0) et étoiles (nuit seulement)
	var ciel := _couche("Ciel")
	ciel.rect(Rect2i(MONDE_GAUCHE, SOL - HAUTEUR_CIEL - 400, largeur, 401), "ciel_haut")
	ciel.image("matiere/ciel", Vector2i(MONDE_GAUCHE, SOL - 1), largeur)
	for i in 50:
		var ex := _rng.randi_range(MONDE_GAUCHE, MONDE_DROITE)
		var ey := _rng.randi_range(-60, 120)
		ciel.rect(Rect2i(ex, ey, 1, 1), "blanc_chaud", true)
	# Cumulus (dérive lente)
	for i in 5:
		var n := _mobile("Nuage%d" % (i + 1))
		n.poser([["matiere/cumulus_%d" % ([1, 2, 3, 2, 1][i]), Vector2i.ZERO]])
		_nuages.append(n)
	# Skyline lointaine (plan 0,15)
	var loin := _couche("Skyline")
	loin.image("matiere/skyline", Vector2i(MONDE_GAUCHE, SOL - 1), largeur)
	# Immeubles de fond bleutés (plan 0,4) et quelques fenêtres allumées la nuit
	var fond := _couche("Fond")
	for i in FONDS.size():
		var nom := "decor/fond_%d" % i
		var x: int = FONDS[i][0]
		fond.image(nom, Vector2i(x, SOL - 1))
		var img := GrillePixel.image(nom)
		_allumer(fond, fenetres(nom), Vector2i(x, SOL - img.get_height()), 0.2, 600 + i)
	# Arbres derrière les bâtiments (seul l'espace libre les montre)
	for i in ARBRES.size():
		var a := _mobile("Arbre%d" % i)
		a.position = Vector2(ARBRES[i][0], SOL - 1)
		_arbres.append([a, "decor/arbre_%d_" % i])
	# Bâtiments de la rue
	var rue := _couche("Batiments")
	for i in BATIMENTS.size():
		var nom := "decor/batiment_%d" % i
		var bx: int = BATIMENTS[i][0]
		rue.image(nom, Vector2i(bx, SOL - 1))
		var h := GrillePixel.image(nom).get_height()
		_allumer(rue, fenetres(nom), Vector2i(bx, SOL - h), 0.35, 700 + i)
	# Maison de Gérard : toutes ses fenêtres s'allument la nuit
	var maison := _couche("Maison")
	maison.image("decor/maison", Vector2i(int(MAISON.position.x), SOL - 1))
	_allumer(maison, fenetres("decor/maison"), Vector2i(MAISON.position), 1.0, 0)
	# Sylvie à sa fenêtre (au-dessus de la lumière de la pièce)
	_sylvie = _mobile("Sylvie")
	var fs: Rect2i = Facades.FENETRE_SYLVIE
	_sylvie.position = Vector2(MAISON.position.x + fs.position.x + fs.size.x / 2, MAISON.position.y + fs.end.y - 1)
	_maj_sylvie()
	# Haie et muret à chaperon
	var jardin := _couche("Muret")
	jardin.image("decor/haie", Vector2i(MURET.position.x + 2, SOL - 18))
	jardin.image("decor/muret", Vector2i(MURET.position.x, SOL - 1))
	# Sol : trottoir de dalles et bordure, chaussée, passage piéton, bord d'en face, remplissage
	var sol := _couche("Sol")
	sol.image("matiere/trottoir", Vector2i(MONDE_GAUCHE, SOL), largeur)
	sol.image("matiere/chaussee", Vector2i(MONDE_GAUCHE, SOL + TROTTOIR), largeur)
	var pp := PASSAGE_PIETON
	sol.rect(Rect2i(pp.position.x - 2, SOL + TROTTOIR + 10, pp.size.x + 4, 2), "goudron")
	for y in range(pp.position.y, pp.end.y, 5):
		sol.rect(Rect2i(pp.position.x, y, pp.size.x, 3), "blanc_chaud")
		sol.rect(Rect2i(pp.position.x, y + 2, pp.size.x, 1), "zinc_clair")
	sol.image("matiere/bord_en_face", Vector2i(MONDE_GAUCHE, BAS_CHAUSSEE), largeur)
	sol.rect(Rect2i(MONDE_GAUCHE, BAS_CHAUSSEE + 8, largeur, 400), "dalle")
	# Ombres portées en aplat au pied des façades (lumière en haut à gauche)
	sol.rect(Rect2i(MONDE_GAUCHE, SOL, largeur, 1), "dalle_ombre")
	# Mobilier : lampadaires (globes allumés la nuit), poteau d'incendie, boîte aux lettres
	var mob := _couche("Mobilier")
	var centres: Array = []
	for lx in LAMPADAIRES:
		mob.rect(Rect2i(lx - 2, 302, 10, 2), "dalle_ombre")
		mob.image("ville/lampadaire", Vector2i(lx, 302))
		if lx == LAMPADAIRES[0]:
			mob.image("decor/plaque", Vector2i(lx - 11, 238))
		var coin := Vector2i(lx, 302) - GrillePixel.origine("ville/lampadaire")
		mob.rect(Rect2i(coin + Vector2i(2, 7), Vector2i(6, 2)), "lumiere", true)
		mob.rect(Rect2i(coin + Vector2i(3, 9), Vector2i(4, 1)), "lumiere", true)
		centres.append(coin + Vector2i(5, 8))
	mob.rect(Rect2i(-26, 301, 10, 2), "dalle_ombre")
	mob.image("ville/bouche_incendie", Vector2i(-22, 302))
	mob.rect(Rect2i(344, 301, 10, 2), "dalle_ombre")
	mob.image("ville/boite_poste", Vector2i(348, 302))
	# Voiture grise garée le long du trottoir
	var garee := _mobile("VoitureGrise")
	garee.position = Vector2(-84, Y_VOITURE_GAREE)
	garee.ombres = [[Rect2i(-30, -2, 60, 3), "ardoise_sombre"]]
	garee.poser(_parts_voiture("205", 0, 0))
	# Gérard, puis la R5 rouge qui passe sur la voie proche
	_gerard = _mobile("Gerard")
	_gerard.ombres = [[Rect2i(-7, -1, 14, 3), "dalle_ombre"]]
	_voiture = _mobile("VoitureRouge")
	_voiture.ombres = [[Rect2i(-31, -2, 62, 3), "ardoise_sombre"]]
	# Arbre de premier plan (plan 1,15), contre le bord droit de la vue
	_premier_plan = _mobile("PremierPlan")
	_premier_plan.z_index = 10
	_premier_plan.poser([["decor/premier_plan_0", Vector2i(-160, -372)], ["decor/premier_plan_tronc", Vector2i(0, -344)]])
	# Calque des lumières (mélange additif), visible la nuit seulement
	_lumieres = Node2D.new()
	_lumieres.name = "Lumieres"
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_lumieres.material = mat
	_lumieres.z_index = 50
	add_child(_lumieres)
	var halos := Halos.new()
	halos.centres = centres
	halos.use_parent_material = true
	_lumieres.add_child(halos)
	_halo_phare = Halos.new()
	_halo_phare.rayons = HALOS_PHARE
	_halo_phare.use_parent_material = true
	_lumieres.add_child(_halo_phare)
	_maj_lumieres()


## Parties d'une voiture (caisse + 2 roues), roues à l'image im, caisse abaissée de bas px.
func _parts_voiture(modele: String, im: int, bas: int) -> Array:
	var v: Dictionary = _voitures[modele]
	var o: Vector2i = v["origine"]
	var roue := "decor/roue_%d" % (im % 2 + 1)
	var parts := [["decor/voiture_" + modele, Vector2i(0, bas)]]
	for rx in v["roues"]:
		parts.append([roue, Vector2i(int(rx) - o.x, 0)])
	return parts


## Ajoute des vitres allumées (nuit seulement) : part = proportion allumée (1 = toutes).
func _allumer(c: Couche, liste: Array, coin: Vector2i, part: float, graine: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = graine
	for f in liste:
		var r: Rect2i = f
		if part >= 1.0 or rng.randf() < part:
			c.rect(Rect2i(coin + r.position, r.size), "lumiere", true)


func _couche(n: String) -> Couche:
	var c := Couche.new()
	c.name = n
	c.rue = self
	add_child(c)
	_couches.append(c)
	return c


func _mobile(n: String) -> Mobile:
	var m := Mobile.new()
	m.name = n
	m.rue = self
	add_child(m)
	_mobiles.append(m)
	return m


func melange() -> float:
	return _melange


func _set_melange(v: float) -> void:
	_melange = clampf(v, 0.0, 1.0)
	for c in _couches:
		c.queue_redraw()
	for m in _mobiles:
		m.queue_redraw()
	_maj_lumieres()


func _maj_lumieres() -> void:
	if _lumieres != null:
		_lumieres.visible = _lumieres_visibles and _melange > 0.0
		_lumieres.modulate = Color(1, 1, 1, _melange)


# --- Animation -------------------------------------------------------------------------------------

func _process(delta: float) -> void:
	_placer_premier_plan()
	if _fige:
		return
	_animer_gerard(delta)
	_animer_voiture(delta)
	# Cumulus : 1 px d'art toutes les DERIVE_NUAGES s, retour à gauche
	_nuage_t += delta
	if _nuage_t >= DERIVE_NUAGES:
		_nuage_t -= DERIVE_NUAGES
		for n in _nuages:
			(n as Mobile).position.x += 1
			if n.position.x > MONDE_DROITE:
				n.position.x = MONDE_GAUCHE - 120
	# Feuillages : 2 images à 1 im/s
	_arbre_t += delta
	if _arbre_t >= 1.0:
		_arbre_t -= 1.0
		_arbre_image = 1 - _arbre_image
		_maj_arbres()
	# Sylvie cligne des yeux toutes les 3 à 6 s (120 ms)
	_cligne_t -= delta
	if _cligne_t <= 0.0:
		_cligne_fin = 0.12
		_cligne_t = _rng.randf_range(3.0, 6.0)
		_maj_sylvie()
	elif _cligne_fin > 0.0:
		_cligne_fin -= delta
		if _cligne_fin <= 0.0:
			_maj_sylvie()


## Arbre de premier plan : tronc à PREMIER_PLAN_MARGE px du bord droit de la vue (lu sur la caméra du
## SubViewport), à une position entière.
func _placer_premier_plan() -> void:
	if _premier_plan == null or not is_inside_tree():
		return
	var vp := get_viewport()
	var cam := vp.get_camera_2d() if vp != null else null
	if cam == null:
		return
	var droite := int(cam.position.x) + int(vp.get_visible_rect().size.x)
	var p := Vector2(droite - PREMIER_PLAN_MARGE, 330)
	if _premier_plan.position != p:
		_premier_plan.position = p


func _animer_gerard(delta: float) -> void:
	if _g_repos > 0.0:
		_g_repos -= delta
		_g_t += delta
		if _g_t >= 1.0 / CADENCE_REPOS:
			_g_t -= 1.0 / CADENCE_REPOS
			_g_image = 1 - _g_image
			_maj_gerard()
		if _g_repos <= 0.0:
			_g_image = 0
			_g_t = 0.0
			_maj_gerard()
		return
	_g_t += delta
	while _g_t >= 1.0 / CADENCE_MARCHE:
		_g_t -= 1.0 / CADENCE_MARCHE
		_g_image = (_g_image + 1) % 4
		_g_x += _g_dir
		if _g_x >= GERARD_MAX or _g_x <= GERARD_MIN:
			_g_dir = -_g_dir
		if int(_g_x) == PORTE_X:
			_g_passe_porte = not _g_passe_porte
			if _g_passe_porte:
				_g_repos = 3.0                          # une fois sur deux, il s'arrête devant sa porte
				_g_image = 0
				_g_t = 0.0
				break
	_maj_gerard()


func _maj_gerard() -> void:
	_gerard.position = Vector2(int(_g_x), PIEDS)
	var dossier := "ville/" if _g_dir > 0 else "miroir/"
	var nom := ("gerard_repos_%d" % (_g_image + 1)) if _g_repos > 0.0 else ("gerard_marche_%d" % (_g_image + 1))
	_gerard.poser([[dossier + nom, Vector2i.ZERO]])


func _animer_voiture(delta: float) -> void:
	if _v_attente > 0.0:
		_v_attente -= delta
		return
	_v_x += VITESSE_VOITURE * delta
	_v_t += delta
	if _v_t >= 1.0 / 8.0:
		_v_t -= 1.0 / 8.0
		_v_image = (_v_image + 1) % 4
	if _v_x > MONDE_DROITE + 60:
		_v_x = MONDE_GAUCHE - 60
		_v_attente = 4.0
	_maj_voiture()


func _maj_voiture() -> void:
	_voiture.position = Vector2(int(_v_x), Y_VOITURE)
	var bas := -1 if _v_image == 3 else 0      # caisse relevée 1 image sur 4 (suspension)
	_voiture.poser(_parts_voiture("r5", _v_image, bas))
	var v: Dictionary = _voitures["r5"]
	var o: Vector2i = v["origine"]
	var ph: Rect2i = v["phare"]
	var fe: Rect2i = v["feu"]
	_voiture.nuit_rects = [[Rect2i(ph.position - o + Vector2i(0, bas), ph.size), "lumiere"],
		[Rect2i(fe.position - o + Vector2i(0, bas), fe.size), "ambre"]]
	if _halo_phare != null:
		_halo_phare.centres = [Vector2i(int(_v_x), Y_VOITURE) + ph.position - o + Vector2i(2, 1 + bas)]
		_halo_phare.queue_redraw()


func _maj_arbres() -> void:
	for a in _arbres:
		(a[0] as Mobile).poser([[a[1] + str(_arbre_image), Vector2i.ZERO]])
	if _premier_plan != null:
		_premier_plan.poser([["decor/premier_plan_%d" % _arbre_image, Vector2i(-160, -372)], ["decor/premier_plan_tronc", Vector2i(0, -344)]])


func _maj_sylvie() -> void:
	var parts := [["ville/" + HUMEURS[_humeur], Vector2i.ZERO]]
	if _cligne_fin > 0.0:
		parts.append(["ville/sylvie_cligne", Vector2i.ZERO])
	_sylvie.poser(parts)


# --- API (lot PX0 §2.4, signatures inchangées) -----------------------------------------------------

## Zone qui doit toujours être visible (px d'art) : du haut de la cheminée au bas de la chaussée,
## de la voisine de gauche à l'épicerie.
func zone_utile() -> Rect2:
	return ZONE


## Passe en nuit (ou en jour) avec un fondu de « fondu » secondes (0 = immédiat).
func regler_nuit(nuit: bool, fondu := FONDU) -> void:
	_nuit = nuit
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var cible := 1.0 if nuit else 0.0
	if fondu <= 0.0:
		_set_melange(cible)
		return
	_tween = create_tween()
	_tween.tween_method(_set_melange, _melange, cible, fondu * absf(cible - _melange))


func est_nuit() -> bool:
	return _nuit


## Vrai quand aucun fondu n'est en cours.
func fondu_termine() -> bool:
	return _melange == (1.0 if _nuit else 0.0)


## Humeur de Sylvie à la fenêtre : 0 contente, 1 neutre, 2 contrariée.
func regler_humeur_sylvie(h: int) -> void:
	_humeur = clampi(h, 0, 2)
	_maj_sylvie()


func humeur_sylvie() -> int:
	return _humeur


## Arrête (ou relance) ce qui bouge : marche, voiture, nuages, arbres, clignements. Le fondu continue.
func figer(f: bool) -> void:
	_fige = f
	if f and _cligne_fin > 0.0:
		_cligne_fin = 0.0
		_maj_sylvie()


func est_fige() -> bool:
	return _fige


## Pose déterministe pour les captures : Gérard devant la maison (marche, image 2), nuages et R5 placés.
func preparer_capture() -> void:
	_g_x = 44.0
	_g_dir = 1
	_g_image = 1
	_g_repos = 0.0
	_g_t = 0.0
	_g_passe_porte = true
	_maj_gerard()
	_v_x = 296.0
	_v_attente = 0.0
	_v_image = 0
	_maj_voiture()
	var poses := [Vector2(-196, 40), Vector2(40, 52), Vector2(214, 72), Vector2(420, 46), Vector2(-440, 60)]
	for i in _nuages.size():
		(_nuages[i] as Mobile).position = poses[i]
	_arbre_image = 0
	_maj_arbres()
	_cligne_fin = 0.0
	_cligne_t = 3.0
	_maj_sylvie()
	_placer_premier_plan()


## Affiche ou masque le calque additif (masqué pendant le contrôle de palette).
func afficher_lumieres(v: bool) -> void:
	_lumieres_visibles = v
	_maj_lumieres()


## Point d'ancrage de l'étiquette « MA MAISON » : sur la chaussée, sous le milieu de la maison.
func point_etiquette_maison() -> Vector2:
	return Vector2(MAISON.get_center().x, SOL + TROTTOIR + CHAUSSEE / 2.0)


func taille_gerard() -> Vector2i:
	return TAILLE_GERARD


## Position (px d'art) des pieds de Gérard (ajout, pour l'interface et les tests).
func position_gerard() -> Vector2i:
	return Vector2i(int(_g_x), PIEDS)


## Planche des sprites (étape « planche ») : fond crème couvrant la vue, sprites agrandis (Gérard ×3,
## Sylvie ×3, M. Lefranc ×2, voitures et lampadaire ×1, petits objets ×2 ou ×3, module de brique ×8),
## rangés de gauche à droite.
func afficher_planche(v: bool, vue: Rect2) -> void:
	if _planche != null:
		_planche.queue_free()
		_planche = null
	if not v:
		return
	_planche = Node2D.new()
	_planche.name = "Planche"
	_planche.z_index = 100
	add_child(_planche)
	var fond := Couche.new()
	fond.rue = self
	fond.rect(Rect2i(vue.position.floor(), vue.size.ceil()), "creme")
	_planche.add_child(fond)
	var marge := 8
	var x := int(vue.position.x) + marge
	var y := int(vue.position.y) + 36
	var hauteur_rangee := 0
	for e in sprites_planche_echelles():
		var n: String = e[0]
		var k: int = e[1]
		var tex := GrillePixel.texture(n)
		var t := tex.get_size() * k
		if x + t.x > vue.end.x - marge and x > int(vue.position.x) + marge:
			x = int(vue.position.x) + marge
			y += hauteur_rangee + 8
			hauteur_rangee = 0
		var s := Sprite2D.new()
		s.texture = tex
		s.centered = false
		s.scale = Vector2(k, k)
		s.position = Vector2(x, y)
		_planche.add_child(s)
		x += int(t.x) + 8
		hauteur_rangee = maxi(hauteur_rangee, int(t.y))


## Sprites montrés sur la planche et leur agrandissement (en px d'art).
func sprites_planche_echelles() -> Array:
	if not GrillePixel.existe("planche/r5"):
		for modele in ["r5", "205"]:
			var img := Image.new()
			img.copy_from(GrillePixel.image("decor/voiture_" + modele))
			var v: Dictionary = _voitures[modele]
			var roue := GrillePixel.image("decor/roue_1")
			for rx in v["roues"]:
				MatieresPixel.coller(img, roue, int(rx) - 6, img.get_height() - 12)
			GrillePixel.enregistrer("planche/" + modele, img)
		var module := GrillePixel.image("matiere/brique_vive").get_region(Rect2i(0, 0, 12, 9))
		GrillePixel.enregistrer("planche/brique", module)
	return [
		["ville/gerard_marche_1", 3], ["ville/gerard_marche_2", 3], ["ville/gerard_marche_3", 3],
		["ville/gerard_marche_4", 3], ["ville/gerard_repos_1", 3], ["ville/gerard_repos_2", 3],
		["planche/brique", 8],
		["ville/sylvie_contente", 3], ["ville/sylvie_neutre", 3], ["ville/sylvie_contrariee", 3],
		["ville/lefranc_affable", 2], ["planche/r5", 1], ["planche/205", 1], ["ville/lampadaire", 1],
		["ville/bouche_incendie", 3], ["ville/boite_poste", 2],
	]


## Noms des sprites de la planche (compatibilité PX0).
func sprites_planche() -> PackedStringArray:
	var noms := PackedStringArray()
	for e in sprites_planche_echelles():
		noms.append(e[0])
	return noms


## Lignes « PX0 … » propres au monde (imprimées par px0.gd avec --px0-controle).
func lignes_controle() -> PackedStringArray:
	var maison := GrillePixel.taille("decor/maison")
	var r5: Vector2i = _voitures["r5"]["taille"]
	var g205: Vector2i = _voitures["205"]["taille"]
	return PackedStringArray([
		"PX0 animation gerard marche=4 repos=2 cadence=%d" % int(CADENCE_MARCHE),
		"PX0 maison=%dx%d" % [maison.x, maison.y],
		"PX0 cadrage maison_haut=%d sol=%d trottoir=%d..%d chaussee=%d..%d passage=%d..%d" % [
			int(MAISON.position.y), SOL, SOL, SOL + TROTTOIR, SOL + TROTTOIR, BAS_CHAUSSEE,
			PASSAGE_PIETON.position.y, PASSAGE_PIETON.end.y],
		"PX0 echelle porte=%d voiture_rouge=%dx%d voiture_grise=%dx%d lampadaire=%d maison=%dx%d" % [
			Facades.PORTE.size.y, r5.x, r5.y, g205.x, g205.y, GrillePixel.taille("ville/lampadaire").y, maison.x, maison.y],
		"PX0 rue zone=%dx%d decor=%d..%d batiments=%d fonds=%d arbres=%d lampadaires=%d nuit=%s humeur=%d" % [
			int(ZONE.size.x), int(ZONE.size.y), MONDE_GAUCHE, MONDE_DROITE, BATIMENTS.size() + 1, FONDS.size(),
			ARBRES.size() + 1, LAMPADAIRES.size(), "oui" if _nuit else "non", _humeur],
		"PX0 gerard pieds=%d,%d" % [int(_g_x), PIEDS],
		"PX0 premier_plan x=%d" % int(_premier_plan.position.x),
	])
