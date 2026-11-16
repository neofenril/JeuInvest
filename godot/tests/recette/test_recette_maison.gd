extends Node
## Recette R-MAISON (testeur), CA-M1, M3, M5, M6, M7, M8, M10 : parties COMPLETES jouées par la vraie scène principale
## (principal.tscn, vraies séquences : porte puis carte, saut « prochain courrier »), cartes et projets allumés.
## Le « joueur » : stratégie de test pour les choix (comme un joueur qui clique), clics par l'API des modales (choisir,
## choisir_rang, echap). Contrôles à chaque carte / projet : BANQUE fermée (même phrase que le moteur), ordre refusé,
## rouverte après ; à chaque mois : étiquette MA MAISON == projet_en_cours() ; guichet == ligne_projet_guichet() ;
## Par défaut 2 parties (lancer avec tests.ps1 -Delai 700) ; TESTEUR_TOUT=1 : 4 parties. jour J : cas A / B / C vus, ventes faites == plan_vente_projet(), compte jamais négatif ; blocage = échec.

var ok := 0
var ko := 0
var scene: Node
var modales: Modales
var hud: Hud
var seq: Node

# bilan d'une partie
var cartes := 0
var projets_choix := 0
var jours_j := {"A": 0, "B": 0, "C": 0}
var ventes_conformes := 0
var ventes_ecarts: Array = []
var banque_ecarts: Array = []
var etiquette_ecarts: Array = []
var etiquette_vues := 0
var guichet_ecarts: Array = []
var guichets := 0
var foyers := 0
var foyer_ecarts: Array = []
var photos: Dictionary = {}
var cc_negatif: Array = []
var choix_projet_ecarts: Array = []
var echap_ecarts: Array = []
var bloque := ""
var fiches: Dictionary = {}


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
	Partie.chemin_sauvegarde = "user://recette_maison_%d.sav" % OS.get_process_id()
	Partie.chemin_records = "user://recette_maison_%d_records.sav" % OS.get_process_id()   # lot 07 : jamais le vrai records.sav
	await _partie(true, 7, "plus_cher", "vendre", true)
	_reprise_ancienne()
	if OS.get_environment("TESTEUR_UNE") != "":
		Sauvegarde.effacer(Partie.chemin_sauvegarde)
		Records.effacer(Partie.chemin_records)
		print("=== recette maison (une partie) : %d OK, %d KO ===" % [ok, ko])
		get_tree().quit(1 if ko > 0 else 0)
		return
	if OS.get_environment("TESTEUR_TOUT") != "":
		await _partie(false, 7, "moins_cher", "auto")
		await _partie(true, 31, "milieu", "vendre")
		await _partie(false, 31, "plus_cher", "vendre")
	Sauvegarde.effacer(Partie.chemin_sauvegarde)
	Records.effacer(Partie.chemin_records)
	print("=== recette maison :%d OK, %d KO ===" % [ok, ko])
	get_tree().quit(1 if ko > 0 else 0)


## CA-M9 : une sauvegarde sans les clés « foyer » ni « projets » (0.4.1) se recharge sans cartes ni projets et la partie finit.
func _reprise_ancienne() -> void:
	var e := EtatPartie.new()
	e.demarrer(Donnees.config_demo(7))
	e.resolution_auto()
	StrategieTest.aller_a(e, Dates.lire("1985-06"), false)
	var chemin := "user://recette_maison_ancienne_%d.sav" % OS.get_process_id()
	Sauvegarde.ecrire(e, {}, chemin)
	var d := Sauvegarde.lire(chemin)
	var etat_d: Dictionary = d.get("etat", d)
	for cle in ["foyer", "projets"]:
		etat_d.erase(cle)
	var e2 := Sauvegarde.charger(d)
	Sauvegarde.effacer(chemin)
	verifier("CA-M9 : sauvegarde sans foyer ni projets : reprise sans cartes ni projets (%s)" % Dates.texte(e2.ab_courant()), e2 != null and not e2.cartes_actives() and not e2.projets_actifs(), "cartes=%s projets=%s" % [str(e2.cartes_actives()), str(e2.projets_actifs())])
	var garde := 0
	var cartes_vues := 0
	while e2.fin == "" and garde < 100:
		if not e2.modale.is_empty():
			if str(e2.modale.get("kind", "")) in ["carte", "projet"]:
				cartes_vues += 1
			e2.resolution_auto()
		e2.avancer()
		garde += 1
	verifier("CA-M9 : la partie reprise finit sans carte ni projet (fin=%s, %s)" % [e2.fin, Dates.texte(e2.ab_courant())], e2.fin == "fin" and cartes_vues == 0 and e2.projet_en_cours().is_empty(), "cartes=%d" % cartes_vues)

func _images(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _raz() -> void:
	cartes = 0
	projets_choix = 0
	jours_j = {"A": 0, "B": 0, "C": 0}
	ventes_conformes = 0
	ventes_ecarts = []
	banque_ecarts = []
	etiquette_ecarts = []
	etiquette_vues = 0
	guichet_ecarts = []
	guichets = 0
	foyers = 0
	foyer_ecarts = []
	photos = {}
	cc_negatif = []
	choix_projet_ecarts = []
	echap_ecarts = []
	bloque = ""


## Valeur de ce que le joueur détient pour chaque id du plan de vente (pour détecter ce qui a été vendu).
func _instantane(e: EtatPartie) -> Dictionary:
	var d := {}
	for id in e.joueur.lignes.keys():
		d[str(id)] = e.joueur.qte(str(id))
	d["av"] = float(e.joueur.av.get("primes", 0.0))
	d["pel"] = float(e.joueur.pel.get("verse", 0.0))
	return d


func _partie(actif: bool, graine: int, pol_projets: String, pol_echeance: String, forcer_b := false) -> void:
	_raz()
	var nom := "%s graine %d (projets %s, jour J %s%s)" % ["actif" if actif else "passif", graine, pol_projets, pol_echeance, ", portefeuille fabrique avant le jour J" if forcer_b else ""]
	StrategieTest.politique_projets = pol_projets
	StrategieTest.politique_echeance = pol_echeance
	StrategieTest.politique_cartes = "epargner" if graine == 7 else "alterner"
	scene = load("res://scenes/principal.tscn").instantiate()
	add_child(scene)
	await _images(5)
	modales = scene.get("modales")
	hud = scene.get("hud")
	seq = scene.get("sequences")
	var cfg := Donnees.config_demo(graine)
	cfg["cartes"] = true
	cfg["projets"] = true
	scene.set("_ignorer_modales", true)
	Partie.nouvelle_partie(cfg)
	scene.set("_ignorer_modales", false)
	scene.call("_apres_mise_en_place")
	Partie.etat.resolution_auto()      # présentation d'ouverture : comme partir_de_la_rue
	scene.call("demarrer_direct", 0)
	await _images(10)
	Partie.bloquee = false
	var e := Partie.etat
	var t_debut := Time.get_ticks_msec()
	var t_vu := Time.get_ticks_msec()
	var sig := ""
	var traite := ""
	var mois_etiquette := -1
	var mois_guichet := -1
	var n_it := 0
	var t_porte := -1.0
	while e.fin == "" and bloque == "" and Time.get_ticks_msec() - t_debut < 480000:
		await get_tree().process_frame
		n_it += 1
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
		if e.joueur.cc < -0.5 and kind == "" and not seq.occupe:
			if cc_negatif.size() < 5:
				cc_negatif.append("%s : compte %.2f" % [Dates.texte_court(e.ab_courant()), e.joueur.cc])
		if not e.modale.is_empty():
			if not modales.ouverte():
				if (kind == "carte" or kind == "projet") and seq.occupe and not photos.has("porte_" + kind):
					if t_porte < 0.0:
						t_porte = Time.get_ticks_msec() / 1000.0
					elif Time.get_ticks_msec() / 1000.0 - t_porte > 0.45:
						photos["porte_" + kind] = true
						await _photo("porte_" + kind)
				continue
			t_porte = -1.0
			var cle := "%d|%s|%s|%s" % [e.ab_courant(), str(e.modale.get("id", "")), str(e.modale.get("etape", "")), kind]
			if kind == "carte" or kind == "projet":
				var mm: ModaleCarte = modales.etat_carte() if kind == "carte" else modales.etat_projet()
				if mm.phase == "conclusion":
					mm.passer()
					continue
				if mm.phase != "attente" or modales.genre_courant != kind:
					continue
				if traite == cle and kind == "carte":
					continue   # (un refus du moteur rouvre la carte : même clé, on ne rejoue pas)
				if traite == cle and kind == "projet" and not (mm as ModaleProjet).en_confirmation:
					continue
				traite = cle
				await _agir_carte_projet(e, kind, mm, actif)
			else:
				if traite != cle:
					traite = cle
					fiches[kind] = int(fiches.get(kind, 0)) + 1
					await _images(8)
					if modales.ouverte() and not e.modale.is_empty():
						var ch := StrategieTest.choix_modale(e, actif)
						modales.fermer(ch)
			continue
		# Pas de modale : la fenêtre Banque ouverte par une présentation « ouvrir » : on la referme comme le joueur (la stratégie a déjà placé l'ordre)
		if modales.ouverte() and modales.genre_courant == "banque":
			await _images(20)
			if modales.ouverte() and modales.genre_courant == "banque":
				fiches["banque_ouverte"] = int(fiches.get("banque_ouverte", 0)) + 1
				modales.fermer("fermer")
			continue
		# Pas de modale : attendre la fin des séquences, puis jouer le mois et sauter
		if seq.occupe or modales.ouverte() or Partie.saut_actif or Partie.bloquee:
			continue
		var ab := e.ab_courant()
		if ab != mois_etiquette:
			mois_etiquette = ab
			_controler_etiquette(e)
			if e.joueur.cc < -0.5:
				cc_negatif.append("%s : compte %.2f (hors modale)" % [Dates.texte_court(ab), e.joueur.cc])
		if ab != mois_guichet and not e.projet_en_cours().is_empty() and (ab % 3 == 0):
			mois_guichet = ab
			await _controler_guichet(e)
			await _controler_foyer(e)
			continue
		if forcer_b and ab >= Dates.lire("1985-06") and ab < Dates.lire("1986-04"):
			forcer_b = false
			e.joueur.cc += e.joueur.livret
			e.joueur.livret = 0.0
			var r_f: Dictionary = e.acheter(e.joueur, "sicav", e.joueur.cc - Produits.f(1500.0))
			print("RECETTE portefeuille fabrique : SICAV achetee, cc=%.2f F, refus=%s" % [e.joueur.cc * 6.55957, str(r_f.get("msg", "aucun"))])
		if e.m >= e.m_fin:
			StrategieTest.jouer_mois(e, actif)
			Partie.changer_vitesse(3)   # dernier mois : le saut est impossible, on joue le temps reel
			continue
		StrategieTest.jouer_mois(e, actif)
		Partie.sauter_jusqu_au_prochain_arret()
	var duree := (Time.get_ticks_msec() - t_debut) / 1000.0
	print("RECETTE maison %s : fin=%s %s patrimoine=%.0f F frais=%.2f F cartes=%d projets_choisis=%d jours_j=%s ventes_conformes=%d guichets=%d etiquettes=%d fiches=%s duree=%.0f s" % [
		nom, e.fin, Dates.texte(e.ab_courant()), e.patrimoine(e.joueur) * 6.55957 / 6.55957, e.frais_payes(), cartes, projets_choix, str(jours_j), ventes_conformes, guichets, etiquette_vues, str(fiches), duree])
	verifier("%s : partie complete par la vraie interface, aucun blocage (%s)" % [nom, bloque], bloque == "" and e.fin == "fin" and Dates.texte(e.ab_courant()).contains("1988"), "fin=%s %s" % [e.fin, Dates.texte(e.ab_courant())])
	verifier("%s : cartes (7 a 10 attendues avec projets) toutes fermees : %d" % [nom, cartes], cartes >= 6 and cartes <= 10, str(cartes))
	verifier("%s : choix de projet : projet_en_cours()[id] == option choisie, %d choix" % [nom, projets_choix], projets_choix >= 2 and choix_projet_ecarts.is_empty(), str(choix_projet_ecarts))
	verifier("%s : ventes faites == plan_vente_projet() (%d jours J avec ventes)" % [nom, ventes_conformes], ventes_ecarts.is_empty(), str(ventes_ecarts))
	verifier("%s : BANQUE fermee pendant carte et projet (phrase du moteur), rouverte apres" % nom, banque_ecarts.is_empty(), str(banque_ecarts))
	verifier("%s : etiquette MA MAISON == projet_en_cours() chaque mois (%d mois avec projet)" % [nom, etiquette_vues], etiquette_ecarts.is_empty() and etiquette_vues >= 10, str(etiquette_ecarts))
	verifier("%s : ligne du guichet == ligne_projet_guichet() (%d fiches), absente sans projet" % [nom, guichets], guichet_ecarts.is_empty() and guichets >= 1, str(guichet_ecarts))
	verifier("%s : Mon foyer (projet en cours) == projet_en_cours() : %d ouvertures" % [nom, foyers], foyer_ecarts.is_empty() and foyers >= 1, str(foyer_ecarts))
	verifier("%s : Echap sans effet hors confirmation, = RETOUR dans la confirmation" % nom, echap_ecarts.is_empty(), str(echap_ecarts))
	verifier("%s : compte jamais sous 0 apres une carte ou un projet" % nom, cc_negatif.is_empty(), str(cc_negatif))
	scene.queue_free()
	await _images(5)


## Photo du viewport (si TESTEUR_IMG est défini) : preuve visuelle relue par le testeur.
func _photo(nom: String) -> void:
	var dossier := OS.get_environment("TESTEUR_IMG")
	if dossier == "":
		return
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png("%s/%s_%s.png" % [dossier, OS.get_environment("TESTEUR_FMT"), nom])


## « Mon foyer » ouvert depuis le bâtiment : le bloc PROJET EN COURS == projet_en_cours() (CA-M4), lu sur les étiquettes réelles.
func _controler_foyer(e: EtatPartie) -> void:
	await get_tree().create_timer(1.0).timeout
	var pe := e.projet_en_cours()
	scene.call("toucher_batiment", "maison")
	var t := 0.0
	while modales.genre_courant != "info" and t < 4.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	await get_tree().create_timer(1.0).timeout
	var date := Dates.texte_court(e.ab_courant())
	if modales.genre_courant != "info" or modales.courant == null:
		foyer_ecarts.append("%s : « Mon foyer » non ouvert" % date)
		return
	var textes: Array = []
	for l in modales.courant.find_children("*", "Label", true, false):
		if (l as Label).visible:
			textes.append((l as Label).text)
	var tout := "\n".join(PackedStringArray(textes))
	var restants: int = e.ab_de(int(pe["m_echeance"])) - e.ab_courant()
	var attendus := ["%s · %s · dans %s" % [pe["nom"], Dates.texte(e.ab_de(int(pe["m_echeance"]))), Dates.duree(restants) if restants > 0 else "ce mois-ci"],
		Format.entier(float(pe["disponible"]), e.ab_courant()) + " sans rien vendre"]
	for a in attendus:
		if not tout.contains(a):
			foyer_ecarts.append("%s : « %s » absent de Mon foyer" % [date, a])
	if restants != int(pe["mois_restants"]):
		foyer_ecarts.append("%s : mois_restants %d, écart de dates %d" % [date, int(pe["mois_restants"]), restants])
	if foyers < 1:
		await _photo("foyer")
	foyers += 1
	modales.fermer("fermer")
	var t2 := 0.0
	while modales.ouverte() and t2 < 4.0:
		await get_tree().process_frame
		t2 += get_process_delta_time()
	await _images(5)

func _controler_etiquette(e: EtatPartie) -> void:
	var pe := e.projet_en_cours()
	var lab := hud.etiquettes["maison"].find_child("LigneProjet", true, false) as Label
	if lab == null:
		etiquette_ecarts.append("nœud LigneProjet introuvable")
		return
	hud.maj(e, false)
	var attendu := "" if pe.is_empty() else "%s / %s" % [Format.nombre(Format.en_devise(float(pe["disponible"]), Format.devise(e.ab_courant()))), Format.entier(float(pe["montant"]), e.ab_courant())]
	var vu := lab.text if lab.visible else ""
	if vu != attendu:
		etiquette_ecarts.append("%s : « %s » au lieu de « %s »" % [Dates.texte_court(e.ab_courant()), vu, attendu])
	elif attendu != "":
		etiquette_vues += 1


func _controler_guichet(e: EtatPartie) -> void:
	scene.call("ouvrir_banque", "", -2.0)
	var t := 0.0
	while not modales.ouverte() and t < 4.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	await get_tree().create_timer(1.0).timeout
	if modales.banque == null or not is_instance_valid(modales.banque):
		guichet_ecarts.append("%s : fenetre Banque non ouverte" % Dates.texte_court(e.ab_courant()))
		return
	var l := modales.banque.find_child("LigneProjetGuichet", true, false) as Label
	var attendu := e.ligne_projet_guichet()
	if l == null or not l.visible or l.text != attendu:
		guichet_ecarts.append("%s : « %s » au lieu de « %s »" % [Dates.texte_court(e.ab_courant()), "" if l == null else (l.text if l.visible else "(cachee)"), attendu])
	else:
		guichets += 1
	if guichets == 1:
		await _photo("guichet")
	modales.fermer("fermer")
	var t2 := 0.0
	while modales.ouverte() and t2 < 4.0:
		await get_tree().process_frame
		t2 += get_process_delta_time()
	await _images(5)


func _banque_fermee_ok(e: EtatPartie, kind: String) -> void:
	var date := Dates.texte_court(e.ab_courant())
	var fermee := bool(scene.call("banque_fermee"))
	var phrase_ok: bool = hud.l_banque_fermee != null and hud.l_banque_fermee.visible and hud.l_banque_fermee.text == Hud.PHRASE_BANQUE_FERMEE
	var refus: Dictionary = e.acheter(e.joueur, "elf", Produits.f(100.0))
	var msg := str(refus.get("msg", ""))
	var avant := modales.genre_courant
	scene.call("ouvrir_banque", "sicav", -2.0)
	await _images(3)
	var inchange: bool = modales.genre_courant == avant and (modales.banque == null or not is_instance_valid(modales.banque) or not modales.banque.is_inside_tree())
	if not fermee or not phrase_ok or msg != Hud.PHRASE_BANQUE_FERMEE or not inchange or not hud.b_marche.disabled:
		banque_ecarts.append("%s %s : fermee=%s phrase_hud=%s msg_moteur=« %s » ouverture_sans_effet=%s bouton_grise=%s" % [date, kind, str(fermee), str(phrase_ok), msg, str(inchange), str(hud.b_marche.disabled)])


func _agir_carte_projet(e: EtatPartie, kind: String, mm: ModaleCarte, actif: bool) -> void:
	var c := e.contenu_modale()
	var date := Dates.texte_court(e.ab_courant())
	fiches[kind] = int(fiches.get(kind, 0)) + 1
	await _images(8)
	var cle_photo := kind if kind == "carte" else "projet_" + str(c.get("etape", ""))
	if c.get("etape", "") == "echeance":
		var ids_j: Array = c["choix"].map(func(x: Dictionary) -> String: return str(x["id"]))
		var dsb := false
		for x: Dictionary in c["choix"]:
			if str(x["id"]) == "realiser_en_vendant":
				dsb = bool(x.get("desactive", false))
		cle_photo = "jour_j_" + ("A" if ids_j.has("realiser") else ("C" if dsb else "B"))
	if not photos.has(cle_photo) and photos.size() < 12:
		photos[cle_photo] = true
		await _photo(cle_photo)
	await _banque_fermee_ok(e, kind)
	var choix_id := StrategieTest.choix_modale(e, actif)
	if kind == "carte":
		cartes += 1
		# un choix désactivé est sans effet (la carte reste)
		for ch: Dictionary in c.get("choix", []):
			if bool(ch.get("desactive", false)):
				var ph := mm.phase
				mm.choisir(str(ch["id"]))
				if mm.phase != ph or e.modale.is_empty():
					echap_ecarts.append("%s : choix desactive %s accepte" % [date, str(ch["id"])])
		var cc0 := e.joueur.cc
		mm.choisir(choix_id)
		await _images(2)
		return
	# projet
	var mp := mm as ModaleProjet
	var etape := str(c.get("etape", ""))
	# Echap hors confirmation : sans effet
	mp.echap()
	if mp.phase != "attente" or e.modale.is_empty():
		echap_ecarts.append("%s : Echap a ferme la carte de projet (%s)" % [date, etape])
	if etape == "choix":
		var opt := choix_id
		mp.choisir(opt)
		await _images(3)
		var pe := e.projet_en_cours()
		projets_choix += 1
		if pe.is_empty() or str(pe.get("id", "")) != opt:
			choix_projet_ecarts.append("%s : option choisie %s, projet_en_cours() %s" % [date, opt, str(pe.get("id", "(vide)"))])
		return
	# jour J : le cas
	var etats := {}
	for ch: Dictionary in c.get("choix", []):
		etats[str(ch["id"])] = bool(ch.get("desactive", false))
	var cas := "A" if (etats.has("realiser") and not bool(etats["realiser"])) else ("B" if (etats.has("realiser_en_vendant") and not bool(etats["realiser_en_vendant"])) else "C")
	jours_j[cas] = int(jours_j[cas]) + 1
	print("RECETTE jour_j %s : cas %s etats=%s disponible=%s manque=%s plan=%d" % [date, cas, str(etats), str(c.get("disponible", "?")), str(c.get("manque", "?")), e.plan_vente_projet().size()])
	if choix_id == "realiser_en_vendant":
		var plan := e.plan_vente_projet()
		var avant := _instantane(e)
		var cc0 := e.joueur.cc
		mp.choisir("realiser_en_vendant")
		await _images(8)
		if not photos.has("confirmation"):
			photos["confirmation"] = true
			await _photo("confirmation")
		if not mp.en_confirmation:
			echap_ecarts.append("%s : RENDRE EN VENDANT n'ouvre pas la confirmation" % date)
			return
		# Echap = RETOUR, puis on rouvre la confirmation
		mp.echap()
		if mp.en_confirmation or e.modale.is_empty():
			echap_ecarts.append("%s : Echap dans la confirmation n'a pas fait RETOUR" % date)
		mp.choisir("realiser_en_vendant")
		await _images(2)
		mp.choisir_rang(0)   # CONFIRMER
		await _images(3)
		var apres := _instantane(e)
		var vendus := []
		for id in avant.keys():
			if float(apres.get(id, 0.0)) < float(avant[id]) - 1e-6:
				vendus.append(str(id))
		var attendus := plan.map(func(v: Dictionary) -> String: return str(v["id"]))
		vendus.sort()
		attendus.sort()
		if vendus != attendus:
			ventes_ecarts.append("%s : vendus %s, plan %s" % [date, str(vendus), str(attendus)])
		else:
			ventes_conformes += 1
		if e.joueur.cc < -0.5:
			cc_negatif.append("%s : compte %.2f apres ventes (avant %.2f)" % [date, e.joueur.cc, cc0])
		return
	mp.choisir(choix_id)
	await _images(2)
