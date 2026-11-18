# JeuClaude

Jeu ludique d'apprentissage de la bourse, du point de vue d'un investisseur particulier français, de 1950 à aujourd'hui.
Objectifs, dans cet ordre : 1) s'amuser ; 2) apprendre l'investissement boursier.
Cibles : PC (Windows) et mobile (Android, iOS plus tard). Langue du jeu et des documents : français.

## Équipe (agents dans .claude/agents/)
- `client` : porteur de la vision, arbitre le périmètre et valide.
- `banquier` : enveloppes, produits, fiscalité et lois françaises depuis 1950.
- `boursier` : rouages de la bourse, événements historiques, données de marché.
- `ux-designer` : interface, direction artistique, animations, ergonomie PC et mobile.
- `game-designer` : plaisir de jeu, rythme, mécaniques, engagement (ajouté le 2026-10-28 : « on s'ennuie un peu »).
- Équipe technique (réorganisée le 2026-10-28 à la demande de l'utilisateur, remplace l'ancien agent `developpeur`) :
  - `chef-de-projet` : **seul interlocuteur des développeurs** ; reçoit les demandes (joueur, client, game designer, UX, experts), arbitre, découpe en lots (`docs/lots/lot_NN.md`), répartit, contrôle.
  - `dev-logique` : simulation, données, état, sauvegarde, tests, exports.
  - `dev-interface` : écrans, HUD, modales, fenêtres, `principal.gd`, captures (et la ville pendant le lot 01 seulement).
  - `dev-ville` (recruté par le chef de projet, validé par l'utilisateur le 2026-10-29, actif à partir du lot 02) : rue, bâtiments, personnages, véhicules, séquences animées, shaders.
  - `testeur` (ajouté le 2026-10-29 à la demande de l'utilisateur) : vérifie chaque branche de développeur avant tout push ; verdict OK / KO dans `docs/lots/lot_NN_recette.md` ; rend compte au chef de projet ; ne corrige jamais le code.
  - **Circuit d'un lot** : (1) le chef de projet écrit `docs/lots/lot_NN.md` ; (2) le coordinateur crée une branche par développeur depuis `main` (`lot/NN-logique`, `lot/NN-interface`) ; (3) le développeur travaille et **commite en local sur sa branche, sans push** ; (4) le testeur vérifie la branche → KO : retour au chef de projet, corrections, nouveau passage ; (5) **OK du testeur → push de la branche** sur GitHub ; (6) le chef de projet valide → fusion dans `main` (`--no-ff`), tests relancés sur `main`, push de `main`. Aucun push de branche de développeur sans OK du testeur.
  - **Recette allégée (décision du joueur, 2026-11-17)** : la série de captures complète (capture_interface.ps1 -Serie, capture_ville.ps1 -Serie) n'est lancée qu'avant chaque export ; entre deux exports, le testeur ne rejoue que les étapes touchées. Recette courte (tests + étapes ciblées + périmètre) quand le changement est petit. Les formats de test restent PC 1920×1080 et téléphones 1440×648 / 1280×720.
  - Les développeurs n'ont aucun contact avec le client ni les autres agents. Un agent ne pouvant pas en lancer un autre, le coordinateur (session principale) lance les développeurs selon le plan du chef de projet, lui transmet leurs comptes rendus, puis commite et pousse le lot validé.
  - Jamais deux développeurs sur le même fichier en même temps (carte de propriété des fichiers tenue par le chef de projet) ; Git permet désormais de revenir en arrière, mais pas de fusionner proprement deux modifications simultanées d'un même fichier sans branches.
  - `docs/connaissances/developpeur.md` = socle technique commun aux deux développeurs.

Chaque agent a une base de connaissances dans `docs/connaissances/<agent>.md` : il la lit au début de chaque mission et la met à jour à la fin (faits vérifiés, décisions, erreurs à ne pas refaire).

## Documents (docs/)
- `00_vision_client.md` : vision initiale du client.
- `01_enveloppes_france.md` : recherche du banquier (gros fichier : lire par sections).
- `02_rouages_bourse.md` : recherche du boursier, données historiques (gros fichier : lire par sections).
- `03_cahier_des_charges.md` : **référence produit** ; prime sur 00, 01, 02, 04 en cas de contradiction.
- `04_ux_design.md` : design UX de la V1 web (gros fichier : lire par sections).
- `05_architecture.md` : architecture de la V1 web.
- `09_direction_artistique_godot.md` : direction artistique Godot (ville « Ma rue »), prime sur 04 pour le visuel.
- `10_retours_joueur.md` : **retours verbatim du joueur réel**, à lire par tous ; ils priment sur les avis des agents.
- `connaissances/` : bases de connaissances des agents.
- `sources/` : documents de référence fournis par l'utilisateur (prioritaires sur la recherche web).

## Technique
- **Moteur : Godot 4.7.2 (GDScript), projet dans `godot/`.** Choisi pour un rendu plus soigné et l'export PC + mobile.
- Exécutable : `outils/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe` (version console, utilisable en ligne de commande, ex. `--headless`).
- `jeu/` : V1 web (HTML/JS) archivée. Sa logique (`jeu/js/moteur.js`, `marche.js`, `score.js`) et ses données (`jeu/data/`) servent de référence pour le portage, mais ne sont plus développées.
- Machine : Windows 11, pas de Node.js, pas de Python fonctionnel.
- **Git** (depuis le 2026-10-29) : Git portable `outils/git/cmd/git.exe` (pas dans le PATH), dépôt `https://github.com/neofenril/JeuInvest.git`, branche `main`, identité locale neofenril. Connexion GitHub mémorisée par Git Credential Manager (l'utilisateur s'est connecté lui-même). `.gitignore` exclut `outils/`, `export/`, `godot/.godot/`, `godot/captures/`.
  - Branches de lot par développeur, commits locaux, push seulement après OK du testeur, fusion dans `main` après validation du chef de projet (voir « Circuit d'un lot »). Messages de commit en français. Tests au vert avant tout commit.
  - Jamais de `push --force`, de réécriture d'historique ni de suppression de branche distante sans accord explicite de l'utilisateur.
  - Ne jamais commiter de secret (keystore de release, mots de passe, jetons).

## Décisions de l'utilisateur (joueur réel)
- Orientation **paysage uniquement**, sur PC comme sur mobile.
- L'écran principal est **une ville** : la maison du personnage (vie, budget), la **banque** (le banquier appelle, avec une animation partant du bâtiment), le **bâtiment média** (une animation pour chaque news). Les chiffres s'affichent par-dessus ou s'ouvrent depuis les bâtiments.
- Graphisme bien plus poussé que la V1 web ; en attendant d'éventuelles illustrations, la ville est dessinée en vectoriel dans Godot.

## État du projet (2026-10-27)
- **Démo V2 livrée** dans `godot/` : janvier 1984 → décembre 1988, Gérard (technicien, en couple non marié avec Sylvie), M. Lefranc présente 9 produits un par un (carte à 5 critères, carnet 3×3), pédagogie des frais (pièces cuivre, 3 piles, relevé de décembre), naissance scriptée 04/1985 (jumeaux 1 fois sur 4), héritage de la tante Odette 1988, comparaison permanente « vs tout au Livret A ».
- **Sauvegarde automatique** (`user://partie_en_cours.sav`, binaire, format 2 : les sauvegardes du format 1 sont ignorées) : « Continuer » / « Nouvelle partie » sur l'écran titre.
- Retours du joueur sur la démo V2 traités (2026-10-27) : **historique des pop-ups** (bouton HISTORIQUE au bout de la frise, touche H, menu, bâtiment média, carnet de la banque ; filtres maison / banque / média ; relecture en lecture seule ; sauvegardé) ; **héritage à un seul pot** (60 000 F d'assurance-vie ; la carte montre, en hypothèse barrée, les 32 500 F nets qu'aurait laissés une succession ; plus de D08 bis) ; un même événement de vie aléatoire ne se répète pas en moins de 24 mois ; **versements automatiques mensuels** (docs/11 §8 : Livret A, assurance-vie, SICAV, PEL obligatoire ; bouton CHAQUE MOIS des fiches). Taux du PEL écrit partout « 6,30 % + prime d'État ≈ 8,25 % » ; « DANS 20 ANS » ne chevauche plus la 1re pile.
- Tests : `godot/outils/tests.ps1` (66 logique + 100 démo + 8 partie, tous au vert).
- Écart validé par le coordinateur : la présentation du PEL a lieu au plus tard en juillet 1984 (après, un PEL neuf rapportait moins que le Livret A).
- Restes P1/P2 de docs/13 : jauge de l'avertissement de frais, tuile animée qui sort de la banque, piles dans le relevé de décembre, sons ; VP-D (option de 11 §8). Non vérifié sur un vrai téléphone : défilement tactile de l'historique.
- Prochaine étape : nouveaux retours du joueur.

## État du projet
- Export configuré (2026-10-27) : `Exporter_Windows.bat` → `export\windows\JeuClaude.exe` (fichier unique, ~105 Mo, vérifié : lancement, données, sauvegarde) ; `Exporter_Android.bat` → `export\android\JeuClaude.apk` (debug, ~55 Mo, export réussi, pas encore essayé sur un téléphone). Outils : modèles d'export dans `%APPDATA%\Godot\export_templates\4.7.2.stable\`, `outils\jdk-17`, `outils\android-sdk`.

## État du projet (2026-11-07) : version 0.3 « tout en pixel »
- Fusionnés dans `main` (7a98012) : lot 01 (technique), PX0/PX1/PX2 (rue de briques pixel art sur grille 960×540, rue large avec caméra qui défile, interface pixel, téléphone de référence 2400×1080 à 400 dpi), lot 02-L (flux du mois, saut « jusqu'au prochain courrier », non-lus, cadence V3, sauvegarde format 3), F1-L. Tests : 495 vérifications au vert (`godot/outils/tests.ps1`).
- Exports 0.3 faits le 2026-11-07 : `export\windows\JeuClaude.exe` (110 Mo) et `export\android\JeuClaude.apk` (58 Mo, debug, jamais essayé sur un vrai téléphone).
- Suite : lot 02-I/02-V (bouton COURRIER, badge non-lus, pièces ; docs/17), puis 03 à 07 selon `docs/lots/feuille_de_route.md`. Sauvegarde manuelle à 3 emplacements : planifiée, NON lancée (`docs/lots/lot_sauvegarde.md`, vagues 6-7). Contenus banquier/boursier V3 : `docs/18`, `docs/19`.

## État du projet (2026-11-09) : version 0.4
- Fusionné dans main (e125a5f) : lot 02 complet (02-I bouton COURRIER + badge des non-lus + saut animé + étiquettes sans chevauchement ; 02-V pièces du mois, retour de caméra, arbre en fondu, vitrine PX0 retirée). 551 vérifications au vert. Exports 0.4 faits : `export\windows\JeuClaude.exe` (110 Mo) et `export\android\JeuClaude.apk` (58 Mo, debug).
- Suite : 03-V (reports : pièces sur l'enseigne, montants longs, seuil test_rue, GrillePixel) et 03-L (dividendes, avoir fiscal) selon `docs/lots/feuille_de_route.md` §2.6.

## État du projet (2026-11-14) : version 0.5 « jouable »
- Fusionné dans main (a608eb2) : lots 02 à 05 : dividendes (une notification par mois, relevé en 4 cas), cartes de dilemme du foyer + humeur de Sylvie, projets (P1/P2) avec vente automatique (règle à redéfinir plus tard, docs/lots/feuille_de_route.md §2.11), Jean-Mi et classement de la rue (bloc LA RUE dans « Mon argent »), Lundi noir (tableau de 7 jours), « Le krach, un an après » (3 barres), écran de fin 4 barres. 1 105 vérifications (`tests.ps1 -Recette -Delai 700`).
- Exports 0.5 faits le 2026-11-14 : `export\windows\JeuClaude.exe` (110 Mo) et `export\android\JeuClaude.apk` (59 Mo, debug). Objectif du joueur : juger si ces fonctionnalités rendent le jeu plus amusant AVANT de peaufiner (animations, caméra, humeur visuelle).
- Décisions du joueur : record = meilleur écart final face à Tata Livret ; pas de sons pour l'instant ; signature de l'exe plus tard (Smart App Control bloque les exe neufs non signés) ; modèles des agents choisis par le joueur (chef-de-projet Opus, certains autres Opus).
- Suite : 07-L (titres/record, branche lot/07-logique, OK du testeur à obtenir) et 07-I (écran de fin d'époque, titres, collection, après le verdict du joueur), sauvegarde manuelle (non lancée, docs/lots/lot_sauvegarde.md), peaufinage reporté.

## État du projet (2026-11-15) : version 0.5.1
- Correctifs demandés par le joueur après essai de la 0.5, fusionnés dans main (2c9b8bd) : le bouton COURRIER avance réellement jusqu'au prochain événement (0,1 s par mois, mois non animés) avec pop-up de confirmation (case « Ne plus afficher », préférence locale) ; la conclusion des cartes et projets dure ~1 s. 1 126 vérifications. Exports 0.5.1 : `export\windows\JeuClaude.exe` et `export\android\JeuClaude.apk` (15/11).
- Branche `lot/07-logique` (titres, record face à Tata Livret) : développée, fusionnée avec main, recette du testeur à passer ; interface 07-I et sauvegarde manuelle après le verdict du joueur.

## État du projet (2026-11-16) : version 0.6 « titres et record »
- Verdict du joueur sur la 0.5.1 : projets « pas mal », pauses non trop nombreuses, vitesse du saut bonne. Fusionnés dans main (ad180f3) : 07-L (9 titres, record = meilleur écart final face à Tata Livret, `user://records.sav`, jamais écrit en test/capture : `Partie.chemin_records` isolé) et 07-I (écran de fin d'époque, rangée « Meilleur résultat » + bouton TITRES à l'écran titre, collection 3×3). 1 334 vérifications (`tests.ps1 -Recette -Delai 700`, à lancer sans autre Godot en parallèle). Exports 0.6 : `export\windows\JeuClaude.exe` et `export\android\JeuClaude.apk` (16/11).
- Reste : sauvegarde manuelle (non lancée), peaufinage reporté (animations, caméra, humeur visuelle…), signature de l'exe, APK de release, iOS, sons (pas pour l'instant).

## État du projet (2026-11-17) : version 0.6.1
- Correctif de l'écran de fin sur smartphone (verdict du joueur sur la 0.6), fusionné dans main (d195290) : récap en tête, une seule zone défilante, polices du récap ≥ 24 px au téléphone, PC inchangé. 1 334 vérifications. Exports 0.6.1 : `export\windows\JeuClaude.exe` et `export\android\JeuClaude.apk` (17/11). Le joueur fait essayer la 0.6 par d'autres personnes et transmettra leurs retours.
- Série de captures complète non rejouée pour ce correctif (changement d'un seul écran, vérifié par les étapes ciblées).

## État du projet (2026-11-18) : version 0.6.2
- Pop-up de début de partie (retour du joueur, backlog n° 6), fusionnée dans main (facc64c) : « JANVIER 1984 », 4 blocs (qui vous êtes, ce qui vous attend, objectif, comment jouer ; texte docs/32, données `godot/data/intro.json`), COMMENCER, temps figé, à chaque nouvelle partie et à « Rejouer autrement », jamais à la reprise ; entrée d'historique. 1 379 vérifications. Exports 0.6.2 (18/11). Mineures : titre d'historique en minuscule initiale (« janvier 1984 »), intertitres collés en relecture.
- Backlog du joueur (6 idées : trophées, profils d'investisseur, bâtiment « s'amuser », décor par décennie, création de partie, pop-up de début) : `docs/lots/backlog_retours_0_6.md`. Extension de la plage des années : plan `docs/lots/plan_extension_annees.md` + contenus experts `docs/33` à `docs/36` ; décisions du joueur attendues (durée de partie, 2e chapitre, ordre, casino/tabac, profil célibataire, étoiles, PER, révision du cahier des charges).

## À faire plus tard
- APK de publication (keystore de release) et version iOS.
- Questionnaire de profil de risque au démarrage (idée de l'utilisateur mise de côté le 2026-10-27). D'ici là, le banquier adapte ses propositions à la seule situation de vie.

## Règles
- Seuls les produits disponibles à la date jouée sont proposés.
- Les données chiffrées incertaines portent un niveau de certitude (A vérifié, B probable, C reconstitué).
- Contenu pédagogique : jamais de conseil d'investissement personnalisé.
