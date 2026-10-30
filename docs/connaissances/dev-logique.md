# Base de connaissances de dev-logique

> Lire d'abord `CLAUDE.md` et le **socle commun `docs/connaissances/developpeur.md`** (architecture, décisions, pièges Godot, commandes, export). Ici : seulement ce qui est propre à dev-logique. Concise.
> Créée le 2026-10-28 par le chef de projet (prise de poste, aucun lot réalisé).

## Périmètre
Simulation, calculs financiers, données, état de partie, sauvegarde, tests automatiques, exports. Consignes uniquement via `docs/lots/lot_NN.md` ; ne modifier que les fichiers attribués par le lot.

## Fichiers possédés par défaut (carte complète : `chef-de-projet.md` §1)
- `godot/data/*.json` (dont les textes du banquier dans `banque.json`)
- `godot/scripts/logique/*.gd`, `godot/scripts/partie.gd` (autoload Partie)
- `godot/tests/test_logique.gd`, `test_demo.gd` ; `test_partie.gd` partagé (il instancie `PanneauBanque`)
- `godot/outils/tests.ps1`, `godot/export_presets.cfg`, racine `Exporter_*.bat`, `Jouer_Godot.bat`
- Partagés selon le lot : `project.godot` (`[autoload]`, `config/version`), `scripts/principal.gd` (stratégie automatique des captures).

## Points d'attention
- L'UI lit directement des champs d'`EtatPartie` (`banque`, `joueur`, `hist`, `stats`, `temoins`…) et ≈ 35 fonctions statiques (`Banquier`, `Produits`, `Versements`, `Marche`) : **renommer ou changer une signature = écart d'interface à signaler** (liste dans `chef-de-projet.md` §2).
- Nouveau champ d'état : décider de la version de sauvegarde dans le plan (`Sauvegarde.VERSION`, `EtatPartie.VERSION_ETAT`, `CHAMPS_ETAT`).
- Version d'export (0.3 / code 3 depuis le lot 02) à incrémenter à chaque export partagé.
- Nouveau champ d'état (lots 03+) : `CHAMPS_ETAT` + initialisation dans `demarrer()` ; pas de nouvelle version de sauvegarde (migration douce). Nouvelle interruption (carte, projet, gazette) : `kind` reconnu par `Cadence.rang/categorie` (déjà prévus), échéance de projet : `echeance_projet` + `m_echeance` dans l'élément de file.

- Outils de test possédés : `godot/outils/trouver_godot.ps1`, `tests.ps1`, `tests/test_interface.*`, `tests/autocontrole/`, `scripts/logique/strategie_test.gd` (commandes et règles : socle §6).
- `StrategieTest` diffère de `principal._strategie_active` sur un seul point : avant de placer dans un produit qu'il vient d'ouvrir, le joueur actif porte son compte à 2 500 F depuis le Livret A (`PLANCHER_F`) ; sans cela, graines 9 et 12 : PEL ou actions jamais achetés faute de liquidités. Jamais déclenché avec la graine des captures (`config_demo(-1)`).
- `test_interface` attend qu'une modale soit **visible** avant de la fermer (le courrier reste caché 0,5 s pendant le vol de l'enveloppe ; le fermer avant lève une SCRIPT ERROR dans `modales.gd` l. 589 — impossible pour un vrai joueur, qui ne peut toucher qu'une feuille visible).

## Journal
- 2026-10-29, lot 01 : `trouver_godot.ps1` (JEUCLAUDE_GODOT / dépôt / worktree), `tests.ps1` strict et extensible (+ `-Autocontrole`), `.bat` avec JEUCLAUDE_GODOT, `StrategieTest`, `test_interface` (21 vérifications, ≈ 5 s), fichiers `user://` uniques par processus. Mutations vérifiées : `vie_en_attente` renommée, `e.hist["mis"]` (hud.gd) et `e.banque["presentes"]` (panneau_banque.gd) faussés → test_interface (et test_partie) en échec.
- 2026-10-29, lot 01 passage 2 (KO du testeur) : `Jouer_Godot.bat` cassé sans `JEUCLAUDE_GODOT`. **En .bat, `%VAR:a=b%` est développé avant l'évaluation du `if` : sauter par `goto` quand la variable peut être absente** (ni `%VAR:a=b%` ni `%VAR:~n%`, même dans un `rem`). Toujours vérifier un .bat à sec (copie hors dépôt, `start` → `echo`), avec et sans la variable. Accès de `test_interface` à `_droite` / `_b_ok` de PanneauBanque : tolérés (T15), échec lisible si renommés.
- 2026-10-30, lot 02-L : flux du mois, saut + non-lus, `Cadence`, format 3 + migration douce, T17/T18, export 0.3 (détail : socle §1, §3). Tests nouveaux : `test_mois_utile.tscn` (flux au franc près contre le moteur et le relevé ; saut sur 40 graines comparé à la même partie jouée mois par mois), `test_cadence.gd` (40 graines × 2 stratégies, imprime la liste des interruptions ; R-MIROIR), `test_sauvegarde.tscn` (chaque champ retiré, sauvegarde pendant un saut). Choix signalés : anticipation étendue aux événements de vie aléatoires ; présentation à sa date limite de rang 2,5 ; saut continué jusqu'à la fin de partie en 12/1988 ; modale de marché laisse le jeu en pause même après un saut ; `changer_vitesse`/`basculer_pause` arrêtent le saut.
- Tests de scène pilotés de façon **synchrone dans `_ready`** (aucun `await`) : `Partie._process(1.4)` fait passer un mois de saut sans que le vrai `_process` interfère.
- Migration : ne compléter clé par clé que les dictionnaires « enregistrement » (`banque`, `stats`, `hist`) ; compléter `modale` ferait réapparaître la présentation D01. Défaut de `modale`/`file` : vide.
- `ReadAllText` / `WriteAllText` .NET avec un chemin relatif : relatif au dossier du processus, pas à `cd` de PowerShell → chemins absolus.
- À ne pas refaire : `exit` dans un .ps1 inclus par point (ne quitte pas l'appelant) ; compter sur le code de sortie de Godot (une SCRIPT ERROR laisse le code 0, ou bloque un test qui n'atteint jamais `quit()`).
