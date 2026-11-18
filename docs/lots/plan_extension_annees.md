# Plan d'extension de la plage des années jouables

> Chef de projet. Version 1 : 2026-11-18 (matin). **Version 2 : 2026-11-18 (après les décisions du joueur, `decisions_extension_annees.md`, qui priment sur ce plan et sur docs/03 A7, A9, A10).**
> Demande d'origine (reprise.md, point 4) : étendre la plage des années pour préparer le décor par décennie (backlog 4) et la création de partie (backlog 5).
> Statut : **lot 08b (rééquilibrage) et lot 09 (socle) prêts à lancer** (`lot_08b_reequilibrage.md`, `lot_09.md`). Les lots 10 et suivants sont esquissés ici ; leurs plans détaillés seront écrits quand les contenus d'experts du §4 seront arrivés et les questions D-J du §4.3 tranchées.
> Contenus d'experts déjà reçus : docs/33 (boursier), docs/34 (banquier), docs/35 (game designer), docs/36 (UX). Ils visaient 2019-2023 en 2e chapitre : ils restent utiles (gabarit de chapitre, R-SEUL, profils de 1984, thème 2020, création de partie) mais le **2e chapitre est désormais 1989-1993**.

---

## 0. En bref (version 2)

1. **Chapitres de 5 ans greffés autour de 1984-1988**, de proche en proche : premier nouveau chapitre **1989-1993**, puis 1994-1998 ou 1979-1983, etc. (2019-2023 en premier : écarté par le joueur).
2. **Une partie traverse les chapitres.** Elle commence au chapitre choisi (ou à une **année précise** saisie, qui reprend tout le contenu du chapitre où elle tombe) et se termine **à la mort du personnage** ou **à la dernière année implémentée** (1988 aujourd'hui, 1993 après le lot 10, l'année en cours à terme). La durée d'une partie n'est donc plus fixe : 5 ans aujourd'hui, jusqu'à 10 ans après le lot 10, beaucoup plus à terme.
3. **Plage : de 1977** (première année jouable) à la dernière année implémentée. 1950-1976 : à reconsidérer tout à la fin (période « très light »).
4. **Profils par chapitre** (3 par tranche de 5 ans, dont un **célibataire**, règle R-SEUL de docs/35) ; **décor par tranche de 10 ans** (pas de 5).
5. **Produits** : PEA (dès 07/1992, donc dans 1989-1993), ETF (2001), PER comme notion ; **deux canaux de frais** (banque de réseau / courtage en ligne). **Jeux** : bureau de tabac oui, casino plus tard ; **étoiles** pour les trophées de bonne pratique ; niveaux d'explication plus tard.
6. **Ordre des lots** : **08b rééquilibrage** → **09 socle** → **10 chapitre 1989-1993** → **11 sauvegarde manuelle** → 12 tabac → 13 création de partie et profils (dont célibataire) → 14 étoiles → puis un chapitre à la fois (produits modernes et canaux de frais avec les chapitres qui les demandent), mort du personnage avant que les parties ne deviennent longues, 1950-1976 à la fin.

---

## 0 bis. Décisions du joueur (18/11) et ce qu'elles changent au plan v1

| Décision | Plan v1 | Conséquence |
|---|---|---|
| 2e chapitre 1989-1993 | 2019-2023 | Même marché P1 (prolongé de 12 mois, 1993) ; francs ; décor 1980 réutilisable (selon D-J3) ; ETF et euro reportés ; PEA arrive dès ce chapitre (09/1992). Lot 10 moins cher que l'ancien lot 12. |
| Fin = mort ou dernière année implémentée | 60 mois fixes | Une partie **enchaîne les chapitres** : transition de chapitre en cours de partie (contenu, banquier, rival, cartes, projets, titres), marché **continu** sur toute la plage, historique et courbes sur plus de 60 mois, sauvegarde manuelle plus utile, record à redéfinir (D-J2). |
| Début 1977 | 1950 visé | Le lot « avant 1978 » est reporté à la toute fin ; seul 1977 (12 mois avant P1) reste à couvrir : extension **vers l'arrière** du marché, risque pour la non-régression (§5). |
| Profils par chapitre, dont célibataire | profils de 1984 seulement | 3 profils de départ par chapitre ; les profils d'un chapitre **continuent** dans les suivants (Gérard a 31 ans en 1989). |
| Décor par 10 ans | thème fixé par chapitre | Le décor est choisi **par la date** (`index.json > themes`) ; il peut changer en cours de partie. |
| Saisie d'une année précise | option (a) reportée | La création de partie accepte un départ à n'importe quel mois de janvier ; le contenu déjà passé du chapitre est sauté (mesuré au lot 09, `MESURE debut_libre`). |
| Ordre : rééquilibrage, socle, puis 1989-1993 et sauvegarde | lot 09 puis 10 création, 11 produits, 12 chapitre 2019 | Nouvelle séquence du §3. |

---

## 1. Audit technique (inchangé depuis la v1, sauf notes « v2 »)

### 1.1 Ce qui est déjà générique (aucune date en dur, fonctionne de 1976 à 2025)

| Élément | Où | Remarque |
|---|---|---|
| Calendrier (mois absolus, textes de dates) | `dates.gd` | Toute année. |
| Séries datées : Livret A (taux 1976-2025, plafonds 1977-2013), inflation 1976-2025, indice annuel / dividende / taux long 1977-2025, baguette 1975-2026 | `series.json`, `marche.gd` | **Rien avant 1976-1977** (voir §1.3). |
| Règles datées : impôts (taux unique, PEA 5 ans), courtage, agios, SICAV | `regles.json`, `Donnees.regle_datee` | Impôts et courtage depuis 1978, agios depuis 1970. |
| Salaires et dépenses par profil, interpolés, bascule F/€ | `salaires.json` | 1975-2025, 4 profils (jeune, technicien, cadre, héritier) ; prénoms prévus par période (P1/P2/P3). v2 : lignes 2023/2025 corrigées au lot 09 (D10). |
| Générateur de marché (pont brownien entre ancrages, β + volatilité propre, fonds) | `marche.gd` | Déterministe par graine de période (A12). |
| Disponibilité d'un produit à sa date (`dispo`), offre publique (`offre`) | `marche.gd`, `etat_partie.gd` | Règle « seuls les produits disponibles à la date jouée » déjà tenue. |
| Événements de marché et notifications de contexte | `periode_p1.json > evenements, contexte` | Format prêt pour P2/P3 (V1 : `jeu/data/periode_p2.js`, `periode_p3.js`). |
| Déclencheurs des présentations du banquier | `banque.json > declencheurs` | En **mois relatifs au début** de la partie (pas en dates) : réutilisables. v2 : à rendre relatifs **au début du chapitre** pour une partie qui traverse les chapitres (lot 10). |
| Moteurs des cartes, projets, cadence, versements, flux du mois, dividendes, témoins (Matelas, Livret, Indice), bilan, sauvegarde (format 3, migration douce) | `foyer.gd`, `projets.gd`, `cadence.gd`, `versements.gd`, `bilan.gd`, `sauvegarde.gd` | Règles génériques ; les **dates et montants sont dans les données** (créneaux, fenêtres, échéances), donc à réécrire par chapitre mais pas à recoder. |
| Affichage de la devise | `format.gd` | F avant 2002, € ensuite. |

### 1.2 Ce qui est lié à 1984-1988 (à déplacer en données ou à généraliser)

| # | Élément | Où | Nature | Traitement (v2 : lot) |
|---|---|---|---|---|
| H1 | Fenêtre de jeu, personnage, départ (11 000 F), naissance 04/1985, moments, titre « de 1978 à aujourd'hui » | `demo.json`, `Donnees.config_demo`, `principal.gd` l. 29 et 125, scénarios de capture | Un seul scénario codé | `chapitre.json`, `config_chapitre` (**lot 09**). |
| H2 | Identité de la période : `id_periode := "P1"`, `Donnees.periode(id)` à plat | `etat_partie.gd` l. 18, 129 ; `donnees.gd` | Une seule période portée | Le chapitre nomme son marché (**lot 09**). |
| H3 | Fenêtre de marché fixe de 15 ans : `Marche.N = 181`, boucle `debut-1 … debut+15`, `hist` de 180 cases, `m_fin` ≤ 179 | `marche.gd` l. 7, 44 ; `etat_partie.gd` l. 36, 92, 141-143 | v2 : **bloquant dès 1993** (P1 finit en 12/1992) | Taille lue dans les données (**lot 09**, mêmes valeurs) ; P1 prolongé à 12/1993 (**lot 10**). |
| H4 | Types de produits : `livret`, `pel`, `emprunt`, `av`, `sicav`, `action` ; listes en dur | `etat_partie.gd` l. 175, 198 ; `marche.gd` l. 64, 81 | Pas d'ETF, PEA, LDDS/LEP, PER | PEA (**lot 10**) ; ETF, canaux de frais (chapitre 1999-2003) ; PER notion (chapitre 2019-2023). |
| H5 | Catalogue de la banque 1984-1988 | `banque.json` | Contenu daté | Par chapitre (**lot 09** : déplacement ; **lot 10** : catalogue 1989-1993 qui **continue** les produits ouverts). |
| H6 | `notes_1984`, année « 1985 » par défaut, `nb_sg` (Saint-Gobain 310 F), « Héritage de tante Odette », « M. Lefranc » | `banquier.gd`, `versements.gd` | Code | **Lot 10**. |
| H7 | Cartes du foyer datées 1984-1988, « Sylvie » dans les phrases | `foyer.json` | Données | Par chapitre ; gabarits `{proche}` (lot 13). |
| H8 | Projets datés 1984-1988 | `projets.json` | Données | Par chapitre (lot 10). |
| H9 | Jean-Mi : plan sur **Peugeot** en francs ; `cours("peugeot")` en dur ; `Quartier` en F | `temoins.json > jeanmi`, `rue.json`, `quartier.gd`, `etat_partie.gd` | Données + code | **Lot 10** (rival de 1989-1993 ou suite de Jean-Mi). |
| H10 | Lundi noir et « un an après » datés | `krach.json`, `krach.gd`, `cadence.gd`, `etat_partie.gd` | Mécanique générale, données datées | « Vitrine » par chapitre (**lot 10**, 2e cas : guerre du Golfe 1990 ou crise du SME 1992, choix du boursier). |
| H11 | Titres d'époque, `fenetre_vente_krach` | `titres.json` | Données | Par chapitre ; v2 : titre **par chapitre traversé** ou par partie (D-J2). |
| H12 | Record unique, collection sans période | `records.gd`, `records.sav` v1 | Format | v2 : attend D-J2 (lot 10 ou 13). |
| H13 | Pas d'ancien franc ni de double affichage 1999-2001 ; « F » en dur dans `Quartier` | `format.gd`, `quartier.gd` | Code | Double affichage avec le chapitre 1999-2003 ; ancien franc : seulement si 1950-1976 est fait. |
| H14 | IPC borné à 1976-2026, séries annuelles absentes avant 1976-1977 | `marche.gd`, `series.json` | Données | 1977 : vérifier au lot « 1979-1983 » ; avant : fin du projet. |
| H15 | Prénoms des naissances « années 1980 » | `evenements_vie.json` | Données | Par chapitre (lot 09 : déplacé). |
| H16 | Tests calés sur 1984-1988 | `strategie_test.gd`, `tests/*` | Tests | Deviennent ceux du chapitre « 1984 » ; `test_reference_1984` (lot 09). |
| H17 | Interface et ville : ~300 occurrences de 1984-1989 / Gérard / Sylvie / Lefranc / Odette / Jean-Mi / Gazette dans ~50 fichiers | `scripts/ui`, `scripts/ville`, `scripts/pixel` | Décor et noms | Inventaire au lot 09 (09-I) ; noms lus dans les données au lot 10. |
| H18 | Export : `include_filter="data/*.json, data/pixel/*/*.txt"` | `export_presets.cfg` | **Piège** : `data/chapitres/*/` non exporté | Filtre étendu, CA-L5 du **lot 09**. |

### 1.3 Données historiques disponibles, par décennie

| Décennie | Dans le jeu (`godot/data`) | Dans les documents | Certitude | Manque principal |
|---|---|---|---|---|
| 1950 | rien | docs/02 §4.2, docs/33 B1, docs/34 K1 | C | Hors plage jusqu'à la fin du projet |
| 1960 | rien | docs/02 §4.2, docs/33 B1 | C | idem |
| 1970 | inflation 1976-1979, indice 1977-1979 | docs/02 §4.2, §4.4, docs/33 B1.1 | B | 1977 : 12 mois de marché avant P1 |
| 1980 | **complet** (P1 1978-1992, démo 1984-1988) | docs/18 à 29 | A/B/C | — |
| 1990 | P1 jusqu'en 1992 (ancrages 1990-1992 dont guerre du Golfe) ; séries 1990-1999 | V1 `periode_p2.js` (1996-2010) | B | **1993** (ancrages, actions), catalogue 1989-1993, PEA ; 1994-1995 entre P1 et P2 |
| 2000 | séries | V1 `periode_p2.js` | A/B | ETF, euro, courtage en ligne |
| 2010-2020 | séries jusqu'en 2025 | V1 `periode_p3.js`, docs/33 B3, docs/34 K2, docs/35 §3, docs/36 §10 | A | Raccord des marchés (v2 : marché continu) |

---

## 2. Architecture cible (v2)

### 2.1 Le monde, les chapitres, la partie

- **Monde** (racine de `godot/data/`) : séries, règles, salaires, rythme, marchés.
- **Chapitre** : tranche de 5 ans de **contenu** (`data/chapitres/<id>/`, id = année de début) : catalogue du banquier, cartes, projets, rival, rue, vitrine, titres, pop-up, profils de départ, événements de vie. Ses fichiers remplacent ceux du monde du même nom.
- **Partie** : commence au début d'un chapitre ou à une année précise ; le **chapitre actif** est celui qui contient le mois courant ; elle finit à la mort du personnage ou à la fin du dernier chapitre ouvert.
- **Marché continu** (v2) : une partie peut aller de 1984 à 1993, puis de 1977 à l'année en cours. Les marchés de 15 ans de docs/03 A7 deviennent des **segments** d'une même frise. Règle : prolonger un marché **vers l'avant** (P1 → 12/1993) ne doit pas changer un seul cours antérieur (tirages dans l'ordre chronologique, à vérifier au lot 10) ; **vers l'arrière** (1977) ou au raccord de deux marchés (1993 → P2 de 1996), on ajoute un segment à graine propre plutôt que de décaler les indices (sinon la non-régression de 1984-1988 casse).

### 2.2 Dossiers et chargement

Détail figé dans `lot_09.md` §3 : `data/chapitres/index.json` (`premiere_annee`, `chapitre_defaut`, `chapitres[]`, `themes[]`), `data/chapitres/1984/*.json`, `Donnees.charger` chapitre → monde, alias `demo`, `chapitre_de(ab)`, `derniere_annee()`, `theme_a(ab)`, `config_chapitre`, `infos_chapitre`, signal `Partie.chapitre_change`.

### 2.3 Durée de partie

- Variable : du départ choisi à la **dernière année implémentée** (ou à la mort). Aujourd'hui 60 mois (1984-1988) ; après le lot 10 : 120 mois depuis 1984, 60 depuis 1989.
- Conséquences techniques (lot 10) : `hist` et courbes au-delà de 180 mois, `HISTORIQUE_MAX` (600 entrées), budgets de cadence par chapitre (la cible ≈ 20 min vaut **par chapitre**), lisibilité de la frise et de « Mon argent » sur 10 ans et plus (UX, U4).
- **Bilan d'étape** à chaque fin de chapitre (proposition, D-J1) : courte carte « 1984-1988 : ce que vous avez fait » (titre d'époque du chapitre, écart face à Tata), puis CONTINUER ou ARRÊTER ICI (qui ouvre l'écran de fin). Sans lui, une partie de 10 ans n'a plus de récompense intermédiaire.

### 2.4 Années de départ et chapitres

- Chapitres alignés sur 1984 : …, 1979-1983, **1984-1988**, **1989-1993**, 1994-1998, 1999-2003, 2004-2008, 2009-2013, 2014-2018, 2019-2023, 2024-2026/27.
- 1977-1978 : soit un premier chapitre « 1977-1983 » de 7 ans, soit un chapitre « 1979-1983 » et un départ en 1977 qui commence par 2 ans « sans chapitre » (contenu générique) : **D-J4**.
- Saisie d'une année précise : départ en janvier de cette année, dans le chapitre qui la contient ; le contenu daté déjà passé est sauté (créneaux de cartes, projets dont le choix est passé, événements scriptés) ; la règle exacte (que faire d'un projet à moitié passé, d'une présentation du banquier tardive) est à écrire par le game designer au lot 13, à partir de la mesure `MESURE debut_libre` du lot 09.

### 2.5 Profils

- 3 profils de départ par chapitre (`profils.json` du chapitre ; gabarit de docs/35 §2 : Gérard, Martine, Bernard pour 1984), dont un célibataire (R-SEUL : le « proche » remplace le conjoint, même moteur d'humeur).
- **Continuité** : un profil commencé dans un chapitre continue dans les suivants (âge, enfants, conjoint ou proche, salaire indexé). Chaque chapitre écrit donc son contenu pour **ses 3 profils de départ et pour les profils qui arrivent des chapitres précédents** (via les archétypes de cartes de docs/35 §1.3 et les gabarits `{proche}`, `{prenoms}`) : à cadrer par le game designer (G6).

### 2.6 Produits par date

- Règle inchangée : seuls les produits disponibles à la date jouée. Le catalogue d'un chapitre **continue** les produits déjà ouverts (un PEL de 1985 vit en 1990) et en présente de nouveaux.
- PEA (loi du 16/07/1992) : lot 10. ETF (2001), double affichage et courtage en ligne : chapitre 1999-2003. PER : notion (fiche ou relevé), chapitre 2019-2023, à trancher jouable ou non avec le banquier et le game designer.
- **Deux canaux de frais** (décision du joueur) : banque de réseau (conseiller, plus cher) et courtage à distance (moins cher, sans conseil) ; à l'ère Minitel il existe déjà des courtiers à distance, mais la leçon porte surtout à partir de 1998-1999 : introduction au chapitre 1994-1998 ou 1999-2003 selon le banquier (K5).

### 2.7 Séries de marché et événements historiques

- Ancrages, crises, événements et contextes restent dans le fichier de marché ; un chapitre choisit ses achetables (4 au plus), sa vitrine et ses contextes.
- 1989-1993 : P1 contient déjà 1990-1992 (guerre du Golfe : 1990-04 2 130 → 1990-09 1 472) ; il manque 1993.

### 2.8 Rival, titres, records

- Rival par chapitre ; Jean-Mi « rembourse jusqu'en 1990 » : suite de Jean-Mi ou nouveau rival en 1989, au game designer (G6).
- Titres : 9 archétypes par chapitre (docs/35 §1.5) ; attribués à la fin de chaque chapitre traversé (bilan d'étape) ou une fois à la fin de la partie : **D-J2**.
- Records : rangés par départ (chapitre ou année) ou par chapitre traversé : **D-J2**. `records.sav` v1 reste lu tant que ce n'est pas tranché ; la migration (v1 → v2) garde la collection actuelle du joueur.

### 2.9 Décor par tranche de 10 ans

- Le décor est choisi **par la date** (`index.json > themes`), pas par le chapitre : il peut changer en cours de partie (`ville.regler_theme`, lot 09). Thème « 1980 » = rue actuelle au pixel près.
- Découpage (**D-J3**) : (a) décennies civiles (changement en janvier 1990, en plein chapitre 1989-1993 : un thème « 1990 » complet est alors nécessaire au lot 10) ; (b) tranches alignées sur deux chapitres, 1984-1993 / 1994-2003 / … (aucun nouveau décor au lot 10 ; 1977-1983 garde le décor 1980) ; (c) 1979-1988 / 1989-1998 (thème « 1990 » au lot 10). **Recommandation : (b)**, la moins chère et sans changement en plein chapitre ; les petits signes d'époque (Twingo 1993, 3615…) passent par des variantes datées du thème.
- Règles de docs/36 §9 (même rue, ancres fixes, palette : ajouts en fin seulement).

### 2.10 Sauvegarde

- Format 3 conservé, migration douce (`chapitre` absent = « 1984 »). Avec des parties de 10 ans et plus, la **sauvegarde manuelle** (lot 11) gagne en utilité ; son résumé d'emplacement affiche l'année et le chapitre.

### 2.11 Interfaces

Figées pour le lot 09 dans `lot_09.md` §3. À ajouter au lot 10 : transition de chapitre côté modules (état des cartes, projets, rival, banquier à travers `chapitre_change`), bilan d'étape (`Bilan.etape(e, chapitre)`), records v2.

### 2.12 Tests

- `test_reference_1984` (lot 09) fige 1984-1988 au centime ; il reste vert à chaque lot suivant, **y compris quand la partie continue au-delà de 1988** (il borne la fin à 12/1988 par `config["fin"]`).
- Un `test_chapitre_<id>` par chapitre ; `test_titres_mesures` et `test_rue_mesures` (lot 08b) par chapitre ; option `tests.ps1 -Chapitre` si la durée dépasse quelques minutes.

---

## 3. Séquence des lots (v2)

| Lot | Contenu | Développeurs | Prérequis | Sortie |
|---|---|---|---|---|
| **08b Rééquilibrage** (`lot_08b_reequilibrage.md`) | Population de test plausible (P-REF), seuils des titres, marin sans concentration, dosage de la rue garanti | dev-logique | aucun | aucune (part avec le prochain export) |
| **09 Socle** (`lot_09.md`) | Chapitres en données, partie qui traverse les chapitres (éprouvée sur un jeu d'essai), fin à la dernière année, fenêtre de marché en données, décor choisi par la date, filtres d'export, salaires 2023-2025 | 09-V ∥ 08b ; 09-L après 08b ; 09-I après 09-L | aucun contenu d'expert | aucune (0.6.3 possible) |
| **10 Chapitre 1989-1993** | 10-L : P1 prolongé à 12/1993 sans changer un cours antérieur ; `data/chapitres/1989/` ; transition de chapitre dans Foyer, Projets, Quartier, Banquier, vitrine (H6, H9, H10) ; PEA ; fin en 12/1993 ; records/titres selon D-J2 ; calibrage (cartes, projets, rival, titres) pour les profils qui continuent depuis 1984 et ceux qui démarrent en 1989 (Gérard seul en 1984 tant que le lot 13 n'est pas fait ; en 1989, un profil de départ par défaut). 10-V : décor selon D-J3 (rien en option (b), sinon thème 1990) et variantes datées. 10-I : bilan d'étape, frise et courbes sur 120 mois, fiches PEA, noms lus dans les données, choix du chapitre de départ minimal (1984 ou 1989) sur l'écran titre. | les trois ; 10-L probablement en 2 branches successives (moteur multi-chapitres, puis contenu) | K4, B5, G6, U4 (§4) ; D-J1 à D-J5 | **0.7 « 1984-1993 »** |
| **11 Sauvegarde manuelle** | `lot_sauvegarde.md` mis à jour (résumé avec année et chapitre, record selon D-J2) | dev-logique puis dev-interface | lot 10 fusionné (format de la partie stabilisé) | 0.7.1 |
| **12 Bureau de tabac** | Tickets à gratter avec compteur net et garde-fous de docs/35 §4 ; la devanture TABAC existe déjà dans la rue | les trois | G7, U5, question juridique (D-J6) | 0.8 |
| **13 Création de partie et profils** | Écran de choix (docs/36 U1) : chapitre **ou** année précise, 3 profils par chapitre ; Martine et Bernard (célibataire, R-SEUL) en 1984, profils de 1989 ; pop-up de début par profil ; records par départ | dev-interface, dev-logique, dev-ville (portraits, proche à la fenêtre) | G2 (docs/35 §2, fait), K3, U1 (docs/36, fait), règle de départ libre (G6) | 0.9 |
| **14 Étoiles** | Trophées de bonne pratique sous forme d'étoiles (docs/35 §4.1), communs à tous les chapitres | dev-logique, dev-interface | G8, U6 | |
| **Mort du personnage** | Événement de fin, à concevoir (ton, âge, probabilité) | dev-logique, dev-interface | G9, D-J7 ; nécessaire avant que les parties ne dépassent ≈ 30 ans | |
| **Chapitres suivants** | Un lot par chapitre : 1979-1983 (+ 1977, D-J4), 1994-1998, 1999-2003 (euro, ETF 2001, courtage en ligne et canaux de frais), 2004-2008, 2009-2013, 2014-2018, 2019-2023 (docs/33-36 déjà écrits, PER notion), 2024-2026 | les trois | contenus par chapitre | |
| **Fin du projet** | 1950-1976 « très light », niveaux d'explication, casino (porte juridique) | | décisions du joueur | |

Parallélisme : 09-V tout de suite (fichiers disjoints du 08b) ; jamais deux lots logiques en même temps sur `etat_partie.gd` et `data/` ; 12-V (tabac côté ville) peut avancer pendant 11 si les fichiers sont disjoints.

---

## 4. Contenus à commander et questions

### 4.1 Pour le chapitre 1989-1993 (lot 10) : demandes à envoyer maintenant

- **B5 (boursier)** — Marché 1989-1993 : (1) ancrages mensuels de l'indice de 12/1988 à 12/1993 (revue de ceux de P1 1990-1992, ajout de 1993), certitude par point ; (2) les actions achetables de 1984-1988 qui continuent (cours de fin de mois jusqu'en 12/1993, dividendes, événements de titre) et 1 à 2 nouvelles (privatisations de 1993 : BNP 10/1993, Rhône-Poulenc 11/1993 ; offre publique et prix) ; SICAV monétaires (taux courts de 1989-1993) ; (3) **vitrine** du chapitre : guerre du Golfe (08/1990-01/1991) ou crise du SME (09/1992), séquence jour par jour (≈ 7 séances), cours retenu, « un an après » qui doit être vrai ; (4) événements de marché et contextes au présent, sans divulgâcheur (chute du Mur 11/1989, Maastricht 09/1992…), 10-12 titres de kiosque ; (5) la Gazette en 1989-1993 (3615 ?) ; (6) dire si prolonger P1 jusqu'en 12/1993 est cohérent avec P2 (1996) ou s'il faut combler 1994-1995 plus tard.
- **K4 (banquier)** — Catalogue 1989-1993 : produits qui continuent (PEL de 1984-1988 à leurs taux, AV, SICAV, Livret A et ses taux 1989-1993) et nouveaux (PEP 1990, PEA 07/1992 et plafond, LEP/CODEVI si utiles, emprunt Balladur 1993, privatisations), présentations (≤ 30 mots, vouvoiement, aucun conseil) et déclencheurs relatifs au début du chapitre ; fiscalité datée (CSG sur les revenus du capital 1991, régime des SICAV de capitalisation, plus-values, PEA 5 ans) ; courtage et droits de garde 1989-1993, banque de réseau / courtier à distance (Minitel) : à partir de quand présenter les **deux canaux de frais** ; salaires et dépenses 1989-1993 (lignes 1990 et 1995 de `salaires.json`) ; le banquier en 1989 (M. Lefranc continue ? « Mme Delmas » réservée à une époque plus tardive) ; événement de transmission équivalent à tante Odette pour les profils qui continuent ; le **point 4** de son retour, réexpliqué au joueur par le coordinateur.
- **G6 (game designer)** — Chapitre 1989-1993 : (1) 3 profils de départ en 1989 (dont célibataire) et la continuité des profils de 1984 (Gérard 31 ans, ses enfants, Sylvie) ; (2) 10 créneaux de cartes, 16 cartes (archétypes de docs/35 §1.3) ; (3) 2 projets ; (4) rival : suite de Jean-Mi (« rembourse jusqu'en 1990 ») ou nouveau rival, toujours sans récompense à la spéculation ; (5) textes de la vitrine et de « un an après » ; (6) 9 titres renommés d'époque ; passages de la rue ; accroche ; (7) **bilan d'étape** de fin de chapitre (contenu, récompense, CONTINUER / ARRÊTER) ; (8) règle d'un départ à une année précise (contenu passé sauté) ; (9) G-R1 et G-R2 du lot 08b.
- **U4 (UX)** — Partie longue : bilan d'étape (PC 1920 × 1080, téléphones 1440 × 648 et 1280 × 720), frise des dates et courbe de « Mon argent » sur 10 ans et plus, écran de fin d'une partie qui a traversé deux chapitres, choix minimal du chapitre de départ sur l'écran titre (en attendant l'écran complet de docs/36 U1) ; fiches PEA ; thème « 1990 » seulement si D-J3 ≠ (b).
- **C2 (client)** — Reporter dans docs/03 les décisions du joueur (A7 : marchés en segments d'une frise continue ; A9 : 1950-1976 en fin de projet ; A10 : parties de durée variable, fin à la mort ou à la dernière année implémentée).

### 4.2 Plus tard (lots 12 à 14)

- G7 / U5 : bureau de tabac (règles, garde-fous, écran) ; G8 / U6 : étoiles ; G9 : mort du personnage ; K5 : deux canaux de frais (chapitre où ils apparaissent) ; K3 : textes des profils Martine et Bernard (docs/35 §2).

### 4.3 Décisions du joueur à obtenir (par le coordinateur)

- **D-J1 Partie qui continue** : une partie commencée en 1984 se poursuivra jusqu'en 1993 après le lot 10 (≈ 40 min au lieu de 20). D'accord, avec un **bilan d'étape** à chaque fin de chapitre (CONTINUER ou ARRÊTER ICI) ? Défaut : oui.
- **D-J2 Titres et record d'une partie longue** : titre d'époque à chaque chapitre traversé (plusieurs titres par partie) ou un seul à la fin ? Record rangé par chapitre de départ, par année de départ, ou par chapitre traversé ? Défaut : un titre par chapitre traversé, record par chapitre de départ.
- **D-J3 Décor par 10 ans** : (a) décennies civiles, (b) tranches de deux chapitres 1984-1993 / 1994-2003, (c) 1979-1988 / 1989-1998 (§2.9). Défaut recommandé : (b).
- **D-J4 1977-1978** : premier chapitre de 7 ans « 1977-1983 », ou chapitre 1979-1983 et deux années d'avant sans contenu scénarisé ? Défaut : 1977-1983 de 7 ans.
- **D-J5 Profils qui continuent** : un joueur parti en 1984 avec Gérard le garde jusqu'à la fin (il vieillit), et les profils de 1989 servent seulement à ceux qui démarrent en 1989. Défaut : oui.
- **D-J6 Bureau de tabac** : les tickets à gratter sont aussi des jeux d'argent (FDJ) ; la même question juridique que pour le casino se pose (jeu simulé, sans argent réel, avec compteur net et message de prévention). On avance avec ces garde-fous ? Défaut : oui, sans mise réelle ni achat intégré, à confirmer.
- **D-J7 Mort du personnage** : seulement liée à l'âge en fin de très longue partie, ou aussi accidentelle ? Ton (sobre, hors écran) ? Défaut : liée à l'âge, sobre, jamais avant 70 ans.
- **Q-R1 (lot 08b)** : Jean-Mi trop présent, pas assez, ou bien dosé selon les testeurs ?

---

## 5. Risques et parades (v2)

| Risque | Gravité | Parade |
|---|---|---|
| Régression de 1984-1988 pendant la migration | forte | Lot 09 sans changement visible ; `test_reference_1984` figé avant toute migration (CA-L1) ; thème « 1980 » au pixel (CA-V1). |
| Prolonger le marché casse les cours antérieurs | forte | Vers l'avant : vérifier que les tirages sont chronologiques ; vers l'arrière ou au raccord : segment à graine propre (§2.1) ; `test_reference_1984` à chaque lot. |
| Données de chapitre absentes de l'exe ou de l'APK | forte | Filtres d'export et CA-L5 (exe par `--main-pack`). |
| Parties longues : rythme, durée, lisibilité des courbes, taille de la sauvegarde et de l'historique | forte | Bilan d'étape (D-J1), cadence par chapitre, UX U4, mesure de durée au lot 10, sauvegarde manuelle (lot 11), `HISTORIQUE_MAX` revu. |
| Transition de chapitre en cours de partie (cartes, projets, rival, banquier) | forte | Éprouvée sur un jeu d'essai au lot 09 ; règles par module au lot 10 ; un test de bascule par module. |
| Records et sauvegarde du joueur perdus | forte | Migration douce ; tests sur des copies ; jamais d'écriture du vrai `records.sav` en test. |
| Volume de contenu par chapitre et par profil (3 profils de départ + profils qui continuent) | forte | Gabarit et archétypes (docs/35) ; un chapitre à la fois ; pas de chapitre ouvert sans contenu complet. |
| Titres et dosage déséquilibrés à chaque nouveau chapitre | moyenne | P-REF et mesures du lot 08b rejouées par chapitre. |
| Jeux d'argent (tabac) mal perçus ou illégaux | moyenne | D-J6 ; garde-fous ; aucun argent réel. |
| Durée des tests | faible | Option `-Chapitre` ; série complète avant les exports seulement. |
| Conflit avec la sauvegarde manuelle (mêmes fichiers) | moyenne | Lot 11 après le lot 10, jamais en parallèle sur `etat_partie.gd` / `partie.gd`. |

---

## 6. Carte de propriété

Lot 08b : `lot_08b_reequilibrage.md` §3. Lot 09 : `lot_09.md` §2. Règles permanentes : `chef-de-projet.md` §1.
