extends SceneTree
## Tests de l'atelier pixel (lot PX0) : palette « Rue 84 », format des grilles, catalogue, générateurs
## de matières, contrôle des pixels nets. Headless :
##   Godot_console.exe --headless --path godot --script res://tests/test_pixel.gd
## Code de sortie 0 si tout passe, 1 sinon. Aucun accès à user://.

var _ok := 0
var _ko := 0

# Valeurs de jour attendues, recopiées de docs/16 §2.3 (ne pas les lire dans palette.gd).
const ATTENDU_JOUR := {
	"encre": "1C1626", "nuit": "2D2840", "ardoise_sombre": "46415C", "ardoise": "6B6880",
	"gris_pierre": "9C98A6", "zinc_clair": "C9C6CC", "creme": "F3E9D2", "blanc_chaud": "FFF9EC",
	"pierre_ombre": "8C735A", "pierre": "BFA27C", "pierre_claire": "E2CBA0", "brique_sombre": "6E2E2E",
	"brique": "A8483A", "tuile": "D06A45", "terre_cuite_claire": "E9A070", "bois_sombre": "4E3226",
	"bois": "7A5034", "bleu_nuit": "283A6B", "bleu_ardoise": "3F5C96", "ciel": "6FA4D8",
	"ciel_clair": "A9D4EE", "vert_sombre": "2F5240", "vert": "4F8A4B", "vert_clair": "8DBF5A",
	"orange": "E2803A", "rouge_auvent": "C7323F", "bleu_vif": "2F7FD1", "peau_claire": "F4D0AE",
	"peau_ombre": "D49A74", "caramel": "A8714E", "lumiere": "FFD97A", "neon_rose": "FF5FA2",
	"ambre": "FFB547", "or": "F2C14E", "gain": "46E08A", "perte": "FF5C5C", "gel": "7FD6FF",
	"cuivre": "C77B4A", "gain_papier": "1B6E3E", "perte_papier": "B3261E",
}
const ATTENDU_NUIT := {"encre": "120F1E", "creme": "6E7092", "or": "6E5A5A", "caramel": "46344A"}
const ATTENDU_ORAGE := {"encre": "1A1418", "creme": "B8AA9E", "or": "B08A48", "caramel": "7A5444"}
const EMISSIVES := ["lumiere", "neon_rose", "ambre", "gain", "perte", "gel", "cuivre", "gain_papier", "perte_papier"]
const VARIANTES := [PalettePixel.JOUR, PalettePixel.NUIT, PalettePixel.ORAGE]
const NOMS_VARIANTES := ["jour", "nuit", "orage"]


func _init() -> void:
	var debut := Time.get_ticks_msec()
	_tests_palette()
	_tests_analyse()
	_tests_catalogue()
	_tests_matieres()
	_tests_blocs()
	print("test_pixel : %d OK, %d KO (%d ms)" % [_ok, _ko, Time.get_ticks_msec() - debut])
	quit(1 if _ko > 0 else 0)


func _verifier(cond: bool, nom: String, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  ", nom)
	else:
		_ko += 1
		print("KO  ", nom, ("  (" + detail + ")") if detail != "" else "")


func _hex(c: Color) -> String:
	return c.to_html(false).to_upper()


# --- Palette -------------------------------------------------------------------------------------

func _tests_palette() -> void:
	var noms := PalettePixel.noms()
	_verifier(noms.size() == 40, "palette : 40 couleurs", str(noms.size()))
	var uniques := {}
	for n in noms:
		uniques[n] = true
	_verifier(uniques.size() == 40, "palette : identifiants uniques")
	_verifier(noms[0] == "encre" and noms[39] == "perte_papier" and noms[33] == "or", "palette : ordre de docs/16 §2.3")
	var ecarts := PackedStringArray()
	for n in ATTENDU_JOUR:
		if not uniques.has(n) or _hex(PalettePixel.couleur(n)) != ATTENDU_JOUR[n]:
			ecarts.append(n)
	_verifier(ecarts.is_empty() and ATTENDU_JOUR.size() == 40, "palette : valeurs de jour = docs/16 §2.3", ", ".join(ecarts))
	ecarts.clear()
	for n in ATTENDU_NUIT:
		if _hex(PalettePixel.couleur(n, PalettePixel.NUIT)) != ATTENDU_NUIT[n]:
			ecarts.append(n)
	for n in ATTENDU_ORAGE:
		if _hex(PalettePixel.couleur(n, PalettePixel.ORAGE)) != ATTENDU_ORAGE[n]:
			ecarts.append(n + " (orage)")
	_verifier(ecarts.is_empty(), "palette : échantillon nuit et orage = docs/16 §2.3", ", ".join(ecarts))
	for vi in VARIANTES.size():
		var vues := {}
		for n in noms:
			vues[PalettePixel.cle(PalettePixel.couleur(n, VARIANTES[vi]))] = true
		_verifier(vues.size() == 40, "palette : 40 couleurs distinctes (%s)" % NOMS_VARIANTES[vi], str(vues.size()))
	var em_ok := true
	var nb_em := 0
	for n in noms:
		if PalettePixel.emissive(n):
			nb_em += 1
			var j := PalettePixel.couleur(n)
			if PalettePixel.couleur(n, PalettePixel.NUIT) != j or PalettePixel.couleur(n, PalettePixel.ORAGE) != j:
				em_ok = false
	_verifier(em_ok and nb_em == EMISSIVES.size(), "palette : %d émissives identiques dans les 3 variantes" % nb_em)
	var inverse_ok := true
	for v in VARIANTES:
		for n in noms:
			var c := PalettePixel.couleur(n, v)
			if PalettePixel.nom_de(c, v) != n or not PalettePixel.contient(c, v):
				inverse_ok = false
	_verifier(inverse_ok, "palette : nom_de et contient retrouvent chaque couleur")
	_verifier(PalettePixel.nom_de(Color(0.5, 0.5, 0.5)) == "" and not PalettePixel.contient(Color(0.5, 0.5, 0.5)), "palette : couleur hors palette reconnue")
	# Conversion jour -> nuit -> jour, alpha conservé
	var img := Image.create_empty(8, 5, false, Image.FORMAT_RGBA8)
	for i in 40:
		img.set_pixel(i % 8, i / 8, PalettePixel.couleur(noms[i]))
	img.set_pixel(0, 0, Color(0, 0, 0, 0))
	var nuit := PalettePixel.convertir(img, PalettePixel.JOUR, PalettePixel.NUIT)
	var retour := PalettePixel.convertir(nuit, PalettePixel.NUIT, PalettePixel.JOUR)
	_verifier(retour.get_data() == img.get_data(), "palette : convertir jour -> nuit -> jour rend l'image d'origine")
	_verifier(_hex(nuit.get_pixel(1, 0)) == "1B1A30" and nuit.get_pixel(0, 0).a == 0.0, "palette : convertir substitue la couleur et garde l'alpha")
	_verifier(PalettePixel.compter_hors_palette(nuit, PalettePixel.NUIT) == 0 and PalettePixel.compter_hors_palette(img) == 0, "palette : image convertie entièrement dans sa variante")
	img.set_pixel(3, 3, Color(0.5, 0.5, 0.5))
	img.set_pixel(4, 3, Color(0.5, 0.5, 0.5, 0.0))
	_verifier(PalettePixel.compter_hors_palette(img) == 1, "palette : compter_hors_palette compte un pixel étranger (et ignore l'alpha 0)")


# --- Analyse des grilles -------------------------------------------------------------------------

func _tests_analyse() -> void:
	var nb_erreurs := GrillePixel.erreurs().size()
	var bon := "# essai\n: e encre\n: o encre 50   # ombre\n: c caramel\nimage essai 4x3\n.ee.\necce\n.oo.\nimage essai_2 2x2 origine 0,0\nee\nc.\n"
	var r := GrillePixel.analyser(bon, "test", "bon")
	_verifier(r["erreurs"].is_empty(), "grille : texte correct sans erreur", ", ".join(r["erreurs"]))
	_verifier(r["images"].has("test/essai") and r["images"].has("test/essai_2"), "grille : noms complets <dossier>/<nom>")
	if r["images"].has("test/essai"):
		var im: Image = r["images"]["test/essai"]["image"]
		_verifier(im.get_size() == Vector2i(4, 3) and r["images"]["test/essai"]["origine"] == Vector2i(2, 2), "grille : taille annoncée et origine par défaut (milieu du bas)")
		_verifier(im.get_pixel(0, 0).a == 0.0 and _hex(im.get_pixel(1, 1)) == "A8714E" and im.get_pixel(1, 1).a == 1.0, "grille : point transparent, lettre opaque de la légende")
		_verifier(absf(im.get_pixel(1, 2).a - 0.5) < 0.01, "grille : alpha déclaré en %")
	if r["images"].has("test/essai_2"):
		_verifier(r["images"]["test/essai_2"]["origine"] == Vector2i(0, 0), "grille : origine annoncée")
	var fautes := {
		"largeur": [": e encre\nimage a 3x2\neee\nee\n", "caractères"],
		"lettre sans légende": [": e encre\nimage a 2x2\nee\nex\n", "sans légende"],
		"couleur inconnue": [": e encre\n: z violet_fluo\nimage a 2x1\nee\n", "couleur inconnue"],
		"nom en double": [": e encre\nimage a 1x1\ne\nimage a 1x1\ne\n", "double"],
		"lignes manquantes": [": e encre\nimage a 2x3\nee\nee\nimage b 1x1\ne\n", "rangées"],
		"ligne inattendue": [": e encre\nbonjour\n", "inattendue"],
	}
	for k in fautes:
		var rr := GrillePixel.analyser(fautes[k][0], "test", k)
		var trouve := false
		for e in rr["erreurs"]:
			if String(e).contains(fautes[k][1]):
				trouve = true
		_verifier(trouve, "grille : erreur détectée (%s)" % k, ", ".join(rr["erreurs"]))
	_verifier(GrillePixel.erreurs().size() == nb_erreurs, "grille : analyser() est pur (aucune erreur enregistrée)")


# --- Catalogue : grilles des dossiers et contrôle de palette ---------------------------------------

func _alphas_declares(dossier: String) -> Dictionary:
	var alphas := {0: true, 255: true}
	var chemin := GrillePixel.RACINE.path_join(dossier)
	if not DirAccess.dir_exists_absolute(chemin):
		return alphas
	for f in DirAccess.get_files_at(chemin):
		if f.ends_with(".txt"):
			for l in FileAccess.get_file_as_string(chemin.path_join(f)).split("\n"):
				var p := GrillePixel._sans_commentaire(l.strip_edges()).split(" ", false)
				if p.size() == 4 and p[0] == ":" and p[3].is_valid_int():
					alphas[roundi(int(p[3]) / 100.0 * 255.0)] = true
	return alphas


func _tests_catalogue() -> void:
	var nb := GrillePixel.charger_dossier("ville")
	_verifier(nb >= 1, "catalogue : grilles de data/pixel/ville chargées (%d)" % nb)
	var nb_ui := GrillePixel.charger_dossier("ui")
	print("     data/pixel/ui : %d grille(s)" % nb_ui)
	_verifier(GrillePixel.erreurs().is_empty(), "catalogue : aucune erreur de chargement", "\n".join(GrillePixel.erreurs()))
	_verifier(GrillePixel.charger_dossier("dossier_absent") == 0 and GrillePixel.erreurs().is_empty(), "catalogue : dossier absent = 0, sans erreur")
	_verifier(GrillePixel.charger_dossier("ville") == nb and GrillePixel.erreurs().is_empty(), "catalogue : recharger un dossier ne crée pas de doublon")
	_verifier(GrillePixel.existe("ville/lefranc_affable") and GrillePixel.taille("ville/lefranc_affable") == Vector2i(48, 48), "catalogue : ville/lefranc_affable 48 × 48")
	var tex := GrillePixel.texture("ville/lefranc_affable", PalettePixel.NUIT)
	_verifier(tex != null and tex.get_size() == Vector2(48, 48) and GrillePixel.texture("ville/lefranc_affable", PalettePixel.NUIT) == tex, "catalogue : texture de nuit créée puis gardée en cache")
	_verifier(GrillePixel.image("ville/lefranc_affable", PalettePixel.ORAGE) == GrillePixel.image("ville/lefranc_affable", PalettePixel.ORAGE), "catalogue : image d'orage en cache")
	# Alpha 0 ou 1 (ou alpha déclaré) dans chaque grille
	for dossier in ["ville", "ui"]:
		var permis := _alphas_declares(dossier)
		var fautifs := PackedStringArray()
		for n in GrillePixel.noms():
			if not n.begins_with(dossier + "/"):
				continue
			var d := GrillePixel.image(n).get_data()
			for i in range(3, d.size(), 4):
				if not permis.has(int(d[i])):
					fautifs.append(n)
					break
		_verifier(fautifs.is_empty(), "catalogue : alpha 0 ou 1 (ou déclaré) dans data/pixel/%s" % dossier, ", ".join(fautifs))


# --- Matières et palette de toutes les images ----------------------------------------------------

func _tests_matieres() -> void:
	var noms := MatieresPixel.generer_tout(1)
	_verifier(noms.size() >= 3 and GrillePixel.existe("matiere/ciel") and GrillePixel.existe("matiere/trottoir") and GrillePixel.existe("matiere/chaussee"), "matières : ciel, trottoir, chaussée enregistrés")
	_verifier(MatieresPixel.ciel(64, 200, 7).get_data() == MatieresPixel.ciel(64, 200, 7).get_data(), "matières : ciel déterministe")
	_verifier(MatieresPixel.trottoir(200, 8, 7).get_data() == MatieresPixel.trottoir(200, 8, 7).get_data(), "matières : trottoir déterministe")
	_verifier(MatieresPixel.chaussee(400, 16, 7).get_data() == MatieresPixel.chaussee(400, 16, 7).get_data(), "matières : chaussée déterministe")
	_verifier(MatieresPixel.chaussee(400, 16, 7).get_data() != MatieresPixel.chaussee(400, 16, 8).get_data(), "matières : la graine change la chaussée")
	# Ciel : bandes dans l'ordre, transitions tramées (deux couleurs alternées sur une même rangée)
	var ciel := MatieresPixel.ciel(64, 300, 1)
	var bas := PalettePixel.nom_de(ciel.get_pixel(0, 299))
	var haut := PalettePixel.nom_de(ciel.get_pixel(0, 0))
	_verifier(bas == "creme" and haut == "bleu_nuit", "matières : ciel de crème (horizon) à bleu nuit (haut)", bas + " / " + haut)
	var trame := false
	for y in 300:
		var c := {}
		for x in 4:
			c[PalettePixel.cle(ciel.get_pixel(x, y))] = true
		if c.size() == 2:
			trame = true
	_verifier(trame, "matières : transitions du ciel tramées (Bayer 4 × 4)")
	# Chaque pixel de chaque image du catalogue appartient à la palette de sa variante
	for vi in VARIANTES.size():
		var fautifs := PackedStringArray()
		var total := 0
		for n in GrillePixel.noms():
			var h := PalettePixel.compter_hors_palette(GrillePixel.image(n, VARIANTES[vi]), VARIANTES[vi])
			if h > 0:
				fautifs.append("%s (%d)" % [n, h])
			total += 1
		_verifier(fautifs.is_empty() and total >= 4, "palette : les %d images du catalogue sont dans la palette %s" % [total, NOMS_VARIANTES[vi]], ", ".join(fautifs))


# --- Contrôle des pixels nets (fonction de px0.gd) -----------------------------------------------

func _tests_blocs() -> void:
	var px0: Script = load("res://scripts/pixel/px0.gd")
	var art := MatieresPixel.chaussee(40, 16, 3)
	var grand := Image.new()
	grand.copy_from(art)
	grand.resize(120, 48, Image.INTERPOLATE_NEAREST)
	var r: Vector2i = px0.controler_blocs(grand, 3)
	_verifier(r == Vector2i(40 * 16, 0), "blocs : image agrandie ×3 sans bloc irrégulier", str(r))
	grand.set_pixel(4, 4, PalettePixel.couleur("perte"))
	grand.set_pixel(100, 40, PalettePixel.couleur("perte"))
	r = px0.controler_blocs(grand, 3)
	_verifier(r == Vector2i(40 * 16, 2), "blocs : deux pixels déplacés = deux blocs irréguliers", str(r))
	grand.resize(121, 49, Image.INTERPOLATE_NEAREST)
	_verifier(px0.controler_blocs(grand, 3).x == 40 * 16, "blocs : seuls les blocs complets sont comptés")
