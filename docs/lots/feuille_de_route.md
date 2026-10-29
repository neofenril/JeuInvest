# Feuille de route technique : game design V3 (P1-P6, P9, P10)

> Chef de projet, 2026-10-29. Provisoire : à recaler quand `docs/15_spec_game_design_v3.md` (game designer) sera prête.
> Décisions du joueur (docs/10, 29/10) : P1, P2, P3, P4, P5, P6, P9, P10 retenues ; réserves du client appliquées par défaut (docs/14 §6) : humeur de Sylvie en 3 états, 8 à 10 cartes par démo, Jean-Mi finit derrière Tata Livret, P5 et P10 allégés.
> Équipe à partir du lot 02 : dev-logique, dev-interface (écrans), **dev-ville** (rue, personnages, animations ; recrutement proposé, voir `recrutement/dev-ville.md`), testeur.

## 1. Lots

| Lot | Contenu | dev-logique | dev-interface (écrans) | dev-ville (rue) | Dépend de | Sortie joueur |
|---|---|---|---|---|---|---|
| **01** | Socle technique (`lot_01.md`) | worktrees, tests stricts, `StrategieTest`, test de l'interface | découpage de `principal.gd`, raccourcis de test retirés | — (pas encore recruté) | rien | — |
| **02** | **P4 Le mois utile** + préparatifs | « flux du mois » dans le résultat de `mois_passe` (intérêts, dividendes, frais, par produit) ; avance rapide `Partie.avancer_jusqu_au_prochain_arret()` (×6, s'arrête **au** mois de toute modale ou carte, jamais avant, A5) ; **migration douce** des sauvegardes (champ absent → valeur par défaut, plus de rupture de format à chaque lot) ; version 0.3 + export | bouton « Jusqu'au prochain courrier » (la barre haute est pleine : place à trancher par l'UX) ; notifications empilées en accéléré ; **découpage de `modales.gd`** (T9) avant les cartes de P1/P2 ; scénarios de capture sur `StrategieTest` (T13) | pièces banque → maison (« +312 F »), « ding » des dividendes en juin, frais en cuivre ; reprise de la famille de captures `ville.gd` | §P4 de docs/15 (seuils d'affichage, vitesse), UX (bouton, pièces) | **oui** : exe + APK 0.3 (premier ressenti du joueur sur la V3) |
| **03** | **P2 Dilemmes du foyer** + humeur de Sylvie + traces P10 des dilemmes | `data/dilemmes.json` (8-10 tirés sur 20-30), catégorie « micro-décision » dans la cadence (jamais le même mois qu'une autre interruption ni deux mois de suite), humeur à 3 états et sa conséquence en argent, coût d'opportunité calculé (affiché après le choix, au conditionnel), escargots toujours perdants, historique | carte de dilemme (un toucher, ≤ 4 s), visage de Sylvie (3 humeurs), entrée d'historique, coût d'opportunité | la carte sort de la maison ; objets achetés visibles (magnétoscope, antenne, Minitel…) | §P2 de docs/15 ; **banquier** : prix d'époque de chaque dilemme (certitude A/B/C) ; UX : carte, visages, objets | oui (avec 04 si proche) |
| **04** | **P1 Projets du foyer** + traces P10 des projets | `data/projets.json` (choix en 01/1984 et après la naissance, un seul projet en cours, deux par démo), règle de la jauge (quelle épargne compte : à trancher dans la spec), échéance (réalisé / reporté / abandonné, effet sur l'humeur), rappel de la date dans les fiches du banquier (textes) | carte de choix du projet, jauge sur la maison, ligne « vous en aurez besoin dans N mois » dans la fiche | réalisation animée (la R5 se gare), traces durables | lot 03 (humeur) ; §P1 de docs/15 ; **banquier** : prix (R5 1986, voyage 1987, apport T3 1988) et textes de rappel (≤ 60 mots, jamais où placer) | **oui** : 0.4 (boucle court + moyen terme) |
| **05** | **P3 Le quartier** + **P9 La rue a de l'humour** | témoins Tonton Matelas (liquide) et Jean-Mi (trajectoire scriptée sur vrais prix, levier), classement de la rue (4 lignes), calendrier des bulles et du kiosque (`data/bulles.json`, `kiosque.json`), bulles réactives à l'état | classement de la rue (Tata Livret reste le comparateur permanent), lecture des bulles dans l'historique si besoin | voisins dessinés qui passent avec une bulle (≈ 1 par trimestre), Porsche 944 puis « À VENDRE », concierge, Sylvie à la fenêtre, M. Lefranc qui fume, jumeaux qui grandissent, kiosque | §P3 et §P9 de docs/15 ; **boursier + banquier** : trajectoire de Jean-Mi (certitude B, il finit derrière Tata Livret) ; **boursier** : titres d'époque datés ; UX : personnages | oui |
| **06** | **P6 Lundi noir, en direct** + « Le krach, un an après » | séries quotidiennes 19 → 23/10/1987 (Gazette), simulation contrefactuelle des 3 choix sur 12 mois avec l'argent du joueur (copie de l'état), carte d'octobre 1988 dans la cadence | carte « un an après » (3 colonnes, au conditionnel, sans jugement) | séquence de 15 s : écran de la Gazette qui chute jour après jour, file devant la banque, téléphone de la maison, Jean-Mi qui court (si lot 05 fait), sans compte à rebours | §P6 de docs/15 ; **boursier** : cours quotidiens (certitude) ; UX : découpage de la séquence | oui |
| **07** | **P5 Score de la rue (allégé)** + équilibrage | rang dans la rue + titre d'époque (règles de la spec, jamais flatteur pour la spéculation), record personnel dans un fichier à part (`user://records.sav`), « Rejouer pour battre Jean-Mi » ; mesure de la durée d'une partie (**≤ 20 min à ×1**, sinon retirer des cartes) et du nombre d'interruptions | écran de fin refait (rang, titre, record) | — (ou finitions de la rue) | lots 03-06 (humeur, projets, voisins, sang-froid) ; §P5 de docs/15 ; client : liste des titres | **oui** : 1.0 de la démo V3 |

Ordre retenu : celui du client (docs/14 §6.4 : P4 d'abord, puis P2, P1, P3 + P9, P6), P5 en dernier car il agrège tous les autres. P10 n'est pas un lot : ses traces arrivent avec P2 et P1 (réserve du client).

## 2. Ce qui peut démarrer avant la spec (docs/15)

- **Tout de suite** : lot 01 entier.
- **Côté développement, sans attendre la spec** : flux du mois (donnée nécessaire à P4 quelle que soit la mise en scène) ; moteur de l'avance rapide (arrêt au mois de la prochaine interruption, testé contre A5) ; migration douce des sauvegardes ; découpage de `modales.gd` ; scénarios de capture sur `StrategieTest`. Le lot 02 peut donc être lancé avec la seule §P4 de la spec, voire sur docs/14 + réserves du client si la spec tarde.
- **Demandes de contenu à lancer dès maintenant (par le coordinateur)** :
  - boursier : cours quotidiens du 19 au 23/10/1987 (P6) ; trajectoire réaliste de Jean-Mi (titres, levier, dates, certitude) avec le banquier pour le règlement mensuel (P3) ; titres d'époque datés pour le kiosque 1984-1988 (P9) ;
  - banquier : prix d'époque des exemples de docs/14 (R5 neuve 1986, voyage en Italie 1987, apport d'un T3 1988, magnétoscope VHS, camping / Club Med, Minitel), avec certitude (P1, P2) ;
  - UX : place du bouton « Jusqu'au prochain courrier » et dessin des pièces du mois (P4) ; puis carte de dilemme, 3 visages de Sylvie, jauge de projet (P1, P2).
- **À attendre** : règles de l'humeur, cadence exacte des cartes, règle de la jauge de projet, script des bulles, règles du titre de fin.

## 3. Risques et points techniques

| Risque | Parade |
|---|---|
| `etat_partie.gd` (1 318 l.) touché par P1, P2, P3, P6 (cadence, état, calendrier) | Un seul développeur logique, lots successifs ; découpage (`vie.gd`, `cadence.gd`, `historique.gd`) au lot 03 si la cadence grossit |
| `modales.gd` (1 453 l.) : toutes les nouvelles cartes | Découpage au lot 02, avant P2/P1 |
| Budget d'interruptions et durée (A45 : 15-20 min) | Test automatique de la cadence étendu à chaque lot ; mesure de durée au lot 07 (≤ 20 min à ×1) |
| Garde-fous pédagogiques (docs/14 §2 et §6.3 : pas de timing récompensé, avance rapide jamais avant un événement, Jean-Mi jamais enviable) | Un test par garde-fou dans le lot qui l'introduit (critère d'acceptation explicite) |
| Sauvegardes du joueur cassées à chaque lot | Migration douce dès le lot 02 |
| APK jamais essayé sur téléphone (T2) | Liste de contrôle à donner au joueur avec l'export 0.3 |
| Trois branches par lot : plus de passages du testeur et de fusions | Fichiers strictement disjoints, interfaces écrites dans le plan, famille de captures par développeur |
