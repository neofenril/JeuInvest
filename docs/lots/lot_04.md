# Lot 04 (vague 3) : moteur des projets et filets du foyer (04-L), carte de dilemme et « Mon foyer » (03-I2), Sylvie et objets des cartes (03-V2)

> Chef de projet, 2026-11-12. Base : `main` 580c7cc (lot 03 fusionné, 725 vérifications avec `-Recette`), puis `main` + 03-R (`lot_03r.md`) pour 04-L et 03-I2.
> Origine : `feuille_de_route.md` §2.8 (vague 3 prête, décisions 4 et 5, reports 2, 5, 7) ; `lot_03_recette.md` (03-I m3/m4, 03-L m2, 03-V m1-m3, 03-foyer m1-m4) ; docs/15 §2-3, §7 (P2, P1, P10) ; docs/17 §4.1-4.4 (UX vague 3) ; docs/18 §2-3 (prix des projets, vente automatique) ; **docs/22** (banquier : C02, C03, C10) ; **docs/23** (game designer : G1 textes, G2 validée, G3 validée, picto « fâchée »).

## 0. Objectif, périmètre, découpage

**Ce que le joueur verra à la fin du lot (sortie possible 0.5 « les dilemmes du foyer »)** : dans une **nouvelle partie**, 8 à 10 fois, une carte de dilemme sort de la maison (porte qui s'ouvre, fiche qui vole et se déplie) avec deux choix de même poids, leur montant et l'effet sur l'humeur de Sylvie ; après le choix, un tampon « CHOISI » et une ligne de conséquence au conditionnel. Sylvie change de visage, de posture et de fenêtre selon son humeur, avec une bulle (« Sylvie est ravie », « Sylvie se radoucit »…) et un picto sur l'étiquette MA MAISON. La maison garde les traces des choix (télé, antenne, poussette, chien, diplôme, escargot). « Mon foyer » devient la porte du frigo (humeur, dernière cause, cartes jouées). La banque est fermée tant qu'une carte attend. Le moteur des **projets** (P1) est écrit mais **éteint** (l'écran des projets est la vague 4).

Une partie commencée avant ce lot (0.4 / 0.4.1) **reste sans cartes** (réglage gardé dans la sauvegarde, D11 du lot 03) : à dire au joueur.

| Partie | Développeur | Branche / worktree | Contenu | Départ |
|---|---|---|---|---|
| **03-V2** | dev-ville | `lot/03-ville2` / `lot03-ville2` | Sylvie en 3 humeurs (docs/17 §4.2), objets des cartes (docs/15 §7), sortie de la carte depuis la maison (`Sequences`), reports m1-m3 de 03-V | **tout de suite** (depuis `main` qui contient ce plan) |
| **04-L** | dev-logique | `lot/04-logique` / `lot04-logique` | Invariant « une carte ouverte se ferme toujours » (1re tâche), coup dur prioritaire (G3), textes G1 / docs/22 dans `foyer.json`, moteur des projets P1 **éteint** (`projets.gd`, `projets.json`), contrat figé pour la vague 4, version 0.5 des exports | après la fusion de 03-R |
| **03-I2** | dev-interface | `lot/03-interface2` / `lot03-interface2` | Carte de dilemme (`Modales.carte`), bulle d'humeur, picto sur l'étiquette, « Mon foyer », BANQUE fermée pendant une carte, fiche des dividendes (03-R), petites reprises, **cartes allumées** pour une nouvelle partie | après la fusion de 03-R ; étape finale après fusion de 04-L et 03-V2 (§6) |

Hors périmètre : écran des projets (carte de choix, jauge, « Le jour J », ligne du guichet : **04-I**, vague 4, sur le contrat §4.2) ; traces P10 des projets (04-V) ; voisins et Jean-Mi (05) ; sons ; sauvegarde manuelle (non lancée) ; avis UX encore non demandés (repli téléphone 1280 × 720, « MA MAISON » au-dessus de « ‹ LA GAZETTE ») ; bulle « intérêt / dividende » (docs/22 §2, client).

## 1. Décisions du chef de projet

| # | Sujet | Décision | Pourquoi |
|---|---|---|---|
| D1 | Invariant « une carte ouverte se ferme toujours » (`feuille_de_route.md` §2.8 décision 4) | **Dans le moteur** (`EtatPartie`), pour le portefeuille du joueur, tant que `modale` est de kind `carte` ou `projet` : `acheter`, `deposer_livret`, `ouvrir_pel`, `verser_pel`, `acheter_emprunt`, `verser_av`, `programmer_versement`, `reactiver_versement` renvoient `{"ok": false, "refus": "carte", "msg": "Réglez d'abord la carte du foyer."}` sans effet. Ventes, retraits, rachats, arrêt d'un versement : permis (ils ne baissent pas le disponible). **Filet** : `resolution_auto()` sur une carte dont aucun choix n'est payable renvoie une sortie « Pas les moyens ce mois-ci » (0 F, humeur inchangée, ligne d'historique genre `carte`, `choix "aucun"`) au lieu de `{}`. `resoudre_modale("aucun")` n'est accepté que dans ce cas. | Garantie tenue sans l'écran ; la BANQUE grisée de 03-I2 n'est qu'un confort. |
| D2 | Coup dur après une carte (G3, docs/23 : validé avec préférence) | (a) Les événements de vie **aléatoires** déjà tirés dans `e.calendrier` comptent comme **interruptions datées connues** pour l'anticipation **des cartes seulement** (`Cadence.date_connue` ou un test dédié dans `peut_passer` pour `kind "carte"`) : la carte glisse dans sa fenêtre, sinon le créneau est abandonné ; (b) si une carte est déjà passée au mois m − 1, un événement de vie au mois m **garde sa pause** : nouvelle exception de R-CADENCE « carte → vie », comme « marché → panne » ; (c) **jamais** un événement de vie rétrogradé en notification à cause d'une carte. | Docs/23 G3 ; le coup dur enseigne l'épargne de précaution. |
| D3 | Textes du foyer (G1, docs/22 §3) | Dans `foyer.json`, sans code sauf D4 : 32 répliques de docs/23 G1.2 (« Dallas » gardé, certitude B, à signaler au client) ; bulle `neutre` (en remontant de fâchée) = « Sylvie se radoucit » ; textes C02, C04 (+ `texte_jumeaux`), C07, C09, C10 de docs/23 G1.5 ; **C10** : `requiert_enfant: true`, `texte` et `texte_jumeaux` de docs/23 (le game designer prime sur la variante neutre du banquier : la naissance est scriptée, il y a toujours un enfant en 1987) ; « pourquoi » : C03 = docs/22 §3.1 **variante A** (sans chiffre), C10 = docs/22 §3.2, C02 = variante de docs/22 §3.3 ; `_erosion` cite docs/23 G2 (règle confirmée). | Contenu arrivé ; tout reste remplaçable sans code. |
| D4 | Ligne après C14 « Tout vendre » (docs/23 G1.3) | Gabarit `foyer.json > gabarits > consequence_revenu` = « + {montant} sur votre compte. « {replique} » » pour les choix de type `revenu` ; repli = réplique seule si le gabarit manque. | Petit code, lisible. |
| D5 | Mesures de l'humeur (docs/23 G2 point 4) | `MESURE C00` imprime aussi, par politique : graines qui **finissent** fâchées, plus long séjour fâché (mois). Si une graine `alterner` reste fâchée **> 24 mois** d'affilée : ligne `ALERTE humeur alterner graine=<g> mois=<n>` (pas un échec ; je la transmets au game designer). | Demande du game designer, sans seuil bloquant. |
| D6 | Projets (P1) **éteints** | Comme les cartes au lot 03 (D11) : `data/projets.json > actif: false` ; une partie lit `config["projets"]` (défaut = `projets.json > actif`) et garde ce réglage dans sa sauvegarde. Les tests l'allument. 04-I (vague 4) l'allumera dans `principal._config()`. Les conditions S7 (projet P2A) et S10 (échéance de projet en 02/1988) de `foyer.json` deviennent **réelles** (vraies seulement projets allumés). | Une modale `kind "projet"` tomberait sur une interface qui ne la connaît pas. |
| D7 | Règles des projets | docs/15 §3.1 et §3.2 telles quelles, **montants de docs/18 §2** (P1B 16 000 F ; les autres comme docs/15), libellés « apport comptant » pour P1C, P2B, P2C (docs/18 §6.4). Vente automatique dans l'ordre de docs/15 (SICAV, actions la plus grosse ligne d'abord, emprunt d'État, assurance-vie, PEL) : **ordre gardé** malgré la réserve du banquier (docs/18 §3.1 : on vend d'abord le risque ; ordre fixe, jamais présenté comme un conseil) ; on vend **juste ce qu'il faut** (dernière ligne partielle ; actions par titres entiers, le surplus va au compte courant), avec les frais, impôts et pénalités du moteur existant ; textes de pénalité de docs/18 §3.2. P2C réalisé : l'apport reste dans le patrimoine sous une ligne « Apport du T3 » (joueur et témoins, R-MIROIR) ; **à confirmer par le client** (docs/15 §3.2), réglage en données (`p2c_dans_patrimoine: true`). | Spec et contenu disponibles. |
| D8 | Résolution automatique des projets | `resolution_auto()` : choix de projet = l'option la **moins chère** ; échéance = RÉALISER si le disponible suffit, sinon REPORTER si possible, sinon RENONCER (**jamais** de vente sans le joueur). `StrategieTest` : nouvelles politiques `politique_projets` (`moins_cher`, `plus_cher`, `milieu`) et `politique_echeance` (`auto` = D8, `vendre` = réaliser en vendant si possible). | Le joueur passif ne vend rien à sa place. |
| D9 | Cartes allumées (03-I2) | `principal._config()` ajoute `"cartes": true` **hors mode capture** (`ScenariosCapture.mode_capture()` faux) : toute nouvelle partie du joueur a les cartes. En mode capture, les cartes restent éteintes par défaut (aucune étape existante ne change, `integrale` reste la référence) ; les étapes qui veulent des cartes passent `"cartes": true` dans leur configuration. Une reprise garde le réglage de sa sauvegarde. `foyer.json > actif` reste `false` (tests logiques inchangés). | Évite de casser toutes les étapes de capture des trois développeurs par des pauses imprévues. |
| D10 | Où vit l'humeur à l'écran | **La ville se synchronise seule** : `ville.suivre_foyer(e)` (dev-ville) règle Sylvie (`humeur_visible()` si `cartes_actives()`, sinon neutre) et les traces ; la ville l'appelle sur `Partie.partie_commencee`, `Partie.mois_passe` et `Partie.modale_fermee` (connexions dans `ville.gd`). L'interface ne fait que la **bulle** et le **picto** (notif `type "humeur"`). Aucun appel de `principal.gd` vers `regler_humeur_sylvie`. | Pas de dépendance croisée entre 03-I2 et 03-V2. |
| D11 | Traces des cartes (docs/15 §7, lignes des cartes) | Calculées **par la ville** à partir du contrat de 03-foyer (`cartes_jouees()`, `enfants`, `Banquier.jumeaux(e)`, `ab_courant()`, `historique`) : `tele` (C02 « a » ou C03 « a »), `antenne` (C03 « a »), `poussette` / `poussette_double` (C04 jouée, quel que soit le choix, jusqu'à 12/1986), `tricycle` / `tricycles` (C04 jouée, à partir de 01/1988), `chien` (C10 jouée, l'un ou l'autre choix ; aspect différent permis), `diplome` (C07 « a », à partir de 01/1988), `escargot` (l'historique contient une notification `escargots`). Berceau : existant, inchangé. Cartes éteintes : aucune trace. Les traces de fenêtre se posent **sur l'appui à droite** (docs/17 §4.2). | Aucune API nouvelle de la logique ; testable par une fonction pure. |
| D12 | Picto et visage « fâchée » (docs/23) | Sourcils en V **doux** : extrémité intérieure 1 px plus bas que l'extérieure, pas plus ; pupilles décalées d'1 px du même côté (« elle regarde ailleurs ») ; bouche en arc tombant. **Même règle** pour le picto 16 × 16 (03-I2), le portrait 48 × 48 (03-I2) et le buste à la fenêtre (03-V2). Si le V d'1 px ne se distingue plus du neutre à ×1, garder le V actuel (à dire). Validation UX sur les captures (après le lot, non bloquante). | Bouderie, pas colère (garde-fou 14 §6.3). |
| D13 | Montants des cartouches (m2 de 03-V) | Le cartouche total du mois ne mélange **jamais** des lignes `verse_en_decembre` vrai et faux : intérêts (versés en décembre) dans un cartouche « + 285 F ce mois-ci / versés en décembre » ; dividendes et coupons dans leurs cartouches nommés (« Elf : + 120 F »). | Le joueur croyait avoir reçu 507 F. |
| D14 | Montant des notifications de dividende (m3 de 03-I) | La notification `dividende` affiche à droite le montant en `Format.entier` (comme son texte et les cartouches). Les autres notifications sont inchangées. | Cohérence « 176 F » / « +175,92 F ». |
| D15 | Version | Sortie visée à la fin du lot : **0.5** « les dilemmes du foyer ». `project.godot > config/version="0.5"` (03-I2) ; `export_presets.cfg` 0.5.0.0, Android « 0.5 » / code 6 (04-L). Exports par le coordinateur sur `main` après F3. La numérotation des sorties suivantes de `feuille_de_route.md` §1 glisse d'un cran (0.6 = projets). | Les cartes sont une vraie nouveauté pour le joueur. |

## 2. Mise en place (coordinateur)

```powershell
$git = "C:\Users\arthu\Documents\temp\JeuClaude\outils\git\cmd\git.exe"
$depot = "C:\Users\arthu\Documents\temp\JeuClaude"
$lots = "C:\Users\arthu\Documents\temp\JeuClaude_lots"
# 1) tout de suite (main contient ce plan, lot_03r.md, docs/22, docs/23) :
& $git -C $depot worktree add -b lot/03-retouches "$lots\lot03-retouches" main   # lot_03r.md
& $git -C $depot worktree add -b lot/03-ville2    "$lots\lot03-ville2"    main
# 2) après la fusion de lot/03-retouches dans main :
& $git -C $depot worktree add -b lot/04-logique     "$lots\lot04-logique"     main
& $git -C $depot worktree add -b lot/03-interface2  "$lots\lot03-interface2"  main
```
- Ne pas réutiliser les anciens dossiers (`lot03-*`, `lot02-*`, `px*`, `lot01-*`, `f1-logique`) : leurs branches sont fusionnées, ils peuvent être retirés (`worktree remove`) au choix du coordinateur.
- `tests.ps1`, `capture*.ps1` trouvent Godot depuis un worktree. `user://` est commun : ne jamais écrire ni effacer `partie_en_cours.sav` ; ne jamais fermer un Godot qu'on n'a pas lancé.
- Avant chaque fusion : supprimer dans le dépôt principal les `polices/*.ttf.import` non suivis s'il y en a.
- Commits locaux en français, un par tâche, `tests.ps1` vert avant chaque commit, aucun push avant l'OK du testeur.

## 3. Carte de propriété des fichiers (lot 04)

Chemins relatifs à `godot/`. Les `.uid` suivent leur script. **Un fichier absent du tableau est interdit à tous.**

| Fichiers | 04-L | 03-I2 | 03-V2 |
|---|---|---|---|
| `scripts/logique/*.gd` (dont `foyer.gd`, `cadence.gd`, `etat_partie.gd`, `banquier.gd`, `strategie_test.gd`, nouveau `projets.gd`), `scripts/partie.gd` | oui | — | — |
| `data/*.json` (dont `foyer.json`, `rythme.json`, `banque.json`, nouveau `projets.json`) | oui | — | — |
| `tests/test_{logique,demo,cadence,mois_utile,sauvegarde,dividendes,foyer}.*`, nouveau `tests/test_projets.*`, `tests/autocontrole/`, `outils/tests.ps1`, `outils/trouver_godot.ps1` | oui | — | — |
| `export_presets.cfg` (versions), `Exporter_*.bat`, `Jouer_Godot.bat` (aucun changement attendu) | oui | — | — |
| `docs/connaissances/developpeur.md` (socle), `docs/connaissances/dev-logique.md` | oui | — | — |
| `scripts/ui/*` (dont `modales.gd` et ses parties, `hud.gd`, `panneau_banque.gd`, `bulle.gd`, nouveaux fichiers de la carte et de « Mon foyer »), `scripts/principal.gd`, `scripts/ecran.gd`, `scenes/`, `project.godot`, `scripts/pixel/ui/*`, `data/pixel/ui/*`, `polices/**/*.import`, `shaders/papier.gdshader`, `assets/icone/`, `scripts/outils/*.gd`, familles `scenarios/{titre,banque,ecrans,outils,interface}.gd`, `outils/capture.ps1`, `outils/capture_interface.ps1`, `tests/test_{interface,partie,ecran}.*`, `docs/connaissances/dev-interface.md` | — | oui | — |
| `scripts/ville/*` (dont `ville.gd`, `maison.gd`, `sequences.gd`, `pieces_mois.gd`), `scripts/juice.gd`, `scripts/pixel/*.gd` hors `scripts/pixel/ui/`, `data/pixel/ville/`, `data/pixel/LISEZMOI.md`, `shaders/` hors `papier.gdshader`, `scripts/outils/scenarios/ville.gd`, `tests/test_{pixel,rue,pieces}.gd`, `outils/capture_ville.ps1`, `docs/connaissances/dev-ville.md` | — | — | oui |
| `tests/recette/`, `docs/lots/lot_04_recette.md` | testeur | | |
| `docs/` hors bases nommées ci-dessus | chef de projet / coordinateur | | |

Règles : 04-L ne touche ni `test_interface` ni `test_partie` ; contrat de `Partie` / `EtatPartie` / `Foyer` : **ajouts seulement** (base du chef de projet §2 et contrat de 03-foyer). dev-ville ne modifie pas `data/pixel/ui/*`. Vérifié pour ce plan : aucun fichier dans deux colonnes ; `project.godot` entier à dev-interface (03-R l'a rendu après sa ligne de version).

## 4. Interfaces (figées avant le lancement)

### 4.1 Fournies par 04-L dans ce lot (lues à la fusion)
```gdscript
# EtatPartie : ordres refusés pendant une carte ou un projet (D1)
#   {"ok": false, "refus": "carte", "msg": "Réglez d'abord la carte du foyer."}
func ordres_bloques() -> bool          # vrai tant que modale.kind est "carte" ou "projet" (lu par 03-I2 à la fusion, par has_method)
# resolution_auto() d'une carte sans choix payable : {"choix": "aucun", "kind": "carte", "montant": 0.0,
#   "consequence": "Pas les moyens ce mois-ci.", "humeur_avant": h, "humeur_apres": h, "notifs": []}
# Notification humeur : titre « Sylvie se radoucit » en remontant de fâchée (D3) ; les autres inchangés.
```
03-I2 n'appelle `ordres_bloques()` que par `has_method` ; sur sa branche seule, il grise la BANQUE sur `Partie.etat.modale.get("kind") == "carte"` (même phrase, littérale : « Réglez d'abord la carte du foyer. »).

### 4.2 Contrat de P1 (projets), figé pour la vague 4 (04-I, 04-V) ; ajouts seulement
```gdscript
# EtatPartie
func projets_actifs() -> bool
func projet_en_cours() -> Dictionary   # {} si aucun ; sinon {"id": "P1C", "nom": String, "icone": String, "montant": float (euros),
	# "m_echeance": int, "echeance_txt": "avril 1986", "mois_restants": int, "report_utilise": bool, "reportable": bool,
	# "disponible": float (compte + Livret A), "revendable": float (valeur nette de revente des placements, frais, impôts et pénalités compris),
	# "atteint": bool (disponible >= montant)}
func projets_passes() -> Array         # [{"id", "nom", "icone", "montant", "statut": "realise"|"realise_apres_report"|"abandonne", "m", "ab"}]
func ligne_projet_guichet() -> String  # « Projet : la Super 5, avril 1986 (dans 14 mois) · 30 000 F », "" si aucun projet en cours
func plan_vente_projet() -> Array      # ventes nécessaires, dans l'ordre (D7) : [{"id", "nom", "vendu": float (brut), "net": float,
	# "frais": float, "impot": float, "penalite": float, "texte_penalite": String, "ecart_verse": float (net − versé, signé), "texte_ecart": String}]
# contenu_modale() d'un choix de projet :
# {"kind": "projet", "etape": "choix", "source": "maison", "date": String, "ab": int, "id": "P1"|"P2", "titre": String, "texte": String,
#  "choix": [{"id": "P1A", "titre": String, "montant": float, "echeance_txt": String, "icone": String, "sous": String}]}   # toujours 3
# contenu_modale() du jour J :
# {"kind": "projet", "etape": "echeance", "source": "maison", "date", "ab", "id": "P1C", "titre", "texte", "montant": float,
#  "disponible": float, "manque": float (≥ 0), "ventes": plan_vente_projet(), "apres_ventes": float (disponible + nets),
#  "choix": [{"id": "realiser"|"realiser_en_vendant"|"reporter"|"renoncer", "titre": String, "desactive": bool, "sous": String}]}
#  (P2C : "reporter" absent, "renoncer" titré « RENONCER POUR L'INSTANT »)
# resoudre_modale(id) -> {"choix", "kind": "projet", "etape", "montant": float, "consequence": String, "humeur_avant": int,
#   "humeur_apres": int, "notifs": Array, "ventes": Array (ventes faites)}
# notif rappel (3 mois avant l'échéance, sans pause) : {"type": "projet_rappel", "source": "maison", "cls": "neutre",
#   "projet": "P1C", "titre": String, "texte": String}
# Historique : genre "projet", source "maison" (choix, réalisation, report, abandon).
```
Nouveau `class_name` du lot : **`Projets`** (04-L, `scripts/logique/projets.gd`, statiques sur une `EtatPartie` comme `Foyer`). Aucun autre.

### 4.3 Carte de dilemme : interface ↔ séquence (03-I2 → 03-V2)
```gdscript
# Modales (façade, dev-interface)
func carte(c: Dictionary, depart: Vector2) -> void
	# c = contenu_modale() d'une carte (contrat lot_03 §5.3 bis). Fiche qui vole de depart (point d'écran ; (-1, -1) = apparition sur place)
	# puis se déplie (docs/17 §4.1). Émet choix_fait("carte", "a"|"b") quand le joueur touche un choix non désactivé ;
	# la carte RESTE affichée. Touches 1 / 2 ; ni clic extérieur ni Échap.
func conclure_carte(r: Dictionary, arrivee: Vector2) -> void
	# Coroutine. r = retour de Partie.resoudre_modale. Tampon « CHOISI », l'autre choix à 40 %, r["consequence"] 3 s
	# (un toucher passe, aucun compte à rebours), puis rangement vers arrivee ((-1, -1) = fondu) ; rend la main quand la carte a disparu.
```
```gdscript
# Sequences (dev-ville), kind "carte" :
#   caméra sur la maison (docs/17 §3.1) → porte ouverte (3 images) → si modales.has_method("carte") : modales.carte(c, porte)
#   sinon modales.courrier(c, porte, e) (repli, règle permanente) → await choix_fait → r = Partie.resoudre_modale(id)
#   (si r est vide : on attend un autre choix) → si modales.has_method("conclure_carte") : await modales.conclure_carte(r, porte)
#   → porte refermée. Sortie ≤ 1 s, passable d'un toucher.
```

### 4.4 Fournies par 03-V2 (ville)
```gdscript
# scripts/ville/ville.gd
func suivre_foyer(e: EtatPartie) -> void            # D10 : humeur de Sylvie + traces, idempotent ; e null = rien
func traces_foyer(e: EtatPartie) -> PackedStringArray   # D11 : ids des traces présentes ce mois-ci (fonction pure)
# API existante inchangée (regler_humeur_sylvie, humeur_sylvie, point_sylvie, porte_ecran, cx_pour…).
```

### 4.5 Sauvegarde
Format 3 inchangé, migration douce. 04-L : champ d'état `projets` (défaut : éteint, aucun projet) ; une sauvegarde de `main` (sans `projets`) se recharge, projets éteints, et va jusqu'à la fin. 03-I2 : rien (le réglage `cartes` est déjà sauvegardé).

## 5. Tâches

### 5.1 04-L (dev-logique, `lot/04-logique`), dans cet ordre
1. **L1 Invariant de la carte (D1)** : refus des ordres débiteurs pendant une carte ou un projet (joueur seulement), `ordres_bloques()`, filet de `resolution_auto`, `resoudre_modale("aucun")`. Test qui rejoue `RECETTE blocage` (graine 7, C01, disponible ramené à 0) : la partie avance jusqu'à la fin par `avancer` + `resolution_auto`, **et** par `Partie.sauter_jusqu_a(…, true)` si l'autoload est accessible au test (sinon le dire).
2. **L2 Coup dur prioritaire (D2)** : anticipation des cartes sur les événements de vie du calendrier, exception « carte → vie », test.
3. **L3 Textes (D3, D4, D5)** : `foyer.json` (répliques, bulles, textes, C10, « pourquoi », `_erosion`), gabarit `consequence_revenu` ; `test_foyer` : aucun chiffre hors gabarits `{…}` dans `texte`, `texte_jumeaux`, `pourquoi`, `replique` (expression `\d` après retrait des `{…}`), répliques 2 à 8 mots ; `MESURE C00` étendue.
4. **L4 Projets (D6, D7, D8)** : `data/projets.json` (actif false ; P1, P2 : fenêtre de choix, 3 options, montants en francs, échéances, icônes, textes provisoires §8, rappel, report +4, effets d'humeur +2 / +1 / −1 / −2, ordre de vente, textes de pénalité, gabarit du guichet, `p2c_dans_patrimoine`) ; `scripts/logique/projets.gd` ; points d'appel dans `etat_partie.gd` seulement (pas de règle dedans) ; `Cadence` (rang 2 échéance, 5 choix, budget `projets` ≤ 4) ; conditions S7 / S10 de `foyer.json` branchées ; R-MIROIR (témoins : même montant, même mois, compte puis Livret A, négatif permis ; rien en cas d'abandon) ; humeur par `Foyer` (bulles) ; historique genre `projet` ; sauvegarde ; contrat §4.2 ; `StrategieTest` (D8).
5. **L5 Tests** `tests/test_projets.*` (+ `test_cadence` et `test_foyer` projets allumés) : CA-L4 à L7.
6. **L6 Version (D15)** : `export_presets.cfg` 0.5.0.0, « 0.5 », code 6.
7. Socle (projets, invariant, G3, nouvelles références), base, compte rendu (mesures du §7.1).

### 5.2 03-V2 (dev-ville, `lot/03-ville2`), dans cet ordre
1. **V1 Sylvie en 3 humeurs** (docs/17 §4.2 ; D12) : visage, posture (coucou toutes les 8 s réelles en « contente », bras croisés en « fâchée »), fenêtre (géraniums, rideau tiré), clignement ; changement d'état = clignement puis nouvelle image ; aucune animation décidée sur `Partie.vitesse` seule.
2. **V2 Synchronisation (D10)** : `suivre_foyer(e)`, connexions aux signaux de `Partie` dans `ville.gd`.
3. **V3 Objets des cartes (D11)** : `traces_foyer(e)` + dessins (palette, pas de rotation ni de mise à l'échelle, une animation = des images ; lueur de télé qui scintille).
4. **V4 Sortie de la carte (§4.3)** : séquence `kind "carte"` dans `sequences.gd`, porte de la maison en 3 images.
5. **V5 Reports de 03-V** : m1 (cartouche jamais sur le panneau INDICE de la Gazette, PC et téléphone) ; m2 (D13) ; m3 (deux cartouches ne se recouvrent jamais, à aucune image : décaler l'arrivée de l'or ou sa place).
6. **V6 Étapes de capture** (famille `ville`) : `sylvie_humeurs` (3 états, transition), `traces_foyer` (maison en 12/1988 pour 3 parties types menées par `StrategieTest` cartes allumées, politiques `depenser`, `epargner`, `alterner`, graine fixe ; imprime `RUE traces politique=<p> attendu=<…> dessine=<…>`), `carte_sortie` (vraie partie cartes allumées jusqu'à la 1re carte ; images pendant l'ouverture de la porte, la carte affichée, après le rangement), étapes des pièces mises à jour.
7. **V7 Tests** (`test_rue` ou `test_pieces`) : `traces_foyer` sur des états fabriqués (chaque règle de D11, cartes éteintes = vide), humeur suivie (éteintes = neutre), cartouches (D13, aucun recouvrement).
8. Base `dev-ville.md`, compte rendu.

### 5.3 03-I2 (dev-interface, `lot/03-interface2`)
**Étape 1** (depuis `main` après 03-R) :
1. **I1 Carte de dilemme** (§4.3, docs/17 §4.1) : `Modales.carte` / `conclure_carte`, PC et téléphone, choix non payable hachuré en marches avec « Il manque … », « Disponible sans rien vendre : … » ; relecture d'une carte depuis l'historique (lecture seule : titre, choix pris, montant, conséquence) ; touches 1 / 2.
2. **I2 Bulle et picto d'humeur** : notification `type "humeur"` → `Bulle` ancrée sur `ville.point_sylvie()` (`has_method`), 4 s, pas de carte de notification empilée ; une bulle née d'une carte attend la fin de `conclure_carte` ; picto sur l'étiquette MA MAISON quand `cartes_actives()`, saut d'1 texel au changement ; pictos 16 × 16 selon D12.
3. **I3 « Mon foyer »** (docs/17 §4.4, sans la colonne des projets : place réservée, rien d'affiché) : portrait 48 × 48 de Sylvie en 3 expressions (grilles dans `data/pixel/ui/`, D12), phrase `humeur_phrase()`, dernière cause, bloc du foyer existant, 4 dernières cartes (`cartes_jouees()`), bouton vers l'historique filtré MA MAISON ; téléphone : 2 onglets ; ferme au clic extérieur, Échap, [×].
4. **I4 BANQUE fermée pendant une carte** (§4.1) : bouton BANQUE grisé avec la phrase, touche du clavier et toucher du bâtiment banque sans effet (phrase montrée) ; message `msg` d'un ordre refusé affiché s'il arrive quand même.
5. **I5 Cartes allumées (D9)** dans `principal._config()`.
6. **I6 Fiche des dividendes** : `panneau_banque.gd` passe sur `Banquier.texte_fiche_dividende(e, id)` (03-R) ; `test_interface` et `scenarios/banque.gd` comparent à cette fonction.
7. **I7 Reprises** : D14 ; m4 de 03-I (commentaire déplacé dans `test_interface`) ; m2 de 03-L (ligne `Intégrale` avec `dividendes_recus()`) ; `config/version="0.5"`.
8. **I8 Captures et tests** : `test_interface` : une passe de toute la démo **cartes allumées** (actif et passif) par la vraie interface, sans blocage, chaque carte fermée par un choix ; `test_ecran` : cartes (bornes, cibles ≥ `cible_min`, polices) ; étapes (famille `interface` ou `ecrans`) `carte` (C01 : deux choix ; C01 avec un choix non payable ; conclusion), `carte_jumeaux` (C04 double), `mon_foyer`, `etiquette_humeur` (3 états), `bulle_humeur`, `banque_fermee`, `integrale_cartes` et `integrale_cartes_saut` (partie complète cartes allumées, graine fixe : patrimoine, frais, interruptions, cartes jouées, dividendes), sur PC 1080, 1152 × 648, téléphones 1440 × 648 et 1280 × 720.

**Étape 2** (après le §6 point 4 : `main` contient 04-L et 03-V2, fusionné dans la branche par le coordinateur) : relancer tests et séries, regarder la carte dans la vraie séquence (porte, vol, conclusion, rangement) et l'ajuster si besoin, brancher `ordres_bloques()` ; base, compte rendu.

## 6. Ordre, parallélisme, fusion

1. Commit de ce plan et de `lot_03r.md` sur `main` (chef de projet, fait), push par le coordinateur, création de `lot/03-retouches` et `lot/03-ville2` (§2).
2. **En parallèle** : 03-R (dev-logique) et 03-V2 (dev-ville). 03-R : recette, fusion dans `main`, exports 0.4.1 (`lot_03r.md` §6).
3. Dès 03-R sur `main` : création de `lot/04-logique` et `lot/03-interface2` ; **en parallèle** 04-L, 03-I2 étape 1, 03-V2 (suite).
4. 04-L et 03-V2 passent chez le testeur **chacune seule** et fusionnent dans `main` dans l'ordre des OK. La recette de la **seconde** simule la fusion des deux avec `main` (copie isolée, `user://` à part : `tests.ps1 -Recette`, `capture_ville.ps1 -Serie`).
5. Quand 04-L **et** 03-V2 sont sur `main` : le coordinateur fusionne `main` dans `lot/03-interface2` (conflit attendu seulement sur `docs/lots/lot_04_recette.md` : garder l'union des sections), dev-interface fait l'étape 2. **03-I2 n'entre pas dans `main` avant 04-L** (il allume les cartes : l'invariant D1 doit être dans le moteur).
6. 03-I2 passe chez le testeur sur sa branche (= `main` + 04-L + 03-V2 + 03-I2) : c'est la fusion complète (CA-F) ; puis fusion dans `main`.
7. Après chaque fusion : `tests.ps1 -Recette` sur `main` (≥ total attendu, 0 erreur de script) ; après 03-I2 : `capture_interface.ps1 -Serie` et `capture_ville.ps1 -Serie` sur `main`. Échec d'intégration → branche `lot/04-<partie>-correctif`, jamais de correction directe sur `main`.
8. **F3** : exports 0.5 par le coordinateur, une partie réelle jouée à ×1 avec cartes (durée notée, cible ≤ 20 min avec le bouton, docs/15 §9.2), envoi au joueur.

**Points d'arrêt de dev-logique** (il s'arrête, me prévient par son compte rendu, et attend ma décision avant la recette) : CA-L5 (calibrage des projets) sous la cible ; CA-L6 (8 à 10 cartes projets allumés) non tenu ; une règle de docs/15 §3 impossible à tenir telle quelle.

## 7. Critères d'acceptation (testeur, `docs/lots/lot_04_recette.md`, une section par branche et par passage)

### 7.1 04-L : CA-L*
- **CA-L1 (tests)** : `tests.ps1 -Recette` vert, 0 erreur de script, total ≥ total de `main` après 03-R + nouvelles vérifications ; `test_interface` et `test_partie` inchangés (`git diff main...lot/04-logique -- godot/tests/test_interface.* godot/tests/test_partie.*` vide) et verts.
- **CA-L2 (invariant, D1)** : test : carte ouverte → chacun des 8 ordres débiteurs renvoie `refus "carte"` et la phrase, compte et lignes inchangés ; vente, retrait, rachat, arrêt d'un versement acceptés ; `RECETTE blocage` rejoué : `resolution_auto()` rend `choix "aucun"`, ligne d'historique, la partie va jusqu'à décembre 1988 (et par `sauter_jusqu_a` si accessible) ; `resoudre_modale("aucun")` refusé quand un choix est payable ; `ordres_bloques()` vrai seulement pendant une carte ou un projet ; témoins non concernés.
- **CA-L3 (coup dur, D2)** : 40 graines × 3 politiques, cartes allumées, projets éteints : **aucun** événement de vie qui ouvre une modale cartes éteintes ne devient une notification cartes allumées (même graine, même mois) ; ligne `MESURE carte_puis_vie=<n>` (attendu 0) ; l'exception « carte → vie » est la seule nouvelle dérogation à R-CADENCE (test) ; CA-FO1 à FO7 du lot 03 toujours verts (dont 8 à 10 cartes).
- **CA-L4 (textes, D3-D5)** : `foyer.json` contient les 32 répliques de docs/23 G1.2 (test qui en compte 32, chacune 2 à 8 mots), « Sylvie se radoucit », C10 `requiert_enfant` + `texte_jumeaux` ; aucun chiffre hors gabarits dans `texte`, `texte_jumeaux`, `pourquoi`, `replique` ; C14 « a » : conséquence « + 1 200 F sur votre compte. « Pas mon fauteuil ! » » (montant au format) ; `MESURE C00` avec fins fâchées et plus long séjour, par politique ; ligne `ALERTE` si besoin (non bloquante).
- **CA-L5 (projets, docs/15 CA-1.1 à 1.7 ; projets et cartes allumés)** : 40 graines : choix du projet 1 en 03/1984 ± 1 mois et du projet 2 en 01 ou 02/1987 dans 100 % des graines, jamais deux projets en cours ; **calibrage** (stratégie passive « tout au Livret A », politique de cartes `epargner`, `plus_cher`, graines sans jumeaux) : ligne `MESURE projets P1C_a_la_date=<x>% P2B_a_la_date=<y>%`, cible ≥ 80 % et ≥ 60 % (**point d'arrêt** sinon : je tranche, montant en données avec le banquier) ; vente automatique dans l'ordre D7, juste ce qu'il faut, frais, impôts, pénalités du moteur, jamais de solde négatif, reste au compte courant (recalcul indépendant sur 2 cas dans le test) ; un report : +4 mois ou premier mois libre, un seul, P2C sans report ; témoins : même montant, même mois à la réalisation, rien à l'abandon ; humeur +2 / +1 / −1 / −2 ; rappel à 3 mois (une notification sans pause) ; `ligne_projet_guichet()` exacte sur 2 cas et `""` sans projet ; sauvegarde au milieu d'un projet → même projet, même échéance, même report ; P2C : jour J **avant** l'écran de fin, apport compté dans le patrimoine (joueur et témoins).
- **CA-L6 (cadence, projets allumés)** : 40 graines × 3 politiques : 8 à 10 cartes (**point d'arrêt** sinon), projets ≤ 4, jamais deux interruptions le même mois ni deux mois de suite hors « marché → panne » et « carte → vie » ; S7 prend l'autre de C09 / C10 si le projet est P2A ; S10 absent si une échéance tombe en 02/1988 ; répartition imprimée.
- **CA-L7 (éteint par défaut, D6)** : configuration par défaut : aucune modale `projet`, aucune notification `projet_rappel` sur 40 graines × 2 stratégies ; références identiques à `main` après 03-R (graine 7 : 172 139,25 F / 869,97 F / 11 / 360,43 F ; captures `integrale` = `integrale_saut` = 161 419 F / 805,93 F / 11) ; tirages existants identiques ; une sauvegarde de `main` se recharge et finit.
- **CA-L8 (contrat)** : `contenu_modale()` des deux étapes de projet et `projet_en_cours()` ont exactement les champs du §4.2 (test qui les énumère) ; `git diff main...lot/04-logique -- godot/scripts/partie.gd godot/scripts/logique/` : aucune ligne `-func`, `-signal`, `-var`, `-const` d'un nom existant retirée ou renommée ; `etat_partie.gd` ne reçoit que des points d'appel et les accesseurs d'une ligne du contrat.
- **CA-L9 (périmètre)** : `git diff main...lot/04-logique --stat` : fichiers de la colonne 04-L seulement ; `export_presets.cfg` : versions 0.5.0.0 / « 0.5 » / 6, rien d'autre.

### 7.2 03-V2 : CA-V*
- **CA-V1 (tests)** : `tests.ps1 -Recette` vert, 0 erreur de script, total ≥ `main` + nouvelles vérifications ; tests de V7 présents (chaque règle de D11, cartes éteintes = aucune trace, humeur neutre cartes éteintes).
- **CA-V2 (Sylvie, V1, D12)** : `sylvie_humeurs` sur PC 1080, téléphones 1440 × 648 et 1280 × 720 : les 3 états se distinguent **sans couleur** (relus, aussi en niveaux de gris) et à ×1 (téléphone 1280 × 720) par la posture et la fenêtre ; « fâchée » = V doux d'1 px + regard de côté, ou V actuel avec la raison écrite ; changement d'état : clignement puis nouvelle image ; `hors_palette=0`, texels entiers.
- **CA-V3 (traces, D11)** : `traces_foyer` sur les 3 parties types : `RUE traces … attendu == dessine` pour chacune ; images de décembre 1988 relues (PC et téléphone 1440 × 648) : chaque trace attendue est visible et reconnaissable, aucune autre ; traces de fenêtre sur l'appui droit, rien qui cache Sylvie.
- **CA-V4 (sortie de la carte, §4.3)** : `carte_sortie` : sur la branche seule, repli `courrier` (pas de `Modales.carte`) et la partie continue après le choix ; la porte s'ouvre en 3 images et se referme ; sortie ≤ 1 s (`RUE carte sortie=<s>`), passable d'un toucher ; caméra sur la maison avant la carte.
- **CA-V5 (reports, D13)** : `pieces_*` sur PC et téléphones : `RUE flottant indice=0` (aucun cartouche sur le panneau INDICE, toutes les images), `RUE flottant chevauchements=0` (aucun recouvrement de deux cartouches), en mai d'un joueur avec Livret A et actions : un cartouche « … ce mois-ci / versés en décembre » pour les intérêts seuls et un cartouche par titre versant (étape `pieces_dividende_jeu`, ligne imprimée) ; `hors_libre=0`.
- **CA-V6 (non-régression)** : `capture_ville.ps1 -Serie` : code 0 partout, `hors_palette=0`, `irreguliers=0`, durées des séquences ± 10 %, plus longue image après préchauffage < 50 ms ; aucune nouvelle ligne de `scripts/ville/` ou `juice.gd` ne décide d'animer sur `Partie.vitesse` seule.
- **CA-V7 (périmètre)** : `git diff main...lot/03-ville2 --stat` : fichiers de la colonne 03-V2 seulement ; API existante de la ville inchangée (aucune ligne `-func` publique).

### 7.3 03-I2 : CA-I* (sur la branche finale = `main` + 04-L + 03-V2 + 03-I2)
- **CA-I1 (tests)** : `tests.ps1 -Recette` vert, 0 erreur de script, total ≥ total de `main` après 04-L et 03-V2 + nouvelles vérifications ; `test_interface` contient la passe cartes allumées (actif et passif) et elle est verte ; `test_ecran` couvre la carte.
- **CA-I2 (carte, docs/17 §4.1)** : étapes `carte`, `carte_jumeaux` sur les 4 formats : deux choix de même style, montant et picto, choix non payable hachuré avec « Il manque … F sur votre compte et votre Livret A » et sans effet au toucher (ligne `UI carte refus=ignore`), « Disponible sans rien vendre », touches 1 / 2 actives, clic extérieur et Échap sans effet ; conclusion : tampon, ligne de conséquence égale à `r["consequence"]` (ligne imprimée), 3 s, passable ; `cibles … sous_seuil=0`, `atkinson_min ≥ 20`, `chiffres_pixelify=0`, `debordements=0` ; images relues.
- **CA-I3 (humeur)** : `bulle_humeur` et `etiquette_humeur` : bulle ancrée sur `point_sylvie`, dans `rect_libre()`, 4 s, aucune carte de notification `humeur` empilée ; une bulle née d'une carte n'apparaît qu'après le rangement (ligne `UI bulle apres_carte=oui`) ; picto de l'étiquette = `humeur_visible()` sur les 3 états, absent cartes éteintes ; pictos selon D12, relus à ×1 et ×3.
- **CA-I4 (« Mon foyer »)** : `mon_foyer` PC et téléphones (2 onglets) : portrait 48 × 48 dans les 3 expressions, phrase = `humeur_phrase()`, dernière cause = `derniere_cause_humeur()`, 4 dernières cartes = `cartes_jouees()` (lignes imprimées), aucun nombre ni jauge d'humeur, bouton vers l'historique MA MAISON, fermeture au clic extérieur, Échap, [×].
- **CA-I5 (banque fermée)** : `banque_fermee` : pendant une carte, bouton BANQUE grisé avec « Réglez d'abord la carte du foyer. », touche et bâtiment sans effet ; la phrase de l'interface == `msg` du moteur (test) ; après la carte, la BANQUE se rouvre.
- **CA-I6 (cartes allumées, D9)** : `principal._config()` hors capture contient `"cartes": true` (test) ; en mode capture, absent ; une sauvegarde de la 0.4.1 reprise reste sans cartes ; `integrale` = `integrale_saut` = 161 419 F / 805,93 F / 11 (inchangés) ; `integrale_cartes` = `integrale_cartes_saut` (même patrimoine, mêmes cartes) : **nouvelle référence** imprimée (patrimoine, frais, interruptions, cartes, dividendes).
- **CA-I7 (fiche, D14, reprises)** : fiche d'une action = `Banquier.texte_fiche_dividende(e, id)` (Elf avant mai, après mai ; Peugeot 1986) ; notification de dividende : montant à droite == montant du texte ; ligne `Intégrale` avec les dividendes ; commentaire de `test_interface` à sa place ; `config/version="0.5"`.
- **CA-F (fusion)** : vraie partie cartes allumées (étape `carte_partie` ou `carte_sortie` sur cette branche) : porte qui s'ouvre, **`Modales.carte`** (plus le repli), conclusion, rangement vers la porte, porte refermée ; Sylvie change d'image en même temps que la bulle ; une trace apparaît le mois de la carte qui la crée (ex. `tele` après C02 « a ») ; BANQUE fermée par `ordres_bloques()` ; `traces_foyer` (03-V2) relancée : identique ; `capture_interface.ps1 -Serie` et `capture_ville.ps1 -Serie` code 0 ; export Windows construit, `--main-pack` : `--etape=titre` et `--etape=carte` sans ligne `ERROR`.
- **CA-I8 (périmètre)** : `git diff main...lot/03-interface2 --stat` (après la fusion du §6 point 5) : fichiers de la colonne 03-I2 seulement.

## 8. Contenu des experts : ce qui existe, ce qui manque (rien n'est bloquant)
**Disponible** : docs/15 §2-3, §7 ; docs/17 §4.1-4.4 ; docs/18 §1-3 ; docs/22 (fiche, relevé, C02, C03, C10) ; docs/23 (G1, G2, G3, picto).

**Textes provisoires à écrire par dev-logique dans `projets.json`** (marqués `_provisoire`, relus ensuite par le game designer, question G4) : carte de choix du projet 1 « Un projet pour 1986 » / « Sylvie et vous voulez vous offrir quelque chose d'ici avril 1986. Lequel ? » ; projet 2 « Un nouveau projet » / « Avec {prenoms}, la famille a d'autres envies. Lequel ? » ; jour J « Le jour J : {nom} » / « C'est le moment : {nom}, {montant}. » ; rappel (docs/15 §3.1) « Sylvie : {nom}, c'est en {mois} ! Sans rien vendre, vous avez {disponible} sur {montant}. » ; conséquences : « {nom} : c'est fait ! » / « Reporté à {mois}. » / « Projet abandonné. » ; sous-texte de P2C : phrase du PEL de docs/18 §2.1.

| # | Expert | Question | Bloquant ? |
|---|---|---|---|
| G4 | game designer | Textes des cartes de projet (choix, jour J, rappel, conséquences, répliques de Sylvie au jour J) en remplacement des provisoires ci-dessus. | non (04-I, vague 4) |
| C1 | client | « Dallas » cité dans C02 (docs/23) ; P2C : apport gardé dans le patrimoine (docs/15 §3.2, D7) ; ordre de vente automatique gardé malgré la réserve du banquier (D7). | non |
| U1 | UX | Relire les captures : carte, pictos et visage « fâchée » (D12), « Mon foyer », traces de la maison. | non (après le lot) |

## 9. Ce que j'attends du testeur
- Une section par branche et par passage dans `docs/lots/lot_04_recette.md` : commit testé, moyens, CA cochés avec preuve, anomalies classées, « non vérifié », verdict. La recette de 03-R a son propre fichier (`lot_03r_recette.md`).
- Chaque branche vérifiée **seule** depuis son worktree, sauf 03-I2 (branche = fusion complète). La seconde de 04-L / 03-V2 simule la fusion des deux avec `main`.
- Contrôles particuliers : (a) CA-L2 par sa propre boucle (ordres pendant une carte, `RECETTE blocage`) ; (b) CA-L3 en comparant cartes éteintes / allumées graine par graine ; (c) CA-L5 : vente automatique recalculée à la main sur un cas (frais, impôt, pénalité de PEL) ; (d) les 3 humeurs et les traces à l'image, en niveaux de gris, à ×1 ; (e) une partie jouée **à la main** cartes allumées (PC et téléphone simulé) jusqu'à 3 cartes au moins : rien de bloqué, banque fermée pendant la carte, rouverte après ; (f) `partie_en_cours.sav` du joueur intact, aucun Godot d'autrui fermé.
- Tests de recette du testeur touchés par ce lot : `test_recette_fiche_dividendes` (texte de la fiche, I6) et ceux qui supposent les cartes éteintes en jeu réel : à adapter par le testeur.
- Questions à me poser plutôt qu'à trancher : tout écart à D1-D15, tout CA impossible à vérifier tel qu'écrit.

## 10. Comptes rendus attendus des développeurs
Fichiers modifiés (comparés au §3), décisions prises à l'intérieur des règles, écarts d'interface (aucun attendu), non vérifié, nombre de vérifications avant / après, captures à relire en priorité, base à jour. 04-L : mesures `MESURE C00` (avec D5), `carte_puis_vie`, calibrage des projets, répartition des cartes projets allumés, références inchangées. 03-V2 : choix sur le V « fâchée » (D12), dessins des traces. 03-I2 : nouvelle référence `integrale_cartes`, portrait 48 × 48.

## 11. Validation (rempli par le chef de projet)
- [ ] 04-L : CA-L1 à L9 · [ ] 03-V2 : CA-V1 à V7 · [ ] 03-I2 : CA-I1 à I8 et CA-F · [ ] captures relues · [ ] bases à jour · [ ] partie réelle chronométrée (F3)

## Décision du joueur (2026-11-13) : ordre de vente automatique (C1, réponse partielle)
Ordre de vente automatique des projets (D7) : **compte courant d'abord, puis Livret bleu, puis le reste par ordre de rentabilité** (verbatim : « l'ordre est compte courant, puis livret bleu, puis le reste par ordre de rentabilité »). Si le Livret bleu n'existe pas encore à la date jouée, il est sauté. L'accélération du développement des features programmées est demandée : 04-L et 03-I2 étape 1 démarrent en parallèle de 03-R.
→ Règle appliquée par 04-L : **D7 bis** de `lot_05.md` §1 (le « Livret bleu » est le Livret A du jeu ; le reste du moins rentable au plus rentable ; question de confirmation au joueur, `lot_05.md` §8 Q-J1).

## 12. Version jouable (2026-11-13) : périmètre réduit de ce lot

> Décision du joueur du 13/11 et `feuille_de_route_jouable.md`. **Prime sur §0, §5, §6 et §7 ci-dessus pour 03-V2 et 03-I2.** 04-L garde tout son périmètre (c'est le moteur du jeu), avec D7 bis.

### 12.1 Ce qui change dans l'ordre et la fusion (§6)
- Plus de fusion simulée par la seconde de 04-L / 03-V2 : le coordinateur relance `tests.ps1 -Recette` sur `main` après chaque fusion (échec → correctif).
- 03-I2 n'a **plus de recette ni de fusion propres** : son étape 1 réduite (§12.3) est commitée sur `lot/03-interface2`, puis dev-interface enchaîne 04-I sur `lot/04-interface`, **empilée** sur ce commit (`lot_05.md`). L'étape 2 de 03-I2 se fait avec celle de 04-I, et la recette **R-MAISON** (`lot_05.md` §7.2) vaut pour les deux. `lot/03-interface2` entre dans `main` par la fusion de `lot/04-interface`.
- Pas d'export 0.5 à F3 : la sortie au joueur est la **0.5 « jouable »** (`feuille_de_route_jouable.md` §4.3, point 6). `config/version="0.5"` et `export_presets.cfg` 0.5 / code 6 restent écrits dans ce lot.

### 12.2 03-V2 réduit : consigne et CA de la recette courte
Consigne : `feuille_de_route_jouable.md` §3 (s'arrêter, routage générique `carte` / `projet` / `gazette`, garder ce qui est fini, le reste sur `lot/03-ville2-suite` non poussée). CA (remplacent CA-V1 à V7) :
- **CA-V1 ★** : `tests.ps1 -Recette` vert, 0 erreur de script, total ≥ `main` ; tests présents pour ce qui est gardé (si `traces_foyer` est gardée : chaque règle de D11 **pour les traces de `TRACES_DESSINEES`**, cartes éteintes = vide ; si `suivre_foyer` est gardé : cartes éteintes = neutre).
- **CA-V2 ★ (routage)** : `carte_sortie` sur la branche seule : repli `courrier`, la partie continue après le choix ; ligne `RUE fiche kind=carte appel=courrier` ; un test ou une étape montre qu'un contenu `kind "projet"` et un contenu `kind "gazette"` passent aussi par le repli (`appel=courrier`) et que la partie avance ; sortie ≤ 1 s.
- **CA-V3 ★ (non-régression)** : `capture_ville.ps1 -Serie` code 0, `hors_palette=0`, `irreguliers=0` ; si V5 est gardé : `RUE flottant indice=0`, `RUE flottant chevauchements=0` (PC et 1440 × 648).
- **CA-V4** : si V1 est gardé : `sylvie_humeurs` PC et 1440 × 648, les 3 états se distinguent (relu, sans exigence de niveaux de gris ni de ×1) ; sinon le compte rendu le dit.
- **CA-V5 ★ (périmètre)** : `git diff --stat main...lot/03-ville2` dans la colonne 03-V2 du §3 ; API existante de la ville inchangée ; `lot/03-ville2-suite` **non poussée**.

### 12.3 03-I2 étape 1 réduite (dev-interface, `lot/03-interface2`)
Garder (essentiel) : **I1** carte de dilemme **sans** vol, dépli ni aimant (apparition sur place, fondu ≤ 0,2 s si le `depart` est donné, tampon = mot « CHOISI » en encre), avec tout le reste de I1 (choix non payable grisé et hachuré si déjà fait, « Il manque … », « Disponible sans rien vendre », touches 1 / 2, ni Échap ni clic extérieur, conclusion 3 s passable, relecture) ; **I2** picto sur l'étiquette MA MAISON et bulle d'humeur (sans saut d'1 texel) ; **I3** « Mon foyer » (portrait 48 × 48 en 3 expressions déjà commencé ; **téléphone : une colonne avec défilement**, pas d'onglets ; colonne PROJET EN COURS laissée vide pour 04-I) ; **I4** BANQUE fermée ; **I5** cartes allumées (D9) ; **I6** fiche des dividendes ; **I7** reprises (D14, m4, m2, `config/version="0.5"`).
Réduire **I8** : `test_interface` passe toute la démo cartes allumées (actif et passif) sans blocage ★ ; `test_ecran` couvre la carte ; étapes `carte` (deux choix ; un choix non payable ; conclusion), `mon_foyer`, `banque_fermee`, `integrale_cartes` sur **PC 1080 et 1440 × 648 seulement**. Retirés : `carte_jumeaux`, `etiquette_humeur` relue à ×1 et ×3, `bulle_humeur` en capture (la ligne `UI bulle apres_carte=oui` reste imprimée par `carte`), `integrale_cartes_saut`, formats 1152 × 648 et 1280 × 720.
Commit, puis compte rendu court : il enchaîne 04-I (`lot_05.md`). Les CA de 03-I2 sont vérifiés dans R-MAISON (`lot_05.md` §7.2).

