# Base de connaissances du chef de projet technique

> À lire au début de chaque mission (après `CLAUDE.md`, avec le socle `developpeur.md`). À mettre à jour à la fin. Concise.
> Dernière mise à jour : 2026-10-29 (validation de la fusion du lot 01).

## 0. Situation

- Équipe : chef de projet (moi), `dev-logique`, `dev-interface`, `testeur`, **`dev-ville`** (recruté le 29/10, actif dès PX0).
- Git (29/10) : `outils/git/cmd/git.exe`, dépôt GitHub, `main`. Circuit : plan → branches `lot/NN-<dev>` (worktrees dans `C:\Users\arthu\Documents\temp\JeuClaude_lots\`) → commits locaux → testeur (`lot_NN_recette.md`) → push de la branche → ma validation → fusion `--no-ff` dans `main`, tests relancés, push.
- **Lot 01 : fusion validée** (29/10, §5 de `lot_01.md`) : `lot/01-logique` 00c4821 (OK passage 2) puis `lot/01-interface` 261d373 (OK passage 1), `--no-ff`, puis vérifications V1-V9 par le coordinateur (202 OK, autocontrôle, captures titre/jouer/krach/fin, `raccourcis` avec et sans `--joueur`, test de recette 11 OK ×2, worktree neuf, `Jouer_Godot.bat` à sec, sauvegarde du joueur intacte). Échec → pas de push, branche `lot/01-<dev>-correctif`. Tâche D08 bis : faite.
  - Après fusion : `principal.gd` 585 l. ; `EcranTitre`, `Sequences`, `RaccourcisTest`, `Reglages`, `ScenariosCapture` + 5 familles ; `StrategieTest` ; `tests.ps1` découvre les tests et détecte les erreurs de script ; `test_interface` 21 vérifications. Référence attendue sur `main` : **202 vérifications** (107 + 21 + 66 + 8), ≈ 24 s.
- **PX0 étape B en cours** (`docs/lots/lot_px0.md`) : `lot/px0-ville` (dev-ville) et `lot/px0-interface` (2e instance de dev-interface), empilées sur le tag `px0-atelier` (9fc6ed8, base 020f8d4 = **avant** le lot 01). Fichiers disjoints du lot 01 (vérifié : 20 fichiers neufs). À la fusion de PX0 : le `tests.ps1` du lot 01 découvrira `tests/test_pixel.gd` tout seul → la recette PX0 doit simuler la fusion avec `main` post-lot 01 (test_pixel doit quitter seul, imprimer OK/KO, aucune erreur de script). Ensuite décision du joueur, puis PX1 (rue, dev-ville) et PX2 (interface, dev-interface) en parallèle, avant les lots 03-04.
- **PX0 bis** (29/10, `docs/lots/lot_px0_bis.md`) : style de rue PX0 rejeté par le joueur ; nouvelle référence `rue_pixel_v2.jpg` (plein jour, briques, arbres verts) + « personnages plus grands ». docs/16 §8 : palette **59 couleurs** (19 ajoutées en fin, les 40 premières intouchables car l'interface PX0 s'en sert), figurine **24 × 42** (1 m ≈ 24 px), maison ≈ 152 × 172, sol à y = 296. dev-ville seul, reprend `lot/px0-ville` (base b586055) ; `lot/px0-interface` (0ad6db7) inchangée (n'utilise que `figer()` et `point_etiquette_maison()`). Recette : CA-B1 à B15 dont fusion simulée avec `main` post-lot 01. Questions au joueur après captures : style, taille, **largeur de rue** (maison + banque + Gazette ne tiennent plus dans 448 px : caméra qui glisse ou bâtiments étroits, à trancher avant PX1), brique « Nord/banlieue », panneaux du HUD foncés sur ciel clair.
- Feuille de route V3 : `docs/lots/feuille_de_route.md` (lots 02 à 07 : P4 → P2 → P1 → P3 + P9 → P6 → P5). Spec `docs/15_spec_game_design_v3.md` en cours chez le game designer.
- Référence avant lot 01 (b55ca7f) : 66 + 100 + 8 (≈ 12 s). Après lot 01 : 202 (voir ci-dessus) ; `-Recette` : + 11.

## 1. Carte de propriété des fichiers

Chemins relatifs à `godot/` sauf mention. « Partagé » = un seul propriétaire **par lot**, nommé dans le plan.

| Fichier / dossier | Propriétaire | Remarque |
|---|---|---|
| `data/*.json` | dev-logique | `banque.json` mêle paramètres et **textes du banquier** (≤ 60 mots, testés). `banque.json > succession` (l. 84) n'est plus lu (donnée de référence). `rythme.json > trafic` lu par la ville ; `demo.json` (`titre`, `journal`, `banquier.nom`, `moments`) lu par l'UI. |
| `scripts/logique/*.gd`, `scripts/partie.gd` | dev-logique | `partie.gd` = pont logique ↔ UI : tout signal modifié = interface du lot. Après lot 01 : `strategie_test.gd` (`StrategieTest`). |
| `tests/test_*.gd`, `tests/autocontrole/`, `outils/tests.ps1`, `outils/trouver_godot.ps1` | dev-logique | Après lot 01 : `tests.ps1` découvre seul les `tests/test_*` → un développeur peut ajouter un test sans toucher `tests.ps1`. |
| `tests/test_partie.*`, `tests/test_interface.*` | **partagé** (défaut dev-logique) | Instancient l'UI : à confier au développeur interface si le lot change ce qu'ils appellent. |
| `tests/recette/` | testeur | Jamais modifié par les développeurs. Lancé seulement par `tests.ps1 -Recette`. Contient `test_recette_decoupage` (lot 01 ; touche du privé de `Modales` : le testeur l'adapte au lot 02 après T9 ; variante `--joueur` lancée à la main). |
| `export_presets.cfg`, `Exporter_*.bat`, `Jouer_Godot.bat` | dev-logique | Version 0.2 / code 2 → 0.3 au lot 02 (avec `project.godot`). |
| `scripts/ui/*.gd`, `scripts/ecran.gd`, `scenes/`, `assets/icone`, `icon.svg`, `outils/generer_icones.gd` | dev-interface | Après lot 01 : `ui/ecran_titre.gd` (`EcranTitre`). |
| `scripts/principal.gd` | dev-interface | Après lot 01 : câblage seulement (≤ 600 l.). Toute fonctionnalité visible y ajoute quelques lignes : prévoir qui les écrit. |
| `scripts/outils/` (`capture.gd`, `reglages.gd`, `raccourcis_test.gd`, `scenarios_capture.gd`), `outils/capture.ps1`, `captures/` | dev-interface | `capture.ps1` prêté à dev-logique au lot 01, rendu à dev-interface ensuite (il inclut `trouver_godot.ps1`, qui reste à dev-logique). Familles de scénarios `scripts/outils/scenarios/{titre,banque,ville,ecrans,outils}.gd` : une famille = un propriétaire (ville → dev-ville). |
| `scripts/ville/*.gd` (dont `sequences.gd` après lot 01), `shaders/`, `scripts/juice.gd` | dev-interface jusqu'au lot 01 ; **dev-ville ensuite** | |
| `project.godot` | **partagé** (défaut dev-interface) | `[display]`, `[gui]`, `[rendering]`, `[input]`, `[jeuclaude]` → interface ; `[autoload]` Partie, `config/version` → logique. Un seul propriétaire par lot. |
| `scripts/pixel/*.gd` (`PalettePixel`, `GrillePixel`, `VuePixel`, `MatieresPixel`, `RuePx0`, `px0.gd`), `scenes/px0.tscn`, `data/pixel/ville/`, `data/pixel/LISEZMOI.md`, `tests/test_pixel.gd`, `outils/capture_px0.ps1`, `Voir_PX0.bat` (racine) | **dev-ville** (PX0) | Atelier pixel (conservé) ; `px0.gd` / `rue_px0.gd` jetables. |
| `scripts/pixel/ui/*.gd` (sans class_name), `data/pixel/ui/`, `polices/**/*.ttf.import` | **dev-interface** (PX0) | Les `.import` des polices naissent au 1er `--import` de **tout** worktree : seul leur propriétaire les commite. |
| `polices/*.ttf`, `OFL.txt`, `LISEZMOI.md` | coordinateur | Sur `main` depuis a515796. |
| `docs/connaissances/dev-interface_px0.md` | dev-interface (PX0) | Temporaire, à fusionner dans `dev-interface.md` au lot 02. |
| `.godot/` | personne | Cache par worktree, régénéré par `--import`. |
| `docs/connaissances/developpeur.md` (socle) | un développeur nommé par lot | Les autres passent par leur base et leur compte rendu. |

**Règle** : le développeur qui porte l'essentiel du changement d'un fichier le reçoit ; l'autre décrit son besoin (signature exacte) dans le plan ou son compte rendu. Deux développeurs qui doivent écrire le même fichier : séquentiel (branche du second créée depuis `main` après fusion du premier).

### Fichiers qui freinent le parallélisme
| Fichier | Traitement |
|---|---|
| `principal.gd` | Découpé au lot 01. |
| Contrat implicite UI → `EtatPartie` (champs `e.banque`, `e.joueur`, `e.hist`, `e.stats`, `e.temoins`, `e.calendrier`, `e.modale` ; ≈ 35 statiques appelées par `panneau_banque.gd`) | `test_interface` + détection des erreurs de script dans `tests.ps1` (lot 01). Façade de lecture : plus tard si les ruptures se répètent. |
| `ui/modales.gd` (1 453 l.) | Découpage au lot 02 (base + journal, courrier, carte banquier, fin/relevé, historique), avant les cartes de P1/P2/P5/P6. |
| `logique/etat_partie.gd` (1 318 l.) | Un seul développeur logique ; découpage (`vie.gd`, `cadence.gd`, `historique.gd`) au lot 03 si la cadence grossit. |
| `ui/panneau_banque.gd` (839 l.), `ui/hud.gd` (772 l.) | Laisser. |

## 2. Interfaces logique ↔ affichage (existantes)

- **Autoload `Partie`** — signaux : `partie_commencee`, `mois_passe(res)` (res = { notifs, modale, fin, m, saut }), `notif_recue(n)` (n.source = maison | banque | media), `modale_ouverte(contenu)` (= `EtatPartie.contenu_modale()`), `modale_fermee(r)`, `vitesse_changee(v)`, `partie_finie(bilan)` (= `Bilan.calculer`), `argent_change`. Actions : `nouvelle_partie`, `reprendre`, `rouvrir_modale`, `sauvegarder`, `changer_vitesse`, `basculer_pause`, `sauter_jusqu_a`, `avancer_un_mois`, `resoudre_modale(choix)`, ordres (`acheter`, `vendre`, `deposer_livret`, `retirer_livret`, `ouvrir_pel`, `verser_pel`, `cloturer_pel`, `acheter_emprunt`, `vendre_emprunt`, `verser_av`, `racheter_av`), versements (`programmer_versement`, `arreter_versement`, `reactiver_versement`), `forcer_naissance` (débogage), `abandonner`. État : `etat`, `vitesse`, `bloquee`, `sauvegarde_auto`, `chemin_sauvegarde`, `progression_mois()`, `duree_mois_s()`, `facteur_trafic()`.
- **`EtatPartie` lu par l'UI** : `ab_courant`, `ab_de`, `banquier_actif`, `depenses`, `epargne_du_mois`, `ecart_livret`, `frais_payes`, `manque_a_gagner`, `patrimoine`, `produit`, `valeur_ligne`, `vie_en_attente`, `historique_recent`, `prenom`, `cours`, `devis_*`, `en_offre`, `place_livret`, `plus_value_latente`, `indice` + champs du §1.
- **Statiques lues par l'UI** : `Banquier.*`, `Produits.*`, `Versements.*`, `Marche.*`, `Sauvegarde.lire/existe/effacer`, `Donnees.charger/config_demo`, `Format`, `Dates`, `Hasard`.
- **Signaux UI internes** : `Hud` (vitesse_demandee, marche_demande, menu_demande, raccourci_demo, batiment_touche, disposition_changee, comparaison_demandee, frais_demandes, notif_touchee, historique_demande), `Modales.choix_fait(genre, id)`, `PanneauBanque` (fermer_demande, ordre_passe, relire, historique_demande), `ville.batiment_touche`, `Ecran.format_change`, `DateVolets.triple_touche`, `CarteProduit.touchee`, `Batiment.touche`.
- **Lot 01** : `Reglages.raccourcis_test()` (faux si tag `template` ou `--joueur`, sinon `jeuclaude/raccourcis_test`) ; `StrategieTest.jouer_mois / aller_a / aller_a_modale`.
- Sauvegarde : format 2. Migration douce (champ absent → défaut) prévue au lot 02 ; d'ici là, tout nouveau champ = décision de version dans le plan.

## 3. Backlog technique (priorisé)

| # | Prio | Élément | Où |
|---|---|---|---|
| ~~T1, T3, T8~~ | — | Raccourcis de test, découpage de `principal.gd` + `test_interface`, D08 bis | **faits au lot 01** |
| B1 | P2 | Graduations de « Mon argent » recouvertes par la courbe et l'étiquette « = 0 F » en début de partie (préexistant ; capture `jumeaux`, mai 1984) | lot 02, dev-interface (`hud.gd`) ; si PX2 refait le HUD, vérifier là |
| B2 | P3 | Commentaire périmé `scripts/ville/accessoire.gd` l. 2 (« séquences de principal.gd » → `Sequences`) | lot 02 ou PX1, dev-ville |
| B3 | P3 | `principal._info()` jamais appelée (code mort, préexistant) | lot 02, dev-interface |
| T18 | P2 | `capture.ps1` : étape `raccourcis` dans la liste, option `-Joueur` (→ `--joueur`) ; `tests.ps1` : pouvoir lancer un test de recette avec `--joueur` (variante du test de recette) | lot 02 : `capture.ps1` dev-interface (avec T13) ; `tests.ps1` dev-logique |
| T2 | P0 | APK jamais essayé sur un vrai téléphone : liste de contrôle courte pour le joueur (installation, défilement de l'historique, cibles 80 px, orientation, sauvegarde en arrière-plan) | avec l'export 0.3 (lot 02) |
| T13 | P1 | Scénarios de capture sur `StrategieTest` (copie temporaire au lot 01) | lot 02, dev-interface |
| T14 | P1 | Migration douce des sauvegardes | lot 02, dev-logique |
| T9 | P1 | Découpage de `modales.gd` (puis `etat_partie.gd` si besoin) | lot 02 / 03 |
| T16 | P1 | `modales.gd` l. 589 : Échap sur un courrier relu pendant le vol de l'enveloppe → SCRIPT ERROR (lambda capture `p` libéré). Reproduire par une étape de capture, puis corriger | lot 02, dev-interface, 1re tâche, avant T9 |
| T15 | P2 | Accesseurs publics de `PanneauBanque` (zone de droite, bouton valider) et `test_interface` qui les utilise (au lieu de `_droite` / `_b_ok`) | lot 02, dev-interface (`test_interface` lui est attribué ce lot-là) |
| T17 | P3 | `tests.ps1` : ajouter les lignes moteur `ERROR:` au motif d'erreurs ; `user://capture.sav` commun aux worktrees → nom unique par processus ; `Exporter_Android.bat` depuis un worktree (JDK/SDK cherchés dans le dépôt principal) | dev-logique / dev-interface (capture), à caser |
| T5 | P2 | Restes P1 de docs/13 : jauge F03, tuile animée de la banque, piles dans le relevé | à re-prioriser face à la V3 |
| T6 | P2 | Sons (autoload `Sons`, couper le son) | à proposer avec P4 / P6 |
| T7 | P2 | VP-D (option 11 §8) | arbitrage client |
| T10 | P3 | APK de publication (keystore hors dépôt, jamais commité) | plus tard |
| T11 | P3 | iOS (Mac + Xcode requis) | impossible ici |
| T12 | P3 | Petites dettes : `Jouer.bat` (V1 archivée) ; accroche « de 1978 à aujourd'hui » pour une démo 1984-1988 (client) ; règles calculées dans l'UI (`modales._phrase_synthese`, comparaisons du HUD) | divers |
| ~~T4~~ | — | Instantané avant lot : remplacé par Git | — |

## 4. Processus

### Plan de lot
`docs/lots/lot_NN.md` (modèle `docs/lots/LISEZMOI.md`, exemple complet : `lot_01.md`) : origine, objectif, hors périmètre, mode, mise en place (commandes worktree), **tableau d'attribution exhaustif** (+ « interdits aux deux »), interfaces (signatures, class_name, sauvegarde), tâches avec CA numérotés (CA-L*, CA-I*, CA-V*) vérifiables par le testeur (test nommé, capture nommée, ligne imprimée, commande), vérifications après fusion, validation. Le plan doit être **commité sur `main` avant la création des branches**.

### Parallélisme avec Git
1. Un fichier = un propriétaire par lot ; un fichier absent du tableau est interdit. Fichiers `.uid` commités avec leur script.
2. Une branche ne doit pas dépendre d'un fichier créé sur une autre branche du même lot (le testeur vérifie chaque branche seule) : sinon séquentiel, ou l'API est créée par le développeur qui l'utilise.
3. Interfaces écrites avant le lancement ; nouveaux `class_name` déclarés dans le plan.
4. Un worktree par branche (`JeuClaude_lots\lotNN-<dev>`) : `.godot/` séparé ; `user://` commun (ne jamais effacer `partie_en_cours.sav` ; fichiers de test uniques par processus après lot 01).
5. Après toutes les fusions d'un lot : je relance `tests.ps1` + captures clés sur `main` ; un échec d'intégration → branche `lot/NN-<dev>-correctif`.

### Définition de « terminé »
- CA cochés avec preuve (test, capture, ligne de sortie) dans le rapport du testeur ; verdict OK.
- `tests.ps1` vert, nombre de vérifications ≥ précédent, un test par règle ajoutée, aucune erreur de script (détectée automatiquement après lot 01).
- Écrans touchés : captures PC + téléphone relues (développeur, testeur, moi).
- Compte rendu : fichiers modifiés (comparés au tableau), non vérifié, écarts d'interface.
- Bases de connaissances à jour ; `CLAUDE.md` mis à jour par le coordinateur.
- Export concerné : exe régénéré et vérifié (`--etape=titre|reprise|raccourcis`).

## 5. Décisions et erreurs à ne pas refaire
- (28/10) Aucun développement avant validation du joueur : levé le 29/10 pour P1-P6, P9, P10 et les deux propositions techniques.
- (29/10) Raccourcis de test : réglage `jeuclaude/raccourcis_test` + tag `template` (l'APK est en debug : `is_debug_build()` ne suffit pas) ; option `--joueur` pour simuler la version du joueur. L'autoload `Capture` reste dans l'exe (vérification de l'export).
- (29/10) Lot 01 en parallèle mais **sans dépendance croisée** : `Reglages` côté interface, `StrategieTest` côté logique, les scénarios gardent une copie de la stratégie jusqu'au lot 02.
- (29/10) Recrutement : **un** développeur de plus, `dev-ville` (la V3 est surtout visuelle : P10, P3, P9, P6, pièces de P4). Pas de second développeur logique : `etat_partie.gd` et la cadence sont un goulot à un seul propriétaire. À réévaluer après le lot 03 (si les passages du testeur ou les demandes de contenu deviennent le goulot, ne pas recruter plus).
- Les retours du joueur (docs/10) priment ; un scénario confus se lit comme un bug (héritage à deux pots).
- (29/10) Pixel art validé (docs/16) : **ne plus commander aucun dessin vectoriel**, même provisoire (sauf quelques lignes). PX0 : facteur N = max(1, floor(hauteur physique / 360)) ; téléphone simulé en 1600 × 720 ×1,7 (la fenêtre 1200 × 540 d'`Ecran` donne N = 1) ; options préfixées `--px0-` (l'autoload `Capture` réagit à `--capture`/`--etape`/`--telephone`) ; HUD de PX0 avec les valeurs de `v3_rue.png` (montage avant / après comparable), carte D08 avec les vrais chiffres (`Banquier.heritage_chiffres`, `Format.entier`). Dette : `include_filter` des exports à étendre à `data/pixel/**/*.txt` ; `capture_px0.ps1` à passer sur `trouver_godot.ps1`.
- (29/10) Deux instances d'un même agent dans deux lots parallèles : jamais la même base de connaissances (fichier temporaire `<agent>_<lot>.md`).
- (29/10) Recette lot 01 : vérifier un CA contre le code **avant** de l'écrire (CA-L9 visait `e.banque` dans `hud.gd`, qui ne le lit pas). Tout `.bat` modifié doit être vérifié « à sec » dans les deux cas (variable définie / absente) : `%VAR:a=b%` est développé avant le `if defined`. Un libellé de test faux = à corriger dans le lot. Les accès d'un test à des membres privés de l'UI sont tolérés s'ils échouent proprement et sont tracés au backlog.
- (29/10) Validation du lot 01 : le testeur a simulé la fusion des deux branches (copie isolée, `user://` à part) ; c'est à exiger dès qu'un lot a deux branches qui se touchent à l'exécution (ici `test_interface` × scène découpée). Les tests de recette du testeur vont dans `tests/recette/` de `main` s'ils couvrent un chemin que rien d'autre ne couvre ; ils ne tournent qu'avec `-Recette`. Vérifier un nombre (« 1 464 lignes ») avant de l'écrire dans un plan.
- Branche empilée (base = tag d'un commit d'une autre branche du lot) : acceptable quand l'API est petite et figée ; le testeur fait le `diff` depuis le tag.
