/* Moteur du jeu : état de la partie, déroulé d'un mois (03 §3.3), ordres, fiscalité, témoins.
   Aucun accès au DOM : l'interface lit l'état et appelle ces fonctions.
   Tous les montants internes sont en euros courants. */
var Moteur = (function () {
  "use strict";
  var R = window.DATA_REGLES, V = window.DATA_VIE, SAL = window.DATA_SALAIRES;
  var EPS = 0.005;

  var COMMUNS = {
    cc: { id: "cc", type: "cc", nom: "Compte courant", court: "Compte courant" },
    livret: { id: "livret", type: "livret", nom: "Livret A", court: "Livret A" },
    emprunt: { id: "emprunt", type: "emprunt", nom: "Emprunt d'État 10 ans", court: "Emprunt d'État" }
  };

  /* ---------------- Accès de base ---------------- */
  function mkt(S) { return Marche.generer(S.periode); }
  function abC(S) { return S.abDebut + S.m; }
  function produit(S, id) { return COMMUNS[id] || mkt(S).infos[id] || null; }
  function cours(S, id, m) { return Marche.cours(mkt(S), id, m === undefined ? S.m : m); }
  function estRisque(pr) { return pr && (pr.type === "action" || pr.type === "sicav" || pr.type === "etf"); }
  function eligiblePEA(pr) { return estRisque(pr); }
  function dispoAb(S, pr) { return pr.dispo ? U.parseD(pr.dispo) : S.abDebut; }
  function estDisponible(S, id, a) {
    var pr = produit(S, id);
    if (!pr) return false;
    if (COMMUNS[id]) return true;
    return dispoAb(S, pr) <= (a === undefined ? abC(S) : a);
  }
  function peaExiste(S) {
    var pea = mkt(S).infos.pea;
    return !!pea && dispoAb(S, pea) <= abC(S);
  }
  /* Produits proposables à la date courante (hors compte courant et PEA) */
  function produitsDisponibles(S) {
    var ids = ["livret", "emprunt"];
    mkt(S).P.produits.forEach(function (pr) {
      if (pr.type !== "pea" && estDisponible(S, pr.id)) ids.push(pr.id);
    });
    return ids;
  }

  /* ---------------- Salaires et dépenses ---------------- */
  function valeurTable(champ, x) {
    var t = SAL.table;
    function v(r) { return U.versEuros(r[champ], r.devise); }
    if (x <= t[0].annee) return v(t[0]);
    for (var i = 0; i < t.length - 1; i++) {
      if (x >= t[i].annee && x <= t[i + 1].annee) {
        var v0 = v(t[i]), v1 = v(t[i + 1]);
        return v0 * Math.pow(v1 / v0, (x - t[i].annee) / (t[i + 1].annee - t[i].annee));
      }
    }
    return v(t[t.length - 1]);
  }
  function smn(annee) { return valeurTable("smn", annee); }
  function paramsDepenses(annee) {
    var p = SAL.depenses[0];
    SAL.depenses.forEach(function (d) { if (d.de <= annee) p = d; });
    return p;
  }
  /* Dépenses du mois (03 §5.2) : elles suivent le salaire versé, mais le loyer reste celui du salaire normal
     (au chômage, la vie courante baisse avec l'indemnité, pas le loyer). */
  function depenses(S, a) {
    var p = paramsDepenses(U.annee(a)), base = S.vie.salaireBase;
    var sal = S.vie.chomageFin >= 0 ? base * V.chomageTaux : base;
    var partLoyer = (p.loyer + SAL.ajustLoyer[S.profil]) / 100;
    var loyer = base * partLoyer * S.vie.loyerMult;
    var vie = sal * (1 - p.epargne[S.profil] / 100 - partLoyer) + base * S.vie.vieSupp;
    return { loyer: loyer, vie: vie, total: loyer + vie };
  }
  function salaireDuMois(S) {
    return S.vie.chomageFin >= 0 ? S.vie.salaireBase * V.chomageTaux : S.vie.salaireBase;
  }

  /* ---------------- Portefeuilles ---------------- */
  function nouveauPortefeuille() {
    return { cc: 0, livret: 0, livretInt: 0, interetsTotal: 0, tranches: [], lignes: {},
      peaDebut: -1, peaVerse: 0, frais: 0, impots: 0, agios: 0 };
  }
  function cle(id, env) { return id + "|" + env; }
  function lignes(W) { return Object.keys(W.lignes).map(function (k) { return W.lignes[k]; }); }
  function valeurLigne(S, l, m) { var p = cours(S, l.id, m); return p ? l.qte * p : 0; }
  function totalEmprunt(W) { return W.tranches.reduce(function (s, t) { return s + t.montant; }, 0); }
  function valeurRisquee(S, W, m) {
    return lignes(W).reduce(function (s, l) { return s + valeurLigne(S, l, m); }, 0);
  }
  function patrimoine(S, W, m) { return W.cc + W.livret + totalEmprunt(W) + valeurRisquee(S, W, m); }
  /* Valeur détenue d'un produit, toutes enveloppes confondues */
  function valeurProduit(S, W, id) {
    if (id === "cc") return W.cc;
    if (id === "livret") return W.livret;
    if (id === "emprunt") return totalEmprunt(W);
    return lignes(W).filter(function (l) { return l.id === id; })
      .reduce(function (s, l) { return s + valeurLigne(S, l); }, 0);
  }

  function compterEpargne(S, flux, a) {
    S.epargneNette += flux;
    S.bagMis += flux / Marche.baguette(a);
  }

  /* ---------------- Ordres : achat ---------------- */
  /* Frais = max(minimum, taux × montant) (03 §7.5) */
  function fraisCourtage(a, brut) {
    var f = Marche.frais(a);
    return brut > 0 ? Math.max(f.min, f.taux / 100 * brut) : 0;
  }
  function coutAction(qte, p, f, ttf) {
    var brut = qte * p;
    return { brut: brut, frais: qte > 0 ? Math.max(f.min, f.taux / 100 * brut) : 0, ttf: brut * ttf };
  }
  function devisAchat(S, id, env, budget) {
    var pr = produit(S, id), a = abC(S), p = cours(S, id);
    var d = { ok: false, id: id, env: env, prix: p, qte: 0, brut: 0, frais: 0, ttf: 0, total: 0, msg: "" };
    if (!pr || !p || !estDisponible(S, id)) { d.msg = "Produit indisponible."; return d; }
    budget = Math.max(0, budget || 0);
    if (pr.type === "action") {
      var f = Marche.frais(a), t = Marche.ttf(a) / 100;
      var q = Math.floor(budget / (p * (1 + f.taux / 100 + t)));
      var c = coutAction(q, p, f, t);
      while (q > 0 && c.brut + c.frais + c.ttf > budget + 1e-9) { q--; c = coutAction(q, p, f, t); }
      if (q <= 0) {
        var c1 = coutAction(1, p, f, t);
        d.msg = "Il faut au moins " + U.txt(c1.brut + c1.frais + c1.ttf, a, { prix: true }) + " pour une action (frais compris).";
        return d;
      }
      d.qte = q; d.brut = c.brut; d.frais = c.frais; d.ttf = c.ttf;
    } else if (pr.type === "etf") {
      var fe = Marche.frais(a), tx = fe.taux / 100, brut;
      if (budget * tx / (1 + tx) >= fe.min) brut = budget / (1 + tx); else brut = budget - fe.min;
      if (brut <= 0.01) { d.msg = "Montant trop faible : les frais minimum sont de " + U.txt(fe.min, a, { prix: true }) + "."; return d; }
      d.brut = brut; d.frais = budget - brut; d.qte = brut / p;
    } else if (pr.type === "sicav") {
      if (budget < 1) { d.msg = "Montant trop faible."; return d; }
      d.frais = budget * R.sicav.entree / 100; d.brut = budget - d.frais; d.qte = d.brut / p;
    } else { d.msg = "Ce produit ne s'achète pas ainsi."; return d; }
    d.total = d.brut + d.frais + d.ttf;
    if (env === "PEA") {
      if (!peaExiste(S)) { d.msg = "Le PEA n'existe pas encore."; return d; }
      if (!eligiblePEA(pr)) { d.msg = "Produit non éligible au PEA."; return d; }
    }
    d.ok = true;
    return d;
  }
  function placePEA(S, W) { return Math.max(0, Marche.plafondPEA(abC(S)) - W.peaVerse); }
  function acheter(S, W, id, env, budget, opts) {
    opts = opts || {};
    var d = devisAchat(S, id, env, budget);
    if (!d.ok) return d;
    if (env === "PEA" && W.peaVerse + d.total > Marche.plafondPEA(abC(S)) + EPS) {
      d.ok = false; d.msg = "Plafond du PEA atteint : vous pouvez encore y verser " + U.txt(placePEA(S, W), abC(S)) + ".";
      return d;
    }
    W.cc -= d.total;
    var k = cle(id, env);
    if (!W.lignes[k]) W.lignes[k] = { id: id, env: env, qte: 0, cout: 0, depuis: S.m };
    W.lignes[k].qte += d.qte;
    W.lignes[k].cout += d.total;
    W.frais += d.frais + d.ttf;
    if (env === "PEA") { if (W.peaDebut < 0) W.peaDebut = S.m; W.peaVerse += d.total; }
    if (S.joueur === W) {
      if (!opts.auto) S.stats.ordres++;
      S.stats.frais += d.frais + d.ttf;
      enregistrerHist(S);
    }
    return d;
  }

  /* ---------------- Ordres : vente ---------------- */
  function tauxImpotVente(S, W, env) {
    var imp = Marche.impot(U.annee(abC(S)));
    if (env === "PEA" && W.peaDebut >= 0 && S.m - W.peaDebut >= R.pea.ansExoneration * 12 && imp.pea5 !== null) return imp.pea5;
    return imp.cto;
  }
  function devisVente(S, W, id, env, montant, tout) {
    var pr = produit(S, id), a = abC(S), p = cours(S, id), l = W.lignes[cle(id, env)];
    var d = { ok: false, id: id, env: env, prix: p, qte: 0, brut: 0, frais: 0, pv: 0, impot: 0, recu: 0, taux: 0, msg: "" };
    if (!l || l.qte <= 0 || !p) { d.msg = "Vous ne détenez pas ce produit."; return d; }
    var q;
    if (tout) q = l.qte;
    else if (pr.type === "action") q = Math.min(l.qte, Math.ceil(Math.max(0, montant) / p - 1e-9));
    else q = Math.min(l.qte, Math.max(0, montant) / p);
    if (q <= 0) { d.msg = "Indiquez un montant."; return d; }
    if (l.qte - q < 1e-6) q = l.qte;
    d.qte = q; d.brut = q * p;
    if (pr.type === "action" || pr.type === "etf") d.frais = fraisCourtage(a, d.brut);
    var net = d.brut - d.frais, coutPart = l.cout * q / l.qte;
    d.pv = net - coutPart;
    d.taux = tauxImpotVente(S, W, env);
    d.impot = Math.max(0, d.pv) * d.taux / 100;
    d.recu = net - d.impot;
    d.perf = coutPart > 0 ? (d.brut / coutPart - 1) : 0;
    var imp = Marche.impot(U.annee(a));
    if (env === "CTO" && peaExiste(S) && imp.pea5 !== null) d.siPEA = Math.max(0, d.pv) * imp.pea5 / 100;
    if (env === "PEA") d.siCTO = Math.max(0, d.pv) * imp.cto / 100;
    d.ok = true;
    return d;
  }
  function vendre(S, W, id, env, montant, opts) {
    opts = opts || {};
    var d = devisVente(S, W, id, env, montant, opts.tout);
    if (!d.ok) return d;
    var k = cle(id, env), l = W.lignes[k], coutPart = l.cout * d.qte / l.qte;
    l.qte -= d.qte; l.cout -= coutPart;
    if (l.qte < 1e-9) delete W.lignes[k];
    W.cc += d.recu;
    W.frais += d.frais;
    W.impots += d.impot;
    if (S.joueur === W) {
      if (!opts.auto) S.stats.ordres++;
      S.stats.frais += d.frais;
      S.stats.impots += d.impot;
      if (env === "CTO" && peaExiste(S) && eligiblePEA(produit(S, id))) S.stats.impotCTOavecPEA += d.impot;
      if (opts.forcee) {
        S.stats.ventesForcees.push({ m: S.m, id: id, perf: d.perf, evt: opts.evt || "" });
      } else {
        S.panique.forEach(function (w) {
          if (S.m >= w.m0 && S.m <= w.fin) {
            w.vendu += d.brut;
            if (!w.panique && w.v0 > 0 && w.vendu > 0.5 * w.v0) {
              w.panique = true;
              S.stats.paniques.push({ m: S.m, id: w.id });
            }
          }
        });
      }
      enregistrerHist(S);
    }
    return d;
  }
  /* « Tout vendre » / « Encaisser » : actions, SICAV et ETF (pas le livret ni l'emprunt) */
  function devisVenteTotale(S, W) {
    var r = { lignes: [], brut: 0, frais: 0, impot: 0, recu: 0 };
    lignes(W).forEach(function (l) {
      var d = devisVente(S, W, l.id, l.env, 0, true);
      if (d.ok) { r.lignes.push(d); r.brut += d.brut; r.frais += d.frais; r.impot += d.impot; r.recu += d.recu; }
    });
    return r;
  }
  function venteTotale(S, W, opts) {
    var r = devisVenteTotale(S, W);
    r.lignes.forEach(function (d) { vendre(S, W, d.id, d.env, 0, { tout: true, auto: opts && opts.sansOrdre }); });
    return r;
  }

  /* ---------------- Livret A et emprunt d'État ---------------- */
  function deposerLivret(S, W, montant) {
    var a = abC(S), plaf = Marche.plafondLivret(a);
    montant = Math.max(0, montant);
    if (montant <= 0) return { ok: false, msg: "Indiquez un montant." };
    if (W.livret + montant > plaf + EPS) {
      return { ok: false, refus: "plafond", max: Math.max(0, plaf - W.livret),
        msg: "Refusé : le Livret A est plafonné à " + U.txt(plaf, a) + ". Vous pouvez encore déposer " + U.txt(Math.max(0, plaf - W.livret), a) + "." };
    }
    W.cc -= montant; W.livret += montant;
    if (S.joueur === W) enregistrerHist(S);
    return { ok: true, montant: montant };
  }
  function retirerLivret(S, W, montant) {
    montant = Math.min(Math.max(0, montant), W.livret);
    if (montant <= 0) return { ok: false, msg: "Rien à retirer." };
    W.livret -= montant; W.cc += montant;
    if (S.joueur === W) enregistrerHist(S);
    return { ok: true, montant: montant };
  }
  function souscrireEmprunt(S, W, montant) {
    montant = Math.max(0, montant);
    if (montant < 1) return { ok: false, msg: "Indiquez un montant." };
    var taux = Marche.tauxLong(U.annee(abC(S)));
    W.tranches.push({ montant: montant, taux: taux, m0: S.m });
    W.cc -= montant;
    if (S.joueur === W) enregistrerHist(S);
    return { ok: true, montant: montant, taux: taux };
  }
  /* Revente au nominal, en commençant par les tranches au taux le plus faible */
  function revendreEmprunt(S, W, montant) {
    var reste = Math.min(Math.max(0, montant), totalEmprunt(W));
    if (reste <= 0) return { ok: false, msg: "Rien à revendre." };
    var fait = reste;
    W.tranches.sort(function (x, y) { return x.taux - y.taux; });
    for (var i = 0; i < W.tranches.length && reste > EPS; i++) {
      var t = W.tranches[i], pris = Math.min(t.montant, reste);
      t.montant -= pris; reste -= pris;
    }
    W.tranches = W.tranches.filter(function (t) { return t.montant > EPS; });
    W.cc += fait;
    if (S.joueur === W) enregistrerHist(S);
    return { ok: true, montant: fait };
  }

  /* ---------------- Versements automatiques ---------------- */
  function programmerAuto(S, id, env, montant) {
    S.auto = S.auto.filter(function (x) { return x.id !== id; });
    if (montant > 0) S.auto.push({ id: id, env: env || "CTO", montant: montant, depuis: S.m });
  }
  function autoDe(S, id) {
    for (var i = 0; i < S.auto.length; i++) if (S.auto[i].id === id) return S.auto[i];
    return null;
  }
  function totalAutos(S) { return S.auto.reduce(function (s, x) { return s + x.montant; }, 0); }
  function executerAutos(S, res) {
    var J = S.joueur, a = abC(S);
    S.auto.forEach(function (x) {
      var pr = produit(S, x.id), nom = pr ? pr.court : x.id;
      if (J.cc < x.montant - EPS) {
        res.notifs.push({ type: "alerte", titre: "Versement sauté", texte: "Compte insuffisant : le versement automatique sur " + nom + " n'a pas été fait ce mois-ci.", cls: "perte" });
        return;
      }
      var r;
      if (x.id === "livret") r = deposerLivret(S, J, x.montant);
      else if (x.id === "emprunt") r = souscrireEmprunt(S, J, x.montant);
      else r = acheter(S, J, x.id, x.env, x.montant, { auto: true });
      if (!r.ok) {
        res.notifs.push({ type: "alerte", titre: "Versement sauté", texte: nom + " : " + r.msg, cls: "perte" });
        return;
      }
      if (pr && (pr.type === "sicav" || pr.type === "etf")) S.stats.autoMois[x.id] = (S.stats.autoMois[x.id] || 0) + 1;
    });
  }

  /* ---------------- Création d'une partie ---------------- */
  function tirerCalendrier(cfg, P) {
    var cal = [];
    if (cfg.sansVie) return cal;
    var rng = U.rng(cfg.graineVie);
    var age0 = SAL.profils[cfg.profil].age, ids = Object.keys(V.types);
    var dernierChomage = -9999, enfants = 0, loyerMult = 1;
    /* Épargne possible restante, en points de salaire, après loyer majoré et enfants */
    function margeBudget(an, mult, nbEnfants) {
      var pire = Infinity;
      for (var k = an; k < 15; k++) { // la décennie suivante peut réduire l'épargne possible
        var p = paramsDepenses(P.debut + k), partLoyer = p.loyer + SAL.ajustLoyer[cfg.profil];
        pire = Math.min(pire, p.epargne[cfg.profil] - partLoyer * (mult - 1) - nbEnfants * V.naissanceSupp * 100);
      }
      return pire;
    }
    for (var an = 0; an < 15; an++) {
      var age = age0 + an, liste = [];
      ids.forEach(function (id) {
        var t = V.types[id], f = (id === "augmentation" && cfg.profil === "cadre") ? t.freqCadre : t.freq;
        if (rng.u() < f) liste.push(id);
      });
      // contraintes
      liste = liste.filter(function (id) {
        if (id === "naissance") {
          // décision 05 : pas de naissance qui rendrait le budget mensuel négatif
          return enfants < V.naissanceMax && age >= V.naissanceAge[0] && age <= V.naissanceAge[1] &&
            margeBudget(an, loyerMult, enfants + 1) >= 0;
        }
        return true;
      });
      if (liste.length === 0) {
        var pool = ["prime", "voiture", "electromenager", "medical", "augmentation", "jeu", "demenagement"];
        liste.push(pool[Math.floor(rng.u() * pool.length)]);
      }
      // mélange puis 3 au maximum
      for (var i = liste.length - 1; i > 0; i--) {
        var j = Math.floor(rng.u() * (i + 1)), tmp = liste[i]; liste[i] = liste[j]; liste[j] = tmp;
      }
      liste = liste.slice(0, V.parAn.max);
      // le tout premier mois reste calme (tutoriel)
      var moisLibres = an === 0 ? [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] : [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
      liste.forEach(function (id) {
        var k = Math.floor(rng.u() * moisLibres.length), mo = moisLibres.splice(k, 1)[0];
        var r1 = rng.u(), r2 = rng.u(), r3 = rng.u(); // toujours 3 tirages : séquence stable
        var m = an * 12 + mo, t = V.types[id], e = { m: m, type: id };
        if (id === "chomage") {
          if (m - dernierChomage < V.ecartChomageMois) return;
          dernierChomage = m;
          e.duree = t.duree[0] + Math.floor(r1 * (t.duree[1] - t.duree[0] + 1));
        } else if (t.effet === "cout") {
          e.M = t.coutM[0] + r1 * (t.coutM[1] - t.coutM[0]);
        } else if (id === "escargots") {
          e.M = t.miseM[0] + r1 * (t.miseM[1] - t.miseM[0]);
          e.perdu = r2 < V.escargots.perte;
          e.delai = V.escargots.delai[0] + Math.floor(r3 * (V.escargots.delai[1] - V.escargots.delai[0] + 1));
        } else if (id === "heritage") {
          e.SMN = t.gainSMN[0] + r1 * (t.gainSMN[1] - t.gainSMN[0]);
        } else if (id === "jeu") {
          if (r2 < t.grosLot.proba) e.SMN = t.grosLot.gainSMN[0] + r1 * (t.grosLot.gainSMN[1] - t.grosLot.gainSMN[0]);
          else e.M = t.gainM[0] + r1 * (t.gainM[1] - t.gainM[0]);
        } else if (t.effet === "gain") {
          e.M = t.gainM[0] + r1 * (t.gainM[1] - t.gainM[0]);
        } else if (id === "augmentation") {
          e.pct = t.pct[0] + Math.floor(r1 * (t.pct[1] - t.pct[0] + 1));
        } else if (id === "naissance") {
          enfants++;
        } else if (id === "demenagement") {
          e.depot = t.depotLoyers[0] + Math.floor(r1 * (t.depotLoyers[1] - t.depotLoyers[0] + 1));
          e.sens = r2 < 0.5 ? 1 : -1;
          // décision 05 : si un loyer plus cher rendait le budget négatif, on déménage vers moins cher
          if (e.sens > 0 && margeBudget(an, loyerMult * (1 + t.loyerVar), enfants) < 3) e.sens = -1;
          loyerMult *= 1 + e.sens * t.loyerVar;
        }
        cal.push(e);
      });
    }
    // Coïncidence forcée : une panne de voiture le mois suivant un événement de marché « − », après le 12e mois
    var krachs = P.evenements.filter(function (ev) {
      return ev.type === "-" && U.parseD(ev.d) - U.ab(P.debut, 1) > V.coincidenceApresMois;
    });
    if (krachs.length) {
      var ev = krachs[Math.floor(rng.u() * krachs.length)], mK = U.parseD(ev.d) - U.ab(P.debut, 1);
      var tv = V.types.voiture;
      cal.push({ m: Math.min(179, mK + 1), type: "voiture", M: tv.coutM[0] + rng.u() * (tv.coutM[1] - tv.coutM[0]), force: true });
    }
    // Prime scriptée du tutoriel (mois 8)
    cal.push({ m: V.primeTutorielMois, type: "prime", M: 0.6, tuto: true });
    cal.sort(function (x, y) { return x.m - y.m; });
    return cal;
  }

  function nouvellePartie(cfg) {
    var mk = Marche.generer(cfg.periode), P = mk.P;
    var S = {
      version: 1,
      periode: cfg.periode, profil: cfg.profil, objectif: cfg.objectif || "inflation",
      graineVie: cfg.graineVie >>> 0, tutoriel: !!cfg.tutoriel, sansVie: !!cfg.sansVie,
      abDebut: mk.abDebut, m: 0,
      vie: { salaireBase: valeurTable(cfg.profil, P.debut), chomageFin: -1, enfants: 0, loyerMult: 1, vieSupp: 0 },
      joueur: nouveauPortefeuille(),
      temoins: { matelas: nouveauPortefeuille(), livret: nouveauPortefeuille(), indice: nouveauPortefeuille() },
      calendrier: [], attente: [], file: [], modale: null, auto: [], choix: [], panique: [],
      hist: { j: [], mis: [], matelas: [], livret: [], indice: [] },
      epargneNette: 0, bagMis: 0,
      annee: { patr0: 0, interets: 0, dividendes: 0, coupons: 0 },
      decouvertMois: 0, fin: null, objectifAtteintM: -1, partieLibre: false,
      marqueurs: [], nouveaux: {}, journal: [], notionsVues: {},
      flags: {},
      stats: { ordres: 0, frais: 0, impots: 0, agios: 0, impotCTOavecPEA: 0, paniques: [], ventesForcees: [],
        coussin: null, escargots: null, autoMois: {}, sommePartCC: 0, sommePartLivret: 0, nbMois: 0,
        maxPartAction: 0, maxPartActionId: null, refPrix: {}, oeufs: null, cousinVentes: 0, faillieM: -1 }
    };
    S.calendrier = tirerCalendrier(cfg, P);
    S.cibles = calculerCibles(cfg);
    var res = entrerMois(S, true);
    S.annee.patr0 = patrimoine(S, S.joueur);
    S.annee.bag0 = S.annee.patr0 / Marche.baguette(abC(S));
    return { S: S, res: res };
  }

  /* Capital de l'héritier : moitié sur le compte courant, moitié en 2 actions (sans frais) */
  function heritageDepart(S, capital) {
    var J = S.joueur, ids = mkt(S).P.heritage || [];
    var demi = capital / 2, part = ids.length ? demi / ids.length : 0;
    J.cc += capital - demi;
    ids.forEach(function (id) {
      var p = cours(S, id), q = Math.floor(part / p);
      if (q > 0) J.lignes[cle(id, "CTO")] = { id: id, env: "CTO", qte: q, cout: q * p, depuis: 0, grandPere: true };
      J.cc += part - q * p;
    });
    var T = S.temoins;
    [T.matelas, T.livret, T.indice].forEach(function (W) { W.cc += capital; });
    compterEpargne(S, capital, abC(S));
  }

  /* ---------------- Objectifs : simulation « Cousin sans événements » ---------------- */
  function simulerCousinSansEvenements(cfg) {
    var mk = Marche.generer(cfg.periode), P = mk.P;
    var C = nouveauPortefeuille();
    var X = { periode: cfg.periode, profil: cfg.profil, abDebut: mk.abDebut, m: 0, joueur: null,
      vie: { salaireBase: valeurTable(cfg.profil, P.debut), chomageFin: -1, enfants: 0, loyerMult: 1, vieSupp: 0 },
      temoins: { indice: C }, stats: { cousinVentes: 0 } };
    var vals = [];
    for (var m = 0; m < 180; m++) {
      X.m = m;
      var a = abC(X);
      if (m > 0) {
        // fin du mois précédent : intérêts du livret
        X.m = m - 1; finDeMoisPortefeuilles(X, [C], null); X.m = m;
        if (U.mois(a) === 1) X.vie.salaireBase *= smn(U.annee(a)) / smn(U.annee(a) - 1);
      }
      C.cc += X.vie.salaireBase - depenses(X, a).total;
      if (m === 0 && cfg.profil === "heritier") C.cc += valeurTable("capital", P.debut);
      allouerCousin(X, C);
      vals.push(patrimoine(X, C));
    }
    return vals;
  }
  function arrondiDevise(eur, a) {
    var dev = U.deviseAffichee(a);
    return U.versEuros(U.arrondi2(U.enDevise(eur, dev)), dev);
  }
  function calculerCibles(cfg) {
    var mk = Marche.generer(cfg.periode), sim = simulerCousinSansEvenements(cfg);
    var o = R.objectifs, mM = o.maison.ans * 12 - 1;
    return {
      maison: arrondiDevise(o.maison.coefCousin * sim[mM], mk.abDebut + mM),
      retraite: arrondiDevise(o.retraite.coefCousin * sim[179], mk.abDebut + 179),
      mLimite: { maison: mM, retraite: 179 }
    };
  }
  function cibleObjectif(S) { return S.objectif === "inflation" ? null : S.cibles[S.objectif]; }
  /* Progression de l'objectif : { pct, atteint, texte… } */
  function progressionObjectif(S) {
    var J = S.joueur, a = abC(S), patr = patrimoine(S, J);
    if (S.objectif === "inflation") {
      var pb = patr / Marche.baguette(a);
      return { pct: S.bagMis > 0 ? pb / S.bagMis : 1, patrBag: pb, misBag: S.bagMis, atteint: pb >= S.bagMis };
    }
    var c = S.cibles[S.objectif];
    return { pct: c > 0 ? patr / c : 1, cible: c, atteint: S.objectifAtteintM >= 0, mLimite: S.cibles.mLimite[S.objectif] };
  }

  /* ---------------- Témoins ---------------- */
  function fondsCousin(S) {
    var infos = mkt(S).infos;
    if (infos.etf && estDisponible(S, "etf")) return "etf";
    return infos.sicav ? "sicav" : "etf";
  }
  function allouerCousin(S, C) {
    var a = abC(S), plaf = Marche.plafondLivret(a);
    if (C.cc < -EPS) {
      var r = Math.min(C.livret, -C.cc); C.livret -= r; C.cc += r;
      if (C.cc < -EPS) vendreFondsCousin(S, C);
      return;
    }
    var cible = Math.min(R.coussinMois * depenses(S, a).total, plaf);
    var d = Math.min(C.cc, Math.max(0, cible - C.livret));
    C.livret += d; C.cc -= d;
    if (C.cc <= EPS) return;
    var id = fondsCousin(S), pr = produit(S, id);
    if (pr.type === "etf") {
      var f = Marche.frais(a);
      if (C.cc < f.min / (f.taux / 100)) return; // il regroupe ses achats pour ne pas payer le minimum de frais
    }
    var env = (peaExiste(S) && C.peaVerse + C.cc <= Marche.plafondPEA(a)) ? "PEA" : "CTO";
    acheter(S, C, id, env, C.cc, { temoin: true });
  }
  function vendreFondsCousin(S, C) {
    var ls = lignes(C).sort(function (x, y) { return x.env === "CTO" ? -1 : 1; });
    for (var i = 0; i < ls.length && C.cc < -EPS; i++) {
      var l = ls[i], val = valeurLigne(S, l), besoin = -C.cc * 1.05 + 20;
      if (val <= besoin) vendre(S, C, l.id, l.env, 0, { tout: true });
      else vendre(S, C, l.id, l.env, besoin, {});
      S.stats.cousinVentes++;
    }
  }
  function allouerTemoins(S) {
    var a = abC(S), T = S.temoins, L = T.livret, plaf = Marche.plafondLivret(a);
    if (L.cc < -EPS) { var r = Math.min(L.livret, -L.cc); L.livret -= r; L.cc += r; }
    else if (L.cc > EPS) { var d = Math.min(L.cc, Math.max(0, plaf - L.livret)); L.livret += d; L.cc -= d; }
    allouerCousin(S, T.indice);
  }

  /* ---------------- Fin de mois : intérêts du livret (crédités le 31/12) ---------------- */
  function finDeMoisPortefeuilles(S, liste, res) {
    var a = abC(S), t = Marche.tauxLivret(a) / 100 / 12;
    liste.forEach(function (W) {
      W.livretInt += W.livret * t;
      if (U.mois(a) === 12) {
        var i = W.livretInt;
        W.livret += i; W.interetsTotal += i; W.livretInt = 0;
        if (res && W === S.joueur && i > 0.005) {
          S.annee.interets += i;
          res.notifs.push({ type: "interets", titre: "Intérêts du Livret A", montant: i, cls: "gain",
            texte: "Les intérêts de l'année " + U.annee(a) + " sont versés sur votre livret." });
        }
      }
    });
  }
  function tousPortefeuilles(S) { var T = S.temoins; return [S.joueur, T.matelas, T.livret, T.indice]; }

  /* ---------------- Le mois : ordre de traitement (03 §3.3) ---------------- */
  function notifier(S, res, n) {
    res.notifs.push(n);
  }
  function journaliser(S, texte) {
    S.journal.push({ m: S.m, texte: texte });
    if (S.journal.length > 50) S.journal.shift();
  }

  function entrerMois(S, initial) {
    var mk = mkt(S), P = mk.P, m = S.m, a = abC(S), y = U.annee(a);
    var J = S.joueur, T = S.temoins, tous = tousPortefeuilles(S);
    var res = { notifs: [], modale: null, fin: null, sauver: false, m: m };

    // 2. Revenus (indexation en janvier, chômage)
    if (!initial && U.mois(a) === 1) S.vie.salaireBase *= smn(y) / smn(y - 1);
    if (S.vie.chomageFin >= 0 && m >= S.vie.chomageFin) {
      S.vie.chomageFin = -1;
      notifier(S, res, { type: "vie", titre: V.retourEmploi.titre, texte: V.retourEmploi.texte, cls: "gain" });
    }
    var salaire = salaireDuMois(S), dep = depenses(S, a);
    // 3. Dépenses
    tous.forEach(function (W) { W.cc += salaire - dep.total; });
    compterEpargne(S, salaire - dep.total, a);
    if (initial && S.profil === "heritier") heritageDepart(S, valeurTable("capital", y));

    // 4. Versements automatiques
    executerAutos(S, res);

    // 5. Revenus des placements
    revenusPlacements(S, res);

    // 6. Agios et faillite
    if (J.cc < -EPS) {
      var ag = -J.cc * Marche.tauxAgios(y) / 100 / 12;
      J.cc -= ag; J.agios += ag; S.stats.agios += ag;
    }
    var seuil = -R.decouvertTolereM * S.vie.salaireBase;
    if (J.cc < seuil - EPS) S.decouvertMois++; else S.decouvertMois = 0;
    if (S.decouvertMois >= R.failliteMois) {
      S.fin = "faillite"; res.fin = "faillite"; S.stats.faillieM = m;
      allouerTemoins(S);
      enregistrerHist(S);
      return res;
    }

    // 7. Déblocages de produits datés
    P.produits.forEach(function (pr) {
      if (pr.dispo && U.parseD(pr.dispo) === a) {
        S.nouveaux[pr.id] = true;
        S.marqueurs.push({ m: m, type: "produit", ref: pr.id });
        notifier(S, res, { type: "nouveau", produit: pr.id, persistante: true, titre: "Nouveau · " + y,
          texte: pr.texteNouveau || (pr.nom + " est disponible."), cls: "neutre" });
        journaliser(S, "Nouveau : " + pr.nom);
      }
    });

    // 8. Événements : marché, contexte, vie
    P.evenements.forEach(function (ev) {
      if (U.parseD(ev.d) !== a) return;
      S.marqueurs.push({ m: m, type: "marche", ref: ev.id, signe: ev.type.charAt(0) });
      journaliser(S, ev.titre);
      if (ev.type === "-silencieux") {
        notifier(S, res, { type: "silencieux", titre: ev.titre, texte: ev.texte, persistante: true, cls: "perte" });
        return;
      }
      if (ev.type === "-") S.panique.push({ id: ev.id, m0: m, fin: m + 2, v0: valeurRisquee(S, J), vendu: 0, panique: false });
      S.file.push({ kind: "marche", id: ev.id, m: m, prio: 0 });
    });
    (P.contexte || []).forEach(function (c) {
      if (U.parseD(c.d) !== a) return;
      if (c.type === "euro") { S.file.push({ kind: "euro", m: m, prio: 2 }); return; }
      notifier(S, res, { type: "info", titre: c.titre, texte: c.texte, cls: "neutre" });
      journaliser(S, c.titre);
    });
    S.attente = S.attente.filter(function (x) {
      if (x.m !== m) return true;
      var t = x.perdu ? V.escargotsPerdu : V.escargotsGagne;
      if (x.perdu) S.stats.escargots = "perdu";
      else { J.cc += x.mise * V.escargots.gain; S.stats.escargots = "gagne"; }
      notifier(S, res, { type: "vie", persistante: true, titre: t.titre, cls: x.perdu ? "perte" : "gain",
        texte: U.gabarit(t.texte, { montant: U.txt(x.perdu ? x.mise : x.mise * V.escargots.gain, a) }),
        montant: x.perdu ? undefined : x.mise * V.escargots.gain });
      return false;
    });
    S.calendrier.forEach(function (e, idx) { if (e.m === m) declencherVie(S, idx, res); });

    // Les témoins placent leur excédent
    allouerTemoins(S);

    // 9. Rappel à 12 mois
    S.choix.forEach(function (c) {
      if (c.m + 12 !== m) return;
      notifier(S, res, { type: "rappel", persistante: true, titre: "Il y a un an…", texte: texteRappel(S, c), cls: "neutre", evt: c.id });
    });

    // 10. Janvier : bilan annuel et sauvegarde
    if (!initial && U.mois(a) === 1) {
      var patrA = patrimoine(S, J), inf = Marche.inflation(y - 1) / 100;
      var vp = S.annee.patr0 > 0 ? patrA / S.annee.patr0 - 1 : 0;
      var bagA = patrA / Marche.baguette(a);
      notifier(S, res, { type: "bilan", persistante: true, titre: "Votre année " + (y - 1), cls: "neutre",
        bilan: { annee: y - 1, varPatr: vp, inflation: inf, pouvoir: (1 + vp) / (1 + inf) - 1,
          patr0: S.annee.patr0, patrA: patrA, pctSignificatif: S.annee.patr0 >= S.vie.salaireBase,
          baguettes: bagA - (S.annee.bag0 || 0), interets: S.annee.interets, dividendes: S.annee.dividendes,
          coupons: S.annee.coupons } });
      S.annee = { patr0: patrA, bag0: bagA, interets: 0, dividendes: 0, coupons: 0 };
      if (y % 10 === 0 && window.DATA_TEXTES.decennies[y]) {
        notifier(S, res, { type: "decennie", titre: window.DATA_TEXTES.decennies[y], texte: "La couleur du jeu change avec l'époque.", cls: "neutre" });
      }
      res.sauver = true;
    }
    if (m === 168) notifier(S, res, { type: "info", titre: "Dernière année !", texte: "Plus que 12 mois avant le bilan.", cls: "neutre" });

    // Statistiques du mois et historique
    statsMois(S);
    enregistrerHist(S);

    // 11. Objectif atteint plus tôt
    if ((S.objectif === "maison" || S.objectif === "retraite") && S.objectifAtteintM < 0 &&
        m <= S.cibles.mLimite[S.objectif] && patrimoine(S, J) >= S.cibles[S.objectif]) {
      S.objectifAtteintM = m;
      S.file.push({ kind: "objectif", m: m, prio: 0.5 });
    }
    var po = progressionObjectif(S);
    if (S.objectif !== "inflation" && !S.flags.objProche && S.objectifAtteintM < 0 && po.pct >= 0.9 && po.pct < 1 && m > 12) {
      S.flags.objProche = true;
      notifier(S, res, { type: "info", titre: "Objectif en vue !", texte: "Plus que " + Math.max(1, Math.round((1 - po.pct) * 100)) + " % !", cls: "gain" });
    }

    // Au plus une modale par mois : priorité marché > vie > euro
    if (!S.modale && S.file.length) {
      S.file.sort(function (x, z) { return x.prio - z.prio || x.m - z.m; });
      S.modale = S.file.shift();
      res.modale = S.modale;
    }
    return res;
  }

  function revenusPlacements(S, res) {
    var J = S.joueur, a = abC(S), y = U.annee(a), imp = Marche.impot(y);
    // Coupons et remboursements de l'emprunt d'État
    J.tranches.forEach(function (t) {
      var k = S.m - t.m0;
      if (k > 0 && k % 12 === 0) {
        var c = t.montant * t.taux / 100, tax = c * imp.cto / 100;
        J.cc += c - tax; J.impots += tax; S.stats.impots += tax; S.annee.coupons += c - tax;
        if (c > 0.005) notifier(S, res, { type: "coupon", titre: "Coupon de l'emprunt d'État", montant: c - tax, cls: "gain",
          texte: "Intérêts de votre emprunt à " + U.nombre(t.taux, 1) + " %, impôt de " + U.txt(tax, a) + " déduit." });
      }
      if (k >= 120) {
        J.cc += t.montant; t.rembourse = true;
        notifier(S, res, { type: "info", titre: "Emprunt remboursé", texte: "Votre emprunt d'État arrive à échéance : " + U.txt(t.montant, a) + " vous sont rendus.", cls: "gain" });
      }
    });
    J.tranches = J.tranches.filter(function (t) { return !t.rembourse; });
    // Dividendes en mai
    if (U.mois(a) !== 5) return;
    var total = 0, impT = 0;
    lignes(J).forEach(function (l) {
      var pr = produit(S, l.id);
      if (pr.type !== "action") return;
      var rdt = Marche.rdtDividende(y) + (pr.ecartDiv || 0);
      if (pr.divNul && pr.divNul.indexOf(y) >= 0) rdt = 0;
      var d = valeurLigne(S, l) * Math.max(0, rdt) / 100;
      var tax = l.env === "PEA" ? 0 : d * imp.cto / 100;
      if (l.env === "CTO" && peaExiste(S)) S.stats.impotCTOavecPEA += tax;
      total += d - tax; impT += tax;
    });
    if (total > 0.005) {
      J.cc += total; J.impots += impT; S.stats.impots += impT; S.annee.dividendes += total;
      var premier = !S.flags.premierDividende; S.flags.premierDividende = true;
      notifier(S, res, { type: "dividende", titre: "Dividendes reçus", montant: total, premier: premier, cls: "gain",
        texte: (premier ? "L'entreprise partage ses bénéfices : c'est un dividende. " : "") +
          (impT > 0.005 ? "Impôt de " + U.txt(impT, a) + " déduit." : "Versés sur votre compte courant.") });
    }
  }

  /* ---------------- Événements de vie ---------------- */
  function montantVie(S, e) {
    var M = S.vie.salaireBase, a = abC(S), t = V.types[e.type];
    if (e.SMN) return e.SMN * smn(U.annee(a));
    if (e.type === "demenagement") return t.coutM * M + e.depot * depenses(S, a).loyer;
    return (e.M || 0) * M;
  }
  function texteVie(S, e) {
    var t = V.types[e.type], a = abC(S);
    return U.gabarit(t.texte, { montant: U.txt(e.montant || 0, a), duree: e.duree, pct: e.pct,
      sens: e.sens > 0 ? "plus cher" : "moins cher" });
  }
  function declencherVie(S, idx, res) {
    var e = S.calendrier[idx], t = V.types[e.type], J = S.joueur, T = S.temoins, a = abC(S);
    var M = S.vie.salaireBase, temoins = [T.matelas, T.livret, T.indice];
    e.montant = montantVie(S, e);
    S.marqueurs.push({ m: S.m, type: "vie", ref: idx });
    journaliser(S, t.titre);
    var modale = false;
    switch (t.effet) {
      case "cout":
        temoins.forEach(function (W) { W.cc -= e.montant; });
        compterEpargne(S, -e.montant, a);
        modale = e.montant > M + EPS || J.cc < e.montant;
        break;
      case "gain":
        temoins.forEach(function (W) { W.cc += e.montant; });
        compterEpargne(S, e.montant, a);
        modale = e.montant > M + EPS || e.type === "heritage" || !!e.tuto;
        break;
      case "demenagement":
        temoins.forEach(function (W) { W.cc -= e.montant; });
        compterEpargne(S, -e.montant, a);
        S.vie.loyerMult *= 1 + e.sens * t.loyerVar;
        modale = true;
        break;
      case "chomage":
        S.vie.chomageFin = S.m + 1 + e.duree; modale = true; break;
      case "augmentation":
        S.vie.salaireBase *= 1 + e.pct / 100; modale = true; break;
      case "naissance":
        S.vie.vieSupp += V.naissanceSupp; S.vie.enfants++; modale = true; break;
      case "escargots":
        modale = true; break;
    }
    e.declenche = true;
    if (modale) {
      S.file.push({ kind: "vie", idx: idx, m: S.m, prio: 1 });
    } else {
      // Notification sans pause : effet immédiat
      if (t.effet === "cout") { payerCoutJoueur(S, e); }
      else if (t.effet === "gain") { J.cc += e.montant; }
      e.resolu = true;
      notifier(S, res, { type: "vie", titre: t.titre, texte: texteVie(S, e), montant: t.effet === "gain" ? e.montant : -e.montant,
        cls: t.effet === "gain" ? "gain" : "perte", picto: t.picto, evtVie: idx });
    }
  }
  function payerCoutJoueur(S, e) {
    var J = S.joueur, M = S.vie.salaireBase;
    var sansVenteForcee = !S.stats.ventesForcees.some(function (v) { return v.m === S.m && v.evt === V.types[e.type].titre; });
    var assez = J.cc >= e.montant - EPS;
    J.cc -= e.montant;
    if (assez && sansVenteForcee && e.montant >= 0.5 * M && !S.stats.coussin) {
      S.stats.coussin = { m: S.m, evt: V.types[e.type].titre };
    }
    enregistrerHist(S);
  }
  /* Résolution d'une modale de vie. choix : "payer", "decouvert", "encaisser", "fonce", "non", "ok" */
  function resoudreVie(S, item, choix) {
    var e = S.calendrier[item.idx], t = V.types[e.type], J = S.joueur, a = abC(S);
    e.resolu = true; e.choix = choix;
    if (t.effet === "cout" || t.effet === "demenagement") payerCoutJoueur(S, e);
    else if (t.effet === "gain") { J.cc += e.montant; enregistrerHist(S); }
    else if (t.effet === "escargots") {
      var mise = (e.M || 1) * S.vie.salaireBase;
      e.mise = mise;
      if (choix === "fonce") {
        J.cc -= mise;
        S.stats.escargots = "accepte";
        S.attente.push({ m: Math.min(179, S.m + e.delai), perdu: e.perdu, mise: mise });
        enregistrerHist(S);
      }
    }
    if (S.modale === item) S.modale = null;
  }

  /* ---------------- Événements de marché ---------------- */
  function evenement(S, id) {
    var l = mkt(S).P.evenements;
    for (var i = 0; i < l.length; i++) if (l[i].id === id) return l[i];
    return null;
  }
  /* Impact sur les placements risqués du joueur : mêmes quantités, prix d'il y a « fenetre » mois */
  function impactMarche(S, ev) {
    var J = S.joueur, f = ev.fenetre || 1, m0 = Math.max(-1, S.m - f), v0 = 0, v1 = 0;
    lignes(J).forEach(function (l) {
      var p0 = cours(S, l.id, m0) || cours(S, l.id), p1 = cours(S, l.id);
      v0 += l.qte * p0; v1 += l.qte * p1;
    });
    return { v0: v0, v1: v1, diff: v1 - v0, pct: v0 > 0 ? v1 / v0 - 1 : 0, depuis: S.abDebut + m0,
      indicePct: Marche.indice(mkt(S), S.m) / Marche.indice(mkt(S), m0) - 1 };
  }
  /* Jeu de choix selon le type (03 §6.1) */
  function choixMarche(S, ev) {
    var detient = valeurRisquee(S, S.joueur) > EPS;
    if (ev.type === "-") {
      if (!detient) return [
        { id: "ecart", titre: "Rester à l'écart", sous: "Garder mon argent" },
        { id: "soldes", titre: "Profiter des soldes", sous: "Acheter pendant la baisse" }];
      return [
        { id: "vendre", titre: "Tout vendre", sous: "Sauver ce qui reste" },
        { id: "rien", titre: "Ne rien faire", sous: "Attendre l'éclaircie" },
        { id: "renforcer", titre: "Renforcer", sous: "Acheter en solde" }];
    }
    if (ev.type === "+opportunite") return [
      { id: "souscrire", titre: ev.produit === "etf" ? "Acheter" : "Souscrire", sous: "Ouvrir le marché" },
      { id: "rien", titre: "Ne rien faire", sous: "Passer mon tour" }];
    return [
      { id: "encaisser", titre: "Encaisser mes gains", sous: detient ? "Vendre mes actions" : "Rien à encaisser", desactive: !detient },
      { id: "rien", titre: "Ne rien faire", sous: "Garder le cap" },
      { id: "suivre", titre: "Suivre la foule", sous: "Acheter aussi" }];
  }
  /* Produit sur lequel ouvrir le tiroir après « Renforcer », « Suivre la foule », « Souscrire » */
  function produitCible(S, ev, choix) {
    if (ev.produit && estDisponible(S, ev.produit)) return ev.produit;
    var J = S.joueur, best = null, bestV = null;
    lignes(J).forEach(function (l) {
      var p0 = cours(S, l.id, S.m - (ev.fenetre || 1)), p1 = cours(S, l.id);
      if (!p0 || !p1) return;
      var v = p1 / p0 - 1;
      if (best === null || (choix === "renforcer" ? v < bestV : v > bestV)) { best = l.id; bestV = v; }
    });
    if (best) return best;
    return estDisponible(S, "etf") && mkt(S).infos.etf ? "etf" : (mkt(S).infos.sicav ? "sicav" : produitsDisponibles(S)[2]);
  }
  function resoudreMarche(S, item, choix) {
    var ev = evenement(S, item.id), J = S.joueur, r = null;
    S.choix.push({ id: ev.id, m: item.m, choix: choix, indice: Marche.indice(mkt(S), item.m), titre: ev.titre, type: ev.type });
    if (choix === "vendre" || choix === "encaisser") {
      if (ev.type === "-") {
        S.panique.forEach(function (w) {
          if (w.id === ev.id && !w.panique) { w.panique = true; S.stats.paniques.push({ m: S.m, id: ev.id, toutVendu: true }); }
        });
      }
      r = venteTotale(S, J, {});
    }
    if (S.modale === item) S.modale = null;
    return r;
  }
  function texteRappel(S, c) {
    var mk = mkt(S), v = Marche.indice(mk, c.m + 12) / c.indice - 1, a = abC(S);
    var actions = { vendre: "tout vendu", encaisser: "encaissé vos gains", rien: "gardé le cap", renforcer: "acheté",
      suivre: "suivi la foule", souscrire: "eu l'occasion d'acheter", soldes: "eu l'occasion d'acheter", ecart: "choisi de rester à l'écart" };
    var t = U.dateTxt(a).replace(/^./, function (x) { return x.toUpperCase(); }) +
      ". Il y a un an, pendant « " + c.titre + " », vous avez " + (actions[c.choix] || "choisi") + ". Depuis, " +
      Marche.nomIndice(a) + " a fait " + U.pct(v) + ".";
    var vendu = c.choix === "vendre" || c.choix === "encaisser", achat = ["renforcer", "suivre", "souscrire", "soldes"].indexOf(c.choix) >= 0;
    if (vendu) t += v > 0 ? " Rester investi aurait payé." : " Cette fois, vendre vous a protégé.";
    else if (achat) t += v > 0 ? " Acheter à ce moment-là a payé." : " Acheter si tôt n'a pas encore payé.";
    else t += v > 0 ? " Garder son calme a payé." : " La patience est parfois longue.";
    return t;
  }

  /* ---------------- Statistiques et historique ---------------- */
  function statsMois(S) {
    var J = S.joueur, st = S.stats, patr = patrimoine(S, J);
    if (patr > EPS) {
      st.sommePartCC += Math.max(0, J.cc) / patr;
      st.sommePartLivret += J.livret / patr;
      st.nbMois++;
      lignes(J).forEach(function (l) {
        var part = valeurLigne(S, l) / patr, p = cours(S, l.id), pr = produit(S, l.id);
        if (pr.type === "action" && part > st.maxPartAction) { st.maxPartAction = part; st.maxPartActionId = l.id; }
        if (part > 0.6) st.refPrix[l.id] = Math.max(st.refPrix[l.id] || 0, p);
      });
    }
    lignes(J).forEach(function (l) {
      var ref = st.refPrix[l.id], p = cours(S, l.id);
      if (ref && p < 0.5 * ref && !st.oeufs) st.oeufs = { m: S.m, id: l.id };
    });
  }
  function enregistrerHist(S) {
    if (!S.hist) return;
    var m = S.m, T = S.temoins;
    S.hist.j[m] = patrimoine(S, S.joueur);
    S.hist.mis[m] = S.epargneNette;
    S.hist.matelas[m] = patrimoine(S, T.matelas);
    S.hist.livret[m] = patrimoine(S, T.livret);
    S.hist.indice[m] = patrimoine(S, T.indice);
  }

  /* ---------------- Passage au mois suivant ---------------- */
  function avancer(S) {
    if (S.fin || S.modale) return { notifs: [], modale: S.modale, fin: S.fin };
    var res0 = { notifs: [] };
    finDeMoisPortefeuilles(S, tousPortefeuilles(S), res0);
    if (S.m >= 179) {
      allouerTemoins(S);
      enregistrerHist(S);
      S.fin = "fin";
      return { notifs: res0.notifs, modale: null, fin: "fin", m: S.m };
    }
    S.m++;
    var res = entrerMois(S, false);
    res.notifs = res0.notifs.concat(res.notifs);
    return res;
  }
  function abandonner(S) { S.fin = S.fin || "abandon"; }

  /* Résolution automatique (tests et mode accéléré) */
  function resolutionAuto(S, item) {
    if (!item) return;
    if (item.kind === "marche") resoudreMarche(S, item, "rien");
    else if (item.kind === "vie") {
      var e = S.calendrier[item.idx], t = V.types[e.type];
      resoudreVie(S, item, t.effet === "escargots" ? "non" : t.effet === "gain" ? "encaisser" : "payer");
    } else {
      if (item.kind === "objectif") S.partieLibre = true;
      S.modale = null;
    }
  }
  /* Reprend la file : si une modale est en attente sans être affichée (chargement), on la renvoie */
  function fermerModaleSimple(S) { S.modale = null; }

  return {
    COMMUNS: COMMUNS,
    produit: produit, cours: cours, estRisque: estRisque, eligiblePEA: eligiblePEA, estDisponible: estDisponible,
    peaExiste: peaExiste, produitsDisponibles: produitsDisponibles, abC: abC, mkt: mkt,
    valeurTable: valeurTable, smn: smn, depenses: depenses, salaireDuMois: salaireDuMois,
    lignes: lignes, valeurLigne: valeurLigne, totalEmprunt: totalEmprunt, valeurRisquee: valeurRisquee,
    patrimoine: patrimoine, valeurProduit: valeurProduit, placePEA: placePEA,
    fraisCourtage: fraisCourtage, devisAchat: devisAchat, acheter: acheter, tauxImpotVente: tauxImpotVente, devisVente: devisVente, vendre: vendre,
    devisVenteTotale: devisVenteTotale, venteTotale: venteTotale,
    deposerLivret: deposerLivret, retirerLivret: retirerLivret, souscrireEmprunt: souscrireEmprunt,
    revendreEmprunt: revendreEmprunt, programmerAuto: programmerAuto, autoDe: autoDe, totalAutos: totalAutos,
    tirerCalendrier: tirerCalendrier, nouvellePartie: nouvellePartie, simulerCousinSansEvenements: simulerCousinSansEvenements,
    calculerCibles: calculerCibles, cibleObjectif: cibleObjectif, progressionObjectif: progressionObjectif,
    texteVie: texteVie, resoudreVie: resoudreVie, payerCoutJoueur: payerCoutJoueur,
    evenement: evenement, impactMarche: impactMarche, choixMarche: choixMarche, produitCible: produitCible,
    resoudreMarche: resoudreMarche, texteRappel: texteRappel,
    enregistrerHist: enregistrerHist, avancer: avancer, abandonner: abandonner, resolutionAuto: resolutionAuto,
    fermerModaleSimple: fermerModaleSimple, journaliser: journaliser
  };
})();
