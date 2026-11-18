# Reprise (mise à jour le 2026-11-18, fin de soirée)

## État
- `main` contient les lots 08b (rééquilibrage des titres), 09-V (thème de décor), 09-L (socle des chapitres, logique). Tests de recette : 1 501 vérifications OK. Pas de nouvel export depuis la 0.6.2 ; **prochain export 0.7 à la fin du lot 10** (décision du joueur).
- Branche `lot/09-interface` (3b0ef6c, poussée ? non : commit local du worktree `JeuClaude_lots\lot09-interface`) : dev-interface a fini (1 504 OK). **Recette du testeur lancée (série de captures complète, rapport attendu dans `docs/lots/lot_09i_recette.md`)** ; si l'agent a été interrompu, la relancer.

## À faire au retour, dans l'ordre
1. Récupérer le verdict de la recette 09-I (relancer le testeur si besoin). OK → pousser `lot/09-interface`, faire valider par le chef de projet, fusionner `--no-ff` dans `main`, relancer `tests.ps1 -Recette -Delai 700` (≈ 12 min, sans autre Godot), pousser `main`.
2. Lancer le lot 10 (plans prêts : `docs/lots/lot_10a.md`, `lot_10b.md`, `lot_10c.md`, `feuille_de_route_v3.md`) : en parallèle `lot/10a-moteur` (dev-logique), `lot/10b-ville` (dev-ville), `lot/10b-interface` étape 1 (dev-interface) ; puis 10a-contenu et 10b-interface étape 2 ; puis 10c ; recette finale (série de captures complète, 2 parties réelles, exe + APK) ; export 0.7.
3. Demander au chef de projet de retirer la mention « conjoint de même sexe possible » de `feuille_de_route_v3.md` (ligne 31) : refusée par le joueur.

## Décisions du joueur (toutes consignées dans `docs/lots/decisions_extension_annees.md` et `docs/10_retours_joueur.md`)
Chapitres de 5 ans (1989-1993 en premier), début 1977, fin = dernière année implémentée, mort du personnage, double record, décor par 2 chapitres, 1977-1983 en un chapitre de 7 ans, Gérard vieillit, Christine seule au lot 10, carte de passage A, mariage 70 %, jumeaux 1/6, divorce accepté (humeur → probabilité, via carrière), décès d'un parent, événements de vie aléatoires (marché = dates historiques), pilote carrière K4/K5 au lot 10, retraite/PER plus tard, SCPI/immobilier comme diversification (pas de privatisation, pas de studio), catalogue de produits déplaçable entre chapitres, tabac validé (casino plus tard, classer 17+), joueuse possible (conjoint de genre inverse, pas de même sexe), investissements alternatifs pour les années 2000.

## Points d'attention
- Plusieurs commits `main` ne sont poussés que localement si le push a échoué ; vérifier `git status` / `git log origin/main..main`.
- Valeurs C à confirmer avant l'export 0.7 : fins de mois 08/1990 et 09/1991 (boursier), SCPI (banquier).
- Retours des testeurs externes de la 0.6.x : à classer dans `docs/10`.