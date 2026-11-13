# Lot 04 : recettes

## 03-V2 (recette courte, 2026-11-13) : `lot/03-ville2`, commit testé 47c00e2

**Verdict : OK** (0 anomalie bloquante ou majeure ; 2 mineures).

Critères : `lot_04.md` §12.2 (recette courte, CA-V1 à V5). Worktree `lot03-ville2`, machine libre pour les mesures (aucun test lancé pendant la série de captures).

### Critères d'acceptation

- [x] **CA-V1 ★** : `tests.ps1 -Recette` code 0, **755 vérifications OK, 0 KO, 0 erreur de script** (main = 725) ; `test_pieces` 62, `test_rue` 102. Tests des parties gardées : les 17 règles de D11 pour les traces dessinées (`TRACES_DESSINEES` n'existe pas sous ce nom : ce sont `TRACES.ORDRE` et `ville.traces_dessinees()`) sont dans `test_pieces._tests_traces` (cartes éteintes = vide, y compris carte inscrite) ; `suivre_foyer` cartes éteintes = Sylvie neutre, aucune trace, dans `test_rue`. Contrôle de recette : un test de plus de ma part (ci-dessous) : 11 vérifications.
- [x] **CA-V2 ★ (routage)** :
  - `carte_sortie` : `RUE carte sortie=0.61 porte=3 carte=courrier`, `RUE carte affichee genre=courrier modales_carte=non choix=a`, `RUE carte suite … modale=vide mois_suivant=oui choisie=a` : repli courrier, la partie continue, sortie 0,61 s (≤ 1 s).
  - Mon `tests/recette/test_recette_routage.gd` (3 passages, 11 OK à chaque fois) : carte réelle (sortie 0,61 s, choix, partie qui avance) ; contenu `kind "projet"` et contenu `kind "gazette"` (modèle : un vrai courrier de vie dont on change le kind ; le moteur de cette branche ne produit pas ces kinds) : ouvrent le **courrier** (`genre_courant == "courrier"`), la séquence se termine, la ville redevient interactive, la partie avance au mois suivant.
  - Écart de forme : la ligne attendue `RUE fiche kind=carte appel=courrier` n'existe pas ; l'équivalent imprimé est `RUE carte … carte=courrier` (voir mineure M1).
- [x] **CA-V3 ★** : `capture_ville.ps1 -Serie` complète, **84 lancements, code 0, « PX1 : tout est vert »**, 0 échec, 0 SCRIPT ERROR / Parse Error, `hors_palette=0`, `irreguliers=0` partout. `RUE flottant indice=0 chevauchements=0` : 20 occurrences (étapes `pieces_*` PC 1920 × 1080, téléphone 1440 × 648 et téléphone 1280 × 720), aucune non nulle. Journal : `godot/captures/px1_serie.log` (ignoré par Git).
- [x] **CA-V4** : `sylvie_humeurs` (PC `_h0/_h1/_h2` et 1440 × 648 `_tel_h0/_h1/_h2`) relues : contente (sourire, coudes écartés), neutre (visage calme), contrariée (sourcils froncés, bras croisés) se distinguent à PC ; à 1440 × 648 la distinction sourire / froncé reste lisible, la posture moins (petit). Pas d'exigence de ×1.
- [x] **CA-V5 ★ (périmètre)** : `git diff --stat main...lot/03-ville2` : 15 fichiers, tous dans la colonne 03-V2 du §3 (`scripts/ville/*`, `scripts/pixel/personnages.gd` et `voisins.gd`, `scenarios/ville.gd`, `capture_ville.ps1`, `test_pieces`, `test_rue`, `dev-ville.md`) ; rien d'`outils/`, de capture ou de secret. API : une seule ligne `-func` supprimée, `Personnages.sylvie(humeur)` devenue `sylvie(humeur, coucou := 0)` (paramètre optionnel : compatible). `lot/03-ville2` et `lot/03-ville2-suite` : **aucune des deux n'est sur `origin`** (`ls-remote --heads`) ; la branche `-suite` n'existe pas non plus en local (rien de non fini mis de côté, ou non créée : à confirmer par le compte rendu).
- Sauvegarde du joueur : `partie_en_cours.sav` **absent** avant, pendant (tests.ps1 : « inchangée (absente) ») et après. Dépôt principal : mes seules écritures sont dans le worktree (test de recette + ce rapport).

### Relecture des images (PC et 1440 × 648)
- `carte_sortie` `_porte` (porte à demi ouverte, caméra revenue sur la maison) et `_carte` (courrier « Les vacances 84 », deux choix) : corrects, pas de débordement.
- `pieces_or_cuivre_tel_cartouches` : « + 312 F ce mois-ci / versés en décembre », « Elf : + 840 F », « − 45 F de frais » : plus de mélange intérêts / dividendes, cartouches ni superposés ni sur le panneau INDICE ni sur les piles.

### Anomalies (mineures)
- **M1** (mineure) : la ligne de contrôle `RUE fiche kind=… appel=courrier` demandée par CA-V2 n'est pas imprimée ; le dev-ville imprime `RUE carte sortie=… carte=courrier`. Le routage `projet` / `gazette` n'a pas de trace dans le journal des captures (seul mon test le prouve). Aucun effet pour le joueur.
- **M2** (mineure, informative) : un contenu `projet` ou `gazette` passe par la séquence courrier complète (enveloppe) : 1,86 s avant l'ouverture, contre 0,61 s pour la carte. Le « ≤ 1 s » ne vaut que pour la sortie de la carte ; à reprendre quand les projets auront leur sortie (04-V).

### Non vérifié
- Ressenti en mouvement (clignement, coucou, transition d'humeur) : seules les images fixes ont été relues ; vrai téléphone.
- `traces_foyer` sur une partie entière (étape retirée du périmètre ; la série n'en contient qu'une partie à graine fixe) ; l'aspect dessiné de `diplome` et `escargot` (façade) n'a pas été relu à l'image.
- Fusion avec 03-R / 04-L : non simulée (§12.1).
