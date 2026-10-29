# Lot 01 : recette (testeur)

## lot/01-logique — passage 1

- Date : 2026-10-29. Branche `lot/01-logique`, commit testé **6751074** (f8af755 + 6751074 sur a515796 ; `main` est à 020f8d4, écart sans code : plan PX0).
- Lieux : worktree du développeur `JeuClaude_lots\lot01-logique` (aucun fichier suivi modifié, HEAD inchangé) ; mutations dans un worktree jetable `JeuClaude_lots\recette-l9` (détaché, supprimé à la fin, rien commité).
- Sauvegarde du joueur `partie_en_cours.sav` : SHA-256 `A00EA7925D16…E380` avant et après toute la recette (identique) ; aucun `test_*.sav` restant dans `user://`.

### Verdict : **KO**

Une anomalie majeure (A1) : `Jouer_Godot.bat` ne lance plus le jeu dans le dépôt principal. Le reste du lot est solide ; la correction est petite (3 lignes du `.bat`).

### Anomalies

**A1 — majeure — `Jouer_Godot.bat` sans `JEUCLAUDE_GODOT` : erreur de syntaxe, le jeu ne se lance pas** (contraire au §2.3 : « sinon le chemin actuel (comportement inchangé dans le dépôt principal) »).
- Reproduire : copie du `.bat` de la branche où `start ""` est remplacé par `echo LANCE` (pour ne pas ouvrir le jeu), variable non définie, `cmd /c Jouer_Godot.bat`.
- Attendu : `LANCE "...\outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --path "...\godot"` (c'est ce que donne la version de `main`, vérifiée de la même façon).
- Constaté : `La syntaxe de la commande n'est pas correcte.`, code 255, rien n'est lancé. Trace (`@echo on`) : la ligne 8 `if defined JEUCLAUDE_GODOT if exist "%JEUCLAUDE_GODOT:_console.exe=.exe%" ...` est développée en `"_console.exe=.exeJEUCLAUDE_GODOT:_console.exe=.exe"` quand la variable n'existe pas (cmd développe `%VAR:a=b%` avant d'évaluer le `if defined`), ce qui casse toute la ligne et arrête le script.
- Avec la variable définie : correct (version sans console du même dossier choisie si elle existe, sinon le chemin de la variable).
- Piste (au développeur, via le chef de projet) : sauter les lignes de substitution quand la variable est absente (`if not defined JEUCLAUDE_GODOT goto :lancer`, puis `set "CANDIDAT=%JEUCLAUDE_GODOT:_console.exe=.exe%"` et `if exist "%CANDIDAT%" ...`), ou expansion retardée (`!JEUCLAUDE_GODOT:_console.exe=.exe!`). Le développeur avait signalé « Jouer_Godot.bat non vérifié ».

**A2 — mineure — `Exporter_Android.bat` inutilisable depuis un worktree.** Avec la variable, il échoue proprement (« ERREUR : JDK introuvable : ...\lot01-logique\outils\jdk-17 », code 1) car JDK et SDK sont cherchés dans `outils\` du dossier du `.bat`. Non exigé par le plan, documenté dans le `.bat` et le socle : à garder en tête (l'export Android se fait depuis le dépôt principal).

**A3 — mineure — `test_interface` lit deux variables privées de `PanneauBanque`** (`pb.get("_droite")`, `pb.get("_b_ok")`). Le §3.5 demande « fonctions publiques ou déjà appelées par `principal.gd` » (`_afficher_automatique` est bien appelée par `principal.gd`, les deux variables non). Conséquence : un simple renommage interne de la fenêtre Banque (refonte pixel art du lot 02) fera échouer `test_interface` sans que le contrat logique ↔ affichage soit rompu. À accepter en connaissance de cause, ou à remplacer par un accesseur public au lot 02.

**A4 — mineure — libellé trompeur dans `test_interface`** : « relevé de décembre affiché (frais de l'année : 869,97 F) » affiche `frais_total`, qui est le **cumul** des frais (`Banquier.releve` : `"frais_total": e.frais_payes()`), pas les frais de l'année (`frais_annee`). Le jeu est correct (HUD « frais payés » 870 F = même cumul) ; seul le texte de la vérification induit en erreur.

### Critères d'acceptation

- [x] **CA-L1** — Depuis le worktree (sans `outils\`), `tests.ps1` affiche « Godot : C:\...\JeuClaude\outils\...console.exe (dépôt principal du worktree) » et passe ; `capture.ps1 -Etape titre -Nom essai_wt` : code 0, `JeuClaude_lots\lot01-logique\godot\captures\essai_wt.png` écrit (1280 × 720), rien dans le dépôt principal. Capture relue : écran titre complet, net, aucune erreur.
- [~] **CA-L2** — Variable valide : utilisée et affichée en tête (« (variable JEUCLAUDE_GODOT) »), code 0. Variable inexistante : `tests.ps1` et `capture.ps1` affichent un message clair en 3 lignes, code 3, aucune trace d'exception. Dépôt principal sans variable : simulé (dossier du scratchpad avec une jonction `outils\` vers celui du dépôt) → `trouver_godot.ps1` choisit `outils\` du dépôt (« dépôt ») ; cas « introuvable » → message listant les 3 chemins, code 3. **Mais** `Jouer_Godot.bat` sans variable est cassé (A1).
- [x] **CA-L3** — Depuis le worktree avec `JEUCLAUDE_GODOT` : `Exporter_Windows.bat auto` → SUCCES, `JeuClaude_lots\lot01-logique\export\windows\JeuClaude.exe` (109 942 800 octets) ; l'exe du dépôt principal n'a pas bougé (27/10, 109 688 336 octets). Exe lancé avec `--log-file -- --capture --etape=titre` : code 0, capture écrite. Dépôt principal sans variable : **non lancé** (consigne) ; simulé dans le scratchpad (appels de Godot remplacés par `echo`) : bons chemins de Godot, du projet et de la sortie.
- [x] **CA-L4** — `tests.ps1` : import propre (5,5 s) + test_demo 107, test_interface 21, test_logique 66, test_partie 8 = **202 vérifications** (≥ 174 + 28 nouvelles), 0 KO, 0 erreur de script, résumé par test, **23,7 s** (< 90 s). Options vérifiées : `-SansImport`, `-Filtre`, `-Recette` (un test jetable de `tests/recette/` découvert seulement avec l'option), `-Delai 8` (test qui ne quitte jamais : arrêté à 8 s, « ÉCHEC (délai) », code 1), aucun test trouvé → message et code 1.
- [x] **CA-L5** — `tests.ps1 -Autocontrole` : erreur volontaire (code de sortie 0 du test) détectée, lignes fautives réaffichées, « AUTOCONTRÔLE RÉUSSI », code 0.
- [x] **CA-L6** — test_demo : 20 graines sans faillite, au moins 7 produits détenus (**minimum 7 : à la limite**, voir zone fragile) ; `aller_a(1986-03)` = mars 1986 (actif et passif) ; `aller_a_modale("p1e6", actif)` = octobre 1987, modale non résolue ; `aller_a_modale("D02", passif)` = juillet 1984 ; id inconnu → false, 30 ms ; au-delà de la démo → fin en décembre 1988. Relecture de code : `jouer_mois` / `aller_a` / `aller_a_modale` reproduisent `principal.gd` l. 1425-1493, à l'écart annoncé près.
- [x] **CA-L7** — Aucun `test_*.sav` après `tests.ps1` ; empreinte de `partie_en_cours.sav` identique (contrôlée par `tests.ps1` et par moi). Deux `tests.ps1 -Filtre test_demo` lancés **en même temps** : tous deux verts, aucun reste.
- [x] **CA-L8** — `test_interface` : code 0, 21 vérifications, aucune erreur de script, 5,4 s (≤ 60 s). Couvre a) écran titre (bouton JOUER, HUD caché, aucune sauvegarde écrite), b) démo complète actif puis passif (HUD chaque mois et chiffres = état, 8 appels / 2 courriers / 1 journal par la fonction de leur genre, choix rangés dans l'historique, Banque sur 7 produits en déc. 1986 et juin 1988, historique 4 filtres + 5 relectures, relevé, écran de fin).
- [x] **CA-L9** — Mutations dans le worktree jetable, chacune annulée avant la suivante :
  | Mutation | Résultat de `tests.ps1` |
  |---|---|
  | M1 `vie_en_attente` renommée (définition + appel l. 292) | code 1 ; **test_interface** : « Nonexistent function 'vie_en_attente' … Hud.maj (hud.gd:621) » ; import et autres tests propres |
  | M2 `e.hist["mis"]` → clé inexistante (hud.gd l. 622) | code 1 ; **test_interface** : « Invalid access … 'mis_inexistant' … Hud.maj (hud.gd:622) » |
  | M3 `e.banque["presentes"]` → clé inexistante (panneau_banque.gd l. 253) | code 1 ; **test_interface** (fiches KO) et **test_partie** (pourtant code 0) : « Invalid access … 'presentes_x' » |
  | M4 (ajout testeur) erreur de syntaxe dans modales.gd | code 1 ; « Parse Error … Could not parse global class "Modales" » |
  | M5 (ajout testeur) clé faussée dans `Modales.courrier` (l. 472) | code 1 ; « Invalid access … 'montant_x' … Modales.courrier » |
  | M6 (ajout testeur) fonction faussée dans `Modales.fin_demo` (l. 1070) | code 1 ; « Parse Error … modales.gd:1070 » |
  Sans `test_interface`, M1 et M2 passaient inaperçues (les 3 autres tests restent verts) : le test remplit son rôle.

### Périmètre (`git diff main...lot/01-logique --stat`)
16 fichiers, tous attribués à dev-logique au §1 (+ `.uid` des 3 nouveaux scripts) : 3 `.bat`, `capture.ps1`, `tests.ps1`, `trouver_godot.ps1`, `strategie_test.gd`, `test_interface.gd/.tscn`, `autocontrole/erreur_volontaire.gd`, `test_demo.gd`, `dev-logique.md`, `developpeur.md`. Aucun fichier interdit (logique hors `strategie_test.gd`, données, hud, modales, panneau_banque, export_presets, .gitignore), aucun fichier temporaire ni capture. Encodage : `.ps1` en UTF-8 avec BOM + CRLF, `.bat` en CRLF (attribut `eol=crlf`).

### Non-régression
- Aucun script du jeu ni donnée modifiés par la branche (diff) : comportement du jeu inchangé par construction.
- Étape `integrale` (partie automatique complète, worktree jetable) : code 0, « modales vues { appel 8, banque 4, courrier 2, journal 1, fin 1 }, fin = fin, décembre 1988, patrimoine 156 645 F, 11 interruptions, frais 273,60 F, 168 s à ×3 ». Capture de fin relue : HUD (156 645 F, « vs tout au Livret A −6 486 F ») cohérent avec la pastille de l'écran de fin (« 6 486 F de moins que Tata Livret ») ; le montant et les barres de l'écran de fin étaient en cours d'animation de comptage au moment de la capture (partent de 0), ce n'est pas un écart.
- Retours du joueur (docs/10) : rien de touché (rythme, clic à côté, comparaison Livret A, historique, sauvegarde) ; tests correspondants verts.

### Avis sur les écarts annoncés par le développeur
1. **CA-L9 inexact (hud.gd ne lit pas `e.banque`)** : confirmé par recherche. Substitution acceptable (`e.hist["mis"]` dans hud.gd, `e.banque["presentes"]` dans panneau_banque.gd) ; exécutée, plus 3 mutations de ma part. Le plan est à corriger pour la recette sur `main`.
2. **`StrategieTest` ≠ copie identique (plancher 2 500 F puisé dans le Livret A avant un achat)** : acceptable, documenté dans le fichier et dans `dev-logique.md`, indispensable pour tenir CA-L6. Point d'attention pour le lot 02 (T13) : quand les captures passeront sur `StrategieTest`, leurs parties pourront différer de `main` sur les graines où le plancher joue (le développeur affirme : jamais avec la graine des captures ; non vérifié par moi).
3. **`trouver_godot.ps1` ne fait pas `exit 3`** : acceptable. Vérifié sur un exemple minimal : sous PowerShell 5.1, `exit` dans un script inclus par point ne quitte pas l'appelant. Résultat final conforme (code 3 de `tests.ps1` et `capture.ps1`).
4. **Non vérifiés par le développeur** : `Jouer_Godot.bat` → vérifié par moi, **cassé** (A1) ; `Exporter_Windows.bat` dans le dépôt principal → simulé, correct ; `Exporter_Android.bat` depuis un worktree → échec propre (A2).

### Signalements hors périmètre (préexistants, pas dus à la branche)
- H1 — `modales.gd` l. 589 (signalé par le développeur) : fermer un courrier pendant le vol de l'enveloppe (0,5 s) → SCRIPT ERROR (la lambda capture `p`, déjà libérée). Le développeur le juge inatteignable par un joueur ; **à mon avis il l'est probablement** : en relecture depuis l'historique (genre « info »), la touche Échap ferme la modale (`modales.gd` l. 144-148) et l'enveloppe vole aussi. Non reproduit (pas de pilotage d'entrées réelles dans cette recette) ; à faire vérifier.
- H2 — Fichiers `godot/polices/**/*.ttf.import` non suivis par Git dans les worktrees (polices ajoutées en a515796 sans leurs `.import`) : à commiter sur `main` (ou décider), sinon chaque worktree les régénère et un développeur risque de les commiter hors périmètre.
- H3 — Écran titre : « MA RUE, DE 1978 À AUJOURD'HUI » alors que la démo commence en 1984 (sous-titre « Démonstration · janvier 1984 → décembre 1988 » juste dessous). Probablement voulu (titre du jeu complet), à confirmer par le chef de projet.

### Remarques (pas des anomalies)
- Le motif d'erreurs de `tests.ps1` ne contient pas les lignes moteur `ERROR:` génériques (ex. « Failed to load resource ») ; les sorties actuelles n'en contiennent aucune, on pourrait l'ajouter plus tard.
- Laissés dans le worktree du développeur (fichiers ignorés par Git) : `godot\captures\essai_wt.png` (CA-L1) et `export\windows\JeuClaude.exe` (CA-L3).
- `user://capture.sav` est commun à tous les worktrees : des captures lancées en même temps par plusieurs agents peuvent se gêner (non observé).

### Non vérifié
- Lancement réel de `Jouer_Godot.bat` (vérifié à sec seulement, pour ne pas ouvrir le jeu sur la partie du joueur) ; export Windows réel depuis le dépôt principal (consigne) ; export et APK Android ; rendu téléphone (la branche ne touche aucun écran : seule la capture `titre` PC a été relue, plus celle de la fin de l'intégrale).

## lot/01-logique — passage 2

- Date : 2026-10-29. Branche `lot/01-logique`, commit testé **00c4821** (sur 6751074). Référence : `docs/lots/lot_01.md` § « Corrections — passage 2 » (CA-P2-1 à CA-P2-4).
- Lieux : worktree du développeur (rien de suivi modifié, HEAD = 00c4821) ; mutations dans un worktree jetable `recette-p2` (supprimé, rien commité) ; essais à sec dans le scratchpad.
- Sauvegarde du joueur : SHA-256 `A00EA7925D16…E380` inchangée ; aucun `test_*.sav` restant.

### Verdict : **OK**

A1 et A4 sont corrigés, A3 échoue désormais de façon lisible. Aucune nouvelle anomalie.

### Critères du passage 2
- [x] **CA-P2-1 (A1)** — Le commit change 3 fichiers : `Jouer_Godot.bat`, `test_interface.gd` et `dev-logique.md`. Le `.bat` saute désormais la substitution par `if not defined JEUCLAUDE_GODOT goto lancer`. Fichier en CRLF (14 lignes, aucun LF seul). Copie à sec (`start ""` → `echo LANCE`, lancée par `cmd /c`) :
  - (a) sans variable : `LANCE "<racine>\outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --path "<racine>\godot"`, code 0 ;
  - (b) variable vers la version console du dépôt principal : version sans console du même dossier choisie, code 0 ;
  - (c) variable vers un `..._console.exe` sans version sans console à côté : chemin de la variable, code 0.
  `Exporter_Windows.bat` et `Exporter_Android.bat` : aucune substitution `%VAR:…%` (recherche de texte).
- [x] **CA-P2-2 (A4)** — Sortie de `test_interface` : « joueur actif : relevé de décembre affiché (frais payés depuis le début (cumul) : 869,97 F) ».
- [x] **CA-P2-3 (A3)** — Commentaire « Accès interne à PanneauBanque, toléré au lot 01 ; … (T15) » présent. Mutations jetables dans `panneau_banque.gd` :
  - `_droite` → `_droite_x` (43 occurrences) : `test_interface` KO, détail « PanneauBanque : champ interne _droite introuvable (renommé ?), voir T15 », **0 erreur de script**, code 1 ;
  - `_b_ok` → `_b_ok_x` (13 occurrences, mon ajout pour la seconde branche du garde-fou) : même résultat avec « _b_ok introuvable ».
- [x] **CA-P2-4** — `tests.ps1` : import propre + 107 / 21 / 66 / 8 = **202 OK**, 0 KO, 0 erreur de script, 23,6 s, « TOUT EST PROPRE ». `-Autocontrole` : réussi, code 0. Diff `main...lot/01-logique` : les mêmes 16 fichiers du §1 ; aucun `.ttf.import`, aucune capture, aucun exe ; les `*.ttf.import` restent non suivis dans le worktree. Aucun fichier en commun avec ce que `main` a reçu depuis a515796 (PX0, maintenant 2d73585) : pas de conflit de fusion attendu.

### Non-régression
- Aucun script du jeu ni donnée touchés par 00c4821 : les acquis du passage 1 (CA-L1 à CA-L9, intégrale) restent valables. Je n'ai pas relancé l'intégrale (non exigé).

### Remarque (mineure, sans effet sur le verdict)
- Quand le garde-fou se déclenche, le détail compte « produits : 1 » : le produit en cours (« livret ») est ajouté à la liste avant le `break`. C'est seulement cosmétique : la vérification est bien KO et le message est clair.

### Non vérifié
- Lancement réel de `Jouer_Godot.bat` (essai à sec seulement, pour ne pas ouvrir le jeu sur la partie du joueur).

## lot/01-interface — passage 1

- Date : 2026-10-29. Branche `lot/01-interface`, commit testé **261d373** (un seul commit sur a515796 ; `main` est à 2d73585, reçu depuis : 4 fichiers de `docs/` seulement, aucun en commun avec la branche ; `git merge-tree` main / branche et lot/01-logique (00c4821) / branche : sans conflit).
- Lieux : worktree du développeur (HEAD inchangé, aucun fichier suivi modifié ; seuls des fichiers ignorés ou non suivis préexistants : `*.ttf.import`, `.godot/`) ; **copies isolées** dans le scratchpad (`git archive` de a515796 = `main` de référence, de 261d373 = branche, et d'une **fusion simulée** logique 00c4821 + interface), chacune avec un `user://` à part (`config/use_custom_user_dir`) pour ne gêner ni la partie du joueur ni l'autre recette.
- Sauvegarde du joueur `partie_en_cours.sav` : SHA-256 `A00EA7925D16…E380` avant et après toute la recette (identique, y compris après l'exe) ; aucun `test_*.sav` restant.

### Verdict : **OK**

Aucune anomalie bloquante ni majeure. Le découpage ne change ni le comportement ni le rendu (comparaison complète avec `main`), les raccourcis de test sont absents de la version du joueur (éditeur `--joueur` et exe exporté), et la scène découpée passe le `test_interface` de l'autre branche une fois les deux fusionnées. Trois mineures, toutes préexistantes ou hors du périmètre attribué.

### Anomalies (mineures, aucune due à la branche)

**B1 — mineure, préexistante (HUD, `hud.gd` interdit) — graduations de « Mon argent » recouvertes en début de partie.** Le développeur demandait si c'est préexistant : **oui**, et ce n'est pas lié au saut de temps.
- Reproduire : capture `jumeaux` (mai 1984) sur `main` a515796 ; même chose sur la branche, capture `raccourcis` (octobre 1984, après F8 et triple toucher).
- Attendu : libellés « 25 000 F / 18 750 F / 12 500 F / 6 250 F » lisibles.
- Constaté (identique sur `main` et la branche) : tant que l'historique fait quelques mois, la courbe et l'étiquette d'écart « = 0 F » sont dessinées dans la colonne des libellés (« 18 750 F » et « 12 500 F » barrés par la courbe et l'étiquette). Plus tard (≥ 1986) le défaut disparaît (captures `comparaison`, `crash_anim`). Captures : `cap_ref_main\jumeaux.png`, développeur `captures\branche\raccourcis.png`. À traiter au lot 02 (HUD).

**B2 — mineure, hors périmètre — commentaire périmé** : `scripts/ville/accessoire.gd` l. 2 « animés par les séquences de principal.gd » (c'est maintenant `Sequences`). Fichier non attribué au lot 01 : à corriger au lot 02.

**B3 — mineure, préexistante — `principal._info()` n'est appelée nulle part**, déjà le cas sur `main` (l. 1051). Code mort à retirer au prochain passage sur `principal.gd`.

### Critères d'acceptation

- [x] **CA-I1** — `principal.gd` : **585 lignes** (≤ 600 ; 1 611 sur `main`, le « 1 464 » du plan était inexact). Nouveaux fichiers : `sequences.gd` 516, `scenarios_capture.gd` 203, `outils.gd` 185, `ecrans.gd` 129, `ecran_titre.gd` 107, `banque.gd` 65, `ville.gd` 62, `titre.gd` 52, `raccourcis_test.gd` 41, `reglages.gd` 14 (tous ≤ 700). Recherche de texte dans `principal.gd` : ni `KEY_F6/F7/F8`, ni construction du titre, ni animation de séquence, ni étape de capture ; `preparer_capture` = 4 lignes de délégation. `EcranTitre` ne référence pas `Partie` (signaux `jouer_demande`, `nouvelle_partie_demandee`). `Reglages.raccourcis_test()` conforme mot pour mot au §2.1.
- [x] **CA-I2** — Les **53 étapes** de `capture.ps1` lancées sur la branche **et** sur `main` (106 lancements + 8 en téléphone) : toutes code 0, **aucune** ligne `SCRIPT ERROR`, `Parse Error`, `ERROR`, `WARNING`, `Invalid …` dans stdout/stderr. Sorties texte identiques à `main` pour les 53 étapes (seuls écarts : mesures `fps` 262,8 / 265,2 et `trafic` 744 / 745 u/s). Comparaison pixel (1 pixel sur 4, seuil 40) des 53 paires PC : 0,00 % à 0,80 % de pixels différents (passants, voitures, tweens), sauf `titre` 3,0 % (caméra décalée de 1-2 px pendant la plongée) et `clic_dehors` 5,9 % (journal en cours d'inclinaison) ; ces deux paires, et `crash_anim`, `comparaison`, `jumeaux`, relues à l'œil : identiques. Téléphone `titre`, `heritage`, `historique`, `krach` : 0,00 % à 0,21 %, relues (ticket de l'héritage, historique, titre : pas de débordement).
- [x] **CA-I3** — `integrale` branche et `main`, même résultat à l'identique : « modales vues { appel 8, banque 4, courrier 2, journal 1, fin 1 }, fin = fin, décembre 1988, patrimoine 156 645 F, 11 interruptions, frais 273,60 F, 168 s à ×3 ». `sauver_fermer` puis `reprise` : « Fermeture : sauvegarde écrite, juillet 1984, modale en attente D02, patrimoine 17 228 F » ; « Titre : bouton CONTINUER, Partie en cours : Gérard · juillet 1984 · patrimoine 17 228 F » ; « Reprise : juillet 1984, modale D02, cc 17 228 F » — identiques à `main`.
- [x] **CA-I4** — Les 3 tests de la branche lancés dans le worktree du développeur (Godot par chemin absolu) : import propre, 66 + 100 + 8 OK, 0 KO, 0 erreur de script, 17 s. **Fusion simulée** (logique 00c4821 + interface) : 66 + 107 + 8 + **`test_interface` 21 OK** (la scène principale découpée s'instancie, écran titre, libération propre), 0 erreur de script : le risque « si `test_interface` échoue sur `main` à cause du découpage » (§4) ne se réalise pas.
- [x] **CA-I5** — Éditeur sans option, étape `raccourcis` : `raccourcis_test=vrai` ; F8 mars 1984 → juillet 1984 ; triple toucher sur la date (fenêtre (101, 32)) juillet → octobre 1984 ; F6 enfants 0 → 1 (carte de naissance) ; F10 PC → téléphone (1280×720 → 1200×540). Capture `titre` PC : ligne d'aide « F10 : format téléphone · F8 … » présente.
- [x] **CA-I6** — Éditeur `-- --joueur` : `raccourcis_test=faux` ; F8 et triple toucher : mars 1984 → mars 1984 ; F6 : 0 → 0 ; F10 : PC → PC. Touches de jeu toujours actives : 2 → vitesse 2, Espace → 0, M → banque ouverte, H → historique ouvert. Capture `titre` sans la ligne d'aide (le reste de l'image identique).
- [x] **CA-I7** — Exe exporté par moi depuis le worktree (`--export-release "Windows"`, 109 959 504 octets, dans le scratchpad) : `--etape=raccourcis` → mêmes lignes qu'en CA-I6 (`raccourcis_test=faux`, rien ne bouge, touches de jeu actives) ; `--etape=titre` → pas de ligne d'aide (image relue). APK : même chemin de code (tag `template`), **non vérifiable sans téléphone**.

### Appels dynamiques via `jeu: Node` (risque signalé par le développeur)
- Recensement de **toutes** les références `jeu.<membre>` (`sequences.gd`, `raccourcis_test.gd`, `scenarios_capture.gd`, 5 familles) : 22 membres distincts (`demo ville hud modales titre sequences en_titre pluie_jusqua dernier_releve nouvelle_partie reprendre demarrer_direct jouer demander_nouvelle_partie maj_titre ouvrir_banque ouvrir_historique ouvrir_menu expliquer_comparaison toucher_batiment toucher_notif notification`) : **tous existent** dans `principal.gd` avec des signatures compatibles. Aucun autre script (HUD, modales, tests) n'appelle un ancien nom (`_ouvrir_banque`, `_occupe`, `_bouton_jouer`, etc.).
- Relecture par différence normalisée (anciens noms remplacés par les nouveaux) : `sequences.gd` = `principal.gd` de `main` l. 537-990 à l'identique (seuls déplacements : `_relire` resté dans `principal.gd`, constantes `ROSE` / `BLEU`) ; reste de `principal.gd` identique hormis les délégations. Scénarios de capture : copie fidèle (y compris la stratégie active).
- Chemins que les captures n'empruntent pas, couverts par un **test de recette à moi** (copie isolée, lancé avec et sans `--joueur`, 11 OK / 0 KO chaque fois) : `RaccourcisTest` créé et triple toucher relié **seulement** si `raccourcis_test` ; ligne d'aide idem ; `jouer` → carte du Livret A ; journal du krach « soldes » → `Sequences` rappelle `jeu.ouvrir_banque` (fenêtre Banque ouverte), puis plus de vedette et temps débloqué ; menu → historique ; abandon → écran de fin → « Rejouer autrement » → `jeu.nouvelle_partie` + `jeu.demarrer_direct` (nouvelle partie dans la rue, carte du Livret A revenue). Fichier : `godot/tests/recette/test_recette_decoupage.gd/.tscn` dans ma copie (scratchpad) ; à déposer dans `godot/tests/recette/` de `main` après fusion (il utilise `RaccourcisTest` / `EcranTitre`), sur décision du chef de projet.

### Périmètre (`git diff main...lot/01-interface --stat`)
24 fichiers, tous attribués à dev-interface au §1 : `principal.gd`, `ecran.gd` (2 lignes : F10 soumis au réglage + commentaire), `project.godot` (section `[jeuclaude]` `raccourcis_test=true`, rien d'autre), `ui/ecran_titre.gd`, `ville/sequences.gd`, `outils/raccourcis_test.gd`, `outils/reglages.gd`, `outils/scenarios_capture.gd`, `outils/scenarios/{banque,ecrans,outils,titre,ville}.gd` (sans `class_name`), les 10 `.uid` correspondants, `dev-interface.md`. Ni `capture.gd` ni `principal.tscn` touchés (non nécessaires). Aucun fichier interdit, aucun `*.ttf.import`, aucune capture, aucun exe. Message de commit en français.

### Non-régression (docs/10)
- Partie complète identique à `main` (CA-I3). Clic à côté : `clic_dehors` identique à `main` (foyer, nouvelles, banque, menu, carte du banquier fermés ; clic dedans et journal du krach : restent ouverts). Comparaison Livret A (`comparaison`, `comparaison_info` : « +3 390 F (vous 151 005 F, Tata Livret 147 615 F) »), historique (5 étapes), sauvegarde / reprise, relevé, versements automatiques, PEL (« 6,30 % + prime d'État ≈ 8,25 % »), rythme et trafic (`trafic` identique) : sorties et images identiques à `main`.
- Cohérence des chiffres relue sur l'écran de fin : 172 556 F − 163 131 F = 9 425 F (pastille, courbe et citation) ; frais 779 F identiques au HUD.

### Remarques (pas des anomalies)
- `capture.ps1` (fichier de dev-logique au lot 01) ne liste pas l'étape `raccourcis` et n'a pas d'option pour `--joueur` : pour la recette sur `main` (§4), passer par la commande Godot directe (`-- --capture=… --etape=raccourcis --joueur`). À ajouter au lot 02.
- En format téléphone **simulé sur PC** (F10 / `--telephone`), la ligne d'aide reste visible : normal (`mobile` absent sur PC), comme sur `main`.
- Le premier `--import` d'une copie neuve du projet a planté une fois (code −1073741819) puis a réussi : bruit de Godot, pas du projet.

### Non vérifié
- Vrai téléphone (APK : absence des raccourcis, triple toucher) ; ressenti en mouvement (seules des images fixes et des journaux) ; lancement réel de l'exe sans `--capture` sur la vraie sauvegarde du joueur (évité : il afficherait « Continuer » sur sa partie).
