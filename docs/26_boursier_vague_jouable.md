# 26 - Contenu boursier de la vague jouable (réponse à B4, `lot_05.md` §8)

> Boursier, 2026-11-13. Pour : 05-L (Jean-Mi, krach, « un an après », kiosque) et 05-I (écrans du lot 06).
> Certitude : **A** vérifié (source publique), **B** probable (erreur < 5-10 %), **C** reconstitué ou valeur de jeu (erreur 10-25 % ou convention).
> Échelle de l'indice : **base 1 000 au 31/12/1987** (indice de l'époque × 3,52). Les clôtures du 20 au 26/10/1987, les cours de Peugeot 1986-1988 et l'indice d'octobre 1988 ne viennent d'**aucune source en ligne** : ce sont des valeurs de jeu (C), à afficher « environ ».
> Convention : tout ancrage = clôture de fin de mois, sauf indication.

## 0. Synthèse : ce qui change par rapport à docs/19 et quoi faire

| # | Constat | Action | Qui |
|---|---|---|---|
| 1 | **Aucun ancrage de l'indice entre 06/1988 (1 300) et 12/1988 (1 573,9)** : le pont brownien donne en 10/1988 une valeur centrale de ≈ 1 477 mais avec un écart-type de ≈ 5 % (±75) ; environ 2 à 4 % des graines (queues de Student ν = 4) tomberaient sous 1 310 et rendraient fausse la phrase « un an après ». | Ajouter l'ancrage dur `["1988-10", 1470]` (C) dans `periode_p1.json > ancragesIndice`. | dev-logique |
| 2 | Texte « un an après » : « a regagné une grande partie du terrain » **sous-estime** la série (en 10/1988, l'indice est au-dessus du niveau d'avant le krach). | Texte final du §1.2. | 05-L (`krach.json`) |
| 3 | Les 5 clôtures C du 20 au 26/10 : le pourcentage du 20/10 (-6,25 %) tombe pile entre deux arrondis. | Stocker `indice` à 1 décimale (19/10 = **1 119,7**) et **calculer** `variation` par le code (§3). | 05-L |
| 4 | docs/19 §2.5 : « S + 46 000 » en 09/1987 est une **erreur de somme** (la somme des termes donne 49 082). Marge réelle de J1 en 09/1987 : **≈ +9 900 F** face à Tata (C), pas 7 000. | Corriger ; les leviers de réglage sont au §2.3. | dev-logique, chef de projet |
| 5 | Le kiosque « LUNDI NOIR » (10/1987) double la modale du krach ; « CAC 40 » (06/1988) double la notification de contexte existante `periode_p1.json > contexte` (1988-06 « L'indice change de nom »). | Remplacer par deux titres A (§4). | 05-L (`rue.json`) |
| 6 | Calendrier de la rue : plusieurs mois reçoivent 2 ou 3 éléments (04/1987, 10/1986, 11/1987, 06/1984) pour un budget de 1 par mois. | Ordre de priorité et décalages du §5. | 05-L |
| 7 | Arrondis du texte du levier : avec les valeurs exactes, couverture = 26 901, perte = 52 941, dette = 26 040 (docs/19 donnait 26 900 / 26 041). | Règle d'affichage du §2.2. | 05-L |

---

## 1. « Le krach, un an après » (B4 points 1 et 2)

### 1.1 Faits sur 1929 et 1987 (pour la phrase finale)

| Fait | Valeur | Cert. |
|---|---|---|
| Dow Jones, sommet de 1929 | 381,17 (clôture du 03/09/1929) | A |
| Dow Jones, plus bas | 41,22 (08/07/1932), soit environ -89 % | A |
| Retour au sommet de 1929 | clôture à 382,74 le **23/11/1954**, soit **25 ans** (hors dividendes ; plus long intervalle de l'histoire du Dow sans nouveau record) | A |
| Dow Jones, 19/10/1987 | -22,6 % (-508 points, à 1 738,74) | A |
| Dow Jones, retour au sommet d'août 1987 (≈ 2 722) | vers l'été 1989, soit environ **deux ans** | B (de mémoire, non retrouvé par la recherche) |
| Paris, krach d'octobre 1987 | -9,7 % le 19/10 ; octobre ≈ -25 % ; plus bas retenu pour le jeu 963 (10/11) | A (-9,7 %) / B |
| Paris, 1988 (série du jeu) | de 1 000 (fin 1987) à 1 573,9 (fin 1988), +57,4 % | A (clôture annuelle de `series.json`) |

Précaution : le krach de 1929 (-89 % en trois ans, dans une crise économique) n'a pas la même ampleur que celui de 1987 (≈ -34 % en cinq semaines, sans récession). La phrase sur 1929 sert à dire que **personne ne connaît la durée**, pas à prédire.

### 1.2 Texte final proposé (≤ 50 mots, 48 mots comptés par blancs)

> « Un an après, la Bourse de Paris a dépassé son niveau d'avant le krach. Ceux qui pouvaient attendre ont retrouvé leur argent ; Jean-Mi, endetté, a dû vendre en pleine chute. En 1987, personne ne savait combien de temps il faudrait : après 1929, Wall Street a mis vingt-cinq ans. »

| Élément | Vérification | Cert. |
|---|---|---|
| « a dépassé son niveau d'avant le krach » | vrai pour la série du jeu si `1988-10 >= 1 310` (fin septembre 1987) ; avec l'ancrage 1 470 : +12 % ; **faux** si l'on vise le sommet de 03/1987 (1 500) : il n'est dépassé qu'en 11-12/1988 | B (niveau de 10/1988 : C) |
| « Jean-Mi, endetté, a dû vendre en pleine chute » | dans le moteur, liquidation d'office à la clôture d'octobre (Peugeot 500, soit -26,5 %), dette de bourse 26 040 F | C (récit) |
| « après 1929, Wall Street a mis vingt-cinq ans » | 1929 -> 1954, en cours nominaux, hors dividendes | A |
| Aucun « vous auriez dû » | oui | - |

Variante courte sans Jean-Mi (si le joueur n'a pas la rue allumée, cas impossible en 0.5 mais utile pour tests) : « Un an après, la Bourse de Paris a dépassé son niveau d'avant le krach. Ceux qui pouvaient attendre ont retrouvé leur argent. En 1987, personne ne savait combien de temps il faudrait : après 1929, Wall Street a mis vingt-cinq ans. » (38 mots).

Garde-fou pédagogique recommandé (données, pas code) : sous les barres, une ligne fixe « Un seul exemple, pas une règle. » (4 mots, hors des 50). À valider par le game designer.

### 1.3 Cohérence de la série du jeu en 10/1988 (B4 point 2)

| Mesure | Valeur | Cert. |
|---|---|---|
| Indice 09/1987 (ancrage) | 1 310 | B |
| 16/10/1987 | 1 240 | A |
| Fin 10/1987 (29/10) | 1 033 (cours du mois retenu par le moteur) | A |
| Plus bas du jeu (11/1987) | 963 | A (séance) |
| Fin 12/1987 | 1 000 | A |
| 06/1988 | 1 300 | B |
| **10/1988 : valeur centrale** (interpolation logarithmique 06/1988 -> 12/1988, 4 mois sur 6) | ≈ 1 477 | C |
| 10/1988 : écart-type du pont (σ mensuel 4,5 %, 4 pas sur 6) | ≈ 5,2 % (≈ ±77) | calcul |
| **Valeur de jeu recommandée (ancrage dur)** | **1 470** | C |
| 12/1988 | 1 573,9 | A |
| Retour au niveau du 16/10 (1 240) | vers 05/1988 (série interpolée) | C |
| Retour à 1 310 | vers 06-07/1988 | C |
| Retour au sommet de 03/1987 (1 500) | **12/1988** (soit 14 mois après le krach) | C |

- Conclusion : la série donne un rebond **cohérent avec l'histoire** (Paris regagne fortement en 1988 ; la leçon existante « a tout récupéré en un peu plus d'un an », `periode_p1.json > evenements p1e6`, reste vraie pour le sommet de 1987 : 12/1988).
- Peugeot (docs/19 §1.2) : 10/1987 = 500, 10/1988 = 720 (+44 %) ; l'indice fait +43 % (1 033 -> 1 477) : avec bêta 1,3 on attendrait ≈ +59 % (≈ 795) ; l'écart de 9 % reste dans la tolérance « résidu < 10 % » (C). À garder.

### 1.4 Ordre de grandeur des 3 barres (10 000 F au cours du mois d'octobre 1987)

Hypothèses (toutes C sauf indication) : valeur investie **10 000 F à la valeur liquidative du mois 10/1987 (indice 1 033)** ; « Renforcé » = +50 % (5 000 F, frais d'entrée 2 % en SICAV, courtage 1,3 % mini 50 F en action) ; valorisation **brute** (A17) ; Livret A 4,5 % (06/1986 -> 03/1996, A) ; vente de SICAV sans frais, aucun impôt (moins-value) ; dividendes : rendement du marché 3,6 % (1987) puis 3,0 % (1988), `series.json`.

**SICAV** (VL(m) = VL(m-1) × I(m)/I(m-1) × (1 + d/12) × (1 - 1,5 %/12), `regles.json > sicav`) : facteur frais + dividendes sur 11/1987 -> 10/1988 = **1,0161** (11-12/1987 à d = 3,6 % ; 01-10/1988 à d = 3,0 %).

| Indice 10/1988 | Tout vendu (Livret A, 12 mois) | Rien fait = 10 000 × (I/1 033) × 1,0161 | Renforcé = Rien fait + 4 900 × (I/1 033) × 1,0161 |
|---|---|---|---|
| 1 400 (bas, -1 σ) | ≈ 10 450 | ≈ 13 770 | ≈ 20 520 |
| **1 470 (ancrage)** | **≈ 10 450** | **≈ 14 460** | **≈ 21 550** |
| 1 477 (centre du pont) | ≈ 10 450 | ≈ 14 530 | ≈ 21 650 |
| 1 550 (haut, +1 σ) | ≈ 10 450 | ≈ 15 250 | ≈ 22 720 |

- Tout vendu : 10 000 × 1,045 = 10 450 (intérêts simples ; 10 459 avec capitalisation mensuelle ; le moteur fixe, écart < 10 F).
- Lecture : avec l'ancrage, **Tout vendu ≈ +4,5 %, Rien fait ≈ +45 %**, écart ≈ 4 000 F. La barre Renforcé est la plus haute **en valeur absolue parce que 5 000 F de plus sont engagés** : recommandé d'ajouter à la légende de la barre « 5 000 F de plus engagés » (donnée `titre`), sinon elle se lit comme un conseil. Le texte, lui, ne la valorise pas (voir §1.2).
- Ordre de grandeur attendu pour le test CA-R7 : Rien fait / Tout vendu ≈ 1,38 ; Renforcé / Rien fait = 1,49 exactement en SICAV (1 + 4 900/10 000) ; vérifier par recalcul indépendant, pas par ces chiffres.

**Action Peugeot** (10 000 F = 20 titres à 500 F ; dividende de mai 1988 : 3,0 % × 620 F = 18,6 F par titre, impôt 16 %, `ecartDiv` Peugeot = 0, C) :

| Barre | Calcul | Ordre de grandeur |
|---|---|---|
| Tout vendu | 20 × 500 = 10 000, courtage 1,3 % = 130, soit 9 870, Livret A 4,5 % | ≈ 10 310 |
| Rien fait | 20 × 720 + 20 × 18,6 × 0,84 | ≈ 14 710 (brut de dividende : 14 770) |
| Renforcé | Rien fait + 9 titres entiers (4 500 + courtage 58,5) × (720 + 15,6) | ≈ 21 330 |

Le moteur achète des titres entiers (surplus au compte courant) ; les 4 440 F non employés ne sont pas dans la barre.

**Exemple (aucune action ni SICAV au krach)** : prendre 10 000 F de SICAV (`mention` : « Exemple : vous n'aviez ni actions ni SICAV en octobre 1987. »), mêmes formules, barres ≈ 10 450 / 14 460 / 21 550 avec l'ancrage.

Biais à ne pas cacher : 1988 est une année exceptionnelle (+57 %) ; la phrase « un seul exemple, pas une règle » et le texte sur 1929 portent ce contrepoids.

### 1.5 Formules pour le recalcul indépendant (CA-R7)

```
vendu    = montant * (1 + taux_livret/100 * 12/12)              # 4,5 % ; mêmes conventions que le moteur pour les intérêts
rien     = montant * Π_{m=11/1987..10/1988} [ I(m)/I(m-1) * (1 + d(annee(m))/1200) * (1 - 0,015/12) ]   # SICAV, VL
renforce = rien + (renfort * (1 - 0,02)) * Π(...)               # même produit, frais d'entrée 2 % sur le renfort
# Action : titres = floor(montant / (cours_10_1987 * (1 + courtage))) ; valeur = titres * cours_10_1988 + dividendes nets
```

---

## 2. Jean-Mi (docs/19 §1-2 : validation et corrections)

### 2.1 Ce qui est confirmé

| Point | Valeur | Cert. |
|---|---|---|
| Ancrages Peugeot 1986-1988 (36 mois) | JSON de docs/19 §1.2, **inchangé** | C |
| Règlement mensuel : couverture ≈ 20 %, report ≈ taux monétaire + commission (0,7 %/mois en 1987), appel de couverture puis liquidation d'office, perte possible au-delà de la mise | docs/19 §2.1 | A (principe) / B (taux) |
| Crédit : 110 000 F, 12 %, 48 mois, mensualité 2 897 F ; capital restant dû : 05/87 108 203 ; 09/87 100 834 ; 10/87 98 945 ; 11/87 97 037 ; 12/87 95 110 ; 01/88 93 164 ; 02/88 91 199 | recalculé (annuité) | calcul ; taux B/C (à confirmer par le banquier : K3) |
| Décote de la Porsche, vente 02/1988 à 91 000 F (solde 199 F négligé) | docs/19 §2.4 | C |
| Le vocabulaire « règlement mensuel » une fois, avec la glose | docs/19 §2.1 | - |

### 2.2 Trajectoire exacte (calcul à la main sur la série docs/19 §1.2, position 150 000 F puis 200 000 F)

| Mois | Cours | Gain brut du mois | Report | Cumul net (G) |
|---|---|---|---|---|
| 10/1986 | 540 | +5 769 | -1 050 | +4 719 |
| 11/1986 | 570 | +8 333 | -1 050 | +12 002 |
| 12/1986 | 600 | +7 895 | -1 050 | +18 847 |
| 01/1987 | 660 | +15 000 | -1 050 | +32 797 |
| 02/1987 | 700 | +9 091 | -1 050 | +40 838 |
| 03/1987 | 740 | +8 571 | -1 050 | +48 359 |
| 04/1987 | 725 | -3 041 | -1 050 | +44 268 |
| 05/1987 | 700 | -5 172 | -1 050 | +38 046 |
| 06/1987 | 690 | -2 143 | -1 050 | +34 853 |
| 07/1987 | 710 | +4 348 | -1 050 | +38 151 |
| 08/1987 (position 200 000) | 710 | 0 | -1 400 | +36 751 |
| 09/1987 | 680 | -8 451 | -1 400 | **+26 901** |
| 10/1987 (liquidation, pas de report) | 500 | -52 941 | 0 | -26 040 |

(Calcul exact : cumul net fin 09/1987 = 26 900,96 ; docs/19 donnait 26 900 ; perte d'octobre = 200 000 × (1 - 500/680) = 52 941,18 ; dette = 26 040,22.)

**Règle d'affichage du texte V13 (CA-R4, « au franc près »)** : arrondir chaque montant au franc, puis calculer `dette_affichée = perte_arrondie - couverture_arrondie` (couverture 26 901, perte 52 941, dette **26 040**), pour que la somme affichée tombe juste. Baisse affichée : 500/680 - 1 = -26,47 %, soit « 26,5 % ». Position : 200 000 F.

Exemple de V13 avec le gabarit de `lot_05.md` §5.2 : « Avec 26 901 F, Jean-Mi en a joué 200 000 au règlement mensuel (acheter à crédit sur la Bourse). Peugeot a perdu 26,5 % : 52 941 F de perte. Ses 26 901 F y sont passés, et il en doit encore 26 040. »

### 2.3 Écart de patrimoine de Jean-Mi face à Tonton Matelas (convention D3 : voiture comptée)

Écart = équité de bourse + 7 500 (liquide) - 37 500 (miroir) + valeur de la voiture - capital restant dû - mensualités payées (le dette de bourse est comprise dans l'équité négative ; son remboursement à 1 000 F/mois est neutre). Tata Livret = Tonton + intérêts du Livret (≈ +1 500 à +2 000 en 09/1987, C).

| Mois | Écart Jean-Mi - Tonton | Face à Tata (≈ -1 700) | Rang de Jean-Mi face au joueur passif |
|---|---|---|---|
| 10/1986 | +4 719 | ≈ +4 600 | devant dès ce mois (C) |
| 12/1986 | +18 847 | ≈ +18 600 | devant |
| 03/1987 | +48 359 | ≈ +46 900 | devant |
| 04/1987 | +44 268 (Porsche achetée : apport -30 000, voiture +140 000, crédit -110 000) | ≈ +42 700 | devant |
| 05/1987 | +34 946 | ≈ +33 300 | devant |
| 06/1987 | +28 671 | ≈ +27 000 | devant |
| 07/1987 | +28 905 | ≈ +27 200 | devant |
| 08/1987 | +24 459 | ≈ +22 700 | devant |
| **09/1987** | **+11 581** | **≈ +9 900** | devant (**marge minimale de J1**) |
| 10/1987 | -47 368 | ≈ -49 100 | **derrière** (passage entre 09 et 10/1987) |
| 11/1987 | -58 357 | ≈ -60 100 | derrière |
| 12/1987 | -66 347 | ≈ -68 000 | derrière |
| 01/1988 | -75 337 | ≈ -77 000 | derrière |
| 02/1988 -> 12/1988 (voiture vendue, solde 199 F) | **-85 210** | ≈ **-87 000 à -89 000** | dernier de la rue |

- **J1** : tenu, marge minimale **≈ +9 900 F en 09/1987** face à Tata (C). docs/19 annonçait 7 000 à 10 000 : la borne basse venait d'une somme erronée.
- **J2** : tenu largement (≈ -87 000 F face à Tata, soit plus de 10 % tant que le patrimoine de Tata est inférieur à ≈ 870 000 F).
- **Dépendance au miroir** : tous les chiffres supposent un compte de 37 500 F au 09/1986. Le plan est en **proportions** (D4) ; la voiture (140 000) et le crédit (110 000) sont des constantes. Si le compte miroir réel est plus faible, les gains diminuent proportionnellement et la marge de 09/1987 fond : sensibilité ≈ 4 000 à 5 000 F de marge pour 10 % de compte en moins (C). Seule `MESURE J1` tranche.
- **Leviers de réglage si J1 casse** (ordre de préférence, tous en données) :

| Levier | Effet sur la marge de 09/1987 |
|---|---|
| Cours Peugeot 09/1987 : 680 -> 690 | ≈ +2 800 F (200 000 × 10/710) ; **ne pas toucher à 10/1987** (500) |
| Cours Peugeot 08/1987 : 710 -> 720 | ≈ +2 800 F en août, repris en septembre si 09 inchangé (net nul) : à éviter seul |
| Décote de la Porsche en 09/1987 : 130 000 -> 133 000 | +3 000 F |
| Apport de 30 000 F -> 25 000 F (crédit 115 000) | ≈ -3 700 F net (déconseillé : plus de dette) |

### 2.4 Calendrier des changements de rang (pour D9)

Pour un joueur passif (proche de Tata) : Jean-Mi passe **devant le joueur en 10/1986** (premier mois autorisé), puis **derrière en 10/1987** (mois du krach, mois de pause : la notification de rang est alors **décalée à 11/1987**). Pour un joueur actif, le rang dépend de son patrimoine : aucun calendrier fixe (seulement les règles D9).

---

## 3. Les 7 jours du Lundi noir (tableau des clôtures) et nom de l'indice (B4 point 3)

### 3.1 Nom à afficher

| Question | Recommandation | Cert. |
|---|---|---|
| Libellé au-dessus du tableau | **« Indice de la Bourse de Paris, environ »** (c'est le nom de `periode_p1.json > nomsIndice` avant 06/1988 ; « Indice de Paris, environ » proposé est acceptable mais incohérent avec le bandeau du jeu) | B |
| Ne jamais écrire « CAC 40 » en 10/1987 | le CAC 40 naît le 31/12/1987 (base 1 000) | A |
| Note de bas de tableau (optionnelle, donnée) | « Échelle du jeu : les journaux de l'époque affichaient des valeurs 3,5 fois plus basses. » | A (rapport 3,52) |
| Mention d'incertitude | toute la colonne en « environ » ; valeurs arrondies à 5 points ; variation au dixième | - |

### 3.2 Valeurs à stocker (`krach.json > jours`)

Les jours 20, 21, 22, 23 et 26/10 sont des **valeurs de jeu (C)** : direction vraie (forte baisse le 20, rebond partiel le 21, nouvelle baisse jusqu'au 26), niveaux inventés. Les seuls points A sont le 16/10, la variation du 19/10, le 29/10 (1 033) et le 10/11 (963). Stocker `indice` **à 1 décimale** et laisser le code calculer `variation` sur les valeurs stockées (le contrat §4.3 donne `variation` en %, 0,0 le premier jour) ; arrondir à 5 points seulement pour l'affichage.

| `jour` (texte) | Date | `indice` stocké | Affiché (5 pts) | `variation` (calculée, au dixième) | `certitude` |
|---|---|---|---|---|---|
| vendredi 16 octobre | 16/10/1987 | 1 240,0 | 1 240 | 0,0 (afficher « - ») | A |
| lundi 19 octobre | 19/10/1987 | **1 119,7** (= 1 240 × 0,903) | 1 120 | **-9,7** | A (variation ; niveau B) |
| mardi 20 octobre | 20/10/1987 | 1 050,0 | 1 050 | -6,2 | C |
| mercredi 21 octobre | 21/10/1987 | 1 085,0 | 1 085 | +3,3 | C |
| jeudi 22 octobre | 22/10/1987 | 1 045,0 | 1 045 | -3,7 | C |
| vendredi 23 octobre | 23/10/1987 | 1 020,0 | 1 020 | -2,4 | C |
| lundi 26 octobre | 26/10/1987 | 990,0 | 990 | -2,9 | C |

Vérifications : jours de la semaine exacts (16/10/1987 vendredi) ; cumul 16 -> 26/10 = -20,2 % (A pour l'ordre de grandeur, C pour le détail) ; 7 lignes. Rapprochement avec le moteur : le **cours du mois** (A11) pour 10/1987 est **1 033** (29/10) : il est au-dessus de la dernière ligne (990 le 26/10). Pour ne pas troubler le joueur, ajouter une ligne de pied **en données** (`pied`) : « Cours retenu pour vos ordres ce mois-ci : environ 1 035 (29 octobre). » (ligne hors des 7 jours ; C pour le texte, A pour 1 033 arrondi à 5). Si le client refuse toute ligne en plus, afficher au moins la note du §3.1.

JSON prêt à coller :

```json
"jours": [
  {"jour": "vendredi 16 octobre", "indice": 1240.0, "certitude": "A"},
  {"jour": "lundi 19 octobre",    "indice": 1119.7, "certitude": "A"},
  {"jour": "mardi 20 octobre",    "indice": 1050.0, "certitude": "C"},
  {"jour": "mercredi 21 octobre", "indice": 1085.0, "certitude": "C"},
  {"jour": "jeudi 22 octobre",    "indice": 1045.0, "certitude": "C"},
  {"jour": "vendredi 23 octobre", "indice": 1020.0, "certitude": "C"},
  {"jour": "lundi 26 octobre",    "indice": 990.0,  "certitude": "C"}
],
"pied": "Cours retenu pour vos ordres ce mois-ci : environ 1 035 (29 octobre)."
```

Points de cohérence : (1) le texte existant de l'événement p1e6 porte `date_journal: "Mardi 20 octobre 1987"` et « Wall Street perd plus de 20 % en une seule séance » : exact pour le lundi 19 (A : -22,6 %), à lire comme le journal du lendemain ; (2) l'ancrage `1987-11 = 963` est un plus bas de séance (10/11), pas une fin de mois (voir base §3) : sans effet sur le tableau.

---

## 4. Kiosque : validation des 11 titres (B4 point 3)

Règles : titre ≤ 8 mots, au présent, **sans issue de marché** (A8). Livraison : mois indiqué, ou mois suivant (D8), sinon absent.

| Mois | Titre (≤ 8 mots) | Fait daté | Cert. | Verdict |
|---|---|---|---|---|
| 06/1984 | Les Bleus sacrés champions d'Europe | finale du 27/06/1984 | A | garder |
| 11/1984 | Canal+ débute à la télévision | 04/11/1984 | A | garder |
| 12/1985 | Coluche ouvre les Restos du cœur | première distribution 21/12/1985 | A | garder |
| 03/1986 | La droite gagne, Chirac à Matignon | législatives 16/03, nomination 20/03/1986 | A | garder |
| 05/1986 | Le nuage radioactif divise l'opinion | polémique début mai 1986 (Tchernobyl 26/04) | B | garder (le jour exact de la polémique est B) |
| 10/1986 | Prost de nouveau champion du monde | 26/10/1986 (Adélaïde) | A | garder |
| 04/1987 | Bouygues retenu pour reprendre TF1 | décision CNCL début avril 1987 | B | garder ; la vente au public est le 29/06/1987 (A) |
| ~~10/1987~~ | ~~LUNDI NOIR~~ | 19/10/1987 | A | **remplacer** : la modale du krach (avec pause) et sa séquence disent déjà tout ; le titre ferait doublon dans un mois à pause |
| **01/1988** (nouveau) | Les agents de change deviennent sociétés de bourse | 22/01/1988 | A | **ajouter** : titre de métier, pédagogique, mois vide |
| 05/1988 | Mitterrand réélu pour sept ans | 08/05/1988 | A | garder |
| ~~06/1988~~ | ~~Le CAC 40, nouvel indicateur en temps réel~~ | 15/06/1988 | A | **remplacer** : doublon exact de la notification de contexte 1988-06 « L'indice change de nom » (`periode_p1.json > contexte`) |
| **07/1987** (nouveau) | La corbeille de la Bourse de Paris disparaît | 14/07/1987 | A | **ajouter** : fin de la criée, comble le trou 06-09/1987 (mois S7 : notification sans pause tolérée) |
| 09/1988 | Séoul : le monde du sport en fête | Jeux 17/09 - 02/10/1988 | A | garder |

Résultat : **11 titres**, répartis 06/84, 11/84, 12/85, 03/86, 05/86, 10/86, 04/87, 07/87, 01/88, 05/88, 09/88 (écart maximal 14 mois entre 11/84 et 12/85 ; les voisins comblent). Optionnels si le game designer veut plus de matière (A) : 11/1987 « Suez : les souscripteurs paieront en 1988 » (paiement de moitié reporté ; QE n° 3362) et 06/1988 « Accords de Matignon sur la Nouvelle-Calédonie » (26/06/1988). Hors liste, déjà dans le jeu : « Saint-Gobain, et bientôt Paribas » (V08, 12/1986 ; Paribas privatisée le 19/01/1987, A).

---

## 5. Calendrier de la rue : conflits à arbitrer (D7-D9, budgets)

Budgets : ≤ 1 voisin tous les 2 mois ; ≤ 1 rue ou kiosque par mois ; pas de notification de voisin un mois à pause. D'après `15 §9` et le §2.4 ci-dessus :

| Mois | Éléments dus | Proposition d'arbitrage (priorité décroissante : ★ > rang > réactive > kiosque daté > voisin courant) |
|---|---|---|
| 06/1984 | V02 Matelas + kiosque Euro 84 | V02 au 06/1984 ; **Euro 84 reste en 06/1984 ou glisse en 07/1984** (D8 : le kiosque cède) |
| 09/1986 -> 10/1986 | V07 ★ (09), Prost (10), rang « Jean-Mi passe devant » (dès 10/1986) | V07 en 09, **rang en 10/1986** (au plus tôt, D9), **Prost glisse en 11/1986** (ou est abandonné) ; V08 (12/1986) à ≥ 2 mois de V07 : ok |
| 04/1987 | V09 ★ + kiosque Bouygues/TF1 | V09 en 04 ; kiosque **glisse en 05/1987** |
| 10/1987 | krach (pause) | aucune notification rue ; rang « Jean-Mi derrière » **décalé** |
| 11/1987 | rang décalé + réactive M. Lefranc (« le mois qui suit le krach ») ; V13 ★ en 12/1987 | **Conflit** : la réactive de Lefranc (voisin, 11/1987) et V13 ★ (12/1987) sont à 1 mois d'écart (règle : 1 voisin tous les 2 mois). Proposition : **supprimer la réactive de Lefranc** (V13 couvre le sujet) ; le rang « derrière » prend 11/1987 |
| 12/1987 | V13 ★ | ok ; kiosque le moins urgent glisse |
| 01/1988 | kiosque agents de change | ok |

Écart de budget attendu : au plus 2 titres de kiosque abandonnés (Euro 84 ou Prost ; Bouygues glisse seulement), à compter dans `CA-R5`.

---

## 6. Résumé des données à intégrer (pour dev-logique, sans ambiguïté)

| Fichier | Donnée | Valeur | Cert. |
|---|---|---|---|
| `periode_p1.json > ancragesIndice` | `["1988-10", 1470]` | ajout | C |
| `periode_p1.json > produits.peugeot.ancrages` | docs/19 §1.2 | inchangé | C |
| `krach.json > jours` | 7 lignes du §3.2 + `pied` | idem | A/C |
| `krach.json > texte_un_an_apres` | texte du §1.2 | 48 mots | B |
| `krach.json > exemple_montant` | 10 000 F de SICAV à la VL du mois 10/1987 | idem | C |
| `krach.json > renforcer` | +50 % de la position (SICAV : frais d'entrée 2 % ; action : courtage 1,3 % mini 50 F, titres entiers) | idem | C |
| `rue.json > kiosque` | 11 titres du §4 | idem | A/B |
| `temoins.json > jeanmi.plan` | docs/19 §2.2-2.4 en proportions ; mêmes chiffres (couverture 80 % du compte, position 5 ×, report 0,7 %, renfort 08/1987 +1/3, Porsche 140 000, apport 30 000, crédit 110 000 / 12 % / 48 mois, décote, vente 02/1988, dette 1 000 F/mois dès 12/1987) | idem | C |

## 7. Points encore incertains (C)

| Sujet | Pourquoi | Ce qui ferait passer en A/B |
|---|---|---|
| Clôtures du 20 au 26/10/1987 | aucune source en ligne | archive du Monde ou des Échos du 21 au 27/10/1987 dans `docs/sources/` |
| Niveaux de Peugeot 1986-1988 | cote officielle inaccessible | annuaire Desfossés, document de référence PSA |
| Indice de 10/1988 (1 470) | aucun ancrage réel trouvé | historique Euronext ou Banque de France |
| Retour du Dow à son sommet d'août 1987 | cité de mémoire (B) | relire l'historique du Dow |
| Taux du crédit auto 1987 (12 %) et prix d'une 944 d'occasion | validation du banquier (K3) | bulletin Banque de France, argus 1987 |
| Valeur du compte miroir au 09/1986 | dépend du moteur | `MESURE J1` sur 40 graines |

Sources utilisées : [Benzinga, Dow : retour au sommet de 1929 en 1954](https://www.benzinga.com/general/education/21/11/24250394/this-day-in-market-history-dow-completes-25-year-great-depression-recovery) ; docs/19 (sources listées en bas de ce fichier : Wikipedia Black Monday, Bank of England 1988, Wikimonde CAC 40, INSEE 12/1987, AN QE n° 3362, IGPDE) ; `godot/data/periode_p1.json`, `series.json`, `regles.json`, `banque.json` (lus le 2026-11-13).
