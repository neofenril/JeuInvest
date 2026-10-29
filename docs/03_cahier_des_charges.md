# 03 : Cahier des charges V1 de JeuClaude

> Rédigé par le client. **C'est la référence unique pour le développeur.** En cas de contradiction avec `00_vision_client.md`, `01_enveloppes_france.md`, `02_rouages_bourse.md` ou `04_ux_design.md`, **ce document l'emporte**.
> Les autres documents servent de source pour les données et les maquettes. On y renvoie au lieu de les recopier : « 01 §7.4 » désigne la section 7.4 de `01_enveloppes_france.md`.
> Priorités, dans cet ordre : **1) s'amuser, 2) apprendre**. Règle de conduite : **si une règle n'est pas écrite ici, le développeur choisit la solution la plus simple.**

---

## 1. Arbitrages du client

### 1.1 Les 5 points soulevés par le designer UX (04 §9)

| # | Sujet | Décision | Motif en une ligne |
|---|---|---|---|
| A1 | Barre de répartition au lieu d'un camembert | **Accepté**, partout (jeu et bilan) | Elle prend une ligne, se lit mieux en petit et se fait en CSS pur. |
| A2 | Petits événements de vie en notification, sans pause | **Accepté** (règle modale ou notification de 04 §3.6) | Environ 50 pauses forcées tueraient le rythme ; on vise environ une interruption par an. |
| A3 | Les 3 périodes en cartes d'abord, l'année libre ensuite | **Accepté, et l'année libre passe en V2** (bouton masqué) | Un champ vide est un mauvais premier contact, et seules les 3 périodes ont des données fiables et scénarisées. |
| A4 | Pas d'euros constants en cours de partie | **Accepté** : la baguette sert d'unité de pouvoir d'achat en jeu, les « € d'aujourd'hui » apparaissent au bilan | La baguette est concrète et drôle ; le calcul officiel (IPC) reste en coulisses et sert au bilan. |
| A5 | La frise n'annonce jamais les krachs | **Accepté** | Annoncer le krach donnerait la réponse et détruirait la leçon. Seules les nouveautés produits sont annoncées, en mystère (★). |

### 1.2 Fiscalité : la simplification proposée par le banquier (01 §7.4)

| # | Décision | Motif |
|---|---|---|
| A6 | **On retient la table « taux unique » de 01 §7.4 telle quelle**, dont **16 % sur toutes les plus-values, dividendes et coupons hors PEA de 1978 à 1997**, puis 26 % de 1998 à 2007, etc. **L'option fidèle (exonération sous un seuil de cessions annuelles) passe en V2.** | Sans cette simplification, l'avantage du PEA serait invisible en 1992-1997. C'est une simplification assumée, signalée dans la bulle (?) de l'impôt : « Simplifié : à l'époque, les petites ventes étaient souvent exonérées. » |

### 1.3 Les périodes (02 §7 Q1)

| # | Décision | Motif |
|---|---|---|
| A7 | **Validées : P1 « Les années fric » de janv. 1978 à déc. 1992 ; P2 « De l'euphorie à la crise » de janv. 1996 à déc. 2010 ; P3 « L'ère des ETF » de janv. 2011 à déc. 2025.** 180 mois chacune, sans chevauchement. | Elles font 15 ans pile, sans doublon, et leur premier choc tombe après le tutoriel. |
| A8 | Les accroches des cartes reprennent les versions **sans divulgâcheur** du boursier (02 §7 Q1, dernier point). Elles remplacent celles de la maquette 04 §3.2, qui cite « krach de 87 ». | C'est cohérent avec A5. |
| A9 | Les Trente Glorieuses (1950-1977) sont **hors V1**. | Les données sont reconstituées (certitude C) et la période est moins dramatique pour un débutant. |

### 1.4 Autres arbitrages pour tenir en une passe

| # | Décision | Motif en une ligne |
|---|---|---|
| A10 | **Durée fixe de 15 ans.** Le choix 10/15/25 ans du récapitulatif (04 §3.2, étape 4) est supprimé. | Les périodes font exactement 15 ans et les données s'arrêtent en 2025. |
| A11 | **Un seul type d'ordre, « au cours du mois »** (02 §7 Q5). Pendant une modale, le cours affiché est celui du mois. | C'est simple, pas faux, et impossible à tricher. |
| A12 | **Les cours sont générés de façon déterministe** (graine fixe par période) : toutes les parties d'une même période voient les mêmes cours. L'aléa vient des événements de vie. | « Rejouer autrement » est équitable et les cours sont vérifiables. |
| A13 | **L'emprunt d'État est un placement à taux fixe garanti, sans cours** (02 §7 Q3, encadré). | On garde la leçon « 16 % fixe en 1981 » sans modéliser les prix des obligations. |
| A14 | **4 actions par période** au lieu de 5 (liste au §4). | Le joueur garde 7 lignes de placements au maximum, et il y a moins de données à calibrer. |
| A15 | Les droits de garde, le petit crédit à la consommation, le LEP, le Codevi, l'assurance-vie, l'or et l'effet fiscal de la loi Monory sont **hors V1**. | Chacun ajoute une règle sans changer la boucle de plaisir. |
| A16 | **Tata Livret respecte le plafond du Livret A** : l'excédent reste sur son compte courant (choix du banquier, 01 §7.2). | Un témoin ne doit pas avoir accès à quelque chose que le joueur n'a pas. |
| A17 | **La valorisation au bilan est brute**, sans impôt latent, pour le joueur comme pour les 3 témoins (02 §7 Q6). | La même règle s'applique à tous, et c'est la plus simple. |
| A18 | La carte de **rappel à 12 mois** (04 §3.8) **entre dans la V1**. | C'est 30 lignes de code pour la meilleure leçon du jeu. |
| A19 | Le **montant des objectifs est calibré automatiquement** à partir de Cousin Indice (§7.7). | On évite des montants arbitraires, faux d'une période ou d'un profil à l'autre. |

---

## 2. Contraintes techniques (non négociables)

1. **Lancement** : le joueur double-clique sur `jeu/index.html` et le jeu s'ouvre dans le navigateur par défaut (Edge ou Chrome sous Windows). Il n'y a **rien à installer**, aucun serveur, et le jeu fonctionne **hors ligne**.
2. Le jeu est écrit en **HTML, CSS et JavaScript purs**, sans bibliothèque ni CDN. Les graphiques sont en SVG, les confettis en canvas (04 §6, §7).
3. **Pas de `fetch` ni de `type="module"`** : ils sont bloqués en `file://`. On utilise uniquement des balises `<script src="…">` classiques. Les données sont des fichiers `.js` qui déclarent une variable globale, par exemple `window.DONNEES_P1 = {…}`.
4. **Les données sont séparées du code**, dans `jeu/data/` : marché, taux, inflation, baguette, salaires, produits, événements de marché, événements de vie, titres, leçons, glossaire. Corriger un chiffre ne doit pas exiger de toucher au moteur.
5. **En interne, tous les montants sont en euros courants.** À l'écran, ils s'affichent en francs (× 6,55957) avant 2002, en double affichage de 1999 à 2001 et le moteur d'affichage gère la bascule (04 §1 Q6, §4.4).
6. Une **sauvegarde unique** et les options sont stockées dans `localStorage` (04 §3.12). Si `localStorage` est indisponible, le jeu fonctionne quand même, sans « Continuer ».
7. Le jeu est **déterministe à partir de deux graines** : la graine des cours (fixe par période) et la graine de vie (tirée à la création de la partie et enregistrée). On utilise un PRNG maison (par exemple mulberry32), jamais `Math.random()` pour le moteur.

---

## 3. La boucle de jeu définitive

### 3.1 Démarrage (moins d'une minute)

Écran titre (04 §3.1), puis création en 3 cartes et un récapitulatif (04 §3.2) :
1. **Période** : P1, P2 ou P3. Accroches de 02 §7 Q1 et « secousses » ●●●○ / ●●●● / ●●●○. La mini-courbe est celle de l'indice de la période.
2. **Profil** : jeune salarié, cadre pressée ou héritier (§5). Les prénoms changent selon l'époque (04 §3.2, étape 2).
3. **Objectif** : battre l'inflation (par défaut), acheter sa maison, ou une retraite tranquille (§7.7).
4. **Récapitulatif** : la phrase de synthèse, la case « Me guider » (cochée à la première partie) et la case « Mêmes événements de vie » (seulement après « Rejouer »), puis le bouton « C'est parti ! ». Pas de choix de durée (A10).

### 3.2 Le temps

- **1 tour = 1 mois**, et une partie dure **180 mois**.
- Vitesses : pause, ×1 = 4 s par mois, ×2 = 2 s, ×3 = 1 s (04 §4.2).
- Pause automatique : toute modale, l'ouverture du tiroir marché (option), une fenêtre masquée et les étapes bloquantes du tutoriel.
- Après une modale de marché, le jeu **reste en pause**. Après les autres modales, il reprend à la vitesse précédente.

### 3.3 Ordre de traitement d'un mois (le cœur du moteur)

Au passage au mois `m` :
1. **Nouveaux cours** du mois `m` (indice, actions, valeurs liquidatives des fonds, ETF).
2. **Revenus** : salaire (ou indemnité chômage) crédité sur le compte courant. En janvier, le salaire est indexé (§5.3).
3. **Dépenses** : loyer et vie courante débités (§5.2).
4. **Versements automatiques** exécutés au cours du mois. Si le compte est insuffisant, le versement est sauté et une notification le signale (04 §3.4).
5. **Revenus des placements** : dividendes en mai (§7.4), intérêts du livret calculés mensuellement et crédités en décembre, coupons d'emprunt à la date anniversaire.
6. **Agios** si le compte est négatif ; contrôle de la faillite (§7.6).
7. **Déblocages** de produits datés : notification persistante (04 §3.7).
8. **Événements**, **au plus une modale par mois**, avec la priorité marché > vie > euro (04 §3.5). L'excédent est reporté au mois suivant. Les notifications ne sont pas limitées (3 visibles au maximum).
9. **Rappel à 12 mois** si un choix de marché a eu lieu 12 mois plus tôt.
10. En janvier : **bilan annuel** de l'année écoulée (04 §3.8) et sauvegarde.
11. Contrôle de l'**objectif** (atteint plus tôt : modale de 04 §3.10) et de la **fin de partie**.

Les mêmes étapes 2 à 6 sont appliquées aux **3 témoins**, avec leurs propres règles (§7.8).

### 3.4 Ce que fait le joueur

- **Lancer, ralentir ou mettre en pause** le temps.
- **Acheter, vendre, déposer ou retirer** dans le tiroir marché (04 §3.4), avec un montant saisi en argent et des frais visibles avant la confirmation.
- **Programmer un versement automatique** mensuel sur un produit.
- **Réagir aux événements** : 2 ou 3 choix dans les modales (journal ou courrier).
- **Lire** le budget, le coussin, l'objectif, la courbe et la répartition (04 §3.3).

### 3.5 Fin de partie

La partie se termine dans l'un de ces 4 cas :
1. **Fin du 180e mois** : bilan.
2. **Objectif atteint plus tôt** (maison ou retraite) : le joueur choisit entre « Voir mon bilan » et « Continuer en partie libre » (04 §3.10).
3. **Faillite** (§7.6) : courrier humoristique, puis bilan en sépia (04 §3.10).
4. **Abandon** par le menu ☰, après confirmation.

Le **bilan** (04 §3.11) présente : le chiffre en € d'aujourd'hui, la course des 4 barres et les 4 courbes, la jauge d'objectif, les étoiles, le titre, les 3 leçons et le bouton « Rejouer la même période autrement » (même période, même profil, même objectif, **même graine de vie**).

---

## 4. Produits par période (liste exacte de la V1)

Règle générale : un produit est **invisible avant sa date** et apparaît par une notification « Nouveau » (04 §3.7). L'enveloppe **PEA** se choisit dans le tiroir au moment de l'achat d'un produit éligible.

### P1 « Les années fric » (janv. 1978 → déc. 1992)

| Produit | Disponible | Éligible PEA | Source des données |
|---|---|---|---|
| Compte courant (0 %) | départ | — | 01 §7.1 |
| Livret A | départ | — | taux 01 §4.1, plafond 01 §4.2 |
| Emprunt d'État à taux fixe 10 ans | départ | non | taux long de l'année d'achat, 02 §4.2 |
| SICAV actions France | départ | oui (à partir de 07/1992) | 02 §7 Q3 et Q6 |
| Elf Aquitaine | départ | oui | profil 02 §7 Q3 |
| L'Oréal | départ | oui | 02 §4.5 et §7 Q3 |
| Peugeot | départ | oui | 02 §4.5 et §7 Q3 |
| Saint-Gobain | **déc. 1986**, au prix fixe de 310 F (privatisation) | oui | 01 §3.2, 02 §4.5 |
| **PEA** (enveloppe) | **juil. 1992** | — | plafond de 600 000 F, 01 §1.2 |

L'indice s'appelle « Indice de la Bourse de Paris » jusqu'en mai 1988, puis « CAC 40 » à partir de juin 1988, avec une notification (01 §5.3, point 1). Aucune des 4 actions n'est nationalisée en 1982 : **pas de mécanique de nationalisation en V1.**

### P2 « De l'euphorie à la crise » (janv. 1996 → déc. 2010)

| Produit | Disponible | Éligible PEA | Source |
|---|---|---|---|
| Compte courant (0 %) | départ | — | 01 §7.1 |
| Livret A | départ | — | 01 §4.1, §4.2 |
| Emprunt d'État (OAT) à taux fixe 10 ans | départ | non | 02 §4.2 |
| SICAV actions France | départ | oui | 02 §7 Q3 |
| L'Oréal | départ | oui | 02 §4.5 |
| Total | départ | oui | 02 §4.5 |
| Alcatel | départ | oui | 02 §4.5 |
| France Télécom | **oct. 1997**, à 27,75 € (182 F) | oui | 01 §3.2, 02 §4.5 |
| **ETF CAC 40** | **janv. 2001** | oui | 02 §7 Q3 |
| **PEA** | départ | — | plafonds datés, 01 §1.2 |

### P3 « L'ère des ETF » (janv. 2011 → déc. 2025)

| Produit | Disponible | Éligible PEA | Source |
|---|---|---|---|
| Compte courant (0 %) | départ | — | 01 §7.1 |
| Livret A | départ | — | 01 §4.1, §4.2 |
| Emprunt d'État (OAT) à taux fixe 10 ans | départ | non | 02 §4.2 (coupon minimal de 0 %) |
| ETF CAC 40 | départ | oui | 02 §7 Q3 |
| LVMH | départ | oui | 02 §4.5 |
| TotalEnergies | départ | oui | 02 §4.5 |
| BNP Paribas | départ | oui | 02 §4.5 |
| Orange | départ | oui | 02 §4.5 |
| **PEA** | départ | — | plafond de 150 000 € à partir de 2014, 01 §1.2 |

---

## 5. Profils de départ

### 5.1 Les 3 profils

| Profil | Prénoms P1 / P2 / P3 | Âge | Salaire net mensuel au départ | Capital de départ |
|---|---|---|---|---|
| Jeune salarié | Gérard / Sébastien / Kevin | 22 | colonne « Jeune salarié » de 01 §7.3, interpolée à l'année de départ | 0 |
| Cadre pressée | Martine / Nathalie / Julie | 30 | colonne « Cadre pressée » | 0 |
| Héritier | Bernard / Christophe / Thomas | 25 | colonne « Héritier : salaire » | colonne « capital de départ » : **la moitié sur le compte courant**, l'autre moitié répartie entre **2 actions de la période** (« les actions de grand-père », sur le compte-titres) |

Les valeurs entre deux lignes du tableau sont interpolées géométriquement (01 §7.3).

### 5.2 Dépenses

- **Dépenses totales du mois** = salaire × (1 − taux d'épargne possible), selon le profil et la décennie (01 §7.3, dernière colonne du tableau des dépenses). Le reste est l'épargne disponible.
- Affichage sur deux lignes (04 §3.3) :
  - **Loyer** = salaire × part « Loyer » de la décennie, plus 3 points pour le jeune salarié et 5 points pour la cadre ;
  - **Vie courante** = le reste des dépenses totales.
- Les dépenses suivent le salaire : elles sont recalculées à chaque changement de salaire. Seuls les événements « naissance » et « déménagement » les modifient (§6.2).

### 5.3 Évolution du salaire

En janvier, le salaire est multiplié par `SMN[a] / SMN[a−1]` (01 §7.3). Les événements « augmentation » et « perte d'emploi » le modifient en plus (§6.2).

---

## 6. Événements retenus pour la V1

### 6.1 Événements de marché (historiques)

**La liste et les contenus sont exactement ceux de 02 §7 Q2** : 8 événements en P1, 8 en P2 et 7 en P3, avec leur mois, leur manchette, leur impact et leur leçon. L'explication de 40 mots au maximum est rédigée par le développeur à partir des colonnes « Impact » et « Leçon », **au présent et sans révéler l'issue** (02 §6.3). La leçon n'apparaît que dans le rappel à 12 mois et au bilan.

| Type (02 §7 Q2) | Affichage | Choix proposés |
|---|---|---|
| `−` | Modale journal (04 §3.5). `paper-spin` si l'impact est ≤ −25 %, sinon `paper-drop`. | Tout vendre / Ne rien faire / Renforcer. Si le joueur n'a aucune action : Rester à l'écart / Profiter des soldes. |
| `+` et `+ (piège)` | Modale journal, pastille verte | Encaisser mes gains / Ne rien faire / Suivre la foule |
| `+ (opportunité)`, c'est-à-dire une privatisation ou une introduction en bourse (Saint-Gobain 12/1986, France Télécom 10/1997, creux de 03/2003) | Modale journal | Souscrire ou Acheter (ouvre le tiroir, prérempli à 25 % du compte) / Ne rien faire |
| `− (silencieux)` (P1 n° 2, déc. 1979) | **Notification persistante**, sans pause | aucun |

Effet des choix :
- « Tout vendre » et « Encaisser » vendent toutes les actions, SICAV et ETF (pas le livret ni l'emprunt), avec une confirmation qui récapitule les frais et l'impôt (04 §3.5).
- « Renforcer » et « Suivre la foule » ouvrent le tiroir prérempli à 25 % du compte courant.
- Le choix est enregistré pour le rappel à 12 mois, l'étoile « sang-froid » et les leçons.

**Notifications de contexte sans pause** (04 §3.6) :
- P1 : changement de nom de l'indice (06/1988), création du PEA (07/1992).
- P2 : double affichage de l'euro (01/1999), **moment euro en modale** (01/2002, 04 §3.9), ETF (01/2001).
- P3 : Livret A à 0,75 % (08/2015) puis à 0,5 % (02/2020), flat tax (01/2018).

La loi Monory (07/1978) n'a **pas d'effet fiscal** en V1 : c'est une simple notification « Le saviez-vous ? ».

### 6.2 Événements de vie

**On retient 11 des 13 événements de 01 §7.6**, avec les effets et fréquences de ce tableau : n° 1 voiture, n° 2 panne d'électroménager, n° 3 perte d'emploi, n° 4 frais médicaux, n° 6 escargots, n° 7 prime, n° 8 augmentation, n° 9 héritage, n° 10 gain au jeu, n° 11 naissance (2 enfants au maximum), n° 13 déménagement. **Le divorce (n° 5) et le mariage (n° 12) passent en V2.**

| Règle | Valeur |
|---|---|
| Tirage | **Au lancement de la partie**, à partir de la graine de vie, on tire tout le calendrier des 180 mois. Il ne dépend pas des actions du joueur, pour que « Rejouer » soit équitable. Les montants sont exprimés en M (mois de salaire) et convertis au moment où l'événement survient. |
| Nombre | 1 à 3 événements par an ; au plus une perte d'emploi tous les 5 ans. |
| Coïncidence forcée | **Une fois par partie**, une panne de voiture (n° 1) au mois d'un événement de marché `−` (ou au mois suivant), après le 12e mois (01 §7.6). |
| Tutoriel | Une prime scriptée au mois 8 (04 §5.2, T7). |
| Modale ou notification | Modale si l'événement propose un choix, si son montant dépasse 1 M, ou s'il change durablement le budget (n° 3, 8, 11, 13). Sinon, notification (04 §3.6). |
| Escargots | Modale à 2 choix. Si le joueur accepte, 90 % de chances de perte totale (annoncée par courrier 6 à 12 mois plus tard), 10 % de chances de récupérer 1,5 fois la mise. L'issue est tirée avec la graine. Les témoins refusent toujours. |
| Perte d'emploi | Salaire à 65 % pendant 6 à 12 mois, puis retour au salaire d'avant, indexé. |
| Naissance | Dépenses de vie courante augmentées de 9 % du salaire (12 % de coût moins 3 % d'allocations), définitivement. |
| Compte insuffisant | Le courrier propose « Vendre un placement… » (liste avec la variation de chaque ligne) ou « Passer à découvert » (04 §3.6, cas 2). |

---

## 7. Règles de calcul

### 7.1 Indice et inflation

- **Indice** : les clôtures annuelles de 02 §4.2 sont des **ancrages durs**, ainsi que les points mensuels des crises de 02 §4.4. Les 180 mois sont générés par un **pont brownien en log** avec des tirages de Student (ν = 4) et une volatilité mensuelle de 4 à 5 % en temps normal, 8 à 12 % en crise (02 §6.2, §7 Q3).
- **IPC** : `IPC[a] = IPC[a−1] × (1 + inflation[a])` avec l'inflation de 01 §4.4 et `IPC[2025] = 100`, interpolé géométriquement au mois.
- **€ d'aujourd'hui** = montant en € × `IPC[2025] / IPC[mois]` (01 §7.2). Cette valeur n'apparaît **qu'au bilan** (A4).
- **Baguette** : prix de 01 §7.3 bis, interpolé linéairement au mois. Le **patrimoine en baguettes** est égal au patrimoine divisé par le prix de la baguette du mois.

### 7.2 Actions

- Log-prix = `beta × log(indice) + résidu`. Le résidu est un pont brownien qui passe par les **ancrages propres à l'action** : bêta et volatilité spécifique de 02 §4.5.
- Les ancrages viennent de 02 §4.5. **Quand seul un profil qualitatif existe** (P1, 02 §7 Q3), le développeur fixe des ancrages annuels qui respectent ce profil, et le critère d'acceptation CA-22 le vérifie.
- Les prix sont **ajustés** (pas de division de nominal en V1). Le prix de départ est arrondi à une valeur plausible de l'époque.
- La génération est faite **au chargement**, avec la graine fixe de la période (A12).

### 7.3 Fonds, ETF, livret, emprunt

| Produit | Règle |
|---|---|
| SICAV actions France | `VL(m) = VL(m−1) × I(m)/I(m−1) × (1 + d/12) × (1 − 1,5 %/12)`, où `d` est le rendement du dividende de l'année (02 §4.2). **Frais d'entrée de 2 %**, sans courtage, et vente sans frais. Les parts sont fractionnables. |
| ETF CAC 40 | Même formule, avec des frais de gestion de **0,25 %/an** et sans frais d'entrée. Le courtage est celui des actions (§7.5), sans TTF. Les parts sont fractionnables. |
| Livret A | Taux daté de 01 §4.1. Intérêts mensuels = solde de fin de mois × taux / 12, cumulés et **crédités le 31/12**. **Plafond daté** (01 §4.2) : un dépôt au-delà est refusé, avec un message. Ni frais ni impôt. |
| Emprunt d'État | Chaque achat est une **tranche** au taux long de l'année d'achat (02 §4.2, plancher 0 %). Le coupon annuel est versé à la date anniversaire et taxé (§7.4). Le remboursement se fait au nominal après 10 ans. **Revente possible à tout moment, au nominal** (simplification A13). Sans frais. |
| Compte courant | 0 %. Découvert : §7.6. |

### 7.4 Fiscalité (A6)

- **Table unique : 01 §7.4.** Le taux s'applique **au moment de l'encaissement** : dividende, coupon, plus-value à la vente.
- **Plus-value** = prix de vente net de frais − prix de revient moyen pondéré (frais d'achat inclus). Si la plus-value est négative, l'impôt est nul et la moins-value n'est pas reportée.
- **Dividendes** : versés en **mai**. Montant = valeur de la ligne × (rendement du dividende de l'année (02 §4.2) + écart propre à l'action), avec un plancher à 0. Écarts : Elf, Total et TotalEnergies +1,5 pt ; Orange et France Télécom +2 pt ; BNP +1 pt (0 en 2009 et en 2020) ; L'Oréal −1,5 pt ; LVMH −1 pt ; Alcatel −1,5 pt ; Peugeot et Saint-Gobain 0. Les dividendes sont crédités sur le compte courant. Ils sont taxés au taux du compte-titres sur un compte-titres, à **0 % dans un PEA** (simplification). L'indice étant un indice de prix, il n'y a pas d'ajustement du cours.
- **PEA** : l'horloge démarre au **premier versement**. Une vente après 5 ans est taxée à la colonne « PEA après 5 ans » ; une vente avant 5 ans, au taux du compte-titres. Il **n'y a pas de clôture en V1** : une bulle (?) le précise. Plafond daté sur le cumul des versements.
- **Écran de vente** : il affiche « Dans un PEA de plus de 5 ans, vous auriez payé : X » dès que le PEA existe (01 §7.4, 04 §3.4).

### 7.5 Frais (une seule formule)

`frais = max(minimum, taux × montant)`, appliquée à l'achat et à la vente des actions et des ETF.

| Période | Taux (impôt de bourse inclus) | Minimum | TTF (achats d'actions seulement, pas des ETF) |
|---|---|---|---|
| 1978 → 1999 | 1,3 % | 50 F (7,62 €) | — |
| 2000 → 2007 | 0,8 % | 10 € | — |
| 2008 → 2018 | 0,5 % | 5 € | 0,2 % à partir du 01/08/2012, 0,3 % à partir du 01/01/2017 |
| 2019 → 2025 | 0,1 % | 1 € | 0,3 %, puis 0,4 % à partir du 01/04/2025 |

Il n'y a pas de droits de garde en V1 (A15). Le total des frais payés est cumulé pour la leçon du bilan.

### 7.6 Découvert et faillite (01 §7.6)

- Découvert toléré : **1 M** (un mois de salaire). Agios mensuels = |solde| × taux / 12, avec un taux de **20 %** jusqu'en 1990, **15 %** de 1991 à 2008 et **16 %** à partir de 2009.
- **Faillite** : 3 mois consécutifs au-delà du découvert toléré. Le bandeau « Découvert : N mois sur 3 » s'affiche dès le premier mois (04 §3.3, état « Découvert », en remplaçant « 6 » par « 3 »).
- Il n'y a pas de petit crédit en V1 (A15).

### 7.7 Objectifs

| Objectif | Condition de réussite | Cible affichée |
|---|---|---|
| Battre l'inflation (par défaut) | À la fin, **patrimoine en baguettes ≥ baguettes mises de côté**. On cumule chaque mois l'épargne nette (apports − retraits du patrimoine, salaire − dépenses − événements), convertie en baguettes au prix du mois ; le capital de départ de l'héritier compte comme un apport du mois 1. | Jauge en % (04 §3.3, « 9 200 → 10 300 baguettes ») |
| Acheter sa maison | **Patrimoine total ≥ cible**, à n'importe quel mois **avant l'échéance** (départ + 8 ans) | Cible = **90 %** du patrimoine de Cousin Indice **sans événements de vie** au mois de l'échéance, arrondie à 2 chiffres significatifs |
| Retraite tranquille | Patrimoine total ≥ cible à n'importe quel mois jusqu'au mois 180 | Cible = **100 %** du patrimoine de Cousin Indice sans événements de vie au mois 180, arrondie de la même façon |

La simulation « Cousin sans événements » est calculée au lancement de la partie. Les coefficients 90 % et 100 % sont des paramètres dans les données.

### 7.8 Les 3 témoins (02 §7 Q6)

Les témoins vivent **la même vie** que le joueur : même salaire, mêmes dépenses, mêmes événements de vie (ils refusent les escargots) et même capital de départ, reçu **en argent**.

| Témoin | Règle |
|---|---|
| Tonton Matelas | Tout reste sur le compte courant ; les coups durs y sont payés. |
| Tata Livret | Tout l'excédent va sur le Livret A, **dans la limite du plafond**, et le reste sur le compte courant (A16). Les coups durs sont payés par le livret. |
| Cousin Indice | Règles 1 à 6 de 02 §7 Q6 : un coussin de 3 mois de dépenses sur le Livret A, puis tout l'excédent dans le fonds indiciel. Le fonds est la SICAV jusqu'en 2000, puis l'ETF pour les **nouveaux** versements à partir de 01/2001 (les parts de SICAV sont conservées). Il passe **dans le PEA** dès que le PEA existe, dans la limite du plafond. Les dividendes sont réinvestis (dans la VL), les frais s'appliquent, et il ne vend que si son coussin est vide. |

Les 4 patrimoines sont valorisés **bruts** (A17) et comparés **en € d'aujourd'hui** au bilan.

### 7.9 Score : étoiles, titre et leçons

**Étoiles (5 au maximum)** :
- 1 étoile si l'objectif est atteint ;
- 1 étoile par témoin battu (patrimoine final strictement supérieur), soit 3 au maximum ;
- 1 étoile « sang-froid » si le joueur n'a **jamais vendu en panique**.

Une **vente en panique** est le choix « Tout vendre » dans une modale `−`, ou la vente de plus de 50 % de la valeur détenue en actions, SICAV et ETF dans le mois d'un événement `−` ou dans les 2 mois suivants. La règle s'affiche au survol (04 §1 Q4).

**Titres** : table `titres.js`, évaluée dans l'ordre ; le premier qui correspond l'emporte.

| # | Condition | Titre |
|---|---|---|
| 1 | Faillite | « Hébergé chez belle-maman » |
| 2 | 2 ventes en panique ou plus | « Roi de la panique » |
| 3 | Escargots acceptés et perdus | « Éleveur d'escargots » |
| 4 | Objectif atteint et 3 témoins battus | « Rentier de la Côte d'Azur » |
| 5 | Une ligne a dépassé 60 % du patrimoine et a perdu plus de 50 % | « Tous les œufs dans le même panier » |
| 6 | Plus de 12 ordres par an en moyenne | « Trader du dimanche » |
| 7 | Livret A ≥ 50 % du patrimoine en moyenne | « Fourmi du Livret A » |
| 8 | Compte courant ≥ 30 % du patrimoine en moyenne | « Neveu de Tonton Matelas » |
| 9 | Un versement automatique sur un fonds ou un ETF actif pendant 10 ans ou plus | « Métronome de l'épargne » |
| 10 | Sinon | « Épargnant en herbe » |

**Leçons** : bibliothèque `lecons.js`. Chaque gabarit a une condition, un ordre d'importance et un texte chiffré. On garde les 3 premières qui s'appliquent, **dont au moins une positive** si possible (04 §3.11).

1. Vente en panique, avec la variation de l'indice 12 et 24 mois plus tard (−).
2. Vente forcée à perte pour payer un coup dur, liée au coussin (−).
3. Argent qui dort : part moyenne du compte courant et perte de pouvoir d'achat en baguettes (−).
4. Frais payés en tout, exprimés en baguettes (−, si les frais dépassent 3 % des apports).
5. Une seule action a dépassé 60 % du patrimoine (−).
6. Impôt payé sur un compte-titres alors que le PEA existait (−).
7. A tenu bon pendant un krach : valeur 12 mois plus tard (+).
8. Le coussin a payé un coup dur sans rien vendre (+).
9. Versement programmé tenu au moins 5 ans (+).
10. Patrimoine en baguettes supérieur à l'épargne mise de côté (+).

---

## 8. Écrans de la V1 (renvoi aux maquettes de 04)

| Écran ou composant | Maquette | Écarts imposés par ce cahier |
|---|---|---|
| Écran titre | 04 §3.1 | aucun |
| Création de partie | 04 §3.2 | Cartes 1978 / 1996 / 2011 avec les accroches de 02 §7 Q1 (A8) ; **bouton « Choisir une année » masqué** (A3) ; **pas de choix de durée** (A10). |
| Écran principal | 04 §3.3 | Barre de répartition (A1) ; découvert sur « N mois sur 3 » (§7.6) ; pas de bandeau d'indice obligatoire. |
| Tiroir marché | 04 §3.4 | Livret : Déposer / Retirer ; emprunt : Souscrire / Revendre au nominal ; choix compte-titres / PEA seulement pour les produits éligibles et après la création du PEA. |
| Modale journal | 04 §3.5 | Jeux de choix du §6.1. |
| Courrier et notifications | 04 §3.6 | Règle modale ou notification du §6.2. |
| Nouveau produit | 04 §3.7 | aucun |
| Bilan annuel et rappel à 12 mois | 04 §3.8 | **Les deux en V1** (A18). |
| Moment euro | 04 §3.9 | P2 seulement. |
| Fins anticipées | 04 §3.10 | aucun |
| Bilan de fin | 04 §3.11 | Courbes des 4 témoins et répliques en V1. **Boutons « Voir sur la frise » et « Revoir ma frise » hors V1.** |
| Menu et options | 04 §3.12 | Pas de sons ni d'historique en V1 : les entrées correspondantes sont masquées. |
| Frise | 04 §4 | Marqueurs passés cliquables (lecture seule) ; à venir : ★ en mystère, échéance d'objectif, fin. **Jamais d'événement de marché à venir** (A5). |
| Tutoriel | 04 §5.2 (T1 à T7) | aucun |
| Glossaire « C'est quoi ? » | 04 §5.1, §5.4 | Bulles au survol et liste dans le menu. |
| Animations | 04 §6.1 | Toutes celles marquées V1, plus `unlock-pop` et `marker-pulse`. Les autres sont facultatives. |
| Direction artistique et accessibilité | 04 §7 | Seulement les blocs `data-era` des années 1970, 1980, 1990, 2000, 2010 et 2020 (pas 1950 ni 1960). |

Ordre de réalisation conseillé : celui de 04 §8 (on obtient une partie jouable « moche » d'abord, puis on l'habille).

---

## 9. Hors V1 (à ne pas développer maintenant)

- **Contenu** : année libre et Trente Glorieuses ; 5e action par période ; assurance-vie (**première de la liste V2**, selon le conseil du banquier) ; LEP ; Codevi et LDD ; or et Napoléon ; SCPI et immobilier ; PER ; crypto-actifs ; actions étrangères et ETF monde.
- **Règles** : seuil de cessions 1978-2010 (fiscalité fidèle) ; clôture du PEA avant 5 ans ; effet fiscal de la loi Monory ; droits de garde ; taux de service des privatisations et actions gratuites ; nationalisations ; division de nominal ; prix des obligations qui varient avec les taux ; ordres à cours limité ; levier (règlement mensuel, SRD) ; vente à découvert ; petit crédit à la consommation ; divorce et mariage.
- **Interface** : sons ; « Le saviez-vous ? » ; historique des événements ; « Revoir ma frise » et « Voir sur la frise » ; collection des titres ; compteur permanent des frais ; prix de l'essence ; marqueurs de mes ordres sur la frise ; `crash-vignette` ; thème sombre ; tablette et mobile ; avatars illustrés.

---

## 10. Critères d'acceptation (testables)

La V1 est acceptée quand **tous** ces points sont vérifiés. Le développeur fournit une page `jeu/tests.html`, ouverte par double-clic, qui exécute les tests automatisables (marqués [auto]) et affiche OK ou KO.

**Lancement et robustesse**
- **CA-01** : un double-clic sur `jeu/index.html` dans un dossier copié sur un autre PC Windows, **sans connexion Internet**, lance le jeu dans Edge et dans Chrome, sans erreur dans la console.
- **CA-02** : une partie complète de 180 mois se joue de bout en bout, sans erreur, **pour chacune des 9 combinaisons** période × profil, à la vitesse ×3 et sans aucune action du joueur. [auto, en mode accéléré sans affichage]
- **CA-03** : on fixe le jeu en pause au mois 50, on ferme l'onglet, on rouvre : « Continuer » reprend au même mois avec le même patrimoine.
- **CA-04** : l'écran principal est lisible à 1366 × 768 sans barre de défilement horizontale.

**Chronologie (anachronismes)** [auto]
- **CA-05** : le PEA n'est proposé nulle part **avant juillet 1992**, dans aucune partie.
- **CA-06** : l'ETF CAC 40 n'est pas proposé **avant janvier 2001**.
- **CA-07** : France Télécom n'apparaît pas avant octobre 1997 et Saint-Gobain pas avant décembre 1986. Leur premier cours est 27,75 € (182 F) pour l'une et 310 F pour l'autre.
- **CA-08** : le libellé « CAC 40 » n'apparaît pas avant juin 1988.
- **CA-09** : les montants sont en F jusqu'en décembre 1998, en double affichage de 1999 à 2001, et en € à partir de janvier 2002. La modale euro s'ouvre une seule fois, en janvier 2002.

**Données et calculs** [auto]
- **CA-10** : l'indice généré passe exactement par chaque clôture annuelle de 02 §4.2 (tolérance de 0,1 %).
- **CA-11** : deux lancements de la même période donnent des cours identiques (déterminisme).
- **CA-12** : deux parties avec la même graine de vie ont le même calendrier d'événements de vie, quels que soient les choix du joueur.
- **CA-13** : un dépôt sur le Livret A qui dépasse le plafond daté est refusé.
- **CA-14** : 10 000 F placés sur le Livret A le 1er janvier 1982 valent 10 850 F le 31 décembre 1982 (taux de 8,5 %).
- **CA-15** : une vente avec plus-value sur un compte-titres en 1995 est taxée à 16 % ; la même vente dans un PEA ouvert depuis plus de 5 ans en 2018 est taxée à 17,2 %.
- **CA-16** : un achat d'action de 1 000 F en 1985 coûte 50 F de frais (minimum) ; un achat de 10 000 F coûte 130 F.
- **CA-17** : un achat de LVMH en 2013 inclut la TTF de 0,2 % ; un achat d'ETF n'en paie pas.
- **CA-18** : 3 mois consécutifs au-delà du découvert toléré déclenchent la faillite, puis le bilan.
- **CA-19** : Tonton Matelas finit avec exactement la somme des épargnes nettes. Tata Livret ne dépasse jamais le plafond du livret.
- **CA-20** : en P1, sans événements de vie, Cousin Indice finit devant Tata Livret, qui finit devant Tonton Matelas, en € d'aujourd'hui.
- **CA-21** : le profil des actions respecte 02 §7 Q3. Par exemple, Peugeot perd au moins 50 % entre fin 1979 et fin 1984 ; France Télécom vaut au moins 200 € en mars 2000 puis au plus 10 € en septembre ou octobre 2002 ; Alcatel perd au moins 90 % entre son sommet de 2000 et fin 2002.
- **CA-22** : chaque action respecte ses ancrages de 02 §4.5 à ±10 %.

**Expérience de jeu**
- **CA-23** : un débutant lance une partie en **4 clics** au maximum depuis l'écran titre (avec les choix par défaut).
- **CA-24** : une partie standard (×1 avec quelques pauses, tutoriel compris) dure **entre 15 et 30 minutes**, mesurée sur 3 joueurs.
- **CA-25** : il n'y a jamais plus d'une modale par mois. Aucun événement de marché à venir n'est visible sur la frise.
- **CA-26** : chaque événement de marché de 02 §7 Q2 se déclenche au mois indiqué, avec sa manchette et le bon jeu de choix.
- **CA-27** : le rappel à 12 mois s'affiche après chaque choix de marché, avec la variation réelle de l'indice sur ces 12 mois.
- **CA-28** : le bilan affiche le patrimoine en € d'aujourd'hui, les 4 barres classées, les étoiles avec leur règle au survol, un titre et 3 leçons (dont au moins une positive si une leçon positive s'applique).
- **CA-29** : « Rejouer la même période autrement » relance la partie avec les mêmes événements de vie (date et montant).
- **CA-30** : chaque produit et chaque notion du glossaire de 04 §5.4 a une bulle « C'est quoi ? » de 2 lignes au maximum.
- **CA-31** : tout le jeu est utilisable au clavier (Espace, 1, 2, 3, M, Échap, Tab), et l'option « animations réduites » supprime les déplacements et les rotations.
