# 15 : Spécification game design V3 de la démo (P1, P2, P3, P4, P5, P6, P9, P10)

> Auteur : game designer. Date : 2026-10-29. Statut : **spécification à découper en lots par le chef de projet.**
> Origine : décision du joueur du 2026-10-29 (`10_retours_joueur.md`) : on fait P1, P2, P3, P4, P5, P6, P9, P10 ; P7, P11, P12, P13 plus tard ; P8 abandonnée. Réserves du client appliquées par défaut (`14` §6) : humeur de Sylvie en 3 états, 8 à 10 cartes placées d'abord dans les tunnels, Jean-Mi finit derrière Tata Livret, P5 allégée (rang + titre, sans étoiles), P10 seulement comme conséquence de P1/P2, garde-fous de 14 §6.3.
> Références : `12` (arbitrages), `13` (UX banquier, cadence §5), `14` (propositions), `11` (catalogue, versements §8), données `godot/data/`.
> **Tous les prix et montants de ce document sont provisoires (certitude C)** tant que le banquier ou le boursier ne les a pas validés (§10). Le code se développe avec ces valeurs ; le contenu définitif remplace les données, sans code.

---

## 0. Vue d'ensemble

| Boucle | Durée | Mécanique | Proposition |
|---|---|---|---|
| Courte | chaque mois | les intérêts et les frais se voient ; bouton « Jusqu'au prochain courrier » | P4 |
| Courte | tous les 3 à 6 mois | carte de dilemme du foyer, un toucher, humeur de Sylvie | P2 (+ P10) |
| Moyenne | 2 ans | projet du foyer : choix, jauge, échéance, réussite ou report | P1 (+ P10) |
| Moyenne | toute la démo | les voisins (Tata Livret, Tonton Matelas, Jean-Mi) : passages, classement, arc de Jean-Mi | P3 + P9 |
| Moment fort | 10/1987 et 10/1988 | Lundi noir en direct ; « Le krach, un an après » | P6 |
| Longue | fin de démo | rang dans la rue + titre d'époque | P5 allégée |

### 0.1 Règles communes (valables pour tout le document)

- **R-MIROIR (nouvelle, structurante)** : les trois voisins-témoins ont **le même salaire, les mêmes événements de vie et les mêmes dépenses que Gérard** : chaque carte de **consommation**, chaque projet réalisé, chaque week-end de réconciliation, chaque effet sur le salaire (cours du soir) leur est appliqué **le même mois et du même montant**. Ils ne diffèrent que par **la façon de placer** l'argent. Conséquences : dépenser n'est jamais une faute dans le classement (garde-fou 14 §2.4) ; la pastille « vs tout au Livret A » reste une mesure **des seuls choix de placement**. Exceptions : les cartes de type **placement** (les escargots) ne sont **pas** recopiées : c'est un mauvais placement, il doit coûter face à Tata. Le paiement d'un témoin se fait sur son compte courant puis son Livret A ; il peut passer en négatif (affiché tel quel).
- **R-CADENCE (remplace 13 §5.3, règles 1 et 2)** : jamais deux interruptions avec pause **le même mois ni deux mois de suite**, toutes catégories confondues. Seules exceptions : un événement de marché et la panne forcée qui le suit (existant). Priorité quand deux candidats visent le même mois : marché > date historique (Saint-Gobain, naissance, héritage, « un an après ») > échéance de projet > événement de vie aléatoire > présentation du banquier > choix de projet > carte de dilemme. Le perdant glisse au premier mois libre (les cartes, elles, peuvent être abandonnées : §2.4).
- **Anticipation sans fuite** : une interruption flexible (présentation, carte, choix de projet) ne part pas au mois m si m + 1 porte une interruption **datée connue des données** (date historique, échéance de projet, date limite d'une présentation non faite, événement de marché). Rien de cela ne se voit à l'écran : le joueur ne perçoit pas l'absence d'une carte (A5 respecté).
- **Budgets par catégorie** (le compteur de 13 §5.3 règle 3 ne compte que les « classiques ») : classiques (présentations, vie, marché, héritage) ≤ 15 ; cartes de dilemme 8 à 10 ; projets ≤ 4 (2 choix + 2 échéances ; l'échéance de décembre 1988 se fond dans la fin) ; Gazette « un an après » 1.
- **Modales à choix** (cartes, projets) : ne se ferment **pas** au clic extérieur (A39). Sur PC : touches 1 / 2 / 3 pour les boutons.
- **Historique** : tout ce qui met en pause est historisé (comme aujourd'hui) ; les passages-clés des voisins aussi (§3.6). Nouvelles sources et genres en §8.
- **Sauvegarde** : format 3 ; les sauvegardes du format 2 sont ignorées (précédent du format 1). Champs nouveaux en §8.
- **Hasard** : tout tirage nouveau (cartes, variantes) utilise la **graine de vie** décalée, sans changer les tirages existants (naissance, événements aléatoires).

---

## 1. P4 « Le mois utile » (à livrer en premier)

### 1.1 Les pièces du mois

- **Quand** : à chaque changement de mois, après le salaire et les versements automatiques.
- **Quoi** : `revenus_du_mois` = intérêts acquis (Livret A, PEL, assurance-vie, compte rémunéré éventuel) + coupons + dividendes versés ce mois ; `frais_du_mois` = frais de gestion prélevés + frais des versements automatiques. Les variations de cours **n'en font pas partie** (elles bougent déjà le patrimoine).
- **Affichage** : si `revenus_du_mois ≥ 10 F` : 1 à 6 pièces d'**or** volent de la banque vers la maison, montant flottant « + 312 F » (nombre de pièces = 1 + arrondi(log10(montant / 10)), plafonné à 6). Si `frais_du_mois ≥ 10 F` : pièces de **cuivre** de la maison vers la banque, « − 45 F de frais », vers le compteur de frais existant. Dividendes et coupons : la pièce porte le nom de la ligne (« Elf : + 840 F ») et un « ding » (quand les sons existeront, T6). Si les intérêts du Livret A ne sont crédités qu'en décembre dans le moteur, le texte dit « + 312 F gagnés ce mois-ci (versés en décembre) ».
- **Vitesses** : ×1 et ×2 : pièces ; ×3 et saut : pas de pièces, le compteur roule seul (règle existante 13 §3.2).
- **Pédagogie** : la pile grossit avec les années (intérêts composés) ; le cuivre des frais tombe chaque mois.

### 1.2 Le bouton « Jusqu'au prochain courrier »

- **Effet** : le temps passe à **×6** (1,33 s par mois ; trafic ×7) **jusqu'à ce qu'une interruption avec pause s'ouvre**, puis, après sa résolution, revient à la vitesse d'avant l'appui.
- **Aucun calcul à l'avance** : on avance mois par mois et on s'arrête quand `mois_passe(res)` porte une modale. Il s'arrête donc **au** mois de l'événement, jamais avant (14 §6.3.3, A5), et à chaque présentation du banquier (A37), carte et échéance de projet.
- **Notifications franchies** : empilées (3 à l'écran au plus, les autres directement dans l'historique) ; un badge sur le bouton HISTORIQUE compte les non lues. Les bulles des voisins non clés sont sautées ; les clés deviennent des notifications (§3.6).
- **États** : inactif quand une fenêtre ou une modale est ouverte, et en décembre 1988. Un nouvel appui pendant le saut l'arrête (retour à la vitesse d'avant). Touche PC : `N`. Sur téléphone : bouton de 80 px à côté des vitesses (UX).
- **Différent** de F8 / triple toucher (outil de test, retiré des versions exportées : T1).

### 1.3 Critères d'acceptation P4

- CA-4.1 : sur 40 graines, avec le bouton appuyé après chaque interruption, chaque arrêt a lieu au mois exact d'une modale ; aucun arrêt sans modale ; aucun mois sauté sans son traitement (salaire, versements, notifications historisées).
- CA-4.2 : la vitesse revient à celle d'avant l'appui après la modale (×1 → saut → modale → ×1).
- CA-4.3 : `revenus_du_mois` et `frais_du_mois` égaux, au franc près, aux mouvements du mois dans le moteur (test sur 60 mois) ; aucune pièce sous 10 F ; pas de pièces à ×3 ni pendant le saut (capture).
- CA-4.4 : les notifications franchies pendant un saut sont toutes dans l'historique, dans l'ordre.

---

## 2. P2 « Les dilemmes du foyer » et l'humeur de Sylvie

### 2.1 L'humeur de Sylvie (3 états visibles, un nombre caché)

- Valeur cachée `humeur` entière, de **−3 à +3**, départ **0**.
- Affichage : **contente** si ≥ +2 ; **neutre** de −1 à +1 ; **fâchée** si ≤ −2. Jamais de nombre ni de jauge à l'écran : le visage de Sylvie à la fenêtre de la maison (3 dessins, UX) et une ligne dans la fenêtre « Mon foyer ».
- Changement d'état : petite bulle de Sylvie depuis la fenêtre (non bloquante, 4 s) : « Sylvie est ravie », « Sylvie fait la tête ». Pas de bulle si l'humeur bouge sans changer d'état.
- Effets sur la valeur :

| Cause | Effet |
|---|---|
| Choix d'une carte | −1, 0 ou +1 selon le choix (§2.5) |
| Projet réalisé à la date / après report | +2 / +1 |
| Projet reporté (au moment du report) / abandonné | −1 / −2 |
| Naissance | +1 |
| Week-end de réconciliation | remet l'humeur à 0 |
| Chaque 1er janvier | 1 pas vers 0 (l'humeur s'use, les choix récents comptent) |

- **Une seule conséquence en argent** (14 §6.5) : si Sylvie est fâchée quand un créneau de carte s'ouvre, la carte tirée est **C00 « Sylvie fait la tête »** (2 fois par partie au plus, jamais sur deux créneaux de suite).
- Un moral bas n'est **jamais** une fin de partie (14 §6.3.7).

### 2.2 La carte de dilemme (déroulé)

1. Le créneau s'ouvre (§2.4) : la carte **sort de la maison** (UX, ≤ 1 s, passable d'un toucher), le temps est en pause.
2. Contenu : titre ≤ 5 mots, texte ≤ 30 mots, **2 boutons** de même poids portant chacun le **montant** et un pictogramme d'humeur (sourire / neutre / moue) — l'effet d'humeur est donc visible avant de choisir (pas de piège).
3. Après le choix : la carte affiche **3 s** (un toucher passe) **une ligne de conséquence**, puis se range dans la maison.
   - Choix qui dépense : « Placés au Livret A au taux d'aujourd'hui ({taux} %), ces {montant} F feraient environ {vf} F fin 1988. » (`vf = montant × (1 + taux)^(mois restants / 12)`, taux du mois courant, jamais un taux futur ; au conditionnel, sans jugement, jamais « vous auriez dû » : 14 §6.3.4).
   - Choix qui épargne : la réplique de Sylvie de la carte.
   - Carte de type revenu ou placement : pas de ligne de coût d'opportunité (la carte a son propre texte).
4. Paiement : compte courant puis Livret A. **Un choix dont le montant dépasse compte courant + Livret A est grisé** (« Il manque {x} F sur votre compte et votre Livret A ») ; chaque carte a au moins un choix à 0 F ou un revenu ; si les deux choix coûtent et qu'aucun n'est payable, la carte est remplacée par l'autre candidate du créneau, sinon le créneau est abandonné.
5. R-MIROIR appliquée le même mois (sauf type placement).
6. Historique : genre `carte`, source maison, titre, choix, montant, ligne de conséquence.

Durée visée : **6 à 8 s** par carte (lecture de 30 mots + un toucher + 3 s de conséquence).

### 2.3 Les escargots (seule carte de type placement)

- C06 : « Prêter 8 000 F à Patrick » (humeur +1, c'est le frère de Sylvie) / « Refuser poliment » (humeur −1).
- Si prêt : **9 mois plus tard**, notification **persistante** de la maison (sans pause) : « Des nouvelles des escargots : l'élevage a fermé. Patrick vous rend 800 F sur 8 000. » Les escargots **perdent toujours** (14 §6.3.5 ; la V1 donnait 10 % de chances de gain : supprimé). Leçon (verso ou ligne de la notification) : « Aucun placement honnête ne promet 30 % par an. Plus la promesse est belle, plus le risque est grand. »
- Non recopiée chez les voisins : elle se voit face à Tata.
- Trace P10 : un escargot dessiné sur le mur de la maison après la mauvaise nouvelle.

### 2.4 Créneaux et tirage (8 à 10 cartes par partie)

Chaque créneau a une **fenêtre**, un **mois préféré** et une ou deux **cartes candidates** (tirage par la graine de vie : deux parties ne racontent pas la même vie, D7). Le créneau part au mois préféré s'il respecte R-CADENCE et l'anticipation, sinon au mois libre le plus proche **dans la fenêtre** (le plus tardif d'abord) ; s'il n'y en a pas, il est **abandonné** (compté pour les tests).

| Créneau | Fenêtre | Préféré | Candidates | Ordre d'abandon si la durée dépasse (§5.3) |
|---|---|---|---|---|
| S1 | 05 → 08/1984 | 07/1984 | C01 Vacances 84, C02 Magnétoscope | 1er |
| S2 | 11/1984 → 02/1985 | 12/1984 | C03 Canal+, C02 (si non tirée en S1) | — |
| S3 | 08 → 10/1985 | 09/1985 | C04 Poussette, C05 Fête de naissance | 2e |
| S4 | 12/1985 → 02/1986 | 01/1986 | C06 Escargots (fixe) | jamais |
| S5 | 06 → 09/1986 | 07/1986 | C07 Cours du soir, C08 Noces des beaux-parents | 3e |
| S6 | 02 → 04/1987 | 03/1987 | C09 Caméscope, C10 Le chien | jamais (tunnel) |
| S7 | 05 → 08/1987 | 07/1987 | C11 Vacances 87 ; si le projet est C2A (Club Med) : l'autre de C09/C10 | jamais (tunnel) |
| S10 | 01 → 02/1988 | 02/1988 | C15 Sports d'hiver ; **seulement si aucune échéance de projet en 02/1988** | — |
| S8 | 06 → 07/1988 | 06/1988 | C12 Club de gym, C13 Vacances 88 | jamais (tunnel) |
| S9 | 08/1988 | 08/1988 | C14 Vide-grenier | 4e |

Résultat attendu : 10 créneaux, 8 à 10 cartes jouées selon les projets choisis et le hasard. C00 (réconciliation) **remplace** la carte d'un créneau, elle n'en ajoute pas.

### 2.5 Les cartes (textes provisoires du game designer ; prix à valider par le banquier, §10.1)

Montants en francs courants ; M = salaire mensuel de Gérard (6 790 F en 1984, 8 490 F en 1988). Notation des boutons : **[libellé : montant, humeur]**.

| id | Titre | Texte (≤ 30 mots) | Choix A | Choix B | Type |
|---|---|---|---|---|---|
| C00 | Sylvie fait la tête | « Sylvie ne vous parle plus depuis trois jours. Votre mère suggère un week-end à deux à Deauville. » | Partir à Deauville : 2 500 F, humeur → 0 | Faire profil bas : 0 F, inchangée | conso |
| C01 | Les vacances 84 | « Sylvie rêve du Club Med à Agadir. Votre frère prête sa tente pour Palavas. » | Club Med : 9 000 F, +1 | Camping à Palavas : 2 500 F, −1 (« Encore Palavas… ») | conso |
| C02 | Le magnétoscope | « Chez Darty, un magnétoscope VHS : 6 500 F. Sylvie veut enregistrer ses feuilletons. » | L'acheter : 6 500 F, +1 | Attendre que les prix baissent : 0 F, −1 | conso |
| C03 | Canal+ arrive | « Une quatrième chaîne, cryptée, avec des films récents. Décodeur et un an d'abonnement : 1 800 F. » | S'abonner : 1 800 F, +1 | Rester sur trois chaînes : 0 F, −1 | conso |
| C04 | La poussette | « La poussette neuve grand modèle : 2 800 F (jumeaux : la double, 4 500 F). La cousine prête la sienne. » | La neuve : 2 800 F / 4 500 F, +1 | Celle de la cousine : 0 F, 0 | conso |
| C05 | La fête de naissance | « Les deux familles veulent fêter {prénom(s)}. Grande fête à la salle des fêtes, ou repas à la maison ? » | Grande fête : 6 000 F, +1 | Repas en famille : 800 F, 0 | conso |
| C06 | Les escargots | « Patrick, le frère de Sylvie, lance un élevage d'escargots. Il promet 30 % par an et vous demande 8 000 F. » | Prêter : 8 000 F, +1 | Refuser poliment : 0 F, −1 | **placement** |
| C07 | Les cours du soir | « Le CNAM propose une formation du soir pour les techniciens : 4 500 F, deux soirs par semaine pendant un an. » | S'inscrire : 4 500 F, −1 ; **salaire + 4 % à partir de janvier 1988** | Pas cette année : 0 F, 0 | conso (effet salaire recopié chez les voisins) |
| C08 | Les noces des beaux-parents | « Trente ans de mariage : les enfants offrent un voyage à Venise. Votre part : 2 500 F. » | Participer : 2 500 F, +1 | Une carte et des fleurs : 300 F, −1 | conso |
| C09 | Le caméscope | « Un caméscope pour filmer {prénom(s)} : 9 500 F. Le photographe en loue un pour les vacances. » | L'acheter : 9 500 F, +1 | Le louer en août : 300 F, 0 | conso |
| C10 | Le chien | « Les enfants réclament un chien. Un labrador d'élevage, ou un chiot de la SPA ? » | Élevage : 3 500 F, +1 | SPA : 400 F, **+1** (moins cher n'est pas plus triste) | conso |
| C11 | Les vacances 87 | « Une maison à louer à l'île de Ré en août : 7 000 F. Les parents de Sylvie vous invitent à Vierzon. » | L'île de Ré : 7 000 F, +1 | Vierzon : 0 F, −1 | conso |
| C12 | Le club de gym | « Sylvie veut s'inscrire au club de gym avec sa sœur : 3 000 F l'année. » | L'inscrire : 3 000 F, +1 | Courir au parc : 0 F, 0 | conso |
| C13 | Les vacances 88 | « Un camping-car loué pour trois semaines : 6 000 F. Ou la vieille tente ? » | Camping-car : 6 000 F, +1 | La tente : 1 500 F, −1 | conso |
| C14 | Le vide-grenier | « Vide-grenier dans la rue dimanche. Vendre le vieux fauteuil, les vinyles, la mobylette ? » | Tout vendre : **+ 1 200 F**, −1 (« Pas mon fauteuil ! ») | On garde tout : 0 F, +1 | revenu |
| C15 | Les sports d'hiver | « Les collègues partent au ski en février. Une semaine à Val Thorens en famille : 8 000 F. » | Partir : 8 000 F, +1 | La luge au parc : 0 F, −1 | conso |

Variantes : `{prénom(s)}` et accords selon un enfant ou des jumeaux (C04, C05, C09). Vouvoiement, comme les textes existants de la maison.

### 2.6 Critères d'acceptation P2

- CA-2.1 : sur 40 graines × 3 stratégies de test (tout dépenser, tout épargner, alterner), **8 à 10 cartes** par partie (C00 comprise) ; jamais deux interruptions le même mois ni deux mois de suite (hors krach → panne) ; jamais de carte au mois qui précède une interruption datée.
- CA-2.2 : la stratégie « tout épargner » rend Sylvie fâchée au moins une fois et déclenche C00 ; « tout dépenser » ne rend jamais le budget négatif (les choix non payables sont grisés).
- CA-2.3 : après chaque carte de consommation, Tata Livret, Tonton Matelas et Jean-Mi ont dépensé le même montant le même mois ; après C06, non.
- CA-2.4 : C06 prêtée → notification à +9 mois, 800 F rendus, dans 100 % des graines.
- CA-2.5 : la ligne de conséquence utilise le taux du Livret A du mois courant (test au franc près) ; aucun texte ne contient « auriez dû », « devriez », « conseil ».
- CA-2.6 : deux graines différentes donnent au moins 2 cartes différentes sur 10 graines (tirage des candidates).
- CA-2.7 : carte ouverte, sauvegarde, reprise : la même carte se rouvre, un seul paiement.

---

## 3. P1 « Les projets du foyer »

### 3.1 Règles

- **Deux projets par démo au plus, un seul en cours à la fois** (14 §6.1).
- **Choix** : carte de choix (pause, sort de la maison) avec **3 options**, chacune avec nom, montant, date ; pas d'option « aucun » (c'est le foyer qui décide d'un but).
- **Jauge** sur la maison (UX) : `disponible = compte courant + Livret A` sur le montant ; un second segment en pointillé montre `placements revendables` (valeur nette de revente du mois : frais, impôt, pénalité de PEL) ; la date de l'échéance sous la jauge.
- **Rappel** à 3 mois de l'échéance : notification sans pause de la maison : « Sylvie : La Super 5, c'est en avril ! Sans rien vendre, vous avez 21 400 F sur 30 000. »
- **Banquier** (garde-fou 14 §6.3.6) : l'en-tête de la fenêtre Banque et chaque formulaire d'ordre portent une ligne **factuelle** : « Projet : la Super 5, avril 1986 (dans 14 mois) · 30 000 F ». Il ne dit jamais où placer.
- **Échéance** (interruption, priorité « échéance de projet ») : carte « Le jour J » :
  - affiche le montant, le **disponible sans rien vendre** et, si besoin, **ce qu'il faudrait vendre**, ligne par ligne, dans l'ordre automatique : SICAV, actions (la plus grosse ligne d'abord), emprunt d'État, assurance-vie, PEL en dernier ; pour chaque ligne : montant net, et l'écart avec ce qui a été versé (« SICAV : 8 200 F, soit 1 300 F de moins que vos versements ») ; pénalité du PEL écrite (« prime d'État perdue : 2 900 F ») ;
  - boutons : **RÉALISER** (si le disponible suffit ; prend le compte courant puis le Livret A) **ou RÉALISER EN VENDANT** (si disponible + ventes suffisent ; une confirmation montre la liste) ; **REPORTER DE 4 MOIS** (une fois par projet) ; **RENONCER** ;
  - si rien ne suffit : seulement REPORTER (si possible) et RENONCER.
- **Réalisation** : animation de la maison (P10, §7) ; humeur +2 (+1 après un report) ; R-MIROIR (les voisins paient le même mois, même montant).
- **Report** : nouvelle échéance à +4 mois, ou au premier mois libre suivant (R-CADENCE) ; humeur −1. À la nouvelle échéance : RÉALISER (EN VENDANT) ou RENONCER.
- **Abandon** : humeur −2 ; le projet est noté « abandonné » dans « Mon foyer » et l'historique ; aucune autre pénalité.
- Les versements automatiques continuent ; un paiement de projet qui vide le compte peut faire refuser un versement le mois suivant (règle existante, tout ou rien).

### 3.2 Les deux projets (montants provisoires, à valider par le banquier : §10.1)

Calibrage : épargne possible ≈ 1 630 F/mois avant la naissance, ≈ 1 150 F avec un enfant, ≈ 480 F avec des jumeaux. L'option la plus chère doit être **tendue** (réussie à la date par un joueur raisonnable avec un enfant, souvent reportée avec des jumeaux ou après de grosses dépenses).

| id | Choix en | Option | Montant | Échéance | Repère |
|---|---|---|---|---|---|
| P1A | 03/1984 | « Le salon et la chaîne hi-fi » | 12 000 F | 04/1986 | ≈ 1,8 M |
| P1B | 03/1984 | « La Grèce pour les 30 ans de Sylvie » | 20 000 F | 04/1986 | ≈ 3 M |
| P1C | 03/1984 | « La Super 5 neuve (la vieille 4L en reprise) » | 30 000 F | 04/1986 | ≈ 4,4 M |
| P2A | 01/1987 | « Le Club Med en famille, juillet 1987 » | 14 000 F | 07/1987 | ≈ 1,8 M, horizon 6 mois, **avant** le krach |
| P2B | 01/1987 | « La deuxième voiture : un break familial » | 40 000 F | 02/1988 | ≈ 5 M, horizon 13 mois, **après** le krach |
| P2C | 01/1987 | « L'apport pour un T3 » | 90 000 F | 12/1988 | ≈ 11 M, horizon 23 mois ; PEL arrivé à 4 ans |

- Choix du projet 2 : créneau 01/1987 (fenêtre 01 → 02/1987).
- **P2C** : l'échéance tombe le dernier mois ; la carte du jour J précède l'écran de fin, sans report possible (« RENONCER POUR L'INSTANT »). Réalisé, l'apport **reste dans le patrimoine** sous une ligne « Apport du T3 : 90 000 F » (ce n'est pas une dépense) ; aucun crédit immobilier n'est simulé (la démo s'arrête). **[revient à la marge sur 12 §4]** « achat de la résidence principale hors démo » : seul l'apport est montré, comme débouché du PEL ; à confirmer par le client.
- Leçon visée (sans la dire) : l'argent de P2B placé en actions début 1987 a fondu en octobre ; celui de P2A, à 6 mois, était sur le Livret A pour la plupart des joueurs ; P2C profite du PEL et de l'héritage.

### 3.3 Critères d'acceptation P1

- CA-1.1 : choix du projet 1 en 03/1984 (± 1 mois) et du projet 2 en 01 ou 02/1987 dans 100 % des graines ; jamais deux projets en cours.
- CA-1.2 : stratégie « tout au Livret A, choix B à chaque carte » avec un enfant : P1C réalisé à la date sur ≥ 80 % des graines ; P2B réalisé à la date sur ≥ 60 % (à ajuster par le banquier en calibrant les montants).
- CA-1.3 : la vente automatique respecte l'ordre, applique frais, impôt (barème A42) et pénalité de PEL du moteur existant ; le reste après paiement va au compte courant ; jamais de solde négatif.
- CA-1.4 : un report déplace l'échéance de 4 mois ou au premier mois libre ; un seul report par projet ; P2C sans report.
- CA-1.5 : les voisins paient le même montant le même mois que la réalisation (et rien en cas d'abandon).
- CA-1.6 : la ligne « Projet : … (dans N mois) » apparaît dans la fenêtre Banque et les formulaires d'ordre, et nulle part dans les textes de présentation du banquier.
- CA-1.7 : sauvegarde au milieu d'un projet, reprise : même projet, même échéance, même report utilisé.

---

## 4. P3 « Le quartier fait ses comptes » et P9 « La rue a de l'humour »

### 4.1 Les voisins (4 lignes au plus ; Cousin Indice reste hors démo)

| Voisin | Règle de placement | Rôle |
|---|---|---|
| **Tata Livret** (existe) | tout au Livret A jusqu'au plafond, le reste au compte courant | **comparateur permanent** (pastille du HUD inchangée) |
| **Tonton Matelas** (existe en données) | tout sur le compte courant | l'inflation : ses billets « rétrécissent » en baguettes |
| **Jean-Mi** (nouveau) | vendeur chez le concessionnaire Peugeot du boulevard ; compte courant jusqu'en 08/1986, puis Peugeot au règlement mensuel (§4.3) | concentration (il travaille chez Peugeot et n'a que du Peugeot) et effet de levier |

Tous suivent R-MIROIR. `temoins.json` reçoit `jeanmi` (nom, initiale, règle, répliques devant/derrière, plan §4.3).

### 4.2 Le classement de la rue

- **Où** : bloc « La rue » dans le panneau « Mon argent » (4 lignes : portrait, nom, patrimoine, rang) et écran de fin (§6). La pastille « vs tout au Livret A » reste seule dans la barre haute (14 §6.1, P3).
- **Changements de rang** : notification sans pause « Jean-Mi passe devant vous dans la rue » / « Vous repassez devant Jean-Mi », **au plus une tous les 6 mois** ; Tata Livret garde sa règle existante (retournement de la pastille).
- Patrimoine négatif possible (Jean-Mi après le krach) : affiché en rouge avec le signe.

### 4.3 L'arc de Jean-Mi (plan provisoire, à calculer et valider par le boursier et le banquier : §10.2)

Le plan est en données (`temoins.json > jeanmi.plan`), calculé chaque mois par le moteur sur **le cours de Peugeot du jeu** (même série que le joueur voit).

| Date | Étape | Chiffres provisoires (C) |
|---|---|---|
| 01/1984 → 08/1986 | vit comme Gérard (miroir), tout sur le compte courant, « attend le bon tuyau » | — |
| 09/1986 | achète du Peugeot au **règlement mensuel** | couverture = 80 % de son compte (≈ 30 000 F) ; position = 5 × couverture (≈ 150 000 F) ; coût des reports ≈ 0,7 % de la position par mois |
| 04/1987 | **Porsche 944 d'occasion** à crédit | 140 000 F ; apport 30 000 F pris sur ses gains ; crédit 110 000 F sur 48 mois (taux d'époque à fournir) |
| 08/1987 | renforce sa position | + 50 000 F de position |
| 10/1987 | krach : la baisse dépasse sa couverture → **liquidation** au cours du mois | perte = position × baisse ; ce qui dépasse la couverture devient une **dette** |
| 11/1987 | panneau « À VENDRE » sur la Porsche | — |
| 02/1988 | Porsche vendue | ≈ − 35 % ; le prix solde une partie du crédit |
| 1988 | rembourse ses dettes avec toute son épargne (« jusqu'en 1990 ») | mensualité à fixer |

Contraintes (tests) : **J1** Jean-Mi devant Tata Livret au moins de 03/1987 à 09/1987 (la montée, courte) ; **J2** derrière Tata Livret en 12/1988 d'au moins 10 %, et **visé : dernier de la rue**, pour toute graine et toute stratégie (y compris le joueur qui a tout mis sur Peugeot sans crédit) ; **J3** aucun bouton du joueur ne vient de Jean-Mi : ses tuyaux sont du décor (14 §6.3.1) ; le joueur ne peut pas acheter à crédit.

**L'effet de levier expliqué une fois** (12/1987, passage-clé V13), calculé sur les vrais chiffres : « Avec {couverture} F, Jean-Mi en a joué {position} au règlement mensuel. Peugeot a perdu {baisse} % : {perte} F de perte. Ses {couverture} F y sont passés, et il en doit encore {dette}. » Le mot « règlement mensuel » n'est gardé que si le boursier le juge utile (sinon « à crédit »).

### 4.4 Les passages (bulles non bloquantes, P3 + P9)

Règles : bulle ≤ 15 mots, visible 5 s (environ un demi-mois à ×1) ; **au plus une bulle tous les 2 mois** (passages et bulles réactives confondus) ; jamais un mois d'interruption avec pause (décalée d'un mois) ; jamais un conseil, un titre à acheter ni une prévision, sauf dans la bouche de Jean-Mi, dont les tuyaux échouent ; jamais nécessaire pour jouer. Un toucher sur la bulle l'ouvre en carte de lecture ; les passages **clés** (★) vont dans l'historique et deviennent des notifications s'ils sont franchis en ×3 ou pendant un saut.

| id | Date | Qui | Bulle (provisoire) |
|---|---|---|---|
| V01 ★ | 02/1984 | Mme Lopez, la concierge | « Vous connaissez vos voisins ? » → carte de lecture « La rue » : les 3 voisins, leur règle, « même salaire et mêmes dépenses que vous » |
| V02 | 06/1984 | Tonton Matelas | « Une banque ? Et si elle fait faillite ? Moi, c'est sous le matelas. » |
| V03 | 09/1984 | Tata Livret | « Le Livret A, mon petit, c'est l'État qui le garantit. » |
| V04 | 03/1985 | Jean-Mi | « La Bourse ? J'attends le bon tuyau. Au café, ils en ont plein. » |
| V05 | 08/1985 | Tonton Matelas | « Avec 100 F, j'avais {b0} baguettes en 1984. Aujourd'hui {b1}. Mes billets rétrécissent ! » |
| V06 | 06/1986 | Tata Livret | « Le Livret A baisse, mais les prix aussi. Alors ça va. » |
| V07 ★ | 09/1986 | Jean-Mi | « Le patron du café me l'a juré : avec la 205, Peugeot ne peut que monter. J'ai tout mis dessus, et même plus ! » |
| V08 | 12/1986 | Mme Lopez | « Saint-Gobain, Paribas… toute la rue devient actionnaire ! » |
| V09 ★ | 04/1987 | Jean-Mi | La Porsche rouge se gare devant chez lui. « Elle est belle, hein ? Payée par Peugeot ! » (puis la Porsche passe dans la rue chaque mois) |
| V10 | 08/1987 | Jean-Mi | « J'en ai repris. Quand ça monte, faut y aller ! » |
| V11 | 10/1987 | Jean-Mi | dans la séquence du Lundi noir (§5.1) : il court vers la banque |
| V12 | 11/1987 | — | la Porsche porte un panneau « À VENDRE » (décor, pas de bulle) |
| V13 ★ | 12/1987 | Jean-Mi | « Je n'ai plus rien… et je dois encore de l'argent. » → carte de lecture : la phrase du levier (§4.3) |
| V14 | 03/1988 | Tonton Matelas, Tata Livret | M : « Le krach ? Moi, j'ai rien perdu ! » T : « Moi non plus, et j'ai touché mes intérêts. » |
| V15 | 07/1988 | Jean-Mi (à vélo), Mme Lopez | J : « La Bourse, plus jamais ! » L : « C'est pas la Bourse, Jean-Mi, c'est le crédit. » |
| V16 ★ | 11/1988 | Jean-Mi | « Peugeot est remonté… sans moi. » (à vérifier sur la série : Peugeot 12/1988 au-dessus du niveau d'avant le krach) |

**Bulles réactives** (P9, même budget d'une bulle tous les 2 mois, une fois chacune) : Mme Lopez au premier achat d'action (« Alors, monsieur Gérard, on est actionnaire ? ») ; à la réalisation d'un projet (« Belle voiture ! » / « Bonnes vacances ! ») ; M. Lefranc devant la banque le mois qui suit le krach (« Quelle semaine… ») ; Sylvie à la fenêtre aux changements d'humeur (§2.1).

**Le kiosque** (bâtiment média, panneau qui défile, sans pause, sans bulle, hors budget) : 06/1984 « Les Bleus champions d'Europe » ; 11/1984 « Canal+ est lancée », « Le Top 50 à la télé » ; 12/1985 « Coluche ouvre les Restos du cœur » ; 03/1986 « Cohabitation : Chirac à Matignon » ; 05/1986 « Tchernobyl : le nuage » ; 10/1986 « Prost champion du monde » ; 04/1987 « TF1 privatisée » ; 10/1987 figé sur « LUNDI NOIR » ; 05/1988 « Mitterrand réélu » ; 06/1988 « Le CAC 40 est né » ; 09/1988 « JO de Séoul ». Dates à vérifier (§10.2).

**Les enfants qui grandissent** (P9/P10, décor) : berceau(x) à la fenêtre 04/1985, poussette(s) devant la porte 1985-1986, tricycle(s) en 1988.

### 4.5 Critères d'acceptation P3 + P9

- CA-3.1 : sur 40 graines × 3 stratégies (tout Livret A, actif diversifié, tout sur Peugeot sans crédit) : J1, J2 vérifiés ; Tonton Matelas derrière Tata Livret en 12/1988 ; Cousin Indice jamais affiché.
- CA-3.2 : les voisins reçoivent salaire, événements de vie, cartes de consommation, projets et héritage identiques au joueur (test du miroir sur 60 mois) ; pas les escargots.
- CA-3.3 : la phrase du levier ne contient que des montants calculés (aucun chiffre en dur) et ses nombres sont cohérents (couverture + dette = perte, au franc près).
- CA-3.4 : jamais deux bulles à moins de 2 mois ; aucune bulle un mois d'interruption avec pause ; les 5 passages ★ sont dans l'historique même franchis en saut.
- CA-3.5 : relecture des textes : aucun « achetez », « vendez », « c'est le moment », aucune prévision hors des répliques de Jean-Mi.

---

## 5. P6 « Lundi noir, en direct » et « Le krach, un an après »

### 5.1 La séquence (10/1987, avant la modale existante du krach)

- **Durée ≤ 15 s**, passable d'un toucher (A34), **aucun compte à rebours ni minuteur** sur la décision (14 §6.3.7).
- Storyboard (UX à détailler) : l'écran de la Gazette affiche jour après jour l'indice de Paris (vendredi 16/10 → lundi 19 → mardi 20 → mercredi 21 → jeudi 22 → vendredi 23 → lundi 26/10/1987, ≈ 1,5 s par jour, chiffres rouges) ; une file de 6 à 8 passants se forme devant la banque ; le téléphone sonne à la maison, bulle de Sylvie : « Gérard, à la radio ils parlent de 1929 ! » ; Jean-Mi traverse la rue en courant (V11) ; M. Lefranc sur le pas de sa porte. Puis la modale du krach actuelle (3 choix, ligne « Face au Livret A »), inchangée.
- Les valeurs journalières de l'indice viennent du boursier (§10.2). La séquence ne change aucun calcul.
- À l'ouverture de la modale, le moteur prend un **instantané** : lignes risquées détenues (SICAV, actions), leur valeur, le montant proposé par « Renforcer », le choix fait.

### 5.2 « Le krach, un an après » (10/1988, interruption datée)

- Carte de la Gazette (pause), 3 barres calculées sur **l'instantané du joueur** à 10/1988 : **Tout vendu** (vendu aux cours d'octobre 1987, frais compris, puis au Livret A) ; **Rien fait** (mêmes lignes aux cours d'octobre 1988, dividendes compris) ; **Renforcé** (mêmes lignes + le montant proposé, acheté aux cours d'octobre 1987). Le choix réel du joueur est entouré. Pas de texte « vous auriez dû ».
- Texte (≤ 50 mots, provisoire) : « Un an après, la Bourse de Paris a regagné une grande partie du terrain perdu. Ceux qui ont pu attendre ont retrouvé leur argent ; Jean-Mi, lui, a été forcé de vendre au plus bas : le crédit ne laisse pas attendre. En octobre 1987, personne ne savait combien de temps il faudrait. »
- Garde-fou (renforcer = market timing ?) : la barre « Renforcé » est montrée parce que c'était un des trois choix, mais le texte ne la valorise pas ; la leçon porte sur **l'horizon** (pouvoir attendre) et le levier. Phrase finale du boursier, au choix, avec certitude : un rappel qu'après 1929 Wall Street a mis environ 25 ans à retrouver son sommet.
- Joueur sans action ni SICAV au krach : les barres portent sur un exemple de 10 000 F de SICAV, mention « exemple : vous n'aviez pas d'actions en octobre 1987 ».

### 5.3 Critères d'acceptation P6

- CA-6.1 : la séquence dure ≤ 15 s et se passe d'un toucher ; aucune valeur de l'indice affichée avant 10/1987.
- CA-6.2 : les 3 barres de « un an après » sont exactes au franc près face à un calcul indépendant (test) pour les 3 choix possibles et le cas « sans action ».
- CA-6.3 : « un an après » tombe en 10/1988 dans 100 % des graines ; il est dans l'historique (source média).

---

## 6. P5 allégée « Le score de la rue » (écran de fin)

- L'écran de fin de 13 §4.3 est gardé ; on ajoute :
  1. **Le rang dans la rue** : les 4 barres (vous, Tata Livret, Tonton Matelas, Jean-Mi) à la place des 2 barres « Vous et Tata Livret », la barre de Tata restant soulignée comme référence ; la réplique du voisin le plus proche (répliques `devant` / `derriere` existantes, plus celles de Jean-Mi).
  2. **Le titre d'époque** (un seul), avec une phrase « pourquoi » ; pas d'étoiles (14 §6.1).
  3. Une ligne « Projets : 2 sur 2 réalisés » et l'humeur finale de Sylvie (son visage).
- Règle des titres : évalués dans l'ordre, le premier qui correspond l'emporte. Aucun titre ne flatte la spéculation ni ne récompense « Renforcer » (« Ne rien faire » et « Renforcer » comptent ensemble comme « a gardé ») :

| Ordre | Titre | Condition | Pourquoi (affiché) |
|---|---|---|---|
| 1 | **Le bon père de famille** | devant Tata de plus de 2 % ET 2 projets réalisés ET Sylvie pas fâchée | « Vous avez fait vivre le foyer et fait travailler l'argent. » |
| 2 | **Le golden boy repenti** | a choisi « Tout vendre » au krach avec au moins 30 % de son patrimoine en actions et SICAV | « Vendre au plus bas, c'est transformer une baisse en perte. » |
| 3 | **L'éleveur d'escargots** | a prêté à Patrick ET derrière Tata | « 30 % promis, 90 % perdus. » |
| 4 | **La fourmi blindée mais seule** | au moins 6 choix « épargne » ET (Sylvie fâchée à la fin OU un projet abandonné) | « L'argent de côté, c'est bien ; une vie à côté aussi. » |
| 5 | **La cigale du Club Med** | au moins 7 choix « dépense » ET Sylvie contente | « Vous avez bien vécu ; l'argent placé, lui, a peu travaillé. » |
| 6 | **Le marin par gros temps** | au moins 30 % en actions et SICAV au krach ET n'a pas vendu ET devant Tata | « Vous avez traversé la tempête sans quitter le bateau. » |
| 7 | **L'écureuil de la Caisse d'épargne** | n'a détenu que compte courant, Livret A et PEL | « Sûr et sans frais, comme Tata Livret. » |
| 8 | **Le neveu de Tonton Matelas** | compte courant ≥ 30 % du patrimoine en moyenne | « Vos billets ont rétréci avec l'inflation. » |
| 9 | **L'apprenti épargnant** | sinon | « Rejouez : un autre foyer, une autre histoire. » |

- CA-5.1 : chacun des 9 titres est atteint par au moins une stratégie de test scriptée ; le titre et le rang sont calculés dans la logique (testés en headless), pas dans l'UI.
- CA-5.2 : un projet réalisé n'abaisse jamais le rang (R-MIROIR) ; le titre 1 est atteignable par un joueur qui a réalisé les 2 projets les plus chers.

---

## 7. P10 « La maison qui grandit » (réduite : traces de P1/P2 seulement)

Liste fermée (UX dessine, dev-interface pose ; une trace par décision, rien ne disparaît au krach) :

| Déclencheur | Trace |
|---|---|
| Humeur | visage de Sylvie à la fenêtre : contente / neutre / fâchée |
| P1A / P1B / P1C réalisé | lampe et chaîne hi-fi à la fenêtre / carte postale et amphore sur le rebord / Super 5 rouge devant la maison (remplace la 4L beige) |
| P2A / P2B / P2C réalisé | autocollant Club Med sur la voiture / second véhicule, un break / panneau « VENDU » et camion de déménagement dans la séquence de fin |
| C02 ou C03 | lueur bleue de télévision le soir ; antenne et décodeur pour C03 |
| C04 | poussette (double si jumeaux) devant la porte (1985-1986), puis tricycle(s) en 1988 |
| C10 | niche et chien dans le jardinet |
| C07 | diplôme du CNAM à la fenêtre en 1988 |
| C06 perdu | un escargot sur le mur |
| Naissance | berceau(x) à la fenêtre (existe) |

- CA-10.1 : capture de la maison en 12/1988 pour 3 parties types (tout dépenser, tout épargner, mixte) : les traces correspondent exactement aux décisions (PC et téléphone).

---

## 8. Données, état, sauvegarde, historique (pour le chef de projet)

- **Données nouvelles** (dev-logique) : `data/foyer.json` (humeur : bornes, seuils, effets ; cartes C00-C15 ; créneaux S1-S10 ; projets P1A-P2C ; textes de rappel) ; `temoins.json > jeanmi` (+ plan) ; `data/rue.json` (passages V01-V16, bulles réactives, kiosque, enfants) ; `periode_p1.json` ou `series.json` : cours journaliers 16 → 26/10/1987 (séquence) et ancrages mensuels de Peugeot 1986-1988 si le boursier les ajoute ; `rythme.json` : vitesse de saut (`duree_mois_s` du saut 1,33 s, trafic 7).
- **État nouveau** (sauvegardé, **format 3**, anciennes sauvegardes ignorées) : `humeur`, `annee_erosion` ; `cartes` (créneaux : état, carte tirée, mois, choix) ; `c00_compte` ; `escargots` (mois du prêt, issue) ; `projets` (en cours, options, échéance, report utilisé, état final) ; `temoins.jeanmi` (position, couverture, dette, crédit Porsche, étape) ; `instantane_krach` ; `bulles_vues`, `dernier_mois_bulle`, `dernier_changement_rang` ; `saut_actif`, `vitesse_avant_saut` ; `stats_titre` (choix dépense / épargne, part risquée au krach, choix au krach, moyenne du compte courant).
- **Historique** : genres nouveaux `carte`, `projet`, `voisin`, `gazette` ; sources : cartes et projets → maison ; passages ★ → nouvelle source `rue` (visible dans TOUT ; filtre dédié ou rangement sous MA MAISON : choix de l'UX) ; « un an après » → média.
- **Fenêtre « Mon foyer »** : humeur (visage + phrase), projet en cours (jauge, échéance), projets passés, cartes jouées (renvoi à l'historique filtré maison).

---

## 9. Calendrier de référence de la démo (01/1984 → 12/1988)

Hypothèse : joueur « moyen » (dates typiques des présentations dynamiques), un enfant, projet 1 = P1C réalisé à la date, projet 2 = P2B réalisé à la date. **■** = interruption avec pause (catégorie) ; ○ = sans pause. Les mois marqués « libre » peuvent recevoir un événement de vie aléatoire (0 à 2 par partie).

| Mois | Interruption ■ | Sans pause ○ |
|---|---|---|
| 01/84 | D01 Livret A (présentation) | |
| 02/84 | | V01 « La rue » ★ ; premières pièces d'intérêts |
| 03/84 | **Choix du projet 1** (projet) | |
| 04/84 | libre | |
| 05/84 | D02 PEL (présentation ; limite 07/84) | |
| 06/84 | | V02 Matelas ; kiosque Euro 84 |
| 07/84 | **S1** C01 ou C02 (carte) | |
| 08/84 | | Livret A 6,5 % |
| 09/84 | libre | V03 Tata |
| 10/84 | D03 Emprunt d'État (présentation ; limite 02/85) | |
| 11/84 | | kiosque Canal+, Top 50 |
| 12/84 | **S2** C03 ou C02 (carte) | relevé 1984 |
| 01/85 | libre | |
| 02/85 | libre | |
| 03/85 | (bloqué : naissance le mois suivant) | V04 Jean-Mi |
| 04/85 | Naissance (vie scriptée) | humeur +1 |
| 05/85 | | berceau à la fenêtre |
| 06/85 | D04 Assurance-vie (présentation ; limite 07/85) | |
| 07/85 | | Livret A 6 % ; D04 bis |
| 08/85 | libre | V05 Matelas (baguettes) |
| 09/85 | **S3** C04 ou C05 (carte) | |
| 10/85 | | |
| 11/85 | D05 SICAV (présentation ; limite 02/86) | |
| 12/85 | | relevé 1985 ; kiosque Restos du cœur |
| 01/86 | **S4** C06 Escargots (carte) | rappel du projet 1 |
| 02/86 | | |
| 03/86 | D06 Actions (présentation ; limite 08/86) | kiosque cohabitation |
| 04/86 | **Échéance du projet 1** (projet) | |
| 05/86 | | Livret A 4,5 % ; kiosque Tchernobyl |
| 06/86 | libre | V06 Tata |
| 07/86 | **S5** C07 ou C08 (carte) | |
| 08/86 | libre (ou échéance du projet 1 reportée) | |
| 09/86 | | V07 Jean-Mi entre en Bourse ★ |
| 10/86 | libre | issue des escargots (si prêt) ; kiosque Prost |
| 11/86 | D07 Saint-Gobain (date historique) | |
| 12/86 | | relevé 1986 ; V08 Mme Lopez |
| 01/87 | **Choix du projet 2** (projet) | |
| 02/87 | | |
| 03/87 | **S6** C09 ou C10 (carte) | |
| 04/87 | | V09 Porsche ★ ; kiosque TF1 ; rang (si Jean-Mi passe devant) |
| 05/87 | (S7 ici si le projet 2 est P2A) | |
| 06/87 | | plafond du Livret A |
| 07/87 | **S7** C11 (carte) — ou échéance P2A | |
| 08/87 | | V10 Jean-Mi renforce |
| 09/87 | (bloqué : marché le mois suivant) | |
| 10/87 | **Krach** : Lundi noir en direct + journal (marché) | instantané |
| 11/87 | Panne de voiture forcée (vie) | L17 ; Porsche « À VENDRE » ; rappel du projet 2 |
| 12/87 | | relevé 1987 ; V13 levier ★ |
| 01/88 | | |
| 02/88 | **Échéance du projet 2** (P2B) — sinon S10 C15 | |
| 03/88 | | V14 Matelas et Tata |
| 04/88 | D08 Héritage (date historique) | |
| 05/88 | | kiosque Mitterrand réélu |
| 06/88 | **S8** C12 ou C13 (carte) | CAC 40 |
| 07/88 | | V15 Jean-Mi à vélo |
| 08/88 | **S9** C14 Vide-grenier (carte) | |
| 09/88 | | kiosque JO de Séoul |
| 10/88 | **Le krach, un an après** (Gazette) | |
| 11/88 | | V16 Jean-Mi ★ |
| 12/88 | (échéance P2C si choisi) puis **fin** | relevé intégré à la fin |

### 9.1 Vérification de la cadence

| Mesure | Démo actuelle | Après V3 (référence) |
|---|---|---|
| Interruptions avec pause | 11 à 13 | **24 à 27** : 7 présentations, 4 classiques scriptées (naissance, krach, panne, héritage), 0 à 2 aléatoires, 8 à 10 cartes, 3 à 4 projets (2 choix, 2 échéances ; la 2e se fond dans la fin si P2C), 1 Gazette |
| Décisions | ≈ 8, dont 1 forte | ≈ 21 (7 présentations, 9 cartes, 2 choix de projet, 1 à 2 échéances, krach) |
| Deux interruptions le même mois ou deux mois de suite | — | **aucune**, hors krach → panne (existant) |
| Plus long tunnel sans pause | 11 mois (88 s) | **3 mois** (24 s) : 01-03/1985 et 08-10/1986 ; 06-09/1987 si le projet 2 n'est pas P2A (S7 en 07 : 2 mois) |
| Tunnel 11/1986 → 10/1987 | 1 notification | choix du projet 2, 2 à 3 cartes, Porsche, échéance P2A possible |
| Tunnel 05 → 12/1988 | 1 notification | 2 cartes, « un an après », 2 passages, fin du projet 2 |

### 9.2 Durée (cible ≤ 20 min à ×1, avec le bouton)

Hypothèses de temps médian par élément (à remplacer par la mesure réelle) :

| Élément | Nombre × temps | Total |
|---|---|---|
| Défilement à ×1, sans le bouton | 60 mois × 8 s | 480 s |
| Présentations + ouverture de la banque et ordres + réglages des versements | 7 × 30 s + 5 × 45 s + 60 s | 495 s |
| Naissance, héritage, panne, 1 à 2 aléatoires | | 80 s |
| Krach : séquence 15 s + décision 30 s | | 45 s |
| Cartes | 9 × 7 s | 63 s |
| Projets : 2 choix × 20 s + 2 échéances × 12 s | | 64 s |
| « Un an après » | | 20 s |
| Lecture volontaire de notifications et bulles | | 30 s |
| Écran de fin | | 60 s |
| **Total à ×1 sans jamais toucher le bouton** | | **≈ 1 340 s ≈ 22 min** |
| Avec le bouton dans la moitié des creux de 2 mois ou plus (≈ 40 % du défilement en ×6) | défilement ≈ 300 s | **≈ 19 min** |
| Avec le bouton après chaque interruption | défilement ≈ 110 s | **≈ 16 min** |

Conclusion : **la cible de 20 min tient avec le bouton** ; à ×1 pur, on la dépasse d'environ 2 min (la démo actuelle est déjà vers 19-20 min, l'ajout pèse ≈ 3 min). Mesure de recette : une partie réelle chronométrée par le coordinateur à ×1 **sans** le bouton, une **avec** ; si la seconde dépasse 20 min, on retire les créneaux dans l'ordre de §2.4 (S1, S3, S5, S9 ; jamais sous 8 cartes). Voir la question 1 au joueur (§12).

---

## 10. Contenu à produire, et par qui

### 10.1 Banquier (prix d'époque, règles, avec niveau de certitude A/B/C)

1. Prix 1984-1988 des **16 cartes** (§2.5) : vacances Club Med Agadir / camping Palavas, magnétoscope VHS, Canal+ (décodeur, abonnement d'un an), poussettes simple et double, fête de naissance, formation du soir CNAM (et la plausibilité de + 4 % de salaire), voyage à Venise, caméscope et location, labrador et SPA, location à l'île de Ré, club de gym, camping-car loué, revenu d'un vide-grenier, semaine à Val Thorens, week-end à Deauville. Garder les ordres de grandeur en mois de salaire si le prix exact change.
2. Montants et libellés des **6 options de projet** (§3.2) : Super 5 neuve avec reprise, voyage en Grèce, salon et chaîne hi-fi, Club Med en famille 1987, break familial 1988 (part comptant avec reprise), apport d'un T3 fin 1988 (et ce que le PEL de 1984 apporte : prime d'État, droit à prêt, en une phrase).
3. **Jean-Mi, côté crédit** : taux et durée d'un crédit auto en 1987 (Porsche), décote d'une Porsche 944 d'occasion en 3 mois de crise, mensualité de remboursement d'une dette en 1988 ; validation de la phrase du levier avec le boursier.
4. Règles de vente automatique pour un projet (§3.1) : vérifier l'ordre (SICAV, actions, emprunt, assurance-vie, PEL) et les textes de pénalité (PEL avant 4 ans, impôt de l'assurance-vie A42).
5. Validation du ton des lignes de conséquence et de la ligne « Projet : … » du guichet (factuel, jamais de conseil, A33).

### 10.2 Boursier (données de marché et d'époque, avec certitude)

1. **Peugeot 1986-1988** : ancrages mensuels (au moins 09/1986, 03/1987, 09/1987, 10/1987, 11/1987, 12/1988) pour que la série du jeu suive l'histoire ; confirmer que Peugeot fin 1988 dépasse son niveau d'avant le krach (V16).
2. **Plan de Jean-Mi** (§4.3) : mécanisme du règlement mensuel pour un particulier en 1986-1987 (couverture exigée, coût des reports, appel de couverture, liquidation), chiffres finaux respectant J1 et J2 ; garder ou non le mot « règlement mensuel ».
3. **Séquence du Lundi noir** : clôtures journalières de l'indice de Paris du 16 au 26/10/1987 (et nom exact de l'indice affiché à l'époque).
4. **« Un an après »** : vérifier que la série du jeu donne en 10/1988 un rebond cohérent avec l'histoire ; phrase sur 1929 (Wall Street, durée de retour au sommet) avec certitude.
5. **Kiosque** : dates et intitulés des 12 titres (§4.4) ; « Saint-Gobain, Paribas » dans V08 (Paribas privatisée en janvier 1987 : à confirmer).

### 10.3 Designer UX (visuel, animation, PC et téléphone)

1. Carte de dilemme (sortie de la maison, 2 boutons avec montant et pictogramme d'humeur, ligne de conséquence 3 s) ; carte de choix de projet à 3 options ; carte « Le jour J » (liste des ventes) ; carte « Le krach, un an après » (3 barres).
2. Jauge de projet sur la maison (2 segments, date) ; ligne « Projet » dans la fenêtre Banque et les formulaires ; fenêtre « Mon foyer » enrichie.
3. Sylvie à la fenêtre (3 visages) ; les traces de §7 ; les enfants qui grandissent.
4. Les 3 voisins et Mme Lopez (silhouettes vectorielles, portraits pour les bulles et le classement), la Porsche 944 rouge, le panneau « À VENDRE », Jean-Mi à vélo ; le bloc « La rue » dans « Mon argent » ; le kiosque défilant.
5. Storyboard de la séquence du Lundi noir (≤ 15 s).
6. Écran de fin : 4 barres, réplique du voisin, titre et « pourquoi », projets, visage de Sylvie (PC et téléphone sans défilement).
7. Bouton « Jusqu'au prochain courrier » (place, libellé court sur téléphone, état actif), badge des notifications non lues, pièces d'or et de cuivre mensuelles.
8. Source `rue` dans l'historique (icône ; filtre dédié ou non).

### 10.4 Game designer (moi) et client

- Textes définitifs des cartes, passages, bulles réactives, titres et « pourquoi » (les versions de ce document servent de base) ; relecture du ton par le client (aucun titre flatteur pour la spéculation, aucune culpabilisation).
- Équilibrage après la première partie réelle : nombre de cartes, montants des projets, effets d'humeur.

---

## 11. Dépendances et ordre de réalisation recommandé

| Étape | Contenu | Attend du contenu ? | Dépend de |
|---|---|---|---|
| 0 | **Lot technique** déjà accepté par le joueur : T1 (raccourcis retirés des exports), T3 (découpage de `principal.gd`) + test de fumée de l'UI | non | — |
| 1 | **P4** : bouton « Jusqu'au prochain courrier », pièces mensuelles, badge HISTORIQUE. **Moteur de cadence V3** (R-CADENCE, catégories, budgets, anticipation), **R-MIROIR** pour les témoins existants, **format de sauvegarde 3**, nouveaux genres d'historique | non | 0 |
| 2 | **P2** : humeur, créneaux, cartes (avec les textes et prix provisoires de ce document), escargots, C00 ; Sylvie à la fenêtre en dessin provisoire | prix du banquier remplaçables ensuite | 1 |
| 3 | **P1** : projets, jauge, rappels, jour J, vente automatique, ligne du guichet ; traces P10 des projets | montants du banquier remplaçables | 1 (et 2 pour l'humeur) |
| 4 | **P3 + P9** : Tonton Matelas affiché, Jean-Mi (moteur générique de plan en données), classement de la rue, passages, bulles, kiosque | moteur : non (plan provisoire) ; **valeurs finales : boursier + banquier** ; dessins : UX | 1 |
| 5 | **P6** : séquence du Lundi noir, instantané, « un an après » | **cours journaliers du boursier** pour l'affichage ; storyboard UX | 1, 4 (Jean-Mi dans la séquence) |
| 6 | **P5 allégée** : rang + titre à l'écran de fin ; traces P10 restantes ; calibrage final des montants ; mesure de durée et retrait éventuel de créneaux | textes définitifs | 2 à 5 |

En parallèle des étapes 1 à 3 : le banquier fournit §10.1, le boursier §10.2, l'UX §10.3. Les étapes 2, 3 et 4 peuvent avancer en parallèle côté logique (fichiers distincts : `foyer`, `projets`, `voisins`) si le chef de projet découpe `etat_partie.gd` en conséquence ; côté interface, elles touchent toutes la maison et les modales : séquentiel conseillé.

---

## 12. Points ouverts à soumettre au joueur (3)

1. **Durée** : avec tout cela, une partie sans jamais utiliser le bouton « Jusqu'au prochain courrier » dure environ 22 minutes à ×1 (≈ 19 min en l'utilisant de temps en temps). On garde les 9 à 10 cartes, ou on en retire 2 pour rester sous 20 minutes même sans le bouton ?
2. **Le classement de la rue** : visible seulement dans « Mon argent » et à la fin, avec un message quand Jean-Mi vous double (proposé), ou affiché en permanence à l'écran à côté de la pastille de Tata Livret ?
3. **Les titres** : faut-il garder sur l'écran titre le meilleur résultat et la liste des titres déjà obtenus (« 3 titres sur 9 ») pour donner envie de rejouer, ou un simple titre à la fin suffit ?

Décisions prises par défaut dans ce document et à confirmer par le client (pas par le joueur) : R-MIROIR (les voisins dépensent comme vous) ; l'apport du T3 réalisé en décembre 1988 sans crédit simulé (marge de 12 §4) ; la barre « Renforcé » dans « un an après » avec un texte qui ne la valorise pas.
