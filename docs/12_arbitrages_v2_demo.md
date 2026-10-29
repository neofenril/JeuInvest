# 12 : Arbitrages du client pour la démo V2 (progression pédagogique)

> Auteur : client. Date : 2026-10-26. Source : retours verbatim du joueur réel (`10_retours_joueur.md`), qui priment.
> Complète `03_cahier_des_charges.md` ; en cas de contradiction, ce document l'emporte pour la démo V2.
> Chiffres, taux, règles fiscales et textes du banquier : `11_catalogue_banque.md` (banquier), qui fait foi.

## 1. Chaque retour devient une exigence testable

| # | Retour du joueur | Exigence | Test de recette |
|---|---|---|---|
| R1 | « Le temps défile trop rapidement » | ×1 = **8 s par mois** (×2 = 4 s, ×3 = 2 s), vitesse par défaut ×1, réglable par une seule constante. Pause automatique à chaque appel du banquier et à chaque modale. | Chronomètre : 12 mois à ×1 = 96 s (± 10 %). Le joueur confirme le rythme. |
| R2 | « Bien garder l'esprit didactique du banquier » | Le banquier (M. Lefranc) est **le fil conducteur** : chaque nouveau produit arrive par son appel (animation depuis la banque), jamais par une simple ligne dans une liste. | Aucun produit ne devient achetable sans une présentation du banquier vue au moins une fois. |
| R3 | « Avec des explications concrètes » | Chaque présentation tient en **60 mots au plus** et contient **un exemple chiffré avec l'argent du joueur** (« Avec vos 8 000 F… »). Le détail va dans « En savoir plus ». | Relecture des textes : 100 % des présentations ont un exemple en francs calculé sur la partie en cours. |
| R4 | « Adaptées au profil de l'utilisateur » | Le **moment** et le **choix** du produit présenté dépendent de la situation du joueur (épargne, famille, produits détenus), voir §2.3. | Deux parties avec des comportements différents reçoivent les présentations dans un ordre ou à des dates différents. |
| R5 | « Une plus grande liste de produits » | La démo passe à **6 familles, 9 lignes** (§3.3). La banque affiche aussi, en silhouette, les produits **existants à l'époque mais pas encore présentés** (« M. Lefranc vous en parlera »). | Au départ, 1 produit ouvert et au moins 5 silhouettes visibles ; aucun produit postérieur à la date jouée (pas de PEA). |
| R6 | « Assurance-vie, bénéfices de succession, pour des parents » | Assurance-vie (fonds en francs) présentée **après la naissance** de l'enfant, avec la **clause bénéficiaire** et une comparaison chiffrée « transmis par succession / transmis par assurance-vie ». | La présentation arrive dans les 3 mois qui suivent la naissance et affiche les deux montants transmis. |
| R7 | « Commencer par un Livret A, puis introduire les autres produits » | Ordre de §2.2 ; le Livret A est présenté **au 1er mois**, seul. | Au 1er mois, seul le Livret A est achetable. |
| R8 | « Avantages et inconvénients par rapport aux choses déjà introduites et utilisées » | Chaque présentation contient un bloc **« Par rapport à ce que vous connaissez »** qui compare au produit **détenu** le plus proche (sinon au dernier présenté), sur 4 critères fixes : rendement, risque, disponibilité de l'argent, fiscalité. | Toute présentation sauf celle du Livret A cite au moins un produit déjà présenté, en priorité un produit détenu. |
| R9 | « Un clic en dehors de la pop-up la ferme » | Les **fenêtres de bâtiment** (banque, maison, média) se ferment au clic ou au toucher à l'extérieur, comme la croix. Les **modales à choix** (krach, courrier à décision) **ne se ferment pas** ainsi : on ne décide pas par accident. | Clic extérieur : la fenêtre de bâtiment se ferme ; la modale de krach reste ouverte. |
| R10 | « Voitures plus rapides en accéléré » (redit le 27/10 : « encore ») | La vitesse des voitures et des passants est **au moins proportionnelle** à la vitesse du temps ; en pause, la ville reste animée au rythme ×1. Voir §7.3. | À ×3, une voiture traverse l'écran **au moins 4 fois** plus vite qu'à ×1. |

R1, R9 et R10 sont déjà en cours chez le développeur ; les valeurs ci-dessus sont la cible de recette.

## 2. Le cœur de la boucle : la progression pédagogique

### 2.1 Le principe en une phrase
**Le banquier choisit quoi présenter et quand ; le joueur choisit quoi en faire.** Adapter, c'est choisir le moment et chiffrer avec l'argent du joueur. Décider à sa place, jamais.

### 2.2 Ordre d'introduction (démo 1984-1988)

| Étape | Produit | Déclencheur (le premier atteint) | Date limite si non déclenché | Comparé à |
|---|---|---|---|---|
| 1 | Livret A | 1er mois (janv. 1984) | — | l'argent qui dort sur le compte courant |
| 2 | PEL | Livret A ≥ 3 mois de dépenses | mois 8 | Livret A (taux verrouillé, argent bloqué 4 ans, projet logement) |
| 3 | Emprunt d'État 10 ans | 2 produits détenus, ou compte courant ≥ 2 mois de salaire inutilisés | mois 14 | Livret A et PEL (taux fixe élevé, mais le prix bouge si on revend) |
| 4 | Assurance-vie (fonds en francs) | naissance (scriptée, §3.2) | 3 mois après la naissance | Livret A et PEL (long terme, clause bénéficiaire, succession) |
| 5 | SICAV actions France | 1 produit à taux fixe détenu depuis 6 mois | mois 26 | Emprunt d'État (rendement espéré plus haut, risque de baisse, diversifié) |
| 6 | Actions (Elf, L'Oréal, Peugeot) | SICAV détenue depuis 3 mois | mois 32 (été 1986) | SICAV (une seule entreprise : plus de risque, dividendes) |
| — | Saint-Gobain | **offre publique, appel le 24/11/1986** (date historique, pas de déclencheur ; privatisation effective en déc. 1986) | — | actions déjà présentées (prix fixe, marché primaire) |

Les dates limites garantissent que **tout joueur a vu les 6 familles avant le krach d'octobre 1987**, y compris celui qui laisse tout sur son compte. L'ordre exact et les textes peuvent être ajustés par le banquier dans `11_catalogue_banque.md`, à condition de respecter : Livret A d'abord, actions en dernier, assurance-vie liée à la naissance.

### 2.3 Ce que « adapté au profil » veut dire (et ne veut pas dire)
- **Oui** : le moment de l'appel (déclencheurs ci-dessus) ; l'exemple chiffré avec les vrais montants du joueur ; le comparatif avec **ses** produits détenus ; le ton selon la situation (« maintenant que vous êtes papa… »).
- **Oui** : des repères généraux formulés comme tels (« beaucoup d'épargnants gardent quelques mois de dépenses de côté »).
- **Non** : « vous devriez », « je vous conseille », « c'est le moment d'acheter », toute phrase sur l'évolution future d'un cours ou d'un taux. Pour les produits risqués, on montre **le passé** (« une année peut faire −30 % comme +40 % »), jamais une prévision.
- Chaque appel propose **3 boutons** : « Ouvrir / Souscrire » (ouvre le tiroir, rien n'est prérempli au-delà d'un montant d'exemple), « Pas maintenant », « En savoir plus ». Refuser n'a **aucune pénalité** ; le produit reste disponible à la banque.

### 2.4 Le carnet du banquier
Toucher la banque ouvre la liste des produits : **présentés** (avec leur fiche courte et le comparatif sur les 4 critères, en pictogrammes de 1 à 3) et **à découvrir** (silhouettes). Le joueur peut relire toute présentation passée. C'est le seul nouvel écran de la démo.

## 3. Cadre de la prochaine démo

### 3.1 Fenêtre : **janv. 1984 → déc. 1988 (60 mois)**
La fenêtre sept. 1986 → déc. 1988 est trop courte pour qu'une progression se déroule : on l'élargit **vers le passé** et on garde la fin. 1984-1986 offre une bourse en forte hausse (le joueur prend goût aux actions), puis la privatisation de Saint-Gobain, le krach de 1987 et le CAC 40 en 1988 : la même apothéose qu'aujourd'hui, mais méritée.

### 3.2 Profil et situation familiale
- **Gérard, 26 ans, technicien, premier CDI depuis 2 ans, en couple avec Sylvie.** Salaire entre « jeune salarié » et « cadre » de 01 §7.3 ; quelques économies sur le compte courant (environ 1,5 mois de salaire) pour que le Livret A ait quelque chose à accueillir dès le 1er mois.
- **Naissance scriptée au printemps 1985** (environ mois 16) : elle déclenche l'assurance-vie. Le budget est calibré pour rester positif après la naissance (règle A21 respectée : au moins 10 % d'épargne possible).
- **Héritage scripté de la tante Odette en 1988** : le joueur reçoit une partie via l'assurance-vie de sa tante (rapide, sans droits) et une partie via la succession (droits élevés, délai de notaire). Il vit de l'autre côté ce que le banquier lui a expliqué en 1985. Montants et règles d'époque : banquier (11), avec niveau de certitude.
- Les autres événements de vie restent aléatoires (graine), 1 à 3 par an, dont la panne de voiture.

### 3.3 Produits : 6 familles, 9 lignes
Compte courant ; Livret A ; PEL ; Emprunt d'État 10 ans ; Assurance-vie fonds en francs ; SICAV actions France ; Elf Aquitaine, L'Oréal, Peugeot ; Saint-Gobain (déc. 1986). **Pas plus** : chaque produit en plus est un appel du banquier en plus.

### 3.4 Durée visée : **15 à 20 minutes**
60 mois × 8 s = 8 min de défilement, plus environ **15 interruptions** (6 présentations du banquier, 3 événements de marché en modale, 4 à 6 événements de vie), soit une toutes les 4 mois. Le bilan annuel devient une notification sans pause.

### 3.5 Fin de démo (écran simple)
Patrimoine final ; produits découverts et produits utilisés ; une seule comparaison avec **Tata Livret** (tout sur Livret A). Pas d'étoiles ni de titre dans la démo.

## 4. Hors de la prochaine démo
- PEA (n'existe pas avant juil. 1992), CEL, LEP, Codevi, SICAV monétaires et obligataires, second marché : en silhouette seulement si le banquier le juge utile, jamais achetables.
- Crédit immobilier et achat de la résidence principale (le PEL l'annonce, ne le réalise pas).
- Fiscalité complète, droits de succession calculés pour tous les cas : seuls l'exemple de la naissance et l'héritage scripté sont chiffrés.
- Témoins Tonton Matelas et Cousin Indice, étoiles, titres, 3 leçons, rappel à 12 mois, tutoriel, sauvegarde, choix du profil et de la période, P2 et P3.
- Questionnaire de profil de risque au démarrage (mis de côté par le joueur, Q1).
- Frais : bouton « Y a-t-il moins cher ? » (F04), ETF (F05), droits de garde ; mariage, Pacs, divorce (le couple est figé, D4).

## 5. Questions au joueur : **répondues le 2026-10-27**
1. **Q1** Adaptation au profil : **situation de vie uniquement** (âge, couple, enfants, épargne, produits détenus). Le questionnaire de risque est **mis de côté** (idée « plus tard »).
2. **Q2** Cadre **janv. 1984 → déc. 1988, Gérard papa en 1985 : validé.**

## 6. Arbitrages rendus (repris dans la base de connaissances du client)
- **A36** L'assurance-vie entre dans le périmètre (annule A15 pour ce produit) : demande explicite du joueur.
- **A37** Le banquier est le seul canal d'introduction des produits ; ordre et déclencheurs de §2.2.
- **A38** Démo élargie à janv. 1984 → déc. 1988, profil unique scripté, 15 à 20 minutes.
- **A39** Clic extérieur : ferme les fenêtres de bâtiment, jamais les modales à choix.
- **A40 à A45** : voir §7.

## 7. Arbitrages complémentaires (2026-10-27, après le catalogue du banquier et la 2e partie du joueur)

### 7.1 Décisions sur les points du banquier (11 §0)
| # | Décision | Raison |
|---|---|---|
| D3 / A40 | **Oui** : une banque **générique** dans la rue, qui ouvre aussi le Livret A, avec la bulle (?) « Simplifié : en 1984, le Livret A s'ouvrait à la Caisse d'épargne ou à la Poste ». | Un seul bâtiment banque (vision ville) ; la bulle garde l'honnêteté historique. |
| D4 / A41 | **Gérard et Sylvie ne sont pas mariés.** Le texte de l'assurance-vie chiffre avec l'argent de Gérard : Sylvie reçoit **0 F** par succession, **tout** par l'assurance-vie. Pour l'enfant, on dit honnêtement qu'il n'y a pas d'écart sous 275 000 F. | C'est l'exemple le plus concret ; le mariage reste « plus tard ». |
| D5 / A42 | **Oui, règle réelle dans la démo** (45 / 25 / 15 / 0 % sur les seuls gains, selon l'âge du contrat), **affichée dans la confirmation du retrait** avec la date d'exonération (« 0 % à partir d'avril 1991 »). Jeu complet : taux unique (A6). | Une seule formule, et c'est elle qui enseigne la durée de détention. |
| A43 | **Oui** aux 3 baisses du Livret A (08/1984, 07/1985, 05/1986) en **notifications sans pause** venues de la banque, avec le taux et l'inflation de l'année. **Oui** à l'appel Saint-Gobain le **24/11/1986** (§2.2). | Le taux qui baisse quand l'inflation baisse est une leçon gratuite ; la date est exacte. |

### 7.2 Nouveaux retours du joueur (27/10) en exigences testables
| # | Retour | Exigence | Test |
|---|---|---|---|
| R11 | Espacer compte courant et patrimoine | Deux blocs séparés en haut (libellé, icône et couleur distincts), patrimoine en plus grand. | Le joueur lit les deux chiffres sans hésiter, sur PC 1366 × 768 et téléphone paysage. |
| R12 | Voir la performance face à « tout sur le compte courant et le Livret A » | **Comparateur permanent** dans le tableau de bord : « Si tout était resté au Livret A (Tata Livret) : X F — vous : ± Y F ». Tata Livret = même salaire, mêmes événements de vie, épargne du mois au Livret A jusqu'au plafond, le reste au compte courant, 0 F de frais. Seconde ligne pointillée sur la courbe. Repris à l'écran de fin. | Visible en permanence, mis à jour chaque mois, vert si le joueur devance Tata Livret, rouge sinon. |
| R13 | Animation de crash à la panne de voiture | Une voiture de la rue se cabosse contre un réverbère (dessin humoristique, personne n'est blessé), puis le courrier part de la maison. 2 s au maximum, passable d'un toucher (A34). | L'animation précède la modale à chaque panne de voiture. |
| R14 | Animation de naissance et jumeaux possibles | Animation depuis la maison (cigogne, berceau qui apparaît à la fenêtre), 2 s au maximum. **Jumeaux : 1 chance sur 4 dans la démo** (tirage par la graine, volontairement plus que la réalité pour qu'on le voie), 2 berceaux. Le budget reste positif même avec des jumeaux (A21 : au moins 5 % d'épargne possible). Le texte de l'assurance-vie s'accorde au nombre d'enfants. | Sur un jeu fixe de 20 graines de test, 3 à 7 donnent des jumeaux, et aucune ne rend le budget négatif (10 % d'épargne possible au moins avec un enfant, 5 % avec des jumeaux). |

### 7.3 Pédagogie des frais : où et quand (A44)
Règle : chaque chiffre de frais est calculé **avec l'argent du joueur** ; le rendement de 7 % est toujours affiché comme « une hypothèse, pas une promesse ».
1. **Le moment fort (F01)** : à la **première souscription** d'un produit avec frais (SICAV, actions ou assurance-vie, le premier des trois), la confirmation s'agrandit en un encart de M. Lefranc : frais payés tout de suite, puis **3 barres sur 20 ans** pour le montant saisi (sans frais / frais du produit / produit plus chargé, par exemple 0,5 % contre 2,5 % par an pour la SICAV). Exemple pour 10 000 F : 38 700 F sans frais, 28 600 F avec la SICAV de la démo. Une seule fois par partie ; pas de modale en plus.
2. **Au moment de la décision (F03)** : avertissement dans le tiroir quand les frais d'un ordre dépassent 2 % du montant (courtage minimum de 50 F).
3. **Chaque décembre (F02)** : notification du relevé annuel : frais payés dans l'année, et depuis le début « X F payés + Y F de gains qui n'ont jamais existé » (calculés par un jumeau sans frais, 11 §5.2 formule 7).
4. **À la fin de la démo (F06)** : ligne « Frais payés : X F (Tata Livret : 0 F) ». Si le joueur n'a rien souscrit, on montre l'exemple de 10 000 F.
Test : un joueur qui achète une SICAV voit F01 une fois, puis F02 en décembre avec des montants exacts au franc près, sur sa propre partie.

### 7.4 Effet sur le volume
R13, R14 et F01 ne créent pas d'interruption en plus (animations avant des modales existantes, encart dans une confirmation) ; les notifications du Livret A et F02 sont sans pause. La cible de **15 à 20 minutes** tient (**A45**).
