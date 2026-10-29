# 14 : Propositions de game design — « Je trouve qu'on s'ennuie un peu »

> Auteur : game designer. Date : 2026-10-28. Statut : **propositions à soumettre au joueur réel. Rien n'est implémenté avant sa validation.**
> Sources : retours verbatim (10), arbitrages (12, base du client), cadence (13 §5), état réel du code (base du développeur), données (`godot/data/`), captures `v3_rue`, `v3_heritage`, `v2_fin`.
> Les propositions qui reviennent sur une décision existante le signalent par **[revient sur …]**.

---

## 1. Diagnostic : pourquoi on s'ennuie (8 points)

| # | Constat | Chiffre (démo actuelle, 60 mois) |
|---|---|---|
| D1 | **On regarde plus qu'on ne joue.** Le temps défile seul, la ville est un décor, rien ne se passe entre deux pop-ups. | 60 × 8 s = **8 min de défilement** à ×1, pour 11 à 13 interruptions (moyenne 11,3) : **une toutes les 5,3 mois, soit ≈ 42 s sans rien à faire**. |
| D2 | **De longs tunnels vides**, précisément là où l'histoire devrait monter en tension. | Nov. 1986 (Saint-Gobain) → oct. 1987 (krach) : **11 mois ≈ 88 s** sans décision (une seule notification, le plafond du Livret A). Mai → déc. 1988 : **8 mois ≈ 64 s** avant la fin. |
| D3 | **Peu de décisions, et une seule avec une vraie tension.** | ≈ 8 choix proposés par partie : 7 présentations (« Ouvrir » / « Pas maintenant », sans enjeu immédiat) + **1 seul dilemme fort, le krach**. Naissance et héritage : un bouton « Compris ». Le seul événement de marché de 1984-1988 est le krach. |
| D4 | **Les choix ne changent presque pas le résultat.** Le salaire et le scénario décident de tout. | Capture `v2_fin` : 195 342 F, dont **175 025 F d'argent mis de côté (90 %)**. Écart avec Tata Livret : **+7 617 F (3,9 %)**. Un bon et un mauvais joueur finissent à quelques pour cent l'un de l'autre : l'enjeu est invisible. |
| D5 | **L'argent ne sert à rien.** C'est un compteur, pas un moyen. Aucun projet, aucun achat, aucune envie du foyer à satisfaire. Pas d'objectif à court ou moyen terme, pas d'échec possible (A21 garantit un budget positif). | 0 objectif, 0 projet, 0 dépense choisie dans la démo. |
| D6 | **Le jeu finit par se jouer tout seul.** Les versements automatiques (demandés par le joueur, et c'est juste pédagogiquement) suppriment la dernière raison d'agir : une fois réglés (≈ mi-1986), on peut finir la partie sans toucher l'écran. | 0 action nécessaire après le dernier produit ouvert. |
| D7 | **Peu de surprises, peu de rejouabilité.** Les grands moments sont scriptés et identiques d'une partie à l'autre ; le hasard se limite à 3 événements (prime, voiture, dentiste) espacés de 24 mois et aux jumeaux (1 sur 4). | « Rejouer autrement » rejoue **la même histoire**. |
| D8 | **Un seul personnage vivant, peu de récompense sensible.** M. Lefranc parle ; Sylvie et l'enfant ne sont que des prénoms ; aucun voisin, aucune réplique drôle dans la rue ; pas de son ; une prime et une panne arrivent avec le même poids ; aucune célébration quand on réussit. | 1 personnage qui parle, 0 son, 0 récompense hors chiffres. |

**En une phrase :** le joueur est spectateur d'une belle rue qui lui fait la leçon gentiment ; il lui manque **des envies à satisfaire, des choix fréquents qui coûtent quelque chose, et des rivaux** à qui se comparer autrement que par un écart de 4 %.

Ce qui marche et qu'il faut garder : le banquier didactique, les pop-ups d'événements et leurs animations (aimés par le joueur), la comparaison permanente avec Tata Livret, la ville.

---

## 2. Garde-fous (valables pour toutes les propositions)

1. **Jamais de récompense au market timing** : aucun défi « faire +X % », aucune annonce de krach (A5), aucun « bon moment pour acheter ».
2. **Pas de jeu d'argent déguisé** : pas de pari sur un cours, pas de loterie récompensée ; le hasard vient de la vie, pas de la bourse.
3. **Pas de conseil personnalisé** : les personnages qui donnent des « tuyaux » (Jean-Mi) sont **montrés en échec** sur la durée, avec de vrais prix.
4. **Dépenser n'est pas une faute** : le jeu valorise l'équilibre (vivre et épargner), pas l'avarice.
5. **Les dilemmes du foyer ne coûtent qu'un toucher** : ils ne doivent pas faire exploser la durée (cible 15-20 min, A45).

---

## 3. Propositions (13)

Notation : **Priorité de 1 à 5** (5 = à faire en premier). Coût estimé dans Godot avec l'équipe actuelle : faible (< 1 jour), moyen (1 à 3 jours), fort (> 3 jours).

### P1. « À quoi sert l'argent ? » — les projets du foyer
- **Description** : en janvier 1984 puis après la naissance, Gérard et Sylvie choisissent **un projet parmi trois**, avec une date et un montant : « La R5 neuve pour l'été 1986 : 42 000 F », « Le tour d'Italie en combi, été 1987 : 15 000 F », « L'apport pour un T3, fin 1988 : 80 000 F ». Une jauge sur la maison ; à la date, si l'argent est là, le projet se réalise **en animation** (la R5 neuve se gare devant la maison). Sinon on reporte ou on renonce, Sylvie est déçue.
- **Plaisir** : un objectif à moyen terme, une tension (« vais-je y arriver ? »), une récompense visible.
- **Apprend** : **l'horizon de placement**. L'argent du voyage de l'été 1987 placé en SICAV en 1986 est là ; celui de l'apport placé en actions fin 1987 a fondu. Le PEL prend tout son sens pour le logement.
- **Garde-fou** : le banquier rappelle la date du projet sur les fiches (« vous en aurez besoin dans 14 mois »), il ne dit jamais où placer.
- **Coût** : moyen (données JSON, une jauge, 3 animations simples). **Priorité : 5.**

### P2. « Les dilemmes du foyer » — façon Reigns, un toucher
- **Description** : tous les 3 à 4 mois de jeu (≈ 30 s réelles à ×1, 15 à 18 cartes par démo), une **petite carte** sort de la maison avec deux choix et leurs coûts : « Sylvie veut un magnétoscope VHS : 6 990 F » [Acheter / Attendre] ; « Vacances : camping à Palavas 3 000 F ou Club Med 12 000 F » ; « Le beau-frère et ses escargots : il promet 30 % par an » (événement de la V1, `jeu/data/evenements_vie.js`). Chaque choix change l'argent et une **seconde jauge : le moral du foyer** (0 à 100), visible sur la maison.
- **Plaisir** : des décisions fréquentes, rapides, drôles, avec un vrai prix ; la vie du foyer existe enfin.
- **Apprend** : l'arbitrage **consommation / épargne** et le coût d'opportunité (« ce magnétoscope, placé au Livret A, vaudrait environ 8 000 F en 1988 », affiché **après** le choix, sans jugement) ; les promesses trop belles (escargots).
- **Garde-fou** : un moral trop bas coûte aussi (week-end « pour se changer les idées » plus cher, projet raté) : le jeu récompense l'équilibre, pas l'avarice.
- **Coût** : moyen (carte rapide, 1 jauge, 20 à 30 dilemmes en données, à écrire avec le banquier pour les prix d'époque). **Priorité : 5.**
- **[revient sur 13 §5.3]** : ces cartes s'ajoutent au budget de 15 interruptions. Je propose une nouvelle catégorie « micro-décision » : pause le temps du toucher (≈ 4 s), pas d'animation de bâtiment, jamais deux mois de suite ni le même mois qu'une autre interruption.

### P3. « Le quartier fait ses comptes » — des rivaux en chair et en os
- **Description** : les témoins deviennent **des voisins de la rue**, avec le même salaire que Gérard : Tata Livret (déjà calculée), Tonton Matelas (tout en liquide) et un nouveau, **Jean-Mi le flambeur**, qui suit les tuyaux du café et achète des Peugeot à crédit (règlement mensuel). Un **classement de la rue** (4 lignes) remplace la pastille seule. Une fois par trimestre, un voisin passe dans la rue avec une bulle. Exemple : au printemps 1987, Jean-Mi gare une Porsche 944 et passe devant Gérard au classement ; en novembre 1987, la Porsche porte un panneau « À VENDRE ».
- **Plaisir** : rivalité, humour, un arc dramatique, la joie de doubler Jean-Mi à la fin.
- **Apprend** : l'inflation (Matelas recule en baguettes), **l'effet de levier et la concentration** (Jean-Mi), la régularité (Tata).
- **Garde-fou** : la trajectoire de Jean-Mi est **scriptée sur les vrais prix** (validation du boursier et du banquier pour le règlement mensuel, certitude B) ; il finit derrière tout joueur diversifié, jamais présenté en modèle.
- **Coût** : moyen (le moteur des témoins et `temoins.json` existent ; personnages et bulles à dessiner). **Priorité : 5.**
- **[revient sur 12 §4]** : Tonton Matelas et Cousin Indice étaient hors démo.

### P4. « Le mois utile » — chaque mois se voit, et on peut sauter l'attente
- **Description** : (a) chaque mois, l'argent **travaille sous les yeux** : les intérêts volent de la banque vers la maison en pièces (« +312 F »), les dividendes font « ding » en juin, les frais tombent en cuivre ; (b) un bouton **« Jusqu'au prochain courrier »** fait défiler à ×6 et s'arrête **à** la prochaine interruption ou carte (jamais avant : rien n'est annoncé).
- **Plaisir** : feedback permanent, le joueur reprend la main sur le rythme sans que le temps « défile trop vite » quand il lit.
- **Apprend** : les intérêts composés deviennent visibles (les pièces grossissent avec les années).
- **Garde-fou** : le bouton ne s'arrête jamais le mois *avant* un événement de marché (A5).
- **Coût** : faible. **Priorité : 4.**

### P5. « Le score de la rue » — une fin qui donne envie de rejouer
- **Description** : l'écran de fin note **5 axes** en étoiles : patrimoine face à Tata Livret, moral du foyer, projets réalisés, frais, sang-froid (krach). Il décerne un **titre** d'époque : « Écureuil de la Caisse d'épargne », « Cigale du Club Med », « Golden boy repenti », « Fourmi blindée mais seule ». Il garde le **record personnel** et propose « Rejouer pour battre Jean-Mi ».
- **Plaisir** : un verdict, une identité de joueur, une raison de recommencer.
- **Apprend** : il n'y a pas qu'une façon de « bien faire » ; l'équilibre gagne.
- **Garde-fou** : aucune étoile pour la performance brute d'un titre ou le timing.
- **Coût** : faible. **Priorité : 4.** **[revient sur 12 §3.5]** : « pas d'étoiles ni de titre dans la démo ».

### P6. « Lundi noir, en direct » — le krach comme un vrai moment de cinéma
- **Description** : 15 secondes de séquence avant la décision : l'écran de la Gazette chute jour après jour (19 → 23 octobre), une file se forme devant la banque, le téléphone sonne à la maison (Sylvie : « Gérard, à la radio ils parlent de 1929 ! »), Jean-Mi court. Puis les trois choix habituels. **Douze mois plus tard (oct. 1988)**, « Le krach, un an après » : ce que chacun des trois choix aurait donné avec l'argent du joueur.
- **Plaisir** : le climax de la démo, de l'émotion ; et la fin de 1988 n'est plus un tunnel vide (D2).
- **Apprend** : le sang-froid, mesuré sur sa propre partie.
- **Garde-fou** : pas de compte à rebours qui pousse à décider vite.
- **Coût** : moyen. **Priorité : 4.** (« Rappel à 12 mois » était hors démo, 12 §4.)

### P7. « La ruée des privatisations » — remplir le tunnel de 1987
- **Description** : après Saint-Gobain, deux autres offres historiques : **Paribas (janv. 1987)** et **Suez (offerte début octobre 1987, quelques jours avant le krach ; dates à vérifier par le boursier)**. Une file devant la banque, et une **réduction** : « Vous avez demandé 40 actions, vous en recevez 8 ». Suez montre le revers : souscrite dans l'euphorie, elle cote sous son prix d'offre après le lundi noir.
- **Plaisir** : surprise, ambiance d'époque, des événements dans la période vide (D2).
- **Apprend** : le marché primaire, la réduction des demandes, prix d'offre et cours qui s'en écartent.
- **Garde-fou** : dates, prix et réductions **vérifiés par le boursier** (niveau de certitude) ; Suez montre qu'une privatisation n'est pas un gain garanti.
- **Coût** : moyen (le mécanisme d'offre de Saint-Gobain existe). **Priorité : 3.** **[revient sur 12 §3.3]** : « 9 lignes, pas plus ».

### P8. « Les défis de l'année » — objectifs courts et collection
- **Description** : chaque janvier, la Gazette publie 3 défis d'épargnant, au choix du joueur d'en suivre ou non : « Avoir 3 mois de dépenses de côté avant la naissance », « Moins de 300 F de frais en 1986 », « Traverser le krach sans vendre », « Détenir 4 familles de produits ». Chaque défi réussi accroche **un diplôme** dans la fenêtre de la maison.
- **Plaisir** : des objectifs à 12 mois, une collection visible.
- **Apprend** : uniquement de bons réflexes (précaution, frais, diversification, sang-froid).
- **Garde-fou** : défis génériques, jamais de performance ; portés par la Gazette, pas par le banquier (pas d'air de conseil).
- **Coût** : faible à moyen. **Priorité : 3.**

### P9. « La rue a de l'humour » — personnages et répliques
- **Description** : des bulles non bloquantes dans la rue, qui réagissent à la partie : la concierge Mme Lopez (« Encore la Peugeot qui monte, hein, monsieur Gérard ? »), Sylvie à la fenêtre, M. Lefranc qui fume devant la banque, les jumeaux qui grandissent (poussette en 1985, tricycle en 1988). Le kiosque affiche les titres d'époque (Platini champion d'Europe 1984, 3615, Top 50, Tchernobyl 1986).
- **Plaisir** : la ville vit, on sourit, on reconnaît l'époque.
- **Apprend** : le contexte historique.
- **Garde-fou** : aucune bulle ne donne de tuyau (seul Jean-Mi le fait, et il échoue).
- **Coût** : faible à moyen (données + bulles). **Priorité : 3.**

### P10. « La maison qui grandit » — la progression se voit
- **Description** : les projets et dilemmes laissent des traces : antenne, R5 devant la porte, vélo d'enfant, Minitel à la fenêtre, véranda ; la maison passe par 3 ou 4 états. Le krach ne fait rien disparaître : seul le papier baisse.
- **Plaisir** : progression et collection visibles d'un coup d'œil.
- **Apprend** : la différence entre patrimoine financier et vie réelle.
- **Coût** : moyen (dessin vectoriel). **Priorité : 3** (vient avec P1 et P2).

### P11. « Et si Gérard avait tenu jusqu'à aujourd'hui ? » — l'épilogue
- **Description** : après le score, une page : le portefeuille de fin 1988 **conservé jusqu'en 2025**, en euros d'aujourd'hui, ligne par ligne (Livret A, L'Oréal, Peugeot, SICAV), à côté de Tata Livret et Tonton Matelas.
- **Plaisir** : un « waouh » final, et l'envie de rejouer avec d'autres choix.
- **Apprend** : le temps long, les intérêts composés, l'inflation.
- **Garde-fou** : données **passées**, certifiées par le boursier (A/B/C), montrées aussi pour les lignes décevantes (pas de sélection flatteuse) ; jamais une prévision.
- **Coût** : faible à moyen (surtout des données). **Priorité : 3.**

### P12. « Une autre vie » — rejouabilité par les destins
- **Description** : 3 personnages dans la même rue en 1984-1988 : Gérard (technicien, en couple), Martine (institutrice, 38 ans, divorcée, un ado, emploi sûr), Paulo (boulanger, 47 ans, revenus irréguliers, retraite à préparer). Chacun a ses projets, ses dilemmes et un ordre de présentation du banquier différent. Le tirage puise aussi dans les 8 événements de la V1 (augmentation, chômage, déménagement…).
- **Plaisir** : rejouer une autre histoire, pas la même.
- **Apprend** : **le bon placement dépend de la situation** : c'est exactement le « adapté au profil » demandé par le joueur.
- **Coût** : fort (textes, équilibrage, banquier). **Priorité : 2** (après le top 5).

### P13. « La criée du Palais Brongniart » — un mini-jeu d'époque
- **Description** : une fois, en 1986 (dernières années de la criée), Gérard visite la Bourse : 30 secondes pour faire passer un ordre dans le brouhaha de la corbeille. On découvre l'ordre « au mieux » et l'ordre « à cours limité » en voyant le prix bouger.
- **Plaisir** : changement de rythme, spectacle.
- **Apprend** : les types d'ordre.
- **Garde-fou** : on gagne en respectant sa limite, pas en achetant « au bon moment ».
- **Coût** : fort. **Priorité : 1** (idée à garder pour plus tard).

### Tableau récapitulatif

| # | Nom | Levier principal | Coût | Priorité |
|---|---|---|---|---|
| P1 | Les projets du foyer | Objectifs, tension | moyen | 5 |
| P2 | Les dilemmes du foyer | Décisions fréquentes | moyen | 5 |
| P3 | Le quartier fait ses comptes | Rivaux, humour, comparaison | moyen | 5 |
| P4 | Le mois utile | Rythme, feedback | faible | 4 |
| P5 | Le score de la rue | Score, rejouabilité | faible | 4 |
| P6 | Lundi noir, en direct | Moment fort | moyen | 4 |
| P7 | La ruée des privatisations | Surprise, époque | moyen | 3 |
| P8 | Les défis de l'année | Objectifs courts, collection | faible-moyen | 3 |
| P9 | La rue a de l'humour | Personnages | faible-moyen | 3 |
| P10 | La maison qui grandit | Progression visible | moyen | 3 |
| P11 | L'épilogue jusqu'en 2025 | Moment fort final | faible-moyen | 3 |
| P12 | Une autre vie | Rejouabilité | fort | 2 |
| P13 | La criée | Mini-jeu | fort | 1 |

---

## 4. Top 5 recommandé pour la prochaine itération

1. **P2 Les dilemmes du foyer** (+ jauge de moral) : le remède direct au « on regarde sans jouer ».
2. **P1 Les projets du foyer** : l'argent sert enfin à quelque chose, et l'horizon de placement s'apprend tout seul.
3. **P3 Le quartier fait ses comptes** (Jean-Mi, Tonton Matelas) : rivalité, humour, et un arc 1986-1987 qui remplit le tunnel avant le krach.
4. **P4 Le mois utile** : peu coûteux, effet immédiat sur la sensation de vide.
5. **P5 Le score de la rue** : donne un verdict aux quatre premières et une raison de rejouer.

Ensemble, ils forment une boucle complète : **court terme** (dilemmes, un toucher), **moyen terme** (projets, rivaux), **long terme** (score, titre, record).

**Effet attendu sur la démo** (estimation à vérifier en jeu) :

| Mesure | Aujourd'hui | Avec le top 5 |
|---|---|---|
| Décisions par partie | ≈ 8, dont 1 forte | ≈ 26 (15 à 18 dilemmes, 2 projets, 7 présentations, krach) |
| Plus long tunnel sans choix | 11 mois (88 s) | ≤ 4 mois (≈ 30 s) |
| Ce qui distingue deux joueurs à la fin | 4 % de patrimoine | 5 axes, titre, projets réalisés ou non, rang face à Jean-Mi |
| Durée | 15-20 min | 16-21 min (≈ 16 cartes × 4 s ≈ 1 min de plus ; le bouton « Jusqu'au prochain courrier » rend du temps à qui veut) |

Juste après, si le joueur valide : **P6 Lundi noir en direct** (moment fort) et **P11 l'épilogue** (coût faible, effet « waouh »).

---

## 5. Questions pour le joueur (une réponse courte suffit)

1. Une **seconde jauge « moral du foyer »** à côté de l'argent : oui ou non ? (C'est le pivot de P1, P2 et P5.)
2. Des **voisins rivaux** dont un flambeur qui finit mal : ça vous amuse, ou vous préférez rester sur Tata Livret seule ?
3. Des **petites cartes à un toucher** environ toutes les 30 secondes de jeu réel (tous les 3 à 4 mois du calendrier) : trop, pas assez, ou bien ?
4. Parmi les 13 propositions, lesquelles vous donnent le plus envie ? Lesquelles rejetez-vous ?

---

## 6. Avis du client (2026-10-28)

> Avis pour éclairer le joueur réel, qui a le dernier mot. Rien n'est validé avant sa réponse.
> Le diagnostic est juste, surtout D4 (on finit à 4 % de Tata Livret quoi qu'on fasse), D5 (l'argent ne sert à rien) et D6 (le jeu se joue seul). Le remède doit rester **simple** : un ou deux systèmes nouveaux bien faits valent mieux que cinq à moitié.

### 6.1 Les 13 propositions, une ligne chacune

| # | Avis | Pourquoi (1 = s'amuser, 2 = apprendre, retours du joueur) |
|---|---|---|
| P1 | **Pour** | 1 : une envie à satisfaire et une tension. 2 : l'horizon de placement, la leçon qui manque le plus aujourd'hui. Réserve : un seul projet en cours à la fois, deux par démo au plus. |
| P2 | **Pour, avec réserve** | Remède direct au « on regarde ». Réserves : 8 à 10 cartes par démo (pas 15 à 18), placées d'abord dans les tunnels ; « moral » en 3 humeurs visibles (visage de Sylvie), pas une jauge de 0 à 100. |
| P3 | **Pour, avec réserve** | Prolonge la demande du joueur (« se comparer à tout au Livret A ») et remplit 1986-1987. Réserves : 4 lignes au plus (Gérard, Tata Livret, Tonton Matelas, Jean-Mi) ; Tata Livret reste le comparateur affiché en permanence. |
| P4 | **Pour** | Coût faible, effet immédiat. Les pièces rendent visibles les intérêts composés et les frais (leçon demandée le 27/10). À faire en premier. |
| P5 | **Pour, en version allégée** | Un verdict donne envie de rejouer. Mais 5 axes en étoiles, c'est un tableau de plus : dans la démo, **le rang dans la rue + un titre** suffisent ; les étoiles attendent le jeu complet. |
| P6 | **Pour** | Le krach est le climax et la meilleure leçon (sang-froid) ; « un an après » remplit le tunnel de 1988 avec l'argent du joueur. |
| P7 | **Pour, avec réserve, après le top 5** | Bonne leçon (Suez sous son prix d'offre), bon remplissage du tunnel. Suez d'abord, Paribas en option ; dates et prix certifiés par le boursier. |
| P8 | **Contre (pour l'instant)** | Fait doublon avec P1 et P5 : trois systèmes d'objectifs, c'est trop. « Traverser le krach sans vendre » sonne comme une consigne, presque un conseil. |
| P9 | **Pour, en accompagnement** | Peu coûteux, fait sourire, ancre l'époque. Bulles rares, non bloquantes, jamais à lire pour pouvoir jouer. À livrer avec P3 (mêmes voisins). |
| P10 | **Pour, réduit** | Seulement comme conséquence visible de P1 et P2 (la R5 devant la porte, le magnétoscope à la fenêtre) ; pas de chantier « 4 états de maison » à part. |
| P11 | **Pour, juste après le top 5** | Gros « waouh » pour peu de code, leçon du temps long. Risque de « si vous aviez acheté L'Oréal » : toutes les lignes, y compris les décevantes. |
| P12 | **Pour, plus tard** | C'est le vrai « adapté au profil » ; mais le coût est fort et il faut d'abord prouver que la boucle de Gérard amuse. Jeu complet. |
| P13 | **Contre (pour la démo)** | Coût fort pour une leçon secondaire (types d'ordre) ; casse le ton « investisseur particulier ». Idée à garder pour le jeu complet. |

### 6.2 Décisions passées à rouvrir

| Décision | Je rouvre ? | Conditions |
|---|---|---|
| Budget de 15 interruptions (12 §3.4, A45) | **Oui** | Nouvelle catégorie « micro-décision » : ≤ 4 s, sans animation de bâtiment, jamais le même mois qu'une autre interruption ni deux mois de suite. Durée mesurée sur une vraie partie : **20 min au plus** à ×1, sinon on retire des cartes. |
| Témoins hors démo (12 §4) | **Oui, en partie** | Tonton Matelas et Jean-Mi entrent, comme voisins. Cousin Indice reste dehors : pas de fonds indiciel pour un particulier en 1984, et 4 lignes suffisent. |
| Pas d'étoiles ni de titre (12 §3.5) | **Oui, pour le titre** | Un titre d'époque + le rang dans la rue + le record personnel. Pas d'étoiles dans la démo. Aucun titre ne flatte la spéculation (« Golden boy repenti » oui, « Roi de la corbeille » non). |
| Limite de 9 produits (12 §3.3) | **Oui, de 1 ou 2 lignes** | Seulement des **offres de privatisation** (même famille que Saint-Gobain, même mécanisme), pas de nouvelle famille ; chiffres avec niveau de certitude. |

### 6.3 Garde-fous pédagogiques imposés

1. **Jean-Mi ne doit jamais faire envie à la fin.** Sa montée est courte (une bulle, la Porsche), sa chute est longue et chiffrée. Il finit **derrière Tata Livret**, pas seulement derrière le joueur diversifié. Le joueur ne peut pas acheter à crédit dans la démo, et Jean-Mi ne lui propose jamais un titre à acheter : ses tuyaux sont du décor, pas des boutons.
2. **L'effet de levier s'explique une fois, avec des chiffres** : « avec 10 000 F, il en a joué 50 000 ; quand la Bourse perd 20 %, il perd tout ». Une phrase, pas un cours ; le « règlement mensuel » n'est nommé que si le boursier le juge utile.
3. **« Jusqu'au prochain courrier »** s'arrête **au** mois de l'interruption ou de la carte, jamais avant, sans aucun signe sur la frise (A5). Il s'arrête à chaque présentation du banquier : la découverte progressive (A37) reste intacte. Les notifications sans pause franchies en accéléré restent lisibles (empilées, puis dans l'historique).
4. **Le coût d'opportunité** des dilemmes s'affiche après le choix, au conditionnel, sans jugement ; jamais « vous auriez dû ». Dépenser pour un projet réussi est **récompensé** dans le verdict.
5. **Les escargots du beau-frère perdent toujours** : les promesses de 30 % par an ne paient pas, et le jeu le dit.
6. **Le banquier ne dit jamais où placer l'argent d'un projet** ; il rappelle seulement la date (« vous en aurez besoin dans 14 mois »). C'est l'expérience (projet raté après le krach) qui enseigne.
7. **Pas de mécanique d'accroche** : pas de récompense quotidienne, pas de série, pas de compte à rebours (P6). Un projet raté ou un moral bas n'est jamais une fin de partie.
8. **Prix d'époque** des dilemmes et des projets fournis par le banquier, avec niveau de certitude ; données de l'épilogue par le boursier, sans sélection flatteuse, avec « le passé ne prédit pas l'avenir ».

### 6.4 Mon top 5 (diffère sur un point)

1. **P4 Le mois utile** : le moins cher, à livrer en premier, il change la sensation dès la prochaine partie.
2. **P2 Les dilemmes du foyer** (8 à 10 cartes, humeur à 3 états).
3. **P1 Les projets du foyer** (avec les traces visibles de P10).
4. **P3 Le quartier fait ses comptes**, **avec en fin de partie le rang dans la rue et un titre** (P5 allégé), et quelques bulles de P9.
5. **P6 Lundi noir, en direct** à la place de P5 complet : le joueur aime les animations d'événements (naissance, crash), et c'est le moment qui enseigne le plus.

Ensuite, dans l'ordre : P11 (épilogue), P7 (Suez), P5 complet si le titre ne suffit pas. Plus tard : P12 (jeu complet), P8, P13.

### 6.5 Mes réponses provisoires aux questions du game designer

1. **Moral du foyer** : oui, mais **3 humeurs visibles** (Sylvie contente, neutre, fâchée), pas un nombre ; une seule conséquence en argent.
2. **Voisins rivaux** : oui, Jean-Mi et Tonton Matelas ; Tata Livret reste la référence affichée en permanence.
3. **Fréquence des cartes** : un peu moins que proposé, **une tous les 5 à 6 mois** (8 à 10 par démo), placées dans les tunnels ; avec les interruptions actuelles, cela fait une décision tous les 3 mois environ. À ajuster après une partie.
4. **Envies** : P4, P2, P1, P3, P6. **Rejets pour la démo** : P8 et P13.
