/* Événements à l'écran : journal (marché), courrier (vie), moment euro, objectif atteint, faillite,
   notifications et relecture des marqueurs de la frise (04 §3.5 à §3.10). */
var UIEvt = (function () {
  "use strict";
  var $ = UI.$;
  function S() { return App.S; }
  function ab() { return Moteur.abC(App.S); }
  function cap(t) { return t.charAt(0).toUpperCase() + t.slice(1); }

  function afficher(item) {
    if (!item) return;
    if (item.kind === "marche") journal(Moteur.evenement(S(), item.id), item, null);
    else if (item.kind === "vie") courrier(item.idx, item, false);
    else if (item.kind === "euro") euro(item);
    else if (item.kind === "objectif") objectif(item);
  }

  /* ---------- Journal ---------- */
  function enteteJournal(a) {
    var era = document.body.getAttribute("data-era") || "1980", j = window.DATA_TEXTES.journal[era] || window.DATA_TEXTES.journal[1980];
    return '<div class="j-tete"><span class="j-nom">' + U.esc(j.nom) + (j.etiquette ? '<span class="j-etiquette">' + j.etiquette + "</span>" : "") +
      "</span><span>" + cap(U.dateTxt(a)) + " · " + U.txt(Marche.baguette(a) * 1.6, a, { prix: true }) + "</span></div>";
  }
  function journal(ev, item, lecture) {
    var s = S(), a = lecture ? s.abDebut + lecture.m : ab();
    var cls = ev.gravite === "majeure" ? "spin" : "drop";
    var h = '<div class="journal ' + (lecture ? "" : cls) + '" id="journal">' + enteteJournal(a) +
      "<h2>" + U.esc(ev.titre) + '</h2><div class="chapo">' + U.esc(ev.texte) + "</div>";
    if (lecture) {
      var c = s.choix.filter(function (x) { return x.id === ev.id; })[0];
      h += '<div class="impact">' + (c ? "Votre choix : <b>" + libChoix(c.choix) + "</b>." : "Vous n'avez pas encore répondu.") + "</div>";
      if (c && c.m + 12 <= s.m) h += "<p>" + U.esc(Moteur.texteRappel(s, c).replace(/^[^.]*\. /, "")) + "</p><p><b>La leçon :</b> " + U.esc(ev.lecon) + "</p>";
      h += '<div class="choix"><button type="button" data-touche="1" data-focus>Fermer</button></div></div>';
      UI.ouvrirModale(h, { titre: ev.titre, onEchap: UI.fermerModale });
      $("#modale .choix button").addEventListener("click", UI.fermerModale);
      return;
    }
    var imp = Moteur.impactMarche(s, ev), detient = imp.v1 > 0.005;
    var pastille;
    if (ev.type === "+opportunite") {
      var pr = ev.produit ? Moteur.produit(s, ev.produit) : null, p = pr ? Moteur.cours(s, pr.id) : null;
      pastille = '<div class="impact gain">' + (pr && p ? (pr.type === "action" ? "Prix : " + U.txt(p, a, { prix: true }) + " l'action. " : "") : "") +
        "Votre compte courant : " + U.txt(s.joueur.cc, a) + "</div>";
    } else if (!detient) {
      pastille = ev.type === "-" ? '<div class="impact">Vous n\'avez pas d\'actions : votre argent est à l\'abri… mais les prix sont soldés.</div>'
        : '<div class="impact">Vous n\'avez pas d\'actions : la fête se passe sans vous… pour l\'instant.</div>';
    } else {
      pastille = '<div class="impact ' + U.classeVar(imp.diff) + '">VOTRE PORTEFEUILLE ' + U.fleche(imp.diff) + " " +
        U.txt(imp.diff, a, { signe: true }) + " (" + U.pct(imp.pct, 0) + " depuis " + U.dateTxt(imp.depuis) + ")</div>";
    }
    h += pastille + '<div id="j-zone">' + zoneChoix(ev) + "</div></div>";
    UI.ouvrirModale(h, { titre: ev.titre, delaiFocus: 1050, onEchap: function () { choisir(ev, item, ev.type === "-" && !detient ? "ecart" : "rien"); } });
    var jn = $("#journal");
    jn.addEventListener("animationend", function () { UI.thud(); }, { once: true });
    brancherChoix(ev, item);
  }
  function libChoix(c) {
    return { vendre: "Tout vendre", rien: "Ne rien faire", renforcer: "Renforcer", ecart: "Rester à l'écart", soldes: "Profiter des soldes",
      encaisser: "Encaisser mes gains", suivre: "Suivre la foule", souscrire: "Souscrire" }[c] || c;
  }
  function zoneChoix(ev) {
    var ch = Moteur.choixMarche(S(), ev);
    return '<div class="question-m">QUE FAITES-VOUS ?</div><div class="choix attente" id="j-choix">' + ch.map(function (c, i) {
      return '<button type="button" data-touche="' + (i + 1) + '" data-choix="' + c.id + '"' + (c.desactive ? " disabled" : "") + (i === 1 ? " data-focus" : "") +
        '><span class="k">' + (i + 1) + "</span><b>" + c.titre + "</b><small>" + c.sous + "</small></button>";
    }).join("") + "</div>";
  }
  function brancherChoix(ev, item) {
    var z = $("#j-choix");
    if (!z) return;
    setTimeout(function () { if (z) z.classList.remove("attente"); }, 1000); // pas de clic réflexe
    UI.$$("[data-choix]", z).forEach(function (b) {
      b.addEventListener("click", function () { choisir(ev, item, b.getAttribute("data-choix")); });
    });
  }
  function choisir(ev, item, choix) {
    var s = S(), a = ab();
    if (choix === "vendre" || choix === "encaisser") {
      var d = Moteur.devisVenteTotale(s, s.joueur);
      $("#j-zone").innerHTML = '<div class="impact">Vous vendez ' + d.lignes.length + " ligne" + (d.lignes.length > 1 ? "s" : "") + " pour " +
        U.txt(d.brut, a) + ", frais " + U.txt(d.frais, a) + ", impôt " + U.txt(d.impot, a) + ". Vous recevrez " + U.txt(d.recu, a) + ".</div>" +
        '<div class="choix"><button type="button" data-touche="1" id="j-ok" data-focus><span class="k">1</span><b>Confirmer</b></button>' +
        '<button type="button" data-touche="2" id="j-non"><span class="k">2</span><b>Je réfléchis encore</b></button></div>';
      $("#j-ok").focus();
      $("#j-ok").addEventListener("click", function () { finir(ev, item, choix); });
      $("#j-non").addEventListener("click", function () { $("#j-zone").innerHTML = zoneChoix(ev); brancherChoix(ev, item); $("#j-choix").classList.remove("attente"); });
      return;
    }
    finir(ev, item, choix);
  }
  function finir(ev, item, choix) {
    var s = S(), r = Moteur.resoudreMarche(s, item, choix);
    App.setVitesse(0); // après une modale de marché, le jeu reste en pause
    UI.fermerModale();
    App.sauver();
    UIJeu.rendre();
    if (r && r.lignes.length) UI.toast('<div class="t-titre">Tout est vendu</div><div class="t-txt">' + U.txt(r.recu, ab()) + " versés sur votre compte courant.</div>", { cls: "neutre" });
    if (["renforcer", "suivre", "souscrire", "soldes"].indexOf(choix) >= 0) {
      Tiroir.ouvrir(Moteur.produitCible(s, ev, choix), { mode: "acheter", montant: Math.max(0, s.joueur.cc) * 0.25 });
    } else {
      Tuto.indiceRelancer();
    }
  }

  /* ---------- Courrier (événement de vie) ---------- */
  function courrier(idx, item, lecture) {
    var s = S(), e = s.calendrier[idx], t = window.DATA_VIE.types[e.type], a = lecture ? s.abDebut + e.m : ab(), J = s.joueur;
    var signe = (t.effet === "gain" || t.effet === "augmentation") ? "gain" : (t.effet === "naissance" || t.effet === "escargots") ? "" : "perte";
    var h = '<div class="courrier ' + (signe ? "c-" + signe : "") + '" id="courrier"><div class="c-tete">✉ COURRIER · ' + U.dateTxt(a) + "</div>" +
      '<div class="picto">' + UI.icone(t.picto, 54) + "</div><h2>" + U.esc(t.titre) + "</h2><p>" + U.esc(Moteur.texteVie(s, e)) + "</p>";
    if (lecture) {
      h += '<div class="c-btns"><button type="button" class="btn" id="c-fermer" data-focus>Fermer</button></div></div>';
      UI.ouvrirModale(h, { titre: t.titre, onEchap: UI.fermerModale });
      $("#c-fermer").addEventListener("click", UI.fermerModale);
      return;
    }
    h += '<div id="c-zone"></div></div>';
    UI.ouvrirModale(h, { titre: t.titre, onEchap: function () { echapCourrier(idx, item); } });
    zoneCourrier(idx, item);
  }
  function echapCourrier(idx, item) {
    var e = S().calendrier[idx], t = window.DATA_VIE.types[e.type];
    if (t.effet === "escargots") return resoudre(item, "non");
    if (t.effet === "chomage" || t.effet === "augmentation" || t.effet === "naissance") return resoudre(item, "ok");
    // Les coûts et les gains demandent un vrai clic
  }
  function zoneCourrier(idx, item) {
    var s = S(), e = s.calendrier[idx], t = window.DATA_VIE.types[e.type], a = ab(), J = s.joueur, z = $("#c-zone");
    var dep = Moteur.depenses(s, a).total, h = "";
    if (t.effet === "cout" || t.effet === "demenagement") {
      if (J.cc >= e.montant - 0.005) {
        var c0 = Math.max(0, J.cc + J.livret) / dep, c1 = Math.max(0, J.cc - e.montant + J.livret) / dep;
        h += '<div class="impact">Votre coussin passe de ' + U.nombre(c0, 1) + " à " + U.nombre(c1, 1) + " mois. " + UI.q("coussin") + "</div>" +
          '<div class="c-btns"><button type="button" class="btn btn-p" data-touche="1" data-act="payer" data-focus>Payer ' + U.txt(e.montant, a) + "</button></div>";
      } else {
        h += '<div class="impact perte">Compte courant : ' + U.txt(J.cc, a) + " · ⚠ il manque " + U.txt(e.montant - J.cc, a) + "</div>" +
          '<div class="c-btns"><button type="button" class="btn" data-touche="1" data-act="vendre" data-focus><b>VENDRE UN PLACEMENT…</b><br><span class="petit">Choisir quoi vendre</span></button>' +
          '<button type="button" class="btn" data-touche="2" data-act="decouvert"><b>PASSER À DÉCOUVERT</b><br><span class="petit">Agios de ' +
          Marche.tauxAgios(U.annee(a)) + " % par an " + "</span></button></div>" + '<div id="c-liste"></div>';
      }
    } else if (t.effet === "gain") {
      h += '<div class="c-btns"><button type="button" class="btn btn-p" data-touche="1" data-act="encaisser" data-focus>Encaisser ' + U.txt(e.montant, a) + "</button></div>";
    } else if (t.effet === "escargots") {
      var mise = (e.M || 1) * s.vie.salaireBase;
      h += '<div class="c-btns"><button type="button" class="btn" data-touche="1" data-act="fonce"><b>Je fonce</b> <span class="petit">Investir ' + U.txt(mise, a) + "</span></button>" +
        '<button type="button" class="btn" data-touche="2" data-act="non" data-focus><b>Non merci</b> <span class="petit">Garder mon argent</span></button></div>';
    } else {
      h += '<div class="c-btns"><button type="button" class="btn btn-p" data-touche="1" data-act="ok" data-focus>D\'accord</button></div>';
    }
    z.innerHTML = h;
    UI.$$("[data-act]", z).forEach(function (b) {
      b.addEventListener("click", function () {
        var act = b.getAttribute("data-act");
        if (act === "vendre") { listeVente(idx, item); return; }
        if (act === "encaisser" && (e.type === "heritage" || e.tuto)) {
          Moteur.resoudreVie(s, item, "encaisser");
          UI.floatUp("+" + U.txt(e.montant, a), $("#b-cc"));
          UIJeu.rendre();
          if (e.tuto) { terminerVie(); Tuto.action("encaisser"); return; }
          z.innerHTML = '<p><b>Que faire de cet argent ?</b> Le marché est ouvert.</p><div class="c-btns">' +
            '<button type="button" class="btn btn-p" data-touche="1" id="c-marche">Ouvrir le marché</button>' +
            '<button type="button" class="btn" data-touche="2" id="c-tard" data-focus>Plus tard</button></div>';
          $("#c-tard").focus();
          $("#c-tard").addEventListener("click", terminerVie);
          $("#c-marche").addEventListener("click", function () { terminerVie(); Tiroir.ouvrir(null); });
          return;
        }
        resoudre(item, act);
      });
    });
  }
  function listeVente(idx, item) {
    var s = S(), e = s.calendrier[idx], a = ab(), J = s.joueur, t = window.DATA_VIE.types[e.type], z = $("#c-liste");
    var besoin = e.montant - J.cc, h = '<div class="liste-vente"><p class="petit">Il manque ' + U.txt(besoin, a) + ". Que vendez-vous ?</p>";
    if (J.livret > 0.5) h += '<button type="button" class="btn" data-v="livret|"><span>Livret A</span><span>' + U.txt(J.livret, a) + " ● 0 %</span></button>";
    if (J.tranches.length) h += '<button type="button" class="btn" data-v="emprunt|"><span>Emprunt d\'État</span><span>' + U.txt(Moteur.totalEmprunt(J), a) + " ● 0 %</span></button>";
    Moteur.lignes(J).forEach(function (l) {
      var pr = Moteur.produit(s, l.id), v = Moteur.valeurLigne(s, l), perf = l.cout > 0 ? v / l.cout - 1 : 0;
      h += '<button type="button" class="btn" data-v="' + l.id + "|" + l.env + '"><span>' + U.esc(pr.court) + (l.env === "PEA" ? " (PEA)" : "") +
        "</span><span>" + U.txt(v, a) + " " + U.varHtml(perf, 0) + "</span></button>";
    });
    if (h.indexOf("data-v") < 0) h += '<p>Vous n\'avez rien à vendre.</p>';
    z.innerHTML = h + "</div>";
    UI.$$("[data-v]", z).forEach(function (b) {
      b.addEventListener("click", function () {
        var p = b.getAttribute("data-v").split("|"), manque = e.montant - J.cc;
        if (p[0] === "livret") Moteur.retirerLivret(s, J, manque);
        else if (p[0] === "emprunt") Moteur.revendreEmprunt(s, J, manque);
        else {
          var l = J.lignes[p[0] + "|" + p[1]], val = Moteur.valeurLigne(s, l), f = Marche.frais(a);
          var brut = manque * 1.02 + f.min + manque * 0.4; // marge pour frais et impôt
          Moteur.vendre(s, J, p[0], p[1], brut, { tout: val <= brut, forcee: true, evt: t.titre });
          var vf = s.stats.ventesForcees[s.stats.ventesForcees.length - 1];
          if (vf && vf.perf < 0) UI.toast('<div class="t-titre">Vendu à perte</div><div class="t-txt">Vendu à ' + U.pct(vf.perf, 0) +
            " pour payer. Un coussin plus épais vous l'aurait évité.</div>", { cls: "perte" });
        }
        UIJeu.rendre();
        zoneCourrier(idx, item);
      });
    });
  }
  function resoudre(item, choix) {
    var s = S();
    Moteur.resoudreVie(s, item, choix);
    terminerVie();
    if (choix === "decouvert") UIJeu.rendre();
  }
  function terminerVie() {
    UI.fermerModale();
    App.sauver();
    UIJeu.rendre();
  }

  /* ---------- Moment euro (1er janvier 2002) ---------- */
  function euro(item) {
    var s = S(), a = ab(), J = s.joueur, patr = Moteur.patrimoine(s, J), sal = Moteur.salaireDuMois(s), bag = Marche.baguette(a);
    function l(lib, v, prix) {
      return "<tr><td>" + lib + "</td><td>" + U.montantDevise(v, "F", { prix: prix }) + "</td><td>→</td><td>" + U.montantDevise(v, "€", { prix: prix }) + "</td></tr>";
    }
    var h = '<div class="panneau centre"><div class="petit">1<sup>er</sup> JANVIER 2002</div><h2>BONJOUR L\'EURO !</h2>' +
      '<svg class="piece" viewBox="0 0 70 70" aria-hidden="true"><circle cx="35" cy="35" r="32" fill="#D9B44A" stroke="#8A6D1F" stroke-width="3"/>' +
      '<circle cx="35" cy="35" r="22" fill="#C9C9C9" stroke="#8A8A8A" stroke-width="2"/><text x="35" y="44" text-anchor="middle" font-size="26" font-weight="700" fill="#333">€</text></svg>' +
      "<p><b>1 € = 6,55957 F</b></p><table class=\"euro-table\">" + l("Votre patrimoine", patr) + l("Une baguette", bag, true) + l("Votre salaire", sal) + "</table>" +
      "<p>Astuce : divisez par 6,5… ou par 7 de tête.<br>Les francs restent affichés en petit pendant un an.</p>" +
      '<button type="button" class="btn btn-p" id="euro-ok" data-touche="1" data-focus>Adieu le franc !</button></div>';
    UI.ouvrirModale(h, { titre: "Bonjour l'euro", onEchap: fermerEuro });
    $("#euro-ok").addEventListener("click", fermerEuro);
    function fermerEuro() {
      s.flags.euroVu = true;
      if (s.modale === item) s.modale = null;
      UI.fermerModale();
      UIJeu.rendre();
      App.sauver();
      if (!UI.animReduites()) UI.$$("#ecran-jeu .mt").forEach(function (el, i) {
        el.style.animationDelay = Math.min(i * 30, 600) + "ms"; UI.play(el, "euro-flip");
      });
    }
  }

  /* ---------- Fins anticipées ---------- */
  function objectif(item) {
    var s = S(), a = ab(), o = window.DATA_REGLES.objectifs[s.objectif], mL = s.cibles.mLimite[s.objectif];
    var avance = mL - s.m + 1;
    var h = '<div class="panneau centre"><h2>OBJECTIF ATTEINT !</h2><p>' + (s.objectif === "maison" ? "Vous avez réuni votre apport de " : "Vous avez atteint ") +
      U.txt(s.cibles[s.objectif], a) + " en " + U.dateTxt(a) + (avance > 0 ? ", avec " + U.duree(avance) + " d'avance" : "") + ".</p>" +
      '<div class="c-btns" style="display:flex;gap:.6rem;justify-content:center"><button type="button" class="btn btn-p" data-touche="1" id="o-bilan">Voir mon bilan</button>' +
      '<button type="button" class="btn" data-touche="2" id="o-libre" data-focus>Continuer en partie libre</button></div></div>';
    UI.ouvrirModale(h, { titre: o.libelle, onEchap: libre });
    UI.confettis(40);
    $("#o-bilan").addEventListener("click", function () { s.modale = null; s.fin = "objectif"; UI.fermerModale(); App.finPartie(); });
    $("#o-libre").addEventListener("click", libre);
    function libre() { s.partieLibre = true; s.modale = null; UI.fermerModale(); App.sauver(); UIJeu.rendre(); }
  }
  function faillite() {
    var a = ab();
    var h = '<div class="courrier c-perte"><div class="c-tete">✉ COURRIER DE VOTRE BANQUE · ' + U.dateTxt(a) + "</div>" +
      '<div class="picto">' + UI.icone("enveloppe", 54) + "</div><h2>Trois mois dans le rouge</h2>" +
      "<p>Votre banquier a confisqué votre chéquier. Vous finissez chez votre belle-mère, qui vous rappelle tous les soirs qu'un coussin de 3 mois, ça ne coûte rien.</p>" +
      '<div class="c-btns"><button type="button" class="btn btn-p" id="f-bilan" data-touche="1" data-focus>Voir mon bilan</button></div></div>';
    UI.ouvrirModale(h, { titre: "Faillite", onEchap: function () {} });
    $("#f-bilan").addEventListener("click", function () { UI.fermerModale(); App.finPartie(); });
  }

  /* ---------- Relecture d'un marqueur de la frise ---------- */
  function revoir(i) {
    var s = S(), mq = s.marqueurs[i];
    if (!mq || UI.modaleOuverte()) return;
    if (mq.type === "marche") journal(Moteur.evenement(s, mq.ref), null, { m: mq.m });
    else if (mq.type === "vie") courrier(mq.ref, null, true);
    else if (mq.type === "produit") {
      var pr = Moteur.produit(s, mq.ref);
      UI.toast('<div class="t-titre">' + U.dateTxt(s.abDebut + mq.m) + " · Nouveau</div><div class=\"t-txt\">" + U.esc(pr.texteNouveau || pr.nom) + "</div>", { nouveau: true });
    }
  }

  /* ---------- Notifications ---------- */
  function notifier(n) {
    var s = S(), a = ab(), h = "";
    var mt = n.montant !== undefined ? '<span class="' + U.classeVar(n.montant) + '">' + U.txt(n.montant, a, { signe: true }) + "</span>" : "";
    if (n.type === "bilan") {
      var b = n.bilan;
      h = '<div class="t-titre">' + U.esc(n.titre).toUpperCase() + "</div><table>" +
        "<tr><td>Votre patrimoine</td><td>" + (b.pctSignificatif ? U.varHtml(b.varPatr)
          : '<span class="' + U.classeVar(b.patrA - b.patr0) + '">' + U.txt(b.patrA - b.patr0, a, { signe: true }) + "</span>") + "</td></tr>" +
        "<tr><td>Les prix (inflation) " + UI.q("inflation") + "</td><td>" + U.varHtml(b.inflation) + "</td></tr>" +
        (b.pctSignificatif ? "<tr><td>Votre pouvoir d'achat " + UI.q("pouvoir") + "</td><td>" + U.varHtml(b.pouvoir) + "</td></tr>" : "") +
        "<tr><td>" + (b.pctSignificatif ? "&nbsp;&nbsp;soit" : "Votre pouvoir d'achat " + UI.q("pouvoir")) + "</td><td>" +
        (b.baguettes >= 0 ? "+" : U.MOINS) + U.nombre(Math.abs(b.baguettes), 0) + " " + UI.icone("baguette", 14) + "</td></tr>" +
        (b.interets > 0.5 ? "<tr><td>Intérêts du livret</td><td class='gain'>" + U.txt(b.interets, a, { signe: true }) + "</td></tr>" : "") +
        (b.coupons > 0.5 ? "<tr><td>Coupons d'emprunt</td><td class='gain'>" + U.txt(b.coupons, a, { signe: true }) + "</td></tr>" : "") +
        (b.dividendes > 0.5 ? "<tr><td>Dividendes reçus</td><td class='gain'>" + U.txt(b.dividendes, a, { signe: true }) + "</td></tr>" : "") +
        "</table>";
      UI.toast(h, { persistante: true, cls: "neutre", annonce: "Bilan de l'année " + b.annee });
      return;
    }
    h = '<div class="t-titre"><span>' + (n.type === "vie" ? UI.icone(n.picto || "etoile", 14) + " " : "") + U.esc(n.titre) + "</span>" + mt + "</div>" +
      '<div class="t-txt">' + U.esc(n.texte || "") + "</div>";
    if (n.type === "nouveau") {
      h += '<div class="t-btns"><button type="button" class="btn btn-mini btn-p" data-dec="' + n.produit + '">Découvrir</button><button type="button" class="btn btn-mini" data-tard>Plus tard</button></div>';
      var t = UI.toast(h, { persistante: true, nouveau: true, annonce: n.titre });
      t.querySelector("[data-dec]").addEventListener("click", function () {
        UI.retirerToast(t);
        App.setVitesse(0);
        var id = n.produit;
        if (id === "pea") {
          var cands = Moteur.produitsDisponibles(s).filter(function (x) { return Moteur.eligiblePEA(Moteur.produit(s, x)); });
          Tiroir.ouvrir(cands[0], { mode: "acheter", env: "PEA" });
        } else Tiroir.ouvrir(id);
      });
      t.querySelector("[data-tard]").addEventListener("click", function () { UI.retirerToast(t); });
      return;
    }
    UI.toast(h, { persistante: !!n.persistante, cls: n.cls, info: n.type === "info" || n.type === "decennie", annonce: n.titre });
  }

  return { afficher: afficher, journal: journal, courrier: courrier, euro: euro, objectif: objectif, faillite: faillite,
    revoir: revoir, notifier: notifier };
})();
