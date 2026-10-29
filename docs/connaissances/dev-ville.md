# Base de connaissances de dev-ville

> À lire au début de chaque mission (après `CLAUDE.md` et `developpeur.md`), à mettre à jour à la fin. Concise.
> Dernière mise à jour : 2026-10-29 (lot PX0, étape A : atelier pixel).

## 1. Atelier pixel (`godot/scripts/pixel/`, conservé après PX0)

| Fichier | Rôle |
|---|---|
| `palette.gd` (`PalettePixel`) | 40 couleurs × 3 variantes (docs/16 §2.3, valeurs vérifiées par le test). **Seul** fichier avec des couleurs en dur. Clé de comparaison = RGB 8 bits (`to_rgba32() >> 8`). `convertir` et `compter_hors_palette` travaillent sur `get_data()` (rapide). Ajouts : `cle`, `existe`, `couleur_alpha`. |
| `grille.gd` (`GrillePixel`) | Catalogue statique : grilles `data/pixel/<dossier>/*.txt` (format : `data/pixel/LISEZMOI.md`) + images de code. `analyser` est pur (pas de `push_error`) ; `charger_dossier` est idempotent (même fichier rechargé = pas de doublon). Cache image et texture par « nom\|variante ». Ajout : `taille(nom)`. |
| `matieres.gd` (`MatieresPixel`) | Générateurs déterministes (RNG à graine). Ciel en bandes (horizon = dernière rangée, transitions Bayer 4 × 4 sur 8 px, motif de période 4 en x : image de 64 px répétée), trottoir 8, chaussée 16. `generer_tout()` enregistre `matiere/ciel`, `matiere/trottoir`, `matiere/chaussee`. |
| `vue_pixel.gd` (`VuePixel`) | SubViewport `ceil(physique / N)` + TextureRect Nearest. Ajouts : `vue_change`, `recalculer`, `echelle`, `marges_art`, `origine_vue`. |
| `rue_px0.gd` (`RuePx0`, jetable) | Monde PX0. Classe interne `Couche` : liste d'opérations (image du catalogue, répétée en x ; rectangle de couleur de palette), dessin jour puis nuit à alpha `melange` **opération par opération** (ordre de superposition respecté pendant le fondu). Repères : SOL 312, trottoir 312-320, chaussée 320-336, maison x 24-120, zone utile (0,188)-(256,336). |
| `px0.gd` + `scenes/px0.tscn` (jetables) | Options `--px0-*`, crochet d'interface, contrôles, captures, montage. `controler_blocs(img, n)` statique (voie rapide : réduction + agrandissement au plus proche voisin comparés à l'original). |

## 2. Faits vérifiés

- **Échelle par axe obligatoire** : en 1366 × 768 (zone virtuelle 1920,9 × 1080), une seule échelle (hauteur) donnait 3 450 blocs irréguliers (~18 colonnes). `get_viewport().get_final_transform().get_scale()` par axe pour la taille du TextureRect et les conversions : 0 irrégulier.
- Mesures (étape A) : 1920 × 1080 → ×3, vue 640 × 360, caméra (-192, 0) ; 1280 × 720 → ×2 ; 1366 × 768 → ×2, vue 683 × 384, caméra (-214, -22) ; téléphone 1600 × 720 (facteur 1,7) → ×2, vue 800 × 360, marges 54,4 / 40,8 px d'art ; ×4 forcé → vue 480 × 270.
- Figurine 28 px d'art = 84 px virtuels à 1080, 49 px virtuels sur téléphone.
- Ne pas écrire `size` d'un Control ancré plein écran dans `_ready` (avertissement « non-equal opposite anchors »).
- La scène passée en argument (`--path godot res://scenes/px0.tscn`) est bien lancée, `--fullscreen` donne 1920 × 1080 sur l'écran principal. Dans un `.bat`, cmd **attend** la fin de l'exe GUI (code de sortie transmis).
- `Input.parse_input_event` permet d'éprouver les touches (J, S, F10) depuis un script, sans clavier.
- Écran de la machine : deux 1920 × 1080 ; `--px0-taille=1920x1080` (sans bordure en 0,0) donne bien 1920 × 1080.
- `capture_px0.ps1` : `Start-Process -RedirectStandardOutput/-Error` (pas de `2>&1` en PS 5.1) ; fichier `.ps1` en UTF-8 **avec BOM** (sinon accents illisibles en PS 5.1). `-Serie` complète ≈ 55 s.
- Images par seconde mesurées en capture : > 2 000 (pas de vsync) ; à revoir avec la rue complète.

## 2 bis. Étape B (rue complète)

- `facades.gd` (sans class_name, `preload`) : maison de Gérard (meulière à joints caramel, chaînes et linteaux de brique, tuiles mécaniques en trapèze, lucarne, cheminée à poteries, volets persiennes vert sombre, marquise, boîte aux lettres, plaque de numéro), haussmannien (pierre de taille, refends, balcons filants 2e et dernier étage, corniche, comble zinc, lucarnes, souches ; rez-de-chaussée porte cochère / boulangerie à auvent rayé / pharmacie à croix gain / tabac à rideaux bistrot), immeuble de brique, arbres d'automne (grappes ombrées haut gauche, contour brique sombre, 2 images), massif, grille basse + portillon, carotte de tabac, chaises, potelets, plaque de rue. Chaque générateur renvoie `{"image", "fenetres"}` : les fenêtres s'allument la nuit (op « nuit seulement », lumiere).
- `RuePx0.generer_decor()` (statique) enregistre ~43 images `decor/…` + `miroir/gerard_*` (retournées par `flip_x`, origine recalculée) ; 0,6 s au lancement. Fond : haussmanniens pâlis (`palir` : ardoise / gris pierre / zinc clair), jamais derrière la maison (toit sur le ciel).
- Classes internes : `Couche` (fixe), `Mobile` (animé, parts [nom, décalage] + rects de nuit), `Halos` (3 disques additifs). Tout ce qui bouge est posé à des positions entières.
- Grilles écrites en « suites » puis développées par un script PowerShell (bloc-notes de session, non versionné) : les `.txt` de `data/pixel/ville` sont la source de vérité.
- Ciel réglé : crème 64, ciel clair 76, ciel 150, bleu ardoise 40 (horizon y 320).
- `capture_px0.ps1` passe `--log-file` hors de `user://` : sinon `user://logs` tourne à chaque lancement (CA-V11 faux positif). Le cache de shaders ne bouge plus après le premier lancement.
- Piège GDScript : `const M := MatieresPixel` refusé (« not a constant expression ») → `preload(...)` ; une variable locale ne peut pas porter le nom d'un paramètre ; `MatieresPixel.call(...)` interdit (passer par `load(...)`).
- Ne jamais tuer de processus Godot (dev-interface tourne en parallèle) : le garde-fou de `px0.gd` est posé en tout premier dans `_ready`.

## 3. Décisions (étape A)

- Ciel : bandes crème 12, ciel clair 46, ciel 110, bleu ardoise 112, puis bleu nuit ; horizon posé au bas du trottoir. **À régler à l'étape B** avec les bâtiments (la partie claire est surtout cachée ; le haut bleu nuit est sous la barre).
- Sous la chaussée : trottoir d'en face puis ardoise sombre (visible seulement sans interface).
- Planche : sprites `ville/*` ×2 en px d'art (×6 à l'écran en 1080) sur crème, rangés à partir de y + 40.
- Portrait `ville/lefranc_affable` **provisoire** (écrit en suites, développé par un petit script PowerShell) : lisible, mais à reprendre (grave, yeux fermés).

## 4. Erreurs à ne pas refaire

- Supposer l'échelle d'étirement identique sur les deux axes (voir §2).
- Commiter un bouchon d'interface ou un `.ttf.import` (propriété de dev-interface PX0).
