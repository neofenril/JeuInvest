# Base de connaissances du game designer

> À lire au début de chaque mission (après `CLAUDE.md` et `docs/10_retours_joueur.md`), à mettre à jour à la fin. Concise.
> Dernière mise à jour : 2026-10-29 (spécification V3, docs/15).

## 1. Faits vérifiés sur le jeu (démo V2, 2026-10-28)

- Rythme : `godot/data/rythme.json`, ×1 = 8 s/mois, ×2 = 4 s, ×3 = 2 s. Le joueur a trouvé 4 s/mois « trop rapide » (26/10) : **ne pas accélérer le défilement par défaut** ; donner le contrôle (bouton de saut).
- 60 mois = 8 min de défilement à ×1 ; 11 à 13 interruptions (moyenne 11,3 sur 40 graines). Durée totale actuelle estimée 19-20 min.
- Tunnels vides actuels : 11/1986 → 10/1987 et 05 → 12/1988.
- Gérard : 6 790 F/mois en 1984, 8 490 F en 1988 ; épargne possible 24 % (≈ 1 630 F/mois), 15 % avec un enfant (≈ 1 150 F), 6 % avec jumeaux (≈ 480 F). Départ : 11 000 F sur le compte courant.
- Peugeot dans le jeu : ancrages annuels seulement (300 F fin 1985, 600 fin 1986, 450 fin 1987, 800 fin 1988) ; indice : ancrages mensuels 1987 (1 500 en 03, 1 033 en 10, 963 en 11).
- Présentations dynamiques (déclencheurs + dates limites 12 §2.2) : D02 ≤ 07/1984, D03 ≤ 02/1985, D04 ≤ 07/1985, D05 ≤ 02/1986, D06 ≤ 08/1986 ; dates fixes : naissance 04/1985, Saint-Gobain 11/1986, krach 10/1987 + panne forcée 11/1987, héritage 04/1988.
- V1 (`jeu/data/evenements_vie.js`) : escargots avec 10 % de gain (à ne pas reprendre : ils perdent toujours) ; `jeu/data/titres.js` : titres humoristiques réutilisables.

## 2. Diagnostic de l'ennui (doc 14 §1)

Spectateur ; tunnels vides ; ≈ 8 décisions dont 1 forte ; résultat à ±4 % ; l'argent ne sert à rien ; le jeu se joue seul ; peu de rejouabilité ; un seul personnage vivant.

## 3. Propositions et spécification

- Doc 14 (28/10) : P1 à P13.
- **Doc 15 (29/10) : spécification de P1, P2, P3, P4, P5 allégée, P6, P9, P10 réduite.** Points clés :
  - **R-MIROIR** : les 3 voisins ont le même salaire, la même vie et les mêmes dépenses (cartes de consommation, projets) ; seules les cartes de placement (escargots) ne sont pas recopiées. Le classement ne mesure que le placement ; dépenser n'est jamais puni.
  - **R-CADENCE** : jamais deux interruptions le même mois ni deux mois de suite (sauf krach → panne) ; priorités marché > historique > échéance de projet > vie > présentation > choix de projet > carte ; pas de carte le mois avant une interruption datée (invisible, A5 respecté).
  - Humeur de Sylvie : valeur cachée −3..+3, 3 visages, érosion chaque janvier, seule conséquence en argent = carte C00 « Sylvie fait la tête » (week-end à Deauville).
  - 10 créneaux de cartes (S1-S10, fenêtre + mois préféré + 1-2 candidates), 16 cartes C00-C15 ; 8 à 10 jouées.
  - Projets : P1 (choix 03/1984, échéance 04/1986 : 12 / 20 / 30 kF), P2 (choix 01/1987 : Club Med 07/1987 14 kF, break 02/1988 40 kF, apport T3 12/1988 90 kF) ; report unique de 4 mois ; vente automatique ordonnée au jour J.
  - Jean-Mi : vendeur Peugeot, règlement mensuel 09/1986, Porsche 04/1987, liquidation 10/1987, dette ; contraintes J1 (devant Tata 03-09/1987) et J2 (derrière Tata ≥ 10 % fin 1988, visé dernier).
  - 16 passages de voisins (5 clés historisés), kiosque d'époque, bulles ≤ 1 tous les 2 mois.
  - 9 titres de fin (ordre d'évaluation ; « Ne rien faire » et « Renforcer » comptent ensemble).
  - Durée estimée : ≈ 22 min à ×1 pur, ≈ 19 min avec le bouton de temps en temps ; ordre de retrait des créneaux S1, S3, S5, S9.

## 4. Décisions du joueur et du client

- (29/10) Joueur : on fait P1, P2, P3, P4, P5, P6, P9, P10 ; plus tard P7, P11, P12, P13 ; **P8 abandonnée**. Réserves du client appliquées par défaut (humeur en 3 états, 8-10 cartes dans les tunnels, Jean-Mi derrière Tata, P5 = rang + titre sans étoiles, P10 réduite), à confirmer par le joueur sur la démo.
- Client (14 §6) : un seul projet à la fois, 2 par démo ; Tata reste le comparateur permanent ; Cousin Indice hors démo ; pas d'étoiles ; budget 20 min max mesuré, sinon retirer des cartes.
- En attente (doc 15 §12) : durée sans bouton (garder ou retirer 2 cartes), classement permanent ou non, collection de titres sur l'écran titre. À confirmer par le client : R-MIROIR, apport du T3 fin 1988 sans crédit, barre « Renforcé » dans « un an après ».

## 5. Principes retenus pour ce projet

- Le joueur aime : pop-ups d'événements, animations (crash, cigogne), banquier didactique, comparaison avec le Livret A. Construire dessus.
- Garde-fous : jamais de récompense au market timing ni d'annonce de krach (A5) ; pas de pari ; pas de conseil (seul Jean-Mi donne des tuyaux, et il échoue) ; dépenser n'est pas une faute ; coût d'opportunité au conditionnel, au taux du mois courant (jamais un taux futur) ; pas de compte à rebours ni de mécanique d'accroche.
- Toute nouvelle interruption se compte face à la cible de 20 min ; un bouton de saut qui s'arrête **au** mois de l'événement, sans calcul à l'avance.
- Prix d'époque, données de marché et dates historiques : toujours à faire valider (banquier, boursier) avec certitude A/B/C ; le code se fait sur des valeurs provisoires remplaçables en données.

## 6. Erreurs à ne pas refaire

- Ne pas oublier que la démo vouvoie le joueur (textes de cartes écrits d'abord au tutoiement, corrigé).
- Un projet coûteux réalisé en fin de démo fait chuter le patrimoine affiché : l'apport immobilier reste un actif (ligne « Apport du T3 »), pas une dépense.
