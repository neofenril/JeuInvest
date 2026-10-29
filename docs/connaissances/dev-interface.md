# Base de connaissances de dev-interface

> Lire d'abord `CLAUDE.md` et le **socle commun `docs/connaissances/developpeur.md`** (architecture, décisions, pièges Godot, captures). Ici : seulement ce qui est propre à dev-interface. Concise.
> Créée le 2026-10-28 par le chef de projet ; mise à jour le 2026-10-29 (lot 01 : découpage de `principal.gd`, raccourcis de test).

## Périmètre
Écrans, HUD, modales, fenêtre Banque, ville vectorielle, animations, game feel, adaptation PC / téléphone, captures. Consignes uniquement via `docs/lots/lot_NN.md` ; ne modifier que les fichiers attribués par le lot. Direction artistique : `docs/09`, `docs/13` ; retours du joueur `docs/10` prioritaires.

## Fichiers possédés par défaut (carte complète : `chef-de-projet.md` §1)
- `godot/scripts/ui/*.gd`, `godot/scripts/ville/*.gd`, `godot/scripts/juice.gd`, `godot/scripts/ecran.gd`
- `godot/scripts/outils/capture.gd`, `godot/outils/capture.ps1`, `godot/captures/`, `godot/outils/generer_icones.gd`
- `godot/scenes/`, `godot/shaders/`, `godot/assets/`, `godot/icon.svg`
- Partagés selon le lot (propriétaire par défaut) : `scripts/principal.gd`, `project.godot` (`[display]`, `[gui]`, `[rendering]`, `[jeuclaude]`).

## Structure de la scène principale (après le lot 01)
| Fichier | Rôle |
|---|---|
| `scripts/principal.gd` (≈ 585 l., plafond 600) | Calques et nœuds, câblage des signaux, mise en place / reprise, `_process`, touches de jeu (Espace / P, 1-3, M / B, H), réactions aux signaux de `Partie`, fenêtre Banque, menu, historique, infos (foyer, comparaison, frais), sauvegarde à la fermeture, `preparer_capture` (délégation). API publique utilisée par les autres modules : `demo ville hud modales titre sequences en_titre pluie_jusqua dernier_releve`, `nouvelle_partie reprendre demarrer_direct jouer demander_nouvelle_partie maj_titre ouvrir_banque ouvrir_historique ouvrir_menu expliquer_comparaison toucher_batiment toucher_notif`. |
| `scripts/ui/ecran_titre.gd` (`EcranTitre`) | Construction du titre (`construire(demo)`), `maj(sauvee, en_cours)`, `texte_reprise()`, `donner_focus()`. Émet `jouer_demande`, `nouvelle_partie_demandee` ; n'appelle jamais `Partie`. Ligne d'aide `l_aide` visible seulement si `Reglages.raccourcis_test()` et pas mobile. |
| `scripts/ville/sequences.gd` (`Sequences`, nœud enfant) | File des « vedettes » (`vedette`, `occupe`), attrape-toucher (A34), séquences banquier / journal / courrier + panne / naissance / fin, `petite_news`, `clignoter_maison`, `maj_media` (écran du toit). Références via `installer(jeu, ville, hud, modales, calque_modales)` ; rappelle `jeu.ouvrir_banque`, `jeu.nouvelle_partie`, `jeu.demarrer_direct`, `jeu.pluie_jusqua`. |
| `scripts/outils/reglages.gd` (`Reglages`) | `raccourcis_test()` : faux dans toute version exportée (tag `template`), avec `-- --joueur`, ou si `jeuclaude/raccourcis_test=false`. |
| `scripts/outils/raccourcis_test.gd` (`RaccourcisTest`) | F6 / F7 (naissance), F8 et triple toucher sur la date (`sauter_moment`). Créé par `principal._ready` **seulement si** `Reglages.raccourcis_test()`. F10 : `ecran.gd` (soumis au même réglage ; `--telephone` des captures passe par `basculer_telephone()` et reste actif). |
| `scripts/outils/scenarios_capture.gd` (`ScenariosCapture`) | Répartiteur des `--etape=` (créé à la demande par `preparer_capture`) + outils : `partir_de_la_rue`, `delai`, `attendre_que`, `aller_a`, `aller_a_modale`, `strategie_active` (copie de `StrategieTest`, à remplacer au lot 02, T13), `appuyer_bouton`, `clic_dehors`, `touche`, `position_fenetre`, `vitesse_mesuree` ; statiques `option(nom)`, `mode_capture()`. |
| `scripts/outils/scenarios/*.gd` (sans `class_name`) | Familles : `titre` (sans départ dans la rue), `banque`, `ville`, `ecrans`, `outils` (dont `raccourcis`). Chaque fichier : `const ETAPES`, `var sc`, `func jouer(etape)`. |

## Où ajouter…
- **Une séquence animée** : `_sequence_x(c)` dans `sequences.gd`, lancée par `vedette()` depuis `jouer_modale()` (ou une fonction publique appelée par `principal._on_notif`).
- **Une étape de capture** : le nom dans `ETAPES` de la famille, son cas dans `jouer()`, la ligne de `outils/capture.ps1` (fichier de dev-logique au lot 01). Une nouvelle famille : fichier dans `scenarios/` + nom dans `ScenariosCapture.FAMILLES`. Une étape inconnue démarre simplement dans la rue.
- **Un raccourci de test** : une touche dans `RaccourcisTest._unhandled_input` + la ligne d'aide d'`EcranTitre`. Jamais dans `principal.gd`.

## Points d'attention
- Les données et calculs viennent de `Partie`, `EtatPartie` et des statiques de `scripts/logique/` (liste dans `chef-de-projet.md` §2) : n'ajoute pas de règle métier dans l'UI ; demande la fonction à dev-logique via le chef de projet. `Format` et `Dates` appartiennent à dev-logique.
- Les appels entre modules passent par une référence `jeu: Node` (principal.gd n'a pas de `class_name`) : appels **dynamiques**, non vérifiés à l'analyse. Une faute de nom n'apparaît qu'à l'exécution : relancer les captures concernées (toutes : boucle du compte rendu ci-dessous).
- Toujours capturer PC (1280×720) et téléphone (`--telephone`) et relire les PNG.
- Ne jamais modifier un script pendant qu'une série de captures tourne (chaque lancement recharge les scripts).
- Entrées simulées : `Input.parse_input_event` attend des coordonnées **fenêtre** ; pour viser un contrôle : `sc.position_fenetre(c)` (`get_final_transform()` × position canevas). Vérifié : le triple toucher atteint la date du HUD.
- Version du joueur depuis l'éditeur : `-- --joueur` (ex. `--etape=raccourcis --joueur`).

## Journal
- 2026-10-29, lot 01 : découpage de `principal.gd` (1 611 → 585 lignes) en `EcranTitre`, `Sequences`, `RaccourcisTest`, `Reglages`, `ScenariosCapture` + 5 familles ; raccourcis de test retirés de la version du joueur ; nouvelle étape `raccourcis`. Vérifications : toutes les étapes de capture.ps1 sans erreur, comparaison pixel à pixel avec `main` (script de comparaison System.Drawing dans PowerShell 5.1, échantillon 1 pixel sur 16, seuil 30), exe exporté depuis le worktree.
