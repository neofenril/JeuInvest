# Base de connaissances de dev-ville

> À lire au début de chaque mission (après `CLAUDE.md` et `developpeur.md`), à mettre à jour à la fin. Concise.
> Dernière mise à jour : 2026-11-12 (lot 03-V : enseignes, cartouches, départ figé, E6, §2 nonies).
> Téléphone de référence (PX2) : 1440 × 648 → N = 2, R = 0,600, Gérard 76 px ; les mesures 1600 × 720 de §2 sont historiques.

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

## 2 ter. PX0 bis (rue de briques, docs/16 §8) — remplace la rue meulière de §2 bis

- Palette 59 couleurs : 19 ajoutées **en fin** de `_NOMS`/`_HEX_*` (les 40 premières intouchables, CA-B2).
- Repères : SOL 296, trottoir 296-308 + bordure 308-310, chaussée 310-332, maison x 0-152 (haut 124), ZONE (-130,124,462,212) → vue 640 : x -219..421. Pieds 304.
- `facades.gd` : `batiment(cfg)` générique (l, etages, brique vive/classique/sombre/claire, toit ardoise/tuiles/plat/pignon à redents, rdc porte/boutique/garage/aveugle, enseigne, pub) ; `fenetre()` 4 carreaux (croisée visible la nuit) ; `arbre_ete()` = petites grappes triées par y dans un gabarit + éclairage local et global (`ombre` < 0 = plus sombre). `vehicules.gd` (nouveau) : caisse par polygone (`Geometry2D.is_point_in_polygon`), roues 12 px à part.
- `matieres.gd` : `texte()` capitales 3 × 5 (enseignes), `lointain()` (plan 0,4), `cumulus()`, `skyline()`.
- Arbre de premier plan : posé chaque image sur `get_viewport().get_camera_2d()` + taille du SubViewport (bord droit), même figé.
- Grilles 24 × 42 / 18 × 21 / objets : générateurs PowerShell en suites dans le bloc-notes (non versionnés) ; le `.txt` fait foi. Scripts `.ps1` à écrire en UTF-8 **avec BOM** (sinon accents cassés en PS 5.1) ; tableau de lignes : `New-Object 'char[][]'` (sinon aplati).
- Pièges : `var cx := tableau[i] * f` → type non inférable (typer `: float`) ; `Set-Content -Encoding UTF8` met un BOM dans les `.gd` (écrire via .NET sans BOM) ; `JEUCLAUDE_GODOT` ne persiste pas entre deux commandes ; `tests.ps1` de cette branche cherche Godot dans le worktree : lancer les 3 tests à la main.
- Mesures : 2 467 im/s à 1080 ; figurine 72 × 126 à 1080, 96 × 168 à ×4.

## 2 quater. PX0 ter (cadrage serré, « approche-toi encore plus » de rue_pixel_v2)

- Palette 67 : +8 en fin (brique_brune, ombre_froide, goudron_sombre, feuille_profonde, mousse, nuage_soleil, bleu_gris, vitre_reflet) ; à reporter dans docs/16 par le chef de projet.
- Repères : SOL 268, trottoir 14 + bordure 3, chaussée 60 (visible jusqu'à 336), maison 0-152 (haut 96), ZONE (-130,96,494,240), pieds 276. Voitures ×1,3 (≈ 94 × 39, roues 16), face avant de trois-quarts.
- Nuages : 5 tons tramés (`_ton_trame`). Briques : ton tiré par brique (5 tons), joints sombres ; `usure()` (salissures tramées, mousse, fissures) ; coulures sous les appuis ; vitres `_vitre()` à reflets.
- Arbre de premier plan = une seule image (tronc + branche de Bézier + masses `arbre_ete`), origine au tronc. Arbres `devant` posés entre la couche Batiments et la Maison. Feuilles qui volettent : 3 mobiles, placés aussi par `preparer_capture`.
- Pièges : `R` est un alias PowerShell (Invoke-History) : ne pas nommer une fonction ainsi ; `WriteAllLines` écrit en CRLF (les remplacements en LF échouent ensuite) ; un paramètre `[string]$Godot` masque le `$godot` de trouver_godot.ps1 (l'inclure dans un bloc `& { . … ; $godot }`) ; une boucle `for k` dans une fonction qui a déjà `var k` = erreur de parse.
- tests.ps1 + trouver_godot.ps1 recopiés à l'identique de main (fusion sans conflit) ; capture_px0.ps1 les utilise.

## 2 quinquies. PX0 quater (grille fine, relief « mini 3D »)

- `VuePixel.HAUTEUR_ART` = 540 : N = floor(h / 540) → 1080p ×2 (vue 960 × 540), 2160p ×4 ; **720p et téléphone 1600 × 720 : N = 1** (vue 1280 × 720 ou 1600 × 720 : plus de monde visible, personnages 2/3 de leur taille 1080p). L'interface ne lit que `monde_vers_ecran`, `marges_art` et les constantes SOL/TROTTOIR/BAS_CHAUSSEE (vérifié sur lot/px0-interface) : pas d'impact sur sa grille.
- Tout ×1,5 : SOL 402, trottoir 26, chaussée 90, maison 228 × 258, étage 75, rdc 90, fenêtre 36 × 48, porte 33 × 66, ZONE (-195,144,741,360) (bas = 504 = haut de la frise à 1080p). Motifs (brique 6 × 3, tuiles, dalles) gardés à leur taille → plus fins à l'écran.
- Personnages et mobilier **générés en code** (`personnages.gd` : Gérard 36 × 63, Sylvie 27 × 32 ; `facades.lampadaire/bouche_incendie/boite_poste/plaque`) ; grilles gerard/sylvie/objets.txt supprimées, lefranc.txt gardé. Contour « teinté » (`contour_teinte`).
- Relief : `ombre_portee()` tramée sous toute saillie ; `_retour()` pan latéral en fuite (cfg "retour" : bâtiments qui avancent, dessinés après les autres) ; toits avec bord, gouttière, sous-face ; cheminée à joue ; embrasures ; marquise ; marches ; auvent avec sous-face, joues et ombre au sol (renvoyé par `batiment()["auvent"]`).

## 2 sexies. PX1 (rue du jeu, branche lot/px1-ville)

- **Fichiers** : `scripts/ville/ville.gd` (API, caméra, défilement, CanvasLayer -5 + VuePixel `mode_reduction`), `rue.gd` (monde : couches, mobiles, météo, saisons, tâches de fond), `batiment.gd` + `maison/banque/media.gd`, `passant.gd`, `voiture.gd`, `accessoire.gd` (sprites des séquences), `sequences.gd` ; atelier : `pixel/edifices.gd` (banque 270 × 285, Gazette 225 × 318, objets des séquences), `pixel/voisins.gd` (figurines paramétrées, enfants, poussettes, vélo, panneau). `dessin.gd` (class_name Dessin) **gardé** : l'UI s'en sert.
- **Rendu D4** : `VuePixel.facteur_et_reduction(Vector2i)` (N = max(2, ceil(h/540)), R = h/(540 N)) ; SubViewport = vue × N, caméra zoom N, TextureRect réduit (linéaire si R < 1). `art_par_virtuel()`, `px_physiques_par_art()`, `teinter()` (gel). Vitrine PX0 inchangée (mode par défaut).
- **Repères** : rue GAUCHE -1560 → DROITE 1860 ; Gazette x -795 (centre -683), maison 0-228 (114), banque 678-948 (813) ; bornes caméra = décor ± 200 − demi-vue. Vertical : bas du libre = clamp(haut cible − 4 + h_libre, SOL + 4, 504).
- **Variantes** : `rue.variantes()` = [[variante, alpha]] (jour, puis orage ×krach, puis nuit ×mélange), quantifiées au 1/32 ; tout dessin passe par `rue.image/rect/emissif/lumiere_nuit`.
- **Pièges** : `Callable.bind(a).bind(b)` appelle f(b, a) → **un seul `bindv`** pour les tâches WorkerThreadPool ; une erreur dans une tâche de fond est **muette** (vérifier le résultat dans un test). Arbres (0,4 s chacun) et recoloration de saison en tâche de fond, sinon génération 9 s. `--script` : le script de test ne peut pas nommer un autoload (Partie), mais les scripts chargés ensuite le peuvent. Commit : `git commit -F fichier` (un here-string passé à `-F -` n'est pas lu).
- Recette PX1 passage 1 (KO) corrigée : arbre de premier plan retiré en mode titre (il cachait l'enseigne JEUCLAUDE ; contrôlé dans test_rue) ; `point_etiquette` bornée au-dessus du bas du libre (l'étiquette pend ≈ 40 px d'art sous le point) ; toutes les saisons + neige préparées dès que les arbres sont prêts ; fonds, skyline, cumulus en tâche de fond (génération ≈ 1,1-1,3 s) ; glyphe N ≠ M ; voiture de Gérard et potelet à gauche de la maison (capot loin de Gérard). Toujours regarder **toutes** les captures de format (720, téléphone) du titre : l'arbre de premier plan suit le bord droit de la vue.
- Captures : `outils/capture_ville.ps1` (1080 en `--fullscreen`, téléphone : la famille passe la fenêtre à 1600 × 720), options `--controle`, `--rue-sans-hud`, `--rue-facteur`, `--rue-passer`. Les scénarios attendent `rue.images_pretes()`.

## 2 septies. PX1-bis (sortie, A11, A3)

- **Tâches de fond** : lancées en tête de `generer()` (arbres + leurs 4 saisons dans la même tâche, premier plan, skyline, fonds avec leur neige, neige des façades **quelle que soit la saison**), puis variantes nuit / orage de tout par lots de 6 (`_tache_variantes`) ; chaque récolte relance les variantes des nouvelles images. `GrillePixel.poser_variantes` (contrôle d'identité de l'image source), `variante_prete`, `texture_prete`.
- **Préchauffage** : file [nom, variante] de **toutes** les images (jour, nuit, orage), budget 4 ms par image, attend la variante si une tâche tourne encore. `images_pretes()` = tâches **et** préchauffage finis (≈ 3 à 4 s après le lancement, headless). Mesuré : krach 8 ms, première nuit 6 ms (contre 300 à 660 ms) ; test_rue imprime `RUE image_max_ms`, le scénario `RUE image_max etape=…`.
- **Sortie** : `_exit_tree` → `attendre_taches()` (attend et récolte ; les lots de variantes s'arrêtent tôt via `_arret`). Cause probable du blocage : fils de GDScript encore actifs pendant la fermeture du moteur (carnet_pel saute en décembre → neige et saisons lancées juste avant la sortie). Une sortie dans les ~3 s du lancement attend la fin des arbres.
- **Pièges** : `wait_for_task_completion` invalide l'identifiant (`is_task_completed` ensuite = « Invalid Task ID ») ; `add_task(…, true)` (haute priorité, 16 fils de GDScript) ralentit le fil principal ×5 (génération 7 s) : rester en basse priorité. `recolorer` : octets précalculés (plus d'appel de palette par pixel).
- Arbres : plus de repli sur l'été (`_maj_arbres`) ; un arbre pas encore prêt n'est pas dessiné.

## 2 octies. Lot 02-V (pièces du mois, D7, M1, retrait de PX0)

- **Vitrine PX0 retirée** (px0.gd, rue_px0.gd, px0.tscn, capture_px0.ps1, Voir_PX0.bat) ; `VuePixel.controler_blocs` (statique). §1 (rue_px0, px0) et §2 ter-quinquies = historique. Reste : ligne de `ecran.gd` (dev-interface) et `$px0` de `capture_interface.ps1` (dev-interface).
- **Pièces** : `PiecesMois.plan(flux, vitesse, en_saut, ab)` pur (ab = mois **écoulé** = `ab_courant() - 1` : le flux de fin de mois est celui du mois passé ; `verse_en_decembre` est déjà faux en décembre côté logique). Seuils et nombre comptés en **francs** (`Format.en_devise(eur, "F")`, tolérance 1e-6 : 10 F en euros ×6,55957 ≠ 10 exactement). 1 + round(log10(F/10)) : 312 F → 2, 1 152 F → 3.
- `Sequences.pieces_du_mois(res)` : raisons pas_de_flux, saut_test, titre, saut, pause, vitesse3, sous_seuil, sequence (modale ou fin dans res, ou vedette en cours), hors_champ. Lieux : **porte visible** (`ville.porte_ecran`, partie visible ≥ 8 px d'art de la porte dans le libre) plutôt que bâtiment entier : à 1080p panneau ouvert, le libre fait 698 px d'art et les deux portes sont à 700 px l'une de l'autre (bords intérieurs : 658) → seul moyen d'avoir « maison et banque visibles ». Sinon bord intérieur de la flèche (`hud.etiquettes[id]`, méta `fleche`), sinon bord d'écran.
- `Juice.pieces_suivies` : Callables relus à chaque image, position arrondie à 3 px virtuels, `pieces_creees` (compteur), `derniere_arrivee`. `Juice.pieces` et `duree` tiennent compte de `Partie.saut_actif`.
- **D7** (`ville.gd`) : `RETOUR_AUTO_S` 10, `RETOUR_DUREE_S` 0,8 ; `_calme` n'avance que si `_temps_tourne()` (vitesse > 0, hors saut, non bloquée, sans modale) et `interactif` ; remis à 0 par tout appui, molette, flèche, `aller_vers` (flèche de bord). `a_la_maison()`, `centrer_sur(x, d)` (= défilement du joueur).
- **M1** (`rue.gd`) : arbre de premier plan en fondu 0,3 s par pas de 1/8 dès que son image existe (mesuré : prêt 1,4 s après un « Jouer » immédiat, plus grand saut d'alpha 0,125).
- Captures : les étapes à flux fabriqué figent le temps par `Partie.bloquee = true` (vitesse ×1, rue animée, aucun vrai mois). Image `<nom>_vol.png` enregistrée par la famille pendant le vol. `capture.gd` prend l'image juste après le retour de `jouer()` (frames=10 ≈ instantané sans vsync) : régler le moment par le dernier `delai` de l'étape. Le flottant vit 0,9 s.
- Avance rapide des captures par `StrategieTest` (plus `sc.strategie_active/aller_a/aller_a_modale`, que 02-I retire).
- Piège : `git rm` met les suppressions dans l'index ; un `commit` suivant de quelques fichiers les emporte aussi.
- Vu en capture, côté HUD (dev-interface) : au téléphone, flèches « ‹ LA GAZETTE » et « ‹ MA MAISON » qui se chevauchent quand la maison est à moitié visible.

## 2 nonies. Lot 03-V (reprises de 02-V, E6)

- **E6 (cause trouvée)** : `grille.gd` retirait le BOM avec un littéral invisible `"<U+FEFF>"`. Exporté en jetons binaires (`script_export_mode=2`), ce littéral devient `""` → `begins_with("")` toujours vrai → le « # » de la 1re ligne mangé → « ligne inattendue ». Correction : `char(0xFEFF)`. **Jamais de caractère invisible dans une chaîne littérale.** test_pixel le contrôle.
- **Vérifier le jeu exporté** : l'exe du worktree (`$env:JEUCLAUDE_GODOT` puis `cmd /c Exporter_Windows.bat x`) se lance (`--log-file`, `--capture` absolu) ; l'exe 0.4 du dépôt principal, lui, a été bloqué par la stratégie de contrôle d'applications (Start-Process refusé). Plus rapide et jamais bloqué : `--headless --path godot --export-pack Windows x.pck` puis `Godot_console --main-pack x.pck --resolution 1280x720 --log-file … -- --capture=<absolu> --etape=titre` (même chargement : scripts en jetons, filtres d'export).
- **m1** : `rue.enseignes()` (rectangles du monde des 5 enseignes de boutique + BANQUE) ; `Sequences.arc_pieces(d, a)` essaie `ARCS_PIECES` (120, 180… 480, 60, 0) et garde le premier dont 33 points de la courbe évitent les enseignes agrandies de `PIECE_COTE` (24) et restent sous le haut du libre. Mesuré : 240 à 1080 (maison ↔ banque), 180 au téléphone, 120 vers une flèche.
- **D7 cartouche** : `Juice.flottant` = PanelContainer + StyleBoxFlat (fond `Style.ENCRE`, contour 3 px de la couleur du texte). **Les content_margin d'un StyleBoxFlat se comptent depuis le bord extérieur** (contour compris) : 3 = texte collé au contour ; mis 6 / 9. `Juice.taille_flottant` mesure un vrai cartouche **dans l'arbre** (hors de l'arbre, la taille minimale du Label est fausse). `Sequences._flottants_pile` empile et borne la pile entière (+ 60 px de montée) dans `rect_libre().grow(-6)`.
- **D8** : `Juice.pieces_suivies(…, arc)` : départ lu au lancement de chaque pièce (dictionnaire `vol` lié aux rappels), arrivée relue ; `Juice.point_arc` statique.
- **Suivi du vol (scénario)** : relevé sur `RenderingServer.frame_pre_draw` (après les Tween) ; pas ramené à 1/60 s du **temps du jeu** (Σ `get_process_delta_time`). Une image enregistrée en plein vol (`get_image` + `save_png`) fausse quand même le pas quand la caméra glisse (saut de 95 px d'art de la caméra) : pas d'image pendant le vol dans `pieces_bascule`. Glissement de la caméra à vitesse régulière (Tween de `centrer_sur(x, 0)`) : un glissement CUBIC rapide donne pas_max ≈ 2,4 × pas_moyen sans aucun saut.
- **D9** : `test_rue` vérifie la durée de génération à la fin ; relance = vraie régénération (oublier `rue/maison`, `matiere/ciel`, `matiere/skyline` dans `GrillePixel._images`, seconde ville, puis la libérer) ; `-- --rue-relance` la force. Mesuré : 1 366 puis 1 274 ms.
- `ville.cx_pour` public, `ville.point_sylvie()` (`maison.fenetre_sylvie()`), `ciel_mat` et `shaders/ciel.gdshader` retirés ensemble.
- Captures : `camera_retour` → `_glissement.png` / `_retour.png` ; `pieces_or|fleche|dividende` → `_arrivee.png` ; `pieces_bascule` ; `pieces_dividende_jeu` (« RUE pieces dividende=absent » tant que 03-L n'est pas fusionné). `capture_ville.ps1` échoue aussi sur `pieces enseigne≠0`, `hors_libre≠0`, `regulier=non`.
- Pièges : `Object.get("CONST")` ne lit pas une constante (`get_script().get_script_constant_map()`) ; `--script` : ne pas nommer `Sequences` (sa compilation tire les autoloads) → `load(...).new()` ; `git add` avec un chemin inexistant annule **tout** l'ajout (le commit part sans les fichiers).
- Vu, non corrigé (hors périmètre ou à arbitrer) : au téléphone, en hors champ, le cartouche près de COMPTE recouvre encore une partie du panneau INDICE de la Gazette pendant 0,9 s (lisible, passager).

## 3. Décisions (étape A)

- Ciel : bandes crème 12, ciel clair 46, ciel 110, bleu ardoise 112, puis bleu nuit ; horizon posé au bas du trottoir. **À régler à l'étape B** avec les bâtiments (la partie claire est surtout cachée ; le haut bleu nuit est sous la barre).
- Sous la chaussée : trottoir d'en face puis ardoise sombre (visible seulement sans interface).
- Planche : sprites `ville/*` ×2 en px d'art (×6 à l'écran en 1080) sur crème, rangés à partir de y + 40.
- Portrait `ville/lefranc_affable` **provisoire** (écrit en suites, développé par un petit script PowerShell) : lisible, mais à reprendre (grave, yeux fermés).

## 4. Erreurs à ne pas refaire

- Supposer l'échelle d'étirement identique sur les deux axes (voir §2).
- Commiter un bouchon d'interface ou un `.ttf.import` (propriété de dev-interface PX0).
- Nommer `R` une fonction PowerShell (alias Invoke-History) : refait en PX1, tout le remplacement est perdu.
- Le gel de la rue ne se décide jamais sur `Partie.vitesse` seul (saut lancé depuis la pause, lot 02) : passer par `anime` / `facteur_trafic`.
- Écrire un BOM (U+FEFF) en littéral dans un `.gd` : il disparaît à l'export (E6). Utiliser `char(0xFEFF)`. (L'espace insécable littéral de `Format.ESPACE` survit : vérifié sur le paquet exporté.)
- Remplacer un bloc de script par `IndexOf('} else {')` : la première occurrence peut être dans une sous-expression (ligne cassée).
