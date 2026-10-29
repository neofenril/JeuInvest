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

## À faire plus tard
- APK de publication (keystore de release) et version iOS.
- Questionnaire de profil de risque au démarrage (idée de l'utilisateur mise de côté le 2026-10-27). D'ici là, le banquier adapte ses propositions à la seule situation de vie.

## Règles
- Seuls les produits disponibles à la date jouée sont proposés.
- Les données chiffrées incertaines portent un niveau de certitude (A vérifié, B probable, C reconstitué).
- Contenu pédagogique : jamais de conseil d'investissement personnalisé.
