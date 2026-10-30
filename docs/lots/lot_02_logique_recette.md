# Recette du lot 02-L (dev-logique)

## Passage 1 : 2026-10-30, branche `lot/02-logique`, commits 1fba69a → 252f8b0 (testé : 252f8b0), `main` = 972358a

### Verdict : **OK** (aucune anomalie bloquante ni majeure ; 4 mineures, 4 questions)

### Moyens
- `tests.ps1 -Recette -Joueur` dans le worktree `lot02-logique` ; `tests.ps1 -Autocontrole -SansImport`.
- Fusion simulée : worktree jetable détaché sur `main` (972358a) + `merge --no-ff lot/02-logique` (sans conflit), `tests.ps1 -Recette`, export Windows, puis worktree supprimé.
- Copies isolées (`git archive`, `user://` à part) de `main` et de la fusion : partie `integrale` des deux côtés (instrumentée dans la copie pour imprimer la liste des interruptions), `test_demo` des deux côtés, scripts de recette jetables (vraie sauvegarde de format 2 écrite par `main` puis lue par la branche ; cas limites du saut).
- Sauvegarde du joueur (`partie_en_cours.sav`) : absente avant et après, jamais touchée.

### Critères d'acceptation
- [x] **CA-L1** : branche : 9 étapes, **258 vérifications OK, 0 KO, 0 erreur de script**, import propre (cadence 13, demo 107, interface 21, logique 66, mois_utile 22, partie 8, sauvegarde 10, recette 11). Fusion avec `main` : 10 étapes, **335 OK** (dont test_pixel 77), 0 erreur, « TOUT EST PROPRE ». `test_interface.*` et `test_partie.*` absents du diff (inchangés) et verts.
- [x] **CA-L2** (flux) : `test_mois_utile` : 3 graines × 60 mois, écart max revenus 0,0000 F, frais 0,0000 F ; 4 genres présents (interets, coupon, frais, frais_versement) ; relevé de décembre = somme des revenus. Relu dans le code : Livret A, PEL, assurance-vie (acquis, `verse_en_decembre` hors décembre), coupon net d'impôt, gestion de la SICAV, frais de versement ; aucune variation de cours. Voir mineure 1 (dividendes).
- [x] **CA-L3** (saut) : 40 graines, 449 sauts, 409 arrêts sur une modale (40 sur la fin), 583 notifications franchies ; partie identique à celle jouée mois par mois ; retours pause / ×1 / ×3 vérifiés ; `saut_actif` faux à l'émission de `modale_ouverte` ; `non_lues()`/`marquer_lues()` ; impossible en 12/1988, après la fin, fenêtre ouverte, modale en attente ; 2e `arreter_saut()` sans effet. Contrôles à moi : saut lancé en 11/1988 → traverse décembre, `partie_finie` avec `saut_actif` faux et vitesse 0 ; temps bloqué pendant un saut → mois figé, saut toujours actif, repart à la fermeture ; sauvegarde pendant un saut puis reprise → sans saut, même mois.
- [x] **CA-L4** (cadence) : 80 parties (40 graines × actif / passif), 913 interruptions, 11 à 13 par partie (moyenne 11,41) ; liste par graine imprimée ; R-CADENCE, dates imposées, classiques ≤ 15, anticipation : OK. Comparaison avec `main` (`test_demo`, 40 graines passif) : `main` {11 : 29, 12 : 11} moyenne 11,3 → branche {11 : 31, 12 : 9} moyenne 11,2 (deux pannes aléatoires de moins, passées en notification : effet attendu de l'anticipation). Différence de calendrier typique : `main` plaçait D05 en 03/1985, juste avant la naissance de 04/1985 (deux mois de suite, ce que R-CADENCE interdit) ; la branche le repousse (08/1985 ou 01/1985 selon le joueur).
- [x] **CA-L5** (sauvegarde) : `test_sauvegarde` 10 OK (format 2 ignoré, 24 champs retirés × 2 moments → valeurs par défaut et partie jusqu'au bout, reprise sans saut). Contrôle à moi : **vraie** sauvegarde de format 2 écrite par le code de `main`, lue par la branche : `lire()` = {}, `existe()` faux, `charger()` null, aucune ligne d'erreur. Voir mineure 2.
- [x] **CA-L6** (contrat) : lignes `-func` : seulement `_rang`, `_choisir_cadence`, `_avant_cadence` (privées d'`EtatPartie`) ; aucun `-signal` ; `-var` : variables locales seulement ; `-const` : `VERSION_ETAT`/`VERSION` changent de valeur (2 → 3), noms conservés. `banque.json > cadence` déplacé dans `rythme.json > cadence`. Recherche (`git grep`) sur `main`, la branche, `lot/px1-ville` et `lot/px2-interface` : **aucun appelant** de ces fonctions ni de `banque.json > cadence` hors `etat_partie.gd` (ni `scripts/ui`, ni `principal.gd`, ni `scripts/ville`, ni `scripts/outils`). Ajouts conformes au §2.2 (`saut_change`, `saut_actif`, `sauter_jusqu_au_prochain_arret`, `arreter_saut`, `saut_possible`, `flux_du_mois`, `non_lues`, `marquer_lues`, `GENRES_HISTORIQUE`, `SOURCES_HISTORIQUE`, `res["flux"]`, `n["pendant_saut"]`).
- [x] **CA-L7** (outils) : `-Autocontrole` : les 2 erreurs volontaires (script et `ERROR:` du moteur par `push_error`, codes 0) détectées, « AUTOCONTRÔLE RÉUSSI », code 0. `-Recette -Joueur` : `test_recette_decoupage_joueur` lancé avec `-- --joueur` (raccourcis_test=false, 11 OK). Le nouveau motif `^\s*ERROR:` ne fait pas échouer `test_pixel` de `main` (fusion verte).
- [x] **CA-L8** (export) : `Exporter_Windows.bat x` depuis le worktree de fusion avec `JEUCLAUDE_GODOT` : code 0, exe 110 Mo, version de fichier et de produit **0.3.0.0** ; `--etape=titre` capturé (écran titre correct) ; `data/pixel/ville/lefranc.txt` et `data/pixel/ui/cadres.txt` présents dans le paquet. `export_presets.cfg` : filtre `data/*.json, data/pixel/*/*.txt` (Windows et Android), Android `0.3` / code 3. APK non exporté (hors critère).

### Périmètre et fusion
- `git diff main...lot/02-logique --stat` : 25 fichiers, tous attribués au §2.1 (logique, `partie.gd`, `banque.json`, `rythme.json`, tests de la logique, `tests/autocontrole/`, `tests.ps1`, `export_presets.cfg`, bases `developpeur.md` et `dev-logique.md`). Aucun fichier temporaire, capture, secret ni fichier d'`outils/`. `git diff --check` propre.
- Aucun fichier commun avec ce que `main` a reçu depuis la base (a0f6637, PX0) ni avec `lot/px1-ville` et `lot/px2-interface` à cette date : fusion `ort` sans conflit.
- Worktree du développeur : seuls des `polices/*.ttf.import` non suivis (créés par l'import), non commités : normal.

### Non-régression (partie complète)
- `integrale` sur `main` : modales {appel 8, banque 4, courrier 2, journal 1, fin 1}, décembre 1988, **156 645 F**, 11 interruptions, frais **273,60 F** (référence du lot 01 retrouvée).
- `integrale` sur la fusion : mêmes modales, décembre 1988, **160 749 F**, 11 interruptions, frais **805,93 F**.
- **Écart expliqué par la cadence V3, pas par un défaut** : même graine (11). `main` : D01, D02, D03, **D05 03/1985**, naissance 04/1985, **D04 06/1985**, D06 08/1986… ; fusion : D01, D02, D03, naissance 04/1985, **D04 06/1985**, **D05 08/1985**, **D06 11/1985**… Le scénario ouvre une présentation sur deux : sur `main`, la 5e est D04 (assurance-vie achetée), sur la fusion la 5e est D05 (**SICAV** achetée : droits d'entrée et frais de gestion, d'où les frais plus élevés). Nouvelle référence `integrale` après fusion : **160 749 F, frais 805,93 F, 11 interruptions**.

### Anomalies
1. **Mineure : aucune ligne « dividende » dans le flux.** Le moteur ne verse pas de dividendes (commentaire du développeur dans `etat_partie.gd`) ; or docs/15 §1.1 prévoit des pièces « Elf : + 840 F » et la vague 2 (02-V) une étiquette au nom de la ligne pour un dividende. Le genre existe dans le contrat mais ne sera jamais émis. Attendu : décision (boursier / CDP) avant 02-V.
2. **Mineure (test) : `test_sauvegarde` « Sauvegarde pendant un saut … non lues conservées » est vérifié avec 0 non lue** (févr. 1984) : la conservation des non-lues n'est pas réellement éprouvée par ce test (elle l'est indirectement par « état identique après rechargement »). Mon propre essai (saut janv. → mai 1984) donne aussi 0 non lue : aucune notification avant l'été 1984.
3. **Mineure (écart à la lettre de la spec) : après une modale de marché atteinte par un saut, le temps reste en pause** (essai : saut à ×1 depuis 08/1987 → arrêt au krach 10/1987 → après résolution, vitesse 0). docs/15 §1.2 / CA-4.2 et le §2.2 du plan disent « ensuite la vitesse est celle d'avant l'appui » ; le développeur a gardé la règle existante (le krach met en pause, `resoudre_modale` ne rétablit pas la vitesse pour `kind == "marche"`). Cohérent avec l'existant, testé et documenté, mais à trancher.
4. **Mineure (hors branche, à signaler) : le dépôt principal a une modification non commitée de `godot/export_presets.cfg`** (modifié le 30/10 à 12:40, avant le début de ma recette ; contenu identique à celui de la branche : filtre pixel et version 0.3). Quelqu'un a écrit dans `C:\Users\arthu\Documents\temp\JeuClaude` au lieu du worktree. Je n'y ai pas touché. Risque : `git merge` de `lot/02-logique` dans `main` refusé (« would be overwritten ») ; à annuler (`git checkout -- godot/export_presets.cfg`) avant la fusion F1.

### Choix du développeur confrontés à la spec
- **Anticipation étendue aux événements de vie aléatoires** : hors de la lettre de docs/15 §0.1 (qui cite présentation, carte, choix de projet), mais nécessaire à R-CADENCE (une date imposée ne glisse pas : une panne aléatoire au mois m imposerait deux mois de suite avec la naissance en m + 1). Effet mesuré : 2 pannes aléatoires de moins sur 40 graines (passées en notification). Conforme à l'esprit ; à acter.
- **Rang 2,5 de la présentation à sa date limite** : absent de la liste de priorités de docs/15 §0.1 ; placé entre l'échéance de projet (2) et l'événement de vie aléatoire (3), et compté comme « datée » (cohérent avec « date limite d'une présentation non faite » de l'anticipation). Pas de contradiction. Changement notable : les interruptions datées ne contournent plus l'écart de 2 mois (sur `main`, historique / scripté / date limite passaient toujours) ; seules marché → panne y échappent. 80 parties : dates imposées toujours tenues ; zone fragile quand les cartes et projets (lots 03-04) rempliront le calendrier.
- **Saut en 11/1988 jusqu'à la fin** : docs/15 §1.2 dit seulement « inactif en décembre 1988 » (on ne peut pas le lancer en décembre) ; un saut lancé en novembre traverse décembre et s'arrête sur la fin (relevé intégré à la fin, calendrier §9). Pas de contradiction.
- **Pause après une modale de marché** : contredit la lettre (anomalie 3).
- **`changer_vitesse` / `basculer_pause` arrêtent le saut** : la spec ne parle que d'un « nouvel appui » sur le bouton ; reprendre la main par les vitesses est raisonnable. `basculer_pause` pendant un saut → pause (et non la vitesse d'avant). Pas de contradiction ; à confirmer par l'UX pour 02-I.
- Temps bloqué (fenêtre ouverte) pendant un saut : le saut reste actif, figé, et reprend à la fermeture (spec : bouton inactif fenêtre ouverte ; le cas « fenêtre ouverte pendant le saut » n'est pas décrit).

### Questions pour le chef de projet
1. Dividendes : le moteur doit-il en verser (Elf, Saint-Gobain) pour la vague 2, ou retire-t-on la pièce « Elf : + 840 F » de 02-V ?
2. Modale de marché pendant un saut : pause (existant) ou vitesse d'avant l'appui (lettre de CA-4.2) ?
3. Accepter l'extension de l'anticipation aux événements de vie et la fin d'écart automatique pour les dates historiques ?
4. Qui a modifié `export_presets.cfg` dans le dépôt principal (anomalie 4) ?

### Non vérifié
- Rendu : rien de visible dans ce lot (pas de captures d'écrans touchés, à part l'écran titre de l'exe).
- Export Android (APK) et vrai téléphone.
- Ressenti du saut en mouvement (aucune interface encore : 02-I).
