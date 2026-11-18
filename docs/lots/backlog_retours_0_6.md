# Backlog issu des retours du joueur sur la 0.6.x (2026-11-17)

Source : docs/10_retours_joueur.md (section 2026-11-17, retours utilisateur). Statut : À PRÉVOIR, non planifié ; à arbitrer par le chef de projet avec le game designer, le banquier et l'UX avant tout lot. Le joueur n'a pas fixé d'ordre.

| # | Fonctionnalité | Lien avec l'existant | Premières remarques du coordinateur |
|---|---|---|---|
| 1 | Étapes avec récompenses sous forme de trophées (positionnement selon le choix fait, comme après le Lundi noir) | « Un an après » (3 barres), titres et collection (07-L/07-I), projets réalisés | Généraliser le mécanisme « étape + comparaison » : bilans d'étape (fin d'année, projets, krach). À cadrer avec le game designer (quelles étapes, quelles récompenses, lien avec les 9 titres). |
| 2 | Profils d'investisseur au début : débutant (explications détaillées, utilité dans le cas du joueur), intermédiaire (explications actuelles), expert (presque rien) | Idée « questionnaire de profil de risque » mise de côté le 2026-10-27 (CLAUDE.md) ; textes du banquier (docs/18, 21, 22, 25) | Trois niveaux de textes à écrire (banquier, game designer) ; un réglage « niveau d'explication » lu par l'interface. Contenu lourd, code léger. |
| 3 | Bâtiment « s'amuser » entre les événements : casino, bureau de tabac (tickets à gratter) | Rue large (bâtiments), argent du compte courant | Attention au garde-fou pédagogique (jamais de gain récompensé, ni de conseil) : les jeux de hasard ont une espérance négative, ce qui peut servir à enseigner (comparaison avec l'investissement). À cadrer avec le game designer et le banquier ; nouveaux bâtiments pour dev-ville. |
| 4 | Évolution du décor selon l'époque, tous les 10 ans | Rue pixel art ; plage 1950 → aujourd'hui pas encore jouable (démo 1984-1988) | Prévu pour quand toute la plage temporelle sera disponible. Prérequis : plage temporelle étendue ; style par décennie dans la bible graphique. |
| 5 | Création de partie : (a) mini questionnaire (âge, année de début, nombre d'enfants…) ou (b) choix de l'année + 3 profils types de l'époque | Aujourd'hui : personnage fixe (Gérard, 1984, Sylvie). Non prévu jusqu'ici | Dépend de la plage temporelle (plusieurs années de départ) et des profils par époque (banquier/boursier). |
| 6 | Pop-up de début : qui on est et quel est l'objectif (quel que soit le choix de début) | Écran titre, nouvelle partie | Petit, utile tout de suite : peut être fait sur la démo actuelle (Gérard, 1984, objectif). Candidat à un correctif rapide. |
## Compléments du 2026-11-18

| # | Complément | Remarques du coordinateur |
|---|---|---|
| 5 bis | Questionnaire de début (variante a) : demander aussi le **salaire actuel** de la personne et le convertir « à équivalence d'inflation » pour simuler un niveau de vie similaire à l'époque choisie | Deux conversions possibles : (1) par l'inflation (pouvoir d'achat sur les prix : `Inflation(époque)/Inflation(aujourd'hui)`) ; (2) par le rapport au salaire moyen ou au SMIC de l'époque (position dans l'échelle des revenus). Elles divergent fortement avant 1980 (les salaires ont augmenté plus vite que les prix). À arbitrer avec le banquier et le boursier (séries `salaires.json`, inflation). Donnée personnelle : ne jamais la stocker hors de l'appareil, ne pas l'envoyer (`privacy`), champ facultatif. Ancien franc avant 1960. |
| 3 bis | **Porte juridique avant tout jeu « pour passer le temps » (casino, tickets à gratter)** | Voir ci-dessous : à instruire AVANT conception et développement. |

### Porte juridique des jeux d'argent simulés (3 / 3 bis)
Question du joueur : la France (ou d'autres pays) peut-elle y voir une incitation aux jeux d'argent ? Le coordinateur n'est pas juriste : AUCUNE conclusion ici, seulement les points à faire instruire par un professionnel avant de lancer le lot.
- **Cadre français à vérifier** : monopole et agrément des jeux d'argent (code de la sécurité intérieure, ANJ, FDJ, casinos autorisés), publicité et promotion des jeux d'argent (encadrées), protection des mineurs, jeux « sociaux/simulés sans enjeu monétaire » (en principe hors champ s'il n'y a ni mise réelle ni gain monétaire réel, mais à confirmer), usage de marques (FDJ, Française des Jeux) et de produits réels (tickets à gratter).
- **Magasins d'applications** : règles de Google Play et de l'App Store sur les jeux de casino simulés (classification d'âge, absence d'argent réel, absence de lien avec des gains réels).
- **Autres pays** : si la diffusion dépasse la France (iOS/Android mondial).
- **Parades de conception à étudier si le projet continue** : aucune mise ni gain en argent réel ; pas de « monnaie » achetable ; classification d'âge adaptée ; mécanique à espérance négative affichée honnêtement (compteur net des mises et gains) ; jamais de récompense du jeu ; messages de prévention ; option pour désactiver ; pas de marque réelle ; ne pas montrer le jeu comme une façon de gagner de l'argent.
- Proposition : le bureau de tabac (un ticket par mois au plus, compteur net) reste préférable au casino pour le risque, mais la question juridique vaut pour les deux. Décision du joueur : à prendre après consultation.
