class_name Repartition
extends Control
## Barre de répartition du patrimoine (A1) : segments par catégorie, avec motifs (jamais la couleur seule)
## et étiquettes en clair sous la barre. Les parts se recalculent en douceur (0,4 s).

const LIBELLES := {"cc": "Compte", "livret": "Livret A", "pel": "PEL", "emprunt": "Emprunt", "av": "Ass.-vie", "sicav": "SICAV", "action": "Actions"}
const ORDRE := ["cc", "livret", "pel", "emprunt", "av", "sicav", "action"]

var parts := {"cc": 1.0, "livret": 0.0, "pel": 0.0, "emprunt": 0.0, "av": 0.0, "sicav": 0.0, "action": 0.0}
var _affiche := {"cc": 1.0, "livret": 0.0, "pel": 0.0, "emprunt": 0.0, "av": 0.0, "sicav": 0.0, "action": 0.0}


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 100)


func regler(valeurs: Dictionary, anime := true) -> void:
	var total := 0.0
	for k in ORDRE:
		total += maxf(0.0, float(valeurs.get(k, 0.0)))
	for k in ORDRE:
		parts[k] = maxf(0.0, float(valeurs.get(k, 0.0))) / total if total > 0.0 else 0.0
	if not anime or Juice.animations_reduites:
		_affiche = parts.duplicate()
		queue_redraw()
		return
	var depart := _affiche.duplicate()
	var arrivee := parts.duplicate()
	var etape := func(u: float) -> void:
		for k in ORDRE:
			_affiche[k] = lerpf(depart[k], arrivee[k], u)
		queue_redraw()
	create_tween().tween_method(etape, 0.0, 1.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var barre := Rect2(0, 0, size.x, 28)
	Dessin.arrondi(self, barre, Style.FILET, 8)
	var x := 0.0
	var police := Style.ui()
	for k in ORDRE:
		var w: float = barre.size.x * float(_affiche[k])
		if w < 1.0:
			continue
		var r := Rect2(x, 0, w, 28)
		var c: Color = Style.CATEGORIES[k]
		draw_rect(r, c)
		# Motifs : rayures pour le livret, points pour la SICAV, hachures croisées pour les actions
		if k == "livret":
			var sx := r.position.x - 28.0
			while sx < r.end.x:
				var a := Vector2(sx, 28)
				var b := Vector2(sx + 28, 0)
				var p0 := a.lerp(b, clampf((r.position.x - sx) / 28.0, 0.0, 1.0))
				var p1 := a.lerp(b, clampf((r.end.x - sx) / 28.0, 0.0, 1.0))
				if p1.x > p0.x:
					draw_line(p0, p1, Color(1, 1, 1, 0.25), 3.0)
				sx += 12.0
		elif k == "sicav":
			var px := r.position.x + 6.0
			while px < r.end.x - 3.0:
				draw_circle(Vector2(px, 9), 2.5, Color(1, 1, 1, 0.3))
				draw_circle(Vector2(px + 6, 19), 2.5, Color(1, 1, 1, 0.3))
				px += 12.0
		elif k == "action":
			var hx := r.position.x
			while hx < r.end.x:
				draw_line(Vector2(hx, 0), Vector2(hx, 28), Color(0, 0, 0, 0.15), 3.0)
				hx += 8.0
		draw_rect(Rect2(r.end.x - 2, 0, 2, 28), Color(Style.PANNEAU_OPAQUE, 0.9))
		x += w
	# Légende : pastilles et pourcentages
	var lx := 0.0
	var ly := 60.0
	for k in ORDRE:
		if float(parts[k]) <= 0.0005:
			continue
		var txt := "%s %s" % [LIBELLES[k], Format.nombre(float(parts[k]) * 100.0, 0) + " %"]
		var w := police.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
		if lx > 0.0 and lx + w + 26 > size.x:
			lx = 0.0
			ly += 28.0
		Dessin.arrondi(self, Rect2(lx, ly - 16, 16, 16), Style.CATEGORIES[k], 4)
		draw_string(police, Vector2(lx + 22, ly), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Style.TEXTE_2)
		lx += w + 34.0
