# 16 : Bible graphique « pixel » (rue, personnages, interface)

> Auteur : designer UX. Date : 2026-10-29. Statut : **proposition, à valider par le joueur sur une preuve de concept (§6.1)**.
> **Révision du 2026-10-29 (§8)** : le style de rue de PX0 est rejeté ; nouvelle référence `rue_pixel_v2.jpg` (plein jour, briques, arbres verts), palette étendue à 59 couleurs, personnages 24 × 42. Le §8 prime sur §1.1, §2.2, §2.6 pour la rue.
> Une fois validée, ce document **remplace `09_direction_artistique_godot.md` pour tout le visuel** : style de la ville, palette, matières, polices, panneaux (09 §2.2, §2.6 à §2.9, §6). Restent valables dans 09 : l'intention « un lieu par type de message » (§2.1), la composition de la rue (§2.3, à redimensionner), la ville qui vit (§2.4), l'époque dans la rue (§2.5), les 10 effets (§3), la mise en page adaptative (§4).
> Origine : retour du joueur du 2026-10-29 (`10_retours_joueur.md`) : « la vue de face est pas mal mais le style est trop "générique" » ; deux références déposées dans `docs/sources/graphisme/references/`.
> Nouveaux éléments à dessiner (docs/15) : Jean-Mi, Tonton Matelas, Tata Livret, Mme Lopez la concierge, Sylvie à la fenêtre (3 humeurs), la maison qui évolue (P10), cartes de dilemme et de projet, Lundi noir en direct, classement de la rue **permanent**, écran de fin avec titres.

---

## 0. En une phrase

**Le monde en vrais pixels, les chiffres en net.** La rue, les personnages, les objets, les cadres et les titres passent en pixel art sur une grille de **640 × 360 pixels d'art**, agrandie d'un facteur entier (×2, ×3 ou ×4) ; les montants, les textes longs et les graphiques restent dans une police nette et lisible, posés dans des cadres pixel. On garde la vue de face, les trois bâtiments-sources et toute l'ergonomie actuelle.

Pourquoi le rendu actuel fait « générique » (captures `v3_rue.png`, `v3_heritage.png`, `v3_historique.png`) : formes géométriques lisses sans matière (aucune brique, aucune ardoise, aucune pierre), aucun contour ni texture, tous les bâtiments au même niveau de détail, personnages en « gélules » sans visage, interface de type application (panneaux bleu nuit arrondis, police système) qu'on retrouve dans mille jeux mobiles. Le pixel art apporte d'un coup la **matière**, le **caractère** (visages, enseignes, objets d'époque) et une **signature** reconnaissable.

---

## 1. Lecture des références

### 1.1 La rue (`rueStyle.jpg`)

| Aspect | Ce qu'on voit, concrètement | Ce qu'on en garde |
|---|---|---|
| **Taille du pixel** | Le panorama fait environ 400 × 115 pixels d'art (un pixel d'art ≈ 4 pixels de l'image). Une maison fait 45 à 55 px de large et 70 à 100 px de haut ; une fenêtre 4 à 6 px. Le pixel est **gros et assumé**. | Grille de 640 × 360 agrandie ×3 sur un écran 1080p : même grain, assez gros pour qu'on « voie le pixel ». Nos bâtiments sont plus grands (96 à 128 px de large) car ils sont jouables et portent des personnages. |
| **Couleurs** | 40 à 60 teintes visibles (image de banque d'images, palette non stricte), mais **chaque matière tient en 3 ou 4 tons** : brique (rouge clair, rouge, brun), ardoise (bleu-gris clair, moyen, sombre), pierre crème (3 tons), feuillage (jaune, orange, rouge, brun). | Palette fixe de 40 couleurs (§2.3), rampes de 3 ou 4 tons par matière. |
| **Contours** | Les silhouettes sont fermées par un **contour sombre teinté** (le ton le plus foncé de la matière, jamais du noir pur) ; toits soulignés d'un liseré clair (zinc) ; corniches = 1 ligne claire + 1 ligne sombre dessous. | Contour teinté pour les bâtiments, contour « encre » violet très sombre pour les personnages et petits objets (§2.4). |
| **Ombrage** | Lumière venant d'en haut à gauche ; aplats à 2 ou 3 tons, **aucun dégradé** sauf le ciel ; ombres portées de 1 à 2 px sous les corniches, les auvents, les appuis de fenêtre ; vitres sombres avec un reflet de 1 px. | Mêmes règles (§2.4). Pas de dégradé lisse dans le monde. |
| **Densité de détails** | Trois niveaux : la **silhouette** varie (mansarde, pignon, toit en croupe, tour d'horloge) ; le **rythme** de façade (rangées de fenêtres, corniches, auvents rayés) ; les **micro-détails** au rez-de-chaussée (jardinières, pots de fleurs, boîtes aux lettres, grilles, lampadaires, bancs). Le haut des façades est calme, le bas est foisonnant. | « Calme en haut, vivant en bas » : c'est aussi là que passent les personnages et que le joueur regarde. Chaque bâtiment a **un élément signature** (l'horloge de la banque, l'écran du toit de la Gazette, la meulière et la marquise de la maison). |
| **Rythme de la rue** | Alternance chaud (brique, crème) / froid (ardoise, gris-bleu) ; hauteurs qui alternent ; **arbres glissés entre les bâtiments** et derrière, qui cassent la répétition et donnent la profondeur. | Alternance chaud / froid entre maison (chaude), Gazette (froide), banque (crème) ; arbres entre les bâtiments ; immeubles de fond plus pâles. |
| **Lumière, ambiance** | Fin d'après-midi d'automne : ciel bleu saturé, nuages en marches d'escalier à 3 tons, feuillages orange et rouges en **contraste complémentaire** avec le ciel. Chaleureux et « cosy ». | L'automne devient l'image de référence (écran titre, captures), mais les saisons restent liées aux mois (09 §2.4) ; chaque saison a sa variante de feuillage et de lumière. |
| **Ce qu'on ne garde pas** | Architecture anglo-américaine (porches, bow-windows, bardage bois, tour isolée), filigrane Dreamstime. | Image de référence seulement, **jamais** intégrée, décalquée ni utilisée pour entraîner un outil. |

### 1.2 Le personnage (`stylePersonnage.png`)

| Aspect | Ce qu'on voit | Ce qu'on en garde |
|---|---|---|
| Proportions | Chibi d'environ **2,3 têtes** ; la tête (cheveux compris) fait près de 45 % de la hauteur. | 2,5 têtes pour les figurines de rue ; bustes « grosse tête » pour les portraits. |
| Visage | Grands yeux (blanc + pupille de 2 à 3 px), sourcils épais qui portent l'expression, nez réduit à une ombre, bouche de 3 à 4 px. | L'expression passe par **les sourcils et la bouche** : 3 expressions par personnage en changeant 6 à 10 pixels. |
| Contour | Contour sombre de 1 px partout (brun très foncé sur la peau, bleu nuit sur le costume). | Contour « encre » `#1C1626` sur les personnages ; contour intérieur plus clair autorisé (bras devant le corps). |
| Ombrage | 2 tons par matière (cel shading) + 1 reflet sur les cheveux et les plis du costume ; source de lumière en haut à gauche. | Idem : clair, moyen, sombre ; 1 reflet maximum par matière. |
| Couleur | Accent saturé (cheveux roux, stylo rouge) sur des vêtements désaturés : l'œil va au visage. | Chaque personnage a **une couleur signature** saturée (Jean-Mi : veste rouge ; Tata Livret : cardigan vert Caisse d'épargne ; Tonton Matelas : béret et pull marron ; Mme Lopez : blouse bleue et fichu ; M. Lefranc : cravate bordeaux ; Sylvie : pull jaune moutarde ; Gérard : blouson bleu de travail). |
| Pose | Trois quarts, en mouvement, penché vers l'avant : du dynamisme. | Figurines de rue de **profil** (elles marchent le long de la rue) ; portraits de **trois quarts** (comme la référence). |

### 1.3 Une rue française des années 80 : l'inventaire du décor

Ce qui rend la rue **française** et **datée**, donc non générique (à dessiner en priorité) :

| Élément | Détail qui « fait vrai » | Où |
|---|---|---|
| Maison de Gérard | **Pavillon en meulière** (pierre ocre grumeleuse à joints rouges : motif généré), tuiles mécaniques rouges, marquise en verre au-dessus de la porte, volets battants bleu-vert, boîte aux lettres, petit jardinet derrière une grille basse | rue, à gauche |
| La Gazette | **Immeuble de presse** en pierre (pas une tour moderne) : grande enseigne peinte « LA GAZETTE » au 1er étage, rotatives visibles à travers la vitrine du rez-de-chaussée, et sur le toit le **journal lumineux** (écran à points ambre) qui donne l'indice | rue, au centre, le plus haut |
| La banque | Pierre de taille crème, 4 colonnes, fronton, **horloge** (clin d'œil à la référence), porte en bois à deux battants, **distributeur à écran vert** (1984 : rare, à afficher à partir de 1986), plaque en laiton | rue, à droite |
| Immeubles de fond | Haussmanniens : pierre crème, balcons filants au 2e et au 5e, toits en zinc gris-bleu « à la Mansart » avec lucarnes et cheminées à poteries orange | arrière-plan |
| Commerces | **Café-tabac** avec la carotte rouge « TABAC », chaises bistrot ; boulangerie à auvent rayé ; **pharmacie à croix verte** clignotante | décor latéral |
| Mobilier urbain | **Kiosque** vert à coupole avec affiche « 3615 » ; **cabine téléphonique** (« PTT » puis « Télécarte ») ; **plaque de rue bleue émaillée** à liseré vert (« RUE DES ÉPARGNANTS ») ; colonne Morris (affiches de cinéma de l'année) ; boîte aux lettres jaune ; réverbère parisien ; banc ; potelets ; platanes | trottoir |
| Véhicules | **Renault 5**, **4L**, **Peugeot 205**, 2CV, Citroën BX, camionnette J7 ; Solex et Mobylette ; la **Porsche 944 rouge** de Jean-Mi ; la Super 5 de Gérard (projet P1C) | chaussée |
| Signes d'époque | Antennes râteau, paraboles absentes, affiches électorales (1986, 1988), Top 50 sur la colonne Morris, berceau puis tricycle (enfants de Gérard) | variantes par année (09 §2.5) |

---

## 2. Règles techniques du pixel art dans Godot 4

### 2.1 Grille native et agrandissement entier

| Règle | Valeur |
|---|---|
| **Grille de la ville** | Hauteur fixe de **360 pixels d'art** ; largeur selon l'écran : **640** (16:9), 576 (16:10), jusqu'à **800** (20:9 des téléphones). La largeur en plus montre du décor latéral (comme aujourd'hui). |
| **Facteur N** | Entier : **N = plus grand entier** tel que la **zone utile** (448 × 232 px d'art, §2.6) tienne dans le rectangle libre de l'écran (écran moins barre haute, frise et panneau ouvert), **mesuré en pixels physiques**. Jamais de facteur fractionnaire en jeu. |
| Exemples (calculés) | PC 1920 × 1080 : **×3** (panneau ouvert ou fermé). PC 2560 × 1440 : ×4. Portable 1366 × 768 : ×2. Téléphone 2400 × 1080 (facteur d'interface 1,7) : **×3**, vue de 800 × 360. Téléphone 1600 × 720 : ×2, vue de 800 × 360. Téléphone 3200 × 1440 : ×4. La vue fait donc **toujours environ 360 px d'art de haut** : le cadrage est stable d'un appareil à l'autre. |
| Pourquoi pas une grille plus fine (960 × 540) | Sur un téléphone 720p, elle tomberait à ×1 (personnages de 40 px physiques, illisibles) ou à ×1,5 (pixels irréguliers, flous). Et elle demande 2,25 fois plus de pixels à dessiner. La grille 640 × 360 tombe juste sur 720p, 1080p et 1440p. |
| **Mise en œuvre** | La ville est rendue dans un **`SubViewport`** de taille `ceil(taille_physique / N)`, avec `snap_2d_transforms_to_pixel` et `snap_2d_vertices_to_pixel` activés, `canvas_item_default_texture_filter` = **Nearest**. L'image est affichée par un `TextureRect` (filtre **Nearest**) qui couvre toute la fenêtre, de taille `taille_physique / facteur_interface` en px virtuels : le facteur d'interface (1,0 ; 1,25 ; 1,7) s'annule, il reste exactement N pixels physiques par pixel d'art. **Ne pas** passer par `SubViewportContainer.stretch_shrink` dans l'espace virtuel (il serait multiplié par 1,7 : pixels irréguliers). |
| Le HUD | Reste dans l'espace virtuel 1 920 × 1 080 avec le facteur 1,7 du téléphone (09 §4.1) : **rien ne change pour la lisibilité des chiffres**. |
| Caméra | `Camera2D` dans le `SubViewport` ; position **arrondie au pixel d'art** à chaque image ; recadrage du panneau (0,3 s) par pas entiers ; secousse du krach : décalages entiers de 1 à 3 px d'art (le HUD bouge à 30 % comme aujourd'hui). |
| Zoom | Toujours entier au repos. Pendant une transition courte (plongée vers la maison de l'écran titre, 0,8 s), un zoom non entier est toléré, puis il se pose sur un entier. |
| Mouvements | Voitures, passants, nuages, particules : positions arrondies au pixel d'art à l'affichage (la vitesse peut rester décimale dans le calcul). Parallaxe : chaque plan est arrondi séparément. |
| Toucher et clic | Conversion écran → ville par la même fonction que l'affichage (`position_physique / N + origine_camera`) ; l'API actuelle (`position_ecran()`, `ecran_batiment()`, `contient()`) est **conservée** pour que le HUD, les pièces et les cartes qui « sortent des bâtiments » continuent de fonctionner. Zones de toucher : au moins 200 × 200 px virtuels (inchangé), elles peuvent dépasser le dessin. |
| Rendu | Compatibility, `CPUParticles2D` (dans le `SubViewport`, donc automatiquement pixellisées) ; textures en **PNG sans compression avec perte**, sans mipmaps. |
| Effets d'interface | Les pièces volantes, les montants flottants, les ondes du téléphone vivent dans le calque d'effets (espace virtuel). Leurs sprites sont agrandis d'un **facteur entier en px virtuels (×3)** avec filtre Nearest ; ils peuvent glisser hors grille (mouvement fluide), le monde, lui, reste sur la grille. |

**Règle de lisibilité** : **aucune information nécessaire au jeu n'est seulement dans la ville.** L'écran du toit, le kiosque, le bandeau LED et les bulles sont du décor et de l'ambiance ; chaque chiffre utile est aussi dans le HUD ou une carte, en police nette.

### 2.2 Échelle des objets (en pixels d'art)

Référence : une figurine adulte mesure 28 px ; « 1 mètre » vaut environ 14 px pour les objets, mais les véhicules sont **raccourcis** (style jouet) pour tenir dans la rue.

| Élément | Taille (l × h) | Remarques |
|---|---|---|
| **Figurine** adulte (Gérard, Sylvie dehors, voisins, concierge, banquier, passants) | **16 × 28** | 2,5 têtes (tête 11 px de haut, 10 de large), profil, contour encre. Origine : milieu des pieds. |
| Enfant / bébé en poussette | 10 × 16 / poussette 18 × 14 | double poussette 26 × 14 (jumeaux) ; tricycle 14 × 12 |
| **Portrait de bulle** (passages, classement, historique) | **32 × 32** | buste de trois quarts, fond transparent |
| **Portrait de carte** (banquier, Sylvie des cartes de dilemme, voisins des cartes de lecture) | **48 × 48** | buste, trois quarts, 3 expressions |
| Sylvie à la fenêtre | buste 12 × 14 dans une fenêtre de 18 × 22 | 3 humeurs ; l'humeur est **aussi** lisible par une bulle (§5.1) |
| Maison de Gérard | 96 × 124 (cheminée comprise) | rez-de-chaussée + 1 étage + toit ; jardinet 24 px à gauche |
| La Gazette | 112 × 216 (antenne comprise) | rez-de-chaussée 40, 3 étages de 34, corniche 6, écran du toit 72 × 36, antenne 24 |
| La banque | 128 × 150 | horloge de 16 px dans le fronton |
| Immeubles de fond | 64 à 112 × 140 à 200 | assemblés à partir de modules (§4.2) |
| Kiosque / cabine / colonne Morris | 28 × 48 / 16 × 44 / 14 × 40 | |
| Réverbère / arbre (platane) | 8 × 56 / 40 × 64 | |
| Renault 5 / 4L / 205 / 2CV | 48 × 20 / 46 × 22 / 46 × 20 / 44 × 22 | roues de 8 px |
| Porsche 944 / break / camionnette | 56 × 18 / 58 × 22 / 54 × 26 | |
| Vélo de Jean-Mi, Solex | 20 × 14 (+ figurine) | |
| Pièce d'or ou de cuivre | 8 × 8 | 4 images de rotation |
| Icônes (téléphone, enveloppe, journal, maison, banque) | 16 × 16 | aussi dans le HUD, agrandies ×3 |
| Tuile de façade | modules de 8 px (fenêtre 12 × 20, travée de 16 px, étage de 34 px) | §4.2 |

### 2.3 Palette « Rue 84 » (40 couleurs)

34 couleurs pour le monde + 6 couleurs réservées à l'interface. **Toutes** les images (dessinées en code, achetées ou fournies) sont ramenées à cette palette (outil de contrôle au chargement, §4.4). Les variantes **nuit** et **orage** (krach, Lundi noir) sont des tables de substitution couleur par couleur : chaque image existe en 3 versions précalculées au chargement, et le passage jour → nuit est un fondu de 3 s entre deux versions. Les couleurs **émissives** (lumières, néon, écrans) ne changent pas : la nuit, elles « brillent » d'elles-mêmes.

| # | Nom | Jour | Nuit | Orage | Usage |
|---|---|---|---|---|---|
| 1 | encre | `#1C1626` | `#120F1E` | `#1A1418` | contour des personnages et petits objets, texte sur papier |
| 2 | nuit | `#2D2840` | `#1B1A30` | `#2A2230` | ombres profondes ; **fond des panneaux du HUD** (remplace `#161E2E`) |
| 3 | ardoise sombre | `#46415C` | `#262842` | `#3A3440` | toits d'ardoise (ombre), biseau des panneaux |
| 4 | ardoise | `#6B6880` | `#363A5C` | `#565060` | toits, zinc, chaussée |
| 5 | gris pierre | `#9C98A6` | `#4A4E72` | `#7A7280` | trottoir, pierre grise ; **texte secondaire** du HUD |
| 6 | zinc clair | `#C9C6CC` | `#5F6488` | `#9A929C` | reflets des toits, liserés |
| 7 | crème | `#F3E9D2` | `#6E7092` | `#B8AA9E` | papier, pierre éclairée ; **texte principal** du HUD |
| 8 | blanc chaud | `#FFF9EC` | `#7A7EA0` | `#C8BCB0` | reflets, nuages, chemises |
| 9 | pierre ombre | `#8C735A` | `#3E3A52` | `#6A5650` | pierre de taille (ombre), meulière |
| 10 | pierre | `#BFA27C` | `#575470` | `#8E7868` | pierre de taille, meulière |
| 11 | pierre claire | `#E2CBA0` | `#6A6884` | `#A89280` | façades crème (Haussmann, banque) |
| 12 | brique sombre | `#6E2E2E` | `#32223A` | `#522628` | joints, ombres de brique |
| 13 | brique | `#A8483A` | `#4A2E48` | `#7E3A34` | brique, cheminées |
| 14 | tuile | `#D06A45` | `#5C3A50` | `#9A5040` | tuiles mécaniques, poteries |
| 15 | terre cuite claire | `#E9A070` | `#6A5266` | `#AE7A60` | reflets des tuiles, peau hâlée claire |
| 16 | bois sombre | `#4E3226` | `#241C2C` | `#3A2624` | portes, troncs (ombre), peau foncée (ombre) |
| 17 | bois | `#7A5034` | `#36283A` | `#5A3C30` | portes, bancs, troncs, peau foncée |
| 18 | bleu nuit | `#283A6B` | `#141C40` | `#22283E` | haut du ciel du soir, costumes |
| 19 | bleu ardoise | `#3F5C96` | `#1E2C5A` | `#364056` | volets, vêtements, ombre du ciel |
| 20 | ciel | `#6FA4D8` | `#22345E` | `#5A5A6E` | ciel, vitres de jour |
| 21 | ciel clair | `#A9D4EE` | `#34466E` | `#7A7484` | bas du ciel, reflets de vitre |
| 22 | vert sombre | `#2F5240` | `#16243A` | `#26362E` | feuillage (ombre), kiosque, liseré de la plaque de rue |
| 23 | vert | `#4F8A4B` | `#22364A` | `#3E5A3E` | feuillage, cardigan de Tata Livret |
| 24 | vert clair | `#8DBF5A` | `#34485A` | `#66804C` | feuillage éclairé, printemps |
| 25 | orange | `#E2803A` | `#64404E` | `#A0603A` | feuillage d'automne, poteries |
| 26 | rouge auvent | `#C7323F` | `#52263E` | `#8E2C34` | auvents, carotte du tabac, Porsche, veste de Jean-Mi |
| 27 | bleu vif | `#2F7FD1` | `#1E3268` | `#34507E` | voitures, plaque de rue, blouse de Mme Lopez |
| 28 | peau claire | `#F4D0AE` | `#6E6480` | `#B4988A` | peau |
| 29 | peau ombre | `#D49A74` | `#5A4A66` | `#96705E` | ombre de peau |
| 30 | caramel | `#A8714E` | `#46344A` | `#7A5444` | peau mate, cheveux châtains |
| 31 | **lumière** | `#FFD97A` | = | = | fenêtres allumées, réverbères, phares (émissive) |
| 32 | **néon rose** | `#FF5FA2` | = | = | enseigne de la Gazette, logo du titre (émissive) |
| 33 | **ambre** | `#FFB547` | = | = | journal lumineux du toit ; **accent** de l'interface (émissive) |
| 34 | **or** | `#F2C14E` | `#6E5A5A`* | `#B08A48`* | feuilles d'automne, pièces d'or, enseigne de la banque (*le feuillage s'assombrit, les pièces et l'or du HUD non) |
| 35 | gain | `#46E08A` | = | = | hausses ▲, écran du distributeur, croix de la pharmacie |
| 36 | perte | `#FF5C5C` | = | = | baisses ▼, chiffres rouges du Lundi noir |
| 37 | gel | `#7FD6FF` | = | = | pause |
| 38 | cuivre | `#C77B4A` | = | = | frais (jamais le rouge des pertes) |
| 39 | gain sur papier | `#1B6E3E` | = | = | montants positifs sur les cartes papier (contraste 5,2:1 sur crème) |
| 40 | perte sur papier | `#B3261E` | = | = | montants négatifs et manchettes rouges sur papier (5,3:1) |

- **Option daltonisme** (hors palette, inchangée) : gain `#4DA3FF`, perte `#FF9F1C` ; sur papier : `#1F5FA8` et `#8F4C00` (5,3:1 et 5,4:1). Les variations portent toujours ▲/▼ et +/− : jamais la couleur seule.
- Contrastes calculés (WCAG) sur le fond de panneau `#2D2840` : crème 11,7:1 ; gris pierre 5,0:1 ; gain 8,3:1 ; perte 4,7:1 ; ambre 8,0:1 ; gel 8,7:1. Sur papier crème `#F3E9D2` : encre 14,6:1 ; gain sur papier 5,2:1 ; perte sur papier 5,4:1. Le panneau est presque opaque (α 0,94) pour que ces valeurs tiennent au-dessus de la ville.
- **Ciel** : dégradé **en bandes** (5 bandes de la rampe 18 → 21, plus le crème en bas le jour), transitions tramées par une matrice de Bayer 4 × 4 au pixel d'art. Couchant : bandes orange (25) et terre cuite (15) près de l'horizon. Nuit : rampe nuit, étoiles de 1 px (8, clignotement 2 états). Orage : rampe orage + nuages lourds.
- **Saisons** : le feuillage change de couleurs par table (printemps 24/23/22 ; été 23/22 ; automne 34/25/26 ; hiver : branches nues en bois 17/16, neige 8 sur les toits).

### 2.4 Contours et ombrage

1. **Lumière** venant d'en haut à gauche, partout, toujours (même la nuit : seule la palette change).
2. **Bâtiments** : contour extérieur dans le ton le plus sombre de leur matière (brique → brique sombre, ardoise → nuit, pierre → pierre ombre). Pas de contour à l'intérieur des façades : les volumes se lisent par 1 ligne claire en haut (corniche, appui) et 1 ligne sombre dessous (ombre portée de 1 à 2 px).
3. **Personnages, véhicules, petits objets** : contour **encre** `#1C1626` de 1 px, fermé ; à l'intérieur de la silhouette (bras devant le corps), contour dans le ton sombre de la matière. C'est ce qui les détache d'un décor chargé, comme dans la référence.
4. **Trois tons par matière** (clair, moyen, sombre) et **un reflet** au plus (cheveux, vitre, carrosserie). Décalage de teinte : les ombres tirent vers le bleu-violet, les lumières vers le jaune (la palette est construite ainsi).
5. **Interdits** : dégradés lisses dans le monde, anticrénelage automatique, « pillow shading » (ombre tout autour du contour), lignes de 1 px en escalier irrégulier (pas de 1-2-1-3 : des marches régulières 1-1-1 ou 2-2-2), pixels isolés qui ne lisent rien (« bruit »).
6. **Tramage** : seulement pour le ciel, les grandes surfaces (chaussée lointaine) et la **vignette du journal** (2 tons d'encre sur papier, §5.4). Jamais sur les personnages.
7. **Anticrénelage manuel** : 1 pixel intermédiaire autorisé sur les courbes des têtes et des carrosseries.
8. **Lumières** : sur un calque séparé en mélange additif (principe de 09, conservé) : fenêtres allumées en lumière (31), halos en 3 disques pixellisés d'alpha 0,30 / 0,18 / 0,08 (pas de dégradé radial lisse).

### 2.5 Animations (nombre d'images par cycle)

Petit nombre d'images, vitesse basse : c'est le charme du pixel art et cela coûte peu.

| Animation | Images | Cadence | Remarque |
|---|---|---|---|
| Figurine : marche | 4 (contact, passage, contact, passage) | 8 im/s | déplacement de 1 px d'art par image à ×1 ; en accéléré, la cadence monte à 12 im/s |
| Figurine : repos | 2 (respiration : tête de 1 px plus bas) | 2 im/s | |
| Figurine : parler | 2 (bouche) | 6 im/s | pendant une bulle |
| Figurine : réaction | 1 ou 2 (bras levés, mains sur la tête) | — | Lundi noir, projet réalisé |
| Portrait de carte : clignement | 2 (yeux ouverts / fermés 120 ms) | toutes les 3 à 6 s | |
| Portrait : parler | 2 (bouche) | 6 im/s | pendant l'apparition du texte |
| Sylvie à la fenêtre | 3 humeurs statiques + clignement 2 | — | |
| Voiture | roues 2 images ; caisse qui s'abaisse de 1 px une image sur 4 | 8 im/s | phares sur le calque de lumière la nuit |
| Arbre | 2 images (feuillage décalé de 1 px) | 1 im/s | + feuilles qui tombent (particules 2 × 2) en automne |
| Fumée de cheminée | 4 | 4 im/s | hiver |
| Combiné de la banque qui sonne | 3 (gauche, centre, droite) | 12 im/s | + 3 anneaux pixellisés qui s'agrandissent |
| Horloge de la banque | 8 positions de l'aiguille | 1 tour par mois de jeu | |
| Néon de la Gazette | 2 (allumé, faible) | bruit aléatoire | |
| Journal lumineux du toit | défilement de 1 px par image | 30 im/s | police à points 5 × 7 générée en code |
| Antenne | 2 (feu rouge allumé / éteint) | 1 im/s | |
| Pièce d'or / de cuivre | 4 (rotation) | 12 im/s | |
| Pluie / neige | particules 1 × 4 / 1 × 1 et 2 × 2 | — | |
| Étoiles | 2 états | aléatoire | |
| Porte de la maison qui s'ouvre (carte qui sort) | 3 | 12 im/s | puis la carte glisse (interface) |

Budget : environ 6 cycles par personnage récurrent (marche 4, repos 2, parler 2, réaction 2, portraits 3 + 2) ; c'est réaliste en code et pour un graphiste.

### 2.6 Composition de la rue (en pixels d'art)

```
 y (px d'art, vue de 360 de haut sur un écran 16:9 à ×3)
   0 ┌──────────────────────────────────────────────────────────────────────────────────────┐
     │ barre haute du HUD (96 px virtuels = 32 px d'art)                                    │
  32 ├──────────────────────────────────────────────────────────────────────────────────────┤
     │ ciel en bandes, nuages pixel        [LA RUE: classement]           ┌─antenne          │
     │ toits de Paris lointains (pâles)    (HUD, §5.2)               ┌────┴────┐            │
 104 │ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ │ ← haut de la zone utile
     │ immeubles haussmanniens (plan moyen)                          │ ▒INDICE▒│  journal   │
     │                                                               │ ╱╲_╱‾╲_ │  lumineux  │
     │                                                               ├─────────┤            │
     │                                                               │LA GAZETTE│ (enseigne) │
     │      ┌──────┐ ← toit de tuiles, cheminée                      │ ▫ ▫ ▫ ▫ │  ┌─────────┐│
 212 │     ╱ ▓▓▓▓▓▓ ╲                                                │ ▫ ▫ ▫ ▫ │  │ (horloge)││
     │    │ ▫  ▣  ▫ │ ← fenêtre de Sylvie                           │ ▫ ▫ ▫ ▫ │  │ BANQUE  ││
     │    │ meulière │      ┌kiosque┐  arbre                         │ rotatives│  │ ║ ║ ║ ║ ││
     │ ┌┐ │ ▫ ┌──┐ ▫│      │ 3615  │                    cabine      │ [vitrine]│  │ ║ ▣ ║ ║ ││
 312 │═╧╧═╧═══╧══╧══╧══════╧═══════╧════════════════════════════════╧══════════╧══╧═════════╧╧═│ ← trottoir (8 px)
     │   R5 →        chaussée (16 px)                ← 205                                 │
 336 ├──────────────────────────────────────────────────────────────────────────────────────┤ ← bas de la zone utile
     │ frise du HUD (72 px virtuels = 24 px d'art)                                          │
 360 └──────────────────────────────────────────────────────────────────────────────────────┘
       ◄──────────────────────── zone utile : 448 × 232 px d'art, toujours visible ────────►
```

- **Zone utile** : 448 × 232 px d'art, alignée en bas au-dessus de la frise. De gauche à droite : jardinet (24) · maison (96) · kiosque (28) · arbre · Gazette (112) · cabine (16) · banque (128), avec des écarts de 8 à 12 px.
- Plans de parallaxe : ciel (0), toits lointains (0,15), immeubles du plan moyen (0,4), rue (1), premier plan (potelets, réverbères, 1,15). Comme dans la référence, des arbres passent **entre** et **derrière** les bâtiments.
- Étiquettes « MA MAISON », « LA GAZETTE », « MA BANQUE » : éléments du HUD (police pixel, §3.2), posées sur la chaussée comme aujourd'hui.

---

## 3. L'interface dans le même univers

### 3.1 Principe : « cadres pixel, contenu net »

| Couche | Rendu | Pourquoi |
|---|---|---|
| Cadres (panneaux, cartes, boutons, onglets, pastilles) | **Pixel art en 9-patch** (`StyleBoxTexture`, filtre Nearest, texels agrandis ×3 en px virtuels) | C'est ce qui fait entrer l'interface dans l'univers. |
| Titres courts, étiquettes, boutons, en-têtes, manchettes | **Police pixel** (Pixelify Sans), en capitales, **≥ 28 px virtuels** | Signature visuelle ; illisible en petit, donc réservée aux mots courts. |
| Chiffres, textes longs, tableaux, bulles d'aide | **Police nette** (Atkinson Hyperlegible Next), tailles de 09 §2.7 inchangées (texte 24 px, minimum 20 px virtuels) | La lisibilité des montants prime (principe 10). |
| Icônes, pictogrammes d'humeur, flèches ▲▼, portraits | Sprites pixel (16 × 16, 32 × 32, 48 × 48) agrandis ×3 | Remplacent les icônes dessinées en `_draw()`. |
| Graphiques (courbe du patrimoine, répartition, piles de F01, barres de fin) | **Restent lisses** (lignes anticrénelées de 3 px), dans les couleurs de la palette | Un graphique en escalier se lit moins bien ; la palette suffit à l'intégrer. |

Remarque technique : sur téléphone, un texel ×3 virtuels devient 5,1 pixels physiques (facteur 1,7) ; les cadres auront des pixels de 5 ou 6 px, différence invisible à cette taille. Le monde, lui, reste au pixel exact (§2.1).

### 3.2 Polices (licence libre, accents français ; à télécharger par l'équipe, pas par moi)

| Rôle | Police | Source et licence | Notes |
|---|---|---|---|
| **Titres, étiquettes, boutons, manchettes** | **Pixelify Sans** (Stefie Justprince), graisses 400 à 700 | Google Fonts : https://fonts.google.com/specimen/Pixelify+Sans — **SIL Open Font License 1.1** ; jeux latin et latin étendu | Accents : É È Ê À Ç Ô Œ à contrôler sur la capture de la preuve de concept. Godot : `FontFile`, `antialiasing` en niveaux de gris, `hinting` aucun, `subpixel_positioning` désactivé, pas de MSDF ; tailles à caler sur sa grille (essais à 28, 32, 48, 72 px virtuels). |
| **Chiffres et textes longs** | **Atkinson Hyperlegible Next** (Braille Institute), graisses 200 à 800 et italiques | Google Fonts : https://fonts.google.com/specimen/Atkinson+Hyperlegible+Next — **OFL 1.1** ; latin étendu | Conçue pour distinguer les caractères proches (1 / l / I, 0 / O, 8 / B) : idéale pour les montants. Chiffres tabulaires (`tnum`) **non confirmés** : à vérifier ; sinon largeur minimale fixe des compteurs (déjà prévu en 09 §2.7). |
| **Journal lumineux, Minitel, écran du distributeur** | **Doto** (Óliver Lalan), matrice à points 6 × 10, axes taille et rondeur des points | Google Fonts : https://fonts.google.com/specimen/Doto — **OFL 1.1** | Couverture des accents à vérifier (« ÉLECTIONS ») ; repli : **VT323** (https://fonts.google.com/specimen/VT323, OFL). Dans la ville même, le bandeau du toit utilise une police 5 × 7 **dessinée en code** (pixel exact). |
| Option à tester | **Jersey 10** (Sarah Cadigan-Fried) | Google Fonts : https://fonts.google.com/specimen/Jersey+10 — OFL 1.1, latin étendu | Police pixel condensée, lisible en grand : candidate pour la **date à volets** et le **patrimoine** (44 à 48 px). À comparer à Atkinson sur la preuve de concept. |

Les polices sont **embarquées** dans `godot/polices/` (avec leur fichier `OFL.txt`) : rendu identique sous Windows et Android, fin des replis `SystemFont` (erreur notée dans ma base). Mention des polices dans un écran « Crédits ».

### 3.3 Les cadres (9-patch, en texels ; ×3 à l'écran)

| Variation de thème | Image source | Bordures 9-patch | Description |
|---|---|---|---|
| `Panneau` (barre haute, frise, « Mon argent », « La rue ») | 24 × 24 | 6 | Fond nuit `#2D2840` (α 0,94) ; contour extérieur encre 1 texel ; biseau clair ardoise sombre 1 texel en haut et à gauche ; coins **en marche d'escalier** (2 texels coupés) ; ombre portée encre α 0,5 décalée de 2 texels en bas. |
| `CartePapier` (carte du banquier, dilemme, projet, courrier, relevé, cartes de lecture) | 32 × 32 | 8 | Papier crème `#F3E9D2`, contour encre, coin supérieur droit corné (3 texels), liseré de couleur de la source sur la gauche (banque or, maison tuile, média néon rose, rue vert). |
| `Journal` | 32 × 32 | 8 | Papier crème légèrement plus gris (ton crème + trame 2 % de gris pierre), bords **déchirés** (bord irrégulier dessiné), double filet sous le titre. |
| `BoutonPrincipal` | 16 × 20 | 5 (bas 7) | Fond ambre, contour encre, **bas 2 texels plus sombre** (relief) ; appui : l'image passe à la version enfoncée (relief 0, contenu descendu de 1 texel). |
| `BoutonSecondaire` | 16 × 20 | 5 | Même forme, fond ardoise sombre ; sur papier : fond crème, contour encre. Dans une présentation du banquier, **même style** pour « Ouvrir » et « Pas maintenant » (principe 11). |
| `Onglet` (historique : TOUT / MA MAISON / MA BANQUE / LA GAZETTE / LA RUE) | 16 × 16 | 4 | Intercalaire de classeur : onglet actif en crème, inactif en ardoise. |
| `Pastille` (vs Livret A, impact, rang) | 12 × 12 | 4 | Pilule en escalier ; contour 1 texel de la couleur gain / perte, fond α 0,16. |
| `Bulle` (passages des voisins, Sylvie) | 16 × 16 + pointe 6 × 4 | 5 | Bulle de BD blanche, contour encre, pointe orientable vers le personnage. |
| `Focus` (clavier, manette) | 12 × 12 | 4 | Cadre de 1 texel blanc chaud qui clignote doucement. |

### 3.4 Écran par écran

| Écran | Dans le nouveau style | Ce qui ne change pas |
|---|---|---|
| **Barre haute** | Réglette en panneau pixel ; **date à volets** = deux plaquettes « calendrier » pixel avec charnière, chiffres en Jersey 10 ou Atkinson gras ; boutons du temps en boutons pixel avec icônes 16 × 16 ; pastille « vs tout au Livret A » en pastille pixel avec flèche sprite ▲/▼ | Disposition, tailles, ordre, comportements (09 §4.2) |
| **Frise** | Rail en pixel (2 tons), curseur = petit calendrier pixel, marqueurs ◆ en sprites 8 × 8, bouton HISTORIQUE avec icône de classeur | Règles (pas de futur) |
| **Mon argent** | Panneau pixel, titres de section en Pixelify ; la courbe reste lisse (or et bleu ciel) ; barre de répartition : segments à motifs **pixel** (hachures 45° en marches, points, lignes) par catégorie | Contenu, ordre |
| **Fenêtre Banque** (carnet + guichet) | **Carnet** = album à pages crème avec coins photo pixel ; chaque produit = une « carte à collectionner » pixel (pictogramme 32 × 32 du produit, silhouette sombre pour les non découverts) ; guichet = formulaire sur papier à en-tête | Carnet 3 × 3, fiche, formulaire, jauge « n/9 » (13 §2) |
| **Cartes du banquier** | Papier à en-tête « BANQUE DE LA RUE » (§5.3), portrait 48 × 48 de M. Lefranc qui parle | Texte ≤ 60 mots, ticket chiffré, comparatif à 5 lignes, 3 boutons de même poids |
| **Carte de dilemme** | Petite carte papier (comme un pense-bête aimanté sur le frigo : coin d'aimant rouge), portrait de Sylvie 48 × 48, 2 boutons avec montant et pictogramme d'humeur 16 × 16 (sourire / neutre / moue) ; sortie de la maison : la porte s'ouvre (3 images), la carte glisse | Déroulé de docs/15 §2.2 |
| **Journal** (krach, nouvelles) | Une de journal pixel : titre « LA GAZETTE » en Pixelify 700, manchette, **vignette tramée** 2 tons (§5.4) | Grammaire 04 §3.5 |
| **Historique** | **Classeur** : onglets intercalaires, lignes sur papier ligné crème, icône de source 16 × 16, montants en Atkinson | Filtres, relecture en lecture seule, défilement |
| **Classement de la rue** | Toujours visible (§5.2) | Règles de docs/15 §4.2 |
| **Écran de fin** | Les 4 voisins devant leur porte sur un mini-décor de rue ; les barres en pixel (blocs de 4 × 4 px) qui montent ; le **titre d'époque** sur une plaque émaillée bleue (comme les plaques de rue), Sylvie à la fenêtre avec son humeur finale | Contenu de docs/15 §6 |
| **Écran titre** | La rue au crépuscule, en pixel ; logo « MA RUE » ou « JEUCLAUDE » en néon rose pixel sur le toit de la Gazette | Travelling, plongée vers la maison (09 §5.1) |

---

## 4. Provenance des images

### 4.1 Les trois voies, honnêtement

| Critère | **a) Pixel art produit en code par l'équipe** | **b) Packs existants** | **c) Images fournies par le joueur** (IA générative ou graphiste) |
|---|---|---|---|
| **Qualité attendue** | Bonne à très bonne pour l'architecture (briques, ardoises, meulière, fenêtres, corniches sont des motifs répétitifs, parfaits pour la génération) et les objets simples ; **moyenne** pour les visages expressifs des portraits 48 × 48 (un développeur qui écrit une grille de pixels en texte n'atteindra pas la finesse de la référence de personnage sans beaucoup d'allers-retours sur captures). | Bonne pour ce qui existe ; mais **rien de français des années 80** n'existe : immeubles victoriens ou cyberpunk, voitures américaines, personnages de RPG fantastique. | IA : impressionnant au premier regard, mais **faux pixel art** (pixels de tailles inégales, 200 couleurs, bords flous) : il faut nettoyer chaque image. Graphiste : la meilleure qualité possible. |
| **Cohérence** | **Excellente** : une palette, une grille, des règles, un même code pour tout. | **Faible** : chaque pack a sa taille de pixel, sa palette, sa lumière ; mélanger 3 packs donne précisément un rendu « générique ». | IA : faible d'une image à l'autre (personnage qui change de visage) sans un gros travail de nettoyage. Graphiste : excellente. |
| **Coût** | Temps des développeurs (aucune dépense). | Gratuit à quelques dizaines d'euros. | IA : abonnement (≈ 10 à 30 € par mois selon l'outil) + temps de nettoyage. Graphiste pixel : ordre de grandeur **1 500 à 5 000 €** pour la démo (3 bâtiments, 8 personnages animés, portraits, objets), à confirmer par devis. |
| **Délais** | 1 lot pour la preuve de concept, 2 lots pour la rue complète (§6). | Immédiat, mais adaptation longue (re-palettisation, retouches, compléments). | IA : quelques jours, irréguliers. Graphiste : 3 à 8 semaines. |
| **Licences** | Aucun risque. | Le plus souvent « usage commercial permis, redistribution des fichiers interdite » ; certains packs exigent une autorisation ou interdisent l'usage commercial ; CraftPix interdit l'entraînement d'IA. À vérifier pack par pack. | IA : droits d'usage selon les conditions de l'outil ; protection par le droit d'auteur incertaine ; **ne jamais** nommer un artiste ni partir de l'image Dreamstime dans une requête. Graphiste : cession de droits écrite à prévoir (usage commercial, modifications, toutes plateformes). |
| **Animations et nouveaux éléments plus tard** | **Le point fort** : une nouvelle voiture de 1995 ou une trace de P10 = quelques lignes de données ; recolorations, variantes d'époque, nuit et orage automatiques. | Bloqué par le contenu du pack : pas de 4L, pas de Porsche 944, pas de kiosque 3615. | IA : animations quasi impossibles à garder cohérentes. Graphiste : possible, mais chaque ajout repasse par lui (dépendance). |

### 4.2 Packs repérés (vérifiés par recherche ; les pages itch.io n'ont pas pu être ouvertes directement : **relire la licence sur la page avant tout usage**)

| Pack | Contenu | Licence (selon la page ou l'auteur) | Adéquation à une rue française 1984 |
|---|---|---|---|
| JackBurton84, « 80s Pixel Cars Pack », https://jackburton84.itch.io/80s-pixel-cars-pack-retro-vehicle-sprites | 11 véhicules de profil, 64 × 32, palette années 80 | Gratuit, usage personnel et commercial ; redistribution, revente, NFT et jeux de données d'IA interdits | **Moyenne** : bonne taille et bonne vue, mais modèles non européens ; utile comme référence de proportions |
| Digital Realms, « 2D Pixel Cars », https://digital-realms.itch.io/pixel-realistic-cars | 9 voitures de profil | Prix libre ; crédit non exigé selon l'auteur (en commentaire), usage commercial compris | Moyenne : style plus réaliste que le nôtre |
| CraftPix, « Free Pixel Art Street Backgrounds », https://free-game-assets.itch.io/free-pixel-art-street-backgrounds (licence : https://craftpix.net/file-licenses/) | 4 fonds de rue 1920 × 1080 + calques | Licence gratuite CraftPix : usage commercial sans attribution, modifications permises, redistribution des fichiers et entraînement d'IA interdits | **Faible** : rues modernes génériques ; pixel plus fin que notre grille |
| arm_teatras, « City for 2D Side Scrollers », https://mantasarm.itch.io/cityscape2d | 4 bâtiments, trottoirs, réverbères, vue de côté | 1 € minimum ; licence non lue | Faible : bâtiments contemporains |
| dalliemoon, « Pixel Art Street Houses », https://dalliemoon.itch.io/street-houses | 4 maisons (plusieurs couleurs), PNG et Aseprite | Prix libre ; **autorisation de l'auteur exigée** pour un usage commercial | Faible : victorien (anglo-saxon) ; mais proche du charme de la référence |
| Hex Pixel, « pixelfolks NPCs », https://hex-pixel.itch.io/pixelfolks-npcs | PNJ chibi, repos et marche en 4 directions | Usage commercial et non commercial permis | Moyenne : chibi mignon, mais vêtements et vue de RPG (du dessus) ; le profil est réutilisable comme gabarit |
| Kenney, « UI Pack » et « Pixel UI pack (750 assets) », https://kenney-assets.itch.io/ui-pack et https://opengameart.org/content/pixel-ui-pack-750-assets | Cadres, boutons, 9-patch | **CC0** (domaine public) | Bonne comme **gabarit** de 9-patch, à redessiner dans notre palette |

Conclusion sur les packs : **aucun ne raconte une rue française de 1984** ; les mélanger reproduirait exactement le défaut que le joueur reproche (« générique »). Ils servent de **référence de proportions** et, au plus, de point de départ pour des cadres CC0.

### 4.3 Ce qu'il faudrait demander au joueur (voie c), s'il fournit des images

Cahier des charges à lui remettre (une page) :

1. **Format** : PNG à fond transparent, **1 pixel de l'image = 1 pixel d'art** (aucun agrandissement), ou agrandi d'un facteur entier annoncé (×4, ×8) ; pas de JPEG.
2. **Palette** : uniquement les 40 couleurs de §2.3 (fichier de palette `.gpl` et `.hex` fourni par l'équipe) ; sinon l'image sera re-palettisée automatiquement, avec perte.
3. **Tailles** : celles de §2.2 (figurine 16 × 28, portrait 48 × 48, maison 96 × 124…), avec l'**origine** (milieu des pieds, bas du bâtiment).
4. **Lumière** en haut à gauche ; contour encre `#1C1626` pour les personnages ; vue **de face orthogonale** pour les bâtiments, **de profil** pour les figurines, **de trois quarts** pour les portraits.
5. **Calques séparés** pour les bâtiments : façade / fenêtres allumées / enseigne / éléments variables (berceau, poussette, antenne Canal+…) ; **pas de texte** dans les images (enseignes et chiffres sont écrits par le jeu, en police pixel, pour les variantes d'époque).
6. **Feuilles d'animation** : une ligne par animation, cases de taille fixe côte à côte (ex. marche : 4 cases de 16 × 28 = 64 × 28), dans l'ordre de §2.5 ; un fichier par personnage (`gerard.png`, `sylvie.png`…) ; les portraits à part (3 expressions + yeux fermés + bouche ouverte).
7. **IA générative** : à utiliser surtout pour des **portraits** et des **vignettes de journal** (images fixes) ; la sortie doit ensuite être nettoyée (réduction au plus proche voisin sur la vraie grille, re-palettisation, retouche des contours). Ne jamais demander « dans le style de » un artiste nommé ni joindre l'image Dreamstime.
8. **Graphiste** : contrat avec cession des droits (commercial, modification, PC et mobile), fichiers sources Aseprite livrés.

### 4.4 Recommandation : voie mixte, le code d'abord

1. **Tout le jeu est d'abord produit en code (voie a)**, dans un **atelier pixel** commun :
   - `palette.gd` : les 40 couleurs et les tables nuit / orage ;
   - **sprites en grilles de texte** dans les données (`godot/data/pixel/*.txt`), une lettre par couleur, compilés au chargement en `ImageTexture` (3 variantes jour / nuit / orage, mises en cache) ; exemple :
     ```
     # gerard_repos_1   16x28   origine 8,27   palette : . transparent, e encre, c cheveux (caramel), p peau, o peau ombre, b blouson (bleu ardoise), n bleu nuit…
     ......eeeee.....
     ....eecccccee...
     ...ecccccccce...
     ```
   - **générateurs de matières** pour les façades (`facade.gd`) : brique, meulière, pierre de taille, ardoise, zinc, tuiles mécaniques, fenêtres à volets, corniches, auvents rayés, assemblés par modules de 8 px à partir d'une description en données (« 3 travées, 2 étages, toit mansardé, rez-de-chaussée commerce ») ; c'est ce qui donne la densité de la référence sans dessiner chaque pixel à la main ;
   - **contrôle de palette** : toute image PNG chargée (pack, IA, graphiste) est vérifiée ; une couleur hors palette est signalée dans les tests.
2. **Les packs (voie b)** : seulement comme références de proportions et, éventuellement, les cadres CC0 de Kenney comme gabarit, redessinés dans la palette.
3. **Le joueur (voie c), plus tard et en option** : là où le code est le plus faible et l'image la plus regardée : **les portraits 48 × 48** (M. Lefranc, Gérard, Sylvie × 3, les 3 voisins, Mme Lopez), les **vignettes du journal** et l'**illustration de l'écran titre**. Grâce à l'atelier, une image fournie remplace une grille sans toucher au code (même nom, même taille, même palette).

Où des illustrations apporteraient le plus (remplace 09 §6) : 1) portraits des personnages récurrents ; 2) vignettes de une du journal (krach, Lundi noir, « un an après ») ; 3) écran titre et écran de fin ; 4) les 3 bâtiments jouables, si le joueur veut aller au-delà du rendu en code.

---

## 5. Maquettes

Conventions : PC = 1 920 × 1 080 px virtuels, ville ×3 (640 × 360 px d'art) ; téléphone = zone virtuelle ≈ 1 410 × 635 (facteur 1,7), ville ×3 sur un écran 2400 × 1080 (800 × 360 px d'art). `▓` = cadre pixel, `░` = ciel en bandes.

### 5.1 La rue au calme (PC)

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ ╔═MAI═╗╔1987╗ BAGUETTE  [❚❚][ ▶ ][▶▶][▶▶▶][»✉]   COMPTE   │ PATRIMOINE        ╔VS TOUT AU LIVRET A╗ [≡] ▓ 96
▓ ╚═════╝╚════╝ 2,85 F                            8 875 F  │ 69 395 F  ▲ +26 % ║ ▲ +3 916 F        ║     ▓
├▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┬▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┤
│▓LA RUE▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ░░▒▒ nuages ▒▒░░            │▓ MON ARGENT                        ▓
│▓ 1 [J] Jean-Mi        81 200 F  ▲     ▓        ┌┴┐ antenne             │▓ = 24 332 baguettes                ▓
│▓ 2 [G] Vous           69 395 F        ▓   ┌────┴─────┐               │▓ courbe (lisse, or / bleu ciel)    ▓
│▓ 3 [T] Tata Livret    65 479 F        ▓   │▒ INDICE ▒│ journal       │▓                                   ▓
│▓ 4 [M] Tonton Matelas 58 900 F        ▓   │▒╱╲_╱‾╲_▒ │ lumineux      │▓ RÉPARTITION [▤▤▒▒▒▒░░███]        ▓
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ├──────────┤               │▓                                   ▓
│ ┌───────────────────────────────┐  toits │LA GAZETTE│ néon rose     │▓ CE MOIS-CI                        ▓
│ │▌ (notification, 3 au plus)    │  zinc  │▫ ▫ ▫ ▫ ▫ │    ┌──(◷)──┐  │▓ Salaire           + 8 152 F       ▓
│ └───────────────────────────────┘ lucar- │▫ ▫ ▫ ▫ ▫ │    │ BANQUE│  │▓ Dépenses          − 6 929 F       ▓
│     ┌▓▓▓▓▓▓┐ cheminée          nes      │▫ ▫ ▫ ▫ ▫ │  ┌─┴───────┴┐ │▓ ...                               ▓
│    ╱ tuiles ╲          ♣ platane        │rotatives │  │ ║  ║  ║  ║│ │▓ COUSSIN ▓▓▓▓▓▓▓░░  4,2 mois       ▓
│   │▫ [Sylvie]│ ┌kiosque┐                │[vitrine] │▯ │ ║ [▣] ║  ║│ │▓ FRAIS PAYÉS              423 F    ▓
│ ⌂ │meulière ▫│ │ 3615  │  ☺ ☺ passants  │  porte   │cab│ ║  ║  ║  ║│ │▓ ╔═════════════════════════════╗  ▓
│═╧═╧══[porte]═╧═╧═══════╧═══════════════╧══════════╧═══╧══════════╧═│▓ ║ BANQUE · carnet et guichet  ║  ▓
│   (R5 →)      ( MA MAISON )      ( LA GAZETTE )     ( MA BANQUE ) │▓ ╚═════════════════════════════╝  ▓
├▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┴▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┤
▓ [▤ HISTORIQUE ②]  1984 ┊ 1985 ┊ 1986 ┊ 1987 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[▦]┄┄┄┄ 1988 ┄┄┄┄┄┄┄┄┄ ⚑ ▓ 72
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

- Ce qui bouge sans action du joueur (critère 09 §5.2) : passants (marche 4 images), voitures, nuages par pas de 1 px, journal lumineux, néon, feuillage (2 images), horloge, fumée en hiver, curseur de la frise, compteurs.
- `[»✉]` : bouton « Jusqu'au prochain courrier » (docs/15 §1.2), proposé à droite des vitesses, même taille (80 px), icône 16 × 16 (double flèche + enveloppe) ; actif = fond ambre qui pulse. Sur téléphone : 3e bouton de 80 px à côté de lecture / pause et de la vitesse cyclique (pas d'appui long : rien de caché).
- Badge `②` sur HISTORIQUE : notifications franchies non lues (docs/15 §1.2).

### 5.2 Le classement permanent de la rue

**Décision du joueur** : le classement est affiché en permanence (docs/10, 2026-10-29).

**PC** : bloc « LA RUE » en haut à gauche, sous la barre haute (visible dans la maquette 5.1), au-dessus du ciel et des toits lointains, **jamais devant un bâtiment jouable** (la maison commence 100 px d'art plus bas).

```
▓LA RUE▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    largeur 380 px virtuels, hauteur 248
▓  1  [portrait 32×32 ×1,5]  Jean-Mi          81 200 F  ▲  ▓   ligne de 52 px (cible tactile 80 avec la marge :
▓  2  [Gérard, cadre ambre]  VOUS             69 395 F     ▓   le bloc entier est un seul bouton qui ouvre
▓  3  [Tata Livret]          Tata Livret      65 479 F     ▓   « Mon argent » à la section La rue)
▓  4  [Tonton Matelas]       Tonton Matelas   58 900 F     ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

- Rang en Pixelify 32 px ; nom en Atkinson 22 px ; patrimoine en Atkinson gras 22 px, aligné à droite, chiffres de même largeur ; négatif en perte avec le signe (Jean-Mi après le krach).
- **Ligne de Tata Livret soulignée** d'un trait pointillé ambre (c'est la référence, comme sur l'écran de fin).
- **Changement de rang** : les deux lignes échangent leur place en glissant (0,4 s, par pas de 3 px virtuels), le portrait qui monte fait un petit saut (2 images), flèche ▲ ou ▼ 6 s ; la notification « Jean-Mi passe devant vous dans la rue » arrive par la règle de docs/15 §4.2.
- Les notifications se placent **sous** ce bloc (3 au plus), toujours au-dessus de la maison.

**Téléphone** : ruban compact de 4 portraits classés de gauche à droite, sous la barre haute, à gauche.

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ ╔MAI╗╔1987╗ [❚❚][×1][»✉]          COMPTE  │ PATRIMOINE      ╔VS LIVRET A╗  [≡]         ▓ 96
▓ ╚═══╝╚════╝                       8 875 F │ 69 395 F ▲+26 % ║ ▲ +3 916 F║              ▓
├▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┬▓▓▓▓▓▓▓▓▓▓┤
│▓LA RUE▓[J]1▓[G]2▓[T]3▓[M]4▓  ← 4 portraits de 64 px, rang dans le coin,     │▓ MON     ▓
│ ┌───────────────────────┐      « VOUS » cadré d'ambre ; toucher = détail    │▓ ARGENT  ▓
│ │▌ notification (2 max) │                  ┌──────────┐                     │▓ 69 k F  ▓ languette
│ └───────────────────────┘                  │▒ INDICE ▒│                     │▓ ╲_╱‾    ▓
│     ┌▓▓▓▓┐                                 │LA GAZETTE│    ┌──(◷)──┐        │▓         ▓
│    ╱tuiles╲  ┌kiosque┐                     │▫ ▫ ▫ ▫ ▫ │    │ BANQUE│        │▓         ▓
│   │[Sylvie]│ │ 3615  │    ☺  ☺             │rotatives │ ▯  │ ║ ▣ ║ │        │▓    ◀    ▓
│═══╧═[porte]╧═╧═══════╧═════════════════════╧══════════╧═══╧═══════╧═══════ │▓         ▓
│     ( MA MAISON )            ( LA GAZETTE )         ( MA BANQUE )           │▓         ▓
├▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┴▓▓▓▓▓▓▓▓▓▓┤
▓ [▤ ②] 1984 ┊ 1985 ┊ 1986 ┊ 1987 ━━━━━━━━━━━━━━━━[▦]┄┄┄ 1988 ┄┄┄┄┄┄ ⚑                    ▓ 72
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

- Ruban : 4 cases de 64 × 64 px virtuels (portrait 32 × 32 ×2) + 8 d'écart = 300 × 72 ; le rang est un chiffre Pixelify de 24 px dans le coin bas droit de chaque case ; « VOUS » a un cadre ambre ; un toucher ouvre « Mon argent » sur la section La rue (avec les montants). Les montants ne sont pas dans le ruban (place) : l'ordre suffit à lire « qui est devant ».
- Accessibilité : l'ordre se lit aussi sans couleur (position + chiffre) ; le cadre de « VOUS » a 2 texels d'épaisseur (pas seulement une teinte).

### 5.3 Une carte du banquier (exemple : l'héritage de tante Odette, avril 1988)

**PC** (1 120 × 560 px virtuels, centrée, fond assombri à 60 %, la ville **figée** et teintée gel) :

```
                     ┌──┐ coin corné
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓█  BANQUE DE LA RUE · 12, rue des Épargnants        ─ en-tête Pixelify 28, encre, filet or  ▓
▓█ ─────────────────────────────────────────────────────────────────────────────── [ X ]  ▓
▓█ ┌────────────┐  M. LEFRANC · votre banquier                    ╔TANTE ODETTE╗          ▓
▓█ │ portrait   │  avril 1988 · UNE NOUVELLE                       (tampon violet pixel,    ▓
▓█ │ 48×48 ×3   │                                                   légèrement tourné)      ▓
▓█ │ (parle,    │                                                                          ▓
▓█ │  cligne)   │                                                                          ▓
▓█ └────────────┘                                                                          ▓
▓█ « Gérard, toutes mes condoléances pour     │ AVEC VOTRE ARGENT                           ▓
▓█ votre tante Odette. Elle vous avait        │ ┌ ticket pixel (bord dentelé) ───────────┐  ▓
▓█ désigné sur son assurance-vie : 60 000 F,  │ │ REÇU PAR ASSURANCE-VIE                  │  ▓
▓█ versés ce mois-ci, sans droits. Par sa     │ │ + 60 000 F   (gain sur papier, 40 px)  │  ▓
▓█ succession, l'État aurait pris 27 500 F…»  │ │ SI ÇA AVAIT ÉTÉ PAR SUCCESSION          │  ▓
▓█ (Atkinson 24 px, encre sur crème)          │ │ ─32 500 F nets─ (barré, gris pierre)   │  ▓
▓█                                            │ └─────────────────────────────────────────┘  ▓
▓█ ╔══════════════╗                                                                         ▓
▓█ ║   COMPRIS    ║  (bouton principal ambre, relief 2 texels)                              ▓
▓█ ╚══════════════╝                                                                         ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
 █ = liseré or de 2 texels à gauche (source : banque)
```

- **Entrée** : à la banque, le combiné vibre (3 images) et 3 anneaux pixel s'élargissent ; la **tuile** de la carte sort de la porte de la banque (porte qui s'ouvre, 3 images), grandit et se pose (≤ 1 s, passable d'un toucher). **Sortie** : elle retourne dans la banque.
- **Portrait** : M. Lefranc, 48 × 48, trois quarts, lunettes, moustache grise, cravate bordeaux ; 3 expressions (affable, grave pour un décès ou le krach, satisfait pour un relevé) ; bouche animée pendant que le texte s'écrit (texte complet au premier toucher).
- Carte de présentation de produit (13 §1) : même papier ; le **comparatif** à 5 lignes utilise des pastilles pixel + mot + « plus / moins / pareil » ; ticket chiffré en ticket dentelé.

**Téléphone** (≤ 1 300 × 590 px virtuels, deux colonnes conservées, sans défilement) : portrait réduit à 48 × 48 ×2 (96 px), à gauche du titre ; tampon « TANTE ODETTE » sous le titre ; colonne texte 56 % / ticket 44 % ; bouton « COMPRIS » de 80 px de haut en bas à gauche ; la croix de fermeture en 80 × 80.

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓█ [portrait 96] M. LEFRANC · avril 1988   ╔TANTE ODETTE╗              [ X ] ▓
▓█ ─────────────────────────────────────────────────────────────────────────── ▓
▓█ « Gérard, toutes mes condoléances…    │ ┌ REÇU PAR ASSURANCE-VIE ──────────┐ ▓
▓█ (texte 24 px, 7 lignes au plus)        │ │ + 60 000 F                       │ ▓
▓█                                        │ │ PAR SUCCESSION : ─32 500 F─       │ ▓
▓█ ╔═══════════╗                          │ └──────────────────────────────────┘ ▓
▓█ ║  COMPRIS  ║                                                                 ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

### 5.4 Le journal du krach (octobre 1987), après la séquence du Lundi noir

**La séquence du Lundi noir en pixel** (docs/15 §5.1, ≤ 15 s, passable d'un toucher) : la palette **orage** se fond en 1 s ; pluie en traits de 1 × 4 px ; le journal lumineux du toit affiche les jours en chiffres **perte** (« VEN 16 », « LUN 19 »…) avec la courbe qui plonge par pas de pixel ; une file de 6 à 8 figurines se forme devant la banque (elles arrivent en marchant, puis restent en repos 2 images) ; « DRING » en lettres pixel qui sautent sur la maison, bulle de Sylvie ; Jean-Mi traverse en courant (marche à 12 im/s, bras levés) ; M. Lefranc sur le pas de sa porte (repos, portrait grave). Puis la Gazette « tremble » (secousse de 2 px d'art) et les journaux en jaillissent (sprites de journal pliés 12 × 8 qui tournoient en 4 images) avant la modale.

**PC** (1 200 × 760 px virtuels, rotation −1,5° conservée seulement **pendant l'arrivée** : au repos, la page est droite pour garder les pixels nets) :

```
┌~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~┐ bord déchiré
│ N° 12 482                         L A   G A Z E T T E                        3,50 F     │ Pixelify 700, 56 px
│ mardi 20 octobre 1987 ══════════════════════════════════════════════════════════════  │ double filet
│                                                                                        │
│                 LUNDI NOIR : LA BOURSE DE PARIS DÉVISSE                                │ manchette 64 px,
│                                                                                        │ encre (« DÉVISSE »
│ ┌──────────────────────── vignette 200 × 72 texels ×3, 2 tons tramés ───────────────┐ │  en perte sur papier)
│ │ la corbeille du palais Brongniart : silhouettes d'agents de change, bras levés,    │ │
│ │ tableau des cours, tout en encre sur papier (trame de Bayer)                       │ │
│ └────────────────────────────────────────────────────────────────────────────────────┘ │
│ Wall Street perd plus de 20 % en une seule séance.     │ ┌ VOTRE ARGENT ─────────────┐ │
│ Paris suit. À la radio, on parle de 1929.              │ │ ▼ − 4 284 F en Bourse      │ │
│ (chapô Atkinson 26 px, 40 mots au plus)                │ │ Face au Livret A : ▼ …     │ │
│                                                        │ └────────────────────────────┘ │
│ ╔═════════════════╗  ╔═════════════════╗  ╔═════════════════╗                           │
│ ║  TOUT VENDRE    ║  ║  NE RIEN FAIRE  ║  ║    RENFORCER    ║   même style, même taille │
│ ╚═════════════════╝  ╚═════════════════╝  ╚═════════════════╝   (80 px de haut)         │
└~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~┘
```

**Téléphone** (1 100 × 590 px virtuels au plus, 09 §4.3) : en-tête « LA GAZETTE » sur une ligne de 40 px avec la date ; manchette sur 2 lignes de 48 px ; **vignette réduite à 200 × 40 texels ×2** (bande panoramique) ; chapô 3 lignes ; bloc « Votre argent » à droite du chapô ; 3 boutons côte à côte de 80 px de haut.

- **Une seule illustration par grand événement** : la vignette est l'endroit où une image fournie (voie c) aurait le plus d'effet ; en attendant, elle est composée en code à partir des figurines (silhouettes encre sur papier tramé).

---

## 6. Plan de migration

### 6.1 Preuve de concept (avant toute migration)

**But** : que le joueur dise « oui, c'est ce style-là » sur une image réelle du jeu, pas sur un document. **Une scène à part** (`godot/scenes/poc_pixel.tscn`), qui ne touche à aucun fichier existant : elle peut avancer pendant les lots en cours sans conflit.

| # | Contenu | Détail |
|---|---|---|
| 1 | Atelier pixel minimal | `palette.gd` (40 couleurs + nuit), compilation de grilles de texte en textures, `SubViewport` à facteur entier (§2.1) avec la caméra arrondie |
| 2 | **La maison de Gérard** | Meulière générée, tuiles, cheminée et fumée, volets, marquise, boîte aux lettres, jardinet, fenêtres qui s'allument la nuit ; **Sylvie à la fenêtre** avec ses 3 humeurs (touche pour changer) |
| 3 | **Gérard** | Figurine 16 × 28 : marche 4 images (va et vient devant la maison), repos 2 ; et son **portrait 48 × 48** (2 expressions) |
| 4 | Un bout de rue | Trottoir, chaussée, un réverbère, un platane (automne), un pan d'immeuble haussmannien de fond, ciel en bandes avec 2 nuages ; une **Renault 5** qui passe |
| 5 | Jour → nuit | Fondu vers la palette nuit en 3 s (touche), lumières additives |
| 6 | **Le HUD** | La barre haute restylée (panneau 9-patch, date à volets, boutons du temps, compte, patrimoine, pastille vs Livret A) avec **Pixelify Sans** et **Atkinson Hyperlegible Next** (et Jersey 10 pour la date et le patrimoine en variante) |
| 7 | Une carte | La carte du banquier de l'héritage (§5.3), papier, portrait de M. Lefranc |
| 8 | Captures | PC 1920 × 1080, mode F10 (téléphone 20:9), 1366 × 768 : jour, nuit, carte ouverte, HUD ; plus un **montage côte à côte** avec la capture actuelle `v3_rue.png` |

Qui : **dev-ville** (1 à 5), **dev-interface** (6, 7), sur des fichiers neufs ; 1 lot. Prérequis : télécharger les polices OFL de §3.2 (Pixelify Sans, Atkinson Hyperlegible Next, Doto ou VT323, et Jersey 10 pour l'essai) depuis Google Fonts dans `godot/polices/`, avec leur fichier de licence.
Critères pour la juger : (1) on reconnaît une rue **française** de 1984 sans légende ; (2) aucun pixel flou ni irrégulier dans la ville, à ×2, ×3 et ×4 ; (3) les chiffres du HUD aussi lisibles qu'aujourd'hui en F10 ; (4) le visage de Sylvie lisible à la fenêtre à ×3 (sinon : la bulle suffit et on agrandit la fenêtre) ; (5) 60 images par seconde.

### 6.2 Ce qui change dans le code (après validation)

| Zone | Fichiers actuels | Changement | Garde-fou |
|---|---|---|---|
| Atelier pixel | (nouveaux) `scripts/pixel/palette.gd`, `grille.gd`, `facade.gd`, `data/pixel/*.txt` | Créés à la preuve de concept, complétés ensuite | Test : toute texture n'utilise que la palette ; chaque grille a la taille annoncée |
| Cadre de la ville | `ville.gd` (cadrage, caméra, calques, particules, toucher) | Rendu dans un `SubViewport`, facteur N entier, caméra arrondie, conversions écran ↔ ville | **API conservée** : `cadrer()`, `viser()`, `revenir()`, `plonger_vers_maison()`, `position_ecran()`, `ecran_batiment()`, `batiment()` |
| Bâtiments | `batiment.gd`, `maison.gd`, `banque.gd`, `media.gd` | Le dessin `_draw()` en polygones est remplacé par des sprites et des façades générées ; la Gazette devient un immeuble de presse en pierre ; mêmes points d'ancrage (`position_antenne()`, fenêtre de Gérard, combiné) | Même interface (`contient()`, `survoler()`, `enfoncer()`, `dessiner_lumieres()`) |
| Décor | `rue.gd`, `plan_fond.gd`, `reverbere.gd`, `accessoire.gd` | Sprites et modules ; immeubles haussmanniens, café-tabac, kiosque, cabine, plaque de rue | Variantes d'époque par table (09 §2.5) |
| Vie | `passant.gd`, `voiture.gd` | Figurines animées (4 + 2 images), voitures d'époque | Vitesses et règles de trafic inchangées |
| Ciel | `shaders/ciel.gdshader` | Bandes + trame de Bayer au pixel d'art ; uniformes `krach` et `gel` conservés | — |
| Thème | `scripts/ui/style.gd` (couleurs, `SystemFont`, `StyleBoxFlat`) | Polices embarquées (`FontFile`), `StyleBoxTexture` 9-patch, nouvelles couleurs de §2.3 ; **mêmes noms de fonctions** (`panneau()`, `carte()`, `bouton_principal()`, `chiffres()`, `ui()`…) | Le reste de l'interface suit sans modification ligne à ligne |
| Sprites d'interface | `ui/portrait.gd`, `ui/piece.gd`, icônes de `outils/generer_icones.gd` | Portraits et pièces en sprites pixel | — |
| Écrans | `modales.gd`, `hud.gd`, `panneau_banque.gd`, `principal.gd` | Re-thème automatique par `style.gd` ; retouches ciblées : papier pour les cartes, classeur pour l'historique, journal | Pas de refonte de la logique d'écran |
| Peut rester provisoirement | `courbe.gd`, `repartition.gd`, `barres.gd`, `piles.gd`, `frise.gd`, `date_volets.gd` | Lisses, dans les nouvelles couleurs ; motifs pixel de la répartition et calendrier pixel de la date plus tard | — |
| Captures | `outils/capture.gd` | Nouvelle série `px_*` | Montage avant / après |

### 6.3 Ordre et impact sur la feuille de route (`docs/lots/feuille_de_route.md`)

| Étape | Contenu | Qui | Effet sur les lots |
|---|---|---|---|
| **PX0** | Preuve de concept (§6.1) | dev-ville + dev-interface, fichiers neufs | **En parallèle** du lot 01 ou 02 : aucun conflit de fichiers. Sortie joueur : captures (et, si possible, un exécutable de la scène). |
| (décision du joueur) | Oui / ajustements / non | joueur | Si non : on garde la ville vectorielle et on ne perd qu'un lot d'interface. |
| **PX1** | La rue en pixel : atelier complet, `SubViewport`, 3 bâtiments, décor, trafic, saisons, nuit, pluie, neige, écran titre | **dev-ville** (fichiers `ville/*`, shader du ciel) | Remplace la partie « dev-ville » du lot 02 (pièces du mois dessinées directement en pixel). |
| **PX2** | L'interface habillée : `style.gd`, polices, 9-patch, portraits, pièces, cartes papier, journal, classeur | **dev-interface** (fichiers `ui/*`, `modales.gd`) | **En parallèle de PX1** (fichiers disjoints) ; à placer **avant** les cartes de dilemme et de projet (lots 03-04), pour ne pas dessiner deux fois. |
| Lots 02 à 07 | Inchangés **côté logique** (dev-logique continue sans attendre) | dev-logique | Aucun retard. |
| Lots 03 à 06, partie visuelle | Sylvie à la fenêtre, traces P10, voisins, Mme Lopez, Porsche, kiosque, Lundi noir, classement, écran de fin : **dessinés directement en pixel** | dev-ville, dev-interface | Commencent après PX1 / PX2 ; **gain** : aucun de ces éléments n'est d'abord fait en vectoriel puis refait. |

Bilan : environ **2 lots de plus côté ville et interface** (PX0, puis PX1 et PX2 en parallèle), **zéro côté logique**. La règle utile pour le chef de projet : **ne plus commander aucun nouveau dessin vectoriel** à partir de maintenant, même provisoire, sauf s'il tient en quelques lignes.

---

## 7. Questions au joueur (3)

1. **Provenance des images** : je propose que l'équipe dessine tout le jeu en pixel art dans le code (une palette, des règles communes : cohérent, gratuit, facile à faire évoluer), et que vous fournissiez **plus tard, si vous le souhaitez**, les portraits des personnages et les illustrations du journal (par une IA d'images ou un graphiste), selon un cahier des charges précis (§4.3). Êtes-vous d'accord ? Avez-vous déjà un outil d'IA d'images, ou un budget pour un graphiste, en tête ?
2. **L'interface** : on habille aussi l'interface en pixel (cadres, titres en police pixel, cartes en papier, historique en classeur) en gardant les **chiffres et les textes longs dans une police nette**, ou préférez-vous que seule la ville passe en pixel et que l'interface reste comme aujourd'hui ?
3. **La taille des personnages** : dans la rue, les personnages sont petits (comme dans votre image de rue : on voit toute la rue, les visages se découvrent dans les cartes et les bulles en grand portrait, comme votre image de personnage), ou voulez-vous des personnages **plus grands dans la rue elle-même** (on voit alors moins de la rue, et la caméra suit l'action) ?

---

## 8. Révision 2026-10-29 : référence `rue_pixel_v2`

> Auteur : chef de projet, d'après le retour du joueur sur PX0 (docs/10 : « Plutôt ça comme style graphique » + « Personnages un peu plus grands cette fois-ci »). **Prime sur §1.1, §2.2, §2.3 (ajouts seulement), §2.6 et l'automne de référence pour la rue.** L'interface (§3), les règles techniques (§2.1, §2.4, §2.5) et la provenance (§4) restent valables. Plan : `docs/lots/lot_px0_bis.md`. À relire par le designer UX avant PX1.

### 8.1 Nouvelle référence de rue
`docs/sources/graphisme/references/rue_pixel_v2.jpg` (non versionnée ; ne jamais la décalquer ni l'intégrer). Ce qu'on en garde : **plein jour d'été**, ciel bleu saturé à **gros nuages blancs** en volumes ; rue de **briques rouge-orangé** très détaillée (joints, toits d'ardoise sombre ou de tuiles rouges, fenêtres à encadrement, portes colorées, boutique à enseigne et **auvent rouge**, boîtes aux lettres, bouches d'incendie) ; **murets de briques à chaperon** ; **grands arbres feuillus vert vif** à gros volumes, derrière et entre les bâtiments, **un tronc au premier plan** sur un bord ; **lampadaire noir à cloche** ; **skyline lointaine bleutée** (silhouettes, grues, pylônes) pour la profondeur ; trottoir en dalles, bordure, chaussée grise à marquages et **passage piéton** ; voitures rouge et grise ; contours sombres jamais noirs, ombres portées douces **en aplat**. Ambiance lumineuse, saturée, chaleureuse. Elle **remplace** `rueStyle.jpg` (automne, crépuscule) comme image de référence ; l'automne redevient une simple saison.

Ce qui reste français (à garder malgré la référence anglo-saxonne) : boîte aux lettres **jaune** La Poste (pas bleue), plaque de rue bleue émaillée, poteau d'incendie rouge (français aussi), voitures françaises (R5, 205, 4L), enseignes en français. La brique situe la rue dans le **Nord ou la banlieue parisienne** des années 1980 (la meulière disparaît de la maison de Gérard).

Jour = référence ; **nuit et orage** = la même scène par tables de substitution (§2.3), sans élément ajouté hors lumières.

### 8.2 Palette étendue : « Rue 84 » 59 couleurs
Les 40 couleurs de §2.3 sont **inchangées** (valeurs et ordre : l'interface s'en sert). 19 couleurs sont **ajoutées à la suite** (n° 41 à 59), pour le monde seulement ; aucune n'est émissive.

| # | Nom | Jour | Nuit | Orage | Usage |
|---|---|---|---|---|---|
| 41 | ciel_haut | `#3C8AD6` | `#1A2C58` | `#4A5266` | haut du ciel de jour (saturé) |
| 42 | ciel_vif | `#5DAAE8` | `#203A66` | `#565C70` | milieu du ciel |
| 43 | nuage | `#F7FBFF` | `#7C80A2` | `#B4B0B8` | nuage éclairé |
| 44 | nuage_ombre | `#CFE2F2` | `#5A6488` | `#9894A0` | volume des nuages |
| 45 | nuage_creux | `#A3C3E0` | `#44507A` | `#7E7C8C` | dessous des nuages |
| 46 | lointain_clair | `#B4CCE0` | `#3E4870` | `#8A8696` | skyline, plan le plus lointain |
| 47 | lointain | `#8DA9C8` | `#323C64` | `#706E80` | skyline, grues, pylônes |
| 48 | lointain_sombre | `#6A86A8` | `#283258` | `#5E5C6E` | skyline la plus proche |
| 49 | brique_vive | `#C4573A` | `#563048` | `#8E4636` | brique rouge-orangé (ton moyen) |
| 50 | brique_claire | `#DE7A4E` | `#66424C` | `#A6644A` | brique éclairée, arêtes |
| 51 | feuille_sombre | `#23542A` | `#142236` | `#22342A` | creux du feuillage |
| 52 | feuille | `#3E8C34` | `#1E3444` | `#3A5634` | feuillage (ton moyen) |
| 53 | feuille_vive | `#6DBB3C` | `#2C4450` | `#5A7A40` | feuillage éclairé |
| 54 | feuille_eclat | `#A9DC54` | `#3C5258` | `#7A9450` | reflets des grappes |
| 55 | goudron | `#5E626C` | `#2A2C46` | `#4C4A54` | chaussée |
| 56 | goudron_clair | `#7C808A` | `#383C5A` | `#64626C` | chaussée usée, bordure |
| 57 | sarcelle | `#2F7C80` | `#18344A` | `#36545A` | portes, volets, auvents secondaires |
| 58 | dalle | `#BDB7AD` | `#50547A` | `#8C8482` | trottoir en dalles |
| 59 | dalle_ombre | `#9E978C` | `#44466A` | `#76706E` | joints des dalles, ombres au sol |

- Rampes : **ciel** 41 → 42 → 20 → 21 (bandes tramées Bayer, claires) ; **nuages** 43 / 44 / 45 ; **lointain** 46 / 47 / 48 ; **brique** 50 / 49 / 13 / 12 (joints : 12, ou 11 pour un mortier clair) ; **feuillage d'été** 54 / 53 / 52 / 51 ; **sol** 58 / 59 (trottoir), 56 / 55 (chaussée), marquages 8 ; toits d'ardoise 4 / 3 / 2, tuiles 15 / 14 / 13 ; lampadaire encre (1) + nuit (2), jamais de noir pur.
- Saisons (§2.3) : l'**été** devient la référence (54 / 53 / 52 / 51) ; printemps 24 / 23 / 22 ; automne 34 / 25 / 26 ; hiver inchangé.
- Ombres portées **en aplat** du ton sombre de la surface touchée (arbre sur brique → 12 ; voiture sur chaussée → 2 ; personnage sur trottoir → 59) ; jamais d'alpha dans les images.

### 8.3 Nouvelle échelle (remplace §2.2 pour la rue)
Le joueur demande des **personnages plus grands** : la figurine passe à **24 × 42** px d'art (× 1,5), soit 126 px à l'écran en 1080p (84 en PX0). « 1 mètre » ≈ 24 px. La grille reste 640 × 360 (§2.1) et la vue garde les bandes du HUD (32 et 24 px d'art).

| Élément | PX0 | Révision |
|---|---|---|
| Figurine adulte | 16 × 28 | **24 × 42** (2,5 têtes ; tête ≈ 16 × 15 : œil 2 × 2 avec pupille, sourcil 3 px, bouche 3-4 px, nez, oreille ; mains et chaussures) |
| Enfant / poussette | 10 × 16 / 18 × 14 | 15 × 24 / 27 × 21 |
| Sylvie à la fenêtre | buste 12 × 14 dans 18 × 22 | buste **18 × 21** dans **26 × 32** (humeurs lisibles sans bulle) |
| Portraits de bulle / de carte | 32 / 48 | inchangés |
| Porte | — | 22 × 44 (+ imposte) |
| Fenêtre | 12 × 20 | 24 × 32 (encadrement 2 px, appui 2 px) |
| Étage | 34 | ≈ 50 |
| Maison de Gérard | 96 × 124 | ≈ **152 × 172** (cheminée comprise), 2 niveaux + toit |
| Bâtiments de la rue | 64-112 × 140-200 | 96-180 × 140-240 |
| Banque / Gazette | 128 × 150 / 112 × 216 | à redimensionner en PX1 (≈ 180 × 200 / 150 × 260), selon la décision sur la largeur de rue |
| Lampadaire / arbre | 8 × 56 / 40 × 64 | 10 × 84 / ≈ 70 × 110 (arbre de premier plan : plus grand, coupé par le bord) |
| Voitures (R5, 205, 4L) | 48 × 20 | ≈ 72 × 30 (roues 12 px) |
| Trottoir / chaussée | 8 / 16 | 12 + bordure 2 / 22 (sol à y = 296 en vue 360) |

**Conséquence** : la zone utile de §2.6 (448 × 232, maison + Gazette + banque visibles ensemble) ne tient plus. Choix à faire par le joueur avant PX1 : rue plus large que l'écran avec caméra qui glisse vers le bâtiment qui parle, ou bâtiments jouables plus étroits.

### 8.4 Banque et Gazette dans la rue de briques (PX1)
- **Banque** : brique 50 / 49 avec encadrements, bandeau et petit fronton en pierre claire (11), horloge dans le fronton, porte en bois à deux battants, enseigne « BANQUE » dorée (34), distributeur à partir de 1986.
- **Gazette** : brique sombre (13 / 12), la plus haute ; enseigne peinte « LA GAZETTE » au 1er étage, vitrine des rotatives, **journal lumineux** sur le toit (ambre) et néon rose.
- **Maison de Gérard** : la plus chaude (tuiles rouges, porte sarcelle ou bleu vif, jardinière), signature : fenêtre de Sylvie et boîte aux lettres jaune.

### 8.5 Interface
Rien ne change dans §3 tant que le joueur n'a pas vu la rue claire sous le HUD. Points à juger sur la preuve PX0 bis : panneaux `nuit` foncés au-dessus d'un ciel clair (garder, teinter vers `bleu_nuit` ou passer la barre haute en papier crème) ; contraste de l'étiquette « MA MAISON » sur le goudron ; ombre portée des panneaux (encre α 0,5 → `bleu_nuit` α 0,35). Aucune de ces options ne demande de couleur en plus.
