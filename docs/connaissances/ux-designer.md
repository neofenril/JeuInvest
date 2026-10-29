# Base de connaissances : UX designer

> À lire au début de chaque mission (après `CLAUDE.md`), à mettre à jour à la fin. Garder entre 100 et 200 lignes : remplacer ce qui est obsolète au lieu d'empiler.
> Documents de référence : `docs/04_ux_design.md` (logique des écrans, V1 web), `docs/09_direction_artistique_godot.md` (ville, game feel, mise en page Godot), **`docs/16_bible_graphique_pixel.md` (nouvelle direction pixel art, en attente de validation du joueur ; une fois validée, elle remplace 09 pour tout le visuel)**, `docs/13_ux_progression_banquier.md` (banquier, frais, Tata Livret), `docs/15_spec_game_design_v3.md` (V3 : voisins, Sylvie, cartes, projets, Lundi noir, fin). Arbitrages du client : `docs/connaissances/client.md`.

---

## 1. Principes retenus (valables quel que soit le moteur)

1. **Le temps est le héros** : date, contrôles du temps et frise toujours visibles.
2. **Un lieu par type de message** : maison = vie, banque = banquier, Gazette = news, la rue = voisins. Le joueur sait d'où vient un événement avant de lire.
3. **Une notion = un moment** : une notion n'apparaît que quand elle sert.
4. **Tout chiffre qui bouge se voit** : il roule, il clignote, il porte ▲/▼ et +/−. Jamais la couleur seule.
5. **Le spectacle ne casse pas le rythme** : animation de bâtiment ≤ 2 s, passable d'un toucher ; lecture jeu en pause, jamais chronométrée.
6. **On ne révèle jamais l'avenir** (pas de marqueur futur, A5).
7. **Le banquier informe, ne conseille jamais** (A33).
8. **Une seule vedette à la fois** : file des effets majeurs.
9. **Tactile d'abord** : rien d'indispensable au survol ; cibles de 80 px virtuels (≈ 49 dp) au minimum.
10. **Lisible avant d'être joli** : couleurs sémantiques (gain, perte, or, cuivre, gel) et disposition ne changent jamais.
11. **Ne pas pousser au clic** : « Ouvrir » et « Pas maintenant » ont le même style.
12. **Les frais sans culpabiliser** : cuivre `#C77B4A`, jamais le rouge des pertes.
13. **Comparer au choix du débutant** : référence permanente « tout au Livret A » (Tata Livret).
14. **Le monde en pixels, les chiffres en net** (16) : aucune information nécessaire n'est seulement dans la ville ; montants et textes longs en police nette.

---

## 2. Ce qui reste valable de la V1 web (04)

| Section de 04 | Statut |
|---|---|
| §1, §2 parcours | Valables (sauf 3 colonnes) |
| §3.1 Écran titre | Remplacé : la rue au crépuscule, logo néon sur le toit de la Gazette |
| §3.2 Création de partie | Valable (hors démo) |
| §3.3 Écran principal | Contenu et états valables ; disposition : 09 §4 |
| §3.4 Marché | Contenu valable ; devenu le guichet de la fenêtre Banque (13 §2) |
| §3.5 Journal, §3.6 Courrier | Grammaire valable ; précédés de l'animation du bâtiment |
| §3.7 à §3.11, §4 Frise, §5 Onboarding | Valables |
| §6 Animations, §7 Direction artistique | Remplacés par 09 puis 16 |
| §7.5 Accessibilité, §7.6 Graphiques | Valables (axe depuis 0, 4 graduations, pas de chandeliers) |

---

## 3. Retours du joueur réel

| Date | Retour | Conséquence |
|---|---|---|
| 2026-10 | « Graphisme insuffisant… je veux beaucoup plus poussé. » ; « Je veux une version mobile. » | Rendu jugé dès la 1re livraison ; Godot ; tout au toucher. |
| 2026-10-26 | Ville en fond : maison, banque (appel animé), média (animation par news). Paysage seul (A35). | Rue en diorama + HUD ; 3 bâtiments-sources. |
| 2026-10-26 | Après la démo 1 : temps trop rapide ; banquier didactique apprécié ; clic extérieur pour fermer. | 8 s par mois ; banquier seul canal des produits (A37). |
| 2026-10-27 | Patrimoine vs « tout au Livret A » ; frais parlants ; naissance, crash ; démo 1984-1988 validée. | Tata Livret permanent ; pédagogie des frais ; doc 13. |
| 2026-10-27 | Historique des pop-ups ; héritage confus ; versements mensuels. | Historique (filtres par source) ; un seul pot ; versements auto. |
| 2026-10-28 | « On s'ennuie un peu. » | Game designer, docs 14 et 15. |
| 2026-10-29 | P1-P6, P9, P10 retenues ; classement de la rue **affiché en permanence** ; titres conservés d'une partie à l'autre. | Bloc « La rue » permanent (16 §5.2). |
| 2026-10-29 | « La vue de face est pas mal mais le style est trop **générique** » ; références : rue en pixel art (Dreamstime, référence seulement) et personnage chibi pixel. **Modifier les graphismes avant d'aller plus loin.** | docs/16 : pixel art 640 × 360, palette de 40 couleurs, interface en cadres pixel, preuve de concept avant migration. |

---

## 4. Direction artistique (16, en attente de validation)

- **Grille** : ville rendue dans un `SubViewport` de ≈ 360 px d'art de haut (640 de large en 16:9, jusqu'à 800 en 20:9), agrandie d'un **facteur entier N** en pixels physiques (×2 sur 720p, ×3 sur 1080p, ×4 sur 1440p) ; affichée par un `TextureRect` Nearest de taille `physique / facteur_interface` pour annuler le 1,7 du téléphone. Zone utile 448 × 232 px d'art. Caméra et objets arrondis au pixel ; zoom entier au repos.
- **Échelle** : figurine 16 × 28 (2,5 têtes) ; portraits 32 × 32 (bulles, classement) et 48 × 48 (cartes) ; maison 96 × 124, Gazette 112 × 216, banque 128 × 150 ; R5 48 × 20 (véhicules raccourcis).
- **Palette « Rue 84 »** : 34 couleurs de monde + 6 d'interface, chacune avec variante nuit et orage (substitution précalculée, fondu de 3 s) ; émissives inchangées la nuit. Panneaux du HUD `#2D2840` (remplace `#161E2E`), texte crème `#F3E9D2`, secondaire `#9C98A6` ; gain, perte, or, cuivre, gel, ambre inchangés ; papier : gain `#1B6E3E`, perte `#B3261E`.
- **Règles** : lumière en haut à gauche ; contour teinté pour les bâtiments, encre `#1C1626` pour personnages et objets ; 3 tons + 1 reflet par matière ; pas de dégradé lisse dans le monde (ciel en bandes tramées Bayer) ; tramage réservé au ciel et à la vignette du journal.
- **Animations** : marche 4 images à 8 im/s, repos 2, parler 2, réaction 2 ; portraits clignement 2 et bouche 2 ; pièces 4 ; combiné 3 ; horloge 8.
- **Rue française 1984** : maison de Gérard en **meulière** ; la Gazette devient un **immeuble de presse en pierre** (rotatives en vitrine, journal lumineux sur le toit) ; banque à colonnes et horloge ; haussmanniens à toits de zinc ; café-tabac (carotte), pharmacie (croix verte), kiosque 3615, cabine, plaque de rue bleue, colonne Morris ; R5, 4L, 205, 2CV, Porsche 944 de Jean-Mi.
- **Interface** : « cadres pixel, contenu net » : 9-patch (`StyleBoxTexture`, Nearest, texel ×3 virtuels) ; cartes du banquier, dilemmes, courrier sur **papier** crème ; historique en classeur à onglets ; graphiques restent lisses.
- **Polices proposées (OFL, Google Fonts, non téléchargées)** : Pixelify Sans (titres ≥ 28 px virtuels), Atkinson Hyperlegible Next (chiffres, textes longs ; `tnum` à vérifier), Doto ou VT323 (LED, Minitel) ; option Jersey 10 pour la date et le patrimoine. Embarquées dans `godot/polices/`.
- **Classement permanent** : PC, bloc « LA RUE » en haut à gauche (4 lignes, portrait, nom, patrimoine, Tata soulignée) ; téléphone, ruban de 4 portraits classés ; jamais devant un bâtiment jouable ; notifications en dessous.
- **Provenance recommandée** : tout en code (grilles de texte en données + générateurs de façades + contrôle de palette) ; packs seulement comme références (aucun pack « rue française 80 », les mélanger referait du générique) ; portraits, vignettes du journal et écran titre fournis plus tard par le joueur (IA ou graphiste) selon le cahier des charges de 16 §4.3.
- **Migration** : PX0 preuve de concept (scène à part, fichiers neufs : maison + Gérard + Sylvie + bout de rue + HUD + carte du banquier), puis PX1 la rue (dev-ville) et PX2 l'interface (dev-interface) en parallèle ; logique non retardée ; plus aucun nouveau dessin vectoriel.

Ce qui reste valable de 09 : intention (un lieu par message), ville qui vit (cycle de 60 s réel, saisons, trafic, pause gelée), époque par tables, les 10 effets, mise en page adaptative (base 1 920 × 1 080, facteur 1,7 téléphone, zone 1 410 × 635, F10).

---

## 5. Décisions techniques de présentation (Godot)

- Base **1 920 × 1 080**, `canvas_items`, `expand`, paysage verrouillé. Facteur `content_scale_factor` : PC 1,0 ; téléphone 1,7 ; tablette 1,25. Tenir de 1 410 × 635 à 1 920 × 1 200. Test : `F10`.
- HUD, effets, modales, transitions en `CanvasLayer` 1, 2, 5, 10. Compatibility, `CPUParticles2D`, lueurs dessinées.
- **Ville pixel** : `SubViewport` (snap 2D activé, filtre Nearest) ; ne **pas** utiliser `SubViewportContainer.stretch_shrink` dans l'espace virtuel (multiplié par 1,7 → pixels irréguliers). API de `ville.gd` et `batiment.gd` à conserver (`cadrer`, `viser`, `position_ecran`, `ecran_batiment`, `contient`…).
- Thème centralisé dans `godot/scripts/ui/style.gd` (couleurs, polices `SystemFont`, `StyleBoxFlat`) : la migration de l'interface passe par lui en gardant les noms de fonctions.
- Code de la ville : `godot/scripts/ville/` (ville, rue, plan_fond, batiment, maison, banque, media, passant, voiture, reverbere, accessoire, dessin) ; ciel : `godot/shaders/ciel.gdshader`.

---

## 6. Démos

- **Démo 1** (2026-10-26) : sept. 1986 → déc. 1988.
- **Démo V2** (livrée 2026-10-27) : janv. 1984 → déc. 1988, Gérard et Sylvie (non mariés), naissance 1985 (jumeaux 1 fois sur 4), héritage 1988, 9 produits présentés par M. Lefranc, historique, versements automatiques.
- **V3 en préparation** (docs/15) : P4 (bouton « Jusqu'au prochain courrier », pièces du mois), P2 (dilemmes, humeur de Sylvie), P1 (projets), P3 + P9 (voisins, classement, bulles, kiosque), P6 (Lundi noir, un an après), P5 allégée (rang, titre), P10 (maison qui évolue). Visuels à faire directement en pixel.

---

## 7. Erreurs à ne pas refaire

- **Avoir conçu un tableau de bord d'application** : toujours partir d'une scène et d'un lieu.
- **Avoir traité le mobile en bonus** : concevoir pour 1 410 × 635 dès le départ.
- **Supposer les polices Windows partout** : embarquer des polices OFL (prévu en 16).
- **Lier un cycle visuel rapide à la vitesse du jeu** : cycles d'ambiance en temps réel.
- **Écrire un document avant d'avoir la vision du joueur** : demander tôt une image mentale ou des références.
- **Un style « propre » sans matière ni caractère paraît générique** (ville vectorielle en aplats, 2026-10-29) : le joueur veut de la texture (briques, ardoises), des visages et des objets d'époque reconnaissables. Toujours ajouter des éléments **spécifiques** (français, datés) et un élément signature par bâtiment.
- **Proposer une grille plus fine sans vérifier les téléphones 720p** : toute grille pixel doit tomber sur un facteur entier ≥ 2 en 720p, 1080p et 1440p.
- Les pages itch.io refusent la lecture automatique (403) : licences des packs vérifiées seulement par recherche ; le noter.

---

## 8. Points ouverts

| # | Question | Pour qui |
|---|---|---|
| G1 | Provenance des images : tout en code + portraits et vignettes fournis plus tard (IA ou graphiste) ? outil ou budget ? (16 §7 q1) | Joueur |
| G2 | Interface habillée en pixel (cadres, titres) avec chiffres nets, ou seulement la ville ? (16 §7 q2) | Joueur |
| G3 | Personnages petits dans la rue + grands portraits, ou personnages plus grands dans la rue ? (16 §7 q3) | Joueur |
| G4 | Lisibilité du visage de Sylvie à la fenêtre à ×3 ; Jersey 10 contre Atkinson pour la date et le patrimoine ; accents de Pixelify et Doto | Preuve de concept PX0 |
| U1 | Sons à 60 % par défaut avec bouton muet | Client |
| U3 | Bruitages CC0 (une quinzaine) | Joueur |
| U4 | Tutoriel rejoué à travers les bâtiments | UX, plus tard |
| U5 | Employeur et Bourse comme bâtiments jouables | UX, client |
| U6 | 3e pile de F01 pour l'action et l'assurance-vie | Banquier |

(O9 « style A, B ou C » est clos : le joueur garde la vue de face, en pixel art. U2 clos : M. Lefranc. U7 appliqué : frais en 5e ligne.)

---

## 9. Journal des missions

| Date | Mission | Résultat |
|---|---|---|
| (avant 2026-10) | Design UX de la V1 web | `docs/04_ux_design.md` |
| 2026-10-26 | Direction artistique Godot | `docs/09`, réécrit le jour même (ville, paysage, tranche 1986-1988) |
| 2026-10-27 | Progression par le banquier, frais, Livret A | `docs/13` |
| 2026-10-29 | Bible graphique pixel art (style jugé « générique ») | `docs/16_bible_graphique_pixel.md` : lecture des références, grille 640 × 360 à facteur entier, palette de 40 couleurs (jour, nuit, orage), échelle, animations, interface en cadres pixel et polices OFL, comparaison des 3 provenances (recommandation : code d'abord, packs en référence, portraits fournis plus tard), maquettes (rue, classement permanent, carte du banquier, journal du krach), migration PX0 / PX1 / PX2, 3 questions au joueur |
