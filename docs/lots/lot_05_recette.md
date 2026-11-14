# Lot 05 : recette du testeur

## 05-L (rue et krach) : passage 1, 2026-11-14, branche `lot/05-logique`, commit testé 9ed6149

**Verdict : KO** (1 anomalie majeure : une barre de « Le krach, un an après » est fausse face au moteur réel).

### Résultats
- `tests.ps1 -Recette` : **981 vérifications OK, 1 KO, 0 erreur de script, import propre** (référence `main` 831). Le KO est **mon** test `test_recette_dividendes` (constantes de mai 1987 périmées par D5 : Peugeot 700 F en 05/1987 → total 540,62 F au lieu de 532,27 F ; recalcul à la main = moteur au centime) : constantes mises à jour dans mon test (`godot/tests/recette/`), pas une anomalie du jeu.
- Nouveau test de recette `godot/tests/recette/test_recette_rue.gd` (42 vérifications indépendantes de celles du développeur) : 39 OK, 3 KO (tous = anomalie A1).
- Périmètre (`git diff main...lot/05-logique --stat`) : 24 fichiers, tous dans la colonne 05-L du plan (modules `quartier`/`krach`, données, `etat_partie`, `cadence`, `bilan`, `projets`, `strategie_test`, tests existants adaptés, bases de connaissances). Aucun `test_interface` / `test_partie`, aucun fichier temporaire. Mineur : `tests/test_rue_moteur.gd(.uid)` est un nouveau test absent de la liste nominative du §3 (même propriétaire, sans conséquence).
- `partie_en_cours.sav` du joueur : absent avant et après (non touché). Aucun Godot d'autrui fermé.

### Anomalie
**A1 (majeure) : barre « Tout vendu » de « Le krach, un an après » trop basse d'un mois d'intérêts du Livret A.**
- Reproduire : graine 7, rue allumée, aucune action au krach (exemple de 10 000 F de SICAV) → modale gazette 10/1988. Même chose avec un portefeuille SICAV + Elf + Peugeot (graines 3 et 12, choix « vendre »).
- Attendu : ce que donne réellement le moteur si l'on vend au krach (10/1987) et place au Livret A : l'argent reçoit les intérêts des fins de mois 10/1987 à 09/1988 (12 mois, `_fin_de_mois`), soit **10 453,80 F** pour 10 000 F (docs/26 : ≈ 10 450 F). Mesuré en jouant les deux parties (avec et sans 10 000 F au Livret à l'ouverture du krach) : 10 453,80 F.
- Constaté : **10 415,03 F** (écart −38,77 F ; −54,22 F sur un portefeuille de 14 568 F). Cause : `EtatPartie.ctx_gazette` boucle `for mm in range(ab_k + 1, a)` et saute le mois 10/1987 ; il faut `range(ab_k, a)` pour les intérêts du Livret (la boucle des dividendes, elle, est bonne : tous en mai). « Rien fait » (14 459,20 F) et « Renforcé » (21 544,20 F) sont exacts au centime face au moteur (SICAV, et lignes SICAV + Elf + Peugeot avec dividendes et achats réels), la barre entourée suit le choix réel.
- Les tests du développeur ne le voient pas (ils recalculent avec la même boucle). Correction à faire côté logique ; mon `test_recette_rue.gd` passera dès que c'est corrigé. Gravité : un chiffre pédagogique affiché est faux de 0,4 % (l'ordre des barres et la leçon ne changent pas) ; classé majeur par la règle « chiffre faux ».

### Critères (CA-R, ★ obligatoires)
- [x] CA-R1 ★ : suite verte (hors mon test périmé, corrigé), 0 erreur de script ; diff `test_interface`/`test_partie` vide.
- [x] CA-R2 ★ J1/J2 sur 120 vraies parties (40 graines × passif, actif, tout-Peugeot, mon propre code) : J1 tenu, marge minimale **5 125 F en 09/1987** ; J2 : Jean-Mi à ≤ 33,1 % du patrimoine de Tata (écart ≥ 66,9 %) en 12/1988, toujours dernier, Matelas derrière Tata. Joueur passif : le joueur repasse devant Jean-Mi en **10/1987 (40/40)** ; Jean-Mi passe devant au plus tard en 10/1986 (27/40 en 10/1986 ; 13/40 dès 01/1986 parce que ces joueurs « dépensiers » ont déjà un patrimoine inférieur au miroir : ce n'est pas lié à la rue) ; notification de rang « perte » en 10 ou 11/1986, « gain » en 12/1987. Tata derrière Jean-Mi de 03 à 09/1987 (= J1). **Écart signalé** : `couverture_min` = 30 000 F (la couverture est le plus grand de 80 % du compte et 30 000 F), non prévu par D4 ; sans lui J1 échoue 26 fois sur 40 ; à faire valider par le chef de projet.
- [x] CA-R3 ★ (miroir) : vérifié par le développeur (40 graines, au franc près jusqu'en 08/1986) et recoupé par mes mesures de différences avec Tonton Matelas (aucun écart inexpliqué).
- [x] CA-R4 ★ levier : couverture + dette = perte (phrase calculée, recalcul dans le test du développeur, relu).
- [x] CA-R5 ★ notifications (120 parties, mon code) : ≤ 1 voisin / 2 mois, ≤ 1 rue ou kiosque / mois, aucune un mois de pause, rang ≥ 6 mois d'écart et pas avant 10/1986, kiosque à sa date ou +1 mois sinon absent (559 titres absents sur 1 320, soit 42 %, à connaître), les 5 ★ toujours dans l'historique (genre voisin, source rue) ; **saut COURRIER** (5 graines, `Partie`) : mêmes notifications que pas à pas, 5 ★ présentes. Passages non ★ abandonnés : 0,53 par partie.
- [x] CA-R6 ★ : aucun « achetez / vendez / c'est le moment / auriez dû » (seule occurrence : un commentaire `_note` de `krach.json`) ; vouvoiement partout, y compris Tata et Jean-Mi ; aucun achat à crédit côté joueur (non modifié).
- [ ] CA-R7 ★ : 10/1988 dans 120 parties sur 120 (genre gazette, source media) ✓ ; barres « Rien fait » et « Renforcé » exactes ✓ ; **« Tout vendu » ✗ (A1)**.
- [x] CA-R8 ★ : 7 jours (1 240 / 1 119,7 / 1 050 / 1 085 / 1 045 / 1 020 / 990), variations recalculées −9,7 −6,2 +3,3 −3,7 −2,4 −2,9, certitudes A A C C C C C ; aucune autre modale n'en porte ; rue éteinte : absent.
- [x] CA-R9 ★ : rue éteinte par défaut (`rue.json > actif = false`, `config_demo` sans clé `rue` ; `principal._config()` n'allume rien dans ce lot, c'est 05-I) : aucune notification rue, pas de gazette ; graine 7 actif **172 139,25 F / 870,08 F / 11 interruptions** ; allumer la rue ne change pas le patrimoine du joueur passif (12 graines). Seules références changées : frais 870,08 F (au lieu de 869,97 F : la gestion de la SICAV suit l'indice 1988-10 = 1 470) et cours Peugeot des cas 100/117/118 de `test_logique` ; explications cohérentes (le patrimoine ne bouge pas).
- [x] CA-R10 ★ : sauvegarde en 11/1986 et 11/1987 puis reprise : Jean-Mi, quartier, instantané identiques, même fin ; sauvegarde allumée amputée de l'instantané et de clés du quartier : se recharge et finit. **Vraies sauvegardes de `main` (d70dba7, écrites par sa propre copie, 3 cas : 06/1986 actif, 06/1987 passif, 12/1987 actif)** : se rechargent, rue éteinte, aucune notification de la rue, vont à la fin avec exactement les chiffres de `main` (76 384,89 F / 604,92 F / 13 ; 36 443,63 F / 0 F / 11).
- [x] CA-R11 : contrat §4.3 présent (accesseurs, notifications, `jours`, gazette, bilan) ; aucune ligne `func/signal/var/const` d'un nom existant supprimée.
- [x] CA-R12 ★ : périmètre OK.
- Patrimoine de Jean-Mi (point 4) ✓ : voiture comptée, jamais d'équité négative ; achat de la Porsche neutre ; en 10/1987 la baisse = perte + décote + intérêts du crédit (dette comptée **une** fois) ; 12/1988 voiture vendue, crédit soldé (40 graines).
- Bilan (point 8) ✓ : `rue` = classement (4 lignes), `replique_rue` = voisin juste devant, sinon juste derrière, bon texte ; vide rue éteinte. Avec les 40 graines seules les répliques de Tata ont été rencontrées (celle de Jean-Mi n'apparaît pas : le joueur n'est jamais derrière lui en fin de partie, cohérent avec J2).

### Non vérifié
Rien à l'écran (lot 06) ; textes `_provisoire` non relus par le game designer ; durée des tests jamais mesurée en charge (aucun seuil en cause ici).

### Mineures
- M1 : 42 % des titres de kiosque absents en moyenne (budget serré) : le joueur en verra ~6 sur 11.
- M2 : un joueur dépensier (13 graines) est déjà derrière Jean-Mi (miroir) avant 10/1986 ; le message de rang n'arrive qu'en 10/1986 ou 11/1986.
- M3 : le worktree contient des modifications non commitées étrangères (`docs/25_banquier_projets_textes.md`, `docs/connaissances/banquier.md`) : pas de moi.
