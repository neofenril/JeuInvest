# Recette du mini-lot 03-R (0.4.1), `lot/03-retouches`

## Passage 1 (2026-11-13) : branche `lot/03-retouches`, commit testé 3367af2 : verdict **OK**

Testeur, sans push. Aucun fichier du jeu modifié par moi ; seul `godot/tests/recette/test_recette_dividendes.gd` est adapté (D1 : une seule notification en mai 1986 ; D2 : cas 2 du relevé).

### Anomalies
- Aucune bloquante ni majeure.
- **m1 (mineure, informative)** : le pire cas de D1 (3 titres versants + 1 nul, texte « premier ») fait **exactement 60 mots** (`nb_mots`) : tout ajout au gabarit `dividendes_premier` ou à `dividendes_nul_ajout` dépasse la limite. Le cas réel Elf + Peugeot en fait 54.
- **m2 (mineure, reportée)** : le montant à droite de la notification reste en centimes (« +175,92 F ») face à « 176 F » dans le texte (m3 de 03-I, hors périmètre 03-R, prévu 03-I2).

### Critères d'acceptation
- [x] **CA-R1** `tests.ps1 -Recette` : 742 vérifications, 0 KO, 0 erreur de script (19 étapes, 116 s ; ≥ 725). Sans `-Recette`, le développeur annonce 671 (non rejoué isolément : 742 − 71 de recette). `test_interface` et `test_partie` non modifiés, verts (39 et 8). Import de la copie isolée sans SCRIPT ERROR ni Parse Error.
- [x] **CA-R2** une notification : (a) Elf + Peugeot mai 1986 = 1 notification `dividende`, `premier`, « Un dividende, c'est » + « Peugeot : rien cette année. », `nuls == [{peugeot}]`, 54 mots ; (b) Peugeot seule = 1 `dividende_nul` (17 mots) ; (c) Elf seule = `nuls == []`, sans « rien cette année » (50 mots) ; (d) 1 seule entrée d'historique banque ; pire cas 60 mots. Confirmé aussi par mon test (17/17).
- [x] **CA-R3** relevé, 4 cas lus : (1) « Aucun intérêt cette année : votre argent est resté sur le compte courant, qui ne rapporte rien. » ; (2) « Pas d'intérêts cette année, mais 346 F de dividendes versés par vos actions, après impôt. » + avoir fiscal, sans « Aucun intérêt » ni `releve_dividendes` ; (3) et (4) = texte de `main` ; champs `dividendes`, `interets`, `cls` inchangés ; cas 4 = 45 mots. Cas réel (joueur sans livret + Elf, 1986) : 176 F, identique à la notification. `RECETTE m1 releve_contradiction=false`.
- [x] **CA-R4** `texte_fiche_dividende` : « Dividende : versé en mai, si l'entreprise en distribue cette année-là. » (Elf avant versement et Peugeot 1986) ; « Dividendes reçus : 176 F » après ; vide pour livret, SICAV, PEL, emprunt, assurance-vie ; aucune clé `fiche_*`/`dividendes*` avec « chaque année », « régulier », « toujours ». Le test de recette `test_recette_fiche_dividendes` (affichage actuel de la fiche, inchangé à l'écran) reste vert.
- [x] **CA-R5** graine 7 : 172 139,25 F / 869,97 F / 11 interruptions / dividendes nets 360,43 F ; passif 145 655,67 F ; captures `integrale` (173 s) et `integrale_saut` (136 s) : **161 419 F, 805,93 F, 11 interruptions** chacune ; `test_cadence` : sortie (100 lignes, liste d'interruptions par graine) **identique** à celle de la base d306dec (comparaison ligne à ligne, 0 écart).
- [x] **CA-R6** `project.godot` : une seule ligne (`0.3` → `0.4.1`) ; `export_presets.cfg` : 0.4.1.0 ×2, Android « 0.4.1 » / code 5. **Non vérifié** : `aapt dump badging` (APK non construit depuis le worktree : à faire sur `main`).
- [x] **CA-R7** exe du développeur (110 299 144 octets) lancé par `--main-pack` avec Godot officiel : `--etape=titre` et `--etape=reprise` capturés (code 0), journaux **sans** ERROR ni GrillePixel ni SCRIPT ; image reprise relue (carte du Livret A, HUD cohérent, aucun défaut). Note : sans sauvegarde présente, « reprise » repart du début 1984.
- [x] **CA-R8** périmètre : 8 fichiers, tous au §3 (`etat_partie.gd`, `banquier.gd`, `banque.json`, `test_dividendes.gd`, `project.godot`, `export_presets.cfg`, 2 bases de connaissances) ; rien d'`outils/`, ni capture, ni secret. Contrat : seules lignes retirées = signatures de `notif_dividendes` et `notif_dividende_nul` (paramètres facultatifs ajoutés en fin, compatibles, `test_interface` vert) et le déplacement d'une variable locale du relevé. Aucun recouvrement avec `main` (qui n'a reçu que `docs/10` et `docs/lot_04.md`).
- [x] **CA-R9** étapes jetables dans une copie isolée (`recette_r9`, `recette_r9_tard`, `recette_r9_releve`), PC 1280 × 720 et téléphone 1440 × 648 : mai 1986 (Elf + Peugeot) = **une seule** notification visible, avec l'explication et « Peugeot : rien cette année. » à 1,8 s et à 4 s (elle reste à l'écran), texte sur 7 lignes sans débordement ni coupure, au téléphone aussi ; cartouche « Elf : + 176 F » cohérent. Relevé de janvier 1987 (décembre 1986, sans livret) : phrase du cas 2 présente dans la notification et dans la fenêtre du relevé, PC et téléphone, sans débordement. Chiffres : 176 F partout (notification, cartouche, relevé).

### Non vérifié
- APK : `aapt dump badging` et construction (à faire sur `main`, consigne du coordinateur).
- Lancement réel de l'exe (Smart App Control) ; ressenti sur vrai téléphone.
- Total sans `-Recette` mesuré séparément non rejoué (671 annoncé).

### Preuves et hygiène
- Sauvegarde du joueur : `partie_en_cours.sav` absente avant et après ; `tests.ps1` indique « inchangée ». `user://` des copies isolées supprimés.
- Captures dans le scratchpad (copie isolée), non commitées.