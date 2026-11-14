# 30 : UX de la sauvegarde manuelle (U6, préparation)

> Auteur : designer UX. Date : 2026-11-13. Pour : chef de projet ; dev-interface au lancement de **SV-I**.
> **Lot non lancé** (`docs/lots/lot_sauvegarde.md`, statut « planifié, NON LANCÉ ») : maquettes de préparation, aucune tâche de développement n'en découle avant le feu vert du joueur (Q-J4).
> Réponse à la demande **U6** de `docs/lots/audit_preparation.md` §3. Cadre : `lot_sauvegarde.md` §1 (design validé), §4.4 (`Options`, `EcranEmplacements`, bandeau), §5.2 (tâches SV-I), §7 (CA-SI1 à SI8).
> **Conventions : celles de docs/24 §0** (texels de 3 px virtuels ; PC 1920 × 1080, T = 3 ; téléphone 1440 × 648, T = 5 ; cibles ≥ 81 px PC, ≥ 72 px = 48 dp téléphone, 78 visé ; Pixelify sans chiffre ; Atkinson ≥ 20 pour tout chiffre ; sprites 16 × 16 à ×3 ; **aucune animation nouvelle** : apparitions sur place, fondu ≤ 0,2 s existant).

---

## 0. Constats sur l'existant (à relire au lancement)

| # | Constat (code de `main`) | Conséquence pour SV-I |
|---|---|---|
| K1 | `Modales` n'a **qu'une modale courante** (`courant`, `genre_courant`) ; `fermer()` émet `choix_fait`. | L'écran des emplacements ouvert **depuis une carte** ne peut pas remplacer la carte (ce serait un choix fait). Il doit être posé **au-dessus**, sur sa propre couche (`CanvasLayer` au-dessus de celle des modales), hors de `Modales.courant`. Repli si la superposition est trop coûteuse : voir §3.5. |
| K2 | Dans le journal du krach, **Échap choisit « rien »** (`_unhandled_key_input`), et les touches 1-3 choisissent. | Tant que l'écran des emplacements est ouvert, il doit **consommer** 1, 2, 3, Échap et Entrée (`set_input_as_handled`) : aucune touche ne doit traverser jusqu'à la carte. Test à écrire (CA-SI4) : ouvrir l'écran par `S` depuis le krach, appuyer sur 2, Échap → emplacement 2 choisi, puis fermeture ; **aucun** choix du journal. |
| K3 | Le menu actuel : panneau 460 px, MENU, REPRENDRE (principal), HISTORIQUE, QUITTER LE JEU ; clic extérieur et Échap = REPRENDRE. | Garder ces comportements ; la bascule ne ferme pas le menu. |
| K4 | La feuille d'ordre de la banque tient de justesse dans 648 px au téléphone (`panneau_banque.gd`, commentaires C4). | Le bouton « Sauvegarder d'abord » ne prend **aucune hauteur** : il partage la rangée du bouton de validation (§4). |

---

## 1. Le menu (SV-I tâche 1)

Une colonne, mêmes boutons qu'aujourd'hui (`Style.bouton`), largeur portée à **600 px** pour la bascule. Ordre : on reprend, on garde, on revient, on relit ; puis le réglage ; puis on sort.

**PC** (panneau 600 × ≈ 690) et **téléphone** (même panneau, boutons de 78 px, ≈ 615 px de haut sur 648)
```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ MENU                                     (petites cap. 24) ▓
▓ ╔══════════════════════════════════════════════════════╗ ▓
▓ ║ REPRENDRE                                            ║ ▓  principal ambre (existant)
▓ ╚══════════════════════════════════════════════════════╝ ▓
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ▓
▓ ▓ [disq.] SAUVEGARDER                                 ▓ ▓  secondaire ; icône 16×16 ×3 facultative
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ ▓
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ▓
▓ ▓ CHARGER                                             ▓ ▓  secondaire
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ ▓
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ▓
▓ ▓ HISTORIQUE                                          ▓ ▓  secondaire (existant)
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ ▓
▓ ─ OPTION ───────────────────────────────────────────── ▓  petites cap. 20 + filet 1 t
▓ ┌──────────────────────────────────────────┬──────────┐ ▓
▓ │ Proposer de sauvegarder avant les grandes│ ▐█OUI█▌non│ ▓  une seule cible (toute la rangée)
▓ │ décisions                    (Atkinson 22)│          │ ▓
▓ └──────────────────────────────────────────┴──────────┘ ▓
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ▓
▓ ▓ QUITTER LE JEU                                      ▓ ▓  secondaire (existant)
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ ▓
▓ La partie en cours est gardée : CONTINUER la reprendra.   ▓  Atkinson 20, secondaire
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

| Élément | Règle |
|---|---|
| Boutons | 81 px PC, 78 px téléphone, écart 12 / 9 ; libellés Pixelify 28 (aucun chiffre) |
| Bascule | `Button` en `toggle_mode` **sans texte** contenant : à gauche le libellé (Atkinson 22, 2 lignes, `MOUSE_FILTER_IGNORE`) ; à droite un interrupteur pixel 144 × 48 (48 × 16 t) à deux cases « OUI » / « NON » en Pixelify 20 capitales : la case active est **pleine ambre, texte encre, cadre encre 1 t** ; l'autre **vide, texte secondaire**. Deux indices (remplissage + mot), jamais la couleur seule. Hauteur de la rangée 81 / 78. Le toucher n'importe où sur la rangée bascule ; **Espace / Entrée** quand elle a le focus. Effet immédiat (`Options.regler_proposer_sauvegarde`), le menu reste ouvert, aucune confirmation |
| SAUVEGARDER désactivé | partie finie ou `sauvegarde_auto` faux (tests) : **hachures en marches** + texte à 60 % + 2e ligne « Partie terminée » (Atkinson 20) ; même taille, aucune réaction |
| CHARGER désactivé | aucun emplacement plein : hachures + « Aucune sauvegarde » |
| Ligne finale | rassure sur QUITTER (la sauvegarde automatique existe) ; Atkinson 20 |
| Interaction | Échap et clic extérieur = REPRENDRE (existant). SAUVEGARDER et CHARGER ferment le menu (`fermer("sauvegarder")` / `fermer("charger")`) puis `principal.gd` ouvre l'écran des emplacements ; le saut est arrêté avant (`sauvegarder_dans` le fait aussi) |

Budget téléphone : 18 + 30 + 6 × 78 + 5 × 9 + filet 24 + 26 + 18 ≈ **629 px** (si la bascule passe à 2 lignes de 26, la rangée reste à 78). Si une mesure dépasse 642 : la ligne finale passe à côté de QUITTER LE JEU (2 colonnes), jamais retirée.

---

## 2. L'écran des 3 emplacements (`EcranEmplacements`, SV-I tâche 2)

### 2.1 Disposition commune

Fenêtre système (panneau **nuit**, pas de papier : ce n'est pas un objet du monde), **trois emplacements côte à côte** (paysage ; ordre 1, 2, 3 = touches 1, 2, 3). Chaque emplacement est **une seule cible**.

**PC** : panneau 1260 × ≈ 600 ; cases 396 × 282 (132 × 94 t), écart 18. **Téléphone** : panneau 1356 × ≈ 600 ; cases 432 × 246 (144 × 82 t), écart 12.

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ SAUVEGARDER LA PARTIE                       (Pixelify 36 ; tél. 28)  ┌▓▓▓▓▓▓▓▓▓▓┐ ▓
▓ Avant : le krach d'octobre 1987     (Atkinson gras 22, si libellé)   ▓  FERMER  ▓ ▓
▓ Choisissez un emplacement.                      (Atkinson 20)        └▓▓▓▓▓▓▓▓▓▓┘ ▓
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┐  ▓
▓ ▓ [1] GÉRARD              ▓ ▓ [2] GÉRARD              ▓ ┊ [3]                     ┊  ▓
▓ ▓ mars 1986               ▓ ▓ septembre 1987          ▓ ┊                         ┊  ▓
▓ ▓ 69 395 F                ▓ ▓ 112 800 F               ▓ ┊   EMPLACEMENT VIDE      ┊  ▓
▓ ▓ Sauvegarde du menu      ▓ ▓ Avant : Le jour J : la  ▓ ┊                         ┊  ▓
▓ ▓                         ▓ ▓ Super 5 neuve           ▓ ┊                         ┊  ▓
▓ ▓ Le 12/11/2026 à 21 h 40 ▓ ▓ Le 13/11/2026 à 18 h 05 ▓ ┊                         ┊  ▓
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┘  ▓
▓ (zone de pied : vide, ou confirmation, ou message ; hauteur réservée 150 / 132)      ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

| Élément d'une case pleine | Règle (`Sauvegarde.lister()`) |
|---|---|
| Numéro | carré encre 36 × 36, Atkinson gras 22 crème (c'est aussi la touche) |
| Prénom | `resume.prenom` en capitales, Atkinson gras 24 |
| Date de jeu | `Dates.texte(resume.ab)` (« mars 1986 »), Atkinson gras **30** : c'est l'information principale |
| Patrimoine | `Format.montant(resume.patrimoine, ab)`, Atkinson gras 26, crème, tabulaire ; aucune couleur de jugement |
| Origine | `libelle` non vide : « Avant : » + libellé (Atkinson 20, 2 lignes au plus, « … ») ; vide : « Sauvegarde du menu » (Atkinson 20, secondaire) |
| Écrite le | `ecrite_le` mis en forme « Le 12/11/2026 à 21 h 40 » (Atkinson 20, secondaire), en bas de la case |
| Cadre | secondaire pixel (`bouton_secondaire`) ; focus clavier : cadre ambre 1 t de plus (existant pour le focus) |

| Case vide | Règle |
|---|---|
| Sauver | cadre **pointillé** 1 t `PANNEAU_SURVOL`, numéro, « EMPLACEMENT VIDE » Pixelify 28 secondaire ; **active** (un toucher écrit directement, sans confirmation) |
| Charger | même dessin + **hachures en marches** ; **inactive** (`refus=ignore`) ; libellé « VIDE » |

Interaction commune : touches **1 / 2 / 3** = l'emplacement ; **Échap** = FERMER (ou ANNULER dans une confirmation) ; clic extérieur = FERMER (sauf pendant une confirmation : la fenêtre frémit, existant). Toutes ces touches sont **consommées** (K2). FERMER : secondaire, 81 / 78 px, coin haut droit.

### 2.2 Mode « sauver »

1. **Case vide** : écriture immédiate (`Partie.sauvegarder_dans(nom, libelle)`).
2. **Case pleine** : **confirmation sur place**, dans la zone de pied (pas de seconde fenêtre) : la case choisie reçoit un cadre **ambre 2 t**, les deux autres passent à 40 % et ne réagissent plus.
```
▓ ┌──────────────────────────────────────────────────────────────────────────────────┐ ▓
▓ │ Remplacer l'emplacement 2 (Gérard, septembre 1987, 112 800 F)                     │ ▓  Atkinson gras 24
▓ │ par la partie d'aujourd'hui (Gérard, octobre 1987, 104 300 F) ?                   │ ▓  Atkinson 22
▓ │ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐   ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐           │ ▓
▓ │ ▓ REMPLACER                       ▓   ▓ ANNULER                         ▓           │ ▓  secondaires tous deux,
▓ │ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘   └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘           │ ▓  81 / 78 px, ≥ 360 de large
▓ └──────────────────────────────────────────────────────────────────────────────────┘ ▓
```
   - **ANNULER a le focus** (on ne détruit rien par un Entrée machinal) ; Échap = ANNULER ; aucune touche numérique pour REMPLACER (la touche du même numéro, répétée, ne remplace pas : pas d'écrasement en deux appuis distraits).
3. **Après l'écriture** (`sauvegarde_faite`) :
   - ouvert **depuis le menu** : la fenêtre reste ouverte ; la case réécrite montre les nouvelles valeurs et un tampon « SAUVEGARDÉ » (Pixelify 20, encre sur ambre, coin haut droit de la case) ; la zone de pied affiche « Partie sauvegardée dans l'emplacement 2. » (Atkinson 22) ; FERMER ramène au jeu, en pause (CA-SI1 : « Sauvegardé » et `lister()` à jour) ;
   - ouvert **depuis un bandeau ou la feuille d'ordre** : la fenêtre **se ferme aussitôt** ; la confirmation est l'état « Sauvegardé » du bandeau (§3.3) ou du bouton (§4).
4. **Échec** (`sauvegarder_dans` faux) : zone de pied « La sauvegarde n'a pas pu être écrite. Votre partie continue normalement. » (Atkinson 22, **alerte ambre** + sprite ⚠ 16 × 16 ×3) ; rien d'autre ne change.

### 2.3 Mode « charger »

En-tête : « CHARGER UNE PARTIE » + **deux phrases toujours visibles** sous le titre (Atkinson 22) :
- « Le hasard ne change pas : seuls vos choix peuvent changer. »
- « Une partie chargée depuis un emplacement ne compte plus pour le record. » (secondaire, sprite ↻ devant) — décision du joueur, à dire **avant** de charger et non découverte à la fin.

1. **Aucune partie en cours** (écran titre sans CONTINUER) : toucher une case pleine **charge directement**.
2. **Partie en cours** (en jeu, ou écran titre avec CONTINUER) : confirmation sur place, même mécanique que l'écrasement :
```
▓ │ Charger l'emplacement 1 (Gérard, mars 1986, 69 395 F) ?                            │  Atkinson gras 24
▓ │ La partie en cours (octobre 1987) sera remplacée ; sauvegardez-la d'abord si vous  │  Atkinson 22
▓ │ voulez la garder.                                                                  │
▓ │ ▓ CHARGER        ▓   ▓ SAUVEGARDER D'ABORD ▓   ▓ ANNULER        ▓                   │  3 secondaires de même taille
```
   - **ANNULER a le focus** ; Échap = ANNULER.
   - SAUVEGARDER D'ABORD bascule la même fenêtre en mode « sauver » (titre, phrases et cases changent sur place) ; après l'écriture, elle revient en mode « charger » avec la même confirmation affichée (le joueur n'a pas à refaire son choix).
   - Sur l'écran titre, SAUVEGARDER D'ABORD est absent (la partie en cours y est la sauvegarde automatique : la sauvegarder demanderait de la charger) ; la phrase devient « La partie en cours (Gérard, octobre 1987) sera remplacée. ».
3. **Après le chargement** : la fenêtre se ferme ; le jeu affiche la partie chargée **en pause**, modale en attente rouverte (mécanisme existant, CA-SI3) ; une notification ordinaire (source maison) « Partie chargée : mars 1986 » ; aucune animation.
4. **Emplacement devenu illisible** entre la liste et le chargement (`charger_emplacement` faux) : zone de pied « Cette sauvegarde ne peut plus être lue. » (alerte ambre) ; la case passe à VIDE.

### 2.4 Budgets

| Format | Calcul | Total |
|---|---|---|
| PC | 30 + titre 48 + libellé 30 + aide 26 + 12 + cases 282 + 18 + pied 150 + 30 | **≈ 626** / 1080 |
| Téléphone, sauver | 18 + titre et FERMER sur une rangée 78 + libellé 28 + 9 + cases 246 + 9 + pied 132 (2 lignes de 26 + boutons 78) + 18 | **≈ 538** / 648 |
| Téléphone, charger en cours de partie | 18 + 78 + 2 phrases 56 + 9 + 246 + 9 + pied 3 lignes de 26 + 78 + 18 | **≈ 592** / 648 |

Au téléphone, la phrase d'aide « Choisissez un emplacement. » est remplacée par le libellé quand il existe (elle redit l'évidence) ; aucune information de case n'est retirée.

---

## 3. Le bandeau « Sauvegarder avant de choisir » (SV-I tâche 4)

### 3.1 Principe

Une **étiquette-bouton** accrochée au **coin haut droit** de la carte, sur la hauteur de l'en-tête (« MA MAISON · MARS 1984 ») et de la 1re ligne du titre. Elle ne recouvre jamais un bouton de choix, ne déplace pas les boutons et n'en a pas l'apparence : petite, sans numéro, sur le bord haut.

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┬▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▌ MA MAISON · AVRIL 1988                                     ▓ [disq.] Sauvegarder     ▓  ← étiquette 414 × 81 (PC)
▌ ┌────────┐  L'HÉRITAGE DE LA TANTE ODETTE                   ▓  avant de choisir · S   ▓
▌ │ Sylvie │                                                 └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
▌ │  ×3    │  (texte de la carte : sa largeur s'arrête à gauche de l'étiquette sur les 2 premières lignes)
▌ └────────┘
▌ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▌ ▓ 1  …                            ▓ ▓ 2  …                            ▓       ← choix inchangés
▌ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

| Élément | Règle |
|---|---|
| Taille | PC **414 × 81** (138 × 27 t) ; téléphone **396 × 78** (132 × 26 t) |
| Style | `bouton_papier` (même papier que la carte, contour encre) ; **pas** d'ambre, **pas** de numéro : il ne doit ni ressembler à un choix ni pousser au clic (principe 11) |
| Contenu | icône disquette 16 × 16 ×3 (facultative ; sans elle, le texte seul) ; « Sauvegarder avant de choisir » Atkinson gras 22, encre, 2 lignes au plus ; PC : « · S » en Atkinson 20 secondaire (rappel de la touche ; absent au téléphone, où il n'y a pas de clavier : ce n'est pas une information cachée) |
| Place | ancrée en haut à droite **à l'intérieur** de la carte, marges de la carte (24 / 18) ; l'en-tête et le titre réduisent leur largeur de celle de l'étiquette + 18 sur leurs lignes ; le portrait ne bouge pas |
| Hauteur ajoutée | **0** quand l'en-tête + la 1re ligne du titre font ≥ 81 / 78 (cas habituel : 27 + 48) ; sinon la rangée de l'en-tête grandit jusqu'à 81 / 78 et le nœud `Defilant` de la carte absorbe |

### 3.2 Comportement

- Affiché si `Options.proposer_sauvegarde()` **et** `Partie.proposition_sauvegarde() != ""` à l'ouverture de la carte ; `Partie.marquer_proposition()` appelé **à l'affichage**.
- **Toucher ou `S`** → écran des emplacements en mode « sauver », libellé = `proposition_sauvegarde()`, **au-dessus** de la carte (K1) ; la carte reste visible, assombrie par le fond de l'écran des emplacements.
- **Choisir directement** un bouton de la carte (toucher ou 1 / 2 / 3 / 4) fonctionne en **un toucher** comme aujourd'hui ; le bandeau disparaît avec l'état de conclusion (bouton CHOISI, conséquence).
- Touches de la carte : **inchangées** (1-4, Entrée, et Échap selon la carte). `S` n'est lu que si le bandeau est actif. Pendant l'écran des emplacements, ses touches sont consommées (K2).
- Absent : option à « non » ; présentations du banquier, événements sans choix, notifications ; **relectures dans l'historique** (lecture seule).
- Carte rouverte à la reprise (CONTINUER ou chargement) : l'état « Sauvegardé » n'est pas mémorisé ; le bandeau réapparaît, actif, seulement si `proposition_sauvegarde()` le permet encore (règle de la logique, espacement compris).

### 3.3 État « Sauvegardé »

```
▓ ✓ Sauvegardé         ▓      ← même place, même taille
▓   emplacement 2      ▓
```
- Sprite ✓ 16 × 16 ×3 + « Sauvegardé » Atkinson gras 22 encre + « emplacement 2 » Atkinson 20 secondaire ; cadre **encre 1 t sans relief** (ce n'est plus un bouton) ; `MOUSE_FILTER_IGNORE` ; `S` ne fait plus rien.
- Aucune animation : le changement d'état se fait sur place quand l'écran des emplacements se ferme.
- Fermeture de l'écran des emplacements **sans** écrire (FERMER, Échap) : le bandeau reste actif, inchangé.

### 3.4 Place dans chaque carte de la liste « toujours » et « avec seuil »

| Carte | Où exactement | Point d'attention téléphone |
|---|---|---|
| **Krach** (journal, modale `marche`) | à droite de la **manchette** du journal (ligne du nom du journal et de la date), à l'intérieur de la page | Budget de docs/24 §2.4 (tableau des 7 jours + 3 choix sans défiler) : la manchette fait ≥ 78 px ; sinon le chapô (`Defilant`) absorbe. Contrôle `UI krach_bandeau choix_visibles=oui` |
| **Héritage D08** (courrier) | coin haut droit de la feuille, à hauteur de l'en-tête | — |
| **Carte de dilemme** (≥ 1 salaire, C06) | coin haut droit (maquette ci-dessus) | le texte de la carte (≤ 30 mots) s'arrête à gauche de l'étiquette sur 2 lignes : vérifier `debordements=0` sur C06 |
| **Projet, étape `choix`** | coin haut droit (docs/24 §1.1) | téléphone : l'étiquette se place à droite du titre « UN PROJET POUR 1986 », pas de hauteur ajoutée |
| **Projet, jour J** (y compris l'écran de confirmation des ventes) | coin haut droit ; il **reste** dans l'écran CONFIRMER LES VENTES (l'en-tête ne change pas) | budget de docs/24 §1.2 : 576 px, + 0 si l'étiquette tient sur la ligne du titre |

### 3.5 Repli technique si la superposition (K1) est refusée

Fermer la carte **sans choix** (nouveau genre de fermeture, sans `choix_fait`), ouvrir l'écran des emplacements, puis **rouvrir la carte en attente** par le mécanisme de reprise, avec l'état « Sauvegardé » transmis. Inconvénient : la carte disparaît une fraction de seconde. À n'utiliser que si la couche au-dessus est impossible.

---

## 4. « Sauvegarder d'abord » dans la feuille d'ordre (SV-I tâche 5)

Sur la **rangée du bouton de validation** (« ACHETER POUR 20 000 F »), à sa gauche : aucune hauteur ajoutée (K4).

**PC** (zone droite de la fenêtre Banque)
```
▓ (montant, curseur, parts rapides, récapitulatif, bande des frais : inchangés)              ▓
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ╔══════════════════════════════════════════════════════════╗ ▓
▓ ▓ [disq.] SAUVEGARDER   ▓ ║ ACHETER POUR 20 000 F                                    ║ ▓
▓ ▓ D'ABORD · S           ▓ ║                                                          ║ ▓
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ ╚══════════════════════════════════════════════════════════╝ ▓
```
**Téléphone** : même rangée, 72 px de haut (hauteur actuelle du bouton de validation) ; « SAUVEGARDER D'ABORD » sur 2 lignes, largeur 288 (96 t) ; le bouton de validation garde le reste.

| Élément | Règle |
|---|---|
| Largeur | PC 1/3 de la rangée (≥ 300), écart 12 ; téléphone 288 |
| Style | **secondaire** (le bouton de validation reste le seul principal ambre) ; libellé Pixelify 22 capitales sur 2 lignes (aucun chiffre), « · S » Atkinson 20 secondaire sur PC |
| Apparition | quand `Options.proposer_sauvegarde()` et `Partie.ordre_important(genre, montant)` sont vrais au montant courant |
| **Pas de saut de mise en page** | une fois apparu dans cette feuille, il **reste** même si le curseur redescend sous le seuil (sinon le bouton de validation change de largeur sous le doigt) ; il disparaît au changement de produit ou de mode. Écart à CA-SI5 à valider : « sous le seuil : absent » s'entend « tant que le seuil n'a pas été atteint dans cette feuille » |
| Action | ouvre l'écran des emplacements (sauver), libellé « Avant : achat de 20 000 F de SICAV Avenir » (genre + montant + produit, construit par l'interface ou fourni par la logique : à figer au lancement) ; montant, curseur et mode **conservés** au retour |
| État « Sauvegardé » | même place : ✓ + « Sauvegardé » (Atkinson gras 22) + « emplacement 2 » (20), cadre encre sans relief, inactif |
| Genres concernés | achat, vente, rachat d'assurance-vie, clôture du PEL, retrait du Livret A (`lot_sauvegarde.md` §4.2) ; pour la clôture du PEL (pas de curseur), il est présent dès l'ouverture de la feuille si le seuil est atteint |

---

## 5. Le bouton CHARGER de l'écran titre (SV-I tâche 3)

Dans la rangée des boutons existante (96 px de haut), **entre** l'action principale et NOUVELLE PARTIE : les deux façons de reprendre sont côte à côte, l'action qui efface est au bout.

```
 Sans emplacement plein (inchangé)     ╔══════════════════╗
                                       ║      JOUER       ║
                                       ╚══════════════════╝

 Emplacement plein, pas de partie      ╔══════════════════╗ ┌▓▓▓▓▓▓▓▓▓▓▓▓┐
 en cours                              ║      JOUER       ║ ▓  CHARGER   ▓
                                       ╚══════════════════╝ └▓▓▓▓▓▓▓▓▓▓▓▓┘

 Partie en cours + emplacement plein   ╔══════════════════╗ ┌▓▓▓▓▓▓▓▓▓▓▓▓┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
                                       ║    CONTINUER     ║ ▓  CHARGER   ▓ ▓  NOUVELLE PARTIE  ▓
                                       ╚══════════════════╝ └▓▓▓▓▓▓▓▓▓▓▓▓┘ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
               Partie en cours : Gérard · mai 1987 · patrimoine 98 200 F
 (puis la rangée du palmarès de docs/29 §2, si le lot 07 est fusionné)
```

| Élément | Règle |
|---|---|
| CHARGER | secondaire, **260 × 96**, Pixelify 28 (comme NOUVELLE PARTIE) ; touche **C** sur PC (facultatif) |
| Largeur totale | 380 + 24 + 260 + 24 + 340 = **1028 px** : tient en 1440 (téléphone) et 1920 |
| Action | écran des emplacements en mode « charger » (§2.3) : cases vides inactives ; confirmation si une partie en cours existe (« La partie en cours (Gérard, mai 1987) sera remplacée. ») ; puis le jeu s'ouvre en pause sur la partie chargée |
| NOUVELLE PARTIE | sa confirmation existante gagne une phrase : « Vos sauvegardes (emplacements 1 à 3) sont gardées. » (CA-SI2 : aucun emplacement effacé) |
| Partie en cours **sans** emplacement plein | inchangé : CONTINUER + NOUVELLE PARTIE |

---

## 6. Ligne « hors record » à la fin

Définie dans **docs/29 §1.4** (pastille pointillée, sprite ↻, ni rouge ni ambre). SV-I ne fait que l'afficher si 07-I n'est pas encore fusionné (`lot_sauvegarde.md` §5.2) : dans ce cas, sous la pastille « VOUS : … que Tata Livret », même style.

---

## 7. Contrôles proposés pour les captures (`lot_sauvegarde.md` §5.2 tâche 7)

- `menu_sauver` : `UI menu entrees=6 bascule=<oui|non> cibles sous_seuil=0`.
- `emplacements_sauver` (1 plein, 1 plein avec libellé, 1 vide ; puis confirmation d'écrasement) et `emplacements_charger` (confirmation en cours de partie) : `UI emplacements mode=<sauver|charger> pleins=<n> confirmation=<aucune|ecraser|charger> focus=annuler phrase_hasard=<oui|non>`.
- `krach_bandeau`, plus D08, C06, projet jour J : `UI bandeau etat=<actif|sauve> chevauche_choix=non choix_visibles=oui`.
- `ordre_important` : `UI ordre sauver_dabord=<oui|non> hauteur_feuille=<px>` (même hauteur avec et sans le bouton).
- `titre_charger` : `UI titre boutons=<JOUER|JOUER,CHARGER|CONTINUER,CHARGER,NOUVELLE>`.
- `fin_rejouee` : voir docs/29 §1.6.
- Test de clavier (K2) : depuis le krach, `S`, `2`, Échap → emplacement 2 écrit, journal toujours ouvert, aucun `choix_fait`.

## 8. Écarts et points à trancher au lancement

| # | Sujet | Proposition | Pour qui |
|---|---|---|---|
| 1 | Écran des emplacements au-dessus d'une carte | Couche à part, hors `Modales.courant` (K1) ; repli §3.5 | Chef de projet, dev-interface |
| 2 | « Sauvegarder d'abord » qui reste une fois apparu (§4) | Écart à CA-SI5 | Chef de projet, testeur |
| 3 | Phrase « ne compte plus pour le record » dans le mode charger | Ajout (pas dans le design validé) : le joueur doit le savoir avant | Client |
| 4 | Libellé d'un ordre (« Avant : achat de 20 000 F de SICAV Avenir ») | Construit par la logique (cohérent avec les autres libellés) | dev-logique |
| 5 | Fenêtre d'écrasement : aucune touche pour REMPLACER, focus sur ANNULER | Sécurité contre l'écrasement par réflexe | Chef de projet |
| 6 | Touches C (charger) et T (titres) sur l'écran titre | Facultatives | Chef de projet |

## 9. Où une illustration aiderait le plus
1. **Une icône disquette 16 × 16** (menu, bandeau, feuille d'ordre) : un seul sprite, reconnu partout ; à défaut, le texte suffit.
2. **Une vignette 32 × 18 de la rue au mois sauvegardé** dans chaque case (saison, nuit, maison avec ses objets P10) : rendrait les emplacements reconnaissables d'un coup d'œil. Coût : une capture réduite du `SubViewport` à l'écriture ; à ne faire qu'après la 1.0.
