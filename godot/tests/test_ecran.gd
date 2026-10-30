extends SceneTree
## Tests headless de l'échelle d'interface (lot PX2 §2.3, CA-I4) : facteur texel T entier, échelle,
## cibles tactiles de 48 dp sur mobile et téléphone simulé, 40 px physiques au moins sur PC à 1280 × 720.
## Lancer : Godot_console --headless --path godot --script res://tests/test_ecran.gd

var _ok := 0
var _ko := 0


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	var E: GDScript = load("res://scripts/ecran.gd")
	# PC : T = floor(hauteur / 360), texel = T px physiques, cible ≥ 40 px physiques
	for cas: Array in [[Vector2i(1280, 720), 2], [Vector2i(1366, 768), 2], [Vector2i(1920, 1080), 3], [Vector2i(2560, 1440), 4], [Vector2i(3840, 2160), 6], [Vector2i(1600, 900), 2], [Vector2i(1920, 1061), 3], [Vector2i(1920, 1000), 3], [Vector2i(1280, 648), 2]]:
		var taille: Vector2i = cas[0]
		var t: int = E.facteur_texel_pour(taille, 96.0, false)
		var ech: float = E.echelle_pour(taille, 96.0, false)
		verifier("PC %s : T = %d" % [taille, cas[1]], t == cas[1], "T = %d" % t)
		verifier("PC %s : 3 px virtuels = T px physiques" % taille, is_equal_approx(ech * 3.0, float(t)), "échelle %.4f" % ech)
		var cible: float = E.cible_min_pour(ech, E.dp_pour(96.0, false), false)
		verifier("PC %s : cible minimale ≥ 40 px physiques" % taille, cible * ech >= 40.0 - 0.001, "%.1f px virtuels" % cible)
		var f: float = E.facteur_contenu_pour(taille, 96.0, false)
		verifier("PC %s : facteur de contenu = échelle exacte (étirement « disabled »)" % taille, f == ech, "f = %.6f" % f)
	# Mobile : T entier, cible_min × échelle ≥ 48 dp, et les boutons dessinés (80 px virtuels) ≥ 48 dp
	for cas: Array in [[Vector2i(1600, 720), 267.0], [Vector2i(2400, 1080), 400.0], [Vector2i(2340, 1080), 395.0], [Vector2i(1280, 720), 320.0]]:
		var taille: Vector2i = cas[0]
		var dpi: float = cas[1]
		var t: int = E.facteur_texel_pour(taille, dpi, true)
		var ech: float = E.echelle_pour(taille, dpi, true)
		var dp: float = E.dp_pour(dpi, true)
		var cible: float = E.cible_min_pour(ech, dp, true)
		verifier("mobile %s à %d dpi : T entier ≥ 1 (T = %d)" % [taille, dpi, t], t >= 1 and is_equal_approx(ech * 3.0, float(t)))
		verifier("mobile %s à %d dpi : cible_min × échelle ≥ 48 dp" % [taille, dpi], cible * ech >= 48.0 * dp - 0.001, "%.1f px virtuels, %.1f px physiques, 48 dp = %.1f" % [cible, cible * ech, 48.0 * dp])
		verifier("mobile %s à %d dpi : un bouton dessiné (84 px virtuels, 28 texels) fait au moins 48 dp" % [taille, dpi], 84.0 * ech >= 48.0 * dp - 0.001, "%.1f px physiques" % (84.0 * ech))
		verifier("mobile %s à %d dpi : T est le plus petit qui convient" % [taille, dpi], t == 1 or 84.0 * (t - 1) / 3.0 < 48.0 * dp, "T = %d" % t)
	# Téléphone simulé (F10) : 1600 × 720 à 267 dpi → T = 3, 1 dp = 1,67 px, zone logique 1600 × 720
	verifier("téléphone simulé : T = 3", E.facteur_texel_pour(Vector2i(1600, 720), 267.0, true) == 3)
	verifier("téléphone simulé : 1 dp = 1,67 px", absf(E.dp_pour(267.0, true) - 1.66875) < 0.001)
	verifier("PC : 1 dp = 1 px", E.dp_pour(96.0, false) == 1.0)
	print("")
	print("=== test_ecran : %d OK, %d KO (%d ms) ===" % [_ok, _ko, Time.get_ticks_msec() - t0])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, condition: bool, detail := "") -> void:
	if condition:
		_ok += 1
		print("OK  ", nom)
	else:
		_ko += 1
		print("KO  ", nom, "  [", detail, "]")
