# Base de connaissances du testeur

> À lire au début de chaque mission (après `CLAUDE.md` et le socle `developpeur.md`), à mettre à jour à la fin. Concise.
> Dernière mise à jour : 2026-10-30 (PX0 : `lot/px0-ville` 45f5120 OK, `lot/px0-interface` 0ad6db7 OK, fusion simulée sans conflit). Avant : lot 01 (logique KO puis OK sur 00c4821 ; interface OK sur 261d373).

## 1. Règles de travail
- Je ne modifie jamais un fichier suivi par Git dans le worktree d'un développeur ; pour les mutations, worktree jetable :
  `& $git -C C:\Users\arthu\Documents\temp\JeuClaude worktree add --detach C:\Users\arthu\Documents\temp\JeuClaude_lots\recette-xx <branche>` puis `worktree remove --force` + `worktree prune`. Annuler chaque mutation (`git checkout -- <fichier>`) avant la suivante.
- `user://` (`%APPDATA%\Godot\app_userdata\JeuClaude`) est commun à tout : noter le SHA-256 de `partie_en_cours.sav` avant/après ; ne jamais lancer le vrai jeu (fenêtre) sur la partie du joueur. Pour tester un `.bat` qui lance le jeu : copie dans le scratchpad, `start ""` remplacé par `echo`.
- Jonction de test (`New-Item -ItemType Junction`) : la supprimer avec `cmd /c rmdir <lien>` (jamais `Remove-Item -Recurse`, qui viderait la cible).
- Rapport : `docs/lots/lot_NN_recette.md` (dépôt principal, sans commit) ; une section par branche et par passage. Deux testeurs en parallèle : relire le fichier juste avant d'écrire et **ajouter** sa section (Edit), jamais réécrire le fichier.
- **Copies isolées** (sans toucher au dépôt ni aux worktrees) : `git archive --format=zip -o x.zip <commit> godot` → `Expand-Archive` dans le scratchpad, puis dans la copie de `project.godot` ajouter `config/use_custom_user_dir=true` + `config/custom_user_dir_name="JeuClaude_recette_x"` : `user://` à part (aucun risque pour la partie du joueur ni conflit de `capture.sav` avec un autre agent). Sert pour la référence `main`, la branche et une **fusion simulée** (archive d'une branche + fichiers de l'autre). Premier `--import` d'une copie neuve : peut planter (−1073741819), relancer.
- Ne pas lancer Godot sur le dépôt principal pour une référence : il y créerait des `*.import` non suivis ; utiliser une copie.

## 2. Commandes
- Git : `C:\Users\arthu\Documents\temp\JeuClaude\outils\git\cmd\git.exe` ; périmètre : `git diff main...<branche> --stat`.
- Tests : `powershell -NoProfile -ExecutionPolicy Bypass -File <wt>\godot\outils\tests.ps1 [-SansImport] [-Filtre x] [-Recette] [-Delai s] [-Autocontrole]` (marche depuis un worktree ; ne pas tronquer la sortie avec `Select-Object -First`, ça tue le processus et fausse `$LASTEXITCODE`).
- Captures : `...\capture.ps1 -Etape <e> -Nom <n> [-Telephone]` → `<wt>\godot\captures\<n>.png` ; relire chaque image.
- Exe exporté : `JeuClaude.exe --resolution 1280x720 --log-file <log> -- --capture=<png absolu> --etape=titre`.
- Mes tests de recette : `godot/tests/recette/test_*.gd` (lancés par `-Recette`).

## 3. Scénarios réutilisables
- Partie complète : capture `integrale` (≈ 170 s) ; référence lot 01 : appel 8, banque 4, courrier 2, journal 1, fin 1 ; fin = fin, déc. 1988, patrimoine 156 645 F, 11 interruptions, frais 273,60 F, écart Livret A −6 486 F.
- Mutations du contrat logique ↔ affichage (doivent faire échouer `tests.ps1`) : renommer `EtatPartie.vie_en_attente` ; `e.hist["mis"]` (hud.gd ~l. 622) ; `e.banque["presentes"]` (panneau_banque.gd ~l. 253) ; clé dans `Modales.courrier` ; erreur de syntaxe dans modales.gd.
- Résolution de Godot : variable valide / inexistante (code 3) ; dépôt simulé (jonction `outils\`) ; dossier vide (code 3, 3 chemins listés).
- `.bat` : toujours tester **avec et sans** `JEUCLAUDE_GODOT` (cmd développe `%VAR:a=b%` même derrière `if defined`) ; `Jouer_Godot.bat` à sec, 3 cas : sans variable, variable vers la console du dépôt principal (→ version sans console), variable vers un `_console.exe` isolé (→ chemin de la variable).
- Garde-fou T15 de `test_interface` : renommer `_droite` ou `_b_ok` dans `panneau_banque.gd` → KO « champ interne … introuvable », 0 erreur de script.
- Passage N d'une branche : contrôler aussi que les fichiers reçus par `main` depuis la base de la branche ne recoupent pas ceux du diff (risque de conflit).
- Parallélisme : deux `tests.ps1 -Filtre test_demo` simultanés → verts, aucun `test_*.sav` restant.
- **« Aucun changement de comportement »** (refactorisation) : lancer les 53 étapes de `capture.ps1` sur `main` et la branche (copies isolées, `Start-Process -Wait -PassThru -RedirectStandardOutput/-Error` pour le code et des journaux propres ; ≈ 10 s par étape, intégrale ≈ 170 s), comparer (1) les sorties texte (seuls `fps` et `trafic` varient), (2) les images au pixel (System.Drawing, 1 pixel sur 4, seuil 40 : < 1 % = animations ; au-delà, regarder la paire), (3) le code par **différence normalisée** (anciens noms remplacés par les nouveaux, puis `git diff --no-index`).
- Appels dynamiques (`jeu: Node`, `call`, `get`) : recenser toutes les références (`Grep -o "\bjeu\.[a-zA-Z_]+"`), vérifier que chaque membre existe ; couvrir par un test de recette les chemins que les captures n'empruntent pas (fin → « Rejouer », journal « soldes » → banque, menu → historique).
- Raccourcis de test : étape `raccourcis` avec et sans `-- --joueur`, puis exe exporté (`--export-release "Windows" <png absolu hors dépôt>`, lancé avec `--log-file`). Attendu joueur : F8 / triple toucher / F6 / F10 sans effet, touches 2 / Espace / M / H actives, titre sans ligne d'aide.
- Test de recette `test_recette_decoupage` (11 vérifications, avec et sans `--joueur`) écrit au lot 01 dans une copie : à déposer dans `godot/tests/recette/` après fusion du lot 01.

## 4. Zones fragiles
- CA-L6 (StrategieTest, ≥ 7 produits sur 20 graines) : minimum **exactement 7** ; tout changement d'équilibre (événements P2-P5) peut le casser.
- `test_interface` lit des variables privées de `PanneauBanque` (`_droite`, `_b_ok`) : toléré au lot 01, échec lisible ; accesseurs publics prévus au lot 02 (T15).
- `modales.gd` l. 589 : fermer un courrier pendant le vol de l'enveloppe (0,5 s) → SCRIPT ERROR ; peut-être atteignable par Échap en relecture d'historique. Reporté au lot 02 (T16, dev-interface) : à vérifier là.
- Écran de fin : montant et barres animés depuis 0 ; une capture trop tôt montre des chiffres « faux » (pas un bug).
- `user://capture.sav` partagé entre worktrees : captures simultanées possibles conflits (parade : copie isolée).
- Structure après le lot 01 : `principal.gd` (≤ 600 l.) + `EcranTitre`, `Sequences`, `RaccourcisTest`, `Reglages`, `ScenariosCapture` + `scenarios/*.gd`. Les modules s'appellent par `jeu: Node` (non vérifié à l'analyse) : tout renommage dans `principal.gd` = relancer toutes les captures.
- HUD « Mon argent » : en début de partie (historique de quelques mois), la courbe et l'étiquette d'écart recouvrent les graduations (préexistant, `main` compris) ; à surveiller au lot 02.
- `capture.ps1` ne connaît ni l'étape `raccourcis` ni `--joueur` (lot 01) : commande Godot directe.

## 4 bis. PX0 (recette 2026-10-30, ville 45f5120 + interface 0ad6db7 : OK / OK, fusion sans conflit)
- Fusion simulée = worktree jetable détaché sur `main` + `merge --no-ff` des deux branches (identité `-c user.name=testeur`), puis `worktree remove --force` + `prune`. Copier les captures utiles avant (ex. `godot/captures/recette_px0_fusion/`, ignoré par Git).
- `capture_px0.ps1 -Serie` (≈ 190 s) ; lignes à relire : `palette … hors_palette`, `grille … irreguliers`, `figurine`, `echelle`, `cadrage`, `etiquette … sur_chaussee`, `hud …`, `carte …`, `images_par_seconde`. Étapes hors série à lancer à la main : `carte_fermee`, `polices`, `carte -Telephone`.
- Grille de la rue 540 : N = 1 à 720p / 1366 / téléphone → contrôle `irreguliers` trivial et rue plus petite qu'en 1080p (zone fragile, à suivre en PX1).
- Branche sur l'ancien `tests.ps1` (avant lot 01) : il ne trouve pas Godot depuis un worktree → lancer les tests à la main (`--script res://tests/test_*.gd`, `res://tests/test_partie.tscn`).
- `.ttf.import` non suivis dans le dépôt principal : ils bloqueront la fusion de `lot/px0-interface` dans `main` (à retirer juste avant).
- Pas d'étape « orage » dans px0 : l'orage n'est contrôlé que par test_pixel.

## 5. Anomalies récurrentes / à surveiller
- Fichiers « recopiés de main » dans une branche (tests.ps1, trouver_godot.ps1 sur px0-ville) : vérifier `git diff main <branche> -- <fichier>` vide → sans conflit, mineur.
- Ce que le développeur marque « non vérifié » : le vérifier en priorité (lot 01 : `Jouer_Godot.bat` cassé sans variable).
- Polices `*.ttf.import` non suivies dans les worktrees : seul dev-interface PX0 les commite (CA-C1 de `lot_px0.md`) ; ailleurs, les signaler s'ils apparaissent dans un diff.
