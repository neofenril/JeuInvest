# Base de connaissances du testeur

> À lire au début de chaque mission (après `CLAUDE.md` et le socle `developpeur.md`), à mettre à jour à la fin. Concise.
> Dernière mise à jour : 2026-11-12 (03-I : b9c1dc7 OK, rapport 295bc68). Avant : 2026-11-12 (03-foyer : 281b807 OK). Avant : 2026-11-12 (03-V passage 2 : de8fbf8 OK). Avant : 2026-11-12 (03-V : c75a150 KO, fusion avec 03-L propre). Avant : 2026-11-09 (02-I passage 2 : 41932b3 OK, fusion comprise). Avant : 2026-11-07 (02-I : `lot/02-interface` baf2664 KO + fusion simulée avec 02-V ; avant : PX2 passage 2 : 5d23c3b OK). Avant : 2026-11-03 (PX2 : `lot/px2-interface` c890d61 KO ; PX1 : `lot/px1-ville` 48ecd10 KO, A1 titre, puis 7733938 OK). Avant : 2026-10-30 (02-L : `lot/02-logique` 252f8b0 OK ; PX0 : `lot/px0-ville` 45f5120 OK, `lot/px0-interface` 0ad6db7 OK, fusion simulée sans conflit). Avant : lot 01 (logique KO puis OK sur 00c4821 ; interface OK sur 261d373).

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

## 4 ter. Lot 02-L (recette 2026-10-30, `lot/02-logique` 252f8b0 : OK, 4 mineures)
- Références : branche 258 vérifications (avec recette `-Joueur`), fusion avec `main` 972358a : 335. `test_cadence` imprime la liste des interruptions par graine (80 parties, 11-13, moy. 11,41) ; `test_demo` 40 graines passif : `main` {11:29, 12:11} → V3 {11:31, 12:9}.
- **Nouvelle référence `integrale` après 02-L : 160 749 F, frais 805,93 F, 11 interruptions** (graine 11 ; la cadence V3 décale D05/D06, le scénario « une présentation sur deux » achète la SICAV au lieu de l'assurance-vie). L'ancienne (156 645 F) ne vaut plus que pour `main` avant F1.
- Expliquer un écart de chiffres : instrumenter `scenarios/outils.gd` **dans la copie isolée** (print de `banque.interruptions_liste`, `joueur.lignes`) et comparer `main` / fusion.
- Vraie sauvegarde d'un ancien format : script jetable dans la copie de `main` (`Sauvegarde.ecrire(e, {}, <chemin absolu scratchpad>)`), lu par un script dans la copie de la branche. `Partie.sauvegarder()` ne fait rien sans `sauvegarde_auto = true`.
- Scènes de test de l'autoload `Partie` : `.tscn` minimal + `Partie._process(1.4)` en boucle (synchrone, headless).
- Exe exporté : passer `--capture=` avec des `/` (avec des `\` via Start-Process : « Can't save PNG at path '' »). Présence d'un fichier dans le paquet : chercher le chemin `data/...` dans les octets de l'exe.
- Copies isolées : `custom_user_dir_name` crée `%APPDATA%\<nom>` (pas sous `Godot\app_userdata`) : y supprimer à la fin.
- Zone fragile : les interruptions datées ne contournent plus l'écart de 2 mois (seul marché → panne) ; à surveiller quand cartes et projets (03-04) rempliront le calendrier. Saut + modale de marché → pause (question ouverte au CDP). Aucun dividende dans le moteur (genre `dividende` jamais émis).
- Vu le 30/10 : `godot/export_presets.cfg` modifié non commité **dans le dépôt principal** (pas par moi) : toujours faire `git status` du dépôt principal en début et fin de recette.

## 4 quater. PX1 (recette 2026-11-03, `lot/px1-ville` 48ecd10 : KO, 1 majeure A1 titre)
- Série `capture_ville.ps1 -Serie` ≈ 500 s, fenêtrée (plein écran à 1080p) : la lancer en arrière-plan et attendre la ligne « PX1 : » dans `godot/captures/px1_serie.log`. Ne pas lancer de tests en parallèle (fps, génération ≤ 2 s).
- Références PX1 : branche 347 vérifications ; fusion avec a74a202 : 392 ; `integrale` inchangée (160 749 F / 805,93 F / 11) ; trafic ×1 / 2,5 / 4,5 exact ; fps 421 (1080) / 687 (tél.).
- Copie de fusion = worktree jetable + merge, puis `git archive HEAD godot` depuis ce worktree avant de le supprimer. `capture.ps1` et `tests.ps1` d'une copie hors dépôt : `$env:JEUCLAUDE_GODOT` dans la même commande.
- Zones fragiles : arbre de premier plan (bord droit de la vue) qui masque l'enseigne du titre ; hiver (recoloration en tâche de fond, arbres verts ou givrés selon le moment) ; étiquettes et `point_tete` qui ne tiennent pas compte du rectangle libre (frise au tél., panneau Mon argent) ; flèches ← → mangées par le focus des boutons ; `test_rue` génération 1,7 s / 2 s.
- Relire en priorité : `titre`, `rue_gazette_tel`, `pause` (hiver), `crash_anim`, `voisins`.
- Passage 2 (7733938 : OK) : 350 vérifications sur la branche, 395 sur la fusion ; génération 1,1 s ; `integrale` inchangée. A2 (étiquette sous la frise au tél.) et A3 (`pause` : arbre vert en hiver) toujours là ; A11 = à-coup au 1er orage.
- **Mesurer un à-coup** : copie isolée (`Expand-Archive` du zip), y ajouter des `print("RUE …")` (seules les lignes `RUE *` passent le filtre de `capture_ville.ps1`) : horodatage + durée max d'image dans `_passer_apres`, et chrono de `GrillePixel.texture` (≥ 15 ms). Krach : image de 600 ms (300 ms après préchauffage) = textures ORAGE créées en direct (images faites en tâche de fond, absentes de `_prechauffe`). Supprimer les copies avec `cmd /c "rmdir /s /q \\?\<chemin littéral>"` (chemins trop longs de `.godot\editor` ; pas de variable dans la commande).

## 4 quinquies. PX2 (recette 2026-11-03, `lot/px2-interface` c890d61 : KO, 4 majeures)
- Références : branche 334 (base 243bb82) ; fusion a74a202 + PX2 + PX1 48ecd10 : 447 ; `integrale` branche seule 156 645 F / 273,60 F (pré-02-L), fusion 160 749 F / 805,93 F / 11. `capture_interface.ps1 -Serie` 61 lancements ≈ 8-20 min (cibles lent) ; fps et `clic_dehors` non journalisés : relancer à la main.
- Échelle PX2 : `content_scale_mode = DISABLED`, facteur T/3 ; PC T = floor(h/324) ; mobile T selon le dpi seul → **zone logique d'un vrai téléphone (2400×1080 à 400 dpi) = 1440×648**, plus petite que le téléphone simulé 1600×720. Simuler : copie isolée avec `FENETRE_TELEPHONE` modifié dans `scripts/ecran.gd` (1440×648, 1200×540) + `--telephone`.
- Cas PC à tester : fenêtre 1920×1009 (1080p fenêtré, T=3) et < 648 px de haut (T=1).
- Prouver une correction : rejouer l'étape sur une copie avec l'ancien fichier (`cmd /c git show <base>:<f> > copie` pour garder les octets ; pas `Out-String`).
- Glyphes : script `--script` dans une copie avec `PolicesPixel.manquants(chemin, texte)` sur tous les caractères non ASCII des données et scripts. Manquent : → ← ▲ ▼ ○ ●.
- Zones fragiles : panneau « Mon argent » plus haut que sa place (recouvre la frise) ; montants en Pixelify dans les boutons (5 → S) ; flèches de bord et étiquettes hors `rect_libre()` à la fusion PX1 ; `debordements` ne voit pas les conteneurs.
- `Copy-Item -Recurse` d'une copie importée : erreurs de chemin trop long sur `.godot\editor\*.cfg` sans conséquence.

- **Passage 2 (5d23c3b : OK, 5 mineures)** : 491 vérifications (branche = fusion, `main` dans la branche) ; `capture_interface.ps1 -Serie` = 106 lancements ≈ 26 min (lancer en arrière-plan, les commandes > 180 s passent en tâche de fond) ; `capture_ville.ps1 -Serie` ≈ 11 min, « échec » attendu depuis un worktree (montage `px0_quater_jour_1080.png` absent). Téléphone simulé = 1440 × 648 à 240 dpi (+ `-Telephone169` 1280 × 720 à 320 dpi). Lignes à lire : `UI panneau … recouvre/contenu_coupe`, `UI etiquette … dans_libre`, `UI fenetre … dans_ecran`, `UI polices`, `cibles`.
- Zones fragiles restantes : textes dessinés par `draw_string` (tuiles du carnet 16 → 12 px, badge NOUVEAU 14 px) invisibles pour `atkinson_min` ; blocage aléatoire de Godot à la sortie (rue PX1).
- Le scratchpad peut être partagé avec une autre session (copies `pb`, `pi`, captures `pel_*`) : préfixer mes fichiers (`testeur_*`) et ne toucher à rien d'autre.
- `partie_en_cours.sav` peut changer hors de mes lancements (vu le 07/11 à 00:49) : noter l'horodatage (`LastWriteTime`) en plus du SHA-256 pour prouver que ce n'est pas la recette.

## 4 sexies. F1-L (recette 2026-11-04, `lot/f1-logique` 6397542 : OK, 3 mineures)
- Références : branche 330 ; fusion main 76e3a30 + F1-L : 401 ; `integrale` inchangée (160 749 F / 805,93 F / 11).
- Insécable = U+00A0 (`Format.ESPACE`) ; contrôle : regex `(\d|\})[ ](%|F\b)` sur les JSON ; glyphes : `Font.has_char(0xA0)` + `get_string_size` (script `--script` absolu hors projet, ça marche).
- Ancienne sauvegarde : script `recette_sav.gd` (mode écrire sur copie de main / lire sur la fusion, `StrategieTest.aller_a` jusqu'à 1989-06) ; comparer les chiffres de fin.
- **Étape `carnet_pel` ne quitte pas** (corrigé par PX1-bis adf593d, vrai sur `main` avant sa fusion) (PNG écrit puis fenêtre figée), déjà sur `main` : lancer les captures par `Start-Process -PassThru` + `WaitForExit(ms)`, jamais en boucle bloquante ; je ne peux pas tuer les processus Godot (garde-fou).
- Reste « → » dans `modales.gd` (l. 521, 873) et des espaces normales dans les autres JSON.

## 4 septies. PX1-bis (recette 2026-11-07, `lot/px1-ville` adf593d : OK, 3 mineures)
- Références : 405 tests (branche = fusion, même arbre) ; `integrale` inchangée ; `test_rue` imprime `RUE image_max_ms`, la série `RUE image_max etape=…` (krach ≤ 44 ms, toucher krach 0,27 s).
- Série dans une copie neuve : copier `px0_quater_jour_1080.png` dans `captures/` sinon le montage px0 fait échouer la série (faux KO).
- Blocage à la sortie : `carnet_pel` ×12 et `--quit-after N` (1 à 2 000) via `Start-Process -PassThru` + `WaitForExit(45000)` : quitte toujours ; ≈ 5,7 s minimum (attente des tâches de fond ≈ 3 s).
- Démarrage : étape jetable `jouer_tot` dans `scenarios/titre.gd` d'une copie (chrono par image + captures à t, « Jouer » à t via variable d'environnement) : arbre de premier plan absent ≈ 2 s ; une image de ≈ 170 ms à t ≈ 0,17 s (origine inconnue).
- `partie_en_cours.sav` peut changer pendant la recette parce que le joueur joue (Godot non console lancé) : noter la date d'écriture du fichier pour se disculper.

## 4 octies. 02-V (recette 2026-11-07, `lot/02-ville` 586385e : OK, 5 mineures ; rapport commité sur la branche, f109d19)
- Références : 539 vérifications (`main` 495) ; série `capture_ville.ps1 -Serie` = 74 lancements, 861 s, **passe sur copie neuve** (plus d'image PX0). Durées de séquence `main` = branche (journal_krach 1,36-1,39 ; l'étape `courrier` donne 1,22 : autre mesure, pas une régression).
- Un lancement en arrière-plan de l'outil n'est pas tué à 10 min : la série complète peut tourner en tâche de fond.
- Lignes à lire : `RUE pieces genre=… n=… depart=… arrivee=…`, `en_vol=… hors_texel=0`, `arrivee … ecart=1`, `aucune raison=…`, `noeuds_crees=0`, `camera … calme=0.0`, `premier_plan … fondu_s`.
- Zones fragiles : pièces d'or sur l'enseigne dorée de l'épicerie (même couleur) ; flottants longs sur le décor ; « porte visible ≥ 8 px » (pièces au bord d'écran à côté de deux flèches de bord) ; changement porte → flèche en plein vol (saut possible) ; flèches « ‹ LA GAZETTE » / « ‹ MA MAISON » qui se chevauchent (HUD, aussi à 1080p).
- Mon `test_recette_decoupage` sortait « 1 resources still in use at exit » : corrigé au 02-I (0026dbb) en fermant la carte du Livret A avant `queue_free` (une modale ouverte laisse des coroutines `GDScriptFunctionState` en attente). Diagnostic : lancer la scène avec `--verbose` → « Resource still in use: <script> ».
- `partie_en_cours.sav` absent le 07/11 : noter l'absence avant / après.
- Rapport dans le worktree de la branche si le coordinateur le demande (commit local) ; risque d'ajout des deux côtés si l'autre branche crée le même fichier.

## 4 nonies. 02-I (recette 2026-11-07, `lot/02-interface` baf2664 : KO, A1 test aléatoire, A2 flèches chevauchées ; rapport + tests commités 0026dbb)
- Références : branche 504 (+ recette 29) ; fusion main + 02-V + 02-I : 548 (+ 29) ; `integrale` et `integrale_saut` = 160 749 F / 805,93 F / 11 ; `capture_interface.ps1 -Serie` = 131 lancements ≈ 27 min (fps et `clic_dehors` journalisés) ; `capture_ville.ps1 -Serie` = 72 lancements ≈ 15 min. Les deux séries en une seule commande de fond.
- **Relancer un test plusieurs fois** (4-5) avant de croire un « vert » : `test_interface` dépendait de la graine de vie aléatoire de `principal._config()` (8 KO sur 9). Chercher `randi` / graine non fixée dans tout nouveau test qui instancie `principal.tscn`.
- Mon `test_recette_saut` (D4) : graine fixe par `Partie.nouvelle_partie(Donnees.config_demo(G))` entouré de `scene._ignorer_modales = true/false` puis `scene._apres_mise_en_place()`.
- Lignes à lire (02-I) : `UI saut anime=… gel=… badge_pause=…`, `UI courrier etat=… taille=… libelle=… dans_barre=…`, `UI badge n=k = non_lues=k`, `UI saut bilan arrets=… sans_modale=0 … vitesses_ecarts=0`, `UI tuiles taille_min`, `Capture : sauvegarde … capture_<pid>.sav`.
- Exe exporté depuis une copie isolée : il hérite du `custom_user_dir_name` (aucun risque pour le joueur). **2 ERROR `GrillePixel` (cadres.txt / icones.txt l. 1) préexistantes dans tout exe depuis 0.3** : ne pas les imputer au lot, mais les citer à CA-F5.
- Zones fragiles : `Hud.placer_etiquettes` (étiquette « MA MAISON » sous la flèche « ‹ LA GAZETTE » quand la maison est au bord gauche ; flèche de bord affichée pour un bâtiment pourtant à l'écran, seuil différent de celui des pièces) ; replis de la barre haute (variation, « COURANT », « EN PAUSE », libellé COURRIER : comparer chaque format à `main`) ; pastille VS LIVRET A dont couleur et chiffre roulant divergent ; captures de carnet prises pendant le retournement des tuiles (`scale.x`).
- Ajout des deux côtés d'un même rapport : copier l'autre version **à l'octet** (`cmd /c git show <branche>:<f> > f`, vérifier `git hash-object`) puis ajouter mes sections : conflit trivial à la fusion.

## 4 decies. 02-I passage 2 (recette 2026-11-09, `lot/02-interface` 41932b3 = fusion main + 02-V : OK, 3 mineures)
- Références : 580 vérifications avec `-Recette` ; `test_interface` 33, graine fixe 7, 10/10 vert ; `capture_interface.ps1 -Serie` = **136** lancements, 1 661 s ; `capture_ville.ps1 -Serie` 856 s ; `integrale` = `integrale_saut` = 160 749 F / 805,93 F / 11 ; `pieces_jeu` 2, 2, 3 puis 0 ; exe 110 239 912 octets.
- Lignes à lire : `UI barre format=… etat=pause|saut … replis=… manque_cc=`, `UI etiquettes balayage positions=… chevauchements=0 hors_libre=0 incoherences=0`, `UI pastille signe images=… incoherences=0`, `UI notifs historisees=… badge_pendant_vol=… badge_apres=…`, `UI timbre taille=`. Journaux complets : `godot/captures/px2_serie.log` et `px1_serie.log` (la sortie console de `capture_interface.ps1` ne garde que les lignes `[n/N] OK`).
- `test_rue` génération : 1,31-1,38 s machine libre, 2,0-2,2 s sous charge → seuil 2 s fragile ; ne jamais lancer `tests.ps1` pendant une série.
- Une recette interrompue (limite d'usage) : `partie_en_cours.sav` est apparu entre-temps (le joueur a joué) : noter date de création + journaux `user://logs` pour se disculper, puis empreinte avant / après chaque lancement.
- Les commandes > 180 s passent en tâche de fond : attendre par `Start-Sleep 170` + lecture du journal.

## 4 undecies. 03-L dividendes (recette 2026-11-12, `lot/03-logique` 2598896 : OK, 2 mineures ; rapport + test commités 6e4fe9c)
- Références : 584 vérifications (625 avec `-Recette`, dont mon `test_recette_dividendes` 12) ; `StrategieTest` graine 7 actif **172 139,25 F / 869,97 F / 11 / dividendes 360,43 F**, passif 145 655,67 F ; mai 1987 (5 000 F par titre en avril) : 532,27 F nets, impôt 101,39 F ; D5 −1 064,84 F (+163 F hors cours). **Capture `integrale` = `integrale_saut` après 03-L : 161 419 F / 805,93 F / 11** (main : 160 749 F) : partie différente de `StrategieTest` (graine 11, interface), ne jamais les comparer.
- Sauvegarde 0.4 réelle : `scratchpad\testeur_l03_sav.gd` (`-- ecrire <chemin> <date>` sur copie de main, `-- lire <chemin>` sur copie de la branche). **Un script `--script` qui plante (SCRIPT ERROR) ne quitte pas** et je ne peux pas tuer Godot : toujours `Start-Process … --quit-after 20000` + `WaitForExit`, et ne jamais appeler sur `main` une fonction de la branche.
- Comparer un test texte main / branche : sorties de `--script res://tests/<t>.gd` sur les deux copies, filtrer `\(\d+ ms\)`, `Compare-Object`.
- Zone fragile : relevé « Aucun intérêt … resté sur le compte courant » + phrase des dividendes (m1) ; notifications `dividende` / `dividende_nul` non relues à l'écran (03-I étape 2).

## 4 duodecies. 03-V (recette 2026-11-12, `lot/03-ville` c75a150 : KO, A1 majeure ; rapport commité ac03db0 sur la branche)
- Références : branche 567 (596 avec `-Recette`) ; fusion main + 03-L + 03-V : 641 avec recette ; `integrale` = `integrale_saut` = 161 419 F / 805,93 F / 11 ; `capture_ville.ps1 -Serie` = 75 lancements ≈ 910 s ; `test_rue` 1,3-1,6 s sous charge ; `-- --rue-relance` force la double mesure.
- Lignes à lire : `RUE pieces enseigne=… `, `RUE pieces piece=k pas_max=… pas_moyen=… regulier=`, `RUE flottant n=… hors_libre=`, `RUE pieces arc=`, `RUE pieces bascule …`, `RUE camera glissement/retour …`, `RUE pieces dividende=absent|present`.
- **Les dividendes (comme coupons et versements) arrivent à l'ENTRÉE du mois** (`_entrer_mois`, passage avril → mai) ; le flux d'un `mois_passe` = fin du mois écoulé + entrée du nouveau. Un scénario qui teste `ab_courant() - 1 == mai` rate le dividende (A1).
- Toujours regarder **l'image** d'une étape « preuve » : `pieces_dividende_jeu` capturait juin, rien à voir. Instrumenter **ma copie** (variables d'environnement `TESTEUR_*` dans le scénario) pour capturer à t + 0,7 / 1,0 / 1,4 / 1,7 s ; restaurer le fichier depuis le zip (`ZipFile.OpenRead` + `ExtractToFile`) avant la série.
- E6 : contre-épreuve rapide = `--export-pack Windows x.pck` de `main` puis `--main-pack x.pck --log-file …` (2 ERROR GrillePixel) ; exe de la branche : 0.
- Smart App Control actif (`Get-MpComputerStatus`.SmartAppControlState = On) : refus ponctuels d'exe non signés (journal `Microsoft-Windows-CodeIntegrity/Operational`, 3033/3077, stratégie {0283ac0f-…}) ; tester sans risque par `JeuClaude.exe --version`.
- Zones fragiles : cartouches superposés cuivre / or à la maison (≈ 0,2 s) ; cartouche « + 507 F » qui mélange intérêts de décembre et dividendes (mai) ; cartouche sous COMPTE sur le panneau INDICE au téléphone.
- **Passage 2 (de8fbf8 : OK, rapport commité 1537104)** : fusion `pieces_dividende_jeu` → `dividende=present lignes=Elf 119,99 F ; Saint-Gobain 101,70 F`, image MAI 1987, compte 9 819 F / patrimoine 80 515 F (branche seule : 9 598 / 80 220, `** ECHEC **` voulu). Depuis, **`capture_ville.ps1 -Serie` est rouge sans 03-L** : fusionner 03-L avant ou avec 03-V. Fusion : conflit add/add sur `lot_03_recette.md` (garder `--theirs` = version 03-V). Non-régression rapide = 18 lancements des étapes `pieces_*` + `camera_retour` ≈ 7 min (boucle en tâche de fond, journal par étape).
- `Start-Process -PassThru` + `WaitForExit(ms)` : `ExitCode` vide (piège PowerShell) ; vérifier l'import par la présence de `.godot\imported` et le journal.

## 4 terdecies. 03-foyer (recette 2026-11-12, `lot/03-foyer` 281b807 : OK, 4 mineures ; rapport + `test_recette_foyer` commités dde4ae5)
- Références : 635 sans recette, 676 avec, **695** avec `test_recette_foyer` (19) ; `test_cadence` 18 (13 sur main, sortie de main identique) ; cartes allumées 120 parties, moy. 9,44 ; C00 epargner 40/40, alterner 9/40, depenser 2/40 ; `integrale` = `integrale_saut` = 161 419 F inchangée.
- **Mesure indépendante de la cadence** : boucle qui OBSERVE `e.modale` à chaque mois (pas `interruptions_liste`), comparée ensuite à la liste ; dates imposées = motifs `scripte/historique/marche`, comparées à la même graine cartes éteintes. Seul « deux mois de suite » permis : `marche:p1e6 -> vie:voiture`.
- Script commun main / branche (`scratchpad\testeur_fo_commun.gd`) : ne JAMAIS citer une `class_name` de la branche (erreur de compilation sur main) ; passer par `has_method` / `get`. GDScript : `var x := <variable non typée>` = Parse Error (« Cannot infer ») → typer explicitement.
- Zone fragile pour la vague 3 : carte ouverte + achat pendant la carte → les deux choix désactivés → partie bloquée (`avancer` ne fait rien avec une modale ouverte). À revérifier à 03-I2 (la banque est-elle accessible pendant une carte ?).
- Cartes allumées : un coup dur aléatoire peut devenir simple notification (graines 20, 21) ; textes « pourquoi » non contrôlés par `test_foyer` (montant en dur C03).

## 4 quattuordecies. 03-I (recette 2026-11-12, `lot/03-interface` b9c1dc7 = fusion complète hors foyer : OK, 4 mineures ; rapport + `test_recette_fiche_dividendes` commités 295bc68)
- Références : 624 développeurs, 665 avec `-Recette`, 671 avec mon test (6) ; `capture_interface.ps1 -Serie` = **144** lancements, 1 785 s, code 0 sur copie neuve ; `integrale` = `integrale_saut` = 161 419 F / 805,93 F / 11 ; fiche Elf juin 1987 (partie des captures, graine `config_demo(-1)`, StrategieTest actif) = 11 Elf, 71,67 (mai 1986) + 119,99 (mai 1987) = 191,66 F → « 192 F ».
- Lignes à lire : `UI releve frais= manque= total=`, `UI bulle ancre=… vise= dans_libre=`, `UI bulle_haute`, `UI bulle_cachee`, `UI fiche dividendes=<écran> = logique=<…>`.
- **Exe neuf bloqué par Smart App Control** (Start-Process : « stratégie de contrôle d'application ») : ne pas contourner ; vérifier le paquet par le Godot signé `--main-pack <JeuClaude.exe>` (lit le pck intégré !) et `--export-pack`, `--log-file`. Le titre montre alors les raccourcis de test (binaire éditeur = debug) : normal.
- Rejouer une étape de capture en logique pure : `EtatPartie.new()` + `demarrer(Donnees.config_demo(-1))` + `resolution_auto()` (= `partir_de_la_rue`), puis `StrategieTest.jouer_mois` / `resolution_auto` / `avancer` mois par mois (= `aller_a`) : mêmes chiffres que la capture. Test en scène `.tscn` pour avoir les autoloads (`PanneauBanque`, `Hud` ne compilent pas en `--script`).
- Aucune étape ne montre `dividende_nul` : étape jetable `recette_nul` dans ma copie (Peugeot + Elf en avril 1986, ×1 jusqu'en mai). Zones fragiles : pile des notifications au téléphone (2 longues le même mois → la plus ancienne retirée sans être vue) ; textes de fiche qui « promettent » (divNul) ; montants des notifications en centimes vs texte arrondi.

## 5. Anomalies récurrentes / à surveiller
- Fichiers « recopiés de main » dans une branche (tests.ps1, trouver_godot.ps1 sur px0-ville) : vérifier `git diff main <branche> -- <fichier>` vide → sans conflit, mineur.
- Ce que le développeur marque « non vérifié » : le vérifier en priorité (lot 01 : `Jouer_Godot.bat` cassé sans variable).
- Contrôles automatiques au vert ≠ écran correct : à PX2, 61 lancements verts mais 3 défauts visibles à l'image (débordement de conteneur, police des chiffres, élément sous un panneau). Toujours relire chaque image et comparer à `main`.
- Polices `*.ttf.import` non suivies dans les worktrees : seul dev-interface PX0 les commite (CA-C1 de `lot_px0.md`) ; ailleurs, les signaler s'ils apparaissent dans un diff.

## 4 undecies. 03-R (recette 2026-11-13, `lot/03-retouches` 3367af2 : OK, 2 mineures)
- Références : 742 vérifications avec `-Recette` (725 sur `main`) ; `integrale` = `integrale_saut` = **161 419 F / 805,93 F / 11** (nouvelle référence depuis 03-L) ; graine 7 actif 172 139,25 F / 869,97 F / 360,43 F de dividendes, passif 145 655,67 F ; `test_cadence` comparé ligne à ligne à la base (copie isolée `git archive d306dec`) : identique.
- Mon `test_recette_dividendes` attend désormais 1 notification en mai 1986 (`nuls` Peugeot, ≤ 60 mots via `Banquier.nb_mots`) et le relevé cas 2.
- Étapes jetables `recette_r9*` dans `scenarios/banque.gd` d'une copie : notification de mai 1986 (Partie.mois_passe + capture à 1,8 s / 4 s) et relevé fabriqué (livret vidé, Elf achetée en avril 1986, `toucher_notif(jeu.dernier_releve)`).
- Exe par `--main-pack` : exécutable non-console `Godot_v4.7.2-stable_win64.exe` + `--log-file` + `-- --capture=<png avec /> --etape=titre|reprise`, `Start-Process -PassThru` + `WaitForExit`.
- Pire cas de notification de dividende = 60 mots pile : zone fragile (03-I2/04-L ne doivent rien ajouter aux gabarits).
- Les 2 Godot visibles d'autres lots : ne pas les tuer.
