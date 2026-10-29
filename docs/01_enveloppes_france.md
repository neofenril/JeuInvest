# 01 — Enveloppes, produits, acteurs et réformes de l'épargne en France (1950 → 2026)

> Rédigé par « le banquier » (35 ans de réseau et de gestion de patrimoine) pour le projet **JeuClaude**.
> Objet : savoir **ce qu'un particulier français pouvait réellement acheter, où, à quel coût et avec quelle fiscalité, à une date donnée**.
> Contenu pédagogique et historique, **pas** un conseil en investissement.

## Légende des niveaux de certitude

| Code | Signification |
|---|---|
| **[A]** | Certain : date ou chiffre recoupé par plusieurs sources ou par un texte officiel (loi, décret). |
| **[B]** | Probable : une source fiable ou mémoire professionnelle solide, à ±1 an ou à quelques % près. |
| **[C]** | Approximatif : ordre de grandeur. Assez bon pour un jeu, pas pour un manuel. |

Conventions monétaires (à respecter dans le moteur) :

| Période | Unité | Conversion |
|---|---|---|
| ≤ 31/12/1959 | Ancien franc (AF) | 100 AF = 1 NF **[A]** |
| 01/01/1960 → 31/12/1998 | Nouveau franc (F) | — |
| 01/01/1999 → 31/12/2001 | Euro scriptural (marchés, cotations en €), billets en F | 1 € = 6,55957 F **[A]** |
| ≥ 01/01/2002 | Euro fiduciaire (franc retiré le 17/02/2002) | — **[A]** |

> Conseil développeur : stocker **tout en euros constants ou en euros courants** en interne, et n'afficher francs ou anciens francs qu'à l'écran selon la date jouée.

---

## 1. Tableau chronologique des enveloppes et produits

### 1.1 Vue synthétique (frise)

| id (suggestion) | Produit | Début | Fin (ou n'est plus commercialisé) | Certitude dates |
|---|---|---|---|---|
| `livret_a` | Livret A (Caisses d'épargne, La Poste) | 1818 (existe en 1950) | — | A |
| `livret_bleu` | Livret bleu (Crédit Mutuel, même régime que le Livret A) | 1975 | fusionné dans le Livret A en 2009 | B |
| `livret_bancaire` | Livret bancaire fiscalisé (« livret B », super-livret) | avant 1950 | — | B |
| `actions_directes` | Actions françaises en direct (titres papier, puis dématérialisés) | avant 1950 | — | A |
| `obligations` | Obligations, rentes, emprunts d'État | avant 1950 | — | A |
| `or_napoleon` | Or physique : Napoléon 20 F, lingots | avant 1950 | — | A |
| `assurance_vie` | Assurance-vie « traditionnelle », puis multisupport | avant 1950 (niche) ; essor 1976-1990 | — | B |
| `cel` | Compte épargne logement | 1965 | — | A |
| `sicav` | SICAV | 1964 (décret du 20/09/1963) | — | A |
| `pee` | Épargne salariale (PEE, participation) | 1967 | — | A |
| `pel` | Plan épargne logement | 1969 (décret du 24/12/1969) | — | A |
| `scpi` | SCPI (« pierre-papier ») | 1970 (loi du 31/12/1970) | — | A |
| `fonds_euros` | Fonds en euros (« fonds en francs » avant 1999) via assurance-vie | ≈1976-1980 (AFER 1976) | — | B |
| `sicav_monory` | SICAV / achats d'actions « Monory » (déduction fiscale) | 07/1978 | 1981-1982 | A |
| `fcp` | FCP (développement effectif) | 1979 (loi du 13/07/1979) | — | A |
| `lep` | Livret d'épargne populaire | 1982 | — | A |
| `codevi` | Codevi → LDD (2007) → LDDS (2016-2017) | 1983 | — | A |
| `cea` | Compte d'épargne en actions (Delors) | 1983 | 31/12/1988 (prorogé d'un an par la LFR du 30/12/1987) | A/B |
| `per_1988` | Plan d'épargne retraite (ancien) | 01/01/1988 | 1989 (remplacé par le PEP) | B |
| `pep` | Plan d'épargne populaire | 1990 | plus d'ouverture depuis le 25/09/2003 | A |
| `pea` | Plan d'épargne en actions | 1992 (loi du 16/07/1992) | — | A |
| `madelin` | Contrat Madelin (travailleurs non salariés) | 1994 | plus de nouveaux contrats depuis le 01/10/2020 | A |
| `livret_jeune` | Livret jeune (12-25 ans) | 1996 | — | B |
| `fcpi` | FCPI (réduction d'impôt) | 1997 | — | B |
| `etf` | Trackers / ETF | 01/2001 (premiers ETF CAC 40 à Paris) | — | B |
| `perp` | PERP (loi Fillon) | 2003-2004 | plus de nouveaux contrats depuis le 01/10/2020 | A |
| `perco` | PERCO (épargne salariale retraite) | 2003 | remplacé par le PER collectif (2020) | A |
| `pea_pme` | PEA-PME | 2014 | — | A |
| `crypto` | Crypto-actifs (hors enveloppe) | ≈2013 (accès grand public) | — | B |
| `per` | PER individuel (loi PACTE) | 01/10/2019 | — | A |
| `pea_jeune` | PEA « jeune » (18-25 ans rattachés) | 2019 | — | A |
| `pea_climat` | Plan d'épargne avenir climat (moins de 18 ans) | 07/2024 | — | B |

### 1.2 Fiches détaillées

#### Livret A (et Livret bleu)

| Paramètre | Valeur |
|---|---|
| Disponibilité | Toute la période. **Distribution exclusive** Caisses d'épargne et La Poste (Caisse nationale d'épargne), plus le Crédit Mutuel (Livret bleu) dès 1975. **Banalisation** : toutes les banques à partir du **01/01/2009** (loi LME du 04/08/2008). [A] |
| Plafond | Voir le tableau du §4.2. 15 000 F (1966) → 100 000 F (1991) → 15 300 € (2002) → 19 125 € (10/2012) → **22 950 €** (depuis le 01/01/2013). [A pour 1966 et après] |
| Taux | Fixé par l'État. Formule réglementée depuis 2004 (inflation et taux courts), fréquemment non appliquée. Historique au §4. |
| Fiscalité | **Intérêts exonérés d'IR et de prélèvements sociaux** depuis toujours. C'est l'argument commercial principal. [A] |
| Frais | Aucun. |
| Calcul | Intérêts par **quinzaine** (dépôt valorisé à partir du 1er ou du 16 suivant, retrait arrêté à la quinzaine précédente), crédités au 31/12. [A] |
| **Jeu (simplifié)** | Taux annuel lu dans la table selon la date ; intérêts mensuels au prorata, capitalisés au 31/12 ; plafond selon la date ; 1 par joueur ; liquidité immédiate ; fiscalité nulle. |

#### Livrets bancaires fiscalisés

| Paramètre | Valeur |
|---|---|
| Disponibilité | Toute la période, dans toutes les banques. [B] |
| Taux | En général inférieur ou égal au Livret A ; taux libres depuis la fin des années 1980 [C]. Taux promotionnels fréquents depuis 2005. |
| Fiscalité | Intérêts imposables (barème ou prélèvement libératoire, puis PFU 30 % en 2018 et 31,4 % en 2026). |
| **Jeu** | Taux = Livret A − 0,5 pt (plancher 0,1 %), sans plafond, fiscalité = PFU de l'époque. Utile pour le « trop-plein » au-delà du plafond du Livret A. |

#### LEP (Livret d'épargne populaire)

| Paramètre | Valeur |
|---|---|
| Disponibilité | Depuis **1982** (premier taux connu au 14/01/1983 : 8,50 %). [A] |
| Condition | **Sous conditions de ressources** (revenu fiscal de référence plafonné). |
| Plafond | 5 000 F (1982), 10 000 F (01/1983), 20 000 F (04/1984), 30 000 F (11/1991), 40 000 F (08/1999) [B], puis ≈ 7 700 € pendant des années, et **10 000 €** depuis le **01/10/2023** [B]. |
| Taux | Supérieur au Livret A (historique au §4.3). |
| Fiscalité | Exonéré d'IR et de PS. |
| **Jeu** | Débloqué seulement si le revenu du personnage est « modeste » (événement de vie). Taux de la table LEP. Bonne mécanique pédagogique (« vérifiez vos droits »). |

#### Codevi → LDD → LDDS

| Paramètre | Valeur |
|---|---|
| Dates | Codevi créé en **1983** ; devenu **LDD** en 2007 (le plafond passe de 4 600 € à 6 000 €) ; **12 000 €** depuis 10/2012 ; renommé **LDDS** fin 2016 (effectif le 01/01/2017). [A] |
| Plafond Codevi | 10 000 F en 1983, puis 20 000 F, puis 30 000 F (≈ 4 600 €) [B/C] |
| Taux | Aligné sur le Livret A (à 0,25 pt près selon les périodes). [B] |
| Fiscalité | Exonéré d'IR et de PS. |
| **Jeu** | Clone du Livret A, avec un plafond propre, disponible à partir de 1983. |

#### Épargne-logement : CEL (1965) et PEL (1969)

| Paramètre | CEL | PEL |
|---|---|---|
| Création | Loi du 10/07/1965 [A] | Décret du 24/12/1969 [A] |
| Plafond | 100 000 F, puis **15 300 €** [A] | 400 000 F, puis **61 200 €** [A] |
| Taux | Variable (≈ 2/3 du Livret A) | **Fixé à l'ouverture pour toute la vie du plan** |
| Contraintes | Liquide (retraits partiels possibles) | Versement minimum annuel (540 € par an aujourd'hui), durée minimale 4 ans, retrait = clôture ; durée maximale de 15 ans pour les plans ouverts depuis 2011 |
| Prime d'État | Oui (avant 2018) | Oui, conditionnée au prêt (depuis 2011) ; supprimée pour les plans ouverts depuis le 01/01/2018 |
| Fiscalité | Intérêts exonérés d'IR avant 2018 (PS dus) ; PFU depuis 2018 | Exonération d'IR jusqu'aux 12 ans du plan (plans antérieurs à 2018) ; **PFU dès le 1er euro pour les PEL ouverts depuis 2018** [A] |
| Frais | Aucun | Aucun |

Taux PEL par période d'ouverture (hors prime d'État ; source La finance pour tous) [A à partir de 1985, B avant] :

| Ouverture | Taux épargne | Remarque |
|---|---|---|
| 24/12/1969 – 03/1972 | 4,00 % | prime incluse [C] |
| 04/1972 – 06/1974 | 3,50 % | [C] |
| 01/1975 – 04/1977 | 4,50 % | [C] |
| 05/1977 – 12/1980 | 4,00 % | [C] |
| 01/1981 – 05/1983 | 5,30 % | hors prime [B] |
| 06/1983 – 07/1984 | 6,30 % | hors prime [B] ; ≈ 8,25 % prime incluse [C] |
| 08/1984 – 06/1985 | 5,30 % | hors prime [B] ; ≈ 7 % prime incluse [C] |
| 07/1985 – 15/05/1986 | 4,75 % | hors prime (≈ 6 % avec prime) |
| 16/05/1986 – 06/02/1994 | 4,62 % | ≈ 6 % avec prime |
| 07/02/1994 – 22/01/1997 | 3,84 % | ≈ 5,25 % avec prime |
| 23/01/1997 – 08/06/1998 | 3,10 % | ≈ 4,25 % avec prime |
| 09/06/1998 – 25/07/1999 | 2,90 % | |
| 26/07/1999 – 30/06/2000 | 2,61 % | |
| 01/07/2000 – 31/07/2003 | 3,27 % | ≈ 4,5 % avec prime |
| 01/08/2003 – 31/01/2015 | 2,50 % | ≈ 3,5 % avec prime |
| 02/2015 – 01/2016 | 2,00 % | |
| 02/2016 – 07/2016 | 1,50 % | |
| 08/2016 – 12/2022 | 1,00 % | |
| 2023 | 2,00 % | |
| 2024 | 2,25 % | |
| 2025 | 1,75 % | |
| depuis le 01/01/2026 | 2,00 % | |

**Jeu (simplifié)** : PEL = « taux verrouillé » à l'ouverture (bonne leçon sur la valeur d'un taux fixe quand les taux baissent), blocage de 4 ans, versement mensuel imposé. Le CEL est facultatif en V1.

#### Compte-titres ordinaire (CTO) et actions en direct

| Paramètre | Valeur |
|---|---|
| Disponibilité | Toute la période. Avant 1984 : titres **papier** au porteur (coupons à découper, garde chez soi ou en banque) ou nominatifs. **Dématérialisation** effective le 03/11/1984. [A] |
| Plafond | Aucun. |
| Accès | Via la banque, qui transmettait l'ordre à un **agent de change** (monopole) jusqu'en 1988 ; ensuite via les sociétés de bourse, puis les banques, puis les courtiers en ligne (voir §2). |
| Univers | 1950-1985 : actions françaises cotées à Paris (et dans les bourses régionales). **Valeurs étrangères difficiles d'accès** à cause du contrôle des changes (« devise-titre » de 1971 à 1986, contrôle levé totalement le 01/01/1990) [B]. Second marché 1983, Nouveau marché 1996, Euronext 2000. |
| Marché à terme pour particuliers | **Règlement mensuel (RM)** jusqu'en 09/2000 (achat à crédit avec liquidation mensuelle), remplacé par le **SRD**. [A] |
| Fiscalité (synthèse) | Dividendes : barème IR, avec **avoir fiscal** (1965-2004) qui neutralisait en partie l'IS ; plus-values : **quasi non imposées avant 1978**, puis imposées au-delà d'un seuil de cessions (1978-2010), barème avec abattements (2013-2017), **PFU 30 %** (2018), **31,4 %** (2026). Détail au §3.3. |
| Frais | Courtage + impôt de bourse (jusqu'en 2007) + droits de garde (≈ 0,2-0,4 % par an en banque de réseau ; souvent 0 en ligne). Voir le §2.2. |
| **Jeu** | Enveloppe par défaut toujours disponible. Fiscalité « plate » par époque (table §5.3). Frais = table §2.2. Univers = indices et sociétés disponibles à la date jouée. |

#### Obligations et emprunts d'État (grand public)

| Emprunt | Date | Caractéristiques | Intérêt pour le jeu | Certitude |
|---|---|---|---|---|
| **Rente Pinay 3,5 % 1952** | 05-06/1952 | Rente 3,5 % **indexée sur l'or (Napoléon)**, exonérée d'impôt sur le revenu et de **droits de succession** ; ≈ 428 Md AF collectés | Produit « miracle » des familles : rendement faible mais protection contre l'inflation et transmission sans droits | B |
| **Emprunt Pinay 3,5 % 1958** | 06/1958 | Même logique (indexation or, exonérations) | Idem | B |
| Conversion 1973 | 1973 | Les rentes Pinay sont converties en un emprunt 4,5 % 1973 indexé sur le Napoléon | Événement de portefeuille | B |
| **Emprunt Giscard 7 % 1973** | 01/1973 | 6,5 Md F, 7 %, capital **indexé sur l'or** (clause liée à l'unité de compte européenne) ; remboursé en **01/1988** pour ≈ 55 à 64 Md F de capital ; coût total ≈ 90 à 100 Md F | Exemple d'emprunt très coûteux pour l'État et très rentable pour l'épargnant | A (dates), B (montants) |
| **Emprunt obligatoire 1983** | 1983 | Prêt forcé de 10 % de l'impôt (au-delà d'un seuil), sur 3 ans, ≈ 11 % [C] | Événement « impôt déguisé » | C |
| OAT (dette standardisée) | 1985 | Création des OAT ; accès des particuliers surtout via SICAV obligataires | Fond de toile des taux longs | A |
| **Emprunt Balladur 6 % 1993** | 06-07/1993 | 110 Md F, 6 %, échangeable contre des actions des privatisations | Lien emprunt / privatisations | B |

Fiscalité des intérêts obligataires : barème IR ou prélèvement libératoire (instauré en 1965 ; ≈ 25 % dans les années 1960-1980, 15-16 % dans les années 1990, 18 % en 2008, 19 % en 2011, 24 % en 2012 [C]), plus PS à partir de 1991-1998, puis PFU depuis 2018.
**Jeu** : en V1, les emprunts d'État sont des **événements datés** (fenêtre de souscription de 1 à 2 mois, coupon fixe, durée). Les obligations « courantes » passent par une SICAV obligataire générique dont le rendement suit le taux long.

#### SICAV et FCP (OPCVM)

| Paramètre | Valeur |
|---|---|
| Dates | SICAV : décret du 20/09/1963, **premières SICAV commercialisées en 1964** [A]. FCP : possibles dès 1963 mais développés après la **loi du 13/07/1979** [A]. |
| Types utiles | Actions françaises, obligataires, **monétaires** (boom des années 1980-1990), diversifiées ; à partir de 1990, actions internationales réellement accessibles. |
| Distributeurs | Banques (réseau), La Poste (fin des années 1980, Sogeposte [C]), assureurs (en UC), puis plateformes en ligne. |
| Frais | Droits d'entrée **2-5 %** en réseau (souvent 0 en ligne depuis les années 2000) ; frais de gestion annuels : actions **1,5-2,5 %**, obligataires 0,8-1,2 %, monétaires 0,3-0,8 % [B]. ETF (2001+) : **0,1-0,5 %**. |
| Fiscalité | Celle des valeurs mobilières (plus-values à la cession). Astuce historique (années 1980-1990) : **SICAV monétaires de capitalisation** sous le seuil de cession = plus-value non imposée [B]. |
| **Jeu** | 3 à 4 fonds génériques à partir de 1964 : « SICAV actions France » (suit l'indice − frais), « SICAV obligataire » (taux long), « SICAV monétaire » (taux court, à partir de 1981 environ), « Fonds actions monde » (à partir de 1990). ETF indiciel à partir de 2001. |

#### Assurance-vie (fonds en euros et unités de compte)

| Paramètre | Valeur |
|---|---|
| Disponibilité | Existe en 1950 (contrats de capital différé, rentes, obsèques), marginale comme placement. **Essor** à partir de **1976** (AFER) et surtout dans les années 1980-1990. Les **UC** existent par circulaires avant leur base légale (directive vie transposée en 1981, décret en 1988, assouplissement en 1992) ; les multisupports se démocratisent dans les années 1990 [B]. |
| Plafond | Aucun. |
| Distributeurs | Assureurs (UAP, AGF, GAN, nationalisés de 1946 à 1990-1996), bancassurance (Predica 1986, Sogecap, Cardif…), CNP via La Poste et les Caisses d'épargne, associations (AFER), courtiers en ligne (années 2000). |
| Frais | Entrée **2-5 %** en réseau (0 % en ligne depuis les années 2000) ; gestion **0,6-1 %** par an (fonds euros) et 0,5-1 % par an sur les UC, plus les frais des fonds. |
| Fiscalité des rachats | **Contrats antérieurs au 01/01/1983 : exonérés.** Contrats 1983-1989 : prélèvement libératoire dégressif (45 % / 25 % / 15 % puis 0 % après 6 ans). **Contrats souscrits depuis 1990 : seuil de 8 ans** (35 % avant 4 ans, 15 % de 4 à 8 ans, puis exonération). **Primes versées depuis le 26/09/1997** : après 8 ans, PL 7,5 % au-delà d'un **abattement annuel de 4 600 € / 9 200 €** (30 000 F / 60 000 F en 1998). **Primes versées depuis le 27/09/2017** : PFU 12,8 % avant 8 ans ; 7,5 % après 8 ans (12,8 % pour la part des encours au-delà de 150 000 €). **PS** : 17,2 % depuis 2018, et l'assurance-vie **reste à 17,2 % en 2026** (exclue de la hausse de CSG). [A/B] |
| Transmission | **Contrats souscrits avant le 20/11/1991 : aucun droit, quel que soit le montant** (seule réserve : art. 757 B de 1980, contrats souscrits tard, au-delà de 100 000 F). Contrats depuis le 20/11/1991 : primes après 70 ans taxées au-delà de 200 000 F (30 500 €) (art. 757 B, LFR 1991). Primes versées depuis le 13/10/1998 avant 70 ans : 20 % au-delà de 1 MF puis **152 500 € par bénéficiaire** (art. 990 I). Conjoint et partenaire de Pacs exonérés depuis le 22/08/2007. Détail : 11 §1.3.5. [A] |
| Risque spécifique | Loi **Sapin 2 (2016)** : le HCSF peut bloquer temporairement les rachats (événement possible dans le jeu, même s'il n'a jamais été déclenché). |

Rendement moyen des fonds en euros (net de frais de gestion, avant PS) :

| Année | Taux | Année | Taux | Année | Taux |
|---|---|---|---|---|---|
| ≈1985 | ≈ 10 % [C] | 2003 | 4,5 % | 2015 | 2,3 % |
| 1990 | ≈ 9 % [B] | 2004 | 4,4 % | 2016 | 1,9 % |
| ≈1995 | ≈ 7,5 % [C] | 2005 | 4,2 % | 2017 | 1,8 % |
| ≈1998 | ≈ 5,5-6 % [C] | 2006 | 4,1 % | 2018 | 1,8 % |
| 2000 | 5,3 % | 2007 | 4,1 % | 2019 | 1,5 % |
| 2001 | 5,3 % | 2008 | 4,0 % | 2020 | 1,3 % |
| 2002 | 4,8 % | 2009 | 3,6 % | 2021 | 1,3 % |
| | | 2010 | 3,4 % | 2022 | 1,9 % |
| | | 2011 | 3,0 % | 2023 | 2,6 % |
| | | 2012 | 2,9 % | 2024 | ≈ 2,5 % [B] |
| | | 2013 | 2,8 % | 2025 | ≈ 2,5 % [C] |
| | | 2014 | 2,5 % | | |

**Jeu** : fonds euros disponible à partir de **1976** (ou de 1980 pour simplifier), capital garanti, rendement = moyenne glissante sur 8 ans du taux long − 0,5 pt (approxime bien le lissage des assureurs), effet cliquet. UC à partir de 1990 (sinon on passe par une SICAV). Une seule règle fiscale par génération de contrat : `date_ouverture` + 8 ans.

#### PEA, PEA-PME, PEA jeune

| Paramètre | Valeur |
|---|---|
| Dates | **PEA : loi n° 92-666 du 16/07/1992** [A]. PEA-PME : loi de finances pour 2014 [A]. PEA jeune : loi PACTE 2019 [A]. |
| Plafond PEA | **600 000 F** (1992) → **120 000 €** (01/01/2002) → **132 000 €** (01/01/2003) → **150 000 €** (01/01/2014). [A] |
| Plafond PEA-PME | 75 000 € (2014) ; depuis PACTE : **225 000 € cumulés** PEA + PEA-PME. [A] |
| PEA jeune | 20 000 € (18-25 ans rattachés au foyer). [A] |
| Univers | Actions de sociétés de l'UE/EEE, OPCVM investis à au moins 75 % dans ces actions (ETF « synthétiques » éligibles). **Pas d'obligations, pas d'actions américaines en direct.** |
| Règles de retrait (historique) | 1992-2019 : retrait avant 8 ans = clôture ; gains taxés à 22,5 % avant 2 ans et à 16 % (puis 18-19 %) de 2 à 5 ans ; **après 5 ans exonération d'IR** ; après 8 ans, retraits partiels possibles mais versements bloqués. **PACTE (2019)** : après 5 ans, retraits partiels sans clôture et versements toujours possibles ; avant 5 ans, PFU 12,8 %. [A/B] |
| Prélèvements sociaux | Dus sur les gains (taux historiques par tranche jusqu'en 2017, puis taux en vigueur au retrait) : 17,2 % (2018) → **18,6 %** (gains constatés depuis le 01/01/2026). [A/B] |
| Frais | Depuis le **01/07/2020** (décret du 05/02/2020) : droits de garde ≤ 0,4 % par an (+ 5 € par ligne), courtage ≤ 0,5 % en ligne et 1,2 % autrement, transfert ≤ 15 € par ligne (plafond 150 €), ouverture ≤ 10 €. [A] |
| **Jeu** | Débloqué au 16/07/1992. Plafond selon la date. Horloge « 5 ans » visible (une mécanique très pédagogique). Retrait avant 5 ans = clôture (règle pré-2019) ou PFU (règle post-2019). |

#### Épargne retraite : PER 1988, PEP, Madelin, PERP, PERCO, PER (2019)

| Produit | Dates | Mécanisme fiscal | Distributeur | Certitude |
|---|---|---|---|---|
| CEA (prédécesseur) | 1983-1988 | Réduction d'impôt de 25 % des achats nets d'actions françaises (plafond 7 000 F / 14 000 F), 5 ans sans désinvestissement | Banques | B |
| PER « 1988 » | 01/01/1988 → 1989 | Déduction ou réduction d'impôt sur les versements | Banques, assureurs | C |
| **PEP** | 1990 → plus d'ouverture depuis le 25/09/2003 | Plafond 600 000 F (≈ 92 000 €), exonération d'IR après 8 ans, prime d'État pour les non-imposables | Banques (PEP bancaire), assureurs (PEP assurance) | A |
| **Madelin** | 1994 → 30/09/2020 | Versements déductibles du bénéfice (indépendants), sortie en rente | Assureurs | A |
| **PERP** | 2003 (loi Fillon du 21/08/2003) → 30/09/2020 | Versements déductibles du revenu, sortie en rente (20 % en capital) | Assureurs, banques | A |
| PERCO | 2003 → 2020 | Épargne salariale retraite | Entreprise | A |
| **PER individuel** | **01/10/2019** (loi PACTE du 22/05/2019) | Versements déductibles dans un plafond (≈ 10 % des revenus) ; sortie en capital ou en rente ; capital imposé à la sortie | Banques, assureurs, en ligne | A |

**Jeu** : PER (2019+) ou PERP (2004-2019) en V2 ; l'intérêt pédagogique (déduction aujourd'hui, impôt demain, blocage jusqu'à la retraite) suppose de modéliser la tranche marginale d'imposition (TMI) du joueur.

#### Mesures « actions » incitatives : Monory (1978) et CEA (1983)

| Dispositif | Dates | Avantage | Certitude |
|---|---|---|---|
| **Loi Monory** (loi du 13/07/1978) | Revenus 1978 à 1981 | **Déduction du revenu imposable** de 5 000 F par foyer et par an (+ 500 F par enfant) pour les achats nets d'actions françaises ou de **SICAV Monory** ; 800 000 foyers en 1978 et ≈ 1 million en 1979 | A |
| **CEA** (Delors) | 1983-1988 | Réduction d'impôt de 25 % des achats nets (plafond 7 000 / 14 000 F) | B |

**Jeu** : bonus fiscal temporaire (pop-up « Nouvelle loi ! »), excellent événement pour 1978 et 1983.

#### Or (Napoléons, lingots)

| Paramètre | Valeur |
|---|---|
| Disponibilité | Toute la période : achat au guichet des banques et chez les changeurs ; **cotation officielle à la Bourse de Paris** (marché de l'or) jusqu'en 2004 environ, puis fixing par des opérateurs privés. [B] |
| Napoléon 20 F | 5,81 g d'or fin (titre 900 ‰). Prime historique sur le métal très variable (de 0 à plus de 50 % dans les années 1970). [A pour le poids, B pour la prime] |
| Anonymat | Achats anonymes historiquement possibles ; épisode de levée de l'anonymat en 1981-1982 [C] ; le paiement en espèces est limité aujourd'hui. |
| Fiscalité à la vente | **Taxe forfaitaire** sur le prix de cession : ≈ 7,5-8 % jusqu'en 2011 [C], **10,5 %** (2014) [B], **11,5 %** (depuis 2019 environ) [B] ; ou option pour le **régime des plus-values** (abattement pour durée de détention, exonération après 22 ans) [B]. |
| Frais | Commission d'achat ou de vente ≈ 3-5 % + frais de garde au coffre. |
| **Jeu** | Actif « refuge » disponible dès 1950, cours de l'or en francs, prime aléatoire, taxe forfaitaire de l'époque à la vente. Très bon contrepoint pour les années 1970 (inflation). |

#### Immobilier « papier » : SCPI

| Paramètre | Valeur |
|---|---|
| Dates | Ancêtre « La Civile Foncière » en 1964 ; statut SCPI par la **loi n° 70-1300 du 31/12/1970**. [A] |
| Frais | Souscription **8-12 %** ; gestion ≈ 10-12 % des loyers. [B] |
| Rendement | ≈ 4-6 % distribués (années 1990-2010) [C] ; crise de 2023-2024 (baisses de valeur de parts, retraits bloqués). [B] |
| Fiscalité | Revenus fonciers (TMI + PS) en direct ; PFU ou fiscalité assurance-vie si la SCPI est logée en UC. **IFI** depuis 2018. |
| **Jeu** | V2. En V1, un événement de vie « acheter sa résidence principale » suffit (crédit, apport). Pas de défiscalisation immobilière (Malraux 1962, Périssol 1996, Robien 2003, Scellier 2009, Pinel 2014-2024) en V1. |

#### Épargne salariale (PEE, participation)

| Paramètre | Valeur |
|---|---|
| Dates | Intéressement (1959), **participation obligatoire et PEE (ordonnances de 1967)**. [A] |
| Mécanique | Blocage de 5 ans, abondement de l'employeur, exonération d'IR (PS dus). |
| **Jeu** | Événement de vie « votre employeur propose un PEE » (abondement = bonus). Optionnel en V1. |

#### Crypto-actifs

| Paramètre | Valeur |
|---|---|
| Disponibilité | Accès grand public vers 2013-2017 ; plateformes enregistrées PSAN (AMF) depuis 2019, puis régime MiCA (2024-2026). [B] |
| Fiscalité | Plus-values de cession imposées au PFU (30 % depuis 2019) [B]. |
| **Jeu** | V2, éventuellement sous forme d'événement « tentation spéculative ». |

---

## 2. Les acteurs et le coût de passer un ordre

### 2.1 Qui fait quoi, et quand

| Période | Acteur | Rôle pour le particulier | Certitude |
|---|---|---|---|
| 1945-1946 → années 1980 | **Banques nationalisées** (Crédit Lyonnais, Société Générale, CNEP et BNCI, fusionnées en BNP en 1966) et banques privées ou d'affaires | Guichet : prennent l'ordre et le transmettent à l'agent de change ; garde des titres | A |
| → 1988 | **Agents de change** (officiers ministériels, monopole de la négociation, Compagnie des agents de change) | Exécution des ordres à la criée ; le particulier fortuné peut avoir « son » agent de change | A |
| Toute la période | **Caisses d'épargne** et **La Poste** (Caisse nationale d'épargne, CCP) | Livret A, puis CEL/PEL ; La Poste distribue aussi des SICAV et de l'assurance-vie (CNP) | A/B |
| 1966-1967 | Réformes Debré : décloisonnement, multiplication des guichets, **bancarisation** des ménages (mensualisation des salaires dans les années 1970) | Avant 1967, une grande partie des ménages n'a ni compte bancaire ni titres | B |
| 1967 | **COB** (ancêtre de l'AMF, créée en 2003) | Régulateur | A |
| 22/01/1988 | **Loi n° 88-70** : les agents de change deviennent des **sociétés de bourse**, rachetées par les banques | — | A |
| 01/07/1989 | **Courtages libres** (fin du tarif réglementé) | Début de la concurrence sur les prix | A |
| 1984-1990 | Cortal (1984, banque directe d'épargne) [C] ; Minitel boursier (fin des années 1980) [B] | Ordres par téléphone ou Minitel | C |
| 1995-2000 | **Courtiers en ligne** : Fimatex (1995), Bourse Direct (1996), Self Trade, Consors, ClickTrade, Boursorama (site en 1998, courtage en 2002), Fortuneo (≈ 2000) | Ordres par Internet, frais divisés par 3 à 5 | B |
| 2000 | **Euronext** (Paris-Amsterdam-Bruxelles), SRD | — | A |
| 2009 | Livret A distribué par toutes les banques | — | A |
| ≈2013-2021 | **Néo-courtiers** : Degiro (arrivé en France au milieu des années 2010) [C], Trade Republic (≈ 2021 en France, licence bancaire en 12/2023, **PEA** proposé en 2025-2026) [B/C], Revolut, eToro… | Ordres à 0-1 €, plans d'investissement programmés | B/C |

### 2.2 Frais de courtage typiques par époque (ordre de 5 000 € ou équivalent)

| Période | Canal | Courtage (ordre de grandeur) | Taxes sur l'opération | Droits de garde | Certitude |
|---|---|---|---|---|---|
| 1950-06/1989 | Banque → agent de change | Courtage réglementé ≈ 0,5-0,65 % + commission bancaire ; **≈ 1 % à 1,5 % au total**, minimum fixe | **Impôt de bourse ≈ 0,3 %** (plafonné) | ≈ 0,2-0,4 % par an + frais de coupon | C |
| 07/1989-1999 | Banque de réseau | ≈ 1-1,5 %, minimum ≈ 50-100 F | Impôt de bourse 0,3 % (0,15 % au-delà de 1 MF, plafond ≈ 4 000 F) | ≈ 0,2-0,3 % par an + frais par ligne | B/C |
| 1996-2007 | Courtier en ligne | ≈ 0,5-0,8 % ou forfait de 10-20 € | Impôt de bourse 0,3 % jusqu'à 153 000 € (0,15 % au-delà), **plafond 610 €**, **supprimé le 01/01/2008** | Souvent 0 | A (impôt), B (courtage) |
| 2008-07/2012 | En ligne / réseau | En ligne : 0,1-0,5 % (minimum 5-10 €) ; réseau : ≈ 0,5-1 % | Aucune | En ligne 0 ; réseau ≈ 0,2-0,3 % | B |
| 08/2012 → | Idem | 2015 (étude AMF) : **26,60 € en banque contre 8,40 € en ligne** pour un ordre de 5 000 € | **TTF** sur les **achats** d'actions françaises de capitalisation > 1 Md€ : **0,2 %** (08/2012), **0,3 %** (01/2017), **0,4 %** (01/04/2025) | PEA plafonné depuis 07/2020 | A |
| ≈2019 → | Néo-courtier | **0 à 1 €** par ordre ; coût caché : spread, frais de change | TTF identique | 0 | B |

**Jeu (table de frais proposée)** :

| Époque jeu | `courtage_pct` | `courtage_min` | `taxe_operation_pct` | `garde_pct_an` |
|---|---|---|---|---|
| 1950-1988 | 1,0 % | 30 F | 0,3 % (achats et ventes) | 0,3 % |
| 1989-1999 | 1,0 % (banque) ou 0,6 % (en ligne, à partir de 1997) | 80 F / 15 € | 0,3 % | 0,25 % / 0 % |
| 2000-2007 | 0,5 % (en ligne) / 1,0 % (banque) | 10 € / 15 € | 0,3 % | 0 % / 0,25 % |
| 2008-2012 | 0,3 % / 0,8 % | 5 € / 12 € | 0 % | 0 % / 0,2 % |
| 2012-2018 | 0,2 % / 0,6 % | 2 € / 10 € | TTF 0,2 % puis 0,3 % (achats, grandes valeurs FR) | 0 % / 0,2 % |
| 2019 → | 1 € fixe (néo-courtier) / 0,5 % (banque) | 1 € | TTF 0,3 % puis 0,4 % (04/2025) | 0 % |

---

## 3. Lois, réformes et grandes opérations grand public

### 3.1 Chronologie des réformes (effet pour l'épargnant)

| Date | Texte ou événement | Effet pour l'épargnant | Certitude |
|---|---|---|---|
| 1945-1946 | Nationalisation de la Banque de France, des 4 grandes banques de dépôt et des grandes compagnies d'assurance | L'épargnant traite surtout avec l'État-banquier | A |
| 05/1952 | **Rente Pinay** 3,5 % indexée sur l'or | Placement refuge, exonéré de droits de succession | B |
| 12/1958 | Plan Pinay-Rueff, dévaluation | Stabilisation ; prépare le nouveau franc | A |
| 01/01/1960 | **Nouveau franc** (100 AF = 1 NF) | Affichage des montants | A |
| 1963-1964 | **SICAV** | Premier accès « collectif » à la bourse | A |
| 1965 | **Avoir fiscal** (loi du 12/07/1965) ; épargne-logement (CEL) ; prélèvement libératoire sur les obligations | Dividendes moins taxés | A/B |
| 1966-1967 | Réformes Debré (bancarisation) ; COB ; participation et PEE | — | A |
| 1969 | PEL | — | A |
| 1970 | SCPI | — | A |
| 01/1973 | **Emprunt Giscard 7 %** indexé sur l'or | Gros gain pour les porteurs en 1988 | A |
| 1973-1974 | 1er choc pétrolier, inflation à 2 chiffres | Rendement réel du Livret A négatif | A |
| 05/07/1978 | **Loi sur les plus-values** (n° 78-688) | Les plus-values boursières deviennent imposables (au-delà d'un seuil) | A |
| 13/07/1978 | **Loi Monory** | Déduction de 5 000 F par an pour l'achat d'actions françaises | A |
| 13/07/1979 | Loi sur les FCP | Essor de la gestion collective | A |
| 05/1981 | Alternance, dévaluations (1981-1983), contrôle des changes renforcé | Krach du « mai 1981 » sur les valeurs à nationaliser | A |
| 1982 | **Impôt sur les grandes fortunes (IGF)** (1982-1986) | — | A |
| 13/02/1982 | **Loi de nationalisation** : 5 groupes industriels (CGE, Saint-Gobain, Pechiney, Rhône-Poulenc, Thomson), 36 banques, Paribas et Suez | Les actionnaires sont **indemnisés en obligations** et les titres sont retirés de la cote | A |
| 1982-1983 | LEP (1982), **Codevi** (1983), **CEA** (1983), **second marché** (1983), emprunt obligatoire (1983), limite de devises pour les touristes (1983) | — | A/B |
| 03/11/1984 | **Dématérialisation des titres** | Fin des titres papier et des coupons | A |
| 1985-1987 | Déréglementation (Bérégovoy) : OAT, MATIF (1986), MONEP (1987), cotation électronique (1986) | — | A |
| 1986 | Lois de privatisation (02/07 et 06/08/1986) ; suppression de l'IGF ; fin de la « devise-titre » | « Capitalisme populaire » | A |
| 10/1987 | **Krach d'octobre 1987** | Privatisation de Suez en cours ; Paribas et Saint-Gobain chutent sous le prix d'offre | A |
| 31/12/1987 | Base 1 000 de l'indice **CAC 40** (publié à partir du 15/06/1988) | Référence de marché | A |
| 22/01/1988 | **Réforme de la bourse** : fin des agents de change, sociétés de bourse | — | A |
| 1989 | **ISF** (seuil initial ≈ 4 MF [B]) ; courtages libres le 01/07/1989 | — | A |
| 01/01/1990 | **Fin du contrôle des changes** | Libre accès aux actions étrangères | A |
| 1990 | PEP ; assurance-vie : seuil de 8 ans pour les nouveaux contrats | — | A |
| 1991 | **CSG** (1,1 %, d'abord sur les revenus d'activité) ; abattements assurance-vie et succession (art. 757 B) | — | A |
| 16/07/1992 | **PEA** | Enveloppe « actions » défiscalisée | A |
| 1993-1997 | Privatisations Balladur puis Juppé (BNP, Rhône-Poulenc, Elf, UAP, Renault…) ; **emprunt Balladur** | — | A |
| 1994 | **Contrats Madelin** | — | A |
| 1996 | **CRDS 0,5 %** ; Nouveau marché ; loi MAF ; Livret jeune | — | A/B |
| 26/09/1997 | Réforme de l'assurance-vie (fin de l'exonération totale pour les nouvelles primes) | 7,5 % après 8 ans au-delà de l'abattement | A |
| 1998 | Prélèvements sociaux à **10 %** | — | A |
| 01/01/1999 | **Euro** (cotations en €) ; 2002 : pièces et billets | Conversion à 6,55957 | A |
| 2000 | Euronext ; SRD remplace le règlement mensuel ; éclatement de la bulle Internet (pic en 03/2000) | — | A |
| 2001 | Premiers **ETF** à Paris | Gestion indicielle bon marché | B |
| 21/08/2003 | **Loi Fillon** : PERP, PERCO ; fermeture du PEP | — | A |
| 01/01/2005 | **Suppression de l'avoir fiscal** → abattement de 50 % puis de 40 % (2006) + crédit d'impôt plafonné | — | A/B |
| 2005 | Loi Fourgous (passage en multisupport sans perdre l'antériorité fiscale) | — | B |
| 01/01/2008 | **Suppression de l'impôt de bourse** ; option PFL de 18 % sur les dividendes | — | A |
| 2008 | Crise financière (Lehman, 09/2008) | — | A |
| 01/01/2009 | **Livret A dans toutes les banques** | — | A |
| 01/01/2011 | **Suppression du seuil de cession** : plus-values imposées dès le 1er euro (19 %) ; seuil de l'ISF relevé à 1,3 M€ | — | A |
| 01/08/2012 | **TTF 0,2 %** ; hausse des plafonds du Livret A et du LDD (10/2012 et 01/2013) | — | A |
| 2013 | **Dividendes et plus-values au barème de l'IR** (fin du PFL), abattements pour durée de détention (50 % de 2 à 8 ans, 65 % au-delà) | Forte hausse de la fiscalité pour les hauts revenus | A |
| 2014 | **PEA-PME** ; PEA à 150 000 € ; Eurocroissance | — | A |
| 2016 | **Loi Sapin 2** (blocage possible de l'assurance-vie) | — | A |
| 01/01/2017 | TTF 0,3 % | — | A |
| 01/01/2018 | **PFU (« flat tax ») 30 %** = 12,8 % IR + 17,2 % PS ; **IFI** remplace l'ISF (seuil 1,3 M€, immobilier seulement) ; PEL sans avantage fiscal | Simplification majeure | A |
| 22/05/2019 | **Loi PACTE** : PER (01/10/2019), PEA jeune, PEA-PME 225 000 €, retraits du PEA après 5 ans | — | A |
| 11/2019 | Privatisation de la **Française des Jeux** | Retour de l'actionnariat populaire | A |
| 2020 | Covid (krach de 03/2020) ; **plafonnement des frais du PEA** (01/07/2020) ; fin de la commercialisation du PERP et du Madelin (01/10/2020) | — | A |
| 2022-2023 | Retour de l'inflation (5-6 %), hausse des taux, Livret A à 3 %, LEP à 6,1 % | — | A |
| 2023 | Loi Industrie verte : Plan d'épargne avenir climat (07/2024) ; PER à gestion pilotée verdie | — | B |
| 2023 | **OPA de l'État sur EDF à 12 €** (contre 32 € en 2005) | Leçon pour les petits porteurs | A |
| 01/04/2025 | **TTF 0,4 %** | — | A |
| 01/01/2026 | **LFSS 2026 : PS à 18,6 %** (CSG +1,4 pt) → **PFU à 31,4 %** ; l'assurance-vie reste à 17,2 % de PS (et l'épargne-logement aussi selon les sources [B]) | — | A/B |

### 3.2 Opérations grand public (marché primaire accessible aux particuliers)

> Rappel pédagogique : **marché primaire** = souscription d'actions nouvelles ou cédées par l'État à prix fixe, souvent avec une décote, des actions gratuites et un traitement préférentiel des petits ordres ; **marché secondaire** = la bourse au quotidien. Dans le jeu, une OPV doit apparaître comme un **événement à fenêtre courte** (1 à 3 semaines) avec un **taux de service** (réduction des ordres en cas de forte demande).

| Date | Opération | Prix grand public | Souscripteurs particuliers | Suite (utile pour scénario) | Certitude |
|---|---|---|---|---|---|
| 11-12/1986 | **Saint-Gobain** (privatisation) | 310 F | ≈ 1,5 million | Hausse, puis krach de 1987 | A (prix), B (souscripteurs) |
| 01/1987 | **Paribas** | ≈ 405 F | ≈ 3,8 millions | Repli sous le prix d'offre après le krach | B |
| 04-06/1987 | CCF, CGE, Havas, **Société Générale**, **TF1** | — | Plusieurs millions au total | — | A (dates) |
| 10/1987 | **Suez** | — | — | **En plein krach** : contre-exemple parfait | A |
| 11-12/1987 | **Eurotunnel** (introduction en bourse) | ≈ 35 F | Très nombreux petits porteurs | Effondrement, restructurations de 1997 et 2007 | B |
| 06-07/1993 | **Emprunt Balladur** 6 % | — | ≈ 1,4 million [C] | Échangeable contre des titres privatisés | B |
| 10/1993 | **BNP** | ≈ 240 F | ≈ 2,8 millions | — | B |
| 11/1993 – 1995 | Rhône-Poulenc, **Elf Aquitaine** (02/1994), UAP, Renault (partielle), Seita, Usinor | — | — | — | A (dates) |
| 20/10/1997 | **France Télécom** (ouverture du capital) | **182 F** (premier cours 215 F) | ≈ 3,9 millions [C] | 401 F en 07/1998, pic ≈ 219 € (03/2000), chute vers ≈ 7 € (09/2002) | A (prix) |
| 07/2005 | **Gaz de France** | ≈ 23 € [C] | — | — | C |
| 21/11/2005 | **EDF** | **32 €** (33 € pour les institutionnels) | ≈ 5 millions | Pic > 80 € (2007), OPA de l'État à 12 € (2023) | A |
| 12/2006 | Natixis | ≈ 19,5 € [C] | ≈ 2,8 millions [C] | Effondrement en 2008 | C |
| 21/11/2019 | **Française des Jeux** | **19,90 €** | ≈ 500 000 | Hausse | A |

### 3.3 Fiscalité des placements financiers : grandes étapes (pour paramétrage)

**Prélèvements sociaux sur les revenus du patrimoine (taux global)** [A depuis 1996] :

| À partir du | Taux global PS |
|---|---|
| < 1991 | 0 % |
| 1991 | ≈ 1,1 % (CSG, d'abord sur les revenus d'activité) [B] |
| 01/02/1996 | 0,5 % (CRDS) + CSG (revenus du patrimoine) ≈ 3,9 % en 1997 |
| 01/01/1998 | 10 % |
| 01/07/2004 | 10,3 % |
| 01/01/2005 | 11 % |
| 01/01/2009 | 12,1 % |
| 01/01/2011 | 12,3 % |
| 01/10/2011 | 13,5 % |
| 01/07/2012 | 15,5 % |
| 01/01/2018 | 17,2 % |
| 01/01/2026 | **18,6 %** (assurance-vie maintenue à 17,2 %) |

**Plus-values mobilières des particuliers (CTO)** :

| Période | Régime | Certitude |
|---|---|---|
| 1950-1978 | En pratique **non imposées** (sauf spéculation habituelle) | B |
| 1978-2010 | Imposées au taux proportionnel **si le total des cessions annuelles dépasse un seuil** (7 650 € en 2002, 15 000 € en 2003, 25 000 € en 2008, 25 830 € en 2010) ; taux 15 % (≈ 1978) → 16 % (années 1990-2000) → 18 % (2008), + PS | A/B |
| 2011 | Suppression du seuil, 19 % + PS | A |
| 2012 | 24 % + PS | B |
| 2013-2017 | **Barème de l'IR** après abattement pour durée de détention (50 % de 2 à 8 ans, 65 % au-delà) + PS | A |
| 2018-2025 | **PFU 30 %** (option barème) | A |
| 2026 → | **PFU 31,4 %** | A/B |

**Dividendes** : barème de l'IR avec **avoir fiscal** (1965-2004, crédit de 50 % du dividende) → abattement de 50 % puis 40 % + crédit d'impôt plafonné (2005-2009) → option PFL de 18 % (2008), 21 % (2012) → barème obligatoire (2013-2017) → **PFU 30 %** (2018) puis 31,4 % (2026). [A/B]

---

## 4. Taux du Livret A et inflation

### 4.1 Taux du Livret A (dates de changement)

> Avant 1966, les sources divergent (certaines donnent 1,5 % en 1946, d'autres une moyenne de 2,75 % en 1950). Retenir **≈ 2,5 %** pour 1950-1959, en certitude **[C]**.

| Date d'effet | Taux | Certitude |
|---|---|---|
| 1950-1959 | ≈ 2,5 % (fourchette 1,5-3 %) | C |
| 01/01/1960 | 3,25 % | B |
| 01/01/1966 | 3,00 % | B |
| 01/01/1968 | 3,50 % | B |
| 01/06/1969 | 4,00 % | B |
| 01/01/1970 | 4,25 % | B |
| 01/01/1974 | 6,00 % | B |
| 01/01/1975 | 7,50 % | B |
| 01/01/1976 | 6,50 % | B |
| ≈ 04/1980 | 7,50 % | B |
| 16/10/1981 | **8,50 %** (record) | A |
| 01/08/1983 | 7,50 % | A |
| 16/08/1984 | 6,50 % | A |
| 01/07/1985 | 6,00 % | A |
| 31/05/1986 | 4,50 % | A |
| 01/03/1996 | 3,50 % | A |
| 16/06/1998 | 3,00 % | A |
| 01/08/1999 | 2,25 % | A |
| 01/07/2000 | 3,00 % | A |
| 01/08/2003 | 2,25 % | A |
| 01/08/2005 | 2,00 % | A |
| 01/02/2006 | 2,25 % | A |
| 01/08/2006 | 2,75 % | A |
| 01/08/2007 | 3,00 % | A |
| 01/02/2008 | 3,50 % | A |
| 01/08/2008 | 4,00 % | A |
| 01/02/2009 | 2,50 % | A |
| 01/05/2009 | 1,75 % | A |
| 01/08/2009 | 1,25 % | A |
| 01/08/2010 | 1,75 % | A |
| 01/02/2011 | 2,00 % | A |
| 01/08/2011 | 2,25 % | A |
| 01/02/2013 | 1,75 % | A |
| 01/08/2013 | 1,25 % | A |
| 01/08/2014 | 1,00 % | A |
| 01/08/2015 | 0,75 % | A |
| 01/02/2020 | **0,50 %** (plancher historique) | A |
| 01/02/2022 | 1,00 % | A |
| 01/08/2022 | 2,00 % | A |
| 01/02/2023 | 3,00 % | A |
| 01/02/2025 | 2,40 % | A |
| 01/08/2025 | 1,70 % | A |
| 01/02/2026 | 1,50 % | A |
| 01/08/2026 | 1,70 % | B (annonce de l'été 2026, à confirmer au JO) |

### 4.2 Plafond du Livret A

| Date | Plafond | Certitude |
|---|---|---|
| avant 1966 | ≈ 1 000 000 AF (10 000 NF) [C] | C |
| 01/01/1966 | 15 000 F | A |
| 09/08/1969 | 20 000 F | A |
| 01/07/1973 | 22 500 F | A |
| 01/01/1974 | 25 000 F | A |
| 01/01/1976 | 32 500 F | A |
| 15/11/1977 | 38 000 F | A |
| 01/09/1978 | 41 000 F | A |
| 1980 | 45 000 F puis 49 000 F | B |
| 02/04/1983 | 58 000 F | A |
| 15/06/1984 | 68 000 F | A |
| 31/05/1986 | 72 000 F | A |
| 30/06/1987 | 80 000 F | A |
| 01/05/1990 | 90 000 F | A |
| 30/10/1991 | 100 000 F | A |
| 01/01/2002 | 15 300 € | A |
| 01/10/2012 | 19 125 € | A |
| 01/01/2013 | **22 950 €** | A |

### 4.3 Taux du LEP (pour mémoire)

| Date | Taux | Date | Taux |
|---|---|---|---|
| 14/01/1983 | 8,50 % | 01/08/2011 | 2,75 % |
| 16/08/1984 | 7,50 % | 01/02/2013 | 2,25 % |
| 01/07/1985 | 7,00 % | 01/08/2013 | 1,50 % |
| 16/05/1986 | 5,50 % | 01/08/2015 | 1,25 % |
| 01/03/1996 | 4,75 % | 01/02/2020 | 1,00 % |
| 01/08/1999 | 4,00 % | 01/02/2022 | 2,20 % |
| 01/07/2000 | 4,25 % | 01/08/2022 | 4,60 % |
| 01/08/2004 | 3,25 % | 01/02/2023 | **6,10 %** |
| 01/08/2005 | 3,00 % | 01/08/2023 | 6,00 % |
| 01/02/2006 | 3,25 % | 01/02/2024 | 5,00 % |
| 01/08/2006 | 3,75 % | 01/08/2024 | 4,00 % |
| 01/08/2007 | 4,00 % | 01/02/2025 | 3,50 % |
| 01/02/2008 | 4,25 % | 01/08/2025 | 2,70 % |
| 01/08/2008 | 4,50 % | 01/02/2026 | 2,50 % |
| 01/02/2009 | 3,00 % | | |
| 01/05/2009 | 2,25 % | | |
| 01/08/2009 | 1,75 % | | |
| 01/08/2010 | 2,25 % | | |
| 01/02/2011 | 2,50 % | | |

### 4.4 Inflation annuelle en France et taux moyen du Livret A (moyennes annuelles)

> Inflation = **hausse moyenne annuelle de l'indice des prix à la consommation** (INSEE). Certitude **[A]** depuis 1986, **[B]** de 1960 à 1985, **[C]** de 1950 à 1959. Certaines sources publient le glissement de décembre à décembre, qui peut différer de 1 à 3 pts les années de forte inflation (1957-1958, 1973-1974). Pour le moteur : **série INSEE de l'IPC en moyenne annuelle** (coefficients de pouvoir d'achat de l'INSEE pour la conversion en euros constants).
> Taux Livret A « moyen » = moyenne pondérée sur l'année des taux du §4.1 (arrondie).

| Année | Inflation | Livret A moyen | Rendement réel du Livret A |
|---|---|---|---|
| 1950 | ≈ 10 % | ≈ 2,5 % | ≈ −7,5 |
| 1951 | ≈ 16 % | ≈ 2,5 % | ≈ −13,5 |
| 1952 | ≈ 12 % | ≈ 2,5 % | ≈ −9,5 |
| 1953 | ≈ −1,5 % | ≈ 2,5 % | ≈ +4 |
| 1954 | ≈ 0,4 % | ≈ 2,5 % | ≈ +2 |
| 1955 | ≈ 1 % | ≈ 2,5 % | ≈ +1,5 |
| 1956 | ≈ 2 % | ≈ 2,5 % | ≈ +0,5 |
| 1957 | ≈ 3 % | ≈ 2,5 % | ≈ −0,5 |
| 1958 | ≈ 15 % | ≈ 2,5 % | ≈ −12,5 |
| 1959 | ≈ 6 % | ≈ 2,5 % | ≈ −3,5 |
| 1960 | 3,6 % | 3,25 % | −0,4 |
| 1961 | 3,3 % | 3,25 % | 0 |
| 1962 | 4,8 % | 3,25 % | −1,5 |
| 1963 | 4,8 % | 3,25 % | −1,5 |
| 1964 | 3,4 % | 3,25 % | −0,2 |
| 1965 | 2,5 % | 3,25 % | +0,7 |
| 1966 | 2,7 % | 3,0 % | +0,3 |
| 1967 | 2,7 % | 3,0 % | +0,3 |
| 1968 | 4,5 % | 3,5 % | −1,0 |
| 1969 | 6,4 % | 3,8 % | −2,6 |
| 1970 | 5,2 % | 4,25 % | −1,0 |
| 1971 | 5,5 % | 4,25 % | −1,3 |
| 1972 | 6,2 % | 4,25 % | −2,0 |
| 1973 | 7,3 % | 4,25 % | −3,0 |
| 1974 | 13,7 % | 6,0 % | −7,7 |
| 1975 | 11,8 % | 7,5 % | −4,3 |
| 1976 | 9,6 % | 6,5 % | −3,1 |
| 1977 | 9,4 % | 6,5 % | −2,9 |
| 1978 | 9,1 % | 6,5 % | −2,6 |
| 1979 | 10,8 % | 6,5 % | −4,3 |
| 1980 | 13,6 % | 7,25 % | −6,4 |
| 1981 | 13,4 % | 7,75 % | −5,7 |
| 1982 | 11,8 % | 8,5 % | −3,3 |
| 1983 | 9,6 % | 8,1 % | −1,5 |
| 1984 | 7,4 % | 7,1 % | −0,3 |
| 1985 | 5,8 % | 6,25 % | +0,5 |
| 1986 | 2,7 % | 5,0 % | +2,3 |
| 1987 | 3,1 % | 4,5 % | +1,4 |
| 1988 | 2,7 % | 4,5 % | +1,8 |
| 1989 | 3,6 % | 4,5 % | +0,9 |
| 1990 | 3,4 % | 4,5 % | +1,1 |
| 1991 | 3,2 % | 4,5 % | +1,3 |
| 1992 | 2,4 % | 4,5 % | +2,1 |
| 1993 | 2,1 % | 4,5 % | +2,4 |
| 1994 | 1,7 % | 4,5 % | +2,8 |
| 1995 | 1,8 % | 4,5 % | +2,7 |
| 1996 | 2,0 % | 3,7 % | +1,7 |
| 1997 | 1,2 % | 3,5 % | +2,3 |
| 1998 | 0,7 % | 3,2 % | +2,5 |
| 1999 | 0,5 % | 2,7 % | +2,2 |
| 2000 | 1,7 % | 2,6 % | +0,9 |
| 2001 | 1,6 % | 3,0 % | +1,4 |
| 2002 | 1,9 % | 3,0 % | +1,1 |
| 2003 | 2,1 % | 2,7 % | +0,6 |
| 2004 | 2,1 % | 2,25 % | +0,15 |
| 2005 | 1,8 % | 2,15 % | +0,35 |
| 2006 | 1,6 % | 2,45 % | +0,85 |
| 2007 | 1,5 % | 2,85 % | +1,35 |
| 2008 | 2,8 % | 3,7 % | +0,9 |
| 2009 | 0,1 % | 1,9 % | +1,8 |
| 2010 | 1,5 % | 1,45 % | 0 |
| 2011 | 2,1 % | 2,1 % | 0 |
| 2012 | 2,0 % | 2,25 % | +0,25 |
| 2013 | 0,9 % | 1,6 % | +0,7 |
| 2014 | 0,5 % | 1,15 % | +0,65 |
| 2015 | 0,0 % | 0,9 % | +0,9 |
| 2016 | 0,2 % | 0,75 % | +0,55 |
| 2017 | 1,0 % | 0,75 % | −0,25 |
| 2018 | 1,8 % | 0,75 % | −1,05 |
| 2019 | 1,1 % | 0,75 % | −0,35 |
| 2020 | 0,5 % | 0,5 % | 0 |
| 2021 | 1,6 % | 0,5 % | −1,1 |
| 2022 | 5,2 % | 1,4 % | −3,8 |
| 2023 | 4,9 % | 2,9 % | −2,0 |
| 2024 | 2,0 % | 3,0 % | +1,0 |
| 2025 | 0,9 % | 2,15 % | +1,25 |
| 2026 | non consolidé (≈ 1-3 %) | ≈ 1,6 % | — |

À retenir pour le gameplay : de 1950 à 1985, le Livret A **perd presque toujours contre l'inflation** (−3 à −13 % de rendement réel certaines années). De 1986 à 2016, il bat l'inflation. En 2021-2023, il redevient perdant. C'est l'une des leçons les plus puissantes du jeu.

---

## 5. Recommandations pour le jeu

### 5.1 Indispensable en V1

1. **Moteur de disponibilité datée** : chaque produit a `date_debut` et `date_fin_commercialisation`, et un produit fermé reste **détenu** s'il a été ouvert avant (PEP, PERP, ancien PEL). Le joueur ne voit jamais un produit anachronique.
2. **Livret A** (taux et plafond datés) : la référence « sans risque » à laquelle tout le reste se compare.
3. **Actions en direct sur CTO** + un **indice de marché** (avant 1988, nommer l'indice « Indice CAC général » ou « Indice de la Bourse de Paris », pas « CAC 40 »).
4. **SICAV génériques** à partir de 1964 (actions, obligataire, monétaire à partir de 1981 environ, monde à partir de 1990), puis **ETF** à partir de 2001.
5. **Assurance-vie fonds euros** (à partir de 1976-1980), avec l'horloge des 8 ans.
6. **PEA** à partir du 16/07/1992, avec l'horloge des 5 ans et un plafond daté.
7. **Inflation et rendement réel** affichés en permanence (« votre pouvoir d'achat »), ainsi que la monnaie de l'époque (AF / F / €).
8. **Frais par époque** (table §2.2) : la chute des frais est en soi une leçon.
9. **Fiscalité simplifiée par époque** (table §5.3), sans barème progressif complet.
10. **Événements datés** : emprunts Pinay et Giscard, loi Monory, nationalisations de 1982 (titres échangés contre des obligations), privatisations de 1986-1987 et 1993, krach de 1987, France Télécom 1997, bulle de 2000, crise de 2008, EDF 2005, flat tax 2018, FDJ 2019, Covid 2020, inflation de 2022.

### 5.2 Ce qui peut être simplifié sans trahir la réalité

| Réalité | Simplification proposée |
|---|---|
| Intérêts du Livret A par quinzaine | Calcul mensuel, crédit au 31/12 |
| Barème de l'IR progressif, quotient familial | Paramètre unique « TMI du joueur » (0 / 11 / 30 / 41 %), modifié par les événements de vie |
| Avoir fiscal, abattements, crédits d'impôt | Taux effectif forfaitaire par époque sur les dividendes |
| Taux historiques de PS par tranche de gains | Taux des PS en vigueur à la date du retrait |
| Seuil de cession 1978-2010 | Seuil fixe (≈ 15 000 € constants) en dessous duquel la plus-value est exonérée |
| Multiples SICAV | 3 ou 4 fonds génériques adossés aux séries de marché |
| Rendement du fonds euros (lissé, propre à chaque assureur) | Taux long glissant sur 8 ans − 0,5 pt, avec plancher 0 % (effet cliquet) |
| Napoléon (prime variable) | Cours de l'or × 5,81 g × (1 + prime aléatoire de 0 à 20 %) |
| Règlement mensuel et SRD | Ignorés en V1 (pas d'effet de levier pour un jeu pédagogique), ou réservés à un mode « expert » |
| PEL (versements obligatoires, prime d'État) | Taux verrouillé + blocage de 4 ans ; prime incluse dans le taux avant 2003 |

Proposition de **table fiscale simplifiée** (taux global appliqué aux gains du CTO, PS compris) :

| Période | Dividendes | Plus-values | Intérêts (obligations, livrets bancaires) |
|---|---|---|---|
| 1950-1964 | 20 % | 0 % | 25 % |
| 1965-1977 | 10 % (avoir fiscal) | 0 % | 25 % |
| 1978-1990 | 10 % | 15 % au-delà du seuil | 25 % |
| 1991-1997 | 15 % | 16 % + PS ≈ 20 % au-delà du seuil | 20 % |
| 1998-2007 | 20 % | 26-27 % au-delà du seuil | 25 % |
| 2008-2012 | 30 % | 29-34 % | 30-35 % |
| 2013-2017 | 35 % (à TMI 30 %) | 30-40 % (après abattements) | 45 % (à TMI 30 %) |
| 2018-2025 | 30 % | 30 % | 30 % |
| 2026 → | 31,4 % | 31,4 % | 31,4 % |

Enveloppes : Livret A, LDD et LEP à 0 % ; PEA à 0 % d'IR après 5 ans (seuls les PS) ; assurance-vie selon l'horloge des 8 ans et la génération du contrat.

Exemple de paramétrage d'un produit (JSON indicatif) :

```json
{
  "id": "pea",
  "label": "Plan d'épargne en actions",
  "date_debut": "1992-07-16",
  "date_fin_commercialisation": null,
  "plafonds": [
    {"depuis": "1992-07-16", "montant": 600000, "devise": "FRF"},
    {"depuis": "2002-01-01", "montant": 120000, "devise": "EUR"},
    {"depuis": "2003-01-01", "montant": 132000, "devise": "EUR"},
    {"depuis": "2014-01-01", "montant": 150000, "devise": "EUR"}
  ],
  "univers": ["actions_ue", "opcvm_eligible_pea", "etf_pea"],
  "horloge_fiscale_ans": 5,
  "regle_retrait": [
    {"depuis": "1992-07-16", "avant_horloge": "cloture_et_impot", "apres_horloge": "exonere_ir_ps_dus"},
    {"depuis": "2019-05-23", "avant_horloge": "cloture_pfu", "apres_horloge": "retrait_partiel_libre"}
  ],
  "certitude": "A"
}
```

### 5.3 Les pièges à éviter (anachronismes et contresens)

1. **« CAC 40 » avant 1988** : l'indice n'existe pas (base au 31/12/1987, publié à partir de juin 1988). Utiliser un indice de la Bourse de Paris reconstitué sous un autre nom.
2. **ETF, courtier en ligne, ordre à 1 €** avant leur date : ETF en 2001, Internet ≈ 1996-1999, néo-courtiers ≈ 2015-2021.
3. **Actions américaines en direct avant 1986-1990** : le contrôle des changes et la devise-titre rendaient l'opération rare et coûteuse. Pour 1950-1985, l'univers est français, avec au mieux une SICAV internationale chère.
4. **PEA avant juillet 1992, PER avant octobre 2019, LDD avant 2007, Livret A dans « sa banque » avant 2009** (il fallait aller à la Caisse d'épargne ou à La Poste).
5. **Oublier l'inflation** : afficher des gains nominaux en 1974 ou en 1981 sans le rendement réel serait un contresens pédagogique majeur.
6. **Les francs** : anciens francs avant 1960 (un salaire de 30 000 AF par mois en 1955, pas 30 000 F) ; francs puis euros en 1999-2002.
7. **Nationalisations de 1982** : les actionnaires n'ont **pas tout perdu**, ils ont été indemnisés en obligations ; les titres disparaissent de la cote. Gérer la sortie de cote proprement.
8. **Privatisations** : ce sont des **OPV à prix fixe**, avec parfois des actions gratuites (1 pour 10 si conservées 18 mois) et des ordres réduits en cas de forte demande ; ce n'est pas un achat en bourse.
9. **Fiscalité 2026** : PFU à 31,4 %, mais l'assurance-vie reste à 30 % (PS à 17,2 %). Ne pas appliquer 18,6 % partout.
10. **Fonds euros = « sans risque »** : vrai pour le capital (sauf blocage Sapin 2), mais pas forcément en termes réels (rendement réel négatif en 2021-2023).
11. **Impôt de bourse et TTF** : l'impôt de bourse touchait achats et ventes jusqu'en 2007 ; la TTF (depuis 2012) ne touche que les **achats** de grandes valeurs **françaises**.
12. **Ne pas présenter de stratégie comme « la bonne »** : le jeu enseigne des mécanismes (diversification, frais, inflation, horizon, fiscalité), il ne donne pas de conseil personnalisé. Prévoir un avertissement pédagogique.
13. **Dates incertaines** : conserver le champ `certitude` dans les données et ne pas bâtir une énigme de quiz sur une donnée de niveau [C].

---

## 6. Sources consultées (sélection)

- Historique du taux et du plafond du Livret A : [ADCF](https://www.adcf.org/taux-livret-a/), [Meilleurtaux, historiques des livrets](https://placement.meilleurtaux.com/livret-epargne/taux-livret.html), [Moneyvox, plafond](https://www.moneyvox.fr/livret-a/plafond.php), [Toutsurmesfinances, taux moyen annuel et inflation depuis 1970](https://www.toutsurmesfinances.com/placements/livret-a-et-livret-bleu-historique-du-taux-moyen-annuel-depuis-1970.html), [Ramify](https://www.ramify.fr/epargne/taux-livret-a), [Nalo, août 2026](https://blog.nalo.fr/taux-livret-a-aout-2026/)
- Inflation : [Inflationtool (France)](https://www.inflationtool.com/rates/france), INSEE (IPC, coefficients de pouvoir d'achat)
- PEL / CEL : [La finance pour tous](https://www.lafinancepourtous.com/pratique/credit/credit-immobilier/le-pret-du-pel-et-du-cel/historique-des-taux-de-rendement-et-de-pret-des-pel-et-des-cel/), [Docteur-factures, PEL 1969-1983](https://www.docteur-factures.fr/historique-taux-pel-1983/), [Banque de France, épargne logement](https://www.banque-france.fr/fr/a-votre-service/particuliers/connaitre-pratiques-bancaires-assurance/epargne/epargne-logement)
- PEA : [Meilleurtaux, plafonds PEA](https://placement.meilleurtaux.com/bourse/pea/plafond-pea.html), [AFG, instruction 2003](https://www.afg.asso.fr/app/uploads/2017/04/PJ1_20030616_1016-1.pdf), [AMF, plafonnement des frais](https://www.amf-france.org/fr/le-mediateur/journal-de-bord-du-mediateur/dossiers-du-mois/plafonnement-des-frais-de-transaction-sur-un-pea-le-canal-de-transmission-dun-ordre-ne-suffit-pas), [Moneyvox, frais PEA 2020](https://www.moneyvox.fr/bourse/actualites/78089/pea-les-frais-de-garde-de-transaction-et-de-transfert-plafonnes-en-juillet-2020)
- Assurance-vie : [Documentissime, contrats depuis 1990](https://www.documentissime.fr/dossiers-droit-pratique/dossier-133-la-fiscalite-des-assurances-sur-la-vie/le-rachat-ou-le-denouement-de-l-assurance-vie/les-contrats-souscrits-apres-le-1er-janvier-1990.html), [IPP, barèmes](https://www.ipp.eu/baremes-ipp/taxation-du-capital/taxation_capital.prelevement_forfaitaire.liberatoire_assurance_vie/table), [Toutsurmesfinances, fonds euros](https://www.toutsurmesfinances.com/placements/assurance-vie-historique-des-taux-de-rendements-des-fonds-en-euros-depuis-2000.html), [Moneyvox, ACPR 2019](https://www.moneyvox.fr/assurance-vie/actualites/81534/les-fonds-euros-ont-rapporte-1,46-en-2019-une-chute-historique), [Lextenso, contrats en UC](https://www.labase-lextenso.fr/ouvrages/t4-les-assurances-de-personnes-9782275051680/section-2-contrats-libelles-en-unites-de-compte-9782275051680-538)
- SICAV / FCP / SCPI : [AFG, historique](https://afg.asso.fr/app/uploads/2017/05/historique-afg-rapport-activite-2020-1.pdf), [Sénat, rapport de 1979](https://www.senat.fr/rap/1978-1979/i1978_1979_0010.pdf), [Centrale des SCPI, histoire](https://www.centraledesscpi.com/guide-des-scpi/histoire-et-legislation)
- Monory / CEA : [Cercle de l'épargne](https://cercledelepargne.com/wp-content/uploads/2018/05/M48-FINANCEMENT-DES-ENTREPRISES.pdf), [Élysée, entretien de V. Giscard d'Estaing, 1981](https://www.elysee.fr/valery-giscard-d-estaing/1981/04/01/interview-de-m-valery-giscard-destaing-dans-le-revenu-francais-sur-la-fiscalite-les-plus-values-limpot-sur-le-capital-et-lepargne-paris-avril-1981)
- Emprunts Pinay / Giscard : [Hérodote, 8 mars 1952](https://www.herodote.net/almanach-ID-3020.php), [Sénat, proposition de résolution 1980](https://www.senat.fr/leg/ppr80-276.html), [Sénat 1983-1984](https://conferenceconsensuslogement.senat.fr/leg/1983-1984/i1983_1984_0219.pdf), [Universalis, chronologie 1988](https://www.universalis.fr/chronologie/1988/35/)
- Bourse, agents de change, impôt de bourse, TTF : [AN, réponse ministérielle sur les courtages de 1989](https://questions.assemblee-nationale.fr/dyn/9/questions/QANR5L9QE13822.pdf), [La finance pour tous, impôt de bourse](https://www.lafinancepourtous.com/2012/01/26/suppression-de-l-impot-de-bourse), [Legifiscal, TTF 0,4 %](https://www.legifiscal.fr/actualites-fiscales/4142-taxe-transactions-financieres-04-1er-avril.html), [France Transactions, étude AMF de 2015](https://www.francetransactions.com/actus/news-bourse/courtiers/Bourse-les-banques-a-reseaux-3-fois-plus-cheres-que-les-courtiers-en-ligne.html)
- Privatisations et opérations : [OpenEdition IGPDE, annexe 16](https://books.openedition.org/igpde/3866?dir=next), [Larousse 1988](https://www.larousse.fr/archives/journaux_annee/1988/104/les_privatisations), [AN, France Télécom](https://questions.assemblee-nationale.fr/dyn/11/questions/QANR5L11QE17974.pdf), [Histel, premier cours de France Télécom](https://www.histelfrance.fr/storage/2025/06/1997.10.20PremiereCotationActionFranceTelecom.pdf), [Tradingsat, EDF](https://www.tradingsat.com/edf-FR0010242511/actualites/edf-la-prise-de-controle-d-edf-une-aubaine-pour-les-minoritaires-1027021.html), [economie.gouv.fr, FDJ](https://www.economie.gouv.fr/node/70737)
- Fiscalité : [Toutsurmesfinances, historique des PS](https://www.toutsurmesfinances.com/placements/taux-historiques-des-prelevements-sociaux-sur-les-produits-de-placement.html), [Actu-Juridique, CSG 2026](https://www.actu-juridique.fr/fiscalite/fiscal-finances/la-csg-en-hausse-sur-les-revenus-du-capital/), [Moneyvox, seuil de cession 2010](https://www.moneyvox.fr/bourse/actualites/14843/le-seuil-de-cession-des-valeurs-mobilieres-fixe-a-25830-euros-pour-2010), [Toutsurmesfinances, ISF/IFI](https://www.toutsurmesfinances.com/patrimoine/a/seuil-de-l-isf-a-partir-de-combien-paye-t-on-l-isf)
- Retraite : [Trésor, fonctionnement du nouveau PER](https://www.tresor.economie.gouv.fr/banque-assurance-finance/les-mesures-de-la-loi-pacte-pour-le-financement-de-l-economie/le-fonctionnement-du-nouveau-per), [Perlib, PERP](https://perlib.fr/articles/retraite/perp-retraite-fonctionnement-transfert-per), [Boursedescredits, PEP](https://www.boursedescredits.com/lexique-definition-plan-epargne-populaire-pep-3357.php)

> Points à reconfirmer avant d'en faire une question de quiz : taux du Livret A avant 1960, inflation de 1950 à 1959, tarifs des agents de change, chiffres de souscripteurs des privatisations, taxe sur l'or avant 2014, dates d'arrivée des néo-courtiers en France, taux d'août 2026.

---

## 7. Réponses au client (périmètre V1 de `00_vision_client.md`)

> Le cadre de la V1 est respecté : **5 à 7 produits par période**, **un taux d'impôt unique par produit et par époque**, **parties de 15 ans**, 1 tour par mois.
> Principe directeur proposé : **tout exprimer en multiples du salaire moyen net de l'année** (`SMN[année]`, table du §7.3). Les montants restent alors justes à n'importe quelle date et le développeur n'a qu'une seule série à maintenir.

### 7.1 Question 1 : quels produits pour chaque période ?

Règle commune : un produit apparaît **à sa date réelle de création**, avec une notification « Nouveau ! ». Les privatisations et les emprunts d'État ne sont pas des produits permanents mais des **événements de souscription** (fenêtre de 2 à 3 semaines, prix fixe).

**Période « Les années fric » (1978-1995)**

| # | Produit | Disponible | Date réelle | Remarque de jeu |
|---|---|---|---|---|
| 1 | Compte courant | dès le départ | — | **Non rémunéré** : la rémunération des comptes courants est interdite en France jusqu'en 2005 [A]. Tonton Matelas n'est pas loin. |
| 2 | Livret A | dès le départ | 1818 | Caisse d'épargne ou La Poste seulement ; taux de 6,5 % à 8,5 %, mais inflation de 9 à 14 % jusqu'en 1984 |
| 3 | Emprunt d'État (obligation à taux fixe) | dès le départ | — | Coupon = taux long de l'année d'émission (≈ 10 % en 1978, **≈ 16 % en 1981**, ≈ 9 % en 1987, ≈ 6 % en 1993) [B]. Leçon : un taux fixe élevé acheté au bon moment devient un trésor quand les taux baissent. |
| 4 | SICAV actions France | dès le départ | 1964 | **Bonus Monory 1978-1981** (pop-up « Nouvelle loi »). La SICAV sert aussi d'« indice » pour Cousin Indice. |
| 5 | 3 à 5 actions françaises (compte-titres) | dès le départ | — | Liste à fixer avec le boursier ; prévoir la **nationalisation de 1982** (titre retiré et échangé contre une obligation). Privatisations 1986-1987 (Saint-Gobain, Paribas, Suez, TF1…) en OPV. |
| 6 | Codevi | 1983 | 1983 | Optionnel : clone du Livret A avec un second plafond |
| 7 | **PEA** | **16/07/1992** | 1992 | Le grand déblocage de fin de période |

**Période « De l'euphorie à la crise » (1995-2012)**

| # | Produit | Disponible | Date réelle | Remarque de jeu |
|---|---|---|---|---|
| 1 | Compte courant | dès le départ | — | Rémunération autorisée à partir de 2005 mais rare : à garder à 0 % |
| 2 | Livret A | dès le départ | — | 4,5 % en 1995, puis entre 1,25 et 4 % ; accessible dans toutes les banques à partir de 2009 |
| 3 | PEA | dès le départ | 1992 | Horloge de 5 ans ; plafond de 600 000 F, puis 120 000, 132 000 et 150 000 € |
| 4 | OAT (obligation d'État 10 ans) | dès le départ | 1985 | Coupon ≈ 7 % (1995), ≈ 5 % (2000), ≈ 3,5 % (2010) [B] |
| 5 | Fonds actions France (SICAV/FCP) | dès le départ | 1964 | Frais d'entrée de 3 % et frais de gestion de 2 % par an : le contre-exemple de l'ETF |
| 6 | 3 à 5 actions françaises | dès le départ | — | France Télécom en OPV (10/1997, 182 F) ; EDF (11/2005, 32 €) |
| 7 | **ETF CAC 40** | **01/2001** | 2001 | Éligible au PEA ; frais ≈ 0,25 % par an |

**Période « L'ère des ETF » (2008-aujourd'hui)**

| # | Produit | Disponible | Remarque de jeu |
|---|---|---|---|
| 1 | Compte courant | dès le départ | 0 % |
| 2 | Livret A | dès le départ | 4 % (08/2008), puis 0,5 % (2020-2021), puis 3 % (2023) |
| 3 | LEP | dès le départ, **si revenus modestes** | 6,1 % en 2023 : jackpot réservé au jeune salarié, qui apprend à « vérifier ses droits » |
| 4 | PEA | dès le départ | Plafond de 150 000 € depuis 2014 ; réforme PACTE de 2019 |
| 5 | ETF CAC 40 (dans le PEA) | dès le départ | Le produit-vedette de la période |
| 6 | 3 à 5 actions françaises | dès le départ | FDJ en OPV (11/2019, 19,90 €) ; EDF retirée de la cote à 12 € (2023) |
| 7 | OAT ou fonds obligataire | dès le départ | Coupon ≈ 3,5 % (2008), ≈ 0 % (2016-2021), ≈ 3 % (2023) : pédagogie de la hausse des taux de 2022 |

**Si le boursier ajoute une période « Trente Glorieuses » (1950-1977)** : compte courant (ou CCP, voire pas de compte bancaire avant les années 1960), Livret A, **Rente Pinay 1952** (événement), actions françaises en direct, SICAV à partir de 1964, PEL en 1969 (optionnel). Si une seule exception à la liste V2 était autorisée, ce serait **le Napoléon** : c'était *le* placement des familles de cette époque.

> **Assurance-vie** : le client la range en V2. C'est pourtant le premier placement des Français depuis les années 1990. Je conseille de la garder en tête de liste pour la V2, avec un fonds euros simple.

### 7.2 Question 2 : taux du Livret A et inflation année par année

La série complète figure au **§4.4** (inflation, Livret A moyen et rendement réel de 1950 à 2026), avec les dates exactes de changement au §4.1 et les plafonds au §4.2. Mode d'emploi proposé :

- **Tata Livret** : chaque mois, elle verse son épargne disponible ; au 31/12, elle reçoit `solde_moyen_de_l'année × taux_moyen[année]` (intérêts une fois par an, comme le souhaite le client). Fiscalité : 0 %. **Respecter le plafond** : au-delà, l'excédent reste sur son compte courant, ce qui est le vrai comportement des épargnants prudents. Cela compte surtout pour l'héritier.
- **Euros constants** : `IPC[a] = IPC[a-1] × (1 + inflation[a])`, avec `IPC[2025] = 100`. Valeur en euros d'aujourd'hui = `montant_en_€ × IPC[2025] / IPC[année]`, après conversion des francs (`F / 6,55957`, et `AF / 655,957`).
- **À montrer au joueur** : de 1950 à 1985, le Livret A perd en général 2 à 13 % de pouvoir d'achat par an ; Tata Livret perd donc contre l'inflation sur la période « années fric » jusque vers 1985, puis gagne. C'est une scène pédagogique gratuite.

### 7.3 Question 3 : salaires et dépenses types des 3 profils

**Salaires nets mensuels typiques (monnaie de l'époque)**

Sources : SMIG créé en 1950 et devenu SMIC en 1970 [A] ; salaires moyens nets INSEE (environ 26 000 AF par mois en 1951, 49 000 AF en 1958, 845 F en 1964, 3 140 F en 1977, 6 250 F en 1983, 8 780 F en 1990) [B] ; au-delà de 2000, séries INSEE du secteur privé [B]. Les profils sont **mes calibrages** [C], pensés pour le jeu :
- jeune salarié ≈ 1,1 × SMIC ;
- cadre ≈ 2,5 × SMN dans les années 1950-1960, ramené à ≈ 1,7 × SMN de nos jours (les cadres étaient plus rares et l'écart plus fort autrefois) ;
- héritier ≈ 0,9 × SMN, plus un capital de départ d'environ 18 mois de SMN.

| Année | SMIG/SMIC net | **SMN** (salaire moyen net) | Jeune salarié | Cadre pressée | Héritier : salaire | Héritier : capital de départ |
|---|---|---|---|---|---|---|
| 1950 | ≈ 12 000 AF | ≈ 22 000 AF | 14 000 AF | 55 000 AF | 20 000 AF | ≈ 400 000 AF |
| 1955 | ≈ 17 000 AF | ≈ 37 000 AF | 19 000 AF | 90 000 AF | 33 000 AF | ≈ 650 000 AF |
| 1960 | ≈ 280 NF | ≈ 650 NF | 330 NF | 1 600 NF | 600 NF | ≈ 12 000 NF |
| 1965 | ≈ 380 F | ≈ 900 F | 430 F | 2 200 F | 800 F | ≈ 16 000 F |
| 1970 | ≈ 550 F | ≈ 1 400 F | 650 F | 3 300 F | 1 250 F | ≈ 25 000 F |
| 1975 | ≈ 1 150 F | ≈ 2 500 F | 1 300 F | 5 700 F | 2 250 F | ≈ 45 000 F |
| 1980 | ≈ 1 900 F | ≈ 4 300 F | 2 200 F | 9 500 F | 3 900 F | ≈ 80 000 F |
| 1985 | ≈ 3 600 F | ≈ 7 200 F | 4 000 F | 15 000 F | 6 500 F | ≈ 130 000 F |
| 1990 | ≈ 4 300 F | ≈ 8 800 F | 4 800 F | 17 000 F | 8 000 F | ≈ 160 000 F |
| 1995 | ≈ 4 950 F | ≈ 10 000 F | 5 500 F | 19 000 F | 9 000 F | ≈ 180 000 F |
| 2000 | ≈ 850 € (5 600 F) | ≈ 1 700 € | 950 € | 3 200 € | 1 550 € | ≈ 30 000 € |
| 2005 | ≈ 960 € | ≈ 1 900 € | 1 050 € | 3 500 € | 1 700 € | ≈ 34 000 € |
| 2010 | ≈ 1 060 € | ≈ 2 080 € | 1 150 € | 3 800 € | 1 900 € | ≈ 37 000 € |
| 2015 | ≈ 1 140 € | ≈ 2 250 € | 1 250 € | 4 000 € | 2 000 € | ≈ 40 000 € |
| 2020 | ≈ 1 220 € | ≈ 2 500 € | 1 350 € | 4 300 € | 2 250 € | ≈ 45 000 € |
| 2025 | ≈ 1 430 € | ≈ 2 750 € | 1 550 € | 4 700 € | 2 500 € | ≈ 50 000 € |

- **Évolution du salaire en cours de partie** : indexer chaque année sur `SMN[a]/SMN[a-1]` (la hausse moyenne des salaires, qui dépasse l'inflation pendant les Trente Glorieuses et la suit à peu près depuis 1985). On y ajoute les événements « augmentation » et « promotion ». Entre deux lignes du tableau, interpoler géométriquement.
- **Capital de l'héritier** : moitié sur le compte courant ou le livret, moitié en « actions de grand-père », 2 lignes d'actions anciennes. Cela crée un premier dilemme : garder ou vendre ?

**Dépenses fixes (en % du salaire net du personnage)** [C, calées sur les coefficients budgétaires de l'INSEE : alimentation ≈ 38 % en 1960, 30 % en 1975, 27 % en 1990 ; logement ≈ 16 % en 1960, 20 % en 1975]

| Décennie | Loyer | Courses | Transport | Autres fixes (énergie, habillement, assurances, loisirs) | Épargne possible (jeune / cadre / héritier) |
|---|---|---|---|---|---|
| 1950-1959 | 8 % (loyers bloqués par la loi de 1948) | 40 % | 5 % (vélo, transports en commun) | 37 % | 8 / 15 / 10 % |
| 1960-1969 | 11 % | 35 % | 9 % | 35 % | 8 / 15 / 10 % |
| 1970-1979 | 14 % | 28 % | 13 % | 33 % | 10 / 18 / 12 % |
| 1980-1989 | 17 % | 22 % | 14 % | 35 % | 8 / 15 / 12 % |
| 1990-1999 | 20 % | 18 % | 14 % | 34 % | 8 / 15 / 12 % |
| 2000-2009 | 23 % | 16 % | 14 % | 33 % | 8 / 15 / 12 % |
| 2010-2026 | 26 % | 15 % | 13 % | 32 % | 6 / 15 / 12 % |

Ajustements par profil : **cadre pressée** = loyer + 5 pts (grande ville), services + 5 pts (restaurants, garde d'enfants) ; **jeune salarié** = loyer + 3 pts (studio). La colonne « épargne possible » est **ce qui reste en moyenne** : elle est cohérente avec le taux d'épargne des ménages (≈ 10-12 % dans les années 1950, ≈ 18-20 % dans les années 1970, ≈ 11 % vers 1987, ≈ 15 % depuis 1995) [B].

**Repères de prix pour « ressentir » l'inflation** [C, à titre d'ambiance] :

| Année | Petite voiture neuve | ≈ en mois de SMN | Litre de super |
|---|---|---|---|
| 1955 | 2CV ≈ 350 000 AF | ≈ 10 | ≈ 60 AF |
| 1962 | 4L ≈ 5 000 NF | ≈ 7 | ≈ 0,95 NF |
| 1972 | R5 ≈ 10 000 F | ≈ 6 | ≈ 1,15 F |
| 1980 | R5 ≈ 32 000 F | ≈ 7,5 | ≈ 3,40 F |
| 1990 | Clio ≈ 60 000 F | ≈ 7 | ≈ 5,40 F |
| 2000 | Clio ≈ 11 000 € | ≈ 6,5 | ≈ 1,10 € |
| 2010 | Clio ≈ 14 000 € | ≈ 6,5 | ≈ 1,35 € |
| 2020 | Clio ≈ 16 000 € | ≈ 6,5 | ≈ 1,35 € |
| 2025 | Clio ≈ 19 000 € | ≈ 7 | ≈ 1,75 € |

Taux d'équipement automobile des ménages : ≈ 20 % en 1953, ≈ 30 % en 1960, ≈ 58 % en 1970, ≈ 70 % en 1980, ≈ 80 % en 2000 [B]. Dans les années 1950, l'événement « accident de voiture » doit donc devenir « vélomoteur volé » ou « réparation du vélo ».

### 7.3 bis Prix de la baguette (unité de pouvoir d'achat demandée par le designer UX)

Sources : série INSEE du **prix au kilo** publiée par la base Fourastié-Sauvy (« pain usuel » jusqu'en 1960, **baguette à partir de 1961**), convertie ici en **baguette de 250 g** (prix au kg ÷ 4) ; UFC-Que Choisir pour 2023-2024. Avant 1961, l'INSEE ne suit pas la baguette : on estime son prix à environ 2 fois le prix au kg du pain usuel divisé par 4, car la baguette coûtait ≈ 2,4 fois plus au kilo que le pain courant lors du changement de série en 1961.
Conversions : **100 AF = 1 NF** (01/01/1960) ; **1 € = 6,55957 F** (1999/2002). Le prix du pain était **taxé (réglementé) jusqu'à la libération des prix de 1978** [B] : la série évolue donc par paliers avant cette date.

| Année | Prix de la baguette (monnaie de l'époque) | Équivalent en € courants | Baguettes par mois de SMIC net | Certitude |
|---|---|---|---|---|
| 1950 | ≈ 20 AF | 0,03 € | ≈ 600 | C |
| 1955 | ≈ 30 AF | 0,05 € | ≈ 570 | C |
| 1960 | ≈ 0,35 NF (35 AF) | 0,05 € | ≈ 800 | C |
| 1961 | 0,38 NF | 0,06 € | — | B (premier relevé de la baguette) |
| 1965 | 0,43 F | 0,07 € | ≈ 880 | B |
| 1970 | 0,57 F | 0,09 € | ≈ 960 | B |
| 1975 | 0,90 F | 0,14 € | ≈ 1 280 | B |
| 1980 | 1,67 F | 0,25 € | ≈ 1 140 | B |
| 1985 | 2,60 F | 0,40 € | ≈ 1 380 | B |
| 1990 | 3,14 F | 0,48 € | ≈ 1 370 | B |
| 1995 | 3,84 F | 0,59 € | ≈ 1 290 | B |
| 2000 | 4,19 F | 0,64 € | ≈ 1 330 | A/B |
| 2002 | 0,68 € (4,46 F) | 0,68 € | — | A/B (bascule en euros) |
| 2005 | 0,75 € | 0,75 € | ≈ 1 280 | B |
| 2010 | 0,84 € | 0,84 € | ≈ 1 260 | B |
| 2015 | 0,86 € | 0,86 € | ≈ 1 330 | B |
| 2020 | 0,88 € | 0,88 € | ≈ 1 390 | B |
| 2023 | 1,06 € | 1,06 € | ≈ 1 280 | B |
| 2025 | ≈ 1,05 € | 1,05 € | ≈ 1 360 | C |
| 2026 | ≈ 1,10 € | 1,10 € | ≈ 1 330 | C |

Conseils pour l'UX :
1. Interpoler linéairement entre les points pour obtenir une valeur mensuelle.
2. La colonne « baguettes par mois de SMIC » montre que le pouvoir d'achat a été multiplié par plus de 2 entre 1950 et 1985, puis qu'il plafonne. C'est un excellent écran de bilan.
3. Mise en garde : la baguette est un indicateur **imparfait** de l'inflation (prix administré jusqu'en 1978, poids du blé et de l'énergie). Le calcul officiel en euros constants doit utiliser l'IPC (§4.4) et la baguette doit rester une unité d'**affichage**.

### 7.4 Question 4 : une fiscalité ultra simplifiée mais juste

Règle : **un taux unique, prélevé au moment où le gain est encaissé** (dividende versé, coupon versé, plus-value à la vente, intérêts du livret au 31/12). Pas de déclaration de revenus.

| Période | Compte courant | Livret A / LEP / Codevi | Compte-titres : actions, SICAV, ETF, obligations (dividendes, coupons, plus-values) | PEA (vente après 5 ans) | PEA (vente avant 5 ans) |
|---|---|---|---|---|---|
| 1950-1977 | 0 % | 0 % | **15 %** sur dividendes et coupons, **0 %** sur plus-values | — | — |
| 1978-1991 | 0 % | 0 % | **16 %** | — | — |
| 1992-1997 | 0 % | 0 % | 16 % | **0 %** | 16 % et clôture |
| 1998-2007 | 0 % | 0 % | **26 %** | **11 %** (prélèvements sociaux seuls) | 26 % et clôture |
| 2008-2012 | 0 % | 0 % | **30 %** | **13 %** | 30 % et clôture |
| 2013-2017 | 0 % | 0 % | **35 %** | **15,5 %** | 35 % et clôture |
| 2018-2025 | 0 % | 0 % | **30 %** (flat tax) | **17,2 %** | 30 % (et clôture avant 2019) |
| 2026 → | 0 % | 0 % | **31,4 %** | **18,6 %** | 31,4 % |

Pourquoi c'est juste sur le fond :
- Livret A : **toujours 0 %**. C'est vrai, et c'est sa seule arme.
- Avant 1978, les plus-values boursières d'un particulier n'étaient pas imposées [B].
- **1978-1999** : honnêtement, un petit porteur cédant moins que le seuil annuel (≈ 50 000 à 340 000 F selon les années) ne payait pas d'impôt sur ses plus-values. Le taux de 16 % appliqué à tout le monde est une **simplification assumée**, pour que l'avantage du PEA reste visible dès 1992. Si le client préfère la fidélité stricte, prévoir l'option « plus-values exonérées en dessous de N fois le SMN de cessions annuelles ».
- **Écran de vente pédagogique** : afficher à chaque vente d'un PEA de plus de 5 ans « Impôt payé : X. Sur un compte-titres, vous auriez payé : Y ». C'est la façon la plus simple de montrer l'intérêt de l'enveloppe.
- Les dividendes versés **dans** le PEA ne sont pas taxés tant qu'ils restent dans le plan. Dans le jeu, ils sont simplement réinvestis ou laissés en liquidités dans le PEA.

### 7.5 Question 5 : présenter les frais simplement

Trois frais seulement, toujours affichés dans la fenêtre d'achat, plus un compteur cumulé sur l'écran de patrimoine :

| Frais | Quand | 1950-1988 | 1989-1999 | 2000-2012 | 2013-2026 |
|---|---|---|---|---|---|
| **Courtage** (actions, ETF, obligations) | à chaque achat ou vente | 1,3 % (impôt de bourse compris) | 1,3 % | 0,8 % (en ligne, avec l'impôt de bourse jusqu'en 2007) | 0,5 % (banque) ou 1 € fixe (néo-courtier à partir de 2019) |
| **Droits de garde** (compte-titres, PEA) | 1 fois par an | 0,3 % | 0,25 % | 0,2 % | 0 % (en ligne) |
| **Frais des fonds** (SICAV, fonds, ETF) | entrée + chaque année (prélevés sur la performance) | entrée 3 %, gestion 1,5 % par an | entrée 3 %, gestion 2 % par an | idem ; ETF : 0 % d'entrée et 0,3 % par an | idem ; ETF : 0,2 % par an |

Ajouter **TTF 0,2 %, 0,3 % puis 0,4 %** sur les achats d'actions françaises à partir du 01/08/2012 (le plus simple est de l'inclure dans le courtage affiché).

Mise en scène conseillée :
1. **Le compteur « Frais payés depuis le début : X baguettes »**, visible en permanence.
2. **Le « jumeau sans frais »** au bilan : « Avec les mêmes choix mais sans frais, vous auriez Y de plus. »
3. **L'exemple qui frappe** (bulle « C'est quoi ? ») : 10 000 € placés 15 ans à 6 % brut donnent ≈ **23 970 €** avec 0 % de frais, ≈ **20 790 €** avec 1 % par an et ≈ **18 010 €** avec 2 % par an. Le fonds à 2 % de frais coûte donc un quart du résultat.
4. Le **minimum de courtage** n'a pas besoin d'être modélisé en V1, mais une ligne « Acheter 1 action à 50 F avec un courtage minimum de 30 F, c'est 60 % de frais » ferait un bon événement de tutoriel.

### 7.6 Question 6 : événements de vie, découvert et petit crédit

**Événements de vie (coûts en mois de salaire net du personnage, notés M, sauf mention contraire)**. Les montants d'exemple sont donnés pour le jeune salarié [C].

| # | Événement | Type | Effet financier | Exemple 1960 | Exemple 1985 | Exemple 2020 | Fréquence par an | Disponibilité, remarque |
|---|---|---|---|---|---|---|---|---|
| 1 | Accident ou panne de voiture | − | −0,6 à −1,2 M | (vélomoteur) 100 NF | 3 000 F | 1 500 € | 15 % | Seulement si le personnage a une voiture ; avant 1965 environ, version deux-roues à −0,3 M |
| 2 | Panne de chaudière ou d'électroménager | − | −0,3 à −0,8 M (**−1,5 M dans les années 1950-1960** : un réfrigérateur coûtait alors ≈ 1 à 2 mois de salaire) | réfrigérateur 500 NF | lave-linge 2 500 F | chaudière 900 € | 15 % | Toujours |
| 3 | Perte d'emploi | − | Salaire remplacé à **≈ 65 %** pendant 6 à 12 mois (avant 1959, **≈ 20 %**, car l'assurance chômage UNEDIC n'existe qu'à partir de 1958-1959) [A/B] | — | — | — | 1 % (1950-1974), 4 % (1975-1996), 4 % (1997-2026) | Le chômage de masse commence après 1974 : cohérent avec l'histoire |
| 4 | Frais médicaux ou dentaires | − | −0,2 à −0,6 M | 60 NF | 1 500 F | 400 € | 10 % | Sécurité sociale depuis 1945 ; reste à charge plus faible depuis la généralisation des mutuelles |
| 5 | Divorce ou séparation | − | −3 à −6 M ponctuels, puis loyer +30 % | — | 20 000 F | 6 000 € | 2 % (avant 1975), 4 % (après la loi de 1975 sur le divorce par consentement mutuel) | Le seul événement « lourd » |
| 6 | « Le beau-frère et ses escargots » (placement miracle) | piège | Proposition : investir 1 à 6 M ; 90 % de probabilité de tout perdre | 1 000 NF | 20 000 F | 5 000 € | 5 % | Toujours, avec un habillage d'époque : pyramide de Ponzi, timbres, forex, crypto |
| 7 | Prime exceptionnelle ou 13e mois | + | +0,5 à +1 M | 300 NF | 3 500 F | 1 300 € | 30 % | Toujours |
| 8 | Augmentation ou promotion | + | Salaire +5 à +12 % définitivement | — | — | — | 15 % | Plus fréquent pour la cadre |
| 9 | Héritage de la grand-tante | + | +6 à +24 SMN | 8 000 NF | 80 000 F | 40 000 € | 3 % | Toujours ; possibilité de recevoir des titres plutôt que de l'argent (rente Pinay ou Napoléons dans les années 1950-1970) |
| 10 | Gain au jeu | + | Petit gain +0,1 à +0,5 M (fréquent) ; gros lot +5 à +50 SMN (très rare : 0,1 %) | — | — | — | 5 % | **Tiercé PMU à partir de 1954**, **Loto à partir de 1976**, Euromillions à partir de 2004 [A] |
| 11 | Naissance d'un enfant | vie | Dépenses +12 % par enfant, moins les allocations familiales (≈ +4 % de salaire dans les années 1950, ≈ +2 % aujourd'hui, par enfant à partir du 2e) | — | — | — | 8 % (25-40 ans) | Les allocations familiales étaient très généreuses dans les années 1950 [B] |
| 12 | Mariage | vie | −1 à −2 M (la fête), puis dépenses communes −10 % | — | — | — | 6 % | Optionnel : second salaire du conjoint |
| 13 | Déménagement | vie | −0,5 M + dépôt de garantie de 1 à 2 loyers ; loyer ±15 % | — | — | — | 8 % | Toujours |

Réglage proposé : **1 à 3 événements par an**, avec au plus un événement négatif « lourd » (perte d'emploi ou divorce) tous les 5 ans. Le jeu doit pouvoir provoquer volontairement la coïncidence « panne de voiture pendant le krach » une fois par partie : c'est la leçon de l'épargne de précaution.

**Découvert et petit crédit (simplifiés)** :

| Paramètre | 1950-1972 | 1973-1990 | 1991-2008 | 2009-2026 | Certitude |
|---|---|---|---|---|---|
| Découvert toléré | 0,5 M (beaucoup de ménages n'ont pas de compte bancaire avant la fin des années 1960) | 1 M | 1 M | 1 M | C |
| Taux du découvert (agios, par an) | 10 % | 20 % | 15 % | 16 % | C |
| Crédit à la consommation (12 à 36 mois) | 12 % (Cetelem 1953, Sofinco 1951 : achats à tempérament) | 18 % | 10 % | 5 % (2009-2021), 8 % (2022+) | C |

Mécanique conseillée :
1. Si le compte courant passe en négatif, les **agios** sont prélevés chaque mois (`solde × taux / 12`).
2. Au-delà du découvert toléré, le jeu propose **3 choix** : vendre un placement (au prix du jour, même en plein krach), souscrire un **petit crédit** (montant ≤ 6 M, mensualité à taux fixe calculée par la formule classique, et refusé si la mensualité dépasse 33 % du salaire, ce qui reflète la règle d'endettement des banques), ou rester dans le rouge.
3. **Faillite** (fin humoristique) : 3 mois consécutifs au-delà du découvert toléré, sans crédit possible.
4. Leçon automatique au bilan : « Vous avez payé X d'agios, soit Y baguettes. Une épargne de précaution de 3 mois de salaire sur le Livret A vous les aurait évités. »

Sources complémentaires de la §7 : [Fourastié-Sauvy, prix du pain usuel et de la baguette (INSEE)](https://stats.fourastie-sauvy.org/include/php/prd2pdf.php?prd=1391), [75secondes, prix de la baguette 1900-2024](https://www.75secondes.fr/actualites/prix-de-la-baguette-de-pain-de-1900-a-aujourdhui), [INSEE, séries longues des salaires du secteur privé](https://www.insee.fr/fr/statistiques/8660332), [Inégalités.fr, salaire minimum et salaire moyen](https://www.inegalites.fr/Salaire-minimum-et-salaire-moyen-un-ecart-stable-depuis-35-ans), [Annexe historique du rapport SMIC 2020](https://halshs.archives-ouvertes.fr/halshs-03242225v1/file/Gauti%C3%A9_Annexe%20historique%20rapport%20SMIC%202020.pdf), [economie.gouv.fr, cinquante ans de consommation](https://www.economie.gouv.fr/node/27009), [Legisocial, SMIC 2020](https://www.legisocial.fr/reperes-sociaux/montant-smic-2020-taux-horaire-net-brut.html).
