class_name ChoixDepart
extends RefCounted
## Morceau de Modales : choix du départ d'une nouvelle partie (lot 10b, I9 ; D6), minimal en attendant l'écran de création du lot 12.
## Une carte par chapitre ouvert : « JANVIER 1984 » et la ligne de présentation du chapitre (chapitre.json > titre > sous_titre : le profil,
## jamais écrit ici). Toucher une carte ferme avec l'id du chapitre ; RETOUR, Échap ou clic extérieur : « retour ». Touches 1 à 3.

var m: Modales
var infos := {}   # contrôles : cartes [{id, titre, sous}], boutons


func _init(modales: Modales) -> void:
	m = modales


## Cartes des chapitres ouverts : [{id, titre, sous}].
static func cartes() -> Array:
	var out: Array = []
	for c: Dictionary in Donnees.chapitres():
		var id := str(c["id"])
		var inf := Donnees.infos_chapitre(id)
		var debut := str(inf.get("config", {}).get("debut", c.get("debut", "")))
		out.append({"id": id, "titre": Dates.texte(Dates.lire(debut), true), "sous": str(inf.get("titre", {}).get("sous_titre", str(c.get("nom", id))))})
	return out


func ouvrir(liste: Array) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "depart"
	m.assombrir(0.65)
	var vue := m.get_viewport_rect().size
	var p := PanelContainer.new()
	p.name = "ChoixDepart"
	var sf := Style.panneau(22)
	sf.content_margin_left = 24 if compact else 40
	sf.content_margin_right = 24 if compact else 40
	sf.content_margin_top = 12 if compact else 28
	sf.content_margin_bottom = 12 if compact else 28
	p.add_theme_stylebox_override("panel", sf)
	var largeur := (vue.x - 40.0) if compact else minf(1000.0, vue.x - 60.0)
	p.custom_minimum_size = Vector2(largeur, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10 if compact else 16)
	p.add_child(v)
	var titre := Style.label("CHOISISSEZ VOTRE DÉPART", 36 if compact else 44, Style.neon(), Style.ACCENT)
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(titre)
	var zone := VBoxContainer.new()
	zone.name = "Cartes"
	zone.add_theme_constant_override("separation", 10 if compact else 14)
	var rang := 0
	_boutons.clear()
	_ids.clear()
	for c: Dictionary in liste:
		var b := Button.new()
		b.name = "Depart_%s" % str(c["id"])
		b.focus_mode = Control.FOCUS_ALL
		b.custom_minimum_size = Vector2(0, 96 if compact else 120)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if rang == 0:
			b.theme_type_variation = "BoutonPrincipal"
		var col := VBoxContainer.new()
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		var l1 := Style.label("%d   %s" % [rang + 1, str(c["titre"])], 30 if compact else 36, Style.ui_gras(), Style.ENCRE if rang == 0 else Style.TEXTE)
		l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l1.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(l1)
		var l2 := Style.label(str(c["sous"]), 22 if compact else 26, Style.ui(), Style.ENCRE if rang == 0 else Style.TEXTE_2)
		l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(l2)
		b.add_child(col)
		b.pressed.connect(m.fermer.bind(str(c["id"])))
		zone.add_child(b)
		_boutons.append(b)
		_ids.append(str(c["id"]))
		rang += 1
	v.add_child(zone)
	var retour := Style.bouton("RETOUR", false, 72 if compact else 84)
	retour.name = "Retour"
	retour.pressed.connect(m.fermer.bind("retour"))
	v.add_child(retour)
	infos = {"cartes": liste.duplicate(true), "boutons": _boutons.size() + 1}
	m.poser(p)
	await m.centrer(p)
	if is_instance_valid(p) and not _boutons.is_empty():
		(_boutons[0] as Button).grab_focus.call_deferred()


var _boutons: Array = []
var _ids: Array = []


## Touches 1 à 3.
func choisir_rang(i: int) -> void:
	if i >= 0 and i < _ids.size():
		m.fermer(str(_ids[i]))
