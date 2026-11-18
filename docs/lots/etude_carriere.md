# Étude : carrière simplifiée (faisabilité, coût, placement)

> Chef de projet, 2026-11-18. **Étude, rien n'est décidé ni lancé.** Idée du joueur : docs/10, section « 2026-11-18 (carrière simplifiée) ». Avis lus : docs/42 (game designer), docs/43 (UX), docs/44 (client). Code lu sur `main` : `scripts/logique/foyer.gd` (`ajuster_salaire`, tirage des candidates), `etat_partie.gd` (`depenses`, `epargne_du_mois`, indexation de janvier l. 793-794), `data/chapitres/1984/foyer.json` (C07).
> Une 2e étude intégrera les événements de vie aléatoires du game designer (docs/45, à venir).

## 0. En bref

1. La variante minimale **n'est pas du « contenu sans code »** : le moteur ne garde **qu'un seul** effet de salaire à la fois (`foyer["salaire"]`), à une **date absolue**, **sans fin** ; surtout, les **dépenses suivent le salaire** (pourcentages de `salaire_base`), donc une hausse de 10 % ne donne que ≈ +1,5 à +2,4 % du salaire en épargne : l'effet serait presque invisible.
2. Coût de la variante minimale : **≈ 5 développeur-jours** (dev-logique 3 à 3,5 ; dev-interface 1,5 ; dev-ville 0). Version complète : **≈ 17 à 20 développeur-jours** en plus du minimal.
3. **Placement recommandé** : le moteur (liste d'effets de salaire, date relative, fin d'effet) **dans 10-L**, car le lot 10 en a besoin de toute façon (promotion de Gérard en 03/1990 après le CNAM, docs/39 : 2e effet de salaire). Le **pilote de 2 cartes (K4, K5) en 1989-1993** vient dans un **mini-lot 10c**, juste après la fusion du lot 10 : il ne retarde pas l'export 0.7 (il part avec la 0.7 s'il est prêt à temps, sinon en 0.7.1).
4. **1984-1988 reste la référence** : pas de K2 ni de K3 dans ce chapitre tant que le joueur n'a pas jugé le pilote ; ensuite seulement derrière un réglage `config["carriere"]` (allumé pour le joueur, éteint pour `test_reference_1984`) et un tirage séparé.

## 1. Faisabilité technique

### 1.1 Le champ `salaire` des cartes aujourd'hui

`foyer.json` C07 : `"salaire": { "pct": 4, "des": "1988-01" }`. À la résolution, `Foyer` écrit **un seul** objet `e.foyer["salaire"] = {pct, m_des, applique}` ; `Foyer.ajuster_salaire`, appelé juste après l'indexation de janvier, fait `salaire_base *= 1 + pct/100` **une fois**.

| Besoin (docs/42) | Pris en charge ? | Travail |
|---|---|---|
| `pct` négatif (K5 : −10 %) | **Oui** mathématiquement (facteur 0,9), jamais testé | 1 test |
| Plusieurs effets dans une partie (C07 + promotion 1990 ; K4 + K5) | **Non** : le 2e choix **écrase** le 1er (le CNAM serait perdu si une autre carte salariale était choisie avant 1988) | liste d'effets `foyer["salaires"]` + migration douce de l'ancien champ |
| Date relative (« dès le mois suivant ») | **Non** : `des` est une date fixe | `des_rel` (mois après le choix) |
| Date de fin `jusqua` et retour à la normale (K5 : −10 % pendant 10 mois puis +8 % ; K6 : indemnités 6 mois) | **Non** | à la fin, division par le même facteur (l'indexation de janvier est multiplicative : le retour est exact) ; 2 étapes enchaînées = 2 effets de la liste |
| Effet visible sur l'épargne | **Non** : `depenses()` = parts de `salaire_base` (loyer, vie courante) ; l'épargne possible reste ≈ 15-24 % du salaire quoi qu'il arrive | champ `revenu_mois` (écart de revenu **hors** train de vie : la hausse va entière à l'épargne possible, la baisse la réduit d'autant) ou `depenses_M_mois` (K2 : garde du mercredi) ; décision Q7 |
| R-MIROIR (voisins mêmes revenus) | **Oui** pour `salaire_base` (partagé) ; le nouveau champ doit l'être aussi | dans le même calcul que `depenses()` |
| Ligne « Épargne possible : avant → après » | **Non** | `Foyer.epargne_apres(e, carte, choix)` + gabarit |
| Candidates dans des créneaux existants, sans pause en plus | **Oui** (`creneaux > candidates`, tirage à la graine de vie décalée) | données |
| `foyer: couple` / profils (R-SEUL) | **Non** aujourd'hui (seul `requiert_enfant`) | prévu au lot 13 ; inutile pour K4/K5 (Gérard et Christine en couple) |

Conclusion : les 3 premières lignes (liste, date relative, fin) sont **déjà nécessaires au lot 10** (promotion scriptée de 03/1990, continuité du CNAM à travers la bascule de chapitre). Les 3 suivantes sont propres à la carrière.

### 1.2 Coût en développeur-jours (estimation, ± 30 %)

| Élément | dev-logique | dev-interface | dev-ville |
|---|---|---|---|
| **Variante minimale** (K4, K5 en 1989-1993 ; 2 boutons ; montant mensuel ; ligne « Métier » dans « Mon foyer ») | | | |
| Liste d'effets, `des_rel`, `jusqua`, migration douce (**dans 10-L**) | 1 | | |
| Écart de revenu hors train de vie + R-MIROIR | 1 | | |
| `epargne_apres`, ligne « Métier » (donnée du profil), cartes K4/K5 en données | 0,5 | | |
| Tests (bornes, sauvegarde, R-MIROIR, mesure : aucune option dominante, écart de patrimoine 5-10 %, critère du client) | 1 | | |
| Bouton à montant mensuel + ligne « Épargne possible » dans la carte existante ; ligne « Métier » ; captures PC et 2 téléphones | | 1,5 | |
| **Total minimal** | **3,5** (dont 1 déjà dû au lot 10) | **1,5** | **0** |
| **Version complète** (en plus) | | | |
| Statut de temps à 3 valeurs (usure de janvier, sauvegarde, « Mon foyer ») | 1 | 0,5 | |
| Suites différées (K6 : PME qui ferme, probabilité, anti-cumul avec les projets), K7 (prime, indemnités) | 2,5 | | |
| Bilan de carrière (données de fin) | 0,5 | | |
| Lettre à en-tête 2-3 colonnes, 4 lignes (docs/43 §2.3-2.4), touches 1-3 | | 3 | |
| Sortie par la boîte aux lettres, bulle « Nouveau salaire », rubrique CARRIÈRE, mini-frise de fin | | 3 | 0,5 (drapeau) |
| Trajet de Gérard (aube / soir), 3 sprites, arrêt de bus, panneau, variantes Peu / Beaucoup | | | 3,5 |
| **Total complet en plus** | **4** | **6,5** | **4** |

## 2. Conflits de fichiers

- **Lot 09-I (en cours, dev-interface)** : `principal.gd`, `ui/modale_intro.gd`, `ui/ecran_titre.gd`, `ui/frise.gd`. La carrière touche la modale des cartes du foyer et « Mon foyer » : **aucun fichier commun**, mais rien n'est lancé avant la fin du lot 09 (un seul développeur interface).
- **Lot 10** : 10-L réécrit `foyer.gd` et les données du foyer (cartes 1989-1993, bascule de chapitre, profil Christine) et `etat_partie.gd` (fenêtre de marché, chapitres). La carrière touche **les mêmes fichiers** : jamais en parallèle. D'où le découpage : le moteur des effets de salaire **dans** 10-L, le pilote (10c) **après** la fusion de 10-L ; 10c-I après 10-I (même modale, même « Mon foyer »).
- **Lot 11 (sauvegarde manuelle)** : touche `partie.gd`, `sauvegarde.gd` et des écrans de menu ; 10c n'ajoute qu'un champ migré en douceur dans l'état du foyer : compatible, 10c avant 11 de préférence (format stabilisé).

## 3. Placement

- Le client accepte un pilote **dans** le lot 10 seulement si c'est du contenu sans nouveau code : **ce n'est pas le cas** (§1.1). Donc :
  1. **10-L** : liste d'effets de salaire, `des_rel`, `jusqua` (besoin propre du lot 10, coût 1 jour déjà compté) ;
  2. **10c « pilote carrière »** juste après la fusion du lot 10 : dev-logique (2,5 j) puis dev-interface (1,5 j), recette courte (étapes ciblées : carte, « Mon foyer », fin) ; part avec la 0.7 si elle est prête quand le lot 10 l'est, sinon en 0.7.1 ; **jamais un jour de retard pour la 0.7** ;
  3. après le verdict du joueur sur le pilote (critères du client, docs/44 §7) : statut de temps, K6/K7, puis la version complète (lettre, trajet) dans un lot dédié, et K2/K3 en 1984-1988 derrière `config["carriere"]`.
- Le plan du lot 10 (`lot_10.md`, à écrire) reprendra le §1.1 (lignes 1 à 3) dans son contrat.

## 4. Risques pour la non-régression de 1984-1988

- Ajouter K2 (S3) et K3 (S6) aux candidates de 1984-1988 **change le tirage** des créneaux (une candidate de plus = d'autres cartes tirées) et les revenus : `test_reference_1984` (35 parties figées au centime, md5 de l'historique) casserait, et avec lui le record et les titres du joueur sur la démo.
- Proposition : **réserver la carrière aux chapitres à partir de 1989** pour le pilote. Plus tard, si le joueur veut K2/K3 en 1984-1988 : liste `candidates_carriere` lue seulement si `config["carriere"]` est vrai (allumé par `principal._config()` hors capture, comme `cartes`, `projets`, `rue`), tirée avec un **décalage de graine propre** (aucun tirage existant ne bouge quand c'est éteint) ; `test_reference_1984` tourne éteint, un 2e jeu de références « carrière allumée » est créé à part.
- Pilote en 1989-1993 : aucune référence existante (le chapitre est neuf) ; seule condition, la promotion CNAM et C07 restent identiques en 1984-1988 (liste d'effets avec un seul élément = même calcul, vérifié par `test_reference_1984`).

## 5. Questions au joueur (avec recommandation)

| # | Question | Recommandation |
|---|---|---|
| Q1 | Pilote de 2 cartes « Travail » en 1989-1993 (le poste itinérant, le congé formation), dans un mini-lot juste après le lot 10, sans retarder la 0.7 ? | **Oui.** |
| Q2 | Variante minimale d'abord (carte actuelle à 2 boutons, montant par mois, ligne « Métier » dans « Mon foyer »), la lettre à en-tête et le trajet de Gérard seulement si le pilote plaît ? | **Oui.** |
| Q3 | Le temps libre passe seulement par l'humeur de Sylvie pour le pilote (pas de statut « du temps / prenant ») ? | **Oui**, le statut vient après le verdict. |
| Q4 | Une augmentation va-t-elle entièrement à l'épargne possible (on garde le même train de vie), ou le train de vie suit-il le salaire comme aujourd'hui (effet presque invisible) ? | **Entièrement à l'épargne possible**, avec la phrase « Une augmentation qu'on ne dépense pas devient de l'épargne chaque mois. » ; les cartes suivantes tentent ensuite de la dépenser. |
| Q5 | Garder 1984-1988 sans carte de carrière (c'est la partie de référence), et les y ajouter plus tard derrière un réglage ? | **Oui.** |
| Q6 | La PME qui ferme (1 partie sur 2 après « partir ») et le plan de départs de 1993 : après le pilote seulement ? | **Oui**, après le verdict. |
| Q7 | Les voisins suivent les mêmes changements de salaire (le classement reste une affaire de placements) ? | **Oui** (R-MIROIR, comme le CNAM aujourd'hui). |
| Q8 | Retraite et PER : seulement aux chapitres où ils ont du sens ? | **Oui** (PER en notion au chapitre 2019-2023). |

Hors joueur : montants et réalisme (temps partiel d'un technicien en 1990-1993, congé formation, indemnités) au **banquier** avant 10c ; règle des 3 axes et écart de patrimoine visé (5-10 %) au **game designer**, mesurés par dev-logique en 10c.
