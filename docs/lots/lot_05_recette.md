# Lot 05 : recette du testeur

## 05-L (rue et krach) : passage 1, 2026-11-14, branche `lot/05-logique`, commit testÃ© 9ed6149

**Verdict : KO** (1 anomalie majeure : une barre de Â« Le krach, un an aprÃ¨s Â» est fausse face au moteur rÃ©el).

### RÃ©sultats
- `tests.ps1 -Recette` : **981 vÃ©rifications OK, 1 KO, 0 erreur de script, import propre** (rÃ©fÃ©rence `main` 831). Le KO est **mon** test `test_recette_dividendes` (constantes de mai 1987 pÃ©rimÃ©es par D5 : Peugeot 700 F en 05/1987 â†’ total 540,62 F au lieu de 532,27 F ; recalcul Ã  la main = moteur au centime) : constantes mises Ã  jour dans mon test (`godot/tests/recette/`), pas une anomalie du jeu.
- Nouveau test de recette `godot/tests/recette/test_recette_rue.gd` (42 vÃ©rifications indÃ©pendantes de celles du dÃ©veloppeur) : 39 OK, 3 KO (tous = anomalie A1).
- PÃ©rimÃ¨tre (`git diff main...lot/05-logique --stat`) : 24 fichiers, tous dans la colonne 05-L du plan (modules `quartier`/`krach`, donnÃ©es, `etat_partie`, `cadence`, `bilan`, `projets`, `strategie_test`, tests existants adaptÃ©s, bases de connaissances). Aucun `test_interface` / `test_partie`, aucun fichier temporaire. Mineur : `tests/test_rue_moteur.gd(.uid)` est un nouveau test absent de la liste nominative du Â§3 (mÃªme propriÃ©taire, sans consÃ©quence).
- `partie_en_cours.sav` du joueur : absent avant et aprÃ¨s (non touchÃ©). Aucun Godot d'autrui fermÃ©.

### Anomalie
**A1 (majeure) : barre Â« Tout vendu Â» de Â« Le krach, un an aprÃ¨s Â» trop basse d'un mois d'intÃ©rÃªts du Livret A.**
- Reproduire : graine 7, rue allumÃ©e, aucune action au krach (exemple de 10 000 F de SICAV) â†’ modale gazette 10/1988. MÃªme chose avec un portefeuille SICAV + Elf + Peugeot (graines 3 et 12, choix Â« vendre Â»).
- Attendu : ce que donne rÃ©ellement le moteur si l'on vend au krach (10/1987) et place au Livret A : l'argent reÃ§oit les intÃ©rÃªts des fins de mois 10/1987 Ã  09/1988 (12 mois, `_fin_de_mois`), soit **10 453,80 F** pour 10 000 F (docs/26 : â‰ˆ 10 450 F). MesurÃ© en jouant les deux parties (avec et sans 10 000 F au Livret Ã  l'ouverture du krach) : 10 453,80 F.
- ConstatÃ© : **10 415,03 F** (Ã©cart âˆ’38,77 F ; âˆ’54,22 F sur un portefeuille de 14 568 F). Cause : `EtatPartie.ctx_gazette` boucle `for mm in range(ab_k + 1, a)` et saute le mois 10/1987 ; il faut `range(ab_k, a)` pour les intÃ©rÃªts du Livret (la boucle des dividendes, elle, est bonne : tous en mai). Â« Rien fait Â» (14 459,20 F) et Â« RenforcÃ© Â» (21 544,20 F) sont exacts au centime face au moteur (SICAV, et lignes SICAV + Elf + Peugeot avec dividendes et achats rÃ©els), la barre entourÃ©e suit le choix rÃ©el.
- Les tests du dÃ©veloppeur ne le voient pas (ils recalculent avec la mÃªme boucle). Correction Ã  faire cÃ´tÃ© logique ; mon `test_recette_rue.gd` passera dÃ¨s que c'est corrigÃ©. GravitÃ© : un chiffre pÃ©dagogique affichÃ© est faux de 0,4 % (l'ordre des barres et la leÃ§on ne changent pas) ; classÃ© majeur par la rÃ¨gle Â« chiffre faux Â».

### CritÃ¨res (CA-R, â˜… obligatoires)
- [x] CA-R1 â˜… : suite verte (hors mon test pÃ©rimÃ©, corrigÃ©), 0 erreur de script ; diff `test_interface`/`test_partie` vide.
- [x] CA-R2 â˜… J1/J2 sur 120 vraies parties (40 graines Ã— passif, actif, tout-Peugeot, mon propre code) : J1 tenu, marge minimale **5 125 F en 09/1987** ; J2 : Jean-Mi Ã  â‰¤ 33,1 % du patrimoine de Tata (Ã©cart â‰¥ 66,9 %) en 12/1988, toujours dernier, Matelas derriÃ¨re Tata. Joueur passif : le joueur repasse devant Jean-Mi en **10/1987 (40/40)** ; Jean-Mi passe devant au plus tard en 10/1986 (27/40 en 10/1986 ; 13/40 dÃ¨s 01/1986 parce que ces joueurs Â« dÃ©pensiers Â» ont dÃ©jÃ  un patrimoine infÃ©rieur au miroir : ce n'est pas liÃ© Ã  la rue) ; notification de rang Â« perte Â» en 10 ou 11/1986, Â« gain Â» en 12/1987. Tata derriÃ¨re Jean-Mi de 03 Ã  09/1987 (= J1). **Ã‰cart signalÃ©** : `couverture_min` = 30 000 F (la couverture est le plus grand de 80 % du compte et 30 000 F), non prÃ©vu par D4 ; sans lui J1 Ã©choue 26 fois sur 40 ; Ã  faire valider par le chef de projet.
- [x] CA-R3 â˜… (miroir) : vÃ©rifiÃ© par le dÃ©veloppeur (40 graines, au franc prÃ¨s jusqu'en 08/1986) et recoupÃ© par mes mesures de diffÃ©rences avec Tonton Matelas (aucun Ã©cart inexpliquÃ©).
- [x] CA-R4 â˜… levier : couverture + dette = perte (phrase calculÃ©e, recalcul dans le test du dÃ©veloppeur, relu).
- [x] CA-R5 â˜… notifications (120 parties, mon code) : â‰¤ 1 voisin / 2 mois, â‰¤ 1 rue ou kiosque / mois, aucune un mois de pause, rang â‰¥ 6 mois d'Ã©cart et pas avant 10/1986, kiosque Ã  sa date ou +1 mois sinon absent (559 titres absents sur 1 320, soit 42 %, Ã  connaÃ®tre), les 5 â˜… toujours dans l'historique (genre voisin, source rue) ; **saut COURRIER** (5 graines, `Partie`) : mÃªmes notifications que pas Ã  pas, 5 â˜… prÃ©sentes. Passages non â˜… abandonnÃ©s : 0,53 par partie.
- [x] CA-R6 â˜… : aucun Â« achetez / vendez / c'est le moment / auriez dÃ» Â» (seule occurrence : un commentaire `_note` de `krach.json`) ; vouvoiement partout, y compris Tata et Jean-Mi ; aucun achat Ã  crÃ©dit cÃ´tÃ© joueur (non modifiÃ©).
- [x] CA-R7 (OK au passage 2) â˜… : 10/1988 dans 120 parties sur 120 (genre gazette, source media) âœ“ ; barres Â« Rien fait Â» et Â« RenforcÃ© Â» exactes âœ“ ; **Â« Tout vendu Â» âœ— (A1)**.
- [x] CA-R8 â˜… : 7 jours (1 240 / 1 119,7 / 1 050 / 1 085 / 1 045 / 1 020 / 990), variations recalculÃ©es âˆ’9,7 âˆ’6,2 +3,3 âˆ’3,7 âˆ’2,4 âˆ’2,9, certitudes A A C C C C C ; aucune autre modale n'en porte ; rue Ã©teinte : absent.
- [x] CA-R9 â˜… : rue Ã©teinte par dÃ©faut (`rue.json > actif = false`, `config_demo` sans clÃ© `rue` ; `principal._config()` n'allume rien dans ce lot, c'est 05-I) : aucune notification rue, pas de gazette ; graine 7 actif **172 139,25 F / 870,08 F / 11 interruptions** ; allumer la rue ne change pas le patrimoine du joueur passif (12 graines). Seules rÃ©fÃ©rences changÃ©es : frais 870,08 F (au lieu de 869,97 F : la gestion de la SICAV suit l'indice 1988-10 = 1 470) et cours Peugeot des cas 100/117/118 de `test_logique` ; explications cohÃ©rentes (le patrimoine ne bouge pas).
- [x] CA-R10 â˜… : sauvegarde en 11/1986 et 11/1987 puis reprise : Jean-Mi, quartier, instantanÃ© identiques, mÃªme fin ; sauvegarde allumÃ©e amputÃ©e de l'instantanÃ© et de clÃ©s du quartier : se recharge et finit. **Vraies sauvegardes de `main` (d70dba7, Ã©crites par sa propre copie, 3 cas : 06/1986 actif, 06/1987 passif, 12/1987 actif)** : se rechargent, rue Ã©teinte, aucune notification de la rue, vont Ã  la fin avec exactement les chiffres de `main` (76 384,89 F / 604,92 F / 13 ; 36 443,63 F / 0 F / 11).
- [x] CA-R11 : contrat Â§4.3 prÃ©sent (accesseurs, notifications, `jours`, gazette, bilan) ; aucune ligne `func/signal/var/const` d'un nom existant supprimÃ©e.
- [x] CA-R12 â˜… : pÃ©rimÃ¨tre OK.
- Patrimoine de Jean-Mi (point 4) âœ“ : voiture comptÃ©e, jamais d'Ã©quitÃ© nÃ©gative ; achat de la Porsche neutre ; en 10/1987 la baisse = perte + dÃ©cote + intÃ©rÃªts du crÃ©dit (dette comptÃ©e **une** fois) ; 12/1988 voiture vendue, crÃ©dit soldÃ© (40 graines).
- Bilan (point 8) âœ“ : `rue` = classement (4 lignes), `replique_rue` = voisin juste devant, sinon juste derriÃ¨re, bon texte ; vide rue Ã©teinte. Avec les 40 graines seules les rÃ©pliques de Tata ont Ã©tÃ© rencontrÃ©es (celle de Jean-Mi n'apparaÃ®t pas : le joueur n'est jamais derriÃ¨re lui en fin de partie, cohÃ©rent avec J2).

### Non vÃ©rifiÃ©
Rien Ã  l'Ã©cran (lot 06) ; textes `_provisoire` non relus par le game designer ; durÃ©e des tests jamais mesurÃ©e en charge (aucun seuil en cause ici).

### Mineures
- M1 : 42 % des titres de kiosque absents en moyenne (budget serrÃ©) : le joueur en verra ~6 sur 11.
- M2 : un joueur dÃ©pensier (13 graines) est dÃ©jÃ  derriÃ¨re Jean-Mi (miroir) avant 10/1986 ; le message de rang n'arrive qu'en 10/1986 ou 11/1986.
- M3 : le worktree contient des modifications non commitÃ©es Ã©trangÃ¨res (`docs/25_banquier_projets_textes.md`, `docs/connaissances/banquier.md`) : pas de moi.

## 05-L (rue et krach) : passage 2, 2026-11-14, branche `lot/05-logique`, commit testÃ© da3000f

**Verdict : OK.**

- A1 corrigÃ©e : `ctx_gazette` boucle du Livret en `range(ab_k, a)`. Mon test `test_recette_rue` (recalcul indÃ©pendant, contre le moteur rÃ©el de deux parties jumelles) : **42/42**. Exemple 10 000 F : Â« Tout vendu Â» = **10 453,80 F** (moteur 10 453,80 F ; docs/26 â‰ˆ 10 450), Â« Rien fait Â» 14 459,20 F et Â« RenforcÃ© Â» 21 544,20 F inchangÃ©s au centime. Portefeuilles de 14 568 F (graines 3 et 12) : barres Ã©gales Ã  l'Ã©tat rÃ©el du moteur (tests 3 lignes de mon test).
- `tests.ps1 -Recette` : **25 Ã©tapes, 1 028 vÃ©rifications OK, 0 KO, 0 erreur de script, aucun Parse Error**, 207,9 s. `test_recette_dividendes` 17/17 (constantes 540,62 F de mai 1987 Ã  jour).
- Diff de da3000f : `etat_partie.gd`, `data/rue.json`, `tests/test_rue_moteur.gd` seulement.
- RÃ©fÃ©rences Ã©teintes inchangÃ©es (graine 7, joueur actif) : 172 139,25 F / 870,08 F / 11 interruptions.
- B8 : `rue.json > etapes_jeanmi` (5 libellÃ©s), `jeanmi_resume()["etape_texte"]` non vide aux 5 Ã©tapes, vide rue Ã©teinte ; test de vouvoiement de `temoins.json` vert.
- `couverture_min` = 30 000 F : Ã©cart consignÃ©, validÃ© par le chef de projet (non rouvert).
- `partie_en_cours.sav` du joueur : absent avant et aprÃ¨s. Aucun Godot d'autrui touchÃ©. 120 parties non refaites (aucun doute : seul le calcul d'une barre a changÃ©).
- CA-R7 maintenant cochÃ© (les trois barres exactes). Les mineures M1 Ã  M3 du passage 1 restent valables (M3 : modifications non commitÃ©es Ã©trangÃ¨res sur docs/25 et connaissances/banquier.md, que je n'ai pas commitÃ©es).

