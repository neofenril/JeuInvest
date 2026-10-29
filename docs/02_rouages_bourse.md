# 02 — Les rouages de la Bourse (référentiel métier pour JeuClaude)

> Rédigé du point de vue d'un « vieux de la vieille » : ancien agent de change au palais Brongniart (époque de la criée), puis gérant et analyste à l'ère électronique.
> Objectif : donner au game designer et au développeur **les notions à enseigner, l'histoire des mécanismes, les grands événements, des séries de données exploitables et des règles de simulation**.
> Contenu **pédagogique uniquement** : aucune recommandation d'investissement personnalisée.

## Légende des niveaux de certitude

| Code | Signification | Usage dans le jeu |
|---|---|---|
| **A** | Donnée officielle vérifiée (source publique : Euronext, INSEE, OCDE/FRED, presse financière) | Utilisable telle quelle |
| **B** | Donnée de mémoire professionnelle recoupée partiellement, erreur probable < 5-10 % | Utilisable, afficher « environ » |
| **C** | Reconstitution / estimation cohérente avec quelques points d'ancrage, erreur possible 10-25 % | Acceptable pour un jeu, à signaler dans les crédits (« données reconstituées ») |

Sources principales consultées (oct. 2026) : tableau annuel CAC 40 de Wikipédia (rétropolé jusqu'en 1969, chaîné sur l'indice CAC Général), Tradingsat/Boursorama (clôture 2025), FRED/Banque mondiale (inflation France 1960-2025, taux 10 ans France 1960-2025), réponse ministérielle AN n° 38037 (inflation INSEE 1979-2008), archives Larousse « Journal de l'année » (Bourse 1966-1994), Tradingsat (pires séances du CAC, meilleure année 1954), Moneyvox (TTF), ADCF/Ramify (Livret A). Liens en fin de document.

---

## 1. Notions de bourse à faire découvrir (du plus simple au plus avancé)

Chaque notion est rattachée à un **niveau de déblocage** suggéré. L'idée : le joueur découvre une notion au moment où le jeu la rend utile (souvent juste après un événement qui l'illustre).

### Niveau 1 — Les fondations (premières minutes de jeu)

| # | Notion | Explication pour débutant | Déclencheur suggéré dans le jeu |
|---|---|---|---|
| 1 | **Épargne sans risque (Livret A, compte sur livret)** | Votre argent est garanti et rapporte un petit intérêt fixé par l'État. C'est le point de comparaison de tout placement : « est-ce que je fais mieux que le Livret A ? ». | Dès le départ, capital initial placé sur Livret A |
| 2 | **Action** | Une action est une petite part de propriété d'une entreprise. Si l'entreprise prospère, la valeur de la part monte et vous touchez une partie des bénéfices ; si elle échoue, vous pouvez tout perdre. | Premier achat |
| 3 | **Cours / capitalisation** | Le cours est le prix d'une action à un instant donné, fixé par la rencontre des acheteurs et des vendeurs. Cours × nombre d'actions = capitalisation, la « valeur de marché » de l'entreprise. | Écran de cotation |
| 4 | **Obligation** | Une obligation est un prêt que vous faites à l'État ou à une entreprise : vous recevez un intérêt fixe (le coupon) chaque année, puis votre capital à l'échéance. Moins risquée qu'une action, mais pas sans risque. | Emprunt d'État proposé (ex. emprunt Pinay 1952, Giscard 1973, Balladur 1993) |
| 5 | **Dividende** | Part du bénéfice que l'entreprise verse chaque année à ses actionnaires, en espèces. Sur longue période, les dividendes représentent une part énorme (souvent près de la moitié) du gain total d'un actionnaire. | Premier versement annuel (en général au printemps) |
| 6 | **Indice boursier** | Un indice (CAC 40, et avant lui l'indice INSEE ou CAC Général) est un « panier » de grandes actions qui résume la tendance du marché. Quand on dit « la Bourse a monté de 2 % », on parle de l'indice. | Bandeau permanent en haut de l'écran |

### Niveau 2 — Passer des ordres et maîtriser les coûts

| # | Notion | Explication pour débutant | Déclencheur |
|---|---|---|---|
| 7 | **Ordre au marché** | Vous achetez ou vendez « à n'importe quel prix », immédiatement. Pratique, mais en cas de panique vous pouvez être exécuté à un prix très défavorable. | Premier ordre |
| 8 | **Ordre à cours limité** | Vous fixez un prix maximum (achat) ou minimum (vente). Vous maîtrisez le prix, mais l'ordre peut ne jamais être exécuté. | Débloqué après une exécution « au marché » défavorable |
| 9 | **Carnet d'ordres et fourchette (spread)** | Le carnet liste les acheteurs et vendeurs en attente ; l'écart entre le meilleur prix d'achat et de vente est la fourchette. Plus une action est peu échangée, plus la fourchette est large et coûteuse. | Petites valeurs / Second marché / Nouveau Marché |
| 10 | **Frais (courtage, impôt de bourse/TTF, droits de garde)** | Chaque opération coûte une commission au courtier, parfois une taxe, et la simple conservation des titres peut être facturée. Des frais de 1 % par an semblent faibles mais grignotent un quart du capital en 30 ans. | Récapitulatif annuel des frais |
| 11 | **Fiscalité et enveloppes (CTO, PEA, assurance-vie)** | Les gains et dividendes sont imposés, mais certaines enveloppes (PEA depuis 1992, assurance-vie) offrent des avantages si l'on garde l'argent longtemps. Le choix de l'enveloppe change le résultat final autant que le choix des actions. | 1978 (SICAV Monory), 1992 (PEA), 2018 (flat tax) |

### Niveau 3 — Comprendre le risque et le temps

| # | Notion | Explication pour débutant | Déclencheur |
|---|---|---|---|
| 12 | **Diversification** | Ne pas mettre tous ses œufs dans le même panier : en détenant plusieurs entreprises de secteurs différents, la faillite de l'une ne vous ruine pas. C'est la seule « protection gratuite » en bourse. | Effondrement d'une action détenue (Eurotunnel, France Télécom, Vivendi, Natixis) |
| 13 | **Fonds / SICAV / FCP / ETF (trackers)** | Un fonds rassemble l'argent de nombreux épargnants pour acheter un portefeuille diversifié géré par un professionnel ; un ETF réplique simplement un indice à frais réduits. | SICAV (1964), SICAV Monory (1978), trackers CAC 40 (2001) |
| 14 | **Intérêts composés** | Les gains produisent eux-mêmes des gains : 7 % par an double le capital en ~10 ans, le quadruple en ~20 ans. Le temps passé investi compte plus que le montant de départ. | Écran « et si vous aviez commencé 10 ans plus tôt » |
| 15 | **Inflation et rendement réel** | L'inflation fait monter les prix et réduit ce que votre argent peut acheter. Un placement à 8 % quand l'inflation est à 13 % (France 1980) vous **appauvrit** de ~5 % par an : c'est le rendement réel qui compte. | Années 1970 : afficher le patrimoine en euros constants |
| 16 | **Volatilité** | Mesure de l'amplitude des variations d'un placement. Une action peut gagner ou perdre 30 % dans l'année sans que rien de grave ne se passe ; plus la volatilité est forte, plus le chemin est cahoteux. | Graphique d'une action vs indice vs obligation |
| 17 | **Horizon de placement** | Sur 1 an, les actions peuvent perdre 40 % ; sur 15-20 ans, elles ont presque toujours battu le livret. On n'investit en actions que l'argent dont on n'aura pas besoin avant longtemps. | Événement de vie « achat immobilier » qui force à vendre au mauvais moment |
| 18 | **Krach et rebond** | Un krach est une chute brutale (−20 % à −60 %) souvent en quelques jours ou semaines. Historiquement, les plus fortes hausses suivent de près les plus fortes baisses : vendre dans la panique fait souvent rater le rebond. | 1974, 1987, 2001, 2008, 2020 |
| 19 | **Investissement progressif (DCA)** | Investir la même somme chaque mois, quel que soit le cours : on achète plus de titres quand c'est bas, moins quand c'est cher, et on évite le stress du « bon moment ». | Option « versement mensuel automatique » |
| 20 | **Market timing** | Tenter d'acheter au plus bas et de vendre au plus haut. Presque impossible à réussir durablement : rater les 10 meilleures séances d'une décennie divise souvent la performance par deux. | Statistique de fin de partie « jours manqués » |

### Niveau 4 — Mécanismes avancés

| # | Notion | Explication pour débutant | Déclencheur |
|---|---|---|---|
| 21 | **Valorisation (PER, rendement du dividende)** | Le PER compare le prix d'une action à son bénéfice annuel : un PER de 15 signifie qu'on paie 15 ans de bénéfices. Un PER très élevé suppose une croissance future spectaculaire. | Fiche entreprise |
| 22 | **Bulle spéculative** | Quand les prix montent parce que tout le monde espère revendre plus cher, et non grâce aux bénéfices, une bulle se forme ; elle finit toujours par éclater. Signe typique : « cette fois, c'est différent ». | 1999-2000 (TMT, Nouveau Marché) |
| 23 | **Taux d'intérêt et prix des obligations** | Quand les taux montent, les obligations anciennes (qui rapportent moins que les nouvelles) perdent de la valeur, et inversement. Une OAT 10 ans perd environ 8 % de valeur si les taux montent de 1 point. | 1994, 2022 (krach obligataire) |
| 24 | **Introduction en bourse / privatisation / OPA** | Une entreprise peut entrer en bourse (privatisation, IPO) ou être rachetée par une autre via une OPA, généralement avec une prime de 20-40 % pour l'actionnaire. Les introductions très médiatisées ne sont pas des gains garantis. | 1986-87, 1993, 1997 (France Télécom) |
| 25 | **Risque politique et risque de change** | Élections, nationalisations, dévaluations ou crises de la dette peuvent faire varier tout un marché. Un investisseur français en actions américaines gagne ou perd aussi sur le dollar. | 1958, 1981, 2011, 2024 |
| 26 | **Effet de levier / Règlement mensuel puis SRD** | Acheter avec de l'argent emprunté (ou en différant le paiement à la fin du mois) multiplie les gains… et les pertes. Avec un levier de 5, une baisse de 20 % efface tout le capital. | Débloqué après 3 ans de jeu ; « appel de marge » lors d'un krach |
| 27 | **Vente à découvert** | Vendre une action qu'on ne possède pas (en l'empruntant) pour la racheter plus bas : on gagne si elle baisse. La perte potentielle est illimitée si le cours monte. | Mode avancé ; interdictions temporaires (sept. 2008, août 2011, mars 2020) |
| 28 | **Produits dérivés (options, warrants, turbos)** | Contrats dont la valeur dépend d'une action ou d'un indice, souvent avec un fort levier. Utiles pour se couvrir, très dangereux pour spéculer : la majorité des particuliers y perdent. | MONEP (1987), warrants (années 1990-2000) |

---

## 2. Évolution des mécanismes de marché en France

### 2.1 Chronologie des institutions et de la technique

| Date | Évènement | Ce que ça change pour le particulier (gameplay) | Certitude |
|---|---|---|---|
| 1826 → 1987 | **Palais Brongniart** : cotation à la **criée** autour de la **corbeille**, par les **agents de change** (officiers ministériels, monopole) | Ordres passés via sa banque ou un agent de change, par courrier/téléphone ; on connaît son prix d'exécution le lendemain dans le journal | A |
| Avant 1961 | **La Coulisse** (marché parallèle non officiel) coexiste avec le Parquet des agents de change ; fusion au début des années 1960 | Peu visible pour le joueur | B |
| 1949 | **SICOVAM** (dépositaire central) : les titres papier sont de plus en plus conservés en compte | Droits de garde | B |
| Années 1950-2000 | Deux marchés : **comptant** (paiement immédiat) et **Règlement Mensuel (RM)** = marché à terme, liquidation en fin de mois | Sur le RM, on peut acheter en ne payant qu'à la liquidation (et « reporter » sa position) : **levier de fait** | A |
| 1960 (1er janv.) | **Nouveau franc** : 100 anciens francs = 1 NF | Les cours sont divisés par 100 à l'affichage | A |
| 1964 | Création des **SICAV** | Premiers fonds accessibles au grand public | B |
| 1965 (12 juil.) | **Avoir fiscal** : crédit d'impôt attaché aux dividendes (supprimé en 2005) | Dividende « net + 50 % d'avoir fiscal » | A |
| 1967 (28 sept.) | Création de la **COB** (Commission des opérations de bourse) | Protection des épargnants, notion de délit d'initié | A |
| 1978 (13 juil.) | **Loi Monory** : réduction d'impôt pour achat d'actions françaises, SICAV Monory | Coup de fouet à l'actionnariat populaire | A |
| 1983 (févr.) | Création du **Second Marché** (PME) | Valeurs moyennes, plus volatiles, fourchettes larges | A |
| 1984 (nov.) | **Dématérialisation** des titres (fin des titres papier) | Plus de coupons à découper | A |
| 1986 (févr.) | **MATIF** (marché à terme des instruments financiers) | Contrats sur taux puis indice | A |
| 1986 (juin) | Lancement de la **CAC — Cotation Assistée en Continu** (dérivée du système CATS de Toronto), d'abord sur quelques valeurs | Cours qui bougent en continu pendant la séance | A |
| 1986-1987 | **Privatisations** (Saint-Gobain, Paribas, CCF, TF1, Société Générale, Suez…) | Vague d'actionnaires débutants (plusieurs millions). Dates de mise en vente et prix : voir `connaissances/boursier.md` §2.6 (Saint-Gobain 24/11/1986 à 310 F ; Paribas 19/01/1987 à 405 F ; CGE 11/05/1987 à 290 F ; Société Générale 15-27/06/1987 à 407 F ; **Suez en octobre 1987**, offre ouverte juste avant le krach) | A (B pour certains prix) |
| 1987 (14 juil.) | **Démontage de la corbeille** : fin de la criée pour les actions françaises | Ambiance sonore du jeu : fin des cris ! | A (source BFM via recherche) |
| 1987 (sept.) | **MONEP** (options négociables) | Options sur actions et indice | B |
| 1987 (31 déc.) | **CAC 40** base 1000 ; publié en temps réel à partir du 15 juin 1988 | Remplace l'indice CAC Général comme baromètre | A |
| 1988 (22 janv.) | **Loi sur les bourses de valeurs** : fin du statut d'agent de change → **sociétés de bourse** (ouvertes aux banques), création de la **SBF** ; monopole ouvert progressivement jusqu'en 1992 | Libéralisation des commissions, concurrence des courtiers | A (dates fines : B) |
| 1989 | Toutes les valeurs cotées via le système CAC | Fin de la cotation manuelle | A |
| 1992 (16 juil.) | Création du **PEA** (Plan d'épargne en actions) | Enveloppe fiscale : exonération d'impôt sur les gains après 5 ans (8 ans à l'origine), hors prélèvements sociaux | A |
| ~1995 | **NSC (Nouveau Système de Cotation)** remplace le système CAC | Plus rapide, prépare l'interconnexion européenne | B (date à confirmer) |
| 1996 (févr.) | **Nouveau Marché** (valeurs de croissance / technologiques) | Haut risque ; berceau de la bulle 1999-2000 | A |
| 1998 (6 avril) | Fin de toute activité de cotation au palais Brongniart (dérivés automatisés) | — | A |
| 1999 (1er janv.) | **Euro** (cotations en euros ; 1 € = 6,55957 F) ; pièces/billets le 1er janv. 2002 | Conversion des prix | A |
| 1999-2000 | Essor des **courtiers en ligne** (Cortal, Boursorama, Self Trade…) | Frais ÷ 3 à 10, ordres depuis chez soi | B |
| 2000 (22 sept.) | **Euronext** (Paris + Amsterdam + Bruxelles ; Lisbonne et LIFFE en 2002) | — | A |
| 2000 (25 sept.) | Le **SRD (Service de Règlement Différé)** remplace le Règlement Mensuel | Levier d'environ ×5 (couverture ~20 %) sur les grandes valeurs, moyennant commission | A |
| 2003 (1er août) | **AMF** (fusion COB + CMF + CDGF) | Régulateur unique | A |
| 2005 | Fin de l'avoir fiscal (remplacé par un abattement de 40 % sur les dividendes) ; Eurolist (compartiments A/B/C), Alternext | Fiscalité des dividendes | A |
| 2007 (avril) | **NYSE Euronext** ; 2007 (nov.) directive **MIF** : fin de l'obligation de passer par la bourse, apparition de plateformes concurrentes | — | A |
| 2008 (1er janv.) | Suppression de l'**impôt sur les opérations de bourse (IOB/TOB)** | Frais en baisse | B |
| 2009 | Plateforme **UTP** remplace NSC | Trading algorithmique / haute fréquence | B |
| 2012 (1er août) | **Taxe sur les transactions financières (TTF)** 0,2 % sur l'achat d'actions françaises > 1 Md€ de capitalisation ; 0,3 % en 2017 ; 0,4 % en 2025 | À intégrer au coût d'achat des grosses valeurs | A |
| 2014 | **PEA-PME** ; Euronext redevient indépendant (introduction en bourse) | — | A |
| 2018 (1er janv.) | **PFU / flat tax 30 %** sur revenus du capital | Fiscalité simplifiée | A |
| 2019 (loi PACTE) | Assouplissement PEA, PER | — | A |
| 2018-2020 | Plateforme **Optiq** ; essor des néo-courtiers à frais quasi nuls | Frais très faibles, risque de surtrading | B |

### 2.2 Paramètres de frais et fiscalité par époque (à utiliser dans le moteur)

Valeurs simplifiées **pour le jeu** (ordres de grandeur réalistes pour un particulier passant par sa banque, puis par un courtier en ligne). Certitude **B/C**.

| Période | Courtage (par ordre) | Taxe sur l'achat/vente | Droits de garde (/an) | Fiscalité simplifiée des gains | Fiscalité simplifiée des dividendes |
|---|---|---|---|---|---|
| 1950-1987 | 0,65 % (min. ~ équivalent 10 €) | Impôt de bourse ~0,3 % | 0,25 % | Plus-values souvent non imposées pour le petit porteur jusqu'en 1978, puis imposées au-delà d'un seuil de cessions | Barème IR, avoir fiscal 50 % à partir de 1965 |
| 1988-1998 | 0,5-0,7 % (banque) | IOB ~0,15-0,3 % | 0,2 % | ~16-18 % au-delà d'un seuil de cessions annuel | Avoir fiscal |
| 1999-2007 | Banque 0,5 % / courtier en ligne 0,15-0,5 % (min 5-15 €) | IOB 0,15-0,3 % (souvent exonéré petits ordres, simplifier à 0,15 %) | 0,1-0,2 % (banque), 0 en ligne | 26-27 % (prélèvements sociaux inclus) ; PEA exonéré après 5 ans | Avoir fiscal puis abattement 40 % (2005) |
| 2008-2017 | 0,1-0,5 % | TTF 0,2 % (≥ 08/2012), 0,3 % (2017) sur grosses valeurs FR | 0 en ligne | Barème + PS (jusqu'à ~45 %… simplifier à 30 %) | Idem |
| 2018-2025 | 0,1 % ou 1-2 € fixe | TTF 0,3 % puis 0,4 % (2025) | 0 | PFU 30 % (PEA : 17,2 % PS seulement après 5 ans) | PFU 30 % |

> Note de l'ancien agent de change : en 1960, aller-retour (achat + revente) = environ **2 % de frais** ; en 2025, c'est souvent **moins de 0,5 %** (TTF incluse). C'est un excellent ressort pédagogique : la même stratégie « active » est ruineuse en 1970 et presque indolore en 2020.

### 2.3 Unités monétaires

| Période | Unité affichée | Conversion vers l'euro |
|---|---|---|
| 1950-1959 | Ancien franc (AF) | 1 € = 655,957 AF |
| 1960-1998 | Nouveau franc (F) | 1 € = 6,55957 F |
| 1999-2001 | Euro pour la Bourse, franc dans la vie courante | — |
| 2002 → | Euro | — |

Recommandation : stocker toutes les valeurs **en euros** dans le moteur, afficher en monnaie d'époque.

---

## 3. Chronologie des grands événements de marché (1950 → 2025)

Colonnes pensées pour un **catalogue d'événements** : `choc_indice` = variation approximative de l'indice actions français pendant l'épisode (pic → creux, ou variation sur la durée indiquée). Valeurs d'indice exprimées dans l'échelle « CAC 40 rebasé » de la section 4.

| id | Date | Évènement | Description courte | Impact approx. sur l'indice FR | Durée | Leçon pédagogique | Certitude impact |
|---|---|---|---|---|---|---|---|
| E01 | 1950-06 → 1951 | Guerre de Corée | Boom des matières premières, inflation à 16 % en 1951 | +8 % (1950), +25 % (1951) en nominal… mais rendement réel faible | 18 mois | Hausse nominale ≠ enrichissement : regarder le réel | C |
| E02 | 1952-05 | Emprunt Pinay | Rente 3,5 % indexée sur l'or, exonérée de droits de succession | Indice −4 % en 1952 (plan de stabilisation) | 1 an | Une obligation peut être indexée ; la fiscalité fait le succès d'un placement | B (emprunt) / C (indice) |
| E03 | 1954 | « Meilleure année du siècle » | Malgré Diên Biên Phu, reprise forte, inflation quasi nulle | ≈ +60 % (Credit Suisse cite +66 %) | 1 an | La Bourse ne suit pas l'actualité du jour ; les meilleures années sont imprévisibles | B |
| E04 | 1956-10/11 | Crise de Suez | Choc pétrolier miniature, rationnement d'essence | ≈ −10 % temporaire, année ≈ −2 % | 2-3 mois | Les chocs géopolitiques ont souvent un effet passager | C |
| E05 | 1957-08 | « Opération 20 % » (dévaluation déguisée) | Inflation et dévaluation du franc | ≈ +30 % sur l'année en nominal | 1 an | Les actions (actifs réels) protègent mieux que le cash d'une dévaluation | C |
| E06 | 1958-05 → 1959 | Crise du 13 mai, retour de De Gaulle, plan Pinay-Rueff, dévaluation de 17,5 % (déc. 1958) | Stabilisation politique et monétaire, ouverture au Marché commun | ≈ +45 % en 1959 | 18 mois | La stabilité politique et des réformes crédibles relancent le marché | B (contexte) / C (chiffre) |
| E07 | 1960-01-01 | Nouveau franc | 100 AF = 1 NF | Neutre (affichage) | — | Illusion monétaire : seul le pouvoir d'achat compte | A |
| E08 | 1962-04 | Sommet du marché (accords d'Évian, mars 1962) | Fin d'un boom de 12 ans ; rapatriés, plan de stabilisation à venir | Sommet ≈ 400 (échelle rebasée) | — | Les sommets ne s'annoncent pas | B (date) / C (niveau) |
| E09 | 1962 → 1967 | Le long marché baissier | Plan de stabilisation Giscard (sept. 1963), encadrement du crédit, désaffection pour les actions | ≈ −45 à −50 % du pic au creux (1967) ; −10 % en 1966 | 5 ans | « Traversée du désert » : un marché peut baisser 5 ans d'affilée ; la diversification (obligations, livret) amortit | B (1966) / C (total) |
| E10 | 1968-05 | Mai 68 | Grèves générales, Bourse incendiée le 24 mai et fermée plus de deux semaines, accords de Grenelle (hausses de salaires), fuite de capitaux | Pas de krach : l'indice termine l'année en hausse (≈ +20 %) — les actions servent de refuge contre l'inflation | 2 mois | Un événement spectaculaire n'est pas forcément un krach | B (fermeture) / C (chiffre) |
| E11 | 1969-08 | Dévaluation du franc (11 %) ; départ de De Gaulle (avril) | Ajustement monétaire, croissance forte | ≈ +30 % sur l'année (C) | 1 an | Dévaluation = actions françaises en hausse nominale, mais en baisse en dollars | C |
| E12 | 1971-08-15 | Fin de la convertibilité dollar-or (Nixon) | Fin de Bretton Woods, changes flottants (1973) | 1971 : −8 % | 1 an | Le risque de change et l'or comme valeur refuge | A (indice) |
| E13 | 1973-01 | Emprunt Giscard 7 % (indexé sur l'or) | L'or flambe ensuite : remboursement en 1988 ≈ 6× le capital nominal, gouffre pour l'État | — | 15 ans | Lire les clauses d'indexation ; un « placement sûr » peut être une affaire exceptionnelle… ou l'inverse | B |
| E14 | 1973-10 → 1974-09 | 1er choc pétrolier (guerre du Kippour, pétrole ×4) | Stagflation, inflation 13,6 % en 1974, taux longs 11 % | ≈ −45 % du pic (printemps 1973) au creux (automne 1974) ; 1974 : −30,8 % | 18 mois | Inflation + récession = pire combinaison ; rendement réel très négatif | A (1974) / B (pic-creux) |
| E15 | 1975-01 → 04 | Rebond de 1975 | Détente monétaire | ≈ +35 % en 4 mois ; 1975 : +30,7 % | 4 mois | Les rebonds sont violents et rapides : rester investi | A (année) / B (4 mois) |
| E16 | 1976-1977 | Plan Barre, montée de l'Union de la gauche, municipales de mars 1977 | Incertitude politique, inflation ~9-10 % | Mai 1977 : indice des agents de change à moitié de son niveau de fin 1961 (−50 % en francs courants en 15 ans !) | 18 mois | Risque politique ; en réel, l'actionnaire de 1962 a perdu ~75 % en 15 ans | A (Larousse) |
| E17 | 1978-03 | Législatives gagnées par la majorité sortante | Fin de la menace de nationalisations | Plus de +30 % avant l'été ; 1978 : +46,5 % | 4 mois | La levée d'une incertitude politique peut déclencher un marché haussier | A |
| E18 | 1978-07-13 | Loi Monory, SICAV Monory | Réduction d'impôt pour l'achat d'actions françaises : afflux de petits épargnants | Soutient la hausse de 1978-1979 | 2 ans | La fiscalité oriente l'épargne ; attention à ne pas investir *uniquement* pour l'avantage fiscal | A (loi) / C (impact) |
| E19 | 1979 → 1980 | 2e choc pétrolier (révolution iranienne) + « choc Volcker » (taux US ~20 %) | Inflation 13,6 % en France en 1980, OAT ~14-16 % | 1979 +17 %, 1980 +7,6 % nominal mais ≈ −5 % réel (hors dividendes) | 2 ans | Taux d'intérêt élevés = concurrence forte des obligations et du livret (Livret A 8,5 % en 1981) | A |
| E20 | 1981-05-10 | Élection de François Mitterrand | Programme de nationalisations, contrôle des changes ; cotations impossibles faute d'acheteurs le lendemain | ≈ −30 % entre le 10 mai et juin 1981 ; 1981 : −16,6 % | 1-2 mois | Risque politique ; les actionnaires des sociétés nationalisées (1982) sont indemnisés en obligations | A |
| E21 | 1981-10 → 1983-03 | Trois dévaluations, « tournant de la rigueur » (mars 1983) | Désinflation engagée, création du Second Marché | 1983 : +56,7 % | 2 ans | La désinflation (baisse de l'inflation et des taux) est le meilleur carburant des marchés | A |
| E22 | 1985-1986 | Grand marché haussier, privatisations Balladur (Saint-Gobain déc. 1986, Paribas janv. 1987…) | Baisse des taux, contre-choc pétrolier 1986, modernisation de la place | 1985 : +46,5 % ; 1986 : +49,7 % | 2 ans | Euphorie : les nouveaux actionnaires pensent que « ça ne peut que monter » | A |
| E23 | 1987-10-19 | Krach d'octobre 1987 | Parti de New York (−22 % le 19), Paris −9,7 % le même jour ; Suez privatisée en pleine tempête | ≈ −36 % du pic de printemps 1987 au creux du 10 nov. ; 1987 : −28,7 % | 1 mois (vif) | Krach éclair ; contagion mondiale ; celui qui a gardé ses titres a tout regagné en ~18 mois | A (séance, année) / B (pic-creux) |
| E24 | 1987-12 | Introduction d'Eurotunnel (35 F) | Projet titanesque financé 100 % privé | Action : 128 F en mai 1989 puis ≈ 0,80 € en 2006-2007 | 20 ans | Ne pas confondre beau projet et bon placement ; risque de dilution/restructuration | A |
| E25 | 1988 | Rebond + vague d'OPA (raid sur la Société Générale, affaire Pechiney-Triangle) | Naissance du CAC 40 en temps réel | 1988 : +57,4 % | 1 an | Rebond post-krach ; délit d'initié et rôle du régulateur | A |
| E26 | 1990-08-02 | Invasion du Koweït (guerre du Golfe) | Pétrole ×2, récession | CAC 40 ≈ 2 130 (avril) → 1 472 (fin sept.) ≈ −31 % ; 1990 : −24,1 % ; rebond le jour de l'offensive (janv. 1991) | 6 mois | « Acheter au son du canon » : les marchés anticipent la fin du conflit | A (année, creux) / B (pic) |
| E27 | 1992-09 | Crise du SME, référendum de Maastricht (20 sept.), création du PEA (juil.) | Taux courts très élevés pour défendre le franc | 1992 : +5,2 % (volatil) | 6 mois | Enveloppe PEA : impact fiscal de long terme | A |
| E28 | 1993-1994 | Privatisations Balladur (BNP oct. 1993, Rhône-Poulenc, Elf févr. 1994), emprunt Balladur (110 Md F, 1,5 M de souscripteurs) | Nouvel afflux de petits porteurs | 1993 : +22,1 % | 1 an | Effet d'aubaine des privatisations, mais performance ensuite très variable | A |
| E29 | 1994-02 | Krach obligataire mondial (hausses de taux de la Fed) | OAT 10 ans de ~5,6 % à ~8 % | CAC ≈ −25 % pic → creux ; 1994 : −17,1 % ; obligations longues −10 % | 10 mois | Hausse des taux = baisse simultanée des obligations ET des actions | A (année) / B (amplitude) |
| E30 | 1997-10-20 | Introduction de France Télécom à 27,75 € (182 F) | Plus grosse privatisation, millions de particuliers ; la même semaine, crise asiatique (27 oct.) | Action → 219 € (mars 2000) → ≈ 7 € (automne 2002) | 5 ans | Une valeur « populaire » peut faire ×8 puis ÷30 | A (IPO, pic) / B (creux) |
| E31 | 1998-07 → 10 | Crise russe, faillite du fonds LTCM | Défaut de la Russie (17 août), panique de liquidité ; profit warning Alcatel (−38 % en une séance, sept.) | CAC ≈ 4 400 → ≈ 2 850 (−35 %) ; année 1998 : +31,5 % ! | 3 mois | Une année peut contenir un krach et finir en forte hausse | A (année) / B (amplitude) |
| E32 | 1999 → 2000-09-04 | Bulle Internet / TMT, passage à l'euro | Nouveau Marché, introductions à PER infini, Vivendi Universal, France Télécom, Alcatel au zénith | 1999 : +51,1 % ; pic historique du CAC 40 : 6 922 le 4 sept. 2000 | 2 ans | Bulle : « cette fois, c'est différent » ; PER extrêmes | A |
| E33 | 2001-09-11 | Attentats du 11 septembre | Wall Street fermée 4 jours | −7,4 % le 11 sept. ; CAC ≈ 3 650 le 21 sept. (≈ −47 % depuis le pic de 2000) ; rebond de +20 % en 2 mois | 2 mois | Choc exogène ; panique puis rebond | A (séance) / B (niveaux) |
| E34 | 2002 | Scandales Enron/WorldCom ; chute de Vivendi Universal (départ de J.-M. Messier, juil.) et de France Télécom (dette ~70 Md€) | Crise de confiance dans les comptes | 2002 : −33,8 % | 1 an | Risque spécifique : une « valeur de fond de portefeuille » peut perdre 90 % | A |
| E35 | 2003-03-12 | Creux du marché (veille de la guerre d'Irak) | Fin du marché baissier 2000-2003 | CAC 2 403 = −65 % depuis le pic de 2000 ; puis +48 % en 1 an | — | Le meilleur moment pour acheter est quand tout le monde est terrifié ; le DCA en profite automatiquement | A |
| E36 | 2007-06-01 → 2007-08-09 | Sommet puis début de la crise des subprimes (BNP Paribas gèle 3 fonds le 9 août) | Crédit hypothécaire américain toxique | Pic CAC 6 168 (1er juin 2007) | — | Les crises commencent souvent par un « petit » signal technique | A |
| E37 | 2008-01-21 | Affaire Kerviel (Société Générale, perte 4,9 Md€) + panique mondiale | Débouclage forcé de positions géantes | CAC −6,8 % le 21 janv. | 1 semaine | Risque opérationnel ; danger du levier | A |
| E38 | 2008-09-15 → 2009-03-09 | Faillite de Lehman Brothers, crise financière mondiale | Sauvetages bancaires, récession mondiale | −9,04 % le 6 oct. 2008, +11,18 % le 13 oct. ; 2008 : −42,7 % ; creux 2 519 le 9 mars 2009 (−59 % depuis 2007) ; 2009 : +22,3 % | 18 mois | Les pires et meilleures séances sont collées ; vendre en panique fait rater le rebond | A |
| E39 | 2010-05 | Crise grecque, « flash crash » (6 mai), plan européen de 750 Md€ | Début de la crise de la zone euro | CAC +9,7 % le 10 mai 2010 | 1 mois | Interventions publiques massives = rebonds violents | A/B |
| E40 | 2011-07 → 09 | Crise des dettes souveraines, dégradation de la note américaine (5 août) | Banques françaises −50 % à −60 % ; interdiction temporaire de la vente à découvert sur les financières (août) | CAC ≈ 4 160 (févr.) → ≈ 2 780 (sept.) ≈ −33 % ; 2011 : −17 % | 3 mois | Risque souverain ; les obligations d'État ne sont pas toutes « sans risque » | A (année) / B (niveaux) |
| E41 | 2012-07-26 | « Whatever it takes » (Draghi) | La BCE promet de sauver l'euro | 2012 : +15,2 % ; 2013 : +18 % | 18 mois | Les banques centrales comme acteur majeur du marché | A |
| E42 | 2015-01 → 2016-02 | QE de la BCE, krach chinois (24 août 2015, −5,3 %), taux négatifs | OAT 10 ans < 1 %, puis négative (2019-2021) | CAC 5 269 (avril 2015) → ≈ 3 900 (févr. 2016) ≈ −25 % | 10 mois | Taux zéro : épargne « sans risque » ne rapporte plus rien en réel | A (taux) / B (indice) |
| E43 | 2016-06-24 | Référendum du Brexit | Surprise du « Leave » | −8,04 % en une séance ; tout effacé en ~3 semaines | 3 semaines | Les surprises politiques ont des effets souvent brefs | A |
| E44 | 2018-10 → 12 | Correction de fin 2018 (guerre commerciale, hausse des taux US) | Flat tax 30 % en vigueur depuis janvier | ≈ −15 % au T4 ; 2018 : −11 % ; 2019 : +26,4 % | 3 mois | Volatilité « ordinaire » ; ne pas confondre correction et krach | A (années) |
| E45 | 2020-02-19 → 03-18 | Krach du Covid-19 | Confinement mondial, guerre des prix du pétrole | 6 111 → 3 755 = −38,6 % en 1 mois ; −12,28 % le 12 mars 2020 (record) ; 2020 : −7,1 % ; 2021 : +28,9 % | 1 mois (baisse) / 12 mois (rebond) | Krach le plus rapide de l'histoire, rebond très rapide (annonce du vaccin, 9 nov. 2020 : ≈ +7,6 %) | A |
| E46 | 2022-02-24 → 09 | Invasion de l'Ukraine, retour de l'inflation, hausse des taux BCE (juil. 2022) | Inflation 5,2 %, OAT 10 ans de 0 % à ~3 % | CAC 7 376 (5 janv.) → 5 677 (29 sept.) ≈ −23 % ; 2022 : −9,5 % ; obligations longues ≈ −15 à −20 % | 9 mois | Krach obligataire : actions et obligations peuvent baisser ensemble ; rendement réel du livret négatif | A (année, taux) / B (amplitude) |
| E47 | 2023-03 | Faillites de SVB et de Credit Suisse (rachat par UBS) | Mini-crise bancaire | ≈ −5 à −7 % en 2 semaines, puis nouveaux records | 1 mois | Contagion limitée ; les records reviennent vite | B |
| E48 | 2024-06-09 | Dissolution de l'Assemblée nationale | Risque politique français, écart de taux OAT/Bund qui s'élargit | ≈ −6 % la semaine suivante ; banques −10 à −15 % ; 2024 : −2,2 % | 1-3 mois | Risque politique domestique ; sous-performance vs S&P 500 (+23 %) | A (année) / B (semaine) |
| E49 | 2025-04-02 → 09 | « Liberation Day » : droits de douane américains | Panique mondiale puis pause de 90 jours (9 avril) | ≈ −16 % depuis le record de mars (≈ 8 200 → ≈ 6 900) en quelques séances, puis rebond | 1 mois | Panique « tarifaire » ; rebond rapide sur une annonce politique | B |
| E50 | 2025 (année) | Records et instabilité politique française | Record de clôture 8 258,96 (21 oct. 2025), plus haut en séance 8 314,23 (13 nov.) ; or > 4 000 $ | 2025 : +10,4 % (CAC 40 GR dividendes réinvestis : +14,3 %) | 1 an | Différence indice de prix / indice dividendes réinvestis | A |
### 3.1 Records de séances du CAC 40 (pour les « jours historiques »)

| Date | Variation | Contexte | Certitude |
|---|---|---|---|
| 2020-03-12 | **−12,28 %** | Covid, guerre des prix pétroliers | A |
| 2008-10-06 | −9,04 % | Lehman, contagion bancaire | A |
| 2020-03-09 | −8,39 % | « Lundi noir » Covid | A |
| 2016-06-24 | −8,04 % | Brexit | A |
| 2001-09-11 | −7,39 % | Attentats | B |
| 2008-01-21 | −6,83 % | Kerviel / panique | B |
| 1987-10-19 | ≈ −9,7 % (CAC Général) | Krach | A |
| 2008-10-13 | **+11,18 %** | Plans de sauvetage bancaires | A/B |
| 2010-05-10 | ≈ +9,7 % | Plan européen 750 Md€ | B |
| 2020-03-24 | ≈ +8,4 % | Plans de relance | B |
| 2020-11-09 | ≈ +7,6 % | Annonce du vaccin Pfizer | B |

---

## 4. Séries de données historiques

### 4.1 Méthode de construction de l'indice « CAC 40 rebasé »

- **1988-2025** : clôtures officielles du **CAC 40** au 31/12 (certitude **A**). Correction : la clôture 1999 est **5 958,32** (+51,12 %) — certaines tables en ligne affichent par erreur 5 858,32.
- **1969-1987** : série rétropolée publiée avec le CAC 40 (Wikipédia, chaînage de l'indice **CAC Général** base 100 fin 1981). Vérification de cohérence effectuée : 1000 / 3,52 = 284 = niveau du CAC Général fin 1987 ; et 352,11 (fin 1981) / 3,52 ≈ 100 = base du CAC Général. Les niveaux de séance d'octobre 1987 publiés par Larousse (352,4 le 16/10, 293,6 le 29/10, 273,6 le 10/11) se convertissent donc par **× 3,52**. Certitude **A/B**.
- **1950-1968** : **reconstitution** (certitude **C**) chaînée vers l'arrière depuis 1969, calée sur les points d'ancrage suivants :
  - indice des agents de change base 100 fin 1961 ≈ 59 fin 1974 et 79,6 en mai 1975 (Larousse) → fin 1961 ≈ **380** en échelle rebasée ;
  - « quintuplement » de l'indice INSEE dans les années 1950 ; 1954 meilleure année (≈ +60/66 %) ;
  - pic d'avril 1962, puis baisse jusqu'en 1967 (−10 % en 1966, ≈ −19 % en rythme annuel au 1er semestre 1967) ;
  - retour au-dessus du niveau de fin 1961 au printemps 1973.
- Pour le moteur : utiliser la colonne `indice_fin_annee` comme **points d'ancrage** et générer l'intra-annuel (section 6).

### 4.2 Série annuelle principale (1950-2025)

Colonnes :
- `indice` = clôture au 31/12 en échelle CAC 40 (base 1000 au 31/12/1987), indice de **prix** (hors dividendes) ;
- `var_%` = variation annuelle de l'indice ;
- `rdt_div_%` = rendement du dividende moyen estimé du marché français (certitude **C** avant 1990, **B** ensuite) ;
- `inflation_%` = inflation annuelle moyenne (INSEE / Banque mondiale ; **A** à partir de 1960, **B/C** avant) ;
- `taux_long_%` = taux des emprunts d'État à 10 ans (OAT après 1985), moyenne annuelle (OCDE via FRED ; **A** à partir de 1960, **C** avant) ;
- `cert_indice` = certitude sur l'indice.

| annee | indice | var_% | cert_indice | rdt_div_% | inflation_% | taux_long_% |
|---|---|---|---|---|---|---|
| 1949 | 65,5 | — | C | 6,0 | 13,0 | 6,5 |
| 1950 | 70,8 | +8,0 | C | 5,5 | 10,0 | 6,5 |
| 1951 | 88,5 | +25,0 | C | 5,5 | 16,2 | 7,0 |
| 1952 | 84,9 | −4,0 | C | 5,8 | 12,0 | 7,0 |
| 1953 | 89,2 | +5,0 | C | 5,5 | −1,7 | 6,8 |
| 1954 | 142,7 | +60,0 | C (B pour le signe/ampleur) | 4,5 | 0,4 | 6,0 |
| 1955 | 151,3 | +6,0 | C | 4,2 | 1,2 | 5,6 |
| 1956 | 148,2 | −2,0 | C | 4,3 | 2,0 | 5,7 |
| 1957 | 195,7 | +32,0 | C | 3,6 | 3,5 | 6,5 |
| 1958 | 205,5 | +5,0 | C | 3,8 | 15,1 | 6,8 |
| 1959 | 300,0 | +46,0 | C | 2,8 | 6,1 | 6,0 |
| 1960 | 312,0 | +4,0 | C | 2,7 | 4,1 | 5,7 |
| 1961 | 380,6 | +22,0 | C | 2,5 | 2,4 | 5,5 |
| 1962 | 342,6 | −10,0 | C | 2,8 | 5,3 | 5,4 |
| 1963 | 294,6 | −14,0 | C | 3,2 | 5,0 | 5,3 |
| 1964 | 262,2 | −11,0 | C | 3,5 | 3,2 | 5,4 |
| 1965 | 243,8 | −7,0 | C | 3,7 | 2,7 | 6,2 |
| 1966 | 219,5 | −10,0 | C (B pour −10 %) | 4,0 | 2,6 | 6,6 |
| 1967 | 210,7 | −4,0 | C | 4,2 | 2,8 | 6,7 |
| 1968 | 257,0 | +22,0 | C | 3,7 | 4,5 | 7,0 |
| 1969 | 334,1 | +30,0 | B (niveau) / C (variation) | 3,2 | 6,0 | 8,2 |
| 1970 | 310,5 | −7,1 | B | 3,6 | 5,3 | 8,6 |
| 1971 | 286,1 | −7,8 | B | 4,0 | 5,4 | 8,4 |
| 1972 | 335,2 | +17,1 | B | 3,6 | 6,1 | 8,0 |
| 1973 | 325,7 | −2,8 | B | 3,9 | 7,4 | 9,0 |
| 1974 | 225,5 | −30,8 | B | 6,0 | 13,6 | 11,0 |
| 1975 | 294,6 | +30,7 | B | 4,8 | 11,7 | 10,3 |
| 1976 | 244,5 | −17,0 | B | 5,8 | 9,6 | 10,5 |
| 1977 | 229,0 | −6,4 | B | 6,5 | 9,5 | 11,0 |
| 1978 | 335,5 | +46,5 | B | 5,0 | 9,3 | 10,6 |
| 1979 | 392,7 | +17,0 | B | 4,8 | 10,6 | 10,8 |
| 1980 | 422,4 | +7,6 | B | 5,0 | 13,6 | 13,8 |
| 1981 | 352,1 | −16,6 | A/B | 6,5 | 13,4 | 16,3 |
| 1982 | 352,8 | +0,2 | A/B | 6,8 | 11,8 | 16,0 |
| 1983 | 552,9 | +56,7 | A/B | 4,8 | 9,6 | 14,4 |
| 1984 | 640,0 | +15,8 | A/B | 4,4 | 7,4 | 13,4 |
| 1985 | 937,8 | +46,5 | A/B | 3,4 | 5,8 | 11,9 |
| 1986 | 1 403,5 | +49,7 | A/B | 2,6 | 2,6 | 9,1 |
| 1987 | 1 000,0 | −28,7 | A | 3,6 | 3,1 | 9,5 |
| 1988 | 1 573,9 | +57,4 | A | 3,0 | 2,7 | 9,1 |
| 1989 | 2 001,1 | +27,1 | A | 2,7 | 3,6 | 8,8 |
| 1990 | 1 517,9 | −24,1 | A | 3,7 | 3,4 | 9,9 |
| 1991 | 1 765,7 | +16,3 | A | 3,4 | 3,2 | 9,0 |
| 1992 | 1 857,8 | +5,2 | A | 3,4 | 2,4 | 8,6 |
| 1993 | 2 268,2 | +22,1 | A | 2,9 | 2,1 | 6,8 |
| 1994 | 1 881,2 | −17,1 | A | 3,4 | 1,6 | 7,2 |
| 1995 | 1 872,0 | −0,5 | A | 3,5 | 1,8 | 7,5 |
| 1996 | 2 315,7 | +23,7 | A | 3,0 | 2,0 | 6,3 |
| 1997 | 2 998,9 | +29,5 | A | 2,4 | 1,2 | 5,6 |
| 1998 | 3 942,7 | +31,5 | A | 2,0 | 0,7 | 4,6 |
| 1999 | 5 958,3 | +51,1 | A | 1,6 | 0,5 | 4,6 |
| 2000 | 5 926,4 | −0,5 | A | 1,8 | 1,7 | 5,4 |
| 2001 | 4 624,6 | −22,0 | A | 2,4 | 1,6 | 5,0 |
| 2002 | 3 063,9 | −33,7 | A | 3,6 | 1,9 | 4,9 |
| 2003 | 3 557,9 | +16,1 | A | 3,2 | 2,1 | 4,1 |
| 2004 | 3 821,2 | +7,4 | A | 3,1 | 2,1 | 4,1 |
| 2005 | 4 715,2 | +23,4 | A | 2,9 | 1,7 | 3,4 |
| 2006 | 5 541,8 | +17,5 | A | 3,0 | 1,7 | 3,8 |
| 2007 | 5 614,1 | +1,3 | A | 3,3 | 1,5 | 4,3 |
| 2008 | 3 218,0 | −42,7 | A | 5,6 | 2,8 | 4,2 |
| 2009 | 3 936,3 | +22,3 | A | 4,0 | 0,1 | 3,6 |
| 2010 | 3 804,8 | −3,3 | A | 4,0 | 1,5 | 3,1 |
| 2011 | 3 159,8 | −17,0 | A | 5,0 | 2,1 | 3,3 |
| 2012 | 3 641,1 | +15,2 | A | 4,0 | 2,0 | 2,5 |
| 2013 | 4 296,0 | +18,0 | A | 3,3 | 0,9 | 2,2 |
| 2014 | 4 272,8 | −0,5 | A | 3,4 | 0,5 | 1,7 |
| 2015 | 4 637,1 | +8,5 | A | 3,3 | 0,0 | 0,8 |
| 2016 | 4 862,3 | +4,9 | A | 3,4 | 0,2 | 0,5 |
| 2017 | 5 312,6 | +9,3 | A | 3,1 | 1,0 | 0,8 |
| 2018 | 4 730,7 | −11,0 | A | 3,6 | 1,8 | 0,8 |
| 2019 | 5 978,1 | +26,4 | A | 3,0 | 1,1 | 0,1 |
| 2020 | 5 551,4 | −7,1 | A | 2,0 | 0,5 | −0,1 |
| 2021 | 7 153,0 | +28,9 | A | 2,4 | 1,6 | 0,0 |
| 2022 | 6 473,8 | −9,5 | A | 3,2 | 5,2 | 1,7 |
| 2023 | 7 543,2 | +16,5 | A | 3,0 | 4,9 | 3,0 |
| 2024 | 7 380,7 | −2,2 | A | 3,4 | 2,0 | 3,0 |
| 2025 | 8 149,5 | +10,4 | A | 3,2 | 0,9 | 3,4 |

Remarques importantes pour le développeur :
1. **Rendement total ≈ var_% + rdt_div_%** (approximation annuelle suffisante pour le jeu). Contrôle 2025 : 10,4 + ~3,5 ≈ 14,3 % = CAC 40 GR officiel.
2. 2020 : la variation officielle est −7,14 % (5 978,06 → 5 551,41). La table Wikipédia indique −7,68 % ; j'ai retenu le calcul exact.
3. Inflation 1950-1959 (certitude B/C) : séries INSEE de mémoire ; 1958 (+15 %) correspond à la poussée liée aux dévaluations de 1957-1958.
4. Taux longs 1950-1959 (certitude C) : rendement de la rente et des emprunts d'État, fourchette 5,5-7 %.

Ordres de grandeur de contrôle (calculés à partir de la table) :
- 1987 → 2025 : CAC ×8,15 en 38 ans = **+5,7 %/an hors dividendes**, ≈ +9 %/an dividendes inclus, ≈ +7 %/an en réel.
- 1950 → 2025 : indice de prix ×115 en 75 ans ≈ +6,5 %/an nominal hors dividendes (certitude C sur le point de départ).
- Le Credit Suisse Yearbook donne pour la France depuis 1900 un rendement réel moyen d'environ 3,4 %/an (pénalisé par les deux guerres) ; depuis 1950, la France est « dans la moyenne » des pays développés.

### 4.3 Livret A (taux en vigueur, pour le comparateur « sans risque »)

| Période | Taux | Certitude |
|---|---|---|
| 1950-1952 | 1,5-2 % | B |
| 1953-1965 | 2,75-3,25 % (3,25 % en 1960) | B |
| 1966-1973 | 3-4,25 % | B |
| 1974-1980 | 6-7,5 % | B |
| 1981 (oct.) - 1983 | 8,5 % (record) | A |
| 1984-1985 | 7,5 % puis 6 % | B |
| 1986 (mai) - 1996 | 4,5 % | B |
| 1996 - 1998 | 3,5 % puis 3 % | B |
| 1999 - 2004 | 2,25-3 % | B |
| 2005 - 2007 | 2-3 % | B |
| 2008 | 3,5 % puis 4 % (août) | A |
| 2009 - 2012 | 1,25-2,25 % | A |
| 2013 - 2019 | 1,75 % → 0,75 % | A |
| 2020 - 2021 | 0,5 % | A |
| 2022 | 1 % (févr.) puis 2 % (août) | A |
| 2023 - 2024 | 3 % | A |
| 2025 | 2,4 % (févr.) puis 1,7 % (août) | A |

### 4.4 Données mensuelles des grandes périodes de crise (fin de mois, échelle CAC 40)

Certitude : **B** pour 1988-2025 (fins de mois approximatives à ±3 %), **C** pour 1973-1987 sauf points cités. Les lignes marquées ★ sont des points de séance documentés (A).

**Krach 1973-1975 (1er choc pétrolier)**

| date | indice | note |
|---|---|---|
| 1972-12 | 335 | |
| 1973-03 | 370 | |
| 1973-05 | 385 | sommet (retour au-dessus du niveau de 1961) |
| 1973-09 | 350 | |
| 1973-12 | 326 | guerre du Kippour, embargo |
| 1974-03 | 300 | |
| 1974-06 | 265 | |
| 1974-09 | 215 | creux approx. |
| 1974-12 | 225 | |
| 1975-04 | 302 | ★ +35 % en 4 mois (Larousse) |
| 1975-06 | 266 | |
| 1975-12 | 295 | |

**Élection de 1981**

| date | indice | note |
|---|---|---|
| 1980-12 | 422 | |
| 1981-04 | 410 | |
| 1981-05 (8 mai) | 400 | veille du 2nd tour |
| 1981-06 | 285 | ★ −30 % depuis le 10 mai |
| 1981-09 | 320 | |
| 1981-12 | 352 | |
| 1982-06 | 345 | |
| 1982-12 | 353 | |

**Krach d'octobre 1987**

| date | indice | note |
|---|---|---|
| 1986-12 | 1 404 | |
| 1987-01 | 1 450 | |
| 1987-03 | 1 500 | sommet approx. (printemps) |
| 1987-06 | 1 400 | |
| 1987-09 | 1 310 | |
| 1987-10-16 | 1 240 | ★ (352,4 CAC Général × 3,52) |
| 1987-10-19 | ≈ 1 120 | ★ −9,7 % dans la séance |
| 1987-10-29 | 1 033 | ★ |
| 1987-11-10 | 963 | ★ creux de l'année |
| 1987-12 | 1 000 | base CAC 40 |
| 1988-06 | 1 300 | |
| 1988-12 | 1 574 | |

**Guerre du Golfe 1990**

| date | indice | note |
|---|---|---|
| 1989-12 | 2 001 | |
| 1990-04 | 2 130 | sommet approx. |
| 1990-07 | 1 950 | |
| 1990-08 | 1 640 | invasion du Koweït le 2 |
| 1990-09 | 1 472 | ★ creux (fin sept.) |
| 1990-12 | 1 518 | |
| 1991-01 | 1 600 | offensive alliée : rebond |
| 1991-03 | 1 800 | |

**Bulle et krach 2000-2003**

| date | indice | date | indice | date | indice |
|---|---|---|---|---|---|
| 1999-12 | 5 958 | 2001-01 | 5 998 | 2002-01 | 4 442 |
| 2000-01 | 5 659 | 2001-02 | 5 420 | 2002-03 | 4 688 |
| 2000-02 | 6 388 | 2001-03 | 5 180 | 2002-05 | 4 219 |
| 2000-03 | 6 420 | 2001-04 | 5 568 | 2002-06 | 3 898 |
| 2000-06 | 6 446 | 2001-06 | 5 225 | 2002-07 | 3 501 |
| 2000-08 | 6 738 | 2001-08 | 4 719 | 2002-09 | 2 777 |
| 2000-09-04 ★ | 6 922 | 2001-09 | 4 012 | 2002-10 | 3 152 |
| 2000-09 | 6 267 | 2001-10 | 4 313 | 2002-12 | 3 064 |
| 2000-10 | 6 399 | 2001-11 | 4 589 | 2003-02 | 2 875 |
| 2000-11 | 5 928 | 2001-12 | 4 625 | 2003-03-12 ★ | 2 403 |
| 2000-12 | 5 926 | | | 2003-06 | 3 084 |
| | | | | 2003-12 | 3 558 |

**Subprimes / Lehman 2007-2009**

| date | indice | date | indice | date | indice |
|---|---|---|---|---|---|
| 2007-06-01 ★ | 6 168 | 2008-04 | 4 997 | 2009-01 | 2 962 |
| 2007-06 | 6 054 | 2008-05 | 5 014 | 2009-02 | 2 807 |
| 2007-08 | 5 662 | 2008-06 | 4 434 | 2009-03-09 ★ | 2 519 |
| 2007-10 | 5 848 | 2008-07 | 4 392 | 2009-03 | 2 804 |
| 2007-12 | 5 614 | 2008-08 | 4 483 | 2009-04 | 3 159 |
| 2008-01 | 4 870 | 2008-09 | 4 032 | 2009-06 | 3 140 |
| 2008-02 | 4 790 | 2008-10 | 3 488 | 2009-09 | 3 795 |
| 2008-03 | 4 707 | 2008-11 | 3 263 | 2009-12 | 3 936 |
| | | 2008-12 | 3 218 | | |

**Crise des dettes souveraines 2011**

| date | indice | date | indice |
|---|---|---|---|
| 2010-12 | 3 805 | 2011-07 | 3 672 |
| 2011-02 | 4 110 | 2011-08 | 3 256 |
| 2011-04 | 4 107 | 2011-09 | 2 982 (creux ≈ 2 780 en séance) |
| 2011-06 | 3 982 | 2011-12 | 3 160 |

**Covid 2020**

| date | indice | date | indice |
|---|---|---|---|
| 2019-12 | 5 978 | 2020-05 | 4 695 |
| 2020-01 | 5 806 | 2020-06 | 4 936 |
| 2020-02-19 ★ | 6 111 | 2020-09 | 4 803 |
| 2020-02 | 5 309 | 2020-10 | 4 594 |
| 2020-03-18 ★ | 3 755 | 2020-11 | 5 518 (vaccin) |
| 2020-03 | 4 396 | 2020-12 | 5 551 |
| 2020-04 | 4 572 | 2021-12 | 7 153 |

**Inflation et hausse des taux 2022**

| date | indice | date | indice |
|---|---|---|---|
| 2021-12 | 7 153 | 2022-06 | 5 923 |
| 2022-01-05 ★ | 7 376 | 2022-08 | 6 125 |
| 2022-02 | 6 659 | 2022-09-29 ★ | 5 677 |
| 2022-03 | 6 660 | 2022-10 | 6 273 |
| 2022-05 | 6 469 | 2022-12 | 6 474 |

### 4.5 Actions emblématiques françaises

Prix **approximatifs ajustés des divisions** (en euros), à utiliser comme **points d'ancrage** pour une trajectoire simulée autour de l'indice (section 6). Certitude globale **B/C** : l'ordre de grandeur et le profil sont fiables, pas le prix au centime. `beta` = sensibilité suggérée au marché ; `vol_spe` = volatilité spécifique annuelle suggérée.

| Action | Cotée (période) | Secteur | beta | vol_spe | Trajectoire / points d'ancrage approximatifs | Leçon portée | Cert. |
|---|---|---|---|---|---|---|---|
| **L'Oréal** | 1963 → | Cosmétiques | 0,8 | 18 % | Croissance régulière exceptionnelle ; ≈ 90 € début 2000, ≈ 55 € en 2003, ≈ 98 € en 2007, ≈ 50 € en mars 2009, ≈ 165 € en 2015, ≈ 260 € en 2019, ≈ 420 € fin 2021, ≈ 450 € en 2023-24, ≈ 360-380 € en 2025 | Valeur de croissance « défensive », intérêts composés | B |
| **Air Liquide** | 1913 → | Gaz industriels | 0,7 | 15 % | Progression lente mais très régulière, actions gratuites fréquentes (+10 % de titres environ tous les 2 ans) ; ≈ ×30 à ×50 dividendes réinvestis depuis 1980 | Patience, actions gratuites, petits porteurs fidèles | B/C |
| **TotalEnergies** (CFP, puis Total 1991, TotalFina 1999, TotalFinaElf 2000) | avant 1950 → | Pétrole | 0,8 | 22 % | Suit le pétrole ; ≈ 40 € en 2000, ≈ 60 € mi-2008, ≈ 36 € en 2009, creux ≈ 22-25 € en 2020, ≈ 55-60 € en 2023-25 ; dividende élevé (5-6 %) | Valeurs cycliques, rendement du dividende | B |
| **Elf Aquitaine** | années 1970 → 2000 (absorbée par TotalFina) | Pétrole | 0,8 | 22 % | Privatisée en 1994, OPE hostile de TotalFina en 1999 avec prime ≈ 20-30 % | OPA/OPE : prime pour l'actionnaire | B |
| **Saint-Gobain** | XIXᵉ siècle → (nationalisée 1982-1986) | Matériaux | 1,2 | 22 % | Première privatisation (déc. 1986, 310 F) ; ≈ 80 € en 2007, ≈ 20 € en 2009 et en mars 2020, ≈ 85-95 € en 2024-25 | Nationalisation/privatisation, cyclicité | B |
| **Michelin** | avant 1950 → | Pneumatiques | 1,0 | 25 % | Pertes lourdes 1980-1984 et 1990-1991 (cours très bas), puis redressement ; division par 4 en 2023 ; ≈ 30 € (post-division) en 2024-25 | Un leader mondial peut traverser des années noires | B/C |
| **Peugeot / PSA → Stellantis** | années 1960 → 2021 (Stellantis ensuite) | Automobile | 1,3 | 30 % | Rachat de Citroën (1974-76) et de Chrysler Europe (1978), pertes 1980-1984 ; crise 2012 (≈ 5 €) et recapitalisation 2014 ; fusion Stellantis janv. 2021 ; Stellantis ≈ 27 € (mars 2024) → ≈ 9 € (2025) | Cyclicité extrême de l'automobile | B |
| **Renault** | 1994 (privatisation partielle) → | Automobile | 1,4 | 30 % | ≈ 120 € (2007), ≈ 13 € (2009), arrestation de C. Ghosn (nov. 2018), ≈ 15 € (2020), ≈ 35-45 € (2024-25) | Gouvernance, cyclicité | B |
| **Alcatel** (CGE → Alcatel Alsthom → Alcatel-Lucent) | longtemps cotée ; nationalisée 1982, privatisée 1987 ; absorbée par Nokia 2016 | Télécom / technologie | 1,6 | 40 % | −38 % en une séance (sept. 1998, avertissement sur résultats) ; ≈ 100 € à l'automne 2000 ; ≈ 3 € fin 2002 ; ≈ 1-4 € jusqu'en 2016 | Bulle technologique, profit warning | B |
| **Vivendi** (Compagnie Générale des Eaux → Vivendi 1998 → Vivendi Universal 2000) | XIXᵉ siècle → | Eau puis médias | 1,3 | 35 % | ≈ 150 € (mars 2000) → ≈ 9-10 € (été 2002, départ de J.-M. Messier) ; scissions UMG (2021), Canal+/Havas/Louis Hachette (déc. 2024) | Conglomérat, dette, gouvernance | B |
| **LVMH** | 1987 (fusion Moët-Hennessy / Louis Vuitton) → | Luxe | 1,1 | 22 % | Contrôle de B. Arnault (1989) ; ≈ 35 € (2003), ≈ 40 € (2008-09), ≈ 150 € (2015), ≈ 700 € (2021), record ≈ 900 € (avril 2023), ≈ 550-650 € (2024-25) | Croissance mondiale, valorisation élevée, retour à la moyenne | B |
| **France Télécom → Orange** | oct. 1997 → | Télécoms | 1,0 (1,8 en 1999-2002) | 25 % (45 % en bulle) | IPO 27,75 € (182 F, 20/10/1997) → 219 € (2 mars 2000) → ≈ 7 € (sept.-oct. 2002) → ≈ 10-15 € de 2010 à 2025 | Privatisation populaire, bulle, dette | A (IPO, pic) / B |
| **Eurotunnel → Getlink** | déc. 1987 → | Infrastructure | 0,7 | 40 % | IPO 35 F (5,34 €) → 128 F (19,5 €) mai 1989 → ≈ 0,80 € (2006-07) ; procédure de sauvegarde (2006), restructuration 2007 avec quasi-éviction des anciens actionnaires ; Getlink ≈ 15-17 € en 2024-25 | Risque projet, dette, dilution | A/B |
| **BNP → BNP Paribas** | privatisée oct. 1993 (240 F) ; fusion avec Paribas en 1999-2000 | Banque | 1,4 | 25 % | ≈ 90 € (2007), ≈ 20 € (mars 2009), ≈ 22 € (sept. 2011), ≈ 25 € (mars 2020), ≈ 75-80 € (2025) | Banques = levier de l'économie, très sensibles aux crises | B |
| **Société Générale** | privatisée juin 1987 (407 F) → | Banque | 1,5 | 30 % | ≈ 160 € (mai 2007), affaire Kerviel (janv. 2008), ≈ 20 € (2009), ≈ 15 € (2011), ≈ 10 € (2020), forte hausse en 2025 (≈ 55-65 €) | Risque opérationnel, volatilité bancaire | B/C |
| **Natixis** | nov. 2006 (19,55 €) → retrait de la cote en 2021 | Banque d'investissement | 1,8 | 40 % | 19,55 € à l'introduction → ≈ 1 € (mars 2009) ; retirée de la cote par BPCE à 4 € (2021) | Introduction « grand public » au mauvais moment | A/B |

### 4.6 Points de comparaison : S&P 500 et or

| annee | S&P 500 (clôture 31/12, points) | Or (USD/once, fin d'année) | Note |
|---|---|---|---|
| 1950 | 20,4 | 35 | Or à prix fixe (Bretton Woods) |
| 1955 | 45,5 | 35 | |
| 1960 | 58,1 | 35 | Pic spéculatif à ~40 $ en oct. 1960 |
| 1965 | 92,4 | 35 | |
| 1970 | 92,2 | 37 | |
| 1973 | 97,6 | 112 | Changes flottants |
| 1974 | 68,6 | 187 | |
| 1975 | 90,2 | 140 | |
| 1980 | 135,8 | 590 | Or : record 850 $ le 21 janv. 1980 |
| 1985 | 211,3 | 327 | |
| 1987 | 247,1 | 484 | |
| 1990 | 330,2 | 386 | |
| 1995 | 615,9 | 387 | |
| 1999 | 1 469,3 | 288 | |
| 2000 | 1 320,3 | 273 | Or : creux ≈ 252 $ en 1999 |
| 2002 | 879,8 | 343 | |
| 2005 | 1 248,3 | 513 | |
| 2007 | 1 468,4 | 834 | |
| 2008 | 903,3 | 870 | |
| 2010 | 1 257,6 | 1 410 | |
| 2011 | 1 257,6 | 1 531 | Or : pic ≈ 1 900 $ en sept. 2011 |
| 2015 | 2 043,9 | 1 060 | |
| 2019 | 3 230,8 | 1 517 | |
| 2020 | 3 756,1 | 1 888 | |
| 2021 | 4 766,2 | 1 806 | |
| 2022 | 3 839,5 | 1 812 | |
| 2023 | 4 769,8 | 2 063 | |
| 2024 | 5 881,6 | 2 625 | |
| 2025 | ≈ 6 845 | ≈ 4 320 | S&P ≈ +16-17 % ; or : record ≈ 4 550 $ en 2025 |

Certitude : S&P 500 **A** (2025 : **B**, clôture exacte à vérifier) ; or **B** (fin d'année ±3 %). Pour un Français, l'or se détenait souvent en **napoléons** (pièce de 20 F) dont la prime fluctuait ; on peut simplifier en convertissant le cours en dollars par le taux de change de l'époque (1 $ ≈ 3,5 AF puis 4,9 F dans les années 1960, 4,2-4,5 F fin années 1970, 10 F en 1985, 5-6 F dans les années 1990).

Leçon de comparaison : sur 1987-2025, le S&P 500 a été multiplié par ≈ 28 contre ≈ 8 pour le CAC 40 (hors dividendes, le CAC versant davantage de dividendes) : **la diversification géographique** est un vrai sujet pour l'épargnant français.

---

## 5. Trois périodes « majeures » proposées

> **Mise à jour** : cette section est ma première proposition. La **recommandation finale**, arbitrée avec la vision du client (parties de 15 ans), est en section 7, Q1.

Critères : 12 à 15 ans chacune, au moins un krach et un marché haussier, des contextes macro différents (inflation forte / bulle / taux zéro), et des mécanismes de marché différents (criée / électronique / en ligne).

### Période 1 — « De la criée au krach » : 1977 → 1990 (13 ans)

- **Pitch** : vous débutez au palais Brongniart, l'inflation est à 10 %, le Livret A rapporte 6,5 % et la Bourse est au plus bas depuis 15 ans. Élections, nationalisations, dévaluations, puis le grand marché haussier des privatisations… et le krach de 1987.
- **Pourquoi c'est pédagogique** : contraste maximal entre rendement nominal et réel ; démonstration qu'acheter quand tout le monde a peur (1977, 1981-82) est payant ; la fin de la criée et l'arrivée de la cotation électronique ; le premier krach mondial « moderne » suivi d'un rebond complet en 18 mois.
- **Événements clés** : E16, E17, E18, E19, E20, E21, E22, E23, E24, E25, E26.
- **Notions couvertes** : action, obligation (taux à 16 % !), dividende, indice, ordre au marché / limité (marché peu liquide, criée), frais élevés (courtage + impôt de bourse), inflation et rendement réel, intérêts composés, risque politique, nationalisation/indemnisation, privatisation, levier via le Règlement Mensuel, krach et rebond, diversification.
- **Chiffres repères** : indice ≈ 229 fin 1977 → 2 001 fin 1989 (×8,7 en 12 ans, ≈ ×6 en réel avec dividendes réinvestis) ; inflation cumulée 1978-1989 ≈ +145 %.

### Période 2 — « Bulle et double krach » : 1995 → 2009 (15 ans)

- **Pitch** : l'euro arrive, Internet promet de tout changer, France Télécom entre en bourse et votre voisin double sa mise sur le Nouveau Marché. Puis deux krachs de −60 % en moins de 10 ans.
- **Pourquoi c'est pédagogique** : la décennie « perdue » (le CAC de fin 2009 est au niveau de 1998) montre que l'horizon long ne suffit pas toujours si l'on achète au sommet ; c'est la démonstration idéale du DCA, de la valorisation (PER), des bulles, du risque spécifique (France Télécom, Vivendi, Alcatel, Natixis) et de l'effet de levier (SRD).
- **Événements clés** : E29 (fin), E30, E31, E32, E33, E34, E35, E36, E37, E38.
- **Notions couvertes** : PEA, courtiers en ligne et baisse des frais, SRD / levier, vente à découvert, bulle, PER, market timing, DCA, diversification (titre unique vs indice), introduction en bourse, krach et rebond, dividendes (amortisseur dans les marchés plats), corrélation actions/obligations (les obligations montent quand les actions chutent en 2001-2002 et 2008).
- **Chiffres repères** : 1 872 (fin 1995) → 6 922 (sept. 2000) → 2 403 (mars 2003) → 6 168 (juin 2007) → 2 519 (mars 2009) → 3 936 (fin 2009).

### Période 3 — « Taux zéro, Covid et retour de l'inflation » : 2011 → 2025 (15 ans)

- **Pitch** : la zone euro vacille, les taux tombent à zéro puis deviennent négatifs, le Livret A rapporte 0,5 %… puis le Covid, le krach le plus rapide de l'histoire, et le retour de l'inflation qui fait chuter les obligations.
- **Pourquoi c'est pédagogique** : période la plus proche du joueur ; montre la « répression financière » (épargne sans risque à rendement réel négatif), le rôle des banques centrales, la vitesse des krachs modernes, le krach obligataire de 2022 (les obligations ne sont pas sans risque), l'intérêt de la diversification internationale (S&P 500) et l'importance des dividendes (CAC 40 GR vs CAC 40).
- **Événements clés** : E40, E41, E42, E43, E44, E45, E46, E47, E48, E49, E50.
- **Notions couvertes** : taux d'intérêt et prix des obligations, inflation et rendement réel, ETF/trackers, frais faibles et risque de surtrading, volatilité, krach et rebond, DCA, market timing, risque politique, flat tax et enveloppes, indice dividendes réinvestis, risque de change.
- **Chiffres repères** : 3 160 (fin 2011) → 8 149 (fin 2025), soit ≈ ×2,6 hors dividendes et ≈ ×4 dividendes inclus.

### Bonus (mode « libre » ou défi)

- **« Les Trente Glorieuses » 1950 → 1967** : un marché qui quintuple puis perd près de la moitié en 5 ans. Données **C** (reconstituées) : à réserver à un mode « découverte » en le signalant.
- **« Le défi de la décennie perdue » 2000 → 2012** : battre le Livret A en partant du sommet de 2000.

---

## 6. Recommandations pour simuler les cours dans le jeu

### 6.1 Pas de temps et ancrages

- **Pas de simulation : la semaine** (ou le mois si la frise est très compressée). Le joueur voit une courbe hebdomadaire ; des journées particulières (records de séance, section 3.1) peuvent être injectées comme « zoom » narratif.
- **Ancrages durs** (la courbe DOIT passer par ces points) : clôtures annuelles (4.2) + points de séance ★ et fins de mois des périodes de crise (4.4).
- **Ancrages souples** : niveaux approximatifs (certitude C) que l'on peut manquer de ±5 %.

### 6.2 Interpolation entre ancrages : pont brownien en log

Entre deux ancrages (t0, S0) et (t1, S1), générer le log-cours par un **pont brownien** :

```
x(t) = ln S(t)
tendance  : m(t) = ln S0 + (ln S1 - ln S0) * (t - t0) / (t1 - t0)
bruit     : B(t) = W(t) - (t - t0)/(t1 - t0) * W(t1)    // W = marche aléatoire
x(t)      = m(t) + B(t)
avec W(t+dt) = W(t) + sigma * sqrt(dt) * eps,  eps ~ Student-t (nu = 4, réduite)
```

- La loi de Student (queues épaisses) reproduit les séances extrêmes mieux qu'une loi normale.
- **Volatilité annualisée `sigma` par régime** (indice) :

| Régime | sigma indice | Exemples |
|---|---|---|
| Calme | 12-15 % | 1955-1956, 1964-1966, 2004-2006, 2017 |
| Normal | 16-20 % | la plupart des années |
| Agité | 25-30 % | 1974, 1981, 1990, 1998, 2011, 2022 |
| Crise aiguë | 40-60 % | oct.-nov. 1987, sept.-oct. 2001, oct. 2008-mars 2009, mars 2020 |

- **Graine aléatoire** fixe par partie : deux joueurs sur la même période voient les mêmes fins d'année (réalité historique) mais le chemin intra-annuel peut varier d'une partie à l'autre (rejouabilité) — ou être figé (mode « histoire exacte »).
- **Clustering de volatilité** : après une semaine à plus de 2 sigmas, multiplier sigma par 1,5 pendant 4-8 semaines (décroissance exponentielle). Effet « les krachs arrivent en grappes ».
- **Asymétrie** : les baisses sont plus rapides que les hausses (« l'ascenseur à la descente, l'escalier à la montée ») ; on peut l'obtenir en tirant le bruit avec un léger biais négatif quand la volatilité est élevée.

### 6.3 Gestion des événements

Structure de données suggérée :

```
Evenement {
  id, date_debut, date_fin,
  type: "marche" | "politique" | "monetaire" | "reglementaire" | "entreprise" | "vie",
  choc_indice_pct,          // ex. -30 (déjà inclus dans les ancrages historiques -> sert au récit)
  profil: "instantane" | "lineaire" | "panique_puis_rebond",
  sigma_multiplicateur,     // ex. 2.5 pendant l'événement
  impacts_secteurs: { banque: 1.5, petrole: -0.5, luxe: 1.0 ... },  // multiplicateurs de beta
  impact_taux_points, impact_inflation_points,
  notion_debloquee, texte_actualite, texte_lecon
}
```

- **Mode historique** : les chocs sont déjà dans les ancrages ; l'événement sert à afficher la « une » du journal, à augmenter sigma, à appliquer les impacts sectoriels sur les actions individuelles et à déclencher la leçon.
- **Pas de divulgâcheur** : le texte d'actualité doit être rédigé **comme à l'époque** (« Inquiétude sur les marchés après… »), sans révéler l'issue. La leçon s'affiche **après** (bilan de fin d'année ou fin d'événement).
- **Mode uchronie (optionnel)** : tirer des événements aléatoires dans le catalogue avec une fréquence réaliste (marché baissier de −20 % ≈ 1 fois tous les 5-6 ans ; krach > −35 % ≈ 1 fois tous les 10-12 ans ; année négative ≈ 1 année sur 3).
- **Événements de vie** couplés : licenciement pendant une récession (1975, 1993, 2009), héritage, achat immobilier : ils forcent le joueur à vendre ou à ne pas pouvoir acheter au plus bas — c'est la leçon « horizon de placement ».

### 6.4 Actions individuelles autour de l'indice

Modèle à facteurs simple (hebdomadaire, en log-rendements) :

```
r_i(t) = alpha_i(t) + beta_i * r_marche(t) + gamma_i,s * r_secteur_s(t) + e_i(t) + saut_i(t)
e_i(t) ~ Student-t(nu=4) * vol_spe_i * sqrt(dt)
```

- `beta_i` et `vol_spe_i` : voir tableau 4.5 (bancaires 1,4-1,6 ; luxe ≈ 1,1 ; pétrole et gaz industriels 0,7-0,8 ; technologie 1,5-1,8 en période de bulle).
- **Facteurs sectoriels** (`r_secteur`) : 5-6 secteurs suffisent (banque, énergie, industrie/auto, consommation/luxe, technologie/télécoms, services aux collectivités), chacun avec sa propre petite volatilité (8-12 %) et des réactions spécifiques aux événements (pétrole ↑ en 1973/1979/2022, banques ↓ en 2008/2011, technologie ↑↑ puis ↓↓ en 1999-2002).
- **Calibrage de `alpha_i`** : pour que l'action passe par ses points d'ancrage du tableau 4.5, résoudre alpha sur chaque segment (pont brownien appliqué au **résidu** `ln S_i - beta * ln Indice`). Ainsi L'Oréal surperforme durablement et Alcatel s'effondre, tout en restant corrélées au marché.
- **Sauts spécifiques** (`saut_i`) : probabilité ≈ 2-4 %/an par titre d'un saut de −20 à −40 % (avertissement sur résultats, scandale) et ≈ 1-2 %/an d'une OPA à +20/+40 %. En mode historique, placer les sauts réels (Alcatel sept. 1998 −38 %, Société Générale janv. 2008, Vivendi 2002…).
- **Faillite / radiation** : prévoir l'état « titre suspendu » puis « radié » ou « restructuré » (Eurotunnel 2007 : échange contre de nouvelles actions + bons, valeur résiduelle faible).
- **Opérations sur titres** : divisions de nominal (Total 4:1 en 2006, Michelin 4:1 en 2023), actions gratuites (Air Liquide), augmentations de capital (Alcatel, banques 2009-2012), scissions (Vivendi 2024). Le moteur doit stocker les prix **ajustés** et afficher les prix **réels d'époque**.
- **Dividendes** : versés une fois par an (avril-juin le plus souvent), le cours baisse du montant du dividende le jour du détachement ; rendement par titre = rendement de marché ± 1,5 point selon le profil (Total, banques : élevé ; LVMH, L'Oréal : plus faible ; technologie : quasi nul). Réduire ou supprimer les dividendes des banques en 2009 et en 2020 (recommandation BCE).

### 6.5 Obligations, livret et inflation

- **Obligation d'État 10 ans** : prix mensuel approximé par `ΔP/P ≈ -D * Δy + y/12` avec une duration `D ≈ 7-8` (≈ 6 quand les taux sont > 10 %). Ex. 2022 : +2,5 points de taux → ≈ −18 % de prix. Ex. 1985-1986 : −5 points → ≈ +30 %.
- **Fonds monétaire / Livret A** : capitalisation mensuelle du taux du tableau 4.3 (Livret A : intérêts par quinzaine, versés au 31/12 — simplifiable).
- **Inflation** : appliquer `(1 + infl_annuelle)^(1/52)` par semaine ; afficher **systématiquement** une courbe « patrimoine en euros constants ». C'est le cœur pédagogique des années 1970-1980.

### 6.6 Ordres et microstructure (réalisme sans complexité)

- **Ordre au marché** : exécuté au cours de la semaine + demi-fourchette (0,1 % grandes valeurs ; 0,5-2 % petites valeurs / Second Marché ; ×3 en crise). Avant 1986 (criée), exécution au cours du jour suivant (« au premier cours » ou « au cours d'ouverture »).
- **Ordre à cours limité** : exécuté si le plus bas (achat) ou le plus haut (vente) de la période simulée franchit la limite ; générer un `haut`/`bas` hebdomadaire ≈ cours ± 0,6 × sigma_hebdo.
- **Levier (RM / SRD)** : couverture 20 % (levier ×5) ; appel de marge si la perte dépasse la couverture → liquidation forcée au cours suivant. Frais de report ≈ taux monétaire + 2 à 3 %/an.
- **Vente à découvert** : autorisée sur les grandes valeurs via le RM/SRD ; interdire temporairement sur les financières en sept. 2008, août 2011 et mars 2020 (cohérent avec les décisions des régulateurs de l'époque).

### 6.7 Contrôles de cohérence à automatiser (tests unitaires)

1. Les clôtures simulées au 31/12 = table 4.2 (tolérance 0 pour certitude A, ±5 % pour C).
2. Pire semaine simulée de 1987 ≤ −15 % ; de 2008 ≤ −20 % ; de 2020 ≤ −20 %.
3. Proportion d'années négatives sur 1950-2025 ≈ 40 % (table : 30 années sur 76).
4. Rendement annuel moyen du portefeuille « 100 % indice, dividendes réinvestis » sur 1988-2025 ≈ 8,5-9,5 %/an.
5. Corrélation hebdomadaire action/indice comprise entre 0,4 et 0,8 pour chaque titre.

---

## Sources

- Tableau annuel CAC 40 (1969-2025, rétropolé) : [Wikipedia — CAC 40](https://en.wikipedia.org/wiki/CAC_40)
- Clôture 2025 (8 149,50 ; +10,42 % ; CAC 40 GR +14,3 % ; records 2025) : [Tradingsat](https://www.tradingsat.com/cac-40-FR0003500008/actualites/cac-40-le-cac-40-a-pris-1042-en-2025-une-performance-en-demi-teinte-1153343.html), [Francetransactions](https://www.francetransactions.com/amp/actus/news-bourse/marches/cac40-performance-2025.html)
- Meilleure année 1954, pire année 2008, rendement réel France depuis 1900 : [Tradingsat — pires années depuis 1900](https://www.tradingsat.com/cac-40-FR0003500008/actualites/cac-40-quelles-ont-ete-les-pires-annees-pour-les-grandes-places-boursieres-depuis-1900-1060799.html)
- Bourse 1966-1994 (pertes 1966-1967, base fin 1961, 1975, 1977, 1981, 1990) : [Larousse — Journal de l'année, Bourse](https://www.larousse.fr/archives/journaux_annee/perspectives/10_Bourse)
- Krach 1987 à Paris (−9,7 % le 19 oct., niveaux CAC Général) : [Larousse — Journal de l'année 1988](https://www.larousse.fr/archives/journaux_annee/1988/91/panorama)
- Inflation France 1960-2025 : [FRED / Banque mondiale FPCPITOTLZGFRA](https://fred.stlouisfed.org/data/FPCPITOTLZGFRA) ; 1979-2008 INSEE : [Assemblée nationale, QE n° 38037](https://www.assemblee-nationale.fr/dyn/13/questions/QANR5L13QE38037.pdf) ; 2000-2025 : [Moneyvox](https://www.moneyvox.fr/placement/inflation.php)
- Taux 10 ans France 1960-2025 : [FRED / OCDE IRLTLT01FRA156N](https://fred.stlouisfed.org/data/IRLTLT01FRA156N)
- Pires séances du CAC 40 : [Tradingsat — 5 pires séances](https://www.tradingsat.com/cac-40-FR0003500008/actualites/cac-40-brexit-attentats-crise-des-subprimes-voici-les-5-pires-seances-de-l-histoire-du-cac-40-903671.html), [Tradingsat — lundi noir 2020](https://www.tradingsat.com/cac-40-FR0003500008/actualites/cac-40-lundi-noir-en-bourse-le-cac-40-plonge-de-839-et-signe-la-2e-plus-forte-baisse-de-son-histoire-903673.html)
- CAC (cotation assistée en continu), palais Brongniart : [Wikipedia — Cotation Assistée en Continu](https://en.wikipedia.org/wiki/Cotation_Assist%C3%A9e_en_Continu), [Wikipedia — Palais Brongniart](https://en.wikipedia.org/wiki/Palais_Brongniart), [Tradingsat — lexique](https://www.tradingsat.com/lexique-boursier/definition-palais-brongniart-169.html), [Boursorama — indices France](https://www.boursorama.com/bourse/indices/france)
- TTF (0,2 % → 0,3 % → 0,4 %) : [Moneyvox — TTF 15 ans après](https://www.moneyvox.fr/bourse/actualites/110311/taxe-sur-les-transactions-financieres-quel-bilan-15-ans-apres), [Le Petit Juriste](https://www.lepetitjuriste.fr/taxe-sur-les-transactions-financieres-entre-efficacite-fiscale-et-volontarisme-politique/)
- Livret A : [ADCF — historique](https://www.adcf.org/taux-livret-a/), [Ramify](https://www.ramify.fr/epargne/taux-livret-a)
- France Télécom (IPO, pic 2000) : [Clubic](https://www.clubic.com/actualite-44398-.html), [ABC Bourse — forum](https://www.abcbourse.com/forums/msg866667_orange--ne-m-appelez-plus-jamais-france)
- Eurotunnel : [Tradingsat — petits porteurs](https://www.tradingsat.com/getlink-se-FR0010533075/actualites/getlink-se-petits-porteurs-ruines-nicolas-sarkozy-a-la-rescousse-355630.html), [Webmanagercenter 2007](https://www.webmanagercenter.com/2007/06/29/30225/dette-reduite-nouvelles-actions-eurotunnel-fait-peau-neuve/)
- S&P 500 et or fin 2025 : [Barchart](https://www.barchart.com/story/news/36832066/is-one-asset-screaming-that-stocks-are-cheap-going-into-2026-can-the-s-p-500-reach-10-000-in-2026), [The Business Journal](https://thebusinessjournal.com/stocks-close-slightly-lower-in-quiet-post-christmas-trading/), [Metalcharts](https://metalcharts.org/gold-price-history/2025)
- Référence académique (non consultable en ligne lors de la rédaction, à exploiter pour fiabiliser 1950-1968) : Gallais-Hamonno & Arbulu, « La rentabilité réelle des actifs boursiers de 1950 à 1992 », *Économie et Statistique* n° 281, 1995 ([RePEc](https://ideas.repec.org/a/prs/ecstat/estat_0336-1454_1995_num_281_1_5927.html)) ; Le Bris & Hautcœur, « A challenge to triumphant optimists? A blue chips index for the Paris stock exchange 1854-2007 », *Financial History Review*, 2010 ([RePEc](https://ideas.repec.org/a/cup/fihrev/v17y2010i02p141-183_00.html)).

> **À faire pour fiabiliser** (si l'équipe veut passer la période 1950-1968 de C à B) : récupérer les séries annuelles de l'indice INSEE des valeurs françaises à revenu variable (ou le tableau de Le Bris & Hautcœur) et recaler la colonne `indice` 1950-1968 en conservant le point d'ancrage 1969 = 334,1.

---

## 7. Réponses au client

> Réponses aux 6 questions posées au boursier dans `00_vision_client.md` (§ 5), en tenant compte des contraintes de la vision (parties de **15 ans**, **1 tour = 1 mois**, **5 à 8 événements historiques par période en V1**, priorité au plaisir, simplicité) et de la règle UX (`04_ux_design.md`, § 4) : **aucun événement de marché à venir n'est affiché sur la frise**.

### Q1. Les 3 périodes majeures : recommandation finale

**Votre proposition** (1978-1995 / 1995-2012 / 2008-aujourd'hui) a le bon esprit : chaque période a une identité claire. Elle pose trois problèmes techniques :
1. **Durées de 17-18 ans** pour une partie standard de 15 ans : soit la partie s'arrête avant la fin du « thème » (on rate 2011 en partant de 1995), soit il faut une durée non standard.
2. **Chevauchements** : 1995 apparaît deux fois, et 2008-2012 figure dans deux périodes. Le joueur qui enchaîne les trois périodes revit la crise de 2008.
3. **« 2008-aujourd'hui »** démarre en pleine crise : l'événement Lehman tombe au 9e mois, avant la fin du tutoriel, alors que le joueur n'a encore rien placé. C'est un mauvais premier contact, et c'est l'inverse de la leçon (le joueur sans actions est « gagnant » par hasard).

Ma proposition initiale (1977-1990 / 1995-2009 / 2011-2025) avait l'inconvénient inverse : elle n'était pas calée sur 15 ans et coupait le PEA de 1992.

**Recommandation finale : trois périodes de 15 ans pile (180 mois), sans chevauchement, en gardant vos noms.**

| # | Nom (client) | Début → fin | Mois | CAC (échelle 4.2) début → fin | Secousses (pour la carte UX) | Monnaie |
|---|---|---|---|---|---|---|
| **P1** | **Les années fric** | **janv. 1978 → déc. 1992** | 180 | 229 → 1 858 (×8,1 en prix ; ≈ ×15 dividendes réinvestis ; inflation cumulée ≈ +165 %) | ●●●○ | Franc |
| **P2** | **De l'euphorie à la crise** | **janv. 1996 → déc. 2010** | 180 | 1 872 → 3 805 (×2 en prix ; ≈ ×3 dividendes réinvestis) | ●●●● | Franc → euro (1999 / 2002) |
| **P3** | **L'ère des ETF** | **janv. 2011 → déc. 2025** | 180 | 3 805 → 8 150 (×2,1 en prix ; ≈ ×3,4 dividendes réinvestis) | ●●●○ | Euro |

Justification :
- **P1** démarre au plus bas d'une traversée du désert de 15 ans (l'indice de mai 1977 vaut la moitié de celui de 1961). On y trouve l'inflation à deux chiffres, le Livret A à 8,5 %, 1981, la désinflation de 1983, les privatisations, le krach de 1987 et la guerre du Golfe. Le PEA est débloqué en juillet 1992 : c'est la récompense de fin de partie, et un « teaser » pour la partie suivante.
- **P2** garde la décennie perdue entière : Nouveau Marché (février 1996), France Télécom, bulle, double krach, passage à l'euro et ETF CAC 40 (2001). Le premier choc tombe en 1997-1998, après le tutoriel.
- **P3** commence juste avant la crise des dettes souveraines (août 2011, mois 8, après le tutoriel). On la termine sur des records (2025), avec les taux zéro, le Covid, l'inflation de 2022 et le risque politique français. Ce n'est pas « 2008 », mais la leçon de 2008 est mieux servie en P2, où le joueur a eu le temps de construire un portefeuille.
- **Trente Glorieuses** : je **déconseille** de les mettre en V1. Mes données 1950-1968 sont reconstituées (certitude C) et les produits sont très limités (pas de SICAV avant 1964). Elles sont surtout moins dramatiques pour un débutant : longue hausse, puis longue érosion lente. À garder pour l'année libre en V2.
- **Accroches des cartes** : pour respecter la règle UX « on ne spoile pas », les accroches ne devraient pas nommer les krachs avec leur date. La maquette UX écrit « krach de 87 » : je propose « Inflation à deux chiffres, élections à hauts risques, la Bourse se modernise. » (P1), « L'euro arrive, Internet s'emballe… et après ? » (P2), « Taux zéro, pandémie, retour de l'inflation. » (P3).

### Q2. Les événements incontournables (V1 : 5 à 8 par période)

Lecture des colonnes :
- `Impact` : variation de l'indice actions français (échelle 4.2) ;
- `Récupération` : temps pour que **l'indice de prix** retrouve son niveau d'avant l'événement (les dividendes raccourcissent ce délai) ;
- `Type` : `-` négatif, `+` positif ou opportunité (pastille verte de la modale UX).

Tous ces événements se déclenchent **le mois indiqué**, sans marqueur préalable sur la frise. Certitude : A ou B pour les dates et amplitudes (voir sections 3 et 4.4), C pour les récupérations de la P1.

#### P1 — Les années fric (janv. 1978 → déc. 1992) : 8 événements

| # | Mois | Type | Manchette (pastiche) | Impact | Récupération | Leçon en une phrase |
|---|---|---|---|---|---|---|
| 1 | **mars 1978** | + | « Législatives : la majorité sauve son siège, la Bourse exulte » | +30 % en 4 mois, +46 % sur l'année | — | Quand une grande incertitude se lève, la Bourse bondit avant qu'on ait eu le temps de réagir. |
| 2 | **déc. 1979** | − (silencieux) | « Deuxième choc pétrolier : les prix s'envolent » | Indice +8 % en 1980, mais inflation 13,6 % : **≈ −5 % en pouvoir d'achat** | — | Gagner 8 % quand les prix montent de 13 %, c'est s'appauvrir : seul le rendement réel compte. |
| 3 | **mai 1981** | − | « Mitterrand élu : vent de panique à la corbeille » | **−30 %** en 5 semaines | ≈ 2 ans (printemps 1983) | Le risque politique fait chuter le marché d'un coup ; celui qui a vendu en juin 1981 a raté le rebond de 1983. |
| 4 | **mars 1983** | + | « Tournant de la rigueur : le franc tient, la Bourse respire » | **+57 %** sur l'année 1983 | — | Quand l'inflation et les taux baissent, actions et obligations montent ensemble. |
| 5 | **déc. 1986** | + (opportunité) | « Saint-Gobain privatisé : les Français font la queue aux guichets » | Marché +50 % en 1986 ; souscription à prix fixe | — | L'euphorie collective est agréable… mais « tout le monde achète » n'est pas un argument. |
| 6 | **oct. 1987** | − | « Lundi noir : la Bourse de Paris dévisse » | −9,7 % le 19 ; **−22 %** du 16 oct. au 10 nov. ; −36 % depuis le sommet du printemps | ≈ 8 mois pour le niveau d'avant le krach, ≈ 14 mois pour le sommet de 1987 | Un krach est brutal mais rarement définitif : celui qui a tenu a tout récupéré en un peu plus d'un an. |
| 7 | **août 1990** | − | « L'Irak envahit le Koweït : le pétrole flambe, les actions plongent » | **−31 %** (avril → septembre) | ≈ 3 ans (1993) | Certaines reprises sont lentes : n'investissez en actions que l'argent dont vous n'aurez pas besoin avant longtemps. |
| 8 | **sept. 1992** | − (court) | « Maastricht : oui du bout des lèvres, tempête sur le franc » | ≈ −15 % en quelques semaines | ≈ 6 mois | La volatilité fait partie du voyage ; au même moment, le PEA (juillet 1992) récompense ceux qui restent investis longtemps. |

Déblocages de produits liés (notifications « Nouveau », sans pause) : SICAV Monory (juillet 1978), Second Marché (1983, V2), CAC 40 (juin 1988 : l'indice change de nom dans le bandeau), PEA (juillet 1992).

#### P2 — De l'euphorie à la crise (janv. 1996 → déc. 2010) : 8 événements

| # | Mois | Type | Manchette (pastiche) | Impact | Récupération | Leçon en une phrase |
|---|---|---|---|---|---|---|
| 1 | **oct. 1997** | + (opportunité) | « France Télécom entre en Bourse : 27,75 € l'action, ruée des particuliers » | Action ×8 en 29 mois (219 € en mars 2000), puis ≈ 7 € à l'automne 2002 | — | Une introduction très médiatisée n'est ni un cadeau garanti ni un piège garanti : tout dépend du prix payé ensuite. |
| 2 | **sept. 1998** | − | « Crise russe : un fonds géant au bord de la faillite » | **−35 %** (juillet → octobre) ; année 1998 quand même +31 % | ≈ 6 mois | Une même année peut contenir un krach et finir en forte hausse. |
| 3 | **mars 2000** | + (piège) | « Internet : la nouvelle économie ne connaît plus la crise » | Marché +51 % en 1999, PER délirants ; sommet du CAC en septembre 2000 | — | Quand on achète parce que « ça monte », on est dans une bulle : elle finit toujours par éclater. |
| 4 | **sept. 2001** | − | « Attentats à New York : les marchés sous le choc » | −7,4 % le 11 ; **−23 %** en 3 semaines | ≈ 2 mois | Les chocs d'actualité les plus terribles ont souvent un effet boursier passager. |
| 5 | **juil. 2002** | − | « Vivendi, France Télécom : les géants vacillent » | **−34 %** sur 2002 ; −65 % depuis le sommet de 2000 au plus bas (mars 2003) | Sommet de 2000 : **21 ans** en prix (2021), ≈ 7 ans dividendes réinvestis | Mettre tous ses œufs dans une seule action peut coûter 90 % ; et acheter au sommet d'une bulle se paie pendant des années. |
| 6 | **mars 2003** | + (opportunité) | « Guerre en Irak : la Bourse au plus bas depuis 1997 » | Point bas, puis **+48 %** en 12 mois | — | C'est quand tout le monde a peur que les actions sont soldées ; le versement programmé en profite tout seul. |
| 7 | **oct. 2008** | − | « Lehman Brothers emporte la finance mondiale » | −9 % le 6 oct. ; **−59 %** de juin 2007 à mars 2009 ; +22 % en 2009 | Sommet de 2007 : ≈ 14 ans en prix (2021), ≈ 8 ans dividendes réinvestis | Les pires et les meilleures séances se suivent de près : vendre dans la panique fait rater le rebond. |
| 8 | **mai 2010** | − | « La Grèce au bord du gouffre, l'Europe sort le chéquier » | ≈ −18 % en 5 semaines, +9,7 % en une séance le 10 mai | ≈ 9 mois | Les interventions publiques massives provoquent des rebonds aussi violents que les chutes. |

Déblocages : Nouveau Marché (février 1996, V2), euro (double affichage en janvier 1999, « moment euro » en janvier 2002), **ETF CAC 40 (janvier 2001)**, courtage en ligne (baisse des frais vers 2000).

#### P3 — L'ère des ETF (janv. 2011 → déc. 2025) : 7 événements

| # | Mois | Type | Manchette (pastiche) | Impact | Récupération | Leçon en une phrase |
|---|---|---|---|---|---|---|
| 1 | **août 2011** | − | « Dette : la zone euro tremble, les banques s'effondrent » | **−30 %** (juillet → septembre), banques −50 % | ≈ 2 ans (2013) | Même les États peuvent faire peur ; diversifier ses placements limite les dégâts. |
| 2 | **juil. 2012** | + | « La BCE promet de sauver l'euro “quoi qu'il en coûte” » | ≈ +22 % en 12 mois | — | Les banques centrales pèsent énormément sur les marchés : ne jamais parier contre elles à court terme. |
| 3 | **juin 2016** | − (court) | « Brexit : le Royaume-Uni claque la porte, Paris plonge » | **−8 %** en une séance | ≈ 3 semaines | Les surprises politiques font des chutes spectaculaires mais souvent brèves. |
| 4 | **mars 2020** | − | « Coronavirus : le monde se confine, la Bourse s'écroule » | **−39 %** en 1 mois (−12 % le 12 mars, record) | ≈ 13 mois (avril 2021) | Le krach le plus rapide de l'histoire a aussi connu l'un des rebonds les plus rapides : rester investi a payé. |
| 5 | **juin 2022** | − (actions ET obligations) | « L'inflation au plus haut depuis 1985, la BCE relève ses taux » | Actions **−23 %** (janvier → septembre) ; obligations d'État ≈ −15 à −20 % ; Livret A de 1 % à 2 % puis 3 % | ≈ 14 mois (printemps 2023) | Quand les taux montent, les obligations baissent aussi : « sans risque » ne veut pas dire « sans perte ». |
| 6 | **juin 2024** | − | « Dissolution surprise : la Bourse de Paris décroche » | ≈ −6 % en une semaine, banques −10 à −15 % ; CAC −2 % en 2024 quand Wall Street fait +23 % | ≈ 8 mois | Un seul pays, c'est un seul risque politique : un ETF monde aurait amorti le choc. |
| 7 | **avr. 2025** | − | « Guerre commerciale : la Bourse vit sa pire semaine depuis 2020 » | ≈ **−16 %** depuis le record de mars, en quelques séances | ≈ 6 mois (record en octobre 2025) | Les paniques sur une annonce politique peuvent se dissiper aussi vite qu'elles sont venues. |

Notifications sans pause (taux zéro) : Livret A à 0,75 % (août 2015) puis 0,5 % (2020), OAT 10 ans sous 0 % (2019-2021). Ce sont les meilleures occasions de montrer que l'argent « sans risque » perd du pouvoir d'achat même sans krach. Déblocages : PEA-PME (2014), flat tax (2018), ETF monde dans le PEA (V2).

### Q3. Quelles données de prix utiliser ?

- **Indice** : la table 4.2 couvre les 3 périodes en données **A** (P2, P3) ou **A/B** (P1 : CAC Général rétropolé, cohérence vérifiée). Il n'y a pas d'indice à reconstituer pour la V1. Seule l'année libre avant 1969 utilisera la reconstitution C.
- **Pas mensuel** : générer les 180 mois par **pont brownien en log** entre les clôtures annuelles, en forçant le passage par les points mensuels des crises (4.4). Volatilité mensuelle : 4-5 % en temps normal, 8-12 % en crise. La recette est décrite en 6.2.
- **Recommandation forte : pré-calculer les courbes une fois pour toutes** (script du développeur, graine fixe) et les livrer comme un fichier de données (`prix_P1.json`…). Chaque partie d'une même période a ainsi exactement les mêmes cours : c'est plus juste pour « Rejouer autrement » et plus facile à vérifier. L'aléa du jeu vient des événements de vie, pas des cours.
- **Fonds actions France (SICAV)** = indice **dividendes réinvestis** − frais (frais d'entrée 2 %, frais de gestion 1,5 %/an avant 2001 ; voir Q6). **ETF CAC 40** (à partir de janvier 2001) = la même formule avec 0,25 %/an de frais et sans frais d'entrée. **Emprunt d'État** = taux 10 ans de la table 4.2 ; pour garder la V1 simple, on le traite comme un livret à taux fixé à l'achat, sans fluctuation de prix (voir l'encadré ci-dessous).
- **Actions** : 4 ou 5 par période, simulées avec le modèle à facteurs de 6.4 et calées sur les ancrages de 4.5.

| Période | Actions V1 conseillées | Profil à reproduire (vs indice) | Cert. |
|---|---|---|---|
| P1 | **Elf Aquitaine** (ou CFP-Total), **L'Oréal**, **Peugeot**, **Saint-Gobain** (débloquée en déc. 1986 à la privatisation) | Elf : forte 1979-1980 (pétrole), faible en 1986 (contre-choc). L'Oréal : surperforme ≈ ×1,5 sur la période, peu de chutes. Peugeot : −60 % de 1979 à 1984 (pertes, rachat de Chrysler Europe), puis ≈ ×5 de 1985 à 1989, rechute en 1990. Saint-Gobain : comme l'indice, β 1,2. | C |
| P2 | **France Télécom** (oct. 1997), **Alcatel**, **Vivendi**, **L'Oréal**, **Total** | Les 3 premières : ×3 à ×8 jusqu'en 2000, puis −90 % à −97 % jusqu'en 2002. L'Oréal et Total : défensives, baissent ≈ deux fois moins que l'indice en 2001-2003. | B |
| P3 | **LVMH**, **TotalEnergies**, **BNP Paribas**, **Orange**, **Stellantis** (Peugeot jusqu'en janv. 2021) | LVMH : ≈ ×5 de 2011 à 2023, puis −35 %. BNP : −50 % en 2011, ×3 ensuite. Orange : stagne, mais dividende de 5-6 %. Total : suit le pétrole (−50 % en 2020). Stellantis : ×5 de 2012 à 2024, puis −65 %. | B |

> Remarque sur l'obligation en V1 : un emprunt d'État à taux fixe **conservé jusqu'à l'échéance** rapporte exactement son taux. On peut donc l'afficher comme un « placement à taux garanti 10 ans », sans cours. La baisse de prix des obligations quand les taux montent (2022) est une notion V2, ou une simple notification en P3.

### Q4. Les notions minimales à la fin d'une partie (classées par importance)

1. **Inflation et pouvoir d'achat** : seul le rendement après inflation compte. Le compte courant et le livret peuvent appauvrir.
2. **Intérêts composés et versement programmé** : le temps et la régularité font le gros du travail.
3. **Risque et horizon** : les actions rapportent plus *parce qu'elles* fluctuent. Elles conviennent à l'argent dont on n'a pas besoin avant 8-10 ans.
4. **Krach et rebond** : ne pas vendre dans la panique, car les meilleures séances suivent les pires.
5. **Épargne de précaution** : 3 à 6 mois de dépenses sur le livret, pour ne jamais être forcé de vendre au plus bas.
6. **Diversification** : un fonds ou un indice plutôt qu'une seule action. Le « Cousin Indice » le montre.
7. **Frais** : 1 % par an de plus, c'est un quart du capital en moins sur 30 ans.
8. **Dividendes et enveloppe fiscale (PEA)** : une part importante du gain vient des dividendes, et l'enveloppe change le résultat final.

(Les notions 9 et suivantes de la section 1, comme les ordres limités, le levier, la vente à découvert, le PER ou le lien entre taux et obligations, relèvent de la V2.)

### Q5. Quel mécanisme d'ordre pour la V1 ?

**Un seul ordre : « au prix du mois ».** Il est simple et pas faux, puisque c'est la logique d'un ordre au marché.

- Le joueur voit le **cours du mois en cours** (cours de fin de mois pré-calculé, affiché comme « cours actuel »). Tout achat ou vente passé pendant ce mois s'exécute **à ce cours**, frais en plus. Il n'y a pas de triche possible : le cours du mois suivant est inconnu.
- **Pendant une modale d'événement**, l'ordre s'exécute au **cours de l'événement** (champ `cours_evenement` dans les données, par exemple ≈ 1 120 le 20 octobre 1987), et non au cours de fin de mois. Sinon le joueur qui vend « en direct » pendant le krach obtiendrait un prix qu'il n'a pas vu. Variante encore plus simple : le cours affiché pendant la modale *est* le cours du mois.
- **Montant saisi en argent** (choix UX). Le jeu achète le nombre entier d'actions et des fractions de parts pour la SICAV et l'ETF (les parts de SICAV se fractionnent réellement en millièmes).
- **Frais** : une seule formule `max(minimum, taux × montant)`, avec deux jeux de paramètres. Avant 2000 (agence bancaire) : 0,7 % avec un minimum d'environ 50 F, et 0,3 % d'impôt de bourse. Après 2000 (en ligne) : 0,5 % avec un minimum de 5 €, plus la TTF de 0,2 à 0,4 % sur les grosses valeurs à partir d'août 2012. SICAV : frais d'entrée de 2 % et pas de courtage. ETF : comme une action. Les droits de garde sont ignorés en V1, ou fixés à 0,2 %/an avant 2000.
- **Petite nuance historique** à mettre dans une bulle « Le saviez-vous ? » : avant 1986, l'ordre partait par la banque et s'exécutait à la criée le lendemain. Le jeu simplifie.
- **Ordre à cours limité** : en V2, comme le souhaite le client. Si on l'ajoute, il s'exécute si la limite est comprise entre le plus bas et le plus haut du mois.

### Q6. Calculer « Cousin Indice » de façon juste et simple

Principe : le Cousin vit **exactement la même vie** que le joueur (même salaire, mêmes dépenses, mêmes événements de vie, même graine) et suit une règle mécanique.

1. **Coussin d'abord** : tant que son Livret A ne contient pas 3 mois de dépenses, il y verse son excédent du mois. Sans coussin, le premier coup dur le forcerait à vendre, et il ne serait plus « celui qui ne vend jamais ».
2. **Puis tout l'excédent du mois va dans le fonds indiciel** (salaire − dépenses − coûts des événements). Le montant n'est pas fixe : c'est l'épargne réellement disponible, comme pour le joueur. Si le client tient à une somme strictement constante, prendre la moyenne de l'excédent prévu sur la période, mais c'est moins juste pour le joueur.
3. **Coups durs** : payés par le coussin, puis reconstitués en priorité. Il ne vend des parts que si le coussin est vide. Cela reste rare et doit être journalisé, car c'est une leçon en soi.
4. **Le produit** : SICAV actions France jusqu'en 2000, puis ETF CAC 40 à partir de 2001. Il passe dans un PEA dès que le PEA existe (juillet 1992), dans la limite du plafond.
5. **Dividendes réinvestis : oui**, toujours. C'est ce que fait réellement une SICAV de capitalisation ou un ETF, et comparer au seul indice de prix pénaliserait injustement le Cousin d'environ 3 % par an.
6. **Frais : oui**, sinon la référence est trop flatteuse.

Formule mensuelle (VL = valeur de la part du fonds, I = indice de prix de la table 4.2 interpolé au mois, d = rendement du dividende annuel, f = frais de gestion annuels) :

```
VL(m)    = VL(m-1) × I(m) / I(m-1) × (1 + d/12) × (1 − f/12)
parts(m) = parts(m-1) + versement(m) × (1 − frais_entree) / VL(m)
valeur(m) = parts(m) × VL(m)
Paramètres : avant 2001 → frais_entree = 2 %, f = 1,5 % ; à partir de 2001 (ETF) → frais_entree = 0,2 % (courtage), f = 0,25 %
```

Ordres de grandeur pour vérifier (versements réguliers, dividendes réinvestis, avant impôt) : en P1, le Cousin finit très loin devant Tata Livret. En P2, il la bat de peu, et ses versements de 2000-2002 sont les seuls en perte. C'est la leçon « décennie perdue, mais le versement programmé sauve la mise ». En P3, il finit nettement devant, le Livret A ayant rapporté moins que l'inflation pendant 10 ans.

**Règle d'équité du bilan** : valoriser le joueur et les trois témoins **avec la même règle**. En V1, c'est la valeur brute, avant impôt sur les plus-values latentes. En V2, ce sera une valeur nette « comme si tout était vendu au dernier mois », avec l'avantage du PEA. Tata Livret applique le même coussin et la même logique, mais avec le Livret A. Au-delà du plafond du Livret A (donnée du banquier), l'excédent passe sur un second livret au même taux, pour rester simple.
