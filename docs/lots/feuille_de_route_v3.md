# Feuille de route v3 : de la 0.7 « dix ans » aux chapitres suivants

> Chef de projet, 2026-11-18 (nuit). Découpage en versions **validé par le joueur** (0.7 « dix ans » à la fin du lot 10, 0.8 « profils et vie », 0.9 « confort », puis un chapitre par lot). Sources qui priment : `decisions_extension_annees.md` (toutes les puces, dont la dernière : **catalogue des produits du monde**), `docs/10_retours_joueur.md` (18/11). S'appuie sur `plan_extension_annees.md` v2, `etude_carriere.md`, docs/39 à 45.
> Remplace le §3 de `plan_extension_annees.md` pour l'ordre et le contenu des lots. **Plans détaillés** : `lot_10a.md` n'est écrit qu'après les rendus du banquier (docs/46) et du game designer (docs/39 mis à jour).
> Durées en **développeur-jours** (estimation ± 30 %, hors recettes du testeur et hors contenus d'experts).

## 0. En bref

| Version | Lots | Ce que le joueur reçoit | Durée de dev |
|---|---|---|---|
| **0.7 « dix ans »** | 10a, 10b, 10c | 1984 → 1993 en une partie (ou départ en 1989 avec Christine), carte de passage de chapitre, bilan final unique, un titre par chapitre, double record, PEA, pilote carrière (2 cartes), catalogue de produits du monde | ≈ 40 j |
| **0.8 « profils et vie »** | 11, 12 | événements de vie aléatoires (21), décès d'un parent, SCPI dès 1984 (révision consciente de 1984-1988), création de partie (chapitre ou année), célibataire, divorce, mort du personnage avec note, étoiles | ≈ 45 j |
| **0.9 « confort »** | 13 | sauvegarde manuelle (3 emplacements), bureau de tabac | ≈ 15 j |
| 0.10 et suivantes | 14+ | un chapitre de 5 ans par lot (1994-1998, 1977-1983…) | ≈ 15-20 j chacun |

Ordre strict : 10a → (10b ∥ 10c-L) → 10c-I → **export 0.7** → 11 → 12 → **export 0.8** → 13 → **export 0.9** → 14+. Série de captures complète avant chaque export (règle du 17/11).

## 0 bis. Lot 10 : plans écrits (18/11, après docs/46 et docs/47)

- `lot_10a.md` (moteur ≈ 11 j puis contenu ≈ 7 j), `lot_10b.md` (ville ≈ 5 j ; interface ≈ 11 j en 2 étapes), `lot_10c.md` (pilote carrière ≈ 4,5 j, recette finale, export 0.7).
- Lancement à la fusion de 09-I : **10a-moteur ∥ 10b-ville ∥ 10b-interface étape 1** ; puis 10a-contenu ∥ 10b-interface étape 2 ; puis 10c-logique, 10c-interface ; recette finale sur la fusion complète.
- Arbitrages (`lot_10a.md` §1) : vitrine du Golfe selon docs/47 (étape 1 sans pause en 08/1990, modale en 09/1990, « un an après » en 09/1991) ; SCPI en 1989-1993 seulement (1984-1988 au lot 11) ; jumeaux 1/6 **par chapitre** (1984-1988 garde 1/4 jusqu'au re-gel du lot 11) ; PEP = message + « En savoir plus » ; K4/K5 toujours présentées. Valeurs C (boursier : 08/1990, 09/1991 ; banquier : SCPI) **non bloquantes**, à confirmer avant l'export 0.7. Tabac : lot 13 (prix et retour des tickets à valider par le banquier avant).
- Durée du lot 10 révisée : ≈ 38 j (au lieu de ≈ 40).

## 1. Décisions déjà prises (rappel, pour les plans de lots)

- Partie qui traverse les chapitres, fin à la dernière année implémentée ou à la mort ; **un seul bilan final** ; carte de passage de chapitre **version A** (docs/40) ; un titre par chapitre traversé ; records par chapitre de départ **et** sur la période totale (double record).
- Décor par tranche de 2 chapitres : **1984-1993 = un seul décor** (thème « 1980 » + variantes datées).
- Lot 10 : **Christine seule** comme profil de départ en 1989 ; Gérard continue et vieillit ; **mariage de Gérard : 70 %** de survenue sur le chapitre 1989-1993 (règle par âge et profil, game designer) ; **jumeaux 1 naissance sur 6** (au lieu de 1 sur 4).
- Carrière : **pilote K4 / K5 dans le lot 10** ; temps libre = humeur seulement ; l'humeur pèse **faiblement** sur la probabilité de divorce (lot 12) ; retraite et PER repoussés ; 8 réponses par défaut de `etude_carriere.md` validées (augmentation entière à l'épargne possible, R-MIROIR, rien en 1984-1988 tant que la référence n'est pas révisée…).
- Événements de **vie aléatoires** (date et survenue), événements de **marché** à leurs dates historiques (docs/45).
- Divorce (sobre, une fois au plus), décès d'un parent (pédagogie : patrimoine des parents de leur vivant, succession, indivision) admis.
- **Tabac lancé** (mécanique légère, aucune marque réelle, aucun argent réel) ; casino plus tard (classement 17+ à valider à la publication).
- Jean-Mi : dosage inchangé, pas de studio à crédit, pas de leçon sur la privatisation ; immobilier comme diversification, **SCPI** à étudier (banquier).
- **Catalogue des produits du monde** (dernière décision) : §3.

## 2. Les lots

### 10a « 1989-1993, logique » (dev-logique ; 2 branches successives)

| Branche | Contenu | Durée |
|---|---|---|
| `lot/10a-moteur` | **catalogue des produits du monde** (§3) avec migration de 1984-1988 **au bit près** ; P1 prolongé jusqu'en 12/1993 sans changer un cours antérieur ; bascule de chapitre dans Foyer, Projets, Quartier, Banquier, Krach (→ vitrine générique), Titres (un titre par chapitre), Records v2 (par chapitre de départ + période totale, migration de `records.sav` v1) ; liste d'effets de salaire (`des_rel`, `jusqua` : `etude_carriere.md` §1.1) ; `HISTORIQUE_MAX`, `hist` > 180 mois ; type d'enveloppe **PEA** ; résorption de M2 (jeu d'essai en copies) | ≈ 11 j |
| `lot/10a-contenu` | `data/chapitres/1989/` : Christine (profil de départ), continuité de Gérard (mariage 70 %, jumeaux 1/6 **pour les naissances de 1989-1993 seulement**), catalogue 1989-1993 (présentations dont PEA, PEP selon le game designer), cartes, 2 projets, rival (suite de Jean-Mi), vitrine, kiosque, titres d'époque ; `test_chapitre_1989`, P-REF et `test_rue_mesures` par chapitre, calibrage (projets 80 / 60 %, titres ≥ 3 % / ≤ 25 %) | ≈ 7 j |

Prérequis : banquier docs/46 (catalogue, PEA, PEP, SCPI, carrière chiffrée), game designer docs/39 mis à jour (vitrine, Christine, mariage, cartes), boursier (ancrages 1993). `test_reference_1984` **inchangé** (CA bloquant).

### 10b « 1989-1993, interface et ville » (dev-interface ∥ dev-ville, après la fusion de 10a-moteur)

- **dev-interface** (≈ 10 j) : carte de passage A ; frise et courbe de « Mon argent » sur 10 ans ; bilan final unique avec un titre par chapitre traversé ; double record (écran de fin, écran titre, collection par chapitre) ; noms lus dans les données (inventaire H17 de 09-I) ; fiches PEA ; choix minimal du départ (1984 avec Gérard ou 1989 avec Christine) sur l'écran titre ; branchement de `Partie.chapitre_change`.
- **dev-ville** (≈ 4 j) : décor 1984-1993 = thème « 1980 » + variantes datées 1989-1993 (petits signes d'époque, sans thème neuf) ; foyer de Christine (personnages, fenêtre du conjoint) ; vieillissement visible de Gérard et des enfants si le game designer le demande.
- Recette de la fusion complète : série de captures, PC et 2 téléphones.

### 10c « pilote carrière » (K4, K5 en 1989-1993)

- 10c-L (dev-logique, ≈ 2,5 j, après 10a-contenu) : écart de revenu hors train de vie + R-MIROIR, `epargne_apres`, cartes K4 / K5 candidates de créneaux existants (aucune pause en plus), mesure « aucune option dominante, écart de patrimoine 5-10 % ».
- 10c-I (dev-interface, ≈ 1,5 j, après 10b) : montant mensuel dans les 2 boutons, ligne « Épargne possible : avant → après », ligne « Métier » dans « Mon foyer ».
- Rien en 1984-1988. **Export 0.7** après 10c ; si 10c glisse, 0.7 part sans lui et 10c sort en 0.7.1 (le joueur a accepté le pilote « dans le lot 10 », pas un retard).

### 11 « Vie complète » (0.8, partie 1)

- dev-logique (≈ 8 j) : 21 événements de vie aléatoires (docs/45), plafond de malchance, décès d'un parent (contenu du banquier : donation, assurance-vie, succession, indivision) ; la naissance de 04/1985 et l'héritage de 04/1988 deviennent aléatoires ; jumeaux 1/6 partout ; **SCPI** (type de produit) et sa présentation **dès 1984-1988** ; **re-gel conscient** de 1984-1988 (§4).
- dev-interface (≈ 3 j) : modales et note du décès d'un parent, fiche SCPI, historique.
- dev-ville (≈ 1,5 j) : signes visuels des événements (deuil sobre, voiture accidentée…), selon l'UX.

### 12 « Profils et fin de vie » (0.8, partie 2)

- Création de partie (docs/36 U1) : chapitre **ou** année précise ; profils par chapitre (Gérard, Martine, Bernard en 1984 ; Christine + selon le game designer en 1989) ; **célibataire** (R-SEUL : proche, gabarits `{proche}`, cartes `foyer: seul`) ; pop-up de début par profil.
- **Divorce** (une fois au plus, lien faible avec l'humeur et la carrière) ; **mort du personnage** liée à l'âge, sobre, avec **note de transmission** (assurance-vie ou non, enfants, conjoint) ; **étoiles** (trophées de bonne pratique, docs/35 §4.1).
- Durée : dev-logique ≈ 12 j, dev-interface ≈ 10 j, dev-ville ≈ 3 j (portraits, proche à la fenêtre). Probablement 2 sous-lots (12a création + célibataire ; 12b divorce, mort, étoiles). **Export 0.8.**

### 13 « Confort » (0.9)

- Sauvegarde manuelle à 3 emplacements (`lot_sauvegarde.md`, résumé avec année, chapitre, profil, version de contenu) : dev-logique ≈ 3 j, dev-interface ≈ 4 j.
- Bureau de tabac (devanture TABAC existante ; tickets à gratter, compteur net, garde-fous de docs/35 §4, aucune marque réelle) : dev-logique ≈ 2 j, dev-interface ≈ 2 j, dev-ville ≈ 2 j. Peut avancer côté ville pendant SV (fichiers disjoints). **Export 0.9.**

### 14+ « Un chapitre par lot »

- Ordre proposé : 1994-1998 (P1/P2 à raccorder, 1994-1995 manquant ; nouveau décor « 1994-2003 »), puis 1977-1983 (7 ans, segment de marché vers l'arrière à graine propre), puis 1999-2003 (euro et double affichage, ETF 2001, **deux canaux de frais**), etc. ; 2019-2023 a déjà ses contenus (docs/33-36) ; investissements alternatifs à partir des années 2000 (après instruction banquier/boursier).
- Par chapitre : dev-logique ≈ 8 j, dev-interface ≈ 3 j, dev-ville ≈ 2 j (variantes) ou ≈ 6 j (nouveau décor tous les 2 chapitres).

## 3. Catalogue des produits du monde (exigence du joueur)

### 3.1 Principe

- Un produit est défini **une seule fois** dans `data/produits.json` (monde) : `id` stable (`livret`, `pel`, `scpi`, `pea`…), `type` moteur, nom, **date de naissance** (et de fin éventuelle), paramètres datés ou renvoi vers `regles.json` / `series.json`, notes à 5 critères, fiche générique (≤ 60 mots, sans date), certitude.
- Un **chapitre** ne définit plus de produit : il liste ses **présentations** (`banque.json > presentations`) : `produit`, `quand` (mois relatif au **début du chapitre**, ou date), `echeance`, texte propre facultatif (sinon la fiche générique), place dans le carnet.
- **Déplacer** une présentation = déplacer une ligne d'un `banque.json` de chapitre à un autre. Aucun code, aucune donnée de produit ne bouge.

### 3.2 Règles qui rendent le déplacement sûr

1. **Idempotence par produit** : l'état de la banque retient les produits **présentés** par `id`, pas par présentation. Un produit déjà présenté (dans un chapitre précédent de la partie) n'est jamais représenté ; le chapitre suivant peut seulement envoyer des **messages datés** (taux, plafond).
2. **Naissance** : une présentation avant la naissance du produit est refusée par un test de données (`test_catalogue` : pour chaque chapitre, `quand ≥ naissance`).
3. **Rattrapage** : un produit né avant le début de la partie, présenté par un chapitre déjà passé (départ à une année précise, chapitre antérieur ajouté plus tard), est mis dans une **file de rattrapage** présentée dans les premiers mois, selon la cadence existante (au plus une présentation par interruption).
4. **Textes de continuité** : le texte d'une présentation ne suppose pas un premier contact (« votre nouveau banquier ») ; l'accueil est un message séparé du chapitre de départ.
5. **Un type de produit inconnu du moteur** (ex. SCPI avant le lot 11) n'est jamais présenté : le test de données le signale.

## 4. Réviser 1984-1988 sans tout casser (re-gel conscient)

- `test_reference_1984` fige 35 parties au centime. Toute révision de contenu de 1984-1988 (SCPI dès 1984, vie aléatoire, jumeaux 1/6) suit **deux commits obligatoires** :
  1. **Code éteint** : le moteur sait faire (type SCPI, tirages aléatoires), mais la révision est derrière un interrupteur de données (`chapitre.json > revision`, ou absence de la ligne de présentation) : `test_reference_1984` **identique**.
  2. **Allumage = re-gel** : un seul commit allume la révision et met à jour les valeurs de `test_reference_1984` ; il est accompagné d'un **journal de re-gel** (`docs/lots/reference_1984.md` : partie par partie, ce qui change et pourquoi), vérifié par le testeur et validé par moi. C'est le **seul** commit autorisé à changer ces valeurs.
- Un seul re-gel par version si possible : le lot 11 réunit SCPI en 1984, vie aléatoire et jumeaux 1/6.
- `chapitre.json > version_contenu` (1 → 2) est inscrite dans la sauvegarde et les records : une sauvegarde de la version 1 se recharge et finit avec son contenu d'origine si c'est simple, sinon avec la version 2 (à trancher au lot 11) ; les records restent comparables par chapitre (question au joueur s'il faut les séparer par version : défaut, non).

### 4.1 Éviter que les chapitres antérieurs soient une réécriture

- Le monde (séries, règles, catalogue, marchés) est déjà continu ; un chapitre antérieur (1977-1983) n'ajoute que **ses présentations, ses cartes, sa vitrine** et un segment de marché à graine propre (aucun cours de 1984-1993 ne bouge).
- Une partie qui démarre en 1984 ne voit jamais rien de 1977-1983 : `test_reference_1984` reste vert quand on ajoute 1977-1983 (CA bloquant de ce futur lot).
- Une partie qui démarre en 1977 arrive en 1984 avec des produits déjà présentés : la règle d'idempotence (§3.2-1) saute leurs présentations de 1984 ; les cartes et projets de 1984 restent (contenu de vie, pas de produits).

## 5. Ce que 10a doit décider pour que le catalogue soit déplaçable

| # | Décision à figer dans `lot_10a.md` | Proposition |
|---|---|---|
| C1 | Emplacement et schéma de `data/produits.json` (champs, dates, renvois aux règles) | §3.1 ; les `parametres` datés de `banque.json` (PEL, AV) y passent |
| C2 | Identité des présentations : `id` de produit au lieu de `D01…D08` partout (état de la banque, sauvegarde, `StrategieTest` (`ouvrir: ["D01"]`), tests, historique) | `id` de produit ; table de correspondance `D0x → produit` gardée pour la migration des sauvegardes |
| C3 | Déclencheurs relatifs au **début du chapitre** (aujourd'hui : « 0 = janvier 1984 », c'est-à-dire le début de la partie) | relatifs au chapitre ; pour 1984, mêmes nombres (non-régression) |
| C4 | Règle de rattrapage (§3.2-3) et son budget de cadence | file présentée dès les premiers mois, une par interruption |
| C5 | Ce qui reste au chapitre : accueil, messages datés, héritage, versements, `frais_pedagogie`, ordre du carnet | au chapitre ; l'ordre du carnet devient « ordre de présentation » par défaut |
| C6 | Offres publiques datées (Saint-Gobain 1986, privatisations) : produit du monde avec fenêtre d'offre, présenté par un chapitre | oui, `offre` dans le catalogue |
| C7 | `version_contenu` par chapitre, inscrite dans la sauvegarde et les records | oui, 1 pour 1984-1988 dès 10a |
| C8 | Test de données `test_catalogue` (naissance, type connu, id unique, chaque produit présenté au plus une fois par chapitre) | oui |
| C9 | Non-régression : 10a-moteur passe `test_reference_1984` **sans le re-geler** | CA bloquant |

## 6. Propriété des fichiers (règles par lot ; détail dans chaque plan)

| Fichiers | Propriétaire |
|---|---|
| `data/*.json` dont `produits.json`, `data/chapitres/**`, `scripts/logique/*`, `partie.gd`, tests logiques, `test_reference_1984`, `tests.ps1`, `export_presets.cfg` | dev-logique |
| `principal.gd`, `scripts/ui/*`, scénarios d'interface, `test_interface` / `test_partie` / `test_ecran`, `project.godot` | dev-interface |
| `scripts/ville/*`, `scripts/pixel/*`, `data/themes/**`, `data/pixel/**`, scénarios et tests de la ville, `sequences.gd`, `juice.gd` | dev-ville |
| `tests/recette/` | testeur |

Jamais deux lots logiques en parallèle (`etat_partie.gd`, `foyer.gd`, `banque.json`) ; 10b et 10c-L en parallèle seulement parce que leurs fichiers sont disjoints ; 10c-I après 10b (mêmes modales, même « Mon foyer »).

## 7. Risques

| Risque | Gravité | Parade |
|---|---|---|
| Migration vers le catalogue qui change 1984-1988 | forte | 10a-moteur sans re-gel (C9) ; correspondance D0x → produit testée sur des sauvegardes réelles |
| Lot 10 trop gros pour une seule sortie | forte | 3 sous-lots ; 10c détachable en 0.7.1 ; contenu 1989 seulement quand docs/46 et docs/39 sont rendus |
| Re-gel mal maîtrisé (lot 11) | forte | interrupteur puis allumage, journal de re-gel, un seul commit autorisé |
| Parties longues (durée, rythme, courbes, sauvegarde) | moyenne | mesure de durée par chapitre ; sauvegarde manuelle en 0.9 ; carte de passage A |
| Vie aléatoire injuste (malchances en série) | moyenne | plafond de malchance (lot 11) mesuré sur P-REF |
| Volume de contenu par chapitre | forte | gabarit et archétypes (docs/35) ; experts en parallèle des développements |
| Tabac, casino perçus comme incitation | moyenne | aucune marque, compteur net, prévention ; casino 17+ à valider à la publication |
| Durée des tests (≈ 12 min avec `-Recette`) | moyenne | option `-Chapitre`, P-REF réduite hors exports |

## 8. Points à signaler au joueur

- **PEA** : né en **07/1992**, il ne peut pas être présenté en 1984-1988 ; il arrive bien dans 1989-1993. La **SCPI** (années 1970 selon le banquier, à confirmer en docs/46) peut, elle, être présentée dès 1984 : c'est la révision du lot 11.
- **PEP** (plan d'épargne populaire, 1990-2003) : épargne à 8 ou 10 ans avec avantage fiscal ; le game designer tranche entre fiche jouable et simple message (réexplication demandée par le joueur : à faire par le coordinateur avec le texte du banquier).
