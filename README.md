# JeuClaude

Un jeu de gestion pour apprendre l'épargne et la Bourse en France : vous vivez 15 ans de vie active
(1978, 1996 ou 2011), avec un salaire, des imprévus, le Livret A, des actions, des krachs et des euphories,
puis vous comparez votre résultat à celui de trois témoins de votre famille.

## Comment jouer

1. Double-cliquez sur **`Jouer.bat`**, ou ouvrez directement `jeu/index.html` dans Edge ou Chrome.
   Rien à installer, aucune connexion Internet nécessaire.
2. **Nouvelle partie** : choisissez une période, un profil et un objectif (ou gardez les choix conseillés).
3. Le temps est en pause au départ : lancez-le avec ▶ (×1 = 4 s par mois), ▶▶ (×2) ou ▶▶▶ (×3).
4. Ouvrez le **marché** (bouton « Acheter / vendre » ou touche `M`) pour déposer sur le Livret A,
   acheter ou vendre, ou programmer un versement automatique.
5. Répondez aux événements (journal pour la Bourse, courrier pour votre vie).
6. Au bout de 15 ans : le bilan, les étoiles, un titre et trois leçons. « Rejouer la même période
   autrement » garde les mêmes événements de vie pour comparer vos choix.

**Clavier** : `Espace` ou `P` pause, `1` `2` `3` vitesses (ou choix dans une fenêtre), `M` marché,
`Échap` fermer ou menu, `Tab` pour naviguer.

La partie est sauvegardée automatiquement dans le navigateur (une seule sauvegarde, « Continuer »).

## Structure

```
Jouer.bat            lanceur (ouvre jeu/index.html)
docs/                cahier des charges, maquettes, recherches, architecture (05_architecture.md)
jeu/index.html       le jeu
jeu/tests.html       tests automatiques des critères d'acceptation (ouvrir par double-clic)
jeu/css/style.css    styles, palette, ambiances par décennie, animations
jeu/js/              moteur (util, marche, moteur, score) puis interface (ui_*, tutoriel, main)
jeu/data/            toutes les données modifiables : séries, salaires, règles, périodes,
                     événements de vie, titres, leçons, glossaire, textes
```

Pour corriger un chiffre ou un texte, modifiez le fichier de `jeu/data/` concerné : le moteur n'a pas
à être touché. Les détails sont dans `docs/05_architecture.md`.

## Exporter (version Godot)

- **Windows** : double-cliquez sur `Exporter_Windows.bat`. Il produit `export\windows\JeuClaude.exe`
  (environ 105 Mo), un fichier unique qui contient tout le jeu : il suffit de le partager.
  Au premier lancement, Windows SmartScreen peut afficher « Windows a protégé votre ordinateur »
  (programme non signé) : cliquer sur « Informations complémentaires » puis « Exécuter quand même ».
  La partie est sauvegardée dans `%APPDATA%\Godot\app_userdata\JeuClaude\`.
- **Android** : double-cliquez sur `Exporter_Android.bat` (il faut `outils\jdk-17` et
  `outils\android-sdk` complets). Il produit `export\android\JeuClaude.apk` (APK de test signé avec
  la clé de debug). Pour l'installer : copier l'APK sur le téléphone et l'ouvrir en autorisant
  l'installation depuis des sources inconnues, ou brancher le téléphone en mode débogage USB et lancer
  `outils\android-sdk\platform-tools\adb.exe install -r export\android\JeuClaude.apk`.
- Les icônes sont dessinées en SVG (`godot\icon.svg`, `godot\assets\icone\*.svg`) ; après une
  modification, régénérer les PNG et l'ICO avec `godot\outils\generer_icones.gd` (voir l'en-tête du script).

*JeuClaude est un jeu pédagogique : il simplifie la réalité et ne donne aucun conseil financier personnalisé.*
