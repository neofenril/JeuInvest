/* Marché : génération déterministe des cours (03 §7.1-7.3) et séries datées (taux, plafonds, IPC, baguette).
   Les tableaux de cours ont 181 cases : la case 0 = décembre précédant la période, la case m+1 = mois m. */
var Marche = (function () {
  "use strict";
  var S = window.DATA_SERIES, R = window.DATA_REGLES;
  var SIGMA_NORMAL = 0.045, SIGMA_CRISE = 0.10, N = 181;
  var cache = {};

  function periode(id) { return window["DATA_" + id]; }

  /* Pont brownien en log entre des points [[i, x], ...] triés (i entiers croissants). */
  function pont(points, sigmaFn, rng) {
    var x = new Array(N);
    for (var k = 0; k < N; k++) x[k] = null;
    for (var p = 0; p < points.length - 1; p++) {
      var i0 = points[p][0], x0 = points[p][1], i1 = points[p + 1][0], x1 = points[p + 1][1];
      var n = i1 - i0, w = [0];
      for (var j = 1; j <= n; j++) w.push(w[j - 1] + sigmaFn(i0 + j) * rng.student4());
      x[i0] = x0;
      for (j = 1; j < n; j++) {
        var t = j / n;
        x[i0 + j] = x0 + (x1 - x0) * t + w[j] - t * w[n];
      }
      x[i1] = x1;
    }
    return x;
  }

  function trierPoints(obj) {
    return Object.keys(obj).map(function (k) { return [+k, obj[k]]; })
      .sort(function (a, b) { return a[0] - b[0]; });
  }

  function generer(idPeriode) {
    if (cache[idPeriode]) return cache[idPeriode];
    var P = periode(idPeriode);
    var ab0 = U.ab(P.debut, 1) - 1; // décembre précédent = case 0
    var rng = U.rng(P.graine);

    /* --- Indice : ancrages durs = clôtures annuelles + points de crise --- */
    var anc = {}, annuels = {};
    for (var y = P.debut - 1; y <= P.debut + 14; y++) {
      var i = U.ab(y, 12) - ab0;
      anc[i] = Math.log(S.annuel[y][0]);
      annuels[i] = true;
    }
    (P.ancragesIndice || []).forEach(function (a) {
      var i = U.parseD(a[0]) - ab0;
      if (i >= 0 && i < N && !annuels[i]) anc[i] = Math.log(a[1]);
    });
    var crise = {};
    (P.moisCrise || []).forEach(function (d) { crise[U.parseD(d) - ab0] = true; });
    var logI = pont(trierPoints(anc), function (i) { return crise[i] ? SIGMA_CRISE : SIGMA_NORMAL; }, rng);
    var indice = logI.map(Math.exp);

    var prix = {}, infos = {};
    P.produits.forEach(function (pr) {
      infos[pr.id] = pr;
      if (pr.type === "action") {
        var pts = {};
        pr.ancrages.forEach(function (a) {
          var i = U.parseD(a[0]) - ab0;
          pts[i] = Math.log(U.versEuros(a[1], pr.devise)) - pr.beta * logI[i];
        });
        var sig = pr.volSpe / Math.sqrt(12);
        var resid = pont(trierPoints(pts), function () { return sig; }, rng);
        prix[pr.id] = resid.map(function (r, i) {
          return r === null ? null : Math.exp(pr.beta * logI[i] + r);
        });
      }
    });

    /* --- Fonds : VL(m) = VL(m-1) × I(m)/I(m-1) × (1 + d/12) × (1 − f/12) --- */
    function fonds(debutI, vlDebut, gestion) {
      var vl = new Array(N);
      for (var i = 0; i < N; i++) vl[i] = null;
      vl[debutI] = vlDebut;
      for (i = debutI + 1; i < N; i++) {
        var d = S.annuel[U.annee(ab0 + i)][1] / 100;
        vl[i] = vl[i - 1] * indice[i] / indice[i - 1] * (1 + d / 12) * (1 - gestion / 100 / 12);
      }
      return vl;
    }
    P.produits.forEach(function (pr) {
      if (pr.type === "sicav") prix[pr.id] = fonds(0, U.versEuros(pr.vl0, pr.devise), R.sicav.gestion);
      if (pr.type === "etf") {
        var iD = pr.dispo ? U.parseD(pr.dispo) - ab0 : 0;
        prix[pr.id] = fonds(iD, indice[iD] / 100, R.etf.gestion);
      }
    });

    var mk = { id: idPeriode, P: P, ab0: ab0, abDebut: ab0 + 1, indice: indice, prix: prix, infos: infos };
    cache[idPeriode] = mk;
    return mk;
  }
  function viderCache() { cache = {}; }

  /* Cours du mois m (0..179) ; m = -1 donne décembre précédent */
  function cours(mk, id, m) {
    var a = mk.prix[id];
    if (!a) return null;
    var v = a[U.clamp(m + 1, 0, N - 1)];
    return v === undefined ? null : v;
  }
  function indice(mk, m) { return mk.indice[U.clamp(m + 1, 0, N - 1)]; }

  /* ---------- Séries datées ---------- */
  function tauxLivret(a) { var v = U.enVigueur(S.livretTaux, a); return v ? v[1] : 0; }
  function plafondLivret(a) { var v = U.enVigueur(S.livretPlafond, a); return v ? U.versEuros(v[1], v[2]) : Infinity; }
  function plafondPEA(a) { var v = U.enVigueur(S.peaPlafond, a); return v ? U.versEuros(v[1], v[2]) : 0; }
  function tauxLong(annee) { return Math.max(0, S.annuel[annee][2]); }
  function rdtDividende(annee) { return S.annuel[annee][1]; }
  function inflation(annee) { return S.inflation[annee] || 0; }

  /* IPC base 100 en 2025 (valeur de l'année placée en janvier), interpolé géométriquement au mois */
  var ipcAn = null;
  function ipcAnnee(y) {
    if (!ipcAn) {
      ipcAn = { 2025: 100 };
      for (var k = 2025; k > 1976; k--) ipcAn[k - 1] = ipcAn[k] / (1 + S.inflation[k] / 100);
      ipcAn[2026] = 100 * (1 + S.inflation[2025] / 100);
    }
    return ipcAn[U.clamp(y, 1976, 2026)];
  }
  function ipc(a) {
    var y = U.annee(a), f = (U.mois(a) - 1) / 12;
    return ipcAnnee(y) * Math.pow(ipcAnnee(y + 1) / ipcAnnee(y), f);
  }
  function eurosAujourdhui(eur, a) { return eur * 100 / ipc(a); }

  /* Prix de la baguette (en euros), interpolation linéaire entre les points de janvier */
  function baguette(a) {
    var pts = S.baguette, x = U.annee(a) + (U.mois(a) - 1) / 12;
    for (var i = 0; i < pts.length - 1; i++) {
      var y0 = pts[i][0], y1 = pts[i + 1][0];
      if (x >= y0 && x <= y1) {
        var v0 = U.versEuros(pts[i][1], pts[i][2]), v1 = U.versEuros(pts[i + 1][1], pts[i + 1][2]);
        return v0 + (v1 - v0) * (x - y0) / (y1 - y0);
      }
    }
    return U.versEuros(pts[pts.length - 1][1], pts[pts.length - 1][2]);
  }

  /* Fiscalité, frais, agios */
  function impot(annee) {
    var r = R.impots[0];
    for (var i = 0; i < R.impots.length; i++) if (R.impots[i].de <= annee) r = R.impots[i];
    return r;
  }
  function frais(a) {
    var r = R.frais[0];
    for (var i = 0; i < R.frais.length; i++) if (U.parseD(R.frais[i].de) <= a) r = R.frais[i];
    return r;
  }
  function ttf(a) {
    var t = 0;
    for (var i = 0; i < R.ttf.length; i++) if (U.parseD(R.ttf[i].de) <= a) t = R.ttf[i].taux;
    return t;
  }
  function tauxAgios(annee) {
    var t = R.agios[0].taux;
    for (var i = 0; i < R.agios.length; i++) if (R.agios[i].de <= annee) t = R.agios[i].taux;
    return t;
  }
  function nomIndice(a) { return a < U.ab(1988, 6) ? "l'Indice de la Bourse de Paris" : "le CAC 40"; }

  return {
    N: N, generer: generer, viderCache: viderCache, cours: cours, indice: indice, periode: periode,
    tauxLivret: tauxLivret, plafondLivret: plafondLivret, plafondPEA: plafondPEA, tauxLong: tauxLong,
    rdtDividende: rdtDividende, inflation: inflation, ipc: ipc, eurosAujourdhui: eurosAujourdhui,
    baguette: baguette, impot: impot, frais: frais, ttf: ttf, tauxAgios: tauxAgios, nomIndice: nomIndice
  };
})();
