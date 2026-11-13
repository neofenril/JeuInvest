# 25. Banquier : relecture et textes définitifs des projets du foyer (demande K3, point 1)

> Sources relues : `lot_05.md` §8 (K3), `docs/18` §2-3, `projets.json` de `lot04-logique` (version en cours d'écriture, du 2026-11-13). Rédigé le 2026-11-13.
> Règles : chaque texte fait 30 mots ou moins (gabarits comptés pour 1 mot) ; aucun conseil, aucun impératif sur un produit, pas de « il vaut mieux » ; constats au présent ou conditionnel.
> Certitude : A vérifié, B probable, C reconstitué. Le point 2 de K3 (Jean-Mi, Porsche, crédit) n'est pas traité ici.

---

## 1. Relecture de l'ordre de vente (réponse à K3 point 1)

### 1.1 Verdict
Juste pour un jeu, lisible à condition de **dire quelle rentabilité on utilise**. Trois remarques.

| # | Constat | Gravité | Proposition |
|---|---|---|---|
| R1 | **Incohérence de définition.** `lot_05.md` D7 bis et K3 parlent de « gain annualisé depuis l'ouverture » ; `projets.json` (`_ordre_vente`) calcule (valeur nette de vente − versements) / versements, **non annualisé**. Les deux ne classent pas pareil : une ligne ouverte depuis 1 an à +5 % passe avant une ligne ouverte depuis 4 ans à +10 % (non annualisé), alors que son rendement annuel est meilleur. | À trancher par le chef de projet | Le texte de la carte doit décrire la formule retenue. Deux variantes ci-dessous (§3.1). Mon avis pédagogique : l'annualisé est la vraie « rentabilité » ; le non annualisé est plus simple et suffit si la phrase dit « ce qui a le moins rapporté ». |
| R2 | **Le PEL se retrouve vendu tôt.** Comme la rentabilité est nette de la prime d'État perdue, un PEL clos avant 4 ans a une rentabilité très basse et passe **avant** des actions en gain. Cela contredit docs/18 §3.1 (« PEL en dernier »). C'est cohérent avec la décision du joueur, mais le joueur doit le **voir** avant de confirmer : la pénalité s'affiche ligne par ligne (§3.4). | Moyenne (effet de jeu) | Ne pas l'expliquer comme un conseil ni comme une erreur : la carte dit seulement l'ordre et montre le coût. |
| R3 | **Le Livret A n'est pas « du moins rentable au plus rentable ».** Il est vendu en 2e rang par décision du joueur, avant toute règle de rentabilité. Réaliste (liquidité immédiate, aucune pénalité, A) mais ce n'est pas un classement de rentabilité. | Faible | La phrase l'énonce séparément : « compte courant, Livret A, puis ... ». |

### 1.2 « Livret bleu » et Livret A
- Le **Livret bleu** est l'appellation du Livret A au **Crédit Mutuel** (depuis 1975, même taux et même plafond que le Livret A, certitude **A** pour l'existence, **B** pour 1975). Le Livret A n'est distribué dans toutes les banques qu'à partir du 01/01/2009 (A) : avant, Caisses d'épargne et La Poste ; pour Gérard, la « sa banque » du jeu reste une simplification (D3 de 11, en attente).
- Recommandation : **écrire « Livret A » dans les textes et sur les cartes** (nom du produit du jeu, partout identique) ; « Livret bleu » n'est pas un anachronisme mais ajouterait un 2e nom sans gain. Si le client veut honorer l'expression du joueur, le glossaire peut dire : « Livret A (au Crédit Mutuel : Livret bleu) ».
- Retrait : le jeu étant mensuel, on ignore la règle des quinzaines (un retrait fait perdre les intérêts de la quinzaine en cours) : simplification à ne pas signaler.

### 1.3 Ce qui est simplifié (à garder pour un jeu)
- Impôt sur plus-value à 16 % : **convention de jeu** (réalité 1984-1988 : plus-values taxées seulement au-delà d'un seuil de cessions, donc souvent nulles pour de petites sommes, A pour le principe, C pour le seuil). La bulle (?) de 03 §7.4 doit s'afficher : « Simplifié : à l'époque, les petites ventes étaient souvent exonérées. »
- Emprunt d'État vendu au nominal sans frais : simplification (le prix réel variait avec les taux).
- PEL clos avant 4 ans, intérêts seuls au taux de base : approximation (B).

---

## 2. Carte de choix de projet

Gabarits : `{echeance}`, `{prenoms}`. Le « sous » est la ligne sous le nom de l'option.

| Clé | Texte définitif | Mots | Cert. |
|---|---|---|---|
| P1 `titre` | Un projet pour 1986 | 4 | |
| P1 `texte` | Sylvie et vous avez une envie à réaliser d'ici {echeance}. Chaque projet a un prix et une date : à vous de choisir. | 23 | |
| P1A `sous` | Canapé, fauteuils et une vraie chaîne hi-fi | 7 | B/C |
| P1B `sous` | Deux semaines dans les Cyclades, à deux | 7 | C |
| P1C `sous` | Apport comptant ; la vieille 4L est reprise | 7 | C |
| P2 `titre` | Un nouveau projet | 3 | |
| P2 `texte` | Avec {prenoms}, la famille a d'autres envies. Chaque projet a un prix et une date : à vous de choisir. | 19 | |
| P2A `sous` | Une semaine en juillet, tous ensemble | 6 | C |
| P2B `sous` | Apport comptant ; le reste serait à crédit | 7 | C |
| P2C `sous` (**à remplacer**) | 20 à 25 % du prix d'un T3, le reste emprunté. Un PEL ouvert en 1984 ouvre droit à un prêt, en 1988 au plus tôt. | 26 | B/C |

Remarques :
- **P2C `sous`** du JSON actuel fait 40 mots : trop long pour une ligne sous un nom, et mélange l'objet (T3) et un produit. Texte ci-dessus : 90 000 F pour un T3 à 350-450 000 F = 20-25 % (B/C, docs/18 §2) ; le prêt d'un PEL ouvert en 1984 est ouvert après 4 ans, donc en 1988 au plus tôt (B ; le jeu présente le PEL au plus tard en 07/1984). Aucun taux de prêt affiché (non sourcé).
- Jamais « placement suggéré » ni mention du produit à utiliser pour réunir la somme (validé, docs/18 §2.2).
- Le `titre` « Un projet pour 1986 » est exact : échéances 04/1986 (P1).
- P1B : « les 30 ans de Sylvie » reste dans le `nom` (hors `sous`). Montant retenu 16 000 F (C).

---

## 3. Le jour J

### 3.1 Phrase de la carte (réponse à K3, ≤ 15 mots)

| Variante | Texte | Mots | À utiliser si |
|---|---|---|---|
| **A (recommandée si rentabilité non annualisée, comme dans `projets.json`)** | Ordre des ventes : compte courant, Livret A, puis ce qui a le moins rapporté. | 14 | rentabilité = (net − versements) / versements |
| B | Ordre des ventes : compte courant, Livret A, puis ce qui rapporte le moins par an. | 15 | rentabilité annualisée (D7 bis) |

Info-bulle (?), ≤ 30 mots, variante A : « « Rapporté » = ce que la ligne vaudrait vendue aujourd'hui, frais, impôts et pénalités déduits, moins vos versements. » (21 mots) ; variante B : ajouter « ramené à une année » (24 mots).
La phrase provisoire (« de ce qui rapporte le moins à ce qui rapporte le plus ») est exacte mais oublie le compte courant et le Livret A : ne pas la garder seule.

### 3.2 Titre, texte, rappel

| Clé | Texte définitif | Mots |
|---|---|---|
| `echeance_titre` | Le jour J : {nom} | 4 |
| `echeance_texte` (somme manquante) | C'est le jour J : {court}, {montant}. Sans rien vendre, vous avez {disponible} ; il manque {manque}. | 15 |
| `echeance_texte_suffisant` (nouvelle clé) | C'est le jour J : {court}, {montant}. Votre compte courant et votre Livret A couvrent la somme. | 15 |
| `rappel_titre` | Le projet approche | 3 |
| `rappel_texte` | Sylvie : {court}, c'est en {mois} ! Sans rien vendre, vous avez {disponible} sur {montant}. | 14 |

Garder `rappel_texte` tel quel (correct, factuel). « Disponible » = compte courant + Livret A, comme le dit le bouton RÉALISER.

### 3.3 Boutons

| Bouton | Titre | Sous-titre définitif | Mots |
|---|---|---|---|
| RÉALISER | RÉALISER | Payé avec le compte courant, puis le Livret A | 8 |
| RÉALISER EN VENDANT | RÉALISER EN VENDANT | Il faut vendre pour {manque} | 6 |
| (désactivé) | RÉALISER EN VENDANT | Même en vendant, il manque {manque} | 6 |
| REPORTER | REPORTER DE 4 MOIS | Nouvelle date : {echeance} | 4 |
| REPORTER (désactivé, déjà fait) | REPORTER DE 4 MOIS | Déjà reporté une fois | 4 |
| REPORTER (désactivé, P2C) | REPORTER DE 4 MOIS | Pas de report possible pour ce projet | 7 |
| RENONCER | RENONCER | Le projet est abandonné | 4 |
| RENONCER (sans report possible) | RENONCER POUR L'INSTANT | Le projet est abandonné | 4 |

Remarque : « RENONCER POUR L'INSTANT » laisse croire à un retour du projet alors que le sous-titre dit « abandonné ». Proposition : garder « RENONCER » dans tous les cas (sinon, sous-titre « Le projet ne reviendra pas »). Cert. : sans objet (texte de jeu).

### 3.4 Écran de confirmation de RÉALISER EN VENDANT

| Élément | Texte définitif | Mots |
|---|---|---|
| Titre | Ce qui serait vendu | 4 |
| Introduction | Ventes dans l'ordre : compte courant, Livret A, puis ce qui a le moins rapporté. Rien n'est vendu avant votre confirmation. | 19 |
| Compte courant / Livret A (ligne) | Livret A : {net}. Retrait sans frais ni impôt. | 8 |
| Dernière ligne partielle | Dernière ligne vendue en partie ; le surplus reste sur le compte courant. | 12 |
| Actions | Actions vendues par titres entiers ; le surplus reste sur le compte courant. | 11 |
| PEL | Le PEL est clos en entier, même si une partie suffirait ; le surplus va sur le compte courant. | 18 |
| Bouton | CONFIRMER LES VENTES | 3 |
| Bouton retour | REVENIR | 1 |

Certitude : Livret A sans frais ni impôt : **A** (0 % d'impôt, 01 §4.1). Le reste = règles du jeu.

### 3.5 Lignes de pénalité et d'écart (une par ligne vendue)

| Produit | Texte définitif | Mots | Cert. |
|---|---|---|---|
| PEL avant 4 ans | Prime d'État perdue : {x}. Le PEL est clos avant 4 ans : seuls les intérêts du taux de base sont versés. | 21 | B |
| PEL après 4 ans (**nouvelle clé** `pel_apres`) | PEL clos après 4 ans : intérêts et prime d'État conservés. Le droit au prêt immobilier est abandonné. | 17 | B |
| Assurance-vie < 6 ans | Rachat avant 6 ans : prélèvement de {taux} sur les intérêts : {x}. | 11 | A/B |
| Actions (gain) | Frais de vente : {frais} ({courtage}). Impôt sur la plus-value : {impot} (règle simplifiée du jeu). | 17 | A / convention |
| Actions (perte, **nouvelle clé** `action_perte`) | Frais de vente : {frais} ({courtage}). Pas d'impôt : la vente est à perte. | 13 | A |
| SICAV | Vente sans frais. Impôt sur la plus-value : {impot} (règle simplifiée du jeu). | 12 | A / convention |
| Emprunt d'État | Vendu au nominal, sans frais : simplification du jeu ; en vrai, le prix dépendait des taux. | 16 | A |
| Écart, moins | {produit} : {net}, soit {ecart} de moins que vos versements. | 9 | |
| Écart, plus | {produit} : {net}, soit {ecart} de plus que vos versements. | 9 | |
| Écart, égal | {produit} : {net}, autant que vos versements. | 6 | |

Points de contrôle :
- Assurance-vie : le prélèvement libératoire est **optionnel** dans la réalité (45 % < 2 ans, 25 % 2-4 ans, 15 % 4-6 ans, 0 % au-delà, contrats 1983-1989, A/B) ; le jeu applique le barème : le mot « prélèvement » est plus juste qu'« impôt ». Prélèvements sociaux : 0 % avant 1991 (A). Un contrat ouvert en 1985 ou après a moins de 6 ans en 1988 : le texte s'applique toujours dans la démo.
- Action « 1,3 %, minimum 50 F » : barème 1978-1999 de 03 §7.5 (A pour le jeu ; courtage réel 1984-1988 ≈ 1 à 1,5 % tout compris, B).
- PEL : le texte « avant 4 ans » est pertinent pour P1 (échéance 04/1986) et P2A/P2B ; pour P2C (12/1988) un PEL ouvert à l'été 1984 a plus de 4 ans : le moteur doit choisir `pel_apres`.
- « Prime d'État perdue » : prime versée sans prêt pour les PEL ouverts avant 12/2002, mais seulement après 4 ans de PEL (B).

---

## 4. Ligne au guichet

| Clé | Texte définitif | Mots | Cert. |
|---|---|---|---|
| `guichet` | Projet : {court}, {echeance} ({dans}) · {montant} | 6 | validé (docs/18 §2.2) |
| `guichet_reporte` (nouvelle clé) | Projet : {court}, reporté à {echeance} ({dans}) · {montant} | 8 | |
| `dans_mois` | dans {n} mois | 3 | |
| `dans_mois` (n = 1, **à ajouter**) | dans 1 mois | 3 | accord singulier |
| `ce_mois` | ce mois-ci | 2 | |

Exemple : « Projet : la Super 5, avril 1986 (dans 14 mois) · 30 000 F ». Jamais de complément du type « placement suggéré » (A33).

---

## 5. Conséquences (mineures, inchangées sauf une)

| Clé | Texte | Verdict |
|---|---|---|
| `consequence_choix` | C'est décidé : {court}, pour {echeance}. | Conservé |
| `consequence_realise` | {nom} : c'est fait ! | Conservé |
| `consequence_reporte` | Reporté à {echeance}. | Conservé |
| `consequence_abandonne` | Projet abandonné. | Conservé ; les répliques de Sylvie relèvent du game designer (G4) |

---

## 6. Récapitulatif des demandes au chef de projet

1. Trancher R1 : rentabilité annualisée (variante B) ou non (variante A, actuelle dans `projets.json`).
2. Remplacer le `sous` de P2C (40 mots) par le texte du §2.
3. Ajouter les clés : `echeance_texte_suffisant`, `pel_apres`, `action_perte`, `guichet_reporte`, pluriel de `dans_mois`.
4. Afficher la pénalité PEL dans la liste des ventes avant confirmation (R2).
5. Écrire « Livret A » dans le jeu ; « Livret bleu » seulement en glossaire (§1.2).
6. Rappeler la bulle « Simplifié : à l'époque, les petites ventes étaient souvent exonérées. » sur les lignes SICAV et actions.
