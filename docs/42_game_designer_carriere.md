# 42 : Game designer, carrière simplifiée

> 2026-11-18. Réponse à l'idée du joueur « carrière simplifiée » (`docs/10_retours_joueur.md`, section du 2026-11-18, verbatim : « opportunité de changer de travail, peut-être payer moins mais avec plus de temps ou vice-versa »). Exploration seulement : **rien n'est décidé ni développé** (`docs/lots/decisions_extension_annees.md`).
> Bases : `godot/data/chapitres/1984/foyer.json` (cartes, humeur, champ `salaire` déjà présent sur C07), `evenements_vie.json`, docs/35 (archétypes, R-SEUL), docs/39 (1989-1993, profils, promotion CNAM), docs/38 §6 (PER comme notion).
> **Tous les montants, pourcentages et dates sont provisoires (certitude C).** Indemnités de chômage, primes de départ, congé formation, retraite : à valider par le **banquier** ; récession de 1993 : **boursier**.
> Règles d'écriture inchangées : vouvoiement ; titre ≤ 5 mots ; texte ≤ 30 mots ; gabarits pour les montants ; jamais « devriez / auriez dû / conseil » ; aucun choix de carrière n'est jamais noté (titre, étoile, rang).

---

## 0. En bref

1. **Aujourd'hui, le salaire tombe du ciel** : le joueur agit sur les dépenses (cartes) et les placements, jamais sur le revenu. La carrière ouvre **l'autre moitié de l'équation** : épargne = revenu − dépenses.
2. **Pas un jeu de carrière** : pas de compétences, d'expérience, de CV ni de marché de l'emploi. **2 à 3 moments de carrière par chapitre**, sous forme de **cartes du foyer** (même modale, mêmes créneaux), avec un effet **durable** sur le salaire ou le temps.
3. **Aucune pause en plus** : les cartes de carrière prennent la place d'une candidate dans des créneaux existants ; leurs suites arrivent en notification sans pause.
4. **Le temps n'a pas besoin d'une jauge** : il passe par l'**humeur** existante (Sylvie ou le proche) et un **statut** à 3 valeurs (« normal », « du temps », « prenant ») qui ne change que la règle d'usure de janvier.
5. **Chaque carte affiche l'épargne possible avant → après** (« 1 150 F → 1 700 F par mois ») : c'est le cœur pédagogique, et il coûte une ligne.
6. **Équilibre garanti par R-MIROIR** : les voisins (Tata Livret compris) suivent les mêmes changements de salaire ; le classement ne bouge donc que par la **liquidité** (a-t-on dû vendre quand le revenu a baissé ?). Aucune option n'est « la bonne » au score.

| Proposition | Plaisir | Pédagogie | Coût |
|---|---|---|---|
| Variante minimale (§5.2) : 4 cartes, champ `salaire` existant, ligne « épargne possible » | moyen | fort (revenu, capacité d'épargne, investir en soi) | faible |
| Statut de temps (§3.3) | moyen (le temps libre se voit sur Sylvie) | moyen (le temps a un prix) | faible (1 champ, 1 règle en janvier, 1 ligne dans « Mon foyer ») |
| Suite différée de la PME (§2, K3 → K6) : un choix de 1987 qui revient en 1991 | fort (continuité entre chapitres, surprise juste) | fort (coussin de précaution face au chômage) | moyen (réutilise la notification différée des escargots) |
| Plan de départs de 1993 (K7) | fort (gros dilemme, somme d'un coup) | fort (prime unique contre salaire durable) | moyen |
| Regrouper préretraite (Michel), chômage partiel (Christine), professeure des écoles (Sophie) sous « carrière » | faible | moyen | faible (déjà prévus en docs/39) |

---

## 1. Ce que la carrière apporte

### 1.1 Au plaisir

- **Des décisions qui durent** : aujourd'hui, seuls C07 (CNAM) et les projets ont un effet à long terme ; la plupart des cartes sont « payer ou non, une fois ». Une carte de carrière change chaque mois qui suit : on la ressent.
- **Un dilemme universel** : « gagner plus ou vivre mieux » parle à tout le monde, même au joueur qui ne connaît rien aux placements. Bonne porte d'entrée pour le débutant.
- **La continuité entre chapitres** (décidée par le joueur, D-J1) : un choix de 1987 qui revient en 1991 est exactement le plaisir que la partie longue rend possible (comme la promotion CNAM de docs/39 §2.2).
- **De l'humour et des personnages** : le chef d'atelier, la PME de Vierzon, Sylvie et ses mercredis.

### 1.2 À l'apprentissage (sans jamais conseiller une carrière)

| Notion | Ce que le joueur vit | Phrase « pourquoi » (banquier, ≤ 25 mots, à valider) |
|---|---|---|
| Capacité d'épargne | la ligne « épargne possible : avant → après » sur chaque carte | « Ce qui compte pour épargner, ce n'est pas le salaire, c'est ce qu'il en reste à la fin du mois. » |
| Train de vie | une hausse de salaire épargnée ou dépensée par les cartes suivantes | « Une augmentation qu'on ne dépense pas devient de l'épargne chaque mois. » |
| Temps libre | moins de revenu, Sylvie plus heureuse, moins de cartes de réconciliation | « Le temps libre a un prix : il se paie en épargne, mois après mois. » |
| Chômage, coussin | la suite de la PME ou le plan de départs : revenu en baisse pendant 6 mois | « Une épargne disponible évite de vendre ses placements au mauvais moment quand le revenu baisse. » (lien avec l'étoile « Le coussin ») |
| Formation | coût maintenant, salaire plus tard, sans garantie (C07, K5) | existant (C07) |
| Somme reçue d'un coup | la prime de départ de 1993 | « Une prime se reçoit une fois ; un salaire plus bas, c'est tous les mois. » |
| Retraite, PER | préretraite de Michel ; ligne d'information sur le revenu qui baisse à la retraite | contenu du banquier (docs/38 §6 : PER en **notion**, jamais présenté comme produit à acheter) |

**Le levier principal** : la carrière fait comprendre que l'investissement ne commence pas en Bourse mais dans la marge entre revenu et dépenses. C'est la leçon la plus utile à un débutant, et le jeu ne la montre pas encore.

---

## 2. Cartes de carrière d'exemple

Notations : **M** = salaire mensuel du profil au mois de la carte ; « épargne » = épargne possible du mois (Gérard : 15 % avec un enfant). Montants pour Gérard, technicien (M ≈ 7 200 F en 1985, 7 900 F en 1987, 8 900 F en 1989, 9 800 F en 1993 ; C). Nature de toutes les cartes : `neutre` (comme C07) pour ne pas peser sur les titres fourmi et cigale.

**Règle d'équilibre** : chaque option doit gagner sur au moins un des 3 axes (**argent**, **temps et humeur**, **sécurité et avenir**) et perdre sur au moins un. Contrôle de relecture : si une option gagne sur deux axes sans rien perdre, on la corrige.

### 2.1 Chapitre 1984-1988

| id | Créneau (existant) | Titre | Texte (≤ 30 mots) | Choix a | Choix b | Équilibre |
|---|---|---|---|---|---|---|
| **K1** | S5 (06-09/1986) | Les cours du soir | **= C07 existant**, inchangé | 0,35 M ; humeur −1 ; salaire + 4 % en 01/1988 | 0 | a : avenir + / argent et temps − ; b : l'inverse |
| **K2** | S3 (08-10/1985), candidate avec C04 / C05, `requiert_enfant`, `foyer: couple` | Le mercredi de Sylvie | Sylvie peut passer à quatre jours par semaine pour garder {prenoms} le mercredi. Son salaire baisse d'un cinquième. | **4/5** : revenu du foyer − 0,08 M/mois ; humeur +1 ; statut **du temps** ; « Le mercredi, c'est sacré. » ; épargne ≈ 1 080 → 500 F | **Temps plein** : garde du mercredi + 0,03 M/mois ; humeur −1 ; « Encore la nounou… » ; épargne ≈ 1 080 → 860 F | a : temps + / argent − ; b : argent + / temps − |
| **K3** | S6 (02-04/1987), candidate avec C09 / C10 | L'offre de la PME | Une PME d'électronique de Vierzon vous propose {pct} % de plus. Une heure de route, et une petite entreprise reste plus fragile qu'une grande. | **Partir** : salaire + 10 % ; humeur −1 ; statut **prenant** ; suite possible K6 ; épargne ≈ 1 190 → 1 980 F | **Rester** : 0 ; humeur 0 ; « On connaît la maison. » | a : argent + / temps et sécurité − ; b : l'inverse |

Gabarits d'affichage communs, sous les deux choix (ligne grise) : « Épargne possible : {epargne_avant} → {epargne_apres} par mois. »

### 2.2 Chapitre 1989-1993

| id | Créneau (docs/39 §14) | Titre | Texte (≤ 30 mots) | Choix a | Choix b | Équilibre |
|---|---|---|---|---|---|---|
| **K4** | S2 (10/1989), candidate avec C03 / C02 / C12 | Le poste itinérant | Votre entreprise cherche un technico-commercial : voiture de service, {pct} % de plus, trois nuits par semaine à l'hôtel. | **Accepter** : salaire + 15 % ; humeur −1 ; statut **prenant** ; « Encore une valise… » | **Rester à l'atelier** : 0 ; « Le soir, tu es là. » | a : argent + / temps − ; b : l'inverse |
| **K5** | S5 (02/1991) : **remplace C07 « formation informatique »** de docs/39 (même archétype A8) | Le congé formation | Dix mois payés à {pct_conge} % pour devenir technicien en informatique. À la sortie, un poste mieux payé, si tout va bien. | **Partir en formation** : salaire − 10 % pendant 10 mois, puis + 8 % (01/1992) ; humeur −1 | **Pas maintenant** : 0 | a : avenir + / argent court terme et temps − |
| **K6** | aucune pause : notification persistante de la maison, 06/1991 | La PME ferme | (si K3 a, **1 partie sur 2**, graine de vie) « La PME de Vierzon a fermé. Six mois d'indemnités, puis votre ancien employeur vous reprend, sans les {pct} %. » | — | — | revenu à 70 % du salaire pendant 6 mois (C, banquier), puis salaire d'avant K3 ; statut normal ; humeur −1 |
| **K7** | S9 (04/1993), candidate avec C13 / C12 | Le plan de départs | La crise touche l'usine : départs volontaires. Une prime de {prime} pour partir. Ceux qui restent n'auront pas d'augmentation cette année. | **Partir** : prime 8 M d'un coup ; 6 mois à 75 % ; puis nouvel emploi à − 8 % ; humeur 0 | **Rester** : pas d'indexation en 01/1994 ; humeur −1 ; « L'ambiance est lourde. » | a : argent immédiat + / revenu durable − ; b : sécurité + / argent et humeur − |

Rappels déjà prévus en docs/39, rangés sous « carrière » (aucun coût de conception de plus) :

| Profil | Événement | Choix |
|---|---|---|
| Gérard | promotion 03/1990 si K1 (C07) pris : + 6 % | sans choix (scripté) |
| Sophie | 09/1991 professeure des écoles : + 8 % | sans choix, sans pause |
| Christine | 04/1993 chômage partiel de Patrick : − 1 500 F pendant 3 mois | sans choix |
| Michel | **K8** 04/1993 « La préretraite » : partir à 56 ans, revenu − 30 %, humeur +2, statut **du temps** ; ou rester. Ligne du banquier : à la retraite, le revenu baisse ; le PER en notion (docs/38 §6) | choix |

### 2.3 Variantes par profil (à écrire au lot concerné)

- **Martine** (cadre, 1984) : K3 → « Le chasseur de têtes » (+ 15 %, statut prenant) ; K2 → « Le 4/5 de Martine » (son propre salaire − 20 % : − 0,2 M).
- **Bernard, Sophie** (célibataires, R-SEUL) : K2 sautée (`foyer: couple`) ; K3 / K4 → « La mutation » (Marseille pour Bernard, prime + 10 %, le proche s'éloigne : humeur −1). Sophie est fonctionnaire : pas de PME ni de plan de départs (K3 et K7 sautées), K4 → « La direction d'école » (+ indemnité, statut prenant).
- **Création d'entreprise** (« se mettre à son compte », revenu irrégulier) : **pas avant 1994-1998** ; elle demande un revenu variable mois par mois, donc du code, et elle est la plus proche du « jeu de gestion de carrière » à éviter.

---

## 3. Intégration aux moteurs existants

### 3.1 Cartes du foyer (moteur réutilisé)

- Les cartes K sont des **cartes du foyer** ordinaires (`type: "conso"`, nature `neutre`) avec un champ `carriere: true` (picto mallette, rangement « maison » dans l'historique).
- Champs nécessaires, du plus simple au plus coûteux :
  1. `salaire: { pct, des }` : **existe déjà** (C07). À vérifier par le chef de projet : `pct` négatif et `jusqua` (fin de l'effet, pour K5 et l'indemnité).
  2. `depenses_M_mois` : variation durable des dépenses (K2 : garde, 4/5 de Sylvie modélisé en dépense car son salaire n'est pas séparé).
  3. `statut` : `normal | temps | prenant` (§3.3).
  4. `suite` : notification différée tirée à la graine (K6) : **reprend le mécanisme des escargots** (`delai`, texte, effet), plus une probabilité.
  5. `versement` : somme reçue d'un coup (K7 : prime), comme l'héritage (`recevoir_tous`).
- **R-MIROIR** : tous les effets de salaire, de dépenses et de prime sont **recopiés chez les voisins** (comme C07 aujourd'hui). Seule la suite K6 dépend du choix ; les voisins ont fait le même choix, donc la subissent aussi. Le classement ne bouge que si le joueur a dû vendre (vente automatique) faute de coussin.

### 3.2 Projets et cadence

- **Aucune pause ajoutée** : K2, K3, K4, K7 sont des **candidates** dans des créneaux existants ; K5 remplace une carte du même archétype ; K6 est une notification. Durée du chapitre inchangée (≈ 20 min).
- Plafond : **au plus 3 moments de carrière avec pause par chapitre** (cartes + promotion scriptée), **au moins 4 mois entre deux**. Le plafond se vérifie au tirage des créneaux : en 1989-1993, si K4, la promotion (03/1990), K5 et K7 tombaient tous, K7 laisse sa place à l'autre candidate de S9.
- R-CADENCE inchangée (jamais deux interruptions le même mois ni deux mois de suite ; pas de carte le mois avant une interruption datée).
- **Projets** : pas de lien direct. Effet indirect voulu : un revenu qui baisse pendant un projet en cours rend la jauge plus tendue ; la vente automatique existante fait le reste.
- **Assurance anti-cumul** : jamais une baisse de revenu (K6, K7 a) pendant les 3 mois avant l'échéance d'un projet ; si c'est le cas, la suite est décalée après l'échéance.

### 3.3 Le temps comme ressource : pas de nouvelle jauge

- **Aujourd'hui, le temps n'existe pas** dans le jeu ; l'humeur de Sylvie (ou du proche) est le seul indicateur de qualité de vie, et sa seule conséquence en argent est la carte de réconciliation C00.
- **Proposition** : pas de jauge (une 2e valeur cachée serait illisible et contraire au « rester simple » du joueur). À la place, un **statut** qui ne change que la règle de janvier :

| Statut | Règle du 1er janvier | Ce que le joueur voit |
|---|---|---|
| normal | usure actuelle : −1 si l'humeur est positive | — |
| **du temps** (K2 a, K8 a) | **pas d'usure** : le bonheur ne s'use pas | ligne « Mon foyer » : « Le mercredi en famille » |
| **prenant** (K3 a, K4 a) | **−1 quelle que soit l'humeur** (borne −3) | ligne « Mon foyer » : « Souvent absent » |

- Effet : le statut prenant mène, en 2 ou 3 ans, à Sylvie fâchée, donc à la carte C00 (0,35 M) : **le temps a un prix en argent**, sans aucune nouvelle mécanique.
- Un seul statut à la fois ; la carte de carrière suivante le remplace ; K6 et la fin du chapitre ne le remettent pas à zéro.
- Option UX (facultative) : un détail du décor (la voiture de Gérard absente le soir si prenant ; Gérard au jardin le mercredi si du temps).

---

## 4. Risques et variante minimale

### 4.1 Risques

| Risque | Parade |
|---|---|
| Dériver vers un jeu de gestion de carrière | 2 à 3 cartes par chapitre, 2 choix, pas de compétence, de poste ni de CV ; création d'entreprise reportée |
| Redondance avec les cartes du foyer | la carte de carrière se distingue par un effet **durable** (salaire, statut) et la ligne « épargne possible » ; plafond de 3 |
| Pauses en trop | aucune pause ajoutée (candidates dans des créneaux existants, suites en notification) |
| Une option dominante | règle des 3 axes (§2) ; R-MIROIR neutralise l'argent au classement ; nature `neutre` hors titres |
| Conseil de carrière déguisé | « pourquoi » sur le budget, jamais sur le choix ; pas de « bonne réponse » au bilan ; aucun titre ni étoile lié |
| Chômage vécu comme injuste | jamais tiré au hasard sans choix préalable : K6 découle de K3, K7 est un choix ; Christine et Michel sont des faits annoncés du profil |
| Pari déguisé (K6 « 1 sur 2 ») | le gain de K3 est certain, seul le risque est incertain, et il est dit dans le texte ; l'enjeu est la précaution, pas la chance |
| R-SEUL | cartes marquées `foyer` ; humeur du proche ; K2 sautée pour un célibataire |
| R-MIROIR mal compris (« pourquoi mon rang ne bouge pas ? ») | rappel déjà présent dans LA RUE : le classement mesure les placements ; à confirmer par le client |
| Mauvais calibrage du budget de Gérard (jumeaux : 6 % d'épargne) | K2 a sur un foyer à jumeaux rendrait l'épargne négative : option grisée (règle « pas les moyens » existante) ou écart réduit à − 0,04 M |

### 4.2 Variante minimale (recommandée pour un premier essai)

- **4 cartes** : K2 et K3 (1984-1988), K4 et K5 (1989-1993) ; K1 existe déjà.
- **Champs** : `salaire` (existant, avec `pct` négatif) et `depenses_M_mois` ; **pas** de statut, **pas** de suite K6, **pas** de K7.
- **Une ligne** « Épargne possible : avant → après » sur ces cartes.
- Le temps reste porté par l'humeur immédiate (±1).
- Coût : **faible** (données + 1 gabarit + 1 champ) ; aucune pause en plus. Si le joueur aime, on ajoute le statut, puis K6 et K7.

---

## 5. Cohérence avec les décisions du joueur

- **Mariage selon l'âge et le profil** : la carrière n'en dépend pas et ne le déclenche pas ; seules les cartes `foyer: couple` exigent un conjoint ; le mois du mariage n'accueille pas de carte de carrière (R-CADENCE suffit).
- **Mort liée à l'âge** (R-FIN) : la carrière n'a **aucun effet** sur la mortalité (pas de « stress qui tue ») ; le statut prenant ne touche que l'humeur. La préretraite de Michel prépare la note de décès (revenus plus bas, transmission) sans la changer.
- **Retraite** : Gérard n'a 60 ans qu'en 2018 : rien à faire avant les chapitres des années 2010 ; la retraite y sera un événement scripté par profil, pas un choix de carrière.
- **Débutant / intermédiaire, rester simple** : 2 choix, 1 chiffre par choix (« + {montant} par mois »), 1 ligne « épargne possible », 1 phrase « pourquoi ». Le niveau d'explication (plus tard) n'ajoute qu'au texte du banquier, jamais de choix.
- **Pas de leçons trop poussées** (retour du 18/11 sur la privatisation) : pas de droit du travail, pas de calcul d'indemnités affiché, pas de régime de retraite détaillé.
- **Jean-Mi** : dosage inchangé ; il peut commenter sans effet (« Moi, je suis payé à la commission. Les bons mois. »).

---

## 6. Questions pour le client et le joueur

1. Variante minimale d'abord (4 cartes, sans statut) ou statut de temps tout de suite ?
2. K6 (la PME qui ferme, 1 partie sur 2) : accepté comme risque de vie, ou jugé trop proche du hasard ?
3. K7 (plan de départs 1993) : gardé pour 1989-1993, ou réservé au chapitre suivant pour ne pas charger le lot 10 ?
4. R-MIROIR : les voisins suivent-ils bien les choix de carrière (le classement reste « placement seul ») ?
5. À valider par le banquier : indemnités (70-75 %), prime de départ (8 M), congé formation (CIF, taux de maintien), revenu de la préretraite, ligne retraite / PER.
