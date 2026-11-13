class_name ModaleCarte
extends RefCounted
## Morceau de Modales (lot 04, 03-I2) : la carte de dilemme du foyer, « pense-bête aimanté du frigo »
## (docs/17 §4.1 ; contrat lot_04 §4.3, contenu lot_03 §5.3 bis).
## - ouvrir(c, depart) : apparition sur place (version jouable : ni vol, ni dépli, ni aimant). Toucher un choix non désactivé (ou 1 / 2) émet
##   choix_fait("carte", id) ; la carte reste affichée. Ni clic extérieur ni Échap.
## - conclure(r, arrivee) : tampon « CHOISI », l'autre choix à 40 %, la ligne de conséquence 3 s (un toucher
##   passe), puis rangement vers arrivee ((-1, -1) : fondu) ; rend la main quand la carte a disparu.
## - lecture(h, a) : relecture depuis l'historique (titre, choix pris, montant, conséquence, FERMER).

const DUREE_CONSEQUENCE := 3.0

var m: Modales
var phase := ""                       # entree | attente | choisi | conclusion | rangement
var boutons := {}                     # id -> Button
var choix := {}                       # id -> Dictionary (contrat)
var ordre: Array = []                 # ids dans l'ordre d'affichage (touches 1, 2)
var genre_emis := "carte"                # genre du signal choix_fait (« projet » pour ModaleProjet)
var refus := 0                        # touchers ignorés sur un choix désactivé (contrôle des captures)
var _p: Control = null                # enveloppe (découpe du dépliage), modale courante
var _panel: PanelContainer = null
var _texte: Label = null
var _suite: Label = null
var _passer := false


func _init(modales: Modales) -> void:
	m = modales


## Expression du portrait selon l'humeur visible (0 contente, 1 neutre, 2 fâchée).
static func nom_humeur(h: int) -> String:
	return ["contente", "neutre", "fachee"][clampi(h, 0, 2)]


static func _humeur_actuelle() -> int:
	var e: EtatPartie = Partie.etat
	if e != null and e.has_method("humeur_visible"):
		return e.humeur_visible()
	return 1


## Montant d'un choix tel qu'affiché : signe explicite, au franc (« −9 000 F », « +1 200 F », « 0 F »).
static func texte_montant(montant: float, a: int) -> String:
	return Format.ecart(montant, a)


func ouvrir(c: Dictionary, depart: Vector2) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "carte"
	m.carte_en_cours = true
	phase = "entree"
	refus = 0
	_passer = false
	boutons.clear()
	choix.clear()
	ordre.clear()
	m.assombrir(0.6)
	var a := int(c.get("ab", Partie.etat.ab_courant() if Partie.etat != null else 0))
	var vue := m.get_viewport_rect().size
	var largeur := floorf(minf(1000.0, vue.x * (0.94 if compact else 0.9)) / 3.0) * 3.0
	_panel = PanelContainer.new()
	_panel.name = "PapierCarte"
	_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_panel.add_theme_stylebox_override("panel", Style.papier("tuile", 30.0, 18.0 if compact else 24.0))
	_panel.custom_minimum_size = Vector2(largeur, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8 if compact else 12)
	_panel.add_child(v)
	v.add_child(Style.label("MA MAISON · " + str(c.get("date", "")).to_upper(), 20, Style.capitales(), Style.TEXTE_PAPIER_2))
	var corps := HBoxContainer.new()
	corps.add_theme_constant_override("separation", 18 if compact else 24)
	var portrait := CadresPixel.icone("portrait_sylvie_" + nom_humeur(_humeur_actuelle()))
	portrait.name = "Portrait"
	portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	corps.add_child(portrait)
	var droite := VBoxContainer.new()
	droite.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	droite.add_theme_constant_override("separation", 6)
	var titre := Style.label(str(c.get("titre", "")).to_upper(), 32 if compact else 48, Style.capitales(), Style.ENCRE)
	titre.name = "Titre"
	titre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	droite.add_child(titre)
	_texte = Style.label(str(c.get("texte", "")), 22 if compact else 26, Style.ui(), Style.ENCRE)
	_texte.name = "Texte"
	_texte.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	droite.add_child(_texte)
	corps.add_child(droite)
	var interieur := largeur - 66.0
	var cote_portrait := 144.0
	titre.custom_minimum_size.x = interieur - cote_portrait - 24.0
	_texte.custom_minimum_size.x = interieur - cote_portrait - 24.0
	v.add_child(corps)
	var rangee := HBoxContainer.new()
	rangee.name = "Choix"
	rangee.add_theme_constant_override("separation", 18)
	var k := 0
	for ch: Dictionary in c.get("choix", []):
		k += 1
		var id := str(ch.get("id", ""))
		choix[id] = ch
		ordre.append(id)
		var b := _bouton_choix(ch, k, a, compact, (interieur - 18.0) / 2.0)
		boutons[id] = b
		rangee.add_child(b)
	v.add_child(rangee)
	var dispo := Format.entier(float(c.get("disponible", 0.0)), a)
	var ld := Style.label(("Disponible : %s" if compact else "Disponible sans rien vendre : %s (compte et Livret A)") % dispo, 20, Style.ui(), Style.TEXTE_PAPIER_2)
	ld.name = "Disponible"
	v.add_child(ld)
	_suite = Style.label("Toucher pour continuer  ›", 20, Style.ui(), Style.TEXTE_PAPIER_2)
	_suite.name = "Suite"
	_suite.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_suite.modulate.a = 0.0
	v.add_child(_suite)
	# Enveloppe sans conteneur : elle découpe la carte pendant le dépliage ; l'aimant est posé dessus
	_p = Control.new()
	_p.name = "Carte"
	_p.mouse_filter = Control.MOUSE_FILTER_STOP
	_p.add_child(_panel)
	_panel.gui_input.connect(_on_toucher)
	m.poser(_p)
	_p.visible = false
	await m.get_tree().process_frame
	await m.get_tree().process_frame
	if not is_instance_valid(_p):
		return
	# 2e passe : les libellés à retour à la ligne des choix (« Il manque … ») ne se mesurent qu'à leur largeur réelle
	_ajuster_boutons(compact)
	await m.get_tree().process_frame
	if not is_instance_valid(_p):
		return
	_panel.reset_size()
	var s := (_panel.size / 3.0).ceil() * 3.0
	_panel.size = s
	_p.size = s
	var pos := (((vue - s) / 2.0).max(Vector2(0, 6)) / 3.0).round() * 3.0
	_p.position = pos
	await _entree(depart, pos, s)
	if is_instance_valid(_p) and phase == "entree":
		phase = "attente"


func _bouton_choix(ch: Dictionary, k: int, a: int, compact: bool, largeur: float) -> Button:
	var b := Button.new()
	b.name = "Choix_" + str(ch.get("id", ""))
	b.focus_mode = Control.FOCUS_NONE
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	CadresPixel.habiller_bouton(b, "papier")
	var desactive := bool(ch.get("desactive", false))
	b.disabled = desactive
	var vb := VBoxContainer.new()
	vb.name = "Contenu"
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", 2)
	var l1 := HBoxContainer.new()
	l1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l1.add_theme_constant_override("separation", 12)
	var touche := Style.label(str(k), 24, Style.ui_gras(), Style.TEXTE_PAPIER_2)
	touche.name = "Touche"
	l1.add_child(touche)
	var t := Style.label(str(ch.get("titre", "")).to_upper(), 28, Style.capitales(), Style.ENCRE)
	t.name = "TitreChoix"
	t.clip_text = true
	t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.custom_minimum_size.x = 60
	l1.add_child(t)
	vb.add_child(l1)
	var l2 := HBoxContainer.new()
	l2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var montant := float(ch.get("montant", 0.0))
	var lm := Style.label(texte_montant(montant, a), 26 if compact else 30, Style.ui_gras(), Style.GAIN_PAPIER if montant > 0.004 else Style.ENCRE)
	lm.name = "Montant"
	lm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l2.add_child(lm)
	var picto := CadresPixel.icone("humeur_" + str(ch.get("picto", "neutre")))
	picto.name = "Picto"
	l2.add_child(picto)
	vb.add_child(l2)
	if desactive:
		var lmq := Style.label("Il manque %s sur votre compte et votre Livret A" % Format.entier(float(ch.get("manque", 0.0)), a), 20, Style.ui_gras(), Style.ENCRE_ROUGE)
		lmq.name = "Manque"
		lmq.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lmq.custom_minimum_size.x = largeur - 42.0
		vb.add_child(lmq)
	b.add_child(vb)
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.offset_left = 21
	vb.offset_right = -21
	vb.offset_top = 12
	vb.offset_bottom = -15
	var besoin := vb.get_combined_minimum_size()
	b.custom_minimum_size = Vector2(0, maxf(96.0 if compact else 120.0, besoin.y + 27.0))
	if desactive:
		var h := Control.new()
		h.name = "Hachures"
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		h.draw.connect(_dessiner_hachures.bind(h))
		b.add_child(h)
		b.gui_input.connect(_on_desactive)
	else:
		b.pressed.connect(choisir.bind(str(ch.get("id", ""))))
	return b


func _ajuster_boutons(compact: bool) -> void:
	var haut := 0.0
	for k: String in boutons:
		var b: Button = boutons[k]
		var vb := b.get_node("Contenu") as Control
		for l in vb.find_children("*", "Label", true, false):
			var lab := l as Label
			if lab.autowrap_mode != TextServer.AUTOWRAP_OFF:
				lab.custom_minimum_size.x = maxf(60.0, b.size.x - 42.0)
		haut = maxf(haut, vb.get_combined_minimum_size().y + 27.0)
	for k: String in boutons:
		var b: Button = boutons[k]
		b.custom_minimum_size.y = maxf(96.0 if compact else 120.0, ceilf(haut / 3.0) * 3.0)


## Hachures en marches d'escalier (un motif, pas seulement du gris) sur un choix non payable.
func _dessiner_hachures(h: Control) -> void:
	var c := Color(Style.ENCRE, 0.22)
	var pas := 18.0
	var y := 6.0
	while y < h.size.y - 6.0:
		var x := 6.0 + fmod(y, pas)
		while x < h.size.x - 9.0:
			h.draw_rect(Rect2(x, y, 6, 3), c)
			x += pas
		y += 3.0


func _on_desactive(ev: InputEvent) -> void:
	var b := ev as InputEventMouseButton
	if b != null and b.pressed and b.button_index == MOUSE_BUTTON_LEFT:
		refus += 1


## Choix du joueur (bouton, touche 1 / 2). La carte reste affichée ; si le moteur refuse (choix désactivé),
## la séquence attend un autre choix : la carte se rouvre aux choix.
func choisir(id: String) -> void:
	if phase != "attente" or not choix.has(id):
		return
	if bool(choix[id].get("desactive", false)):
		refus += 1
		return
	phase = "choisi"
	m.choix_fait.emit(genre_emis, id)
	# Sans conclusion lancée par la séquence (refus du moteur), la carte attend un autre choix
	if phase == "choisi" and is_instance_valid(_p):
		phase = "attente"


func choisir_rang(n: int) -> void:
	if n >= 0 and n < ordre.size():
		choisir(str(ordre[n]))


func _on_toucher(ev: InputEvent) -> void:
	var b := ev as InputEventMouseButton
	if b != null and b.pressed and b.button_index == MOUSE_BUTTON_LEFT and phase == "conclusion":
		passer()


## Un toucher pendant la ligne de conséquence la passe.
func passer() -> void:
	if phase == "conclusion":
		_passer = true


## Version jouable (lot 04 §12.3) : la carte apparaît sur place, sans vol, dépli ni aimant ; fondu ≤ 0,2 s
## si un point de départ est donné (la porte), apparition immédiate sinon.
func _entree(depart: Vector2, _pos: Vector2, _s: Vector2) -> void:
	_p.visible = true
	if depart.x >= 0.0 and depart.y >= 0.0 and not Juice.animations_reduites:
		_p.modulate.a = 0.0
		var tw := _p.create_tween()
		tw.tween_property(_p, "modulate:a", 1.0, 0.18)
		await tw.finished

## Conclusion (contrat lot_04 §4.3). r : retour de Partie.resoudre_modale.
func conclure(r: Dictionary, arrivee: Vector2) -> void:
	if not is_instance_valid(_p):
		_ranger_fin()
		return
	phase = "conclusion"
	_passer = false
	var id := str(r.get("choix", ""))
	for k: String in boutons:
		var b: Button = boutons[k]
		b.disabled = true
		b.add_theme_stylebox_override("disabled", b.get_theme_stylebox("normal"))
		if k == id:
			_tamponner(b)
		else:
			b.modulate.a = 0.4
	var consequence := str(r.get("consequence", ""))
	if consequence != "":
		_texte.text = consequence
		_texte.add_theme_font_size_override("font_size", 22 if m.compact else 24)
	_texte.name = "Consequence"
	_suite.modulate.a = 1.0
	var t := 0.0
	while t < DUREE_CONSEQUENCE and not _passer and is_instance_valid(_p):
		await m.get_tree().process_frame
		t += m.get_process_delta_time()
	await _ranger(arrivee)


func _tamponner(b: Button) -> void:
	var tp := PanelContainer.new()
	tp.name = "Tampon"
	tp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tp.add_theme_stylebox_override("panel", CadresPixel.style_marges("tampon", 18, 9, 18, 9))
	tp.add_child(Style.label("CHOISI", 28, Style.capitales(), PalettePixel.couleur("bleu_ardoise")))
	b.add_child(tp)
	tp.reset_size()
	tp.position = (Vector2(b.size.x - tp.size.x - 12.0, -12.0) / 3.0).round() * 3.0


## Rangement : fondu de 0,2 s (pas de vol vers la porte dans la version jouable).
func _ranger(_arrivee: Vector2) -> void:
	phase = "rangement"
	if is_instance_valid(_p):
		if Juice.animations_reduites:
			_p.visible = false
		else:
			var tf := _p.create_tween()
			tf.tween_property(_p, "modulate:a", 0.0, 0.2)
			await tf.finished
	_ranger_fin()

func _ranger_fin() -> void:
	if is_instance_valid(_p):
		_p.queue_free()
	if m.courant == _p:
		m.courant = null
		m.genre_courant = ""
		m.assombrir(0.0)
	_p = null
	phase = ""
	m.carte_en_cours = false
	m.carte_rangee.emit()


## Relecture d'une carte depuis l'historique (lecture seule) : titre, choix pris, montant, conséquence.
func lecture(h: Dictionary, a: int) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "info"
	m.assombrir(0.45)
	var c: Dictionary = h.get("contenu", {})
	var p := PanelContainer.new()
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.add_theme_stylebox_override("panel", Style.papier("tuile", 30.0, 18.0 if compact else 24.0))
	p.custom_minimum_size = Vector2(minf(900.0, m.get_viewport_rect().size.x - 60.0), 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8 if compact else 12)
	p.add_child(v)
	v.add_child(Style.label("HISTORIQUE · MA MAISON · " + Dates.texte(a).to_upper(), 20, Style.capitales(), Style.TEXTE_PAPIER_2))
	var titre := Style.label(str(c.get("titre", h.get("titre", ""))).to_upper(), 32 if compact else 40, Style.capitales(), Style.ENCRE)
	titre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(titre)
	var txt := Style.label(str(c.get("texte", "")), 22 if compact else 24, Style.ui(), Style.ENCRE)
	txt.name = "Defilant"
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(txt)
	var montant := float(c.get("montant_choisi", h.get("montant", 0.0)))
	var lc := Style.label("Votre choix : %s  ·  %s" % [str(c.get("choix_fait", h.get("choix", ""))), texte_montant(montant, a)], 24, Style.ui_gras(), PalettePixel.couleur("bois_sombre"))
	lc.name = "ChoixPris"
	lc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(lc)
	var consequence := str(c.get("consequence", h.get("resume", "")))
	if consequence != "":
		var lq := Style.label(consequence, 22 if compact else 24, Style.ui(), Style.TEXTE_PAPIER_2)
		lq.name = "Consequence"
		lq.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(lq)
	var bf := ModaleOutils.bouton_papier("FERMER", "", compact)
	bf.pressed.connect(m.fermer.bind("fermer"))
	v.add_child(bf)
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)
	if is_instance_valid(p):
		m.apparaitre(p)
