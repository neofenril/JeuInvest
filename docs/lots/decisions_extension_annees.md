# Décisions du joueur sur l'extension des années (2026-11-18)

Source verbatim : `docs/10_retours_joueur.md`, section « 2026-11-18 (décisions du joueur sur le plan d'extension des années) ». Ces décisions **priment** sur les recommandations de `plan_extension_annees.md` et sur `docs/03` (A7, A9, A10) en cas de contradiction.

## 1. Structure des périodes
- **Chapitres de 5 ans**, greffés **autour de la période existante** : le premier nouveau chapitre est **1989-1993** (suite directe de la démo 1984-1988) ; on continue ensuite de proche en proche (1994-1998, etc.). Le plan recommandait 2019-2023 en premier : **écarté**.
- **Début de la plage jouable : 1977** (première année implémentée). 1950-1976 : à reconsidérer **à la toute fin**, éventuellement une période « très light » de données simplifiées.
- **Fin de la plage : dernière année implémentée.** Aujourd'hui 1988 ; après le prochain lot 1993 ; à terme l'année en cours (2026, voire 2027).
- **Profils par tranche de 5 ans** (comme proposé par le game designer, docs/35), y compris un **profil célibataire** (à lancer ; règle R-SEUL de docs/35).
- **Artwork (décor) par tranche de 10 ans**, pas de 5.
- **Création de partie** : on garde le choix par chapitre **et** on ajoute la **saisie d'une année précise** ; l'année saisie reprend tous les éléments du chapitre où elle s'insère.
- **Fin de partie** : à la **mort du personnage** (événement de mort à concevoir) ou à la dernière année implémentée.

## 2. Produits et contenus
- **PEA et ETF : confirmés** (lot 11 du plan). **PER : ajouté comme notion** (jouable ou notion pédagogique : à trancher avec le banquier/game designer au lot concerné).
- **Deux canaux de frais** : banque de réseau (plus cher, avec conseiller) et courtage en ligne (moins cher), pour montrer surtout à l'ère internet que le réseau n'est pas indispensable.
- **Nom de la conseillère** : laissé au coordinateur (proposition du banquier : Mme Delmas, vouvoiement).
- **Salaires** : corriger la ligne 2025 de `salaires.json` ; ajouter une ligne 2023 avec **2 points d'épargne en moins** (malus inflation 2022-2023, docs/34 §K2.6) ; valeurs exactes laissées au banquier/chef de projet.
- **Boursier** : garder les choix par défaut de docs/33.
- **Point 4 du retour du banquier** : le joueur ne l'a pas compris → à réexpliquer (voir réponse du coordinateur).

## 3. Fonctionnalités de jeu
- **Trophées des bonnes pratiques** : gardés, **sous forme d'étoiles**.
- **Bureau de tabac** : gardé, à commencer. **Casino : repoussé** (porte juridique, docs/lots/backlog_retours_0_6.md « 3 bis »).
- **Niveaux d'explication** (débutant / normal / professionnel) : plus tard.

## 4. Ordre des travaux (décision du joueur)
1. **Rééquilibrage** (titres rares/trop fréquents, dosage Jean-Mi : voir docs/lots/reprise.md).
2. **Socle des chapitres (lot 09)**.
3. Puis seulement : **période 1989-1993** et **sauvegarde manuelle** (après le socle).
4. Tabac, célibataire, étoiles/trophées, ETF/PEA/PER, canaux de frais : à planifier par le chef de projet dans cet ordre général, selon les dépendances.

## 5. Réponses du joueur aux décisions D-J1 à D-J7 (2026-11-18, verbatim dans docs/10)
- **D-J1** : une partie commencée en 1984 **continue jusqu'en 1993** (marché continu d'un chapitre à l'autre). **Un seul bilan final** suffit (à la fin de la dernière période développée) ; un bilan d'étape par chapitre est facultatif.
- **D-J2** : **un titre par chapitre traversé**. Records : **double record** envisagé, par chapitre de départ **et** sur la période totale ; garder les records par chapitre pour le moment.
- **D-J3** : décor par **tranche de 2 chapitres** (1984-1993 : un seul décor).
- **D-J4** : 1977-1983 = **un chapitre unique de 7 ans**.
- **D-J5** : Gérard gardé, **vieillit** au fil des chapitres.
- **D-J6** : tabac **et** casino sont **suspendus à une confirmation juridique** que le joueur ira chercher ; ne rien concevoir ni développer tant qu'il n'a pas confirmé (le lot « tabac » est donc en attente).
- **D-J7** : mort **liée à l'âge, traitée sobrement**, avec une **note informative** adaptée à la situation : assurance-vie présente ou non, enfants ou conjoint ; expliquer ce qui aurait été transmis et comment si le personnage avait eu (ou non) une assurance-vie.
- **Q-R1** : le dosage actuel de Jean-Mi est bon, **ne pas le modifier**.
- Experts (boursier, banquier, game designer, UX) : à lancer **en parallèle des développements** pour la période 1989-1993.
- **Mariage du personnage** (réponse au point 1 du game designer, docs/39 §15) : il **n'est pas imposé en 06/1990** ; il **dépend de l'âge du personnage, selon le profil saisi** (règle à définir par le game designer : tranches d'âge, situation de départ marié / couple non marié / célibataire R-SEUL). Gérard (31 ans en 1989) reste le cas de référence à recaler.

- **Lot 10 : un seul profil de départ** (le profil n'est pas nommé par le joueur ; proposition du game designer retenue par défaut : Christine, docs/39). **Carte de passage de chapitre : version A** (docs/40, sans bilan d'étape). **PEP : le game designer tranche** (fiche jouable ou simple message). Reste ouvert : Jean-Mi et le studio à crédit 1990-1993 (docs/39 §15).

- **Jean-Mi, studio, privatisation, immobilier (2026-11-18)** : pas de studio à crédit pour Jean-Mi tant que le joueur ne peut pas lui-même investir dans l'immobilier ; **pas de leçon sur la privatisation** (trop poussé pour un joueur débutant ou intermédiaire : rester simple) ; **garder la notion d'immobilier comme diversification** (ne pas tout mettre dans le même panier : bourse, obligations/OAT, court / moyen / long terme, immobilier) et étudier les **SCPI** (date de naissance en France à établir par le banquier). Mission confiée au banquier (docs/41) puis au game designer.

- **Export** : pas d'export 0.6.3 ; prochain export (0.7) **à la fin du lot 10** (chapitre 1989-1993), avec la série de captures complète.

- **Investissements alternatifs (idée du joueur, 2026-11-18)** : à l'implémentation des années 2000, prévoir des placements alternatifs (cartes de collection, montres de luxe, etc.). À instruire par le banquier et le boursier avant ce chapitre : dates réelles d'apparition de chaque marché (le boom des cartes de collection et des montres de luxe est surtout 2015-2022 ; avant : vin, art, timbres, or), accessibilité pour un épargnant français, fiscalité, liquidité et risque ; noms et marques fictifs (même précaution juridique que pour le casino, docs/lots/backlog_retours_0_6.md « 3 bis »).

- **Carrière simplifiée (idée du joueur, 2026-11-18)** : choix simples de carrière (opportunité de changer de travail, payer moins mais avoir plus de temps, ou l'inverse). Exploration confiée au client, au game designer, à l'UX et au chef de projet (docs/42 à 44, docs/lots/etude_carriere.md). Rien n'est décidé ni développé.

- **Événements de vie aléatoires et rejouabilité (2026-11-18)** : tous les événements de VIE (accident de voiture, naissance, divorce, décès dans la famille, voyages, annulations de réservation, héritage, etc.) doivent être **aléatoires** dans leur date et leur survenue, jamais à date fixe d'une partie à l'autre, pour que peu importe l'époque ils puissent se produire et pour la rejouabilité (profils, niveaux). Seuls les événements de MARCHÉ restent à leurs **dates historiques réelles**. Étude confiée au game designer (docs/45) puis au chef de projet (impact sur 1984-1988 : naissance scriptée 04/1985, héritage 04/1988, test de référence).

- **Carrière (2026-11-18)** : **pilote de 2 cartes accepté dans le lot 10** (options de métier / promotion : K4 et K5 de docs/42) ; **temps libre = humeur seulement** (pas de nouvelle jauge), mais **l'humeur du conjoint influe légèrement sur la probabilité de divorce** (par exemple un travail à horaires plus lourds qui dégrade l'humeur) : à concevoir par le game designer sans faire de l'épargne une faute (docs/45 §divorce) ; **retraite et PER repoussés** à la fin de carrière, quand la plage de jeu sera plus longue. Autres réponses aux questions de docs/lots/etude_carriere.md : non données (recommandations du chef de projet par défaut).

- **Événements de vie (2026-11-18, réponses aux 4 décisions de docs/45)** : **divorce accepté** (sobre, au plus une fois par partie, lié faiblement à l'humeur via les choix de carrière) ; **mariage de Gérard : 70 % de survenue sur le chapitre** (proposition du game designer, validée ; le joueur a ajouté « donc garantie » : lecture ambiguë, à reconfirmer avant le lot 10) ; **jumeaux : 1 naissance sur 6** au lieu de 1 sur 4 ; **décès d'un parent admis**, avec une visée pédagogique : sensibiliser à la gestion du patrimoine des parents de leur vivant et montrer les difficultés après leur décès (banquier : donation, assurance-vie, succession, indivision).
- **Carrière** : les 8 réponses par défaut du chef de projet (docs/lots/etude_carriere.md) sont **validées**.

- **(2026-11-18, suite)** Mariage de Gérard : **70 % de survenue** confirmé. Profil de départ du lot 10 : **Christine** confirmée. **Tabac et casino : le joueur a vérifié qu'ils ne semblent pas problématiques puisque l'application ne demande aucun argent** ; vérification du coordinateur (non juridique) : Apple classe les jeux de casino simulés « fréquents ou intenses » en 17+ dans le monde, la politique de Google sur le jeu simulé est à relire au moment de publier, aucun texte officiel ANJ/Légifrance trouvé : lancer le tabac (mécanique légère, sans marque réelle) ; le casino reste à classer 17+ et à valider à la publication. **Produits antérieurs à leur chapitre** : un produit est défini une fois dans un **catalogue du monde avec sa date de naissance** (ex. SCPI 1970, PEP 1990, PEA 07/1992) ; **chaque chapitre choisit s'il le présente et quand**, et un chapitre antérieur développé plus tard (ou 1984-1988 révisé) doit pouvoir présenter un produit déjà existant (ex. SCPI dès 1984) sans réécriture : les présentations doivent pouvoir être déplacées d'un chapitre à l'autre. Révisions de contenu lancées (banquier, game designer, chef de projet).

- **Joueuse (2026-11-18)** : le questionnaire de début de partie doit permettre d'être une **femme**. Dans ce cas, le conjoint change de genre (le rôle de Sylvie devient « Gérard » : le personnage du joueur est féminin, son conjoint masculin). Conséquences à prévoir : textes à accords de genre et gabarits {conjoint} / {prenom} / accords (« monsieur / madame », « Gérard le technicien »), portraits (joueuse et conjoint), prénoms par époque, humeur du conjoint, naissances et mariage selon l'âge, bilan et titres. À traiter avec la création de partie (lot 12) ; **dès le lot 10, ne pas écrire de nouveaux textes avec un prénom ou un genre en dur** (gabarits dans les données). Question ouverte : conjoint de même sexe (non demandé).
