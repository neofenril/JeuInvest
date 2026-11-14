# Feuille de route « version jouable » (0.5) : vagues 3, 4 et 5 sans peaufinage

> Chef de projet, 2026-11-13. **Prime sur `feuille_de_route.md` §1 (vagues 3 à 5) et sur les numéros de sortie 0.5 / 0.6 / 0.7.** Les règles de fond (propriété des fichiers, testeur avant push, validation du chef de projet, fusion `--no-ff`, jamais de correction directe sur `main`) restent celles de `feuille_de_route.md` §3 et §5.
> Origine : décision du joueur (2026-11-13, verbatim) : « continue les développements et tu peux lancer vague 4 et 5, je veux une version jouable avec ces fonctionnalités voir si on s'amuse plus ou s'il faut prévoir d'autres choses, avant de plus peaufiner le reste comme les animations, mouvements de caméra, humeur de personnages etc... ». Rappel docs/10 (29/10) : **le classement de la rue est affiché en permanence**.
> État au départ : `main` 335442b. En cours : 03-R (`lot/03-retouches`, 3 commits, attend la recette), 04-L (`lot/04-logique`, vide), 03-I2 étape 1 (`lot/03-interface2`, commencé, rien de commité), 03-V2 (`lot/03-ville2`, ≈ 860 lignes écrites, rien de commité).

## 1. Principe

1. **Une seule sortie au joueur : 0.5 « jouable »**, qui contient toutes les règles de jeu des vagues 3, 4 et 5 : cartes du foyer et humeur, projets, voisins et classement de la rue, Jean-Mi, kiosque, krach (jours du Lundi noir en tableau, « un an après »). Pas de 0.6 ni de 0.7 intermédiaires. Les fusions intermédiaires dans `main` (J1, J2) ne sont pas envoyées au joueur.
2. **Essentiel = la règle + un écran fonctionnel** (carte, ligne, tableau, barre). **Reporté = la mise en scène** (animations, caméra, humeurs visuelles dans la rue, séquences, objets décoratifs, bulles des voisins dans la rue). Chaque élément reporté a un **repli sobre** : carte simple, texte, notification, ligne d'historique.
3. Tout ce qui est nouveau reste **éteint par défaut dans le moteur** (réglages `cartes`, `projets`, `rue` dans la configuration de la partie, gardés dans la sauvegarde) et **allumé par `principal._config()` hors mode capture** : les références des tests et des captures existantes ne bougent pas, le joueur a tout.
4. **Parallélisme maximal** : dev-logique a une 2e instance (**dev-logique-bis**) pour écrire, sur des fichiers neufs, les modules de la vague 5 pendant que dev-logique finit les projets (§4) ; les deux interfaces de vague sont **regroupées en deux recettes** (maison, puis rue) au lieu de quatre.
5. **Recettes ciblées** (§5) : moins de formats, moins de captures relues, défauts visuels classés « mineurs » sauf s'ils cachent une information ou bloquent.

## 2. Essentiel / reporté, par vague

### 2.1 Vague 3 : le foyer (cartes de dilemme, humeur) — lot 04
| Sujet | ESSENTIEL (dans la 0.5) | REPORTÉ (après le verdict) | Repli sobre |
|---|---|---|---|
| Moteur des cartes (04-L) | invariant « une carte ouverte se ferme toujours », coup dur prioritaire (G3), textes G1 / docs/22, projets écrits (§2.2) | — | — |
| Carte de dilemme (03-I2) | `Modales.carte` : 2 choix, montant, picto d'humeur, choix non payable grisé + « Il manque … », « Disponible sans rien vendre », touches 1 / 2, conclusion (« CHOISI » + ligne de conséquence 3 s, passable), relecture dans l'historique | vol de la fiche depuis la porte, dépli en 3 images, aimant qui tombe, tampon incliné en escalier | la carte **apparaît sur place** (fondu ≤ 0,2 s) ; tampon = mot « CHOISI » en encre |
| Humeur de Sylvie | picto sur l'étiquette MA MAISON, bulle d'humeur (composant `Bulle` existant), « Mon foyer » avec portrait 48 × 48 en 3 expressions, phrase, dernière cause, 4 dernières cartes | Sylvie à la fenêtre en 3 humeurs (posture, coucou, géraniums, rideau, clignement), saut d'1 texel du picto | picto + bulle + portrait de « Mon foyer » |
| Traces de la maison (P10) | fonction pure `traces_foyer` si déjà écrite | dessins non finis, lueur qui scintille, captures des 3 parties relues | aucune (les cartes jouées sont listées dans « Mon foyer ») |
| Entrée de la carte (03-V2) | `Sequences` : `kind "carte"` → caméra sur la maison → `Modales.carte` (repli `courrier`) → `resoudre_modale` → `conclure_carte` ; **routage générique** pour `projet` et `gazette` (§3) | porte en 3 images si elle n'est pas finie | caméra sur la maison, carte sur place |
| Banque pendant une carte | BANQUE grisée + phrase, ordres refusés par le moteur | — | — |
| « Mon foyer » au téléphone | une colonne avec défilement | 2 onglets | défilement |

### 2.2 Vague 4 : les projets (P1) — lot 05 (04-I)
| Sujet | ESSENTIEL | REPORTÉ | Repli sobre |
|---|---|---|---|
| Moteur (04-L, lot 04) | projets P1 / P2, rappel, report, vente automatique dans l'**ordre du joueur** (D7 bis, `lot_05.md` §1), R-MIROIR, humeur, sauvegarde | — | — |
| Carte de choix (3 options) | `Modales.projet` étape `choix` : 3 boutons (icône, nom, montant, échéance), touches 1 / 2 / 3 | icônes 32 × 32 dessinées, sortie de la porte | icônes 16 × 16 existantes ou initiale ; apparition sur place |
| Le jour J | `Modales.projet` étape `echeance` : montant, disponible, manque, **liste des ventes ligne par ligne** (net, écart avec les versements, pénalité), boutons RÉALISER / RÉALISER EN VENDANT (écran de confirmation) / REPORTER / RENONCER | animation de la réalisation | ligne de conséquence comme les cartes |
| Jauge du projet | **2e ligne de l'étiquette MA MAISON** : « [icône] 21 400 / 30 000 F » (texte, sans barre) ; jauge à 2 segments dans « Mon foyer » (colonne PROJET EN COURS, projets passés ✓ ↻ ✗) | jauge accrochée sous l'étiquette (docs/17 §4.3), saut au rappel, ✓ sprite | texte + barre statique dans « Mon foyer » |
| Ligne du guichet | « Projet : la Super 5, avril 1986 (dans 14 mois) · 30 000 F » dans l'en-tête de la fenêtre Banque et des formulaires d'ordre | — | — |
| Traces P10 des projets (04-V) | — | Super 5 garée, break, carte postale, chaîne hi-fi, déménagement | ligne « Projets » de « Mon foyer » + historique |
| Projets allumés | `principal._config()` hors capture : `"projets": true` | — | — |

### 2.3 Vague 5 : la rue (P3 + P9) et le krach (P6) — lot 05 (05-L) et lot 06 (05-I)
| Sujet | ESSENTIEL | REPORTÉ | Repli sobre |
|---|---|---|---|
| Jean-Mi (05-L) | témoin à part entière : miroir jusqu'en 08/1986, Peugeot au règlement mensuel (docs/19 §2), Porsche à crédit, liquidation au krach, dette, remboursement ; J1, J2 testés ; vrais ancrages de Peugeot (docs/19 §1.2) | Jean-Mi dessiné dans la rue, à vélo | — |
| Classement de la rue | **affiché en permanence** (décision du joueur) : pastille compacte « RUE 2e / 4 » dans la barre haute ; bloc « La rue » (4 lignes) dans « Mon argent » ; notification de changement de rang (≤ 1 / 6 mois) ; écran de fin à 4 barres + rang | portraits dessinés des voisins | initiale dans une pastille de couleur |
| Passages des voisins (V01-V16) et bulles réactives | **notifications sans pause** source `rue` (« Tonton Matelas : « … » »), budget ≤ 1 tous les 2 mois, jamais un mois de pause ; les 5 passages ★ dans l'historique, même pendant un saut ; V01 et V13 (levier) = texte long lisible en relecture (= carte de lecture) | bulles au-dessus des voisins, `faire_passer`, Porsche garée, « À VENDRE », Mme Lopez | notification + relecture |
| Kiosque | **notification sans pause** de la Gazette (11 titres datés, docs/19 §3), au plus 1 notification rue ou kiosque par mois | panneau défilant sur la Gazette | notification |
| Historique | onglet LA RUE (source `rue`, docs/17 §4.5) | icône dessinée | libellé |
| Lundi noir | modale du krach **inchangée** + **tableau des 7 jours** (16 → 26/10/1987, « environ », docs/19 §4.2) dans la modale | séquence de 15 s (file devant la banque, téléphone, Jean-Mi qui court, chiffres qui défilent) | tableau statique |
| « Le krach, un an après » | interruption datée 10/1988, carte de la Gazette à **3 barres** (Tout vendu / Rien fait / Renforcé, choix réel entouré), cas « sans action » en exemple | sortie animée de la Gazette | carte simple |
| Enfants qui grandissent, Porsche, panneau | — | tout | — |
| Titres d'époque (P5), record | — (sortie **0.6** : `lot_07.md`, 07-L lancé dès le 14/11 empilé sur 05-L, invisible ; entre dans `main` avant R-RUE seulement s'il est validé à temps, pour que les parties 0.5 remplissent déjà `records.sav` ; 07-I après l'envoi de la 0.5) | — | rang seul à la fin |

## 3. Lot en cours 03-V2 : décision de périmètre (consigne à transmettre à dev-ville tout de suite)

> « Arrête-toi sur le minimum et commite. **Ne commence plus rien de nouveau.** Dans l'ordre :
> 1. **Garder et finir (essentiel)** : V4 `_sequence_carte` (déjà écrite) **et la rendre générique** : `kind "carte"` et `kind "projet"` → maison, `kind "gazette"` → bâtiment média ; même déroulé (caméra sur le bâtiment ; porte en 3 images seulement pour la maison et seulement si elle est déjà finie) ; appel `modales.call(kind, c, depart)` si `modales.has_method(kind)`, sinon `modales.courrier(c, depart, e)` ; boucle tant que `Partie.resoudre_modale` rend `{}` ; puis `conclure_<kind>` par `has_method`. Ligne `RUE fiche kind=<k> appel=<modales|courrier>`.
> 2. **Garder si c'est déjà fini et vert, sinon retirer du commit** : V5 (m1 panneau INDICE, m3 cartouches qui se recouvrent, m2 / D13 intérêts à part) ; V2 `suivre_foyer` + V1 Sylvie en 3 visages (sans coucou, géraniums, rideau ni clignement s'ils ne sont pas finis) ; V3 `traces_foyer` (fonction pure) avec **seulement les traces déjà dessinées** (liste `TRACES_DESSINEES` ; les autres ne sont ni attendues ni dessinées).
> 3. Étapes de capture : `carte_sortie` (obligatoire), étapes des pièces mises à jour ; `sylvie_humeurs` seulement si V1 est gardé. Pas d'étape `traces_foyer` sur 3 parties. Tests (V7) : ceux des parties gardées.
> 4. Le travail de peaufinage commencé mais non fini : le commiter **à part** sur une branche locale `lot/03-ville2-suite` (créée depuis ton dernier commit de `lot/03-ville2`), jamais poussée, pour le reprendre après le verdict du joueur.
> 5. `tests.ps1 -Recette` vert, base `dev-ville.md`, compte rendu (ce qui est gardé, ce qui est parti sur `-suite`). »

CA de la recette courte de 03-V2 : `lot_04.md` §12.2. Après 03-V2, **dev-ville n'a plus de tâche essentielle** jusqu'à la 0.5 : il reste disponible pour un correctif d'intégration (branche `lot/NN-ville-correctif`) ; aucun peaufinage avant le verdict du joueur.

## 4. Plan de parallélisme

### 4.1 Qui fait quoi
| Développeur | Maintenant | Ensuite | Puis |
|---|---|---|---|
| **dev-logique** | 03-R (attend la recette) → **04-L** (`lot/04-logique`, `lot_04.md` + D7 bis de `lot_05.md`) | dès que 04-L part chez le testeur : **05-L phase B** sur `lot/05-logique` (le coordinateur y fusionne `lot/04-logique`) | corrections de recette |
| **dev-logique-bis** (2e instance, base temporaire `dev-logique_05.md`) | **05-L phase A** (`lot/05-logique`, fichiers neufs seulement : `quartier.gd` (`Quartier`), `krach.gd` (`Krach`), `rue.json`, `krach.json`, `temoins.json > jeanmi`, `test_quartier`, `test_krach` ; plan `lot_05.md` §5.2) | rend la main : fin de l'instance | — |
| **dev-interface** | **03-I2 étape 1 réduite** (`lot/03-interface2`, §2.1, `lot_04.md` §12.3) | **04-I étape 1** (`lot/04-interface`, **empilée** sur le dernier commit de `lot/03-interface2`) sur le contrat figé `lot_04.md` §4.2 ; quand 04-L et 03-V2 sont sur `main` : étape 2 (03-I2 étape 2 + 04-I sur le vrai moteur) → **recette R-MAISON** | **05-I** (`lot/05-interface`, `lot_06.md`) depuis `main` après R-MAISON, étape 1 sur le contrat `lot_05.md` §4 ; étape 2 après 05-L → **recette R-RUE** (= recette finale) |
| **dev-ville** | **03-V2 réduit** (§3) → recette courte | réserve (correctifs d'intégration seulement) | — |
| **testeur** | 03-R, puis 03-V2 et 04-L dans l'ordre de remise | R-MAISON, 05-L | R-RUE + partie à la main |

### 4.2 Branches, worktrees (`C:\Users\arthu\Documents\temp\JeuClaude_lots\`)
| Branche | Worktree | Créée depuis | Quand |
|---|---|---|---|
| `lot/03-retouches`, `lot/03-ville2`, `lot/04-logique`, `lot/03-interface2` | existants | — | — |
| `lot/05-logique` | `lot05-logique` | `main` (après le commit de ces plans) | **tout de suite** (dev-logique-bis) |
| `lot/04-interface` | `lot04-interface` | dernier commit de `lot/03-interface2` (03-I2 étape 1 commitée) | dès le compte rendu de 03-I2 étape 1 |
| `lot/05-interface` | `lot05-interface` | `main` après la fusion de `lot/04-interface` | après R-MAISON |
| `lot/03-ville2-suite` | aucun (branche locale) | dernier commit de `lot/03-ville2` | par dev-ville, si du peaufinage non fini existe |

Deux instances de dev-logique ne travaillent **jamais** sur la même branche en même temps : phase A seule sur `lot/05-logique`, puis phase B seule (dev-logique-bis a rendu son compte rendu et commité avant que le coordinateur fusionne `lot/04-logique` dans la branche).

### 4.3 Ordre de fusion dans `main`
1. **J0** : `lot/03-retouches` (après OK). Exports 0.4.1 : facultatifs (le joueur attend la 0.5 ; à décider par le coordinateur).
2. `lot/03-ville2` et `lot/04-logique`, **dans l'ordre des OK**, sans fusion simulée (le coordinateur relance `tests.ps1 -Recette` sur `main` après chaque fusion ; échec → correctif).
3. Coordinateur : `main` → `lot/04-interface` (qui contient 03-I2 étape 1 et 04-I étape 1). dev-interface : étape 2. **R-MAISON** sur cette branche. Fusion de `lot/04-interface` dans `main` (elle contient `lot/03-interface2` : **pas de fusion séparée** de `lot/03-interface2`). = **J1** (cartes et projets allumés pour une nouvelle partie ; pas d'export au joueur).
4. Coordinateur : `main` (avec 04-L) → `lot/05-logique` avant sa recette. Recette 05-L. Fusion.
5. Coordinateur : `main` → `lot/05-interface`. dev-interface : étape 2. **R-RUE** (= fusion complète). Fusion. = **J2**.
6. **Sortie 0.5 « jouable »** : `tests.ps1 -Recette` et les deux séries de captures sur `main` ; exports exe + APK (lancés par le joueur à cause de Smart App Control, paquet vérifié par `--main-pack`) ; **une partie réelle chronométrée** par le coordinateur avec le bouton COURRIER (durée notée, docs/15 §9.2) ; envoi au joueur avec : « nouvelle partie obligatoire pour avoir les nouveautés ; une partie 0.4 reprise reste sans cartes, projets ni rue ; ce qui n'est pas animé l'est volontairement ; dites-nous si on s'amuse plus ».

Chemin critique : 04-L → 05-L phase B → recette 05-L → 05-I étape 2 → R-RUE → 0.5. Tout le reste tourne à côté.

## 5. Recettes : le minimum pour fusionner vite sans casser

Règles inchangées : OK du testeur avant tout push de branche ; validation du chef de projet avant fusion ; une section par passage dans `lot_NN_recette.md`.

**Six passages jusqu'à la 0.5** : 03-R (court), 03-V2 (court), 04-L, R-MAISON (groupée : 03-I2 + 04-I sur la fusion), 05-L, R-RUE (groupée et finale). Plus de fusion simulée séparée : les deux recettes groupées **sont** des fusions complètes.

Dans chaque passage, **obligatoire** :
1. `tests.ps1 -Recette` vert, 0 erreur de script, total ≥ référence de `main` ;
2. `git diff --stat main...<branche>` : périmètre du plan ;
3. les CA marqués **★** du plan (les autres : par sondage, ou « non vérifié » écrit) ;
4. `partie_en_cours.sav` du joueur intact, aucun Godot d'autrui fermé.

Captures : **deux formats seulement** (PC 1920 × 1080 et téléphone 1440 × 648) et seulement les étapes listées par le plan ; `test_ecran` couvre les autres formats par calcul.

**KO seulement si** : test rouge ou erreur de script ; partie bloquée ; chiffre faux (R-MIROIR, vente, barres, classement) ; contrat ou sauvegarde cassés ; règle pédagogique violée (conseil, prévision, timing récompensé) ; information **cachée** ou bouton inaccessible ; fichier hors périmètre. **Tout le reste est mineur** : noté, reporté au §6, ne bloque pas.

Passage 2 après un KO : seulement les points KO + l'obligatoire 1-4.

Recettes groupées (R-MAISON, R-RUE) : en plus, **une partie jouée à la main** (PC, puis téléphone simulé 1440 × 648 jusqu'à 3 interruptions) avec tout allumé : aucun blocage, chaque carte se ferme, rien d'illisible. R-RUE ajoute la vérification du paquet exporté (`--main-pack`, `--etape=titre` sans `ERROR`).

## 6. Liste du peaufinage (après le verdict du joueur ; rien n'est lancé avant)
Animations de la carte (vol, dépli, aimant, tampon) ; Sylvie à la fenêtre (3 humeurs, si retirée de 03-V2) ; traces P10 (cartes et projets) ; jauge accrochée à l'étiquette ; icônes 32 × 32 ; bulles des voisins dans la rue, `faire_passer`, Porsche, « À VENDRE », Jean-Mi à vélo, Mme Lopez ; kiosque défilant ; séquence du Lundi noir ; enfants qui grandissent ; « Mon foyer » en 2 onglets au téléphone ; portraits des voisins ; formats 1152 × 648 et 1280 × 720 relus ; mineures des recettes de cette feuille de route ; avis UX en attente (repli 1280 × 720, « MA MAISON » au-dessus de « ‹ LA GAZETTE »). Puis P5 (titres, record), sauvegarde manuelle (SV), 1.0, comme `feuille_de_route.md` §1 et §10.

## 7. Contenus des experts
Détail et textes exacts des demandes : `lot_05.md` §8. Résumé : **rien n'empêche de lancer** ; une question au joueur bloque seulement la **recette** de 04-L (ordre de vente : défaut appliqué en attendant) ; les maquettes UX sont souhaitées avant 04-I étape 1 et 05-I étape 1 (défauts écrits dans les plans sinon) ; boursier, banquier, game designer : relectures et textes définitifs, remplaçables sans code.
