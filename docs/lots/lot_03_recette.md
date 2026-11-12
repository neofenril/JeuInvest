# Lot 03 : recette du testeur

> Une section par branche et par passage. Destinataire : chef de projet.

## 03-L, passage 1 : 2026-11-12, `lot/03-logique` 2598896 (commits 4c5c162, 03c494e, 2598896 ; base 87f2d6f)

### Verdict : **OK** (0 bloquante, 0 majeure, 2 mineures, 3 points pour le chef de projet)

### Ce qui a été fait
- `tests.ps1 -Recette` lancé deux fois dans le worktree : **vert les deux fois**, 0 erreur de script, 0 `Parse Error`. 1er passage : 613 vérifications (= **584** des développeurs + 29 de recette), 80 s. 2e passage avec mon nouveau test : 625 (584 + 41), 82 s. `test_rue` génération sous le seuil les deux fois.
- Copies isolées (`git archive`, `user://` à part) de `main` 8930fc3 et de la branche : comparaison des sorties de `test_cadence`, `test_demo`, `test_logique` ; vraie sauvegarde 0.4 écrite par `main` puis relue par la branche ; captures `integrale` et `integrale_saut` des deux côtés.
- Nouveau test de recette `godot/tests/recette/test_recette_dividendes.gd` (12 vérifications ; recalcul depuis les JSON bruts, sans `Donnees` ni `Marche`).

### Critères d'acceptation
- [x] **CA-L1** : vert, 584 ≥ 551 + 33 nouvelles ; `git diff main...lot/03-logique -- godot/tests/test_interface.* godot/tests/test_partie.*` vide ; `test_interface` (33) et `test_partie` verts.
- [x] **CA-L2** : `test_dividendes` vert, et **recalcul à la main** (mon test, JSON bruts, quantités recalculées avec le courtage 1,3 % min. 50 F) sur la graine 7, 5 000 F par titre achetés en avril 1987 :

  | Titre | Qté | Cours mai 1987 | Taux (rdt 1987 3,6 % + écart) | Net (× 0,84) | Moteur |
  |---|---|---|---|---|---|
  | Elf | 18 | 254,63 F | 5,1 % | 196,35 F | 196,35 F |
  | L'Oréal | 7 | 606,43 F | 2,1 % | 74,88 F | 74,88 F |
  | Peugeot | 7 | 560,55 F | 3,6 % | 118,66 F | 118,66 F |
  | Saint-Gobain | 14 | 336,31 F | 3,6 % | 142,38 F | 142,38 F |
  | **Total** | | | | **532,27 F**, impôt **101,39 F** | notification : 532,27 / 101,39 |

  Égal au centime au compte rendu. SICAV : rien en plus ; vendu en avril : rien en mai ; `divNul` et `moisDiv` fabriqués : conformes ; plancher 0 conforme.
- [x] **Détenu au début du mois de détachement** (docs/20) : acheté en mai 1987 → rien en mai, juin, juillet ; acheté et revendu en mai → rien ; détenu en avril et vendu en mai → dividende gardé (versé à l'entrée du mois). Peugeot détenu en mai 1986 → notification `dividende_nul` (banque, neutre, sans montant, rangée dans l'historique), Elf verse seul ; Peugeot seul → nul en 1986, puis 1re vraie notification en mai 1987 avec `premier = true`. Témoins : aucun ne détient d'action en direct (`indice` = SICAV) → aucun dividende, comparaison Livret A cohérente.
- [x] **CA-L3** : `test_mois_utile` étendu vert (180 mois, écart max 0,0000 F, 5 genres dont `dividende`).
- [x] **CA-L4** : une notification par mois de versement, sans pause, `premier` et texte conformes ; textes ≤ 60 mots (`dividendes_premier` 49, `releve_avoir_fiscal` 23), aucun « → », insécables U+00A0 vérifiés dans `banque.json` (aucune espace normale avant %) ; textes = ceux du banquier (docs/21 K1, K2), 16 % lu dans les règles, jamais en dur. Phrase de l'avoir fiscal présente dans le relevé de la **1re année** seulement (1987), absente en 1988 : écart au plan (relevé au lieu de la notification) justifié par la longueur, conforme à l'option prévue par docs/21.
- [x] **CA-L5** : tests du développeur verts (sauvegarde avant mai, champs retirés, D-02L-4 : « Précondition D-02L-4 : saut actif true, 1 non lue(s) en oct. 1984 »). **Vraie sauvegarde 0.4** (écrite par le code de `main`, graine 7, `StrategieTest` actif) relue par la branche : champs absents → défauts (`{}`, faux, 0) ; sauvegarde de février 1986 → fin de partie **172 139,25 F, 869,97 F, 11 interruptions, 360,43 F de dividendes : identique à la référence d'une partie neuve** ; sauvegarde de mars 1987 → fin 172 089,54 F, 1er dividende en mai 1987 avec `premier = true` (le versement de mai 1986, passé sous la 0.4, n'est pas rattrapé : normal).
- [x] **CA-L6** : `DIVIDENDES aller_retour elf 1987-04 1987-06 gain_net=−1064,84 F` retrouvé. Décomposition (mon test) : 37 actions, cours 266,66 → 254,63 → 233,47 F ; variation −1 227,89 F, frais 128,26 + 112,30 F, dividende net + 403,61 F. **Hors variation de cours, l'aller-retour rapporte + 163,05 F pour 10 000 F (+ 1,6 %)**, conforme à l'estimation du boursier (docs/20 B3 : + 1,7 % pour Elf). Référence : actif 172 139,25 F / 869,97 F / 11 / 360,43 F ; passif 145 655,67 F / 0 F / 11 / 0 F. **`test_cadence` identique à `main`** : 98 lignes, aucune différence hors durée (913 interruptions, 11 à 13, moyenne 11,41). `test_logique` identique ; `test_demo` : seuls diffèrent le patrimoine actif (171 767 → 172 139 F), le nombre de notifications (+ 3 dividendes) et les intérêts 1988 (6 825 → 6 827 F).
- [x] **CA-L7** : aucune ligne `-func/-signal/-var/-const` retirée (seule ligne `-var` : la variable locale `n` de `Banquier.releve`, modifiée).
- [x] **CA-L8** : 11 fichiers, tous dans la colonne 03-L (`data/*.json`, `scripts/logique/{banquier,etat_partie}.gd`, `tests/test_{dividendes,mois_utile,sauvegarde}`, bases dev-logique et socle). Aucun fichier temporaire, capture ni secret. `main` a reçu depuis la base 8930fc3 (docs/20, docs/21, base du boursier) : aucun recoupement.
- [x] `partie_en_cours.sav` du joueur : **absent avant et après** la recette (rien écrit ; seuls fichiers de `user://` : `capture_reprise*.sav` d'octobre et novembre, non touchés). Dépôt principal : `git status` propre avant et après.

### Anomalies
- **m1 (mineure, consignée à la demande)** : relevé de décembre contradictoire quand il n'y a pas d'intérêts mais des dividendes. Reproduire : graine 7, joueur passif jusqu'en avril 1987, Livret A vidé, 5 000 F d'Elf, avancer jusqu'en décembre 1987 (`test_recette_dividendes`, ligne `RECETTE m1 releve_contradiction=true` ; même cas dans `test_dividendes`, relevés 1987 et 1988). Constaté : « Aucun intérêt cette année : votre argent est resté sur le compte courant. Vos actions vous ont versé 196 F de dividendes cette année, après impôt. … ». Attendu : pas de « resté sur le compte courant » quand le joueur a des actions qui ont versé (variante de `releve_sans_interets` à faire écrire par le banquier, puis dev-logique). Dans la partie `integrale`, le joueur a des intérêts : la phrase n'y apparaît pas.
- **m2 (mineure)** : la ligne `Intégrale : …` de la capture n'imprime pas les dividendes (`dividendes_recus()`), donc CA-I7 ne pourra pas les comparer (fichier de dev-interface, `scenarios/outils.gd`).

### Points pour le chef de projet
1. **Référence de la capture `integrale` (question instruite)** : la capture et la référence logique ne jouent pas la même partie. `integrale` = graine de vie de `principal` (11), réponses par l'interface (« une présentation sur deux ouverte, 25 % placés ») ; la référence de 03-L = graine 7, `StrategieTest`. Les 172 139,25 F ne peuvent donc pas sortir de la capture. Mesuré aujourd'hui (copies isolées, 1280 × 720) : **`main` : `integrale` = `integrale_saut` = 160 749 F, frais 805,93 F, 11 interruptions** (référence connue) ; **branche 03-L : `integrale` = `integrale_saut` = 161 419 F, frais 805,93 F, 11 interruptions** (+ 670 F de dividendes et de leur placement ; mêmes modales : appel 8, banque 4, courrier 2, journal 1, fin 1 ; `UI saut bilan arrets=10 sans_modale=0 fin=1 vitesses_ecarts=0` ; aucune ligne `ERROR`). Le relevé 1988 à l'écran montre « … vous ont versé 294 F de dividendes … ». Proposition : réécrire CA-I7 « `integrale` = `integrale_saut` = **161 419 F / 805,93 F / 11** (référence de capture après 03-L) » et garder 172 139,25 F pour `test_dividendes` et CA-FO1 (`StrategieTest`) ; si 03-V ou 03-foyer change le moteur, refaire la mesure.
2. Plafond facultatif du rendement de marché 1987 à 3,2 % (docs/20 B2) : non appliqué par le développeur (signalé) ; écart ≤ 0,4 point. À trancher (donnée seule, sans code ?).
3. Garde-fou D5 : avec la règle « détenu au début du mois », l'achat en avril et la revente en juin touchent toujours le dividende (+ 1,6 % hors cours pour Elf, négatif pour L'Oréal) ; le boursier recommande de ne rien changer (B3). La phrase pédagogique qu'il propose (« le cours baisse du montant du dividende le jour du détachement ») n'est pas dans les textes : à décider avec le banquier si souhaitée.

### Non vérifié
- Rendu à l'écran des notifications « Dividendes » et « Pas de dividende cette année » (toast, pièce Elf) : interface et ville, prévus en 03-I étape 2 / CA-I7 sur la branche finale ; seule la capture de fin d'`integrale` a été relue (relevé 1988 avec la phrase des dividendes, écran de fin pris pendant l'animation des chiffres, comme d'habitude).
- Vrai téléphone : sans objet pour cette partie logique.

### Incident de recette (sans effet sur le jeu)
Un de mes scripts lancés sur ma copie isolée de `main` (lecture de sauvegarde appelant `dividendes_recus`, absente de `main`) s'est arrêté sur une erreur de script sans quitter : deux processus Godot (PID 7136 et 1748, ligne de commande `…scratchpad\testeur_l03_main\godot … testeur_l03_sav.gd -- lire …`) restent ouverts, inactifs, sur ma copie à part (aucun accès à `partie_en_cours.sav`). L'arrêt m'a été refusé par le garde-fou ; le coordinateur peut les fermer.
