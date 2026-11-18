# 35 : Game designer, extension des années jouables (G1, G2, G3)

> 2026-11-18. Réponse aux demandes G1, G2 et G3 de `docs/lots/plan_extension_annees.md` §4.3, avec mon avis sur les idées 1, 2 et 3 de `docs/lots/backlog_retours_0_6.md` (§4).
> Bases : docs/15 (spécification V3), 23, 27, 28 (titres), 32 (pop-up de début), `godot/data/` (salaires, projets, titres, demo).
> **Tous les prix, montants et dates de jeu sont provisoires (certitude C)** sauf mention. À valider : prix et règles par le **banquier** (K2, K3), données de marché et dates par le **boursier** (B3). Le code se fait sur ces valeurs, qu'on remplace ensuite dans les données.
> Règles d'écriture inchangées : vouvoiement ; titres de carte ≤ 5 mots ; textes ≤ 30 mots ; aucun montant en dur dans les textes (gabarits) ; jamais « achetez / vendez / c'est le moment / auriez dû / devriez / conseil » ; aucun événement de marché annoncé avant sa date (A5) ; accroches sans divulgâcheur (A8).

---

## 0. En bref

1. **Durée de 5 ans confirmée** (60 mois). Un chapitre = un **gabarit fixe** (§1.2) : 10 créneaux de cartes, 2 projets, 1 rival, 1 vitrine, 1 date historique, 1 à 2 événements de vie scriptés, 9 titres. Le moteur ne change pas ; seules les données se réécrivent.
2. **13 archétypes de cartes** communs à toutes les époques (§1.3) : on réécrit le décor de la carte (mots, prix), jamais sa fonction. Les 9 titres sont **9 archétypes à conditions communes**, renommés par époque (§1.5).
3. **Profils de 1984-1988** (§2) : Gérard + **Martine**, 32 ans, cadre mariée (« gagner beaucoup ne suffit pas ») + **Bernard**, 25 ans, célibataire héritier (« que faire de 120 000 F reçus d'un coup ? »). **Règle R-SEUL** : sans conjoint, l'humeur passe à un **proche** (le meilleur ami) ; même moteur, cartes marquées couple / seul.
4. **Chapitre 2019-2023 « Les années smartphone »** (§3) : Julie (infirmière, pacsée), Thomas (développeur, célibataire, 40 000 € de mamie), Nathalie (cadre, mariée, 2 enfants) ; vitrine **mars 2020** ; date historique **entrée en Bourse de la FDJ (11/2019)** ; arnaque « livret miracle à 8 % » ; rival **Max** (cryptomonnaie à effet de levier, Tesla à crédit, plateforme en faillite) avec 8 garde-fous ; 9 titres d'époque.
5. **Avis sur le backlog** (§4) : d'abord les **trophées de bonne pratique** et l'étagère de la maison, puis le **bureau de tabac** (tickets à gratter avec compteur net, garde-fous stricts, pas de casino), puis le **niveau d'explication**.

| Proposition | Plaisir | Pédagogie | Coût |
|---|---|---|---|
| Gabarit de chapitre et archétypes (G1) | moyen (rejouabilité par époque) | fort (même leçon, autre décor) | faible : c'est une règle d'écriture des données |
| 2 profils de plus en 1984 + R-SEUL (G2) | fort (3 parties différentes sur le même chapitre) | moyen à fort (train de vie, somme d'un coup) | moyen : données, ~12 cartes variantes, 1 portrait, recalibrage |
| Chapitre 2019-2023 (G3) | fort (récent, reconnaissable, Covid en direct) | fort (taux réel, ETF, PEA, levier, arnaques en ligne) | fort (lot 12 entier : contenu, décor, rival) |

---

## 1. G1 : structure d'un chapitre

### 1.1 Durée : 5 ans, confirmé

- 60 mois, comme la démo validée par le joueur (« le cadre de la démo est ok », 29/10 ; « je ne trouve pas les pauses trop nombreuses », 16/11). Tout le calibrage (cadence, 20 min, projets à 80 / 60 %, seuils des titres) est fait pour 60 mois.
- Le mois de la **vitrine** se place entre le **13e et le 46e mois** : assez tard pour que le joueur ait placé, assez tôt pour que « un an après » tombe dans la partie (ce qui exclut une vitrine dans les 12 derniers mois).
- Pas de chapitre qui finit au fond d'un krach sans « un an après » (exigence de B2).
- Mode « carrière » (même personnage sur plusieurs chapitres) : plus tard, hors de ce plan.

### 1.2 Le gabarit : ce qui est commun et ce qui se réécrit

| Élément | Nombre par chapitre | Commun (moteur, règles) | Réécrit par chapitre (données) | Qui écrit |
|---|---|---|---|---|
| Durée, cadence | 60 mois ; 24 à 27 interruptions avec pause ; tunnel ≤ 3 mois | R-CADENCE, anticipation sans fuite, budgets, bouton COURRIER | dates des interruptions | game designer |
| Présentations du banquier | 6 à 8 | déclencheurs **relatifs** au début, dates limites | catalogue, textes, nom du banquier | banquier |
| Date historique d'offre | 1 (Saint-Gobain 1986 ; FDJ 2019) | modale d'offre publique | produit, prix, date | banquier + boursier |
| Cartes du foyer | 10 créneaux, 16 cartes, 8 à 10 jouées | humeur, coût d'opportunité au taux du mois, R-MIROIR, grisé si non payable, C00 | textes, prix (§1.3), dates des créneaux | game designer (textes), banquier (prix) |
| Carte « arnaque » | 1, créneau fixe, jamais retiré | type `placement`, perte toujours, non recopiée chez les voisins, notification à +6 à +9 mois | l'arnaque de l'époque | game designer |
| Projets | 2 (3 options chacun) ; un seul en cours | jauge, rappel à 3 mois, jour J, report unique, vente automatique, `dans_patrimoine` | noms, montants, dates : P1 choisi au 3e mois, échéance du 28e au 34e mois ; P2 choisi du 37e au 40e mois (jamais pendant un P1 reporté), options courte (4 à 6 mois), moyenne (10 à 13 mois), longue (fin de partie, `dans_patrimoine`) | game designer + banquier |
| Événements de vie scriptés | 1 à 2 par profil | modale de vie, effets sur salaire et dépenses | naissance, prime, donation… | game designer |
| Rival | 1 | moteur `Quartier` (plan en proportions, liquidation, dette), J1 / J2 / J3, phrase du levier calculée | nom, produit, devise, plan, répliques | game designer + boursier |
| Témoins Tata Livret, Tonton Matelas | 2 | identiques dans tous les chapitres (archétypes **sans âge** : « Tata Livret ne vieillit pas ; le Livret A non plus ») | répliques datées | game designer |
| Passages de la rue | 12 à 16 bulles dont 5 ★ | ≤ 1 bulle tous les 2 mois, ★ historisées | textes | game designer |
| Kiosque | 10 à 12 titres | sans pause, hors budget | titres d'époque | game designer, dates boursier |
| Vitrine | 1 séquence ≤ 15 s + modale 3 choix + « un an après » | instantané, 3 barres, fenêtre de vente relative | séance jour par jour, storyboard, textes | boursier (données), game designer (textes), UX |
| Événement de marché secondaire | 0 à 1 | modale de marché | date, texte | boursier |
| Titres | 9 | 9 archétypes, ordre et conditions de docs/28 | noms, « pourquoi », paramètres (§1.5) | game designer |
| Pop-up de début | 1 par profil | 4 blocs de docs/32 | bloc 1 et ligne « défi » | game designer |
| Accroche du chapitre | 1 (≤ 25 mots) | écran de choix | texte | game designer |

**Fils rouges entre les chapitres** (coût nul, plaisir de reconnaissance pour celui qui rejoue) : Tata Livret et Tonton Matelas identiques ; **Mme Lopez**, concierge en 1984, retraitée et « mémoire de la rue » en 2019 ; la **banque** au même endroit (en 2019, la conseillère est **Sandrine Lefranc**, la petite-fille : à valider par le client) ; le gag de **Vierzon** (les beaux-parents qui invitent en août) revient à chaque époque ; un rival par époque qui finit toujours « à vélo ».

### 1.3 Les 13 archétypes de cartes (réutilisables)

Prix exprimés en **M** = salaire mensuel du profil au début du chapitre, multiplié par le **coefficient de cartes** du profil (§2.3), arrondi à 100 F ou à 10 € ; le banquier peut remplacer un prix par un prix d'époque vérifié.

| Arch. | Fonction (ne change jamais) | Prix de réf. (choix a / b) | 1984 (Gérard) | 2019 (Julie) | Contraintes |
|---|---|---|---|---|---|
| A0 Réconciliation | seule conséquence en argent de l'humeur | 0,35 M / 0 | C00 Deauville | C00 Étretat | remplace un créneau, 2 fois au plus |
| A1 Vacances | dépense de plaisir récurrente | 1 à 1,3 M / 0 à 0,35 M | C01, C11, C13 | C01, C11, C13 | 3 à 4 par chapitre |
| A2 Saison | sports d'hiver ou équivalent | 1 M / 0 | C15 | C15 | seulement sans échéance de projet le même mois |
| A3 Techno | objet de l'époque, prix qui baisse ensuite | 0,8 à 1,4 M / 0 à 0,1 M | C02 magnétoscope, C09 caméscope | C02 smartphone, C09 vélo électrique | |
| A4 Abonnement | coût qui revient chaque mois | 0,25 M par an / 0 | C03 Canal+ | C03 streaming | le « pourquoi » chiffre l'année |
| A5 Enfant | matériel de l'enfant | 0,35 à 0,6 M / 0 | C04 poussette | C04 poussette trio | `requiert_enfant` |
| A6 Fête | fête de famille | 0,9 M / 0,1 M | C05 naissance | C05 fête de naissance / 30 ans | |
| A7 Arnaque | promesse trop belle ; perte certaine | ≈ 1,2 M / 0 | C06 escargots | C06 livret miracle | **fixe, jamais retirée**, type `placement` |
| A8 Investir en soi | coût contre salaire + 4 % plus tard | 0,4 à 0,7 M / 0 | C07 CNAM | C07 formation (CPF) | nature `neutre` |
| A9 Famille | cadeau ou fête de la belle-famille | 0,35 M / 0,05 M | C08 noces | C08 mariage reporté | |
| A10 Animal | moins cher n'est pas plus triste | 0,5 M / 0,06 M (+1 aussi) | C10 chien | C10 chien | sortie +1 pour la fourmi (docs/23) |
| A11 Bien-être | dépense régulière de confort | 0,45 M / 0 | C12 gym | C12 salle de sport | |
| A12 Revenu | vendre des objets | + 0,18 M / 0 | C14 vide-grenier | C14 vente en ligne | nature `epargne` / `neutre` |

Règles du gabarit : 1 A0, 1 A7, 1 A8, 1 A12 par chapitre ; au plus 4 A1 ; les **natures** (`epargne`, `depense`, `neutre`) suivent l'archétype (docs/28 §2), ce qui garde les seuils des titres 4 et 5 valides d'un chapitre à l'autre.

### 1.4 Gabarits de texte nécessaires (pour dev-logique)

- `{proche}` (Sylvie, Alain, Fred…), `{de_proche}` (« de Sylvie », « d'Alain » : élision), `{e}` (accord : ravie / ravi), `{prenoms}` (enfants), `{conjoint_ou_ami}` (« votre compagne », « votre mari », « votre meilleur ami »).
- Répliques : champ facultatif `replique_m` quand le proche est un homme (3 cas en 1984 : C07a « seule » → « seul », C02 et C12 réécrits, §2.4).
- Champ `foyer` sur chaque carte : `tous` (défaut), `couple`, `seul` ; et `profils` (liste) pour les cartes propres à un profil. Une candidate incompatible avec le profil est **sautée** comme `requiert_enfant` aujourd'hui.

### 1.5 Les titres : 9 archétypes, renommés par époque

- Mêmes **id**, même **ordre**, mêmes **conditions** que docs/28 §1.2 dans tous les chapitres (code inchangé). Par chapitre, `titres.json` change : `nom`, `nom_f` (forme féminine), `pourquoi`, et 3 paramètres : `produits_surs` (produits sans risque de l'époque), `fenetre_vente_krach` (vitrine + 1 → vitrine + 6), `ecart_min` (2 % par défaut).
- Pourquoi garder les mêmes conditions : chaque archétype est une **façon de jouer** (fourmi, cigale, marin…). Le joueur qui change d'époque retrouve les mêmes leçons sous un autre costume, et la collection reste comparable (« 3 / 9 en 1984, 1 / 9 en 2019 »).

### 1.6 Records, collection, trophées

- **Record par chapitre** (écart final face à Tata Livret), tous profils confondus, avec le profil noté à côté (« + 7,4 % · Bernard »). Les marchés diffèrent d'un chapitre à l'autre : un record commun comparerait 1984 à 2019, pas le joueur à lui-même. Le pourcentage face à Tata, lui, neutralise le profil (R-MIROIR).
- **Collection par chapitre** (9 cases chacune), plus une ligne de total à l'écran titre (« Titres : 4 / 18 »). Un titre s'obtient avec n'importe quel profil.
- **Trophées de bonne pratique** (backlog n° 1, détail §4.1) : 6 trophées **communs** à tous les chapitres, mêmes conditions, comptés par chapitre.

### 1.7 Niveau d'explication (lien avec le backlog n° 2)

- Il ne touche **que** les textes du banquier (présentations, fiches, relevé de décembre), pas les cartes, projets ni titres (le jeu reste le même à tous les niveaux).
- Champs par présentation : `texte` (intermédiaire, l'actuel), `texte_detail` (débutant : + 1 paragraphe « Dans votre cas », avec les gabarits du profil : salaire, projet en cours, épargne du mois), `texte_court` (expert : 1 ligne, la carte à 5 critères suffit).
- Coût d'écriture par chapitre : ≈ 8 présentations × 2 textes de plus = 16 textes (banquier). Réglage choisi à la création de partie, gardé dans la sauvegarde, modifiable dans le menu.

---

## 2. G2 : profils types de 1984-1988

### 2.1 Les trois profils

| | **Gérard** (profil 1, existant) | **Martine** (profil 2) | **Bernard** (profil 3) |
|---|---|---|---|
| Libellé à l'écran de choix | Le technicien | La cadre pressée | L'héritier |
| Âge, métier | 26 ans, technicien | 32 ans, cadre commerciale chez un fabricant d'électroménager | 25 ans, contrôleur à la SNCF |
| Colonne de `salaires.json` | `technicien` (6 790 F en 01/1984) | `cadre` (≈ 13 700 F en 01/1984, interpolé) | `heritier` (≈ 5 900 F en 01/1984, interpolé) |
| Épargne possible (`depenses`) | 24 % | 15 % (≈ 2 050 F/mois) | 12 % (≈ 700 F/mois) |
| Situation | en couple, non marié, avec Sylvie | mariée à **Alain**, instituteur ; une fille, **Céline**, 4 ans | **célibataire** ; proche : **Fred**, son meilleur ami (règle R-SEUL, §2.2) |
| Départ | 11 000 F sur le compte courant | 20 000 F sur le compte courant (1,5 mois) | 3 000 F sur le compte courant + **120 000 F** hérités de sa grand-mère en décembre 1983, sur le compte courant (colonne `capital`, à valider par le banquier) |
| Événements scriptés | naissance 04/1985 (jumeaux 1 fois sur 4) ; héritage de tante Odette 04/1988 | **2e enfant** 04/1985 (jumeaux 1 fois sur 4) ; héritage de tante Odette 04/1988 (K3 : ce qui change pour une femme mariée) | 04/1985 : **mariage de Fred, vous êtes témoin** (vie, 1 500 F, humeur +1) ; **pas d'héritage en 1988** (il a déjà hérité ; le créneau d'avril 1988 reste libre) |
| Défi (ligne de la pop-up) | construire, mois après mois, avec un salaire moyen | bien gagner sa vie ne suffit pas : encore faut-il en garder une part | que faire de 120 000 F reçus d'un coup ? |
| Leçon visée (jamais dite) | régularité, intérêts composés, PEL | train de vie (les cartes coûtent plus cher, la tentation est plus forte) | placer une grosse somme, plafond du Livret A, le krach vu avec beaucoup à perdre |
| Coefficients (§2.3) | cartes 1 ; projets 1 | cartes 1,6 ; projets 1,3 | cartes 1 ; projets 2,5 (options propres) |

- Le défi est une **question ou un constat**, jamais une consigne (« que faire de… ? » et non « diversifiez »).
- R-MIROIR inchangée : les trois voisins ont le salaire, le départ (y compris les 120 000 F de Bernard) et les dépenses du profil choisi. Le rang et les titres restent donc justes pour tous les profils.

### 2.2 Règle du foyer sans conjoint (R-SEUL)

Choix : **un profil sans conjoint** (Bernard), plutôt que tous en couple. Raison : le joueur veut « 3 profils types de l'époque » ; trois couples se ressembleraient, et un célibataire est un cas réel fréquent. Le coût reste faible car le moteur ne change pas.

1. **Le moteur d'humeur ne change pas** : valeur −3..+3, 3 états, usure positive en janvier, C00. Le profil désigne un `proche` : `{ "nom": "Fred", "lien": "ami", "feminin": false }`. Pour un couple : `lien: "conjoint"`.
2. **Ce que mesure l'humeur** : pour un célibataire, c'est « la bande ». Trop d'économies, et les copains n'appellent plus. Même leçon que la fourmi en couple : épargner n'est pas une faute, mais une vie à côté compte aussi.
3. **Affichage** : le visage de Fred (3 états) à la fenêtre « Mon foyer » et dans les bulles. À la fenêtre de la maison : Fred accoudé à la fenêtre avec Bernard (content), Bernard seul (neutre), Bernard seul devant la télé, volets mi-clos (fâché). **Repli moins cher** : le portrait de Fred à la place de celui de Sylvie, mêmes 3 visages. Coût : un portrait en 3 états (UX, dev-ville).
4. **Effets** : naissance absente ; mariage de Fred +1 ; projets réalisés +2 / +1 ; reports et abandons −1 / −2 (inchangé).
5. **Cartes** : chaque carte porte `foyer` (§1.4). Les cartes de couple sont réécrites pour le célibataire quand l'archétype l'exige (§2.4) ; les autres prennent `{proche}`.
6. **Titres** : conditions inchangées (l'humeur est celle du proche). Le titre 1 devient « Le bon père de famille (sans famille) » pour Bernard, « La bonne mère de famille » pour Martine (`nom_f`).
7. **Bulles** : le proche parle comme Sylvie (phrases sans « tu » ni « vous », 2 à 8 mots, docs/23 G1.1).

### 2.3 Calibrage par profil (à mesurer par les tests)

- **Coefficient de cartes** : prix des archétypes × coefficient (Martine 1,6 : elle gagne deux fois plus mais n'épargne que 15 % ; la tentation doit coûter plus).
- **Coefficient de projets** : Martine 1,3 sur les options de Gérard ; Bernard a ses options propres (§2.5) car son capital rend les projets de Gérard sans enjeu.
- CA de calibrage repris de docs/15 CA-1.2 pour chaque profil : option la plus chère de P1 réalisée à la date sur ≥ 80 % des graines (stratégie « tout au Livret A, choix b ») ; option du milieu de P2 sur ≥ 60 %. J1 et J2 de Jean-Mi pour chaque profil. Répartition des 9 titres par profil (alerte si un titre dépasse 50 % des parties `alterner`).

### 2.4 Cartes variantes de 1984

Martine (`profils: ["cadre"]` ou gabarits) :

| Carte | Changement |
|---|---|
| C02 Le magnétoscope | « Chez Darty, un magnétoscope VHS : {prix_a}. Alain ne veut plus rater un match du Tournoi. » Répliques : a « Ce soir, on enregistre le match ! » ; b « Encore un match de raté… » |
| C07 → **Le séminaire du samedi** | « Une formation au management, le samedi pendant un an : {prix_a}. Votre directeur parle d'une promotion. » a S'inscrire (−1, salaire + 4 % en 01/1988, `replique_m` « Tous les samedis seul avec Céline… ») ; b Pas cette année (0) |
| C12 → **L'aide ménagère** (nouvelle) | « Une aide ménagère deux matinées par semaine : {prix_a} l'année. Alain propose plutôt de partager les tâches. » a L'embaucher (+1, « Enfin du temps pour nous ! ») ; b Partager les tâches (0, « Je fais les vitres, pas le repassage. ») ; natures depense / epargne |
| Autres | `{proche}` = Alain, `{e}` masculin ; enfants : « Céline et {prenoms} » |

Bernard (`foyer: "seul"`) :

| Carte | Titre | Texte (≤ 30 mots) | Choix a | Choix b |
|---|---|---|---|---|
| C00s | La bande s'éloigne | Fred ne vous appelle plus. La bande part en week-end à Amsterdam sans vous demander. | Les rejoindre : 0,35 M, humeur → 0, « Comme au bon vieux temps ! » | Rester tranquille : 0, « Ils reviendront. » |
| C01s | Les vacances 84 | Fred a trouvé le Club Med d'Agadir, « spécial célibataires ». Sinon, la tente de son frère à Palavas. | Club Med : 1,3 M, +1, « Agadir, quelle ambiance ! » | Palavas : 0,35 M, −1, « Encore Palavas… » |
| C04s | La moto | Une Honda d'occasion, chez le garagiste du coin : {prix_a}. Fred a déjà le casque. | L'acheter : 0,6 M, +1, « Direction la côte ! » | Garder la mobylette : 0, 0, « Elle démarre, c'est l'essentiel. » |
| C05s | La crémaillère | Vous emménagez dans un deux-pièces. Fred veut une vraie crémaillère, avec un orchestre. | Grande fête : 0,9 M, +1, « On s'en souviendra ! » | Pizza entre amis : 0,1 M, 0, « Simple et bon. » |
| C08s | Les noces de vos parents | Trente ans de mariage : votre sœur organise un voyage à Venise. Votre part : {prix_a}. | Participer : 0,35 M, +1, « Maman a pleuré de joie. » | Une carte et des fleurs : 0,05 M, −1, « Des fleurs… pour trente ans. » |
| C06 | Les escargots | « Patrick, un copain du foot, lance un élevage d'escargots… » (suite inchangée) | inchangé | inchangé |
| C10 | Le chien | Repli sans enfant de docs/23 : « Vous avez toujours rêvé d'un chien. Un labrador d'élevage, ou un chien de la SPA ? » | inchangé | inchangé |
| C11 | Les vacances 87 | « … Les parents de Fred vous invitent à Vierzon. » | inchangé | inchangé |

Sont sautées pour Bernard : C04, C05 et C09 dans leur forme « enfant » (remplacées par C04s, C05s ; C09 devient « filmer les copains »).

### 2.5 Projets des nouveaux profils (montants C, à calibrer)

| Projet | Gérard (existant) | Martine (× 1,3, noms adaptés) | Bernard (options propres) |
|---|---|---|---|
| P1A (04/1986) | Le salon et la chaîne hi-fi, 12 000 F | Le salon et la chaîne hi-fi, 16 000 F | La chaîne hi-fi et le magnétoscope, 15 000 F |
| P1B (04/1986) | La Grèce pour les 30 ans de Sylvie, 16 000 F | La Grèce en famille, 22 000 F | Le tour des États-Unis avec Fred, 25 000 F |
| P1C (04/1986) | La Super 5 neuve, 30 000 F | Une BMW série 3 (apport, la R18 reprise), 40 000 F | **La 205 GTI neuve** (apport), 60 000 F |
| P2A (07/1987) | Le Club Med en famille, 14 000 F | Le Club Med en famille, 18 000 F | Le Club Med avec la bande, 15 000 F |
| P2B (02/1988) | Un break familial, 35 000 F | La maison de campagne : les travaux, 45 000 F | Un voilier d'occasion, 60 000 F |
| P2C (12/1988) | L'apport pour un T3, 90 000 F | L'apport pour une maison, 120 000 F | L'apport pour un appartement à soi, 150 000 F (`dans_patrimoine`) |

Pour Bernard, les projets pèsent sur le capital : la tension vient du choix « je dépense mon héritage ou je le place », pas de la jauge mensuelle. La 205 GTI (lancée en 1984, certitude B) fait un clin d'œil à Jean-Mi, vendeur Peugeot.

### 2.6 Pop-up de début (blocs 1 et ligne « défi » ; blocs 2 à 4 de docs/32 inchangés)

- **Martine** : « Vous êtes Martine, 32 ans, cadre commerciale. Vous êtes mariée à Alain, instituteur, et vous avez une fille, Céline, 4 ans. Vous gagnez {salaire} par mois et vous avez {depart} sur votre compte courant. » Défi (fin du bloc 3) : « Votre défi : bien gagner sa vie ne suffit pas, encore faut-il en garder une part. »
- **Bernard** : « Vous êtes Bernard, 25 ans, contrôleur à la SNCF, célibataire. Votre grand-mère vous a laissé {capital}, qui dort sur votre compte courant. Vous gagnez {salaire} par mois. » Défi : « Votre défi : que faire de cette somme reçue d'un coup ? »
- **Gérard** : texte de docs/32 inchangé, plus le défi : « Votre défi : construire, mois après mois, avec un salaire moyen. »
- Bloc 2 : « M. Lefranc, votre banquier » reste ; pour Bernard, « des dépenses de famille » devient « des dépenses, des amis » (gabarit `{attente}`).

---

## 3. G3 : chapitre 2019-2023 « Les années smartphone »

### 3.1 Accroche et repères

- **Nom** : Les années smartphone.
- **Accroche** (écran de choix, 24 mots) : « 2019. Le Livret A rapporte 0,75 %, on commande tout sur son téléphone, même des actions. Cinq ans pour faire mieux que Tata Livret. »
- Contrôle A5 / A8 : ni Covid, ni inflation, ni hausse des taux, ni krach. Le Livret A à 0,75 % est un fait du premier mois (certitude A).
- Faits de l'époque qui servent la pédagogie (certitude A sauf mention, à revalider par K2 et B3) : Livret A 0,75 % → **0,5 % (02/2020)** → 1 % (02/2022) → 2 % (08/2022) → **3 % (02/2023)** ; inflation 2022 ≈ 5,2 %, 2023 ≈ 4,9 % ; flat tax 30 % depuis 2018 ; plafond du PEA 150 000 € ; PEL à 1 % brut jusqu'en 2022, 2 % pour un PEL ouvert en 2023.
- **Leçons visées** (jamais dites) : taux réel (Livret A à 3 % contre 5 % d'inflation), frais bas des ETF, PEA, krach éclair et retour, arnaques en ligne, levier et plateforme.

### 3.2 Les trois profils

| | **Julie** | **Thomas** | **Nathalie** |
|---|---|---|---|
| Libellé | L'infirmière | Le développeur | La cadre en famille |
| Âge, métier | 29 ans, infirmière à l'hôpital | 27 ans, développeur dans une petite entreprise | 38 ans, cadre commerciale |
| Colonne | `technicien` (≈ 2 320 €) | `heritier` (≈ 2 200 €) | `cadre` (≈ 4 240 €) |
| Épargne possible | 18 % (≈ 420 €) | 12 % (≈ 265 €) | 15 % (≈ 640 €) |
| Situation | **pacsée** avec Karim, technicien de maintenance | **célibataire** (R-SEUL), proche : **Léa**, sa meilleure amie | **mariée** à Franck, deux enfants : Inès (9 ans), Hugo (6 ans) ; crédit immobilier en cours (dans le loyer) |
| Départ | 3 500 € sur le compte, 1 500 € sur un Livret A ouvert par ses parents | 2 000 € sur le compte + **40 000 €** de l'assurance-vie de sa grand-mère, reçus en décembre 2018, sur le compte | 6 000 € sur le compte, 8 000 € sur le Livret A |
| 04/2020 (confinement, pour tous) | « en première ligne » : **prime Covid** (1 500 € ou 500 € selon le département, certitude A/B) versée en 06/2020 ; **Ségur** + 183 € net par mois dès 09/2020 (A) | télétravail : dépenses courantes − 30 % pendant 2 mois (épargne forcée) | **chômage partiel de Franck** : revenu du foyer − 400 € pendant 2 mois |
| 2e événement scripté | **naissance 07/2021** (jumeaux 1 fois sur 4) | 07/2021 : **nouvel employeur**, salaire + 10 % | 07/2021 : **donation des parents**, 30 000 € (abattement de 100 000 € par parent et par enfant, A) |
| Défi | « Bâtir avec un salaire modeste, et un bébé en projet. » | « Que faire de 40 000 € reçus d'un coup ? » | « Bien gagner, bien dépenser… et en garder une part. » |
| Coefficients | cartes 1 ; projets 1 | cartes 1 ; projets : options propres | cartes 1,6 ; projets 1,8 |

R-MIROIR : les voisins reçoivent aussi la prime, le Ségur, l'épargne forcée, la donation (comme l'héritage d'Odette aujourd'hui).

**Pop-up de début, bloc 1** :
- Julie : « Vous êtes Julie, 29 ans, infirmière. Vous êtes pacsée avec Karim. Vous gagnez {salaire} par mois, avec {depart} sur votre compte et {livret} sur votre Livret A. »
- Thomas : « Vous êtes Thomas, 27 ans, développeur, célibataire. Votre grand-mère vous a laissé {capital}, posés sur votre compte courant. Vous gagnez {salaire} par mois. »
- Nathalie : « Vous êtes Nathalie, 38 ans, cadre commerciale, mariée à Franck, mère d'Inès et d'Hugo. Vous gagnez {salaire} par mois, avec {depart} sur votre compte et {livret} sur votre Livret A. »
- Bloc 2 : « Cinq ans de vie, de 2019 à 2023 : des dépenses de famille, des projets, des surprises. Sandrine Lefranc, votre conseillère, vous présentera ses placements. Les marchés auront leurs secousses. »

### 3.3 Calendrier de référence (Julie ; ■ = pause, ○ = sans pause)

| Mois | ■ | ○ |
|---|---|---|
| 01/19 | D01 Livret A et LDDS (banquier) | |
| 02/19 | | V01 Mme Lopez ★ « La rue » |
| 03/19 | **Choix du projet 1** | |
| 05/19 | D02 PEL (limite 06/19) | |
| 07/19 | **S1** C01 ou C02 | |
| 09/19 | D03 PEA et actions (limite 09/19) | |
| 11/19 | **Date historique : la FDJ entre en Bourse** (offre, §3.7) | |
| 01/20 | **S2** C03 ou C02 | Livret A à 0,5 % (02/20) |
| 03/20 | **Vitrine : mars 2020** (séquence + modale 3 choix) | instantané |
| 04/20 | **Le confinement** (vie, forcé ; exception vitrine → vie comme krach → panne) | applaudissements de 20 h |
| 06/20 | **S3** C16 ou C09 | prime Covid (Julie) |
| 08/20 | D04 Assurance-vie : fonds en euros et unités de compte (limite 10/20) | |
| 09/20 | | Ségur (Julie) |
| 11/20 | **S4** C06 Le livret miracle (fixe) | |
| 01/21 | **S5** C07 ou C08 | kiosque GameStop |
| 03/21 | **Mars 2020, un an après** (média) | |
| 05/21 | D05 ETF (limite 05/21) | issue du livret miracle (si placé) |
| 07/21 | **Naissance** (vie scriptée) | rappel du projet 1 |
| 08/21 | | V09 Max entre ★ |
| 10/21 | **Échéance du projet 1** | |
| 11/21 | | V10 la Tesla ★ |
| 12/21 | **S6** C10 ou C09 | |
| 02/22 | D06 LEP ou PER selon le profil (K2) ; ou échéance reportée du projet 1 (la présentation glisse) | kiosque Ukraine ; Livret A 1 % |
| 04/22 | **Choix du projet 2** (fenêtre 03 → 04/22 : jamais pendant un projet 1 reporté) | |
| 06/22 | **Marché : l'inflation au plus haut, la BCE relève ses taux** (boursier) | liquidation de Max |
| 08/22 | **Échéance P2A** — sinon **S7** C11 | Livret A 2 % |
| 10/22 | **S8** C04, C05 ou C12 | |
| 11/22 | | V13 la plateforme de Max ★ |
| 02/23 | **Échéance P2B** — sinon **S10** C15 | Livret A 3 % |
| 03/23 | | kiosque banques américaines |
| 05/23 | **S9** C13 | |
| 08/23 | **S10 bis** C14 (vente en ligne) | |
| 12/23 | (échéance P2C si choisi) puis **fin** | V16 Max ★ |

Compte : 6 présentations + FDJ, 2 marché (vitrine, 2022), 2 vie scriptées + confinement, 0 à 2 aléatoires, 10 créneaux (8 à 10 cartes), 4 projets, 1 « un an après » : **25 à 28**, comme 1984. Plus long tunnel : 3 mois. Les dates des présentations sont des **limites** : le moteur les place (déclencheurs relatifs). Pour Thomas et Nathalie, le 07/21 porte leur événement propre. Vérification R-CADENCE faite sur ce tableau : aucune pause deux mois de suite hors vitrine → confinement.

### 3.4 Les cartes (prix pour Julie, coefficient 1 ; C : à valider par le banquier)

| id | Titre | Texte (≤ 30 mots) | Choix a | Choix b | Créneau |
|---|---|---|---|---|---|
| C00 | {proche} fait la tête | {proche} ne vous parle plus depuis trois jours. Un week-end à Étretat, juste tous les deux ? | Partir : 350 €, → 0, « Les falaises, c'était magique ! » | Profil bas : 0, « Je ne boude pas. Je réfléchis. » | remplace |
| C00s (Thomas) | La bande s'éloigne | Léa et la bande partent à Lisbonne sans vous. Le groupe de discussion est bien calme. | Les rejoindre : 400 €, → 0 | Rester : 0 | remplace |
| C01 | Les vacances 2019 | Karim rêve d'un club en Croatie. Ses cousins prêtent leur tente pour l'Ardèche. | Croatie : 2 400 €, +1, « Une eau turquoise ! » | Ardèche : 600 €, −1, « Encore les moustiques… » | S1 |
| C02 | Le smartphone | L'écran de Karim est fissuré. Le dernier modèle : {prix_a}. Un reconditionné fait presque pareil. | Le neuf : 1 100 €, +1, « Il fait de ces photos ! » | Reconditionné : 250 €, 0, « Comme neuf, ou presque. » | S1, S2 |
| C03 | Les abonnements | Films, séries, musique, sport : tout prendre fait {prix_a} par mois. Ou un seul, à tour de rôle ? | Tout prendre : 45 €/mois (540 € l'an), +1, « Enfin la série dont tout le monde parle ! » | Un seul : 0, 0, « Un à la fois, ça suffit. » | S2 |
| C16 (vacances 2020) | Les vacances en France | Cette année, on reste en France. Un gîte dans le Cantal, ou chez les parents de Karim, à Vierzon ? | Le gîte : 900 €, +1, « Le silence, enfin ! » | Vierzon : 0, −1, « Vierzon. En août. Encore. » | S3 |
| C09 | Le vélo électrique | Pour aller à l'hôpital sans les transports : un vélo électrique, {prix_a}. Ou réparer le vieux vélo. | Électrique : 1 600 €, +1, « Plus jamais en retard ! » | Le vieux vélo : 60 €, 0, « Il grince, mais il roule. » | S3, S6 |
| C06 | Le livret miracle | Une publicité : un « livret » à 8 % garanti, au nom d'une grande banque. Le cousin de Karim y a mis 5 000 € et touche ses intérêts. Minimum : {prix_a}. | Placer : 3 000 €, +1, « Mon cousin n'est pas un menteur ! » | Refuser : 0, −1, « Tu fais confiance à personne. » | S4 (fixe) |
| C07 | La formation | Une formation certifiante du soir, en partie payée par votre compte formation. Reste à payer : {prix_a}. Une promotion devient possible. | S'inscrire : 1 200 €, −1, salaire + 4 % en 01/2023, « Deux soirs par semaine, seul à la maison… » (Karim ; forme féminine pour un proche femme) | Pas cette année : 0, 0, « L'an prochain, peut-être. » | S5 |
| C08 | Le mariage reporté | Le mariage de la sœur de Karim, reporté deux fois, a enfin lieu. Enterrement de vie de jeune fille, tenue, cadeau : {prix_a}. | Tout faire : 900 €, +1, « On a dansé jusqu'à l'aube ! » | Juste le mariage : 200 €, −1, « On est partis avant le gâteau… » | S5 |
| C10 | Le chien | Depuis le confinement, tout le quartier a un chien. Un chiot de race, ou un chien de refuge ? | De race : 1 500 €, +1, « Il est magnifique ! » | Refuge : 150 €, +1, « C'est lui qui nous a choisis. » | S6 |
| C11 | Les vacances 2022 | Une maison en Bretagne en août : {prix_a}. Les parents de Karim, à Vierzon, ont repeint la chambre d'amis. | Bretagne : 1 400 €, +1, « Les crêpes, la mer ! » | Vierzon : 0, −1, « Vierzon, mais en couleur. » | S7 |
| C04 | La poussette | Une poussette « trio » neuve : {prix_a}. Une voisine vend la sienne sur internet, presque pas servie. | La neuve : 900 €, +1, « Elle se plie d'une main ! » | D'occasion : 150 €, 0, « Comme neuve, vraiment. » | S8 (`requiert_enfant`) |
| C05 | La fête de naissance | Les deux familles veulent fêter {prenoms}. Une salle avec traiteur, ou un repas à la maison ? | La salle : 2 000 €, +1, « Toute la famille réunie ! » | La maison : 300 €, 0, « Un bon repas, c'est l'essentiel. » | S8 (`requiert_enfant`) |
| C12 | La salle de sport | La salle de sport du coin : {prix_a} l'année, avec les cours collectifs. Ou courir au parc. | S'abonner : 480 €, +1, « Ma coach est géniale ! » | Le parc : 0, 0, « Au parc, il y a des canards. » | S8 |
| C15 | Les sports d'hiver | Les collègues partent aux Arcs en février. Une semaine en famille : {prix_a}. | Partir : 2 500 €, +1, « La neige, enfin ! » | La luge au parc : 0, −1, « La luge au parc… vraiment ? » | S10 (si pas d'échéance en 02/23) |
| C13 | Les vacances 2023 | Un van aménagé loué deux semaines : {prix_a}. Ou la vieille tente de l'Ardèche ? | Le van : 1 800 €, +1, « On s'arrête où on veut ! » | La tente : 300 €, −1, « La tente prend toujours l'eau… » | S9 |
| C14 | La vente en ligne | Le placard déborde : la console, les vêtements, le vieux vélo. Tout vendre en ligne ? | Tout vendre : + 350 €, −1, « Pas ma console ! » | On garde tout : 0, +1, « Ma console reste avec moi ! » | S10 bis |

- Natures (docs/28 §2) : comme les archétypes (C06 et C07 neutres ; C14 a épargne, b neutre ; C10 b épargne ; C16 comme une carte de vacances). 17 cartes pour 10 créneaux, C00 compris.
- **Escargots de 2019 (C06)** : notification persistante à +6 mois (05/2021) : « Le site du livret miracle a fermé. Les 3 000 € ont disparu ; le cousin de Karim aussi a tout perdu. » **Perte totale, toujours.** Leçon : « Aucun placement honnête ne garantit 8 % quand le Livret A rapporte 0,5 %. Plus la promesse est belle, plus le risque est grand. » (Les premiers « intérêts » versés au cousin, c'est le principe de la cavalerie : à écrire par le banquier en une phrase si utile.) Trace P10 : un smartphone fissuré sur le mur, à la place de l'escargot.
- Thomas : C04 et C05 sautées (pas d'enfant) ; C05s **« Vos 30 ans »** (S8 : « La bande veut fêter vos 30 ans dans un bar privatisé. » a 1 200 € +1 ; b pique-nique 100 € 0). Nathalie : `{proche}` = Franck ; C04 → **« L'ordinateur d'Inès »** (S8 : « Inès entre au collège ; elle réclame un ordinateur portable. » a neuf 900 € +1 ; b celui de Franck, reformaté 0 0) ; C07 → formation de management, 4 000 €.

### 3.5 Les projets (montants C ; calibrage CA-1.2 à mesurer)

| Projet | Julie | Thomas | Nathalie (× 1,8 sauf mention) |
|---|---|---|---|
| Choix P1 | 03/2019, échéances **10/2021** (après la vitrine : la leçon de l'horizon) | idem | idem |
| Choix P2 | 04/2022 (fenêtre 03 → 04/2022) ; horizons de 4, 10 et 20 mois | idem | idem |
| P1A | La cuisine équipée, 4 000 € | Un ordinateur et un vélo de route, 3 500 € | La salle de bains refaite, 8 000 € |
| P1B | L'Islande à deux, 6 000 € | Six semaines en Amérique du Sud, 7 000 € | Les États-Unis en famille, 12 000 € |
| P1C | Une Clio récente d'occasion, 10 000 € | **Un van aménagé**, 30 000 € | Une voiture électrique (apport, prime déduite), 18 000 € |
| P2A (08/2022) | Un parc de vacances en famille, 1 800 € | Un festival et un road trip avec la bande, 2 000 € | Colonie pour les enfants et une semaine à deux, 3 500 € |
| P2B (02/2023) | Une voiture familiale (apport), 8 000 € | Meubler un deux-pièces, 6 000 € | L'isolation de la maison (aide de l'État déduite), 15 000 € |
| P2C (12/2023) | L'apport pour un appartement, 25 000 € (`dans_patrimoine`) | L'apport pour un studio, 45 000 € (`dans_patrimoine`) | L'apport pour un studio à louer, 40 000 € (`dans_patrimoine`) |

- Le report unique de 4 mois de P1 ne peut pas tomber pendant un confinement (échéance en 10/2021, report en 02/2022) : choix volontaire, pour ne pas mêler une contrainte sanitaire à la leçon.
- `detail` de P2C (banquier, une phrase) : en 2023, les taux des crédits immobiliers ont fortement monté ; l'apport compte plus (fait d'époque, montré **au jour J**, jamais avant).
- Leçons visées : P1 traverse la vitrine (argent d'un projet à 2 ans placé en actions en mars 2020) ; P2B tombe après la baisse de 2022 ; P2C profite du Livret A à 3 % et du PEA.

### 3.6 La vitrine : mars 2020, en direct, et un an après

**Séquence** (≤ 15 s, passable d'un toucher, aucun minuteur) :
- Tableau de 7 séances du CAC 40 (≈ 1,5 s chacune, chiffres rouges) : vendredi 21/02, lundi 09/03, jeudi 12/03, vendredi 13/03, lundi 16/03, mardi 17/03, mercredi 18/03/2020. Clôtures et variations : **boursier (B3)**, certitude par point ; repères à vérifier : jeudi 12/03 ≈ − 12 % (pire séance de l'histoire du CAC 40), point bas en clôture le 18/03.
- La rue : les rideaux de fer se baissent un à un ; une file devant la supérette (papier toilette sous le bras : humour d'époque, sans moquerie) ; les passants disparaissent ; un pigeon traverse la rue vide.
- Bulle du proche : « Ils ferment tout. Même les écoles. » Max (sans investir) : « Ça va encore baisser. J'attends le point bas. »
- Le téléphone de la maison vibre : « Sandrine Lefranc vous propose un appel en visio. » Puis la **modale des 3 choix** existante (Tout vendre / Ne rien faire / Renforcer), ligne « Face au Livret A », inchangée.
- Nom de la séquence (historique) : « Mars 2020 ». Le mot « krach » n'apparaît qu'**après** la séquence, comme en 1987.

**Le confinement** (04/2020, vie, forcé) : carte « Restez chez vous » : les dépenses courantes baissent, l'événement propre au profil (§3.2). Moment fort visuel : **à 20 h, toutes les fenêtres de la rue s'ouvrent et applaudissent** (pour Julie : « Julie, c'est pour toi », dit Karim). Ensuite, rue calme jusqu'en 06/2020 (moins de passants : décor).

**« Mars 2020, un an après »** (03/2021, média, 3 barres sur l'instantané, choix entouré) :
> « Un an après, la Bourse de Paris a retrouvé son niveau d'avant la crise [à vérifier par B3]. Ceux qui ont pu attendre ont retrouvé leur argent. En mars 2020, personne ne savait si ce serait un mois ou dix ans. » (≈ 40 mots)

Ligne de Max sous les barres : « Max attendait le point bas pour entrer. Il l'attend toujours. » (anti-market timing, sans valoriser « Renforcer » : la leçon porte sur l'horizon et sur l'impossibilité de deviner le point bas.)
Cas sans action : exemple de 2 000 € d'ETF, mention « exemple : vous n'aviez pas d'actions en mars 2020 ».

### 3.7 La date historique : la FDJ entre en Bourse (11/2019)

- Équivalent de Saint-Gobain 1986 : offre publique aux particuliers (prix réduit, action gratuite pour 10 gardées 18 mois : **à confirmer par le banquier et le boursier**, certitude B). Achetable dans le PEA ou au compte-titres.
- Pourquoi elle : c'est la privatisation populaire de l'époque, et elle prépare l'idée n° 3 du backlog (§4.3) : on peut être **actionnaire de la maison de jeux** plutôt que joueur.
- Texte : à écrire par le banquier ; garde-fou : pas de « bonne affaire », seulement les conditions de l'offre.

### 3.8 Le rival : Max, « l'investisseur du téléphone »

**Qui** : Max, 26 ans, vendeur de trottinettes électriques au bout de la rue, une chaîne vidéo où il parle « finance » à 300 abonnés. Rôle : **concentration, effet de levier, crédit à la consommation, plateforme non garantie**, et le **market timing** (il « attend le bon moment »). Pourquoi la cryptomonnaie plutôt que les « meme stocks » : c'est la folie la plus répandue chez les particuliers français de 2021-2022 ; GameStop reste un titre du kiosque et une bulle de Max.

**L'arc** (plan en proportions dans `temoins.json > rival` ; série de l'actif de Max : ancrages mensuels du bitcoin en euros 2021-2023, fournis par B3, certitude A ; **série jamais affichée au joueur** sous forme de cours ou de graphique) :

| Date | Étape | Chiffres provisoires (C) |
|---|---|---|
| 01/2019 → 07/2021 | vit comme vous (miroir), tout sur le compte courant, « attend le bon moment » | — |
| 03/2020 | « Ça va encore baisser. J'attends le point bas. » (n'achète pas) | — |
| 01/2021 | bulle : « Des petits porteurs ont fait plier Wall Street ! Moi, je prépare mon coup. » | — |
| 08/2021 ★ | met 80 % de son épargne sur une plateforme de cryptomonnaies, avec un **levier × 2** | position = 2 × couverture |
| 11/2021 ★ | **Tesla à crédit** devant chez lui : « Payée par le bitcoin ! » | 48 000 € ; apport 10 000 € pris sur ses gains ; crédit 38 000 € sur 60 mois (taux K2) |
| 12/2021 | renforce : « Quand ça monte, faut y aller ! » | + 30 % de position |
| 05/2022 | « C'est juste une correction. » | — |
| 06/2022 | **liquidation** : la baisse dépasse sa couverture | perte = toute la couverture ; reste la dette de la Tesla |
| 11/2022 ★ | sa plateforme fait faillite : le peu qui restait est bloqué | kiosque : « Une grande plateforme de cryptomonnaies fait faillite » (sans nom de marque) |
| 02/2023 | panneau « À VENDRE » sur la Tesla (les prix de l'occasion ont baissé, B) | ≈ − 30 % |
| 07/2023 | Max livre des repas à vélo ; Mme Lopez : « C'est pas le bitcoin, Max, c'est le crédit. » | — |
| 12/2023 ★ | « Le bitcoin est remonté… sans moi. » (à vérifier sur la série : fin 2023 au-dessus de 06/2022, A) | — |

**Phrase du levier** (11/2022, carte de lecture, montants calculés) : « Avec {couverture}, Max en a joué {position} sur sa plateforme. Sa cryptomonnaie a perdu {baisse} % depuis son achat : sa mise a disparu. Il doit encore {dette} sur sa Tesla. »

**Garde-fous** (CA du lot 12) :
1. **Aucun bouton** : ni cryptomonnaie, ni levier, ni appli de trading ne sont proposés au joueur ; le banquier ne les présente pas. S'il en parle (K2), c'est en une phrase factuelle (« ni garanti, ni proposé par la banque »).
2. **J1** : Max devant Tata Livret au moins 3 mois entre 09/2021 et 03/2022 (la montée est visible et tentante, c'est le but).
3. **J2** : Max derrière Tata d'au moins 10 % en 12/2023, visé dernier de la rue, **pour toute graine, toute stratégie et les 3 profils** (y compris Thomas et ses 40 000 €).
4. La leçon porte sur **le levier, le crédit et la plateforme**, jamais sur « la cryptomonnaie, c'est mal » : aucun texte ne dit « arnaque » à propos du bitcoin, ni « ça va remonter » (la dernière réplique est un constat, après coup).
5. Aucun cours de cryptomonnaie affiché ; aucune prévision hors des répliques de Max, dont les tuyaux échouent.
6. Max n'entre dans **aucune condition de titre** (comme Jean-Mi).
7. Pas de nom de plateforme ni de cryptomonnaie de marque autre que « bitcoin » (nom commun) ; pas de personnalité réelle.
8. Max n'est jamais ridicule au point d'humilier : il redémarre (le vélo, puis « Je recommence, mais avec un Livret A cette fois », bulle facultative en 12/2023).

### 3.9 La rue : passages (★ = historisés) et kiosque

| id | Date | Qui | Bulle (≤ 15 mots) |
|---|---|---|---|
| V01 ★ | 02/2019 | Mme Lopez | « Trente-cinq ans que je vois passer les voisins. Vous les connaissez ? » → carte « La rue » |
| V02 | 05/2019 | Tonton Matelas | « Une appli de banque ? Moi, c'est sous le matelas. Ça ne bugue pas. » |
| V03 | 09/2019 | Tata Livret | « 0,75 %, ce n'est pas beaucoup. Mais c'est garanti. » |
| V04 | 12/2019 | Max | « La Bourse ? J'attends le bon moment. Sur internet, ils savent tout. » |
| V05 | 06/2020 | Mme Lopez | « Ici, j'en ai vu passer, des crises. Et des Jean-Mi. » (clin d'œil sans divulguer 1987) |
| V06 | 10/2020 | Tata Livret | « 0,5 %… mais les prix ne bougent pas. Alors ça va. » |
| V07 | 01/2021 | Max | « Des petits porteurs ont fait plier Wall Street ! Moi, je prépare mon coup. » |
| V08 | 06/2021 | Mme Lopez | « Toute la rue a un chien maintenant. » |
| V09 ★ | 08/2021 | Max | « J'ai tout mis sur le bitcoin, et même le double. » |
| V10 ★ | 11/2021 | Max | La Tesla se gare. « Elle est belle, hein ? Payée par le bitcoin ! » |
| V11 | 06/2022 | Max | traverse la rue en fixant son téléphone, sans un mot (décor) |
| V12 | 09/2022 | Tonton Matelas | « Avec 100 €, j'avais {b0} baguettes en 2019. Aujourd'hui {b1}. » |
| V13 ★ | 11/2022 | Max | « Ma plateforme a fermé. Je n'ai plus rien… et il reste la Tesla. » → phrase du levier |
| V14 | 03/2023 | Tata Livret | « 3 % sur mon livret ! … Mais les courses ont pris plus. » |
| V15 | 07/2023 | Max (à vélo), Mme Lopez | M : « La Bourse, plus jamais ! » L : « C'est pas le bitcoin, Max, c'est le crédit. » |
| V16 ★ | 12/2023 | Max | « Le bitcoin est remonté… sans moi. » |

Bulles réactives : Mme Lopez au premier achat d'action (« Alors, on est actionnaire ? Comme pour la FDJ ! ») ; Sandrine Lefranc devant la banque le mois qui suit la vitrine (« Quel mois… ») ; le proche aux changements d'humeur.

**Kiosque** (dates à vérifier par B3) : 04/2019 Notre-Dame en flammes ; 07/2019 46 °C dans le Gard (06/2019) ; 11/2019 La FDJ entre en Bourse ; 12/2019 Grève contre la réforme des retraites ; 03/2020 figé sur « CONFINEMENT » ; 04/2020 20 h : la France applaudit ses soignants ; 12/2020 Premier vacciné en France ; 01/2021 GameStop : les petits porteurs défient Wall Street ; 02/2022 Guerre en Ukraine ; 04/2022 Macron réélu ; 11/2022 Une plateforme de cryptomonnaies fait faillite ; 12/2022 Les Bleus en finale de la Coupe du monde ; 03/2023 Retraites : le 49.3 ; 09/2023 Coupe du monde de rugby en France.
**Aucun titre sur un virus ou la Chine avant 03/2020** (A5 : ce serait annoncer la vitrine).

### 3.10 Les 9 titres de 2019-2023

Conditions de docs/28 §1.2 ; paramètres : `produits_surs: ["livret", "ldds", "lep", "pel"]` (selon le catalogue K2), `fenetre_vente_krach: ["2020-04", "2020-09"]`, `ecart_min: 0.02`, `part_risquee: 0.30`.

| Ordre | id | Nom (forme féminine) | Pourquoi (≤ 15 mots) |
|---|---|---|---|
| 1 | `bon_pere` | Le gestionnaire raisonnable (La gestionnaire raisonnable) | Depuis 2014, la loi dit « raisonnable » au lieu de « bon père de famille ». Vous l'êtes. (15) |
| 2 | `golden_boy` | Le confiné paniqué (La confinée paniquée) | Vendu dans la panique de mars 2020 : la baisse est devenue une perte. (13) |
| 3 | `escargots` | La victime du livret miracle | 8 % garantis, 100 % perdus : plus la promesse est belle, plus le risque est grand. (15) |
| 4 | `fourmi` | Le minimaliste trop sage (La minimaliste trop sage) | Bien épargner, c'est aussi savoir dépenser pour les siens. (9) |
| 5 | `cigale` | L'abonné à tout (L'abonnée à tout) | Vous avez profité de chaque saison ; votre épargne, elle, a moins grossi. (13) |
| 6 | `marin` | Le confiné serein (La confinée sereine) | Confiné, pas paniqué : vous avez gardé le cap. (8) |
| 7 | `neveu_matelas` | Le neveu de Tonton Matelas (La nièce de Tonton Matelas) | En 2022, l'inflation a mangé les euros de votre compte courant. (11) |
| 8 | `ecureuil` | Le fidèle du Livret A (La fidèle du Livret A) | Sûr et sans frais, comme Tata Livret ; mais en 2022, les prix allaient plus vite. (15) |
| 9 | `apprenti` | L'apprenti investisseur (L'apprentie investisseuse) | Un peu de tout, sans excès : rejouez pour tenter une autre voie. (12) |

- Titre 1 : le fait est vrai (loi du 4 août 2014, certitude A) et apprend quelque chose. Titre 8 : vrai sur 2022 (Livret A 1 à 2 % contre ≈ 5 % d'inflation, A) ; c'est la leçon du taux réel.
- Contrôle : aucun titre ne valorise « Renforcer », la cryptomonnaie ni la vente ; « golden boy » nomme l'erreur sans moquer.

### 3.11 Ce que le chapitre demande aux autres (rappel)

- **Banquier (K2)** : catalogue et ordre (Livret A, LDDS, LEP selon le profil, PEL, assurance-vie fonds en euros et UC, PEA, actions, ETF, PER pour Nathalie ?), offre FDJ, prime Covid et Ségur, donation, prix des 17 cartes et 18 options de projet, crédit de la Tesla, « cavalerie » en une phrase, `detail` de P2C.
- **Boursier (B3)** : CAC 40 et 4 actions 2019-2023, séance du 21/02 au 18/03/2020, « un an après », événement de 06/2022, série du bitcoin en euros pour Max (J1, J2, V16), dates du kiosque, FDJ (prix, cours).
- **UX (U2)** : rue 2020 (trottinettes, livreurs à vélo, rideaux de fer, applaudissements de 20 h), Max et sa Tesla, Mme Lopez âgée, smartphone fissuré (trace de C06), portraits de Karim, Léa, Franck.

---

## 4. Avis sur les idées 1, 2 et 3 du backlog : ce que je ferais d'abord

### 4.1 Mes recommandations (10 lignes)

1. **D'abord l'idée 1 (trophées), version « bonne pratique »** : plaisir fort, pédagogie forte, coût faible à moyen. 6 trophées communs à tous les chapitres, gagnés au moment où le geste est fait, posés sur une **étagère dans la maison** (trace P10) : *Le coussin* (3 mois de salaire disponibles fin de 1re année), *Le panier* (3 familles de placements détenues ensemble 12 mois), *Le régulier* (versements automatiques 24 mois de suite), *Le sang-froid* (≥ 20 % en risqué à la vitrine, pas de vente de plus de 50 % dans les 6 mois : « Ne rien faire » et « Renforcer » comptent ensemble), *L'œil du lynx* (arnaque refusée), *Le projet tenu* (un projet réalisé à la date).
2. Les « étapes » demandées par le joueur = jour J du projet 1, « un an après », jour J du projet 2, fin : à chacune, le **rang dans la rue** + les trophées gagnés depuis l'étape précédente. Aucun trophée ne récompense un gain de marché ni une date d'achat.
3. **Ensuite l'idée 3, mais le bureau de tabac seulement, pas le casino** (le casino coûte un bâtiment, une ambiance adulte et une probable classification PEGI plus stricte, à vérifier ; le tabac existe dans toute rue française de 1950 à 2023).
4. Garde-fous du tabac : vrais taux de retour aux joueurs (≈ 2/3 des mises au grattage, à vérifier par le banquier), argent réel de la partie, **un ticket par mois au plus**, aucune animation de jackpot, compteur toujours visible « Mises : 240 F · Gains : 90 F · Livret A : + 3 F », non recopié chez les voisins (comme les escargots), un titre ou un trophée inverse (« Le roi du grattage »).
5. La chute pédagogique vient en 2019 : la FDJ entre en Bourse, on peut être actionnaire du jeu plutôt que joueur (« la maison gagne toujours », chiffré).
6. Plaisir du tabac : moyen à fort (un geste libre entre les événements, ce que réclame le joueur) ; pédagogie : forte si le compteur est honnête ; coût : moyen (un bâtiment, une modale, une règle).
7. **En dernier l'idée 2 (niveaux d'explication)** : utile pour faire essayer le jeu aux débutants, mais peu de plaisir en plus et beaucoup d'écriture (≈ 16 textes de banquier par chapitre).
8. Version réduite à faire tout de suite si le joueur y tient : « Débutant / Normal » seulement (l'expert passe déjà vite les présentations), réglage dans le menu, sans questionnaire.
9. Ordre recommandé : trophées (avec la création de partie, lot 10) → tabac (avec le décor par décennie) → niveaux d'explication (avec le contenu du banquier de chaque chapitre).
10. À trancher par le joueur : le casino est-il indispensable, ou le bureau de tabac suffit-il pour « s'amuser entre les événements » ?

### 4.2 Points à confirmer par le client

- Profil célibataire (R-SEUL) plutôt que trois couples.
- Bernard sans héritage en 1988 ; Martine « La bonne mère de famille » ; « Le bon père de famille (sans famille) ».
- Sandrine Lefranc, petite-fille de M. Lefranc ; Mme Lopez dans les deux époques ; gag de Vierzon récurrent.
- Marques et faits cités en 2019 (FDJ, Tesla, GameStop, bitcoin, Disney et autres plateformes non citées) ; Covid traité avec légèreté sur le décor (papier toilette, pigeon) mais jamais sur la maladie : aucun décès, aucune blague sur les soignants.
- Trophées de bonne pratique : ils réintroduisent une forme d'« étoiles » écartée en 2026-10 ; je le propose parce que le **joueur** l'a demandé (17/11), et qu'ils récompensent des gestes, pas un score.
