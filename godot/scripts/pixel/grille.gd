class_name GrillePixel
extends RefCounted
## Catalogue des images pixel : grilles de texte (res://data/pixel/<dossier>/*.txt, format décrit dans
## data/pixel/LISEZMOI.md) et images générées par code (MatieresPixel), sous un nom unique
## « <dossier>/<nom> ». Chaque image existe en 3 variantes (jour, nuit, orage), calculées à la demande
## par PalettePixel.convertir puis gardées en cache, avec leur texture.

const RACINE := "res://data/pixel"
const _RESERVES := ".#: "

static var _images := {}      # nom -> {"image": Image, "origine": Vector2i, "source": String}
static var _cache := {}       # "nom|variante" -> Image
static var _textures := {}    # "nom|variante" -> ImageTexture
static var _erreurs := PackedStringArray()


## Analyse un texte de grilles, sans effet de bord ni push_error.
## Renvoie {"images": {nom_complet: {"image": Image, "origine": Vector2i}}, "erreurs": PackedStringArray}.
static func analyser(texte: String, dossier: String, source := "") -> Dictionary:
	var images := {}
	var erreurs := PackedStringArray()
	var legende := {}            # lettre -> Color (alpha compris)
	var src := source if source != "" else "texte"
	var lignes := texte.replace("\r", "").split("\n")
	if lignes.size() > 0 and lignes[0].begins_with("﻿"):
		lignes[0] = lignes[0].substr(1)
	# Image en cours de lecture
	var nom := ""
	var largeur := 0
	var hauteur := 0
	var origine := Vector2i(-1, -1)
	var rangees: Array = []
	var debut := 0
	var lettres_inconnues := {}
	var i := 0
	while i <= lignes.size():
		var brute: String = lignes[i] if i < lignes.size() else ""
		var fin_de_texte := i == lignes.size()
		var ligne := brute.strip_edges()
		var ou := "%s:%d" % [src, i + 1]
		# Lecture des rangées d'une image
		if nom != "" and rangees.size() < hauteur:
			var est_rangee := not fin_de_texte and ligne != "" and not ligne.begins_with("#") \
				and not ligne.begins_with(":") and not ligne.begins_with("image ")
			if est_rangee:
				if ligne.length() != largeur:
					erreurs.append("%s : %s : rangée %d de %d caractères au lieu de %d" % [ou, nom, rangees.size() + 1, ligne.length(), largeur])
				rangees.append(ligne)
				if rangees.size() == hauteur:
					_terminer(images, erreurs, dossier, nom, largeur, hauteur, origine, rangees, legende, src, debut, lettres_inconnues)
					nom = ""
				i += 1
				continue
			if ligne.begins_with("#") and not fin_de_texte:
				i += 1
				continue
			erreurs.append("%s:%d : %s : %d rangées au lieu de %d" % [src, debut, nom, rangees.size(), hauteur])
			nom = ""
			# la ligne courante est traitée ci-dessous (en-tête, légende…)
		if fin_de_texte:
			break
		if ligne == "" or ligne.begins_with("#"):
			i += 1
			continue
		var utile := _sans_commentaire(ligne)
		if utile.begins_with(":"):
			var parties := utile.substr(1).strip_edges().split(" ", false)
			if parties.size() < 2 or parties.size() > 3:
				erreurs.append("%s : légende illisible « %s » (attendu « : <lettre> <couleur> [alpha %%] »)" % [ou, utile])
			else:
				var lettre: String = parties[0]
				var couleur: String = parties[1]
				var alpha := 100
				var ok := true
				if lettre.length() != 1 or _RESERVES.contains(lettre) or lettre.unicode_at(0) < 33:
					erreurs.append("%s : lettre de légende invalide « %s »" % [ou, lettre])
					ok = false
				if not PalettePixel.existe(couleur):
					erreurs.append("%s : couleur inconnue « %s »" % [ou, couleur])
					ok = false
				if parties.size() == 3:
					if not parties[2].is_valid_int() or int(parties[2]) < 1 or int(parties[2]) > 100:
						erreurs.append("%s : alpha invalide « %s » (1 à 100)" % [ou, parties[2]])
						ok = false
					else:
						alpha = int(parties[2])
				if ok:
					var c := PalettePixel.couleur(couleur)
					c.a = alpha / 100.0
					legende[lettre] = c
		elif utile.begins_with("image ") or utile == "image":
			var p := utile.split(" ", false)
			var ok := true
			var n := ""
			var dims := Vector2i.ZERO
			var o := Vector2i(-1, -1)
			if p.size() != 3 and p.size() != 5:
				ok = false
			else:
				n = p[1]
				var d := p[2].split("x")
				if d.size() != 2 or not d[0].is_valid_int() or not d[1].is_valid_int() or int(d[0]) < 1 or int(d[1]) < 1:
					ok = false
				else:
					dims = Vector2i(int(d[0]), int(d[1]))
				if p.size() == 5:
					var oo := p[4].split(",")
					if p[3] != "origine" or oo.size() != 2 or not oo[0].is_valid_int() or not oo[1].is_valid_int():
						ok = false
					else:
						o = Vector2i(int(oo[0]), int(oo[1]))
			if not ok:
				erreurs.append("%s : en-tête illisible « %s » (attendu « image <nom> <L>x<H> [origine x,y] »)" % [ou, utile])
			elif not _nom_valide(n):
				erreurs.append("%s : nom d'image invalide « %s » (lettres minuscules, chiffres, _)" % [ou, n])
			else:
				nom = n
				largeur = dims.x
				hauteur = dims.y
				origine = o
				rangees = []
				debut = i + 1
				lettres_inconnues = {}
		else:
			erreurs.append("%s : ligne inattendue « %s »" % [ou, ligne.left(40)])
		i += 1
	return {"images": images, "erreurs": erreurs}


static func _sans_commentaire(ligne: String) -> String:
	var k := ligne.find(" #")
	return ligne.left(k).strip_edges() if k >= 0 else ligne


static func _nom_valide(n: String) -> bool:
	if n == "":
		return false
	for c in n:
		if not ((c >= "a" and c <= "z") or (c >= "0" and c <= "9") or c == "_"):
			return false
	return true


static func _terminer(images: Dictionary, erreurs: PackedStringArray, dossier: String, nom: String, largeur: int,
		hauteur: int, origine: Vector2i, rangees: Array, legende: Dictionary, src: String, debut: int,
		lettres_inconnues: Dictionary) -> void:
	var complet := dossier + "/" + nom
	if images.has(complet):
		erreurs.append("%s:%d : nom en double « %s »" % [src, debut, complet])
		return
	var img := Image.create_empty(largeur, hauteur, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in rangees.size():
		var r: String = rangees[y]
		for x in mini(r.length(), largeur):
			var ch := r[x]
			if ch == ".":
				continue
			if legende.has(ch):
				img.set_pixel(x, y, legende[ch])
			elif not lettres_inconnues.has(ch):
				lettres_inconnues[ch] = true
				erreurs.append("%s:%d : %s : lettre « %s » sans légende" % [src, debut + y + 1, nom, ch])
	var o := origine
	if o == Vector2i(-1, -1):
		o = Vector2i(largeur / 2, hauteur - 1)
	images[complet] = {"image": img, "origine": o}


## Charge tous les .txt de res://data/pixel/<dossier>/ (ordre alphabétique) et les enregistre.
## Chaque erreur : push_error et ajout à erreurs(). Dossier absent : 0, sans erreur.
## Renvoie le nombre d'images enregistrées.
static func charger_dossier(dossier: String) -> int:
	var chemin := RACINE.path_join(dossier)
	if not DirAccess.dir_exists_absolute(chemin):
		return 0
	var fichiers := Array(DirAccess.get_files_at(chemin))
	fichiers.sort()
	var total := 0
	for f in fichiers:
		if not String(f).ends_with(".txt"):
			continue
		var source := chemin.path_join(f)
		var texte := FileAccess.get_file_as_string(source)
		if texte == "" and FileAccess.get_open_error() != OK:
			_erreur("GrillePixel : lecture impossible de %s" % source)
			continue
		var r := analyser(texte, dossier, source)
		for e in r["erreurs"]:
			_erreur("GrillePixel : " + e)
		for n in r["images"]:
			var deja: Dictionary = _images.get(n, {})
			if not deja.is_empty() and deja.get("source", "") != source:
				_erreur("GrillePixel : nom en double « %s » (%s et %s)" % [n, deja.get("source", ""), source])
				continue
			_poser(n, r["images"][n]["image"], r["images"][n]["origine"], source)
			total += 1
	return total


static func _erreur(e: String) -> void:
	_erreurs.append(e)
	push_error(e)


## Enregistre (ou remplace) une image produite par code. Origine par défaut : milieu du bas.
static func enregistrer(nom: String, image: Image, origine := Vector2i(-1, -1)) -> void:
	var img := image
	if img.get_format() != Image.FORMAT_RGBA8:
		img = Image.new()
		img.copy_from(image)
		img.convert(Image.FORMAT_RGBA8)
	var o := origine
	if o == Vector2i(-1, -1):
		o = Vector2i(img.get_width() / 2, img.get_height() - 1)
	_poser(nom, img, o, "code")


static func _poser(nom: String, img: Image, origine: Vector2i, source: String) -> void:
	_images[nom] = {"image": img, "origine": origine, "source": source}
	for v in [PalettePixel.JOUR, PalettePixel.NUIT, PalettePixel.ORAGE]:
		_cache.erase("%s|%d" % [nom, v])
		_textures.erase("%s|%d" % [nom, v])


static func existe(nom: String) -> bool:
	return _images.has(nom)


## Image d'une variante (en cache : ne pas la modifier). Nom inconnu : push_error, null.
static func image(nom: String, variante := PalettePixel.JOUR) -> Image:
	if not _images.has(nom):
		push_error("GrillePixel : image inconnue « %s »" % nom)
		return null
	if variante == PalettePixel.JOUR:
		return _images[nom]["image"]
	var k := "%s|%d" % [nom, variante]
	if not _cache.has(k):
		_cache[k] = PalettePixel.convertir(_images[nom]["image"], PalettePixel.JOUR, variante)
	return _cache[k]


## Texture d'une variante (en cache). Nom inconnu : push_error, null.
static func texture(nom: String, variante := PalettePixel.JOUR) -> ImageTexture:
	var k := "%s|%d" % [nom, variante]
	if not _textures.has(k):
		var img := image(nom, variante)
		if img == null:
			return null
		_textures[k] = ImageTexture.create_from_image(img)
	return _textures[k]


static func origine(nom: String) -> Vector2i:
	if not _images.has(nom):
		push_error("GrillePixel : image inconnue « %s »" % nom)
		return Vector2i.ZERO
	return _images[nom]["origine"]


static func taille(nom: String) -> Vector2i:
	if not _images.has(nom):
		return Vector2i.ZERO
	return _images[nom]["image"].get_size()


static func noms() -> PackedStringArray:
	var n := PackedStringArray(_images.keys())
	n.sort()
	return n


static func erreurs() -> PackedStringArray:
	return _erreurs
