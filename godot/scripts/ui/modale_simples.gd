class_name ModaleSimples
extends RefCounted
## Morceau de Modales (T9) : les panneaux simples, panneau d'information, confirmation et menu.

var m: Modales


func _init(modales: Modales) -> void:
	m = modales


func confirmer(titre: String, texte: String, oui: String, non: String) -> void:
	m.compact = Ecran.compact()
	m.genre_courant = "confirmer"
	m.assombrir(0.55)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.panneau(18))
	p.custom_minimum_size = Vector2(minf(820.0, m.get_viewport_rect().size.x - 60.0), 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	p.add_child(v)
	v.add_child(Style.label(titre, 24, Style.capitales(), Style.TEXTE_2))
	var l := Style.label(texte, 24, Style.ui(), Style.TEXTE)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(l)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 16)
	var b_non := Style.bouton(non, true)
	b_non.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_non.pressed.connect(m.fermer.bind("non"))
	var b_oui := Style.bouton(oui)
	b_oui.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_oui.pressed.connect(m.fermer.bind("oui"))
	hb.add_child(b_non)
	hb.add_child(b_oui)
	v.add_child(hb)
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)
	b_non.grab_focus.call_deferred()


## extra : libellé d'un second bouton (ferme avec l'id « extra »), "" pour aucun.
func info(titre: String, lignes: Array, depart := Vector2(-1, -1), extra := "") -> void:
	m.genre_courant = "info"
	m.assombrir(0.35)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.panneau(18))
	p.custom_minimum_size = Vector2(minf(720.0, m.get_viewport_rect().size.x - 60.0), 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	v.add_child(Style.label(titre, 24, Style.capitales(), Style.TEXTE_2))
	for l in lignes:
		var lab := Style.label(str(l), 24, Style.ui(), Style.TEXTE)
		lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(lab)
	if extra != "":
		var bx := Style.bouton(extra)
		bx.pressed.connect(m.fermer.bind("extra"))
		v.add_child(bx)
	var ok := Style.bouton("FERMER")
	ok.pressed.connect(m.fermer.bind("fermer"))
	v.add_child(ok)
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)
	var cible := p.position
	if depart.x >= 0.0 and not Juice.animations_reduites:
		p.scale = Vector2(0.6, 0.6)
		p.position = depart - p.size * 0.3
		p.modulate.a = 0.0
		var tw := p.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(p, "position", cible, 0.3)
		tw.tween_property(p, "scale", Vector2.ONE, 0.3)
		tw.tween_property(p, "modulate:a", 1.0, 0.2)


func menu() -> void:
	m.genre_courant = "menu"
	m.assombrir(0.5)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Style.panneau(18))
	p.custom_minimum_size = Vector2(460, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	p.add_child(v)
	v.add_child(Style.label("MENU", 24, Style.capitales(), Style.TEXTE_2))
	var rep := Style.bouton("REPRENDRE", true)
	rep.pressed.connect(m.fermer.bind("reprendre"))
	v.add_child(rep)
	var hi := Style.bouton("HISTORIQUE")
	hi.pressed.connect(m.fermer.bind("historique"))
	v.add_child(hi)
	var q := Style.bouton("QUITTER LE JEU")
	q.pressed.connect(m.fermer.bind("quitter"))
	v.add_child(q)
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)
