# Lot PX0 : preuve de concept pixel art (maison de Gérard, bout de rue, HUD, carte du banquier)

- Origine : validation de la bible graphique par le joueur le 2026-10-29 (docs/10, section « Validation de la bible graphique pixel art ») : tout le jeu en pixel art dessiné dans le code, **interface comprise** (chiffres et textes longs dans une police nette), **personnages petits dans la rue, à peu près à la taille actuelle**, PX0 lancé **en même temps que le lot 01**. Référence : docs/16 §6.1 (contenu), §2 (règles techniques, palette), §3 (interface, polices), §5.1 et §5.3 (maquettes).
- Objectif : une **scène autonome** `res://scenes/px0.tscn`, lancée en ligne de commande ou par `Voir_PX0.bat`, qui montre sur une vraie image du jeu le style proposé : la maison de Gérard en meulière, Gérard qui marche devant (petit, ≈ taille actuelle), Sylvie à la fenêtre (3 humeurs), un bout de rue (façade voisine, immeubles de fond, trottoir, chaussée, réverbère, platane d'automne, ciel en bandes), le passage jour → nuit, la barre haute et la frise restylées avec les polices embarquées, et la carte du banquier de l'héritage (docs/16 §5.3). Le joueur dit ensuite « oui, c'est ce style-là », « oui avec ajustements » ou « non ».
- Ce que le joueur verra : `Voir_PX0.bat` (à la racine du dépôt) ouvre la scène **en plein écran** (1920 × 1080 sur son écran, donc ×3 : la grille de 640 × 360 de la bible). Touches : **J** jour / nuit (fondu de 3 s), **S** humeur de Sylvie, **C** carte du banquier (COMPRIS, croix ou clic à côté pour fermer), **P** police des chiffres (Atkinson / Jersey 10), **F10** format téléphone (fenêtre 1600 × 720, facteur 1,7), **H** aide, **Échap** quitter. Il reçoit aussi la série de captures (§5) et deux montages « avant / après » à côté de `v3_rue.png` et `v3_rue_tel.png`. Rien ne change dans le jeu lui-même.
- Hors périmètre : toute modification du jeu existant (ville vectorielle, HUD, modales, `principal.gd`) ; la Gazette, la banque, les passants, la circulation, les saisons, la pluie (PX1) ; le panneau « Mon argent », la fenêtre Banque, l'historique, le journal (PX2) ; le portrait de Gérard 48 × 48 ; l'animation d'entrée de la carte (la tuile qui sort de la banque) ; les sons ; un exe ou un APK de la scène ; les données de partie (aucune sauvegarde lue ni écrite).
- Mode : **séquentiel court puis parallèle**. Étape A : dev-ville seul pose l'atelier et le squelette de la scène, le coordinateur étiquette ce commit `px0-atelier`. Étape B : dev-ville (rue, maison, personnages) et une **deuxième instance de dev-interface** (HUD, carte, polices) travaillent en même temps, dans deux worktrees, sur des fichiers disjoints. La branche interface est **empilée** sur `px0-atelier` (seule exception à la règle « pas de dépendance entre branches d'un lot » : l'atelier y est inclus, la branche se vérifie donc seule).
- Indépendance avec le lot 01 : **aucun fichier commun** (tableau §1 et liste des interdits). PX0 ne s'appuie sur aucun fichier créé par le lot 01 (`trouver_godot.ps1`, `Reglages`, `StrategieTest`…) : il part de `main` actuel.
- Base : `main` à jour, **après** commit de ce plan par le coordinateur.

## 0. Mise en place (coordinateur)

```powershell
$git = "C:\Users\arthu\Documents\temp\JeuClaude\outils\git\cmd\git.exe"
$depot = "C:\Users\arthu\Documents\temp\JeuClaude"
# Étape A
& $git -C $depot worktree add -b lot/px0-ville C:\Users\arthu\Documents\temp\JeuClaude_lots\px0-ville main
# … dev-ville livre l'étape A (CA-A1 à CA-A4 vérifiés par le coordinateur, §3), puis :
& $git -C $depot tag px0-atelier lot/px0-ville
& $git -C $depot worktree add -b lot/px0-interface C:\Users\arthu\Documents\temp\JeuClaude_lots\px0-interface px0-atelier
# Étape B : relancer dev-ville (même worktree, même branche) et lancer dev-interface en parallèle.
```

- Chaque développeur travaille **uniquement** dans son worktree, commite en local, ne pousse pas. Le tag `px0-atelier` reste local (le testeur s'en sert pour le `diff` de la branche interface).
- Godot n'est que dans le dépôt principal. Dans les worktrees : `$env:JEUCLAUDE_GODOT = "C:\Users\arthu\Documents\temp\JeuClaude\outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"` (lu par `capture_px0.ps1` et `Voir_PX0.bat`, §2.6), ou ce chemin en direct. Premier `--import` de chaque worktree ≈ 5 s.
- `user://` est commun à tous les worktrees et au joueur : **PX0 n'y lit ni n'y écrit rien** (aucun appel à `Partie`, `Sauvegarde`, `EtatPartie`).
- **Fichiers d'import des polices** : le premier `--import` de **n'importe quel** worktree (lot 01 compris, puisque `godot/polices/` est sur `main`) crée `godot/polices/**/*.ttf.import` (non suivis). Seul **dev-interface PX0** les commite (avec ses réglages, §2.5). Les développeurs du lot 01 et dev-ville ne les commitent pas (le testeur le vérifie par le `diff --stat`).
- Ordre de fusion : `lot/px0-ville` puis `lot/px0-interface` (qui contient déjà les commits de l'atelier). Indépendant du lot 01 : on fusionne ce qui est validé en premier. Les fichiers PX0 sont isolés ; si le joueur refuse le style, un commit de nettoyage les retire de `main`.

## 1. Fichiers attribués (tout fichier absent de ce tableau est interdit)

Chemins relatifs à la racine du dépôt. Les `.uid` des nouveaux scripts sont commités par leur propriétaire. « Dossier » = le propriétaire peut y créer d'autres fichiers.

| Fichier | Propriétaire | Étape | Nature |
|---|---|---|---|
| `godot/scripts/pixel/palette.gd` | dev-ville | A | **Nouveau** : `PalettePixel` (§2.1) |
| `godot/scripts/pixel/grille.gd` | dev-ville | A | **Nouveau** : `GrillePixel`, compilateur de grilles (§2.2) |
| `godot/scripts/pixel/vue_pixel.gd` | dev-ville | A | **Nouveau** : `VuePixel`, rendu basse résolution à facteur entier (§2.3) |
| `godot/scripts/pixel/matieres.gd` | dev-ville | A (ciel), B | **Nouveau** : `MatieresPixel`, générateurs (ciel en bandes tramé, meulière, tuiles, pierre, brique, ardoise, zinc, trottoir, chaussée) |
| `godot/scripts/pixel/rue_px0.gd` | dev-ville | A (squelette), B | **Nouveau** : `RuePx0`, le monde de la preuve de concept (§2.4) |
| `godot/scripts/pixel/*.gd` (autres) | dev-ville | B | Dossier : figurines, maison, décor, si besoin |
| `godot/scripts/pixel/px0.gd`, `godot/scenes/px0.tscn` | dev-ville | A | **Nouveaux** : racine de la scène (options, touches J/S/F10/Échap, cadrage, captures, contrôles, crochet d'interface, §2.6) |
| `godot/data/pixel/LISEZMOI.md` | dev-ville | A | Format des grilles, noms de la palette, conventions (servira aussi aux images fournies plus tard) |
| `godot/data/pixel/ville/*.txt` | dev-ville | A, B | Dossier : grilles de la ville (Gérard, Sylvie, M. Lefranc 48 × 48, maison, réverbère, platane, nuages, R5…) |
| `godot/tests/test_pixel.gd` | dev-ville | A, B | **Nouveau** : test de palette et de grilles (headless, `--script`) |
| `godot/outils/capture_px0.ps1` | dev-ville | A | **Nouveau** : captures et série PX0 (§2.6) |
| `Voir_PX0.bat` | dev-ville | A | **Nouveau** : lancement pour le joueur |
| `docs/connaissances/dev-ville.md` | dev-ville | A, B | Création de sa base |
| `godot/scripts/pixel/ui/*.gd` | dev-interface | B | Dossier : `interface_px0.gd` (crochet, §2.5), HUD, carte, cadres 9-patch, polices ; **sans `class_name`** (chargés par chemin) |
| `godot/data/pixel/ui/*.txt` | dev-interface | B | Dossier : cadres 9-patch, icônes 16 × 16, flèches, tampon, ticket dentelé |
| `godot/polices/**/*.ttf.import` | dev-interface | B | Réglages d'import des 4 polices (§2.5) |
| `docs/connaissances/dev-interface_px0.md` | dev-interface | B | **Nouveau**, temporaire : ses enseignements (fusionnés dans `dev-interface.md` au lot 02 ; `dev-interface.md` appartient à l'instance du lot 01) |

**Interdits aux deux** (en plus de tout fichier absent du tableau) : tous les fichiers attribués au lot 01 (`godot/project.godot`, `scripts/principal.gd`, `scripts/ecran.gd`, `scripts/ville/*` dont `sequences.gd`, `scripts/outils/*`, `scripts/ui/*`, `outils/tests.ps1`, `outils/capture.ps1`, `outils/trouver_godot.ps1`, `tests/test_*` existants, `tests/autocontrole/`, `Exporter_*.bat`, `Jouer_Godot.bat`), `scripts/logique/*`, `scripts/partie.gd`, `scripts/juice.gd`, `shaders/`, `data/*.json`, `export_presets.cfg`, `.gitignore`, `CLAUDE.md`, `docs/` hors bases citées, `godot/polices/*` hors `.import`. **Lecture seule permise** : `Banquier`, `Format`, `Dates` (statiques, §2.5), les polices, les captures et références du dépôt principal. Un besoin hors de ce tableau : le décrire dans le compte rendu, ne pas le faire.

## 2. Interfaces (fixées avant le lancement)

Nouveaux `class_name` (aucun autre ; aucun ne recoupe ceux du lot 01) : `PalettePixel`, `GrillePixel`, `VuePixel`, `MatieresPixel`, `RuePx0` (dev-ville). dev-interface n'en crée aucun. Pas de changement de sauvegarde, de signal de `Partie`, de donnée JSON, de réglage du projet.

### 2.1 Palette « Rue 84 » — `scripts/pixel/palette.gd` (dev-ville)
`class_name PalettePixel`, `extends RefCounted`, statique. Valeurs **exactement** celles de docs/16 §2.3 (jour, nuit, orage). Identifiants, dans l'ordre : `encre, nuit, ardoise_sombre, ardoise, gris_pierre, zinc_clair, creme, blanc_chaud, pierre_ombre, pierre, pierre_claire, brique_sombre, brique, tuile, terre_cuite_claire, bois_sombre, bois, bleu_nuit, bleu_ardoise, ciel, ciel_clair, vert_sombre, vert, vert_clair, orange, rouge_auvent, bleu_vif, peau_claire, peau_ombre, caramel, lumiere, neon_rose, ambre, or, gain, perte, gel, cuivre, gain_papier, perte_papier`.
```gdscript
const JOUR := 0
const NUIT := 1
const ORAGE := 2
static func noms() -> PackedStringArray                          # les 40 identifiants, dans l'ordre ci-dessus
static func couleur(nom: String, variante := JOUR) -> Color      # nom inconnu : push_error, renvoie Color.MAGENTA
static func emissive(nom: String) -> bool                        # lumiere, neon_rose, ambre, gain, perte, gel, cuivre, gain_papier, perte_papier
static func contient(c: Color, variante := JOUR) -> bool         # égalité exacte sur R, G, B en 8 bits (to_rgba32 sans alpha)
static func nom_de(c: Color, variante := JOUR) -> String         # "" si hors palette
static func convertir(img: Image, de := JOUR, vers := NUIT) -> Image      # substitution couleur par couleur, alpha conservé
static func compter_hors_palette(img: Image, variante := JOUR) -> int     # pixels d'alpha > 0 dont le RGB est hors palette
```
L'interface utilise les mêmes couleurs (`PalettePixel.couleur("creme")`, `"nuit"`, `"ambre"`, `"gain"`, `"cuivre"`…) : aucune couleur codée en dur dans `scripts/pixel/` (vérifiable par recherche de `Color("#` et `Color(0.`, hors `palette.gd`).

### 2.2 Format des grilles et `GrillePixel` — `scripts/pixel/grille.gd` (dev-ville)
Fichiers `godot/data/pixel/<dossier>/*.txt` (UTF-8), `<dossier>` = `ville` (dev-ville) ou `ui` (dev-interface). Plusieurs images par fichier :
```
# Commentaire : ligne ignorée.
: e encre                 # légende : une lettre → un identifiant de palette ; vaut pour les images qui suivent
: c caramel
: o encre 50              # alpha facultatif en % (défaut 100) ; réservé aux ombres portées de l'interface
image gerard_repos_1 16x28 origine 8,27
......eeeee.....
(exactement 28 lignes de 16 caractères)
image gerard_repos_2 16x28 origine 8,27
…
```
- `.` = transparent (toujours) ; lettre = un caractère imprimable sauf `.`, `#`, `:` et l'espace, sensible à la casse ; `origine` facultative (défaut : milieu du bas, `(l/2, h-1)`) ; nom complet = `<dossier>/<nom>` (ex. `ville/gerard_repos_1`, `ui/panneau`), unique.
- Erreurs détectées : largeur ou nombre de lignes différents de l'annonce, lettre sans légende, identifiant de palette inconnu, nom en double, ligne inattendue.
- Les images générées par code (`MatieresPixel`) sont enregistrées dans le même catalogue (et donc contrôlées par le test de palette).
```gdscript
class_name GrillePixel  # extends RefCounted, état statique (static var)
static func analyser(texte: String, dossier: String, source := "") -> Dictionary  # pur, sans push_error : {"images": {nom: {"image": Image, "origine": Vector2i}}, "erreurs": PackedStringArray}
static func charger_dossier(dossier: String) -> int        # lit res://data/pixel/<dossier>/*.txt, enregistre ; push_error par erreur ; dossier absent → 0, sans erreur
static func enregistrer(nom: String, image: Image, origine := Vector2i(-1, -1)) -> void
static func existe(nom: String) -> bool
static func image(nom: String, variante := PalettePixel.JOUR) -> Image          # nuit / orage : PalettePixel.convertir, en cache
static func texture(nom: String, variante := PalettePixel.JOUR) -> ImageTexture # en cache
static func origine(nom: String) -> Vector2i
static func noms() -> PackedStringArray
static func erreurs() -> PackedStringArray                 # erreurs de chargement accumulées
```
Les sprites sont opaques ou transparents (alpha 0 ou 1, sauf alpha déclaré dans la légende). Les transparences d'affichage (panneau α 0,94, fond assombri, halos α 0,30 / 0,18 / 0,08) sont appliquées à l'affichage (`modulate`, calque de lumière), jamais dans les images.

### 2.3 Rendu à facteur entier — `scripts/pixel/vue_pixel.gd` (dev-ville)
`class_name VuePixel`, `extends Control` (ancres plein écran), selon docs/16 §2.1 : un `SubViewport` de taille `ceil(taille_physique / N)` (`snap_2d_transforms_to_pixel`, `snap_2d_vertices_to_pixel`, `canvas_item_default_texture_filter` = Nearest, **réglés sur le SubViewport**, pas dans `project.godot`), affiché par un `TextureRect` filtre Nearest, à l'origine, de taille `taille_vue × N / échelle_finale` en px virtuels (l'échelle finale de la fenêtre inclut l'étirement `canvas_items` et le facteur d'interface : il reste exactement N pixels physiques par pixel d'art). Caméra `Camera2D` dans le SubViewport, position arrondie au pixel d'art. Recalcul à chaque changement de taille de fenêtre ou de facteur d'interface.
- **Règle de N pour PX0** : `N = max(1, floor(hauteur_physique / 360))` (la vue fait toujours ≈ 360 px d'art de haut, docs/16 §2.1) ; forçable (`forcer_facteur`). Exemples : 1920 × 1080 → ×3, vue 640 × 360 ; 1280 × 720 → ×2 ; 1366 × 768 → ×2, vue 683 × 384 ; téléphone 1600 × 720 (facteur 1,7) → ×2, vue 800 × 360. (La règle « zone utile dans le rectangle libre » de la bible donne N = 1 sur téléphone à cause des bandes du HUD ; à retrancher avec l'UX en PX1, voir §6.)
```gdscript
signal facteur_change(n: int)
var monde: Node2D        # racine du monde, dans le SubViewport, coordonnées en px d'art
var camera: Camera2D
func facteur() -> int
func taille_vue() -> Vector2i                                     # px d'art
func forcer_facteur(n: int) -> void                               # 0 = automatique
func regler_marges(haut_virtuel: float, bas_virtuel: float) -> void   # hauteur des bandes du HUD (px virtuels) ; défaut 96 et 72
func cadrer(zone: Rect2) -> void          # bas de la zone posé sur le haut de la frise, zone centrée en largeur, arrondi au pixel d'art
func monde_vers_ecran(p: Vector2) -> Vector2                      # px d'art → px virtuels de l'interface
func ecran_vers_monde(p: Vector2) -> Vector2
func image_monde() -> Image                                       # image du SubViewport, avant agrandissement
```

### 2.4 Le monde — `scripts/pixel/rue_px0.gd` (dev-ville)
`class_name RuePx0`, `extends Node2D`, enfant de `vue.monde`. Composition d'après docs/16 §2.6 et §5.1, en px d'art : jardinet (24) + **maison de Gérard 96 × 124** (meulière générée à joints, tuiles mécaniques, cheminée, volets bleu-vert, marquise, boîte aux lettres, grille basse, fenêtre de Sylvie 18 × 22 avec buste 12 × 14), au moins **une façade voisine** (haussmannienne ou commerce de rez-de-chaussée), immeubles de fond plus pâles, **platane d'automne** 40 × 64 glissé entre deux bâtiments, **réverbère parisien** 8 × 56, trottoir (8), chaussée (16), ciel en bandes tramé (Bayer 4 × 4) avec 2 nuages en marches. Décor habillé sur **au moins 1 000 px d'art de large** (le plein écran maximisé ou le 20:9 montrent jusqu'à 960). **Gérard** : figurine **16 × 28** (2,5 têtes, profil, contour encre, blouson bleu de travail), marche 4 images à 8 im/s (1 px d'art par image) en va-et-vient devant la maison, repos 2 images à 2 im/s devant la porte. Bonus non bloquant : Renault 5 48 × 20 qui passe (roues 2 images). Portraits pour la carte : **M. Lefranc 48 × 48**, trois quarts, lunettes, moustache grise, cravate bordeaux, expressions `affable` et `grave` (+ yeux fermés si possible), grilles `ville/lefranc_affable`, `ville/lefranc_grave` (`ville/lefranc_yeux_fermes`).
```gdscript
func zone_utile() -> Rect2                    # px d'art : du haut de la cheminée au bas de la chaussée, du jardinet à la façade voisine
func regler_nuit(nuit: bool, fondu := 3.0) -> void   # fondu entre versions jour et nuit précalculées ; émissives inchangées ; lumières additives la nuit
func est_nuit() -> bool
func regler_humeur_sylvie(h: int) -> void     # 0 contente, 1 neutre, 2 contrariée ; + clignement
func humeur_sylvie() -> int
func figer(f: bool) -> void                   # arrête marche, voiture, nuages, clignements (carte ouverte, captures)
func preparer_capture() -> void               # pose déterministe : Gérard devant la maison (marche, image 2), nuages et R5 placés
func afficher_lumieres(v: bool) -> void       # calque additif (masqué pendant le contrôle de palette)
func point_etiquette_maison() -> Vector2      # px d'art, sur la chaussée sous la maison (étiquette « MA MAISON » de l'interface)
func taille_gerard() -> Vector2i              # 16 × 28
```

### 2.5 L'interface — crochet `scripts/pixel/ui/interface_px0.gd` (dev-interface)
`px0.gd` (dev-ville) contient, dès l'étape A : `const CHEMIN_INTERFACE := "res://scripts/pixel/ui/interface_px0.gd"` ; si le fichier existe et que `--px0-sans-interface` est absent, il l'instancie (`load(...).new()`), l'ajoute après la vue et appelle `installer`. Sinon la scène tourne sans interface (branche ville seule). Contrat :
```gdscript
extends CanvasLayer          # pas de class_name
func installer(vue: VuePixel, rue: RuePx0) -> void    # construit HUD, étiquette, carte (fermée), aide ; appelle vue.regler_marges(<haut>, <bas>) selon sa mise en page
func preparer(etape: String) -> void                  # peut contenir des await ; gère « carte », « carte_fermee », « jersey », « polices » ; ignore les autres
func lignes_controle() -> PackedStringArray           # lignes « PX0 … » imprimées par px0.gd avec --px0-controle (§3, CA-I*)
```
- Touches de l'interface : C, P, H (gérées par `interface_px0.gd`, `_unhandled_input`) ; celles de la racine : J, S, F10, Échap. Aucune autre.
- **Polices** (`godot/polices/`, LISEZMOI) : `FontFile` importées avec antialiasing en niveaux de gris, hinting aucun, sous-pixel désactivé, sans MSDF ; graisses par `FontVariation`. **Pixelify Sans** : titres, étiquettes, boutons, en-têtes, **jamais sous 28 px virtuels** ; **Atkinson Hyperlegible Next** : chiffres, textes longs et tout texte de moins de 28 px ; **Jersey 10** : variante de la date et du patrimoine (touche P) ; **Doto** : seulement sur la planche des polices. Aucune `SystemFont`.
- **Cadres** (docs/16 §3.3) : grilles `ui/…` agrandies ×3 au plus proche voisin, `StyleBoxTexture` (marges ×3), filtre Nearest : `Panneau` 24 × 24 (6), `CartePapier` 32 × 32 (8), `BoutonPrincipal` 16 × 20 (5, bas 7) et sa version enfoncée, `BoutonSecondaire` 16 × 20, `Pastille` 12 × 12 (4). Icônes 16 × 16 ×3 : pause, lecture, ×2, ×3, menu, historique ; flèches ▲ ▼ 8 × 8.
- **Valeurs du HUD** : celles de la capture `v3_rue.png` (partie réelle, mai 1987), en constante commentée dans le script : `MAI` `1987`, `BAGUETTE 2,85 F`, `COMPTE COURANT 8 875 F`, `PATRIMOINE 69 395 F ▲ +26 %`, `VS TOUT AU LIVRET A ▲ +3 916 F`, frise 1984 → 1988 curseur en mai 1987, bouton HISTORIQUE. (Lire une partie en cours n'est pas simple sans le lot 01 et toucherait `user://` : refusé. Les mêmes chiffres rendent le montage avant / après comparable.)
- **Carte de l'héritage** (docs/16 §5.3, PC 1 120 × 560, téléphone ≤ 1 300 × 590 px virtuels) : chiffres et texte **réels**, lus en lecture seule : `var a := Dates.lire("1988-04")`, `var h := Banquier.heritage_chiffres()`, `var d: Dictionary = Banquier.donnees()["heritage"]["D08"]`, texte = `Format.gabarit(d["texte"], {"prenom": "Gérard", "av_montant": Format.entier(h["av"], a), "droits": Format.entier(h["droits"], a), "succ_net": Format.entier(h["net"], a)})`, ticket = `d["ticket"]` avec le même gabarit (soit 60 000 F, 27 500 F, 32 500 F). Portrait `GrillePixel.texture("ville/lefranc_affable")` ×3 (×2 sur téléphone) ; **si la grille n'existe pas** (branche interface avant fusion) : cadre crème vide de même taille, sans erreur. Fond assombri à 60 % teinté gel, `rue.figer(true)` à l'ouverture, `false` à la fermeture.

### 2.6 Racine, options, captures — `px0.gd`, `capture_px0.ps1`, `Voir_PX0.bat` (dev-ville)
Options après `--` (préfixe `--px0-` **obligatoire** : l'autoload `Capture` réagit à `--capture`, `--etape`, `--telephone`, qui ne doivent jamais être utilisés ici) :

| Option | Effet |
|---|---|
| `--px0-taille=LxH` | fenêtre sans bordure en (0, 0), à cette taille exacte (sinon la fenêtre 1920 × 1080 serait rognée par Windows) |
| `--px0-telephone` | facteur d'interface 1,7 et, sans `--px0-taille`, fenêtre 1600 × 720 (comme F10) |
| `--px0-facteur=N` | force N (contrôle du ×4 sur un écran 1080) |
| `--px0-etape=E` | `jour` (défaut), `nuit` (fondu terminé), `sylvie_0` / `sylvie_1` / `sylvie_2`, `planche` (dev-ville : sprites ×6 sur fond crème : Gérard 4 + 2 images, Sylvie 3 humeurs, M. Lefranc, R5) ; puis `interface.preparer(E)` (`carte`, `carte_fermee`, `jersey`, `polices`). Étape inconnue de tous : message, code 2 |
| `--px0-libre` | ne fige pas la scène (sinon `preparer_capture()` puis `figer(true)`) |
| `--px0-sans-interface` | n'instancie pas l'interface |
| `--px0-controle` | imprime les lignes de contrôle (§3) |
| `--px0-fps` | mesure les images par seconde sur 3 s après 1 s de chauffe |
| `--px0-capture=<png>` | enregistre la fenêtre puis quitte (chemin relatif = relatif à `godot/`) ; code 4 si l'image n'a pas la taille demandée |
| `--px0-montage=<png de référence>` | avec `--px0-capture` : écrit aussi `<capture>_montage.png` (référence mise à la hauteur de la capture, à gauche ; capture à droite) |
| `--px0-attente=s`, `--px0-quitter-apres=s` | attente avant capture ; arrêt automatique (essai de lancement) |

- F10 est intercepté par `px0.gd` dans `_input` (marqué traité : l'autoload `Ecran` ne le voit pas) et bascule le format téléphone **de PX0** (1600 × 720, facteur 1,7 ; la fenêtre 1200 × 540 d'`Ecran` donnerait N = 1).
- `godot/outils/capture_px0.ps1` : `-Etape`, `-Nom`, `-Taille`, `-Telephone`, `-Facteur`, `-SansInterface`, `-Libre`, `-Controle`, `-Fps`, `-Attente`, `-Montage`, `-Godot` ; **`-Serie`** produit toute la série du §5 dans `godot/captures/` et le journal `godot/captures/px0_serie.log`. Godot : `-Godot`, sinon `$env:JEUCLAUDE_GODOT`, sinon `<racine>\outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`, sinon message clair et code 3. Références des montages : `v3_rue.png` et `v3_rue_tel.png` dans `<dépôt principal>\godot\captures\` (dépôt principal = dossier parent de `outils\` dans le chemin de Godot). Lance `--import` d'abord. Code de sortie 0 **seulement si** chaque lancement rend 0, aucune ligne `SCRIPT ERROR`, `Parse Error`, `Failed to load`, `Invalid call`, `Invalid access`, `Cannot call method`, et tous les contrôles sont à zéro (`hors_palette=0`, `irreguliers=0`). Résumé : une ligne par capture.
- `Voir_PX0.bat` : `JEUCLAUDE_GODOT` s'il est défini, sinon `%~dp0outils\…\Godot_v4.7.2-stable_win64_console.exe` pour `--headless --path "%~dp0godot" --import` (≈ 5 s, les polices doivent être importées), puis l'exe sans console : `--path "%~dp0godot" res://scenes/px0.tscn --fullscreen` (vérifier que la scène passée en argument est bien lancée ; sinon `--scene`). Message clair si Godot est introuvable.

## 3. Tâches et critères d'acceptation

### Étape A — dev-ville seul (branche `lot/px0-ville`, worktree `C:\Users\arthu\Documents\temp\JeuClaude_lots\px0-ville`)
Atelier et squelette, petit et stable (l'interface s'appuie dessus) : `palette.gd`, `grille.gd`, `vue_pixel.gd`, `matieres.gd` (au moins le ciel en bandes tramé, le trottoir et la chaussée), `rue_px0.gd` (squelette avec toutes les fonctions du §2.4, même vides), `px0.gd` + `px0.tscn` (toutes les options et le crochet du §2.5), `capture_px0.ps1`, `Voir_PX0.bat`, `data/pixel/LISEZMOI.md`, `test_pixel.gd`, la grille `ville/lefranc_affable` (même provisoire). Un commit « PX0 atelier ». **Après le tag, les signatures du §2 ne changent plus** (ajouts seulement).
- CA-A1 : `--headless --import` puis `--headless --script res://tests/test_pixel.gd` : code 0, aucune erreur de script.
- CA-A2 : `capture_px0.ps1 -Etape jour -Nom px0_a -Taille 1920x1080 -Controle -SansInterface` : code 0 ; image 1920 × 1080 ; lignes `PX0 fenetre=1920x1080 facteur=3 vue=640x360` et `PX0 grille … irreguliers=0`.
- CA-A3 : `px0.gd` contient le crochet (`CHEMIN_INTERFACE`, `installer`, `preparer`, `lignes_controle`) ; sans fichier d'interface, la scène tourne sans erreur.
- CA-A4 : `git diff --stat main...lot/px0-ville` limité aux fichiers « étape A » du §1.
Vérifiés par le coordinateur avant le tag (pas de passage du testeur à cette étape).

### Étape B — dev-ville (même branche)
1. Monde complet (§2.4), nuit, Sylvie, Gérard, M. Lefranc, planche ; test de palette complet ; base `dev-ville.md`.
- CA-V1 (`test_pixel`, ≤ 10 s, ≥ 25 vérifications `OK`/`KO`, code 1 en cas d'échec) : 40 couleurs, identifiants uniques, valeurs jour **égales à docs/16 §2.3** (liste attendue écrite dans le test), 40 couleurs jour distinctes, émissives identiques dans les 3 variantes ; **toutes** les grilles de `data/pixel/ville` **et** `data/pixel/ui` (s'il existe) : aucune erreur, taille annoncée, alpha 0 ou 1 (ou alpha déclaré) ; **chaque pixel** de chaque image (grilles + générateurs de `MatieresPixel` appelés avec une graine fixe) appartient à la palette de sa variante, en jour, nuit et orage ; un générateur appelé deux fois avec la même graine donne la même image ; `analyser()` sur 4 textes fautifs (largeur, lettre sans légende, couleur inconnue, nom en double) renvoie chaque erreur, sans `push_error`.
- CA-V2 (palette à l'écran) : `-Controle` en `jour` et `nuit`, à 1920 × 1080 et au téléphone : `PX0 palette variante=<jour|nuit> pixels=<n> hors_palette=0` (image du SubViewport, lumières additives masquées, après le fondu).
- CA-V3 (pixels nets) : `-SansInterface -Libre -Controle` (scène en mouvement) à 1280 × 720 (×2), 1920 × 1080 (×3), 1920 × 1080 `-Facteur 4` (×4), 1366 × 768 (×2, vue 683 × 384) et téléphone (×2, vue 800 × 360) : `PX0 grille blocs=<n> irreguliers=0` (chaque bloc N × N complet de l'image de la fenêtre est uniforme).
- CA-V4 (contenu, `px0_jour_1080` et `px0_jour_tel`) : tous les éléments du §2.4 sont visibles ; la maison (cheminée comprise) est entièrement sous la barre haute et le trottoir au-dessus de la frise sur les 5 formats ; matières lisibles (joints de la meulière, rangs de tuiles), contours teintés, lumière en haut à gauche, aucun dégradé lisse hors ciel en bandes.
- CA-V5 (taille des personnages, décision du joueur) : `PX0 figurine gerard=16x28 ecran=<l>x<h>` ; à 1920 × 1080, h = 84 px (passant actuel de `v3_rue.png` ≈ 75 px à cette taille : rapport entre 0,8 et 1,3) ; maison 96 × 124 (± 8).
- CA-V6 (nuit) : `px0_nuit_*` : palette nuit, fenêtres de la maison et de Sylvie allumées (couleur `lumiere`), halo du réverbère en 3 disques ; `PX0 fondu=3.0s`.
- CA-V7 (Sylvie) : `px0_sylvie_1`, `px0_sylvie_2` et `px0_planche` : 3 humeurs nettement différentes (sourcils et bouche) ; visage lisible à ×3 (sinon l'écrire : la bulle suffira, la fenêtre sera agrandie en PX1).
- CA-V8 (animation) : `PX0 animation gerard marche=4 repos=2 cadence=8` ; la planche montre les 6 images ; deux captures `-Libre` à `-Attente 0` et `1.5` montrent Gérard à deux positions différentes.
- CA-V9 (fluidité) : `-Fps` à 1920 × 1080 avec interface : `PX0 images_par_seconde=<n>`, n ≥ 55.
- CA-V10 (lancement) : `Voir_PX0.bat` relu ; la commande qu'il exécute, avec `-- --px0-quitter-apres=5`, ouvre la scène en plein écran et se ferme seule, code 0, sans erreur ; sans Godot trouvable : message clair.
- CA-V11 (`user://` intact) : avant et après `capture_px0.ps1 -Serie`, même liste de fichiers dans `%APPDATA%\Godot\app_userdata\JeuClaude` et même SHA-256 de `partie_en_cours.sav` (s'il existe).

### Étape B — dev-interface (branche `lot/px0-interface`, worktree `C:\Users\arthu\Documents\temp\JeuClaude_lots\px0-interface`, base `px0-atelier`)
1. Polices (`.import`), cadres et icônes (`data/pixel/ui/*.txt`), HUD (barre haute + frise + étiquette « MA MAISON »), carte de l'héritage, planche des polices, aide clavier, variante Jersey 10 ; base `dev-interface_px0.md`.
- CA-I1 (polices) : `px0_polices` : Pixelify Sans, Atkinson Hyperlegible Next, Jersey 10 et Doto à 28, 32, 48 et 72 px virtuels, sur panneau nuit et sur papier crème, avec « ÉÈÊÀÇÔŒÙÎ àéèêçôœùî « » 0123456789 1lI 0O 8B 69 395 F » : **aucun carré vide** ; ligne `PX0 polices chargees=4 tnum_atkinson=<oui|non>` (chiffres de même largeur avec `tnum` ; sinon compteurs à largeur minimale fixe) ; aucune `SystemFont` dans `scripts/pixel/ui/`.
- CA-I2 (HUD) : `px0_jour_1080`, `px0_jour_720`, `px0_jour_1366`, `px0_jour_tel` : toutes les valeurs du §2.5 présentes, chiffres en Atkinson, aucun texte coupé ni chevauché ; `PX0 hud pixelify_min=<n> compte=<n> patrimoine=<n>` : Pixelify jamais sous 28 px, compte ≥ 32 px et patrimoine ≥ 44 px virtuels (tailles actuelles de `hud.gd`) ; cadres pixel (coins en escalier, contour encre de 1 texel = 3 px à 1080).
- CA-I3 (lisibilité) : `px0_montage_pc` et `px0_montage_tel` : les chiffres de la barre haute sont au moins aussi grands et contrastés qu'en `v3_rue` / `v3_rue_tel` (avis motivé du testeur).
- CA-I4 (étiquette) : « MA MAISON » posée sur la chaussée sous la maison sur les 5 formats (position calculée par `vue.monde_vers_ecran(rue.point_etiquette_maison())`).
- CA-I5 (carte) : `px0_carte_1080` et `px0_carte_tel` : papier crème, contour encre, coin corné, liseré or à gauche, en-tête « BANQUE DE LA RUE · 12, rue des Épargnants », « M. LEFRANC · votre banquier », « avril 1988 · UNE NOUVELLE », tampon « TANTE ODETTE », texte D08 identique à `banque.json` (Gérard), ticket : **60 000 F** (gain sur papier), « SI ÇA AVAIT ÉTÉ PAR SUCCESSION », **32 500 F** nets barré et atténué, **27 500 F** de droits ; bouton COMPRIS ambre ; carte entière dans la fenêtre au téléphone ; `PX0 carte montants=60 000 F|32 500 F|27 500 F mots=<n>` avec n ≤ 60.
- CA-I6 (fermeture) : étape `carte_fermee` : ouvre la carte puis envoie un **vrai clic** sur COMPRIS → `PX0 carte fermee=oui rue_figee=non`.
- CA-I7 (Jersey 10) : `px0_jersey_1080` : date et patrimoine en Jersey 10, le reste inchangé.

### Commun aux deux branches
- CA-C1 : `git diff --stat main...lot/px0-ville` et `git diff --stat px0-atelier...lot/px0-interface` limités aux fichiers de leur propriétaire (§1) ; aucun `.ttf.import` hors branche interface.
- CA-C2 : `capture_px0.ps1 -Serie` : code 0 sur chaque branche (sur la branche ville, les étapes d'interface sont capturées sans interface et le signalent).
- CA-C3 : `outils/tests.ps1` de la branche (version de `main`) toujours au vert (66 + 100 + 8), import sans erreur.

## 4. Après les deux fusions (et celle du lot 01, quel que soit l'ordre)
- Sur `main` (chef de projet) : `capture_px0.ps1 -Serie` au vert ; captures relues (carte avec le **vrai portrait** de M. Lefranc, désormais présent) ; `Voir_PX0.bat` essayé depuis le dépôt principal ; si le lot 01 est fusionné : `tests.ps1` (nouvelle version) découvre `test_pixel` et reste vert, import sans erreur de script.
- Envoi au joueur (coordinateur) : `Voir_PX0.bat`, `px0_jour_1080`, `px0_nuit_1080`, `px0_carte_1080`, `px0_jour_tel`, `px0_planche`, `px0_polices`, `px0_jersey_1080`, les deux montages ; questions : le style (critères docs/16 §6.1 : rue française de 1984 reconnaissable, visage de Sylvie, chiffres lisibles), la taille des personnages, Atkinson ou Jersey 10 pour la date et le patrimoine.

## 5. Série de captures (`capture_px0.ps1 -Serie`, dans `godot/captures/`)
| Nom | Format | Options |
|---|---|---|
| `px0_jour_1080`, `px0_nuit_1080`, `px0_carte_1080`, `px0_jersey_1080`, `px0_sylvie_1`, `px0_sylvie_2` | 1920 × 1080 | `-Controle` ; `-Fps` sur `jour` |
| `px0_jour_720` | 1280 × 720 | `-Controle` |
| `px0_jour_1366` | 1366 × 768 | `-Controle` |
| `px0_jour_tel`, `px0_nuit_tel`, `px0_carte_tel` | téléphone 1600 × 720, facteur 1,7 | `-Controle` |
| `px0_grille_x2`, `px0_grille_x3`, `px0_grille_x4`, `px0_grille_1366`, `px0_grille_tel` | 1280 × 720 ; 1920 × 1080 ; 1920 × 1080 `-Facteur 4` ; 1366 × 768 ; téléphone | `-SansInterface -Libre -Controle` |
| `px0_libre_0`, `px0_libre_15` | 1920 × 1080 | `-Libre`, attente 0 et 1,5 s |
| `px0_planche`, `px0_polices` | 1920 × 1080 | étapes `planche`, `polices` |
| `px0_montage_pc`, `px0_montage_tel` | — | `v3_rue.png` + `px0_jour_1080` ; `v3_rue_tel.png` + `px0_jour_tel` |

## 6. Vérifications attendues (testeur, `docs/lots/lot_px0_recette.md`)
- Par branche : CA de la branche + CA-C1 à CA-C3, preuves (lignes du journal, captures). La branche interface se vérifie avec l'atelier tel qu'au tag (rue incomplète, portrait possiblement provisoire : normal).
- **Comparaison au style de référence** (`C:\Users\arthu\Documents\temp\JeuClaude\docs\sources\graphisme\references\rueStyle.jpg` et `stylePersonnage.png`, non versionnées : lire dans le dépôt principal) — sur le **style**, pas à l'identique (ne jamais décalquer). Grille à cocher (oui / partiel / non + capture) : pixel gros et assumé, aucun flou ; chaque matière en 3-4 tons ; contours sombres teintés (bâtiments) et encre (personnages) ; lumière en haut à gauche, ombres portées de 1-2 px sous corniches et appuis ; aucun dégradé lisse hors ciel en bandes ; « calme en haut, vivant en bas » ; arbre glissé entre les bâtiments ; figurine à 2,5 têtes, contour encre, couleur signature ; ambiance chaleureuse ; élément français daté reconnaissable (meulière, volets, réverbère parisien, haussmannien). Le verdict du style appartient au joueur : le testeur signale les écarts, il ne refuse une branche que sur un CA.
- Non vérifiable ici (à écrire comme tel) : ressenti du mouvement et du fondu (images fixes seulement) ; rendu sur un vrai téléphone ; 2560 × 1440 réel (le ×4 est contrôlé par `-Facteur 4`).
- Comptes rendus : fichiers modifiés (comparés au §1), ce qui n'est pas vérifié, écarts d'interface, durée de `-Serie`, décisions prises seul (option la plus simple).

## 7. Dette et suites connues (pour PX1 / PX2, rien à faire dans ce lot)
- `export_presets.cfg > include_filter="data/*.json"` n'exporte pas `data/pixel/**/*.txt` : à étendre (dev-logique) avant toute version exportée qui utilise l'atelier.
- `capture_px0.ps1` localise Godot lui-même : passer à `trouver_godot.ps1` (lot 01) en PX1.
- Règle du facteur N sur téléphone (bandes du HUD) et F10 d'`Ecran` (1200 × 540 → N = 1) : à trancher avec l'UX en PX1.
- Scripts `px0.gd`, `rue_px0.gd`, `scripts/pixel/ui/*_px0` : jetables ; l'atelier (`palette`, `grille`, `vue_pixel`, `matieres`, grilles) est conservé.

## 8. Validation (rempli par le chef de projet)
- [x] CA-A1 à CA-A4 (coordinateur, avant le tag) · [x] CA-V1 à CA-V11 (lus avec les valeurs de PX0 bis/ter/quater ; CA-V1 : 10,4-11 s au lieu de 10, D3 accepté) · [x] CA-I1 à CA-I7 · [x] CA-C1 à CA-C3 · [ ] série relue sur `main` (après fusion, §4) · [x] base du chef de projet à jour
- **Décision (chef de projet, 30/10) : fusion validée**, sur le rapport `lot_px0_recette.md` passage 1 (OK ville **45f5120**, OK interface **0ad6db7**, fusion simulée sans conflit, 290 vérifications vertes, partie intégrale identique au lot 01). Ordre : `lot/px0-ville` puis `lot/px0-interface`, `--no-ff`, après avoir vérifié que les têtes locales et distantes sont toujours 45f5120 et 0ad6db7. **Avant la fusion de l'interface** : supprimer les 5 `godot/polices/**/*.ttf.import` non suivis du dépôt principal (régénérés par l'import ; la version commitée par dev-interface fait foi), sinon `git merge` refuse. Après fusion : `tests.ps1` (attendu ≥ 279 = 202 + 77, aucune erreur de script), `capture_px0.ps1 -Serie` code 0, `Voir_PX0.bat` à sec, captures `px0_quater_jour_1080`, `jour_tel`, `carte_*` relues ; échec → pas de push, branche `lot/px0-<dev>-correctif`.
- Arbitrage des défauts : **D1** accepté tel quel (copies identiques à `main`, sans effet) ; rappel dans PX1 §0 : un fichier hors tableau est interdit même identique. **D2** : docs/16 §8.2 à mettre à 67 couleurs (rédacteur de docs/16, via le coordinateur) ; PX1/PX2 citent 67. **D3** accepté ; plafond de `test_pixel` porté à 15 s dans PX1 (CA-V2 bis). **D4** : tranché, rue composée à facteur entier ≥ 2 puis **réduite** à la taille de l'écran (proportions de 1080p partout), voir `lot_px1.md` §2.3 et CA-V4. **D5** : planche de la vitrine seulement, non corrigé (vitrine jetable, nettoyée au lot 03) ; la planche de PX1 se capture sans HUD (CA-V11). **D6** : non repris dans la vitrine ; couvert par PX2 (`polices_jeu`, `clic_dehors`, CA-I8, CA-I11).
