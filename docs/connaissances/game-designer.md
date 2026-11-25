# Base de connaissances du game designer

> À lire au début de chaque mission (après `CLAUDE.md` et `docs/10_retours_joueur.md`), à mettre à jour à la fin. Concise.
> Dernière mise à jour : 2026-11-18 (docs/47, révision du lot 10).

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

- **Doc 23 (12/11)** : répliques de Sylvie, usure de l'humeur positive seulement (validée), coup dur garde sa pause. **Doc 27 (13/11)** : textes des projets et de la rue, Jean-Mi visible (★ persistantes, étape), fiche de retour 0.5.
- **Doc 28 (13/11, G6)** : titres de fin. Ordre corrigé (neveu 7 avant écureuil 8, sinon le titre 8 est inatteignable) ; seuils cartes = ≥ 5 et écart ≥ 3 (et non 6 / 7) ; nature par choix (C06, C07 neutres ; C14a épargne, C14b neutre ; C00b, C10b SPA épargne) ; abandon « évitable » seulement ; part risquée = 0 si instantané exemple ; étoiles retirées (étoile Cousin Indice contraire à CA-3.1) ; collection « ??? » sans indice ; SV : `toujours` = marche, D08, projet, C06 (pas la gazette), espacement de 6 mois compté depuis toute proposition.

- **Doc 35 (18/11)** : gabarit de chapitre, 13 archétypes de cartes, R-SEUL, profils Martine / Bernard (1984), chapitre 2019-2023 (devenu secondaire : le joueur a choisi 1989-1993 en 2e).
- **Doc 39 (18/11, G6)** : chapitre 1989-1993 en continuité. Passage de chapitre en 01/1989 (1 carte : titre 1984-88 + ce qui change, CONTINUER, pas de bilan d'étape) ; Gérard marié en 06/1990 (choix de la fête), promotion 03/1990 si C07 pris (retour à 5 ans) ; vitrine Golfe 09/1990 (baisse lente, « un an après » à 2 cas selon le cours réel), SME 09/1992 en secondaire ; Jean-Mi saison 2 = studio à crédit à taux révisable (moteur de la Porsche réutilisé, `bien`, `loyer`, `taux_revise`), même dosage ; profils 1989 Sophie (célibataire, Karine), Christine, Michel (52 ans, préretraite) ; arnaque = diamants ; R-DÉPART (départ à égalité avec Tata, présentations en file, options de projet à ≥ 12 mois, hors record) ; 6 étoiles par chapitre (« — » si non concernée) ; R-FIN (jamais avant 70 ans, table de mortalité, scène du crépuscule, note au conditionnel avec hypothèse barrée ; Gérard jamais concerné avant 2028) ; double record (chapitre de départ mesuré à sa fin / total si dernière année atteinte). G-R1 validé (escargots 20 % facultatif, alerte golden_boy ≤ 20 %) ; G-R2 : apprenti « Aucun style marqué cette fois : rejouez pour tenter une autre voie. »
- **Doc 42 (18/11)** : carrière simplifiée (idée du joueur, rien de décidé). Cartes du foyer K1-K8 (K1 = C07 ; K2 mercredi de Sylvie 4/5, K3 offre de la PME + suite K6 « la PME ferme » 1 fois sur 2 en 06/1991, K4 poste itinérant, K5 congé formation remplace la C07 de 1989, K7 plan de départs 1993, K8 préretraite de Michel), candidates dans des créneaux existants : **0 pause ajoutée**, ≤ 3 par chapitre. Ligne « épargne possible avant → après ». Temps : **pas de jauge**, statut `normal | temps | prenant` qui ne change que l'usure de janvier (temps : pas d'usure ; prenant : −1 toujours → C00). Règle des 3 axes (argent / temps-humeur / sécurité-avenir). R-MIROIR : voisins suivent les salaires. Variante minimale : K2-K5, champ `salaire` existant (+ pct négatif) et `depenses_M_mois`. Création d'entreprise reportée ≥ 1994.

- **Doc 45 (18/11)** : événements de vie aléatoires (demande du joueur : seul le marché garde ses dates). Ancrés = survenue garantie, date en fenêtre ≥ 6 mois (naissance 12/1984-06/1985, coup dur 1-3 mois après une vitrine, héritage 01-09/1988, mariage de Gérard 09/1989-06/1992 à 70 %, Raymond 01/1991-06/1992) ; 21 types en M (mois de salaire) ; pioche par tranches de 12 mois ; budget de malchance 1,5-4,5 M par chapitre, ≤ 2 gros coups, ≥ 1 bonne nouvelle / 24 mois ; R-MIROIR étendue à tous les types ; aucun héritage dans les 6 mois avant une vitrine ; séparation couplée faiblement à l'humeur **par la carrière seulement** (décision du joueur : §2 bis, 1,5 % + 0,75 pt par année « fâchée + horaires lourds actifs », plafond 3 %, étiquette `cause: "carriere"`, jamais l'épargne) ; pilote carrière K4/K5 au lot 10, retraite et PER repoussés ; calendrier de référence (`vie_reference`) pour tests et captures. Lot 10 = §6.

- **Doc 47 (18/11, prime sur docs/39 §2.1, §5, §6.1, §13, §14)** : vitrine du Golfe en 2 étapes mensuelles réelles (08/1990 sans pause + bandeau −16 % ; 09/1990 pause, courbe de 3 fins de mois « fins de mois seulement », ordres au cours de fin septembre), jamais de jours fictifs ; « un an après » 09/1991 calculé (rebond / écart à juillet). Jean-Mi saison 2 = tout dans une seule SCPI comptant (8 passages, 5 ★, J1 supprimée, J2 gardée). SCPI jouable (part 1 000 F dont 100 F de frais, loyers 6,5 → 5,8 %, revente 900 → 780 F en 1993, **vente différée de 3 mois**, exclue de la vente automatique), B2 02-04/1990, alerte 03/1993 si parts. **PEP = simple message** (tranché). Mariage par âge (< 30 : 60 %, 30-39 : 70 %, 40-49 : 40 %, ≥ 50 : 20 %, fenêtre M9-M42). Jumeaux 1/6. K4 / K5 toujours présentées. Privatisations retirées (BNP action ordinaire 10/1993). 24-26 pauses. Tabac : devanture existante, ticket fictif « Le Trèfle » 10 F, 1/mois, une seule zone (pas de « presque gagné »), retour 65 %, pré-tiré (flux `tabac`), compteur net + Livret A, hors R-CADENCE, non recopié, ni titre ni étoile.

- **G-K1 (25/11, docs/47 §6 bis)** : à + 15 % épargnés, K4 a donnait 35 / 55 % d'écart de patrimoine (≈ 2,3 / 3,7 points par point de revenu, Gérard / Christine) et l'humeur saturait. Réglage : brut + 15 % et frais −12,5 % (net + 2,5 %, deux effets `revenu`), humeur K4 a −2 ; K5 a + 9,5 % après le congé, humeur −2 ; avertissements pour a et b ; échelle de réglage ; dernier recours (code) : humeur plafonnée à +1 sous statut prenant.

## 3 bis. Faits vérifiés dans le code (13/11, lot/05-logique)
- Calendrier de vie : `etat_partie._tirer_calendrier` (15 ans tirés au départ, indépendant des choix, sauvegardé dans `CHAMPS_ETAT`) ; flux décalés pour naissances (+1000003) et foyer ; `_espacer_repetitions` (24 mois) ; panne forcée = krach + 1 mois ; héritage daté dans `banque.json` > `heritage.av.d` (D08) ; `test_cadence` vérifie les dates exactes.
- `Foyer.humeur_visible` : **0 = contente, 1 = neutre, 2 = fâchée** (piège : lot_07 D2 l'avait inversé).
- `foyer.json` : `sens` vaut `depense` même à 0 F, inutilisable pour épargne / dépense. Prix réels ≠ docs/15 (C02 5 500, C07 2 500, C09 b 600, C04 2 200 / 3 800).
- Instantané du krach : `lignes` = actions + SICAV seulement ; `exemple: true` si le joueur n'en a pas ; choix `vendre | rien | renforcer`. Héritage versé en argent à tous (`recevoir_tous`). Bilan : 5 étoiles dont « battre Cousin Indice ».
- Produits de la démo : livret, pel, emprunt, av, sicav, elf, loreal, peugeot, saintgobain.
- (18/11) Données par chapitre : `godot/data/chapitres/1984/` (foyer.json, evenements_vie.json : voiture, medical, prime, naissance ; aucun chômage implémenté). Carte : champ `salaire: { pct, des }` (C07), recopié chez les témoins. Le salaire de Sylvie n'est pas modélisé à part.

## 4. Décisions du joueur et du client

- (29/10) Joueur : on fait P1, P2, P3, P4, P5, P6, P9, P10 ; plus tard P7, P11, P12, P13 ; **P8 abandonnée**. Réserves du client appliquées par défaut (humeur en 3 états, 8-10 cartes dans les tunnels, Jean-Mi derrière Tata, P5 = rang + titre sans étoiles, P10 réduite), à confirmer par le joueur sur la démo.
- Client (14 §6) : un seul projet à la fois, 2 par démo ; Tata reste le comparateur permanent ; Cousin Indice hors démo ; pas d'étoiles ; budget 20 min max mesuré, sinon retirer des cartes.
- En attente (doc 15 §12) : durée sans bouton (garder ou retirer 2 cartes), classement permanent ou non, collection de titres sur l'écran titre. À confirmer par le client : R-MIROIR, apport du T3 fin 1988 sans crédit, barre « Renforcé » dans « un an après ».

- (18/11) Joueur, extension des années (`docs/lots/decisions_extension_annees.md`, prime sur docs/35) : chapitres de 5 ans de proche en proche, 2e = 1989-1993 ; partie continue 1984 → 1993, marché continu, **un seul bilan final** ; un titre par chapitre traversé ; double record ; Gérard vieillit ; profils par 5 ans dont célibataire ; départ à une année précise ; fin = mort (âge, sobre, note assurance-vie / conjoint / enfants) ou dernière année ; **étoiles** de bonnes pratiques (revient sur le « pas d'étoiles » du client, voulu par le joueur) ; Jean-Mi : dosage inchangé ; tabac et casino suspendus (question juridique) ; décor 1984-1993 unique ; 1977-1983 = un chapitre de 7 ans.

- (18/11, suite) Joueur : pas de studio ni de crédit pour Jean-Mi tant que le joueur ne peut pas en faire autant (**un rival n'utilise que des produits accessibles au joueur**) ; pas de leçon sur les privatisations (rester simple) ; SCPI / diversification oui ; mariage 70 % ; jumeaux 1/6 ; Christine seul profil du lot 10 ; carte de passage version A ; divorce et décès d'un parent admis ; tabac lancé (aucun argent réel), casino plus tard ; produits définis dans un catalogue du monde avec date de naissance, présentations déplaçables entre chapitres (le PEA, 07/1992, ne peut pas remonter avant).

## 5. Principes retenus pour ce projet

- Le joueur aime : pop-ups d'événements, animations (crash, cigogne), banquier didactique, comparaison avec le Livret A. Construire dessus.
- Garde-fous : jamais de récompense au market timing ni d'annonce de krach (A5) ; pas de pari ; pas de conseil (seul Jean-Mi donne des tuyaux, et il échoue) ; dépenser n'est pas une faute ; coût d'opportunité au conditionnel, au taux du mois courant (jamais un taux futur) ; pas de compte à rebours ni de mécanique d'accroche.
- Toute nouvelle interruption se compte face à la cible de 20 min ; un bouton de saut qui s'arrête **au** mois de l'événement, sans calcul à l'avance.
- Prix d'époque, données de marché et dates historiques : toujours à faire valider (banquier, boursier) avec certitude A/B/C ; le code se fait sur des valeurs provisoires remplaçables en données.

## 6. Erreurs à ne pas refaire

- Ne pas oublier que la démo vouvoie le joueur (textes de cartes écrits d'abord au tutoiement, corrigé).
- Ne pas concevoir une séquence sur des données qui n'existent pas (7 vendredis du Golfe sans clôtures journalières) : demander d'abord au boursier la granularité disponible.
- Ne pas faire vivre au rival une mécanique interdite au joueur (studio à crédit) : le joueur l'a rejetée.
- Un malus d'humeur ponctuel s'efface : l'humeur plafonne à +3 et l'usure « prenant » (codée en dur à −1, `foyer.gd` `debut_mois`) n'agit que sous 0. Un revenu entièrement épargné écrase tout dilemme de carrière (le train de vie ne suit pas : `revenu_mois` va à l'épargne).
- Recompter les mots des gabarits (un texte « un an après » faisait 35 mots).
- Un projet coûteux réalisé en fin de démo fait chuter le patrimoine affiché : l'apport immobilier reste un actif (ligne « Apport du T3 »), pas une dépense.
