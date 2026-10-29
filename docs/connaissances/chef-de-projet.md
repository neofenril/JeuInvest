# Base de connaissances du chef de projet technique

> À lire au début de chaque mission (après `CLAUDE.md`, avec le socle `developpeur.md`). À mettre à jour à la fin. Concise.
> Dernière mise à jour : 2026-10-28 (prise de poste, aucun lot lancé).

## 0. Situation

- Équipe : chef de projet (moi) + `dev-logique` + `dev-interface`. Le coordinateur lance les développeurs à partir de mes plans (`docs/lots/lot_NN.md`, modèle : `docs/lots/LISEZMOI.md`).
- **Aucun lot en cours.** Prochain lot attendu : propositions du game designer (`docs/14_propositions_game_design.md`, pas encore écrit), **soumises au joueur avant tout développement** (docs/10, 2026-10-28).
- État vérifié le 2026-10-28 : `tests.ps1` vert (test_logique 66 OK en 0,5 s, test_demo 100 OK en 2,3 s, test_partie OK en ≈ 4 s ; codes de sortie 0). Pas de Git : la seule protection contre l'écrasement est l'attribution exclusive des fichiers (§4).

## 1. Carte de propriété des fichiers

Chemins relatifs à `godot/` sauf mention. « Partagé » = un seul propriétaire **par lot**, nommé dans le plan.

| Fichier / dossier | Propriétaire | Remarque |
|---|---|---|
| `data/*.json` (banque, series, salaires, regles, periode_p1, temoins, evenements_vie, demo) | dev-logique | `banque.json` (25 Ko) mêle paramètres et **textes du banquier** : une correction de texte passe aussi par dev-logique (tests de longueur ≤ 60 mots). |
| `data/rythme.json` | dev-logique | `trafic` est lu par `ville/ville.gd` (affichage) : changement de format = interface à déclarer. |
| `data/demo.json` | dev-logique | `titre`, `journal`, `banquier.nom` sont lus par l'UI (`principal.gd`, `modales.gd`). |
| `scripts/logique/*.gd` (etat_partie, banquier, produits, versements, marche, portefeuille, bilan, sauvegarde, donnees, dates, format, hasard) | dev-logique | `Format` et `Dates` servent surtout à l'UI : un nouveau format = demande à dev-logique. |
| `scripts/partie.gd` (autoload Partie) | dev-logique | Pont logique ↔ UI ; toute modification de signal = interface du lot. |
| `tests/test_logique.gd`, `tests/test_demo.gd` | dev-logique | |
| `tests/test_partie.gd` + `.tscn` | **partagé** (défaut dev-logique) | Instancie `PanneauBanque` (UI) : à confier à dev-interface si le lot change la fenêtre Banque. |
| `outils/tests.ps1` | dev-logique | |
| `export_presets.cfg`, racine `Exporter_Windows.bat`, `Exporter_Android.bat` | dev-logique | Version 0.2 / code 2 : à incrémenter à chaque export partagé (avec `project.godot`). |
| `scripts/ui/*.gd` (hud, modales, panneau_banque, style, carte_produit, piles, courbe, frise, date_volets, barres, repartition, pastilles, piece, portrait, bouton_temps) | dev-interface | |
| `scripts/ville/*.gd` (ville, rue, voiture, passant, batiment, maison, banque, media, accessoire, reverbere, plan_fond, dessin) | dev-interface | |
| `scripts/juice.gd`, `scripts/ecran.gd` (autoloads) | dev-interface | |
| `scripts/outils/capture.gd` (autoload), `outils/capture.ps1`, `captures/` | dev-interface | |
| `scenes/*.tscn`, `shaders/*`, `assets/`, `icon.svg`, `outils/generer_icones.gd` | dev-interface | |
| `scripts/principal.gd` (1 464 lignes) | **partagé** (défaut dev-interface) | Orchestration + titre + séquences + raccourcis + scénarios de capture. dev-logique n'y touche que si le plan le lui attribue (ex. `_strategie_active`, saut de temps). |
| `project.godot` | **partagé** (défaut dev-interface) | `[display]`, `[gui]`, `[rendering]`, `[input]` → interface ; `[autoload]` Partie, `config/version` → logique. Un seul propriétaire par lot. |
| `.godot/` | personne | Cache régénéré par `--import` ; ne jamais éditer. Ajout d'un `class_name` → relancer l'import. |
| Racine `Jouer_Godot.bat` | dev-logique | `Jouer.bat` ouvre la V1 web archivée (ne plus toucher). |

**Règle d'attribution des fichiers partagés par lot** : le développeur qui porte l'essentiel du changement du fichier le reçoit ; l'autre décrit ce qu'il lui faut dans le plan (signature exacte) ou dans son compte rendu, et le propriétaire l'intègre. Si les deux ont besoin d'écrire dans le même fichier : travail **séquentiel** (dev-logique d'abord, puis dev-interface câble l'UI).

### Fichiers qui empêchent le parallélisme (découpage à faire dans un lot dédié, si le joueur valide)

| Fichier | Problème | Découpage proposé | Priorité |
|---|---|---|---|
| `scripts/principal.gd` (1 464 l.) | Point de passage obligé de toute fonctionnalité visible (signaux, séquences, captures) ; ~430 lignes de scénarios de capture mêlent pilotage logique et UI. | `principal.gd` (câblage, file « vedette », ≈ 400 l.) ; `ui/ecran_titre.gd` (l. 172-345) ; `ville/sequences.gd` (appel banquier, journal, courrier, crash, naissance, confettis, fumée : l. 567-990) ; `outils/scenarios_capture.gd` (l. 1160-fin, dev-interface) avec la stratégie de jeu automatique dans `logique/strategie_test.gd` (dev-logique, réutilisable par les tests) ; `outils/raccourcis_test.gd` (F6-F8, triple toucher). | **Haute** : préalable au 1er gros lot game design. |
| `project.godot` | Les deux en ont besoin (autoload, réglages d'affichage, version). | Pas de découpage possible : regrouper les besoins dans le plan, un seul propriétaire. | — |
| Contrat implicite UI → `EtatPartie` | L'UI lit des champs internes (`e.banque` dict, `e.joueur`, `e.hist`, `e.stats`, `e.temoins`, `e.calendrier`, `e.modale`) et `panneau_banque.gd` appelle ≈ 35 fonctions statiques (`Banquier`, `Produits`, `Versements`, `Marche`). Un renommage côté logique casse l'UI sans qu'aucun test ne le voie (sauf la fenêtre Banque dans test_partie). | Test de fumée headless (dev-interface + dev-logique) qui instancie `Hud`, `Modales`, `PanneauBanque` et les met à jour sur 60 mois ; à terme, une façade `Partie` pour les lectures. | Haute (avec le découpage) |
| `scripts/ui/modales.gd` (1 453 l., 70 Ko) | Un seul propriétaire, donc pas de conflit, mais coût de lecture élevé et régressions croisées entre modales. | Base `modales.gd` (fond, ouverture, clic dehors, info, confirmer, menu) + `modale_journal.gd`, `modale_courrier.gd`, `carte_banquier.gd`, `modale_fin.gd` (+ relevé), `modale_historique.gd`. | Moyenne |
| `scripts/ui/panneau_banque.gd` (839 l.), `hud.gd` (772 l.) | Gros, fortement liés à la logique (cf. contrat). | Après la façade ; sinon laisser. | Basse |
| `scripts/logique/etat_partie.gd` (1 318 l.) | Un seul propriétaire ; coût de lecture. | `logique/vie.gd` (calendrier, naissances), `logique/historique.gd`, `logique/cadence.gd` (file des modales). | Basse |

## 2. Interfaces logique ↔ affichage (existantes)

- **Autoload `Partie`** (`scripts/partie.gd`) — signaux : `partie_commencee`, `mois_passe(res)` (res = { notifs, modale, fin, m, saut }), `notif_recue(n)` (n.source = maison | banque | media), `modale_ouverte(contenu)` (= `EtatPartie.contenu_modale()`), `modale_fermee(r)`, `vitesse_changee(v)`, `partie_finie(bilan)` (= `Bilan.calculer`), `argent_change`.
  Actions : `nouvelle_partie`, `reprendre`, `rouvrir_modale`, `sauvegarder`, `changer_vitesse`, `basculer_pause`, `sauter_jusqu_a`, `avancer_un_mois`, `resoudre_modale(choix)`, ordres (`acheter`, `vendre`, `deposer_livret`, `retirer_livret`, `ouvrir_pel`, `verser_pel`, `cloturer_pel`, `acheter_emprunt`, `vendre_emprunt`, `verser_av`, `racheter_av`), versements (`programmer_versement`, `arreter_versement`, `reactiver_versement`), `forcer_naissance` (débogage), `abandonner`. État : `etat`, `vitesse`, `bloquee`, `sauvegarde_auto`, `chemin_sauvegarde`, `progression_mois()`, `duree_mois_s()`, `facteur_trafic()`.
- **`EtatPartie` lu par l'UI** — fonctions : `ab_courant`, `ab_de`, `banquier_actif`, `depenses`, `epargne_du_mois`, `ecart_livret`, `frais_payes`, `manque_a_gagner`, `patrimoine`, `produit`, `valeur_ligne`, `vie_en_attente`, `historique_recent`, `prenom`, `cours`, `devis_achat`, `devis_vente`, `devis_vente_totale`, `en_offre`, `place_livret`, `plus_value_latente`, `indice`. Champs : voir §1 (contrat implicite). `principal.gd` (captures) appelle aussi directement `avancer`, `resolution_auto`, `resoudre_modale` et les ordres sur `e`.
- **Statiques lues par l'UI** : `Banquier.*` (contenu, couleur, piles, ordre_carnet, nb_decouverts, etat_carte, info_produit, marquer_vu, presente, presentation_de, detenu, notes, taux_txt, texte_taux_pel, valeur, variables, donnees, CRITERES), `Produits.*` (f, params, devis_*, taux_av, taux_emprunt), `Versements.*` (actif, plan, montants, params, reglable, frais_pct, texte_non_eligible, total_mensuel), `Marche.*` (baguette, frais, plafond_livret, taux_livret), `Sauvegarde.lire/existe/effacer`, `Donnees.charger/config_demo`, `Format`, `Dates`, `Hasard` (media.gd).
- **Signaux UI internes** (dev-interface) : `Hud` (vitesse_demandee, marche_demande, menu_demande, raccourci_demo, batiment_touche, disposition_changee, comparaison_demandee, frais_demandes, notif_touchee, historique_demande), `Modales.choix_fait(genre, id)`, `PanneauBanque` (fermer_demande, ordre_passe, relire, historique_demande), `ville.batiment_touche`, `Ecran.format_change`, `DateVolets.triple_touche`, `CarteProduit.touchee`, `Batiment.touche`.
- Sauvegarde : format 2 (`Sauvegarde.VERSION`, `EtatPartie.VERSION_ETAT`, `CHAMPS_ETAT`). Tout nouveau champ d'état = décision de version dans le plan (ignorer les anciennes sauvegardes ou migrer).

## 3. Backlog technique (priorisé)

| # | Prio | Élément | Propriétaire | Effort |
|---|---|---|---|---|
| T1 | P0 | **Raccourcis de test dans les versions exportées** : l'écran titre de l'exe affiche « F10 / F8 / F6 / F7 » (`principal.gd` l. 239, masqué seulement sur mobile) ; F6/F7/F8 actifs dans l'exe ; **triple toucher sur la date = saut de temps (F8) actif sur téléphone**. Ne garder qu'avec un réglage `jeuclaude/raccourcis_test` (vrai dans l'éditeur, faux à l'export ; attention : l'APK est exporté en debug, donc `OS.is_debug_build()` ne suffit pas). | dev-interface (principal, hud, ecran) + dev-logique (export_presets, project.godot) | S |
| T2 | P0 | **APK jamais essayé sur un vrai téléphone** ; défilement tactile de l'historique, cibles 80 px, facteur 1,7, orientation, sauvegarde à la mise en arrière-plan non vérifiés. Préparer une liste de contrôle courte pour le joueur (installation, 10 vérifications). | chef de projet (liste) ; corrections : dev-interface | S + retour joueur |
| T3 | P1 | **Découpage de `principal.gd`** + test de fumée de l'UI (§1). Préalable au parallélisme. Lot technique dédié, à faire valider par le joueur/client (aucun gain visible). | dev-interface puis dev-logique (séquentiel) | M |
| T4 | P1 | **Instantané avant chaque lot** (pas de Git) : script `outils/instantane.ps1` qui copie `godot/` (sans `.godot/`, `captures/`) dans `sauvegardes/avant_lot_NN/`. En attendant : copie manuelle par le chef de projet au lancement du lot. | dev-logique | S |
| T5 | P1 | Restes P1 de docs/13 : bandeau F03 **jauge de seuil** (+ vérifier le bouton « Grouper »), **tuile animée** qui sort de la banque et y retourne (#7), **piles dans le relevé de décembre** (#11). À re-prioriser face aux propositions du game designer (game feel). | dev-interface | S chacun |
| T6 | P2 | **Sons** : aucun son dans le projet (pas d'AudioStreamPlayer, pas d'`assets/sons`). Sonnerie banque, tiroir-caisse des frais, journal, naissance (13 #15). Prévoir un autoload `Sons` + réglage couper le son. Probablement demandé par le game designer. | dev-interface | M |
| T7 | P2 | **VP-D** (option de 11 §8, nov. 1987) : arbitrage client/game designer avant. | dev-logique puis dev-interface | S |
| T8 | P2 | Docs obsolètes (pas du code) : D08 bis encore cité dans `docs/13` (§1.6 l. 108, §5.1 l. 312, §5.2 l. 320, §5.3 l. 343) et `docs/11` (l. 488, l. 579-580 ancien texte D08). Signalé au coordinateur pour l'ux-designer / le banquier. Vérifier aussi `banque.json > succession` (l. 84 : paramètres encore utilisés ?). | coordinateur ; dev-logique pour le JSON | S |
| T9 | P2 | Découpage de `modales.gd`, puis éventuellement `etat_partie.gd` (§1). | dev-interface / dev-logique | M |
| T10 | P3 | APK de publication (keystore de release, à conserver hors du projet) ; incrément de version systématique. | dev-logique | S |
| T11 | P3 | iOS : nécessite un Mac + Xcode + compte Apple ; impossible sur la machine actuelle. | — | L |
| T12 | P3 | Petites dettes : `Capture` (autoload) embarqué dans l'exe (inactif sans `--capture`) ; `Jouer.bat` lance la V1 archivée ; accroche du titre « de 1978 à aujourd'hui » pour une démo 1984-1988 (à faire trancher par le client) ; règles et textes calculés dans l'UI (`modales._phrase_synthese`, comparaisons du HUD) non testés en headless. | divers | S |

## 4. Processus

### Plan de lot
`docs/lots/lot_NN.md`, modèle dans `docs/lots/LISEZMOI.md` : objectif et origine (retour joueur, docs), hors périmètre, **tableau d'attribution exhaustif des fichiers**, interfaces (signatures, signaux, champs, format de sauvegarde), tâches par développeur avec critères d'acceptation numérotés et testables, ordre (parallèle ou séquentiel), vérifications attendues (tests, captures nommées).

### Règles de parallélisme (pas de Git)
1. Un fichier = un propriétaire par lot. **Un fichier absent du tableau d'attribution est interdit** aux deux développeurs.
2. Les interfaces sont écrites dans le plan **avant** le lancement. Si la logique n'est pas prête, dev-interface code contre la signature prévue ; dev-logique livre les tests de cette API.
3. Fichier partagé nécessaire aux deux → séquentiel : dev-logique d'abord (API + tests), puis dev-interface (câblage + captures).
4. Nouveau `class_name` : nom déclaré dans le plan (espace global unique).
5. Pendant un lot parallèle, pas de `--import` simultané (cache `.godot/`) : dev-logique lance les tests, dev-interface les captures ; la vérification finale complète est faite par moi, seul.
6. Instantané de `godot/` avant chaque lot (T4).

### Définition de « terminé »
- Chaque critère d'acceptation coché avec sa preuve (nom du test ou de la capture).
- `godot/outils/tests.ps1` : 3 codes de sortie 0 ; nombre de tests ≥ au précédent ; un test par règle ajoutée.
- Aucune ligne `SCRIPT ERROR`, `Parse Error` ni nouvel avertissement dans la sortie.
- Tout écran touché : captures PC (1280×720) **et** téléphone (`--telephone`) relues par le développeur puis par moi.
- Compte rendu : liste exhaustive des fichiers modifiés (je la compare au tableau d'attribution), ce qui n'est pas vérifié, écarts d'interface.
- Bases de connaissances mises à jour (`dev-*.md`, socle `developpeur.md` si commun) ; état de `CLAUDE.md` mis à jour par le coordinateur.
- Si l'export est concerné : exe régénéré et vérifié (`--etape=titre|reprise`).

## 5. Décisions et erreurs à ne pas refaire
- (2026-10-28) Aucun développement avant validation par le joueur des propositions du game designer.
- Les retours du joueur (docs/10) priment sur tout plan ; un scénario confus se lit comme un bug (héritage à deux pots).
