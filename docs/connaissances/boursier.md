# Base de connaissances du boursier

> À lire au début de chaque mission, à mettre à jour à la fin. Synthèse opérationnelle : le détail est dans `docs/02_rouages_bourse.md` (« 02 §x »). En cas de contradiction, `03_cahier_des_charges.md` (« 03 §x ») l'emporte sur 02.
> Certitude : **A** vérifié (source publique), **B** probable (erreur < 5-10 %), **C** reconstitué (erreur 10-25 %).

---

## 1. Décisions du client qui s'imposent à moi

| Réf. 03 | Décision | Conséquence pour mes livrables |
|---|---|---|
| A7 | **P1 « Les années fric » 01/1978 → 12/1992 ; P2 « De l'euphorie à la crise » 01/1996 → 12/2010 ; P3 « L'ère des ETF » 01/2011 → 12/2025**, 180 mois chacune, sans chevauchement | Toute donnée doit couvrir ces 3 fenêtres (+ décembre de l'année précédente pour les ancrages de départ). |
| A8, A5 | Accroches sans divulgâcheur (02 §7 Q1) ; la frise n'annonce jamais un krach | Manchettes et textes « au présent », sans l'issue ; la leçon ne sort qu'au rappel à 12 mois et au bilan. |
| A9 | Trente Glorieuses (1950-1977) **hors V1** | Fiabiliser 1950-1968 n'est pas prioritaire (V2, année libre). |
| A10, A12 | Durée fixe 15 ans ; cours **déterministes** (graine fixe par période) | Mes ancrages doivent être des valeurs uniques, pas des fourchettes. |
| A11 | Un seul ordre « au cours du mois » ; pendant une modale, cours = celui du mois | Pas de `cours_evenement` séparé en V1 : un point de séance n'existe que s'il est l'ancrage du mois. |
| A13 | Emprunt d'État = taux fixe garanti, **sans cours**, au taux long de l'année d'achat (plancher 0 %) | Ma colonne `taux_long_%` (02 §4.2) est utilisée telle quelle. |
| A14 | **4 actions par période** : P1 Elf, L'Oréal, Peugeot, Saint-Gobain (12/1986 à 310 F) ; P2 L'Oréal, Total, Alcatel, France Télécom (10/1997 à 27,75 €) ; P3 LVMH, TotalEnergies, BNP Paribas, Orange | Vivendi et Stellantis sont sortis de la V1. Pas de nationalisation, pas de division de nominal (prix ajustés). |
| §6.1 | **8 événements en P1, 8 en P2, 7 en P3**, exactement ceux de 02 §7 Q2 (mois, manchette, impact, leçon) | Toute modification de 02 §7 Q2 change le jeu : passer par le client. |
| §7.1 | Clôtures annuelles de 02 §4.2 et points mensuels de crise de 02 §4.4 = **ancrages durs** ; pont brownien en log, Student ν = 4, vol. mensuelle 4-5 % (normal) et 8-12 % (crise) | CA-10 : tolérance 0,1 % sur les clôtures annuelles. |
| §7.1 | Inflation : **01 §4.4 (banquier)**, pas ma colonne de 02 §4.2 | Écarts de ±0,2 pt entre les deux (1977, 1978, 1986, 1994, 2005, 2006) : 01 fait foi. |
| §7.2 | Action : `log-prix = beta × log(indice) + résidu`, résidu en pont brownien passant par les ancrages de 02 §4.5 (beta, vol_spe) ; en P1 (profil seulement), **le développeur fixe les ancrages** | CA-21 (profils) et CA-22 (ancrages à ±10 %). |
| §7.3 | SICAV : `VL(m) = VL(m−1) × I(m)/I(m−1) × (1 + d/12) × (1 − 1,5 %/12)`, frais d'entrée 2 % ; ETF (dès 01/2001) : 0,25 %/an, courtage action, sans TTF | `d` = ma colonne `rdt_div_%` (02 §4.2). |
| §7.4 | Dividendes en mai = rendement de marché + écart par titre (Elf/Total +1,5 ; Orange/FT +2 ; BNP +1, 0 en 2009 et 2020 ; L'Oréal −1,5 ; LVMH −1 ; Alcatel −1,5 ; Peugeot, Saint-Gobain 0) | Indice de **prix** : pas d'ajustement du cours au détachement. |
| §7.5 | Frais `max(min, taux × montant)` : 1978-1999 1,3 % (min 50 F) ; 2000-2007 0,8 % (10 €) ; 2008-2018 0,5 % (5 €) ; 2019-2025 0,1 % (1 €) ; TTF 0,2 % (08/2012), 0,3 % (2017), 0,4 % (04/2025) | Remplace mes paramètres de 02 §2.2 et §7 Q5. |
| §7.8 | **Cousin Indice** = règles 1-6 de 02 §7 Q6 : coussin de 3 mois de dépenses sur Livret A, puis tout l'excédent dans le fonds (SICAV jusqu'en 2000, ETF pour les nouveaux versements dès 01/2001), PEA dès qu'il existe, dividendes réinvestis, frais appliqués, ne vend que coussin vide | CA-20 : en P1 sans événements de vie, Cousin > Tata Livret > Tonton Matelas. |
| A17 | Valorisation **brute** au bilan pour tous | Pas d'impôt latent à calculer. |
| A18, CA-27 | Rappel à 12 mois après chaque choix de marché, avec la variation réelle de l'indice | Voir le point d'attention du §3 (événements de fin de période). |

---

## 2. Faits et séries clés vérifiés (A/B)

### 2.1 Indice (échelle CAC 40, base 1000 au 31/12/1987 ; détail 02 §4.2 et §4.4)

| Repère | Valeur | Cert. |
|---|---|---|
| Fin 1977 / fin 1992 (P1) | 229,0 → 1 857,8 (×8,1 en prix) | B (rétropolé CAC Général × 3,52) / A |
| Fin 1995 / fin 2010 (P2) | 1 872,0 → 3 804,8 (×2,0) | A |
| Fin 2010 / fin 2025 (P3) | 3 804,8 → 8 149,5 (×2,1) | A |
| Pièges de saisie | fin 1999 = **5 958,32** (pas 5 858) ; 2020 = **−7,14 %** (pas −7,68 %) | A |
| Krach 1987 | 16/10 : 1 240 ; 19/10 : −9,7 % ; 29/10 : 1 033 ; 10/11 : 963 (CAC Général × 3,52) | A |
| 1990 | creux fin sept. 1 472 ; année −24,1 % | A |
| 1992 | plus haut 2 077,5, plus bas 1 611 (mois non vérifiés) | B |
| Bulle | pic 6 922 (04/09/2000) ; creux 2 403 (12/03/2003) = −65 % | A |
| Subprimes | pic 6 168 (01/06/2007) ; creux 2 519 (09/03/2009) = −59 % | A |
| Covid | 6 111 (19/02/2020) → 3 755 (18/03/2020) = −38,6 % | A |
| 2022 | 7 376 (05/01) → 5 677 (29/09) = −23 % | A |
| 2025 | record de clôture 8 206,56 (03/03) puis plus bas 6 863,02 (09/04) ; fin avril 7 593,87 ; record 8 258,96 (21/10) ; fin d'année 8 149,50 (+10,4 % ; GR +14,3 %) | A |
| Fins de mois vérifiées (dev) | 04-06/2010 : ≈ 3 817 / 3 508 / 3 443 ; 06-07/2012 : 3 197 / 3 292 ; 05-06/2016 : 4 506 / 4 237 ; 05-06/2024 : 7 993 / 7 479 ; 02-03-05/2025 : 8 112 / 7 791 / 7 752 | A/B |

### 2.2 Séances record (02 §3.1)

−12,28 % (12/03/2020) ; −9,04 % (06/10/2008) ; −8,39 % (09/03/2020) ; −8,04 % (24/06/2016) ; ≈ −9,7 % (19/10/1987, CAC Général) ; +11,18 % (13/10/2008) ; ≈ +9,7 % (10/05/2010). Certitude A (B pour 2001 et 2008-01).

### 2.3 Taux, inflation, Livret A (repères ; séries complètes : 02 §4.2, 01 §4.1 et §4.4)

| Repère | Valeur | Cert. |
|---|---|---|
| Taux long 10 ans | 16,3 % (1981, record) ; 9,1 % (1986) ; 4,6 % (1998) ; −0,1 % (2020) ; 3,4 % (2025) | A |
| Inflation | 13,6 % (1980) ; 13,4 % (1981) ; 2,6-2,7 % (1986) ; 0,1 % (2009) ; 5,2 % (2022) ; 0,9 % (2025) | A |
| Livret A | 8,5 % (16/10/1981 → 08/1983, record) ; 4,5 % (06/1986 → 03/1996) ; 0,75 % (08/2015) ; 0,5 % (02/2020) ; 3 % (02/2023) ; 2,4 % (02/2025) puis 1,7 % (08/2025) | A (la série datée du banquier, 01 §4.1, fait foi) |

### 2.4 Institutions et produits (02 §2.1)

| Date | Fait | Cert. |
|---|---|---|
| 13/07/1978 | Loi Monory (en V1 : simple « Le saviez-vous ? ») | A |
| 06/1986 | Cotation Assistée en Continu (CAC) | A |
| 14/07/1987 | Fin de la criée (démontage de la corbeille) | A |
| 31/12/1987 | CAC 40 base 1000 ; publié en temps réel à partir du 15/06/1988 (bandeau du jeu : « CAC 40 » dès 06/1988) | A |
| 22/01/1988 | Fin des agents de change, sociétés de bourse | A |
| 16/07/1992 | PEA (plafond 600 000 F) | A |
| 01/01/1999 | Euro (1 € = 6,55957 F) ; pièces le 01/01/2002 | A |
| 25/09/2000 | SRD remplace le Règlement Mensuel (hors V1) | A |
| 01/2001 | Premiers ETF CAC 40 | A |
| 01/08/2012 | TTF 0,2 % ; 0,3 % en 2017 ; 0,4 % au 01/04/2025 | A |
| 01/01/2018 | PFU 30 % | A |

### 2.5 Actions : points sûrs (02 §4.5)

| Titre | Fait | Cert. |
|---|---|---|
| Saint-Gobain | OPV 310 F (mise en vente 24/11/1986, privatisation 22/12/1986) ; = 11,81 € après division par 4 (27/06/2002) ; rendement global 11,8 %/an de 1986 à 2004 (doc. de référence) | A |
| France Télécom | IPO 27,75 € (182 F) le 20/10/1997 ; 219 € le 02/03/2000 ; ≈ 7 € en sept.-oct. 2002 | A / B (creux) |
| Elf Aquitaine | 416-420 F en janv. 1994, au lancement de la privatisation (UPI) | A |
| Alcatel | −38 % en une séance (sept. 1998) ; ≈ 100 € (automne 2000) ; ≈ 3 € (fin 2002) | B |
| L'Oréal | division du nominal par 10 en 2000 ; ≈ 88-90 € (fin 1999 - début 2000, après division) | B |

### 2.6 Privatisations grand public 1986-1987 (vérifié le 2026-10-27, pour la démo 01/1984 → 12/1988)

| Société | Mise en vente (IGPDE) | Prix de l'offre | Souscripteurs | Cert. |
|---|---|---|---|---|
| Saint-Gobain | 24/11/1986 (privatisation effective 22/12/1986) | 310 F | ≈ 1,5 M | A (date, prix) / B |
| Paribas | 19/01/1987 | 405 F (480 F le 11/06/1987) | ≈ 3,8 M | A (prix) / B |
| CCF | 27/04/1987 | ≈ 107 F | — | A (date) / B (prix) |
| CGE (future Alcatel) | 11/05/1987 | 290 F (326 F le 11/06/1987) | — | A |
| Havas | 25/05/1987 | ≈ 500 F | — | A (date) / B (prix) |
| Société Générale | OPV du 15 au 27/06/1987 | 407 F | ≈ 2,3 M (20,9 M d'actions) | A |
| TF1 | 29/06/1987 (loi du 30/09/1986 sur la communication ; 50 % au groupe Bouygues, 40 % au public) | ≈ 165 F | — | A (date) / B (prix) |
| **Suez** | **octobre 1987** (offre ouverte vers le 05/10, close juste avant le krach du 19/10 ; la moitié du paiement a été reportée à 1988) | ≈ 317 F | ≈ 1,6 M (C) | A (mois) / B (prix, jour) |
| Matra | 20/01/1988 | — | — | A (date) |

- **Suez, le 10/05/1987 de l'IGPDE est très probablement une inversion jour/mois de 05/10/1987.** Preuves : Larousse (Journal de l'année 1988) liste les **dix opérations achevées au 31/07/1987** (Saint-Gobain, Paribas, Sogénal, BTP, BIMP, CCF, CGE, Havas, Société Générale, TF1), sans Suez, qui figure parmi les cessions « ultérieures » avec la CGCT et l'IDI. De plus, la question écrite AN n° 3362 (1988) évoque des souscripteurs de Suez dont le paiement de la moitié des actions a été reporté à 1988 « à la suite des difficultés boursières de l'automne ». **On garde 10/1987.**
- Premières cotations : environ 3 à 5 semaines après l'ouverture de l'offre (C, non vérifié titre par titre). Avant le krach, les cours se tenaient « légèrement au-dessus du prix de l'offre » (Larousse). Pour le jeu, la valeur à retenir est le prix fixe de l'offre ; la première cotation n'est pas nécessaire en V1.
- Règles communes (lois de 1986) : priorité aux particuliers, **1 action gratuite pour 10 conservées 18 mois**, paiement fractionné possible. Le taux de service (réduction des ordres) est hors V1.

### 2.7 Taux du marché monétaire 1982-1992 (OCDE via FRED, moyennes annuelles, certitude A)

| Année | 1982 | 1983 | 1984 | 1985 | 1986 | 1987 | 1988 | 1989 | 1990 | 1991 | 1992 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Taux à 3 mois (%) | 14,6 | 12,5 | 11,7 | 9,9 | 7,7 | 8,3 | 7,9 | 9,4 | 10,3 | 9,6 | 10,3 |
| Taux au jour le jour (%) | 12,9 | 12,3 | 11,0 | 9,0 | 7,8 | 8,0 | 8,2 | 10,5 | 9,7 | 10,1 | 10,0 |

- SICAV monétaire nette ≈ taux à 3 mois − 0,5 à 1 point de frais (B).
- **Comparaison avec le tableau du banquier (11 §1.3.2)** : bon de 1982 à 1987. **1988 : 7,5 → 8,0** (SICAV nette 7,0 → 7,5) ; **1989 : 9 → 9,5** (SICAV nette 8,5 → 9,0). Pour la démo, cela donne une SICAV monétaire nette à ≈ 11 % en 1984, 9,5 % en 1985, 7 % en 1986-1987 et 7,5 % en 1988.

---

## 3. Points incertains (C) à fiabiliser

| Sujet | État | Pistes de sources |
|---|---|---|
| **Niveaux absolus des actions P1** (Elf, L'Oréal, Peugeot, Saint-Gobain 1977-1992) | Profils fiables (B), niveaux C ; Elf et L'Oréal étaient surévalués par le dev (§4) | Annuaire Desfossés, cote officielle (archives de la SBF), Le Monde (archives numérisées, cote du jour), documents de référence des sociétés (historique boursier sur 10 ans) |
| Fins de mois 1973-1987 et 1998 (crise russe) | Points intermédiaires reconstitués ; seuls les ★ sont A | Historique Euronext (`live.euronext.com`, getHistoricalPrice) pour 1990 et après ; Larousse « Journal de l'année » et bulletins Banque de France avant |
| Mois exacts du plus haut et du plus bas de 1992 | Probablement fin mai et début octobre | Euronext, presse de l'époque |
| Rendement du dividende avant 1990 | C (5-7 % fin des années 1970) : pèse sur la SICAV et sur Cousin Indice en P1 | Gallais-Hamonno & Arbulu (1995) ; Le Bris & Hautcœur (2010) |
| Indice 1950-1968 | Reconstitué (C), hors V1 (A9) | Le Bris & Hautcœur, indice INSEE des valeurs à revenu variable |
| Date du NSC (≈ 1995) | B | Archives SBF / Euronext |
| Durées de récupération P1 (02 §7 Q2) | C | Recalcul sur la courbe générée |
| **Convention « fin de mois » ou « point de séance »** | Plusieurs ancrages d'actions de 02 §4.5 sont des **creux de séance** (L'Oréal et Total 03/2009, BNP 09/2011 et 03/2020, TotalEnergies 03/2020 = 23 € alors que la clôture de fin mars est d'environ 33-35 €, à vérifier) alors que l'indice du même mois est une fin de mois | Règle à adopter : **ancrage = clôture de fin de mois**, sauf choix narratif documenté. À corriger dans 02 §4.5 lors d'une prochaine mission. |
| **Rappel à 12 mois en fin de période** | Les événements P1 n° 8 (09/1992) et P3 n° 7 (04/2025) n'ont pas de mois + 12 dans la partie | À signaler au client et au développeur : rappel remplacé par une ligne au bilan, ou rappel raccourci. |

---

## 4. Validation des valeurs « dev » (mission du 2026-10-26)

Règle : les ancrages sont des clôtures de fin de mois. « Garder » = valeur cohérente avec les sources ou avec le récit de 02 §7 Q2.

| Fichier | Clé | Actuelle | Recommandée | Cert. | Motif |
|---|---|---|---|---|---|
| periode_p1.js | ancragesIndice 1978-02 | 222 | garder | C | Baisse avant les législatives de mars, cohérente. |
| periode_p1.js | ancragesIndice 1978-03 | 245 | garder | C | Début du rebond après le 2e tour (19/03). |
| periode_p1.js | ancragesIndice 1978-07 | 300 | garder | B | « Plus de +30 % avant l'été » (Larousse) : 229 → 300. |
| periode_p1.js | ancragesIndice 1981-05 | 340 | garder | C | Étape entre 400 (8 mai) et 285 (juin, −30 %). |
| periode_p1.js | ancragesIndice 1992-05 | 2 050 | garder | B | Plus haut annuel 2 077,5. |
| periode_p1.js | ancragesIndice 1992-08 / 09 / 10 | 1 850 / 1 700 / 1 720 | garder | C | Plus bas annuel 1 611 en séance ; chute ≈ −17 % depuis mai, conforme à l'impact « ≈ −15 % » de l'événement n° 8. |
| periode_p1.js | produits.elf.ancrages (toute la série) | 300 (1977-12) … 1 500 (1992-12) | **× 0,24** : 72, 96, 150, 190, 145, 135, 180, 190, 215, 230, 190, 275, 360, 325, 350, 360 | C (B pour fin 1992) | Elf cotait 416-420 F en janv. 1994 : fin 1992 ≈ 350 F, et non 1 500 F. Le profil (fort en 1979-1980, plat en 1986) est conservé. |
| periode_p1.js | produits.loreal.ancrages (toute la série) | 500 (1977-12) … 6 000 (1992-12) | **× 0,17** : 85, 120, 140, 155, 145, 155, 240, 290, 425, 630, 495, 715, 920, 780, 950, 1 020 | C | Ancre P2 : 20 € fin 1995 ≈ 1 310 F avant la division par 10 de 2000 ; le CAC est stable de 1992 à 1995, d'où ≈ 1 000 F fin 1992. Le profil (≈ ×1,5 l'indice) est conservé. |
| periode_p1.js | produits.peugeot.ancrages | 350 … 700 | garder | C | Niveaux plausibles ; profil conforme à CA-21 (−60 % de fin 1979 à fin 1984, ×5,6 de fin 1984 à fin 1989). |
| periode_p1.js | produits.saintgobain.ancrages | 310 … 420 | garder | A (310) / C | 230 F fin 1987 (sous le prix d'OPV) est cohérent avec bêta 1,2 et le krach ; la leçon « tout le monde achète » en profite. |
| periode_p2.js | ancragesIndice 1998-07 / 08 / 09 / 10 | 4 400 / 3 750 / 3 200 / 3 450 | garder | C | Le pic de juillet ≈ 4 400 est en séance (B) ; la fin de mois est probablement un peu plus basse, et le creux de début octobre ≈ 2 850-2 900. À vérifier sur l'historique Euronext. |
| periode_p2.js | ancragesIndice 2010-04 / 05 / 06 | 3 816 / 3 507 / 3 443 | garder | A/B | Clôtures de fin de mois réelles. |
| periode_p3.js | ancragesIndice 2012-06 / 07 | 3 197 / 3 291 | garder | A/B | Clôtures de fin de mois réelles. |
| periode_p3.js | ancragesIndice 2016-05 / 06 | 4 506 / 4 237 | garder | A/B | Idem. |
| periode_p3.js | ancragesIndice 2024-05 / 06 | 7 993 / 7 479 | garder | A/B | Idem. |
| periode_p3.js | ancragesIndice 2025-02 / 03 / 05 | 8 111 / 7 791 / 7 750 | garder | A | Idem (8 111,6 / 7 790,7 / 7 751,9). |
| periode_p3.js | ancragesIndice 2025-04 | 7 100 | **garder, en documentant l'écart** | A (séance) | La fin avril réelle est 7 593,87 (−2,5 % sur le mois) : elle rendrait la modale « pire semaine depuis 2020 » incompréhensible. 7 100 ≈ clôtures des 8 et 10 avril (plus bas 6 863 le 9). Choix narratif à mentionner dans un commentaire du fichier. |
| series.js | annuel, livretTaux, livretPlafond, peaPlafond | — | aucune correction | A | Clôtures identiques à 02 §4.2. Les autres séries relèvent du banquier (01). |
| periode_p3.js (hors dev) | totalenergies.ancrages 2020-03 | 23 | ≈ 34 si l'on applique la convention de fin de mois | B/C | 23 € = creux de séance (≈ 18/03). À trancher en même temps que la convention du §3. |

Les points P2 et P3 non marqués « dev » reprennent 02 §4.4 et §4.5 sans écart notable. CA-21 reste vérifié (France Télécom 219 € en 03/2000 et 7 € en 09/2002 ; Alcatel de 100 € à 3 € = −97 %).

---

## 5. Journal des missions

| Date | Mission | Résultat | À retenir / erreurs à ne pas refaire |
|---|---|---|---|
| (antérieure) | Rédaction de 02 (notions, chronologie, séries, simulation) puis §7 (réponses au client Q1-Q6) | Base de données du jeu ; périodes et événements V1 validés par le client (03 A7, §6.1) | Vérifier les clôtures auprès de 2 sources (piège de 1999 à 5 858) ; calculer les variations plutôt que les recopier (2020). |
| 2026-10-26 | Création de cette base ; validation des valeurs « dev » de `jeu/data/` | Indice : tous les points dev sont gardés. **Elf (× 0,24) et L'Oréal (× 0,17) P1 sont à corriger.** 2025-04 est gardé comme choix narratif. | Toujours dire si un ancrage est une **fin de mois** ou un **point de séance**. Vérifier qu'un événement de fin de période laisse 12 mois pour son rappel. Les niveaux absolus en francs des actions avant 1990 sont mes données les plus fragiles. Le code n'a pas été modifié (la V1 web est archivée : le portage Godot reprend `jeu/data/`). |
| 2026-10-27 | Vérification pour le banquier (démo 01/1984 → 12/1988) : privatisations 1986-1987 et taux monétaires | §2.6 et §2.7 ajoutés ; Suez confirmé en **10/1987** (le 10/05/1987 de l'IGPDE est une inversion probable) ; taux monétaires 1988-1989 du banquier à relever d'environ 0,5 point ; une ligne précisée dans 02 §2.1 | Une date isolée qui contredit le récit (krach, paiement reporté) se vérifie par recoupement : listes « achevées au 31/07 », questions parlementaires. Les PDF scannés (Sénat) ne sont pas lisibles ici, faute de pdftoppm. |

Sources utilisées le 2026-10-27 : [IGPDE, dates de mise en vente](https://books.openedition.org/igpde/3866?dir=next) ; [Larousse, les privatisations (1988)](https://www.larousse.fr/archives/journaux_annee/1988/104/les_privatisations) ; [Universalis, OPV Société Générale (juin 1987)](https://www.universalis.fr/chronologie/france/1987/8/) ; [Assemblée nationale, QE n° 3362 (Suez)](https://www.assemblee-nationale.fr/dyn/9/questions/QANR5L9QE3362.pdf) ; [Sénat, rapport 1988-1989 n° 328 (prix Paribas, CGE, Saint-Gobain)](https://www.senat.fr/rap/1988-1989/i1988_1989_0328.pdf) ; [FRED, taux à 3 mois](https://fred.stlouisfed.org/data/IR3TIB01FRA156N) ; [FRED, taux au jour le jour](https://fred.stlouisfed.org/data/IRSTCI01FRA156N).

Sources utilisées le 2026-10-26 : [Macrotrends, CAC 40 (plus haut et plus bas 1992)](https://pro.macrotrends.net/2596/cac-40-index-france-historical-chart-data) ; [Tradingsat, clôture du 30/04/2025](https://www.tradingsat.com/cac-40-FR0003500008/actualites/cac-40-l-indice-d-inflation-prefere-de-la-fed-s-assagit-le-cac-40-sauve-l-honneur-pour-finir-le-mois-d-avril-1137696.html) ; [TradingView / Dow Jones, plus bas du 09/04/2025](https://tr.tradingview.com/news/DJN_DN20250805009845%3A0-cac-40-index-ends-0-14-lower-at-7621-04-data-talk) ; [UPI, Elf en janv. 1994](https://www.upi.com/Archives/1994/01/21/Public-offering-of-Elf-Aquitaine-opens/4776759128400/) ; [Saint-Gobain, document de référence 2004](https://www.bnains.org/archives/communiques/Saint_Gobain/20050601_Actualisation_du_document_de_reference_2004_Saint_Gobain.pdf) ; [IGPDE, dates des privatisations](https://books.openedition.org/igpde/3866?dir=next) ; [ABC Bourse, clôtures 1998-2008](https://www.abcbourse.com/analyses/chronique-retrospective_de_10_ans_de_bourse_a_paris-71).
