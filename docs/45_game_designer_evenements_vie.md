# 45 : Game designer, événements de vie aléatoires et rejouabilité

> 2026-11-18. Réponse au retour du joueur « événements de vie aléatoires et rejouabilité » (`docs/10`, 18/11) et à `docs/lots/decisions_extension_annees.md` (dernier point). Prime sur docs/15, docs/35 et docs/39 pour les **dates** des événements de vie (naissance 04/1985, héritage 04/1988, panne 11/1987, mariage 06/1990, oncle Raymond 03/1991 deviennent des **fenêtres**).
> Montants en **M** = mois de salaire du profil à la date (valable à toute époque). Probabilités et montants : certitude C, à valider par le banquier (assurances, succession, chômage). Règles d'écriture inchangées : vouvoiement, ≤ 30 mots, aucun conseil, aucun « vous auriez dû ».

---

## 0. En bref

1. **Tout événement de vie a une date tirée** par la graine de la partie ; seuls le **marché** et les **faits d'époque** (kiosque, lois, produits) gardent leur date réelle.
2. Les événements qui portent une leçon (naissance, héritage, coup dur pendant le krach, mariage) deviennent **ancrés** : leur **survenue** est garantie (ou très probable) mais leur **date** est tirée dans une **fenêtre** de 6 à 24 mois, cohérente avec l'âge et la situation.
3. Les autres sont tirés dans une **pioche par tranches** (une tranche = 12 mois) avec un **budget de malchance** par chapitre : jamais une partie vide, jamais une série noire.
4. **Équité** : R-MIROIR s'applique à tous les événements de vie (Tata Livret, Tonton Matelas et Jean-Mi vivent la même vie) ; l'écart face à Tata vient donc des choix. Un garde-fou évite le seul vrai effet de chance : un gros héritage juste avant une baisse de marché.
5. **Non-régression** : un **calendrier de référence** (les dates actuelles) reste disponible pour les tests et les captures ; les vraies parties tirent leurs dates.

| Proposition | Plaisir | Pédagogie | Coût |
|---|---|---|---|
| Fenêtres pour naissance, héritage, coup dur du krach (lot 10) | fort (plus d'anticipation, rejouabilité) | neutre (mêmes leçons) | faible à moyen (tirage au départ, tests) |
| Pioche par tranches + budget de malchance | moyen à fort (régularité des surprises) | moyen | faible (post-traitement du calendrier actuel) |
| 6 nouveaux types simples (JSON seul) | moyen (variété) | fort (assurances, franchise, précaution) | faible |
| Famille élargie (aînés, décès, héritages variables) | fort (histoires différentes) | fort (succession, AV, ligne directe) | moyen à fort (banquier : chiffres par lien) |
| Chômage, arrêt maladie, voyage annulé (conditionnels) | moyen | fort (précaution, assurance annulation) | moyen (effets temporaires sur le salaire) |
| Séparation (divorce) | fort en sens, faible en plaisir | fort (régime, contrats au nom de qui) | fort (bascule vers R-SEUL, partage) |

---

## 1. Inventaire : ce qui est aléatoire, ce qui est scripté (main, 18/11)

| Élément | Aujourd'hui | Où |
|---|---|---|
| Panne de voiture, dentiste, prime | **Aléatoire** : 1 à 3 par an (au moins 1, pool), mois tiré, montant tiré ; même type ≤ 1 fois / 24 mois ; tiré au départ, sauvegardé, indépendant des choix | `chapitres/1984/evenements_vie.json`, `etat_partie._tirer_calendrier` |
| Panne « coïncidence » | **Scriptée** : le mois qui suit le krach (11/1987), seul type voiture | `coincidenceApresMois` |
| Naissance | **Scriptée** 04/1985 ; seul le nombre (jumeaux 1 fois sur 4) et les prénoms sont tirés. Les naissances aléatoires existent dans le moteur mais sont éteintes (`naissances_aleatoires: false`) | `chapitre.json` |
| Héritage de tante Odette | **Scripté** 04/1988, 60 000 F d'assurance-vie (hypothèse barrée 32 500 F par succession), présentation D08 | `banque.json` > `heritage` |
| Cartes du foyer | **Mi-aléatoires** : 10 créneaux à fenêtre fixe (S1-S10), candidate tirée ; C00 selon l'humeur | `foyer.json` |
| Projets | **Scriptés** : choix 03/1984 et 01/1987, échéances fixes | `projets.json` |
| Jean-Mi, kiosque, passages de la rue | **Scriptés** (récit du rival, faits d'époque) | `rue.json` |
| Prévu en 1989-1993 (docs/39, docs/38) | mariage 06/1990, promotion 03/1990 (si C07), oncle Raymond 03/1991, Karine 06/1990, chômage partiel de Patrick 04/1993, préretraite de Michel 04/1993 : **tous à date fixe** | docs/39 §2-3, docs/38 §7.1 |
| Tests | `test_cadence` exige naissance 04/1985, panne 11/1987, héritage 04/1988 (40 graines) ; `Cadence.date_connue` les traite comme datées | `godot/tests/test_cadence.gd` |

Constat : les petits coups durs sont déjà aléatoires, mais **les 3 moments de vie qui comptent** (naissance, héritage, panne du krach) tombent toujours au même mois. Dès la 2e partie, le joueur les attend : c'est exactement ce que le joueur réel refuse.

---

## 2. Catalogue des événements de vie (21 types)

Légende : **A** = aléatoire simple (effet `cout` / `gain`, JSON seul) ; **C** = conditionnel (dépend d'un choix ou d'un état, tiré d'avance) ; **N** = ancré (survenue garantie ou forte, date en fenêtre, §4). Pause : ■ toujours, ○ notification, ◐ pause si ≥ 1 M ou si le compte ne suffit pas. Probabilités **annuelles de base**.

| # | Nom (titre de carte) | Type | Proba / an | Conditions | Effet chiffré | Pause | Ce qu'il apprend (jamais dit comme conseil) |
|---|---|---|---|---|---|---|---|
| 1 | La voiture rend l'âme | A | 15 % | a une voiture (tous sauf profil sans voiture) | − 0,6 à 1,2 M | ■ | épargne de précaution |
| 2 | Frais de dentiste | A | 10 % | — | − 0,2 à 0,6 M | ○ | mutuelle, reste à charge |
| 3 | Prime exceptionnelle | A | 30 % | salarié | + 0,5 à 1,0 M | ◐ | que faire d'une rentrée imprévue |
| 4 | Le lave-linge lâche | A | 12 % | — | − 0,3 à 0,5 M | ○ | les petites dépenses imprévues sont la norme |
| 5 | Dégât des eaux | A | 6 % | — | − 0,3 M (franchise ; le reste payé par l'assurance habitation) | ◐ | franchise, utilité de l'assurance |
| 6 | L'accrochage | A | 4 % | a une voiture | − 0,4 M (franchise) puis − 0,04 M / mois pendant 12 mois (malus) | ■ | un coût continue après l'événement |
| 7 | Le cambriolage | A | 2 % | — | − 0,3 à 0,8 M (objets non déclarés, franchise) | ■ | assurance et ce qu'elle ne couvre pas |
| 8 | Heures supplémentaires | A | 10 % | salarié, hors récession | + 0,3 à 0,6 M | ○ | revenu irrégulier |
| 9 | Trop-perçu des impôts | A | 5 % | imposable | + 0,2 à 0,4 M | ○ | (aucun : respiration) |
| 10 | Le mariage du cousin | A | 8 % | — | − 0,15 à 0,3 M (cadeau, voyage) | ○ | obligations sociales = vrai poste du budget |
| 11 | Voyage annulé | C | 6 % **par voyage réservé** (cartes vacances, projet voyage, choix a) | voyage choisi dans les 6 mois | − 30 % du prix du voyage (acompte perdu), **0 si l'assurance annulation a été prise** (choix c de la carte vacances : + 4 % du prix) | ■ | assurance = payer pour effacer un risque qu'on ne peut pas absorber |
| 12 | Pépin à l'étranger | C | 4 % par voyage hors CEE | voyage hors CEE | − 0,5 à 1,5 M de frais médicaux ; 0 si assistance (carte bancaire « haut de gamme » ou assurance voyage : dates à confirmer, banquier) | ■ | assurance voyage, garanties de la carte |
| 13 | Le chômage partiel | C | 3 % ; **8 % en récession** (1993, 2009 : périodes fournies par le boursier) | salarié, ou conjoint salarié | revenu − 25 % pendant 3 à 6 mois (indemnités comprises) | ■ | 3 à 6 mois de dépenses de côté |
| 14 | L'arrêt maladie | C | 2 % | salarié | revenu − 10 % pendant 3 mois (indemnités journalières, mutuelle) | ◐ | prévoyance, précaution |
| 15 | Une naissance | N | 1er enfant : fenêtre garantie si le profil le prévoit, sinon 10 % ; 2e : 8 % | couple, 25-40 ans, budget restant positif (règle existante), ≤ 2 enfants | dépenses + 9 % du salaire par enfant, définitivement (existant) ; jumeaux 1,5 % (25 % pour la naissance ancrée de Gérard, choix de la démo) | ■ | budget familial, épargne qui baisse |
| 16 | Le grand jour (mariage) | N | 12 % | couple non marié, 25-40 ans, ≥ 2 ans de vie commune ; jamais dans les 9 mois d'une naissance | fête au choix 0,3 / 1,8 M (docs/39 §2.1) ; règles des époux pour la succession | ■ | mariage et transmission |
| 17 | Le départ d'un aîné (tante, oncle, parrain, sans enfant) | N | 1 garanti par tranche de 10 ans joués, fenêtre (§4) | un aîné vivant dans la famille élargie (§3.4) | héritage 6 à 9 M : **assurance-vie** (60 %) ou **succession** (40 %), tirés ; hypothèse barrée inverse (rendu d'Odette) | ■ | assurance-vie hors succession, parenté et droits |
| 18 | Le départ d'un parent | N | selon l'âge du parent : 1 % < 65 ans, 2 % 65-74, 5 % 75-84, 12 % ≥ 85 | parent vivant ; au plus 1 par chapitre | frais d'obsèques − 0,5 M (partagés) ; héritage en ligne directe 3 à 8 M, **sous l'abattement : 0 droit** | ■ | ligne directe, abattement ; l'assurance-vie n'y change rien sous l'abattement (règle d'honnêteté de docs/38) |
| 19 | La séparation | C | 1,5 % (+ couplage carrière, §2 bis, plafond 3 %) | couple depuis ≥ 3 ans, jamais dans les 12 mois d'une naissance ou d'un mariage, au plus 1 par partie | déménagement − 2 M ; mariés : partage par moitié de ce qui a été acquis ensemble ; non mariés : chacun garde les placements à son nom, le compte joint est coupé en deux ; dépenses du foyer recalculées ; bascule en R-SEUL (proche = un ami) | ■ | régime matrimonial, au nom de qui sont les placements, budget seul |
| 20 | Les études de l'aîné | N | à 18 ans d'un enfant | enfant de 18 ans | − 0,4 M / mois pendant 3 ans, ou bourse (tirée 30 %) | ○ puis ■ à l'entrée | épargne à horizon connu |
| 21 | Le coup dur pendant la tempête | N | 1 par vitrine de marché | une vitrine (krach, Golfe…) dans le chapitre | − 0,8 à 1,2 M, type tiré parmi 1, 5, 6, 7 ; **1 à 3 mois** après la vitrine | ■ | la précaution évite de vendre au plus bas |

Exclus volontairement : gain au jeu (loto, tiercé : pas de récompense au hasard pur, et tabac / casino suspendus), « bon tuyau » d'un proche qui marche (seul Jean-Mi donne des tuyaux, et il échoue), accident grave ou maladie grave du personnage (lourd, pas de leçon d'épargne propre), décès d'un enfant ou du conjoint (exclu ; la mort du personnage suit R-FIN, docs/39 §10).

**Liaison des choix (sans tricher)** : les types C sont **pré-tirés** au départ (un nombre aléatoire par mois et par type, sur leur propre flux) ; le choix du joueur décide seulement si la condition est remplie. Un choix ne rebat donc jamais les autres événements.

**Séparation** : couplée **faiblement** à l'humeur, et **seulement par la carrière** (décision du joueur du 18/11, §2 bis ; remplace « indépendante de l'humeur »). Texte sobre : « Sylvie et vous avez décidé de vous séparer. Chacun reprend sa route ; reste à partager ce que vous avez construit. » Pas d'humour, pas de voisin.

**Décès** : une phrase, pas de cause, pas d'humour, pas de passage de voisin le même mois. « Tante Josiane s'est éteinte en mars, à 81 ans. Elle vous avait désigné sur son assurance-vie. » Puis la carte chiffrée du banquier. Le nom « Josiane » est aussi l'épouse de Michel (docs/39 §3) : à retirer de la liste des aînés quand le profil est Michel.

---

## 2 bis. Séparation et humeur : couplage faible par la carrière (décision du joueur, 18/11)

Le joueur veut que l'humeur du conjoint pèse **légèrement** sur la séparation (ex. horaires plus lourds → humeur en baisse → risque un peu plus haut). Le client refuse toute nouvelle jauge (docs/44). Règle :

1. **Aucune jauge nouvelle.** Chaque variation d'humeur porte déjà une cause (« dernière cause ») ; on étiquette celles qui viennent des **cartes de carrière** (K4, K5 et suivantes) : `cause: "carriere"`. Les cartes de dépense / épargne, C00, les projets et l'usure de janvier n'ont jamais cette étiquette.
2. **Probabilité annuelle** (tirée chaque janvier, nombre pré-tiré sur le flux `conditionnels`) : `p = 1,5 % + 0,75 point par année « tendue »`, **plafond 3 %**. Une année est « tendue » si, au 31 décembre, Sylvie est **fâchée** et qu'un choix de carrière à horaires lourds est **actif**. Un choix « plus de temps » (4/5e…) actif retire 0,5 point (plancher 1 %). Les années tendues s'effacent une à une dès que la situation se détend (pas de dette éternelle).
3. **N'épargne jamais contre le joueur** : une fâcherie due à des refus de dépense (Palavas, luge au parc…) ne compte pas, car le choix de carrière lourd est requis. L'usure positive de janvier (D15) reste telle quelle et n'entre pas dans le calcul. La fourmi garde la même probabilité que la cigale à carrière égale.
4. **Lisible** : la carte de carrière l'écrit en clair sous le choix lourd : « Sylvie vous verra moins. Le couple peut en souffrir. » ; la bulle d'humeur liée cite la cause (« Encore rentré à 21 h. ») ; la carte de séparation rappelle sobrement « Les soirées tardives avaient pesé. » si au moins une année tendue, sinon aucune cause. Jamais de pourcentage affiché, jamais de compte à rebours.
5. **Honnête et sobre** : les conséquences financières viennent du banquier (régime matrimonial, partage du commun, contrats au nom de chacun, deux loyers, pension s'il y a des enfants) ; aucun reproche, aucun humour. Effet plafonné : sur 5 ans, ≈ 5 % (plus de temps) / ≈ 7 % (base) / ≈ 14 % au pire (5 années tendues), jamais une quasi-certitude.
6. **Tests et équité** : R-MIROIR inchangée (les voisins ont les mêmes choix de carrière, donc la même séparation, avec un partage proportionnel à leur patrimoine) : l'écart face à Tata Livret ne bouge pas. Tests : (a) politiques « épargner » / « dépenser » sur 40 graines, carrière neutre → **mêmes dates de séparation** ; (b) probabilité jamais > 3 % ; (c) sur 1 000 graines, fréquence mesurée conforme à la formule ; (d) sauvegarde des années tendues.
7. **Lot 10** : la séparation n'y est pas (elle exige R-SEUL) ; le pilote K4 / K5 pose seulement l'étiquette `cause: "carriere"` et le compteur d'années tendues (sauvegardé, sans effet), pour brancher la séparation plus tard sans changer les parties en cours.

---

## 3. Règles de tirage, anti-répétition et équité

### 3.1 Graine et flux
- **Une graine par partie** (tirée à « Nouvelle partie », sauvegardée ; existe : `graine_vie`).
- **Un flux par module**, décalage fixe (existe pour naissances et foyer) : `vie`, `naissance`, `famille`, `conditionnels`, `chapitre_N` (+ 7 919 × index du chapitre). Ajouter un type ou un chapitre ne déplace jamais les dates déjà tirées des autres.
- **Calendrier tiré au départ de chaque chapitre** et sauvegardé tel quel (déjà dans `CHAMPS_ETAT`) : une mise à jour des données ne change pas une partie en cours.
- **Anti-retour entre deux parties** (faible coût) : la date de l'aîné et de la naissance de la dernière partie sont gardées dans les préférences locales ; si la nouvelle graine les redonne au même mois, on retire la graine (3 essais au plus).

### 3.2 Pioche par tranches (au lieu de 15 tirages indépendants)
Par chapitre de 60 mois, 5 tranches de 12 mois :
1. Placer d'abord les **ancrés** (§4) dans leurs fenêtres.
2. Pour chaque tranche, tirer les A et le pré-tirage des C avec les probabilités du §2 (comme aujourd'hui), au plus 3 par tranche.
3. Appliquer le **budget de malchance** (§3.3), puis l'**espacement** (§3.4).

### 3.3 Budget de malchance (par chapitre de 60 mois, R-MIROIR compris)
| Règle | Valeur |
|---|---|
| Coûts imprévus (A + C + coup dur du krach) | entre **1,5 M et 4,5 M** au total ; au-delà, on retire le plus petit flexible ; en dessous, on ajoute un type 4 ou 5 |
| Gros coups durs (≥ 1 M) | **≤ 2** par chapitre, **≥ 9 mois** d'écart |
| Série noire interdite | jamais 3 coûts dans 12 mois glissants |
| Bonne nouvelle | **≥ 1** (prime, heures sup., trop-perçu) par 24 mois |
| Jamais vide | ≥ 1 événement de vie (pause ou notification) par tranche de 12 mois ; ≥ 3 événements de vie avec pause par chapitre |
| Revenu amputé (13, 14) | ≤ 1 épisode par chapitre |
| Séparation, départ d'un parent | ≤ 1 « événement lourd » par chapitre ; jamais deux chapitres de suite avec un événement lourd |

Niveaux de difficulté (plus tard, quand ils existeront) : débutant 1,5-3 M, normal 1,5-4,5 M, professionnel 3-6 M. Jamais d'effet sur le marché.

### 3.4 Espacement
- Même type : ≥ 24 mois (existe). Deux ancrés : ≥ 6 mois. Un ancré jamais à ± 1 mois d'un événement de marché, d'une date historique ou d'une échéance de projet (connus au départ).
- R-CADENCE inchangée : une pause par mois, jamais deux mois de suite (exception marché → coup dur de la tempête si le délai tiré est 1 mois).

### 3.5 Équité : l'écart doit venir des choix
- **R-MIROIR étendue** : tous les types (coûts, gains, revenu amputé, héritages, naissance, séparation proportionnelle au patrimoine) touchent aussi Tata Livret, Tonton Matelas et Jean-Mi. Le score (écart face à Tata) neutralise donc la chance sur les montants.
- **Seul effet de chance restant** : le moment d'une grosse rentrée par rapport au marché. Garde-fou : **aucun héritage ni rentrée ≥ 3 M dans les 6 mois qui précèdent une vitrine** de marché (règle invisible, A5 respecté : elle ne se voit pas).
- **Mesure (test)** : pour une même stratégie, l'écart face à Tata varie selon la graine ; cible : **dispersion due à la graine ≤ ¼ de l'écart entre la stratégie « tout au Livret A » et la stratégie de référence la plus investie** (population P-REF du lot 08b, 100 graines).

---

## 4. Ce qui reste « scripté » : survenue garantie, date en fenêtre

| Événement | Survenue | Fenêtre de date (1984-1993) | Contrainte pédagogique |
|---|---|---|---|
| Naissance (Gérard ; 2e enfant de Martine) | garantie | **12/1984 → 06/1985** (7 mois) | avant S3 (C04 poussette, C05 fête, 08-10/1985) ; plus tard (lot 13+) : S3 relatif = naissance + 3 à 6 mois et fenêtre élargie à 18 mois |
| Coup dur de la tempête | garanti | krach + **1 à 3 mois** (11/1987 → 01/1988) ; Golfe : 10/1990 → 12/1990 | la précaution se voit au pire moment ; type tiré |
| Héritage de l'aîné (Odette) | garanti 1 par 10 ans | **01/1988 → 09/1988** | après D04 (AV présentée) ; pas dans les 6 mois avant une vitrine ; nom tiré (Odette, Raymond, Josiane, Marcel) au même degré (oncle / tante : mêmes chiffres, docs/38) |
| Mariage de Gérard | 70 % sur le chapitre | **09/1989 → 06/1992** | 12 %/an ne suffit pas sur 5 ans : fenêtre + 70 % ; sinon il reste en concubinage (la note de transmission en est plus forte) |
| Oncle Raymond (2e aîné, Gérard) | garanti si Odette a eu lieu avant | **01/1991 → 06/1992** | hors ± 6 mois de la vitrine du Golfe et de « un an après » ; le type (AV / succession) est l'inverse de celui d'Odette, pour voir les deux cas |
| Chômage partiel de Patrick (Christine) | garanti | **01/1993 → 09/1993** (récession réelle) | fait d'époque : fenêtre dans la période historique |
| Événements des autres profils (Karine 06/1990, préretraite de Michel 04/1993, promotion de Sophie 09/1991) | garantis | ± 6 mois autour de la date prévue, sauf réforme datée (Sophie : corps créé en 1990 → 09/1990-09/1992, rentrée seulement) | une date de loi ou de rentrée scolaire reste une date réelle |
| Promotion CNAM | conditionnelle (C07) | **01/1990 → 12/1990** | leçon « investir en soi paie tard » |

Fenêtre minimale : 6 mois (anticipation au mois près impossible) ; contrôle : sur 100 graines, **aucun mois ne porte plus de 25 %** d'un même ancré.

---

## 5. Impacts

**Tests** (dev-logique, testeur)
- `test_cadence` (dates imposées) : remplacer l'égalité de date par l'appartenance à la fenêtre, sur 40 graines ; garder les mêmes vérifications R-CADENCE.
- **Calendrier de référence** : un drapeau de configuration (`vie_reference: true`) rejoue les dates actuelles (naissance 04/1985, panne 11/1987, héritage 04/1988, Odette). Utilisé par `graine_test`, les scénarios de capture et `test_demo` : les 1 379 vérifications et les captures de 1984-1988 restent valables sans réécriture. Les vraies parties ne l'utilisent jamais.
- Nouveaux tests (100 graines) : fenêtres respectées ; ≤ 25 % sur un même mois ; budget de malchance (§3.3) ; jamais vide ; ancrés hors ± 1 mois des datées ; R-MIROIR (le test Tonton Matelas existant suffit, étendu aux nouveaux types) ; équité (§3.5) ; cartes `requiert_enfant` jamais avant la naissance.
- `Cadence.date_connue` : un ancré tiré au départ compte comme date connue (comme la naissance scriptée aujourd'hui).

**Cadence et durée** : la cible reste ≈ 20 min par chapitre et 26-28 pauses en 1989-1993. Les nouveaux types sont surtout des notifications (○) ; avec pause : ancrés 2 à 3 + aléatoires 1 à 3 par chapitre, comme aujourd'hui (0-2 + naissance + héritage + panne). Le plafond `plafond_interruptions` continue de transformer les mineurs en notifications.

**Records** : comparables, car Tata vit la même vie (§3.5) ; garde-fou héritage / vitrine. Le record de 1984-1988 existant reste valable (même calcul). Option plus tard, faible coût : **code de partie** (la graine affichée au bilan) pour qu'un ami rejoue exactement la même vie et compare ; jamais par défaut.

**Contenus** : banquier (chiffres de l'héritage selon le lien et AV / succession, franchises, assurance annulation et assistance d'époque, indemnités chômage et maladie) ; boursier (périodes de récession) ; UX (picto par type, carte sobre du décès).

---

## 6. Variante minimale du lot 10

Coût total : **faible à moyen**, uniquement logique + données + tests, aucune nouvelle scène.
1. **Naissance** de Gérard : fenêtre 12/1984 → 06/1985 (jumeaux 1 fois sur 4 inchangé).
2. **Coup dur de la tempête** : 1 à 3 mois après le krach, type tiré parmi voiture / dégât des eaux / accrochage / cambriolage (si le délai est 1, exception R-CADENCE actuelle).
3. **Héritage** : fenêtre 01/1988 → 09/1988 ; nom de l'aîné tiré parmi 4 au même degré (montants inchangés : 60 000 F, 32 500 F).
4. **1989-1993** : mariage (fenêtre, 70 %), promotion CNAM (fenêtre 1990), oncle Raymond (fenêtre, AV), chômage partiel de Patrick pour Christine (fenêtre 1993) : à tirer dès leur écriture, pas de date fixe.
5. **Types 4, 5, 6, 8, 9, 10** ajoutés à `evenements_vie.json` (effets `cout` / `gain` existants, sauf le malus du 6 : version simple − 0,8 M d'un coup au lot 10).
6. **Budget de malchance** en post-traitement du calendrier (bornes du §3.3) et **règle héritage / vitrine**.
7. **Calendrier de référence** pour les tests et captures ; nouveaux tests du §5.

Après le lot 10 : conditionnels 11 à 14 (assurance annulation dans les cartes vacances), famille élargie et départ d'un parent (17-18), études (20), séparation (19, avec R-SEUL), anti-retour entre parties, code de partie.

---

## 7. Points à confirmer

- **Joueur / client** : séparation dans le jeu (oui, sobre, ≤ 1 par partie, couplage faible par la carrière seulement, §2 bis ; K4 / K5 au lot 10, retraite et PER repoussés) ; mariage de Gérard à 70 % (et non garanti) ; jumeaux 25 % gardés pour la naissance ancrée ; décès d'un parent admis (sobre).
- **Banquier** : chiffres AV / succession par lien et par année, assurance annulation et assistance (existence et prix en 1984-1993), indemnités de chômage partiel, franchises.
- **Boursier** : périodes de récession par décennie (probabilité du chômage partiel).
- **Chef de projet** : découpage (lot 10 = §6) et carte des fichiers (`etat_partie.gd`, `banquier.gd`, `cadence.gd`, données du chapitre, tests).
