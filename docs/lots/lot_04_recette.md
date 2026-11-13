# Lot 04 : recettes

## 03-V2 (recette courte, 2026-11-13) : `lot/03-ville2`, commit testé 47c00e2

**Verdict : OK** (0 anomalie bloquante ou majeure ; 2 mineures).

Critères : `lot_04.md` §12.2 (recette courte, CA-V1 à V5). Worktree `lot03-ville2`, machine libre pour les mesures (aucun test lancé pendant la série de captures).

### Critères d'acceptation

- [x] **CA-V1 ★** : `tests.ps1 -Recette` code 0, **755 vérifications OK, 0 KO, 0 erreur de script** (main = 725) ; `test_pieces` 62, `test_rue` 102. Tests des parties gardées : les 17 règles de D11 pour les traces dessinées (`TRACES_DESSINEES` n'existe pas sous ce nom : ce sont `TRACES.ORDRE` et `ville.traces_dessinees()`) sont dans `test_pieces._tests_traces` (cartes éteintes = vide, y compris carte inscrite) ; `suivre_foyer` cartes éteintes = Sylvie neutre, aucune trace, dans `test_rue`. Contrôle de recette : un test de plus de ma part (ci-dessous) : 11 vérifications.
- [x] **CA-V2 ★ (routage)** :
  - `carte_sortie` : `RUE carte sortie=0.61 porte=3 carte=courrier`, `RUE carte affichee genre=courrier modales_carte=non choix=a`, `RUE carte suite … modale=vide mois_suivant=oui choisie=a` : repli courrier, la partie continue, sortie 0,61 s (≤ 1 s).
  - Mon `tests/recette/test_recette_routage.gd` (3 passages, 11 OK à chaque fois) : carte réelle (sortie 0,61 s, choix, partie qui avance) ; contenu `kind "projet"` et contenu `kind "gazette"` (modèle : un vrai courrier de vie dont on change le kind ; le moteur de cette branche ne produit pas ces kinds) : ouvrent le **courrier** (`genre_courant == "courrier"`), la séquence se termine, la ville redevient interactive, la partie avance au mois suivant.
  - Écart de forme : la ligne attendue `RUE fiche kind=carte appel=courrier` n'existe pas ; l'équivalent imprimé est `RUE carte … carte=courrier` (voir mineure M1).
- [x] **CA-V3 ★** : `capture_ville.ps1 -Serie` complète, **84 lancements, code 0, « PX1 : tout est vert »**, 0 échec, 0 SCRIPT ERROR / Parse Error, `hors_palette=0`, `irreguliers=0` partout. `RUE flottant indice=0 chevauchements=0` : 20 occurrences (étapes `pieces_*` PC 1920 × 1080, téléphone 1440 × 648 et téléphone 1280 × 720), aucune non nulle. Journal : `godot/captures/px1_serie.log` (ignoré par Git).
- [x] **CA-V4** : `sylvie_humeurs` (PC `_h0/_h1/_h2` et 1440 × 648 `_tel_h0/_h1/_h2`) relues : contente (sourire, coudes écartés), neutre (visage calme), contrariée (sourcils froncés, bras croisés) se distinguent à PC ; à 1440 × 648 la distinction sourire / froncé reste lisible, la posture moins (petit). Pas d'exigence de ×1.
- [x] **CA-V5 ★ (périmètre)** : `git diff --stat main...lot/03-ville2` : 15 fichiers, tous dans la colonne 03-V2 du §3 (`scripts/ville/*`, `scripts/pixel/personnages.gd` et `voisins.gd`, `scenarios/ville.gd`, `capture_ville.ps1`, `test_pieces`, `test_rue`, `dev-ville.md`) ; rien d'`outils/`, de capture ou de secret. API : une seule ligne `-func` supprimée, `Personnages.sylvie(humeur)` devenue `sylvie(humeur, coucou := 0)` (paramètre optionnel : compatible). `lot/03-ville2` et `lot/03-ville2-suite` : **aucune des deux n'est sur `origin`** (`ls-remote --heads`) ; la branche `-suite` n'existe pas non plus en local (rien de non fini mis de côté, ou non créée : à confirmer par le compte rendu).
- Sauvegarde du joueur : `partie_en_cours.sav` **absent** avant, pendant (tests.ps1 : « inchangée (absente) ») et après. Dépôt principal : mes seules écritures sont dans le worktree (test de recette + ce rapport).

### Relecture des images (PC et 1440 × 648)
- `carte_sortie` `_porte` (porte à demi ouverte, caméra revenue sur la maison) et `_carte` (courrier « Les vacances 84 », deux choix) : corrects, pas de débordement.
- `pieces_or_cuivre_tel_cartouches` : « + 312 F ce mois-ci / versés en décembre », « Elf : + 840 F », « − 45 F de frais » : plus de mélange intérêts / dividendes, cartouches ni superposés ni sur le panneau INDICE ni sur les piles.

### Anomalies (mineures)
- **M1** (mineure) : la ligne de contrôle `RUE fiche kind=… appel=courrier` demandée par CA-V2 n'est pas imprimée ; le dev-ville imprime `RUE carte sortie=… carte=courrier`. Le routage `projet` / `gazette` n'a pas de trace dans le journal des captures (seul mon test le prouve). Aucun effet pour le joueur.
- **M2** (mineure, informative) : un contenu `projet` ou `gazette` passe par la séquence courrier complète (enveloppe) : 1,86 s avant l'ouverture, contre 0,61 s pour la carte. Le « ≤ 1 s » ne vaut que pour la sortie de la carte ; à reprendre quand les projets auront leur sortie (04-V).

### Non vérifié
- Ressenti en mouvement (clignement, coucou, transition d'humeur) : seules les images fixes ont été relues ; vrai téléphone.
- `traces_foyer` sur une partie entière (étape retirée du périmètre ; la série n'en contient qu'une partie à graine fixe) ; l'aspect dessiné de `diplome` et `escargot` (façade) n'a pas été relu à l'image.
- Fusion avec 03-R / 04-L : non simulée (§12.1).

## 04-L (recette, 2026-11-13) : `lot/04-logique`, commit testé 9a90a60

**Verdict : OK.** Aucune anomalie bloquante ni majeure ; 5 mineures / informations (§ Anomalies). Recette allégée de la version jouable (KO seulement : test rouge, partie bloquée, chiffre faux, sauvegarde ou contrat cassés, règle pédagogique violée, information cachée, fichier hors périmètre) : aucun de ces cas constaté.

### Résultats automatiques
- `tests.ps1 -Recette` : **831 vérifications OK, 0 KO, 0 erreur de script, import propre, « TOUT EST PROPRE »** (167 s). Sans `-Recette` : 749 OK (le compte rendu du développeur annonçait 706 : l'écart vient de la fusion de 03-V2, sans conséquence). Premier passage : 830 OK + 1 KO = `test_recette_foyer` FO2, le KO **attendu** (§13.2) ; voir ci-dessous.
- Adaptation de ma recette (`godot/tests/recette/test_recette_foyer.gd`, commitée avec ce rapport) : FO2 admet « carte → vie » (une interruption « vie » au mois qui suit une carte) et rien d'autre ; la règle « rien la veille d'une interruption datée » exclut le cas « vie ». Résultat : 19 OK, 0 KO ; 120 parties (graines 1 à 40 × 3 politiques) : 9,70 cartes en moyenne (8 : 4 parties, 9 : 28, 10 : 88) ; `carte → vie` 20 cas sur 120 parties (au plus 1 par partie), les autres enchaînements de deux mois restent `marche:p1e6 → vie:voiture` (120) seulement.
- `test_interface` et `test_partie` : absents du diff (`git diff main...HEAD --stat`), verts (39 et 8).
- `partie_en_cours.sav` du joueur : **absent avant, pendant et après** (`tests.ps1` : « inchangée (absente) ») ; aucun `user://` du joueur touché (copie de `main` en `custom_user_dir`, supprimée).

### Mesures indépendantes (script `testeur_l04_mesures.gd`, graines 101 à 140, différentes de celles du développeur ; boucle propre qui OBSERVE chaque modale)
| Mesure | Résultat |
|---|---|
| Parties projets + cartes allumés, 3 politiques de cartes × 40 graines (politique de projets variée) | **120 parties finies, 0 blocage** (observation modale par modale) |
| Cartes par partie | 8 : 19, 9 : 39, 10 : 62 ; **7 cartes : 0 sur 120** (critère : 7 à 10, au plus 2 à 7) |
| Projets (modales) par partie | 4 : 9, 5 : 71, 6 : 40 ; max 6 (budget `projets` = 6) |
| Choix du projet 1 / projet 2 | projet 1 en 03/1984 ± 1 mois, projet 2 en 01-02/1987, **120 / 120**, 2 choix par partie, jamais deux projets en cours |
| Cadence | une interruption par mois au plus ; jamais deux mois de suite hors `marché → panne` et `carte → vie` ; rappel : au plus 2 `projet_rappel` par partie |
| **Calibrage** (passif « tout au Livret A », cartes `epargner`, P1C puis P2B ; disponible ≥ montant au jour J) | **P1C 100 %, P2B 100 %** sur 33 graines sans jumeaux (40 graines : 100 % / 100 %) ; développeur, graines 1 à 40 : 100 % / 87 % ; cibles ≥ 80 % et ≥ 60 % **tenues** |
| Données | P2B = 35 000 F dans `projets.json` (échéance 02/1988 inchangée), P2C 90 000 F ; aucun texte ne contient « 40 000 » (seule la note `_montant`, voulue par le plan §13.1) |
| `carte_puis_vie` (informatif) | 8 cas sur 120 parties (graines 101-140), 8 parties concernées, max 1 par partie (développeur : 20 sur 120, max 1) ; seuil de signalement (> 1 par partie) non atteint |
| Références **éteintes** (défaut) | graine 7 actif **172 139,25 F / 869,97 F / 11 interruptions / dividendes 360,43 F** ; passif **145 655,67 F** : identiques à `main` ; 20 graines × 2 stratégies : aucune modale `projet` ni `carte`, aucun rappel, parties finies |
| Cartes allumées, projets éteints | aucune modale `projet`, partie finie |
| Tout allumé, graine 7 actif | partie finie, patrimoine 138 615,22 F (nouvelle mesure, pas une référence), projets P1A et P2A réalisés |
| Sauvegarde au milieu d'un projet (P1C, avril 1986) | `projet_en_cours()` identique après rechargement ; les deux parties finissent au même patrimoine (129 945,00 F) et mêmes projets passés |
| Sauvegarde sans champ `projets` (0.4.x) | rechargée, projets éteints, va à la fin |

### Vente automatique (règle inchangée : décision du joueur du 13/11, `feuille_de_route.md` §2.11)
Règle lue dans `projets.gd` et `projets.json` : compte courant, Livret A, puis les placements du moins rentable au plus rentable (rentabilité non annualisée = (net de revente − versé) / versé, frais, impôts et pénalités déduits ; égalité : la plus grosse ligne), juste ce qu'il faut (dernière ligne partielle), PEL en entier, aucune vente décidée à la place du joueur (`resolution_auto` au jour J ne vend pas : vérifié). Elle correspond au commit `dbb9de0` du chef de projet ; aucune modification de la règle dans le diff.
Recalcul indépendant (ordre recalculé dans mon script avec les devis du moteur, besoin de 35 000 F − 3 000 F = 32 000 F ; compte 2 000 F + Livret A 1 000 F) :
- **Cas 1** (SICAV 20 000 F pour 14 000 F versés, assurance-vie 9 000 F pour 8 000 F, PEL 10 000 F pour 9 000 F à 20 mois) : rentabilités PEL 3,7 % < AV 9,4 % < SICAV 36,0 % ; ordre du moteur `pel, av, sicav` = ordre recalculé ; nets 32 000,00 F ; ventes faites = plan ; compte et Livret A à 0,00 F (jamais négatifs).
- **Cas 2** (SICAV à perte : 20 000 F pour 30 000 F versés, mêmes AV et PEL) : SICAV −33,3 % part la première, puis PEL, AV ; ordre moteur = ordre recalculé ; nets 32 000,00 F ; compte et Livret A à 0,00 F.
- Dans les deux cas, « juste ce qu'il faut » : sans la dernière ligne, les ventes ne suffiraient pas ; total final = disponible + reçu − 35 000 F.
Le test du développeur recalcule de son côté 2 cas (SICAV à perte, PEL clos avant 4 ans) : verts.

### Critères d'acceptation (lot_04.md §7.1, avec l'arbitrage §13)
- [x] **CA-L1** tests : 831 OK avec `-Recette`, 0 erreur de script ; total ≥ `main` ; `test_interface` / `test_partie` inchangés et verts.
- [x] **CA-L2** invariant D1 : `test_projets` (8 ordres débiteurs refusés `refus « carte »` avec la phrase, compte et lignes inchangés ; ventes, retrait, arrêt d'un versement permis ; témoins non concernés ; `ordres_bloques()` faux sans carte, vrai pour un projet) ; `RECETTE blocage` rejoué par ma recette : `resolution_auto` rend « Pas les moyens ce mois-ci », la carte se ferme, la partie va à décembre 1988 (par `avancer`, et par `Partie.sauter_jusqu_a` dans le test du développeur : autoload accessible) ; `resoudre_modale("aucun")` refusé quand un choix est payable. Ma recette ne rejouait pas la partie après blocage : vérifié par le test du développeur et par mon observation des 120 parties (aucune bloquée).
- [x] **CA-L3** coup dur (arbitrage A3) : `vie_retrogradee=0` (test du développeur, graines 1 à 40 × 3 politiques) ; `carte_puis_vie` informatif, max 1 par partie. Voir M1 pour ma mesure littérale sur d'autres graines.
- [x] **CA-L4** textes : 32 répliques (comptées par mon script), aucun chiffre hors gabarit dans `texte`, `texte_jumeaux`, `pourquoi` ; « Sylvie se radoucit » ; C10 `requiert_enfant` + `texte_jumeaux` ; C14 « a » = `consequence_revenu` « + {montant} sur votre compte. « {replique} » » ; `MESURE C00` imprimée par politique (epargner : 40 / 40, fâchées en fin 40, plus long séjour 35 mois ; depenser : 3 / 40 ; alterner : 3 / 40) ; aucune ligne `ALERTE`. Réserve : voir M2 (9 mots).
- [x] **CA-L5** projets : dates, jamais deux en cours, calibrage ≥ 80 % / ≥ 60 % (100 % / 100 % chez moi, 100 % / 87 % chez le développeur), vente dans l'ordre D7 bis (2 cas recalculés), sauvegarde au milieu d'un projet, rappel, témoins : vérifiés par `test_projets` (44 OK) ; mes mesures : dates, calibrage, ventes, sauvegarde. Non rejoués à la main : humeur +2 / +1 / −1 / −2, `ligne_projet_guichet()`, apport P2C dans le patrimoine (tests du développeur verts, lus seulement).
- [x] **CA-L6** cadence projets allumés : 7 à 10 cartes (0 partie à 7 sur mes 120 ; `cartes7=2/120` chez le développeur, limite 2 respectée), projets ≤ 6, pas de mois double ni de suite hors exceptions ; S7 / S10 : testés par le développeur (verts).
- [x] **CA-L7** éteint par défaut : références identiques (172 139,25 F / 869,97 F / 11 / 360,43 F ; passif 145 655,67 F), aucune modale `projet` ni rappel sur 20 graines × 2 stratégies (mes mesures) et 40 × 2 (test). Les références d'`integrale` / `integrale_saut` (161 419 F) relèvent des captures d'interface : non rejouées (aucun fichier d'interface touché, `test_interface` vert).
- [x] **CA-L8** contrat : champs de `contenu_modale()` et `projet_en_cours()` énumérés par `test_projets` (vert). Diff de `scripts/logique/` : seules lignes `func` retirées = trois fonctions **privées** de remplissage posées par 03-foyer (`Foyer._projet_choisi`, `Foyer._echeance_projet_en`, `Cadence._bloque`) et remplacées ; aucune fonction publique, signal, var ou const existants retirés ; `partie.gd` inchangé.
- [x] **CA-L9** périmètre : `git diff main...HEAD --stat` = 18 fichiers, tous dans la colonne 04-L (`scripts/logique/*`, `data/foyer|projets|rythme.json`, `tests/test_{cadence,foyer,projets}.*`, `export_presets.cfg`, `docs/connaissances/{dev-logique,developpeur}.md`) sauf le `.uid` de ma recette (M3). `export_presets.cfg` : `0.5.0.0` ×2, « 0.5 », code 6, rien d'autre.

### Anomalies
- **M1** (mineure, information pour le chef de projet) : ma mesure **littérale** de `vie_retrogradee` (même graine, même événement de vie : modale cartes éteintes, notification cartes allumées) donne **3 événements sur 159** comparés (graines 101 à 140, projets éteints), tous la **graine 129**, les 3 politiques : l'événement « Frais de dentiste » (3 596 F, calendrier mois 85) ouvre un courrier cartes éteintes et une simple notification cartes allumées. Cause relevée à la trace (mois, compte, calendrier) : cartes allumées, la carte C03 prend le mois 84 et la présentation D05 glisse de 84 à 91 ; le joueur actif n'a donc pas acheté le produit de D05 au mois 84, son compte courant tient 4 877 F à l'entrée du mois 85 (contre 2 020 F cartes éteintes) et l'événement passe en notification par la règle de toujours (`courrier = montant > seuil ou compte < montant`). Ce n'est pas la cadence qui rétrograde un événement : mesure dédiée (événements de vie dont le montant dépasse le seuil de courrier et qui finissent en notification) : cartes éteintes 3, cartes allumées 1, cartes + projets 1 sur 120 parties, aucun lié aux cartes (artefacts de seuil). Je ne retiens pas de KO ; à noter si le chef de projet veut une définition de `vie_retrogradee` insensible à l'argent (le test du développeur compare par indice d'événement sur 40 graines : 0). Sur `main`, cette graine ne présente pas le décalage (D05 reste au mois 84).
- **M2** (mineure) : les répliques C10 b (« Je crois que c'est lui qui nous a choisis. ») et C12 b (« Au parc, au moins, il y a des canards. ») ont 9 mots ; le test du développeur a élargi la borne à 10 (texte verbatim de docs/23 G1.2, qui annonce 8) et l'écrit dans le libellé du test. CA-L4 demandait 2 à 8 : écart documenté, texte de l'expert.
- **M3** (mineure) : le diff contient `godot/tests/recette/test_recette_routage.gd.uid` (dossier du testeur ; fichier généré par Godot, ajouté au commit par le développeur) : sans effet, hors colonne 04-L.
- **M4** (mineure, documentaire) : `lot_05.md` D7 bis décrit une rentabilité « annualisée » et un paramètre `projets.json > ordre_vente: "rentabilite" | "fixe"` ; le code applique la rentabilité **non annualisée** (décision du joueur, `feuille_de_route.md` §2.11 et commit `dbb9de0`, « à redéfinir plus tard ») et n'a pas ce paramètre (`_ordre_vente` n'est qu'une note). Conforme à la règle actuelle décidée ; à aligner dans la documentation quand la règle sera redéfinie.
- **M5** (mineure, rappel) : `test_rue` imprime « génération de la rue = 2 000 ms » (seuil 2 s, atteint sous charge : d'autres Godot tournaient en parallèle ; 8,5 s pour l'étape) ; vert aux deux passages, seuil toujours fragile.

### Non vérifié
- Aucune capture ni rendu (04-L ne touche pas l'interface) ; textes des cartes, des projets et des notifications non relus à l'écran (04-I).
- Humeur des projets, `ligne_projet_guichet()`, S7 / S10 et apport P2C : lus dans les tests du développeur, non rejoués par ma propre mesure.
- Partie complète à la main avec projets allumés dans l'interface : impossible tant que 04-I n'allume pas les projets (`projets` éteints par défaut, `_config()` non modifié).
- Questions du joueur (Q-J1 : « Livret bleu », ordre de vente) : en attente de réponse, hors périmètre de la recette.