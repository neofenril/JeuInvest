extends Node
## Recette finale du lot 10 (testeur) : UNE partie reelle complete par la vraie scene principale (saut « prochain courrier »),
## sauvegarde et records ISOLES. Sans TESTEUR_FINALE=1 le test se termine tout de suite (il n'est pas une verification du jeu en serie).
## Variables : TESTEUR_CH = 1984 | 1989 (chapitre de depart), TESTEUR_GRAINE, TESTEUR_ACTIF = 1 | 0, TESTEUR_REPRISE = 1 (sauvegarde puis
## reprise a la carte de passage 1988 -> 1989), TESTEUR_RAZ = 1 (efface le records isole), TESTEUR_FMT = tel, TESTEUR_IMG = dossier de photos.

var ok := 0
var ko := 0
var scene: Node
var modales: Modales
var seq: Node
var vus: Dictionary = {}
var motifs: Array[RegEx] = []
var chemin_records := "user://recette_finale_records.sav"
var notifs: Array = []
var ecran_vus: Dictionary = {}
var residus_ecran := 0
var audit_fait := false
var t_scan := 0


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
	if OS.get_environment("TESTEUR_FINALE") != "1":
		get_tree().quit(0)
		return
	for p in ["\\{[A-Za-z_0-9]+\\}", "%[sdf]", "\\bnull\\b", "\\bNaN\\b", "\\binf\\b", "<[a-z_]+>", "\\$\\{", "TODO", "XXX", "\\[\\[", "\\bnan\\b", "\\bundefined\\b", "\\bFLAG\\b", "\\bTBD\\b", "§"]:
		var re := RegEx.new()
		re.compile(p)
		motifs.append(re)
	if OS.get_environment("TESTEUR_FMT") == "tel":
		Ecran.basculer_telephone()
		await get_tree().create_timer(0.5).timeout
	var pid := OS.get_process_id()
	Partie.chemin_sauvegarde = "user://recette_finale_%d.sav" % pid
	Partie.chemin_records = chemin_records
	if OS.get_environment("TESTEUR_RAZ") == "1":
		Records.effacer(chemin_records)
	var ch := OS.get_environment("TESTEUR_CH") if OS.get_environment("TESTEUR_CH") != "" else "1984"
	var graine := int(OS.get_environment("TESTEUR_GRAINE")) if OS.get_environment("TESTEUR_GRAINE") != "" else 7
	var actif := OS.get_environment("TESTEUR_ACTIF") != "0"
	var reprise := OS.get_environment("TESTEUR_REPRISE") == "1"
	var r := await _partie(ch, graine, actif, reprise)
	Partie.notif_recue.disconnect(_noter_notif)
	var dossiers := Records.lire(chemin_records)
	print("RECETTE records apres : ", str(dossiers["chapitres"]))
	# scan des notifications et de l'historique
	var n_res := 0
	for n in notifs:
		n_res += _scanner(str(n), "notif")
	for h in Partie.etat.historique:
		n_res += _scanner(str(h), "historique")
	print("RECETTE residus dans les donnees brutes (informatif) : %d" % n_res)
	verifier("aucun jeton / gabarit residuel A L'ECRAN ni dans les modales (%d textes vus)" % ecran_vus.size(), residus_ecran == 0 and int(r["residus"]) == 0, "%d + %d" % [residus_ecran, int(r["residus"])])
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	print("=== recette finale %s graine %d actif=%s reprise=%s : %d OK, %d KO ===" % [ch, graine, str(actif), str(reprise), ok, ko])
	get_tree().quit(1 if ko > 0 else 0)


func _scan_ecran() -> void:
	for n: Node in get_tree().root.find_children("*", "Control", true, false):
		var txt := ""
		if n is Label:
			txt = (n as Label).text
		elif n is RichTextLabel:
			txt = (n as RichTextLabel).text
		elif n is Button:
			txt = (n as Button).text
		if txt == "" or ecran_vus.has(txt) or not (n as Control).is_visible_in_tree():
			continue
		ecran_vus[txt] = true
		var nr := _scanner(txt, "ECRAN")
		residus_ecran += nr
		if nr > 0:
			print("RESIDU chemin : ", n.get_path(), " ancetres : ", n.get_parent().name, " / ", n.get_parent().get_parent().name, " ab=", Dates.texte(Partie.etat.ab_courant()))
			_photo_residu.call_deferred("residu_%d" % residus_ecran)


func _photo_residu(nom: String) -> void:
	await _photo(nom)


func _audit_historique() -> void:
	audit_fait = true
	var e := Partie.etat
	var nb := e.historique.size()
	scene.call("ouvrir_historique", "")
	await get_tree().create_timer(1.2).timeout
	_scan_ecran()
	await _photo("historique")
	if modales.ouverte():
		modales.fermer("fermer")
	await _images(10)
	var relus := 0
	for i in nb:
		if modales.relire_historique(e, i):
			relus += 1
			await _images(6)
			_scan_ecran()
			residus_ecran += _scanner_modale("relecture%d" % i)
			if modales.ouverte():
				modales.fermer("fermer")
			await _images(4)
	print("RECETTE audit historique : %d entrees, %d relues" % [nb, relus])
	verifier("audit historique : toutes les entrees relisibles", relus == nb, "%d / %d" % [relus, nb])
	await _images(10)

func _noter_notif(n: Dictionary) -> void:
	notifs.append(n)


func _scanner(texte: String, ou: String) -> int:
	var c := 0
	for re in motifs:
		var m := re.search(texte)
		if m != null:
			c += 1
			print("RESIDU %s : « %s » dans « %s »" % [ou, m.get_string(), texte.substr(maxi(0, m.get_start() - 40), 120)])
	return c


func _textes_modale() -> Array:
	var out: Array = []
	if modales.courant == null:
		return out
	for l: Node in modales.courant.find_children("*", "Label", true, false):
		out.append((l as Label).text)
	for l: Node in modales.courant.find_children("*", "RichTextLabel", true, false):
		out.append((l as RichTextLabel).text)
	for l: Node in modales.courant.find_children("*", "Button", true, false):
		out.append((l as Button).text)
	return out


func _scanner_modale(cle: String) -> int:
	var n := 0
	for t in _textes_modale():
		n += _scanner(str(t), "modale " + cle)
	return n


func _partie(ch: String, graine: int, actif: bool, reprise: bool) -> Dictionary:
	StrategieTest.politique_projets = "plus_cher"
	StrategieTest.politique_echeance = "vendre"
	StrategieTest.politique_cartes = "epargner" if graine == 7 else "alterner"
	scene = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await _images(5)
	modales = scene.get("modales")
	seq = scene.get("sequences")
	var cfg := Donnees.config_chapitre(ch, graine)
	cfg["cartes"] = true
	cfg["projets"] = true
	cfg["rue"] = true
	scene.set("_ignorer_modales", true)
	Partie.nouvelle_partie(cfg)
	scene.set("_ignorer_modales", false)
	scene.call("_apres_mise_en_place")
	Partie.etat.resolution_auto()
	Partie.notif_recue.connect(_noter_notif)
	scene.call("demarrer_direct", 0)
	var e := Partie.etat
	print("RECETTE depart : chapitre=%s fin=%s prenom=%s patrimoine=%.2f ab=%s" % [e.chapitre_depart, str(cfg.get("fin", "")), str(e.get("prenom")), e.patrimoine(e.joueur), Dates.texte(e.ab_courant())])
	var res := {"residus": 0}
	var t0 := Time.get_ticks_msec()
	var sig := ""
	var t_vu := Time.get_ticks_msec()
	var traite := ""
	var repris := false
	var interruptions := 0
	while Time.get_ticks_msec() - t0 < 1500000:
		await get_tree().process_frame
		e = Partie.etat
		if Time.get_ticks_msec() - t_scan > 250:
			t_scan = Time.get_ticks_msec()
			_scan_ecran()
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
			verifier("bloque : %s" % s, false)
			break
		if modales.ouverte() and modales.genre_courant == "intro":
			await get_tree().create_timer(1.2).timeout
			res["residus"] += _scanner_modale("intro")
			await _photo("intro_" + ch)
			modales.fermer("commencer")
			await _images(10)
			continue
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
				if traite != cle:
					interruptions += 1
					await _images(15)
					res["residus"] += _scanner_modale(kind + str(e.modale.get("id", "")))
					print("RECETTE modale %s %s %s" % [Dates.texte(e.ab_courant()), kind, str(e.modale.get("id", ""))])
					print("RECETTE textes %s %s : %s" % [Dates.texte(e.ab_courant()), str(e.modale.get("id", "")), " || ".join(PackedStringArray(_textes_modale().map(func(x): return str(x))))])
					if str(e.modale.get("id", "")).begins_with("carriere") or str(e.modale.get("id", "")).contains("carri"):
						await _photo("carte_" + str(e.modale.get("id", "")))
				traite = cle
				await _agir(e, kind, mm, actif)
			elif traite != cle:
				traite = cle
				interruptions += 1
				await _images(20)
				print("RECETTE modale %s %s %s" % [Dates.texte(e.ab_courant()), kind, str(e.modale.get("id", ""))])
				res["residus"] += _scanner_modale(kind + str(e.modale.get("id", "")))
				if kind in ["gazette", "passage", "vie", "marche"]:
					print("RECETTE textes %s %s : %s" % [Dates.texte(e.ab_courant()), str(e.modale.get("id", "")), " || ".join(PackedStringArray(_textes_modale().map(func(x): return str(x))))])
				if kind == "passage":
					await get_tree().create_timer(1.5).timeout
					await _photo("passage")
					if reprise and not repris:
						repris = true
						await _reprise_au_passage()
						traite = ""
						e = Partie.etat
						continue
				if kind in ["gazette", "marche"] and not vus.has(kind):
					vus[kind] = true
					await _photo(kind + "_" + ch)
				if modales.ouverte() and not e.modale.is_empty():
					modales.fermer(StrategieTest.choix_modale(e, actif))
			continue
		if modales.ouverte() and modales.genre_courant == "banque":
			await _images(20)
			res["residus"] += _scanner_modale("banque")
			if modales.ouverte() and modales.genre_courant == "banque":
				modales.fermer("fermer")
			continue
		if seq.occupe or modales.ouverte() or Partie.saut_actif or Partie.bloquee:
			continue
		if not audit_fait and e.m >= e.m_fin - 3:
			await _audit_historique()
			continue
		if e.m >= e.m_fin:
			StrategieTest.jouer_mois(e, actif)
			Partie.changer_vitesse(3)
			continue
		StrategieTest.jouer_mois(e, actif)
		Partie.sauter_jusqu_au_prochain_arret()
	e = Partie.etat
	verifier("partie finie, ecran de fin ouvert (fin=%s %s)" % [e.fin, Dates.texte(e.ab_courant())], e.fin == "fin" and modales.genre_courant == "fin", "")
	await get_tree().create_timer(4.0).timeout
	var mf: ModaleReleveFin = modales.etat_fin()
	var f: Dictionary = mf.infos_fin
	res["residus"] += _scanner_modale("fin")
	print("RECETTE infos_fin=%s" % str(f))
	print("RECETTE patrimoine moteur=%.2f interruptions=%d" % [e.patrimoine(e.joueur), interruptions])
	var db: Dictionary = {}
	var v = modales.get("dernier_bilan")
	if v is Dictionary:
		db = v
	print("RECETTE bilan=%s" % str(db))
	if not db.is_empty():
		var vous := float(db.get("nominal", {}).get("vous", -1.0))
		var tata := float(db.get("nominal", {}).get("tata", db.get("nominal", {}).get("livret", -1.0)))
		print("RECETTE nominal=%s ecart_tata_pct=%s annee_fin=%s" % [str(db.get("nominal", {})), str(db.get("ecart_tata_pct", "?")), str(db.get("annee_fin", "?"))])
		verifier("bilan : nominal.vous == patrimoine moteur", absf(vous - e.patrimoine(e.joueur)) < 1.0, "%.2f | %.2f" % [vous, e.patrimoine(e.joueur)])
		if tata > 0.0:
			var pct := (vous / tata - 1.0) * 100.0
			verifier("bilan : ecart Tata recalcule == affiche (%.3f)" % pct, absf(pct - float(db.get("ecart_tata_pct", 1e9))) < 0.05, str(db.get("ecart_tata_pct", "?")))
	await _photo("fin_" + ch)
	var vp := Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).grow(1.0)
	verifier("panneau de fin dans l'ecran", vp.encloses(modales.courant.get_global_rect()), str(modales.courant.get_global_rect()))
	var tous: Array = []
	for t in _textes_modale():
		tous.append(str(t))
	print("RECETTE textes fin : %s" % " || ".join(PackedStringArray(tous)))
	# fermer vers le titre pour que les records soient ecrits (deja ecrits a la fin) et verifier le fichier
	var rec := Records.lire(chemin_records)
	verifier("records v2 : fichier lisible, chapitre %s present" % ch, (rec["chapitres"] as Dictionary).has(ch), str(rec["chapitres"].keys()))
	res["interruptions"] = interruptions
	scene.queue_free()
	await _images(5)
	Partie.bloquee = false
	return res


func _reprise_au_passage() -> void:
	var e := Partie.etat
	var avant := {"ab": e.ab_courant(), "pat": snappedf(e.patrimoine(e.joueur), 0.01), "cc": snappedf(e.joueur.cc, 0.01), "livret": snappedf(e.joueur.livret, 0.01),
		"modale": str(e.modale.get("kind", "")), "histo": e.historique.size(), "non_lues": e.non_lues()}
	var ok_s := Partie.sauvegarder()
	verifier("sauvegarde au passage 1988->1989 ecrite", ok_s and Sauvegarde.existe(Partie.chemin_sauvegarde), "")
	var d := Sauvegarde.lire(Partie.chemin_sauvegarde)
	verifier("sauvegarde relue (non vide)", not d.is_empty(), "")
	scene.queue_free()
	await _images(8)
	Partie.bloquee = false
	Partie.vitesse = 0
	scene = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await _images(5)
	modales = scene.get("modales")
	seq = scene.get("sequences")
	var rep: bool = scene.call("reprendre", d)
	verifier("reprise du passage acceptee", rep, "")
	scene.call("demarrer_direct", 0)
	await get_tree().create_timer(2.0).timeout
	e = Partie.etat
	var apres := {"ab": e.ab_courant(), "pat": snappedf(e.patrimoine(e.joueur), 0.01), "cc": snappedf(e.joueur.cc, 0.01), "livret": snappedf(e.joueur.livret, 0.01),
		"modale": str(e.modale.get("kind", "")), "histo": e.historique.size(), "non_lues": e.non_lues()}
	print("RECETTE reprise avant=%s apres=%s" % [str(avant), str(apres)])
	verifier("reprise : meme date, patrimoine, compte, livret, modale (passage), historique", avant == apres, "%s | %s" % [str(avant), str(apres)])
	verifier("reprise : la carte de passage est rouverte", modales.genre_courant == "passage" and modales.ouverte(), modales.genre_courant)
	await _photo("passage_reprise")


func _agir(e: EtatPartie, kind: String, mm: ModaleCarte, actif: bool) -> void:
	await _images(8)
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
