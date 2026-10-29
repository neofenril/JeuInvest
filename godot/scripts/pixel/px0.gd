extends Node
## Racine de la preuve de concept pixel (lot PX0, docs/lots/lot_px0.md §2.6) : scène autonome, qui ne lit
## ni n'écrit rien dans user:// et n'utilise ni Partie, ni Sauvegarde, ni EtatPartie.
##
## Touches de la racine : J jour / nuit (fondu de 3 s), S humeur de Sylvie, F10 format téléphone
## (fenêtre 1600 × 720, facteur 1,7), Échap quitter. L'interface (C, P, H) est dans
## scripts/pixel/ui/interface_px0.gd, chargée par chemin si elle existe (crochet ci-dessous).
##
## Options (après « -- », préfixe --px0- obligatoire) :
##   --px0-taille=LxH       fenêtre sans bordure en (0, 0), à cette taille exacte
##   --px0-telephone        facteur d'interface 1,7 ; sans --px0-taille, fenêtre 1600 × 720 (comme F10)
##   --px0-facteur=N        force N
##   --px0-etape=E          jour (défaut), nuit, sylvie_0, sylvie_1, sylvie_2, planche ; puis interface :
##                          carte, carte_fermee, jersey, polices. Étape inconnue : message, code 2
##   --px0-libre            ne fige pas la scène (sinon pose de capture puis figer)
##   --px0-sans-interface   n'instancie pas l'interface
##   --px0-controle         imprime les lignes de contrôle « PX0 … »
##   --px0-fps              mesure les images par seconde sur 3 s après 1 s de chauffe
##   --px0-capture=<png>    enregistre la fenêtre puis quitte (relatif = relatif à godot/) ; code 4 si la taille diffère
##   --px0-montage=<png>    avec --px0-capture : écrit aussi <capture>_montage.png (référence à gauche)
##   --px0-attente=s        attente avant la capture
##   --px0-quitter-apres=s  arrêt automatique (code 0)

const CHEMIN_INTERFACE := "res://scripts/pixel/ui/interface_px0.gd"
const ETAPES_VILLE := ["jour", "nuit", "sylvie_0", "sylvie_1", "sylvie_2", "planche"]
const ETAPES_INTERFACE := ["carte", "carte_fermee", "jersey", "polices"]
const OPTIONS := ["taille", "telephone", "facteur", "etape", "libre", "sans-interface", "controle", "fps",
	"capture", "montage", "attente", "quitter-apres"]
const FENETRE_TELEPHONE := Vector2i(1600, 720)
const FACTEUR_TELEPHONE := 1.7
const GARDE_FOU := 120.0

var vue: VuePixel
var rue: RuePx0
var interface: Object = null

var _options := {}
var _taille := Vector2i.ZERO
var _telephone := false
var _fenetre_pc := Vector2i(1600, 900)
var _mode_pc := Window.MODE_WINDOWED
var _bordure_pc := false


func _ready() -> void:
	if not _lire_options():
		return
	_regler_fenetre()
	GrillePixel.charger_dossier("ville")
	MatieresPixel.generer_tout()
	vue = VuePixel.new()
	add_child(vue)
	if _options.has("facteur"):
		vue.forcer_facteur(int(_options["facteur"]))
	rue = RuePx0.new()
	vue.monde.add_child(rue)
	vue.cadrer(rue.zone_utile())
	# Crochet de l'interface (lot PX0 §2.5) : chargée par chemin, sans class_name
	if not _options.has("sans-interface") and ResourceLoader.exists(CHEMIN_INTERFACE):
		var script: Script = load(CHEMIN_INTERFACE)
		if script != null:
			interface = script.new()
			add_child(interface)
			interface.installer(vue, rue)
	if _options.has("quitter-apres"):
		get_tree().create_timer(float(_options["quitter-apres"]), true, false, true).timeout.connect(_quitter.bind(0))
	if _options.has("capture"):
		get_tree().create_timer(GARDE_FOU, true, false, true).timeout.connect(_delai_depasse)
	_demarrer.call_deferred()


func _lire_options() -> bool:
	for arg in OS.get_cmdline_user_args():
		if not arg.begins_with("--px0-"):
			continue
		var kv := arg.substr(6).split("=", true, 1)
		if not OPTIONS.has(kv[0]):
			printerr("PX0 option inconnue : %s (options : --px0-%s)" % [arg, ", --px0-".join(OPTIONS)])
			_quitter.call_deferred(2)
			return false
		_options[kv[0]] = kv[1] if kv.size() > 1 else "1"
	var etape := String(_options.get("etape", "jour"))
	if not ETAPES_VILLE.has(etape) and not ETAPES_INTERFACE.has(etape):
		printerr("PX0 étape inconnue : %s (étapes : %s)" % [etape, ", ".join(ETAPES_VILLE + ETAPES_INTERFACE)])
		_quitter.call_deferred(2)
		return false
	if _options.has("taille"):
		var t := String(_options["taille"]).split("x")
		if t.size() != 2 or not t[0].is_valid_int() or not t[1].is_valid_int():
			printerr("PX0 taille illisible : %s (attendu LxH)" % _options["taille"])
			_quitter.call_deferred(2)
			return false
		_taille = Vector2i(int(t[0]), int(t[1]))
	return true


func _regler_fenetre() -> void:
	var fen := get_window()
	if _options.has("telephone"):
		fen.content_scale_factor = FACTEUR_TELEPHONE
		_telephone = true
	if _taille != Vector2i.ZERO:
		fen.mode = Window.MODE_WINDOWED
		fen.borderless = true
		fen.position = Vector2i.ZERO
		fen.size = _taille
	elif _telephone:
		fen.mode = Window.MODE_WINDOWED
		fen.size = FENETRE_TELEPHONE
		fen.move_to_center()


func _taille_attendue() -> Vector2i:
	if _taille != Vector2i.ZERO:
		return _taille
	if _telephone:
		return FENETRE_TELEPHONE
	return Vector2i.ZERO


func _demarrer() -> void:
	for i in 4:
		await get_tree().process_frame
	vue.recalculer()
	var etape := String(_options.get("etape", "jour"))
	var libre := _options.has("libre")
	if not libre:
		rue.preparer_capture()
	match etape:
		"nuit":
			rue.regler_nuit(true, 0.0)
		"sylvie_0", "sylvie_1", "sylvie_2":
			rue.regler_humeur_sylvie(int(etape.right(1)))
		"planche":
			rue.afficher_planche(true, Rect2(vue.origine_vue(), Vector2(vue.taille_vue())))
	if interface != null:
		await interface.preparer(etape)   # l'interface gère ses étapes et ignore les autres
	if not libre:
		rue.figer(true)
	for i in 3:
		await get_tree().process_frame
	if _options.has("controle"):
		await _controler(etape)
	if _options.has("fps"):
		await _mesurer_fps()
	if _options.has("capture"):
		await _capturer()


# --- Contrôles -----------------------------------------------------------------------------------

func _controler(etape: String) -> void:
	var fen := get_window()
	var tv := vue.taille_vue()
	print("PX0 fenetre=%dx%d facteur=%d vue=%dx%d" % [fen.size.x, fen.size.y, vue.facteur(), tv.x, tv.y])
	print("PX0 echelle=%.3f marges_art=%.1f/%.1f camera=%d,%d" % [vue.echelle(), vue.marges_art().x, vue.marges_art().y, int(vue.origine_vue().x), int(vue.origine_vue().y)])
	print("PX0 interface=%s" % ("presente" if interface != null else "absente"))
	if ETAPES_INTERFACE.has(etape) and interface == null:
		print("PX0 etape=%s sans_interface (capture de la rue seule)" % etape)
	else:
		print("PX0 etape=%s" % etape)
	# Palette : image du SubViewport, lumières additives masquées, après le fondu
	while not rue.fondu_termine():
		await get_tree().process_frame
	rue.afficher_lumieres(false)
	await _images_rendues(2)
	var img := vue.image_monde()
	rue.afficher_lumieres(true)
	var variante := PalettePixel.NUIT if rue.est_nuit() else PalettePixel.JOUR
	print("PX0 palette variante=%s pixels=%d hors_palette=%d" % ["nuit" if rue.est_nuit() else "jour", img.get_width() * img.get_height(), PalettePixel.compter_hors_palette(img, variante)])
	# Grille : chaque bloc N × N complet de l'image de la fenêtre est uniforme (interface masquée)
	var iface_visible := true
	if interface != null and interface is CanvasLayer:
		iface_visible = interface.visible
		interface.visible = false
	await _images_rendues(2)
	var fenetre := get_viewport().get_texture().get_image()
	if interface != null and interface is CanvasLayer:
		interface.visible = iface_visible
	var r := controler_blocs(fenetre, vue.facteur())
	print("PX0 grille blocs=%d irreguliers=%d" % [r.x, r.y])
	var g := rue.taille_gerard()
	var e := Vector2(g) * vue.facteur() / vue.echelle()
	print("PX0 figurine gerard=%dx%d ecran=%dx%d" % [g.x, g.y, roundi(e.x), roundi(e.y)])
	print("PX0 fondu=%.1fs" % RuePx0.FONDU)
	for l in rue.lignes_controle():
		print(l)
	if interface != null and interface.has_method("lignes_controle"):
		for l in interface.lignes_controle():
			print(l)


func _images_rendues(n: int) -> void:
	for i in n:
		await RenderingServer.frame_post_draw


## Contrôle des pixels nets : renvoie (blocs complets, blocs non uniformes) pour des blocs n × n
## alignés sur l'origine. Voie rapide : réduction puis agrandissement au plus proche voisin, comparés
## à l'original ; en cas d'écart, comptage exact bloc par bloc.
static func controler_blocs(img: Image, n: int) -> Vector2i:
	var src := Image.new()
	src.copy_from(img)
	src.convert(Image.FORMAT_RGBA8)
	var bx := src.get_width() / n
	var by := src.get_height() / n
	if bx == 0 or by == 0:
		return Vector2i.ZERO
	src.crop(bx * n, by * n)
	if n == 1:
		return Vector2i(bx * by, 0)
	var aller := Image.new()
	aller.copy_from(src)
	aller.resize(bx, by, Image.INTERPOLATE_NEAREST)
	aller.resize(bx * n, by * n, Image.INTERPOLATE_NEAREST)
	if aller.get_data() == src.get_data():
		return Vector2i(bx * by, 0)
	var d := src.get_data()
	var l := bx * n
	var irreguliers := 0
	for j in by:
		for i in bx:
			var ref := d.decode_u32(((j * n) * l + i * n) * 4)
			var ok := true
			for y in n:
				var base := ((j * n + y) * l + i * n) * 4
				for x in n:
					if d.decode_u32(base + x * 4) != ref:
						ok = false
						break
				if not ok:
					break
			if not ok:
				irreguliers += 1
	return Vector2i(bx * by, irreguliers)


func _mesurer_fps() -> void:
	await get_tree().create_timer(1.0).timeout
	var debut := Time.get_ticks_usec()
	var images := 0
	while Time.get_ticks_usec() - debut < 3000000:
		await get_tree().process_frame
		images += 1
	var duree := (Time.get_ticks_usec() - debut) / 1000000.0
	print("PX0 images_par_seconde=%d" % roundi(images / duree))


# --- Capture -------------------------------------------------------------------------------------

func _capturer() -> void:
	var attente := float(_options.get("attente", "0"))
	if attente > 0.0:
		await get_tree().create_timer(attente).timeout
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var chemin := String(_options["capture"])
	if chemin.is_relative_path():
		chemin = ProjectSettings.globalize_path("res://").path_join(chemin)
	DirAccess.make_dir_recursive_absolute(chemin.get_base_dir())
	var err := image.save_png(chemin)
	if err != OK:
		push_error("PX0 capture impossible (%s) : %s" % [error_string(err), chemin])
		_quitter(1)
		return
	print("PX0 capture=%s taille=%dx%d" % [chemin, image.get_width(), image.get_height()])
	if _options.has("montage"):
		_monter(image, String(_options["montage"]), chemin.get_basename() + "_montage.png")
	var attendue := _taille_attendue()
	if attendue != Vector2i.ZERO and image.get_size() != attendue:
		printerr("PX0 taille de capture %dx%d au lieu de %dx%d" % [image.get_width(), image.get_height(), attendue.x, attendue.y])
		_quitter(4)
		return
	_quitter(0)


## Montage avant / après : la référence mise à la hauteur de la capture à gauche, la capture à droite.
func _monter(capture: Image, reference: String, sortie: String) -> void:
	var chemin := reference
	if chemin.is_relative_path():
		chemin = ProjectSettings.globalize_path("res://").path_join(chemin)
	var ref := Image.load_from_file(chemin)
	if ref == null or ref.is_empty():
		push_error("PX0 montage : référence illisible %s" % chemin)
		return
	ref.convert(Image.FORMAT_RGBA8)
	var cap := Image.new()
	cap.copy_from(capture)
	cap.convert(Image.FORMAT_RGBA8)
	var h := cap.get_height()
	if ref.get_height() != h:
		ref.resize(roundi(ref.get_width() * float(h) / ref.get_height()), h, Image.INTERPOLATE_BILINEAR)
	var ecart := 16
	var m := Image.create_empty(ref.get_width() + ecart + cap.get_width(), h, false, Image.FORMAT_RGBA8)
	m.fill(PalettePixel.couleur("encre"))
	m.blit_rect(ref, Rect2i(Vector2i.ZERO, ref.get_size()), Vector2i.ZERO)
	m.blit_rect(cap, Rect2i(Vector2i.ZERO, cap.get_size()), Vector2i(ref.get_width() + ecart, 0))
	var err := m.save_png(sortie)
	if err == OK:
		print("PX0 montage=%s taille=%dx%d" % [sortie, m.get_width(), m.get_height()])
	else:
		push_error("PX0 montage impossible (%s) : %s" % [error_string(err), sortie])


func _delai_depasse() -> void:
	push_error("PX0 délai dépassé (%d s)" % int(GARDE_FOU))
	_quitter(5)


func _quitter(code: int) -> void:
	get_tree().quit(code)


# --- Touches -------------------------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k != null and k.pressed and not k.echo and k.keycode == KEY_F10:
		# Intercepté ici : l'autoload Ecran (fenêtre 1200 × 540, N = 1) ne le voit pas.
		basculer_telephone()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo:
		return
	match k.keycode:
		KEY_J:
			rue.regler_nuit(not rue.est_nuit(), RuePx0.FONDU)
		KEY_S:
			rue.regler_humeur_sylvie((rue.humeur_sylvie() + 1) % 3)
		KEY_ESCAPE:
			_quitter(0)
		_:
			return
	get_viewport().set_input_as_handled()


## Format téléphone de PX0 : fenêtre 1600 × 720, facteur d'interface 1,7 (N = 2, vue 800 × 360).
func basculer_telephone() -> void:
	var fen := get_window()
	if not _telephone:
		_fenetre_pc = fen.size
		_mode_pc = fen.mode
		_bordure_pc = fen.borderless
		fen.mode = Window.MODE_WINDOWED
		fen.borderless = false
		fen.size = FENETRE_TELEPHONE
		fen.content_scale_factor = FACTEUR_TELEPHONE
		fen.move_to_center()
		_telephone = true
	else:
		fen.content_scale_factor = 1.0
		fen.borderless = _bordure_pc
		fen.mode = _mode_pc
		if _mode_pc == Window.MODE_WINDOWED:
			fen.size = _fenetre_pc
			fen.move_to_center()
		_telephone = false
	vue.recalculer()
