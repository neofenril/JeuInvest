# Lot 01 : socle technique (raccourcis de test, découpage de principal.gd, worktrees, test de l'interface)

- Origine : décision du joueur du 2026-10-29 (docs/10 : « on conserve les deux idées » du chef de projet) ; backlog T1, T3, T8 (`docs/connaissances/chef-de-projet.md`). Préalable aux lots du game design V3 (docs/14 : P1-P6, P9, P10 ; spécification docs/15 en cours).
- Objectif : (1) la version du joueur (exe, APK) n'a plus aucun raccourci de test : ni aide F10/F8/F6 sur l'écran titre, ni F6/F7/F8/F10, ni **triple toucher sur la date qui saute le temps** ; (2) `principal.gd` (1 464 lignes) est découpé pour que plusieurs développeurs puissent travailler en même temps ; (3) les scripts de test et de capture marchent depuis un worktree Git ; (4) un test automatique charge l'interface sans écran et fait échouer `tests.ps1` à la moindre erreur de script (rupture du contrat logique ↔ affichage).
- Ce que le joueur verra : rien de neuf, sinon l'écran titre sans la ligne « F10 : format téléphone · F8 … » et plus de saut de temps par un triple toucher. **Aucun changement de comportement du jeu** : c'est le critère principal.
- Hors périmètre : toute fonctionnalité de docs/14 ; découpage de `modales.gd` et `etat_partie.gd` (lots suivants) ; changement de version / nouvel export pour le joueur (fait à la fin du lot 02) ; `banque.json` ; APK de publication.
- Mode : **parallèle**, deux worktrees, aucun fichier commun (tableau ci-dessous).
- Base : `main` à jour, **après** commit par le coordinateur de ce plan et de `docs/10_retours_joueur.md` (sinon les worktrees ne les voient pas).

## 0. Mise en place (coordinateur)

```powershell
$git = "C:\Users\arthu\Documents\temp\JeuClaude\outils\git\cmd\git.exe"
& $git -C C:\Users\arthu\Documents\temp\JeuClaude worktree add -b lot/01-logique   C:\Users\arthu\Documents\temp\JeuClaude_lots\lot01-logique   main
& $git -C C:\Users\arthu\Documents\temp\JeuClaude worktree add -b lot/01-interface C:\Users\arthu\Documents\temp\JeuClaude_lots\lot01-interface main
```

- Chaque développeur travaille **uniquement** dans son worktree (jamais dans `C:\Users\arthu\Documents\temp\JeuClaude`), commite en local sur sa branche, ne pousse pas.
- Godot n'existe que dans le dépôt principal (`outils\` n'est pas versionné). Pendant ce lot, tant que la branche logique n'est pas fusionnée, lancer Godot **par son chemin absolu** :
  `& "C:\Users\arthu\Documents\temp\JeuClaude\outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path <worktree>\godot --import` (puis les 3 tests, ou `--path <worktree>\godot --resolution 1280x720 -- --capture=captures/x.png --etape=y [--telephone]`).
- Chaque worktree a son propre cache `godot\.godot\` (premier `--import` ≈ 5 s) : plus de risque d'import simultané. En revanche, `user://` (`%APPDATA%\Godot\app_userdata\JeuClaude`) est **commun** à tous les worktrees, à l'éditeur et à l'exe : ne jamais effacer `partie_en_cours.sav` (partie du joueur) ; tant que CA-L7 n'est pas fusionné, ne pas lancer `test_demo` dans deux worktrees à la même seconde.
- Ordre de fusion conseillé : `lot/01-logique` puis `lot/01-interface` (aucun conflit attendu : fichiers disjoints). Après les deux fusions, je relance tout sur `main` (§ Vérifications).

## 1. Fichiers attribués (tout fichier absent de ce tableau est interdit)

Chemins relatifs à la racine du dépôt. Les fichiers `.uid` générés pour un nouveau script sont commités avec lui, par son propriétaire.

| Fichier | Propriétaire | Nature du changement |
|---|---|---|
| `godot/outils/trouver_godot.ps1` | dev-logique | **Nouveau** : localisation de Godot (§2.3) |
| `godot/outils/tests.ps1` | dev-logique | Worktree, import systématique, découverte des tests, détection des erreurs de script |
| `godot/outils/capture.ps1` | **dev-logique (pour ce lot seulement)** | Seulement la localisation de Godot (via `trouver_godot.ps1`) ; arguments et liste d'étapes inchangés |
| `Exporter_Windows.bat`, `Exporter_Android.bat`, `Jouer_Godot.bat` | dev-logique | Variable `JEUCLAUDE_GODOT` (§2.3) |
| `godot/scripts/logique/strategie_test.gd` | dev-logique | **Nouveau** : `StrategieTest` (§2.2) |
| `godot/tests/test_interface.gd`, `godot/tests/test_interface.tscn` | dev-logique | **Nouveaux** : test de fumée de l'interface |
| `godot/tests/autocontrole/erreur_volontaire.gd` | dev-logique | **Nouveau** : script fautif volontaire pour `tests.ps1 -Autocontrole` |
| `godot/tests/test_demo.gd` | dev-logique | Fichiers `user://` uniques par processus et effacés ; tests de `StrategieTest` |
| `docs/connaissances/dev-logique.md`, `docs/connaissances/developpeur.md` (socle) | dev-logique | Bases de connaissances (le socle : commandes, worktrees, tests) |
| `godot/scripts/principal.gd` | dev-interface | Découpage (§3) |
| `godot/scripts/ui/ecran_titre.gd` | dev-interface | **Nouveau** : `EcranTitre` |
| `godot/scripts/ville/sequences.gd` | dev-interface | **Nouveau** : `Sequences` |
| `godot/scripts/outils/raccourcis_test.gd` | dev-interface | **Nouveau** : `RaccourcisTest` |
| `godot/scripts/outils/reglages.gd` | dev-interface | **Nouveau** : `Reglages` (§2.1) |
| `godot/scripts/outils/scenarios_capture.gd` + `godot/scripts/outils/scenarios/*.gd` | dev-interface | **Nouveaux** : scénarios de capture (§3) |
| `godot/scripts/outils/capture.gd` | dev-interface | Seulement si l'appel de `preparer_capture` doit changer |
| `godot/scripts/ecran.gd` | dev-interface | F10 soumis à `Reglages.raccourcis_test()` |
| `godot/project.godot` | dev-interface | Réglage `jeuclaude/raccourcis_test=true` ; rien d'autre |
| `godot/scenes/principal.tscn` | dev-interface | Seulement si nécessaire |
| `docs/connaissances/dev-interface.md` | dev-interface | Base de connaissances (structure après découpage) |

**Interdits aux deux** : `scripts/logique/*` (sauf `strategie_test.gd`), `scripts/partie.gd`, `data/*`, `scripts/ui/hud.gd`, `modales.gd`, `panneau_banque.gd`, `date_volets.gd`, `export_presets.cfg`, `.gitignore`, `CLAUDE.md`, `docs/` hors bases citées. Si un changement y semble nécessaire : le décrire dans le compte rendu, ne pas le faire.

## 2. Interfaces (fixées avant le lancement)

### 2.1 Réglage des raccourcis de test (dev-interface)
- `project.godot`, nouvelle section : `[jeuclaude]` `raccourcis_test=true`.
- `scripts/outils/reglages.gd`, `class_name Reglages`, `extends RefCounted`, sans état :
  ```gdscript
  ## Vrai seulement dans l'éditeur / en ligne de commande (développement, tests, captures).
  static func raccourcis_test() -> bool:
      if OS.has_feature("template"):            # toute version exportée : exe, APK (même en debug)
          return false
      if "--joueur" in OS.get_cmdline_user_args():   # simuler la version du joueur depuis l'éditeur
          return false
      return bool(ProjectSettings.get_setting("jeuclaude/raccourcis_test", true))
  ```
  (`OS.is_debug_build()` ne suffit pas : l'APK est exporté en debug. Le tag `template` est présent dans toute version exportée, debug ou release, sans dépendre d'un réglage des préréglages d'export.)
- Gouverné par ce réglage : ligne d'aide de l'écran titre, F6 / F7 (naissance, jumeaux), F8 (moment suivant), **triple toucher sur la date** (`Hud.raccourci_demo`, connecté seulement si vrai), F10 (`Ecran`). **Pas gouverné** : les touches de jeu (Espace / P, 1-3, M / B, H), l'autoload `Capture` (inactif sans `--capture`, nécessaire pour vérifier l'exe), `Partie.forcer_naissance` / `sauter_jusqu_a` (API, inchangées).

### 2.2 `StrategieTest` (dev-logique), `scripts/logique/strategie_test.gd`
`class_name StrategieTest`, `extends RefCounted`, fonctions statiques, sans nœud. Reprend **à l'identique** la logique de `principal.gd` (`_strategie_active` l. 1425, `_aller_a` l. 1457, `_aller_a_modale` l. 1473), sans le rafraîchissement de l'interface :
```gdscript
static func jouer_mois(e: EtatPartie, actif: bool) -> void          # résout la modale en attente (actif : ouvre et achète, vend face à un gros courrier ; passif : resolution_auto), puis rééquilibre compte / Livret A (actif)
static func aller_a(e: EtatPartie, ab: int, actif: bool) -> void     # avance sans animation jusqu'au mois absolu ab (garde 100 mois)
static func aller_a_modale(e: EtatPartie, id: String, actif: bool) -> bool   # s'arrête modale « id » ouverte (présentation Dxx, p1e6, voiture, naissance…) ; false si non trouvée
```
Usage en lot 01 : `test_interface` et `test_demo`. **Les scénarios de capture gardent leur propre copie pendant ce lot** (fichiers disjoints) ; ils passeront sur `StrategieTest` au lot 02 (backlog T13).

### 2.3 Localisation de Godot (dev-logique), `godot/outils/trouver_godot.ps1`
Script inclus par point (`. (Join-Path $PSScriptRoot "trouver_godot.ps1")`) qui définit `$godot` (console) et `$godotFenetre` (exe sans console, pour `Jouer_Godot.bat` s'il en a besoin), dans cet ordre :
1. `$env:JEUCLAUDE_GODOT` s'il est défini ; s'il pointe vers un fichier inexistant : **erreur explicite** (pas de repli silencieux) ;
2. `<racine du dépôt>\outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe` ;
3. worktree : `<racine>\.git` est un **fichier** `gitdir: <dépôt principal>/.git/worktrees/<nom>` → dépôt principal = ce qui précède `/.git/worktrees/` → `<dépôt principal>\outils\…` (lecture du fichier en PowerShell pur : Git n'est pas dans le PATH) ;
4. sinon : message en français listant les 3 chemins essayés, `exit 3`.
Les `.bat` : `JEUCLAUDE_GODOT` s'il est défini, sinon le chemin actuel (comportement inchangé dans le dépôt principal).

### 2.4 Pas de changement de format de sauvegarde, de signal de `Partie`, de donnée JSON.
- Nouveaux `class_name` (espace global, aucun autre) : `StrategieTest` (dev-logique) ; `Reglages`, `EcranTitre`, `Sequences`, `RaccourcisTest`, `ScenariosCapture` (dev-interface). Les fichiers de `scripts/outils/scenarios/` n'ont **pas** de `class_name` (chargés par chemin).

## 3. Tâches

### dev-logique (branche `lot/01-logique`, worktree `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot01-logique`)

1. **Localisation de Godot** (`trouver_godot.ps1`, `tests.ps1`, `capture.ps1`, `.bat`) selon §2.3.
   - CA-L1 : depuis le worktree (sans `outils\`), `tests.ps1` trouve Godot dans le dépôt principal et passe ; `capture.ps1 -Etape titre -Nom essai_wt` écrit `godot\captures\essai_wt.png` **dans le worktree** (code 0).
   - CA-L2 : `$env:JEUCLAUDE_GODOT` = chemin valide → utilisé (affiché en tête de sortie) ; = chemin inexistant → message clair, code 3, aucune trace d'exception PowerShell. Dans le dépôt principal, sans variable : comportement identique à aujourd'hui.
   - CA-L3 : `Exporter_Windows.bat` lancé depuis le dépôt principal produit toujours `export\windows\JeuClaude.exe` ; depuis un worktree avec `JEUCLAUDE_GODOT` défini, il exporte dans `<worktree>\export\windows\`.
2. **`tests.ps1` plus strict et extensible.**
   - Import (`--headless --import`) à chaque lancement (option `-SansImport` pour le sauter) ; découverte automatique : `godot/tests/test_*.tscn` lancés comme scènes, `godot/tests/test_*.gd` lancés en `--script` **sauf** s'ils ont un `.tscn` du même nom ; option `-Recette` qui ajoute `godot/tests/recette/test_*` (dossier du testeur) ; option `-Filtre <motif>` pour n'en lancer qu'une partie.
   - La sortie complète (stdout + stderr) de l'import et de chaque test est analysée : `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, `Invalid call`, `Invalid access`, `Cannot call method` → le test est en échec **même si son code de sortie est 0** ; les lignes fautives sont réaffichées.
   - Résumé final : une ligne par test (nom, code, durée, nombre d'erreurs de script), total, code de sortie 0 seulement si tout est propre.
   - CA-L4 : `tests.ps1` sur la branche : tous les tests découverts au vert, nombre total de vérifications ≥ 174 + les nouvelles, résumé affiché, durée totale < 90 s.
   - CA-L5 : `tests.ps1 -Autocontrole` lance `tests/autocontrole/erreur_volontaire.gd` (hors découverte normale ; provoque une erreur de script à l'exécution puis `quit(0)`) et renvoie 0 **seulement si** l'erreur a été détectée et signalée.
3. **`StrategieTest`** (§2.2), extraite de `principal.gd` (lecture seule de ce fichier).
   - CA-L6 (test_demo) : sur 20 graines, le joueur actif finit la démo sans faillite, a détenu au moins 7 des 9 produits ; `aller_a(e, Dates.lire("1986-03"), true)` arrive exactement en mars 1986 ; `aller_a_modale(e, "p1e6", true)` s'arrête sur la modale du krach ; `aller_a_modale(e, "D02", false)` sur la présentation du PEL ; id inconnu → `false` sans boucle infinie.
4. **Fichiers de test dans `user://`** : noms uniques par processus (`OS.get_process_id()`), effacés en fin de test.
   - CA-L7 : après `tests.ps1`, aucun `test_*.sav` ne reste dans `%APPDATA%\Godot\app_userdata\JeuClaude` ; l'empreinte SHA-256 de `partie_en_cours.sav` (s'il existe) est identique avant et après.
5. **Test de fumée de l'interface** `tests/test_interface.tscn` (+ `.gd`), headless, ≤ 60 s. Il ne modifie **aucun** fichier de `scripts/` (hors `strategie_test.gd`) et n'utilise que des fonctions publiques ou déjà appelées par `principal.gd` :
   - a) `Partie.chemin_sauvegarde = "user://test_interface_<pid>.sav"` **avant** toute instanciation ; instancie `res://scenes/principal.tscn`, attend 10 images, vérifie que l'écran titre est affiché et qu'aucune sauvegarde du joueur n'est touchée, puis libère la scène ;
   - b) instancie `Hud`, `Modales`, `PanneauBanque` dans l'arbre et joue la démo complète (graine fixe) deux fois, joueur actif (`StrategieTest`) puis passif : chaque mois `hud.maj(e, false)` ; chaque modale rencontrée est affichée par la fonction de `Modales` que `principal.gd` utilise pour ce genre (présentation, nouvelle/héritage, journal, courrier, naissance), puis fermée par le choix que la stratégie a pris ; aux mois 1986-12 et 1988-06, fenêtre Banque construite sur chaque produit détenu (fiche, formulaire d'ordre, réglage « chaque mois ») ; historique ouvert avec chaque filtre et 5 entrées relues ; relevé de décembre affiché ; écran de fin affiché avec `Bilan.calculer` ;
   - c) au moins 20 vérifications (`OK` / `KO` comme `test_partie`), code de sortie 1 si une échoue.
   - CA-L8 : `test_interface` passe sur la branche (code 0, aucune erreur de script) en ≤ 60 s.
   - CA-L9 (mutation, faite par le testeur dans un worktree jetable, jamais commitée) : renommer `EtatPartie.vie_en_attente` (et son appel interne l. 292) → `tests.ps1` échoue et désigne l'import ou `test_interface` ; même chose en remplaçant par une clé inexistante une lecture de champ de `e.hist` dans `hud.gd` (ex. `e.hist["mis"]`) **et** une lecture de champ de `e.banque` dans `panneau_banque.gd` (ex. `e.banque["presentes"]`). *(Corrigé le 2026-10-29 : la version initiale visait `e.banque` dans `hud.gd`, qui ne le lit pas.)*
6. Mettre à jour `dev-logique.md` et le socle `developpeur.md` (commandes depuis un worktree, `JEUCLAUDE_GODOT`, options de `tests.ps1`, `StrategieTest`, règle des fichiers `user://`).

### dev-interface (branche `lot/01-interface`, worktree `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot01-interface`)

1. **Découpage de `principal.gd`** — déplacement de code, **aucun changement de comportement ni de rendu**. Cible :
   - `scripts/principal.gd` (≤ 600 lignes) : création des calques et des nœuds, câblage des signaux, mise en place / reprise de partie, boucle (`_process`), touches de jeu (Espace / P, 1-3, M / B, H), réactions aux signaux de `Partie` (mois, notifications, modales, fin), file « vedette » si elle n'est pas déplacée dans `Sequences`, fenêtre Banque, menu, historique, infos (comparaison, frais, bâtiments), sauvegarde à la fermeture, et `preparer_capture(etape)` réduit à une délégation (≤ 5 lignes) vers `ScenariosCapture` (l'autoload `Capture` appelle toujours `scene.preparer_capture`).
   - `scripts/ui/ecran_titre.gd` (`EcranTitre`, `extends Control`) : construction de l'écran titre (l. 172-345 actuelles), boutons JOUER / CONTINUER / NOUVELLE PARTIE, ligne de reprise. Il **n'appelle aucune action de `Partie`** : il émet des signaux (`jouer_demande`, `nouvelle_partie_demandee`) que `principal.gd` traite ; la confirmation d'effacement reste une `Modales.confirmer`.
   - `scripts/ville/sequences.gd` (`Sequences`, `extends Node`, enfant de la scène principale) : appel du banquier, sonnerie, clignotement de la maison, journal, courrier, panne de voiture et réparation, naissance, confettis, voiture neuve, fumée, petite news, fin (l. 577-990). Expose `occupe: bool` (lu par `principal.gd` et les scénarios). Les références (`ville`, `hud`, `modales`) lui sont passées par `principal.gd`.
   - `scripts/outils/raccourcis_test.gd` (`RaccourcisTest`, `extends Node`) : F6 / F7 / F8, « moment suivant » (`_sauter_moment`), triple toucher (`hud.raccourci_demo`). **Créé par `principal.gd` seulement si `Reglages.raccourcis_test()`** ; sinon il n'existe pas et le signal n'est pas connecté.
   - `scripts/outils/scenarios_capture.gd` (`ScenariosCapture`) : répartiteur + outils communs (`_aller_a`, `_aller_a_modale`, stratégie active — copie temporaire, voir §2.2 —, `_attendre_que`, `_clic_dehors`, `_appuyer_bouton`, `_vitesse_mesuree`) ; les étapes sont rangées par famille dans `scripts/outils/scenarios/` (sans `class_name`, un fichier par famille, liste des familles en constante dans le répartiteur) : `titre.gd` (titre, titre_continuer, titre_confirmer, jouer, sauver_fermer, reprise), `banque.gd` (présentations, heritage, carnet, banque_ordre, f01, releve, releve_notif, carnet_pel, automatique, automatique_pel), `ville.gd` (rue, rue_nuit, trafic, crash_*, naissance_*, jumeaux_*, news, krach_anim, fps), `ecrans.gd` (foyer, marche_banque, pause, panneau, historique_*, comparaison*, krach, courrier, fin, clic_dehors), `outils.gd` (polices, f10, integrale, raccourcis). But : au lot 02, un autre développeur pourra recevoir une famille entière sans toucher aux autres.
   - CA-I1 : `principal.gd` ≤ 600 lignes ; aucun nouveau fichier > 700 lignes ; `principal.gd` ne contient plus `KEY_F6`, `KEY_F7`, `KEY_F8`, ni la construction du titre, ni les animations des séquences, ni les étapes de capture (vérifiable par recherche de texte).
   - CA-I2 : **toutes** les étapes listées dans `capture.ps1` s'exécutent sans erreur de script (code 0) ; pour `titre`, `titre_continuer`, `jouer`, `presentation_livret`, `heritage`, `carnet`, `banque_ordre`, `f01`, `krach_anim`, `krach`, `courrier`, `crash_anim`, `naissance_anim`, `news`, `fin`, `historique`, `automatique` : capture PC identique à l'œil à la même étape lancée sur `main` (le testeur compare les paires) ; `titre`, `heritage`, `historique`, `krach` aussi en `--telephone`.
   - CA-I3 : `integrale` va jusqu'à l'écran de fin sans erreur de script ; les genres de modales vus et la fin (`fin = …`) sont les mêmes que sur `main` ; `sauver_fermer` puis `reprise` : la carte du PEL est rouverte à l'identique (lignes « Fermeture : … » / « Reprise : … » équivalentes à `main`).
   - CA-I4 : `tests.ps1` de la branche au vert (66 + 100 + 8), aucune `SCRIPT ERROR` / `Parse Error` à l'import ni dans les captures.
2. **Raccourcis de test retirés de la version du joueur** (§2.1) : `Reglages`, réglage dans `project.godot`, `RaccourcisTest`, ligne d'aide du titre affichée seulement si `Reglages.raccourcis_test()` (et toujours masquée sur mobile), F10 dans `ecran.gd` soumis au réglage. Nouvelle étape de capture `raccourcis` (famille `outils.gd`) : partie en mars 1984, simule F8, F6, F10 et un triple toucher **par de vrais événements d'entrée** à la position de la date du HUD, et affiche une ligne par essai : `raccourcis_test=<vrai|faux> ; F8 : <mois avant> → <mois après> ; triple toucher : … ; F6 : enfants … ; F10 : format …`.
   - CA-I5 : éditeur, sans option : `raccourcis` montre que F8 et le triple toucher font avancer le temps, F6 fait naître un enfant, F10 bascule le format ; capture `titre` avec la ligne d'aide (PC).
   - CA-I6 : éditeur avec `-- --joueur` : `raccourcis` → `raccourcis_test=faux`, aucun mois sauté, aucun enfant, format inchangé ; capture `titre` sans la ligne d'aide ; les touches de jeu (Espace, 1-3, M, H) marchent toujours (vérifié dans `raccourcis` ou `clic_dehors`).
   - CA-I7 : **exe exporté depuis la branche** (commande directe : `--headless --path <worktree>\godot --export-release "Windows" <worktree>\export\windows\JeuClaude.exe`, après import) lancé avec `--log-file <log> -- --capture=<png absolu> --etape=raccourcis` puis `--etape=titre` : même résultat que CA-I6 (log et image). APK : même chemin de code (`template`) ; non vérifiable sans téléphone, à noter comme tel.
3. Mettre à jour `dev-interface.md` : nouvelle structure (qui fait quoi, où ajouter une séquence, une étape de capture, un raccourci de test).

### Tâche documentaire (coordinateur, hors branches de développeur, commit direct sur `main`)
Supprimer D08 bis (retiré le 2026-10-27) des documents de conception, ou faire faire la correction par l'ux-designer (docs/13) et le banquier (docs/11) :
- `docs/13` l. 3 « D01 à D08 bis » → « D01 à D08 » ; l. 107 ticket → « Reçu par assurance-vie : 60 000 F, ce mois-ci, sans droits · Si ça avait été par succession : 32 500 F nets (barré), vous auriez attendu 6 mois et payé 27 500 F de droits » ; l. 108 et l. 312 : retirer « D08 bis » ; l. 320 : « (messages D04 bis, L17) » et « rangé dans l'historique (bouton HISTORIQUE du carnet, filtre banque) » au lieu de l'onglet « Messages » ; l. 343 : retirer « 09/1988 : D08 bis ».
- `docs/11` l. 488 : « Décès 03/1988 ; assurance-vie versée en 04/1988 (un seul pot) | D08 » ; l. 579 : texte D08 remplacé par celui de l. 333 (identique à `banque.json`) ; l. 580 : ligne D08 bis marquée « supprimé le 2026-10-27 (un seul pot) » ; l. 746 : « D01 à D08 ».
- Puis retirer de `CLAUDE.md` (État du projet) la phrase « docs/13 §1.6 et §5.3 mentionnent encore D08 bis ».

## 4. Vérifications attendues

- Par branche (testeur, `docs/lots/lot_01_recette.md`) : `git diff main...lot/01-<x> --stat` limité aux fichiers du §1 (plus les `.uid` des nouveaux scripts) ; CA de la branche ; non-régression (partie complète : `integrale`).
- Après les deux fusions, sur `main` (chef de projet, puis testeur si doute) : `tests.ps1` (nouvelle version) au vert, y compris `test_interface` qui instancie désormais la scène principale **découpée** ; `tests.ps1 -Autocontrole` ; captures `titre`, `jouer`, `krach`, `fin`, `raccourcis` (avec et sans `--joueur`) ; `capture.ps1` lancé depuis un worktree neuf. Si `test_interface` échoue sur `main` à cause du découpage : correction par dev-interface sur `lot/01-interface-correctif`.
- Comptes rendus : fichiers modifiés (comparés au §1), ce qui n'est pas vérifié, écarts d'interface, durée de `tests.ps1`.

## Corrections — passage 2 (`lot/01-logique`, après le KO du passage 1 sur 6751074)

Arbitrage du chef de projet (2026-10-29) sur `docs/lots/lot_01_recette.md` :

| Point | Décision | Qui / où |
|---|---|---|
| A1 majeure : `Jouer_Godot.bat` cassé sans `JEUCLAUDE_GODOT` | **Corriger maintenant** (bloquant : c'est le lanceur du joueur) | dev-logique, `lot/01-logique` |
| A4 mineure : « frais de l'année » affiche le cumul | **Corriger maintenant** (une ligne, un test qui ment est un défaut) | dev-logique, `lot/01-logique` |
| A3 mineure : `test_interface` lit `_droite` / `_b_ok` de `PanneauBanque` | **Accepté pour le lot 01** (`panneau_banque.gd` est interdit aux deux développeurs) ; maintenant, seulement rendre l'échec lisible ; accesseurs publics au lot 02 (backlog T15) | dev-logique maintenant (balisage) ; dev-interface au lot 02 |
| A2 mineure : `Exporter_Android.bat` échoue depuis un worktree | **Aucune correction** : échec propre et documenté ; l'export Android se fait depuis le dépôt principal (export 0.3 au lot 02) | — |
| Écarts annoncés (CA-L9, plancher 2 500 F, `trouver_godot.ps1` sans `exit`) | **Acceptés** ; CA-L9 corrigé dans ce plan (§3, tâche 5) | — |
| H1 : `modales.gd` l. 589, Échap sur un courrier relu pendant le vol de l'enveloppe → SCRIPT ERROR | Hors lot 01 (`modales.gd` interdit). **Lot 02, dev-interface, première tâche, avant le découpage de `modales.gd` (T9)** : reproduction par une étape de capture (famille `ecrans.gd`) puis correction (lambda gardée par `is_instance_valid(p)` ou tween porté par `p`, enveloppe libérée à la fermeture). Pas de correctif express : effet = une ligne d'erreur dans le journal, aucun blocage connu (backlog T16) | dev-interface, lot 02 |
| H2 : `polices/**/*.ttf.import` non suivis | **Déjà couvert par PX0** (`lot_px0.md` §1 et CA-C1 : seul dev-interface PX0 les commite). Rappel : dev-logique ne les commite pas | — |
| H3 : « DE 1978 À AUJOURD'HUI » sur le titre | Déjà au backlog (T12, arbitrage client) | — |

### Consignes pour dev-logique (worktree `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot01-logique`, nouveau commit sur `lot/01-logique`, pas d'amend, pas de push)

1. **A1 — `Jouer_Godot.bat`** : ne plus jamais développer `%JEUCLAUDE_GODOT:...%` quand la variable est absente. Remplacer les lignes 7-8 par un saut :
   ```bat
   if not defined JEUCLAUDE_GODOT goto lancer
   set "GODOT_FENETRE=%JEUCLAUDE_GODOT%"
   set "CANDIDAT=%JEUCLAUDE_GODOT:_console.exe=.exe%"
   if exist "%CANDIDAT%" set "GODOT_FENETRE=%CANDIDAT%"
   :lancer
   start "" "%GODOT_FENETRE%" --path "%~dp0godot"
   ```
   (`goto` saute les lignes sans les développer.) Fichier en CRLF. **Vérifier à sec** les deux cas, comme le testeur : copie temporaire du `.bat` (dans le scratchpad, pas commitée) où `start ""` est remplacé par `echo LANCE`, lancée par `cmd /c` (a) sans la variable : sortie `LANCE "<racine>\outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --path "<racine>\godot"`, code 0 ; (b) avec la variable vers la version console du dépôt principal : version sans console du même dossier choisie. Ne pas lancer le vrai jeu. Relire `Exporter_Windows.bat` et `Exporter_Android.bat` : aucune autre substitution `%VAR:a=b%` ni `%VAR:~n%` sur une variable possiblement absente.
2. **A4 — `tests/test_interface.gd` l. 148** : libellé « frais payés depuis le début (cumul) : %s » au lieu de « frais de l'année : %s » (la valeur `frais_total` reste la bonne : c'est le cumul, comme le HUD).
3. **A3 — `tests/test_interface.gd`, `_visiter_banque`** : ne pas changer l'approche, mais (a) commentaire au-dessus des lectures de `_droite` / `_b_ok` : « accès interne à PanneauBanque, toléré au lot 01 ; à remplacer par des accesseurs publics au lot 02 (T15) » ; (b) si `pb.get("_droite")` ou `pb.get("_b_ok")` renvoie `null`, la vérification échoue avec un message explicite (« PanneauBanque : champ interne _droite introuvable (renommé ?), voir T15 ») **sans erreur de script** : aujourd'hui la l. 215 appelle `droite.get_child_count()` sans tester `null`.
4. `tests.ps1` (tous les tests) au vert, nombre de vérifications ≥ 202, puis commit en français (ex. « Lot 01 logique : Jouer_Godot.bat sans variable, libellés de test_interface »). `git diff main...lot/01-logique --stat` toujours limité au §1. Ne commiter aucun `*.ttf.import`, aucune capture, aucun exe.
5. Compte rendu : les deux sorties à sec de l'étape 1, le résumé de `tests.ps1`, le hash du commit. Ajouter à `dev-logique.md` : « en .bat, `%VAR:a=b%` est développé avant l'évaluation du `if` : sauter par `goto` quand la variable peut être absente ».

### Ce que le testeur revérifie (passage 2, rapide)
- CA-P2-1 (A1) : `Jouer_Godot.bat` à sec, sans variable → `LANCE` avec le chemin `outils\` du dépôt, code 0 ; avec variable valide → version sans console choisie ; avec variable vers un fichier sans version sans console → chemin de la variable.
- CA-P2-2 (A4) : la ligne du relevé dans la sortie de `test_interface` dit « cumul ».
- CA-P2-3 (A3) : mutation jetable `_droite` → `_droite_x` dans `panneau_banque.gd` : `test_interface` KO avec le message « champ interne _droite introuvable », sans SCRIPT ERROR provenant de `test_interface.gd`.
- CA-P2-4 : `tests.ps1` vert (≥ 202 vérifications), `-Autocontrole` vert ; diff limité au §1 ; le reste des CA du passage 1 est acquis (pas de nouvelle intégrale exigée, aucun script du jeu touché).

## 5. Validation (rempli par le chef de projet)
- [ ] CA-L1 à CA-L9 · [ ] CA-I1 à CA-I7 · [ ] tests sur `main` après fusion · [ ] captures relues · [ ] bases de connaissances à jour · [ ] tâche documentaire D08 bis
- Décision :
