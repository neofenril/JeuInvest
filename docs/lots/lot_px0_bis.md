# Lot PX0 bis : nouvelle proposition de rue (briques, plein jour, personnages plus grands)

- Origine : retour du joueur sur PX0 (docs/10, « Retour sur la preuve de concept PX0 ») : « Plutôt ça comme style graphique, fais une nouvelle proposition en te basant là-dessus » + référence `docs/sources/graphisme/references/rue_pixel_v2.jpg` (non versionnée : la lire dans le dépôt principal) ; complément : « Personnages un peu plus grands cette fois-ci ». Le style PX0 (automne, crépuscule, meulière, fonds uniformes, figurines simples) est rejeté.
- Objectif : refaire **la rue** de la scène `px0.tscn` dans le style de la référence (journée lumineuse, briques, grands arbres verts, ciel à gros nuages, profondeur) avec des **personnages ≈ 1,5 × plus grands** (24 × 42 px d'art au lieu de 16 × 28), puis renvoyer au joueur une série de captures et `Voir_PX0.bat`. Règles de style : docs/16 §8 (révision du 2026-10-29), qui prime sur §1.1, §2.2, §2.3 et §2.6 pour la rue.
- Ce que le joueur verra : la même scène (`Voir_PX0.bat`, touches J, S, F10, Échap ; C, P, H si l'interface est fusionnée), une rue de briques de jour, la nuit étant la même scène teintée (touche J), et un montage côte à côte avec `rue_pixel_v2.jpg`.
- Hors périmètre : l'interface (HUD, carte, polices : branche `lot/px0-interface` **inchangée**, voir §5), la banque et la Gazette jouables, le trafic, les saisons, la pluie et l'orage animé (PX1), tout fichier du jeu existant. Pas de nouvelle sauvegarde, signal, donnée JSON ni réglage de projet.
- Mode : **un seul développeur, dev-ville**, qui **reprend sa branche** `lot/px0-ville` (worktree `C:\Users\arthu\Documents\temp\JeuClaude_lots\px0-ville`, dernier commit b586055). Pas de nouvelle branche : l'historique de PX0 reste (le rendu rejeté est dans b586055, on peut y revenir). Commits locaux, sans push, jusqu'à l'OK du testeur.

## 0. Mise en place (coordinateur)
- Commiter ce plan et la révision de docs/16 sur `main`. Puis relancer dev-ville dans son worktree, avec `$env:JEUCLAUDE_GODOT` comme pour PX0. Lui donner le chemin **absolu** de la référence (`C:\Users\arthu\Documents\temp\JeuClaude\docs\sources\graphisme\references\rue_pixel_v2.jpg`).
- Les `*.ttf.import` non suivis du worktree ville ne sont **pas** commités (propriété de dev-interface PX0).
- `main` contient désormais le lot 01 : dev-ville **ne fusionne pas** `main` dans sa branche ; la compatibilité est vérifiée par le testeur (CA-B12).

## 1. Écarts entre la bible (PX0) et la référence

| Sujet | PX0 (bible §1.1, §2) | PX0 bis (référence `rue_pixel_v2`) |
|---|---|---|
| Lumière, saison | fin d'après-midi d'automne, ciel en bandes sombres, feuillage orange | **plein jour d'été**, ciel bleu saturé, **gros nuages blancs** en volumes (3 tons), dérive lente ; nuit = même scène par table de substitution |
| Palette | 40 couleurs, verts et briques désaturés | **+19 couleurs** (59) : bleus du ciel, nuages, lointain bleuté, briques vives, 4 verts de feuillage, goudron, dalles, sarcelle (docs/16 §8.2). Les 40 couleurs existantes **ne changent pas** (l'interface PX0 s'en sert) |
| Matière dominante | meulière (maison), pierre crème (fonds) | **brique rouge-orangé à joints visibles** (rangs de 3 px, quinconce), toits d'ardoise sombre **ou** tuiles rouges, chaperons de muret, encadrements de fenêtres en pierre claire |
| Maison de Gérard | pavillon en meulière 96 × 124 | **maison de ville en brique** 2 niveaux, toit de tuiles rouges, porte colorée, boîte aux lettres jaune, fenêtre de Sylvie à l'étage ; ≈ 152 × 172 |
| Bâtiments de fond | immeubles pâles uniformes | **variés** : silhouettes, hauteurs, toits, couleurs de brique (vive, sombre, claire), un pignon aveugle, une boutique ; + **skyline lointaine bleutée** (immeubles, grues, pylônes), sans détails |
| Banque et Gazette | pierre de taille crème, immeuble de presse en pierre | même rue de briques : banque = brique + encadrements et fronton en pierre claire, horloge ; Gazette = brique sombre, enseigne peinte, écran du toit. **Pas dessinées dans ce lot** (PX1), seulement décrites (docs/16 §8.4) |
| Arbres | platane d'automne 40 × 64 entre deux bâtiments | **grands arbres feuillus** vert vif, gros volumes (3 tons + éclat), derrière et entre les bâtiments ; **un tronc et feuillage au premier plan** sur un bord |
| Mobilier | réverbère parisien 8 × 56 | **lampadaire noir à cloche** (contour encre, pas de noir pur), **murets de briques avec chaperon**, bouche d'incendie rouge, boîte aux lettres jaune La Poste, plaque de rue bleue, enseigne et **auvent rouge** de boutique |
| Sol | trottoir 8, chaussée 16 | trottoir en **dalles** 12, bordure 2, chaussée 22 en goudron avec **marquages** et **passage piéton** |
| Personnages | 16 × 28, 2,5 têtes | **24 × 42**, 2,5 têtes (tête ≈ 16 px : yeux 2 × 2, sourcils, bouche 3-4 px, mains, chaussures), 3 tons par matière |
| Échelle | « 1 m ≈ 14 px » | **« 1 m ≈ 24 px »** ; portes, fenêtres, véhicules et bâtiments agrandis en conséquence (docs/16 §8.3) |
| Ombres | 1-2 px sous corniches | idem + ombres portées douces **en aplat** du ton sombre de la surface (arbre sur façade, auvent, voiture sur la chaussée) ; jamais d'alpha dans les images |

Conséquence pour PX1 (à trancher plus tard, pas dans ce lot) : avec cette échelle, maison + banque + Gazette ne tiennent plus dans 448 px d'art de large. Il faudra une rue plus large que l'écran (la caméra glisse vers le bâtiment qui parle) ou des bâtiments jouables plus étroits. Question posée au joueur (§7).

## 2. Fichiers attribués (dev-ville seul ; tout fichier absent est interdit)

| Fichier | Nature |
|---|---|
| `godot/scripts/pixel/palette.gd` | **Ajout en fin de liste** des 19 couleurs de docs/16 §8.2 (jour, nuit, orage) ; les 40 premières inchangées (valeurs et ordre) ; commentaire d'en-tête mis à jour |
| `godot/scripts/pixel/matieres.gd`, `facades.gd`, `rue_px0.gd`, `px0.gd` | Ciel et nuages, brique, dalles, goudron, façades, composition, échelle, premier plan |
| `godot/scripts/pixel/*.gd` (nouveaux) | Permis (ex. `arbres.gd`, `ciel.gd`), **sans `class_name`** (chargés par `preload`) |
| `godot/data/pixel/ville/*.txt` | Figurines 24 × 42, Sylvie à la fenêtre, voitures, lampadaire, mobilier ; M. Lefranc 48 × 48 inchangé (sauf retouche de couleurs) |
| `godot/data/pixel/LISEZMOI.md` | Nouveaux noms de couleurs, nouvelle échelle |
| `godot/tests/test_pixel.gd` | Liste attendue = 59 couleurs |
| `godot/outils/capture_px0.ps1` | Option `-Reference` pour le montage avec `rue_pixel_v2.jpg`, série §6 |
| `Voir_PX0.bat` | Seulement si nécessaire |
| `docs/connaissances/dev-ville.md` | Sa base |

Interdits : tout le reste, en particulier `godot/scripts/pixel/ui/`, `godot/data/pixel/ui/`, `godot/polices/`, tout fichier de `main` hors de ce tableau, `docs/` hors sa base.

### Interfaces (inchangées pour l'interface PX0)
- `PalettePixel` : mêmes fonctions ; `noms()` renvoie 59 noms ; les 40 premiers identiques (ordre et valeurs).
- `RuePx0` : **mêmes signatures** (§2.4 de `lot_px0.md`). Changent seulement les valeurs : `taille_gerard()` → `Vector2i(24, 42)` ; `point_etiquette_maison()` reste sur la chaussée sous la maison ; `zone_utile()` couvre la nouvelle maison et sa voisine. L'interface PX0 n'utilise que `figer()` et `point_etiquette_maison()` (vérifié dans `hud_px0.gd`, `carte_px0.gd`).
- `VuePixel` : inchangée (N = max(1, floor(hauteur / 360)), marges 96 / 72 px virtuels = bandes de 32 et 24 px d'art). Le monde visible va donc de y = 32 à y = 336 à 1080p.

## 3. Composition imposée (px d'art, vue 640 × 360, ×3 à 1080p)

```
y   0-32   (barre haute de l'interface)
y  32-~140 ciel : 4 tons + gros nuages (2-3 cumulus de 60-120 px de large, 3 tons, dérive 1 px / 2 s)
y ~150-296 skyline bleutée (plan 0,15) ; bâtiments de fond variés (plan 0,4) ; arbres derrière
y ~124-296 rue : maison voisine | MAISON DE GÉRARD | muret à chaperon + arbre | boutique à auvent rouge | pignon…
y 296-308  trottoir en dalles (12) ; 308-310 bordure ; 310-332 chaussée (22) avec marquages et passage piéton
y 332-336  bas de chaussée ; 336-360 (frise de l'interface)
```
- Pieds des personnages sur le trottoir (y ≈ 304) ; Gérard (24 × 42) va et vient devant sa porte, repos devant la porte.
- Premier plan (plan 1,15) : tronc + feuillage sur le bord **droit**, posé par rapport au **bord droit de la vue** (visible en 640, 683 et 800 de large) ; il ne recouvre ni la maison de Gérard, ni Gérard, ni l'étiquette « MA MAISON ».
- Décor habillé sur au moins **1 000 px** de large (inchangé).
- Lumière en haut à gauche ; contours des bâtiments dans le ton sombre de leur matière ; encre pour personnages, voitures, mobilier ; **aucun noir pur** (`#000000` interdit, déjà hors palette).

## 4. Tâches (dev-ville, dans cet ordre ; un commit par tâche, messages en français)

1. **Palette** (§8.2 de docs/16) + `test_pixel` (59 couleurs, valeurs attendues écrites dans le test) + LISEZMOI. Lancer le test avant la suite.
2. **Ciel et lointain** : 4 tons de bleu (bandes tramées Bayer conservées mais **claires**, du `ciel_haut` en haut au `ciel_clair` à l'horizon) ; cumulus en grilles ou générés (blanc, ombre, creux), dérive lente ; skyline : silhouettes plates en 3 tons de `lointain_*` (immeubles, 1-2 grues, 1 pylône), aucun détail de fenêtre.
3. **Matières** : brique à joints (rang de 3 px : 2 brique + 1 joint, brique de 6 px, quinconce ; 3 variantes : vive, classique, sombre), ardoise de toit, tuiles rouges, chaperon de muret, dalles de trottoir (joints tous les 12 px), goudron (2 tons, marquages `blanc_chaud`, passage piéton à bandes).
4. **Maison de Gérard** ≈ 152 × 172 (cheminée comprise) : brique, toit de tuiles rouges, cheminée, encadrements et appuis en pierre claire, porte colorée 22 × 44 (sarcelle ou bleu vif) avec imposte, 2 fenêtres au rez-de-chaussée et 2 à l'étage (24 × 32, croisée, reflet), **fenêtre de Sylvie** (26 × 32, buste 18 × 21, 3 humeurs + clignement), boîte aux lettres jaune, numéro, marche de seuil. Fenêtres allumées la nuit (`lumiere`).
5. **Rue** : au moins **5 bâtiments différents** de silhouette, hauteur (140 à 240 px), toit (ardoise, tuiles, toit plat à acrotère, pignon) et brique ; une **boutique** (vitrine, enseigne peinte, **auvent rouge** rayé, porte) ; un pignon aveugle avec publicité peinte d'époque (sans marque réelle) ; murets de briques à chaperon ; 2 grands arbres feuillus (≈ 70 × 110, 4 tons de vert, gros volumes en grappes, tronc `bois`) derrière et entre les bâtiments ; arbre de premier plan ; lampadaire noir à cloche (≈ 10 × 84) ; bouche d'incendie rouge (8 × 14) ; boîte aux lettres jaune ; plaque de rue bleue « RUE DES ÉPARGNANTS » (illisible à cette taille : simple plaque) ; **optionnel** : kiosque vert, feuilles qui volettent (2 × 2, 2-3 à la fois).
6. **Personnages 24 × 42** : Gérard (marche 4 images à 8 im/s, 1 px par image ; repos 2 images à 2 im/s), plus lisible : visage de profil avec œil 2 × 2, sourcil, nez, bouche, oreille, cheveux à reflet, mains, chaussures, blouson bleu de travail en 3 tons, pantalon, ceinture ; ombre au sol en aplat `dalle_ombre` (12 × 2) ; **optionnel** : une passante (cabas, couleur signature) qui traverse.
7. **Véhicules** : voiture **rouge** (R5, ≈ 72 × 30) et voiture **grise** (205 ou 4L, ≈ 70 × 32), l'une garée, l'autre qui passe (roues 2 images), ombre portée en aplat sur la chaussée, phares la nuit.
8. **Nuit** : vérifier la scène entière en palette nuit (fenêtres, lampadaire avec halo 3 disques, phares) ; orage : conversion seule (pas d'animation).
9. **Planche** (étape `planche`, fond crème, ×4) : Gérard 6 images, Sylvie 3 humeurs, M. Lefranc, 2 voitures, lampadaire, bouche d'incendie, un module de brique ×8.
10. **Captures** (§6) + montage avec la référence ; base `dev-ville.md` ; compte rendu (fichiers, écarts, décisions prises seul, ce qui n'est pas vérifié).

## 5. Ce que dev-interface devra peut-être adapter (rien n'est lancé)
- La branche `lot/px0-interface` (0ad6db7) **reste telle quelle** : elle ne lit que des couleurs existantes, `figer()` et `point_etiquette_maison()`. Elle passe sa recette sur la même base qu'avant.
- À juger **par le joueur** sur le montage commun (après fusion des deux branches) et à faire en PX2 seulement s'il le demande :
  1. Panneaux du HUD : fond `nuit` violet-gris très sombre au-dessus d'un ciel clair saturé. Fort contraste (lisibilité des chiffres garantie, docs/16 §2.3) mais bandes lourdes. Options : garder ; teinter vers `bleu_nuit` ; panneaux « papier crème » à encre sombre pour la barre haute de jour.
  2. Étiquette « MA MAISON » : désormais sur goudron gris moyen (contraste à recontrôler, ≥ 4,5:1).
  3. Ombre portée des panneaux (encre α 0,5) : peut paraître sale sur un ciel clair ; la passer à `bleu_nuit` α 0,35.
  4. Fond assombri de la carte (60 % teinté gel) : à garder.
  5. Taille d'une figurine (24 × 42) : la bande du HUD de 96 px virtuels ne doit pas couper la cheminée ; c'est à dev-ville de cadrer (CA-B5).
- Aucune de ces adaptations ne demande de changement de palette : elles se font avec les 59 couleurs.

## 6. Critères d'acceptation (testeur, `docs/lots/lot_px0_bis_recette.md`)

Commandes depuis le worktree ville, avec `$env:JEUCLAUDE_GODOT` défini. Toutes les captures dans `godot/captures/`.

- **CA-B1 (test)** : `--headless --import` puis `--headless --script res://tests/test_pixel.gd` : code 0, aucune erreur de script, ≥ 25 vérifications ; le test contient les 59 valeurs jour de docs/16 §8.2 (et §2.3 pour les 40 premières), 59 couleurs jour distinctes, émissives identiques dans les 3 variantes ; toutes les grilles et générateurs dans la palette en jour, nuit et orage.
- **CA-B2 (40 couleurs intactes)** : `git diff b586055 -- godot/scripts/pixel/palette.gd` ne montre **aucune** ligne retirée dans les 40 premières valeurs (`_NOMS`, `_HEX_*`) : uniquement des ajouts en fin de tableaux (et commentaires).
- **CA-B3 (hors palette)** : `capture_px0.ps1 -Etape jour|nuit -Controle -SansInterface` à 1920 × 1080 et `-Telephone` : `PX0 palette variante=<jour|nuit> … hors_palette=0`.
- **CA-B4 (alignement entier)** : `-SansInterface -Libre -Controle` à 1280 × 720, 1920 × 1080, 1920 × 1080 `-Facteur 4`, 1366 × 768, téléphone : `PX0 grille … irreguliers=0` (nuages et voiture en mouvement compris).
- **CA-B5 (cadrage)** : `px0_bis_jour_1080`, `px0_bis_jour_720`, `px0_bis_jour_1366`, `px0_bis_jour_tel` : maison de Gérard entière (cheminée comprise) entre y = 32 et le trottoir, trottoir et passage piéton au-dessus de y = 336 (vérifiable avec `-SansInterface` en mesurant l'image ou avec une ligne `PX0 cadrage maison_haut=<y> sol=<y>` ajoutée par dev-ville) ; l'arbre de premier plan visible sur les 4 formats et ne recouvrant ni la maison ni Gérard.
- **CA-B6 (personnages plus grands)** : ligne `PX0 figurine gerard=24x42 ecran=72x126` à 1920 × 1080 (h = 126 px, rapport ≥ 1,4 avec les 84 px de PX0) ; planche : sur Gérard on distingue œil, sourcil, bouche, main, chaussure ; **Sylvie à la fenêtre** (`px0_bis_sylvie_0/1/2`) : 3 humeurs nettement différentes à ×3 **sans** la planche (sourcils et bouche), avis motivé du testeur.
- **CA-B7 (échelle cohérente)** : porte de la maison plus haute que Gérard (≥ 44 px), voitures d'au moins 66 px de long et 28 px de haut, lampadaire ≥ 2 × Gérard ; ligne `PX0 echelle porte=<h> voiture_rouge=<l>x<h> voiture_grise=<l>x<h> lampadaire=<h> maison=<l>x<h>`.
- **CA-B8 (contenu de la référence)** — grille à cocher sur `px0_bis_jour_1080` (oui / partiel / non + zone de la capture) : ciel bleu à gros nuages blancs ; skyline bleutée avec au moins une grue ou un pylône ; ≥ 5 bâtiments de silhouettes différentes ; joints de briques visibles ; toits d'ardoise **et** de tuiles ; fenêtres à encadrement ; ≥ 2 portes de couleurs différentes ; boutique à auvent rouge et enseigne ; boîte aux lettres ; bouche d'incendie rouge ; muret à chaperon ; ≥ 2 grands arbres verts en 3-4 tons ; tronc de premier plan ; lampadaire noir à cloche ; trottoir en dalles, bordure, chaussée avec marquages et passage piéton ; voiture rouge et voiture grise ; ombres portées en aplat. CA validé si **tous** les éléments sont « oui » ou « partiel » et au plus 3 « partiel ».
- **CA-B9 (comparaison visuelle)** : `px0_bis_montage_ref` (référence à gauche à la hauteur de la capture, capture à droite) : avis motivé du testeur sur luminosité, saturation, densité de détails, profondeur (3 plans lisibles), chaleur. Ne jamais décalquer : aucune zone de la capture ne reproduit la composition exacte de la référence. Le verdict du style appartient au joueur : le testeur signale les écarts et ne refuse que sur un CA mesurable.
- **CA-B10 (nuit)** : `px0_bis_nuit_1080`, `px0_bis_nuit_tel` : même scène teintée (aucun élément ajouté ou retiré hors lumières), fenêtres allumées, halo du lampadaire en 3 disques, `PX0 fondu=3.0s`.
- **CA-B11 (fps)** : `-Fps` à 1920 × 1080 avec et sans interface (la branche ville seule n'a pas d'interface ; avec interface : sur la fusion simulée de CA-B12) : `PX0 images_par_seconde=<n>`, n ≥ 55.
- **CA-B12 (fusion simulée)** : copie isolée de `main` actuel (lot 01 fusionné) + `lot/px0-ville` + `lot/px0-interface`, `user://` à part : fusion sans conflit ; `outils/tests.ps1` découvre `test_pixel` et reste vert (202 + test_pixel) ; `capture_px0.ps1 -Serie` code 0 ; `px0_bis_carte_1080` : carte de l'héritage lisible au-dessus de la rue claire, portrait réel de M. Lefranc.
- **CA-B13 (périmètre)** : `git diff --stat b586055..lot/px0-ville` limité au §2 ; aucun `.ttf.import` ; aucune couleur codée en dur dans `scripts/pixel/` hors `palette.gd` (recherche de `Color("#`, `Color(0.`, `Color(1`).
- **CA-B14 (user:// intact)** : comme CA-V11 de PX0 (liste des fichiers et SHA-256 de `partie_en_cours.sav` identiques avant / après `-Serie`).
- **CA-B15 (lancement)** : `Voir_PX0.bat` : commande avec `-- --px0-quitter-apres=5` : plein écran, fermeture seule, code 0, sans erreur.
- Non vérifiable ici (à écrire comme tel) : ressenti de la dérive des nuages et du fondu ; vrai téléphone ; 2560 × 1440 réel.

## 7. Série de captures (`capture_px0.ps1 -Serie`)
Mêmes noms que PX0 avec le préfixe `px0_bis_` (les anciennes captures `px0_*` restent pour comparaison) : `jour_1080`, `nuit_1080`, `jour_720`, `jour_1366`, `jour_tel`, `nuit_tel`, `sylvie_0`, `sylvie_1`, `sylvie_2`, `grille_x2`, `grille_x3`, `grille_x4`, `grille_1366`, `grille_tel`, `libre_0`, `libre_15`, `planche`, et les montages `montage_ref` (`rue_pixel_v2.jpg` + `jour_1080`), `montage_px0` (`px0_jour_1080` + `px0_bis_jour_1080`), `montage_pc` (`v3_rue.png` + `jour_1080`). Sur la fusion simulée (CA-B12) : `carte_1080`, `jersey_1080`.

Envoi au joueur (coordinateur, après OK du testeur et ma validation) : `px0_bis_jour_1080`, `px0_bis_nuit_1080`, `px0_bis_jour_tel`, `px0_bis_planche`, `px0_bis_montage_ref`, `px0_bis_montage_px0`, `px0_bis_carte_1080`, et `Voir_PX0.bat` après fusion. Questions :
1. Le style : « oui », « oui avec ajustements » ou « non » ?
2. Taille des personnages (24 × 42, ≈ 1,5 × PX0) : bien, plus grands, plus petits ?
3. Avec cette échelle, la rue ne tient plus en entier sur l'écran : préférez-vous une rue **plus large que l'écran** (la caméra glisse vers la banque quand le banquier appelle, vers la Gazette pour une news) ou des bâtiments plus étroits pour tout voir d'un coup ?
4. La rue est en briques (façon Nord ou banlieue parisienne des années 1980) ; les marqueurs français restent (boîte aux lettres jaune, plaque bleue, R5, 205) : ça vous va ?
5. La barre du haut et la frise restent foncées sur un ciel clair : on garde, ou on essaie des panneaux plus clairs ?

## 8. Validation (chef de projet)
- [ ] CA-B1 à CA-B15 (rapport du testeur OK) · [ ] série relue · [ ] push de `lot/px0-ville`, puis fusion ville puis interface dans `main` (`--no-ff`), tests et `-Serie` relancés sur `main` · [ ] bases à jour
- Décision :
