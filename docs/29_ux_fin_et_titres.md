# 29 : UX de l'écran de fin complet, du palmarès de l'écran titre et de la collection des titres (U5)

> Auteur : designer UX. Date : 2026-11-13. Pour : chef de projet, puis dev-interface (07-I : I1, I2, I3, I4).
> Réponse à la demande **U5** de `docs/lots/audit_preparation.md` §3. Cadre : `docs/lots/lot_07.md` D9-D11 et §2 (contrat `Bilan`, `Titres`, `Records`), docs/15 §6 (9 titres), docs/24 §2.6 (bloc des 4 barres), `lot_sauvegarde.md` §2 (ligne « hors record »).
> **Conventions : celles de docs/24 §0**, sans exception (texels de 3 px virtuels, PC 1920 × 1080 T = 3, téléphone 1440 × 648 T = 5, cibles ≥ 81 px PC et ≥ 72 px téléphone (48 dp), Pixelify jamais avec un chiffre, Atkinson ≥ 20 pour tout chiffre, ▲ / ▼ + signe en plus de la couleur, sprites 16 × 16 et portraits 48 × 48 à ×3 seulement, **aucune animation nouvelle**).
> Ce document remplace les défauts D10-D11 là où il les précise ; écarts au §5.

---

## 0. Constats sur l'existant (à lire avant de coder)

| # | Constat (code de `main`) | Conséquence |
|---|---|---|
| K1 | Les **5 étoiles** sont calculées dans `Bilan.calculer` (`etoiles`, `nb_etoiles`) mais **ne sont affichées nulle part** : `ModaleReleveFin.fin_demo` ne les lit pas. | D9 « étoiles gardées » = **rien à l'écran** aujourd'hui. Je ne les ajoute pas (docs/15 §6 : « pas d'étoiles »). Si le game designer (G6 point 5) veut les montrer, leur place est réservée au §1.5. |
| K2 | Le titre de l'écran de fin (« DÉCEMBRE 1988 · CINQ ANS DE LA VIE DE GÉRARD ») est en `Style.neon()` alors qu'il contient un chiffre. | Le passer en **Atkinson gras 36** (PC) / 28 (téléphone), couleur ambre, même ombre : règle `Style.police_pour`. Contrôle `chiffres_pixelify=0` (CA-T7). |
| K3 | Le panneau de fin apparaît par une mise à l'échelle 0,85 → 1 (`TRANS_BACK`). | Animation **existante** : on la garde (pas d'ajout, pas de retrait). Le roulement du patrimoine (`Juice.rouler`) et la course des barres (`barres.animer`) restent. Tout le reste est posé sans animation. |
| K4 | `humeur_visible()` : docs/17 §4 numérote contente = 0, fâchée = 2 ; `lot_07` D2 écrit « fâchée / contente = 0 / 2 ». | L'interface n'affiche **jamais le nombre** : elle lit l'humeur et écrit la phrase de docs/17 (« Sylvie est contente » / « Sylvie va bien » / « Sylvie fait la tête »). À trancher par dev-logique dans le contrat (`bilan["humeur_fin"]`), pas par l'interface. |

---

## 1. Écran de fin complet (07-I, I1)

### 1.1 Principe

L'écran garde sa structure (titre, patrimoine, comparaison, frais, phrase, deux boutons) mais passe de **une colonne + courbe** à **deux colonnes sous une bande « titre d'époque »**. Ordre de lecture voulu : **qui je suis devenu (titre) → mon foyer (Sylvie, projets) → où j'en suis dans la rue (4 barres) → combien (patrimoine, Tata, record) → le détail (frais, phrase)**. Le titre d'époque est la récompense : il est en haut, en grand, mais sans effet.

### 1.2 PC (panneau 1500 × ≈ 850, centré ; tient aussi en 1920 × 1009)

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓                    DÉCEMBRE 1988 · CINQ ANS DE LA VIE DE GÉRARD                  ← Atkinson gras 36, ambre ▓
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌──────────────────────────────────────────┐ ▓
▓ ▓ VOTRE TITRE D'ÉPOQUE        [NOUVEAU DANS LA COLLECTION]▓ │ ┌────────┐ LE FOYER                      │ ▓
▓ ▓ LE MARIN PAR GROS TEMPS                     (Pixelify 48)▓ │ │ Sylvie │ Sylvie est contente.          │ ▓
▓ ▓ « Vous avez traversé la tempête sans quitter le bateau. »▓ │ │ 48×48  │ Projets : 2 sur 2 réalisés    │ ▓
▓ ▓                                    (Atkinson 24 italique)▓ │ │  ×3    │ ✓ Le salon · ✓ La Super 5     │ ▓
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ │ └────────┘                               │ ▓
▓                                                           └──────────────────────────────────────────┘ ▓
▓ LA RUE : VOUS ET VOS VOISINS        [2e DE LA RUE SUR 4]  │ VOTRE PATRIMOINE           160 749 F      ▓
▓ 1 TATA LIVRET     ████████████████████████████ 165 300 F  │                     (Atkinson gras 60)    ▓
▓   ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄  │ ┌────────────────────────────────────────┐▓
▓ 2 VOUS            ███████████████████████████  160 749 F  │ │ ▼ VOUS : 4 551 F de moins que Tata     │▓
▓ 3 TONTON MATELAS  ███████████████████████      139 800 F  │ │   Livret (− 3 %)                       │▓
▓ 4 JEAN-MI         ▏                           − 12 400 F  │ └────────────────────────────────────────┘▓
▓ (J) Jean-Mi : « La Porsche ? Revendue. Et je rembourse    │ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ▲ + 12 % face à Tata  ▓
▓     encore ma banque. »                  (Atkinson 22 it.) │ ▓NOUVEAU RECORD !▓   (ancien : + 7 %)    ▓
▓ Argent mis de côté en cinq ans : 98 400 F                 │ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘                        ▓
▓                                                           │ CINQ ANS EN UN COUP D'ŒIL                 ▓
▓                                                           │ [courbe vous / Tata, 150 px]   — Vous — Tata ▓
▓ ──────────────────────────────────────────────────────────────────────────────────────────────────── ▓
▓ Frais payés : 4 120 F · Tata Livret : 0 F                Produits découverts 7/9 · utilisés 4/9      ▓
▓       « Cette fois, le Livret A a fait mieux de 4 551 F. Les frais et le krach sont passés par là… »    ▓
▓ ╔══════════════════════════════════════════════╗ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ▓
▓ ║ REJOUER AUTREMENT                            ║ ▓ QUITTER                                    ▓ ▓
▓ ╚══════════════════════════════════════════════╝ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

| Bloc | Règle PC |
|---|---|
| Panneau | 1500 de large (marges 39 = 13 t), contenu 1422 ; hauteur au contenu, ≈ 850 ; assombrissement 0,65 (existant) |
| En-tête | voir K2 ; hauteur 48 |
| **Bande du titre** (gauche, 870 px) | plaque `Pastille` contour **ambre** 2 t, fond panneau ; ligne 1 « VOTRE TITRE D'ÉPOQUE » petites capitales 20 secondaire ; ligne 2 `bilan["titre"]["nom"]` en **capitales Pixelify 48** crème (aucun titre de la liste n'a de chiffre ; si un jour il en a un : Atkinson gras 40, règle `police_pour`), 2 lignes au plus ; ligne 3 `pourquoi` entre « », Atkinson 24 italique, 2 lignes au plus. Hauteur ≈ 156 |
| Pastille « NOUVEAU DANS LA COLLECTION » | coin haut droit de la plaque, petites capitales 20, encre sur ambre ; seulement si ce titre a `nombre == 1` dans `bilan["record"]["collection"]` (ajout facultatif, §5 écart 4) ; sinon rien |
| **Le foyer** (droite, 534 px) | cadre `PANNEAU_SURVOL` 1 t ; portrait de Sylvie **48 × 48 ×3 = 144 px** à gauche (expression = humeur de fin) ; à droite : « LE FOYER » petites capitales 20 ; la **phrase d'humeur** de docs/17 (Atkinson 22) ; « Projets : 2 sur 2 réalisés » (Atkinson gras 22) ; une ligne par projet : sprite ✓ / ↻ / ✗ **et** le nom court (Atkinson 20, secondaire), 1 ligne, « … » si trop long. Visage + phrase + chiffre : trois indices (principe 16) |
| Projets, cas | `total == 0` : la ligne « Projets » est absente, la phrase d'humeur reste ; 1 réalisé : « Projets : 1 sur 2 réalisés » ; « réalisé » au singulier si `realises <= 1` |
| **Colonne gauche « La rue »** (870 px) | exactement docs/24 §2.6 (4 barres 192 px, rang en pastille neutre, pointillé ambre sous Tata, négatif sans barre avec « − » et couleur perte, réplique, « Argent mis de côté ») |
| **Colonne droite « Combien »** (534 px) | « VOTRE PATRIMOINE » petites capitales 20 + montant Atkinson gras **60** aligné à droite (roulement existant) ; pastille de comparaison existante **avec le % ajouté** : « VOUS : 4 551 F de moins que Tata Livret (− 3 %) » (`bilan["ecart_tata_pct"]`, arrondi à l'unité, ▲ / ▼ + signe), 2 lignes au plus ; **ligne du record** (§1.4) ; courbe des cinq ans réduite de 250 à **150 px** + légende (existante) |
| Séparation | filet `PANNEAU_SURVOL` 1 t sur toute la largeur |
| Frais / produits | inchangés (une ligne, cuivre / crème) ; ligne « Exemple : 10 000 F placés 20 ans… » inchangée quand les frais sont nuls (+ 60 px, budget compris) |
| Phrase de synthèse | inchangée, Atkinson 24, centrée, 2 lignes au plus |
| Boutons | inchangés : REJOUER AUTREMENT (principal ambre) et QUITTER (secondaire), 81 px, moitié de largeur chacun |

**Budget vertical PC** : 39 + en-tête 48 + 12 + bande 156 + 12 + colonnes ≈ 360 + 12 + filet 3 + 12 + frais 33 + 12 + phrase 60 + 12 + boutons 81 + 39 ≈ **891 px** ; avec la ligne « Exemple » ≈ 951. Tient en 1009 (fenêtre avec barre des tâches) sans défilement. Le nœud « Defilant » existant reste en secours.

### 1.3 Téléphone 1440 × 648 (panneau 1380 × 648 max, contenu ≈ 1324)

Rien n'est retiré : ce qui ne tient pas passe **dans la zone qui défile** (nœud `Defilant`), annoncée par une ligne « ▼ La suite : frais, phrase, courbe » quand elle n'est pas entièrement visible.

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓            DÉCEMBRE 1988 · CINQ ANS DE LA VIE DE GÉRARD     (Atkinson gras 28) ▓   ┐
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐  LA RUE              [2e DE LA RUE SUR 4]▓   │
▓ ▓┌──────┐ VOTRE TITRE D'ÉPOQUE     ▓  1 TATA LIVRET   ███████████████ 165 300 F ▓   │
▓ ▓│Sylvie│ LE MARIN PAR GROS TEMPS  ▓    ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄  ▓   │ toujours
▓ ▓│ 144 │ (Pixelify 36, 2 lignes)   ▓  2 VOUS          ██████████████  160 749 F ▓   │ visible
▓ ▓│      │ « Vous avez traversé la  ▓  3 TONTON MAT.   ████████████    139 800 F ▓   │ (≈ 470 px)
▓ ▓└──────┘ tempête… » (20 it.)      ▓  4 JEAN-MI       ▏              − 12 400 F ▓   │
▓ ▓ Sylvie est contente · Projets : 2 sur 2 réalisés  ▓                          ▓   │
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘                                           ▓   │
▓ VOTRE PATRIMOINE  160 749 F  (gras 44)   ▼ VOUS : 4 551 F de moins que Tata (− 3 %)▓   │
▓ [NOUVEAU RECORD !] ▲ + 12 % face à Tata Livret (ancien : + 7 %)                  ▓   ┘
▓ ┌ zone qui défile ───────────────────────────────────────────────────────────┐   ▓   ┐
▓ │ (J) Jean-Mi : « La Porsche ? Revendue… »  · Argent mis de côté : 98 400 F    │   ▓   │ ≈ 100 px
▓ │ ▼ La suite : frais, phrase, courbe                                          │   ▓   │ visibles
▓ └─────────────────────────────────────────────────────────────────────────────┘   ▓   ┘
▓ ╔════════════════════════════════════╗ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐  ▓   72 px
▓ ║ REJOUER AUTREMENT                  ║ ▓ QUITTER                            ▓  ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

**Ce qui se replie au téléphone** (et où il va : rien ne disparaît)

| Élément | PC | Téléphone |
|---|---|---|
| Titre d'époque + pourquoi | bande pleine largeur | **colonne gauche** (560 px), nom en Pixelify 36 (2 lignes), pourquoi Atkinson 20 italique (2 lignes, sinon « … » et la phrase entière est redite en tête de la zone qui défile) |
| Portrait de Sylvie | 144 px dans le bloc « Le foyer » | **144 px** (×3 obligatoire à T = 5) **dans la plaque du titre**, à gauche |
| Bloc « Le foyer » | cadre à part, phrase + projets + liste des projets | **une ligne** sous le titre : « Sylvie est contente · Projets : 2 sur 2 réalisés » (Atkinson 20) ; la **liste des projets** (✓ noms) passe dans la zone qui défile |
| Pastille « NOUVEAU DANS LA COLLECTION » | coin de la plaque | même place, petites capitales 20 (la plaque a la largeur) |
| 4 barres + rang | colonne gauche | **colonne droite** (≈ 740 px), barres 168 (docs/24 §2.6), libellés « TONTON MAT. » si la colonne titre fait moins de 200 px |
| Patrimoine + comparaison | colonne droite, 3 lignes | **une ligne** : patrimoine Atkinson gras 44 à gauche, pastille de comparaison à droite (1 ligne, « Tata » sans « Livret » si besoin ; le % reste) |
| Record / hors record | ligne dans la colonne droite | **une ligne** pleine largeur sous le patrimoine (§1.4) |
| Réplique du voisin, « Argent mis de côté » | colonne gauche | **zone qui défile**, en tête |
| Frais, produits, « Exemple », phrase de synthèse | sous les colonnes | **zone qui défile**, dans cet ordre |
| Courbe des cinq ans | colonne droite (150 px) | **zone qui défile**, en dernier (150 px). Aujourd'hui elle est absente en compact : je la rends, puisque « rien de caché » |
| Boutons | 81 px | 72 px, toujours visibles |

**Budget vertical téléphone** : 18 + en-tête 36 + 6 + bloc à 2 colonnes **≈ 210** (plaque : max(144, 24 + 84 + 52) + 30 ; rue : 30 + 168) + 6 + patrimoine 54 + 6 + record 39 + 6 + zone qui défile **≥ 96** + 6 + boutons 72 + 18 ≈ **573 px sur 648** (marge de 75 px pour le nom de titre le plus long sur 2 lignes et la pastille de collection). Contrôle : `UI fin defilant_visible>=96 boutons_visibles=oui`.

### 1.4 La ligne du record (états exclusifs)

| Cas (contrat `bilan["record"]`) | Affichage | Style |
|---|---|---|
| `nouveau: true`, ancien vide (1re partie comptée) | **[NOUVEAU RECORD !]** + « ▲ + 12 % face à Tata Livret · votre premier résultat enregistré » | pastille `bouton_principal` ambre non cliquable (`MOUSE_FILTER_IGNORE`), texte **Pixelify 28 encre** (aucun chiffre) ; le reste Atkinson gras 24 crème |
| `nouveau: true`, ancien présent | **[NOUVEAU RECORD !]** + « ▲ + 12 % face à Tata Livret (ancien : + 7 %) » | idem |
| `nouveau: false`, pas hors record | « Votre record : ▲ + 12 % face à Tata Livret (2e de la rue, Le marin par gros temps) » | Atkinson 22 **secondaire**, sans pastille (information, pas récompense) |
| `hors_record: true` | « Partie rejouée depuis une sauvegarde : hors record » | Atkinson 22 crème dans une pastille **contour pointillé** `PANNEAU_SURVOL` 1 t, sans fond ; à gauche un sprite ↻ 16 × 16 ×3 (celui du projet reporté). Ni rouge ni ambre : ce n'est ni une faute ni une récompense. Le titre, le rang et la collection restent affichés normalement |
| Faillite ou abandon (`bilan["titre"]` vide) | ligne absente ; **bande du titre absente** (le bloc « Le foyer » prend la largeur sur PC ; au téléphone, la plaque garde le portrait et la ligne foyer) | — |
| Écart négatif | ▼ + « − 3 % » ; couleur perte **seulement sur la flèche et le nombre** de la pastille de comparaison ; dans la ligne du record le nombre reste crème (un record peut être négatif : pas de rouge sur une récompense) | — |

Format du pourcentage : entier, signe et espace insécable (« + 12 % », « − 3 % ») ; « 0 % » sans flèche. Même format sur l'écran titre (§2).

### 1.5 Les 5 étoiles (en attente de G6 point 5)

Défaut : **non affichées** (K1). Si le game designer demande de les montrer : une ligne dans la zone « détail » (PC sous les frais ; téléphone dans la zone qui défile) : « OBJECTIFS : 3 SUR 5 » (Atkinson gras 22) puis les 5 règles de `etoiles[i]["regle"]`, chacune précédée d'un sprite ✓ ou ✗ **et** du mot « atteint » / « non atteint » (Atkinson 20). Jamais à côté du titre d'époque (deux récompenses concurrentes) ; ≈ 200 px de plus : au PC, la courbe tombe alors à 120 px.

### 1.6 Interaction

- Aucune touche nouvelle : 1 / Entrée = REJOUER AUTREMENT, 2 = QUITTER si c'est déjà le cas ; ni Échap ni clic extérieur (écran de fin).
- La zone qui défile se fait glisser au doigt et à la molette ; la ligne « ▼ La suite… » est un simple libellé (pas une cible).
- Captures (CA-T7) : `fin_titre`, `fin_record`, `fin_hors_record`, plus `fin_sans_titre` (faillite fabriquée) proposé ; lignes `UI fin titre="<nom>" pourquoi=oui record=<nouveau|ancien|hors|aucun> projets=<n>/<t> humeur=<0|1|2> debordements=0 chiffres_pixelify=0`.

---

## 2. Écran titre : la ligne du palmarès et le bouton TITRES (07-I, I2)

### 2.1 Place

Sous la ligne de reprise (« Partie en cours : Gérard · mai 1987 · patrimoine … ») et **au-dessus de l'aide F10** : une rangée « palmarès » = la phrase du meilleur résultat + le bouton TITRES. La pile de l'écran titre reste ancrée en bas : la plaque de l'accroche monte de ≈ 90 px (à vérifier sur la capture : elle ne doit pas couvrir l'enseigne néon de la Gazette ; sinon `offset_bottom` passe de −40 à −24).

**PC**
```
                ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
                ▓        (accroche, Pixelify 48)                ▓
                ▓        (sous-titre, Atkinson 24)              ▓
                └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
         ╔════════════════════╗ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐                      96 px (existant)
         ║     CONTINUER      ║ ▓  NOUVELLE PARTIE   ▓
         ╚════════════════════╝ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
            Partie en cours : Gérard · mai 1987 · patrimoine 98 200 F      Atkinson 22 (existant)
  ┌──────────────────────────────────────────────────────────────────┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
  │ Meilleur résultat : ▲ + 12 % face à Tata Livret · 2e de la rue · │ ▓ TITRES 3 / 9 ▓   81 px
  │ Le marin par gros temps                                          │ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
  └──────────────────────────────────────────────────────────────────┘
```

| Élément | Règle |
|---|---|
| Phrase | « Meilleur résultat : » (Atkinson 22, secondaire) + « ▲ + 12 % face à Tata Livret · 2e de la rue · Le marin par gros temps » (Atkinson **gras** 22, crème) ; le nom du titre **en Atkinson** (dans une phrase avec chiffres, pas de Pixelify) ; ▲ / ▼ sprite 8 × 8 ×3 devant le signe ; 2 lignes au plus |
| Lisibilité sur la rue | la phrase est posée sur une plaque `panneau` (même 9-patch que l'accroche, opacité 0,94), marges 18 / 9 : elle passe devant la vitrine de la banque ou de la maison selon le format |
| Bouton TITRES | `Button` **sans texte** contenant une `HBox` de deux libellés en `MOUSE_FILTER_IGNORE` (même technique que la languette de docs/24 §2.1) : « TITRES » Pixelify 28 + « 3 / 9 » Atkinson gras 28 ; style secondaire ; 81 px PC / 78 px téléphone de haut, ≈ 230 de large ; touche **T** sur PC |
| Données | `Records.lire()["record"]` (écart, rang, titre) ; n = nombre d'ids de `collection` ; 9 = `Titres.tous().size()` |
| Rangée | `HBox` centrée, écart 18 ; la phrase prend la largeur restante, au plus 1100 px |

| Cas | Rangée |
|---|---|
| Pas de `records.sav` (ou vide) | **absente** : écran identique à `main` (CA-T8) |
| Collection non vide, record vide (seulement des parties hors record) | bouton TITRES seul, centré |
| Record présent | phrase + bouton |
| Rang 1 | « 1er de la rue » ; écart négatif : ▼ « − 3 % face à Tata Livret » |

**Téléphone 1440 × 648** : même rangée ; la phrase tient sur 2 lignes dans ≈ 1100 px à 22 ; bouton 78 px. Budget de la pile : accroche + sous-titre ≈ 120 + 14 + boutons 96 + 14 + reprise 30 + 14 + palmarès 78 + 40 ≈ **406 px** : reste ≈ 240 px de rue visible au-dessus.

---

## 3. La fenêtre de la collection (07-I, I3)

Fenêtre **de lecture** (Échap, clic extérieur et FERMER la ferment ; aucune décision). Panneau nuit `Style.panneau`, ouverte sur place (fondu ≤ 0,2 s existant). Ouverte par TITRES (écran titre) ; **pas** depuis le jeu (rien à y faire pendant une partie ; à rouvrir si le client le demande).

**Une grille 3 × 3 sans défilement**, dans l'ordre `ordre` 1 → 9 (l'ordre d'évaluation de docs/15 §6, pas un classement de prestige : je n'affiche donc pas « rang » mais le numéro dans un carré).

**PC** : panneau 1260 × ≈ 700.
```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ LES TITRES D'ÉPOQUE   (Pixelify 36)     3 SUR 9 OBTENUS (Atkinson gras 24)   ┌▓▓▓▓▓▓▓▓┐▓
▓ Un titre par partie terminée, selon votre façon de jouer.    (Atkinson 20)   ▓ FERMER ▓▓
▓                                                                              └▓▓▓▓▓▓▓▓┘▓
▓ ┌───────────────────────────┐ ┌┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┐ ┌───────────────────────────┐ ▓
▓ │[1] LE BON PÈRE DE FAMILLE │ ┊[2] ???                    ┊ │[3] L'ÉLEVEUR D'ESCARGOTS  │ ▓
▓ │    Obtenu 2 fois          │ ┊                           ┊ │    Obtenu 1 fois          │ ▓
▓ │    1re fois : 12/11/2026  │ ┊                           ┊ │    1re fois : 13/11/2026  │ ▓
▓ └───────────────────────────┘ └┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┘ └───────────────────────────┘ ▓
▓ ┌┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┐ ┌┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┐ ┌───────────────────────────┐ ▓
▓ ┊[4] ???                    ┊ ┊[5] ???                    ┊ │[6] LE MARIN PAR GROS TEMPS│ ▓
▓ ┊                           ┊ ┊                           ┊ │    Obtenu 1 fois          │ ▓
▓ └┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┘ └┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┘ └───────────────────────────┘ ▓
▓ (ligne 3 : 7, 8, 9)                                                                       ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

| Élément | Règle |
|---|---|
| Tuile | PC 390 × 168 (130 × 56 t), écarts 18 ; téléphone 432 × 138 (144 × 46 t), écarts 12 ; **pas une cible** (lecture seule) |
| Numéro | carré encre 36 × 36 (12 t), chiffre Atkinson gras 22 crème |
| Titre obtenu | cadre `PANNEAU_SURVOL` 1 t plein, fond panneau ; nom en **Atkinson gras 24 capitales** (les noms font jusqu'à 34 caractères : Pixelify trop large ici), 2 lignes au plus ; « Obtenu 2 fois » / « Obtenu 1 fois » (Atkinson 20, crème) ; « 1re fois : 12/11/2026 » (Atkinson 20, secondaire ; date réelle `premiere`, format jj/mm/aaaa) |
| Titre non obtenu | cadre **pointillé** `PANNEAU_SURVOL` 1 t, fond transparent ; numéro + « ??? » Atkinson gras 24 **secondaire**. Deux indices (pointillé + « ??? »), aucune couleur seule, aucun cadenas |
| Titre de la dernière partie | si la fenêtre s'ouvre juste après une fin (écran titre revenu après REJOUER / QUITTER) : cadre **ambre** 1 t sur la tuile du titre obtenu + mot « DERNIÈRE PARTIE » (petites capitales 20) — facultatif, sans animation |
| « pourquoi » | **absent** de la collection, aux deux formats (il est lu à la fin de partie). Pas de version « PC seulement » : il serait caché au téléphone. S'il est demandé un jour, il faudra une 2e page ou une fiche ouverte par un toucher sur la tuile |
| En-tête | « LES TITRES D'ÉPOQUE » Pixelify 36 ; « 3 SUR 9 OBTENUS » Atkinson gras 24 ; phrase Atkinson 20 secondaire ; FERMER secondaire 81 × ≈ 200 (PC) / 78 (téléphone), en haut à droite |
| Si G6 choisit « cachés » au lieu de « ??? » | grille inchangée, les tuiles non obtenues restent (pointillé) mais sans numéro ; « 3 SUR 9 » reste (sinon le joueur ne sait pas qu'il en reste) |

**Téléphone 1440 × 648** : panneau 1356 × ≈ 560 ; en-tête sur **une** ligne de 78 px (titre 28, compteur 22, FERMER à droite ; la phrase d'aide passe sous la grille en Atkinson 20) ; grille 3 × 138 + 2 × 12 = 438. Budget : 18 + 78 + 12 + 438 + 12 + 26 + 18 ≈ **602 px**. Contrôle : `UI titres tuiles=9 obtenus=<n> debordements=0 cibles sous_seuil=0`.

---

## 4. Contrôles proposés pour les captures (I4)

- `fin_titre`, `fin_record`, `fin_hors_record` (+ `fin_sans_titre`) en PC 1920 × 1080 et 1920 × 1009, téléphone 1440 × 648 : ligne `UI fin …` du §1.6.
- `titre_record` : `UI titre palmares=<absent|bouton|complet> texte="<phrase>" titres=<n>/9` ; sans `records.sav` : capture identique à `titre` de `main`.
- `titres_collection` : contenu fabriqué (3 obtenus dont un 2 fois, 6 « ??? »).

## 5. Écarts aux défauts de `lot_07.md` (à arbitrer par le chef de projet)

| # | Défaut | Ce document | Raison |
|---|---|---|---|
| 1 | D10 : ajout au bloc de 05-I | Écran réorganisé en bande du titre + 2 colonnes (PC) | Sans cela, PC dépasse 1009 px de haut avec le titre, le foyer et la ligne du record. |
| 2 | Courbe absente au téléphone (existant) | Courbe dans la zone qui défile | « Rien de caché au téléphone ». |
| 3 | D9 : étoiles « gardées » | Rien à afficher (elles ne le sont pas aujourd'hui, K1) ; place réservée §1.5 | Constat du code. |
| 4 | — | Ajouts facultatifs : `ecart_tata_pct` dans la pastille de comparaison ; « NOUVEAU DANS LA COLLECTION » (lu dans `bilan["record"]["collection"]`) ; « DERNIÈRE PARTIE » dans la collection | Lient la fin, le record et la collection sans animation. Rien ne bloque sans eux. |
| 5 | En-tête de fin en `Style.neon()` | Atkinson gras (K2) | Règle des chiffres. |
| 6 | D11 : ligne puis bouton | Une seule rangée (phrase + bouton), phrase sur plaque | Lisible devant n'importe quelle façade ; une ligne de moins. |

## 6. Où une illustration aiderait le plus
1. **Un sceau ou une médaille pixel par titre** (9 × 32 × 32) : à gauche du nom dans la bande du titre et dans chaque tuile de la collection (les « ??? » montreraient la silhouette noire). C'est l'ajout le plus motivant pour rejouer.
2. Les 3 expressions de Sylvie en 48 × 48 existent déjà ; une 4e « fin de partie » (Sylvie et Gérard ensemble, 96 × 48) remplacerait le portrait seul.
