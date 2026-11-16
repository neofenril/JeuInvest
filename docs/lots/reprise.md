# Reprise (écrit le 2026-11-17 au soir)

## Où on en est
- **0.6 « titres et record »** livrée : main 10b44a6 (poussé), 1 334 vérifications au vert (`tests.ps1 -Recette -Delai 700`, à lancer sans autre Godot en parallèle). Exports du 16/11 : `export\windows\JeuClaude.exe`, `export\android\JeuClaude.apk`.
- Verdicts du joueur : 0.5.1 : projets « pas mal », pauses OK, saut bien. 0.6 : « version pas mal », il la fait essayer par d'autres personnes et donnera leurs retours ; défaut : **écran de fin trop petit sur smartphone** (récap peu lisible).

## En cours à la reprise
- **Correctif écran de fin smartphone** : dev-interface (agent a0ad2949a8b9f6f3f, resumable par SendMessage) travaille dans `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot07-correctifs` (branche `lot/07-correctifs` depuis main 10b44a6), commits locaux, rien de poussé. Consigne : agrandir le récap (titre, pourquoi, barres, comparaison Tata %, record, projets), réduire le décoratif (portrait Sylvie, courbe), toute la zone libre, Atkinson ≥ 24 px, PC inchangé, contrôle auto de taille minimale. Suite : recette courte du testeur → push branche → fusion main → tests → export 0.6.1 (version dans `godot/project.godot` + 4 lignes de `godot/export_presets.cfg` : 0.6 / code 8 aujourd'hui).
- Si l'agent n'a pas fini ou a été coupé par la limite d'usage : le relancer par SendMessage avec « reprends là où tu t'es arrêté ».

## À faire ensuite (selon retours du joueur)
1. Classer les retours des testeurs externes dans `docs/10_retours_joueur.md` (verbatim), les passer au chef de projet (agent `chef-de-projet`, Opus) pour arbitrage et plan de lot.
2. Options : rééquilibrage (voir mesures de `test_titres_mesures` : golden_boy et ecureuil seulement par stratégie dédiée, cigale rare, neveu ~27 %), sauvegarde manuelle (`docs/lots/lot_sauvegarde.md`, maquettes `docs/30`, NON lancée, attend le feu vert du joueur), peaufinage reporté (animations, caméra, humeur visuelle, Lundi noir animé, réalisations des projets, voisins qui passent), nouvelles idées fun.
3. Mineures connues : flèche ▲/▼ du record isolée sur sa ligne au PC ; « TONTON MATE » tronqué au téléphone ; règle de vente automatique à redéfinir (feuille_de_route.md §2.11) ; texte 60 mots de la notification du 1er dividende ; icônes/portraits manquants (voisins), certitudes C du boursier (archives de presse souhaitées dans docs/sources/).
4. Plus tard : signature de l'exe (Smart App Control bloque les exe neufs non signés), APK de release (keystore à garder par le joueur), iOS (Mac requis), sons (pas pour l'instant), questionnaire de profil de risque.

## Points d'attention pour la session
- Le dépôt principal a des fichiers modifiés non commités qui ne sont pas du coordinateur : `.claude/agents/{client,game-designer,ux-designer}.md` (le joueur a lui-même choisi les modèles : ne pas y toucher), `docs/connaissances/game-designer.md`, `PromptInitial.txt`.
- Deux processus Godot orphelins du testeur ont pu rester ouverts (le joueur peut les fermer) ; tests : éviter plusieurs Godot en parallèle, `records.sav` du joueur peut être réécrit par un `JeuClaude.exe` ouvert (faux positif de `tests.ps1`).
- Circuit : dev → testeur OK → push branche → fusion main (--no-ff) → tests → push ; le coordinateur crée les worktrees dans `C:\Users\arthu\Documents\temp\JeuClaude_lots\` ; devs sans push ; un agent ne peut pas en lancer un autre.
- Agents (ids de session perdus au redémarrage) : relancer par type (dev-interface, dev-logique, dev-ville, testeur, chef-de-projet, game-designer, ux-designer, banquier, boursier) avec lecture de leur base `docs/connaissances/<agent>.md`.