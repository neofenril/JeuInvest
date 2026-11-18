# Lot 09-V : recette courte (testeur)

## Passage 1 : 2026-11-18, branche `lot/09-ville`, commit testé a4aef5f (base `main` 68d6f7d)

**Verdict : OK** (0 anomalie bloquante ou majeure ; 2 mineures).

### Périmètre (CA-V4)
`git diff main...lot/09-ville --stat` : 9 fichiers, tous dans la colonne 09-V du plan : `scripts/ville/rue.gd`, `ville.gd`, `theme_decor.gd` + `.uid` (nouveaux), `data/themes/1980.json` (contrat §3), `outils/capture_ville.ps1`, `scripts/outils/scenarios/ville.gd`, `tests/test_rue.gd`, `docs/connaissances/dev-ville.md`. Aucun fichier d'interface, de logique, de sauvegarde, d'`outils/`, aucune capture. Worktree propre.

### Tests
`tests.ps1` (sans `-Recette`) sur la branche : **1 098 vérifications OK, 0 KO, 0 erreur de script, 0 échec** (181,6 s) ; `test_rue` 106 OK, `test_pixel` 78 OK. Lignes clés : `RUE theme=1980 identique_main=oui couleurs_hors_palette=0 ancres_identiques=oui` ; `RUE theme=essai pixels_changes=1212 ancres_identiques=oui noeuds_fuites=0 retour_1980=oui` ; test du report d'un changement de thème pendant une séquence animée vert. Les 2 WARNING `ThemeDecor : thème « nexiste_pas » / « essai » inconnu` sont voulus (thème inconnu = table vide).
`partie_en_cours.sav` (SHA-256 0EFB110DAC59...) inchangé ; `records.sav` absent avant et après.

### Captures (`capture_ville.ps1`, branche sans option ×2, branche `-Theme 1980`, `main` ; copie isolée pour `main`)
Étapes : `rue_libre`, `rue`, `rue_nuit` (PC 1920×1080), `rue_libre`, `rue`, `rue_nuit` (téléphone 1440×648). Fichiers `godot/captures/t09_*` du worktree et de la copie de `main`.
- **Gigue des hachages confirmée, sans rapport avec le thème** : les deux captures témoins « sans option » de la branche diffèrent entre elles (ex. `rue_nuit` téléphone : 6D3A... vs 70AB... ; `rue` PC : 42F0... vs D999...), car piétons, voitures, nuages et horloge du HUD bougent entre deux lancements. Les PNG ne sont pas déterministes au hachage hors `rue_libre` PC (où les deux témoins sont identiques).
- **Décor statique (bandeau haut des images : façades, fenêtres, arbres, ciel)** : 0 pixel de différence entre sans option, `-Theme 1980` et `main` pour `rue_libre` PC (y < 450), `rue_libre` / `rue` / `rue_nuit` téléphone (35 % supérieurs). `rue` et `rue_nuit` PC : 73 à 157 pixels de différence dans le bandeau (HUD animé, lumières), du même ordre que l'écart entre les deux témoins sans option (15 et 107) : bruit d'animation. Les différences de `rue_libre` PC (≈ 6 800 pixels sur un échantillon 1/4) se limitent aux piétons et voitures (relu : positions différentes, façades identiques).
- Relu : `t09_rue_libre_pc_a/_th` (images identiques à l'animation près), `t09_rue_nuit_pc_th` (fenêtres allumées, lampadaire, HUD lisibles, rien de coupé).

### Critères d'acceptation
- [x] **CA-V1 ★** thème « 1980 » identique à `main` : preuve par construction et par `test_rue` (`identique_main=oui`, images et couches), confirmée visuellement et par différence de pixels sur le décor statique des captures. Le hachage de l'image entière du `SubViewport` n'a pas été recalculé par moi (hors scénarios de capture), seulement par le test du développeur.
- [x] **CA-V2 ★** thème d'essai : 1 212 pixels changés, ancres identiques, 0 nœud fuité, retour exact à 1980.
- [x] **CA-V3 ★** `-Theme 1980` ≡ sans option (décor identique, étapes `rue` PC et téléphone ; à l'animation près, voir gigue).
- [x] **CA-V4 ★** `test_rue` et `test_pixel` verts, périmètre ⊂ 09-V.
- [ ] CA-I3 : hors lot 09-V (lot 09-I).

### Anomalies
- **A1 (mineure)** : `ville.gd` / `capture_ville.ps1` : l'option `--theme` n'imprime `RUE theme=…` / `THEME …` qu'avec `-Controle` ; sans, aucune trace du thème appliqué dans le journal (info : pas de preuve que l'option a été lue pour une capture sans `-Controle`). Non bloquant.
- **A2 (mineure)** : captures PNG des étapes animées non déterministes au hachage : prévoir, pour les prochaines recettes de la ville, une comparaison par zone (décor sans personnages) plutôt qu'un hachage global.

### Non vérifié
Rendu d'un vrai thème autre que « 1980 » (table vide pour l'instant : seul le thème d'essai de test existe) ; bascule en cours de partie dans le jeu complet (09-I) ; comportement sur vrai téléphone.
