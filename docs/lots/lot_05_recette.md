# Lot 05 : recette du testeur

## R-MAISON (branche `lot/04-interface`, HEAD 8954b73 = 03-I2 + 04-I + main d70dba7) : 2026-11-14

**Verdict : OK** (0 bloquante, 0 majeure, 7 mineures). Recette allégée (`feuille_de_route_jouable.md`) : aucun test rouge de la branche, aucune partie bloquée, aucun chiffre faux, sauvegarde et contrat intacts, aucune règle pédagogique violée, périmètre respecté.

### 1. Tests automatiques
- `tests.ps1 -Recette` : premier passage 863 vérifications OK, 4 KO, 0 erreur de script. Les 4 KO étaient **mes propres tests de recette, périmés** (pas des défauts de la branche) : 3 dans `test_recette_fiche_dividendes` (la fiche d'une action montre depuis 03-R, déjà dans `main`, « Dividende : versé en mai, si l'entreprise en distribue cette année-là. » même pour une action non détenue, et garde le cumul reçu après la vente) et 1 dans `test_recette_routage` (la carte passe désormais par `Modales.carte`, plus par le repli courrier : c'est l'objet de 04-I). Je les ai adaptés (dossier `tests/recette/`, qui m'appartient).
- Nouveau `tests/recette/test_recette_maison.gd` (+ `.tscn`) : **parties complètes par la vraie scène `principal.tscn`** (vraies séquences porte → carte, saut, fenêtre Banque), cartes et projets allumés, 4 parties avec TESTEUR_TOUT=1 (actif graine 7 avec portefeuille fabriqué pour obtenir le cas B ; passif graine 7 ; actif graine 31 ; passif graine 31), 1 seule par défaut + reprise d'une sauvegarde sans clés `foyer` / `projets` : **42 vérifications OK, 0 KO**. Contrôles : partie finie en 12/1988 sans blocage ; 9 à 10 cartes toutes fermées ; choix de projet : `projet_en_cours()["id"]` == option choisie ; jour J cas A, B (×2, fabriqué) et C (×1) vus ; **ventes faites == `plan_vente_projet()`** (2/2) ; Échap sans effet hors confirmation et = RETOUR dans la confirmation ; carte désactivée sans effet ; compte jamais négatif ; BANQUE grisée + phrase du HUD == `msg` du moteur (« Réglez d'abord la carte du foyer. ») + ouverture sans effet pendant chaque carte et chaque projet, rouverte ensuite ; étiquette MA MAISON == `projet_en_cours()` à chaque mois (13 à 19 mois par partie) ; ligne du guichet == `ligne_projet_guichet()` (3 à 6 fiches par partie) ; « Mon foyer » (bloc projet) == `projet_en_cours()` (dates, « dans N mois », disponible).
- Total final `tests.ps1 -Recette` : voir §8 (ajouté en fin de passage).
- `capture_interface.ps1 -Serie` : **176 lancements, 0 échec, 0 sortie bloquée, 2 512 s**, code 0. fps 469 (PC) / 776 (tél.).
- `integrale` (cartes éteintes) = **161 419 F / 805,93 F / 11** (référence de `main` inchangée). `integrale_cartes` 111 651 F / 583,36 F / 10 cartes ; **`integrale_maison` 87 447 F, frais 493,03 F, 11 interruptions, dividendes 199,22 F, 10 cartes, 2 projets réalisés sur 2, 14 fiches** : identique au compte rendu du développeur.
- `RUE fiche kind=carte appel=modales` (10 fois) et `RUE fiche kind=projet appel=modales` (4 fois) relevées avec `--controle` dans une vraie partie ; `RUE carte sortie=…` 14 fois.
- `partie_en_cours.sav` du joueur : **absent avant, absent après** tous mes lancements (aucune réécriture par mes soins ; l'exe du joueur n'a pas tourné pendant ma recette).

### 2. Périmètre
`git diff main...HEAD --stat` : 22 fichiers, tous dans la colonne dev-interface (`scripts/ui/*`, `principal.gd`, `project.godot`, `data/pixel/ui/*`, scénarios, `capture_interface.ps1`, `test_interface.gd`, `docs/connaissances/dev-interface.md`) + le prêt `scripts/ville/sequences.gd` (seulement `jouer_modale`, `_sequence_carte`, `_sequence_gazette`). Aucun fichier de logique, de données JSON, de capture ou temporaire. Mes fichiers (`tests/recette/*`) sont non commités par le développeur.

### 3. Critères CA-M
- [x] **CA-M1** `-Recette` vert (après adaptation de mes 2 tests périmés) ; `test_interface` passe la démo cartes et projets allumés (actif et passif) ; mes 4 parties par la vraie scène, sans blocage.
- [x] **CA-M2** carte : 2 choix, montants, pictos ; choix non payable grisé « Il manque … » sans effet (`UI carte refus=ignore`) ; Échap / clic extérieur sans effet ; conclusion == `r["consequence"]` (`egal=oui`) ; `cibles sous_seuil=0`, `debordements=0`, `chiffres_pixelify=0`.
- [x] **CA-M3** BANQUE fermée pendant carte et projet, phrase identique au moteur, rouverte après (série + mon test sur 4 parties).
- [x] **CA-M4** « Mon foyer » : phrase == `humeur_phrase()`, cause, 4 cartes, projet en cours == `projet_en_cours()` (vérifié en jeu réel, 21 mois = « 1 an et 9 mois »), passés avec symbole et mot, aucun nombre d'humeur ; une colonne au téléphone (vérifié à l'image).
- [x] **CA-M5** choix de projet : 3 options == `c["choix"]`, touches, Échap sans effet, `projet_en_cours()["id"]` == option choisie.
- [x] **CA-M6** jour J : cas A (réaliser actif), B (réaliser en vendant, confirmation == `plan_vente_projet()`, ventes faites == plan, compte jamais négatif) et C (rien ne suffit ; P2C : « RENONCER POUR L'INSTANT », sans REPORTER) vus en jeu réel.
- [x] **CA-M7** ligne du guichet == `ligne_projet_guichet()` quand un projet est en cours (« Projet : la Super 5, avril 1986 (dans 21 mois) · 30 000 F »), rien sans projet.
- [x] **CA-M8** étiquette == `projet_en_cours()`, `chevauchements=0`, absente sans projet.
- [x] **CA-M9** `_config()` hors capture contient `cartes` et `projets` (test) ; absents en capture ; reprise d'une sauvegarde sans clés `foyer` / `projets` : sans cartes ni projets, finit en 12/1988 (script d'écriture sur la branche elle-même, pas une vraie sauvegarde 0.4.1 : voir §6) ; `integrale` = `integrale_saut` = références de `main` ; `integrale_maison` imprimée.
- [x] **CA-M10** lignes `RUE fiche … appel=modales` ; `capture_interface.ps1 -Serie` code 0 ; `capture_ville.ps1 -Serie` **non rejouée** (aucun fichier de ville touché hors le prêt `sequences.gd`, couvert par `test_rue`, `test_pieces`, `test_pixel` verts et par la vraie séquence).
- [~] **CA-M11** (à la main) : remplacé par mes 4 parties complètes pilotées par code dans la vraie scène, PC et téléphone simulé (captures relues) ; le jeu à la main par un humain n'a pas été fait.
- [x] **CA-M12** périmètre conforme (§2).

### 4. Captures relues (à l'image)
Série : `l5_projet_choix_tel`, `l5_projet_jour_j_tel`, `l5_projet_jour_j_1080`, `l5_projet_confirmation_tel`, `l5_foyer_projet_tel`, `l5_etiquette_projet_1080` et `_tel`, `l5_banque_guichet_tel`, `l4_carte_tel`, `l4_carte_refus_1080`, `l4_banque_fermee_tel`. Vraie séquence (mes captures, hors dépôt) : porte ouverte puis carte (PC et téléphone), carte, choix de projet, jour J cas A / B / C, confirmation, Mon foyer, guichet, aux formats 1920 × 1080 et 1440 × 648. Aucun débordement, aucun chevauchement, chiffres lisibles et cohérents d'un écran à l'autre (ex. 20 936 + 9 064 = 30 000 F ; 21 mois = 1 an et 9 mois ; étiquette = « Disponible » de la carte).

### 5. Anomalies (toutes mineures)
1. **Jour J cas C : « Rien à vendre : tout est disponible. » alors qu'il manque 2 362 F** (P2C, 12/1988, joueur tout sur le compte courant ; le bandeau « IL MANQUE 2 362 F » et le bouton disent le vrai). Phrase contradictoire dans un cas réel (1 partie sur 4 chez moi). Attendu : texte propre au cas « manque et rien à vendre » (ex. « Rien à vendre : il manque 2 362 F »). `modale_projet.gd`.
2. **« Mon foyer » PC 1080 : montant tronqué** dans la ligne d'une carte longue : « Les vacances 84 · Camping à Palavas · −2 5… » (au téléphone la ligne tient). À faire : tronquer le titre, jamais le montant.
3. **Confirmation des ventes : « Ce qui reste va sur votre compte. »** sans montant quand il ne reste rien (reste = 0) ; maquette : ligne absente. `modale_projet.gd` l. 529.
4. **Liste courte des ventes sans en-têtes de colonnes** (VOUS RECEVEZ / VS VOS VERSEMENTS / COÛT DE LA VENTE, prévus par docs/24 §1.2.1) : trois montants non légendés.
5. **Confirmation au téléphone : une seule vente visible sur deux** (défilement avec barre visible ; total couvre les deux). Défilement tactile non vérifié.
6. **Cartes de projet : grande zone vide en bas** (PC, jour J et confirmation) ; hauteur fixe plus grande que le contenu. Cosmétique. Par ailleurs, pendant la sortie de la porte au téléphone, le bas de l'étiquette MA MAISON passe sous la frise (une capture).
7. `Grouper : 2 500 F` en Atkinson **18 px** (< 20) dans le formulaire d'ordre : **préexistant** (non touché par ce lot, imprimé `UI atkinson_petit`). Et : certaines captures du développeur (`foyer_projet`, `projet_jour_j`) utilisent des contenus fabriqués que le moteur n'émet pas (4 boutons dont RÉALISER désactivé ; « dans 1 an et 2 mois » en 10/1985 pour avril 1986) : le vrai moteur émet RÉALISER **ou** RÉALISER EN VENDANT ; j'ai vérifié le vrai rendu moi-même.

### 6. Non vérifié
Vrai téléphone et défilement tactile ; ressenti de l'animation de la porte ; partie jouée à la main par un humain ; `capture_ville.ps1 -Serie` ; vraie sauvegarde 0.4.1 de l'exe du joueur (je n'ai pas touché à `partie_en_cours.sav`) ; jour J cas B obtenu par portefeuille fabriqué (le moteur ne l'amène pas seul sur mes graines : 7 et 31) ; reports (REPORTER) jamais choisis par ma stratégie.

### 7. Zones fragiles pour la suite
Texte des cas de jour J selon `ventes` vide (anomalie 1) ; carte projet à hauteur fixe ; « Mon foyer » PC avec titres longs ; `Sequences.jouer_modale` prêté (gazette : `Modales.gazette` n'existe pas encore, repli courrier).

### 8. Total final

tests.ps1 -Recette : 21 étapes développeurs et recette hors 	est_recette_maison = 868 vérifications OK, 0 KO, 0 erreur de script ; plus 	est_recette_maison en défaut (1 partie actif graine 7 avec portefeuille fabriqué, + reprise CA-M9) = 12 OK, 183 s : **total 880, 0 KO**. Variable TESTEUR_TOUT=1 : 4 parties (42 OK, 0 KO, vérifié en fenêtré, ≈ 12 min). 	est_recette_maison demande -Delai 700 (le défaut de 120 s ne suffit pas) ; TESTEUR_IMG / TESTEUR_FMT produisent des captures du viewport.
