# Lot 09 : socle des chapitres

> Chef de projet, 2026-11-18. Deuxième lot de l'ordre décidé par le joueur (`decisions_extension_annees.md` §4). Plan d'ensemble : `plan_extension_annees.md` (version du 18/11 après décisions).
> **Aucun changement visible, aucun contenu d'expert.** Le jeu reste 1984-1988 au bit près ; on prépare : données par chapitre de 5 ans, partie qui traverse les chapitres, fin à la dernière année implémentée, décor choisi par la date (tranches de 10 ans), export des sous-dossiers.
> Base : `main` **après la fusion du lot 08b** (09-L, 09-I) ; `main` actuel pour 09-V (fichiers disjoints du 08b).
> État (18/11 soir) : 08b OK (2c84a43) et 09-V OK (a4aef5f), fusions validées ; 09-L lançable depuis `main` après ces deux fusions. `test_reference_1984` (L0) fige donc l'état **après** 08b (titres rééquilibrés).

## 0. En bref

| Branche | Développeur | Quand | Contenu |
|---|---|---|---|
| `lot/09-ville` | dev-ville | **tout de suite** (parallèle au lot 08b) | table des thèmes de décor (`ThemeDecor`), thème « 1980 » = rue actuelle au pixel près, `ville.regler_theme`, option de capture `--theme` |
| `lot/09-logique` | dev-logique | après la fusion de `lot/08b-logique` dans `main` | `data/chapitres/` (index + chapitre « 1984 »), `Donnees` par chapitre, chapitre actif selon la date, fin à la dernière année implémentée, fenêtre de marché lue dans les données, sauvegarde, filtres d'export, salaires 2023-2025 |
| `lot/09-interface` | dev-interface | après la fusion de `lot/09-logique` (et de `lot/09-ville` si elle est prête) dans `main` | `principal.gd` et l'interface passent par `config_chapitre`, `infos_chapitre`, `theme_a` → `regler_theme` ; aucun texte changé |

Worktrees : `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot09-ville`, `lot09-logique`, `lot09-interface`.
```
outils\git\cmd\git.exe -C C:\Users\arthu\Documents\temp\JeuClaude worktree add C:\Users\arthu\Documents\temp\JeuClaude_lots\lot09-ville -b lot/09-ville main
# après fusion de 08b :
outils\git\cmd\git.exe -C C:\Users\arthu\Documents\temp\JeuClaude worktree add C:\Users\arthu\Documents\temp\JeuClaude_lots\lot09-logique -b lot/09-logique main
# après fusion de 09-L (et 09-V) :
outils\git\cmd\git.exe -C C:\Users\arthu\Documents\temp\JeuClaude worktree add C:\Users\arthu\Documents\temp\JeuClaude_lots\lot09-interface -b lot/09-interface main
```
Ce plan est commité sur `main` avant la création des branches. Rappel worktree : `outils/` n'est pas versionné, `trouver_godot.ps1` cherche Godot dans le dépôt principal (vérifié aux lots précédents) ; `user://` est commun : ne jamais écrire `partie_en_cours.sav` ni `records.sav`.

## 1. Décisions du lot

| # | Décision |
|---|---|
| D1 | **Chapitre** = tranche de 5 ans de contenu (`data/chapitres/<id>/`), id = année de début (« 1984 »). Les fichiers d'un chapitre **remplacent** ceux de `data/` du même nom (fichier entier, jamais de fusion profonde). Monde (reste dans `data/`) : `series`, `regles`, `salaires`, `rythme`, `periode_p1`. Chapitre « 1984 » : `chapitre` (ex-`demo`), `banque`, `foyer`, `projets`, `rue`, `krach`, `titres`, `intro`, `temoins`, `evenements_vie`. |
| D2 | **Une partie traverse les chapitres** (décision du joueur : fin à la dernière année implémentée). Le chapitre **actif** est celui qui contient le mois courant ; `config["chapitre"]` = chapitre **de départ** (choix de création, profils). Dans ce lot un seul chapitre existe : la bascule est éprouvée sur un **jeu de données d'essai** (`godot/tests/donnees/`), jamais dans `data/`. Les modules (Foyer, Projets, Quartier, Banquier, Krach, Titres) ne savent **pas encore** reprendre un état à travers une bascule : c'est le lot 10. |
| D3 | **Fin de partie** = min(`config["fin"]`, décembre de `index.json > derniere_annee`) ; `derniere_annee` = fin du dernier chapitre `ouvert` (1988 aujourd'hui). Un chapitre `ouvert: false` n'est jamais joué. La mort du personnage viendra plus tard (lot dédié) : rien dans ce lot. |
| D4 | **Décor par tranches de 10 ans, choisi par la date** : `index.json > themes` = liste `[{"de": "AAAA-MM", "theme": "<id>"}]` ; aujourd'hui une seule ligne `{"de": "1977-01", "theme": "1980"}`. Joueur (D-J3, `decisions_extension_annees.md` §5) : **un décor par tranche de 2 chapitres**, 1984-1993 = un seul décor ; le chapitre 1977-1983 (7 ans, D-J4) garde « 1980 » tant qu'aucun autre thème n'existe. Le lot 10 n'ajoute donc aucun thème. |
| D5 | `premiere_annee` = 1977 dans `index.json` (lu plus tard par l'écran de création). Aucun effet de jeu dans ce lot (le marché P1 commence en 1978). |
| D6 | Fenêtre de marché lue dans le fichier de marché (`Marche.N`, tailles de `hist`, bornes de `m_fin`) : **mêmes valeurs pour P1** (181 / 180 / 179). Prépare la prolongation de P1 jusqu'en 1993 (lot 10). |
| D7 | Sauvegarde : format 3 inchangé, migration douce : `config_depart["chapitre"]` absent = « 1984 » ; chapitre actif recalculé depuis la date à la reprise. |
| D8 | Records : **inchangés** (version 1) dans ce lot. Joueur (D-J1, D-J2) : un seul bilan final, **un titre par chapitre traversé**, records **par chapitre de départ** (record sur la période totale envisagé plus tard) ; tout cela est fait au **lot 10**. Ici, le bilan gagne seulement `chapitre_depart`, `annee_depart`, `annee_fin`, et `Bilan`/`Titres` ne doivent rien supposer d'un chapitre unique de plus que ce qui existe déjà. |
| D12 | Hors lot 09, rappel pour le lot 10 (décisions du joueur, `decisions_extension_annees.md` §5) : un seul profil de départ en 1989 (Christine, docs/39) ; carte de passage de chapitre **version A** (docs/40, sans bilan d'étape) ; mariage selon l'âge et le profil (règle du game designer) ; PEP tranché par le game designer ; mort liée à l'âge avec note sur la transmission (lot dédié) ; dosage de Jean-Mi **inchangé** (Q-R1). Aucun de ces points ne change le contrat du lot 09. |
| D9 | Noms affichés (banquier, journal, titre, accroche) lus dans `infos_chapitre()` ; textes **identiques** à aujourd'hui (même « de 1978 à aujourd'hui », dette T12 laissée au lot 13). |
| D10 | Salaires (décision du joueur, valeurs laissées au chef de projet, docs/34 K2.6) : ligne **2023** `smn 2735, jeune 1480, technicien 2530, cadre 4550, heritier 2400, capital 47000` ; ligne **2025** corrigée `smn 2870, jeune 1610, technicien 2700, cadre 4890, heritier 2600, capital 52000` ; dépenses : ligne `de 2022` = celle de 2010 avec **2 points d'épargne en moins** pour chaque profil (malus d'inflation 2022-2023), ligne `de 2024` = retour aux valeurs de 2010. Certitude C, notée dans `_note`. Sans effet sur 1984-1988 (vérifié par CA-L1). |
| D11 | Alias permanents pour ne casser aucun appelant : `Donnees.charger("demo")` lit `chapitre` ; `Donnees.config_demo(g)` = `config_chapitre("1984", g)`. |

## 2. Fichiers attribués

| Fichier | 09-L (dev-logique) | 09-V (dev-ville) | 09-I (dev-interface) |
|---|---|---|---|
| `godot/data/*.json` (dont `git mv` vers `data/chapitres/1984/`), `godot/data/chapitres/**` | ✔ | | |
| `godot/data/themes/**` (**nouveau**, tables de thèmes) | | ✔ | |
| `godot/scripts/logique/*.gd`, `godot/scripts/partie.gd` | ✔ | | |
| `godot/tests/test_*.gd` logiques, `godot/tests/test_chapitres.gd` (**nouveau**), `godot/tests/test_reference_1984.gd` (**nouveau**), `godot/tests/donnees/**` (**nouveau**, jeu d'essai) | ✔ | | |
| `godot/outils/tests.ps1`, `godot/export_presets.cfg` (filtres seulement), `docs/connaissances/developpeur.md` | ✔ | | |
| `godot/scripts/ville/*.gd` (dont `theme_decor.gd` **nouveau**, `class_name ThemeDecor`), `godot/scripts/pixel/*.gd` (si besoin), `godot/scripts/outils/scenarios/ville.gd`, `godot/outils/capture_ville.ps1`, `godot/tests/test_rue.gd`, `godot/tests/test_pixel.gd` | | ✔ | |
| `godot/scripts/principal.gd`, `godot/scripts/ui/*.gd`, autres familles `godot/scripts/outils/scenarios/*.gd`, `godot/tests/test_interface.*`, `test_partie.*`, `test_ecran.*` | | | ✔ |
| Bases : `docs/connaissances/dev-logique.md` / `dev-ville.md` / `dev-interface.md` | ✔ | ✔ | ✔ (la sienne) |

**Interdits à tous** : `project.godot`, `godot/tests/recette/`, `godot/scripts/juice.gd`, `godot/scripts/ville/sequences.gd` (aucun besoin), les fichiers d'un autre développeur. `.uid` commités avec leur script. 09-L ne touche à aucun fichier de `scripts/ui`, `scripts/ville`, `principal.gd` ; s'il faut une ligne d'interface, il la décrit dans son compte rendu pour 09-I.

## 3. Contrat (figé avant lancement)

### 3.1 Données

```
godot/data/chapitres/index.json
{
  "premiere_annee": 1977,
  "chapitre_defaut": "1984",
  "chapitres": [
    { "id": "1984", "nom": "Les années fric", "debut": "1984-01", "fin": "1988-12", "marche": "P1", "ouvert": true }
  ],
  "themes": [ { "de": "1977-01", "theme": "1980" } ]
}
godot/data/chapitres/1984/chapitre.json   (= demo.json actuel, contenu inchangé + "id": "1984")
godot/data/chapitres/1984/{banque,foyer,projets,rue,krach,titres,intro,temoins,evenements_vie}.json   (git mv, octets inchangés)
godot/data/themes/1980.json               (09-V : table vide documentée)
```
`derniere_annee` est **calculée** (fin du dernier chapitre ouvert), jamais écrite à la main.

### 3.2 `Donnees` (logique)

```
static var racine_chapitres := "res://data/chapitres"   # tests : "res://tests/donnees/chapitres" (le monde reste res://data)
static var chapitre := ""                               # chapitre actif ; "" = index.chapitre_defaut (les tests qui lisent
                                                        # titres, foyer… sans partie lancée continuent de marcher)
static func regler_chapitre(id: String) -> void         # change le chapitre actif (le cache est indexé par chapitre)
static func charger(nom: String) -> Dictionary          # <racine_chapitres>/<chapitre>/<nom>.json, sinon res://data/<nom>.json ; "demo" -> "chapitre"
static func index() -> Dictionary                       # <racine_chapitres>/index.json
static func chapitres(tous := false) -> Array           # [{id, nom, debut, fin, marche, ouvert}], ouverts seulement par défaut
static func chapitre_de(ab: int) -> String              # chapitre ouvert qui contient le mois absolu ab ("" si aucun)
static func premiere_annee() -> int                     # 1977
static func derniere_annee() -> int                     # 1988 aujourd'hui
static func theme_a(ab: int) -> String                  # "1980" pour toute date aujourd'hui
static func config_chapitre(id: String, graine := -1) -> Dictionary   # = config_demo actuelle + "chapitre": id ; fin bornée par derniere_annee
static func config_demo(graine := -1) -> Dictionary     # alias de config_chapitre("1984", graine)
static func infos_chapitre(id := "") -> Dictionary      # chapitre.json du chapitre id (défaut : actif) : banquier, journal, titre, moments, vitesse_depart…
```

### 3.3 `EtatPartie` / `Partie`

- `config["chapitre"]` (défaut `index.chapitre_defaut`) ; `e.chapitre` (String) = chapitre actif, recalculé à chaque entrée de mois : s'il change, `Donnees.regler_chapitre` puis signal **`Partie.chapitre_change(ancien: String, nouveau: String)`** (nouveau signal, jamais émis avec les données réelles de ce lot ; l'interface pourra s'y brancher au lot 10).
- `Bilan.calculer` : + `chapitre_depart`, `annee_depart`, `annee_fin`.
- Aucune autre signature changée. `Partie.etat`, signaux existants, `contenu_modale()` : identiques.

### 3.4 Ville (dev-ville)

```
class_name ThemeDecor            # scripts/ville/theme_decor.gd
static func table(id: String) -> Dictionary     # data/themes/<id>.json ; id inconnu ou fichier absent : {} (= rue actuelle), avertissement
ville.regler_theme(id: String) -> void          # applicable au démarrage ET en cours de partie ; sans effet si id == theme actuel
ville.theme_actuel() -> String                  # "1980" par défaut
```
Règles de docs/36 §9 : ancres inchangées (`FENETRE_BANQUIER`, `PORTE_BANQUE`, `HORLOGE`, `ECRAN`, `NEON`, `ROTATIVE`, `FENETRE_SYLVIE`, `PORTE`), palette : ajouts en fin seulement (aucun dans ce lot). Format de table : docs/36 §10.6 (clés lues dans ce lot : aucune obligatoire ; le thème « 1980 » est la table vide).

### 3.5 Interface (09-I, appels ajoutés)

- `principal._config()` : `Donnees.config_chapitre(Donnees.index()["chapitre_defaut"], graine)` (même résultat que `config_demo`).
- `demo = Donnees.infos_chapitre()` à la place de `Donnees.charger("demo")` (`principal.gd`, `modale_intro.gd`).
- Au démarrage, à la reprise et à chaque `mois_passe` : `if ville.has_method("regler_theme"): ville.regler_theme(Donnees.theme_a(Partie.etat.ab_courant()))`.
- `Partie.chapitre_change` : connecté à une fonction vide documentée (place de la future transition de chapitre, lot 10).

## 4. Tâches

### 4.1 09-L (dev-logique)

- **L0 (1er commit, avant toute migration) : `test_reference_1984.gd`.** Sur l'état de `main` (après 08b), joue et **fige dans le test** : intégrale graine 7 ; passif ; actif ; tout-Peugeot ; les 9 `PROFILS_TITRES` ; 20 parties de P-REF (graines 1-20) ; cartes, projets, rue allumés quand le test d'origine les allume. Pour chacune : patrimoine final (au centime), frais, impôts, interruptions, titre, rang, nombre d'entrées d'historique et **empreinte** (md5) de la suite des textes d'historique. Le test doit passer sur ce commit.
- **L1** Arborescence du §3.1 par `git mv` (historique gardé), `index.json`, `chapitre.json`.
- **L2** `Donnees` du §3.2 (cache indexé par chapitre, `racine_chapitres`, alias D11) ; `push_error` seulement si le fichier manque **à la fois** dans le chapitre et dans le monde.
- **L3** `EtatPartie` / `Partie` / `Bilan` du §3.3 ; fin bornée (D3).
- **L4** `Marche` : taille de fenêtre lue dans `periode_*.json` (champ `fin` ou nombre de mois ; défaut 15 ans si absent), `hist` et `m_fin` dimensionnés en conséquence ; `HISTORIQUE_MAX` inchangé (600) mais nommé dans le compte rendu comme limite pour le lot 10.
- **L5** Sauvegarde (D7) : relecture d'une **copie** de la sauvegarde du joueur (0.6.x, si elle existe) et de 3 sauvegardes écrites par `main` (06/1986, 10/1987, 06/1988), jusqu'à la fin : mêmes chiffres que `main`.
- **L6** Filtres d'export (**piège H18**) : dans les **deux** préréglages, `include_filter="data/*.json, data/chapitres/*.json, data/chapitres/*/*.json, data/themes/*.json, data/pixel/*/*.txt"`. Rien d'autre dans `export_presets.cfg` (version inchangée).
- **L7** Salaires et dépenses (D10).
- **L8** `test_chapitres.gd` : résolution chapitre → monde ; alias `demo` ; cache par chapitre (deux chapitres d'essai, même nom de fichier, contenus différents) ; `chapitres()`, `chapitre_de` aux bornes (1983-12, 1984-01, 1988-12, 1989-01) ; `derniere_annee` (1988 ; puis 1993 avec le jeu d'essai où un 2e chapitre est `ouvert`, et 1988 s'il est fermé) ; `theme_a` ; `config_chapitre("1984", g)` égal en profondeur à l'ancienne `config_demo(g)` (copie figée dans le test) ; **bascule** : avec le jeu d'essai (chapitres « 1984 » et « 1989 » minimalistes, `racine_chapitres` = `res://tests/donnees/chapitres`), une partie sans cartes ni projets ni rue démarrée en 1988-07 et bornée à 1989-06 passe en « 1989 » en janvier 1989, émet `chapitre_change` une fois, lit le fichier du nouveau chapitre ; filtre d'export : les deux `include_filter` contiennent `data/chapitres/*/*.json` ; **mesure** (non bloquante) `MESURE debut_libre` : partie démarrée en 1986-01 avec cartes, projets, rue allumés → va-t-elle au bout sans erreur ? ce qui est sauté (créneaux, projets, naissance) ; sert à dimensionner la saisie d'une année (lot 13).
- **L9** `test_titres_mesures`, `test_rue_mesures` (lot 08b) et tous les tests existants : verts sans changer une seule valeur attendue.

### 4.2 09-V (dev-ville)

- **V1** `ThemeDecor` (§3.4) et `data/themes/1980.json` (table vide + `_note` qui renvoie à docs/36 §10.6).
- **V2** `ville.regler_theme(id)` / `theme_actuel()` : reconstruit le décor statique seulement si le thème change ; jamais pendant une séquence animée (sinon différé à sa fin) ; aucun nœud fuité (compte de nœuds avant / après 2 bascules aller-retour identique).
- **V3** Thème d'essai dans les tests seulement (table fabriquée dans `test_rue`, ex. enseigne de la boulangerie changée) : prouve que le mécanisme change des pixels **hors ancres** et laisse les ancres identiques.
- **V4** Option de capture `--theme=<id>` dans `scenarios/ville.gd` et `-Theme` dans `capture_ville.ps1`.
- **V5** `test_rue` : lignes `RUE theme=1980 identique_main=oui couleurs_hors_palette=0 ancres_identiques=oui` et `RUE theme=essai pixels_changes=<n> ancres_identiques=oui noeuds_fuites=0`.

### 4.3 09-I (dev-interface)

- **I1** Appels du §3.5 ; plus aucun `Donnees.charger("demo")` dans `scripts/ui` ni `principal.gd`.
- **I2** Scénarios de capture de sa famille : inchangés sauf passage par `config_chapitre` si besoin.
- **I3** Inventaire (compte rendu seulement, aucun changement) des textes d'interface encore liés à 1984-1988 en dur (H17 du plan) : fichier, ligne, texte ; il servira au lot 10.

## 5. Critères d'acceptation

### 09-L
- **CA-L1 ★ Non-régression au bit près** : `test_reference_1984` vert sur le dernier commit, **sans modification de ses valeurs depuis L0** (`git diff <L0>..HEAD -- godot/tests/test_reference_1984.gd` vide : le test appelle `config_demo`, qui reste un alias).
- **CA-L2 ★** Tous les tests existants verts sans changer une valeur attendue ; total ≥ total de `main` + nouvelles vérifications ; 0 erreur de script ; aucune ligne `Données introuvables`.
- **CA-L3 ★** `git mv` : `git log --follow` de `godot/data/chapitres/1984/banque.json` remonte à l'ancien `godot/data/banque.json` ; les 9 fichiers déplacés ont le **même hachage** qu'avant (`git hash-object`), `chapitre.json` = `demo.json` + la clé `id`.
- **CA-L4 ★** `test_chapitres` vert : tous les cas du §4.1 L8 (bascule comprise) ; la ligne `MESURE debut_libre` est imprimée.
- **CA-L5 ★ Export** : les deux `include_filter` du §4.1 L6 ; un `--export-pack` Windows dans le dossier temporaire du testeur, lancé par `--main-pack <pck> --etape=titre` puis `--etape=jouer`, ne journalise ni `Données introuvables` ni `JSON invalide`, et la partie démarre en janvier 1984 avec Gérard et M. Lefranc.
- **CA-L6 ★ Sauvegarde** : L5 rejoué par le testeur sur ses propres copies (jamais le fichier du joueur) ; une sauvegarde écrite par la branche se relit sur la branche avec `chapitre` « 1984 ».
- **CA-L7 ★** Salaires : lignes 2023 et 2025 et dépenses 2022/2024 conformes à D10 ; `valeur_table("technicien", 2023)` = 2530 ; épargne technicien 2022 = 16 %, 2024 = 18 %.
- **CA-L8 ★ Périmètre** : `git diff main...lot/09-logique --stat` ⊂ colonne 09-L.

### 09-V
- **CA-V1 ★** Thème « 1980 » identique **au pixel** à `main` : image du `SubViewport` de la rue à N ≥ 2 (1920 × 1080), jour et nuit, hachage égal avec et sans `regler_theme("1980")`.
- **CA-V2 ★** Thème d'essai : pixels changés > 0 hors ancres, ancres identiques, 0 nœud fuité après 2 allers-retours, aucune erreur.
- **CA-V3 ★** `capture_ville.ps1 -Theme 1980` produit la même image que sans l'option (étape `rue` PC 1920 × 1080 et téléphone 1440 × 648).
- **CA-V4 ★** `test_rue` et `test_pixel` verts ; périmètre ⊂ colonne 09-V.

### 09-I (recette = fusion complète des trois)
- **CA-I1 ★** Plus aucun `Donnees.charger("demo")` dans `scripts/ui` ni `principal.gd` (recherche ; les scénarios d'un autre propriétaire et les tests de non-régression sont exclus nommément de la recherche).
- **CA-I2 ★** Captures ciblées identiques à `main` (relues côte à côte) : `titre`, intro (pop-up de début), `jouer`, `krach`, `fin` ; PC 1920 × 1080 et téléphone 1440 × 648.
- **CA-I3 ★** `regler_theme` appelé au démarrage et à la reprise (ligne de journal en capture `THEME 1980`), jamais d'erreur si la ville ne l'a pas (`has_method`).
- **CA-I4 ★** `tests.ps1 -Recette -Delai 700` vert sur la fusion ; `test_interface`, `test_partie`, `test_ecran` verts ; périmètre ⊂ colonne 09-I.

## 6. Ordre, recettes, fusions

1. **09-V** (tout de suite) → recette courte → push → fusion dans `main` (peut se faire avant ou après 08b).
2. **08b** → fusion → **09-L** (branche créée depuis `main`) → recette (tests + CA-L*, pas de captures sauf CA-L5) → push → fusion.
3. **09-I** depuis `main` (contient 08b, 09-L et, si prête, 09-V) → recette = fusion complète (CA-I*) → push → fusion → tests relancés sur `main`.
4. Pas d'export à la fin du lot (rien de visible) ; le prochain export (0.7) part avec le lot 10. Exception : si le joueur veut le rééquilibrage tout de suite, export 0.6.3 après 09-I (série de captures complète, règle du 17/11).

## 7. Points d'arrêt

- dev-logique : une valeur de `test_reference_1984` bouge et la cause n'est pas une erreur de migration (ex. ordre de chargement, flottant) ; la taille de fenêtre de `Marche` ne peut pas être lue sans changer un tirage aléatoire ; un fichier qu'on croyait « monde » contient du contenu daté 1984-1988 (le signaler, le déplacer dans le chapitre).
- dev-ville : `regler_theme` en cours de partie impose de toucher `sequences.gd` ou `juice.gd`.
- dev-interface : une ligne d'interface dépend d'une donnée absente de `infos_chapitre()`.

## 8. Comptes rendus attendus

Fichiers modifiés (comparés au §2) ; écarts au contrat (aucun attendu) ; lignes `MESURE debut_libre`, `RUE theme=…`, `THEME …` ; durée des tests avant / après ; non vérifié ; base à jour. 09-L : liste des contenus encore datés trouvés dans le code (H6, H9, H10, H17 du plan) pour le lot 10.
