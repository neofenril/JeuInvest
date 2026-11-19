class_name PanneauEnveloppes
extends RefCounted
## Fiches PEA, SCPI et PEP de la fenêtre Banque (lot 10b, I8 ; docs/47 §3, D5). Complète la fiche commune de PanneauBanque (définition,
## 4 critères, frais) par le propre de chaque produit ; aucune règle de jeu ici : les chiffres viennent d'Enveloppes, de EtatPartie et du
## catalogue, les ordres passent par Partie (acheter, vendre, vendre_scpi, annuler_vente_differee, ouvrir_pea, verser_pea, retirer_pea).
## Les montants des ordres sont des boutons de montants ronds (pas de curseur) : un toucher passe l'ordre, le résultat s'affiche en tête.
##   PEA  : ouvrir ; versements en numéraire sous le plafond ; achats et ventes de titres éligibles DANS l'enveloppe ; retrait (avant 5 ans
##          il clôt le plan : phrase d'avertissement ; l'impôt est calculé par le moteur).
##   SCPI : la ligne affiche la valeur de REVENTE (les frais se voient tout de suite) ; achat par parts ; vente DIFFÉRÉE (3 mois) visible avec
##          son mois d'exécution et annulable.
##   PEP  : produit « message » : fiche d'information, aucun bouton d'achat (« En savoir plus » = le texte long de la notification).

const MONTANTS_F := [1000.0, 5000.0, 10000.0]
const PARTS := [1, 5, 10]


## Types gérés ici (les autres produits gardent la fiche et le formulaire de toujours).
static func gere(type: String) -> bool:
	return type in ["scpi", "pea", "message"]


## Complète la colonne de droite de `p` (fiche déjà posée : en-tête, définition, critères) selon le type du produit.
static func completer(p: PanneauBanque, pid: String, type: String) -> void:
	var d := p.zone_droite()
	if p.message_enveloppe != "":
		var lm := p._texte(p.message_enveloppe, 20 if p.compact else 22, Style.ui_gras(), Style.CUIVRE)
		lm.name = "MessageEnveloppe"
		d.add_child(lm)
		p.message_enveloppe = ""
	match type:
		"scpi":
			_scpi(p, d, pid)
		"pea":
			_pea(p, d, pid)
		_:
			_message(p, d, pid)


# ---------------------------------------------------------------------
# SCPI
# ---------------------------------------------------------------------

## Texte « Vous avez » d'une SCPI : parts et valeur de revente (testé : valeur_ligne).
static func texte_scpi(e: EtatPartie) -> String:
	var a := e.ab_courant()
	var n := Enveloppes.parts(e.joueur)
	if n < 1.0:
		return "Vous avez : rien pour l'instant."
	return "Vous avez : %d part%s = %s à la revente." % [int(n), "s" if n >= 2.0 else "", Format.montant(Enveloppes.valeur_scpi(e.joueur, a), a)]


static func _scpi(p: PanneauBanque, d: Control, pid: String) -> void:
	var e := p.e
	var a := e.ab_courant()
	var compact := p.compact
	d.add_child(p._texte("Une part coûte %s ; revendue aujourd'hui, elle vaut %s. Loyers : %s %% par an, chaque trimestre." % [
		Format.montant(Enveloppes.prix_part(), a), Format.montant(Enveloppes.prix_revente(a), a), Format.nombre(Enveloppes.taux_loyer(a), 1)], 20 if compact else 22, Style.ui(), Style.TEXTE))
	var lv := p._texte(texte_scpi(e), 22 if compact else 24, Style.chiffres())
	lv.name = "VousAvez"
	d.add_child(lv)
	# Ventes en cours : mois d'exécution et ANNULER
	var ventes := e.ventes_differees()
	for i in ventes.size():
		var v: Dictionary = ventes[i]
		var h := HBoxContainer.new()
		h.name = "VenteEnCours"
		h.add_theme_constant_override("separation", 12)
		var t := Style.label("Vente en cours : %d part%s, exécution en %s." % [int(v["parts"]), "s" if int(v["parts"]) >= 2 else "", Dates.texte(e.ab_de(int(v["m_execution"])))], 20 if compact else 22, Style.ui_gras(), Style.GEL)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		t.custom_minimum_size.x = p._largeur_droite - 220.0
		t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(t)
		var an := Style.bouton("ANNULER", false, 64 if compact else 72)
		an.name = "AnnulerVente"
		an.pressed.connect(_annuler.bind(p, pid, i))
		h.add_child(an)
		d.add_child(h)
	var libres := int(Enveloppes.parts(e.joueur) - Enveloppes.parts_en_vente(e.joueur) + 1e-9)
	d.add_child(_rangee(p, "ACHETER", PARTS, func(n: int) -> String: return "%d PART%s" % [n, "S" if n > 1 else ""], func(n: int) -> void: _acheter(p, pid, n),
		func(n: int) -> bool: return e.joueur.cc >= Enveloppes.prix_part() * n - 1e-6, true))
	if Enveloppes.parts(e.joueur) >= 1.0:
		d.add_child(_rangee(p, "VENDRE (3 MOIS)", PARTS, func(n: int) -> String: return "%d PART%s" % [n, "S" if n > 1 else ""], func(n: int) -> void: _vendre_scpi(p, pid, n),
			func(n: int) -> bool: return n <= libres, false))
	d.add_child(p._texte("La revente prend du temps : l'argent arrive 3 mois après l'ordre, au prix du jour d'exécution.", 16 if compact else 18, Style.ui(), Style.TEXTE_2))


static func _acheter(p: PanneauBanque, pid: String, n: int) -> void:
	var r := Partie.acheter("scpi", Enveloppes.prix_part() * n)
	p.message_enveloppe = "" if r.get("ok", false) else str(r.get("msg", "Ordre refusé."))
	p.rafraichir_fiche(pid)


static func _vendre_scpi(p: PanneauBanque, pid: String, n: int) -> void:
	var ok := Partie.vendre_scpi(n)
	Partie.argent_change.emit()
	p.message_enveloppe = "" if ok else "Vous ne détenez pas autant de parts à vendre."
	p.rafraichir_fiche(pid)


static func _annuler(p: PanneauBanque, pid: String, i: int) -> void:
	Partie.annuler_vente_differee(i)
	Partie.argent_change.emit()
	p.rafraichir_fiche(pid)


# ---------------------------------------------------------------------
# PEA
# ---------------------------------------------------------------------

static func _pea(p: PanneauBanque, d: Control, pid: String) -> void:
	var e := p.e
	var a := e.ab_courant()
	var w := e.joueur
	var compact := p.compact
	if not Enveloppes.a_pea(w):
		var lv := p._texte("Vous avez : pas encore de PEA.", 22 if compact else 24, Style.chiffres())
		lv.name = "VousAvez"
		d.add_child(lv)
		var ouvrir := Style.bouton("OUVRIR UN PEA", true, 72 if compact else 80)
		ouvrir.name = "OuvrirPea"
		ouvrir.pressed.connect(_ouvrir.bind(p, pid))
		d.add_child(ouvrir)
		return
	var plafond := Enveloppes.plafond_pea(a)
	var verse := float(w.pea["verse"])
	var duree := int(Enveloppes.params_pea().get("duree_exoneration_mois", 60))
	var age := Enveloppes.age_pea(e, w)
	var lv2 := p._texte("Vous avez : %s dans le PEA, dont %s en espèces." % [Format.montant(Enveloppes.valeur_pea(e, w), a), Format.montant(float(w.pea["cc"]), a)], 22 if compact else 24, Style.chiffres())
	lv2.name = "VousAvez"
	d.add_child(lv2)
	d.add_child(p._texte("Versé : %s sur un plafond de %s · ouvert depuis %s." % [Format.montant(verse, a), Format.montant(plafond, a), Dates.duree(age) if age > 0 else "ce mois-ci"], 18 if compact else 20, Style.ui(), Style.TEXTE_2))
	d.add_child(_rangee(p, "VERSER", MONTANTS_F, func(f: float) -> String: return Format.entier(Produits.f(f), a), func(f: float) -> void: _verser(p, pid, f),
		func(f: float) -> bool: return w.cc >= Produits.f(f) - 1e-6 and plafond - verse >= Produits.f(f) - 1e-6, true))
	d.add_child(_rangee(p, "RETIRER", [1000.0], func(f: float) -> String: return Format.entier(Produits.f(f), a), func(f: float) -> void: _retirer(p, pid, f),
		func(_f: float) -> bool: return Enveloppes.valeur_pea(e, w) > 0.0, false))
	if age < duree:
		d.add_child(p._texte("Retirer avant %d ans clôt le plan : les gains sont alors imposés comme sur un compte-titres." % [duree / 12], 16 if compact else 18, Style.ui_gras(), Style.CUIVRE))
	# Titres du PEA : les produits éligibles déjà présentés, dans une liste qui défile (3 lignes visibles au PC, 2 au téléphone)
	var liste := ScrollContainer.new()
	liste.name = "ListeTitres"
	liste.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var lv_liste := VBoxContainer.new()
	lv_liste.add_theme_constant_override("separation", 6)
	lv_liste.custom_minimum_size.x = p._largeur_droite - 14.0
	liste.add_child(lv_liste)
	var n_titres := 0
	for tid: String in Banquier.ordre_carnet():
		if not Banquier.presente(e, tid) or not Enveloppes.eligible_pea(e, tid):
			continue
		var l: Dictionary = (w.pea["lignes"] as Dictionary).get(tid, {})
		var valeur := float(l.get("qte", 0.0)) * e.cours(tid) if not l.is_empty() else 0.0
		var h := HBoxContainer.new()
		h.name = "TitrePea_%s" % tid
		h.add_theme_constant_override("separation", 10)
		var nom := Style.label("%s · %s" % [str(Banquier.info_produit(tid).get("court", tid)), Format.montant(valeur, a) if not l.is_empty() else "aucun"], 20 if compact else 22, Style.ui_gras())
		nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nom.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(nom)
		var ba := Style.bouton("ACHETER %s" % Format.entier(Produits.f(1000.0), a), true, 64 if compact else 72)
		ba.name = "AcheterPea"
		ba.disabled = float(w.pea["cc"]) < Produits.f(100.0)
		ba.pressed.connect(_acheter_pea.bind(p, pid, tid))
		h.add_child(ba)
		var bv := Style.bouton("VENDRE TOUT", false, 64 if compact else 72)
		bv.name = "VendrePea"
		bv.disabled = l.is_empty()
		bv.pressed.connect(_vendre_pea.bind(p, pid, tid))
		h.add_child(bv)
		lv_liste.add_child(h)
		n_titres += 1
	liste.custom_minimum_size = Vector2(0, minf(float(n_titres), 1.5 if compact else 3.0) * (Style.cible_min() + 14.0 if compact else 90.0))
	d.add_child(liste)


static func _ouvrir(p: PanneauBanque, pid: String) -> void:
	var ok := Partie.ouvrir_pea()
	Partie.argent_change.emit()
	p.message_enveloppe = "" if ok else "Impossible d'ouvrir le PEA."
	p.rafraichir_fiche(pid)


static func _verser(p: PanneauBanque, pid: String, f: float) -> void:
	var r := Partie.verser_pea(Produits.f(f))
	p.message_enveloppe = "" if r.get("ok", false) else str(r.get("msg", "Versement refusé."))
	p.rafraichir_fiche(pid)


static func _retirer(p: PanneauBanque, pid: String, f: float) -> void:
	var r := Partie.retirer_pea(Produits.f(f))
	p.message_enveloppe = "" if r.get("ok", false) else str(r.get("msg", "Retrait refusé."))
	if r.get("ok", false) and bool(r.get("cloture", false)):
		p.message_enveloppe = "Le PEA est clôturé : %s reçus, dont %s d'impôt." % [Format.montant(float(r.get("recu", 0.0)), p.e.ab_courant()), Format.montant(float(r.get("impot", 0.0)), p.e.ab_courant())]
	p.rafraichir_fiche(pid)


static func _acheter_pea(p: PanneauBanque, pid: String, tid: String) -> void:
	var r := Partie.acheter(tid, Produits.f(1000.0), "pea")
	p.message_enveloppe = "" if r.get("ok", false) else str(r.get("msg", "Ordre refusé."))
	p.rafraichir_fiche(pid)


static func _vendre_pea(p: PanneauBanque, pid: String, tid: String) -> void:
	var r := Partie.vendre(tid, 0.0, true, "pea")
	p.message_enveloppe = "" if r.get("ok", false) else str(r.get("msg", "Ordre refusé."))
	p.rafraichir_fiche(pid)


# ---------------------------------------------------------------------
# PEP (message)
# ---------------------------------------------------------------------

static func _message(p: PanneauBanque, d: Control, pid: String) -> void:
	var cat := Donnees.produit(pid)
	var long := str(cat.get("texte_long", cat.get("definition", "")))
	if long != "":
		var lt := p._texte(long, 20 if p.compact else 22, Style.ui(), Style.TEXTE)
		lt.name = "TexteLong"
		d.add_child(lt)
	d.add_child(p._texte("Ce produit est présenté par un message : pas d'achat dans cette fenêtre.", 18 if p.compact else 20, Style.ui(), Style.TEXTE_2))


# ---------------------------------------------------------------------
# Rangée de montants
# ---------------------------------------------------------------------

## Une rangée « LIBELLÉ  [montant] [montant] [montant] » ; `actif(v)` dit si le bouton peut servir.
static func _rangee(p: PanneauBanque, libelle: String, valeurs: Array, texte: Callable, action: Callable, actif: Callable, principal: bool) -> Control:
	var h := HBoxContainer.new()
	h.name = "Rangee_" + libelle.split(" ")[0]
	h.add_theme_constant_override("separation", 8)
	var l := Style.label(libelle, 20, Style.capitales(), Style.TEXTE_2)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	l.custom_minimum_size.x = 150 if not p.compact else 120
	h.add_child(l)
	for v: Variant in valeurs:
		var b := Style.bouton(str(texte.call(v)), principal, 64 if p.compact else 72)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.disabled = not bool(actif.call(v))
		b.pressed.connect(func() -> void: action.call(v))
		h.add_child(b)
	return h
