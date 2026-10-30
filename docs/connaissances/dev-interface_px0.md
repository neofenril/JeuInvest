# Base temporaire de dev-interface (instance PX0)

> Enseignements du lot PX0 (interface pixel). À fusionner dans `dev-interface.md` au lot 02. Dernière mise à jour : 2026-10-29.

## Ce qui est fait (branche `lot/px0-interface`)
- `godot/scripts/pixel/ui/` (sans class_name, chargés par preload) : `interface_px0.gd` (crochet : installer / preparer / lignes_controle, touches C P H, aide), `hud_px0.gd` (barre haute, frise, étiquette MA MAISON), `carte_px0.gd` (héritage D08, lecture seule), `planche_polices_px0.gd`, `cadres_px0.gd` (9-patch ×3, boutons, étiquettes), `polices_px0.gd` (FontVariation, tnum).
- `godot/data/pixel/ui/cadres.txt` (panneau, carte_papier, boutons principal / secondaire / papier + enfoncés, pastille, plaquette, étiquette, cadre_portrait, tampon, ticket) et `icones.txt` (pause, lecture, x2, x3, menu, historique, flèches, curseur, drapeau, croix).
- `.ttf.import` des 5 fichiers : antialiasing=1, hinting=0, subpixel_positioning=0, MSDF non, allow_system_fallback=false (un glyphe manquant se voit au lieu d'être remplacé).

## Faits vérifiés
- Les 4 polices couvrent « ÉÈÊÀÇÔŒÙÎ àéèêçôœùî « » · » et l'espace insécable ; **aucune n'a ▲ ▼ ≡** : sprites obligatoires.
- Atkinson Next et Jersey 10 ont `tnum` (opentype_features {"tnum": 1} sur FontVariation, mesuré par get_string_size) ; Pixelify non, et son « 5 » ressemble à un S : jamais Pixelify pour des chiffres.
- Hauteur de ligne (ascent + descent) : Atkinson ≈ 1,32 em, Pixelify ≈ 1,21, Jersey ≈ 1,1. Barre de 96 : légende 20 + valeur 44 tiennent sans séparation négative ; Jersey patrimoine 56 au plus.
- Carte héritage PC 1119 × 530 (3 colonnes : portrait + COMPRIS / texte 450 / tampon + ticket 360) ; tient aussi au téléphone (portrait ×2).

## Pièges Godot 4.7
- `trait` est un mot réservé (traits) ; attention aussi aux remplacements de texte (« portrait » contient « trait »).
- Une constante de preload ne doit pas porter le nom d'une class_name globale (`Hud` existe) : erreurs absurdes. Suffixer `Px0`.
- `set_anchors_preset` avant que la taille du parent soit connue laisse une taille 0 : utiliser `set_anchors_and_offsets_preset`.
- Boucle sur un tableau littéral : typer la variable (`for etat: String in [...]`) sinon « Cannot infer the type ».
- Vrai clic simulé : `Input.parse_input_event` avec la position physique `get_viewport().get_final_transform() * centre_virtuel`, appui puis relâchement, deux images entre.
- `show_behind_parent` permet un filet (charnière) derrière le texte d'un Label.
- Ticket dentelé : `AXIS_STRETCH_MODE_TILE` en largeur, largeur = 36 + k × 36 px pour ne pas étirer le motif.

## Non fait / limites
- Animation d'entrée de la carte, clignement du portrait, badge de l'historique : hors périmètre PX0.
- Bouton HISTORIQUE 60 px de haut (bande de 72) : sous la cible tactile de 80, comme dans v3.
