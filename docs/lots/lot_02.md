# Lot 02 (parties 02-I et 02-V) : « le mois utile » visible (P4)

- Origine : docs/15 §1 (P4), docs/17 §1-3 (UX de la vague 2), `feuille_de_route.md` §1 (vague 2) et §2.5 (D-02L-1 à D-02L-5), recette `lot_02_logique_recette.md` (anomalies 1 à 3), recettes PX1-bis (M1, M3) et PX2 (m10, m11, m12), backlog T13, T17, T18. Le joueur a validé la 0.3 le 07/11 (« l'exe fonctionne bien ») et demande de continuer la feuille de route.
- Objectif (ce que le joueur verra dans la 0.4) : un bouton **COURRIER** dans la barre du temps fait filer les mois (×6) jusqu'au prochain appel, courrier ou journal ; la rue reste vivante pendant ce saut ; les notifications franchies s'empilent en forme courte et un **badge** sur HISTORIQUE compte celles qu'il n'a pas lues ; chaque mois, à ×1 et ×2, des **pièces d'or** (intérêts, coupons, dividendes) volent de la banque vers la maison et des **pièces de cuivre** (frais) de la maison vers la banque, même quand la banque est hors de l'écran (elles passent par la flèche de bord).
- Hors périmètre : toute logique (`partie.gd`, `scripts/logique/`, `data/*.json`) : le moteur du saut, le flux du mois et les non-lus sont sur `main` depuis 02-L ; les **dividendes réels** (03-L, D-02L-1 : ici la pièce « Elf : + 840 F » est seulement montrée sur un flux fabriqué par un scénario de capture) ; les sons (T6) ; les cartes, projets, voisins (lots 03 à 05) ; la sauvegarde manuelle (non lancée) ; la suppression de `shaders/ciel.gdshader` (03-V, voir §3.3).
- Mode : **parallèle**, deux branches sur des fichiers disjoints (§2), qui se rejoignent à l'exécution par deux appels `has_method` (§3). dev-logique peut tourner en même temps sur 03-L (plan séparé, fichiers logiques seulement, §2.3).
- Base : `main` **après le commit de ce plan** (contient 02-L, F1-L, PX1, PX1-bis, PX2 ; 495 vérifications vertes le 07/11).

## 0. Décisions prises par le chef de projet (questions ouvertes de docs/17 et de la recette 02-L)

| # | Question | Décision | Pourquoi |
|---|---|---|---|
| D1 | Place et libellé du bouton (docs/17 §1.1-1.2) | **Comme docs/17** : à droite des vitesses, après un filet vertical, libellé **COURRIER**, icône 16 × 16 de docs/17 §1.2 ; le bloc BAGUETTE quitte la barre haute (le prix reste dans « Mon foyer », les « = N baguettes » dans « Mon argent »). Téléphone : icône au-dessus, libellé dessous en Atkinson gras 20. Touche **N**. Info-bulle PC : « Avancer jusqu'au prochain appel, courrier ou journal (N) ». | Contrôle du temps rangé avec le temps ; seule place libre de la barre. |
| D2 | États du bouton | Caché tant qu'aucune modale n'a été résolue dans la partie (calculé : une entrée d'historique de genre `appel`, `journal` ou `courrier` existe, donc rien à sauvegarder) ; repos ; saut actif (fond ambre qui pulse 2 images à 2 im/s, chevrons qui avancent, « EN PAUSE » remplacé par **» ×6** en ambre, boutons de vitesse sans état enfoncé) ; inactif (fenêtre ou modale ouverte, séquence en cours, `Partie.saut_possible()` faux, donc décembre 1988) : icône et libellé à 40 %, aucun effet au toucher. | docs/17 §1.3. |
| D3 | Q3 : drapeau « bulle COURRIER déjà vue » | **Réglage local** (`user://preferences.cfg`, section `bulles`, clé `courrier`), pas dans la sauvegarde. Jamais lu ni écrit en mode capture ni dans les tests (option `--bulle-courrier` pour la forcer en capture). Bulle **non bloquante** : le temps continue ; elle part sur [COMPRIS] ou au premier appui sur COURRIER. | Une notion = un moment, pour le joueur et non pour la partie ; évite un champ de sauvegarde (dev-logique occupé sur 03-L). |
| D4 | Ce qui arrête le saut | Un nouvel appui (bouton ou N), une vitesse, la pause, le cycle de vitesse (téléphone) **et toute fenêtre ouverte par le joueur** (Banque, historique, menu, « Mon foyer », comparaison, détail des frais, relevé) : `Partie.arreter_saut()` avant `Partie.bloquee = true`. Après un arrêt, la vitesse est celle d'avant l'appui (déjà dans `Partie`), sauf vitesse ou pause choisies par le joueur. Le cycle de vitesse pendant un saut **arrête seulement le saut** (il ne change pas de vitesse au même toucher). | Le joueur reprend la main dès qu'il fait autre chose ; un saut figé derrière une fenêtre puis qui repart seul surprendrait. Confirme D-02L-3. |
| D5 | Badge des non-lus (docs/17 §2) | Badge = `Partie.etat.non_lues()` (définition de la logique : entrées créées pendant un saut et pas encore vues) ; pastille ambre 12 × 12 texels, chiffre Atkinson gras 22, « 9+ » au-delà de 9, absente à 0, posée sur le coin haut droit du bouton HISTORIQUE, dans les bornes de la frise. **Écart à docs/17 §2.1** : hors saut, une notification poussée par la 4e n'est pas comptée (elle est `lu = true` pour la logique). `marquer_lues()` est appelé **à la fermeture finale** de l'historique (après les relectures), puis `Partie.sauvegarder()` ; les entrées non lues portent l'étiquette **NOUVEAU** pendant toute l'ouverture et chaque filtre affiche une petite pastille avec son nombre de nouveautés (> 0 seulement). | Une seule définition (logique) ; NOUVEAU visible tant que le classeur est ouvert. |
| D6 | Notifications pendant le saut | Forme compacte d'une ligne (pastille de source + titre ≤ 40 caractères, coupé par « … »), 3 au plus ; la 4e pousse la plus ancienne, qui se réduit en une **fiche 8 × 8 texels** de la couleur de sa source et vole vers HISTORIQUE (0,4 s, arc), puis le badge saute d'1 texel (2 images, 0,12 s). Hors saut : comportement actuel. | docs/17 §2.2. |
| D7 | Q1 : retour automatique de la caméra (docs/17 §3.1) | **Oui, à l'essai** : quand le temps tourne (vitesse > 0, hors saut, hors séquence) et que le joueur n'a pas touché la rue depuis **10 s**, la caméra revient seule à la maison en 0,8 s. En pause et pendant le saut : elle reste où elle est. À montrer au joueur avec la 0.4 (réversible : une constante de `ville.gd`). | Sans lui, un joueur qui a regardé la banque ne voit plus jamais ses pièces arriver ni Sylvie. Écart assumé à `lot_px1` §3 (la position choisie reste la position de repos **en pause**). |
| D8 | Trajet et règles des pièces (docs/15 §1.1, docs/17 §3.3) | Voir §4.2 (règles complètes). Résumé : **or** = revenus du mois (`res["flux"].revenus` ≥ 10 F), de la banque vers la porte de la maison ; **cuivre** = frais (`res["flux"].frais` ≥ 10 F), de la maison vers la banque ; nombre = 1 + arrondi(log10(montant / 10)), entre 1 et 6 ; ×1 et ×2 seulement, jamais à ×3, pendant un saut ni après un saut de test (F8, `res["saut"]`) ; départ / arrivée = porte du bâtiment s'il est visible, sinon bord intérieur de sa flèche de bord ; ni maison ni banque visibles : pas de pièces, seulement le montant flottant près du compteur COMPTE. Arc 120 px virtuels, 0,9 s, pièces décalées de 0,08 s, arrivée recalculée à chaque image, positions arrondies au texel. | docs/15 et docs/17 tels quels. |
| D9 | Pièces existantes de `principal.gd` | Quand `Sequences.pieces_du_mois` existe : **plus de pièces du salaire** (l. 322-325) ni de pièces sur les notifications `interets` / `releve` / `coupon` (l. 352-353) ; les ondes de la banque restent ; les pièces des ordres (`_on_ordre`) restent. | L'or doit vouloir dire « l'argent a travaillé » (pédagogie de P4) ; le salaire en or chaque mois brouillerait le message, et le relevé de décembre compterait deux fois les intérêts. |
| D10 | Texte des intérêts versés en décembre | Si **toutes** les lignes de revenus du mois ont `verse_en_decembre` et que le mois n'est pas décembre : « + 312 F gagnés ce mois-ci (versés en décembre) » ; sinon « + 312 F ». Coupons et dividendes : un montant flottant de plus par ligne, « Elf : + 840 F » (2 au plus, décalés de 0,3 s). Cuivre : « − 45 F de frais ». | docs/15 §1.1. |

## 1. Mise en place (coordinateur)

```powershell
$git = "C:\Users\arthu\Documents\temp\JeuClaude\outils\git\cmd\git.exe"
$depot = "C:\Users\arthu\Documents\temp\JeuClaude"
& $git -C $depot pull --ff-only            # main à jour (contient ce plan)
& $git -C $depot worktree add -b lot/02-interface C:\Users\arthu\Documents\temp\JeuClaude_lots\lot02-interface main
& $git -C $depot worktree add -b lot/02-ville     C:\Users\arthu\Documents\temp\JeuClaude_lots\lot02-ville     main
```
- Les deux worktrees partent du **même** commit de `main` (celui de ce plan). Le dossier `lot02-logique` existe déjà (branche 02-L fusionnée) : ne pas le réutiliser.
- `tests.ps1`, `capture.ps1`, `capture_interface.ps1`, `capture_ville.ps1` trouvent Godot depuis un worktree (`trouver_godot.ps1`, dépôt principal). `user://` est commun : ne jamais effacer ni écrire `partie_en_cours.sav` ; ne jamais fermer un Godot qu'on n'a pas lancé.
- Avant la 1re fusion : supprimer dans le dépôt principal les `polices/*.ttf.import` non suivis s'il y en a (leçon de PX0).
- Commits locaux en français, un par tâche, sans push avant l'OK du testeur. `tests.ps1` vert avant chaque commit.

## 2. Carte de propriété des fichiers (vague 2)

Chemins relatifs à `godot/`. Les `.uid` suivent leur script. Un fichier absent du tableau est **interdit** à tous.

### 2.1 dev-interface (`lot/02-interface`)
| Fichier | Nature du changement |
|---|---|
| `scripts/principal.gd` | Vitesse effective (I1), câblage du bouton et de la touche N (I2), arrêt du saut à l'ouverture d'une fenêtre (D4), badge et `marquer_lues` (I4), appel `has_method` des pièces (I6), retrait du ciel vectoriel (I7), `capture.sav` unique (T17). Reste ≤ 600 lignes. |
| `scripts/ui/hud.gd`, `scripts/ui/bouton_temps.gd`, `scripts/ui/frise.gd` | Bouton COURRIER et ses états, » ×6, badge, notifications compactes et fiche volante, `sauter_etiquette`, fantômes du curseur, m11 |
| `scripts/ui/modale_historique.gd` (et `modales.gd` si sa façade doit passer un paramètre) | Étiquettes NOUVEAU, pastilles des filtres |
| `scripts/ui/carte_produit.gd` | m10 : textes courts ≥ 20 px |
| `scripts/ui/style.gd`, `scripts/ui/cadres_pixel.gd`, `data/pixel/ui/*.txt` | Icône `courrier` 16 × 16, pastille du badge, style ambre du saut, si besoin |
| `scripts/ui/ecran_titre.gd` | Seulement si la garde de reprise manque (elle est déjà là, l. 111-115 : **rien à faire**, à vérifier) |
| `scripts/outils/reglages.gd` | Préférence locale `bulles/courrier` (D3) |
| `scripts/outils/scenarios_capture.gd`, familles `scenarios/{titre,banque,ecrans,outils,interface}.gd`, `scripts/outils/capture.gd`, `scripts/outils/raccourcis_test.gd` | T13 (StrategieTest), nouvelles étapes (§5.1) |
| `outils/capture.ps1`, `outils/capture_interface.ps1` | T18 (`-Joueur`, liste), nouvelles étapes dans la série |
| `tests/test_interface.*`, `tests/test_partie.*`, `tests/test_ecran.gd` | Attribués à dev-interface pour ce lot |
| `scenes/principal.tscn`, `project.godot` (`[input]` si la touche N y est déclarée ; rien d'autre) | |
| `docs/connaissances/dev-interface.md` | Sa base |

### 2.2 dev-ville (`lot/02-ville`)
| Fichier | Nature du changement |
|---|---|
| `scripts/ville/sequences.gd` | `pieces_du_mois(res)` (§3.2) |
| **nouveau** `scripts/ville/pieces_mois.gd` (`class_name PiecesMois`) | Règles (statiques, testables) et animation des pièces du mois |
| `scripts/ville/ville.gd`, `scripts/ville/*.gd` | Retour automatique de la caméra (D7) ; `accessoire.gd` : B2 (déjà corrigé sur `main`, **vérifier seulement**) |
| `scripts/juice.gd` | `duree()` et pièces tiennent compte du saut ; `pieces_suivies` (§3.2) |
| `scripts/pixel/*.gd` hors `scripts/pixel/ui/` ; **suppression** de `scripts/pixel/px0.gd`, `scripts/pixel/rue_px0.gd`, `scenes/px0.tscn` ; `data/pixel/ville/`, `data/pixel/LISEZMOI.md` | Nettoyage de la vitrine PX0 (V4) ; `controler_blocs` déplacé dans l'atelier (ex. `VuePixel.controler_blocs`, statique) |
| `scripts/outils/scenarios/ville.gd` | Nouvelles étapes des pièces (§5.2), `controler_blocs` déplacé |
| `tests/test_pixel.gd`, `tests/test_rue.gd`, **nouveau** `tests/test_pieces.gd` | |
| `outils/capture_ville.ps1` ; **suppression** de `outils/capture_px0.ps1` et `Voir_PX0.bat` (racine) | M3 / m12 (montage PX0 facultatif ou retiré), nouvelles étapes |
| `docs/connaissances/dev-ville.md` | Sa base |

### 2.3 dev-logique (03-L, plan séparé) et interdits
- Si 03-L tourne en même temps : `scripts/logique/*`, `scripts/partie.gd`, `data/*.json`, `tests/test_{logique,demo,cadence,mois_utile,sauvegarde}.*`, `tests/autocontrole/`, `outils/tests.ps1`, `outils/trouver_godot.ps1`, `export_presets.cfg`, `Exporter_*.bat`, `Jouer_Godot.bat`, `docs/connaissances/{developpeur,dev-logique}.md`. **03-L ne touche ni `test_interface` ni `test_partie`** pendant cette vague ; il **ajoute** seulement au contrat de `Partie` / `EtatPartie` (rien de retiré ni renommé).
- Interdits aux deux développeurs de ce plan : tout ce qui est en 2.3, `tests/recette/` (testeur), `polices/*.ttf` et licences, `scripts/ecran.gd` (la ligne qui cite `px0.tscn` reste jusqu'en 03-I : inoffensive), `shaders/` (rien à faire ce lot), `docs/` hors sa base.
- Vérifié pour ce plan : aucun fichier n'apparaît dans deux colonnes ; `juice.gd` passe entièrement à dev-ville (PX2 n'y touche plus) ; `scenarios/ville.gd` revient à dev-ville (l'exception de PX2 §9 est close).

## 3. Interfaces (figées avant le lancement)

### 3.1 Déjà sur `main` (02-L), lecture seule
`Partie.saut_actif`, `Partie.saut_change(actif)`, `Partie.sauter_jusqu_au_prochain_arret() -> bool`, `Partie.arreter_saut()`, `Partie.saut_possible() -> bool`, `Partie.duree_mois_s()` / `facteur_trafic()` (valeurs du saut pendant le saut, quelle que soit la vitesse) ; `mois_passe(res)` avec `res["flux"] = {revenus, frais, lignes: [{id, nom, genre, montant, verse_en_decembre}]}`, `res["pendant_saut"]`, `res["saut"]` (saut de test F8 : pas d'animation) ; `notif_recue(n)` avec `n["pendant_saut"]` ; `EtatPartie.non_lues(source := "") -> int`, `marquer_lues(source := "")`, champ `lu` des entrées d'historique (absent = lu). Rappel : `notif_recue` est émis **avant** `mois_passe` pour un même mois.

**Vitesse effective** (règle pour les deux branches) : `Partie.saut_actif or Partie.vitesse > 0`. Un saut lancé depuis la pause garde `Partie.vitesse == 0`. Aucun code ne décide du gel, de l'animation ou des pièces sur `Partie.vitesse` seul.

### 3.2 Fourni par dev-ville, appelé par `principal.gd` (dev-interface) par `has_method`
```gdscript
# scripts/ville/sequences.gd
func pieces_du_mois(res: Dictionary) -> void
	# Lit res["flux"], Partie.vitesse, Partie.saut_actif, res["saut"], res["pendant_saut"].
	# Ne fait rien si : pas de flux, vitesse 0 ou 3, saut actif ou res["pendant_saut"], res["saut"], mode titre, séquence en cours.
	# Sinon : pièces d'or et de cuivre (D8, D10), montants flottants par Juice.flottant, saut de la flèche de bord
	# par hud.sauter_etiquette(id) si hud.has_method("sauter_etiquette").
	# Avec --controle : imprime « RUE pieces genre=<or|cuivre> n=<n> depart=<maison|banque|fleche_gauche|fleche_droite>
	#   arrivee=<…> montant=<texte> » ou « RUE pieces aucune raison=<vitesse3|saut|sous_seuil|hors_champ|…> ».

# scripts/ville/pieces_mois.gd
class_name PiecesMois
static func plan(flux: Dictionary, vitesse: int, en_saut: bool, ab: int) -> Dictionary
	# {"or": {"n": int, "texte": String} ou {}, "cuivre": {"n": int, "texte": String} ou {}, "lignes": [String] (≤ 2)}
	# Pur (aucun nœud) : c'est lui que test_pieces éprouve.

# scripts/juice.gd
func pieces_suivies(depart: Callable, arrivee: Callable, n: int, cuivre := false, a_chaque_arrivee := Callable()) -> void
	# depart / arrivee : Callable -> Vector2 (coordonnées d'écran logiques), relus à chaque image.
	# Crée des Piece (scripts/ui/piece.gd, inchangé) et pilote leur position ; arc de 120, 0,9 s, décalage 0,08 s.
func duree(d: float) -> float   # pendant le saut : comme ×3 (d × 0,5)
```
Côté `principal.gd` (dev-interface), dans `_on_mois` et `_on_notif` :
```gdscript
if sequences.has_method("pieces_du_mois"):
	sequences.pieces_du_mois(res)          # D9 : plus de pièces du salaire ni des notifications interets/releve/coupon
else:
	<code actuel inchangé>
```
Sur `lot/02-interface` seule, `has_method` est faux : l'ancien comportement reste. Sur `lot/02-ville` seule, `principal.gd` n'appelle rien : les pièces neuves ne se voient que par les étapes de capture de §5.2. Les deux ensemble : seulement les pièces neuves (vérifié à la fusion simulée, CA-F2).

### 3.3 Fourni par dev-interface, appelé par dev-ville par `has_method`
```gdscript
# scripts/ui/hud.gd
func sauter_etiquette(id: String) -> void   # l'étiquette ou la flèche de bord de id monte d'1 texel (3 px) puis revient : 2 images, 0,12 s
```
**Gelés pour ce lot** (dev-ville les lit, dev-interface ne les renomme pas) : `Hud.etiquettes[id]` (PanelContainer), sa méta `"fleche"` (`""`, `"gauche"`, `"droite"`), `Hud.rect_libre()`, `Hud.l_cc`, `Hud.l_patr`, `Hud.l_frais`, `Hud.compact`, `Hud.panneau`, `Hud.languette`, `Piece` (`cuivre`, nœud `Node2D`). Le bord intérieur d'une flèche = milieu de son côté tourné vers le centre de `rect_libre()`.
- Le ciel vectoriel : `principal.gd` ne crée plus le `ColorRect` ni ne charge `shaders/ciel.gdshader` ; il n'appelle plus `ville.set("ciel_mat", …)`. `ville.gd` **garde** `var ciel_mat` (lue par `test_rue`). Le fichier `shaders/ciel.gdshader` reste jusqu'en 03-V (sa suppression sur `lot/02-ville` casserait `principal.gd` de `main`).

### 3.4 Nouveaux noms
- `class_name PiecesMois` (dev-ville). Aucun autre `class_name`.
- Hud (dev-interface, internes mais lus par les tests et le testeur) : signal `courrier_demande`, `b_courrier: Button` (nom de nœud `Courrier`), `badge_non_lus: Control`, `func maj_courrier(etat: String)` (`"cache"`, `"repos"`, `"saut"`, `"inactif"`), `func maj_badge(n: int)`, `func etat_courrier() -> String`.
- Sauvegarde : **aucun changement** (format 3). Données JSON : aucune.

## 4. Tâches

### 4.1 dev-interface (`lot/02-interface`), dans cet ordre
1. **I1 Vitesse effective** (D-02L-5) : `principal._process` (l. 268-269) : `anime` et `gel` sur la vitesse effective ; `bouton_temps.gd` l. 36 (icône lecture / pause) idem ; `hud.maj_vitesse` + nouvel écouteur de `Partie.saut_change` : pendant le saut pas de « EN PAUSE », pas de cadre de gel, aucun bouton de vitesse enfoncé, » ×6 en ambre ; à la fin du saut, retour à l'affichage de `Partie.vitesse`. Cycle de vitesse (l. 301) : pendant un saut, `Partie.arreter_saut()` seulement (D4). `hud.gd` l. 876 (durée de vie des notifications) : déjà juste pendant le saut (`duree_mois_s` renvoie 1,33 → 3 s) ; garder, commenter. Commit séparé.
2. **I2 Bouton COURRIER** (D1, D2, D4) : bouton, icône (grille `data/pixel/ui/`), états, touche N (`_unhandled_input`), info-bulle ; nouvel appui = arrêt ; arrêt à l'ouverture de toute fenêtre ; retrait du bloc BAGUETTE de la barre ; replis si la barre manque de place (d'abord `l_var`, puis le libellé du bouton : icône seule 84 × 84 ; jamais le bouton). Première apparition : glissement 0,3 s et bulle unique (D3). Fantômes du curseur de la frise pendant le saut (3 curseurs à 60, 40, 20 %).
3. **I3 Notifications pendant le saut** (D6) : forme compacte, 3 au plus, fiche volante vers HISTORIQUE, saut du badge.
4. **I4 Badge et historique** (D5) : `maj_badge(e.non_lues())` après chaque `mois_passe`, à la reprise et après la fermeture de l'historique ; NOUVEAU et pastilles des filtres dans `modale_historique.gd` ; `marquer_lues()` + `sauvegarder()` à la fermeture finale.
5. **I5 `sauter_etiquette(id)`** (§3.3).
6. **I6 Appel des pièces** (§3.2, D9) dans `_on_mois` et `_on_notif`.
7. **I7 Ciel vectoriel retiré** de `principal.modales_init` (§3.3).
8. **T13** : `scenarios_capture.gd` utilise `StrategieTest` (`jouer_mois`, `aller_a`, `aller_a_modale`) ; la copie (`strategie_active`, `aller_a`, `aller_a_modale` locaux) disparaît ; les familles appellent la nouvelle forme.
9. **T17** : `principal.gd` l. 58 : `user://capture_<pid>.sav` (effacé à la sortie) ; `sauver_fermer` / `reprise` (deux processus) : `user://capture_reprise_<empreinte du chemin du projet>.sav` (unique par worktree).
10. **T18** : `capture.ps1 -Joueur` passe `--joueur` ; commentaire de `capture.ps1` à jour (étape `raccourcis`, nouvelles étapes).
11. **m10** (`carte_produit.gd` l. 100) : textes de la tuile ≥ 20 px, raccourcis plutôt que rapetissés (« 11 %/an », « ≈ 8,25 % »), badge NOUVEAU et timbre aussi ; **m11** : languette « MON / ARGENT / 82 k F » sans « F » orphelin.
12. **Étapes de capture et tests** (§5.1), base, compte rendu.

### 4.2 dev-ville (`lot/02-ville`), dans cet ordre
1. **V1 Règles des pièces** : `PiecesMois.plan` (D8, D10) et `tests/test_pieces.gd` (au moins : seuils 9,99 / 10 F ; nombre de pièces 10 F → 1, 100 → 2, 1 000 → 3, 10⁶ → 6 (plafond) ; rien à ×3, en pause, pendant le saut ; texte « versés en décembre » seulement si toutes les lignes de revenus le sont et hors décembre ; « Elf : + 840 F » pour une ligne `dividende`, nom de ligne pour un `coupon`, 2 lignes au plus ; textes en `Format` avec espaces insécables, aucune « → »).
2. **V2 Trajet** : `Sequences.pieces_du_mois(res)` et `Juice.pieces_suivies` (§3.2) ; départ / arrivée selon la visibilité (`ville.est_visible`, `ecran_batiment`, flèche de bord lue dans `hud.etiquettes`), arrivée recalculée à chaque image (la rue glissée pendant le vol), positions arrondies au texel ; « ni maison ni banque visibles » : flottant près de `hud.l_cc` seulement ; `hud.sauter_etiquette` par `has_method` à chaque pièce qui passe par une flèche.
3. **V3 Saut** : `juice.gd` l. 21 (`duree`) et toutes les pièces tiennent compte de `Partie.saut_actif` ; aucune nouvelle ligne de `scripts/ville/` ne lit `Partie.vitesse` seule pour décider d'animer.
4. **V4 Retour automatique de la caméra** (D7), avec une étape de capture qui le montre (§5.2).
5. **V5 Nettoyage de la vitrine PX0** : supprimer `scripts/pixel/px0.gd`, `scripts/pixel/rue_px0.gd`, `scenes/px0.tscn`, `outils/capture_px0.ps1`, `Voir_PX0.bat` ; `controler_blocs` déplacé (statique, même résultat) et ses 3 contrôles de `test_pixel` gardés ; contrôles de `test_pixel` qui lisent `RuePx0` repris sur la rue réelle ou retirés (dire lesquels dans le compte rendu) ; `data/pixel/LISEZMOI.md` et commentaires à jour ; `capture_ville.ps1` : plus de montage contre `px0_quater_jour_1080.png` (M3, m12).
6. **V6 `test_rue`** : cas 1440 × 648 (téléphone de référence de PX2) : `facteur=2 reduction=0.600` et Gérard ≈ 76 px à l'écran (± 1) ; base `dev-ville.md` à jour (les mesures 1600 × 720 deviennent historiques).
7. **V7 M1 (PX1-bis)** : l'arbre de premier plan n'apparaît plus d'un coup après un « Jouer » rapide (présent dès l'arrivée, ou fondu ≤ 0,3 s en images entières d'alpha de la palette, au choix du développeur, à dire).
8. **B2** : vérifier que `accessoire.gd` ne cite plus `principal.gd` (c'est le cas sur `main`) : rien à faire sinon.
9. Étapes de capture (§5.2), base, compte rendu.

## 5. Critères d'acceptation

### 5.1 dev-interface : CA-I*
- **CA-I1 (tests)** : `tests.ps1` vert, 0 erreur de script, total ≥ **495** + nouvelles vérifications ; `test_interface` couvre : bouton caché avant la 1re modale résolue puis visible ; touche N et `courrier_demande` lancent le saut (`Partie.saut_actif` vrai) ; 2e appui l'arrête ; inactif (`etat_courrier() == "inactif"`) avec une modale ouverte, avec la fenêtre Banque ouverte, en décembre 1988 ; ouverture de la Banque pendant un saut → `saut_actif` faux ; badge = `non_lues()` après un saut qui franchit au moins une notification (> 0), « 9+ » à 10, absent à 0 ; après fermeture de l'historique : `non_lues() == 0`, badge absent. `test_partie` vert.
- **CA-I2 (rue vivante pendant le saut, D-02L-5)** : étape `courrier_saut_pause` : saut lancé **depuis la pause** ; imprime `UI saut anime=oui gel=0.00 badge_pause=non vitesse=0 saut=oui` (valeurs lues sur `ville.anime`, `ville.gel`, le badge) et `RUE`/`UI` trafic ≥ 6 (facteur de la rue) ; capture : rue non teintée, voitures en mouvement (2 captures à 0,5 s d'écart).
- **CA-I3 (bouton, états)** : captures `courrier_repos`, `courrier_saut` (fond ambre, » ×6, fantômes de la frise), `courrier_inactif` (fenêtre ouverte), `courrier_bulle` (1re apparition, D3), chacune PC 1080, PC 1152 × 648 et les deux téléphones (1440 × 648 à 240 dpi, 1280 × 720 à 320 dpi). Contrôles `cibles` : bouton ≥ `cible_min` (≥ 48 dp au téléphone, ≥ 80 px virtuels à 1080p), `sous_seuil=0`, aucun `hors_cadre` / `hors_ecran` dans la barre aux 7 formats de la série ; `UI polices pixelify_min=28 atkinson_min=20`. Le bloc BAGUETTE n'est plus dans la barre ; le prix reste dans « Mon foyer » (capture `foyer`).
- **CA-I4 (arrêts)** : étape `integrale_saut` : toute la partie en appuyant sur COURRIER (par le signal du bouton) après chaque interruption, réponses par l'interface comme `integrale` ; imprime chaque arrêt `UI saut arret mois=<…> modale=<kind/id>` ; aucun arrêt sans modale ; fin de partie en décembre 1988 avec **le même patrimoine final que `integrale`** (référence actuelle : 160 749 F, frais 805,93 F, 11 interruptions) ; code 0. Vitesse rétablie : ×1 → saut → modale → ×1 et pause → saut → modale → pause, imprimé ; après le krach : pause (D-02L-2).
- **CA-I5 (notifications et badge)** : capture `notifs_saut` (3 notifications compactes ≤ 1 ligne chacune, PC et téléphone 1440 × 648, dans `rect_libre()`), `badge_non_lus` (badge lisible, dans la frise, chiffre en Atkinson), `historique_nouveau` (étiquettes NOUVEAU, pastilles des filtres) ; contrôle : `UI badge n=<k> = non_lues=<k>`.
- **CA-I6 (pièces, côté interface)** : sur la branche seule, `_on_mois` et `_on_notif` gardent l'ancien comportement (has_method faux, vérifié par l'étape `rue` : pièces du salaire présentes à ×1 comme sur `main`) ; `sauter_etiquette("banque")` existe et ramène l'étiquette à sa place (contrôle `UI sauter_etiquette retour=oui`).
- **CA-I7 (outils)** : `scenarios_capture.gd` ne contient plus de copie de stratégie (`git grep -n "func strategie_active" godot/scripts/outils` vide) ; les étapes qui avançaient le temps (`krach`, `heritage`, `f01`, `carnet_pel`, `automatique`, `historique_*`, `integrale`) donnent code 0 et des captures cohérentes (relues) ; deux `capture.ps1` lancés en même temps depuis deux worktrees n'écrivent pas le même `.sav` (noms imprimés) ; `sauver_fermer` puis `reprise` : « Continuer » reprend ; `capture.ps1 -Etape raccourcis -Joueur` : `raccourcis_test=false`.
- **CA-I8 (non-régression)** : `capture_interface.ps1 -Serie` complète, code 0 partout ; `clic_dehors` conforme ; `courrier_relu_echap` vert ; écran titre « Continuer » avec une sauvegarde sans `ab` (garde existante) ; m10 : plus aucun texte de tuile sous 20 px (contrôle étendu aux `draw_string` de `carte_produit.gd`, ligne `UI tuiles taille_min=<n>` ≥ 20) ; m11 : capture `pause_tel` sans « F » seul. `principal.gd` ≤ 600 lignes.
- **CA-I9 (périmètre)** : `git diff main...lot/02-interface --stat` : seulement des fichiers du §2.1.

### 5.2 dev-ville : CA-V*
- **CA-V1 (tests)** : `tests.ps1` vert, 0 erreur de script, total ≥ **495** − (contrôles de `test_pixel` retirés avec `RuePx0`, listés) + nouvelles vérifications ; `test_pieces` couvre tous les cas de V1 ; `test_rue` : cas 1440 × 648 (`reduction=0.600`, Gérard 76 ± 1 px), génération ≤ 2 s.
- **CA-V2 (pièces visibles)** : étapes `pieces_or` (maison et banque visibles, flux fabriqué de 312 F de revenus), `pieces_fleche` (banque hors champ à droite : les pièces sortent par la flèche « MA BANQUE › »), `pieces_cuivre` (45 F de frais, vers la banque), `pieces_dividende` (« Elf : + 840 F », flux fabriqué, D-02L-1), `pieces_glisse` (la rue glisse pendant le vol : les pièces arrivent quand même à la porte) ; chacune PC 1080 et téléphone 1440 × 648, avec une capture **pendant** le vol (pièces visibles, en texels entiers) ; lignes `RUE pieces …` conformes à D8 ; `hors_palette=0` sur la rue.
- **CA-V3 (pas de pièces)** : étapes `pieces_x3`, `pieces_saut`, `pieces_hors_champ` (Gazette au centre, maison et banque hors champ : seulement le flottant près de COMPTE), `pieces_sous_seuil` (9 F) : `RUE pieces aucune raison=…` correct, aucun nœud `Piece` créé (compté) ; `Juice.duree(1.0)` = 0,5 pendant un saut (imprimé).
- **CA-V4 (caméra)** : étape `camera_retour` : rue glissée sur la banque à ×1, 10 s sans toucher → caméra revenue sur la maison (`RUE camera retour apres=<s>` ≈ 10 s, glissement 0,8 s) ; en pause et pendant un saut : pas de retour (`RUE camera retour=non`).
- **CA-V5 (vitrine PX0 retirée)** : `git grep -n -i "px0\b\|RuePx0\|rue_px0\|capture_px0\|Voir_PX0" -- godot/scripts godot/tests godot/outils godot/scenes *.bat` ne renvoie que des **commentaires d'historique** (listés dans le compte rendu) et la ligne d'`ecran.gd` (laissée, §2.3) ; `controler_blocs` donne les mêmes résultats (3 contrôles de `test_pixel` verts) ; `capture_ville.ps1 -Serie` termine « tout est vert » sur une **copie neuve** (sans image de référence PX0).
- **CA-V6 (non-régression de la rue)** : `capture_ville.ps1 -Serie` : code 0 partout, `hors_palette=0`, `irreguliers=0`, durées des séquences inchangées (± 10 %), plus longue image après préchauffage < 50 ms ; M1 : capture `jouer` lancée à 0,3 s (étape existante ou nouvelle) sans apparition brusque de l'arbre (décrire la méthode).
- **CA-V7 (périmètre)** : `git diff main...lot/02-ville --stat` : seulement des fichiers du §2.2 (suppressions comprises) ; aucune nouvelle ligne de `scripts/ville/` ou `juice.gd` ne décide d'animer sur `Partie.vitesse` seule (relu par le testeur).

### 5.3 Fusion : CA-F* (vérifiés par le testeur sur la **seconde** branche à recevoir l'OK, fusion simulée des deux avec `main`, copie isolée, `user://` à part)
- **CA-F1** : `merge --no-ff` des deux branches sur `main` sans conflit ; `tests.ps1` vert (total ≥ somme attendue) ; `capture_interface.ps1 -Serie` et `capture_ville.ps1 -Serie` code 0 partout.
- **CA-F2 (pièces dans le vrai jeu)** : étape `pieces_jeu` (écrite par **dev-ville** dans `scenarios/ville.gd` : la vraie partie à ×1 pendant 3 mois avec un Livret A garni, sans appel direct à `pieces_du_mois` ; sur `lot/02-ville` seule elle doit seulement finir en code 0, les pièces neuves n'y apparaissent pas) : pièces d'or de la banque vers la maison au changement de mois, **plus aucune pièce du salaire** ni double pièce au relevé de décembre (D9), la flèche de bord saute quand la banque est hors champ ; à ×3 et pendant un saut : aucune pièce.
- **CA-F3** : `integrale` et `integrale_saut` : même patrimoine final (160 749 F tant que 03-L n'est pas fusionné ; sinon la nouvelle référence de 03-L, identique pour les deux).
- **CA-F4** : captures relues ensemble : `courrier_saut`, `notifs_saut`, `badge_non_lus`, `pieces_fleche`, `pieces_or`, `etiquettes_bord` (PC et téléphone 1440 × 648) : le badge, les flèches et les pièces ne se recouvrent pas mal, rien sous le panneau « Mon argent ».
- **CA-F5** : `Exporter_Windows.bat` depuis le worktree de fusion (avec `JEUCLAUDE_GODOT`) : exe lancé, `--etape=titre` puis `--etape=courrier_saut` capturés, aucune ligne d'erreur dans le journal.

## 6. Ordre, parallélisme, fusion

1. Commit de ce plan sur `main` (fait par le chef de projet), `pull` du coordinateur, puis création des **deux** worktrees (§1) le même jour.
2. dev-interface et dev-ville en **parallèle**. dev-logique peut lancer 03-L en même temps (plan séparé, à écrire ; §2.3).
3. Chaque branche passe chez le testeur **seule** (`docs/lots/lot_02_recette.md`, une section par branche et par passage). KO → retour au chef de projet → corrections sur la même branche → nouveau passage.
4. Fusion **dans l'ordre des OK**. La recette de la **seconde** branche ajoute la fusion simulée des deux (CA-F1 à F5). Si 03-L est fusionné entre-temps, la fusion simulée part du `main` d'alors.
5. Après les deux fusions : je relance `tests.ps1` et les deux séries sur `main` ; échec d'intégration → branche `lot/02-<dev>-correctif`, jamais de correction directe sur `main`.
6. Sortie **0.4 « le mois utile »** (F2) : elle part dès que 02-I et 02-V sont sur `main` (P4 complet, sauf les dividendes réels de 03-L), sans attendre 03-L. Export par dev-logique (version 0.4, code 4 ; `project.godot > config/version` par dev-interface) : mini-lot F2-L ou fin de 03-L, à décider au moment de F2.

## 7. Ce que j'attends du testeur

- Une section par branche dans `docs/lots/lot_02_recette.md` : commit testé, moyens, CA cochés avec preuve (ligne imprimée, capture nommée, commande), anomalies classées (bloquante / majeure / mineure), « non vérifié », verdict OK / KO.
- Vérifier chaque branche **seule** depuis son worktree (`tests.ps1 -Recette`, séries de captures) et relire **toutes** les captures nouvelles aux formats demandés, pas seulement les lignes de contrôle.
- Contrôles particuliers : (a) le saut lancé depuis la pause sur la vraie scène (CA-I2), à l'image ; (b) `integrale_saut` jusqu'à la fin (CA-I4) ; (c) le périmètre (`git diff --stat`) contre le §2 ; (d) sur `lot/02-ville`, la recherche de CA-V5 et une série lancée depuis une copie neuve ; (e) `partie_en_cours.sav` du joueur : empreinte avant / après, jamais touché ; (f) aucun Godot fermé qui ne soit pas à lui.
- Adapter `tests/recette/test_recette_decoupage` si l'interface du lot le casse (il touche du privé de `Modales`) ; ajouter un test de recette `tests/recette/test_recette_saut.gd` si un chemin n'est couvert par rien d'autre (saut + fenêtre ouverte + reprise).
- Questions à me poser plutôt qu'à trancher : tout écart à D1-D10, tout CA impossible à vérifier tel qu'écrit.
- Si une des deux branches est vue après la fusion de l'autre : la tester sur `main` fusionné dans une copie (sa base a changé), et le dire.

## 8. Comptes rendus attendus des développeurs
Fichiers modifiés (comparés au §2), décisions prises à l'intérieur des règles (ex. M1 : fondu ou présence), écarts d'interface (aucun attendu), non vérifié, nombre de vérifications avant / après, captures à relire en priorité, base de connaissances à jour.

## 9. Validation (rempli par le chef de projet)
- [ ] 02-I : CA-I1 à I9 · [x] 02-V : CA-V1 à V7 · [ ] fusion : CA-F1 à F5 · [ ] captures relues · [ ] bases à jour
- Décision (07/11) : **02-V validé** (recette OK passage 1, 586385e, 539 vérifications ; ses mineures m1, m2, m4, m5 vont en 03-V, §10.6) → fusion de `lot/02-ville` dans `main` tout de suite (§10.1). **02-I : KO passage 1** (A1, A2) → corrections du §10.

## 10. Corrections passage 2 (02-I, dev-interface seul) — 07/11

Origine : `lot_02_recette.md`, sections « 02-I passage 1 » et « Fusion simulée ». Le jeu fonctionne ; deux majeures (A1 test aléatoire, A2 étiquettes chevauchées) et des mineures. **dev-ville n'a rien à faire dans ce passage** (`lot/02-ville` reste telle quelle, OK et poussée).

### 10.1 Mise en place (coordinateur), dans cet ordre
1. Supprimer dans le dépôt principal les `polices/*.ttf.import` non suivis s'il y en a.
2. Fusionner `lot/02-ville` dans `main` (`merge --no-ff`), `tests.ps1` sur `main` (≥ 539 vérifications, 0 erreur de script), push de `main`. Sur `main` seule, `principal.gd` n'appelle pas encore `pieces_du_mois` : l'ancien comportement des pièces reste (attendu, §3.2).
3. Fusionner `main` dans `lot/02-interface` (dans le worktree `lot02-interface`). Conflit attendu « ajouté des deux côtés » sur `docs/lots/lot_02_recette.md` : **garder la version de `lot/02-interface`** (elle commence par la section 02-V à l'octet près). Aucun autre conflit attendu (fichiers disjoints). `tests.ps1` sur la branche : seul A1 peut être rouge.
4. Lancer dev-interface sur `lot/02-interface`. Il lit cette section dans `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot02-interface\docs\lots\lot_02.md` (arrivée par l'étape 3).
Raison de l'ordre : A2 s'appuie sur `ville.porte_ecran` (fourni par 02-V) et se règle sur la vraie rue avec les vraies pièces ; la branche devient la fusion elle-même, que le testeur vérifie d'un coup (§10.5).

### 10.2 Fichiers (dev-interface)
Ceux du §2.1, **plus `scripts/ui/modale_courrier.gd`** (C5 seulement). Toujours interdits : `scripts/ville/*`, `scripts/pixel/*` (dont `grille.gd`), `juice.gd`, `scripts/outils/scenarios/ville.gd`, `capture_ville.ps1`, `tests/test_{pieces,rue,pixel}.gd`, logique, données, `tests/recette/`, `docs/` hors sa base.

### 10.3 Décisions du chef de projet
| # | Sujet | Décision |
|---|---|---|
| E1 | Règle de visibilité d'une étiquette (m3 de 02-V) | **Alignée sur celle des pièces** : pour `maison` et `banque`, le bâtiment est « vu » (étiquette en place, sans chevron) si `ville.porte_ecran(id) != Vector2(-1, -1)` (au moins 8 px d'art de porte dans le rectangle libre, règle de 02-V **validée**) ; sinon flèche de bord. Pour `media` (sans porte) : `est_visible` comme aujourd'hui. Appel par `has_method("porte_ecran")`, repli sur `est_visible`. Ainsi : flèche affichée ⇔ les pièces passent par la flèche ; jamais de flèche à côté d'un bâtiment dont on voit la porte. |
| E2 | Chevauchements (A2) | Invariant : **aucune étiquette ni flèche n'en recouvre une autre** (rectangles agrandis de 4 px), toutes dans `rect_libre()`. Méthode conseillée : poser d'abord les flèches de bord (empilement actuel), puis les étiquettes en place ; une étiquette qui touche une flèche du même côté est poussée à côté d'elle vers le centre (à 8 px), et, faute de place, au-dessus. Masquer une étiquette est interdit. |
| E3 | Replis de la barre haute (m1), PC (`compact` faux) | Dans cet ordre, chacun seulement si la barre déborde encore : (1) « VS TOUT AU LIVRET A » → « VS LIVRET A » ; (2) « COMPTE COURANT » → « COMPTE » ; (3) variation `l_var` ; (4) libellé COURRIER (icône seule, info-bulle gardée). « EN PAUSE » / « » ×6 » ne se replie **jamais** sur PC. Objectif 1920 × 1080 et 1920 × 1009 : variation et libellé COURRIER visibles (obligatoire) ; « COMPTE COURANT » s'il tient (sinon « COMPTE », dire de combien de px il manquait). 1152 × 648 : icône seule acceptée (écart à D1 validé). |
| E4 | Replis, téléphone (`compact` vrai) | Ordre : (1) libellé COURRIER (icône seule 84 × 84 ; la bulle de 1re apparition l'explique) ; (2) seulement ensuite « EN PAUSE » / « » ×6 ». **Téléphone de référence 1440 × 648 : « EN PAUSE » en pause et « » ×6 » pendant le saut toujours visibles** (écart à D1 assumé : l'état du temps prime sur le libellé du bouton). 1280 × 720 : visibles si possible ; sinon repli permis (dire pourquoi). La largeur mini de `badge_pause` peut descendre à la plus large des deux chaînes. |
| E5 | `strategie_active` (m3 de 02-I) | Après l'étape 3 du §10.1, plus aucun appelant (`scenarios/ville.gd` de 02-V ne l'appelle plus) : dev-interface **supprime** la délégation et son commentaire. |
| E6 | Erreurs `GrillePixel` dans l'exe (m4) | Préexistantes, identiques en 0.3 ; **non bloquantes** pour la 0.4 (écart accepté à CA-F5 pour ces deux lignes seulement). Constat : `cadres.txt` commence bien par « # Cadres » (octets 35 32, sans BOM) : la cause est dans la lecture par l'exe, à chercher par le propriétaire de `scripts/pixel/grille.gd` → **03-V, dev-ville** (§10.6). Ne pas retirer les commentaires des `.txt` pour masquer l'erreur. |

### 10.4 Tâches (dev-interface), un commit par tâche, `tests.ps1` vert avant chaque commit
- **C1 (A1) `test_interface` déterministe.** `_test_courrier` ne dépend plus de la graine aléatoire de `principal._config()` : relancer la partie avec `Donnees.config_demo(GRAINE)` après l'instanciation de la scène, **et** faire franchir au saut une notification connue indépendante de la vie (ex. partir de janvier 1986 par `StrategieTest.aller_a`, saut qui franchit « Le Livret A baisse »). Ajouter une vérification de **précondition** explicite (`non_lues() > 0` avant d'ouvrir l'historique), pour que « historique fermé : non_lues() == 0 » ne puisse plus passer à vide. Les autres vérifications du test gardent leur sens.
- **C2 (A2 + E1 + E2) `Hud.placer_etiquettes`.** Règle E1, invariant E2. Ajouter `func chevauchements_etiquettes() -> int` (nombre de paires qui se recouvrent, rectangles agrandis de 4 px, + étiquettes hors `rect_libre()`), lu par les tests et les captures. Le méta `"fleche"` et `Hud.etiquettes` restent gelés (lus par `Sequences`).
- **C3 Contrôles de C2.** (a) `test_interface` : balayage de toute la rue (caméra déplacée par l'API de la ville, `aller_vers` / `position_camera` / `bornes_rue`, pas ≤ 30 px d'art), panneau ouvert, au format du test : `chevauchements_etiquettes() == 0` à chaque position ; à chaque position, pour `maison` et `banque`, flèche affichée ⇔ `porte_ecran == (-1, -1)`. (b) Nouvelle étape de capture `etiquettes_balayage` (famille `interface`, ajoutée à la série de `capture_interface.ps1`) aux formats PC 1080, PC 1152 × 648, téléphone 1440 × 648, téléphone 1280 × 720, qui imprime `UI etiquettes balayage positions=<n> chevauchements=0 hors_libre=0 incoherences=0` et capture les deux cadrages de la recette : « maison presque entière au bord gauche » (celui de `pieces_glisse`) et « banque entière au téléphone » (celui de `pieces_or_tel`).
- **C4 (m1, E3, E4) Replis de la barre.** `_replier_barre` dans l'ordre E3 / E4. Ligne de contrôle dans l'étape `cibles` (ou `courrier_*`) : `UI barre format=<…> etat=<pause|saut> pause_visible=<oui|non> libelle_courrier=<oui|non> var=<oui|non> titre_cc=<…> titre_livret=<…> replis=<liste>` aux 7 formats de la série, en pause **et** pendant un saut.
- **C5 (m2 de 02-I) Timbre « 2,20 F »** (`modale_courrier.gd` l. 215) : ≥ 20 px, en Atkinson (`Style.chiffres()`), lisible dans le timbre (agrandir le timbre si besoin) ; contrôle `UI timbre taille=<n>` ≥ 20 dans l'étape `courrier`.
- **C6 (E5)** : suppression de `strategie_active` ; `git grep -n "func strategie_active" godot/scripts/outils` vide.
- **C7 (m5) Pastille « VS LIVRET A »** : couleur et flèche suivent le **signe du chiffre affiché** (roulant), à la même image. Étape de capture `pastille_signe` (écart forcé de + 198 F à − 4 F, échantillonné à chaque image du roulement) : `UI pastille signe images=<n> incoherences=0`.
- **C8 (m6, petit)** : `notifs_saut` passe par de vraies entrées d'historique non lues, de sorte que l'incrément du badge à l'arrivée de la fiche volante se voie (capture pendant et après le vol ; `UI badge n=<k> = non_lues=<k>` avec k > 0). Le krach depuis ×1 reste couvert par `test_partie` : rien à faire pour `integrale_saut`.
- Base `dev-interface.md` et compte rendu (§8) : fichiers modifiés, total de vérifications avant / après, mesures de C4 (px manquants éventuels), captures à relire en priorité.

### 10.5 Critères d'acceptation du passage 2 (testeur, sur `lot/02-interface` qui contient désormais `main` + 02-V)
- **CA-C1 (A1)** : `tests.ps1 -SansImport -Filtre test_interface` lancé **10 fois de suite** : 10 fois vert ; la précondition `non_lues() > 0` est imprimée. `tests.ps1 -Recette` vert, 0 erreur de script, total ≥ 548 + 18 + 11 + nouvelles vérifications (548 = fusion simulée du passage 1).
- **CA-C2 (A2)** : `etiquettes_balayage` aux 4 formats : `chevauchements=0 hors_libre=0 incoherences=0` ; captures des deux cadrages relues : plus de « ‹ LA GAZETTE |AISON » ni de flèche « MA BANQUE › » à côté d'une banque dont on voit la porte. Étapes de dev-ville relancées sur la branche (`capture_ville.ps1 -Etape pieces_or`, `pieces_glisse`, `pieces_fleche`, `pieces_hors_champ`, PC 1080 et `-Telephone`) : aucune étiquette chevauchée, flèche de bord présente **seulement** quand les pièces partent ou arrivent par elle (lignes `RUE pieces … depart=/arrivee=` cohérentes avec les flèches visibles).
- **CA-C3 (m1)** : lignes `UI barre …` : 1440 × 648 `pause_visible=oui` en pause et en saut (« » ×6 » vu à l'image `l2_courrier_saut_tel`) ; 1920 × 1080 et 1920 × 1009 `var=oui libelle_courrier=oui` (et `titre_cc` dit) ; aucun `hors_cadre` / `hors_ecran` dans la barre aux 7 formats ; bouton toujours ≥ `cible_min`.
- **CA-C4 (m2)** : `UI timbre taille=` ≥ 20 ; capture `courrier` relue (PC et téléphone).
- **CA-C5 (m3)** : recherche de C6 vide ; `capture_interface.ps1 -Serie` et `capture_ville.ps1 -Serie` complètes, code 0 partout (`pieces_jeu` compris).
- **CA-C6 (m5)** : `UI pastille signe … incoherences=0`.
- **CA-C7 (m6)** : capture `notifs_saut` : badge > 0 après l'arrivée d'une fiche, ligne `UI badge` juste.
- **CA-C8 (fusion)** : CA-F1 à F4 rejoués **sur la branche** (elle contient `main` + 02-V) : `integrale` et `integrale_saut` 160 749 F, 805,93 F, 11 interruptions ; `pieces_jeu` 2, 2, 3 nœuds à ×1, 0 à ×3 et en saut. CA-F5 : exe exporté, `titre` et `courrier_saut` capturés ; seules lignes d'erreur tolérées : les deux `GrillePixel` de E6.
- **CA-C9 (périmètre)** : `git diff main...lot/02-interface --stat` (après l'étape 3 du §10.1) : fichiers du §10.2 seulement.
- Toujours : `partie_en_cours.sav` du joueur intact, aucun Godot d'autrui fermé.

Après OK : push de la branche, ma validation, fusion `--no-ff` dans `main` (sans conflit attendu : `main` y est déjà), tests et deux séries relancés sur `main`, puis sortie 0.4 (F2).

### 10.6 Reporté en 03-V (dev-ville), à écrire dans le plan 03-V
- m1 de 02-V : pièces d'or confondues avec l'enseigne ÉPICERIE (arc plus haut ou plus bas, contour sombre, éclat) ; contrôle : aucune pièce sur l'enseigne pendant le vol, PC et téléphone.
- m2 de 02-V : montants flottants longs posés sur le décor (texte de D10 plus court ou sur plaquette ; avis UX à demander avant) ; cuivre peu contrasté sur la brique.
- m4 de 02-V : saut d'une pièce quand le point de départ bascule de la porte à la flèche pendant le vol (figer le départ au lancement, ou interpoler) ; à vérifier en mouvement (suivi image par image : aucun pas > 2 fois le pas moyen).
- m5 de 02-V : image de `camera_retour` prise juste après le retour.
- E6 : erreurs `GrillePixel` des `.txt` d'interface dans l'exe (`scripts/pixel/grille.gd`) ; contrôle : journal de l'exe sans aucune ligne `ERROR`.
- Rien de cela ne bloque la 0.4.
