# Recette 09-I (fin du lot 09) : `lot/09-interface`

## Passage 1 (2026-11-18 / 19), commit 3b0ef6c (fusion 08b + 09-V + 09-L + 09-I), testeur

**Verdict : OK** (0 anomalie bloquante ou majeure, 2 mineures, 1 point hors lot signalé).

### Contrôles
- **Périmètre** : `git diff main...lot/09-interface --stat` = `principal.gd`, `ui/ecran_titre.gd` (commentaire), `ui/frise.gd`, `ui/modale_intro.gd`, `tests/test_interface.gd`, `docs/connaissances/dev-interface.md`. Aucun fichier de `scripts/ville`, aucun fichier d'`outils/`, de captures ni de secret. Worktree propre.
- **Import** d'un worktree neuf : propre (pas d'erreur au 1er passage cette fois).
- **Tests** : `tests.ps1 -Recette -Delai 700` = 36 étapes, **1 504 vérifications OK, 0 KO, 0 erreur de script, 0 échec**, 713 s, « TOUT EST PROPRE ». `test_reference_1984` 35 OK (inchangé), `test_interface` 132 (dont `INTERFACE _config chapitre=1984 fin=1988-12`), `test_chapitres` bascule 1984 -> 1989 : `chapitre_change` émis une fois ; mes 7 tests de recette verts (rue 42, foyer 19, etc.).

### Critères d'acceptation
- [x] **CA-I1** : plus aucun `charger("demo")` dans `scripts/ui` ni `principal.gd` (recherche ; restent seulement des `config_demo` d'alias dans les scénarios et `etat_partie.gd`, hors périmètre).
- [x] **CA-I2** : captures ciblées (`titre`, `jouer`, `krach`, `fin`, intro `l8_intro_vue`) PC 1920 × 1080 et téléphones 1440 × 648 / 1280 × 720 comparées à `main` (voir CA-I6) : mêmes écrans, écarts < 1 % de pixels (animation).
- [x] **CA-I3** : ligne `THEME 1980` au démarrage (`jouer`) et à la reprise (`reprise`) avec `--controle` ; test_interface : thème « 1980 » conforme à `Donnees.theme_a`, `has_method` gardé.
- [x] **CA-I4** : 1 504 vérifications (≥ 1 501 + nouvelles), `test_interface`, `test_partie`, `test_ecran` verts, périmètre respecté.
- [x] **CA-I5** : les 5 points : `_config()` via `config_chapitre` (chapitre « 1984 », fin « 1988-12 »), `demo = infos_chapitre()` (principal + modale_intro), commentaire de `ecran_titre`, `frise.gd` sans 179 (`m_fin := 0`, posé par `Hud.maj` depuis `e.m_depart / e.m_fin`), `Partie.chapitre_change` branché sur `_on_chapitre_change` (testé par émission manuelle : textes rafraîchis, thème gardé, aucune erreur).
- [x] **CA-I6** : séries complètes, branche contre `main` 5d7bfd2 (copie isolée).
  - `capture_interface.ps1 -Serie` : 207 lancements chacune, 3 002 s (branche) / 3 000 s (main). Branche : 7 échecs `px2_hud_*` « barre : saut non lancé » ; **main : les mêmes 7 + `l4_carte_conclusion_tel`** (alea). Donc préexistant, non imputable au lot (voir M1). Les 1 073 lignes `UI`/`RUE` du journal sont identiques hors valeurs animées (trafic 2,39 / 2,40, nombre d'images, `bulle apres_carte` oui/non : minutage).
  - `capture_ville.ps1 -Serie` : 136 images, « PX1 : tout est vert » sur les deux.
  - Images : 362 PNG, aucun absent ni de taille différente ; 18 identiques à l'octet ; tous les écrans d'interface à moins de 1 % de pixels différents (seuil 40, 1 pixel sur 4), sauf 3 prises en plein mouvement (`l2_notifs_saut_tel` 10,9 %, `l2_historique_nouveau_*` 4-6 %) que j'ai relues côte à côte : décalage de caméra de 1-2 px et ouverture de la fenêtre à un autre instant, contenu et chiffres identiques. Ville, par zone de décor (bandeau haut, 10-40 % de la hauteur) : 127 des 136 images à moins de 1 % ; 9 entre 1,1 et 14,6 % (`px1_pieces_saut`, `glisse_vol`, `jumeaux_anim`, `camera_retour_glissement`, `pieces_*`, `rue_gazette_720/1366`) = pièces en vol, caméra, jumeaux, écran INDICE allumé ou non au moment de la prise ; `pieces_saut` relue côte à côte : décor identique. Aucune différence de chiffre ni de texte.
  - Chiffres 1984-1988 inchangés (journaux, `integrale`, `test_reference_1984`).
- [x] **CA-I7** : `--export-pack Windows` (1,4 Mo, contient `data/chapitres/index.json`, `chapitres/1984/*.json`, `themes/1980.json`), lancé par `--main-pack` (Godot non console) : étapes `titre`, `jouer`, `reprise` : 0 ERROR, aucune ligne « introuvable » / « JSON invalide », `THEME 1980`, image `jouer` : JANV 1984, compte 12 629 F, Mon argent, banque. Gérard et M. Lefranc : couverts par `test_demo` / `test_recette_intro` (vert) ; non relus à l'image dans l'exe. L'étape `intro` écrit `res://captures/` : 1 ERROR d'artefact de scénario (connu).
- [x] **Sauvegarde du joueur** : `partie_en_cours.sav` inchangé (SHA-256 0EFB110D…2E, écrit le 15/11, avant et après) ; `records.sav` absent avant et après ; aucun fichier de `user://` du joueur modifié ni supprimé par moi.

### Anomalies
- **M1 (mineure, préexistante, hors lot)** : série `capture_interface.ps1`, étape `hud` : « barre : saut non lancé » (`SAUT_IMPOSSIBLE`, `scenarios/interface.gd` ~l. 1722) sur les 7 formats, aussi sur `main` 5d7bfd2. Le code de sortie de la série reste 1 tant que cela dure. À confier au dev-interface.
- **M2 (mineure)** : `m_fin := 0` par défaut dans `frise.gd` (au lieu de 179) : si la frise est dessinée avant le premier `Hud.maj`, elle se dessine pleine échelle ; aucun effet vu dans les captures.
- Hors lot : deux processus Godot (11120, 12116) lancés le 18/11 à 22:33, pas par moi, tournaient pendant toute la recette ; non tués.

### Non vérifié
Vrai téléphone, ressenti en mouvement, bascule réelle de chapitre à l'écran (aucun chapitre 1989 dans `data/`, prévue lot 10 ; testée en logique et signal seulement).
