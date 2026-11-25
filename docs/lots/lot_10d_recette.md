# Lot 10d : recette ciblée (corrections de la recette finale du lot 10)

## Passage 1 (2026-11-25) : branche `lot/10d` commit 877ee89 (main 0b3fd99 + 10d-logique ce4feef + 10d-interface eab4d87) : verdict **KO** (1 majeure nouvelle, 1 préexistante hors lot, 4 mineures)

Copie isolée : `git archive 877ee89 godot` dans le scratchpad du testeur, `user://` à part (`JeuClaude_recette_10d`). Référence `main` 0b3fd99 dans une 2e copie isolée. Dépôt principal, worktree `lot10d` et partie du joueur intacts (`partie_en_cours.sav` SHA-256 `0EFB110D...22E5E` identique, pas de `records.sav` du joueur, `git status` propre).

### Résumé
A1 (jeton `{Proche}`) est corrigé, M1, M2, M3, M4, M7 et les textes K4 / SCPI le sont aussi, 1984-88 est inchangé et tous les tests sont verts. Mais la correction de A2 est **incomplète** : « Projets : 4 sur 4 réalisés » est désormais cohérent, seulement la liste dessous affiche les deux projets du chapitre 2 **en double** à la place des projets réels du chapitre 1 (anomalie N1, majeure). Le joueur le verra à la fin de chaque partie de dix ans. Correctif court attendu (résoudre le nom des projets rangés « 1984:P1 » dans les données du chapitre d'origine), puis nouveau passage ciblé.

### 1. Tests automatiques
- `tests.ps1 -Recette -Delai 700` (copie isolée, aucun autre Godot en parallèle) : **1 777 vérifications OK, 0 KO** (1 766 de la finale + 11 de `test_correctifs_10d`), 50 étapes, 1 382 s ; sauvegarde et records du joueur inchangés. Le script rend « ÉCHEC » à cause de 2 lignes d'import : `res://tests/recette/test_recette_fin_titres.tscn:1 Parse Error: Expected '['` : **mon** fichier de recette (07-I) est commité avec un BOM UTF-8 ; le message n'apparaît qu'à l'import d'une copie neuve, la scène elle-même tourne (25 OK). Sans rapport avec le lot ; à corriger de mon côté (retirer le BOM, dossier `tests/recette/` qui m'appartient) avant l'export.
- `test_reference_1984` : 35 OK (graine 7 actif 172 139,25 F / 870,08 F / 11 interruptions inchangés) : **1984-88 inchangé**.
- `test_correctifs_10d` 11 OK ; `test_interface` OK avec le test du HUD à 0 F.

### 2. Captures (PC 1920×1080, téléphones 1440×648 et 1280×720)
- Étapes `fin_1993`, `mon_foyer_metier`, `hud`, `carte_conclusion`, `bulle`, `carriere_k4`, `carriere_k5`, `fin_1988`, `fin` x 3 formats : 27 lancements, **tous code 0**, `debordements=0`, `UI carriere ... conforme=oui`, `UI foyer metier=... egal=oui`.
- **M7** : `hud` à 7 formats (1280×720, 1366×768, 1920×1009, 1152×648, 1080, 1440×648, 1280×720 tél.) : 7 sur 7 code 0 (« saut lancé » observé par signal) ; `carte_conclusion` : 3 + 10 lancements (PC et téléphone), 13 sur 13 code 0, `bulle apres_carte=oui texte=« Sylvie est ravie »` à chaque fois (la série échouait 2 fois sur 4 avant). `capture_interface.ps1 -Serie` complète (252 lancements, environ 65 min) **non rejouée** : sous-ensemble représentatif seulement (les 2 familles qui échouaient + toutes les étapes touchées) ; ce lot ne touche que `interface.gd` (scénarios), `hud.gd`, `modale_foyer.gd`, `modale_releve_fin.gd`, `bilan.gd`, `foyer.gd` et des textes.
- `fin_1993` relue après 6 s (`capture.ps1 -Attente 6`, 3 formats) : 228 394 F, Tata 263 831 F, écart 35 438 F (- 13 %), identiques sur tous les écrans. **M1 corrigé** : au 1440×648 le « (– 13 %) » passe en entier à la ligne, au 1280×720 il tient sur la ligne 2 (plus de coupure du signe).
- Mon foyer (Christine, K4 acceptée) au PC et au téléphone : « Patrick fait la tête. » ; **M6 (barre de défilement) corrigé** (réserve de 30 px : « Assistante du directeur commercial » ne touche plus la barre).

### 3. Parties réelles (fenêtre, `principal.tscn`, saut « prochain courrier », records et sauvegarde isolés ; harnais `test_recette_finale.gd`)
| Partie | Format | Fin | Patrimoine (€) | Écart Tata | Jetons à l'écran / modales | Projets |
|---|---|---|---|---|---|---|
| Gérard 1984->1993, graine 7 actif, sauvegarde + reprise au passage | PC | déc. 1993 | 35 949,06 | -1,734 % | **0** (1 830 textes) | « 4 sur 4 » (liste fausse, N1) |
| Christine 1989->1993, graine 7 actif | PC | déc. 1993 | 22 021,25 | -1,112 % | **0** (1 038 textes) | « 2 sur 2 », liste juste |
| Gérard 1984->1993, graine 31 passif | téléphone | déc. 1993 | 25 353,80 | -18,044 % | **0** (1 404 textes) | « 3 sur 4 » (liste fausse, N1) |
| Christine 1989->1993, graine 11 passif | téléphone | déc. 1993 | 18 638,92 | -13,482 % | **0** (829 textes) | « 2 sur 2 » |
- Les 4 parties : 0 KO. Mêmes patrimoine et écart que ceux de la recette finale (aucune dérive de chiffres : 35 949,06 / 22 021,25 / 25 353,80 / 18 638,92). Patrimoine moteur = `bilan.nominal.vous` ; écart recalculé = affiché ; l'écran de fin, la barre « Vous » et le message « VOUS : X F de moins que Tata Livret » concordent (ex. 235 810 F / 239 972 F / 4 162 F / - 2 %). Reprise au passage 1988->1989 : date, patrimoine (18 915,66), compte, Livret A, 73 entrées d'historique, 41 non-lus et carte de passage identiques ; la partie reprise finit au centime comme avant.
- **A1 corrigé** : sur `main` 0b3fd99 la même partie Christine produit 2 jetons (`{Proche} fait la tête`, `{Proche} se radoucit`, bulle de MA MAISON) ; sur `lot/10d` 0 jeton dans les 4 parties, bulles lues « Sylvie est ravie », « Patrick fait la tête ». Historique relu entrée par entrée : 75 / 75, 144 / 144, 78 / 78, 151 / 151, aucun jeton.
- **M2 corrigé** : « Revendables à tout moment, disait la brochure : personne n'a voulu les racheter. » (plus de guillemets imbriqués). **M3 corrigé** : intro « Dix ans de vie, de 1984 à 1993 » ; sous-titre du titre « Gérard · janvier 1984 – décembre 1993 · 26 ans » (plus de « Démonstration »). **M4 corrigé** : test HUD à 0 F, « COMPTE 0 F » vu à l'écran. Texte SCPI (frais d'entrée, revente environ 10 % sous le prix payé) et K4 (« La garde du soir est déduite ») conformes à la demande.

### Anomalies

**N1 (majeure, nouvelle) : la liste des projets de l'écran de fin d'une partie de dix ans montre les projets du chapitre 2 en double au lieu de ceux du chapitre 1.**
- Étapes : jouer Gérard 1984->1993 (graine 7 actif ou 31 passif, 2 projets du chapitre 1 puis 2 du chapitre 2), arriver à l'écran de fin.
- Attendu : 4 lignes distinctes : projets du chapitre 1 (ex. « La Super 5 neuve », « L'apport pour un T3 » ou les options réellement choisies) puis ceux du chapitre 2.
- Constaté : graine 7 : « Une 405 break : réalisé / La maison avec jardin : l'apport : réalisé / Une 405 break : réalisé / La maison avec jardin : l'apport : réalisé » (bilan : ids `P1C, P2C, P1C, P2C`). Graine 31 : « Une 405 break : réalisé / La maison avec jardin : l'apport : **abandonné** / Une 405 break : réalisé / La maison avec jardin : l'apport : réalisé ». Le dernier chapitre est donc affiché deux fois, les noms du chapitre 1 sont perdus (et dans la capture du dev `fin_1993` : « cuisine équipée / Corse » en double, même cause). Le compte « x sur y » est juste, la liste non.
- Cause probable : `bilan.gd` `_projets` retrouve le nom par `Projets._def(pid)` et `Projets._option(s["option"])` qui cherchent dans le chapitre courant d'abord ; les ids des deux chapitres sont identiques (`P1`, `P1A..C`, `P2`, `P2A..C` dans `1984/projets.json` et `1989/projets.json`), donc « 1984:P1 » prend la définition du chapitre 1989. Pour une entrée « 1984:Px », chercher dans les données du chapitre 1984 (`Donnees.charger_dans`). Même vérification pour l'état « abandonné ».
- Captures : `partie_G1.txt` ligne « textes fin », image `img\pc_fin_1984.png` (scratchpad, voir fin) ; `godot\captures\a6_pc.png`.

**N2 (majeure selon moi, préexistante, hors lot 10d) : `SCRIPT ERROR: Out of bounds get index '1' (on base: 'PackedStringArray')` à l'ouverture d'un ordre de la banque.**
- Étapes : partie active complète (Gérard ou Christine, graine 7), le banquier présente un produit en mode « ouvrir » ; l'erreur sort 2 fois par partie (`format.gd:36` `nombre` <- `montant` <- `panneau_banque.gd:734` `_info_prix` <- `_afficher_ordre` <- `construire` <- `ouvrir_banque` <- `_sequence_banquier`). Un prix NaN / infini arrive dans `Format.montant(p, a, true)` (aucune garde `is_nan(p)` pour le prix du jour, alors qu'il y en a une pour `p0`). Absente des parties passives (rien n'est ouvert).
- Reproduite à l'identique sur `main` 0b3fd99 (même partie Christine) : donc pas causée par 10d ; elle m'avait échappé à la recette finale (je ne relisais que le journal de la sortie standard des parties). À faire traiter, avec le produit concerné à identifier (non élucidé : probablement B2 SCPI ou B4 PEA, présentations jouables du chapitre 1989). Effet probable : en-tête du panneau d'ordre sans prix.

**Mineures (n'empêchent pas un OK) :**
- **M5 non résolue** (écran de fin d'une partie de dix ans, PC) : le resserrement des marges ne suffit pas. Au 1920×1080 comme au 1280×720, la colonne de droite défile encore (barre visible) ; la légende « Vous / Tata Livret » de la courbe « DIX ANS EN UN COUP D'ŒIL » est coupée au bord inférieur, et la courbe réduite à 90 px a ses graduations « 400 000 F » et « 200 000 F » **superposées** (illisibles). À 1280×720 la ligne « Argent mis de côté en dix ans » est aussi rognée par le bas de la zone. Lisible en faisant défiler ; je n'avais signalé que le défilement, la superposition des graduations est nouvelle (effet de la hauteur réduite).
- **M6 partielle** : Mon foyer affiche encore « Le poste itinérant · Accepter · 0 F » (carte de carrière jouée, montant nul rendu en « 0 F » ; seule la barre de défilement a été traitée).
- Ligne du bilan : lignes « Projets » du chapitre 1 dupliquées : voir N1.
- Fichier de recette `test_recette_fin_titres.tscn` avec BOM (à moi) : erreur d'import sur copie neuve, sans effet sur les tests.

### Critères d'acceptation
- [x] Périmètre : 17 fichiers (4 JSON de données, `bilan.gd`, `foyer.gd`, `interface.gd` (scénarios), `hud.gd`, `modale_foyer.gd`, `modale_releve_fin.gd`, tests, bases de connaissances) ; rien d'inattendu.
- [x] Tests automatiques 1 777 / 0 KO (hors le BOM de mon propre fichier).
- [x] 1984-88 inchangé (`test_reference_1984` 35 OK, références chiffrées identiques).
- [x] A1 : plus aucun jeton à l'écran ni dans l'historique (4 parties, 2 formats, 4 400 textes balayés).
- [ ] **A2 : « Projets : x sur y » cohérent avec la liste affichée dessous : échoue (N1)** : le compte est juste, la liste est fausse (doublons, noms du chapitre 1 perdus).
- [x] M1, M2, M3, M4, M6 (barre), M7, K4, SCPI : vérifiés.
- [ ] M5 : partiellement (défilement et courbe encore à retoucher, mineur).
- [x] `capture_interface` : `hud` et `carte_conclusion` sortent en code 0 (20 lancements sur 20) ; série complète non rejouée (sous-ensemble).

### Non vérifié
Série complète `capture_interface.ps1 -Serie` (252 lancements) et `capture_ville.ps1 -Serie` (non touchée par le lot) ; vrai téléphone ; relecture humaine des textes ; l'identité du produit qui déclenche N2.

### Fichiers de preuve (hors dépôt)
Dossier `C:\Users\arthu\AppData\Local\Temp\claude\a5f3148d28e60fc6\b77abd8d-5910-4bb5-a447-5b2479db06ee\scratchpad\r10d_113338371\` : `tests.log`, `cap.log`, `cap2.log`, `c\partie_G1.txt` / `G2` / `C1` / `C2` (+ `.err`), `main\partie_CM.txt` / `.err` (référence `main`), `c\img\*.png`, `c\godot\captures\*.png` (`a6_*` = fin 1993 relue à 6 s, `r10d_*` = étapes ciblées).
