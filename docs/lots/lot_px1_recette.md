# Recette du lot PX1 (dev-ville)

## Passage 1 : 2026-11-03, branche `lot/px1-ville`, commit testé 48ecd10 (b830a6c, 9e6c58b, 48ecd10)

**Verdict : KO** (1 anomalie majeure, 9 mineures). Tout le reste est vert : tests, série complète, fusion simulée avec `main` a74a202, partie complète identique à la référence. La correction attendue est localisée (écran titre).

### Ce qui a été lancé
- `tests.ps1` depuis le worktree : 6 étapes, **347 vérifications OK, 0 KO, 0 erreur de script, 42,4 s** (référence de `main` à la base 243bb82 : 279 → +68).
- `capture_ville.ps1 -Serie`, relancée **en entier** (503 s) : 50 lancements, tous à code 0, aucune erreur de script, `hors_palette=0` et `irreguliers=0` partout, 3 montages produits, « PX1 : tout est vert ». Journal : `px1-ville\godot\captures\px1_serie.log`.
- Fusion simulée : worktree jetable détaché sur a74a202 + `merge --no-ff lot/px1-ville` → **aucun conflit** (les 31 fichiers reçus par `main` depuis la base ne recoupent pas les 29 de la branche ; aucun fichier commun non plus avec `lot/px2-interface`). Copie isolée (`user://` à part) : `tests.ps1` **10 étapes, 392 OK, 0 KO, 53,0 s** ; `test_rue` génération 1 735 ms ; 23 étapes de CA-V7 à code 0, sans erreur ; **partie complète : 160 749 F, frais 805,93 F, 11 interruptions, fin déc. 1988** (= référence de `main`). Worktree jetable supprimé, `user://` isolés effacés.
- Vitrine PX0 : `capture_px0.ps1 -Etape jour -Controle -Taille 1920x1080` → code 0, tout vert ; `Voir_PX0.bat -- --px0-quitter-apres=5` → code 0.
- `user://` du joueur : `partie_en_cours.sav` SHA-256 E2B314A8… inchangé avant et après ; seul `capture.sav` ajouté (hors contrôle).

### Critères d'acceptation
- [x] **CA-V1** : 347 ≥ 279 + 30 ; 42,4 s ≤ 60 s ; import propre.
- [x] **CA-V2** : `test_rue` 68 OK en 4,8 s ; N/R justes pour les 6 formats ; génération 1 717 ms (≤ 2 000, marge étroite : voir A10). Les bornes sont éprouvées via `_cx` + `_appliquer` (pas un vrai glisser) : le glisser est couvert par CA-V6.
- [x] **CA-V2 bis** : `test_pixel` 77 OK, 10,3 s, 67 couleurs, les 40 premières inchangées.
- [x] **CA-V3** : `rue` jour, `rue_nuit` nuit, `krach_anim` orage : `hors_palette=0` (image du SubViewport).
- [x] **CA-V4** : 1080p `facteur=2 reduction=1.000 vue=960x540 gerard_ecran=126` ; 720p `2 / 0.667 / 960x540 / 84` ; 1366 × 768 `2 / 0.711 / 961x540 / 90` ; téléphone `2 / 0.667 / 1200x540 / 84` ; ×4 forcé `4 / 0.500` ; `irreguliers=0` partout (blocs N × N). `px1_montage_formats` : Gérard à la même proportion sur les trois formats (vérifié à l'œil). Le « grouillement » pendant le défilement n'est pas vérifiable sur des images fixes.
- [x] **CA-V5** : `largeur=3420`, Gazette −683, maison 114, banque 813 (distances 797 et 699) ; cadrages sur les 4 formats : maison haut 144 / bas 402 dans 48..504 (téléphone 106..503) ; banque haut 117 ; Gazette haut 84, bas 402 (téléphone : libre 79..476). Bâtiment entier dans le rectangle libre sur `rue_1080`, `rue_banque`, `rue_gazette`, `_720`, `_1366`, `_tel`.
- [x] **CA-V6** : glisser 245 → 826 sans `batiment_touche` ; molette 826 → 720 ; flèche → 720 → 844 ; `interactif=false` 844 → 844 ; toucher bref sur la banque → émis. Voir A6 pour la flèche.
- [x] **CA-V7** : sur la fusion, les 23 étapes (`titre` … `historique`) donnent code 0, 0 `SCRIPT ERROR` / `Invalid call` / `Invalid access`. Étiquettes « MA MAISON » et « MA BANQUE » sur la chaussée sous leur bâtiment (`rue_1080`, `rue_banque`). Voir A2 pour le téléphone.
- [x] **CA-V8** : `banquier` 2,21 s `maison->banque->maison` ; `journal` 1,02 s ; `journal_krach` 1,61 s `->media` ; `crash` 1,78 s ; `petite_news` `maison->maison` ; passer : banquier 0,28 s, crash 0,26 s, naissance 0,29 s, krach 0,90 s, toujours `delai=0.00`. Naissance (1,85 s) et courrier simple (1,0 s) : non imprimés, calculés en lisant le code (A5). Captures : combiné et ondes à la banque, signal entre la banque et la maison, BONK et capot, jumeaux (deux paquets sur le rebord, confettis), krach (orage, pluie, journaux volants, courbe rouge).
- [x] **CA-V9** : ×1 → 63,5 / 26,0 ; ×2 → 158,0 / 64,7 (facteur 2,50) ; ×3 → 295,3 / 117,3 (facteur 4,50) ; pause → 0. Écart < 1 %. Le gel passe par `anime` (`principal.gd` : `Partie.vitesse > 0 or sequences.occupe`) puis `facteur_trafic` → 0 (`ville.gd` l. 100-109), jamais par `Partie.vitesse` seul.
- [ ] **CA-V10** : rue de nuit OK (fenêtres en `lumiere`, halos à 3 disques, phares) ; hiver OK (neige au sol et sur les toits, flocons) ; automne, printemps et pluie OK ; teinte de pause peu perceptible (35 % au plus, conforme). **Échec sur le titre (A1)** ; `jouer` ne montre pas la maison au repos (A4).
- [x] **CA-V11** : les 3 humeurs de Sylvie se distinguent nettement à 1080p (0 : sourire ouvert, joues ; 1 : bouche neutre ; 2 : sourcils froncés, bouche tombante) ; planche sans HUD et sans tête coupée : 9 personnages, M. Lefranc qui fume et au repos, Jean-Mi à vélo, 2 enfants, poussette simple et double, 944, R5, 205, 4L, fourgonnette, « À VENDRE » ; voisins : `point_tete` tata 370,696 et jeanmi 1470,696 dans l'écran (A8).
- [x] **CA-V12** : 421 images/s à 1080p, 687 au téléphone.
- [x] **CA-V13** : les 29 fichiers du diff relèvent tous du §1 (`scripts/ville/*`, `scripts/pixel/*` hors `ui/`, `juice.gd` modifié seulement dans `_process`, scénario `ville.gd`, `capture_ville.ps1`, `test_rue.gd`, `dev-ville.md`) ; ni `.ttf.import` ni fichier temporaire ; aucun `Color("#`, `Color(0.` ou `Color(1` hors `palette.gd` (les ondes `Color.WHITE` sont converties en couleurs de palette dans `media.gd`) ; aucune référence à `Style` ; `class_name Batiment` et `class_name Sequences` présents. `rue_px0.gd` : seulement `Color(1,1,1,a)` → `Color(Color.WHITE,a)`, la vitrine marche.
- [x] **CA-V14** : code 0 pour les deux commandes.
- [x] **CA-V15** : même liste de fichiers (hors `capture*.sav` et `logs`) et même SHA-256.
- [x] **CA-V16** (avis, non bloquant) : `px1_montage_px0` et `px1_montage_ref` montrent la même famille que PX0 quater (briques à joints, relief, cumulus tramés, gros arbres, trottoir en dalles). Écarts : la rue du jeu est plus dense (banque à fronton et horloge, Gazette sombre, mur peint « CHOCOLAT AU LAIT ») ; la R5 de la planche ressemble à un break à trois volumes. Verdict au joueur.

### Anomalies
1. **A1 (majeure) : sur l'écran titre, l'enseigne du titre est masquée par l'arbre.** Étapes : `capture.ps1 -Etape titre` (1280 × 720) ou série `px1_titre` (1080p). Attendu (CA-V10, §4.4) : l'enseigne du titre de la Gazette s'écrit lettre à lettre, lisible. Constaté : seuls « JEUC » se lisent ; la suite est sous le feuillage de l'arbre de premier plan (posé sur le bord droit de la vue, qui est centrée sur la Gazette en mode titre). En hiver (janvier 1984), le feuillage est en plus givré. C'est la première image du jeu. Captures : `px1-ville\godot\captures\px1_titre.png`. Je l'ai vu dans la copie de fusion (`cv7_titre`).
2. **A2 (mineure) : au téléphone, l'étiquette de la Gazette est coupée.** Étapes : `rue_gazette -Telephone`. Pour faire tenir le journal lumineux, la caméra descend (libre 79..476 au lieu de 106..503) : `point_etiquette("media")` tombe à y = 541 et l'étiquette « LA GAZETTE » est à moitié sous la frise. Capture : `px1_rue_gazette_tel.png`. À recontrôler à la fusion PX1 × PX2 (nouvelles étiquettes).
3. **A3 (mineure, écart déclaré « arbres givrés ») : les arbres d'hiver changent d'une capture à l'autre.** `px1_saison_hiver` (01/1985) : feuillage entièrement givré, blanc. `px1_pause` (01/1988) : arbre vert, alors que les toits sont enneigés. `px1_jouer` (01/1984) : vert, un peu givré. Cause probable : la recoloration de saison se fait en tâche de fond et n'est pas finie au moment de la capture, ou bien l'état n'est pas le même. Sur le fond : un arbre qui garde ses feuilles en janvier (même givrées) est un choix à soumettre au joueur.
4. **A4 (mineure, écart déclaré) : la capture `jouer` montre la banque, pas la maison au repos.** En janvier 1984, l'appel du Livret A part aussitôt : la capture montre la banque et M. Lefranc. `plonger_vers_maison` n'est couvert que par `test_rue` (il renvoie un Tween) et, indirectement, par le départ `maison->` des séquences. Le cadrage de la maison au repos est en revanche vu sur `rue_1080`.
5. **A5 (mineure, écart déclaré) : les durées de la naissance et du courrier simple ne sont pas imprimées.** En lisant le code : naissance 0,75 + 0,6 + 0,5 = 1,85 s ≤ 2,6 ; courrier 0,7 + 0,3 = 1,0 s ≤ 1,5. Autre point : `passe_krach` touche vers 0,9 s et non 0,3 s après le début (le délai reste nul). Le protocole « toucher 0,3 s après le début » n'est donc pas tenu pour le krach.
6. **A6 (mineure, écart déclaré) : les flèches ← → ne font pas défiler la rue quand un bouton a le focus.** Elles sont lues dans `_unhandled_input` ; si un bouton du HUD a le focus (après un clic sur la vitesse, par exemple), Godot s'en sert pour déplacer le focus et la rue ne bouge pas. L'étape `defilement` contourne le cas par `gui_release_focus()`. Le correctif relève plutôt de l'interface (`focus_mode` des boutons, PX2) : question au CDP.
7. **A7 (mineure) : « À VENDRE » est coupé « À VEN / DRE », sans trait d'union**, sur le panneau et sur la vitre de la 944 (planche). La Porsche fait 168 × 47 au lieu de ≈ 100 × 39 (écart déclaré) : c'est cohérent avec les voitures passées à ×1,5 en PX0 quater (≈ 140 à 170 px), je ne le compte pas comme défaut.
8. **A8 (mineure) : Jean-Mi passe derrière le panneau « Mon argent ».** Dans `voisins`, sa tête est en x = 1470, sous le panneau de l'ancien HUD (x > 1410) : le contrôle répond `ecran=oui`, mais il n'est pas visible. `point_tete` devrait tenir compte du rectangle libre.
9. **A9 (mineure) : la panne est peu lisible.** Dans `crash_anim`, le capot ouvert (gris) passe sur le buste de Gérard, qui marche devant la voiture, et le « BONK » est petit. Capture : `px1_crash_anim.png`. Le signal du banquier (`banquier_signal`) est petit lui aussi, mais lisible.
10. **A10 (mineure) : marges et commits.** `test_rue` génère la rue en 1 717 à 1 735 ms pour un plafond de 2 000 ms (marge ≈ 13 %, zone fragile sur une machine plus lente). Il y a 3 commits pour 7 tâches, et le message de b830a6c est incomplet (corrigé par la note de 9e6c58b) : acceptable, le périmètre est respecté.

### Non vérifié
Ressenti du glissement et de l'inertie ; « grouillement » des pixels en mouvement sous 1080p (images fixes seulement) ; vrai téléphone (glisser au doigt) ; 2160p réel ; perception de la teinte de pause.

### Questions au chef de projet
- A1 : faut-il déplacer ou retirer l'arbre de premier plan en mode titre, ou cadrer l'enseigne ailleurs ? C'est la seule correction exigée pour l'OK.
- A6 : faut-il ouvrir une demande à PX2 (`focus_mode = FOCUS_NONE` sur les boutons du HUD) ou laisser la ville lire les flèches dans `_input` ?
- A3 : arbres d'hiver nus, ou givrés (choix du joueur) ? Faut-il attendre la fin des tâches de fond avant d'afficher la saison ?
- A2 / A8 : à traiter à la fusion avec PX2 (étiquettes et bulles hors du rectangle libre) ?

## Passage 2 : 2026-11-03, branche `lot/px1-ville`, commit testé 7733938 (c03d10a, ab50fda, cf8b53b, 7733938)

**Verdict : OK** (A1 corrigée ; restent des mineures, dont une nouvelle, A11, à corriger de préférence avant la fusion avec PX2).

### Ce qui a été lancé
- Périmètre : les 4 commits touchent 10 fichiers, tous déjà dans le diff du passage 1 et dans le §1 du plan (`scripts/ville/*`, `scripts/pixel/*`, scénario `ville.gd`, `capture_ville.ps1`, `test_rue.gd`, `dev-ville.md`). Diff total `main...lot/px1-ville` : mêmes 29 fichiers. Worktree propre.
- `tests.ps1` (worktree) : 7 étapes, **350 OK, 0 KO, 0 erreur de script, 44,5 s** ; import propre ; `test_rue` 71 OK (+3 : enseigne du titre dans la vue, arbre retiré au titre, puis de retour en jeu) ; génération **1 161 ms** (1 717 ms au passage 1).
- `capture_ville.ps1 -Serie` en entier : tous les lancements à code 0, aucune erreur de script, `hors_palette=0` et `irreguliers=0` partout, « PX1 : tout est vert ». Images par seconde 426 (1080p) / 694 (téléphone). Un autre agent avait 2 Godot ouverts pendant la série (aucun effet visible sur les chiffres).
- Fusion simulée : worktree jetable `recette-px1-p2-fusion` détaché sur a74a202 + `merge --no-ff lot/px1-ville` → **aucun conflit**. Copie isolée : `tests.ps1` **9 étapes, 395 OK, 0 KO, 44,6 s** (génération 1 087 ms) ; **partie complète : 160 749 F, frais 805,93 F, 11 interruptions, fin déc. 1988, modales appel 8 / banque 4 / courrier 2 / journal 1 / fin 1** (= référence). Worktree jetable supprimé, `user://` isolés effacés. (`main` est passé entre-temps à 3abcc48, commit de documents seulement.)
- `partie_en_cours.sav` du joueur : SHA-256 E2B314A8… inchangé.

### Reprise des anomalies du passage 1
- **A1 corrigée.** `px1_titre` (1080p), `px1_titre_720`, `px1_titre_tel` : « JEUCLAUDE » entier et lisible sur les trois formats, plus d'arbre de premier plan au titre (`RUE titre premier_plan=masque`). L'arbre revient en jeu (`test_rue`, `px1_jouer`). Remarque hors lot : au téléphone, le sous-titre « MA RUE, DE 1978 À AUJOURD'HUI » passe sur la façade de la Gazette (texte de l'écran titre, interface).
- **A2 non corrigée (mineure).** `px1_rue_gazette_tel` : l'étiquette « LA GAZETTE » (y = 516 dans la vue 540) est toujours à moitié sous la frise. Le bas de `libre_monde()` ne semble pas tenir compte de la frise au téléphone. À revoir à la fusion avec PX2.
- **A3 en partie corrigée (mineure).** `px1_saison_hiver` (01/1985) et `px1_jouer` (01/1984) montrent maintenant le même feuillage givré. Mais `px1_pause` (01/1988, étape de `capture.ps1` qui n'attend pas les tâches de fond) montre toujours un arbre vert sous des toits enneigés : au chargement d'une partie en hiver, l'arbre est vert puis se givre quelques instants plus tard.
- **A4 corrigée** : nouvelle étape `jouer_repos` → `camera=245 repos_maison=oui`, capture `px1_jouer` sur la maison au repos.
- **A5 corrigée** : durées imprimées, naissance 1,84 s (≤ 2,6), courrier simple 0,97 s (≤ 1,5). Le toucher du krach : voir A11.
- **A7 corrigée** : « À VENDRE » sur une ligne, sur le panneau et sur la vitre de la 944 (`px1_planche_personnages`).
- **A9 corrigée** : la 205 et le potelet sont à gauche de la maison, le capot ne passe plus sur Gérard, le « BONK » est plus grand et lisible, le triangle est derrière la voiture (`px1_crash_anim`). Glyphe N : il se distingue maintenant du M (« BANQUE » sur la façade, « TONTON », « JEAN-MI »). À 3 × 5 pixels, il ressemble un peu à un Π, mais se lit.
- **A10 corrigée** : génération 1,09 à 1,16 s (marge ≈ 42 %).
- A6 et A8 : pas touchées dans ce passage (questions au CDP toujours ouvertes).

### Nouvelle anomalie
11. **A11 (mineure) : la rue se fige ≈ 0,3 à 0,6 s au début du krach** (c'est la cause du toucher qui part à 0,9 s au lieu de 0,3 s). Mesure faite dans une copie isolée instrumentée (rien n'a été modifié dans la branche) : `krach_anim -Passer 0.3`, 3 fois → une seule image de **604 à 664 ms** juste après le début de la séquence. Le minuteur de 0,3 s expire pendant cette image, et le toucher arrive à 0,63-0,69 s (0,73 s dans la série, 0,90 s au passage 1). Pour le crash, l'image la plus longue dure 46 ms et le toucher arrive à 0,3 s. Cause : à la première image d'orage, `GrillePixel.texture(nom, ORAGE)` crée en direct les textures d'orage qui ne sont pas encore prêtes : `matiere/skyline` 90-99 ms, `matiere/chaussee` 43 ms, `rue/fond_*`, `rue/batiment_*`, `banque`, `gazette` 15-19 ms chacune, `premier_plan_*_automne` 32 ms. **En conditions de jeu**, après 10 s d'attente (`_prechauffe` vide, plus aucune tâche de fond), il reste **une image de 306 ms** : skyline, `fond_1`, `fond_7` et premier plan de saison ne sont jamais préchauffés. La liste `_prechauffe` est construite dans `_construire()`, avant que ces images existent ; depuis c03d10a (A10), la skyline, les cumulus et les façades de fond sont générés en tâche de fond, donc absents de la liste. Même chose pour la nuit (variante 1 : ≈ 0,3 s de textures créées en direct). Effet pour le joueur : un à-coup visible au moment le plus dramatique (et à la première nuit), et un toucher pris en retard. Le « passer » reste correct (`delai=0.00`). Piste pour le développeur : ajouter à `_prechauffe` les images récoltées par `_recolter()` (variantes NUIT et ORAGE, et variantes de saison).

### Critères d'acceptation (changements par rapport au passage 1)
- [x] **CA-V1** : 350 vérifications, 44,5 s, import propre.
- [x] **CA-V2** : génération 1 161 ms.
- [x] **CA-V7** : sur la fusion, aucune erreur ; étiquettes au PC OK ; au téléphone, voir A2.
- [x] **CA-V8** : banquier 2,20 s, journal 0,98 s, krach 1,59 s, crash 1,78 / 1,75 s, courrier 0,97 s, naissance 1,84 s ; passer : banquier 0,31 s, crash 0,29 s, naissance 0,30 s, krach 0,73 s (A11), toujours `delai=0.00`.
- [x] **CA-V10** : titre lisible sur les 3 formats ; maison au repos après « Jouer ». Saisons : A3 en partie.
- [x] **CA-V12** : 426 / 694 images/s en moyenne (l'à-coup d'A11 est ponctuel et ne compte pas dans cette moyenne).
- [x] **CA-V13** : périmètre respecté (10 fichiers, tous dans le §1).
- Les autres critères sont inchangés depuis le passage 1 (vérifiés par la série et les tests).

### Non vérifié
Le même qu'au passage 1 ; en plus, l'à-coup d'A11 dans une vraie partie lancée de janvier 1984 jusqu'au krach (mesuré seulement après 10 s de préchauffage, ce qui reproduit le cas d'une longue partie) et la durée de l'à-coup de la première nuit (textures mesurées, image non chronométrée).

## PX1-bis : 2026-11-07, branche `lot/px1-ville`, commit testé adf593d (base `main` dfd5ca4)

**Verdict : OK** (A11, A3 et le blocage à la sortie corrigés ; 3 mineures).

### Ce qui a été lancé
- Périmètre : `git diff main...lot/px1-ville --stat` = 5 fichiers : `scripts/ville/rue.gd`, `scripts/pixel/grille.gd`, `scripts/outils/scenarios/ville.gd`, `tests/test_rue.gd`, `docs/connaissances/dev-ville.md`. Tous attribués à dev-ville par le §1 de `lot_px1.md` (`grille.gd` : ligne « `scripts/pixel/*.gd` hors `scripts/pixel/ui/` (… `grille` …) »). Aucun fichier temporaire ni `.import`. Worktree propre.
- `tests.ps1` (worktree) : 10 étapes, **405 OK, 0 KO, 0 erreur de script, 58,7 s**, import propre. `test_rue` 75 OK : génération 1 408 ms, `RUE image_max_ms=16.0` (première nuit, premier orage, fondus, après préchauffage), tâches + préchauffage 2,8 s.
- `capture_ville.ps1 -Serie` (copie isolée de adf593d, `user://` à part, 519 s) : 55 lancements à code 0, 0 erreur de script, `hors_palette=0` (14/14), `irreguliers=0` (5/5). Le « au moins un échec » final venait seulement du montage `px1_montage_px0` (image de référence `px0_quater_jour_1080.png` absente de ma copie, fichier non suivi) ; après copie de l'image, `-Montages` : « PX1 : tout est vert ». Images/s 351 (1080p) / 612 (tél.), un peu moins qu'au passage 2 (426 / 694), machine chargée par un autre testeur en parallèle ; ≫ 60.
- Fusion simulée : worktree jetable détaché sur `main` dfd5ca4 + `merge --no-ff lot/px1-ville` → aucun conflit, **arbre identique** à adf593d (la branche part de `main`) : les 405 tests valent pour la fusion. **Partie complète** (`integrale` sur la copie) : **160 749 F, frais 805,93 F, 11 interruptions**, fin déc. 1988, modales appel 8 / banque 4 / courrier 2 / journal 1 / fin 1 (= référence). Worktree et copies supprimés.
- `partie_en_cours.sav` du joueur : SHA-256 E2B314A8… au début de ma recette, 836B1610… à la fin, fichier daté du 07/11 à 00:49:26 : écrit par une partie lancée à 00:28 (2 Godot qui n'étaient pas à moi, fermés depuis), pas par mes lancements (tous en `user://` isolé, sauf `tests.ps1`, qui n'y touche pas).

### A11 (à-coup au premier orage / à la première nuit) : corrigée
- Série : `RUE image_max etape=krach_anim` 6,1 / 17,1 / 43,6 ms (au lieu de 604 à 664 ms) ; `rue` 2-4 ms, `rue_nuit` 3,4 ms, `pluie` 4,0 ms. Toucher pour passer le krach : `journal_krach duree=0.27` s (0,73 s au passage 2), `delai=0.00` ; banquier 0,28, crash 0,26, naissance 0,26 s.
- Durées normales inchangées : banquier 2,24 s, journal 0,96, krach 1,30, crash 1,78 / 1,74, courrier 0,96, naissance 1,83 s.
- **Démarrage** (copie instrumentée : chrono des images et captures à 0,2 à 5 s après le début du scénario, « Jouer » à 0,3 s puis à 1,5 s) : les 7 arbres de la rue sont dessinables dès 0,2 s ; seul l'**arbre de premier plan** manque jusqu'à ≈ 2 s (préchauffage fini à ≈ 2,2 s). Au titre il est masqué de toute façon ; en jeu, il n'apparaît d'un coup (bord droit) que si le joueur clique « Jouer » dans les ≈ 2 premières secondes. Une image de 165-173 ms à t ≈ 0,17 s, sur l'écran titre (origine non recherchée : peut-être déjà sur `main`, compilation des shaders au premier affichage). Voir M1.

### A3 (arbre vert sous les toits enneigés) : corrigée
- `px1_pause` (01/1988, étape qui n'attend pas les tâches de fond) : arbre givré sous des toits enneigés, comme `px1_saison_hiver` ; même chose sur ma capture de démarrage en janvier 1984 (arbres givrés dès 0,2 s). Contrôle ajouté dans `test_rue` (noms des feuillages demandés en hiver).

### Blocage à la sortie : corrigé
- Étape `carnet_pel` (qui figeait Godot sur `main` depuis F1-L) : **12 lancements sur 12** ont quitté seuls, en 6 à 7 s, PNG écrit, 0 erreur.
- Arrêt pendant la génération (`--quit-after` 1, 2, 5, 10, 30, 60, 120, 250, 500, 1 000, 2 000 images) : **11 sur 11** quittent, 0 erreur ni fuite signalée. Durée totale 5,7-5,8 s, même pour un arrêt à la 1re image (6,5 s à 1 000 images, 8,4 s à 2 000) : quitter juste après le lancement coûte bien ≈ 3 s d'attente des tâches de fond. Voir M2.
- Je n'ai fermé aucun Godot (les miens se sont tous arrêtés seuls).

### Anomalies (mineures)
- **M1** : au démarrage, si le joueur clique « Jouer » dans les ≈ 2 s, l'arbre de premier plan apparaît d'un coup au bord droit de la rue. Attendu : arbre présent dès l'arrivée en jeu ou apparition discrète (fondu). Peu visible (bord d'écran, caméra en mouvement vers la banque au 1er appel).
- **M2** : fermer le jeu dans les ≈ 3 s qui suivent le lancement fige la fenêtre ≈ 3 s avant qu'elle se ferme (le fil principal attend les tâches dans `_exit_tree`). Acceptable (bien mieux qu'un Godot bloqué), à garder en tête sur téléphone (fermeture par le système).
- **M3** : `capture_ville.ps1 -Serie` finit en « au moins un échec » quand l'image de référence de PX0 manque (copie neuve, autre poste) alors que tous les contrôles sont verts : le montage manquant devrait être signalé sans faire échouer la série.
- Restent ouvertes depuis le passage 2 : A2 (étiquette « LA GAZETTE » sous la frise au téléphone), A6, A8.

### Critères vérifiés
- [x] 405 tests verts, import propre, 0 SCRIPT ERROR.
- [x] Série : 0 erreur, `hors_palette=0`, `irreguliers=0`.
- [x] A11 : plus longue image au premier orage / première nuit < 50 ms après préchauffage ; toucher du krach 0,27 s.
- [x] A3 : arbre givré sous toits enneigés en janvier 1988.
- [x] Sortie : 12/12 `carnet_pel`, 11/11 arrêts précoces.
- [x] Périmètre conforme ; fusion sans conflit, partie complète = référence.

### Non vérifié
Vrai téléphone (durée du préchauffage et de l'attente à la sortie sur un processeur mobile, fermeture de l'appli par Android) ; reproduction du blocage sur `main` dans cette recette (non relancée pour ne pas laisser de Godot figés que je ne peux pas fermer ; constaté à F1-L) ; origine de l'image de 165 ms sur l'écran titre.
