# 32 — Pop-up de début de partie (« Qui suis-je, que dois-je faire ? »)

> Game designer, 2026-11-17. Demande du joueur : docs/10 (17/11, point 6). Backlog : docs/lots/backlog_retours_0_6.md.
> Chiffres lus dans `godot/data/` : `demo.json` (Gérard, 26 ans, technicien, janvier 1984 → décembre 1988, `depart_F.cc` = 11 000 F, aucun livret) ; salaire 6 790 F/mois en 1984 (`salaires.json`, déjà vérifié par le game designer le 28/10).

## 0. Écart volontaire à la demande : on ne nomme PAS le krach

La demande cite « krach en octobre 1987 ». **Refusé : décision A5 du cahier des charges** (« la frise n'annonce jamais les krachs », A8 : accroches sans divulgâcheur). Annoncer le krach dès l'écran d'accueil donnerait la réponse, récompenserait le market timing (vendre en septembre 1987) et viderait le Lundi noir de sa leçon et de son trophée. On promet des « secousses » sans date ni nature.

## 1. Texte de la pop-up

**Titre** : `JANVIER 1984`
**Sous-titre** (petit, sous le titre) : `Votre vie d'épargnant commence`

**Bloc 1 — QUI VOUS ÊTES**
> Vous êtes Gérard, 26 ans, technicien. Vous vivez avec Sylvie, sans être mariés. Vous gagnez {salaire} par mois et vous avez {depart} sur votre compte courant.

**Bloc 2 — CE QUI VOUS ATTEND**
> Cinq ans de vie, de 1984 à 1988 : des dépenses de famille, des projets, des surprises. M. Lefranc, votre banquier, vous présentera ses placements. Les marchés auront leurs secousses.

**Bloc 3 — VOTRE OBJECTIF**
> Faire mieux que Tata Livret, qui laisse tout sur son Livret A. Mener vos projets à bien. Et finir avec un titre : lequel méritez-vous ?

**Bloc 4 — COMMENT JOUER**
> Le temps passe seul. COURRIER (touche N) avance jusqu'au prochain événement ; à vous de décider quand on vous le demande.

**Bouton** : `COMMENCER` (un seul bouton, Entrée / Espace le valident).

Gabarits (pas de chiffre en dur, comme `foyer.json`) :
- `{salaire}` = salaire mensuel de janvier 1984 formaté (« 6 790 F ») ;
- `{depart}` = `depart_F.cc` formaté (« 11 000 F »).
Si le profil ou la période changent un jour (points 2 et 5 du même retour), seuls les gabarits et le bloc 1 changent.

Volumes : bloc 1 = 29 mots, bloc 2 = 30, bloc 3 = 26, bloc 4 = 22 ; ≈ 110 mots en tout, lisible en 30 s. Sur smartphone : chaque bloc commence par son intitulé en capitales (QUI VOUS ÊTES, CE QUI VOUS ATTEND, VOTRE OBJECTIF, COMMENT JOUER), corps à la taille des textes de cartes ; si la hauteur ne suffit pas, défilement vertical, le bouton COMMENCER restant toujours visible en bas (jamais sous le pli).

Contrôles : vouvoiement ; aucun mot interdit (« achetez », « vendez », « c'est le moment », « auriez dû », « étoile », « Cousin Indice ») ; aucun conseil ; aucune date ni nature d'événement de marché (A5) ; « Tata Livret » et « M. Lefranc » sont les noms déjà présents dans le jeu.

## 2. Comportement

- **Quand** : à chaque **Nouvelle partie**, après l'écran titre, sur la rue déjà affichée en janvier 1984, temps **en pause** jusqu'au clic sur COMMENCER. Pas à « Continuer ».
- **Avant** toute autre pop-up (présentation du Livret A du premier mois, choix du projet P1 de mars 1984) : elle ne doit pas s'empiler avec elles.
- Échap et clic extérieur : sans effet (même règle que les modales à choix), pour qu'on ne la saute pas par erreur à la première partie.
- **Relecture** : entrée dans l'HISTORIQUE (source maison, genre « info », titre « Janvier 1984 : votre situation »), pour retrouver l'objectif en cours de partie. Coût faible, utile au joueur qui revient après une pause.
- Ne compte pas dans le budget de 20 min (une seule fois, ~30 s).

## 3. « Ne plus afficher » : non

Pas de case. Raisons :
1. Elle ne s'affiche qu'une fois par partie (pas comme la confirmation du COURRIER, répétée) : la gêne est d'un clic.
2. Le joueur fait essayer le jeu à d'autres personnes sur la même machine : une case cochée par le premier priverait les suivants de l'explication, alors que c'est précisément pour eux qu'elle existe.
3. Quand les profils et années de départ arriveront (points 2 et 5), le texte changera à chaque partie : il redevient utile à chaque fois.

À revoir seulement si le joueur se plaint après plusieurs parties ; dans ce cas, préférer une préférence locale (comme `Ne plus afficher` du COURRIER), jamais dans la sauvegarde.

## 4. Estimation

| | Plaisir | Pédagogie | Coût |
|---|---|---|---|
| Pop-up de début (texte + modale + pause + entrée d'historique) | moyen (le joueur sait pourquoi il joue dès la 1re minute ; donne l'enjeu Tata et le titre) | moyen (pose le comparateur Livret A et la notion d'objectif d'épargne) | faible (modale « info » existante, 2 gabarits, un test : affichée à Nouvelle partie, absente à Continuer) |
