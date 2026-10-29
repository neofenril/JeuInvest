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
- Version d'export (0.2 / code 2) à incrémenter à chaque export partagé.

- Outils de test possédés : `godot/outils/trouver_godot.ps1`, `tests.ps1`, `tests/test_interface.*`, `tests/autocontrole/`, `scripts/logique/strategie_test.gd` (commandes et règles : socle §6).
- `StrategieTest` diffère de `principal._strategie_active` sur un seul point : avant de placer dans un produit qu'il vient d'ouvrir, le joueur actif porte son compte à 2 500 F depuis le Livret A (`PLANCHER_F`) ; sans cela, graines 9 et 12 : PEL ou actions jamais achetés faute de liquidités. Jamais déclenché avec la graine des captures (`config_demo(-1)`).
- `test_interface` attend qu'une modale soit **visible** avant de la fermer (le courrier reste caché 0,5 s pendant le vol de l'enveloppe ; le fermer avant lève une SCRIPT ERROR dans `modales.gd` l. 589 — impossible pour un vrai joueur, qui ne peut toucher qu'une feuille visible).

## Journal
- 2026-10-29, lot 01 : `trouver_godot.ps1` (JEUCLAUDE_GODOT / dépôt / worktree), `tests.ps1` strict et extensible (+ `-Autocontrole`), `.bat` avec JEUCLAUDE_GODOT, `StrategieTest`, `test_interface` (21 vérifications, ≈ 5 s), fichiers `user://` uniques par processus. Mutations vérifiées : `vie_en_attente` renommée, `e.hist["mis"]` (hud.gd) et `e.banque["presentes"]` (panneau_banque.gd) faussés → test_interface (et test_partie) en échec.
- À ne pas refaire : `exit` dans un .ps1 inclus par point (ne quitte pas l'appelant) ; compter sur le code de sortie de Godot (une SCRIPT ERROR laisse le code 0, ou bloque un test qui n'atteint jamais `quit()`).
