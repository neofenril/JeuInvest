# Lot 09-L : recette du testeur

## Passage 1 (2026-11-18), branche `lot/09-logique`, commit testé 015cafa (L0 = 147bf3d)

**Verdict : OK** (aucune anomalie bloquante ni majeure ; 3 mineures).

### Méthode
Worktree du développeur `lot09-logique` (git status propre avant et après) ; copies isolées de `main` et de 015cafa dans le scratchpad (`custom_user_dir_name`, nettoyées). `partie_en_cours.sav` du joueur : SHA-256 identique avant / après (0EFB110D…, écrit le 15/11 21:08). Aucun `records.sav` touché.

### Critères d'acceptation
- [x] **CA-L1** `test_reference_1984` : `git diff 147bf3d..HEAD` vide. Passe sur la branche (35 OK) ET sur une copie de `main` (35 OK) : la référence est donc bien celle de `main` après 08b. Il couvre 1984-01 → 1988-12 (parties « fin=fin »), 35 parties : intégrale g7 actif / passif, tout allumé actif / passif, tout-Peugeot, 9 profils, 20 parties P-REF ; patrimoine à 8 décimales, frais, impôts, interruptions, titre, rang, nombre d'entrées d'historique, md5 des textes.
- [x] **CA-L2** `tests.ps1 -Recette -Delai 700` : 36 étapes, **1 501 vérifications OK**, 0 KO, 0 erreur de script, 0 échec, 705,6 s, « TOUT EST PROPRE » (main : 1 417 ; +84). Aucune ligne « Données introuvables » / « JSON invalide » / SCRIPT ERROR / Parse Error dans le journal. Seul test existant modifié : `test_demo` (2 chemins `res://data/banque|demo.json` → `chapitres/1984/…`), aucune valeur attendue changée.
- [x] **CA-L3** 9 renames à **100 %** (banque, evenements_vie, foyer, intro, krach, projets, rue, temoins, titres) ; `git rev-parse main:… == HEAD:…` identique pour les 9 ; `git log --follow` de `chapitres/1984/banque.json` remonte à l'ancien `data/banque.json` ; `demo.json` → `chapitre.json` (98 %) = ajout de la seule ligne `"id": "1984"`.
- [x] **CA-L4** `test_chapitres` 45 OK (bascule 1988→1989 comprise) ; ligne `MESURE debut_libre` imprimée : 20 parties démarrées en 1986-01 vont toutes au bout, 8 à 10 cartes, naissance d'avril 1985 sautée, 36 projets réalisés + 4 après report, rue visible dans 20 parties sur 20.
- [x] **CA-L5 Export** : les deux `include_filter` = `data/*.json, data/chapitres/*.json, data/chapitres/*/*.json, data/themes/*.json, data/pixel/*/*.txt` ; seule modification de `export_presets.cfg`. `--export-pack Windows` (1,4 Mo) : contient `data/chapitres/index.json`, `…/1984/{banque,chapitre,titres,evenements_vie}.json`, `data/salaires.json`, pas de `tests/donnees`. `--main-pack` avec le Godot non console, étapes `titre` et `jouer` : 0 ERROR / « introuvable » / « invalide » / SCRIPT ; capture relue : JANV 1984, 12 629 F, M. Lefranc à la fenêtre de la banque. (Note : le premier `--import` de la copie affiche un Parse Error sur `tests/recette/test_recette_fin_titres.tscn` ; artefact d'import à froid, absent de `tests.ps1`, fichier non touché par le lot.)
- [x] **CA-L6 Sauvegarde** : les 3 `.sav` écrits par main (06/1986, 10/1987, 06/1988) sont rejoués jusqu'à la fin **sur une copie de `main`** par mon propre script : lignes identiques, au chiffre près, à celles figées dans `test_chapitres` (ex. 0686 : 18 987,54215522 F / frais 122,12299452 / 26 interruptions / md5 e39529eee9c30b55475c19ef44ce4472) ; sur la branche : mêmes chiffres, chapitre « 1984 » ; sauvegarde écrite par la branche relue avec chapitre « 1984 ». Sauvegarde du joueur : non modifiée (hash).
- [x] **CA-L7** `valeur_table("technicien", 2023)` = 2530, 2025 = 2700, smn 2025 = 2870 ; épargne technicien 2021 = 18, 2022 = 16, 2023 = 16, 2024 = 18 ; 2022 = 2010 − 2 points pour chaque profil, 2024 = 2010 (tests verts).
- [x] **CA-L8 Périmètre** : tout le diff ⊂ colonne 09-L (data/, scripts/logique, partie.gd, tests logiques + nouveaux, export_presets, bases `dev-logique.md` / `developpeur.md`). Aucun fichier de `scripts/ui`, `scripts/ville`, `principal.gd`, `project.godot`, `tests/recette/`, aucun fichier d'`outils/`, aucun résidu. `tests.ps1` non modifié (autorisé, non nécessaire).
- Alias : `Donnees.charger("demo")` = `chapitre` (test), `config_demo` = `config_chapitre("1984")` ; les appelants d'interface (`principal.gd`, `modale_intro.gd`, `test_interface`) fonctionnent inchangés. Plus aucun `Marche.N` ni chemin `res://data/<fichier de chapitre>.json` dans le code.

### Jugement des écarts annoncés par le développeur
1. **Fin bornée seulement si la config porte « chapitre »** : acceptable. `config_chapitre` / `config_demo` posent la clé, donc toute partie réelle est bornée ; les configs de tests (sans clé) restent libres, ce qui était nécessaire pour la bascule d'essai et la mesure. Risque : un futur appelant qui bâtit sa config à la main contourne D3 (voir mineure M1).
2. **Jeu d'essai `tests/donnees/chapitres` = copies complètes de 1984 (et 1989)** au lieu de « minimalistes » : acceptable (la bascule est prouvée, exclu de l'export par `tests/*`), au prix de ~2 000 lignes dupliquées à resynchroniser si le format des fichiers change (M2).
3. **`Marche.N` remplacé par `n_cases`** (+ `nb_mois()`, `ANNEES_PAR_DEFAUT` 15) : acceptable, c'est ce que demande L4 ; P1 reste à 181 cases (`fin: 1992`), les tirages sont inchangés (parties de référence identiques au bit près).

### Anomalies
Aucune bloquante ni majeure.
- **M1 (mineure)** : la borne D3 dépend de la présence de `config["chapitre"]` ; à noter pour le lot 10 / 09-I (`principal._config()` doit passer par `config_chapitre`, ce que prévoit le plan).
- **M2 (mineure)** : copies complètes de 1984 dans `tests/donnees/` (dette de maintenance).
- **M3 (mineure, documentaire)** : `HISTORIQUE_MAX` reste à 600, signalé par le développeur comme limite pour le lot 10.

### Non vérifié
Aucune capture d'écran du lot (hors CA-L5, hors périmètre) ; bascule réelle de chapitre non jouable avant le lot 10 (éprouvée sur le jeu d'essai seulement) ; sauvegarde 0.6.x réelle du joueur non rejouée (le fichier du joueur est resté intact ; les 3 sauvegardes de main couvrent le même format 3).
