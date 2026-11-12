# 23 : Réponses du game designer pour la vague 3 (G1, G2, G3, picto « fâchée »)

> 2026-11-12. Base : docs/15 §2, `lot_03.md` §12 (D15), `feuille_de_route.md` §2.8, `godot/data/foyer.json` (état de `lot/03-foyer`).
> Tout se règle **en données** dans `foyer.json` (aucun changement de code demandé, sauf G3 et une option de G1 signalée).
> Règles d'écriture tenues : titres ≤ 5 mots, textes ≤ 30 mots, aucun montant en dur (gabarits `{prix_a}`, `{prenoms}`), narration au **vous**, aucun « auriez dû / devriez / conseil », aucun jugement sur dépenser ou épargner.

---

## G1. Textes

### G1.1 Règle de voix de Sylvie
- Les répliques sont des **phrases de Sylvie, sans s'adresser à personne** (ni « tu » ni « vous ») : on évite le conflit entre le vouvoiement du joueur et le tutoiement naturel d'un couple.
- 2 à 8 mots. Humour léger, jamais de reproche sur l'argent : elle réagit à **la chose** (le fauteuil, la tente, Vierzon), pas au fait d'avoir dépensé ou épargné.
- Pas de gabarit dans les répliques (pas de `{prenoms}`), pour ne pas dépendre d'une substitution que le moteur ne fait peut-être pas sur ce champ.

### G1.2 Répliques (une par choix : 32, à mettre dans `cartes.Cxx.a/b.replique`)
Rappel du contrat : la réplique sert de **ligne de conséquence** pour un choix qui épargne et de **« dernière cause »** dans « Mon foyer » pour tous les choix. Humeur = effet du choix (+1 contente, 0 neutre, −1 fâchée).

| Carte | Choix | Humeur | Réplique |
|---|---|---|---|
| C00 | a Partir à Deauville | → 0 | Deauville, c'était merveilleux ! *(inchangée)* |
| C00 | b Faire profil bas | 0 | Je ne boude pas. Je réfléchis. |
| C01 | a Club Med | +1 | Agadir, quel rêve ! *(inchangée)* |
| C01 | b Camping à Palavas | −1 | Encore Palavas… *(inchangée)* |
| C02 | a L'acheter | +1 | Ce soir, on enregistre « Dallas » ! |
| C02 | b Attendre | −1 | Encore un épisode de raté… |
| C03 | a S'abonner | +1 | Un film le samedi soir, enfin ! |
| C03 | b Trois chaînes | −1 | Trois chaînes, et rien à voir. |
| C04 | a La neuve | +1 | Elle roule comme un nuage ! |
| C04 | b Celle de la cousine | 0 | Elle a servi, elle servira encore. |
| C05 | a Grande fête | +1 | Toute la famille réunie, c'était beau. |
| C05 | b Repas en famille | 0 | Un bon repas, c'est l'essentiel. |
| C06 | a Prêter | +1 | Patrick va être tellement content ! |
| C06 | b Refuser poliment | −1 | Mon propre frère… |
| C07 | a S'inscrire | −1 | Deux soirs par semaine seule à la maison… |
| C07 | b Pas cette année | 0 | L'an prochain, peut-être. |
| C08 | a Participer | +1 | Maman a pleuré de joie. |
| C08 | b Carte et fleurs | −1 | Des fleurs… pour trente ans. |
| C09 | a L'acheter | +1 | On gardera tout en souvenir ! |
| C09 | b Le louer en août | 0 | Deux semaines de film, c'est déjà bien. |
| C10 | a Élevage | +1 | Il est magnifique ! |
| C10 | b SPA | +1 | Je crois que c'est lui qui nous a choisis. |
| C11 | a L'île de Ré | +1 | L'île de Ré, c'était parfait ! *(inchangée)* |
| C11 | b Vierzon | −1 | Vierzon. En août. Encore. |
| C12 | a L'inscrire | +1 | Ma sœur n'en revient pas ! |
| C12 | b Courir au parc | 0 | Au parc, au moins, il y a des canards. |
| C13 | a Camping-car | +1 | On s'arrête où on veut ! |
| C13 | b La tente | −1 | La tente prend toujours l'eau… |
| C14 | a Tout vendre | −1 | Pas mon fauteuil ! *(inchangée)* |
| C14 | b On garde tout | +1 | Mon fauteuil reste avec moi ! |
| C15 | a Partir | +1 | La neige, enfin ! |
| C15 | b La luge au parc | −1 | La luge au parc… vraiment ? |

« Dallas » : diffusé en France de 1981 à 1991 (certitude B) ; si le client préfère ne pas citer de marque ou de série, remplacer par « Ce soir, on enregistre mon feuilleton ! ».

### G1.3 Lignes après un choix « placement » ou « revenu » (pas de coût d'opportunité, docs/15 §2.2)
- C06 a (Prêter) : la réplique « Patrick va être tellement content ! ». Rien d'autre : la leçon arrive 9 mois plus tard (notification des escargots, inchangée).
- C14 a (Tout vendre) : `+ {montant} sur votre compte. « Pas mon fauteuil ! »` ; si le moteur n'assemble pas ces deux parties, la réplique seule suffit (le montant est déjà sur le bouton).

### G1.4 Bulles d'humeur et phrases

`notif_humeur` (bulle de 4 s à la fenêtre, puis notification ou historique ; 3e personne, lisible hors contexte dans l'historique) :

| Clé | Texte | Avis |
|---|---|---|
| `contente` | Sylvie est ravie | validé |
| `neutre` (en remontant de fâchée) | **Sylvie se radoucit** | remplace « Sylvie va mieux » (on sort d'une bouderie, pas d'une maladie) |
| `neutre_depuis_contente` | Sylvie va bien | **validé** (C-FO3) : neutre, sans reproche ; c'est l'usure de janvier ou un choix à −1 |
| `fachee` | Sylvie fait la tête | validé |

`phrases` (« Mon foyer ») : « Sylvie est contente » / « Sylvie va bien » / « Sylvie fait la tête » : validées. `cause_naissance` « Un bébé à la maison ! » : validée.

### G1.5 Textes des cartes (prix du banquier dans `prix_F`, jamais dans le texte)

| Carte | Champ | Texte (≤ 30 mots) |
|---|---|---|
| C02 | `texte` | Chez Darty, un magnétoscope VHS : {prix_a}. Sylvie ne veut plus rater un épisode de « Dallas ». |
| C04 | `texte` | Une poussette neuve, grand modèle : {prix_a}. La cousine prête la sienne, un peu usée mais solide. |
| C04 | `texte_jumeaux` | Une poussette double neuve : {prix_a}. La cousine prête la sienne, une double aussi, un peu usée mais solide. |
| C07 | `texte` | Le CNAM propose une formation du soir pour les techniciens : {prix_a}, deux soirs par semaine pendant un an. Avec le diplôme, une promotion devient possible. |
| C09 | `texte` | Un caméscope pour filmer {prenoms} : {prix_a}. Le photographe du quartier en loue un pour les vacances. |
| C10 | `texte` (un enfant) | {prenoms} ne quitte plus le chien des voisins, et Sylvie en a toujours rêvé. Un labrador d'élevage, ou un chien de la SPA ? |
| C10 | `texte_jumeaux` | {prenoms} ne quittent plus le chien des voisins, et Sylvie en a toujours rêvé. Un labrador d'élevage, ou un chien de la SPA ? |
| C10 | repli sans enfant (si un jour la naissance n'est plus scriptée) | Sylvie a toujours rêvé d'un chien. Un labrador d'élevage, ou un chien de la SPA ? |

- **C10 (m4 de la recette)** : ajouter `"requiert_enfant": true` et le `texte_jumeaux` ci-dessus. La naissance est scriptée en 04/1985, donc en 03/1987 il y a toujours un enfant de 2 ans (ou des jumeaux) : aucune carte perdue. Le repli sans enfant n'est utile que si le moteur ne sait pas gérer `requiert_enfant` sur C10 ; dans ce cas, le mettre en `texte` et ne pas utiliser `{prenoms}`.
- **C07** : la phrase « une promotion devient possible » annonce l'effet salaire (+4 % en 01/1988) sans le chiffrer ni le garantir : pas de piège (le joueur voit qu'il y a un enjeu au-delà de l'humeur −1), cohérent avec le « pourquoi » (« sans garantie »). 27 mots.
- **C09** : sans « premiers pas » (l'enfant a déjà 2 ans en 1987) ; aucun accord à faire.
- Libellés des boutons : inchangés.
- Hors de mon champ (report 5, m2) : le « pourquoi » de C03 avec « 120 F par mois font 1 440 F par an » relève du banquier. Proposition si besoin d'un repli sans chiffre : « Un abonnement revient chaque mois : sur plusieurs années, il coûte bien plus que son premier prix. »

---

## G2. Usure de l'humeur seulement quand elle est positive (D15) : **VALIDÉE**, sans changement

Mesures : C00 jouée dans 40/40 graines `epargner`, 9/40 `alterner`, 2/40 `depenser`.

1. **C'est exactement la courbe voulue.** La fourmi voit toujours la réconciliation (la leçon « blindée mais seule », fin n° 4) ; l'alternance la voit une partie sur quatre environ (surprise, rejouabilité) ; la cigale presque jamais. Plus on épargne systématiquement, plus le coût humain apparaît : c'est la seule conséquence de l'humeur, elle doit être visible là où elle enseigne.
2. **La rancune qui attend ne piège pas le joueur économe** : des sorties à +1 existent à 0 F ou presque (C14 « On garde tout » 0 F +1 ; C10 « SPA » +1 à prix modeste ; C04/C05/C09/C12 à 0 F ou peu, neutres), plus la naissance et les projets réalisés (+2). Le joueur voit le picto avant de choisir. Pas de mécanique punitive cachée.
3. **Usure symétrique lente (négatif tous les 2 ans) : rejetée.** Elle rendrait la réconciliation aléatoire pour la fourmi (retour au constat des 25/40), et « la bouderie passe toute seule si on attend » est une mauvaise leçon de jeu (attendre sans décider est récompensé).
4. **Une mesure à ajouter (non bloquante, test seulement)** : dans la ligne `MESURE C00`, imprimer aussi, par politique, le nombre de graines qui **finissent** fâchées et le plus long séjour fâché (en mois). Seuil d'alerte : si une graine `alterner` reste fâchée plus de 24 mois d'affilée, me le signaler (risque de visage boudeur trop long à la fenêtre, perçu comme culpabilisant). Pour `epargner`, finir fâchée est attendu.

Données confirmées : `"erosion_positive": 1, "erosion_negative": 0`. La clé `_erosion` peut perdre « à confirmer par le game designer (G2) » et citer ce document.

---

## G3. Coup dur aléatoire juste après une carte : **le coup dur garde sa pause, VALIDÉ**, avec une préférence

**Validé** : un coup dur (panne de voiture d'octobre 1985…) ne devient **jamais** une simple notification à cause d'une carte. C'est un événement subi, qui coûte de l'argent et enseigne l'épargne de précaution ; sans pause, le joueur le rate (retour au « jeu qui se joue seul »). La carte est un choix de confort : c'est elle qui cède.

**Préférence (à faire si le calendrier des coups durs est tiré au démarrage par la graine de vie, ce que je crois)** : traiter les coups durs déjà tirés comme des **interruptions datées** dans le placement des créneaux. La règle existante « pas de carte le mois avant une interruption datée » s'applique alors aussi à eux : la carte glisse ailleurs **dans sa fenêtre** (le plus tardif d'abord), comme aujourd'hui. Invisible pour le joueur, pas d'annonce (A5 respecté : rien du marché, et la carte ne trahit rien).

**Si aucun mois libre dans la fenêtre** (ou si un coup dur n'est connu qu'au dernier moment) :
- ordre de préférence : (1) la carte glisse dans sa fenêtre ; (2) sinon le créneau est **abandonné** (compté comme aujourd'hui, ce qui protège aussi la cible de 20 min) ; (3) jamais de coup dur rétrogradé.
- Si la carte est **déjà jouée** quand le coup dur tombe le mois suivant : on accepte **exceptionnellement deux mois de suite** (même dérogation que krach → panne). Effet pédagogique positif et non culpabilisant : « dépense choisie, puis dépense subie » montre à quoi sert un matelas, et la ligne de la carte était au conditionnel.

CA proposé pour 04-L : sur 40 graines × 3 politiques, aucun coup dur aléatoire n'est une notification sans pause ; les cas « carte puis coup dur le mois suivant » sont comptés et imprimés (attendu : 0 si le calendrier est connu au départ).

---

## Picto « fâchée » : sourcils en V

**Avis : garder le V, mais un V doux, et ajouter le regard de côté.**
- À 16 × 16, le V est le seul indice de colère lisible sans couleur : on le garde (écart de dev-interface à docs/17 §4.1 accepté).
- Mais Sylvie **fait la tête**, elle n'est pas furieuse : un V profond la rend hostile, et une épouse qui vous fusille du regard à chaque bouton « épargner » pousse à la culpabilisation (garde-fou 14 §6.3). Le V doit tomber d'**1 px seulement** (extrémité intérieure 1 px plus bas que l'extérieure), pas davantage.
- Ajouter, si la place le permet, les **pupilles décalées d'1 px du même côté** (comme à la fenêtre, docs/17 §4.2 : « elle regarde ailleurs ») : c'est ce qui dit « bouderie » plutôt que « colère », et ça reste lisible sans couleur.
- Garder la bouche en arc tombant (moue), cohérente avec le libellé « moue » de docs/15 §2.2.
- À faire valider par l'UX sur une capture à ×1 (téléphone 720p) et ×3 ; si le V d'1 px ne se distingue plus du neutre à ×1, revenir au V actuel plutôt que de perdre la lisibilité.
