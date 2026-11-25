# Lot 10 : recette finale avant export (version 0.7, code Android 11)

## Passage 1 (2026-11-25) : `main` commit 135a487 : verdict **KO** (2 majeures, 7 mineures)

Copie isolée : `git archive 135a487 godot` dans le scratchpad du testeur, `user://` à part (`JeuClaude_recette_fin10`). Dépôt principal et partie du joueur intacts (`partie_en_cours.sav` : SHA-256 `0EFB110D...22E5E`, écriture du 15/11 21:08, identique avant et après). Le dépôt principal contient des modifications non commitées qui ne sont pas de moi (`docs/37_boursier_1989_1993.md`, `docs/46_banquier_revision_lot10.md`, `docs/connaissances/banquier.md`, `boursier.md`) et, ajoutés par moi, `godot/tests/recette/test_recette_finale.gd` + `.tscn` (non suivis, inertes sans `TESTEUR_FINALE=1`).

### Résumé
Tout est vert côté automatique et captures (hors deux échecs préexistants), 1984-88 inchangé, reprise du passage 1988->1989 sans perte, records v2 corrects, exports configurables. Mais deux défauts visibles par le joueur apparaissent dès qu'on joue réellement les parties de dix ans ou de Christine : un jeton brut `{Proche}` dans la bulle d'humeur (A1) et « Projets : 4 sur 2 réalisés » à l'écran de fin (A2). Je ne peux pas donner OK avec ces deux points : correctif court à prévoir, puis nouveau passage ciblé (étapes A1/A2 + tests) avant l'export.

### 1. Tests automatiques
- `godot/outils/tests.ps1 -Recette -Delai 700` : **1 766 vérifications OK, 0 KO, 0 erreur de script, 0 échec, 48 étapes, 1 379 s** (« TOUT EST PROPRE »). Import de la copie : 0 `SCRIPT ERROR` / `Parse Error`.
- Références inchangées : graine 7 actif 172 139,25 F / frais 870,08 F / 11 interruptions (CA-FO1, CA-L7, test_reference_1984 35 OK) : **1984-88 inchangé**.

### 2. Séries de captures (PC 1920×1080, téléphones 1440×648 et 1280×720)
- `capture_interface.ps1 -Serie` : 252 lancements, 3 902 s, 8 échecs, tous expliqués : 7 × `hud` « saut non lancé » (préexistant, présent sur `main` depuis le lot 09, déjà noté) et 1 × `l4_carte_conclusion` « bulle apres_carte=non » (**instable** : 2 échecs sur 4 relances à 1080 sur `main`, et 3 sur 5 sur la base 2f89384 d'avant le lot 10c : préexistant, aléatoire, sans lien avec le lot).
- `capture_ville.ps1 -Serie` : code 0, « PX1 : tout est vert ». Étapes carrière K4 / K5 / Mon foyer relancées à la main en 3 formats (`carriere_k4`, `carriere_k5`, `mon_foyer_metier`) : lignes `UI carriere ... conforme=oui`, `incoherences=0`.
- Images relues (PC et téléphone) : passage 1989, intro Christine, intro Gérard, vitrine du Golfe, Golfe un an après, carnet 13 produits, fiche SCPI / vente différée, frise 10 ans, Mon argent 10 ans, cartes K4 / K5, Mon foyer (métier / statut), fin 1993 (Gérard 10 ans, Christine 5 ans), titre + palmarès v2, collection par chapitre, choix du départ. Pas de débordement ni de chevauchement bloquant ; défauts relevés en mineures ci-dessous.
- Piège de relecture : l'écran de fin s'anime (barres et montant depuis 0) ; la capture `fin_1993` à 0,5 s montrait 222 495 F / 35 438 F incohérents, relancée avec `-Attente 6` : 228 394 F, Tata 263 831 F, écart 35 438 F, tout cohérent.

### 3. Parties réelles (fenêtre, `principal.tscn`, saut « prochain courrier », records et sauvegarde isolés)
Test de recette `godot/tests/recette/test_recette_finale.gd` (variables `TESTEUR_FINALE=1`, `TESTEUR_CH`, `TESTEUR_GRAINE`, `TESTEUR_ACTIF`, `TESTEUR_REPRISE`, `TESTEUR_FMT`, `TESTEUR_IMG`) : joue la partie jusqu'à l'écran de fin, balaie en continu tous les textes à l'écran à la recherche de jetons (`{x}`, `%s`, `null`, `NaN`...), relit les 144 entrées de l'historique, recalcule l'écart face à Tata Livret, contrôle les records.

| Partie | Format | Fin | Patrimoine (€) | Écart Tata | Titre |
|---|---|---|---|---|---|
| Gérard 1984->1993, graine 7 actif, **sauvegarde + reprise au passage** | PC | déc. 1993 | 35 949,06 | -1,734 % | Écureuil (1984-88) + Fidèle de Tata Livret (1989-93) |
| Gérard 1984->1993, graine 7 actif, sans reprise | téléphone | déc. 1993 | 35 949,06 | -1,734 % | identique |
| Gérard 1984->1993, graine 31 passif, reprise | PC | déc. 1993 | 25 353,80 | -18,044 % | Collectionneur de diamants |
| Christine 1989->1993, graine 11 passif | PC | déc. 1993 | 18 638,92 | -13,482 % | Collectionneuse de diamants |
| Christine 1989->1993, graine 7 actif (2 fois) | PC et téléphone | déc. 1993 | 22 021,25 | -1,112 % | Fidèle de Tata Livret |

- **Cohérence des chiffres** : dans les 5 parties, `bilan.nominal.vous` = patrimoine du moteur (écart < 1 €) ; l'écart recalculé (vous / Tata - 1) = l'écart affiché ; écran de fin : patrimoine, barre « Vous », ligne de la rue et message « VOUS : X F de moins que Tata Livret (- N %) » identiques (ex. 235 810 F / 239 972 F / 4 162 F / - 2 % ; Christine 144 450 F vs 146 075 F / 1 625 F / - 1 %).
- **Sauvegarde / reprise au passage 1988->1989** : sauvegarde écrite, relue, reprise acceptée, même date, patrimoine, compte, Livret A, nombre d'entrées d'historique (73), non-lus (41), carte de passage rouverte ; la partie reprise finit **exactement** comme la partie sans reprise (35 949,06 € / -1,7343 %). OK.
- **Historique** : 75 à 151 entrées par partie, toutes relisibles (relecture ouverte une par une, aucun jeton dans les textes relus).
- **Records v2** (fichier isolé, relu après chaque fin) : sections `chapitre_1984` et `chapitre_1989` distinctes ; Gérard 10 ans : record de chapitre 1984-1988 (-1,9774 %, fin 1988) et record de partie `records_partie["1993"]` (-1,7343 %) ; collection par chapitre (`ecureuil` x2 dans 1984, x3 dans 1989 après trois fins) ; 2e partie identique = égalité (« ancien », pas de NOUVEAU DANS LA COLLECTION, compteur +1) ; partie moins bonne (-18 %) : records gardés. Aucun écrit hors fichier isolé.
- **Jetons / gabarits résiduels** : aucun dans les modales, l'historique relu et l'écran de fin des parties de Gérard (1984-88) ; **résidus dans la bulle d'humeur au-dessus de MA MAISON : voir A1**. (Les `{mise}` et `[]` vus dans les données brutes de l'historique sont des champs de données rendus correctement à l'affichage : « 1 000 F de plus engagés ».)

### 4. Exports (sans les lancer)
- `export_presets.cfg` : Windows `../export/windows/JeuClaude.exe`, `file_version` / `product_version` 0.7.0.0, `embed_pck=true`, `include_filter` couvre `data/*.json`, `data/chapitres/*/*.json`, `data/themes/*.json`, `data/pixel/*/*.txt` ; Android `../export/android/JeuClaude.apk`, `version/name="0.7"`, **`version/code=11`**, `package/unique_name="fr.jeuclaude.demo"`, arm64 + armeabi, signature debug. `project.godot` : `config/version="0.7"`. `outils\jdk-17`, `android-sdk` et les modèles d'export 4.7.2 présents. `Exporter_Windows.bat` / `Exporter_Android.bat` inchangés (variable `JEUCLAUDE_GODOT`).
- `--export-pack Windows` sur la copie : paquet 1 642 992 octets, 0 erreur, 35 fichiers de données sur 36 présents (seul `data/pixel/LISEZMOI.md` exclu, voulu), ni `tests/` ni `captures/` ; lancé par `--main-pack` avec le Godot non console : étapes `titre` et `fin_1993`, **0 ERROR**.
- Non fait : l'export lui-même, le lancement de l'exe signé (Smart App Control), l'installation de l'APK.

### Anomalies

**A1 (majeure) : jeton brut `{Proche}` / `{e_p}` dans la bulle d'humeur de la maison (chapitre 1989).**
- Étapes : jouer le chapitre 1989 (Christine, ou Gérard après le passage ; reproduit dans 6 parties sur 6) ; résoudre une carte ou un projet du foyer ; la bulle qui sort de MA MAISON affiche par exemple « {Proche} fait la tête » (apparu avec des accolades rendues comme des parenthèses : « (Proche) fait la tête »), « {Proche} se radoucit », « {Proche} va bien », « {Proche} est ravi{e_p} » au lieu de « Patrick fait la tête », « Sylvie va bien », etc.
- Attendu : prénom du proche et accord rendus (comme dans Mon foyer, qui affiche bien « Patrick fait la tête. », et dans l'historique : « Patrick se radoucit »).
- Constaté : la notification d'humeur émise à la résolution d'une carte ou d'un projet (`foyer.gd` l. 222, `"titre": humeur_phrase(...)`, `"bulle": true`) ne passe pas par le rendu central `EtatPartie.rendre` (appliqué seulement aux notifications de `_entrer_mois`) ; `principal.gd` `_bulle_humeur` (l. 540) affiche `n["titre"]` tel quel. Nœud : `Principal/@CanvasLayer/Bulle/Cadre/.../Texte`. Absent en 1984-88 (le texte n'y contient pas de gabarit).
- Captures : `testeur_fin10_947610869\img\pc_residu_1.png` (avril 1993, « (Proche) fait la tête »), `pc_residu_2.png` (déc. 1993, « (Proche) se radoucit »), dans le dossier scratchpad indiqué en fin de rapport.

**A2 (majeure) : « Projets : 4 sur 2 réalisés » à l'écran de fin d'une partie de dix ans.**
- Étapes : partie Gérard 1984->1993, réaliser les deux projets du chapitre 1 (ex. P1C, P2C) et ceux du chapitre 2 ; écran de fin.
- Attendu : x sur total cumulé (4 sur 4) ou projets du dernier chapitre seulement, cohérent avec la liste affichée dessous.
- Constaté : « Projets : 4 sur 2 réalisés » (graine 7 actif), « 3 sur 2 » (graine 31) ; la liste ne montre que 2 projets (ceux du chapitre 2). Cause : `bilan.gd` l. 25 `realises = Titres.projets_realises(e)` (cumul des deux chapitres) contre `total = liste.size()` (chapitre courant seul). Même défaut dans la capture du développeur `fin_1993` (`l10_fin_1993_*`). Christine (5 ans) : 2 sur 2, correct.

**Mineures (n'empêchent pas un OK) :**
- **M1** : écran de fin au téléphone 1440×648 (scénario `fin_1993`) : « (- 13 %) » coupé après le « (– » (césure du signe moins : « Tata Livret (– / 13 %) »). Un espace insécable ou une césure interdite suffirait.
- **M2** : titre de Christine « La collectionneuse de diamants » : citation en double guillemets « « Revendables à tout moment » : personne n'a voulu les racheter. » (guillemets imbriqués ; même motif possible pour les autres titres).
- **M3** : l'intro de Gérard (« Cinq ans de vie, de 1984 à 1988 ... ») et le bilan « Démonstration » annoncent 5 ans alors que le choix du départ affiche « janvier 1984 – décembre 1993 » et que la partie dure 10 ans (la carte de passage dit bien « Jusqu'en décembre 1993 ») ; libellé « Démonstration » pour une partie de dix ans.
- **M4** : barre haute, compte exactement à zéro : « 0,00 F » (décimales) alors que tous les autres montants sont entiers (« 0 F »). Vu en décembre 1993 sur la partie Gérard 10 ans.
- **M5** : écran de fin d'une partie de dix ans au PC (1920×1080 et 1280×720) : dans la colonne de droite, « DIX ANS EN UN COUP D'ŒIL » (courbe) est sous le pli, la ligne « 4 JEAN-MI » est rognée à son bord inférieur : il faut faire défiler ; à surveiller (non bloquant, lisible au défilement).
- **M6** (10c, déjà signalées) : Mon foyer, carte de carrière jouée affichée « Accepter · 0 F » ; au téléphone, « Assistante du directeur commercial » touche la barre de défilement.
- **M7** (préexistantes) : `hud` « saut non lancé » x7 et `l4_carte_conclusion` instable : `capture_interface.ps1 -Serie` ne sort donc jamais en code 0.
- Note de recette : le compteur « interruptions » de mon harnais compte le passage deux fois après reprise (artefact du test, pas du jeu).

### Critères d'acceptation vérifiés
- [x] Périmètre : `main` 135a487, aucune sortie hors copie ; dépôt et partie du joueur intacts.
- [x] Tests automatiques (1 766 / 0 KO, import propre).
- [x] 1984-88 inchangé (références chiffrées identiques).
- [x] Séries de captures PC / 1440×648 / 1280×720 jouées et relues (2 échecs préexistants seulement).
- [x] Parties réelles Gérard 1984->1993 et Christine 1989->1993 jusqu'au bilan final, chiffres cohérents.
- [x] Sauvegarde / reprise au passage 1988->1989 sans perte ; records v2.
- [x] Exports configurables (0.7 / code 11), paquet valide, 0 ERROR.
- [ ] **Aucun jeton ni gabarit résiduel à l'écran** : échoue (A1).
- [ ] **Écran de fin cohérent sur dix ans** : échoue (A2).

### Non vérifié
Vrai téléphone (défilement tactile, ressenti), exe exporté signé, APK installé, ressenti du rythme en mouvement ; relecture de tous les textes des 144 entrées par un humain (seul un balayage automatique de jetons a été fait) ; parties avec achats d'actions en 1989-93 (le joueur « actif » de test n'achète que ce que le banquier présente : « utilisés 1/13 »).

### À confirmer par le boursier / le banquier
- **Golfe, un an après** : le libellé « avant la baisse : 2 000 F » est ambigu : les barres (Tout vendu 2 091 F, Rien fait 2 536 F, Renforcé 3 778 F) ne sont cohérentes avec « reste sous son niveau de juillet 1990 » que si 2 000 F est la mise de septembre 1990 (au plus bas) ; « avant la baisse » suggère la valeur de juillet. Libellé à confirmer.
- **Édition spéciale du Golfe** : texte « encore 10,2 % en septembre » et message « -10 % » face au graphe 1 640 -> 1 470 (soit -10,4 % sur les valeurs arrondies à 10 points) : arrondi à confirmer.
- **Emprunt d'État « 13,4 % fixe »** affiché en 1992 dans le carnet : taux d'un emprunt acheté pendant le chapitre 1 (OAT de 1984-1988) ? Plausible, à confirmer (un emprunt neuf de 1992 serait vers 8-9 %).
- **Maastricht** (référendum 51 % oui, la livre et la lire quittent le SME, taux qui s'envolent), CAC 40 à 1 830 en septembre 1991 : conformes à ma mémoire, sans conseil de ma part.
- Valeurs financières du chapitre 1989-93 (PEL « ≈ 8,25 % » encore en 1992, SCPI 6,3 % / revente à 900 F pour 1 000 F, PEA ouvert en 1992) : cohérentes en interne, non vérifiées par une source.

### Fichiers de preuve (hors dépôt)
Dossier : `C:\Users\arthu\AppData\Local\Temp\claude\a5f3148d28e60fc6\b77abd8d-5910-4bb5-a447-5b2479db06ee\scratchpad\testeur_fin10_947610869\` : `tests.log`, `serie_i.log`, `serie_v.log`, `extra.log`, `partie_G3.txt` / `partie_C3.txt` / `partie_G4.txt` / `partie_G5.txt` / `partie_C2.txt`, `img\*.png` (photos des parties), `godot\captures\*.png` (séries).
