# Base de connaissances du client

> Synthèse opérationnelle du client (porteur de la vision). À lire au début de chaque mission et à mettre à jour à la fin.
> Référence produit : `docs/03_cahier_des_charges.md` (prime sur 00, 01, 02, 04). Cette base **complète** 03 avec les décisions prises depuis ; en cas de contradiction, **la décision la plus récente de cette base l'emporte** jusqu'à sa reprise dans 03.

---

## 1. Vision et objectifs (5 lignes)

1. Un petit jeu de gestion de vie et d'épargne : on incarne un Français ordinaire, entre 1950 et aujourd'hui, sur une frise façon Les Sims.
2. Priorités non négociables, dans cet ordre : **1) s'amuser, 2) apprendre la bourse** ; on apprend en jouant, jamais par un cours.
3. Seuls les produits **réellement disponibles** à la date jouée sont proposés ; les vrais événements historiques et des événements de vie aléatoires forcent des arbitrages.
4. La leçon centrale : se comparer à Tonton Matelas, Tata Livret et Cousin Indice (inflation, diversification, sang-froid, épargne de précaution, enveloppe PEA).
5. Règle d'or : une partie complète en 15 à 30 minutes qui donne envie de rejouer ; **en cas de doute, la solution la plus simple**.

---

## 2. Arbitrages rendus et leur raison

### 2.1 Arbitrages du cahier des charges (rappel, détail en 03 §1)

| # | Décision | Raison |
|---|---|---|
| A1 | Barre de répartition au lieu d'un camembert | Une ligne, lisible en petit (encore plus vrai sur mobile). |
| A2 | Petits événements de vie en notification, sans pause | Garder le rythme : environ une interruption forte par an. |
| A3 | 3 périodes en cartes ; année libre en V2 | Un champ vide est un mauvais premier contact ; seules les 3 périodes sont scénarisées. |
| A4 | La baguette comme unité de pouvoir d'achat en jeu ; € d'aujourd'hui au bilan | Concret et drôle ; le calcul IPC reste en coulisses. |
| A5 | La frise n'annonce jamais un krach | Sinon la leçon est détruite. |
| A6 | Fiscalité « taux unique » (16 % hors PEA 1978-1997, etc.) | Rend l'avantage du PEA visible ; simplification assumée et signalée. |
| A7-A9 | P1 1978-1992, P2 1996-2010, P3 2011-2025 ; Trente Glorieuses hors V1 | 15 ans pile chacune, sans doublon ; 1950-1977 = données peu fiables. |
| A10-A14 | 15 ans fixes ; ordre « au cours du mois » ; cours déterministes ; emprunt d'État sans cours ; 4 actions par période | Simple, juste, rejouable à armes égales. |
| A15-A19 | Pas de droits de garde, crédit conso… (assurance-vie : annulé par A36) ; Tata Livret plafonnée ; bilan brut ; rappel à 12 mois ; objectifs calibrés sur Cousin Indice | Chaque règle en plus doit apporter du plaisir ou une leçon. |

### 2.2 Arbitrages rendus le 2026-10-26 (questions du développeur V1, 05 §6)

| # | Sujet | Décision | Raison |
|---|---|---|---|
| A20 | **Chômage** (05 §6.2 n° 10) : les dépenses suivent le salaire à 65 %, **sauf le loyer**, qui reste celui du salaire normal | **Validé.** À reprendre tel quel dans Godot. | C'est réaliste (on réduit ses courses, pas son loyer) et la perte d'emploi reste un vrai coup dur qui enseigne l'épargne de précaution, sans condamner mécaniquement le joueur prudent à la faillite. |
| A21 | **Naissance et déménagement** (05 §6.2 n° 11) : aucune naissance tirée si elle rend le budget mensuel négatif ; un déménagement « plus cher » devient « moins cher » s'il laisse moins de 3 points d'épargne | **Validé. On garde +9 % du salaire par enfant**, on ne réduit pas ce coût. | Un événement qui rend le budget négatif pour le reste de la partie n'est pas un arbitrage, c'est une condamnation : ni plaisir ni leçon. Le garde-fou vit dans le tirage (déterministe, invisible) et ramène les faillites passives de 15-25 % à 1 sur 900. |
| A22 | Pas d'événement de vie au 1er mois ; prime du tutoriel au mois 8 toujours présente ; panne de voiture forcée le mois **suivant** un événement « − » | **Validé.** | Le calendrier ne dépend que de la graine ; « Rejouer » reste équitable. |
| A23 | Témoins sans agios ni faillite | **Validé.** | Ce sont des étalons de comparaison, pas des joueurs. |
| A24 | Lien « Garder les choix conseillés » (lancement en 3 clics) | **Validé côté client** ; l'UX peut l'habiller autrement dans Godot. | Lancer vite est plus important que tout voir. |
| A25 | Autres décisions de 05 §6 (n° 1 à 9, 12 à 33) | **Validées par défaut.** Les points d'indice et ancrages « dev » restent **à valider par le boursier**. | Elles suivent la règle « la solution la plus simple ». |

### 2.3 Arbitrages rendus le 2026-10-26 (changement de moteur)

| # | Décision | Raison |
|---|---|---|
| A26 | **Passage à Godot 4 (GDScript)**, projet dans `godot/`. La V1 web (`jeu/`) est **archivée** : elle sert de référence de règles et de données, plus de développement. | Le joueur réel trouve le rendu web insuffisant et veut du mobile ; Godot permet un rendu plus soigné et l'export PC + Android. |
| A27 | **Les règles de jeu du 03 ne changent pas** avec le moteur : on porte, on ne réinvente pas. Les critères de règles (CA-05 à CA-22, CA-25 à CA-29) restent les critères de recette. | La logique est testée (24/24) ; le problème est la forme, pas le fond. |
| A28 | **Contraintes techniques révisées** (remplacent 03 §2, points 1 à 3 et 6) : PC = un exécutable Windows autonome qui se lance par double-clic, **sans installation, hors ligne** (via `Jouer.bat` ou l'exe directement) ; mobile = **Android d'abord** (APK), iOS plus tard. Données toujours séparées du code ; une seule sauvegarde locale. | On garde l'esprit « zéro friction » de la vision, adapté au nouveau moteur. |
| A29 | **Mobile entre dans le périmètre** (03 §9 le mettait hors V1). Conséquences : tout ce qui passait par le survol (bulles « C'est quoi ? », règle des étoiles) doit marcher **au toucher** ; zones tactiles larges ; le clavier reste un bonus PC. | Demande explicite du joueur réel. |
| A30 | La recette de la V1 web est **abandonnée** (interrompue, plus d'actualité). | Inutile de valider une version archivée. |

---

## 3. Retours de l'utilisateur réel et ce que j'en déduis

| Retour du joueur | Ce que j'en déduis | Priorité |
|---|---|---|
| « Le jeu s'ouvre bien par Jouer.bat » | Le lancement par double-clic est acquis et apprécié : **à conserver à l'identique** avec Godot (un `Jouer.bat` ou un exe à la racine). Ne pas régresser sur ce point. | Indispensable |
| « La version site ne me plaisait pas, graphisme insuffisant » | Le fond (règles, données, événements) n'est pas remis en cause ; **la forme est le chantier n° 1**. Le rendu visuel n'est plus un « habillage final » (03 §8 : « jouable moche d'abord ») : il doit être jugé **dès la première livraison**. | Indispensable, en premier |
| « Veut une version mobile » | Il faut concevoir **une interface qui tient sur téléphone dès le départ**, pas l'adapter après coup. L'écran principal (frise + patrimoine + actions) est le plus risqué sur petit écran. | Indispensable |
| (2026-10-26) « Une sorte de **ville en fond**, avec la **maison** de mon personnage, un **bâtiment banque** : quand le banquier m'appelle, on voit une animation d'appel depuis ce bâtiment ; un **bâtiment média** avec une animation pour chaque news. » | Le « graphisme poussé » = **une scène de ville vivante qui met en scène les événements**, pas seulement une interface plus jolie. Chaque type de message a **son lieu d'origine** dans la ville. Voir A31 et A32. | Indispensable, cœur du rendu |
| (2026-10-26, démo Godot sept. 1986 → déc. 1988, verbatim en 10) Aime les pop-ups d'événements et **l'esprit didactique du banquier** ; trouve le **temps trop rapide** ; veut **plus de produits**, l'**assurance-vie** avec ses avantages de **succession** (pour des parents), une **introduction progressive** (Livret A d'abord, puis chaque produit comparé à ceux déjà connus et utilisés), des propositions **adaptées au profil** avec des **explications concrètes** ; clic hors pop-up = fermer ; voitures plus rapides en accéléré. | Le rendu « ville » est validé de fait (pas de critique visuelle). **Le banquier devient le cœur de la pédagogie** : progression produit par produit, déclenchée par la situation du joueur. Il faut une fenêtre plus longue pour la dérouler. Traduction complète : `docs/12_arbitrages_v2_demo.md` (R1 à R10). | Indispensable, démo V2 |
| (2026-10-27, 2e partie après corrections de rythme) Espacer compte courant et patrimoine ; **mieux voir la performance face à « tout au compte courant + Livret A »** (« c'est l'option des gens qui téléchargeront l'appli pour apprendre ») ; véhicules **encore** plus rapides ; animation de crash à la panne ; animation de naissance, **jumeaux possibles** ; **les frais** avec des exemples parlants (10 k€ à 2,5 % contre 0,5 % sur 20 ans). Réponses : cadre 1984-1988 **validé** ; **pas de questionnaire de risque** pour l'instant. | Le public visé est le débutant qui laisse tout sur son livret : **Tata Livret devient le comparateur permanent**, pas seulement un témoin de fin. Il aime le spectacle des événements de vie (animations). Les frais sont une leçon à part entière. Voir 12 §7 (R11 à R14, A40 à A45). | Indispensable, démo V2 |

| (2026-10-28, après la démo V2 et l'historique) « **Je trouve qu'on s'ennuie un peu** » ; exige que la liste du game designer lui soit **soumise avant tout développement**. | Le fond pédagogique est acquis, **l'objectif n° 1 (s'amuser) n'est pas atteint** : spectateur, peu de décisions, choix sans effet visible (4 % d'écart avec Tata Livret), argent sans usage. Voir 3.3. | Indispensable, prochaine itération |

### 3.3 Avis rendu sur docs/14 (2026-10-28) : **provisoire, en attente du joueur**

Mon top 5 : **P4** mois utile + « Jusqu'au prochain courrier » (coût faible, en premier) ; **P2** dilemmes (8 à 10 cartes, humeur en 3 états, pas de jauge 0-100) ; **P1** projets (+ traces visibles P10) ; **P3** voisins Tata / Matelas / Jean-Mi + rang et titre de fin (P5 allégé) + bulles P9 ; **P6** krach en direct + « un an après ». Ensuite P11, P7 (Suez d'abord), P5 complet. Plus tard : P12. Contre pour la démo : P8 (doublon d'objectifs), P13 (coût fort).
Décisions que j'accepte de rouvrir si le joueur valide : budget de 15 interruptions (micro-décisions ≤ 4 s, durée ≤ 20 min mesurée) ; Matelas et Jean-Mi dans la démo (pas Cousin Indice) ; un titre et un rang (pas d'étoiles) ; +1 ou 2 privatisations (pas de nouvelle famille).
Garde-fous imposés (14 §6.3) : Jean-Mi finit derrière Tata Livret, ses tuyaux ne sont jamais des boutons, pas de crédit pour le joueur ; le saut de temps s'arrête au mois de l'interruption, jamais avant, et à chaque présentation du banquier ; coût d'opportunité affiché après le choix, sans jugement ; les escargots perdent toujours ; pas de mécanique d'accroche ; prix d'époque avec certitude.
Leçon : **plus de systèmes ≠ plus de plaisir** ; je préfère moins de cartes et une humeur simple, puis mesurer.

### 3.1 Décisions issues de la vision « ville » (2026-10-26)

| # | Décision | Raison |
|---|---|---|
| A31 | **L'écran principal devient une scène de ville** (2D illustrée, animée) en fond, avec 3 bâtiments au moins. Le tableau de bord (patrimoine, budget, frise et vitesses) est **superposé** à la ville, sobre, sans la masquer. | C'est l'image que le joueur a en tête ; la ville rend lisible « d'où vient » chaque événement. |
| A32 | **Chaque bâtiment a un rôle et une animation** : **Maison** du personnage = événements de vie (courrier, naissance, panne, chômage) et budget ; **Banque** = le **banquier, un personnage qui appelle** (animation d'appel depuis le bâtiment) ; **Média** = toutes les news (événements de marché en journal, notifications de contexte : nom du CAC 40, euro, flat tax…), avec une animation à chaque news. Toucher un bâtiment ouvre l'écran correspondant (Banque → tiroir marché). | Une règle simple, un lieu par type de message : le joueur comprend sans lire. |
| A33 | **Rôle du banquier** : il appelle pour les **déblocages de produits** (« le PEA vient d'être créé », privatisations Saint-Gobain et France Télécom), les **changements de taux du Livret A** et de fiscalité, le **bilan annuel** et le **rappel à 12 mois** ; il explique les produits (« C'est quoi ? »). **Il ne conseille jamais quoi acheter ou vendre et n'annonce jamais un krach** (règle CLAUDE.md « pas de conseil personnalisé » et A5). Ton : bienveillant, un peu vendeur, humour d'époque. | Il incarne la pédagogie sans en faire un cours ; un « conseil » qui ferait gagner détruirait la leçon. |
| A35 | **Mobile en paysage uniquement** (orientation verrouillée), comme le PC : **une seule mise en page**, adaptée en taille (zones tactiles larges, textes lisibles sur téléphone). Pas de version portrait. | Choix du joueur ; la ville et la frise horizontale s'y prêtent, et une seule mise en page divise le travail par deux. |
| A34 | Les modales du 03 restent les mêmes sur le fond (choix, textes, règle une modale par mois) : **l'animation du bâtiment précède la modale** (2 s au maximum, passable d'un toucher). | Le spectacle ne doit pas casser le rythme ni la règle des 10 secondes de lecture. |

### 3.2 Décisions issues du test de la démo Godot (2026-10-26, détail en 12)

| # | Décision | Raison |
|---|---|---|
| A36 | **L'assurance-vie (fonds en francs) entre dans le périmètre**, présentée après une naissance, avec clause bénéficiaire et comparaison chiffrée succession / assurance-vie. Annule A15 pour ce produit. | Demande explicite du joueur ; la succession parle aux parents. |
| A37 | **Le banquier est le seul canal d'introduction des produits** : Livret A au 1er mois, puis PEL, emprunt d'État, assurance-vie (naissance), SICAV, actions ; chaque étape a un déclencheur lié à la situation et une **date limite** (tout est vu avant le krach). Chaque présentation : 60 mots max, exemple chiffré avec l'argent du joueur, bloc « Par rapport à ce que vous connaissez » sur 4 critères (rendement, risque, disponibilité, fiscalité), boutons Ouvrir / Pas maintenant / En savoir plus. | Progression demandée par le joueur ; les dates limites évitent qu'un joueur passif ne voie rien. |
| A37b | **Ligne rouge du banquier** : adapter = choisir le moment et chiffrer ; jamais « vous devriez », jamais de prévision de cours ou de taux ; le risque se montre par le passé. | Concilie « adapté au profil » (joueur) et « pas de conseil personnalisé » (CLAUDE.md). |
| A38 | **Démo V2 : janv. 1984 → déc. 1988 (60 mois)**, profil unique scripté (Gérard, 26 ans, technicien, en couple), naissance scriptée au printemps 1985, héritage scripté de la tante Odette en 1988 (assurance-vie vs succession vécues), 6 familles / 9 lignes de produits, 15 à 20 min, ×1 = 8 s/mois, écran de fin simple (patrimoine, produits découverts, comparaison Tata Livret). | La fenêtre de 27 mois était trop courte pour une progression ; 1984-1986 = hausse qui donne goût aux actions avant le krach. |
| A40 | Banque **générique** qui ouvre aussi le Livret A, avec la bulle (?) historique (D3). | Un seul bâtiment banque ; l'honnêteté passe par la bulle. |
| A41 | Gérard et Sylvie **non mariés** (D4) : l'assurance-vie protège Sylvie (0 F par succession, tout par l'assurance-vie) ; pour l'enfant, on dit honnêtement qu'il n'y a pas d'écart sous 275 000 F. | Exemple le plus concret ; mariage plus tard. |
| A42 | Rachats d'assurance-vie : **règle réelle 45 / 25 / 15 / 0 %** sur les gains dans la démo, affichée dans la confirmation ; taux unique dans le jeu complet (D5). | Une formule qui enseigne la durée de détention. |
| A43 | 3 baisses du Livret A (1984-1986) en notifications sans pause ; appel Saint-Gobain le 24/11/1986. | Leçon gratuite, date exacte. |
| A44 | **Pédagogie des frais** : moment fort F01 à la 1re souscription avec frais (encart dans la confirmation, 3 barres sur 20 ans avec le montant du joueur, 7 % = « hypothèse, pas une promesse ») ; F03 dans le tiroir (frais > 2 %) ; F02 relevé de décembre (jumeau sans frais) ; F06 à la fin. Plus : comparateur Tata Livret permanent (R12), crash et naissance animés, jumeaux 1 sur 4 dans la démo (R13, R14). | Retours du 27/10 ; aucune interruption en plus, 15-20 min tiennent (A45). |
| A39 | Clic ou toucher à l'extérieur : ferme les **fenêtres de bâtiment**, **jamais les modales à choix**. Voitures proportionnelles à la vitesse du temps. | Retour du joueur, sans risque de décision par accident. |

Déductions pour l'ordre de travail :
1. **D'abord le rendu**, sur une tranche courte, validé par le joueur ; **ensuite seulement** le portage complet des règles.
2. ~~Ce que le joueur entend par « beaucoup plus poussé »~~ : **tranché** par sa réponse (ville + 3 bâtiments animés, A31 à A34).
3. Les idées « plus tard » liées à l'ambiance (avatars illustrés, sons, ambiance par décennie, `coin-rain`, « Revoir ma frise ») **remontent en priorité** si elles servent le rendu ; les ajouts de contenu (année libre…) restent en V2 ; l'assurance-vie est avancée (A36). La ville qui **change d'époque** (voitures, enseignes, couleurs par décennie) est le meilleur candidat, mais **après** la version minimale.

---

## 4. Priorités pour la version Godot

### 4.1 Étape 1 : démo « rendu » (sept. 1986 → déc. 1988) : **testée le 2026-10-26**

Ville, banquier qui appelle, média, krach, panne de voiture : jouée par le joueur réel. Aucune critique sur le visuel, les pop-ups et le banquier plaisent ; retours en 10, traduits en 12.

### 4.1 bis Étape 1 bis : démo V2 « progression pédagogique » (en cours)

Cadre complet : `docs/12_arbitrages_v2_demo.md` (A36 à A39). Catalogue et textes du banquier : `docs/11_catalogue_banque.md`. Critère de sortie : le joueur confirme le rythme (R1) et la progression du banquier (R2 à R8).

### 4.2 Étape 2 : portage complet (après la démo V2) ; la progression du banquier (A37) s'applique à toutes les périodes

Ordre conseillé :
1. Moteur et données portés depuis `jeu/js/moteur.js`, `marche.js`, `score.js` et `jeu/data/`, avec des tests automatiques équivalents (CA-02, CA-05 à CA-22).
2. Les 4 écrans : création de partie, écran principal, tiroir marché, bilan de fin (le bilan doit être aussi soigné que la modale de krach).
3. Modales et notifications, rappel à 12 mois, moment euro, nouveautés.
4. Tutoriel, glossaire au toucher, sauvegarde unique.
5. Ambiance par décennie, sons légers (le « ding » du dividende), avatars : selon les retours de l'étape 1.

### 4.3 Ce que je refuse toujours

Chandeliers, indicateurs techniques, tableaux de 50 colonnes, compte utilisateur, connexion obligatoire, effets visuels qui ralentissent la lecture d'un événement (10 secondes de lecture au maximum).

---

## 5. Points ouverts

| # | Question | À qui | Statut |
|---|---|---|---|
| O1 | Que veut dire « graphisme beaucoup plus poussé » pour le joueur ? | Joueur réel | **Fermé le 2026-10-26** : ville en fond, maison, banque (appels du banquier), média (animation à chaque news). Voir A31 à A34. |
| O2 | Mobile : portrait ou paysage ? | Joueur réel | **Fermé le 2026-10-26 : paysage** (A35). |
| O9 | Style graphique de la ville (vue de face, isométrique façon Les Sims, pixel art, illustration plate) | UX, puis joueur | À proposer par l'UX (2 ou 3 croquis), le joueur choisit |
| O3 | iOS : quand ? (CLAUDE.md : « plus tard »). Exige un Mac pour l'export. | Développeur | V2 |
| O4 | Distribution Android : APK installé à la main suffit-il pour la V1 ? Ma position : **oui**, pas de store en V1. | Joueur réel | À confirmer |
| O5 | Points d'indice et ancrages d'actions marqués « dev » (05 §6.1 n° 2 et 4) | Boursier | À valider |
| O6 | Durée réelle d'une partie (CA-24, jamais mesurée) et rythme (environ 16 modales par partie) | Joueur réel | À mesurer sur la version Godot complète |
| O7 | Naissance : avec le garde-fou A21, le jeune salarié n'a presque jamais d'enfant. Or l'assurance-vie (A36) se présente à la naissance. | Client | Démo V2 : naissance scriptée. Jeu complet : à revoir (naissance plus fréquente ou autre déclencheur) |
| O10 | « Adapté au profil » : situation de vie ou questionnaire de risque ? | Joueur réel | **Fermé le 2026-10-27** : situation de vie uniquement ; questionnaire mis de côté (idée « plus tard »). |
| O11 | Cadre de la démo V2 (janv. 1984, Gérard 26 ans, papa en 1985, 15-20 min) | Joueur réel | **Fermé le 2026-10-27 : validé.** |
| O12 | Règles d'époque de l'assurance-vie et chiffres de l'héritage | Banquier (11) | **Fermé** : livrés en 11 §1.7 (certitudes A à C) ; montants d'Odette en C, acceptables pour une démo. |
| O13 | Jumeaux dans le jeu complet : fréquence (démo 1 sur 4, réalité ≈ 1,5 %) | Client | À régler au portage complet |
| O14 | Réponses du joueur à docs/14 §5 (moral, voisins, fréquence des cartes, propositions retenues) | Joueur réel | **Ouvert** : rien ne se développe avant sa réponse. Mes réponses provisoires en 14 §6.5. |
| O15 | Durée réelle avec les cartes (cible ≤ 20 min, A45) | Joueur réel | À mesurer sur la première partie avec P2 |
| O8 | Sauvegarde : une partie commencée sur PC ne se continue pas sur mobile. Acceptable en V1 (une sauvegarde locale par appareil). | Client | Tranché : pas de synchronisation en V1 |

---

## 6. Journal des missions

| Date | Mission | Résultat |
|---|---|---|
| (avant 2026-10) | Vision initiale | `docs/00_vision_client.md` : boucle de jeu, périmètre V1 / plus tard, questions aux experts. |
| (avant 2026-10) | Cahier des charges V1 | `docs/03_cahier_des_charges.md` : arbitrages A1 à A19, règles, produits, 31 critères d'acceptation. |
| (avant 2026-10) | Recette de la V1 web | **Interrompue**, plus d'actualité (A30). |
| 2026-10-26 | Création de cette base ; passage à Godot | Arbitrages A20 à A30 (chômage et naissance validés, contraintes techniques révisées, mobile dans le périmètre) ; définition de la version minimale « rendu » ; points ouverts O1 à O8. |

| 2026-10-26 | Retour du joueur sur le graphisme | O1 fermé : vision « ville » (A31 à A34) ; le banquier devient un personnage qui appelle (déblocages, taux, bilans, jamais de conseil) ; version minimale mise à jour ; O9 ajouté. Puis O2 fermé : mobile en paysage (A35). |

| 2026-10-26 | Retours du joueur sur la démo Godot | `docs/12_arbitrages_v2_demo.md` : R1 à R10 testables, progression du banquier, démo V2 1984-1988 ; A36 à A39 ; O10 à O12. |
| 2026-10-27 | Réponses du joueur, catalogue du banquier (11), retours de la 2e partie | 12 §7 : D3 à D5 tranchés (A40 à A43), R11 à R14, pédagogie des frais (A44), volume inchangé (A45) ; O10 à O12 fermés, O13 ouvert. |
| 2026-10-28 | Avis sur les propositions du game designer (« on s'ennuie ») | 14 §6 : avis sur P1-P13, conditions de réouverture, 8 garde-fous, top 5 (P4, P2, P1, P3+titre, P6) ; O14, O15 ouverts. Équipe : game designer, chef de projet, dev-logique, dev-interface. |

### Erreurs à ne pas refaire
- Avoir classé le rendu visuel en « habillage de fin » (03 §8) : pour ce joueur, **le rendu fait partie du plaisir**, donc de la priorité n° 1. Il se juge dès la première livraison.
- Avoir mis le mobile en « hors V1 » sans le demander au joueur : vérifier les plateformes attendues dès le départ.
