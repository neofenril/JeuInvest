# Lot 07 (P5 « Le score de la rue ») : titre d'époque, record personnel, collection des titres, écran de fin et écran titre

> Chef de projet, 2026-11-13. **Statut : BROUILLON, non lançable** tant que G6 (game designer) et C1 (client) n'ont pas répondu (`audit_preparation.md` §3). Les défauts ci-dessous s'appliquent si les réponses tardent, **sauf** la définition des choix « épargne / dépense » (D3), qui doit venir du game designer.
> Entrées : docs/15 §6 (P5 allégée, 9 titres, CA-5.1, CA-5.2) ; docs/10 du 29/10 (« record personnel et collection des titres conservés d'une partie à l'autre ») ; `lot_sauvegarde.md` §2 (recharge = hors record) ; `lot_06.md` §10 A7 (4 barres, rang, projets, Sylvie à la fin déjà posés par 05-I).
> Place : après la sortie 0.5. **07-L peut partir dès que dev-logique est libre** (fin de recette 05-L), avant le verdict du joueur : il ne change rien de visible (titres et record éteints tant que 07-I n'est pas fusionné). 07-I part après la fusion de 05-I (R-RUE) et de 07-L, avec la maquette U5.

## 0. Découpage

| Partie | Développeur | Branche / worktree | Départ |
|---|---|---|---|
| **07-L** | dev-logique | `lot/07-logique` / `lot07-logique`, depuis `main` | après la recette de 05-L et la réponse G6 |
| **07-I** | dev-interface | `lot/07-interface` / `lot07-interface`, depuis `main` | après R-RUE, fusion de 07-L et maquette U5 (sinon défauts §1) |
| — | dev-ville | aucune tâche | — |

Hors périmètre : sauvegarde manuelle (SV, seulement le compteur `retours` ici), traces P10, animations de l'écran de fin au-delà de la course des barres existante, sons.

## 1. Décisions (défauts en attendant G6 / C1 / U5)

| # | Sujet | Défaut |
|---|---|---|
| D1 | Titres | Les 9 de docs/15 §6, **dans cet ordre**, premier qui correspond ; textes et « pourquoi » en données `data/titres.json` (provisoires jusqu'à G6). « Ne rien faire » et « Renforcer » comptent ensemble comme « a gardé ». |
| D2 | Seuils | « devant Tata de plus de 2 % » = patrimoine nominal final du joueur > 1,02 × Tata ; « 30 % en actions et SICAV au krach » = part risquée de l'**instantané** du krach (`instantane_krach`), donc calculée même rue éteinte (07-L rend l'instantané indépendant de `rue_active()`) ; « Sylvie fâchée / contente » = `humeur_visible()` en 12/1988 (0 / 2) ; « projet abandonné » = un projet à l'état renoncé (y compris « renoncer pour l'instant » de P2C non repris) ; « n'a détenu que compte courant, Livret A, PEL » = aucun achat d'un autre produit de toute la partie ; « compte courant ≥ 30 % en moyenne » = moyenne mensuelle de (compte courant / patrimoine), mois 01/1984 → 12/1988. Paramètres dans `titres.json`. |
| D3 | Choix « épargne » / « dépense » (titres 4 et 5) | **À définir par le game designer (G6 point 2), bloquant pour 07-L.** Proposition : chaque choix de carte porte `nature: "epargne" | "depense" | "neutre"` dans `foyer.json` ; seuls les choix étiquetés comptent. |
| D4 | Record | **Défaut, à confirmer par le client (C1)** : record = meilleur **écart final en % face à Tata Livret** (même vie, même salaire : il mesure les placements, pas la chance) ; on garde aussi, pour l'affichage, le rang dans la rue, le titre, la date réelle et le prénom. Égalité : le plus ancien reste. |
| D5 | Hors record | `retours` (int, défaut 0) **créé par 07-L** dans `CHAMPS_ETAT` (migration douce) ; `bilan["record_possible"]` = `retours == 0`. SV-L n'aura plus qu'à l'incrémenter. Partie abandonnée ou finie par faillite : ni record ni titre. |
| D6 | Collection | Les titres obtenus, avec le nombre de fois et la première date ; **le titre d'une partie rejouée entre dans la collection** (défaut de `lot_sauvegarde.md` §2, à confirmer C1). Titres non obtenus : affichés « ??? » avec leur rang dans la liste (défaut, à confirmer G6). |
| D7 | Fichier `user://records.sav` | `ConfigFile` lisible (pas de binaire), version 1 : `[record]` (ecart_pct, rang, titre, prenom, date_reelle, patrimoine) et `[collection]` (id = "nombre;première date"). Absent, illisible ou d'une autre version : traité comme vide, **jamais d'erreur**, jamais d'effet sur la partie. Tests : chemin unique par processus ; le vrai fichier du joueur n'est jamais touché (empreinte contrôlée par `tests.ps1`, comme `partie_en_cours.sav`). |
| D8 | Moment de l'écriture | Une seule fois par partie, quand `partie_finie` est émis ; idempotent (identifiant de partie = graine + date réelle de création gardée dans `config`) : une fin rejouée ou relue n'écrit pas deux fois. |
| D9 | Étoiles du bilan existant | **Gardées** à l'écran de fin jusqu'à l'avis G6 point 5 (docs/15 §6 dit « pas d'étoiles » pour le titre : le titre n'a pas d'étoiles, les 5 étoiles existantes sont une autre chose). |
| D10 | Écran de fin (07-I) | Ajout au bloc de 05-I : titre (Pixelify, sans chiffre) + « pourquoi » (Atkinson italique) ; « Nouveau record ! » si `bilan["record"]["nouveau"]` ; « Partie rejouée depuis une sauvegarde : hors record » si `record_possible` faux. PC et téléphone sans défilement si possible. |
| D11 | Écran titre (07-I) | Sous les boutons : « Meilleur résultat : + 12 % face à Tata Livret · 2e de la rue · Le marin par gros temps » (absent sans record) ; bouton secondaire TITRES « 3 / 9 » qui ouvre la collection (liste des 9, obtenus avec nombre et date, autres « ??? »). |

## 2. Interfaces (à figer au lancement ; ajouts seulement)

```gdscript
# class_name Titres (scripts/logique/titres.gd, statique) — dev-logique
static func calculer(e: EtatPartie) -> Dictionary   # {"id": String, "nom": String, "pourquoi": String, "ordre": int}
static func tous() -> Array                         # 9 × {"id", "nom", "ordre"} (pour la collection)
# class_name Records (scripts/logique/records.gd, statique) — dev-logique
const CHEMIN := "user://records.sav"
static func lire(chemin := CHEMIN) -> Dictionary    # {"record": {} | {...}, "collection": {id: {"nombre": int, "premiere": String}}}
static func enregistrer(bilan: Dictionary, chemin := CHEMIN) -> Dictionary   # {"nouveau": bool, "ancien": Dictionary, "collection": Dictionary}
# EtatPartie : CHAMPS_ETAT += "retours" (0), "stats_titre" ({...}, migration douce) ; id de partie dans config
# Bilan.calculer(e) : + "titre": Titres.calculer(e) ({} si abandon / faillite), "projets": {"realises": int, "total": int},
#   "humeur_fin": int, "retours": int, "record_possible": bool, "ecart_tata_pct": float
# Partie : à partie_finie, bilan["record"] = Records.enregistrer(bilan) si record_possible, sinon {"nouveau": false, "hors_record": true}
```

## 3. Carte de propriété des fichiers
| Fichiers | 07-L (dev-logique) | 07-I (dev-interface) |
|---|---|---|
| nouveaux `scripts/logique/titres.gd`, `records.gd`, `data/titres.json`, `tests/test_titres.gd` ; `scripts/logique/*` existants, `partie.gd`, `data/*.json`, `StrategieTest`, tests logiques, `tests.ps1` (empreinte de `records.sav`), `docs/connaissances/dev-logique.md`, socle `developpeur.md` | oui | — |
| `scripts/ui/*` (dont `modale_releve_fin.gd`, `ecran_titre.gd`, nouvelle `modale_titres.gd` si besoin), `principal.gd`, `ecran.gd`, `scenes/`, `project.godot`, `scripts/pixel/ui/*`, `data/pixel/ui/*`, `assets/icone/`, `scripts/outils/*.gd`, familles `scenarios/{titre,ecrans,outils,interface}.gd`, `outils/capture*.ps1` sauf `capture_ville.ps1`, `tests/test_{interface,partie,ecran}.*`, `docs/connaissances/dev-interface.md` | — | oui |
| `scripts/ville/*`, `juice.gd`, `shaders/` | — | — |
| `tests/recette/`, `docs/lots/lot_07_recette.md` | testeur | testeur |

## 4. Tâches
**07-L** : L1 `stats_titre` tenues mois par mois (choix par nature D3, moyenne du compte courant, produits détenus, part risquée et choix au krach, escargots, projets) ; L2 `Titres` + `titres.json` ; L3 `Records` + écriture à la fin (D7, D8) ; L4 `retours`, `record_possible` (D5) ; L5 `Bilan` (§2) ; L6 `StrategieTest` : une stratégie scriptée par titre (9) ; L7 tests, base, compte rendu (répartition des titres sur 40 graines × stratégies existantes, imprimée).
**07-I** : I1 écran de fin (D10) ; I2 écran titre (D11) ; I3 collection ; I4 captures `fin_titre`, `fin_record`, `fin_hors_record` (contenu fabriqué), `titre_record`, `titres_collection` (PC 1920 × 1080, téléphone 1440 × 648) ; I5 `test_interface` : fin d'une démo complète tout allumé, titre affiché == `bilan["titre"]` ; base, compte rendu.

## 5. Critères d'acceptation (★ = obligatoire)
- **CA-T1 ★** : `tests.ps1 -Recette` vert, 0 erreur de script ; `test_interface` et `test_partie` inchangés par 07-L.
- **CA-T2 ★ (CA-5.1)** : chacun des 9 titres atteint par au moins une stratégie scriptée (graine fixe, ligne `TITRE <id> strategie=<nom>`) ; titre et rang calculés dans la logique.
- **CA-T3 ★ (CA-5.2)** : un projet réalisé n'abaisse jamais le rang (40 graines, réaliser / renoncer comparés) ; titre 1 atteignable en réalisant les 2 projets les plus chers.
- **CA-T4 ★ (pédagogie)** : aucun titre ne récompense « Renforcer » seul ni la vente au plus bas ; aucun « achetez », « vendez », « c'est le moment », « auriez dû » dans `titres.json`.
- **CA-T5 ★ (record)** : fichier absent / tronqué / autre version → vide sans erreur ; meilleur écart gardé, pire ignoré, égalité = l'ancien ; `record_possible` faux → record inchangé, collection mise à jour (D6) ; double émission de fin → une seule écriture ; vrai `user://records.sav` intact (empreinte).
- **CA-T6 ★ (compatibilité)** : une sauvegarde 0.5 reprise va jusqu'à la fin avec `retours` = 0 et un titre.
- **CA-T7 ★ (écran de fin)** : `fin_titre` : titre et « pourquoi » == bilan (imprimés) ; `fin_record` : « Nouveau record ! » ; `fin_hors_record` : la ligne hors record ; PC et téléphone : `debordements=0`, `chiffres_pixelify=0`.
- **CA-T8 ★ (écran titre)** : sans `records.sav` : écran identique à `main` ; avec : ligne du meilleur résultat == fichier ; TITRES « n / 9 » ouvre la collection ; cibles ≥ `cible_min`.
- **CA-T9 ★ (périmètre)** : `git diff --stat main...<branche>` dans la colonne du §3.

## 6. Ce qui manque avant de lancer (voir `audit_preparation.md`)
- **G6** (game designer) : D3 (nature des choix), validation des 9 conditions avec le jeu réel, textes définitifs, « ??? », étoiles, seuils de SV.
- **C1** (client) : D4 (critère du record), D6 (partie rejouée dans la collection), ton des titres.
- **U5** (UX) : maquettes de l'écran de fin complet et de l'écran titre (meilleur résultat, collection) ; sinon D10-D11.
