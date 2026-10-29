# 13 : UX de la progression par le banquier, des frais et de la comparaison avec le Livret A

> Rédigé par le UX designer le 2026-10-27 pour la démo V2 (janv. 1984 → déc. 1988, Gérard). Sources, par ordre de priorité : retours du joueur (`10_retours_joueur.md`), arbitrages du client (`12_arbitrages_v2_demo.md`, y compris §7 : A40 à A45), catalogue et textes du banquier (`11_catalogue_banque.md` : D01 à D08 bis, §2.4, §5). Direction artistique, effets et mise en page : `09_direction_artistique_godot.md`.
> **Ce document modifie 09 sur un point** : toucher la banque ouvre la **fenêtre Banque** (carnet et guichet, § 2), et non plus directement le marché.
> Zones de référence : PC 1 920 × 1 080 ; téléphone en paysage, zone effective ≈ 1 410 × 635 (09 §4.1). Tailles en px virtuels.

---

## 1. La présentation d'un nouveau produit par M. Lefranc

### 1.1 Règles

- **Un appel = un produit** (11 §2.1). Le temps se met en pause et reprend ensuite à la vitesse d'avant.
- **Texte : 60 mots au maximum** (12 R3), c'est-à-dire la réplique D du banquier (11 §4.0). Si le compteur du développeur dépasse 60 mots, la dernière phrase part dans « En savoir plus ».
- **Ticket chiffré** : le chiffre clé de la réplique est répété en gros, **calculé avec l'argent du joueur** (§ 1.3).
- **Comparatif « Par rapport à ce que vous connaissez »** : sur les **4 critères fixes de 12 R8** (rendement, risque, disponibilité, fiscalité), comparés au produit **détenu** le plus proche, sinon au dernier produit présenté (au compte courant pour le Livret A). Plus une ligne **Frais** en clair (pas en pastilles), parce que les frais sont devenus une leçon centrale (A44). *Écart avec la demande de mission, qui citait « frais » parmi les 4 critères : je garde « fiscalité » comme l'exige R8 et j'ajoute les frais en 5e ligne.*
- Chaque critère porte **des pastilles (1 à 3) et un mot** (« faible », « bloqué 4 ans », « sans impôt ») ; la colonne d'écart dit **« plus », « moins » ou « pareil »**, jamais une flèche verte ou rouge : plus de risque n'est ni bien ni mal.
- **3 boutons de même poids** (12 §2.3) : `OUVRIR` (ou `SOUSCRIRE` pour le PEL et l'assurance-vie, `ACHETER` pour les actions), `PAS MAINTENANT`, et le lien `En savoir plus ›`. **Ouvrir et Pas maintenant ont exactement le même style** (`BoutonSecondaire`) : un bouton d'accent pousserait au clic et ferait du banquier un vendeur (A33). Refuser est sans pénalité.
- `Échap`, la croix ou un toucher à l'extérieur valent « Pas maintenant » (c'est une fenêtre d'information, pas une modale à choix : A39).

### 1.2 Mise en page (2 colonnes en paysage)

**PC** : carte de 1 300 × 560 environ, centrée.

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ ╭────╮  M. LEFRANC · votre banquier                     ┌──────────────┐                          ✕  │ en-tête
│ │◠ ◠ │  Banque · février 1986                           │▌ SICAV       │ ← tuile du produit             │ 96 px
│ ╰─▬──╯  NOUVEAU PRODUIT · 5 sur 9                       │▌ ACTIONS     │   (couleur de famille,      │
│                                                         └──────────────┘    pictogramme)             │
├─────────────────────────────────────────────────┬────────────────────────────────────────────────────┤
│ « Votre emprunt d'État vous rapporte 13,4 %,    │ AVEC VOTRE ARGENT                                  │
│   garanti. La SICAV actions, elle, ne garantit  │ ┌────────────────────────────────────────────────┐ │
│   rien : avec 5 000 F, vous possédez un morceau │ │  5 000 F  →  100 F de droits d'entrée          │ │ ticket
│   de dizaines d'entreprises françaises. Une     │ │              puis 1,5 % par an                  │ │ 84 px
│   année peut faire +50 % comme −30 % (1974).    │ └────────────────────────────────────────────────┘ │
│   Comptez 100 F de droits d'entrée et 1,5 % de  │ PAR RAPPORT À VOTRE EMPRUNT D'ÉTAT (vous en avez)  │
│   frais par an, pour de l'argent qui peut       │                SICAV           Emprunt d'État      │
│   attendre 8 à 10 ans. »                        │ Rendement   ●●● espéré*     ●●○ 13,4 % fixe   plus │
│                                                 │ Risque      ●●○ moyen       ●○○ faible        plus │
│ (texte écrit en 1 s au maximum,                 │ Disponible  ●●○ en 2 jours  ●●○ si revendu  pareil │
│  bouche du portrait animée)                     │ Impôt       ●○○ 16 %        ●○○ 16 %        pareil │
│                                                 │ Frais       2 % + 1,5 %/an  aucun                  │
│                                                 │ * espéré, jamais garanti ; le passé ne prédit rien │
├─────────────────────────────────────────────────┴────────────────────────────────────────────────────┤
│  ┌──────────────────────────┐   ┌──────────────────────────┐                  En savoir plus ›      │ 80 px
│  │   OUVRIR UNE SICAV       │   │   PAS MAINTENANT         │                                        │
│  └──────────────────────────┘   └──────────────────────────┘                                        │
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

**Téléphone** (1 330 × 545, même structure) : en-tête de 80 px (portrait de 64 px), colonne de texte de 600 px (8 lignes de 24 px au maximum), lignes du comparatif de 36 px, boutons de 80 px. Hauteur totale ≤ 560 px : **pas de défilement**.

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ ◠◠ M. LEFRANC · févr. 1986 · NOUVEAU 5/9       ▌SICAV ACTIONS                 ✕ │ 80
├──────────────────────────────────────┬───────────────────────────────────────────┤
│ « Votre emprunt d'État vous rapporte │ 5 000 F → 100 F d'entrée, puis 1,5 %/an   │ 72
│   13,4 %, garanti. La SICAV actions, │ VS VOTRE EMPRUNT D'ÉTAT                   │
│   elle, ne garantit rien : avec      │ Rendement  ●●● espéré   ●●○ 13,4 %   plus │ 5 × 36
│   5 000 F, vous possédez un morceau  │ Risque     ●●○ moyen    ●○○ faible   plus │
│   de dizaines d'entreprises… »       │ Disponible ●●○ 2 jours  ●●○ revente pareil│
│                                      │ Impôt      ●○○ 16 %     ●○○ 16 %   pareil │
│                                      │ Frais      2 % + 1,5 %/an   aucun         │
├──────────────────────────────────────┴───────────────────────────────────────────┤
│ [   OUVRIR UNE SICAV   ]   [   PAS MAINTENANT   ]              En savoir plus › │ 80
└──────────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Contenu du ticket chiffré, par présentation

| id | Ticket (montants calculés à la date de l'appel, 11 §4.0) |
|---|---|
| D01 Livret A | « {cc} F → + {cc × taux} F par an, sans impôt » |
| D02 PEL | « {v} F par mois pendant 4 ans → {fv_pel} F » |
| D03 Emprunt d'État | « {m} F prêtés → {m × t} F par an jusqu'en {annee + 10} ({nets} F après impôt) » |
| D04 Assurance-vie (non mariés, A41) | **Ticket à 2 colonnes** (exigé par R6) : « Si vous disparaissiez, Sylvie recevrait : par succession **0 F** · par assurance-vie **{e} F** ». Ligne sous le ticket : « Pour {enfant} (ou vos jumeaux) : pas d'écart sous 275 000 F. » |
| D05 SICAV actions | « {m} F → {m × 0,02} F de droits d'entrée, puis 1,5 % par an » |
| D06 Actions | « Un ordre de {m} F → {max(50 ; 1,3 % × m)} F de courtage » |
| D07 Saint-Gobain | « {m} F → {floor(m / 310)} actions à 310 F, sans courtage » |

Le ticket est un panneau `panneau_eleve` avec un liseré `or`. Les montants sont en `Bahnschrift` 34 px et roulent de 0 à leur valeur en 0,5 s à l'ouverture de la carte (09 effet 5).

### 1.4 « En savoir plus » : le verso de la carte

La carte **se retourne** (`scale.x` 1 → 0 en 0,12 s, changement de contenu, 0 → 1 en 0,15 s, `BACK`/`OUT`). Au verso : la réplique détaillée (11 §4.1), les simplifications du jeu en bulles (?), et pour la SICAV la leçon de frais (§ 3.3). Bouton `‹ Retour` en haut à gauche ; les 3 boutons restent en bas.

### 1.5 Animation d'entrée depuis la banque (≤ 2 s, passable d'un toucher, A34)

Elle prolonge l'appel de 09 effet 1 :

| t | Ce qui se passe | Easing |
|---|---|---|
| 0 | La caméra glisse vers la banque, zoom + 6 % (0,35 s) | `CUBIC`/`IN_OUT` |
| 0,2 s | Le combiné sonne au-dessus du toit, 3 arcs d'ondes (0,6 s) | `SINE` |
| 0,8 s | La porte de la banque s'ouvre (0,2 s) ; **la tuile du produit** en sort, monte en tournant d'un demi-tour et grandit (`scale` 0,3 → 1, 0,5 s) | `CUBIC`/`OUT` |
| 1,3 s | La carte se déplie depuis la tuile (`scale` 0,6 → 1 avec le `pivot_offset` sur la tuile, fondu, 0,35 s) ; la tuile se pose dans l'en-tête | `BACK`/`OUT` |
| 1,65 s | Le texte s'écrit (`visible_ratio`, 1 s au maximum), le ticket roule ; les boutons sont actifs tout de suite (pas de délai : il n'y a pas de piège à éviter) | linéaire |

**Sortie** : quel que soit le choix, la tuile se détache, **retourne dans la banque** en arc (0,5 s) et un point de notification s'allume sur l'étiquette « MA BANQUE » jusqu'à la prochaine ouverture du carnet. Avec `OUVRIR`, la fenêtre Banque s'ouvre directement sur la fiche du produit, formulaire d'ordre affiché, avec un **montant d'exemple seulement** (12 §2.3).

### 1.6 Les autres cartes du banquier

| Carte | Contenu | Pause |
|---|---|---|
| **Présentation** (D01 à D07) | § 1.2 | Oui (compte dans le budget d'interruptions, § 5) |
| **Nouvelle** (D08 : héritage de tante Odette) | Portrait, texte, ticket à 2 colonnes « assurance-vie : 60 000 F, ce mois-ci · succession : 45 000 F nets dans 6 mois », un seul bouton `COMPRIS` | Oui |
| **Message** (baisses du Livret A, D04 bis, D08 bis, L17 après le krach, relevé de décembre) | Notification légère venue de la banque (§ 5.2) ; le toucher ouvre une carte de lecture | Non |

---

## 2. Le carnet du banquier (fenêtre Banque)

### 2.1 Accès

- **Toucher ou cliquer sur la banque** (12 §2.4) ; bouton « Banque » dans le panneau « Mon argent » ; touche `B` sur PC.
- La fenêtre Banque **réunit le carnet et le guichet** : à gauche le carnet, à droite la fiche du produit choisi, puis son formulaire d'ordre (contenu de 04 §3.4, déjà réalisé dans `panneau_marche.gd`). On ne superpose jamais deux fenêtres.
- C'est une fenêtre de bâtiment : un toucher à l'extérieur la ferme (A39). Elle se déplie depuis la banque (09 effet 10) et met le jeu en pause.

### 2.2 Mise en page

**L'album** : les 9 lignes de la démo (12 §3.3) en **grille de 3 × 3 cartes à collectionner**, plus le compte courant en bandeau. La grille tient sans défilement sur téléphone.

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ LA BANQUE · février 1986        Produits découverts : 5 sur 9  █████░░░░                          ✕  │ 64
├─────────────────────────────────────────────┬────────────────────────────────────────────────────────┤
│ COMPTE COURANT   4 210 F · 0 %              │ ▌SICAV ACTIONS FRANCE                     ┌──────────┐ │
│ ┌───────────┐ ┌───────────┐ ┌───────────┐   │ ▌présentée en février 1986                │ ◠◠ relire│ │
│ │▌LIVRET A  │ │▌PEL       │ │▌EMPRUNT   │   │                                           │ la prés. │ │
│ │ 12 400 F  │ │  6 000 F  │ │ D'ÉTAT    │   │ Rendement   ●●● espéré, jamais garanti    └──────────┘ │
│ │ 4,5 %     │ │ 8,25 % ⚿  │ │ 10 000 F  │   │ Risque      ●●○ moyen                                │
│ └───────────┘ └───────────┘ └───────────┘   │ Disponible  ●●○ en 2 jours                           │
│ ┌───────────┐ ┌───────────┐ ┌ ─ ─ ─ ─ ─ ┐   │ Impôt       ●○○ 16 % sur les gains                   │
│ │▌ASSURANCE │ │▌SICAV     │ │     ?     │   │ Frais       2 % à l'entrée + 1,5 % par an            │
│ │ VIE       │ │ ACTIONS   │ │ Une entre-│   │                                                      │
│ │ présentée │ │ NOUVEAU ✦ │ │ prise à   │   │ VOUS AVEZ : rien pour l'instant                      │
│ └───────────┘ └───────────┘ └ ─ ─ ─ ─ ─ ┘   │                                                      │
│ ┌ ─ ─ ─ ─ ─ ┐ ┌ ─ ─ ─ ─ ─ ┐ ┌ ─ ─ ─ ─ ─ ┐   │ ┌──────────────────────┐ ┌──────────────────────┐    │
│ │     ?     │ │     ?     │ │     ?     │   │ │       ACHETER        │ │        VENDRE        │    │
│ │ M. Lefranc│ │ M. Lefranc│ │ Une grande│   │ └──────────────────────┘ └──────────────────────┘    │
│ │vous en par│ │vous en par│ │ première  │   │  (le formulaire d'ordre remplace la fiche ici)       │
│ └ ─ ─ ─ ─ ─ ┘ └ ─ ─ ─ ─ ─ ┘ └ ─ ─ ─ ─ ─ ┘   │                                                      │
├─────────────────────────────────────────────┴────────────────────────────────────────────────────────┤
│ Simplifié : en 1984, le Livret A s'ouvrait à la Caisse d'épargne ou à la Poste. (?)                  │ 36
└──────────────────────────────────────────────────────────────────────────────────────────────────────┘
  PC : grille de 3 × (150 × 128 px), fiche de 780 px. Téléphone : grille de 3 × (140 × 120 px), fiche
  de 820 px, hauteur totale ≤ 580 px. Le bandeau du bas (A40) peut passer dans une bulle (?) sur téléphone.
```

| État d'une carte | Rendu |
|---|---|
| **Détenue** | Couleur de famille pleine, valeur actuelle, variation ▲/▼, cadenas ⚿ si l'argent est bloqué (PEL) ou si un retrait est imposé (assurance-vie de moins de 6 ans) |
| **Présentée, non détenue** | Couleur à 45 %, mention « présentée en {mois année} » |
| **Nouvelle** | Badge « NOUVEAU ✦ » et reflet qui passe toutes les 4 s, jusqu'à la première ouverture de sa fiche |
| **À découvrir** | Silhouette : fond `#0F1522`, contour pointillé `filet`, « ? » et un **indice de besoin**, jamais une date : PEL « Pour un projet de logement », emprunt « Prêter à l'État », assurance-vie « Penser à sa famille », SICAV « Un panier d'entreprises », actions « Une entreprise à soi », Saint-Gobain « Une grande première ». Au toucher : « M. Lefranc vous en parlera le moment venu. » |

Au départ (janv. 1984) : Livret A en « Nouvelle », 8 silhouettes (12 R5 : au moins 5). Aucun produit postérieur à la date jouée, pas de PEA.

**La fiche** reprend les 4 critères et les frais (sans comparaison, en valeur absolue), « Vous avez », et le bouton `relire la présentation` qui rouvre la carte d'appel en lecture seule, avec sa date (12 §2.4). Pour l'assurance-vie, la confirmation d'un retrait affiche le **barème réel** et la date d'exonération : « Impôt sur les gains retirés : 25 % (contrat de 2 à 4 ans). 0 % à partir d'avril 1991. » (A42).

### 2.3 Déblocage animé

À l'ouverture du carnet qui suit une présentation, la carte du produit **se révèle** :

1. la silhouette se retourne (`scale.x` 1 → 0 → 1, 0,3 s) ;
2. la couleur de famille la remplit de bas en haut (0,3 s, `CUBIC`/`OUT`) ;
3. un reflet la traverse (0,4 s), le badge « NOUVEAU ✦ » apparaît avec un pop (`BACK`/`OUT`) ;
4. la jauge « Produits découverts » avance d'un cran et roule (0,4 s), avec un « ting ».

Si plusieurs produits sont à révéler, ils le sont en cascade (0,15 s d'écart).

---

## 3. La pédagogie des frais (A44)

### 3.1 Règles de ton (ne pas culpabiliser)

- On dit « **les frais ont coûté** », jamais « vous avez perdu » ni « votre erreur ».
- On rappelle **ce que les frais paient** (le gérant, l'agent de change, l'assureur) : c'est un prix, pas une faute.
- On montre toujours **une option moins chère** à côté ; le choix reste au joueur.
- Couleur des frais : **cuivre `#C77B4A`** (5:1 sur `panneau`), **jamais le rouge `perte`** : un frais n'est pas une perte de marché.
- Le 7 % est toujours écrit « **hypothèse, pas une promesse** » (12 §7.3).

### 3.2 Les pièces de cuivre (à chaque ordre avec frais)

À la confirmation d'un achat (09 effet 10), les pièces partent du compte vers la banque comme aujourd'hui, mais **les pièces de frais sont en cuivre** (`#C77B4A`, liseré `#8A4F2B`) et se posent sur le petit **compteur de frais** du panneau « Mon argent ». Ce compteur roule : « Frais payés depuis le début : 1 240 F ». Le toucher ouvre le détail : entrée, courtage, gestion, et « + 860 F de gains qui n'ont jamais existé » (jumeau sans frais, 11 §5.2 formule 7). En ×3, pas de pièces : le compteur roule seul.

### 3.3 Le moment fort : la confirmation agrandie (F01)

À la **première souscription d'un produit avec frais** (SICAV, action ou assurance-vie, le premier des trois), la confirmation de l'ordre **s'agrandit** dans la fenêtre Banque en un encart de M. Lefranc (pas de modale en plus : 12 §7.4). Une seule fois par partie.

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│ ✓ ACHETÉ : 5 000 F de SICAV actions France         Frais payés tout de suite : 100 F ◉◉  │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│ ◠◠ « Un mot sur les frais, dont on parle trop peu. Voici vos 5 000 F dans 20 ans, si la  │
│     Bourse montait de 7 % par an (une hypothèse, pas une promesse). »                    │
│                                                                                          │
│        19 350 F                                                                          │
│        ┌──────┐            14 300 F                                                      │
│        │◉◉◉◉◉◉│            ┌──────┐                    11 500 F                          │
│        │◉◉◉◉◉◉│            │◉◉◉◉◉◉│                    ┌──────┐                          │
│        │◉◉◉◉◉◉│            │◉◉◉◉◉◉│                    │◉◉◉◉◉◉│                          │
│        │◉◉◉◉◉◉│            │◉◉◉◉◉◉│                    │◉◉◉◉◉◉│                          │
│        └──────┘            └──────┘                    └──────┘                          │
│      SANS FRAIS        CETTE SICAV                  SICAV PLUS CHARGÉE                    │
│                        2 % + 1,5 %/an               4,5 % + 2,5 %/an                      │
│                        les frais coûtent 5 050 F    ils coûteraient 7 850 F               │
│                                                                                          │
│  Un frais annuel se prend chaque année sur tout le capital, gains compris.  [ COMPRIS ]  │
└──────────────────────────────────────────────────────────────────────────────────────────┘
   (montants pour 5 000 F, 11 §5.3 C ramené à 5 000 F ; calculés pour le montant réellement saisi)
```

- **Les 3 barres** sont des piles de pièces dessinées (ellipses empilées) : le sens « argent » est immédiat. Animation : un compteur d'années va de 0 à 20 en 2 s, les 3 piles montent ensemble et leurs montants roulent ; à la fin, l'écart avec la pile « sans frais » apparaît **en pièces fantômes** (contour seul, au-dessus des piles 2 et 3) avec la mention « gains qui n'ont jamais existé ».
- **Paramètres des 3 barres** (calcul `V = C × (1 − e) × (1 + r − f)^20`, r = 7 %) ; la 3e barre est à confirmer par le banquier :

| Produit souscrit | Barre 2 « ce produit » | Barre 3 « plus chargé » |
|---|---|---|
| SICAV | 2 % + 1,5 %/an | 4,5 % + 2,5 %/an (SICAV maison, 11 §5.3 C) |
| Action | courtage de l'ordre, à l'achat et à la revente | le même montant en 5 petits ordres (5 minimums de 50 F) |
| Assurance-vie | 4 % sur le versement (gestion incluse dans le taux) | 5 % sur le versement + 1 %/an de gestion en plus (à valider) |

- Si la fenêtre est trop étroite (téléphone), le texte de M. Lefranc passe sur une ligne et les piles font 220 px de haut. L'encart tient dans 1 330 × 540.

### 3.4 Les autres moments

| id | Quand | Forme |
|---|---|---|
| **F03** | Dans le formulaire d'ordre, dès que les frais dépassent 2 % du montant | Bandeau cuivre sous le montant : « Petit ordre, gros frais : 50 F, soit 5 %. L'action devra monter d'environ 10,5 % avant de vous rapporter 1 F. » et une **jauge de seuil** (un trait sur une règle de 0 à 15 %). Bouton `Grouper : 2 500 F` qui porte le montant au seuil où les frais retombent à 2 % (50 F / 2 %), si le compte le permet. Non bloquant. |
| **F02** | Chaque décembre, avec le bilan annuel (L21) | **Une seule** notification de la banque, sans pause : « Relevé 1985 : 320 F de frais cette année. Depuis le début : 540 F payés + 210 F de gains qui n'ont jamais existé. » Le toucher ouvre les 3 piles avec les **vrais chiffres** du joueur (sa valeur, sa valeur sans frais). Sans aucun frais dans l'année : le relevé ne parle que des intérêts. |
| **F06** | Écran de fin | Ligne « Frais payés : X F · Tata Livret : 0 F » (§ 4.3). Si le joueur n'a rien souscrit : l'exemple de 10 000 F en 3 piles. |
| Leçon générale | Verso « En savoir plus » de la SICAV | L'exemple du joueur réel : 10 000 F, 0,5 % contre 2,5 % par an, sur 20 ans (35 236 F contre 24 117 F, 11 §5.3 A), avec les mêmes piles |

**Cadence** : en dehors des ordres (F03), au plus **un message sur les frais par année de jeu** (F02).

---

## 4. La comparaison « si tout était resté au Livret A »

### 4.1 État constaté dans le code (2026-10-27)

| Élément | État |
|---|---|
| Moteur | **Prêt** : témoin `temoins["livret"]` (même vie, tout au Livret A dans la limite du plafond, le reste au compte), historique mensuel `hist["livret"]`, fonction `ecart_livret()` dans `etat_partie.gd`, testé dans `tests/test_logique.gd`. |
| Barre haute (`hud.gd`, `maj()`) | **Pas encore affiché** : patrimoine, variation sur 12 mois, baguettes. |
| Courbe de « Mon argent » (`courbe.gd`) | Patrimoine et « argent mis de côté » en pointillé ; **pas de courbe du Livret A**. |
| Modale du krach (`modales.gd`) | Impact sur le patrimoine, phrase « Votre compte et votre Livret A, eux, ne bougent pas » ; **pas d'écart**. |
| Fin de démonstration (`modales.gd`, `fin_demo()`) | Patrimoine, argent mis de côté, placements ; **pas de Tata Livret** ni de frais. |

Le développeur y travaille : ce qui suit est la cible, alignée sur 12 R12.

### 4.2 Pendant la partie

- **Barre haute** (12 R12, R11) : sous le bloc patrimoine, une pastille sur une ligne : `vs tout au Livret A : ▲ + 3 420 F` en `gain`, ou `▼ − 1 150 F` en `perte` (couleurs exigées par R12, toujours avec flèche et signe). Sur téléphone : `vs Livret A ▲ + 3 420 F` (20 px). Tant que le joueur n'a rien d'autre que le Livret A : `= Livret A`, en `texte_2`. Mise à jour chaque mois, avec roulement. **Quand le signe change** : la pastille se retourne (0,25 s) et un montant flottant neutre apparaît (« Vous repassez devant le Livret A » ou « Le Livret A repasse devant »). Le toucher ouvre « Mon argent ».
- **Panneau « Mon argent »** : un bloc « Si tout était resté au Livret A (Tata Livret) : 46 300 F · Vous : + 3 420 F » au-dessus de la courbe. Sur la courbe : la **ligne de Tata Livret** en `#4EA8DE`, en tirets longs (14 px plein, 8 px vide), avec son étiquette en bout de ligne. L'**espace entre la courbe du joueur et celle de Tata** est teinté (`gain` α 0,18 au-dessus, `perte` α 0,18 en dessous) : l'écart se voit sans lire. L'aire sous la courbe du joueur disparaît (trop de remplissages). La ligne « argent mis de côté » reste en pointillé gris fin.
- **Krach** : dans la pastille d'impact du journal, une 2e ligne : « Face au Livret A : ▲ + 2 100 F (+ 8 900 F le mois dernier) ». C'est honnête dans les deux sens : on voit que le krach mange l'avance, pas forcément tout.

### 4.3 L'écran de fin de démonstration (12 §3.5, F06)

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│                      DÉCEMBRE 1988 · CINQ ANS DE LA VIE DE GÉRARD                                 │
│                                                                                                  │
│   VOTRE PATRIMOINE        142 600 F                                 (roule de 0 en 1,5 s)         │
│                                                                                                  │
│   ┌─ VOUS ET TATA LIVRET ───────────────────────────┐  ┌─ CINQ ANS EN UN COUP D'ŒIL ─────────┐   │
│   │ VOUS          ██████████████████████  142 600 F │  │          ╭─╮        ╭── Vous         │   │
│   │ TATA LIVRET   ████████████████        118 900 F │  │     ╭────╯ ╰╲ ╭────╯─ ─ Tata Livret │   │
│   │               ┆ argent mis de côté : 96 000 F    │  │ ────╯─ ─ ─ ─ ╲╯                    │   │
│   │      ┌──────────────────────────────┐            │  │ ●85 naissance  ◆87 krach  ●88 Odette│   │
│   │      │  VOUS : + 23 700 F            │ ← pastille │  └─────────────────────────────────────┘   │
│   │      └──────────────────────────────┘            │                                            │
│   └──────────────────────────────────────────────────┘                                            │
│   Frais payés : 1 240 F  ·  Tata Livret : 0 F          Produits découverts 9/9 · utilisés 4/9     │
│                                                                                                  │
│   « Vos placements ont fait mieux que le Livret A de 23 700 F, krach de 1987 compris. »          │
│                                                                                                  │
│          ┌───────────────────────────┐        ┌───────────────────────────┐                      │
│          │  ↻  REJOUER AUTREMENT     │        │  QUITTER                  │                      │
│          └───────────────────────────┘        └───────────────────────────┘                      │
└──────────────────────────────────────────────────────────────────────────────────────────────────┘
  Téléphone : même écran sans le graphique de droite (bouton « Voir la courbe » à la place).
```

| t | Étape | Animation |
|---|---|---|
| 0 | Iris depuis la maison (09 effet 8), titre | Fondu 0,4 s |
| 0,6 s | Patrimoine | Roulement 1,5 s |
| 2,2 s | Les 2 barres | Course de 1,5 s (`CUBIC`/`OUT`), le trait « argent mis de côté » apparaît ensuite |
| 3,8 s | Pastille d'écart | Roulement 0,8 s ; pluie légère de pièces si l'écart est positif, rien sinon |
| 4,6 s | Courbes | Tracé de 1,5 s avec les marqueurs de la partie |
| 5,0 s | Frais, produits découverts, phrase | Fondu ; un toucher accélère toute la séquence |

**La phrase de synthèse** (une seule, choisie par règle, jamais de reproche) :
- devant Tata : « Vos placements ont fait mieux que le Livret A de {X} F, krach de 1987 compris. » ;
- derrière : « Cette fois, le Livret A a fait mieux de {X} F. Le krach est tombé au mauvais moment : rejouez pour voir ce qui change. » ;
- à égalité (tout au Livret A) : « Vous avez fait comme Tata Livret : sûr et sans frais. Et si vous essayiez autre chose ? »

---

## 5. Notifications légères et appels : la cadence

### 5.1 Ce qui met en pause, ce qui ne met pas en pause

| Interrompt (pause, compte dans le budget) | N'interrompt pas (notification) |
|---|---|
| Présentations D01 à D07 | Baisses du Livret A (A43), avec le taux et l'inflation de l'année ; si le joueur détient un PEL ou un emprunt : « … votre PEL, lui, garde 8,25 % » (D02 bis) |
| Krach et autres événements de marché en modale | Relevé de décembre : bilan annuel L21 et frais F02, **fusionnés** en une seule notification |
| Naissance (cigogne), panne de voiture (accident), autres événements de vie à décision ou coûtant plus d'un mois de salaire | Plafond du Livret A (L03, 06/1987), CAC 40 (06/1988), « Le saviez-vous ? » (1 tous les 18 mois au maximum) |
| Héritage D08 (04/1988) | D04 bis (complément sur l'assurance-vie), L17 (message après le krach), D08 bis (succession réglée) : **messages persistants du banquier** |

Ouvrir soi-même une notification ou la banque met en pause **mais ne compte pas** : c'est le joueur qui choisit.

### 5.2 Les notifications du banquier

- Elles **partent de la banque** : une onde depuis le toit (0,4 s), puis la notification vole vers sa place sous la barre haute (09 effet 3). Bordure gauche à l'accent de la banque, mini-portrait de 32 px.
- **Ordinaires** (taux, relevé) : affichées 8 s (1 mois à ×1), 3 au maximum à l'écran.
- **Persistantes** (messages D04 bis, L17, D08 bis) : elles restent jusqu'au toucher ; un point de notification reste sur l'étiquette « MA BANQUE », et le message est rangé dans le carnet (onglet « Messages », 5 derniers).

### 5.3 Règles de cadence (budget de 15 interruptions pour 60 mois)

1. **Une interruption au plus par mois** (03 §3.3). Priorité : marché > nouveauté historique (Saint-Gobain) > vie > présentation. L'excédent passe au mois suivant.
2. **Au moins 2 mois de jeu (16 s à ×1) entre deux interruptions**, sauf pour les dates historiques et les événements de marché. Une présentation retardée par cette règle garde sa **date limite** (12 §2.2) ; à la date limite, c'est l'événement de vie mineur qui passe en notification.
3. **Compteur d'interruptions** de la démo : au-delà de 13, les événements de vie aléatoires sans décision passent en notification. Les présentations ne sont jamais supprimées (12 R2), les événements scriptés non plus.
4. Après un appel ou un événement de vie, le temps reprend à la vitesse d'avant ; après un événement de marché, il reste en pause (03 §3.2).

**Calendrier attendu** (scripté, plus 1 à 3 événements de vie aléatoires) :

| Mois | Interruption | Notifications sans pause |
|---|---|---|
| 01/1984 | D01 Livret A | |
| ≤ 08/1984 | D02 PEL | 08/1984 : Livret A à 6,5 % |
| ≤ 02/1985 | D03 Emprunt d'État | |
| ~ 04/1985 | Naissance (cigogne) | |
| ≤ 07/1985 | D04 Assurance-vie (au moins 2 mois après la naissance) | 07/1985 : Livret A à 6 % ; D04 bis |
| ≤ 02/1986 | D05 SICAV | 05/1986 : Livret A à 4,5 % |
| ≤ 08/1986 | D06 Actions | |
| 11/1986 | D07 Saint-Gobain (24/11/1986, A43) | 06/1987 : plafond du Livret A |
| 10/1987 | Krach | |
| 11/1987 | Panne de voiture (coïncidence forcée, 03 §6.2) | L17 |
| 04/1988 | D08 Héritage | 06/1988 : CAC 40 ; 09/1988 : D08 bis |
| | **11 interruptions scriptées + 1 à 3 aléatoires = 12 à 14** | + 4 relevés de décembre (1984 à 1987) |

---

## 6. À implémenter, par priorité

Effort : S < ½ journée, M ½ à 2 jours, L > 2 jours.

| # | Élément | Section | Effort |
|---|---|---|---|
| **P0** | | | |
| 1 | Pastille « vs tout au Livret A » dans la barre haute, bloc et ligne de Tata Livret avec l'écart teinté dans « Mon argent » | § 4.2 | S à M (moteur prêt) |
| 2 | Carte de présentation à 2 colonnes : texte ≤ 60 mots, ticket chiffré, comparatif à 4 critères plus les frais, 3 boutons de même poids, fermeture extérieure = « Pas maintenant » | § 1.2, § 1.3 | M |
| 3 | Fenêtre Banque = carnet (grille de 3 × 3, 4 états) + fiche + formulaire d'ordre existant ; aucun produit achetable sans présentation | § 2.2 | M à L |
| 4 | File d'interruptions : règles 1 à 4 de § 5.3, compteur, notifications du banquier (ordinaires et persistantes), onglet « Messages » | § 5 | M |
| 5 | Écran de fin : patrimoine, 2 barres, pastille d'écart, frais payés, produits découverts et utilisés, phrase de synthèse | § 4.3 | M |
| 6 | Encart F01 avec les 3 piles (première souscription avec frais) et jumeau sans frais | § 3.3 | M |
| **P1** | | | |
| 7 | Animation d'entrée par la tuile du produit, retour dans la banque, point sur l'étiquette | § 1.5 | S |
| 8 | Déblocage animé dans le carnet et jauge « Produits découverts » | § 2.3 | S |
| 9 | Pièces de cuivre et compteur « Frais payés depuis le début » avec détail | § 3.2 | S |
| 10 | Bandeau F03 avec jauge de seuil et bouton `Grouper` | § 3.4 | S |
| 11 | Relevé de décembre fusionné (L21 et F02) avec ouverture des piles | § 3.4 | S |
| 12 | Ligne « Face au Livret A » dans la modale du krach ; retournement de la pastille quand le signe change | § 4.2 | S |
| **P2** | | | |
| 13 | Verso « En savoir plus » qui se retourne, leçon 0,5 % contre 2,5 % sur 10 000 F | § 1.4, § 3.4 | S |
| 14 | Relecture des présentations passées depuis la fiche | § 2.2 | S |
| 15 | Bouche du portrait animée, sons (sonnerie, tiroir-caisse pour les frais) | § 1.5 | S |
