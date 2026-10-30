# Feuille de route technique : pixel art (PX1, PX2) puis game design V3 (lots 02 à 07)

> Chef de projet, mise à jour du 2026-10-30. Remplace la version du 29/10.
> Entrées : décisions du joueur (docs/10 : P1-P6, P9, P10 retenues ; style PX0 quater validé, rue large avec défilement, personnages 36 × 63 sur la grille 960 × 540, interface PX0 conservée, « tout continuer ») ; spec `docs/15_spec_game_design_v3.md` ; bible graphique `docs/16` (§9 = révision du 30/10) ; plans `lot_px1.md`, `lot_px2.md`.
> Ordre : **PX1 et PX2** (la rue et l'interface en pixel) **en même temps que** la logique du lot 02, puis les lots 02 à 07 dans l'ordre du client : **P4** (02), **P2** (03), **P1** (04), **P3 + P9** (05), **P6** (06), **P5** (07). P10 n'est pas un lot : ses traces arrivent avec P2 et P1.

## 1. Principe : trois développeurs, trois branches par vague, la logique une vague en avance

Chaque vague lance **trois branches en parallèle**, une par développeur, sur des fichiers disjoints (§3). dev-logique travaille **une vague en avance** : la logique d'un lot est fusionnée (sans effet visible, interfaces figées) avant que l'interface et la rue de ce lot commencent. Ainsi aucune branche d'affichage n'attend une API qui n'est pas encore sur `main`.

| Vague | dev-logique | dev-interface | dev-ville | Point de fusion | Sortie joueur |
|---|---|---|---|---|---|
| **1** | **02-L** : moteur de P4, cadence V3, sauvegarde format 3 (§2) | **PX2** : toute l'interface en pixel (`lot_px2.md`), dont T16 et T9 | **PX1** : la rue en pixel (`lot_px1.md`) | **F1** | **0.3 « tout en pixel »** (exe + APK + liste de contrôle du téléphone, T2). Aucune règle nouvelle visible, sauf la cadence V3 ; nouvelle partie obligatoire (format 3) |
| **2** | **03-L** : P2 (humeur, créneaux, 16 cartes, escargots, C00, coût d'opportunité, R-MIROIR des cartes) ; découpage d'`etat_partie.gd` (`foyer.gd`) | **02-I** : bouton « Jusqu'au prochain courrier » (touche N), badge des non-lus sur HISTORIQUE, notifications empilées (3 au plus), `marquer_lues`, ville animée pendant le saut, retrait du ciel vectoriel de `principal.gd`, T13, T18 (`capture.ps1 -Joueur`, étape `raccourcis`), T17 (`capture.sav` unique par processus) | **02-V** : pièces du mois dans la rue (or banque → maison, cuivre maison → banque, nom de la ligne pour un dividende, « + 312 F » par `Juice.flottant`), pas de pièces à ×3 ni pendant le saut ; **nettoyage de la vitrine PX0** ; B2 | **F2** | **0.4 « le mois utile »** (P4) |
| **3** | **04-L** : P1 (projets, jauge, échéance, report, vente automatique, rappel dans les fiches) | **03-I** : carte de dilemme (sort de la maison, 2 boutons montant + humeur, ligne de conséquence 3 s), composant **Bulle** (Sylvie, réutilisé au lot 05), « Mon foyer » (humeur), historique genre `carte` | **03-V** : Sylvie câblée sur l'humeur, objets des cartes (lueur de télé, antenne, poussette, chien, escargot, diplôme) | F3 | (avec F4) |
| **4** | **05-L** : P3 + P9 (Jean-Mi sur le vrai cours de Peugeot, levier, classement, calendrier des passages et bulles réactives, kiosque) | **04-I** : carte de choix de projet, jauge sur la maison, « Projet : … dans N mois » dans la fenêtre Banque, carte « le jour J » | **04-V** : réalisations animées (la Super 5 se gare, break, carte postale, chaîne hi-fi), traces P10 des projets | **F4** | **0.5 « le foyer »** (P2 + P1) |
| **5** | **06-L** : P6 (cours quotidiens 16 → 26/10/1987, instantané, « un an après » au franc près) | **05-I** : bloc « La rue » dans « Mon argent » (4 lignes), bulles des voisins, carte de lecture « La rue » et levier, source `rue` de l'historique | **05-V** : passages des voisins (`faire_passer`), Porsche puis « À VENDRE », Jean-Mi à vélo, kiosque défilant, enfants qui grandissent | F5 | **0.6 « la rue »** |
| **6** | **07-L** : P5 (rang, titre, record dans `user://records.sav`), mesure de la durée (≤ 20 min avec le bouton) | **06-I** : carte « Le krach, un an après » (3 barres) | **06-V** : séquence du Lundi noir (≤ 15 s, sans compte à rebours) | F6 | **0.7 « le krach »** |
| **7** | équilibrage, export 1.0 | **07-I** : écran de fin (4 barres, titre, projets, visage de Sylvie), meilleur résultat sur l'écran titre | **07-V** : finitions de la rue | F7 | **1.0 de la démo V3** |

Chaque case est une branche `lot/NN-<dev>` (`lot/px1-ville`, `lot/px2-interface`, `lot/02-logique`, puis `lot/02-interface`, `lot/02-ville`, `lot/03-logique`…), un worktree `C:\Users\arthu\Documents\temp\JeuClaude_lots\<lot>-<dev>`, un passage du testeur (`docs/lots/lot_NN_recette.md`). Les plans des vagues 2 et suivantes (`lot_02.md` pour 02-I et 02-V, `lot_03.md`…) seront écrits par le chef de projet pendant la vague précédente, avec la spec, le contenu des experts et les maquettes UX disponibles.

## 2. Lot 02-L : plan de lancement de dev-logique (vague 1)

> Fait office de plan de lot pour la branche `lot/02-logique` (les parties 02-I et 02-V auront leur plan, `lot_02.md`, en vague 2). Référence : docs/15 §1, §0.1, §8, §11 étape 1.

- Objectif : tout ce qui, dans P4 et le socle V3, ne se voit pas encore : flux du mois, moteur du saut « jusqu'au prochain courrier », non-lus, cadence V3, R-MIROIR des témoins existants, sauvegarde format 3 avec migration douce, préparation de l'export 0.3.
- Mode : parallèle de PX1 et PX2, **aucun fichier commun**. Base : `main` actuel (ne dépend pas de PX0 : lançable **dès maintenant**).
- Mise en place : `& $git -C $depot worktree add -b lot/02-logique C:\Users\arthu\Documents\temp\JeuClaude_lots\lot02-logique main`.

### 2.1 Fichiers attribués (tout autre fichier est interdit)
`scripts/logique/*.gd` (dont nouveau `cadence.gd`) ; `scripts/partie.gd` ; `data/*.json` (dont `rythme.json > saut`, paramètres de cadence) ; `tests/test_logique.*`, `tests/test_demo.*`, `tests/autocontrole/`, nouveaux `tests/test_mois_utile.*`, `tests/test_cadence.*`, `tests/test_sauvegarde.*` (scènes `.tscn` permises s'il faut l'autoload `Partie`) ; `outils/tests.ps1`, `outils/trouver_godot.ps1` ; `export_presets.cfg`, `Exporter_*.bat`, `Jouer_Godot.bat` ; `docs/connaissances/developpeur.md` (socle : dev-logique pour la vague 1) et `docs/connaissances/dev-logique.md`. **Interdits** : `project.godot`, `scripts/ui/*`, `scripts/ville/*`, `scripts/pixel/**`, `principal.gd`, `ecran.gd`, `juice.gd`, `scripts/outils/**`, `tests/test_interface.*`, `tests/test_partie.*`, `tests/test_pixel.gd`, `tests/test_rue.gd`, `tests/recette/`, `outils/capture*.ps1`.

### 2.2 Interfaces (figées ; **ajouts seulement**, rien de ce que l'interface lit n'est retiré ni renommé : base du chef de projet §2)
```gdscript
# Partie (autoload)
signal saut_change(actif: bool)
var saut_actif: bool                                   # pendant le saut, Partie.vitesse garde la vitesse d'avant l'appui (0 à 3)
func sauter_jusqu_au_prochain_arret() -> bool          # faux si impossible (partie finie, décembre 1988, modale en attente)
func arreter_saut() -> void                            # un nouvel appui pendant le saut l'arrête
func saut_possible() -> bool
# pendant le saut : duree_mois_s() = rythme.json > saut.duree_mois_s (1,33) ; facteur_trafic(v) = saut.trafic (7) quel que soit v
# le saut s'arrête AU mois de la modale : saut_actif est faux quand modale_ouverte est émis ; ensuite la vitesse est celle d'avant l'appui
# mois_passe(res) : res["flux"] = {"revenus": float, "frais": float, "lignes": [{"id": String, "nom": String,
#     "genre": "interets"|"coupon"|"dividende"|"frais"|"frais_versement", "montant": float, "verse_en_decembre": bool}]}
# notif_recue(n) : n["pendant_saut"] = bool
# EtatPartie
func flux_du_mois() -> Dictionary                      # même contenu que res["flux"] du dernier mois
func non_lues(source := "") -> int                     # entrées d'historique créées pendant un saut et pas encore vues
func marquer_lues(source := "") -> void
const GENRES_HISTORIQUE := [...]                       # + "carte", "projet", "voisin", "gazette" (aucune entrée avant les lots 03-05)
const SOURCES_HISTORIQUE := [...]                      # + "rue"
```
- `Cadence` (`class_name`, `scripts/logique/cadence.gd`) : R-CADENCE (jamais deux interruptions avec pause le même mois ni deux mois de suite, sauf krach → panne), priorités et glissement (docs/15 §0.1), **anticipation sans fuite**, budgets par catégorie (classiques ≤ 15 ; cartes, projets, Gazette : compteurs prêts, vides). Dates imposées inchangées : PEL présenté au plus tard en 07/1984, naissance 04/1985, krach 10/1987 puis panne 11/1987, héritage 04/1988.
- **Sauvegarde format 3** : `Sauvegarde.VERSION = 3` ; un fichier de format 2 est ignoré proprement (`lire()` renvoie `{}`, aucune erreur ; l'écran titre ne propose plus « Continuer ») ; **migration douce** à partir du format 3 : tout champ absent prend sa valeur par défaut (table unique dans `EtatPartie`), pour qu'aucun lot suivant ne casse plus les parties du joueur. `saut_actif` n'est pas sauvegardé (une reprise repart sans saut).

### 2.3 Tâches
1. Flux du mois. 2. Saut et non-lus (`rythme.json > saut`). 3. `Cadence` extraite d'`etat_partie.gd` + R-CADENCE, anticipation, budgets ; R-MIROIR vérifié pour Tata Livret et Tonton Matelas. 4. Format 3 + migration douce (T14). 5. `tests.ps1` : lignes moteur `ERROR:` dans le motif d'erreurs (T17), option `-Joueur` qui passe `--joueur` aux tests de recette (T18). 6. Export : `include_filter` étendu à `data/pixel/*/*.txt`, version 0.3 (Windows 0.3.0.0, Android 0.3 / code 3) ; `project.godot > config/version` est écrit par dev-interface dans PX2 (même valeur). 7. Socle `developpeur.md`, base, compte rendu.

### 2.4 Critères d'acceptation (testeur, `docs/lots/lot_02_logique_recette.md`)
- **CA-L1** : `tests.ps1` vert, aucune erreur de script, total ≥ 202 + nouvelles vérifications ; `test_interface` et `test_partie` **inchangés** et verts.
- **CA-L2 (flux, docs/15 CA-4.3)** : sur 60 mois et 3 graines, `revenus` et `frais` égaux au franc près aux mouvements du moteur (intérêts, coupons, dividendes ; frais de gestion et de versement) ; variations de cours exclues.
- **CA-L3 (saut, CA-4.1, 4.2, 4.4)** : 40 graines, appui après chaque interruption : chaque arrêt au mois exact d'une modale, aucun arrêt sans modale, aucun mois sauté sans salaire, versements et historique ; vitesse d'avant rétablie (×1 → saut → modale → ×1 ; pause → saut → modale → pause) ; notifications franchies toutes dans l'historique, dans l'ordre, `lu = false`, `non_lues()` exact, `marquer_lues()` → 0 ; `saut_possible()` faux en 12/1988 et partie finie ; un 2e appel `arreter_saut()` sans effet.
- **CA-L4 (cadence)** : 40 graines × 2 stratégies (`StrategieTest` actif et passif) : aucune paire d'interruptions avec pause le même mois ou deux mois de suite hors krach → panne ; dates imposées respectées ; classiques ≤ 15 ; aucune interruption flexible au mois qui précède une interruption datée ; le nombre total d'interruptions et la liste par graine imprimés (comparés par le testeur à `main`).
- **CA-L5 (sauvegarde)** : un fichier de format 2 (fabriqué par le test) est ignoré sans erreur ; pour chaque champ de l'état sauvegardé, le retirer puis recharger donne la valeur par défaut et la partie va jusqu'à la fin ; sauvegarde pendant un saut → reprise sans saut, même mois ; fichiers de test uniques par processus, `partie_en_cours.sav` jamais touché (empreinte contrôlée par `tests.ps1`).
- **CA-L6 (contrat de l'interface)** : `git diff main...lot/02-logique -- godot/scripts/partie.gd godot/scripts/logique/` ne retire ni ne renomme aucun signal, fonction ou champ listé dans la base du chef de projet §2 (contrôle du testeur par recherche des lignes `-func`, `-signal`, `-var`).
- **CA-L7 (outils)** : `tests.ps1 -Autocontrole` détecte une ligne `ERROR:` injectée ; `tests.ps1 -Recette -Joueur` lance `test_recette_decoupage` avec `--joueur`.
- **CA-L8 (export)** : `Exporter_Windows.bat` depuis le worktree (avec `JEUCLAUDE_GODOT`) : code 0, exe `--etape=titre` capturé ; `export_presets.cfg` contient le nouveau filtre et la version 0.3.

## 3. Carte de propriété des fichiers en vague 1 (PX1 ∥ PX2 ∥ 02-L)

Chemins relatifs à `godot/`. Un fichier = un propriétaire pendant toute la vague ; un fichier absent = interdit à tous.

| Fichiers | dev-ville (PX1) | dev-interface (PX2) | dev-logique (02-L) |
|---|---|---|---|
| `scripts/ville/*`, `scripts/pixel/*.gd` (hors `ui/`), `data/pixel/ville/`, `data/pixel/LISEZMOI.md`, `scripts/juice.gd` (secousse seulement), `shaders/ciel.gdshader`, `scripts/outils/scenarios/ville.gd`, `tests/test_pixel.gd`, `tests/test_rue.gd`, `outils/capture_ville.ps1`, `outils/capture_px0.ps1`, `scenes/px0.tscn`, `Voir_PX0.bat` | **oui** | — | — |
| `scripts/ui/*`, `scripts/principal.gd`, `scripts/ecran.gd`, `scenes/principal.tscn`, `project.godot`, `scripts/pixel/ui/*`, `data/pixel/ui/*`, `polices/**/*.import`, `shaders/papier.gdshader`, `assets/icone/`, `scripts/outils/*.gd`, familles `titre`, `banque`, `ecrans`, `outils`, `interface`, `outils/capture.ps1`, `outils/capture_interface.ps1`, `tests/test_interface.*`, `tests/test_partie.*`, `tests/test_ecran.gd` | — | **oui** | — |
| `scripts/logique/*`, `scripts/partie.gd`, `data/*.json`, `tests/test_logique.*`, `tests/test_demo.*`, `tests/autocontrole/`, nouveaux `tests/test_{mois_utile,cadence,sauvegarde}.*`, `outils/tests.ps1`, `outils/trouver_godot.ps1`, `export_presets.cfg`, `Exporter_*.bat`, `Jouer_Godot.bat` | — | — | **oui** |
| `tests/recette/` | testeur | | |
| `docs/connaissances/` | `dev-ville.md` | `dev-interface.md` (+ suppression de `dev-interface_px0.md`) | `developpeur.md`, `dev-logique.md` |

Vérification faite pour ce plan : aucun fichier n'apparaît deux fois ; les trois branches peuvent partir de `main` le même jour (PX1 et PX2 après la fusion de PX0, 02-L tout de suite).

**Règles pour les vagues suivantes** (à reprendre dans chaque `lot_NN.md`) : `principal.gd`, `scripts/ui/*`, `project.godot` → toujours dev-interface ; `sequences.gd`, `ville/*`, `juice.gd` → toujours dev-ville ; `partie.gd`, `logique/*`, `data/*.json` → toujours dev-logique. Une nouvelle sorte de modale (carte, projet, « un an après ») : dev-interface crée `Modales.<sorte>(c, depart)`, dev-ville l'appelle depuis `Sequences.jouer_modale` par `has_method`, avec repli sur `courrier` ; c'est vérifié à la fusion simulée. Une bulle : composant d'interface (dev-interface) placé par `ville.point_tete(n)` (dev-ville).

## 4. Interfaces à figer (résumé ; le détail est dans chaque plan)

| Interface | Producteur → consommateurs | Où |
|---|---|---|
| API de la ville (conservée + `point_etiquette`, `est_visible`, `aller_vers`, `bornes_rue`, `camera_bougee`, `regler_humeur_sylvie`, `faire_passer`, `point_tete`, `PERSONNAGES`) | dev-ville → `principal.gd`, `hud.gd`, lots 03 et 05 | `lot_px1.md` §2.1-2.2 |
| API de l'interface appelée par `Sequences` et `Juice` (`Hud`, façade `Modales` après T9, `Style` complet, `Piece.voler`) | dev-interface → dev-ville | `lot_px2.md` §2.2 |
| Échelle (`Ecran.facteur_texel`, `dp`, `cible_min`, téléphone simulé 1600 × 720 à 267 dpi) | dev-interface → tous les écrans futurs | `lot_px2.md` §2.3 |
| Flux du mois, saut, non-lus, genres et sources d'historique, `Cadence`, format 3 | dev-logique → 02-I, 02-V, puis tous | §2.2 ci-dessus |
| Lots 03 à 07 : `foyer.json`, humeur (`EtatPartie.humeur_visible() -> int` 0/1/2), cartes, projets, voisins, instantané du krach, titre | dev-logique → interface et rue de la vague suivante | figées dans `lot_NN.md` **avant** la vague où la logique est écrite |

## 5. Points de fusion

- **F0 (en cours)** : recette PX0 (`lot_px0_recette.md`, testeur) → ma validation → fusion `lot/px0-ville` puis `lot/px0-interface` dans `main` (`--no-ff`), `tests.ps1` (202 + `test_pixel`) et `capture_px0.ps1 -Serie` sur `main`. **PX1 et PX2 partent de ce `main`.**
- **F1** : les trois branches de la vague 1 fusionnent **dans l'ordre de leur OK**. La recette de la dernière simule la fusion des trois (copie isolée, `user://` à part : `tests.ps1`, `capture_ville.ps1 -Serie`, `capture_interface.ps1 -Serie`, captures relues ensemble). Après la 3e fusion : tests et séries sur `main`, export 0.3 (exe, APK), liste de contrôle du téléphone (T2), envoi au joueur.
- **F2 à F7** : même règle à chaque vague. Une régression d'intégration → branche `lot/NN-<dev>-correctif`, jamais de correction directe sur `main`.
- La vague N+1 démarre pour un développeur dès que **sa** branche de la vague N est fusionnée, et que les branches dont il dépend (la logique de son lot) sont sur `main`. La logique de la vague N+1 ne dépend que de `main` : dev-logique enchaîne sans attendre.

## 6. Premier lot de chaque développeur

| Développeur | Lot | Lançable |
|---|---|---|
| dev-logique | **02-L** (§2 de ce document) | **Tout de suite**, depuis `main` actuel (aucun fichier commun avec PX0 ni avec PX1 / PX2) |
| dev-ville | **PX1** (`lot_px1.md`) | Dès l'OK du testeur sur PX0, ma validation et la fusion F0 |
| dev-interface | **PX2** (`lot_px2.md`) | Idem ; commence par T16 et T9 (sans changement visuel) |

## 7. Contenu à demander maintenant (coordinateur), pour ne pas bloquer les vagues 2 à 5

| Pour | Qui | Quoi | Utile au plus tard |
|---|---|---|---|
| 02-I, 02-V | UX | place et libellé court du bouton « Jusqu'au prochain courrier » (la barre haute est pleine), badge des non-lus, trajet des pièces dans une rue plus large que l'écran | début de la vague 2 |
| 03-L, 04-L | banquier | prix d'époque des 16 cartes et des 6 options de projet, certitude A/B/C (docs/15 §10.1) | vague 2 (03-L tourne avec les valeurs provisoires, remplaçables sans code) |
| 03-I, 04-I | UX | carte de dilemme, visages de Sylvie (sur la base de PX1), jauge de projet, « Mon foyer » | début de la vague 3 |
| 05-L | boursier + banquier | ancrages mensuels de Peugeot 1986-1988, plan de Jean-Mi (règlement mensuel, J1/J2), crédit de la Porsche ; titres datés du kiosque | début de la vague 4 |
| 06-L, 06-V | boursier ; UX | clôtures quotidiennes du 16 au 26/10/1987 ; storyboard du Lundi noir | début de la vague 5 |
| 07-L | client, game designer | textes des titres et « pourquoi » | début de la vague 6 |

Les silhouettes des voisins sont proposées par dev-ville en PX1 (planche) et jugées par le joueur, au lieu d'attendre l'UX.

## 8. Reports du backlog (affectés)

T16, T9, T15, B1, B3 → PX2 ; T14, T17 (`tests.ps1`), T18 (`tests.ps1`) → 02-L ; T13, T17 (`capture.sav`), T18 (`capture.ps1`) → 02-I ; B2 → PX1 ou 02-V ; T2 (liste de contrôle du téléphone) → F1 ; T5, T6 (sons), T7 → à re-prioriser après F2 ; T10, T11, T12 → plus tard. Le testeur adapte `tests/recette/test_recette_decoupage` après T9 (PX2).

## 9. Risques et parades

| Risque | Parade |
|---|---|
| Trois branches en parallèle, deux qui se touchent à l'exécution (ville × HUD) | API figées dans les plans, appels nouveaux par `has_method`, fusion simulée des trois à la dernière recette |
| `etat_partie.gd` (1 318 l.) touché à chaque lot | Un seul développeur logique ; `Cadence` extraite en 02-L, `foyer.gd` en 03-L |
| `modales.gd` (1 453 l.) : toutes les nouvelles cartes | T9 au début de PX2, avant tout habillage |
| Rue large : un bâtiment qui parle hors écran | La caméra glisse vers lui (PX1) ; étiquettes en flèches de bord (PX2) ; les pièces et cartes entrent par le bord |
| Tests plus lents (rue générée à chaque instanciation de la scène principale) | Génération ≤ 2 s (CA-V2), `tests.ps1` ≤ 60 s (CA-V1) |
| Partie du joueur perdue au passage en 0.3 (format 3) | Dit au joueur avec l'envoi ; migration douce ensuite : plus aucune rupture |
| Budget d'interruptions et durée (≤ 20 min avec le bouton) | Tests de cadence à chaque lot logique ; mesure en 07-L, retrait de créneaux dans l'ordre de docs/15 §2.4 |
| Garde-fous pédagogiques (pas de timing récompensé, saut jamais avant un événement, Jean-Mi jamais enviable) | Un test par garde-fou dans le lot qui l'introduit |
| APK jamais essayé sur téléphone (T2) ; cibles tactiles | `Ecran.dp` + CA-I4/I6 de PX2 ; liste de contrôle donnée au joueur avec la 0.3 |
