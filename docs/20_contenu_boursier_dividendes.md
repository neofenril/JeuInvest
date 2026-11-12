# 20 - Dividendes 1986-1988 : réponses du boursier aux questions B1 à B3 de lot_03 §8

> Certitude : **A** vérifié, **B** probable (erreur < 5-10 %), **C** reconstitué (erreur 10-25 %, ou fait non confirmé).
> Honnêteté sur les sources : la recherche web du 2026-11-12 n'a donné **aucune** source en ligne exploitable pour les dividendes par titre de 1986-1988 (documents de référence en ligne dès ~2000, archives de presse inaccessibles). Tout ce qui suit est donc **B ou C** et vient de la pratique de l'époque et du modèle de docs/03 §7.4. Rien n'est bloquant : le défaut du lot (mai, rendement de marché + écart) reste acceptable pour un jeu. Une archive fournie dans `docs/sources/` (annuaire Desfossés, rapports annuels 1986-88) permettrait de passer en B.

## B1. Mois de détachement / paiement 1986-1988

Pratique de l'époque (B) : exercice = année civile, assemblée générale en mai-juin, **détachement et paiement dans les semaines suivant l'AG**, soit mai à juillet. Un seul dividende par an (pas d'acompte semestriel en général ; Elf et Saint-Gobain ont parfois versé un acompte, non retenu ici : C).

| Titre | Mois de paiement retenu (1987 et 1988) | `moisDiv` à écrire | Certitude | Remarque |
|---|---|---|---|---|
| Elf Aquitaine | juin (AG en mai-juin) | 5 ou 6 (indifférent) | C | Dividende de l'exercice 1986 versé en 1987. |
| L'Oréal | juin (AG fin mai - début juin) | idem | C | |
| Peugeot SA | juin-juillet (AG en juin) | idem | C | Voir B2 : pas de dividende avant l'exercice 1986. |
| Saint-Gobain | juin (AG en juin) | idem | C | |

Décision recommandée : **ne rien écrire (défaut mai)** pour les quatre titres. L'écart réel d'un à deux mois est invisible pour le joueur et n'a aucune valeur pédagogique ; si l'on veut de la variété, `moisDiv = 6` pour Peugeot seulement (la date la plus tardive, C).

Cas du premier dividende de **Saint-Gobain** (OPV du 24/11/1986, privatisation le 22/12/1986) : l'acheteur de décembre 1986 est actionnaire à la clôture de l'exercice 1986 et reçoit le **dividende de l'exercice 1986 en mai-juin 1987** (B). Il n'y a **aucun dividende entre l'achat et mai 1987**. Pas de dividende 1986 payé en 1986 pour aucun des quatre titres (A sur le principe : aucun n'a d'acompte à cette époque dans nos données ; C sur Elf).

Pour le mois de paiement d'un exercice N, le jeu paie en mai N+1 : en 01/1984 - 12/1988, les paiements ont lieu en **mai 1984 à mai 1988** (cinq versements possibles ; pour un titre acheté après mai 1988, aucun dividende avant la fin de la partie, c'est normal).

## B2. Rendement par titre et Peugeot

Modèle : rendement du titre = `rdt_div_%` de marché (02 §4.2, A/B pour le marché) + `ecartDiv` du titre (03 §7.4). Rendement **brut avant avoir fiscal**, appliqué au cours du mois de détachement.

| Année (paiement en mai) | Marché `rdt_div_%` | Elf (+1,5) | L'Oréal (-1,5) | Peugeot (0) | Saint-Gobain (0) |
|---|---|---|---|---|---|
| 1984 (exercice 1983) | non repris ici (marché ≈ 4,5-5 %, C) | - | - | **0 (divNul)** | non coté privé : sans objet |
| 1985 (exercice 1984) | 3,4 | 4,9 | 1,9 | **0 (divNul)** | sans objet |
| 1986 (exercice 1985) | 2,6 | 4,1 | 1,1 | **0 (divNul)** | sans objet (privatisée 12/1986) |
| 1987 (exercice 1986) | 3,6 | 5,1 | 2,1 | 3,6 | 3,6 |
| 1988 (exercice 1987) | 3,0 | 4,5 | 1,5 | 3,0 | 3,0 |

Validation du modèle (B/C) : l'ordre de grandeur est juste. Elf (pétrole, dividende généreux, cours déprimé par le contre-choc pétrolier de 1986) est au-dessus du marché ; L'Oréal (PER élevé, croissance) très en dessous (de l'ordre de 1 à 2 %) ; Saint-Gobain proche du marché. Le détachement de mai 1987 précède le krach ; le 3,6 % de 1987 vient du rendement de marché calculé sur l'indice de fin d'année (1000 après -28,7 %). **Attention (B)** : appliqué à un cours de mai 1987 proche du plus haut, un rendement de 3,6 % surestime un peu le dividende réel (qui avait été fixé sur des cours plus bas). Pour éviter l'effet, **plafonner le rendement de marché utilisé à 3,2 % pour 1987** (le niveau 3,0-3,2 est cohérent avec 1988). Sinon, garder tel quel : écart d'au plus 0,4 point, négligeable.

Rendement net perçu par le joueur = brut x (1 - 16 %) (D2 du lot, avoir fiscal non modélisé).

**Peugeot SA (C, probable)** : les résultats de PSA ont été mauvais de 1980 à 1985 (pertes consolidées, absorption de Citroën puis de Talbot-Chrysler Europe, restructurations). **Pas de dividende pour les exercices 1983, 1984 et 1985** (donc paiements 1984, 1985, 1986 nuls). Retour aux bénéfices en 1986 et **reprise du dividende pour l'exercice 1986 (versé en 1987)**. Certitude C : l'absence de dividende pendant les pertes est quasi sûre pour 1984 et 1985 (B), la reprise exacte en 1986 est probable (C). Les années du joueur étant 1984-1988, `divNul = [1984, 1985, 1986]` (années de paiement) pour Peugeot, comme dans le défaut du lot.

Lien pédagogique : cela soutient l'histoire de Peugeot dans docs/19 (le titre à 520 F en 09/1986 est un pari sur le redressement, sans coupon pendant l'attente).

## B3. Faut-il faire baisser le cours au détachement ?

**Réponse : non pour la V3, on garde docs/03 §7.4 (aucun ajustement).** Justification par les chiffres (modèle de frais de 03 §7.5 : 1,3 %, minimum 50 F, à l'achat **et** à la vente ; impôt 16 %) :

| Titre | Rendement brut 1987 | Net après 16 % | Frais aller-retour (2 x 1,3 %) | Gain net de l'aller-retour « achat avant, vente après » |
|---|---|---|---|---|
| Elf | 5,1 % | 4,3 % | 2,6 % | **+1,7 %** (avant risque de cours sur 2 mois, vol. mensuelle 4-5 %) |
| Saint-Gobain, Peugeot | 3,6 % | 3,0 % | 2,6 % | +0,4 % |
| L'Oréal | 2,1 % | 1,8 % | 2,6 % | **-0,8 %** |

Les frais de courtage de l'époque neutralisent presque entièrement l'astuce, sauf peut-être Elf. Le gain maximal (+1,7 %) est inférieur à l'écart-type d'un mois de bourse : ce n'est pas une martingale, juste un petit pari. Faire baisser le cours créerait en revanche un défaut : les ancrages (clôtures de fin de mois et données du jeu) sont des **cours réels**, qui contiennent déjà les baisses de détachement ; ajouter une chute artificielle forcerait à une remontée compensatoire pour tenir les ancrages (dents de scie), compliquerait le pont brownien et brouillerait le rappel à 12 mois.

Garde-fou léger recommandé (sans toucher aux cours, code minimal) : **le dividende n'est versé que pour les actions détenues au début du mois de détachement** (achetées au plus tard le mois précédent). Une ligne achetée en mai ne touche rien en mai. Le jeu reste au cours du mois (A11) ; la leçon « le cours baisse du montant du dividende le jour du détachement, on ne s'enrichit pas en achetant la veille » peut figurer dans la **notification du 1er dividende** comme phrase pédagogique, sans modifier la simulation. Si le client veut quand même l'effet visible plus tard, à traiter en lot ultérieur : baisse = dividende brut le mois de détachement, compensée par un pont brownien reconstruit entre les mêmes ancrages (jamais sur l'indice, qui reste de prix).

## Récapitulatif pour le développeur

| Clé | Valeur |
|---|---|
| `regles.json > dividendes.mois` | 5 (inchangé), `_certitude` C |
| `moisDiv` par titre | absent (défaut mai) ; option Peugeot = 6 |
| `divNul` Peugeot | `[1984, 1985, 1986]`, `_certDiv` C |
| `divNul` Elf, L'Oréal, Saint-Gobain | absent (Saint-Gobain : pas de paiement avant mai 1987 puisque achetable dès 12/1986 seulement ; avant, le titre n'est pas dans le jeu) |
| `ecartDiv` | Elf +1,5 ; L'Oréal -1,5 ; Peugeot 0 ; Saint-Gobain 0 (validés, B/C) |
| Plafond optionnel du rendement de marché 1987 | 3,2 % (écart de 0,4 point sinon) |
| Condition de versement | action détenue **avant** le début du mois de détachement |
| Ajustement du cours au détachement | **aucun** (B3) |
