/* Tiroir « Marché » (04 §3.4) : acheter, vendre, déposer, retirer, souscrire, revendre, versement automatique. */
var Tiroir = (function () {
  "use strict";
  var $ = UI.$;
  var st = { ouvert: false, id: null, mode: null, montant: "", env: "CTO", msg: null, msgCls: "", tout: false,
    courbe: "1", eclaireAuto: false };

  var TYPES = { livret: "Épargne", emprunt: "Obligation", sicav: "Fonds", action: "Action · Paris", etf: "Fonds indiciel" };
  var GLOSS = { livret: "livret", emprunt: "emprunt", sicav: "sicav", action: "action", etf: "etf" };

  function S() { return App.S; }
  function ab() { return Moteur.abC(App.S); }
  function dev() { return U.deviseAffichee(ab()); }
  function enEuros(v) { return U.versEuros(+v || 0, dev()); }
  function enAffiche(eur) { return Math.round(U.enDevise(eur, dev()) * 100) / 100; }

  function modesDe(pr) {
    if (pr.type === "livret") return ["deposer", "retirer"];
    if (pr.type === "emprunt") return ["souscrire", "revendre"];
    return ["acheter", "vendre"];
  }
  var LIB = { deposer: "DÉPOSER", retirer: "RETIRER", souscrire: "SOUSCRIRE", revendre: "REVENDRE AU NOMINAL", acheter: "ACHETER", vendre: "VENDRE" };

  function detientEnv(s, id) {
    return Moteur.lignes(s.joueur).filter(function (l) { return l.id === id; }).map(function (l) { return l.env; });
  }
  function onglets(s) {
    var ids = Moteur.produitsDisponibles(s);
    Moteur.lignes(s.joueur).forEach(function (l) { if (ids.indexOf(l.id) < 0) ids.push(l.id); });
    return ids;
  }

  function ouvrir(id, opts) {
    opts = opts || {};
    var s = S();
    if (!s || s.fin) return;
    if (!id) {
      var ls = Moteur.lignes(s.joueur);
      id = ls.length ? ls[0].id : "livret";
    }
    st.id = id; st.msg = null; st.tout = false; st.eclaireAuto = !!opts.eclaireAuto;
    var pr = Moteur.produit(s, id);
    st.mode = opts.mode || modesDe(pr)[0];
    st.env = (opts.env) || (Moteur.peaExiste(s) && Moteur.eligiblePEA(pr) ? "PEA" : "CTO");
    if (st.mode === "vendre") { var envs = detientEnv(s, id); if (envs.length) st.env = envs[0]; }
    st.montant = opts.montant !== undefined ? String(enAffiche(opts.montant)) : "";
    delete s.nouveaux[id];
    var el = document.getElementById("tiroir");
    if (!st.ouvert) {
      el.classList.remove("ferme");
      el.hidden = false;
      st.ouvert = true;
      if (App.options.pauseMarche) App.bloquer("tiroir");
    }
    rendre();
    setTimeout(function () {
      var f = el.querySelector("#ti-montant") || el.querySelector("button");
      if (f) f.focus({ preventScroll: true });
      if (st.eclaireAuto) { var z = el.querySelector(".ti-auto"); if (z && z.scrollIntoView) z.scrollIntoView({ block: "center" }); }
    }, 60);
  }
  function fermer() {
    if (!st.ouvert) return;
    var el = document.getElementById("tiroir");
    st.ouvert = false;
    if (UI.animReduites()) { el.hidden = true; }
    else {
      el.classList.add("ferme");
      setTimeout(function () { if (!st.ouvert) { el.hidden = true; el.classList.remove("ferme"); } }, 210);
    }
    App.debloquer("tiroir");
    UIJeu.rendre();
    Tuto.action("fermeTiroir");
  }
  function estOuvert() { return st.ouvert; }

  function rendre() {
    var s = S(), a = ab(), pr = Moteur.produit(s, st.id), J = s.joueur;
    var h = '<div class="ti-tete"><h2>MARCHÉ · ' + U.dateTxt(a).toUpperCase() + "</h2>" +
      '<span class="petit">' + (App.enMarche() ? "le temps continue" : "le temps est en pause") + "</span>" +
      '<button type="button" class="btn btn-mini" id="ti-fermer" aria-label="Fermer le marché (Échap)">✕</button></div>';
    h += '<div class="ti-onglets" role="tablist">';
    onglets(s).forEach(function (id) {
      var p = Moteur.produit(s, id);
      h += '<button type="button" role="tab" data-onglet="' + id + '" aria-selected="' + (id === st.id) + '">' + U.esc(p.court || p.nom) + "</button>";
    });
    h += "</div>";
    // En-tête produit
    h += '<div class="ti-prix"><div class="ti-nom">' + U.esc(pr.nom) + '</div><div class="petit">' + TYPES[pr.type] + "</div></div>";
    if (Moteur.estRisque(pr)) {
      var p = Moteur.cours(s, st.id), p1 = Moteur.cours(s, st.id, s.m - 1) || p;
      h += '<div class="ti-prix"><span><span class="num">' + U.money(p, a, { prix: true }) + "</span> " +
        (pr.type === "action" ? "l'action" : "la part") + "</span><span>" + U.varHtml(p / p1 - 1) + " ce mois</span></div>";
      h += '<div class="btns-periode" style="text-align:right"><button type="button" class="btn btn-mini" data-tc="1" aria-pressed="' + (st.courbe === "1") + '">1 an</button> ' +
        '<button type="button" class="btn btn-mini" data-tc="5" aria-pressed="' + (st.courbe === "5") + '">5 ans</button></div>';
      var v = [], n = st.courbe === "5" ? 60 : 12;
      for (var m = Math.max(-1, s.m - n); m <= s.m; m++) v.push(Moteur.cours(s, st.id, m));
      h += '<div class="ti-courbe">' + UI.sparkline(v, 440, 110).replace("<svg ", '<svg class="ti-courbe" ') + "</div>";
    } else if (pr.type === "livret") {
      h += '<div class="ti-prix"><span>Taux : <b>' + U.nombre(Marche.tauxLivret(a), 2) + " %</b> par an, intérêts versés chaque fin d'année</span></div>" +
        '<div class="petit">Plafond : ' + U.txt(Marche.plafondLivret(a), a) + " · ni frais ni impôt</div>";
    } else if (pr.type === "emprunt") {
      h += '<div class="ti-prix"><span>Taux garanti cette année : <b>' + U.nombre(Marche.tauxLong(U.annee(a)), 1) + " %</b> par an pendant 10 ans</span></div>" +
        '<div class="petit">Coupon versé chaque année à la date anniversaire, taxé ' + U.nombre(Marche.impot(U.annee(a)).cto, 1) +
        " %. Revente possible à tout moment au prix d'achat (simplifié). Sans frais.</div>";
    }
    var gd = UI.defGloss(GLOSS[pr.type]);
    h += '<div class="ti-quoi"><b>C\'est quoi ?</b> ' + U.esc(pr.description || (gd ? gd.def : "")) + "</div>";
    // Ce que vous avez
    var detenu = Moteur.valeurProduit(s, J, st.id);
    if (detenu > 0.005) {
      var txt = "Vous avez : ";
      if (Moteur.estRisque(pr)) {
        Moteur.lignes(J).filter(function (l) { return l.id === st.id; }).forEach(function (l, i) {
          var val = Moteur.valeurLigne(s, l);
          txt += (i ? " · " : "") + (pr.type === "action" ? U.nombre(l.qte, 0) + " actions" : U.nombre(l.qte, 2) + " parts") +
            (l.env === "PEA" ? " (PEA)" : "") + " = " + U.money(val, a) + " " + U.varHtml(l.cout > 0 ? val / l.cout - 1 : 0);
        });
      } else txt += U.money(detenu, a);
      h += "<div>" + txt + "</div>";
    }
    // Actions
    var modes = modesDe(pr), peutVendre = detenu > 0.005;
    h += '<div class="ti-actions">' + modes.map(function (md, i) {
      var dis = i === 1 && !peutVendre;
      return '<button type="button" data-mode="' + md + '" aria-pressed="' + (st.mode === md) + '"' + (dis ? " disabled" : "") + ">" + LIB[md] + "</button>";
    }).join("") + "</div>";
    var achat = st.mode === "acheter" || st.mode === "deposer" || st.mode === "souscrire";
    if (achat && J.cc <= 0.5) {
      h += '<div class="ti-alerte">Plus rien sur le compte courant ce mois-ci.</div>';
    }
    h += '<div class="ti-champ"><label for="ti-montant">Montant</label><input type="number" id="ti-montant" min="0" step="any" inputmode="decimal" value="' +
      U.esc(st.montant) + '"> <span>' + dev() + "</span></div>";
    h += '<div class="ti-pcts">' + [0.1, 0.25, 0.5, 1].map(function (x) {
      return '<button type="button" class="btn btn-mini" data-pct="' + x + '">' + (x === 1 ? "Tout" : Math.round(x * 100) + " %") + "</button>";
    }).join(" ") + ' <span class="petit">' + (achat ? "du compte courant" : "de ce que vous avez") + "</span></div>";
    // Enveloppe
    if (Moteur.estRisque(pr)) {
      if (st.mode === "acheter" && Moteur.peaExiste(s) && Moteur.eligiblePEA(pr)) {
        h += '<div class="ti-champ">Dans <label><input type="radio" name="ti-env" value="CTO"' + (st.env === "CTO" ? " checked" : "") + "> Compte-titres</label>" + UI.q("cto") +
          '<label><input type="radio" name="ti-env" value="PEA"' + (st.env === "PEA" ? " checked" : "") + "> PEA</label>" + UI.q("pea") + "</div>" +
          (st.env === "PEA" ? '<div class="petit">Vous pouvez encore verser ' + U.txt(Moteur.placePEA(s, J), a) + " sur le PEA" +
            (J.peaDebut >= 0 ? " · ouvert en " + U.dateTxt(s.abDebut + J.peaDebut) : "") + ".</div>" : "");
      } else if (st.mode === "vendre") {
        var envs = detientEnv(s, st.id);
        if (envs.length > 1) h += '<div class="ti-champ">Depuis ' + envs.map(function (e) {
          return '<label><input type="radio" name="ti-env" value="' + e + '"' + (st.env === e ? " checked" : "") + "> " + (e === "PEA" ? "PEA" : "Compte-titres") + "</label>";
        }).join(" ") + "</div>";
      }
    }
    h += '<div id="ti-devis"></div>';
    // Versement automatique
    var au = Moteur.autoDe(s, st.id);
    h += '<div class="ti-auto' + (st.eclaireAuto ? " eclaire" : "") + '" id="ti-auto"><h3 class="titre-col">Versement automatique ' + UI.q("versement") + "</h3>" +
      '<div class="ti-champ"><label><input type="checkbox" id="ti-auto-on"' + (au ? " checked" : "") + "> Chaque mois, investir</label>" +
      '<input type="number" id="ti-auto-montant" min="0" step="any" value="' + (au ? enAffiche(au.montant) : enAffiche(defautAuto(s))) + '"> ' + dev() + " ici</div>" +
      (au ? '<div class="petit">Programmé depuis ' + U.dateTxt(s.abDebut + au.depuis) + (au.env === "PEA" ? " · dans le PEA" : "") + ".</div>" : "") + "</div>";
    h += '<p class="petit">' + U.esc(window.DATA_TEXTES.avertissement) + "</p>";

    var el = document.getElementById("tiroir");
    el.innerHTML = h;
    brancher(el);
    majDevis();
  }
  function defautAuto(s) {
    var dep = Moteur.depenses(s, ab()), reste = Moteur.salaireDuMois(s) - dep.total;
    return Math.max(0, U.versEuros(Math.round(U.enDevise(reste * 0.5, dev()) / 10) * 10, dev()));
  }

  function brancher(el) {
    $("#ti-fermer", el).addEventListener("click", fermer);
    UI.$$("[data-onglet]", el).forEach(function (b) {
      b.addEventListener("click", function () { ouvrir(b.getAttribute("data-onglet")); });
    });
    UI.$$("[data-mode]", el).forEach(function (b) {
      b.addEventListener("click", function () {
        st.mode = b.getAttribute("data-mode"); st.msg = null; st.tout = false; st.montant = "";
        if (st.mode === "vendre") { var envs = detientEnv(S(), st.id); if (envs.length) st.env = envs[0]; }
        else if (st.mode === "acheter") { var pr = Moteur.produit(S(), st.id); st.env = Moteur.peaExiste(S()) && Moteur.eligiblePEA(pr) ? "PEA" : "CTO"; }
        rendre();
      });
    });
    UI.$$("[data-tc]", el).forEach(function (b) {
      b.addEventListener("click", function () { st.courbe = b.getAttribute("data-tc"); rendre(); });
    });
    var inp = $("#ti-montant", el);
    inp.addEventListener("input", function () { st.montant = inp.value; st.tout = false; st.msg = null; majDevis(); });
    inp.addEventListener("keydown", function (e) { if (e.key === "Enter") { e.preventDefault(); executer(); } });
    UI.$$("[data-pct]", el).forEach(function (b) {
      b.addEventListener("click", function () {
        var x = +b.getAttribute("data-pct"), base = baseMontant();
        st.tout = x === 1 && !estAchat();
        st.montant = String(Math.floor(enAffiche(base * x) * 100) / 100);
        st.msg = null;
        inp.value = st.montant; majDevis();
      });
    });
    UI.$$('input[name="ti-env"]', el).forEach(function (r) {
      r.addEventListener("change", function () { st.env = r.value; rendre(); });
    });
    var on = $("#ti-auto-on", el), am = $("#ti-auto-montant", el);
    function majAuto() {
      var s = S(), v = enEuros(am.value);
      if (on.checked && v > 0) Moteur.programmerAuto(s, st.id, Moteur.estRisque(Moteur.produit(s, st.id)) ? st.env : "CTO", v);
      else Moteur.programmerAuto(s, st.id, "CTO", 0);
      UIJeu.rendre();
      Tuto.action("auto");
    }
    on.addEventListener("change", function () { majAuto(); rendre(); });
    am.addEventListener("change", function () { if (on.checked) majAuto(); });
  }

  function estAchat() { return st.mode === "acheter" || st.mode === "deposer" || st.mode === "souscrire"; }
  function baseMontant() {
    var s = S(), J = s.joueur;
    if (estAchat()) return Math.max(0, J.cc);
    if (st.mode === "retirer") return J.livret;
    if (st.mode === "revendre") return Moteur.totalEmprunt(J);
    var l = J.lignes[st.id + "|" + st.env];
    return l ? Moteur.valeurLigne(s, l) : 0;
  }

  function ligne(lib, val, cls) { return "<tr" + (cls ? ' class="' + cls + '"' : "") + "><td>" + lib + "</td><td>" + val + "</td></tr>"; }
  function majDevis() {
    var s = S(), a = ab(), J = s.joueur, pr = Moteur.produit(s, st.id), z = document.getElementById("ti-devis");
    if (!z) return;
    var montant = enEuros(st.montant), h = "", bouton = "", ok = false, apresCC = J.cc;
    var dep = Moteur.depenses(s, a).total;
    if (st.mode === "acheter") {
      var d = Moteur.devisAchat(s, st.id, st.env, montant);
      if (montant > 0 && d.ok) {
        var unite = pr.type === "action" ? U.nombre(d.qte, 0) + " actions" : U.nombre(d.qte, 3) + " parts";
        h += '<table class="ti-devis">' + ligne(unite + " × " + U.txt(d.prix, a, { prix: true }), U.money(d.brut, a)) +
          ligne((pr.type === "sicav" ? "Frais d'entrée (2 %)" : "Frais de courtage") + " " + UI.q("courtage"), U.money(d.frais, a, { prix: true })) +
          (d.ttf > 0 ? ligne("Taxe sur les transactions (TTF)", U.money(d.ttf, a, { prix: true })) : "") +
          ligne("Reste sur le compte", U.money(J.cc - d.total, a), "fort") + "</table>";
        apresCC = J.cc - d.total;
        ok = true; // on n'interdit jamais rien : un achat au-delà du compte est signalé, pas bloqué
        bouton = "ACHETER POUR " + U.txt(d.total, a);
      } else if (montant > 0) h += '<div class="ti-erreur">' + U.esc(d.msg) + "</div>";
    } else if (st.mode === "vendre") {
      var dv = Moteur.devisVente(s, J, st.id, st.env, montant, st.tout);
      if (montant > 0 && dv.ok) {
        var un = pr.type === "action" ? U.nombre(dv.qte, 0) + " actions" : U.nombre(dv.qte, 3) + " parts";
        h += '<table class="ti-devis">' + ligne("Vous vendez : " + un + " × " + U.txt(dv.prix, a, { prix: true }), U.money(dv.brut, a)) +
          (dv.frais > 0 ? ligne("Frais " + UI.q("courtage"), U.money(-dv.frais, a, { prix: true })) : "") +
          ligne((dv.pv >= 0 ? "Plus-value (gain depuis l'achat) " : "Moins-value (perte depuis l'achat) ") + UI.q("plusvalue"), U.money(dv.pv, a, { signe: true })) +
          ligne("Impôt sur la plus-value (" + U.nombre(dv.taux, 1) + " %) " + UI.q("impot"), U.money(-dv.impot, a));
        if (dv.siPEA !== undefined) h += ligne("→ dans un PEA de plus de 5 ans, vous auriez payé :", U.money(dv.siPEA, a), "compar");
        if (dv.siCTO !== undefined) h += ligne("→ sur un compte-titres, vous auriez payé :", U.money(dv.siCTO, a), "compar");
        h += ligne("Vous recevez sur le compte courant", U.money(dv.recu, a), "fort") + "</table>";
        if (st.env === "PEA" && J.peaDebut >= 0 && s.m - J.peaDebut < 60) h += '<div class="petit">PEA de moins de 5 ans : taxé comme un compte-titres (pas de clôture dans le jeu). ' + UI.q("pea") + "</div>";
        ok = true; bouton = "VENDRE POUR " + U.txt(dv.recu, a);
      } else if (montant > 0) h += '<div class="ti-erreur">' + U.esc(dv.msg) + "</div>";
    } else if (st.mode === "deposer") {
      var plaf = Marche.plafondLivret(a), place = Math.max(0, plaf - J.livret);
      h += '<div class="petit">Vous pouvez encore déposer ' + U.txt(place, a) + " (plafond " + U.txt(plaf, a) + ").</div>";
      if (montant > place + 0.005) h += '<div class="ti-erreur">Au-delà du plafond : le dépôt sera refusé.</div>';
      if (montant > 0) { ok = true; bouton = "DÉPOSER " + U.txt(montant, a); apresCC = J.cc - montant; }
    } else if (st.mode === "retirer") {
      if (montant > 0) { ok = true; bouton = "RETIRER " + U.txt(Math.min(montant, J.livret), a); }
    } else if (st.mode === "souscrire") {
      if (montant > 0) {
        h += '<table class="ti-devis">' + ligne("Coupon annuel estimé", U.money(montant * Marche.tauxLong(U.annee(a)) / 100, a)) +
          ligne("Reste sur le compte", U.money(J.cc - montant, a), "fort") + "</table>";
        ok = true; bouton = "SOUSCRIRE " + U.txt(montant, a); apresCC = J.cc - montant;
      }
    } else if (st.mode === "revendre") {
      if (montant > 0) { ok = true; bouton = "REVENDRE " + U.txt(Math.min(montant, Moteur.totalEmprunt(J)), a); }
    }
    // Garde-fou pédagogique, non bloquant
    if (ok && (st.mode === "acheter" || st.mode === "souscrire")) {
      var cous = Math.max(0, apresCC + J.livret) / dep;
      if (cous < window.DATA_REGLES.coussinMois) h += '<div class="ti-alerte">⚠ Votre coussin passerait à ' + U.nombre(cous, 1) + " mois. " + UI.q("precaution") + "</div>";
      if (apresCC < 0) h += '<div class="ti-alerte">⚠ Votre compte passerait à découvert.</div>';
    }
    if (st.msg) h += '<div class="' + st.msgCls + '">' + st.msg + "</div>";
    h += '<button type="button" class="btn btn-p ti-go" id="ti-go"' + (ok ? "" : " disabled") + ">" + (bouton || LIB[st.mode]) + "</button>";
    z.innerHTML = h;
    var go = document.getElementById("ti-go");
    if (go) go.addEventListener("click", executer);
  }

  function executer() {
    var s = S(), J = s.joueur, a = ab(), montant = enEuros(st.montant), r, pr = Moteur.produit(s, st.id);
    if (!(montant > 0)) return;
    if (st.mode === "acheter") r = Moteur.acheter(s, J, st.id, st.env, montant);
    else if (st.mode === "vendre") r = Moteur.vendre(s, J, st.id, st.env, montant, { tout: st.tout });
    else if (st.mode === "deposer") r = Moteur.deposerLivret(s, J, montant);
    else if (st.mode === "retirer") r = Moteur.retirerLivret(s, J, montant);
    else if (st.mode === "souscrire") r = Moteur.souscrireEmprunt(s, J, montant);
    else if (st.mode === "revendre") r = Moteur.revendreEmprunt(s, J, montant);
    if (!r || !r.ok) {
      st.msg = U.esc((r && r.msg) || "Opération impossible."); st.msgCls = "ti-erreur";
      majDevis();
      UI.play(document.getElementById("ti-go"), "shake");
      return;
    }
    var msg = { acheter: "✓ Acheté", vendre: "✓ Vendu", deposer: "✓ Déposé", retirer: "✓ Retiré", souscrire: "✓ Souscrit", revendre: "✓ Revendu" }[st.mode];
    if (st.mode === "acheter" && pr.type === "action") msg += " : " + U.nombre(r.qte, 0) + " actions";
    if (st.mode === "vendre") msg += " : " + U.txt(r.recu, a) + " reçus" + (r.impot > 0.005 ? " (dont " + U.txt(r.impot, a) + " d'impôt payés)" : "");
    var actionTuto = st.mode;
    if (st.mode === "vendre" && !Moteur.valeurProduit(s, J, st.id)) st.mode = "acheter";
    st.msg = msg; st.msgCls = "ti-ok"; st.montant = ""; st.tout = false;
    rendre();
    UIJeu.rendre();
    Tuto.action(actionTuto, st.id);
  }

  return { ouvrir: ouvrir, fermer: fermer, estOuvert: estOuvert, rendre: rendre };
})();
