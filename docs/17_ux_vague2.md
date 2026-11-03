# 17 : UX de la vague 2 (P4 dans la rue large) et préparation de la vague 3

> Auteur : designer UX. Date : 2026-10-30. Pour : chef de projet (lots 02-I, 02-V, puis 03-I, 04-I).
> Bases : docs/15 (§1 P4, §2 P2, §3 P1, §8), docs/16 §3, §5, §9, `lot_px1.md` §2.2, `lot_px2.md` §2.3-2.4, `hud.gd` actuel.
> Conventions : PC = 1 920 × 1 080 px virtuels ; téléphone = téléphone simulé de PX2 (1 600 × 720, 267 dpi, 1 dp = 1,67 px physiques). Toute cible tactile ≥ `Ecran.cible_min()` (48 dp) sur mobile, ≥ 80 px virtuels sur PC à 1080p. Texel d'interface = grille 640 × 360 (×3 à 1080p). `▓` = cadre pixel, `[..]` = bouton.

---

## 1. Le bouton « Jusqu'au prochain courrier » (P4)

### 1.1 Place : dans le groupe du temps, la baguette sort de la barre

Le bouton est un **contrôle du temps** (principe 1) : il se range à droite des vitesses, séparé d'elles par un filet vertical d'1 texel. Pour lui faire de la place, le bloc **BAGUETTE** quitte la barre haute sur PC (il est déjà caché sur téléphone) : le prix de la baguette reste dans « Mon foyer » (ligne existante) et l'équivalence « = 24 332 baguettes » dans « Mon argent ». Gain : ≈ 160 px, le bouton en prend ≈ 200.

**PC (barre de 96 px)**
```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ ╔═MAI═╗╔1987╗  [❚❚][ ▶ ][▶▶][▶▶▶] ┊ [»✉ COURRIER]  EN PAUSE    COMPTE  │ PATRIMOINE  ╔VS TOUT AU LIVRET A╗ [≡] ▓
▓ ╚═════╝╚════╝   80   80  80   80  ┊   ≈ 200 × 80                8 875 F │ 69 395 F ▲  ║ ▲ +3 916 F        ║     ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
- Bouton 9-patch `BoutonSecondaire`, hauteur 80, icône 16 × 16 texels (48 px) + libellé **COURRIER** en Pixelify 28 (capitales).
- Si la barre manque de largeur (fenêtre étroite non compacte) : on cache d'abord la variation « ▲ +26 % » du patrimoine (déjà caché en compact), puis le libellé du bouton (icône seule, 80 × 80). Jamais le bouton lui-même.

**Téléphone (mode compact : lecture/pause + vitesse cyclique)**
```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ ╔MAI╗╔1987╗ [❚❚][×1] ┊ [ »✉  ]   COMPTE  │ PATRIMOINE  ╔VS LIVRET A╗  [≡]   ▓
▓ ╚═══╝╚════╝          ┊ [COURRIER]  8 875 F │ 69 395 F    ║ ▲ +3 916 F║        ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
- Icône au-dessus, libellé dessous en **Atkinson gras 20 px** (Pixelify serait sous 28 px) ; bouton ≥ 64 × 48 dp. La barre compacte a la place (2 boutons de temps au lieu de 4).

### 1.2 Libellé et icône
- Libellé court : **COURRIER** (un mot, sens du docs/15 : « jusqu'au prochain courrier »). Info-bulle PC et nom accessible : « Avancer jusqu'au prochain appel, courrier ou journal (N) ». Écartés : « SUITE » (vague), « SAUT » (jargon), « ACCÉLÉRER » (confusion avec ×3).
- Icône 16 × 16 (`k` encre, `c` crème, `o` crème ombrée, `.` transparent) :
```
................
.kk..kk.........
..kk..kk........
...kk..kk.......
..kk..kk........
.kk..kk.........
................
...kkkkkkkkkkkk.
...kckoooooockk.
...kcckoooockck.
...kccckookccck.
...kcccckkcccck.
...kcccccccccck.
...kcccccccccck.
...kkkkkkkkkkkk.
................
```

### 1.3 États
| État | Rendu | Autres contrôles |
|---|---|---|
| **Caché** | avant la 1re interruption de la partie (une notion = un moment) | — |
| Repos | `BoutonSecondaire` ardoise | normal |
| **Saut actif** | fond **ambre** qui pulse (2 images, 2 im/s, pas d'alpha), chevrons qui avancent d'1 texel (2 images, 4 im/s) ; l'emplacement « EN PAUSE » affiche **» ×6** en ambre | boutons de vitesse éteints ; un appui sur COURRIER, une vitesse ou la pause **arrête** le saut |
| Inactif | modale ou fenêtre ouverte, décembre 1988 : icône et libellé à 40 % (couleur `secondaire`), aucun retour au toucher | — |
| Arrivée | le saut s'arrête **au** mois de la modale : la séquence du bâtiment prend le relais (§3) ; après la modale, retour à la vitesse d'avant l'appui, bouton au repos | — |

- Pendant le saut : les volets de la date tournent à chaque mois (existant), le curseur de la frise laisse **3 fantômes** (curseurs à 60, 40, 20 % d'opacité derrière lui) : la vitesse se voit sans couleur.
- **Première apparition** (après la résolution de la 1re interruption, ≈ février 1984) : le bouton glisse dans la barre (0,3 s) et une bulle pointée, une seule fois : « Rien à faire ce mois-ci ? COURRIER fait filer le temps jusqu'au prochain appel, courrier ou journal. » [COMPRIS]. Jamais rejouée (drapeau de sauvegarde, sinon réglage local).

---

## 2. Le badge des non-lus (sur HISTORIQUE)

### 2.1 Ce qui compte
Une notification est **non lue** si `n["pendant_saut"]` est vrai et qu'elle n'a pas été touchée, ou si elle a été poussée directement dans l'historique parce que 3 notifications étaient déjà à l'écran. Hors saut, rien ne change (pas de badge). **Ouvrir l'historique remet le compteur à zéro.**

### 2.2 Rendu
```
   PC (frise, 72 px)                       Téléphone
▓ ┌──────────────────┐③                ▓ ┌─────────────┐③
▓ │ ▤  HISTORIQUE    │ 1984 ┊ 1985 …   ▓ │ ▤ HISTORIQUE│ 1984 …
▓ └──────────────────┘                 ▓ └─────────────┘
```
- Pastille 9-patch `Pastille` en escalier, 12 × 12 texels (36 px), fond **ambre**, contour encre 1 texel, chiffre en **Atkinson gras 22**, encre ; posée à cheval sur le coin haut droit du bouton (moitié dehors), **dans** les bornes de la frise. Au-delà de 9 : « 9+ ». Le badge fait partie du bouton (pas une cible à part).
- Lisible sans couleur : c'est un chiffre dans une forme ; absent quand le compteur est à 0.
- **Arrivée d'un non-lu** : la notification qui quitte l'écran se réduit en une **fiche 8 × 8 texels** de la couleur de sa source qui vole vers HISTORIQUE (0,4 s, arc), puis le badge **saute d'1 texel** vers le haut (2 images, 0,12 s) et son chiffre change. Pas de mise à l'échelle des cadres pixel.
- Dans le classeur : les entrées non lues à l'ouverture portent une étiquette **NOUVEAU** (ambre, Pixelify 28 sur PC, Atkinson gras 20 sur téléphone) jusqu'à la fermeture ; chaque onglet affiche son nombre de nouveautés (« MA BANQUE · 2 »).
- Notifications à l'écran pendant le saut : forme compacte d'une ligne (pastille de source + titre ≤ 40 caractères), 3 au plus, empilées sous le bloc « La rue » ; la 4e pousse la plus ancienne vers HISTORIQUE (animation ci-dessus).

---

## 3. Pièces, enveloppes et caméra dans une rue plus large que l'écran

### 3.1 Règle d'or : la caméra ne bouge que pour une pause
| Événement | Caméra | Ce qu'on voit |
|---|---|---|
| Pièces du mois (×1, ×2) | **ne bouge pas** | pièces qui entrent ou sortent **par la flèche de bord** du bâtiment hors champ |
| Petite news (sans pause) | ne bouge pas | ondes de la Gazette ; si elle est hors champ, la flèche « ‹ LA GAZETTE » clignote 2 fois (rose néon) |
| Appel du banquier, journal, courrier, naissance, panne | `aller_vers(source)` puis séquence (PX1), modale, `revenir()` | la carte part du bâtiment, qui est visible |
| Carte de dilemme, de projet (vague 3) | `aller_vers("maison")` si la maison n'est pas visible | la carte sort de la porte (§4.1) |
| Saut en cours | ne bouge pas jusqu'à la modale d'arrivée | — |

- Glissement : 0,35 s si la cible est à moins d'un écran, 0,5 s au-delà ; courbe cubique entrée-sortie ; pas de zoom (grille entière). Passable d'un toucher comme les séquences.
- **À trancher par le chef de projet (écart avec `lot_px1` §3)** : PX1 fait de la position choisie par le joueur la nouvelle position de repos. Je recommande plutôt : **quand le temps tourne et que le joueur n'a pas touché la rue depuis 10 s**, la caméra revient seule à la maison (0,8 s). Sinon un joueur qui a regardé la banque ne voit plus les pièces arriver ni Sylvie à la fenêtre. En pause : la caméra reste où le joueur l'a laissée.

### 3.2 Les flèches de bord (PX2 les pose, la vague 2 les anime)
```
┌─────────────────────── rectangle libre (hors barre, frise, panneau) ───────────────────────┐
│                                                                                            │
│                         ┌▓▓cheminée▓▓┐                                                    │
│                         │  maison    │                                                    │
│ ═══════════════════════╧════porte═══╧══════════════════════════════════════════════════ │
│ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓┐            ( MA MAISON ☺ )                           ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓●┐ │
│ ▓‹ LA GAZETTE ▓                                                       ▓  MA BANQUE ›  ▓ │
│ └▓▓▓▓▓▓▓▓▓▓▓▓▓┘                                                       └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ │
└────────────────────────────────────────────────────────────────────────────────────────────┘
```
- Même hauteur que les étiquettes (sur la chaussée), à 16 px du bord du **rectangle libre** (donc à gauche du panneau « Mon argent » ouvert sur PC). Cadre `Panneau`, chevron sprite 8 × 8, libellé Pixelify 28 ; cible ≥ 80 px virtuels de haut (PC), ≥ 48 dp (téléphone). Toucher = `aller_vers(id)`.
- Le point d'alerte de la banque (`point_banque`, le banquier a quelque chose) se reporte sur la flèche (`●` en haut à droite).
- Deux bâtiments hors champ du même côté : deux flèches empilées (la plus proche en bas).

### 3.3 Trajet des pièces
```
 Maison visible, banque hors champ à droite (cas le plus courant : repos)

                      + 312 F               ← montant flottant au-dessus de la maison, à l'arrivée
                   ◦     ◦    ◦
              ◦ ↙                ◦  ◦ ←─── sortie : bord intérieur de la flèche
        ┌maison┐                        ┌▓▓▓▓▓▓▓▓▓▓▓▓┐
     ═══╧porte═╧══════════════════════  ▓ MA BANQUE ›▓  ← la flèche « saute » d'1 texel à chaque pièce
```
- **Départ** : si la source est visible, `ecran_batiment(b, porte)` ; sinon, le bord intérieur de sa flèche de bord. **Arrivée** : porte de la maison (or) ; vers la banque ou sa flèche (cuivre). Point d'arrivée **recalculé à chaque image** (le joueur peut faire glisser la rue pendant le vol).
- Arc parabolique (sommet 120 px virtuels au-dessus de la ligne départ-arrivée), 0,9 s, pièces décalées de 0,08 s, positions arrondies au texel. À l'arrivée : le compteur COMPTE roule, montant flottant (or « + 312 F », cuivre « − 45 F de frais »).
- Cuivre : part de la maison, sort par la flèche de la banque ; si le panneau « Mon argent » est ouvert, le chiffre FRAIS PAYÉS roule.
- **Ni la maison ni la banque visibles** : pas de pièces, seul le montant flottant près du compteur COMPTE.
- Enveloppes (courrier) et journaux volants : ils accompagnent une modale, donc la caméra a déjà glissé vers leur source (§3.1) ; s'ils visent un point hors champ (rare), même règle : sortie par la flèche.

---

## 4. Pour la vague 3

### 4.1 La carte de dilemme (pense-bête aimanté du frigo)

**Sortie** (≤ 1 s, passable d'un toucher) : la caméra montre la maison (§3.1) → la porte s'ouvre (3 images, monde) → une **fiche 12 × 8 texels** (UI) vole de la porte au centre (0,35 s, arc) → la carte se **déplie** en hauteur en 3 images (1/3, 2/3, plein ; découpe, sans mise à l'échelle) → l'aimant rouge tombe d'1 texel. Rangement : l'inverse, puis la porte se ferme.

**PC** (1 000 × 560 px virtuels, centrée, fond assombri 60 %, rue figée teinte gel)
```
                              ▄▀▄ aimant rouge (tuile), 8 × 8 texels
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀▄▀▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▌ MA MAISON · JUILLET 1984                                                       ◤   (coin corné)
▌ ┌────────┐   LES VACANCES 84                         ← Pixelify 48
▌ │ Sylvie │   « Sylvie rêve du Club Med à Agadir.      ← Atkinson 26, ≤ 30 mots
▌ │ 48×48  │     Votre frère prête sa tente pour
▌ │ (×3)   │     Palavas. »
▌ └────────┘
▌ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐   ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▌ ▓ 1  CLUB MED                ▓   ▓ 2  CAMPING À PALAVAS      ▓   ← Pixelify 28
▌ ▓    − 9 000 F         [☺]   ▓   ▓    − 2 500 F        [☹]   ▓   ← Atkinson gras 30 + picto 16×16
▌ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘   └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘   ← 2 × (440 × 120), même style
▌ Disponible sans rien vendre : 23 400 F (compte et Livret A)   ← Atkinson 20, secondaire
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
- `CartePapier` crème, liseré **tuile** (source maison) à gauche. Les deux boutons ont **le même style** (principe 11) ; recette : `+ 1 200 F` en gain avec le signe pour le vide-grenier.
- **Choix non payable** : bouton couvert de hachures en marches (motif, pas seulement du gris), texte remplacé sous le montant par « Il manque 1 200 F sur votre compte et votre Livret A » (Atkinson 20) ; non cliquable mais garde sa taille.
- Touches 1 / 2 ; pas de fermeture au clic extérieur ni à Échap (A39).
- **Après le choix** (3 s, un toucher passe, aucun compte à rebours affiché) : le bouton choisi reçoit un **tampon** « CHOISI » (encre, incliné en escalier), l'autre passe à 40 % ; la zone du texte laisse place à la ligne de conséquence (Atkinson 24, italique), par exemple « Placés au Livret A au taux d'aujourd'hui (6,5 %), ces 9 000 F feraient environ 11 900 F fin 1988. » ; en bas à droite, « Toucher pour continuer › » en secondaire.

**Téléphone** : carte à 94 % de la largeur du rectangle libre, portrait 48 × 48 ×2, titre Pixelify 32, texte Atkinson 22, boutons côte à côte (le paysage le permet), chacun ≥ 96 dp de haut ; « Disponible… » sur une ligne, sinon tronqué au mot « Disponible : 23 400 F ».

**Pictos d'humeur 16 × 16** (boutons, étiquette de la maison, « Mon foyer ») : tête de Sylvie (même coiffure brune, pull moutarde), seules 3 lignes changent ; forme lisible sans couleur. Base (`h` cheveux bois, `p` peau, `o` peau ombre, `k` encre, `r` joue tuile, `j` pull or) :
```
....hhhhhhhh....
..hhhhhhhhhhhh..
.hhhhhhhhhhhhhh.
.hhhpppppppphhh.
hhhpppppppppphhh
hhpp[sourcils]hh   ligne 5   (variable)
hhpp[ yeux   ]hh   lignes 6-7 (variable)
hhppppppoppppphh
hhpp[bouche ]hh    lignes 9-10 (variable)
.hhpppppppppphh.
.hhhpppppppphhh.
hhhh.poooop.hhhh
.hhjjjjjjjjjjhh.
jjjjjjjjjjjjjjjj
```
| Ligne | ☺ contente | ☐ neutre | ☹ fâchée |
|---|---|---|---|
| 5 | `hhpppppppppppphh` (sourcils remontés dans la frange) | `hhppkkppppkkpphh` | `hhpkpppppppkpphh` + ligne 4 `hhhkpppppppkphhh` → V |
| 6 | `hhppkkppppkkpphh` | `hhppkkppppkkpphh` | `hhppooppppoopphh` (paupières) |
| 7 | `hhpkppkppkppkphh` (yeux en ^) | `hhppkkppppkkpphh` | `hhppkkppppkkpphh` |
| 9 | `hhrpkppppppkprhh` | `hhpppppppppppphh` | `hhppppkkkkpppphh` |
| 10 | `hhpppkkkkkkppphh` | `hhppppkkkkpppphh` | `hhpppkppppkppphh` |

### 4.2 Sylvie à la fenêtre : 3 humeurs (base PX0 `personnages.gd`, buste 27 × 32, grille 960 × 540)

Le visage seul ne suffit pas : à ×1 (téléphone, 720p) le buste fait 32 px physiques, environ 3 mm. Chaque humeur a donc **trois indices** : visage, **posture**, **fenêtre**, plus le picto d'humeur dans l'étiquette de la maison (couche interface, toujours lisible).

| | Contente (0) | Neutre (1, défaut) | Fâchée (2) |
|---|---|---|---|
| Visage (lignes y 8 à 18) | sourcils hauts arqués (y 8-9), **yeux en ^** (y 11 : x 10 et 16 ; y 12 : x 9, 11, 15, 17), joues `tuile` 2 × 1 (y 14), grand sourire (coins y 16, x 10 et 16 ; y 17 x 11-15 ; y 18 x 12-14 `tuile`) | actuel : sourcils droits y 9, yeux 2 × 2, bouche droite y 17 | sourcils en V (actuel), paupières `peau_ombre` sur y 11, pupilles **décalées d'1 px vers l'extérieur de la maison** (elle regarde ailleurs), bouche en arc tombant (actuel) |
| Posture | coudes sur l'appui, **une main fait coucou** toutes les 8 s réelles (2 images, 0,5 s) | mains jointes sur l'appui (actuel) | **bras croisés hauts** (bande du pull remontée de 2 px, mains cachées), épaules +1 px |
| Fenêtre | les deux rideaux ouverts, **pot de géraniums** sur l'appui | rideaux ouverts | **rideau gauche tiré à moitié** (crème, plis 1 px), pas de fleurs |
| Clignement | aucun (yeux déjà fermés en ^) | toutes les 3 à 5 s | toutes les 3 à 5 s |

- Changement d'état : clignement, puis la nouvelle image ; en même temps la bulle de docs/15 §2.1 (4 s) et le picto de l'étiquette « MA MAISON » saute d'1 texel. Pas de transition si l'état ne change pas.
- Les traces P10 à la fenêtre de Sylvie (berceau, lampe hi-fi, diplôme) se posent **sur l'appui à droite** : le côté gauche reste aux rideaux et aux fleurs, pour qu'on ne les confonde pas.

### 4.3 La jauge de projet (attachée à l'étiquette de la maison)

Les chiffres restent nets (principe 14) : la jauge est une **pièce d'interface** collée sous l'étiquette « MA MAISON », sur la chaussée ; elle suit la maison et devient une flèche de bord avec elle.
```
                ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
                ▓  MA MAISON   [☺]   ▓                 ← étiquette (picto d'humeur)
  ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
  ▓ [auto] LA SUPER 5 · AVRIL 1986 · dans 14 mois      ▓   ← Pixelify 28 / Atkinson 20
  ▓ ████████████████▒▒▒▒▒▒░░░░░░░░░░░░│ 30 000 F    ▓   ← 360 × 24 px
  ▓ 21 400 F sans rien vendre  ·  ▒ + 4 100 F placés ▓   ← Atkinson 20
  └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
- Segment plein **ambre** = disponible (compte + Livret A) ; segment **hachuré en marches** (ambre sur fond) = placements revendables (valeur nette) ; vide `ardoise_sombre` ; trait encre vertical = objectif. Les deux segments se distinguent par le motif, pas par la teinte.
- Icône du projet 16 × 16 (canapé, valise, voiture, break, clé du T3). Quand le disponible atteint l'objectif : la jauge est pleine et un **✓** sprite s'ajoute à droite, sans texte d'incitation.
- Rappel à 3 mois : la jauge saute d'1 texel 2 fois avec la notification. Échéance : la carte « Le jour J » sort de la porte comme un dilemme.
- **Téléphone** : une seule ligne (icône + barre 240 px + « 21 400 / 30 000 F ») ; le nom et la date passent dans « Mon foyer ». Toucher la jauge ou l'étiquette = ouvrir « Mon foyer » (cible ≥ 48 dp : jauge et étiquette forment un seul bouton).
- Aucun projet en cours : la jauge disparaît.

### 4.4 La fenêtre « Mon foyer » (la porte du frigo)

Ouverte par la maison (toucher, étiquette, jauge). Remplace l'actuelle `info` « MON FOYER ». Même grammaire de papier que les dilemmes : un panneau crème où les éléments sont **aimantés**.

**PC** (1 280 × 760 px virtuels)
```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓[×]┐
▌ MON FOYER · GÉRARD                                                             JUILLET 1987   ▌
▌ ┌──────┐ Sylvie est contente.                 │ PROJET EN COURS                               ▌
▌ │Sylvie│ « L'île de Ré, c'était parfait ! »   │ [auto] LE BREAK FAMILIAL · février 1988          ▌
▌ │48×48 │  (dernière cause, ≤ 10 mots)          │ ██████████▒▒▒▒░░░░░░░░░░░░░░│ 40 000 F         ▌
▌ └──────┘                                      │ 18 300 F sans rien vendre · ▒ + 9 800 F placés ▌
▌ LE FOYER                                      │ Il manque 21 700 F sans rien vendre.           ▌
▌ Gérard, Sylvie, Léa (2 ans)                   │                                                ▌
▌ Salaire du mois ............... 7 640 F       │ PROJETS PASSÉS                                 ▌
▌ Loyer ........ 2 300 F · Vie ... 3 900 F      │ ✓ La Super 5 · avril 1986 · 30 000 F           ▌
▌ Versements automatiques ......... 800 F       │                                                ▌
▌ Il reste chaque mois ............ 640 F       │ CARTES DU FOYER (les 4 dernières)              ▌
▌ Coussin de sécurité ........... 4,2 mois      │ ▄▀▄ Vacances 87 · L'île de Ré · − 7 000 F [☺] ▌
▌ Baguette ...................... 3,40 F        │ ▄▀▄ Le chien · SPA · − 400 F              [☺] ▌
▌                                               │ ▄▀▄ Caméscope · location · − 300 F        [☐] ▌
▌                                               │ [ TOUS LES COURRIERS DE LA MAISON › ]          ▌
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
- Humeur : portrait 48 × 48 (3 expressions, mêmes indices qu'à la fenêtre) + **une phrase** (« Sylvie est contente / Sylvie va bien / Sylvie fait la tête ») + la dernière cause en citation ; **jamais de nombre ni de jauge** (docs/15 §2.1).
- Projets passés : ✓ réalisé, ↻ réalisé après report, ✗ abandonné (symbole + mot, pas seulement la couleur).
- Cartes du foyer : pense-bêtes miniatures (aimant 8 × 8, titre, choix, montant, picto) ; le bouton du bas ouvre l'historique filtré MA MAISON (remplace « COURRIERS REÇUS › »).
- Ferme au clic extérieur, à Échap et par [×] (lecture seule, pas de choix).
- **Téléphone** : deux onglets en haut (FOYER · PROJETS ET CARTES), une colonne chacun, sans défilement à 1 600 × 720 ; portrait ×2.

### 4.5 Source `rue` dans l'historique (docs/15 §8, pour mémoire)
Onglet dédié **LA RUE** (déjà prévu en 16 §3.3), icône 16 × 16 « plaque de rue bleue ». Liseré « vert » de 16 §3.3 : si le seul vert des 40 couleurs d'interface est `gain`, prendre plutôt **`sarcelle`**, pour ne pas faire lire un gain.

---

## 5. Où des illustrations aideraient le plus (vague 3)
1. Portraits 48 × 48 de Sylvie en 3 humeurs (cartes, « Mon foyer », écran de fin) : c'est l'image la plus regardée de la vague.
2. Les 6 icônes de projet en 32 × 32 pour la carte de choix et « Le jour J ».

## 6. Questions ouvertes
| # | Question | Pour |
|---|---|---|
| Q1 | Retour automatique de la caméra à la maison après 10 s sans toucher quand le temps tourne (§3.1) ? | Chef de projet (écart à `lot_px1`) |
| Q2 | Couleur de la source `rue` dans les 40 couleurs d'interface (§4.5) | dev-interface |
| Q3 | Drapeau « bulle COURRIER déjà vue » : dans la sauvegarde ou dans un réglage local ? | Chef de projet |
