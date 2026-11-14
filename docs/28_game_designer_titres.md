# 28 : Game designer, titres d'époque, collection et seuils de la sauvegarde (G6)

> 2026-11-13. Réponse à G6 (`docs/lots/audit_preparation.md` §3) pour `docs/lots/lot_07.md` et `docs/lots/lot_sauvegarde.md`.
> Relu face au code de `lot/05-logique` : `foyer.json`, `foyer.gd`, `projets.gd`, `krach.gd`, `bilan.gd`, `etat_partie.gd`, `banquier.gd`.
> Tout est en données (`titres.json`, `foyer.json`, `rythme.json`) sauf ce qui est marqué **[code]**.

---

## 0. Ce qui change par rapport à docs/15 §6 et à `lot_07.md` §1 (résumé)

1. **Ordre : « Le neveu de Tonton Matelas » passe avant « L'écureuil »** (7 ↔ 8). Sinon un joueur qui garde tout sur le compte courant reçoit « L'écureuil » (il n'a « détenu que compte courant, Livret A, PEL »), et le titre 8 n'est jamais obtenu.
2. **Seuils des cartes : majorité nette au lieu de « 6 » et « 7 »** : au moins 5 choix de la nature voulue **et** au moins 3 de plus que de l'autre nature. Le nombre de choix comptés varie de 5 à 9 selon la partie (C06 et C07 sont neutres, S10 disparaît avec le break, des créneaux sont abandonnés) : avec « 7 dépenses », la cigale serait impossible dans une partie sur deux.
3. **« Projet abandonné » (titre 4) = abandon évitable** : renoncer alors que RÉALISER ou RÉALISER EN VENDANT était possible. Renoncer faute d'argent n'est pas de l'avarice. **[code, petit]**
4. **Erreur à corriger dans `lot_07.md` D2** : `Foyer.humeur_visible()` renvoie **0 = contente, 1 = neutre, 2 = fâchée** (`foyer.gd`, `visible_de`). D2 écrit « fâchée / contente = (0 / 2) » : c'est l'inverse.
5. **Instantané du krach** : la part risquée vaut **0** si l'instantané est un **exemple** (`"exemple": true`, joueur sans action ni SICAV). Sinon le joueur prudent serait compté comme ayant 10 000 F de SICAV. L'instantané doit aussi garder le **patrimoine** du joueur au même moment (`"patrimoine"`, ajout) **[code, petit]**.
6. Textes : 3 noms et 6 « pourquoi » retouchés (§3).
7. **Les 5 étoiles disparaissent** quand le titre arrive (§5). La collection montre les titres non obtenus en « ??? » (§4).

---

## 1. Les 9 titres face au jeu codé : conditions exactes

Évalués **une fois, à la fin de la partie** (après la carte du jour J de P2C), dans l'ordre ; le premier qui correspond l'emporte. Partie abandonnée ou finie en faillite : pas de titre (D5).

### 1.1 Grandeurs (à tenir dans `stats_titre`, L1 de `lot_07.md`)

| Grandeur | Définition exacte |
|---|---|
| `ecart_tata` | `patrimoine(joueur) / patrimoine(livret) − 1`, nominal, au dernier mois (apport du T3 compris, comme pour tout le monde). Même nombre que le record (D4). |
| `projets_realises` | projets à l'état `realise` ou `realise_apres_report` (sur 2). |
| `humeur_fin` | `Foyer.humeur_visible(e)` au dernier mois, après P2C : 0 contente, 1 neutre, 2 fâchée. |
| `abandon_evitable` | vrai si au moins un projet est passé à `abandonne` alors que le bouton RÉALISER ou RÉALISER EN VENDANT était actif (`desactive == false`) au moment du choix. Compte aussi « RENONCER POUR L'INSTANT » de P2C. **[code]** : un booléen noté dans `Projets.resoudre`. |
| `part_risquee_krach` | `Krach.base(inst) / inst["patrimoine"]`, soit la valeur des actions et des SICAV au cours du krach divisée par le patrimoine au même moment ; **0 si `inst["exemple"]` ou si `lignes` est vide**. L'instantané est pris même rue éteinte (D2). |
| `a_vendu_krach` | `inst["choix"] == "vendre"`. **Recommandé** (paramètre `vente_apres_krach`, 0 = éteint) : vrai aussi si les ventes d'actions et de SICAV faites par ordre entre 11/1987 et 04/1988 dépassent 50 % de `Krach.base(inst)` (vendre en panique un mois plus tard, c'est la même chose). |
| `escargots` | C06 jouée avec le choix `a` (Prêter). |
| `nb_epargne`, `nb_depense` | choix de cartes faits, comptés selon la nature (§2). Un choix grisé (non payable) n'est pas fait ; une carte sortie par « Pas les moyens ce mois-ci » ne compte pas. |
| `produits_detenus` | ensemble des produits détenus au moins un mois (quantité ou solde > 0) sur toute la partie : `livret`, `pel`, `emprunt`, `av`, `sicav`, actions (`elf`, `loreal`, `peugeot`, `saintgobain`). Le compte courant n'est pas un produit. L'héritage arrive en argent (`recevoir_tous`) : il ne crée pas d'assurance-vie. |
| `cc_moyen` | moyenne, sur les 60 fins de mois 01/1984 → 12/1988, de `cc / patrimoine` (mois à patrimoine ≤ 0 ignorés). |

### 1.2 Conditions, dans l'ordre définitif

| Ordre | id | Condition | Paramètres (`titres.json`) |
|---|---|---|---|
| 1 | `bon_pere` | `ecart_tata > 0,02` ET `projets_realises == 2` ET `humeur_fin != 2` | `ecart_min: 0.02` |
| 2 | `golden_boy` | `part_risquee_krach ≥ 0,30` ET `a_vendu_krach` | `part_risquee: 0.30` |
| 3 | `escargots` | `escargots` ET `ecart_tata < 0` | — |
| 4 | `fourmi` | `nb_epargne ≥ 5` ET `nb_epargne − nb_depense ≥ 3` ET (`humeur_fin == 2` OU `abandon_evitable`) | `cartes_min: 5`, `cartes_ecart: 3` |
| 5 | `cigale` | `nb_depense ≥ 5` ET `nb_depense − nb_epargne ≥ 3` ET `humeur_fin == 0` | mêmes paramètres |
| 6 | `marin` | `part_risquee_krach ≥ 0,30` ET non `a_vendu_krach` (« Ne rien faire » et « Renforcer » comptent ensemble) ET `ecart_tata > 0` | `part_risquee` |
| 7 | `neveu_matelas` | `cc_moyen ≥ 0,30` | `cc_moyen_min: 0.30` |
| 8 | `ecureuil` | `produits_detenus ⊆ {livret, pel}` | `produits_surs: ["livret", "pel"]` |
| 9 | `apprenti` | sinon | — |

### 1.3 Pourquoi ces choix

- **2 % (titre 1)** : gardé. Le PEL seul donne à peine 1 à 2 % de plus que Tata sur la démo. Au-dessus de 2 %, il faut avoir vraiment fait travailler l'argent. C'est aussi l'écart du record : un seul nombre pour le joueur.
- **30 % (titres 2 et 6)** : gardé. En dessous, vendre ou garder au krach ne change pas l'histoire de la partie. Le même seuil pour les deux titres rend le choix symétrique : avec la même exposition, vendre donne 2 et garder donne 6.
- **Golden boy avant marin, bon père avant tout** : un joueur qui a vendu au krach mais qui finit nettement devant Tata avec ses 2 projets garde « bon père ». Le titre juge la partie entière, et « Le krach, un an après » a déjà montré la leçon. Aucun titre ne punit deux fois.
- **Jean-Mi n'entre dans aucune condition** (choix voulu) : son arc est écrit d'avance, il n'a aucun lien avec les choix du joueur. Les titres ne mesurent que le joueur face à Tata (même vie, R-MIROIR). Le rang reste affiché à côté, sans servir aux titres.
- **Aucune condition ne demande « Renforcer »** ; aucune ne récompense la vente (le titre 2 la nomme comme une erreur, sans ton moralisateur) ; dépenser n'interdit aucun titre positif (le titre 1 est atteignable par une cigale qui a bien placé : CA-5.2).

---

## 2. BLOQUANT : nature de chaque choix de carte (titres 4 et 5)

Champ à ajouter **par choix** dans `foyer.json` : `"nature": "epargne" | "depense" | "neutre"`. Le champ `sens` existant ne convient pas : il vaut `depense` même pour les choix à 0 F. Règle : le choix le plus cher pour le confort est « dépense », le choix sobre est « épargne ». Les cartes qui ne portent pas sur la consommation sont « neutres ».

| Carte | Choix a | Nature a | Choix b | Nature b | Raison |
|---|---|---|---|---|---|
| C00 Sylvie fait la tête | Partir à Deauville (2 500 F) | **depense** | Faire profil bas (0 F) | **epargne** | dépense de plaisir contre refus de dépenser |
| C01 Vacances 84 | Club Med (9 000 F) | **depense** | Camping à Palavas (2 500 F) | **epargne** | le choix sobre coûte aussi, mais il est 3,6 fois moins cher |
| C02 Magnétoscope | L'acheter (5 500 F) | **depense** | Attendre (0 F) | **epargne** | |
| C03 Canal+ | S'abonner (1 800 F) | **depense** | Trois chaînes (0 F) | **epargne** | |
| C04 Poussette | La neuve (2 200 / 3 800 F) | **depense** | Celle de la cousine (0 F) | **epargne** | |
| C05 Fête de naissance | Grande fête (6 000 F) | **depense** | Repas en famille (800 F) | **epargne** | |
| C06 Escargots | Prêter (8 000 F) | **neutre** | Refuser poliment (0 F) | **neutre** | carte de placement : elle a son titre (3). Refuser une arnaque est de la prudence, pas de l'avarice ; prêter n'est pas une dépense de confort. |
| C07 Cours du soir | S'inscrire (2 500 F, salaire + 4 %) | **neutre** | Pas cette année (0 F) | **neutre** | investissement en soi-même (le « pourquoi » le dit) : ni cigale ni fourmi. |
| C08 Noces | Participer (2 500 F) | **depense** | Carte et fleurs (300 F) | **epargne** | |
| C09 Caméscope | L'acheter (9 500 F) | **depense** | Le louer (600 F) | **epargne** | |
| C10 Le chien | Élevage (3 500 F) | **depense** | SPA (400 F, humeur + 1) | **epargne** | c'est voulu : la fourmi a ici une sortie qui plaît à Sylvie (docs/23 G2). |
| C11 Vacances 87 | L'île de Ré (7 000 F) | **depense** | Vierzon (0 F) | **epargne** | |
| C12 Club de gym | L'inscrire (3 000 F) | **depense** | Courir au parc (0 F) | **epargne** | |
| C13 Vacances 88 | Camping-car (6 000 F) | **depense** | La tente (1 500 F) | **epargne** | |
| C14 Vide-grenier | Tout vendre (+ 1 200 F) | **epargne** | On garde tout (0 F) | **neutre** | vendre pour faire rentrer de l'argent, c'est un geste d'épargnant ; garder ses objets ne coûte rien. |
| C15 Sports d'hiver | Partir (8 000 F) | **depense** | La luge au parc (0 F) | **epargne** | |

Capacité par partie (10 créneaux, 8 à 10 cartes) : environ 6 à 9 choix « épargne » possibles, 5 à 8 choix « dépense » (C14 ne peut pas être une dépense, C06 et C07 sont neutres, S10 saute avec le break). D'où les seuils de §1.2 : 5 et un écart de 3.
**Mesure demandée à dev-logique (L7)** : sur 40 graines, imprimer `nb_epargne` et `nb_depense` pour les politiques `epargner` et `depenser`. Si `depenser` donne moins de 5 dépenses dans plus de 10 % des graines, passer `cartes_min` à 4 (donnée).

---

## 3. Textes définitifs (`titres.json`)

Nom sans chiffre ; « pourquoi » de 15 mots au plus, au vous, sans « achetez / vendez / c'est le moment / auriez dû ».

| Ordre | id | Nom | Pourquoi (mots) |
|---|---|---|---|
| 1 | `bon_pere` | Le bon père de famille | Vous avez fait vivre le foyer et fait travailler l'argent. (10) |
| 2 | `golden_boy` | Le golden boy repenti | Vendu dans la panique : la baisse est devenue une perte. (10) |
| 3 | `escargots` | L'éleveur d'escargots | 30 % promis, 90 % perdus : plus la promesse est belle, plus le risque est grand. (15) |
| 4 | `fourmi` | La fourmi trop sage | Bien épargner, c'est aussi savoir dépenser pour les siens. (9) |
| 5 | `cigale` | La cigale du Club Med | Vous avez profité de chaque saison ; votre épargne, elle, a moins grossi. (13) |
| 6 | `marin` | Le marin par gros temps | Vous avez traversé la tempête sans quitter le bateau. (9) |
| 7 | `neveu_matelas` | Le neveu de Tonton Matelas | Sur votre compte courant, vos billets ont rétréci avec l'inflation. (10) |
| 8 | `ecureuil` | L'écureuil de la Caisse d'épargne | Sûr et sans frais, comme Tata Livret : sans risque, mais sans surprise. (12) |
| 9 | `apprenti` | L'apprenti épargnant | Un peu de tout, sans excès : rejouez pour tenter une autre voie. (12) |

Changements et raisons :
- **2** : « Vendre au plus bas » supposait de savoir après coup que c'était le plus bas, ce que personne ne savait en octobre 1987 (garde-fou A5). « Dans la panique » décrit le geste, pas un savoir tiré du futur.
- **3** : on ajoute la leçon (reprise du texte des escargots) ; 30 % et 90 % sont les chiffres du jeu (8 000 F prêtés, 800 F rendus).
- **4** : « blindée mais seule » culpabilisait (garde-fou 14 §6.3) ; « trop sage » sourit sans juger.
- **5** : l'ancien « l'argent placé a peu travaillé » est faux pour une cigale qui a bien placé : avec R-MIROIR, dépenser ne change pas l'écart avec Tata. La nouvelle phrase ne parle que du montant épargné.
- **7, 8, 9** : on précise la cause (7) ; on montre l'autre face de la sécurité (8) ; « Rejouez » est gardé sans pression (9).
- Marques et termes d'époque (Club Med, Caisse d'épargne, « golden boy », années 1980) : certitude A pour l'époque. À valider par le client (C1 point 3) s'il ne veut pas de marques.

---

## 4. Collection : « ??? » plutôt que des titres cachés

**Décision proposée : les 9 cases sont visibles, les titres non obtenus s'affichent « ??? » (défaut D6 confirmé).**
- Plaisir : fort. Les cases vides donnent une raison de rejouer (« il m'en manque 6 ») sans aucune mécanique d'accroche ; le compteur « 3 / 9 » de l'écran titre suffit.
- Pédagogie : chaque titre raconte une autre façon de jouer, donc rejouer pour en voir un autre, c'est essayer une autre stratégie.
- Garde-fou : **aucun indice sur la condition** d'un titre non obtenu, aucune fanfare à 9 / 9, aucune récompense en jeu. Le joueur ne doit pas recevoir une liste de « mauvais gestes à faire pour compléter ». Les titres 2 et 3 restent possibles à chercher exprès : faire volontairement l'erreur dans un bac à sable, puis lire sa leçon, n'apprend pas un mauvais réflexe.
- Titre obtenu : nom, « pourquoi », « obtenu n fois », date de la première fois.
- **Petit plus, coût faible, plaisir moyen** : sur l'écran de fin, la ligne « Nouveau dans votre collection » quand le titre est obtenu pour la première fois (`nombre == 1` dans la collection renvoyée par `Records.enregistrer`). Facultatif pour 07-I.

## 5. Les 5 étoiles : le titre les remplace

**Décision proposée : les étoiles disparaissent de l'écran de fin quand 07-I affiche le titre.** Raisons :
1. Le client a dit « pas d'étoiles » pour P5 (14 §6, 15 §6).
2. Elles font double emploi : les étoiles « battre Tata » et « battre Matelas » répètent les 4 barres et le rang ; l'étoile « sang-froid » répète le titre 2.
3. **L'étoile « Battre Cousin Indice » (`bilan.gd`, `battus["indice"]`) contredit CA-3.1** (Cousin Indice n'apparaît pas dans la démo). À retirer de l'affichage dès 07-I, sinon dès qu'on le peut.
4. Deux notes concurrentes (3 étoiles sur 5 et un titre) brouillent la fin : un seul verdict se retient mieux.

On garde, **sans étoile**, la seule information qui n'est dite nulle part ailleurs : la ligne sur l'inflation (« plus de baguettes que vous n'en avez mis de côté », `bilan["objectif"]`), en une phrase factuelle. Les clés `etoiles` et `nb_etoiles` peuvent rester dans `Bilan` pour les tests : il suffit de ne plus les afficher.

---

## 6. Sauvegarde manuelle : seuils de `rythme.json > sauvegarde`

| Réglage | Avis | Valeur |
|---|---|---|
| `toujours` | Krach, héritage et projets : **gardés** (liste validée par le joueur). **C06 passe dans `toujours`** (« et toujours les escargots » : il ne doit pas être bloqué par l'espacement). | `["marche", "D08", "projet", "C06"]` |
| « Le krach, un an après » (`gazette`) | **Non**, il ne rejoint pas la liste. C'est une carte de lecture avec un seul bouton (OK), sans décision : sauvegarder avant ne sert à rien. Le krach lui-même est déjà dans `toujours`. | — |
| Héritage (D08) | Gardé par fidélité à la décision du joueur, mais la carte n'a qu'un bouton (« compris ») : la vraie décision vient ensuite, avec les ordres (placer 60 000 F dépasse le seuil d'ordre en 1988). Pas de changement. | — |
| `seuil_carte_salaires` | **1,0 gardé**, avec **enjeu = prix du choix le plus cher** (et non l'écart entre les deux choix). Cartes concernées : C01 (9 000 F en 1984), C09 (9 500 F en 1987), plus C06 par `toujours` ; C15 (8 000 F) reste juste en dessous du salaire de 1988. Une carte de vacances ou d'achat ordinaire ne mérite pas de sauvegarde. | 1.0 |
| `seuil_ordre_part`, `seuil_ordre_min` | **20 % et 5 000 F gardés**. En 1984, c'est le plancher de 5 000 F qui joue (patrimoine d'environ 15 000 F) ; après l'héritage, ce sont les 20 % (environ 30 000 F) : la proposition tombe sur les gros gestes (placer l'héritage, vendre en panique après le krach). | 0.20 / 5000 |
| `intervalle_mois` | **6 mois gardés, mais comptés depuis la dernière proposition, quelle qu'elle soit** (y compris une proposition « toujours »). Sinon la somme dépasse la cible : 6 à 7 « toujours » (krach, D08, 2 choix et 2 jours J de projet, plus 1 si un projet est reporté) + 1 à 3 cartes + 0 à 2 ordres = 7 à 12, au-delà des 4 à 10 de CA-SL6. Avec ce comptage : environ 7 à 10. | 6 |

Note pour le chef de projet : `lot_sauvegarde.md` §1 annonce « Toujours : ≤ 6 par partie », mais un report de projet en ajoute un 7e. Les « toujours » restent proposés sans exception, et seuls les « avec seuil » attendent 6 mois. La règle reste dans la logique de SV-L, qui n'est pas encore codée : changer la façon de compter ne coûte rien.

---

## 7. Une stratégie par titre (CA-5.1 / CA-T2)

Vocabulaire de `StrategieTest` : cartes `epargner` / `depenser` / `alterner` ; projets `moins_cher` / `plus_cher` ; jour J `auto` / `vendre`.

| Titre | Stratégie (une phrase) |
|---|---|
| 1 bon père | Livret A jusqu'à fin 1984, puis 40 % de chaque mois en SICAV et en actions dès leur présentation, « Ne rien faire » au krach, projets `plus_cher` réalisés en `vendre`, cartes `alterner`, escargots refusés. |
| 2 golden boy | Au moins 50 % du patrimoine en SICAV et en actions dès 1986, puis « Tout vendre » au krach (le reste : `alterner`, projets `moins_cher`). |
| 3 escargots | Tout au Livret A comme Tata, prêter les 8 000 F à Patrick, cartes `alterner`, projets `moins_cher`. |
| 4 fourmi | Tout au Livret A, cartes `epargner`, escargots refusés, puis RENONCER au projet 2 alors qu'il est payable. |
| 5 cigale | Tout au Livret A, cartes `depenser`, escargots refusés, projets `moins_cher` réalisés (Sylvie finit contente). |
| 6 marin | 40 % en SICAV et en actions dès 1986, « Ne rien faire » (ou « Renforcer ») au krach, cartes `alterner`, renoncer au projet 1 (pour ne pas recevoir « bon père »). |
| 7 neveu | Ne rien placer : tout reste sur le compte courant, cartes `alterner`, escargots refusés, projets `moins_cher`. |
| 8 écureuil | Tout au Livret A sans PEL, cartes `alterner`, escargots refusés, projets `moins_cher` (écart avec Tata ≈ 0, donc pas « bon père »). |
| 9 apprenti | 15 % en SICAV gardés au krach, le reste au Livret A, cartes `alterner`, escargots refusés, renoncer au projet 2. |

Contrôle demandé (L7) : imprimer la **répartition des 9 titres** sur 40 graines × stratégies existantes. Alerte au game designer si un titre dépasse 50 % des parties `alterner` (titre trop facile, rejouabilité faible) ou si le titre 1 n'est jamais obtenu hors stratégie dédiée.

---

## 8. Demandes au chef de projet (résumé)

- `foyer.json` : `nature` par choix (§2). **Débloque 07-L.**
- `titres.json` : ordre, conditions et paramètres de §1.2, textes de §3.
- **[code, petit]** : `abandon_evitable` dans `Projets.resoudre` ; `"patrimoine"` dans l'instantané du krach ; part risquée = 0 si l'instantané est un exemple ; (recommandé) ventes d'actions et de SICAV 11/1987 → 04/1988 pour `a_vendu_krach`.
- Corriger `lot_07.md` D2 : humeur 0 = contente, 2 = fâchée ; D9 : étoiles retirées à 07-I (§5) ; D6 : « ??? » confirmé, sans indice.
- `lot_sauvegarde.md` / `rythme.json` : `toujours` = `["marche", "D08", "projet", "C06"]`, sans `gazette` ; enjeu de carte = prix du choix le plus cher ; espacement de 6 mois compté depuis la dernière proposition, quelle qu'elle soit.
- Pour le client (C1 point 3) : noms et « pourquoi » de §3, marques comprises.
