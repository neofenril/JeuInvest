/* Briques d'interface partagées : DOM, animations, icônes, notifications, modale, glossaire, courbes SVG. */
var UI = (function () {
  "use strict";

  function $(sel, racine) { return (racine || document).querySelector(sel); }
  function $$(sel, racine) { return Array.prototype.slice.call((racine || document).querySelectorAll(sel)); }
  function animReduites() { return document.documentElement.getAttribute("data-anim") === "reduit"; }

  /* Pose une classe d'animation puis la retire à la fin (04 §6.2) */
  function play(el, cls) {
    if (!el) return;
    el.classList.remove(cls);
    void el.offsetWidth; // relance l'animation
    el.classList.add(cls);
    el.addEventListener("animationend", function f() { el.classList.remove(cls); el.removeEventListener("animationend", f); });
  }
  function thud() { play(document.getElementById("app"), "thud"); }

  /* count-roll : interpolation easeOutCubic */
  function compteur(el, de, a, duree, format) {
    if (!el) return;
    if (animReduites() || document.hidden || duree <= 0 || Math.abs(a - de) < 0.01) { el._roll = (el._roll || 0) + 1; el.innerHTML = format(a); return; }
    var t0 = performance.now(), id = (el._roll = (el._roll || 0) + 1);
    function pas(t) {
      if (el._roll !== id) return;
      var k = Math.min(1, (t - t0) / duree), e = 1 - Math.pow(1 - k, 3);
      el.innerHTML = format(de + (a - de) * e);
      if (k < 1) requestAnimationFrame(pas);
    }
    requestAnimationFrame(pas);
    // filet de sécurité : la valeur finale s'affiche même si l'animation est suspendue
    setTimeout(function () { if (el._roll === id) { el._roll++; el.innerHTML = format(a); } }, duree + 150);
  }

  function floatUp(texte, cible, cls) {
    if (!cible || animReduites()) return;
    var r = cible.getBoundingClientRect(), d = document.createElement("div");
    d.className = "float-up " + (cls || "");
    d.textContent = texte;
    d.style.left = (r.left + r.width / 2 - 30) + "px";
    d.style.top = (r.top - 4) + "px";
    document.body.appendChild(d);
    setTimeout(function () { d.remove(); }, 1100);
  }

  /* Confettis en canvas, puis suppression du canvas (04 §6.1) */
  function confettis(n) {
    if (animReduites()) return;
    var c = document.createElement("canvas"), ctx = c.getContext("2d");
    c.width = window.innerWidth; c.height = window.innerHeight;
    c.style.cssText = "position:fixed;inset:0;pointer-events:none;z-index:95";
    document.body.appendChild(c);
    var couleurs = ["#B0174F", "#1B7A3E", "#D99A2B", "#2E86AB", "#6A1B9A", "#D98A00"], parts = [];
    for (var i = 0; i < n; i++) {
      parts.push({ x: Math.random() * c.width, y: -20 - Math.random() * c.height * 0.4, vx: (Math.random() - 0.5) * 3,
        vy: 2 + Math.random() * 3, r: Math.random() * Math.PI, vr: (Math.random() - 0.5) * 0.3,
        w: 6 + Math.random() * 6, h: 4 + Math.random() * 4, col: couleurs[i % couleurs.length] });
    }
    var t0 = performance.now();
    function pas(t) {
      ctx.clearRect(0, 0, c.width, c.height);
      parts.forEach(function (p) {
        p.vy += 0.06; p.x += p.vx; p.y += p.vy; p.r += p.vr;
        ctx.save(); ctx.translate(p.x, p.y); ctx.rotate(p.r); ctx.fillStyle = p.col;
        ctx.fillRect(-p.w / 2, -p.h / 2, p.w, p.h); ctx.restore();
      });
      if (t - t0 < 2500) requestAnimationFrame(pas); else c.remove();
    }
    requestAnimationFrame(pas);
  }

  /* ---------- Icônes SVG (trait de 2 px, pas d'emoji) ---------- */
  var ICO = {
    voiture: '<path d="M5 17h14M3 13l2-5h14l2 5v4H3z"/><circle cx="7.5" cy="17" r="2"/><circle cx="16.5" cy="17" r="2"/>',
    maison: '<path d="M3 11l9-7 9 7M5 10v10h14V10M10 20v-6h4v6"/>',
    bebe: '<circle cx="12" cy="9" r="5"/><path d="M6 21c1-4 11-4 12 0M10 9h.01M14 9h.01"/>',
    coeur: '<path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.5-7 10-7 10z"/>',
    valise: '<rect x="3" y="7" width="18" height="13" rx="2"/><path d="M9 7V4h6v3"/>',
    chaudiere: '<rect x="6" y="3" width="12" height="18" rx="2"/><circle cx="12" cy="13" r="3"/><path d="M9 7h6"/>',
    enveloppe: '<rect x="3" y="5" width="18" height="14" rx="1"/><path d="M3 6l9 7 9-7"/>',
    piece: '<circle cx="12" cy="12" r="9"/><path d="M15 9h-4a2 2 0 0 0 0 4h2a2 2 0 0 1 0 4H9"/>',
    billet: '<rect x="2" y="6" width="20" height="12" rx="1"/><circle cx="12" cy="12" r="3"/>',
    baguette: '<path d="M4 18L18 4c2 0 2 2 2 2L6 20s-2 0-2-2zM9 13l2 2M12 10l2 2M15 7l2 2"/>',
    etoile: '<path d="M12 3l2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z"/>',
    drapeau: '<path d="M5 21V4h11l-2 4 2 4H5"/>',
    journal: '<rect x="3" y="4" width="18" height="16" rx="1"/><path d="M7 8h10M7 12h10M7 16h6"/>'
  };
  function icone(nom, taille) {
    taille = taille || 24;
    return '<svg viewBox="0 0 24 24" width="' + taille + '" height="' + taille + '" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + (ICO[nom] || ICO.enveloppe) + "</svg>";
  }

  /* ---------- Glossaire « C'est quoi ? » ---------- */
  var glossIndex = {};
  (window.DATA_GLOSSAIRE || []).forEach(function (g) { glossIndex[g.id] = g; });
  function q(id) { return '<button type="button" class="qq" data-g="' + id + '" aria-label="C\'est quoi ?">?</button>'; }
  function defGloss(id) {
    var g = glossIndex[id];
    if (!g) return null;
    var a = (window.App && App.S) ? Moteur.abC(App.S) : U.ab(2025, 1);
    return { terme: g.terme, def: U.gabarit(g.def, { indice: Marche.nomIndice(a).replace(/^l[ea]? ?'?/, "") }) };
  }
  var bulleTimer = null, bulleCible = null;
  function montrerBulle(el) {
    var id = el.getAttribute("data-g"), d = defGloss(id), b = document.getElementById("bulle-glossaire");
    if (!d || !b) return;
    if (window.App && App.S) App.S.notionsVues[id] = true;
    b.innerHTML = "<b>" + U.esc(d.terme) + "</b>" + U.esc(d.def);
    b.hidden = false;
    var r = el.getBoundingClientRect(), bw = b.offsetWidth, bh = b.offsetHeight;
    var x = U.clamp(r.left + r.width / 2 - bw / 2, 8, window.innerWidth - bw - 8);
    var y = r.top - bh - 8; if (y < 8) y = r.bottom + 8;
    b.style.left = x + "px"; b.style.top = y + "px";
    bulleCible = el;
  }
  function cacherBulle() {
    clearTimeout(bulleTimer);
    var b = document.getElementById("bulle-glossaire");
    if (b) b.hidden = true;
    bulleCible = null;
  }
  function initGlossaire() {
    document.addEventListener("mouseover", function (e) {
      var el = e.target.closest && e.target.closest(".qq");
      if (!el) return;
      clearTimeout(bulleTimer);
      bulleTimer = setTimeout(function () { montrerBulle(el); }, 300);
    });
    document.addEventListener("mouseout", function (e) {
      var el = e.target.closest && e.target.closest(".qq");
      if (el) cacherBulle();
    });
    document.addEventListener("focusin", function (e) {
      if (e.target.classList && e.target.classList.contains("qq")) montrerBulle(e.target);
    });
    document.addEventListener("focusout", function (e) {
      if (e.target.classList && e.target.classList.contains("qq")) cacherBulle();
    });
    document.addEventListener("click", function (e) {
      var el = e.target.closest && e.target.closest(".qq");
      if (el) { e.preventDefault(); e.stopPropagation(); if (bulleCible === el) cacherBulle(); else montrerBulle(el); }
    }, true);
  }

  /* ---------- Notifications (3 visibles au maximum) ---------- */
  var MAX_TOASTS = 3;
  function toast(contenuHtml, opts) {
    opts = opts || {};
    var zone = document.getElementById("toasts");
    if (!zone) return null;
    var t = document.createElement("div");
    t.className = "toast t-" + (opts.cls || "neutre") + (opts.nouveau ? " t-nouveau" : "") + (opts.info ? " t-info" : "");
    t.setAttribute("role", "status");
    t.innerHTML = contenuHtml + '<button type="button" class="t-x" aria-label="Fermer">✕</button>';
    t.querySelector(".t-x").addEventListener("click", function () { retirerToast(t); });
    t._persist = !!opts.persistante;
    zone.appendChild(t);
    var anciennes = $$(".toast", zone).filter(function (x) { return x !== t && !x._out; });
    while (anciennes.length > MAX_TOASTS - 1) {
      // on retire d'abord les non persistantes, puis les plus anciennes
      var cand = anciennes.filter(function (x) { return !x._persist; })[0] || anciennes[0];
      retirerToast(cand);
      anciennes.splice(anciennes.indexOf(cand), 1);
    }
    if (!opts.persistante) {
      var duree = (window.App && App.vitesse === 3) ? 3000 : 5000;
      setTimeout(function () { retirerToast(t); }, opts.duree || duree);
    }
    var ann = document.getElementById("annonce");
    if (ann && opts.annonce) ann.textContent = opts.annonce;
    return t;
  }
  function retirerToast(t) {
    if (!t || t._out) return;
    t._out = true;
    t.classList.add("out");
    setTimeout(function () { t.remove(); }, 220);
  }
  function viderToasts() { var z = document.getElementById("toasts"); if (z) z.innerHTML = ""; }

  /* ---------- Modale unique (role=dialog, piège du focus) ---------- */
  var modale = { ouverte: false, opts: null, retourFocus: null };
  function ouvrirModale(html, opts) {
    opts = opts || {};
    var fond = document.getElementById("modale-fond"), m = document.getElementById("modale");
    if (!modale.ouverte) modale.retourFocus = document.activeElement;
    m.innerHTML = html;
    m.setAttribute("aria-label", opts.titre || "Fenêtre");
    fond.hidden = false;
    modale.ouverte = true; modale.opts = opts;
    cacherBulle();
    if (window.App) App.bloquer("modale");
    setTimeout(function () {
      var f = m.querySelector("[data-focus]") || m.querySelector("button:not([disabled]), input, select");
      if (f) f.focus({ preventScroll: true });
    }, opts.delaiFocus || 30);
    return m;
  }
  function fermerModale() {
    var fond = document.getElementById("modale-fond");
    if (!modale.ouverte) return;
    fond.hidden = true;
    document.getElementById("modale").innerHTML = "";
    modale.ouverte = false;
    var cb = modale.opts && modale.opts.onFerme;
    modale.opts = null;
    if (window.App) App.debloquer("modale");
    if (modale.retourFocus && modale.retourFocus.focus && document.body.contains(modale.retourFocus)) {
      try { modale.retourFocus.focus({ preventScroll: true }); } catch (e) { /* rien */ }
    }
    if (cb) cb();
  }
  function modaleOuverte() { return modale.ouverte; }
  /* Clavier dans la modale : Tab piégé, Échap, touches 1-3 */
  function clavierModale(e) {
    if (!modale.ouverte) return false;
    var m = document.getElementById("modale");
    if (e.key === "Tab") {
      var f = $$("button:not([disabled]), input:not([disabled]), select, [tabindex='0']", m);
      if (!f.length) return true;
      var i = f.indexOf(document.activeElement);
      if (e.shiftKey && (i <= 0)) { f[f.length - 1].focus(); e.preventDefault(); }
      else if (!e.shiftKey && (i === f.length - 1 || i < 0)) { f[0].focus(); e.preventDefault(); }
      return true;
    }
    if (e.key === "Escape") {
      e.preventDefault();
      if (modale.opts && modale.opts.onEchap) modale.opts.onEchap();
      return true;
    }
    if (/^[1-9]$/.test(e.key)) {
      var b = m.querySelector('[data-touche="' + e.key + '"]');
      if (b && !b.disabled && !b.closest(".attente")) { e.preventDefault(); b.click(); }
      return true;
    }
    return e.key === " " || e.key === "m" || e.key === "M" || e.key === "p" || e.key === "P";
  }

  /* ---------- Courbes SVG ---------- */
  function chemin(points) {
    var d = "", debut = true;
    points.forEach(function (p) {
      if (p === null || p[1] === null || isNaN(p[1])) { debut = true; return; }
      d += (debut ? "M" : "L") + p[0].toFixed(1) + " " + p[1].toFixed(1);
      debut = false;
    });
    return d;
  }
  function sparkline(valeurs, w, h) {
    var v = valeurs.filter(function (x) { return x !== null && x !== undefined; });
    if (v.length < 2) return '<svg viewBox="0 0 ' + w + " " + h + '"></svg>';
    var min = Math.min.apply(null, v), max = Math.max.apply(null, v), e = max - min || 1;
    var pts = v.map(function (x, i) { return [i / (v.length - 1) * w, h - 2 - (x - min) / e * (h - 4)]; });
    return '<svg viewBox="0 0 ' + w + " " + h + '" preserveAspectRatio="none" aria-hidden="true"><path d="' + chemin(pts) + '"/></svg>';
  }
  /* Graduation ronde : au plus 4 valeurs */
  function graduations(max) {
    if (max <= 0) return [0];
    var brut = max / 3, p = Math.pow(10, Math.floor(Math.log10(brut))), n = brut / p;
    var pas = (n <= 1 ? 1 : n <= 2 ? 2 : n <= 5 ? 5 : 10) * p, out = [];
    for (var v = 0; v <= max * 1.0001 && out.length < 5; v += pas) out.push(v);
    if (out[out.length - 1] < max) out.push(out[out.length - 1] + pas);
    return out.slice(0, 5);
  }
  function longueurChemins(racine) {
    $$("path.dessin", racine).forEach(function (p) {
      try { p.style.setProperty("--len", Math.ceil(p.getTotalLength())); } catch (e) { /* rien */ }
    });
  }

  return {
    $: $, $$: $$, play: play, thud: thud, compteur: compteur, floatUp: floatUp, confettis: confettis,
    icone: icone, q: q, defGloss: defGloss, initGlossaire: initGlossaire, cacherBulle: cacherBulle,
    toast: toast, retirerToast: retirerToast, viderToasts: viderToasts,
    ouvrirModale: ouvrirModale, fermerModale: fermerModale, modaleOuverte: modaleOuverte, clavierModale: clavierModale,
    chemin: chemin, sparkline: sparkline, graduations: graduations, longueurChemins: longueurChemins,
    animReduites: animReduites
  };
})();
