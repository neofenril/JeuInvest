# Reprise (mise à jour le 2026-11-27)

## État
- Lot 10 terminé, fusionné dans `main` et poussé. 1 797 vérifications OK. Version **0.7 exportée** (exe et APK, 27/11).
- En attente du verdict du joueur sur la 0.7. Aucun agent en cours.

## Pour le lot 11
Défauts relevés à la dernière recette (`lot_10d_recette.md`, passage 2) :
- **En premier** : carnet de la banque en 1989-93, « présentée en <mois courant> », la date avance avec le temps (`panneau_banque.gd` l. 247, `e.m` par défaut).
- Icônes d'humeur 16×16 dessinées d'après Sylvie : visage féminin aussi pour Patrick.
- Écran de fin : « Les frais et le krach sont passés par là » avec 0 F de frais.
- Relecture d'un choix de projet : « +30 000 F » ressemble à un gain.
- Guillemets imbriqués dans « Mon foyer » après un projet réalisé ; étiquette d'écart sur les courbes de fin au PC.

À arbitrer ou corriger :
- Titre `bon_pere` impossible sur dix ans avec 3 ou 4 projets réalisés (`Titres.projets_realises` exige `== 2`).
- `Projets.option_choisie` lit les projets archivés : un choix de 1984 peut déclencher une condition de 1989.
- Bug `cadence.gd` (l. 171-175), textes 1984 à neutraliser, re-gel de `test_reference_1984`.
- Contrat 10c à mettre à jour (flèche « › », « Épargne possible » toujours visible).
- Variante de la carte K4 pour un foyer sans enfant (docs/46 §9).
- À confirmer : légende « avant la baisse : 2 000 F » (Golfe), « 10,2 % » contre −10,4 % ; valeurs CAC 1990-91 en C (relevé officiel à déposer dans `docs/sources/` si disponible).

Contenu prévu du lot 11 (vie complète : événements aléatoires, plafond de malchance, décès d'un parent) : `feuille_de_route_v3.md`.

## Divers
- Retours des testeurs externes de la 0.6.x : à classer dans `docs/10`.
- Décisions du joueur : `decisions_extension_annees.md` et `docs/10_retours_joueur.md`.
