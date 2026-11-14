class_name BlocRue
extends VBoxContainer
## Bloc « LA RUE » du panneau « Mon argent » (lot 06, 05-I R2 ; docs/24 §2.2, lot_06 §10 A1-A2) : le classement permanent
## (4 lignes de `classement_rue()`), en tête du panneau sur PC, en 3e colonne (ou en tête de la colonne A) au téléphone.
## Ligne : rang (Atkinson gras), pastille d'initiale, nom, patrimoine (`Format.entier`, négatif en perte avec le signe) ;
## la ligne « vous » est encadrée d'ambre et en gras ; la ligne de Tata (référence) est soulignée d'un pointillé ambre, puis une
## ligne de légende ; sous Jean-Mi, en secondaire, `jeanmi_resume().etape_texte`. Lecture seule : aucune cible, aucune animation.

const HAUTEUR_LIGNE := 33.0
const HAUTEUR_LIGNE_TEL := 36.0
const COULEURS := {"vous": "ambre", "livret": "vert_sombre", "matelas": "bois", "jeanmi": "bleu_nuit"}   # fonds foncés : aucun ne se lit comme un gain ou une perte
const LEGENDE := "Référence : tout au Livret A."

var lignes_texte: Array = []          # un Dictionary par ligne : {rang, nom, montant, vous, negatif, etape} (lu par les tests)
var l_vous: Label
var compact := false
var _rangee: VBoxContainer
var _entete_droite: Label


func _init() -> void:
	name = "BlocRue"
	add_theme_constant_override("separation", 3)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tete := HBoxContainer.new()
	tete.name = "EnteteRue"
	var l := Style.label("LA RUE", 20, Style.capitales(), Style.TEXTE_2)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tete.add_child(l)
	l_vous = Style.label("", 22, Style.ui_gras(), Style.TEXTE)
	l_vous.name = "VousRang"
	tete.add_child(l_vous)
	add_child(tete)
	_rangee = VBoxContainer.new()
	_rangee.name = "Rangee"
	_rangee.add_theme_constant_override("separation", 3)
	add_child(_rangee)


## « 1er », « 2e », « 3e », « 4e » (pas de « ᵉ » : le glyphe manque aux polices).
static func rang_texte(r: int) -> String:
	return "1er" if r == 1 else "%de" % r


## Patrimoine d'une ligne du classement (francs, signé) : « 69 395 F », « −12 400 F ».
static func texte_patrimoine(francs: float, a: int) -> String:
	return Format.entier(francs / Format.TAUX_EURO, a)


## Pastille d'initiale (cote en px virtuels, multiple de 3) : fond foncé de la personne, lettre Atkinson gras, contour encre.
static func pastille(id: String, initiale: String, cote := 30.0, taille_lettre := 20) -> Control:
	var pc := PanelContainer.new()
	pc.name = "Pastille_" + id
	pc.custom_minimum_size = Vector2(cote, cote)
	pc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = PalettePixel.couleur(str(COULEURS.get(id, "bleu_nuit")))
	sb.set_border_width_all(3)
	sb.border_color = Style.ENCRE
	pc.add_theme_stylebox_override("panel", sb)
	var l := Style.label(initiale, taille_lettre, Style.ui_gras(), Style.ENCRE if id == "vous" else PalettePixel.couleur("creme"))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pc.add_child(l)
	return pc


## Met le bloc à jour : `classement` = classement_rue() ; `jeanmi` = jeanmi_resume() ({} si absent) ; `a` = mois affiché.
## Renvoie false (bloc à cacher) si le classement est vide (rue éteinte).
func maj(classement: Array, jeanmi: Dictionary, a: int) -> bool:
	for c in _rangee.get_children():
		_rangee.remove_child(c)
		c.queue_free()
	lignes_texte.clear()
	if classement.is_empty():
		return false
	var h := HAUTEUR_LIGNE_TEL if compact else HAUTEUR_LIGNE
	for l: Dictionary in classement:
		var vous := bool(l.get("vous", false))
		var id := str(l.get("id", ""))
		var p := float(l.get("patrimoine", 0.0))
		var negatif := p < -0.5
		var rang := int(l.get("rang", 0))
		var ligne := HBoxContainer.new()
		ligne.name = "Ligne_" + id
		ligne.custom_minimum_size = Vector2(0, h)
		ligne.add_theme_constant_override("separation", 9)
		var lr := Style.label(rang_texte(rang), 22, Style.ui_gras(), Style.TEXTE)
		lr.custom_minimum_size.x = 39
		lr.name = "Rang"
		ligne.add_child(lr)
		ligne.add_child(pastille(id, str(l.get("initiale", "")), 30.0))
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 0)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var ln := Style.label(str(l.get("nom", "")), 22, Style.ui_gras() if vous else Style.ui(), Style.TEXTE)
		ln.name = "Nom"
		ln.clip_text = true
		ln.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		ln.custom_minimum_size.x = 60
		col.add_child(ln)
		var etape := ""
		if id == "jeanmi":
			etape = str(jeanmi.get("etape_texte", ""))
		if etape != "":
			var le := Style.label(etape, 20, Style.ui(), Style.TEXTE_2)
			le.name = "EtapeJeanMi"
			le.clip_text = true
			le.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			le.custom_minimum_size.x = 60
			col.add_child(le)
		ligne.add_child(col)
		var texte := texte_patrimoine(p, a)
		var lm := Style.label(texte, 22, Style.chiffres(), Style.PERTE if negatif else Style.TEXTE)
		lm.name = "Montant"
		lm.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		ligne.add_child(lm)
		lignes_texte.append({"id": id, "rang": rang, "nom": str(l.get("nom", "")), "montant": texte, "vous": vous, "negatif": negatif, "etape": etape})
		if vous:
			var cadre := PanelContainer.new()
			cadre.name = "CadreVous"
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color(0, 0, 0, 0)
			sb.set_border_width_all(3)
			sb.border_color = PalettePixel.couleur("ambre")
			sb.content_margin_left = 6
			sb.content_margin_right = 6
			cadre.add_theme_stylebox_override("panel", sb)
			cadre.add_child(ligne)
			_rangee.add_child(cadre)
		else:
			_rangee.add_child(ligne)
		if bool(l.get("reference", false)):
			var pt := Control.new()
			pt.name = "PointilleReference"
			pt.custom_minimum_size = Vector2(0, 3)
			pt.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pt.draw.connect(_dessiner_pointille.bind(pt))
			_rangee.add_child(pt)
			var lg := Style.label(LEGENDE, 20, Style.ui(), Style.TEXTE_2)
			lg.name = "LegendeReference"
			lg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lg.custom_minimum_size.x = 60
			_rangee.add_child(lg)
	l_vous.text = "VOUS : %s / %d" % [rang_texte(_rang_de(classement)), classement.size()]
	return true


static func _rang_de(classement: Array) -> int:
	for l: Dictionary in classement:
		if bool(l.get("vous", false)):
			return int(l.get("rang", 0))
	return 0


## Pointillé ambre : 6 px plein, 3 px vide, épaisseur 3 px (1 texel).
func _dessiner_pointille(c: Control) -> void:
	var x := 0.0
	while x < c.size.x:
		c.draw_rect(Rect2(x, 0, minf(6.0, c.size.x - x), 3), PalettePixel.couleur("ambre"))
		x += 9.0
