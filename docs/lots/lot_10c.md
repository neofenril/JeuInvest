# Lot 10c : pilote carrière (K4, K5) et sortie 0.7 « dix ans »

> Chef de projet, 2026-11-18. Troisième sous-lot de la **0.7**. Sources : `etude_carriere.md` (8 réponses par défaut **validées par le joueur**), docs/42 (cartes K4, K5), **docs/47 §6** (prime : K4 et K5 **toujours présentées**, statut « prenant », compteur d'années tendues), docs/46 §4.3 (congé formation : 90 % pendant 10 mois), docs/43 §7 (variante minimale d'interface).
> Base : 10c-L après la fusion de `lot/10a-contenu` ; 10c-I après la fusion de `lot/10b-interface`.

## 0. En bref

| Branche | Qui | Quand | Durée |
|---|---|---|---|
| `lot/10c-logique` | dev-logique | après la fusion de 10a-contenu | ≈ 3 j |
| `lot/10c-interface` | dev-interface | après la fusion de 10b-interface **et** de 10c-logique | ≈ 1,5 j |

- **Rien en 1984-1988** (`test_reference_1984` inchangé). K4 (09-12/1989, créneau S2) et K5 (02/1991, créneau S5) en 1989-1993, pour Gérard et pour Christine.
- Variante minimale d'interface : la carte du foyer existante, 2 boutons au **montant mensuel**, une ligne « Épargne possible : avant → après », une ligne « Métier » dans « Mon foyer ». Pas de lettre à en-tête, pas de trajet de Gérard.
- Puis **recette finale du lot 10** sur la fusion complète et **export 0.7** (§6).

Worktrees : `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot10c-logique`, `lot10c-interface`.

## 1. Décisions

| # | Décision |
|---|---|
| D1 | **Une augmentation va entièrement à l'épargne possible** (le train de vie ne suit pas) et une baisse la réduit d'autant : nouveau terme `revenu_mois` (écart de revenu hors train de vie) dans le calcul du mois, partagé avec les voisins (R-MIROIR). La liste d'effets de salaire de 10a reste pour les effets « train de vie » (CNAM, promotion). |
| D2 | K4 et K5 **toujours présentées** (docs/47 §6) : cartes **fixes** des créneaux S2 et S5 de 1989 (C02 passe en S1, C12 en S9, la formation de docs/39 est remplacée par K5). |
| D3 | Statut « prenant » (K4 a) : usure de l'humeur de −1 chaque janvier quelle que soit l'humeur ; fin du statut à la sortie de K5 a. **Compteur d'années tendues** (proche fâché au 31/12 et statut prenant) sauvegardé, **sans effet** (le divorce viendra au lot 12). Temps libre = humeur seulement. |
| D4 | K5 a : 90 % du salaire pendant 10 mois (docs/46 §4.3, au lieu de −10 % : identique), puis + 8 % en 01/1992. Nature des deux cartes : `neutre` (aucun effet sur fourmi ou cigale). Aucun titre ni étoile lié. |
| D5 | Plafond : 3 moments de carrière par chapitre (K4, promotion CNAM, K5), au moins 4 mois entre deux (docs/47 §6). |
| D6 | Version 0.7 / code Android 11 : `project.godot` (`config/version`) et `export_presets.cfg` (4 lignes) **prêtés à dev-logique** dans 10c-L (précédent du lot 03-R). |

## 2. Fichiers attribués

| Fichier | 10c-logique | 10c-interface |
|---|---|---|
| `godot/data/chapitres/1989/foyer.json`, `profils.json` (ligne « Métier »), `godot/scripts/logique/foyer.gd`, `etat_partie.gd`, `bilan.gd`, `partie.gd` | ✔ | |
| `godot/tests/test_foyer.gd`, `test_chapitre_1989.gd`, `test_carriere.gd` (**nouveau**) | ✔ | |
| `godot/project.godot` (ligne `config/version` seule), `godot/export_presets.cfg` (versions seules) | ✔ (prêt) | |
| `godot/scripts/ui/modale_carte.gd`, `modale_foyer.gd`, scénarios d'interface, `test_interface.*` | | ✔ |
| Bases | ✔ | ✔ |

Interdits : 1984-1988 (`data/chapitres/1984/**`), `test_reference_1984`, `scripts/ville/`, `principal.gd` (aucun besoin), `tests/recette/`.

## 3. Contrat (ajouts)

```
# contenu_modale() d'une carte de carrière (kind "carte") : champs ajoutés
"carriere": true
"choix": [{ ..., "revenu_mois": float (signé, en devise du jeu), "epargne_avant": float, "epargne_apres": float }]
# EtatPartie
func metier() -> String               # « Technicien », « Technico-commercial itinérant »… (données du profil et des cartes)
func statut_carriere() -> String      # "normal" | "prenant"
e.foyer["annees_tendues"] : int        # sauvegardé, sans effet
```

## 4. Critères d'acceptation

### 10c-logique
- **CA-C1 ★** `test_reference_1984` inchangé et vert ; aucune carte K en 1984-1988.
- **CA-C2 ★** K4 présentée dans 100 % des parties 1989 (Gérard et Christine, 200 graines P-REF chacune), K5 aussi (sauf faillite) ; jamais deux moments de carrière à moins de 4 mois.
- **CA-C3 ★** `epargne_apres − epargne_avant` == `revenu_mois` au centime ; R-MIROIR : Tata et Tonton reçoivent le même écart de revenu ; K5 a : 10 mois à 90 %, puis + 8 % exactement en 01/1992.
- **CA-C4 ★ Aucune option dominante** (critère du client, docs/44 §7) : sur P-REF, pour K4 comme pour K5, chaque option est la meilleure en patrimoine **ou** en humeur selon les graines (lignes imprimées : part des graines où a bat b en patrimoine, en humeur) ; écart de patrimoine médian en fin de chapitre entre a et b **entre 5 et 10 %** (mesure ; hors plage = point d'arrêt, réglage par les montants seulement).
- **CA-C5 ★** Statut prenant (usure de janvier), compteur d'années tendues sauvegardé et relu ; aucune valeur de titre ou d'étoile ne dépend de K4 / K5.
- **CA-C6 ★** Calibrage de 10a-contenu toujours tenu (CA-N3, CA-N4 de `lot_10a.md`) avec K4 et K5 ; version 0.7 / code 11 dans `project.godot` et les 4 lignes d'`export_presets.cfg`.

### 10c-interface
- **CA-C7 ★** Carte de carrière : montant **par mois** signé dans chaque bouton, ligne « Épargne possible : {avant} → {après} par mois » == contenu ; picto d'humeur du proche ; aucune autre différence avec la carte du foyer ; PC et 2 téléphones, `debordements=0`.
- **CA-C8 ★** « Mon foyer » : ligne « Métier » == `metier()` ; captures `carriere_k4`, `carriere_k5`, `mon_foyer_metier`.

## 5. Ordre

10a-contenu fusionné → 10c-logique → recette courte → fusion. 10b-interface et 10c-logique fusionnés → 10c-interface → recette = **recette finale du lot 10** (§6).

## 6. Recette finale du lot 10 et export 0.7

Sur `main` après la fusion de 10c-interface (fusion complète 10a + 10b + 10c) :
1. `tests.ps1 -Recette -Delai 700` vert, 0 erreur de script ; `test_reference_1984` identique depuis le lot 09.
2. **Série de captures complète** (règle du 17/11) : `capture_interface.ps1 -Serie` et `capture_ville.ps1 -Serie`, PC 1920 × 1080 (et 1920 × 1009 pour la frise), téléphones 1440 × 648 et 1280 × 720 ; étapes nouvelles de `lot_10b.md` §4 (I11, V4) et §4 ci-dessus ; 1984-1988 comparé à la série de la 0.6.2.
3. Deux parties complètes par la vraie interface : 1984 → 1993 (Gérard) et 1989 → 1993 (Christine), records et sauvegarde isolés ; temps mesuré (cible ≈ 20 min par chapitre, CA-N6).
4. Exe et APK : `--export-pack` + `--main-pack` (étapes `titre`, `jouer`, `reprise`, `passage_1989`) : aucune erreur, données de `data/chapitres/1989/` et `data/produits.json` présentes.
5. Valeurs C confirmées ou gardées avec mention (A2, A4 de `lot_10a.md`) : le coordinateur demande au boursier (fins de mois 08/1990, 09/1991, dividendes 1989-1993, BNP) et au banquier (SCPI) **pendant** le développement ; une correction arrivée avant l'export = commit de données de dev-logique + relance de `test_chapitre_1989`.
6. Rapport : `docs/lots/lot_10_recette.md`. OK → fusion, export 0.7 (exe + APK), fiche de retour pour le joueur (questions : hésitation sur K4 / K5, passage de chapitre, longueur de la partie, SCPI et Jean-Mi).

## 7. Conflits avec la suite

- Lot 11 (vie aléatoire, re-gel de 1984) reprend `foyer.gd` et `evenements_vie` : après l'export 0.7.
- Lot 12 : divorce branché sur `annees_tendues` (lien faible, docs/45 §2 bis) ; statut « du temps » éventuel ; création de partie complète remplace le choix minimal de 10b.
- Version complète de la carrière (lettre à en-tête, trajet de Gérard, K6, K7) : seulement après le verdict du joueur sur la 0.7.
