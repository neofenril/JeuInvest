# Base de connaissances du game designer

> À lire au début de chaque mission (après `CLAUDE.md` et `docs/10_retours_joueur.md`), à mettre à jour à la fin. Concise.
> Dernière mise à jour : 2026-10-28 (première mission).

## 1. Faits vérifiés sur le jeu (démo V2, 2026-10-28)

- Rythme : `godot/data/rythme.json`, ×1 = 8 s/mois, ×2 = 4 s, ×3 = 2 s. Le joueur a trouvé 4 s/mois « trop rapide » (26/10) : **ne pas proposer d'accélérer le défilement par défaut** ; donner plutôt le contrôle (saut jusqu'au prochain événement).
- 60 mois (janv. 1984 → déc. 1988) = 8 min de défilement à ×1 ; 11 à 13 interruptions (moyenne 11,3 sur 40 graines, base du développeur).
- Tunnels vides : 11/1986 → 10/1987 (11 mois) et 05/1988 → 12/1988 (8 mois).
- Un seul événement de marché en 1984-1988 (krach 10/1987) ; dans la V1 (`jeu/data/periode_p1.js`), rien d'autre dans cette fenêtre (Saint-Gobain est déjà D07).
- Événements de vie aléatoires de la démo : 3 types (prime, voiture, dentiste), écart de 24 mois. La V1 en a 8 de plus, dont **« Le beau-frère et ses escargots »** (vrai dilemme, issue 6 à 12 mois plus tard), augmentation, chômage, déménagement, gain au jeu.
- Choix réels : 7 présentations (Ouvrir / Pas maintenant), krach (3 choix), courriers (payer, parfois vendre). Naissance et héritage : « Compris ».
- Capture `v2_fin` : 195 342 F, dont 175 025 F d'épargne mise de côté (90 %) ; écart avec Tata Livret +7 617 F (3,9 %). **Les choix pèsent peu sur le résultat.**
- Les versements automatiques rendent le jeu jouable sans aucune action après mi-1986.
- Témoins déjà en données : `godot/data/temoins.json` (Matelas, Livret, Indice, avec répliques). Tata Livret calculée en permanence.

## 2. Diagnostic de l'ennui (doc 14 §1)

Spectateur plutôt que joueur ; tunnels vides ; ≈ 8 décisions dont 1 forte ; résultat à ±4 % ; l'argent ne sert à rien (aucun projet, aucune dépense choisie, pas d'échec) ; le jeu se joue seul ; peu de hasard et de rejouabilité ; un seul personnage vivant, pas de son, pas de célébration.

## 3. Propositions faites (doc 14, 2026-10-28)

13 propositions P1 à P13. Top 5 : **P2 dilemmes du foyer + jauge de moral**, **P1 projets du foyer**, **P3 voisins rivaux (Jean-Mi le flambeur, Tonton Matelas)**, **P4 le mois utile (pièces d'intérêts, bouton « Jusqu'au prochain courrier »)**, **P5 score de la rue (5 axes, titre, record)**. Ensuite : P6 krach en direct + « un an après », P11 épilogue jusqu'en 2025.
Décisions sur lesquelles je propose de revenir : budget de 15 interruptions (13 §5.3) → catégorie « micro-décision » ; témoins hors démo (12 §4) ; pas d'étoiles ni de titre (12 §3.5) ; 9 lignes de produits (12 §3.3, pour P7).

## 4. Décisions du joueur et du client

- (en attente) Réponses aux 4 questions de 14 §5 : jauge de moral, voisins rivaux, fréquence des cartes, propositions préférées et rejetées.

## 5. Principes retenus pour ce projet

- Le joueur aime : les pop-ups d'événements, leurs animations (crash, cigogne), le banquier didactique, la comparaison avec le Livret A. Construire dessus.
- Garde-fous : jamais de récompense au market timing ni d'annonce de krach (A5) ; pas de pari ; pas de conseil personnalisé (les « tuyaux » viennent de Jean-Mi, montré en échec sur de vrais prix) ; dépenser n'est pas une faute.
- Toute nouvelle interruption se compte face à la cible 15-20 min (A45).
- Les faits historiques proposés (privatisations Paribas, Suez, règlement mensuel) sont à faire vérifier par le boursier ou le banquier avant d'être écrits en données.

## 6. Erreurs à ne pas refaire

- (rien encore)
