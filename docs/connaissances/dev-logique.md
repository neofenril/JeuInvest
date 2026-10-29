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

## Journal
- (vide)
