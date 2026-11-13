# 27 : Game designer, version jouable 0.5 (G4 projets, G5 rue, avis sur le plaisir)

> 2026-11-13. Réponses à `docs/lots/lot_05.md` §8 (G4, G5) dans le cadre de `feuille_de_route_jouable.md`.
> **Tout est en données** (`projets.json`, `rue.json`, `temoins.json`) sauf 4 points signalés **[code]**, tous facultatifs.
> Règles d'écriture tenues : narration au **vous** ; Sylvie ne s'adresse à personne (docs/23 G1.1) ; aucun « achetez / vendez / c'est le moment / auriez dû » ; aucune prévision hors de la bouche de Jean-Mi ; montants en gabarits.

---

## 1. G4 : textes des cartes de projet (remplacent les `_provisoire` de `projets.json`)

### 1.1 Trois corrections de fond sur les provisoires
1. **« C'est le moment » (jour J) est un mot interdit** de la recette (CA-R6) : remplacé.
2. **`{nom}` en milieu de phrase** donne « Le jour J : La Super 5 neuve » (majuscule) : utiliser `{court}` dans les phrases, `{nom}` seulement en tête de bouton.
3. **Sous-titre de P2C** : la phrase du PEL (40 mots) ne tient pas sous un bouton. Sous-titre court ci-dessous ; la phrase du banquier (docs/18 §2.1) va dans une clé `detail` affichée au jour J de P2C **[code, facultatif]**, sinon elle est simplement retirée (le banquier a déjà présenté le PEL).

### 1.2 Cartes de choix
| Clé | Texte |
|---|---|
| P1 `titre` | Le projet du foyer |
| P1 `texte` | Pour {echeance}, Sylvie et vous voulez vous offrir quelque chose. Un seul projet à la fois : lequel ? |
| P2 `titre` | Le projet suivant |
| P2 `texte` | Avec {prenoms}, les envies changent. Trois projets, trois dates : lequel ? |
| P1A, P1B, P1C, P2A, P2B : `nom`, `court`, `sous` | **inchangés** (bons) |
| P2C `sous` | Apport comptant ; un PEL de 4 ans y aide |

« Trois projets, trois dates » attire l'œil sur l'**horizon** (6, 13, 23 mois) sans dire la leçon.

### 1.3 Rappel, jour J, conséquences
| Clé | Texte |
|---|---|
| `rappel_titre` | Sylvie compte les mois |
| `rappel_texte` | Sylvie : « {court}, c'est en {mois} ! » Sans rien vendre : {disponible} sur {montant}. |
| `rappel_texte_atteint` **[code, facultatif]** (si `atteint`) | Sylvie : « {court}, c'est en {mois} ! » Tout est déjà de côté. |
| `echeance_titre` | Le jour J : {court} |
| `echeance_texte` | Nous y sommes : {court}, {montant}. Voici ce qui est de côté. |
| `consequence_choix` | C'est décidé : {court}, pour {echeance}. Le compteur est sur la maison. |
| `consequence_realise` | C'est fait : {court} ! « {replique} » (repli sans `{replique}` : « C'est fait : {court} ! ») |
| `consequence_reporte` | Reporté à {echeance}. « Quatre mois de plus… on patientera. » |
| `consequence_abandonne` | Projet abandonné ; l'argent reste de côté. « Tant pis, ce sera pour une autre fois. » |
| `consequence_abandonne_p2c` **[facultatif]** | L'argent reste de côté. « Le T3 attendra encore un peu. » |
| `guichet` | inchangé (validé par le banquier, docs/18 §2.2) |

« L'argent reste de côté » : renoncer n'est pas une perte d'argent, seulement d'humeur (pas de punition cachée).

### 1.4 Boutons du jour J (sous-titres)
| Bouton | `sous` |
|---|---|
| RÉALISER | Pris sur le compte courant, puis le Livret A · Sylvie ravie |
| RÉALISER EN VENDANT | Vendre des placements pour {manque} · Sylvie ravie |
| (impossible) | Même en vendant tout, il manque {manque} |
| REPORTER DE 4 MOIS | Nouvelle date : {echeance} · Sylvie déçue |
| RENONCER | Projet abandonné · Sylvie très déçue |

Pourquoi l'humeur sur les boutons : même règle que les cartes (docs/23 G2 : « le joueur voit l'effet avant de choisir »). Sans elle, −1 / −2 seraient des pénalités cachées.

**Écran de confirmation, ligne d'ordre de vente** (question K3 du banquier, je signale seulement) : préférer « **D'abord ce qui a le moins rapporté jusqu'ici.** » à « de ce qui rapporte le moins… » : D7 bis mesure le passé ; le présent se lit comme une prévision.

### 1.5 Répliques de Sylvie au jour J (clé `replique_realise` par option ; gabarit comme D4 du lot 04)
| Option | Réplique |
|---|---|
| P1A salon | Enfin un canapé où l'on tient à deux ! |
| P1B Grèce | Trente ans face à la mer Égée ! |
| P1C Super 5 | Adieu la 4L, elle a bien servi ! |
| P2A Club Med | Des vacances où je ne cuisine pas ! |
| P2B break | Enfin de la place pour tout le monde ! |
| P2C T3 | Une chambre d'enfant, une vraie ! |

Valables avec un enfant comme avec des jumeaux ; aussi après un report.

---

## 2. G5 : la rue en notifications

### 2.1 Patrimoine de Jean-Mi (D3) : **validé, avec une correction et une précision**

**Validé : la voiture à sa valeur de marché, moins le crédit.** Raisons :
- C'est la bonne comptabilité (patrimoine net = actifs à leur valeur de revente − dettes). Compter le crédit sans la voiture punirait Jean-Mi deux fois ; compter ni l'un ni l'autre ferait tomber J1.
- **J1 est indispensable au plaisir** : sans montée visible de Jean-Mi, pas de tentation, et la chute de 10/1987 ne raconte rien.
- **Pédagogiquement juste** : à l'achat, Porsche + crédit = 0 de patrimoine en plus (140 000 − 110 000 − 30 000 d'apport) ; ensuite la décote le fait baisser chaque mois, et accélère pendant le krach (125 000 → 91 000). Le joueur voit qu'une voiture n'enrichit pas. En 12/1988 (voiture vendue, crédit soldé), les deux conventions donnent **le même résultat** : seule la trajectoire change.
- Asymétrie avec le joueur (sa Super 5 ou son break ne comptent pas) : sans effet sur les rangs, puisque les 4 voisins achètent la même chose (R-MIROIR). Seule la Porsche est propre à Jean-Mi : elle doit donc compter.

**Correction (risque de double comptage dans la formule D3)** : « équité du compte de bourse (… négative après liquidation) » **et** « − dette de bourse » comptent la dette deux fois. Règle : **après la liquidation, équité = 0 et la dette est une ligne à part** (docs/19 §2.3, 12/1988 : liquide − mensualités + voiture − crédit − dette). Test : en 11/1987, la part « bourse » du patrimoine de Jean-Mi vaut −26 041 F ± 1 %, une seule fois.

**Précision pour le joueur (données)** : la règle affichée de Jean-Mi dit d'où vient son patrimoine (voir §2.2, `regle`).

### 2.2 Textes définitifs (`rue.json`, `temoins.json > jeanmi`)

Format : titre = nom du voisin ; texte ≤ 15 mots (≤ 60 si long). Deux voisins dans un passage : titre « A et B ».

| id | Date | Titre | Texte |
|---|---|---|---|
| V01 ★ long | 02/1984 | Mme Lopez | « Vous connaissez vos voisins ? » Tata Livret met tout sur son Livret A. Tonton Matelas garde tout sur son compte. Jean-Mi, vendeur chez Peugeot, attend le bon tuyau. Mêmes revenus, mêmes dépenses que vous : seule change la façon de placer. Le classement de la rue est en haut de l'écran. (49 mots) |
| V02 | **05**/1984 | Tonton Matelas | « Une banque ? Et si elle saute ? Moi, c'est sous le matelas. » |
| V03 | 09/1984 | Tata Livret | « Le Livret A, c'est garanti par l'État, et ça rapporte chaque année. » |
| V04 | 03/1985 | Jean-Mi | « La Bourse ? J'attends le bon tuyau. Au café, ils en ont plein. » |
| V05 | 08/1985 | Tonton Matelas | « La baguette a encore augmenté. Mes billets, eux, n'ont pas bougé… » |
| V06 | 06/1986 | Tata Livret | « Mon Livret rapporte moins, mais les prix montent moins vite. C'est l'écart qui compte. » |
| V07 ★ | 09/1986 | Jean-Mi | « Tuyau du café : Peugeot ne peut que monter. J'ai tout mis, et même plus ! » |
| V08 | 12/1986 | Mme Lopez | « Saint-Gobain, et bientôt Paribas… toute la rue devient actionnaire ! » (D7, inchangé) |
| V09 ★ | 04/1987 | Jean-Mi | « Elle est belle, ma Porsche ! Payée par Peugeot… et un peu par la banque. » |
| V10 | 08/1987 | Jean-Mi | « J'en ai repris, encore à crédit. Quand ça monte, faut en profiter ! » |
| V13 ★ long | 12/1987 | Jean-Mi | « Je n'ai plus rien… et je dois encore de l'argent. » Avec {couverture}, Jean-Mi en a joué {position} au règlement mensuel (acheter à crédit sur la Bourse). Peugeot a perdu {baisse} : {perte} de perte. Ses {couverture} y sont passés, et il en doit encore {dette}. Le crédit grossit les gains… et les pertes. (52 mots) |
| V14 | 03/1988 | Tonton Matelas et Tata Livret | M. : « Le krach ? Moi, j'ai rien perdu ! » T. : « Si : l'inflation, un peu chaque année. » |
| V15 | 07/1988 | Jean-Mi, à vélo, et Mme Lopez | J. : « La Bourse, plus jamais ! » L. : « C'est pas la Bourse, Jean-Mi, c'est le crédit. » |
| V16 ★ | 11/1988 | Jean-Mi | « Peugeot est remonté plus haut qu'avant le krach… sans moi. » (vérifié : 770 F en 11/1988 > 740 F, plus haut de 1987, docs/19 §1.3) |

Notes :
- **V02 avancé en 05/1984** pour laisser juin aux Bleus du kiosque (sinon le kiosque cède et glisse en juillet).
- **V05** sans chiffre (le gabarit `{b0}` `{b1}` n'est pas prévu en A1) ; si le banquier fournit le prix de la baguette 1984 / 1985 avec certitude, variante : « Avec 100 F, j'avais {b0} baguettes en 1984. Aujourd'hui, {b1}. »
- **V14** corrige l'idée fausse de Tonton Matelas (« rien perdu ») : c'est la seule leçon d'inflation après le krach.
- **V01 et V13, toast** : le toast montre la première phrase entre guillemets, le toucher ouvre le texte long. Si l'interface ne sait pas couper, ajouter une clé `court` (ajout au contrat) : V01 « Vous connaissez vos voisins ? », V13 « Je n'ai plus rien… et je dois encore de l'argent. »

**Bulles réactives**
| Déclencheur | Titre | Texte |
|---|---|---|
| 1er achat d'action | Mme Lopez | « Alors, monsieur Gérard, on est actionnaire ? Comme les patrons ! » |
| 1er projet réalisé (par option ; repli générique) | Mme Lopez | P1A « Un salon tout neuf ? Vous recevez quand ? » · P1B « Bronzés comme ça, vous rentrez de Grèce ! » · P1C « Belle Super 5 ! La 4L va manquer à la rue. » · P2A « Bonnes vacances ! Rapportez-moi un collier de coquillages. » · P2B « Deux voitures ! Il va falloir garer la mienne ailleurs. » · repli « Bravo pour le projet, toute la rue en parle ! » |
| M. Lefranc après le krach | — | **À supprimer** (voir §2.3) |

**Rang** (`titre` « Classement de la rue »)
- perte : « Jean-Mi passe devant vous dans la rue. Tout le café est au courant. »
- gain : « Vous repassez devant Jean-Mi au classement de la rue. »
(Neutres sur le « comment » : aucune incitation à copier Jean-Mi, aucune joie au malheur.)

**`temoins.json > jeanmi`**
- `nom` « Jean-Mi », `initiale` « J ».
- `regle` : « Garde tout sur son compte en attendant le bon tuyau. » ; à partir de 09/1986, si une clé `regle_apres` est lue **[code, facultatif]** : « Tout sur Peugeot, à crédit. Sa Porsche compte à son prix d'occasion, moins son crédit. »
- `devant` (Jean-Mi devant le joueur à la fin, cas extrême) : « Même avec mes dettes, je suis devant ? Il s'est passé quoi chez vous ? »
- `derriere` : « Bravo. Moi, je rembourse jusqu'en 1990. Plus jamais de crédit pour la Bourse. »

**Harmonisation à signaler** (données existantes, hors G5) : `temoins.json > livret.derriere` et `indice.derriere` tutoient le joueur (« Tu as pris des risques… ») alors que tout le jeu le vouvoie. Proposition : « Vous avez pris des risques… et ça a payé. Bravo ! ».

### 2.3 Dosage : **juste pour une première partie**, avec 3 retouches

Total : 14 passages + 2 réactives + 11 titres ≈ 27 notifications « rue ou kiosque » en 60 mois, soit une tous les 2 mois en moyenne, en plus des notifications existantes (dividendes, rappels, humeur). C'est le bon niveau : assez pour que la rue vive, pas assez pour devenir du bruit.

Retouches :
1. **Supprimer la réactive de M. Lefranc après le krach** : elle est perdue dans 100 % des parties (11/1987 = panne forcée avec pause ; 12/1987 = V13 ★ ; 01/1988 trop près de V13 ; au-delà de +2 mois : abandonnée). Le krach a déjà sa modale.
2. **Remplacer le titre « LUNDI NOIR » (10/1987)** pour la même raison (10, 11 et 12/1987 tous pris) et parce que la modale du krach le dit déjà. À la place : **01/1988 « Fin des agents de change, place aux sociétés de bourse »** (A, docs/19 §3) : pédagogique, après le krach, sans prévision.
3. **Priorités dans un même mois** : rang > passage ★ > réactive > passage ordinaire > kiosque. La réactive répond à un geste du joueur : c'est elle qui donne l'impression que la rue le regarde. Le rang compte dans le plafond « 1 notification rue ou kiosque par mois ».

Je garde : ≤ 1 voisin tous les 2 mois, ≤ 1 rue ou kiosque par mois, rang ≤ 1 tous les 6 mois, 11 titres de kiosque (dont un remplacé).

### 2.4 Pastille permanente
**« RUE 2e / 4 »** : validé, avec « **1er** » (pas « 1e »). Couleur neutre (le rang n'est ni un gain ni une perte en soi, la pastille « vs Livret A » porte déjà la couleur). Un toucher ouvre « Mon argent ». En 1984, égalités nombreuses (Jean-Mi = Tonton Matelas) : le joueur devant (D9), puis Tonton Matelas avant Jean-Mi.

---

## 3. Avis honnête : le plaisir dans la 0.5

### 3.1 Ce qui apportera le plus (dans l'ordre)
1. **Les projets** : pour la première fois, l'argent **sert à quelque chose**, avec une date. Le compteur sur la maison, le rappel et le jour J (vendre ou non, et à quel prix) créent la seule vraie tension à moyen terme. C'est aussi la plus forte leçon de la version (horizon, liquidité, coût de sortie).
2. **Jean-Mi et le classement permanent** : un rival, une histoire avec une chute, un score qui bouge. C'est le seul « personnage » qui monte et tombe ; son arc donne du sens au krach.
3. **Les cartes du foyer** : elles remplissent les tunnels et donnent un choix toutes les 4 à 6 minutes.

Ce qui va manquer le plus : la **séquence du Lundi noir** (reportée). Un tableau statique de 7 jours n'a pas l'impact du moment fort de la démo ; « un an après » compensera en partie, par la réflexion plutôt que l'émotion.

**Risque principal** : Jean-Mi n'existe **que par des toasts**. Avec le bouton COURRIER, la plupart passent pendant un saut ; si le joueur ne les lit pas, l'arc tombe à plat et le verdict « on ne s'amuse pas plus » portera sur une rue qu'il n'aura pas vue.

### 3.2 Trois idées, sans élargir le périmètre
| # | Idée | Plaisir | Pédagogie | Coût |
|---|---|---|---|---|
| 1 | **Rendre Jean-Mi visible sans animation** : (a) ses 4 passages ★ (V07, V09, V13, V16) restent à l'écran jusqu'au toucher, sans pause et sans arrêter le saut ; (b) dans « La rue » de « Mon argent », sa ligne porte son étape en 2-3 mots, d'après `jeanmi_resume().etape`, déjà au contrat : « attend un tuyau » / « tout sur Peugeot » / « Porsche à crédit » / « liquidé » / « rembourse ». | fort | fort (le levier se suit mois par mois) | faible (réglage d'une notification, une étiquette) |
| 2 | **Fermer les 3 boucles à l'écran de fin** : à côté des 4 barres et du rang, la ligne « Projets : 2 sur 2 réalisés » et le portrait 48 × 48 de Sylvie (existant, docs/15 §6 point 3). Sans les titres (vague 6), la fin ne parle que d'argent ; or la 0.5 est justement le test du foyer et de la rue. | moyen | moyen (on ne gagne pas seulement en patrimoine) | faible |
| 3 | **Une fiche de retour avec la 0.5** (zéro code) : chronométrer et demander au joueur : (1) le moment où vous avez le plus hésité ; (2) le moment où vous avez appuyé sur COURRIER par ennui ; (3) avez-vous regardé la pastille RUE ? (4) Jean-Mi vous a-t-il donné envie d'acheter du Peugeot ? (5) au jour J, avez-vous dû vendre, et qu'en avez-vous pensé ? (6) avez-vous envie de rejouer pour faire autrement ? | indirect | indirect | nul |

L'idée 3 sert le but du joueur (« voir si on s'amuse plus ») : un verdict précis évite de peaufiner les mauvaises choses. Les questions 4 et 6 mesurent la tentation et la rejouabilité, les deux choses que la rue doit apporter.

**Si la partie paraît hachée** (environ 25 pauses en 60 mois avec les projets et « un an après ») : le premier levier reste de retirer les créneaux de cartes S1, S3, S5 et S9 (docs/15 §9.2), pas les projets ni la rue.

---

## 4. À transmettre au chef de projet (résumé)
- Données à remplacer : `projets.json` (§1), `rue.json` (§2.2, §2.3), `temoins.json > jeanmi` (§2.2).
- D3 : validé ; **corriger la formule** (pas d'équité négative en plus de la dette) et ajouter le test de 11/1987 (§2.1).
- Supprimer la réactive de M. Lefranc ; remplacer « LUNDI NOIR » par le titre de 01/1988 ; V02 en 05/1984 ; ordre des priorités dans un mois (§2.3).
- Facultatif **[code]** : `rappel_texte_atteint`, `detail` de P2C, `replique_realise`, `regle_apres`, clé `court` des textes longs (ajouts seulement).
- Pour la 0.5 : notifications ★ de Jean-Mi qui restent jusqu'au toucher, et son étape dans « La rue » (§3.2, idée 1) ; « Projets 2/2 » et le visage de Sylvie à l'écran de fin (idée 2) ; fiche de retour (idée 3).
- Harmoniser le vouvoiement dans `temoins.json` (Tata, Cousin Indice).
