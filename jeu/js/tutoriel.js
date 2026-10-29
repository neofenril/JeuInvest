/* Tutoriel de la première année (04 §5.2, T1 à T7) : une bulle de 2 lignes à la fois, une action réelle par étape. */
var Tuto = (function () {
  "use strict";
  var $ = UI.$;
  var t = { actif: false, courante: null, timer: null, cible: null };

  /* m : index du mois (0 = premier mois) ; pause : met le jeu en pause ; attend : action qui ferme la bulle */
  function etapes() {
    return [
      { id: "T1", m: 0, cible: "#b-cc", pause: true, texte: "Votre salaire tombe ici chaque mois. Le loyer et les courses partent aussitôt.",
        boutons: [["OK", function () { suivante(); }]] },
      { id: "T2", m: 0, cible: "#btn-play", attend: "play", texte: "Le temps est en pause. Lancez-le ! Espace pour mettre en pause à tout moment." },
      { id: "T3", m: 1, cible: "#bloc-coussin", pause: true, texte: "Un imprévu arrive toujours. Mettez 3 mois de dépenses de côté sur le Livret A.",
        boutons: [["Ouvrir le Livret A", function () {
          var s = App.S, J = s.joueur, dep = Moteur.depenses(s, Moteur.abC(s)).total;
          var m = Math.max(0, Math.min(J.cc, 3 * dep - J.livret, Marche.plafondLivret(Moteur.abC(s)) - J.livret));
          suivante(); Tiroir.ouvrir("livret", { mode: "deposer", montant: m });
        }], ["Plus tard", function () { suivante(); }]] },
      { id: "T4", m: 2, cible: "#b-baguette", duree: 6000, texte: function () {
        var s = App.S, a = Moteur.abC(s), d = Marche.baguette(a) - Marche.baguette(a - 2);
        return "La baguette a pris " + U.txt(d, a, { prix: true }) + " en 2 mois. Les prix montent : c'est l'inflation.";
      } },
      { id: "T5", m: 3, cible: "#col-placements", pause: true, texte: "Les actions montent et descendent, mais rapportent plus à long terme. Essayez avec un petit montant ?",
        boutons: [["Essayer", function () {
          var s = App.S, ids = Moteur.produitsDisponibles(s).filter(function (id) { return Moteur.produit(s, id).type === "action"; });
          suivante(); Tiroir.ouvrir(ids[0] || null, { mode: "acheter", montant: Math.max(0, s.joueur.cc) * 0.25 });
        }], ["Plus tard", function () { suivante(); }]] },
      { id: "T6", m: 5, cible: "#btn-marche", pause: true, texte: "Un petit montant chaque mois, sans y penser : c'est la méthode de Cousin… vous verrez.",
        boutons: [["Voir", function () {
          var s = App.S, f = Moteur.estDisponible(s, "etf") && Moteur.mkt(s).infos.etf ? "etf" : (Moteur.mkt(s).infos.sicav ? "sicav" : null);
          suivante(); Tiroir.ouvrir(f, { eclaireAuto: true });
        }], ["Plus tard", function () { suivante(); }]] },
      { id: "FIN", m: 12, cible: "#b-date", pause: true, texte: "C'est vous qui pilotez, maintenant. Bonne chance !",
        boutons: [["OK", function () { terminer(); }]] }
    ];
  }

  function actif() { return t.actif; }
  function liste() { return t.liste || (t.liste = etapes()); }

  function demarrer(S) {
    t.liste = etapes();
    t.actif = !!S.tutoriel;
    if (S.flags.tutoIndex === undefined) S.flags.tutoIndex = 0;
    if (!t.actif) return;
    verifier(S, !!S.modale);
  }
  /* Appelé à chaque nouveau mois ; « modale » indique qu'une modale occupe déjà ce mois */
  function surMois(S, modale) {
    if (!t.actif) return;
    // une bulle sans bouton (T4) disparaît au plus tard deux mois après son apparition
    if (t.courante && t.courante.duree && S.m >= t.courante.m + 2) suivante();
    var l = liste(), e = l[S.flags.tutoIndex];
    if (!e) return;
    if (e.m <= S.m && modale) { e.m = S.m + 1; return; } // l'étape est décalée d'un mois
    verifier(S, modale);
  }
  function verifier(S, modale) {
    var l = liste(), e = l[S.flags.tutoIndex];
    if (!e || t.courante || modale) return;
    if (e.m <= S.m) montrer(e);
  }
  function montrer(e) {
    t.courante = e;
    if (e.pause) App.bloquer("tuto");
    var co = document.getElementById("coach");
    var txt = typeof e.texte === "function" ? e.texte() : e.texte;
    var h = "<div>" + U.esc(txt) + '</div><div class="co-btns">';
    (e.boutons || []).forEach(function (b, i) { h += '<button type="button" data-cob="' + i + '">' + U.esc(b[0]) + "</button>"; });
    h += '<button type="button" class="co-passer" id="co-passer">Passer le tutoriel</button></div>';
    co.innerHTML = h;
    co.hidden = false;
    UI.$$("[data-cob]", co).forEach(function (b) {
      b.addEventListener("click", function () { e.boutons[+b.getAttribute("data-cob")][1](); });
    });
    $("#co-passer").addEventListener("click", passer);
    var cible = document.querySelector(e.cible);
    t.cible = cible;
    if (cible) cible.classList.add("spotlight");
    placer(co, cible);
    var f = co.querySelector("[data-cob]");
    if (f) setTimeout(function () { f.focus({ preventScroll: true }); }, 30);
    if (e.duree) t.timer = setTimeout(function () { if (t.courante === e) suivante(); }, e.duree);
  }
  function placer(co, cible) {
    if (!cible) { co.style.left = "50%"; co.style.top = "40%"; return; }
    var r = cible.getBoundingClientRect(), w = co.offsetWidth, h = co.offsetHeight;
    var x = U.clamp(r.left + r.width / 2 - w / 2, 8, window.innerWidth - w - 8);
    var y = r.bottom + 10;
    if (y + h > window.innerHeight - 8) y = Math.max(8, r.top - h - 10);
    co.style.left = x + "px"; co.style.top = y + "px";
  }
  function cacher() {
    clearTimeout(t.timer);
    var co = document.getElementById("coach");
    if (co) co.hidden = true;
    if (t.cible) t.cible.classList.remove("spotlight");
    t.cible = null;
    if (t.courante && t.courante.pause) App.debloquer("tuto");
    t.courante = null;
  }
  function suivante() {
    var S = App.S;
    cacher();
    S.flags.tutoIndex++;
    verifier(S, !!S.modale);
  }
  function terminer() {
    cacher();
    t.actif = false;
    if (App.S) { App.S.tutoriel = false; App.S.flags.tutoIndex = 99; }
  }
  function passer() { terminer(); App.sauver(); }
  /* Une action du joueur peut fermer l'étape qui l'attend */
  function action(nom) {
    if (!t.actif || !t.courante) return;
    if (t.courante.attend === nom) suivante();
  }
  function rePlacer() { if (t.courante) placer(document.getElementById("coach"), t.cible); }

  /* Petite bulle (hors tutoriel) : après une modale de marché, le jeu reste en pause */
  var timerIndice = null;
  function indiceRelancer() {
    var b = document.getElementById("btn-play");
    if (!b) return;
    var d = document.querySelector(".indice-bulle") || document.createElement("div");
    d.className = "indice-bulle";
    d.textContent = "Le temps est en pause. Relancez-le quand vous voulez (Espace).";
    document.body.appendChild(d);
    var r = b.getBoundingClientRect();
    d.style.left = Math.max(8, r.left - 40) + "px"; d.style.top = (r.bottom + 8) + "px";
    clearTimeout(timerIndice);
    timerIndice = setTimeout(function () { d.remove(); }, 4000);
  }

  return { demarrer: demarrer, surMois: surMois, action: action, actif: actif, passer: passer, terminer: terminer,
    cacher: cacher, rePlacer: rePlacer, indiceRelancer: indiceRelancer };
})();
