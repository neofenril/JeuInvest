class_name ModaleCourrier
extends RefCounted
## Morceau de Modales (T9) : le courrier d'un événement de vie (04 §3.6) et le faire-part de naissance,
## avec l'enveloppe qui vole de la maison ; relecture depuis l'historique.

const TAILLE_VALEUR_TIMBRE := 20   # m2 (recette 02-I) : Atkinson, jamais sous 20 px

var m: Modales


func _init(modales: Modales) -> void:
	m = modales


## lecture_choix / ab_lecture : relecture depuis l'historique (le choix fait et la date d'alors, FERMER).
func ouvrir(c: Dictionary, depart: Vector2, e: EtatPartie, lecture_choix := "", ab_lecture := -1) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	var lecture := lecture_choix != ""
	m.genre_courant = "info" if lecture else "courrier"
	m.assombrir(0.6)
	var a := ab_lecture if lecture else e.ab_courant()
	var montant := float(c.get("montant", 0.0))
	var naissance: bool = c.get("effet", "") == "naissance"
	var bonne := montant > 0.0
	var p := PanelContainer.new()
	# Papier à lettre crème, liseré : rose (faire-part), vert (bonne nouvelle), rouge (dépense)
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.add_theme_stylebox_override("panel", Style.papier("neon_rose" if naissance else ("gain_papier" if bonne else "perte_papier"), 30.0, 24.0 if compact else 30.0))
	p.custom_minimum_size = Vector2(840, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8 if compact else 12)
	p.add_child(v)
	var tete := HBoxContainer.new()
	tete.add_theme_constant_override("separation", 12)
	var env := Control.new()
	env.custom_minimum_size = Vector2(40, 30)
	env.draw.connect(_dessiner_enveloppe.bind(env, PalettePixel.couleur("pierre_ombre")))
	env.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(env)
	var lt := Style.label(("FAIRE-PART · " if naissance else "COURRIER · ") + Dates.texte(a).to_upper(), 20, Style.capitales(), PalettePixel.couleur("pierre_ombre"))
	lt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tete.add_child(lt)
	var timbre := Control.new()
	timbre.name = "Timbre"
	timbre.custom_minimum_size = Vector2(108, 126)   # valeur « 2,20 F » en 20 px dans une bande sous l'image (C5)
	timbre.set_meta("taille_valeur", TAILLE_VALEUR_TIMBRE)
	timbre.draw.connect(_dessiner_timbre.bind(timbre, str(c.get("picto", ""))))
	tete.add_child(timbre)
	v.add_child(tete)
	var titre := Style.label(str(c["titre"]).to_upper(), 34, Style.ui_gras(), Style.ENCRE)
	titre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(titre)
	var txt := Style.label(str(c["texte"]), 26, Style.ui(), Style.ENCRE)
	txt.name = "Defilant"
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(txt)
	var info := _situation(c, e, a, lecture, lecture_choix, naissance, bonne, montant)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(info)
	var boutons: BoxContainer = VBoxContainer.new() if c["choix"].size() > 1 and not lecture else HBoxContainer.new()
	boutons.add_theme_constant_override("separation", 10)
	if lecture:
		var bf := ModaleOutils.bouton_papier("FERMER", "", compact)
		bf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bf.pressed.connect(m.fermer.bind("fermer"))
		boutons.add_child(bf)
		v.add_child(boutons)
		m.poser(p)
		m.fixer_largeurs(p)
		await m.centrer(p)
		if is_instance_valid(p):
			p.rotation = 0.0
			m.apparaitre(p)
		return
	for ch in c["choix"]:
		var titre_b := str(ch["titre"]).to_upper()
		if ch["id"] == "payer":
			titre_b = "PAYER " + Format.montant(-montant, a)
		var texte_b := titre_b + ("\n" + str(ch.get("sous", "")) if ch["id"] != "payer" and ch.get("sous", "") != "" else "")
		var b: Button = Style.bouton(texte_b, true) if ch == c["choix"][0] else ModaleOutils.bouton_papier(texte_b, "", false)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.disabled = bool(ch.get("desactive", false))
		b.pressed.connect(m.fermer.bind(str(ch["id"])))
		boutons.add_child(b)
	v.add_child(boutons)
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)
	_entree(p, depart)


## Situation du compte sous la lettre (ou le choix fait, en relecture).
func _situation(c: Dictionary, e: EtatPartie, a: int, lecture: bool, lecture_choix: String, naissance: bool, bonne: bool, montant: float) -> Label:
	var cc := e.joueur.cc
	if lecture:
		var t_lec := "Votre choix : " + lecture_choix
		if not naissance and absf(montant) > 0.004:
			t_lec += "  ·  " + Format.montant(montant, a, false, true)
		return Style.label(t_lec, 24, Style.ui_gras(), PalettePixel.couleur("bois_sombre"))
	if naissance:
		var reste := float(c.get("reste_apres", 0.0))
		var t_info := "Dépenses du mois : de %s à %s.  Il vous restera %s par mois." % [
			Format.montant(float(c.get("depenses_avant", 0.0)), a), Format.montant(float(c.get("depenses_apres", 0.0)), a), Format.montant(reste, a)]
		if reste < 0.0:
			t_info += " Le budget du mois devient négatif : il faudra puiser dans l'épargne."
		return Style.label(t_info, 24, Style.ui_gras() if reste < 0.0 else Style.ui(), Style.ENCRE_ROUGE if reste < 0.0 else PalettePixel.couleur("bois_sombre"))
	if bonne:
		return Style.label("Versée sur votre compte courant.", 24, Style.ui(), PalettePixel.couleur("gain_papier"))
	if cc >= -montant:
		var dep := float(e.depenses()["total"])
		var c0 := (maxf(0.0, cc) + e.joueur.livret) / dep
		var c1 := (maxf(0.0, cc + montant) + e.joueur.livret) / dep
		return Style.label("Compte courant : %s.  Votre coussin passe de %s à %s mois." % [Format.montant(cc, a), Format.nombre(c0, 1), Format.nombre(c1, 1)], 24, Style.ui(), PalettePixel.couleur("bois_sombre"))
	return Style.label("Compte courant : %s.  Il manque %s." % [Format.montant(cc, a), Format.montant(-montant - cc, a)], 24, Style.ui_gras(), Style.ENCRE_ROUGE)


## Entrée : l'enveloppe vole de la maison vers le centre, puis la lettre glisse du bas.
func _entree(p: Control, depart: Vector2) -> void:
	if not is_instance_valid(p):
		return
	var cible := p.position
	p.rotation = 0.0
	if Juice.animations_reduites:
		p.modulate.a = 0.0
		p.create_tween().tween_property(p, "modulate:a", 1.0, 0.15)
		return
	p.visible = false
	var enveloppe := Control.new()
	enveloppe.size = Vector2(180, 120)
	enveloppe.pivot_offset = enveloppe.size / 2.0
	enveloppe.position = depart - enveloppe.size / 2.0
	enveloppe.scale = Vector2(0.3, 0.3)
	enveloppe.draw.connect(_dessiner_grande_enveloppe.bind(enveloppe))
	m.add_child(enveloppe)
	var centre := m.get_viewport_rect().size / 2.0 - enveloppe.size / 2.0
	var tw := enveloppe.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(enveloppe, "position", centre, 0.5)
	tw.tween_property(enveloppe, "scale", Vector2(1.6, 1.6), 0.5)
	tw.tween_property(enveloppe, "rotation", deg_to_rad(-6.0), 0.5)
	tw.chain().tween_callback(enveloppe.queue_free)
	# T16 : la lettre peut être fermée (et libérée) pendant le vol de l'enveloppe : pas de capture directe de p.
	var ref_p: WeakRef = weakref(p)
	var montrer := func() -> void:
		var q: Control = ref_p.get_ref()
		if q != null:
			q.visible = true
	tw.chain().tween_callback(montrer)
	p.set_meta("enveloppe", weakref(enveloppe))
	p.position = cible + Vector2(0, 160)
	p.modulate.a = 0.0
	var tl := p.create_tween().set_parallel(true)
	tl.tween_property(p, "position", cible, 0.35).set_delay(0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tl.tween_property(p, "modulate:a", 1.0, 0.2).set_delay(0.5)


func _dessiner_enveloppe(c: Control, couleur: Color) -> void:
	var r := Rect2(Vector2(2, 2), c.size - Vector2(4, 4))
	c.draw_rect(r, couleur, false, 2.5)
	c.draw_polyline(PackedVector2Array([r.position, r.get_center() + Vector2(0, 2), Vector2(r.end.x, r.position.y)]), couleur, 2.5, true)


func _dessiner_grande_enveloppe(c: Control) -> void:
	var r := Rect2(Vector2.ZERO, c.size)
	c.draw_rect(r, PalettePixel.couleur("creme"))
	c.draw_colored_polygon(PackedVector2Array([r.position, Vector2(r.end.x, 0), r.get_center() + Vector2(0, 8)]), PalettePixel.couleur("pierre_claire"))
	c.draw_rect(Rect2(r.end.x - 46, 10, 34, 40), PalettePixel.couleur("rouge_auvent"))
	c.draw_rect(r, PalettePixel.couleur("pierre"), false, 2.0)


## Bébé emmailloté pour le timbre du faire-part (lange, visage, nœud).
func _dessiner_bebe(t: Control, c: Vector2, lange: Color, k: float) -> void:
	t.draw_circle(c + Vector2(0, -15) * k, 5 * k, lange.darkened(0.15))
	Dessin.arrondi(t, Rect2(c + Vector2(-18, -12) * k, Vector2(36, 30) * k), lange, int(12 * k))
	t.draw_circle(c + Vector2(0, -2) * k, 9 * k, PalettePixel.couleur("peau_claire"))
	t.draw_circle(c + Vector2(-3, -3) * k, 1.4 * k, PalettePixel.couleur("encre"))
	t.draw_circle(c + Vector2(3, -3) * k, 1.4 * k, PalettePixel.couleur("encre"))
	t.draw_arc(c, 3.0 * k, 0.3, PI - 0.3, 6, PalettePixel.couleur("terre_cuite_claire"), 1.4 * k)


## Timbre dentelé avec un pictogramme (voiture, dent, billet, bébé, jumeaux).
func _dessiner_timbre(t: Control, picto: String) -> void:
	var r := Rect2(Vector2(6, 6), t.size - Vector2(12, 12))
	t.draw_rect(r, PalettePixel.couleur("blanc_chaud"))
	var k := 0.0
	while k < r.size.x:
		t.draw_circle(Vector2(r.position.x + k, r.position.y), 3.5, Style.COURRIER)
		t.draw_circle(Vector2(r.position.x + k, r.end.y), 3.5, Style.COURRIER)
		k += 10.0
	k = 0.0
	while k < r.size.y:
		t.draw_circle(Vector2(r.position.x, r.position.y + k), 3.5, Style.COURRIER)
		t.draw_circle(Vector2(r.end.x, r.position.y + k), 3.5, Style.COURRIER)
		k += 10.0
	var interieur := r.grow(-8)
	interieur.size.y -= 24.0   # bande blanche du bas : la valeur faciale
	t.draw_rect(interieur, PalettePixel.couleur("ciel_clair"))
	var c := interieur.get_center()
	match picto:
		"voiture":
			Dessin.arrondi(t, Rect2(c.x - 26, c.y - 4, 52, 16), PalettePixel.couleur("rouge_auvent"), 4)
			t.draw_colored_polygon(PackedVector2Array([c + Vector2(-16, -4), c + Vector2(-9, -16), c + Vector2(12, -16), c + Vector2(18, -4)]), PalettePixel.couleur("rouge_auvent"))
			t.draw_circle(c + Vector2(-14, 13), 6, PalettePixel.couleur("encre"))
			t.draw_circle(c + Vector2(15, 13), 6, PalettePixel.couleur("encre"))
			for i in 3:
				t.draw_circle(c + Vector2(26 + i * 4, -6 - i * 8), 4 + i, Color(PalettePixel.couleur("gris_pierre"), 0.7))
		"coeur":
			t.draw_circle(c + Vector2(-8, -4), 10, PalettePixel.couleur("rouge_auvent"))
			t.draw_circle(c + Vector2(8, -4), 10, PalettePixel.couleur("rouge_auvent"))
			t.draw_colored_polygon(PackedVector2Array([c + Vector2(-17, 0), c + Vector2(17, 0), c + Vector2(0, 20)]), PalettePixel.couleur("rouge_auvent"))
		"bebe":
			_dessiner_bebe(t, c, PalettePixel.couleur("neon_rose"), 1.0)
		"jumeaux":
			_dessiner_bebe(t, c + Vector2(-13, 2), PalettePixel.couleur("neon_rose"), 0.75)
			_dessiner_bebe(t, c + Vector2(13, 2), PalettePixel.couleur("ciel_clair"), 0.75)
		_:
			t.draw_rect(Rect2(c.x - 24, c.y - 12, 48, 26), PalettePixel.couleur("vert"))
			t.draw_circle(c + Vector2(0, 1), 8, PalettePixel.couleur("vert_clair"))
	t.draw_string(Style.chiffres(), Vector2(r.position.x + 8, r.end.y - 9), "2,20 F", HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16, TAILLE_VALEUR_TIMBRE, PalettePixel.couleur("pierre_ombre"))
