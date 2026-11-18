# 43 : UX de la carrière simplifiée (où se passe le travail, carte de choix, retour visuel, temps libre, bilan)

> Auteur : UX designer, 2026-11-18. Statut : **exploration**, rien n'est décidé ni développé (docs/lots/decisions_extension_annees.md, dernière entrée).
> Source : retour verbatim du joueur, docs/10 « 2026-11-18 (carrière simplifiée) » : « opportunité de changer de travail, peut-être payer moins mais avec plus de temps ou vice-versa… quelque chose d'agréable à jouer ».
> S'appuie sur : docs/17 §4.1 (carte de dilemme), §4.4 (« Mon foyer »), docs/40 §1.1 (frise), §2 (bilan final), docs/39 §2.2 et §3 (promotion CNAM, préretraite de Michel : précédents de choix « temps contre revenu »), docs/16 et §9 (grilles, polices, palette).
> Le contenu (quels métiers, quels montants, quelle fréquence, quel effet du temps libre) appartient au **game designer** (docs/44) et au **banquier** (réalisme des salaires, temps partiel, trajets). Les exemples chiffrés ci-dessous ne servent qu'à dimensionner les maquettes.

---

## 0. En bref

1. **Le travail se passe hors champ, à gauche de la rue** : on ne crée pas de 4e bâtiment. Gérard **part le matin et rentre le soir** par le bord gauche, avec un moyen de transport qui dit son métier (bus, R5, vélo). Un **panneau de direction** en bord de décor porte le nom de l'employeur. Coût M (dev-ville), facultatif.
2. **La carte de carrière est une lettre à en-tête**, pas un pense-bête : elle sort de la **boîte aux lettres** de la maison (source maison, filtre MA MAISON de l'historique), sur papier blanc bleuté avec un liseré « bleu de travail ». Même grammaire que le dilemme : on lit, on choisit, un tampon.
3. **2 ou 3 colonnes, 4 lignes chacune, toujours dans le même ordre** : Salaire / mois · Mis de côté / mois · Temps libre · Sylvie. Deltas avec ▲▼ et signe, temps libre en **3 cases + un mot**, Sylvie en **picto d'humeur existant**. Aucune jauge.
4. **Une option « Rester comme ça » existe toujours** et a le même style que les autres (principe 11).
5. **Temps libre** (si le game designer le retient) : **3 niveaux** (Peu · Normal · Beaucoup), jamais un nombre. Visible dans « Mon foyer », sur la carte, et dans la rue par le rythme de Gérard (rentre tard / bricole le samedi).
6. **Après le choix** : tampon (existant), ligne de conséquence, puis 2 petits retours dans le monde (Gérard change de transport, le panneau change de nom) et une ligne dans l'historique. **Pas de marqueur sur la frise** (elle ne porte que le marché et les nouveautés).
7. **Bilan final** : une ligne « Carrière » dans le bloc LE FOYER + une **mini-frise des métiers** dans la zone de détail. Jamais noté (pas de titre ni d'étoile liés au choix), comme la préretraite de Michel.
8. **Variante minimale (XS-S)** : la carte de dilemme actuelle telle quelle, 2 boutons, montant mensuel au lieu d'un montant unique, picto de Sylvie, une ligne « Métier » dans « Mon foyer ». Rien dans la rue.

---

## 1. Où se « passe » le travail dans la ville

### 1.1 Trois options comparées

| Option | Ce qu'on voit | Pour | Contre | Coût |
|---|---|---|---|---|
| **A. Hors champ, par le bord gauche (recommandée)** | Gérard sort de chez lui le matin, marche vers la gauche (arrêt de bus, sa voiture ou son vélo), disparaît ; revient au crépuscule. Panneau de direction en bord de décor : « ZI DE VÉLIZY → THOMSON » (nom fictif à fixer). | Réutilise la marche (4 images) et le cycle de 60 s réel ; dit « il travaille ailleurs » sans encombrer la rue ; aucune nouvelle cible de toucher | La carte de carrière n'a pas de bâtiment-source propre | M |
| B. 4e bâtiment « L'usine / le bureau » | Une façade de plus, cliquable, étiquette « MON TRAVAIL » | Un lieu par type de message, très lisible | Un bâtiment qui ne sert qu'une fois tous les 2 à 5 ans = façade morte ; rue déjà plus large que l'écran ; nouvelle flèche de bord ; le métier change de lieu à chaque changement de poste (plusieurs façades) | L |
| C. Rien dans la rue | Tout passe par la carte et « Mon foyer » | Gratuit | Le joueur ne « sent » pas la carrière | XS |

**Recommandation : A**, et **C pour la variante minimale**. B reste la piste U5 (« employeur comme bâtiment jouable ») à rouvrir seulement si la carrière devient un système riche (formation, primes, PEE, chômage) au décor 1994-2003.

### 1.2 Le trajet de Gérard (option A, dev-ville)

Cycle d'ambiance **en temps réel** (60 s, indépendant de la vitesse du jeu, figé en pause, docs/09 §2.4) ; rien de tout cela n'est une information nécessaire (principe 14).

| Moment du cycle | Gérard | Variante selon le temps libre (§4) |
|---|---|---|
| Aube (≈ 0-5 s) | la porte s'ouvre (3 images existantes), Gérard sort, marche vers la gauche à 8 im/s, sort du champ en ≈ 3 s | **Peu** : il sort **avant** l'aube (ciel encore nuit) avec une mallette |
| Journée | absent ; sa fenêtre est éteinte | **Beaucoup** : 1 cycle sur 3, il **ne part pas** (jour libre) : il bricole devant la maison (2 images, marteau) ou lave la voiture |
| Crépuscule (≈ 40-45 s) | revient par la gauche, entre ; sa fenêtre s'allume | **Peu** : revient **à la nuit**, sa fenêtre s'allume plus tard que les autres |

- **Moyen de transport = indice du métier**, trois sprites au plus : à pied jusqu'à l'**arrêt de bus** (poteau RATP 6 × 40 au bord gauche, existant ou à ajouter), **R5** garée devant la maison (existante), **vélo** (16 × 10, 2 images). Un changement de poste peut changer de transport (« le nouveau poste est loin : la R5 »).
- **Panneau de direction** au bord gauche (décor, 48 × 12 texels, plaque blanche à liseré, flèche) : nom du lieu de travail en police à points existante. Il change au changement d'employeur. Aucun texte nécessaire n'y est écrit seulement là : le nom figure aussi dans « Mon foyer ».
- Pendant le saut COURRIER, le cycle continue en temps réel : rien à faire.
- Profils (docs/39 §3) : même mécanique pour Christine, Sophie, Michel (sprite du profil) ; après une préretraite, Michel **ne part plus** : il jardine (même animation que « jour libre »). C'est la meilleure mise en scène de « temps libre contre revenu ».

---

## 2. La carte de choix de carrière

### 2.1 Sortie (≤ 1 s, passable d'un toucher)

Variante du dilemme (docs/17 §4.1), pour qu'on reconnaisse la famille et qu'on sente la différence :

1. La caméra montre la maison si elle est hors champ (règle existante `aller_vers("maison")`).
2. **Le drapeau de la boîte aux lettres se lève** (2 images, monde) au lieu de la porte qui s'ouvre. Si l'option A est faite et que c'est le soir : Gérard rentre avec l'enveloppe à la main (facultatif).
3. Une **enveloppe 12 × 8 texels** (UI, papier blanc bleuté, coin replié) vole de la boîte au centre (0,35 s, arc), s'ouvre (3 images : rabat fermé, rabat levé, lettre qui sort) et la carte se **déplie** en hauteur en 3 images (découpe, sans mise à l'échelle, règle 21).
4. Pas d'aimant rouge : à la place, un **trombone** 6 × 12 texels sur le bord haut (signe « courrier officiel », forme lisible sans couleur).

| Élément | Dilemme du foyer | Carte de carrière |
|---|---|---|
| Support | pense-bête crème, aimant rouge | **lettre à en-tête**, papier blanc bleuté (`papier_froid`, à prendre dans les 40 couleurs d'interface ; sinon crème + liseré seul), trombone |
| Liseré gauche | tuile (source maison) | **bleu de travail** (bleu ardoise de la palette, distinct du gel) ; source toujours MA MAISON dans l'historique |
| Picto de source 16 × 16 | maison | **mallette** (poignée, fermoir ; forme seule lisible) |
| Portrait | Sylvie 48 × 48 | **le personnage joué** 48 × 48 (Gérard, Christine…), ou le futur patron si le game designer le veut (illustration utile, §8) |

### 2.2 Les 4 lignes de conséquence (le cœur de la carte)

Chaque option est **une colonne cliquable entière** (un seul bouton, pas de sous-cible). Les lignes sont **toujours dans le même ordre**, alignées d'une colonne à l'autre, pour que l'œil compare horizontalement.

| Ligne | Contenu | Représentation (jamais la couleur seule) |
|---|---|---|
| SALAIRE / MOIS | nouveau salaire net + écart | « 9 040 F » Atkinson gras 30 ; dessous « ▲ + 1 400 F » (gain) / « ▼ − 1 760 F » (perte) / « = inchangé » (secondaire), Atkinson 22 |
| MIS DE CÔTÉ / MOIS | ce qui reste chaque mois après la vie (comme la ligne « Il reste chaque mois » de « Mon foyer ») | même forme : « 810 F » + « ▲ + 170 F ». C'est **la ligne qui relie la carrière à l'investissement** : à garder même dans la variante minimale si possible |
| TEMPS LIBRE | 3 cases + un mot (§4) | `▮▮▯ Normal` → `▮▯▯ Peu` ; si le niveau change, une petite flèche « ▮▮▯ › ▮▯▯ » |
| SYLVIE (ou le proche, ou « vous » pour le célibataire) | humeur **attendue** | picto d'humeur 16 × 16 existant (☺ ☐ ☹) + un mot (« contente », « pas d'avis », « inquiète ») |

Règles :
- **Pas de total, pas de score, pas de jauge** : le joueur arbitre lui-même entre argent et temps (c'est le jeu).
- Les montants sont **mensuels** et l'unité est écrite (« / mois »), pour ne pas confondre avec les montants uniques des dilemmes.
- Une option qui coûte une fois (formation, déménagement) l'affiche en 5e ligne facultative : « Une fois : − 3 000 F » (cuivre si ce sont des frais, sinon perte).
- **« Rester comme ça »** : toujours présente, à droite, même cadre, valeurs « = inchangé » ; c'est le choix par défaut honnête, jamais grisé ni rendu moins attirant.
- Choix non accessible (ex. formation non payable) : hachures en marches + phrase « Il manque 1 200 F… » (règle des dilemmes).
- Touches 1 / 2 / 3 ; pas de fermeture au clic extérieur ni à Échap (A39, comme le dilemme).
- Information du banquier facultative, une ligne sous les colonnes, ≤ 20 mots, sans conseil (ex. « Un salaire plus haut, c'est aussi plus de cotisations retraite. » à valider par le banquier).

### 2.3 PC 1920 × 1080 (3 options ; carte 1 242 × 651 px virtuels, centrée, fond assombri 60 %, rue figée teinte gel)

```
                                        ⊂⊃ trombone 6 × 12 t
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓⊂⊃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
█ [mallette] MA MAISON · MON TRAVAIL · MARS 1990                                (Atkinson 20, secondaire)  ▓
█ ┌────────┐  UNE PLACE CHEZ THOMSON                                            ← Pixelify 48             ▓
█ │ Gérard │  « L'ancien chef d'équipe vous appelle : ils cherchent un technicien  ← Atkinson 26, ≤ 35 mots ▓
█ │ 48×48  │    à Vélizy. Mieux payé, mais une heure de route matin et soir.       ▓
█ │  (×3)  │    Votre patron, lui, propose le 4 jours par semaine. »             ▓
█ └────────┘                                                                                               ▓
█ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐   ▓
█ ▓ 1  PARTIR CHEZ THOMSON     ▓ ▓ 2  LE 4 JOURS             ▓ ▓ 3  RESTER COMME ÇA          ▓   ▓ ← Pixelify 28
█ ▓ ─────────────────────────  ▓ ▓ ─────────────────────────  ▓ ▓ ─────────────────────────  ▓   ▓
█ ▓ SALAIRE / MOIS             ▓ ▓ SALAIRE / MOIS             ▓ ▓ SALAIRE / MOIS             ▓   ▓ ← petites capitales 20
█ ▓ 9 040 F      ▲ + 1 400 F   ▓ ▓ 5 880 F      ▼ − 1 760 F   ▓ ▓ 7 640 F      = inchangé    ▓   ▓ ← Atk. gras 30 / 22
█ ▓ MIS DE CÔTÉ / MOIS         ▓ ▓ MIS DE CÔTÉ / MOIS         ▓ ▓ MIS DE CÔTÉ / MOIS         ▓   ▓
█ ▓ 810 F        ▲ + 170 F     ▓ ▓ 0 F          ▼ − 640 F     ▓ ▓ 640 F        = inchangé    ▓   ▓
█ ▓ TEMPS LIBRE                ▓ ▓ TEMPS LIBRE                ▓ ▓ TEMPS LIBRE                ▓   ▓
█ ▓ ▮▮▯ › ▮▯▯  Peu             ▓ ▓ ▮▮▯ › ▮▮▮  Beaucoup        ▓ ▓ ▮▮▯  Normal                ▓   ▓
█ ▓ SYLVIE                     ▓ ▓ SYLVIE                     ▓ ▓ SYLVIE                     ▓   ▓
█ ▓ [☐] pas d'avis             ▓ ▓ [☺] contente               ▓ ▓ [☐] pas d'avis             ▓   ▓
█ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘   ▓
█ Aujourd'hui : 7 640 F de salaire, 640 F mis de côté chaque mois.          (Atkinson 20, secondaire)     ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
(█ = liseré bleu de travail ; montants et métiers : exemples à remplacer par docs/44 et le banquier.)
```

| Mesure (px virtuels, multiples de 3 = texel ×3 à 1080p) | Valeur |
|---|---|
| Carte | 1 242 × 651 (dilemme : 1 000 × 560) |
| Colonne d'option | 384 × 330, écart 21 ; cible entière (≫ 48 dp) |
| Budget vertical | marges 27 + en-tête 30 + titre 57 + texte 3 × 33 + 15 + colonnes 330 + 12 + ligne « Aujourd'hui » 30 + 27 ≈ **627 / 651** |
| 2 options | colonnes 573 × 330 ; la carte garde sa largeur (la lettre ne « rétrécit » pas selon le contenu) |
| Texte d'option | titre Pixelify 28 sur 2 lignes au plus (sinon raccourcir le libellé, ne jamais tronquer) |

### 2.4 Téléphone 1440 × 648 (même carte, 3 colonnes côte à côte : le paysage le permet)

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓⊂⊃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
█ [G 48×48 ×1,5] UNE PLACE CHEZ THOMSON  (Pixelify 32)        MARS 1990 (Atk. 20)    ▓
█                « L'ancien chef d'équipe vous appelle : mieux payé, une heure de    ▓
█                  route. Votre patron propose le 4 jours. »  (Atkinson 22, 2 lignes)▓
█ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ▓
█ ▓ 1 PARTIR CHEZ THOMSON  ▓ ▓ 2 LE 4 JOURS           ▓ ▓ 3 RESTER COMME ÇA      ▓ ▓ ← Pixelify 26
█ ▓ Salaire  9 040 F       ▓ ▓ Salaire  5 880 F       ▓ ▓ Salaire  7 640 F       ▓ ▓ ← Atk. gras 24
█ ▓          ▲ + 1 400 F   ▓ ▓          ▼ − 1 760 F   ▓ ▓          = inchangé    ▓ ▓ ← Atk. 20
█ ▓ De côté  810 F         ▓ ▓ De côté  0 F           ▓ ▓ De côté  640 F         ▓ ▓
█ ▓          ▲ + 170 F     ▓ ▓          ▼ − 640 F     ▓ ▓          = inchangé    ▓ ▓
█ ▓ Temps    ▮▯▯ Peu       ▓ ▓ Temps    ▮▮▮ Beaucoup  ▓ ▓ Temps    ▮▮▯ Normal    ▓ ▓
█ ▓ Sylvie   [☐] pas d'avis▓ ▓ Sylvie   [☺] contente  ▓ ▓ Sylvie   [☐] pas d'avis▓ ▓
█ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ ▓
█ Aujourd'hui : 7 640 F de salaire, 640 F de côté par mois.   (Atkinson 20)          ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

- Carte à 94 % de la largeur libre (≈ 1 350), colonnes ≈ 438 × 300 ; libellés courts à gauche (« Salaire », « De côté », « Temps », « Sylvie ») et valeurs à droite : la colonne se lit en 2 sous-colonnes, l'en-tête de ligne disparaît (gain ≈ 90 px).
- Sur téléphone, **pas de flèche « ▮▮▯ › ▮▯▯ »** : seul l'état d'arrivée est montré (le niveau actuel est dans la colonne « Rester »).
- Budget : 18 + titre 42 + texte 2 × 30 + 9 + colonnes 300 + 9 + ligne 30 + 18 ≈ **486 / 648** : il reste de la place pour la ligne du banquier et une 5e ligne « Une fois ».
- 1280 × 720 : colonnes ≈ 390 ; « pas d'avis » passe sous le picto si besoin (2 lignes, la colonne grandit de 27).

### 2.5 Après le choix (≈ 3 s, un toucher passe, aucun compte à rebours)

| Temps | Sur la carte | Dans la rue / le HUD | Coût |
|---|---|---|---|
| 0 | tampon **« SIGNÉ »** (encre, incliné en escalier ; réutilise le tampon « CHOISI », autre mot) sur la colonne choisie ; les autres passent à 40 % | — | S (existant) |
| 0,2 s | la zone du texte laisse place à **la ligne de conséquence** (Atkinson 24 italique), ex. « Dès avril : 810 F de côté chaque mois au lieu de 640 F. Sur trois ans, environ 6 100 F de plus à placer. » (calcul simple, sans taux, pas de projection de marché) | — | S |
| fermeture (toucher) | la lettre se replie et **retourne dans la boîte aux lettres** ; le drapeau s'abaisse | Sylvie change d'humeur à la fenêtre si l'humeur change (mécanisme existant : clignement, bulle 4 s, picto qui saute) | 0 |
| mois suivant, à la paie | les pièces du mois existantes montent de la maison ; **une seule fois**, l'étiquette « MA MAISON » affiche une **bulle chiffrée** « Nouveau salaire : 9 040 F ▲ » (2 s, même style que les bulles des voisins) | le nouveau transport et le panneau apparaissent au **cycle suivant** (pas de transition animée) ; si le temps libre change, le rythme de Gérard change | S (bulle) ; M (rue) |

- **Badge** : pas de nouveau badge ; l'entrée d'historique compte dans les non-lus seulement si elle a été franchie pendant un saut (règle existante).
- **Historique** (onglet MA MAISON, picto mallette) : « Mars 1990 · Une place chez Thomson · Partir chez Thomson · Salaire 9 040 F (▲ + 1 400 F) · Temps libre : peu ». Relecture en lecture seule, comme les dilemmes.
- **Frise : rien**. Elle ne porte que le marché (◆) et les nouveautés (?) (docs/40 §1.1) ; ajouter les événements de vie ferait une nouvelle catégorie de marqueurs pour un seul usage. Si un jour la frise accueille les naissances, mariage et carrière ensemble, ce sera un rang de pictos 7 × 7 t sous le rail (à concevoir alors).
- **Choix de « Rester »** : tampon « SIGNÉ » aussi (on a choisi, pas renoncé), conséquence « Rien ne change. Votre patron apprécie. » ou équivalent du game designer ; aucun retour dans la rue.

---

## 3. « Mon foyer » : ce qui change

Bloc LE FOYER de la porte du frigo (docs/17 §4.4), colonne gauche ; ajouts en **gras** ci-dessous, rien d'autre ne bouge.

```
▌ LE FOYER                                      │
▌ Gérard, Sylvie, Léa (6 ans)                   │
▌ Métier ...... technicien chez Thomson [mallette] │   ← nouvelle ligne
▌ Salaire du mois ............... 9 040 F       │
▌ Temps libre ........................ ▮▯▯ Peu  │   ← nouvelle ligne (si la ressource existe)
▌ Loyer ........ 2 300 F · Vie ... 3 900 F      │
▌ Il reste chaque mois ............ 810 F       │
```
- Colonne droite : rubrique **CARRIÈRE** (sous PROJETS PASSÉS, au-dessus des CARTES DU FOYER) : les 3 derniers changements « mars 1990 · Thomson · 9 040 F ▲ ». Si la colonne déborde, les cartes du foyer passent à 3 lignes.
- Téléphone : les deux lignes vont dans l'onglet FOYER ; CARRIÈRE dans l'onglet PROJETS ET CARTES (renommé « PROJETS, TRAVAIL, CARTES » seulement si la place le permet, sinon l'onglet garde son nom).
- Coût S.

---

## 4. Le temps libre : représentation minimale (si le game designer en fait une ressource)

**Recommandation : 3 niveaux, comme l'humeur.** Un nombre d'heures ou une jauge continue demanderait au joueur d'apprendre une unité qui ne sert qu'ici. Trois crans suffisent pour « gagner plus / avoir plus de temps ».

| Niveau | Picto 3 cases (12 × 4 texels, cases 3 × 4 séparées d'1 texel) | Mot | Dans la rue (option A) |
|---|---|---|---|
| Peu | ▮▯▯ (1 pleine, 2 en contour pointillé) | Peu | Gérard part avant l'aube, rentre à la nuit, mallette |
| Normal | ▮▮▯ | Normal | trajet du §1.2 |
| Beaucoup | ▮▮▮ | Beaucoup | 1 cycle sur 3 : il reste et bricole / jardine / joue au ballon avec l'enfant |

- Cases pleines en **crème** (`TEXTE`) à contour encre, vides en contour pointillé secondaire : pas de couleur sémantique (le temps libre n'est ni un gain ni une perte d'argent) ; **ne pas** utiliser d'étoiles (réservées aux trophées, principe 20) ni de cœurs (on confondrait avec l'humeur).
- Toujours **picto + mot** (trois indices avec la rue).
- Où on le voit : carte de carrière, « Mon foyer », historique, bilan final. **Pas dans le HUD permanent** (une info de plus en haut d'écran pour une valeur qui change tous les 2 à 5 ans serait du bruit).
- Effet de jeu (à trancher par docs/44, l'UX n'a pas d'avis tranché) : le plus lisible est de le **brancher sur ce qui existe déjà**, l'humeur de Sylvie (Peu = l'humeur baisse plus vite) ou les cartes du foyer (Beaucoup = certaines cartes gratuites, « Je repeins moi-même »). Une ressource sans effet visible serait décorative : dans ce cas, ne pas l'afficher du tout et laisser l'humeur porter le message.

---

## 5. Le bilan de carrière dans l'écran de fin

Aucun bloc nouveau : la carrière s'insère dans la grammaire de docs/40 §2.

### 5.1 PC 1920 × 1080

```
▓ │ ┌────────┐ LE FOYER                         │ ▓
▓ │ │ Sylvie │ Sylvie est contente.             │ ▓
▓ │ │ 144    │ Projets : 3 sur 4 réalisés       │ ▓
▓ │ │        │ Carrière : 7 640 F → 10 900 F ▲  │ ▓   ← nouvelle ligne (Atkinson 22)
▓ │ └────────┘ ✓ Le salon · ✓ La Super 5 …      │ ▓
...
▓ ───────────────────────────────────────────────────────────────────────────────────────────── ▓
▓ VOTRE CARRIÈRE  1984 Technicien ── 1990 Thomson (Vélizy) ── 1992 Le 4 jours ──▶ 1993        ▓  ← zone détail
▓                 temps libre :  ▮▮▯              ▮▯▯                 ▮▮▮                      ▓     Atkinson 20
▓ Frais payés : 9 870 F · Tata Livret : 0 F             Produits découverts 9/11 · utilisés 5/11 ▓
```
- **Mini-frise des métiers** : une ligne, étapes reliées par un trait, date en gras ; sous chaque étape, le picto du temps libre (si la ressource existe). 4 étapes au plus, sinon « … et 2 autres » (même règle que les projets).
- Budget : + 30 px (ligne du foyer, absorbée par la plaque) + 54 px (2 lignes de détail) : la courbe passe de 120 à **72 px** (minimum lisible, règle de docs/40 §2.4) ; au-delà, la zone détail passe dans le `Defilant` existant.
- Pas de phrase de jugement (« vous avez sacrifié… ») : les deux voies sont honnêtes. Le game designer peut ajouter **une** phrase neutre au gabarit de fin (« Moins d'argent, plus de samedis : 1 200 F de moins placés chaque année, et Sylvie contente. »).
- Les titres et étoiles **ne dépendent pas** du choix de carrière (précédent : préretraite de Michel, docs/39 §3). Exception possible à valider : une étoile « Le coussin » reste calculée sur l'épargne, ce qui reflète indirectement le salaire ; c'est voulu.

### 5.2 Téléphone 1440 × 648

- Partie fixe : la ligne « Sylvie est contente · Projets 3/4 » devient « Sylvie contente · Projets 3/4 · Salaire 7 640 → 10 900 F ▲ » (Atkinson 20) ; si elle dépasse la plaque (560 px), le salaire passe dans la zone qui défile.
- Zone qui défile : « VOTRE CARRIÈRE » en 2e rubrique (après les étoiles), mini-frise sur 2 lignes si besoin.
- Contrôle proposé pour la capture : `UI fin carriere=oui etapes=3 temps_libre=3 debordements=0 chiffres_pixelify=0`.

---

## 6. Coût d'implémentation estimé

| Écran / élément | Propriétaire probable | Taille | Commentaire |
|---|---|---|---|
| Carte de carrière 2-3 colonnes (§2.3-2.4) | dev-interface | **M** | Nouvelle disposition dans `CartePapier` ; 4 lignes alignées ; touches 1-3 ; tampon réutilisé |
| Sortie par la boîte aux lettres + enveloppe (§2.1) | dev-ville (drapeau) + dev-interface (enveloppe) | S | Variante de la sortie du dilemme ; peut rester « sortie par la porte » au départ |
| Ligne de conséquence + bulle « Nouveau salaire » (§2.5) | dev-interface | S | Gabarits de texte fournis par le game designer |
| Historique (entrée, picto mallette) | dev-logique + dev-interface | S | Source maison existante |
| « Mon foyer » : 2 lignes + rubrique CARRIÈRE (§3) | dev-interface | S | |
| Temps libre : 3 crans, picto (§4) | dev-logique (état, sauvegarde) + dev-interface (picto) | S | Le coût réel est dans la règle de jeu, pas dans l'écran |
| Bilan de fin : ligne + mini-frise (§5) | dev-interface | S | Budget vertical déjà calculé |
| Trajet de Gérard, transports, panneau (§1.2) | dev-ville | **M** | Marche existante ; 3 sprites (vélo, mallette, marteau), arrêt de bus, panneau ; variantes Peu / Beaucoup |
| 4e bâtiment « Mon travail » (option B) | dev-ville + dev-interface | **L** | Non recommandé maintenant |

Total recommandé (sans B) : **≈ 1 M + 1 M + 5 S**, soit un lot moyen réparti sur les trois développeurs, testable par étapes ciblées (carte, « Mon foyer », fin).

---

## 7. Variante minimale (réutilise la carte de dilemme existante, XS-S)

But : faire juger l'idée au joueur avant d'investir.

1. **Carte** : la carte de dilemme de docs/17 §4.1, **sans aucun changement de mise en page** : 2 boutons de 440 × 120 (« Partir chez Thomson » / « Rester »). Dans chaque bouton, la ligne du montant devient **mensuelle** : « + 1 400 F / mois » (gain, signe) ou « − 1 760 F / mois », et le picto d'humeur de Sylvie garde sa place à droite. Le texte de la carte (≤ 30 mots) dit le temps libre en mots (« une heure de route matin et soir »).
2. **Pas de ressource « temps libre »** : c'est l'humeur de Sylvie qui porte le prix du temps (le picto ☹ sur l'option « Thomson »). Mécanique déjà existante.
3. **Après le choix** : tampon « CHOISI » et ligne de conséquence existants, avec un gabarit mensuel (« 170 F de plus à mettre de côté chaque mois »).
4. **« Mon foyer »** : seule la ligne « Métier » est ajoutée ; « Salaire du mois » existe déjà et se met à jour.
5. **Historique** : entrée MA MAISON automatique (comme toute carte du foyer).
6. **Fin** : rien de neuf (la ligne « Carrière » peut venir ensuite).
7. Pour 3 options (« le 4 jours ») : la variante minimale reste à 2 boutons ; on peut enchaîner deux cartes (« Thomson ou rester ? » en 1990, « le 4 jours ? » en 1992) plutôt qu'élargir la carte.

Coût : **XS à S** (données de cartes + un gabarit de montant mensuel + une ligne de « Mon foyer »). Ce qui manque par rapport à la version complète : la comparaison sur 4 lignes et la carrière « visible » dans la rue.

---

## 8. Où des illustrations apporteraient le plus

1. **Le portrait du personnage 48 × 48 en tenue de travail** (bleu, blouse, costume) : il dit le métier mieux que le texte ; une variante par grand métier.
2. **Le moment où Gérard rentre le soir** (silhouette au crépuscule, mallette) : une petite vignette pour la carte, plus forte qu'une icône.
3. L'en-tête de lettre de chaque employeur fictif (logo de 32 × 16 texels) : cheap, mais donne de la personnalité.

---

## 9. Questions ouvertes

| # | Question | Pour |
|---|---|---|
| C1 | Temps libre : ressource à 3 crans branchée sur l'humeur / les cartes, ou rien (l'humeur suffit) ? | Game designer (docs/44), client |
| C2 | Fréquence : au plus une carte de carrière par chapitre (+ les scriptées comme la promotion CNAM) ? Ne pas tomber le même mois qu'une carte du foyer | Game designer |
| C3 | 2 ou 3 options par carte (la complète en permet 3 ; la minimale 2) | Client, après essai de la minimale |
| C4 | Option A (trajet de Gérard) dans le même lot que la carte, ou plus tard avec le peaufinage ? | Chef de projet |
| C5 | Réalisme : temps partiel (« 4 jours ») accessible à un technicien du privé en 1990-1993 ? Montants nets, trajets | Banquier |
| C6 | La promotion CNAM (docs/39 §2.2, sans choix) passe-t-elle dans le même habillage (lettre, mallette, ligne « Métier ») ? Recommandé : oui, sans colonnes (simple lettre + bulle de salaire) | Game designer, chef de projet |
| C7 | Couleur du liseré « bleu de travail » et du papier froid : à prendre dans les 40 couleurs d'interface existantes (sinon crème + liseré seul) | dev-interface |
