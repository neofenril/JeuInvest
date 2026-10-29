/* Écrans hors partie : titre (04 §3.1), création (§3.2), bilan de fin (§3.11), menu et options (§3.12). */
var UIEcrans = (function () {
  "use strict";
  var $ = UI.$;
  var ERAS = [1970, 1980, 1990, 2000, 2010, 2020];
  var crea = { etape: 1, periode: "P1", profil: "jeune", objectif: "inflation", tutoriel: true, memesVie: false, graineVie: null };
  var timerUne = null;

  function montrer(id) {
    ["ecran-titre", "ecran-creation", "ecran-jeu", "ecran-bilan"].forEach(function (e) {
      document.getElementById(e).hidden = e !== id;
    });
    if (id !== "ecran-titre" && timerUne) { clearInterval(timerUne); timerUne = null; }
    window.scrollTo(0, 0);
  }

  /* ---------- Écran titre ---------- */
  function titre(message) {
    montrer("ecran-titre");
    document.body.classList.remove("is-paused");
    var sv = App.resumeSauvegarde();
    var h = '<div class="une" id="une"><div class="une-tete"><span>LA GAZETTE</span><span>édition spéciale · 1 F</span></div>' +
      "<h1>JeuClaude</h1><p>Votre argent, votre vie, de 1978 à nos jours</p></div>";
    if (message) h += '<p class="titre-message" role="status">' + U.esc(message) + "</p>";
    h += '<div class="titre-boutons">';
    if (sv) h += '<button type="button" class="btn btn-p" id="t-continuer">▶︎  CONTINUER   <span class="petit" style="color:inherit">' + U.esc(sv) + "</span></button>";
    h += '<button type="button" class="btn ' + (sv ? "" : "btn-p") + '" id="t-nouvelle">+  NOUVELLE PARTIE</button></div>' +
      '<div class="titre-liens"><button type="button" class="btn-lien" id="t-options">Options</button> · <button type="button" class="btn-lien" id="t-gloss">Glossaire</button> · <button type="button" class="btn-lien" id="t-apropos">À propos</button></div>' +
      '<div class="bandeau-defile" aria-hidden="true"><div>' + window.DATA_TEXTES.bandeau.join("   ···   ") + "</div></div>";
    var el = document.getElementById("ecran-titre");
    el.innerHTML = h;
    if (sv) $("#t-continuer").addEventListener("click", function () { App.continuer(); });
    $("#t-nouvelle").addEventListener("click", function () {
      if (sv) confirmer("Cela remplacera votre partie en cours (" + sv + "). Continuer ?", function () { creation(); });
      else creation();
    });
    $("#t-options").addEventListener("click", function () { options(); });
    $("#t-gloss").addEventListener("click", function () { glossaire(); });
    $("#t-apropos").addEventListener("click", apropos);
    (sv ? $("#t-continuer") : $("#t-nouvelle")).focus();
    var i = 0;
    document.body.setAttribute("data-era", ERAS[1]);
    if (timerUne) clearInterval(timerUne);
    if (!UI.animReduites() && !(window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches)) {
      timerUne = setInterval(function () { i = (i + 1) % ERAS.length; document.body.setAttribute("data-era", ERAS[i]); }, 4000);
    }
  }

  function confirmer(texte, siOui) {
    UI.ouvrirModale('<div class="panneau"><p>' + U.esc(texte) + '</p><div style="display:flex;gap:.6rem;justify-content:flex-end">' +
      '<button type="button" class="btn" id="cf-non" data-touche="2" data-focus>Annuler</button><button type="button" class="btn btn-p" id="cf-oui" data-touche="1">Confirmer</button></div></div>',
      { titre: "Confirmation", onEchap: UI.fermerModale });
    $("#cf-non").addEventListener("click", UI.fermerModale);
    $("#cf-oui").addEventListener("click", function () { UI.fermerModale(); siOui(); });
  }

  /* ---------- Création de partie ---------- */
  function creation(rejouer) {
    var meta = App.meta();
    if (rejouer) {
      crea.periode = rejouer.periode; crea.profil = rejouer.profil; crea.objectif = rejouer.objectif;
      crea.graineVie = rejouer.graineVie; crea.memesVie = true; crea.etape = 4;
    } else {
      crea = { etape: 1, periode: "P1", profil: "jeune", objectif: "inflation", memesVie: false, graineVie: null };
    }
    crea.tutoriel = !(meta.parties > 0);
    montrer("ecran-creation");
    document.body.setAttribute("data-era", "1980");
    rendreCreation();
  }
  function prenom(p, per) { return window.DATA_SALAIRES.profils[p].prenoms[per]; }
  function phrase() {
    var P = Marche.periode(crea.periode), pf = window.DATA_SALAIRES.profils[crea.profil], o = window.DATA_REGLES.objectifs[crea.objectif];
    var e = crea.etape;
    var x1 = e > 1 ? "<b>janvier " + P.debut + "</b>" : "______";
    var x2 = e > 2 ? "<b>" + prenom(crea.profil, crea.periode) + ", " + pf.age + " ans, " + pf.court + "</b>" : "______";
    var x3 = e > 3 ? "<b>" + o.court + "</b>" : "______";
    return "« En " + x1 + ", je suis " + x2 + (e > 2 ? "," : "") + " et je veux " + x3 + (e > 3 ? " en 15 ans" : "") + ". »";
  }
  function miniCourbe(id) {
    var mk = Marche.generer(id), v = [];
    for (var i = 0; i < 181; i += 6) v.push(mk.indice[i]);
    return UI.sparkline(v, 300, 60);
  }
  function rendreCreation() {
    var e = crea.etape, h = '<div class="crea-tete"><button type="button" class="btn" id="cr-retour">← Retour</button><h2>' +
      (e < 4 ? "NOUVELLE PARTIE" : "VOTRE HISTOIRE") + '</h2><span class="etapes" aria-label="Étape ' + Math.min(e, 3) + ' sur 3">' +
      [1, 2, 3].map(function (k) { return '<span class="' + (k < e || e === 4 ? "ok" : "") + '"></span>'; }).join("") + (e < 4 ? " " + e + "/3" : "") + "</span></div>" +
      '<p class="phrase">' + phrase() + "</p>";
    if (e === 1) {
      h += '<p class="question">Quand commencez-vous votre vie active ?</p><div class="cartes">' + ["P1", "P2", "P3"].map(function (id) {
        var P = Marche.periode(id);
        return '<button type="button" class="carte' + (crea.periode === id ? " choisie" : "") + '" data-carte="' + id + '">' +
          '<span class="c-sur">À partir de ' + P.debut + '</span><span class="c-titre">' + U.esc(P.nom) + "</span>" + miniCourbe(id) +
          "<span>" + U.esc(P.accroche) + '</span><span class="petit">Monnaie : ' + P.monnaie + '</span><span class="petit">Secousses : ' +
          "●●●●".slice(0, P.secousses) + "○○○○".slice(0, 4 - P.secousses) + "</span></button>";
      }).join("") + "</div>";
    } else if (e === 2) {
      var P = Marche.periode(crea.periode), aD = U.ab(P.debut, 1);
      h += '<p class="question">Qui êtes-vous ?</p><div class="cartes">' + ["jeune", "cadre", "heritier"].map(function (id) {
        var pf = window.DATA_SALAIRES.profils[id], pr = prenom(id, crea.periode), sal = Moteur.valeurTable(id, P.debut);
        var l3 = id === "heritier" ? "Capital " + U.txt(Moteur.valeurTable("capital", P.debut), aD) : id === "cadre" ? "Dépenses élevées" : "Épargne " + U.txt(0, aD).replace(",00", "");
        return '<button type="button" class="carte' + (crea.profil === id ? " choisie" : "") + '" data-carte="' + id + '">' +
          '<span class="avatar" aria-hidden="true">' + pr.charAt(0) + '</span><span class="c-titre">' + pr + ", " + pf.age + " ans</span><span>" + pf.libelle + "</span>" +
          "<span>Salaire " + U.txt(sal, aD) + " / mois</span><span>" + l3 + '</span><span class="petit">' + pf.accroche + "</span></button>";
      }).join("") + "</div>";
    } else if (e === 3) {
      var P3 = Marche.periode(crea.periode), cib = Moteur.calculerCibles({ periode: crea.periode, profil: crea.profil });
      var mk = Marche.generer(crea.periode);
      h += '<p class="question">Quel est votre rêve ?</p><div class="cartes">' + ["inflation", "maison", "retraite"].map(function (id) {
        var o = window.DATA_REGLES.objectifs[id], desc;
        if (id === "inflation") desc = o.description;
        else if (id === "maison") desc = "Réunir " + U.txt(cib.maison, mk.abDebut + cib.mLimite.maison) + " d'apport avant " + (P3.debut + o.ans) + ".";
        else desc = "Atteindre " + U.txt(cib.retraite, mk.abDebut + 179) + " en " + (P3.debut + 14) + ".";
        return '<button type="button" class="carte' + (crea.objectif === id ? " choisie" : "") + '" data-carte="' + id + '">' +
          (o.conseille ? '<span class="c-sur">★ Conseillé pour débuter</span>' : '<span class="c-sur">&nbsp;</span>') +
          '<span class="c-titre">' + o.libelle + "</span><span>" + desc + '</span><span class="petit">Difficulté : ' +
          "●●●".slice(0, o.difficulte) + "○○○".slice(0, 3 - o.difficulte) + "</span></button>";
      }).join("") + "</div>";
    }
    if (e < 4) {
      h += '<p style="text-align:center;margin-top:1.2rem"><button type="button" class="btn-lien" id="cr-direct">Garder les choix conseillés et aller au récapitulatif ›</button></p>';
    } else {
      h += '<div class="recap"><label><input type="checkbox" id="cr-tuto"' + (crea.tutoriel ? " checked" : "") + "> Me guider pendant la première année</label>" +
        (crea.graineVie ? '<label><input type="checkbox" id="cr-memes"' + (crea.memesVie ? " checked" : "") + "> Mêmes événements de vie que ma dernière partie</label>" : "") +
        '<button type="button" class="btn btn-p" id="cr-go">▶︎  C\'EST PARTI !</button></div>';
    }
    var el = document.getElementById("ecran-creation");
    el.innerHTML = h;
    $("#cr-retour").addEventListener("click", function () {
      if (crea.etape === 1) titre(); else { crea.etape--; rendreCreation(); }
    });
    UI.$$("[data-carte]", el).forEach(function (b) {
      b.addEventListener("click", function () {
        var v = b.getAttribute("data-carte");
        if (crea.etape === 1) crea.periode = v; else if (crea.etape === 2) crea.profil = v; else crea.objectif = v;
        UI.$$("[data-carte]", el).forEach(function (x) { x.classList.toggle("choisie", x === b); });
        var et = crea.etape;
        setTimeout(function () { if (crea.etape === et) { crea.etape++; rendreCreation(); } }, 250);
      });
    });
    var direct = $("#cr-direct");
    if (direct) direct.addEventListener("click", function () { crea.etape = 4; rendreCreation(); });
    var go = $("#cr-go");
    if (go) {
      go.addEventListener("click", function () {
        var t = $("#cr-tuto"), mv = $("#cr-memes");
        var graine = (mv && mv.checked && crea.graineVie) ? crea.graineVie : U.nouvelleGraine();
        App.nouvelle({ periode: crea.periode, profil: crea.profil, objectif: crea.objectif, tutoriel: t ? t.checked : false, graineVie: graine });
      });
      go.focus();
    } else {
      var ch = el.querySelector(".carte.choisie") || el.querySelector(".carte");
      if (ch) ch.focus();
    }
  }

  /* ---------- Bilan de fin ---------- */
  var bi = { timers: [], etape: 0, etapes: [] };
  function bilan() {
    var s = App.S, B = Score.bilan(s), a = B.a, DT = window.DATA_TEMOINS;
    montrer("ecran-bilan");
    var el = document.getElementById("ecran-bilan");
    el.classList.toggle("sepia", s.fin === "faillite");
    var ans = Math.max(1, Math.floor((s.m + 1) / 12));
    var h = '<div class="bi-rideau bi-etape">' + U.dateTxt(a, true) + " · " + (ans === 15 ? "QUINZE ANS PLUS TARD" : ans + " AN" + (ans > 1 ? "S" : "") + " PLUS TARD") + "</div>";
    if (s.fin === "faillite") h += '<p class="bi-sous" style="text-align:center">' + UI.icone("maison", 20) + " Chez belle-maman, on fait les comptes…</p>";
    h += '<div class="bi-etape" style="text-align:center;margin-top:.8rem"><div class="titre-col">Votre patrimoine final</div>' +
      '<div class="bi-chiffre" id="bi-chiffre">0 €</div><div>d\'aujourd\'hui ' + UI.q("eurosAujourdhui") + '</div><div class="bi-sous">= ' +
      U.montantDevise(B.nominal.vous, U.deviseAffichee(a)) + " de " + U.annee(a) + " · " + U.nombre(B.bag.vous, 0) + " baguettes</div></div>";
    // La course et les courbes
    var noms = { vous: "VOUS", matelas: DT.matelas.nom, livret: DT.livret.nom, indice: DT.indice.nom };
    var coul = { vous: "var(--t-vous)", matelas: "var(--t-matelas)", livret: "var(--t-livret)", indice: "var(--t-indice)" };
    var ini = { vous: App.prenom().charAt(0), matelas: "M", livret: "L", indice: "C" };
    var maxV = Math.max.apply(null, B.classement.map(function (c) { return Math.max(0, c.valeur); })) || 1;
    var course = '<div class="course" id="bi-course">' + ["vous", "matelas", "livret", "indice"].map(function (k) {
      var rang = B.classement.findIndex(function (c) { return c.id === k; }) + 1;
      return '<div class="rang' + (k === "vous" ? " vous" : "") + '" data-rang="' + rang + '" title="' + U.esc(k === "vous" ? "Vous" : DT[k].regle) + '">' +
        '<span class="rg">' + rang + '</span><span class="mini-av" style="background:' + coul[k] + '">' + ini[k] + "</span><span>" + U.esc(noms[k]) + "</span>" +
        '<div><div class="barre" style="background:' + coul[k] + '" data-w="' + (Math.max(0, B.auj[k]) / maxV * 100) + '"></div></div>' +
        '<span class="montant">' + U.montantDevise(B.auj[k], "€") + "</span></div>";
    }).join("") + "</div>";
    h += '<div class="bi-grille bi-etape"><div class="bi-cadre"><div class="titre-col">La course <span style="text-transform:none;font-weight:400">(en € d\'aujourd\'hui)</span></div>' + course +
      '<p class="replique bi-etape" id="bi-replique"><span class="mini-av" style="display:inline-flex;background:' + coul[B.replique.temoin] + '">' + ini[B.replique.temoin] + "</span> « " + U.esc(B.replique.texte) + " »</p></div>" +
      '<div class="bi-cadre"><div class="titre-col">' + (ans === 15 ? "Quinze ans" : ans + " ans") + " en un coup d'œil</div>" + courbesBilan(s, coul) + "</div></div>";
    // Objectif
    var o = window.DATA_REGLES.objectifs[s.objectif], po = B.objectif.po, pctO = U.clamp(po.pct, 0, 1);
    var txtO = s.objectif === "inflation" ? U.nombre(po.patrBag, 0) + " baguettes pour " + U.nombre(po.misBag, 0) + " mises de côté"
      : (B.objectif.atteint ? "en " + U.dateTxt(s.abDebut + s.objectifAtteintM) + " (cible " + U.txt(po.cible, s.abDebut + s.objectifAtteintM) + ")" : U.nombre(po.pct * 100, 0) + " % de " + U.txt(po.cible, a));
    h += '<div class="bi-cadre bi-etape" style="margin-top:1rem"><div class="titre-col">Objectif · ' + o.libelle + "</div>" +
      '<div class="jauge ' + (B.objectif.atteint ? "ok" : "") + '"><div id="bi-jauge" style="width:0%"></div></div><div>' + (B.objectif.atteint ? "<b class='gain'>Atteint</b> · " : "<b>Pas atteint</b> · ") + txtO + "</div></div>";
    // Étoiles et titre
    h += '<div class="bi-etape" style="margin-top:1rem"><div class="bi-etoiles" id="bi-etoiles">' + B.etoiles.map(function (e) {
      return '<span tabindex="0" title="' + U.esc(e.regle) + '" aria-label="' + (e.ok ? "Étoile gagnée : " : "Étoile manquée : ") + U.esc(e.regle) + '">' + (e.ok ? "★" : "☆") + "</span>";
    }).join("") + '</div><div class="petit" style="text-align:center">' + B.nbEtoiles + " étoile" + (B.nbEtoiles > 1 ? "s" : "") + " sur 5 · survolez une étoile pour voir sa règle</div></div>";
    h += '<div class="tampon-zone bi-etape" id="bi-tampon"></div>';
    if (B.nbBattus === 3) h += '<p class="triomphe bi-etape">Vous avez battu toute la famille !</p>';
    // Leçons
    h += '<div class="bi-etape"><div class="titre-col">Les ' + (B.lecons.length === 3 ? "3 leçons" : "leçons") + " de votre partie</div>" +
      '<div class="lecons" id="bi-lecons"></div></div>';
    h += '<div class="bi-bas bi-etape"><button type="button" class="btn btn-p bi-rejouer" id="bi-rejouer">↻ REJOUER LA MÊME PÉRIODE AUTREMENT</button>' +
      '<button type="button" class="btn-lien" id="bi-nouvelle">Nouvelle partie</button> · <button type="button" class="btn-lien" id="bi-accueil">Accueil</button></div>' +
      '<p class="avertissement">' + U.esc(window.DATA_TEXTES.avertissement) + "</p>";
    el.innerHTML = h;
    $("#bi-rejouer").addEventListener("click", function () {
      creation({ periode: s.periode, profil: s.profil, objectif: s.objectif, graineVie: s.graineVie });
    });
    $("#bi-nouvelle").addEventListener("click", function () { creation(); });
    $("#bi-accueil").addEventListener("click", function () { titre(); });

    // Séquence de révélation (environ 8 s ; clic ou Espace : étape suivante ; double-clic : tout)
    bi.timers.forEach(clearTimeout); bi.timers = [];
    var etapes = UI.$$(".bi-etape", el);
    var actions = {
      chiffre: function () { UI.compteur($("#bi-chiffre"), 0, B.auj.vous, 1500, function (v) { return U.montantDevise(v, "€"); }); },
      course: function () {
        UI.$$(".barre", el).forEach(function (b) { b.style.width = b.getAttribute("data-w") + "%"; });
        UI.$$("path.trace", el).forEach(function (p) {
          try { p.style.setProperty("--len", Math.ceil(p.getTotalLength())); } catch (er) { /* rien */ }
          p.style.visibility = "visible";
          p.classList.add("dessin");
        });
        bi.timers.push(setTimeout(trierCourse, 2000));
      },
      jauge: function () { var j = $("#bi-jauge"); if (j) { j.style.transition = "width .8s"; j.style.width = (pctO * 100) + "%"; } },
      etoiles: function () {
        UI.$$("#bi-etoiles span", el).forEach(function (sp, i) {
          bi.timers.push(setTimeout(function () { if (B.etoiles[i].ok) sp.classList.add("on"); }, i * 200));
        });
      },
      titre: function () { $("#bi-tampon").innerHTML = '<span class="tampon">« ' + U.esc(B.titre.titre) + " »</span>"; bi.timers.push(setTimeout(UI.thud, 340)); },
      lecons: function () {
        $("#bi-lecons").innerHTML = B.lecons.map(function (l, i) {
          return '<div class="lecon ' + (l.signe === "+" ? "l-plus" : "l-moins") + '" style="animation-delay:' + (i * 150) + 'ms">' + (l.signe === "+" ? "▲ " : "▼ ") + U.esc(l.texte) + "</div>";
        }).join("") || '<div class="lecon">Rejouez pour découvrir d\'autres leçons !</div>';
      },
      fin: function () {
        if ((B.objectif.atteint || B.nbBattus >= 2) && s.fin !== "faillite") UI.confettis(120);
        $("#bi-rejouer").focus({ preventScroll: true });
      }
    };
    function trierCourse() {
      var c = $("#bi-course");
      if (!c) return;
      var rangs = UI.$$(".rang", c).sort(function (x, y) { return +x.getAttribute("data-rang") - +y.getAttribute("data-rang"); });
      rangs.forEach(function (r) { c.appendChild(r); });
    }
    // association étape -> action
    var plan = [];
    etapes.forEach(function (et) {
      var act = null;
      if (et.querySelector("#bi-chiffre")) act = actions.chiffre;
      else if (et.querySelector("#bi-course")) act = actions.course;
      else if (et.querySelector("#bi-jauge")) act = actions.jauge;
      else if (et.querySelector("#bi-etoiles")) act = actions.etoiles;
      else if (et.id === "bi-tampon") act = actions.titre;
      else if (et.querySelector("#bi-lecons")) act = actions.lecons;
      else if (et.querySelector("#bi-rejouer")) act = actions.fin;
      plan.push({ el: et, act: act, fait: false });
    });
    var delais = [0, 600, 2200, 4400, 4800, 5600, 6800, 7000, 7200, 7800];
    bi.etape = 0;
    function suivante() {
      if (bi.etape >= plan.length) return;
      var p = plan[bi.etape++];
      p.el.classList.add("vu");
      if (p.act && !p.fait) { p.fait = true; p.act(); }
    }
    function toutMontrer() { bi.timers.forEach(clearTimeout); bi.timers = []; while (bi.etape < plan.length) suivante(); trierCourse(); }
    plan.forEach(function (p, i) { bi.timers.push(setTimeout(suivante, delais[Math.min(i, delais.length - 1)] + (i >= delais.length ? (i - delais.length + 1) * 300 : 0))); });
    if (UI.animReduites()) toutMontrer();
    el.onclick = function (e) { if (!e.target.closest("button")) suivante(); };
    el.ondblclick = toutMontrer;
    bi.suivante = suivante; bi.toutMontrer = toutMontrer;
  }
  function courbesBilan(s, coul) {
    var W = 460, H = 220, gx = 8, bas = H - 20, series = { vous: s.hist.j, matelas: s.hist.matelas, livret: s.hist.livret, indice: s.hist.indice };
    var styles = { vous: "stroke-width:3.5", matelas: "stroke-dasharray:2 4", livret: "stroke-dasharray:8 4", indice: "" };
    var max = 1, conv = {};
    Object.keys(series).forEach(function (k) {
      conv[k] = series[k].slice(0, s.m + 1).map(function (v, m) { return Marche.eurosAujourdhui(v || 0, s.abDebut + m); });
      max = Math.max(max, Math.max.apply(null, conv[k]));
    });
    function X(m) { return gx + m / 179 * (W - gx - 90); }
    function Y(v) { return bas - Math.max(0, v) / max * (bas - 10); }
    var g = "";
    s.marqueurs.forEach(function (mq) {
      if (mq.type !== "marche") return;
      g += '<text x="' + X(mq.m) + '" y="' + (H - 4) + '" text-anchor="middle">◆' + String(U.annee(s.abDebut + mq.m)).slice(2) + "</text>";
    });
    var noms = { vous: "Vous", matelas: "Matelas", livret: "Livret", indice: "Cousin" }, etiq = [];
    Object.keys(conv).forEach(function (k) {
      var pts = conv[k].map(function (v, m) { return [X(m), Y(v)]; });
      var last = pts[pts.length - 1] || [X(0), Y(0)];
      g += '<path class="trace" style="stroke:' + coul[k] + ";" + styles[k] + ';visibility:hidden" d="' + UI.chemin(pts) + '"/>';
      etiq.push({ k: k, x: last[0] + 4, y: last[1] + 4 });
    });
    // étiquettes en bout de ligne, écartées pour ne pas se chevaucher
    etiq.sort(function (p, q) { return p.y - q.y; });
    for (var i = 1; i < etiq.length; i++) if (etiq[i].y - etiq[i - 1].y < 12) etiq[i].y = etiq[i - 1].y + 12;
    etiq.forEach(function (e) {
      g += '<text x="' + e.x + '" y="' + e.y + '" style="fill:' + coul[e.k] + ';font-weight:700">' + noms[e.k] + "</text>";
    });
    return '<svg class="bi-courbes" viewBox="0 0 ' + W + " " + H + '" role="img" aria-label="Les 4 courbes de patrimoine en euros d\'aujourd\'hui"><line class="axe" x1="' + gx + '" x2="' + (W - 90) + '" y1="' + bas + '" y2="' + bas + '" stroke="var(--line)"/>' + g + "</svg>";
  }
  function bilanClavier(e) {
    if (document.getElementById("ecran-bilan").hidden) return false;
    if (e.key === " " && bi.suivante && !e.target.closest("button")) { e.preventDefault(); bi.suivante(); return true; }
    return false;
  }

  /* ---------- Menu, options, glossaire ---------- */
  function menu() {
    if (UI.modaleOuverte()) return;
    var h = '<div class="panneau"><h2>Menu</h2><div class="menu-liste">' +
      '<button type="button" class="btn" id="mn-reprendre" data-focus>▶︎ Reprendre</button>' +
      '<button type="button" class="btn" id="mn-gloss">Glossaire</button>' +
      '<button type="button" class="btn" id="mn-options">Options</button>' +
      '<button type="button" class="btn" id="mn-fin">Terminer et voir le bilan</button>' +
      '<button type="button" class="btn" id="mn-accueil">Retour à l\'accueil</button></div></div>';
    UI.ouvrirModale(h, { titre: "Menu", onEchap: UI.fermerModale });
    $("#mn-reprendre").addEventListener("click", UI.fermerModale);
    $("#mn-gloss").addEventListener("click", function () { glossaire(true); });
    $("#mn-options").addEventListener("click", function () { options(true); });
    $("#mn-fin").addEventListener("click", function () {
      UI.fermerModale();
      confirmer("Terminer la partie maintenant et voir votre bilan ?", function () { Moteur.abandonner(App.S); App.finPartie(); });
    });
    $("#mn-accueil").addEventListener("click", function () { UI.fermerModale(); App.sauver(); App.quitterVersTitre(); });
  }
  function retourMenu(depuisMenu) {
    UI.fermerModale();
    if (depuisMenu) menu();
  }
  function options(depuisMenu) {
    var o = App.options;
    function sel(id, val, choix) {
      return '<select id="' + id + '">' + choix.map(function (c) { return '<option value="' + c[0] + '"' + (String(val) === String(c[0]) ? " selected" : "") + ">" + c[1] + "</option>"; }).join("") + "</select>";
    }
    var h = '<div class="panneau"><h2>Options</h2><div class="options-liste">' +
      "<label>Animations " + sel("op-anim", o.animReduites ? "1" : "0", [["0", "normales"], ["1", "réduites"]]) + "</label>" +
      "<label>Taille du texte " + sel("op-texte", o.grandTexte ? "1" : "0", [["0", "normale"], ["1", "grande"]]) + "</label>" +
      "<label>Couleurs des gains et pertes " + sel("op-cb", o.daltonien ? "1" : "0", [["0", "vert / rouge"], ["1", "bleu / orange"]]) + "</label>" +
      "<label>Pause automatique à l'ouverture du marché " + sel("op-pause", o.pauseMarche ? "1" : "0", [["1", "oui"], ["0", "non"]]) + "</label>" +
      "<label>Équivalent dans l'autre monnaie " + sel("op-monnaie", o.autreMonnaie, [["auto", "automatique"], ["toujours", "toujours"], ["jamais", "jamais"]]) + "</label>" +
      '</div><p style="text-align:right"><button type="button" class="btn btn-p" id="op-ok" data-focus>Fermer</button></p></div>';
    UI.fermerModale();
    UI.ouvrirModale(h, { titre: "Options", onEchap: function () { retourMenu(depuisMenu); } });
    function maj() {
      o.animReduites = $("#op-anim").value === "1";
      o.grandTexte = $("#op-texte").value === "1";
      o.daltonien = $("#op-cb").value === "1";
      o.pauseMarche = $("#op-pause").value === "1";
      o.autreMonnaie = $("#op-monnaie").value;
      App.appliquerOptions(); App.sauverOptions();
      if (App.S && !document.getElementById("ecran-jeu").hidden) UIJeu.rendre();
    }
    UI.$$("#modale select").forEach(function (s) { s.addEventListener("change", maj); });
    $("#op-ok").addEventListener("click", function () { retourMenu(depuisMenu); });
  }
  function glossaire(depuisMenu) {
    var vus = (App.S && !document.getElementById("ecran-jeu").hidden) ? App.S.notionsVues : null;
    var liste = window.DATA_GLOSSAIRE.slice().sort(function (x, y) { return x.terme.localeCompare(y.terme, "fr"); });
    var h = '<div class="panneau"><h2>Glossaire « C\'est quoi ? »</h2>' + (vus ? '<p class="petit">Les notions pas encore rencontrées sont en gris.</p>' : "") +
      '<dl class="gloss-liste">' + liste.map(function (g) {
        var d = UI.defGloss(g.id), cls = vus && !vus[g.id] ? ' class="pas-vu"' : "";
        return "<dt" + cls + ">" + U.esc(d.terme) + "</dt><dd" + cls + ">" + U.esc(d.def) + "</dd>";
      }).join("") + '</dl><p style="text-align:right"><button type="button" class="btn btn-p" id="gl-ok" data-focus>Fermer</button></p></div>';
    UI.fermerModale();
    UI.ouvrirModale(h, { titre: "Glossaire", onEchap: function () { retourMenu(depuisMenu); } });
    $("#gl-ok").addEventListener("click", function () { retourMenu(depuisMenu); });
  }
  function apropos() {
    var h = '<div class="panneau"><h2>À propos</h2><p>JeuClaude vous fait vivre 15 ans d\'épargne en France : salaire, imprévus, Livret A, actions, krachs et euphories, avec les vrais chiffres de l\'époque (simplifiés).</p>' +
      "<p>Tout fonctionne hors ligne, dans votre navigateur. La partie est sauvegardée automatiquement sur cet ordinateur.</p>" +
      '<p class="petit">' + U.esc(window.DATA_TEXTES.avertissement) + '</p><p style="text-align:right"><button type="button" class="btn btn-p" id="ap-ok" data-focus>Fermer</button></p></div>';
    UI.ouvrirModale(h, { titre: "À propos", onEchap: UI.fermerModale });
    $("#ap-ok").addEventListener("click", UI.fermerModale);
  }

  return { montrer: montrer, titre: titre, creation: creation, bilan: bilan, bilanClavier: bilanClavier, menu: menu,
    options: options, glossaire: glossaire, confirmer: confirmer };
})();
