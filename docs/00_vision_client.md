# JeuClaude : la vision du client

> Document rédigé par le client, qui porte l'idée. C'est la référence pour toutes les décisions de périmètre.
> Ordre des priorités, non négociable : **1) s'amuser, 2) apprendre l'investissement boursier.**
> En cas de doute, on choisit la solution la plus simple.

---

## 1. Vision et public visé

### La vision en un paragraphe

JeuClaude est un petit jeu de gestion de vie et d'épargne où l'on incarne **un Français ou une Française ordinaire** qui démarre dans la vie active à l'époque de son choix, entre 1950 et aujourd'hui. Le temps défile sur une frise façon *Les Sims*. Le joueur touche son salaire, paie son loyer et ses courses, encaisse les coups durs (accident de voiture, licenciement, naissance) et les bonnes surprises (héritage, prime). Avec ce qui lui reste, il décide quoi faire de son argent. Il peut le garder sur le compte courant, le placer sur un livret, acheter des actions, des obligations ou des SICAV, et plus tard ouvrir un PEA ou acheter un ETF. Il ne peut utiliser **que ce qui existait vraiment à cette date**. Les vrais événements de l'histoire (choc pétrolier, nationalisations de 1981, krach de 1987, bulle Internet, 2008, Covid, retour de l'inflation) secouent son patrimoine. On apprend en jouant, et non en lisant un cours : pourquoi l'inflation ronge le bas de laine, pourquoi diversifier, pourquoi ne pas vendre en pleine panique, et à quoi sert une enveloppe fiscale.

### Public visé

- **Cœur de cible** : des adultes de 18 à 40 ans, curieux, qui n'ont jamais investi en bourse ou qui ont un livret A « parce que c'est ce qu'on fait ». Ils ont entendu parler du PEA et des ETF sans oser se lancer.
- **Cible secondaire** : des lycéens et des étudiants (cours d'économie, éducation financière), et des parents qui veulent montrer le principe à leurs enfants.
- **Ce que le public n'est pas** : des traders confirmés. Pas de graphiques en chandeliers, pas d'analyse technique, pas de vente à découvert en V1.
- **Contrainte de plateforme** : le jeu se lance **en double-cliquant sur un fichier, sous Windows, sans rien installer ni créer de compte**. Il doit fonctionner hors ligne.

---

## 2. La boucle de jeu

### 2.1 Démarrage de la partie (environ 1 minute)

1. **Choix de la date de départ** :
   - soit le joueur saisit une année entre 1950 et aujourd'hui ;
   - soit il clique sur « Je n'ai pas d'idée » et le jeu lui propose **3 périodes majeures**, chacune avec une accroche de deux lignes. Ce sont mes propositions, **à valider par le boursier** :
     - **« Les années fric » (1978-1995)** : fin des chocs pétroliers, inflation à deux chiffres, nationalisations de 1981 puis privatisations de 1986, création du CAC 40, krach de 1987, naissance du PEA en 1992.
     - **« De l'euphorie à la crise » (1995-2012)** : privatisations grand public (France Télécom), passage à l'euro, bulle Internet et son éclatement, 11 septembre, subprimes de 2008, crise des dettes de la zone euro.
     - **« L'ère des ETF » (2008-aujourd'hui)** : 2008, taux zéro, essor des ETF et du PEA, Covid en 2020, retour de l'inflation en 2022, remontée des taux.
2. **Choix du personnage** parmi 3 profils simples, sans éditeur complexe :
   - « Le jeune salarié » : petit salaire, aucune épargne, toute la vie devant lui ;
   - « La cadre pressée » : bon salaire, grosses dépenses, peu de temps ;
   - « L'héritier » : salaire modeste, mais un petit capital de départ.
   Le salaire et les dépenses sont **calibrés sur l'époque** : un salaire de 1980 en francs n'a rien à voir avec un salaire de 2020 en euros.
3. **Choix d'un objectif de vie**, parmi 3 au maximum :
   - **Acheter sa maison** : réunir un apport de X dans N années ;
   - **Prendre sa retraite tranquille** : atteindre un patrimoine de X à la fin de la partie ;
   - **Battre l'inflation** : finir avec un pouvoir d'achat supérieur à celui du départ, en euros constants. C'est l'objectif le plus simple, à proposer par défaut.

### 2.2 Ce que fait le joueur, minute par minute

**Le temps.** Une frise horizontale montre les années. Un curseur avance tout seul, avec les boutons *Pause / Vitesse 1 / Vitesse 2 / Vitesse 3*, comme dans Les Sims.
- **1 tour = 1 mois de jeu.** En vitesse 1, un mois passe en 3 à 5 secondes environ.
- **Une partie standard = 15 ans de jeu**, soit 180 mois, ce qui fait **15 à 25 minutes** de vraie vie avec les pauses.
- Le joueur peut **mettre en pause à tout moment** pour réfléchir et passer des ordres.

**Chaque mois, automatiquement :**
- le salaire tombe sur le compte courant ;
- les dépenses fixes (loyer, courses, transport) partent ;
- les intérêts et dividendes sont versés aux bonnes dates (les intérêts du livret une fois par an, ce qui est plus simple) ;
- les prix des actifs bougent à partir de **données historiques réelles ou plausibles**. Les gros mouvements doivent être fidèles à l'histoire.

**Ce que le joueur fait (en pause ou en direct) :**
- **Acheter ou vendre** un produit disponible à la date courante, avec des frais de courtage simples et visibles.
- **Mettre en place un versement automatique** (« chaque mois, je verse 100 F sur mon livret ou sur mon PEA »). C'est très important pédagogiquement, pour montrer la force des intérêts composés et de l'investissement programmé.
- **Consulter son patrimoine** : un seul écran, un camembert de répartition et une courbe de la valeur totale.
- **Lire le journal** : une manchette d'époque s'affiche lors des grands événements, par exemple « Lundi noir à Wall Street : la Bourse de Paris dévisse » (octobre 1987).

**Les interruptions, qui sont le cœur du plaisir :**
- **Événements de marché historiques** : le jeu se met en pause tout seul, affiche une manchette de journal et une explication très courte (2 ou 3 phrases maximum), puis demande « Que faites-vous ? » avec 2 ou 3 choix (vendre tout, ne rien faire, renforcer). On voit les conséquences dans les mois qui suivent.
- **Événements de vie aléatoires**, environ 1 à 3 par an de jeu :
  - négatifs : accident de voiture (−X), panne de chaudière, perte d'emploi (quelques mois sans salaire), divorce ;
  - positifs : prime, augmentation, héritage d'une grand-tante, gain au tiercé ;
  - de vie : naissance d'un enfant (les dépenses augmentent), mariage, déménagement.
  Ces événements **forcent des arbitrages**. Si je n'ai pas de quoi payer la réparation, je dois vendre des actions, peut-être au pire moment. C'est la leçon de l'**épargne de précaution**, apprise par la douleur et sans la moindre ligne de cours.
- **Nouveaux produits disponibles** : une petite notification annonce « Nouveau : le PEA vient d'être créé (1992) ! Il permet... ». Le jeu débloque des choses au fil du temps, ce qui ajoute une récompense de découverte.

### 2.3 Quand la partie s'arrête

La partie s'arrête dans l'un de ces trois cas :
1. **la fin de la durée prévue** (15 ans par défaut ; 10 ou 25 ans en option) ;
2. **l'objectif atteint plus tôt** : le joueur peut alors arrêter et voir son bilan, ou continuer en « partie libre » ;
3. **la faillite** : le compte courant est négatif au-delà d'un découvert toléré pendant plusieurs mois. On affiche alors un bilan avec humour (« Vous finissez chez votre belle-mère »), sans écran de « Game Over » brutal.

### 2.4 Comment on gagne et comment on évalue sa partie

L'écran de fin est **le moment où l'on apprend le plus**. Il doit être soigné.

- **Le chiffre principal** : le patrimoine final **en euros d'aujourd'hui** (corrigé de l'inflation), pour que ce soit parlant.
- **La comparaison avec 3 personnages témoins**, qui ont reçu le même salaire et subi les mêmes événements de vie mais ont fait des choix différents :
  - **Tonton Matelas** : il a tout gardé en billets sous le matelas ;
  - **Tata Livret** : elle a tout mis sur le livret A ;
  - **Cousin Indice** : il a investi chaque mois la même somme sur le marché actions français, sans jamais rien vendre.
  → Le joueur voit immédiatement s'il a fait mieux ou moins bien que ces stratégies simples. C'est **la** leçon du jeu.
- **L'objectif de vie** : atteint ou non, avec une jauge.
- **Une note de 1 à 5 étoiles**, et surtout **un titre humoristique** qui résume le style du joueur : « Fourmi du Livret A », « Trader du dimanche », « Roi de la panique », « Rentier de la Côte d'Azur », « Pigeon de la bulle Internet ».
- **Les 3 leçons de ta partie** : trois phrases générées à partir de ce que le joueur a réellement fait. Par exemple : « Vous avez vendu en mars 2009, au plus bas. Si vous aviez attendu 2 ans, vous auriez récupéré +60 %. »
- **Le bouton « Rejouer la même période autrement »**, mis en évidence. C'est ce qui donne envie de revenir.

---

## 3. Périmètre : V1 indispensable ou plus tard

**Règle d'or de la V1 : une partie complète, jouable en 15 à 30 minutes, qui donne envie d'en refaire une autre.** Tout ce qui ne sert pas cela attend.

### V1 : indispensable

| Domaine | Contenu V1 |
|---|---|
| **Lancement** | Un fichier à double-cliquer sous Windows, sans installation et hors ligne. |
| **Périodes** | Les 3 périodes majeures, entièrement scénarisées avec des données réalistes. Le choix d'une année libre est accepté, mais avec moins d'événements scénarisés. Si c'est trop lourd, la V1 se limite aux 3 périodes et l'année libre passe en V2. |
| **Personnage** | 3 profils prédéfinis, un salaire et des dépenses fixes calibrés par époque, une évolution simple du salaire. |
| **Objectifs** | 3 objectifs : maison, retraite, battre l'inflation. |
| **Temps** | Une frise avec pause et 3 vitesses, 1 tour par mois, une partie de 15 ans par défaut. |
| **Produits** | Une sélection **très courte**, de 5 à 7 produits au maximum, uniquement s'ils existent à l'époque : compte courant, livret A, une obligation ou un emprunt d'État, une SICAV ou un fonds actions France, 3 à 5 grandes actions françaises emblématiques de la période, puis le PEA et un ETF CAC 40 quand ils apparaissent. **Liste exacte à fixer avec le banquier et le boursier.** |
| **Fiscalité** | Ultra simplifiée : un seul taux forfaitaire par type de produit et par époque, et l'avantage du PEA visible au moment de la vente. Pas de déclaration de revenus. |
| **Événements de marché** | 5 à 8 événements historiques majeurs par période, avec une manchette, une explication courte et un choix. |
| **Événements de vie** | Une dizaine d'événements aléatoires (positifs, négatifs, de vie), à fréquence modérée. |
| **Écrans** | Seulement 4 : accueil et choix de partie, jeu (frise et tableau de bord), achat et vente, bilan de fin. |
| **Bilan** | Patrimoine réel, comparaison avec les 3 témoins, titre humoristique, 3 leçons, bouton « Rejouer ». |
| **Pédagogie** | Une bulle « C'est quoi ? » de 2 lignes sur chaque produit et chaque notion (inflation, dividende, frais, diversification). Pas de cours magistral. |
| **Sauvegarde** | Une seule sauvegarde automatique locale, pour reprendre une partie interrompue. |

### Plus tard : V2 et au-delà

- Choix libre de n'importe quelle année avec une couverture complète des événements.
- Davantage d'actions et de secteurs, et des actions étrangères ou de grands indices mondiaux.
- Assurance-vie, PER, immobilier locatif, SCPI, or physique (le Napoléon, très français !), emprunt immobilier avec simulation de crédit.
- Produits avancés : ordres à cours limité, vente à découvert, SRD, options, warrants, crypto-actifs (à partir de 2009).
- Fiscalité réaliste (barème, prélèvement forfaitaire unique, abattements).
- Éditeur de personnage complet, famille détaillée, carrière avec choix de métier.
- Succès et badges permanents, classement entre amis, défis du jour (« Survivez à 2008 avec plus de 10 000 € »).
- Point de vue d'autres pays : investisseur américain, allemand…
- Mode multijoueur ou mode classe pour les enseignants.
- Sons et musique d'époque plus riches, et des « publicités » rétro.

**Ce que je refuse, même plus tard, s'il n'y a pas de plaisir ou d'apprentissage clair** : les graphiques en chandeliers, les indicateurs techniques et les tableaux de 50 colonnes.

---

## 4. Ce qui rendra le jeu amusant

1. **La tension**
   - Voir son portefeuille fondre pendant un krach, avec le temps qui continue de défiler : « Je vends ou je tiens ? »
   - Le coup dur au mauvais moment : la voiture tombe en panne juste pendant le krach, et il faut vendre au plus bas.
   - L'objectif de vie avec une échéance : « Il me reste 3 ans pour réunir mon apport. »
2. **Les surprises**
   - Les événements de vie aléatoires : deux parties sur la même période ne sont jamais identiques.
   - Les déblocages de produits au fil du temps (« Le PEA est arrivé ! »).
   - Le joueur qui connaît l'histoire sait que 1987 arrive… mais pas l'accident de voiture de mars.
3. **Les récompenses**
   - Voir les intérêts composés faire « boule de neige » sur la courbe de patrimoine.
   - Battre Tonton Matelas, Tata Livret et Cousin Indice.
   - Débloquer des titres humoristiques et avoir envie de les collectionner.
   - Le petit « ding » du premier dividende reçu.
4. **L'humour**
   - Des personnages témoins caricaturaux et attachants.
   - Des événements de vie décalés (« Votre beau-frère vous propose d'investir dans son élevage d'escargots »). C'est une bonne occasion d'enseigner l'arnaque et le placement miracle.
   - Des titres de fin qui piquent gentiment.
   - Le ton : bienveillant, jamais moralisateur.
5. **L'ambiance d'époque**
   - Des manchettes de journaux pastiches, sans copier de vrais titres de presse.
   - Une **monnaie d'époque** : anciens francs avant 1960, nouveaux francs, puis euros en 2002, avec une conversion affichée. Le passage à l'euro doit être un vrai moment du jeu.
   - Des prix du quotidien qui évoluent (une baguette, un plein d'essence), pour **ressentir** l'inflation.
   - Une palette de couleurs et une typographie qui changent légèrement selon la décennie, si c'est simple à faire.

---

## 5. Mes questions aux experts

### Au banquier (docs/01_enveloppes_france.md)

1. Pour chaque période proposée, **quels produits et enveloppes étaient réellement accessibles à un particulier** ? Donnez les dates exactes de création : livret A, livret d'épargne populaire, SICAV, compte-titres, PEA, assurance-vie, LDD… Je veux une liste **courte**, de 5 à 7 produits par période, pas un catalogue.
2. Quels étaient les **taux du livret A et l'inflation**, année par année, de 1950 à aujourd'hui ? J'en ai besoin pour Tata Livret et pour le calcul en euros constants.
3. Quel **salaire et quelles dépenses types** (loyer, alimentation, voiture) pour nos 3 profils, à chaque époque ? Des ordres de grandeur suffisent.
4. Quelle **fiscalité ultra simplifiée** proposez-vous (un taux unique par produit et par époque) qui reste juste sur le fond, notamment pour montrer l'intérêt du PEA ?
5. Comment présenter **les frais** (droits de garde, frais de courtage, frais d'entrée des SICAV) simplement, pour que le joueur comprenne qu'ils comptent sur la durée ?
6. Quels **événements de vie** financièrement réalistes, avec quel coût typique selon l'époque, nous conseillez-vous ? Et comment gérer simplement le découvert ou un petit crédit à la consommation ?

### Au boursier (docs/02_rouages_bourse.md)

1. **Mes 3 périodes majeures** (1978-1995, 1995-2012, 2008-aujourd'hui) sont-elles les bonnes ? Proposeriez-vous mieux, par exemple en ajoutant ou en remplaçant une période des Trente Glorieuses ?
2. Pour chaque période, quels sont **les 5 à 8 événements de marché incontournables**, avec la date, l'ampleur de la baisse ou de la hausse, la durée de la récupération et **la leçon** à en tirer en une phrase ?
3. Quelles **données de prix** peut-on utiliser ? Faut-il un indice reconstitué avant le CAC 40 (avant 1987), 3 à 5 actions emblématiques par période, des données mensuelles ? Si les données réelles sont introuvables ou lourdes, comment fabriquer des courbes **plausibles et fidèles aux grands mouvements** ?
4. Quelles **notions boursières minimales** le joueur doit-il avoir comprises à la fin d'une partie ? Idéalement 5 à 8 notions, classées par importance.
5. Quel **mécanisme d'ordre** proposez-vous pour la V1 (ordre au marché au prix du mois ?) qui soit simple sans être faux ?
6. Comment calculer de façon juste et simple la stratégie de **Cousin Indice** (investissement mensuel, dividendes réinvestis ou non) pour qu'elle serve de référence honnête ?

### Au designer UX

1. Comment faire tenir **la frise du temps, le tableau de bord du patrimoine et les actions possibles sur un seul écran principal** lisible, sans submerger un débutant ?
2. Comment concevoir l'**interruption d'un événement** (marché ou vie) pour qu'elle soit excitante et claire, en 10 secondes de lecture au maximum ?
3. Quel **parcours d'accueil** (choix de la période, du profil et de l'objectif) proposez-vous pour lancer une partie en moins d'une minute, avec un tutoriel intégré au jeu plutôt qu'un pavé de texte ?
4. Comment rendre l'**écran de bilan** gratifiant et pédagogique (comparaison avec les 3 témoins, titre, leçons) et donner envie de cliquer sur « Rejouer » ?
5. Comment faire **ressentir l'époque** (couleurs, typographie, manchettes, monnaie) sans multiplier le travail du développeur ?
6. Comment afficher les montants en **francs puis en euros**, et la notion d'**euros constants**, sans perdre le joueur ?

---

## Contraintes transmises au développeur (pour mémoire)

- Lancement par **double-clic sous Windows**, **sans installation**, **hors ligne**, par exemple une page HTML autonome qui s'ouvre dans le navigateur. Le choix technique revient au développeur, mais cette contrainte est non négociable.
- Les données (prix, taux, inflation, événements) sont **séparées du code** dans des fichiers simples, pour pouvoir les corriger ou en ajouter sans tout réécrire.
- Une seule sauvegarde locale automatique.
