extends CanvasLayer
## Interface pixel de la preuve de concept (lot PX0 §2.5) : crochet chargé par px0.gd (CHEMIN_INTERFACE),
## sans class_name. Construit le HUD (barre haute, frise, étiquette « MA MAISON »), la carte de l'héritage
## (fermée), l'aide et la planche des polices. Touches : C carte du banquier, P police des chiffres
## (Atkinson / Jersey 10), H aide. Ne lit ni n'écrit rien dans user://.

const Polices := preload("res://scripts/pixel/ui/polices_px0.gd")
const Cadres := preload("res://scripts/pixel/ui/cadres_px0.gd")
const HudPx0 := preload("res://scripts/pixel/ui/hud_px0.gd")
const CartePx0 := preload("res://scripts/pixel/ui/carte_px0.gd")
const PlanchePx0 := preload("res://scripts/pixel/ui/planche_polices_px0.gd")

const ECHANTILLON := "ÉÈÊÀÇÔŒÙÎ àéèêçôœùî « » 0123456789 1lI 0O 8B 69 395 F"
const TOUCHES := [
	["J", "jour / nuit (fondu de 3 s)"],
	["S", "humeur de Sylvie"],
	["C", "carte du banquier (héritage)"],
	["P", "police des chiffres : Atkinson / Jersey 10"],
	["F10", "format téléphone"],
	["H", "afficher / masquer cette aide"],
	["Échap", "quitter"],
]

var vue: VuePixel
var rue: RuePx0
var racine: Control
var hud: HudPx0
var carte: CartePx0
var planche: PlanchePx0
var aide: PanelContainer

var _etape := ""
var _fermeture := ""        # résultat de l'étape carte_fermee


func _init() -> void:
	name = "InterfacePx0"
	layer = 10


func installer(v: VuePixel, r: RuePx0) -> void:
	vue = v
	rue = r
	Cadres.charger()
	racine = Control.new()
	racine.name = "Racine"
	racine.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	racine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(racine)
	hud = HudPx0.new()
	racine.add_child(hud)
	hud.construire(v, r)      # appelle vue.regler_marges(96, 72)
	hud.menu_demande = basculer_aide
	carte = CartePx0.new()
	racine.add_child(carte)
	carte.construire(r, hud)
	aide = _construire_aide()
	racine.add_child(aide)
	planche = PlanchePx0.new()
	racine.add_child(planche)
	planche.construire()
	# Aide visible au lancement pour le joueur ; jamais pendant une capture ou un contrôle.
	var args := " ".join(OS.get_cmdline_user_args())
	aide.visible = not (args.contains("--px0-capture") or args.contains("--px0-controle") or args.contains("--px0-fps"))


## Étapes de capture propres à l'interface ; les autres sont ignorées.
func preparer(etape: String) -> void:
	_etape = etape
	match etape:
		"carte":
			carte.ouvrir()
		"carte_fermee":
			carte.ouvrir()
			await _images(3)
			await carte.cliquer_compris()
			await _images(2)
			var figee: bool = rue.call("est_fige") if rue.has_method("est_fige") else false
			_fermeture = "PX0 carte fermee=%s rue_figee=%s" % ["non" if carte.visible else "oui", "oui" if figee else "non"]
		"jersey":
			hud.regler_jersey(true)
		"polices":
			planche.visible = true
	await _images(2)


func _images(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func lignes_controle() -> PackedStringArray:
	var l := PackedStringArray()
	var tnum := Polices.tnum_atkinson()
	var chargees := Polices.chargees()
	l.append("PX0 polices chargees=%d tnum_atkinson=%s" % [chargees, "oui" if tnum else "non"])
	var manque := []
	for c in Polices.chemins():
		var m := Polices.manquants(c, ECHANTILLON + "·" + Format.ESPACE)
		if m != "":
			manque.append("%s:%s" % [c.get_file(), m])
	l.append("PX0 polices glyphes_manquants=%s systemfont=%d" % ["aucun" if manque.is_empty() else ",".join(manque), _compter_systemfont(racine)])
	l.append_array(hud.lignes_controle())
	l.append_array(carte.lignes_controle())
	if _etape == "carte_fermee":
		l.append(_fermeture)
	if _etape == "polices":
		l.append("PX0 planche polices=4 tailles=28,32,48,72 fonds=nuit,creme")
	return l


func _compter_systemfont(n: Node) -> int:
	var k := 0
	if n is Control and n.has_theme_font_override("font") and n.get_theme_font("font") is SystemFont:
		k += 1
	for c in n.get_children():
		k += _compter_systemfont(c)
	return k


# --- Aide -----------------------------------------------------------------------------------------

func _construire_aide() -> PanelContainer:
	var p := Cadres.panneau("panneau")
	p.name = "Aide"
	var st: StyleBoxTexture = Cadres.style("panneau").duplicate()
	st.content_margin_left = 30
	st.content_margin_right = 30
	st.content_margin_top = 18
	st.content_margin_bottom = 27
	p.add_theme_stylebox_override("panel", st)
	p.self_modulate = Color(1, 1, 1, 0.97)
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.gui_input.connect(_clic_aide)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	v.add_child(Cadres.etiquette("PREUVE DE CONCEPT PIXEL · TOUCHES", Polices.pixelify(600), 28, "ambre"))
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 24)
	g.add_theme_constant_override("v_separation", 0)
	for t in TOUCHES:
		g.add_child(Cadres.etiquette(t[0], Polices.atkinson(800), 24, "ambre"))
		g.add_child(Cadres.etiquette(t[1], Polices.atkinson(400), 24, "creme"))
	v.add_child(g)
	v.add_child(Cadres.etiquette("Un clic sur ce panneau ou H le ferme.", Polices.atkinson(400), 20, "gris_pierre"))
	p.add_child(v)
	p.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	p.grow_horizontal = Control.GROW_DIRECTION_BOTH
	p.offset_top = HudPx0.HAUT + 24
	p.visible = false
	return p


func _clic_aide(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb != null and mb.pressed:
		aide.visible = false
		aide.accept_event()


func basculer_aide() -> void:
	aide.visible = not aide.visible


func _unhandled_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo:
		return
	match k.keycode:
		KEY_C:
			carte.basculer()
		KEY_P:
			hud.regler_jersey(not hud.jersey())
		KEY_H:
			basculer_aide()
		_:
			return
	get_viewport().set_input_as_handled()
