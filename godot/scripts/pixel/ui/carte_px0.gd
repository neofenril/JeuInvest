extends Control
## Carte du banquier de l'héritage de tante Odette, avril 1988 (docs/16 §5.3, lot PX0 §2.5), en lecture
## seule : texte et chiffres réels lus dans banque.json par Banquier, Format et Dates (statiques), aucune
## partie ni sauvegarde. Papier crème, contour encre, coin corné, liseré or (banque), portrait 48 × 48 de
## M. Lefranc (×3 sur PC, ×2 sur téléphone ; cadre crème vide si la grille manque), tampon, ticket dentelé,
## bouton COMPRIS ambre. Fond assombri à 60 % teinté gel ; la rue est figée tant que la carte est ouverte.
## Fermeture : COMPRIS, croix, clic à côté, touche C. Sans class_name : chargé par chemin.

const Polices := preload("res://scripts/pixel/ui/polices_px0.gd")
const Cadres := preload("res://scripts/pixel/ui/cadres_px0.gd")

const PORTRAIT := "ville/lefranc_affable"
const LARGEUR_TICKET := 360.0      # 36 + 9 × 36 : le bord dentelé se répète sans étirement
const LARGEUR_TEXTE := 450.0
const LARGEUR_GAUCHE := 186.0

var rue: RuePx0
var hud = null     # HUD (en_pause)

var boite: Control
var papier: PanelContainer
var b_compris: Button
var b_croix: Button
var cadre_portrait: PanelContainer
var portrait: TextureRect
var tampon: PanelContainer
var l_tampon: Label
var support_tampon: Control
var l_texte: Label

var texte := ""
var montants := PackedStringArray()     # 60 000 F, 32 500 F, 27 500 F (espaces ordinaires)
var portrait_present := false
var _telephone := false
signal fermee


func _init() -> void:
	name = "CarteHeritage"
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP


func construire(r: RuePx0, h) -> void:
	rue = r
	hud = h
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Données réelles, lecture seule (lot PX0 §2.5)
	var a := Dates.lire("1988-04")
	var ch := Banquier.heritage_chiffres()
	var d: Dictionary = Banquier.donnees()["heritage"]["D08"]
	var vals := {"prenom": "Gérard", "av_montant": Format.entier(ch["av"], a), "droits": Format.entier(ch["droits"], a),
		"succ_net": Format.entier(ch["net"], a)}
	texte = Format.gabarit(d["texte"], vals)
	var ticket: Array = []
	for t in d["ticket"]:
		ticket.append(Format.gabarit(String(t), vals))
	montants = PackedStringArray([_ordinaire(vals["av_montant"]), _ordinaire(vals["succ_net"]), _ordinaire(vals["droits"])])

	# Fond assombri (60 %) teinté gel
	var voile := ColorRect.new()
	voile.color = PalettePixel.couleur_alpha("encre", 0.6)
	voile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	voile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(voile)
	var gel := ColorRect.new()
	gel.color = PalettePixel.couleur_alpha("gel", 0.10)
	gel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(gel)

	boite = Control.new()
	boite.name = "Boite"
	boite.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(boite)
	papier = Cadres.panneau("carte_papier")
	var st: StyleBoxTexture = Cadres.style("carte_papier").duplicate()
	st.content_margin_left = 36
	st.content_margin_top = 24
	st.content_margin_right = 30
	st.content_margin_bottom = 30
	papier.add_theme_stylebox_override("panel", st)
	papier.mouse_filter = Control.MOUSE_FILTER_STOP
	boite.add_child(papier)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 9)
	papier.add_child(v)

	# En-tête et filet or
	var tete := HBoxContainer.new()
	var l_tete := Cadres.etiquette("BANQUE DE LA RUE · 12, rue des Épargnants", Polices.pixelify(600), 28, "encre")
	tete.add_child(l_tete)
	var reserve := Control.new()
	reserve.custom_minimum_size = Vector2(96, 0)
	reserve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reserve.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tete.add_child(reserve)
	v.add_child(tete)
	var filet := ColorRect.new()
	filet.color = PalettePixel.couleur("or")
	filet.custom_minimum_size = Vector2(0, 3)
	filet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(filet)

	var corps := HBoxContainer.new()
	corps.add_theme_constant_override("separation", 18)
	v.add_child(corps)

	# Colonne gauche : portrait, puis COMPRIS en bas
	var g := VBoxContainer.new()
	g.custom_minimum_size = Vector2(LARGEUR_GAUCHE, 0)
	g.add_theme_constant_override("separation", 12)
	cadre_portrait = Cadres.panneau("cadre_portrait")
	var sp: StyleBoxTexture = Cadres.style("cadre_portrait").duplicate()
	for cote in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		sp.set_content_margin(cote, 6)
	cadre_portrait.add_theme_stylebox_override("panel", sp)
	cadre_portrait.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	cadre_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait = TextureRect.new()
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_SCALE
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_present = GrillePixel.existe(PORTRAIT)
	if portrait_present:
		portrait.texture = GrillePixel.texture(PORTRAIT)
	cadre_portrait.add_child(portrait)
	g.add_child(cadre_portrait)
	var ressort := Control.new()
	ressort.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ressort.mouse_filter = Control.MOUSE_FILTER_IGNORE
	g.add_child(ressort)
	b_compris = Cadres.bouton("principal", "COMPRIS", "", Vector2(LARGEUR_GAUCHE, 80))
	b_compris.name = "Compris"
	b_compris.pressed.connect(fermer)
	g.add_child(b_compris)
	corps.add_child(g)

	# Colonne du milieu : qui parle, quand, le texte D08
	var m := VBoxContainer.new()
	m.add_theme_constant_override("separation", 3)
	m.custom_minimum_size = Vector2(LARGEUR_TEXTE, 0)
	m.add_child(Cadres.etiquette("M. LEFRANC · votre banquier", Polices.pixelify(600), 28, "encre"))
	m.add_child(Cadres.etiquette("avril 1988 · UNE NOUVELLE", Polices.atkinson(700), 22, "ardoise"))
	var esp := Control.new()
	esp.custom_minimum_size = Vector2(0, 9)
	m.add_child(esp)
	l_texte = Cadres.etiquette(texte, Polices.atkinson(400), 24, "encre")
	l_texte.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l_texte.custom_minimum_size = Vector2(LARGEUR_TEXTE, 0)
	m.add_child(l_texte)
	corps.add_child(m)

	var separation := ColorRect.new()
	separation.color = PalettePixel.couleur("pierre_claire")
	separation.custom_minimum_size = Vector2(3, 0)
	separation.mouse_filter = Control.MOUSE_FILTER_IGNORE
	corps.add_child(separation)

	# Colonne droite : tampon, « AVEC VOTRE ARGENT », ticket
	var dr := VBoxContainer.new()
	dr.add_theme_constant_override("separation", 9)
	dr.custom_minimum_size = Vector2(LARGEUR_TICKET, 0)
	support_tampon = Control.new()
	support_tampon.custom_minimum_size = Vector2(0, 72)
	support_tampon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tampon = Cadres.panneau("tampon")
	var stt: StyleBoxTexture = Cadres.style("tampon").duplicate()
	stt.content_margin_left = 18
	stt.content_margin_right = 18
	stt.content_margin_top = 6
	stt.content_margin_bottom = 6
	tampon.add_theme_stylebox_override("panel", stt)
	tampon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l_tampon = Cadres.etiquette(String(d["titre"]), Polices.pixelify(700), 28, "bleu_ardoise")
	tampon.add_child(l_tampon)
	support_tampon.add_child(tampon)
	dr.add_child(support_tampon)
	dr.add_child(Cadres.etiquette("AVEC VOTRE ARGENT", Polices.pixelify(600), 28, "encre"))
	var tk := Cadres.panneau("ticket")
	var stk: StyleBoxTexture = Cadres.style("ticket").duplicate()
	stk.content_margin_left = 21
	stk.content_margin_right = 21
	stk.content_margin_top = 21
	stk.content_margin_bottom = 21
	tk.add_theme_stylebox_override("panel", stk)
	tk.custom_minimum_size = Vector2(LARGEUR_TICKET, 0)
	tk.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	tk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 0)
	tv.add_child(Cadres.etiquette(String(ticket[0]).to_upper(), Polices.atkinson(700), 20, "ardoise"))
	tv.add_child(Cadres.etiquette("+" + Format.ESPACE + String(ticket[1]), Polices.atkinson(800), 40, "gain_papier"))
	tv.add_child(Cadres.etiquette(String(ticket[2]), Polices.atkinson(400), 20, "encre"))
	var pointille := Pointille.new()
	pointille.custom_minimum_size = Vector2(0, 21)
	tv.add_child(pointille)
	tv.add_child(Cadres.etiquette(String(ticket[3]).to_upper(), Polices.atkinson(700), 20, "ardoise"))
	var barre_ligne := HBoxContainer.new()
	var l_net := Cadres.etiquette(String(ticket[4]), Polices.atkinson(700), 32, "gris_pierre")
	var rature := ColorRect.new()
	rature.color = PalettePixel.couleur("gris_pierre")
	rature.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rature.anchor_right = 1.0
	rature.anchor_top = 0.5
	rature.anchor_bottom = 0.5
	rature.offset_left = -3
	rature.offset_right = 3
	rature.offset_top = -1.5
	rature.offset_bottom = 1.5
	l_net.add_child(rature)
	barre_ligne.add_child(l_net)
	tv.add_child(barre_ligne)
	var l_droits := Cadres.etiquette(String(ticket[5]), Polices.atkinson(400), 20, "ardoise")
	l_droits.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l_droits.custom_minimum_size = Vector2(LARGEUR_TICKET - 42, 0)
	tv.add_child(l_droits)
	tk.add_child(tv)
	dr.add_child(tk)
	corps.add_child(dr)

	# Croix de fermeture 80 × 80, en haut à droite (hors des conteneurs)
	b_croix = Cadres.bouton("papier", "", "croix")
	b_croix.name = "Croix"
	b_croix.pressed.connect(fermer)
	boite.add_child(b_croix)

	resized.connect(mettre_en_page)
	mettre_en_page.call_deferred()


## Filet pointillé du ticket (tirets de 2 texels, encre claire).
class Pointille extends Control:
	func _draw() -> void:
		var y := roundf(size.y / 2.0 / 3.0) * 3.0 - 1.5
		var x := 0.0
		while x + 6.0 <= size.x:
			draw_rect(Rect2(x, y, 6, 3), PalettePixel.couleur("zinc_clair"))
			x += 12.0


func mettre_en_page() -> void:
	if papier == null:
		return
	_telephone = get_window() != null and get_window().content_scale_factor > 1.01
	var k := 2 if _telephone else 3
	portrait.custom_minimum_size = Vector2(48 * k, 48 * k)
	var t := papier.get_combined_minimum_size()
	papier.size = t
	boite.size = t
	boite.position = ((size - t) / 2.0).round()
	b_croix.size = b_croix.get_combined_minimum_size()
	b_croix.position = Vector2(t.x - b_croix.size.x - 21, 12)
	tampon.size = tampon.get_combined_minimum_size()
	tampon.position = Vector2(6, (support_tampon.custom_minimum_size.y - tampon.size.y) / 2.0).round()
	tampon.pivot_offset = tampon.size / 2.0
	tampon.rotation_degrees = -3.0


func ouvrir() -> void:
	visible = true
	mettre_en_page()
	if rue != null:
		rue.figer(true)


func fermer() -> void:
	if not visible:
		return
	visible = false
	if rue != null:
		# La rue reprend, sauf si le joueur avait mis le temps en pause.
		rue.figer(hud != null and hud.has_method("en_pause") and hud.en_pause())
	fermee.emit()


func basculer() -> void:
	if visible:
		fermer()
	else:
		ouvrir()


func _gui_input(event: InputEvent) -> void:
	# Clic (ou toucher) à côté de la carte : ferme
	var mb := event as InputEventMouseButton
	if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		if not boite.get_global_rect().has_point(mb.global_position):
			fermer()
			accept_event()
	var tc := event as InputEventScreenTouch
	if tc != null and tc.pressed and not boite.get_global_rect().has_point(tc.position):
		fermer()
		accept_event()


## Vrai clic de souris (appui puis relâchement) au centre du bouton COMPRIS, par la file d'entrée.
func cliquer_compris() -> void:
	var centre := b_compris.get_global_rect().get_center()
	var physique: Vector2 = get_viewport().get_final_transform() * centre
	for appui in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = appui
		ev.button_mask = MOUSE_BUTTON_MASK_LEFT if appui else 0
		ev.position = physique
		ev.global_position = physique
		Input.parse_input_event(ev)
		await get_tree().process_frame
		await get_tree().process_frame


static func _ordinaire(s: String) -> String:
	return s.replace(Format.ESPACE, " ")


## Nombre de mots du texte (suites séparées par des espaces ordinaires contenant une lettre ou un chiffre).
func mots() -> int:
	var n := 0
	for m in texte.split(" ", false):
		for ch in m:
			if ch.to_lower() != ch.to_upper() or ch.is_valid_int():
				n += 1
				break
	return n


func lignes_controle() -> PackedStringArray:
	var r := boite.get_global_rect()
	var ecran := get_viewport_rect()
	var dans := ecran.encloses(r)
	return PackedStringArray([
		"PX0 carte montants=%s mots=%d" % ["|".join(montants), mots()],
		"PX0 carte ouverte=%s taille=%dx%d dans_fenetre=%s portrait=%s portrait_ecran=%d tampon=%s" % [
			"oui" if visible else "non", roundi(r.size.x), roundi(r.size.y), "oui" if dans else "non",
			"present" if portrait_present else "absent (cadre vide)", roundi(portrait.custom_minimum_size.x),
			l_tampon.text],
	])
