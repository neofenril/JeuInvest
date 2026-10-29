# Images pixel du jeu (grilles de texte)

Tout le pixel art du jeu est écrit ici, en texte, une lettre par pixel (docs/16 §4.4). Les grilles sont
compilées au lancement par `GrillePixel` (`scripts/pixel/grille.gd`) en images, puis en textures, dans les
3 variantes de la palette (jour, nuit, orage). Ce format sert aussi de cahier des charges pour des images
fournies plus tard (graphiste, IA nettoyée) : même nom, même taille, même palette, même origine.

## Dossiers

| Dossier | Contenu | Propriétaire |
|---|---|---|
| `ville/` | personnages, portraits, maison, décor, véhicules | dev-ville |
| `ui/` | cadres 9-patch, icônes, flèches, tampon, ticket | dev-interface |

Nom complet d'une image : `<dossier>/<nom>` (ex. `ville/lefranc_affable`, `ui/panneau`), **unique** dans
tout le jeu. Les images produites par code (`MatieresPixel`) sont rangées sous `matiere/…` (ciel, trottoir,
chaussée…) dans le même catalogue, donc soumises aux mêmes contrôles.

## Format d'un fichier `.txt` (UTF-8)

```
# Commentaire : ligne ignorée (aussi permis entre les rangées d'une image).
: e encre                 # légende : une lettre -> un identifiant de la palette
: c caramel
: o encre 50              # alpha facultatif en % (1 à 100, défaut 100) : réservé aux ombres de l'interface
image gerard_repos_1 16x28 origine 8,27
......eeeee.....
(exactement 28 rangées de 16 caractères)
image gerard_repos_2 16x28
...
```

- **Légende** : `: <lettre> <couleur> [alpha %]`. Elle vaut pour toutes les images qui la suivent dans le
  fichier (une lettre peut être redéfinie plus bas ; la légende ne passe pas d'un fichier à l'autre).
  Lettre = un caractère imprimable, **sensible à la casse** (`r` et `R` sont deux couleurs), sauf `.`, `#`,
  `:` et l'espace.
- **`.` = transparent**, toujours.
- **En-tête** : `image <nom> <L>x<H> [origine x,y]`. Nom : minuscules, chiffres, `_`. Origine = point
  d'ancrage, en pixels depuis le coin haut gauche ; par défaut, le milieu du bas `(L/2, H-1)` (les pieds
  d'une figurine, le bas d'un bâtiment).
- Puis **exactement H rangées de L caractères**. Un commentaire `# …` en fin de ligne est permis sur les
  lignes de légende et d'en-tête, jamais dans une rangée.
- **Erreurs détectées** (test `tests/test_pixel.gd`, et `push_error` au chargement) : largeur ou nombre de
  rangées différents de l'annonce, lettre sans légende, couleur inconnue, nom en double, ligne inattendue.

## Palette « Rue 84 » (docs/16 §2.3)

40 identifiants, dans cet ordre : `encre, nuit, ardoise_sombre, ardoise, gris_pierre, zinc_clair, creme,
blanc_chaud, pierre_ombre, pierre, pierre_claire, brique_sombre, brique, tuile, terre_cuite_claire,
bois_sombre, bois, bleu_nuit, bleu_ardoise, ciel, ciel_clair, vert_sombre, vert, vert_clair, orange,
rouge_auvent, bleu_vif, peau_claire, peau_ombre, caramel, lumiere, neon_rose, ambre, or, gain, perte, gel,
cuivre, gain_papier, perte_papier`.

- Les grilles sont **toujours dessinées en couleurs de jour** ; nuit et orage sont calculées par substitution
  couleur par couleur (`PalettePixel.convertir`). Émissives (identiques dans les 3 variantes) : `lumiere,
  neon_rose, ambre, gain, perte, gel, cuivre, gain_papier, perte_papier`.
- Aucune autre couleur n'est permise : le test contrôle chaque pixel de chaque image dans les 3 variantes.
- Alpha : 0 ou 1 dans les sprites ; un alpha déclaré dans la légende seulement pour les ombres portées de
  l'interface. Les transparences d'affichage (panneau à 0,94, voile, halos) se font à l'affichage, jamais
  dans les images.

## Conventions de dessin (docs/16 §2.2 à §2.5)

- Lumière en haut à gauche ; 3 tons par matière (clair, moyen, sombre), 1 reflet au plus.
- Personnages et petits objets : contour **encre** de 1 px, fermé ; bâtiments : contour dans le ton le plus
  sombre de leur matière. Pas de dégradé, pas de « pillow shading », marches régulières (1-1-1, 2-2-2).
- Tailles : figurine 16 × 28 (origine au milieu des pieds), portrait de carte 48 × 48 (trois quarts),
  portrait de bulle 32 × 32, maison de Gérard 96 × 124, réverbère 8 × 56, platane 40 × 64, R5 48 × 20.
- Animations : une image par entrée, numérotée (`gerard_marche_1` … `_4`, `gerard_repos_1`, `_2`).
- Expressions : un nom par expression (`lefranc_affable`, `lefranc_grave`, `lefranc_yeux_fermes`).

## Outil d'écriture

Une grille peut être tapée directement. Pour les grandes images, il est plus sûr de l'écrire en « suites »
(ex. `12. 3e 4p 1e` = 12 transparents, 3 encre, 4 peau, 1 encre) puis de la développer en rangées complétées
par des points : la largeur est alors garantie. Vérifier ensuite à l'écran avec l'étape `planche`
(`godot/outils/capture_px0.ps1 -Etape planche -Taille 1920x1080`).
