# Plan d'extension de la plage des années jouables

> Chef de projet, 2026-11-18. Demande du joueur (reprise.md, point 4) : « commencer à étendre la plage des années jouables pour envisager la prise en charge de 4 et 5 » du backlog (`backlog_retours_0_6.md` : 4 = décor qui évolue tous les 10 ans ; 5 = création de partie, mini-questionnaire ou année + 3 profils types).
> Statut : **plan d'ensemble, aucun lot lancé.** Les numéros de lots commencent à 09 (le n° 08 est pris par `lot/08-intro`, pop-up de début). Les plans détaillés (`lot_09.md`…) seront écrits quand les contenus experts du §4 seront arrivés.
> Sources lues : CLAUDE.md, docs/03 §1.3-1.4, §3-5, docs/02 §3, §4.2, §4.4, §4.5, §5, docs/01 (sommaire, §7), docs/09 §2.5, docs/16 (sommaire, §1.3), docs/32, `godot/data/*.json`, `godot/scripts/logique/*.gd`, `jeu/data/periode_p2.js` et `periode_p3.js`, `export_presets.cfg`.

---

## 0. En bref

1. **Architecture : deux couches.** Le **monde** (continu, partagé : séries, règles fiscales, salaires, marchés de 15 ans `P1/P2/P3` déjà prévus par docs/03 A7) et le **chapitre** (= la « période de jeu » : une tranche de 5 ans d'un marché, avec son personnage, ses profils, son banquier, ses cartes, ses projets, son voisin rival, sa « vitrine » historique type Lundi noir, ses titres et son **thème de décor par décennie**). Un chapitre = un dossier `godot/data/chapitres/<id>/` dont les fichiers **remplacent** ceux de `godot/data/` du même nom.
2. **Durée : 5 ans (60 mois) par défaut**, paramètre du chapitre (le moteur accepte 36 à 180). C'est la durée validée par le joueur sur la démo et la seule compatible avec la densité de contenu actuelle (8-10 cartes, 2 projets, un krach, ≈ 20 min).
3. **Années de départ : une par chapitre** (janvier de la 1re année), **un chapitre par décennie** à terme (8 chapitres de 1950 à 2023) : le décor change donc « tous les 10 ans » d'un chapitre à l'autre (backlog 4). Création de partie = option (b) du joueur (chapitre + 3 profils types) ; l'option (a) (questionnaire, année libre) vient en dernier.
4. **Premier chapitre à ouvrir après la migration de 1984-1988 : « 2019-2023 »** (Covid, retour de l'inflation, Livret A de 0,5 % à 3 %). Données de certitude A, marché P3 déjà écrit dans la V1 web, contraste maximal (euro, ETF, PEA, décor moderne) : c'est lui qui valide l'architecture. Repli moins cher : 1978-1983 (même marché P1, francs, même décor).
5. **Coût** : 4 lots pour jouer le 2e chapitre (09 socle, 10 création de partie, 11 produits modernes, 12 chapitre 2019-2023), puis ≈ 1 lot par chapitre supplémentaire, + 2 lots spéciaux (avant 1978 : séries 1949-1977 et ancien franc ; 1999-2001 : double affichage). Plage complète : 12 à 14 lots. Le goulot est le **contenu des experts**, pas le code.

---

## 1. Audit technique

### 1.1 Ce qui est déjà générique (aucune date en dur, fonctionne de 1976 à 2025)

| Élément | Où | Remarque |
|---|---|---|
| Calendrier (mois absolus, textes de dates) | `dates.gd` | Toute année. |
| Séries datées : Livret A (taux 1976-2025, plafonds 1977-2013), inflation 1976-2025, indice annuel / dividende / taux long 1977-2025, baguette 1975-2026 | `series.json`, `marche.gd` | **Rien avant 1976-1977** (voir §1.3). |
| Règles datées : impôts (taux unique, PEA 5 ans), courtage, agios, SICAV | `regles.json`, `Donnees.regle_datee` | Impôts et courtage depuis 1978, agios depuis 1970. |
| Salaires et dépenses par profil, interpolés, bascule F/€ | `salaires.json` | 1975-2025, 4 profils (jeune, technicien, cadre, héritier) ; prénoms prévus par période (P1/P2/P3). |
| Générateur de marché (pont brownien entre ancrages, β + volatilité propre, fonds) | `marche.gd` | Déterministe par graine de période (A12). |
| Disponibilité d'un produit à sa date (`dispo`), offre publique (`offre`) | `marche.gd`, `etat_partie.gd` | Règle « seuls les produits disponibles à la date jouée » déjà tenue. |
| Événements de marché et notifications de contexte | `periode_p1.json > evenements, contexte` | Format prêt pour P2/P3 (V1 : `jeu/data/periode_p2.js`, `periode_p3.js`). |
| Déclencheurs des présentations du banquier | `banque.json > declencheurs` | En **mois relatifs au début** de la partie (pas en dates) : réutilisables. |
| Moteurs des cartes, projets, cadence, versements, flux du mois, dividendes, témoins (Matelas, Livret, Indice), bilan, sauvegarde (format 3, migration douce) | `foyer.gd`, `projets.gd`, `cadence.gd`, `versements.gd`, `bilan.gd`, `sauvegarde.gd` | Règles génériques ; les **dates et montants sont dans les données** (créneaux, fenêtres, échéances), donc à réécrire par chapitre mais pas à recoder. |
| Affichage de la devise | `format.gd` | F avant 2002, € ensuite. |

### 1.2 Ce qui est lié à 1984-1988 (à déplacer en données ou à généraliser)

| # | Élément | Où | Nature | Traitement proposé |
|---|---|---|---|---|
| H1 | Fenêtre de jeu, personnage, départ (11 000 F), naissance 04/1985, moments, titre « de 1978 à aujourd'hui » | `demo.json`, `Donnees.config_demo`, `principal.gd` l. 29 et 125, scénarios de capture (5 appels) | Un seul scénario codé | `chapitre.json` par chapitre ; `Donnees.config_chapitre(id, profil, graine)` ; `config_demo` gardé comme alias de « 1984 ». |
| H2 | Identité de la période : `id_periode := "P1"` par défaut, `Donnees.periode(id)` à plat dans `data/` | `etat_partie.gd` l. 18, 129 ; `donnees.gd` | Une seule période portée | Le chapitre nomme son marché (`"marche": "P1"`) et sa tranche (`debut`, `fin`). |
| H3 | Fenêtre de marché fixe de 15 ans : `Marche.N = 181`, boucle `debut-1 … debut+15` sur `series.annuel`, `hist` de 180 cases, `m_fin` borné à 179 | `marche.gd` l. 7, 44 ; `etat_partie.gd` l. 36, 92, 141-143 | Suffit pour P1/P2/P3 (180 mois) ; **faux pour un marché d'avant 1978** (P0 de 13-14 ans) | Taille de fenêtre lue dans le fichier de marché (lot « avant 1978 » seulement). |
| H4 | Types de produits connus du moteur : `livret`, `pel`, `emprunt`, `av`, `sicav`, `action` ; listes en dur `["livret","pel","emprunt","av"]` | `etat_partie.gd` l. 175, 198 ; `marche.gd` l. 64, 81 | **Pas d'ETF, pas de PEA, pas de LDDS/LEP, pas de PER** | Lot 11 (produits modernes) : type `etf` (fonds à frais bas), enveloppe `pea`, livret réglementé générique. |
| H5 | Catalogue de la banque : 9 produits, ordre du carnet, présentations D01-D07, héritage D08 (Odette, 60 000 F, 04/1988), taux du PEL 1984-1986, taux AV 1983-1989, baisses du Livret A 1984-1986, plafond 07/1987, succession 275 000 F, versements en F (`min_F`, `montants_F`), textes « 1984 », « Caisse d'épargne ou la Poste », « 50 F » | `banque.json` (233 l.) | Contenu daté, devise dans les noms de champs | Un `banque.json` par chapitre ; montants avec champ `devise` (plus de suffixe `_F`). |
| H6 | Raccourcis codés dans le banquier : `notes_1984` (l. 406), année « 1985 » par défaut (l. 320), Saint-Gobain à 310 F (`nb_sg`, l. 311), journal « Héritage de tante Odette » (l. 581, 707), « M. Lefranc » dans `versements.gd` l. 102 | `banquier.gd`, `versements.gd` | Code | Généraliser (notes datées, prix d'offre lu dans `offre.prix`, noms lus dans les données). |
| H7 | Cartes du foyer : 10 créneaux datés 1984-1988, prix en F, « Sylvie » dans les phrases, C07 (+4 % en 01/1988) | `foyer.json` ; commentaires de `foyer.gd` | Données | `foyer.json` par chapitre ; conjoint en gabarit `{conjoint}`. |
| H8 | Projets : fenêtres et échéances 1984-1988, Super 5, Club Med | `projets.json` | Données | Par chapitre. |
| H9 | Jean-Mi : plan à crédit sur **Peugeot** 09/1986-10/1987, Porsche, décote, en **francs** ; `cours("peugeot")` en dur (l. 1801) ; module `Quartier` explicitement en F ; rang dès 10/1986 ; kiosque et passages datés | `temoins.json > jeanmi`, `rue.json`, `quartier.gd`, `etat_partie.gd` | Données + code (produit et devise) | Le rival nomme son produit et sa devise ; `Quartier` travaille dans la devise du chapitre. |
| H10 | Lundi noir et « un an après » : 7 jours d'octobre 1987, `mois_krach`, `mois_un_an_apres`, cadence `mois_gazette` | `krach.json`, `krach.gd`, `cadence.gd` l. 98, `etat_partie.gd` l. 1874-1951 | Mécanique générale, données datées | Renommer en **« vitrine »** du chapitre (séquence jour par jour + un an après), lue dans `vitrine.json` ; Covid 03/2020 en est le 2e cas. |
| H11 | Titres d'époque (golden boy, Club Med, écureuil de la Caisse d'épargne, marin par gros temps) ; `fenetre_vente_krach` 11/1987-04/1988 | `titres.json` | Données datées et thématiques | Par chapitre ; fenêtres relatives à la vitrine. |
| H12 | Record unique (meilleur écart face à Tata) et collection de 9 titres, sans notion de période | `records.gd`, `user://records.sav` v1 | Format | Records **par chapitre** (v2, migration : l'existant devient le record de « 1984 »). |
| H13 | Devise : pas d'**ancien franc** (avant 1960), pas de **double affichage** 1999-2001 ; `Quartier` formate « F » en dur | `format.gd`, `quartier.gd` l. 177 | Code | Lots spéciaux (§3.3). |
| H14 | IPC borné à 1976-2026 (`ipc_annee`), inflation et indice annuels absents avant 1976-1977 | `marche.gd` l. 178-185, `series.json` | Données manquantes | Port de docs/02 §4.2 (1949-1976) et docs/01 §4.1, §4.4 (lot « avant 1978 »). |
| H15 | Prénoms des naissances « années 1980 » | `evenements_vie.json` | Données | Par décennie (chapitre). |
| H16 | Stratégies de test et 1 334 vérifications calées sur 1984-1988 (dates « 1986-03 », Peugeot, krach) | `strategie_test.gd`, `tests/*` | Tests | Les tests actuels deviennent ceux du chapitre « 1984 » ; un test de chapitre par nouveau chapitre. |
| H17 | Interface et ville : 301 occurrences de 1984-1989 / Gérard / Sylvie / Lefranc / Odette / Jean-Mi / Gazette dans 50 fichiers (portraits, `personnages.gd`, `voisins.gd`, `edifices.gd`, `vehicules.gd` (R5, 205), `media.gd`, `ecran_titre.gd`, `date_volets.gd`, scénarios de capture) ; texte de la pop-up de début « JANVIER 1984 » (docs/32) | `scripts/ui`, `scripts/ville`, `scripts/pixel` | Décor et noms | Noms lus dans les données du chapitre ; décor par **thème** (§2.9). |
| H18 | Export : `include_filter="data/*.json, data/pixel/*/*.txt"` | `export_presets.cfg` | **Piège** : les sous-dossiers `data/chapitres/*/` ne seraient pas exportés | Ajouter `data/chapitres/*/*.json` (CA obligatoire du lot 09). |

Bilan : le moteur est **plus générique qu'il n'y paraît** (dates en données, déclencheurs relatifs, séries jusqu'en 2025) ; le lien à 1984-1988 tient surtout à **un seul jeu de fichiers de données**, à une dizaine de raccourcis de code (H2, H6, H9, H10, H12) et au décor. Les vrais trous : produits modernes (H4), données d'avant 1977 (H14), devises particulières (H13).

### 1.3 Données historiques disponibles, par décennie

| Décennie | Dans le jeu (`godot/data`) | Dans les documents | Certitude | Manque principal |
|---|---|---|---|---|
| 1950 | rien | docs/02 §4.2 (indice, dividende, inflation, taux long annuels 1949-1959), E01-E06 ; docs/01 (produits) | C (indice), B/C | Livret A 1950-1959 non sourcé (banquier : « ≈ 2,5 % », non vérifié) ; ancien franc ; pas de SICAV (1964) : Cousin Indice n'a pas de fonds |
| 1960 | rien | docs/02 §4.2, E07-E11 ; nouveau franc 01/1960 | C | Mensuel ; SICAV dès 1964, CEL 1965 |
| 1970 | inflation 1976-1979, indice 1977-1979 | docs/02 §4.2, §4.4 (krach 1973-1975 mensuel), E12-E16 ; PEL 1969 | B (A pour 1974-1975) | Séries 1965-1976 à porter ; marché « P0 » (1963-1977) à écrire |
| 1980 | **complet** (P1 1978-1992, démo 1984-1988) | docs/18 à 29 | A/B/C | — |
| 1990 | P1 jusqu'à 1992 ; séries 1990-1999 | V1 `periode_p2.js` (P2 1996-2010 : L'Oréal, Total, Alcatel, France Télécom 10/1997, ETF 2001, PEA) | B | Double affichage F/€ 1999-2001 ; port et revue de P2 |
| 2000 | séries | V1 `periode_p2.js`, E32-E39 | A/B | Port de P2 ; ETF, PEA |
| 2010 | séries | V1 `periode_p3.js` (P3 2011-2025 : ETF CAC 40, LVMH, TotalEnergies, BNP, Orange, PEA), E40-E44 | A | Port de P3 ; ETF, PEA |
| 2020 | séries jusqu'en 2025 | V1 `periode_p3.js`, E45-E50 ; Livret A 2020-2025 dans `series.json` | A | Port de P3 ; ETF, PEA ; données de séance du Covid pour la vitrine |

---

## 2. Architecture cible

### 2.1 Deux couches : le monde et le chapitre

- **Monde** (partagé par tous les chapitres, à la racine de `godot/data/`) : `series.json`, `regles.json`, `salaires.json`, `rythme.json`, `evenements_vie.json` (types génériques), `temoins.json` (Matelas, Livret, Indice), et les **marchés de 15 ans** `periode_p1.json`, `periode_p2.json`, `periode_p3.json` (puis `periode_p0*.json` avant 1978). Un marché est généré une fois, avec sa graine : **toutes les parties d'un même marché voient les mêmes cours** (A12), quel que soit le chapitre.
- **Chapitre** (= « période de jeu » de la demande) : une **tranche de 5 ans d'un marché** et tout le scénario qui va avec. Cela concilie docs/03 A7 (marchés de 15 ans) et la durée de partie validée sur la démo (5 ans).
- **Pourquoi des tranches d'un marché plutôt qu'un marché par chapitre** : la démo actuelle est déjà la tranche 1984-1988 du marché P1 (`m_depart` = 72) ; la garder telle quelle donne une **non-régression au bit près** (mêmes cours, même référence `integrale`), et deux chapitres d'un même marché (1978-1983 et 1984-1988) restent cohérents entre eux.

### 2.2 Dossiers et chargement

```
godot/data/
  series.json, regles.json, salaires.json, rythme.json, evenements_vie.json, temoins.json   (monde)
  periode_p1.json, periode_p3.json, ...                                                       (marchés de 15 ans)
  chapitres/
    index.json            liste ordonnée : id, nom, accroche, debut, fin, marche, theme, ouvert, profils
    1984/                 (migration de la démo)
      chapitre.json       ex-demo.json + marche, debut, fin, theme, banquier, journal, intro (pop-up), vitrine
      profils.json        3 profils types (Gérard + 2)
      banque.json  foyer.json  projets.json  rue.json  temoins.json  vitrine.json  titres.json  vie.json
    2019/
      ...
```

- Règle de chargement : `Donnees.charger(nom)` cherche `data/chapitres/<chapitre actif>/<nom>.json`, sinon `data/<nom>.json`. **Remplacement du fichier entier**, jamais de fusion profonde (simple, testable).
- Le chapitre actif est fixé par `EtatPartie._configurer` (`config["chapitre"]`, défaut « 1984 ») ; le cache de `Donnees` est indexé par chapitre.
- `include_filter` des exports étendu à `data/chapitres/*/*.json` (H18).

### 2.3 Durée de partie

- **60 mois par défaut** (`chapitre.json > debut, fin`), le moteur accepte toute tranche de 36 à 180 mois dans le marché.
- Motifs : (1) le joueur a validé 1984-1988 et sa durée (« le cadre de la démo est ok », 29/10) ; (2) les budgets de cadence (`rythme.json`) et la cible de ≈ 20 min sont calés sur 60 mois ; (3) une partie de 15 ans demanderait 3 fois plus de cartes, projets et vitrines par chapitre.
- docs/03 A10 (« durée fixe de 15 ans ») est donc à **réviser par le client** (§4.5). Un mode « carrière » qui enchaîne des chapitres (même personnage qui vieillit) est une idée pour plus tard, hors de ce plan.

### 2.4 Années de départ

- Une seule date de départ par chapitre (janvier de la 1re année) : tout le contenu scénarisé (créneaux, projets, rival, vitrine) est daté.
- **Un chapitre par décennie** à terme ; fenêtres candidates à faire valider par le boursier et le game designer (§4) :

| Décennie | Fenêtre candidate | Marché | Événement vitrine | Certitude des données | Besoin moteur particulier |
|---|---|---|---|---|---|
| 1950 | 1954-1958 | P00 (1950-1962) | Suez 1956 ou « opération 20 % » 1957 | C | ancien franc, pas de fonds, séries 1949-1959 |
| 1960 | 1958-1962 ou 1962-1966 | P0 (1963-1977) ou P00 | nouveau franc 01/1960 ; sommet de 1962 | C | idem + nouveau franc |
| 1970 | 1973-1977 | P0 | 1er choc pétrolier (−45 %) | B (A 1974-1975) | séries 1965-1976 |
| 1980 | **1984-1988** (existant) ; 1978-1983 possible | P1 | Lundi noir 1987 ; élection de 1981 | A/B/C | — |
| 1990 | 1996-2000 ou 1997-2001 | P2 | France Télécom 10/1997, bulle 2000 | B | double affichage F/€ 1999-2001, PEA, ETF 2001 |
| 2000 | 2006-2010 | P2 | Lehman 09/2008 | A/B | PEA, ETF |
| 2010 | 2011-2015 ou 2014-2018 | P3 | crise des dettes 08/2011 ; Brexit 06/2016 | A | PEA, ETF |
| 2020 | **2019-2023** | P3 | Covid 03/2020 | A | PEA, ETF |

- L'option (a) du joueur (questionnaire avec année libre) suppose un contenu **non daté** (cartes et projets génériques, vitrine optionnelle) : elle n'est envisagée qu'après 3 chapitres, quand on saura ce qui se réutilise (§3.3).

### 2.5 Profils types par chapitre

- `profils.json` du chapitre : 3 profils, chacun = prénom, âge, métier, colonne de salaire (`salaires.json`), situation (seul, couple marié / non marié / pacsé, enfants au départ), compte et livret de départ (avec devise), événements scriptés propres (naissance, héritage), conjoint (nom, pour les cartes et l'humeur), texte de la pop-up de début (docs/32 a prévu les gabarits).
- Le moteur du foyer suppose un conjoint (humeur de Sylvie). Deux voies, **au game designer de choisir** : tous les profils en couple (le plus simple), ou une variante « seul » des cartes (humeur d'un proche, ou pas d'humeur).
- Pour 1984-1988 : Gérard reste le profil 1 ; les profils 2 et 3 réutilisent les colonnes existantes (`cadre`, `heritier` ou `jeune`) ; chaque profil demande un **recalibrage** (projets 80 % / 60 %, cartes, rival, titres), mesuré par les tests.

### 2.6 Produits par date

- La règle reste « seuls les produits disponibles à la date jouée » (`dispo`, `offre`) ; chaque chapitre a son **catalogue de banquier** (`banque.json` : produits, ordre du carnet, présentations, déclencheurs relatifs, paramètres datés).
- Nouveaux types (lot 11) : `etf` (fonds indiciel, frais de gestion bas, sans droits d'entrée), enveloppe `pea` (titres éligibles, plafond daté, impôt `pea5` de `regles.json`, retrait avant 5 ans = clôture, imposé au taux du compte-titres), livret réglementé générique (`ldds`, `lep` si retenus). PER, unités de compte d'assurance-vie, cryptomonnaies : seulement si le banquier et le game designer les jugent nécessaires au chapitre 2019-2023.
- Montants des données : une valeur + une `devise` (« F », « € », plus tard « AF »), plus de suffixe `_F` dans les noms de champs ; conversion par `Format.vers_euros` comme aujourd'hui.

### 2.7 Séries de marché et événements historiques

- Le marché de 15 ans porte les ancrages de l'indice et des actions, les mois de crise, les événements de marché et les contextes (format de `periode_p1.json`, inchangé).
- Le chapitre choisit dans ce marché ses **achetables** (4 actions au plus, A14), son événement **vitrine** (`vitrine.json` : mois, séquence jour par jour, cours retenu, « un an après », produit du rival) et ses notifications de contexte propres.
- Les cours d'une même action dans deux marchés différents (L'Oréal en P1 et en P3) ne sont pas raccordés : acceptable car aucune partie ne traverse deux marchés.

### 2.8 Rival, titres, records

- Rival (Jean-Mi en 1984) : un par chapitre, dans `temoins.json > rival` du chapitre (nom, règle, plan en proportions, produit, devise). `Quartier` ne suppose plus « F » ni « peugeot ».
- Titres : `titres.json` par chapitre (9 titres, conditions sur des **fenêtres relatives à la vitrine**). Lien avec le backlog n° 1 (étapes et trophées) : à cadrer par le game designer en même temps.
- Records : `records.sav` **version 2**, sections par chapitre (`[record.1984]`, `[collection.1984]`) ; migration : le fichier v1 du joueur devient le chapitre « 1984 », sans perte. Écran titre : record du dernier chapitre joué ; collection par chapitre.

### 2.9 Thème de décor par décennie (backlog n° 4)

- `chapitre.json > theme` (« 1950 », … « 2020 ») lu par la ville **au démarrage de la partie** ; un chapitre de 5 ans reste dans une décennie : le décor change **entre** chapitres, ce qui répond à « tous les 10 ans ». Les variations à l'intérieur d'un chapitre restent datées comme aujourd'hui (« INDICE » → « CAC 40 » en 06/1988).
- Côté ville (dev-ville) : une table de thèmes (voitures, devantures et enseignes, banque, bâtiment média, passants et accessoires, horizon, mobilier urbain, petits signes d'époque), base docs/09 §2.5 à réécrire par l'UX dans docs/16. Le thème « 1980 » = la rue actuelle, à l'identique au pixel près.
- Palette : les 40 premières couleurs restent intouchables (interface) ; un thème peut **ajouter** des couleurs en fin de palette, jamais en modifier.

### 2.10 Sauvegarde

- Format 3 conservé, migration douce : `config_depart["chapitre"]` absent = « 1984 » ; `config_depart["profil_type"]` absent = profil 1. Le résumé de la sauvegarde (écran titre, emplacements de la sauvegarde manuelle) affiche le chapitre.
- Aucune dépendance dure avec la sauvegarde manuelle (`lot_sauvegarde.md`) : les deux ordres sont possibles. Si la sauvegarde manuelle passe après le lot 09, son résumé d'emplacement montre le chapitre dès le départ.

### 2.11 Interfaces à figer avant le lot 09 (proposition, détail dans `lot_09.md`)

```
# Donnees (logique)
static var chapitre := "1984"
static func regler_chapitre(id: String) -> void            # vide le cache si le chapitre change
static func chapitres() -> Array                            # data/chapitres/index.json : [{id, nom, accroche, debut, fin, theme, ouvert, profils}]
static func config_chapitre(id: String, profil := "", graine := -1) -> Dictionary   # remplace config_demo
static func config_demo(graine := -1) -> Dictionary         # = config_chapitre("1984", "", graine), gardé pour les scénarios
static func infos_chapitre() -> Dictionary                  # chapitre.json actif : nom, banquier.nom, journal, titre, intro, theme
# EtatPartie : config["chapitre"], config["profil_type"] ; e.chapitre (String)
# Ville (dev-ville, appelé par principal.gd via has_method) : ville.regler_theme(theme: String)
# Records v2 : Records.lire(chemin, chapitre) ; Records.enregistrer(bilan, id_partie, chemin, date) lit bilan["chapitre"]
```

### 2.12 Tests

- Les tests existants deviennent ceux du chapitre « 1984 » : **mêmes nombres au bit près** après le lot 09 (références de la stratégie `integrale` et des autres politiques de `StrategieTest` relevées sur `main` juste avant le lot : patrimoine final, frais, interruptions ; total des vérifications ≥ 1 334).
- Chaque nouveau chapitre apporte `test_chapitre_<id>.gd` : chargement des données, cohérence des dates (tout dans la tranche), produits disponibles à leur date, calibrage (projets, cartes, rival, titres) sur les politiques de `StrategieTest` rendues relatives au début du chapitre.
- Durée des tests : à surveiller (≈ 1 334 vérifications aujourd'hui) ; option `tests.ps1 -Chapitre <id>` si elle dépasse quelques minutes.

---

## 3. Séquence et découpage en lots

### 3.1 Ordre des chapitres

1. **« 1984 »** (1984-1988) : migration de la démo, sans aucun changement visible (lot 09).
2. **« 2019 »** (2019-2023) : **recommandé** comme 2e chapitre, pour valider l'architecture.
   - Données : certitude A (CAC 40, Livret A, inflation), marché P3 déjà écrit dans la V1 (`jeu/data/periode_p3.js` : 4 actions, ETF, 7 événements, contextes) ; seules les données de séance du Covid (vitrine) manquent.
   - Euro seul : aucune conversion, aucun double affichage.
   - Il oblige à faire ce dont tous les chapitres d'après 1992 auront besoin (ETF, PEA) : rien de spécifique.
   - Contraste de décor maximal (voitures, téléphones, banque, média) : il valide le thème par décennie (backlog n° 4).
   - Vitrine qui ressemble au Lundi noir (krach éclair, rebond en un an : « un an après » en 03/2021) : la mécanique se généralise sans nouvelle règle.
   - Récent et reconnaissable pour les testeurs du joueur (Covid, inflation de 2022, Livret A à 3 % en 2023).
   - Ouverture à 2019 plutôt qu'à 2020 : le Covid tombe au 15e mois (après la prise en main) au lieu du 3e ; flat tax déjà en vigueur ; fin en décembre 2023 avec un Livret A à 3 % (belle leçon « taux réel »).
   - **Repli** si le joueur veut un 2e chapitre plus tôt et moins cher : **1978-1983** (même marché P1, mêmes produits, francs, décor 1980 inchangé, Mitterrand 1981 et taux à 16 %). Il valide le découpage des données mais ni le décor ni les produits modernes.
3. Ensuite, par disponibilité des données : 2006-2010 (P2, Lehman), 2011-2015 (P3), 1996-2000 (P2 + double affichage), 1973-1977 (séries à porter), 1958-1962 puis 1954-1958 (données C, ancien franc, à signaler « reconstitué » au joueur comme le propose docs/02 §5).

### 3.2 Lots pour ouvrir le 2e chapitre

| Lot | Contenu | Développeurs | Parallélisme | Prérequis |
|---|---|---|---|---|
| **09 « Socle des chapitres »** | 09-L : `data/chapitres/1984/` (déplacement de demo, banque, foyer, projets, rue, krach → vitrine, titres, jeanmi), `Donnees` (chargement par chapitre), `config_chapitre`, H2, H6, H9, H10 généralisés, records v2 + migration, sauvegarde (champ chapitre), `include_filter`, tests inchangés au bit près. 09-V : table des thèmes (`ThemeDecor`), thème « 1980 » = rue actuelle au pixel près, `ville.regler_theme`, option de capture `--theme`. 09-I (petit, après 09-L) : `principal.gd` passe par `config_chapitre` et `regler_theme`, noms lus dans `infos_chapitre()` (banquier, journal, titre). | dev-logique, dev-ville, dev-interface | 09-L ∥ 09-V ; 09-I après la fusion de 09-L | Aucun contenu expert. Après le rééquilibrage (mêmes fichiers de données). |
| **10 « Création de partie »** | 10-I : écran de choix (chapitres en cartes, verrouillés « bientôt » sauf « 1984 » ; 3 profils ; récapitulatif), pop-up de début alimentée par le profil ; écran titre (record par chapitre). 10-L : `profils.json` de « 1984 » (Gérard + 2), recalibrage des 2 nouveaux profils. | dev-interface, dev-logique | 10-L ∥ 10-I (contrat : `chapitres()`, `profils`) | Maquettes UX (U1) ; profils du game designer (G2). Sortie possible **0.7 « trois profils »**. |
| **11 « Produits modernes »** | 11-L : types `etf`, enveloppe `pea`, livret réglementé générique, devise dans les données, versements en €, impôts PFU / prélèvements sociaux datés ; tests sur un chapitre d'essai. | dev-logique | Séquentiel avec 10-L (même développeur), ou dev-logique-bis si les fichiers sont disjoints (précédent du lot 05) | Règles du banquier (K2). |
| **12 « Chapitre 2019-2023 »** | 12-L : `periode_p3.json` (port revu de la V1), `data/chapitres/2019/` complet, vitrine Covid, calibrage. 12-V : thème « 2020 » (voitures, devantures, banque, média, passants). 12-I : portrait du banquier, nom du média, chapitre « 2019 » déverrouillé. | les trois | 12-L ∥ 12-V ; 12-I en dernier (recette de la fusion complète) | Contenus K2, B2, G3, U2. Sortie **0.8 « deux époques »** (série de captures complète). |

### 3.3 Lots suivants (estimation)

| Lot | Contenu | Coût |
|---|---|---|
| Un chapitre de plus dans P1, P2 ou P3 | données du chapitre + thème de décennie + calibrage | ≈ 1 lot chacun (contenu expert ≈ docs/18 à 29 en volume) |
| « Avant 1978 » | séries 1949-1977 (indice, dividende, taux long, inflation, Livret A, baguette, salaires), fenêtre de marché variable (H3), marchés P0 / P00, ancien franc (H13), témoin Indice sans fonds avant 1964 | 1 à 1,5 lot, avant le 1er chapitre d'avant 1978 |
| « Euro » | double affichage 1999-2001, modale de l'euro (01/2002) | 0,5 à 1 lot, avec le chapitre 1990 |
| Questionnaire (option a) | âge, enfants, année libre : contenu générique non daté | 1 à 2 lots, après au moins 3 chapitres |

**Total pour les 8 décennies : 12 à 14 lots.** Le goulot est le contenu des experts (catalogue du banquier, cartes, projets, rival, vitrine, titres pour chaque chapitre) et les recettes, pas le moteur.

---

## 4. Contenus experts nécessaires et demandes à envoyer

Toutes les demandes ci-dessous sont **à lancer maintenant** (elles ne bloquent pas le lot 09, qui n'a besoin d'aucun contenu) sauf mention. Réponses attendues dans de nouveaux documents numérotés de `docs/` (33 et suivants).

### 4.1 Boursier

- **B1 (maintenant) — État des lieux par décennie.** Pour chaque décennie de 1950 à 2020 : séries disponibles (indice annuel et mensuel, dividende, taux long, inflation) avec certitude, ce qui est déjà dans `godot/data/series.json` et `periode_p1.json`, ce qui est dans docs/02 et `jeu/data/periode_p2.js` / `periode_p3.js`, ce qui manque. Liste des valeurs 1949-1976 prêtes à recopier dans `series.json` (format de `annuel` et `inflation`).
- **B2 (maintenant) — Fenêtres de chapitres.** Valider ou corriger le tableau du §2.4 : une fenêtre de 5 ans par décennie, son marché de 15 ans, son événement vitrine (mois, ampleur, délai de retour au niveau d'avant : la « leçon un an après » doit être vraie), 4 actions au plus et un fonds (SICAV ou ETF) avec leurs ancrages. Dire pour chaque fenêtre si la fin de partie laisse une leçon juste (pas de fin au fond d'un krach sans explication).
- **B3 (maintenant) — Chapitre 2019-2023, données de marché.** Revue de `jeu/data/periode_p3.js` pour 2018-12 → 2023-12 (ancrages mensuels du CAC 40 en 2019-2023, ancrages des 4 actions en clôture de fin de mois, dividendes nuls de 2020 pour les banques), ETF CAC 40 et, si utile à la leçon de diversification, un ETF monde ; événements de marché du chapitre (Covid 03/2020, Ukraine 02/2022, inflation 06/2022, banques 03/2023…) au présent et sans divulgâcheur ; séquence jour par jour du Covid pour la vitrine (≈ 7 séances, 9 à 18 mars 2020, certitude par point), cours retenu pour les ordres du mois, carte « un an après » (03/2021) ; nom et support du média en 2019 (journal, chaîne d'info, site).
- **B4 (plus tard, avec le chapitre)** — Données de séance des autres vitrines.

### 4.2 Banquier

- **K1 (maintenant) — État des lieux par décennie.** Produits accessibles à un particulier (date d'apparition, conditions), taux réglementés et plafonds (Livret A 1950-1976 en particulier, CEL, PEL, LEP, LDDS), fiscalité simplifiée (table de `regles.json` à prolonger avant 1978), monnaie (ancien franc, nouveau franc, double affichage), frais de courtage et de gestion ; pour chaque ligne : source et certitude ; ce qui est déjà dans `godot/data/` et ce qui manque.
- **K2 (maintenant) — Catalogue du banquier 2019-2023.** Liste de 8 à 10 produits dans l'ordre de présentation (Livret A, LDDS, LEP ?, PEL à son taux d'ouverture 2019-2023, assurance-vie fonds euros et unités de compte, PEA, ETF, actions au compte-titres, PER ?, autre ?), avec : paramètres datés (taux PEL par date d'ouverture, taux servis des fonds euros 2018-2023, prélèvements sociaux, PFU, plafonds PEA et livrets, règles de retrait du PEA, frais de courtage d'un courtier en ligne et d'une banque de réseau, frais d'entrée et de gestion d'assurance-vie), déclencheurs relatifs au début de partie, textes des présentations (≤ 60 mots, vouvoiement, jamais de conseil), messages datés (Livret A 0,5 → 1 → 2 → 3 %), et la **forme du banquier en 2019** (conseiller en agence, application ?). Héritage ou transmission équivalents à tante Odette (abattement assurance-vie de 152 500 €, couple pacsé ou non : ce qu'hérite le conjoint). Salaires et dépenses des profils types 2019-2023 (vérifier les lignes 2020 et 2025 de `salaires.json`).
- **K3 (avec le lot 10)** — Relecture des textes de présentation pour les 2 nouveaux profils de 1984-1988 (cadre, héritier ou jeune) : ce qui change dans les phrases (« Sylvie, qui n'est pas votre épouse », succession).

### 4.3 Game designer

- **G1 (maintenant) — Structure d'un chapitre.** Ce qui est commun à tous les chapitres (gabarit) et ce qui se réécrit : nombre de cartes, de projets, rival, vitrine, titres ; cartes réutilisables d'une époque à l'autre avec variantes de prix et de mots ; durée (confirmer 5 ans) ; lien avec le backlog n° 1 (étapes et trophées) et n° 2 (niveau d'explication) ; records et collection par chapitre ou communs.
- **G2 (maintenant) — Profils types de 1984-1988.** Deux profils en plus de Gérard (prénom, âge, métier, situation, départ, événements scriptés, objectif, texte de la pop-up de début selon docs/32), et la règle du foyer pour un profil sans conjoint s'il y en a un.
- **G3 (maintenant, pour le lot 12) — Chapitre 2019-2023.** 3 profils types de l'époque, cartes du foyer (8-10), 2 projets, rival (quelle folie de 2019-2023 : crypto, « meme stocks », trading à effet de levier ? avec les garde-fous de docs/03 : jamais de récompense à la spéculation), 9 titres d'époque, textes de la vitrine et de « un an après », accroche du chapitre sans divulgâcheur (A5, A8).
- **G4 (plus tard)** — Option (a) : questionnaire et contenu non daté.

### 4.4 Designer UX

- **U1 (maintenant) — Écran de création de partie.** Choix du chapitre (frise des décennies ? cartes ? chapitres verrouillés visibles), choix parmi 3 profils, récapitulatif, enchaînement avec la pop-up de début ; PC 1920 × 1080, téléphones 1440 × 648 et 1280 × 720 ; écran titre avec record par chapitre.
- **U2 (maintenant) — Thèmes de décor par décennie.** Réécrire docs/09 §2.5 dans docs/16 pour la grille pixel actuelle : pour chaque décennie, les variantes (voitures, devantures, enseignes, banque, bâtiment média, passants, accessoires, horizon) ; **thème « 2020 » détaillé en premier** (dessins dans le code, dev-ville, palette : ajouts en fin seulement) ; nom et allure du média selon l'époque.
- **U3 (plus tard)** — Questionnaire (option a).

### 4.5 Client

- **C1 (maintenant) — Révision de docs/03.** A7 et A10 (périodes de 15 ans, durée fixe de 15 ans) et A9 (Trente Glorieuses hors V1) contredisent la demande du joueur ; proposition : marchés de 15 ans gardés, **parties de 5 ans** en chapitres, 1950-1977 admis avec la mention « données reconstituées ». Valider l'ordre des chapitres (§3.1) et la sortie 0.8 « deux époques ».

### 4.6 Questions au joueur (par le coordinateur)

- Q1 : durée d'une partie, 5 ans par chapitre (recommandé) ?
- Q2 : 2e chapitre 2019-2023 (recommandé) ou 1978-1983 (moins cher, même décor) ?
- Q3 : place du lot 09 par rapport à la sauvegarde manuelle (les deux ordres sont possibles ; défaut : rééquilibrage, puis lot 09, puis sauvegarde manuelle).

---

## 5. Risques et parades

| Risque | Gravité | Parade |
|---|---|---|
| Régression de la démo 1984-1988 pendant la migration (données déplacées, raccourcis généralisés) | forte | Lot 09 sans changement visible ; CA bloquant : mêmes nombres au bit près (références des politiques de `StrategieTest` relevées avant le lot, vérifications ≥ 1 334), captures du thème « 1980 » identiques au pixel. |
| Exe ou APK sans les données des chapitres (`include_filter`) | forte | CA du lot 09 : exe lancé avec `--main-pack`, chapitre « 1984 » chargé depuis `data/chapitres/`. |
| Records et sauvegarde du joueur perdus | forte | Migration v1 → v2 des records et champ `chapitre` par défaut ; tests sur une copie des fichiers de la 0.6.1. |
| Volume de contenu par chapitre (≈ docs/18 à 29) | forte | Gabarit de chapitre (G1), cartes réutilisables, un chapitre à la fois ; pas de chapitre ouvert sans contenu complet. |
| Calibrages à refaire par profil et par chapitre (projets, rival, titres) | moyenne | Mesures sur les politiques de test avant de figer les CA (leçon du lot 03) ; `test_titres_mesures` par chapitre. |
| Produits modernes mal expliqués ou anachroniques (PEA, PER, cryptomonnaies) | moyenne | Textes du banquier relus ; garde-fous de docs/03 et du backlog n° 3 ; aucun conseil. |
| Données reconstituées (avant 1978) présentées comme exactes | moyenne | Mention « reconstitué » à l'écran de choix ; certitude dans les données. |
| Coût du décor (8 thèmes dessinés en code) | moyenne | Thème = variantes sur la rue existante (pas une nouvelle rue) ; ajouts de palette en fin ; un thème par chapitre ouvert. |
| Durée des tests qui grossit avec les chapitres | faible | Option `-Chapitre` de `tests.ps1` ; série complète avant les exports seulement (règle du joueur du 17/11). |
| Conflit avec le rééquilibrage ou la sauvegarde manuelle (mêmes fichiers logiques) | moyenne | Jamais en parallèle sur `etat_partie.gd` et `data/*.json` : rééquilibrage d'abord ; sauvegarde manuelle avant ou après le lot 09, jamais pendant. |

**Coût estimé** : 4 lots jusqu'au 2e chapitre jouable (09 ≈ taille du lot 03 côté logique ; 10 et 11 moyens ; 12 grand), puis ≈ 1 lot par chapitre ; 12 à 14 lots pour les 8 décennies, rythmés par l'arrivée des contenus experts.

---

## 6. Carte de propriété prévisionnelle du lot 09 (à confirmer dans `lot_09.md`)

| Fichiers | Propriétaire |
|---|---|
| `data/*.json`, `data/chapitres/**`, `scripts/logique/*.gd`, `scripts/partie.gd`, `tests/test_*` logiques, `outils/tests.ps1`, `export_presets.cfg` (filtres) | dev-logique (09-L) |
| `scripts/ville/*.gd`, `scripts/pixel/*.gd` (thèmes), `scripts/outils/scenarios/ville.gd`, `outils/capture_ville.ps1`, `tests/test_rue.gd`, `tests/test_pixel.gd` | dev-ville (09-V) |
| `scripts/principal.gd`, `scripts/ui/*.gd`, autres familles de scénarios, `test_interface`, `test_partie`, `test_ecran` | dev-interface (09-I, après fusion de 09-L) |
