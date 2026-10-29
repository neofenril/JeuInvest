extends SceneTree
## Génère les icônes d'export à partir des SVG (à relancer après modification d'un SVG) :
##   Godot_console.exe --headless --path godot --script res://outils/generer_icones.gd
## Sorties dans res://assets/icone/ : icone_256.png, icone_192.png (Android, ancienne icône),
## android_avant.png et android_fond.png (432 × 432, icône adaptative), icone.ico (Windows).

const DOSSIER := "res://assets/icone/"
const TAILLES_ICO: Array[int] = [16, 24, 32, 48, 64, 128, 256]


func _init() -> void:
	var ok := true
	var principale := _texte("res://icon.svg")
	ok = _png(principale, 256, "icone_256.png") and ok
	ok = _png(principale, 192, "icone_192.png") and ok
	ok = _png(_texte(DOSSIER + "android_avant.svg"), 432, "android_avant.png") and ok
	ok = _png(_texte(DOSSIER + "android_fond.svg"), 432, "android_fond.png") and ok
	ok = _ico(principale) and ok
	print("Icônes générées." if ok else "ERREUR pendant la génération des icônes.")
	quit(0 if ok else 1)


func _texte(chemin: String) -> String:
	return FileAccess.get_file_as_string(chemin)


## Rendu d'un SVG carré à la taille demandée (le SVG source est conçu en 256 ou 432).
func _image(svg: String, taille: int) -> Image:
	var base := Image.new()
	base.load_svg_from_string(svg, 1.0)
	var image := Image.new()
	image.load_svg_from_string(svg, float(taille) / float(base.get_width()))
	if image.get_width() != taille:
		image.resize(taille, taille, Image.INTERPOLATE_LANCZOS)
	return image


func _png(svg: String, taille: int, nom: String) -> bool:
	var err := _image(svg, taille).save_png(DOSSIER + nom)
	if err != OK:
		push_error("PNG impossible : %s (%s)" % [nom, error_string(err)])
	return err == OK


## Fichier .ico à entrées PNG (format accepté par Windows depuis Vista).
func _ico(svg: String) -> bool:
	var images: Array[PackedByteArray] = []
	for t in TAILLES_ICO:
		images.append(_image(svg, t).save_png_to_buffer())
	var entete := PackedByteArray()
	entete.resize(6 + 16 * TAILLES_ICO.size())
	entete.encode_u16(0, 0)
	entete.encode_u16(2, 1)
	entete.encode_u16(4, TAILLES_ICO.size())
	var decalage := entete.size()
	for i in TAILLES_ICO.size():
		var o := 6 + 16 * i
		var t := TAILLES_ICO[i]
		entete.encode_u8(o, 0 if t >= 256 else t)
		entete.encode_u8(o + 1, 0 if t >= 256 else t)
		entete.encode_u8(o + 2, 0)
		entete.encode_u8(o + 3, 0)
		entete.encode_u16(o + 4, 1)
		entete.encode_u16(o + 6, 32)
		entete.encode_u32(o + 8, images[i].size())
		entete.encode_u32(o + 12, decalage)
		decalage += images[i].size()
	var f := FileAccess.open(DOSSIER + "icone.ico", FileAccess.WRITE)
	if f == null:
		push_error("ICO impossible : %s" % error_string(FileAccess.get_open_error()))
		return false
	f.store_buffer(entete)
	for donnees in images:
		f.store_buffer(donnees)
	f.close()
	return true
