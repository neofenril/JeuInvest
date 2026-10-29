# Retours du joueur réel

## 2026-10-26 — Démo Godot (sept. 1986 → déc. 1988)

Verbatim :

- le temps défile trop rapidement
- les pop-ups lors des évènements c'est bien, bien garder l'esprit "didactique" au niveau du banquier. Comme dans la vraie vie il nous propose des choses, mais ici ce sont des choses adaptées au profil de l'utilisateur, et avec des explications concrètes
- ajouter une plus grande liste de produits disponibles dans la banque
- ajouter d'autres types d'enveloppes, comme les assurances vies en mettant en avant les bénéfices de successions liés à cette enveloppe (plus pertinent pour des parents bien entendu)
- introduire les différents placements au fur et à mesure. Commencer par un livret A, expliquer ses avantages puis introduire les différents autres produits, leurs avantages et inconvénients par rapport aux choses déjà introduites et déjà utilisées pour l'utilisateur courant
- faire en sorte qu'une fois la pop-up d'un bâtiment ouverte, un clic en dehors de celle-ci la ferme comme le bouton fermer ou la croix de la pop-up
- faire défiler les voitures plus rapidement lorsque la vitesse de défilement est accélérée

Points positifs exprimés : les pop-ups d'événements ; l'esprit didactique du banquier.

## 2026-10-27 — Nouvelle partie de la démo (après corrections de rythme)

Verbatim :

- espacer le compte courant du patrimoine en haut pour améliorer la visibilité
- améliorer la visibilité de la performance des placements choisis par rapport à la solution "tout laisser sur le compte courant et les livrets A" (qui est l'option des personnes qui téléchargeront cette application car ils sont là pour apprendre !)
- encore augmenter la vitesse des véhicules lors des phases d'accélérations
- ajouter une animation de voiture qui se crash lorsque l'évènement de panne de voiture survient
- ajouter une animation de naissance de bébé lors de l'évènement. prévoir une possibilité d'avoir des jumeaux
- aborder les frais et les pertes liés à ceux-ci avec des exemples parlants (investir 10k€ à 2.5% de frais sur 20 ans vs 0.5% de frais par exemple)

Demande complémentaire (reprise de session) :
- « penser aussi à un moment donné à ajouter une fonctionnalité de sauvegarde de la partie en cours ! »

## 2026-10-27 — Démo V2 (janvier 1984 → décembre 1988)

Verbatim :

- Rajoute un endroit avec l'historique des pop-up qui sont apparues à l'utilisateur, de façon résumée.
- Lors de la succession avec l'assurance vie, le montant initial de 60k€ est donné en plus de celui après impôt de 45k€. On touche donc 2 fois l'argent de la succession
- rajoute fonctionnalité de versement automatique mensuel sur les supports qui le peuvent

Analyse du coordinateur sur l'héritage : ce n'était pas un double versement dans le code (deux pots distincts dans le scénario : 60 000 F d'assurance-vie + 100 000 F de succession taxés à 55 % = 45 000 F nets), mais le joueur l'a compris comme un double paiement : le scénario est trop confus. Décision : **un seul pot** — l'assurance-vie verse 60 000 F, et le banquier montre ce que ces mêmes 60 000 F auraient donné par succession (27 000 F nets à 55 %). Plus de second versement en septembre.

## 2026-10-28

Verbatim :

- « Je trouve qu'on s'ennuie un peu » → création d'un agent game designer qui discute avec le client et fait une liste de propositions, **à soumettre au joueur avant toute autre chose** (aucune implémentation avant sa validation).

Réponses aux questions du client (docs/12) :
- « le cadre de la démo est ok » → démo janvier 1984 → décembre 1988 avec Gérard, papa en 1985 : validé.
- « pas de questionnaire prévu pour le moment, garde ça de côté, peut-être à implémenter plus tard » → « adapté au profil » = selon la situation de vie uniquement (âge, couple, enfants, épargne). Questionnaire de risque : idée mise de côté.
