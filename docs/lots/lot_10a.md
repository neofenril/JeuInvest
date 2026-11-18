# Lot 10a : chapitre 1989-1993, logique (moteur puis contenu)

> Chef de projet, 2026-11-18. Premier sous-lot de la **0.7 « dix ans »** (`feuille_de_route_v3.md`). Interface et ville : `lot_10b.md` ; pilote carrière : `lot_10c.md`.
> Contenus (ordre de priorité en cas de contradiction) : `decisions_extension_annees.md` > **docs/47** (game designer, prime sur docs/39) > **docs/46** (banquier, prime sur docs/38) > docs/39, docs/38, docs/37 (boursier), docs/41 (SCPI), docs/40 (UX : définitions des records §3.1). Arbitrages du chef de projet : §1.
> Base : `main` après la fusion de `lot/09-interface` (lot 09 complet). **Ne pas lancer avant cette fusion.**

## 0. En bref

| Branche | Qui | Quand | Durée |
|---|---|---|---|
| `lot/10a-moteur` | dev-logique | dès la fusion de 09-I | ≈ 11 j |
| `lot/10a-contenu` | dev-logique | après la fusion de 10a-moteur | ≈ 7 j |

- **10a-moteur** : catalogue des produits du monde (migration de 1984-1988 **au bit près**), P1 prolongé à 12/1993, bascule de chapitre dans chaque module, vitrine générique, un titre par chapitre, records v2 (double record), types **PEA** et **SCPI**, produits « message » (PEP), liste d'effets de salaire, mariage selon l'âge, `foyer_visuel()`, fin de partie à la dernière année implémentée. Aucun contenu 1989 réel : il est éprouvé sur un **jeu d'essai minimal**.
- **10a-contenu** : `data/chapitres/1989/` (Christine, continuité de Gérard, catalogue, cartes, projets, Jean-Mi saison 2, vitrine du Golfe, kiosque, rue, titres), chapitre 1989 **ouvert** (dernière année = 1993), calibrage.
- `test_reference_1984` **ne change pas** (aucune valeur, aucun appel) dans les deux branches.

Worktrees : `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot10a-moteur`, puis `lot10a-contenu`.
```
outils\git\cmd\git.exe -C C:\Users\arthu\Documents\temp\JeuClaude worktree add C:\Users\arthu\Documents\temp\JeuClaude_lots\lot10a-moteur -b lot/10a-moteur main
# après fusion de 10a-moteur :
outils\git\cmd\git.exe -C C:\Users\arthu\Documents\temp\JeuClaude worktree add C:\Users\arthu\Documents\temp\JeuClaude_lots\lot10a-contenu -b lot/10a-contenu main
```

## 1. Arbitrages du chef de projet (divergences entre experts)

| # | Sujet | Divergence | Décision | Bloque le dev ? |
|---|---|---|---|---|
| A1 | **Vitrine du Golfe** | docs/37 §7.1 : événement à pause en 08/1990, « un an après » 08/1991 ; docs/47 §1 : étape 1 sans pause en 08/1990, **modale en 09/1990**, « un an après » **09/1991** | **docs/47** (le boursier admet lui-même 2 étapes mensuelles en §7.2 ; le choix en 09/1990 se fait au creux réel A ; aucune donnée journalière inventée). Fenêtre de vente des titres : `["1990-09", "1991-03"]`. Textes **calculés** sur la série | non |
| A2 | Fins de mois **08/1990 (1 640, C)** et **09/1991 (1 830, C)** | à valider par le boursier | valeurs de docs/37 §3 utilisées telles quelles ; textes calculés, donc un changement ultérieur = **une ligne de données** + relance de `test_chapitre_1989` | **non** : à confirmer **avant l'export 0.7** (sinon gardées en C) |
| A3 | Fenêtre de présentation de la **SCPI** en 1989-1993 | docs/46 : départ 1989 M16-M20 (04-08/1990) ; docs/47 : continuation 02-04/1990, départ 1989 « après les actions, au plus tard 05/1990 » | continuation **02/1990, limite 04/1990** ; départ 1989 **04/1990, limite 05/1990** ; toujours avant la vitrine (08/1990) et avant l'achat de Jean-Mi (10/1990) | non |
| A4 | Valeurs de la **SCPI** (part 1 000 F, frais 10 %, loyers 6,5 / 6,3 / 5,8 %, revente 900 / 820 / 780 F, délai de vente 3 mois) | C, à valider par le banquier (docs/46 §7, docs/47 §9) | utilisées telles quelles, toutes en données (`produits.json`, aucun nombre dans le code) | **non** : confirmation **avant l'export 0.7** ; changement = données + recalcul de J2 |
| A5 | Mécanique SCPI : vente **différée de 3 mois**, annulable, **exclue de la vente automatique** des projets, non recopiée chez Tata / Tonton | demandée au chef de projet (docs/47 §9) | **acceptée** (c'est la leçon de liquidité) | — |
| A6 | **SCPI en 1984-1988** | possible dès 01/1984 (docs/46, fenêtre 01/1986-09/1987) | **pas dans ce lot** : lot 11, avec le re-gel conscient de `test_reference_1984` (`feuille_de_route_v3.md` §4) | — |
| A7 | **Jumeaux 1/6** | décision du joueur, globale | paramètre **par chapitre** : 1/6 dans 1989-1993 dès ce lot ; 1984-1988 garde 1/4 jusqu'au re-gel du lot 11 (sinon `test_reference_1984` bouge) | — |
| A8 | **PEP** | docs/46 : message + fiche « En savoir plus » ; docs/47 : simple message | **message + « En savoir plus »** (texte long de la notification, mécanisme existant `long`/`texte_long`) ; aucune fiche jouable | — |
| A9 | Privatisations | retirées (docs/46 §1, docs/47 §5) | **BNP** = action ordinaire disponible dès **10/1993**, sans dividende dans la fenêtre, notification « Nouvelle action au catalogue : BNP. » ; Saint-Gobain 1986 inchangé | — |
| A10 | Jean-Mi saison 2 | docs/39 (studio à crédit) contre docs/47 (SCPI comptant) | **docs/47** : SCPI comptant, J1 supprimée au chapitre 2, **J2** (derrière Tata d'au moins 10 % en 12/1993, toute graine) ; réglage = part de l'épargne versée, jamais les chiffres du produit | — |
| A11 | Tickets « Le Trèfle » (prix, date, retour 65 %) | à valider par le banquier | **hors lot 10** (lot 13) | — |

## 2. Fichiers attribués (dev-logique, les deux branches)

| Fichier | 10a-moteur | 10a-contenu |
|---|---|---|
| `godot/data/produits.json` (**nouveau**, catalogue du monde) | crée (produits de 1984-1988 + PEA, SCPI, PEP, SICAV monétaire, BNP) | complète (textes, paramètres 1989-1993) |
| `godot/data/periode_p1.json` | fin 1993, ancrages 1989-1993 (docs/37 §3), actions 1993, BNP | — |
| `godot/data/regles.json`, `series.json`, `salaires.json`, `rythme.json` | si besoin (fiscalité datée docs/38 §3.7 : CSG 1991, plus-values) | — |
| `godot/data/chapitres/index.json` | schéma (chapitre 1989 **fermé**) | ouvre 1989 |
| `godot/data/chapitres/1984/*.json` | **migration seulement** (les produits passent au catalogue ; présentations par id de produit ; octets de contenu équivalents) | — |
| `godot/data/chapitres/1989/*.json` (**nouveau**) | — | crée |
| `godot/scripts/logique/*.gd`, `godot/scripts/partie.gd` | ✔ | corrections seulement |
| `godot/tests/test_*.gd` logiques, `godot/tests/test_catalogue.gd`, `test_bascule.gd` (**nouveaux**), `godot/tests/test_chapitre_1989.gd` (**nouveau**, 10a-contenu), `godot/tests/donnees/**` | ✔ | ✔ |
| `godot/tests/test_reference_1984.gd` | **interdit** | **interdit** |
| `godot/outils/tests.ps1` | si besoin (option `-Chapitre`) | — |
| `docs/connaissances/dev-logique.md`, `developpeur.md` | ✔ | ✔ |

**Interdits** : `scripts/ui/`, `scripts/ville/`, `scripts/pixel/`, `principal.gd`, `project.godot`, `export_presets.cfg` (version au lot 10c), `data/themes/`, `tests/recette/`, `test_interface`, `test_partie`, `test_ecran`, `test_rue`, `test_pixel`, scénarios de capture. Si l'interface doit changer pour que les tests restent verts : point d'arrêt (ne jamais casser l'écran : nouveaux champs **ajoutés**, jamais renommés).

## 3. Ce que 10a-moteur fige pour le catalogue déplaçable (C1 à C9 de `feuille_de_route_v3.md` §5)

| # | Décision figée |
|---|---|
| C1 | `data/produits.json` : `{ "<id>": { type, nom, famille, naissance: "AAAA-MM", fin?: "AAAA-MM", notes {rendement, risque, dispo, fisc}, mots, indice, fiche (texte générique ≤ 60 mots à variables), parametres (datés : PEL, AV, SCPI, PEA…), offre? {debut, fin, prix}, mode_defaut: "jouable" | "message" | "silhouette", certitude } }`. Les `produits` et `parametres` de `banque.json` 1984 y passent **à l'identique**. |
| C2 | Identité = **id de produit** partout : état de la banque (`produits_vus`), sauvegarde, historique (`produit`), `StrategieTest` (`ouvrir: ["livret", "av", …]`), tests. Table `D01…D08 → id` gardée **seulement** pour migrer les sauvegardes (format 3, migration douce) et pour les tests existants. |
| C3 | Présentations du chapitre : `banque.json > presentations: [{ produit, mode?, quand: mois relatif au **début du chapitre** (0 = janvier de la 1re année), echeance, apres?: id, texte?, compare?, risque? }]` ; pour 1984 : **mêmes nombres** qu'aujourd'hui. Un départ en cours de chapitre (lot 12) décale au début de la partie (`max(quand, mois de départ)`). |
| C4 | **R-UNE-FOIS** (docs/46 §2.1) : un produit dans `produits_vus` n'est jamais représenté ; **R-RATTRAPAGE** : produit de base (rangs 1-8 de docs/46 §2.3) né avant le début du chapitre, non vu et non déclaré par le chapitre → présenté du mois 1 au mois 24, dans l'ordre pédagogique global, au plus un tous les 2 mois, dans le budget de cadence. |
| C5 | Restent au chapitre : accueil, messages datés, héritage (Odette / Raymond), versements, `frais_pedagogie`, `ordre_carnet` (devient l'ordre d'affichage ; un produit vu absent de la liste se range à la fin). |
| C6 | Offres publiques : `offre` dans le catalogue (Saint-Gobain 1986) ; aucune en 1989-1993. |
| C7 | `chapitre.json > version_contenu` (1 pour 1984 et 1989), écrit dans la sauvegarde et les records. |
| C8 | `test_catalogue` : id uniques ; chaque présentation de chaque chapitre a `quand` ≥ naissance (en mois absolus) ; type connu du moteur ; un produit au plus une fois par chapitre ; tout produit du `ordre_carnet` existe. |
| C9 | `test_reference_1984` vert sans modification (CA-M1). |

## 4. Contrat logique → interface et ville (figé ; `lot_10b.md` et `lot_10c.md` s'y appuient)

Règle : **ajouts seulement** ; aucun champ existant renommé ni retiré.

```
# Donnees
static func config_chapitre(id: String, graine := -1, fin := "") -> Dictionary
    # fin "" = décembre de derniere_annee() (partie qui traverse les chapitres) ; sinon borne explicite
static func config_demo(graine := -1) -> Dictionary    # = config_chapitre("1984", graine, "1988-12") : figé pour les tests et captures
static func produit(id: String) -> Dictionary          # entrée du catalogue
# EtatPartie (lecture)
e.chapitre, e.chapitre_depart                           # String
func chapitres_traverses() -> Array                     # ["1984", "1989"]
func foyer_visuel() -> Dictionary                       # {"joueur": {"prenom","sexe":"h"|"f","age"}, "proche": {"prenom","sexe","lien":"conjoint"|"ami"} | {},
                                                        #  "enfants": [{"prenom","age"}], "marie": bool}
func ventes_differees() -> Array                        # [{"produit","parts","m_ordre","m_execution","estime"}]
func enveloppe(id_ligne: String) -> String              # "" | "pea"
# Partie (actions)
func ouvrir_pea() -> bool
func acheter(...) / vendre(...)                         # inchangés ; + paramètre facultatif enveloppe := "" en dernier
func vendre_scpi(parts: int) -> bool                    # crée une vente différée (délai produits.json > scpi.parametres.delai_vente_mois)
func annuler_vente_differee(index: int) -> bool
signal chapitre_change(ancien: String, nouveau: String) # existe (lot 09) ; émis au 1er mois du nouveau chapitre, AVANT la modale de passage
# Modales (contenu_modale()["kind"])
"passage"   : {annee, chapitre, nom_chapitre, patrimoine, ecart_tata_pct, rang, texte_attente, fin_partie: "AAAA-MM", choix: [{"id":"continuer"}]}
              # carte de passage version A (docs/40 §1.2.3) ; resoudre_modale("continuer")
"marche" (vitrine) : champs du krach de 1987 conservés ; pour une vitrine en étapes : "courbe": [{"mois","valeur"}], "mention": String, sans "jours"
"gazette" (un an après) : inchangé (3 barres), textes du chapitre
# Notifications : n["produit"] (présentation, message), n["long"] / n["texte_long"] (PEP « En savoir plus »), n["vitrine_etape"] = 1 (étape sans pause)
# Bilan.calculer
bilan["titre"]   : inchangé (titre du dernier chapitre traversé)
bilan["titres"]  : [{"chapitre","id","nom","pourquoi","ordre"}]  # un par chapitre traversé entièrement
bilan["record_chapitre"], bilan["record_partie"] : {"ecart_pct","rang","annee_fin"} ; bilan["hors_record"] : bool
bilan["chapitre_depart"], ["annee_depart"], ["annee_fin"] : (lot 09)
# Records v2 (records.sav, version 2 ; v1 migré : son record devient record_chapitre de « 1984 », sa collection celle de « 1984 »)
static func lire(chemin := CHEMIN) -> Dictionary
    # {"chapitres": {"1984": {"record_chapitre": {...}|{}, "records_partie": {"1993": {...}}, "collection": {id: {nombre, premiere}}}}}
static func enregistrer(bilan, id_partie, chemin := CHEMIN, date := "") -> Dictionary
    # + "nouveau_chapitre", "nouveau_partie", "nouveaux_titres": [...]
```

Définitions (docs/40 §3.1, docs/39 §11.2) : **record de chapitre** = écart face à Tata Livret à la fin des 5 ans du chapitre de départ (= record actuel) ; **record de partie** = écart à la fin de la partie, rangé par chapitre de départ **et** année de fin ; titres par chapitre comptés dans la collection de **ce** chapitre.

## 5. Tâches

### 5.1 10a-moteur

- **M0 (1er commit)** : `test_bascule.gd` minimal sur le jeu d'essai, et vérification que `test_reference_1984` passe (aucune modification).
- **M1 Catalogue** (§3, C1-C9) ; migration de `chapitres/1984/banque.json` ; `Banquier` lit le catalogue ; `StrategieTest` passe aux id de produit (la table D0x reste pour les sauvegardes).
- **M2 Marché** : P1 jusqu'en 12/1993 (`fin` dans `periode_p1.json`, ancrages de docs/37 §3, actions 1993 de docs/37 §5, BNP dès 10/1993 avec `divNul` implicite, `moisCrise` 1990-08, 1990-09, 1992-09, 1989-10). **Les cours jusqu'en 12/1988 ne bougent pas** (CA-M2) ; ceux de 1989-1992 peuvent changer (nouveaux ancrages), c'est voulu.
- **M3 Bascule de chapitre** : chaque module garde son état à travers `chapitre_change` : Foyer (créneaux du nouveau chapitre, humeur continue, `salaires` en liste), Projets (ids préfixés par chapitre, un projet en cours au 31/12 se termine selon ses règles), Quartier (rival qui continue : Jean-Mi garde dette et historique), Banquier (§3), Krach → **vitrine générique** (`vitrine.json` du chapitre ; `krach.json` de 1984 lu comme vitrine sans changement de résultat), Cadence (budgets du chapitre), Titres (un titre par chapitre, calculé au 31/12 de la dernière année du chapitre sur ses propres mois, paramètres du chapitre).
- **M4 Records v2** (§4), migration v1, jamais d'écriture du vrai fichier en test.
- **M5 Types** : **PEA** (enveloppe : actions et SICAV actions éligibles, plafond 600 000 F, versements en numéraire, retrait avant 5 ans = clôture et impôt du compte-titres, après 5 ans exonéré hors prélèvements, règles datées dans `regles.json`) ; **SCPI** (A4, A5 : part, frais d'entrée, valeur de revente datée affichée comme valeur de ligne, loyers trimestriels au compte courant imposés au taux de la convention du jeu, vente différée, exclusion de la vente automatique, pas de R-MIROIR) ; **mode « message »** (PEP : notification sans pause avec `long`/`texte_long`).
- **M6 Vie** : liste d'effets de salaire (`des`, `des_rel`, `jusqua`, migration de l'ancien champ unique : le CNAM de 1984 donne le même résultat) ; mariage par âge et situation (table docs/47 §4.1, fenêtre M9-M42, tirage sur un flux propre à graine décalée : aucun tirage existant ne bouge) ; jumeaux par chapitre (A7) ; `foyer_visuel()`.
- **M7 Fin et sauvegarde** : `config_chapitre` (fin par défaut = dernière année) et `config_demo` figé (§4) ; `hist` et courbes dimensionnés sur la partie (≥ 120 mois) ; `HISTORIQUE_MAX` relevé (≥ 1 200, mesuré) ; sauvegarde : `version_contenu`, `produits_vus`, ventes différées, records ; migration des sauvegardes 0.6.x.
- **M8 Jeu d'essai** : `tests/donnees/chapitres/` réduit au **minimum** (fichiers qui diffèrent seulement ; le reste retombe sur le monde) : résorbe M2 de la recette 09-L.

### 5.2 10a-contenu

- **N1** `data/chapitres/1989/` : `chapitre.json` (accueil, carte de passage : textes docs/40 §1.2.3, `version_contenu` 1), `profils.json` (**Christine** seule, docs/39 §3 ; Gérard continue), `banque.json` (présentations de docs/46 §1.2 et A3, messages datés, PEP, oncle Raymond docs/38 §7.1, rattrapage), `foyer.json` (cartes de docs/39 §4 avec le calendrier de docs/47 §7 ; créneaux S2 et S5 **réservés** au pilote 10c : ils portent aujourd'hui C03 et la formation de docs/39, 10c les remplace), `projets.json` (docs/39 §7), `rue.json` et `temoins.json` (Jean-Mi saison 2, docs/47 §2 ; dosage 8 passages, 5 ★), `vitrine.json` (A1), `titres.json` (docs/39 §13, `fenetre_vente_krach` de A1, `produits_surs` ["livret", "pel"]), `intro.json` (pop-up de Christine), kiosque (docs/37 §8 sans privatisation), `evenements_vie.json` si besoin (prénoms, jumeaux 1/6).
- **N2** Continuité de Gérard (docs/39 §2 révisé par docs/47) : rappels de 1984-1988 en gabarits conditionnels, promotion CNAM (si C07, fenêtre 01-10/1990), mariage 70 %.
- **N3** `index.json` : 1989 `ouvert: true` → `derniere_annee()` = 1993.
- **N4** `test_chapitre_1989.gd` : données (dates dans la tranche, catalogue), calibrage, mesures (§6).

## 6. Critères d'acceptation

### 10a-moteur
- **CA-M1 ★ Non-régression** : `test_reference_1984` vert, `git diff main...HEAD -- godot/tests/test_reference_1984.gd` vide ; tous les tests existants verts sans changer une valeur attendue (sauf les `D0x` remplacés par des id de produit dans les tests logiques, chaque remplacement listé).
- **CA-M2 ★ Marché** : pour l'indice et chaque titre, cours mensuels de 1978-01 à 1988-12 **identiques au bit près** à `main` (comparaison imprimée `MARCHE identiques=1 per 132 mois`) ; 1989-1993 : fins d'année = `series.json` (A) ; les valeurs du tableau de docs/37 §3 sont des ancrages atteints.
- **CA-M3 ★ Catalogue** : `test_catalogue` vert (C8) ; le catalogue 1984 reproduit exactement les fiches actuelles (texte, notes, paramètres : comparaison champ à champ avec l'ancien `banque.json`) ; un produit présenté une fois n'est jamais représenté ; rattrapage vérifié sur le jeu d'essai (produit non déclaré → présenté entre le mois 1 et 24, un au plus tous les 2 mois).
- **CA-M4 ★ Bascule** (jeu d'essai) : partie 1984-01 → 1989-12 sans erreur ; `chapitre_change` émis une fois, avant la modale `passage` ; humeur, projets, Jean-Mi, banque, effets de salaire conservés ; un titre par chapitre ; `bilan["titre"]` = titre du dernier chapitre.
- **CA-M5 ★ Records v2** : migration d'une copie de `records.sav` v1 (record et collection conservés, rangés sous « 1984 ») ; double record (chapitre / partie) ; idempotence ; fichiers tronqués ou illisibles = vides ; vrai fichier jamais écrit.
- **CA-M6 ★ PEA / SCPI / message** : PEA (plafond, éligibilité, clôture avant 5 ans, exonération après 5 ans) ; SCPI (prix, frais, revente datée, loyers trimestriels, vente exécutée exactement 3 mois plus tard au prix du mois d'exécution, annulation, jamais utilisée par la vente automatique, absente chez Tata et Tonton) ; PEP : notification avec texte long, aucune fiche.
- **CA-M7 ★ Vie** : CNAM de 1984 = même salaire qu'avant ; deux effets de salaire cumulés ; `jusqua` rend le salaire exact ; mariage : fréquence mesurée sur 400 graines dans ±5 points des probabilités de docs/47 §4.1 pour chaque tranche ; jumeaux 1989 = 1/6 ± 3 points sur 600 naissances ancrées.
- **CA-M8 ★ Sauvegarde** : sauvegardes 0.6.x (copies) et `main` relues jusqu'à la fin avec les chiffres de `main` ; sauvegarde écrite en 1990 (jeu d'essai) relue : chapitre, produits vus, ventes différées, records.
- **CA-M9 ★ Tests** : `tests.ps1 -Recette -Delai 700` vert, ≥ 1 501 + nouvelles, 0 erreur de script ; durée annoncée ; périmètre ⊂ §2.

### 10a-contenu
- **CA-N1 ★ Données** : `test_catalogue` vert avec 1989 ; toute date de 1989-1993 dans la tranche ; PEA jamais avant 07/1992, PEP jamais avant 01/1990 ; aucun mot interdit ni privatisation (recherche de « Balladur », « privatis », « studio ») ; textes ≤ 30 mots (passages ≤ 15).
- **CA-N2 ★ Parties** : 1984 → 1993 (Gérard) et 1989 → 1993 (Christine) vont au bout sur 200 graines P-REF chacune, 0 faillite passive.
- **CA-N3 ★ Calendrier** : interruptions avec pause de 1989-1993 entre 24 et 26 (docs/47 §7) en moyenne pour Gérard et pour Christine ; R-CADENCE tenue (jamais deux le même mois ni deux mois de suite).
- **CA-N4 ★ Calibrage** : P1 la plus chère réalisée à la date sur ≥ 80 % des graines (« tout au Livret A, choix b »), P2 du milieu sur ≥ 60 % ; titres 1989-1993 sur P-REF : chaque titre ≥ 3 %, aucun > 25 % ; rue (`test_rue_mesures` sur 1989-1993) : 5 / 5 ★ de Jean-Mi livrées, bornes de docs/27 ; **J2** : Jean-Mi derrière Tata d'au moins 10 % en 12/1993 sur toutes les graines et les deux départs.
- **CA-N5 ★ Vitrine** : étape 1 (08/1990) = notification sans pause avec le bandeau calculé ; étape 2 (09/1990) = modale avec 3 points de fin de mois, la mention fixe, ordres au cours de fin septembre ; « un an après » en 09/1991 : texte du bon cas selon la série (`rebond`, `ecart` imprimés).
- **CA-N6 (mesure)** : durée estimée d'une partie 1984 → 1993 (nombre d'interruptions et de notifications), imprimée.
- **CA-N7 ★** `tests.ps1 -Recette` vert ; `test_reference_1984` inchangé et vert ; périmètre ⊂ §2.

## 7. Points d'arrêt

- Un cours de 1978-1988 bouge en prolongeant P1 (CA-M2) : s'arrêter, proposer un segment à graine propre pour 1989-1993.
- La migration du catalogue change une valeur de `test_reference_1984`.
- J2 ou CA-N4 inatteignable avec les réglages permis (part de l'épargne de Jean-Mi, montants des projets) : tableau mesuré au chef de projet.
- Un champ d'interface existant devrait être renommé ou retiré.

## 8. Recettes

- 10a-moteur : recette **courte** (tests + CA-M + périmètre ; aucune capture) ; push après OK ; fusion avant le lancement de 10a-contenu **et** de l'étape 2 de 10b-I.
- 10a-contenu : recette courte (tests + mesures CA-N) ; les captures du chapitre 1989 sont faites à la recette finale de 10b (fusion complète).
- Valeurs C à confirmer **avant l'export 0.7** (non bloquantes pour le développement) : A2 (boursier), A4 (banquier), dividendes 1989-1993 et dates BNP (docs/37 §9) ; toute correction = commit de données + relance de `test_chapitre_1989`, jamais de re-gel de 1984.

## 9. Conflits avec la suite

- `lot_10b.md` : aucune intersection (10b ne touche ni `data/` ni `scripts/logique/`) ; 10b-I étape 2 démarre sur `main` après 10a-moteur.
- `lot_10c.md` : 10c-L reprend `data/chapitres/1989/foyer.json` et `foyer.gd` **après** la fusion de 10a-contenu.
- Lot 11 : re-gel de 1984 (SCPI, vie aléatoire, jumeaux 1/6) **après** l'export 0.7 ; il s'appuie sur le catalogue (C1-C9) et sur l'interrupteur de révision.
- Lot 13 (sauvegarde manuelle) : format de sauvegarde de ce lot = base ; ne plus le changer d'ici là sans migration douce.
