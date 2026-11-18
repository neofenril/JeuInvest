# Lot 08b : rééquilibrage des titres d'époque et du dosage de la rue

> Chef de projet, 2026-11-18. **Premier lot de l'ordre décidé par le joueur** (`decisions_extension_annees.md` §4 : rééquilibrage → socle des chapitres → 1989-1993 et sauvegarde manuelle).
> Origine : `reprise.md` (point 1), recette 07-L (`lot_07_recette.md` CA-T10 et A3), `test_titres_mesures`, docs/27 §2.3 (dosage de la rue), docs/28 (titres).
> Base : `main` à c14dede (0.6.2, **1 379 vérifications**, `tests.ps1 -Recette -Delai 700`).

## 0. En bref

- **Un seul développeur : dev-logique.** Branche `lot/08b-logique`, worktree `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot08b-logique`.
- **Aucun changement visible d'interface**, aucun changement de patrimoine, de frais ni de cadence : seuls changent (1) le **titre** attribué à la fin et (2) éventuellement la **date** ou l'abandon de quelques notifications de la rue. Les références chiffrées des parties restent identiques au centime.
- Pourquoi : la mesure de 07-L (520 parties) donne golden_boy 0, écureuil 0, cigale 4 %, neveu 27 % du total (38 % en « alterner »), marin **40/40** en « tout sur Peugeot » (la concentration sur une seule action est récompensée, contraire à docs/03 : jamais de récompense à la spéculation), bon_pere **52 %** en « alterner + moins cher ».
- Diagnostic : une partie du déséquilibre vient de la **population de test** (aucune stratégie générique ne vend au krach ni ne reste « livret + PEL » : golden_boy et écureuil y sont impossibles). On corrige donc d'abord **la mesure** (population de référence plausible), puis **les seuils**.
- Durée visée : 1 à 2 jours de développement, recette courte.

## 1. Hors périmètre

- Ordre, nombre (9), identifiants, noms et « pourquoi » des titres : **inchangés** (la collection du joueur dans `records.sav` reste valide). Exception possible : le « pourquoi » d'« apprenti » si le game designer le réécrit (G-R2, donnée seulement).
- Aucun fichier d'interface, de ville, de scénario de capture ; `project.godot`, `export_presets.cfg`, `principal.gd` interdits.
- Pas de nouvelle notification, pas de nouveau texte de la rue ; pas de changement de `Quartier` hors mesure (sauf budgets en données, §4).
- Pas d'export (aucun changement visible : la 0.6.2 reste la version du joueur ; le rééquilibrage partira avec le prochain export).

## 2. Mise en place (coordinateur)

```
outils\git\cmd\git.exe -C C:\Users\arthu\Documents\temp\JeuClaude worktree add C:\Users\arthu\Documents\temp\JeuClaude_lots\lot08b-logique -b lot/08b-logique main
```
Ce plan est commité sur `main` avant la création de la branche. Base de connaissances : `docs/connaissances/dev-logique.md` + socle `developpeur.md`.

## 3. Fichiers attribués (dev-logique)

| Fichier | Action |
|---|---|
| `godot/data/titres.json` | paramètres (§4.2) ; nouveaux paramètres documentés dans `_parametres` |
| `godot/scripts/logique/titres.gd` | conditions : seulement les 3 ajouts permis (§4.2) |
| `godot/scripts/logique/strategie_test.gd` | population de référence (§4.1), clés de profil facultatives nouvelles |
| `godot/tests/test_titres_mesures.gd` | mesure sur la population de référence ; alertes devenues **bloquantes** (§5) |
| `godot/tests/test_titres.gd` | mises à jour des attentes (bornes des nouveaux paramètres, CA-T2 rejoué) |
| `godot/tests/test_rue_mesures.gd` + `.uid` (**nouveau**) | mesure du dosage de la rue et de Jean-Mi (§4.3) |
| `godot/data/rue.json` | budgets et mois des passages **non ★** seulement, si la mesure l'exige (§4.3) |
| `docs/connaissances/dev-logique.md` | base à jour |

Interdits : tout le reste (en particulier `etat_partie.gd`, `quartier.gd`, `foyer.gd`, `projets.gd`, `tests/recette/`, `tests.ps1`). Si une mesure exige un de ces fichiers : **point d'arrêt**, compte rendu au chef de projet.

## 4. Tâches

### 4.1 T1 : population de référence « P-REF » (mesure d'abord, aucun seuil changé)

- `StrategieTest.profil_reference(g: int) -> Dictionary` : un profil de joueur **plausible**, tiré de façon déterministe de la graine `g` (générateur propre, ex. `RandomNumberGenerator` à graine `g * 7919 + 13`, jamais le hasard de la partie). Lois de tirage (certitude C, à valider par le game designer, G-R1) :

| Clé | Tirage |
|---|---|
| `cartes` | epargner 30 % · alterner 40 % · depenser 30 % |
| `escargots` | preter 15 % · refuser 85 % |
| `projets` | moins_cher 40 % · milieu 20 % · plus_cher 40 % ; `jour_j` par projet : auto 70 % · vendre 15 % · renoncer 15 % |
| `ouvrir` | D01 (Livret A) 90 % ; chacune des autres présentations 50 % |
| `livret` | vrai 80 % |
| `bourse.part` | 0 : 30 % · 0,15 : 25 % · 0,30 : 20 % · 0,45 : 15 % · 0,60 : 10 % ; `depuis` tiré entre 1984-06 et 1986-06 |
| `bourse.produit` (**clé nouvelle**) | `"sicav"` 50 % · `"elf"` 20 % · `"une_action"` 30 % (toute la part risquée sur **une seule** action présentée, tirée parmi celles disponibles) |
| `krach` | rien 55 % · vendre 30 % · renforcer 15 % |
| `vente_apres` (**clé nouvelle**) | 10 % : vend toutes les actions et SICAV en 12/1987 par ordre |

- Partie de P-REF = `Donnees.config_demo(g)` avec cartes, projets et rue allumés, jouée par `jouer_partie_profil`, **g = 1 à 200**. Si l'étape dépasse 90 s sur la machine du joueur, passer à 120 graines (le dire dans le compte rendu).
- `test_titres_mesures` imprime, **avant tout changement de seuil** (1er commit) : `REFERENCE_PREF (200 parties) : bon_pere=… golden_boy=… …` et garde ses 13 combinaisons actuelles (`REPARTITION …`). Ces lignes du 1er commit vont dans le compte rendu (« avant »).

### 4.2 T2 : seuils des titres (données d'abord)

Leviers permis, dans cet ordre de préférence :
1. Paramètres existants de `titres.json` : `ecart_min`, `part_risquee`, `cartes_min`, `cartes_ecart`, `cc_moyen_min`, `vente_apres_krach`, `fenetre_vente_krach`. `produits_surs` reste `["livret", "pel"]` (le « pourquoi » d'écureuil dit « sans frais »).
2. Trois ajouts de code dans `titres.gd`, chacun piloté par un paramètre (absent = comportement actuel) :
   - `marin_ligne_max` (proposé 0,60) : « marin » exige en plus que **la plus grosse ligne risquée au krach ≤ marin_ligne_max × la part risquée** (une SICAV compte comme une ligne diversifiée : sa part ne déclenche jamais le refus). Tout-Peugeot n'est plus « marin ».
   - `cigale_min`, `cigale_ecart` (défaut = `cartes_min`, `cartes_ecart`) : seuils propres à la cigale, pour la rendre atteignable sans toucher la fourmi.
   - `bon_pere_humeur` (défaut `"pas_fachee"`, autre valeur `"contente"`) : humeur exigée pour « bon père ».
3. Rien d'autre : pas de nouveau titre, pas de changement d'ordre.

Valeurs de départ suggérées (à confirmer par la mesure) : `ecart_min` 0,04 ; `cc_moyen_min` 0,35 ; `cigale_min` 4, `cigale_ecart` 2 ; `marin_ligne_max` 0,60.

### 4.3 T3 : dosage de la rue et de Jean-Mi

Aucune plainte précise du joueur à ce jour (« à valider avec les retours des testeurs externes ») : ce lot **mesure et garantit** le dosage de docs/27 §2.3 ; il ne le change que si une borne n'est pas tenue.

- `test_rue_mesures.gd` (nouveau, logique pure) joue P-REF (200 parties, rue allumée) et les 3 modes de `test_rue_moteur` (passif, actif, peugeot × 40 graines), et imprime par mode : `RUE mode=… notifs_rue_kiosque moy=… min=… max=… jeanmi moy=… etoiles_livrees=…/… abandonnes_non_etoile moy=… max_par_mois=… ecart_voisin_min=… mois_pause_violes=…` ; puis une ligne `JEANMI etapes_vues=…` (part des parties où chaque étape de son arc, « attend un tuyau » / « tout sur Peugeot » / « Porsche à crédit » / « liquidé » / « rembourse », a donné au moins une notification).
- Si une borne du §5 (CA-R4 à R7) n'est pas tenue : ajuster **seulement** `rue.json > budgets` et les mois des passages **non ★** ; jamais les ★ (V01, V07, V09, V13, V16), jamais de texte.
- Si le joueur répond à la question Q-R1 (§7) avant la fin du lot : « trop de Jean-Mi » → retirer d'abord les passages non ★ de Jean-Mi ; « pas assez » → rien à coder dans ce lot (idée 1 de docs/27 §3.2 : passe par l'interface, lot ultérieur).

## 5. Critères d'acceptation (vérifiés par le testeur)

Bloquants (★) sauf mention. « P-REF » = 200 parties de §4.1.

- **CA-R1 ★ Mesure « avant » fournie** : le 1er commit de la branche ne change aucun seuil et imprime `REFERENCE_PREF` ; le compte rendu cite ces lignes et celles d'après.
- **CA-R2 ★ Répartition sur P-REF** (ligne `REFERENCE_PREF` du dernier commit, contrôlée par `verifier` dans `test_titres_mesures`) :
  - chacun des 9 titres ≥ 3 % (≥ 6 / 200) ;
  - aucun titre > 25 % (> 50 / 200), « apprenti » compris ;
  - bon_pere entre 8 % et 25 %.
- **CA-R3 ★ Combinaisons existantes** (13 × 40) :
  - aucun titre > 50 % d'une combinaison « alterner » (l'alerte actuelle devient une vérification) ;
  - bon_pere ≤ 40 % en « actif alterner moins_cher » et en « passif alterner moins_cher » ;
  - « tout sur Peugeot » : marin ≤ 4 / 40 (attendu 0).
- **CA-R4 ★ Stratégies dédiées (CA-T2)** : chacun des 9 profils de `PROFILS_TITRES` obtient toujours son titre sur sa graine de référence (profils ajustés si un seuil bouge, ajustement cité dans le compte rendu).
- **CA-R5 ★ Rue, bornes de docs/27 §2.3** sur P-REF et les 3 modes : 5 / 5 passages ★ livrés dans 100 % des parties ; jamais plus d'une notification rue ou kiosque par mois ; jamais une notification de voisin à moins de 2 mois d'une autre ; aucune sur un mois qui ouvre une interruption avec pause ; notification de rang ≤ 1 tous les 6 mois.
- **CA-R6 ★ Volume** : moyenne des notifications rue + kiosque par partie entre 20 et 30 dans chaque mode ; passages non ★ abandonnés ≤ 3 en moyenne (seuil de `lot_05.md`).
- **CA-R7 (mesure, non bloquant)** : ligne `JEANMI etapes_vues` imprimée ; signaler toute étape vue dans moins de 80 % des parties où Jean-Mi l'a atteinte.
- **CA-R8 ★ Non-régression** : patrimoines finaux, frais et nombre d'interruptions identiques au centime à `main` pour les parties de référence (`test_logique` intégrale graine 7 ; `test_rue_moteur` ; 8 parties de `test_foyer` / `test_dividendes`) ; aucune référence de test modifiée hors `test_titres*` et (si §4.3 a joué) `test_rue_moteur` / `test_quartier`, chaque changement expliqué.
- **CA-R9 ★ Tests** : `tests.ps1 -Recette -Delai 700` vert, ≥ 1 379 vérifications + les nouvelles, 0 erreur de script ; durée totale augmentée de ≤ 120 s ; `records.sav` et `partie_en_cours.sav` du joueur inchangés (aucun test n'écrit le vrai fichier).
- **CA-R10 ★ Périmètre** : `git diff main...lot/08b-logique --stat` ⊂ tableau du §3.
- **CA-R11 ★ Textes** : si un texte change (seulement « apprenti », G-R2), mêmes règles que CA-T4 de 07-L (≤ 15 mots, vouvoiement, mots interdits).

## 6. Points d'arrêt (dev-logique s'arrête et prévient)

- CA-R2 ou CA-R3 inatteignable avec les leviers du §4.2 : envoyer le tableau mesuré (P-REF et combinaisons, pour 2 ou 3 jeux de seuils essayés) ; le chef de projet arbitre avec le game designer.
- Une borne de CA-R5 / R6 exige de toucher `quartier.gd` ou un passage ★.
- P-REF fait finir une partie en faillite ou inachevée (≠ 0) : signaler les graines.

## 7. Questions (non bloquantes ; le lot part avec les défauts)

- **G-R1 (game designer)** : lois de tirage de P-REF (§4.1) plausibles pour un joueur réel ? Cibles de CA-R2 (≥ 3 %, ≤ 25 %, bon_pere 8-25 %) justes ? Défaut : celles du plan.
- **G-R2 (game designer)** : tout-Peugeot (non vendu, gagnant) reçoit désormais « apprenti », dont le « pourquoi » dit « Un peu de tout, sans excès » : texte à réécrire (≤ 15 mots, ex. « Rejouez pour tenter une autre voie. » seul) ? Défaut : inchangé.
- **Q-R1 (joueur, par le coordinateur)** : les testeurs de la 0.6 ont-ils trouvé Jean-Mi trop présent, pas assez, ou bien dosé ? Défaut : dosage de docs/27 garanti par CA-R5/R6, rien de plus.

## 8. Recette et fusion

- Recette **courte** (décision du joueur du 17/11) : tests + CA ci-dessus + périmètre ; aucune capture (aucun écran touché). Rapport : `docs/lots/lot_08b_recette.md`.
- OK du testeur → push de `lot/08b-logique` → ma validation → fusion `--no-ff` dans `main`, tests relancés sur `main`, push. **Le lot 09-L part de `main` après cette fusion** (il déplace `titres.json` et `rue.json`).

## 9. Compte rendu attendu

Fichiers modifiés (comparés au §3) ; lignes `REFERENCE_PREF` et `REPARTITION` avant / après ; valeurs retenues des paramètres et pourquoi ; lignes `RUE` et `JEANMI` ; ajustements de `rue.json` (le cas échéant) ; durée de `test_titres_mesures` et `test_rue_mesures` ; non vérifié ; base à jour.
