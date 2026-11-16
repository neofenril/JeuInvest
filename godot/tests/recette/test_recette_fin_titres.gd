extends Node
## Recette 07-I (testeur), CA-T11 / T12 / T14 : parties COMPLETES par la vraie scene principale (saut « prochain courrier »),
## records.sav ISOLE (Partie.chemin_records) : a la fin l'ecran de fin montre le titre et le record ecrit ; l'ecran titre suivant montre
## la rangee « Meilleur resultat ». Partie A (actif 7), B (identique : egalite, rien de nouveau), C (passif 31 : autre resultat).
## TESTEUR_FMT=tel : format telephone. TESTEUR_IMG=<dossier> : photo de l'ecran de fin.

var ok := 0
var ko := 0
var scene: Node
var modales: Modales


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		ko += 1
		print("KO  ", nom, "  [", detail, "]")


func _images(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _ready() -> void:
	if OS.get_environment("TESTEUR_FMT") == "tel":
		Ecran.basculer_telephone()
		await get_tree().create_timer(0.5).timeout
	var pid := OS.get_process_id()
	Partie.chemin_sauvegarde = "user://recette_fin_%d.sav" % pid
	Partie.chemin_records = "user://recette_records_%d.sav" % pid
	Records.effacer(Partie.chemin_records)
	verifier("records isole absent au depart", Records.lire(Partie.chemin_records)["record"].is_empty())
	var a := await _partie(true, 7, "A")
	var rec_a := Records.lire(Partie.chemin_records)
	verifier("A : record ecrit apres la fin (ecart %s)" % str((rec_a["record"] as Dictionary).get("ecart_pct", "?")), not (rec_a["record"] as Dictionary).is_empty())
	verifier("A : titre affiche == titre du record == bilan", a["titre"] != "" and str(a["titre"]).to_upper() == str(a["vu"]) and str((rec_a["record"] as Dictionary).get("titre_nom", "")) == a["titre"], "%s | %s" % [a["titre"], a["vu"]])
	verifier("A : NOUVEAU DANS LA COLLECTION a la 1re obtention", a["nouveau_coll"], "")
	verifier("A : etat record = nouveau (1re partie)", a["etat"] == "nouveau", a["etat"])
	await _ecran_titre("apres A")
	var ecart_a := float((rec_a["record"] as Dictionary).get("ecart_pct", 0.0))
	var n_a := int((rec_a["collection"] as Dictionary).size())
	var b := await _partie(true, 7, "B")
	var rec_b := Records.lire(Partie.chemin_records)
	verifier("B (identique) : record inchange (egalite = ancien)", is_equal_approx(float((rec_b["record"] as Dictionary).get("ecart_pct", -1.0)), ecart_a), str(rec_b["record"]))
	verifier("B : pas de NOUVEAU DANS LA COLLECTION (deja obtenu)", not b["nouveau_coll"], "")
	verifier("B : titre meme que A", b["titre"] == a["titre"], "%s | %s" % [b["titre"], a["titre"]])
	var tt := int(((rec_b["collection"] as Dictionary).get(str((rec_b["record"] as Dictionary).get("titre_id", "")), {}) as Dictionary).get("nombre", 0))
	verifier("B : compteur du titre = 2", tt == 2, str(tt))
	var c := await _partie(false, 31, "C")
	var rec_c := Records.lire(Partie.chemin_records)
	var pire := float(c["ecart"]) < ecart_a
	print("RECETTE C ecart partie=%.2f record=%.2f titre C=%s titre A=%s" % [float(c["ecart"]), float((rec_c["record"] as Dictionary).get("ecart_pct", -1.0)), c["titre"], a["titre"]])
	if pire:
		verifier("C (moins bonne) : record garde", is_equal_approx(float((rec_c["record"] as Dictionary).get("ecart_pct", -1.0)), ecart_a), str(rec_c["record"]))
		verifier("C : etat record 'ancien' (pas nouveau)", c["etat"] != "nouveau", c["etat"])
	if c["titre"] != a["titre"]:
		verifier("C : nouveau titre -> NOUVEAU DANS LA COLLECTION", c["nouveau_coll"], "")
		verifier("C : collection grandit", (rec_c["collection"] as Dictionary).size() == n_a + 1, str((rec_c["collection"] as Dictionary).size()))
	await _ecran_titre("apres C")
	# collection ouverte depuis le titre (touche T)
	scene.call("ouvrir_titres")
	await get_tree().create_timer(1.0).timeout
	verifier("collection ouverte (genre titres)", modales.genre_courant == "titres" and modales.courant != null, modales.genre_courant)
	var inconnus := 0
	var tuiles := 0
	for l: Node in modales.courant.find_children("*", "Label", true, false):
		if (l as Label).text == "???":
			inconnus += 1
	for t: Node in modales.courant.find_children("Tuile_*", "PanelContainer", true, false):
		tuiles += 1
	var oc := (rec_c["collection"] as Dictionary).size()
	verifier("collection : 9 tuiles, %d obtenus -> %d ???" % [oc, 9 - oc], tuiles == 9 and inconnus == 9 - oc, "tuiles=%d inconnus=%d" % [tuiles, inconnus])
	await _photo("collection")
	modales.fermer("fermer")
	await _images(5)
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	Records.effacer(Partie.chemin_records)
	print("=== recette fin/titres : %d OK, %d KO ===" % [ok, ko])
	get_tree().quit(1 if ko > 0 else 0)


func _ecran_titre(quand: String) -> void:
	if scene != null and is_instance_valid(scene):
		scene.queue_free()
		await _images(5)
	scene = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await get_tree().create_timer(2.5).timeout
	modales = scene.get("modales")
	print("RECETTE sonde %s : genre=%s ouverte=%s en_titre=%s fin=%s tel_dernier_bilan_patrimoine=%s" % [quand, modales.genre_courant, str(modales.ouverte()), str(scene.get("en_titre")), Partie.etat.fin, str(modales.dernier_bilan.get("nominal", {}))])
	await _photo("titre_" + quand.replace(" ", "_"))
	print("RECETTE sonde apres photo %s : genre=%s" % [quand, modales.genre_courant])
	var titre = scene.get("titre")
	var rec := Records.lire(Partie.chemin_records)
	var r: Dictionary = rec["record"]
	var tx: String = titre.l_palmares.text
	verifier("Ecran titre %s : rangee palmares visible" % quand, titre.rangee_palmares.visible, "")
	verifier("Ecran titre %s : phrase contient 'Meilleur resultat' (sans accents tolere), titre et ecart du fichier" % quand, tx.to_lower().contains("meilleur") and tx.contains(str(r.get("titre_nom", "?"))), tx)
	print("RECETTE titre %s : « %s » bouton=« %s »" % [quand, tx, titre.bouton_titres.text])


func _partie(actif: bool, graine: int, nom: String) -> Dictionary:
	StrategieTest.politique_projets = "plus_cher"
	StrategieTest.politique_echeance = "vendre"
	StrategieTest.politique_cartes = "epargner" if graine == 7 else "alterner"
	scene = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await _images(5)
	modales = scene.get("modales")
	var seq = scene.get("sequences")
	var cfg := Donnees.config_demo(graine)
	cfg["cartes"] = true
	cfg["projets"] = true
	cfg["rue"] = true
	scene.set("_ignorer_modales", true)
	Partie.nouvelle_partie(cfg)
	scene.set("_ignorer_modales", false)
	scene.call("_apres_mise_en_place")
	Partie.etat.resolution_auto()
	scene.call("demarrer_direct", 0)
	await _images(10)
	Partie.bloquee = false
	var e := Partie.etat
	var t0 := Time.get_ticks_msec()
	var sig := ""
	var t_vu := Time.get_ticks_msec()
	var traite := ""
	var res := {"titre": "", "vu": "", "nouveau_coll": false, "etat": "", "ecart": 0.0}
	while Time.get_ticks_msec() - t0 < 540000:
		await get_tree().process_frame
		if modales.genre_courant == "fin" and modales.courant != null:
			break
		var kind := str(e.modale.get("kind", ""))
		var s := "%d|%s|%s|%s|%s|%s" % [e.ab_courant(), str(e.modale.get("id", "")), str(modales.ouverte()), str(seq.occupe), modales.genre_courant, str(Partie.saut_actif)]
		if kind == "carte":
			s += "|" + modales.etat_carte().phase
		elif kind == "projet":
			s += "|" + modales.etat_projet().phase + str(modales.etat_projet().en_confirmation)
		if s != sig:
			sig = s
			t_vu = Time.get_ticks_msec()
		elif Time.get_ticks_msec() - t_vu > 40000:
			verifier("%s : bloque : %s" % [nom, s], false)
			break
		if not e.modale.is_empty():
			if not modales.ouverte():
				continue
			var cle := "%d|%s|%s|%s" % [e.ab_courant(), str(e.modale.get("id", "")), str(e.modale.get("etape", "")), kind]
			if kind == "carte" or kind == "projet":
				var mm: ModaleCarte = modales.etat_carte() if kind == "carte" else modales.etat_projet()
				if mm.phase == "conclusion":
					mm.passer()
					continue
				if mm.phase != "attente" or modales.genre_courant != kind:
					continue
				if traite == cle and kind == "carte":
					continue
				if traite == cle and kind == "projet" and not (mm as ModaleProjet).en_confirmation:
					continue
				traite = cle
				await _agir(e, kind, mm, actif)
			elif traite != cle:
				traite = cle
				await _images(8)
				if modales.ouverte() and not e.modale.is_empty():
					modales.fermer(StrategieTest.choix_modale(e, actif))
			continue
		if modales.ouverte() and modales.genre_courant == "banque":
			await _images(20)
			if modales.ouverte() and modales.genre_courant == "banque":
				modales.fermer("fermer")
			continue
		if seq.occupe or modales.ouverte() or Partie.saut_actif or Partie.bloquee:
			continue
		if e.m >= e.m_fin:
			StrategieTest.jouer_mois(e, actif)
			Partie.changer_vitesse(3)
			continue
		StrategieTest.jouer_mois(e, actif)
		Partie.sauter_jusqu_au_prochain_arret()
	verifier("%s : partie finie, ecran de fin ouvert (fin=%s %s)" % [nom, e.fin, Dates.texte(e.ab_courant())], e.fin == "fin" and modales.genre_courant == "fin", "")
	await get_tree().create_timer(3.0).timeout
	var mf: ModaleReleveFin = modales.etat_fin()
	var f: Dictionary = mf.infos_fin
	res["titre"] = str(f.get("titre", ""))
	res["etat"] = str(f.get("record", ""))
	var nl := modales.courant.find_child("NomTitre", true, false) as Label
	res["vu"] = nl.text if nl != null else ""
	for l: Node in modales.courant.find_children("*", "Label", true, false):
		if (l as Label).text.contains("NOUVEAU DANS LA COLLECTION"):
			res["nouveau_coll"] = true
		if (l as Label).text.to_lower().contains("étoile"):
			verifier("%s : aucun texte etoile" % nom, false, (l as Label).text)
	var db = modales.get("dernier_bilan") if modales.get("dernier_bilan") != null else Partie.get("dernier_bilan")
	if db is Dictionary:
		res["ecart"] = float((db as Dictionary).get("ecart_tata_pct", 0.0))
		print("RECETTE %s : bilan.ecart_tata_pct=%s titre=%s record=%s" % [nom, str(res["ecart"]), str((db as Dictionary).get("titre", {})), str((db as Dictionary).get("record", {}))])
	print("RECETTE %s : infos_fin=%s patrimoine=%.0f" % [nom, str(f), e.patrimoine(e.joueur)])
	await _photo("fin_" + nom)
	var vp := Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).grow(1.0)
	verifier("%s : panneau de fin dans l'ecran" % nom, vp.encloses(modales.courant.get_global_rect()), str(modales.courant.get_global_rect()))
	scene.queue_free()
	await _images(5)
	Partie.bloquee = false
	return res


func _agir(e: EtatPartie, kind: String, mm: ModaleCarte, actif: bool) -> void:
	await _images(8)
	var c := e.contenu_modale()
	var choix_id := StrategieTest.choix_modale(e, actif)
	if kind == "carte":
		mm.choisir(choix_id)
		await _images(2)
		return
	var mp := mm as ModaleProjet
	mp.choisir(choix_id)
	await _images(8)
	if mp.en_confirmation:
		mp.choisir(choix_id)
	await _images(2)

func _photo(nom: String) -> void:
	var dossier := OS.get_environment("TESTEUR_IMG")
	if dossier == "":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s_%s.png" % [dossier, OS.get_environment("TESTEUR_FMT"), nom])
