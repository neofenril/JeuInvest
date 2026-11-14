# Lot SV : sauvegarde à la demande et proposition de sauvegarde avant les grandes décisions

> Chef de projet, 2026-11-06. **Statut : planifié, NON LANCÉ** (décision du joueur : « note les éléments de cette fonctionnalité pour plus tard, à ne pas lancer tout de suite »). Place : **avant la version finale 1.0**, vagues 6 et 7 (`feuille_de_route.md` §10). À relancer seulement sur demande du coordinateur ; avant le lancement : recopier les noms de fichiers issus de T9 (§5.2), vérifier les `kind` réels des cartes, projets et « un an après » (§4.3), obtenir la maquette UX (§6).
> Origine : docs/10, 06/11 (verbatim) : « prévoir l'ajout d'une fonctionalité de sauvegarde avant la version finale. Permettre au joueur de sauvegarder la partie quand il le souhaite, et lui proposer automatiquement avant chaque décision importante ».
> Réponses du joueur (06/11, verbatim dans docs/10) : « 3 emplacements possibles. l'utilisateur choisis quel emplacement écraser lors d'une nouvelle sauvegarde. je valide les décisions importantes. Je confirme une recharge de sauvegarde annule la prise en compte de la partie courante dans le record. »
> Existant (`main` ae19d02) : un seul fichier `user://partie_en_cours.sav` (format 3, migration douce par `EtatPartie.defauts_etat`), écrit à chaque mois, après chaque choix et ordre, à la fermeture ; « Continuer » sur l'écran titre ; la modale en attente est rouverte à la reprise ; le marché est déterministe et tout le hasard vient de `graine_vie` (sauvegardée dans `config`).

> **Mise à jour du 2026-11-13 (audit de préparation)** : `kind` réels relevés dans le code (05-L) : carte `carte` (C06 = `id`), projet `projet` (étapes `choix` / `echeance` dans `c["etape"]`), krach `marche` (id `p1e6`), héritage `D08`, « un an après » `gazette`. `rythme.json > sauvegarde.toujours` devient `["marche", "D08", "projet", "C06"]` (sans `gazette` : game designer, docs/28 §6 ; arbitrages au §10). Le compteur `retours` et `bilan["record_possible"]` sont **créés par 07-L** (défaut 0 / vrai, `lot_07.md`) : SV-L ne fait plus que l'incrémenter ; 07 ne dépend donc plus de SV. Reste avant lancement : feu vert du joueur, maquette UX (U6 de `audit_preparation.md`), relecture des seuils (G6 point 6).

## 1. Design validé

| Sujet | Décision |
|---|---|
| Emplacements | **3 emplacements** choisis par le joueur (décision du joueur). La sauvegarde automatique technique (`partie_en_cours.sav`, « Continuer ») est gardée telle quelle : ce n'est pas un emplacement, elle protège contre une fermeture ou une coupure. Les emplacements sont partagés entre les parties : une nouvelle partie n'efface que l'automatique. |
| Contenu affiché d'un emplacement | prénom, date de jeu (« mars 1986 »), patrimoine, date réelle d'écriture, et le libellé de la décision si la sauvegarde vient d'une proposition (« Avant : le krach d'octobre 1987 »). |
| Écrasement | **À chaque sauvegarde, le joueur choisit l'emplacement** (décision du joueur), y compris pour une sauvegarde proposée avant une décision. Un emplacement plein demande confirmation (« Remplacer mars 1986 ? »). Aucun écrasement automatique. |
| Sauvegarder quand il veut | Menu (bouton MENU existant) : **SAUVEGARDER** → écran des 3 emplacements. Possible à tout moment, y compris pendant une modale en attente (la reprise la rouvre, mécanisme existant). Le saut est d'abord arrêté ; impossible après la fin. |
| Reprendre | Écran titre : CONTINUER (inchangé) + **CHARGER** (si au moins un emplacement plein) + NOUVELLE PARTIE. En jeu : menu **CHARGER**, avec confirmation (« La partie en cours sera remplacée ; sauvegardez-la d'abord si vous voulez la garder »). Après un chargement, l'automatique suit la partie chargée. |
| Proposition avant une décision | **Non bloquante** : bandeau « Sauvegarder avant de choisir » dans la carte ou la feuille. Un toucher ouvre l'écran des 3 emplacements (choix, confirmation si plein), puis retour à la carte, bandeau devenu « Sauvegardé ». Le joueur peut aussi choisir directement sans toucher le bandeau. Pas de question modale (≈ 30 décisions à choix par partie avec P1 et P2 : contraire à R-CADENCE). Le joueur n'a pas répondu à ce point : défaut retenu. |
| « Décision importante » (**liste validée par le joueur**, calculée dans la logique) | **Toujours** : choix au krach (modale `marche`), héritage (D08, 60 000 F), choix de projet et échéance de projet (P1). **Avec seuil** : carte de dilemme dont l'enjeu ≥ 1 mois de salaire, et toujours les escargots (C06) ; ordre de bourse ou retrait (achat, vente, rachat d'assurance-vie, clôture du PEL, retrait du Livret A) ≥ 20 % du patrimoine du joueur et ≥ 5 000 F. **Jamais** : présentations du banquier, événements de vie sans choix, notifications, versements automatiques, petits ordres. |
| Fréquence | « Toujours » : bandeau à chaque fois (≤ 6 par partie). « Avec seuil » : au plus une proposition **tous les 6 mois de jeu**. Attendu : 4 à 10 propositions par partie (mesuré par test). |
| Désactivation | Menu > **« Proposer de sauvegarder avant les grandes décisions : oui / non »** (oui par défaut), retenu d'une partie à l'autre (`user://options.cfg`). La sauvegarde du menu reste toujours disponible. |
| Hasard | Figé par la graine : recharger puis refaire le même choix redonne exactement la même suite (escargots compris). Dit une fois dans l'écran de chargement : « Le hasard ne change pas : seuls vos choix peuvent changer. » |

## 2. Record, classement et R-MIROIR

- **R-MIROIR n'est pas touché** : les voisins-témoins sont dans l'état sauvegardé ; une partie rechargée les retrouve au même point. Le classement de la rue reste juste à l'intérieur d'une partie.
- Risque traité : sauvegarder avant le krach (ou les escargots), essayer, recharger, garder le meilleur choix et battre le record (07-L, `user://records.sav`).
- **Règle validée par le joueur** : « une recharge de sauvegarde annule la prise en compte de la partie courante dans le record ». L'état porte un compteur `retours` (chargements d'un emplacement dans cette partie ; « Continuer » ne compte pas). Si `retours > 0`, la partie est **« rejouée »** : l'écran de fin montre le rang et le titre avec la ligne « Partie rejouée depuis une sauvegarde : hors record », et **le record n'est pas mis à jour**. Le compteur suit la partie dans toutes ses sauvegardes.
- Collection des titres (docs/10, 29/10) : le joueur n'a pas tranché ; **défaut : le titre d'une partie rejouée entre dans la collection** (rejouer un choix est pédagogique, cf. « Le krach, un an après »). À confirmer par le client au moment de 07-L.
- Limite assumée : copier un fichier de `user://` à la main reste possible (jeu solo, sans classement en ligne).

## 3. Mode, place, dépendances

- Deux branches **séquentielles**, pas de dev-ville : **SV-L** (dev-logique) puis **SV-I** (dev-interface).
- **SV-L** : **vague 6, avant 07-L** (≈ 1 jour). Dépend de 03-L, 04-L, 05-L et 06-L sur `main` : toutes les décisions de la liste existent (cartes, C06, projets, krach, « un an après »), les seuils se testent sur les vrais contenus. 07-L consomme `bilan["record_possible"]` dès sa création.
- **SV-I** : **vague 7, avant 07-I** (branche créée depuis `main` après la fusion de 06-I et de SV-L). Pose le bandeau dans la base commune des modales (issue de T9) : cartes, projets, krach, héritage l'ont sans travail de plus. 07-I affiche la ligne « hors record » dans le nouvel écran de fin.
- Sortie joueur : **1.0** (F7). Pré-requis : PX2 fusionné (T9), 03 à 06 fusionnés, maquette UX (§6). Aucune autre branche ne dépend de SV avant la vague 6.

## 4. Interfaces (à figer au lancement ; ajouts seulement)

### 4.1 `Sauvegarde` (dev-logique)
```gdscript
const DOSSIER_EMPLACEMENTS := "user://emplacements/"
const EMPLACEMENTS := ["emplacement_1", "emplacement_2", "emplacement_3"]
static func chemin_emplacement(nom: String) -> String           # DOSSIER_EMPLACEMENTS + nom + ".sav"
static func lister() -> Array[Dictionary]                         # toujours 3 éléments, dans l'ordre :
#   {"nom": String, "vide": bool, "resume": {"prenom", "ab", "date", "patrimoine"}, "ecrite_le": String, "libelle": String}
#   emplacement absent, corrompu ou d'une autre version = {"nom", "vide": true} (aucune erreur)
```
- Même format que l'automatique (format 3, **pas de changement de `VERSION`**) ; champs nouveaux dans le dictionnaire de tête : `"genre"` (`auto` | `emplacement`), `"libelle"` (String, vide pour une sauvegarde du menu). Absents = `auto` et `""` (migration douce).
- `ecrire` et `lire` gardent leur signature ; la nouvelle tête est écrite par une fonction ajoutée.

### 4.2 `Partie` (autoload, dev-logique)
```gdscript
signal sauvegarde_faite(nom: String)                  # après une écriture réussie d'un emplacement
func sauvegarder_dans(nom: String, libelle := "") -> bool   # faux si sauvegarde_auto est faux, partie finie, nom inconnu ; arrête le saut
func charger_emplacement(nom: String) -> bool          # reprendre() + retours += 1 + écriture de l'automatique ; faux si vide ou illisible
func proposition_sauvegarde() -> String                # libellé si la modale ouverte est une décision importante et la proposition permise, sinon ""
func ordre_important(genre: String, montant: float) -> bool   # "achat" | "vente" | "rachat_av" | "cloture_pel" | "retrait_livret"
func marquer_proposition() -> void                     # appelée quand le bandeau est AFFICHÉ : démarre l'espacement de 6 mois
```
- `proposition_sauvegarde()` et `ordre_important()` ignorent l'option du joueur (lue par l'interface) : la logique reste testable seule.

### 4.3 `EtatPartie` (dev-logique)
- `CHAMPS_ETAT` += `"retours"` (int, 0), `"dernier_point_propose"` (int, −99).
- `func decision_importante(contenu: Dictionary) -> String` : libellé ou "" selon §1. « Toujours » = `kind` ou `id` dans `rythme.json > sauvegarde.toujours` ; carte = enjeu ≥ `seuil_carte_salaires` × salaire, ou `id == "C06"`. Les `kind` réels des projets et de « un an après » sont relevés dans le code au lancement (les noms ci-dessous sont provisoires).
- `data/rythme.json > sauvegarde` : `{"intervalle_mois": 6, "seuil_carte_salaires": 1.0, "seuil_ordre_part": 0.20, "seuil_ordre_min": 5000, "toujours": ["marche", "D08", "projet", "C06"]}` (**docs/28 §6**, tranché le 14/11 : sans `gazette` ; C06 dans `toujours`). **Enjeu d'une carte = prix du choix le plus cher** (pas l'écart entre les choix). **Espacement de 6 mois compté depuis la dernière proposition, quelle qu'elle soit** (une « toujours » remet aussi le compteur à zéro ; les « toujours » restent proposées sans exception). « Toujours » : ≤ 7 par partie (un report de projet en ajoute une).
- `func libelle_ordre(genre: String, montant: float, produit: String) -> String` : libellé de la proposition pour un ordre (« Avant : achat de 20 000 F de SICAV Avenir »), **construit par la logique** (docs/30 §8 point 4).
- `Bilan.calculer` : `"retours"` et `"record_possible"` **existent déjà** (créés par 07-L) ; SV-L ne fait qu'incrémenter `retours`.

### 4.4 Interface (dev-interface)
- `class_name Options` (`scripts/ui/options.gd`, statique, `ConfigFile` dans `user://options.cfg`) : `static func proposer_sauvegarde() -> bool`, `static func regler_proposer_sauvegarde(oui: bool)`. Aucun autoload nouveau, `project.godot` intouché.
- `class_name EcranEmplacements` (`scripts/ui/ecran_emplacements.gd`) : les 3 emplacements en mode `"sauver"` ou `"charger"`, signal `emplacement_choisi(nom: String)`, `ferme`.
- Façade `Modales` : bandeau dans la base commune (T9), affiché si `Options.proposer_sauvegarde()` et `Partie.proposition_sauvegarde() != ""`.

## 5. Tâches et fichiers attribués

### 5.1 SV-L (dev-logique, branche `lot/sv-logique`, worktree `JeuClaude_lots\sv-logique`)
Fichiers : `scripts/logique/sauvegarde.gd`, `scripts/logique/etat_partie.gd` (et `foyer.gd` s'il porte les cartes et projets), `scripts/logique/bilan.gd`, `scripts/partie.gd`, `data/rythme.json`, `tests/test_sauvegarde.*`, nouveau `tests/test_emplacements.gd`, `docs/connaissances/dev-logique.md`. **Interdits** : `scripts/ui/*`, `principal.gd`, `project.godot`, `scripts/ville/*`, `tests/test_interface.*`, `tests/test_partie.*`, `tests/recette/`.
1. Emplacements (`lister`, `chemin_emplacement`, tête `genre`/`libelle`), dossier créé à la demande.
2. `sauvegarder_dans`, `charger_emplacement`, compteur `retours`, signal `sauvegarde_faite`.
3. `decision_importante`, `proposition_sauvegarde`, `ordre_important`, `marquer_proposition`, `rythme.json > sauvegarde`.
4. `Bilan` : `retours`, `record_possible`.
5. Tests (dossier `user://emplacements_test_<pid>/`, **jamais** le vrai dossier) ; base, compte rendu.

### 5.2 SV-I (dev-interface, branche `lot/sv-interface`, worktree `JeuClaude_lots\sv-interface`)
Fichiers : `scripts/principal.gd`, façade `ui/modales.gd` et ses morceaux « base commune » et « info, confirmation, menu » (noms exacts issus de T9, à recopier ici au lancement), `ui/ecran_titre.gd`, `ui/panneau_banque.gd`, nouveaux `ui/options.gd`, `ui/ecran_emplacements.gd`, familles de capture `titre` et `ecrans`, `tests/test_interface.*`, `tests/test_partie.*`, `docs/connaissances/dev-interface.md`. **Interdits** : `scripts/logique/*`, `partie.gd`, `data/*`, `scripts/ville/*`, `project.godot`, `tests/recette/`. Si 07-I tourne en même temps : l'écran de fin reste à 07-I, SV-I ne fait que fournir la ligne (texte) ; sinon SV-I l'ajoute à l'écran de fin existant.
1. Menu : REPRENDRE, SAUVEGARDER, CHARGER, HISTORIQUE, option « Proposer de sauvegarder… » (bascule), QUITTER LE JEU.
2. `EcranEmplacements` (sauver : choix parmi 3, confirmation d'écrasement ; charger : confirmation en cours de partie).
3. Écran titre : bouton CHARGER.
4. Bandeau dans les modales à choix → `EcranEmplacements` en mode sauver, libellé de la décision transmis ; touche PC `S` ; touches 1/2/3 inchangées.
5. Feuille d'ordre : bouton secondaire « Sauvegarder d'abord » quand `Partie.ordre_important(...)`.
6. Ligne « Partie rejouée depuis une sauvegarde : hors record » si `bilan["record_possible"]` est faux.
7. Captures (`menu_sauver`, `emplacements_sauver`, `emplacements_charger`, `titre_charger`, `krach_bandeau`, `ordre_important`, `fin_rejouee`) en PC 1920 × 1080, 1920 × 1009, téléphones 1440 × 648 / 240 dpi et 1280 × 720 / 320 dpi.

## 6. Contenu à demander (coordinateur, au début de la vague 6)
- **UX** : maquette du menu, de `EcranEmplacements` (PC et téléphone, 3 lignes, emplacement vide, écrasement), du bandeau dans une carte (place, libellé, état « Sauvegardé ») et du bouton « Sauvegarder d'abord ».
- **Game designer** : relire seuils et espacement (réglables sans code dans `rythme.json`) ; dire si « un an après » (06) rejoint la liste « toujours ».

## 7. Critères d'acceptation

### SV-L (`docs/lots/lot_sv_logique_recette.md`)
- **CA-SL1** : `tests.ps1` vert, aucune erreur de script, total ≥ référence de `main` + nouvelles vérifications ; `test_interface` et `test_partie` inchangés et verts.
- **CA-SL2 (emplacements)** : écrire puis `lister()` les 3 emplacements : résumé, `ecrite_le`, `libelle` exacts ; `lister()` renvoie toujours 3 éléments ; réécrire un emplacement le remplace et ne touche pas les 2 autres ; un emplacement tronqué, modifié (empreinte) ou de format 2 est listé `vide` sans erreur ; aucun fichier hors du dossier de test.
- **CA-SL3 (compatibilité)** : un `partie_en_cours.sav` écrit avec l'ancienne tête se recharge : `retours == 0`, `dernier_point_propose == −99`, partie menée jusqu'à la fin ; `Sauvegarde.VERSION` toujours 3.
- **CA-SL4 (reprise exacte)** : 10 graines × 2 stratégies (`StrategieTest`) : sauvegarde au mois m (dont un mois avec modale en attente : krach, une carte, C06, un projet), 12 mois joués → état A ; `charger_emplacement` puis mêmes choix → état B ; A et B identiques (patrimoine au centime, historique, témoins, issue des escargots).
- **CA-SL5 (record)** : `charger_emplacement` → `retours == 1`, puis 2 au second chargement ; « Continuer » (`reprendre(Sauvegarde.lire())`) ne change pas `retours` ; une sauvegarde d'une partie rejouée, rechargée, a `retours ≥ 1` ; `Bilan.calculer(...)["record_possible"]` faux si et seulement si `retours > 0`.
- **CA-SL6 (décisions importantes)** : `decision_importante` vrai pour le krach (10/1987), D08 (04/1988), C06, chaque choix et échéance de projet, une carte à enjeu ≥ 1 salaire ; faux pour chaque présentation du banquier, chaque événement de vie, une carte sous le seuil ; `ordre_important` aux bornes (19 % / 20 %, 4 999 / 5 000 F) ; espacement : deux décisions « avec seuil » à 5 mois → la 2e non proposée, à 6 mois → proposée ; les « toujours » ignorent l'espacement. Sur 40 graines × 2 stratégies, nombre de propositions par partie imprimé, **entre 4 et 10** dans 100 % des cas.
- **CA-SL7 (sûreté)** : `sauvegarde_auto = false` → `sauvegarder_dans` faux, rien d'écrit ; pendant un saut, il l'arrête puis écrit (reprise sans saut) ; partie finie → faux ; `partie_en_cours.sav` et `user://emplacements/` du joueur jamais touchés (empreintes contrôlées par `tests.ps1`).
- **CA-SL8 (contrat)** : `git diff main...lot/sv-logique -- godot/scripts/partie.gd godot/scripts/logique/` ne retire ni ne renomme aucun signal, fonction ou champ.

### SV-I (`docs/lots/lot_sv_interface_recette.md`)
- **CA-SI1 (menu)** : capture `menu_sauver` : 6 entrées, cibles ≥ `Ecran.cible_min` ; SAUVEGARDER → 3 emplacements ; emplacement plein → confirmation ; après écriture, « Sauvegardé » et `Sauvegarde.lister()` à jour (`test_interface`).
- **CA-SI2 (titre)** : sans emplacement : JOUER seul (inchangé) ; avec un emplacement et sans partie en cours : JOUER + CHARGER ; avec partie en cours : CONTINUER + CHARGER + NOUVELLE PARTIE ; capture `titre_charger` PC et téléphone ; NOUVELLE PARTIE n'efface aucun emplacement.
- **CA-SI3 (chargement)** : en jeu, CHARGER demande confirmation ; après chargement : date, patrimoine, HUD, ville et maison cohérents, modale en attente rouverte, pause, aucun saut actif ; « Continuer » au redémarrage reprend la partie chargée.
- **CA-SI4 (bandeau)** : capture `krach_bandeau` et D08 : bandeau visible ; un toucher → écran des 3 emplacements, choix du joueur (confirmation si plein), retour à la carte avec « Sauvegardé », emplacement écrit avec le bon libellé ; choisir directement un bouton de la carte sans toucher le bandeau fonctionne (1 toucher) ; touches 1/2/3 inchangées, `S` ouvre l'écran des emplacements ; option à « non » → aucun bandeau ; présentation du banquier → aucun bandeau.
- **CA-SI5 (ordre)** : feuille d'achat ≥ 20 % du patrimoine : bouton « Sauvegarder d'abord » ; **tant que le seuil n'a pas été atteint dans cette feuille** : absent ; une fois apparu, il reste jusqu'au changement de produit ou de mode (docs/30 §4, pas de saut de mise en page) ; même hauteur de feuille avec et sans lui ; capture `ordre_important`.
- **CA-SI6 (option)** : régler « non », quitter, relancer : option restée à « non » (fichier de test unique par processus dans les tests).
- **CA-SI7 (fin)** : capture `fin_rejouee` : ligne « hors record » présente si `record_possible` est faux, absente sinon.
- **CA-SI8 (écrans)** : toutes les captures du §5.2 aux 4 formats sans texte hors cadre ni hors écran, chiffres en Atkinson ; aucune `SCRIPT ERROR` ; `tests.ps1` vert.

## 8. Vérifications après fusion (chef de projet, sur `main`)
`tests.ps1` (total ≥ référence) ; captures `reprise` et `titre` inchangées pour un joueur sans emplacement ; `partie_en_cours.sav` du joueur intacte et reprise par CONTINUER ; export Windows `--etape=titre` ; sur l'APK 1.0 : sauvegarder, tuer l'application, relancer, CHARGER (ajouté à la liste de contrôle du téléphone, T2).

## 9. Décisions du joueur et points restés par défaut
- Tranché (06/11) : 3 emplacements ; le joueur choisit l'emplacement à écraser à chaque sauvegarde ; liste des décisions importantes validée ; une recharge exclut la partie du record ; à noter, ne pas lancer maintenant.
- Par défaut (non répondu, pas de nouvelle question tant que le lot n'est pas lancé) : bandeau non bloquant plutôt qu'une question ; titre d'une partie rejouée gardé dans la collection (à confirmer par le client en 07-L).

## 10. Arbitrages du 14/11 (docs/28 §6, docs/30 §8) — maquettes UX : **docs/30** (référence de SV-I)
| # | Point | Décision |
|---|---|---|
| G-1 | Seuils (docs/28 §6) | Repris au §4.3 : `toujours` = `["marche","D08","projet","C06"]`, enjeu = prix du choix le plus cher, espacement depuis la dernière proposition quelle qu'elle soit. CA-SL6 : « toujours » vrai pour C06 sans seuil ni espacement ; 4 à 10 propositions par partie inchangé (mesure). |
| U-1 | Écran des emplacements au-dessus d'une carte | **Couche à part** (`CanvasLayer` au-dessus des modales, hors `Modales.courant`) ; repli docs/30 §3.5 autorisé si la superposition casse un test, écrit au compte rendu. Les touches 1, 2, 3, Échap, Entrée sont consommées tant qu'il est ouvert (test K2 obligatoire, ajouté à CA-SI4). |
| U-2 | « Sauvegarder d'abord » qui reste | **Accepté** : CA-SI5 réécrit. |
| U-3 | Phrase « cette partie ne comptera plus pour le record » dans le mode charger | **Acceptée** : ce n'est pas une règle nouvelle, c'est la règle du joueur (06/11) dite avant le geste (rien de caché). Texte donné par la logique (`Sauvegarde`), le client peut le reformuler. |
| U-4 | Libellé d'un ordre | Construit par la logique : `libelle_ordre` (§4.3). |
| U-5 | Fenêtre d'écrasement | **Accepté** : focus sur ANNULER, aucune touche pour REMPLACER. |
| U-6 | Touches C (charger) et T (titres) de l'écran titre | T **obligatoire** en 07-I (`lot_07.md` D11) ; C **facultative** en SV-I. |
| — | Captures SV-I | deux formats seulement (PC 1920 × 1080, téléphone 1440 × 648) + 1920 × 1009 pour l'écran des emplacements, règle de `feuille_de_route_jouable.md` §5 ; `test_ecran` pour les autres. |
Statut inchangé : **NON LANCÉ** (feu vert du joueur attendu).
