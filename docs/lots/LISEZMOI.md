# Plans de lot

Un lot = un plan `lot_NN.md` écrit par le chef de projet, commité sur `main`, exécuté par le coordinateur (une branche `lot/NN-<dev>` et un worktree par développeur), vérifié branche par branche par le testeur (`lot_NN_recette.md`), validé par le chef de projet, puis fusionné. Règles complètes : `docs/connaissances/chef-de-projet.md` §4 ; exemple complet : `lot_01.md` ; suite prévue : `feuille_de_route.md`.

## Modèle

```markdown
# Lot NN : <titre court>

- Origine : <retour joueur docs/10 du JJ/MM, docs/14 §x, backlog T…>
- Objectif (1 à 3 phrases, ce que le joueur verra) :
- Hors périmètre :
- Mode : parallèle | séquentiel (dev-logique puis dev-interface)
- Branches et worktrees : lot/NN-logique, lot/NN-interface (, lot/NN-ville) ; ordre de fusion

## Fichiers attribués (tout fichier absent de ce tableau est interdit)
| Fichier | Propriétaire | Nature du changement |
|---|---|---|

## Interfaces (fixées avant le lancement)
- Signaux / fonctions (signature exacte) :
- Champs d'état et sauvegarde (version inchangée | +1, anciennes sauvegardes ignorées | migrées) :
- Données JSON (clés ajoutées) :
- Nouveaux class_name :

## Tâches
### dev-logique
1. … — CA-L1 : <critère testable> (test : <nom>)
### dev-interface
1. … — CA-I1 : <critère testable> (captures : <étape>, PC + téléphone)

## Vérifications attendues
- tests.ps1 vert, nombre de tests ≥ N, aucune SCRIPT ERROR / Parse Error
- captures à relire : <liste>
- comptes rendus : fichiers modifiés, non vérifié, écarts d'interface

## Validation (rempli par le chef de projet)
- [ ] CA cochés avec preuve · [ ] tests · [ ] captures relues · [ ] bases de connaissances à jour
- Décision : validé | corrections demandées (liste)
```
