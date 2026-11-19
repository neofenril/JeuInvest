# Lot 10b : chapitre 1989-1993, interface et ville

> Chef de projet, 2026-11-18. Deuxième sous-lot de la **0.7 « dix ans »**. Contrat logique : `lot_10a.md` §4 (figé). Maquettes : **docs/40** (frise sur 10 ans §1.1, carte de passage version A §1.2.3, décor 1984-1993 §1.3, bilan final §2, double record §3), docs/47 (vitrine en 2 étapes §1, SCPI §3), docs/29 (écran de fin), docs/17 (cartes, « Mon foyer »).
> Base : `main` après la fusion de `lot/09-interface`.

## 0. En bref

| Branche | Qui | Quand | Durée |
|---|---|---|---|
| `lot/10b-ville` | dev-ville | **dès la fusion de 09-I**, en parallèle de 10a-moteur | ≈ 5 j |
| `lot/10b-interface` | dev-interface | **étape 1** dès la fusion de 09-I ; **étape 2** après la fusion de 10a-moteur (le coordinateur fusionne `main` dans la branche) | ≈ 11 j |

- **10b-ville** : foyer visible paramétrable (Christine, Patrick, Aurélie, Julien ; Gérard et ses enfants qui vieillissent), variantes datées 1989-1993 du décor unique 1984-1993, télévision de la maison pour l'étape 1 de la vitrine, routage des nouvelles modales dans `Sequences`.
- **10b-interface, étape 1** (ne dépend que de ce qui est sur `main`) : frise et courbe de « Mon argent » sur toute la partie, carnet de la banque au-delà de 9 produits, noms lus dans les données (inventaire H17 de 09-I).
- **10b-interface, étape 2** (contrat de 10a) : carte de passage, vitrine en courbe, bilan final (un titre par chapitre, double record), écran titre et collection par chapitre, fiches et ordres PEA / SCPI (vente différée), PEP « En savoir plus », choix du départ (1984 Gérard / 1989 Christine), branchement de `foyer_visuel()`.
- Recette finale du lot 10 : **sur la fusion complète** (10a + 10b + 10c), série de captures complète, puis export 0.7 (`lot_10c.md` §6).

Worktrees : `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot10b-ville`, `lot10b-interface`.
```
outils\git\cmd\git.exe -C C:\Users\arthu\Documents\temp\JeuClaude worktree add C:\Users\arthu\Documents\temp\JeuClaude_lots\lot10b-ville -b lot/10b-ville main
outils\git\cmd\git.exe -C C:\Users\arthu\Documents\temp\JeuClaude worktree add C:\Users\arthu\Documents\temp\JeuClaude_lots\lot10b-interface -b lot/10b-interface main
```

## 1. Décisions

| # | Décision |
|---|---|
| D1 | **Un seul décor 1984-1993** (thème « 1980 ») ; ce qui vieillit passe par des **variantes datées** (`data/themes/1980.json > variantes_datees`, docs/40 §1.3), jamais par un nouveau thème. Le décor de 1984-1988 reste **identique au pixel** (aucune variante avant 01/1989). |
| D2 | Carte de passage **version A** (docs/40 §1.2.3) : pas de titre révélé, « Votre titre d'époque 1984-1988 vous attend au bilan final. » ; la rue ne change pas, pas de chargement. |
| D3 | Vitrine du Golfe (arbitrage A1 de `lot_10a.md`) : étape 1 = notification sans pause + télévision de la maison ; étape 2 = modale du krach **existante**, avec une courbe de 3 points de fin de mois et la mention fixe à la place du tableau des jours. |
| D4 | Carnet de la banque : la grille 3 × 3 ne suffit plus (jusqu'à 13 produits en 1993) : grille de **4 colonnes** au PC et défilement vertical au téléphone ; produits vus seulement ; ordre = `ordre_carnet` du chapitre actif. |
| D5 | SCPI : la ligne affiche la **valeur de revente** (les frais se voient tout de suite) ; une vente en attente est visible dans la fiche (« Vente en cours : exécution en {mois} », bouton ANNULER). PEA : enveloppe affichée comme un sous-bloc du carnet (ouvrir, verser, lignes éligibles). |
| D6 | Choix du départ, **minimal** en attendant l'écran complet du lot 12 : sur l'écran titre, « NOUVELLE PARTIE » ouvre un choix à 2 cartes (« Janvier 1984 · Gérard » / « Janvier 1989 · Christine ») ; pop-up de début du profil choisi. |
| D7 | Double record (docs/40 §3) : écran titre = rangée « Meilleur résultat » par chapitre de départ (record de chapitre et record de partie) ; bilan final = 2 lignes ; collection = un onglet par chapitre. |
| D8 | `principal.gd` reste du câblage (≤ 650 lignes) ; tout nouvel écran = un nouveau fichier `ui/`. |

## 1 bis. Règle « textes sans genre en dur » (exigence du joueur du 18/11)

- Aucun texte affiché ne contient « Sylvie », « Gérard », « il / elle », « Monsieur », un accord ou un prénom de profil en dur : l'interface affiche les textes **déjà rendus** par la logique (`Gabarits`, `lot_10a.md` §1 bis) et lit les prénoms dans `foyer_visuel()` / `infos_chapitre()`.
- **10b-interface, étape 1 (tâche I4 élargie, ≈ +1,5 j)** : les ≈ 12 lignes d'affichage en dur relevées dans `hud.gd`, `modale_foyer.gd`, `modale_projet.gd`, `modale_releve_fin.gd`, `modale_carte.gd`, `bulle.gd` (inventaire I3 de 09-I) passent par les données ; les noms de méthodes et commentaires (`regler_humeur_sylvie`, `FENETRE_SYLVIE`) peuvent rester. **Portraits** (`portrait.gd`) : joueuse et conjoint homme, 3 humeurs, PC et téléphones (≈ +1 j, étape 2) ; Christine et Patrick en ont besoin dès ce lot.
- **10b-ville (V1 élargie, ≈ +1 j)** : le personnage du joueur et le conjoint à la fenêtre suivent `sexe` de `foyer_visuel()` (cas d'essai obligatoire : joueuse « Sylvie » et conjoint « Gérard ») ; les ≈ 50 occurrences de `maison.gd`, `ville.gd`, `rue.gd`, `sequences.gd` sont surtout des identifiants : les renommer n'est **pas** demandé.
- **CA-I10 ★** (au lot 10 : écrans de **1989-1993** seulement ; 1984-1988 après la neutralisation de ses données au lot 11, `lot_10a.md` §8 bis) : avec un profil d'essai féminin, captures `mon_foyer`, carte du foyer, projet, passage, fin, intro : aucun « Sylvie » ni accord masculin visibles pour la joueuse ; pour Gérard, images identiques à `main`. **CA-V5 ★** : `RUE foyer=joueuse_conjoint_h` correct.

## 2. Fichiers attribués

| Fichier | 10b-ville | 10b-interface |
|---|---|---|
| `godot/scripts/ville/*.gd` (dont `sequences.gd`, `maison.gd`, `passant.gd`, `ville.gd`, `rue.gd`, `theme_decor.gd`), `godot/scripts/pixel/*.gd`, `godot/scripts/juice.gd` | ✔ | |
| `godot/data/themes/**`, `godot/data/pixel/**` | ✔ | |
| `godot/scripts/outils/scenarios/ville.gd`, `godot/outils/capture_ville.ps1`, `godot/tests/test_rue.gd`, `test_pixel.gd`, `test_pieces.gd` | ✔ | |
| `godot/scripts/principal.gd`, `godot/scripts/ui/*.gd` (dont nouveaux `modale_passage.gd`, `choix_depart.gd`), `godot/scripts/outils/scenarios/{titre,banque,ecrans,interface,outils}.gd`, `godot/outils/capture_interface.ps1` | | ✔ |
| `godot/tests/test_interface.*`, `test_partie.*`, `test_ecran.*` | | ✔ |
| `godot/project.godot` | | ✔ (aucun changement attendu ; la version 0.7 est au lot 10c) |
| Bases `dev-ville.md` / `dev-interface.md` | ✔ | ✔ |

**Interdits aux deux** : `data/*.json` hors thèmes, `data/chapitres/**`, `scripts/logique/`, `partie.gd`, `export_presets.cfg`, `tests/recette/`, `test_reference_1984`. Tout besoin logique = compte rendu au chef de projet (jamais de contournement dans l'interface : règle « aucune règle de jeu calculée dans l'UI »).

## 3. Contrat entre 10b-ville et 10b-interface (figé)

```
# Ville (dev-ville), appelé par principal.gd via has_method
ville.regler_foyer_visuel(d: Dictionary) -> void   # format de EtatPartie.foyer_visuel() (lot_10a.md §4) ; idempotent ;
                                                   # au démarrage, à la reprise, chaque janvier, à chaque naissance ou mariage
ville.montrer_tele(sujet: String, duree_s := 6.0)  # « golfe » : silhouette de chars à l'écran de la télé de la maison ; jamais de texte
# Sequences (dev-ville) : routage de contenu_modale()["kind"]
"passage" -> Modales.passage(c, depart)  si has_method, sinon courrier   (sortie : depuis la porte de la maison, comme une carte)
"marche" avec "courbe" -> Modales.marche(c, depart) existant (la modale lit "courbe" au lieu de "jours")
n["vitrine_etape"] == 1 -> ville.montrer_tele("golfe") puis la notification (aucune pause)
# Interface (dev-interface)
Modales.passage(c: Dictionary, depart: Vector2) -> void   # nouvelle sorte, fichier ui/modale_passage.gd
```
Le format de `foyer_visuel()` vient de `lot_10a.md` §4 ; 10b-ville le teste avec des dictionnaires fabriqués (aucune dépendance au code de 10a).

## 4. Tâches

### 4.1 10b-ville
- **V1** Foyer paramétrable : le personnage du joueur (homme ou femme, âge : silhouette 20-35 / 36-55 ans), le proche (conjoint ou ami, à la fenêtre du conjoint), les enfants par âge (bébé < 2 ans, petit 2-6, enfant 7-12, ado 13+ : sprites générés en code, palette existante) ; Gérard 1984 → 1993 et ses enfants qui grandissent ; Christine, Patrick (ouvrier), Aurélie (8 ans), Julien (5 ans).
- **V2** Variantes datées 1989-1993 dans `data/themes/1980.json` (docs/40 §1.3 : ce qui vieillit quand même) ; aucune variante avant 01/1989 ; elles se lisent par la date (mécanisme du lot 09).
- **V3** Télévision de la maison (`montrer_tele`) et routage de `Sequences` (§3).
- **V4** Scénarios de capture `ville` : `foyer_christine`, `foyer_gerard_1993`, `rue_1991`, `tele_golfe` ; `test_rue` : lignes `RUE foyer=… sprites=… hors_palette=0`, `RUE theme=1980 avant_1989 identique_main=oui`.

### 4.2 10b-interface, étape 1 (indépendante de 10a)
- **I1** (corrige aussi M2 de `lot_09i_recette.md` : `m_fin` de la frise à 0 avant le premier `Hud.maj`) Frise sur toute la partie (docs/40 §1.1 : rail continu, coupures de chapitre, drapeau à la dernière année implémentée) à partir de `m_depart`, `m_fin`, `Donnees.chapitres()` ; PC et téléphones.
- **I2** Courbe de « Mon argent » sur toute la durée (vous / Tata), avec la coupure de chapitre.
- **I3** Carnet de la banque au-delà de 9 produits (D4), sans changer l'aspect à 9 produits ou moins (1984-1988 identique).
- **I4** Noms et textes encore en dur relevés par 09-I (inventaire H17) : lus dans `infos_chapitre()` / `foyer_visuel()` ou dans les données, à textes identiques pour 1984-1988.

### 4.3 10b-interface, étape 2 (après fusion de 10a-moteur dans la branche)
- **I5** `Modales.passage` (docs/40 §1.2.3), PC et téléphones.
- **I6** Modale de vitrine en courbe (3 points, mention) ; « un an après » de 1991 sur l'écran existant.
- **I7** Bilan final : une plaque de titre par chapitre traversé, 2 lignes de record, courbe sur toute la durée (docs/40 §2) ; écran titre (rangée par chapitre de départ) et collection par chapitre (docs/40 §3.2-3.4, sans étoiles : lot 12).
- **I8** Fiches PEA et SCPI (carte à 5 critères existante), ordres dans l'enveloppe PEA, vente différée de la SCPI et son annulation (D5) ; PEP : « En savoir plus » par la relecture longue existante.
- **I9** Choix du départ (D6) et pop-up de début de Christine (`intro.json` du chapitre 1989) ; `principal._config()` passe le chapitre choisi à `config_chapitre` (fin par défaut = dernière année).
- **I10** Branchements : `ville.regler_foyer_visuel(Partie.etat.foyer_visuel())`, `chapitre_change` (thème, `infos_chapitre`), BNP « Nouvelle action au catalogue » (notification existante).
- **I11** Scénarios de capture : `frise_10ans`, `mon_argent_10ans`, `carnet_13`, `passage_1989`, `vitrine_golfe_etape1`, `vitrine_golfe`, `golfe_un_an_apres`, `fiche_pea`, `fiche_scpi`, `vente_differee`, `pep_en_savoir_plus`, `choix_depart`, `intro_christine`, `fin_1993` (2 titres, 2 records), `titre_palmares_v2`, `collection_chapitres` ; aucune étape existante ne change d'image en 1984-1988.

## 5. Critères d'acceptation

### 10b-ville (recette courte)
- **CA-V1 ★** Décor de 1984-1988 identique au pixel à `main` (zone de décor, sans personnages : leçon de la recette 09-V) ; aucune couleur hors palette.
- **CA-V2 ★** `regler_foyer_visuel` : 6 dictionnaires fabriqués (Gérard 26 et 35 ans, avec bébé / 2 enfants / jumeaux ; Christine avec Patrick et 2 enfants ; foyer sans proche) donnent les bons sprites (ligne `RUE foyer=` par cas) ; idempotent ; 0 nœud fuité.
- **CA-V3 ★** Variantes datées visibles seulement à partir de leur date ; `tele_golfe` sans texte ; routage `passage` avec repli `courrier` quand `Modales.passage` n'existe pas.
- **CA-V4 ★** `test_rue`, `test_pixel`, `test_pieces` verts ; périmètre ⊂ colonne 10b-ville.

### 10b-interface
- **CA-I1 ★** 1984-1988 inchangé : captures de la série existante comparées à `main` (titre, intro, jouer, krach, fin, banque, carnet à 9) : aucune différence hors animation.
- **CA-I2 ★** Frise et « Mon argent » sur 120 mois : lisibles PC 1920 × 1080, 1920 × 1009, téléphones 1440 × 648 et 1280 × 720 ; `debordements=0 hors_cadre=0 hors_ecran=0`, chiffres en Atkinson, cibles ≥ seuils de docs/16.
- **CA-I3 ★** Carnet à 13 produits : tous visibles (défilement au téléphone), cibles ≥ seuils, aucun chevauchement.
- **CA-I4 ★** Carte de passage : chiffres == `contenu_modale()` (patrimoine, écart, rang), aucun titre révélé, CONTINUER seul bouton ; PC et 2 téléphones.
- **CA-I5 ★** Vitrine : 3 points, mention fixe, ordres possibles ; étape 1 sans pause (le temps continue, `Partie.vitesse` inchangée).
- **CA-I6 ★** Bilan final d'une partie 1984 → 1993 : 2 plaques de titre == `bilan["titres"]`, 2 lignes de record == `bilan`, courbe complète ; écran titre et collection cohérents avec `Records.lire` (copie isolée de `records.sav`, jamais le vrai fichier).
- **CA-I7 ★** PEA / SCPI / PEP : fiches lisibles, vente différée affichée avec son mois d'exécution et annulable, valeur de la ligne SCPI == `valeur_ligne` ; PEP sans bouton d'achat.
- **CA-I8 ★** Choix du départ : 1984 → Gérard en 01/1984 (fin 12/1993), 1989 → Christine en 01/1989 ; pop-up du bon profil ; « Continuer » reprend sans choix.
- **CA-I9 ★** `tests.ps1 -Recette -Delai 700` vert sur la fusion avec `main` (10a-moteur, puis 10a-contenu quand il est fusionné) ; `test_interface` couvre I5-I10 ; périmètre ⊂ colonne 10b-interface ; `principal.gd` ≤ 650 lignes.

## 6. Ordre et recettes

1. Fusion de 09-I → lancer **10a-moteur**, **10b-ville** et **10b-interface étape 1** en même temps (fichiers disjoints).
2. 10b-ville : recette courte → push → fusion (indépendante).
3. 10a-moteur fusionné → le coordinateur fusionne `main` dans `lot/10b-interface` → étape 2 ; en parallèle, **10a-contenu**.
4. 10b-interface : recette **ciblée** (étapes I11 + CA-I) sur la fusion avec `main` ; fusion après 10a-contenu de préférence (pour capturer le vrai chapitre 1989) ; sinon les captures de 1989 sont refaites à la recette finale.
5. Recette finale du lot 10 et export 0.7 : `lot_10c.md` §6.

## 7. Points d'arrêt et conflits

- dev-interface : un champ du contrat manque ou ne suffit pas (ex. la vitrine sans `courbe`) : compte rendu, pas de calcul dans l'UI.
- dev-ville : `regler_foyer_visuel` impose de toucher `principal.gd` ou un fichier d'interface.
- Conflits avec la suite : `lot_10c.md` (10c-I touche `modale_carte.gd` et « Mon foyer » **après** la fusion de 10b-interface) ; lot 12 (écran de création complet, remplace D6 ; étoiles dans la collection) ; lot 13 (sauvegarde manuelle : menus).
