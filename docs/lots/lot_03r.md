# Mini-lot 03-R « 0.4.1, les dividendes » : une notification par mois, relevé sans contradiction, version 0.4.1

> Chef de projet, 2026-11-12. Base : `main` 580c7cc (lot 03 fusionné, `tests.ps1 -Recette` 725 vérifications vertes).
> Origine : `feuille_de_route.md` §2.8 (reports 2, 3, 6 ; mini-lot 03-R) ; `lot_03_recette.md` (03-I passage 1 : m1, m2) ; textes du banquier `docs/22_textes_banquier_dividendes_bis.md` (arrivés le 12/11).
> Un seul développeur : **dev-logique**, branche `lot/03-retouches`, worktree `C:\Users\arthu\Documents\temp\JeuClaude_lots\lot03-retouches`. Durée visée : une demi-journée. **Passe avant 04-L et 03-I2** (mêmes fichiers ou API utilisée).

## 0. Ce que le joueur verra (0.4.1)
- Un mois de mai où un titre verse et un autre non (Elf et Peugeot en mai 1986) : **une seule** notification de la banque, qui explique ce qu'est un dividende **et** dit que Peugeot n'a rien versé. Au téléphone, l'explication ne disparaît plus sans être lue.
- Le relevé de décembre ne dit plus « Aucun intérêt cette année : votre argent est resté sur le compte courant » à un joueur dont les actions viennent de verser des dividendes.
- Version 0.4.1 (exe et APK). La fiche des actions ne change pas encore à l'écran (03-I2 branche le nouveau texte, §2 D4).

Hors périmètre : la fiche de la fenêtre Banque (03-I2) ; les montants à droite des notifications en centimes (m3 de 03-I, 03-I2) ; la bulle « intérêt / dividende » de docs/22 §2 (au client, plus tard) ; les textes du foyer de docs/22 §3 (04-L, avec G1).

## 1. Mise en place (coordinateur)
```powershell
$git = "C:\Users\arthu\Documents\temp\JeuClaude\outils\git\cmd\git.exe"
$depot = "C:\Users\arthu\Documents\temp\JeuClaude"
$lots = "C:\Users\arthu\Documents\temp\JeuClaude_lots"
# main contient ce plan, lot_04.md, docs/22 et docs/23 (commit du chef de projet au-dessus de 580c7cc)
& $git -C $depot worktree add -b lot/03-retouches "$lots\lot03-retouches" main
```
- Commits locaux en français, un par tâche, `tests.ps1` vert avant chaque commit, aucun push avant l'OK du testeur. Ne jamais écrire `partie_en_cours.sav`.
- Avant de modifier quoi que ce soit : relever le total de `tests.ps1` (sans `-Recette`) sur la branche neuve et l'écrire dans le compte rendu (référence « avant »).

## 2. Décisions du chef de projet

| # | Sujet | Décision |
|---|---|---|
| D1 | Une notification de dividende par mois (report 3, m2 de 03-I) | Dans `EtatPartie._verser_dividendes` : si au moins un titre verse **et** au moins un titre détenu est en année `divNul`, **une seule** notification `type "dividende"` ; son texte = texte habituel (`dividendes_premier` ou `dividendes`) suivi du nouveau gabarit `dividendes_nul_ajout` = « ` {noms} : rien cette année.` » ({noms} = noms courts joints par « et ») ; nouveau champ `"nuls": [{"id", "nom"}]` (vide sinon, toujours présent). Si **aucun** titre ne verse et qu'au moins un est en `divNul` : **une seule** notification `dividende_nul` (inchangée ; si plusieurs titres, {nom} = noms joints par « et », texte au singulier accepté : un seul titre a `divNul` dans les données). `Banquier.notif_dividende_nul` reste (appelée par `test_interface`) ; nouveau paramètre facultatif en fin de signature seulement. |
| D2 | Relevé (report 6, docs/22 §2) | Quatre cas, une phrase par cas : (1) 0 intérêt, 0 dividende : `releve_sans_interets` remplacé par « Aucun intérêt cette année : votre argent est resté sur le compte courant, qui ne rapporte rien. » ; (2) 0 intérêt, dividendes > 0 : **une seule phrase**, nouvelle clé `releve_dividendes_sans_interets` = « Pas d'intérêts cette année, mais {dividendes} de dividendes versés par vos actions, après impôt. » (variante sobre de docs/22 §2, choisie : plus courte, sans « aucun intérêt » répété), **sans** `releve_dividendes` ensuite ; (3) intérêts > 0, 0 dividende : inchangé ; (4) les deux : inchangé (intérêts puis `releve_dividendes`). La phrase de l'avoir fiscal (1re année avec dividendes) suit dans les cas 2 et 4, comme aujourd'hui. `cls` et champs du relevé inchangés. |
| D3 | Textes | Dans `banque.json > messages`, provisoires = textes de ce tableau (docs/22 pour le relevé et la fiche ; `dividendes_nul_ajout` écrit par le chef de projet, à relire par le banquier). Tous ≤ 60 mots une fois assemblés, aucun « → », espaces insécables de `Format`. Mettre à jour la clé de commentaire `_dividendes`. |
| D4 | Phrase de la fiche (report 2, docs/22 §1, option recommandée) | **Préparée ici, affichée en 03-I2** : nouvelle statique `Banquier.texte_fiche_dividende(e: EtatPartie, id: String) -> String` : `""` si `id` n'est pas une action ; « Dividendes reçus : {montant} » (`Format.entier`) si `e.dividendes_recus(id) > 0` ; sinon `fiche_dividende` = « Dividende : versé en {mois}, si l'entreprise en distribue cette année-là. » ({mois} = `Dates.MOIS[mois_dividende(id) − 1]`). Clés `fiche_dividende`, `fiche_dividendes_recus` dans `banque.json`. Aucune variante par titre (docs/22 §1 : ne pas révéler l'avenir d'un titre). `panneau_banque.gd` n'est **pas** touché dans ce lot. |
| D5 | Version | `project.godot` : **seulement** la ligne `config/version="0.4.1"` (prêtée à dev-logique pour ce mini-lot ; elle valait encore « 0.3 »). `export_presets.cfg` : Windows `application/file_version` et `product_version` = `"0.4.1.0"` ; Android `version/name="0.4.1"`, `version/code=5`. |
| D6 | Exports | Le développeur **construit** l'exe et l'APK depuis son worktree pour vérifier (`JEUCLAUDE_GODOT` défini ; l'APK : `Exporter_Android.bat` cherche JDK et SDK dans `outils\` du dossier du .bat → s'il échoue depuis le worktree, le dire, pas de contournement). Les exports livrés au joueur sont refaits par le coordinateur **sur `main` après la fusion**. Smart App Control bloque le lancement d'un exe neuf non signé sur cette machine : la vérification se fait par `--main-pack` (Godot officiel) ; le joueur lance lui-même l'exe. |

## 3. Carte de propriété (03-R)
Chemins relatifs à `godot/`. **Un fichier absent est interdit.**

| Fichiers | dev-logique (03-R) |
|---|---|
| `scripts/logique/etat_partie.gd`, `scripts/logique/banquier.gd` | oui |
| `data/banque.json` | oui |
| `tests/test_dividendes.*`, `tests/test_logique.*` (test des messages, si besoin) | oui |
| `project.godot` : **la seule ligne `config/version`** (prêt) | oui |
| `export_presets.cfg` (versions seulement) | oui |
| `docs/connaissances/developpeur.md` (socle), `docs/connaissances/dev-logique.md` | oui |
| `tests/recette/`, `docs/lots/lot_03r_recette.md` | testeur |

Interdits : `test_interface`, `test_partie`, `scripts/ui/*`, tout le reste. Contrat : ajouts seulement (rien de retiré ni renommé dans `Partie`, `EtatPartie`, `Banquier`).

## 4. Tâches (dans cet ordre)
1. **R1 (D1)** : fusion des notifications ; test.
2. **R2 (D2, D3)** : relevé en 4 cas ; test.
3. **R3 (D4)** : `Banquier.texte_fiche_dividende` + clés ; test.
4. **R4 (D5, D6)** : versions ; exe et APK construits depuis le worktree.
5. Socle (section Dividendes : notification unique, `nuls`, relevé à 4 cas, `texte_fiche_dividende`, version 0.4.1 / code 5), base, compte rendu.

## 5. Critères d'acceptation (testeur, `docs/lots/lot_03r_recette.md`)
- **CA-R1 (tests)** : `tests.ps1` vert, 0 erreur de script, total ≥ « avant » + nouvelles vérifications. `test_interface` et `test_partie` inchangés et verts. **Le testeur adapte d'abord ses tests de recette** qui attendent deux notifications en mai 1986 (`tests/recette/test_recette_dividendes.gd` l. 159-177) : c'est le changement voulu (D1) ; puis `tests.ps1 -Recette` vert, total ≥ 725.
- **CA-R2 (une notification, D1)** : `test_dividendes` : (a) Elf et Peugeot détenues en avril 1986, passage à mai 1986 : **exactement une** notification de type `dividende` ou `dividende_nul` dans le mois ; elle est de type `dividende`, `premier = true`, son texte contient « Un dividende, c'est » **et** « Peugeot : rien cette année », `nuls == [{"id": "peugeot", "nom": "Peugeot"}]` ; (b) Peugeot seule en mai 1986 : une seule notification, `dividende_nul` ; (c) Elf seule : `nuls == []`, texte sans « rien cette année » ; (d) une seule entrée d'historique banque pour le mois (a). Textes assemblés ≤ 60 mots dans les cas (a), (b), (c) et dans le pire cas fabriqué (3 titres versants + 1 nul, texte « premier »).
- **CA-R3 (relevé, D2)** : relevé fabriqué dans les 4 cas : cas 2 = la phrase `releve_dividendes_sans_interets` seule (et l'avoir fiscal la 1re année), **jamais** « Aucun intérêt cette année » ni la phrase `releve_dividendes` en plus ; cas 1 = nouveau texte ; cas 3 et 4 = texte de `main`. `n["dividendes"]`, `n["interets"]`, `cls` inchangés. Montant de la phrase = `Format.entier` du net de l'année.
- **CA-R4 (fiche, D4)** : `texte_fiche_dividende` : « Dividende : versé en mai, si l'entreprise en distribue cette année-là. » pour Elf avant tout versement et pour Peugeot en 1986 ; « Dividendes reçus : … F » = `Format.entier(dividendes_recus(id))` après ; `""` pour livret, SICAV, PEL, emprunt, assurance-vie ; aucune clé `fiche_*` ni `dividendes*` ne contient « chaque année », « régulier » ou « toujours » (docs/22 §1).
- **CA-R5 (non-régression)** : graine 7 (`StrategieTest` actif) à fin 1988 : 172 139,25 F, 869,97 F de frais, 11 interruptions, 360,43 F de dividendes ; passif 145 655,67 F ; captures `integrale` = `integrale_saut` = **161 419 F, 805,93 F, 11 interruptions** ; `test_cadence` identique à `main` (aucune interruption de plus ni de moins).
- **CA-R6 (version)** : `git diff main...lot/03-retouches -- godot/project.godot` = la seule ligne `config/version` ; `export_presets.cfg` : 0.4.1.0 (Windows, 2 lignes), « 0.4.1 » / code 5 (Android). APK construit : `aapt dump badging` → `versionCode='5' versionName='0.4.1'`.
- **CA-R7 (exe)** : exe construit depuis le worktree ; Godot officiel `--main-pack <exe>` : `--etape=titre` et `--etape=reprise` capturés, journal **sans** ligne `ERROR` ni `GrillePixel` ; images relues.
- **CA-R8 (périmètre)** : `git diff main...lot/03-retouches --stat` : fichiers du §3 seulement ; contrat : aucune ligne `-func`, `-signal`, `-var`, `-const` d'un nom existant retirée ou renommée.
- **CA-R9 (à l'écran)** : étape jetable du testeur (comme `recette_nul` du lot 03), téléphone 1440 × 648 et PC 1280 × 720, mai 1986 avec Elf et Peugeot : une seule notification visible, avec l'explication et « Peugeot : rien cette année » ; relevé de décembre 1986 d'un joueur sans livret avec Elf (ou fabriqué) relu.

## 6. Après l'OK du testeur
Push de la branche, ma validation, fusion `--no-ff` dans `main`, `tests.ps1 -Recette` sur `main` (≥ total de la recette, 0 KO), puis **exports 0.4.1** par le coordinateur sur `main` (`Exporter_Windows.bat`, `Exporter_Android.bat`), vérification `--main-pack` et `aapt`, envoi au joueur avec la mention : le joueur lance l'exe lui-même (Smart App Control) ; sa partie en cours se recharge (format 3 inchangé). Ensuite seulement : création des branches `lot/04-logique` et `lot/03-interface2` (`lot_04.md` §2).

## 7. Compte rendu attendu
Fichiers modifiés (comparés au §3), total avant / après, lignes de test imprimées pour CA-R2 à R4 (textes assemblés), export (taille, chemin, réussite ou échec de l'APK depuis le worktree), non vérifié, base et socle à jour.

## 8. Validation (rempli par le chef de projet)
- [ ] CA-R1 à R9 · [ ] captures relues · [ ] bases à jour
