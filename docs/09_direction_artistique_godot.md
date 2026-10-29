# 09 : Direction artistique, ville et « game feel » (version Godot, PC et mobile en paysage)

> Rédigé par le UX designer le 2026-10-26, à partir du retour du joueur réel (« une ville en fond, la maison de mon personnage, une banque d'où le banquier m'appelle, un bâtiment média animé à chaque news ») et des arbitrages du client A31 à A35 (`docs/connaissances/client.md`).
> Ce document **remplace 04 §6 et §7** (animations et direction artistique) ainsi que la disposition de l'écran principal (04 §3.3) pour la version Godot. **La logique des écrans de 04 reste valable** : parcours (04 §2), contenu du marché (04 §3.4), grammaire du journal (04 §3.5), courrier et notifications (04 §3.6), règles de la frise (04 §4), onboarding (04 §5), séquence du bilan (04 §3.11), accessibilité (04 §7.5) et graphiques pour débutants (04 §7.6). En cas de contradiction : 03 puis les arbitrages du client priment, puis ce document pour tout ce qui est visuel.
> Contraintes : Godot 4 (GDScript), **aucune ressource externe** (formes `Polygon2D` / `_draw()`, StyleBox, dégradés, shaders, particules, Tween, polices système). Les chiffres des maquettes sont illustratifs.

---

## 1. Diagnostic : pourquoi la V1 web fait « site web »

1. **Pas de lieu.** Le joueur regarde des colonnes de chiffres, pas un monde. Rien ne dit *d'où* vient un événement : un krach et une panne de voiture arrivent par le même genre de boîte.
2. **Aucune matière ni lumière.** Fond crème uni, cartes blanches à filet de 1 px, Segoe UI : l'esthétique d'un formulaire. Pas de profondeur, pas de grain, pas de source de lumière.
3. **L'argent est du texte dans des tableaux.** Aucun objet ne l'incarne (pièce, jauge, écran lumineux), et la hiérarchie typographique est écrasée (tout entre 14 et 28 px).
4. **Le monde ne vit pas.** Quand le temps tourne, seul le curseur glisse. Les feedbacks sont des flashs de 600 ms, sans anticipation, rebond, particules ni son : il n'y a pas de « juice ».
5. **L'époque n'est qu'une couleur d'accent.** Rien ne montre qu'on est en 1987 : ni les voitures, ni les enseignes, ni la lumière.

---

## 2. Direction artistique

### 2.1 Intention

**« Ma rue, de 1978 à aujourd'hui. »** L'écran principal est une **rue de ville française en diorama**, vue de face, vivante (passants, voitures, saisons, jour et nuit). Trois bâtiments y parlent au joueur, **un lieu par type de message** :

| Bâtiment | Ce qui en sort | Ce qu'il ouvre au toucher |
|---|---|---|
| **La maison** du personnage | Événements de vie (courrier, panne, naissance, chômage) | « Mon foyer » : budget du mois, coussin de sécurité |
| **La banque** | Le **banquier qui appelle** : nouveaux produits, privatisations, taux du Livret A, fiscalité, bilan annuel, rappel à 12 mois. **Jamais de conseil d'achat ni d'annonce de krach** (A33). Il verse aussi le salaire sur le compte. | La fenêtre Banque : carnet du banquier et guichet (13 §2) |
| **Le média** (« La Gazette », tour avec antenne, enseigne et écran lumineux sur le toit) | **Toutes les news** : événements de marché (journal en modale) et notifications de contexte | « Les nouvelles » : historique des news |

Par-dessus la ville, un **HUD sombre et lumineux** (date, temps, argent, frise, panneau « Mon argent ») ; au premier plan, les **papiers** (journal, courrier, carte d'appel) qui tombent devant la scène.

Trois matières, trois sens :
- **la ville** (aplats colorés, lumière du jour) = le monde qui vit ;
- **la lumière** (HUD, néon, écran du toit) = ce qui se compte : cours, patrimoine, temps ;
- **le papier** (journal, courrier) = ce qui arrive et demande une décision.

### 2.2 Style de la ville (point ouvert O9 : 3 propositions, une recommandée)

| | **A. Diorama de face en aplats (recommandé)** | B. Isométrique façon Les Sims / Pocket City | C. Silhouettes en contre-jour néon |
|---|---|---|---|
| Rendu | Rue vue de face, 4 plans de parallaxe, façades en aplats à 2 tons, fenêtres qui s'allument | Îlot en 3/4, toits et façades visibles | Bâtiments noirs découpés sur un ciel en dégradé, seules les lumières sont colorées |
| Coût dans Godot | Faible : rectangles et polygones, profondeur par parallaxe | Élevé (×3) : chaque bâtiment demande 3 faces, l'ordre de tri est délicat | Très faible |
| Lisibilité sur téléphone | Excellente : formes larges, étiquettes horizontales | Moyenne : petits détails | Bonne la nuit, pauvre en époque et en vie |
| Évolution par époque | Facile (voitures, enseignes, skyline) | Coûteuse | Limitée |

**Règles du style A** :
- **Formes** : rectangles, trapèzes et cercles ; coins légèrement arrondis (4 à 8 px) sur les toits et les auvents ; proportions « jouet » (bâtiments trapus, toits épais, portes larges).
- **Pas de contour noir.** Chaque volume a **2 tons** : face éclairée, et côté ou dessous 20 % plus sombre ; plus une ombre portée au sol (polygone noir α 0,25).
- **Perspective atmosphérique** : plus un plan est loin, plus il est désaturé et proche de la couleur du ciel (mélange de 30 % pour le plan moyen lointain, 60 % pour l'horizon).
- **Détail réservé aux 3 bâtiments jouables** ; le décor reste en aplats simples.
- **Lumières** : fenêtres (rectangles arrondis `#FFD27A`), réverbères (halo radial), enseignes (néon) sont dessinées sur un calque séparé, **non assombri la nuit** et en mélange additif.
- **Personnages et voitures** : passants en « gélule » (corps arrondi et tête ronde, 2 couleurs, rebond de marche par sinus) ; voitures en profil simple (caisse, vitres, 2 roues qui tournent).

**Références** : *Alto's Adventure* (ciel en dégradé, parallaxe, lumière qui change), *Mini Motorways* (voitures en pastilles, aplats lisibles), *Tiny Tower* et *Fallout Shelter* (bâtiments vus de face, lisibles d'un coup d'œil), illustrations *Kurzgesagt* (aplats et lueurs), *Papers, Please* (papiers posés devant la scène, tampon), *Balatro* (juice des chiffres), *Reigns* (cartes de décision lisibles).

### 2.3 Composition de la rue (monde de 2 560 × 1 080 unités)

```
 PLANS (du fond vers l'avant)                      vitesse de parallaxe
 0 Ciel (shader : dégradé, soleil ou lune, étoiles, nuages en polygones)      0
 1 Horizon : silhouette de Paris (tour Eiffel, tour Montparnasse, toits)     0,15
 2 Plan moyen lointain : immeubles haussmanniens en aplats, palais Brongniart 0,4
 3 RUE : maison · média · banque (jouables), kiosque, cabine, café, arbres     1
 4 Premier plan : trottoir, réverbères, voitures, passants                    1,15

   ┌─────────────────────────────────────── zone utile 1 400 × 700 ───────────────────────────────────────┐
   │                                   ┌────────┐ ← enseigne LA GAZETTE (néon)                         │
   │                                   │ ▓▓▓▓▓▓ │ ← écran du toit : courbe de l'indice + bandeau LED   │
   │                                   │ ▓▓▓▓▓▓ │                                                       │
   │      /\       antenne ─►   ╪      ├────────┤                     ┌─────────────────┐              │
   │     /  \                          │ □ □ □ □│                     │═════════════════│ fronton      │
   │    /____\  toit                   │ □ ■ □ □│   (fenêtres qui     │  B A N Q U E    │              │
   │    │ ■ □│                         │ □ □ □ ■│    s'allument)      │ ║  ║  ║  ║  ║  │ colonnes     │
   │    │ □ ▣│ ← fenêtre de Gérard     │ □ □ ■ □│                     │ ║  ║ ▣║  ║  ║  │ ← fenêtre    │
   │  ▯ │ ┌┐ │ ← boîte aux lettres     │ ┌────┐ │   kiosque  cabine   │ ║  ║  ║  ║  ║  │   du banquier│
   │ ═══╧═╧╧═╧═══ (voiture) ═══════════╧═╧════╧═╧════════════════════════╧═════════════════╧════════════  │
   │   MA MAISON                        LA GAZETTE                         MA BANQUE   ← étiquettes   │
   └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘
   À gauche et à droite de la zone utile : décor qui ne sert qu'aux écrans plus larges (20:9).
```

- Les 3 bâtiments jouables occupent la **zone utile** (1 400 × 700 unités, centrée en bas), toujours visible quel que soit l'écran (§ 4.2).
- Hauteurs : maison 300, banque 340, média 520 (le plus haut : c'est d'où vient le spectacle). Chaque bâtiment a une **étiquette** sous le trottoir (pastille sombre, texte de 20 px) et une **zone de toucher** au moins égale à sa façade.
- Survol (PC) ou appui (mobile) : contour lumineux de 3 px à l'accent autour de la façade et léger soulèvement (`position.y` − 6, 0,12 s).

### 2.4 La ville qui vit

| Élément | Règle | Implémentation |
|---|---|---|
| **Cycle jour et nuit** | 60 s réelles par cycle, **indépendant de la vitesse du jeu** (en ×3, un cycle par mois ferait clignoter l'écran). Figé en pause. | Uniformes `jour` et `couchant` du shader de ciel ; `modulate` du nœud `Ville/Decor` : jour `#FFFFFF`, couchant `#FFD9C2`, nuit `#5A5F8C`. Les fenêtres s'allument une à une au crépuscule (décalage aléatoire de 0 à 3 s). |
| **Saisons** (liées aux mois du jeu) | Printemps et été : arbres vert `#6DBE6A` ; automne (sept. à nov.) : `#E39B4B` et feuilles qui tombent ; hiver (déc. à févr.) : arbres nus, toits blanchis, neige légère. | `modulate` des feuillages ; `CPUParticles2D` (feuilles : 12, neige : 60) |
| **Trafic** | 3 à 5 voitures et 4 à 8 passants, qui traversent en boucle. Au krach : les passants s'arrêtent et regardent le média. | Nœuds réutilisés, déplacés en `_process()` ; vitesse × 1,3 en ×3 |
| **Vie des bâtiments** | Maison : fenêtre de Gérard allumée le soir, fumée de cheminée en hiver. Média : bandeau LED qui défile (cours de l'indice, dernières manchettes), antenne qui clignote. Banque : horloge dont l'aiguille tourne d'un tour par mois de jeu. | `_draw()` et `Tween` en boucle |
| **Pause** (temps gelé) | Passants et voitures figés, ciel bleui et désaturé, cadre « gel » autour de l'écran, badge « EN PAUSE » | Uniforme `gel` → 1 en 0,3 s ; `process_mode` de la ville sur pause |

### 2.5 L'époque dans la rue (peu coûteux, par tables de données)

Une table `epoques` indique, par année, quels **variants** afficher. Chaque variant est un petit polygone ou un texte.

| Élément | 1978-1985 | 1986-1992 (tranche) | Plus tard (P2, P3) |
|---|---|---|---|
| Voitures | Profils arrondis (2CV, DS), couleurs ocre, vert olive, orange | Profils carrés (R5, 205), rouge, blanc, bleu marine | 1996+ : profils ronds ; 2011+ : citadines, 1 voiture électrique silencieuse |
| Kiosque | Journaux | + affiche « 3615 » (Minitel) | 2000 : affiche « @ » ; 2011 : kiosque fermé |
| Cabine téléphonique | Oui | Oui, + « Télécarte » | Disparaît en 2011 |
| Banque | Enseigne peinte | + distributeur de billets à écran vert | 2000 : logo moderne ; 2020 : « Banque en ligne » |
| Média | Antenne râteau, enseigne peinte | Écran lumineux sur le toit, enseigne néon ; en **juin 1988**, l'écran passe de « INDICE » à « CAC 40 » | 2000 : « LaGazette.fr » ; 2020 : écran géant à LED |
| Horizon | Tour Montparnasse | Idem (la Grande Arche apparaît en 1989) | Tours de La Défense de plus en plus nombreuses |
| Passants | Pantalons à pattes d'éléphant (jambes évasées) | Épaulettes (corps plus large en haut), walkman (point jaune) | Téléphones portables (rectangle lumineux à la main) |

### 2.6 Palette

**HUD** (identique pour toutes les périodes, contrastes calculés sur `panneau` `#161E2E`) :

| Jeton | Hex | Usage | Contraste |
|---|---|---|---|
| `panneau` | `#161E2E` (α 0,88) | Panneaux du HUD | — |
| `panneau_eleve` | `#1F2A3F` | Cartes, survol | — |
| `filet` | `#2E3B55` | Séparateurs, frise à venir | décoratif |
| `texte` | `#EDEAE0` | Texte principal, montants | 14:1 |
| `texte_2` | `#9AA6BD` | Texte secondaire | 6,8:1 |
| `gain` | `#46E08A` | Hausses, ▲ | 9:1 |
| `perte` | `#FF5C5C` | Baisses, ▼, découvert | 5,5:1 |
| `or` | `#F2C14E` (ombre `#B8862B`) | Pièces, intérêts, étoiles ; jamais pour du texte courant | 9:1 |
| `gel` | `#7FD6FF` | Pause | 10:1 |
| `alerte` | `#FFC94D` | Avertissements | 10:1 |
| `accent` | P1 `#FFB547` (ambre) · P2 `#3FC3FF` (cyan) · P3 `#A98BFF` (violet) | Bouton principal, curseur de frise, courbe | ≥ 6:1 |
| `encre_sur_accent` | `#14100A` | Texte sur un bouton d'accent | ≥ 6:1 |

**Ville, période P1** (aplats ; ton d'ombre = −20 % de luminosité) :

| Élément | Couleur |
|---|---|
| Ciel de jour, haut → bas | `#6BA8DB` → `#EEDDB8` |
| Ciel de nuit, haut → bas | `#0D1022` → `#2A1F38` ; couchant `#FA8C5C` |
| Horizon (silhouettes) | `#8E9BB5` le jour (mélangé au ciel) |
| Immeubles lointains | `#C9B79C`, `#B9A58A`, toits `#6E7A8C` |
| Maison | murs `#E8D3B0`, toit `#B5553C`, volets `#3F7F8C` |
| Média | façade `#3B4A63`, enseigne néon `#FF6FA8`, écran `#0E1A12` à tracé ambre |
| Banque | pierre `#E9E2D3`, fronton `#D6CCB8`, porte `#5A3E2B`, enseigne or `#C9A24A` |
| Trottoir, chaussée | `#9C968C`, `#4A4A52`, marquage `#E8E2D0` |
| Fenêtres allumées, réverbères | `#FFD27A`, halo `#FFD27A` α 0,25 |

**Papier** : journal `#EFE6D2`, encre `#1B1A17` (15:1), encre rouge `#B3261E` (5,3:1) ; courrier `#FBF8F1` ; variantes du journal par décennie : 04 §7.3.
**Catégories** (barre de répartition, avec motifs, 04 §7.5) : compte `#8C96A8`, livret `#4EA8DE`, emprunt `#B39DDB`, SICAV `#5CC8A0`, actions `#FF8A65`, ETF `#F2C14E`.
**Daltonisme** (option) : `gain` = `#4DA3FF`, `perte` = `#FF9F1C`. Les variations portent toujours ▲/▼ et +/− ; l'accent ne sert jamais à une variation.

### 2.7 Typographie

Polices système par la ressource **`SystemFont`** (liste de repli Windows puis Android, puis police par défaut de Godot). Activer `multichannel_signed_distance_field` sur les titres et les chiffres (ils sont agrandis pendant les animations). Interlettrage par `FontVariation.spacing_glyph`, chiffres à chasse fixe par `opentype_features = {"tnum": 1}` (à vérifier sur Bahnschrift ; sinon, largeur minimale fixe pour que le compteur ne tremble pas).

| Rôle | `font_names` (ordre de repli) | Graisse |
|---|---|---|
| Chiffres, date, compteurs | `Bahnschrift`, `Roboto Condensed`, `sans-serif-condensed`, `sans-serif` | 600 à 700 |
| Interface | `Segoe UI`, `Roboto`, `sans-serif` | 400 / 600 |
| Bandeau LED du média | `Consolas`, `Lucida Console`, `monospace` | 700 |
| Manchettes | par décennie (04 §7.3) ; **Rockwell n'est pas installé par défaut sous Windows** : `Rockwell`, `Georgia`, `serif` | 700 |
| Corps du journal, courrier | `Georgia`, `serif` / police d'interface | 400 |

**Une seule échelle de tailles**, en px virtuels sur la base 1 920 × 1 080 (§ 4.1). Le facteur d'échelle du téléphone (× 1,7) les grossit automatiquement.

| Élément | px virtuels | Rendu PC 1080p | Rendu téléphone 6,5" |
|---|---|---|---|
| Date à volets | 48 | 48 px | ≈ 30 dp |
| Patrimoine total | 44 | 44 px | ≈ 27 dp |
| Compte courant | 34 | 34 px | ≈ 21 dp |
| Texte courant, libellés de bouton | 24 | 24 px | ≈ 15 dp |
| Variation, titre de panneau (capitales, + 2 d'interlettrage), étiquette de bâtiment | 20 | 20 px | ≈ 12 dp |
| **Minimum absolu** (texte secondaire) | 20 | 20 px | ≈ 12 dp |
| Montant d'une carte | 30 | 30 px | ≈ 19 dp |
| Manchette du journal | 72 | 72 px | ≈ 45 dp |
| Chapô du journal, texte du courrier | 26 | 26 px | ≈ 16 dp |
| Montant flottant (« + 1 200 F »), contour de 6 px | 30 | 30 px | ≈ 19 dp |

Sur un portable en 1 366 × 768, tout est réduit à 71 % (texte courant de 17 px, minimum de 14 px). Option « Texte plus grand » : × 1,15.

### 2.8 Panneaux (valeurs StyleBoxFlat)

Un seul `Theme` (`res://theme/theme.tres`) avec des variations de type (`theme_type_variation`).

| Variation | bg_color | Coins | Bordure | Ombre | Marges | Remarque |
|---|---|---|---|---|---|---|
| `Panneau` (HUD) | `#161E2E` α 0,88 | 18 | 1 px `#FFFFFF14` ; **haut 2 px `#FFFFFF24`** (lumière d'en haut) | `#00000099`, taille 18, décalage (0, 8) | 16 × 20 | `anti_aliasing` activé |
| `CartePlacement` | `#1F2A3F` | 14 | 1 px `#FFFFFF1A` ; haut 2 px `#FFFFFF2E` ; **gauche 6 px couleur de catégorie** | `#00000080`, 10, (0, 6) | 14 × 18 | Survol : `#26334C` |
| `BoutonPrincipal` | `accent` | 16 | **bas 4 px accent assombri de 30 %** (relief) | `#00000066`, 6, (0, 4) | 14 × 28 | Survol : + 8 % de luminosité, ombre accent α 0,35 taille 14 (lueur). Appui : bordure basse 1 px, marge haute + 3 px. |
| `BoutonSecondaire` | `#FFFFFF0F` | 16 | 1,5 px `#FFFFFF33` | aucune | 12 × 24 | Survol : `#FFFFFF1F` |
| `EtiquetteBatiment` | `#161E2E` α 0,85 | 999 (pilule) | 1 px `#FFFFFF24` | `#00000080`, 8, (0, 4) | 6 × 16 | Point de notification : disque `perte` de 16 px en haut à droite |
| `Journal` | `#EFE6D2` | 2 | aucune | `#000000B3`, 30, (6, 14) | 36 | Rotation − 1,5° au repos, shader papier |
| `Courrier` | `#FBF8F1` | 6 | **gauche 10 px** perte, gain ou accent (04 §3.6) | `#00000099`, 24, (4, 10) | 28 | Rotation + 1° au repos |
| `CarteAppel` | `#1F2A3F` | 22 | 2 px accent | `#000000B3`, 24, (0, 10) | 24 | Portrait du banquier dans un disque de 120 px |
| `Notification` | `#1F2A3F` α 0,95 | 14 | gauche 6 px couleur de la source (maison, banque, média) | `#00000099`, 16, (0, 6) | 12 × 18 | |
| `PastilleImpact` | `perte` α 0,16 (ou `gain`) | 999 | 2 px `perte` (ou `gain`) | aucune | 8 × 20 | |
| `Focus` | `draw_center` désactivé | 18 | 3 px `#FFFFFF` | aucune | `expand_margin` 4 | Clavier et manette |

**Reflet** : chaque `Panneau` porte un enfant `TextureRect` (`GradientTexture2D` vertical, blanc α 0,06 → 0 sur la moitié haute, `mouse_filter` = ignorer), avec `clip_children = CLIP_CHILDREN_AND_DRAW` sur le panneau pour respecter les coins arrondis.

### 2.9 Shaders et matières

| Matière | Où | Recette |
|---|---|---|
| **Ciel** | Plan 0 de la ville | `ciel.gdshader` ci-dessous : dégradé jour / nuit, couchant, étoiles, uniformes `krach` et `gel`, grain léger |
| **Néon** | Enseigne du média, logo du titre, « EN PAUSE » | `font_shadow_color` = couleur α 0,6, `shadow_outline_size` 12, décalage nul ; clignotement par bruit (α 0,85 à 1) |
| **Écran du toit** | Média | Fond `#0E1A12`, courbe de l'indice en ambre, lignes de balayage 1 sur 3 px à α 0,10 |
| **Papier journal** | Journal | Bruit fin (α 0,06), fibres (bruit étiré horizontalement), bords assombris de 8 %, double filet sous le nom du journal |
| **Courrier** | Modale de vie | Papier plus blanc, grain α 0,03, timbre dentelé en `_draw()` |
| **Reflet de confirmation** | Carte achetée | Bande diagonale blanche α 0,25 qui traverse (uniforme `progres`) |

```glsl
// res://shaders/ciel.gdshader : ColorRect plein écran, plan 0 de la ville.
shader_type canvas_item;
uniform vec4 haut_jour : source_color = vec4(0.42, 0.66, 0.86, 1.0);
uniform vec4 bas_jour  : source_color = vec4(0.93, 0.87, 0.72, 1.0);
uniform vec4 haut_nuit : source_color = vec4(0.05, 0.06, 0.13, 1.0);
uniform vec4 bas_nuit  : source_color = vec4(0.16, 0.12, 0.22, 1.0);
uniform vec4 lueur_couchant : source_color = vec4(0.98, 0.55, 0.36, 1.0);
uniform float jour : hint_range(0.0, 1.0) = 1.0;      // 1 = plein jour, 0 = nuit
uniform float couchant : hint_range(0.0, 1.0) = 0.0;  // lueur orange à l'horizon
uniform float krach : hint_range(0.0, 1.0) = 0.0;     // ciel d'orage rouge-gris
uniform float gel : hint_range(0.0, 1.0) = 0.0;       // pause : bleui, désaturé
uniform float grain = 0.02;
float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
    vec3 col = mix(mix(haut_nuit.rgb, haut_jour.rgb, jour), mix(bas_nuit.rgb, bas_jour.rgb, jour),
                   smoothstep(0.0, 1.0, UV.y));
    col = mix(col, lueur_couchant.rgb, couchant * smoothstep(0.4, 1.0, UV.y) * 0.7);
    col += step(0.9975, hash(floor(UV * vec2(420.0, 240.0)))) * (1.0 - jour) * (1.0 - UV.y) * 0.8;
    col = mix(col, vec3(0.36, 0.12, 0.12), krach * 0.6);
    float g = dot(col, vec3(0.299, 0.587, 0.114));
    col = mix(col, vec3(g * 0.85, g * 0.95, g * 1.15), gel * 0.5);
    col += (hash(UV * 900.0 + fract(TIME)) - 0.5) * grain;
    COLOR = vec4(col, 1.0);
}
```

---

## 3. « Game feel » : les 10 effets qui font la différence

**Règles communes**
- **Une seule vedette à la fois** : une file dans l'autoload `Juice` sérialise les effets majeurs (un appel du banquier n'arrive pas pendant le krach).
- **Animation de bâtiment avant chaque modale : 2 s au maximum, passable d'un toucher ou d'un clic** (A34) : le toucher termine instantanément les tweens (état final) et ouvre la modale.
- **La caméra désigne la source** : avant une animation de bâtiment, la `Camera2D` de la ville glisse et zoome de 6 % vers le bâtiment (0,35 s, `CUBIC`/`IN_OUT`), puis revient à la fermeture de la modale.
- **Vitesse** : en ×2, durées × 0,75 ; en ×3, durées × 0,5, sans pièces de salaire ni montants flottants sur les cartes.
- **Animations réduites** (option, et défaut si le système le demande) : ni secousse, ni rotation, ni zoom de caméra, ni particules ; fondus de 0,15 s au maximum. Les animations de bâtiment deviennent un simple halo de 0,5 s.
- Tous les effets passent par `Juice` (`secouer()`, `pieces()`, `flottant()`, `son()`, `animer_batiment()`).

| # | Effet | Déclencheur | Durée | Easing | Implémentation Godot |
|---|---|---|---|---|---|
| 1 | **Appel du banquier** | Déblocage de produit, privatisation, taux, fiscalité, bilan annuel, rappel à 12 mois (A33) | 1,9 s, puis la carte d'appel | Caméra `CUBIC`/`IN_OUT` ; sonnerie `SINE` ; signal `SINE`/`IN_OUT` ; carte `BACK`/`OUT` | t = 0 : caméra vers la banque ; la fenêtre du banquier s'allume avec sa silhouette (combiné à l'oreille). t = 0,2 s : un **combiné** dessiné au-dessus du toit sonne (rotation ± 12°, 2 salves de 4 × 0,06 s) et émet 3 **arcs d'ondes** qui grandissent et s'effacent (0,6 s, `draw_arc()`). t = 0,9 s : un **signal** (5 points lumineux) file de la banque à la maison le long d'un arc (0,5 s, Bézier quadratique). t = 1,4 s : la fenêtre de la maison clignote. t = 1,6 s : la **carte d'appel** (§ 3.1) glisse depuis le côté de la banque (0,3 s). Son : double sonnerie de téléphone à cadran (générée). |
| 2 | **News du média et journal qui tournoie** | Événement de marché (04 §3.5) | Krach : 1,8 s de bâtiment, puis 0,7 s de journal ; news ordinaire : 1,2 s puis 0,45 s | Ciel `SINE`/`IN_OUT` ; journaux `CUBIC`/`OUT` ; rotation finale `QUART`/`OUT` ; chute `BACK`/`OUT` | **Krach** : t = 0 caméra vers le média ; uniforme `krach` du ciel de 0 à 1 (0,8 s) ; l'enseigne grésille ; le bandeau LED affiche « FLASH » en rouge (3 clignotements de 0,1 s) ; l'**écran du toit montre la courbe qui plonge** ; l'antenne émet 3 ondes rouges ; les passants s'arrêtent. t = 0,8 s : **3 journaux jaillissent** du média en tournoyant vers la caméra (`scale` 0,2 → 0,6, rotation ± 360°, 0,5 s, en décalé). t = 1,3 s : le dernier grandit jusqu'à devenir la **modale journal** (`scale` → 1, rotation finale − 1,5°, 0,7 s) ; à l'arrivée : secousse 0,5 et poussière (`CPUParticles2D`, 28 grains beige en un coup). La manchette s'imprime (`visible_ratio` 0 → 1, 0,35 s) ; les boutons sont actifs après 1 s (04 §3.5). Puis **pluie** sur la ville (`CPUParticles2D`, traits de 2 × 18 px, 120 particules) tant que le patrimoine reste à plus de 15 % sous son plus haut. **News ordinaire** : ondes blanches, 1 seul journal, modale en chute simple (`scale` 1,8 → 1, rotation − 12° → − 1,5°). Sortie de la modale : glisse vers le bas avec + 8° (0,3 s, `CUBIC`/`IN`). |
| 3 | **Petite news sans pause** | Notification de contexte (exemple : l'indice devient le CAC 40, juin 1988) | Bandeau LED : 5 s ; notification : 0,4 s | Linéaire ; notification `BACK`/`OUT` | 1 onde blanche depuis l'antenne ; la manchette défile sur le bandeau LED du toit ; une **notification** part du média et vole vers sa place dans le HUD (0,4 s), avec la bordure gauche à la couleur du média. Le temps ne s'arrête pas. |
| 4 | **Courrier depuis la maison** | Événement de vie en modale ou en notification (04 §3.6). Exemple de la tranche : la panne de voiture. | 1,6 s, puis la modale | Rebond `BACK`/`OUT` ; enveloppe `CUBIC`/`OUT` | t = 0 : caméra vers la maison. **Panne** : la voiture devant la maison tousse (4 bouffées de fumée grise en particules, carrosserie `scale.y` 1 → 0,9 → 1 deux fois, 0,8 s), le capot se soulève. t = 0,8 s : le **drapeau rouge de la boîte aux lettres** se lève (0,2 s), une **enveloppe** en sort et vole vers le centre en grandissant (0,5 s) puis devient la modale courrier (`letter-slide`, 04 §6.1). Bonne nouvelle : confettis dorés au-dessus du toit au lieu de la fumée. |
| 5 | **Compteurs qui roulent**, avec pop et montant flottant | Toute variation d'un montant affiché | Roulement : min(0,6 s ; 40 % du mois). Pop : 0,07 s + 0,25 s. Flottant : 0,9 s. | Roulement `EXPO`/`OUT` ; pop `SINE`/`OUT` puis `BACK`/`OUT` ; flottant `CUBIC`/`OUT` | `tween_method()` sur une fonction qui formate le texte ; `pivot_offset = size / 2`, puis `scale` 1 → 1,10 → 1 ; `modulate` vers `gain` ou `perte` puis retour en 0,6 s. Flottant : `Label` créé dans le calque Effets, qui monte de 60 px et s'efface sur les 0,3 dernières secondes. |
| 6 | **Pièces volantes** | Salaire (3 pièces de la banque vers le compte du HUD, en ×1 seulement) ; intérêts du livret ; achat (3 pièces du compte vers la banque) | 0,55 s par pièce, départs décalés de 0,05 s | `SINE`/`IN_OUT` le long d'une Bézier quadratique (point de contrôle 120 px au-dessus) | Réserve de 12 nœuds `Piece` (28 px, `_draw()` : disque `or`, liseré `#B8862B`, reflet blanc α 0,5). Rotation simulée par `scale.x = abs(cos(t × 12))`. Passage du monde au HUD : position convertie avec `get_global_transform_with_canvas()`. À chaque arrivée : pop du compteur (effet 5) et « ting » dont la hauteur monte de 5 % par pièce. |
| 7 | **Secousse d'écran et ambiance de krach** | Impact du journal (0,5 pour un krach, 0,25 sinon), mois où l'indice perd 8 % ou plus (0,2), achat refusé (0,15, horizontale) | Décroissance du « trauma » : 1,6 par seconde ; vibration mobile de 40 à 80 ms | Amplitude ∝ trauma² | Décalage = bruit `FastNoiseLite` × 20 px × trauma², appliqué à `offset` de la `Camera2D` (ville, amplitude pleine) et du `CanvasLayer` du HUD (30 %). Les modales ne bougent pas. `Input.vibrate_handheld(60)`. |
| 8 | **Date à volets** | Nouveau mois ; en janvier, le volet de l'année tombe aussi | Fermeture 0,09 s, ouverture 0,14 s ; année décalée de 0,05 s | `QUAD`/`IN` puis `BACK`/`OUT` | Deux cases sombres (mois, année) avec une ligne médiane ; `scale.y` 1 → 0, changement du texte, 0 → 1 ; un `ColorRect` noir α 0,3 couvre la moitié basse pendant le pliage. Son « tic ». |
| 9 | **Courbe vivante** (panneau « Mon argent » et écran du toit) | Nouveau mois | Segment : min(0,6 s ; 40 % du mois) ; tête : pulsation de 1,2 s ; recadrage de l'axe : 0,5 s | `CUBIC`/`OUT` ; `SINE`/`IN_OUT` ; `CUBIC`/`IN_OUT` | `Control` avec `_draw()` : aire en `draw_polygon()` avec couleurs par sommet (accent α 0,30 en haut, 0 en bas) ; trait en 3 passes `draw_polyline()` (14 px α 0,12, 7 px α 0,25, 3 px α 1) ; tête en 3 cercles concentriques ; `CPUParticles2D` sur la tête avec `local_coords = false` (traînée, 30 particules) ; étiquette de prix qui suit la tête. Couleur de la tête : `gain` ou `perte` selon le mois. |
| 10 | **Boutons, panneaux et bâtiments « physiques »** | Survol, appui, achat confirmé ou refusé, ouverture d'un panneau | Survol 0,12 s ; appui 0,06 s ; relâchement 0,2 s ; panneau 0,3 s à l'entrée, 0,22 s à la sortie ; reflet 0,6 s | Survol `SINE`/`OUT` ; relâchement `BACK`/`OUT` ; panneau `CUBIC`/`OUT` puis `CUBIC`/`IN` | Survol : `scale` 1,03 et lueur. Appui : `scale` 0,95. **Toucher un bâtiment** : la façade s'enfonce de 4 px puis rebondit, et le panneau correspondant **se déplie depuis le bâtiment** (`scale` 0,6 → 1 depuis un `pivot_offset` placé du côté du bâtiment, avec fondu). Achat confirmé : le bouton devient « ✓ Acheté » sur fond `gain` (1,2 s), la carte est balayée par le reflet, pièces vers la banque, la barre de répartition se recalcule en 0,4 s. Refus : secousse horizontale de la ligne du montant et flash `perte`. |

**Extrait de référence** (secousse et compteur)

```gdscript
# Juice.gd (autoload)
var trauma := 0.0
var camera: Camera2D        # caméra de la ville
var hud: CanvasLayer
var _bruit := FastNoiseLite.new()
var _t := 0.0

func secouer(q: float) -> void:
	if Reglages.animations_reduites: return
	trauma = minf(1.0, trauma + q)

func _process(delta: float) -> void:
	_t += delta * 40.0
	trauma = maxf(0.0, trauma - 1.6 * delta)
	var d := Vector2(_bruit.get_noise_2d(_t, 0.0), _bruit.get_noise_2d(0.0, _t)) * 20.0 * trauma * trauma
	if camera: camera.offset = d
	if hud: hud.offset = d * 0.3

func rouler(label: Label, de: float, a: float, duree: float) -> void:
	var t := label.create_tween()
	t.tween_method(func(v: float): label.text = Format.argent(v), de, a, duree) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	label.pivot_offset = label.size / 2.0
	t.tween_property(label, "scale", Vector2.ONE * 1.10, 0.07).set_trans(Tween.TRANS_SINE)
	t.tween_property(label, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
```

**Icônes** : dessiner ▶, ❚❚, ▲, ▼, ⚑, ◆, ★, le combiné et l'enveloppe en `_draw()` plutôt qu'en caractères Unicode, dont le rendu n'est pas garanti par les polices Android.

**Sons** (recommandés, sommaires dans la tranche) : 7 sons générés en code au démarrage (`AudioStreamWAV` rempli par sinusoïde ou bruit filtré, recettes de 04 §6.3) : tic (volet), ting (pièce), sonnerie de téléphone, boum sourd (journal), froissement (courrier), clic, ambiance de rue en boucle (bruit rose très bas). *Proposition à arbitrer par le client* : sons **activés** par défaut à 60 %, avec un bouton muet toujours visible (04 §6.3 les désactivait).

### 3.1 La carte d'appel du banquier (nouvel écran)

```
        ┌───────────────────────────────────────────────────────────┐
        │  ╭─────╮   M. LEFRANC · votre banquier            ✕       │
        │  │ ◠ ◠ │   Banque · décembre 1986                         │
        │  │  ▬  │   (portrait en formes : visage, lunettes larges,  │
        │  ╰──┬──╯    moustache, cravate large : années 80)         │
        │ ───────────────────────────────────────────────────────── │
        │  « Grande nouvelle ! L'État vend Saint-Gobain au public,  │
        │    à 310 F l'action. Les guichets sont ouverts. »         │
        │    C'est quoi, une privatisation ? (?)                     │
        │  ┌──────────────────────────┐  ┌──────────────────────────┐│
        │  │  VOIR L'OFFRE            │  │  PLUS TARD               ││
        │  └──────────────────────────┘  └──────────────────────────┘│
        └───────────────────────────────────────────────────────────┘
```

- Le texte **informe, ne conseille pas** (A33) : pas de « je vous recommande ». « Voir l'offre » ouvre le marché sur le produit, prérempli selon 03 §6.1 ; le choix reste au joueur.
- Le portrait est dessiné en formes simples (disque du visage, cheveux, lunettes, moustache, col et cravate en triangles) et change de détails par décennie. Il « parle » : la bouche s'ouvre et se ferme pendant l'apparition du texte (`visible_ratio`, 0,02 s par lettre, plafonné à 1 s).
- Nom du banquier à valider par le client.

---

## 4. Mise en page adaptative (paysage uniquement, A35)

### 4.1 Résolution, étirement, échelle

| Réglage | Valeur |
|---|---|
| Taille de base | 1 920 × 1 080 |
| Étirement | `canvas_items`, aspect `expand` |
| Orientation mobile | Paysage verrouillé (`display/window/handheld/orientation` = `landscape` ; `sensor_landscape` pour autoriser les deux sens) |
| **Facteur d'échelle** (`get_tree().root.content_scale_factor`) | PC : 1,0. Téléphone (côté court < 3,5 pouces, calculé avec `DisplayServer.screen_get_size()` et `screen_get_dpi()`) : **1,7**. Tablette : 1,25. |
| Zone virtuelle effective | PC 16:9 : 1 920 × 1 080 (16:10 : 1 920 × 1 200). **Téléphone 20:9 : environ 1 410 × 635**, quelle que soit la définition de l'écran. **Une seule mise en page doit tenir de 1 410 × 635 à 1 920 × 1 200.** |
| Zones sûres | `DisplayServer.get_display_safe_area()` ajoutée aux marges gauche et droite du HUD (encoche en paysage). La ville passe sous l'encoche, pas le HUD. |
| Rendu | Moteur **Compatibility** (Android d'entrée de gamme). Pas de `WorldEnvironment` : toutes les lueurs sont dessinées. `CPUParticles2D`. Objectif : 60 images par seconde. |
| Test sur PC | Touche `F10` : fenêtre de 1 200 × 540 et facteur 1,7, soit **exactement** la zone d'un téléphone 20:9. |

**Calques** : ville dans le canevas par défaut, avec sa `Camera2D` ; `CanvasLayer` 1 HUD ; 2 Effets (pièces, montants flottants) ; 5 Modales (journal, courrier, carte d'appel, marché, fond assombri à 60 %) ; 10 Transitions.

**Cadrage de la ville** : à chaque changement de taille, la caméra calcule le rectangle libre (écran moins la barre haute, la frise et le panneau « Mon argent » s'il est ouvert) et règle `zoom` pour que la **zone utile** (1 400 × 700, § 2.3) y tienne entière, alignée en bas. Le surplus de largeur (écrans 20:9) montre le décor latéral, le surplus de hauteur montre le ciel. Ouvrir ou fermer le panneau recadre en 0,3 s (`CUBIC`/`IN_OUT`).

### 4.2 Écran principal sur PC (1 920 × 1 080)

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│┌─────┬──────┐ Baguette 2,90 F  ┌────┬────┬────┬────┐  ◉ EN PAUSE      COMPTE COURANT   PATRIMOINE      ≡ │ barre haute
││ OCT │ 1987 │                  │ ❚❚ │ ▶  │ ▶▶ │▶▶▶ │                     4 210 F      38 450 F ▼ −15 %  │ 96 px
│└─────┴──────┘                  └────┴────┴────┴────┘                                                   │
├──────────────────────────────────────────────────────────────────────────────┬───────────────────────────┤
│  ciel (jour / nuit, orage au krach)              ┌──────┐                    │ MON ARGENT   [Moi|Bourse] │ panneau
│                                                  │CAC 40│ ← écran du toit    │ 38 450 F                  │ 500 px
│      silhouette de Paris · palais Brongniart     │╲_╱‾╲_│                    │ = 13 260 baguettes        │ (ouvert
│                                                  ├──────┤                    │ ╭─╮   ╭──╮                │  par
│        /\                                        │□ ■ □ │   ┌─────────────┐  │─╯ ╰───╯  ╲_◉~ (courbe)    │  défaut
│       /__\                                       │■ □ □ │   │ B A N Q U E │  │ - - - argent mis de côté  │  sur PC)
│       │■ □│                    kiosque  cabine   │□ □ ■ │   │ ║ ║ ▣ ║ ║ ║ │  │ RÉPARTITION               │
│     ▯ │┌┐ │   (passants, voitures)               │┌──┐  │   │ ║ ║ ║ ║ ║ ║ │  │ [░░▓▓▓▓▒▒▒▒████]          │
│ ══════╧╧╧═╧══════════════════════════════════════╧╧══╧══╧═══╧═════════════╧═ │ CE MOIS-CI                │
│   ( MA MAISON )                    ( LA GAZETTE )            ( MA BANQUE )    │ Salaire        + 3 650 F  │
│ ┌────────────────────────────┐  ← notifications (3 au maximum),              │ Dépenses       − 3 000 F  │
│ │▌ Le CAC 40 est né  · média │     en haut à gauche sous la barre             │ Reste          +   650 F  │
│ └────────────────────────────┘                                               │ COUSSIN ███████░░ 2,1 mois │
│                                                                              │ ┌───────────────────────┐ │
│                                                                              │ │    MARCHÉ (banque)    │ │
│                                                                              │ └───────────────────────┘ │
├──────────────────────────────────────────────────────────────────────────────┴───────────────────────────┤
│ 1986      │      1987      │ ◆    1988      ⚑     ██████████████████████████◉═══════════════════════════  │ frise 72 px
└──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Écran principal sur téléphone (zone effective ≈ 1 410 × 635)

Même structure ; le panneau « Mon argent » est **replié par défaut** en une languette à droite, qui montre le patrimoine et une mini-courbe.

```
┌────────────────────────────────────────────────────────────────────────────────┐
│┌─────┬──────┐ ┌──────┐┌──────┐                PATRIMOINE            ≡         │ 96 px
││ OCT │ 1987 │ │  ▶   ││  ×2  │  ◉ PAUSE       38 450 F ▼ −15 %                │
│└─────┴──────┘ └──────┘└──────┘                compte 4 210 F                  │
├────────────────────────────────────────────────────────────────────────┬───────┤
│ ┌──────────────────────┐                ┌────┐                          │ MON   │
│ │▌ Le CAC 40 est né    │ (notification) │CAC │                          │ ARGENT│ languette
│ └──────────────────────┘                ├────┤       ┌──────────┐       │       │ 96 px
│      /\                                 │□ ■ │       │ BANQUE   │       │ 38 k  │ (toucher :
│     /__\                                │■ □ │       │ ║ ║▣║ ║  │       │ ╲_╱‾  │  le panneau
│ ▯   │■ □│      kiosque                  │┌─┐ │       │ ║ ║ ║ ║  │       │       │  se déplie
│ ════╧╧══╧═══════════════════════════════╧╧═╧╧═══════╧══════════╧═════  │   ◀   │  sur 560 px,
│  (MAISON)                          (GAZETTE)          (BANQUE)          │       │  la ville
├────────────────────────────────────────────────────────────────────────┴───────┤  glisse)
│ 1986      │      1987      │ ◆   1988   ⚑  ████████████████◉════════════════   │ 72 px
└────────────────────────────────────────────────────────────────────────────────┘
```

| Différence téléphone | Règle |
|---|---|
| Contrôles du temps | 2 boutons de 80 × 80 px : lecture / pause, et vitesse cyclique ×1 → ×2 → ×3 (le PC garde les 4 boutons) |
| Barre haute | Le patrimoine passe en premier ; le compte courant en dessous en 24 px ; la baguette passe dans « Mon foyer » |
| Panneaux (« Mon argent », « Mon foyer », marché) | Panneaux latéraux qui se déplient depuis le bâtiment ou la languette, sur 560 px, fermés par glissement ou par toucher du fond |
| Saisie d'un montant | **Pas de clavier virtuel par défaut** : boutons 10 / 25 / 50 % / Tout, curseur, et pas de ± 100 F ; le champ numérique reste disponible |
| Journal | 1 100 px de large au maximum, hauteur ≤ 590 px : manchette sur 2 lignes, chapô de 3 lignes au maximum, 3 choix côte à côte de 80 px de haut |
| Bulles « C'est quoi ? » | Toucher le `(?)` ; appui long sur un chiffre. Rien n'est accessible uniquement au survol (A29) |

**Tailles tactiles** : **80 px virtuels au minimum** (≈ 49 dp sur téléphone, 80 px sur PC) et 16 px d'écart entre deux cibles. Les zones de toucher peuvent dépasser le dessin. Les bâtiments ont une zone de toucher d'au moins 200 × 200 px virtuels.

---

## 5. Version minimale (« tranche verticale ») : alignée sur client A31 à A35 et client §4.1

**But** : que le joueur dise « oui, c'est ça » ou « non, plutôt comme ceci ». **Tranche de P1, septembre 1986 → décembre 1988**, données de `jeu/data/` (indice, SICAV, Saint-Gobain, livret, salaire de Gérard). État de départ de démonstration : un compte courant et un Livret A déjà garnis (valeurs plausibles fixées par le développeur à partir d'une simulation de la V1).

### 5.1 Contenu exact et niveau de soin

| # | Élément | Contenu | Soin |
|---|---|---|---|
| 1 | **Lancement** | Exe Windows autonome (et `Jouer.bat`), APK Android, ou à défaut le mode `F10` | — |
| 2 | **Écran titre** | La ville elle-même, au crépuscule : la caméra glisse lentement le long de la rue (travelling de 20 s en boucle), le logo « JEUCLAUDE » s'allume en **néon sur le toit du média**, les fenêtres s'allument. Bouton **Jouer** : la caméra plonge vers la maison (0,8 s) et le HUD glisse en place (barre haute par le haut, frise par le bas, panneau par la droite, 0,3 s en décalé). **Aucun changement de scène.** | **Fort** |
| 3 | **La ville** | Les 3 bâtiments jouables avec étiquettes et zones de toucher, horizon, plan moyen, ciel animé (cycle de 60 s), 3 voitures et 4 passants, saisons (au moins l'hiver avec la neige), variantes 1986-1988 (§ 2.5 : voitures carrées, Minitel, écran du toit qui passe à « CAC 40 » en juin 1988) | **Fort** |
| 4 | **HUD** | Barre haute (date à volets, contrôles du temps, compte et patrimoine qui roulent, état de pause gelé) ; frise de la tranche (curseur continu, marqueur ◆ après le krach) ; panneau « Mon argent » (courbe de patrimoine et pointillé « argent mis de côté », barre de répartition, budget du mois, coussin) | **Fort** pour la barre haute et la frise ; moyen pour le panneau |
| 5 | **Écran du toit du média** | La courbe de l'indice (effet 9) et le bandeau LED | **Fort** |
| 6 | **Appel du banquier** (déc. 1986) | Effet 1, carte d'appel (§ 3.1) sur la privatisation de Saint-Gobain à 310 F, « Voir l'offre » | **Fort** |
| 7 | **Marché** | Toucher la banque (ou « Voir l'offre ») ouvre le panneau : acheter Saint-Gobain ou la SICAV, déposer sur le Livret A ; montant par 10 / 25 / 50 % / Tout et curseur, frais visibles, confirmation (effet 10, pièces vers la banque) | Moyen pour la mise en page ; **fort** pour la confirmation et le toucher |
| 8 | **Krach** (oct. 1987) | Effet 2 complet (orage, journaux, modale journal avec les 3 choix de 04 §3.5), secousse, pluie tant que le patrimoine reste bas | **Fort** : c'est le moment à réussir |
| 9 | **Petite news sans pause** (juin 1988) | Effet 3 : « L'indice devient le CAC 40 » | Moyen |
| 10 | **Courrier depuis la maison** (nov. 1987, mois suivant le krach : coïncidence forcée de 03 §6.2) | Effet 4, modale courrier « La voiture rend l'âme » (04 §3.6, cas 1 ou 2 selon le compte) | **Fort** pour l'animation ; moyen pour la modale |
| 11 | **Salaire et dépenses** | Chaque mois, pièces de la banque vers le compte (×1) | Moyen |
| 12 | **Fin de la démonstration** (déc. 1988) | Carte simple « Fin de la démonstration », patrimoine qui roule, boutons « Rejouer » et « Quitter » (pas de bilan) | Sommaire |
| 13 | **Sons** | Les 7 sons générés, bouton muet | Sommaire |
| 14 | **Raccourci de démonstration** | `F8` ou triple toucher sur la date : saut au mois précédant le prochain moment fort | Sans soin |

**Hors tranche** (client §4.1) : création de partie, tutoriel, bilan de fin, témoins, fiscalité complète, sauvegarde, PEA, emprunt, euro, P2 et P3, options (seule une constante « animations réduites » est câblée).

**Peut rester sommaire** : panneaux « Mon foyer » et « Les nouvelles » (texte simple), mise en page du marché, menu ≡ réduit à « Quitter », libellés provisoires, sons basiques.

### 5.2 Critères pour juger le rendu

1. Une capture prise **à n'importe quel moment** montre d'abord une ville, pas un formulaire.
2. Quand le temps tourne sans action du joueur, au moins 5 choses bougent (passants, voitures, ciel, volets de la date, curseur, bandeau LED, compteurs).
3. Chaque événement se reconnaît **à son bâtiment** avant toute lecture ; chaque animation de bâtiment dure 2 s au maximum et se passe d'un toucher.
4. La séquence du krach (orage → journaux → journal lisible) tient en 2,5 s.
5. En mode `F10` (téléphone 20:9) : les 3 bâtiments sont visibles entiers, aucun texte n'est plus petit que 20 px virtuels, toutes les cibles font au moins 80 px virtuels, sans défilement.
6. 60 images par seconde sur le PC de développement ; pas de saccade pendant la pluie et les particules.

---

## 6. Où de vraies illustrations apporteraient le plus (demande future à l'utilisateur)

**Style recherché** : le style A (§ 2.2) poussé plus loin, en **ligne claire franco-belge contemporaine** : aplats, trait régulier optionnel, 4 à 6 couleurs par élément, léger grain ; décors d'époque documentés ; personnages expressifs. Format : **SVG** de préférence (Godot les importe en texture à la taille voulue), sinon PNG transparent au double de la taille d'affichage. **Chaque élément est livré en calques séparés** (façade, fenêtres, lumières, enseigne) pour garder les animations du § 3.

| Priorité | Où | Pourquoi | Quantité |
|---|---|---|---|
| 1 | **Les 3 bâtiments jouables** (maison, banque, média), avec leurs variantes d'époque | Ce sont eux qu'on regarde 20 minutes ; ils portent toute l'identité du jeu. | 3 bâtiments × 3 périodes |
| 2 | **Portraits du banquier et du personnage** (Gérard, Martine, Bernard × 3 époques), avec 3 expressions (content, inquiet, abattu) | Le joueur s'attache à un visage ; le banquier devient un vrai personnage récurrent. | 1 banquier × 3 époques ; 9 personnages × 3 expressions |
| 3 | **Vignette de la une** de chaque événement de marché, rendue en demi-teinte monochrome (un shader peut tramer une illustration en couleur) | Le journal devient une vraie une : c'est le moment fort de chaque partie. | 23 |
| 4 | **Véhicules et passants par décennie**, horizon de Paris et palais Brongniart | La rue raconte l'époque à elle seule. | une quarantaine de petits éléments |
| 5 | **Pictogrammes des courriers** en style de timbre (voiture, bébé, chaudière, héritage…) | Reconnaissance immédiate des événements de vie. | 11 |
| 6 | **Les 3 témoins** et les tampons des titres du bilan | Humour et collection, pour la version complète. | 3 + une vingtaine |

**Autres ressources à demander en même temps** (licences libres) :
- **2 ou 3 polices embarquées** (licence OFL) pour un rendu identique sous Windows et Android : une condensée pour les chiffres et les manchettes, une police d'interface, une police de bandeau LED. Bahnschrift et Segoe UI n'existent pas sur Android : sans elles, le rendu mobile sera moins typé.
- **Une quinzaine de bruitages** (licence CC0) : ambiance de rue, sonnerie de téléphone à cadran, rotative et papier, tampon, pièces, pluie, foule.
