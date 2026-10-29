/* Écran principal (04 §3.3) : barre haute, frise, trois colonnes, fil d'actualité. */
var UIJeu = (function () {
  "use strict";
  var $ = UI.$, TXT = "︎"; // force le rendu texte (pas emoji) des symboles ▶ ❚
  var vue = { periodeCourbe: "tout", dernierCC: null, dernierPatr: null, dernierM: -1, decouvertVu: false };

  var CAT = { cc: "cash", livret: "livret", emprunt: "oblig", sicav: "fonds", action: "actions", etf: "etf" };
  var CAT_NOM = { cash: "Compte", livret: "Livret", oblig: "Emprunt", fonds: "SICAV", actions: "Actions", etf: "ETF" };
  var GLOSS_TYPE = { livret: "livret", emprunt: "emprunt", sicav: "sicav", action: "action", etf: "etf" };

  function S() { return App.S; }
  function a() { return Moteur.abC(App.S); }

  function init() {
    var el = document.getElementById("ecran-jeu");
    el.innerHTML =
      '<header id="barre">' +
        '<div class="b-date"><span class="date" id="b-date"><span></span></span>' +
        '<span class="baguette" id="b-baguette" tabindex="0"></span></div>' +
        '<div class="temps" role="radiogroup" aria-label="Vitesse du temps">' +
          '<button type="button" data-v="0" role="radio" title="Pause (Espace ou P)" aria-label="Pause">❚❚' + TXT + '</button>' +
          '<button type="button" data-v="1" role="radio" title="Vitesse ×1 : 4 s par mois (touche 1)" aria-label="Vitesse ×1" id="btn-play">▶' + TXT + '</button>' +
          '<button type="button" data-v="2" role="radio" title="Vitesse ×2 : 2 s par mois (touche 2)" aria-label="Vitesse ×2">▶' + TXT + '▶' + TXT + '</button>' +
          '<button type="button" data-v="3" role="radio" title="Vitesse ×3 : 1 s par mois (touche 3)" aria-label="Vitesse ×3">▶' + TXT + '▶' + TXT + '▶' + TXT + '</button>' +
          '<span class="badge-pause" id="badge-pause">❚❚' + TXT + ' EN PAUSE</span>' +
        '</div>' +
        '<div class="b-totaux">' +
          '<div class="b-total" id="b-cc"><div class="lib">Compte courant</div><div class="val" id="b-cc-val"></div></div>' +
          '<div class="b-total" id="b-patr" tabindex="0"><div class="lib">Patrimoine total</div><div class="val" id="b-patr-val"></div><div class="petit" id="b-patr-var"></div></div>' +
        '</div>' +
        '<button type="button" class="btn-menu" id="btn-menu" aria-label="Menu (Échap)">☰</button>' +
      '</header>' +
      '<div id="bandeau-decouvert" role="alert" hidden></div>' +
      '<div id="frise" aria-label="Frise du temps">' +
        '<div class="fr-annees" id="fr-annees"></div>' +
        '<div class="fr-barre"><div class="fr-passe" id="fr-passe"></div><div class="fr-raye" id="fr-raye"></div><div class="fr-curseur" id="fr-curseur" title=""></div></div>' +
        '<div class="fr-marqueurs" id="fr-marqueurs"></div>' +
        '<span class="fr-fin" title="Fin de la partie">' + UI.icone("drapeau", 16) + '</span>' +
      '</div>' +
      '<main id="colonnes">' +
        '<section id="col-mois" aria-label="Mon mois"></section>' +
        '<section id="col-patrimoine" aria-label="Mon patrimoine"></section>' +
        '<section id="col-placements" aria-label="Mes placements"></section>' +
      '</main>' +
      '<footer id="fil"><b>▸</b><span class="fil-txt" id="fil-txt"></span></footer>';

    UI.$$(".temps button", el).forEach(function (b) {
      b.addEventListener("click", function () { App.setVitesse(+b.getAttribute("data-v")); });
    });
    $("#btn-menu").addEventListener("click", function () { UIEcrans.menu(); });
    $("#b-patr").addEventListener("click", function () {
      var c = document.getElementById("col-patrimoine"); if (c && c.scrollIntoView) c.scrollIntoView({ behavior: "smooth" });
    });
    el.addEventListener("click", function (e) {
      var g = e.target.closest("[data-gerer]");
      if (g) { Tiroir.ouvrir(g.getAttribute("data-gerer")); return; }
      var mq = e.target.closest("[data-marq]");
      if (mq) { UIEvt.revoir(+mq.getAttribute("data-marq")); return; }
      var pc = e.target.closest("[data-pc]");
      if (pc) { vue.periodeCourbe = pc.getAttribute("data-pc"); rendrePatrimoine(); return; }
      if (e.target.closest("#btn-marche")) Tiroir.ouvrir(null);
    });
    vue.dernierCC = null; vue.dernierPatr = null; vue.dernierM = -1; vue.decouvertVu = false;
  }

  /* ---------- Rendu complet ---------- */
  function rendre() {
    if (!S()) return;
    var annee = U.annee(a()), era = U.clamp(Math.floor(annee / 10) * 10, 1970, 2020);
    document.body.setAttribute("data-era", era);
    rendreBarre();
    rendreFrise();
    rendreMois();
    rendrePatrimoine();
    rendrePlacements();
    rendreFil();
    etatPause();
    vue.dernierM = S().m;
  }

  function etatPause() {
    var enMarche = App.enMarche();
    document.body.classList.toggle("is-paused", !enMarche && !!S() && !S().fin);
    UI.$$(".temps button").forEach(function (b) {
      var v = +b.getAttribute("data-v");
      b.setAttribute("aria-pressed", String(v === App.vitesse));
      b.setAttribute("aria-checked", String(v === App.vitesse));
    });
    var bp = $("#badge-pause");
    if (bp) bp.style.visibility = enMarche ? "hidden" : "visible";
  }

  function rendreBarre() {
    var s = S(), J = s.joueur, ab = a();
    var dEl = $("#b-date span");
    var nouveau = U.dateTxt(ab, true);
    if (dEl.textContent !== nouveau) {
      dEl.textContent = nouveau;
      if (vue.dernierM >= 0) UI.play(dEl, "date-flip");
    }
    var bag = Marche.baguette(ab), bag12 = Marche.baguette(ab - 12);
    var be = $("#b-baguette");
    be.innerHTML = "Baguette " + U.money(bag, ab, { prix: true, seul: true });
    be.title = "Il y a 1 an : " + U.txt(bag12, ab, { prix: true }) + " (" + U.pct(bag / bag12 - 1, 0) + "). C'est l'inflation.";
    var patr = Moteur.patrimoine(s, J);
    var fmtCC = function (v) { return U.money(v, ab); };
    var anim = App.vitesse === 3 ? 250 : 400;
    UI.compteur($("#b-cc-val"), vue.dernierCC === null ? J.cc : vue.dernierCC, J.cc, anim, fmtCC);
    UI.compteur($("#b-patr-val"), vue.dernierPatr === null ? patr : vue.dernierPatr, patr, anim, fmtCC);
    if (vue.dernierPatr !== null && s.m !== vue.dernierM) {
      if (patr > vue.dernierPatr + 0.01) UI.play($("#b-patr"), "flash-gain");
      else if (patr < vue.dernierPatr - 0.01) UI.play($("#b-patr"), "flash-loss");
    }
    var prec = s.m > 0 ? s.hist.j[s.m - 1] : null;
    $("#b-patr-var").innerHTML = prec ? U.varHtml(prec > 0 ? patr / prec - 1 : 0) + " ce mois" : "";
    var dec = J.cc < 0;
    $("#b-cc").classList.toggle("decouvert", dec);
    var bd = $("#bandeau-decouvert");
    if (dec) {
      var tol = window.DATA_REGLES.decouvertTolereM * s.vie.salaireBase;
      bd.hidden = false;
      bd.innerHTML = "⚠ Découvert : " + s.decouvertMois + " mois sur 3 au-delà du découvert toléré (" + U.txt(tol, ab) +
        "). Vendez un placement ou réduisez vos versements. " + UI.q("decouvert");
      if (!vue.decouvertVu) { UI.play($("#b-cc"), "shake"); vue.decouvertVu = true; }
    } else { bd.hidden = true; vue.decouvertVu = false; }
    vue.dernierCC = J.cc; vue.dernierPatr = patr;
  }

  /* ---------- Frise (04 §4) ---------- */
  function pos(m) { return (U.clamp(m, 0, 180) / 180 * 100) + "%"; }
  function rendreFrise() {
    var s = S(), P = Moteur.mkt(s).P, ab = a();
    var an = $("#fr-annees");
    if (!an.childNodes.length || an._p !== s.periode) {
      var h = "";
      for (var y = 0; y <= 15; y++) h += '<span style="left:' + pos(y * 12) + '">' + (P.debut + y) + "</span>";
      an.innerHTML = h; an._p = s.periode;
    }
    $("#fr-raye").style.width = (12 / 180 * 100) + "%";
    majCurseur(App.progres || 0);
    // marqueurs passés (cliquables), regroupés par mois (3 au maximum, puis « +n »)
    var parMois = {}, html = "";
    s.marqueurs.forEach(function (mq, i) {
      if (mq.m > s.m) return;
      (parMois[mq.m] = parMois[mq.m] || []).push(i);
    });
    Object.keys(parMois).forEach(function (mk) {
      var l = parMois[mk];
      l.slice(0, 3).forEach(function (i, k) {
        var mq = s.marqueurs[i], cls = "marq m-" + mq.type, sym = "●", titre = "";
        if (mq.type === "marche") {
          sym = "◆"; var ev = Moteur.evenement(s, mq.ref);
          cls += mq.signe === "-" ? " baisse" : " hausse"; titre = ev ? ev.titre : "";
        } else if (mq.type === "vie") {
          var e = s.calendrier[mq.ref]; titre = e ? window.DATA_VIE.types[e.type].titre : "";
        } else if (mq.type === "produit") {
          sym = "★"; var pr = Moteur.produit(s, mq.ref); titre = "Nouveau : " + (pr ? pr.nom : "");
        }
        if (mq.m === s.m && vue.dernierM !== s.m) cls += " pulse";
        html += '<button type="button" class="' + cls + '" data-marq="' + i + '" style="left:' + pos(+mk + 0.5) +
          ";top:" + (k * 9) + 'px" title="' + U.esc(U.dateTxt(s.abDebut + mq.m) + " · " + titre) + '" aria-label="' + U.esc(titre) + '">' + sym + "</button>";
      });
      if (l.length > 3) html += '<span class="marq m-futur" style="left:' + pos(+mk + 0.5) + ';top:22px;font-size:10px">+' + (l.length - 3) + "</span>";
    });
    // à venir : nouveautés en mystère, euro, échéance d'objectif — jamais d'événement de marché
    P.produits.forEach(function (pr) {
      if (!pr.dispo) return;
      var m = U.parseD(pr.dispo) - s.abDebut;
      if (m > s.m) html += '<span class="marq m-futur m-futur-produit" style="left:' + pos(m + 0.5) + '" title="Nouveauté en ' + U.annee(U.parseD(pr.dispo)) + '">★</span>';
    });
    var mEuro = U.ab(2002, 1) - s.abDebut;
    if (mEuro > s.m && mEuro < 180 && ab >= U.ab(1999, 1)) html += '<span class="marq m-futur" style="left:' + pos(mEuro + 0.5) + '" title="L\'euro arrive">€</span>';
    if (s.objectif === "maison" && s.objectifAtteintM < 0) {
      var mE = s.cibles.mLimite.maison + 1;
      if (mE > s.m) html += '<span class="marq m-futur" style="left:' + pos(mE) + ';color:var(--accent)" title="Échéance : acheter sa maison">' + UI.icone("maison", 14) + "</span>";
    }
    $("#fr-marqueurs").innerHTML = html;
  }
  function majCurseur(progres) {
    var s = S();
    if (!s) return;
    var x = (s.m + U.clamp(progres, 0, 1)) / 180 * 100;
    var c = $("#fr-curseur"), p = $("#fr-passe");
    if (c) { c.style.left = x + "%"; c.title = U.dateTxt(Moteur.abC(s)); }
    if (p) p.style.width = x + "%";
  }

  /* ---------- Mon mois ---------- */
  function rendreMois() {
    var s = S(), ab = a(), dep = Moteur.depenses(s, ab), sal = Moteur.salaireDuMois(s), autos = Moteur.totalAutos(s);
    var reste = sal - dep.total - autos;
    var chom = s.vie.chomageFin >= 0;
    var h = '<h2 class="titre-col">Mon mois <span style="float:right;text-transform:none;letter-spacing:0;font-weight:400">' + U.dateTxt(ab) + "</span></h2>" +
      '<table class="lignes-budget">' +
      "<tr><td>" + (chom ? "Indemnité chômage" : "Salaire") + "</td><td class='gain'>" + U.money(sal, ab, { signe: true }) + "</td></tr>" +
      "<tr><td>Loyer</td><td>" + U.money(-dep.loyer, ab) + "</td></tr>" +
      "<tr><td>Vie courante</td><td>" + U.money(-dep.vie, ab) + "</td></tr>" +
      (autos > 0 ? "<tr><td>Versements auto " + UI.q("versement") + "</td><td>" + U.money(-autos, ab) + "</td></tr>" : "") +
      "<tr class='reste'><td>Reste</td><td class='" + U.classeVar(reste) + "'>" + U.money(reste, ab, { signe: true }) + "</td></tr></table>";
    // Coussin : compte courant + livret en mois de dépenses
    var J = s.joueur, cous = Math.max(0, J.cc + J.livret) / dep.total, cible = window.DATA_REGLES.coussinMois;
    h += '<div class="bloc" id="bloc-coussin"><h3 class="titre-col">Coussin de sécurité ' + UI.q("coussin") + "</h3>" +
      '<div class="jauge ' + (cous >= cible ? "ok" : cous < 1 ? "bas" : "") + '" role="meter" aria-valuemin="0" aria-valuemax="6" aria-valuenow="' + cous.toFixed(1) + '"><div style="width:' + U.clamp(cous / 6 * 100, 0, 100) + '%"></div></div>' +
      '<div class="petit">' + U.nombre(cous, 1) + " mois de dépenses · conseillé : " + cible + " mois</div></div>";
    // Objectif
    var o = window.DATA_REGLES.objectifs[s.objectif], po = Moteur.progressionObjectif(s);
    h += '<div class="bloc" id="bloc-objectif"><h3 class="titre-col">Mon objectif</h3><div><b>' + o.libelle + "</b></div>";
    if (s.objectifAtteintM >= 0) {
      h += '<div class="gain"><b>Objectif atteint en ' + U.dateTxt(s.abDebut + s.objectifAtteintM) + " ✓</b></div>";
    } else {
      var pc = po.pct;
      h += '<div class="jauge ' + (pc >= 1 ? "ok" : "") + (pc >= 0.9 ? " proche" : "") + '"><div style="width:' + U.clamp(pc * 100, 0, 100) + '%"></div></div>';
      if (s.objectif === "inflation") {
        h += '<div class="petit">' + U.nombre(pc * 100, 0) + " % · " + U.nombre(po.misBag, 0) + " → " + U.nombre(po.patrBag, 0) +
          " baguettes " + UI.q("pouvoir") + '</div><div class="petit">Mis de côté → ce que ça vaut. Encore ' + U.duree(179 - s.m) + ".</div>";
      } else {
        var mL = s.cibles.mLimite[s.objectif];
        h += '<div class="petit">' + U.nombre(pc * 100, 0) + " % de " + U.txt(po.cible, ab) + "</div>" +
          '<div class="petit">' + (s.m <= mL ? "Encore " + U.duree(mL - s.m + 1) + " (avant " + U.dateTxt(s.abDebut + mL + 1) + ")" : "Échéance dépassée") + "</div>";
      }
    }
    h += "</div>";
    $("#col-mois").innerHTML = h;
  }

  /* ---------- Mon patrimoine ---------- */
  function rendrePatrimoine() {
    var s = S(), ab = a(), J = s.joueur, patr = Moteur.patrimoine(s, J);
    var maxH = Math.max.apply(null, s.hist.j.slice(0, s.m + 1).concat([patr]));
    var krach = maxH > 0 && patr < 0.85 * maxH && Moteur.valeurRisquee(s, J) > 0;
    var h = '<h2 class="titre-col">Mon patrimoine <span class="btns-periode" style="float:right">' +
      '<button type="button" class="btn btn-mini" data-pc="an" aria-pressed="' + (vue.periodeCourbe === "an") + '">1 an</button> ' +
      '<button type="button" class="btn btn-mini" data-pc="tout" aria-pressed="' + (vue.periodeCourbe === "tout") + '">Tout</button></span></h2>' +
      '<div class="patr-total"><span class="grand">' + U.money(patr, ab) + "</span><span>= " +
      U.nombre(patr / Marche.baguette(ab), 0) + " baguettes " + UI.q("pouvoir") + "</span>" +
      (krach ? '<span class="alerte-krach">▼ ' + U.pct(patr / maxH - 1, 0) + " depuis le plus haut</span>" : "") + "</div>" +
      '<div class="courbe-zone" id="courbe-zone">' + svgCourbe(s, krach) + (s.m === 0 ? '<div class="courbe-vide">Votre courbe se dessinera mois après mois.</div>' : "") + "</div>" +
      '<div class="legende"><span>── Ce que ça vaut</span><span>- - Argent mis de côté ' + UI.q("composes") + "</span></div>";
    // Répartition (barre horizontale à motifs, 03 A1)
    var parts = { cash: Math.max(0, J.cc), livret: J.livret, oblig: Moteur.totalEmprunt(J), fonds: 0, actions: 0, etf: 0 };
    Moteur.lignes(J).forEach(function (l) {
      var pr = Moteur.produit(s, l.id); parts[CAT[pr.type]] += Moteur.valeurLigne(s, l);
    });
    var tot = Object.keys(parts).reduce(function (x, k) { return x + parts[k]; }, 0) || 1;
    var barre = "", leg = "";
    Object.keys(parts).forEach(function (k) {
      if (parts[k] <= 0.5) return;
      var p = parts[k] / tot * 100;
      barre += '<div class="cat-' + k + '" style="width:' + p + '%" title="' + CAT_NOM[k] + " " + Math.round(p) + ' %"></div>';
      leg += '<span><i class="cat-' + k + '"></i>' + CAT_NOM[k] + " " + Math.round(p) + " %</span>";
    });
    h += '<div class="bloc"><h3 class="titre-col">Répartition ' + UI.q("diversification") + '</h3><div class="repartition" aria-hidden="true">' +
      (barre || '<div class="cat-cash" style="width:100%"></div>') + '</div><div class="rep-legende">' + (leg || "<span><i class='cat-cash'></i>Compte 100 %</span>") + "</div></div>";
    $("#col-patrimoine").innerHTML = h;
    brancherInfobulle(s);
  }
  function svgCourbe(s, krach) {
    var W = 600, H = 230, gx = 56, gy = 16, bas = H - 22;
    var m1 = s.m, m0 = vue.periodeCourbe === "an" ? Math.max(0, m1 - 11) : 0;
    var span = vue.periodeCourbe === "an" ? 11 : 179;
    var ab = a(), dev = U.deviseAffichee(ab);
    var vals = [], mis = [];
    for (var m = m0; m <= m1; m++) { vals.push(s.hist.j[m] || 0); mis.push(s.hist.mis[m] || 0); }
    var max = Math.max(1, Math.max.apply(null, vals.concat(mis)));
    var grad = UI.graduations(U.enDevise(max, dev)).map(function (v) { return U.versEuros(v, dev); });
    var top = grad[grad.length - 1] || max;
    function X(m) { return gx + (m - m0) / Math.max(1, span) * (W - gx - 8); }
    function Y(v) { return bas - Math.max(0, v) / top * (bas - gy); }
    var g = "";
    grad.forEach(function (v) {
      g += '<line class="axe" x1="' + gx + '" x2="' + (W - 8) + '" y1="' + Y(v) + '" y2="' + Y(v) + '"/>' +
        '<text x="' + (gx - 4) + '" y="' + (Y(v) + 4) + '" text-anchor="end">' + U.nombre(U.enDevise(v, dev), 0) + "</text>";
    });
    // années en abscisse
    var y0 = U.annee(s.abDebut), pasA = vue.periodeCourbe === "an" ? 1 : 3;
    for (var mm = m0; mm <= m0 + span; mm++) {
      var abx = s.abDebut + mm;
      if (U.mois(abx) === 1 && (U.annee(abx) - y0) % pasA === 0) g += '<text x="' + X(mm) + '" y="' + (H - 6) + '" text-anchor="middle">' + U.annee(abx) + "</text>";
    }
    var mEuro = U.ab(2002, 1) - s.abDebut;
    if (mEuro >= m0 && mEuro <= m1) g += '<line class="axe c-euro" x1="' + X(mEuro) + '" x2="' + X(mEuro) + '" y1="' + gy + '" y2="' + bas + '"/><text x="' + (X(mEuro) + 3) + '" y="' + (gy + 10) + '">Passage à l\'euro</text>';
    var pts = vals.map(function (v, i) { return [X(m0 + i), Y(v)]; });
    var ptsMis = mis.map(function (v, i) { return [X(m0 + i), Y(v)]; });
    var aire = pts.length > 1 ? UI.chemin(pts) + "L" + pts[pts.length - 1][0].toFixed(1) + " " + bas + "L" + pts[0][0].toFixed(1) + " " + bas + "Z" : "";
    return '<svg class="courbe" id="svg-courbe" viewBox="0 0 ' + W + " " + H + '" preserveAspectRatio="none" role="img" aria-label="Courbe du patrimoine">' + g +
      (aire ? '<path class="c-aire' + (krach ? " krach" : "") + '" d="' + aire + '"/>' : "") +
      '<path class="c-mis" d="' + UI.chemin(ptsMis) + '"/>' +
      '<path class="c-patr" d="' + UI.chemin(pts) + '"/>' +
      (pts.length ? '<circle cx="' + pts[pts.length - 1][0] + '" cy="' + pts[pts.length - 1][1] + '" r="3.5" fill="var(--accent)"/>' : "") +
      "</svg>";
  }
  function brancherInfobulle(s) {
    var zone = $("#courbe-zone"), svg = $("#svg-courbe");
    if (!zone || !svg) return;
    var bulle = document.createElement("div");
    bulle.className = "infobulle"; bulle.hidden = true; zone.appendChild(bulle);
    svg.addEventListener("mousemove", function (e) {
      var r = svg.getBoundingClientRect(), W = 600, gx = 56;
      var m0 = vue.periodeCourbe === "an" ? Math.max(0, s.m - 11) : 0, span = vue.periodeCourbe === "an" ? 11 : 179;
      var xv = (e.clientX - r.left) / r.width * W;
      var m = Math.round(m0 + (xv - gx) / (W - gx - 8) * span);
      if (m < m0 || m > s.m) { bulle.hidden = true; return; }
      bulle.hidden = false;
      bulle.textContent = U.dateTxt(s.abDebut + m) + " · " + U.txt(s.hist.j[m] || 0, s.abDebut + m);
      bulle.style.left = (e.clientX - r.left) + "px";
      bulle.style.top = (e.clientY - r.top) + "px";
    });
    svg.addEventListener("mouseleave", function () { bulle.hidden = true; });
  }

  /* ---------- Mes placements ---------- */
  function ligneHtml(s, o) {
    var autoP = o.auto ? ' <span class="pastille p-auto">AUTO</span>' : "";
    var envP = o.env === "PEA" ? ' <span class="pastille p-pea">PEA</span>' : "";
    var nouv = o.nouveau ? ' <span class="pastille p-nouveau">NOUVEAU</span>' : "";
    return '<div class="placement b-cat-' + o.cat + (o.dispo ? " dispo" : "") + (o.nouveau ? " nouveau" : "") + '">' +
      '<div><div class="nom">' + U.esc(o.nom) + envP + autoP + nouv + "</div>" + (o.det ? '<div class="det">' + o.det + "</div>" : "") + "</div>" +
      '<div class="val">' + (o.valeur !== null ? U.money(o.valeur, a()) : "") + "</div>" +
      '<div class="det">' + (o.varTxt || "") + " " + (o.spark || "") + "</div>" +
      '<div class="act"><button type="button" class="btn btn-mini" data-gerer="' + o.id + '">' + (o.dispo ? "Découvrir" : "Gérer") + "</button></div></div>";
  }
  function spark12(s, id) {
    var v = [];
    for (var m = Math.max(-1, s.m - 12); m <= s.m; m++) v.push(Moteur.cours(s, id, m));
    return UI.sparkline(v, 70, 22);
  }
  function rendrePlacements() {
    var s = S(), J = s.joueur, ab = a(), h = '<h2 class="titre-col">Mes placements</h2>', detenus = {};
    var tl = Marche.tauxLivret(ab);
    if (J.livret > 0.5) {
      detenus.livret = true;
      h += ligneHtml(s, { id: "livret", cat: "livret", nom: "Livret A", valeur: J.livret, auto: Moteur.autoDe(s, "livret"),
        det: U.nombre(tl, 2) + " % / an " + UI.q("livret") });
    }
    if (J.tranches.length) {
      detenus.emprunt = true;
      var tot = Moteur.totalEmprunt(J), tm = J.tranches.reduce(function (x, t) { return x + t.taux * t.montant; }, 0) / tot;
      h += ligneHtml(s, { id: "emprunt", cat: "oblig", nom: "Emprunt d'État", valeur: tot, auto: Moteur.autoDe(s, "emprunt"),
        det: "Taux moyen " + U.nombre(tm, 2) + " % " + UI.q("emprunt") });
    }
    Moteur.lignes(J).forEach(function (l) {
      var pr = Moteur.produit(s, l.id), v = Moteur.valeurLigne(s, l);
      detenus[l.id] = true;
      var perf = l.cout > 0 ? v / l.cout - 1 : 0;
      h += ligneHtml(s, { id: l.id, cat: CAT[pr.type], nom: pr.court || pr.nom, env: l.env, valeur: v,
        auto: Moteur.autoDe(s, l.id) && Moteur.autoDe(s, l.id).env === l.env,
        varTxt: U.varHtml(perf) + (l.grandPere ? " · de grand-père" : ""), spark: spark12(s, l.id) });
    });
    var aucun = !Object.keys(detenus).length;
    if (aucun) h += '<p class="vide-msg">Votre argent dort sur le compte courant.</p>';
    var dispo = Moteur.produitsDisponibles(s).filter(function (id) { return !detenus[id]; });
    if (Tuto.actif() && s.m < 3) dispo = dispo.filter(function (id) { return id === "livret"; });
    if (dispo.length) {
      h += '<div class="sep-dispo">Disponibles</div>';
      dispo.forEach(function (id) {
        var pr = Moteur.produit(s, id), det = "";
        if (id === "livret") det = U.nombre(tl, 2) + " % / an " + UI.q("livret");
        else if (id === "emprunt") det = "Taux garanti " + U.nombre(Marche.tauxLong(U.annee(ab)), 1) + " % pendant 10 ans " + UI.q("emprunt");
        else det = (pr.secteur ? pr.secteur + " · " : "") + U.txt(Moteur.cours(s, id), ab, { prix: true }) + " " + UI.q(GLOSS_TYPE[pr.type]);
        h += ligneHtml(s, { id: id, cat: CAT[pr.type], nom: pr.court || pr.nom, valeur: null, dispo: true, nouveau: !!s.nouveaux[id], det: det,
          spark: (pr.type === "action" || pr.type === "etf" || pr.type === "sicav") ? spark12(s, id) : "" });
      });
    }
    if (s.nouveaux.pea && Moteur.peaExiste(s)) {
      h += '<div class="placement dispo nouveau b-cat-etf"><div><div class="nom">PEA <span class="pastille p-nouveau">NOUVEAU</span></div><div class="det">Choisissez « PEA » au moment d\'acheter une action, une SICAV ou un ETF. ' + UI.q("pea") + "</div></div></div>";
    }
    h += '<button type="button" class="btn btn-p btn-marche" id="btn-marche">+ ACHETER / VENDRE <span class="petit" style="color:inherit">(M)</span></button>';
    $("#col-placements").innerHTML = h;
  }

  function rendreFil() {
    var s = S(), j = s.journal[s.journal.length - 1];
    $("#fil-txt").textContent = j ? U.dateTxt(s.abDebut + j.m) + " · " + j.texte : U.dateTxt(a()) + " · Bienvenue ! Votre salaire vient d'être versé.";
  }

  /* Effets visuels d'un nouveau mois (float-up des revenus) */
  function effetsNotifs(notifs) {
    notifs.forEach(function (n) {
      if ((n.type === "interets" || n.type === "dividende" || n.type === "coupon") && n.montant > 0) {
        var cible = n.type === "interets" ? document.querySelector('[data-gerer="livret"]') : $("#b-cc");
        UI.floatUp("+" + U.txt(n.montant, a()), cible || $("#b-cc"));
        if (n.premier) UI.play($("#b-cc"), "ding");
      }
    });
  }

  return { init: init, rendre: rendre, majCurseur: majCurseur, etatPause: etatPause, effetsNotifs: effetsNotifs, vue: vue };
})();
