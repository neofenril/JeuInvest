# Reprise (mise à jour le 2026-11-17 au soir)

## Où on en est
- **0.6.1** livrée : main (poussé), 1 334 vérifications au vert (`tests.ps1 -Recette -Delai 700`, sans autre Godot en parallèle). Exports du 17/11 : `export\windows\JeuClaude.exe`, `export\android\JeuClaude.apk`. Version : 0.6.1 / code Android 9 (`godot/project.godot` + 4 lignes de `godot/export_presets.cfg`).
- Le joueur fait essayer la 0.6.x par d'autres personnes et donnera leurs retours ; il les classe dans `docs/10_retours_joueur.md` (verbatim). Nouveaux retours du 17/11 : 6 fonctionnalités à prévoir (`docs/lots/backlog_retours_0_6.md`).
- Méthode de recette allégée (décision du joueur) : série de captures complète seulement avant chaque export ; sinon étapes ciblées ; recette courte si changement petit (voir CLAUDE.md).

## En cours à la reprise
1. **Pop-up de début de partie (backlog n° 6)** : dev-interface (agent a0ad2949a8b9f6f3f, relançable par SendMessage) dans `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot08-intro` (branche `lot/08-intro` depuis main e2557cb), commits locaux, rien de poussé. Texte définitif : `docs/32_popup_debut.md` (non commité : le commiter dans main) : titre « JANVIER 1984 », 4 blocs (qui vous êtes avec {salaire} et {depart} lus dans les données, ce qui attend, objectif, comment jouer), bouton COMMENCER seul, pas de case « ne plus afficher », krach volontairement non annoncé, affichée à chaque Nouvelle partie jamais à Continuer, avant toute autre pop-up, entrée dans l'historique. Suite : recette courte du testeur → push de la branche → fusion main → tests → export 0.6.2 (version 0.6.2 / code 10).

## Ensuite, dans l'ordre (conseil de priorisation validé par le joueur)
1. **Rééquilibrage** : mesures de `test_titres_mesures` (golden_boy et ecureuil seulement par stratégie dédiée, cigale rare, neveu ~27 %, marin 40/40 en tout-Peugeot, bon_pere 52 % en alterner moins_cher) ; dosage des notifications de Jean-Mi ; à valider avec les retours des testeurs externes.
2. **Sauvegarde manuelle à 3 emplacements** (`docs/lots/lot_sauvegarde.md`, maquettes `docs/30_ux_sauvegarde.md`, seuils `docs/28`) : le joueur a dit « à ne pas lancer tout de suite » ; lancer à la reprise selon l'ordre de priorisation, en lui rappelant.
3. **Plan d'ensemble des idées 1 à 3 du backlog** (étapes et trophées, profils d'investisseur débutant/intermédiaire/expert, bâtiment « s'amuser » avec garde-fou pédagogique) : faire cadrer par le chef de projet (Opus) avec le game designer, le banquier et l'UX ; ordre et coût.
4. **Extension de la plage des années jouables** (demande du joueur) pour préparer les idées 4 (décor par décennie) et 5 (création de partie : mini-questionnaire ou année + 3 profils types) : à lancer dès la reprise : faire écrire par le chef de projet un plan d'extension (années de départ, durée de partie, données par époque), demander au banquier et au boursier un état des lieux des données disponibles par décennie (docs/01, docs/02, docs/sources/) et une proposition de séquence (quelles années en premier, ex. 1950-1960… 1990-2020), puis au game designer les profils types par époque et le contenu de départ. Prérequis techniques à examiner avec dev-logique : démo actuelle codée 1984-1988 (demo.json, regles.json, periode_p1.json, series.json), calendrier de vie, produits disponibles par date.

## Points d'attention
- Retours du joueur à lire en premier : `docs/10_retours_joueur.md` (priment sur l'avis des agents).
- Modèles d'agents choisis par le joueur (chef-de-projet, client, game-designer, ux-designer en Opus ; les autres en Sonnet) : ne pas y toucher.
- Windows Smart App Control peut bloquer un exe neuf non signé ; vérifier par `--main-pack` ; signature plus tard.
- `PromptInitial.txt` est un fichier du joueur non suivi : ne pas le commiter.
- `records.sav` du joueur : ne jamais l'écrire en test ; un `JeuClaude.exe` ouvert peut l'écrire (faux positif de `tests.ps1`).
- Circuit : dev → testeur OK → push branche → fusion main (--no-ff) → tests → push ; worktrees dans `C:\Users\arthu\Documents\temp\JeuClaude_lots\` ; devs sans push ; un agent ne peut pas en lancer un autre ; ids d'agents perdus au redémarrage : relancer par type avec lecture de `docs/connaissances/<agent>.md`.
- Plus tard : signature de l'exe, APK de release (keystore gardé par le joueur), iOS (Mac requis), sons (pas pour l'instant), règle de vente automatique à redéfinir (feuille_de_route.md §2.11).