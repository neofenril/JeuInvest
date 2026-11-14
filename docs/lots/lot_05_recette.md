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
