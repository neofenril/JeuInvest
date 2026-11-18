# Lot 08 : recette

## Pop-up de début de partie (2026-11-18, branche `lot/08-intro`, HEAD 3b49d1d + modification NON COMMITEE de `godot/data/intro.json`)

**Verdict : OK** (recette courte ; 0 bloquante, 0 majeure, 2 mineures).

Note au chef de projet : le dernier changement du développeur (gabarit « ... vous démarrez avec {depart} d'économies ») est dans l'arbre de travail mais PAS commité (`git status` : `M godot/data/intro.json`). J'ai testé cet état. Le développeur doit le commiter avant le push, sinon la branche poussée portera l'ancien texte (« vous avez {depart} sur votre compte courant »).

### Vérifications
- Périmètre (`git diff main...HEAD --stat`) : principal.gd, modales.gd, reglages.gd, modale_intro.gd (+ .uid), intro.json, test_interface.gd, scenarios/interface.gd, docs/connaissances/dev-interface.md. Rien d'autre (aucun fichier temporaire, capture, outils/). Données de référence inchangées.
- `tests.ps1 -Recette -Delai 700` : **1 350 vérifications, 0 KO, 0 erreur de script, TOUT EST PROPRE** (624 s, aucun autre Godot de ma part en parallèle). `partie_en_cours.sav` du joueur identique avant/après (SHA-256 0EFB110DAC59), `records.sav` absent avant et après.
- Captures de l'étape `intro` (PC 1920x1080 en fenêtre 1280x720, téléphones 1440x648 et 1280x720), relues : titre, sous-titre, 4 blocs, COMMENCER toujours visible en bas, texte >= 26 px (chiffres >= 26 px, 28 px au PC), rien de coupé ; une zone défilante (le dernier bloc « COMMENT JOUER » n'est visible qu'en défilant au PC et au 1440x648, entièrement visible au 1280x720). Lignes `UI intro blocs=4/4 bouton_ok=oui panneau_dans_ecran=oui temps_fige=oui`, `debordements=0`, cibles >= 56 / 72 / 84 px ; `entree_ferme=oui`.
- Nouveau test de recette `godot/tests/recette/test_recette_intro.gd` (+ .tscn), 29 vérifications, par la vraie `principal.tscn`, `user://` isolé (sauvegarde et records redirigés) :
  - A. NOUVELLE PARTIE depuis l'écran titre : la pop-up s'ouvre avant toute autre, temps figé 2,5 s (mois inchangé), Échap et clics extérieurs sans effet, valeurs 6 786 F (= `salaire_base`) et 11 000 F (= `demo.json` depart_F.cc), aucun mot interdit, aucun « tu/ton/ta », pas de « krach », défilement jusqu'au bas atteint, Entrée ferme, entrée d'historique source maison, `lu` vrai, 0 non-lue ajoutée, le jeu repart ensuite.
  - B. Continuer (reprise d'une sauvegarde puis `jouer()`) : jamais de pop-up (240 images observées).
  - C. REJOUER AUTREMENT (`nouvelle_partie` + `demarrer_direct`) : pop-up, temps figé ; fermée par Espace, par la touche 1 et par le bouton COMMENCER.
  - E. Headless sans `intro_force` ni `--intro` : pas de pop-up (donc les parties automatiques des tests ne sont pas gênées).
  - Le flux « REJOUER AUTREMENT » réel (`sequences._sequence_fin` : `nouvelle_partie()` puis `demarrer_direct()`) a été relu ; `_reprise` y est remis à faux.
- Relecture dans l'HISTORIQUE (captures PC et téléphone) : entrée « MA MAISON · JANVIER 1984 », texte complet, bouton FERMER, rien de coupé.
- Cohérence : 6 786 F et 11 000 F identiques dans la pop-up, l'historique et le HUD (« Salaire +6 786 F »). Écart noté avec docs/32 (qui écrit 6 790 F) : le chiffre du jeu est celui de la partie, la règle « lu dans les données » est respectée ; docs/32 est simplement approximatif.
- Texte : vouvoiement, aucun mot interdit, krach non annoncé (docs/32 §0 respecté), pas de case « Ne plus afficher » (docs/32 §3 respecté).

### Anomalies (mineures)
1. **Mineure** : le titre de l'entrée d'historique s'écrit en minuscule initiale « janvier 1984 : votre situation » (docs/32 §2 : « Janvier 1984 : votre situation »). Cause : le gabarit `{date}` est la date en minuscules ; la forme `{DATE}`/majuscule initiale n'est pas prévue pour ce titre. Capture : relecture PC/téléphone.
2. **Mineure** : dans la relecture de l'historique, les intertitres des blocs sont collés dans un seul paragraphe avec `capitalize()` (« Qui Vous Êtes : ... Ce Qui Vous Attend : ... ») : lisible mais peu élégant (casse Title Case, pas de sauts de ligne).

### Critères
- [x] Pop-up après JOUER / NOUVELLE PARTIE / REJOUER AUTREMENT (JOUER via le chemin `demander_nouvelle_partie` testé ; JOUER avec `jouer()` sans sauvegarde même code `_intro_nouvelle_partie`).
- [x] Jamais à la reprise ; jamais en test/capture sauf option.
- [x] COMMENCER par clic, Entrée, Espace, 1 ; Échap et clic extérieur ne ferment pas.
- [x] Temps figé derrière ; avant toute autre pop-up (le mois n'avance pas tant qu'elle est ouverte).
- [x] Téléphone : zone défilante, COMMENCER toujours visible.
- [x] Entrée d'historique, déjà lue, aucune non-lue.
- [x] Valeurs lues dans la partie / les données ; krach non annoncé.
- [x] Tests au vert (1 350).

### Non vérifié
- Vrai téléphone (défilement tactile de la zone, ressenti) ; JOUER depuis un écran titre avec animation de plongée en fenêtre réelle (code identique à NOUVELLE PARTIE après `await`, non rejoué à la main).
- Photo de la liste de l'historique avec l'entrée (mon test n'a pu ouvrir la liste en capture) ; la relecture, elle, est vérifiée.
