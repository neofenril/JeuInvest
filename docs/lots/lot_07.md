# Lot 07 (P5 « Le score de la rue ») : titre d'époque, record personnel, collection des titres, écran de fin et écran titre

> Chef de projet, 2026-11-13, 2e version le 14/11 (docs/28, docs/29, docs/30 intégrés). **Statut : 07-L PRÊT À LANCER ; 07-I prêt sur le papier (docs/29), lancé après la sortie 0.5.**
> Entrées : docs/15 §6 (P5 allégée, CA-5.1, CA-5.2) ; **docs/10 du 13/11** (record = meilleur écart final en % face à Tata Livret, rang et titre affichés ; pas de sons ; APK 0.5 attendue) ; docs/10 du 29/10 (record et collection conservés d'une partie à l'autre) ; **docs/28** (game designer, G6 : conditions, natures, textes, « ??? », étoiles) ; **docs/29** (UX, U5 : écran de fin, palmarès, collection) ; docs/25 §7 (banquier : rien qui change le code) ; `lot_sauvegarde.md` §2 (recharge = hors record) ; `lot_06.md` §10 A7.
> Règle « version jouable d'abord » (`feuille_de_route_jouable.md`) : **rien de ce lot n'entre dans le chemin critique de la 0.5.** Le rang de la rue est dans la 0.5 (05-I). Titres, record et collection sortent en **0.6**.

## 0. Découpage, branches, ordre

| Partie | Développeur | Branche / worktree | Base | Départ |
|---|---|---|---|---|
| **07-L** | dev-logique | `lot/07-logique` / `JeuClaude_lots\lot07-logique` | **empilée** sur `lot/05-logique` (tag `lot07-base` = 9ed6149, dernier commit remis au testeur) | **tout de suite** (dev-logique est libre pendant la recette de 05-L) |
| **07-I** | dev-interface | `lot/07-interface` / `JeuClaude_lots\lot07-interface` | `main` après la sortie 0.5 (contient 05-I) **et** la fusion de 07-L | après l'envoi de la 0.5 au joueur, pendant l'attente de son verdict |
| — | dev-ville | aucune tâche | — | — |

**Pourquoi empiler 07-L sur `lot/05-logique`** : 07-L modifie `krach.gd`, `bilan.gd`, `projets.gd`, `etat_partie.gd`, `strategie_test.gd`, tous modifiés par 05-L. Partir de `main` donnerait des conflits sûrs ; attendre la fusion de 05-L laisserait dev-logique sans travail pendant une recette. Règles :
1. Si la recette de 05-L est KO : dev-logique **commite son travail en cours sur `lot/07-logique`**, corrige sur `lot/05-logique` (priorité absolue : chemin critique de la 0.5), puis le coordinateur fusionne `lot/05-logique` dans `lot/07-logique` et dev-logique reprend. Jamais les deux branches en même temps.
2. Après la fusion de 05-L dans `main`, le coordinateur fusionne `main` dans `lot/07-logique` **avant** la recette de 07-L (le testeur fait `git diff --stat main...lot/07-logique`).
3. **Entrée dans `main` (opportuniste)** : si 07-L a son OK et ma validation **avant que dev-interface remette 05-I étape 2**, il est fusionné dans `main` avant R-RUE : il ne change rien à l'écran, mais les parties du joueur en 0.5 alimenteront déjà `records.sav` (le joueur retrouvera ses titres en 0.6). Sinon il attend la sortie 0.5 : **on ne retarde jamais R-RUE ni la 0.5 pour 07-L**. Priorité du testeur : 05-L, R-MAISON, R-RUE, puis 07-L.

Mise en place (coordinateur, après le commit de ce plan sur `main`) :
```
git tag lot07-base 9ed6149
git worktree add -b lot/07-logique ..\JeuClaude_lots\lot07-logique lot07-base
```
(si le testeur a commité sur `lot/05-logique` entre-temps, prendre son dernier commit à la place de 9ed6149 et le dire à dev-logique).

Hors périmètre : sauvegarde manuelle (SV : ce lot crée seulement le compteur `retours`, toujours 0 avant SV) ; médailles ou sceaux dessinés par titre (docs/29 §6, peaufinage) ; « DERNIÈRE PARTIE » dans la collection (facultatif reporté) ; sons (décision du joueur du 13/11) ; toute animation nouvelle ; collection ouverte depuis le jeu.

## 1. Décisions (corrigées après docs/10 du 13/11, docs/28, docs/29)

| # | Sujet | Décision |
|---|---|---|
| D1 | Titres | Les 9 de **docs/28 §1.2, dans cet ordre** (« Le neveu de Tonton Matelas » **7e**, « L'écureuil » **8e**), premier qui correspond, évalués une fois à la fin (après la carte du jour J de P2C). Noms et « pourquoi » de **docs/28 §3** dans `data/titres.json` (marques comprises ; remplaçables sans code si le client les refuse). |
| D2 | Grandeurs et seuils | Exactement **docs/28 §1.1** (grandeurs) et **§1.2** (paramètres dans `titres.json` : `ecart_min` 0.02, `part_risquee` 0.30, `cartes_min` 5, `cartes_ecart` 3, `cc_moyen_min` 0.30, `produits_surs` ["livret","pel"], `vente_apres_krach` **0.50 allumé**). **Humeur : `Foyer.humeur_visible()` = 0 contente, 1 neutre, 2 fâchée** (corrige l'ancienne D2, inversée). `part_risquee_krach` = `Krach.base(inst) / inst["patrimoine"]`, **0 si `inst["exemple"]` ou `lignes` vide**. `abandon_evitable` = abandon (y compris « RENONCER POUR L'INSTANT » non repris) alors que RÉALISER ou RÉALISER EN VENDANT était actif ; compte seulement si l'état final du projet est `abandonne`. `a_vendu_krach` = choix « vendre » **ou** ventes d'actions et de SICAV **par ordre du joueur** (pas les ventes automatiques d'un projet) entre 11/1987 et 04/1988 > 50 % de `Krach.base(inst)`. `ecart_tata` = patrimoine nominal joueur / Tata − 1 au dernier mois. |
| D3 | Nature des choix de carte | Champ `"nature": "epargne" | "depense" | "neutre"` **sur chaque choix** de `foyer.json`, valeurs de **docs/28 §2** (C06 et C07 neutres ; C14 a = epargne, b = neutre). Un choix grisé n'est pas fait ; une carte sortie par « Pas les moyens ce mois-ci » ne compte pas. Mesure L7 : si la politique `depenser` donne moins de 5 dépenses sur plus de 10 % des 40 graines, dev-logique passe `cartes_min` à 4 dans `titres.json` et l'écrit dans son compte rendu (pas de point d'arrêt). |
| D4 | Record | **Décision du joueur (13/11)** : meilleur **écart final en % face à Tata Livret** (`bilan["ecart_tata_pct"]` = 100 × `ecart_tata`). Gardés pour l'affichage : rang dans la rue (0 si rue éteinte), titre (id et nom), prénom, patrimoine, date réelle. Nouveau record si strictement meilleur ; égalité : l'ancien reste. |
| D5 | Hors record | `retours` (int, 0) **créé par 07-L** dans `CHAMPS_ETAT` (migration douce) ; `bilan["record_possible"]` = `retours == 0` et `fin == "fin"`. Abandon ou faillite : ni titre, ni record, ni collection. |
| D6 | Collection | Titres obtenus avec nombre et première date réelle ; **le titre d'une partie rejouée entre dans la collection** (défaut gardé, à confirmer par le client sans bloquer : SV n'existe pas encore, `retours` vaut toujours 0). Non obtenus : **« ??? », numéro visible, aucun indice sur la condition**, pas de fanfare à 9/9 (docs/28 §4). |
| D7 | `user://records.sav` | `ConfigFile` (texte), `VERSION = 1` : `[meta] version` ; `[record]` (ecart_pct, rang, titre_id, titre_nom, prenom, patrimoine, date_reelle « AAAA-MM-JJ ») ; `[collection]` (id = `{"nombre": int, "premiere": "AAAA-MM-JJ"}`) ; `[parties] ids` (identifiants déjà comptés, les 200 derniers). Absent, illisible, tronqué ou d'une autre version : vide, **jamais d'erreur ni d'effet sur la partie**. |
| D8 | Moment de l'écriture | Dans `Partie`, quand `partie_finie` est émis, **seulement si `Partie.sauvegarde_auto` est vrai** (vraie partie du joueur : `principal` le met à faux en capture, les tests à faux) et dans `Partie.chemin_records` (défaut `Records.CHEMIN`). Idempotent par `config["id_partie"]` (graine + date-heure réelle de création ; créé à la reprise s'il manque, puis sauvegardé) : une fin rejouée, relue ou reprise n'écrit pas deux fois. 07-L n'a donc **pas besoin de `principal.gd`**. |
| D9 | Étoiles | **Non affichées** (docs/28 §5, docs/29 K1 : elles ne le sont déjà pas). Les clés `etoiles` / `nb_etoiles` restent dans `Bilan` pour les tests. Aucun « Cousin Indice » ni étoile sur l'écran de fin (CA-T7). La phrase factuelle sur l'inflation est gardée **sans étoile** : `bilan["objectif"]["phrase"]` (texte dans `titres.json`). |
| D10 | Écran de fin (07-I) | **docs/29 §1** : bande « titre d'époque » + 2 colonnes au PC, repli téléphone de §1.3 (rien caché, zone qui défile, courbe rendue au téléphone) ; ligne du record en états exclusifs (§1.4) ; en-tête en Atkinson gras (K2) ; % ajouté dans la pastille de comparaison ; « NOUVEAU DANS LA COLLECTION » **gardé** (coût faible, docs/28 §4 et docs/29 d'accord) ; phrase de l'inflation dans la zone « détail » (PC sous les frais, téléphone dans la zone qui défile). |
| D11 | Écran titre et collection (07-I) | **docs/29 §2 et §3** : une rangée « palmarès » (phrase sur plaque + bouton TITRES « n / 9 », touche T) sous la ligne de reprise ; absente sans `records.sav` ; collection en grille 3 × 3 sans défilement, lecture seule, « pourquoi » absent de la collection. |
| D12 | Écarts UX (docs/29 §5) | 1 réorganisation : **acceptée** ; 2 courbe au téléphone : **acceptée** ; 3 étoiles : D9 ; 4 facultatifs : `ecart_tata_pct` et « NOUVEAU DANS LA COLLECTION » **obligatoires**, « DERNIÈRE PARTIE » **reporté** ; 5 en-tête Atkinson : **accepté** ; 6 une rangée : **acceptée**. K4 : l'interface affiche `bilan["humeur_phrase"]`, jamais le nombre. |
| D13 | Sauvegarde manuelle (pour mémoire, SV non lancée) | docs/28 §6 et docs/30 §8 tranchés dans `lot_sauvegarde.md` §10 (14/11) : `toujours` = `["marche","D08","projet","C06"]` (sans `gazette`), enjeu de carte = prix du choix le plus cher, espacement compté depuis la dernière proposition ; écran des emplacements sur une couche à part ; phrase « hors record » dite dans le mode charger. Rien dans ce lot, sauf la touche T (D11). |
| D14 | Humeur de Sylvie (constat du 14/11) | Le code fait foi : `Foyer.humeur_visible()` = **0 contente, 1 neutre, 2 fâchée** (`foyer.gd` l. 132-143, comme docs/17). Les deux erreurs relevées (ancienne D2 de ce plan, docs/29 K4) sont corrigées ici ; dev-logique ne change pas la numérotation ; `bilan["humeur_fin"]` la reprend telle quelle et `bilan["humeur_phrase"]` donne le texte à afficher. |

## 2. Interfaces (figées au lancement ; ajouts seulement)

```gdscript
# class_name Titres (scripts/logique/titres.gd, statique) — dev-logique
static func donnees() -> Dictionary                 # titres.json
static func grandeurs(e: EtatPartie) -> Dictionary  # docs/28 §1.1 : ecart_tata, projets_realises, humeur_fin, abandon_evitable,
                                                    # part_risquee_krach, a_vendu_krach, escargots, nb_epargne, nb_depense,
                                                    # produits_detenus (Array), cc_moyen
static func evaluer(g: Dictionary) -> Dictionary    # pure : {"id", "nom", "pourquoi", "ordre"} (tests sur grandeurs fabriquées)
static func calculer(e: EtatPartie) -> Dictionary   # {} si e.fin != "fin" ; sinon evaluer(grandeurs(e))
static func tous() -> Array                         # 9 × {"id", "nom", "ordre"}, dans l'ordre 1 → 9

# class_name Records (scripts/logique/records.gd, statique) — dev-logique
const CHEMIN := "user://records.sav"
const VERSION := 1
static func lire(chemin := CHEMIN) -> Dictionary
#   {"record": {} | {"ecart_pct": float, "rang": int, "titre_id", "titre_nom", "prenom", "patrimoine": float, "date_reelle": "AAAA-MM-JJ"},
#    "collection": {id: {"nombre": int, "premiere": "AAAA-MM-JJ"}}}
static func enregistrer(bilan: Dictionary, id_partie: String, chemin := CHEMIN) -> Dictionary
#   {"ecrit": bool, "deja_compte": bool, "hors_record": bool, "nouveau": bool, "ancien": Dictionary,
#    "record": Dictionary, "collection": Dictionary, "nouveau_titre": bool}
static func effacer(chemin: String) -> void         # tests seulement

# EtatPartie : CHAMPS_ETAT += "retours" (0), "stats_titre" ({}) ; migration douce ; config["id_partie"] ;
#   instantane_k pris même rue éteinte (+ "patrimoine") ; instantane_krach() inchangé pour l'interface (vide si rue éteinte)
# Bilan.calculer(e) : + "titre": Dictionary ({} si abandon / faillite), "ecart_tata_pct": float, "humeur_fin": int,
#   "humeur_phrase": String, "projets": {"realises": int, "total": int, "liste": [{"id", "nom", "etat"}]},
#   "retours": int, "record_possible": bool ; "objectif" + "phrase"
# Partie : var chemin_records := Records.CHEMIN ; avant d'émettre partie_finie(bilan) :
#   bilan["record"] = Records.enregistrer(bilan, id_partie, chemin_records) si sauvegarde_auto et titre non vide,
#   sinon {"ecrit": false, "hors_record": not bilan["record_possible"], "nouveau": false, "nouveau_titre": false}
```
07-I lit seulement : `bilan[...]` ci-dessus, `Records.lire(Partie.chemin_records)`, `Titres.tous()`. Ses captures fabriquent `bilan["record"]` et un `records.sav` à chemin unique (`Partie.chemin_records`).

## 3. Carte de propriété des fichiers

| Fichiers | 07-L (dev-logique) | 07-I (dev-interface) |
|---|---|---|
| nouveaux `scripts/logique/titres.gd`, `records.gd` (+ `.uid`), `data/titres.json`, `tests/test_titres.gd`, `tests/test_records.gd` (+ `.uid`, `.tscn` si besoin) | oui | — |
| `data/foyer.json` (champ `nature`), `scripts/logique/{etat_partie,bilan,krach,projets,foyer,strategie_test}.gd`, `scripts/partie.gd`, `tests/test_{logique,foyer,projets,krach,sauvegarde,quartier,rue_moteur}.gd` (adaptations seulement), `outils/tests.ps1` (empreinte de `records.sav`), `docs/connaissances/dev-logique.md`, socle `developpeur.md` | oui | — |
| `scripts/ui/*` (dont `modale_releve_fin.gd`, `ecran_titre.gd`, nouvelle `modale_titres.gd`), `principal.gd` (touche T si elle n'est pas dans `ecran_titre`), `scenes/`, `scripts/pixel/ui/*`, `data/pixel/ui/*`, `scripts/outils/*.gd`, familles `scenarios/{titre,ecrans,outils}.gd`, `outils/capture*.ps1` sauf `capture_ville.ps1`, `tests/test_{interface,partie,ecran}.*`, `docs/connaissances/dev-interface.md` | — | oui |
| `scripts/ville/*`, `sequences.gd`, `juice.gd`, `shaders/`, `project.godot`, `export_presets.cfg`, `data/rythme.json` | interdit | interdit |
| `tests/recette/`, `docs/lots/lot_07_recette.md` | testeur | testeur |

`tests/test_interface.*` et `tests/test_partie.*` : **interdits à 07-L** (ils restent à dev-interface). Si l'écriture de `records.sav` à la fin les touche, c'est un défaut de 07-L (D8 : rien n'est écrit quand `sauvegarde_auto` est faux).

## 4. Tâches

### 07-L (dev-logique) — dans cet ordre
- **L0** Lire docs/28 en entier (§1, §2, §3, §7), ce plan, `lot_05.md` (contrat de 05-L). Vérifier en premier que 05-L est vert sur la base (`tests.ps1 -Recette`).
- **L1 Données** : `nature` sur les 32 choix de `foyer.json` (docs/28 §2) ; `titres.json` (ordre, conditions, paramètres D2, textes §3, 2 phrases de l'inflation).
- **L2 Petits ajouts de code (docs/28 §8)** : `abandon_evitable` noté dans `Projets.resoudre` ; `"patrimoine"` dans l'instantané du krach ; instantané pris même rue éteinte (sans rien changer d'autre quand la rue est éteinte : ni « un an après », ni notification) ; part risquée 0 pour un exemple.
- **L3 `stats_titre`** tenues mois par mois et sauvegardées : natures des choix faits, somme `cc / patrimoine` et nombre de mois, produits détenus, ventes d'actions et de SICAV par ordre 11/1987 → 04/1988, escargots, abandon évitable.
- **L4 `Titres`** (§2) ; **L5 `Records`** + écriture dans `Partie` (D7, D8), `id_partie`, `retours`, `record_possible` ; **L6 `Bilan`** (§2).
- **L7 Stratégies et mesures** : une stratégie scriptée par titre (docs/28 §7 ; dans `StrategieTest` ou dans `test_titres`, graine fixe, cartes, projets, rue allumés). Mesures imprimées : `nb_epargne` / `nb_depense` sur 40 graines pour `epargner` et `depenser` ; répartition des 9 titres sur 40 graines × stratégies existantes ; alerte écrite au compte rendu si un titre dépasse 50 % des parties `alterner` ou si `bon_pere` n'est jamais obtenu hors stratégie dédiée (non bloquant : question au game designer).
- **L8** `tests.ps1` (empreinte de `records.sav`), base `dev-logique.md`, compte rendu (fichiers comparés au §3, mesures, écarts).

### 07-I (dev-interface) — après la sortie 0.5
- **I1** Écran de fin (D10, docs/29 §1) ; **I2** écran titre (D11, docs/29 §2) ; **I3** collection (docs/29 §3) ; **I4** captures `fin_titre`, `fin_record`, `fin_hors_record`, `fin_sans_titre`, `titre_record`, `titres_collection` (PC 1920 × 1080, téléphone 1440 × 648 ; `fin_*` aussi en 1920 × 1009) ; **I5** `test_interface` : fin d'une démo complète tout allumé, titre affiché == `bilan["titre"]["nom"]` ; base, compte rendu.
- **Peut démarrer avant la fusion de 07-L ?** Non utile : 07-I part après la 0.5, et 07-L sera alors sur `main`. Si 07-L n'y est pas encore, I2 et I3 (écran titre, collection) peuvent partir sur un `records.sav` fabriqué et `Titres.tous()` lu par `has_method` ; I1 attend 07-L.

## 5. Critères d'acceptation (★ = obligatoire)

### 07-L
- **CA-T1 ★** `tests.ps1 -Recette` vert, 0 erreur de script, total ≥ référence de la base ; `test_interface` et `test_partie` **inchangés** (diff vide) et verts.
- **CA-T2 ★ (CA-5.1)** Chacun des 9 titres atteint par sa stratégie dédiée : 9 lignes `TITRE <id> strategie=<nom> graine=<n>` imprimées, chacune vérifiée.
- **CA-T3 ★ (CA-5.2)** Sur 40 graines, réaliser un projet n'abaisse jamais le rang par rapport à y renoncer (lignes comparées imprimées) ; `bon_pere` atteint avec les 2 projets les plus chers réalisés.
- **CA-T4 ★ (pédagogie)** Aucun titre ne demande « Renforcer » ; aucun n'est attribué pour une vente (le 2 la nomme comme une erreur) ; `titres.json` ne contient ni « achetez », ni « vendez », ni « c'est le moment », ni « auriez dû » ; noms sans chiffre ; « pourquoi » ≤ 15 mots (test).
- **CA-T5 ★ (conditions)** `evaluer` sur grandeurs fabriquées : chaque condition de docs/28 §1.2 aux bornes (ex. `ecart_tata` 0,02 pile = non, `nb_epargne` 5 et écart 3 = oui, 4 = non) ; ordre 7 avant 8 (compte courant seul → `neveu_matelas`) ; **humeur 0 = contente, 2 = fâchée** (cigale exige 0, fourmi accepte 2) ; exemple de krach → part risquée 0 ; vente par ordre en 12/1987 > 50 % → `a_vendu_krach` ; vente automatique d'un projet → non ; renoncer faute d'argent → `abandon_evitable` faux.
- **CA-T6 ★ (natures)** Chaque choix de `foyer.json` a une `nature` valide, égale au tableau de docs/28 §2 (test qui recopie le tableau) ; mesure L7 imprimée (`NATURES politique=<p> depenses_min=… sous5=<n>/40`) et `cartes_min` cohérent avec la règle D3.
- **CA-T7 ★ (record)** Fichier absent / tronqué / autre version → vide, sans erreur ; meilleur écart gardé, pire ignoré, égalité = l'ancien ; `record_possible` faux (`retours` forcé à 1) → record inchangé, collection mise à jour ; double `partie_finie` (même `id_partie`) → une seule écriture (`deja_compte`) ; abandon et faillite → aucune écriture ; `sauvegarde_auto` faux → aucune écriture ; empreinte du vrai `user://records.sav` identique avant / après `tests.ps1` (absent reste absent).
- **CA-T8 ★ (compatibilité)** Une sauvegarde de la base (0.5) et une de `main` 0.4 reprises vont jusqu'à la fin : `retours` = 0, `id_partie` créé, un titre non vide, aucune erreur ; partie rue éteinte : `instantane_krach()` toujours vide pour l'interface, références de `test_logique` (intégrale, frais, interruptions) inchangées.
- **CA-T9 ★ (périmètre)** `git diff --stat main...lot/07-logique` (après fusion de 05-L dans `main` puis de `main` dans la branche) dans la colonne 07-L du §3.
- CA-T10 (mesure, non bloquant) Répartition des 9 titres imprimée ; alertes du L7 écrites au compte rendu.

### 07-I (vérifiés à sa recette, qui est aussi une fusion complète)
- **CA-T11 ★ (écran de fin)** `fin_titre`, `fin_record`, `fin_hors_record`, `fin_sans_titre` : ligne `UI fin titre="<nom>" pourquoi=oui record=<nouveau|ancien|hors|aucun> projets=<n>/<t> humeur=<0|1|2> debordements=0 chiffres_pixelify=0` (docs/29 §1.6), titre et « pourquoi » == bilan ; aucun texte « étoile » ni « Cousin Indice » ; au téléphone `defilant_visible>=96 boutons_visibles=oui` ; PC 1920 × 1009 sans défilement.
- **CA-T12 ★ (écran titre)** Sans `records.sav` : `UI titre palmares=absent` et capture identique à `titre` de `main` ; avec : phrase == fichier, TITRES « n / 9 » ouvre la collection, touche T ; cibles ≥ `cible_min`.
- **CA-T13 ★ (collection)** `titres_collection` : `UI titres tuiles=9 obtenus=<n> debordements=0 cibles sous_seuil=0` ; non obtenus = « ??? » sans aucun texte de condition.
- **CA-T14 ★** `test_interface` : démo complète tout allumé, titre affiché == `bilan["titre"]["nom"]` ; une partie jouée à la main jusqu'à la fin (PC et téléphone) écrit `records.sav` puis l'écran titre le montre ; périmètre colonne 07-I.

## 6. Ce qui reste ouvert (rien ne bloque 07-L)
- Client (C1 point 3) : noms des titres et marques (Club Med, Caisse d'épargne) ; D6 (partie rejouée dans la collection). Réponse = données seulement.
- Game designer : alertes de répartition de L7 éventuelles.
- 07-I : aucun manque de spécification (docs/29 reçu) ; il attend seulement que dev-interface soit libre après la 0.5.
