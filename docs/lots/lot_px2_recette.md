# Recette du lot PX2 (dev-interface)

## Passage 1 : 2026-11-03, branche `lot/px2-interface`, commit testé c890d61 (a24f817 → c890d61, 16 commits, base 243bb82)

**Verdict : KO** (4 anomalies majeures, 9 mineures). La branche est propre sur le plan technique : tests, série de captures, T16, T9, périmètre, partie complète et sauvegarde sont bons. Le KO vient de la relecture des images : le panneau « Mon argent » déborde sur la frise, des montants sont écrits en Pixelify, la flèche « MA BANQUE › » est cachée à la fusion avec PX1, et l'interface ne tient pas sur les vrais téléphones courants.

### Ce qui a été lancé
- `tests.ps1` depuis le worktree : **7 étapes, 334 OK, 0 KO, 0 erreur de script, 38,9 s** (279 sur `main` à la base 243bb82, plus 55 de `test_ecran`). Import propre. Recette du lot 01 (`-Recette -Filtre recette`, avec et sans `-Joueur`) : 11 OK sur 11 dans les deux cas, sans adaptation (seul `_on_choix_journal` est utilisé, et il est resté dans la façade).
- `capture_interface.ps1 -Serie` : **61 lancements, 0 échec, aucune erreur de script**, 2 montages écrits, sauvegarde du joueur inchangée. Les fps et les sorties de `clic_dehors` ne sont pas dans le journal : relancés à la main.
- Copies isolées (`git archive` + `user://` à part) de `main`, de la branche, de a24f817 (T16), de d7bf431 (T9), de T16 sans le correctif, et de la fusion simulée `main` a74a202 + PX2 + PX1 **48ecd10** (worktree jetable, puis supprimé). Deux copies de la branche ont reçu un téléphone simulé plus petit (1440 × 648 et 1200 × 540) pour imiter de vrais téléphones (voir M4).
- PX1 a avancé pendant la recette (7733938, 4 commits de corrections). `merge-tree` avec PX2 : aucun conflit, aucun fichier en commun. Cette version n'a pas été rejouée à l'image.

### Critères d'acceptation
- [x] **CA-I1** : 334 ≥ 279 + `test_ecran`. `test_interface` passe par `zone_droite()` / `bouton_valider()`, et le scénario `integrale` aussi.
- [x] **CA-I2** : `courrier_relu_echap` rend le code 0, sans erreur, avec `UI vol_enveloppe echap_ignore=oui fermee=oui` et `UI echap_courrier relu=true fermee=oui`. **J'ai vérifié que l'étape reproduit bien le défaut** : sur la copie a24f817 avec le `modales.gd` d'avant le correctif, on obtient `SCRIPT ERROR … 'visible' … on a base object of type 'Nil'` en `modales.gd:589`. Avec le correctif, plus rien.
- [x] **CA-I3** : `modales.gd` fait 294 lignes (1 453 avant). Morceaux au commit T9 : banquier 294, journal 275, historique 242, courrier 220, relevé et fin 208, simples 100, outils 96 (tous ≤ 450). Captures 1280 × 720 avant (a24f817) et après (d7bf431), 1 pixel sur 2, seuil 40 : `presentation_livret` 0,025 %, `journal` 0,014 %, `courrier` 0,102 %, `historique` 0,013 %, `fin` 0,063 % (tous ≤ 0,5 %). `test_interface` donne 21 OK sur d7bf431.
- [x] **CA-I4** : `test_ecran` 55 OK. Valeurs justes, **mais voir M4** : sur mobile, T ne dépend que du dpi.
- [x] **CA-I5** : `planche_cadres` donne T = 2 à 720p et à 1366, T = 3 à 1080p et au téléphone, avec `irreguliers=0` partout (36 254 blocs). Planche relue : 19 cadres et 16 icônes nets.
- [x] **CA-I6** : `cibles` a 720p, 1366 et au téléphone : `sous_seuil=0` sur les 15 écrans. Minimum 48 px physiques à 720p, 81 au téléphone.
- [x] **CA-I7** : HISTORIQUE fait 96 × 254 px à 1080p comme au téléphone, `recouvert=non` panneau ouvert et fermé (64 × 169 à 720p et à 1366). `hud_focalisables=0` : A6 réglé côté interface.
- [ ] **CA-I8** : la recherche ne trouve aucune `SystemFont` ni `Color("#`. `pixelify_min=28`, `atkinson=oui`, `polices_jeu` sans glyphe manquant. Contrôle des glyphes des 4 polices sur tous les caractères non ASCII des données et des scripts : seuls « → ← ▲ ▼ ○ ● » manquent (tous remplacés ou dessinés). **Échoue sur M2** : des montants sont en Pixelify.
- [ ] **CA-I9** : `debordements=0` partout, mais la relecture des images montre M1, m1 et m2. Le contrôle ne voit ni les conteneurs qui débordent ni les textes à retour à la ligne.
- [x] **CA-I10** : les 46 captures sont relues. On retrouve l'habillage du §3 : papier crème, coin corné, liseré, portrait pixel, ticket dentelé, page de Gazette, classeur à onglets avec compteurs (4 + 23 + 2 = 29), carnet pixel, cadres sombres. Les montages `px2_montage_pc` et `px2_montage_carte` sont écrits. Les défauts sont listés plus bas.
- [x] **CA-I11** : `clic_dehors` ferme le foyer, les nouvelles, la banque, le menu et la carte (« pas maintenant ») ; le journal reste ouvert. `integrale` sur la branche : 156 645 F, frais 273,60 F, 11 interruptions (= référence d'avant 02-L). `sauver_fermer` puis `reprise` : CONTINUER, juillet 1984, D02, 17 228 F. Raccourcis : 2, Espace, M et H marchent ; F8, F6, F10 et le triple toucher sont actifs en test et sans effet avec `--joueur`. Échap est vérifié par CA-I2. Les touches 1, 3, P et B ne sont pas rejouées (leur code dans `principal.gd` n'a pas changé).
- [ ] **CA-I12** : avec la ville de `main`, les étiquettes sont sur la chaussée comme avant. **Fusion avec PX1 : échec (M3).** Les étapes `etiquettes_bord` et `etiquettes_aller` n'existent pas ; j'ai vérifié avec `rue`, `rue_gazette` et `rue_banque`.
- [x] **CA-I13** : 259,6 images/s à 1080p et 352,9 au téléphone.
- [x] **CA-I14** : les 62 fichiers du diff relèvent tous du §1. Dans `project.godot`, seul `config/version="0.3"` change : l'échelle est réglée à l'exécution (`content_scale_mode = DISABLED`, facteur T/3). `scripts/pixel/ui/` est vide. `papier.gdshader` est supprimé et plus rien n'y fait référence. `Voir_PX0.bat -- --px0-quitter-apres=5` rend le code 0, et la vitrine en console aussi, sans erreur (crochet `ResourceLoader.exists`). Aucun membre public retiré de `Style`, `Hud`, `EcranTitre`, `Piece`, `PanneauBanque` ou `CarteProduit`. De `Modales`, seule la constante `NOMS_SOURCES` disparaît, et personne ne l'utilise.
- [x] **CA-I15** : `partie_en_cours.sav` garde le SHA-256 E2B314A8… avant et après toute la recette. Mes dossiers `user://` isolés sont effacés.

### Fusion simulée (`main` a74a202 + PX2 c890d61 + PX1 48ecd10)
- Aucun conflit. `tests.ps1` : **10 étapes, 447 OK** (392 + 55), 0 KO, 0 erreur, 46,9 s.
- `integrale` : **160 749 F, frais 805,93 F, 11 interruptions, fin décembre 1988** (= référence de `main`).
- Rue de PX1 avec la nouvelle échelle de l'interface : `rue_libre --controle` donne `irreguliers=0` à 1080p, 720p, 1366 et au téléphone (facteur 2, réductions 1 / 0,667 / 0,711 / 0,667). Aucune régression de netteté.
- **A8 (Jean-Mi sous le panneau) n'est pas résolu** : `point_tete jeanmi=1470` alors que `rect_libre` s'arrête à 1396. Il est invisible sur `f_voisins_1080` (voir m6).

### Anomalies
1. **M1 (majeure, régression) : le panneau « Mon argent » est plus haut que la place disponible.** Dans `hud.gd`, `offset_bottom = -BAS - 12` vise y ≈ 954 à 1080p, mais le contenu (courbe, répartition, ce mois-ci, coussin, frais, bouton) étire le panneau jusqu'à y ≈ 1010. Or la frise PX2 (`BAS` = 114) commence à y ≈ 966.
   - Étapes : `capture_interface.ps1 -Etape hud -Taille 1920x1080`, ou `px2_hud_1080`, `px2_pause_1080`, `px2_hud_720`.
   - Constaté : en 1988, l'année, le curseur du mois et le drapeau de la frise sont cachés sous le panneau, alors que le panneau est ouvert par défaut sur PC. Sur `main`, la frise reste libre (vérifié).
   - Au téléphone (`px2_panneau_tel`, `px2_releve_tel`), « Actions 5 % » sort du cadre et s'écrit sur le bord de la frise.
   - Dans une fenêtre de **1920 × 1009** (1080p fenêtré avec la barre des tâches, le cas PC le plus courant ; T = 3 grâce à la tolérance), le bouton « BANQUE · carnet et guichet » est coupé par le bas de l'écran. Capture : copie isolée `hud_1920x1009.png`.
   - À 1366 × 768 (zone 2049 × 1152), tout tient.
2. **M2 (majeure) : des montants sont écrits en Pixelify, dont le « 5 » se lit S.** C'est contraire à la décision du joueur du 29/10 (« chiffres et textes longs dans une police nette ») et à la base de dev-interface (« jamais pour des chiffres »). Exemples :
   - CHAQUE MOIS : « 300 F / **S00 F** / 1 000 F », le montant choisi lui-même (`px2_automatique_1080`, `_tel`) ;
   - ordre : « 10 % / **2S %** / **SO %** » et le bouton de validation « **ACHETER POUR 9S3,68 F** » (`px2_banque_ordre_tel`) ;
   - courrier : « PAYER 8 139 F ».
   Le contrôle `atkinson=oui` ne lit que les chiffres du HUD. Les boutons qui portent un montant doivent être en Atkinson.
3. **M3 (majeure, à la fusion avec PX1) : la flèche de bord de la banque est invisible.** `placer_etiquettes` pose la flèche de droite à `largeur − taille − 12`, sans tenir compte de `rect_libre()`.
   - Constaté : à 1080p (`f_rue_1080`), « MA BANQUE › » est sous le panneau « Mon argent ». On n'en devine que le fantôme. Au téléphone (`f_rue_tel`), « MA BAN… » est coupé par la languette. Or au repos la caméra est sur la maison et la banque est hors champ (`etiquette banque visible=non`) : le joueur ne voit pas le chemin vers la banque.
   - Même cause en bas : au téléphone, `rue_gazette` place « LA GAZETTE » à y = 605, sous la frise (qui commence à 606), donc invisible. C'est A2 de PX1, qui n'est pas compensé côté interface.
   - Attendu (§2.4, CA-I12) : la flèche se voit à l'intérieur du rectangle libre et, touchée, fait glisser la caméra.
   - Le toucher sur la flèche (`aller_vers`) n'est pas vérifié, faute d'étape `etiquettes_aller`.
4. **M4 (majeure, écart entre le plan et les vrais téléphones) : sur un téléphone courant, l'interface ne tient pas à l'écran.** Sur mobile, `facteur_texel_pour` ne dépend que du dpi. Exemples :
   - 2400 × 1080 à 400 dpi : T = 5, zone **1440 × 648** ;
   - 2340 × 1080 à 395 dpi : 1404 × 648 ;
   - 2400 × 1080 à 480 dpi : T = 6, zone 1200 × 540 ;
   - 1280 × 720 à 320 dpi : zone 960 × 540.

   Ces zones sont plus petites que le téléphone simulé du plan (1600 × 720 à 267 dpi), qui est un téléphone peu dense et peu représentatif. Je les ai simulées avec une copie dont `FENETRE_TELEPHONE` vaut 1440 × 648 ou 1200 × 540 (même zone logique, cibles à 80 px virtuels) :
   - à 1440 × 648, la fenêtre d'ordre déborde (`fenêtre hors écran … S: (1412, 641)`) et le bouton « ACHETER POUR … » sort de l'écran : impossible de valider un achat ;
   - à 1200 × 540, la carte du banquier, le carnet, l'ordre et CHAQUE MOIS sortent de l'écran (la carte de l'héritage est coupée en haut et en bas), et le panneau « Mon argent » déborde davantage.

   L'ancienne zone du téléphone (1412 × 635, facteur 1,7) était proche de ces vraies valeurs. PX2 a agrandi les éléments et validé sur une zone plus grande. C'est un risque bloquant pour l'APK 0.3.
5. **m1 (mineure, régression) : la notification persistante « Un mot après le krach » a sa dernière ligne coupée** : « … (rangé dans l'historique » sort du cadre à droite (`px2_courrier_1080`). Elle tenait sur `main`.
6. **m2 (mineure, préexistante) : dans le carnet, le cadenas et le calendrier recouvrent des chiffres** : « 11 % cette a█ée », « ≈ 8,25 % fix█ », et le « F » de « 17 284 F » sous le calendrier au téléphone (`px2_carnet_tel`, `px2_f01_tel`). Le défaut existe déjà sur `main`.
7. **m3 (mineure, écart déclaré) : « › » remplace « → ».** Les textes restent justes et compréhensibles :
   - « janvier 1984 › décembre 1988 » (titre) ;
   - « 12 600 F › + 945 F par an, sans impôt » (ticket) ;
   - « 6 000 F › 19 actions à 310 F » (historique).

   Mais « › » est un guillemet, pas une flèche. Le remplacement ne passe que par `Style.label`, alors qu'il y a 46 affectations directes de `.text` dans `scripts/ui/`. Aucune ne porte « → » aujourd'hui (vérifié), mais c'est fragile. Les données (`banque.json`, `demo.json`) ne sont pas modifiées : c'est conforme au périmètre.
8. **m4 (mineure) : une fenêtre de moins de 648 px de haut donne T = 1.** L'interface s'affiche alors au tiers et devient illisible (fenêtre 1280 × 640 : HISTORIQUE fait 32 px). La tolérance de 10 % est en soi acceptée : elle évite ce cas à 1366 × 768 fenêtré (≈ 697 px de haut).
9. **m5 (mineure, contenu) : la carte du Livret A coupe la ligne entre « 7,5 » et « % » à 1080p.** C'est une espace normale dans le texte du banquier, révélée par la nouvelle mise en page. Il faut une espace insécable (côté logique ou données).
10. **m6 (mineure, A8 transmis) : Jean-Mi passe toujours sous le panneau.** PX2 n'a ajouté que la ligne `UI panneau rect=… rect_libre=…`. Cette ligne affiche `rect=replié` même à 1080p, panneau ouvert, sans doute parce qu'elle est imprimée pendant l'animation de bascule.
11. **m7 (mineure) : quelques textes Atkinson sont à 16 px virtuels**, sous le minimum de 20 de docs/16 §3.1 : « * espéré, jamais garanti… », « Touchez pour voir le détail des frais ».
12. **m8 (mineure, outillage) : la série ne journalise pas tout ce que le plan demande de lire.** `px2_serie.log` n'enregistre ni les fps (CA-I13 n'est pas vérifié automatiquement) ni les lignes de `clic_dehors`. Le contrôle `debordements` ignore les conteneurs plus hauts que leur place (M1). Les étapes `etiquettes_bord` et `etiquettes_aller` du plan (CA-I12, §7) manquent.
13. **m9 (mineure, hors périmètre, logique) : le relevé affiche « 417 F + 42 F = 458 F »**, à cause des arrondis (`px2_releve_*`). Le défaut existe déjà sur `main`.

Écarts déclarés, acceptés :
- en-tête « BANQUE DE LA RUE » sans adresse ;
- tampon droit, sans la rotation de −2° : c'est cohérent avec « pages droites au repos » ;
- tolérance de 10 % sur T (sauf m4).

### Non vérifié
- Vrai téléphone : dpi réel, défilement tactile du classeur, confort des cibles. M4 est calculé et simulé, pas vu sur un appareil.
- Écrans 1440p et 2160p réels (calculés par `test_ecran`).
- Toucher la flèche de bord pour appeler `aller_vers`.
- Touches 1, 3, P et B rejouées.
- PX1 7733938 à l'image.

### Questions au chef de projet
1. M4 : faut-il remplacer ou compléter le téléphone simulé par un téléphone représentatif (2400 × 1080 à 400 dpi, soit une zone de 1440 × 648) dans le plan et dans la série ? Ou bien plafonner T sur mobile pour garder une zone d'au moins 1600 × 720, en acceptant des cibles un peu sous 48 dp ?
2. M1 : faut-il alléger le panneau « Mon argent », le rendre défilant, ou réduire la frise ?
3. M3, A2, A8 : qui garde les étiquettes, les flèches et les bulles dans le rectangle libre ? PX2 (`placer_etiquettes` borné par `rect_libre()`) ou PX1 (`point_etiquette`, `point_tete`) ?
4. m3 : flèche en sprite dans le texte, ou réécriture des données par dev-logique (« à », « : ») ?
5. m4 : faut-il un T minimal de 2 sur PC ?

## Passage 2 : 2026-11-06/07, branche `lot/px2-interface`, commit testé 5d23c3b (corrections C1-C9, `main` fusionné : 79a57f0 PX1 + 02-L, 79b2444 F1-L)

**Verdict : OK** (0 bloquante, 0 majeure, 5 mineures). M1 à M4 sont corrigés et vérifiés à l'image. Je recommande le push de la branche.

### Ce qui a été lancé
- Base : `main` ae19d02 (F1-L) est dans la branche. Le seul commit de `main` qui n'y est pas, dfd5ca4, ne touche que `docs/` (4 fichiers, aucun en commun avec la branche).
- `tests.ps1` depuis le worktree : **11 étapes, 491 OK, 0 KO, 0 erreur de script**, import propre. `test_ecran` passe de 55 à 90 vérifications (CA-C1 : ≥ 20 nouvelles).
- `capture_interface.ps1 -Serie` : **106 lancements, 0 échec, 0 SCRIPT ERROR**, 3 montages écrits, sauvegarde du joueur inchangée pendant la série. Godot reste bloqué à la sortie 2 fois (`pause_tel169`, `historique_tel169`) : l'image est enregistrée et les contrôles sont imprimés. Ce blocage vient de la rue PX1 et dev-ville le corrige : **non imputé à PX2**.
- `capture_ville.ps1 -Serie` : **54 étapes OK, 0 SCRIPT ERROR**. Le seul « échec » est le montage `px1_montage_ref`, faute de la référence `px0_quater_jour_1080.png`, absente du worktree (elle n'existe que dans le dépôt principal, dossier ignoré par Git). C'est de l'outillage, pas une anomalie. `RUE cadrage` : les 3 bâtiments sont dans le rectangle libre à tous les formats. Téléphone : `fenetre=1440x648 reduction=0.600 vue=1200x540 gerard_ecran=76`, comme attendu au §9.5. fps : 459 en PC, 760 au téléphone.
- Fusion simulée (worktree jetable sur `main` dfd5ca4 + `merge --no-ff`, puis supprimé) : aucun conflit, arbre `godot/` identique à la branche. **491 OK.** `integrale` : **160 749 F, frais 805,93 F, 11 interruptions, fin décembre 1988** (appel 8, banque 4, courrier 2, journal 1, fin 1).
- Vitrine PX0 (`scenes/px0.tscn -- --px0-quitter-apres=5`) : code 0, sans erreur.

### Corrections et critères
- [x] **CA-C1 / M4** : les règles d'`ecran.gd` sont conformes au §9.1. Pour un 2400 × 1080 à 400 dpi : T = 5, zone 1440 × 648, `cible_min` = 72 px virtuels = 48 dp, bouton dessiné de 84 px = 56 dp. Sur PC : T ≥ 2 et `min_size` 1152 × 648. `cibles` aux deux téléphones : `sous_seuil=0` (minimum 72 à 1440 × 648, 84 à 1280 × 720 ; 60 à 1920 × 1009). « ACHETER POUR 953,68 F » est entier et visible (`banque_ordre_tel`, montage des téléphones). La carte de l'héritage tient (`heritage_tel`). 70 lignes `UI fenetre … dans_ecran=oui boutons_visibles=oui`, aucune « fenêtre hors écran ».
- [x] **CA-C2 / M1** : `UI panneau recouvre=non contenu_coupe=non` aux 7 formats. Exemples bas/frise : 972/984 à 1080p, 901/913 à 1009, 864/876 à 1152 × 648, 540/552 au téléphone, 612/624 au 16:9. À l'image (`hud_1080`, `hud_1009`, `hud_1152`, `hud_720`, `panneau_tel`, `panneau_tel169`) : l'année, le curseur et le drapeau de la frise sont visibles, et le bouton BANQUE est entier. Les replis se font dans l'ordre prévu (légende et coussin repliés à 1009 et au téléphone). « Actions 5 % » ne déborde plus.
- [x] **CA-C3 / M2** : `UI polices pixelify_min=28 atkinson_min=20 chiffres_pixelify=0`. Les captures sont relues et **aucun 5 ne se lit S** : 300 / 500 / 1 000 F, 10 / 25 / 50 %, ACHETER POUR 953,68 F, PAYER 8 139 F, titres de fin et d'accroche. Voir m10 pour les textes dessinés.
- [x] **CA-C4** : voir CA-C1. Le corps de CHAQUE MOIS au téléphone tient jusqu'au bas de la fenêtre.
- [x] **CA-C5** : m1 est corrigé (la notification « Un mot après le krach » tient dans son cadre, `courrier_1080`). m2 est corrigé : le cadenas est en bas à droite et le calendrier en haut à droite, sans recouvrir de chiffre (`carnet_tel`, `f01_tel`, `carnet_1080`).
- [x] **CA-C6** : chevrons en sprite sur les flèches de bord. `fleches_texte=0`. Dans `scripts/ui/`, il ne reste « → » que dans des commentaires.
- [x] **CA-C7** : la série recopie fps et `clic_dehors`, contrôle `hors_cadre` et `hors_ecran`, couvre les deux téléphones et `hud_1009`.
- [x] **CA-C8 / M3 / A2** : `UI etiquette … dans_libre=oui` pour les 3 bâtiments × 3 vues × 5 formats (45 lignes). Les flèches s'empilent quand il y en a deux du même côté. `etiquettes_aller` : `UI aller banque visible=oui`. À l'image, « MA BANQUE › » est lisible entièrement à gauche du panneau (`etiquettes_bord_1080`) et de la languette (`_tel`), et « LA GAZETTE » est au-dessus de la frise au téléphone (`etiquettes_gazette_tel`).
- [x] CA-I11 (non-régression) : le clic à côté ferme le foyer, les nouvelles, la banque, le menu et la carte (« pas maintenant »), et le journal du krach reste ouvert, aux 3 formats. `courrier_relu_echap` est vert. CA-I13 : 453 images/s à 1080p, 753 au téléphone.
- [x] Cohérence des chiffres : HUD, notification, courrier et historique concordent (compte 9 598 F, coussin 5,8 mois, 8 139 F, 60 000 F / 32 500 F). La fin au téléphone (172 556 F, +9 425 F) correspond au HUD. Le « −500 F / −1 000 F » de versements entre `pause` et `panneau` est voulu : l'étape `panneau` programme 500 F de plus.
- [x] **Périmètre** : 65 fichiers, tous au §1 ou à l'exception du §9.3. Dans `ville.gd`, seul `_regler_fenetre` change. Dans `capture_ville.ps1`, seul le commentaire de la ligne 4 change. Dans `project.godot`, seul `config/version="0.3"` change. `principal.gd` perd `_info()` (B3). Aucun `.bat`, `data/*.json`, `scripts/logique` ou `export_presets.cfg` n'est touché.

### Anomalies (mineures, n'empêchent pas l'OK)
1. **m10 (mineure) : la ligne sous le montant des tuiles du carnet est dessinée en 16 px, et descend à 12 px quand la place manque.** C'est `carte_produit.gd` l. 100 (`_taille_ajustee(…, 16)`, plancher 12). Les lignes concernées : « 11 % cette année », « ≈ 8,25 % fixe », « +4 537 F ». Le badge « NOUVEAU » (14 px) et le timbre « 2,20 F » (14 px) sont dans le même cas.
   - Ces textes sont dessinés par `draw_string` : le contrôle `atkinson_min` ne les voit pas.
   - Sur un vrai 2400 × 1080 à 400 dpi, 12 px virtuels font environ 8 dp, 16 px environ 11 dp : c'est sous le minimum de docs/16 §3.1 (20 px).
   - Je l'accepte comme information secondaire, puisque le taux et le gain sont repris en grand dans la fiche. À reprendre en 02-V ou 03 : texte plus court (« 11 %/an ») plutôt que plus petit, et contrôle étendu aux `draw_string`.
2. **m11 (mineure) : au téléphone, la languette affiche « MON / ARGENT / 82 k / F »**, avec le « F » seul sur sa ligne (`pause_tel`, `etiquettes_bord_tel`).
3. **m12 (mineure, outillage) : `capture_ville.ps1 -Serie` rend « au moins un échec » depuis un worktree** à cause de la seule référence `px0_quater_jour_1080.png`, absente. Il faudrait que ce montage soit facultatif ou que la référence soit copiée.
4. **m13 (mineure, information) : `fleches_texte` ne compte plus que « → »**, alors que le plan disait « → ou › ». Les « › » qui restent sont voulus : « En savoir plus › », « COURRIERS REÇUS › ».
5. m9 (relevé « 417 F + 42 F = 458 F ») est toujours là, et prévu en 03-L. Le blocage de Godot à la sortie (2 fois sur 106) est suivi par dev-ville sur `lot/px1-ville`.

### Sauvegarde du joueur
- Pendant la série d'interface, mes tests et la partie complète, `partie_en_cours.sav` n'a pas bougé (E2B314A8… puis 836B1610… de part et d'autre de chaque lancement, contrôlé par les scripts).
- Le fichier a été réécrit le 07/11 à **00:49:26** : après la fin de mes séries (00:41) et avant mes derniers tests (08:53), pendant la pause de la session. Ce n'est donc **pas** dû à la recette. Le joueur, ou un autre agent, l'a modifié. À confirmer par le chef de projet.

### Non vérifié
- Vrai téléphone (T2, après l'export 0.3) : dpi réel, confort des cibles à 48 dp, défilement tactile.
- Toucher réel de la flèche : il est seulement simulé par `Input.parse_input_event`.
