# JeuClaude : design UX / UI

> Document rédigé par le UX designer. Il traduit la vision du client (`00_vision_client.md`) en écrans, en rythme, en feedbacks et en direction artistique.
> Au moment de la rédaction, `01_enveloppes_france.md` (banquier) et `02_rouages_bourse.md` (boursier) n'existent pas encore. Tous les chiffres d'exemple (prix, taux, baisses) sont donc **indicatifs** et marqués *[à valider]* quand ils dépendent de ces experts.
> Contrainte technique retenue : HTML, CSS et JavaScript purs, ouverts par double-clic, hors ligne, sans bibliothèque. Graphiques en SVG, confettis en canvas, animations en CSS.

---

## 0. Cinq principes qui guident tous les écrans

1. **Le temps est le héros.** La frise et la date sont toujours visibles, en haut. Tout le reste en découle.
2. **Un seul écran de jeu.** Trois colonnes : *Mon mois*, *Mon patrimoine*, *Mes placements*. Rien n'est caché à plus d'un clic. Le marché s'ouvre dans un tiroir latéral, pas sur un autre écran : la frise reste visible.
3. **Une notion = un moment.** Une notion n'apparaît que lorsqu'elle sert : l'inflation quand la baguette augmente, le dividende quand il tombe, l'épargne de précaution quand la voiture casse.
4. **Tout chiffre qui bouge se voit.** Il défile, il clignote en vert ou en rouge, et il porte toujours une flèche et un signe.
5. **Lisible avant d'être joli.** L'époque se ressent dans le journal, la monnaie et la couleur d'accent. Les boutons, les tableaux et les graphiques restent stables d'une décennie à l'autre.

**Résolution cible** : 1366 × 768 (le portable Windows le plus courant) et 1920 × 1080. Minimum confortable : 1280 × 720. En dessous de 1100 px de large, les trois colonnes s'empilent (cas non optimisé en V1). Tout est dimensionné en `rem` pour que l'option « Texte plus grand » fonctionne partout.

---

## 1. Réponses aux questions du client

### Q1. Frise, patrimoine et actions sur un seul écran, sans submerger un débutant ?

- **Une hiérarchie en trois étages.** En haut, une barre fixe porte la date, les contrôles du temps et les deux seuls chiffres qui comptent (compte courant et patrimoine total). Juste en dessous, la frise occupe toute la largeur. En bas, trois colonnes de lecture gauche → droite : *ce qui entre et sort ce mois-ci* → *ce que j'ai* → *ce que je peux faire*.
- **L'affichage progressif.** Au premier mois, le joueur voit seulement le compte courant, son budget et le livret A. Les autres placements « s'allument » pendant le tutoriel puis au fil des déblocages historiques. Il n'y a jamais plus de 7 lignes de placements, puisque le client plafonne la liste à 5 à 7 produits.
- **Le marché dans un tiroir.** Acheter, vendre et programmer un versement se fait dans un panneau qui glisse depuis la droite et met le jeu en pause. L'écran principal reste un tableau de bord, pas une salle de marché.
- **Pas de camembert sur l'écran principal**, mais une **barre de répartition horizontale** (voir § 3.3) : elle prend une ligne au lieu d'un carré, se lit mieux en petit et se dessine en CSS pur. *Désaccord léger avec le client*, qui demandait un camembert. Le bilan peut en afficher un si on y tient.

### Q2. Une interruption excitante et claire, lue en 10 secondes au maximum ?

- **Le jeu se met en pause tout seul** : on n'impose jamais de lecture chronométrée.
- **Mise en scène en moins d'une seconde** : l'écran s'assombrit, le journal **tombe en tournoyant** (clin d'œil aux vieux films), un léger « choc » secoue l'écran, puis le texte apparaît.
- **Une grammaire fixe, toujours dans le même ordre**, pour que l'œil sache où aller :
  1. la manchette, 8 mots au maximum, en très gros ;
  2. la date ;
  3. l'explication, 40 mots au maximum, soit 2 ou 3 phrases ;
  4. **l'impact personnel**, dans une pastille colorée : « Votre portefeuille : ▼ −6 820 F (−21 %) ». C'est cette ligne qui rend le moment excitant : on parle de *son* argent ;
  5. la question « Que faites-vous ? » et **3 gros boutons** au maximum, chacun avec un verbe (2 à 3 mots) et une sous-ligne (5 mots au maximum).
- **On ne révèle jamais la conséquence d'un choix sur le moment.** La réponse arrive **12 mois plus tard**, dans une carte de rappel : « Il y a un an, vous avez tout vendu. Depuis, le marché a repris +24 %. » C'est la leçon la plus forte du jeu, et elle coûte une ligne de code.
- **Les événements de vie ont un autre habillage** (un courrier, pas un journal), pour que le joueur reconnaisse au premier coup d'œil s'il s'agit du monde ou de sa vie.
- **Toutes les interruptions ne bloquent pas** (voir § 3.6). Avec 1 à 3 événements de vie par an plus 5 à 8 événements de marché, une partie compterait jusqu'à 50 pauses forcées : c'est trop. Seuls les événements qui demandent une décision ou qui coûtent plus d'un mois de salaire ouvrent une modale. Les autres arrivent en notification, sans arrêter le temps. On vise environ **une interruption par an de jeu**, soit une toutes les 50 secondes en vitesse ×1. *C'est une précision par rapport à la vision.*

### Q3. Un accueil en moins d'une minute, avec un tutoriel dans le jeu ?

- **Trois clics, puis « Jouer ».** Chaque étape (période, profil, objectif) est un choix entre 3 cartes. Le clic sur une carte passe automatiquement à l'étape suivante. Des valeurs par défaut sont présélectionnées (la première période, le jeune salarié, « Battre l'inflation »).
- **Une phrase se construit en haut de l'écran** au fil des choix : « En 1978, je suis Gérard, jeune salarié, et je veux battre l'inflation en 15 ans. » Le joueur comprend sa partie sans lire de règles.
- **Je propose d'inverser l'ordre de la vision** : les 3 périodes d'abord, sous forme de cartes, et l'année libre en lien secondaire (« Une autre année en tête ? »). Un champ « saisissez une année » vide est un mauvais premier contact pour un débutant, qui ne sait pas quoi choisir. *Désaccord avec le client.*
- **Le tutoriel est la première année de jeu** : 6 étapes accrochées aux mois 1 à 6, chacune demandant **une action réelle** (lancer le temps, ouvrir un livret, regarder la baguette…). On n'affiche jamais plus d'une bulle de 2 lignes à la fois. Le bouton « Passer le tutoriel » reste toujours visible, et la case « Tutoriel » est décochée d'office à partir de la deuxième partie.

### Q4. Un bilan gratifiant et pédagogique qui donne envie de rejouer ?

- **Une révélation par étapes**, comme une remise de prix, d'environ 8 secondes, qu'un clic peut accélérer : le chiffre final défile → **la course** des 4 barres (vous et les 3 témoins) → la jauge d'objectif → les étoiles une à une → le **titre humoristique frappé comme un tampon** → les 3 leçons qui se retournent comme des cartes → le bouton « Rejouer ».
- **Le graphique des 4 courbes** (vous, Tonton Matelas, Tata Livret, Cousin Indice) sur toute la partie, avec les événements marqués. On *voit* Cousin Indice plonger en 1987 puis remonter : c'est la leçon du jeu, sans une ligne de cours.
- **Des étoiles transparentes** : 1 étoile pour l'objectif atteint, 1 par témoin battu (3 au maximum) et 1 étoile « sang-froid » si l'on n'a jamais vendu en panique. La règle s'affiche au survol. Le joueur sait donc *quoi* améliorer.
- **Chaque leçon est cliquable** (« Voir sur la frise ») et montre le moment précis où elle s'est jouée.
- **« Rejouer la même période autrement » rejoue avec les mêmes événements de vie** (même graine aléatoire, case cochée par défaut). La seule différence entre les deux parties devient alors les choix du joueur. C'est ce qui rend la comparaison juste et donne envie d'essayer « pour voir ».
- Les témoins ont **une réplique** selon leur rang (« Au moins, mes billets, je peux les toucher ! »). C'est de l'humour à très bas coût.

### Q5. Faire ressentir l'époque sans multiplier le travail du développeur ?

- **Un seul attribut** `data-era="1980"` sur le `<body>`, qui redéfinit **6 variables CSS** : papier du journal, encre, couleur d'accent, police et casse des manchettes, nom du journal. Il y a 8 décennies, soit 8 petits blocs CSS d'environ 10 lignes (§ 7.3).
- **Le journal évolue avec les médias** : quotidien sépia dans les années 1950 → une à gros titres dans les années 1980 → page web dans les années 2000 → notification de smartphone dans les années 2020. Le joueur ressent le temps qui passe, et c'est toujours le même composant HTML.
- **Le panier du quotidien** : le prix de la baguette (et, en option, d'un plein d'essence) sous la date. C'est une ligne de texte, mais elle porte toute l'inflation.
- **La monnaie elle-même** (F, puis F et €, puis €) et un vrai « moment euro » (§ 3.9).
- **Un changement de décennie discret** : notification « Bienvenue dans les années 80 » et bascule de la couleur d'accent en fondu.
- On **ne change pas** les mises en page, les icônes ni les boutons selon l'époque : ce serait coûteux et ça nuirait à la lisibilité.

### Q6. Francs puis euros, et euros constants, sans perdre le joueur ?

- **Une seule monnaie principale à la fois**, toujours avec son symbole : `12 450 F` ou `1 898 €`. Jamais de chiffre sans unité.
- **Quatre phases calquées sur la vraie vie** :
  1. jusqu'à fin 1998 : uniquement des francs ;
  2. de 1999 à 2001 : **double affichage**, avec les francs en principal et l'équivalent en euros en petit et en gris, comme sur les étiquettes de l'époque ;
  3. le 1er janvier 2002 : **moment euro**, en modale. Tous les montants « basculent » en même temps avec l'animation `euro-flip` ;
  4. en 2002 : les euros passent en principal et les francs en petit pendant 12 mois, puis les francs disparaissent.
  Le même mécanisme sert pour le passage des anciens aux nouveaux francs en 1960 (année libre, V2) : une seule fonction, un taux de conversion différent.
- **Pas d'« euros constants » pendant la partie.** Le terme fait peur. Pour mesurer le pouvoir d'achat en jeu, on utilise **la baguette comme unité** : « Votre patrimoine = 13 260 baguettes ». C'est concret, drôle, et ça se compare d'une décennie à l'autre sans calcul. L'objectif « Battre l'inflation » s'affiche lui aussi en baguettes.
- **Au bilan**, le chiffre principal est en « **€ d'aujourd'hui** » (on évite le mot « constants », qui reste réservé au glossaire), suivi de la valeur nominale d'époque et du nombre de baguettes : « 61 300 € d'aujourd'hui (= 214 000 F de 1992 = 22 400 baguettes) ». Un « (?) » ouvre la bulle d'explication.
- *Écart avec la vision*, qui voulait les euros constants partout comme référence. Je les garde pour le bilan, où ils ont le plus de sens. *Dépendance au banquier* : il faut la série du prix de la baguette, année par année.

---

## 2. Le parcours complet

```
 ┌─────────────┐   Continuer (si sauvegarde)                               ┌──────────────┐
 │ ÉCRAN TITRE ├──────────────────────────────────────────────────────────►│              │
 └──────┬──────┘                                                           │              │
        │ Nouvelle partie                                                  │    ÉCRAN     │
        ▼                                                                  │  PRINCIPAL   │
 ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐   │  (frise +    │
 │ 1. PÉRIODE  ├─►│ 2. PROFIL   ├─►│ 3. OBJECTIF ├─►│ 4. RÉCAP + JOUER ├──►│  3 colonnes) │
 └─────────────┘  └─────────────┘  └─────────────┘  └──────────────────┘   │              │
   ~10 s            ~10 s            ~10 s            ~10 s                │ mois 1-6 :   │
                                                                           │ tutoriel     │
                                                                           └──┬────┬───┬──┘
                ┌─────────────────────────────────────────────────────────────┘    │   │
                ▼                                   ▼                              │   │
     ┌────────────────────┐   ┌────────────────────────────────────┐               │   │
     │ TIROIR MARCHÉ      │   │ MODALES : marché · vie · euro ·    │               │   │
     │ (achat, vente,     │   │ objectif atteint · faillite        │               │   │
     │ versement auto)    │   └────────────────────────────────────┘               │   │
     └────────────────────┘   NOTIFICATIONS : petits événements, nouveaux          │   │
                              produits, bilan annuel, rappel à 12 mois             │   │
                                                                                   ▼   ▼
                                    ┌─────────────────────────────┐  fin de durée │ faillite
                                    │       BILAN DE FIN          │◄──────────────┘ ou objectif
                                    └──────┬───────────────┬──────┘                  atteint
                     Rejouer la même       │               │ Nouvelle partie
                     période autrement     ▼               ▼
                     (→ étape 4,     ┌──────────┐    ┌─────────────┐
                     mêmes choix,    │ RÉCAP 4  │    │ 1. PÉRIODE  │
                     même graine)    └──────────┘    └─────────────┘
```

Le décompte en écrans respecte la vision : **accueil** (titre et création), **jeu** (avec le tiroir marché et les modales), **achat/vente** (le tiroir) et **bilan**.

---

## 3. Les écrans

Les légendes des maquettes utilisent `[ … ]` pour un bouton, `( )`/`(•)` pour un choix exclusif, `[ ]`/`[x]` pour une case à cocher, `(?)` pour une bulle « C'est quoi ? », `▲ ▼` pour une variation.

### 3.1 Écran titre

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                          │
│        ╔══════════════════════════════════════════════════════════╗                      │
│        ║ LA GAZETTE                      édition spéciale · 1 F   ║  ← une « une » qui   │
│        ║══════════════════════════════════════════════════════════║    change toutes les │
│        ║                    J E U C L A U D E                     ║    4 s : son style   │
│        ║       Votre argent, votre vie, de 1950 à nos jours       ║    passe de 1950 à   │
│        ╚══════════════════════════════════════════════════════════╝    2020 (§ 7.3)      │
│                                                                                          │
│                  ┌─────────────────────────────────────────────────┐                     │
│                  │  ▶  CONTINUER   Gérard · mars 1986 · 412 300 F  │  ← si sauvegarde    │
│                  └─────────────────────────────────────────────────┘                     │
│                  ┌─────────────────────────────────────────────────┐                     │
│                  │  +  NOUVELLE PARTIE                             │                     │
│                  └─────────────────────────────────────────────────┘                     │
│                           Options   ·   Glossaire   ·   À propos                         │
│                                                                                          │
│ ──────────────────────────────────────────────────────────────────────────────────────── │
│  1960 Le nouveau franc arrive ··· 1973 Choc pétrolier ··· 1987 Lundi noir ··· 2002 Bonj… │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Contenu** : la une animée (même composant que la manchette en jeu, avec `data-era` qui tourne sur 8 décennies), 2 boutons, 3 liens, un bandeau défilant de manchettes.
- **Interactions** : `Entrée` déclenche le bouton mis en avant (Continuer s'il existe, sinon Nouvelle partie). Si une sauvegarde existe, « Nouvelle partie » demande confirmation : « Cela remplacera votre partie en cours (mars 1986). Continuer ? »
- **États** :
  - *pas de sauvegarde* : « Continuer » est masqué et « Nouvelle partie » devient le bouton principal ;
  - *sauvegarde corrompue* : message neutre « Votre ancienne partie n'a pas pu être relue. » et seul « Nouvelle partie » reste ;
  - *`prefers-reduced-motion`* : la une ne change plus et le bandeau est figé.

### 3.2 Création de partie (3 étapes et un récapitulatif)

Un seul écran, dont le contenu change. En haut : un bouton retour, des pastilles d'étape et **la phrase qui se remplit**.

#### Étape 1 : la période

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│ ← Retour                         NOUVELLE PARTIE                              ● ○ ○  1/3 │
│                                                                                          │
│        « En ______ , je suis ______ et je veux ______ . »                                │
│                                                                                          │
│   Quand commencez-vous votre vie active ?                                                │
│                                                                                          │
│   ┌────────────────────────────┐ ┌────────────────────────────┐ ┌───────────────────────┐│
│   │ À PARTIR DE 1978           │ │ À PARTIR DE 1995           │ │ À PARTIR DE 2008      ││
│   │ LES ANNÉES FRIC            │ │ DE L'EUPHORIE À LA CRISE   │ │ L'ÈRE DES ETF         ││
│   │    ╱╲    ╱╲╱‾‾╲_╱‾‾        │ │     _╱‾‾╲__╱‾╲__╱‾         │ │  ╲_╱‾‾‾╱‾╲╱‾‾‾╲╱‾     ││
│   │ Inflation à deux chiffres, │ │ L'euro arrive, Internet    │ │ Taux zéro, Covid,     ││
│   │ krach de 87, le PEA naît.  │ │ s'emballe… puis 2008.      │ │ retour de l'inflation.││
│   │ Monnaie : franc            │ │ Monnaie : franc → euro     │ │ Monnaie : euro        ││
│   │ Secousses : ●●●○           │ │ Secousses : ●●●●           │ │ Secousses : ●●●○      ││
│   └────────────────────────────┘ └────────────────────────────┘ └───────────────────────┘│
│                                                                                          │
│              Une autre année en tête ?  [ Choisir une année… ]                           │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Carte** : année de départ, nom, mini-courbe SVG de l'indice sur la période (tirée des données de prix, 30 points suffisent), accroche de 2 lignes au maximum, monnaie, « secousses » sur 4 (nombre et violence des événements de marché, *[à valider par le boursier]*).
- **Survol ou focus** : la carte se soulève (`card-lift`) et la mini-courbe se dessine (`line-draw`).
- **Clic** : la carte se marque d'un liseré d'accent, la phrase se complète (« En 1978, »), puis l'étape 2 arrive en glissant après 250 ms.
- **« Choisir une année »** ouvre une petite boîte avec un curseur de 1950 à l'année courante et un champ numérique, et prévient : « Moins d'événements scénarisés hors des 3 périodes. » Le bouton est **masqué en V1** si le développeur ou le boursier tranchent pour la V2.

#### Étape 2 : le profil

```
│   Qui êtes-vous ?                                                                        │
│   ┌────────────────────────────┐ ┌────────────────────────────┐ ┌───────────────────────┐│
│   │      ( G )                 │ │      ( M )                 │ │      ( B )            ││
│   │ GÉRARD, 22 ANS             │ │ MARTINE, 30 ANS            │ │ BERNARD, 25 ANS       ││
│   │ Le jeune salarié           │ │ La cadre pressée           │ │ L'héritier            ││
│   │ Salaire  3 200 F / mois    │ │ Salaire  9 500 F / mois    │ │ Salaire 3 800 F / mois││
│   │ Épargne  0 F               │ │ Dépenses élevées           │ │ Capital 40 000 F      ││
│   │ « Tout à construire. »     │ │ « Gagne bien, dépense      │ │ « Un coup de pouce    ││
│   │                            │ │   autant. »                │ │   de mamie. »         ││
│   └────────────────────────────┘ └────────────────────────────┘ └───────────────────────┘│
```

- **Prénoms selon l'époque** (une liste de 3 prénoms par période, dans les données) : Gérard, Martine et Bernard en 1978 ; Sébastien, Nathalie et Christophe en 1995 ; Kevin, Julie et Thomas en 2008. Le coût est nul et l'effet garanti.
- **Avatar** : un cercle de couleur avec l'initiale. Aucune illustration n'est nécessaire en V1.
- Les **montants viennent des données du banquier**, dans la monnaie de l'époque. Les chiffres ci-dessus sont fictifs.

#### Étape 3 : l'objectif

```
│   Quel est votre rêve ?                                                                  │
│   ┌────────────────────────────┐ ┌────────────────────────────┐ ┌───────────────────────┐│
│   │ ★ CONSEILLÉ POUR DÉBUTER   │ │                            │ │                       ││
│   │ BATTRE L'INFLATION         │ │ ACHETER SA MAISON          │ │ UNE RETRAITE          ││
│   │ Finir plus riche en        │ │ Réunir 80 000 F d'apport   │ │ TRANQUILLE            ││
│   │ baguettes qu'au départ.    │ │ avant 1986.                │ │ Atteindre 600 000 F   ││
│   │ Difficulté : ●○○           │ │ Difficulté : ●●○           │ │ en 1993.              ││
│   │                            │ │                            │ │ Difficulté : ●●●      ││
│   └────────────────────────────┘ └────────────────────────────┘ └───────────────────────┘│
```

#### Étape 4 : récapitulatif

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│ ← Retour                         VOTRE HISTOIRE                               ● ● ●      │
│                                                                                          │
│      « En janvier 1978, je suis Gérard, 22 ans, jeune salarié,                           │
│        et je veux battre l'inflation en 15 ans. »                                        │
│                                                                                          │
│      Durée :        ( ) 10 ans    (•) 15 ans    ( ) 25 ans                               │
│      Tutoriel :     [x] Me guider pendant la première année                              │
│      Événements :   [x] Mêmes événements de vie que ma dernière partie  ← si « Rejouer » │
│                                                                                          │
│                        ┌──────────────────────────────────┐                              │
│                        │        ▶  C'EST PARTI !          │                              │
│                        └──────────────────────────────────┘                              │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- Une durée est grisée si les données ne couvrent pas la période (2008 + 25 ans), avec la bulle « Les données s'arrêtent en 2025 ».
- La case *Tutoriel* est cochée lors de la première partie, puis décochée.
- Les **valeurs par défaut** permettent de lancer une partie en 4 clics (carte, carte, carte, « C'est parti »).

### 3.3 Écran principal

Disposition sur 1366 × 768 : une barre haute de 64 px, une frise de 72 px, puis trois colonnes (280 px | flexible | 340 px) et une ligne de fil d'actualité de 32 px en bas.

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ MARS 1984          [❚❚][ ▶ ][▶▶][▶▶▶]  ⏸ EN PAUSE        COMPTE COURANT      PATRIMOINE TOTAL       ☰  │
│ Baguette 2,90 F                                          4 210 F             38 450 F  ▲ +2,1 %         │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 1978  1979  1980  1981  1982  1983  1984  1985  1986  1987  1988  1989  1990  1991  1992  1993          │
│ ════════════════════════════════════════●──────────────────────────────────────────────────────── ⚑     │
│   ◆      ●   ◆ ◆      ◆●     ●                                          ★                             │
├────────────────────────────┬───────────────────────────────────────────────┬─────────────────────────────┤
│ MON MOIS         mars 1984 │ MON PATRIMOINE                 [1 an] [Tout]  │ MES PLACEMENTS              │
│                            │ 38 450 F         = 13 260 baguettes (?)       │                             │
│ Salaire         + 5 800 F  │                                               │ ▌Livret A          10 400 F │
│ Loyer           − 2 100 F  │ 40 000 ┤                         ╭──╮  ╭──    │  8,5 % / an  (?)    ╱‾‾‾    │
│ Vie courante    − 2 450 F  │        │               ╭───╮ ╭──╯   ╰──╯      │               [ Gérer ]     │
│ Versements auto −   500 F  │ 20 000 ┤      ╭───────╯   ╰─╯ - - - - - -     │ ▌SICAV France       8 100 F │
│ ────────────────────────── │        │ ╭───╯ - - - - - - -                   │  ▲ +12,4 %          ╱╲╱‾    │
│ Reste           +   750 F  │      0 ┼─┴──────┬──────┬──────┬──────┬───     │               [ Gérer ]     │
│                            │          1979   1980   1981   1982   1983     │ ▌Cie Pétrolière    15 750 F │
│ COUSSIN DE SÉCURITÉ    (?) │  ── Ce que ça vaut  - - Argent mis de côté    │  ▼ −3,4 %           ╲_╱‾    │
│ [███████████░░░░░] 2,1 mois│                                               │               [ Gérer ]     │
│ conseillé : 3 mois         │ RÉPARTITION                                   │ ─ Disponibles ───────────── │
│                            │ [░░░░▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒████████████████]       │ ▌Emprunt d'État  [Découvrir]│
│ MON OBJECTIF               │  Compte 11 %  Livret 27 %  SICAV 21 %         │ ▌Cie Automobile  [Découvrir]│
│ Battre l'inflation         │  Actions 41 %                                 │                             │
│ [██████████████░░] 112 %   │                                               │ ┌─────────────────────────┐ │
│ 9 200 → 10 300 baguettes   │                                               │ │ + ACHETER / VENDRE  (M) │ │
│ Encore 9 ans et 10 mois    │                                               │ └─────────────────────────┘ │
├────────────────────────────┴───────────────────────────────────────────────┴─────────────────────────────┤
│ ▸ mars 1984 · Salaire versé · Le livret A passe à 8,5 % · Le saviez-vous ? Le Minitel…    [Historique]   │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### Zones et contenu

| Zone | Contenu | Interactions |
|---|---|---|
| **Barre haute, gauche** | Date `MARS 1984` en très gros (Bahnschrift 28 px), panier du quotidien en dessous (baguette ; plein d'essence en bonus). | Survol de la baguette : bulle « Il y a 1 an : 2,65 F (+9 %). C'est l'inflation. » |
| **Barre haute, centre** | Contrôles du temps et badge `EN PAUSE` (§ 4). | Clic, ou touches `Espace`/`P`, `1`, `2`, `3`. |
| **Barre haute, droite** | Compte courant et patrimoine total, avec la variation du mois. Menu ☰. | Clic sur le patrimoine : défile jusqu'à la colonne centrale (utile à petite taille). |
| **Frise** | § 4. | Survol ou clic sur un marqueur. |
| **Mon mois** | Budget du mois (entrées et sorties), **coussin de sécurité** (jauge en mois de dépenses), **objectif** (jauge, cible, temps restant). | Survol d'une ligne de dépense : détail. Le coussin et l'objectif ont un `(?)`. |
| **Mon patrimoine** | Total en monnaie et en baguettes ; **courbe de patrimoine** en SVG avec la ligne pointillée « Argent mis de côté » (cumul de l'épargne sans aucun rendement : c'est Tonton Matelas, non nommé avant le bilan) ; **barre de répartition** horizontale avec motif et étiquette par catégorie. | `[1 an] [Tout]`. Survol de la courbe : infobulle date + valeur. Les marqueurs d'événements de la courbe reprennent ceux de la frise. |
| **Mes placements** | Placements détenus (nom, valeur, variation depuis l'achat, mini-courbe de 12 mois, enveloppe), puis placements disponibles non détenus, puis bouton marché. | `[Gérer]` ou `[Découvrir]` ouvre le tiroir sur ce produit. `M` ouvre le tiroir. |
| **Fil** | Dernier message du mois sur une ligne (défilement horizontal s'il est trop long). | `[Historique]` : liste des 50 derniers messages. |

**Pourquoi la ligne « Argent mis de côté »** : l'écart entre la courbe pleine et la ligne pointillée, ce sont *les intérêts et les plus-values*. On voit l'effet boule de neige se creuser, ou la ligne pleine passer sous la pointillée pendant un krach. C'est la visualisation des intérêts composés que demande le client, sans formule.

#### États de l'écran principal

| État | Déclencheur | Rendu |
|---|---|---|
| **Vide** | Mois 1, rien de placé | Colonne placements : « Votre argent dort sur le compte courant. » et un seul produit visible, le livret A. Courbe : un point et le texte « Votre courbe se dessinera mois après mois. » Répartition : 100 % compte (gris). |
| **Normal, en marche** | Temps actif | Le curseur de la frise glisse, rien ne clignote en dehors des changements. |
| **Gain du mois** | Patrimoine ▲ | Le total défile (`count-roll`), `flash-gain` sur le total et les lignes concernées, flèche ▲ et signe « + ». |
| **Perte du mois** | Patrimoine ▼ | Même chose en `flash-loss`, avec ▼ et « − ». |
| **Krach en cours** | Patrimoine à plus de 15 % sous son plus haut | Vignette rouge très légère sur les bords (`crash-vignette`, bonus), aire sous la courbe teintée `--loss-bg`, et pastille sous le total : « −18 % depuis le plus haut ». La tension reste visible même quand le temps tourne. |
| **Pause** | Pause manuelle, modale, tiroir ou fenêtre masquée | Cadre de 4 px couleur `--pause` autour de la zone de jeu, badge `⏸ EN PAUSE` qui respire (`pause-breathe`), curseur figé. Les chiffres restent lisibles et ne sont jamais grisés. |
| **Découvert** | Compte courant < 0 | La valeur du compte devient rouge, avec un fond `--loss-bg` et l'icône ⚠. Bandeau sous la barre haute : « Découvert : 2 mois sur 6 tolérés. Vendez un placement ou réduisez vos versements. » `shake-alert` au premier mois de découvert. |
| **Objectif proche** | Objectif ≥ 90 % | Jauge en `--gain` et `glow` doux, notification « Plus que 8 % ! ». |
| **Dernière année** | 12 derniers mois | Le dernier segment de la frise est rayé et la notification « Dernière année ! » apparaît. |

### 3.4 Tiroir « Marché » (achat, vente, versement automatique)

Il s'ouvre depuis la droite et recouvre la colonne des placements et la moitié de la colonne centrale (480 px). **Il met le jeu en pause** (option désactivable : « Pause auto à l'ouverture du marché »).

```
                                        ┌──────────────────────────────────────────────┐
                                        │ ✕  MARCHÉ · mars 1984    le temps est en pause│
                                        │ ┌────────┬────────┬────────┬────────┬───────┐ │
                                        │ │Livret A│SICAV Fr│Pétrol. │Automob.│Emprunt│ │
                                        │ └────────┴────────┴────────┴────────┴───────┘ │
                                        │ CIE PÉTROLIÈRE            Action · Paris     │
                                        │ 141,20 F l'action        ▼ −3,4 % ce mois     │
                                        │  ╭╮    ╭─╮                    [1 an] [5 ans]  │
                                        │ ─╯╰────╯ ╰──╮╭──╮╭─                          │
                                        │             ╰╯  ╰╯                           │
                                        │ C'est quoi ? Un morceau d'une entreprise. Son │
                                        │ prix monte et baisse. Elle verse un dividende.│
                                        │ Vous avez : 112 actions = 15 750 F  ▲ +8,0 %  │
                                        │ ┌─────────────────────┬─────────────────────┐ │
                                        │ │      ACHETER        │       VENDRE        │ │
                                        │ └─────────────────────┴─────────────────────┘ │
                                        │ Montant    [     2 000 ] F                    │
                                        │ [10 %] [25 %] [50 %] [Tout]  du compte courant│
                                        │ Dans       (•) Compte-titres  ( ) PEA (?)     │
                                        │ ───────────────────────────────────────────── │
                                        │ 14 actions × 141,20 F         1 976,80 F      │
                                        │ Frais de courtage (?)             20,00 F     │
                                        │ Reste sur le compte           2 213,20 F      │
                                        │ ⚠ Votre coussin passerait à 1,4 mois.         │
                                        │ ┌───────────────────────────────────────────┐ │
                                        │ │       ACHETER POUR 1 996,80 F             │ │
                                        │ └───────────────────────────────────────────┘ │
                                        │ ─ VERSEMENT AUTOMATIQUE ───────────────────── │
                                        │ [ ] Chaque mois, investir [  200 ] F ici  (?) │
                                        └──────────────────────────────────────────────┘
```

- **On saisit un montant d'argent, pas un nombre de titres.** Le débutant pense « je mets 2 000 F ». Le jeu calcule le nombre entier d'actions et affiche le reste. Les boutons 10 / 25 / 50 % / Tout évitent de taper.
- **Les frais sont toujours visibles avant de confirmer** : c'est la première rencontre avec la notion de frais.
- **Garde-fou pédagogique et non bloquant** : si l'achat fait passer le coussin sous 3 mois, un avertissement jaune s'affiche. On n'interdit jamais rien : le joueur doit pouvoir faire l'erreur.
- **L'onglet Vendre** montre la plus-value et l'impôt estimé, **avec la comparaison PEA** dès que le PEA existe :
  ```
  Vous vendez : 112 actions × 141,20 F            15 814,40 F
  Plus-value (gain depuis l'achat)                + 1 170,00 F
  Impôt sur la plus-value (?)                       − 187,20 F
     → dans un PEA de plus de 5 ans, vous auriez payé : 0 F *[taux à valider]*
  Vous recevez sur le compte courant              15 607,20 F
  [  VENDRE POUR 15 607,20 F  ]
  ```
- **Livret A** : pas d'onglets Acheter/Vendre mais **Déposer / Retirer**, sans frais ni impôt affichés, avec la mention « Taux : 8,5 % par an, intérêts versés chaque fin d'année » *[à valider]*.
- **Versement automatique** : quand la case est cochée, le montant apparaît dans *Mon mois* (« Versements auto »), et la ligne du produit porte la pastille `AUTO`. Si le compte est insuffisant, le versement est sauté ce mois-là et une notification le signale.
- **Confirmation** : le bouton devient « ✓ Acheté », la pièce vole vers la ligne du produit (`coin-fly`) et le tiroir reste ouvert (le joueur enchaîne souvent plusieurs ordres). `Échap` ou ✕ ferme le tiroir, et le temps reprend **seulement si** il tournait avant l'ouverture.
- **États** :
  - *produit verrouillé* : invisible, on ne montre pas ce qui n'existe pas encore ;
  - *compte vide* : boutons d'achat désactivés et texte « Plus rien sur le compte courant ce mois-ci. » ;
  - *aucun titre détenu* : onglet Vendre désactivé ;
  - *montant trop faible pour une action* : « Il faut au moins 141,20 F pour une action. »

### 3.5 Modale « Événement de marché » (le journal)

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│░░░░░░░░░░░░░░░░░░░░░░░░ fond assombri à 60 %, jeu en pause ░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
│░░░░░░░ ┌────────────────────────────────────────────────────────────────────┐ ░░░░░░░░░│
│░░░░░░░ │ LA GAZETTE                       Mardi 20 octobre 1987 · 4,50 F    │ ░░░░░░░░░│
│░░░░░░░ │════════════════════════════════════════════════════════════════════│ ░░░░░░░░░│
│░░░░░░░ │                                                                    │ ░░░░░░░░░│
│░░░░░░░ │       LUNDI NOIR : LA BOURSE                                       │ ░░░░░░░░░│
│░░░░░░░ │       DE PARIS DÉVISSE                                             │ ░░░░░░░░░│
│░░░░░░░ │ ────────────────────────────────────────────────────────────────── │ ░░░░░░░░░│
│░░░░░░░ │ Wall Street a perdu plus de 20 % en une seule séance. Paris suit : │ ░░░░░░░░░│
│░░░░░░░ │ les actions françaises fondent en quelques semaines. Les           │ ░░░░░░░░░│
│░░░░░░░ │ épargnants se ruent sur les guichets.            *[à valider]*     │ ░░░░░░░░░│
│░░░░░░░ │                                                                    │ ░░░░░░░░░│
│░░░░░░░ │  ┌──────────────────────────────────────────────────────────────┐  │ ░░░░░░░░░│
│░░░░░░░ │  │ VOTRE PORTEFEUILLE   ▼ −6 820 F  (−21 % depuis septembre)    │  │ ░░░░░░░░░│
│░░░░░░░ │  └──────────────────────────────────────────────────────────────┘  │ ░░░░░░░░░│
│░░░░░░░ │  QUE FAITES-VOUS ?                                                 │ ░░░░░░░░░│
│░░░░░░░ │  ┌────────────────────┐ ┌────────────────────┐ ┌────────────────┐  │ ░░░░░░░░░│
│░░░░░░░ │  │ 1  TOUT VENDRE     │ │ 2  NE RIEN FAIRE   │ │ 3  RENFORCER   │  │ ░░░░░░░░░│
│░░░░░░░ │  │ Sauver ce qui reste│ │ Attendre l'éclaircie│ │ Acheter en solde│ │ ░░░░░░░░░│
│░░░░░░░ │  └────────────────────┘ └────────────────────┘ └────────────────┘  │ ░░░░░░░░░│
│░░░░░░░ └────────────────────────────────────────────────────────────────────┘ ░░░░░░░░░│
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Entrée** : `backdrop-in` (200 ms), puis `paper-spin` (journal tournoyant, 700 ms) pour les krachs et les grandes crises, ou `paper-drop` (450 ms) pour les autres événements, enfin `screen-thud`. Les boutons n'acceptent les clics **qu'après 1 seconde** (`opacity .5` puis 1), pour éviter un clic réflexe qui ferait sauter la lecture.
- **Choix** :
  - *Tout vendre* : écran de confirmation dans la modale (« Vous vendez 3 lignes pour 25 400 F, frais 60 F, impôt 0 F. [Confirmer] [Je réfléchis encore] »), puis exécution ;
  - *Ne rien faire* : la modale se ferme et le jeu **reste en pause**, pour laisser le joueur souffler ; une bulle sur ▶ lui indique de relancer le temps ;
  - *Renforcer* : la modale se ferme et le tiroir s'ouvre sur le fonds ou l'action la plus touchée, avec 25 % du compte prérempli.
- **Raccourcis** : les touches `1`, `2`, `3` choisissent. `Échap` vaut « Ne rien faire » (le choix le plus neutre).
- **Variante « aucune action détenue »** : la pastille d'impact dit « Vous n'avez pas d'actions : votre argent est à l'abri… mais les prix sont soldés. » et les choix deviennent *Rester à l'écart* / *Profiter des soldes*.
- **Événement positif** (euphorie, privatisation) : même composant, pastille verte, choix *Encaisser mes gains* / *Ne rien faire* / *Suivre la foule*. C'est l'occasion d'enseigner la bulle : on peut tomber dans le piège dans les deux sens.
- **Après** : un marqueur ◆ reste sur la frise. 12 mois plus tard, la carte de rappel s'affiche (§ 3.8).
- **File d'attente** : jamais plus d'une modale par mois. L'ordre est marché > vie > euro. Un événement de vie de trop est reporté au mois suivant.

### 3.6 Événements de vie : modale « courrier » ou notification

**Règle de tri** (paramètre dans les données de chaque événement, `mode: "modale" | "toast"`) :
- **modale** si l'événement demande un choix, coûte ou rapporte plus d'un mois de salaire, ou change durablement le budget (naissance, perte d'emploi, déménagement) ;
- **notification** dans les autres cas (petite prime, petite panne, augmentation modeste).

#### Modale « courrier »

```
            ┌──────────────────────────────────────────────────┐
            │ ✉  COURRIER · avril 1985                         │
            │ ──────────────────────────────────────────────── │
            │            [ pictogramme : voiture ]             │
            │                                                  │
            │          LA VOITURE REND L'ÂME                   │
            │  Le garagiste est formel : embrayage et courroie.│
            │  La facture s'élève à 3 400 F.                   │
            │                                                  │
            │  Compte courant : 2 100 F     ⚠ il manque 1 300 F │
            │                                                  │
            │  ┌────────────────────────────────────────────┐  │
            │  │ VENDRE UN PLACEMENT…                       │  │
            │  │ Choisir quoi vendre                        │  │
            │  └────────────────────────────────────────────┘  │
            │  ┌────────────────────────────────────────────┐  │
            │  │ PASSER À DÉCOUVERT                         │  │
            │  │ Agios de 12 % par an *[à valider]*         │  │
            │  └────────────────────────────────────────────┘  │
            └──────────────────────────────────────────────────┘
```

- **Look** : papier blanc et bord gauche épais de couleur (`--loss` pour un coup dur, `--gain` pour une bonne nouvelle, `--accent` pour un événement de vie neutre), police UI et non journal. Entrée en `letter-slide` (glisse du bas avec une légère rotation, 350 ms).
- **Cas 1, le compte suffit** : un seul bouton « Payer 3 400 F », la pastille « Votre coussin passe de 2,8 à 1,9 mois » et le jeu reprend.
- **Cas 2, le compte ne suffit pas** : choix ci-dessus. « Vendre un placement » ouvre une liste simplifiée des placements avec leur variation (« SICAV ▼ −18 % ») : le joueur *voit* qu'il vend à perte. C'est la leçon de l'épargne de précaution par la douleur, voulue par le client.
- **Événement à choix** (« Votre beau-frère vous propose d'investir dans son élevage d'escargots, rendement promis 30 % ») : 2 boutons, *Je fonce* / *Non merci*. La conséquence tombe plus tard, par un nouveau courrier.
- **Bonne nouvelle importante** (héritage) : `coin-rain` léger (10 pièces qui tombent dans le compte courant, 800 ms) et bouton unique « Encaisser ». La bulle ajoute : « Que faire de cet argent ? Le marché est ouvert. » avec [Ouvrir le marché] [Plus tard].

#### Notification (toast)

```
┌──────────────────────────────────────────────┐
│▌ ★  Prime de fin d'année        + 1 200 F    │
│▌    Versée sur votre compte courant.      ✕  │
└──────────────────────────────────────────────┘
```

- En bas à gauche, 3 au maximum empilées. Elles disparaissent après 5 s, ou 3 s en ×3, sauf les notifications **persistantes** (nouveau produit, rappel à 12 mois), qui attendent un clic. Elles sont toutes archivées dans l'historique du fil.

### 3.7 Nouveau produit débloqué

```
┌──────────────────────────────────────────────┐
│▌ NOUVEAU · 1992                              │
│▌ Le PEA vient d'être créé !                  │
│▌ Un compte pour placer en actions, avec moins│
│▌ d'impôt si vous le gardez 5 ans.            │
│▌               [ Découvrir ]   [ Plus tard ] │
└──────────────────────────────────────────────┘
```

- C'est une notification persistante **qui ne met pas le jeu en pause**. « Découvrir » met en pause et ouvre le tiroir sur le produit.
- Le produit apparaît dans « Disponibles » avec `unlock-pop`, l'étiquette « NOUVEAU » (jusqu'à la première ouverture) et un balayage brillant.
- Sur la frise, le marqueur ★ « cadeau » à venir s'ouvre (§ 4.3).

### 3.8 Cartes récurrentes : bilan annuel et rappel à 12 mois

**Bilan annuel** : notification persistante en janvier, qui ne met pas le jeu en pause.

```
┌──────────────────────────────────────────────┐
│▌ VOTRE ANNÉE 1984                         ✕  │
│▌ Votre patrimoine         ▲ +14,2 %          │
│▌ Les prix (inflation) (?) ▲  +6,7 %          │
│▌ Votre pouvoir d'achat    ▲  +7,0 %          │
│▌   soit +870 [icône baguette]                │  ← pictogramme SVG, pas un emoji
│▌ Intérêts du livret      + 860 F             │
│▌ Dividendes reçus        + 140 F             │
└──────────────────────────────────────────────┘
```

C'est **le** support de l'apprentissage de l'inflation : une fois par an, on compare « ce que j'ai gagné » et « ce que les prix ont pris ».

**Rappel à 12 mois** après un choix de marché (persistant) :

> « Octobre 1988. Il y a un an, pendant le Lundi noir, vous avez **tout vendu**. Depuis, le marché a repris **+24 %** *[à valider]*. » [Voir sur la frise]

Le texte varie selon le choix et le résultat, sans jamais moraliser : si vendre était le bon choix à 12 mois, on le dit aussi.

### 3.9 Le moment euro (1er janvier 2002)

```
            ┌──────────────────────────────────────────────────┐
            │              1er JANVIER 2002                    │
            │           BONJOUR L'EURO !                       │
            │      [ pièce de 1 € qui tourne : coin-spin ]     │
            │                                                  │
            │        1 € = 6,55957 F                           │
            │                                                  │
            │  Votre patrimoine      412 300 F  →  62 855 €    │
            │  Une baguette              4,60 F  →  0,70 €     │
            │  Votre salaire          14 200 F  →  2 165 €     │
            │                                                  │
            │  Astuce : divisez par 6,5… ou par 7 de tête.     │
            │  Les francs restent affichés en petit un an.     │
            │                  [  Adieu le franc !  ]          │
            └──────────────────────────────────────────────────┘
```

- À la fermeture, `euro-flip` fait basculer **tous** les montants visibles, puis le symbole de la frise passe de F à €. Les graphiques sont convertis rétroactivement en euros (axe unique), avec une ligne verticale « Passage à l'euro ».
- On réutilise ce composant pour le nouveau franc de 1960 (« 100 anciens francs = 1 nouveau franc »).

### 3.10 Fins de partie anticipées

**Objectif atteint plus tôt** : modale avec des confettis légers (40 particules).

```
            ┌──────────────────────────────────────────────────┐
            │          OBJECTIF ATTEINT !                      │
            │  Vous avez réuni votre apport de 80 000 F        │
            │  en juin 1984, avec 20 mois d'avance.            │
            │  [ Voir mon bilan ]   [ Continuer en partie libre ]│
            └──────────────────────────────────────────────────┘
```

En partie libre, la jauge d'objectif est remplacée par « Objectif atteint en juin 1984 ✓ » et la frise continue jusqu'à la fin prévue.

**Faillite** (découvert au-delà du nombre de mois toléré) : pas de « Game Over ». La modale « courrier » de la banque annonce : « Votre banquier a confisqué votre chéquier. Vous finissez chez votre belle-mère. » [Voir mon bilan]. Le bilan qui suit est complet, avec une teinte sépia et sans confettis.

**Abandon** : menu ☰ → « Terminer et voir mon bilan », après confirmation.

### 3.11 Bilan de fin

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│                       DÉCEMBRE 1992 · QUINZE ANS PLUS TARD                               │
│                                                                                          │
│   VOTRE PATRIMOINE FINAL                                                                 │
│   61 300 € d'aujourd'hui (?)        = 214 000 F de 1992 · 22 400 baguettes               │
│                                                                                          │
│  ┌─ LA COURSE ──────────────────────────────────────┐ ┌─ QUINZE ANS EN UN COUP D'ŒIL ──┐ │
│  │ 1  (C) Cousin Indice  ████████████████████ 68 200│ │      ╭╮        ╭──── Cousin    │ │
│  │ 2  (G) VOUS           ██████████████████   61 300│ │   ╭──╯╰─╮ ╭───╯───── Vous     │ │
│  │ 3  (L) Tata Livret    ███████████          39 800│ │ ╭─╯─────╰─╯──────── Livret    │ │
│  │ 4  (M) Tonton Matelas ██████               21 500│ │ ╯──────────────────── Matelas │ │
│  │ « Le Cousin a tenu bon en 87. Pas vous. »        │ │ ◆87  ◆90                      │ │
│  └──────────────────────────────────────────────────┘ └────────────────────────────────┘ │
│                                                                                          │
│   OBJECTIF · Battre l'inflation   [████████████████████████] Atteint · +142 %            │
│                                                                                          │
│              ★ ★ ★ ★ ☆   (?)        ╔══════════════════════════════╗                     │
│                                     ║   « FOURMI DU LIVRET A »     ║  ← tampon           │
│                                     ╚══════════════════════════════╝                     │
│                                                                                          │
│   LES 3 LEÇONS DE VOTRE PARTIE                                                           │
│   ┌──────────────────────────┐ ┌──────────────────────────┐ ┌──────────────────────────┐ │
│   │ ▼ Vous avez tout vendu en│ │ ▲ Votre coussin vous a   │ │ ● 38 % de votre argent a │ │
│   │ novembre 1987, au plus   │ │ sauvé en avril 1985 : la │ │ dormi sur le compte      │ │
│   │ bas. Deux ans plus tard :│ │ voiture payée sans rien  │ │ courant. L'inflation en a│ │
│   │ +48 %.                   │ │ vendre à perte.          │ │ mangé 31 %.              │ │
│   │ [Voir sur la frise]      │ │ [Voir sur la frise]      │ │                          │ │
│   └──────────────────────────┘ └──────────────────────────┘ └──────────────────────────┘ │
│                                                                                          │
│   ┌────────────────────────────────────────────┐                                         │
│   │  ↻  REJOUER LA MÊME PÉRIODE AUTREMENT      │   Nouvelle partie   ·   Revoir ma frise │
│   └────────────────────────────────────────────┘                                         │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

**Séquence de révélation** (environ 8 s au total ; un clic ou `Espace` passe à l'étape suivante, et un double clic affiche tout) :

| t | Étape | Animation |
|---|---|---|
| 0,0 s | Rideau « Quinze ans plus tard… » | `fade-in` 400 ms |
| 0,6 s | Patrimoine final | `count-roll` 1 500 ms de 0 à la valeur |
| 2,2 s | La course : barres et courbes | `bar-race` 2 000 ms, barres classées à la fin, ligne « VOUS » en surbrillance ; les courbes se dessinent avec `line-draw` en même temps |
| 4,4 s | Réplique du témoin le mieux classé (ou du pire, s'il est devant vous) | `fade-in` |
| 4,8 s | Jauge d'objectif | remplissage 800 ms |
| 5,6 s | Étoiles | `star-pop` ×5, 200 ms chacune |
| 6,8 s | Titre | `stamp` 350 ms + `screen-thud` |
| 7,2 s | 3 leçons | `card-flip` en cascade, 150 ms d'écart |
| 7,8 s | Bouton Rejouer | `pulse-cta` en boucle douce |
| 8,0 s | Confettis | si objectif atteint ou au moins 2 témoins battus ; 2,5 s |

- **Les états selon le résultat** :
  - *triomphe* (les 3 témoins battus) : confettis complets et bandeau « Vous avez battu toute la famille ! » ;
  - *moyen* : pas de confettis, la réplique d'un témoin taquine gentiment ;
  - *faillite* : teinte sépia, illustration humoristique, et une leçon n° 1 toujours consacrée au coussin.
- **« Revoir ma frise »** : l'écran principal en lecture seule, au dernier mois, avec tous les marqueurs cliquables. On ne peut pas modifier la partie.
- **Les titres** sont une table de règles dans les données (condition → titre), évaluées dans l'ordre. Le premier qui correspond gagne. Les titres obtenus sont mémorisés localement (« 4 titres sur 20 découverts » en bonus).
- **Les leçons** sont choisies dans une bibliothèque de gabarits, chacun avec une condition et un score d'importance (vente en panique > coussin insuffisant > argent qui dort > frais élevés > absence de diversification > bonne décision à saluer). On garde les 3 meilleures, dont **au moins une positive** si possible.

### 3.12 Menu ☰ et options

```
┌──────────────────────────────┐
│ ▶ Reprendre                  │
│   Glossaire                  │
│   Historique des événements  │
│   Options                    │
│   Terminer et voir le bilan  │
│   Retour à l'accueil         │  (sauvegarde automatique avant)
└──────────────────────────────┘
```

**Options** (mémorisées dans `localStorage`, séparées de la sauvegarde de partie) :
- Sons : désactivés (par défaut) / activés ; volume.
- Animations : normales / réduites. La valeur par défaut suit `prefers-reduced-motion`.
- Taille du texte : normale / grande (`html { font-size: 112.5% }`).
- Couleurs des gains et pertes : vert/rouge (par défaut) / bleu/orange (daltonisme).
- Pause automatique à l'ouverture du marché : oui (par défaut) / non.
- Afficher l'équivalent dans l'autre monnaie : automatique (par défaut) / toujours / jamais.

**Sauvegarde** : automatique à chaque mois de janvier, à chaque pause manuelle, à chaque fermeture de modale et sur `beforeunload`. Un seul emplacement, comme le demande le client.

---

## 4. La frise du temps

### 4.1 Anatomie

```
 1978  1979  1980  1981  1982  1983  1984  1985  1986  1987  1988 … 1992  1993
 ┊     ┊     ┊     ┊     ┊     ┊     ┊     ┊     ┊     ┊     ┊      ┊     ┊
 ████████████████████████████████████●─────────────────────────────────────── ⚑
   ◆      ●   ◆ ◆      ◆●     ●      ▲                        ★     ⌂
   └─ marqueurs passés (pleins,      └─ curseur : date        └─ à venir : nouveauté (★),
      cliquables)                       courante                 échéance d'objectif (⌂), fin (⚑)
```

- **Une barre pleine largeur = toute la partie** (15 ans = 180 mois). Graduation par année (un trait et un libellé). Avec 25 ans, on n'affiche le libellé qu'une année sur deux.
- **Partie passée** remplie en `--accent`, **partie à venir** en `--line`. Le curseur est un rond de 16 px avec une ombre ; au survol, il affiche « mars 1984 ».
- **Le curseur glisse en continu** (pas de saut mois par mois). Sa position vaut `(moisÉcoulés + progressionDuMois) / totalMois`, recalculée à chaque `requestAnimationFrame` : c'est fluide, et sans transition CSS à synchroniser.
- **On ne voyage pas dans le temps** : cliquer sur la frise ne fait pas avancer ni reculer la partie.

### 4.2 Contrôles et rythme

```
 [❚❚] [ ▶ ] [▶▶] [▶▶▶]
  P/␣   1     2     3      ← raccourcis affichés au survol
```

| Vitesse | Durée réelle d'un mois | 1 an de jeu | 15 ans sans pause | Usage |
|---|---|---|---|---|
| ❚❚ Pause | — | — | — | Réfléchir, passer des ordres. |
| ▶ ×1 | **4 s** | 48 s | 12 min | Rythme par défaut après le tutoriel. |
| ▶▶ ×2 | 2 s | 24 s | 6 min | Périodes calmes. |
| ▶▶▶ ×3 | 1 s | 12 s | 3 min | « Je n'ai rien à faire, avance. » |

**Estimation d'une partie standard** : environ 12 min de temps à ×1, plus le tutoriel (2 min), plus les modales (environ 15 × 20 s = 5 min), plus les pauses de réflexion, moins le temps gagné en ×2 et ×3. On tombe à **15 à 22 minutes**, dans la fourchette du client.

- **La vitesse est conservée après une modale** : le jeu reprend à la vitesse d'avant, sauf après un événement de marché, où il reste en pause (§ 3.5).
- **Pause automatique** pour toute modale, à l'ouverture du tiroir (option), quand la fenêtre est masquée (`visibilitychange`) et à la fin du tutoriel de chaque étape bloquante.
- **« Plus c'est rapide, moins c'est décoré »** : en ×3, on supprime `coin-fly` et les flashs des lignes de placement, et `count-roll` dure au maximum la moitié d'un mois. Seul le total clignote.
- **Bouton actif** : fond `--accent`, texte blanc, `aria-pressed="true"`. Les 4 boutons forment un groupe radio accessible.

### 4.3 Marqueurs

| Marqueur | Forme et couleur | Passé | À venir |
|---|---|---|---|
| Événement de marché | ◆ losange, `--ink` (contour rouge si baisse, vert si hausse) | Oui, cliquable : rouvre la manchette en lecture seule, avec le choix fait et le résultat à 12 mois s'il est connu. | **Jamais.** Montrer « krach en octobre 1987 » reviendrait à donner la réponse : le joueur vendrait la veille, ce qui contredit la leçon. |
| Événement de vie | ● rond, `--accent` | Oui, cliquable : rouvre le courrier. | Non (c'est aléatoire). |
| Nouveau produit | ★ étoile, `--warn` | Oui : nom du produit. | **Oui, mais en mystère** : « ★ Nouveauté en 1992 », sans le nom. Ça crée l'anticipation des Sims sans rien dévoiler du marché. |
| Monnaie | ¤ | 1960, 2002. | 2002 est affiché dès 1999 (« L'euro arrive »), comme dans la vraie vie. |
| Échéance d'objectif | ⌂ maison ou ⚑ drapeau | — | Oui, toujours. |
| Fin de partie | ⚑ au bout | — | Oui. |
| Mes ordres *(bonus)* | petits traits sous la barre : ▲ achat, ▼ vente | Oui | — |

- Un nouveau marqueur passé apparaît avec `marker-pulse` (2 ondes).
- Quand des marqueurs se chevauchent (même mois), ils s'empilent verticalement (3 au maximum, puis « +2 »).

### 4.4 Date et monnaie

- **Date** : mois en toutes lettres et année, en capitales dans la barre haute (`MARS 1984`), en minuscules ailleurs (« mars 1984 »). Au changement de mois, `date-flip` (100 ms vers le haut, 150 ms d'entrée).
- **Format des montants** : `Intl.NumberFormat('fr-FR')`, avec une espace fine insécable comme séparateur de milliers.
  - Pas de centimes au-delà de 1 000 (`38 450 F`), 2 décimales en dessous et pour les prix unitaires (`141,20 F`, `0,70 €`).
  - Au-delà de 10 millions : `12,4 M F` (très rare).
  - Les variations portent toujours un signe et une flèche : `▲ +2,1 %`, `▼ −3 400 F`. On utilise le vrai signe moins (`−`, U+2212), pas le tiret.
  - Symboles : `AF` (anciens francs, avant 1960), `F` (francs), `€`.
- **Double affichage** (phases 2 et 4 du § 1, Q6) : la valeur secondaire est écrite en petit (0,8 em), en `--ink-2`, sous la valeur principale ou à droite : `412 300 F` `≈ 62 855 €`.

---

## 5. L'onboarding progressif

### 5.1 Les trois formes d'explication

| Forme | Quand | Aspect | Règle |
|---|---|---|---|
| **Bulle coach** | Tutoriel et toute première rencontre d'une notion | Bulle sombre (`--ink` sur fond, texte blanc) avec une flèche vers l'élément. L'élément est mis en lumière par `spotlight` (`box-shadow: 0 0 0 9999px rgba(0,0,0,.55)`). | 2 lignes au maximum (environ 120 caractères). Une seule à la fois. Elle se ferme en faisant l'action demandée ou par « OK ». |
| **« C'est quoi ? »** (glossaire au survol) | Toujours disponible | Mot souligné en pointillés ou icône `(?)`. Bulle claire après 300 ms de survol, ou sur focus clavier, ou au clic (pour le tactile). | 2 lignes au maximum. Pas de lien vers un « cours ». Les définitions viennent d'un fichier de données. |
| **« Le saviez-vous ? »** | Mois calmes (aucun événement depuis 6 mois), au maximum 1 tous les 18 mois | Notification à bandeau jaune `--warn-bg`, 8 s. | Anecdote d'époque ou rappel de notion. Jamais la même deux fois dans une partie. |

**Règle d'or** : jamais plus d'**une** information pédagogique par mois de jeu, et chaque notion n'est expliquée en bulle coach qu'**une fois par partie** (liste `notionsVues` dans la sauvegarde). Le glossaire reste toujours accessible.

### 5.2 Le tutoriel : la première année (si « Me guider » est coché)

| Étape | Moment | Bulle (2 lignes au maximum) | Action attendue | Notion |
|---|---|---|---|---|
| T1 | Mois 1, jeu en pause | Sur le compte courant : « Votre salaire tombe ici chaque mois. Le loyer et les courses partent aussitôt. » | Aucune ; bouton « OK » | Budget |
| T2 | Juste après | Sur ▶ : « Le temps est en pause. Lancez-le ! Espace pour mettre en pause à tout moment. » | Clic sur ▶ | Contrôle du temps |
| T3 | Mois 2, pause auto | Sur *Coussin de sécurité* : « Un imprévu arrive toujours. Mettez 3 mois de dépenses de côté sur le livret A. » | Ouvrir le tiroir et déposer sur le livret (montant prérempli) | Épargne de précaution, livret A |
| T4 | Mois 3, sans pause | Sur la baguette : « La baguette a pris 0,05 F en 2 mois. Les prix montent : c'est l'inflation. » | Aucune (disparaît après 6 s) | Inflation |
| T5 | Mois 4, pause auto | Sur *Mes placements* : « Les actions montent et descendent, mais rapportent plus à long terme. Essayez avec un petit montant ? » | Achat facultatif : [Essayer] ou [Plus tard] | Action, risque |
| T6 | Mois 6, pause auto | Sur la case « Versement automatique » : « Un petit montant chaque mois, sans y penser : c'est la méthode de Cousin… vous verrez. » | Facultatif | Versement programmé |
| T7 | Mois 7 à 9 | **Premier événement de vie scripté**, petit et positif (prime) | Clic sur « Encaisser » | Courrier, choix |
| Fin | Mois 12 | Premier **bilan annuel** (§ 3.8) et bulle : « C'est vous qui pilotez, maintenant. Bonne chance ! » | — | Lecture du bilan annuel |

Le bouton « Passer le tutoriel » reste dans un coin de chaque bulle. Si un événement de marché tombe pendant la première année (cas de la période 2008), il a priorité et l'étape en cours est décalée d'un mois.

### 5.3 Les notions qui arrivent ensuite, en situation

| Notion | Déclencheur en jeu | Forme | Texte d'exemple |
|---|---|---|---|
| Intérêts | Premier versement d'intérêts du livret | Bulle coach sur la ligne livret + `float-up` « +860 F » | « Le livret vous a versé 860 F d'intérêts. L'an prochain, ces 860 F rapporteront aussi. » |
| Intérêts composés | 3e versement d'intérêts | Bulle sur la courbe (écart avec le pointillé) | « Vous voyez l'écart qui grandit ? Ce sont vos intérêts qui rapportent des intérêts. » |
| Dividende | Premier dividende reçu | `dividend-ding` + bulle | « L'entreprise partage ses bénéfices : c'est un dividende. Vous l'avez reçu sans rien vendre. » |
| Frais | Premier achat d'action ou de SICAV | Ligne « Frais » soulignée et bulle dans le tiroir | « Chaque achat coûte des frais. Acheter et vendre souvent, c'est payer souvent. » |
| Volatilité / krach | Premier événement de marché négatif | Dans la manchette + carte de rappel à 12 mois | (porté par l'événement lui-même) |
| Plus-value et impôt | Première vente gagnante | Bulle dans l'onglet Vendre | « Vous avez gagné 1 170 F : c'est une plus-value. L'État en prend une part. » |
| Enveloppe fiscale (PEA) | Déblocage du PEA, puis première vente hors PEA quand le PEA existe | Notification « Nouveau », puis ligne comparative dans l'onglet Vendre | « Dans un PEA, vous auriez gardé ces 187 F. » |
| Diversification | Plus de 60 % du patrimoine sur une seule action | Notification douce (une fois) | « Tous vos œufs sont dans le même panier. Si cette entreprise trébuche… » |
| Épargne de précaution (bis) | Premier coup dur payé en vendant à perte | Bulle dans le courrier | « Vendu à −18 % pour payer le garagiste. Un coussin plus épais vous l'aurait évité. » |
| Pouvoir d'achat, € d'aujourd'hui | Bilan de fin (§ 3.11), passage à l'euro | `(?)` à côté du chiffre | « Ce que vaudrait votre argent avec les prix d'aujourd'hui. » |
| Indice, ETF | Déblocage de l'ETF | Notification « Nouveau » | « Un ETF achète d'un coup toutes les grandes entreprises de l'indice. Un panier tout fait. » |

### 5.4 Glossaire

Une vingtaine d'entrées, chacune de 2 lignes au maximum, dans un fichier de données `glossaire.js` (contenu à valider par le banquier et le boursier) : inflation, pouvoir d'achat, intérêts, intérêts composés, livret A, action, dividende, obligation / emprunt d'État, SICAV, indice (CAC 40), ETF, PEA, compte-titres, frais de courtage, droits de garde, plus-value, diversification, épargne de précaution, versement programmé, découvert, € d'aujourd'hui. Le glossaire complet est consultable depuis le menu ☰, trié par ordre alphabétique, et **les notions non encore rencontrées y sont grisées** (petite récompense de collection).

---

## 6. Feedbacks et animations

Toutes les durées sont divisées par 2 en ×3. Avec « Animations réduites » ou `prefers-reduced-motion`, on garde seulement les fondus d'opacité (≤ 150 ms) et les changements de couleur : pas de déplacement, de rotation ni de confettis.

### 6.1 Catalogue

| Nom | Déclencheur | Durée | Effet (CSS / JS) | Priorité |
|---|---|---|---|---|
| `count-roll` | Tout montant qui change | 400 ms (≤ ½ mois), 1 500 ms au bilan | JS : interpolation `requestAnimationFrame`, easing `easeOutCubic`, `font-variant-numeric: tabular-nums` pour éviter que le texte tremble | V1 |
| `flash-gain` / `flash-loss` | Variation mensuelle d'un total ou d'une ligne | 600 ms | `@keyframes` sur `background-color` de `--gain-bg` / `--loss-bg` vers transparent ; la flèche ▲/▼ reste affichée | V1 |
| `date-flip` | Nouveau mois | 250 ms | Ancienne date `translateY(-100%)` + `opacity 0`, nouvelle date depuis `translateY(100%)` | V1 |
| `pause-breathe` | État pause | 2 s en boucle | `opacity` du cadre et du badge de 0,45 à 1, `alternate infinite` | V1 |
| `paper-drop` | Événement de marché ordinaire | 450 ms | `transform: scale(2.2) rotate(-14deg)` → `scale(1) rotate(-1.5deg)`, `opacity 0→1`, `cubic-bezier(.2,1.3,.4,1)` (léger rebond) | V1 |
| `paper-spin` | Krach ou grande crise (`gravite: "majeure"`) | 700 ms | `scale(.1) rotate(0)` → `scale(1) rotate(720deg)`, `ease-out` ; le journal qui tourne des vieux films | V1 |
| `screen-thud` | Fin de `paper-drop` / `paper-spin`, tampon du bilan | 160 ms | Sur `#app` : `translateY(0 → 4px → -2px → 0)` | V1 |
| `backdrop-in` | Ouverture d'une modale | 200 ms | Fond `rgba(20,16,10,.6)` en `opacity 0→1` | V1 |
| `letter-slide` | Modale courrier | 350 ms | `translateY(40px) rotate(2deg)` → `0`, `opacity 0→1` | V1 |
| `drawer-slide` | Tiroir marché | 250 ms ouverture / 200 ms fermeture | `translateX(100%)` → `0`, `ease-out` | V1 |
| `toast-in` / `toast-out` | Notifications | 250 / 200 ms | `translateY(16px)` + `opacity` | V1 |
| `float-up` | Intérêts, dividende, prime | 1 000 ms | Texte « +860 F » créé près de la ligne : `translateY(0 → -36px)`, `opacity 1 → 0` | V1 |
| `unlock-pop` | Nouveau produit disponible | 400 ms + balayage 800 ms | `scale(.85 → 1.05 → 1)` ; reflet par `linear-gradient` animé en `background-position` | V1 |
| `marker-pulse` | Nouveau marqueur sur la frise | 2 × 600 ms | Pseudo-élément `::after` : anneau `scale(1 → 2.4)`, `opacity .8 → 0` | V1 |
| `shake-alert` | Premier mois de découvert, achat refusé | 300 ms | `translateX(0, -4px, 4px, -3px, 3px, 0)` | V1 |
| `line-draw` | Nouveau point de courbe, courbes du bilan | 300 ms (jeu) / 2 000 ms (bilan) | SVG : `stroke-dasharray` = longueur, `stroke-dashoffset` de la longueur à 0 | V1 |
| `bar-race` | Bilan : la course | 2 000 ms | `width` 0 → valeur, `ease-out` ; tri final par `order` après la fin | V1 |
| `stamp` | Titre humoristique | 350 ms | `scale(2.6) rotate(10deg)`, `opacity 0` → `scale(1) rotate(-4deg)`, `opacity 1`, `cubic-bezier(.3,1.6,.5,1)`, puis `screen-thud` | V1 |
| `star-pop` | Étoiles du bilan | 200 ms × 5 en cascade | `scale(0 → 1.25 → 1)` ; une étoile vide apparaît en simple fondu | V1 |
| `card-flip` | Leçons du bilan | 400 ms, 150 ms d'écart | `rotateY(90deg → 0)` avec `perspective: 800px` | V1 |
| `pulse-cta` | Bouton Rejouer | 1,6 s en boucle | `box-shadow` de 0 à `0 0 0 8px` accent à 30 % | V1 |
| `confetti` | Bilan réussi, objectif atteint | 2 500 ms | Canvas plein écran, 120 rectangles (40 pour l'objectif), gravité et rotation ; environ 60 lignes de JS, puis le canvas est supprimé | V1 |
| `euro-flip` | Passage à l'euro (et nouveau franc) | 600 ms, 30 ms d'écart par montant | `rotateX(0 → 90deg)`, changement du texte, `rotateX(-90deg → 0)` | V1 |
| `coin-spin` | Modale euro | 1,2 s en boucle | Disque SVG `rotateY(360deg)` | P1 |
| `card-lift` | Survol d'une carte de choix | 150 ms | `translateY(-4px)` + ombre plus forte | V1 |
| `coin-fly` | Salaire versé (×1 seulement), achat confirmé | 500 ms | Pastille de pièce en `position: fixed`, `transform` de la source vers la cible (calculé par `getBoundingClientRect`), `cubic-bezier(.5,0,.5,1)` | P1 |
| `coin-rain` | Héritage, gros gain | 800 ms | 10 pièces SVG qui tombent sur la valeur du compte, `animation-delay` aléatoire | P1 |
| `dividend-ding` | Premier dividende | 600 ms | Halo doré `box-shadow` sur la ligne + `float-up` ; le « ding » sonore seulement si les sons sont actifs | V1 (visuel) |
| `crash-vignette` | Patrimoine à plus de 15 % sous son plus haut | entrée 1 s, maintien | `#app::before` : `box-shadow: inset 0 0 120px rgba(179,38,30,.25)` en fondu | Bonus |
| `era-shift` | Changement de décennie | 1 s | `transition: background-color 1s, color 1s` sur les éléments qui utilisent `--accent` | P1 |

### 6.2 Extrait CSS de référence

```css
@keyframes flash-gain { from { background-color: var(--gain-bg); } to { background-color: transparent; } }
@keyframes flash-loss { from { background-color: var(--loss-bg); } to { background-color: transparent; } }
.flash-gain { animation: flash-gain .6s ease-out; }
.flash-loss { animation: flash-loss .6s ease-out; }

@keyframes paper-spin {
  from { transform: scale(.1) rotate(0deg);   opacity: 0; }
  60%  { opacity: 1; }
  to   { transform: scale(1)  rotate(720deg); opacity: 1; }
}
@keyframes paper-drop {
  from { transform: scale(2.2) rotate(-14deg); opacity: 0; }
  to   { transform: scale(1)   rotate(-1.5deg); opacity: 1; }
}
.journal.spin { animation: paper-spin .7s ease-out both; }
.journal.drop { animation: paper-drop .45s cubic-bezier(.2,1.3,.4,1) both; }

@keyframes stamp {
  from { transform: scale(2.6) rotate(10deg); opacity: 0; }
  to   { transform: scale(1)   rotate(-4deg); opacity: 1; }
}
@keyframes pause-breathe { from { opacity: .45; } to { opacity: 1; } }
.is-paused #app { outline: 4px solid var(--pause); outline-offset: -4px; }
.is-paused .badge-pause { animation: pause-breathe 2s ease-in-out infinite alternate; }

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { animation-duration: 1ms !important; animation-iteration-count: 1 !important;
                           transition-duration: 1ms !important; }
}
```

Le JS pose la classe, puis la retire sur `animationend` (une fonction utilitaire `play(el, 'flash-gain')` de 5 lignes suffit).

### 6.3 Sons (optionnels, désactivés par défaut)

Ils sont **synthétisés en Web Audio** : aucun fichier, donc rien à charger hors ligne. Il y a 4 sons au maximum, chacun en moins de 10 lignes :

| Son | Déclencheur | Recette |
|---|---|---|
| `ding` | Dividende, intérêts | Sinus 1 320 Hz, attaque 5 ms, extinction exponentielle 400 ms |
| `thud` | Journal qui tombe | Bruit blanc filtré passe-bas à 300 Hz, 120 ms |
| `cha-ching` | Prime, héritage, objectif atteint | Deux sinus 880 et 1 320 Hz décalés de 80 ms |
| `stamp` | Tampon du bilan | Bruit filtré à 800 Hz, 60 ms |

L'icône de haut-parleur barré se trouve dans le menu et dans les options. Le premier son n'est joué qu'après une interaction de l'utilisateur, à cause des règles d'autoplay des navigateurs.

---

## 7. Direction artistique

### 7.1 Palette (variables CSS)

L'ambiance est **« papier et encre »** : un fond crème chaleureux, du texte presque noir, une couleur d'accent qui change avec l'époque. Tous les couples texte/fond ci-dessous ont été vérifiés à **4,5:1 au minimum** (WCAG AA).

```css
:root {
  /* Fonds et texte */
  --bg:          #F6F1E7;  /* papier crème, fond de l'application */
  --surface:     #FFFFFF;  /* cartes, colonnes, tiroir */
  --surface-2:   #EFE8DA;  /* en-têtes de colonnes, zones inactives */
  --line:        #D8CFBF;  /* bordures, frise à venir */
  --ink:         #1E1B16;  /* texte principal (≈ 15:1 sur --bg) */
  --ink-2:       #5A5348;  /* texte secondaire (≈ 7:1 sur --bg) */

  /* Accent (redéfini par décennie, § 7.3) */
  --accent:      #1F4E79;  /* boutons principaux, curseur, frise passée */
  --accent-ink:  #FFFFFF;  /* texte sur l'accent */

  /* Sémantique */
  --gain:        #1B7A3E;  --gain-bg: #DFF2E5;   /* ≈ 5,4:1 sur blanc */
  --loss:        #B3261E;  --loss-bg: #FBE3E1;   /* ≈ 6,5:1 sur blanc */
  --warn:        #8A5A00;  --warn-bg: #FFF1CC;
  --pause:       #D98A00;  /* cadre de pause : jamais utilisé pour du texte */

  /* Journal (redéfini par décennie) */
  --journal-paper: #F3EAD3;
  --journal-ink:   #1A1A1A;
  --font-headline: Georgia, "Times New Roman", Times, serif;
  --headline-case: uppercase;

  /* Catégories de placements (barre de répartition, courbes du bilan) */
  --cat-cash:    #8A8A8A;  /* compte courant : gris, uni */
  --cat-livret:  #2E86AB;  /* livret : bleu, rayures fines */
  --cat-oblig:   #6C5B7B;  /* obligation : violet, points */
  --cat-fonds:   #3F8F6B;  /* SICAV : vert sapin, rayures obliques */
  --cat-actions: #C8553D;  /* actions : brique, uni */
  --cat-etf:     #D99A2B;  /* ETF : ocre, quadrillage */

  /* Témoins (bilan) */
  --t-matelas: #8A8A8A;  --t-livret: #2E86AB;  --t-indice: #D99A2B;  --t-vous: var(--accent);
}

/* Option daltonisme : bleu / orange au lieu de vert / rouge */
:root[data-cb="1"] {
  --gain: #1565C0; --gain-bg: #E1ECFA;
  --loss: #C2410C; --loss-bg: #FDE8DC;
}
```

**Remarque** : le nom du journal par décennie (« La Gazette », « LaGazette.fr »…) n'est pas une variable CSS. Il s'écrit soit par `content: "…"` dans un pseudo-élément propre à chaque `[data-era]`, soit par une petite table en JS. Les deux solutions sont triviales.

### 7.2 Typographies (système, disponibles hors ligne)

| Rôle | Pile de polices | Usage |
|---|---|---|
| Interface | `"Segoe UI", system-ui, -apple-system, "Helvetica Neue", Arial, sans-serif` | Tout le texte courant. |
| Chiffres clés | `Bahnschrift, "Segoe UI", system-ui, sans-serif` + `font-variant-numeric: tabular-nums` | Date, totaux, bilan. Bahnschrift (Windows 10 et plus) a un style « tableau de bord » très lisible. |
| Journal | `var(--font-headline)`, qui varie par décennie (§ 7.3) | Manchettes uniquement. |
| Courrier | Police d'interface, en graisse 600 | Événements de vie. |

**Tailles** (base de 16 px = 1 rem) : texte courant 1 rem ; secondaire 0,875 rem (**jamais moins de 14 px**) ; titres de colonne 0,8125 rem en capitales espacées (seule exception, en `--ink-2` et en gras) ; totaux 1,75 rem ; date 1,75 rem ; manchette de 2,25 à 2,75 rem ; chiffre du bilan 3,5 rem. Interligne de 1,4, lignes de 60 caractères au maximum dans les modales.

### 7.3 Ambiance par décennie

Les décennies sont gérées par `<body data-era="1980">`, mis à jour au 1er janvier de chaque décennie. On ne touche **qu'à** l'accent, au journal et à la notification de changement de décennie.

| Décennie | Accent UI | Papier journal | Manchette | Nom du journal et détail |
|---|---|---|---|---|
| 1950 | `#7A2E2E` bordeaux | `#EBDFC2` sépia, `filter: sepia(.3)` sur le cadre | Georgia gras, capitales, interlettrage .02em, double filet | « La Gazette », titre centré en Times italique |
| 1960 | `#2D4F8B` bleu roi | `#F0E7CF` | Times New Roman gras, capitales, sur 2 colonnes | « La Gazette », prix en anciens puis nouveaux francs |
| 1970 | `#A64B1F` orange brûlé | `#F2E4C4` | `Rockwell, Georgia, serif`, gras, casse normale | Bandeau supérieur orange et brun |
| 1980 | `#B0174F` framboise | `#F7F3EA` | `Impact, "Arial Black", sans-serif`, capitales serrées | Bandeau « SPÉCIAL » rouge, gros chiffres |
| 1990 | `#00695C` sarcelle | `#FAF8F2` | `"Franklin Gothic Medium", "Arial Narrow", Arial`, capitales | Cartouche de couleur « Économie » |
| 2000 | `#1E5AA8` bleu web | `#FFFFFF` | `Verdana, Tahoma, sans-serif`, gras | « LaGazette.fr », étiquette « FLASH INFO », barre de navigation factice |
| 2010 | `#3949AB` indigo | `#FFFFFF` | `"Segoe UI Semibold", "Segoe UI", sans-serif` | Carte d'application à plat, pastille « ALERTE » |
| 2020 | `#6A1B9A` violet | `#FFFFFF` arrondi, ombre | `"Segoe UI", system-ui` gras 700 | Notification de smartphone : « La Gazette · il y a 2 min » |

Tous ces accents portent du texte blanc à 4,5:1 au minimum. Le journal est **un seul composant HTML** (nom du journal, date, prix, manchette, chapô) : seul le CSS change.

**Les manchettes sont des pastiches** écrits pour le jeu (« Lundi noir : la Bourse de Paris dévisse »). Le journal est fictif (« La Gazette »), sans logo ni nom de titre réel.

### 7.4 Iconographie

Il y a environ 15 pictogrammes SVG en ligne, d'un trait de 2 px, dans un seul fichier `icones.js` : voiture, maison, bébé, cœur, valise, chaudière, enveloppe, pièce, billet, baguette, journal, étoile, drapeau, cadenas, haut-parleur. **On n'utilise pas d'emoji** dans l'interface, car leur rendu varie selon les versions de Windows. Les avatars sont des cercles avec une initiale ; les témoins portent en plus un accessoire simple (béret pour Tonton, lunettes pour Tata, casquette pour Cousin) en bonus.

### 7.5 Accessibilité

- **Contraste** : texte ≥ 4,5:1, gros chiffres et éléments graphiques ≥ 3:1. On ne met jamais de texte sur `--pause` ni sur les couleurs de catégorie (les étiquettes sont posées à côté de la barre).
- **Jamais la couleur seule** : chaque variation porte une **flèche ▲/▼**, un **signe +/−** et une couleur. La barre de répartition utilise des **motifs** (`repeating-linear-gradient`) en plus des teintes, avec des étiquettes en clair. Les courbes du bilan ont des **styles de trait différents** (plein, tirets, points, épais pour « Vous ») et une étiquette en bout de ligne plutôt qu'une légende éloignée.
- **Option daltonisme** bleu/orange (§ 7.1).
- **Clavier** : tout est atteignable avec `Tab`, avec un focus visible (`outline: 3px solid var(--accent); outline-offset: 2px`). Raccourcis : `Espace`/`P` pour la pause, `1`/`2`/`3` pour les vitesses (ou les choix dans une modale), `M` pour le marché, `Échap` pour fermer.
- **Modales** : `role="dialog"`, `aria-modal="true"`, piège du focus, retour du focus à l'élément d'origine.
- **Lecteurs d'écran** : une zone `aria-live="polite"` annonce seulement le changement d'année, les événements et les notifications, pas chaque mois.
- **Lecture** : tous les textes sont lus **jeu en pause** (aucune lecture chronométrée). Phrases courtes, jamais de jargon sans `(?)`.
- **Mouvement** : `prefers-reduced-motion` est respecté, avec une option manuelle. Aucun clignotement au-delà de 3 fois par seconde.
- **Taille** : option « Texte plus grand » (+12,5 %). La mise en page tient jusqu'à 200 % de zoom navigateur grâce à l'empilement des colonnes.

### 7.6 Graphiques : règles pour débutants

- On utilise SVG partout (courbe principale, mini-courbes, bilan). Il y a 180 points au maximum, donc aucun souci de performance. Une seule fonction `tracerCourbe(svg, points, options)` suffit.
- **4 graduations au maximum** sur l'axe vertical, avec des nombres ronds (`20 000 F`) ; axe horizontal en années.
- **L'axe vertical commence à 0** pour la courbe de patrimoine, afin de ne pas dramatiser les variations. Les mini-courbes de prix n'ont pas d'axe : elles montrent seulement une tendance.
- L'aire sous la courbe est remplie à 12 % d'opacité de l'accent, ou de `--loss` pendant un krach.
- Les infobulles de survol affichent seulement la date et la valeur.
- Pas de chandeliers, pas d'indicateurs techniques, conformément à la vision.

---

## 8. Priorités : indispensable V1 et bonus

Effort estimé pour un seul développeur : **S** < ½ journée, **M** de ½ à 2 jours, **L** plus de 2 jours.

### P0 : indispensable V1 (sans cela, la partie ne fonctionne pas ou n'apprend rien)

| # | Élément | Effort |
|---|---|---|
| 1 | Écran principal en 3 colonnes, barre haute, états vide / pause / gain / perte / découvert | L |
| 2 | Frise : barre, curseur continu, 4 contrôles, raccourcis, marqueurs passés cliquables, échéance et fin | M |
| 3 | Boucle de temps à 4 s / 2 s / 1 s par mois, pause automatique (modale, tiroir, fenêtre masquée) | M |
| 4 | Tiroir marché : acheter, vendre, déposer, retirer, frais visibles, impôt à la vente avec comparaison PEA, versement automatique | L |
| 5 | Modale « journal » (événement de marché) avec impact personnel et 3 choix, `paper-drop` / `paper-spin` | M |
| 6 | Modale « courrier » (événement de vie), cas « compte insuffisant → vendre ou découvert », et règle modale ou notification | M |
| 7 | Notifications (événements mineurs, nouveau produit, bilan annuel) | S |
| 8 | Création de partie en 3 étapes et récapitulatif, valeurs par défaut, phrase qui se remplit | M |
| 9 | Écran titre avec Continuer / Nouvelle partie | S |
| 10 | Bilan de fin : chiffre en € d'aujourd'hui, course des 4 barres, jauge d'objectif, étoiles, titre, 3 leçons, bouton Rejouer (même graine) | L |
| 11 | Courbe de patrimoine en SVG avec la ligne « Argent mis de côté », barre de répartition avec motifs | M |
| 12 | Coussin de sécurité et jauge d'objectif dans *Mon mois* | S |
| 13 | Glossaire au survol `(?)` et tutoriel T1 à T7 | M |
| 14 | Monnaie : formatage, F puis double affichage puis €, moment euro avec `euro-flip` | M |
| 15 | Compteur en baguettes (pouvoir d'achat) | S |
| 16 | Animations de base : `count-roll`, `flash-*`, `date-flip`, `pause-breathe`, `toast`, `drawer-slide`, `stamp`, `bar-race`, `star-pop`, `confetti` | M |
| 17 | Palette, typographies, ambiance par décennie (8 blocs CSS), option daltonisme, animations réduites, texte plus grand | S |
| 18 | Accessibilité clavier et focus des modales | S |
| 19 | Sauvegarde automatique unique et options dans `localStorage` | S |

### P1 : V1 si le temps le permet (fort impact, faible coût)

- Carte de rappel à 12 mois après un choix de marché (**je la recommande très fortement** : c'est 30 lignes de code pour la meilleure leçon du jeu).
- Courbes des 4 témoins au bilan (en plus des barres).
- Réplique des témoins selon leur rang.
- « Le saviez-vous ? » (le mécanisme et 5 anecdotes par période).
- Marqueur « ★ Nouveauté à venir » en mystère sur la frise.
- `coin-fly`, `coin-rain`, `unlock-pop`, `marker-pulse`, `era-shift`, `coin-spin`.
- Notification « Bienvenue dans les années 80 ».
- Sons synthétisés (4 sons, désactivés par défaut).
- Historique des événements, « Revoir ma frise » en lecture seule.

### Bonus : V2 et au-delà

- `crash-vignette` et teinte de krach sur l'interface.
- Marqueurs de mes ordres (▲/▼) sur la frise.
- Collection des titres obtenus (« 4 sur 20 ») et glossaire « à collectionner ».
- Prix du plein d'essence et d'autres prix du quotidien.
- Accessoires dessinés des témoins, avatars illustrés par époque.
- Choix libre de l'année (la V1 se limite aux 3 périodes, comme l'envisage le client en repli).
- Thème sombre.
- Disposition adaptée aux tablettes et aux petits écrans.
- Comparaison en direct avec Tata Livret sur la courbe (option).

**Ordre de réalisation conseillé au développeur** : 3 → 2 → 1 (écran statique) → 11 → 4 → 6 → 5 → 7 → 10 → 8 → 9 → 14 → 13 → 16 → reste. On obtient une partie jouable « moche » vers le n° 10, et on habille ensuite.

---

## 9. Dépendances et questions ouvertes

| Pour qui | Besoin |
|---|---|
| Banquier | Série annuelle du **prix de la baguette** (et, en option, du plein d'essence) ; seuil et durée du découvert toléré ; taux d'agios ; frais de courtage et droits de garde par époque ; taux d'impôt simplifié par produit (pour la ligne « dans un PEA, vous auriez payé »). |
| Boursier | Pour chaque événement de marché : manchette, texte de 40 mots au maximum, gravité (`majeure` → `paper-spin`), variation à 12 mois (pour la carte de rappel) ; note « secousses » par période ; libellé court des 3 choix par événement. |
| Client | Validation : (a) barre de répartition au lieu du camembert sur l'écran de jeu ; (b) événements de vie mineurs sans pause ; (c) ordre « 3 périodes d'abord, année libre ensuite » ; (d) baguettes en jeu et € d'aujourd'hui au bilan ; (e) aucun marqueur de marché à venir sur la frise. |
| Développeur | Format des données d'événement : `{ id, type: "marche"\|"vie", mode: "modale"\|"toast", gravite, date, titre, texte, choix[], effets }` ; graine aléatoire enregistrée dans la sauvegarde pour « Rejouer » ; liste `notionsVues` dans la sauvegarde. |
