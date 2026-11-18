# 34 — Banquier : extension des années (K2 catalogue 2019-2023, K1 état des lieux 1950-2025)

> Réponse aux demandes K1 et K2 de `docs/lots/plan_extension_annees.md` §4.2. Rédigé le 2026-11-18 par le banquier.
> Priorité : **K2 d'abord** (première période à ouvrir : chapitre 2019-2023), **K1 ensuite** (décennies 1950-2025).
> Certitude : **A** vérifié (texte officiel ou plusieurs sources concordantes), **B** probable (une source fiable, ±1 an ou ±5 %), **C** reconstitué (ordre de grandeur).
> Les documents de `docs/sources/` priment ; aucun n'a été nécessaire ici. Contenu pédagogique : aucun conseil personnalisé.
> Contrainte de texte appliquée : **présentations ≤ 30 mots** (consigne de la demande ; docs/11 fixait 60 mots pour la démo 1984-1988). Comptage fait par mots séparés par des espaces (« 12 000 » = 2 mots, « : » et « % » = 1 mot chacun) : marge de sécurité prise.
> Variables entre accolades `{...}` : à remplir par le moteur avec le taux daté et l'argent du joueur.

---

# PARTIE K2 — Catalogue du banquier pour le chapitre 2019-2023

Fenêtre supposée : 01/2019 → 12/2023 (60 mois), profil unique ou 3 profils selon G3.

## K2.1 Résumé des choix (à lire en premier)

| Sujet | Position du banquier | Cert. |
|---|---|---|
| Nombre de produits | **10 lignes** : 9 présentées dans l'ordre ci-dessous + le PER en « silhouette » (visible, non jouable, ou jouable sur décision du client) | — |
| Leçon centrale 2019-2023 | **Taux fixe contre taux variable** : un PEL ouvert en 2019 reste à 1 % alors que le Livret A passe de 0,75 % à 3 % (02/2023) et le LEP à 6,1 % ; un PEL ouvert en 2023 (2 %) rapporte moins que le Livret A (3 %). Et l'inflation (5,2 % en 2022) bat le Livret A en 2021-2023. | A |
| Fiscalité à afficher | PFU 30 % (12,8 % IR + 17,2 % prélèvements sociaux) tout au long de la période ; PEA > 5 ans : 17,2 % ; **aucun changement de taux 2019-2023** (la table de `regles.json` : `2018 → cto 30, pea5 17.2` suffit) | A |
| Marché primaire grand public | **Française des Jeux, 21/11/2019, 19,90 €** (déjà dans docs/01 et la base) : candidate à une carte/notification « contexte » dans le chapitre (introduction de 2019 ouverte aux particuliers, ≈ 500 000 souscripteurs particuliers : ordre de grandeur C) | A (date, prix) |
| Forme du banquier | Conseiller en agence + application mobile (voir K2.7) | B |
| Écart à signaler | Frais de courtage de `regles.json` pour 2019+ (0,1 %, min 1 €) correspondent aux néo-courtiers (1 à 2 € par ordre) ; une banque de réseau ou un courtier en ligne classique coûtait en 2019 bien plus cher (0,3 à 0,6 %, min 2 à 10 €). Simplification acceptable, mais à dire dans la bulle (K2.4). | B |

## K2.2 Catalogue : ordre de présentation et déclencheurs

M = mois de la partie (M1 = 01/2019). Les déclencheurs sont **relatifs au début de partie** (règle de `docs/32`/plan) ; la date réelle est donnée pour contrôle. Tous les produits sont vus **avant fin 02/2020 (M14)**, c'est-à-dire avant le Covid, pour que le krach de 03/2020 trouve le joueur informé (même logique que « tout voir avant le krach » de la démo 1984-1988).

| # | Produit | Présenté à | Déclencheur (relatif) | Pourquoi dans cet ordre | Retiré / change |
|---|---|---|---|---|---|
| 1 | Livret A | M1 | Départ de partie | Socle, 0 % d'impôt, taux 0,75 % | Taux : voir K2.3 |
| 2 | LDDS | M3 | Livret A ≥ 50 % du plafond **ou** M3 au plus tard | Même taux, plafond 12 000 € : « deuxième tiroir » | — |
| 3 | LEP | M4 | **Si le foyer est éligible** (revenu fiscal de référence sous plafond, ≈ 20 000 € pour 1 part en 2021, B) ; sinon le banquier explique qu'il n'y a pas droit | Meilleur taux sans risque dès 02/2022 (2,2 %) puis 6,1 % en 02/2023 ; conditions de ressources = bonne leçon | Plafond 10 000 € le 01/10/2023 |
| 4 | PEL | M6 (au plus tard M8) | Projet d'achat de la résidence principale ou 1er dilemme « logement » du foyer | Taux **fixé à l'ouverture** : 1 % (ouvert en 2019). Texte d'avertissement : « taux fixe, ne bougera pas ». | Pas de prime d'État depuis 2018 (K2.3) |
| 5 | Assurance-vie, fonds euros | M9 | Naissance, projet ou argent dormant > 6 mois de salaire | Garantie du capital, 1,4 % servi en 2019 ; à comparer avec Livret A 0,75 % | — |
| 6 | Assurance-vie, unités de compte | M10 (même fiche, 2e étape) | Après les fonds euros | Capital non garanti ; fait le lien avec le PEA | — |
| 7 | PEA (enveloppe) | M11 | Avoir ≥ 3 mois de salaire de côté | Enveloppe fiscale ; horloge de 5 ans démarrée au 1er versement | Retraits : règles K2.3 |
| 8 | ETF CAC 40 | M12 | Après le PEA | Fonds indiciel, frais ≈ 0,25 % ; dans PEA ou en CTO | — |
| 9 | Actions en compte-titres (LVMH, TotalEnergies [« Total » avant 05/2021], BNP Paribas, Orange) | M13-M14 | Après l'ETF | Dernier de l'échelle des risques ; PFU 30 % | **Noms : Total jusqu'à 05/2021 (A)** |
| 10 | PER (silhouette) | M14 | Seulement présent sous forme de bulle « Le saviez-vous ? » | Créé le 01/10/2019 (loi PACTE) ; sortie bloquée jusqu'à la retraite, hors V1 selon docs/03 §9 | Hors périmètre (décision client à confirmer) |

Hors catalogue, à ne pas présenter : emprunt d'État (taux 10 ans ≈ 0,1 % en 2019, négatif en 2020, ≈ 3 % fin 2023 ; un particulier l'achète via compte-titres : trop abstrait pour 2019, B), crypto, SCPI, CEL (supplanté), Livret jeune.

## K2.3 Paramètres datés 2019-2023 (exploitables)

### K2.3.1 Livrets réglementés

| Produit | Date d'effet | Taux | Plafond (versements) | Fiscalité | Cert. |
|---|---|---|---|---|---|
| Livret A | 01/08/2015 → 31/01/2020 | 0,75 % | 22 950 € (depuis 01/01/2013) | 0 % | A |
| Livret A | 01/02/2020 → 31/01/2022 | 0,50 % | 22 950 € | 0 % | A |
| Livret A | 01/02/2022 | 1,00 % | 22 950 € | 0 % | A |
| Livret A | 01/08/2022 | 2,00 % | 22 950 € | 0 % | A |
| Livret A | 01/02/2023 → 31/01/2025 | 3,00 % | 22 950 € | 0 % | A |
| LDDS | idem Livret A (même taux) | idem | **12 000 €** (depuis 01/10/2012) | 0 % | A (plafond), A (taux = Livret A) |
| LEP | 01/08/2015 → 31/01/2020 | 1,25 % | 7 700 € | 0 % | A / B |
| LEP | 01/02/2020 | 1,00 % | 7 700 € | 0 % | A |
| LEP | 01/02/2022 | 2,20 % | 7 700 € | 0 % | A |
| LEP | 01/08/2022 | 4,60 % | 7 700 € | 0 % | A |
| LEP | 01/02/2023 | 6,10 % | 7 700 € | 0 % | A |
| LEP | 01/08/2023 | 6,00 % | 7 700 → **10 000 € le 01/10/2023** | 0 % | A |
| LEP, condition de ressources (revenu fiscal de référence N-2, 1 part, métropole) | 2021 : 20 016 € ; 2023 : 21 393 € ; 2019-2020 : ≈ 19 500-20 000 € | — | — | — | A (2021, 2023), C (2019-2020) |

Notes : les intérêts sont crédités une fois par an (31/12), calculés par quinzaine ; un jeu simplifié peut garder « crédit au 31/12 » comme dans la démo (docs/03 §7.3). Le LEP est un bon candidat de « produit conditionnel » : si le profil dépasse le plafond de ressources, le banquier le dit et ne propose pas d'ouverture.

### K2.3.2 Épargne logement

| Produit | Date d'ouverture | Taux annuel (hors prime) | Taux du prêt associé | Cert. |
|---|---|---|---|---|
| PEL | 01/08/2016 → 31/12/2022 | **1,00 %** | 2,20 % | A |
| PEL | 01/01/2023 → 31/12/2023 | **2,00 %** | 3,20 % | A |
| PEL | 01/01/2024 → 31/12/2024 | 2,25 % | 3,45 % | A |
| PEL | 01/01/2025 → 31/12/2025 | 1,75 % | 2,95 % | A |
| CEL | 01/08/2015 → 31/01/2020 | 0,50 % | 2,00 % | A |
| CEL | 01/02/2020 → 31/01/2022 | 0,25 % | 1,75 % | A |
| CEL | 01/02/2022 → 31/07/2022 | 0,75 % | 2,25 % | A |
| CEL | 01/08/2022 → 31/01/2023 | 1,25 % | 2,75 % | A |
| CEL | 01/02/2023 → 31/01/2025 | 2,00 % | 3,50 % | A |

Règles du PEL (B, à confirmer au CCH si le client veut les coder) : durée de 4 à 10 ans ; retrait avant 4 ans = clôture ; versement initial ≥ 225 € puis ≥ 540 € par an ; plafond 61 200 € ; **prime d'État supprimée pour les PEL ouverts depuis le 01/01/2018** (A) ; intérêts des PEL ouverts depuis 2018 soumis au PFU 30 % chaque année (A). Le PEL se prête à une règle de jeu simple : `taux_PEL = taux de la date d'ouverture, constant ensuite` (déjà le mécanisme de la démo 1984-1988).

### K2.3.3 Assurance-vie

| Paramètre | Valeur 2019-2023 | Cert. |
|---|---|---|
| Taux servi moyen des fonds euros (net de frais de gestion, avant prélèvements sociaux) | 2018 : 1,83 % ; **2019 : 1,46 %** (ACPR ; France Assureurs ≈ 1,4 %) ; **2020 : ≈ 1,3 %** ; **2021 : 1,3 %** ; **2022 : 1,9 %** ; **2023 : 2,6 %** | A (2019, 2022, 2023), B (2020 et 2021 : arrondis, une valeur de 1,1 % circule mais n'est pas étayée) |
| Meilleurs fonds euros (pour une variante « bon fonds ») | ≈ 2,5-3,0 % en 2019 ; > 3 % en 2023 | C |
| Prélèvements sociaux sur fonds euros | 17,2 %, prélevés chaque année sur les intérêts crédités | A |
| Rachat, contrat < 8 ans | PFU 12,8 % + 17,2 % = 30 % sur la part de gains | A |
| Rachat, contrat ≥ 8 ans (primes versées depuis le 27/09/2017) | 7,5 % + 17,2 % = 24,7 % sur la part de gains correspondant à ≤ 150 000 € de primes ; 12,8 % au-delà ; abattement annuel 4 600 € (personne seule) ou 9 200 € (couple) sur les gains | A |
| Frais d'entrée (sur chaque versement) | Courtier / assureur en ligne : 0 % ; banque de réseau : 0 à 4,8 % (plafond contractuel), **≈ 3 % typique** | B |
| Frais de gestion annuels | Fonds euros : 0,6 à 0,85 % ; unités de compte : 0,5 à 1 % (+ frais propres du fonds : ETF ≈ 0,2-0,3 %, fonds actifs 1,5-2 %) | B |
| Loi PACTE (22/05/2019) | Assouplit les contrats (euro-croissance, transfert) ; pas d'effet à modéliser | A |

Pour le jeu, une seule fiche « fonds euros » (taux = moyenne de l'année, `n−1` annoncé en janvier comme dans la démo : « le fonds a servi X % l'an dernier ») et une seule fiche « unités de compte » (suivent l'ETF CAC 40 moins 0,8 % de gestion) suffisent.

### K2.3.4 PEA, compte-titres, flat tax

| Paramètre | Valeur 2019-2023 | Cert. |
|---|---|---|
| Plafond du PEA | **150 000 €** | A |
| Plafond du PEA-PME | 225 000 € (limite commune PEA + PEA-PME = 225 000 € depuis la loi PACTE) | A |
| PEA jeune (créé 2019) | 18-25 ans, rattaché au foyer fiscal des parents, plafond **20 000 €**, devient PEA classique à 25 ans en gardant l'ancienneté | A |
| Retraits PEA | **Avant 5 ans : clôture et imposition** (PFU 30 %). **Après 5 ans : retraits partiels possibles sans clôture** (loi PACTE, depuis 2019) ; gains exonérés d'IR, prélèvements sociaux 17,2 % dus. | A |
| Frais plafonnés (garde et courtage PEA/ETF) | Depuis le 01/07/2020 : garde ≤ 0,4 %/an, courtage ≤ 0,5 % en ligne (voir base §2.4) | A |
| Dividendes, intérêts, plus-values en compte-titres | PFU 30 % (12,8 % + 17,2 %) ; option barème globale possible | A |
| PFU, prélèvements sociaux | 30 % et 17,2 %, **inchangés de 2019 à 2023** (le PFU passe à 31,4 % le 01/01/2026 d'après la base, B) | A |
| TTF (taxe sur les transactions financières) | 0,3 % (achats d'actions françaises > 1 Md€ de capitalisation) ; 0,4 % dès 01/04/2025 | A |
| Impôt de bourse | supprimé depuis 2008 | A |
| Moins-values | Imputables sur les plus-values de même nature (report 10 ans) : **non reportées en V1** (docs/03 §7.4) | A |

### K2.3.5 Frais de courtage (ordre de 1 000 à 5 000 €)

| Type d'acteur en 2019 | Courtage typique | Cert. |
|---|---|---|
| Banque de réseau (agence) | ≈ 0,5-1 % de l'ordre, **minimum ≈ 8-12 €** (étude AMF 2015 : 26,60 € pour 5 000 € soit 0,53 %) ; droits de garde du compte-titres en plus (0,2-0,4 %/an hors PEA) | B (AMF 2015, A pour ce seul point ; extrapolation 2019 B/C) |
| Courtier en ligne classique (Boursorama, Fortuneo) | 1,99 € jusqu'à 500 € puis ≈ 0,35-0,60 % (offres d'entrée de gamme, source datée de 2026, ordre de grandeur pour 2019 : C) ; tarifs dégressifs pour gros volumes | C |
| Néo-courtier (Degiro 2 € par ordre, Trade Republic 1 € par ordre) | **1 à 2 € fixes** ; présents en France entre 2017-2021 (date exacte d'ouverture du PEA : plus tard, 2020-2023, C) | B (tarifs), C (dates) |
| ETF CAC 40 (gestion annuelle) | ≈ 0,25 % (Lyxor, Amundi) | B |
| Valeur retenue en V1 (`regles.json`) | 0,1 %, min 1 €, 2019-2025 (décision 03 §7.5) | décision client |

**Recommandation** : conserver la décision du client et ajouter une bulle : « Simplifié : en banque de réseau, le même ordre coûtait souvent 5 à 10 fois plus. » ; ou, si le game designer veut une vraie leçon de frais, deux « canaux » (réseau et en ligne) en V3.

## K2.4 Textes de présentation (≤ 30 mots, vouvoiement, aucun conseil)

Chaque texte est suivi du comptage de mots. Variables `{...}` : taux daté et exemple chiffré sur l'argent du joueur (ex. « 1 000 € rapportent {gain} € après un an »). Les boutons restent « Ouvrir / Pas maintenant / En savoir plus ».

| # | Produit | Texte (≤ 30 mots) | Mots |
|---|---|---|---|
| 1 | Livret A | « Le Livret A reste disponible à tout moment et ses intérêts ne sont pas imposés. Il rapporte {taux} % par an : {gain} € de gain sur {montant} €. » | 29 |
| 2 | LDDS | « Le LDDS fonctionne comme le Livret A : mêmes intérêts, aucun impôt, argent disponible. Plafond : 12 000 €. Il s'ajoute au Livret A. » | 24 |
| 3 | LEP | « Le LEP rapporte plus que le Livret A, sans impôt, mais il est réservé aux foyers aux revenus modestes. Plafond : 7 700 €. » | 24 |
| 4 | PEL | « Le PEL fixe son taux le jour de l'ouverture : {pel} % pendant toute sa durée. Il donne droit à un prêt immobilier à {pret} %. » | 26 |
| 5 | Assurance-vie, fonds euros | « L'assurance-vie en fonds euros garantit votre capital net de frais. Elle a rapporté en moyenne {taux} % l'an dernier. Après 8 ans, ses gains sont moins imposés. » | 27 |
| 6 | Assurance-vie, unités de compte | « Les unités de compte placent votre argent dans des fonds en actions ou en obligations : le capital n'est pas garanti et peut baisser comme monter. » | 26 |
| 7 | PEA | « Le PEA abrite actions européennes et ETF. Après 5 ans, les gains ne sont plus soumis à l'impôt sur le revenu, seulement à 17,2 % de prélèvements sociaux. » | 28 |
| 8 | ETF CAC 40 | « Un ETF suit un indice, par exemple le CAC 40, et s'achète comme une action. Frais annuels faibles ; valeur variable, sans garantie. » | 23 |
| 9 | Actions (compte-titres) | « Une action est une part d'entreprise. Son cours varie chaque jour et le dividende n'est pas garanti. En compte-titres, les gains sont taxés à 30 % (flat tax). » | 28 |
| 10 | PER (silhouette) | « Le PER sert à préparer la retraite : les versements sont déductibles du revenu imposable, mais l'argent est bloqué jusqu'à la retraite, sauf achat de la résidence principale. » | 28 |

Mot de prudence à garder dans la mise en page (hors comptage) : la ligne « En savoir plus » ouvre la carte à 5 critères (rendement, risque, disponibilité, fiscalité, frais) comme dans la démo.

### Messages datés « contexte » (≤ 30 mots chacun)

| Date | Texte | Mots | Cert. |
|---|---|---|---|
| 01/2019 (début) | « Le Livret A rapporte 0,75 % par an. L'inflation était d'environ 1,8 % en 2018 : votre argent y perd un peu de pouvoir d'achat. » | 26 | A (taux), A (inflation 2018 : 1,8 %, voir 01 §4.4) |
| 05/2019 | « La loi PACTE est adoptée. Elle assouplit le PEA après 5 ans et crée, à l'automne, le plan d'épargne retraite (PER). » | 22 | A |
| 21/11/2019 | « La Française des Jeux entre en Bourse à 19,90 € l'action, avec une offre ouverte aux particuliers. » | 18 | A |
| 02/2020 | « Le Livret A passe à 0,50 %, son plus bas niveau historique. Le LEP passe à 1 %. » | 17 | A |
| 07/2020 | « Les frais de garde et de courtage des PEA sont désormais plafonnés. » | 12 | A (date : 01/07/2020) |
| 02/2022 | « Le Livret A passe à 1 %. L'inflation s'accélère : sur 12 mois, les prix montent plus vite que ce taux. » | 22 | A |
| 08/2022 | « Le Livret A passe à 2 %. L'inflation française dépasse 5 % sur l'année 2022. » | 15 | A |
| 02/2023 | « Le Livret A passe à 3 %, le LEP à 6,1 %. Un PEL ouvert en 2019 reste, lui, à 1 %. » | 19 | A |
| 10/2023 | « Le plafond du LEP passe de 7 700 à 10 000 €. » | 11 | A |

## K2.5 Transmission et héritage (équivalent de tante Odette)

Proposition de cas pour le chapitre : **une tante (ou un oncle) lègue une assurance-vie de 40 000 € au joueur** (équivalent 1988 : 60 000 F ≈ 9 100 € nominaux, soit ≈ 17 000 € en 2019 avec l'inflation 1988-2019 (C) ; 40 000 € est un chiffre « jeu » plus parlant, à ajuster par le game designer). Un seul pot, comme en 1988.

### Comparaison par succession ou par assurance-vie (le joueur est un neveu ou une nièce)

| Étape | Par succession | Par assurance-vie |
|---|---|---|
| Abattement | **7 967 €** (neveu/nièce) | **152 500 €** (par bénéficiaire, art. 990 I, primes versées avant 70 ans) |
| Base taxable sur 40 000 € | 32 033 € | 0 € |
| Taux | **55 %** | 20 % au-delà de 152 500 € (jusqu'à 700 000 € taxables), 31,25 % au-delà |
| Droits | 17 618 € | **0 €** |
| Net reçu | 22 382 € | **40 000 €** |
| Cert. | A | A |

Variante **concubin(e)** : abattement 1 594 €, taux 60 % : droits 23 043 €, net 16 957 € (A) ; avec assurance-vie : 0 €. Variante **frère / sœur** : abattement 15 932 €, 35 % jusqu'à 24 430 € puis 45 % (A, tranches B). Variante **enfant** : abattement 100 000 € par parent et par enfant (A), droits 0 € ici.
Primes versées après 70 ans : abattement global de 30 500 € sur les primes (art. 757 B), hors 990 I (A).

### Couple : ce que le conjoint hérite (pour une carte de dilemme du foyer, type « Sylvie, qui n'est pas votre épouse »)

| Situation du couple | Droits de succession du survivant | Ce qu'il hérite sans testament | Cert. |
|---|---|---|---|
| Mariés | **0 %** (exonération TEPA du 22/08/2007) | Part légale : usufruit de tout (si enfants communs, au choix) ou ¼ en pleine propriété ; droit d'habitation viager sur le logement (1 an gratuit garanti) | A |
| Pacsés | **0 %** (exonération TEPA) | **Rien sans testament** : le Pacs n'ouvre aucun droit successoral ; droit temporaire au logement 1 an | A |
| Concubins (union libre) | **60 %** après abattement de 1 594 € | **Rien** ; aucune protection sans testament | A |

Messages utiles pour le banquier : l'assurance-vie permet de désigner **n'importe quel bénéficiaire** (concubin, ami) ; l'argent versé n'entre pas dans la succession ; pas de réserve héréditaire sur l'assurance-vie (sauf primes « manifestement exagérées », B).
Donations utiles : abattement parent-enfant 100 000 € tous les 15 ans ; don de somme d'argent exonéré jusqu'à 31 865 € (donateur < 80 ans, bénéficiaire majeur, tous les 15 ans) (A).

## K2.6 Salaires et dépenses des profils 2019-2023 (vérification de `salaires.json`)

Les lignes existantes : 2020 (smn 2 500 ; jeune 1 350 ; technicien 2 350 ; cadre 4 300 ; héritier 2 250 ; capital 45 000) et 2025 (smn 2 750 ; jeune 1 550 ; technicien 2 600 ; cadre 4 700 ; héritier 2 500 ; capital 50 000). Le champ `smn` du fichier correspond au **salaire net moyen** (pas au SMIC).

| Repère (net mensuel, € courants) | 2019 | 2020 | 2021 | 2022 | 2023 | Cert. / source |
|---|---|---|---|---|---|---|
| Salaire net moyen, équivalent temps plein, secteur privé | **2 424** | ≈ 2 480 | ≈ 2 560 | **2 630** | **2 735** | A (2019, 2022, 2023 : INSEE Première) ; B/C (2020, 2021 : interpolés) |
| Salaire net médian, secteur privé | **1 940** | ≈ 1 990 | ≈ 2 060 | ≈ 2 100 | **2 183** | A (2019, 2023) ; C (autres) |
| SMIC net mensuel (35 h) | ≈ 1 204 | ≈ 1 219 | ≈ 1 231 → 1 258 | ≈ 1 269 → 1 302 → 1 329 | ≈ 1 353 → 1 383 | B (valeurs à confirmer au JO) |
| Inflation (IPC moyenne annuelle) | 1,1 % | 0,5 % | 1,6 % | 5,2 % | 4,9 % | A (01 §4.4) |

Contrôle de la table actuelle :
- **2020 : cohérente** (smn 2 500 contre ≈ 2 480 réel, écart ≈ 1 %) ; `jeune` 1 350 ≈ 1,1 SMIC net : plausible ; `technicien` 2 350 ≈ 0,95 × moyenne : plausible ; `cadre` 4 300 : plausible (cadres du privé : net moyen autour de 4 000 €, B/C).
- **2025 : probablement un peu bas.** L'interpolation géométrique 2020 → 2025 donne ≈ 2 647 en 2023 contre **2 735 réels** (−3 %), et la ligne 2025 (2 750) est à peine supérieure à la valeur 2023. Valeur plus cohérente pour 2025 : **smn ≈ 2 850 à 2 900** (C : à vérifier sur INSEE 2024-2025), avec les autres profils × 1,04. À arbitrer ; **non bloquant pour 2019-2023** si l'on ajoute une ligne **2023 : smn 2 735, jeune 1 480, technicien 2 530, cadre 4 550, héritier 2 400, capital 47 000** (proportions de 2020 conservées ; C).
- **Dépenses** : la ligne `de: 2010 → loyer 26 %` couvre 2019-2023 ; la part du logement dans le budget des ménages (loyers + charges) est de l'ordre de 25-30 % (B). Aucun changement requis. Les montants d'épargne possibles (8 % / 18 % / 15 % / 12 %) restent plausibles ; à la hausse des prix de 2022-2023 (+10 % sur deux ans) la part d'épargne devrait baisser : **malus de −2 points en 2022-2023** proposé (C) pour la leçon « l'inflation grignote l'épargne ».
- **Indexation de janvier** (`smn[a]/smn[a−1]`) : avec les valeurs ci-dessus, +2,4 % (2020), +3,2 % (2021), +2,7 % (2022), +4,0 % (2023) ; cohérent avec l'inflation de 2022 qui reste supérieure (écart de pouvoir d'achat = effet voulu).

## K2.7 Forme du banquier en 2019

| Question | Réponse | Cert. |
|---|---|---|
| Conseiller en agence ? | Oui, dominante pour les clients des banques de réseau (BNP, Société Générale, Crédit Agricole, Caisse d'Épargne, LCL, Banque Populaire…) ; **environ 35 000 agences en 2019, en baisse continue** | B (ordre de grandeur C pour le nombre) |
| Application mobile ? | Oui : consultation, virements, ouverture de livret en ligne ; **banques en ligne** (Boursorama, Fortuneo, ING, Hello bank!) en progression ; « néo-banques » (N26, Revolut) émergentes | B |
| Conseil à distance ? | Rendez-vous téléphoniques ou en visioconférence répandus à partir du premier confinement (**17/03/2020 → 11/05/2020**) | A (dates), B (usage) |
| Forme recommandée pour le jeu | **Conseillère ou conseiller humain, représenté·e dans la « banque » de la ville** (continuité avec M. Lefranc) ; en 2019, l'appel du banquier = message de l'application + appel téléphonique ; en mars-mai 2020, la banque est « fermée » (agence au ralenti), rendez-vous par visio | proposition |
| Nom (proposition) | Mme Delmas, conseillère clientèle (nom libre, à choisir par le client/game designer) ; tutoiement **non** ; vouvoiement partout | proposition |
| Dissymétrie à signaler | Ouvrir des comptes à la banque physique ou en ligne est gratuit ; seuls les actes de gestion (courtage, droits de garde, frais d'assurance-vie) sont facturés | B |

Pour le thème UX : intérieur d'agence avec distributeur et vitrine ; panneau « Prenez rendez-vous » ; affichage numérique des taux (écran LED de vitrine : Livret A {taux} %).

## K2.8 Ce qui manque encore pour 2019-2023 (à fournir ou à arbitrer)

| Sujet | Statut | Qui |
|---|---|---|
| Taux exact des fonds euros 2020 et 2021 (1,3 % ? 1,28 / 1,30 ?) | B : ACPR « revalorisation 2020 » et « 2021 » à consulter | banquier si le client demande |
| Condition de ressources du LEP 2019-2020 | C | banquier |
| Dates d'arrivée en France des néo-courtiers avec PEA | C | banquier |
| Revue des salaires 2021-2025 et table 2023 | C | banquier + chef de projet (data) |
| Ajouter ou non un PER jouable | décision client | client |
| Distinguer canaux « banque de réseau » et « en ligne » (frais) | décision client / game designer | client |

---

# PARTIE K1 — État des lieux par décennie (1950-2025)

Pour chaque décennie : produits accessibles, taux et plafonds, fiscalité simplifiée, monnaie, frais ; **déjà dans `godot/data/`** et **manquant**. Détail et sources de l'historique : `docs/01_enveloppes_france.md` et `docs/connaissances/banquier.md`.

## K1.0 Synthèse : couverture actuelle de `godot/data/`

| Fichier | Couvre | Manque pour 1950-1977 | Manque pour l'après-2025 |
|---|---|---|---|
| `regles.json > impots` | 1978 → 2018+ | Barème avant 1978 (tableau K1.3) | — |
| `regles.json > frais` | 1978 → 2019+ | Courtage 1950-1977 | — |
| `regles.json > agios` | 1970 → 2009+ | 1950-1969 | — |
| `salaires.json > table` | 1975 → 2025 | 1950-1974 (lignes tous les 5 ans) | 2026+ |
| `salaires.json > depenses` | 1970 → 2010+ | 1950-1969 (loyer, épargne) | — |
| `series.json`, `periode_p1.json` | Indice, inflation, Livret A, taux long (voir B1 du boursier) | Livret A avant 1960, plafonds avant 1966 | — |
| Livret A (taux et plafond) | 1960 → 2026 dans docs/01 §4.1-4.2 | 1950-1959 (≈ 2,75 % à 3 %, B/C), plafonds avant 1966 (C) | 2026+ |
| Monnaie | F / € (devise dans `salaires.json`) | Ancien franc (AF), nouveau franc (NF) | — |

## K1.1 Monnaie

| Date | Événement | Règle de jeu proposée | Cert. |
|---|---|---|---|
| Jusqu'au 31/12/1959 | Franc dit « ancien franc » (AF). Salaires et livrets en dizaines de milliers de francs | Affichage en F avec les montants anciens (ex. 400 000 F), ou en « NF équivalents » avec pastille « ancien franc » | A |
| **01/01/1960** | **Nouveau franc (NF) : 1 NF = 100 AF** | Basculer l'affichage à cette date, avec une notification « Le franc perd deux zéros » ; une partie qui chevauche 1960 voit la conversion | A |
| 1963 | « Nouveau » disparaît du libellé (le franc reste le franc) | Aucun effet de jeu | B |
| 1960-1970 | Beaucoup de Français continuent à compter en « anciens francs » : **décalage « mental »** | Bulle « Le saviez-vous ? » (H13 du plan) | B |
| 01/01/1999 | Euro scriptural : 1 € = 6,55957 F ; double affichage 1999-2001 | Voir base §2.1 et docs/03 §2.5 | A |
| 01/01/2002 → 17/02/2002 | Billets et pièces ; franc retiré le 17/02/2002 (cours légal) | Modale de l'euro (01/2002) | A |
| En interne | Euros courants (docs/03 §2.5) ; **convertir les séries 1950-1959 en euros** : 1 € = 6,55957 F = 655,957 AF | Les montants en AF s'affichent ×655,957 € pour le moteur | A |

## K1.2 Produits accessibles à un particulier, par décennie

Légende « Jeu » : présenté dans les chapitres actuels (P1 1978-1992, P2, P3) ; « Candidat » : à envisager dans un chapitre avant 1978 ; « Silhouette » : décor ou bulle.

| Décennie | Produits et supports (date d'apparition) | Accès | Jeu / Candidat | Cert. |
|---|---|---|---|---|
| **1950-1959** | Livret A (Caisses d'épargne, **Caisse nationale d'épargne** de La Poste) ; **bons du Trésor**, bons de caisse ; emprunt **Pinay 1952** (3,5 %, exonéré, **indexé sur le napoléon**), emprunt Pinay-Rueff **1958** ; actions et obligations par **agent de change** (monopole, courtage fixe) ; **or** (napoléons, lingots : marché libre) ; assurance-vie « classique » en francs (contrats de capitalisation) ; la **Poste** (comptes chèques postaux) ; **« Bons de la Caisse »** | Guichets d'épargne ; agents de change réservés à une minorité (clientèle aisée) | Candidat | B (Pinay 1952 A, le reste B) |
| **1960-1969** | **SICAV (décret du 20/09/1963 ; premières en 1964)** ; **CEL (1965)** et **PEL (décret du 24/12/1969)** ; FCP (loi du 13/03/1957 : B) ; obligations convertibles (C) ; **Livret B** (taux supérieur, C) ; **bancarisation** des salaires (1967 : obligation de compte au-delà de 1 500 F/mois, B) | Banques : seules les banques de dépôt (BNP, CCF, Société Générale, Crédit Lyonnais) ; Livret A partout | Candidat | A (SICAV, CEL, PEL), B (le reste) |
| **1970-1977** | **SCPI (loi du 31/12/1970)** ; **emprunt Giscard 7 % indexé sur l'or (01/1973)** ; **SMIC (02/01/1970)** remplaçant le SMIG ; **COB (1967)** ; **mensualisation** (1970-1978) ; épargne-logement (CEL/PEL) en essor ; **Livret jeune** (1970, B) ; **réforme bancaire de 1966-1967** (déspécialisation) ; **chèque** et carte bancaire (cartes CB dès 1967-1970, B) ; **taxe forfaitaire sur l'or (1976)** (C) ; **chocs pétroliers 10/1973 et 1979** | Banques généralistes, agences de quartier | Candidat | A / B |
| **1978-1989** | Déjà documenté : Monory (07/1978), CEA (1983-1988), **LEP (1982), Codevi (1983)**, assurance-vie (essor 1983-1988), **titres dématérialisés (11/1984)**, **loi du 22/01/1988** (fin du monopole des agents de change ; sociétés de bourse), **PER « 1988 »** ; **privatisations 1986-87** | Banques + guichets ; agents de change jusqu'à 1988-1989 | **Jeu P1** | A |
| **1990-1999** | **PEP (1990)**, **PEA (loi du 16/07/1992)**, Madelin (1994), **SICAV monétaires** (1987-1995), **FCPE**, **privatisation de France Télécom (10/1997)**, **euro (01/1999)**, courtiers en ligne (dès 1997-1999 : Bourse Direct, Boursorama 1998) | Banques, Minitel, courtiers en ligne à partir de 1998 | **Jeu P2** | A / B |
| **2000-2009** | **ETF à Paris (01/2001)** ; **PERP (2003)** ; **Livret A dans toutes les banques (01/01/2009)** ; **LDD (2007)** ; **loi Fillon (2003)** ; **SRD (09/2000)** ; **AMF (2003)** ; **impôt de bourse supprimé (01/01/2008)** | Banque, courtier en ligne, Bourse en ligne, PEA | **Jeu P2** | A |
| **2010-2019** | **PEA-PME (2014)**, **PFU (01/01/2018)**, **IFI (2018)**, **TTF (2012)**, **loi PACTE (22/05/2019)** : PER (01/10/2019), **PEA jeune (2019)** ; **néo-courtiers** (2017+) ; **LDDS (2017, plafond 12 000 €)** ; **fonds euros en forte baisse** | Application mobile, courtiers à 1 € | **Jeu P3** | A |
| **2020-2025** | **Plafonnement des frais de PEA (07/2020)** ; **flambée des taux 2022-2023** (Livret A 3 %, LEP 6,1 %) ; **LEP plafond 10 000 € (01/10/2023)** ; **TTF 0,4 % (01/04/2025)** ; **PFU 31,4 % (2026, B)** | Courtiers en ligne, banques | **Jeu P3** | A / B |

Rappel (anachronismes) : voir base §4 ; ne pas offrir SICAV avant 1964, ETF avant 2001, PEA avant 07/1992, Livret A dans toutes les banques avant 2009, etc.

## K1.3 Taux réglementés et plafonds

### K1.3.1 Livret A, 1950-1977

| Date d'effet | Taux | Plafond | Cert. |
|---|---|---|---|
| 1950 → 1953 | **≈ 2,75 %** (une série donne 2,75 % pour 1950-1953 ; la base retenait 2,5 %) | **≈ 300 000 AF** (nouveau Code des caisses d'épargne de 1952), puis **400 000 AF** | B (taux), C (plafond, une seule source) |
| 1954 → 1958 | 2,75 % (2,5 % en 1955, une série) | 400 000 AF ≈ 4 000 NF | B / C |
| 1959 → 1960 | ≈ 3,0 % | 4 000 NF (après le 01/01/1960) | B / C |
| 01/01/1960 | 3,25 % | 4 000 NF (C ; les paliers jusqu'à 15 000 F en 1966 ne sont pas documentés ici) | B |
| 01/01/1966 | 3,00 % | **15 000 F** | B (taux), A (plafond) |
| 01/01/1968 | 3,50 % | 15 000 F | B |
| 01/06/1969 | 4,00 % | 15 000 → 20 000 F (09/08/1969) | B / A |
| 01/01/1970 | 4,25 % | 20 000 F | B / A |
| 01/07/1973 | 4,25 % | 22 500 F | A |
| 01/01/1974 | 6,00 % | 25 000 F | B / A |
| 01/01/1975 | 7,50 % | 25 000 F | B / A |
| 01/01/1976 | 6,50 % | 32 500 F | B / A |
| 15/11/1977 | 6,50 % | 38 000 F | B / A |

**Correction à `docs/01` §4.2 / base §3** : le plafond « avant 1966 ≈ 1 000 000 AF (10 000 NF) [C] » est **probablement trop haut** pour 1952-1960 : une source cite 300 000 puis 400 000 AF (soit 4 000 NF). À traiter comme C. **Taux 1950-1959 : retenir 2,75 % (B) au lieu de 2,5 % (C)** pour les tables à créer ; l'écart est faible (0,25 pt).

### K1.3.2 Autres produits avant 1978

| Produit | Paramètres connus | Cert. |
|---|---|---|
| CEL (1965) | Taux ≈ 2,5-3,5 %, prêt immobilier associé ; plafond ≈ 15 000 → 20 000 F (C) | C |
| PEL (décret du 24/12/1969) | Épargne sur 4-5 ans, prêt à taux fixe + prime d'État (la prime est dans la base 1983-1986 ; avant 1978 : taux ≈ 4,5-6,0 % hors prime, C) | C |
| Emprunt Pinay (1952) | 3,5 %, exonéré d'impôt, remboursement indexé sur le napoléon (or) : forte hausse du capital | A (nature), B (taux) |
| Emprunt Giscard (01/1973) | 7 %, indexé sur le lingot d'or, 15 ans ; remboursé 01/1988 | A |
| SICAV | 1964 ; frais d'entrée ≈ 2-3 % | A / C |
| Agents de change | Courtage fixe ≈ 1 à 1,5 % tout compris (C) ; impôt de bourse ≈ 0,3 % | C |

### K1.3.3 Livret A, taux et plafonds après 1978, LEP, PEL, plafonds PEA

Voir `docs/01` §4.1-4.3 et base §2.3-2.4 (non répétés ici). Données prêtes à coder déjà dans le jeu pour 1978-2025.

## K1.4 Fiscalité simplifiée à prolonger avant 1978 (table de `regles.json`)

Table actuelle : `de: 1978 → cto 16 ; 1992 → pea5 0 ; 1998 → cto 26, pea5 11 ; 2008 → cto 30, pea5 13 ; 2013 → cto 35, pea5 15.5 ; 2018 → cto 30, pea5 17.2`.

| Période | Fiscalité réelle (résumé) | Taux unique proposé pour `impots.cto` | Cert. | Remarque |
|---|---|---|---|---|
| 1950-1964 | Retenue à la source sur revenus de valeurs mobilières (≈ 18-24 %) puis barème ; plus-values mobilières **non imposées** ; Livret A et emprunt Pinay exonérés | **≈ 15 %** sur dividendes et coupons ; **0 %** de plus-value | C | Pas d'avoir fiscal ; taux des dividendes et RVM : à vérifier (CGI historique) |
| 1965-1977 | **Avoir fiscal 50 % (1965-2004)** sur dividendes ; **prélèvement libératoire sur obligations** (≈ 25 %, C) ; **plus-values non imposées** (sauf spéculation) ; barème de l'IRPP très progressif (jusqu'à 60 % et plus) | **≈ 15-16 %** en convention de jeu (aligner sur la ligne 1978 pour éviter une rupture) | C | Prolonger `de: 1950 → cto 16, pea5 null` est le plus simple : **valeur identique à 1978 (A6)** |
| 1978-1991 | Plus-values imposées au-delà d'un seuil (loi du 05/07/1978) | 16 % | A (jeu) | Déjà dans `regles.json` |
| Prélèvements sociaux | 0 % avant 1991 ; CSG 1991 | voir base §2.5 | A | Pas de ligne séparée dans `regles.json` |

**Recommandation** : ajouter une seule ligne `{ "de": 1950, "cto": 16, "pea5": null }` (cohérence avec 1978-1991) plutôt que de modéliser un barème inconnu ; ajouter la bulle « Simplifié : les gains en Bourse n'étaient pas imposés avant 1978. »

## K1.5 Frais de courtage et de gestion avant 1978

| Période | Courtage (tout compris) | Minimum | Autres frais | Cert. |
|---|---|---|---|---|
| 1950-1977 | ≈ 1,0 à 1,5 % de l'ordre (agent de change, **courtage fixé par barème**) | ≈ 5-10 F (C) | Impôt de bourse ≈ 0,3 % | C |
| `regles.json` actuel | 1,3 %, min 7,62 € (50 F) dès 1978 | — | — | décision client |
| SICAV (1964+) | Entrée 2-3 % ; gestion annuelle ≈ 1-1,5 % | — | — | C |

**Recommandation** : étendre la ligne `{ "de": "1978-01", "taux": 1.3, "min": 7.62245 }` en `{ "de": "1950-01", "taux": 1.3, "min": 0.76 }` (minimum ≈ 5 F de 1960 = 0,76 € ; **chiffre à recaler** selon `salaires.json`, C).

## K1.6 Salaires et dépenses 1950-1974 (manquants)

| Repère | Valeur | Cert. | Remarque |
|---|---|---|---|
| SMIG créé le 11/02/1950 ; **SMIC le 02/01/1970** | Salaire minimum légal | A | |
| Salaire moyen net | À fournir (INSEE séries longues, Fourastié) ; base 1975 de `salaires.json` : smn 2 500 F | C pour 1950-1974 | **Demande : boursier + banquier, source INSEE à citer** |
| Inflation 1950-1959 | ≈ 10 % / 16 % / 12 % / −1,5 % / 0,4 % / 1 % / 2 % / 3 % / 15 % / 6 % | C | docs/01 §4.4 |
| Baguette avant 1961 | Voir docs/01 §7.3 bis | C | |

Si le client veut ouvrir 1950-1977 : prévoir un lot « séries 1949-1977 » (boursier : indice, dividende, taux long) et ce document (banquier : salaires, dépenses, loyers).

## K1.7 Frais de gestion, droits de garde, frais de tenue de compte (toutes périodes)

Non modélisés en V1 (docs/03 §9). Repères si demandés :

| Période | Droits de garde | Tenue de compte | Cert. |
|---|---|---|---|
| 1950-1983 | Titres papier : coffre, coupons à détacher ; frais de garde ≈ 0,2-0,3 %/an | Compte chèque gratuit (Poste) ou frais modestes | C |
| 1984-2000 | Titres dématérialisés (11/1984) : droits de garde ≈ 0,1-0,3 % | Frais fixes ≈ 15-45 F/an | C |
| 2000-2018 | 0,2-0,4 %/an hors PEA ; PEA : 15-30 € ou 0,3 %/an | 0-4 €/mois | B |
| 2019-2025 | Banque en ligne : 0 € ; réseau : 0,2-0,4 %/an ; PEA plafonnés 07/2020 | 0-3 €/mois | B |

## K1.8 Ce qui est déjà dans `godot/data/`, ce qui manque, par décennie (synthèse)

| Décennie | Données de règles | Salaires | Livret A | Fiscalité | Monnaie | Manque principal |
|---|---|---|---|---|---|---|
| 1950-59 | non | non | non (B/C ici) | non | AF/NF : non | Tout : K1.3, K1.4, K1.5, K1.6 ; séries boursières (B1) |
| 1960-69 | non | non | partiel dans docs/01 | non | NF : non | idem + CEL/PEL/SICAV (01) |
| 1970-77 | `agios` dès 1970, `depenses` dès 1970 | 1975 | docs/01 | non | F | Lignes 1970-1974 de salaires ; courtage |
| 1978-89 | oui | oui | oui | oui | F | Rien de majeur (PEL 1984-1988 : voir base) |
| 1990-99 | oui | oui | oui | oui | F → € (1999) | Double affichage 1999-2001 |
| 2000-09 | oui | oui | oui | oui | € | Rien |
| 2010-19 | oui | oui | oui | oui | € | Rien |
| 2020-25 | oui | oui (voir K2.6) | oui | oui | € | Ligne 2023 de salaires, PER (K2) |

---

# Sources principales

- Taux et historique PEL / CEL : La Finance pour tous, « Historique des taux de rendement et de prêt des PEL et des CEL » — https://www.lafinancepourtous.com/pratique/credit/credit-immobilier/le-pret-du-pel-et-du-cel/historique-des-taux-de-rendement-et-de-pret-des-pel-et-des-cel/ (A)
- Taux des fonds euros : ACPR, « Revalorisation 2019 / 2022 des contrats individuels » (https://acpr.banque-france.fr/system/files/import/acpr/medias/documents/20201013_as_115_revalorisation_2019_contrats_individuels.pdf, .../as_revalorisation_2022_contrats_individuels.pdf) ; Boursorama / France Assureurs pour 2023 (2,6 %) — https://www.boursorama.com/patrimoine/actualites/assurance-vie-les-fonds-en-euros-ont-rapporte-en-moyenne-2-60-en-2023-a2cb8beb27f941f0b996d6a3acda7d39 (A pour 2019, 2022, 2023)
- Salaires : INSEE Première n° 1863 (2019), n° 1971 (2022), ECRT2025 (2023) — https://www.insee.fr/fr/statistiques/fichier/version-html/5396066/ip1863.pdf ; https://www.insee.fr/fr/statistiques/fichier/7707884/ip1971.pdf ; https://insee.fr/fr/statistiques/fichier/7456921/ECRT2023-F29.pdf
- PEA, loi PACTE, PEA jeune : Crédit Agricole (https://www.credit-agricole.fr/particulier/conseils/magazine/tout-un-mag/avant-et-apres-la-loi-pacte-ce-qui-change-pour-votre-pea.html) ; Legifiscal (https://www.legifiscal.fr/placements/epargne/bourse-pea/pea-jeunes.html) (A)
- Assurance-vie, fiscalité des rachats : Legifiscal (https://www.legifiscal.fr/placements/immobilier/fiscalite-9.html), Moneyvox (https://www.moneyvox.fr/assurance-vie/fiscalite-rachat.php), AFER 2019-2022 (A)
- LEP / LDDS : Legifiscal (https://www.legifiscal.fr/actualites-fiscales/3565-plafond-lep-livret-epargne-populaire-passe-10-000-euros-1ier-octobre-2023.html) ; Boursorama / Caisse d'Épargne pour le LDDS 12 000 € (A)
- Courtage : Guide de la Banque, Pricebank, Finance Héros, tarifs relevés en 2026 (C pour 2019) ; AMF, étude 2015 sur les frais de courtage (A, déjà dans la base)
- Livret A 1950-1960 : Selectra, « Historique du Livret A » (https://selectra.info/finance/guides/livrets-epargne/livret-a/historique) et Toutsurmesfinances (https://www.toutsurmesfinances.com/placements/taux-livret-a.html) (B/C, sources secondaires sans référence au Journal officiel)
- Autres : `docs/01_enveloppes_france.md`, `docs/connaissances/banquier.md`, `godot/data/salaires.json`, `godot/data/regles.json` (état au 2026-11-18)

## Points à confirmer par une source primaire (si le client souhaite fiabiliser)

| Point | Certitude actuelle | Source à consulter |
|---|---|---|
| Taux moyen des fonds euros 2020 et 2021 | B | ACPR, rapports de revalorisation 2020 et 2021 |
| Plafond de ressources LEP 2019-2020 | C | Légifrance, avis de la DGFiP |
| Livret A 1950-1965 (taux, plafond) | B/C | Journal officiel, Caisse des Dépôts, annuaires statistiques |
| Fiscalité des valeurs mobilières 1950-1977 | C | CGI historiques, IGPDE |
| SMIC net 2019-2023 | B | Décrets annuels du JO |
| Date d'ouverture du PEA chez les néo-courtiers | C | Communiqués des courtiers, REGAFI |
| Valeurs salariales 2025 | C | INSEE (publication 2026) |
