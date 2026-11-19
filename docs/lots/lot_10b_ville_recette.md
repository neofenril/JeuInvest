# Lot 10b-ville : recette courte

## Passage 1 (2026-11-19, `lot/10b-ville`, commit testé 45c9b91, base d9059eb)

**Verdict : OK** (0 anomalie bloquante ou majeure ; 2 mineures).

### Vérifications
- Périmètre : 19 fichiers, tous dans la colonne 10b-ville (`scripts/ville`, `scripts/pixel`, `data/themes`, `scenarios/ville.gd`, `capture_ville.ps1`, `test_rue.gd`, `dev-ville.md`) ; ni capture, ni fichier d'`outils/`, ni secret ; seuls `.uid` des 2 nouveaux scripts en plus. `git status` du worktree propre.
- `tests.ps1` complet : 24 étapes, **1 236 vérifications OK**, 0 KO, 0 erreur de script, sauvegarde et records du joueur inchangés (1er passage, stable).
- CA-V1 : `RUE theme=1980 avant_1989 identique_main=oui` ; contre-épreuve indépendante : captures `rue` et `rue_nuit` (mai 1987, sans HUD) branche contre copie isolée de la base d9059eb, bandeau de décor 10-40 % de hauteur : **0 pixel différent sur 155 520** (jour et nuit). Palette : `hors_palette=0` sur les 4 scénarios.
- CA-V2 : 6 cas `RUE foyer=…` (Gérard 26 ans + bébé, Gérard 35 ans + 2 enfants / jumeaux, Christine + Patrick + 2 enfants, joueuse + conjoint homme, sans proche) : `hors_palette=0 idempotent=oui`.
- CA-V3 : `foyer_christine`, `foyer_gerard_1993`, `rue_1991`, `tele_golfe` : code 0, `RUE tele sujet=golfe active=true texte=0`, variantes `citadine_1990` / `citadine_1993` / `bonne_annee:1991` visibles dans les bonnes années seulement. Relu : Christine (fenêtre : conjoint homme) et télé (fenêtre orange avec silhouette, sans texte) corrects.
- `traces_foyer.gd` (tricycle limité à 01-12/1988) : sans effet 1984-1988 (la partie s'arrête en 12/1988) ; `rue` identique à la base.

### Mineures
- M1 : la ligne `identique_main` de `test_rue` compare la rue à elle-même avant/après (auto-référence), pas à `main` ; je l'ai contre-vérifiée à la main (ci-dessus).
- M2 : `1980.json` sans retour à la ligne final (cosmétique). La télé est très petite à 1920x1080 (silhouette difficile à lire) : à juger en mouvement.

### Non vérifié
Rendu en mouvement (télé 6 s, variantes saisonnières), vrai téléphone, joueuse « Sylvie » avec conjoint « Gérard » à l'écran (couvert par le cas `joueuse_conjoint_h` en test seulement).
