/* Utilitaires : hasard déterministe, dates, monnaie, formatage, stockage. Aucun accès au DOM du jeu. */
var U = (function () {
  "use strict";
  var TAUX_EURO = 6.55957;
  var MOIS = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août",
    "septembre", "octobre", "novembre", "décembre"];
  var MOINS = "−"; // vrai signe moins

  /* ---------- Hasard déterministe (mulberry32) ---------- */
  function mulberry32(a) {
    return function () {
      a |= 0; a = (a + 0x6D2B79F5) | 0;
      var t = Math.imul(a ^ (a >>> 15), 1 | a);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }
  function rng(graine) {
    var r = mulberry32(graine >>> 0);
    var g = {
      u: r,
      entre: function (a, b) { return a + (b - a) * r(); },
      entier: function (a, b) { return a + Math.floor(r() * (b - a + 1)); },
      normal: function () {
        var u1 = r() || 1e-12, u2 = r();
        return Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
      },
      /* Student nu = 4, réduite (variance 1), bornée à ±3,5 */
      student4: function () {
        var z = g.normal();
        var chi2 = -2 * Math.log((r() || 1e-12) * (r() || 1e-12)); // chi2 à 4 degrés de liberté
        var t = z / Math.sqrt(chi2 / 4) / Math.SQRT2;
        return Math.max(-3.5, Math.min(3.5, t));
      }
    };
    return g;
  }
  function nouvelleGraine() {
    // Seule utilisation de Math.random : tirer la graine de vie à la création d'une partie.
    return (Math.floor(Math.random() * 2147483646) + 1);
  }

  /* ---------- Dates : « mois absolu » = année × 12 + (mois − 1) ---------- */
  function ab(annee, mois) { return annee * 12 + (mois - 1); }
  function parseD(s) { var p = String(s).split("-"); return ab(+p[0], +p[1]); }
  function annee(a) { return Math.floor(a / 12); }
  function mois(a) { return (a % 12) + 1; }
  function dateTxt(a, majuscules) {
    var t = MOIS[mois(a) - 1] + " " + annee(a);
    return majuscules ? t.toUpperCase() : t;
  }
  function moisNom(a) { return MOIS[mois(a) - 1]; }
  function duree(nbMois) {
    var a = Math.floor(nbMois / 12), m = nbMois % 12, t = [];
    if (a) t.push(a + (a > 1 ? " ans" : " an"));
    if (m) t.push(m + " mois");
    return t.join(" et ") || "0 mois";
  }

  /* ---------- Monnaie ---------- */
  var options = { autreMonnaie: "auto" };
  function versEuros(v, devise) { return devise === "F" ? v / TAUX_EURO : v; }
  function deviseAffichee(a) { return a < ab(2002, 1) ? "F" : "€"; }
  /* Phase d'affichage : F seul, F + € (1999-2001), € + F (2002), € seul */
  function secondaire(a) {
    if (options.autreMonnaie === "jamais") return null;
    if (options.autreMonnaie === "toujours") return a < ab(2002, 1) ? "€" : "F";
    if (a >= ab(1999, 1) && a < ab(2002, 1)) return "€";
    if (a >= ab(2002, 1) && a < ab(2003, 1)) return "F";
    return null;
  }
  function enDevise(eur, devise) { return devise === "F" ? eur * TAUX_EURO : eur; }

  var fmt0 = new Intl.NumberFormat("fr-FR", { maximumFractionDigits: 0 });
  var fmt2 = new Intl.NumberFormat("fr-FR", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  var fmt1 = new Intl.NumberFormat("fr-FR", { minimumFractionDigits: 1, maximumFractionDigits: 1 });
  function nombre(x, dec) {
    var f = dec === 2 ? fmt2 : dec === 1 ? fmt1 : fmt0;
    var s = f.format(Math.abs(x));
    return (x < 0 && Math.abs(x) >= (dec === 2 ? 0.005 : dec === 1 ? 0.05 : 0.5) ? MOINS : "") + s;
  }
  /* Montant (en euros internes) affiché dans une devise donnée */
  function montantDevise(eur, devise, opts) {
    opts = opts || {};
    var v = enDevise(eur, devise), av = Math.abs(v), s;
    if (av >= 1e7) s = nombre(v / 1e6, 1) + " M";
    else if (opts.prix || av < 1000) s = nombre(v, 2);
    else s = nombre(v, 0);
    if (opts.signe && v > 0.004) s = "+" + s;
    return s + " " + devise;
  }
  /* Texte simple : devise principale de la date */
  function txt(eur, a, opts) { return montantDevise(eur, deviseAffichee(a), opts); }
  /* HTML : devise principale + équivalent en petit si la phase l'exige */
  function money(eur, a, opts) {
    var p = '<span class="mt-p">' + txt(eur, a, opts) + "</span>";
    var sec = secondaire(a);
    if (sec && !(opts && opts.seul)) p += ' <span class="mt-s">≈ ' + montantDevise(eur, sec, opts) + "</span>";
    return '<span class="mt" data-eur="' + eur + '">' + p + "</span>";
  }
  function pct(x, dec) {
    if (dec === undefined) dec = 1;
    var s = nombre(x * 100, dec);
    if (x > 0 && Math.abs(x * 100) >= 0.05) s = "+" + s;
    return s + " %";
  }
  function fleche(x) { return x > 0.0005 ? "▲" : x < -0.0005 ? "▼" : "●"; }
  function classeVar(x) { return x > 0.0005 ? "gain" : x < -0.0005 ? "perte" : "neutre"; }
  function varHtml(x, dec) {
    return '<span class="var ' + classeVar(x) + '">' + fleche(x) + " " + pct(x, dec) + "</span>";
  }
  /* Arrondi à 2 chiffres significatifs */
  function arrondi2(x) {
    if (!x || x <= 0) return 0;
    var p = Math.pow(10, Math.floor(Math.log10(x)) - 1);
    return Math.round(x / p) * p;
  }

  /* ---------- Divers ---------- */
  function esc(s) {
    return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
  }
  function gabarit(t, vals) {
    return String(t).replace(/\{(\w+)\}/g, function (m0, k) { return vals[k] !== undefined ? vals[k] : m0; });
  }
  function clamp(x, a, b) { return Math.max(a, Math.min(b, x)); }
  /* Valeur en vigueur à la date a dans une liste triée [["AAAA-MM", valeur, devise?], ...] */
  function enVigueur(liste, a) {
    var v = null;
    for (var i = 0; i < liste.length; i++) {
      if (parseD(liste[i][0]) <= a) v = liste[i]; else break;
    }
    return v;
  }

  /* ---------- Stockage local protégé ---------- */
  function lire(cle) {
    try {
      var s = window.localStorage.getItem(cle);
      return s ? JSON.parse(s) : null;
    } catch (e) { return null; }
  }
  function lireBrut(cle) {
    try { return window.localStorage.getItem(cle); } catch (e) { return null; }
  }
  function ecrire(cle, val) {
    try { window.localStorage.setItem(cle, JSON.stringify(val)); return true; } catch (e) { return false; }
  }
  function effacer(cle) {
    try { window.localStorage.removeItem(cle); } catch (e) { /* rien */ }
  }

  return {
    TAUX_EURO: TAUX_EURO, MOINS: MOINS, MOIS: MOIS, options: options,
    rng: rng, nouvelleGraine: nouvelleGraine,
    ab: ab, parseD: parseD, annee: annee, mois: mois, dateTxt: dateTxt, moisNom: moisNom, duree: duree,
    versEuros: versEuros, deviseAffichee: deviseAffichee, secondaire: secondaire, enDevise: enDevise,
    nombre: nombre, montantDevise: montantDevise, txt: txt, money: money, pct: pct, fleche: fleche,
    classeVar: classeVar, varHtml: varHtml, arrondi2: arrondi2,
    esc: esc, gabarit: gabarit, clamp: clamp, enVigueur: enVigueur,
    lire: lire, lireBrut: lireBrut, ecrire: ecrire, effacer: effacer
  };
})();
