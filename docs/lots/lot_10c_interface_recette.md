# Recette du lot 10c-interface

## Passage 1 (2026-11-25) : branche `lot/10c-interface`, commit 6f546eb (base main ced560b) : verdict OK (6 mineures)

Recette allégée (tests complets + étapes ciblées + non-régression pixel). Copies isolées (`git archive`, user:// à part) ; partie du joueur intacte (SHA-256 0EFB110DAC59... identique avant / après, `tests.ps1` : « Sauvegarde du joueur : inchangée », « Records : inchangés »). Worktree du développeur propre.

### 1. Périmètre
`git diff main...lot/10c-interface --stat` : 5 fichiers, tous attendus : `ui/modale_carte.gd`, `ui/modale_foyer.gd`, `scripts/outils/scenarios/interface.gd`, `tests/test_interface.gd`, `docs/connaissances/dev-interface.md`. Aucun fichier temporaire, capture, secret, ni `outils/`. Aucune donnée ni logique touchée.

### 2. Tests automatiques
`tests.ps1 -Recette -Delai 700` : 47 étapes, **1 766 vérifications OK, 0 KO, 0 erreur de script** (main : 1 718). Un premier passage a donné 1 KO (CA-C6 « version 0.7 / fichiers sans BOM ») : artefact de MA copie (project.godot réencodé par mon propre script) ; après correction de la copie, `test_carriere` rejoué seul : 39 OK, 0 KO. Pas d'erreur de script à l'import, sauf l'erreur connue `tests/recette/test_recette_fin_titres.tscn` (« Expected '[' », à froid, ticket n° 5 de `lot_10c.md` §6 bis, à mon nom ; non bloquant, hors `tests.ps1`).

### 3. Critères d'acceptation
- [x] **CA-C7** : montant par mois signé dans chaque bouton (« +222 F / mois », « −949 F / mois », « Pas de changement » pour 0), ligne « Épargne possible : avant › après par mois » == contenu (`conforme=oui`, `incoherences=0` pour K4 et K5), picto d'humeur du proche présent, avertissement sous chaque bouton == contenu ; `debordements=0 hors_cadre=0 hors_ecran=0` en PC 1920x1080, 1440x648 et 1280x720, images relues : aucun débordement ni texte coupé, boutons de même hauteur. Valeur négative (K5 a : « 1 139 F › 190 F » ; cas Gérard : « 395 F › −99 F ») lisible. Réserves : points 1 et 2 ci-dessous.
- [x] **CA-C8** : « Mon foyer » (étape `mon_foyer_metier`, après acceptation de K4) : « Métier » = `metier()` (« Assistante du directeur commercial »), « Statut : Souvent absente » rendu par la logique ; PC et 2 téléphones, `debordements=0`.
- [x] **CA-C9** (côté interface) : aucun prénom en dur dans `modale_carte.gd` / `modale_foyer.gd` (seule occurrence : un commentaire). Rendus vus : Christine (« Patrick vous verra… », « Souvent absente », « Assistante… ») ; profil Gérard simulé (sexe h, proche Sylvie, copie de scénario : « Sylvie vous verra… », « Souvent absent », « Salarié ») ; aucun gabarit résiduel (`{e}`, `{proche}`).
- [x] Non-régression 1984-1988 : étapes `carte` et `mon_foyer` main contre branche, PC / 1440x648 / 1280x720 : écart de pixels 0,000 % (carte, 3 formats) ; 0,018 % / 0,066 % / 0,000 % (mon_foyer : animations), « Mon foyer » de 1984 sans ligne Métier (conforme au code : `chapitre == "1984"` exclu), `debordements=0`.
- [x] Cartes du foyer classiques inchangées (le champ `revenu_mois` seul active le nouveau rendu).
- Non vérifié : défilement tactile réel de « Mon foyer » sur un vrai téléphone ; série de captures complète (non demandée) ; carte de carrière relue depuis l'historique (en dehors des étapes demandées).

### 4. Points signalés par le développeur : jugement
1. **Ligne « Épargne possible » dans chaque bouton au lieu d'une ligne au survol** : écart au contrat (§6 bis), mais **acceptable, mineur** : lisible sans survol (indispensable au tactile), les deux valeurs se comparent d'un coup d'œil, aucun débordement aux 3 formats. À faire acter par le chef de projet.
2. **« › » au lieu de « → »** : mineur ; « → » est absent de la police pixel (voir base de connaissances) ; le rendu « 1 066 F › 1 288 F » reste compréhensible. Le texte du contrat (CA-C7) dit « → » : mettre le contrat à jour.
3. **« · 0 F » sur la carte de carrière jouée dans « Mon foyer »** (« Le poste itinérant · Accepter · 0 F ») : constaté ; vient du montant moteur = 0 pour une carte de carrière (le montant est maintenant mensuel). **Mineur, ticket logique** : afficher « +222 F / mois » ou rien.

### 5. Anomalies
Aucune bloquante ni majeure.
- **M1 (mineure)** : points 1 à 3 ci-dessus.
- **M2 (mineure)** : au téléphone, une valeur longue de « Mon foyer » (« Assistante du directeur commercial ») touche la barre de défilement (1280x720 : texte collé à la barre). Même géométrie que main pour les montants ; à surveiller si un métier plus long arrive. Captures : `t10c_mon_foyer_metier_t1.png`, `_t2.png` (dossier `godot/captures` de la copie).
- **M3 (mineure)** : le commentaire de `_carriere` (scénarios/interface.gd) annonce « --profil=christine » mais le scénario ne lit aucun argument : le profil est celui du chapitre 1989 (Christine) ; le cas Gérard n'est donc pas couvert par les captures du développeur (j'ai vérifié par une copie modifiée, rendu correct).
- **M4 (observation de contenu, à voir par le game designer)** : K4 affiche « salaire + 15 % » dans le texte mais « +222 F / mois » en montant (garde et frais déduits, dit dans l'avertissement) ; compréhensible, pas un écart de chiffres.
- **M5** : erreur d'import `test_recette_fin_titres.tscn` (à mon nom, non liée au lot).

### 6. Verdict : **OK**
Le push de `lot/10c-interface` peut avoir lieu. Mineures listées pour le chef de projet.