# Recette du lot 10b-interface, étape 2 (chapitre 1989 réel)

## Passage 1 : 2026-11-25, branche `lot/10b-interface`, commit testé bc61e1e (contient lot/10a-contenu et 10a bis)

**Verdict : KO** (1 anomalie majeure : A1, régression de la barre haute en 1984-1988 au téléphone 1280 × 720). 7 mineures.
Recette allégée (décision du joueur du 2026-11-17) : tests complets, étapes ciblées, périmètre. Série de captures complète non lancée (prévue avant l'export 0.7, après le pilote 10c).

### Méthode
- Tests : worktree du développeur, `tests.ps1 -Recette -Delai 700` (import propre). Captures : deux copies isolées (`git archive` de `main` et de bc61e1e, `user://` à part), formats PC 1920 × 1080, téléphones 1440 × 648 et 1280 × 720, par `capture_interface.ps1`. Images relues une à une.
- Partie du joueur : `partie_en_cours.sav` inchangé (SHA-256 0EFB110DAC59…), `records.sav` absent avant et après ; dépôt principal : seul `PromptInitial.txt` non suivi (préexistant) ; worktree du développeur propre.

### 1. Tests automatiques : VERT
`tests.ps1 -Recette -Delai 700` : **47 étapes, 1 718 vérifications OK, 0 KO, 0 erreur de script, TOUT EST PROPRE** (1 178 s ; test_reference_1984 35 OK, test_interface 156, test_chapitre_1989 36, test_10a_bis 17). Aucun test instable observé (dev-logique faisait tourner Godot en parallèle ; rien à relancer).

**Contournement « choix du départ ignoré en capture et en headless » : ne masque rien.** `principal._demander_depart` ne saute le choix que si `ScenariosCapture.mode_capture()` (argument `--capture`) ou `DisplayServer.get_name() == "headless"` ; un joueur humain (fenêtre, sans `--capture`) passe par le choix. Preuve : mon test `test_recette_depart` (fenêtre réelle, `principal.tscn`, `user://` isolé ; copie dans le scratchpad, non déposé car il ne compile pas sur `main`) : **11 OK** : JOUER ouvre le choix (2 cartes), carte 2 = chapitre 1989, janvier 1989, fin 12/1993, pop-up de Christine sans « Gérard » ni « Sylvie » ; NOUVELLE PARTIE ouvre le choix, carte 1 = 1984 (fin 12/1993) ; RETOUR : on reste au titre sans modale. « Continuer » (`_reprise`) saute le choix (lecture du code).

### 2. 1984-1988 inchangé (étapes ciblées contre `main`)
Comparaison pixel (1 pixel sur 4, seuil 40) de `carnet`, `fin`, `hud`, `jouer`, `krach` × 3 formats :
- `carnet` : panneau de la banque identique à `main` (relu en 1280 × 720) ; seules différences : frise (10 ans, voulue) et, en 1280 × 720, la barre haute (A1).
- `jouer`, `krach`, `hud` : PC et 1440 × 648 identiques aux animations et à la frise près (0,15 à 1,2 %). Date à volets : animation d'origine retrouvée (initiale « SEPT 1986 » comme avant 10b, repliée vers la date de départ ; rien de visible fixe).
- **1280 × 720 : régression (A1).**
- `fin` : **ne montre plus la fin de 1988** : la partie 1984 va maintenant jusqu'en 1993, l'étape s'arrête sur la carte de passage de janvier 1989 (A2). La fin de 1988 n'existe plus ; le bilan est contrôlé par `fin_1993`.
- `test_reference_1984` : fichier inchangé par rapport à `main`, vert.

### 3. Captures `l10_` (vraies données 1989)
Toutes les étapes demandées × 3 formats (PC, 1440 × 648, 1280 × 720), code 0 : `debordements=0 hors_cadre=0 hors_ecran=0 sous_seuil=0` partout (46 lignes), `frise_10ans mois=120 coupures=1`, `carnet_13 cartes=13` (4 colonnes au PC, 3 colonnes avec défilement au téléphone), `passage titre=JANVIER 1989 valeurs=["125 951 F","- 10 %","2e sur 4"]`, `fin_1993 plaques=2 records=["nouveau","nouveau"]`. Relu :
- `frise_10ans` / `mon_argent_10ans` : rail 1984-1993, coupure à 1989, drapeau ; courbe sur toute la durée ; lisible aux 3 formats.
- `intro_christine` : portrait de la joueuse (3 humeurs dessinées, neutre ici), « Vous êtes Christine, 34 ans… mariée à Patrick… », COMMENCER dans l'écran, zone défilante au téléphone (dernier bloc atteignable). Frise à partir de 1989.
- `passage_1989` : chiffres identiques à `contenu_modale()` (ligne `UI passage`), aucun titre révélé (« Votre titre d'époque 1984-1988 vous attend au bilan final. »), CONTINUER seul bouton ; PC et téléphones.
- `vitrine_golfe` : courbe de 3 points (1 950 / 1 640 / 1 470), mention « Fins de mois seulement… », 2 choix ; texte de bilan cohérent avec « fin août : −17 558 F ». `golfe_un_an_apres` : 3 barres lisibles (voir A4).
- `fin_1993` (relu à 3 s d'animation, 228 944 F, Tata 264 381 F, écart 35 438 F, −13 %) : 2 plaques (1984-1988 « Le neveu de Tonton Matelas », 1989-1993 « Le Spartiate du Minitel »), 2 lignes de record, courbe « Dix ans en un coup d'œil ». Au téléphone, une seule zone défilante, boutons visibles.
- `titre_palmares_v2` : 3 lignes de record (départ 1984, partie jusqu'en 1993, départ 1989), TITRES 3 / 18, rien ne déborde. `collection_chapitres` : 2 onglets (1984-1988, 1989-1993), « 2 SUR 9 OBTENUS ». `choix_depart` : 2 cartes + RETOUR, focus sur la 1re.
- `fiche_scpi` : ligne SCPI = valeur de revente (5 parts = 4 500 F, 900 F la part) ; `vente_differee` : « Vente en cours : 2 parts, exécution en novembre 1992 » (août + 3 mois), bouton ANNULER, boutons de vente adaptés. `fiche_pea` : « 4 950 F dans le PEA, dont 3 064 F en espèces » (= 3 064 + Elf 1 886), plafond 600 000 F, avertissement de retrait avant 5 ans, ordres par ligne. `pep_en_savoir_plus` : fiche sans bouton d'achat (« Relire la présentation » en haut à droite).
- Cohérence des chiffres : écrans cohérents entre eux (patrimoine / écart de la barre haute, carte de passage, bilan). Écart d'1 F entre « Tata 264 381 F » et « 35 438 F » : arrondi préexistant (main : 173 035 − 163 131 = 9 904, affiché 9 903).

### 4. Barre haute : A1 (voir ci-dessous). PC et téléphone 1440 × 648 : sans effet en 1984-1988 (images identiques, `replis` inchangés).

### 5. Textes
Aucun « Lefranc / Sylvie / Gérard / Monsieur / il-elle / 1984-1987 » en dur dans les lignes ajoutées de `scripts/ui/`, `principal.gd` (seulement des commentaires) ; « SEPT / 1986 » = valeurs initiales de la date à volets (jamais affichées fixes). Une phrase en dur sans prénom : « Votre titre d'époque … vous attend au bilan final. » (`modale_passage.gd` l. 39), les années viennent de `Noms.annees_chapitre`. Longueurs : textes de fiche et notifications dans les limites visibles (aucun débordement, pas de texte coupé relevé).

### 6. Légende « au krach : … » du Golfe : voir A4 (mineure).

### 7. Périmètre
Fichiers modifiés par rapport à la base 10a : tous dans la colonne interface (`scripts/ui/*`, `principal.gd`, `scenarios/interface.gd`, `capture_interface.ps1`, `test_interface.gd`, base `dev-interface.md`), sauf `godot/data/pixel/ui/portraits_f.txt` et `portraits_h.txt` (colonne « data/pixel/** » = ville au tableau du plan ; mais les portraits sont une tâche de l'interface au §1 bis : écart de forme, mineur). `principal.gd` : 750 lignes (709 sur `main`, plafond du plan 650 : dépassement préexistant, +41). Rien d'inattendu (pas de capture, secret ni fichier d'`outils/`).

### 8. Sauvegarde et records
`tests.ps1` : « Sauvegarde du joueur inchangée », « Records du joueur : inchangés (absents) ». Format de sauvegarde non touché par cette branche (pas de fichier `logique/sauvegarde*` modifié par l'interface).

### Anomalies
**A1 (MAJEURE) : barre haute à 1280 × 720 en 1984-1988 : « VS LIVRET A » et « COMPTE » disparaissent, chiffres réduits, dès janvier 1984.**
- Reproduire : `capture_interface.ps1 -Etape jouer -Taille 1280x720 -Telephone169` (ou `hud`) sur `main` puis sur la branche ; comparer `UI barre` (étape `hud`).
- Attendu (`main`) : `replis=libelle_courrier,pause`, marge 34, libellés « COMPTE » et « VS LIVRET A » visibles (comparaison au Livret A permanente, demande du joueur). Constaté : `replis=libelle_courrier,pause,titre_livret_cache,titre_cc_cache,chiffres_reduits` ; en janvier 1984 (12 629 F) le bouton n'affiche plus que « = 0 F » sans titre, le montant du compte est en petit, la barre se décale (boutons de temps 25 px plus à droite). Captures : `cmp_main_jouer_tel169.png` / `cmp_br_jouer_tel169.png`, `cmp_*_hud_tel169.png` (dossiers `captures/` des copies isolées du scratchpad).
- Cause probable : `_replier_barre` mesure `trop` avec le badge « EN PAUSE » visible (pire cas, marge_avec_badge −95 sur `main` aussi) ; le repli « pause » ne fait que poser un méta, le badge reste compté, donc `trop` reste vrai après `libelle_courrier` et `pause` et les trois nouveaux replis (`titre_livret_cache`, `titre_cc_cache`, `chiffres_reduits`) se déclenchent à tout moment, même avec 5 chiffres. Le plan (`lot_10b.md`) et la demande du chef de projet exigent « sans effet en 1984-1988 » ; CA-I1 non respecté à ce format. Le 1280 × 720 est un format de test du projet. 1440 × 648 et PC : non touchés. En 1991-1993 (6 chiffres) le repli est voulu et lisible (`l10_frise_10ans_tel169.png`).
- Piste (pour le développeur, via le chef de projet) : ne déclencher les nouveaux replis que si la largeur manque réellement hors pire cas, ou mesurer après avoir retiré le badge replié ; rejouer ensuite `jouer`, `hud`, `krach` en 1280 × 720 contre `main`.

Mineures (n'empêchent pas un OK) :
- **A2** : l'étape `fin` n'affiche plus l'écran de fin de décembre 1988 (la partie 1984 dure jusqu'en 1993 ; l'étape s'arrête sur la carte de passage). CA-I1 « fin identique à main » non vérifiable ; la fin est couverte par `fin_1993`, `fin_titre`, tests. À signaler au chef de projet pour la série complète (étape `fin` à reformuler).
- **A3** : donnée de 1984 `chapitre.json > titre > sous_titre` = « Démonstration · janvier 1984 – décembre 1988 · Gérard, 26 ans », affichée sur l'écran titre et sur la carte du choix du départ, alors que la partie 1984 va jusqu'en 1993 (et que les lignes de palmarès disent « partie jusqu'en 1993 »). Donnée du moteur (colonne logique, lot 11 ?), non corrigeable par l'interface.
- **A4** : la fiche « un an après » du Golfe garde la légende fixe « au krach : 2 000 F » (`modale_gazette.gd` l. 104) au lieu d'un repère propre au Golfe (« en septembre 1990 »). Compréhensible mais faux en mot ; mineure.
- **A5** : « REJOUER AUTREMENT » (`sequences._sequence_fin` → `nouvelle_partie()` + `demarrer_direct`) relance toujours le chapitre par défaut (1984, Gérard), sans choix, même pour une joueuse partie de 1989 ; acceptable jusqu'au lot 12 (écran de création), à noter.
- **A6** : PEP : phrase technique visible du joueur, « Présenté par un message : pas de fiche jouable. » (répétée dans la fiche et en légende) ; SCPI : « elle vaut 900,00 F » avec décimales alors que les autres montants n'en ont pas.
- **A7** : `principal.gd` 750 lignes (> 650, préexistant à 709) ; portraits dans `data/pixel/ui/` (colonne ville du tableau).
- **A8** : bilan 1440 × 648 : « (− 13 / %) » coupé sur deux lignes (le « % » orphelin) dans le cartouche d'écart.

### Critères d'acceptation (lot_10b.md §5)
- CA-I1 ★ 1984-1988 inchangé : **échoué** à 1280 × 720 (A1) ; PC et 1440 × 648 vérifiés ; `fin` non comparable (A2).
- CA-I2 ★ frise et « Mon argent » sur 120 mois : vérifié (3 formats, 0 débordement, 1920 × 1009 non rejoué : non vérifié).
- CA-I3 ★ carnet à 13 produits : vérifié.
- CA-I4 ★ carte de passage : vérifié (chiffres == `contenu_modale()` via `UI passage`, pas de titre, un seul bouton).
- CA-I5 ★ vitrine (3 points, mention fixe) : vérifié ; « étape 1 sans pause » : couvert par `test_interface` (non rejoué en image).
- CA-I6 ★ bilan 1984 → 1993 : vérifié (2 plaques, 2 records, courbe) ; cohérence avec `Records.lire` par `test_recette_fin_titres` (25 OK, `records.sav` isolé).
- CA-I7 ★ PEA / SCPI / PEP : vérifié (vente différée, ANNULER, valeur de ligne SCPI, PEP sans achat).
- CA-I8 ★ choix du départ : vérifié par mon test fenêtré (11 OK) ; « Continuer » sans choix : lecture du code seulement.
- CA-I9 ★ `tests.ps1 -Recette -Delai 700` vert : **oui** (1 718) ; périmètre : conforme (A7) ; `principal.gd` ≤ 650 : **non** (préexistant, A7).

### Non vérifié
Vrai téléphone ; ressenti en mouvement ; 1920 × 1009 ; défilement tactile de l'écran de fin ; série de captures complète (prévue avant l'export 0.7) ; reprise d'une ancienne sauvegarde de joueur (hors périmètre 10b-interface, couverte par la recette 10a).

### Ce qu'il faut pour un OK
Corriger A1 (et rejouer `jouer`, `hud`, `krach`, `carnet` en 1280 × 720 contre `main` : 1984-1988 identique), puis relancer `tests.ps1 -Recette -Delai 700`. Les mineures peuvent suivre (A3 est une donnée : à confier à la logique avant l'export).

---

## Passage 2 : 2026-11-25, branche `lot/10b-interface`, commit test� ce53600 (correctifs de recette)

**Verdict : OK** (0 bloquante, 0 majeure ; mineures restantes ci-dessous).

- **Tests** : `tests.ps1 -Recette -Delai 700` : 47 �tapes, **1 718 v�rifications OK, 0 KO, 0 erreur de script**. Le script signale un � �chec � : `test_sauvegarde_9396.sav` rest� dans `user://` ; le fichier date du **17/11/2026** (vestige d'une ancienne session, jamais supprimable par moi : garde-fou) et son num�ro 9396 a co�ncid� avec le pid d'un test de ce passage : faux positif, non d� au lot (test_sauvegarde 10 OK ; sauvegarde et records du joueur inchang�s). � purger par le coordinateur.
- **A1 corrig�** : 1280 � 720, `UI barre � replis=libelle_courrier,pause`, `marge=34 marge_avec_badge=-95` (identique � main, `hud`) ; `jouer`, `hud`, `krach`, `carnet` contre main : plus aucune diff�rence dans la barre haute (bandeau y < 100 identique) ; seule la frise du bas diff�re (1984-1993, dur�e par d�faut � 10 ans, voulue) et les animations (0,2 � 1,2 %). PC et 1440 � 648 : identiques � main hors frise et animations (confirm�).
- **A2 corrig�** : �tape `fin_1988` : �cran � D�cembre 1988 � cinq ans de la vie de G�rard � (titre, rue, courbe, 151 926 F, �cart -15 082 F), 0 d�bordement aux 3 formats.
- **A4 corrig�** : � avant la baisse : 2 000 F � pour le Golfe (l�gende � au krach � conserv�e seulement pour un titre contenant KRACH, lecture du code).
- **A5 corrig�** : mon test fen�tr� : partie 1989 termin�e puis `nouvelle_partie()` (REJOUER AUTREMENT) -> chapitre 1989 (D1 OK) ; les 7 v�rifications du choix du d�part restent OK.
- **A6 corrig�** : fiche PEP � Ce plan ne s'ach�te pas ici : votre banquier vous en parle par un message. � ; SCPI � elle vaut 900 F �, montants ronds.
- **A8 corrig� en partie** : � % � ne tombe plus seul ; au t�l�phone 1440 � 648 la coupure se fait d�sormais apr�s � (� � (� 13 %) � � la ligne suivante) : mineure r�siduelle.
- **Mineures restantes** : A3 (sous-titre 1984 � � d�cembre 1988 � sur l'�cran titre et le choix du d�part ; donn�e, non corrig�e, trait�e � part) ; A7 (portraits dans `data/pixel/ui/` : exception de p�rim�tre � ent�riner par le chef de projet ; `principal.gd` > 650 lignes pr�existant) ; A8 r�siduelle.
- Non v�rifi� : vrai t�l�phone, 1920 � 1009, s�rie de captures compl�te (avant export 0.7).
