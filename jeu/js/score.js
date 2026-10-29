/* Score du bilan (03 §7.9) : étoiles, titre, leçons, classement des témoins. */
var Score = (function () {
  "use strict";

  function moyenne(somme, n) { return n > 0 ? somme / n : 0; }
  function nomProduit(S, id) { var p = Moteur.produit(S, id); return p ? p.nom : id; }
  function varIndice(S, m0, k) {
    var mk = Moteur.mkt(S);
    if (m0 + k > S.m) return "(au-delà de la fin de la partie)";
    return U.pct(Marche.indice(mk, m0 + k) / Marche.indice(mk, m0) - 1);
  }
  function titreEvt(S, id) { var ev = Moteur.evenement(S, id); return ev ? ev.titre : ""; }

  function bilan(S) {
    var J = S.joueur, T = S.temoins, a = Moteur.abC(S), st = S.stats;
    var nominal = {
      vous: Moteur.patrimoine(S, J), matelas: Moteur.patrimoine(S, T.matelas),
      livret: Moteur.patrimoine(S, T.livret), indice: Moteur.patrimoine(S, T.indice)
    };
    var auj = {}, bag = {};
    Object.keys(nominal).forEach(function (k) {
      auj[k] = Marche.eurosAujourdhui(nominal[k], a);
      bag[k] = nominal[k] / Marche.baguette(a);
    });
    var classement = Object.keys(nominal).map(function (k) { return { id: k, valeur: auj[k] }; })
      .sort(function (x, y) { return y.valeur - x.valeur; });

    var po = Moteur.progressionObjectif(S);
    var atteint = S.objectif === "inflation" ? po.atteint : S.objectifAtteintM >= 0;
    if (S.fin === "faillite") atteint = false;
    var battu = {
      matelas: nominal.vous > nominal.matelas, livret: nominal.vous > nominal.livret, indice: nominal.vous > nominal.indice
    };
    var nbBattus = (battu.matelas ? 1 : 0) + (battu.livret ? 1 : 0) + (battu.indice ? 1 : 0);
    var DT = window.DATA_TEMOINS;
    var etoiles = [
      { ok: atteint, regle: "Objectif atteint : " + window.DATA_REGLES.objectifs[S.objectif].libelle + "." },
      { ok: battu.matelas, regle: "Battre " + DT.matelas.nom + " (" + DT.matelas.regle.toLowerCase() + ")" },
      { ok: battu.livret, regle: "Battre " + DT.livret.nom + " (" + DT.livret.regle.toLowerCase() + ")" },
      { ok: battu.indice, regle: "Battre " + DT.indice.nom + " (" + DT.indice.regle.toLowerCase() + ")" },
      { ok: st.paniques.length === 0, regle: "Sang-froid : ne jamais vendre en panique (« Tout vendre » pendant une baisse, ou vendre plus de la moitié de ses actions, SICAV et ETF dans le mois d'une baisse ou les 2 mois suivants)." }
    ];

    var ctx = {
      faillite: S.fin === "faillite", atteint: atteint, nbBattus: nbBattus,
      partCC: moyenne(st.sommePartCC, st.nbMois), partLivret: moyenne(st.sommePartLivret, st.nbMois),
      ordresParAn: st.ordres / Math.max(1, (S.m + 1) / 12)
    };
    var conditions = {
      faillite: function () { return ctx.faillite; },
      panique: function () { return st.paniques.length >= 2; },
      escargots: function () { return st.escargots === "perdu"; },
      rentier: function () { return ctx.atteint && ctx.nbBattus === 3; },
      oeufs: function () { return !!st.oeufs; },
      trader: function () { return ctx.ordresParAn > 12; },
      fourmi: function () { return ctx.partLivret >= 0.5; },
      neveu: function () { return ctx.partCC >= 0.3; },
      metronome: function () {
        return Object.keys(st.autoMois).some(function (k) { return st.autoMois[k] >= 120; });
      },
      herbe: function () { return true; }
    };
    var titre = null;
    for (var i = 0; i < window.DATA_TITRES.length && !titre; i++) {
      var t = window.DATA_TITRES[i];
      if (conditions[t.id] && conditions[t.id]()) titre = t;
    }

    var lecons = choisirLecons(S, ctx, po);

    // Réplique : le témoin le mieux classé s'il est devant vous, sinon le suivant vous félicite
    var rangVous = classement.findIndex(function (c) { return c.id === "vous"; });
    var replique;
    if (rangVous === 0) {
      var second = classement[1].id;
      replique = { temoin: second, texte: DT[second].derriere };
    } else {
      var premier = classement[0].id;
      replique = { temoin: premier, texte: DT[premier].devant };
    }

    return {
      a: a, nominal: nominal, auj: auj, bag: bag, classement: classement, objectif: { atteint: atteint, po: po },
      etoiles: etoiles, nbEtoiles: etoiles.filter(function (e) { return e.ok; }).length,
      titre: titre, lecons: lecons, replique: replique, nbBattus: nbBattus
    };
  }

  function choisirLecons(S, ctx, po) {
    var st = S.stats, a = Moteur.abC(S), J = S.joueur, out = [];
    var vals = {};
    function ok(id, v) { vals[id] = v; }

    if (ctx.faillite) ok("faillite", { mois: U.dateTxt(S.abDebut + Math.max(0, st.faillieM)) });
    if (st.paniques.length) {
      var p = st.paniques[0];
      ok("panique", { mois: U.dateTxt(S.abDebut + p.m), evt: titreEvt(S, p.id), v12: varIndice(S, p.m, 12), v24: varIndice(S, p.m, 24) });
    }
    var vf = st.ventesForcees.filter(function (v) { return v.perf < 0; })[0];
    if (vf) ok("venteForcee", { mois: U.dateTxt(S.abDebut + vf.m), produit: nomProduit(S, vf.id), var: U.pct(vf.perf, 0), evt: vf.evt });
    if (ctx.partCC >= 0.25) {
      var b0 = Marche.baguette(S.abDebut), b1 = Marche.baguette(a);
      ok("dort", { part: U.pct(ctx.partCC, 0).replace("+", ""), b0: U.txt(b0, S.abDebut, { prix: true }), b1: U.txt(b1, a, { prix: true }),
        perte: U.pct(1 - b0 / b1, 0).replace("+", "") });
    }
    if (st.frais > 0.03 * Math.max(1, S.epargneNette)) {
      ok("frais", { frais: U.txt(st.frais, a), bag: U.nombre(st.frais / Marche.baguette(a), 0) });
    }
    if (st.maxPartAction >= 0.6) ok("panier", { action: nomProduit(S, st.maxPartActionId), pct: U.pct(st.maxPartAction, 0).replace("+", "") });
    if (st.impotCTOavecPEA > 0.5) ok("peaOublie", { impot: U.txt(st.impotCTOavecPEA, a) });
    var mk = Moteur.mkt(S);
    var tenu = S.panique.filter(function (w) {
      return w.v0 > 1 && !w.panique && w.m0 + 12 <= S.m && Marche.indice(mk, w.m0 + 12) > 1.05 * Marche.indice(mk, w.m0);
    })[0];
    if (tenu) ok("tenuBon", { evt: titreEvt(S, tenu.id), mois: U.dateTxt(S.abDebut + tenu.m0), v12: varIndice(S, tenu.m0, 12) });
    if (st.coussin) ok("coussin", { mois: U.dateTxt(S.abDebut + st.coussin.m), evt: st.coussin.evt });
    var autoId = Object.keys(st.autoMois).filter(function (k) { return st.autoMois[k] >= 60; })[0];
    if (autoId) ok("versement", { produit: nomProduit(S, autoId), duree: U.duree(st.autoMois[autoId]) });
    var patrBag = Moteur.patrimoine(S, J) / Marche.baguette(a);
    if (patrBag > S.bagMis && S.bagMis > 0) ok("baguettes", { patrBag: U.nombre(patrBag, 0), misBag: U.nombre(S.bagMis, 0) });

    var applicables = window.DATA_LECONS.filter(function (l) { return vals[l.id]; })
      .sort(function (x, y) { return x.ordre - y.ordre; });
    out = applicables.slice(0, 3);
    var positives = applicables.filter(function (l) { return l.signe === "+"; });
    if (positives.length && !out.some(function (l) { return l.signe === "+"; })) out[out.length - 1] = positives[0];
    return out.map(function (l) { return { id: l.id, signe: l.signe, texte: U.gabarit(l.texte, vals[l.id]) }; });
  }

  return { bilan: bilan };
})();
