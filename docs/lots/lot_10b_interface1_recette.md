# Lot 10b-interface, étape 1 : recette courte

## Passage 1 (2026-11-19, `lot/10b-interface`, commit testé 0e8e373, base d9059eb)

**Verdict : OK** (0 anomalie bloquante ou majeure ; 3 mineures). Étape 2 (contrat de 10a) non concernée.

### Vérifications
- Périmètre : 14 fichiers, tous dans la colonne 10b-interface (`ui/*`, dont le nouveau `noms.gd`, `scenarios/interface.gd`, `capture_interface.ps1`, `test_interface.gd`, `dev-interface.md`) ; rien d'inattendu.
- `tests.ps1` complet : 24 étapes, **1 225 vérifications OK**, 0 KO, 0 erreur de script, sauvegarde et records inchangés.
- Captures ciblées (PC 1920x1080, 1440x648, 1280x720), 0 `ERROR`, `debordements=0 hors_cadre=0 hors_ecran=0` partout, `sous_seuil=0` : `frise_10ans` (120 mois, coupure visible, années paires seules au téléphone), `mon_argent_10ans`, `carnet_13` (13 cartes, 4 colonnes au PC sans défilement, 3 colonnes défilantes aux téléphones, cibles min 60 / 72 / 84), `hud`. Images relues : frise 1984-1993 avec coupure en 1989 et drapeau, carnet à 13 produits lisible, aucun chevauchement.
- Comparaison à la base (copie isolée de d9059eb) : `carnet` et `fin` identiques hors animation (PC carnet 99 / 518 400 px échantillonnés, fin 0 ; téléphones 0 à 174 px, bbox limitée au décor ou au bord de la rue) : **pas strictement identiques à l'octet**, mais écart de l'ordre de 0,03 % (animation). `hud` : écarts localisés dans la zone de rue (x 242-1324, y 102-550 à 1440x648), jamais dans la barre haute, le panneau ni la frise : animation (personnages, voitures), pas une régression.
- Aucun texte en dur Lefranc / Sylvie / Gérard / dates dans les lignes ajoutées de `scripts/` (seuls des commentaires et du code de test) ; les noms passent par `noms.gd`.
- `frise.gd` : `m_fin = -1` à l'initialisation, garde `if m_fin < m_debut` avant tout dessin : M2 de 09-I corrigée.

### Mineures
- M1 : l'étape `carnet_13` utilise des cartes « FAB 1-4 » fabriquées (« présentée en déc. 1986 ») : décor de test, à remplacer par le vrai chapitre 1989 à l'étape 2.
- M2 : la courbe « Mon argent » ne montre que le temps joué (axe 1984-1988) alors que la frise montre 120 mois : cohérent, mais à confirmer pour le bilan.
- M3 : « hud » PC en pause : libellé « COMPTE COURANT » plus long que le « COMPTE » de la capture de référence (état différent, pas une régression ; à re-vérifier avec `main` en pause à l'étape 2).

### Non vérifié
Étape 2 (passage, vitrine, fin 2 titres, choix du départ) ; série complète (recette allégée) ; vrai téléphone ; défilement tactile du carnet à 13.
