extends Node
## Recette R-RUE (testeur), CA-U1, U2, U3, U4, U5, U6, U7, U8, U9 : parties COMPLETES jouées par la vraie scène principale
## (principal.tscn, vraies séquences), tout allumé (cartes, projets, rue). Le « joueur » est StrategieTest ; les clics passent par
## l'API des modales. Contrôles :
##  - chaque mois : bloc LA RUE (hud.bloc_rue.lignes_texte) == classement_rue() (ordre, noms, rang, montants, signe) ; classement
##    cohérent avec les patrimoines (tri décroissant, rang du joueur) ; rang de la languette (téléphone) ;
##  - notifications reçues (notif_recue) : comptées, source rue / media, historique ; persistantes : indication affichée, pas de pause ;
##  - fenêtre du krach : 7 lignes == c["jours"] (arrondies à 5 points), les 3 choix dans l'écran ;
##  - « un an après » : 3 barres jamais triées, valeurs == c["barres"] ET == recalcul indépendant (copie de l'état au krach, même
##    choix, jeu passif jusqu'en 10/1988), barre choisie entourée == choix réel ; Échap sans effet ;
##  - écran de fin : 4 barres == classement_rue(), rang, réplique, « Projets : n sur 2 », Jean-Mi derrière Tata.
## Variables : TESTEUR_CAS = "actif:7" ou "passif:31" (défaut actif:7), TESTEUR_FMT = tel (téléphone simulé), TESTEUR_MODE = x1 (vitesse
## ×1, sans saut ; sinon saut « prochain courrier »). Lancer avec tests.ps1 -Delai 700.

var ok := 0
var ko := 0
var scene: Node
var modales: Modales
var hud: Hud
var seq: Node

var notifs: Array = []
var persist_vues := 0
var persist_saut_vues := 0
var persist_saut_total := 0
var bloque := ""
var ecarts_bloc: Array = []
var mois_bloc := 0
var ecarts_coherence: Array = []
var ecarts_toast: Array = []
var toasts_vus := 0
var fiches: Dictionary = {}
var krach_ecarts: Array = []
var krach_vu := 0
var gaz_ecarts: Array = []
var gaz_vu := 0
var snap: Dictionary = {}
var jours_attendus: Array = []
var barres_reelles: Dictionary = {}
var choix_krach := ""
var cartes := 0
var projets := 0
var t0_ms := 0
var duree_pause_s := 0.0


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		ok += 1
		print("OK  ", nom, ("  [" + detail + "]") if detail != "" else "")
	else:
		ko += 1
		print("KO  ", nom, "  [", detail, "]")


func _ready() -> void:
	if OS.get_environment("TESTEUR_FMT") == "tel":
		Ecran.basculer_telephone()
		await get_tree().create_timer(0.5).timeout
	Partie.chemin_sauvegarde = "user://recette_rue_ui_%d.sav" % OS.get_process_id()
	var cas := OS.get_environment("TESTEUR_CAS")
	if cas == "":
		cas = "actif:7"
	var p := cas.split(":")
	await _partie(p[0] == "actif", int(p[1]))
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	print("=== recette rue ui : %d OK, %d KO ===" % [ok, ko])
	get_tree().quit(1 if ko > 0 else 0)


func _images(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _photo(nom: String) -> void:
	var dossier := OS.get_environment("TESTEUR_IMG")
	if dossier == "":
		return
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png("%s/%s_%s.png" % [dossier, OS.get_environment("TESTEUR_FMT"), nom])


func _sur_notif(n: Dictionary) -> void:
	if bool(n.get("persistant", false)) and not bool(n.get("pendant_saut", false)):
		_verifier_persistante.call_deferred(str(n.get("texte", "")), str(n.get("source", "")), Partie.etat.ab_courant())
	notifs.append({"ab": Partie.etat.ab_courant(), "type": str(n.get("type", "")), "source": str(n.get("source", "")), "id": str(n.get("id", "")),
		"persistant": bool(n.get("persistant", false)), "long": bool(n.get("long", false)), "texte": str(n.get("texte", "")), "t": Time.get_ticks_msec(), "saut": Partie.saut_actif})


func _partie(actif: bool, graine: int) -> void:
	var nom := "%s graine %d (%s, %s)" % ["actif" if actif else "passif", graine, "telephone" if OS.get_environment("TESTEUR_FMT") == "tel" else "PC", "x1" if OS.get_environment("TESTEUR_MODE") == "x1" else "saut"]
	StrategieTest.politique_projets = "moins_cher" if graine == 7 else "plus_cher"
	StrategieTest.politique_echeance = "auto"
	StrategieTest.politique_cartes = "epargner" if graine == 7 else "alterner"
	scene = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await _images(5)
	modales = scene.get("modales")
	hud = scene.get("hud")
	seq = scene.get("sequences")
	# CA-U8 : la config d'une nouvelle partie du joueur (hors capture) est tout allumée
	var cfg_vraie: Dictionary = scene.call("_config")
	verifier("CA-U8 : _config() hors capture : cartes, projets, rue vrais", bool(cfg_vraie.get("cartes", false)) and bool(cfg_vraie.get("projets", false)) and bool(cfg_vraie.get("rue", false)), str([cfg_vraie.get("cartes"), cfg_vraie.get("projets"), cfg_vraie.get("rue")]))
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
	Partie.notif_recue.connect(_sur_notif)
	var e := Partie.etat
	verifier("la rue est allumée dans la partie (rue_active)", e.rue_active(), "")
	var x1 := OS.get_environment("TESTEUR_MODE") == "x1"
	t0_ms = Time.get_ticks_msec()
	var t_vu := Time.get_ticks_msec()
	var sig := ""
	var traite := ""
	var mois_joue := -1
	var mois_ctl := -1
	var n_notifs_vues := 0
	while e.fin == "" and bloque == "" and Time.get_ticks_msec() - t0_ms < 1500000:
		await get_tree().process_frame
		var kind := str(e.modale.get("kind", ""))
		var s := "%d|%s|%s|%s|%s|%s|%s" % [e.ab_courant(), str(e.modale.get("id", "")), str(e.modale.get("etape", "")), str(modales.ouverte()), str(seq.occupe), modales.genre_courant, str(Partie.saut_actif)]
		if kind == "carte":
			s += "|" + modales.etat_carte().phase
		elif kind == "projet":
			s += "|" + modales.etat_projet().phase + str(modales.etat_projet().en_confirmation)
		if s != sig:
			sig = s
			t_vu = Time.get_ticks_msec()
		elif Time.get_ticks_msec() - t_vu > 40000:
			bloque = "aucun changement depuis 40 s : %s" % s
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
				fiches[kind] = int(fiches.get(kind, 0)) + 1
				await _images(8)
				await _agir_carte_projet(e, kind, mm, actif)
			else:
				if traite != cle:
					traite = cle
					fiches[kind] = int(fiches.get(kind, 0)) + 1
					await _images(8)
					if modales.ouverte() and not e.modale.is_empty():
						var ch := StrategieTest.choix_modale(e, actif)
						if kind == "marche" and e.contenu_modale().get("detient", false) and OS.get_environment("TESTEUR_KRACH") != "":
							ch = OS.get_environment("TESTEUR_KRACH")
						if kind == "marche" and e.contenu_modale().has("jours"):
							await _controler_krach(e, ch)
						elif kind == "gazette":
							await _controler_gazette(e)
						if modales.ouverte() and not e.modale.is_empty():
							modales.fermer(ch)
			continue
		if modales.ouverte() and modales.genre_courant == "banque":
			await _images(20)
			if modales.ouverte() and modales.genre_courant == "banque":
				fiches["banque_ouverte"] = int(fiches.get("banque_ouverte", 0)) + 1
				if actif and modales.banque != null and is_instance_valid(modales.banque):
					StrategieTest._placer(e, str(modales.banque.produit))
				modales.fermer("fermer")
			continue
		if seq.occupe or modales.ouverte() or Partie.saut_actif or Partie.bloquee:
			continue
		var ab := e.ab_courant()
		if ab != mois_ctl:
			mois_ctl = ab
			_controler_bloc(e)
			if x1:
				await _controler_toasts(n_notifs_vues)
				n_notifs_vues = notifs.size()
			else:
				_controler_persistantes()
		if x1:
			if ab != mois_joue:
				mois_joue = ab
				StrategieTest.jouer_mois(e, actif)
				Partie.changer_vitesse(1)
			continue
		if e.m >= e.m_fin:
			StrategieTest.jouer_mois(e, actif)
			Partie.changer_vitesse(3)
			continue
		StrategieTest.jouer_mois(e, actif)
		Partie.sauter_jusqu_au_prochain_arret()
	var duree := (Time.get_ticks_msec() - t0_ms) / 1000.0
	# écran de fin
	var t_f := 0.0
	while modales.genre_courant != "fin" and t_f < 20.0 and bloque == "":
		await get_tree().process_frame
		t_f += get_process_delta_time()
	await get_tree().create_timer(3.0).timeout
	await _controler_fin(e)
	await _photo("fin_vraie")
	var nr := 0
	var nk := 0
	var np := 0
	var nrang := 0
	for n: Dictionary in notifs:
		if n["source"] == "rue":
			nr += 1
			if n["type"] == "rang":
				nrang += 1
		if n["type"] == "kiosque":
			nk += 1
		if n["persistant"]:
			np += 1
	var cl := e.classement_rue()
	print("RECETTE rue_ui %s : fin=%s %s patrimoine=%.2f F frais=%.2f F interruptions=%s cartes=%d projets_choix=%d notifs_rue=%d (rang=%d, persistantes=%d) kiosque=%d dividendes=%.2f rang_final=%d duree=%.0f s classement=%s" % [
		nom, e.fin, Dates.texte(e.ab_courant()), e.patrimoine(e.joueur) * Format.TAUX_EURO, e.frais_payes(), str(fiches), cartes, projets, nr, nrang, np, nk, e.dividendes_recus() * Format.TAUX_EURO, e.rang_rue(), duree,
		str(cl.map(func(l: Dictionary) -> String: return "%s %.0f" % [l["id"], l["patrimoine"]]))])
	verifier("%s : partie complète par la vraie interface tout allumé, aucun blocage (%s)" % [nom, bloque], bloque == "" and e.fin == "fin" and Dates.texte(e.ab_courant()).contains("1988"), "fin=%s %s" % [e.fin, Dates.texte(e.ab_courant())])
	verifier("%s : bloc LA RUE == classement_rue() chaque mois (%d mois)" % [nom, mois_bloc], ecarts_bloc.is_empty() and mois_bloc >= 20, str(ecarts_bloc.slice(0, 4)))
	verifier("%s : classement cohérent avec les patrimoines (tri, rang, Jean-Mi, Tata)" % nom, ecarts_coherence.is_empty(), str(ecarts_coherence.slice(0, 4)))
	verifier("%s : krach : fenêtre avec 7 jours == c[jours], choix visibles (%d vue)" % [nom, krach_vu], krach_vu == 1 and krach_ecarts.is_empty(), str(krach_ecarts))
	verifier("%s : « un an après » ouverte en 10/1988, 3 barres == c[barres] == recalcul indépendant (%d vue)" % [nom, gaz_vu], gaz_vu == 1 and gaz_ecarts.is_empty(), str(gaz_ecarts))
	verifier("%s : notifications de la rue reçues (voisin, rang, kiosque) : %d rue, %d kiosque" % [nom, nr, nk], nr >= 8 and nk >= 1, "")
	verifier("%s : toasts lisibles == n[texte] (x1) ou persistantes affichées : %s" % [nom, str(ecarts_toast.slice(0, 4))], ecarts_toast.is_empty(), "toasts vus=%d persistantes vues=%d / %d ; en saut %d / %d" % [toasts_vus, persist_vues, np, persist_saut_vues, persist_saut_total])
	verifier("%s : historique : toutes les notifications de la rue y sont (source rue / media)" % nom, _controler_historique(e), "")
	scene.queue_free()
	await _images(5)


## Bloc LA RUE du HUD == classement_rue() (CA-U3) et cohérence du classement (CA-U2).
func _controler_bloc(e: EtatPartie) -> void:
	hud.maj(e, false)
	var cl := e.classement_rue()
	var l := hud.bloc_rue.lignes_texte
	var date := Dates.texte_court(e.ab_courant())
	if l.size() != 4 or cl.size() != 4:
		ecarts_bloc.append("%s : %d lignes (classement %d)" % [date, l.size(), cl.size()])
		return
	for i in 4:
		var x: Dictionary = l[i]
		var c: Dictionary = cl[i]
		var montant := Format.entier(float(c["patrimoine"]) / Format.TAUX_EURO, e.ab_courant())
		if str(x["nom"]).to_lower() != str(c["nom"]).to_lower() or int(x["rang"]) != int(c["rang"]) or str(x["montant"]) != montant or bool(x["vous"]) != bool(c["vous"]):
			ecarts_bloc.append("%s : ligne %d « %s / %s / %s » au lieu de « %s / %d / %s »" % [date, i, str(x["nom"]), str(x["rang"]), str(x["montant"]), str(c["nom"]), int(c["rang"]), montant])
		if float(c["patrimoine"]) < 0.0 and not (str(x["montant"]).begins_with(Format.MOINS) and bool(x["negatif"])):
			ecarts_bloc.append("%s : montant négatif sans signe : %s" % [date, str(x["montant"])])
	mois_bloc += 1
	# cohérence : tri décroissant, vous = patrimoine + vie en attente, Tata = patrimoine de temoins[livret]
	for i in 3:
		if float(cl[i]["patrimoine"]) < float(cl[i + 1]["patrimoine"]) - 0.5:   # (égalité au franc près : le joueur devant)
			ecarts_coherence.append("%s : classement non trié (%s %.0f < %s %.0f)" % [date, cl[i]["id"], cl[i]["patrimoine"], cl[i + 1]["id"], cl[i + 1]["patrimoine"]])
	var par_id := {}
	for c: Dictionary in cl:
		par_id[c["id"]] = c
	var vous_attendu := (e.patrimoine(e.joueur) + e.vie_en_attente()) * Format.TAUX_EURO
	if absf(float(par_id["vous"]["patrimoine"]) - vous_attendu) > 0.01:
		ecarts_coherence.append("%s : vous %.2f au lieu de %.2f" % [date, par_id["vous"]["patrimoine"], vous_attendu])
	if absf(float(par_id["livret"]["patrimoine"]) - e.patrimoine(e.temoins["livret"]) * Format.TAUX_EURO) > 0.01:
		ecarts_coherence.append("%s : Tata incohérente" % date)
	var rang_vous := 0
	for c: Dictionary in cl:
		if c["vous"]:
			rang_vous = int(c["rang"])
	if rang_vous != e.rang_rue():
		ecarts_coherence.append("%s : rang_rue() %d != rang du classement %d" % [date, e.rang_rue(), rang_vous])
	if hud.compact:
		var t_rang := (hud._languette_rang.get_child(1) as Label).text
		if not hud._languette_rang.visible or t_rang != BlocRue.rang_texte(rang_vous):
			ecarts_coherence.append("%s : languette « %s » au lieu de « %s »" % [date, t_rang, BlocRue.rang_texte(rang_vous)])
	if e.ab_courant() >= Dates.lire("1988-12") and float(par_id["jeanmi"]["patrimoine"]) >= float(par_id["livret"]["patrimoine"]):
		ecarts_coherence.append("%s : Jean-Mi (%.0f) pas derrière Tata (%.0f)" % [date, par_id["jeanmi"]["patrimoine"], par_id["livret"]["patrimoine"]])


## Mode x1 : chaque notification de la rue ou du kiosque reçue a un toast dont le texte == n[texte] (court).
func _controler_toasts(depuis: int) -> void:
	for i in range(depuis, notifs.size()):
		var n: Dictionary = notifs[i]
		if not (n["source"] == "rue" or n["type"] == "kiosque"):
			continue
		var vu := false
		for t in 6:
			for lab in hud.notifs.find_children("TexteNotif", "Label", true, false):
				if (lab as Label).text == n["texte"]:
					vu = true
			if vu:
				break
			await get_tree().create_timer(0.3).timeout
		if vu:
			toasts_vus += 1
		elif Time.get_ticks_msec() - int(n["t"]) < 8000:
			ecarts_toast.append("%s : toast absent pour « %s »" % [Dates.texte_court(int(n["ab"])), n["texte"]])
		if n["persistant"]:
			if hud.notifs.find_child("IndicationPersistante", true, false) != null:
				persist_vues += 1
			else:
				ecarts_toast.append("%s : persistante sans indication" % Dates.texte_court(int(n["ab"])))


func _controler_persistantes() -> void:
	for n: Dictionary in notifs:
		if n["persistant"] and not n.has("_vue"):
			n["_vue"] = true
			if hud.notifs.find_child("IndicationPersistante", true, false) != null:
				persist_vues += 1


func _controler_historique(e: EtatPartie) -> bool:
	var dans_hist := 0
	var attendu := 0
	for n: Dictionary in notifs:
		if n["source"] == "rue":
			attendu += 1
	for h in e.historique:
		if str(h.get("source", "")) == "rue":
			dans_hist += 1
	print("RECETTE historique source rue : %d dans e.hist, %d notifications recues" % [dans_hist, attendu])
	return dans_hist >= attendu


## Fenêtre du krach : 7 lignes == c["jours"] (arrondies à 5), choix visibles (CA-U5).
func _controler_krach(e: EtatPartie, ch: String) -> void:
	var c := e.contenu_modale()
	var jours: Array = c["jours"]
	krach_vu += 1
	await _images(30)
	# copie de l'état AVANT le choix (recalcul indépendant des barres)
	var chemin := "user://recette_rue_ui_snap_%d.sav" % OS.get_process_id()
	Sauvegarde.ecrire(e, {}, chemin)
	snap = Sauvegarde.lire(chemin)
	Sauvegarde.effacer(chemin)
	choix_krach = ch
	if modales.genre_courant != "journal" or modales._journal == null:
		krach_ecarts.append("fenêtre du krach non ouverte (genre %s)" % modales.genre_courant)
		return
	var mj: ModaleJournal = modales._journal
	if mj.lignes_jours.size() != 7 or jours.size() != 7:
		krach_ecarts.append("%d lignes affichées, %d jours" % [mj.lignes_jours.size(), jours.size()])
	for i in mini(mj.lignes_jours.size(), jours.size()):
		var texte := "|".join(PackedStringArray(mj.lignes_jours[i]))
		var nombres: Array = [int(RegEx.create_from_string("[^0-9]").sub(String(mj.lignes_jours[i][1]), "", true))]
		var val := float(jours[i]["indice"])
		var arrondi := int(roundf(val / 5.0) * 5.0)
		if nombres.is_empty() or absi(int(nombres[0]) - arrondi) > 0:
			krach_ecarts.append("ligne %d « %s » : indice %.2f, arrondi attendu %d" % [i, texte, val, arrondi])
		print("RECETTE krach ligne ", i, " : ", texte, " | indice=", snappedf(val, 0.01), " variation=", snappedf(float(jours[i].get("variation", 0.0)), 0.01), " certitude=", jours[i].get("certitude", ""))
	var vue := scene.get_viewport().get_visible_rect()
	var choix := modales.courant.find_child("Choix", true, false) as Control
	var visibles := choix != null and vue.grow(1.0).encloses(choix.get_global_rect())
	if choix != null:
		for b in choix.find_children("*", "Button", true, false):
			var br := (b as Button).get_global_rect()
			if (b as Button).visible and not vue.grow(1.0).encloses(br):
				visibles = false
	if not visibles:
		print("RECETTE krach : choix hors du viewport de test (fenetre sans rapport avec un vrai format : a lire sur les captures) ", str(vue))
	await _photo("krach_vrai")


## « Un an après » : 3 barres == c["barres"] et == recalcul indépendant, entourée == choix réel, Échap sans effet (CA-U6).
func _controler_gazette(e: EtatPartie) -> void:
	var c := e.contenu_modale()
	gaz_vu += 1
	await _images(30)
	var ab := e.ab_courant()
	if ab != Dates.lire("1988-10"):
		gaz_ecarts.append("ouverte en %s au lieu de 10/1988" % Dates.texte_court(ab))
	if modales.genre_courant != "gazette":
		gaz_ecarts.append("genre %s" % modales.genre_courant)
		return
	var mg := modales.etat_gazette()
	var ordre: Array = mg.barres_vues.map(func(b: Dictionary) -> String: return str(b["id"]))
	if ordre != ["vendu", "rien", "renforce"]:
		gaz_ecarts.append("ordre %s" % str(ordre))
	var barres: Array = c["barres"]
	for i in mini(3, mg.barres_vues.size()):
		if str(mg.barres_vues[i]["valeur_txt"]) != Format.entier(float(barres[i]["valeur"]), ab):
			gaz_ecarts.append("valeur affichée %s != %s" % [str(mg.barres_vues[i]["valeur_txt"]), Format.entier(float(barres[i]["valeur"]), ab)])
	var choisie := ""
	for b: Dictionary in mg.barres_vues:
		if bool(b["choisi"]):
			choisie = str(b["id"])
	var attendu_choisie: String = {"vendre": "vendu", "rien": "rien", "renforcer": "renforce"}.get(choix_krach, "")
	if choisie != attendu_choisie:
		gaz_ecarts.append("barre entourée « %s » mais choix du krach « %s » (attendu « %s »)" % [choisie, choix_krach, attendu_choisie])
	# Échap et clic extérieur sans effet
	var recu := {}
	var coup := func(g: String, id: String) -> void: recu["id"] = id
	modales.choix_fait.connect(coup)
	var ev := InputEventKey.new()
	ev.keycode = KEY_ESCAPE
	ev.pressed = true
	Input.parse_input_event(ev)
	await _images(10)
	if modales.genre_courant != "gazette" or not recu.is_empty():
		gaz_ecarts.append("Échap a fermé la fiche")
	modales.choix_fait.disconnect(coup)
	# recalcul indépendant : copie de l'état au krach, même choix, jeu passif jusqu'en 10/1988
	var reel := {}
	for b: Dictionary in barres:
		reel[b["id"]] = float(b["valeur"])
	var ind := _recalcul_independant()
	print("RECETTE gazette choix_krach=%s barres_ui=%s recalcul=%s base=%s mention=« %s »" % [choix_krach, str(reel), str(ind), str(c.get("base")), str(c.get("mention", ""))])
	for id in ["vendu", "rien", "renforce"]:
		if not ind.has(id) or absf(float(reel[id]) - float(ind[id])) * Format.TAUX_EURO > 1.0:
			gaz_ecarts.append("barre %s : %.2f F, recalcul %s F" % [id, float(reel[id]) * Format.TAUX_EURO, str(float(ind.get(id, -1.0)) * Format.TAUX_EURO)])
	await _photo("gazette_vraie")


## Barres obtenues en rejouant, sur une copie de l'état au krach, le même choix puis un jeu passif jusqu'à la modale « un an après ».
func _recalcul_independant() -> Dictionary:
	if snap.is_empty():
		return {}
	var c2 := Sauvegarde.charger(snap)
	if c2 == null:
		return {}
	var inst := c2.instantane_krach()
	var div0 := c2.dividendes_recus()
	var val_choix := {}
	var resu := {"inst": inst}
	var cc0 := c2.joueur.cc
	var avec_lignes: bool = (inst.get("lignes", []) as Array).size() > 0 and not bool(inst.get("exemple", true))
	var choix := choix_krach if avec_lignes else "ecart"
	c2.resoudre_modale(choix)
	if choix == "vendre":
		c2.deposer_livret(c2.joueur, c2.joueur.cc - cc0)
	elif choix == "renforcer":
		var tot := Krach.base(inst)
		for l in inst["lignes"]:
			c2.acheter(c2.joueur, str(l["id"]), float(inst["montant_renforcer"]) * float(l["qte"]) * float(l["cours"]) / tot)
	var garde := 0
	while c2.fin == "" and garde < 100:
		garde += 1
		while not c2.modale.is_empty():
			if str(c2.modale.get("kind", "")) == "gazette":
				return c2.contenu_modale()["barres"].reduce(func(a: Dictionary, b: Dictionary) -> Dictionary:
					a[b["id"]] = float(b["valeur"])
					return a, {})
			c2.resolution_auto()
		StrategieTest.jouer_mois(c2, false)
		c2.avancer()
	return {}


func _controler_fin(e: EtatPartie) -> void:
	if modales.genre_courant != "fin":
		verifier("écran de fin ouvert", false, "genre %s" % modales.genre_courant)
		return
	var mf := modales.etat_fin()
	var cl := e.classement_rue()
	var br := mf.barres_fin
	var lignes: Array = br.lignes if br != null else []
	var attendu: Array = cl.map(func(l: Dictionary) -> String: return "%d %s|%s" % [int(l["rang"]), str(l["nom"]).to_upper(), Format.entier(float(l["patrimoine"]) / Format.TAUX_EURO, e.ab_courant())])
	var lus: Array = lignes.map(func(l: Array) -> String: return "%s|%s" % [str(l[0]), Format.entier(float(l[1]), e.ab_courant())])
	var tr := modales.courant.find_child("TexteRang", true, false) as Label
	var rep := modales.courant.find_child("TexteReplique", true, false) as Label
	var pr := modales.courant.find_child("ProjetsRealises", true, false) as Label
	var rang := e.rang_rue()
	print("RECETTE fin lignes=", str(lus), " rang=", tr.text if tr != null else "-", " replique=", rep.text if rep != null else "-", " projets=", pr.text if pr != null else "-")
	verifier("écran de fin : 4 barres == classement_rue() (ordre, noms, montants)", lus == attendu, "%s / %s" % [str(lus), str(attendu)])
	verifier("écran de fin : rang « %s » == rang_rue() %d" % [tr.text if tr != null else "?", rang], tr != null and tr.text.begins_with(BlocRue.rang_texte(rang)) and tr.text.ends_with("SUR 4"), "")
	var bilan := Bilan.calculer(e)
	var rr: Dictionary = bilan.get("replique_rue", {})
	verifier("écran de fin : réplique affichée == replique_rue du bilan", rep != null and not rr.is_empty() and rep.text == "%s : « %s »" % [str(rr["nom"]), str(rr["texte"])], "%s / %s" % [rep.text if rep != null else "-", str(rr)])
	var realises := 0
	for pp: Dictionary in e.projets_passes():
		if str(pp.get("statut", "")).begins_with("realise"):
			realises += 1
	verifier("écran de fin : « Projets : n sur 2 » == projets_passes() (%d)" % realises, pr != null and pr.text.begins_with("Projets : %d sur 2" % realises), pr.text if pr != null else "-")


## Carte du foyer ou projet : le joueur choisit comme StrategieTest.
func _agir_carte_projet(e: EtatPartie, kind: String, mm: ModaleCarte, actif: bool) -> void:
	var c := e.contenu_modale()
	var choix_id := StrategieTest.choix_modale(e, actif)
	if kind == "carte":
		cartes += 1
		mm.choisir(choix_id)
		await _images(2)
		return
	var mp := mm as ModaleProjet
	var etape := str(c.get("etape", ""))
	if etape == "choix":
		projets += 1
		mp.choisir(choix_id)
		await _images(3)
		return
	if choix_id == "realiser_en_vendant":
		mp.choisir("realiser_en_vendant")
		await _images(8)
		if mp.en_confirmation:
			mp.choisir_rang(0)
			await _images(3)
		return
	mp.choisir(choix_id)
	await _images(2)


## Une notification persistante est affichée avec son indication (et ne met pas le jeu en pause) 0,8 s après sa réception.
func _verifier_persistante(texte: String, source: String, ab: int) -> void:
	await get_tree().create_timer(0.8).timeout
	var vu := hud != null and is_instance_valid(hud) and hud.notifs.find_child("IndicationPersistante", true, false) != null
	if vu:
		persist_vues += 1
	else:
		ecarts_toast.append("%s : persistante « %s » non affichée après 0,8 s" % [Dates.texte_court(ab), texte])


## R-RUE passage 2 (M5) : pendant un saut, une persistante reste affichée (forme compacte) bien après les 3,4 s d une ordinaire,
## tant que moins de 3 notifications plus récentes l ont poussée vers l historique.
func _verifier_persistante_saut(texte: String, ab: int, rang: int) -> void:
	await get_tree().create_timer(5.0).timeout
	if hud == null or not is_instance_valid(hud) or notifs.size() - rang >= 3:
		return
	var n := 0
	for p in hud._liste_notifs:
		if is_instance_valid(p) and p.name == "NotifCompacte":
			n += 1
	persist_saut_total += 1
	if n >= 1:
		persist_saut_vues += 1
	else:
		ecarts_toast.append("%s : persistante « %s » disparue en saut apres 5 s" % [Dates.texte_court(ab), texte])
