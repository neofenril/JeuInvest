# Lot 05 (vague 4, version jouable) : projets à l'écran (04-I) ∥ moteur de la rue et du krach (05-L, phases A et B)

> Chef de projet, 2026-11-13. Cadre : `feuille_de_route_jouable.md` (prime sur `feuille_de_route.md` §1 pour les vagues 3 à 5). Base : `main` 335442b + ces plans.
> Entrées : docs/15 §3 (P1), §4 (P3 + P9), §5 (P6) ; docs/17 §4.3-4.5 ; docs/18 §2-3, §5 ; **docs/19** (Peugeot 1986-1988, plan de Jean-Mi, kiosque, clôtures du Lundi noir) ; `lot_04.md` §4.2 (contrat des projets, figé) et §12 ; décision du joueur du 13/11 (ordre de vente) ; docs/10 du 29/10 (**classement affiché en permanence**).

## 0. Objectif, découpage

**Pour le joueur (à la sortie 0.5 « jouable », pas à la fin de ce lot)** : dans une nouvelle partie, le foyer choisit un projet en mars 1984 puis en janvier 1987 (3 options), la maison affiche « 21 400 / 30 000 F », le guichet rappelle le projet, le jour J propose de réaliser, de vendre (liste des ventes ligne par ligne), de reporter ou de renoncer. Le moteur fait aussi vivre Jean-Mi, le classement de la rue, les passages des voisins et le kiosque en notifications, le tableau des jours du Lundi noir et « Le krach, un an après » ; leur écran est le lot 06.

| Partie | Développeur | Branche / worktree | Contenu | Départ |
|---|---|---|---|---|
| **04-I** | dev-interface | `lot/04-interface` / `lot04-interface`, **empilée** sur le dernier commit de `lot/03-interface2` | carte de choix de projet, jour J, ligne du guichet, 2e ligne de l'étiquette MA MAISON, colonne PROJET de « Mon foyer », projets allumés ; **plus l'étape 2 de 03-I2** | dès le commit de 03-I2 étape 1 réduite (`lot_04.md` §12.3) |
| **05-L phase A** | **dev-logique-bis** (2e instance, base temporaire `docs/connaissances/dev-logique_05.md`) | `lot/05-logique` / `lot05-logique`, depuis `main` | modules purs `Quartier` et `Krach`, données `rue.json`, `krach.json`, `temoins.json > jeanmi`, tests sur données fabriquées | **tout de suite** |
| **05-L phase B** | dev-logique | même branche, après la phase A | branchement dans le moteur (Jean-Mi témoin, notifications, krach, « un an après », ancrages de Peugeot, sauvegarde, bilan), contrat §4.3 figé pour 05-I | quand 04-L part chez le testeur (le coordinateur fusionne `lot/04-logique` dans `lot/05-logique`) |

dev-ville : **aucune tâche** dans ce lot (réserve ; le routage générique `projet` / `gazette` est livré par 03-V2, `lot_04.md` §12.2).

Hors périmètre : traces P10 des projets, jauge accrochée sous l'étiquette, animations (`feuille_de_route_jouable.md` §6) ; écrans de la rue et du krach (lot 06) ; titres P5, record, sauvegarde manuelle.

## 1. Décisions du chef de projet

| # | Sujet | Décision |
|---|---|---|
| **D7 bis** (s'applique à **04-L**, `lot_04.md` D7) | Ordre de vente automatique (joueur, 13/11) | **RÉALISER** prend le compte courant puis le **Livret A** (le « Livret bleu » du joueur : c'était la version Crédit Mutuel du Livret A, mêmes règles ; le jeu n'a que le Livret A). **RÉALISER EN VENDANT** vend ensuite les placements **du moins rentable au plus rentable** (on garde ce qui rapporte le plus). Rentabilité d'une ligne = gain annualisé depuis son ouverture, **net de ce que la vente coûterait** (frais, impôt, pénalité ; pour le PEL, prime d'État perdue comprise), calculé par le moteur le mois du jour J ; égalité : la plus grosse ligne d'abord. Juste ce qu'il faut (dernière ligne partielle ; actions par titres entiers, surplus au compte courant). Paramètre `projets.json > ordre_vente: "rentabilite"` (l'ancien ordre fixe reste possible : `"fixe"`). Jamais présenté comme un conseil : la carte dit « Ventes, de ce qui rapporte le moins à ce qui rapporte le plus ». Question de confirmation au joueur (§8 Q-J1) : **seule la recette de 04-L l'attend** ; si le joueur répond autrement, c'est une donnée ou une fonction de tri, pas un nouveau lot. CA-L5 de `lot_04.md` : « ordre D7 » se lit « ordre D7 bis » (test : ordre recalculé indépendamment sur 2 cas, dont un avec une ligne d'actions en perte après le krach). |
| D2 | Deux instances de dev-logique | Exception écrite à la règle « un seul développeur logique » : la phase A **ne touche aucun fichier existant** de `scripts/logique/` ni `partie.gd`, ni `periode_p1.json`, `series.json`, `rythme.json`, `foyer.json`, `projets.json`, `banque.json`, ni aucun test existant, ni `tests.ps1` (qui découvre seul les nouveaux tests). Elle commite et rend son compte rendu **avant** que le coordinateur fusionne `lot/04-logique` dans la branche ; dev-logique reprend ensuite seul. Pas de recette de la phase A seule : je relis son compte rendu et ses tests ; la recette porte sur 05-L entier. |
| D3 | Patrimoine de Jean-Mi (docs/19 §2.5, question au game designer) | **Voiture comptée à sa valeur de marché** (sans quoi J1 tombe) : patrimoine = compte courant + équité du compte de bourse (couverture ± gains, négative après liquidation) + valeur de la voiture − capital restant dû − dette de bourse. Le game designer peut le contester (§8 G5) sans bloquer. |
| D4 | Plan de Jean-Mi | docs/19 §2.2-2.4 **en proportions** dans `temoins.json > jeanmi.plan` : couverture = 80 % de son compte courant au 09/1986, position = 5 × couverture, report 0,7 %/mois, renfort 08/1987 = +1/3 de la position (≈ 50 000 F), Porsche 04/1987 140 000 F (apport 30 000 F pris sur les gains, crédit 110 000 F, 48 mois, 12 %), décote mensuelle (table docs/19 §2.4), vente 02/1988 (le reste du crédit, s'il y en a, est soldé par la vente ; un écart < 500 F est négligé), liquidation au cours de fin 10/1987, dette remboursée **1 000 F/mois** dès 12/1987. Le compte courant de Jean-Mi peut être négatif (aucun agio). Escargots non recopiés (R-MIROIR). Le joueur ne peut jamais acheter à crédit (J3). |
| D5 | Ancrages de Peugeot | Phase B remplace les ancrages 1986-1988 de `periode_p1.json` par le JSON de docs/19 §1.2 (**toutes les parties**, rue allumée ou non : c'est une meilleure donnée). Les références qui bougent sont réimprimées et expliquées dans le compte rendu (`test_foyer` : nouvelle `REF_PATRIMOINE_F` avec la raison) ; aucune autre donnée de marché ne change. |
| D6 | Un seul réglage pour la rue et le krach | `config["rue"]` (défaut `rue.json > actif = false`, gardé dans la sauvegarde) allume **ensemble** : Jean-Mi affiché, classement, notifications des voisins, du rang et du kiosque, `jours` du krach, « un an après ». Éteint : la partie est celle de `main` (sauf D5). Jean-Mi est **calculé dans tous les cas** (état et historique), seulement montré si allumé : le bilan reste stable. |
| D7 | Passages et bulles réactives | **Notifications sans pause** (`type "voisin"`, source `rue`), textes de docs/15 §4.4 corrigés par docs/19 §3 (V08 : « Saint-Gobain, et bientôt Paribas… toute la rue devient actionnaire ! »). Budget : au plus **1 notification de voisin tous les 2 mois** (passages et réactives confondus) ; jamais un mois qui ouvre une interruption avec pause : décalée au premier mois possible, au plus +2 mois, sinon abandonnée **sauf** les 5 passages ★ (V01, V07, V09, V13, V16), jamais abandonnés. V01 et V13 : texte long (≤ 60 mots, `long: true`) lu par la relecture de la notification (carte de lecture « La rue » : les 3 voisins, leur règle, « même salaire et mêmes dépenses que vous » ; V13 : phrase du levier calculée). Réactives : 1er achat d'action du joueur (Mme Lopez), réalisation d'un projet (Mme Lopez), M. Lefranc le mois qui suit le krach. Sylvie : déjà faite (humeur). V11 (Jean-Mi court, séquence) et V12 (panneau, décor) : **supprimés** de la version jouable. |
| D8 | Kiosque | **Notification sans pause** de la Gazette (`type "kiosque"`, source `media`), 11 titres (§5.2 A1), **au plus 1 notification rue ou kiosque par mois** (le kiosque cède au voisin : décalé d'un mois au plus, sinon abandonné). |
| D9 | Classement et rang | Tri par patrimoine décroissant, **égalité : le joueur devant**. Notification `type "rang"` quand le joueur passe devant ou derrière **Jean-Mi** (pas Tata, dont la pastille existe déjà), au plus une tous les 6 mois, la première au plus tôt en 10/1986. |
| D10 | Krach | `contenu_modale()` du krach (10/1987), rue allumée : + `jours` (7 lignes, `krach.json`, docs/19 §4.2 ; affichés « environ », arrondis à 5 points). L'**instantané** est pris à l'ouverture de cette modale et complété du choix à la résolution. « Un an après » : interruption **datée** 10/1988 (rang « date historique » de R-CADENCE, budget `gazette` 1, déjà prévu dans `rythme.json`), `kind "gazette"`, source `media` ; textes docs/15 §5.2 (provisoires, `krach.json`). Barres : **Tout vendu** = lignes risquées vendues aux cours de fin 10/1987 avec frais et impôt du moteur, puis au Livret A jusqu'en 10/1988 ; **Rien fait** = mêmes lignes aux cours de 10/1988, dividendes reçus entre-temps compris ; **Renforcé** = Rien fait + le montant proposé par « Renforcer » acheté aux cours de fin 10/1987 (mêmes proportions, frais compris), dividendes compris. Sans action ni SICAV au krach : exemple de 10 000 F de SICAV, `mention` non vide. Aucun « vous auriez dû ». |
| D11 | Projets allumés et jauge (04-I) | `principal._config()` hors mode capture : `"projets": true` (avec `"cartes": true`). Jauge sobre : **2e ligne de l'étiquette MA MAISON** (icône 16 × 16 + « 21 400 / 30 000 F », Atkinson, sans barre), à condition que `Hud.chevauchements_etiquettes()` reste à 0 ; barre à 2 segments (disponible plein, revendable hachuré) dans la colonne PROJET EN COURS de « Mon foyer ». Rien sans projet en cours. |
| D12 | Carte de choix et jour J (04-I) | Même grammaire que la carte de dilemme de 03-I2 (fiche crème, liseré maison, apparition sur place). Choix : 3 boutons de même style (icône, nom, montant, échéance), touches 1 / 2 / 3, ni Échap ni clic extérieur. Jour J : montant, « Disponible sans rien vendre », « Il manque … », liste `ventes` (nom, net, `texte_ecart`, `texte_penalite`), boutons de `c["choix"]` (désactivés hachurés avec leur `sous`) ; RÉALISER EN VENDANT ouvre un **écran de confirmation** dans la carte (liste des ventes, total, « Ce qui reste va sur votre compte. », CONFIRMER / RETOUR) avant `choix_fait`. Conclusion comme `conclure_carte` (ligne `r["consequence"]`, 3 s, passable). |

## 2. Mise en place (coordinateur)
```powershell
$git = "C:\Users\arthu\Documents\temp\JeuClaude\outils\git\cmd\git.exe"
$depot = "C:\Users\arthu\Documents\temp\JeuClaude"
$lots = "C:\Users\arthu\Documents\temp\JeuClaude_lots"
# tout de suite (main contient ce plan) :
& $git -C $depot worktree add -b lot/05-logique "$lots\lot05-logique" main
# dès le commit de 03-I2 étape 1 réduite :
& $git -C $depot worktree add -b lot/04-interface "$lots\lot04-interface" lot/03-interface2
# phase B : après le compte rendu de la phase A ET la remise de 04-L au testeur :
& $git -C "$lots\lot05-logique" merge --no-ff lot/04-logique -m "Fusion de lot/04-logique dans lot/05-logique (phase B)"
# avant chaque recette : main fusionné dans la branche (04-L sur main pour 05-L ; 04-L et 03-V2 sur main pour 04-I)
```
Les scripts trouvent Godot depuis un worktree. `user://` commun : ne jamais écrire ni effacer `partie_en_cours.sav`, ne jamais fermer un Godot qu'on n'a pas lancé. Commits locaux en français, `tests.ps1` vert avant chaque commit, aucun push avant l'OK du testeur.

## 3. Carte de propriété des fichiers (lot 05)
Chemins relatifs à `godot/`. Les `.uid` suivent leur script. **Un fichier absent est interdit à tous.**

| Fichiers | 05-L phase A (dev-logique-bis) | 05-L phase B (dev-logique) | 04-I (dev-interface) |
|---|---|---|---|
| nouveaux `scripts/logique/quartier.gd` (`class_name Quartier`), `scripts/logique/krach.gd` (`class_name Krach`), nouveaux `data/rue.json`, `data/krach.json`, `data/temoins.json` (ajout de `jeanmi`), nouveaux `tests/test_quartier.gd`, `tests/test_krach.gd`, `docs/connaissances/dev-logique_05.md` | oui | oui (après A) | — |
| `scripts/logique/*` existants, `scripts/partie.gd`, `data/*.json` existants, `tests/test_{logique,demo,cadence,mois_utile,sauvegarde,dividendes,foyer,projets}.*`, `tests/autocontrole/`, `outils/tests.ps1`, `outils/trouver_godot.ps1`, `export_presets.cfg`, `docs/connaissances/developpeur.md`, `docs/connaissances/dev-logique.md` | — | oui | — |
| `scripts/ui/*`, `scripts/principal.gd`, `scripts/ecran.gd`, `scenes/`, `project.godot`, `scripts/pixel/ui/*`, `data/pixel/ui/*`, `polices/**/*.import`, `assets/icone/`, `scripts/outils/*.gd`, familles `scenarios/{titre,banque,ecrans,outils,interface}.gd`, `outils/capture.ps1`, `outils/capture_interface.ps1`, `tests/test_{interface,partie,ecran}.*`, `docs/connaissances/dev-interface.md` | — | — | oui |
| `scripts/ville/*`, `juice.gd`, `shaders/`, `scripts/pixel/*.gd` hors `ui/`, `scenarios/ville.gd`, `tests/test_{pixel,rue,pieces}.gd` | — | — | — (dev-ville en réserve) |
| `tests/recette/`, `docs/lots/lot_05_recette.md` | testeur | | |

Règles : 05-L ne touche ni `test_interface` ni `test_partie` ; contrats de `Partie`, `EtatPartie`, `Foyer`, `Projets` : **ajouts seulement**. 04-I ne lit le moteur que par le contrat `lot_04.md` §4.2 et `ordres_bloques()`. Vérifié pour ce plan : aucun fichier dans deux colonnes en même temps (A puis B sur la même branche, jamais ensemble).

## 4. Interfaces (figées)

### 4.1 Routage (livré par 03-V2, `lot_04.md` §12.2)
`Sequences.jouer_modale(c)` : `kind "carte"` et `"projet"` → caméra sur la maison ; `"gazette"` → bâtiment média ; `modales.call(kind, c, depart)` si `modales.has_method(kind)`, sinon `modales.courrier(c, depart, e)` ; boucle tant que `Partie.resoudre_modale(id)` rend `{}` ; puis `modales.call("conclure_" + kind, r, depart)` si la méthode existe. Ligne `RUE fiche kind=<k> appel=<modales|courrier>`.

### 4.2 Fournies par 04-I (façade `Modales`, dev-interface)
```gdscript
func projet(c: Dictionary, depart: Vector2) -> void           # c = contenu_modale() kind "projet" (lot_04 §4.2), étapes "choix" et "echeance" ;
	# émet choix_fait("projet", id) ; RESTE affichée ; touches 1/2/3 (choix) ou 1-4 (jour J) ; ni Échap ni clic extérieur ;
	# "realiser_en_vendant" : écran de confirmation dans la carte avant l'émission (D12)
func conclure_projet(r: Dictionary, arrivee: Vector2) -> void  # coroutine : r["consequence"] 3 s, passable, puis disparition
```
Lit : `EtatPartie.projet_en_cours()`, `projets_passes()`, `ligne_projet_guichet()`, `plan_vente_projet()`, `projets_actifs()`, `ordres_bloques()` (lot_04 §4.1-4.2).

### 4.3 Fournies par 05-L (phase B) pour 05-I (lot 06) — **figées** ; ajouts seulement
```gdscript
# EtatPartie
func rue_active() -> bool                   # config["rue"] (défaut rue.json > actif = false), gardé dans la sauvegarde
func classement_rue() -> Array              # [] si éteinte ; sinon 4 lignes triées (patrimoine décroissant, égalité : joueur devant) :
	# [{"id": "vous"|"livret"|"matelas"|"jeanmi", "nom": String, "initiale": String, "patrimoine": float (F, < 0 possible),
	#   "rang": int (1-4), "vous": bool, "reference": bool (vrai pour Tata Livret)}]
func rang_rue() -> int                      # rang du joueur, 0 si éteinte
func jeanmi_resume() -> Dictionary          # {} si éteinte ; {"etape": "attend"|"position"|"porsche"|"liquide"|"rembourse", "patrimoine": float, "dette": float}
func instantane_krach() -> Dictionary       # {} avant l'ouverture de la modale du krach ou si éteinte
# Notifications sans pause (notif_recue, res["notifs"]) :
#  {"type": "voisin", "source": "rue", "cls": "neutre", "id": "V07", "qui": "jeanmi"|"livret"|"matelas"|"lopez"|"lefranc",
#   "titre": String (nom du voisin), "texte": String (≤ 15 mots ; ≤ 60 si long), "cle": bool, "long": bool}
#  {"type": "rang", "source": "rue", "cls": "gain"|"perte", "titre": String, "texte": String, "rang": int}
#  {"type": "kiosque", "source": "media", "cls": "neutre", "titre": "LA GAZETTE", "texte": String}
# Historique : voisin et rang → genre "voisin", source "rue" ; kiosque → genre "gazette", source "media" ; « un an après » → genre "gazette", source "media".
# contenu_modale() du krach (kind "marche", 10/1987), rue allumée : + "jours": [{"jour": "vendredi 16 octobre", "indice": float,
#   "variation": float (%, 0.0 le 1er jour), "certitude": "A"|"C"}]   (7 lignes) ; clé absente sinon
# contenu_modale() kind "gazette" (10/1988) :
#  {"kind": "gazette", "source": "media", "date": String, "ab": int, "titre": "LE KRACH, UN AN APRÈS", "texte": String (≤ 50 mots),
#   "mention": String ("" ou « Exemple : vous n'aviez ni actions ni SICAV en octobre 1987. »), "base": float,
#   "barres": [{"id": "vendu"|"rien"|"renforce", "titre": String, "valeur": float, "choisi": bool}]  (toujours 3, cet ordre ; choisi : un seul vrai, aucun si exemple),
#   "choix": [{"id": "ok", "titre": "J'AI COMPRIS"}]}
# resoudre_modale("ok") -> {"choix": "ok", "kind": "gazette", "notifs": []}
# Bilan.calculer(e) : + "rue": classement_rue() en fin de partie ([] si éteinte) ;
#   + "replique_rue": {"qui": String, "nom": String, "texte": String} (voisin juste devant le joueur, sinon celui juste derrière ; {} si éteinte)
```
Nouveaux `class_name` du lot : **`Quartier`**, **`Krach`** (05-L). Aucun pour 04-I.

### 4.4 Sauvegarde
Format 3, migration douce. 05-L : `config["rue"]`, état `jeanmi` (position, couverture, dette, crédit, voiture, étape), `quartier` (passages vus, dernier mois de notification de voisin, dernier changement de rang, kiosque vus), `instantane_krach`. Une sauvegarde de `main` se recharge (rue éteinte, Jean-Mi recalculé depuis 01/1984 **non** : il démarre à l'état « attend » avec un compte égal à celui de Tonton Matelas) et va jusqu'à la fin. 04-I : rien.

## 5. Tâches

### 5.1 04-I (dev-interface, `lot/04-interface`)
**Étape 1** (sur le contrat, contenus fabriqués dans les scénarios de capture) :
1. **P1** `Modales.projet` / `conclure_projet` (D12), étapes `choix` et `echeance`, PC et téléphone 1440 × 648 ; relecture d'un projet dans l'historique (genre `projet`, lecture seule).
2. **P2** Ligne du guichet : en-tête de la fenêtre Banque et chaque formulaire d'ordre affichent `ligne_projet_guichet()` quand elle n'est pas vide.
3. **P3** 2e ligne de l'étiquette MA MAISON (D11), aussi en flèche de bord ; absente sans projet.
4. **P4** Colonne PROJET EN COURS de « Mon foyer » : nom, échéance, barre à 2 segments, « … sans rien vendre · + … placés », « Il manque … sans rien vendre. » ; PROJETS PASSÉS avec ✓ / ↻ / ✗ et le mot ; au téléphone, dans la colonne unique.
5. **P5** BANQUE fermée aussi pendant une modale `projet` (même phrase que le moteur).
6. **P6** `principal._config()` hors capture : `"projets": true`.
**Étape 2** (après §6 point 3) : étape 2 de 03-I2 (`lot_04.md` §5.3 : carte dans la vraie séquence, `ordres_bloques()` branché) et de 04-I (projets dans une vraie partie) ; tests et captures (§7.2) ; base, compte rendu.

### 5.2 05-L phase A (dev-logique-bis, `lot/05-logique`, fichiers neufs seulement)
1. **A1 Données** : `rue.json` (`actif: false` ; passages V01-V10, V13-V16 avec date, qui, texte, `cle`, `long` (D7) ; réactives ; 11 titres du kiosque : 06/1984 « Les Bleus sacrés champions d'Europe », 11/1984 « Canal+ débute à la télévision », 12/1985 « Coluche ouvre les Restos du cœur », 03/1986 « La droite gagne, Chirac à Matignon », 05/1986 « Le nuage radioactif divise l'opinion », 10/1986 « Prost de nouveau champion du monde », 04/1987 « Bouygues retenu pour reprendre TF1 », 10/1987 « LUNDI NOIR », 05/1988 « Mitterrand réélu pour sept ans », 06/1988 « Le CAC 40, nouvel indicateur en temps réel », 09/1988 « Séoul : le monde du sport en fête » (docs/19 §3, certitudes) ; textes de rang (« Jean-Mi passe devant vous dans la rue. » / « Vous repassez devant Jean-Mi. ») ; gabarit du levier (docs/19 §2.3 : « Avec {couverture}, Jean-Mi en a joué {position} au règlement mensuel (acheter à crédit sur la Bourse). Peugeot a perdu {baisse} : {perte} de perte. Ses {couverture} y sont passés, et il en doit encore {dette}. ») ; budgets ; tout texte marqué `_provisoire` (game designer, §8 G5)). `krach.json` : 7 jours (docs/19 §4.2, certitudes), textes de « un an après » (docs/15 §5.2) et de la mention, montant de l'exemple (10 000 F). `temoins.json > jeanmi` : nom, initiale « J », règle, répliques `devant` / `derriere` provisoires, plan (D4).
2. **A2 `Quartier`** (statiques, sans état propre ; signatures libres, documentées dans le compte rendu) : état initial et pas mensuel de Jean-Mi (cours du mois, cours précédent, compte courant → nouvel état, mouvement du compte, événements), patrimoine (D3), classement (D9), phrase du levier, sélection des notifications du mois (budgets D7-D8, décalages, ★ jamais abandonnés, mois de pause interdit), titre du kiosque.
3. **A3 `Krach`** : jours du Lundi noir, construction de l'instantané (lecture seule d'une `EtatPartie`), 3 barres (D10) à partir de l'instantané et des cours / taux / dividendes fournis en arguments.
4. **A4 Tests** `test_quartier`, `test_krach` sur données fabriquées : trajectoire de Jean-Mi sur la série de docs/19 §1.2 avec un miroir fabriqué → fin 09/1987 couverture 26 900 F ± 1 %, perte 52 941 F ± 1 %, dette 26 041 F ± 1 %, `couverture + dette = perte` au franc ; phrase du levier sans chiffre en dur ; budgets des notifications ; mots interdits (« achetez », « vendez », « c'est le moment », « auriez dû ») dans tous les textes neufs ; barres recalculées indépendamment sur 2 portefeuilles fabriqués et l'exemple.
5. Base `dev-logique_05.md`, compte rendu (API exacte de `Quartier` et `Krach`, ce qui reste à brancher).

### 5.3 05-L phase B (dev-logique, même branche)
1. **B1** Ancrages de Peugeot (D5), nouvelles références imprimées et expliquées.
2. **B2** Jean-Mi témoin (D4, R-MIROIR : salaire, vie, cartes de consommation, projets, héritage ; pas les escargots), `hist["jeanmi"]`, sauvegarde.
3. **B3** `config["rue"]` (D6), notifications voisin / rang / kiosque (D7-D9), historique, non-lus pendant un saut.
4. **B4** Krach : `jours`, instantané, « un an après » (Cadence, budget `gazette`), `resoudre_modale("ok")`.
5. **B5** Bilan (`rue`, `replique_rue`), accesseurs du contrat §4.3.
6. **B6** `StrategieTest` : stratégie « tout sur Peugeot sans crédit » (dès 03/1986, tout le disponible au-delà d'un mois de dépenses).
7. **B7** Tests (§7.1) ; socle `developpeur.md`, base `dev-logique.md` (y reporter l'essentiel de `dev-logique_05.md`, puis supprimer ce fichier), compte rendu.

**Points d'arrêt de dev-logique** (il s'arrête et me prévient) : J1 ou J2 non tenu sur les vraies parties (docs/19 §2.5 : marge mince en 09/1987 ; levier en données : décote de 09/1987, cours d'août-septembre) ; « un an après » impossible en 10/1988 sans casser R-CADENCE ; budgets des notifications qui abandonnent plus de 3 passages non ★ en moyenne.

## 6. Ordre, parallélisme, fusion
1. Commit de ce plan (fait) ; création de `lot/05-logique` ; **dev-logique-bis lance la phase A** en parallèle de 04-L (dev-logique), 03-I2 étape 1 et 03-V2.
2. 03-I2 étape 1 commitée → création de `lot/04-interface` → dev-interface fait l'étape 1 de 04-I.
3. 04-L et 03-V2 recettés et fusionnés dans `main` (ordre des OK) → le coordinateur fusionne `main` dans `lot/04-interface` → étape 2 → **recette R-MAISON** → fusion de `lot/04-interface` dans `main` (**J1**, pas d'export).
4. Phase A commitée et compte rendu lu par moi + 04-L remis au testeur → fusion de `lot/04-logique` dans `lot/05-logique` → phase B. Avant la recette : `main` (avec 04-L) fusionné dans la branche. Recette 05-L → fusion.
5. Après chaque fusion : `tests.ps1 -Recette` sur `main` par le coordinateur ; échec → `lot/05-<partie>-correctif`.
6. Suite : `lot_06.md` (05-I, R-RUE, sortie 0.5 jouable).

## 7. Critères d'acceptation (testeur, `docs/lots/lot_05_recette.md`) — recettes ciblées (`feuille_de_route_jouable.md` §5) ; ★ = obligatoire

### 7.1 05-L (branche = `main` avec 04-L + 05-L)
- **CA-R1 ★** : `tests.ps1 -Recette` vert, 0 erreur de script, total ≥ `main` + nouvelles vérifications ; `git diff main...lot/05-logique -- godot/tests/test_interface.* godot/tests/test_partie.*` vide.
- **CA-R2 ★ (Jean-Mi, CA-3.1)** : 40 graines × 3 stratégies (passive « tout au Livret A », active, « tout sur Peugeot sans crédit »), rue, cartes et projets allumés : **J1** Jean-Mi devant Tata chaque mois de 03 à 09/1987 ; **J2** derrière Tata d'au moins 10 % en 12/1988 et **dernier** de la rue ; Tonton Matelas derrière Tata en 12/1988 ; ligne `MESURE J1 marge_min=<F> mois=<mm/aaaa>`.
- **CA-R3 ★ (miroir)** : jusqu'en 08/1986, patrimoine de Jean-Mi = celui de Tonton Matelas au franc près, chaque mois, 40 graines (cartes et projets allumés) ; ensuite, les mouvements communs (salaire, vie, cartes de consommation, projets, héritage) sont appliqués à Jean-Mi le même mois, du même montant ; escargots non recopiés.
- **CA-R4 ★ (levier)** : texte de V13 : aucun chiffre hors gabarit, `couverture + dette = perte` au franc près, recalcul indépendant dans le test sur une graine.
- **CA-R5 ★ (notifications)** : 40 graines, saut après chaque interruption : ≤ 1 notification de voisin tous les 2 mois ; ≤ 1 notification rue ou kiosque par mois ; aucune un mois qui ouvre une interruption avec pause ; les 5 ★ dans l'historique (source `rue`), même franchis en saut ; rang ≤ 1 tous les 6 mois ; kiosque : chaque titre au plus 1 fois, à sa date ou 1 mois après, sinon absent (compté).
- **CA-R6 ★ (pédagogie)** : aucun « achetez », « vendez », « c'est le moment », « auriez dû » dans `rue.json`, `krach.json`, `temoins.json > jeanmi` ; aucun bouton du joueur n'achète à crédit.
- **CA-R7 ★ (« un an après », CA-6.2 / 6.3)** : 10/1988 dans 100 % des parties (40 graines × 3 stratégies), historique genre `gazette` source `media` ; barres exactes au franc près face à un recalcul indépendant pour les 3 choix du krach et l'exemple ; R-CADENCE tenue (test de cadence vert avec rue allumée).
- **CA-R8 ★ (Lundi noir)** : contenu du krach rue allumée : 7 `jours` égaux à `krach.json` ; aucune autre modale ne porte `jours`.
- **CA-R9 ★ (éteint par défaut)** : rue éteinte : aucune notification `voisin` / `rang` / `kiosque`, aucune modale `gazette`, pas de `jours` ; tirages identiques à `main` ; seules les références dues aux ancrages de Peugeot changent, expliquées.
- **CA-R10 ★ (sauvegarde)** : sauvegarde en 11/1986 et en 11/1987 puis reprise : Jean-Mi, quartier, instantané identiques, même fin ; une sauvegarde de `main` se recharge et finit.
- **CA-R11 (contrat)** : un test énumère les champs du §4.3 ; aucune ligne `-func`, `-signal`, `-var`, `-const` d'un nom existant retirée.
- **CA-R12 ★ (périmètre)** : `git diff --stat main...lot/05-logique` dans les colonnes 05-L du §3.

### 7.2 R-MAISON (branche `lot/04-interface` = `main` + 04-L + 03-V2 + 03-I2 + 04-I) : remplace CA-I1 à I8 et CA-F de `lot_04.md`
- **CA-M1 ★** : `tests.ps1 -Recette` vert, 0 erreur de script ; `test_interface` passe **toute la démo cartes et projets allumés** (actif et passif) par la vraie interface, chaque carte et chaque projet fermés, sans blocage.
- **CA-M2 ★ (carte)** : étape `carte` (PC 1080, 1440 × 648) : 2 choix, montants, pictos ; choix non payable grisé avec « Il manque … » et sans effet (`UI carte refus=ignore`) ; Échap et clic extérieur sans effet ; conclusion = `r["consequence"]` (ligne imprimée) ; `cibles … sous_seuil=0`, `debordements=0`, `chiffres_pixelify=0`.
- **CA-M3 ★ (banque fermée)** : pendant une carte **et** pendant un projet : BANQUE grisée, phrase de l'interface == `msg` du moteur, touche et bâtiment sans effet ; rouverte après.
- **CA-M4 (« Mon foyer »)** : `mon_foyer` : phrase = `humeur_phrase()`, cause, 4 cartes, projet en cours (valeurs == `projet_en_cours()`, lignes imprimées), projets passés avec symbole et mot, aucun nombre ni jauge d'humeur ; téléphone en une colonne.
- **CA-M5 ★ (choix de projet)** : `projet_choix` : 3 options == `c["choix"]` (nom, montant, échéance), touches 1 / 2 / 3, Échap sans effet ; après le choix `projet_en_cours()["id"]` == option choisie (imprimé).
- **CA-M6 ★ (jour J)** : `projet_jour_j` en 3 cas : disponible suffisant (RÉALISER actif) ; manque couvert par les ventes (RÉALISER EN VENDANT → confirmation listant exactement `plan_vente_projet()` : nom, net, écart, pénalité ; après confirmation, ventes faites == plan, compte jamais négatif, lignes imprimées) ; rien ne suffit (REPORTER si possible, RENONCER). P2C : pas de REPORTER, « RENONCER POUR L'INSTANT ». Ordre de vente = D7 bis.
- **CA-M7 ★ (guichet)** : en-tête de la Banque et formulaires d'ordre : `ligne_projet_guichet()` quand un projet est en cours, rien sinon ; absente des présentations du banquier.
- **CA-M8 (étiquette)** : 2e ligne de MA MAISON == `projet_en_cours()` (disponible / montant) ; `chevauchements_etiquettes()` = 0 sur les étapes d'étiquettes existantes ; absente sans projet.
- **CA-M9 ★ (allumage)** : `_config()` hors capture contient `"cartes": true` et `"projets": true` (test) ; en capture, absents ; une sauvegarde 0.4.1 reprise reste sans cartes ni projets ; `integrale` = `integrale_saut` = références de `main` ; nouvelle référence `integrale_maison` (cartes et projets allumés, graine fixe : patrimoine, frais, interruptions, cartes, projets réalisés) imprimée.
- **CA-M10 ★ (fusion)** : vraie partie allumée : `RUE fiche kind=carte appel=modales` et `RUE fiche kind=projet appel=modales` ; `capture_interface.ps1 -Serie` et `capture_ville.ps1 -Serie` code 0.
- **CA-M11 ★ (à la main)** : partie jouée sur PC jusqu'en 05/1986 au moins (≥ 3 cartes, choix du projet 1, jour J) puis téléphone simulé 1440 × 648 sur 3 interruptions : rien de bloqué, rien d'illisible.
- **CA-M12 ★ (périmètre)** : `git diff --stat main...lot/04-interface` : colonnes dev-interface de `lot_04.md` §3 et de ce plan.

## 8. Contenus des experts : manques et demandes exactes (à lancer par le coordinateur)

**Rien n'empêche de lancer les développeurs.** Classement : **(B)** bloque une recette ; **(S)** souhaité avant l'étape 1 d'un écran, sinon défaut du plan appliqué ; **(N)** non bloquant, données remplaçables sans code.

| # | Pour | Qui | Bloque ? |
|---|---|---|---|
| Q-J1 | 04-L (D7 bis) | joueur (par le coordinateur) | **(B)** recette de 04-L |
| U3 | 04-I étape 1 | UX | (S) avant 04-I étape 1 |
| U4 | 05-I étape 1 (lot 06) | UX | (S) avant 05-I étape 1 |
| K3 | 04-L, 05-L | banquier | (N) |
| B4 | 05-L | boursier | (N) |
| G5 | 05-L | game designer | (N), souhaité avant la recette de 05-L |
| G4 | 04-I | game designer | (N) (déjà demandé dans `lot_04.md` §8 ; rappel) |

**Q-J1 (au joueur, texte exact)** : « Pour l'ordre de vente automatique d'un projet : le jeu n'a qu'un livret, le Livret A (le Livret bleu était le même livret au Crédit Mutuel). On prend donc d'abord le compte courant, puis le Livret A. Ensuite, "par ordre de rentabilité" : on vend d'abord ce qui rapporte le moins et on garde ce qui rapporte le plus, c'est bien ça ? (Conséquence : après le krach, des actions en perte seraient vendues avant le PEL.) »

**U3 (à l'UX, texte exact)** : « Version jouable sans animation (feuille_de_route_jouable.md, lot_05.md D11-D12). Maquettes texte, comme docs/17 §4, PC 1920 × 1080 et téléphone 1440 × 648, même grammaire que la carte de dilemme (docs/17 §4.1, apparition sur place) : (1) carte de choix de projet à 3 options (icône 16 × 16, nom, montant, échéance) ; (2) carte "Le jour J" : montant, disponible sans rien vendre, ce qui manque, liste des ventes ligne par ligne (nom, net, écart avec les versements, pénalité), 4 boutons dont certains désactivés avec une raison, et l'écran de confirmation de RÉALISER EN VENDANT ; (3) 2e ligne de l'étiquette MA MAISON "[icône] 21 400 / 30 000 F" sans barre (et en flèche de bord) ; (4) colonne PROJET EN COURS de "Mon foyer" au téléphone, en une seule colonne avec défilement. Contraintes : cibles ≥ 48 dp, chiffres en Atkinson, rien d'animé. Sans réponse avant le début de 04-I, dev-interface applique lot_05.md D11-D12. »

**U4 (à l'UX, texte exact)** : « Version jouable (lot_06.md). Maquettes texte PC 1920 × 1080 et téléphone 1440 × 648, sans animation : (1) le classement de la rue **affiché en permanence** (décision du joueur du 29/10) alors que la barre haute est pleine : défaut proposé, une pastille "RUE 2e / 4" à côté de la pastille "vs tout au Livret A", qui ouvre "Mon argent" ; (2) bloc "La rue" dans "Mon argent" : 4 lignes (initiale, nom, patrimoine, rang ; Tata soulignée comme référence ; patrimoine négatif en rouge avec le signe) ; (3) notification d'un voisin (source rue, couleur sarcelle, docs/17 §4.5) et sa relecture longue (V01 "La rue", V13 le levier, ≤ 60 mots) ; (4) tableau des 7 jours du Lundi noir dans la modale du krach existante ("environ", arrondi à 5 points) ; (5) carte "Le krach, un an après" à 3 barres, choix du joueur entouré, mention "exemple" ; (6) écran de fin à 4 barres + rang + réplique du voisin le plus proche. Sans réponse avant le début de 05-I, dev-interface applique les défauts de lot_06.md. »

**K3 (au banquier, texte exact)** : « Deux points, non bloquants. (1) Le joueur a fixé l'ordre de vente automatique d'un projet : compte courant, puis "Livret bleu", puis le reste par ordre de rentabilité. Nous traitons le Livret bleu comme le Livret A du jeu et vendons du moins rentable au plus rentable, rentabilité = gain annualisé depuis l'ouverture, net de ce que la vente coûterait (frais, impôt, pénalité, prime d'État perdue du PEL) (lot_05.md D7 bis). Est-ce juste et lisible pour un joueur ? Une phrase pour la carte, ≤ 15 mots, sans conseil (provisoire : "Ventes, de ce qui rapporte le moins à ce qui rapporte le plus."). (2) Jean-Mi : docs/19 §2.4 retient une Porsche 944 d'occasion à 140 000 F, crédit 110 000 F sur 48 mois à 12 %, mensualité 2 897 F ; docs/18 §5 donnait 12-14 % et une 944 neuve à 240-280 000 F. Validez-vous les chiffres de docs/19 (certitude A/B/C) ? »

**B4 (au boursier, texte exact)** : « Non bloquant, pour lot_05.md D10. (1) Relire le texte provisoire de "Le krach, un an après" (docs/15 §5.2, ≤ 50 mots) et proposer la phrase finale sur 1929 (Wall Street, durée de retour au sommet), avec certitude. (2) Vérifier que la série du jeu (indice et Peugeot, docs/19 §1.2) donne en 10/1988 un rebond cohérent avec l'histoire, et donner l'ordre de grandeur attendu des 3 barres pour 10 000 F de SICAV (tout vendu fin 10/1987 puis Livret A ; rien fait ; renforcé de 50 %). (3) Valider la liste des 11 titres du kiosque retenus (lot_05.md §5.2 A1) et le nom de l'indice à afficher au-dessus des 7 jours du Lundi noir ("Indice de Paris, environ" proposé). »

**G5 (au game designer, texte exact)** : « Version jouable : les voisins n'apparaissent pas dans la rue, ils parlent par **notifications** sans pause (lot_05.md D7-D9). Merci de : (1) valider ou corriger la convention de patrimoine de Jean-Mi (voiture comptée à sa valeur de marché, D3) ; (2) écrire les textes définitifs, au format notification (≤ 15 mots, titre = nom du voisin) de V02-V10, V14-V16, des 3 bulles réactives et des 2 notifications de rang ; V01 et V13 en texte long ≤ 60 mots (V13 garde les chiffres en gabarits {couverture}, {position}, {baisse}, {perte}, {dette}) ; répliques `devant` / `derriere` de Jean-Mi pour l'écran de fin, jamais enviables ; (3) dire si le dosage (≤ 1 voisin tous les 2 mois, ≤ 1 notification rue ou kiosque par mois, 11 titres de kiosque) vous paraît juste pour une première partie jouable ; (4) libellé de la pastille permanente du classement ("RUE 2e / 4" proposé). Tout est remplaçable dans rue.json et temoins.json sans code. »

**G4 (rappel au game designer)** : textes des cartes de projet (choix, jour J, rappel, conséquences, répliques de Sylvie au jour J), en remplacement des provisoires de `lot_04.md` §8.

## 9. Comptes rendus attendus
Fichiers modifiés (comparés au §3), décisions prises dans les règles, écarts d'interface (aucun attendu), non vérifié, vérifications avant / après, captures à relire en priorité, base à jour. Phase A : API de `Quartier` / `Krach`, trajectoire de Jean-Mi obtenue. Phase B : `MESURE J1`, références changées par D5, nombre de passages abandonnés, répartition des notifications par mois. 04-I : référence `integrale_maison`, défauts appliqués faute d'avis UX.

## 10. Validation (rempli par le chef de projet)
- [ ] 05-L : CA-R1 à R12 · [ ] R-MAISON : CA-M1 à M12 · [ ] captures relues · [ ] bases à jour
