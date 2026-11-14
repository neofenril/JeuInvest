# Lot 05 : recette du testeur

## 05-L (rue et krach) : passage 1, 2026-11-14, branche `lot/05-logique`, commit testÃ© 9ed6149

**Verdict : KO** (1 anomalie majeure : une barre de Â« Le krach, un an aprÃ¨s Â» est fausse face au moteur rÃ©el).

### RÃ©sultats
- `tests.ps1 -Recette` : **981 vÃ©rifications OK, 1 KO, 0 erreur de script, import propre** (rÃ©fÃ©rence `main` 831). Le KO est **mon** test `test_recette_dividendes` (constantes de mai 1987 pÃ©rimÃ©es par D5 : Peugeot 700 F en 05/1987 â†’ total 540,62 F au lieu de 532,27 F ; recalcul Ã  la main = moteur au centime) : constantes mises Ã  jour dans mon test (`godot/tests/recette/`), pas une anomalie du jeu.
- Nouveau test de recette `godot/tests/recette/test_recette_rue.gd` (42 vÃ©rifications indÃ©pendantes de celles du dÃ©veloppeur) : 39 OK, 3 KO (tous = anomalie A1).
- PÃ©rimÃ¨tre (`git diff main...lot/05-logique --stat`) : 24 fichiers, tous dans la colonne 05-L du plan (modules `quartier`/`krach`, donnÃ©es, `etat_partie`, `cadence`, `bilan`, `projets`, `strategie_test`, tests existants adaptÃ©s, bases de connaissances). Aucun `test_interface` / `test_partie`, aucun fichier temporaire. Mineur : `tests/test_rue_moteur.gd(.uid)` est un nouveau test absent de la liste nominative du Â§3 (mÃªme propriÃ©taire, sans consÃ©quence).
- `partie_en_cours.sav` du joueur : absent avant et aprÃ¨s (non touchÃ©). Aucun Godot d'autrui fermÃ©.

### Anomalie
**A1 (majeure) : barre Â« Tout vendu Â» de Â« Le krach, un an aprÃ¨s Â» trop basse d'un mois d'intÃ©rÃªts du Livret A.**
- Reproduire : graine 7, rue allumÃ©e, aucune action au krach (exemple de 10 000 F de SICAV) â†’ modale gazette 10/1988. MÃªme chose avec un portefeuille SICAV + Elf + Peugeot (graines 3 et 12, choix Â« vendre Â»).
- Attendu : ce que donne rÃ©ellement le moteur si l'on vend au krach (10/1987) et place au Livret A : l'argent reÃ§oit les intÃ©rÃªts des fins de mois 10/1987 Ã  09/1988 (12 mois, `_fin_de_mois`), soit **10 453,80 F** pour 10 000 F (docs/26 : â‰ˆ 10 450 F). MesurÃ© en jouant les deux parties (avec et sans 10 000 F au Livret Ã  l'ouverture du krach) : 10 453,80 F.
- ConstatÃ© : **10 415,03 F** (Ã©cart âˆ’38,77 F ; âˆ’54,22 F sur un portefeuille de 14 568 F). Cause : `EtatPartie.ctx_gazette` boucle `for mm in range(ab_k + 1, a)` et saute le mois 10/1987 ; il faut `range(ab_k, a)` pour les intÃ©rÃªts du Livret (la boucle des dividendes, elle, est bonne : tous en mai). Â« Rien fait Â» (14 459,20 F) et Â« RenforcÃ© Â» (21 544,20 F) sont exacts au centime face au moteur (SICAV, et lignes SICAV + Elf + Peugeot avec dividendes et achats rÃ©els), la barre entourÃ©e suit le choix rÃ©el.
- Les tests du dÃ©veloppeur ne le voient pas (ils recalculent avec la mÃªme boucle). Correction Ã  faire cÃ´tÃ© logique ; mon `test_recette_rue.gd` passera dÃ¨s que c'est corrigÃ©. GravitÃ© : un chiffre pÃ©dagogique affichÃ© est faux de 0,4 % (l'ordre des barres et la leÃ§on ne changent pas) ; classÃ© majeur par la rÃ¨gle Â« chiffre faux Â».

### CritÃ¨res (CA-R, â˜… obligatoires)
- [x] CA-R1 â˜… : suite verte (hors mon test pÃ©rimÃ©, corrigÃ©), 0 erreur de script ; diff `test_interface`/`test_partie` vide.
- [x] CA-R2 â˜… J1/J2 sur 120 vraies parties (40 graines Ã— passif, actif, tout-Peugeot, mon propre code) : J1 tenu, marge minimale **5 125 F en 09/1987** ; J2 : Jean-Mi Ã  â‰¤ 33,1 % du patrimoine de Tata (Ã©cart â‰¥ 66,9 %) en 12/1988, toujours dernier, Matelas derriÃ¨re Tata. Joueur passif : le joueur repasse devant Jean-Mi en **10/1987 (40/40)** ; Jean-Mi passe devant au plus tard en 10/1986 (27/40 en 10/1986 ; 13/40 dÃ¨s 01/1986 parce que ces joueurs Â« dÃ©pensiers Â» ont dÃ©jÃ  un patrimoine infÃ©rieur au miroir : ce n'est pas liÃ© Ã  la rue) ; notification de rang Â« perte Â» en 10 ou 11/1986, Â« gain Â» en 12/1987. Tata derriÃ¨re Jean-Mi de 03 Ã  09/1987 (= J1). **Ã‰cart signalÃ©** : `couverture_min` = 30 000 F (la couverture est le plus grand de 80 % du compte et 30 000 F), non prÃ©vu par D4 ; sans lui J1 Ã©choue 26 fois sur 40 ; Ã  faire valider par le chef de projet.
- [x] CA-R3 â˜… (miroir) : vÃ©rifiÃ© par le dÃ©veloppeur (40 graines, au franc prÃ¨s jusqu'en 08/1986) et recoupÃ© par mes mesures de diffÃ©rences avec Tonton Matelas (aucun Ã©cart inexpliquÃ©).
- [x] CA-R4 â˜… levier : couverture + dette = perte (phrase calculÃ©e, recalcul dans le test du dÃ©veloppeur, relu).
- [x] CA-R5 â˜… notifications (120 parties, mon code) : â‰¤ 1 voisin / 2 mois, â‰¤ 1 rue ou kiosque / mois, aucune un mois de pause, rang â‰¥ 6 mois d'Ã©cart et pas avant 10/1986, kiosque Ã  sa date ou +1 mois sinon absent (559 titres absents sur 1 320, soit 42 %, Ã  connaÃ®tre), les 5 â˜… toujours dans l'historique (genre voisin, source rue) ; **saut COURRIER** (5 graines, `Partie`) : mÃªmes notifications que pas Ã  pas, 5 â˜… prÃ©sentes. Passages non â˜… abandonnÃ©s : 0,53 par partie.
- [x] CA-R6 â˜… : aucun Â« achetez / vendez / c'est le moment / auriez dÃ» Â» (seule occurrence : un commentaire `_note` de `krach.json`) ; vouvoiement partout, y compris Tata et Jean-Mi ; aucun achat Ã  crÃ©dit cÃ´tÃ© joueur (non modifiÃ©).
- [x] CA-R7 (OK au passage 2) â˜… : 10/1988 dans 120 parties sur 120 (genre gazette, source media) âœ“ ; barres Â« Rien fait Â» et Â« RenforcÃ© Â» exactes âœ“ ; **Â« Tout vendu Â» âœ— (A1)**.
- [x] CA-R8 â˜… : 7 jours (1 240 / 1 119,7 / 1 050 / 1 085 / 1 045 / 1 020 / 990), variations recalculÃ©es âˆ’9,7 âˆ’6,2 +3,3 âˆ’3,7 âˆ’2,4 âˆ’2,9, certitudes A A C C C C C ; aucune autre modale n'en porte ; rue Ã©teinte : absent.
- [x] CA-R9 â˜… : rue Ã©teinte par dÃ©faut (`rue.json > actif = false`, `config_demo` sans clÃ© `rue` ; `principal._config()` n'allume rien dans ce lot, c'est 05-I) : aucune notification rue, pas de gazette ; graine 7 actif **172 139,25 F / 870,08 F / 11 interruptions** ; allumer la rue ne change pas le patrimoine du joueur passif (12 graines). Seules rÃ©fÃ©rences changÃ©es : frais 870,08 F (au lieu de 869,97 F : la gestion de la SICAV suit l'indice 1988-10 = 1 470) et cours Peugeot des cas 100/117/118 de `test_logique` ; explications cohÃ©rentes (le patrimoine ne bouge pas).
- [x] CA-R10 â˜… : sauvegarde en 11/1986 et 11/1987 puis reprise : Jean-Mi, quartier, instantanÃ© identiques, mÃªme fin ; sauvegarde allumÃ©e amputÃ©e de l'instantanÃ© et de clÃ©s du quartier : se recharge et finit. **Vraies sauvegardes de `main` (d70dba7, Ã©crites par sa propre copie, 3 cas : 06/1986 actif, 06/1987 passif, 12/1987 actif)** : se rechargent, rue Ã©teinte, aucune notification de la rue, vont Ã  la fin avec exactement les chiffres de `main` (76 384,89 F / 604,92 F / 13 ; 36 443,63 F / 0 F / 11).
- [x] CA-R11 : contrat Â§4.3 prÃ©sent (accesseurs, notifications, `jours`, gazette, bilan) ; aucune ligne `func/signal/var/const` d'un nom existant supprimÃ©e.
- [x] CA-R12 â˜… : pÃ©rimÃ¨tre OK.
- Patrimoine de Jean-Mi (point 4) âœ“ : voiture comptÃ©e, jamais d'Ã©quitÃ© nÃ©gative ; achat de la Porsche neutre ; en 10/1987 la baisse = perte + dÃ©cote + intÃ©rÃªts du crÃ©dit (dette comptÃ©e **une** fois) ; 12/1988 voiture vendue, crÃ©dit soldÃ© (40 graines).
- Bilan (point 8) âœ“ : `rue` = classement (4 lignes), `replique_rue` = voisin juste devant, sinon juste derriÃ¨re, bon texte ; vide rue Ã©teinte. Avec les 40 graines seules les rÃ©pliques de Tata ont Ã©tÃ© rencontrÃ©es (celle de Jean-Mi n'apparaÃ®t pas : le joueur n'est jamais derriÃ¨re lui en fin de partie, cohÃ©rent avec J2).

### Non vÃ©rifiÃ©
Rien Ã  l'Ã©cran (lot 06) ; textes `_provisoire` non relus par le game designer ; durÃ©e des tests jamais mesurÃ©e en charge (aucun seuil en cause ici).

### Mineures
- M1 : 42 % des titres de kiosque absents en moyenne (budget serrÃ©) : le joueur en verra ~6 sur 11.
- M2 : un joueur dÃ©pensier (13 graines) est dÃ©jÃ  derriÃ¨re Jean-Mi (miroir) avant 10/1986 ; le message de rang n'arrive qu'en 10/1986 ou 11/1986.
- M3 : le worktree contient des modifications non commitÃ©es Ã©trangÃ¨res (`docs/25_banquier_projets_textes.md`, `docs/connaissances/banquier.md`) : pas de moi.

## 05-L (rue et krach) : passage 2, 2026-11-14, branche `lot/05-logique`, commit testÃ© da3000f

**Verdict : OK.**

- A1 corrigÃ©e : `ctx_gazette` boucle du Livret en `range(ab_k, a)`. Mon test `test_recette_rue` (recalcul indÃ©pendant, contre le moteur rÃ©el de deux parties jumelles) : **42/42**. Exemple 10 000 F : Â« Tout vendu Â» = **10 453,80 F** (moteur 10 453,80 F ; docs/26 â‰ˆ 10 450), Â« Rien fait Â» 14 459,20 F et Â« RenforcÃ© Â» 21 544,20 F inchangÃ©s au centime. Portefeuilles de 14 568 F (graines 3 et 12) : barres Ã©gales Ã  l'Ã©tat rÃ©el du moteur (tests 3 lignes de mon test).
- `tests.ps1 -Recette` : **25 Ã©tapes, 1 028 vÃ©rifications OK, 0 KO, 0 erreur de script, aucun Parse Error**, 207,9 s. `test_recette_dividendes` 17/17 (constantes 540,62 F de mai 1987 Ã  jour).
- Diff de da3000f : `etat_partie.gd`, `data/rue.json`, `tests/test_rue_moteur.gd` seulement.
- RÃ©fÃ©rences Ã©teintes inchangÃ©es (graine 7, joueur actif) : 172 139,25 F / 870,08 F / 11 interruptions.
- B8 : `rue.json > etapes_jeanmi` (5 libellÃ©s), `jeanmi_resume()["etape_texte"]` non vide aux 5 Ã©tapes, vide rue Ã©teinte ; test de vouvoiement de `temoins.json` vert.
- `couverture_min` = 30 000 F : Ã©cart consignÃ©, validÃ© par le chef de projet (non rouvert).
- `partie_en_cours.sav` du joueur : absent avant et aprÃ¨s. Aucun Godot d'autrui touchÃ©. 120 parties non refaites (aucun doute : seul le calcul d'une barre a changÃ©).
- CA-R7 maintenant cochÃ© (les trois barres exactes). Les mineures M1 Ã  M3 du passage 1 restent valables (M3 : modifications non commitÃ©es Ã©trangÃ¨res sur docs/25 et connaissances/banquier.md, que je n'ai pas commitÃ©es).


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


## R-RUE (branche `lot/05-interface`, HEAD 1faa723 = main 6cc9f43 + 03-I2 + 04-I + corrections R-MAISON + 05-I) : 2026-11-14

**Verdict : KO** (2 anomalies majeures, chacune corrigeable en quelques lignes ; tout le reste est vert). Aucune partie bloquée, aucun chiffre de la rue faux, sauvegarde et contrats intacts.

### 1. Tests automatiques
- `tests.ps1 -Recette -Delai 700` (avant mon nouveau test) : 26 étapes, **1 091 vérifications OK, 0 KO, 0 erreur de script** (test_interface 89, test_projets 44, test_rue_moteur 36, mes tests de recette rue 42, maison 12, routage 11, saut 18, etc.). Sauvegarde du joueur : absente avant / après (aucun `partie_en_cours.sav`, aucun Godot lancé par moi sur la partie du joueur).
- Nouveau `godot/tests/recette/test_recette_rue_ui.gd` (+ `.tscn`, 14 vérifications) : une partie COMPLÈTE par la vraie `principal.tscn`, tout allumé, pilotée par code (voir §4). **Il est ROUGE en `tests.ps1` : 14 OK, 0 KO mais 3 erreurs de script (anomalie A2).** Je le laisse dans le dépôt : il garde la correction de A2.
- `capture_interface.ps1 -Serie` COMPLÈTE : **207 lancements, 0 échec, 0 sortie bloquée, 3 021 s** ; `user://` inchangé. `UI … incoherences=1` : aucune ; `sous_seuil`, `debordements`, `recouvre`, `contenu_coupe` : aucun non nul. Les 3 échecs corrigés par le développeur (fiche « un an après » au téléphone) sont verts.
- `capture_ville.ps1 -Serie` : 84 lancements, « PX1 : tout est vert » (`RUE fiche kind=carte appel=modales`).
- `integrale_jouable` (log de la série) : 86 213 F, frais 264,80 F, 11 interruptions, dividendes 54,54 F, 10 cartes, 2 / 2 projets, 17 notifications de la rue, rang final 3 : identique au compte rendu. `integrale` = 161 419 F / 806,08 F / 11 (KB 805,93 F : écart de 0,15 F dû au passage 2 de 05-L, même cause que 870,08 F en rue éteinte ; non remesuré sur `main`). Références rue éteinte (tests) : actif graine 7 172 139,25 F / 870,08 F / 11 / dividendes 360,43 F, passif 145 655,67 F : conformes à l'attendu.

### 2. Périmètre (`git diff main...HEAD --stat`)
Tout est dans la colonne 05-I (scripts/ui, principal.gd, scenarios, capture_interface.ps1, data/pixel/ui, project.godot version 0.5, test_interface) + mes fichiers de recette. Aucun fichier de `scripts/logique/`. `scripts/ville/sequences.gd` : seulement `jouer_modale`, `_sequence_carte` (paramétrée par le kind) et la nouvelle `_sequence_gazette` (CA-U12 OK). **Écart : `godot/data/rue.json`** (1 phrase : `texte_long` de V01 « …est dans le panneau « Mon argent » » au lieu de « …en haut de l'écran »), fichier de la colonne dev-logique. La correction est exacte et sans effet sur la logique (tests verts) ; à faire ratifier par le chef de projet (mineure M1).

### 3. Parties complètes (vraie scène, tout allumé, saut « prochain courrier » sauf mention)
Neuf parties jouées de bout en bout par `principal.tscn` (graines 7 et 31, actif et passif, PC et téléphone simulé, krach « vendre » / « renforcer » / « rien » / « exemple », une partie à ×1 sans saut ; 8 en saut + 1 à ×1) : **aucune bloquée**, toutes finissent en décembre 1988.
- Bloc LA RUE du HUD == `classement_rue()` (ordre, noms, rang, montants au format, signe − des négatifs) chaque mois de saut vu (26 mois) ; classement trié, « Vous » = patrimoine + vie en attente, Tata = patrimoine de `temoins["livret"]`, rang de la languette (téléphone) == `rang_rue()` ; Jean-Mi derrière Tata en 12/1988 dans toutes les parties (21 809 F, 32 429 F, 2 429 F contre 95 à 128 k F). Égalité joueur / Tonton Matelas (passif) : le joueur devant, à moins de 0,5 F près.
- Krach (10/1987) : la fenêtre s'ouvre avec le tableau, 7 lignes == `c["jours"]` == `krach.json` (arrondis à 5 points, variations recalculées à la main : −9,7 ; −6,2 ; +3,3 ; −3,7 ; −2,4 ; −2,9 ; cumul −20 %) ; 3 choix visibles aux deux formats (captures `l6_krach_jours_1080` et `_tel`, relues).
- « Un an après » : ouverte en 10/1988 dans 9 parties sur 9 ; 3 barres dans l'ordre vendu / rien / renforcé, valeurs == `c["barres"]` ET == **recalcul indépendant** (copie de l'état au krach, même choix, jeu passif jusqu'en 10/1988) à 1 F près dans les 3 variantes ; barre entourée == choix réel du krach (vendre → vendu, renforcer → renforcé, rien → rien, exemple → aucune + mention) ; Échap sans effet. `RUE fiche kind=gazette appel=modales`, `kind=projet`, `kind=carte` imprimées en partie réelle.
- Notifications : 17 de la rue + 5 à 6 du kiosque par partie (6 notifications persistantes), toutes dans l'historique (source rue / média) ; à ×1, 23 toasts sur 23 affichés avec le texte court exact ; ★ présentes.
- Écran de fin (partie réelle) : 4 barres == `classement_rue()`, rang « 1er / 2e DE LA RUE SUR 4 » == `rang_rue()`, réplique == `replique_rue` du bilan (vouvoiement), « Projets : n sur 2 réalisés » == `projets_passes()`.
- **Durée** (temps machine, sans temps de lecture humain) : saut « prochain courrier » **164 à 171 s** par partie ; à ×1 sans saut **516 s** (8,6 min). 25 interruptions avec pause (cartes 10, projets 4, présentations 7, vie 2, marché 1, gazette 1) et 17 + 6 notifications. Estimation avec le bouton COURRIER et ≈ 15 à 20 s de lecture par interruption : ≈ 9 à 11 min (cible ≤ 20 min : tenue, mais **estimée, non mesurée sur un humain**).
- Ancienne sauvegarde : deux sauvegardes réelles de `main` (06/1986 et 12/1987, avec et sans les clés `foyer` / `projets` / `quartier` / `jeanmi`) se rechargent, restent sans rue (classement vide, 0 notification de rue, 0 gazette) et finissent en 12/1988 (HUD éteint : `l6_rue_eteinte_tel` relue, languette « MON ARGENT 13 k F » identique à `main`).
- Export : `Exporter_Windows.bat` (copie isolée, `JEUCLAUDE_GODOT`) réussi, 110 517 272 octets. `--main-pack` + `--etape=titre` et `--etape=rue_bloc` : **0 ligne ERROR, 0 GrillePixel** (les 2 ERROR GrillePixel des exe depuis 0.3 ont disparu). `--etape=un_an_apres` : 1 ERROR, `Can't save PNG at path 'captures/l6_un_an_apres_vue_rien.png'` : c'est l'étape de capture du développeur qui écrit une image dans `res://captures/`, impossible dans un paquet ; aucun rapport avec le jeu (M2).

### 4. Critères (CA-U)
- [~] **CA-U1** tests des développeurs et recette existante verts (1 091 OK) ; mon nouveau test de partie complète rouge (A2) ; `test_interface` passe la démo tout allumé ; ma recette passe 9 parties complètes sans blocage.
- [x] **CA-U2** (bloc / languette) : `UI rue rang=2 lignes=4 negatif_signe=oui panneau_coupe=non` PC 1080, 1152 × 648, téléphone, 16:9 ; languette « 2e sur 4 » (rang == `rang_rue()` dans mes parties) ; toucher = panneau ouvert ; éteinte : ni bloc ni rang ; `sous_seuil=0`.
- [x] **CA-U3** bloc == `classement_rue()` (mes parties) ; négatif rouge avec signe (captures) ; `debordements=0`.
- [x] **CA-U4** notifications : libellé « LA RUE » + liseré bleu ; relecture longue == `texte_long` (`UI rue_notifs relecture_longue … egal=oui`) ; persistante restée 3 mois sans pause ; onglet LA RUE (9 entrées, source rue seule). Réserve : voir M5.
- [x] **CA-U5** krach : voir §3 (7 lignes, choix visibles aux 2 formats, modale inchangée sans jours, `l6_krach_sans_jours_tel`).
- [x] **CA-U6** « un an après » : voir §3 (3 barres, entourée, Échap, `RUE fiche kind=gazette appel=modales`).
- [x] **CA-U7** fin : voir §3 ; rue éteinte : `UI fin barres=2 rue=eteinte pastille_rang=ABSENTE`.
- [x] **CA-U8** `_config()` hors capture : cartes, projets, rue vrais (OK dans mon test) ; `integrale` = `integrale_saut` (hors capture éteints) ; `integrale_jouable` imprimée.
- [~] **CA-U9** partie complète « à la main » : remplacée par 9 parties pilotées par code dans la vraie scène (aucun humain) ; téléphone 09/1987 à 11/1987 relu sur captures. **A1 : au téléphone, l'historique a des nombres tronqués.**
- [~] **CA-U10** export réussi, `--main-pack` titre propre ; `un_an_apres` : 1 ERROR de capture (M2).
- [x] **CA-U11** périmètre (réserve M1). [x] **CA-U12** `sequences.gd` limité à `jouer_modale` et aux séquences carte / gazette.

### 5. Anomalies
**A1 (majeure) : historique au téléphone, les nombres des onglets sont tronqués (chiffre faux).** Étapes : rue allumée (cas par défaut de 0.5), ouvrir HISTORIQUE sur le téléphone simulé 1440 × 648 avec ≥ 10 entrées dans MA MAISON / MA BANQUE (`capture_interface.ps1 -Etape historique_rue -Telephone`). Attendu : « MA MAISON 15 », « MA BANQUE 18 ». Constaté : « MA MAISON 1 », « MA BANQUE 1 » (le 2e chiffre est coupé par `clip_text`, `modale_historique.gd` l. 86) ; à 1280 × 720 (`-Telephone169`) les trois nombres MA MAISON / MA BANQUE / LA GAZETTE disparaissent, et à 1440 × 648 LA GAZETTE « 4 » est juste. Cause : le 5e onglet LA RUE réduit la largeur de chacun (avec 4 onglets, `px2_historique_tel169` affichait « 4 », « 26 », « 2 » sans coupure) ; régression propre à l'allumage de la rue. Captures : `l6_historique_rue_tel.png`, `testeur_hist_tel169.png`. Correction attendue : police ou libellé plus courts (ex. « MAISON », « BANQUE ») ou nombre en pastille, sans `clip_text` sur le nombre.

**A2 (majeure) : SCRIPT ERROR en partie normale pendant un saut (test rouge).** Étapes : partie complète tout allumé, bouton COURRIER, plusieurs notifications (rue, kiosque, banque) pendant un même saut. Attendu : aucune erreur. Constaté : `SCRIPT ERROR: Invalid type in function '_retirer' in base 'Control (Hud)'. The Object-derived class of argument 1 (previously freed)…  at: Hud._notifier_compacte (hud.gd:1803)` (3 fois en `tests.ps1`, dans 6 parties sur 8 en mode saut, 2 à 3 erreurs chacune ; jamais à ×1). Cause : la 4e notification compacte évacue la plus ancienne (`_evacuer` → `queue_free`), puis le minuteur de celle-ci appelle `_retirer(p)` sur un nœud libéré ; `notifier()` a la garde `is_instance_valid(p)` (l. 1714) mais pas `_notifier_compacte` (l. 1802-1803). Pas d'effet visible en jeu (le nœud est déjà parti), mais `tests.ps1` traite tout SCRIPT ERROR comme un échec et l'allumage de la rue rend le cas courant. Reproduire : `tests.ps1 -Recette -Filtre rue_ui -Delai 700`. Correction : `if not is_instance_valid(p): return` après le `await` de la l. 1802.

**Mineures**
- M1 : `data/rue.json` modifié par dev-interface (voir §2).
- M2 : `un_an_apres` dans un paquet exporté : 1 ERROR (écriture d'une capture dans `res://captures/`) ; idem probable pour `rue_notifs` (`l6_rue_relecture.png`).
- M3 : téléphone : « Liquidé : la bourse l'a rui… » (étape de Jean-Mi) et « 5 000 F de plus enga… » (légende de la barre « Renforcé ») coupés par des points de suspension.
- M4 : krach au téléphone : la phrase « Seuls le 16 et le 19 sont des chiffres d'archives » est omise (voulu par `docs/24` §2.4, « ENVIRON » reste) ; le niveau de certitude C n'est alors dit nulle part sur ce format.
- M5 : pendant un saut, une notification persistante (★ de Jean-Mi, message du banquier) passe par la forme compacte d'une ligne et disparaît après ≈ 3 s comme les autres (`_notifier_compacte` ignore `persistant`) ; elle reste dans l'historique et le badge. À ×1 elle reste jusqu'au toucher (testé). Le contrôle du développeur (`persistante=reste`) porte sur une notification fabriquée hors saut.
- M6 : écran de fin au téléphone (`l6_fin_rue_negatif_tel`) : la réplique, l'argent mis de côté et la pastille d'écart sont sous la ligne de flottaison (défilement, ligne coupée en bas de la zone) ; défilement tactile non vérifié.
- M7 : au tout début de partie, les graduations « 20 000 F / 10 000 F » de la courbe de « Mon argent » se superposent (préexistant). Notification kiosque : titre « LA GAZETTE » répété.

### 6. Non vérifié
Vrai téléphone et défilement tactile ; partie jouée à la main par un humain (durée ressentie, lecture) ; animations en mouvement ; `capture_ville.ps1` sur `main` pour comparer ; référence `integrale` sur `main` (806,08 vs 805,93 F expliqué mais non remesuré) ; exe lancé (Smart App Control) : paquet vérifié par `--main-pack` ; sauvegarde réelle du joueur (inexistante sur cette machine).

### 7. Zones fragiles
Pile des notifications compactes (A2) ; 5 onglets de l'historique au téléphone (A1) ; textes coupés par points de suspension au téléphone (M3) ; fenêtre du krach sur formats étroits ; scénarios de capture qui écrivent dans `res://`.

### R-RUE passage 2 : 2026-11-14, branche `lot/05-interface`, HEAD 47a7d7d (5 commits de correction après 0ec70f5)

**Verdict : OK** (0 anomalie bloquante ou majeure ; mineures listées).

- **Tests** : `tests.ps1 -Recette -Delai 700` : 27 étapes, **1 105 vérifications OK, 0 KO, 0 erreur de script** (dont mon `test_recette_rue_ui` 14 OK, maintenant « propre », et `test_interface` 89 avec le nouveau contrôle des onglets).
- **A2 corrigée** : garde `is_instance_valid(p)` dans `_notifier_compacte` (hud.gd). Mon test en parties COMPLÈTES, mode saut : 4 parties de plus (actif 7 PC krach « vendre », actif 31 téléphone « renforcer », passif 31 PC, passif 7 téléphone) + la partie de `tests.ps1` : **0 SCRIPT ERROR** (avant : 2 à 3 par partie), 14 OK / 0 KO chacune.
- **A1 corrigée** : onglets courts sans icône au téléphone (« MAISON 15 », « BANQUE 18 », « GAZETTE 4 », « RUE 9 », « TOUT 46 »), police 26. Relu à l'image à 1440 × 648 et 1280 × 720 (`r2_hist_tel`, `r2_hist_tel169`) : nombres entiers, 15 + 18 + 4 + 9 = 46 = TOUT ; au PC 1080 : libellés longs avec icônes (« LA RUE 9 »).
- **M3** relue : étape de Jean-Mi « Liquidé : la bourse l'a ruiné » passe à la ligne (`r2_bloc_tel`) ; légende « 5 000 F de plus engagés » sur 2 lignes (`r2_anv_tel`), un peu serrée contre la ligne « Un seul exemple, pas une règle » et la fiche garde du papier vide en bas (cosmétique).
- **M6** relue (`r2_fin_neg_tel`) : visage plus petit, réplique de Tata remontée, visible sans défilement ; « Projets : 2 sur 2 réalisés » visible.
- **M5** : le code retourne avant le minuteur pour une notification persistante compacte (hud.gd). Vérification en situation **non concluante** : ma sonde « persistante encore affichée 5 s après en saut » ne s'est déclenchée dans aucune partie (≥ 3 notifications plus récentes ou fin de saut) ; reste à vérifier à la main.
- **M2** : correction lue dans le diff, **export non refait** (un_an_apres en paquet non revérifié).
- **Captures** : 9 étapes touchées (historique ×3, fin ×2, un_an_apres ×3, rue_bloc, rue_notifs) + 8 d'échantillon (krach_jours, carte, projet_jour_j, mon_foyer, notifs_saut, fin, historique, rue_eteinte) : toutes code 0, aucun `incoherences`, `debordements`, `sous_seuil` non nul. **Série complète non rejouée** (207 lancements, vert au passage 1 sur le même code hors 6 fichiers).
- **Périmètre des 5 commits** : `scenarios/interface.gd`, `bloc_rue.gd`, `hud.gd`, `modale_gazette.gd`, `modale_historique.gd`, `modale_releve_fin.gd`, `test_interface.gd` : tous colonne 05-I, aucun fichier logique ni ville. M1 (rue.json) inchangée, à ratifier par le chef de projet.
- Mineures restantes : M1, M4 (certitude C omise au téléphone, voulu), M7 ; légende « Renforcé » serrée ; M5 et M2 non confirmés en situation.
- Mon test a reçu une sonde de persistantes en saut (`_verifier_persistante_saut`).