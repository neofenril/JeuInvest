# Base de connaissances du chef de projet technique

> À lire au début de chaque mission (après `CLAUDE.md`, avec le socle `developpeur.md`). À mettre à jour à la fin. Concise.
> Dernière mise à jour : 2026-10-29 (plan du lot 01, feuille de route V3, recrutement de dev-ville proposé).

## 0. Situation

- Équipe : chef de projet (moi), `dev-logique`, `dev-interface`, `testeur` (depuis le 29/10) ; **`dev-ville` proposé** (fiche `docs/lots/recrutement/dev-ville.md`, à installer par le coordinateur, actif à partir du lot 02).
- Git (29/10) : `outils/git/cmd/git.exe`, dépôt GitHub, `main`. Circuit : plan → branches `lot/NN-<dev>` (worktrees dans `C:\Users\arthu\Documents\temp\JeuClaude_lots\`) → commits locaux → testeur (`lot_NN_recette.md`) → push de la branche → ma validation → fusion `--no-ff` dans `main`, tests relancés, push.
- **Lot 01 planifié** (`docs/lots/lot_01.md`), pas encore lancé : raccourcis de test retirés des versions exportées, découpage de `principal.gd`, worktrees, `tests.ps1` strict + `test_interface`. Parallèle (2 worktrees).
- Feuille de route V3 : `docs/lots/feuille_de_route.md` (lots 02 à 07 : P4 → P2 → P1 → P3 + P9 → P6 → P5). Spec `docs/15_spec_game_design_v3.md` en cours chez le game designer.
- Référence vérifiée le 29/10 sur `main` (b55ca7f) : 66 + 100 + 8 tests verts (≈ 12 s) ; import headless ≈ 5 s, sans erreur.

## 1. Carte de propriété des fichiers

Chemins relatifs à `godot/` sauf mention. « Partagé » = un seul propriétaire **par lot**, nommé dans le plan.

| Fichier / dossier | Propriétaire | Remarque |
|---|---|---|
| `data/*.json` | dev-logique | `banque.json` mêle paramètres et **textes du banquier** (≤ 60 mots, testés). `banque.json > succession` (l. 84) n'est plus lu (donnée de référence). `rythme.json > trafic` lu par la ville ; `demo.json` (`titre`, `journal`, `banquier.nom`, `moments`) lu par l'UI. |
| `scripts/logique/*.gd`, `scripts/partie.gd` | dev-logique | `partie.gd` = pont logique ↔ UI : tout signal modifié = interface du lot. Après lot 01 : `strategie_test.gd` (`StrategieTest`). |
| `tests/test_*.gd`, `tests/autocontrole/`, `outils/tests.ps1`, `outils/trouver_godot.ps1` | dev-logique | Après lot 01 : `tests.ps1` découvre seul les `tests/test_*` → un développeur peut ajouter un test sans toucher `tests.ps1`. |
| `tests/test_partie.*`, `tests/test_interface.*` | **partagé** (défaut dev-logique) | Instancient l'UI : à confier au développeur interface si le lot change ce qu'ils appellent. |
| `tests/recette/` | testeur | Jamais modifié par les développeurs. |
| `export_presets.cfg`, `Exporter_*.bat`, `Jouer_Godot.bat` | dev-logique | Version 0.2 / code 2 → 0.3 au lot 02 (avec `project.godot`). |
| `scripts/ui/*.gd`, `scripts/ecran.gd`, `scenes/`, `assets/icone`, `icon.svg`, `outils/generer_icones.gd` | dev-interface | Après lot 01 : `ui/ecran_titre.gd` (`EcranTitre`). |
| `scripts/principal.gd` | dev-interface | Après lot 01 : câblage seulement (≤ 600 l.). Toute fonctionnalité visible y ajoute quelques lignes : prévoir qui les écrit. |
| `scripts/outils/` (`capture.gd`, `reglages.gd`, `raccourcis_test.gd`, `scenarios_capture.gd`), `outils/capture.ps1`, `captures/` | dev-interface | `capture.ps1` prêté à dev-logique au lot 01. Familles de scénarios `scripts/outils/scenarios/{titre,banque,ville,ecrans,outils}.gd` : une famille = un propriétaire (ville → dev-ville). |
| `scripts/ville/*.gd` (dont `sequences.gd` après lot 01), `shaders/`, `scripts/juice.gd` | dev-interface jusqu'au lot 01 ; **dev-ville ensuite** | |
| `project.godot` | **partagé** (défaut dev-interface) | `[display]`, `[gui]`, `[rendering]`, `[input]`, `[jeuclaude]` → interface ; `[autoload]` Partie, `config/version` → logique. Un seul propriétaire par lot. |
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
| T1 | P0 | Raccourcis de test hors des versions exportées | **lot 01** |
| T3 | P1 | Découpage de `principal.gd` + test de l'interface | **lot 01** |
| T8 | P2 | D08 bis dans docs/13 et docs/11 | **lot 01** (tâche documentaire du coordinateur) |
| T2 | P0 | APK jamais essayé sur un vrai téléphone : liste de contrôle courte pour le joueur (installation, défilement de l'historique, cibles 80 px, orientation, sauvegarde en arrière-plan) | avec l'export 0.3 (lot 02) |
| T13 | P1 | Scénarios de capture sur `StrategieTest` (copie temporaire au lot 01) | lot 02, dev-interface |
| T14 | P1 | Migration douce des sauvegardes | lot 02, dev-logique |
| T9 | P1 | Découpage de `modales.gd` (puis `etat_partie.gd` si besoin) | lot 02 / 03 |
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
