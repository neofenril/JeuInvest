extends SceneTree
## Lot 10a-moteur, CA-M6 : PEA (plafond, éligibilité, clôture avant 5 ans, retrait libre après 5 ans), SCPI (prix, frais de
## 10 %, valeur de revente datée, loyers trimestriels, vente exécutée exactement 3 mois plus tard au prix du mois d'exécution,
## annulation, hors vente automatique, absente chez les témoins) et produit « message » (PEP : notification avec texte long).
## Partie d'essai sur les années 1992-1993 : mois fixés par config, sans événement de vie (sans_vie), sans banquier.

var _ok := 0
var _ko := 0


func _partie(debut: String, fin: String) -> EtatPartie:
	var c := Donnees.config_demo(5)
	c["debut"] = debut
	c["fin"] = fin
	c.erase("chapitre")   # hors des chapitres ouverts (1992-1997) : la fin n'est pas bornée par derniere_annee
	c["sans_vie"] = true
	c["banquier"] = false
	c["rue"] = false
	var e := EtatPartie.new()
	e.demarrer(c)
	e.joueur.cc = Produits.f(3000000.0)
	return e


func _aller(e: EtatPartie, mois: String) -> void:
	var cible := Dates.lire(mois)
	var garde := 0
	while e.ab_courant() < cible and e.fin == "" and garde < 400:
		garde += 1
		while not e.modale.is_empty():
			e.resolution_auto()
		e.avancer()


func _initialize() -> void:
	# ---------- PEA ----------
	var e := _partie("1992-01", "1993-12")
	verifier("PEA : refusé avant 07/1992 (le plan naît en 07/1992, docs/46)", not e.ouvrir_pea() and e.joueur.pea.is_empty())
	_aller(e, "1992-07")
	verifier("PEA : ouvert en 07/1992 ; une seconde ouverture est refusée", e.ouvrir_pea() and not e.ouvrir_pea())
	var plaf := Enveloppes.plafond_pea(e.ab_courant())
	verifier("Plafond du PEA : 600 000 F (series.json)", absf(plaf - Produits.f(600000.0)) < 0.01, str(plaf))
	var v := Enveloppes.verser_pea(e, e.joueur, Produits.f(700000.0))
	verifier("Versement : plafonné à 600 000 F, le reste est refusé", v["ok"] and absf(float(e.joueur.pea["verse"]) - Produits.f(600000.0)) < 0.01 and not Enveloppes.verser_pea(e, e.joueur, 100.0)["ok"])
	verifier("Éligibilité : Elf et la SICAV actions oui, la SICAV monétaire non", Enveloppes.eligible_pea(e, "elf") and Enveloppes.eligible_pea(e, "sicav") and not Enveloppes.eligible_pea(e, "sicav_monetaire"))
	var d := e.acheter(e.joueur, "elf", Produits.f(20000.0), "pea")
	verifier("Achat dans l'enveloppe : payé par les espèces du PEA, pas par le compte courant ; enveloppe(\"elf\") = pea",
		d["ok"] and e.enveloppe("elf") == "pea" and not e.joueur.lignes.has("elf") and e.joueur.cc > Produits.f(2000000.0) and float(e.joueur.pea["cc"]) < Produits.f(600000.0) - 1.0)
	verifier("Achat non éligible refusé dans le PEA", not e.acheter(e.joueur, "sicav_monetaire", 1000.0, "pea")["ok"])
	var patr := e.patrimoine(e.joueur)
	verifier("patrimoine compte le PEA (espèces + titres)", patr > e.joueur.cc + Enveloppes.valeur_pea(e, e.joueur) - 1.0 and Enveloppes.valeur_pea(e, e.joueur) > Produits.f(590000.0))
	var avant_cc := e.joueur.cc
	var r := Enveloppes.retirer_pea(e, e.joueur, Produits.f(1000.0))
	verifier("Retrait avant 5 ans = clôture : plan vide, tout est versé au compte courant, impôt du compte-titres sur le gain", r["ok"] and r["cloture"] and e.joueur.pea.is_empty()
		and e.joueur.cc > avant_cc + Produits.f(500000.0) and float(r["impot"]) >= 0.0 and absf(float(r["impot"]) - maxf(0.0, float(r["gain"])) * 0.16) < 0.01, str(r))
	# Après 5 ans
	var f := _partie("1992-07", "1993-12")   # P1 s'arrête en 1993 : l'ancienneté de 5 ans est simulée en reculant la date d'ouverture
	f.ouvrir_pea()
	Enveloppes.verser_pea(f, f.joueur, Produits.f(100000.0))
	f.acheter(f.joueur, "elf", Produits.f(40000.0), "pea")
	f.joueur.pea["ouvert_m"] = f.m - 61
	verifier("Ancienneté du PEA : 61 mois", Enveloppes.age_pea(f, f.joueur) >= 60, str(Enveloppes.age_pea(f, f.joueur)))
	var vp := Enveloppes.vendre_pea(f, f.joueur, "elf", 0.0, true)
	var rec := Enveloppes.retirer_pea(f, f.joueur, Produits.f(1000.0))
	verifier("Après 5 ans : vente dans l'enveloppe sans impôt, retrait libre (le plan continue), impôt « pea5 » (0 en 1997)",
		vp["ok"] and rec["ok"] and not rec["cloture"] and not f.joueur.pea.is_empty() and float(rec["impot"]) < 0.01, str(rec))
	verifier("PEA : jamais recopié chez les témoins", f.temoins["livret"].pea.is_empty() and f.temoins["matelas"].pea.is_empty())

	# ---------- SCPI ----------
	var s := _partie("1993-01", "1993-12")
	var cc0 := s.joueur.cc
	var a := s.acheter(s.joueur, "scpi", Produits.f(10500.0))
	verifier("SCPI : 10 parts à 1 000 F (budget 10 500 F), dont 10 % de frais d'entrée", a["ok"] and int(a["parts"]) == 10 and absf(cc0 - s.joueur.cc - Produits.f(10000.0)) < 0.001 and absf(float(a["frais"]) - Produits.f(1000.0)) < 0.001, str(a))
	verifier("Valeur de la ligne = parts × valeur de revente datée (900 F en 01/1993) : 9 000 F, les frais se voient tout de suite",
		absf(Enveloppes.valeur_scpi(s.joueur, s.ab_courant()) - Produits.f(9000.0)) < 0.001)
	verifier("Aucune ligne « scpi » dans les lignes d'actions : la vente automatique des projets ne la voit pas", not s.joueur.lignes.has("scpi") and str(Projets.plan_vente(s, Produits.f(100000.0))).find("scpi") < 0)
	verifier("SCPI jamais recopiée chez Tata ni Tonton", s.temoins["livret"].scpi.is_empty() and s.temoins["matelas"].scpi.is_empty() and s.temoins["indice"].scpi.is_empty())
	# loyers : en mars 1993 (5,8 %), 10 parts × 1 000 F × 5,8 % ÷ 4 = 145 F brut, 121,80 F net
	var s2 := _partie("1993-01", "1993-12")
	s2.acheter(s2.joueur, "scpi", Produits.f(10000.0))
	_aller(s2, "1993-02")
	var avant := s2.joueur.cc
	var avant_impots := s2.joueur.impots
	s2.avancer()   # mars
	var gain_mars := s2.joueur.cc - avant
	verifier("Loyer de mars 1993 : 10 parts × 1 000 F × 5,8 % ÷ 4 = 145 F, net de 16 % = 121,80 F (dans le compte courant, avec le flux du mois)",
		absf(s2.joueur.impots - avant_impots - Produits.f(145.0) * 0.16) < 0.001 and gain_mars > Produits.f(121.8) - 1.0, "impôt %f gain %f" % [s2.joueur.impots - avant_impots, gain_mars])
	# vente différée : ordre en 02/1993, exécution en 05/1993 au prix de 05/1993 (820 F depuis 03/1993)
	var s3 := _partie("1993-01", "1993-12")
	s3.acheter(s3.joueur, "scpi", Produits.f(10000.0))
	_aller(s3, "1993-02")
	verifier("Vente différée : plus de parts que détenu refusé ; 4 parts acceptées", not s3.vendre_scpi(11) and s3.vendre_scpi(4))
	var vd := s3.ventes_differees()
	verifier("ventes_differees() : produit scpi, 4 parts, exécution exactement 3 mois plus tard, estimation au prix du jour (900 F)",
		vd.size() == 1 and vd[0]["produit"] == "scpi" and int(vd[0]["parts"]) == 4 and int(vd[0]["m_execution"]) - int(vd[0]["m_ordre"]) == 3 and absf(float(vd[0]["estime"]) - Produits.f(3600.0)) < 0.001, str(vd))
	verifier("Parts en vente non revendables deux fois (6 libres)", not s3.vendre_scpi(7) and s3.vendre_scpi(1))
	verifier("Annulation d'une vente différée : la seconde (1 part) est annulée, la première reste", s3.annuler_vente_differee(1) and s3.ventes_differees().size() == 1 and not s3.annuler_vente_differee(5))
	var cc_av := 0.0
	var m_exec := int(vd[0]["m_execution"])
	while s3.m < m_exec - 1:
		s3.avancer()
	cc_av = s3.joueur.cc
	verifier("Avant le terme, aucune exécution (4 parts toujours détenues)", int(Enveloppes.parts(s3.joueur)) == 10)
	s3.avancer()
	var prix_exec := Enveloppes.prix_revente(s3.ab_courant())
	verifier("Exécutée au mois d'exécution (05/1993) au prix datée du mois (820 F depuis 03/1993) ; 6 parts restent ; aucune vente en attente",
		s3.m == m_exec and absf(prix_exec - Produits.f(820.0)) < 0.001 and int(Enveloppes.parts(s3.joueur)) == 6 and s3.ventes_differees().is_empty() and s3.joueur.cc > cc_av + 4.0 * prix_exec - 1.0,
		"parts %f cc %f" % [Enveloppes.parts(s3.joueur), s3.joueur.cc - cc_av])

	# ---------- Branchement EtatPartie.vendre(enveloppe) ----------
	var k := _partie("1992-07", "1993-12")
	k.ouvrir_pea()
	Enveloppes.verser_pea(k, k.joueur, Produits.f(50000.0))
	k.acheter(k.joueur, "elf", Produits.f(20000.0), "pea")
	var cc_k := k.joueur.cc
	var vk := k.vendre(k.joueur, "elf", 0.0, true, false, "pea")
	verifier("Vente dans le PEA par vendre(..., enveloppe=pea) : ligne soldée, produit dans les espèces du PEA, compte courant et impôt inchangés",
		vk["ok"] and k.enveloppe("elf") == "" and is_equal_approx(k.joueur.cc, cc_k) and float(k.joueur.pea["cc"]) > Produits.f(29000.0) and k.joueur.impots == 0.0, str(vk))
	verifier("Vente PEA d'un titre non détenu refusée ; achat PEA sans enveloppe ouverte refusé", not k.vendre(k.joueur, "elf", 0.0, true, false, "pea")["ok"]
		and not _partie("1992-07", "1993-12").acheter(_partie("1992-07", "1993-12").joueur, "elf", 1000.0, "pea")["ok"])

	# ---------- PEP (mode message) ----------
	var n := Enveloppes.notif_message("pep")
	verifier("PEP : notification sans pause avec texte long « En savoir plus » (long et texte_long), aucune fiche jouable",
		n.get("type", "") == "message" and n["produit"] == "pep" and not str(n["long"]).is_empty() and n["long"] == n["texte_long"] and not bool(n["persistant"])
		and not e.devis_achat("pep", 1000.0)["ok"] and Enveloppes.notif_message("elf").is_empty())
	print("")
	print("=== test_enveloppes : %d OK, %d KO ===" % [_ok, _ko])
	quit(1 if _ko > 0 else 0)


func verifier(nom: String, cond: bool, detail := "") -> void:
	if cond:
		_ok += 1
		print("OK  %s" % nom)
	else:
		_ko += 1
		print("KO  %s %s" % [nom, detail])
