# Base de connaissances de dev-interface

> Lire d'abord `CLAUDE.md` et le **socle commun `docs/connaissances/developpeur.md`** (architecture, décisions, pièges Godot, captures). Ici : seulement ce qui est propre à dev-interface. Concise.
> Créée le 2026-10-28 par le chef de projet ; mise à jour le 2026-10-29 (lot 01 : découpage de `principal.gd`, raccourcis de test).

## Périmètre
Écrans, HUD, modales, fenêtre Banque, ville vectorielle, animations, game feel, adaptation PC / téléphone, captures. Consignes uniquement via `docs/lots/lot_NN.md` ; ne modifier que les fichiers attribués par le lot. Direction artistique : `docs/09`, `docs/13` ; retours du joueur `docs/10` prioritaires.

## Fichiers possédés par défaut (carte complète : `chef-de-projet.md` §1)
- `godot/scripts/ui/*.gd`, `godot/scripts/ville/*.gd`, `godot/scripts/juice.gd`, `godot/scripts/ecran.gd`
- `godot/scripts/outils/capture.gd`, `godot/outils/capture.ps1`, `godot/captures/`, `godot/outils/generer_icones.gd`
- `godot/scenes/`, `godot/shaders/`, `godot/assets/`, `godot/icon.svg`
- Partagés selon le lot (propriétaire par défaut) : `scripts/principal.gd`, `project.godot` (`[display]`, `[gui]`, `[rendering]`, `[jeuclaude]`).

## Structure de la scène principale (après le lot 01)
| Fichier | Rôle |
|---|---|
| `scripts/principal.gd` (≈ 585 l., plafond 600) | Calques et nœuds, câblage des signaux, mise en place / reprise, `_process`, touches de jeu (Espace / P, 1-3, M / B, H), réactions aux signaux de `Partie`, fenêtre Banque, menu, historique, infos (foyer, comparaison, frais), sauvegarde à la fermeture, `preparer_capture` (délégation). API publique utilisée par les autres modules : `demo ville hud modales titre sequences en_titre pluie_jusqua dernier_releve`, `nouvelle_partie reprendre demarrer_direct jouer demander_nouvelle_partie maj_titre ouvrir_banque ouvrir_historique ouvrir_menu expliquer_comparaison toucher_batiment toucher_notif`. |
| `scripts/ui/ecran_titre.gd` (`EcranTitre`) | Construction du titre (`construire(demo)`), `maj(sauvee, en_cours)`, `texte_reprise()`, `donner_focus()`. Émet `jouer_demande`, `nouvelle_partie_demandee` ; n'appelle jamais `Partie`. Ligne d'aide `l_aide` visible seulement si `Reglages.raccourcis_test()` et pas mobile. |
| `scripts/ville/sequences.gd` (`Sequences`, nœud enfant) | File des « vedettes » (`vedette`, `occupe`), attrape-toucher (A34), séquences banquier / journal / courrier + panne / naissance / fin, `petite_news`, `clignoter_maison`, `maj_media` (écran du toit). Références via `installer(jeu, ville, hud, modales, calque_modales)` ; rappelle `jeu.ouvrir_banque`, `jeu.nouvelle_partie`, `jeu.demarrer_direct`, `jeu.pluie_jusqua`. |
| `scripts/outils/reglages.gd` (`Reglages`) | `raccourcis_test()` : faux dans toute version exportée (tag `template`), avec `-- --joueur`, ou si `jeuclaude/raccourcis_test=false`. |
| `scripts/outils/raccourcis_test.gd` (`RaccourcisTest`) | F6 / F7 (naissance), F8 et triple toucher sur la date (`sauter_moment`). Créé par `principal._ready` **seulement si** `Reglages.raccourcis_test()`. F10 : `ecran.gd` (soumis au même réglage ; `--telephone` des captures passe par `basculer_telephone()` et reste actif). |
| `scripts/outils/scenarios_capture.gd` (`ScenariosCapture`) | Répartiteur des `--etape=` (créé à la demande par `preparer_capture`) + outils : `partir_de_la_rue`, `delai`, `attendre_que`, `aller_a`, `aller_a_modale`, `strategie_active` (copie de `StrategieTest`, à remplacer au lot 02, T13), `appuyer_bouton`, `clic_dehors`, `touche`, `position_fenetre`, `vitesse_mesuree` ; statiques `option(nom)`, `mode_capture()`. |
| `scripts/outils/scenarios/*.gd` (sans `class_name`) | Familles : `titre` (sans départ dans la rue), `banque`, `ville`, `ecrans` (dont `courrier_relu_echap`), `outils` (dont `raccourcis`), `interface` (PX2 : `planche_cadres`, `cibles`, `hud`, `polices_jeu`). Chaque fichier : `const ETAPES`, `var sc`, `func jouer(etape)`. |

## Interface pixel (lot PX2, 2026-11-03)
- **Échelle** (`Ecran`) : à l'exécution, `content_scale_mode = DISABLED` et `content_scale_factor = T / 3` exact (project.godot garde canvas_items pour la vitrine PX0, ignorée par `Ecran`). Zone logique = taille physique × 3 / T (1080p : 1920 × 1080 ; 720p : 1920 × 1080 ; 1366 × 768 : 2049 × 1152 ; téléphone simulé 1600 × 720 à 267 dpi : T = 3, zone 1600 × 720). PC : T = floor(h / 324) (360 à 10 % près : une fenêtre agrandie 1920 × 1061 garde T = 3). Mobile : plus petit T tel qu'un bouton de 84 px (28 texels) fasse 48 dp. `cible_min()` = 48 dp (mobile) ou 48 px physiques (PC), en px virtuels. `compact()` : zone < 1600 × 900. Avec « canvas_items + expand », Godot tronque la zone logique (2048 au lieu de 2049) : texels irréguliers ; d'où le mode désactivé.
- **Thème** : `Style` (mêmes noms qu'en V2 ; couleurs = variables statiques tirées de `PalettePixel`), `PolicesPixel` (Atkinson tnum pour chiffres et textes, Pixelify ≥ 28 pour titres et boutons, Doto pour les affichages), `CadresPixel` (9-patch ×3, substitutions de palette : `{"or": "neon_rose"}` pour le liseré). `Style.label` remplace Pixelify < 28 par `petites_capitales()` ; `Style.sans_fleche` remplace « → » (absent des 4 polices) par « › » ; « ▲ ▼ ≡ » aussi absents : sprites.
- **Garde-fous** : `Modales._garde_cible` (signal `node_added`) donne à tout bouton sous les modales un côté ≥ `cible_min()` ; contrôles `UI ` de la famille de captures `interface` (planche_cadres, cibles, hud, polices_jeu) ; série `outils/capture_interface.ps1 -Serie` (1920 × 1080 en `--fullscreen`).
- **Modales découpées (T9)** : façade `Modales` (état, fond, fermeture, clavier, `poser / centrer / fixer_largeurs / apparaitre / assombrir`) + morceaux RefCounted (`ModaleJournal`, `ModaleCourrier`, `ModaleBanquier`, `ModaleReleveFin`, `ModaleSimples`, `ModaleHistorique`) + `ModaleOutils` statique. `_on_choix_journal` reste dans la façade (captures, recette).
- **Papier** : cartes du banquier, courrier, relectures = `Style.papier(source)` ; textes `ENCRE`, `TEXTE_PAPIER_2`, `GAIN_PAPIER`, `ENCRE_ROUGE` (jamais `TEXTE` crème sur crème). Pages droites au repos (rotation 0 : pixels nets).
- Pièges vus : `get_meta(nom, null)` affiche une erreur si la clé manque (tester `has_meta`) ; affecter une instance libérée à une variable typée = SCRIPT ERROR (passer par `WeakRef`) ; en PowerShell, `$l` et `$L` sont la même variable ; ne jamais arrêter un Godot qui n'est pas à soi (dev-ville capture en parallèle).

## PX0 (fusionné depuis dev-interface_px0.md, supprimé)
- Les 4 polices couvrent « ÉÈÊÀÇÔŒÙÎ àéèêçôœùî « » · » ; Pixelify n'a pas `tnum` et son « 5 » ressemble à un S : jamais pour des chiffres. Hauteur de ligne : Atkinson ≈ 1,32 em, Pixelify ≈ 1,21.
- `.ttf.import` : antialiasing 1, hinting 0, pas de sous-pixel ni MSDF, `allow_system_fallback=false` (un glyphe manquant se voit).
- Pièges Godot 4.7 : `trait` est réservé ; une constante de preload ne doit pas porter le nom d'une class_name ; `set_anchors_and_offsets_preset` plutôt que `set_anchors_preset` avant la mise en page ; typer la variable de boucle sur un tableau littéral ; ticket dentelé en `AXIS_STRETCH_MODE_TILE`.

## Où ajouter…
- **Une séquence animée** : `_sequence_x(c)` dans `sequences.gd`, lancée par `vedette()` depuis `jouer_modale()` (ou une fonction publique appelée par `principal._on_notif`).
- **Une étape de capture** : le nom dans `ETAPES` de la famille, son cas dans `jouer()`, la ligne de `outils/capture.ps1` (fichier de dev-logique au lot 01). Une nouvelle famille : fichier dans `scenarios/` + nom dans `ScenariosCapture.FAMILLES`. Une étape inconnue démarre simplement dans la rue.
- **Un raccourci de test** : une touche dans `RaccourcisTest._unhandled_input` + la ligne d'aide d'`EcranTitre`. Jamais dans `principal.gd`.

## Points d'attention
- Les données et calculs viennent de `Partie`, `EtatPartie` et des statiques de `scripts/logique/` (liste dans `chef-de-projet.md` §2) : n'ajoute pas de règle métier dans l'UI ; demande la fonction à dev-logique via le chef de projet. `Format` et `Dates` appartiennent à dev-logique.
- Les appels entre modules passent par une référence `jeu: Node` (principal.gd n'a pas de `class_name`) : appels **dynamiques**, non vérifiés à l'analyse. Une faute de nom n'apparaît qu'à l'exécution : relancer les captures concernées (toutes : boucle du compte rendu ci-dessous).
- Toujours capturer PC (1280×720) et téléphone (`--telephone`) et relire les PNG.
- Ne jamais modifier un script pendant qu'une série de captures tourne (chaque lancement recharge les scripts).
- Entrées simulées : `Input.parse_input_event` attend des coordonnées **fenêtre** ; pour viser un contrôle : `sc.position_fenetre(c)` (`get_final_transform()` × position canevas). Vérifié : le triple toucher atteint la date du HUD.
- Version du joueur depuis l'éditeur : `-- --joueur` (ex. `--etape=raccourcis --joueur`).

## Journal
- 2026-11-03, PX2 : T16 (enveloppe en vol), T9 (découpage de modales.gd, 1 453 → 294 l. + 7 morceaux), échelle à texel entier, thème pixel, HUD (HAUT 102, BAS 114, HISTORIQUE 96 px), cartes papier, journal, classeur, carnet, T15, B1, B3, version 0.3, garde de lecture du résumé de sauvegarde (format 3) dans `EcranTitre.maj`.
- 2026-10-29, lot 01 : découpage de `principal.gd` (1 611 → 585 lignes) en `EcranTitre`, `Sequences`, `RaccourcisTest`, `Reglages`, `ScenariosCapture` + 5 familles ; raccourcis de test retirés de la version du joueur ; nouvelle étape `raccourcis`. Vérifications : toutes les étapes de capture.ps1 sans erreur, comparaison pixel à pixel avec `main` (script de comparaison System.Drawing dans PowerShell 5.1, échantillon 1 pixel sur 16, seuil 30), exe exporté depuis le worktree.
