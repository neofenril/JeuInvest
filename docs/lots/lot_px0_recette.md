# Recette du lot PX0 (preuve de concept pixel art : PX0, bis, ter, quater)

## Passage 1 — 2026-10-30 — testeur

- Branches : `lot/px0-ville` (commit testé **45f5120**, « PX0 quater : grille fine 960 × 540 et relief des façades ») et `lot/px0-interface` (commit testé **0ad6db7**, empilée sur `px0-atelier` = 9fc6ed8).
- Fusion simulée : worktree jetable détaché sur `main` 2154e21, `merge --no-ff lot/px0-ville` puis `merge --no-ff lot/px0-interface` (supprimé à la fin). `main` est passé à a0f6637 pendant la recette : commit de documents seulement (`docs/`), aucun fichier commun avec PX0, le résultat de la fusion pour le code est identique.
- Référentiel : `lot_px0.md` (CA-V, CA-I, CA-C), `lot_px0_bis.md` (CA-B1 à CA-B15), docs/16 §8, et les décisions du joueur transmises par le coordinateur : grille de la rue 960 × 540 (×2 en 1080p), Gérard 36 × 63 (126 px à l'écran en 1080p), interface PX0 conservée sur sa grille 640 × 360. Les CA écrits pour la grille 360 (×3, 24 × 42, `-Facteur` ×2/×3) sont lus avec ces nouvelles valeurs.
- Captures de la fusion conservées (non suivies) : `C:\Users\arthu\Documents\temp\JeuClaude\godot\captures\recette_px0_fusion\` ; captures de la branche ville seule : `C:\Users\arthu\Documents\temp\JeuClaude_lots\px0-ville\godot\captures\px0_quater_*.png`.

### Verdicts

| Branche | Verdict |
|---|---|
| `lot/px0-ville` (45f5120) | **OK** (défauts mineurs seulement) |
| `lot/px0-interface` (0ad6db7) | **OK** |
| Fusion simulée main + ville + interface | **sans conflit, tout vert** |

### 1. Branche `lot/px0-ville` seule (45f5120)

- **Périmètre** (`git diff --stat main...lot/px0-ville`, 28 fichiers) : `scripts/pixel/*` (palette, grille, vue_pixel, matieres, facades, personnages, vehicules, rue_px0, px0 + `.uid`), `scenes/px0.tscn`, `data/pixel/LISEZMOI.md`, `data/pixel/ville/lefranc.txt`, `tests/test_pixel.gd`, `outils/capture_px0.ps1`, `Voir_PX0.bat`, `docs/connaissances/dev-ville.md` : conforme. **Hors tableau** : `godot/outils/tests.ps1` et `godot/outils/trouver_godot.ps1` (commit e9cb791, « recopiés de main ») : contenu **identique à `main`** (`git diff main lot/px0-ville -- ces fichiers` vide), donc aucun conflit ni effet (D1). Aucun `.ttf.import` commité (ils sont non suivis dans le worktree, comme prévu). Aucun fichier `ui/`, aucune donnée JSON, aucun réglage de projet.
- **Tests** (`tests.ps1` de la branche = celui de `main`) : import propre (6,2 s) ; test_demo 100, test_logique 66, test_partie 8, **test_pixel 77** OK ; 0 KO, 0 erreur de script ; code 0.
- **Série** (`capture_px0.ps1 -Serie`, 188 s, code 0, « PX0 : tout est vert ») : 19 captures `px0_quater_*`, toutes `hors_palette=0` et `irreguliers=0`, aucun `SCRIPT ERROR` ; les étapes `carte` et `jersey` capturent la rue seule et le signalent (`sans_interface`).
- **user://** (CA-B14) : liste des fichiers identique avant / après (`capture_reprise.sav` seul ; pas de `partie_en_cours.sav`), SHA-256 inchangé.

| CA | Résultat | Preuve |
|---|---|---|
| CA-B1 test_pixel | **OK** | 77 vérifications, code 0 ; 106 images (grilles + générateurs) dans la palette jour, nuit, orage ; erreurs d'`analyser()` détectées sans `push_error`. Durée 10,4-11 s (au-delà des 10 s de CA-V1 : D3) |
| CA-B2 40 couleurs intactes | **OK** | `git diff b586055 -- palette.gd` : aucune ligne retirée dans `_NOMS` ni `_HEX_*`, seulement des ajouts en fin (19 de §8.2 + 8 « PX0 ter » = 67 couleurs : D2) |
| CA-B3 hors palette | **OK** | `palette variante=jour|nuit … hors_palette=0` à 1920 × 1080 et au téléphone |
| CA-B4 alignement | **OK** | `irreguliers=0` partout ; à 1080p N = 2 (518 400 blocs), `-Facteur 4` N = 4. À 1280 × 720, 1366 × 768 et téléphone, N = 1 : le contrôle est trivialement vrai (D4) |
| CA-B5 cadrage | **OK** | `PX0 cadrage maison_haut=144 sol=402 trottoir=402..428 chaussee=428..518 passage=436..504` ; à 1080p la vue va de 0 à 540, bandes 48 / 36 px d'art : cheminée sous la barre, trottoir et passage piéton au-dessus de la frise (504) ; idem 720p, 1366, téléphone (caméra remontée, plus de ciel). Arbre de premier plan visible sur les 4 formats, ne couvre ni la maison ni Gérard |
| CA-B6 personnages | **OK** (valeurs révisées) | `figurine gerard=36x63 ecran=72x126` à 1080p (126 px physiques, décision du joueur) ; planche : œil, sourcil, bouche, main, chaussure lisibles ; Sylvie 0/1/2 sans planche : 3 humeurs nettement différentes (sourire et joues / bouche droite / sourcils froncés et bouche tombante) |
| CA-B7 échelle | **OK** | `echelle porte=66 voiture_rouge=140x59 voiture_grise=137x62 lampadaire=126 maison=228x258` : porte > Gérard (63), lampadaire = 2 × Gérard, voitures largement au-dessus des minima (×1,5 de la grille) |
| CA-B8 contenu de la référence | **OK** (0 « non », 2 « partiel ») | oui : ciel bleu à gros nuages, ≥ 5 bâtiments différents, joints de briques, toits d'ardoise et de tuiles, fenêtres à encadrement, portes rouge / bleue / sarcelle, épicerie à auvent rouge et enseigne, boîte aux lettres jaune, bouche d'incendie rouge, muret à chaperon, grands arbres 4 tons, tronc de premier plan, lampadaire noir à cloche, dalles + bordure + chaussée à marquages et passage piéton, voitures rouge et grise, ombres au sol en aplat. Partiel : skyline (immeubles bleutés visibles, grue / pylône peu lisibles en 1080p car masqués par l'arbre), plaque bleue (simple rectangle, voulu) |
| CA-B9 comparaison | avis | `px0_quater_montage_ref` : luminosité, saturation, chaleur proches de la référence ; densité de détails élevée (briques, appuis en saillie, linteaux, embrasures, ombres tramées) ; profondeur sur 3 plans (skyline, arbres et fonds, rue) ; relief « 3D » des façades rendu par les joues latérales et les saillies. Pas de décalque constaté. Verdict du style : au joueur |
| CA-B10 nuit | **OK** | `px0_quater_nuit_1080` / `nuit_tel` : même scène teintée, fenêtres allumées (`lumiere`), halo du lampadaire en 3 disques, phare de la voiture, `fondu=3.0s` |
| CA-B11 fps sans interface | **OK** | `images_par_seconde=2377` (1080p) |
| CA-B13 couleurs en dur | **OK** | seules occurrences hors `palette.gd` : `Color(1, 1, 1, alpha)` de modulation (transparence d'affichage, permise par §2.2) |
| CA-B14 user:// | **OK** | voir ci-dessus |
| CA-B15 lancement | **OK** (sur la fusion) | voir §3 |
| CA-V8 animation | **OK** | `PX0 animation gerard marche=4 repos=2 cadence=8` ; planche : 6 images ; `libre_0` / `libre_15` : positions différentes |

### 2. Branche `lot/px0-interface` seule (0ad6db7)

- **Périmètre** (`git diff --stat px0-atelier...lot/px0-interface`, 20 fichiers) : `scripts/pixel/ui/*` (+ `.uid`, sans `class_name`), `data/pixel/ui/cadres.txt`, `icones.txt`, les 5 `godot/polices/**/*.ttf.import`, `docs/connaissances/dev-interface_px0.md` : **conforme** au §1. Aucune `SystemFont`.
- **Tests** : `tests.ps1` de la branche (version d'avant le lot 01) ne sait pas trouver Godot depuis un worktree (cherche `<worktree>\outils\…`) : limite connue de l'ancien script, pas un défaut de la branche. Commandes équivalentes lancées à la main avec le Godot du dépôt : import code 0 ; test_logique 66 OK, test_demo 100 OK, test_partie OK, test_pixel (version atelier) 50 OK ; 0 erreur de script.
- **Série** (`capture_px0.ps1 -Serie` de l'atelier, 53 s, code 0, « tout est vert ») : 21 captures, `hors_palette=0`, `irreguliers=0`.

| CA | Résultat | Preuve |
|---|---|---|
| CA-I1 polices | **OK** | `polices chargees=4 tnum_atkinson=oui`, `glyphes_manquants=aucun systemfont=0` ; planche 4 polices × 28/32/48/72 × fonds nuit et crème |
| CA-I2 HUD | **OK** | `hud pixelify_min=28 compte=32 patrimoine=44` (56 en Jersey), `hors_bande=0 chevauchements=0` aux 4 formats (PC 13 textes, téléphone compact 11) ; valeurs `MAI|1987|8 875 F|69 395 F|+26 %|+3 916 F`, frise 1984-1988, curseur mai 1987 |
| CA-I3 lisibilité | **OK** (avis) | chiffres de la barre haute au moins aussi grands que `v3_rue` (patrimoine 44 px virtuels, contraste crème sur nuit très fort) |
| CA-I4 étiquette | **OK** | `etiquette maison … sur_chaussee=oui` aux 5 formats |
| CA-I5 carte | **OK** | `carte montants=60 000 F|32 500 F|27 500 F mots=51`, `taille=1119x530 dans_fenetre=oui portrait=present tampon=TANTE ODETTE` ; texte D08, 32 500 F barré, COMPRIS ambre, carte entière au téléphone |
| CA-I6 fermeture | **OK** | `carte fermee=oui rue_figee=non` (vrai clic) |
| CA-I7 Jersey 10 | **OK** | `police_chiffres=jersey`, date et patrimoine seuls changés |

### 3. Fusion simulée (main 2154e21 + ville + interface)

- **Conflits : aucun.** Les deux fusions `--no-ff` passent en stratégie `ort` sans intervention. Raisons vérifiées :
  - `tests.ps1`, `trouver_godot.ps1` : la branche ville en porte une copie **identique** à `main` → aucune différence à fusionner.
  - `palette.gd`, `grille.gd`, `vue_pixel.gd`, `rue_px0.gd`, `px0.gd`, `capture_px0.ps1`, `test_pixel.gd` : modifiés par la seule branche ville depuis l'atelier (l'interface ne touche aucun fichier de l'atelier) → version ville retenue.
  - `polices/**/*.ttf.import` : commités par la seule branche interface (non suivis côté ville) → version interface retenue. Attention au moment de la vraie fusion : les `.ttf.import` **non suivis** du dépôt principal (créés le 29/10 à 14 h 32) bloqueront `git merge` (« untracked working tree files would be overwritten ») : les supprimer (ou vérifier qu'ils sont identiques) juste avant la fusion de `lot/px0-interface` dans `main`.
  - Rien n'est donc à résoudre ; aucune modification proposée aux branches.
- **Compatibilité d'API** (contrôlée dans le code) : l'interface n'appelle que `vue.regler_marges`, `vue.vue_change`, `vue.monde_vers_ecran`, `rue.figer`, `rue.est_fige`, `rue.point_etiquette_maison`, `RuePx0.SOL / TROTTOIR / BAS_CHAUSSEE`, `PalettePixel.couleur / couleur_alpha / nom_de`, `GrillePixel.existe / texture / image / charger_dossier` : tous présents dans la version ville. Les constantes de la rue (SOL 402, TROTTOIR 26, BAS_CHAUSSEE 518, grille 540) passent par `monde_vers_ecran` : l'interface (grille 640 × 360 virtuelle) se pose correctement.
- **tests.ps1 -Recette** (version lot 01) : import propre ; test_demo 107, test_interface 21, test_logique 66, test_partie 8, **test_pixel 77** (découvert automatiquement ; catalogue avec les 25 grilles `ui/` et le vrai portrait `ville/lefranc_affable`), test_recette_decoupage 11 : **290 OK, 0 KO, 0 erreur de script**, « TOUT EST PROPRE », sauvegarde du joueur inchangée.
- **Série** (`-Serie`, 188 s, code 0) : 19 captures, toutes `hors_palette=0`, `irreguliers=0`, aucune erreur ; plus `carte_fermee` (`fermee=oui rue_figee=non`), `polices` et `carte` téléphone à la main : code 0.
- **Fluidité avec interface** (CA-V9, CA-B11) : `images_par_seconde=1687` à 1920 × 1080 (≥ 55). Mesure sans synchronisation verticale : ne dit rien d'un vrai téléphone.
- **Pose de l'interface sur la rue** : `etiquette maison centre=838,946 chaussee_y=856-1036 sur_chaussee=oui` (1080p), `869,962` (720p), `874,963` (1366), `652,536` (téléphone) ; barre haute au-dessus de la cheminée, frise sous le passage piéton à tous les formats ; aucune donnée cachée par le décor.
- **Captures relues** : jour 1080 / 720 / 1366 / téléphone, nuit 1080 / téléphone, carte 1080 / téléphone (portrait réel de M. Lefranc, carte lisible sur le fond assombri), Jersey, Sylvie 0/1/2, planche. Orage : pas d'étape de capture (conversion seule, contrôlée par test_pixel en palette orage) : non vérifié à l'œil.
- **Jeu normal intact** : `capture.ps1` titre, rue, heritage : code 0, ville vectorielle inchangée ; **partie intégrale** : appel 8, banque 4, courrier 2, journal 1, fin 1, décembre 1988, patrimoine **156 645 F**, 11 interruptions, frais **273,60 F** : identique à la référence du lot 01.
- **Voir_PX0.bat** (CA-B15) : avec `JEUCLAUDE_GODOT` et `-- --px0-quitter-apres=5` : import, scène PX0 lancée en plein écran, fermeture seule, code 0 (15 s) ; sans variable depuis un worktree : message clair, code 3 (normal : `outils\` n'existe que dans le dépôt principal).

### 4. Défauts

Aucun bloquant, aucun majeur.

| N° | Gravité | Branche | Constat | Attendu / proposition |
|---|---|---|---|---|
| D1 | mineure | ville | `godot/outils/tests.ps1` et `trouver_godot.ps1` hors du tableau de propriété (§2 de lot_px0_bis) | Sans effet (contenu identique à `main`) ; à accepter tel quel ou à signaler au développeur pour la suite |
| D2 | mineure (documents) | ville | Palette à **67** couleurs (8 « PX0 ter » : `brique_brune`, `ombre_froide`, `goudron_sombre`, `feuille_profonde`, `mousse`, `nuage_soleil`, `bleu_gris`, `vitre_reflet`) alors que docs/16 §8.2 en décrit 59 | Mettre docs/16 à jour (chef de projet) ; les 40 premières sont intactes |
| D3 | mineure | ville | test_pixel dure 10,4 à 11 s (CA-V1 : ≤ 10 s) | Sans gravité ; à surveiller si le catalogue grossit |
| D4 | **à arbitrer** (non bloquant, dette connue lot_px0 §7) | ville | Avec la grille 540, N = floor(hauteur / 540) : **N = 1** à 1280 × 720, 1366 × 768 et au téléphone 1600 × 720 (et N = 2 en 1440p). La rue y est montrée à 2/3 de sa taille 1080p par rapport à l'écran : Gérard fait 63 px physiques sur 720 (8,8 % de la hauteur virtuelle au téléphone, 11,7 % en 1080p), plus de ciel vide en haut, la vue montre 1 600 px d'art de rue au téléphone. L'interface, elle, garde ses proportions : « MA MAISON » paraît grosse à côté de Gérard. Le contrôle de pixels nets y est trivial (N = 1) | La taille validée par le joueur ne vaut qu'en 1080p (et 2160p). À trancher avant PX1 avec l'UX (facteur non entier interdit ; options : N = 1 assumé, cadrage plus serré, grille par format) ; rendu sur un vrai téléphone à faire |
| D5 | mineure | fusion | Étape `planche` avec l'interface : la barre haute coupe le haut des têtes de la 1re rangée de Gérard, et « MA MAISON » flotte sur le fond crème | Décaler la planche sous la bande du HUD ou masquer l'interface pour cette étape |
| D6 | mineure | ville | La série `-Serie` de la branche ville ne produit plus `polices` ni `carte_fermee` (présentes dans la série de l'atelier) | Faites à la main sur la fusion : vertes ; à rajouter à la série |

### 5. Non vérifié
- Ressenti du mouvement (marche, dérive des nuages, fondu de 3 s, feuilles) : images fixes seulement.
- Vrai téléphone (taille physique de Gérard, D4), 1440p et 2160p réels (le ×4 est contrôlé par `-Facteur 4`).
- Rendu de l'orage à l'œil (aucune étape de capture).
- Plein écran de `Voir_PX0.bat` vu à l'œil (vérifié par le code de sortie de `--px0-quitter-apres` et l'option `--fullscreen`).
