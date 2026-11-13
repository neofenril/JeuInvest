# 24 : UX de la version jouable (U3 projets, U4 rue et krach)

> Auteur : designer UX. Date : 2026-11-13. Pour : chef de projet, puis dev-interface (04-I étape 1, 05-I étape 1).
> Réponse aux demandes **U3** et **U4** de `docs/lots/lot_05.md` §8. Cadre : `feuille_de_route_jouable.md` (sobre, **aucune animation nouvelle**), `lot_05.md` D11-D12 et §4.2-4.3 (contrats figés), `lot_04.md` §4.2 (contrat des projets), `lot_06.md` E1-E8, docs/16 §3 (bible : cadres pixel, contenu net), docs/17 §4 (grammaire de la carte de dilemme, « Mon foyer »).
> Ce document **remplace les défauts** D11-D12 et E1-E8 là où il les précise ; les écarts sont listés au §3. Ce qui n'est pas dit ici reste le défaut du plan.

---

## 0. Conventions (valables pour tout le document)

| Sujet | Règle |
|---|---|
| Grille | Interface en texels de la grille 640 × 360 ; **1 texel = 3 px virtuels** à tous les formats (= T px physiques). Toutes les tailles ci-dessous sont en **px virtuels** (texels entre parenthèses) et sont des **multiples de 3**. |
| Formats de référence | **PC** 1920 × 1080 virtuels (T = 3). **Téléphone** 1440 × 648 virtuels (2400 × 1080 à 400 dpi, T = 5). |
| Cibles tactiles | PC : **≥ 81 px** (27 t) de haut pour un bouton de modale (le minimum technique est 48). Téléphone : **≥ 72 px** (24 t) = 48 dp (`cible_min()`) ; je vise 78 px (26 t) quand la place le permet. |
| Polices | **Pixelify** : mots courts en capitales, ≥ 28 px, **jamais de chiffre** (si le texte contient un chiffre : Atkinson gras, règle `Style.police_pour`). **Atkinson Hyperlegible** : tous les chiffres et textes longs, **≥ 20 px**, chiffres tabulaires, montants alignés à droite. « petites capitales 20 » = `Style.capitales()` à 20 px. |
| Couleurs | Palette des 40 couleurs d'interface (docs/16 §2.3). Sur papier crème `#F3E9D2` : texte `ENCRE #1C1626`, secondaire `TEXTE_PAPIER_2`, hausse `#1B6E3E`, baisse `#B3261E`. Sur panneau `nuit #2D2840` : texte crème, secondaire `#9C98A6`, hausse `#46E08A`, baisse `#FF5C5C`, accent `ambre #FFB547`. Jamais la couleur seule : toute hausse / baisse porte ▲ / ▼ (sprites 8 × 8, les glyphes manquent aux polices) **et** le signe + / −. |
| Sources | Liseré gauche des cartes : maison `tuile #D06A45`, banque `or`, média `néon rose #FF5FA2`, **rue `bleu vif #2F7FD1`** (la plaque de rue émaillée ; voir §3, écart 6). |
| Animation | **Aucune animation nouvelle.** Une carte apparaît **sur place** (fondu ≤ 0,2 s, celui de 03-I2), un chiffre change sans rouler, rien ne saute. Les animations **déjà codées** (roulement du patrimoine, course des barres de fin) restent telles quelles : on ne les retire pas, on n'en ajoute pas. |
| Fermeture | Carte qui demande un choix : ni Échap ni clic extérieur (A39). Carte de lecture : Échap, clic extérieur et FERMER. |
| Icônes | Sprites 16 × 16 **toujours à ×3** (48 px) ; jamais ×2 ni ×1,5 (pixels irréguliers au téléphone, T = 5). Icône de projet absente : initiale du projet dans un carré encre 48 × 48. |

Notation des maquettes : `▓` cadre pixel, `▌` liseré de source, `[ … ]` bouton, `▒` hachures en marches (choix désactivé), `┄` pointillé.

---

# U3 : les projets à l'écran (04-I)

## 1.1 Carte de choix de projet (étape `choix`, 3 options)

Même papier que la carte de dilemme (`CartePapier`, liseré tuile, apparition sur place). Trois boutons **de même style et de même taille** (principe 11 : aucun projet n'est mis en avant).

**PC** : carte 1176 × ≈ 600 (392 t × ≈ 200 t), centrée, fond assombri 60 %.
```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓◤
▌ MA MAISON · MARS 1984                                         ← petites capitales 20, TEXTE_PAPIER_2
▌ ┌────────┐  UN PROJET POUR 1986                               ← titre : Atkinson gras 40 (chiffres) ;
▌ │ Sylvie │  Sylvie et vous voulez vous offrir quelque chose      Pixelify 48 si pas de chiffre
▌ │ 48×48  │  d'ici avril 1986. Lequel ?                       ← c["texte"], Atkinson 24, ≤ 3 lignes
▌ │  ×3    │
▌ └────────┘
▌ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▌ ▓ 1 [salon] Le salon et la  ▓ ▓ 2 [grèce] La Grèce pour  ▓ ▓ 3 [auto] La Super 5     ▓
▌ ▓   48×48   chaîne hi-fi    ▓ ▓   48×48   les 30 ans de ▓ ▓   48×48   neuve         ▓
▌ ▓                           ▓ ▓           Sylvie        ▓ ▓                         ▓
▌ ▓ 12 000 F · avril 1986     ▓ ▓ 16 000 F · avril 1986   ▓ ▓ 30 000 F · avril 1986   ▓
▌ ▓ Canapé, fauteuils et une  ▓ ▓ Deux semaines dans les  ▓ ▓ Apport comptant, la     ▓
▌ ▓ vraie chaîne              ▓ ▓ Cyclades, à deux        ▓ ▓ vieille 4L en reprise   ▓
▌ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
▌ (note de bas de carte, seulement si un « sous » dépasse 2 lignes, voir ci-dessous)
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

| Élément | PC | Téléphone 1440 × 648 |
|---|---|---|
| Carte | 1176 de large (392 t), marges internes 24 (8 t), liseré 6 (2 t) | 1356 de large (452 t) = 94 % de la zone, marges 18 (6 t) |
| Portrait de Sylvie | 48 × 48 ×3 = 144 px, humeur du moment | **même taille que sur la carte de dilemme de 03-I2 au téléphone** (une seule règle pour les deux cartes ; si 03-I2 l'a mis à ×2, vérifier qu'il reste net à T = 5, sinon ×3 = 144 px : la hauteur le permet) |
| Titre / texte | 40-48 / Atkinson 24, ≤ 3 lignes | 32-36 / Atkinson 22, ≤ 2 lignes |
| 3 boutons | 360 × 195 chacun (120 × 65 t), écart 18 (6 t) | 438 × 180 chacun (146 × 60 t), écart 15 (5 t) |
| Dans un bouton | ligne 1 : numéro de touche (Atkinson gras 24 dans un carré encre 30 × 30) + icône 48 × 48 + `titre` en Atkinson gras 24, ≤ 2 lignes ; ligne 2 : `montant` Atkinson gras 30 + « · » + `echeance_txt` Atkinson 20 ; ligne 3 : `sous` Atkinson 20 `TEXTE_PAPIER_2`, ≤ 2 lignes | idem, titre 22, montant 28 |

- **Nom long** (« La Grèce pour les 30 ans de Sylvie ») : en Atkinson gras, pas en Pixelify (trop long pour une police pixel), 2 lignes au plus, sinon « … ».
- **`sous` de plus de 2 lignes** (cas de P2C : la phrase du PEL fait ≈ 200 caractères) : le bouton montre les 2 premières lignes terminées par « … ③ » et la phrase entière s'affiche **sous les boutons**, en note : « ③ Un PEL ouvert en 1984 verse chaque année… » (Atkinson 20, `TEXTE_PAPIER_2`, largeur de la carte, ≤ 3 lignes). Aucune information n'est perdue, rien n'est au survol. Je recommande quand même au game designer (G4) un `sous` ≤ 60 caractères.
- **Ligne « Disponible sans rien vendre »** : absente du contrat de l'étape `choix` ; si dev-logique ajoute un champ `disponible` (ajout permis), l'afficher sous les boutons comme sur la carte de dilemme (« Aujourd'hui, sans rien vendre : 8 400 F (compte et Livret A) », Atkinson 20). Sinon, rien.
- **Touches** 1 / 2 / 3 ; ni Échap ni clic extérieur. Aucun choix n'est désactivé à cette étape (c'est un objectif, pas une dépense).
- **Après le choix** (`conclure_projet`, comme `conclure_carte`) : le bouton choisi reçoit le mot **CHOISI** (Pixelify 28, encre, dans un cadre encre 1 t, coin haut droit du bouton), les deux autres passent à 40 % d'opacité ; la zone du texte affiche `r["consequence"]` (Atkinson 24 italique, ex. « C'est décidé : la Super 5, pour avril 1986. ») ; en bas à droite « Toucher pour continuer › » (Atkinson 20, secondaire) ; 3 s, un toucher passe, aucun compte à rebours ; puis disparition par fondu ≤ 0,2 s.

**Téléphone** (même ordre, boutons côte à côte : le paysage le permet)
```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓◤
▌ [Sylvie 96] MA MAISON · MARS 1984                                              (20)
▌             UN PROJET POUR 1986                                                (32)
▌             Sylvie et vous voulez vous offrir quelque chose d'ici avril 1986.  (22)
▌ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▌ ▓ 1 [ic] Le salon et la ▓ ▓ 2 [ic] La Grèce pour ▓ ▓ 3 [ic] La Super 5    ▓   438 × 180
▌ ▓        chaîne hi-fi   ▓ ▓        les 30 ans…   ▓ ▓        neuve        ▓
▌ ▓ 12 000 F · avril 1986 ▓ ▓ 16 000 F · avril 1986▓ ▓ 30 000 F · avril 1986▓
▌ ▓ Canapé, fauteuils…    ▓ ▓ Deux semaines dans…  ▓ ▓ Apport comptant, la… ▓
▌ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
Hauteur totale ≈ 420 px sur 648 : il reste la place de la note ③.

---

## 1.2 « Le jour J » (étape `echeance`)

### 1.2.1 La carte principale

Lecture de haut en bas : **ce que coûte le projet → ce que j'ai sans rien vendre → ce qui manque → ce qu'il faudrait vendre → les 4 décisions**.

**PC** : carte 1176 × ≈ 700 (392 × ≈ 233 t).
```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓◤
▌ MA MAISON · AVRIL 1986                                                         (20)
▌ ┌────────┐  [auto 48] LE JOUR J : LA SUPER 5 NEUVE                              ← Pixelify 48 (40 si chiffre)
▌ │ Sylvie │  C'est le moment : La Super 5 neuve, 30 000 F.                       ← Atkinson 24
▌ │ ×3     │
▌ └────────┘
▌ ┌──────────────────┬──────────────────────┬──────────────────┬──────────────────┐
▌ │ LE PROJET        │ SANS RIEN VENDRE     │ IL MANQUE        │ APRÈS LES VENTES │ ← petites capitales 20
▌ │ 30 000 F         │ 21 400 F             │ 8 600 F          │ 30 600 F         │ ← Atkinson gras 30
▌ │                  │ compte et Livret A   │                  │                  │ ← Atkinson 20, secondaire
▌ └──────────────────┴──────────────────────┴──────────────────┴──────────────────┘
▌ SI VOUS VENDEZ (de ce qui rapporte le moins à ce qui rapporte le plus)          ← petites capitales 20
▌  PLACEMENT              VOUS RECEVEZ    VS VOS VERSEMENTS    COÛT DE LA VENTE   ← en-têtes 20, secondaire
▌  SICAV Avenir               4 100 F        ▼ − 300 F             45 F
▌  Plan d'épargne-logement    5 100 F        ▲ + 900 F          1 150 F
▌  ┄ (au-delà de 4 lignes : « + 2 autres placements : détail à l'étape suivante »)
▌ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▌ ▓▒▒1 RÉALISER▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓ ▓ 2  RÉALISER EN VENDANT                ▓   ← Pixelify 28
▌ ▓▒▒Il manque 8 600 F sur le compte▒▒▒▒▒▓ ▓    Il faut vendre pour 8 600 F       ▓   ← Atkinson 20
▌ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
▌ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▌ ▓ 3  REPORTER DE 4 MOIS               ▓ ▓ 4  RENONCER                         ▓
▌ ▓    Nouvelle date : août 1986        ▓ ▓    Le projet est abandonné          ▓
▌ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

| Bloc | Contenu exact (contrat `lot_04` §4.2) | Dimensions PC / téléphone |
|---|---|---|
| Bandeau des chiffres | 4 cases de même largeur, filets encre 1 t : `montant` ; `disponible` (+ « compte et Livret A ») ; `manque` (si 0 : le mot « rien ») ; `apres_ventes` (case **absente** si `ventes` est vide) | hauteur 105 (35 t) / 96 (32 t) ; libellés petites capitales 20 ; chiffres Atkinson gras 30 / 28 ; tous en encre, **aucune couleur de jugement** |
| Ventes, version courte | une ligne par vente de `ventes`, dans l'ordre reçu : `nom` (Atkinson 22) ; `net` (gras 22) ; `ecart_verse` signé (▲ + hausse papier / ▼ − baisse papier / « = 0 F ») ; coût = `frais + impot + penalite` (encre, « 0 F » si nul) | lignes de 30 (10 t) ; 4 lignes au plus sur PC, **2** au téléphone, puis « + N autres placements : détail à l'étape suivante » ; bloc **absent** si `ventes` est vide (il est alors remplacé par « Rien à vendre : tout est disponible. », Atkinson 20) |
| Intitulé des ventes | « SI VOUS VENDEZ » + « (de ce qui rapporte le moins à ce qui rapporte le plus) » : phrase provisoire de D7 bis, **en donnée** (`projets.json`, texte à valider par le banquier, K3) | Atkinson 20 |
| 4 boutons | grille **2 × 2**, dans l'ordre de `c["choix"]` ; titre Pixelify 28 (« 1 RÉALISER ») ; `sous` Atkinson 20, 1 ligne | 552 × 96 (184 × 32 t), écarts 18 / 666 × 84 (222 × 28 t), écarts 12 |

- **Même style pour les 4 boutons** (aucun n'est « principal ») : `BoutonSecondaire` sur papier. Un bouton `desactive` : **hachures en marches** sur tout le bouton (motif, pas seulement du gris), texte à 60 %, `sous` = la raison fournie (« Même en vendant, il manque 2 300 F ») ; il garde sa taille et ne réagit pas (ligne `UI projet refus=ignore`).
- **P2C** : 3 choix seulement (`reporter` absent) : grille 2 × 2 avec la 4e case **vide** (pas de bouton étiré), RENONCER POUR L'INSTANT en case 3. Les numéros suivent les boutons visibles (1, 2, 3).
- Touches 1 à 4 (sur les boutons actifs) ; ni Échap ni clic extérieur.
- Le portrait de Sylvie montre son humeur du moment ; **l'icône du projet** est à gauche du titre.

**Les 3 cas à capturer (`projet_jour_j`)** :

| Cas | Bandeau | Ventes | Boutons |
|---|---|---|---|
| A. Disponible suffisant | IL MANQUE : rien ; pas de case APRÈS LES VENTES | « Rien à vendre : tout est disponible. » | RÉALISER actif ; RÉALISER EN VENDANT désactivé (raison du moteur) ; REPORTER ; RENONCER |
| B. Manque couvert par les ventes | 4 cases | liste courte | RÉALISER désactivé (« Il manque 8 600 F… ») ; RÉALISER EN VENDANT actif → confirmation (§1.2.2) |
| C. Rien ne suffit | 4 cases ; APRÈS LES VENTES < LE PROJET | liste courte | les deux RÉALISER désactivés ; REPORTER (si possible) ; RENONCER |

**Téléphone** : même ordre, sans défilement. Le portrait (même taille que sur la carte de choix) passe à gauche de l'en-tête ; le titre en 32-36 ; le texte sur 1 ligne (sinon « … » : la phrase est redite par le bandeau) ; le bandeau en 4 cases ; ventes : 2 lignes ; boutons 2 × 2 de 84 px. Budget vertical : en-tête 30 + titre 45 + texte 30 + bandeau 96 + ventes 24 + 2 × 30 + 27 + boutons 2 × 84 + 12 + marges 36 + écarts 48 ≈ **576 px sur 648** (le bloc des ventes est le nœud « Defilant » s'il faut gagner de la place).

### 1.2.2 L'écran de confirmation de RÉALISER EN VENDANT (dans la même carte)

Le toucher sur RÉALISER EN VENDANT **ne fait encore rien** : la partie basse de la carte (bandeau, ventes courtes, boutons) est **remplacée sur place** par l'écran ci-dessous ; l'en-tête (portrait, titre) reste. `choix_fait("projet", "realiser_en_vendant")` n'est émis qu'au CONFIRMER.

```
▌ ┌────────┐  [auto] LE JOUR J : LA SUPER 5 NEUVE
▌ └────────┘  CONFIRMER LES VENTES                                               ← Pixelify 28
▌ Ventes, de ce qui rapporte le moins à ce qui rapporte le plus.                  ← Atkinson 20 (donnée, K3)
▌ ┌──────────────────────────────────────────────────────────────────────────────┐
▌ │ 1  SICAV Avenir                                                   4 100 F    │ ← nom gras 22 · net gras 24
▌ │    SICAV : 4 100 F, soit 300 F de moins que vos versements.                  │ ← texte_ecart, Atkinson 20
▌ │    Impôt sur la plus-value : 45 F.                                           │ ← texte_penalite, 20 italique
▌ │┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄│
▌ │ 2  Plan d'épargne-logement                                        5 100 F    │
▌ │    PEL : 5 100 F, soit 900 F de plus que vos versements.                     │
▌ │    Prime d'État perdue : 1 150 F. Le PEL est clos avant 4 ans : seuls…       │
▌ └──────────────────────────────────────────────────────────────────────────────┘ ← zone « Defilant »
▌  TOTAL DES VENTES (net)                                                9 200 F   ← gras 24, filet encre au-dessus
▌  Avec votre compte et votre Livret A : 30 600 F pour un projet de 30 000 F.      ← Atkinson 22
▌  Ce qui reste va sur votre compte : 600 F.                                        ← Atkinson 22
▌ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▌ ▓ 1  CONFIRMER                        ▓ ▓ 2  RETOUR                           ▓
▌ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
- Une vente = 3 lignes (nom + `net` ; `texte_ecart` ; `texte_penalite`, omise si vide), séparées par un pointillé encre 1 t. **Ce sont les textes du moteur, sans réécriture** (CA-M6 : la liste == `plan_vente_projet()`).
- TOTAL = somme des `net` ; « Avec votre compte… » = `apres_ventes` et `montant` ; reste = `apres_ventes − montant` (affiché seulement s'il est > 0). Arithmétique d'affichage seulement.
- **Seule la liste défile** (nœud « Defilant ») : le total et les deux boutons restent toujours visibles. Téléphone : la liste prend la hauteur restante (≈ 2 ventes visibles), boutons de 84 px.
- CONFIRMER et RETOUR : **même style** (secondaire papier), 552 × 96 PC / 666 × 84 téléphone. Touches 1 = CONFIRMER, 2 = RETOUR ; **Échap = RETOUR** dans cet écran seulement (action sans effet, voir §3, écart 3). RETOUR remet la carte principale telle qu'elle était.
- **Conclusion** (`conclure_projet`) : la carte reprend la forme principale, le bouton choisi porte **CHOISI**, les autres à 40 %, le texte devient `r["consequence"]` (« La Super 5 neuve : c'est fait ! ») ; 3 s, un toucher passe. Les ventes faites (`r["ventes"]`) ne sont pas réaffichées : elles sont dans l'historique.

---

## 1.3 La 2e ligne de l'étiquette MA MAISON (et de sa flèche de bord)

```
 Sans projet (inchangé)            Projet en cours                         Flèche de bord, maison hors champ
 ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐               ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐           ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
 ▓ MA MAISON [☺] ▓               ▓ [auto]  MA MAISON [☺]     ▓           ▓ ‹ MA MAISON [☺]     ▓
 └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘               ▓  48×48  21 400 / 30 000 F ▓           ▓   21 400 / 30 000 F ▓
                                   └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘           └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
| Élément | Valeur |
|---|---|
| Icône du projet | `projet_en_cours()["icone"]`, 16 × 16 **×3 = 48 px**, à gauche, centrée verticalement sur les deux lignes ; absente dans la flèche de bord (place) |
| Ligne 1 | inchangée : « MA MAISON » Pixelify 28 + picto d'humeur 48 |
| Ligne 2 | « {disponible} / {montant} » (`Format.entier`, espace insécable avant F), **Atkinson gras 22**, crème ; hauteur 27 (9 t) ; aucune barre, aucune couleur de jugement |
| Objectif atteint (`atteint`) | même texte ; rien d'autre (pas d'incitation, pas d'animation) |
| Taille | hauteur ≈ 93 (31 t) au lieu de ≈ 66 ; largeur + 57 px pour l'icône. Le tout reste **un seul bouton** (ouvre « Mon foyer »), ≥ `cible_min()` |
| Placement | même `_place_libre` ; contrôle : `chevauchements_etiquettes()` = 0 sur les étapes existantes. Si une étape échoue : supprimer d'abord l'icône (ligne 2 seule), jamais le chiffre |
| Téléphone | identique (mêmes px virtuels) |

---

## 1.4 « Mon foyer » au téléphone : colonne PROJET EN COURS (une colonne, défilement)

Ordre dans la colonne unique (03-I2 l'a posée ; 04-I remplit le bloc projet) : **humeur** (portrait + phrase + cause) → **PROJET EN COURS** → **PROJETS PASSÉS** → **CARTES DU FOYER** → **LE FOYER** (budget). Le projet passe avant les cartes : c'est ce que le joueur vient chercher en touchant l'étiquette.
```
▌ PROJET EN COURS                                                    (petites capitales 20)
▌ [auto 48] La Super 5 neuve · avril 1986 · dans 14 mois             (Atkinson gras 22 / 20)
▌ ████████████████▒▒▒▒▒▒░░░░░░░░░░░░░░│ 30 000 F                     barre 24 px (8 t) de haut
▌ 21 400 F sans rien vendre · ▒ + 4 100 F placés                     (Atkinson 20)
▌ Il manque 8 600 F sans rien vendre.                                (Atkinson 20)
▌ PROJETS PASSÉS
▌ ✓ réalisé · Le salon et la chaîne hi-fi · avril 1986 · 12 000 F
```
- Barre : largeur = colonne − 150 px (place du montant) ; segment **plein ambre** = `disponible`, segment **hachuré en marches ambre** = `revendable`, vide `ardoise sombre`, trait encre 1 t = objectif ; contour encre 1 t. Échelle : `montant` = trait ; si `disponible + revendable > montant`, la barre s'arrête au trait (pas de débordement).
- « Il manque… » seulement si `disponible < montant`. Projets passés : sprite ✓ / ↻ / ✗ **et** le mot (réalisé, réalisé après report, abandonné).
- Rien sans projet : le bloc affiche « Aucun projet en cours. » (Atkinson 20, secondaire) pour que la colonne garde son ordre.

---

# U4 : la rue et le krach à l'écran (05-I)

## 2.1 Le classement permanent : où le mettre quand la barre haute est pleine

**Constat** (mesures de `_replier_barre`, dev-interface) : à 1920 PC, la barre est déjà pleine (le titre « VS TOUT AU LIVRET A » est replié) ; au téléphone 1440 × 648, il reste ≈ 25 px. Une pastille « RUE 2e / 4 » de ≈ 130 px forcerait à replier le badge EN PAUSE au téléphone et la variation du patrimoine sur PC : on perdrait une information pour en ajouter une.

**Décision UX : le classement ne va pas dans la barre ; il est accroché juste dessous, à droite, là où le joueur lit déjà « VS LIVRET A ».** Il est permanent dans les deux cas :

| Format | Où | Pourquoi c'est permanent |
|---|---|---|
| **PC** (non compact) | **Bloc « LA RUE » en tête du panneau « Mon argent »** (§2.2), juste sous la barre. | Sur PC le panneau est **toujours ouvert** (pas de bouton REPLIER, `panneau_ouvert = not compact`) : le bloc est visible en permanence, avec les montants, ce qui vaut mieux qu'une pastille. |
| **Téléphone** (compact) | **En tête de la languette « MON ARGENT »** (bord droit, sous la barre) : RUE / 2e / sur 4. | La languette est visible dès que le panneau est replié ; panneau ouvert, c'est le bloc qui se voit. Le toucher (toute la languette) ouvre « Mon argent », donc le bloc. |

**Languette au téléphone** (104 px de large, ≈ 426 px de haut ; aujourd'hui un `Button` à texte : la remplacer par un `Button` sans texte contenant une `VBox` de labels en `MOUSE_FILTER_IGNORE`) :
```
┌▓▓▓▓▓▓┐
▓ RUE  ▓   petites capitales 20, secondaire         ┐
▓  2e  ▓   Atkinson gras 36, crème                  │ ≈ 105 px (35 t), visible seulement si rue_active()
▓ sur 4▓   Atkinson 20, secondaire                  ┘
▓ ──── ▓   filet 1 t (PANNEAU_SURVOL)
▓ MON  ▓   existant (petites capitales 20)
▓ARGENT▓
▓      ▓
▓ 69 k ▓
▓  F   ▓
▓  ◀   ▓
└▓▓▓▓▓▓┘
```
- Rang : « 1er », « 2e », « 3e », « 4e » (lettres normales : pas de « ᵉ », glyphe absent des polices embarquées). Rien d'autre (pas de couleur : le rang n'est ni un gain ni une perte ; l'ordre et le chiffre suffisent).
- Changement de rang : le chiffre change **sans animation** ; la notification `rang` (§2.3) dit ce qui s'est passé.
- Rue éteinte : les 3 lignes et le filet sont absents ; la languette redevient celle d'aujourd'hui.

**Repli, si le chef de projet tient à E1 (pastille dans la barre)** : pastille 9-patch `Pastille` (contour `PANNEAU_SURVOL`, fond α 0,16) collée à droite de « VS LIVRET A » (écart 6 px), hauteur **78 px** comme elle ; ligne 1 « RUE » petites capitales 16 (même rôle que le titre de « VS LIVRET A ») ; ligne 2 « 2e / 4 » Atkinson gras 30 ; marges 12 ; largeur ≈ 120. Replis dans l'ordre : PC titre « VS… » (déjà), `l_var`, « COMPTE COURANT » → « COMPTE », libellé COURRIER ; téléphone libellé COURRIER, puis **badge EN PAUSE** (le cadre gel reste le signal de pause). Jamais le rang lui-même. Je le déconseille pour la 0.5 : plus de risque (barre, replis, tests `UI barre`) pour moins d'information.

---

## 2.2 Le bloc « La rue » dans « Mon argent »

**PC** (panneau de 500 px, contenu ≈ 464 px) : **en tête du panneau**, juste sous « MON ARGENT ».
```
▓ MON ARGENT                                                ▓
▓ LA RUE                                     VOUS : 2e / 4  ▓  petites capitales 20 / Atkinson gras 22
▓  1  (J) Jean-Mi                              81 200 F     ▓
▓ ┌──────────────────────────────────────────────────────┐  ▓  ligne « vous » : cadre ambre 1 t
▓ │2  (G) Vous                                 69 395 F  │  ▓  nom et montant en gras
▓ └──────────────────────────────────────────────────────┘  ▓
▓  3  (T) Tata Livret                          65 479 F     ▓
▓  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄    ▓  pointillé ambre : la référence
▓  4  (M) Tonton Matelas                       58 900 F     ▓
▓ ┄ Tata Livret : tout au Livret A, la référence.           ▓  Atkinson 20, secondaire
▓ Même salaire, mêmes dépenses, mêmes coups durs :          ▓  phrase existante (l_ecart_note),
▓ seul le placement change.                                 ▓  déplacée ici quand la rue est allumée
▓ (puis l'existant : courbe, légende, répartition, ce mois-ci, coussin, frais, BANQUE)
```
| Élément | Valeur |
|---|---|
| Ligne | hauteur 36 (12 t), écart 3 ; colonnes : rang x 0-30 (Atkinson gras 22), pastille d'initiale x 36-66, nom x 78 → , montant aligné à droite sur le bord du contenu |
| Pastille d'initiale | 30 × 30 (10 t), cadre `Pastille` contour encre 1 t, lettre `initiale` Atkinson gras 20 ; fonds (couleurs foncées, aucune ne se lit comme gain ou perte) : vous `ambre` (lettre encre) ; Tata `vert sombre #2F5240` ; Tonton `bois #7A5034` ; Jean-Mi `bleu nuit #283A6B` (lettres crème, contrastes ≥ 5:1) |
| Nom | `nom` Atkinson 22 ; « vous » en gras |
| Patrimoine | `Format.entier`, Atkinson gras 22, tabulaire ; **négatif : couleur perte `#FF5C5C` + signe « − »** (jamais la couleur seule) ; sinon crème |
| Référence | ligne de Tata (`reference: true`) soulignée d'un pointillé ambre 1 t (6 px plein, 3 px vide) + la ligne de légende |
| Ligne « vous » | `vous: true` : cadre ambre 1 t autour de la ligne + gras (deux indices, pas seulement une teinte) |
| En-tête | « LA RUE » à gauche ; « VOUS : 2e / 4 » à droite (`rang_rue()`) |
| Interaction | lecture seule sur PC (pas de cible) |

- Place dans le panneau : le bloc fait ≈ 240 px. Le panneau reste **sans défilement** : `_alleger_panneau` replie dans l'ordre la ligne baguette, le coussin, la légende de la répartition (existant), puis **réduit la courbe de 110 à 81 px**, puis passe la phrase « Même salaire… » sur une ligne raccourcie « Même salaire, mêmes dépenses pour tous. ». Le bloc LA RUE, les frais et BANQUE ne se replient jamais.
- **Téléphone** (panneau compact, ouvert par la languette) : le panneau passe de 900 à **min(zone − 48, 1392) px** et à **3 colonnes** de largeur égale (écart 24) : A = courbe et répartition (existant) ; B = ce mois-ci, coussin, frais, BANQUE (existant) ; **C = LA RUE** (mêmes lignes, hauteur 39 = 13 t, la phrase « Même salaire… » en bas de C). Zone de moins de 1300 px de large (téléphone 1280 × 720) : 2 colonnes, LA RUE **en tête de la colonne A** et la courbe repliée.
- Rue éteinte : bloc absent, `l_ecart_note` à sa place d'aujourd'hui, panneau inchangé.

---

## 2.3 Notifications de la rue et relecture longue (rappel de la demande U4, point 3)

- **Notification** (`voisin`, `rang`) : carte de notification existante, liseré **bleu vif** (plaque de rue), libellé de source « LA RUE » (petites capitales 20) au-dessus du titre ; titre = `titre` (nom du voisin) Atkinson gras 22 ; texte Atkinson 22, ≤ 2 lignes. `rang` : sprite ▲ (`cls` gain) ou ▼ (`cls` perte) devant le titre, texte crème (la flèche porte le sens). `kiosque` : source média existante, rien de neuf.
- `long: true` : la notification montre les 2 premières lignes terminées par « … Lire › » ; un toucher ouvre la **carte de lecture** (lecture seule) : `CartePapier` liseré bleu vif, en-tête « LA RUE · SEPTEMBRE 1986 » (20), à gauche une pastille d'initiale de **96 × 96** (en attendant les portraits), titre = nom (Pixelify 48 ; Atkinson gras 40 s'il contient un chiffre), texte entier Atkinson 24 (≤ 60 mots ≈ 6 lignes sur 900 px), bouton FERMER (secondaire, 81 px / 78 px) ; Échap et clic extérieur ferment. PC 1056 × ≈ 420 ; téléphone 94 % de la largeur, texte 22.
- Historique : onglet **LA RUE** (icône plaque bleue 16 × 16, ou libellé seul si l'icône n'est pas prête).

---

## 2.4 Le tableau du Lundi noir dans la modale du krach

Ajouté **entre le chapô et le bloc « VOS PLACEMENTS EN BOURSE »**, seulement si `c["jours"]` existe ; rien d'autre ne change dans la modale. C'est un bandeau horizontal (comme le journal lumineux du toit), pas une colonne : il prend peu de hauteur, ce qui garde les 3 choix visibles au téléphone.

**PC** (page de 1200, contenu 1128 px) : 7 cases + 1 case de cumul.
```
│ INDICE DE PARIS, ENVIRON                  Seuls le 16 et le 19 sont des chiffres d'archives. │ ← petites capitales 20 / Atkinson 20 italique
│ ┌────────┬────────┬────────┬────────┬────────┬────────┬────────┬──────────┐                  │
│ │ VEN 16 │ LUN 19 │ MAR 20 │ MER 21 │ JEU 22 │ VEN 23 │ LUN 26 │EN 7 JOURS│  ← Atkinson gras 20
│ │ 1 240  │ 1 120  │ 1 050  │ 1 085  │ 1 045  │ 1 020  │   990  │          │  ← Atkinson gras 26
│ │   —    │▼ −9,7 %│▼ −6,2 %│▲ +3,3 %│▼ −3,7 %│▼ −2,4 %│▼ −2,9 %│ ▼ −20 %  │  ← Atkinson 20 (gras pour le cumul)
│ └────────┴────────┴────────┴────────┴────────┴────────┴────────┴──────────┘                  │
```
| Élément | Règle |
|---|---|
| Cases | 8 × 141 px (47 t), hauteur 96 (32 t), filets encre 1 t, papier du journal ; centré |
| Jour | `jour` (« vendredi 16 octobre ») → 3 premières lettres en capitales + numéro : « VEN 16 » (affichage seulement) |
| Valeur | `indice` arrondi à 5 points (`round(x / 5) × 5`), `Format.entier` sans devise, encre |
| Variation | `variation` au dixième, virgule, « % » insécable ; baisse : ▼ + « − » + baisse papier `#B3261E` ; hausse : ▲ + « + » + hausse papier `#1B6E3E` ; **1re ligne : « — »** (variation inconnue, valeur 0.0 du contrat) |
| Cumul | (dernier `indice` / premier `indice` − 1), arrondi à l'unité : « ▼ −20 % » en gras, case à fond `pierre claire #E2CBA0` pour la distinguer (plus filet double) |
| Certitude | phrase construite depuis `certitude` : jours en « A » → « Seuls le 16 et le 19 sont des chiffres d'archives. » ; tous en A → pas de phrase. L'étiquette « ENVIRON » reste dans tous les cas (docs/19 §4.2) |

**Téléphone** (page de 1360, contenu ≈ 1312) : **7 cases** de 186 px (62 t), **2 lignes** par case pour gagner de la hauteur :
```
│ INDICE DE PARIS, ENVIRON                                          16 → 26 OCTOBRE : ▼ −20 %   │
│ ┌──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┐                │
│ │ VEN 16   │ LUN 19   │ MAR 20   │ MER 21   │ JEU 22   │ VEN 23   │ LUN 26   │  Atkinson gras 20
│ │ 1 240  — │1 120 ▼9,7│1 050 ▼6,2│1 085 ▲3,3│1 045 ▼3,7│1 020 ▼2,4│ 990 ▼2,9 │  gras 22 + 20
│ └──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┘                │
```
- Variation au téléphone : « ▼ −9,7 % » complet si la case le permet (186 px suffisent à 20 px : « 1 120 ▼ −9,7 % » ≈ 170 px) ; sinon le « % » tombe, jamais le signe ni la flèche. Le cumul passe dans l'en-tête, à droite ; la phrase de certitude est omise (l'étiquette « ENVIRON » reste).
- Hauteur : 27 + 66 = **93 px**. Pour que les 3 choix restent visibles sans défiler à 648 px : au téléphone et **seulement quand le tableau est là**, le libellé « QUE FAITES-VOUS ? » est masqué (les 3 boutons parlent d'eux-mêmes) et le chapô reste le seul nœud « Defilant ». Contrôle : `UI krach_jours choix_visibles=oui` sur 1440 × 648.
- Relecture du journal du krach dans l'historique : même tableau (il fait partie du contenu).

---

## 2.5 La carte « Le krach, un an après » (octobre 1988)

`Modales.gazette` : `CartePapier` **liseré néon rose** (source média), apparition sur place.

**PC** : 1176 × ≈ 620 (392 t).
```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓◤
▌ LA GAZETTE · OCTOBRE 1988                                                     (20)
▌ LE KRACH, UN AN APRÈS                                                         Pixelify 48
▌ Il y a un an, la Bourse de Paris perdait plus de 20 % en quelques jours.      c["texte"], Atkinson 24,
▌ Un an plus tard, voici ce que seraient devenus vos placements selon le choix   ≤ 50 mots
▌ fait ce jour-là… (texte du moteur)
▌ Exemple : vous n'aviez ni actions ni SICAV en octobre 1987.                    c["mention"], 22 italique (si non vide)
▌
▌ VOS PLACEMENTS EN BOURSE D'OCTOBRE 1987, UN AN APRÈS          ┊ au krach : 10 000 F   ← petites capitales 20
▌                                                               ┊
▌  Tout vendu          ██████████████████████████████████       ┊          8 400 F
▌ ┌───────────────────────────────────────────────────────────────────────────────────┐
▌ │Rien fait           ████████████████████████████████████████████████    10 900 F  │  ← choisi : cadre encre 2 t
▌ │[VOTRE CHOIX]                                                ┊                     │
▌ └───────────────────────────────────────────────────────────────────────────────────┘
▌  Renforcé            ████████████████████████████████████████████████████████  15 600 F
▌
▌                                                              ╔══════════════════╗
▌                                                              ║ 1  J'AI COMPRIS  ║   BoutonPrincipal ambre
▌                                                              ╚══════════════════╝
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
| Élément | Règle |
|---|---|
| Ordre | toujours les 3 `barres` dans l'ordre reçu (vendu, rien, renforcé) : **jamais triées** par valeur (l'ordre suit le choix, pas le résultat) |
| Ligne | hauteur 60 (20 t), écart 9 ; colonne titre 240 px (`titre` Atkinson gras 22) ; zone de barre ; colonne valeur 180 px (`valeur`, `Format.entier`, Atkinson gras 26, **encre**, aligné à droite) |
| Barre | hauteur 30 (10 t), rectangle plein (graphique lisse, 16 §3.1), contour encre 1 t ; remplissage `ardoise #6B6880` ; **barre choisie en `ambre`** ; axe à 0 à gauche ; longueur = valeur / max(valeurs, `base`) × zone ; valeur ≤ 0 : pas de barre, seulement le montant |
| Choix du joueur | `choisi: true` : **cadre encre 2 t autour de toute la ligne** + étiquette « VOTRE CHOIX » (petites capitales 20, encre sur fond ambre, contour encre) sous le titre ; trois indices (cadre, mot, teinte). Aucune ligne n'est entourée dans le cas exemple |
| Repère `base` | trait vertical pointillé encre 1 t à la position de `base`, libellé « au krach : 10 000 F » (Atkinson 20) au-dessus du graphique. **À confirmer avec dev-logique** : `base` = valeur des lignes risquées à l'instantané du krach (ou 10 000 F dans l'exemple). Si `base` ≤ 0 : pas de repère |
| Couleurs | **aucune** couleur de gain ou de perte, aucun signe, aucun écart calculé entre les barres : le joueur compare les longueurs ; le texte du moteur dit le reste (« aucun vous auriez dû ») |
| Titre du graphique | libellé fixe ci-dessus ; si le moteur ajoute un jour `titre_barres` (ajout permis), il le remplace |
| Bouton | J'AI COMPRIS, `BoutonPrincipal` ambre, 360 × 81 (120 × 27 t), en bas à droite ; touches 1 et Entrée ; ni Échap ni clic extérieur |

**Téléphone** : carte 1356 × ≈ 560 ; titre Pixelify 36 ; texte Atkinson 22 (≤ 4 lignes, nœud « Defilant ») ; lignes de barres 54 (18 t), barre 27 (9 t), colonne titre 200, valeur 170 ; bouton 360 × 78. Budget : 27 + 45 + 4 × 29 + 29 + 27 + 3 × 54 + 2 × 9 + 78 + marges 36 + écarts 36 ≈ **570 px sur 648**.

**Conclusion** (`conclure_gazette`) : rien à montrer ; la carte disparaît par fondu ≤ 0,2 s.

---

## 2.6 L'écran de fin à 4 barres

On ne change que le bloc de gauche « VOUS ET TATA LIVRET » quand `bilan["rue"]` n'est pas vide ; le reste de l'écran (titre, patrimoine, courbe des cinq ans sur PC, pastille « VOUS : … de plus que Tata Livret », frais, produits, phrase, boutons) est **inchangé**.

**PC** (bloc de gauche ≈ 700 px)
```
 LA RUE : VOUS ET VOS VOISINS                         ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
                                                      ▓ 2e DE LA RUE SUR 4  ▓  ← Atkinson gras 28, pastille neutre
                                                      └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
 1 TATA LIVRET      ██████████████████████████████████████████  165 300 F
    ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄    ← pointillé ambre : la référence
 2 VOUS             ████████████████████████████████████████    160 749 F   ← barre ambre, libellé en gras
 3 TONTON MATELAS   ██████████████████████████████████          139 800 F
 4 JEAN-MI          ▏                                           − 12 400 F  ← négatif : pas de barre, montant en perte avec le signe
 (J) Jean-Mi : « La Porsche ? Revendue. Et je rembourse encore ma banque. »   ← replique_rue, Atkinson 22 italique, ≤ 2 lignes
 Argent mis de côté en cinq ans : … (existant)
 [pastille existante « VOUS : … de moins que Tata Livret »]
```
| Élément | Règle |
|---|---|
| Ordre | celui de `bilan["rue"]` (rang croissant), numéro de rang devant le libellé |
| Barres | `Barres` réutilisé avec 4 lignes ; hauteur du contrôle 4 × 48 = **192** PC (16 t par ligne), 4 × 42 = **168** au téléphone ; libellés en **petites capitales 20** (au lieu de 18) |
| Couleurs | vous `ACCENT` (ambre) ; Tata `Courbe.COULEUR_REF` (la même que sa courbe, à côté) ; Tonton et Jean-Mi `zinc clair #C9C6CC` ; l'identité se lit par le libellé, pas par la teinte |
| Négatif (ajout à `Barres`) | valeur < 0 : pas de barre, trait encre 1 t à l'axe, montant en `PERTE` avec « − », posé juste après l'axe ; l'échelle se calcule sur les seules valeurs positives |
| Référence | pointillé ambre 1 t sous la ligne de Tata, sur toute la largeur de la barre (ajout à `Barres` : paramètre « ligne de référence ») |
| Rang | pastille neutre (contour `PANNEAU_SURVOL`) « 2e DE LA RUE SUR 4 », Atkinson gras 28 (chiffres), à droite du titre du bloc ; « 1er » au premier rang |
| Réplique | `replique_rue` : pastille d'initiale 30 × 30 + « Nom : « texte » », Atkinson 22 italique, 2 lignes au plus ; absente si `{}` |
| Animation | la course des barres déjà codée (`barres.animer`) s'applique aux 4 lignes ; rien de plus |

**Téléphone** : même bloc en pleine largeur (la courbe est déjà absente en compact) ; la pastille de rang passe sur la ligne du titre, à droite ; le nœud « Defilant » existant (la ligne du bloc) absorbe le manque de hauteur ; les boutons REJOUER / QUITTER (72 px) restent visibles.

Rue éteinte : écran identique à `main` (CA-U7).

---

## 3. Écarts aux défauts des plans (à arbitrer par le chef de projet)

| # | Défaut du plan | Ce document | Raison |
|---|---|---|---|
| 1 | E1 : pastille « RUE 2e / 4 » dans la barre haute, PC et téléphone | PC : bloc en tête du panneau toujours ouvert ; téléphone : en tête de la languette. Pastille de barre en repli (§2.1) | Barre pleine aux deux formats ; aucun repli d'information existante ; le bloc PC montre aussi les montants. CA-U2 se lit alors « classement visible pendant toute la partie (bloc PC, languette téléphone) ». |
| 2 | D12 : liste des ventes complète (textes) sur la carte du jour J | Carte principale : liste **chiffrée** courte (net, écart, coût) ; textes complets (`texte_ecart`, `texte_penalite`) dans la confirmation | Hauteur du téléphone ; le joueur voit les montants pour décider, et lit les phrases avant de confirmer. |
| 3 | D12 : ni Échap ni clic extérieur | Inchangé, sauf **Échap = RETOUR** dans l'écran de confirmation | Échap ne ferme jamais la carte ; il annule seulement une étape sans effet. À refuser si la recette préfère une règle unique. |
| 4 | 16 §5.2 : rang en Pixelify 32 | Rang en **Atkinson gras** partout | Règle des chiffres (le « 5 » de Pixelify ressemble à un S). |
| 5 | Barres de fin : libellés 18 | 20 | Minimum Atkinson de la version pixel. |
| 6 | 17 §4.5 / E3 : liseré **sarcelle** pour la rue | **Bleu vif `#2F7FD1`** | La sarcelle n'est pas parmi les 40 couleurs d'interface ; le bleu vif y est et c'est la couleur de la plaque de rue (clôt mon point U9). |
| 7 | — | Ajouts **facultatifs** au contrat : `disponible` dans le choix de projet ; `titre_barres` dans « un an après » ; `partiel: bool` dans une vente (ajouterait « en partie » au nom) | Rien ne bloque sans eux. |

---

## 4. Contrôles utiles pour les captures (proposés, à reprendre dans les CA)

- `projet_choix` : `UI projet options=3 hauteurs_egales=oui note_sous=<oui|non>` ; `cibles … sous_seuil=0` ; `chiffres_pixelify=0`.
- `projet_jour_j` (3 cas) puis confirmation : `UI projet confirmation ventes=<n> total=<F> reste=<F>` ; `defilant_seul=oui` (total et boutons visibles).
- Étiquette : `UI etiquette maison lignes=2 texte="21 400 / 30 000 F"` ; `chevauchements_etiquettes()=0`.
- `rue_bloc` PC et `rue_pastille` téléphone (languette) : `UI rue rang=<n> lignes=4 negatif_signe=oui panneau_coupe=non`.
- `krach_jours` : `UI krach_jours cases=<8|7> choix_visibles=oui`.
- `un_an_apres` (4 cas) : `UI gazette barres=3 entouree=<id|aucune> ordre=vendu,rien,renforce`.
- `fin_rue` : `UI fin barres=4 rang=<n> replique=<oui|non>`.

## 5. Où des illustrations aideraient le plus (après le verdict du joueur)
1. Les **4 portraits 32 × 32** des voisins (bloc La rue, notifications, fin) : remplacent les pastilles d'initiale sans changer la mise en page (même case de 30 → 32 × 32 à ×1, ou 96 à ×3 dans la carte de lecture).
2. Les **6 icônes de projet** en 16 × 16 (puis 32 × 32) : présentes à 3 endroits (choix, jour J, étiquette).
3. Une **vignette** pour « un an après » (la corbeille un an plus tard), dans la bande vide au-dessus du graphique.
