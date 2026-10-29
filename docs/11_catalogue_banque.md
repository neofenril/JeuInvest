# 11 — Catalogue de la banque, progression du joueur et répliques de M. Lefranc

> Rédigé par le banquier le 2026-10-26, complété le 2026-10-27, en réponse aux retours du joueur réel (`10_retours_joueur.md`, sections du 26 et du 27/10) et aligné sur les arbitrages du client pour la démo V2 (`12_arbitrages_v2_demo.md` : **01/1984 → 12/1988, Gérard**). Pour la démo, lire d'abord §1.7, §2.5, §4.0 et §5.
> Demande du joueur : un banquier **didactique** qui **propose** des produits **adaptés au profil**, avec des **explications concrètes** ; une **liste de produits bien plus grande** ; d'**autres enveloppes**, dont l'**assurance-vie** et ses **avantages successoraux** (surtout pour les parents) ; une **introduction progressive** qui commence par le Livret A, puis présente chaque produit avec ses avantages et inconvénients **par rapport à ce que le joueur connaît et utilise déjà**.
> Ordre de priorité des sources : `docs/sources/` (vide à ce jour) > 03 > 01 et 02 > recherche web. Les sources web consultées sont au §9.
> Certitude : **A** vérifié (texte officiel ou plusieurs sources concordantes), **B** probable (une source fiable, ou ±1 an), **C** reconstitué (ordre de grandeur, calibrage de jeu).

---

## 0. Ce que ce document change, et ce que le client doit trancher

| # | Point | Situation | Ma proposition | Statut |
|---|---|---|---|---|
| D1 | Rôle du banquier | Le joueur veut qu'il **propose** selon le profil | **Tranché** par le client (12 §2.1-2.3, A37) : le banquier choisit quoi présenter et quand, le joueur décide ; 3 boutons « Ouvrir / Pas maintenant / En savoir plus » ; jamais « vous devriez », jamais de prévision. **Pas de questionnaire de risque** (validé par le joueur le 2026-10-27) : l'adaptation se fait **uniquement sur la situation de vie**. Je m'aligne (§3). | Tranché |
| D2 | Périmètre produits | A15 excluait l'assurance-vie, le LEP, le Codevi, l'or | **Tranché** pour la démo (12 §3.3, A36) : 9 lignes, dont l'assurance-vie ; LEP, Codevi, CEL, SICAV monétaires en silhouette. Les catalogues complets (§1.2 à §1.6) servent au jeu complet. | Tranché |
| D3 | Le Livret A dans « la banque de la rue » en 1984-1988 | Le Livret A n'est distribué **que** par les Caisses d'épargne et La Poste (Livret bleu au Crédit Mutuel) [A] ; une BNP ou une Société générale ne peut pas l'ouvrir | Banque **générique** qui regroupe tous les guichets, avec une bulle (?) : « Simplifié : en 1984, le Livret A s'ouvrait à la Caisse d'épargne ou à la Poste ; toutes les banques ne le proposent que depuis 2009. » | Client (je recommande cette option) |
| D4 | Gérard et Sylvie sont-ils **mariés** ? | 12 §3.2 dit « en couple » | Le choix change l'argument de l'assurance-vie (§1.7.3) : **non mariés**, Sylvie n'hérite de rien et paierait 60 % sur un legs ; **mariés**, en présence d'un enfant, elle ne reçoit par la loi que l'usufruit d'un quart (droit d'avant 2001). Dans les deux cas, l'assurance-vie qui la désigne est l'argument le plus concret avec l'argent réel du joueur. Je recommande **non mariés** (plus parlant, et le mariage reste en V2). | Client |
| D5 | Fiscalité des rachats d'assurance-vie | Rien | Démo : **règle réelle** des contrats 1983-1989 (45 / 25 / 15 / 0 % selon l'âge du contrat, §1.7.2), car c'est elle qui enseigne la durée de détention ; jeu complet : règle « taux unique » (§1.3.5) | Client |

---

## 1. Catalogue des produits d'une banque de réseau

### 1.0 Conventions communes (pour le développeur)

**Échelle de risque (perte possible en capital), de 1 à 5**

| Note | Signification | Exemples |
|---|---|---|
| 1 | Capital garanti, valeur qui ne baisse jamais | Livret A, Codevi, LEP, CEL, PEL, compte à terme, SICAV monétaire (quasi) |
| 2 | Capital garanti par un assureur (pas par l'État), ou presque sans variation | Assurance-vie fonds en francs / en euros |
| 3 | Valeur qui varie avec les taux d'intérêt ; capital rendu seulement à l'échéance | Obligations, emprunt d'État, SICAV obligataire |
| 4 | Valeur très variable, mais diversifiée | SICAV actions, assurance-vie en unités de compte, ETF, or |
| 5 | Une seule entreprise : perte forte ou totale possible | Action en direct, y compris les privatisations |

**Échelle de liquidité**

| Code | Signification |
|---|---|
| L0 | Disponible tout de suite, sans frais |
| L1 | Disponible en quelques jours (vente de SICAV, rachat d'assurance-vie) ; peut coûter des frais ou de l'impôt |
| L2 | Bloqué jusqu'à une échéance ; une sortie anticipée coûte (pénalité, perte de prime, impôt) |
| L3 | Bloqué : un retrait **ferme** le produit (PEL ; PEA avant 8 ans jusqu'en 2019) |

**Fiscalité « jeu »** : on garde la table « taux unique » de A6 (16 % hors PEA de 1978 à 1997, 26 % de 1998 à 2007, etc.). Les produits exonérés le sont à 0 %. La fiscalité réelle est donnée pour les bulles (?).

**Monnaie** : montants en francs (F) jusqu'en 1998, comme à l'écran. Pour le moteur : euros courants (÷ 6,55957).

### 1.1 Qui distribuait quoi en 1986-1988

| Guichet | Ce qu'on y trouvait | Cert. |
|---|---|---|
| **Caisse d'épargne**, **La Poste** (Caisse nationale d'épargne) | Livret A (monopole avec le Crédit Mutuel, sous le nom de Livret bleu), LEP, CEL et PEL, SICAV « maison », assurance-vie (CNP, filiales des Caisses), bons d'épargne | A / B |
| **Banque de réseau** (BNP, Crédit lyonnais, Société générale, Crédit agricole, CIC…) | Compte chèques, carte bleue, compte sur livret **imposable**, Codevi, LEP (selon le réseau, C), CEL et PEL, comptes à terme et bons de caisse, bons du Trésor, OAT, SICAV et FCP maison (monétaires, obligataires, actions), ordres de bourse **transmis à un agent de change** (jusqu'à la loi du 22/01/1988), souscription aux **privatisations** au guichet, or (napoléons, lingots), **assurance-vie de la filiale** (bancassurance : Predica pour le Crédit agricole en 1986, Cardif, Sogecap…) | A / B |
| **Assureurs et associations** | Assurance-vie (UAP, AGF, GAN, AFER créée en 1976) | A |

Les années 1986-1988 sont celles du « capitalisme populaire » (privatisations), du **boom des SICAV monétaires** (424 Md F d'encours en 1987, sur 822 Md F de SICAV [A, rapport du Sénat]) et de **l'essor de l'assurance-vie** portée par des fonds en francs à 10 % et plus.

### 1.2 P1 (1978-1992) : frise des disponibilités

| id | Produit | Disponible de | à | Remarque | Cert. |
|---|---|---|---|---|---|
| `compte_courant` | Compte chèques | départ | — | Rémunération interdite jusqu'en 2005 | A |
| `livret_a` | Livret A | départ | — | Caisse d'épargne, Poste (voir D3) | A |
| `livret_bancaire` | Compte sur livret bancaire | départ | — | Imposable | B |
| `cel` | Compte épargne logement | départ (1965) | — | | A |
| `pel` | Plan épargne logement | départ (1969) | — | Taux fixé à l'ouverture | A |
| `compte_terme` | Compte à terme, bon de caisse | départ | — | Imposable | B |
| `bon_tresor` | Bon du Trésor sur formule | départ | 31/12/1998 (fin d'émission) | Anonymat possible contre un prélèvement lourd | B |
| `emprunt_etat` | Emprunt d'État, puis OAT (1985) | départ | — | Produit V1 existant (A13) | A |
| `sicav_monetaire` | SICAV monétaire (« de trésorerie ») | ≈ 1981 | — | Boom de 1983 à 1990 | C (date), A (boom) |
| `sicav_obligataire` | SICAV obligataire | départ | — | | A |
| `sicav_actions` | SICAV actions françaises | départ | — | Produit V1 existant | A |
| `sicav_monory` | Achats « Monory » (déduction de 5 000 F) | 07/1978 | 12/1981 | « Le saviez-vous ? » (A6 : sans effet) | A |
| `actions` | Actions en direct | départ | — | Agent de change jusqu'au 22/01/1988 | A |
| `privatisation` | Offres publiques de vente | 11/1986 | 1988 (reprise en 1993) | Saint-Gobain : mise en vente le 24/11/1986, 310 F | A |
| `lep` | Livret d'épargne populaire | 1982 (taux connu au 14/01/1983) | — | Sous conditions de ressources | A |
| `codevi` | Codevi | ≈ 10/1983 (loi du 08/07/1983, décret du 30/09/1983) | — (LDD en 2007) | | A |
| `cea` | Compte d'épargne en actions (Delors) | 1983 | **31/12/1988** (prorogé d'un an par la loi de finances rectificative du 30/12/1987) | Réduction d'impôt de 25 % | A/B |
| `av_fonds_francs` | Assurance-vie, fonds en francs | départ | — | Contrats bancaires surtout après 1985 | A |
| `av_uc` | Assurance-vie multisupport (unités de compte) | 1981 (Triplan de Cardif, premier multisupport d'un réseau bancaire) | — | Rare avant 1990 | B |
| `per_1988` | Plan d'épargne retraite (loi du 17/06/1987) | 01/01/1988 | 31/12/1989 (remplacé par le PEP) | Versements déductibles : 8 000 F (16 000 F pour un couple marié) | B |
| `pep` | Plan d'épargne populaire | 01/1990 | 25/09/2003 | | A |
| `or` | Napoléons, lingots | départ | — | | A |
| `pea` | PEA | 16/07/1992 | — | Produit V1 existant | A |

### 1.3 P1 en détail : paramètres pour 1986-1988

#### 1.3.1 Tableau de paramètres (valeurs de 09/1986 à 12/1988)

| id | Rendement 1986 / 1987 / 1988 | Plafond | Frais | Fiscalité réelle 1986-1988 | Fiscalité jeu | Liquidité | Risque | Cert. |
|---|---|---|---|---|---|---|---|---|
| `compte_courant` | 0 % | — | Aucun (tenue de compte gratuite à l'époque, B) | — | — | L0 | 1 (mais érodé par l'inflation : 2,6 / 3,1 / 2,7 %) | A |
| `livret_a` | **4,5 %** (depuis le 31/05/1986) | **72 000 F**, puis **80 000 F au 30/06/1987** | Aucun | Exonéré | 0 % | L0 | 1 | A |
| `codevi` | 4,5 % (aligné sur le Livret A) | 10 000 F | Aucun | Exonéré | 0 % | L0 | 1 | B (taux), C (plafond) |
| `lep` | **5,5 %** (depuis le 16/05/1986) | **20 000 F** (depuis 04/1984) | Aucun | Exonéré ; réservé aux foyers peu ou pas imposés | 0 % | L0 | 1 | A (taux), B (plafond), C (condition) |
| `cel` | 2,75 % hors prime (ouvert depuis le 16/05/1986), plus une prime d'État | 100 000 F | Aucun | Exonéré | 0 % | L0 (retraits partiels) | 1 | B |
| `pel` | **4,62 % hors prime, ≈ 6 % prime comprise**, fixé pour la vie du plan (ouvert du 16/05/1986 au 06/02/1994) | 400 000 F ; prime plafonnée à 10 000 F | Aucun | Exonéré ; **prime versée même sans prêt** (PEL ouverts avant le 12/12/2002) | 0 % | L3 (retrait = clôture ; avant 4 ans : prime perdue et taux réduit) | 1 | A (taux), B (prime) |
| `compte_terme` | ≈ 6-7 % selon la durée (1 mois à 2 ans) | — | Aucun | Imposable (prélèvement libératoire ≈ 25-27 %, C) | 16 % | L2 | 1 | C |
| `bon_tresor` | ≈ 7-8 % sur 5 ans, taux progressif | — | Aucun | Imposable ; anonymat possible contre un prélèvement très lourd | 16 % | L2 | 1 | C |
| `emprunt_etat` | Taux long : **9,1 / 9,5 / 9,1 %** (02 §4.2) | — | 0 % en jeu | Coupons imposables (barème ou prélèvement libératoire) | 16 % | Jeu : revente au nominal (A13) ; réel : au cours du jour | 3 (réel), 2 (jeu) | A (taux) |
| `sicav_monetaire` | ≈ **7 %** net de frais (taux monétaire ≈ 7,7 / 8,0 / 7,5 % moins ≈ 0,5 pt) | — | Entrée 0-1 % ; gestion ≈ 0,5 %/an | Plus-value à la vente, **exonérée si les cessions de l'année restent sous un seuil** (≈ 300 000 F, C) : en pratique non imposée pour la plupart des épargnants | 16 % (A6, bulle « Simplifié ») | L1 (48 h) | 1 | B (taux monétaires), C (net) |
| `sicav_obligataire` | Taux long − 1 pt de frais, plus l'effet prix (baisse quand les taux montent) | — | Entrée 1-2 % ; gestion ≈ 1 %/an | Comme la SICAV monétaire | 16 % | L1 | 3 | C |
| `sicav_actions` | Indice + dividende − 1,5 %/an (V1) | — | **Entrée 2 %** (jeu ; réel 2-4,5 % en réseau) ; gestion 1,5 %/an | Plus-values au-delà du seuil de cessions ; dividendes au barème avec avoir fiscal | 16 % | L1 | 4 | A (règle V1) |
| `actions` | Cours du marché + dividendes | — | **1,3 %, minimum 50 F** (V1, impôt de bourse compris) | Idem | 16 % | L1 | 5 | A (règle V1) |
| `privatisation` | Prix fixe de l'offre (Saint-Gobain 310 F) | Ordres réduits si trop de demande (« taux de service », hors V1) | Aucun frais à la souscription (B) | Idem ; **1 action gratuite pour 10 conservées 18 mois** (B) | 16 % | L1 après cotation | 5 | A (prix), B (gratuites) |
| `av_fonds_francs` | Contrat bancaire ≈ **11 / 9,75 / 9,5 %** net (AFER, meilleur élève : 11,51 / 10,35 / 10,05 %) | — | **Entrée 4 %** (réel 3-5 % en réseau) ; gestion incluse dans le taux net | Voir §1.3.5 ; **hors succession, sans droits** | Avant 6 ans : 16 % sur les gains ; après : 0 % | L1 (rachat en quelques jours) | 2 | A (AFER), B (réseau) |
| `or` | Aucun revenu ; suit le cours de l'or en francs (02) | — | Commission ≈ 2-3 % à l'achat et à la vente, plus le coffre | Taxe forfaitaire sur le **prix de vente** ≈ 6-7,5 % (C) | 7 % du prix de vente | L1 | 4 | C (taxe) |
| `cea` | Réduction d'impôt de 25 % des achats nets d'actions françaises, plafonnés à 7 000 F (14 000 F pour un couple marié), 5 ans sans désinvestissement | — | — | — | « Le saviez-vous ? » (pas d'impôt sur le revenu modélisé) | — | — | A/B |
| `per_1988` | Versements déductibles du revenu imposable | 8 000 F / 16 000 F par an | — | — | « Le saviez-vous ? » | L3 | selon les supports | B |

Repères pour le moteur : inflation 2,6 / 3,1 / 2,7 % (1986 / 1987 / 1988, 02) ; **le Livret A rapporte enfin plus que l'inflation** (+1,4 à +2,3 points réels), après trente ans presque toujours négatifs. C'est le premier message de M. Lefranc.

#### 1.3.2 Rendements annuels pour toute la P1 (1978-1992)

| Année | Livret A moyen | LEP | Taux long (OAT) | Taux monétaire (≈) | SICAV monétaire nette (≈) | Fonds en francs, contrat bancaire (jeu) | AFER (net) |
|---|---|---|---|---|---|---|---|
| 1978 | 6,5 | — | 10,6 | 8 | 7,5 | 10,0 | 10,55 |
| 1979 | 6,5 | — | 10,8 | 9 | 8,5 | 10,5 | 10,95 |
| 1980 | 7,25 | — | 13,8 | 12 | 11,5 | 12,0 | 12,54 |
| 1981 | 7,75 | — | 16,3 | 15 | 14,5 | 13,0 | 13,47 |
| 1982 | 8,5 | — | 16,0 | 14,5 | 14,0 | 14,25 | 14,78 |
| 1983 | 8,1 | 8,5 | 14,4 | 12,5 | 12,0 | 15,5 | 16,13 |
| 1984 | 7,1 | ≈ 8 | 13,4 | 11,5 | 11,0 | 12,5 | 12,98 |
| 1985 | 6,25 | ≈ 7,2 | 11,9 | 10 | 9,5 | 11,5 | 12,09 |
| 1986 | 5,0 | ≈ 6,1 | 9,1 | 7,7 | 7,0 | 11,0 | 11,51 |
| 1987 | 4,5 | 5,5 | 9,5 | 8,0 | 7,0 | 9,75 | 10,35 |
| 1988 | 4,5 | 5,5 | 9,1 | 7,5 | 7,0 | 9,5 | 10,05 |
| 1989 | 4,5 | 5,5 | 8,8 | 9 | 8,5 | 9,0 | 9,62 |
| 1990 | 4,5 | 5,5 | ≈ 10 | 10 | 9,5 | 8,75 | 9,22 |
| 1991 | 4,5 | 5,5 | ≈ 9 | 9,5 | 9,0 | 8,75 | 9,24 |
| 1992 | 4,5 | 5,5 | ≈ 8,6 | 10 | 9,5 | 8,75 | 9,27 |
| Cert. | A | A | A (02) | B/C, **à valider par le boursier** | C | C (règle : AFER − 0,5 pt, arrondi au quart de point) | **A** |

Règle de calcul du fonds en francs dans le jeu : taux de l'année crédité au 31/12 (intérêts courus au mois, comme le Livret A), **effet cliquet** (les intérêts crédités ne peuvent plus être perdus). Le fonds en francs « en retard » sur les taux du marché est voulu : il lisse, ce qui le rend plus rémunérateur que le marché quand les taux baissent (années 1980-1990) et moins quand ils montent (2022-2023).

#### 1.3.3 Ce qui est simplifiable sans trahir

| Réalité | Simplification proposée | Bulle (?) |
|---|---|---|
| Intérêts du Livret A par quinzaine | Prorata mensuel, crédité au 31/12 (V1) | — |
| Prime d'État du PEL versée à la clôture | Taux PEL de 6 % tout compris, crédité au 31/12 ; **clôture avant 4 ans = taux du CEL (2,75 %), sans prime** | « La prime d'État est comprise dans les 6 %. » |
| Versement minimal du PEL (≈ 3 600 F par an, C) | Versement mensuel choisi à l'ouverture, minimum 300 F, prélevé automatiquement | — |
| Fiscalité des rachats d'assurance-vie dégressive (45 / 25 / 15 / 0 %) | 16 % avant 6 ans, 0 % après (§1.3.5) | « Simplifié : en réalité 45 % avant 2 ans, 25 % de 2 à 4 ans, 15 % de 4 à 6 ans. » |
| Seuil de cessions qui exonère les petits porteurs | 16 % (A6) | Bulle A6 existante |
| Taux de service des privatisations, actions gratuites | Hors démo ; texte seulement | — |
| Prix des obligations | Revente au nominal (A13) | « Simplifié : en vrai, revendre avant l'échéance se fait au prix du jour, qui baisse quand les taux montent. » |
| Prime des napoléons sur l'or | Cours de l'or + 3 % | — |

#### 1.3.4 Droits de succession en 1986-1988 (pour les explications de M. Lefranc)

| Paramètre | Valeur en 1986-1988 | Cert. |
|---|---|---|
| Abattement par part, **conjoint et enfants (ligne directe)** | **275 000 F** (depuis le 01/01/1984 ; 300 000 F pour les enfants et 330 000 F pour le conjoint au 01/01/1992) | A |
| Barème en ligne directe, après abattement | 5 % jusqu'à 50 000 F ; 10 % de 50 000 à 75 000 F ; 15 % de 75 000 à 100 000 F ; **20 % de 100 000 à 3,4 MF** ; 30 %, 35 %, 40 % au-delà | A (tranche à 20 % dès 100 000 F), B (hautes tranches) |
| **Entre non-parents (concubins compris)** | **60 %** | A |
| Pacs | N'existe pas (1999) | A |

Exemple de référence (vérifié à la main) : un parent laisse 675 000 F à un enfant unique. Sans assurance-vie : 675 000 − 275 000 = 400 000 F taxables → 2 500 + 2 500 + 3 750 + 60 000 = **68 750 F de droits**. Si 400 000 F sont sur une assurance-vie qui désigne l'enfant : le reste (275 000 F) est couvert par l'abattement → **0 F**.

#### 1.3.5 L'assurance-vie, époque par époque (point le plus demandé)

**Ce qui était vrai en 1986-1988** (pour un épargnant de 22 à 40 ans) :

1. **Hors succession.** Le capital est versé directement au **bénéficiaire désigné** (clause bénéficiaire) et ne fait pas partie de la succession (Code des assurances, art. L. 132-12, principe de la loi du 13/07/1930) [A].
2. **Aucun droit de succession, quel que soit le montant**, pour les contrats souscrits avant le 20/11/1991 [A : réponse ministérielle publiée au JO du 06/09/1993]. Seule exception : depuis la loi de finances pour 1980 (art. 68), un premier article 757 B taxait, au-delà de **100 000 F**, les contrats souscrits **tard dans la vie** avec des primes concentrées sur les premières années (dispositif anti-abus) [A pour l'existence et le seuil, **C** pour les conditions exactes d'âge et de primes]. Il ne concerne pas un joueur de 22 à 40 ans. Restent aussi l'abus de droit et les primes « manifestement exagérées » (art. L. 132-13) [A].
3. **Fiscalité des rachats** (contrats souscrits du 01/01/1983 au 31/12/1989) : prélèvement libératoire optionnel de **45 % avant 2 ans, 25 % de 2 à 4 ans, 15 % de 4 à 6 ans, 0 % après 6 ans** ; contrats d'avant 1983 : exonérés [A/B]. Aucun prélèvement social (la CSG naît en 1991).
4. **Réduction d'impôt sur les primes** : 25 % des primes, dans la limite de **4 000 F par foyer + 1 000 F par enfant** (soit au plus 1 000 F + 250 F par enfant), pour les contrats d'épargne d'une durée minimale [B ; durée minimale C]. Supprimée par les lois de finances pour 1996 et 1997.
5. **Rendement** : fonds en francs à 10-11 % (AFER 11,51 % en 1986, A), capital garanti par l'assureur, effet cliquet.
6. **Frais** : 3 à 5 % à l'entrée dans les réseaux [B], gestion ≈ 0,5-1 % par an.
7. **Distribution** : assureurs, AFER, et désormais les banques via leurs filiales (Predica en 1986). Les multisupports existent (Triplan de Cardif en 1981) mais restent rares [B].

**Évolution ensuite** (pour P1 fin, P2 et P3) :

| Date | Changement | Effet pour le jeu | Cert. |
|---|---|---|---|
| 01/01/1990 | Contrats nouveaux : exonération après **8 ans** (35 % avant 4 ans, 15 % de 4 à 8 ans) | Maturité 8 ans pour les contrats ouverts à partir de 1990 | A/B |
| 30/12/1991 (loi n° 91-1323, art. 26) | Nouvel art. **757 B** : contrats souscrits **depuis le 20/11/1991**, primes versées **après 70 ans** soumises aux droits de succession au-delà de **200 000 F** (tous bénéficiaires confondus) ; les contrats plus anciens restent totalement exonérés | Sans effet pour les profils (moins de 70 ans) | A |
| 1991 → 1998 | Primes versées **avant 70 ans** : toujours **aucun droit**, quel que soit le montant | — | A |
| 26/09/1997 | Primes versées depuis cette date : après 8 ans, prélèvement de **7,5 %** au-delà d'un abattement annuel de 30 000 F (60 000 F pour un couple), soit 4 600 € / 9 200 € | Couvert par la simplification « taux du PEA » | A |
| 13/10/1998 (loi de finances pour 1999) | Art. **990 I** : au décès, prélèvement de **20 %** au-delà de **1 MF par bénéficiaire** (primes versées avant 70 ans) | Seuil hors de portée des profils | A (règle), B (n° de la loi) |
| 01/01/2002 | Conversion : 152 500 € (990 I) et 30 500 € (757 B), inchangés depuis | — | A |
| 2005 | Amendement Fourgous (passage en multisupport sans perdre l'antériorité) | — | B |
| 22/08/2007 (loi TEPA) | **Conjoint et partenaire de Pacs exonérés** de droits de succession et du 990 I | Argument « conjoint » obsolète, argument « enfants » intact | A |
| 31/07/2011 | 990 I : 25 % au-delà de 902 838 € | — | A |
| 01/07/2014 | 990 I : 20 % jusqu'à 700 000 € taxables, **31,25 %** au-delà | — | A |
| 27/09/2017 | PFU : gains taxés 12,8 % avant 8 ans ; 7,5 % après (12,8 % au-delà de 150 000 € d'encours) ; prélèvements sociaux 17,2 % | Simplification « taux du PEA » maintenue | A |
| 22/05/2019 (loi PACTE) | Transfert d'un contrat vers un contrat plus récent du même assureur sans perte d'antériorité | — | B |
| 01/01/2026 | Prélèvements sociaux à 18,6 %, **sauf assurance-vie, maintenue à 17,2 %** | Petite leçon « enveloppe » en 2026 | A/B |

**Règle de jeu proposée pour l'assurance-vie**

| Paramètre | P1 (1978-1992) | P2 (1996-2010) | P3 (2011-2025) |
|---|---|---|---|
| Support | Fonds en francs | Fonds en euros (+ unités de compte, plus tard) | Fonds en euros + UC « fonds indiciel » (plus tard) |
| Rendement | Tableau §1.3.2 | Tableau §1.5 | Tableau §1.6 |
| Frais d'entrée | 4 % | 3 % | 2 % en réseau (0 % en ligne, plus tard) |
| Maturité fiscale | Ouvert avant 1983 : 0 an ; 1983-1989 : **6 ans** ; dès 1990 : **8 ans** | 8 ans | 8 ans |
| Impôt sur les gains, avant maturité | 16 % (démo V2 : 45 / 25 / 15 % réels, §1.7.2) | Taux du compte-titres de l'année (26 / 30 %) | Taux du compte-titres (35 / 30 %) |
| Impôt sur les gains, après maturité | **0 %** | Taux du PEA > 5 ans (11 / 13 %) | Taux du PEA > 5 ans (15,5 / 17,2 %) |
| Droits de succession | **0 %, sans limite** | 0 % jusqu'à 1 MF puis 152 500 € par bénéficiaire, 20 % au-delà | 0 % jusqu'à 152 500 € par bénéficiaire, puis 20 % / 31,25 % |
| Liquidité | Rachat disponible le mois suivant | idem | idem |
| Risque | 2 | 2 (UC : 4) | 2 (UC : 4) |

Comme le jeu ne fait pas mourir le personnage, l'avantage successoral se montre **par les mots de M. Lefranc** (démo), puis par un **encadré « transmission » au bilan de fin** pour les joueurs parents (plus tard, §6) : « Si vous transmettiez votre patrimoine aujourd'hui : droits estimés sans assurance-vie / avec. »

### 1.4 Abattements successoraux en ligne directe (pour l'encadré « transmission », plus tard)

| Depuis | Abattement par enfant | Conjoint | Cert. |
|---|---|---|---|
| 01/01/1984 | 275 000 F | 275 000 F | A |
| 01/01/1992 | 300 000 F | 330 000 F | A |
| 01/01/2002 | 46 000 € | 76 000 € | B |
| 01/01/2006 | 50 000 € | 76 000 € | B |
| 22/08/2007 | 150 000 € | **exonéré** (TEPA) | A |
| 01/01/2011 | 159 325 € | exonéré | A |
| 17/08/2012 | **100 000 €** | exonéré | A |

### 1.5 P2 (1996-2010) : catalogue en bref

| id | Produit | Disponibilité | Paramètres simplifiés | Liquidité | Risque | Cert. |
|---|---|---|---|---|---|---|
| `livret_a` | Livret A | départ (toutes les banques le 01/01/2009) | 3,5 % (1996) … 4 % (08/2008) → 1,25 % (08/2009) ; plafond 100 000 F puis 15 300 € | L0 | 1 | A |
| `livret_jeune` | Livret jeune (12-25 ans) | 1996 | ≈ Livret A + 0,5 à 1 pt ; 10 000 F puis 1 600 € | L0 | 1 | B |
| `codevi` → `ldd` | Codevi, puis LDD (2007) | départ | = Livret A ; 30 000 F → 4 600 € → **6 000 €** (2007) | L0 | 1 | A |
| `lep` | LEP | départ | 4,75 % (1996) … 4,5 % (08/2008) → 1,75 % (2009) ; 40 000 F (1999) → 7 700 € | L0 | 1 | A/B |
| `pel` | PEL | départ | 3,84 % (1994-1997) → 2,5 % (2003-2015) hors prime ; **prime conditionnée à un prêt pour les PEL ouverts depuis le 12/12/2002** | L3 | 1 | A |
| `pep` | PEP | départ | Exonéré après 8 ans ; plus d'ouverture après le 25/09/2003 | L3 | 1-4 | A |
| `perp` | PERP | 2004 | Versements déductibles, sortie en rente (V2 : suppose la tranche d'impôt) | L3 | 2-4 | A |
| `emprunt_etat` | OAT | départ | Taux long de l'année (02) | jeu L1 | 3 | A |
| `sicav_monetaire` | SICAV monétaire | départ | Taux monétaire − 0,5 pt (≈ 3 % puis 0,5 % en 2010) | L1 | 1 | B/C |
| `sicav_actions` | SICAV actions | départ | V1 | L1 | 4 | A |
| `etf` | ETF CAC 40 | 01/2001 | V1 | L1 | 4 | A/B |
| `actions` | Actions ; France Télécom (10/1997, 182 F), EDF (11/2005, 32 €) | départ | V1 | L1 | 5 | A |
| `pea` | PEA | départ | V1 | L3 | 4-5 | A |
| `av_fonds_euros` | Assurance-vie fonds en euros | départ | 6,8 % (1996, AFER), ≈ 5,3 % (2000), 4,4 % (2004), 4,0 % (2008), 3,4 % (2010) (moyenne du marché, 01 §1.2) | L1 | 2 | A/B |
| `av_uc` | Assurance-vie multisupport (UC) | départ ; contrats « DSK » (1998) et « NSK » (2005) investis en actions [B] | Suit une SICAV ou un ETF − 0,8 %/an de frais de contrat | L1 | 4 | B |
| `or` | Or | départ | Taxe ≈ 8 % (7,5 % + 0,5 % de CRDS) | L1 | 4 | B |
| `courtier_en_ligne` | Courtage en ligne | 1996-1999 | Frais divisés par 3 à 5 (V1 : 0,8 % dès 2000) | — | — | B |

### 1.6 P3 (2011-2025) : catalogue en bref

| id | Produit | Paramètres simplifiés | Liquidité | Risque | Cert. |
|---|---|---|---|---|---|
| `livret_a` | 2,25 % (2011) → **0,5 % (02/2020)** → **3 % (02/2023)** → 1,7 % (08/2025) ; plafond **22 950 €** (01/2013) | L0 | 1 | A |
| `ldds` | = Livret A ; **12 000 €** (10/2012) ; LDDS en 2017 | L0 | 1 | A |
| `lep` | Jusqu'à **6,1 % (02/2023)** ; plafond **10 000 € depuis le 01/10/2023** | L0 | 1 | A/B |
| `pel` | 2,5 % → 1 % (08/2016) → 2 % (2023) ; **imposable (PFU) dès 2018** | L3 | 1 | A |
| `av_fonds_euros` | 3,0 % (2011) → 1,3 % (2020-2021) → 2,6 % (2023) → ≈ 2,5 % (2024-2025) | L1 | 2 | A/B |
| `av_uc` | Fonds indiciels (ETF) en UC, frais de contrat 0,5-1 %/an | L1 | 4 | B |
| `eurocroissance` | 2014 ; capital garanti à l'échéance seulement (curiosité) | L2 | 2-3 | A |
| `per` | 01/10/2019 ; versements déductibles (V2) | L3 | 2-4 | A |
| `pea`, `pea_pme`, `pea_jeune` | 150 000 € (2014) ; PEA-PME 225 000 € cumulés (2019) ; PEA jeune 20 000 € | L3 → L1 après 5 ans (PACTE) | 4-5 | A |
| `etf`, `actions` | V1 ; Française des Jeux (11/2019, 19,90 €) | L1 | 4 / 5 | A |
| `sicav_monetaire` | Rendement **négatif** de 2015 à 2021 (≈ −0,3 à −0,6 %), ≈ 3,5 % en 2023-2024 | L1 | 1 | B |
| `or` | Taxe 10 % + 0,5 % de CRDS (2014), puis 11 % + 0,5 % | L1 | 4 | B |
| `crypto` | Hors banque de réseau (V2, « tentation ») | L1 | 5 | B |

### 1.7 Démo V2 (01/1984 → 12/1988, Gérard) : paramètres exacts

#### 1.7.1 Les 9 lignes de la démo (12 §3.3), date par date

| Ligne | Paramètre | Valeurs datées | Cert. |
|---|---|---|---|
| Compte courant | Taux | 0 % | A |
| Livret A | Taux | **7,5 %** jusqu'au 15/08/1984 → **6,5 %** au 16/08/1984 → **6 %** au 01/07/1985 → **4,5 %** au 31/05/1986 | A |
| | Plafond | **58 000 F** (depuis le 02/04/1983) → **68 000 F** au 15/06/1984 → **72 000 F** au 31/05/1986 → **80 000 F** au 30/06/1987 | A |
| | Repère inflation | 7,4 % (1984), 5,8 % (1985), 2,6 % (1986), 3,1 % (1987), 2,7 % (1988) (02) : le Livret A passe d'un rendement réel nul (1984) à nettement positif (1986-1988) | A |
| PEL | Taux fixé **à l'ouverture**, hors prime / prime de l'État comprise | Ouvert du 01/1984 au 07/1984 : **6,30 % / ≈ 8,25 %** ; du 08/1984 au 06/1985 : **5,30 % / ≈ 7 %** ; du 07/1985 au 15/05/1986 : **4,75 % / ≈ 6 %** ; depuis le 16/05/1986 : **4,62 % / ≈ 6 %** | B (hors prime), C (prime incluse avant 1985 : calée sur le rapport 1986, ≈ × 1,3) |
| | Règles | Plafond 400 000 F ; prime plafonnée à 10 000 F et **versée même sans prêt** ; durée minimale 4 ans ; retrait = clôture ; clôture avant 4 ans = sans prime (jeu : taux hors prime) ; versement minimal ≈ 300 F par mois (C) ; exonéré d'impôt | B |
| Emprunt d'État 10 ans | Taux de la tranche = taux long de l'année d'achat (A13) | **13,4 %** (1984), **11,9 %** (1985), 9,1 % (1986), 9,5 % (1987), 9,1 % (1988) | A (02) |
| | Remarque | Avant 1985, l'État plaçait encore des emprunts « grand public » au guichet ; dès 1985, les OAT. Le coupon de 13,4 % acheté en 1984 reste acquis 10 ans : c'est la plus belle leçon « taux fixe » de la démo (en réalité, son prix a aussi fortement monté quand les taux ont baissé en 1985-1986 ; A13 l'ignore) | A/B |
| Assurance-vie fonds en francs | Taux net crédité au 31/12 | **12,5 %** (1984), **11,5 %** (1985), **11 %** (1986), **9,75 %** (1987), **9,5 %** (1988) ; repère AFER : 12,98 / 12,09 / 11,51 / 10,35 / 10,05 % | C (réseau = AFER − 0,5 pt), A (AFER) |
| | Frais | **4 %** sur chaque versement ; gestion incluse dans le taux net | B |
| | Fiscalité, succession | §1.7.2 | A/B |
| SICAV actions France | Règle V1 | Indice + dividende − 1,5 %/an ; entrée 2 % ; 16 % sur les gains | A (règle) |
| Actions Elf, L'Oréal, Peugeot | Règle V1 | Courtage 1,3 %, minimum 50 F ; 16 % | A (règle) |
| Saint-Gobain | Offre publique de vente | Mise en vente le **24/11/1986**, prix fixe **310 F**, privatisation effective en 12/1986 ; pas de courtage à la souscription (B) ; 1 action gratuite pour 10 conservées 18 mois (B, hors démo) | A / B |

#### 1.7.2 Assurance-vie : les règles exactes pour un contrat ouvert en 1985

| Sujet | Règle en vigueur de 1984 à 1988 | Cert. |
|---|---|---|
| Régime applicable | Contrats souscrits du **01/01/1983 au 31/12/1989** | A |
| Durée de détention | Horloge fiscale de **6 ans** à partir de la souscription (8 ans seulement pour les contrats ouverts à partir de 1990) | A/B |
| Rachat (retrait) | Seuls les **gains** contenus dans le retrait sont imposés, au barème de l'impôt sur le revenu ou, sur option, au **prélèvement libératoire de 45 % (contrat de moins de 2 ans), 25 % (2 à 4 ans), 15 % (4 à 6 ans), 0 % après 6 ans** | A/B |
| Calendrier pour un contrat ouvert en 04/1985 | 45 % jusqu'en 03/1987 ; 25 % de 04/1987 à 03/1989 ; 15 % de 04/1989 à 03/1991 ; **exonéré dès 04/1991**, après la fin de la démo | calcul |
| Prélèvements sociaux | Aucun (la CSG naît en 1991) | A |
| Au décès | Capital versé au **bénéficiaire désigné**, **hors succession** (C. assur. art. L. 132-12) et **sans aucun droit de succession, quel que soit le montant** (contrats antérieurs au 20/11/1991). Seule réserve : l'article 757 B de 1980 (contrats souscrits tard dans la vie, primes concentrées, au-delà de 100 000 F), sans objet pour Gérard | A (C pour le détail de 1980) |
| Clause bénéficiaire | Libre, modifiable à tout moment ; peut désigner une concubine, un enfant, n'importe qui | A |
| Délai de versement au bénéficiaire | Quelques semaines après la remise des pièces (le délai légal d'un mois date des années 2000) | B |
| Réduction d'impôt sur les primes | 25 % des primes, plafond 4 000 F + 1 000 F par enfant : **hors démo** (pas d'impôt sur le revenu modélisé) | B |

Formule de l'impôt sur un rachat (démo) : `gains_rachat = montant_rachat × (valeur_contrat − primes_nettes_restantes) / valeur_contrat` ; `impot = gains_rachat × taux(age_contrat)` ; ensuite `primes_nettes_restantes −= montant_rachat − gains_rachat`.

#### 1.7.3 Transmission : les règles de 1984-1988 pour chiffrer la comparaison (R6)

| Bénéficiaire | Par succession (ou par testament) | Par assurance-vie | Cert. |
|---|---|---|---|
| Enfant | Abattement 275 000 F, puis barème 5 / 10 / 15 / 20 % (§1.3.4) | 0 F de droits | A |
| Conjoint marié | Même abattement et même barème ; **mais**, en présence d'enfants, la loi ne lui donne que **l'usufruit d'un quart** (droit d'avant la loi du 03/12/2001) | 0 F de droits, et le capital en pleine propriété | A |
| **Concubin(e)** | **Aucun droit légal** ; par testament, **60 %** de droits | 0 F de droits | A |
| Neveu, nièce | Abattement de **10 000 F** par part (art. 788 CGI, « abattement minimum », en vigueur du 01/01/1974 à 1988 au moins), puis **55 %** | 0 F de droits | A |

Fonction pour le moteur (ligne directe, en francs, 1984-1991) :
```
droits_ligne_directe(part):
    x = max(0, part - 275000)
    tranches = [(50000, 0.05), (75000, 0.10), (100000, 0.15), (3400000, 0.20), (5600000, 0.30), (11200000, 0.35), (INF, 0.40)]
    cumule la taxe tranche par tranche sur x
droits_concubin(part) = 0.60 × part        # legs par testament
droits_neveu(part)    = 0.55 × max(0, part - 10000)   # abattement minimum de 10 000 F (art. 788, depuis 1974)
```

Comparaison à afficher avec **l'argent réel de Gérard** (exemple : 30 000 F d'épargne) :
- **Sylvie (non mariés)** : par succession **0 F** (elle n'hérite pas ; 12 000 F avec un testament, après 60 % de droits) ; par assurance-vie **30 000 F**.
- **L'enfant** : 30 000 F dans les deux cas (sous l'abattement). L'avantage fiscal pour l'enfant n'apparaît qu'au-delà de 275 000 F : on l'illustre avec l'exemple de §1.3.4 (675 000 F, dont 400 000 F en assurance-vie : **68 750 F** de droits évités). Ne pas prétendre le contraire : c'est une leçon d'honnêteté.

#### 1.7.4 L'héritage scripté de tante Odette (1988), version simplifiée « un seul pot » (coordinateur, 2026-10-27)

| Élément | Valeur retenue | Cert. |
|---|---|---|
| Lien | Tante **par le sang** (sœur d'un parent), veuve, sans enfant | — |
| Décès | **03/1988** | scénario |
| Assurance-vie d'Odette | Contrat ancien (souscrit en 1975), Gérard bénéficiaire : **60 000 F**, versés en **04/1988**, **0 F de droits**, pas d'impôt sur le revenu. **Plus de succession séparée** (les 100 000 F de la version précédente sont supprimés) | A (règle), C (montant) |
| Comparaison montrée par M. Lefranc | Les **mêmes 60 000 F** reçus par succession : abattement **10 000 F** (art. 788 CGI, depuis le 01/01/1974, toujours en vigueur en 03/1988), puis **55 %** sur 50 000 F = **27 500 F de droits**, soit **32 500 F nets**, six mois plus tard | A |
| Ordre de grandeur | Salaire de Gérard en 1988 ≈ 8 000 à 9 000 F nets : l'assurance-vie ≈ 7 mois de salaire | C |
| Leçon | Assurance-vie : 60 000 F tout de suite ; succession : 32 500 F six mois plus tard (0,54 F par franc ; chaque franc au-delà de 10 000 F ne laisse que 0,45 F) | A |
| Ignoré | Frais de notaire (≈ 2 à 3 %, C) | C |

> **Correction** : « 60 000 × 45 % = 27 000 F » est faux deux fois : 45 % donne le **net** (pas les droits) et oublie l'abattement de 10 000 F. Bons chiffres : **27 500 F de droits, 32 500 F nets**. Dans `banque.json`, supprimer `heritage.succession` et D08 bis, remplacer `{droits_pct} %` par les montants, et corriger la phrase « 1 F d'un côté, 0,45 F de l'autre ».

Texte D08 proposé (57 mots, « 60 000 F » compté pour 3) : « {prenom}, toutes mes condoléances pour votre tante Odette. Elle vous avait désigné sur son assurance-vie : 60 000 F, versés ce mois-ci, sans un centime de droits. Si cette somme était passée par sa succession, l'État aurait pris 27 500 F, car un neveu est peu favorisé : il vous serait resté 32 500 F, six mois plus tard. »
Ticket : « Assurance-vie : 60 000 F, ce mois-ci, sans droits » / « Par succession : 32 500 F, dans 6 mois (27 500 F de droits) ».

---

## 2. La progression du joueur : un produit à la fois

### 2.1 Principes

1. **Le Livret A d'abord, toujours** (mois 1). Chaque produit suivant est présenté **par comparaison** avec ce que le joueur **détient** (en priorité) ou **connaît déjà**.
2. **Une nouveauté au plus par appel**, et au moins **4 mois de jeu** entre deux présentations de produit. Les **nouveautés historiques** (Saint-Gobain 11/1986, plafond du Livret A 06/1987, PEA 07/1992…) passent avant et ne comptent pas dans l'intervalle. Dans la démo V2, ce sont les déclencheurs et **dates limites** de 12 §2.2 qui font foi (§2.5).
3. Un produit est présenté **quand il devient utile au personnage** (déclencheur), pas parce qu'il existe.
4. Chaque présentation finit par **3 boutons** (12 §2.3) : « Ouvrir / Souscrire » (ouvre le tiroir, montant d'exemple seulement), « Pas maintenant » (aucune pénalité, le produit reste à la banque), « En savoir plus » (fiche détaillée et comparatif).
5. Le **carnet du banquier** (toucher la banque, 12 §2.4) liste les produits **présentés** et, en silhouette, ceux **à découvrir** : « M. Lefranc vous en parlera ». Aucun produit n'est achetable avant sa présentation (12, R2).
6. **Notion de « coussin »** : `coussin_mois = (compte courant + Livret A + Codevi + LEP + SICAV monétaire) / dépenses mensuelles`. Objectif : **3 mois** (règle de Cousin Indice, 03 §7.8). Une jauge « coussin » à côté du Livret A rend la notion visible.

### 2.2 Les étapes

| Étape | Produit | Déclencheur (le premier vrai) | Notion apprise | Comparé à |
|---|---|---|---|---|
| E1 | **Livret A** | Mois 1 de la partie (appel forcé) | Intérêt, disponibilité, exonération, **rendement réel** (taux − inflation) | Compte courant |
| E2 | *Coussin de sécurité* (pas un produit) | Mois 2, ou dès le 1er dépôt sur le Livret A | Épargne de précaution : 3 mois de dépenses | — |
| E3 | **LEP** | Profil jeune salarié (foyer peu imposé, C) ; ou perte d'emploi | Conditions de ressources ; « vérifiez vos droits » | Livret A |
| E4 | **PEL** | Coussin ≥ 1 mois **et** épargne mensuelle ≥ 300 F **et** âge ≤ 40 ans ; ou 6 mois après E1 | **Rendement contre disponibilité** ; taux fixe garanti ; épargne forcée | Livret A |
| E5 | **Codevi** | Livret A ≥ plafond − 1 mois d'épargne | Plafond ; empiler les livrets exonérés | Livret A |
| E6 | **SICAV monétaire** (ou compte à terme) | Livret A et Codevi pleins ; ou coussin ≥ 3 mois avec plus de 10 000 F hors coussin | **Fiscalité** : un taux brut plus élevé, mais imposable ; pas de plafond | Livret A, Codevi |
| E7 | **Emprunt d'État** | Coussin ≥ 3 mois **et** ≥ 10 000 F hors coussin | Prêter longtemps à taux fixe ; coupon ; **risque de taux** | Livret A, PEL |
| E8 | **SICAV actions** | Coussin ≥ 3 mois **et** ≥ 5 000 F hors coussin ; ou l'héritier dès le mois 3 (diversifier ses 2 lignes) | Action, dividende, **diversification**, volatilité, **horizon long**, frais | Emprunt d'État, Livret A |
| E9 | **Privatisation** puis **actions en direct** | Historique : Saint-Gobain, appel forcé en 11/1986 ; actions en direct présentées le mois suivant la souscription | **Marché primaire / secondaire** ; concentration du risque ; frais par ordre | SICAV actions (ou Livret A si E8 pas encore vu) |
| E10 | **Assurance-vie (fonds en francs)** | Le premier de : **naissance** (argument successoral) ; épargne totale ≥ 6 mois de salaire avec coussin ≥ 3 mois ; héritier au mois 4 ; cadre 12 mois après E1 | **Enveloppe** (≠ produit) ; horloge fiscale de 6 / 8 ans ; frais d'entrée ; **transmission hors succession** | Livret A, PEL, emprunt d'État |
| E11 | **Or** | Optionnel : après un krach, ou en période d'inflation forte (1978-1982) | Valeur refuge sans rendement ; coût de l'aller-retour | Livret A, SICAV actions |
| E12 | **PEA** | Historique : 07/1992 (P1) ; départ en P2-P3, présenté après E8 | Enveloppe fiscale actions ; horloge de 5 ans | Compte-titres (SICAV actions, actions) |
| E13 | **ETF** (P2 dès 01/2001, P3) | Historique 01/2001 ; en P3, après E8 | Gestion indicielle, frais bas | SICAV actions |
| E14 | **Assurance-vie en UC** (P2-P3) | Le joueur a déjà une assurance-vie et une SICAV / un ETF | Enveloppe + support risqué ; garantie perdue | Fonds en euros, PEA |

### 2.3 Avantages et inconvénients relatifs (le cœur des fiches produit)

Chaque fiche affiche **une colonne de référence** : le produit le plus proche que le joueur **détient** (à défaut, le Livret A). Règle simple : référence = premier produit détenu dans la liste « Comparé à » de l'étape.

**E1 Livret A, comparé au compte courant**

| Avantages | Inconvénients |
|---|---|
| Rapporte 4,5 % au lieu de 0 % | Plafonné (72 000 F, puis 80 000 F) |
| Pas d'impôt | Pas de chéquier : il faut faire un virement vers le compte courant pour payer |
| Retrait à tout moment | Taux décidé par l'État, qui peut le baisser (de 6 % à 4,5 % en mai 1986) |

**E3 LEP, comparé au Livret A**

| Avantages | Inconvénients |
|---|---|
| 5,5 % au lieu de 4,5 %, mêmes services | Réservé aux revenus modestes |
| Exonéré, disponible | Plafond plus bas (20 000 F) |

**E4 PEL, comparé au Livret A**

| Avantages | Inconvénients |
|---|---|
| ≈ 6 % prime comprise au lieu de 4,5 % | **Bloqué** : un retrait ferme le plan ; avant 4 ans, la prime est perdue |
| Taux **garanti pour toute la durée**, même si les taux baissent | Versements réguliers obligatoires |
| Pas d'impôt ; droit à un prêt immobilier | Le taux reste figé même si les taux montent |

**E5 Codevi, comparé au Livret A**

| Avantages | Inconvénients |
|---|---|
| Un plafond de plus (10 000 F), même taux, même exonération | Petit plafond |

**E6 SICAV monétaire, comparée au Livret A (et au Codevi)**

| Avantages | Inconvénients |
|---|---|
| ≈ 7 % au lieu de 4,5 % | Gains imposables (16 % en jeu) : ≈ 5,9 % net |
| Pas de plafond | Disponible en 48 heures, pas immédiatement |
| | Rendement variable, qui suit les taux du marché (et peut devenir négatif, comme en 2015-2021) |

**E7 Emprunt d'État, comparé au Livret A et au PEL**

| Avantages | Inconvénients |
|---|---|
| ≈ 9 % fixe pendant 10 ans, deux fois le Livret A | Coupons imposables (16 %) |
| Pas de plafond ni de versements obligatoires (vs PEL) | Sur 10 ans ; revendu avant, son prix dépend des taux du jour (simplifié en jeu) |
| Garanti par l'État à l'échéance | |

**E8 SICAV actions, comparée à l'emprunt d'État (et au Livret A)**

| Avantages | Inconvénients |
|---|---|
| Part de la croissance et des dividendes de dizaines d'entreprises | **Aucune garantie** : des années à +50 % (1986), d'autres à −30 % (1974) |
| Sur longue période, historiquement mieux que les obligations | 2 % d'entrée et 1,5 % par an de frais |
| Diversifiée (vs une action seule) | Impose un horizon de 8 à 10 ans |

**E9 Privatisation et actions en direct, comparées à la SICAV actions**

| Avantages | Inconvénients |
|---|---|
| Prix fixe connu à l'avance, sans frais de souscription, action gratuite si on garde 18 mois | **Une seule entreprise** : le risque n'est pas réparti |
| Pas de frais de gestion annuels | Chaque ordre coûte 1,3 % (au moins 50 F) : les petits ordres sont chers |
| On choisit soi-même ses entreprises | Il faut suivre ses titres soi-même |

**E10 Assurance-vie (fonds en francs), comparée au Livret A, au PEL et à l'emprunt d'État**

| Avantages | Inconvénients |
|---|---|
| ≈ 10 % en 1986-1987, capital garanti par l'assureur, intérêts acquis chaque année (effet cliquet) | **4 % de frais d'entrée** : il faut environ 6 mois pour les « rembourser » |
| Pas de plafond, pas de versements obligatoires (vs PEL) | Gains taxés si retrait avant 6 ans (8 ans pour les contrats ouverts dès 1990) |
| Gains exonérés après 6 ans | Garantie d'un assureur, pas de l'État (vs Livret A, emprunt d'État) |
| **Hors succession et sans droits** : l'argent va directement à qui l'on désigne | Retrait en quelques jours, pas immédiat |
| Pas de risque de prix si on sort avant terme (vs emprunt d'État) | Le taux varie chaque année (pas fixe comme le PEL) |

**E11 Or, comparé au Livret A et à la SICAV actions**

| Avantages | Inconvénients |
|---|---|
| Valeur reconnue partout, refuge en cas de crise monétaire | Ne rapporte rien (ni intérêt ni dividende) |
| Indépendant de la Bourse de Paris | ≈ 5 % de commissions aller-retour + taxe de ≈ 7 % à la vente |
| | Cours très variable (record en 1980, puis vingt ans de baisse) |

**E12 PEA, comparé au compte-titres**

| Avantages | Inconvénients |
|---|---|
| Après 5 ans, **0 %** d'impôt au lieu de 16 % (P1) | Actions et SICAV actions européennes seulement ; ni obligations ni livrets |
| Mêmes actions et SICAV qu'avant | Retrait avant 5 ans : impôt (et clôture avant 8 ans jusqu'en 2019) |
| | Plafonné (600 000 F, puis 150 000 €) |

### 2.4 Les 4 critères fixes du comparatif (12, R8), notés de 1 à 3

Pour les pictogrammes du carnet du banquier. Rendement : 1 faible, 3 élevé (espéré pour les actions) ; risque : 1 faible, 3 élevé ; disponibilité : 3 immédiate, 1 bloquée ; fiscalité : 3 sans impôt, 1 imposé. Valeurs pour 1984-1988.

| Ligne | Rendement | Risque | Disponibilité | Fiscalité | Commentaire |
|---|---|---|---|---|---|
| Compte courant | 0 (aucun) | 1 | 3 | 3 | Point de départ de toutes les comparaisons |
| Livret A | 1 | 1 | 3 | 3 | |
| PEL | 2 | 1 | 1 | 3 | Taux fixe garanti |
| Emprunt d'État | 2 (3 en 1984 : 13,4 %) | 1 en jeu (A13), 2 en réalité | 2 | 1 | Coupons imposés à 16 % |
| Assurance-vie fonds en francs | 3 (≈ 11-12 % en 1984-1986) | 1 | 2 | 2 (0 % après 6 ans) | Seul produit « hors succession » |
| SICAV actions | 3 (espéré, non garanti) | 2 | 2 | 1 | Diversifiée |
| Actions, Saint-Gobain | 3 (espéré, non garanti) | 3 | 2 | 1 | Une seule entreprise |

### 2.5 Démo V2 (01/1984 → 12/1988) : alignement sur l'ordre du client (12 §2.2)

**Je retiens l'ordre du client** : Livret A → PEL → emprunt d'État → assurance-vie → SICAV actions → actions → Saint-Gobain. Il est historiquement juste (tous ces produits existent en 01/1984) et pédagogiquement solide : on va du plus sûr au plus risqué, et l'assurance-vie arrive avec la naissance, au moment où l'argument successoral a du sens. Mes remarques n'en changent pas l'ordre :

| Étape (12) | Produit | Déclencheur et date limite (12) | Texte | Remarques du banquier |
|---|---|---|---|---|
| 1 | Livret A | Mois 1 (01/1984) | D01 | En 01/1984, 7,5 % pour 7,4 % d'inflation : **rendement réel nul**. Le dire : « il protège plus qu'il n'enrichit ». Le rendement réel devient nettement positif en 1986. |
| 2 | PEL | Livret A ≥ 3 mois de dépenses ; au plus tard mois 8 (08/1984) | D02 | Le taux dépend du **mois d'ouverture** (§1.7.1) : ≈ 8,25 % jusqu'en 07/1984, ≈ 7 % ensuite. Le moteur doit figer le taux à l'ouverture. |
| — | **Baisses du Livret A** (16/08/1984, 01/07/1985, 31/05/1986) | Historique : notification de la banque, **sans pause** | D02 bis | **Ajout proposé** : trois baisses en deux ans (7,5 → 4,5 %). Si le joueur a un PEL ou un emprunt d'État, M. Lefranc rappelle que **leur taux, lui, ne bouge pas** : c'est la leçon « taux fixe contre taux variable », gratuite et historique. |
| 3 | Emprunt d'État 10 ans | 2 produits détenus, ou compte courant ≥ 2 mois de salaire ; au plus tard mois 14 (02/1985) | D03 | 13,4 % en 1984, 11,9 % en 1985 : le joueur rapide verrouille un taux exceptionnel. |
| 4 | Assurance-vie | Naissance scriptée (≈ mois 16, printemps 1985) ; au plus tard 3 mois après | D04 (+ D04 bis au rendez-vous suivant) | Règles exactes : §1.7.2. L'horloge de 6 ans finit en **1991, après la démo** : M. Lefranc doit le dire (un retrait avant coûte 45 % puis 25 % d'impôt sur les gains). Argument chiffré avec l'argent de Gérard : §1.7.3 (Sylvie). Dépend de D4 (mariés ou non). |
| 5 | SICAV actions | 1 produit à taux fixe détenu depuis 6 mois ; au plus tard mois 26 (02/1986) | D05 | Le joueur la découvre en pleine hausse (1985 : +46,5 %, 1986 : +49,7 %) : rappeler aussi 1974 (−30,8 %), sans jamais prédire. |
| 6 | Actions (Elf, L'Oréal, Peugeot) | SICAV détenue depuis 3 mois ; au plus tard mois 32 (08/1986) | D06 | Le minimum de courtage de 50 F est la meilleure leçon de frais (§5.4). |
| — | Saint-Gobain | Historique | D07 | **Petit écart proposé** : l'offre a été **mise en vente le 24/11/1986** et close début décembre ; un appel en **11/1986** est plus juste qu'en 12/1986 (avec 1 tour = 1 mois, un appel en 12/1986 reste acceptable s'il dit « derniers jours »). |
| — | Krach (10/1987) | Média, puis appel si le joueur détient des actions | L17 | Inchangé. |
| — | Héritage de tante Odette | Décès 03/1988 ; assurance-vie versée en 04/1988 ; succession en 09/1988 | D08, D08 bis | Montants §1.7.4. |
| — | Bilan annuel et frais de l'année | Décembre, notification sans pause | L21, F02 | §5.4. |

**Garde-fou « coussin » et dates limites** : le client garantit que tout joueur a vu les 6 familles avant le krach, même sans épargne. Je m'y range : quand une date limite force une présentation de produit risqué alors que `coussin_mois < 3`, M. Lefranc ajoute une seule phrase : « Avant cela, votre roue de secours n'est pas encore complète : ce placement ne concerne que l'argent au-delà. »

---

## 3. Adapter les propositions à la situation de vie

**Décision du joueur (2026-10-27) : pas de questionnaire de profil de risque.** M. Lefranc ne demande jamais « êtes-vous prudent ou audacieux ? ». Il adapte ses présentations **uniquement à la situation de vie** du personnage : âge, couple, enfants, épargne, coussin, produits détenus, événements (naissance, chômage, héritage). Adapter, c'est choisir **le moment**, **l'exemple chiffré** (l'argent réel du joueur), **la comparaison** (ses produits) et **le ton** ; jamais décider (12 §2.1).

### 3.1 Ce que M. Lefranc « sait » du joueur

| Variable | Calcul | Usage |
|---|---|---|
| `profil` | Démo : Gérard seul. Jeu complet : jeune salarié / cadre pressée / héritier (03 §5), qui sont des **situations de départ** (âge, salaire, capital), pas des profils de risque | Ordre des étapes du jeu complet (§3.2), montants des exemples |
| `age` | âge du personnage à la date | PEL (≤ 40 ans), « prendre date » en assurance-vie (jeune), plus tard 757 B (≥ 70 ans, hors des profils) |
| `enfants` | 0 à 2 (naissance scriptée en 1985 dans la démo ; jumeaux possibles, retour du 27/10) | Déclenche l'assurance-vie ; ton « maintenant que vous êtes papa » ; avec des jumeaux, l'exemple successoral se fait avec 2 parts de 275 000 F |
| `couple` | Démo : Gérard et Sylvie (mariés ou non : D4) | Argument assurance-vie pour Sylvie (§1.7.3) ; texte « concubins » (L16) ; argument « conjoint » (avant 08/2007) |
| `coussin_mois` | §2.1, point 6 | Aucun produit risqué (risque ≥ 3) n'est **présenté** tant que `coussin_mois < 3`, sauf les nouveautés historiques, avec l'avertissement « avec l'argent au-delà de votre coussin » |
| `epargne_mensuelle` | salaire − dépenses | PEL (≥ 300 F), montants des exemples |
| `hors_coussin` | épargne liquide − 3 mois de dépenses | Emprunt d'État, SICAV, assurance-vie |
| `livret_plein` | solde ≥ plafond − 1 mois d'épargne | Codevi, SICAV monétaire |
| `expo_actions` | (SICAV actions + actions) / patrimoine | Ton de L17 (krach) ; présentation de E11 |
| `produits_detenus`, `produits_presentes` | ensembles | Référence de comparaison (§2.3), intervalle entre deux appels |
| `chomage` | événement en cours | LEP, L18, aucune proposition risquée pendant l'événement |
| `heritage` | Événement scripté de 1988 (démo) | D08 ; ensuite, présentation du placement de la somme reçue selon le coussin |

L'**horizon** n'est jamais demandé : il est déduit de la situation (personnage de moins de 40 ans = long terme ; chômage en cours = court terme ; jeune parent = horizon des études de l'enfant, 18 ans). Le projet logement n'est pas demandé non plus : le PEL est présenté comme « si vous pensez acheter un jour », le joueur juge.

### 3.2 Règles de choix (évaluées une fois par mois, dans l'ordre)

Dans la **démo**, l'ordre est fixé par le client (§2.5) ; la situation de vie joue sur le **moment** (déclencheurs), les **chiffres**, la **référence de comparaison** et le **ton**. Les règles ci-dessous valent pour le **jeu complet**.

1. **Nouveauté historique** du mois (Saint-Gobain, plafond du Livret A, PEA, ETF…) → appel forcé.
2. **Événement de vie** du mois : naissance → L14 (puis L15 au rendez-vous suivant) ; perte d'emploi → L18.
3. **Bilan annuel** en décembre (L21).
4. Sinon, si l'intervalle minimal est écoulé, **la première étape non présentée dont le déclencheur est vrai**, dans l'ordre du profil :

| Profil | Ordre de présentation | Pourquoi |
|---|---|---|
| Jeune salarié | E1, E2, E3 LEP, E4 PEL, (E9 historique), E8, E10, E7, E6, E5, E11 | Peu d'épargne : d'abord les livrets et l'épargne forcée ; le risque une fois le coussin fait |
| Cadre pressée | E1, E2, E4 PEL, (E9), E10 assurance-vie, E8, E7, E6, E5, E11 | Bonne capacité d'épargne, horizon long, impôt sur le revenu : l'assurance-vie prend de la valeur |
| Héritier | E1, E5 Codevi, E8 SICAV actions, E10 assurance-vie, E6, E7, (E9), E4, E11 | Capital élevé dès le départ et concentré sur deux actions : plafond, diversification, transmission |
| Tout profil avec enfant | E10 passe en tête dès la naissance | Argument successoral (demande du joueur) |

5. **Garde-fous** : jamais de produit de risque ≥ 3 si `coussin_mois < 3` (hors historique) ; jamais de PEL si `epargne_mensuelle < 300 F` ; jamais d'assurance-vie « pour un projet de moins de 2 ans » (le texte le dit) ; aucune proposition risquée pendant un chômage.

### 3.3 Ce que M. Lefranc ne fait jamais

| Interdit | Formulation à employer à la place |
|---|---|
| Prédire le marché (« ça va monter », « c'est le bon moment ») | « Personne, moi compris, ne sait ce que fera la Bourse l'an prochain. » |
| Choisir le montant | « Combien ? C'est vous qui voyez ; moi, je vous montre ce que ça donne sur 10 000 F. » |
| Décider à la place du joueur | Toujours les 4 boutons (§2.1, point 4) |
| Dire « garanti » pour un placement risqué, ou « sans risque » pour l'assurance-vie | « garanti par l'État » (livrets, emprunt d'État à l'échéance) ; « garanti par l'assureur » (fonds en francs) ; « aucune garantie » (actions) |
| Citer un rendement futur | Seulement le taux du moment ou le passé (« l'an dernier », « en 1974 ») |
| Employer un mot anachronique | « CAC 40 » avant 06/1988 (dire « l'indice de la Bourse de Paris ») ; « PEA » avant 07/1992 ; « euros » avant 1999 |

### 3.4 Ses travers réalistes (pédagogiques, à proposer au client en option)

Un vrai banquier de 1986 n'était pas neutre. Montrer ses travers, **sans le rendre malhonnête**, apprend au joueur à poser les bonnes questions.

| Travers | Réalité | Mécanique proposée | Cert. |
|---|---|---|---|
| **Produits maison chargés en frais** | SICAV maison à 3-4,5 % d'entrée, assurance-vie maison à 4-5 % | Bouton « Y a-t-il moins cher ? » dans la fiche : M. Lefranc répond honnêtement (L22) et un « contrat d'association » à 0-2 % d'entrée apparaît (plus tard) | B |
| **Le PEL pour tout le monde** | Produit de collecte prisé des réseaux, même sans projet immobilier | Il le présente tôt à tous les profils ; la fiche rappelle le blocage | B |
| **L'euphorie des privatisations** | 1986-1987 : le guichet relaie l'enthousiasme général (« tout le monde y gagne ») | L10 évoque l'engouement (« on fait la queue au guichet ») mais rappelle le risque ; la leçon tombe avec Suez en 10/1987 | A |
| **Le Livret A « oublié »** | Une banque commerciale ne pouvait pas l'ouvrir et préférait vendre ses SICAV | Hors démo (contraire à la demande « commencer par le Livret A ») ; possible en mode « réaliste » | A |
| **Faire tourner le portefeuille** | Chaque ordre rapporte des commissions à la banque | Plus tard : M. Lefranc propose un « arbitrage » ; la fiche affiche le coût des frais | C |

---

## 4. Répliques de M. Lefranc, prêtes à l'emploi

### 4.0 Démo V2 (1984-1988) : présentations de 60 mots au plus, avec l'argent du joueur (12, R3)

Variables calculées par le moteur à la date de l'appel ; l'exemple entre crochets est un calcul de contrôle. Taux : §1.7.1. Chaque texte est suivi du bloc « Par rapport à ce que vous connaissez » (§2.4) et des 3 boutons. Le détail (exemples longs, fiscalité) va dans « En savoir plus » : on peut y reprendre les répliques L01 à L25 du §4.1. Décompte : 50 à 60 mots en comptant chaque nombre comme un mot ; D04 bis, D05 et D08 sont à la limite (≈ 60-65) : si le compteur du développeur dépasse, couper la dernière phrase, qui est reprise dans « En savoir plus ».

| id | Moment | Texte | Calcul de contrôle |
|---|---|---|---|
| **D01** | Mois 1 (01/1984) | « Bonjour {civ} {nom}, Lefranc, de la banque ! Vos {cc} F dorment à 0 % sur votre compte courant. Sur un Livret A, ils rapporteraient 7,5 % sans impôt, soit {cc × 0,075} F par an, disponibles à tout moment. Seul bémol : les prix montent d'environ 7 % par an ; le Livret A protège votre argent plus qu'il ne l'enrichit. » | cc = 11 000 F → 825 F |
| **D02** | Étape 2 (PEL) | « Votre Livret A couvre maintenant trois mois de dépenses : votre roue de secours est prête. Pour un projet de logement, le PEL rapporte {taux_pel} % prime de l'État comprise, contre {taux_la} % au Livret A, et ce taux est garanti jusqu'au bout. Avec {v} F par mois pendant 4 ans : {fv_pel} F. Mais un seul retrait ferme le plan. » | v = 500 F, 8,25 % → ≈ 28 150 F (formule §5.2) |
| **D02 bis** | Baisse du Livret A (16/08/1984 ; 01/07/1985 ; 31/05/1986), si PEL ou emprunt détenu | « Le Livret A passe de {ancien} % à {nouveau} %. Sur vos {la} F, c'est {la × écart} F d'intérêts en moins par an. Votre {pel_ou_emprunt}, lui, garde son taux de {taux_fixe} % : c'est tout l'intérêt d'un taux fixe. » | 30 000 F, 7,5 → 6,5 % → 300 F |
| **D03** | Étape 3 (emprunt d'État) | « L'État emprunte en ce moment à {t} % sur 10 ans. Prêtez-lui {m} F : il vous verse {m × t} F chaque année jusqu'en {annee + 10}, {m × t × 0,84} F après impôt, puis vous rend votre mise. Par rapport au Livret A : un taux plus élevé et fixe, mais imposé, et un argent prêté pour longtemps. » | 10 000 F en 1984 → 1 340 F, 1 126 F nets |
| **D04** | Étape 4, naissance (variante **non mariés**, recommandée) | « Félicitations pour {enfant} ! Une question délicate : si vous disparaissiez, Sylvie, qui n'est pas votre épouse, n'hériterait de rien de vos {e} F. L'assurance-vie verse son capital à qui vous désignez, hors succession et sans droits : Sylvie recevrait {e} F. Le fonds en francs a rapporté {t_av} % l'an dernier ; 4 % de frais à l'entrée. » | e = 30 000 F ; t_av = 12,5 % (1984) |
| **D04 m** | Variante **mariés** | « Félicitations pour {enfant} ! Une question délicate : si vous disparaissiez, la loi donnerait l'essentiel de vos {e} F à votre enfant, et à Sylvie seulement l'usage d'un quart. L'assurance-vie verse son capital à qui vous désignez, hors succession et sans droits : Sylvie recevrait {e} F. Le fonds en francs a rapporté {t_av} % l'an dernier ; 4 % de frais. » | — |
| **D04 bis** | Rendez-vous suivant (≤ 3 mois) | « Pour votre enfant, l'assurance-vie compte surtout pour les grosses sommes : 675 000 F transmis par succession, c'est 68 750 F de droits après l'abattement de 275 000 F ; si 400 000 F passent par une assurance-vie qui le désigne, 0 F. Mais c'est un placement fait pour durer : avant 6 ans, les gains retirés sont imposés de 45 % à 15 %. » | §1.3.4 |
| **D05** | Étape 5 (SICAV actions) | « Votre {produit_fixe} vous rapporte {t} %, garanti. La SICAV actions, elle, ne garantit rien : avec {m} F, vous possédez un morceau de dizaines d'entreprises françaises. Une année peut faire +50 % comme −30 % (1974). Comptez {m × 0,02} F de droits d'entrée et 1,5 % de frais par an, pour de l'argent qui peut attendre 8 à 10 ans. » | 5 000 F → 100 F |
| **D06** | Étape 6 (actions) | « Après la SICAV, les actions en direct : Elf, L'Oréal, Peugeot. Vous choisissez votre entreprise, sans frais de gestion annuels, et touchez ses dividendes. Mais une entreprise peut chuter seule, alors que la SICAV en mélange des dizaines. Chaque ordre coûte 1,3 %, au moins 50 F : sur {m} F, {max(50, m × 0,013)} F. » | 2 000 F → 50 F (2,5 %) |
| **D07** | Saint-Gobain (11/1986) | « Grande première : l'État vend Saint-Gobain au public, 310 F l'action, prix fixe, au guichet jusqu'au début décembre. Par rapport à vos achats en Bourse : pas de courtage, et le prix est connu d'avance. Mais c'est une action comme les autres : son cours pourra monter ou baisser. Avec {m} F, vous pourriez en prendre {floor(m / 310)}. » | 5 000 F → 16 actions |
| **D08** | 04/1988 (héritage, 1) | « {civ} {nom}, toutes mes condoléances pour votre tante Odette. Elle vous avait désigné sur son assurance-vie : 60 000 F, versés ce mois-ci, sans un centime de droits. Sa succession passera chez le notaire : comptez six mois, et l'État prendra 55 % de votre part, car un neveu est peu favorisé. Vous voyez de l'autre côté ce que je vous expliquais en 1985. » | §1.7.4 |
| **D08 bis** | 09/1988 (héritage, 2) | « Le notaire a réglé la succession de votre tante : sur votre part de 100 000 F, 55 000 F de droits ; il vous revient 45 000 F, six mois après. Comparez : son assurance-vie vous a versé 60 000 F entiers, en un mois. Pour un franc transmis : 1 F d'un côté, 0,45 F de l'autre. » | §1.7.4 |

### 4.1 Répliques détaillées (jeu complet et « En savoir plus »)

Variables : `{civ}` (Monsieur / Madame), `{nom}`, `{coussin}` (3 mois de dépenses, arrondi à 100 F), `{enfant}`, `{x}`, `{interets}`, `{gain_reel}`, `{baguettes}`, `{annee_maturite}`. Les montants entre parenthèses sont des exemples à recalculer par le moteur. Chaque réplique est suivie des 4 boutons (§2.1). Note « Jeu » : simplification à mettre dans la bulle (?).

| id | Déclencheur | Texte | Cert. des chiffres |
|---|---|---|---|
| **L01** | E1, mois 1 | « Bonjour {civ} {nom}, Lefranc, de la banque ! Pour commencer, ce que je présente à tous mes nouveaux clients : le Livret A. Il rapporte 4,5 % par an, sans un centime d'impôt, et votre argent reste disponible à tout moment : 10 000 F déposés aujourd'hui, ce sont 450 F d'intérêts dans un an. Et comme les prix ne montent plus que d'environ 3 % par an, votre épargne gagne enfin du pouvoir d'achat, ce qui n'était pas arrivé depuis bien longtemps. » | A |
| **L02** | E2 | « Une règle que je répète à tous mes clients : gardez sur le Livret A l'équivalent de trois mois de dépenses, soit chez vous environ {coussin} F (11 700 F). C'est votre roue de secours : une panne de voiture, une période sans travail, et vous n'aurez rien à vendre au mauvais moment. Tant que ce coussin n'est pas fait, je ne vous présenterai rien de risqué. » | — |
| **L03** | 30/06/1987 | « Bonne nouvelle, {civ} {nom} : depuis le 30 juin, le plafond du Livret A passe de 72 000 à 80 000 F. Vous pouvez y loger 8 000 F de plus, toujours à 4,5 % et toujours sans impôt : 360 F d'intérêts de plus par an. » | A |
| **L04** | E5 (Livret A plein) | « Votre Livret A est plein : c'est le maximum autorisé par l'État. Il a un petit frère, le Codevi : même taux de 4,5 %, pas d'impôt non plus, disponible à tout moment, mais limité à 10 000 F. Cela fait 450 F d'intérêts par an de plus, sans rien changer à vos habitudes. » | B (plafond C) |
| **L05** | E3 (jeune salarié, chômage) | « Vous payez peu ou pas d'impôt sur le revenu ? Alors vous avez peut-être droit au Livret d'épargne populaire : 5,5 % au lieu des 4,5 % du Livret A, sans impôt, jusqu'à 20 000 F. Sur 10 000 F, c'est 100 F de plus chaque année pour exactement le même service. Apportez-moi simplement votre avis d'imposition. » | A (taux), B (plafond) |
| **L06** | E4 | « Si vous pensez acheter un jour votre logement, regardez le plan épargne logement : environ 6 % par an prime de l'État comprise, et ce taux est garanti pour toute la vie du plan, même si les taux baissent. En versant 500 F par mois pendant 4 ans, vous aurez environ 27 000 F, contre 26 200 F sur le Livret A, plus le droit à un prêt immobilier. La contrepartie : l'argent est bloqué, un seul retrait et le plan est clos. » | A/B |
| **L07** | E6 (livrets pleins, surplus) | « Au-delà de vos livrets, beaucoup de clients utilisent une SICAV monétaire : elle suit les taux du marché, autour de 7 % en ce moment, sans plafond, et vous récupérez votre argent en 48 heures. Contrairement au Livret A, les gains sont imposables : avec 16 % d'impôt, 7 % deviennent environ 5,9 %. Et si les taux baissent, son rendement baissera aussi. » | B/C. Jeu : bulle A6 sur le seuil de cessions |
| **L08** | E7 | « L'État emprunte en ce moment à environ 9 % sur 10 ans. Prêtez-lui 10 000 F : il vous verse 900 F chaque année, 756 F après impôt, puis vous rend vos 10 000 F à l'échéance. C'est près du double du Livret A, mais vous prêtez pour longtemps : revendu avant l'échéance, le titre vaut le prix du jour, plus bas si les taux ont monté. » | A. Jeu : « Simplifié : dans le jeu, revente au prix d'achat » |
| **L09** | E8 | « Votre coussin est fait, bravo. Pour l'argent dont vous n'aurez pas besoin avant 8 ou 10 ans, il y a la SICAV actions : avec 5 000 F, vous possédez un petit morceau de dizaines de grandes entreprises françaises et vous touchez leur part de bénéfices. La Bourse de Paris a gagné près de 50 % l'an dernier, mais elle a perdu près d'un tiers en 1974 : personne, moi compris, ne sait ce qu'elle fera l'an prochain. Comptez 100 F de droits d'entrée sur 5 000 F, puis environ 1,5 % de frais par an. » Variante héritier : « Les actions de votre grand-père, ce sont deux paniers seulement ; une SICAV en contient des dizaines. » | A (1974 : B) |
| **L10** | Saint-Gobain (24/11/1986 → 12/1986) | « Grande première, {civ} {nom} : l'État vend Saint-Gobain au public, à 310 F l'action, prix fixe, au guichet ; on fait la queue jusque sur le trottoir ! Dix actions, c'est 3 100 F, et si vous les gardez 18 mois, l'État vous en offre une onzième. Mais c'est une seule entreprise : contrairement à votre Livret A, sa valeur peut baisser, et je ne vous dirai pas qu'elle va monter. Si vous souscrivez, faites-le avec de l'argent au-delà de votre coussin. » | A (prix), B (gratuite) |
| **L11** | Mois suivant une 1re souscription d'actions | « Maintenant que vous êtes actionnaire, vous pouvez acheter d'autres actions à la Bourse, au cours du jour. Chaque ordre passe par l'agent de change et coûte environ 1,3 %, avec un minimum de 50 F : pour 2 000 F d'actions, ces 50 F représentent déjà 2,5 %. Mieux vaut des ordres moins nombreux et plus gros. » | A (règle V1) |
| **L12** | E10, présentation générale | « Connaissez-vous l'assurance-vie ? Notre contrat en francs a rapporté près de 10 % l'an dernier ; le capital est garanti par l'assureur et les intérêts crédités chaque année sont définitivement acquis. Après 6 ans, vos gains ne paient plus d'impôt du tout. La contrepartie : 4 % de frais à l'entrée, soit 800 F sur 20 000 F, et un impôt sur les gains si vous retirez avant 6 ans : c'est un placement pour plusieurs années, pas pour la voiture du mois prochain. » | B. Jeu : bulle « 45 / 25 / 15 % en réalité » |
| **L13** | E10, profils jeunes (« prendre date ») | « Un vieux truc de banquier : en assurance-vie, ce qui compte, c'est la date d'ouverture, car l'horloge des 6 ans démarre au premier versement. Ouvrir aujourd'hui avec 1 000 F, soit 40 F de frais, c'est avoir un contrat déjà mûr en {annee_maturite} (1993), le jour où vous aurez davantage à placer. Rien ne vous oblige à verser plus ensuite. » | A |
| **L14** | Naissance (succession, 1) | « Toutes mes félicitations pour la naissance de {enfant} ! Un sujet qu'on n'aime pas aborder, mais que je dois vous présenter : le capital d'une assurance-vie est versé directement à la personne que vous désignez, en dehors de la succession, et aujourd'hui sans aucun droit de succession, quel que soit le montant. Ce que vous laisseriez sur des livrets ou en SICAV serait taxé jusqu'à 20 % au-delà de 275 000 F par enfant. Et l'argent arrive en quelques semaines, sans attendre le règlement chez le notaire. » | A |
| **L15** | Rendez-vous suivant une naissance, ou épargne ≥ 100 000 F (succession, 2) | « Prenons un exemple : vous laissez un jour 675 000 F à votre enfant. Tout sur des comptes et des SICAV, il paie environ 68 750 F de droits après l'abattement de 275 000 F. Si 400 000 F sont sur une assurance-vie qui le désigne, il ne paie rien : 68 750 F de plus pour lui. La clé, c'est la clause bénéficiaire : écrivez par exemple « mon conjoint, à défaut mes enfants », et vous pouvez la changer quand vous voulez. » | A (calcul §1.3.4), B (tranches) |
| **L16** | Couple non marié (V2) (succession, 3) | « Vous vivez avec {conjoint} sans être mariés ? Aux yeux du fisc, vous êtes des étrangers l'un pour l'autre : ce que vous lui laisseriez par testament serait taxé à 60 %. Sur 100 000 F, il lui resterait 40 000 F. Avec une assurance-vie qui la désigne comme bénéficiaire, elle recevrait les 100 000 F entiers. » | A |
| **L17** | Krach (10-11/1987), si `expo_actions > 0` | « {civ} {nom}, vous avez vu les journaux. Je ne sais pas plus que vous ce que fera la Bourse demain, et je me méfie de ceux qui prétendent le savoir. Votre coussin sur le Livret A, lui, n'a pas bougé d'un centime ; vos actions ont perdu {x} %. Vendre aujourd'hui, c'est encaisser cette baisse ; garder, c'est accepter de ne pas savoir quand elle sera rattrapée : c'est à vous de décider. » | — |
| **L18** | Perte d'emploi | « J'ai appris pour votre emploi, j'en suis désolé. C'est exactement pour ce moment que nous avons constitué votre coussin : puisez d'abord dans le Livret A, disponible tout de suite et sans frais. Évitez si possible de toucher au PEL, qu'un retrait fermerait, ou à l'assurance-vie, dont les gains seraient imposés avant 6 ans. Et vérifiez vos droits au LEP : avec des revenus plus faibles, vous y avez peut-être droit. » | — |
| **L19** | E11 (optionnel) | « Certains clients aiment garder quelques napoléons au coffre : une pièce de 20 F en or vaut environ {cours} F aujourd'hui. L'or ne rapporte ni intérêt ni dividende ; entre les commissions d'achat et de revente et la taxe d'environ 7 % à la vente, il doit monter de plus de 10 % avant que vous gagniez un franc. On l'achète comme une assurance contre les crises monétaires, pas pour s'enrichir. » | C (taxe) |
| **L20** | « Le saviez-vous ? » (1987-1988) | « Le saviez-vous ? Jusqu'à la fin de 1988, l'État rembourse sur vos impôts 25 % de vos achats nets d'actions françaises, dans la limite de 7 000 F d'achats (14 000 F pour un couple marié), à condition de les garder 5 ans : jusqu'à 1 750 F d'impôt en moins. » Variante 01/1988 (L20 bis) : « Nouveau depuis janvier : le Plan d'épargne retraite. Jusqu'à 8 000 F versés par an (16 000 F pour un couple marié) se déduisent de vos revenus imposables ; c'est de l'épargne pour très longtemps. » | A/B ; sans effet en jeu |
| **L21** | Bilan de décembre | « Petit bilan de fin d'année, {civ} {nom} : votre Livret A vous a rapporté {interets} F cette année, sans impôt. Les prix ayant monté d'environ 3 %, votre gain réel est de {gain_reel} F, soit {baguettes} baguettes de plus dans votre poche. Rendez-vous l'an prochain ! » | moteur |
| **L22** | Bouton « Y a-t-il moins cher ? » (travers) | « Entre nous ? Notre SICAV maison prend 3 % à l'entrée ; d'autres maisons font moins, et une SICAV monétaire ne prend presque rien. Je suis là pour vous présenter nos produits, pas ceux de la concurrence, mais vous avez parfaitement le droit de comparer : sur 20 000 F, un point de frais, c'est 200 F. » | B |
| **L23** | 07/1992 (fin de P1) | « Grande nouvelle de juillet : le Plan d'épargne en actions. Vous y logez des actions françaises ou des SICAV actions, jusqu'à 600 000 F ; au bout de 5 ans, gains et dividendes ne paient plus d'impôt, au lieu de 16 % sur votre compte-titres. Sur 10 000 F de plus-value, ce sont 1 600 F qui restent chez vous. Seul bémol : un retrait avant 5 ans fait perdre l'avantage. » | A |
| **L24** | P2, 10/1998 | « Du nouveau pour l'assurance-vie : depuis le 13 octobre, ce que vous versez avant 70 ans reste hors succession, mais au-delà d'un million de francs par bénéficiaire, un prélèvement de 20 % s'applique. En dessous, toujours rien : pour presque tous nos clients, l'avantage reste entier. Par exemple, 500 000 F transmis à chacun de vos deux enfants : zéro franc de droits. » | A |
| **L25** | P3, 02/2020 | « Février 2020 : le Livret A ne rapporte plus que 0,5 %, et le fonds en euros de votre assurance-vie environ 1,3 %. Avec une inflation proche de 1 %, l'épargne garantie ne fait plus, au mieux, que maintenir votre pouvoir d'achat. C'est pourquoi la plupart des contrats proposent des unités de compte, par exemple un fonds qui suit un indice : plus de potentiel, mais plus de garantie du capital. Je vous présente les deux, vous choisissez la part de chacun. » | A |

Vérification des calculs : L06 (500 F/mois, 48 mois) : à 6 % → 500 × ((1,005^48 − 1) / 0,005) ≈ 27 050 F ; à 4,5 % → ≈ 26 220 F. L08 : 900 × (1 − 16 %) = 756 F. L12 : 4 % × 20 000 = 800 F. L13 : ouverture en 1987 + 6 ans = 1993. L15 : voir §1.3.4. L19 : achat + 2,5 %, vente − 2,5 % − 7 % → hausse nécessaire ≈ 13 %. L23 : 16 % × 10 000 = 1 600 F.

---

## 5. Pédagogie des frais (retour du joueur du 2026-10-27)

> « Aborder les frais et les pertes liés à ceux-ci avec des exemples parlants (investir 10k€ à 2.5% de frais sur 20 ans vs 0.5% de frais par exemple). »
> Message central : **un frais annuel de 2 % paraît minuscule, mais il se prélève tous les ans sur un capital qui grossit ; sur 20 ou 30 ans, il peut manger le tiers ou la moitié des gains.** Et plus le rendement est faible, plus la part mangée est grande.

### 5.1 Les types de frais, époque par époque

| Frais | 1984-1988 (démo) | 1989-1999 | 2000-2010 | 2011-2025 | Cert. |
|---|---|---|---|---|---|
| **Droits d'entrée** des SICAV et FCP (une fois, sur chaque achat) | 2 à 4,5 % en réseau (jeu : 2 %) | 2 à 4 % en réseau | Réseau 2-3 % ; en ligne 0-1 % ; ETF 0 % (2001) | Réseau 1-3 % ; en ligne 0 % ; ETF 0 % | B |
| **Frais de gestion annuels** des fonds actions (prélevés chaque jour sur la valeur, invisibles) | 1,5 à 2,5 % (jeu : 1,5 %) | 1,5 à 2,5 % | 1,5 à 2,5 % ; ETF 0,15-0,5 % | 1,5 à 2,2 % ; ETF 0,05-0,3 % | B |
| **Courtage** (chaque achat et chaque vente d'action) | Agent de change ≈ 0,65 % + commission de la banque ; ≈ 1 à 1,5 % au total, avec un **minimum** (jeu : 1,3 %, minimum 50 F) | Libre depuis le 01/07/1989 ; réseau 1-1,5 % ; en ligne dès 1996-1999 | Réseau ≈ 1 % ; en ligne 0,5 % ou forfait de 10 à 15 € | Réseau ≈ 0,5-1 % (étude AMF 2015 : 26,60 € pour un ordre de 5 000 €, contre 8,40 € en ligne) ; néo-courtiers 0 à 1 € | A/B |
| **Taxe sur les transactions** | Impôt de bourse ≈ 0,3 % (achat et vente) | idem | idem, supprimé le 01/01/2008 | TTF 0,2 % (08/2012), 0,3 % (2017), 0,4 % (04/2025), achats de grandes valeurs françaises | A |
| **Droits de garde** (chaque année, sur le compte-titres) | ≈ 0,2-0,4 % par an + un montant par ligne (hors V1) | idem | Réseau 0,2-0,3 % ; en ligne 0 | Réseau 0,2-0,3 % ; PEA plafonné à 0,4 % depuis le 01/07/2020 ; en ligne 0 | B |
| **Frais sur versements** d'assurance-vie (sur chaque versement) | 3 à 5 % (jeu : 4 %) | 3 à 5 % ; associations 2-3 % | Réseau 2-3 % ; en ligne 0 % | Réseau 1-3 % ; en ligne 0 % | B |
| **Frais de gestion** d'assurance-vie (chaque année) | Fonds en francs 0,5-1 %, déjà déduits du taux servi | idem | Fonds en euros 0,6-1 % ; UC 0,6-1 % + frais du fonds | En ligne ≈ 0,5 % ; réseau 0,75-1 % + frais des fonds | B |
| **Frais d'arbitrage** d'assurance-vie | Rares (peu de multisupports) | 0,5-1 % | 0,5-1 % ; en ligne gratuits | idem | C |
| **Or** | Commission ≈ 2-3 % à l'achat et à la vente + taxe ≈ 6-7,5 % du prix de vente | | Taxe ≈ 8 % | Taxe 11,5 % | C/B |
| **Coûts cachés** | — | — | — | Écart achat-vente (spread) et frais de change chez les néo-courtiers | B |

À dire au joueur : un **frais d'entrée** se paie une fois ; un **frais annuel** se paie tous les ans, **sur tout le capital, gains compris**, d'où l'effet boule de neige.

### 5.2 Formules (pour calculer avec l'argent réel du joueur)

Notations : `C` capital placé ; `e` frais d'entrée (0,02 = 2 %) ; `r` rendement brut annuel avant frais (hypothèse affichée) ; `f` frais annuels ; `n` années ; `P` versement mensuel ; `m` nombre de mois.

```
# 1. Capital final d'un placement unique (convention simple, celle des comparateurs)
V(n) = C × (1 − e) × (1 + r − f)^n
#    variante exacte si le frais est prélevé sur l'actif : C × (1 − e) × ((1 + r) × (1 − f))^n  (écart < 1 % sur 20 ans)

# 2. Manque à gagner entre deux formules de frais
manque(n) = V_frais_bas(n) − V_frais_haut(n)

# 3. Part des gains mangée par les frais (le chiffre le plus parlant)
part_mangee = 1 − (V_frais_haut(n) − C) / (V_sans_frais(n) − C)

# 4. Versements mensuels (PEL, assurance-vie, plan d'épargne)
i = (1 + r − f)^(1/12) − 1
V(m) = P × (1 − e) × ((1 + i)^m − 1) / i

# 5. Hausse nécessaire pour rentrer dans ses frais (achat puis revente d'une action)
frais_achat = max(min_courtage, taux × M) / M        # M = montant de l'ordre
hausse_necessaire = (1 + frais_achat) / (1 − frais_vente) − 1

# 6. Délai pour « rembourser » un droit d'entrée par un meilleur rendement
t_annees = ln(1 / (1 − e)) / ln((1 + r_produit) / (1 + r_reference))

# 7. Dans le moteur : le « jumeau sans frais »
# Pour chaque ligne détenue, suivre en parallèle valeur_ombre, mise à jour avec le même rendement brut
# mais sans aucun frais (ni entrée, ni gestion, ni courtage). Alors :
cout_total_frais = valeur_ombre − valeur_reelle       # frais payés + gains qu'ils auraient produits
frais_payes      = somme des frais débités              # partie visible
manque_a_gagner  = cout_total_frais − frais_payes      # partie invisible
```

Le jumeau sans frais coûte quelques lignes au développeur et donne, avec l'argent réel du joueur, la phrase la plus parlante de la démo : « Vos frais vous ont coûté X F, dont Y F payés et Z F de gains qui n'ont jamais existé. »

### 5.3 Exemples chiffrés (calculés et vérifiés)

**Hypothèse affichée partout : 7 % de rendement brut par an** (ordre de grandeur des actions françaises sur longue période, dividendes réinvestis : 02 indique ≈ 9 % par an de 1987 à 2025 ; 7 % est volontairement prudent). C'est une **hypothèse de calcul, jamais une promesse** : M. Lefranc doit le dire.

**A. L'exemple du joueur : 10 000 placés, 0,5 % contre 2,5 % de frais annuels, 7 % brut** (valable en euros comme en francs : seuls les multiplicateurs comptent)

| Durée | Sans frais (7 %) | Frais 0,5 % (6,5 % net) | Frais 2,5 % (4,5 % net) | **Manque à gagner** (0,5 % − 2,5 %) | Gains perdus avec 2,5 %, par rapport à 0,5 % | Gains perdus avec 2,5 %, par rapport à « sans frais » (formule 3) |
|---|---|---|---|---|---|---|
| 10 ans | 19 672 | 18 771 | 15 530 | **3 241** | 37 % | 43 % |
| 20 ans | 38 697 | 35 236 | 24 117 | **11 119** | 44 % | 51 % |
| 30 ans | 76 123 | 66 144 | 37 453 | **28 691** | 51 % | 58 % |

À 20 ans : avec 0,5 % de frais, le joueur garde 25 236 de gains ; avec 2,5 %, 14 117. **Deux points de frais coûtent 44 % des gains, soit environ 4 mois de salaire moyen net de 2025 (≈ 2 750 €).**

**B. Hypothèse prudente : 4 % brut (obligations, fonds en euros)** : quand le rendement est faible, les frais pèsent encore plus.

| Durée | Frais 0,5 % (3,5 % net) | Frais 2,5 % (1,5 % net) | Manque à gagner | Part des gains (à 0,5 %) perdue |
|---|---|---|---|---|
| 10 ans | 14 106 | 11 605 | 2 501 | 61 % |
| 20 ans | 19 898 | 13 469 | 6 429 | 65 % |
| 30 ans | 28 068 | 15 631 | 12 437 | 69 % |

**C. En francs, dans la démo (1984-1988) : 10 000 F en SICAV actions, 7 % brut**

| Formule | 5 ans (durée de la démo) | 10 ans | 20 ans | 30 ans |
|---|---|---|---|---|
| Sans aucun frais (référence théorique) | 14 026 F | 19 672 F | 38 697 F | 76 123 F |
| **SICAV de la démo** : 2 % d'entrée + 1,5 %/an (9 800 F × 1,055^n) | 12 808 F | 16 740 F | 28 594 F | 48 843 F |
| SICAV « maison » chargée : 4,5 % d'entrée + 2,5 %/an (9 550 F × 1,045^n) | 11 901 F | 14 831 F | 23 032 F | 35 768 F |
| Coût des frais de la SICAV de la démo (sans frais − démo) | 1 218 F | 2 932 F | 10 103 F | 27 280 F |
| Écart entre les deux SICAV | 907 F | 1 909 F | 5 562 F | 13 075 F |

Autres exemples en francs (règles de la démo) :
- **Courtage minimum** : un ordre de 1 000 F coûte 50 F, soit 5 % ; avec 50 F de plus à la revente, l'action doit monter d'environ **10,5 %** pour rentrer dans ses frais (formule 5 : 1,05 / 0,95 − 1). Pour un ordre de 10 000 F : 130 F, et une hausse nécessaire d'environ **2,6 %**.
- **Assurance-vie, 4 % sur les versements** : sur 20 000 F, 800 F partent tout de suite. Avec un fonds en francs à 11,5 % (1985) contre 6 % au Livret A, ils sont « remboursés » en **≈ 10 mois** (formule 6 : ln(1/0,96) / ln(1,115/1,06) = 0,81 an). Sur un versement de 500 F par mois pendant 20 ans, ce sont 4 800 F de frais d'entrée au total.
- **PEL** : aucun frais ; 500 F par mois pendant 4 ans à 8,25 % → ≈ 28 150 F (formule 4).

**D. En euros (P2-P3) : 10 000 € à 7 % brut, SICAV de réseau contre ETF**

| Durée | SICAV de réseau : 3 % d'entrée + 2 %/an | ETF : 0 % d'entrée + 0,25 %/an | **Écart** |
|---|---|---|---|
| 10 ans | 15 800 € | 19 217 € | **3 417 €** |
| 20 ans | 25 737 € | 36 928 € | **11 191 €** |
| 30 ans | 41 923 € | 70 963 € | **29 040 €** |

Vérifications : 1,065^20 = 3,5236 ; 1,045^20 = 2,4117 ; 1,07^20 = 3,8697 ; 1,055^20 = 2,9178 ; 1,0675^20 = 3,6928 ; 1,05^20 = 2,6533 ; 1,035^20 = 1,9898 ; 1,015^20 = 1,3469 (calculs par logarithmes, arrondis à l'unité).

### 5.4 Moments de jeu qui font ressentir les frais

| id | Moment | Texte ou mécanique | Pourquoi |
|---|---|---|---|
| **F01** | « En savoir plus » de la SICAV (D05), ou 1er achat de SICAV | « Un mot sur les frais, dont on parle trop peu. Sur vos {m} F, {m × 0,02} F partent dès l'achat, puis 1,5 % chaque année, sur tout votre capital. Avec 7 % de hausse moyenne par an, une hypothèse et pas une promesse, 10 000 F deviennent 38 700 F en 20 ans sans frais, et 28 600 F avec : 10 000 F d'écart. » | L'exemple du joueur, à l'échelle de la démo |
| **F02** | Relevé de décembre (notification sans pause, avec le bilan annuel L21) | « Relevé de fin d'année : vos placements vous ont coûté {frais_annee} F de frais cette année (entrée, courtage, gestion), soit {baguettes} baguettes. Depuis le début : {frais_payes} F payés, et {manque_a_gagner} F de gains que cet argent aurait produits. » | Rend visible l'invisible (frais de gestion), avec le jumeau sans frais (formule 7) |
| **F03** | Avertissement dans le tiroir, quand `frais_ordre / montant > 2 %` | « Petit ordre, gros frais : pour {m} F d'actions, le minimum de 50 F représente {50 / m × 100} %. À l'achat et à la revente, l'action devra monter d'environ {hausse} % avant que vous gagniez un franc. Un seul ordre groupé coûte moins cher. » | Leçon immédiate, au moment de la décision |
| **F04** | Bouton « Y a-t-il moins cher ? » (L22), jeu complet | Réponse honnête de M. Lefranc, chiffrée sur 20 ans avec la formule 1 | Montre le conflit d'intérêts sans le caricaturer |
| **F05** | P2, 01/2001 (arrivée des ETF) | « Nouveau : des fonds qui se contentent de copier l'indice, les trackers. 0,25 % de frais par an au lieu de 2 %, et pas de droits d'entrée. Sur 10 000 € et 20 ans, avec 7 % de hausse moyenne (hypothèse), c'est 36 900 € au lieu de 25 700 € : l'écart paie une voiture. » | Leçon centrale de P2-P3 |
| **F06** | Écran de fin de démo | Ligne « Frais payés : X F (Tata Livret : 0 F) » à côté de la comparaison avec Tata Livret (12 §3.5) | Répond aussi au retour du 27/10 sur la comparaison avec « tout sur le Livret A » |

---

## 6. Pour la prochaine démo, et pour plus tard

### 6.1 Indispensable pour la démo V2 (01/1984 → 12/1988)

| # | Élément | Pourquoi |
|---|---|---|
| 1 | Paramètres datés des **9 lignes** (§1.7.1), dont le taux du PEL **figé à l'ouverture** et les **3 baisses du Livret A** | Exactitude historique |
| 2 | **Assurance-vie** : 4 % sur versements, taux crédités au 31/12 (§1.7.1), **rachats à 45 / 25 / 15 / 0 %** selon l'âge du contrat (§1.7.2, D5), badge « hors succession » | Demande explicite du joueur |
| 3 | Réponse du client à **D4** (Gérard et Sylvie mariés ou non) | Change le texte D04 |
| 4 | **Héritage de tante Odette** : 60 000 F d'assurance-vie en 04/1988, comparés à 32 500 F nets par succession (§1.7.4, un seul pot) | Exigence de 12 §3.2 |
| 5 | Présentations **D01 à D08 bis** (§4.0), avec les calculs sur l'argent du joueur | R3 |
| 6 | Notes de comparaison sur 4 critères (§2.4) | R8 |
| 7 | **Jumeau sans frais** (formule 7), relevé F02, avertissement F03, ligne F06 | Retour du 27/10 sur les frais |
| 8 | Bulles (?) des simplifications (§1.3.3) et de D3 (Livret A au guichet) | Honnêteté historique |

### 6.2 Plus tard

| Élément | Remarque |
|---|---|
| CEL, compte à terme, bon du Trésor, SICAV obligataire | Peu de leçons nouvelles par rapport aux 10 produits de la démo |
| Encadré « transmission » au bilan de fin (droits avec / sans assurance-vie, §1.3.4 et §1.4) | Rend l'avantage successoral chiffré ; à faire dès que les enfants existent en jeu |
| Statut de couple modifiable (mariage, Pacs, divorce) | La démo fige Gérard et Sylvie (D4) ; le jeu complet débloque L16 et l'argument « conjoint » (avant 2007) |
| Produits de 1984-1988 en silhouette (LEP, Codevi, CEL, SICAV monétaire, or) | Achetables dans le jeu complet (§1.3) |
| Assurance-vie en unités de compte, contrats « d'association » ou en ligne moins chargés | Avec le travers « Y a-t-il moins cher ? » (L22) |
| Réduction d'impôt sur les primes d'assurance-vie, CEA, PER 1988, PEP, PERP, PER 2019 | Supposent de modéliser l'impôt sur le revenu (tranche marginale) |
| Condition de ressources fine du LEP | Démo : jeune salarié éligible, ou pendant un chômage |
| Seuil de cessions, taux de service des privatisations, actions gratuites, droits de garde | Option « fidèle » de V2 (A6) ; la fiscalité réelle des rachats d'assurance-vie entre, elle, dans la démo (D5) |
| Catalogues P2 et P3 complets (§1.5, §1.6) | Après la démo P1 |
| Travers « faire tourner le portefeuille », mode « banquier réaliste » (Livret A absent des banques avant 2009) | Pour joueurs avancés |

---

## 7. Points encore incertains

| Sujet | Valeur retenue | Cert. | Pour fiabiliser |
|---|---|---|---|
| Conditions exactes de l'article 757 B de 1980 (âge, primes) | Seuil de 100 000 F ; contrats souscrits tard avec primes concentrées | C | Légifrance, version historique de l'art. 757 B (loi n° 80-30, art. 68) |
| Plafond du Codevi en 1986-1988 | 10 000 F (15 000 F avant 1993, 20 000 F au 01/07/1993, 30 000 F le 01/10/1994) | C | Décret n° 83-872 et ses modificatifs |
| Condition de ressources du LEP en 1986 | Foyers peu ou pas imposés | C | Textes de 1982 (JO) |
| Taux du CEL et prime du CEL en 1986 | 2,75 % hors prime | B | Banque de France, La finance pour tous |
| Rendement moyen des fonds en francs des réseaux bancaires | AFER − 0,5 pt | C | FFSA (France Assureurs), rapports annuels 1985-1995 |
| Taux monétaires annuels 1978-1992 | Tableau §1.3.2 | B/C | Banque de France (TMM, TJJ) : **à valider par le boursier** |
| Taxe forfaitaire sur l'or en 1986-1988 | ≈ 6-7,5 % (4 % en 1976, 7,5 % + 0,5 % plus tard) | C | CGI art. 150 V bis, versions historiques |
| Action gratuite des privatisations (1 pour 10 conservées 18 mois) et son plafond | Retenu sans plafond | B | Notes d'opération COB de 1986 |
| Durée minimale des contrats ouvrant droit à la réduction d'impôt sur les primes | — | C | CGI art. 199 septies historique |
| Date de la privatisation de Suez | 10/1987 (01, 02) ; l'IGPDE donne « 10/05/1987 » | B | À vérifier par le boursier (format de date ambigu) |
| Taux du PEL ouvert en 1984-1985, prime comprise | 6,30 % puis 5,30 % hors prime (B) ; ≈ 8,25 % et ≈ 7 % prime comprise (C, rapport de 1986 appliqué) | B/C | Arrêtés au JO ; séries INSEE « placements à rendement réglementé » |
| Montant de l'héritage d'Odette | 60 000 F d'assurance-vie (un seul pot) | C (scénario) | — |
| Formes réelles des versements programmés en 1984-1988 (§8.1) : plans en SICAV, minimums | Voir §8.1 | B/C | Archives de tarifs bancaires, presse (Le Revenu, Mieux vivre), AFG |
| Versements minimaux du PEL avant le décret de 1992 (3 600 F par an) | 300 F par mois | B/C | Arrêtés au JO (CCH, art. R. 315-24 et suivants, versions antérieures à 1992) |
| Frais typiques par époque (§5.1) | Fourchettes | B | Études AMF, guides de La finance pour tous, tarifs bancaires archivés |

---

## 8. Versements programmés (retour du joueur du 2026-10-27, démo V2)

> « Rajoute fonctionnalité de versement automatique mensuel sur les supports qui le peuvent. »
> Principe : un ordre permanent, réglé une fois, qui verse chaque mois le même montant du compte courant vers un placement. Seuls les supports qui le permettaient réellement en 1984-1988 le proposent.

### 8.1 Les 9 produits de la démo : éligibilité et forme réelle

| Produit (`banque.json`) | Versement mensuel automatique en 1984-1988 ? | Forme réelle | Minimum par mois (réel / **jeu**) | Frais par versement (**jeu**) | Contraintes | Cert. |
|---|---|---|---|---|---|---|
| `livret` Livret A | **Oui** | **Virement permanent** du compte vers le livret (Caisse d'épargne ou Poste, depuis un compte bancaire ou un CCP) | ≈ 10 F par opération / **100 F** | **0** | **Plafond** des dépôts : 58 000 F → 68 000 F (15/06/1984) → 72 000 F (31/05/1986) → 80 000 F (30/06/1987) ; les intérêts du 31/12 peuvent le dépasser | A (plafonds), B (virement, minimum) |
| `pel` PEL | **Oui, et obligatoire** (déjà le cas dans la démo) | **Versements périodiques fixés au contrat** (mensuels, trimestriels ou semestriels), prélevés automatiquement ; versements libres en plus possibles | **3 600 F par an**, soit **300 F** par mois / **300 F** (choix 300, 500, 1 000 F) | **0** | Minimum annuel à respecter, sinon le plan peut être résilié ; plafond 400 000 F ; montant modifiable par avenant | B (règles), B/C (3 600 F avant le décret de 1992 : aujourd'hui 540 € ≈ 3 542 F) |
| `emprunt` Emprunt d'État | **Non** | Voir §8.2 | — | — | — | A/B |
| `av` Assurance-vie | **Oui** | Contrats **à primes périodiques** ou **versements libres programmés** par prélèvement mensuel (courants dans les réseaux et chez les assureurs) | ≈ 150 à 500 F selon les contrats / **300 F** | **4 %** sur chaque versement (réel 3 à 5 %) | Horloge fiscale des rachats comptée **depuis la souscription** (jeu, simplifié) ; capital garanti | B (forme), C (minimums) |
| `sicav` SICAV actions | **Oui** | **Souscription périodique** à la valeur liquidative par prélèvement (« plan d'épargne » ou « versements programmés » des réseaux bancaires) ; SICAV de distribution (la capitalisation n'est autorisée qu'au 01/10/1989) | ≈ 200 à 500 F / **300 F** | **2 %** sur chaque versement (réel 2 à 4,5 %) | Aucune garantie ; prix = valeur liquidative du jour du versement | B (principe), C (nom commercial, minimums) |
| `elf`, `loreal`, `peugeot` Actions | **Non** | Voir §8.2 | — | — | — | A |
| `saintgobain` Saint-Gobain | **Non** | Offre unique du 24/11 au début 12/1986, puis action cotée comme les autres (§8.2) | — | — | — | A |

Simplification à signaler en bulle (?) : « Simplifié : en 1984-1988, une SICAV s'achetait souvent par parts entières ; le jeu achète des fractions de part. » (C)

### 8.2 Pourquoi pas les actions ni l'emprunt d'État (et ce qui s'en approchait)

**Actions en direct (Elf, L'Oréal, Peugeot, puis Saint-Gobain)**
- Chaque achat est un **ordre** transmis par la banque à l'**agent de change** : aucun service ne répétait un ordre chaque mois. Les plans d'achat programmé d'actions arrivent bien plus tard, chez les courtiers en ligne (années 2010-2020, C).
- Le **courtage minimum** rend l'idée ruineuse : 500 F par mois → 50 F de courtage, soit **10 %** à l'achat (≈ 20 % aller-retour). Ordre groupé de 3 000 F par trimestre : 50 F, soit 1,7 %.
- **Pas de fraction d'action** : une action vaut de 180 à 800 F dans le jeu (`periode_p1.json`) ; 300 F par mois n'achètent parfois rien.
- Ce qui s'en approchait : les **clubs d'investissement** (cotisation mensuelle de quelques centaines de francs, achats décidés en commun ; fédération nationale fondée en 1968, B) ; l'**actionnariat salarié** (plan d'épargne d'entreprise de 1967, prélevé sur le salaire, A) ; et surtout le **plan en SICAV**, qui est la vraie réponse de l'époque.
- Dans le jeu : pas de bouton « automatique » sur les actions ; la bulle (?) dit : « Pas de versement automatique en actions : chaque ordre coûte au moins 50 F. Pour investir un peu chaque mois en Bourse, on passait par une SICAV. »

**Emprunt d'État**
- L'État n'emprunte **qu'à dates fixes** : quelques grands emprunts au guichet par an jusqu'en 1985, puis des **OAT** émises par adjudication auprès des banques (B). Entre deux émissions, il faut acheter en Bourse, avec courtage et coupon couru.
- Dans le jeu, chaque achat crée une **tranche** à 10 ans au taux de l'année (A13) : un versement mensuel créerait 60 lignes en 5 ans, sans leçon nouvelle.
- Ce qui s'en approchait : les **SICAV obligataires** à versements programmés (silhouette, hors démo), ou le réemploi des coupons à chaque échéance.

### 8.3 Règles simplifiées pour le jeu

| # | Règle | Détail |
|---|---|---|
| VP1 | **Moment** | Le 1er du mois, juste **après le salaire**, avant les dépenses et les événements du mois. |
| VP2 | **Ordre** | PEL d'abord (obligatoire), puis les autres plans dans l'ordre de leur création. |
| VP3 | **Tout ou rien, jamais de découvert** | Un versement n'est exécuté que si le compte courant, après versement, couvre encore les **dépenses prévues du mois**. Sinon : **non effectué**, sans frais, notification sans pause « Versement de {v} vers {produit} non effectué : compte insuffisant ». Garde-fou du jeu : une vraie banque exécutait le virement dès que le solde le permettait (et facturait parfois un rejet). |
| VP4 | **Suspension** | Après **3 refus de suite** (hors PEL), le plan est suspendu ; message persistant ; réactivation d'un toucher. Rien n'est suspendu d'office lors d'un chômage ou d'une naissance : VP3 suffit. |
| VP5 | **Plafond du Livret A** | Le versement est réduit à `plafond − solde`. À 0 : plan suspendu, message « Votre Livret A est plein ({plafond}) : le versement est suspendu, l'argent reste sur votre compte courant. » Au relèvement du plafond (06/1984, 05/1986, 06/1987), le message de la banque propose de le **réactiver** (jamais automatiquement). Les intérêts du 31/12 peuvent dépasser le plafond. |
| VP6 | **PEL** | Versement de 300 F au moins, modifiable (effet le mois suivant). À la **date anniversaire**, si les 12 derniers mois totalisent moins de 3 600 F, M. Lefranc propose de **régulariser** (le manque est prélevé si le compte le permet) ; sinon le plan est clos aux conditions de clôture habituelles (taux réduit de 2,75 % avant 4 ans). |
| VP7 | **Frais d'entrée** | Prélevés sur **chaque** versement (assurance-vie 4 %, SICAV 2 %) et comptés dans le jumeau sans frais (§5.2, formule 7) et le relevé annuel. |
| VP8 | **SICAV** | Achat à la valeur liquidative du mois, en fractions de part. |
| VP9 | **Assurance-vie** | Les versements n'ouvrent pas de nouvelle horloge fiscale : l'âge du contrat compte depuis la souscription. |
| VP10 | **Réglage** | Dans le tiroir du produit : montants proposés 100, 200, 300, 500, 1 000 F (minimum du produit), modifier ou arrêter à tout moment, effet le mois suivant. Un seul plan par produit. Les versements ponctuels restent possibles. |
| VP11 | **Visibilité** | Une icône « calendrier » sur la carte du produit ; ligne « Versements automatiques : {total} par mois » dans le budget de la maison, pour voir ce qui part avant les dépenses. |

### 8.4 Pédagogie : investir un peu, chaque mois

- **Se payer en premier** : l'épargne part le jour de la paye, avant les dépenses ; on vit avec le reste, au lieu d'épargner « ce qui reste » (souvent rien).
- **Régularité** : un plan supprime la décision de chaque mois, donc l'hésitation et la tentation d'attendre « le bon moment ».
- **Lisser le prix d'achat** (sur la SICAV) : un montant fixe achète plus de parts quand le prix baisse. Exemple : 500 F à 100 F, 80 F puis 125 F la part → 5 + 6,25 + 4 = **15,25 parts** pour 1 500 F, soit **98,36 F** la part en moyenne, contre 101,67 F de prix moyen (hors frais).
- **Honnêteté** : le lissage ne garantit aucun gain, et une somme **déjà disponible**, placée en une fois, a en moyenne fait mieux sur longue période, parce que les marchés montent plus souvent qu'ils ne baissent (B). L'intérêt du plan est d'épargner son salaire au fil de l'eau et d'éviter de tout acheter au plus haut. En octobre 1987, le plan continue d'acheter, à prix bas, sans que le joueur ait à oser.

**Textes de M. Lefranc** (variables calculées sur l'argent du joueur ; `{v12}` = 12 × `{v}`, hors intérêts)

| id | Quand | Texte |
|---|---|---|
| **VP-A** | Une fois, notification persistante sans pause, 3 mois après la première ouverture d'un produit éligible, si aucun plan n'est actif (respecte la cadence 13 §5.3) | « {prenom}, la banque peut virer automatiquement une somme le 1er de chaque mois, juste après votre paye. Avec {v} par mois, vous aurez {v12} de côté dans un an, sans y penser : l'épargne passe avant les dépenses, pas après. Montant et placement à votre choix ; vous arrêtez quand vous voulez. » (50 mots ; ex. 500 F → 6 000 F) |
| **VP-B** | « En savoir plus » de la SICAV, ou à l'activation d'un plan sur la SICAV | « Avec un versement fixe chaque mois, vous achetez plus de parts quand la SICAV baisse, moins quand elle monte. Exemple : 500 F par mois à 100, 80 puis 125 F la part : 15,25 parts, payées 98,36 F en moyenne, contre 101,67 F de prix moyen. Aucune garantie de gain, mais on évite de tout acheter au plus haut. » (58 mots) |
| **VP-C** | Ajoutée à l'activation d'un plan sur l'assurance-vie ou la SICAV | « Rappel : {e_pct} % de frais d'entrée sur chaque versement, soit {frais_v} sur vos {v} chaque mois, {frais_an} par an. » (ex. assurance-vie 500 F : 20 F par mois, 240 F par an ; SICAV 500 F : 10 F, 120 F) |
| VP-D (option) | 11/1987, si un plan SICAV est actif ; notification sans pause | « Ce mois-ci, vos {v} ont acheté {n} parts de SICAV, contre {n0} en septembre : même somme, parts moins chères. Personne ne sait si la baisse continuera. » |

Aucun de ces textes ne nomme un produit à privilégier : VP-A laisse le choix du placement, VP-B et VP-C ne s'affichent que sur un produit déjà choisi par le joueur.

---

## 9. Sources consultées (recherches des 26 et 27/10/2026)

- [Question écrite n° 35859 (8e législature), JO AN du 01/02/1988, réponse du 14/03/1988](https://questions.assemblee-nationale.fr/dyn/8/questions/QANR5L8QE35859.pdf) : « abattement minimum » de 10 000 F sur chaque part successorale (art. 788 CGI), en vigueur depuis le 01/01/1974 et non relevé en 1988.
- [Banque de France, épargne logement](https://www.banque-france.fr/fr/a-votre-service/particuliers/connaitre-pratiques-bancaires-assurance/epargne/epargne-logement) : versements mensuels, trimestriels ou semestriels, 540 € par an au minimum, clôture en cas de non-respect.
- [Office québécois de la langue française, SICAV de capitalisation](https://vitrinelinguistique.oqlf.gouv.qc.ca/fiche-gdt/fiche/17563543/sicav-de-capitalisation) : autorisées en France depuis le 01/10/1989.

- [Docteur-factures, historique des taux du PEL](https://www.docteur-factures.fr/historique-taux-pel-1983/) et [MoneyVox, PEL ancien](https://www.moneyvox.fr/placement/PEL-ancien.php) : 6,30 % (06/1983-07/1984), 5,30 % (08/1984-06/1985), 4,75 %, 4,62 % ; prime intégrée pour les PEL antérieurs au 12/12/2002.

- [Réponse ministérielle n° 3073, JO AN du 06/09/1993](https://questions.assemblee-nationale.fr/dyn/10/questions/QANR5L10QE3073.pdf) : réforme de 1991 (loi n° 91-1323, art. 26), seuil de 200 000 F, exonération totale des contrats antérieurs au 20/11/1991.
- [Barèmes IPP, assurance-vie, souscriptions après 1991](https://baremes.ipp.eu/parameters/droits-de-mutation/droits_mutation_titre_gratuit.assurance_vie.souscription_apres_91/table) : 100 000 F (loi du 19/01/1980, art. 68), 200 000 F (1992), 1 MF (1999), 152 500 € et 30 500 € (2002), taux du 990 I (2011, 2014).
- [BOFiP BOI-ENR-DMTG-10-10-20-20](https://bofip.impots.gouv.fr/bofip/3456-PGP.html/identifiant=BOI-ENR-DMTG-10-10-20-20-20160701) : champ de l'art. 757 B (contrats depuis le 20/11/1991, primes après 70 ans).
- [Legifiscal, réponse ministérielle du 16/10/2012](https://www.legifiscal.fr/actualites-fiscales/013-fiscalite-de-lassurance-vie-limposition-des-primes-versees-au-deces-de-lassure.html) : articulation 757 B / 990 I, date du 13/10/1998.
- [AFER, rendements du Fonds Garanti depuis 1977](https://www.afer.fr/content/uploads/tableau-comparatif-FG-AFER-VF.pdf) : 11,51 % (1986), 10,35 % (1987), 10,05 % (1988)…
- [Documentissime, rachats des contrats 1983-1990](https://www.documentissime.fr/dossiers-droit-pratique/dossier-133-la-fiscalite-des-assurances-sur-la-vie/le-rachat-ou-le-denouement-de-l-assurance-vie/contrats-souscrits-apres-1983-et-avant-1990.html) et [IPP, prélèvement libératoire assurance-vie](https://www.ipp.eu/baremes-ipp/taxation-du-capital/taxation_capital.prelevement_forfaitaire.liberatoire_assurance_vie/table) : 45 / 25 / 15 %, puis 8 ans en 1990.
- [Question écrite n° 6522 (10e législature)](https://questions.assemblee-nationale.fr/dyn/10/questions/QANR5L10QE6522.pdf) et [n° 736 (11e législature)](https://www.assemblee-nationale.fr/dyn/11/questions/QANR5L11QE736.pdf) : réduction d'impôt de 25 % des primes, 4 000 F + 1 000 F par enfant ; suppression en 1996-1997.
- [BNP Paribas, Cardif et Triplan (1981)](https://group.bnpparibas/communique-de-presse/etude-commanditee-cardif-natio-vie-bnp-paribas-l-assurance-vie-multisupport-reste-placement-d-avenir) : premier multisupport d'un réseau bancaire.
- [Question écrite sur le PER de 1988](https://questions.assemblee-nationale.fr/dyn/8/questions/QANR5L8QE30571.pdf) et [n° 16801 (9e législature)](https://questions.assemblee-nationale.fr/dyn/9/questions/QANR5L9QE16801.pdf) : loi du 17/06/1987, lancement le 01/01/1988, déduction de 8 000 / 16 000 F, remplacement par le PEP.
- [Question écrite n° 5251 (9e législature)](https://www.assemblee-nationale.fr/dyn/9/questions/QANR5L9QE5251.pdf) : CEA prorogé pour 1988, non alimentable depuis le 01/01/1989.
- [Question écrite n° 18216 (10e législature)](https://questions.assemblee-nationale.fr/dyn/10/questions/QANR5L10QE18216.pdf) et [Légifrance, décret Codevi](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000000732379) : plafonds du Codevi.
- [Meilleurtaux, plafonds des livrets](https://placement.meilleurtaux.com/livret-epargne/plafond-livret-epargne.html) : LEP 5 000 F (1982), 10 000 F (1983), 20 000 F (1984), 30 000 F (1991), 40 000 F (1999) ; [LEP à 10 000 € au 1er octobre 2023](https://placement.meilleurtaux.com/livret-epargne/actualites/2023-octobre/elargissement-livret-epargne-populaire-10000-euros-1er-octobre.html).
- [Empruntis, historique du CEL](https://www.empruntis.com/financement/prets-bancaires/plan-epargne-logement-pel/cel/) : 2,75 % à partir du 16/05/1986.
- [La finance pour tous, PEL et prime d'État](https://www.lafinancepourtous.com/pratique/placements/epargne-logement/le-plan-epargne-logement-pel-une-epargne-de-projet/pel-et-prime-d-etat/comment-page-25/?lang=en) : prime sans prêt avant le 12/12/2002.
- [Question écrite n° 1500 (9e législature)](https://questions.assemblee-nationale.fr/dyn/9/questions/QANR5L9QE1500.pdf) : abattement de 275 000 F (1984), 300 000 / 330 000 F (1992).
- [Rapport du Sénat 1988-1989 n° 85](https://conferenceconsensuslogement.senat.fr/rap/1988-1989/i1988_1989_0085.pdf) : SICAV de trésorerie, 424 Md F en 1987.
- [IGPDE, les privatisations de 1986-1988](https://books.openedition.org/igpde/3866?dir=next) et [Saint-Gobain, document de référence 2004](https://www.bnains.org/archives/communiques/Saint_Gobain/20050601_Actualisation_du_document_de_reference_2004_Saint_Gobain.pdf) : mise en vente le 24/11/1986, 310 F.
- [BOFiP, bons du Trésor sur formules](https://bofip.impots.gouv.fr/bofip/3743-PGP.html/identifiant%3DBOI-RPPM-RCM-30-10-20-30-20171004) : fin d'émission au 01/01/1999, régime de l'anonymat.
- [Question écrite n° 125 (12e législature)](https://www.assemblee-nationale.fr/dyn/12/questions/QANR5L12QE125.pdf) et [achat-or-et-argent.fr](https://www.achat-or-et-argent.fr/contenu-67-302-1916-les-legislations-en-vigueur-pour-acheter-de-l-or) : taxe forfaitaire sur l'or (loi de 1976, 4 % à l'origine).
