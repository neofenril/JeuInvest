# Lot PX1 : la rue du jeu en pixel art (rue large, caméra qui glisse, séquences, personnages)

- Origine : verdicts du joueur (docs/10) sur PX0 bis (« style bien… largeur rue avec défilement bien… interface ok… garde la taille des personnages »), PX0 ter (« inspire-toi à fond… mini effet 3D… un peu moins pixelisé ») et validation de PX0 quater (45f5120) avec l'ordre de **tout continuer**. Règles graphiques : docs/16 §9 (prime sur §2 et §8 pour la rue), puis §8.1, §8.2, §8.4, §2.4, §2.5.
- Objectif : remplacer la ville vectorielle du jeu (`godot/scripts/ville/`) par la rue pixel de PX0 quater, **dans le jeu réel** : maison de Gérard, **banque** et **Gazette** jouables sur une **rue plus large que l'écran** ; la caméra **glisse** vers le bâtiment qui parle puis revient ; le joueur peut faire défiler la rue ; toutes les séquences animées existantes refaites en pixel ; trafic et passants (accélérés avec la vitesse du jeu) ; nuit, saisons, pluie, ciel de krach, gel de la pause ; écran titre (la rue au crépuscule) ; Sylvie à la fenêtre (3 humeurs, API) ; voisins de docs/15 dessinés (Tata Livret, Tonton Matelas, Jean-Mi, Mme Lopez, M. Lefranc) et capables de traverser la rue (API, sans règle de jeu).
- Ce que le joueur verra (après fusion de PX1 **et** PX2, export 0.3) : le jeu entier dans la rue de briques validée, à la place de la ville vectorielle. Aucune règle de jeu ne change.
- Hors périmètre : HUD, modales, fenêtres, frise, historique, carnet, écran titre (ses boutons), polices, thème (PX2, dev-interface) ; toute logique (`scripts/logique/`, `partie.gd`, données JSON) ; les pièces du mois de P4 (lot 02, partie ville) ; le moment où les voisins passent, leurs bulles et le classement (lot 05) ; l'humeur de Sylvie calculée (lot 03 : PX1 fournit seulement `regler_humeur_sylvie`) ; la séquence du Lundi noir (lot 06) ; les sons (T6).
- Mode : **parallèle** de PX2 (dev-interface) et du lot 02 logique (dev-logique), fichiers strictement disjoints (§1). Un seul développeur : **dev-ville**.
- Base : `main` **après** la fusion de PX0 (`lot/px0-ville` puis `lot/px0-interface`, après OK du testeur et ma validation) et le commit de ce plan.

## 0. Mise en place (coordinateur)

```powershell
$git = "C:\Users\arthu\Documents\temp\JeuClaude\outils\git\cmd\git.exe"
$depot = "C:\Users\arthu\Documents\temp\JeuClaude"
& $git -C $depot worktree add -b lot/px1-ville C:\Users\arthu\Documents\temp\JeuClaude_lots\px1-ville main
```
- Dans le worktree : `tests.ps1` et `capture.ps1` trouvent Godot seuls (`trouver_godot.ps1`) ; pour les autres scripts, `$env:JEUCLAUDE_GODOT = "C:\Users\arthu\Documents\temp\JeuClaude\outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"` dans **la même commande** (la variable ne persiste pas).
- Référence de style (non versionnée, lecture seule) : `C:\Users\arthu\Documents\temp\JeuClaude\docs\sources\graphisme\references\rue_pixel_v2.jpg` ; ne jamais la décalquer.
- `user://` est commun à tous les worktrees et au joueur : ne jamais effacer `partie_en_cours.sav` ; les captures du jeu utilisent `user://capture.sav` (déjà en place).
- Les `*.ttf.import` appartiennent à dev-interface : ne pas les commiter.
- Commits locaux en français, un par tâche (§4), sans push, jusqu'à l'OK du testeur.
- Recette PX0 (D1) : un fichier absent du §1 est interdit **même recopié à l'identique** de `main` (`tests.ps1`, `trouver_godot.ps1` : ils sont déjà sur `main`, rien à recopier).

## 1. Fichiers attribués (tout fichier absent de ce tableau est interdit)

Chemins relatifs à `godot/` sauf mention. Les `.uid` suivent leur script.

| Fichier | Nature |
|---|---|
| `scripts/ville/*.gd` (dont `ville.gd`, `sequences.gd`, `batiment.gd`, `maison.gd`, `banque.gd`, `media.gd`, `rue.gd`, `plan_fond.gd`, `passant.gd`, `voiture.gd`, `reverbere.gd`, `accessoire.gd`, `dessin.gd`) | Réécriture en pixel. Création, suppression et renommage permis **sauf** les deux `class_name` existants : `Batiment` (`batiment.gd`) et `Sequences` (`sequences.gd`), conservés (§2) |
| `scripts/pixel/*.gd` hors `scripts/pixel/ui/` (`palette`, `grille`, `vue_pixel`, `matieres`, `facades`, `personnages`, `vehicules`, `rue_px0`, `px0`, nouveaux) | Atelier : complété ; `rue_px0.gd`, `px0.gd` gardés **en état de marche** (§2.5) |
| `scenes/px0.tscn`, `outils/capture_px0.ps1`, `Voir_PX0.bat` (racine) | Seulement si une modification de l'atelier les casse |
| `data/pixel/ville/*.txt`, `data/pixel/LISEZMOI.md` | Grilles (portraits) et documentation |
| `scripts/juice.gd` | **Seulement** `secouer()` et `_process()` (secousse de la caméra de la rue, en px d'art entiers). Les signatures et le comportement de `rouler`, `pop`, `flottant`, `pieces`, `duree` ne changent pas (PX2 s'en sert) |
| `shaders/ciel.gdshader` | Peut rester inutilisé ; **ne pas le supprimer** (`principal.gd` le charge, l. 83) |
| `scripts/outils/scenarios/ville.gd` | Famille de captures « ville » (étapes existantes + nouvelles, §6) |
| `tests/test_pixel.gd` | Adapté si l'atelier change |
| `tests/test_rue.gd` | **Nouveau** (découvert seul par `tests.ps1`) |
| `outils/capture_ville.ps1` | **Nouveau** : série PX1 (§6) |
| `docs/connaissances/dev-ville.md` | Sa base |

**Interdits** (en plus de tout fichier absent) : `scripts/principal.gd`, `scripts/ecran.gd`, `scripts/ui/*`, `scripts/pixel/ui/*`, `data/pixel/ui/*`, `polices/**`, `scenes/principal.tscn`, `project.godot`, `scripts/outils/*.gd` et les autres familles de `scripts/outils/scenarios/`, `outils/capture.ps1`, `outils/tests.ps1`, `outils/trouver_godot.ps1`, `scripts/logique/*`, `scripts/partie.gd`, `data/*.json`, `shaders/papier.gdshader`, `tests/test_interface.*`, `tests/test_partie.*`, `tests/test_logique.*`, `tests/test_demo.*`, `tests/recette/`, `export_presets.cfg`, `*.bat` hors `Voir_PX0.bat`, `docs/` hors sa base. **Lecture seule permise** : tout le reste (en particulier `Partie`, `EtatPartie`, `Dates`, `Format`, `data/rythme.json`, `hud.gd`, `principal.gd`). Un besoin hors tableau : l'écrire dans le compte rendu, ne pas le faire.

## 2. Interfaces (fixées avant le lancement)

### 2.1 API conservée de la ville (lue par `principal.gd`, `hud.gd`, les scénarios, `Juice`) — **ne rien retirer, ne rien renommer**
`principal.gd` crée la ville par `Node2D.new()` + `set_script("res://scripts/ville/ville.gd")` : **`ville.gd` reste `extends Node2D`**. Il peut créer en enfant un `CanvasLayer` (calque négatif, sous le HUD) qui porte une `VuePixel` plein écran : la rue est rendue dans son `SubViewport`, opaque (le `ColorRect` du ciel de `principal.gd` reste dessous, invisible : PX2 ou le lot 02 le retirera).

| Membre | Sens en PX1 |
|---|---|
| `signal batiment_touche(id: String)` | `"maison"`, `"banque"`, `"media"` ; un toucher bref (< 14 px de déplacement, comme l'historique) sur la façade ; un glisser fait défiler la rue et ne touche rien |
| `var anime`, `var interactif`, `var mode_titre` | Inchangés (`anime` faux : trafic, passants, nuages figés ; `interactif` faux : ni toucher ni défilement manuel) |
| `var facteur_trafic` | Lu par la ville dans `Partie.facteur_trafic(maxi(1, Partie.vitesse))` comme aujourd'hui (le lot 02 renverra 7 pendant le saut : rien à faire ici) |
| `var phase` (0 → 1) | Cycle jour/nuit : fondu entre les versions jour et nuit précalculées (`melange`), crépuscule à `phase = 0.585` (écran titre) ; `var nuit` (0 → 1) reste lisible |
| `var krach` (0 → 1) | Fondu vers la variante **orage** de la palette (ciel, façades), sans élément ajouté |
| `var gel` (0 → 1) | Teinte de pause : `modulate` de l'affichage (couleur `gel` de la palette, au plus 35 %), jamais dans les images |
| `var pluie: bool` | Pluie en pixel (traits de 1 × 3 à 1 × 5 px d'art, positions entières) |
| `var ciel_mat` | Accepté, peut être ignoré |
| `var camera: Camera2D` | La caméra du `SubViewport` (`Juice.camera = ville.camera`) ; position arrondie au px d'art |
| `var maison`, `var banque`, `var media: Batiment` ; `var voiture_maison`, `var potelet: Node2D` ; `var passants: Array` | Mêmes rôles ; `banque.aiguille` (0 → 1, horloge du fronton, écrit par `principal.gd` chaque image, suivi de `queue_redraw()`) ; `media.titre`, `media.titre_lettres` (enseigne du titre lettre à lettre, écrits par `principal.gd`) |
| `func regler_mois(mois: int, annee: int)` | Saison (été = référence ; printemps, automne, hiver avec neige au sol et sur les toits, flocons), variantes d'époque (distributeur de la banque à partir de 1986) |
| `func cadrer(libre: Rect2, duree := 0.0)` | `libre` = rectangle d'écran laissé par le HUD (px virtuels) : le sol posé juste au-dessus du bas de `libre`, la cheminée de la maison sous son haut ; garde la position horizontale courante |
| `func viser(b: Batiment, duree := 0.35, zoom_en_plus := 1.06)` | Glisse horizontalement pour centrer `b` dans `libre` ; **pas de zoom** (un zoom non entier casse la grille) : `zoom_en_plus` ignoré |
| `func revenir(duree := 0.35)` | Revient à la position d'avant le dernier `viser` / `aller_vers` (ou à la maison) |
| `func plonger_vers_maison(duree := 0.8) -> Tween` | Écran titre → jeu : la caméra glisse de la Gazette (enseigne du titre) vers la maison ; renvoie le `Tween` (attendu par `principal.jouer`) |
| `func position_ecran(monde: Vector2) -> Vector2` | px d'art → px virtuels de l'interface (`VuePixel.monde_vers_ecran`) |
| `func ecran_batiment(b: Batiment, decalage := Vector2.ZERO) -> Vector2` | `position_ecran(b.position + decalage)` ; `decalage` en px d'art de la grille 960 × 540 (les appels existants passent `(0, -150)` à `(0, -470)` : point sur la façade, ou au-dessus pour la Gazette) ; le point peut être **hors écran** si le bâtiment l'est |
| `func batiment(id: String) -> Batiment` | `"maison"`, `"banque"`, `"media"` |
| `Batiment` (`class_name`) : `id`, `nom`, `zone`, `contient(point_local)`, `survoler(oui)`, `enfoncer()`, `signal touche`, `dessiner_lumieres(ci)` | Conservés. **`position` = milieu du pied de la façade, au niveau du sol** (y = `SOL`) : `hud.gd` place les étiquettes en `position_ecran(b.position + Vector2(0, 56))`, ce qui tombe sur la chaussée |
| `Sequences` (`class_name`) : `installer(jeu, ville, hud, modales, calque_modales)`, `jouer_modale(c)`, `fin()`, `vedette(f)`, `maj_media(anime)`, `clignoter_maison()`, `petite_news(n)`, `var occupe` | Conservés (appelés par `principal.gd` et les scénarios). `Sequences` continue d'appeler `hud.maj`, `hud.notifier`, `hud.point_banque`, `hud._duree_mois`, `modales.presentation`, `journal`, `courrier`, `fin_demo`, `journaux_volants`, `choix_fait`, `donnees_demo` : PX2 s'engage à les garder (lot_px2 §2.2) |

### 2.2 Ajouts (nouveaux membres de `ville.gd` ; PX2 et les lots suivants les appellent par `has_method`, jamais avant fusion)
```gdscript
func point_etiquette(id: String) -> Vector2          # px virtuels : sur la chaussée, sous le milieu du bâtiment (étiquettes du HUD)
func est_visible(id: String) -> bool                 # vrai si le bâtiment est entièrement dans le rectangle libre
func aller_vers(id: String, duree := 0.5) -> Tween   # glisse vers un bâtiment (sans changer la position de repos)
func position_camera() -> float                      # x du centre de la vue, px d'art
func bornes_rue() -> Vector2                         # x mini et maxi de la caméra
func regler_humeur_sylvie(h: int) -> void            # 0 contente, 1 neutre (défaut), 2 fâchée ; + clignement ; bulle : lot 03
func humeur_sylvie() -> int
func faire_passer(qui: String, sens := 1, vitesse := 1.0) -> Node2D   # traverse la rue (sens 1 : de gauche à droite), libéré à la sortie ; qui ∈ PERSONNAGES
func point_tete(n: Node2D) -> Vector2                # px virtuels, au-dessus de la tête (bulles de l'interface, lot 05)
const PERSONNAGES := ["gerard", "tata", "matelas", "jeanmi", "lopez", "lefranc", "passant_1", "passant_2", "passant_3"]
signal camera_bougee                                 # après chaque déplacement de la caméra (étiquettes hors écran de PX2)
```

### 2.3 Règles de rendu (docs/16 §2.1, §9)
- **Proportions de 1080p sur tous les écrans (arbitrage D4 de la recette PX0, 30/10, remplace la ligne « 720p et téléphone : ×1 » de docs/16 §9)** : la vue montre toujours **540 px d'art de haut** (largeur = 540 × rapport de l'écran : 960 en 16:9, 1200 au téléphone 20:9). La rue est rendue dans le `SubViewport` à N_rue = max(2, ceil(hauteur physique / 540)) (entier, pixels nets dans le `SubViewport`), puis l'image est **réduite** à la composition d'un rapport R = hauteur physique / (540 × N_rue) ≤ 1, en filtre linéaire ; **jamais agrandie** d'un facteur non entier. 1080p : N = 2, R = 1 (pixels exacts) ; 2160p : N = 4, R = 1 ; 720p et téléphone 1600 × 720 : N = 2, R = 0,667 ; 1366 × 768 : N = 2, R ≈ 0,711 ; 1440p : N = 3, R ≈ 0,889. Gérard occupe donc 63/540 de la hauteur partout (84 px physiques en 720p, 126 en 1080p). Pixels un peu moins nets sous 1080p : assumé (le joueur a validé la taille des personnages, et demandé « un peu moins pixelisé »). Écarté : une variante dédiée du dessin pour les petits écrans (deux jeux de grilles et de générateurs à tenir, visages illisibles à 2/3) et l'agrandissement non entier ×1,33 (pixels irréguliers qui « grouillent » pendant le défilement). Toutes les conversions (`monde_vers_ecran`, toucher, `point_etiquette`, `point_tete`, `cadrer`) tiennent compte de R : l'interface n'a rien à faire. Le rapport R est porté par `VuePixel` (méthode libre, décrite dans le compte rendu) ; la vitrine PX0 peut garder l'ancienne règle.
- Échelle par axe (dev-ville.md §2) ; tout ce qui bouge est posé à des positions entières en px d'art ; **aucune rotation ni mise à l'échelle** de sprite dans le monde (une animation = des images) ; transparences seulement à l'affichage (`modulate`, calque additif des lumières).
- Aucune couleur codée en dur hors `palette.gd` dans `scripts/ville/` et `scripts/pixel/` (recherche de `Color("#`, `Color(0.`, `Color(1`) ; aucune dépendance à `Style` (`scripts/ui/style.gd`, que PX2 réécrit).
- Le jeu tourne **sans fenêtre** (`--headless`) : `test_interface` et `test_partie` instancient la scène principale ; la ville ne doit pas lire d'image de `SubViewport` hors captures.

### 2.4 Inchangé
Pas de sauvegarde, de signal de `Partie`, de donnée JSON, de réglage du projet, de `class_name` retiré. Nouveaux `class_name` autorisés : aucun (scripts nouveaux chargés par `preload`, comme `facades.gd`).

### 2.5 Vitrine PX0
`Voir_PX0.bat` et `capture_px0.ps1 -Etape jour -Controle` doivent encore marcher à la fin de PX1 (PX2 s'appuie sur les fichiers `scripts/pixel/ui/*_px0.gd` jusqu'à sa fin). Le nettoyage de la vitrine (`px0.gd`, `rue_px0.gd`, `px0.tscn`, `capture_px0.ps1`, `Voir_PX0.bat`) se fera au lot 03, après la fusion de PX2.

## 3. La rue (px d'art, grille 960 × 540, ×2 à 1080p)

- Longueur habillée **≥ 2 880 px** (3 vues à 1080p), décor au-delà des bornes de la caméra sur 200 px de chaque côté. De gauche à droite : … | **la Gazette** | 1 ou 2 bâtiments | **la maison de Gérard** | 1 ou 2 bâtiments (dont la boutique à auvent rouge) | **la banque** | … Distance entre le milieu de la maison et celui de la banque (et de la Gazette) : **600 à 900 px**.
- **Maison de Gérard** : celle de PX0 quater (228 × 258), fenêtre de Sylvie, boîte aux lettres jaune, porte sarcelle ; garde ses points d'ancrage pour les séquences (fenêtre de Gérard, rebord pour la naissance, boîte aux lettres).
- **Banque** (docs/16 §8.4) ≈ 270 × 285 : brique vive, encadrements, bandeau et petit fronton en pierre claire, **horloge** du fronton (aiguille = `aiguille`), porte en bois à deux battants, enseigne « BANQUE » dorée, fenêtre du banquier (silhouette de M. Lefranc pendant l'appel, combiné qui sonne, ondes), distributeur à partir de 1986.
- **La Gazette** ≈ 225 × 330 (sommet du journal lumineux compris, toujours sous la barre haute) : brique sombre, enseigne peinte « LA GAZETTE », vitrine des rotatives, **journal lumineux** du toit (ambre ; rouge et grésillement au krach : courbe des 30 derniers mois de l'indice, nom et valeur, bandeau défilant, en lettres pixel 3 × 5 de `MatieresPixel.texte`), néon rose ; enseigne du titre lettre à lettre en mode titre.
- **Repos** : la maison centrée dans le rectangle libre ; la caméra ne dépasse jamais `bornes_rue()`.
- **Défilement manuel** (si `interactif`) : glisser horizontal (souris, doigt), molette, flèches ← → ; inertie courte (≤ 0,4 s) ; la position choisie devient la position de repos.
- **Vie** : passants (3 figurines génériques + Gérard qui va et vient devant sa porte), voitures d'époque (R5, 205, 4L, une camionnette) sur deux voies, vitesses de `rythme.json > trafic` × `facteur_trafic`, nuages, feuilles ; voiture de Gérard garée devant la maison (`voiture_maison`) et potelet (`potelet`) pour la panne.
- **Personnages de docs/15** (figurines 36 × 63, contour teinté, 3 tons par matière, marche 4 images à 8 im/s, repos 2 images) : Tata Livret, Tonton Matelas, Jean-Mi (vendeur Peugeot ; variante à vélo), Mme Lopez (la concierge), M. Lefranc (costume, moustache ; variante qui fume devant la banque) ; enfants 22 × 36 et poussette (simple, double) pour plus tard ; **Porsche 944 rouge** (≈ 100 × 39) et panneau « À VENDRE ». Silhouettes et couleurs signatures : proposition de dev-ville, jugée par le joueur sur la planche.

## 4. Tâches (dans cet ordre ; un commit par tâche)

1. **Monde du jeu** : `ville.gd` sur `VuePixel` (avec la composition « N entier ≥ 2 puis réduction » de §2.3) + la rue de §3 (bâtiments, décor, sol), API §2.1 complète, `Batiment` pixel (toucher, survol : contour en surbrillance d'1 px d'art couleur `or`, enfoncement d'1 px), caméra, défilement, `cadrer`, `point_etiquette`, `est_visible`, `aller_vers`, `bornes_rue`, `camera_bougee`. Le jeu se lance, la scène principale tourne sans erreur, `tests.ps1` vert.
2. **Vie de la rue** : passants, Gérard, voitures, nuages, accélération (`facteur_trafic`), gel, `anime`.
3. **Temps et météo** : cycle jour/nuit (`phase`), crépuscule du titre, saisons (`regler_mois`), pluie, neige, ciel de krach (variante orage), lumières de nuit (fenêtres, lampadaires à halo en 3 disques, phares).
4. **Séquences** (`sequences.gd`, même enchaînement et mêmes modales qu'aujourd'hui, passables d'un toucher, A34) : appel du banquier (la caméra glisse vers la banque, combiné qui sonne, ondes, le signal file vers la maison, la caméra suit, la fenêtre de Gérard clignote, puis la carte) ; journal (glisse vers la Gazette, écran ; au krach : orage, pluie, écran rouge et grésillement, passants arrêtés, secousse, journaux volants) ; courrier (la boîte aux lettres s'ouvre, l'enveloppe part de la boîte) ; panne / crash burlesque (la voiture tousse, part seule, percute le potelet, « BONK » en lettres pixel, capot, fumée, enjoliveur, triangle ; réparée après le courrier) ; naissance (cigogne, paquet(s) — deux pour les jumeaux —, fenêtre allumée, confettis pixel) ; petite news (ondes de la Gazette ; **pas** de glissement de caméra) ; fin de démo ; écran titre et `plonger_vers_maison`. Après chaque séquence, `revenir`.
5. **Sylvie et les voisins** : Sylvie à la fenêtre (3 humeurs + clignement, `regler_humeur_sylvie`, défaut neutre), personnages de §3, `faire_passer`, `point_tete`, Porsche, panneau « À VENDRE », planche.
6. **Secousse** : `Juice.secouer` sur la caméra de la rue, en px d'art entiers (amplitude ≤ 4 px d'art).
7. **Tests, captures, base** : `test_rue.gd`, famille `ville` (§6), `capture_ville.ps1`, B2 (commentaire périmé d'`accessoire.gd`, si le fichier reste), base `dev-ville.md`, compte rendu.

## 5. Critères d'acceptation (testeur, `docs/lots/lot_px1_recette.md`)

Commandes depuis le worktree `px1-ville`. Captures dans `godot/captures/`. Toutes les lignes de contrôle commencent par `RUE ` et sont imprimées par la famille `ville` avec `--controle` (option lue par `ScenariosCapture.option`).

- **CA-V1 (tests)** : `powershell -ExecutionPolicy Bypass -File godot\outils\tests.ps1` : vert, aucune erreur de script, nombre total de vérifications ≥ (référence de `main` au moment de la création de la branche) + 30 ; durée totale ≤ 60 s.
- **CA-V2 (`test_rue`, headless, ≤ 15 s, ≥ 30 vérifications `OK`/`KO`, code 1 en cas d'échec)** : instancie `ville.gd` seule (Node2D + script) ; tous les membres de §2.1 et §2.2 existent (liste écrite dans le test) ; `batiment("maison"|"banque"|"media")` non nuls, `position.y == SOL` ; ordre Gazette < maison < banque et distances de §3 ; `aller_vers` puis `revenir` reviennent au repos ; la caméra reste dans `bornes_rue()` après un défilement simulé de ± 10 000 px ; `regler_mois` sur les 12 mois et `phase`, `krach`, `gel`, `pluie` aux bornes : aucune erreur ; `regler_humeur_sylvie(0..2)` relu par `humeur_sylvie()` ; `faire_passer` pour chaque `PERSONNAGES` renvoie un nœud libéré à la sortie ; génération de la rue ≤ 2 000 ms (`RUE generation_ms=<n>`) ; le rapport de §2.3 calculé par une fonction statique pure (ex. `VuePixel.facteur_et_reduction(Vector2i)`) pour 1280 × 720, 1366 × 768, 1600 × 720, 1920 × 1080, 2560 × 1440, 3840 × 2160 (valeurs de §2.3).
- **CA-V2 bis (`test_pixel`, recette PX0 D3)** : toujours vert, durée ≤ 15 s (10,4-11 s en PX0) ; palette à **67** couleurs dont les 40 premières inchangées.
- **CA-V3 (palette)** : étapes `rue`, `rue_nuit`, `krach_anim` avec `--controle --rue-sans-hud` à 1920 × 1080 : `RUE palette variante=<jour|nuit|orage> hors_palette=0` (image du `SubViewport`, lumières additives masquées, fondu terminé ; au krach, mesure une fois `krach = 1`).
- **CA-V4 (pixels nets, proportions constantes — §2.3)** : étape `rue_libre` (rue en mouvement, HUD masqué) à 1280 × 720, 1366 × 768, 1920 × 1080, `-Telephone` et 1920 × 1080 `-Facteur 4` : `RUE facteur=<N> reduction=<R> vue=<l>x<h> gerard_ecran=<px>` avec 1080p `facteur=2 reduction=1.000 vue=960x540 gerard_ecran=126` ; 720p `facteur=2 reduction=0.667 vue=960x540 gerard_ecran=84` (± 1) ; 1366 × 768 `facteur=2 reduction=0.711` ; téléphone `facteur=2 reduction=0.667 vue=1200x540 gerard_ecran=84` (± 1) ; et `RUE grille irreguliers=0` mesuré sur l'image du **`SubViewport`** (avant réduction : blocs N × N uniformes, contrôle jamais trivial puisque N ≥ 2). Captures `rue_720` et `rue_tel` relues : aucun pixel « grouillant » pendant `defilement` (avis du testeur), Gérard à la même proportion qu'en 1080p (montage `px1_montage_formats` : `rue_1080` | `rue_720` | `rue_tel` à la même hauteur).
- **CA-V5 (rue large et caméra)** : `RUE rue largeur=<l> bornes=<a>..<b> gazette=<x> maison=<x> banque=<x>` avec l ≥ 2 880 et distances de §3 ; capture `rue_1080` : maison entière (cheminée comprise) dans le rectangle libre, trottoir au-dessus de la frise ; captures `rue_banque` et `rue_gazette` (après `aller_vers`) : bâtiment entier visible, journal lumineux de la Gazette sous la barre haute (`RUE cadrage <id> haut=<y> bas=<y> libre=<y1>..<y2>` avec haut ≥ y1 et bas ≤ y2), sur les 4 formats de CA-V4.
- **CA-V6 (défilement)** : étape `defilement` : un glisser simulé (`Input.parse_input_event`, 600 px virtuels vers la gauche) déplace la caméra (`RUE defilement avant=<x> apres=<x>` avec un écart ≠ 0) et **n'émet pas** `batiment_touche` ; un toucher bref sur la banque l'émet (`RUE toucher banque=oui`) ; molette et flèche → : écart ≠ 0 ; `interactif = false` : écart = 0.
- **CA-V7 (API conservée, jeu réel)** : les étapes existantes de toutes les familles se jouent sans erreur de script avec la nouvelle rue : `capture.ps1` pour `titre`, `jouer`, `rue`, `rue_nuit`, `foyer`, `marche_banque`, `pause`, `krach_anim`, `krach`, `courrier`, `news`, `fin`, `heritage`, `presentation_livret`, `crash_anim`, `crash_fin`, `crash_courrier`, `naissance_anim`, `naissance`, `jumeaux`, `trafic`, `fps`, `historique` : code 0, aucune ligne `SCRIPT ERROR`, `Invalid call`, `Invalid access`. Étiquettes « MA MAISON / MA BANQUE / LA GAZETTE » de l'**ancien** HUD : sur la chaussée sous leur bâtiment quand il est visible (`rue_1080`, `rue_banque`).
- **CA-V8 (séquences)** : chaque séquence imprime `RUE sequence <nom> duree=<s> camera=<départ>-><arrivée>` : `banquier` ≤ 2,6 s (`camera=maison->banque->maison`), `journal_krach` ≤ 2,2 s (`->media`), `journal` ≤ 1,2 s, `courrier` ≤ 1,5 s, `crash` ≤ 2,6 s, `naissance` ≤ 2,6 s, `petite_news` sans déplacement de caméra ; avec un toucher simulé 0,3 s après le début : la modale est ouverte moins de 0,4 s après le toucher (`RUE passee <nom> delai=<s>`). Captures `banquier_anim` (combiné et ondes à la banque), `banquier_signal` (signal entre banque et maison), `crash_anim`, `naissance_anim`, `jumeaux_anim` (deux paquets), `krach_anim` (écran rouge, pluie, orage).
- **CA-V9 (trafic accéléré)** : étape `trafic` : vitesses mesurées des voitures et des passants à ×1, ×2, ×3 dans le rapport de `Partie.facteur_trafic(v)` à ± 15 % ; à la pause : 0.
- **CA-V10 (temps, météo, saisons)** : captures `rue_nuit` (fenêtres allumées en `lumiere`, halos en 3 disques), `saison_hiver` (01/1985 : neige au sol et sur les toits), `saison_automne` (10/1986), `saison_printemps` (04/1987), `pluie`, `pause` (teinte gel) ; `titre` (crépuscule, enseigne lettre à lettre de la Gazette, sans erreur) et `jouer` (après `plonger_vers_maison` : maison au repos).
- **CA-V11 (Sylvie, voisins)** : captures `sylvie_0`, `sylvie_1`, `sylvie_2` (3 humeurs nettement différentes à 1080p **sans** planche : sourcils et bouche ; avis motivé du testeur) ; `planche_personnages` (**sans HUD** ni étiquettes : aucune tête coupée par la barre haute, recette PX0 D5 ; tous les `PERSONNAGES`, Jean-Mi à vélo, M. Lefranc qui fume, enfants, poussettes, Porsche, « À VENDRE ») ; `voisins` (Tata Livret et Jean-Mi qui traversent la rue, `point_tete` imprimé dans l'écran).
- **CA-V12 (fluidité)** : étape `fps` (11/1987, pluie et krach, HUD affiché) à 1920 × 1080 et `-Telephone` : `Images par seconde … ≥ 55`.
- **CA-V13 (périmètre)** : `git diff --stat main...lot/px1-ville` limité au §1 ; aucun `.ttf.import` ; aucune couleur en dur ni référence à `Style` dans `scripts/ville/` et `scripts/pixel/` (hors `scripts/pixel/ui/` et `palette.gd`) ; `class_name Batiment` et `class_name Sequences` présents.
- **CA-V14 (vitrine)** : `capture_px0.ps1 -Etape jour -Controle -Taille 1920x1080` : code 0 ; `Voir_PX0.bat` avec `-- --px0-quitter-apres=5` : code 0.
- **CA-V15 (`user://` intact)** : avant / après `capture_ville.ps1 -Serie` : même liste de fichiers dans `%APPDATA%\Godot\app_userdata\JeuClaude` (hors `capture*.sav` et `logs`) et même SHA-256 de `partie_en_cours.sav` s'il existe.
- **CA-V16 (style, avis du testeur, non bloquant)** : montage `px1_montage_ref` (`rue_pixel_v2.jpg` | `rue_1080`) et `px1_montage_px0` (`px0_quater_jour_1080` | `rue_1080`) : même famille visuelle que PX0 quater (briques, relief, ciel, arbres, sol) ; écarts signalés, verdict au joueur.
- Non vérifiable ici (à écrire comme tel) : ressenti du glissement et de l'inertie ; vrai téléphone (le glisser au doigt) ; 2160p réel.

## 6. Série de captures (`outils/capture_ville.ps1 -Serie`, préfixe `px1_`)
Le script lance la scène principale (via `trouver_godot.ps1`, comme `capture.ps1`), avec `--controle`, sur : `rue_1080`, `rue_720`, `rue_1366`, `rue_tel`, `rue_banque`, `rue_gazette`, `rue_libre` (×4 formats), `defilement`, `rue_nuit`, `saison_hiver`, `saison_automne`, `saison_printemps`, `pluie`, `pause`, `titre`, `jouer`, `banquier_anim`, `banquier_signal`, `krach_anim`, `crash_anim`, `crash_fin`, `naissance_anim`, `jumeaux_anim`, `news`, `sylvie_0..2`, `planche_personnages`, `voisins`, `trafic`, `fps`, et les trois montages (`px1_montage_ref`, `px1_montage_px0`, `px1_montage_formats`). Journal `godot/captures/px1_serie.log`. Code 0 seulement si chaque lancement rend 0, aucune ligne d'erreur de script, et tous les contrôles à zéro (`hors_palette=0`, `irreguliers=0`).

## 7. Fusion et vérifications après fusion
- PX1, PX2 et le lot 02 logique se fusionnent **dans l'ordre de leur OK**. La recette de la **dernière** branche des trois simule la fusion avec `main` (qui contient les deux autres) : copie isolée, `user://` à part, `tests.ps1`, `capture_ville.ps1 -Serie` et la série de PX2.
- Points de contact à l'exécution, vérifiés à la fusion PX1 × PX2 : étiquettes du HUD sur la chaussée et, hors écran, flèche de bord qui appelle `aller_vers` (PX2) ; `cadrer(hud.rect_libre())` avec les nouvelles bandes du HUD ; secousse ; pièces et journaux volants partant d'un bâtiment hors écran (ils entrent par le bord) ; carte du banquier qui part de la banque.
- Sur `main` (chef de projet) : `tests.ps1`, `capture_ville.ps1 -Serie`, captures clés relues (`rue_1080`, `rue_tel`, `banquier_anim`, `krach_anim`, `titre`).

## 8. Validation (chef de projet)
- [ ] CA-V1 à CA-V16 (rapport du testeur OK) · [ ] série relue · [ ] fusion `--no-ff`, tests et série relancés sur `main` · [ ] bases à jour
- Décision :
