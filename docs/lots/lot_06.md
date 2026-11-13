# Lot 06 (vague 5, version jouable) : la rue et le krach à l'écran (05-I), recette finale et sortie 0.5 « jouable »

> Chef de projet, 2026-11-13. Cadre : `feuille_de_route_jouable.md`. Le moteur de ce lot (P3 + P9 + P6) est **05-L** (`lot_05.md` §5.2-5.3, contrat §4.3 figé). Ce plan couvre l'interface (05-I, qui regroupe les anciens 05-I et 06-I) et la sortie.
> Entrées : docs/15 §4-6 ; docs/17 §4.5 ; docs/19 §3-4 ; docs/10 du 29/10 (**classement affiché en permanence**) ; maquettes UX U4 si elles arrivent (`lot_05.md` §8), sinon défauts ci-dessous.

## 0. Objectif, découpage

**Ce que le joueur verra (0.5 « jouable »)** : la pastille « RUE 2e / 4 » en permanence dans la barre haute ; dans « Mon argent », le bloc « La rue » (vous, Tata Livret, Tonton Matelas, Jean-Mi) ; les voisins et la Gazette qui parlent en notifications (onglet LA RUE dans l'historique, relecture longue de « La rue » et du levier de Jean-Mi) ; dans la modale du krach, le tableau des jours du 16 au 26 octobre 1987 ; en octobre 1988, la carte « Le krach, un an après » à 3 barres ; à la fin, 4 barres et le rang.

| Partie | Développeur | Branche / worktree | Départ |
|---|---|---|---|
| **05-I** | dev-interface | `lot/05-interface` / `lot05-interface`, depuis `main` après la fusion de `lot/04-interface` (R-MAISON) | étape 1 tout de suite sur le contrat `lot_05.md` §4.3 (contenus fabriqués) ; étape 2 quand 05-L est sur `main` |
| — | dev-logique | correctifs de 05-L si besoin (branche `lot/05-logique-correctif`) | — |
| — | dev-ville | réserve (le routage `gazette` est livré par 03-V2) | — |

Hors périmètre : séquence du Lundi noir, bulles des voisins dans la rue, Porsche, kiosque défilant, portraits dessinés, titres P5 et record, sauvegarde manuelle (`feuille_de_route_jouable.md` §6).

## 1. Décisions (défauts tant que l'UX n'a pas répondu à U4)

| # | Sujet | Décision |
|---|---|---|
| E1 | Classement permanent | Pastille « RUE 2e / 4 » (Pixelify pour le mot, Atkinson pour le chiffre) **à côté** de la pastille « vs tout au Livret A », même hauteur ; un toucher ouvre « Mon argent » ; absente rue éteinte. Au téléphone, si la place manque : « 2e / 4 » seul avec le pictogramme de plaque de rue (≥ `cible_min`). Elle saute d'1 texel à une notification `rang` (seule animation permise). |
| E2 | Bloc « La rue » dans « Mon argent » | 4 lignes de `classement_rue()` : initiale dans une pastille de couleur, nom, patrimoine (`Format.entier`, rouge avec le signe si négatif), rang ; ligne « vous » en gras ; Tata soulignée « référence » ; phrase existante « Même salaire, mêmes dépenses… » gardée. |
| E3 | Notifications `voisin`, `rang`, `kiosque` | Carte de notification existante ; source `rue` : liseré **sarcelle** (docs/17 §4.5) et libellé « LA RUE » ; titre = nom du voisin ; `kiosque` = source média existante. Un toucher ouvre la relecture (lecture seule) ; `long: true` → relecture en carte de lecture (texte entier, ≤ 60 mots, bouton FERMER). |
| E4 | Historique | Onglet / filtre **LA RUE** (source `rue`) à côté de MA MAISON, BANQUE, MÉDIA ; relecture des genres `voisin` et `gazette`. |
| E5 | Krach | Dans la modale du krach existante, si `c["jours"]` existe : tableau « Indice de Paris, environ » de 7 lignes (jour, valeur arrondie à 5 points, variation au dixième, rouge si baisse), au-dessus des 3 choix, sans rien retirer ; au téléphone, 2 colonnes compactes ou défilement, choix toujours visibles sans défiler. |
| E6 | « Le krach, un an après » | `Modales.gazette(c, depart)` / `conclure_gazette(r, arrivee)` : fiche papier liseré média, titre, 3 barres horizontales (`barres.gd` réutilisé si possible) avec titre et valeur, barre `choisi` **entourée** et marquée « votre choix », `mention` en italique si non vide, texte ≤ 50 mots, bouton J'AI COMPRIS (touche 1 / Entrée) ; ni Échap ni clic extérieur. Aucune autre phrase ajoutée par l'interface. |
| E7 | Écran de fin | Si `bilan["rue"]` non vide : 4 barres (vous, Tata, Tonton, Jean-Mi) à la place des barres « Vous et Tata Livret » (barre de Tata soulignée référence), rang « 2e de la rue sur 4 », `replique_rue` ; le reste de l'écran inchangé ; PC et téléphone sans défilement si possible, sinon défilement. |
| E8 | Allumage | `principal._config()` hors capture : `"rue": true` (avec cartes et projets). En capture : absent, sauf étapes qui le demandent. |

## 2. Mise en place (coordinateur)
```powershell
& $git -C $depot worktree add -b lot/05-interface "$lots\lot05-interface" main   # après la fusion de lot/04-interface
# étape 2 : quand lot/05-logique est fusionné dans main :
& $git -C "$lots\lot05-interface" merge --no-ff main -m "Fusion de main (05-L) dans lot/05-interface"
```
Mêmes règles que `lot_05.md` §2.

## 3. Carte de propriété des fichiers (lot 06)
| Fichiers | 05-I (dev-interface) | correctif 05-L (dev-logique, si besoin) |
|---|---|---|
| `scripts/ui/*` (dont `hud.gd`, `modales.gd`, `modale_journal.gd`, `modale_historique.gd`, `modale_releve_fin.gd`, nouveau `modale_gazette.gd`), `scripts/principal.gd`, `scripts/ecran.gd`, `scenes/`, `project.godot`, `scripts/pixel/ui/*`, `data/pixel/ui/*`, `polices/**/*.import`, `assets/icone/`, `scripts/outils/*.gd`, familles `scenarios/{titre,banque,ecrans,outils,interface}.gd`, `outils/capture*.ps1` sauf `capture_ville.ps1`, `tests/test_{interface,partie,ecran}.*`, `docs/connaissances/dev-interface.md` | oui | — |
| `scripts/logique/*`, `scripts/partie.gd`, `data/*.json`, tests logiques, `outils/tests.ps1`, `export_presets.cfg`, `Exporter_*.bat` | — | oui |
| `scripts/ville/*`, `juice.gd`, `shaders/`, `scenarios/ville.gd`, tests de la rue | — (interdit) | — |
| `tests/recette/`, `docs/lots/lot_06_recette.md` | testeur | |

## 4. Interfaces
Consommées : `lot_05.md` §4.3 (05-L) et §4.1 (routage `gazette` de 03-V2). Fournies : `Modales.gazette(c: Dictionary, depart: Vector2) -> void`, `Modales.conclure_gazette(r: Dictionary, arrivee: Vector2) -> void` (coroutine). Aucun nouveau `class_name` obligatoire (si `modale_gazette.gd` en a un : `ModaleGazette`, à déclarer dans le compte rendu). Sur la branche avant l'étape 2, les écrans sont alimentés par des contenus fabriqués conformes au contrat, et tout appel au moteur nouveau passe par `has_method`.

## 5. Tâches (05-I)
**Étape 1** (contrat, contenus fabriqués) : R1 pastille permanente (E1) ; R2 bloc « La rue » (E2) ; R3 notifications et relecture longue (E3) ; R4 onglet LA RUE (E4) ; R5 tableau du krach (E5) ; R6 `Modales.gazette` (E6) ; R7 écran de fin (E7) ; R8 allumage (E8) ; étapes de capture `rue_pastille`, `rue_bloc`, `rue_notifs` (voisin court, voisin long, rang, kiosque), `historique_rue`, `krach_jours`, `un_an_apres` (choix vendu, rien, renforcé, exemple), `fin_rue`.
**Étape 2** (après la fusion de 05-L dans `main` puis de `main` dans la branche) : vrai moteur, passe de `test_interface` sur toute la démo **tout allumé** (cartes, projets, rue ; actif et passif), étape `integrale_jouable` (graine fixe), captures sur les 2 formats ; base, compte rendu.

## 6. Ordre et sortie 0.5 « jouable »
1. 05-I étape 1 dès la fusion de `lot/04-interface` ; étape 2 dès que 05-L est sur `main`.
2. **R-RUE** = recette finale sur `lot/05-interface` (= `main` + 05-I = tout le jeu jouable).
3. Fusion dans `main` ; le coordinateur relance `tests.ps1 -Recette`, `capture_interface.ps1 -Serie`, `capture_ville.ps1 -Serie`.
4. Exports 0.5 (exe et APK ; version déjà 0.5 / code 6) ; vérification du paquet par `--main-pack` ; exe lancé par le joueur (Smart App Control).
5. **Partie réelle chronométrée** par le coordinateur, tout allumé, avec le bouton COURRIER (durée, nombre d'interruptions et de notifications notés) ; si > 25 min : je propose au joueur, **après** son verdict, le retrait de créneaux (docs/15 §2.4) plutôt que de retarder la sortie.
6. Envoi au joueur (message du coordinateur) : nouvelle partie obligatoire ; ce qui n'est pas animé l'est volontairement ; trois questions : « On s'amuse plus ? Qu'est-ce qui manque ou ennuie ? Qu'est-ce qu'on peaufine d'abord ? ».

## 7. Critères d'acceptation R-RUE (testeur, `docs/lots/lot_06_recette.md`) — ★ = obligatoire
- **CA-U1 ★** : `tests.ps1 -Recette` vert, 0 erreur de script ; `test_interface` passe toute la démo **tout allumé** (actif et passif) sans blocage, chaque carte, projet, krach et « un an après » fermés.
- **CA-U2 ★ (classement permanent)** : `rue_pastille` PC et 1440 × 648 : pastille visible pendant toute la partie (hors fenêtres plein écran), rang == `rang_rue()` (imprimé), un toucher ouvre « Mon argent » ; absente rue éteinte ; `cibles … sous_seuil=0`.
- **CA-U3 ★ (bloc)** : `rue_bloc` : 4 lignes == `classement_rue()` (ordre, noms, montants au format, rang, imprimés) ; montant négatif en rouge avec le signe ; `debordements=0`.
- **CA-U4 ★ (notifications)** : `rue_notifs` : source `rue` reconnaissable sans couleur (libellé) ; relecture longue de V01 et V13 complète (texte imprimé == contenu) ; onglet LA RUE ne montre que la source `rue` ; badge des non-lus juste après un saut qui franchit une notification de voisin.
- **CA-U5 ★ (krach)** : `krach_jours` : 7 lignes == `c["jours"]` (arrondies à 5 points, imprimées) ; les 3 choix visibles sans défilement sur les 2 formats ; modale inchangée sans `jours`.
- **CA-U6 ★ (« un an après »)** : `un_an_apres` en 4 cas : 3 barres, valeurs == `c["barres"]` (imprimées), barre choisie entourée (aucune dans l'exemple, `mention` affichée) ; Échap sans effet ; vraie partie : `RUE fiche kind=gazette appel=modales`.
- **CA-U7 ★ (fin)** : `fin_rue` : 4 barres == `bilan["rue"]`, rang, réplique == `replique_rue` ; rue éteinte : écran de fin identique à `main`.
- **CA-U8 ★ (allumage)** : `_config()` hors capture : `cartes`, `projets`, `rue` vrais (test) ; en capture absents ; `integrale` = `integrale_saut` = références de `main` ; nouvelle référence `integrale_jouable` imprimée (patrimoine, frais, interruptions, notifications de la rue, rang final).
- **CA-U9 ★ (à la main)** : une partie **complète** jouée sur PC tout allumé (bouton COURRIER permis) : aucun blocage, durée notée ; téléphone simulé 1440 × 648 de 09/1987 à 11/1987 (krach, panne, notifications) : rien de caché ni d'inaccessible.
- **CA-U10 ★ (export)** : `Exporter_Windows.bat` réussi depuis le worktree ; `--main-pack` : `--etape=titre` et `--etape=un_an_apres` sans ligne `ERROR`.
- **CA-U11 ★ (périmètre)** : `git diff --stat main...lot/05-interface` dans la colonne 05-I du §3 ; aucun fichier de `scripts/ville/` ni de `scripts/logique/`.

## 8. Contenus des experts
U4 (UX, souhaité avant l'étape 1), G5 et B4 : textes exacts dans `lot_05.md` §8. Rien de bloquant : défauts E1-E8.

## 9. Validation (rempli par le chef de projet)
- [ ] R-RUE : CA-U1 à U11 · [ ] captures relues · [ ] partie chronométrée · [ ] exports 0.5 · [ ] bases à jour
