# Base de connaissances de dev-interface

> Lire d'abord `CLAUDE.md` et le **socle commun `docs/connaissances/developpeur.md`** (architecture, décisions, pièges Godot, captures). Ici : seulement ce qui est propre à dev-interface. Concise.
> Créée le 2026-10-28 par le chef de projet (prise de poste, aucun lot réalisé).

## Périmètre
Écrans, HUD, modales, fenêtre Banque, ville vectorielle, animations, game feel, adaptation PC / téléphone, captures. Consignes uniquement via `docs/lots/lot_NN.md` ; ne modifier que les fichiers attribués par le lot. Direction artistique : `docs/09`, `docs/13` ; retours du joueur `docs/10` prioritaires.

## Fichiers possédés par défaut (carte complète : `chef-de-projet.md` §1)
- `godot/scripts/ui/*.gd`, `godot/scripts/ville/*.gd`, `godot/scripts/juice.gd`, `godot/scripts/ecran.gd`
- `godot/scripts/outils/capture.gd`, `godot/outils/capture.ps1`, `godot/captures/`, `godot/outils/generer_icones.gd`
- `godot/scenes/`, `godot/shaders/`, `godot/assets/`, `godot/icon.svg`
- Partagés selon le lot (propriétaire par défaut) : `scripts/principal.gd`, `project.godot` (`[display]`, `[gui]`, `[rendering]`).

## Points d'attention
- Les données et calculs viennent de `Partie`, `EtatPartie` et des statiques de `scripts/logique/` (liste dans `chef-de-projet.md` §2) : n'ajoute pas de règle métier dans l'UI ; demande la fonction à dev-logique via le chef de projet.
- `Format` et `Dates` appartiennent à dev-logique.
- Toujours capturer PC (1280×720) et téléphone (`--telephone`) et relire les PNG.

## Journal
- (vide)
