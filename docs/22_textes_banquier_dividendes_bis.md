# Textes du banquier, complément du lot 03 (reports 2, 5 et 6)

> Auteur : banquier. Date : 2026-11-12. Contenu pédagogique, sans conseil d'investissement. Tous les textes ≤ 30 mots (comptés, « % » et « : » non comptés).
> Certitude : **A** fait vérifié, **B** probable, **C** convention de jeu ou formulation reconstituée. Les textes eux-mêmes sont des propositions de rédaction (pas de chiffre historique en dur, sauf mention).
> Complète `docs/21_contenu_banquier_dividendes.md`. Placeholders : `{xxx}` à substituer par le code.

## 1. Fiche d'une action : ligne « dividende » (report 2)

Problème : « Dividende versé chaque année en mai » est faux pour Peugeot l'année sans dividende. Principe : la fiche décrit la règle, pas le résultat d'une année ; l'année concrète est dite par la notification (« Pas de dividende cette année »).

| Option | Texte | Mots | Remarque |
|---|---|---|---|
| **Recommandée** | `Dividende : versé en mai, si l'entreprise en distribue cette année-là.` | 11 | Vrai toutes les années, une seule ligne, aucune prévision. |
| Alternative pédagogique | `Dividende : une part des bénéfices, versée en mai quand l'entreprise en distribue. Il peut varier ou manquer.` | 18 | Définit le mot ; à réserver à la fiche de la première action rencontrée (« une notion = un moment »). |
| Alternative courte | `Dividende : en mai, non garanti.` | 5 | Pour un encart étroit (téléphone). |

Certitude : le principe (le dividende est voté chaque année par l'assemblée générale, jamais garanti) = **A**. Le mois de mai = convention de jeu (**C**, docs/03 §7.4 : « dividendes versés en mai »). Éviter « chaque année », « régulier » et « toujours » dans toute fiche : seules les années sans dividende le démentent.

Pour les actions qui n'ont jamais manqué de dividende sur la période, la même phrase reste exacte : ne pas faire de variante par titre (évite de révéler l'avenir d'un titre).

## 2. Relevé de décembre : aucun intérêt mais des dividendes (report 6)

Problème : « Aucun intérêt cette année : votre argent est resté sur le compte courant. » puis « Vos actions vous ont versé 196 F… » se contredisent en apparence (le joueur a bien reçu de l'argent). Cause : la phrase « aucun intérêt » parle des intérêts de placements d'épargne, pas des dividendes. Solution : trois cas à distinguer par le code, chacun avec sa phrase unique.

| Cas (intérêts / dividendes de l'année) | Texte | Mots |
|---|---|---|
| Aucun intérêt, aucun dividende (cas actuel) | `Aucun intérêt cette année : votre argent est resté sur le compte courant, qui ne rapporte rien.` | 16 |
| **Aucun intérêt, dividendes > 0** | `Votre épargne n'a produit aucun intérêt, mais vos actions vous ont versé {dividendes} de dividendes cette année, après impôt.` | 20 |
| Intérêts > 0, aucun dividende | texte actuel des intérêts, sans phrase sur les dividendes | (inchangé) |
| Intérêts > 0 et dividendes > 0 | texte actuel des intérêts, puis `Vos actions vous ont versé {dividendes} de dividendes cette année, après impôt.` (12 mots, docs/21 §K2) | 12 |

Règles de mise en forme :
- Dans le 2e cas, **une seule phrase** (pas deux lignes qui se contredisent) ; le code ne doit jamais afficher « Aucun intérêt cette année » quand `dividendes` > 0.
- Variante plus sobre pour le 2e cas, si la formulation « n'a produit aucun intérêt » paraît trop sévère : `Pas d'intérêts cette année, mais {dividendes} de dividendes versés par vos actions, après impôt.` (14 mots).
- Distinction à garder visible en bulle (?) si le client veut la pédagogie : un intérêt rémunère un prêt (Livret A, obligation, PEL) ; un dividende rémunère une part d'entreprise. Texte de bulle proposé (A) : `Intérêt : le prix d'un prêt, fixé d'avance. Dividende : une part des bénéfices, décidée chaque année par l'entreprise.` (19 mots).
- Pas de « avoir fiscal » ici ; la phrase de docs/21 §1.2 reste réservée au 1er dividende.

## 3. Foyer : relecture de C03, C10 et C02 (report 5, questions m2 et m4)

Constats sur `godot/data/foyer.json` (lu le 2026-11-12) :
- **C03** : le « pourquoi » dit « 120 F par mois font 1 440 F par an » : montant en dur (contraire à la règle du fichier : « aucun montant écrit en dur »), et il ne colle pas au prix du choix (1 800 F = décodeur + un an). Fait d'époque : abonnement Canal+ 120 F/mois (**B**, Larousse 1985 ; une source donne 140 F), caution du décodeur ≈ 420 F (**B**), lancement le 04/11/1984 (**A**) : 12 × 120 + 420 = 1 860 F, d'où l'ordre de grandeur de 1 800 F (**C**).
- **C10** : « Les enfants réclament un chien » alors que le foyer peut n'avoir qu'un enfant de 2 ans (et un enfant de 2 ans ne « réclame » guère un labrador d'élevage). La carte n'a pas `requiert_enfant` : elle peut aussi tomber sans enfant. Le texte doit donc marcher pour 0, 1 ou 2 enfants.
- **C02** : texte et pourquoi corrects (prix par gabarit `{prix_a}`). Réserves mineures : « high-tech » est un peu moderne dans la bouche d'un narrateur de 1984 (le mot existait en français dès le début des années 1980, **B**), et « attendre un an » est une affirmation sur l'avenir des prix ; je propose une version plus prudente, facultative.

### 3.1 C03 « Canal+ arrive »

Pas de montant en dur. Deux gabarits possibles pour le « pourquoi » ; le premier n'exige aucun nouveau placeholder.

| Variante | `pourquoi` | Mots | Placeholders |
|---|---|---|---|
| **A, sans chiffre (recommandée)** | `Un abonnement revient chaque mois : sur l'année, la somme est plus lourde qu'elle n'en a l'air au moment de s'engager.` | 22 | aucun |
| B, avec gabarit | `Un abonnement revient chaque mois : ici, {prix_a} la première année, soit environ {prix_a_par_mois} par mois, décodeur compris.` | 21 | `{prix_a}` (existant), `{prix_a_par_mois}` = `prix_a / 12` arrondi (**nouveau**, à fournir par dev-logique) |

Variante B : l'arrondi « environ » est nécessaire (1 800 F / 12 = 150 F, qui n'est pas l'abonnement réel de 120 F : le décodeur est inclus dans le prix). Si le client préfère un chiffre exact et cohérent, préférer la variante A ou bien aligner `prix_F` sur 1 860 F (12 × 120 + 420, **B**) et réécrire : `Un abonnement revient chaque mois : sur douze mois, la facture dépasse largement la mensualité affichée.` (16 mots).

### 3.2 C10 « Le chien »

Texte neutre (sans « enfants »), valable avec 0, 1 ou 2 enfants :

| Variante | `texte` | Mots | Placeholders |
|---|---|---|---|
| **A, neutre (recommandée)** | `Chez vous, on rêve d'un chien. Un labrador d'élevage, ou un chiot de la SPA ?` | 16 | aucun |
| B, avec prénoms | `{prenoms} voudrait bien un chien. Un labrador d'élevage, ou un chiot de la SPA ?` | 15 | `{prenoms}` (existant, utilisé par C05) ; **accord du verbe à régler** : « voudrait » (1 enfant) ou « voudraient » (jumeaux), donc deux gabarits ou la variante A |
| C, avec `requiert_enfant` | texte actuel conservé, carte jouée seulement s'il y a au moins un enfant, et au pluriel seulement avec des jumeaux : `texte` = `Votre fils réclame un chien…` / `texte_jumeaux` = `Les enfants réclament un chien…` | 14 | exige de connaître le sexe ou d'utiliser « votre enfant » : `Votre enfant réclame un chien. Un labrador d'élevage, ou un chiot de la SPA ?` (16 mots) |

Recommandation : variante A (aucune dépendance au foyer, le moins de code). `pourquoi` sans chiffre vague ni montant :

> `Le prix d'achat n'est qu'une partie du coût : nourriture, vétérinaire et assurance reviennent chaque année.` (16 mots)

Certitude : conseil de fond sans chiffre, **A** (coût récurrent d'un animal). L'actuel « plusieurs milliers de francs par an » est un ordre de grandeur non vérifié (**C**) : à retirer.

Remarque de cohérence : avec un enfant de 2 ans en 1987, la variante A évite l'anachronisme psychologique d'un tout-petit qui « réclame » un chien.

### 3.3 C02 « Le magnétoscope » (relecture, modifications facultatives)

| Élément | Actuel | Variante proposée | Mots |
|---|---|---|---|
| `pourquoi` | `Les prix du high-tech baissent vite : attendre un an peut coûter moins cher, mais on perd un an d'usage.` | `Un appareil neuf perd vite de sa valeur et son prix baisse souvent : attendre peut coûter moins cher, mais on y perd des soirées.` | 24 |
| `texte` | `Chez Darty, un magnétoscope VHS : {prix_a}. Sylvie veut enregistrer ses feuilletons.` | inchangé (16 mots, un seul gabarit, pas de montant en dur) | 14 |

Certitude : Darty et le VHS en 1984-1987 = **A/B** (VHS dominant face au Bétamax en France dès le milieu des années 1980 ; prix 5 500 F = **C**, voir docs/18). La variante `pourquoi` supprime l'anglicisme et la promesse de baisse « d'un an » ; elle reste vraie sans prévision précise.

## 4. Points à faire valider

- Le client doit trancher C03 : variante A (aucun chiffre) ou B (nouveau placeholder `{prix_a_par_mois}`) ; ma préférence est A pour garder `test_foyer` simple.
- Le contrôle `test_foyer` demandé au report 5 doit aussi balayer les `pourquoi` à la recherche de chiffres (regex `\d`) : les trois propositions ci-dessus le satisfont (hors gabarits entre accolades).
- Le prix du décodeur et de l'abonnement Canal+ reste **B** (une source de 1985 ; une autre dit 140 F) : ne rien afficher de plus précis que « environ ».
