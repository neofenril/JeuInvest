# Recette lot 10a-moteur (branche `lot/10a-moteur`)

## Passage 1 (2026-11-19, HEAD fa1e851, main déjà fusionné) : verdict **OK**

Recette complète (tests + CA-M + périmètre ; aucune capture, lot sans interface). Aucune anomalie bloquante ni majeure ; 4 mineures.

### Mesures
- `tests.ps1 -Recette -Delai 700` : **1 647 vérifications OK, 0 KO, 0 erreur de script, 0 échec, 728,4 s** (45 étapes). `main` (copie isolée, même commande) : 1 527 vérifications, 704,8 s (36 étapes). Soit +120 vérifications, +3,3 % de durée (CA-M9). Records du joueur inchangés, `partie_en_cours.sav` identique avant/après (SHA-256 0EFB110D…), `records.sav` du joueur absent avant et après.
- Nouveaux tests : bascule 14, catalogue 11, catalogue_ids 13, enveloppes 26, gabarits 12, marche 14, partie_pea 5, records_v2 13, vie 12.

### Critères
- [x] **CA-M1** : `git diff main...HEAD -- godot/tests/test_reference_1984.gd` vide ; 35 vérifications vertes. Valeurs de tests modifiées (toutes justifiées par M2/M7) : test_chapitres (181→193 cases, 180→192 mois, 600→1 200), test_logique (192 mois ; 2 dates de référence V1 de 1990 et 1992 retirées de la comparaison), test_records (v1→v2), test_interface (D0x→id de produit, catalogue).
- [x] **CA-M2** : recalculé par moi (script hors projet, `main` et branche) : md5 des 133 cases 1977-12 à 1988-12 de l'indice, Elf, L'Oréal, Peugeot, Saint-Gobain, SICAV **identiques** ; ligne `MARCHE identiques=1 per 132 mois` imprimée ; prolongement à 193 cases (12/1993) ; fins d'année = series.json ; BNP absente avant 10/1993, 240 F en 10/1993.
- [x] **CA-M3** : catalogue de 15 produits (naissances et certitudes A/B/C présentes), 1984 reproduit champ à champ, jamais de présentation avant naissance, un produit au plus une fois par chapitre, R-UNE-FOIS, R-RATTRAPAGE (scpi et sicav_monétaire présentés entre les mois 1 et 24, un au plus tous les 2 mois), `produits_vus`, migration `presentes` D0x.
- [x] **CA-M4** : 1984-01 → 1989-12 sans erreur, `chapitre_change` émis une fois avant la modale `passage`, humeur, projets, Jean-Mi, banque, effets de salaire conservés, un titre par chapitre.
- [x] **CA-M5** : migration v1 (record et collection sous « 1984 »), double record, idempotence, fichiers tronqués/vides/illisibles/version inconnue = vides, chemins de test isolés.
- [x] **CA-M6** : PEA (refus avant 07/1992, plafond 600 000 F, éligibilité, clôture avant 5 ans avec impôt du compte-titres, retrait libre après 5 ans), SCPI (10 % de frais, valeur de ligne = revente datée, loyer trimestriel net 121,80 F, vente différée de 3 mois annulable au prix du mois d'exécution, hors vente automatique, absente chez Tata/Tonton), PEP en notification avec texte long, sans fiche.
- [x] **CA-M7** : CNAM 1984 inchangé, effets cumulés, `jusqua` ; mariage sur 400 graines dans ±5 points (61,5 / 73,8 / 42 / 20 % pour 60 / 70 / 40 / 20) ; jumeaux 1989 = 15,7 % sur 600 (1/6 ± 3) ; 1984 garde 1/4.
- [x] **CA-M8** : les 3 sauvegardes d'avant (`tests/donnees/sauvegardes/`) et une copie de la sauvegarde du joueur (août 1984, 15/11) relues et jouées jusqu'à la fin sur `main` et sur la branche : patrimoine, frais, impôts, interruptions, historique et md5 des textes **identiques** (vérifié par mon propre script, indépendant de celui du développeur). Sauvegarde écrite en 1990 (jeu d'essai) relue : chapitre, produits vus, ventes différées, parts de SCPI.
- [x] **CA-M9** : voir mesures.
- [ ] **CA-M10** : hors lot (neutralisation des textes de 1984 glissée au lot 11 par décision du chef de projet). Pour Gérard, les textes rendus sont néanmoins identiques à `main` (md5 d'historique des sauvegardes ci-dessus). `Gabarits` est testé (12 vérifications : joueuse, élision, majuscule, jetons étrangers laissés).

### Autres contrôles
- **Périmètre** (`diff main...HEAD`, 53 fichiers) : tout est en colonne logique (`data/`, `scripts/logique`, `scripts/partie.gd`, `tests/`, `docs/connaissances/dev-logique.md`). Exceptions connues : `test_interface.gd`, `tests/recette/test_recette_titres.gd` (`version=2`) et le scénario `scripts/outils/scenarios/interface.gd` (`_carnet_13`) corrigés par le chef de projet ; diffs relus, mécaniques (catalogue + `produits_vus`). Ni `outils/`, ni captures, ni secrets, ni `export_presets.cfg`/`project.godot`. Worktree propre (seul `docs/lots/lot_10a.md` modifié dans le dépôt principal, hors recette).
- **Règle pédagogique / pas de nom en dur** : aucun conseil personnalisé dans les textes ajoutés ; le code neuf ne contient aucun prénom (seuls les exemples de commentaires de `gabarits.gd`) ; les libellés « M. Lefranc présente », « tante Odette » sont passés du code aux données de `chapitres/1984/banque.json` (neutralisation reportée au lot 11, voir M1).
- **Export** : `--export-pack Windows` réussi (1,49 Mo hors fichiers importés), contient `data/produits.json`, `data/periode_p1.json`, `data/chapitres/index.json` et les 10 JSON de `data/chapitres/1984/` (le filtre `data/*.json` couvre le catalogue) ; aucun chapitre 1989 réel, normal à ce stade.

### Anomalies (mineures)
1. **Mineure** : CA-M10 et le jeu d'essai minimal (M8) non livrés : le chef de projet les a reportés au lot 11 ; à reprendre sinon le CA-I10 de `lot_10b.md` ne porte pas sur 1984.
2. **Mineure** : `test_logique` ne compare plus 2 des 8 dates de la référence V1 (1990, 1992), faute de ancrages inchangés ; la comparaison 1978-1988 reste exacte par `test_marche` (md5 de `main` figés en dur, que j'ai revérifiés).
3. **Mineure** : la sortie de `tests.ps1` sur `main` comme sur la branche affiche un `[stderr] … cleanup (core/object/object.cpp:2536)` (fuite à la sortie d'une scène), sans impact sur le verdict (préexistant sur `main`).
4. **Mineure** : docs/35 §1.4 doit être mis à jour (`{e}` joueur, `{e_p}` proche) : le développeur doit le consigner au compte rendu ; non vérifié dans un document.

### Non vérifié
Interface et rendus (hors lot, aucune capture), partie sur téléphone, valeurs C (SCPI, fins de mois 1990/1991, BNP) à confirmer avant l'export 0.7.
