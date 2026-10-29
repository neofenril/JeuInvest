# 05 : Architecture technique de JeuClaude (V1)

> **2026-10-26 : V1 web archivée.** Le jeu passe à Godot 4.7.2 (`godot/`, arbitrage A26). Le socle Godot (données JSON,
> logique, tests, outils) est décrit dans `docs/connaissances/developpeur.md` §4 ; les règles et formules ci-dessous restent la référence.

> Rédigé par le développeur. Référence : `03_cahier_des_charges.md` (prioritaire), puis `04_ux_design.md`.
> Ce document décrit le choix technique, l'organisation du code, le modèle de données, le déroulé d'un tour,
> la façon d'enrichir le contenu, les décisions prises et l'état des critères d'acceptation.

---

## 1. Choix technologique

**HTML + CSS + JavaScript purs, scripts classiques, sans bibliothèque ni outil de construction.**

| Contrainte | Conséquence |
|---|---|
| Windows 11, ni Node.js, ni Python, ni Git ; lancement par double-clic, hors ligne, sans installation (03 §2.1) | Le navigateur (Edge ou Chrome, toujours présents) est le seul « moteur » disponible. Pas de compilation : les fichiers sont lus tels quels. |
| `file://` bloque `fetch` et `type="module"` (03 §2.3) | Uniquement des balises `<script src>` classiques, chargées dans un ordre fixe. Les données sont des fichiers `.js` qui déclarent `window.DATA_…`. |
| Données séparées du moteur (03 §2.4) | Dossier `jeu/data/` : 11 fichiers éditables à la main ; aucun chiffre historique n'est écrit dans `jeu/js/`. |
| Graphiques en SVG, confettis en canvas (03 §2.2) | Courbes et mini-courbes générées en chaînes SVG ; un seul canvas temporaire pour les confettis. |
| Sauvegarde `localStorage` protégée (03 §2.6) | Toutes les lectures et écritures passent par `U.lire / U.ecrire` dans un `try/catch` : sans stockage, le jeu tourne, sans « Continuer ». |
| Déterminisme à deux graines (03 §2.7) | PRNG maison `mulberry32` ; `Math.random()` n'est utilisé qu'une fois, pour tirer la graine de vie d'une nouvelle partie. |

Pourquoi pas un moteur de jeu (Phaser, Godot…) : il faudrait soit un CDN (interdit hors ligne), soit un export
compilé (aucun outil disponible). Le jeu est un tableau de bord animé : le DOM et le CSS suffisent et restent
lisibles à 1366 × 768 avec le zoom navigateur et l'option « texte plus grand ».

Chaque module est une IIFE qui expose un seul objet global (`U`, `Marche`, `Moteur`, `Score`, `UI`, `UIJeu`,
`Tiroir`, `UIEvt`, `UIEcrans`, `Tuto`, `App`). Le moteur (`util`, `marche`, `moteur`, `score`) n'accède jamais
au DOM : il est testé seul par `jeu/tests.html`.

---

## 2. Arborescence

```
Jouer.bat                    start "" "%~dp0jeu\index.html"
README.md
docs/05_architecture.md      ce document
jeu/
  index.html                 squelette des 4 écrans + ordre de chargement des scripts
  tests.html                 tests automatiques des critères [auto] (OK / KO)
  css/style.css              palette (04 §7.1), 6 ambiances data-era (1970 → 2020), mise en page, animations (04 §6)
  data/                      — tout ce qui est éditable —
    series.js                indice annuel, dividende, taux long (02 §4.2) ; inflation (01 §4.4) ; Livret A taux
                             et plafonds (01 §4.1-4.2) ; plafond PEA (01 §1.2) ; baguette (01 §7.3 bis)
    salaires.js              table des salaires et capitaux (01 §7.3), dépenses par décennie, profils et prénoms
    regles.js                fiscalité (01 §7.4), frais et TTF (03 §7.5), agios, fonds, objectifs, vitesses
    periode_p1.js / _p2 / _p3   période : ancrages mensuels de l'indice, produits (ancrages des actions),
                             « actions de grand-père », événements de marché (02 §7 Q2), notifications de contexte
    evenements_vie.js        11 événements de vie (01 §7.6, 03 §6.2) : fréquences, montants en M, textes
    titres.js                10 titres du bilan + les 3 témoins et leurs répliques
    lecons.js                11 gabarits de leçons (texte à trous)
    glossaire.js             24 notions « C'est quoi ? » (04 §5.4)
    textes.js                nom du journal par décennie, bandeau de l'écran titre, avertissement
  js/
    util.js                  PRNG, dates (« mois absolu »), monnaie F/€, formatage fr-FR, stockage protégé
    marche.js                génération des cours (pont brownien), séries datées (taux, plafonds, IPC, baguette, impôts, frais)
    moteur.js                état de partie, déroulé d'un mois, ordres, livret, emprunt, événements, témoins, objectifs
    score.js                 étoiles, titre, leçons, classement et réplique
    ui_commun.js             modale (focus piégé), notifications, glossaire au survol, count-roll, confettis, icônes SVG
    ui_jeu.js                écran principal : barre haute, frise, Mon mois, Mon patrimoine, Mes placements, fil
    ui_tiroir.js             tiroir Marché
    ui_evenements.js         journal, courrier, moment euro, objectif atteint, faillite, relecture des marqueurs, notifications
    ui_ecrans.js             écran titre, création (3 cartes + récap), bilan de fin, menu, options, glossaire
    tutoriel.js              T1 à T7 et bulle de fin
    main.js                  App : boucle du temps, pause, clavier, sauvegarde, enchaînement des écrans
```

**Ordre de chargement** (identique dans `index.html` et `tests.html` pour la partie moteur) : `data/*` → `util` →
`marche` → `moteur` → `score` → `ui_commun` → `ui_jeu` → `ui_tiroir` → `ui_evenements` → `ui_ecrans` → `tutoriel` → `main`.
Les modules ne s'appellent entre eux qu'à l'exécution (jamais au chargement), sauf `ui_commun` qui indexe le
glossaire au chargement (les données sont déjà là). `main.js` démarre sur `DOMContentLoaded`.

---

## 3. Modèle de données

### 3.1 Conventions

- **Montants internes en euros courants** ; la conversion F (× 6,55957) n'a lieu qu'à l'affichage (`U.money`, `U.txt`).
  Dans les fichiers de données, une valeur en francs est marquée `"F"` (troisième colonne ou champ `devise`).
- **Dates** : « mois absolu » `ab = année × 12 + (mois − 1)`, écrit `"AAAA-MM"` dans les données.
  Dans une partie, `m` = index du mois (0 = janvier de l'année de départ, 179 = décembre de la 15e année).
- **Cours** : tableaux de 181 cases par produit ; case 0 = décembre précédant la période, case `m + 1` = mois `m`
  (cours de fin de mois, affiché comme « cours actuel » pendant tout le mois, 03 A11).

### 3.2 Une période (`window.DATA_P1`)

```js
{ id, nom, debut: 1978, graine: 19780101, secousses: 3, accroche, monnaie,
  ancragesIndice: [["1987-10", 1033], ["1981-05", 340, "dev"], …],   // les clôtures annuelles viennent de series.js
  moisCrise: ["1987-10", …],                                         // volatilité 10 % au lieu de 4,5 %
  produits: [
    { id: "sicav", type: "sicav", nom, vl0: 1000, devise: "F", description },
    { id: "peugeot", type: "action", nom, secteur, beta: 1.3, volSpe: 0.30, ecartDiv: 0, devise: "F",
      dispo: "1986-12" /* facultatif */, texteNouveau, ancrages: [["1979-12", 450], …] },
    { id: "etf", type: "etf", dispo: "2001-01" }, { id: "pea", type: "pea", dispo: "1992-07" } ],
  heritage: ["elf", "peugeot"],
  evenements: [ { id, d: "1987-10", type: "-" | "+" | "+piege" | "+opportunite" | "-silencieux",
                  fenetre: 1, gravite: "majeure", produit, titre, texte, lecon } ],
  contexte: [ { d: "1988-06", titre, texte } | { d: "2002-01", type: "euro" } ] }
```

Le compte courant, le Livret A et l'emprunt d'État sont communs aux 3 périodes (définis dans `moteur.js`, `COMMUNS`).

### 3.3 État d'une partie (`App.S`, sauvegardé tel quel en JSON)

```js
{ version: 1, periode, profil, objectif, graineVie, tutoriel, abDebut, m,
  vie: { salaireBase, chomageFin, enfants, loyerMult, vieSupp },        // salaire normal et modificateurs durables
  joueur: Portefeuille, temoins: { matelas, livret, indice },          // 4 portefeuilles de même forme
  calendrier: [ { m, type, M | SMN | duree | pct | depot, sens, perdu, delai, montant, resolu } ],
  file: [ { kind: "marche" | "vie" | "euro" | "objectif", id | idx, m, prio } ], modale,   // file d'attente des modales
  auto: [ { id, env, montant, depuis } ], choix: [ … ], panique: [ fenêtres de 3 mois après un événement « − » ],
  hist: { j, mis, matelas, livret, indice },                           // valeurs mensuelles (courbes, bilan)
  epargneNette, bagMis, annee: { patr0, bag0, interets, dividendes, coupons },
  decouvertMois, fin, objectifAtteintM, partieLibre, cibles: { maison, retraite, mLimite },
  marqueurs, nouveaux, journal, notionsVues, flags, stats: { ordres, frais, impots, paniques, ventesForcees, … } }

Portefeuille = { cc, livret, livretInt, interetsTotal, tranches: [ { montant, taux, m0 } ],
                 lignes: { "loreal|PEA": { id, env, qte, cout, depuis } }, peaDebut, peaVerse, frais, impots, agios }
```

Les cours ne sont **pas** sauvegardés : ils sont régénérés à l'identique à partir de la graine de la période.

### 3.4 Génération des cours (03 §7.1-7.3)

- **Indice** : ancrages durs = clôtures au 31/12 (02 §4.2) + points mensuels de 02 §4.4 ; entre deux ancrages,
  pont brownien en log, pas mensuel, tirages de Student (ν = 4, réduite, bornée à ± 3,5), σ = 4,5 % par mois, 10 % les mois de crise.
- **Actions** : `ln P = β × ln I + résidu` ; le résidu est un pont brownien (σ = vol_spe / √12) entre les ancrages propres à l'action.
  L'action passe donc exactement par ses ancrages et suit le marché entre eux.
- **SICAV / ETF** : `VL(m) = VL(m−1) × I(m)/I(m−1) × (1 + d/12) × (1 − f/12)` avec f = 1,5 % (SICAV) ou 0,25 % (ETF, départ à I/100).
- **Livret, emprunt, IPC, baguette** : séries datées lues dans `series.js` (`Marche.tauxLivret`, `plafondLivret`, `tauxLong`, `ipc`, `baguette`).

---

## 4. Déroulé d'un tour

`App.boucle` (requestAnimationFrame) fait avancer une progression ; quand elle atteint 1 mois (4 s, 2 s ou 1 s),
`Moteur.avancer(S)` est appelé, puis l'interface affiche le résultat `{ notifs, modale, fin, sauver }`.
Le temps n'avance pas si la vitesse est 0, si une raison de blocage existe (`modale`, `tiroir`, `tuto`) ou si une modale de la partie est en attente.

`Moteur.avancer(S)` :
1. **Fin du mois courant** : intérêts du Livret A sur le solde de fin de mois (cumulés) ; en décembre, crédit des intérêts de l'année (31/12).
2. `S.m++` puis `entrerMois` (03 §3.3) :
   1. nouveaux cours (lus dans les tableaux générés) ;
   2. revenus : indexation du salaire en janvier (`SMN[a]/SMN[a−1]`), fin éventuelle du chômage, salaire crédité aux **4 portefeuilles** ;
   3. dépenses (loyer + vie courante) débitées aux 4 portefeuilles ; l'épargne nette et les « baguettes mises de côté » sont cumulées ;
   4. versements automatiques du joueur (sautés avec notification si le compte est insuffisant) ;
   5. coupons et remboursements d'emprunt ; dividendes en mai ;
   6. agios si découvert ; compteur « N mois sur 3 » ; faillite au 3e mois ;
   7. déblocages de produits datés (notification persistante + marqueur ★) ;
   8. événements de marché (mis en file) et de contexte (notification), issues des escargots, événements de vie
      (les témoins paient tout de suite ; le joueur paie à la résolution de la modale, ou tout de suite si c'est une notification) ;
      puis les témoins placent leur excédent ;
   9. rappels à 12 mois ;
   10. en janvier : bilan annuel (notification) et sauvegarde ; changement de décennie ;
   11. statistiques, historique, objectif atteint plus tôt ;
   puis **au plus une modale** est prise dans la file (priorité marché 0 > objectif 0,5 > vie 1 > euro 2) ; le reste attend le mois suivant.
3. Au-delà du mois 179 : `S.fin = "fin"` et le bilan s'affiche.

Les actions du joueur (tiroir, choix des modales) appellent directement `Moteur.acheter / vendre / deposerLivret /
retirerLivret / souscrireEmprunt / revendreEmprunt / programmerAuto / resoudreMarche / resoudreVie`, au cours du mois affiché.

---

## 5. Enrichir le jeu

### Ajouter un événement de marché
Ajouter une entrée dans `evenements` de `jeu/data/periode_pX.js` : `{ id unique, d: "AAAA-MM", type, fenetre, gravite, titre, texte, lecon }`.
Le type fixe le jeu de choix (03 §6.1) ; `gravite: "majeure"` donne l'animation `paper-spin`. Si l'événement doit se voir dans
les cours, ajouter ou ajuster des points dans `ancragesIndice` (et `moisCrise`). Aucun code à toucher.

### Ajouter un événement de vie
Ajouter un type dans `types` de `jeu/data/evenements_vie.js` avec un `effet` existant (`cout`, `gain`, `chomage`,
`augmentation`, `naissance`, `demenagement`, `escargots`), une fréquence et ses montants en M ou en SMN. Un nouvel `effet`
demande quelques lignes dans `tirerCalendrier`, `declencherVie` et `resoudreVie` (`moteur.js`).

### Ajouter une période
1. Copier `periode_p3.js` en `periode_p4.js`, changer `window.DATA_P4`, `id`, `debut`, `graine`, produits, ancrages et événements.
2. Vérifier que `series.js` couvre les années (indice, dividende, taux long, inflation, baguette) et que `salaires.js` couvre la décennie.
3. Ajouter `<script src="data/periode_p4.js">` dans `index.html` et `tests.html`, et `"P4"` dans la liste des cartes (`ui_ecrans.js`, `rendreCreation`)
   et dans `PER` de `tests.html`.
4. Ouvrir `tests.html` : les critères d'ancrage, de déterminisme et de partie complète s'appliquent automatiquement à la nouvelle période.

### Corriger un chiffre ou un texte
Tous les taux, plafonds, frais, impôts, salaires, prix, textes, titres, leçons et définitions sont dans `jeu/data/`.

---

## 6. Décisions prises / questions au client et à l'UX

Règle suivie : « si une règle n'est pas écrite, la solution la plus simple ». Chaque décision est réversible dans les données ou en quelques lignes.

### 6.1 Données et marché
1. **Cours de fin de mois.** Quand 02 §4.4 ne donne pas la fin de mois, on prend le dernier point ★ du mois (oct. 1987 = 1 033, nov. 1987 = 963, mars 2003 = 2 403, janv. 2022 = 7 376, sept. 2022 = 5 677). Les clôtures annuelles priment en cas de doublon.
2. **Points « dev »** ajoutés pour que le récit tienne (marqués `"dev"` dans les fichiers) : 1978-02/03/07 (+30 % en 4 mois), **mai 1981 = 340** (entre 400 le 8 mai et 285 fin juin), 1992-05/08/09/10 (Maastricht), 1998-07 à 10 (crise russe), 2010-04 à 06 (Grèce), 2012-06/07 (BCE), 2016-05/06 (Brexit), 2024-05/06 (dissolution), 2025-02 à 05 (guerre commerciale). **À valider par le boursier.**
3. **Une seule échelle d'indice** (CAC 40, base 1 000 fin 1987) pour toute la P1 ; seul le nom change en juin 1988 (`Marche.nomIndice`).
4. **Ancrages annuels des 4 actions de P1** fixés par le développeur pour respecter les profils de 02 §7 Q3 (Elf forte en 1979-1980 et faible en 1986, L'Oréal ≈ ×1,5 l'indice, Peugeot −60 % de 1979 à 1984 puis ×5,5 jusqu'en 1989, Saint-Gobain 310 F en décembre 1986). Pour P2 et P3, les points de 02 §4.5 sont repris et complétés par des fins d'année plausibles. **Orange** est maintenu à 9 € ou plus (au lieu d'environ 8 € réels en 2012) pour respecter « ≈ 10-15 € » à ± 10 % (CA-22). **À valider par le boursier.**
5. **Bêta constant** par action (pas de bêta 1,8 pour France Télécom en 1999-2002 : les ancrages portent déjà la bulle).
6. **Dates de changement** du Livret A : jour ≤ 15 → ce mois-ci, jour > 15 → mois suivant. Plafond 1980 « 45 000 puis 49 000 F » : 49 000 F en juillet 1980.
7. **IPC** : la valeur annuelle est placée en janvier puis interpolée géométriquement ; 2026 = 2025 × (1 + 0,9 %). **Baguette** : points placés en janvier, interpolation linéaire.
8. **Salaires** : table convertie en euros puis interpolée géométriquement à l'année ; indexation chaque janvier.
9. **Dividende BNP « 0 en 2009 et en 2020 »** compris comme « pas de dividende ces années-là » (recommandation BCE, 02 §6.4).

### 6.2 Règles de jeu
10. **Chômage** : les dépenses suivent le salaire (03 §5.2) **sauf le loyer**, qui reste celui du salaire normal. Avec des dépenses calculées sur le salaire normal, un jeune salarié prudent (tout sur le compte courant) faisait très souvent faillite après une perte d'emploi. **Question au client** : ce compromis convient-il ?
11. **Tirage des événements de vie** (contraintes ajoutées, sans effet sur le déterminisme) : pas d'événement au tout premier mois ; **pas de naissance qui rendrait le budget mensuel négatif** (+9 % du salaire dépasse le taux d'épargne du jeune salarié, 6 à 10 %) ; un déménagement « plus cher » devient « moins cher » s'il laisse moins de 3 points d'épargne. Sans ces garde-fous, le jeune salarié passif faisait faillite dans 15 à 25 % des parties en P1 et P3 ; avec eux, 1 faillite sur 900 parties sans aucune action du joueur. **Question au client** : garder +9 % du salaire par enfant (03 §6.2) avec ce garde-fou, ou réduire ce coût ?
12. **Prime du tutoriel au mois 8** : toujours présente, même sans tutoriel, pour que le calendrier ne dépende que de la graine.
13. **Coïncidence forcée** : panne de voiture le mois **suivant** un événement « − » tiré au hasard après le 12e mois (la modale de marché a priorité).
14. **Événement de vie** : modale aussi quand le compte ne suffit pas à payer (cas 2 du courrier) ; les témoins paient le mois de l'événement, le joueur à la résolution (au plus un mois plus tard si la modale est reportée).
15. **Témoins** : ni agios ni faillite (sinon Tonton Matelas ne finirait pas « exactement » avec la somme des épargnes, CA-19). Tata Livret ne **dépose** jamais au-delà du plafond ; ses intérêts peuvent le dépasser (règle réelle).
16. **Cousin Indice** : coussin = min(3 mois de dépenses, plafond du livret) ; il **regroupe ses achats d'ETF** jusqu'à ce que le montant dépasse minimum ÷ taux de courtage (sinon le minimum de 10 € avalerait 5 % de petits versements) ; PEA si la place le permet ; vend ses fonds seulement si le coussin est vide.
17. **Faillite** : seuil = −1 × salaire normal du moment ; agios appliqués au début de chaque mois.
18. **Intérêts du livret** calculés sur le solde de fin de chaque mois et crédités au passage du 31/12 (CA-14 exact).
19. **Dividendes d'une ligne en PEA** : crédités sur le compte courant, à 0 % d'impôt (pas de liquidités dans le PEA en V1).
20. **Revente de l'emprunt** : au nominal, en commençant par les tranches au taux le plus faible.
21. **Vente en panique** : les ventes forcées pour payer un coup dur (courrier) ne comptent pas ; « Tout vendre » compte une seule fois par événement.
22. **Titre « Tous les œufs… »** : prix de référence = plus haut cours atteint pendant que la ligne dépassait 60 % du patrimoine. **« Trader du dimanche »** : achats et ventes d'actions, SICAV et ETF (hors versements automatiques, livret et emprunt).
23. **Seuils des leçons** : « argent qui dort » si le compte courant pèse 25 % ou plus en moyenne ; « a tenu bon » si l'indice a pris plus de 5 % dans les 12 mois ; « coussin » si un coup dur d'au moins ½ mois de salaire a été payé sans découvert ni vente forcée.
24. **Escargots** : la mise n'est pas comptée dans l'épargne nette (c'est une perte, pas un retrait).
25. **Privatisations** : souscription au cours du mois, qui vaut le prix fixe (310 F, 27,75 €) ; pas de taux de service ni d'actions gratuites (03 §9).

### 6.3 Interface
26. **CA-23** : « Nouvelle partie » est un clic ; en plus du parcours carte → carte → carte → « C'est parti », un lien « Garder les choix conseillés et aller au récapitulatif » permet de lancer en 3 clics. **Question à l'UX** : ce lien convient-il ?
27. **Bandeau de l'écran titre sans krach** (04 §3.1 citait « 1987 Lundi noir ») pour rester cohérent avec A5 et A8.
28. **Bilan annuel** : la variation en % n'est affichée que si le patrimoine de départ de l'année vaut au moins un mois de salaire (sinon « +1 375 % » la première année) ; sinon montant et baguettes.
29. **« Objectif en vue ! »** seulement pour « maison » et « retraite » ; l'objectif « inflation » ne se juge qu'à la fin.
30. **Cibles des objectifs** arrondies à 2 chiffres significatifs dans la monnaie affichée à l'échéance.
31. **Tutoriel** : les produits autres que le livret sont masqués les 3 premiers mois seulement si « Me guider » est coché ; la bulle T4 disparaît après 6 s ou 2 mois ; l'étape en cours est sauvegardée.
32. **Notifications persistantes** (bilans annuels, rappels, nouveautés) : 3 visibles au plus, les plus anciennes disparaissent.
33. **Non faits (bonus P1 de 04)** : `coin-rain` (remplacé par un `float-up` sur l'héritage), `coin-fly`, `era-shift` en fondu, sons, historique, « Le saviez-vous ? » récurrents, « Revoir ma frise ». `coin-spin` est fait (moment euro).

---

## 7. Critères d'acceptation (03 §10)

Vérifications faites : `jeu/tests.html` exécuté dans un navigateur Chromium (panneau navigateur, servi par un petit serveur local
temporaire) → **24 / 24 OK** ; parties jouées par script dans l'interface réelle (P1, P2, P3 ; tutoriel ; modales ; tiroir ;
euro ; objectif ; faillite ; abandon ; bilan ; rejouer ; menu ; options ; glossaire) **sans erreur dans la console**.
900 parties automatiques sans action du joueur : 1 faillite (malchance), 899 parties complètes.

| Critère | État | Comment |
|---|---|---|
| CA-01 lancement hors ligne Edge/Chrome | **Partiellement vérifié** | Aucune dépendance réseau, ni `fetch` ni module ; aucune erreur console au chargement (Chromium, servi en HTTP local). **Non vérifié : double-clic en `file://` sur un autre PC, dans Edge et dans Chrome.** |
| CA-02 9 combinaisons × 180 mois | Respecté [auto] | 27 parties (3 graines) ; le test accepte une fin par faillite, qui reste rare (§6.2, n° 10-11). |
| CA-03 pause, fermeture, « Continuer » | Respecté (moteur [auto] + essai manuel) | Sauvegarde à chaque pause, janvier, fermeture de modale et `beforeunload`. Rechargement constaté : même mois, même patrimoine. |
| CA-04 1366 × 768 sans défilement horizontal | Respecté | Vérifié en émulation 1366 × 768 (largeur de défilement = largeur visible). |
| CA-05 PEA pas avant 07/1992 | Respecté [auto] | |
| CA-06 ETF pas avant 01/2001 | Respecté [auto] | |
| CA-07 France Télécom 10/1997 à 27,75 €, Saint-Gobain 12/1986 à 310 F | Respecté [auto] | |
| CA-08 pas de « CAC 40 » avant 06/1988 | Respecté [auto] | Textes générés en P1, produits, glossaire dynamique. |
| CA-09 F / double / € ; modale euro unique en 01/2002 | Respecté [auto] | |
| CA-10 indice = clôtures annuelles | Respecté [auto] | Écart nul (ancrages durs). |
| CA-11 déterminisme des cours | Respecté [auto] | |
| CA-12 / CA-29 même graine = même calendrier | Respecté [auto] | Joueur passif et joueur actif : calendriers identiques (dates et montants). Chemin « Rejouer » vérifié dans l'interface. |
| CA-13 plafond du livret | Respecté [auto] | |
| CA-14 10 000 F → 10 850 F en 1982 | Respecté [auto] | |
| CA-15 16 % en 1995 ; 17,2 % en PEA en 2018 | Respecté [auto] | |
| CA-16 frais 50 F et 130 F | Respecté [auto] | |
| CA-17 TTF LVMH 2013, pas sur l'ETF | Respecté [auto] | |
| CA-18 faillite après 3 mois | Respecté [auto] | Courrier, puis bilan sépia (vérifié dans l'interface). |
| CA-19 Tonton = épargne nette ; Tata sous le plafond | Respecté [auto] | Écart 0 € sur les 9 combinaisons. |
| CA-20 P1 sans événements : Cousin > Tata > Tonton | Respecté [auto] | Pour les 3 profils. |
| CA-21 profils Peugeot, France Télécom, Alcatel | Respecté [auto] | −60 % ; 219 € puis 7 € ; −97 %. |
| CA-22 ancrages des actions à ± 10 % | Respecté [auto] | Exact par construction ; ancrages P1 et compléments à valider (§6.1). |
| CA-23 4 clics depuis l'écran titre | Respecté | 3 clics avec le lien « choix conseillés » ; 5 par le parcours complet (§6.3, n° 26). |
| CA-24 durée 15 à 30 min | **Non vérifié** | Estimation : 12 min à ×1 + environ 16 modales par partie (mesuré) + tutoriel. À mesurer sur 3 joueurs. |
| CA-25 une modale par mois, pas de marché futur | Respecté [auto] | |
| CA-26 événements au bon mois, bonne manchette, bons choix | Respecté [auto] | 8 / 8 / 7 événements. |
| CA-27 rappel à 12 mois avec la variation réelle | Respecté [auto] | |
| CA-28 bilan complet | Respecté (vérifié dans l'interface) | € d'aujourd'hui, 4 barres classées, courbes, étoiles avec règle au survol (attribut `title`), titre, 3 leçons dont une positive si possible. |
| CA-30 bulles « C'est quoi ? » de 2 lignes | Respecté, à confirmer visuellement | 24 définitions de 120 caractères au plus environ, bulle de 400 px ; chaque produit a sa bulle. |
| CA-31 clavier et animations réduites | Respecté (partiellement testé) | Espace/P, 1-2-3 (vitesse ou choix), M, Échap, Tab avec focus piégé dans les modales ; option et `prefers-reduced-motion` ramènent les animations à 1 ms. Navigation complète au clavier non testée par un humain. |

---

## 8. Risques connus

- **`file://`** : non testé par double-clic (mon environnement d'essai servait les fichiers en HTTP local). Rien dans le code n'en dépend, mais c'est le premier test à faire.
- **Animations** : vérifiées par le code et les captures, pas en temps réel sur une machine lente ; `count-roll` a un filet de sécurité qui affiche la valeur finale.
- **Équilibrage** : rythme (environ 16 modales par partie), coût des événements pour le jeune salarié, montants des objectifs : à ajuster après les premiers tests de joueurs (tout est dans `jeu/data/`).
- **Données « dev »** (points d'indice et ancrages d'actions) : plausibles mais non sourcées ; à faire valider par le boursier.
- **Sauvegarde** : `localStorage` est propre à chaque navigateur ; une partie commencée dans Edge ne se continue pas dans Chrome.
