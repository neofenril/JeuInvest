# Lot 08b : recette courte (testeur)

## Passage 1 : 2026-11-18, branche `lot/08b-logique`, commit testé 2c84a43 (base : `main` 68d6f7d ; godot/ identique à c14dede)

**Verdict : OK** (0 anomalie bloquante ou majeure ; 4 mineures dont 2 écarts de plan à faire arbitrer par le chef de projet).

### Méthode
- `tests.ps1 -Recette -Delai 700` sur le worktree de la branche (machine libre) ; référence `main` rejouée dans une copie isolée (`git archive main godot`, `user://` à part).
- Aucune capture (aucun écran touché, recette courte du 17/11).

### Résultats
| Mesure | `main` | `lot/08b-logique` |
|---|---|---|
| Vérifications | 1 379 OK, 0 KO | **1 417 OK, 0 KO**, 0 erreur de script, 0 échec |
| Durée totale | 641,8 s | 670,5 s (**+ 28,7 s**) |
| `test_titres_mesures` / `test_rue_mesures` | - | 35,9 s / 16,4 s |

(Sur `main`, la copie neuve affiche « 2 erreur(s) de script » à l'import : artefact connu du premier `--import` d'une copie neuve, toutes les étapes sont propres.)

Fichiers du joueur : `partie_en_cours.sav` SHA-256 0EFB110DAC59... inchangé (écriture du 15/11 21:08, avant et après) ; `records.sav` absent avant et après (message de `tests.ps1` : « inchangés »).

### Critères d'acceptation
- [x] **CA-R1 ★** : le 1er commit (41c483f) ne touche que `strategie_test.gd` et `test_titres_mesures.gd`, `titres.json` inchangé (`ecart_min` 0,02, `cc_moyen_min` 0,30) : mesure « avant » bien isolée. (Les lignes « avant » citées au compte rendu du développeur ne sont pas rejouées par moi : seuls les seuils du commit étaient à contrôler.)
- [x] **CA-R2 ★** : `REFERENCE_PREF (200 parties)` = bon_pere 28 (14 %) · golden_boy 16 (8 %) · escargots 21 · fourmi 27 · cigale 20 · marin 16 · neveu_matelas 13 · ecureuil 23 · apprenti 36 (18 %). Tous ≥ 6/200, aucun > 50, bon_pere dans 16-50. Toutes les parties finissent et ont un titre (vérification verte).
- [~] **CA-R3 ★** : bon_pere 13/40 (actif alterner moins_cher) et 0/40 (passif) ≤ 16 ; « tout sur Peugeot » marin 0/40 (apprenti 40/40) ; plafond 50 % respecté pour **les combinaisons actives hors Peugeot** (max : marin 16/40 = 40 % en « actif alterner plus_cher ») et pour l'agrégat ALTERNER (200 parties : neveu 77 = 38,5 %). **Écart de plan** : le plan dit « aucune combinaison alterner > 50 % » ; or « passif alterner » donne neveu_matelas 39/40 et 38/40 (97 %), et « actif alterner Peugeot » apprenti 40/40. Le développeur a restreint la vérification aux combinaisons actives hors Peugeot (documenté dans le test). Titre cohérent pour un joueur qui ne fait rien (neveu de Tonton Matelas) : à arbitrer par le chef de projet, non bloquant à mon sens.
- [x] **CA-R4 ★** : les 9 profils de `PROFILS_TITRES` obtiennent leur titre (`test_titres` 62 OK, `test_recette_titres` 80 OK, `test_recette_fin_titres` 25 OK).
- [x] **CA-R5 ★** : lignes `RUE mode=…` (P-REF 200 parties, passif / actif / peugeot × 40) : `etoiles_livrees` 200/200, 40/40 ×3 ; `max_par_mois=1` ; `ecart_voisin_min=2` ; `mois_pause_violes=0` ; `rang_trop_proche=0`.
- [x] **CA-R6 ★** : notifications rue + kiosque par partie : P-REF 22,8 (20-25), passif 22,6, actif 23,2, peugeot 22,9 (tous dans 20-30) ; passages non ★ abandonnés 0,36 / 0,00 / 0,90 / 0,68 (≤ 3).
- [~] **CA-R7** (mesure) : `JEANMI etapes_vues=attend=100% (320/320) position=100% porsche=100% **liquide=0% (0/320)** rembourse=100%`. L'étape « liquidé » n'est jamais vue dans ces 320 parties : à signaler au chef de projet (aucune partie de la mesure ne vend Jean-Mi « liquidé », y compris le mode peugeot ; `rue.json` est intact, donc ce n'est pas une régression du lot, mais la mesure ne peut pas l'exercer).
- [x] **CA-R8 ★** : `rue.json` strictement identique à `main` (`git diff main lot/08b-logique -- godot/data/rue.json` vide : dosage de Jean-Mi inchangé) ; `test_logique` (intégrale), `test_rue_moteur` (36), `test_foyer` (34), `test_dividendes` (44), `test_cadence` (18), `test_recette_rue` (42), `test_recette_maison` (12) verts sans référence modifiée ; seules références changées : bornes de `test_titres*` (attendu) et ma recette titres (voir A1).
- [x] **CA-R9 ★** : 1 417 ≥ 1 379, 0 erreur de script, durée + 28,7 s (≤ 120), fichiers du joueur intacts.
- [~] **CA-R10 ★** : périmètre = 9 fichiers. Tous dans le §3 sauf **`godot/tests/recette/test_recette_titres.gd`** (3 lignes : seuil 0,02 → 0,075 codé en dur dans mes vérifications). Dossier explicitement interdit au développeur par le plan, mais la modification est indispensable (sinon `-Recette` rouge) et se limite à suivre le nouveau paramètre : voir A1. Pas de fichier d'interface, `principal.gd`, `quartier.gd`, `tests.ps1`, `project.godot`, ni de fichier temporaire ou de capture.
- [x] **CA-R11 ★** : seul texte changé : « pourquoi » d'apprenti = « Aucun style marqué cette fois : rejouez pour tenter une autre voie. » : 11 mots (≤ 15), vouvoiement, aucun mot interdit (`test_titres` vert).

### Anomalies
- **A1 (mineure, périmètre)** : le développeur a modifié `godot/tests/recette/test_recette_titres.gd` (dossier du testeur, interdit par le plan §3). Nécessaire et minimal (3 lignes, valeurs recalées sur `ecart_min` 0,075) ; relu et vert. À entériner par le chef de projet ; je reprendrai la main sur ce fichier au prochain passage.
- **A2 (mineure, écart de plan CA-R3)** : plafond 50 % restreint aux combinaisons actives hors Peugeot (passif « alterner » : neveu 97 %). Voir CA-R3.
- **A3 (mineure, CA-R7)** : étape « liquidé » de Jean-Mi vue dans 0 % des parties mesurées. Non causé par le lot.
- **A4 (mineure, note)** : P-REF donne apprenti 18 % (36/200) : sous le plafond de 25 %, mais c'est le titre par défaut le plus fréquent ; tout-Peugeot (gagnant, non vendu) reçoit toujours « apprenti » (G-R2 : texte réécrit, comme prévu).

### Non vérifié
- Plausibilité des lois de tirage de P-REF et des cibles pour un vrai joueur (G-R1, game designer) ; ressenti des titres en partie réelle ; aucune capture (aucun écran touché) ; lignes « avant » du compte rendu non rejouées.
