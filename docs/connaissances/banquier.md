# Base de connaissances : le banquier

> À lire au début de chaque mission et à mettre à jour à la fin. C'est une synthèse opérationnelle : pour le détail, voir `docs/01_enveloppes_france.md` (« 01 §x »).
> Ordre de priorité des sources : `docs/sources/` (documents de l'utilisateur) > `03_cahier_des_charges.md` (référence produit) > 01 et 02 > recherche web.
> Certitude : **A** vérifié (texte officiel ou plusieurs sources), **B** probable (une source fiable, ±1 an), **C** reconstitué (ordre de grandeur).
> Dernière mise à jour : 2026-10-27.

---

## 1. Décisions du client qui s'imposent à moi

### 1.1 Cadre général

| Sujet | Décision (03) | Réf. |
|---|---|---|
| Périodes V1 | P1 « Les années fric » 01/1978 → 12/1992 ; P2 « De l'euphorie à la crise » 01/1996 → 12/2010 ; P3 « L'ère des ETF » 01/2011 → 12/2025. 180 mois chacune. | A7, A10 |
| Hors V1 | Trente Glorieuses (1950-1977), année libre. Mes propositions de périodes de 01 §7.1 (1978-1995, 1995-2012, 2008-…) sont **caduques**. | A3, A9 |
| Temps | 1 tour = 1 mois ; ordre unique « au cours du mois » ; cours déterministes. | A11, A12 |
| Monnaie | En interne : euros courants. Affichage F jusqu'à 12/1998, double affichage 1999-2001, € dès 01/2002 (modale euro en P2). | 03 §2.5 |
| Unité de pouvoir d'achat | La baguette (01 §7.3 bis) en jeu ; € d'aujourd'hui (IPC 01 §4.4, base 2025 = 100) **au bilan seulement**. | A4 |
| Technique | Le moteur est désormais Godot 4.7.2 (CLAUDE.md). Les contraintes HTML/JS de 03 §2 visent la V1 web archivée ; les règles métier de 03 restent valables. | CLAUDE.md |

### 1.2 Produits par période (liste exacte de 03 §4)

| Produit | P1 (1978-1992) | P2 (1996-2010) | P3 (2011-2025) | Règle V1 (03 §7.3) |
|---|---|---|---|---|
| Compte courant | départ | départ | départ | 0 % (rémunération interdite jusqu'en 2005) |
| Livret A | départ | départ | départ | Taux daté 01 §4.1, plafond daté 01 §4.2 (dépôt excédentaire refusé), intérêts mensuels crédités au 31/12, 0 % d'impôt |
| Emprunt d'État 10 ans | départ | OAT, départ | OAT, départ | Tranche au taux long de l'année d'achat (02 §4.2, plancher 0 %), coupon annuel taxé, **revente au nominal à tout moment**, sans frais |
| SICAV actions France | départ (PEA dès 07/1992) | départ | — | Suit l'indice + dividende − 1,5 %/an ; **entrée 2 %**, vente sans frais |
| ETF CAC 40 | — | **01/2001** | départ | Gestion 0,25 %/an, courtage actions, **pas de TTF** |
| Actions | Elf Aquitaine, L'Oréal, Peugeot ; **Saint-Gobain 12/1986 à 310 F** | L'Oréal, Total, Alcatel ; **France Télécom 10/1997 à 27,75 € (182 F)** | LVMH, TotalEnergies, BNP Paribas, Orange | 4 par période ; pas de nationalisation, pas de division de nominal |
| PEA (enveloppe) | **07/1992**, 600 000 F | départ, plafonds datés | départ, 150 000 € dès 2014 | Horloge au 1er versement, pas de clôture en V1 |

Notifications « contexte » à fournir : Monory 07/1978 (simple « Le saviez-vous ? », **sans effet fiscal**), CAC 40 06/1988, PEA 07/1992, euro 01/1999 et 01/2002, ETF 01/2001, Livret A 0,75 % (08/2015) et 0,5 % (02/2020), flat tax 01/2018.

### 1.3 Fiscalité V1 (A6 : ma table 01 §7.4 retenue telle quelle)

| Période | Livret A | Compte-titres (dividendes, coupons, plus-values) | PEA vente après 5 ans | PEA vente avant 5 ans |
|---|---|---|---|---|
| 1978-1991 | 0 % | 16 % | — | — |
| 1992-1997 | 0 % | 16 % | 0 % | 16 % |
| 1998-2007 | 0 % | 26 % | 11 % | 26 % |
| 2008-2012 | 0 % | 30 % | 13 % | 30 % |
| 2013-2017 | 0 % | 35 % | 15,5 % | 35 % |
| 2018-2025 | 0 % | 30 % | 17,2 % | 30 % |

Règles d'application (03 §7.4) : taux prélevé à l'encaissement ; plus-value = vente nette de frais − PRU pondéré frais inclus ; moins-value non reportée ; dividendes versés en mai, **0 % dans le PEA** ; valorisation au bilan **brute** (A17). La bulle (?) doit dire : « Simplifié : à l'époque, les petites ventes étaient souvent exonérées. » Test de référence CA-15 : CTO 1995 = 16 %, PEA > 5 ans en 2018 = 17,2 %.

### 1.4 Frais V1 (03 §7.5, une seule formule `max(minimum, taux × montant)`)

| Période | Taux (impôt de bourse inclus) | Minimum | TTF (achats d'actions, pas les ETF) |
|---|---|---|---|
| 1978-1999 | 1,3 % | 50 F (7,62 €) | — |
| 2000-2007 | 0,8 % | 10 € | — |
| 2008-2018 | 0,5 % | 5 € | 0,2 % dès 01/08/2012 ; 0,3 % dès 01/01/2017 |
| 2019-2025 | 0,1 % | 1 € | 0,3 % ; 0,4 % dès 01/04/2025 |

Pas de droits de garde en V1. Ma table 01 §2.2 et 01 §7.5 (entrée 3 %, ETF 0,3 %) sont **remplacées** par 03 pour le jeu.

### 1.5 Profils, budget et événements de vie

| Sujet | Décision | Réf. |
|---|---|---|
| Profils | Jeune salarié (22 ans, capital 0), cadre pressée (30 ans, 0), héritier (25 ans, capital moitié compte courant, moitié 2 actions de la période sur CTO). Salaires : 01 §7.3, interpolation géométrique ; indexation en janvier sur `SMN[a]/SMN[a−1]`. | 03 §5 |
| Dépenses | Salaire × (1 − épargne possible) ; loyer = part de la décennie + 3 pts (jeune) ou + 5 pts (cadre). | 03 §5.2 |
| Événements de vie | 11 retenus sur 13 (divorce et mariage en V2). Calendrier tiré au lancement (graine de vie), 1 à 3 par an, une perte d'emploi max tous les 5 ans, montants en M (mois de salaire). | 03 §6.2 |
| Paramètres clés | Perte d'emploi : 65 % du salaire 6 à 12 mois. Naissance : +9 % du salaire (12 % − 3 % d'allocations), 2 enfants max. Escargots : 90 % de perte, 10 % de ×1,5. Panne de voiture forcée une fois pendant un krach. | 03 §6.2 |
| Découvert | Toléré 1 M ; agios 20 % (≤ 1990), 15 % (1991-2008), 16 % (≥ 2009) ; faillite après 3 mois au-delà. Pas de petit crédit. | 03 §7.6 |
| Témoins | Tata Livret respecte le plafond du Livret A (ma recommandation). Cousin Indice : coussin de 3 mois, SICAV puis ETF (01/2001), PEA dès qu'il existe. | A16, 03 §7.8 |

### 1.6 Hors V1 (ne pas pousser sans demande du client)

LEP, Codevi/LDD, or, SCPI, PER, crypto, actions étrangères ; seuil de cessions 1978-2010, clôture du PEA, effet fiscal Monory, droits de garde, taux de service et actions gratuites des privatisations, nationalisations, prix des obligations, SRD, petit crédit (03 §9). L'**assurance-vie est entrée** dans la démo V2 (A36).

### 1.7 Démo V2 (12_arbitrages_v2_demo.md, 2026-10-26/27) et mon document 11

| Sujet | Décision |
|---|---|
| Cadre | **01/1984 → 12/1988**, profil unique **Gérard, 26 ans, technicien, en couple avec Sylvie** ; naissance scriptée au printemps 1985 (jumeaux possibles) ; héritage de tante Odette en 1988. Validé par le joueur. |
| Produits | 9 lignes : compte courant, Livret A, PEL, emprunt d'État 10 ans, assurance-vie fonds en francs, SICAV actions, Elf / L'Oréal / Peugeot, Saint-Gobain. Autres produits d'époque en silhouette seulement. |
| Ordre (12 §2.2), que j'ai **retenu** | Livret A (mois 1) → PEL → emprunt d'État → assurance-vie (à la naissance) → SICAV → actions → Saint-Gobain (historique). Dates limites pour tout voir avant le krach. |
| Banquier | Choisit quoi présenter et quand ; le joueur décide ; 3 boutons « Ouvrir / Pas maintenant / En savoir plus » ; présentation ≤ 60 mots avec **exemple chiffré sur l'argent du joueur** ; comparatif sur 4 critères (rendement, risque, disponibilité, fiscalité). Jamais « vous devriez », jamais de prévision. |
| Profil | **Pas de questionnaire de risque** (joueur, 2026-10-27) : adaptation **uniquement selon la situation de vie** (âge, couple, enfants, épargne, coussin, produits détenus). |
| Frais (retour du 27/10) | Section « Pédagogie des frais » dans 11 §5 : exemples 0,5 % contre 2,5 % (7 % brut : 35 236 contre 24 117 à 20 ans), formules et « jumeau sans frais ». |
| Héritage d'Odette (coordinateur, 27/10) | **Un seul pot** : assurance-vie de 60 000 F (04/1988), plus de succession séparée. Comparaison montrée : par succession, 60 000 − 10 000 F d'abattement = 50 000 × 55 % = **27 500 F de droits, 32 500 F nets** (11 §1.7.4). |
| Versements programmés (joueur, 27/10) | 11 §8 : oui pour Livret A (virement permanent, plafond), PEL (obligatoire, 3 600 F/an), assurance-vie (4 % par versement), SICAV (2 %) ; non pour actions et emprunt d'État. Règles VP1-VP11, textes VP-A à VP-D. |
| Mes propositions en attente du client | D3 (Livret A au guichet d'une banque générique, bulle), **D4 (Gérard et Sylvie mariés ou non : je recommande non mariés)**, D5 (rachats d'assurance-vie à 45 / 25 / 15 / 0 % réels dans la démo), appels « baisse du Livret A » (08/1984, 07/1985, 05/1986), Saint-Gobain en 11/1986. |

---

## 2. Faits clés vérifiés (certitude A ou B)

### 2.1 Monnaie et marché

| Fait | Valeur | Cert. |
|---|---|---|
| Nouveau franc | 01/01/1960, 100 AF = 1 NF | A |
| Euro | 01/01/1999 scriptural, 1 € = 6,55957 F ; billets 01/01/2002 ; franc retiré le 17/02/2002 | A |
| Dématérialisation des titres | 03/11/1984 | A |
| Fin des agents de change | Loi n° 88-70 du 22/01/1988 (sociétés de bourse) ; courtages libres le 01/07/1989 | A |
| CAC 40 | Base 1 000 au 31/12/1987, publié à partir du 15/06/1988 | A |
| Contrôle des changes | Devise-titre 1971-1986 ; levée totale le 01/01/1990 | B / A |
| Euronext et SRD | 2000 (le SRD remplace le règlement mensuel en 09/2000) | A |
| Régulateur | COB 1967 → AMF 2003 | A |

### 2.2 Dates de création utiles (01 §1.1)

| Produit | Début | Fin de commercialisation | Cert. |
|---|---|---|---|
| SICAV | 1964 (décret du 20/09/1963) | — | A |
| CEL / PEL | 1965 / décret du 24/12/1969 | — | A |
| SCPI | Loi du 31/12/1970 | — | A |
| LEP / Codevi | 1982 / 1983 (LDD 2007, LDDS 2017) | — | A |
| CEA (Delors) | 1983 | 1987 | B |
| PEP | 1990 | 25/09/2003 | A |
| PEA | Loi n° 92-666 du 16/07/1992 | — | A |
| Madelin / PERP | 1994 / 2003-2004 | 01/10/2020 | A |
| ETF à Paris | 01/2001 | — | B |
| PEA-PME / PEA jeune | 2014 / 2019 | — | A |
| PER individuel | 01/10/2019 (loi PACTE du 22/05/2019) | — | A |
| Livret A dans toutes les banques | 01/01/2009 (loi LME) | — | A |

### 2.3 Livret A dans les périodes V1 (détail : 01 §4.1 et §4.2)

| Repère | Valeur | Cert. |
|---|---|---|
| Taux P1 | 6,5 % (1978) → ≈ 7,5 % (≈ 04/1980, B) → **8,5 % au 16/10/1981** → 7,5 % (01/08/1983) → 6,5 % (16/08/1984) → 6 % (01/07/1985) → 4,5 % (31/05/1986 à 1996) | A sauf 1980 |
| Taux P2 | 3,5 % (01/03/1996) … 4 % (01/08/2008) → 1,25 % (01/08/2009) → 1,75 % (01/08/2010) | A |
| Taux P3 | 2 % (02/2011), 2,25 % (08/2011) … 0,75 % (08/2015), **0,5 % (02/2020)**, 3 % (02/2023), 2,4 % (02/2025), 1,7 % (08/2025) | A |
| Plafonds P1 | 38 000 F (15/11/1977), 41 000 F (01/09/1978), 45 000 puis 49 000 F (1980, B), 58 000 F (02/04/1983), 68 000 F (15/06/1984), 72 000 F (31/05/1986), 80 000 F (30/06/1987), 90 000 F (01/05/1990), 100 000 F (30/10/1991) | A |
| Plafonds P2-P3 | 100 000 F → 15 300 € (01/01/2002) → 19 125 € (01/10/2012) → 22 950 € (01/01/2013) | A |
| Rendement réel | Négatif jusqu'en 1984, positif de 1985-1986 à 2016, négatif en 2021-2023 (01 §4.4) | A depuis 1986 |
| Test CA-14 | 10 000 F au 01/01/1982 → 10 850 F au 31/12/1982 | — |

### 2.4 PEA

| Paramètre | Valeur | Cert. |
|---|---|---|
| Plafond | 600 000 F (1992) → 120 000 € (01/01/2002) → 132 000 € (01/01/2003) → 150 000 € (01/01/2014) | A |
| Fiscalité réelle | Exonération d'IR après 5 ans (PS dus) ; avant 2019, retrait avant 8 ans = clôture ; PACTE 2019 : retraits partiels libres après 5 ans | A/B |
| Frais plafonnés | Depuis le 01/07/2020 : garde ≤ 0,4 %/an, courtage ≤ 0,5 % en ligne | A |
| Univers | Actions UE/EEE et OPCVM ≥ 75 % éligibles ; ni obligations ni actions américaines en direct | A |

### 2.5 Fiscalité réelle (pour les bulles et la V2 ; détail 01 §3.3)

| Repère | Valeur | Cert. |
|---|---|---|
| Plus-values mobilières | Non imposées avant 1978 (B) ; loi du 05/07/1978 : imposées au-delà d'un seuil de cessions (1978-2010) ; seuil supprimé en 2011 ; barème + abattements 2013-2017 ; PFU 30 % en 2018 | A |
| Avoir fiscal | 1965-2004, supprimé le 01/01/2005 | A/B |
| PS | 0 % avant 1991 ; 10 % (1998), 11 % (2005), 12,1 % (2009), 13,5 % (10/2011), 15,5 % (07/2012), 17,2 % (2018), 18,6 % (2026, assurance-vie maintenue à 17,2 %) | A depuis 1996 |
| PFU | 30 % au 01/01/2018 ; 31,4 % au 01/01/2026 | A / A-B |
| ISF / IFI | IGF 1982-1986, ISF 1989, IFI 01/01/2018 | A |
| Monory | Loi du 13/07/1978, déduction de 5 000 F par foyer (+ 500 F par enfant), revenus 1978-1981 | A |

### 2.6 Coûts de transaction réels

| Repère | Valeur | Cert. |
|---|---|---|
| Impôt de bourse | ≈ 0,3 % (0,15 % au-delà d'un seuil), plafonné (610 € en fin de période), achats et ventes, supprimé le 01/01/2008 | A |
| TTF | Achats d'actions françaises > 1 Md€ de capitalisation : 0,2 % (01/08/2012), 0,3 % (01/01/2017), 0,4 % (01/04/2025) | A |
| Étude AMF 2015 | Ordre de 5 000 € : 26,60 € en banque, 8,40 € en ligne | A |

### 2.7 Opérations grand public (marché primaire, 01 §3.2)

| Opération | Date | Prix particuliers | Cert. |
|---|---|---|---|
| Saint-Gobain | OPV 11-12/1986 | 310 F | A |
| Krach / privatisation de Suez | 10/1987 | — | A |
| France Télécom | 20/10/1997 | 182 F (1er cours 215 F) ; pic ≈ 219 € (03/2000) | A |
| EDF | 21/11/2005 | 32 € ; OPA de l'État à 12 € en 2023 | A |
| Française des Jeux | 21/11/2019 | 19,90 € | A |
| Emprunt Giscard 7 % indexé or | 01/1973, remboursé 01/1988 | — | A (dates) |
| Nationalisations | Loi du 13/02/1982, indemnisation en obligations | — | A |

### 2.8 Assurance-vie, successions et produits de 1984-1988 (vérifiés en 10/2026 ; détail 11 §1.3.5, §1.7)

| Fait | Valeur | Cert. |
|---|---|---|
| Succession, contrats souscrits **avant le 20/11/1991** | Hors succession (C. assur. L. 132-12) et **aucun droit, quel que soit le montant** (RM n° 3073, JO 06/09/1993) | A |
| Art. 757 B, 1re version | Loi de finances pour 1980 (19/01/1980, art. 68) : anti-abus, seuil 100 000 F, contrats souscrits tard (conditions exactes C) | A / C |
| Art. 757 B actuel | LFR 1991 (loi n° 91-1323, art. 26) : contrats depuis le 20/11/1991, primes après 70 ans, au-delà de **200 000 F** → 30 500 € | A |
| Art. 990 I | Primes depuis le 13/10/1998 avant 70 ans : 20 % au-delà de 1 MF par bénéficiaire → 152 500 € (2002) ; 25 % > 902 838 € (2011) ; 31,25 % > 700 000 € taxables (07/2014) | A |
| TEPA 22/08/2007 | Conjoint et Pacs exonérés | A |
| Rachats, contrats 1983-1989 | PL optionnel 45 % (< 2 ans), 25 % (2-4), 15 % (4-6), 0 % après 6 ans ; contrats < 1983 exonérés ; 8 ans dès 1990 (35 / 15 %) | A/B |
| Réduction d'impôt sur primes (avant 1996) | 25 % des primes, plafond 4 000 F + 1 000 F par enfant ; supprimée en 1996-1997 | B |
| AFER, fonds garanti net | 12,98 (1984), 12,09 (1985), 11,51 (1986), 10,35 (1987), 10,05 (1988), 9,22 (1990) … 2,40 % (2017) | A |
| Fonds en francs « réseau » pour le jeu | AFER − 0,5 pt : 12,5 / 11,5 / 11 / 9,75 / 9,5 % (1984-1988) | C |
| Multisupport | Triplan (Cardif) 1981, premier d'un réseau bancaire | B |
| Droits de succession 1984-1991 | Abattement **275 000 F** (enfant et conjoint) depuis 01/01/1984 ; 300 000 / 330 000 F au 01/01/1992 ; barème en ligne directe 5/10/15/20 % (20 % dès 100 000 F) ; **concubin 60 %**, neveu **55 %** après l'**abattement minimum de 10 000 F par part** (art. 788, du 01/01/1974 à 1988 au moins, AN QE 35859, A) ; conjoint avec enfants : usufruit du quart avant la loi de 2001 | A (B hautes tranches) |
| Abattements ligne directe ensuite | 46 000 € (2002), 50 000 € (2006), 150 000 € (08/2007), 159 325 € (2011), **100 000 €** (17/08/2012) | A/B |
| PEL | 6,30 % hors prime (06/1983-07/1984), 5,30 % (08/1984-06/1985), 4,75 %, 4,62 % (05/1986-01/1994) ; prime versée **sans prêt** pour les PEL ouverts avant le 12/12/2002, plafond 10 000 F | B |
| CEL | 2,75 % hors prime (ouvert du 16/05/1986 au 15/02/1994) | B |
| LEP plafonds | 5 000 F (1982), 10 000 F (1983), 20 000 F (04/1984), 30 000 F (11/1991), 40 000 F (1999), 7 700 €, **10 000 € au 01/10/2023** | B |
| Codevi plafonds | 10 000 F (1983, C), 15 000 F (date ?) → 20 000 F (07/1993) → 30 000 F (01/10/1994) | B/C |
| CEA | 1983 → **31/12/1988** (prorogé d'un an), 25 % des achats nets, 7 000 / 14 000 F | A/B |
| PER « 1988 » | Loi du 17/06/1987 ; 01/01/1988 → 31/12/1989 ; déduction 8 000 / 16 000 F ; remplacé par le PEP | B |
| Saint-Gobain | Mise en vente le **24/11/1986**, close début décembre, 310 F | A |
| SICAV de trésorerie | 424 Md F d'encours en 1987 sur 822 Md F de SICAV (rapport du Sénat) | A |
| Bons du Trésor sur formules | Émis jusqu'au 31/12/1998 ; anonymat possible | A/B |

---

## 3. Points incertains (certitude C) à fiabiliser

| Sujet | Valeur actuelle (01) | Utilisé en V1 ? | Sources pour fiabiliser |
|---|---|---|---|
| Livret A 1950-1959 | ≈ 2,5 % (1,5 à 3 %) | Non | Archives de la Caisse des dépôts, JO (arrêtés de taux), Annuaire statistique de la France |
| Livret A ≈ 04/1980 (7,5 %) et plafonds 1980 | B | **Oui (P1)** | JO / Légifrance (arrêtés du ministère de l'Économie), ADCF, archives des Caisses d'épargne |
| Livret A au 01/08/2026 (1,70 %) | B, annonce de l'été 2026 | Non | JO, communiqué de la Banque de France |
| Inflation 1950-1959 | ≈ valeurs | Non | INSEE, séries longues de l'IPC et coefficients de pouvoir d'achat |
| Seuil de cessions 1978-1999 (≈ 50 000 à 340 000 F) | C | Non (A6) | CGI art. 92 B / 150-0 A historiques, barèmes IPP, BOI archivés |
| Taux du prélèvement libératoire sur obligations (1965-2012) | C | Non | Barèmes IPP (taxation du capital), Légifrance |
| Courtage des agents de change avant 1989 | ≈ 1 à 1,5 % tout compris | Indirectement (1,3 % de 03 §7.5) | Tarifs de la Compagnie des agents de change, réponses ministérielles AN, IGPDE |
| PEL 1969-1985 : taux prime incluse (1984-1985 : ≈ 8,25 % puis ≈ 7 %, rapport de 1986 appliqué) | C | **Oui (démo V2)** | Arrêtés au JO, séries INSEE des placements réglementés |
| Codevi 1986-1993, condition de ressources du LEP en 1984-1988 | C | Silhouettes seulement | Décret n° 83-872 et modificatifs, JO 1982 |
| Fonds en francs des réseaux bancaires (AFER − 0,5 pt) | C | **Oui (démo V2)** | France Assureurs (ex-FFSA), rapports annuels 1984-1995 |
| Art. 757 B de 1980 (âge, primes) | C | Non | Légifrance, versions historiques du CGI |
| Versements programmés 1984-1988 : nom commercial et minimums des plans en SICAV et des primes périodiques d'assurance-vie ; PEL 3 600 F/an avant 1992 | B/C | **Oui (démo V2, 11 §8)** | Tarifs bancaires archivés, presse (Le Revenu, Mieux vivre), CCH art. R. 315 avant 1992 |
| Taux monétaires 1978-1992 (11 §1.3.2) | B/C | Non (jeu complet) | Banque de France ; **à valider par le boursier** |
| Taxe forfaitaire sur l'or 1976-1991 (4 % à l'origine, ≈ 6-7,5 %) | C | Non | CGI art. 150 V bis historique |
| Action gratuite des privatisations (1 pour 10, 18 mois) et son plafond | B | Non | Notes d'opération COB 1986 |
| Date de l'OPV de Suez (IGPDE : « 10/05/1987 ») | B | Non | Boursier |
| Souscripteurs des privatisations, prix GDF 2005, Natixis 2006 | C/B | Non | Commission de la privatisation, Cour des comptes, IGPDE, prospectus AMF |
| Taxe sur l'or avant 2014 | ≈ 7,5-8 % | Non | CGI art. 150 VK, BOFiP |
| Arrivée des néo-courtiers (Degiro, Trade Republic) | C | Non | Registre REGAFI, communiqués ACPR/AMF |
| Cortal 1984, Sogeposte, anonymat de l'or 1981-1982, emprunt obligatoire 1983 | C | Non | Archives de presse (Le Monde, Les Échos), Légifrance |
| Salaires des profils, dépenses par décennie, baguette avant 1961 | C (mes calibrages) | **Oui** | INSEE séries longues des salaires, budget de famille INSEE, base Fourastié-Sauvy |
| Taux des agios (20 / 15 / 16 %) | C | **Oui** | Banque de France (taux effectifs moyens, taux d'usure depuis 1966) |
| PS 2026 sur l'épargne-logement | B | Non | LFSS 2026, BOFiP |

Priorité si le client demande une fiabilisation : d'abord les données **utilisées en V1** (lignes « Oui »).

---

## 4. Anachronismes à éviter

| Interdit avant | Élément | Remarque |
|---|---|---|
| 06/1988 | Libellé « CAC 40 » | « Indice de la Bourse de Paris » avant (CA-08) |
| 12/1986 / 10/1997 | Saint-Gobain / France Télécom dans le jeu | Saint-Gobain était coté avant sa nationalisation de 1982 : son absence en 1978-1982 est une simplification, pas une erreur à corriger |
| 07/1992 | PEA | CA-05 |
| 01/2001 | ETF | CA-06 |
| 2002 | Affichage en € seul | F jusqu'en 1998, double affichage 1999-2001 (CA-09) |
| 01/01/2009 | Livret A dans « sa banque » | Avant : Caisse d'épargne, La Poste (et Livret bleu du Crédit Mutuel dès 1975) |
| 2005 | Compte courant rémunéré | Interdit avant, rare après |
| 1996-1999 | Courtier en ligne ; néo-courtier et ordre à 1 € avant ≈ 2015-2019 | |
| 01/01/1990 | Actions étrangères en direct facilement accessibles | Contrôle des changes |
| 2018 | « Flat tax », PFU, IFI | Avant : barème, PL, ISF (1989-2017) |
| 08/2012 | TTF | Et l'impôt de bourse disparaît au 01/01/2008 |
| 11/1984 | Fin des titres papier | Avant : coupons à découper |
| 09/2000 / 2003 | SRD / AMF | Avant : règlement mensuel / COB |
| 2007 / 10/2019 | LDD / PER | Codevi avant 2007 ; PERP 2004-2020 |
| 05/2021 | Nom « TotalEnergies » | Total (1991-1999), TotalFina (1999), TotalFinaElf (2000-2003), Total (2003-2021) [A pour 2021, B pour les étapes] → **à signaler au client pour P3 et P2** |
| 07/2013 | Nom « Orange » pour la société | France Télécom en 2011-2013 [A] → à signaler pour P3 |
| 12/2006 | Nom « Alcatel-Lucent » | Alcatel Alsthom jusqu'en 1998, puis Alcatel [B] |
| — | Contresens | Nationalisés de 1982 indemnisés en obligations (pas de perte totale) ; privatisation = OPV à prix fixe, pas un achat en bourse ; 2026 : PFU 31,4 % mais assurance-vie à 30 % ; jamais présenter une stratégie comme « la bonne » |

---

## 5. Journal des missions

| Date | Mission | Résultat |
|---|---|---|
| non consignée | Recherche initiale sur les enveloppes, produits, acteurs, réformes 1950-2026 | `docs/01_enveloppes_france.md` §1 à §6 |
| non consignée | Réponses au client (00) : produits par période, Livret A et inflation, salaires, fiscalité simplifiée, frais, événements de vie | 01 §7 ; table fiscale §7.4 retenue par le client (A6) |
| non consignée | Prix de la baguette pour le designer UX | 01 §7.3 bis, retenu comme unité de pouvoir d'achat (A4) |
| 2026-10-26 | Constitution de la base de connaissances (sans recherche web) ; relevé des écarts 01/03 et des anachronismes de noms de sociétés (TotalEnergies, Orange) | `docs/connaissances/banquier.md` |
| 2026-10-26/27 | Catalogue de la banque par période, progression du joueur, adaptation à la situation de vie, 25 répliques L + 12 répliques démo D (≤ 60 mots), règles d'assurance-vie et de succession (recherche web), héritage d'Odette, pédagogie des frais (formules, exemples, jumeau sans frais) ; alignement sur 12 (démo 1984-1988) | `docs/11_catalogue_banque.md` ; corrections dans 01 (CEA 1988, LEP 01/10/2023, PEL 1983-1985, transmission AV) |

| 2026-10-27 | Versements programmés (11 §8) ; héritage d'Odette en un seul pot, abattement neveu de 10 000 F vérifié (11 §1.7.3-1.7.4) ; sources renumérotées en 11 §9 | `docs/11_catalogue_banque.md` |

### Erreurs à ne pas refaire
- Ne pas affirmer qu'un texte du banquier est « sous 60 mots » sans compter ; vérifier chaque calcul (une première version de 11 §5.3 mélangeait deux définitions de « part des gains mangée » : toujours préciser la référence, « par rapport à 0,5 % » ou « par rapport à sans frais »).
- Avant 1986, un PEL « prime incluse » ne peut pas rapporter moins que le Livret A : une source qui donne 6,3 % en 1984 parle du taux **hors prime**.
- Droits d'un neveu : ne pas oublier l'abattement minimum de 10 000 F (depuis 1974 ; abattement propre aux neveux depuis la loi TEPA de 2007, aujourd'hui 7 967 €, B) ; ne pas confondre la part nette (45 %) et les droits (55 %).
- L'avantage successoral de l'assurance-vie **pour un enfant** n'existe qu'au-delà de l'abattement (275 000 F en 1984-1991) : avec les petites sommes du joueur, l'argument concret est celui du **concubin** (ou du conjoint avant 2001).
