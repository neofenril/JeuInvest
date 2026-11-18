# 33. Boursier : extension aux autres décennies (B3, B2, B1)

> Réponse aux demandes B1, B2, B3 de `docs/lots/plan_extension_annees.md` §4.1. Date : 2026-11-18.
> Certitude : **A** vérifié en source publique ; **B** probable (erreur < 5-10 %) ; **C** reconstitué (10-25 %). « Fin de mois » = clôture du dernier jour ; « séance » = point intra-journalier ou clôture d'un jour précis.
> Vérifié en ligne dans cette mission : clôture du 12/03/2020 (4 044, −12,28 %, −32,35 % depuis le 01/01, BFM Bourse), plus haut du 19/02/2020 (6 111,24), clôtures de fin de février (5 309,9) et de mars 2020 (4 396,12), plus bas du 18/03/2020 (3 754,84) (convextrade.com). **Tout le reste de B3 vient de ma mémoire de marché ou de docs/02 : à recouper sur Euronext (getHistoricalPrice FR0003500008) avant calibrage fin.** Aucune source en ligne trouvée pour les clôtures journalières du 6 au 17/03/2020 : points C.
> Cours d'action : jamais dans une table de ce document sans mention « ajusté » : toutes les valeurs sont des prix de l'époque rapportés à l'action actuelle (divisions de nominal appliquées), comme en V1.

---

## B3. Chapitre 2019-2023 : marché P3 (priorité 1)

### B3.1 Indice CAC 40, fin de mois, 12/2018 → 12/2023 (prêt à recopier dans `periode_p3.json`)

Les ancrages de P3 (V1) pour 2019-2023 sont **épars** (pas de 2019, 2021, 2023) : le pont brownien serait trop libre. Je propose une série mensuelle complète. Les mois marqués A sont ceux de la V1 ou vérifiés ; les autres sont **B** (mémoire, ±1 %, à recouper).

| Mois | Indice | Cert. | | Mois | Indice | Cert. |
|---|---|---|---|---|---|---|
| 2018-12 | 4 730,7 | A | | 2021-07 | 6 612,8 | B |
| 2019-01 | 4 980,8 | B | | 2021-08 | 6 680,2 | B |
| 2019-02 | 5 266,0 | B | | 2021-09 | 6 516,9 | B |
| 2019-03 | 5 350,5 | B | | 2021-10 | 6 830,8 | B |
| 2019-04 | 5 586,4 | B | | 2021-11 | 6 739,7 | B |
| 2019-05 | 5 207,6 | B | | 2021-12 | 7 153,0 | A |
| 2019-06 | 5 538,9 | B | | 2022-01 | **6 965** | B (la V1 a 7 376 = plus haut de séance du 05/01) |
| 2019-07 | 5 518,9 | B | | 2022-02 | 6 659 | A |
| 2019-08 | 5 480,5 | B | | 2022-03 | 6 660 | A |
| 2019-09 | 5 677,7 | B | | 2022-04 | 6 535 | B |
| 2019-10 | 5 729,9 | B | | 2022-05 | 6 469 | A |
| 2019-11 | 5 905,7 | B | | 2022-06 | 5 923 | A |
| 2019-12 | 5 978,1 | A | | 2022-07 | 6 449 | B |
| 2020-01 | 5 806 | A | | 2022-08 | 6 142 | B (V1 : 6 125) |
| 2020-02 | 5 309,9 | A | | 2022-09 | **5 762** | B (V1 : 5 677 = clôture du 29/09, pas la fin de mois) |
| 2020-03 | 4 396,1 | A (fin de mois ; voir B3.3 pour le cours « de vitrine ») | | 2022-10 | 6 267 | B (V1 : 6 273) |
| 2020-04 | 4 572 | A | | 2022-11 | 6 738 | B |
| 2020-05 | 4 695 | A | | 2022-12 | 6 473,8 | A |
| 2020-06 | 4 936 | A | | 2023-01 | 7 082 | B |
| 2020-07 | 4 783 | B | | 2023-02 | 7 268 | B |
| 2020-08 | 4 966 | B | | 2023-03 | 7 322 | B |
| 2020-09 | 4 803 | A | | 2023-04 | 7 492 | B |
| 2020-10 | 4 594,6 | A | | 2023-05 | 7 099 | B |
| 2020-11 | 5 518,9 | A | | 2023-06 | 7 400 | B |
| 2020-12 | 5 551,4 | A | | 2023-07 | 7 499 | B |
| 2021-01 | 5 399 | B | | 2023-08 | 7 317 | B |
| 2021-02 | 5 704 | B | | 2023-09 | 7 136 | B |
| 2021-03 | 6 067 | B | | 2023-10 | 6 885 | B |
| 2021-04 | 6 270 | B | | 2023-11 | 7 250 | B |
| 2021-05 | 6 447 | B | | 2023-12 | 7 543,2 | A |
| 2021-06 | 6 508 | B | | | | |

Corrections à la V1 (`periode_p3.js`) pour respecter la convention « fin de mois » (docs/boursier §3) : 2022-01 : 7 376 -> 6 965 ; 2022-09 : 5 677 -> 5 762 ; 2022-08 : 6 125 -> 6 142 ; 2022-10 : 6 273 -> 6 267. Les mois de crise (`moisCrise`) 2022-06 et 2022-09 sont conservés ; ajouter 2020-02/03/04 (déjà), 2023-03.
Repères A utiles aux textes : plus haut du 19/02/2020 = 6 111 ; 12/03/2020 = 4 044 (−12,28 %, record historique de baisse) ; 2020 : −7,14 % ; 2021 : +28,85 % ; 2022 : −9,5 % ; 2023 : +16,5 %.

### B3.2 Les 4 actions, ancrages (en €, prix ajustés)

Les clôtures de fin de décembre de la V1 sont plausibles (B). Pour les mois intermédiaires, je n'ai **pas** de séries mensuelles vérifiées : je ne donne que les points qui servent le récit (C), le pont brownien (bêta, volatilité spécifique de P3) comblant le reste.

| Mois | LVMH | TotalEnergies | BNP Paribas | Orange | Cert. |
|---|---|---|---|---|---|
| 2018-12 | 258 | 46 | 39,5 | 14,2 | B |
| 2019-12 | 414 | 49 | 52,8 | 13,1 | B |
| 2020-02 | 360 | 42 | 41 | 12 | C |
| 2020-03 (point de séance du 18/03, voir B3.3) | 280 | 23 | 25 | 9,9 | C (fin de mars réelle : ≈ 310 / ≈ 33 / ≈ 30 / ≈ 10,5, C) |
| 2020-12 | 511 | 35 | 43,1 | 9,7 | B |
| 2021-12 | 700 | 44,6 | 60,8 | 9,6 | B |
| 2022-06 | 570 | 49 | 47 | 9 | C |
| 2022-12 | 680 | 58,7 | 53,2 | 9,4 | B |
| 2023-03 | 860 | 58 | 55 | 10,5 | C (BNP ≈ −11 % en mars : banques) |
| 2023-12 | 733 | 61,6 | 62,6 | 10,3 | B |

- **Dividendes** (mai) : BNP **0 en 2020** (la BCE a imposé la suspension des dividendes 2019 ; le dividende de 1,11 € est versé en 2021) : `divNul: [2020]`, certitude B. Orange a réduit et fractionné son dividende 2020 (C : ne pas modéliser, simple note). TotalEnergies et LVMH maintenus (B). Écarts de rendement : inchangés (docs/03 §7.4).
- **Convention** : l'ancrage 2020-03 des actions et celui de l'indice doivent être **cohérents entre eux**. Voir la décision B3.3.
- **ETF CAC 40** : aucun ancrage propre, il suit l'indice (frais 0,25 %/an, docs/03 §7.3).
- **ETF monde (optionnel, utile à la leçon « un seul pays = un seul risque »)** : rendement annuel en euros, dividendes réinvestis, ordre de grandeur (B) : 2019 +30 % ; 2020 +6 % ; 2021 +31 % ; 2022 −13 % ; 2023 +20 %. Creux du Covid ≈ −33 % (19/02 -> 23/03/2020, B). Recommandation : **ne pas l'inclure** dans les 4 actions + 1 fonds du chapitre ; le mentionner seulement dans la carte « un an après » ou au bilan (« un fonds mondial se serait mieux comporté que le CAC en 2019-2023 », ce qui est vrai : CAC ≈ +60 % prix contre ≈ +95 % pour le monde sur 5 ans en euros, C).

### B3.3 Vitrine Covid : séquence jour par jour (février-mars 2020)

Principe : **A11** (un seul cours par mois) s'applique. Précédent du Lundi noir : l'ancrage d'octobre 1987 est le **29/10 (1 033)**, pas la fin de mois (docs/boursier §3, mission du 2026-10-30). Je recommande la **même règle narrative** : le cours des ordres de **mars 2020 = point de séance du 18/03 (3 755)**, documenté comme tel dans le fichier. Alternative honnête mais moins instructive : fin de mars réelle 4 396 (la baisse de mars serait alors seulement −17 % depuis février). Avec 3 755, le rebond d'avril (4 572, **+22 %**) est spectaculaire et fidèle à l'esprit de l'événement.

| Séance | Jour | Clôture CAC 40 | Variation | Cert. | Commentaire (au présent, sans divulgâcheur) |
|---|---|---|---|---|---|
| Plus haut | mer. 19/02 | 6 111 | | A | « La Bourse touche des sommets. » |
| Fin de mois | ven. 28/02 | 5 310 | −13 % depuis le 19/02 | A | Début de la peur (première semaine de panique : −11 % du 24 au 28/02, B) |
| Veille | ven. 06/03 | ≈ 5 139 | | B (déduit de −8,39 %) | |
| 1 | lun. 09/03 | 4 708 | −8,39 % | A (variation) / B (niveau) | Pétrole en chute après la rupture Russie/Arabie saoudite ; pire séance depuis 2008 |
| 2 | mar. 10/03 | ≈ 4 770 | ≈ +1,3 % | C | Rebond sur espoirs d'aides |
| 3 | mer. 11/03 | ≈ 4 610 | ≈ −3,4 % | B (déduit du 12/03) | L'OMS parle de pandémie |
| 4 | **jeu. 12/03** | **4 044** | **−12,28 %** | **A** | **Pire séance de l'histoire du CAC.** Aucune valeur vedette ne monte ; Renault −22 %. Wall Street : Dow −10 %. La BCE déçoit. |
| 5 | ven. 13/03 | ≈ 4 100 | ≈ +1 % | C | Fermeture des écoles annoncée |
| 6 | lun. 16/03 | ≈ 3 880 | ≈ −5 % | C | Le confinement est annoncé le soir du 16/03 pour le lendemain midi (A) |
| 7 | mar. 17/03 | ≈ 3 900 | ≈ 0 % | C | |
| 8 | **mer. 18/03** | **3 755** | ≈ −4 % | **A/B** (plus bas de l'année ; clôture ou plus bas de séance, à trancher) | **Cours retenu pour les ordres de mars 2020.** |
| Fin de mois | mar. 31/03 | 4 396 | | A | Après un rebond de +17 % en 8 séances (nombre à recalculer) |

- Fenêtre de la vitrine : 9 -> 18/03 = **8 séances** (le plan disait ≈ 7) ; si l'UX veut 7, supprimer le 10/03.
- **Valeurs fiables à afficher** : 4 708 (9/03), 4 044 (12/03), 3 755 (18/03), 4 396 (fin mars). Les points C (10, 13, 16, 17/03) peuvent apparaître arrondis à la centaine ; à défaut de source, ne pas citer leur variation à la décimale.
- **Carte « un an après » (03/2021)** : CAC 40 fin mars 2021 ≈ 6 067 (B) : **+62 %** par rapport à 3 755, **+14 %** par rapport à fin février 2020 (5 310), et **au-dessus du niveau de fin 2019 (5 978)** : le niveau d'avant la crise est retrouvé, la leçon « un an après » est **vraie**. (Le plus haut de séance du 19/02/2020, 6 111, n'est dépassé qu'en avril 2021 : 6 270 fin avril ; ne pas dire « retrouvé le sommet » en 03/2021.) Délai de retour au niveau de fin 2019 : ≈ 12 mois ; au sommet du 19/02 : ≈ 14 mois (B).
- Pour la même leçon, un joueur qui a vendu à 3 755 et n'est pas revenu a perdu ≈ 38 % ; pas besoin de l'écrire : le bilan le calcule.

### B3.4 Événements de marché du chapitre (textes au présent, sans issue)

Format : mois, manchette, impact sur l'indice (calculé sur les fins de mois ci-dessus), délai de retour au niveau d'avant, leçon (pour le rappel à 12 mois uniquement).

| Mois | Manchette (A8 : sans divulgâcheur) | Impact | Retour au niveau d'avant | Leçon | Cert. |
|---|---|---|---|---|---|
| 2019-05 | Guerre commerciale : les droits de douane s'invitent dans les cours | mois −6,8 % (5 586 -> 5 208) | 1 mois (06/2019 : 5 539) | Une correction n'est pas un krach | B |
| **2020-03** | **Coronavirus : l'Europe se confine, la Bourse chute à une vitesse jamais vue** (vitrine) | −38,6 % du 19/02 au 18/03 ; −17 % en fin de mois | ≈ 12 mois (03/2021), sommet 14 mois | Le plus rapide des krachs, l'un des plus rapides rebonds | A (mois) / B (délais) |
| 2020-11 | Un vaccin est annoncé, les marchés s'envolent | mois +20,1 % (4 595 -> 5 519) ; +7 % le 09/11 (B) | — | Les meilleurs mois suivent les pires : ne pas attendre « d'y voir clair » | A (mois) |
| 2022-02 | Guerre en Ukraine : l'énergie s'emballe | mois −4,4 % (6 965 -> 6 659) ; ≈ −4 % le 24/02 (B) | ≈ 13 mois (6 965 de fin janvier 2022 n'est retrouvé qu'en 03/2023 : 7 322) ; le niveau de fin février (6 659) l'est dès 03/2022 | Les chocs géopolitiques font des séances brutales, pas toujours durables | B |
| 2022-06 | L'inflation dépasse 5 %, la BCE relève ses taux | mois −8,4 % (6 469 -> 5 923) ; creux de fin septembre | 5 mois (11/2022 : 6 738 > 6 469) | Hausse des taux = baisse des actions et des obligations ; le Livret A passe à 2 % en 08/2022 | A |
| 2023-03 | Des banques américaines tombent, une banque suisse est rachetée en urgence | mois **+0,7 %** (7 268 -> 7 322) mais banques françaises ≈ −10 à −15 % en quelques séances (BNP ≈ 62 -> 55) ; CAC ≈ −6 % entre le 08 et le 15/03 (C) | quelques semaines | Ce qui se passe **dans** un mois n'apparaît pas dans sa clôture ; les banques sont plus fragiles que l'indice | B/C |

- **Point d'attention** : 2023-03 est difficile à mettre en scène avec des ancrages de fin de mois (l'indice ne baisse pas). Soit le traiter comme événement **sectoriel** (BNP seule), soit le supprimer, soit un point de séance (indice ≈ 6 900 le 15/03, C). Recommandation : **événement sectoriel BNP** (impact 2023-03 : −11 %), au présent, sans issue.
- Contextes (sans pause) : loi PACTE (05/2019, A), Livret A 0,5 % (02/2020), 1 % (02/2022), 2 % (08/2022), 3 % (02/2023) (A, déjà dans `series.json`), flat tax en vigueur depuis 01/2018 (A), GameStop (01/2021, A : contexte pour le rival), inflation française 2022 : 5,2 % en moyenne (A).
- Rappels à 12 mois : tous les événements ci-dessus ont leur mois + 12 dans la partie (dernier : 2023-03 -> 2024-03, **hors de la fenêtre 12/2023** : remplacer par une ligne au bilan ou raccourcir, point de docs/boursier §3 ; 2022-06 -> 2023-06 OK).

### B3.5 Média en 2019

En 2019, un particulier s'informe par : la **chaîne d'information en continu** (bandeau avec le CAC 40 en direct ; BFM Business pour l'économie), la presse économique (Les Echos), des sites de courtiers en ligne et des **alertes sur smartphone** (notification de cours, application bancaire), les réseaux sociaux pour les « petits » investisseurs (A/B).
Recommandation pour le bâtiment « média » : **chaîne d'info en continu avec bandeau défilant** (parabole sur le toit, écran de façade) **+ notification push sur le téléphone du personnage** pour l'animation de chaque news. Je suggère un **nom fictif** (ex. « Éco 24 » ou « Le Fil Éco ») pour éviter marques déposées et dates, avec la mention dans les textes « les chaînes d'info en continu ». Si le client préfère le réel : « BFM Business » est le plus exact (certitude A que c'est la chaîne éco de référence).

### B3.6 Fin de partie du chapitre 2019-2023

12/2023 : CAC 7 543 (+60 % en 5 ans, +16,5 % en 2023), mais **inflation cumulée 2019-2023 ≈ +14 %** et Livret A à 3 % (au-dessus de l'inflation 2023 pour la première fois depuis 2021). La fin laisse une **leçon juste** : rendement réel, taux, diversification. Pas de fin au fond d'un krach.

---

## B2. Fenêtres de chapitres (une par décennie)

Calculs d'après les clôtures annuelles de docs/02 §4.2 (A pour 1988+, B 1969-1987, C avant) et l'inflation de docs/01 §4.4 (fait foi). « Retour » = délai pour retrouver le niveau d'avant l'événement.

| Décennie | Fenêtre | Marché | Indice début -> fin (×) | Inflation cumulée | Vitrine (mois, ampleur) | Retour / « un an après » vrai ? | Fin de partie | Cert. |
|---|---|---|---|---|---|---|---|---|
| 1950 | **1954-1958** (ancien franc) | P00 (1950-1962) | 89 -> 206 (**×2,3**) | ≈ +22 % (1958 : 15 %) | **Suez, 11/1956** (milieu de partie, mois 35). Ampleur : 1956 est une année quasi plate (−2 %), baisse du mois non documentée (≈ −5 à −8 %, C) | « Un an après » (11/1957) : indice plus haut (1957 +32 %) : **vrai**, mais le krach est faible : **cette décennie n'a pas de krach cinématique**. Alternative de vitrine : dévaluation / plan Rueff 12/1958 (mois 59, trop tard) | Fin en 1958 dans une hausse ; inflation de 15 % en 1958 : leçon « actions contre inflation ». Juste. | C |
| 1960 | **1965-1969** (nouveau franc, pas d'ancien franc) | P0 (1963-1977) | 262 -> 334 (**×1,27**) | ≈ +20 % | **Mai 68, 05/1968** (mois 41). Ampleur : 1968 finit à +22 % (C) ; baisse de mai-juin à documenter (Larousse, Journal de l'année 1968) | « Un an après » (05/1969) nettement plus haut (1969 +30 %) : **vrai**, retour en quelques mois (C) | Fin en 1969 au sommet de la décennie (334) ; 1970 −7 %. Juste, avec un bilan qui peut dire « 1970-1971 : −15 % ». | C |
| 1970 | **1973-1977** | P0 | 335 -> 229 (**×0,68**) | ≈ +64 % | **1er choc pétrolier, 10/1973 -> 09/1974** (mois 10 à 21). Pic 385 (05/1973), creux ≈ 215 (09/1974) = **−45 %** (A/B). Année 1974 : −30,8 % (A) | « Un an après » (10/1974) : creux à ≈ 215-225, **rebond +35 % en 4 mois début 1975** (A). **Retour au niveau d'avant (326-385) : pas avant 1978** (335 fin 1978). La leçon « un an après » doit être « le rebond est violent mais le niveau d'avant n'est pas retrouvé » | **Fin au fond** : 229, −32 % nominal, ≈ −58 % réel, après 5 ans de stagflation. Pas de rebond dans la fenêtre : **le bilan doit expliquer** (« en 1978 : +46,5 % ») et montrer l'obligation (taux 10-11 %) et le Livret A (6,5 %) | B (A 1974-1975) |
| 1980 | **1984-1988** (existant) ou **1978-1983** | P1 | 553 -> 1 574 (×2,8) / 229 -> 553 (×2,4) | 1984-88 : ≈ +30 % | Lundi noir 10/1987 (existant) ; 1978-83 : élection 05/1981 (indice −30 % mai-juin, C) | 1987 : voir docs/18-19 | existant | A/B/C |
| 1990 | **1997-2001** (recommandée) ; 1996-2000 possible | P2 | 2 316 -> 4 625 (**×2,0**) | ≈ +6 % | **France Télécom IPO 10/1997** (mois 10) puis **crise russe 08-09/1998** : indice 4 400 -> 3 200 (**−27 %**, mois 20-21). Bulle 03/2000 (FT 219 €) | 08/1998 -> retour à ≈ 4 400 vers 04/1999 (≈ 8 mois après le creux, B/C) ; fin 1998 : 3 943 ; 10/1999 ≈ **+40 %** vs 10/1998 : **vrai** | Fin 12/2001 : 4 625, −22 % sur 2001, −33 % du pic (6 922 en 09/2000) : leçon **bulle** juste, **mais** la baisse continue jusqu'en 03/2003 : le bilan peut le dire (hors jeu). 1996-2000 finirait à −14 % du pic, avec FT à ≈ 95 € après 219 € : correct aussi, plus gai. Euro 01/1999 dans la fenêtre : double affichage F/€ requis | B |
| 2000 | **2006-2010** | P2 | 4 715 -> 3 805 (**×0,81**) | ≈ +8 % | **Lehman, 09-10/2008** (mois 33-34) ; indice 4 483 (08/2008) -> 3 488 (10/2008) ; creux 2 519 (09/03/2009, séance), 2 804 fin 03/2009 | Un an après (10/2009 ≈ 3 800 B) : +9 % vs 10/2008 mais **−15 % vs avant Lehman**. Retour à 4 483 : 2013-14 (≈ 5 ans). Leçon vraie si formulée : « le creux est venu 5 mois après » | Fin 12/2010 : 3 805, soit −19 % en prix mais ≈ **0 % dividendes réinvestis** (rdt ≈ 3,5-4 %/an : ≈ +20 %) : leçon dividendes juste | A/B |
| 2010 | **2011-2015** (recommandée) ; 2014-2018 (Brexit) | P3 | 3 805 -> 4 637 (**×1,22**) | ≈ +6 % | **Crise des dettes, 08/2011** (mois 8) : 4 107 (04/2011) -> 2 982 (09/2011) = **−27 %**, banques −45 % | Un an après (08/2012) ≈ 3 400 (C) : +4 % seulement ; retour à ≈ 4 100 en 2013 (≈ 2 ans). La leçon doit dire « 2 ans » | Fin 12/2015 : 4 637, après le krach chinois d'août 2015 : fin sur un marché de +22 % en 5 ans : juste | A/B |
| 2020 | **2019-2023** | P3 | 4 731 -> 7 543 (**×1,6**) | ≈ +14 % | **Covid 03/2020** (mois 15) : −38,6 % en 4 semaines | ≈ 12 mois (03/2021) : **vrai** | Voir B3.6 : juste | A |

Fenêtres de repli : 2014-2018 (Brexit 06/2016 : 4 506 -> 4 237, séance −8,04 % le 24/06 ; retour 11/2016 ≈ 5 mois ; fin 2018 en correction −11 %, rebond 2019 +26 % : fin « au creux » mais le bilan peut le dire) ; 1958-1962 (dévaluation 12/1958 + nouveau franc 01/1960 ; fin 1962 à 343 après −10 % en 1962).

Besoins moteur : 1950 sans fonds (SICAV : 1964) ; 1950-1959 en **ancien franc** ; 1960 en nouveau franc ; 1999-2001 double affichage.

### Actions et fonds par fenêtre (4 au plus + 1 fonds)

Niveaux d'actions avant 1990 : **je n'ai pas de séries fiables** (C) ; je propose des profils (bêta) et des titres, les niveaux étant à fixer par le développeur selon docs/boursier §3 (règle d'ancrage : prix ajustés, profil seulement).

| Fenêtre | Actions (A14) | Fonds | Ancrages disponibles |
|---|---|---|---|
| 1954-1958 | CFP (Total), Saint-Gobain, Peugeot, Air Liquide ; alternative : Michelin | Aucun (SICAV en 1964) ; Cousin Indice sans fonds | Profil seulement (C) |
| 1965-1969 | Peugeot, Saint-Gobain, L'Oréal (cotée dès 1963), CFP | SICAV actions françaises (dès 1964) | Profil seulement (C) |
| 1973-1977 | CFP (Total), Peugeot (rachat de Citroën 1974-76), Saint-Gobain, L'Oréal ; Elf (créée 1976) trop tard | SICAV | Profil seulement (C) |
| 1984-1988 | existant (P1) | SICAV | docs/18-20 |
| 1997-2001 | France Télécom (27,75 € à 10/1997, 31 € 12/1997, 61 € 07/1998, 55 € 12/1998, 120 € 12/1999, 219 € 03/2000, 95 € 12/2000, 43 € 12/2001), Alcatel (24, 25, 45, 85, 62, 19 €), L'Oréal (37, 60, 88, 90, 80 €), Total (25, 26, 33, 40, 38 €) : valeurs de `periode_p2.js` (B/C), à garder | SICAV (jusqu'en 2000), ETF CAC 40 (dès 01/2001) | `periode_p2.js` |
| 2006-2010 | L'Oréal (62 € 12/2005, 76, 98, 61, 78, 83), Total (53, 55, 57, 39, 45, 40), Alcatel-Lucent (11, 11, 5, 2, 2,4, 2,2), France Télécom (21, 21, 24, 20, 17,5, 15,6) : `periode_p2.js` | ETF CAC 40 | `periode_p2.js` |
| 2011-2015 | LVMH (110, 138, 133, 132, 150 € en fin d'année), TotalEnergies (39,5, 39, 44,5, 42,5, 41,2), BNP Paribas (30,3, 42,6, 56,7, 49,3, 52,2 ; 22 en 09/2011), Orange (12,1, 9,2, 9,6, 14,1, 15,5) : `periode_p3.js` | ETF CAC 40 | `periode_p3.js` |
| 2019-2023 | LVMH, TotalEnergies, BNP Paribas, Orange | ETF CAC 40 | B3.2 |

---

## B1. Données de marché disponibles par décennie

| Décennie | Dans `godot/data` | Dans docs / V1 | Certitude | Manque |
|---|---|---|---|---|
| 1949-1959 | rien | docs/02 §4.2 : indice, dividende, taux long (1949-59), inflation ; docs/01 §4.4 inflation 1950-59, Livret A ≈ 2,5 % non sourcé | C (indice, taux long avant 1960, dividende), B/C (inflation) | Mensuel ; niveaux d'actions ; Livret A daté |
| 1960-1969 | rien | idem ; inflation A | C (indice), A (inflation, taux long) | Mensuel ; SICAV 1964 ; Livret A (K1 banquier) |
| 1970-1976 | `inflation` 1976 seulement | docs/02 §4.2 + §4.4 (**mensuel 1973-75, C**) ; E12-E16 | B (A pour 1974-75) | Mensuel 1965-72 et 1976 ; actions |
| 1977-1992 | **complet** | docs/18 à 29 | A/B/C | — |
| 1993-2000 | `annuel` + inflation | docs/02 §4.4 (1998 mensuel B/C) ; `periode_p2.js` | B | Mensuel 1996-2000 hors 1998 ; double affichage F/€ |
| 2001-2010 | `annuel` + inflation | `periode_p2.js` (ancrages 2007-2010 en partie) | A/B | Mensuel 2004-2007, 2010 ; 2006-2007 à compléter |
| 2011-2018 | `annuel` + inflation | `periode_p3.js` (ancrages éparses : 2011, 2012-07, 2016) | A/B | Mensuel 2013-2015, 2017-2018 (à produire comme B3.1) |
| 2019-2025 | `annuel` + inflation | B3.1 de ce document | A (fin d'année), B (mensuel) | Voir B3.1 |

### B1.1 Valeurs 1949-1976 prêtes à recopier dans `godot/data/series.json`

Format de `annuel` : `"année": [clôture 31/12 (échelle CAC 40), rendement dividende %, taux long %]`, source docs/02 §4.2 (colonnes indice, rdt_div, taux_long). Certitude : indice **C** (1949-1968), **B** (1969-1976) ; dividende **C** avant 1990 ; taux long **C** avant 1960, **A** de 1960 à 1976.
Ces valeurs sont des **points d'ancrage** : le moteur génère l'intra-annuel (docs/02 §6). **Piège** : 1976 doit être reprise telle quelle (244,5) ; le premier millésime actuel de `series.json` est 1977.

```json
"1949": [65.5, 6.0, 6.5],
"1950": [70.8, 5.5, 6.5],
"1951": [88.5, 5.5, 7.0],
"1952": [84.9, 5.8, 7.0],
"1953": [89.2, 5.5, 6.8],
"1954": [142.7, 4.5, 6.0],
"1955": [151.3, 4.2, 5.6],
"1956": [148.2, 4.3, 5.7],
"1957": [195.7, 3.6, 6.5],
"1958": [205.5, 3.8, 6.8],
"1959": [300.0, 2.8, 6.0],
"1960": [312.0, 2.7, 5.7],
"1961": [380.6, 2.5, 5.5],
"1962": [342.6, 2.8, 5.4],
"1963": [294.6, 3.2, 5.3],
"1964": [262.2, 3.5, 5.4],
"1965": [243.8, 3.7, 6.2],
"1966": [219.5, 4.0, 6.6],
"1967": [210.7, 4.2, 6.7],
"1968": [257.0, 3.7, 7.0],
"1969": [334.1, 3.2, 8.2],
"1970": [310.5, 3.6, 8.6],
"1971": [286.1, 4.0, 8.4],
"1972": [335.2, 3.6, 8.0],
"1973": [325.7, 3.9, 9.0],
"1974": [225.5, 6.0, 11.0],
"1975": [294.6, 4.8, 10.3],
"1976": [244.5, 5.8, 10.5]
```

Inflation (clef `inflation`, **01 §4.4 du banquier**, qui fait foi ; différences avec ma colonne de docs/02 notées) :

```json
"1949": 13.0, "1950": 10.0, "1951": 16.0, "1952": 12.0, "1953": -1.5, "1954": 0.4,
"1955": 1.0, "1956": 2.0, "1957": 3.0, "1958": 15.0, "1959": 6.0, "1960": 3.6,
"1961": 3.3, "1962": 4.8, "1963": 4.8, "1964": 3.4, "1965": 2.5, "1966": 2.7,
"1967": 2.7, "1968": 4.5, "1969": 6.4, "1970": 5.2, "1971": 5.5, "1972": 6.2,
"1973": 7.3, "1974": 13.7, "1975": 11.8
```

| Année | 02 | 01 (retenu) | Cert. |
|---|---|---|---|
| 1949 | 13,0 | 13,0 (non couverte par 01 ; **ma valeur**) | C |
| 1951 | 16,2 | 16,0 | B/C |
| 1969 | 6,0 | 6,4 | B |
| 1972 | 6,1 | 6,2 | B |
| 1973 | 7,4 | 7,3 | A |
| 1974 | 13,6 | 13,7 | A |
| 1975 | 11,7 | 11,8 | A |

À savoir :
- Avant 1960, tout est en **anciens francs** (AF) : l'indice est une échelle sans unité (pas de conversion à faire), mais montants (salaires, prix) oui : H13 du plan.
- Le rendement du dividende avant 1990 (C) et le taux long avant 1960 (C) pèsent sur SICAV et Cousin Indice : à signaler « reconstitué » au joueur (docs/02 §5).
- Pas de niveau d'action avant 1990 : voir B2.
- Mensuel 1973-1975 : docs/02 §4.4 (C, sauf 1975-04 ★). Autres périodes : pont brownien annuel -> mensuel (docs/03 §7.1).

---

## Sources

- [BFM Bourse / Tradingsat, clôture du 12/03/2020 (4 044, −12,28 %)](https://www.tradingsat.com/cac-40-FR0003500008/conseils/cac-40-le-cac-panse-ses-plaies-apres-un-lundi-et-un-jeudi-noirs-904313.html)
- [Convextrade, historique CAC 40 2020 (6 111,24 ; 5 309,9 ; 4 396,12 ; 3 754,84)](https://convextrade.com/metrics/cac40/history/2020)
- docs/02 §4.2, §4.4 ; docs/01 §4.4 ; `jeu/data/periode_p2.js`, `periode_p3.js` ; Larousse, Journal de l'année (indice des agents de change 1961-1975, déjà cités dans docs/02).
- Euronext (historique du CAC 40, FR0003500008) : source recommandée pour recouper B3.1 ; non accessible en lecture dans cette mission.

## Points à trancher par le client ou le chef de projet

1. Convention du cours de vitrine du Covid : **3 755 (point de séance du 18/03)** recommandé, ou 4 396 (fin de mois). Même arbitrage que Lundi noir.
2. 2023-03 (banques) : événement sectoriel (BNP) ou suppression ; rappel à 12 mois à 03/2024 hors fenêtre.
3. Décennie 1950 : fenêtre sans vrai krach (vitrine Suez faible, C) ; à valider par le game designer avant de l'ouvrir. 1973-1977 finit au fond d'un marché baissier : choix assumé, avec bilan explicatif.
4. 1997-2001 plutôt que 1996-2000 pour la décennie 1990.
5. Nom du média 2019 : fictif (« Éco 24 ») ou réel (« BFM Business »).
