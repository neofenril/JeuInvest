# 19 - Contenu boursier pour le game design V3 (boursier)

> Réponse à `docs/lots/feuille_de_route.md` §7 (lignes 05-L et 06-L) et à `docs/15_spec_game_design_v3.md` §4.3, §4.4, §5, §10.2.
> Certitude : **A** vérifié (source publique), **B** probable (erreur < 5-10 %), **C** reconstitué (erreur 10-25 %). `docs/sources/` ne contient aucun document (seulement un LISEZMOI).
> **Limite honnête** : les cours de Peugeot en francs en 1986-1988 et les clôtures quotidiennes de l'indice du 20 au 26/10/1987 **n'ont pas pu être trouvés en ligne** (ni Euronext, ni presse en accès libre). Ce sont des **reconstitutions (C)** calées sur des repères A/B. Les niveaux sont jouables et cohérents avec l'histoire ; ils ne doivent pas être présentés comme des cotations officielles (mention « environ » ou arrondis à 5 F / 5 points).
> Échelle des indices : **base CAC 40 = 1000 au 31/12/1987** (CAC Général rétropolé × 3,52), comme `periode_p1.json`.

---

## 1. Peugeot : ancrages mensuels 1986-1988 (fins de mois, en francs)

### 1.1 Repères sur lesquels la série est calée

| Repère | Valeur | Cert. |
|---|---|---|
| Fins d'année déjà dans `periode_p1.json` (gardées) | 12/1985 300 ; 12/1986 600 ; 12/1987 450 ; 12/1988 800 | C (validés au §4 de ma base) |
| Indice (échelle CAC 40) | 12/1986 non listé ; 01/1987 1 450 ; 03/1987 1 500 ; 06/1987 1 400 ; 09/1987 1 310 ; 16/10 1 240 ; 29/10 1 033 ; 10/11 963 ; 12/1987 1 000 ; 06/1988 1 300 | A/B (voir ma base §2.1) |
| Bêta Peugeot | 1,3 (`periode_p1.json`) | C |
| Contexte | 205 (lancée 1983) en plein succès, Peugeot SA redevenue bénéficiaire en 1985-1986 après les pertes de 1984 (Talbot) ; Peugeot **n'a pas été privatisée** (société privée familiale) | B |
| INSEE (note de conjoncture 12/1987) | cours des actions revenus fin 1987 au niveau du début 1986, ≈ 30 % sous le plus haut du 1er semestre 1987 | B |

Méthode : la série suit `bêta × indice` (écarts résiduels < 10 % chaque mois), plus un tempo propre au titre (hausse 1986 portée par les résultats). Chaque mois est un **ancrage dur** (série déterministe, pas de tirage libre entre deux mois).

### 1.2 Tableau exploitable (fin de mois, F, certitude C sauf mention)

| Mois | Cours | Mois | Cours | Mois | Cours |
|---|---|---|---|---|---|
| 1986-01 | 310 | 1987-01 | 660 | 1988-01 | 480 |
| 1986-02 | 320 | 1987-02 | 700 | 1988-02 | 520 |
| 1986-03 | 345 | 1987-03 | 740 | 1988-03 | 550 |
| 1986-04 | 370 | 1987-04 | 725 | 1988-04 | 590 |
| 1986-05 | 385 | 1987-05 | 700 | 1988-05 | 620 |
| 1986-06 | 400 | 1987-06 | 690 | 1988-06 | 630 |
| 1986-07 | 440 | 1987-07 | 710 | 1988-07 | 650 |
| 1986-08 | 470 | 1987-08 | 710 | 1988-08 | 640 |
| 1986-09 | **520** | 1987-09 | **680** | 1988-09 | 680 |
| 1986-10 | 540 | 1987-10 | **500** (fin d'octobre, ≈ 29/10) | 1988-10 | 720 |
| 1986-11 | 570 | 1987-11 | 440 | 1988-11 | 770 |
| 1986-12 | 600 | 1987-12 | 450 | 1988-12 | **800** |

JSON prêt à coller (`ancrages` de `peugeot`, remplace la liste actuelle pour 1986-1988 ; les fins d'année antérieures restent) :

```
["1986-01",310],["1986-02",320],["1986-03",345],["1986-04",370],["1986-05",385],["1986-06",400],
["1986-07",440],["1986-08",470],["1986-09",520],["1986-10",540],["1986-11",570],["1986-12",600],
["1987-01",660],["1987-02",700],["1987-03",740],["1987-04",725],["1987-05",700],["1987-06",690],
["1987-07",710],["1987-08",710],["1987-09",680],["1987-10",500],["1987-11",440],["1987-12",450],
["1988-01",480],["1988-02",520],["1988-03",550],["1988-04",590],["1988-05",620],["1988-06",630],
["1988-07",650],["1988-08",640],["1988-09",680],["1988-10",720],["1988-11",770],["1988-12",800]
```

### 1.3 Contrôles demandés par la spec

| Contrôle | Résultat |
|---|---|
| Plus haut avant krach | 740 (03/1987) ; niveau juste avant le krach (16/10) ≈ **640** (680 × (1 240 / 1 310)^1,3) |
| Baisse sur octobre 1987 (fin sept. → fin oct.) | 680 → 500 = **−26,5 %** (indice : 1 310 → 1 033 = −21 %, × bêta 1,3 ≈ −27 %) |
| Plus bas | 440 (11/1987) |
| **V16** : Peugeot 12/1988 au-dessus du niveau d'avant le krach | 800 > 680 (fin sept.) > 640 (16/10) et > 740 (plus haut de 03/1987) : **oui, marge de 8 % au-dessus même du plus haut de 1987**. 11/1988 (770) est déjà au-dessus de 680. |
| Fin 1986 / indice | 600 ; cohérent avec le profil CA-21 (×2 en 1986, forte progression) |
| Joueur « tout sur Peugeot, sans crédit » | 09/1986 → 12/1988 : 520 → 800 = +54 % hors dividendes ; il ne finit jamais derrière Jean-Mi (voir §2.5) |

**Points à signaler** : (1) le niveau absolu de 1986-1987 est un C (la cote officielle n'est pas accessible en ligne) ; (2) l'ancrage d'indice `1987-10 = 1033` est en réalité le **29/10**, pas la fin du mois : la baisse mensuelle d'octobre 1987 de la Bourse de Paris est citée vers **−25 %** (Wikimonde, B), ce qui donnerait une clôture du 30/10 d'environ 1 000 pour 1 310 fin septembre. Écart de 3 % tolérable ; à ne pas « corriger » sans décision. (3) Le Bank of England Quarterly Bulletin (1988) cite −34 % pour Paris entre le 5/10 et le plus bas, ce qui est difficile à concilier avec 963 (10/11) sauf si le plus bas est plus profond que mes repères : **un doute C subsiste sur le plus bas exact** ; sans effet sur le jeu.

---

## 2. Jean-Mi : règlement mensuel, étapes, trajectoire, crédit Porsche

### 2.1 Le règlement mensuel pour un particulier en 1986-1987 (pédagogie)

| Notion | Fait | Cert. |
|---|---|---|
| Principe | Sur le marché à règlement mensuel (RM), on achète sans payer tout de suite : le paiement et la livraison ont lieu à la **liquidation** de fin de mois. On peut revendre dans le mois sans avoir sorti la somme : on ne touche que la différence. | A |
| Couverture | Dépôt de garantie en espèces ou en titres, de l'ordre de **20 %** de la position (donc position = 5 × couverture) | B (le taux variait selon les valeurs et les sociétés de bourse) |
| Report | Pour conserver la position au mois suivant, on la « reporte » : coût ≈ taux du marché monétaire + commission. Taux à 3 mois 1987 : 8,3 % (ma base §2.7) soit ≈ 0,7 % par mois de la position. | B |
| Appel de couverture | Si la perte entame la couverture, le courtier (l'agent de change, société de bourse dès le 22/01/1988) demande un complément. En cas de défaut : **liquidation d'office** de la position. | A (principe) |
| Dette | Si la baisse dépasse la couverture, la différence est due au courtier : on peut perdre **plus que sa mise**. | A |
| Vocabulaire | Le mot « règlement mensuel » est correct et historique ; le SRD le remplace en 09/2000. **Recommandation : le garder une fois** dans la carte de lecture V13, avec la glose « (acheter à crédit sur la Bourse) », puis « à crédit ». | - |

### 2.2 Paramètres du plan (remplacent le tableau provisoire de 15 §4.3)

| Paramètre | Valeur | Cert. |
|---|---|---|
| Compte de Jean-Mi à 09/1986 (miroir de Gérard) | **37 500 F** (vérifier avec la valeur réelle du miroir) | - |
| Couverture | 30 000 F (80 %) | - |
| Position 09/1986 → 07/1987 | 150 000 F (5 × couverture), achetée à la clôture de 09/1986 (520 F) | - |
| Renfort 08/1987 | + 50 000 F de position (total **200 000 F**), à la clôture de 07/1987 (710 F) | - |
| Report | 0,7 % de la position par mois, de 10/1986 à 09/1987 (octobre 1987 : liquidation, pas de report) | B |
| Gains mensuels | position × (cours du mois / cours du mois précédent − 1), encaissés à chaque liquidation | - |
| Couverture de référence | gardée fixe à 30 000 F (les gains au-delà sont dépensés ou placés sur le compte courant) | convention |
| Apport Porsche (04/1987) | 30 000 F prélevés sur les gains | - |

### 2.3 Étapes et chiffres (sur la série du §1.2)

| Date | Étape | Chiffres |
|---|---|---|
| 01/1984 → 08/1986 | miroir de Gérard, tout au compte courant, « attend le bon tuyau » | - |
| 09/1986 | achète du Peugeot au RM (V07) | 150 000 F à 520 F |
| 10/1986 → 03/1987 | la montée | gains cumulés 54 659 F, reports 6 300 F (03/1987) |
| 04/1987 | Porsche 944 d'occasion à crédit (V09) | voir §2.4 ; apport 30 000 F pris sur les gains |
| 08/1987 | renforce (V10) | position 200 000 F |
| 09/1987 | Peugeot recule (710 → 680) | gain du mois −8 451 F, report −1 400 F |
| **Fin 09/1987** | **couverture restante** | **26 900 F** |
| 10/1987 | krach : 680 → 500 = **−26,5 %** | **perte 52 941 F** = 26 900 F (couverture) + **dette 26 041 F** |
| 11/1987 | panneau « À VENDRE » (V12) | valeur estimée de la voiture 115 000 F |
| 12/1987 | V13 | « Avec 26 900 F, Jean-Mi en a joué 200 000. Peugeot a perdu 26,5 % : 52 941 F de perte. Ses 26 900 F y sont passés, et il en doit encore 26 041. » (**couverture + dette = perte, au franc près**) |
| 02/1988 | Porsche vendue | −35 % sur 140 000 F = **91 000 F** ; solde du crédit à cette date : 91 201 F, donc le prix règle presque tout (il reste 201 F, à négliger : traiter comme soldé) |
| 12/1987 → 02/1990 | rembourse la dette de bourse | **1 000 F par mois** (≈ 26 mois), sans intérêt de retard modélisé ; au bilan 12/1988, reste 13 041 F |

La phrase du levier gagne à utiliser « couverture » = la valeur en fin de septembre (26 900 F), pas les 30 000 F de départ : c'est elle qui doit vérifier couverture + dette = perte.

### 2.4 Crédit de la Porsche

| Paramètre | Valeur | Cert. |
|---|---|---|
| Prix | 140 000 F (944 d'occasion, plausible en 1987 ; le neuf dépassait 200 000 F) | C |
| Apport | 30 000 F | - |
| Crédit | 110 000 F sur 48 mois | - |
| Taux nominal annuel | **12 %** (crédit à la consommation en 1987 : 11 à 14 % TEG) | B/C |
| Mensualité | **2 897 F** (calcul : 110 000 × 0,01 / (1 − 1,01^−48)) | calcul |
| Capital restant dû après n mensualités | 05/87 : 108 203 ; 09/87 : 100 833 ; 02/88 (après 10) : 91 201 | calcul |
| Décote de la voiture (valeur de marché) | 04/87 140 000 ; 05 138 000 ; 06 136 000 ; 07 134 000 ; 08 132 000 ; 09 130 000 ; 10 125 000 ; 11 115 000 ; 12 108 000 ; 01/88 100 000 ; 02/88 91 000 (vendue) | C |

Les mensualités sont payées sur le budget courant de Jean-Mi ; **le compte courant peut devenir débiteur** (2 897 F dépasse sans doute son excédent mensuel). Aucun agio à modéliser.

### 2.5 Contraintes J1 / J2 vérifiées à la main

Convention de patrimoine **à fixer par le game designer** : patrimoine de Jean-Mi = compte courant + équité du compte de bourse (couverture ± gains, négative après liquidation) + **valeur de marché de la voiture** − capital restant dû − dette de bourse. Si la voiture n'est pas comptée, Jean-Mi serait à −100 000 F dès 04/1987 et J1 tomberait : **la voiture doit être comptée**. Soit S le cumul de l'excédent de budget commun (même pour tous, miroir).

| Date | Jean-Mi | Tata Livret (référence) | Écart |
|---|---|---|---|
| 03/1987 | S + 85 900 (équité 78 359 + liquide 7 500) | S + ≈ 39 000 | **+ 47 000** |
| 09/1987 | S + 46 000 (équité 26 900 + liquide 7 500 + voiture 130 000 − crédit 100 833 − mensualités 14 485) | S + ≈ 39 200 (37 500 + intérêts du Livret à 4,5 %) | **+ ≈ 7 000 à 10 000 (marge mince : ne pas durcir la décote de la voiture avant 09/1987)** |
| 12/1988 | S − 47 700 (liquide 7 500 − mensualités 28 970 + (91 000 − 91 201) − dette 26 041) | S + ≈ 41 500 | **− ≈ 89 000** |
| 12/1988, Tonton Matelas | - | S + 37 500 (nominal) | Jean-Mi derrière de ≈ 85 000 |

- **J1** (devant Tata 03/1987 → 09/1987) : tenu, mais la marge en septembre est faible (≈ 7 000 F). C'est le seul mois à surveiller ; si le moteur impose un patrimoine de Tata plus élevé que ci-dessus, remonter légèrement le cours d'août-septembre de Peugeot ou baisser la décote de la voiture en 09/1987.
- **J2** (derrière Tata d'au moins 10 % en 12/1988, dernier de la rue) : tenu largement (écart ≈ 89 000 F). Le joueur « tout sur Peugeot sans crédit » finit au-dessus (pas de dette, +54 %).
- **Test à faire par le moteur** : ces calculs sont à la main sur des hypothèses de miroir ; relancer CA-3.1 sur la série réelle (40 graines).
- **Rang de Jean-Mi dans la rue au pic** : dès 12/1986 il est devant Tata et Tonton (≈ +19 000 F de gains nets) ; « Jean-Mi passe devant » se produirait en 10-12/1986. Le plan de 15 §4.4 le met au 04/1987 : l'événement de rang peut simplement être **celui qui est déclenché en premier** (au plus une notification par 6 mois).

---

## 3. Le kiosque : titres datés 1984-1988

Reformulés (pas de titre de presse copié), ≤ 8 mots, formulés au présent, **sans annoncer d'issue de marché** (règle A8). Certitude portée sur la date. ★ = déjà dans la spec 15 §4.4.

| Mois | Titre proposé | Fait (date) | Cert. |
|---|---|---|---|
| 01/1984 | Le Livret A reste le placement favori des Français | titre de contexte, sans date précise | C (optionnel) |
| 03/1984 | Les Français s'inquiètent du chômage | 2 millions de chômeurs en 1984 | B |
| 06/1984 ★ | Les Bleus sacrés champions d'Europe | finale Euro 84, 27/06/1984 | A |
| 07/1984 | Fabius remplace Mauroy à Matignon | 17/07/1984 | A |
| 07/1984 | Fignon gagne le Tour de France | 22/07/1984 | A |
| 11/1984 ★ | Canal+ débute à la télévision | 04/11/1984 | A |
| 11/1984 ★ | Le Top 50 entre dans les foyers | Top 50 sur Canal+, fin 1984 | B (jour) |
| 03/1985 | Gorbatchev prend la tête de l'URSS | 11/03/1985 | A |
| 07/1985 | Un bateau de Greenpeace coulé à Auckland | Rainbow Warrior, 10/07/1985 | A |
| 10/1985 | Prost sacré champion du monde | titre 1985, 06/10/1985 | A |
| 12/1985 ★ | Coluche ouvre les Restos du cœur | première distribution, 21/12/1985 | A |
| 02/1986 | Un tunnel sous la Manche : feu vert | accord franco-britannique 12/02/1986 | A |
| 03/1986 ★ | La droite gagne, Chirac à Matignon | législatives 16/03, nomination 20/03/1986 | A |
| 04/1986 | Nuage de Tchernobyl : que dit-on aux Français ? | accident 26/04/1986 | A |
| 05/1986 ★ | Le nuage radioactif divise l'opinion | polémique début mai 1986 | B |
| 06/1986 | La Bourse passe en cotation continue | CAC (06/1986) | A |
| 06/1986 | Les Bleus finissent troisièmes au Mexique | 28/06/1986 | A |
| 09/1986 | Série d'attentats à Paris | 17/09/1986 (rue de Rennes) | A |
| 10/1986 ★ | Prost de nouveau champion du monde | 26/10/1986 (Adélaïde) | A |
| 11/1986 | Saint-Gobain : l'État vend ses actions au public | mise en vente 24/11/1986 | A |
| 12/1986 | Étudiants dans la rue contre la loi Devaquet | début déc. 1986 (retrait 08/12) | A |
| 01/1987 | Paribas ouvre son capital aux particuliers | 19/01/1987 | A |
| 04/1987 ★ | Bouygues retenu pour reprendre TF1 | attribution CNCL, avril 1987 | B |
| 05/1987 | Le procès Barbie s'ouvre à Lyon | 11/05/1987 | A |
| 06/1987 | La Société Générale cherche 2 millions d'actionnaires | OPV 15-27/06/1987 | A |
| 06/1987 | TF1 : mise en vente au public | 29/06/1987 | A |
| 07/1987 | La corbeille de la Bourse de Paris disparaît | 14/07/1987 | A |
| 09/1987 | Rentrée : la Bourse de Paris à haut niveau | contexte ; **sans** prévision | B |
| 10/1987 | (début) Tempête sur la Bretagne | 15-16/10/1987 | A |
| 10/1987 ★ | **LUNDI NOIR** (figé jusqu'à 11/1987) | 19/10/1987 | A |
| 11/1987 | Suez : les souscripteurs paieront en 1988 | report de moitié de paiement | A (QE n° 3362) |
| 12/1987 | Accord Washington : les missiles à moyenne portée seront retirés | 08/12/1987 | A |
| 01/1988 | Fin des agents de change : place aux sociétés de bourse | 22/01/1988 | A |
| 03/1988 | Les Français discutent du nouveau pouvoir d'achat | titre générique, optionnel | C |
| 05/1988 ★ | Mitterrand réélu pour sept ans | 08/05/1988 (54 %) | A |
| 05/1988 | Rocard à Matignon | 10/05/1988 | A |
| 06/1988 ★ | Le CAC 40, nouvel indicateur en temps réel | création 31/12/1987 ; diffusion continue 15/06/1988 | A |
| 06/1988 | Accords de Matignon sur la Nouvelle-Calédonie | 26/06/1988 | A |
| 09/1988 ★ | Séoul : le monde du sport en fête | Jeux 17/09-02/10/1988 | A |
| 11/1988 | Le RMI approche | loi du 01/12/1988, débat en nov. | B |

Remarques : (1) l'**Euro 84** du 06/1984 est en avance de peu sur la période ; (2) « Paribas » dans V08 (12/1986) : **correct à moitié**, Paribas est privatisée le **19/01/1987**, pas en décembre 1986 : à reformuler en « Saint-Gobain, bientôt Paribas » ou à décaler V08 en 02/1987 (A) ; (3) « TF1 privatisée » de la spec (04/1987) est prématurée : l'attribution à Bouygues est d'avril (B) et la vente au public du 29/06/1987 (A) ; (4) fixer le panneau de 10/1987 sur « LUNDI NOIR » (A) est cohérent avec la règle de A5.

---

## 4. Lundi noir : contexte et clôtures quotidiennes de l'indice de Paris, 16-26 octobre 1987

### 4.1 Contexte (A sauf mention)

| Fait | Détail |
|---|---|
| Wall Street | vendredi 16/10 : Dow Jones −4,6 % (−108 points, à 2 246,74) ; lundi 19/10 : **−22,6 %** (−508 points, à 1 738,74), plus forte baisse en une séance de son histoire |
| Paris | lundi 19/10 : **≈ −9,7 %** (indice de l'époque, CAC Général ; certitude A pour le pourcentage, B pour la valeur exacte) ; octobre 1987 : environ **−25 %** (B) |
| Facteurs invoqués | hausse des taux américains et inquiétudes sur l'inflation ; déficit commercial américain élevé (publié le 14/10) ; baisse du dollar et tensions entre Washington et Bonn sur les taux (déclaration du week-end du 17-18/10) ; ventes automatiques de couverture de portefeuilles (« portfolio insurance ») ; peu de liquidité pour absorber les ordres de vente | B |
| Europe | tempête dans le sud de l'Angleterre dans la nuit du 15 au 16/10 : Londres fermée le vendredi 16/10 ; Londres, Francfort, Paris et Tokyo suivent la baisse le lundi | A |
| Paris, particularité | marché en pleine mutation (CAC en 1986, fin de la criée en 07/1987) ; privatisations en cours (Suez en offre depuis le 05/10) ; **pas de fermeture** de la Bourse | A/B |
| Réaction | mardi 20/10 : la Réserve fédérale affirme sa disposition à fournir des liquidités ; reprise brève à New York, mais les bourses européennes continuent de baisser plusieurs jours | A |
| Opinion | « 1929 ? » est la question de la semaine ; l'économie n'a pas basculé en récession en 1988 (croissance française 1988 : +4,5 %) | B |

### 4.2 Clôtures quotidiennes (indice de Paris, échelle CAC 40) - **reconstitution C**, sauf deux points A

Règle d'affichage conseillée : arrondir à 5 points (« ≈ 1 045 »), pourcentage au dixième.

| Date | Jour | Clôture | Variation | Cert. |
|---|---|---|---|---|
| 16/10/1987 | vendredi | **1 240** | non connue (≈ −5 % depuis fin septembre) | A (niveau, ma base) |
| 19/10/1987 | lundi | **1 120** | **−9,7 %** | A (variation) |
| 20/10/1987 | mardi | 1 050 | ≈ −6,2 % | C |
| 21/10/1987 | mercredi | 1 085 | ≈ +3,3 % (rebond technique, Wall Street repart) | C |
| 22/10/1987 | jeudi | 1 045 | ≈ −3,7 % | C |
| 23/10/1987 | vendredi | 1 020 | ≈ −2,4 % | C |
| 26/10/1987 | lundi | 990 | ≈ −2,9 % | C |
| 29/10/1987 | jeudi | **1 033** | rebond de ≈ +4 % sur le plus bas | A (niveau, ma base) |
| 10/11/1987 | mardi | **963** | plus bas retenu pour le jeu | A (ma base) |

- Cumul 16 → 26/10 : 1 240 → 990 = **−20 %** ; depuis le point haut de 03/1987 (1 500) : −34 %.
- Seuls les points 16/10, 19/10 (variation), 29/10 et 10/11 sont solidement documentés ; **les 20, 21, 22, 23 et 26/10 sont inventés dans une fourchette crédible** (la vraie direction : forte baisse le 20, rebond partiel, nouvelle baisse jusqu'à la fin du mois). Si le client dispose d'une page d'archive (Le Monde, Les Échos), la remplacer.
- Les 5 jours doivent s'afficher sous l'étiquette « environ » et sans pourcentage au-delà de la décimale.
- Pour la séquence de 15 s : Peugeot dans le jeu peut être affiché à titre indicatif : 16/10 ≈ 640 ; 26/10 ≈ 470 ; 29/10 ≈ 500 (fin du mois = ancrage 500).
- Vérification d'ordre de grandeur : Wikimonde et la Bank of England (Quarterly Bulletin 1988, −34 % depuis le 5/10) concordent sur une baisse de 25 à 34 % de Paris en octobre 1987 ; le point 26/10 (990) correspond à −24 % depuis fin septembre.

---

## 5. Décisions et questions pour le chef de projet et le client

1. Valider la **convention de patrimoine de Jean-Mi** (voiture comptée à sa valeur de marché) et le chiffre de Tata au miroir (§2.5) : sans cela J1 n'est pas démontrable.
2. Remplacer les ancrages de Peugeot 1986-1988 par le JSON du §1.2.
3. Décider du sort du mot « règlement mensuel » (je recommande : une fois, glosé).
4. V08 : « Paribas » trop tôt (voir §3), et kiosque 04/1987 « TF1 privatisée » à reformuler.
5. Les clôtures du 20 au 26/10 sont C : acceptable pour une séquence animée de 15 s ? (oui, à mon avis, avec « environ »).
6. Le banquier doit confirmer le taux du crédit auto de 1987 (12 % choisi en B/C) et la date des taux du Livret A (4,5 % depuis 06/1986, A).

Sources : [Wikipedia, Black Monday 1987 (Dow Jones, contexte)](https://en.wikipedia.org/wiki/Black_Monday_(1987)) ; [Bank of England, The equity market crash (1988)](https://www.bankofengland.co.uk/-/media/boe/files/quarterly-bulletin/1988/the-equity-market-crash) ; [Wikimonde, CAC 40 (baisse mensuelle d'octobre 1987)](https://wikimonde.com/article/CAC_40) ; [INSEE, vue d'ensemble de conjoncture, 12/1987](https://www.insee.fr/fr/statistiques/fichier/1407984/vue_ensemble_8712.pdf) ; [Assemblée nationale, QE n° 3362 (Suez)](https://www.assemblee-nationale.fr/dyn/9/questions/QANR5L9QE3362.pdf) ; [IGPDE, dates des privatisations](https://books.openedition.org/igpde/3866?dir=next). Les cours de Peugeot et les clôtures du 20 au 26/10 ne viennent d'aucune source : reconstitutions.
