# 47 : Game designer, révision du chapitre 1989-1993 pour le lot 10

> 2026-11-18. Révise `docs/39` après les dernières décisions du joueur (`docs/lots/decisions_extension_annees.md`, puces du 18/11 ; `docs/10`, sections du 18/11), le boursier (`docs/37` §7.2 : pas de clôtures journalières en 1990) et le banquier (`docs/41` : SCPI, diversification, retrait des privatisations). **Prime sur docs/39** pour : §2.1 (mariage), §5 (Jean-Mi), §6.1 (vitrine), §13 (paramètres de titres), §14 (calendrier), et sur docs/45 pour les jumeaux. `docs/46` (banquier) n'existait pas à la rédaction : le PEP est tranché ici (§4).
> Chiffres de jeu : certitude C sauf mention. Règles d'écriture inchangées (vouvoiement, titres ≤ 5 mots, textes ≤ 30 mots, bulles ≤ 15 mots, jamais de conseil, rien d'annoncé avant sa date).

## 0. En bref

| # | Décision | Plaisir | Pédagogie | Coût |
|---|---|---|---|---|
| 1 | Vitrine du Golfe en **deux étapes mensuelles réelles** (août sans pause, septembre avec choix), courbe de 3 points de fin de mois marquée « fins de mois », aucune donnée journalière | moyen à fort (la baisse qui dure, après la chute d'un jour de 1987) | fort | faible (modale et instantané existants) |
| 2 | **Jean-Mi, saison 2 : tout dans une seule SCPI, payée comptant** ; même dosage (8 passages, 5 ★) ; plus de studio, de crédit, de privatisation | moyen à fort | fort (concentration, frais, liquidité) | faible (même produit que le joueur) |
| 3 | **SCPI jouable** présentée par M. Lefranc (02-04/1990), vente **différée de 3 mois**, alerte de liquidité en 03/1993 ; **PEP = simple message** | moyen | fort (4e panier, revente non garantie) | moyen (vente différée = mécanique nouvelle) |
| 4 | Mariage selon l'âge et la situation (70 % pour Gérard, fenêtre 09/1989-06/1992) ; jumeaux 1/6 ; Christine seule au départ 1989 | moyen | fort | faible |
| 5 | Privatisations retirées ; BNP = action ordinaire à partir de 10/1993 | neutre | « rester simple » | négatif (moins de travail) |
| 6 | Pilote carrière : K4 et K5 **toujours présentées** (sinon le joueur ne peut pas juger le pilote) | moyen à fort | moyen | faible |
| 7 | **Bureau de tabac** : un ticket fictif par mois au plus, gain pré-tiré, compteur net et espérance affichés | moyen à fort (geste libre) | fort si honnête | moyen |

---

## 1. Vitrine du Golfe : arbitrage

### 1.1 Le problème
docs/39 prévoyait un tableau de **7 vendredis**. Le boursier n'a aucune clôture journalière ou hebdomadaire vérifiée : seulement des **fins de mois** (07/1990 : 1 950, B ; 08/1990 : 1 640, C ; 09/1990 : 1 472, A). Inventer 7 cours « du vendredi » et les afficher comme des cours réels est exclu.

### 1.2 Forme retenue : deux étapes, les vrais mois
Rejeté : jours fictifs (même étiquetés, ils passent pour vrais dans la mémoire du joueur) ; fondu « décoré » de 7 étapes (le boursier l'autorise, mais il crée une précision qui n'existe pas).
Retenu : **la lenteur se vit sur deux mois de jeu**, c'est plus fort qu'un tableau.

| Mois | Forme | Contenu |
|---|---|---|
| **08/1990, étape 1** (○ sans pause) | kiosque existant « L'Irak envahit le Koweït » + télévision de la maison (chars en silhouette) ; à la fin du mois, bandeau de marché : « Fin août : la Bourse de Paris recule de {baisse_aout} % depuis fin juillet. » (−16 %) | aucun choix ; le joueur peut agir librement comme tout mois |
| **09/1990, étape 2** (■ vitrine) | modale existante : **courbe de 3 points** (fin juillet, fin août, fin septembre) reliés par des segments droits, mention fixe sous la courbe : « Fins de mois seulement : entre deux, la Bourse a fait des allers-retours. » ; puis instantané, choix Tout vendre / Ne rien faire / Renforcer, ligne « Face au Livret A » | ordres exécutés au cours de fin septembre (convention du jeu) |

- Texte de la modale (≤ 30 mots) : « Deux mois que la Bourse glisse : {baisse_totale} % depuis fin juillet. En 1987, la chute avait pris une journée. Cette fois, elle dure. » (24 mots ; −24 %).
- Répliques : Jean-Mi « Moi, je ne touche plus à la Bourse. » ; Sylvie (ou Patrick) « On ne parle que de ça. ». Séquence ≤ 10 s, passable.
- Tous les pourcentages sont **calculés** sur la série du jeu : si le boursier corrige 1 640 (C), les textes suivent sans réécriture.
- Paramètre de titre corrigé : `fenetre_vente_krach: ["1990-09", "1991-03"]` (le choix a lieu en 09/1990 ; docs/39 §13 disait 10/1990).

### 1.3 « Le Golfe, un an après » (09/1991, 3 barres comme 1987)
Repères calculés par le code : `rebond` = 09/1991 / 09/1990 ; `ecart` = 09/1991 / 07/1990. Avec la série actuelle (C) : 1 830 → **+24 %** depuis le creux, **−6 %** sous juillet. Deux cas :
- **Encore sous juillet 1990** (cas attendu) : « Un an après, la Bourse a regagné {rebond} % depuis septembre 1990, mais reste {ecart} % sous juillet. Un an ne suffit pas toujours : les actions demandent du temps. » (30 mots, deux-points compté)
- **Revenue au-dessus** : « Un an après, la Bourse a retrouvé son niveau de juillet 1990. Ceux qui ont pu attendre ont retrouvé leur argent. » (21 mots)
- 3 barres (vendu / rien / renforcé, choix entouré) ; « Ne rien faire » et « Renforcer » ne sont jamais hiérarchisés dans le texte. Cas sans action : exemple de 2 000 F de SICAV actions.
- Jean-Mi : « Ma pierre, elle, n'a pas bougé ! » (vrai à la date : le prix des parts est stable ; aucun sous-entendu sur la suite).

---

## 2. Jean-Mi, saison 2 : « tout dans le même panier »

**Principe** : Jean-Mi a juré « plus jamais de crédit, plus jamais la Bourse ». Après le Golfe, il met **tout son argent dans une seule SCPI, comptant**, puis y verse chaque trimestre toute son épargne (frais d'entrée à chaque achat). C'est **le produit que M. Lefranc a présenté au joueur** : même règles, mêmes chiffres. Leçon : concentration, frais d'entrée, revente non garantie. Jamais « la SCPI, c'est mal » : c'est le panier unique qui pèche.
**Tentation affichée** : le taux (6,5 % de loyers contre 4,5 % au Livret A), pas le classement. **J1 supprimée** au chapitre 2 (Jean-Mi n'a plus à passer devant Tata). **J2 inchangée** (derrière Tata d'au moins 10 % en 12/1993, toute graine, tout profil), vérifiée par test ; réglage si besoin : part de l'épargne versée en SCPI, jamais les chiffres du produit.

| Id | Date | Bulle (≤ 15 mots) | Moteur |
|---|---|---|---|
| V04 | 12/1989 | « Encore six mois de remboursement. Après, je fais du solide. » | dette existante |
| V06 ★ | 06/1990 | « Dernière mensualité ! Plus jamais de crédit, plus jamais la Bourse. » | fin de dette |
| V07 ★ | 10/1990 | sort de la banque, une plaquette à la main : « Des bureaux à Lyon, 6,5 % de loyers. Tout dedans, comptant ! » | achat SCPI avec 90 % de son compte |
| V08 | 05/1991 | « Mes loyers tombent chaque trimestre. Ton livret, il fait combien, déjà ? » | achats trimestriels |
| V10 | 03/1992 | « Tous mes œufs dans le même panier ? Un panier en béton ! » | — |
| V11 ★ | 10/1992 | « Un étage de mon immeuble est vide. Mes loyers ont baissé. » | taux de distribution 1992-1993 (§3) |
| V13 ★ | 06/1993 | « Ma 205 est morte. Je vends mes parts… il faut attendre un acheteur. » + carte de lecture | ordre de vente différé de 3 mois |
| V15 ★ | 12/1993 | « La pierre, c'est bien. Toute ma pierre dans un seul panier, moins. » | Jean-Mi passe au Livret A |

- **Carte de lecture** (06/1993, ouverte depuis la ★, sans pause, montants calculés) : « Jean-Mi a tout mis dans une seule SCPI : {mise}. Pour revendre, il attend un acheteur, au prix conseillé de {decote} % sous son prix d'achat. » (≤ 30 mots).
- Mme Lopez, V14 (09/1993) : « Jean-Mi a vendu ses parts. Moins cher qu'il les avait payées. »
- Partie commencée en 1989 (Christine) : Jean-Mi part à égalité avec Tata, tout au Livret A jusqu'en 10/1990 ; V01 : « Jean-Mi, vendeur chez Peugeot. La Bourse lui a coûté cher en 1987, il en parle volontiers. »
- Dosage : 8 passages, 5 ★ de Jean-Mi, comme docs/39 (mesuré par `test_rue_mesures`). Aucune mention restante de studio, crédit révisable, taux variable, privatisation.

---

## 3. SCPI jouable, diversification, PEP

### 3.1 Produit (données C, à valider : banquier pour frais et loyers, boursier pour le prix des parts)
| Paramètre | Valeur |
|---|---|
| Naissance au catalogue du monde | 1970 (loi du 31/12/1970, A) ; présentable dans tout chapitre postérieur (un 1984-1988 révisé peut la présenter sans réécriture) |
| Part | 1 000 F, dont 100 F de frais d'entrée ; **valeur de revente** au départ : 900 F (affichée dans « Mon argent », pour que les frais se voient tout de suite) |
| Loyers | 6,5 %/an du prix de souscription en 1989-1991, 6,3 % en 1992, 5,8 % en 1993 (B), versés chaque trimestre sur le compte courant ; fiscalité convention du jeu 16 %, bulle « Simplifié : en vrai, revenus fonciers » |
| Valeur de revente | 900 F stable jusqu'en 12/1992 ; 820 F en 03/1993 ; 780 F en 12/1993 ; suite en 1994-1996 au chapitre suivant (−25 % au total sur le prix, docs/41) |
| Vente | **ordre de vente exécuté 3 mois plus tard**, au prix du mois d'exécution ; l'argent n'est pas disponible avant ; annulable tant qu'il n'est pas exécuté |
| Vente automatique d'un projet | **n'utilise jamais la SCPI** (indisponible à la date) : si le reste ne suffit pas, règle existante (report, abandon) ; c'est la leçon de liquidité, sans texte de plus |
| Versement automatique | non (simplicité) |
| R-MIROIR | non recopiée chez Tata et Tonton (choix de placement) |

### 3.2 Présentation par M. Lefranc
- Continuation (Gérard) : **02/1990, limite 04/1990** (créneau B2 de docs/39, libéré par le PEP). Départ 1989 (Christine) : après les actions, limite 05/1990 (M17), avant la vitrine.
- Toujours **avant 10/1990** : le joueur connaît le produit quand Jean-Mi l'achète.
- Carte : titre « La pierre en parts » ; texte : « Une SCPI achète des bureaux et des commerces, et vous reverse les loyers. Une part : {prix}. Frais d'entrée élevés ; pour revendre, il faut un acheteur. » (≤ 30 mots). Carte à 5 critères existante : rendement « ≈ 6,5 % de loyers par an, plus ou moins la valeur de la part » ; risque « moyen » ; disponibilité « faible : environ 3 mois, prix non garanti » ; frais « ≈ 10 % à l'entrée » ; fiscalité « loyers imposés ». Sous la carte : message 4 de docs/41 (« L'immobilier est un autre panier… »).

### 3.3 Messages de contexte (banque, sans pause)
- 05/1989, avec la SICAV monétaire (M3-M6) : message 3 de docs/41 (court / moyen / long terme).
- 01/1990 : message 1 (diversifier) ; le PEP (§3.5) le même mois, en une seule notification.
- À la présentation de l'OAT (départ 1989) : message 2. Bilan final : message 6, une ligne.

### 3.4 Alerte de liquidité (03/1993, notification de la banque, **seulement si le joueur détient des parts**)
« Votre SCPI : pour revendre une part, le prix conseillé est désormais de {prix_revente}, soit {decote} % sous votre prix d'achat. Délai : environ trois mois. » (≤ 30 mots). Date : après la loi du 04/01/1993 qui organise ce prix conseillé (A). Aucune alerte avant (A5). Sans parts : rien, Jean-Mi porte la leçon.

### 3.5 PEP : simple message (tranché)
- **Pas de fiche jouable au lot 10.** Raisons : le joueur ne le connaît pas et veut rester simple ; son seul avantage (intérêts exonérés après 8 ans) ne se voit pas avant 1998 ; le chapitre accueille déjà SICAV monétaire, SCPI et PEA, et le PEA porte mieux la leçon « enveloppe fiscale » (actions, 5 ans).
- Notification 01/1990 (texte n° 8 de docs/38, 29 mots). Paramètre de titres : `produits_surs: ["livret", "pel"]` (pas de « pep »).
- Pour le joueur, en une phrase : le PEP était un plan d'épargne bloqué 8 ans pour ne pas payer d'impôt sur ses intérêts (fermé aux nouveaux plans en 2003, B, banquier).
- Remarque au coordinateur : le **PEA naît le 16/07/1992 (A)** ; il ne peut pas être présenté en 1984-1988, contrairement à la SCPI.

---

## 4. Vie : mariage, jumeaux, profil

### 4.1 Mariage selon l'âge et la situation (règle générale, prime sur docs/39 §2.1)
| Situation au début du chapitre | Survenue sur le chapitre |
|---|---|
| marié(e) | aucune |
| couple non marié, < 30 ans | 60 % |
| couple non marié, 30-39 ans | **70 %** (Gérard, 31 ans : validé) |
| couple non marié, 40-49 ans | 40 % |
| couple non marié, ≥ 50 ans | 20 % |
| célibataire (R-SEUL) | aucune tant que « la rencontre » n'existe pas |

- Fenêtre : **M9 → M42** du chapitre (09/1989 → 06/1992), date tirée sur le flux `famille` ; conditions : ≥ 2 ans de vie commune, jamais dans les 9 mois après une naissance, contraintes d'espacement de docs/45 §3.4 ; au plus un mariage par partie (hors remariage, plus tard). Probabilités C, à affiner par époque (le mariage recule après 1999).
- Texte : « Après {annees} ans ensemble, Sylvie et vous avez dit oui. Reste la fête : toute la famille, ou les témoins et un bon restaurant ? » ; choix et montants de docs/39 §2.1 inchangés ; R-MIROIR.
- Sans mariage (30 %) : rien d'annoncé ; une bulle de Sylvie au plus, en 1993 : « Le mariage ? On a bien le temps. » La note de transmission (R-FIN) en sera plus parlante.

### 4.2 Jumeaux : **1 naissance ancrée sur 6** (au lieu de 1 sur 4 ; docs/45 §2 n° 15 et §6.1 corrigés). Naissances aléatoires : 1,5 % inchangé.

### 4.3 Profil de départ du lot 10 : **Christine uniquement** (docs/39 §3) ; Sophie et Michel au lot des profils. Christine est mariée : aucun mariage. Son proche est Patrick (humeur, répliques).

---

## 5. Privatisations retirées

- Retirés : emprunt Balladur (B5, 06/1993), offre BNP (10/1993), Rhône-Poulenc, kiosque « BNP : l'État vend ses actions », lien emprunt / privatisation. Saint-Gobain 1986 : inchangé, aucune nouvelle explication.
- **BNP** : action ordinaire du catalogue à partir de 10/1993, une notification sans pause : « Nouvelle action au catalogue : BNP. » Aucun dividende avant 1994 (docs/37).
- Effet : 2 pauses de moins en 1993 (§7), utile pour la cible de 20 min.

---

## 6. Pilote carrière (K4, K5 de docs/42)

| | K4 « Le poste itinérant » | K5 « Le congé formation » |
|---|---|---|
| Créneau | S2, **toujours présentée** (fenêtre 09-12/1989) ; C02 passe en S1, C12 en S9 | S5 (02/1991), remplace C07, **toujours présentée** |
| Choix a | salaire + 15 % ; humeur −1 `cause: "carriere"` ; statut **prenant** ; ligne sous le choix : « {Proche} vous verra moins. Le couple peut en souffrir. » | salaire −10 % pendant 10 mois, puis + 8 % (01/1992) ; humeur −1 `cause: "carriere"` ; statut **normal** à la sortie (si K4 a : fin du poste itinérant) |
| Choix b | 0 ; « Le soir, tu es là. » | 0 |
| Christine | « Assistante du directeur commercial » (déplacements) ; proche Patrick | formation de comptable sur informatique |

- Temps libre = **humeur seulement** ; statut prenant : usure −1 chaque janvier quelle que soit l'humeur (docs/42 §3.3).
- **Compteur d'années tendues** (Sylvie fâchée au 31/12 et statut prenant actif) : sauvegardé, **sans effet** au lot 10 ; la séparation se branchera plus tard (docs/45 §2 bis).
- Promotion CNAM (si C07 en 1984-1988) : fenêtre 01-10/1990, ≥ 4 mois de K4 et de K5 ; plafond de 3 moments de carrière par chapitre respecté (K4, promotion, K5). R-MIROIR : voisins recopient salaires et statuts. Retraite et PER : repoussés.

---

## 7. Calendrier de référence révisé (Gérard venu de 1984 ; ■ pause, ○ sans pause)

| Mois | ■ | ○ |
|---|---|---|
| 01/89 | Passage de chapitre (version A) | |
| 02/89 | | V01 Mme Lopez ★ |
| 03/89 | Choix du projet 1 | |
| 05/89 | B1 SICAV monétaire | message 3 |
| 07/89 | S1 C01 ou C02 | kiosque Bicentenaire |
| 10/89 | **S2 K4 Le poste itinérant** | |
| 11/89 | | kiosque Mur de Berlin |
| 12/89 | | V04 Jean-Mi |
| 01/90 | | message 1 + PEP |
| 03/90 | **B2 SCPI** (02-04/1990) | |
| 05/90 ou mois tiré | promotion CNAM (si C07) sinon S3 C10 | |
| 06/90 | (mariage si tiré ce mois-ci) | V06 ★ |
| 08/90 | | **vitrine, étape 1** (kiosque, télé, bandeau) |
| 09/90 | **Vitrine, étape 2 : le Golfe** | |
| 10-12/90 | coup dur de la tempête (tiré) | V07 ★ Jean-Mi SCPI |
| 11/90-02/91 | S4 C06 Les diamants (glisse selon le coup dur) | |
| 02/91 | **S5 K5 Le congé formation** | |
| 04/91 | Échéance du projet 1 | |
| 05/91 | | V08 |
| 06/91 | B3 | |
| 07/91 | | issue des diamants |
| 09/91 | Le Golfe, un an après | |
| 12/91 | S6 | |
| 02/92 | Choix du projet 2 | kiosque Albertville |
| 03/92 | | V10 |
| 04/92 | S7 | |
| 07/92 | échéance P2A (sinon rien) | kiosque PEA |
| 09/92 | Marché : Maastricht et SME | |
| 10/92 | | V11 ★ |
| 11/92 | B4 le PEA | |
| 02/93 | échéance P2B, sinon S8 | |
| 03/93 | | **alerte SCPI** (si parts) |
| 04/93 | S9 | |
| 06/93 | | V13 ★ + carte de lecture |
| 08/93 | S10 | |
| 09/93 | | V14 Mme Lopez |
| 10/93 | | BNP au catalogue |
| 12/93 | échéance P2C, bilan final | V15 ★ |

- Mariage (70 %), Raymond (01/1991-06/1992), événements aléatoires : placés par le tirage (docs/45) dans les mois libres, R-CADENCE inchangée. Total : **24 à 26 pauses** (2 de moins que docs/39). Christine : passage remplacé par la pop-up de début ; chômage partiel de Patrick tiré en 01-09/1993.

---

## 8. Bureau de tabac (lancé par le joueur ; casino plus tard)

**Lieu** : la devanture **TABAC** existante de la rue, rendue cliquable (survol PC, toucher mobile) ; un buraliste fictif, **M. Paoli**, derrière le comptoir. Aucun nouveau bâtiment, aucune animation d'appel (pas de clignotement, pas de badge, pas de notification).

| Règle | Valeur |
|---|---|
| Produit | ticket fictif **« Le Trèfle »**, 10 F (1984-1993, C ; prix et date d'apparition des jeux de grattage en France à vérifier par le banquier ; disponible dès cette date) ; aucune marque ni nom réel (FDJ, Tac-O-Tac, Banco…) |
| Fréquence | **1 ticket par mois au plus** ; ensuite « Un ticket par mois. » (pas de compte à rebours) |
| Paiement | compte courant ; impossible s'il ne couvre pas 10 F |
| Grattage | **une seule zone** à gratter (≤ 3 s, bouton TOUT GRATTER) qui révèle un montant ou « Perdu » : **aucun « presque gagné »** (pas de 2 symboles sur 3) |
| Gains | 1/5 : 10 F ; 1/10 : 20 F ; 1/50 : 100 F ; 1/2 000 : 1 000 F → **retour 65 %** (ordre de grandeur du grattage, B à confirmer par le banquier) ; aucun jackpot, aucune animation de fête |
| Tirage | **pré-tiré** sur un flux `tabac` (un nombre par mois) : recharger ou attendre ne change rien |
| Compteur | toujours visible dans la modale : « Tickets : {n} · Misé : {mises} · Gagné : {gains} · Net : {net} » et « Les mêmes {mises} au Livret A : {livret} » (taux passés seulement) ; ligne fixe : « En moyenne, un ticket de 10 F rend 6,50 F. » |
| Prévention (1re ouverture, une fois) | « Jeu simulé, sans argent réel. Dans la vraie vie, les jeux d'argent sont interdits aux mineurs et peuvent rendre dépendant. » |
| Temps | modale ouverte par le joueur : temps figé, **hors R-CADENCE** (ce n'est pas une interruption) |
| Score | non recopié chez les voisins (choix, comme les escargots) ; effet moyen −3,50 F/mois, négligeable ; **ni titre ni étoile** au pilote |
| Bilan final | une ligne si au moins un ticket : « Le Trèfle : {n} tickets, net {net}. » |
| Humour | 10 répliques du buraliste, tirées : perte « Pas cette fois. Le Trèfle a ses humeurs. » ; 10 F « Dix francs ! Vous voilà… remboursé. » ; 1 000 F « Ça arrive. Rarement. » |

- Plaisir : un geste libre entre les événements (ce que demandait le joueur), petite surprise mensuelle. Pédagogie : espérance négative visible à chaque ticket, comparée au Livret A ; aucun gain mis en scène. Coût : **moyen** (dev-logique : règle, flux, compteur, sauvegarde ; dev-interface : modale ; dev-ville : enseigne cliquable, buraliste).
- Garde-fous : pas de 2e ticket, pas de mise variable, pas de série ni de bonus, pas de rappel ; un gain de 1 000 F (≈ 3 % des parties sur 60 tickets) est montré avec la même sobriété qu'une perte.
- Place dans la feuille de route : lot à part après le lot 10 (ou en parallèle si le chef de projet a un développeur libre) ; disponible dans 1984-1993.

---

## 9. Points à confirmer
- **Boursier** : fin août 1990 (1 640, C) ; fin septembre 1991 (1 830, C) pour « un an après ».
- **Banquier** : prix de part, frais, loyers et valeur de revente 1989-1993 ; délai de vente de 3 mois ; date d'apparition et prix des tickets à gratter en France ; taux de retour du grattage.
- **Chef de projet** : vente différée (SCPI) et exclusion de la vente automatique ; K4 / K5 toujours présentées ; tabac en lot séparé.
