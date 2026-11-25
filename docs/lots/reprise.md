# Reprise (mise à jour le 2026-11-25, arrêt demandé par le joueur)

## État
- `main` contient tout le lot 10 (09, 10a, 10b, 10c) : 1 766 vérifications OK. Version 0.7 configurée, **pas encore exportée**.
- Recette finale du lot 10 : KO (`lot_10_recette_finale.md`), corrigée en lot 10d ; passage ciblé : KO (`lot_10d_recette.md`) ; deuxième tour de correctifs fait, **pas encore testé**.
- `lot/10d-logique` (0905c70, commits locaux) : liste des projets (N1), SCPI/PEA ouverts sur leur fiche (N2), « 0 F » côté historique (M6) ; 1 786 vérifications OK.
- `lot/10d-interface` (fa2e6de, commits locaux) : fin de dix ans au PC (M5), garde sur le prix (N2), « Mon foyer » (M6), BOM du test de recette. Compte rendu reçu : 1 784 vérifications OK ; « Mon foyer » n'affiche plus de montant nul (donc le point 3 ci-dessous ne concerne plus que « Votre choix » et l'historique). N2 est traité des deux côtés : même choix (ouvrir la fiche), à dédoublonner à la fusion.
- Rien de 10d n'est poussé ni fusionné dans `main`.

## À faire au retour, dans l'ordre
1. Vérifier qu'aucun Godot orphelin ne tourne (arguments `archive … testeur_b3.zip`, vu par dev-interface).
2. Réunir `lot/10d-logique` et `lot/10d-interface` (les deux touchent N2 et M6 : attendre des conflits ou des doublons).
3. Faire finir le « 0 F » dans les trois affichages signalés par dev-logique, si le tour 2 d'interface ne l'a pas couvert : `modale_foyer.texte_carte`, `modale_carte.gd` (« Votre choix »), `modale_historique.gd` (« par mois »), avec `Foyer.montant_joue_txt`.
4. Recette ciblée du testeur (y compris le projet encore en cours à la bascule, corrigé sans demande). **Le joueur a demandé de ne pas lancer le testeur le soir du 25.**
5. OK → push, fusion `--no-ff` dans `main`, tests, push, puis exports 0.7 (`Exporter_Windows.bat`, `Exporter_Android.bat`) et mise à jour de `CLAUDE.md`.

## Pour le lot 11
- Titre `bon_pere` impossible sur dix ans avec 3 ou 4 projets réalisés (`Titres.projets_realises` exige `== 2`) : à arbitrer.
- `Projets.option_choisie` lit les projets archivés : un choix de 1984 peut déclencher une condition de 1989.
- Bug `cadence.gd` (l. 171-175), textes 1984 à neutraliser, re-gel de `test_reference_1984`.
- Contrat 10c à mettre à jour (flèche « › », « Épargne possible » toujours visible).
- À confirmer : légende « avant la baisse : 2 000 F » (Golfe), « 10,2 % » contre −10,4 % ; valeurs CAC 1990-91 en C (relevé officiel à déposer dans `docs/sources/` si disponible).
- Variante de la carte K4 pour un foyer sans enfant (docs/46 §9).

## Divers
- Retours des testeurs externes de la 0.6.x : à classer dans `docs/10`.
- Décisions du joueur : `docs/lots/decisions_extension_annees.md` et `docs/10_retours_joueur.md`.
