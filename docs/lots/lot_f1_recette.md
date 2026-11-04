# Recette du mini-lot F1-L (dev-logique)

## Passage 1 — 2026-11-03/04, branche `lot/f1-logique`, commits 1f16f31 + 6397542 (base 3abcc48, `main` = 76e3a30)

### Verdict : **OK** (0 bloquante, 0 majeure, 3 mineures, 1 observation hors lot)

### Périmètre
`git diff main...lot/f1-logique --stat` : `data/banque.json`, `data/demo.json`, `scripts/logique/banquier.gd`, `scripts/logique/etat_partie.gd`, `tests/test_demo.gd`, `tests/test_partie.gd`, `docs/connaissances/dev-logique.md`. Rien d'inattendu (ni capture, ni `outils/`, ni `export_presets.cfg`). Aucun fichier en commun avec ce que `main` a reçu depuis la base, ni avec `lot/px2-interface` (79a57f0).
- Tests des développeurs modifiés (3 dans `test_demo`, 1 dans `test_partie`) : **acceptable**. Seules les chaînes attendues changent (`" %"` remplacé par `Format.ESPACE + "%"`, idem pour « 50 F ») : la règle vérifiée reste la même, rien n'est affaibli (le contrôle « jamais 6 % » vérifie maintenant les deux espaces). En plus, `test_demo` ajoute 6 vérifications F1-L.

### Tests automatiques
- Branche (worktree `f1-logique`) : **330 vérifications OK, 0 KO, 0 erreur de script** (9 étapes, 44,7 s). Import propre.
- Fusion simulée `main` 76e3a30 + F1-L (worktree jetable, merge sans conflit) : **401 OK, 0 KO, 0 erreur de script** (10 étapes, dont test_rue).
- Fusion à trois `main` + F1-L + `lot/px2-interface` 79a57f0 : merge sans conflit, import sans `SCRIPT ERROR` ni `Parse Error`.

### Critères
- [x] **(a) Flèches réécrites à la source.** `demo.json` : « janvier 1984 – décembre 1988 » (capture du titre conforme). `banque.json` : ticket du PEL « pendant 4 ans : {fv_pel} ». `Banquier.joindre_ticket` : « 12 600 F : + 945 F par an, sans impôt », « 400 F par mois pendant 4 ans : 22 519 F » (un seul « : »). Plus aucun « → » dans `data/` ni dans `scripts/logique/` en dehors des commentaires ; restent les 2 de `scripts/ui/modales.gd` (l. 521 « Dépenses du mois : a → b », l. 873 flèche du ticket de la carte) : hors périmètre, voir m2.
- [x] **(b) Espaces insécables (m5).** `banque.json` : 0 « chiffre ou } + espace normale + % / F », 0 séparateur de milliers sécable ; 138 U+00A0 (aucun U+202F, cohérent avec `Format.ESPACE` = U+00A0). `texte_taux_pel` : U+00A0 avant les deux « % ». Rendu : Atkinson, Pixelify, Jersey 10, Doto et Segoe UI ont le glyphe U+00A0, de même chasse que l'espace (script de mesure sur la fusion avec PX2). Capture de la fenêtre Banque (fusion avec PX2, Atkinson) : « 6,30 % + prime d'État ≈ 8,25 % », « ≈ 8,25 % fixe », « 13,4 % fixe », « 500 F » : espaces bien affichés, pas de glyphe manquant.
- [x] **(c) Version.** `export_presets.cfg` non touché ; déjà en 0.3 / code 3 sur `main` (`file_version` et `product_version` 0.3.0.0, `version/name` "0.3"). Export après la fusion de PX2 : non fait (hors recette).
- [x] **Ancienne sauvegarde.** Une vraie sauvegarde de format 3 écrite par `main` (graine 7, joueur actif, juin 1986, 16 entrées d'historique dont 5 avec « → ») est chargée sans erreur par la fusion : 0 flèche restante (résumés et tickets) ; la partie continuée finit **à l'identique** sur `main` et sur la fusion (patrimoine 171 767,32 F, frais 869,97 F, 31 entrées).
- [x] **Partie complète** (`integrale`, main + F1-L, copie isolée) : fin en décembre 1988, **160 749 F, frais 805,93 F, 11 interruptions**, modales {appel 8, banque 4, courrier 2, journal 1, fin 1}, aucune `SCRIPT ERROR` : identique à la référence.
- [x] Non-régression : historique (capture : résumés corrects, chiffres cohérents), comparaison Livret A, sauvegarde (test_sauvegarde 10/10).

### Anomalies
- **m1 (mineure)** : dans une **ancienne sauvegarde**, le résumé du PEL devient « 400 F par mois **:** pendant 4 ans **:** 22 519 F » (deux « : »), alors qu'une partie neuve donne « 400 F par mois pendant 4 ans : 22 519 F ». En cause : `Banquier.sans_fleche` remplace chaque « → » par « : », sans reprendre la règle de `joindre_ticket`. Ce n'est que cosmétique, et seulement dans l'historique des parties commencées avant F1-L. Reproduire : sauvegarde de `main` qui contient la présentation du PEL, chargée sur la branche, puis HISTORIQUE.
- **m2 (mineure, hors périmètre, interface)** : `modales.gd` l. 873 garde la flèche entre les deux morceaux du ticket de la carte (capture : « 12 600 F → + 945 F par an, sans impôt »). Sur la carte du PEL, on lira « 400 F par mois → pendant 4 ans : 22 519 F ». Et l. 521 : « Dépenses du mois : a → b ». À traiter par dev-interface (la substitution « › » de PX2 masque le glyphe manquant, mais le contrôle `fleches_texte` ne tombera pas à 0).
- **m3 (mineure, hors périmètre)** : il reste des espaces normales avant « % » ou « F » ailleurs : `salaires.json` 9, `periode_p1.json` 5, `series.json` 3, `evenements_vie.json` 2, `regles.json` 1 (en partie des commentaires), et dans des gabarits codés en dur (`etat_partie.gd` l. 1225 « Agios de %s % par an », `produits.gd` l. 296 « après 16 % d'impôt »). Cela peut donner une coupure de ligne entre le nombre et l'unité dans ces textes. Le dev le signale lui-même.

### Observation hors lot (à transmettre)
- L'étape de capture **`carnet_pel` ne rend pas la main** : le PNG est écrit, puis la fenêtre Godot reste « ne répond pas », indéfiniment. Constaté sur `main` seul (copie isolée de 76e3a30), sur main + F1-L et sur main + F1-L + PX2. **Ce n'est donc pas dû à F1-L.** Un processus de capture de dev-interface (worktree `px2-interface`) était dans le même état au même moment. Je n'ai pas pu tuer mes processus bloqués (refusé par le garde-fou) ; ils ont disparu à la reprise de session. Les autres étapes (`titre`, `historique`, `banque_ordre`, `presentation_livret`, `integrale`) se terminent normalement.

### Non vérifié
- Un vrai téléphone et l'APK 0.3 (après la fusion de PX2).
- La capture au format téléphone de la banque (série interrompue par le blocage ci-dessus ; la mesure des glyphes ne dépend pas du format).
- Le rendu en Pixelify d'un texte avec chiffres : la règle PX2 met les chiffres en Atkinson, donc l'insécable n'est contrôlée en Pixelify que par la mesure de la police.

### Questions au chef de projet
1. m1 : correction dans F1-L (faire passer `sans_fleche` par la règle de `joindre_ticket`) ou tolérée (anciennes parties seulement) ?
2. m2 / m3 : à planifier (dev-interface pour `modales.gd`, dev-logique pour les autres JSON et les gabarits) ?
3. Blocage de `carnet_pel` à la sortie : à confier à dev-interface ou dev-ville (présent sur `main`).
