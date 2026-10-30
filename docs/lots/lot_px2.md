# Lot PX2 : toute l'interface en pixel art (HUD, modales, fenêtres, historique, carnet, écran titre)

- Origine : décision du joueur du 29/10 (« pour ce qui est de l'interface, on passe tout en pixels… chiffres et textes longs dans une police nette ») et verdict sur PX0 bis (« Interface ok » : barre haute et frise sombres de PX0 conservées), puis l'ordre de tout continuer (30/10). Références : docs/16 §3 (interface, polices, cadres 9-patch, écran par écran), §5.3 (carte du banquier), §5.4 (journal), §6.2 (ce qui change dans le code), §9 ; le code de PX0 (`scripts/pixel/ui/*_px0.gd`, `data/pixel/ui/*.txt`), validé par le joueur.
- Objectif : habiller **toute** l'interface du jeu réel dans le style de PX0 : thème (`style.gd`), polices embarquées, cadres 9-patch pixel, barre haute, frise, panneau « Mon argent », notifications, étiquettes des bâtiments, toutes les modales (cartes du banquier en papier, journal, courrier, relevé, fin, info, confirmation, menu), **historique en classeur**, fenêtre Banque et **carnet**, écran titre, portraits et pièces ; avec une **échelle tactile garantie (≥ 48 dp)** et un **bouton HISTORIQUE agrandi**. Avant l'habillage : T16 (Échap sur un courrier relu) et T9 (découpage de `modales.gd`).
- Ce que le joueur verra (après fusion de PX1 et PX2, export 0.3) : le même jeu, entièrement en pixel art, chiffres et textes longs en Atkinson Hyperlegible Next, titres en Pixelify Sans.
- Hors périmètre : la rue (PX1, dev-ville) ; toute logique, donnée JSON, sauvegarde ; le bouton « Jusqu'au prochain courrier », le badge des non-lus, les pièces du mois, T13 et l'étape `raccourcis` de `capture.ps1` (lot 02, partie interface) ; les cartes de dilemme, de projet, le classement, les bulles (lots 03 à 07) ; les sons ; les graphiques « lisses » (`courbe`, `repartition`, `barres`, `piles`) restent lisses, dans les couleurs de la palette (docs/16 §6.2).
- Mode : **parallèle** de PX1 (dev-ville) et du lot 02 logique (dev-logique), fichiers strictement disjoints (§1). Un seul développeur : **dev-interface** (une seule instance : sa base `dev-interface.md` absorbe `dev-interface_px0.md`).
- Base : `main` **après** la fusion de PX0 et le commit de ce plan.
- Décisions prises sans demander au joueur (PX0 validé tel quel) : date et patrimoine en **Atkinson** (Jersey 10 abandonnée, police gardée dans le dépôt) ; panneaux sombres (`nuit`) conservés ; étiquettes des bâtiments sur la chaussée.

## 0. Mise en place (coordinateur)

```powershell
$git = "C:\Users\arthu\Documents\temp\JeuClaude\outils\git\cmd\git.exe"
$depot = "C:\Users\arthu\Documents\temp\JeuClaude"
& $git -C $depot worktree add -b lot/px2-interface C:\Users\arthu\Documents\temp\JeuClaude_lots\px2-interface main
```
- `tests.ps1` et `capture.ps1` trouvent Godot depuis le worktree ; `user://` commun : ne jamais effacer `partie_en_cours.sav`.
- Commits locaux en français, un par tâche (§4), sans push, jusqu'à l'OK du testeur. Le commit de T9 (découpage) est **séparé** de tout changement visuel.

## 1. Fichiers attribués (tout fichier absent de ce tableau est interdit)

Chemins relatifs à `godot/` sauf mention. Les `.uid` suivent leur script.

| Fichier | Nature |
|---|---|
| `scripts/ui/*.gd` (tous) et nouveaux fichiers dans `scripts/ui/` (découpage de `modales.gd`, cadres, polices) | Thème, HUD, modales, fenêtre Banque, historique, écran titre, portraits, pièces |
| `scripts/principal.gd` | Câblage seulement (≤ 600 lignes) ; B3 (`_info()` mort) |
| `scripts/ecran.gd` | Échelle d'interface, dp, format téléphone simulé (§2.3) |
| `scenes/principal.tscn`, `project.godot` (toutes sections ; `config/version` passe à `"0.3"`) | `[display]`, `[gui]`, `[rendering]` si l'échelle l'exige ; **pas** de changement de `[autoload]` |
| `scripts/pixel/ui/*.gd`, `data/pixel/ui/*.txt`, `polices/**/*.ttf.import` | Code et grilles de PX0 : à reprendre dans `scripts/ui/` ; les fichiers `*_px0.gd` sont **supprimés à la fin** (la vitrine PX0 tourne alors sans interface, prévu par CA-A3 de PX0) |
| `shaders/papier.gdshader` | Remplacé ou supprimé si le papier devient un 9-patch |
| `assets/icone/`, `icon.svg`, `outils/generer_icones.gd` | Seulement si l'icône change (facultatif) |
| `scripts/outils/capture.gd`, `reglages.gd`, `raccourcis_test.gd`, `scenarios_capture.gd`, familles `scripts/outils/scenarios/{titre,banque,ecrans,outils}.gd`, nouvelle famille `scenarios/interface.gd` | Étapes de capture et contrôles `UI ` |
| `outils/capture.ps1` (liste en commentaire) et **nouveau** `outils/capture_interface.ps1` (série PX2) | |
| `tests/test_interface.*`, `tests/test_partie.*` | **Attribués à dev-interface pour ce lot** (ils instancient l'interface) ; nouveau `tests/test_ecran.gd` permis |
| `docs/connaissances/dev-interface.md` ; suppression de `docs/connaissances/dev-interface_px0.md` après fusion de son contenu | Sa base |

**Interdits** : `scripts/ville/*`, `scripts/pixel/*.gd` hors `scripts/pixel/ui/`, `data/pixel/ville/`, `data/pixel/LISEZMOI.md`, `scripts/juice.gd`, `shaders/ciel.gdshader`, `scripts/outils/scenarios/ville.gd`, `scripts/logique/*`, `scripts/partie.gd`, `data/*.json`, `tests/test_logique.*`, `tests/test_demo.*`, `tests/test_pixel.gd`, `tests/test_rue.gd`, `tests/recette/`, `tests/autocontrole/`, `outils/tests.ps1`, `outils/trouver_godot.ps1`, `outils/capture_ville.ps1`, `outils/capture_px0.ps1`, `export_presets.cfg`, `*.bat`, `polices/*.ttf` et licences, `docs/` hors sa base. **Lecture seule** : `PalettePixel`, `GrillePixel` (couleurs, grilles, portrait `ville/lefranc_*`), `Partie`, `EtatPartie` et les statiques listées dans la base du chef de projet §2.

## 2. Interfaces (fixées avant le lancement)

### 2.1 Couleurs et grilles
Toute couleur de l'interface vient de `PalettePixel.couleur(<nom>)` (les 40 premières couleurs, docs/16 §2.3) ; aucune `Color("#…")` ni `Color(0.…)` dans `scripts/ui/` sauf l'alpha d'affichage (`Color(c, a)`). Grilles d'interface dans `data/pixel/ui/` (format `data/pixel/LISEZMOI.md`), chargées par `GrillePixel.charger_dossier("ui")` ; portrait de M. Lefranc par `GrillePixel.texture("ville/lefranc_affable"|"ville/lefranc_grave")` (si absent : cadre crème vide, sans erreur).

### 2.2 Ce que PX2 garde (appelé par `Sequences`, `Juice`, la ville, les tests et les autres familles) — **ne rien retirer, ne rien renommer**
- `Style` (`class_name`) : **tous** ses membres publics actuels (constantes dont `SOURCES`, `TEXTE`, et fonctions `chiffres`, `ui`, `ui_gras`, `capitales`, `led`, `manchette`, `titre_journal`, `journal`, `neon`, `boite`, `bordure`, `ombre`, `panneau`, `carte`, `bouton_principal`, `bouton_secondaire`, `boite_notification`, `etiquette_batiment`, `pastille`, `theme`, `label`, `bouton`, `ombre_de`) : la ville vectorielle s'en sert tant que PX1 n'est pas fusionné. Les types de retour peuvent devenir plus généraux (`StyleBox` au lieu de `StyleBoxFlat`) seulement si aucun appelant hors `scripts/ui/` n'utilise un membre de `StyleBoxFlat` (à vérifier par recherche, résultat dans le compte rendu).
- `Hud` : signaux actuels ; `var ville`, `rect_libre()`, `maj(e, anime, duree_roule)`, `_duree_mois()`, `maj_vitesse(v)`, `notifier(n, a, depart)`, `point_banque(oui)`, `afficher(oui, anime)`, `basculer_panneau(ouvrir)`, `var etiquettes` (dictionnaire id → nœud).
- `Modales` (reste la **façade** après T9, `class_name Modales`, `extends Control`) : `signal choix_fait(genre, id)`, `ouverte()`, `fermer(id)`, `journal(c, depart, spectaculaire, lecture_choix)`, `journaux_volants(depart, n)`, `courrier(c, depart, e, lecture_choix, ab_lecture)`, `presentation(c, depart, lecture, bandeau)`, `ouvrir_banque(e, produit, montant, depart)`, `confirmer(titre, texte, oui, non)`, `releve(n, a)`, `fin_demo(e)`, `info(titre, lignes, depart, extra)`, `menu()`, `historique(e, filtre, defilement)`, `lecture_notification(h, a)`, `var donnees_demo`, `var genre_courant`.
- `EcranTitre` : `jouer_demande`, `nouvelle_partie_demandee`, `construire`, `maj`, `texte_reprise`, `donner_focus`. `Piece.voler(depart, arrivee, duree, delai, a_l_arrivee)` (appelé par `Juice.pieces`). `PanneauBanque`, `CarteProduit`, `Portrait` : signaux actuels.
- **T15** : `PanneauBanque.zone_droite() -> Control` et `PanneauBanque.bouton_valider() -> Button` ; `test_interface` les utilise à la place de `_droite` / `_b_ok`.
- Le test de recette du testeur (`tests/recette/test_recette_decoupage`) touche du privé de `Modales` : après T9, **le testeur** l'adapte (lancé seulement par `tests.ps1 -Recette`) ; dev-interface écrit dans son compte rendu la correspondance ancien → nouveau.

### 2.3 Échelle d'interface et cibles tactiles — `scripts/ecran.gd`
- **Texel entier** : un texel des cadres (grille 640 × 360 de docs/16 §3.3) = T pixels physiques entiers, T = max(1, floor(hauteur physique / 360)) sur PC (720p : 2 ; 1366 × 768 : 2 ; 1080p : 3 ; 1440p : 4). Méthode libre (recommandée : garder la base virtuelle 1920 × 1080 en `expand` et régler `content_scale_factor` pour que 3 px virtuels = T px physiques) ; elle est décrite dans le compte rendu.
- **dp** : 1 dp = dpi / 160 pixels physiques (`DisplayServer.screen_get_dpi()` sur mobile, 1 sur PC). **Téléphone simulé** (F10, `--telephone`) : fenêtre **1600 × 720 à 267 dpi** (téléphone 20:9 de 6,5 pouces ; 1 dp = 1,67 px), à la place de 1200 × 540 × 1,7. Sur mobile, T est le plus petit entier qui garantit les cibles de 48 dp.
- Nouveaux membres (statiques purs pour les tests, plus l'état courant) :
```gdscript
static func facteur_texel_pour(taille_physique: Vector2i, dpi: float, mobile: bool) -> int
static func echelle_pour(taille_physique: Vector2i, dpi: float, mobile: bool) -> float   # px physiques par px virtuel
func facteur_texel() -> int
func dp() -> float                        # px physiques par dp
func cible_min() -> float                 # côté minimal d'une cible tactile, en px virtuels (48 dp)
```
- **Toute cible tactile** (bouton, onglet, ligne d'historique, carte du carnet, bâtiment de l'interface, croix de fermeture, bascule) a un côté minimal ≥ `cible_min()` sur mobile et sur le téléphone simulé ; sur PC, ≥ 40 px physiques à 1280 × 720. `Style.bouton()` et les cadres l'appliquent par défaut.
- **Bouton HISTORIQUE agrandi** : icône + libellé, hauteur ≥ 1,5 × l'actuelle sur PC (60 → ≥ 90 px virtuels à 1080p), ≥ 96 px physiques de haut et ≥ 200 de large sur le téléphone simulé, jamais recouvert (panneau « Mon argent » ouvert ou fermé, notifications).

### 2.4 Étiquettes des bâtiments et rue large (contact avec PX1, sans dépendance)
- Si `ville.has_method("point_etiquette")` : étiquette en `ville.point_etiquette(id)` ; sinon, comme aujourd'hui (`position_ecran(b.position + Vector2(0, 56))`).
- Si `ville.has_method("est_visible")` et que le bâtiment n'est pas visible : l'étiquette devient une **flèche de bord** (« ‹ LA GAZETTE », « MA BANQUE › ») qui, touchée, appelle `ville.aller_vers(id)` ; mise à jour sur `camera_bougee` si le signal existe, sinon à chaque image.
- Aucune autre lecture de la ville. Les flèches ← → et le glisser horizontal sur la rue appartiennent à la ville (défilement, PX1) : l'interface ne les intercepte pas hors de ses fenêtres. La branche se vérifie seule avec l'ancienne ville (chemin « sinon ») ; le chemin PX1 est vérifié à la fusion (§7).

### 2.5 Inchangé
Pas de sauvegarde, de signal de `Partie`, de donnée JSON, d'autoload. Nouveaux `class_name` permis : `CadresPixel` (9-patch), `PolicesPixel` (polices), et ceux des morceaux de `modales.gd` (T9) — liste exacte dans le compte rendu ; aucun ne recoupe `PalettePixel`, `GrillePixel`, `VuePixel`, `MatieresPixel`, `RuePx0`, `Batiment`, `Sequences`.

## 3. Écran par écran (docs/16 §3.4 ; même contenu, mêmes comportements qu'aujourd'hui)

| Écran | Habillage |
|---|---|
| Barre haute | Celle de PX0 (date en volets, boutons du temps, compte, patrimoine, pastille « vs tout au Livret A », menu) ; B1 : graduations de « Mon argent » jamais recouvertes |
| Frise + HISTORIQUE | Frise pixel 1984 → 1988 avec curseur ; bouton HISTORIQUE agrandi (§2.3) |
| Panneau « Mon argent » | Panneau 9-patch, courbe et répartition lisses dans les couleurs de la palette, ligne des versements auto, frais en cuivre |
| Notifications | Pastilles pixel par source (maison orange, banque or, média rose) |
| Cartes du banquier | Papier crème, coin corné, liseré or, en-tête de la banque, portrait 48 × 48 (affable / grave), tampon, ticket dentelé, bouton ambre (PX0, docs/16 §5.3) |
| Journal | Page de la Gazette : manchette en Pixelify, texte en Atkinson, filet, 3 choix (docs/16 §5.4) |
| Courrier, relevé, fin, info, confirmation, menu | Enveloppe / papier ; relevé avec piles ; fin de démo ; cadres sombres pour info, confirmation, menu |
| Historique | **Classeur** : onglets pour les filtres (TOUT, MA MAISON, MA BANQUE, LA GAZETTE, avec le nombre), lignes à pastille de source, défilement, relecture en lecture seule |
| Fenêtre Banque | Carnet 3 × 3 (cartes produit pixel, icône calendrier), fiche, formulaire d'ordre, CHAQUE MOIS, avertissement des frais |
| Écran titre | Titre en Pixelify sur la rue au crépuscule, boutons CONTINUER / NOUVELLE PARTIE, confirmation |
| Portraits, pièces, icônes | Portrait pixel (grille de M. Lefranc), pièces or et cuivre 8 × 8 texels, icônes 16 × 16 de PX0 |

## 4. Tâches (dans cet ordre ; un commit par tâche)

1. **T16** : étape de capture `courrier_relu_echap` qui reproduit l'Échap pendant le vol de l'enveloppe d'un courrier relu (SCRIPT ERROR actuel, `modales.gd` l. 589) ; correction.
2. **T9** : découpage de `modales.gd` (≈ 1 453 l.) en une façade `Modales` et des morceaux (base commune ; journal ; courrier et naissance ; carte du banquier ; relevé et fin ; info, confirmation, menu ; historique), **sans aucun changement visuel** ; `tests.ps1` vert ; captures `presentation_livret`, `journal`, `courrier`, `historique`, `fin` identiques avant / après (comparaison par le testeur).
3. **Échelle** (§2.3) : `Ecran`, téléphone simulé 1600 × 720, `test_ecran.gd`.
4. **Thème** : `style.gd` sur polices embarquées (`FontFile`, réglages de PX0) et cadres 9-patch (`CadresPixel`, `PolicesPixel` repris de PX0) ; aucune `SystemFont`.
5. **HUD** : barre haute, frise, HISTORIQUE agrandi, panneau « Mon argent » (B1), notifications, badge de pause, étiquettes (§2.4).
6. **Modales** : cartes du banquier, journal, courrier, relevé, fin, info, confirmation, menu.
7. **Historique en classeur** et relectures.
8. **Fenêtre Banque et carnet** (T15).
9. **Écran titre**, portraits, pièces ; B3 (`principal._info()`) ; `config/version="0.3"`.
10. **Fin** : suppression de `scripts/pixel/ui/*_px0.gd` (et de ce qui n'est plus utilisé de `data/pixel/ui/`), série de captures (§6), base `dev-interface.md` (avec le contenu de `dev-interface_px0.md`, puis suppression de ce dernier), compte rendu (fichiers, écarts, décisions prises seul, ce qui n'est pas vérifié).

## 5. Critères d'acceptation (testeur, `docs/lots/lot_px2_recette.md`)

Commandes depuis le worktree `px2-interface`. Lignes de contrôle `UI ` imprimées avec `--controle` par la famille `interface` (ou les familles existantes).

- **CA-I1 (tests)** : `tests.ps1` vert, aucune erreur de script, total ≥ référence de `main` à la création de la branche (+ `test_ecran`) ; `test_interface` passe par les nouveaux accesseurs de T15.
- **CA-I2 (T16)** : étape `courrier_relu_echap` : code 0, aucune ligne `SCRIPT ERROR`, `UI echap_courrier fermee=oui`.
- **CA-I3 (T9)** : `modales.gd` ≤ 450 lignes ; morceaux listés, aucun > 450 lignes ; au commit de T9, les 5 captures citées en §4.2 sont identiques à celles du commit précédent (différence de pixels ≤ 0,5 %, mesure du testeur) ; `test_interface` vert à ce commit.
- **CA-I4 (échelle, `test_ecran`, headless)** : `facteur_texel_pour` et `echelle_pour` donnent, pour (1280 × 720, PC) T = 2, (1366 × 768, PC) T = 2, (1920 × 1080, PC) T = 3, (2560 × 1440, PC) T = 4 ; pour (1600 × 720, 267 dpi), (2400 × 1080, 400 dpi), (2340 × 1080, 395 dpi), (1280 × 720, 320 dpi) en mobile : `cible_min()` × échelle ≥ 48 dp, et T entier ; ≥ 20 vérifications.
- **CA-I5 (texels nets)** : étape `planche_cadres` (tous les 9-patch et icônes, sur fond uni) à 1280 × 720, 1366 × 768, 1920 × 1080 et `-Telephone` : `UI cadres facteur_texel=<T> irreguliers=0` (chaque bloc T × T des cadres est uniforme).
- **CA-I6 (cibles tactiles)** : étape `cibles` en `-Telephone` et à 1280 × 720 : parcourt l'écran titre, la rue avec HUD (panneau ouvert et fermé), une carte du banquier, le journal du krach, un courrier, le relevé, la fin, l'info, la confirmation, le menu, l'historique (onglets et lignes), la fenêtre Banque (carnet, fiche, ordre, CHAQUE MOIS) : `UI cibles ecran=<nom> n=<n> min=<px physiques> sous_seuil=0` pour chacun (seuil : 80 px au téléphone simulé, 40 px à 1280 × 720).
- **CA-I7 (HISTORIQUE)** : `UI historique hauteur=<px> largeur=<px> recouvert=non` : à 1080p hauteur ≥ 90 px ; au téléphone simulé hauteur ≥ 96 et largeur ≥ 200 px physiques ; recouvert=non panneau ouvert et fermé ; capture `hud_1080`, `hud_tel`.
- **CA-I8 (polices)** : aucune `SystemFont` ni `Color("#` dans `scripts/ui/` (recherche) ; `UI polices pixelify_min=<n> atkinson=oui` avec Pixelify jamais sous 28 px virtuels ; chiffres du HUD en Atkinson ; captures `polices_jeu` : accents français complets (« ÉÈÊÀÇÔŒÙÎ àéèêçôœùî « » ») sans carré vide.
- **CA-I9 (textes)** : sur chaque écran de CA-I6 au téléphone simulé et à 1366 × 768 : `UI debordements=0` (aucun `Label` dont le texte dépasse sa boîte sans retour à la ligne ni ellipse prévue) ; relecture visuelle du testeur : aucun texte coupé ni chevauché.
- **CA-I10 (écrans, PC 1920 × 1080 et téléphone simulé)** : captures `titre`, `titre_confirmer`, `jouer`, `pause`, `panneau`, `presentation_livret`, `presentation_av`, `heritage`, `krach`, `courrier`, `releve`, `f01`, `fin`, `historique`, `historique_filtre`, `historique_entree`, `carnet`, `carnet_pel`, `banque_ordre`, `automatique`, `foyer`, `comparaison_info`, `clic_dehors` : habillage du §3, cadres pixel, papier pour les cartes, classeur pour l'historique ; montages `px2_montage_pc` (`v3_rue.png` | `hud_1080`) et `px2_montage_carte` (`px0_carte_1080` | `heritage`).
- **CA-I11 (comportements inchangés)** : étapes `clic_dehors` (fermetures par clic à côté conformes à `developpeur.md` §2), `integrale` (60 mois à ×3, réponses par l'interface) : code 0 ; touches 1/2/3, Espace, P, M/B, H, Échap inchangées (N reste libre pour le lot 02) ; `sauver_fermer` puis `reprise` : « Continuer » reprend la partie.
- **CA-I12 (étiquettes)** : avec la ville de `main` (vectorielle) : étiquettes comme avant (`rue`). Le chemin « rue large » (flèches de bord, `aller_vers`) est vérifié à la fusion simulée avec PX1 (§7) : captures `etiquettes_bord` (banque hors écran : flèche « MA BANQUE › ») et `etiquettes_aller` (après toucher : la banque est visible).
- **CA-I13 (fluidité)** : étape `fps` à 1920 × 1080 et au téléphone simulé : ≥ 55 images par seconde.
- **CA-I14 (périmètre)** : `git diff --stat main...lot/px2-interface` limité au §1 ; `project.godot` : seulement `config/version="0.3"` et les clés d'échelle décrites dans le compte rendu ; aucun `*_px0.gd` restant dans `scripts/pixel/ui/` ; `Voir_PX0.bat` (avec `-- --px0-quitter-apres=5`) se lance encore sans erreur (sans interface).
- **CA-I15 (`user://` intact)** : comme CA-V15 de PX1, autour de `capture_interface.ps1 -Serie`.
- Non vérifiable ici (à écrire comme tel) : vrai téléphone (dpi réel, défilement tactile de l'historique, confort des cibles) ; écrans 1440p et 2160p réels (calculés par `test_ecran`).

## 6. Série de captures (`outils/capture_interface.ps1 -Serie`, préfixe `px2_`)
Toutes les captures de CA-I10 en PC 1920 × 1080 et téléphone simulé, plus `hud_720`, `hud_1366`, `planche_cadres` (4 formats), `cibles` (2 formats), `polices_jeu`, `courrier_relu_echap`, `fps`, et les montages. Journal `godot/captures/px2_serie.log` ; code 0 seulement si chaque lancement rend 0, sans erreur de script, et tous les contrôles à zéro (`irreguliers=0`, `sous_seuil=0`, `debordements=0`).

## 7. Fusion et vérifications après fusion
- Ordre : celui des OK (PX1, PX2, lot 02 logique). La recette de la **dernière** des trois branches simule la fusion des trois avec `main` (copie isolée, `user://` à part) : `tests.ps1` ; `capture_ville.ps1 -Serie` ; `capture_interface.ps1 -Serie` ; captures `etiquettes_bord`, `etiquettes_aller`, `banquier_anim`, `krach_anim`, `heritage`, `fin` relues ensemble (HUD sur la rue de briques).
- Après fusion des trois sur `main` (chef de projet) : mêmes commandes, puis export 0.3 (exe + APK, dev-logique, lot 02) et liste de contrôle du téléphone (T2) pour le joueur.

## 8. Validation (chef de projet)
- [ ] CA-I1 à CA-I15 (rapport du testeur OK) · [ ] série relue · [ ] fusion `--no-ff`, tests et séries relancés sur `main` · [ ] bases à jour
- Décision :
