# Lot 03 : dividendes, reprises de la rue (03-V), finitions d'interface (03-I), moteur des dilemmes du foyer (03-foyer)

> Chef de projet, 2026-11-12. Base : `main` a2016ad (0.4 validée par le joueur, 551 vérifications vertes le 12/11, 12 étapes, 51,6 s).
> Origine : le joueur valide la 0.4 et demande la suite ; `feuille_de_route.md` §1 (vague 2 : 03-L), §2.5 (D-02L-1, D-02L-4), §2.6 (reports 03-V) ; `lot_02.md` §10.6 ; `lot_px2_recette.md` m9 ; docs/03 §7.4 (règle des dividendes), docs/01 §7.4 (impôt), docs/15 §2 (P2), docs/17 §4 (UX de la vague 3), docs/18 (prix du banquier), docs/19 (boursier).

## 0. Objectif, périmètre, découpage

**Ce que le joueur verra (0.4.1 ou 0.5)** : ses actions **versent un dividende** une fois par an (Elf, L'Oréal, Peugeot, Saint-Gobain), net de l'impôt simplifié de 16 % : pièce d'or « Elf : + 840 F » qui vole de la banque à la maison, notification de la banque (la première explique ce qu'est un dividende), ligne dans le relevé de décembre, cumul « Dividendes reçus » dans la fiche de chaque action. Les montants flottants de la rue deviennent lisibles (cartouche), les pièces ne se confondent plus avec l'enseigne, plus d'erreur dans le journal de l'exe. Le moteur des **dilemmes du foyer** (P2) est écrit mais **éteint** (aucune carte ne s'ouvre tant que l'interface de la vague 3 n'est pas là).

Quatre parties, quatre branches :

| Partie | Développeur | Branche / worktree | Contenu | Départ |
|---|---|---|---|---|
| **03-L** | dev-logique | `lot/03-logique` / `lot03-logique` | Dividendes (taux, mois, impôt, notification, relevé, flux), D-02L-4, API de lecture pour l'interface | tout de suite |
| **03-V** | dev-ville | `lot/03-ville` / `lot03-ville` | Reports de 02-V (m1, m2, m4, m5), seuil de `test_rue`, accesseur public `cx_pour`, erreurs `GrillePixel` de l'exe, retrait de `shaders/ciel.gdshader`, `point_sylvie()` | tout de suite |
| **03-I** | dev-interface | `lot/03-interface` / `lot03-interface` | Étape 1 : m9 (arrondis du relevé), ligne `notifs_saut` de sa base, ligne PX0 d'`ecran.gd`, composant `Bulle` et pictos d'humeur (préparation vague 3, non branchés). Étape 2 : `cx_pour` dans les tests et captures, « Dividendes reçus » dans la fiche | étape 1 tout de suite ; étape 2 après fusion de 03-L et 03-V (§6) |
| **03-foyer** | dev-logique | `lot/03-foyer` / `lot03-foyer` | Moteur de P2 (humeur, créneaux, 16 cartes, C00, escargots, coût d'opportunité, R-MIROIR des cartes) dans `foyer.gd`, **désactivé par défaut** ; interface figée pour la vague 3 (§5.3) | après fusion de 03-L |

Hors périmètre : la carte de dilemme à l'écran, « Mon foyer » enrichi, Sylvie câblée sur l'humeur, objets des cartes (vague 3 : plan `lot_04.md`, parties « 03-I2 / 03-V2 » ∥ 04-L) ; Peugeot 1986-1988 de docs/19 et Jean-Mi (05-L) ; sons (T6) ; sauvegarde manuelle (non lancée) ; avis UX sur le repli du téléphone 1280 × 720 et « MA MAISON » au-dessus de « ‹ LA GAZETTE » (feuille de route §2.6, pas encore demandé).

## 1. Décisions du chef de projet

| # | Sujet | Décision | Pourquoi |
|---|---|---|---|
| D1 | Règle des dividendes | **docs/03 §7.4 telle quelle** (référence produit) : versés une fois par an, au **mois de détachement** du titre (défaut **mai**, `regles.json > dividendes.mois`, surchargeable par titre `moisDiv`) ; montant brut = valeur de la ligne au cours du mois × max(0, rendement du dividende de l'année (`series.json > annuel`, 2e colonne) + `ecartDiv` du titre) / 100 ; 0 pour une année listée dans `divNul` du titre ; détenteur au mois de détachement = dividende entier ; crédité sur le compte courant ; pas d'ajustement du cours. | Règle déjà écrite, données déjà présentes (`ecartDiv` dans `periode_p1.json`, rendement annuel dans `series.json`), certitude C. Le contenu du boursier, s'il arrive, remplace les valeurs **sans code**. |
| D2 | Impôt et avoir fiscal | Taux unique **au compte-titres** `Marche.impot(a)["cto"]` (16 % de 1978 à 1991, docs/01 §7.4) prélevé au versement ; l'avoir fiscal n'est **pas modélisé à part** (il est compris dans ce taux simplifié, docs/01 §5.2) ; `w.impots` augmente. PEA inexistant dans la démo (1984-1988) : la règle « 0 % dans un PEA » est écrite mais non éprouvée. | docs/03 §7.4 renvoie à 01 §7.4. Une phrase sur l'avoir fiscal est demandée au banquier (§8), non bloquante. |
| D3 | Qui touche | Le joueur et tout portefeuille qui détient des actions en direct (le moteur le fait pour tous ; aujourd'hui seul le joueur en a). La SICAV a déjà le dividende dans sa valeur liquidative (docs/03 §7.3) : **rien de plus** pour elle. Le **jumeau sans frais** (`valeur_ombre_ligne`, `manque_a_gagner`) reçoit ses dividendes au même taux, sinon le manque à gagner serait sous-estimé (dev-logique vérifie comment l'ombre est tenue et le dit). | Cohérence de la pédagogie des frais. |
| D4 | Ce que le joueur voit | Une notification **sans pause** de la banque par mois de versement : `type "dividende"`, `cls "gain"`, `montant` = net total ; la **première** de la partie dit ce qu'est un dividende ; le détail par ligne (2 lignes au plus nommées, « et 1 autre ») ; « après 16 % d'impôt ». Une ligne `genre "dividende"` **par titre** dans le flux (montant **net**), donc les pièces d'or et « Elf : + 840 F » de 02-V deviennent réelles sans toucher à la rue. Relevé de décembre : une phrase « Vos actions vous ont versé {dividendes} de dividendes cette année, après impôt. » si > 0, et `n["dividendes"]`. Textes dans `banque.json > messages` (≤ 60 mots, testés), provisoires jusqu'à la relecture du banquier. | docs/15 §1.1, docs/04 principe 3 « une notion = un moment ». |
| D5 | Garde-fou « pas de timing récompensé » | Avec un cours sans détachement, acheter en avril et revendre en juin rapporte le dividende. **Mesuré, pas corrigé** dans ce lot : un test imprime le gain net de l'aller-retour Elf avril → juin 1987 (frais et impôt compris). La correction éventuelle (cours en « dents de scie » compensées, qui laisse les ancrages intacts) contredit docs/03 §7.4 : question au boursier (§8, B3), lot ultérieur. | Ne pas changer une règle de référence sans l'expert ; l'enjeu est faible (actions présentées au plus tôt en 03/1986, donc 2 ou 3 mois de mai). |
| D6 | Arrondis du relevé (m9, « 417 F + 42 F = 458 F ») | Le total affiché est la **somme des valeurs affichées** (chaque terme arrondi au franc par `Format.entier`, puis additionné). Côté interface (la grille est dans `modale_releve_fin.gd`). | La logique fournit des valeurs exactes ; c'est l'affichage qui doit rester juste à l'œil. |
| D7 | Montants flottants longs (m2 de 02-V) | **Cartouche** : fond `encre` ou `ardoise_sombre` (palette d'interface), contour 1 texel, marge 1 texel ; **2 lignes au plus, ≤ 20 caractères chacune** ; texte de D10 (lot 02) réécrit : ligne 1 « + 312 F ce mois-ci », ligne 2 « versés en décembre » ; coupons et dividendes « Elf : + 840 F » ; cuivre « − 45 F de frais ». Atkinson (chiffres) ≥ 20 px virtuels. Le cartouche reste dans `hud.rect_libre()`. Pas d'avis UX préalable : l'UX relira les captures ensuite. | Lisible sur la brique et les arbres, cuivre contrasté, ne recouvre plus le décor sur 650 px. |
| D8 | Saut de pièce (m4 de 02-V) | Le **point de départ est figé au lancement** de chaque pièce ; seule l'arrivée est relue à chaque image (règle de docs/17 §3.3 gardée pour l'arrivée). | Plus simple qu'une interpolation ; le saut venait du départ. |
| D9 | Seuil de durée de `test_rue` (1,3 s à vide, 2,0-2,2 s sous charge, seuil 2 s) | **Meilleure de 2 mesures** : si la 1re dépasse le seuil, une seule relance, et c'est la plus courte qui compte ; les deux sont imprimées. Seuil de 2 s inchangé. | Le contrôle reste un vrai contrôle de lenteur, sans échec aléatoire. |
| D10 | Accesseur de `ville._cx_pour` | `func cx_pour(x_monde: float) -> float` public dans `ville.gd` (même calcul) ; `_cx_pour` reste interne à la ville. `sequences.gd` passe sur `cx_pour` (03-V) ; `test_interface` et `scenarios/interface.gd` aussi (03-I étape 2). | Fin des appels privés de l'interface vers la ville. |
| D11 | P2 sans interface | Le moteur des cartes arrive sur `main` **éteint** : `data/foyer.json > actif: false` ; une partie lit `config["cartes"]` (défaut = `foyer.json > actif`) au démarrage et garde ce réglage dans sa sauvegarde (une partie commencée sans cartes n'en reçoit jamais). Les tests l'allument explicitement. L'humeur, elle, existe toujours (invisible). La vague 3 (`03-I2`) allumera le drapeau. | Sur `main`, une modale `kind "carte"` tomberait dans une interface qui ne la connaît pas. |
| D12 | Prix des cartes | **« Prix retenu » de docs/18 §1** (C02 5 500 F, C04 2 200 / 3 800 F, C07 2 500 F, C09 location 600 F ; les autres comme docs/15) ; textes de docs/15 §2.5 **avec les montants en gabarits** (`{prix_a}`, `{prix_b}`), jamais écrits en dur ; phrases « pourquoi » de docs/18 §1.2 dans les données. | Contenu du banquier disponible ; tout reste remplaçable sans code. |
| D13 | Ligne de conséquence (docs/15 §2.2) | Choix qui dépense : « Placés au Livret A au taux d'aujourd'hui ({taux} %), ces {montant} F feraient environ {vf} F fin 1988. » (taux du Livret A **du mois courant**, vf = montant × (1 + taux)^(mois restants / 12), mois restants = `m_fin − m`) ; choix à 0 F : la réplique de Sylvie si la carte en a une, sinon la phrase « pourquoi » de la carte ; cartes « placement » (C06) et « revenu » (C14) : la phrase « pourquoi ». | Les répliques manquent pour la plupart des cartes (game designer, §8), non bloquant. |
| D14 | C00 et créneaux | C00 remplace la carte d'un créneau quand Sylvie est fâchée à l'ouverture du créneau, 2 fois par partie au plus, jamais sur deux créneaux de suite, **jamais à la place de S4** (escargots, créneau fixe). Conditions liées aux projets (S7 si le projet est P2A, S10 si une échéance de projet tombe en 02/1988) : écrites dans les données, **toujours fausses** tant que les projets n'existent pas (04-L). Placement d'un créneau : mois préféré s'il passe (R-CADENCE, anticipation), sinon les mois suivants de la fenêtre ; les mois de la fenêtre **avant** le préféré ne sont pris que si le préféré est déjà connu comme bloqué (date connue à m, m − 1 ou m + 1) ; fenêtre finie → créneau abandonné (compté). Le développeur peut affiner l'algorithme s'il tient CA-FO2 et le dit. | docs/15 §2.4 laisse l'algorithme ouvert ; la mesure (8 à 10 cartes) fait foi. |

## 2. Mise en place (coordinateur)

```powershell
$git = "C:\Users\arthu\Documents\temp\JeuClaude\outils\git\cmd\git.exe"
$depot = "C:\Users\arthu\Documents\temp\JeuClaude"
$lots = "C:\Users\arthu\Documents\temp\JeuClaude_lots"
# main contient ce plan (commit du chef de projet, au-dessus de a2016ad) ; le pousser d'abord si besoin
& $git -C $depot worktree add -b lot/03-logique   "$lots\lot03-logique"   main
& $git -C $depot worktree add -b lot/03-ville     "$lots\lot03-ville"     main
& $git -C $depot worktree add -b lot/03-interface "$lots\lot03-interface" main
# plus tard, après la fusion de lot/03-logique dans main (§6) :
# & $git -C $depot worktree add -b lot/03-foyer "$lots\lot03-foyer" main
```
- Les trois premiers worktrees partent du **même** commit (celui de ce plan). Ne pas réutiliser les anciens dossiers (`lot02-*`, `px*`, `lot01-*`, `f1-logique`) : ils peuvent être supprimés (`worktree remove`) une fois leurs branches fusionnées, au choix du coordinateur.
- `tests.ps1`, `capture*.ps1` trouvent Godot depuis un worktree (`trouver_godot.ps1`). `user://` est commun : ne jamais effacer ni écrire `partie_en_cours.sav` ; ne jamais fermer un Godot qu'on n'a pas lancé.
- Avant chaque fusion : supprimer dans le dépôt principal les `polices/*.ttf.import` non suivis s'il y en a.
- Commits locaux en français, un par tâche, `tests.ps1` vert avant chaque commit, aucun push avant l'OK du testeur.

## 3. Carte de propriété des fichiers (lot 03)

Chemins relatifs à `godot/`. Les `.uid` suivent leur script. **Un fichier absent du tableau est interdit à tous.**

| Fichiers | 03-L | 03-V | 03-I | 03-foyer |
|---|---|---|---|---|
| `scripts/logique/*.gd` (dont `strategie_test.gd` ; nouveau `foyer.gd` en 03-foyer), `scripts/partie.gd` | oui | — | — | oui (après 03-L) |
| `data/*.json` (dont nouveau `data/foyer.json` en 03-foyer) | oui | — | — | oui |
| `tests/test_{logique,demo,cadence,mois_utile,sauvegarde}.*`, nouveaux `tests/test_dividendes.*` (03-L) et `tests/test_foyer.*` (03-foyer), `tests/autocontrole/`, `outils/tests.ps1`, `outils/trouver_godot.ps1` | oui | — | — | oui |
| `Exporter_*.bat`, `Jouer_Godot.bat` (aucun changement attendu) | oui | — | — | oui |
| `export_presets.cfg` (**seulement** les filtres d'inclusion, si la cause de E6 y est) | — | **oui** | — | — |
| `docs/connaissances/developpeur.md` (socle), `docs/connaissances/dev-logique.md` | oui | — | — | oui |
| `scripts/ville/*` (dont `ville.gd`, `sequences.gd`, `pieces_mois.gd`), `scripts/juice.gd`, `scripts/pixel/*.gd` hors `scripts/pixel/ui/` (dont `grille.gd`), `data/pixel/ville/`, `data/pixel/LISEZMOI.md`, `shaders/ciel.gdshader` (suppression), `scripts/outils/scenarios/ville.gd`, `tests/test_{pixel,rue,pieces}.gd`, `outils/capture_ville.ps1`, `docs/connaissances/dev-ville.md` | — | oui | — | — |
| `scripts/ui/*` (dont `modale_releve_fin.gd`, `panneau_banque.gd`, nouveau `bulle.gd`), `scripts/principal.gd`, `scripts/ecran.gd`, `scenes/`, `project.godot`, `scripts/pixel/ui/*`, `data/pixel/ui/*.txt`, `polices/**/*.import`, `shaders/papier.gdshader`, `assets/icone/`, `scripts/outils/*.gd`, familles `scenarios/{titre,banque,ecrans,outils,interface}.gd`, `outils/capture.ps1`, `outils/capture_interface.ps1`, `tests/test_{interface,partie,ecran}.*`, `docs/connaissances/dev-interface.md` | — | — | oui | — |
| `tests/recette/`, `docs/lots/lot_03_recette.md` | testeur | | | |
| `docs/` hors bases nommées ci-dessus | chef de projet / coordinateur | | | |

Règles : **03-L et 03-foyer ne touchent ni `test_interface` ni `test_partie`** et n'ajoutent au contrat de `Partie` / `EtatPartie` que des ajouts (rien de retiré ni renommé, base du chef de projet §2). dev-ville ne modifie pas `data/pixel/ui/*.txt` (ne pas retirer les commentaires pour masquer E6). Vérifié pour ce plan : aucun fichier n'apparaît dans deux colonnes d'un même moment (03-L et 03-foyer sont successifs ; 03-I étape 2 ne touche que ses fichiers après fusion de `main` dans sa branche).

## 4. Interfaces (figées avant le lancement)

### 4.1 Fournies par 03-L (lues par 03-I étape 2, 03-V par les données du flux)
```gdscript
# EtatPartie (ajouts)
func dividendes_recus(id := "") -> float     # cumul net reçu par le joueur depuis le début, pour un titre ("" = tous), euros internes
func mois_dividende(id: String) -> int       # mois de détachement du titre (1-12), 0 si ce n'est pas une action
# Flux du mois (contrat de 02-L inchangé) : une ligne {"id": "<titre>", "nom": nom_ligne(id), "genre": "dividende",
#   "montant": net, "verse_en_decembre": false} par titre ayant versé ce mois-ci.
# notif_recue(n), mois de versement : {"type": "dividende", "source": "banque", "cls": "gain", "montant": net_total,
#   "brut": float, "impot": float, "premier": bool, "lignes": [{"id", "nom", "net"}], "titre": String, "texte": String}
# Relevé de décembre (Banquier.releve) : champ "dividendes" (net de l'année) ; texte enrichi si > 0.
```
Données : `regles.json > dividendes = {"mois": 5, "_certitude": "C", "_source": "docs/03 §7.4"}` ; par titre dans `periode_p1.json` : `ecartDiv` (existant), `moisDiv` (facultatif), `divNul` (facultatif, liste d'années), `_certDiv` (A/B/C). `banque.json > messages` : `dividendes_titre`, `dividendes_premier`, `dividendes`, `releve_dividendes`.

### 4.2 Fournies par 03-V (lues par 03-I étape 2 et la vague 3)
```gdscript
# scripts/ville/ville.gd
func cx_pour(x_monde: float) -> float   # x du centre de la vue qui met x_monde au milieu du rectangle libre (= ancien _cx_pour)
func point_sylvie() -> Vector2          # point d'écran logique au-dessus de la fenêtre de Sylvie (pour une bulle), (-1, -1) hors champ
```
`Juice.flottant` garde sa signature ; le cartouche est interne à dev-ville. Rien d'autre ne change dans l'API de la ville (`lot_px1.md` §2.1-2.2, `porte_ecran`, `regler_humeur_sylvie`, `point_tete`).

### 4.3 Fournies par 03-I (pour la vague 3 ; aucun appelant dans ce lot)
```gdscript
# scripts/ui/bulle.gd
class_name Bulle extends Control
static func montrer(parent: Node, texte: String, ancre: Callable, duree := 4.0, portrait := "") -> Bulle
	# ancre : Callable -> Vector2 (écran logique), relue à chaque image ; (-1, -1) = cachée tant que l'ancre est hors champ.
	# Non bloquante (mouse_filter IGNORE), bornée à Hud.rect_libre() si un Hud est trouvé, pointe orientée vers l'ancre,
	# texte Atkinson ≥ 20 px virtuels, 2 lignes au plus ; disparaît après duree ; portrait facultatif 32 × 32 (docs/16 §3).
func fermer() -> void
# Pictos d'humeur 16 × 16 (docs/17 §4.1) : icônes "humeur_contente", "humeur_neutre", "humeur_fachee" dans data/pixel/ui/icones.txt,
# lues par la fonction existante des icônes de Style / CadresPixel (dev-interface dit laquelle dans sa base).
```
Nouveaux `class_name` du lot : **`Bulle`** (03-I), **`Foyer`** (03-foyer). Aucun autre.

### 4.4 Sauvegarde
03-L : format 3 inchangé ; nouveaux champs avec défaut (migration douce) : `banque["dividendes_annee"]` (0), drapeau « premier dividende vu » (faux), cumul par titre des dividendes reçus ({}). 03-foyer : champ d'état `foyer` (défaut : cartes éteintes, humeur 0), voir §5.3. Une sauvegarde de la 0.4 se recharge et va jusqu'à la fin (CA-L5, CA-FO6).

## 5. Tâches

### 5.1 03-L (dev-logique, `lot/03-logique`), dans cet ordre
1. **L1 Dividendes dans le moteur** (D1, D2, D3) : au mois de détachement de chaque titre détenu, ordre de docs/03 §3.3 point 5 (après salaire, dépenses et versements) ; `divNul`, `moisDiv`, plancher 0 ; impôt ; jumeau sans frais ; `noter_flux("dividende", id, net)` par titre (joueur seulement).
2. **L2 Ce que le joueur reçoit** (D4) : notification, textes provisoires dans `banque.json`, relevé de décembre (`dividendes_annee`, phrase, champ `dividendes`), `dividendes_recus`, `mois_dividende`, sauvegarde (§4.4).
3. **L3 Tests** (`tests/test_dividendes.*`, et `test_mois_utile` étendu) : voir CA-L2 à CA-L4.
4. **L4 D-02L-4** : `test_sauvegarde` : sauvegarde pendant un saut **après au moins une notification franchie** ; non-lues > 0 conservées (précondition imprimée).
5. **L5 Mesure D5** : gain net de l'aller-retour Elf avril → juin 1987 imprimé (pas de seuil).
6. **L6** Nouvelle référence de partie complète : `integrale` (stratégie et réponses de `StrategieTest` utilisées par `test_demo`) : patrimoine final, frais, nombre d'interruptions, total des dividendes nets, imprimés ; reportés dans le compte rendu et le socle.
7. Socle `developpeur.md` (dividendes, nouvelle référence), base `dev-logique.md`, compte rendu.

### 5.2 03-V (dev-ville, `lot/03-ville`), dans cet ordre
1. **V1 (m1)** : pièces d'or et de cuivre jamais sur l'enseigne ÉPICERIE ni confondues avec elle (arc plus haut ou plus bas, contour sombre, éclat : au choix, à dire).
2. **V2 (m2, D7)** : cartouche des montants flottants, textes de D7 dans `PiecesMois` (et `test_pieces` à jour).
3. **V3 (m4, D8)** : départ figé au lancement de chaque pièce.
4. **V4 (m5)** : `camera_retour` capture l'image juste après le retour (et une pendant le glissement).
5. **V5 (D9)** : `test_rue`, meilleure de 2 mesures.
6. **V6 (D10)** : `cx_pour` public, `sequences.gd` l. 164 passe dessus ; `point_sylvie()`.
7. **V7 (E6)** : erreurs `GrillePixel` dans le journal de l'exe : trouver la cause (lecture dans le paquet exporté : `FileAccess`, fin de ligne, BOM, filtre d'export…) et la corriger dans `scripts/pixel/grille.gd` (ou les filtres d'`export_presets.cfg`, seulement s'ils sont en cause) ; exporter un exe depuis le worktree (`Exporter_Windows.bat`, `JEUCLAUDE_GODOT`) pour le prouver.
8. **V8** : supprimer `shaders/ciel.gdshader` (lot 02 §3.3) ; `ville.ciel_mat` et la ligne de `test_rue` qui le liste : gardés ou retirés **ensemble** (à dire).
9. **V9 Étape `pieces_dividende_jeu`** (famille `ville`, pour la fusion) : vraie partie avec une ligne Elf achetée par `StrategieTest` avant mai 1987, avancée à ×1 jusqu'à juin 1987 ; imprime les lignes `RUE pieces …` du mois de mai. Sur `lot/03-ville` seule (pas de dividende dans le moteur), elle doit seulement finir en code 0 et imprimer `RUE pieces dividende=absent`.
10. Base `dev-ville.md`, compte rendu.

### 5.3 03-foyer (dev-logique, `lot/03-foyer`, après fusion de 03-L)
Référence : docs/15 §2 (règles), §0.1 (R-MIROIR, R-CADENCE, hasard), §8 ; prix et « pourquoi » de docs/18 §1 (D12) ; D11, D13, D14.
1. **FO1 Données** `data/foyer.json` : `actif: false` ; humeur (bornes −3 / +3, départ 0, seuils contente ≥ 2 / fâchée ≤ −2, naissance +1, érosion d'un pas vers 0 chaque 1er janvier) ; cartes C00-C15 (titre, texte à gabarits, type `conso` | `placement` | `revenu`, deux choix `a` / `b` : libellé, prix en francs, sens dépense / revenu, effet d'humeur −1 / 0 / +1 ou `"zero"` (C00), réplique facultative, variante jumeaux, effet salaire C07 + 4 % dès 01/1988), `pourquoi`, `_certitude` ; créneaux S1-S10 (fenêtre, préféré, candidates, conditions) ; C00 (2 au plus) ; escargots (délai 9 mois, 800 F rendus) ; gabarits des lignes de conséquence et des notifications d'humeur.
2. **FO2 `scripts/logique/foyer.gd`** (`class_name Foyer`, statiques sur une `EtatPartie`, comme `Cadence`) : tirage des candidates au démarrage par la graine de vie **décalée** (aucun tirage existant ne change), ouverture des créneaux dans `e.file` (`kind "carte"`), humeur, paiement (compte courant puis Livret A), choix non payable désactivé (« Il manque {x} F sur votre compte et votre Livret A »), remplacement ou abandon si aucun choix n'est payable, C00, escargots (notification persistante à + 9 mois, 800 F rendus, toujours perdus), R-MIROIR (cartes `conso` et effet salaire recopiés chez les témoins le même mois, du même montant ; `placement` non ; un témoin peut passer en négatif), historique `genre "carte"`, source `maison`. `etat_partie.gd` ne reçoit que les points d'appel (pas de logique de P2 dedans).
3. **FO3 Contrat** (§5.3 bis), sauvegarde (champ `foyer`, défaut), `Cadence` (`kind "carte"` déjà prévu : rang 6, budget `cartes` 8 à 10 dans `rythme.json`).
4. **FO4 `StrategieTest`** : politiques de choix de carte `depenser` (le choix le plus cher payable), `epargner` (le moins cher), `alterner`.
5. **FO5 Tests** `tests/test_foyer.*` (+ `test_cadence` avec cartes allumées) : CA-FO1 à FO8.
6. Socle, base, compte rendu (répartition des cartes sur 40 graines, nombre d'abandons par créneau).

#### 5.3 bis Contrat de P2 (figé pour la vague 3 ; ajouts seulement)
```gdscript
# EtatPartie
func cartes_actives() -> bool
func humeur_visible() -> int            # 0 contente, 1 neutre, 2 fâchée (même codage que ville.regler_humeur_sylvie)
func humeur_phrase() -> String          # « Sylvie est contente » | « Sylvie va bien » | « Sylvie fait la tête »
func derniere_cause_humeur() -> String  # ≤ 10 mots (« L'île de Ré, c'était parfait ! »), "" si aucune
func cartes_jouees() -> Array           # [{id, creneau, titre, choix, libelle, montant (signé, euros), humeur_effet, picto, m, ab}], ancien → récent
# contenu_modale() pour une carte :
# {"kind": "carte", "source": "maison", "date": String, "ab": int, "id": "C01", "creneau": "S1", "titre": String, "texte": String,
#  "type": "conso"|"placement"|"revenu", "disponible": float (compte + Livret A),
#  "choix": [{"id": "a"|"b", "titre": String, "montant": float (signé : −9000 dépense, +1200 revenu), "humeur": -1|0|1|"zero",
#             "picto": "contente"|"neutre"|"fachee", "desactive": bool, "manque": float, "sous": String}]}   # toujours 2 choix
# resoudre_modale("a"|"b") -> {"choix", "kind": "carte", "montant": float, "consequence": String, "humeur_avant": int, "humeur_apres": int,
#   "notifs": Array}   # notifs ajouté (§12, C-FO4) : notifications nées du choix (humeur), à émettre par l'appelant
#   (humeur_* = humeur_visible() avant / après) ; refusé sans effet si le choix est désactivé (renvoie {} ; la modale reste ouverte)
# resolution_auto() sur une carte : le choix le moins cher payable.
# notif_recue(n), changement d'état visible de l'humeur : {"type": "humeur", "source": "maison", "cls": "neutre", "humeur": int,
#   "titre": "Sylvie est ravie" | "Sylvie va mieux" | "Sylvie va bien" (neutre en redescendant de contente, §12) | "Sylvie fait la tête", "texte": String, "bulle": true}
# notif escargots : {"type": "escargots", "source": "maison", "cls": "perte", "persistant": true, "montant": 800 F en euros, "titre", "texte"}
#   (clé "persistant", celle que lit hud.gd ; "persistante" retirée, §12)
# Historique : genre "carte", source "maison" : titre, libellé du choix, montant, ligne de conséquence.
```

### 5.4 03-I (dev-interface, `lot/03-interface`)
**Étape 1** (tout de suite, depuis `main`) :
1. **I1 (m9, D6)** : `modale_releve_fin.gd` : total = somme des valeurs affichées ; vérifié aussi pour toute autre somme affichée de la même façon dans les modales (dire lesquelles).
2. **I2** : base `dev-interface.md` : la ligne « `notifs_saut` (4 notifications fabriquées : 1986 en a peu) » corrigée (vraies entrées d'historique non lues depuis C8).
3. **I3** : `ecran.gd` l. 127-129 (vitrine `px0.tscn`, supprimée en 02-V) retirée ; `capture_interface.ps1` l. 174-175 (montages contre `px0_carte_1080.png` / `v3_rue.png`) retirés ou rendus facultatifs (ne pas échouer si l'image manque).
4. **I4 `Bulle`** (§4.3) : cadre 9-patch `bulle` (16 × 16 + pointe 6 × 4, docs/16 §5) dans `data/pixel/ui/cadres.txt`, pointe vers le bas ou le haut selon la place, pictos d'humeur (docs/17 §4.1, 3 grilles) ; étape de capture `bulle` (famille `interface`) : une bulle « Sylvie est ravie » ancrée sur `ville.point_sylvie()` si la ville l'a (`has_method`), sinon sur `ville.porte_ecran("maison")` ; une bulle ancrée hors champ (cachée) ; les 3 pictos agrandis ; tests dans `test_ecran` (bornes, pointe, disparition après `duree`, ancre hors champ).
**Étape 2** (après le §6 point 3 : `main` contient 03-L et 03-V, fusionné dans la branche par le coordinateur) :
5. **I5 (D10)** : `test_interface` l. 172 et `scenarios/interface.gd` l. 197 passent sur `ville.cx_pour` ; `git grep -n "_cx_pour" godot/tests godot/scripts/outils godot/scripts/ui godot/scripts/principal.gd` vide.
6. **I6 Dividendes dans la fiche** : dans la fenêtre Banque, fiche d'une action détenue : ligne « Dividendes reçus : 1 240 F » (Atkinson, `Format.entier`) si `dividendes_recus(id) > 0`, sinon « Dividende versé chaque année en {mois} » (`mois_dividende`) ; rien pour les autres produits. Aucun rendement prévisionnel affiché.
7. Étapes de capture et tests (§7.3), base, compte rendu.

## 6. Ordre, parallélisme, fusion

1. Commit de ce plan sur `main` (chef de projet, fait), push par le coordinateur, création des **trois** worktrees (§2) le même jour.
2. **En parallèle** : 03-L, 03-V, 03-I étape 1. Aucune dépendance entre eux (fichiers disjoints ; 03-I étape 1 n'appelle `point_sylvie` que par `has_method`).
3. **03-L** et **03-V** passent chez le testeur **chacune seule**, fusionnent dans `main` dans l'ordre des OK. La recette de la **seconde** des deux simule la fusion des deux avec `main` (CA-F1 à F3 ci-dessous).
4. Dès que 03-L est sur `main` : création de `lot/03-foyer` depuis `main` (§2) et lancement de dev-logique sur 03-foyer.
5. Quand 03-L **et** 03-V sont sur `main` : le coordinateur fusionne `main` dans `lot/03-interface` (conflits attendus : aucun, sauf éventuellement `docs/lots/lot_03_recette.md` ajouté des deux côtés : garder l'union des sections) et lance dev-interface sur l'étape 2. Si dev-interface a fini l'étape 1 avant : il attend (ou l'étape 1 passe chez le testeur seule, au choix du coordinateur ; elle sera revue sur la branche finale).
6. 03-I passe chez le testeur sur sa branche (= `main` + 03-L + 03-V + 03-I) : c'est la fusion complète, vérifiée d'un coup ; puis fusion dans `main`.
7. 03-foyer : recette seule (aucune interface touchée), fusion simulée avec le `main` du moment ; fusion dans `main` quand OK, avant ou après 03-I.
8. Après chaque fusion : `tests.ps1` sur `main` (≥ total attendu, 0 erreur de script) ; après 03-I : `capture_interface.ps1 -Serie` et `capture_ville.ps1 -Serie` sur `main`. Échec d'intégration → branche `lot/03-<partie>-correctif`, jamais de correction directe sur `main`.
9. Sortie joueur : une **0.4.1 « les dividendes »** est possible dès que 03-L, 03-V et 03-I sont sur `main`. Elle n'est pas dans ce plan : si le coordinateur et le joueur la veulent, mini-lot d'export (comme F1-L : version 0.4.1 / code 5 par dev-logique, `config/version` par dev-interface, l'un après l'autre). Sinon, la prochaine sortie est la 0.5 « le foyer » (vague 3).

## 7. Critères d'acceptation (testeur, `docs/lots/lot_03_recette.md`, une section par branche et par passage)

### 7.1 03-L : CA-L*
- **CA-L1 (tests)** : `tests.ps1` vert, 0 erreur de script, total ≥ **551** + nouvelles vérifications ; `test_interface` et `test_partie` **inchangés** (`git diff main...lot/03-logique -- godot/tests/test_interface.* godot/tests/test_partie.*` vide) et verts.
- **CA-L2 (règle, D1-D2)** : `test_dividendes` : pour Elf, L'Oréal, Peugeot en mai 1987 et Saint-Gobain en mai 1987 (disponible 11/1986), net = valeur de la ligne × (rendement 1987 + écart) × 0,84, au centime près, recalculé par le test **depuis les données** ; aucun versement un autre mois ; titre vendu en avril → rien en mai ; année `divNul` (fabriquée par le test) → 0 ; `moisDiv` surchargé (fabriqué) → versement au bon mois ; SICAV : aucun versement en plus ; impôt ajouté à `impots` ; compte courant crédité du net.
- **CA-L3 (flux et pièces, docs/15 CA-4.3)** : `test_mois_utile` étendu : sur 60 mois et 3 graines avec une stratégie qui détient des actions, `revenus` égal au franc près aux mouvements (dividendes nets compris) ; une ligne `genre "dividende"` par titre versant, `nom` = nom court (« Elf »), `verse_en_decembre` faux.
- **CA-L4 (ce que voit le joueur, D4)** : une seule notification `dividende` par mois de versement, sans pause (aucune modale ouverte par elle, `Cadence` inchangée) ; la 1re de la partie a `premier = true` et le texte « premier » ; relevé de décembre 1987 : `n["dividendes"]` = somme des nets de l'année, phrase présente, absente une année sans dividende ; textes ≤ 60 mots (test existant des messages), aucun « → », espaces insécables de `Format` ; `dividendes_recus("elf")` = cumul ; `mois_dividende("elf")` = `moisDiv` d'Elf dans les données (5 par défaut), `mois_dividende("livret") == 0`.
- **CA-L5 (sauvegarde)** : sauvegarde avant mai, reprise, versement identique ; une sauvegarde **sans** les nouveaux champs (retirés par le test) se recharge et va jusqu'à la fin ; D-02L-4 : sauvegarde pendant un saut après au moins une notification franchie, `non_lues() > 0` conservé (précondition imprimée, la ligne n'affiche plus « 0 non lue(s) »).
- **CA-L6 (mesures)** : ligne `DIVIDENDES aller_retour elf 1987-04 1987-06 gain_net=<x> F` (D5) ; nouvelle référence `integrale` imprimée (patrimoine, frais, interruptions, dividendes nets) ; `test_cadence` vert, nombre d'interruptions par graine **identique** à `main` (les dividendes n'interrompent pas).
- **CA-L7 (contrat)** : `git diff main...lot/03-logique -- godot/scripts/partie.gd godot/scripts/logique/` : aucune ligne `-func`, `-signal`, `-var`, `-const` d'un nom de la base du chef de projet §2 retirée ou renommée.
- **CA-L8 (périmètre)** : `git diff main...lot/03-logique --stat` : fichiers de la colonne 03-L seulement.

### 7.2 03-V : CA-V*
- **CA-V1 (tests)** : `tests.ps1` vert, 0 erreur de script, total ≥ 551 + nouvelles vérifications ; `test_pieces` à jour des textes de D7 (2 lignes ≤ 20 caractères, « + 312 F ce mois-ci » / « versés en décembre », « Elf : + 840 F », « − 45 F de frais ») ; `test_rue` : la ligne de durée imprime les deux mesures quand il y a relance (D9) ; `test_rue` lancé 5 fois de suite **sous charge** (un autre `tests.ps1` en même temps) : 5 fois vert.
- **CA-V2 (m1, m2)** : `capture_ville.ps1` étapes `pieces_or`, `pieces_fleche`, `pieces_cuivre`, `pieces_dividende`, PC 1080 et téléphone 1440 × 648, capture **pendant** le vol et **à l'arrivée** : aucune pièce sur l'enseigne ÉPICERIE (contrôle imprimé `RUE pieces enseigne=0` : aucune position de pièce dans le rectangle de l'enseigne, sur toutes les images du vol) ; cartouches lisibles (relus), dans `rect_libre()` (`RUE flottant hors_libre=0`), cuivre lisible sur la brique ; `hors_palette=0`.
- **CA-V3 (m4, D8)** : nouvelle étape `pieces_bascule` : la rue glisse pendant le vol de sorte que la banque passe de visible à hors champ ; suivi image par image imprimé : `RUE pieces pas_max=<x> pas_moyen=<y>` avec `pas_max ≤ 2 × pas_moyen` pour chaque pièce.
- **CA-V4 (m5)** : `camera_retour` : une image pendant le glissement, une juste après (`RUE camera retour apres=<s>` ≈ 10 s, image relue : la maison au centre).
- **CA-V5 (D10)** : `ville.cx_pour(x)` == ancien calcul (test dans `test_rue` sur 3 valeurs) ; `git grep -n "call(\"_cx_pour\"" godot/scripts/ville` vide ; `point_sylvie()` : dans l'écran quand la maison est visible (au-dessus de la fenêtre de Sylvie, ± 8 px d'art), `(-1, -1)` quand elle est hors champ (test).
- **CA-V6 (E6)** : exe exporté depuis le worktree : `--etape=titre` et `--etape=rue` : journal **sans aucune ligne `ERROR`** ni `GrillePixel` ; cause écrite dans le compte rendu et la base ; les `.txt` d'interface inchangés.
- **CA-V7 (nettoyage)** : `shaders/ciel.gdshader` absent ; `git grep -n "ciel.gdshader" godot` vide hors commentaires d'historique ; `test_rue` cohérent avec le choix sur `ciel_mat`.
- **CA-V8 (non-régression)** : `capture_ville.ps1 -Serie` : code 0 partout, `hors_palette=0`, `irreguliers=0`, durées des séquences ± 10 %, plus longue image après préchauffage < 50 ms ; `pieces_dividende_jeu` code 0 avec `RUE pieces dividende=absent` (branche seule).
- **CA-V9 (périmètre)** : `git diff main...lot/03-ville --stat` : fichiers de la colonne 03-V seulement ; aucune nouvelle ligne de `scripts/ville/` ou `juice.gd` ne décide d'animer sur `Partie.vitesse` seule.

### 7.3 03-I : CA-I* (sur la branche finale = `main` + 03-L + 03-V + 03-I)
- **CA-I1 (tests)** : `tests.ps1 -Recette` vert, 0 erreur de script, total ≥ (total de `main` après 03-L et 03-V) + nouvelles vérifications ; `test_ecran` couvre `Bulle` (bornes dans `rect_libre()`, pointe vers l'ancre, cachée si l'ancre vaut (-1, -1), disparue après `duree`, `mouse_filter` IGNORE).
- **CA-I2 (m9, D6)** : étape `releve` (famille `banque`) avec des frais et un manque à gagner dont les arrondis tombent mal (fabriqués : 416,6 + 41,6, vrai total 458,2) : ligne imprimée `UI releve frais=417 manque=42 total=459` (somme des affichés, et non 458) ; capture relue PC et téléphone.
- **CA-I3 (nettoyage)** : `git grep -n "px0" godot/scripts/ecran.gd` vide ; `capture_interface.ps1 -Serie` code 0 sur une copie neuve (sans `px0_carte_1080.png` ni `v3_rue.png`) ; base de dev-interface corrigée (ligne `notifs_saut`).
- **CA-I4 (Bulle, pictos)** : étape `bulle` PC 1080, PC 1152 × 648, téléphones 1440 × 648 et 1280 × 720 : bulle lisible, pointe vers la fenêtre de Sylvie (`point_sylvie` présent sur la branche finale), texte ≥ 20 px (`UI polices atkinson_min=20`), dans `rect_libre()` ; pictos d'humeur nets (texels entiers), lisibles sans couleur (relus).
- **CA-I5 (D10)** : recherche de I5 vide ; `test_interface` (balayage des étiquettes) et `etiquettes_balayage` verts avec `cx_pour`.
- **CA-I6 (dividendes à l'écran)** : étape `fiche_dividendes` (famille `banque`) : partie menée par `StrategieTest` avec Elf achetée avant mai 1987, avancée à juin 1987, fenêtre Banque ouverte sur la fiche d'Elf : « Dividendes reçus : … F » = `Format.entier(dividendes_recus("elf"))` (ligne `UI fiche dividendes=<texte> = logique=<texte>`) ; même fiche avant mai : « Dividende versé chaque année en mai » ; PC et téléphone 1440 × 648, cibles et polices conformes (`cibles`, `sous_seuil=0`).
- **CA-I7 (fusion, ex-CA-F)** : `integrale` et `integrale_saut` donnent **le même** patrimoine final, égal à la nouvelle référence de 03-L (CA-L6) ; `pieces_dividende_jeu` (dev-ville) sur cette branche : pièce d'or et cartouche « Elf : + … F » en mai 1987 (`RUE pieces … ` avec la ligne Elf), notification « Dividendes » visible, aucune pièce à ×3 ni pendant un saut ; `pieces_jeu` inchangé ; captures relues ensemble : `pieces_dividende_jeu`, `notifs_saut`, `releve` (PC et téléphone 1440 × 648).
- **CA-I8 (export)** : `Exporter_Windows.bat` depuis le worktree : exe lancé, `--etape=titre` et `--etape=courrier_saut` capturés, **aucune ligne `ERROR`** dans le journal (E6 réglé par 03-V).
- **CA-I9 (périmètre)** : `git diff main...lot/03-interface --stat` (après la fusion du §6 point 5) : fichiers de la colonne 03-I seulement.

### 7.4 03-foyer : CA-FO*
- **CA-FO1 (éteint par défaut, D11)** : avec la configuration par défaut, aucune modale `kind "carte"` sur 40 graines × 2 stratégies ; `integrale` donne **exactement** la référence de 03-L (patrimoine, frais, interruptions) ; `test_interface`, `test_partie` verts et inchangés.
- **CA-FO2 (docs/15 CA-2.1)** : cartes allumées, 40 graines × 3 politiques (`depenser`, `epargner`, `alterner`) : **8 à 10 cartes** par partie (C00 comprise) ; jamais deux interruptions avec pause le même mois ni deux mois de suite (hors krach → panne) ; jamais de carte au mois qui précède une interruption datée ; dates imposées inchangées ; classiques ≤ 15 ; répartition imprimée (cartes par graine, abandons par créneau).
- **CA-FO3 (CA-2.2)** : `epargner` rend Sylvie fâchée au moins une fois et déclenche C00 (≤ 2, jamais deux créneaux de suite, jamais en S4) dans 100 % des graines ; `depenser` : le compte courant + Livret A du joueur ne passe jamais sous 0 à cause d'une carte (un choix non payable est `desactive` et `resoudre_modale` le refuse).
- **CA-FO4 (CA-2.3, R-MIROIR)** : après chaque carte `conso`, les témoins ont dépensé le même montant le même mois (au centime) ; après C06, non ; C07 choisie : salaire + 4 % dès 01/1988 pour le joueur **et** les témoins.
- **CA-FO5 (CA-2.4, CA-2.5)** : C06 prêtée → notification `escargots` à + 9 mois, 800 F rendus, 100 % des graines ; ligne de conséquence recalculée au franc près par le test (taux du Livret A du mois, mois restants) ; aucun texte de `foyer.json` ne contient « auriez dû », « devriez », « conseil », « il faut », ni de montant écrit en dur dans un texte de carte (gabarits seulement) ; textes de carte ≤ 30 mots, titres ≤ 5 mots.
- **CA-FO6 (CA-2.6, CA-2.7, sauvegarde)** : sur 10 graines, au moins 2 cartes différentes entre deux graines ; carte ouverte → sauvegarde → reprise : la même carte se rouvre, un seul paiement ; une sauvegarde de la 0.4 (sans champ `foyer`) se recharge, cartes éteintes, va jusqu'à la fin ; tirages existants (naissance, événements de vie) **identiques** à `main` pour 40 graines (cartes allumées ou non).
- **CA-FO7 (contrat, §5.3 bis)** : `contenu_modale()` d'une carte contient exactement les champs du contrat (test qui les énumère) ; `humeur_visible()` suit les seuils ; notification `humeur` seulement quand l'état visible change ; historique `genre "carte"`, source `maison`.
- **CA-FO8 (périmètre et contrat)** : comme CA-L7 et CA-L8 pour `lot/03-foyer` ; `etat_partie.gd` ne grossit que des points d'appel (diff relu : pas de règle de P2 dedans).

## 8. Contenu des experts : ce qui existe, ce qui manque (rien n'est bloquant)

**Disponible** : règle complète des dividendes (docs/03 §7.4, docs/01 §7.4 : mai, rendement de marché + écart par titre, 16 % au compte-titres) ; données : `series.json > annuel` (rendement 1984-1988 : 4,4 / 3,4 / 2,6 / 3,6 / 3,0 %, certitude C), `periode_p1.json` (`ecartDiv` : Elf + 1,5, L'Oréal − 1,5, Peugeot 0, Saint-Gobain 0 ; Saint-Gobain disponible en 11/1986), `regles.json > impots` ; prix des 16 cartes et phrases « pourquoi » (docs/18 §1) ; textes et règles de P2 (docs/15 §2) ; UX de la vague 3 (docs/17 §4). **docs/18 et docs/19 ne disent rien des dividendes ni de l'avoir fiscal.**

À demander par le coordinateur (souhaité **avant la recette de 03-L**, intégrable sans code ; s'il n'arrive pas, 03-L part avec les valeurs C ci-dessus) :

| # | Expert | Question | Bloquant ? |
|---|---|---|---|
| B1 | boursier | Mois de détachement (ou de paiement) des dividendes de **1986 à 1988** d'Elf Aquitaine, L'Oréal, Peugeot SA, Saint-Gobain (1er dividende versé aux actionnaires de la privatisation de 11/1986 : 1987 ?), certitude A/B/C. | non (défaut mai, docs/03) |
| B2 | boursier | Rendement du dividende de chaque titre en 1986, 1987, 1988, ou validation du modèle « rendement de marché + écart » ; **Peugeot a-t-il versé un dividende en 1984-1986** (pertes de 1980-1985) ? (→ `divNul`). | non |
| B3 | boursier (puis client si changement de règle) | Garde-fou anti-timing (D5) : faut-il faire baisser le cours au détachement (« dents de scie » compensées, ancrages intacts), contre docs/03 §7.4 « pas d'ajustement » ? Chiffre à l'appui : la ligne `DIVIDENDES aller_retour` de 03-L. | non (lot ultérieur) |
| K1 | banquier | Confirmer pour 1986-1988 le taux simplifié unique de 16 % sur les dividendes au compte-titres, et une phrase ≤ 25 mots sur l'**avoir fiscal** (crédit d'impôt de 50 % du dividende, 1965-2004) à placer dans la notification du 1er dividende ou dans le relevé ; certitude. | non |
| K2 | banquier | Relire les 4 textes provisoires de `banque.json` (titre, 1er dividende, dividendes suivants, phrase du relevé) une fois 03-L écrit (≤ 60 mots, sans conseil). | non |
| G1 | game designer | Pour 03-foyer : répliques de Sylvie par choix (aujourd'hui 2 sur 32), textes des bulles d'humeur, lignes des choix « placement » / « revenu », textes des cartes adaptés aux prix du banquier (C02, C04, C07, C09). | non (D13 donne un repli) |

## 9. Ce que j'attends du testeur
- Une section par branche et par passage dans `docs/lots/lot_03_recette.md` : commit testé, moyens, CA cochés avec preuve (ligne imprimée, capture nommée, commande), anomalies classées, « non vérifié », verdict.
- Chaque branche vérifiée **seule** depuis son worktree (`tests.ps1 -Recette`, séries), sauf 03-I (branche = fusion complète). La seconde de 03-L / 03-V simule la fusion des deux avec `main` (copie isolée, `user://` à part) : `tests.ps1`, `integrale` (nouvelle référence), `capture_ville.ps1 -Etape pieces_dividende_jeu` (pièce Elf réelle en mai 1987).
- Contrôles particuliers : (a) CA-L2 recalculé à la main sur une ligne (Elf, mai 1987) ; (b) `test_rue` sous charge (CA-V1) ; (c) journal de l'exe sans `ERROR` (CA-V6, CA-I8) ; (d) les cartouches et l'enseigne à l'image, PC et téléphone ; (e) 03-foyer : CA-FO1 avant tout (rien ne doit changer pour le joueur), puis la répartition des cartes ; (f) `partie_en_cours.sav` du joueur intact, aucun Godot d'autrui fermé.
- Questions à me poser plutôt qu'à trancher : tout écart à D1-D14, tout CA impossible à vérifier tel qu'écrit.

## 10. Comptes rendus attendus des développeurs
Fichiers modifiés (comparés au §3), décisions prises à l'intérieur des règles (V1 : méthode contre l'enseigne ; V7 : cause de E6 ; V8 : `ciel_mat` ; FO2 : algorithme des créneaux), écarts d'interface (aucun attendu), non vérifié, nombre de vérifications avant / après, captures à relire en priorité, base de connaissances à jour. 03-L : nouvelle référence `integrale` et ligne D5. 03-foyer : répartition des cartes.

## 11. Validation (rempli par le chef de projet)
- [x] 03-L : CA-L1 à L8 · [x] 03-V : CA-V1 à V9 (passage 2) · [x] 03-I : CA-I1 à I9 (CA-I5 reformulé : `test_rue.gd` exclu) · [x] 03-foyer : CA-FO1 à FO8 · [x] captures relues (testeur) · [x] bases à jour
- **VALIDÉ le 2026-11-12** par le chef de projet. Fusion : `lot/03-interface` puis `lot/03-foyer`. Décisions et reports : `feuille_de_route.md` §2.8 (mini-lot 03-R avant l'export 0.4.1, invariant « une carte ouverte se ferme toujours » en 04-L).

## 12. Corrections 03-foyer (2026-11-12, après le 1er compte rendu de dev-logique)

**Constat** : CA-FO3 à 25 graines `epargner` sur 40 (C00 déclenchée), au lieu de 100 %. Cause : l'usure du 1er janvier (1 pas vers 0, docs/15 §2.1) et le +1 de la naissance effacent la bouderie de 12/1984 avant le créneau suivant ; avec usure nulle : 40/40.

**D15 (décision, arbitrage game design à confirmer par le game designer, question G2)** : **l'usure du 1er janvier ne s'applique qu'à une humeur positive** (« le bonheur s'use, la rancune attend une réconciliation »). Une humeur négative ne remonte que par un choix +1, la naissance, un projet réalisé (vague 3) ou le week-end de Deauville (C00, humeur → 0).
- Pourquoi : C00 est la **seule** conséquence en argent de l'humeur (docs/15 §2.1) et la leçon de la fourmi (fin n° 4 « blindée mais seule », docs/15 §6) : si l'épargnant intégral y échappe une fois sur trois, la mécanique est invisible pour le joueur qui en a le plus besoin. Le joueur garde la main (chaque carte montre l'effet d'humeur avant le choix, choix à +1 toujours possible), et un moral bas n'est jamais une fin de partie.
- Rejeté : (b) rendre des choix plus « fâchants » = réécrire le contenu de docs/15 §2.5 (rôle du game designer, effet de bord sur toutes les politiques) ; (c) assouplir CA-FO3 = accepter qu'un tiers des fourmis ne voient jamais C00, contraire à docs/15 CA-2.2.
- Réglage en données, sans valeur en dur : `foyer.json > humeur` : `"erosion"` remplacé par `"erosion_positive": 1, "erosion_negative": 0`. Si le game designer préfère une usure symétrique lente (ex. négatif tous les 2 ans), c'est un changement de données et de test, pas de code.
- **CA-FO3 inchangé (100 % des graines, 40/40)**, et désormais **vérifié** (plus seulement imprimé).

**Choix de dev-logique validés** :
- C-FO1 : algorithme des créneaux (affinement de D14, autorisé) : validé tant que CA-FO2 tient ; décrit dans sa base.
- C-FO2 : C14 (type `revenu`) recopiée chez les témoins : conforme à R-MIROIR (docs/15 : conso **et** revenu recopiés, seul le placement C06 ne l'est pas). CA-FO4 couvre aussi C14 (même rentrée, même mois).
- C-FO3 : titre « Sylvie va bien » (neutre en redescendant de contente) : validé, contrat §5.3 mis à jour ; à relire par le game designer (G1).
- C-FO4 : `notifs` ajouté au retour de `resoudre_modale` : validé (ajout, rien de retiré), contrat §5.3 mis à jour ; la vague 3 (03-I2) émet ces notifications.
- C-FO5 : clé de persistance : **une seule clé, `persistant`** (celle de `hud.gd` et de `banquier.gd`) ; `persistante` retirée du code et du contrat (§5.3 corrigé).

**Corrections demandées à dev-logique (`lot/03-foyer`)** :
1. `godot/data/foyer.json > humeur` : `"erosion": 1` → `"erosion_positive": 1, "erosion_negative": 0` (+ une clé `_erosion` d'une ligne citant D15).
2. `godot/scripts/logique/foyer.gd > debut_mois` : pas = `erosion_positive` si h > 0, `erosion_negative` si h < 0 (même formule vers 0) ; commentaire de la fonction à jour.
3. `foyer.gd` (notif escargots) : retirer `"persistante": true`, garder `"persistant": true` ; tests qui lisent `persistante` à adapter.
4. `godot/tests/test_foyer.gd` : CA-FO3 **vérifié** : 40/40 graines `epargner` avec au moins un état fâché et au moins une C00 (règles de C00 toujours vérifiées) ; ligne `MESURE C00` gardée et étendue aux 3 politiques (`depenser`, `epargner`, `alterner` : graines avec C00, nombre total) ; test unitaire de l'usure : +3 → +2 et −2 → −2 au 1er janvier.
5. CA-FO1, FO2 et FO6 relancés (l'humeur n'a aucun effet en argent cartes éteintes ; C00 remplace sans ajouter) ; `tests.ps1` vert ; base de dev-logique (mesures C00 par politique) ; un commit « 03-foyer : usure de l'humeur sur le positif seulement (D15), clé persistant ».

**Question au game designer (G2, non bloquante)** : confirmer D15 (usure asymétrique) ou donner une autre règle d'usure ; répartition de C00 sur `alterner` à l'appui (ligne `MESURE C00`).
