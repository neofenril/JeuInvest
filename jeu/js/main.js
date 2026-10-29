/* Contrôleur : boucle du temps, sauvegarde, options, clavier, enchaînement des écrans. */
var App = (function () {
  "use strict";
  var CLE_PARTIE = "jeuclaude.partie", CLE_OPTIONS = "jeuclaude.options", CLE_META = "jeuclaude.meta";
  var VIT = window.DATA_REGLES.vitesses;

  var app = {
    S: null, vitesse: 0, progres: 0, bloque: {}, dernierT: 0, sauvegardeCorrompue: false,
    options: { animReduites: false, grandTexte: false, daltonien: false, pauseMarche: true, autreMonnaie: "auto" }
  };

  /* ---------- Options et méta ---------- */
  function chargerOptions() {
    var o = U.lire(CLE_OPTIONS);
    var reduit = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    app.options.animReduites = !!reduit;
    if (o) Object.keys(app.options).forEach(function (k) { if (o[k] !== undefined) app.options[k] = o[k]; });
    appliquerOptions();
  }
  function appliquerOptions() {
    var r = document.documentElement, o = app.options;
    if (o.animReduites) r.setAttribute("data-anim", "reduit"); else r.removeAttribute("data-anim");
    if (o.grandTexte) r.setAttribute("data-texte", "grand"); else r.removeAttribute("data-texte");
    if (o.daltonien) r.setAttribute("data-cb", "1"); else r.removeAttribute("data-cb");
    U.options.autreMonnaie = o.autreMonnaie;
  }
  function sauverOptions() { U.ecrire(CLE_OPTIONS, app.options); }
  function meta() { return U.lire(CLE_META) || { parties: 0 }; }

  /* ---------- Sauvegarde unique ---------- */
  function sauver() {
    if (!app.S || app.S.sansSauvegarde) return;
    if (app.S.fin) { U.effacer(CLE_PARTIE); return; }
    U.ecrire(CLE_PARTIE, app.S);
  }
  function lirePartie() {
    var brut = U.lireBrut(CLE_PARTIE);
    if (!brut) return null;
    try {
      var s = JSON.parse(brut);
      if (!s || s.version !== 1 || !window["DATA_" + s.periode] || !s.joueur || typeof s.m !== "number") throw new Error("format");
      return s;
    } catch (e) {
      app.sauvegardeCorrompue = true;
      U.effacer(CLE_PARTIE);
      return null;
    }
  }
  function prenomDe(s) { return window.DATA_SALAIRES.profils[s.profil].prenoms[s.periode]; }
  function resumeSauvegarde() {
    var s = lirePartie();
    if (!s) return null;
    try {
      return prenomDe(s) + " · " + U.dateTxt(s.abDebut + s.m) + " · " + U.txt(s.hist.j[s.m] || 0, s.abDebut + s.m);
    } catch (e) { return null; }
  }

  /* ---------- Temps ---------- */
  function enMarche() {
    return !!app.S && !app.S.fin && app.vitesse > 0 && Object.keys(app.bloque).length === 0 && !app.S.modale;
  }
  function bloquer(r) { app.bloque[r] = true; if (app.S) UIJeu.etatPause(); }
  function debloquer(r) { delete app.bloque[r]; if (app.S && !document.getElementById("ecran-jeu").hidden) UIJeu.etatPause(); }
  function setVitesse(v) {
    var avant = app.vitesse;
    app.vitesse = v;
    if (v > 0) Tuto.action("play");
    if (v === 0 && avant > 0) sauver(); // sauvegarde à chaque pause manuelle
    if (app.S) UIJeu.etatPause();
  }
  function boucle(t) {
    var dt = app.dernierT ? Math.min(250, t - app.dernierT) : 0;
    app.dernierT = t;
    if (enMarche()) {
      app.progres += dt / VIT[app.vitesse];
      if (app.progres >= 1) {
        app.progres = 0;
        moisSuivant();
      }
    }
    if (app.S && !app.S.fin) UIJeu.majCurseur(app.progres);
    requestAnimationFrame(boucle);
  }
  function moisSuivant() {
    var res;
    try { res = Moteur.avancer(app.S); }
    catch (e) { console.error(e); app.vitesse = 0; UIJeu.etatPause(); return; }
    traiter(res);
  }
  function traiter(res) {
    var s = app.S;
    UIJeu.rendre();
    (res.notifs || []).forEach(function (n) {
      UIEvt.notifier(n);
      Moteur.journaliser(s, n.titre);
    });
    UIJeu.effetsNotifs(res.notifs || []);
    UIJeu.rendre();
    if (res.sauver) sauver();
    if (res.fin === "faillite") { app.vitesse = 0; UIJeu.etatPause(); UIEvt.faillite(); return; }
    if (res.fin) { finPartie(); return; }
    if (res.modale) UIEvt.afficher(res.modale);
    Tuto.surMois(s, !!res.modale);
  }

  /* ---------- Parties ---------- */
  function lancer(S, res) {
    app.S = S; app.vitesse = 0; app.progres = 0; app.bloque = {};
    UI.viderToasts();
    UIEcrans.montrer("ecran-jeu");
    UIJeu.init();
    UIJeu.rendre();
    Tuto.demarrer(S);
    UIJeu.rendre(); // le tutoriel masque certains produits les premiers mois
    if (res) {
      (res.notifs || []).forEach(function (n) { UIEvt.notifier(n); });
      if (res.modale) UIEvt.afficher(res.modale);
    } else if (S.modale) {
      UIEvt.afficher(S.modale);
    }
  }
  function nouvelle(cfg) {
    var r = Moteur.nouvellePartie(cfg);
    var mt = meta(); mt.parties = (mt.parties || 0) + 1; mt.derniere = cfg; U.ecrire(CLE_META, mt);
    lancer(r.S, r.res);
    sauver();
  }
  function continuer() {
    var s = lirePartie();
    if (!s) { UIEcrans.titre("Votre ancienne partie n'a pas pu être relue."); return; }
    lancer(s, null);
  }
  function finPartie() {
    var s = app.S;
    if (!s) return;
    if (!s.fin) s.fin = "abandon";
    app.vitesse = 0;
    Tuto.cacher();
    if (Tiroir.estOuvert()) Tiroir.fermer();
    U.effacer(CLE_PARTIE);
    UI.viderToasts();
    document.body.classList.remove("is-paused");
    UIEcrans.bilan();
  }
  function quitterVersTitre() {
    sauver();
    Tuto.cacher();
    if (Tiroir.estOuvert()) Tiroir.fermer();
    app.S = null; app.vitesse = 0; app.bloque = {};
    UI.viderToasts();
    UIEcrans.titre();
  }

  /* ---------- Clavier (04 §7.5) ---------- */
  function clavier(e) {
    if (e.ctrlKey || e.altKey || e.metaKey) return;
    if (UI.clavierModale(e)) return;
    if (UIEcrans.bilanClavier(e)) return;
    var tag = (e.target && e.target.tagName) || "";
    var saisie = tag === "INPUT" || tag === "SELECT" || tag === "TEXTAREA";
    if (!document.getElementById("ecran-titre").hidden && e.key === "Enter" && tag !== "BUTTON") {
      var b = document.getElementById("t-continuer") || document.getElementById("t-nouvelle");
      if (b) { e.preventDefault(); b.click(); }
      return;
    }
    if (!app.S || app.S.fin || document.getElementById("ecran-jeu").hidden) return;
    if (e.key === "Escape") {
      e.preventDefault();
      if (Tiroir.estOuvert()) Tiroir.fermer(); else UIEcrans.menu();
      return;
    }
    if (saisie) return;
    if (e.key === " " || e.key === "p" || e.key === "P") {
      if (tag === "BUTTON" && e.key === " ") return; // l'Espace active le bouton focalisé
      e.preventDefault();
      if (app.vitesse > 0) { app.vitesseAvantPause = app.vitesse; setVitesse(0); }
      else setVitesse(app.vitesseAvantPause || 1);
      return;
    }
    if (e.key === "1" || e.key === "2" || e.key === "3") { e.preventDefault(); setVitesse(+e.key); app.vitesseAvantPause = +e.key; return; }
    if (e.key === "m" || e.key === "M") { e.preventDefault(); if (Tiroir.estOuvert()) Tiroir.fermer(); else Tiroir.ouvrir(null); }
  }

  /* ---------- Démarrage ---------- */
  function demarrer() {
    chargerOptions();
    UI.initGlossaire();
    document.addEventListener("keydown", clavier);
    document.addEventListener("visibilitychange", function () {
      if (document.hidden && app.S && !app.S.fin && app.vitesse > 0) { app.vitesseAvantPause = app.vitesse; setVitesse(0); }
    });
    window.addEventListener("beforeunload", sauver);
    window.addEventListener("resize", function () { Tuto.rePlacer(); });
    var s = lirePartie(); // détecte une sauvegarde corrompue
    UIEcrans.titre(app.sauvegardeCorrompue ? "Votre ancienne partie n'a pas pu être relue." : null);
    requestAnimationFrame(boucle);
  }

  app.enMarche = enMarche; app.bloquer = bloquer; app.debloquer = debloquer; app.setVitesse = setVitesse;
  app.sauver = sauver; app.sauverOptions = sauverOptions; app.appliquerOptions = appliquerOptions; app.meta = meta;
  app.resumeSauvegarde = resumeSauvegarde; app.nouvelle = nouvelle; app.continuer = continuer; app.finPartie = finPartie;
  app.quitterVersTitre = quitterVersTitre; app.demarrer = demarrer;
  app.moisSuivant = moisSuivant; // utile pour les tests manuels dans la console
  app.prenom = function () { return app.S ? prenomDe(app.S) : "V"; };
  return app;
})();

document.addEventListener("DOMContentLoaded", function () {
  try { App.demarrer(); }
  catch (e) {
    console.error(e);
    document.body.innerHTML = '<p style="padding:2rem">Le jeu n\'a pas pu démarrer : ' + String(e && e.message) + "</p>";
  }
});
