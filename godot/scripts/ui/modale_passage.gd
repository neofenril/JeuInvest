class_name ModalePassage
extends RefCounted
## Morceau de Modales : carte de passage de chapitre, version A (docs/40 §1.2.3, lot 10b I5). Papier crème, titre « JANVIER 1989 »,
## trois repères chiffrés (patrimoine, écart face à Tata Livret, rang dans la rue), la promesse du titre d'époque (aucun titre
## révélé), « Ce qui vous attend » (texte du chapitre, rendu par la logique) et un seul bouton CONTINUER (id « continuer »).
## Ni Échap ni clic extérieur. Les chiffres ne roulent pas (déjà vus au relevé de décembre). Aucun calcul : tout vient de
## contenu_modale().

var m: Modales
var infos := {}   # contrôles : chiffres affichés, bouton


func _init(modales: Modales) -> void:
	m = modales


## Chapitre qui précède celui du contenu dans l'index ("" si aucun).
static func chapitre_precedent(id: String) -> String:
	var prec := ""
	for c: Dictionary in Donnees.chapitres(true):
		if str(c["id"]) == id:
			return prec
		prec = str(c["id"])
	return ""


## Textes affichés (aussi lus par les tests) : titre, sous-titre, vignettes [{titre, valeur, signe}], promesse, attente, objectif.
static func textes(c: Dictionary) -> Dictionary:
	var ab :=Dates.lire("%d-01" % int(c.get("annee", 0)))
	var ecart := float(c.get("ecart_tata_pct", 0.0))
	var vign: Array = [
		{"titre": "PATRIMOINE", "valeur": Format.montant(float(c.get("patrimoine", 0.0)), ab), "signe": 0},
		{"titre": "FACE À TATA LIVRET", "valeur": ModaleReleveFin.pct_texte(ecart), "signe": 1 if roundi(ecart) > 0 else (-1 if roundi(ecart) < 0 else 0)}]
	if int(c.get("rang", 0)) > 0:
		vign.append({"titre": "DANS LA RUE", "valeur": "%s sur 4" % BlocRue.rang_texte(int(c["rang"])), "signe": 0})
	var prec := chapitre_precedent(str(c.get("chapitre", "")))
	var promesse := ""
	if prec != "":
		promesse = "Votre titre d'époque %s vous attend au bilan final." % Noms.annees_chapitre(prec)
	var fin := Dates.texte(Dates.lire(str(c.get("fin_partie", "1993-12"))))
	return {"titre": str(c.get("date", "")).to_upper(), "sous_titre": str(c.get("nom_chapitre", "")), "vignettes": vign, "promesse": promesse,
		"attente": str(c.get("texte_attente", "")), "objectif": "Jusqu'en %s : continuez à faire mieux que Tata Livret." % fin}


func ouvrir(c: Dictionary, depart: Vector2) -> void:
	m.compact = Ecran.compact()
	var compact := m.compact
	m.genre_courant = "passage"
	m.assombrir(0.65)
	var t := textes(c)
	var vue := m.get_viewport_rect().size
	var largeur := (vue.x - 40.0) if compact else minf(1140.0, vue.x - 60.0)
	var p := PanelContainer.new()
	p.name = "Passage"
	p.add_theme_stylebox_override("panel", Style.papier("maison", 24.0 if compact else 36.0, 14.0 if compact else 28.0))
	p.custom_minimum_size = Vector2(largeur, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6 if compact else 12)
	p.add_child(v)
	var titre := Style.label(str(t["titre"]), 36 if compact else 48, Style.ui_gras(), Style.ENCRE)
	titre.name = "Titre"
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(titre)
	if str(t["sous_titre"]) != "":
		var st := Style.label(str(t["sous_titre"]), 22 if compact else 24, Style.ui(), Style.TEXTE_PAPIER_2)
		st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(st)
	v.add_child(ModaleOutils.filet(Style.TEXTE_PAPIER_2, 1))
	v.add_child(Style.label("OÙ VOUS EN ÊTES", 20, Style.capitales(), Style.TEXTE_PAPIER_2))
	var rang := HBoxContainer.new()
	rang.name = "Vignettes"
	rang.add_theme_constant_override("separation", 12 if compact else 18)
	var lv: Array = []
	for vg: Dictionary in t["vignettes"]:
		rang.add_child(_vignette(vg, compact, lv))
	v.add_child(rang)
	if str(t["promesse"]) != "":
		var lp := Style.label(str(t["promesse"]), 20 if compact else 22, Style.ui(), Style.TEXTE_PAPIER_2)
		lp.name = "Promesse"
		lp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(lp)
	v.add_child(ModaleOutils.filet(Style.TEXTE_PAPIER_2, 1))
	var lat := Style.label("CE QUI VOUS ATTEND", 20, Style.capitales(), Style.TEXTE_PAPIER_2)
	v.add_child(lat)
	var zone := VBoxContainer.new()
	zone.name = "Defilant"
	zone.add_theme_constant_override("separation", 6 if compact else 10)
	var ta := Style.label(str(t["attente"]), 22 if compact else 24, Style.ui(), Style.ENCRE)
	ta.name = "Attente"
	ta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	zone.add_child(ta)
	var to := Style.label(str(t["objectif"]), 22 if compact else 24, Style.ui_gras(), Style.ENCRE)
	to.name = "Objectif"
	to.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	zone.add_child(to)
	v.add_child(zone)
	var go := ModaleOutils.bouton_papier("CONTINUER ›", "", compact)
	go.name = "Continuer"
	go.custom_minimum_size.x = 440
	go.size_flags_horizontal = Control.SIZE_SHRINK_END
	go.pressed.connect(m.fermer.bind("continuer"))
	v.add_child(go)
	infos = {"titre": str(t["titre"]), "valeurs": lv, "promesse": str(t["promesse"]), "attente": str(t["attente"]), "boutons": 1}
	m.poser(p)
	m.fixer_largeurs(p)
	await m.centrer(p)
	if not is_instance_valid(p):
		return
	if depart.x >= 0.0 and not Juice.animations_reduites:
		p.pivot_offset = depart - p.position
	p.scale = Vector2(0.9, 0.9)
	p.modulate.a = 0.0
	var tw := p.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(p, "scale", Vector2.ONE, 0.2)
	tw.tween_property(p, "modulate:a", 1.0, 0.2)
	go.grab_focus.call_deferred()


## Une vignette : libellé en petites capitales, valeur en Atkinson gras (flèche et couleur papier pour l'écart).
func _vignette(vg: Dictionary, compact: bool, lues: Array) -> Control:
	var pc := PanelContainer.new()
	pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.set_border_width_all(3)
	sb.border_color = Style.TEXTE_PAPIER_2
	sb.set_content_margin_all(8 if compact else 12)
	pc.add_theme_stylebox_override("panel", sb)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	pc.add_child(col)
	col.add_child(Style.label(str(vg["titre"]), 18 if compact else 20, Style.capitales(), Style.TEXTE_PAPIER_2))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	var signe := int(vg["signe"])
	var c := Style.ENCRE if signe == 0 else (Style.GAIN_PAPIER if signe > 0 else Style.ENCRE_ROUGE)
	if signe != 0:
		h.add_child(ModaleOutils.fleche(signe > 0, c))
	var lv := Style.label(str(vg["valeur"]), 26 if compact else 32, Style.ui_gras(), c)
	lv.name = "Valeur"
	h.add_child(lv)
	col.add_child(h)
	lues.append(str(vg["valeur"]))
	return pc
