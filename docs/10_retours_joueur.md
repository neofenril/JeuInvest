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

## 2026-10-29 — Décision sur les propositions du game designer (docs/14) et du chef de projet

Verbatim :

- « On fait P1, P2, P3, P4, P5, P6, P9, P10 ; on garde éventuellement pour plus tard P7, P11, P12, P13 ; on retient pas P8. »
- « Concernant les propositions techniques du CDP on conserve les deux idées. » → retirer les raccourcis de test des versions exportées ; découper `principal.gd`.
- « Je laisse le CDP recruter d'autres développeurs s'il pense que ça peut permettre d'augmenter l'efficacité. »
- Ajout d'un **testeur** : « Les développeurs ne pushent pas sur leur branche tant que le testeur n'est pas passé dessus et n'a pas vérifié que les développements étaient OK. »

Questions 1 à 3 du game designer (moral du foyer, voisins rivaux, fréquence des cartes) : pas de réponse explicite ; en retenant P2, P3 et P5, le joueur valide le principe. Par défaut, on applique les réserves du client (docs/14 §6) : moral en 3 humeurs de Sylvie, 8 à 10 cartes par démo, Jean-Mi finit derrière Tata Livret, P5 et P10 dans leur version allégée — à confirmer par le joueur sur la démo.

## 2026-10-29 — Réponses aux 3 questions de docs/15 §12, recrutement, graphisme

Verbatim : « Tu peux garder les trois propositions, là, ces trois dernières questions. Et pas de problème pour garder le nouveau développeur que le chef de projet a décidé de recruter. » — et : « J'ai déposé les photos » (références graphiques dans `docs/sources/graphisme/references/`), avec la volonté de **modifier les graphismes avant d'aller plus loin** (« la vue de face est pas mal mais le style est trop "générique" »).

Interprétation retenue : (1) toutes les cartes de dilemme sont gardées, même si la partie dépasse un peu 20 min sans le bouton « Jusqu'au prochain courrier » ; (2) le classement de la rue est affiché en permanence ; (3) record personnel et collection des titres conservés d'une partie à l'autre. Recrutement de `dev-ville` validé.

## 2026-10-29 — Validation de la bible graphique pixel art (docs/16)

Verbatim : « Ouais, on dessine tout en pixels dans le code, on fournira plus tard les éléments. J'ai pas d'outil IA pour le moment, ni de budget en tête. Pour ce qui est de l'interface, on passe tout en pixels, oui. Comme proposé avec les chiffres et les textes longs dans une police nette. Il n'y a pas que la ville qui change. Pour ce qui est des personnages, ouais, on peut les mettre petits, comme ça on verra plus la rue. On peut garder un peu la taille qu'il y avait avant, c'était pas mal. Tu peux télécharger les polices et tu peux lancer le proof of concept. Et le lot technique 1 qui part en même temps. »

Décisions : tout en pixel art dessiné dans le code (images fournies plus tard par le joueur, pas d'outil d'IA ni de budget pour l'instant) ; **l'interface aussi passe en pixel**, chiffres et textes longs dans une police nette ; **personnages petits dans la rue, à peu près à la taille de la version vectorielle actuelle** ; polices OFL téléchargées ; preuve de concept PX0 et lot 01 lancés en parallèle.

Réponses aux questions du client (docs/12) :
- « le cadre de la démo est ok » → démo janvier 1984 → décembre 1988 avec Gérard, papa en 1985 : validé.
- « pas de questionnaire prévu pour le moment, garde ça de côté, peut-être à implémenter plus tard » → « adapté au profil » = selon la situation de vie uniquement (âge, couple, enfants, épargne). Questionnaire de risque : idée mise de côté.

## 2026-10-29 — Retour sur la preuve de concept PX0 (style de la rue)

Verbatim : « Plutôt ca comme style graphique, fait une nouvelle proposition en te basant là-dessus » + nouvelle image de référence (docs/sources/graphisme/references/rue_pixel_v2.jpg, gitignorée) : rue de briques vue de face, ciel bleu à gros nuages, grands arbres feuillus vert vif, lampadaire noir, voitures rouge et grise, trottoirs, passage piéton, skyline lointaine floue, arbre en premier plan à droite. Couleurs vives et saturées, bien plus claires que le PX0 (automne/crépuscule).


Verbatim (complément, même jour) : « Personnages un peu plus grand cette fois-ci » → remplace la décision précédente « petits, taille de la version vectorielle » pour la nouvelle proposition PX0 bis.


Verbatim (verdict sur PX0 bis, 2026-10-29) : « Style bien mais approche toi encore plus de la dernière image que je t'ai fournie si possible. L'ambiance est ok, garde la taille des personnages elle est bien. Largeur rue avec défilement bien. Interface ok. »
Décisions : style PX0 bis validé sous réserve de se rapprocher de rue_pixel_v2.jpg ; ambiance briques Nord/banlieue années 1980 OK ; personnages 24x42 conservés ; rue plus large que l'écran avec défilement de la caméra (pour PX1) ; interface PX0 (barre du haut/frise sombres) conservée.


Verbatim (retour sur PX0 ter, 2026-10-30) : « Tu peux faire encore plus proche, l'image d'origine est libre de droit, inspire-toi à fond, en particulier le mini effet 3D qui est présent sur les bâtiments, pour donner plus de relief à l'ensemble. Des graphismes un peu moins pixelisés si possible. »


## 2026-11-06 — Demande de fonctionnalité : sauvegarde avant la version finale

Verbatim : « prévoir l'ajout d'une fonctionalité de sauvegarde avant la version finale. Permettre au joueur de sauvegarder la partie quand il le souhaite, et lui proposer automatiquement avant chaque décision importante »
Contexte : une sauvegarde automatique unique existe déjà (partie_en_cours.sav, format 3). La demande ajoute la sauvegarde manuelle à la demande et des points de sauvegarde proposés avant les décisions importantes.


Verbatim (réponses, 2026-11-06) : « 3 emplacements possibles. l'utilisateur choisis quel emplacement écraser lors d'une nouvelle sauvegarde. je valide les décisions importantes. Je confirme une recharge de sauvegarde annule la prise en compte de la partie courante dans le record. note les éléments de cette fonctionnalité pour plus tard, à ne pas lancer tout de suite »
Décisions : 3 emplacements ; le joueur choisit l'emplacement à écraser ; la liste des « décisions importantes » proposée par le CDP est validée ; recharger une sauvegarde annule la prise en compte de la partie courante dans le record ; fonctionnalité à NOTER seulement, NE PAS LANCER maintenant.


## 2026-11-13
- Ordre de vente automatique : « l'ordre est compte courant, puis livret bleu, puis le reste par ordre de rentabilité ». Demande : « tu peux accélérer le développement des features programmées ? »


## 2026-11-13 (suite)
- Règle de vente automatique des projets : « on garde ce qui est fait aujourd'hui, on verra plus tard » ; à redéfinir proprement plus tard (aujourd'hui : compte courant, Livret A, puis du moins au plus rentable, rentabilité non annualisée ; le PEL clos avant 4 ans peut partir avant des actions en gain).
- Le joueur a lui-même choisi les modèles des agents (chef de projet en Opus, les autres en Sonnet pour certains, Opus pour client, game-designer et ux-designer) : ne pas y toucher.


## 2026-11-13 (décisions pour le lot 07 et la diffusion)
- Record personnel : validé « face à Tata Livret » (meilleur écart final en % face à Tata Livret ; rang et titre aussi affichés).
- Sons : « pas de sons pour l'instant » (hors 1.0 tant que non redemandé).
- Signature de l'exe : « peut attendre ».
- APK : le joueur a essayé la toute première version ; il attend une nouvelle APK avec les nouvelles fonctionnalités majeures (censées ajouter du fun) pour voir si c'est réellement le cas. Donc la 0.5 jouable doit être exportée en exe ET en APK.


## 2026-11-14 (retours sur la 0.5)
- « le bouton d'avance jusqu'au prochain évènement (x6) doit réellement avancer jusqu'au prochain évènement et pas simplement faire x6. Préciser au joueur ce que son action va faire via une pop-up et proposer via une case à cocher de ne pas réafficher la pop-up au prochain clic sur ce bouton. »
- « La pop-up des choix de projets reste trop longtemps à l'écran après avoir sélectionné l'un des choix. » (« corrige de suite »)


## 2026-11-16 (verdict sur la 0.5.1)
- « les projets sont pas mal et je ne trouve pas les pauses trop nombreuses. La vitesse du saut est bonne. » Demande : lancer le testeur sur les titres et le record face à Tata Livret, vite, pour tester rapidement.


## 2026-11-17 (verdict sur la 0.6)
- « Sur smartphone l'écran de fin est un petit [peu petit] on a du mal à voir le récap des infos, cette version est pas mal, je la fais essayer par d'autres personnes et je te donnerai leur retour. »


## 2026-11-17 (méthode de recette)
- Décision du joueur : pour gagner du temps, (2) la série de captures complète n'est lancée qu'avant chaque export, avec des étapes ciblées entre-temps ; (4) recettes courtes quand le changement est petit. (Non retenus : réduire les formats de test à PC + un téléphone ; simplifier les écrans à mise en page fragile.)


## 2026-11-17 (retours utilisateur sur la 0.6.1 : fonctionnalités à prévoir)
Verbatim du joueur :
1) mettre des sortes d'étapes avec des récompenses sous forme de trophées (comme fait après le Lundi noir avec un positionnement en fonction du choix qui a été fait)
2) prévoir des profils d'investisseurs en début de partie : a) débutant : on explique tous les produits avec plus de détail, à quoi ça peut servir dans le cas de l'utilisateur, etc. ; b) intermédiaire : explications actuelles ; c) expert : on explique presque rien
3) prévoir un bâtiment pour « s'amuser » entre les événements, genre des casinos, des bureaux de tabac pour acheter des tickets à gratter entre autres
4) prévoir une évolution du décor en fonction de l'époque (quand toute la plage temporelle sera disponible), tous les 10 ans ça pourrait être bien
5) je ne sais plus si c'est déjà prévu, mais laisser le choix à l'utilisateur soit : a) un mini questionnaire pour demander à l'utilisateur son âge, l'année à laquelle il souhaite commencer, nombre d'enfants, etc. ; b) simplement sélection de l'année, et proposer 3 profils types de l'époque choisie
6) peu importe le choix de début, prévoir une pop-up de début pour expliquer qui on est et quel est notre objectif

## 2026-11-18 (retours utilisateur : questionnaire de début, jeux d'argent)
- « Dans le questionnaire de début, en plus du nom, de l'âge etc., il pourrait être intéressant de demander le salaire actuel de la personne, et de le transformer à équivalence de l'inflation pour simuler un niveau de vie similaire mais à l'époque. »
- « Prévoir une question lors de l'implémentation des jeux pour passer le temps comme le casino : en effet les lois françaises (ou ailleurs) pourraient considérer ça comme de l'incitation aux jeux d'argent et je ne sais pas si c'est légal. »


---

## 2026-11-18 (décisions du joueur sur le plan d'extension des années, verbatim)

> Concernant le plan global, on va commencer par le 9, comme tu proposais sur le socle avec les chapitres. Ensuite, je confirme l'ajout de notions de PEA et d'EDF, ETF, pardon. On va bien travailler sur des périodes de 5 ans supplémentaires, et pour commencer, on va se baser sur la dernière année qui est développée, donc 88, et on va partir de l'année qui suit, 89, jusqu'à 93, donc par tranche de 5 ans comme tu dis. Et on va se greffer au fur et à mesure autour de la période existante pour continuer. Sur ces tranches de 5 ans, on va bien gérer les profils comme tu proposes par tranche de 5 ans. Et par contre pour l'artwork, ce sera bien par tranche de 10 ans. La création du personnage, on va quand même conserver le choix par chapitre, mais on va aussi proposer la saisie d'une année en particulier, et cette année en particulier, elle viendra reprendre tous les éléments du chapitre dans lequel elle va s'insérer. La partie elle s'arrêtera soit quand le personnage y meurt, on peut envisager un événement de mort du personnage, soit à la dernière année qui est implémentée. Donc actuellement c'est 88, pour le prochain lot ce sera 93 avec la tranche de 5 ans supplémentaires, et à terme ce sera l'année en cours, 2026 voire 2027 quand on aura fini le projet. On va aussi garder le fait que l'année 76 pour le moment c'est enfin 77 c'est la première année qu'on implémentera. On verra tout à la fin des développements si on prévoit une période pas imaginaire mais avec des données très light entre 1950 et 1976. Voilà, ça c'est le retour pour la partie plan pour la suite, en fonction des retours du banquier. Ou attends. Non, il y a le retour des boursiers d'abord. Donc le boursier d'abord, les questions c'était... Les choix à trancher, on va garder les choix par défaut du boursier pour le moment. Et concernant le banquier, je veux, oui, l'ajout du PER comme notion. J'aimerais bien aussi qu'on distingue les deux canaux de frais avec la banque de réseau et le courtage en ligne qui est moins cher en ligne pour mettre en avant, surtout dans la période internet, que le réseau bancaire n'est pas forcément nécessaire, même s'il y a des conseillers. Le nom de la conseillère, je te laisse proposer quelque chose. Et je comprends pas le point 4 du retour du banquier. Corrigeons la ligne des salaires 2025, ajoutons une ligne 2023 avec 2 points d'épargne en moins. Je sais pas, je te laisse déterminer. On va garder les trophées des bonnes pratiques, on va garder le bureau de tabac aussi, on va pouvoir commencer ça. Et le niveau d'explication débutant, normal et professionnel, pareil, on verra plus tard. Pour l'ordre des travaux, on va commencer par le rééquilibrage, puis le socle des chapitres comme tu proposais. Sauvegarde manuelle, on peut mettre ça pour plus tard et on va étendre les autres périodes, donc la période 89-93 après. Donc socle d'abord, période supplémentaire et sauvegarde pour après. On va pour le moment se contenter du bureau de tabac et on verra pour le casino plus tard. Et je veux bien le profil célibataire aussi à lancer. Les étoiles avec le trophée sous forme d'étoiles, c'est bien aussi.

---

## 2026-11-18 (réponses du joueur aux décisions D-J1 à D-J7 et Q-R1, verbatim)

> Oui, une partie commençait en 84, elle continue bien jusqu'en 93. On peut envisager un bilan d'étape à la fin de chaque chapitre de 5 ans, mais idéalement un seul bilan unique à la fin serait suffisant. Donc à la fin, c'est à la fin de la période qui est développée. Donc oui, il faut bien marcher continu d'un chapitre à l'autre. Et en effet, il faut repenser les records à la nouvelle période complète. Mais on peut garder les records par chapitre pour le moment quelque part si on envisage de faire double record, en gros des records par chapitre puis des records sur la période totale. On peut garder l'idée d'avoir un titre par chapitre traversé pour le J2 et donc un record par chapitre de départ, pourquoi pas. Le décor, j'ai dit un artwork par décennie, en effet, les chapitres durent 5 ans, tu recommandes des tranches de 2 chapitres, donc oui, on va bien garder des tranches de 2 chapitres pour un seul décor, donc 84-93, ça évite en effet d'avoir des choses bizarres. Avant 84, la période 77-83, elle formerait un chapitre unique de 7 ans, ok. Gérard, il est gardé, vieilli au fil des chapitres, ok. Les tickets à gratter au bureau de tabac qui posent la même question juridique, c'est vrai. Du coup, on garde le coût du tabac avec au même titre le casino, avec confirmation, il faudra que je me renseigne. La mort du personnage, en effet, elle est liée à l'âge, elle est sobrement traitée. Cependant, on peut quand même mettre une nuance avec une petite note informative dans le cas de la mort du personnage en disant... En fonction des cas, hein, s'il a une assurance vie ou pas, expliquer à quel point ça aurait été bien. S'il a des enfants, on peut dire ben voilà, là, t'as pas d'assurance vie. Si t'en avais une, ton patrimoine, il aurait été transmis de telle façon à ta femme ou à tes enfants. Si t'en avais une, ça aurait été fait différemment, etc. Jean-Mi, trop peu ou pas assez présent. Pour le moment, c'est pas mal. On peut laisser le dosage actuel. Et pour répondre à ta question sur lancer en parallèle les boursiers et banquiers pour récupérer les infos, oui, lance-les en parallèle du développement sur la période 89-93.

---

## 2026-11-18 (mariage du personnage, verbatim)

> Le mariage du personnage, il va dépendre de l'âge, en fonction du profil qui a été rentré.


---

## 2026-11-18 (profils du lot 10, carte de passage, PEP, verbatim)

> Un seul profil pour le lot 10, la carte de passage A. Et petit 5 laisse le game designer trancher.


---

## 2026-11-18 (Jean-Mi, privatisation, immobilier et SCPI, verbatim)

> Je vois pas l'intérêt de faire acheter à Jean-Mi un studio avec un crédit à tout révisable, blablabla, si le joueur lui-même ne peut pas investir dans l'immobilier. Pourquoi tu me proposes ça, du coup?

> Parler de la privatisation, c'est bien, mais c'est quand même quelque chose d'assez poussé. Je pense pas que ce soit pour tous les profils de joueurs. Faut rester relativement simple. C'est pas tous les investisseurs qui vont s'intéresser à ce qu'est une privatisation. Il faut que dans la partie joueur débutant ou intermédiaire, faut pas aborder des sujets trop complexes. Donc peut-être pas conserver ça. Par contre, conserver la notion d'investissement immobilier pour une notion de diversification de placement, pour pas tout mettre ses œufs dans le même panier, donc dans la bourse ou tout ce qui est OAT, moyen terme, court terme, moyen terme, long terme, etc. Ça pourrait être intéressant d'amener aussi la partie immobilière. Et je sais pas aussi la partie SCPI, je sais pas à quelle date en France les SCPI ont vu le jour. Voilà, ça pourrait être intéressant de parler de ça.


---

## 2026-11-18 (export après le lot 10, verbatim)

> Je préfère attendre la fin du lot 10
