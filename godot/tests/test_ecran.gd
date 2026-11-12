extends SceneTree
## Tests headless de l'échelle d'interface (lot PX2 §2.3 et §9.1, CA-I4 puis CA-C1) : facteur texel T entier,
## T ≥ 2 sur PC, plafond mobile (zone virtuelle ≥ 1280 × 648), cible_min = min(48 dp, 84) sur mobile.
## Lot 03 : composant Bulle (I4, CA-I1). Le total du relevé (D6) est vérifié dans test_interface (autoloads).
## Lancer : Godot_console --headless --path godot --script res://tests/test_ecran.gd

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	var E: GDScript = load("res://scripts/ecran.gd")
	# PC : T = max(2, floor(côté court / 324)), texel = T px physiques, cible ≥ 40 px physiques
	for cas: Array in [[Vector2i(1280, 720), 2], [Vector2i(1366, 768), 2], [Vector2i(1920, 1080), 3], [Vector2i(2560, 1440), 4], [Vector2i(3840, 2160), 6],
			[Vector2i(1600, 900), 2], [Vector2i(1920, 1061), 3], [Vector2i(1920, 1009), 3], [Vector2i(1280, 640), 2], [Vector2i(1152, 648), 2]]:
		var taille: Vector2i = cas[0]
		var t: int = E.facteur_texel_pour(taille, 96.0, false)
		var ech: float = E.echelle_pour(taille, 96.0, false)
		verifier("PC %s : T = %d" % [taille, cas[1]], t == cas[1], "T = %d" % t)
		verifier("PC %s : 3 px virtuels = T px physiques" % taille, is_equal_approx(ech * 3.0, float(t)), "échelle %.4f" % ech)
		var cible: float = E.cible_min_pour(ech, E.dp_pour(96.0, false), false)
		verifier("PC %s : cible minimale ≥ 40 px physiques" % taille, cible * ech >= 40.0 - 0.001, "%.1f px virtuels" % cible)
		var f: float = E.facteur_contenu_pour(taille, 96.0, false)
		verifier("PC %s : facteur de contenu = échelle exacte (étirement « disabled »)" % taille, f == ech, "f = %.6f" % f)
		var zone := Vector2(taille) / ech
		if taille.x >= 1152 and taille.y >= 648:
			verifier("PC %s : zone virtuelle ≥ 1728 × 972 (fenêtre ≥ 1152 × 648)" % taille, zone.x >= 1727.9 and zone.y >= 971.9, str(zone))
	verifier("PC : T ≥ 2 même pour une fenêtre minuscule", E.facteur_texel_pour(Vector2i(800, 450), 96.0, false) == 2)
	verifier("PC : taille minimale de fenêtre 1152 × 648", E.FENETRE_MIN_PC == Vector2i(1152, 648))
	# Mobile (§9.1) : [taille, dpi, T attendu, zone attendue]
	for cas: Array in [[Vector2i(2400, 1080), 400.0, 5, Vector2(1440, 648)], [Vector2i(2340, 1080), 395.0, 5, Vector2(1404, 648)],
			[Vector2i(2400, 1080), 480.0, 5, Vector2(1440, 648)], [Vector2i(1600, 720), 267.0, 3, Vector2(1600, 720)],
			[Vector2i(1280, 720), 320.0, 3, Vector2(1280, 720)], [Vector2i(3200, 1440), 560.0, 6, Vector2(1600, 720)],
			[Vector2i(1440, 648), 240.0, 3, Vector2(1440, 648)]]:
		var taille: Vector2i = cas[0]
		var dpi: float = cas[1]
		var t: int = E.facteur_texel_pour(taille, dpi, true)
		var ech: float = E.echelle_pour(taille, dpi, true)
		var dp: float = E.dp_pour(dpi, true)
		var cible: float = E.cible_min_pour(ech, dp, true)
		var zone := Vector2(taille) / ech
		verifier("mobile %s à %d dpi : T = %d" % [taille, dpi, cas[2]], t == cas[2], "T = %d" % t)
		verifier("mobile %s à %d dpi : zone %s" % [taille, dpi, cas[3]], zone.distance_to(cas[3]) < 0.5, str(zone))
		verifier("mobile %s à %d dpi : zone ≥ 1280 × 648" % [taille, dpi], zone.x >= 1279.9 and zone.y >= 647.9, str(zone))
		verifier("mobile %s à %d dpi : cible_min = min(48 dp, 84)" % [taille, dpi], is_equal_approx(cible, minf(ceilf(48.0 * dp / ech), 84.0)), "%.1f" % cible)
		verifier("mobile %s à %d dpi : un bouton de 84 px virtuels fait au moins 42 dp" % [taille, dpi], 84.0 * ech >= 42.0 * dp - 0.01, "%.1f px physiques, 42 dp = %.1f" % [84.0 * ech, 42.0 * dp])
	# Téléphones simulés
	verifier("téléphone simulé principal : 1440 × 648 à 240 dpi", E.FENETRE_TELEPHONE == Vector2i(1440, 648) and E.DPI_TELEPHONE == 240.0)
	verifier("téléphone simulé 169 : 1280 × 720 à 320 dpi", E.FENETRE_TELEPHONE_169 == Vector2i(1280, 720) and E.DPI_TELEPHONE_169 == 320.0)
	verifier("téléphone simulé principal : échelle 1 (T = 3)", E.facteur_texel_pour(E.FENETRE_TELEPHONE, E.DPI_TELEPHONE, true) == 3)
	verifier("PC : 1 dp = 1 px", E.dp_pour(96.0, false) == 1.0)
	await _tests_bulle()
	print("")
	print("=== test_ecran : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


## Lot 03, I4 : composant Bulle (CA-I1) : bornes, pointe vers l'ancre, ancre hors champ, disparition, souris.
func _tests_bulle() -> void:
	var racine := get_root()
	var police := Style.ui()
	# Coupe du texte : 1 ligne si court, 2 lignes au plus sinon, chacune ≤ largeur
	verifier("bulle : texte court sur une ligne", not Bulle.lignes_bulle("Sylvie est ravie", police, 22, 420.0).contains("\n"))
	var long := Bulle.lignes_bulle("L'île de Ré, c'était parfait ! On y retourne l'an prochain, et cette fois on emmène les enfants et la tante Odette avec nous.", police, 22, 420.0)
	var lignes := long.split("\n")
	verifier("bulle : texte long coupé en 2 lignes, terminé par une ellipse", lignes.size() == 2 and (long.ends_with("…") or long.ends_with("...")), long.replace("\n", " / "))
	verifier("bulle : chaque ligne ≤ 420 px", Array(lignes).all(func(x: String) -> bool: return police.get_string_size(x, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x <= 420.0))
	# Placement dans un rectangle imposé
	var borne := Rect2(120, 120, 900, 480)
	var ancres := [Vector2(570, 420)]
	var b := Bulle.montrer(racine, "Sylvie est ravie", func() -> Vector2: return ancres[0], 0.6)
	b.borne = borne
	await process_frame
	await process_frame
	var bout := b.bout_pointe()
	verifier("bulle : visible, dans le rectangle libre", b.visible and borne.grow(0.5).encloses(b.rect_total()), str(b.rect_total()))
	verifier("bulle : au-dessus de l'ancre, pointe vers le bas, bout sur l'ancre", b.pointe_vers_bas and absf(bout.x - 570.0) <= 3.0 and 420.0 - bout.y >= 0.0 and 420.0 - bout.y <= 6.0, "bout %s" % bout)
	verifier("bulle : texte Atkinson ≥ 20 px", PolicesPixel.est_atkinson(b.texte_label.get_theme_font("font")) and b.texte_label.get_theme_font_size("font_size") >= 20)
	verifier("bulle : mouse_filter IGNORE (bulle et enfants)", b.mouse_filter == Control.MOUSE_FILTER_IGNORE and b.find_children("*", "Control", true, false).all(func(c: Control) -> bool: return c.mouse_filter == Control.MOUSE_FILTER_IGNORE))
	verifier("bulle : position et taille sur la grille des texels (multiples de 3)", fmod(b.global_position.x, 3.0) == 0.0 and fmod(b.global_position.y, 3.0) == 0.0 and fmod(b.size.x, 3.0) == 0.0 and fmod(b.size.y, 3.0) == 0.0, "%s %s" % [b.global_position, b.size])
	# Ancre près du haut : la bulle passe dessous, pointe vers le haut
	ancres[0] = Vector2(900, 135)
	await process_frame
	bout = b.bout_pointe()
	verifier("bulle : sans place au-dessus, sous l'ancre, pointe vers le haut", not b.pointe_vers_bas and bout.y >= 135.0 and bout.y - 135.0 <= 6.0 and absf(bout.x - 900.0) <= 3.0, "bout %s" % bout)
	verifier("bulle : toujours dans le rectangle libre (en haut)", borne.grow(0.5).encloses(b.rect_total()), str(b.rect_total()))
	# Ancre au bord gauche : la bulle reste dans le rectangle, la pointe va vers l'ancre sans quitter le cadre
	ancres[0] = Vector2(124, 500)
	await process_frame
	bout = b.bout_pointe()
	verifier("bulle : ancre au bord gauche, bulle bornée", borne.grow(0.5).encloses(b.rect_total()), str(b.rect_total()))
	verifier("bulle : pointe au plus près de l'ancre, hors des coins", bout.x - b.global_position.x >= Bulle.COIN + Bulle.POINTE.x / 2.0 - 0.5 and bout.x - 124.0 <= Bulle.COIN + Bulle.POINTE.x / 2.0 + 3.0, "bout %s, bulle %s" % [bout, b.global_position])
	# Ancre hors champ : cachée, puis revient
	ancres[0] = Vector2(-1, -1)
	await process_frame
	verifier("bulle : ancre (-1, -1) : cachée", not b.visible)
	ancres[0] = Vector2(570, 420)
	await process_frame
	verifier("bulle : l'ancre revient : visible", b.visible)
	var b2 := Bulle.montrer(racine, "Hors champ", func() -> Vector2: return Vector2(-1, -1), 0.6)
	verifier("bulle : ancrée hors champ dès le départ : cachée", not b2.visible)
	var b3 := Bulle.montrer(racine, "Fermée à la main", func() -> Vector2: return Vector2(300, 300), 30.0)
	b3.fermer()
	# Disparition après « duree » (0,6 s + fondu 0,2 s)
	var wb: WeakRef = weakref(b)
	var wb2: WeakRef = weakref(b2)
	var wb3: WeakRef = weakref(b3)
	verifier("bulle : encore là avant la fin de sa durée", wb.get_ref() != null)
	await create_timer(1.3).timeout
	verifier("bulle : disparue après sa durée", wb.get_ref() == null and wb2.get_ref() == null)
	verifier("bulle : fermer() la retire", wb3.get_ref() == null)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom)
	else:
		_ko += 1
		print("KO  ", nom, "  [", detail, "]")
