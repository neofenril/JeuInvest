# Audit de préparation des fonctionnalités restantes (avant et après la 0.5 « jouable »)

> Chef de projet, 2026-11-13. État : `main` d70dba7 (lots 02, 03, 03-R, 03-V2, 04-L). En cours : 05-L phase B (`lot/05-logique` 4025ba9, B1-B7 commités), 04-I étape 2 (`lot/04-interface`, modification de `sequences.gd` non commitée). Question du joueur : « quelles sont les prochaines fonctionnalités à développer et est-ce que le chef de projet a les informations nécessaires pour les commencer ? ».
> « Prête » = plan, spec, contenus d'experts, maquettes, contrat et critères d'acceptation présents. Les numéros « 06-L / 06-I » de l'ancienne feuille de route n'existent plus : le moteur du krach est dans **05-L**, son écran dans **05-I** (`lot_06.md`).

## 1. Liste ordonnée

| # | Fonctionnalité | Lot / plan | Statut | Ce qui manque / remarque |
|---|---|---|---|---|
| 1 | Projets à l'écran + carte de dilemme dans la vraie partie | 04-I étape 2 → R-MAISON (`lot_05.md` §5.1, §7.2) | **Prête, en cours** | Exception de propriété actée : `sequences.gd` prêté à dev-interface (`lot_06.md` §10 A10), **ajouter `gazette` → bâtiment média** dans la même modification |
| 2 | Moteur de la rue et du krach (Jean-Mi, classement, voisins, kiosque, 7 jours du Lundi noir, « un an après ») | 05-L phase B → recette (`lot_05.md` §5.3, §7.1, **§9 bis**) | **Prête, presque finie** | Écart `couverture_min` 30 000 F **validé** ; petit ajout B8 (`etape_texte` de Jean-Mi, vouvoiement de `temoins.json`), non bloquant |
| 3 | 05-I : classement permanent (bloc PC / languette téléphone), bloc « La rue », notifications de la rue, relectures longues, onglet LA RUE | `lot_06.md` §5 + **§10** | **Prête** (maquettes docs/24 §2.1-2.3 arbitrées aujourd'hui) | Départ après R-MAISON |
| 4 | Lundi noir en tableau dans la modale du krach ; « Le krach, un an après » à 3 barres (anciens 06-L / 06-I) | moteur 05-L ; écran 05-I (`lot_06.md` E5, E6, A5, A6) | **Prête** | Données docs/26 déjà dans `krach.json` |
| 5 | Écran de fin à 4 barres + rang + réplique (+ projets, Sylvie) | 05-I (`lot_06.md` E7, A7) | **Prête** | — |
| 6 | Sortie 0.5 « jouable » : exports, partie chronométrée, fiche de retour | `lot_06.md` §6 + A11, A12 | **Prête** | Exe lancé par le joueur (Smart App Control) |
| 7 | Mesure de la durée de partie (≤ 20 min avec COURRIER) | `lot_06.md` §6 point 5, CA-U9, A12 | **Prête** | Faite par le coordinateur à la sortie 0.5 ; aucune demande |
| — | *Après la 0.5* | | | |
| 8 | 07-L : titre d'époque, record dans `user://records.sav`, collection | `lot_07.md` (**brouillon écrit**) | **Pas prête** | **G6** (game designer ; point 2 bloquant : nature épargne / dépense de chaque choix de carte) ; **C1** (client : critère du record) |
| 9 | 07-I : écran de fin avec titre, record, hors record ; meilleur résultat et collection à l'écran titre | `lot_07.md` | **Pas prête** | **U5** (UX) + contrat de 07-L ; défauts D10-D11 écrits sinon |
| 10 | Équilibrage (cartes, montants, durée) | à planifier | **Pas prête** | Verdict du joueur sur la 0.5 + mesure du n° 7 ; puis le game designer (docs/27 §3.2 : retirer S1, S3, S5, S9 d'abord) |
| 11 | Sauvegarde manuelle SV-L / SV-I | `lot_sauvegarde.md` (mis à jour : `kind` réels, `retours` créé par 07-L) | **Pas prête** | **Feu vert du joueur** (« ne pas lancer tout de suite ») ; **U6** (UX) ; seuils (G6 point 6) |
| 12 | Icônes manquantes (6 projets 16 × 16, plaque LA RUE, 4 portraits de voisins 32 × 32) | peaufinage | **Pas prête** | **U7** (description de chaque sprite) ; repli actuel : initiales |
| 13 | Sons | backlog T6 | **Pas prête** | **C1 point 4** (en veut-on pour la 1.0 ?) + **U7** (liste, caractère, règles) ; aucun son dans le dépôt : bruitages à générer dans le code |
| 14 | Peaufinage reporté : animations de carte, caméra, Sylvie à la fenêtre, traces P10, voisins dans la rue, Porsche, kiosque défilant, séquence du Lundi noir, réalisations animées, objets des cartes | `feuille_de_route_jouable.md` §6 ; travail commencé sur `lot/03-ville2-suite` (local) | **Pas prête, volontairement** | **Verdict du joueur** sur la 0.5 (ordre des priorités) ; puis storyboard UX du Lundi noir (docs/15 §5.1 n'en donne qu'une esquisse) |
| 15 | Signature de l'exe | report 8 de `feuille_de_route.md` §2.8 | **Pas prête** | Décision et achat de l'utilisateur (certificat) ; question Q-J2 à poser avec la 0.5 |
| 16 | APK de publication | T10 | **Pas prête** | Clé de signature créée et gardée par l'utilisateur (jamais dans le dépôt) ; **APK jamais essayée sur un téléphone** (T2) : Q-J3 |
| 17 | iOS | T11 | **Impossible ici** | Mac + Xcode + compte Apple Developer |
| 18 | Questionnaire de profil de risque | « À faire plus tard » de `CLAUDE.md` | **Mis de côté par le joueur** (29/10) | Aucune demande tant que le joueur ne le rouvre pas |

## 2. Ce que j'ai écrit moi-même aujourd'hui
- `lot_06.md` **§10** : arbitrage des avis UX (docs/24 §3, écarts 1 à 7), game designer (docs/27 idées 1-3) et boursier (docs/26) ; prêt de `sequences.gd` ; CA-U2, U4, U6, U7, U11 modifiés, CA-U12 ajouté.
- `lot_05.md` **§9 bis** : écart `couverture_min` validé, ajouts de contrat constatés (`texte_long`, `persistant`, `regle`), tâche B8.
- `lot_07.md` : **brouillon** complet (décisions par défaut, interfaces `Titres` / `Records`, carte des fichiers, CA-T1 à T9) ; lançable dès G6 + C1.
- `lot_sauvegarde.md` : `kind` réels, `retours` déplacé dans 07-L (07 ne dépend plus de SV).

## 3. Demandes à lancer maintenant (textes exacts)

### Game designer — G6 (bloque 07-L au point 2)
« Préparation du lot 07 (P5 « Le score de la rue », plan brouillon `docs/lots/lot_07.md`) et de la sauvegarde manuelle (`docs/lots/lot_sauvegarde.md`). Merci d'écrire `docs/28_game_designer_titres.md` : (1) relire les 9 titres de docs/15 §6 face au jeu tel qu'il est codé (cartes de docs/23, projets de docs/25 et 27 avec « RENONCER POUR L'INSTANT » de P2C, instantané du krach, Jean-Mi, escargots C06) : condition exacte de chacun, seuils (2 %, 30 %, 6 et 7 choix), ordre ; (2) **bloquant** : pour chaque choix des cartes C00 à C15, dire s'il compte comme « épargne », « dépense » ou « neutre » (titres 4 et 5) ; (3) textes définitifs des 9 titres et de leur « pourquoi » (≤ 15 mots, vouvoiement, aucun titre qui flatte la spéculation ou récompense « Renforcer ») ; (4) collection : titres non obtenus montrés en « ??? » ou cachés ? (5) les 5 étoiles actuelles du bilan restent-elles à côté du titre, ou le titre les remplace ? (6) sauvegarde manuelle : relire les seuils de `rythme.json > sauvegarde` (une proposition « avec seuil » tous les 6 mois au plus, carte ≥ 1 mois de salaire, ordre ≥ 20 % du patrimoine et ≥ 5 000 F) et dire si « Le krach, un an après » rejoint la liste « toujours » ; (7) pour chaque titre, une stratégie de jeu simple qui l'obtient (une phrase), pour le test CA-5.1. Les défauts du chef de projet sont dans `lot_07.md` §1 ; tout est remplaçable dans `data/titres.json` et `foyer.json` sans code, sauf le point 2. »

### Client — C1 (bloque 07-L au point 1)
« Quatre arbitrages courts. (1) Record personnel (docs/10 du 29/10, `docs/lots/lot_07.md` D4) : nous proposons de retenir le **meilleur écart final en % face à Tata Livret** (même vie, même salaire : il mesure les placements, pas la chance), en affichant aussi le rang dans la rue et le titre. Validez-vous, ou préférez-vous le patrimoine final, ou le rang ? (2) Une partie rejouée depuis une sauvegarde manuelle est hors record (décision du joueur) : son titre entre-t-il quand même dans la collection ? (défaut : oui, rejouer un choix est pédagogique.) (3) Ton des titres : relire les 9 titres de docs/15 §6 quand le game designer aura écrit docs/28 (aucun ne doit flatter la spéculation ni culpabiliser). (4) Sons : en voulez-vous dans la 1.0 (quelques bruitages courts générés dans le code, coupables dans le menu), ou plus tard ? »

### UX — U5 (souhaitée avant 07-I), U6 (préparation de SV, aucun développement), U7 (basse priorité)
« **U5** — Lot 07 (`docs/lots/lot_07.md` D10-D11). Maquettes texte comme docs/24, PC 1920 × 1080 et téléphone 1440 × 648, sans animation nouvelle : (1) écran de fin complet : votre bloc de 4 barres (docs/24 §2.6) + titre d'époque (nom, sans chiffre) et sa phrase « pourquoi », ligne « Projets : n sur 2 réalisés », portrait 48 × 48 de Sylvie, « Nouveau record ! », ligne « Partie rejouée depuis une sauvegarde : hors record » ; dites ce qui se replie au téléphone (les 5 étoiles existantes restent en attendant l'avis du game designer) ; (2) écran titre : ligne « Meilleur résultat : + 12 % face à Tata Livret · 2e de la rue · Le marin par gros temps » et bouton TITRES « 3 / 9 » ; (3) fenêtre de la collection (9 titres ; obtenus avec nombre et première date ; non obtenus « ??? »). Contraintes : chiffres en Atkinson, cibles ≥ 48 dp, rien de caché au téléphone. Réponse dans `docs/29_ux_fin_et_titres.md`.
**U6** — Sauvegarde manuelle (`docs/lots/lot_sauvegarde.md`, planifiée, pas lancée : maquettes de préparation seulement). PC 1920 × 1080 et téléphone 1440 × 648 : (1) menu (REPRENDRE, SAUVEGARDER, CHARGER, HISTORIQUE, bascule « Proposer de sauvegarder avant les grandes décisions », QUITTER LE JEU) ; (2) écran des 3 emplacements en mode sauver et charger (vide, plein, confirmation d'écrasement, confirmation de chargement en cours de partie, phrase « Le hasard ne change pas : seuls vos choix peuvent changer. ») ; (3) bandeau non bloquant « Sauvegarder avant de choisir » dans une carte (krach, héritage, carte de dilemme, projet) et son état « Sauvegardé », sans gêner les touches 1/2/3 ; (4) bouton secondaire « Sauvegarder d'abord » dans la feuille d'ordre ; (5) bouton CHARGER de l'écran titre. Réponse dans `docs/30_ux_sauvegarde.md`.
**U7** — Basse priorité (après le verdict du joueur sur la 0.5). (1) Décrire, une ligne chacun, les sprites manquants à dessiner dans le code selon docs/16 : 6 icônes de projet 16 × 16 (P1A à P2C), plaque de rue 16 × 16 (onglet LA RUE), 4 portraits 32 × 32 (Tata Livret, Tonton Matelas, Jean-Mi, Mme Lopez) : silhouette, couleurs de la palette, ce qui les distingue à petite taille ; (2) proposer une liste de 12 sons au plus (pièces, notification, carte, krach, fin, boutons…), leur caractère (bruitages courts générés dans le code), leurs règles (rien pendant un saut sauf les notifications ★, bouton pour couper le son, volume par défaut), à faire valider par le client. Réponse dans `docs/31_ux_icones_sons.md`. »

### Banquier — rappel K3 point 2 (non bloquant)
« Rappel de K3 point 2, non bloquant (les données sont déjà dans le jeu en certitude C) : Jean-Mi achète en 04/1987 une Porsche 944 d'occasion à 140 000 F, apport 30 000 F, crédit 110 000 F sur 48 mois à 12 % (mensualité 2 897 F), décote mensuelle de docs/19 §2.4, revente en 02/1988 ; docs/18 §5 donnait 12-14 % et une 944 neuve à 240-280 000 F. Validez-vous ces chiffres (certitude A/B/C) ? En plus, si vous l'avez avec certitude : le prix d'une baguette en 1984 et en 1985 (variante chiffrée de la phrase V05 de Tonton Matelas, docs/27 §2.2). Réponse en §7 de docs/25. »

### Boursier
Aucune demande : docs/26 couvre tout ce qui reste jusqu'à la 1.0. (Ses points C du §7 ne se lèveront qu'avec des archives fournies dans `docs/sources/`.)

### Testeur (à joindre aux prochaines recettes)
« Pour R-MAISON, la recette 05-L et R-RUE, appliquez en plus `docs/lots/lot_05.md` §9 bis et `docs/lots/lot_06.md` §10 : `scripts/ville/sequences.gd` est prêté à dev-interface (diff limité à `jouer_modale` et à la séquence de la carte, lignes `RUE fiche kind=carte|projet|gazette appel=modales`) ; CA-U2, U4, U6, U7, U11 sont reformulés et CA-U12 est ajouté. L'écart `couverture_min` = 30 000 F de 05-L est validé. »

### Consignes aux développeurs (par le coordinateur)
- **dev-interface (04-I étape 2, en cours)** : « `sequences.gd` vous est prêté (`lot_06.md` §10 A10). Dans la même modification, ajoutez `kind "gazette"` → caméra sur le bâtiment média (pas de porte), `modales.call("gazette", c, depart)` si la méthode existe sinon `courrier`, et la ligne `RUE fiche kind=<k> appel=<modales|courrier>` pour carte, projet et gazette. Rien d'autre dans `scripts/ville/`. »
- **dev-logique (05-L)** : « Tâche B8 de `lot_05.md` §9 bis (`etape_texte` de Jean-Mi, vouvoiement de `temoins.json`, test), avant de remettre la branche au testeur si possible ; sinon au passage 2. »

### Joueur (par le coordinateur, avec l'envoi de la 0.5 ; rien d'urgent)
- **Q-J2** : « Windows bloque l'exe parce qu'il n'est pas signé. Pour le diffuser à d'autres que vous, il faut un certificat de signature (payant chaque année) ; sinon on continue comme aujourd'hui (vous le lancez vous-même). On s'en occupe maintenant ou plus tard ? »
- **Q-J3** : « Avez-vous pu installer l'APK sur un téléphone Android ? Pour une version de publication, il faudra une clé de signature que vous seul garderez (hors du dépôt, avec un mot de passe que vous choisirez) : on vous préparera le script le moment venu. »
- **Q-J4** : feu vert pour la sauvegarde manuelle (`lot_sauvegarde.md`), à demander **après** son verdict sur la 0.5.

## 4. Risques relevés pendant l'audit
- `lot04-interface` modifie `scripts/ville/sequences.gd` (fichier de dev-ville) sans prêt écrit : régularisé par `lot_06.md` §10 A10 (dev-ville n'a aucune branche ouverte sur ce fichier).
- Jean-Mi n'existe que par des notifications : risque principal du verdict (docs/27 §3.1) ; parade : notifications ★ persistantes (livrées par 05-L), étape dans le bloc « La rue » (B8 + A2), question 3-4 de la fiche de retour.
- Mesure de durée faite une seule fois, à la main : si > 25 min, la décision passe par le joueur après son verdict, pas avant la sortie.
