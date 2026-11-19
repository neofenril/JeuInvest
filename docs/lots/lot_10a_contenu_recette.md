# Recette du lot 10a-contenu + 10a bis (chapitre 1989-1993 et bascule)

## Passage 1 (2026-11-19) : branche `lot/10a-contenu`, commit 5f4be40 : verdict **OK**

Worktree `JeuClaude_lots\lot10a-contenu`, aucune modification du code ; rien commité ni poussé.

### Tests automatiques
- `tests.ps1 -Recette -Delai 700` en entier : 47 étapes, **1 698 vérifications OK, 2 KO** (1 031 s), 0 erreur de script, sauvegarde et records du joueur inchangés. Les 2 KO sont exactement les deux attendus de `test_interface` (fin par défaut 1993-12 ; frise sans coupure) : ils reviennent à dev-interface, pas des KO de ce lot. Aucune instabilité observée (les autres Godot étaient visibles, pas de test relancé en échec).
- `test_reference_1984` : fichier et données 1984 inchangés par rapport à `main` (diff vide), 35 OK. (Je ne l'ai pas rejoué sur une copie de `main` : l'identité du fichier et du chapitre 1984 suffit.)
- `test_chapitre_1989` 36 OK, `test_10a_bis` 17 OK, `test_bascule` 14, `test_chapitres` 45, `test_cadence` 18, `test_titres` 62, `test_records(_v2)`, `test_sauvegarde` verts.

### Critères CA-B (mesure indépendante : script à moi, 200 graines Gérard 1984 → 1993, profil P-REF, boucle qui observe `e.modale` ; mêmes chiffres que `test_10a_bis`)
- [x] **CA-B1** : cartes 1989-1993 moyenne 9,89 (min 7, max 11 ; 153/200 parties dans 8-10, la moyenne est dans la cible) ; mariage 140/200 = 70,0 % ; oncle Raymond (D08) 200/200 ; « un an après » (gazette G1) 200/200 ; pauses 24,25 (Christine 24,24) ; cadence 200/200 selon le test, voir mineure M1.
- [x] **CA-B2** : titres Gérard (5 % à 21,5 %) et Christine (4 % à 24 %) tous entre 3 et 25 %.
- [x] **CA-B3** : 0 jeton `{…}` dans mes 200 modales (Gérard) ; test dev : 0 jeton en modales, notifications et historiques pour Gérard, Christine, joueuse d'essai ; 935 textes rendus.
- [x] **CA-B4** : PEP (01/1990) et BNP (10/1993) en notification sans pause ; SICAV monétaire achetable, +10,0 % en 1990 (taux 9,6 %).
- [x] **CA-B5** : `test_reference_1984` inchangé et vert ; suite verte hors les 2 KO attendus.

### Textes et pédagogie
- Aucun conseil personnalisé trouvé (recherche vous devriez / conseillons / achetez / vendez / investissez : seuls hits = exemple pédagogique générique du VPB et la note interne de `titres.json`). Textes ≤ 30 mots (présentations, cartes, messages), passages et kiosque ≤ 15, contrôlés par le test et vérifiés. Aucun prénom en dur (hors témoins), aucune privatisation, aucun « Balladur ». Certitudes : `_certitude` C sur les cartes de foyer ; 08/1990 = 1 640 (C) et 09/1990 = 1 472 (A) notés dans `vitrine.json`, 09/1991 = 1 830 (C) testé ; SCPI et Raymond (70 000 F) marqués C dans `banque.json`.

### Sauvegarde, records, périmètre, export
- Sauvegarde et records du joueur inchangés (SHA-256 avant/après) ; migration des anciennes sauvegardes (marqueurs par chapitre) couverte par `test_sauvegarde`, `test_records_v2`, `test_bascule` (verts). Non rejoué : une vraie `partie_en_cours.sav` du joueur (non vérifié).
- Périmètre : `scripts/logique/*`, `data/chapitres/1989/`, `index.json`, tests logiques, `docs/connaissances/dev-logique.md`, plus `periode_p1.json` (SICAV monétaire, nécessaire, donnée du monde) et `salaires.json` (profil christine, accepté par le plan). Rien dans `scripts/ui`, `principal.gd`, `test_reference_1984`, `test_interface`. Aucun fichier parasite.
- Export : `--export-pack Windows` : le paquet contient les 11 fichiers `data/chapitres/1989/*.json`.

### Anomalies
- **M1 (mineure)** : la cadence « 200/200 » repose sur des exceptions écrites dans le test (panne forcée après marché ou carte ; événement de vie / présentation poussés contre une date ferme ; échéance de projet reportée après la carte de passage : « 1 graine sur 400 chacun »). Acceptable, à surveiller.
- **M2 (mineure)** : `test_chapitre_1989` signale 3 « écarts moteur » (non bloquants) : 23,8 pauses en stratégie passive (cible 24-26 ; 24,25 en P-REF, cible tenue), et Jean-Mi 4,99 étoiles sur 5 pour Gérard (J2 atteinte 200/200).
- **M3 (mineure)** : cartes 7 à 11 selon les parties (seules 153/200 dans 8-10) ; la moyenne est conforme.
- Christine : 0 mariage (voulu, déjà mariée), 6,2 cartes (hors cible CA-B1, qui vise Gérard).

### Non vérifié
Rendu à l'écran (aucune capture : lot de données et de moteur, interface à 10b) ; ressenti du rythme ; textes relus sur 1 profil seulement hors tests automatiques.
