# 36 : UX de l'extension des années (U1 création de partie, U2 thèmes de décor par décennie)

> Auteur : designer UX. Date : 2026-11-18. Pour : chef de projet (lots 09-V, 10-I, 12-V), puis dev-interface et dev-ville.
> Réponse aux demandes **U1** et **U2** de `docs/lots/plan_extension_annees.md` §4.4 ; backlog `docs/lots/backlog_retours_0_6.md` n° 4 (décor tous les 10 ans) et n° 5 (création de partie). Lien avec le n° 2 (niveau d'explication) et le n° 6 (pop-up de début, docs/32).
> **Conventions : celles de docs/24 §0**, sans exception : texels de 3 px virtuels ; PC 1920 × 1080 (T = 3) ; téléphone 1440 × 648 virtuels (T = 5), contrôle secondaire en 1280 × 720 ; cibles ≥ 81 px au PC, ≥ 72 px = 48 dp au téléphone (78 visé) ; Pixelify en capitales, ≥ 28, **jamais avec un chiffre** ; **tous les chiffres en Atkinson Hyperlegible** (gras pour les montants et les années), ≥ 20 px, tabulaires ; ▲ / ▼ + signe en plus de la couleur ; sprites 16 × 16 et portraits 48 × 48 à ×3 seulement.
> Statut : proposition. Les noms de chapitres, accroches et profils écrits ici sont des **exemples de mise en page** : les textes définitifs viennent du game designer (G1, G2, G3), du banquier (K2) et du boursier (B2, B3).

---

## 0. En bref

1. **Création de partie en 2 écrans + la pop-up de début** : (1) « CHOISISSEZ UNE ÉPOQUE » : une **frise des 8 décennies** (une tuile par chapitre, les chapitres fermés visibles avec « BIENTÔT ») et la **fiche du chapitre** choisi ; (2) « QUI ÊTES-VOUS ? » : **3 fiches de profil** côte à côte sur papier, une barre de récapitulatif en bas et COMMENCER ; puis la rue de l'époque et la pop-up de début de docs/32, qui sert de récapitulatif détaillé (pas de 3e écran).
2. **Rien n'est effacé avant COMMENCER** : la confirmation « la partie en cours sera remplacée » passe de NOUVELLE PARTIE à COMMENCER (on peut explorer les époques sans risque).
3. **Écran titre** : la rue derrière le titre prend le thème du dernier chapitre joué ; la ligne de reprise et le palmarès nomment le chapitre ; la collection des titres gagne un sélecteur de chapitre « ‹ 1984-1988 › ».
4. **Questionnaire (option a) en repli** : un écran « COMPOSER MON PERSONNAGE » (4 questions à boutons, aperçu en direct) qui, dans sa version légère, **choisit le plus proche des 3 profils** du chapitre : il ne demande aucun contenu non daté.
5. **Thèmes de décor : « la même rue, à 8 âges »**. Mêmes emplacements, mêmes silhouettes, mêmes points d'ancrage des séquences ; on change les **menuiseries, devantures, enseignes, véhicules, mobilier, passants, le média et la banque**. Le thème « 1980 » est la rue actuelle au pixel près. **Thème « 2020 » détaillé au §10** ; les 7 autres en une ligne au §11.
6. **Palette** : le thème 2020 ajoute **6 couleurs** en fin de palette (n° 68 à 73, dont une émissive) ; aucune couleur existante n'est modifiée.

---

# U1 : la création de partie

## 1. Parcours

```
ÉCRAN TITRE
  ├─ CONTINUER ───────────────────────────────────────────────► rue de la partie (thème du chapitre), en pause
  ├─ JOUER (aucune partie) ou NOUVELLE PARTIE
  │     ▼
  │  [1] CHOISISSEZ UNE ÉPOQUE   frise des 8 décennies + fiche du chapitre       Échap / ‹ RETOUR → écran titre
  │     │ CHOISIR CETTE ÉPOQUE ›
  │     ▼
  │  [2] QUI ÊTES-VOUS ?          3 fiches de profil + barre de récapitulatif      Échap / ‹ RETOUR → [1]
  │     │ COMMENCER ›   (si une partie est en cours : confirmation « sera remplacée »)
  │     ▼
  │  rue du chapitre (thème préparé derrière un fondu), janvier de la 1re année, temps en pause
  │     ▼
  │  POP-UP DE DÉBUT (docs/32, gabarits du profil) ── COMMENCER ──► le temps démarre
  │
  └─ TITRES ───► collection, sélecteur de chapitre
ÉCRAN DE FIN ── REJOUER AUTREMENT ──► [2] avec le même chapitre (RETOUR mène à [1])
```

| Règle | Pourquoi |
|---|---|
| Deux écrans seulement avant la rue | La pop-up de début (docs/32) dit déjà qui l'on est et ce qu'on doit faire : un 3e écran « récapitulatif » la répéterait. Le récapitulatif court tient dans la **barre du bas** de l'écran [2]. |
| L'écran [1] s'affiche même s'il n'y a qu'**un** chapitre ouvert (lot 10) | Le joueur voit que l'époque est un choix et que d'autres arrivent (envie de revenir). « 1984-1988 » est présélectionné : un seul toucher de plus que la 0.6. |
| REJOUER AUTREMENT mène à [2] | Rejouer le même chapitre avec un autre profil est le cas le plus fréquent : on saute l'étape déjà faite. |
| **Confirmation d'effacement à COMMENCER**, plus à NOUVELLE PARTIE | On peut regarder les époques et les profils sans rien risquer ; on ne détruit la partie en cours qu'au moment de la remplacer. Écart au comportement actuel (§5, écart 1). |
| Ni l'un ni l'autre écran ne touche à `Partie` | Comme `EcranTitre` aujourd'hui : ils émettent des signaux (`chapitre_choisi(id)`, `partie_demandee(id, profil)`) traités par `principal.gd`. |

## 2. Écran [1] : « CHOISISSEZ UNE ÉPOQUE »

### 2.1 Principe

- Panneau système **nuit** plein écran à 0,94 au-dessus de la rue de l'écran titre (assombrie) : ce n'est pas un objet du monde, donc pas de papier.
- En haut, une **frise des décennies** : 8 tuiles de 1950 à 2020, dans l'ordre du temps, sur un rail (filet `PANNEAU_SURVOL`). Le temps est le héros (principe 1) : on choisit **un moment de la frise**, pas une ligne de menu.
- En dessous, **la fiche du chapitre** sélectionné, reliée à sa tuile par une encoche de 6 t.
- Les chapitres fermés **restent visibles** (« BIENTÔT ») et leur fiche se lit (accroche, période, ce qui change) ; seul le bouton est désactivé. Pas de cadenas : un chapitre fermé n'est pas une punition, c'est une promesse.
- Aucune information au survol ; un toucher sur une tuile = sélection ; le bouton de la fiche = validation.

### 2.2 PC 1920 × 1080

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ ┌▓▓▓▓▓▓▓▓▓▓▓┐                     CHOISISSEZ UNE ÉPOQUE  (Pixelify 48)          ①ÉPOQUE ─ ②PERSONNAGE      ▓
▓ ▓ ‹ RETOUR  ▓                                                                   (petites cap. 20)          ▓
▓ └▓▓▓▓▓▓▓▓▓▓▓┘                                                                                              ▓
▓ ═══════╤══════════╤══════════╤══════════╤══════════╤══════════╤══════════╤══════════╤═══════  rail         ▓
▓ ┌┄┄┄┄┄┄┄┄┄┄┐┌┄┄┄┄┄┄┄┄┄┄┐┌┄┄┄┄┄┄┄┄┄┄┐┌▓▓▓▓▓▓▓▓▓▓┐┌┄┄┄┄┄┄┄┄┄┄┐┌┄┄┄┄┄┄┄┄┄┄┐┌┄┄┄┄┄┄┄┄┄┄┐┌──────────┐ ▓
▓ ┊ [ic]     ┊┊ [ic]     ┊┊ [ic]     ┊▓ [ic]     ▓┊ [ic]     ┊┊ [ic]     ┊┊ [ic]     ┊│ [ic]     │ ▓
▓ ┊ 1950     ┊┊ 1960     ┊┊ 1970     ┊▓ 1980     ▓┊ 1990     ┊┊ 2000     ┊┊ 2010     ┊│ 2020     │ ▓
▓ ┊1954-1958 ┊┊1962-1966 ┊┊1973-1977 ┊▓1984-1988 ▓┊1996-2000 ┊┊2006-2010 ┊┊2011-2015 ┊│2019-2023 │ ▓
▓ ┊ BIENTÔT  ┊┊ BIENTÔT  ┊┊ BIENTÔT  ┊▓ ▲ +12 %  ▓┊ BIENTÔT  ┊┊ BIENTÔT  ┊┊ BIENTÔT  ┊│ À JOUER  │ ▓
▓ └┄┄┄┄┄┄┄┄┄┄┘└┄┄┄┄┄┄┄┄┄┄┘└┄┄┄┄┄┄┄┄┄┄┘└▓▓▓▓▓▓▓▓▓▓┘└┄┄┄┄┄┄┄┄┄┄┘└┄┄┄┄┄┄┄┄┄┄┘└┄┄┄┄┄┄┄┄┄┄┘└──────────┘ ▓
▓                                          ▼ (encoche ambre, sous la tuile choisie)                            ▓
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ▓
▓ ▓ ┌──────────────────────────────┐  LA BOURSE POUR TOUS                          (Pixelify 48, nom)     ▓ ▓
▓ ▓ │                              │  Janvier 1984 – décembre 1988 · 5 ans          (Atkinson gras 28)    ▓ ▓
▓ ▓ │   VIGNETTE D'ÉPOQUE          │                                                                       ▓ ▓
▓ ▓ │   576 × 324                  │  Les privatisations approchent, la Bourse fait la une et votre       ▓ ▓
▓ ▓ │   (§2.5)                     │  banquier a de nouveaux placements à vous montrer.  (Atkinson 24,   ▓ ▓
▓ ▓ │                              │                                                       ≤ 3 lignes)    ▓ ▓
▓ ▓ │                              │  [F] Monnaie : le franc        [B] Banquier : M. Lefranc              ▓ ▓
▓ ▓ │                              │  [J] Média : La Gazette        [✓] Données vérifiées                  ▓ ▓
▓ ▓ └──────────────────────────────┘                                     (icônes 16×16 ×3 + Atkinson 22)  ▓ ▓
▓ ▓ ───────────────────────────────────────────────────────────────────────────────────────────────────   ▓ ▓
▓ ▓ Votre meilleur résultat : ▲ + 12 % face à Tata Livret · Titres 3 / 9      ╔═════════════════════════╗ ▓ ▓
▓ ▓ 2 parties terminées                       (Atkinson gras 24 / 20)          ║ CHOISIR CETTE ÉPOQUE ›  ║ ▓ ▓
▓ ▓                                                                            ╚═════════════════════════╝ ▓ ▓
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
(Exemple : tuile 1980 sélectionnée et déjà jouée, tuile 2020 ouverte et jamais jouée, les autres fermées.)

| Élément | Règle PC |
|---|---|
| En-tête | hauteur 81 ; ‹ RETOUR secondaire 240 × 81 (Pixelify 28) à gauche ; titre Pixelify 48 centré ; indicateur d'étape à droite : « ① ÉPOQUE ─ ② PERSONNAGE » en petites capitales 20, l'étape en cours en crème **soulignée ambre 1 t**, l'autre en secondaire (deux indices : soulignement + couleur) ; les numéros dans des ronds encre en Atkinson gras 20. L'indicateur n'est pas une cible. |
| Frise | 8 tuiles de **210 × 150** (70 × 50 t), écart 18 : 1 806 px, marges 57. Le rail (filet 1 t) passe au-dessus, avec un taquet par tuile. Si le nombre de chapitres dépasse 8 un jour (2 chapitres dans une décennie) : une tuile par décennie, et la fiche montre un **sélecteur à 2 cases** « 1978-1983 │ 1984-1988 » (cibles 81). |
| Contenu d'une tuile | icône d'époque 16 × 16 ×3 (§2.5) ; décennie en **Atkinson gras 36** ; période du chapitre en Atkinson 20 ; ligne d'état (ci-dessous). Une tuile = **une cible** (`Button` sans texte, enfants en `MOUSE_FILTER_IGNORE`, technique de docs/24 §2.1). |
| États d'une tuile | **Ouverte, jamais jouée** : cadre plein `PANNEAU_SURVOL` 1 t, état « À JOUER » (petites capitales 20, crème). **Ouverte, jouée** : même cadre, état = meilleur écart « ▲ + 12 % » (Atkinson gras 20, sprite ▲ / ▼ 8 × 8 ×3, crème : pas de vert ni de rouge sur une récompense, règle de docs/29 §1.4). **Fermée** : cadre **pointillé**, fond transparent, décennie et période en secondaire, état « BIENTÔT » (petites capitales 20, secondaire). **Sélectionnée** : cadre **ambre 2 t** + encoche ambre 6 t vers la fiche ; aucune autre différence (pas de grossissement). |
| Fiche du chapitre | panneau `panneau` 1 806 × ≈ 560 ; à gauche la vignette 576 × 324 (192 × 108 t) ; à droite (1 140 px) : nom du chapitre en **Pixelify 48** (sans chiffre ; s'il en a un, Atkinson gras 40 par `Style.police_pour`), 2 lignes au plus ; période en Atkinson gras 28 ; accroche Atkinson 24, 3 lignes au plus ; **4 faits** en grille 2 × 2 (icône 16 × 16 ×3 + Atkinson 22) : monnaie, banquier, média, certitude des données. |
| Fait « certitude » | « Données vérifiées » (sprite ✓) pour les chapitres A/B ; « Données en partie reconstituées » (sprite ≈, Atkinson 22 crème) pour les chapitres d'avant 1978 (plan §5, risque « données reconstituées ») ; un toucher sur ce fait n'ouvre rien (pas d'info cachée : la phrase suffit). |
| Ligne du record | si le chapitre a un record : « Votre meilleur résultat : ▲ + 12 % face à Tata Livret · Titres 3 / 9 » (Atkinson gras 24) + « 2 parties terminées » (Atkinson 20, secondaire) ; sinon « Pas encore joué. Titres 0 / 9 » (Atkinson 22, secondaire). Format du pourcentage : docs/29 §1.4. Données : `Records.lire(chemin, chapitre)`. |
| Bouton | « CHOISIR CETTE ÉPOQUE › » **principal ambre** 540 × 81, Pixelify 28, en bas à droite de la fiche. Chapitre fermé : même place, même taille, **hachures en marches** + texte à 60 % + 2e ligne « Arrive dans une prochaine version » (Atkinson 20) ; ne réagit pas (`refus=ignore`). |
| Budget vertical | 30 + en-tête 81 + 24 + rail 12 + tuiles 150 + encoche 18 + fiche 560 + 30 ≈ **905 px** (tient en 1009). |

### 2.3 Téléphone 1440 × 648

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ ┌▓▓▓▓▓▓▓▓▓▓┐  CHOISISSEZ UNE ÉPOQUE  (Pixelify 32)                ①ÉPOQUE ─ ②PERSONNAGE   ▓  78
▓ ▓‹ RETOUR  ▓                                                                             ▓
▓ └▓▓▓▓▓▓▓▓▓▓┘                                                                             ▓
▓ ┌┄┄┄┄┄┄┄┐┌┄┄┄┄┄┄┄┐┌┄┄┄┄┄┄┄┐┌▓▓▓▓▓▓▓┐┌┄┄┄┄┄┄┄┐┌┄┄┄┄┄┄┄┐┌┄┄┄┄┄┄┄┐┌───────┐                 ▓
▓ ┊ 1950  ┊┊ 1960  ┊┊ 1970  ┊▓ 1980  ▓┊ 1990  ┊┊ 2000  ┊┊ 2010  ┊│ 2020  │  165 × 114     ▓
▓ ┊1954-58┊┊1962-66┊┊1973-77┊▓1984-88▓┊1996-00┊┊2006-10┊┊2011-15┊│2019-23│                 ▓
▓ ┊BIENTÔT┊┊BIENTÔT┊┊BIENTÔT┊▓▲ +12 %▓┊BIENTÔT┊┊BIENTÔT┊┊BIENTÔT┊│À JOUER│                 ▓
▓ └┄┄┄┄┄┄┄┘└┄┄┄┄┄┄┄┘└┄┄┄┄┄┄┄┘└▓▓▓▓▓▓▓┘└┄┄┄┄┄┄┄┘└┄┄┄┄┄┄┄┘└┄┄┄┄┄┄┄┘└───────┘                 ▓
▓                              ▼                                                            ▓
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐ ▓
▓ ▓ ┌───────────────────┐ LA BOURSE POUR TOUS                     (Pixelify 32)          ▓ ▓
▓ ▓ │ VIGNETTE          │ Janvier 1984 – décembre 1988 · 5 ans    (Atkinson gras 24)     ▓ ▓
▓ ▓ │ 288 × 162         │ Les privatisations approchent, la Bourse fait la une et votre  ▓ ▓
▓ ▓ │                   │ banquier a de nouveaux placements…      (Atkinson 22, 2 lignes)▓ ▓
▓ ▓ └───────────────────┘ Franc · M. Lefranc · La Gazette · Données vérifiées (22)       ▓ ▓
▓ ▓ Meilleur : ▲ + 12 % face à Tata · Titres 3 / 9 (gras 22)  ╔══════════════════════╗   ▓ ▓
▓ ▓ 2 parties terminées (20)                                   ║ CHOISIR CETTE ÉPOQUE ›║  ▓ ▓ 78
▓ ▓                                                            ╚══════════════════════╝   ▓ ▓
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘ ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

| Élément | Ce qui change au téléphone (rien n'est retiré) |
|---|---|
| En-tête | une rangée de 78 : RETOUR 216 × 78, titre Pixelify 32, indicateur d'étape petites capitales 20 |
| Tuiles | **165 × 114** (55 × 38 t), écart 9 : 1 383 px. L'icône d'époque **passe dans la vignette** de la fiche (une tuile de 114 px ne loge pas un sprite de 48 + 3 lignes). Décennie Atkinson gras 32 ; période **abrégée** « 1984-88 » (Atkinson 20) ; ligne d'état 20. |
| Fiche | hauteur ≈ 384 ; vignette **288 × 162** (96 × 54 t) ; nom Pixelify 32 ; période gras 24 ; accroche 22 sur 2 lignes (au-delà : « … » et la phrase complète est dans la pop-up de début ; c'est la seule coupe tolérée, l'accroche n'étant pas une information de jeu) ; les 4 faits sur **une ligne** séparés par « · » (sans icônes) ; record en 2 lignes à gauche du bouton |
| Bouton | 552 × 78, sur la même rangée que le record |
| Budget | 18 + 78 + 9 + rail 6 + tuiles 114 + encoche 12 + fiche 384 + 18 ≈ **639 px** sur 648. Si une mesure dépasse : l'encoche passe à 6, puis le rail se fond dans le haut des tuiles (−6) ; jamais de défilement vertical sur cet écran. |
| 1280 × 720 (contrôle) | largeur utile 1 244 : tuiles `(largeur − 7 × 6) / 8` = 150 ; **en dessous de 150**, la frise défile horizontalement (glisser) avec deux flèches de bord ‹ › de 72 × 114 (cibles), comme les flèches de bord de la rue. 72 px de hauteur en plus : la fiche s'allonge, l'accroche passe à 3 lignes. |

### 2.4 Interaction

| Action | PC | Téléphone |
|---|---|---|
| Sélectionner un chapitre | clic sur la tuile ; **← / →** déplacent la sélection (fermés compris) | toucher la tuile |
| Valider | bouton, **Entrée** (seulement si ouvert) | bouton |
| Retour | ‹ RETOUR, **Échap** | ‹ RETOUR, geste retour d'Android |
| Ouverture | sélection initiale = **chapitre de la dernière partie** (records ou sauvegarde), sinon le **plus ancien chapitre ouvert** (« 1984 » au lot 10) | idem |

- Changement de sélection **sur place** : cadre et encoche changent, la fiche est remplacée sans fondu (aucune animation nouvelle). Option peu coûteuse si le chef de projet l'accepte : l'encoche glisse de la tuile précédente en 0,12 s (`Tween` sur `position.x`, arrondi au texel).
- La rue derrière l'écran **ne change pas** pendant la navigation (régénérer un thème coûte du temps de calcul : §4.2).

### 2.5 La vignette d'époque (sans illustration externe)

Tant qu'aucune illustration n'est fournie, la vignette est **composée en code avec des éléments déjà dessinés ou très petits** :

```
┌──────────────────────────────────────────────┐
│ ciel en 3 bandes de la palette du thème        │   bandes : ciel_haut / ciel_vif / ciel (jour)
│              ┌────────────────┐                │
│              │ LA GAZETTE     │  ← nom du média dans son lettrage d'époque (police à points 5 × 7
│              └────────────────┘    déjà codée pour le journal lumineux, ou Pixelify)
│     1984                                       │   ← année en Atkinson gras 72, crème, ombre encre 1 t
│ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ │   ← bandeau de façade : rampe brique du thème
│   [ic voiture]   [ic téléphone]   [ic écran]   │   ← 3 icônes d'époque 16 × 16 ×3 (même jeu que la tuile)
└──────────────────────────────────────────────┘
```

- **Jeu d'icônes d'époque** (à dessiner une fois, 16 × 16) : par décennie, une **voiture** (silhouette de profil), un **téléphone** (mural à cadran → combiné gris → à touches → portable → smartphone) et un **écran / média** (journal → poste de radio → téléviseur → Minitel → écran plat → smartphone). 8 × 3 = 24 sprites ; l'icône de tuile est la voiture.
- Couleurs : celles de la palette ; l'année n'est jamais en Pixelify.
- **Où une illustration apporterait le plus de tout le document** : une vraie vignette par chapitre (la rue à cette époque, 192 × 108 px d'art, cahier des charges de docs/16 §4.3). Elle remplacerait la composition ci-dessus sans changer la mise en page.

## 3. Écran [2] : « QUI ÊTES-VOUS ? »

### 3.1 Principe

- Même panneau nuit et même en-tête (étape ② soulignée). Sous le titre, le rappel du chapitre.
- **Trois fiches de profil côte à côte**, sur **papier crème** (c'est la fiche d'une personne : même famille que les cartes du banquier et le courrier). Une fiche = **une cible**. Trois fiches **de même taille et de même style** (principe 11) : aucun profil n'est mis en avant, sauf une étiquette factuelle de difficulté.
- En bas, la **barre de récapitulatif** : une phrase qui dit ce qui va se passer + COMMENCER.
- On n'annonce **aucun événement scripté** (naissance, héritage, krach : A5, A8). La fiche dit qui l'on est, ce qu'on a, ce qu'on veut ; jamais ce qui va arriver.

### 3.2 PC 1920 × 1080

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ ┌▓▓▓▓▓▓▓▓▓▓▓┐                     QUI ÊTES-VOUS ?  (Pixelify 48)                ①ÉPOQUE ─ ②PERSONNAGE      ▓
▓ ▓ ‹ RETOUR  ▓              1984-1988 · La Bourse pour tous  (Atkinson gras 24, secondaire)                  ▓
▓ └▓▓▓▓▓▓▓▓▓▓▓┘                                                                                              ▓
▓ ┌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┐  ┌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┐  ┌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┐      ▓
▓ │ 1                     [CHOISI]│  │ 2                              │  │ 3                              │      ▓
▓ │ ┌────────┐ GÉRARD, 26 ANS     │  │ ┌────────┐ NADINE, 38 ANS      │  │ ┌────────┐ THIERRY, 22 ANS     │      ▓
▓ │ │portrait│ Technicien         │  │ │portrait│ Cadre administrative│  │ │portrait│ Employé de bureau   │      ▓
▓ │ │ 48×48  │                    │  │ │ 48×48  │                     │  │ │ 48×48  │                     │      ▓
▓ │ │  ×3    │                    │  │ │  ×3    │                     │  │ │  ×3    │                     │      ▓
▓ │ └────────┘                    │  │ └────────┘                     │  │ └────────┘                     │      ▓
▓ │ [♥] En couple avec Sylvie,    │  │ [♥] Mariée à Bernard           │  │ [♥] En couple avec Corinne     │      ▓
▓ │     sans être mariés          │  │ [◎] 2 enfants                  │  │ [◎] Pas d'enfant               │      ▓
▓ │ [◎] Pas d'enfant              │  │                                │  │                                │      ▓
▓ │ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ │  │ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ │  │ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ │      ▓
▓ │ Salaire          6 790 F/mois │  │ Salaires        14 200 F/mois  │  │ Salaire          5 100 F/mois  │      ▓
▓ │ Sur le compte       11 000 F  │  │ Sur le compte      18 000 F    │  │ Sur le compte       3 000 F    │      ▓
▓ │ Déjà épargné             0 F  │  │ Déjà épargné       40 000 F    │  │ Déjà épargné             0 F   │      ▓
▓ │ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ │  │ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ │  │ ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄ │      ▓
▓ │ « Mettre de côté pour la      │  │ « Payer les études des enfants │  │ « Quitter le studio et avoir   │      ▓
▓ │ famille qu'on veut fonder. »  │  │ sans renoncer aux vacances. »  │  │ enfin une voiture à moi. »     │      ▓
▓ │ MARGE ■■□  moyenne            │  │ MARGE ■■■  large               │  │ MARGE ■□□  serrée              │      ▓
▓ └▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┘  └▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┘  └▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┘      ▓
▓ ┌──────────────────────────────────────────────────────────────────────────────┐ ╔═══════════════════════╗ ▓
▓ │ Vous serez Gérard, 26 ans, technicien, en janvier 1984.                       │ ║     COMMENCER ›       ║ ▓
▓ │ Cinq ans pour faire mieux que Tata Livret.            (Atkinson gras 24 / 22) │ ╚═══════════════════════╝ ▓
▓ └──────────────────────────────────────────────────────────────────────────────┘                           ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
(▒ = bord de la fiche papier. Profils 2 et 3, prénoms, montants et phrases : **exemples de mise en page**, en attente de G2 et K3. Les montants de Gérard sont ceux de docs/32.)

| Élément | Règle PC |
|---|---|
| Rappel du chapitre | sous le titre, « 1984-1988 · La Bourse pour tous », Atkinson gras 24, secondaire (chiffres : jamais Pixelify) |
| Fiches | 3 × **582 × 600** (194 × 200 t), écart 30 ; papier `CartePapier` sans liseré de source ; marges 24 |
| Numéro | carré encre 36 × 36, Atkinson gras 22 crème (= touche 1 / 2 / 3) |
| Portrait | **48 × 48 ×3 = 144 px**, expression neutre souriante ; sans portrait dessiné : **initiale** du prénom en Pixelify 64 dans un carré encre 144 (règle de l'icône absente de docs/24 §0) |
| Identité | « GÉRARD, 26 ANS » : **Atkinson gras 32** capitales (il y a un chiffre) ; métier Atkinson 24, encre |
| Foyer | 2 lignes au plus, chacune avec un sprite 16 × 16 ×3 : cœur (conjoint) ou personne seule ; enfants (« Pas d'enfant », « 1 enfant », « 2 enfants »), Atkinson 22 |
| Chiffres de départ | 3 lignes de 30 : libellé à gauche (Atkinson 22, `TEXTE_PAPIER_2`), montant **à droite**, Atkinson gras 24, encre, tabulaire, devise du chapitre (`Format.montant`) ; « Salaires » au pluriel si le couple a deux revenus (donnée du profil). Aucune couleur de jugement. |
| Objectif du personnage | 2 lignes au plus, entre « », Atkinson 22 italique, encre. C'est le **désir** du personnage (relié aux projets), pas un événement à venir. |
| Marge de manœuvre | « MARGE » petites capitales 20 + **3 cases** (■ pleines encre, □ vides contour encre) + le mot « serrée / moyenne / large » (Atkinson 22) : trois indices, aucune couleur. Valeur lue dans `profils.json > marge` (1 à 3), fixée par le game designer après calibrage (G2), **pas calculée** par l'interface. Elle informe sur la difficulté sans dire quel profil « choisir ». |
| Sélection | toucher la fiche : cadre **ambre 2 t** autour du papier + tampon « CHOISI » (Pixelify 20, encre sur ambre, coin haut droit) ; les autres fiches restent à 100 % (on compare encore). Retoucher la fiche choisie ne fait rien (pas de validation au double toucher : trop facile par accident). |
| Barre de récapitulatif | cadre `PANNEAU_SURVOL` 1 t, 1 230 × 81 ; **avant sélection** : « Choisissez un personnage (touches 1, 2, 3). » (Atkinson 22, secondaire) ; **après** : ligne 1 « Vous serez Gérard, 26 ans, technicien, en janvier 1984. » (Atkinson gras 24) ; ligne 2 « Cinq ans pour faire mieux que Tata Livret. » (Atkinson 22) — gabarit `{prenom}`, `{age}`, `{metier}`, `{mois_debut}`, `{duree}` |
| COMMENCER | principal ambre 540 × 81, Pixelify 28 ; **désactivé** (hachures + « Choisissez un personnage », Atkinson 20) tant qu'aucune fiche n'est choisie |
| Présélection | le **dernier profil joué dans ce chapitre** (REJOUER AUTREMENT : le suivant dans l'ordre, pour inviter à changer ; à confirmer par le game designer) ; à la toute première partie : **aucune** |
| Budget vertical | 30 + en-tête 81 + rappel 30 + 18 + fiches 600 + 24 + barre 81 + 30 ≈ **894 px** |

Contenu de la fiche (ordre de lecture) : **qui** (visage, nom, âge, métier) → **avec qui** (foyer) → **avec quoi** (3 chiffres) → **pour quoi** (objectif) → **à quel point c'est difficile** (marge). Volume : ≤ 45 mots par fiche.

### 3.3 Téléphone 1440 × 648

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ ┌▓▓▓▓▓▓▓▓▓▓┐ QUI ÊTES-VOUS ? (Pixelify 32)  1984-1988 (gras 22)     ①ÉPOQUE ─ ②PERSONNAGE  ▓ 78
▓ ▓‹ RETOUR  ▓                                                                              ▓
▓ └▓▓▓▓▓▓▓▓▓▓┘                                                                              ▓
▓ ┌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┐ ┌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┐ ┌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┐    ▓
▓ │1 ┌──────┐ GÉRARD, 26 ANS[CHOISI]│2 ┌──────┐ NADINE, 38 ANS  │ │3 ┌──────┐ THIERRY, 22 ANS │    ▓
▓ │  │ 144  │ Technicien      │ │  │ 144  │ Cadre admin.    │ │  │ 144  │ Employé de bur. │    ▓
▓ │  │      │ ♥ Sylvie, non   │ │  │      │ ♥ Mariée, Bernard│ │  │      │ ♥ Corinne       │    ▓
▓ │  └──────┘   mariés · 0 enf.│ │  └──────┘ ◎ 2 enfants     │ │  └──────┘ ◎ Pas d'enfant  │    ▓
▓ │ Salaire       6 790 F/mois │ │ Salaires     14 200 F/mois │ │ Salaire       5 100 F/mois │    ▓
▓ │ Sur le compte     11 000 F │ │ Sur le compte    18 000 F  │ │ Sur le compte     3 000 F  │    ▓
▓ │ Déjà épargné           0 F │ │ Déjà épargné     40 000 F  │ │ Déjà épargné           0 F │    ▓
▓ │ « Mettre de côté pour la   │ │ « Payer les études des     │ │ « Quitter le studio et     │    ▓
▓ │ famille qu'on veut… »      │ │ enfants sans renoncer… »   │ │ avoir enfin une voiture… » │    ▓
▓ │ MARGE ■■□ moyenne          │ │ MARGE ■■■ large            │ │ MARGE ■□□ serrée           │    ▓
▓ └▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┘ └▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┘ └▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┘    ▓
▓ ┌──────────────────────────────────────────────────────────────┐ ╔════════════════════╗     ▓
▓ │ Vous serez Gérard, 26 ans, technicien, en janvier 1984.       │ ║    COMMENCER ›     ║     ▓ 78
▓ │ Cinq ans pour faire mieux que Tata Livret.                    │ ╚════════════════════╝     ▓
▓ └──────────────────────────────────────────────────────────────┘                            ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

| Élément | Téléphone |
|---|---|
| En-tête | une rangée de 78 : RETOUR, titre Pixelify 32 + rappel « 1984-1988 » Atkinson gras 22, indicateur d'étape (le nom du chapitre disparaît de l'en-tête : il est dans la barre si besoin, voir ci-dessous) |
| Fiches | 3 × **444 × 435** (148 × 145 t), écart 12 ; marges 15 ; portrait **144** (×3 obligatoire à T = 5) à gauche, identité et foyer **à sa droite** (264 px de texte) : identité Atkinson gras 26, métier 22 (abrégé dans la **donnée** `metier_court` s'il dépasse 18 caractères, jamais tronqué au hasard), foyer 2 lignes de 20 ; chiffres 3 × 28 (libellés 20, montants gras 22) ; objectif 2 lignes de 20 italique ; marge 1 ligne |
| Objectif trop long | « … » après 2 lignes ; la phrase entière s'affiche dans la **barre de récapitulatif** quand la fiche est choisie (ligne 2 remplace « Cinq ans pour… ») : rien n'est perdu |
| Barre + COMMENCER | barre 1 000 × 78, COMMENCER 342 × 78 |
| Budget | 18 + 78 + 9 + fiches 435 + 12 + 78 + 18 = **648 px**. Fiche : 15 + max(144, 26 + 22 + 2 × 20 + 6) + 6 + 84 + 6 + 52 + 6 + 28 + 15 ≈ **356** : marge de 79 px pour un foyer sur 3 lignes ou un métier long. Contrôle : `UI profils fiches=3 debordements=0 cibles sous_seuil=0`. |
| 1280 × 720 | fiches 400 × 507 : l'objectif passe à 3 lignes, plus de « … » |

### 3.4 Interaction

| Action | PC | Téléphone |
|---|---|---|
| Choisir un profil | clic sur la fiche ; touches **1 / 2 / 3** | toucher la fiche |
| Commencer | COMMENCER, **Entrée** (si un profil est choisi) | COMMENCER |
| Retour | ‹ RETOUR, **Échap** → écran [1], la sélection du chapitre est gardée | ‹ RETOUR, geste retour |

**Si une partie est en cours** (sauvegarde automatique non terminée), COMMENCER ouvre la confirmation existante de NOUVELLE PARTIE, déplacée ici et complétée :

```
▓ Commencer une nouvelle partie ?                                         (Atkinson gras 24)
▓ La partie en cours (Gérard, 1984-1988, mai 1987) sera remplacée.         (Atkinson 22)
▓ Vos titres et vos records sont gardés.                                   (Atkinson 20, secondaire)
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐   ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ ▓ REMPLACER ET COMMENCER    ▓   ▓ ANNULER                   ▓      secondaires tous deux ; ANNULER a le focus
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘   └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```
(+ « Vos sauvegardes (emplacements 1 à 3) sont gardées. » quand la sauvegarde manuelle existera, docs/30 §5.)

### 3.5 Place réservée : le niveau d'explication (backlog n° 2)

Quand le réglage « niveau d'explication » existera (débutant / intermédiaire / expert, textes du banquier et du game designer), il se place **dans la barre de récapitulatif**, à gauche de COMMENCER, sous la forme d'un sélecteur à 3 cases (même interrupteur pixel que docs/30 §1 : case active pleine ambre + mot ; 3 × 150 × 78). La phrase du récapitulatif passe alors sur une seule ligne. Rien d'autre ne bouge ; pas d'écran de plus. Valeur par défaut : la dernière choisie (préférence locale), sinon « intermédiaire » (= les textes actuels).

## 4. Après COMMENCER : l'enchaînement

### 4.1 Séquence

1. L'écran [2] disparaît par le fondu existant (≤ 0,2 s).
2. **Si le thème du chapitre diffère de celui de la rue affichée** : un panneau nuit opaque couvre l'écran avec, au centre, la date de départ « JANVIER 2019 » (Atkinson gras 60, ambre) et dessous « La rue se prépare… » (Atkinson 22, secondaire), **seulement si la préparation dure plus de 0,5 s** (sinon on ne montre rien). Pendant ce temps : `ville.regler_theme(theme)` puis attente de `images_pretes()`. Aucune barre de progression (durée courte et inconnue).
3. La rue apparaît (fondu existant), cadrée sur la maison, **janvier de la 1re année, temps en pause**.
4. **Pop-up de début** (docs/32) alimentée par le profil : titre `{MOIS_DEBUT}` (« JANVIER 2019 »), sous-titre « Votre vie d'épargnant commence », bloc 1 = gabarit du profil (`profils.json > intro`), blocs 2-4 = gabarits du chapitre (`chapitre.json > intro`), bouton COMMENCER. Elle est le **récapitulatif détaillé** ; elle entre dans l'historique comme aujourd'hui.

### 4.2 Pourquoi la rue ne change pas pendant qu'on parcourt les époques

La rue est générée en tâches de fond (images lourdes, variantes nuit et orage, préchauffage : `rue.gd`). Changer de thème à chaque toucher sur la frise ferait attendre et chauffer le téléphone. La **vignette** de la fiche (§2.5) donne l'époque ; la rue change **une fois**, au moment de jouer. Si le chef de projet mesure une préparation < 0,3 s sur le téléphone de référence, on pourra plus tard changer la rue derrière l'écran [1] (effet « la rue vieillit » très parlant) : à mesurer au lot 09-V, pas à promettre.

## 5. L'écran titre adapté

### 5.1 Ce qui change

```
                    (la rue au thème du dernier chapitre joué, crépuscule, comme aujourd'hui)
                ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
                ▓        MA RUE, DE 1950 À AUJOURD'HUI           ▓   accroche : Atkinson gras 44 (chiffres)
                ▓   Choisissez une époque, vivez cinq ans d'épargne ▓  sous-titre : Atkinson 24
                └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
         ╔════════════════════╗ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐                       96 px (existant)
         ║     CONTINUER      ║ ▓  NOUVELLE PARTIE   ▓
         ╚════════════════════╝ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
        Partie en cours : Gérard · 1984-1988 · mai 1987 · patrimoine 98 200 F         Atkinson 22
  ┌──────────────────────────────────────────────────────────────────┐ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
  │ 1984-1988 · meilleur résultat : ▲ + 12 % face à Tata Livret ·     │ ▓ TITRES 3 / 9 ▓   81 px
  │ 2e de la rue · Le marin par gros temps                           │ └▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
  └──────────────────────────────────────────────────────────────────┘
```

| Élément | Avant (0.6) | Après |
|---|---|---|
| Rue derrière le titre | thème unique | thème du **chapitre de la partie en cours**, sinon du **dernier chapitre terminé**, sinon « 1980 » ; une seule génération au lancement (aucun coût de plus) |
| Accroche | « Ma rue, de 1978 à aujourd'hui » en Pixelify (**contient des chiffres** : écart actuel à la règle `police_pour`) | lue dans `chapitres/index.json > titre` ; « MA RUE, DE 1950 À AUJOURD'HUI » quand ≥ 2 chapitres sont ouverts, sinon inchangée ; **Atkinson gras 44** avec la même ombre néon (la règle des chiffres s'applique) ; si le client veut garder le Pixelify du logo, écrire l'accroche **sans chiffre** (« MA RUE, D'UNE ÉPOQUE À L'AUTRE ») |
| Sous-titre | « Démonstration · janvier 1984 – décembre 1988 · Gérard, 26 ans » | « Choisissez une époque, vivez cinq ans d'épargne » (donnée) |
| JOUER (aucune partie) | lance la démo | ouvre l'écran [1] |
| NOUVELLE PARTIE | confirmation puis démo | ouvre l'écran [1] **sans confirmation** (elle est à COMMENCER, §3.4) |
| Ligne de reprise | « Gérard · mai 1987 · patrimoine … » | + la période du chapitre : « Gérard · 1984-1988 · mai 1987 · patrimoine 98 200 F » |
| Palmarès | record unique | record **du chapitre affiché par la rue** (même règle de choix), préfixé de sa période ; bouton « TITRES n / 9 » du même chapitre ; s'il n'a pas de record mais qu'un autre chapitre en a un, on montre ce dernier (on ne cache pas un record) |
| Touche T, CHARGER (docs/30 §5) | — | inchangés |

Budget téléphone : identique à docs/29 §2 (≈ 406 px), la ligne de reprise reste sur une ligne (≈ 70 caractères à 22 px dans 1 380 px).

### 5.2 La collection des titres par chapitre (fenêtre TITRES, docs/29 §3)

Un **sélecteur de chapitre** dans l'en-tête, plutôt que des onglets (8 onglets ne tiendraient pas au téléphone) :

```
▓ LES TITRES D'ÉPOQUE  ┌▓▓▓┐ 1984-1988 ┌▓▓▓┐   3 SUR 9 OBTENUS     ┌▓▓▓▓▓▓▓▓┐ ▓
▓ (Pixelify 36)        ▓ ‹ ▓ (gras 24) ▓ › ▓   (Atkinson gras 24)   ▓ FERMER ▓ ▓
▓                      └▓▓▓┘           └▓▓▓┘                        └▓▓▓▓▓▓▓▓┘ ▓
▓ (grille 3 × 3 de docs/29 §3, inchangée, titres du chapitre affiché)          ▓
```

- Flèches ‹ › : secondaires **81 × 81** (PC) / **78 × 78** (téléphone) ; touches ← / → ; elles ne parcourent que les chapitres **ouverts** ; une seule flèche grisée (hachures) aux extrémités ; avec un seul chapitre ouvert, le sélecteur affiche la période sans flèches.
- Au téléphone, l'en-tête reste sur **une** rangée de 78 : « TITRES » (Pixelify 28) + sélecteur + « 3 / 9 » (Atkinson gras 22) + FERMER. Budget inchangé (≈ 602 px).
- Chapitre affiché à l'ouverture : celui du palmarès de l'écran titre.

## 6. Repli : le questionnaire (option a du joueur)

### 6.1 Deux niveaux

| Niveau | Ce que fait le questionnaire | Contenu nécessaire | Quand |
|---|---|---|---|
| **Léger (recommandé en repli)** | Après le choix de l'époque, 4 questions ; le jeu **choisit le plus proche des 3 profils** du chapitre et ajuste ce qui est sans risque (prénom choisi, nombre d'enfants au départ si le profil le permet). | Aucun contenu nouveau : les 3 profils existent ; une table de correspondance par chapitre (game designer). | Possible dès le lot 10, en 4e fiche « COMPOSER MON PERSONNAGE » ou en lien sous les fiches (voir §6.3). |
| **Complet (option a d'origine)** | Âge, année de départ libre, enfants, revenus : un personnage sur mesure. | Cartes, projets et rival **non datés** (G4) ; année libre hors chapitres. | Après 3 chapitres (plan §2.4, §3.3). |

### 6.2 Écran « COMPOSER MON PERSONNAGE » (PC ; téléphone : mêmes rangées, aperçu réduit)

```
┌▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┐
▓ ‹ RETOUR                  COMPOSER MON PERSONNAGE                       ①ÉPOQUE ─ ②PERSONNAGE        ▓
▓ VOTRE ÂGE                                                          ┌▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┐   ▓
▓ ┌▓▓▓▓▓▓▓▓▓▓▓▓▓┐┌▓▓▓▓▓▓▓▓▓▓▓▓▓┐┌▓▓▓▓▓▓▓▓▓▓▓▓▓┐                      │ APERÇU (fiche du §3,       │   ▓
▓ ▓ MOINS DE 30 ▓▓ 30 À 45 ANS ▓▓ PLUS DE 45  ▓                      │ mise à jour à chaque       │   ▓
▓ └▓▓▓▓▓▓▓▓▓▓▓▓▓┘└▓▓▓▓▓▓▓▓▓▓▓▓▓┘└▓▓▓▓▓▓▓▓▓▓▓▓▓┘                      │ réponse, sans animation)   │   ▓
▓ VOUS VIVEZ                                                         │                            │   ▓
▓ ▓ SEUL(E) ▓ ▓ EN COUPLE ▓ ▓ MARIÉ(E) ▓                             │ GÉRARD, 26 ANS             │   ▓
▓ ENFANTS AU DÉPART                                                  │ …                          │   ▓
▓ ▓ AUCUN ▓ ▓ UN ▓ ▓ DEUX ▓ ▓ TROIS OU PLUS ▓                        │ MARGE ■■□ moyenne          │   ▓
▓ VOTRE PRÉNOM                                                       └▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒┘   ▓
▓ ▓ GÉRARD ▓ ▓ ↻ UN AUTRE ▓                                                ╔══════════════════════╗     ▓
▓                                                                          ║     COMMENCER ›      ║     ▓
▓                                                                          ╚══════════════════════╝     ▓
└▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┘
```

- Chaque réponse = un **bouton de segment** (78 / 81 px de haut, ≥ 200 de large), la réponse active pleine ambre + texte encre, les autres secondaires (deux indices : remplissage + cadre). Libellés en mots, en capitales Pixelify (pas de chiffres : « TROIS OU PLUS », « 30 À 45 ANS » → Atkinson gras 24 puisqu'il y a des chiffres).
- **Pas de champ de saisie** : le clavier virtuel couvrirait la moitié de l'écran en paysage. Prénom choisi dans une liste de prénoms **de l'époque** (`vie.json` du chapitre), bouton ↻ « UN AUTRE ».
- Réponses par défaut = celles du profil 1 : on peut commencer tout de suite.
- **Aucune question sur le goût du risque** (idée mise de côté le 2026-10-27, et docs/03 : jamais de conseil personnalisé).
- L'aperçu dit honnêtement ce que le jeu fera : en version légère, une ligne sous la fiche « Le personnage le plus proche dans cette époque. » (Atkinson 20, secondaire).

### 6.3 Place du questionnaire dans l'écran [2]

Version légère seulement : un **lien-bouton secondaire** « COMPOSER MON PERSONNAGE » (Pixelify 28, 81 / 78 px) **dans la barre de récapitulatif**, à gauche, tant qu'aucune fiche n'est choisie ; pas de 4e fiche (elle réduirait les 3 autres à 330 px au téléphone, illisible). Si le réglage du niveau d'explication (§3.5) occupe déjà la barre, le lien passe dans l'en-tête, à gauche de l'indicateur d'étape.

## 7. Contrôles proposés pour les captures (lots 10-I et suivants)

- `creation_epoque` (1 chapitre ouvert, sélection « 1984 » ; puis un chapitre fermé sélectionné) : `UI epoque tuiles=8 ouvertes=<n> selection=<id> bouton=<actif|ferme> debordements=0 cibles sous_seuil=0 chiffres_pixelify=0`.
- `creation_profils` (aucune sélection ; profil 1 choisi ; confirmation de remplacement) : `UI profils fiches=3 choisi=<0-3> commencer=<actif|inactif> confirmation=<aucune|remplacer> focus=annuler debordements=0`.
- `creation_preparation` : capture du panneau « JANVIER 2019 · La rue se prépare… » en forçant un délai.
- `titre_chapitres` : `UI titre theme=<id> reprise="<texte>" palmares_chapitre=<id>` ; sans records, capture identique à celle de 0.6 hors accroche et sous-titre.
- `titres_collection_chapitres` : sélecteur avec 2 chapitres ouverts.
- Formats : PC 1920 × 1080 et 1920 × 1009, téléphones 1440 × 648 et 1280 × 720.

## 8. Écarts et points à trancher (U1)

| # | Sujet | Proposition | Pour qui |
|---|---|---|---|
| 1 | Confirmation d'effacement déplacée de NOUVELLE PARTIE à COMMENCER | Oui (exploration sans risque) | Chef de projet |
| 2 | Accroche de l'écran titre en Pixelify avec des chiffres (écart existant) | Atkinson gras, ou accroche sans chiffre | Client |
| 3 | Chapitres fermés visibles (« BIENTÔT ») | Oui ; sinon la frise montre une seule tuile et perd son sens | Client |
| 4 | Champ `marge` (1 à 3) et `objectif` dans `profils.json` | À ajouter au contrat du lot 10 et à fournir par G2 | Chef de projet, game designer |
| 5 | Présélection du profil après REJOUER AUTREMENT (suivant dans l'ordre) | À confirmer | Game designer |
| 6 | Nom du chapitre (« La Bourse pour tous » est un exemple) | Un nom court sans chiffre par chapitre, dans `index.json` | Game designer (G1) |
| 7 | Questionnaire léger dès le lot 10 ou plus tard | Plus tard ; le lot 10 réserve seulement la place (§6.3) | Chef de projet |

---

# U2 : les thèmes de décor par décennie (complément de docs/16)

> À reporter dans docs/16 comme **§10 « Thèmes d'époque »** quand le chef de projet l'aura validé (je ne modifie pas docs/16 dans cette mission). Remplace docs/09 §2.5 pour le visuel ; prime sur docs/16 §1.3 pour tout ce qui n'est pas 1980. Grille, échelle et règles : docs/16 §9 (rue en grille 960 × 540, figurine 36 × 63, palette 67 couleurs, relief « mini 3D »).

## 9. Principe : « la même rue, à huit âges »

1. **Mêmes emplacements, mêmes silhouettes.** La rue garde `BATIMENTS`, `FONDS`, `ARBRES`, la maison (x 0), la Gazette (x −795) et la banque (x 678) à leurs places et à leurs tailles. Un thème change **ce qui habille** les volumes : menuiseries, rez-de-chaussée, enseignes, toitures, mobilier, véhicules, passants. Le joueur qui joue deux époques **reconnaît sa rue** : c'est l'effet recherché (« ma rue a vieilli ») et c'est ce qui rend 8 thèmes abordables (plan §5, risque « coût du décor »).
2. **Les points d'ancrage ne bougent pas.** `FENETRE_BANQUIER`, `PORTE_BANQUE`, `HORLOGE`, `ECRAN`, `NEON`, `ROTATIVE`, `FENETRE_SYLVIE`, `PORTE` (maison) gardent leurs rectangles dans tous les thèmes : les séquences (appel du banquier, pièces qui sortent de la porte, animation du média, cartes qui sortent de la maison) marchent sans changement. Seul le **dessin** dans ces rectangles change.
3. **Un élément signature par époque**, bien visible depuis la maison : en 1984 le journal lumineux ambre ; en 2020 **l'écran de la chaîne d'info et la vitrine-studio de la Gazette**, plus la **cabine devenue boîte à livres**.
4. **Ce qui ne change jamais** (continuité, repères du joueur) : la brique, les arbres, la plaque de rue bleue « RUE DES ÉPARGNANTS », la boîte aux lettres jaune, la bouche d'incendie, l'horloge de la banque, la Gazette plus haute que tout, la fenêtre de Sylvie (ou du conjoint), les étiquettes du HUD.
5. **Variantes datées à l'intérieur d'un chapitre** : comme « INDICE » → « CAC 40 » en 06/1988, un thème porte une petite table `{debut, fin, effet}` (affiches, masques, rue vide). Elles montrent **le présent**, jamais l'avenir (A5).
6. **Palette** : un thème **ajoute** des couleurs en fin de palette (n° 68 et suivants), jamais n'en modifie ; chaque ajout a ses valeurs jour, nuit, orage (`palette.gd` fait foi).
7. **Lisibilité** : aucun élément de décor ne porte seul une information de jeu (docs/16 §2.1). L'écran du média répète ce que dit le HUD, il ne le remplace pas.

## 10. Le thème « 2020 » (chapitre 2019-2023)

### 10.1 Ce qui change par rapport à 1984, en un tableau

| Élément | 1984 (rue actuelle) | 2020 | Coût |
|---|---|---|---|
| **Fenêtres** | bois peint, petits bois, vitre à reflet | **PVC blanc** (cadre 2 px `blanc_chaud`, sans petits bois) ou **alu anthracite** (n° 68) ; la moitié des fenêtres avec **coffre de volet roulant** (bande de 6 px au-dessus, lames horizontales de 2 px quand le volet est à moitié baissé) ; 2 garde-corps **vitrés** (n° 72) | moyen : paramètres de `Facades.fenetre()` (`style`) |
| **Façades** | brique patinée (`usure`), pub peinte « CHOCOLAT AU LAIT » | brique **nettoyée** (`usure` divisée par 2) ; **2 immeubles ravalés en enduit clair** (isolation par l'extérieur : aplat `enduit` n° 69-70, appuis alu, plus de corniche de brique) ; la pub peinte devient un **fantôme délavé** (mêmes lettres, couleurs remplacées par `brique_claire` et `pierre`, 50 % des pixels de lettre retirés en trame régulière) | faible |
| **Immeuble neuf** | — | l'immeuble à x 1 668 devient une **petite résidence** de même gabarit : bardage bois vertical (n° 71, lames de 3 px), balcons à garde-corps vitré, rez-de-chaussée en retrait avec porte vitrée et interphone | moyen : un nouveau type `"facade": "residence"` |
| **Toits** | antennes râteau, cheminées | antennes râteau **presque toutes retirées** (une reste, penchée : clin d'œil) ; **2 paraboles** ; **fenêtres de toit** (velux 18 × 12, vitre `vitre_reflet`) sur les ardoises ; **panneaux solaires** sur un toit de tuiles (grille `bleu_nuit` / `bleu_ardoise`, reflet 1 px `ciel_clair`) ; cheminées gardées | faible |
| **Façades, petits objets** | jardinières, boîtes murales | **unités extérieures de climatisation** (18 × 15, `blanc_chaud` + grille ronde `gris_pierre`) sur 2 façades ; **boîtier fibre** gris ; **bacs de tri** devant la maison (bac à couvercle jaune `or`, bac à couvercle vert `vert`, 15 × 21) | faible |
| **Devantures** (`BATIMENTS`, champ `enseigne`) | CAFE, LIBRAIRIE, EPICERIE, BOULANGERIE, TABAC | **CAFÉ** (terrasse : 2 tables + chaises bistrot, autocollant « CB » sur la vitre) ; LIBRAIRIE → **BARBIER** (enseigne en lettres découpées, poteau rayé rouge et blanc de 6 × 30) ; ÉPICERIE → **SUPÉRETTE** (caisson lumineux à la place de l'auvent, « OUVERT 7J/7 », vitrine à affiches promo jaunes) ; **BOULANGERIE** inchangée (« ARTISAN BOULANGER » en sous-titre) ; **TABAC** garde sa **carotte** (elle existe toujours) + « PRESSE · JEUX » ; un local à x −1 155 devient **vitrine vide « À LOUER »** (papier kraft aux vitres, panneau d'agence) | faible : textes et options existants (`auvent`, `devanture`) + un mode `caisson` |
| **Enseignes** | lettres peintes, auvents de toile | **caissons lumineux** et **lettres découpées** (sans empattement), émissifs la nuit (`led_blanche` n° 73, `lumiere`, `neon_rose`) ; un **« OUVERT » à LED** rouge-rose qui clignote (2 images, 1 im/s) sur la supérette | faible |
| **Pharmacie** | — (rien dans la rue actuelle) | **croix verte à LED** sur le pignon à x 546 (à la place du haut de la pub fantôme) : 24 × 24, alterne **croix / heure / température** (« 08:45 », « 12° » en points 3 × 5, couleur `gain`, émissive) toutes les 3 s : la signature la plus française de 2020 | faible : police à points déjà codée pour le journal lumineux |
| **Mobilier** | lampadaire à cloche, bouche d'incendie, boîte jaune, plaque de rue | **lampadaire LED** (mât anthracite, tête plate 24 × 6, halo plus blanc : `led_blanche`) ; **borne de recharge** (15 × 36, `blanc_chaud` + écran `sarcelle` émissif la nuit, câble vers la Zoé garée) devant une **place peinte en vert** ; **boîte à livres** (ancienne cabine téléphonique 16 × 66 repeinte `sarcelle`, étagères de livres de toutes les couleurs) ; **arceaux à vélos** avec un vélo ; **2 trottinettes en libre-service** couchées sur le trottoir ; **abribus à panneau publicitaire lumineux** (« sucette » 30 × 75, émissive la nuit) ; potelets anthracite ; **inchangés** : boîte aux lettres jaune, bouche d'incendie, plaque de rue | moyen (5 objets neufs, tous petits) |
| **Sol** | dalles, chaussée, passage piéton | + **bande cyclable** (ligne pointillée blanche et pictogramme vélo de 15 × 9 au sol), **« ZONE 30 »** peint, **coussin berlinois** (ralentisseur 30 × 3 en relief) | faible |
| **Véhicules** | R5, 205, 4L, fourgonnette, Porsche 944 | **citadine 2020**, **petite électrique**, **SUV compact**, **fourgon de livraison**, **vélo de livreur** à sac cube, **trottinette** ; voiture du rival selon G3 (§10.3) | moyen : 5 entrées de `MODELES` |
| **Passants** | épaulettes, walkman, berceau puis tricycle | **smartphone** tenu devant le visage (3 × 5 px, écran `led_blanche` émissif la nuit) pour un passant sur deux ; **écouteurs** (1 px blanc) ; **sac à dos** ; **baskets blanches** (2 px) ; doudoune sans manches ; poussette à 3 roues ; vêtements plus sombres (nuit, ardoise, bleu nuit) avec **un** accent saturé par figurine (règle de docs/16 §1.2) | moyen : accessoires de `personnages.gd` |
| **Média (la Gazette)** | journal lumineux ambre « INDICE / CAC 40 » sur le toit, néon rose, **rotatives** en vitrine | **écran géant à LED** dans le rectangle `ECRAN` (points plus serrés, logo + bandeau défilant « CAC 40 ▲ 1,2 % » en ambre, ▲ en `gain`, ▼ en `perte`, toujours avec la flèche) ; **vitrine-studio** dans `ROTATIVE` : plateau d'une chaîne d'info vu de la rue (présentateur derrière un bureau, caméra sur pied, 3 écrans, projecteur) ; enseigne **« GAZETTE INFO »** en lettres découpées, pastille **« EN DIRECT »** en `neon_rose` (jamais en rouge de perte) ; sur le toit, **2 paraboles** et un mât d'antennes ; un **camion-régie à parabole** garé devant pendant la vitrine Covid (variante datée) | moyen |
| **Banque** | porte en bois à deux battants, enseigne dorée, distributeur à écran vert (dès 1986), combiné qui sonne | même immeuble de brique, fronton et **horloge** ; **porte vitrée coulissante** dans `PORTE_BANQUE` (cadre alu, autocollant « sans contact » : 4 arcs de 1 px) ; enseigne en **caisson** (« BANQUE » en lettres blanches sur bandeau `bleu_vif`, émissive la nuit) ; **distributeur encastré** à écran couleur ; panneau « SUR RENDEZ-VOUS » sur la vitre ; l'appel du banquier passe par un **smartphone** (§10.4) | moyen |
| **Maison du joueur** | porte et volets peints, marquise, boîte aux lettres | même volume ; **porte alu anthracite** à imposte vitrée, **fenêtres PVC** à volets roulants (sauf la fenêtre du conjoint, qui garde des volets battants : elle doit rester lisible, docs/17 §4.2), **bacs de tri** devant, boîte aux lettres **normalisée** (jaune toujours), interphone ; jardinet avec un **salon de jardin en résine** | faible |
| **Horizon** (`lointain`) | skyline bleutée, grues, pylônes | + **tours de La Défense plus nombreuses et plus hautes**, **grues de chantier** (Grand Paris Express) plus nombreuses, 1 **éolienne** très lointaine | faible |
| **Nuit** | fenêtres jaunes, globes, néon de la Gazette | moins de fenêtres jaunes, plus de **lumière blanche** (`led_blanche`) : écrans, caissons, sucette, lampadaires LED, smartphones des passants ; la rue de 2020 est **plus froide et plus éclairée** la nuit | faible (calque de lumière existant) |

### 10.2 Palette : 6 ajouts (n° 68 à 73)

| # | Nom | Jour | Nuit | Orage | Usage |
|---|---|---|---|---|---|
| 68 | anthracite | `#3B3F48` | `#1E2034` | `#36363E` | menuiseries alu, mâts, potelets, portes modernes |
| 69 | enduit | `#E4D9C3` | `#64667E` | `#A89E92` | façades ravalées (éclairé) |
| 70 | enduit_ombre | `#BFB29A` | `#50526C` | `#8C8478` | façades ravalées (ombre), appuis |
| 71 | bardage | `#B07D52` | `#483646` | `#7E5E48` | bardage bois de la résidence, salon de jardin |
| 72 | verre_teinte | `#7FA7C4` | `#2E3E62` | `#6C7484` | garde-corps vitrés, porte coulissante, vitrine-studio |
| 73 | **led_blanche** | `#EAF4FF` | = | = | **émissive** : lampadaires LED, caissons, écrans, smartphones |

- Valeurs nuit et orage proposées par analogie avec les rampes existantes (nuit : plus sombre et bleu-violet ; orage : désaturé) : **à recalculer par dev-ville** avec la méthode de `palette.gd` et le contrôle de palette.
- `led_blanche` est la **seule** émissive ajoutée : elle reste claire la nuit, comme `lumiere`. Contraste : elle ne sert jamais de texte d'interface.
- Tout le reste du thème réutilise les 67 couleurs (or pour le bac jaune, vert pour le bac vert, sarcelle pour la boîte à livres et la borne, gain pour la croix de pharmacie comme en 1984).

### 10.3 Véhicules : 5 modèles au format de `Vehicules.MODELES`

Coordonnées **avant** `ECHELLE` (1,95), comme les modèles existants ; profils de caisse tournés vers la droite ; roues de 24 px ; contour encre. Silhouettes génériques : **aucun logo, aucun nom de marque dessiné**.

| Clé | Taille | Profil (polygone) | Vitres | Roues | Couleurs [corps, éclat, ombre] · pare-chocs | Ce qui la date |
|---|---|---|---|---|---|---|
| `citadine` | 74 × 30 | (1,24) (1,15) (3,12) (14,4) (40,3) (50,6) (57,12) (71,15) (73,18) (73,24) | arrière (16,6)(28,6)(28,11)(12,11) ; avant (31,6)(42,5)(51,11)(31,11) | [15, 58] | `blanc_chaud`, `nuage`, `zinc_clair` · `ardoise_sombre` ; variante gris `ardoise`, `zinc_clair`, `ardoise_sombre` | ceinture de caisse **haute**, vitres **basses**, pare-brise très incliné, feux en virgule (`feu` de 6 × 2) |
| `electrique` | 68 × 31 | (1,24) (1,14) (4,11) (13,4) (19,2) (42,2) (52,8) (59,13) (66,15) (67,18) (67,24) | arrière (15,5)(26,5)(26,11)(11,11) ; avant (29,5)(41,4)(50,11)(29,11) | [14, 54] | `ciel_clair`, `blanc_chaud`, `ciel` · `ardoise_sombre` | toit rond, **liseré `bleu_vif`** sous les portes, trappe de recharge (2 × 2) ; **pas de fumée**, passe en silence ; garée à la borne avec son câble |
| `suv` | 76 × 36 | (1,30) (1,16) (3,13) (14,4) (46,3) (55,9) (61,15) (73,17) (75,20) (75,30) | arrière (16,6)(30,6)(30,14)(12,14) ; avant (33,6)(45,5)(53,14)(33,14) | [16, 60] | `ardoise`, `zinc_clair`, `ardoise_sombre` · `nuit` ; variante `rouge_auvent` | caisse **haute**, passages de roue **soulignés de plastique** `nuit` (2 px), barres de toit |
| `livraison` | 84 × 42 | (1,36) (1,3) (3,1) (58,1) (66,14) (80,18) (83,21) (83,36) | avant seule (59,4)(64,4)(70,14)(59,14) | [17, 68] | `blanc_chaud`, `nuage`, `gris_pierre` · `ardoise_sombre` | fourgon haut, **bande `bleu_vif`** et pictogramme de colis (8 × 8) sur le flanc ; s'arrête en double file 4 s avec feux de détresse (feu clignotant 2 images) |
| `rival_2020` | 90 × 27 | (1,22) (1,12) (5,9) (26,3) (52,2) (66,8) (86,11) (89,14) (89,22) | une seule surface vitrée continue (24,4)(52,4)(64,9)(20,9), toit `nuit` | [18, 72] | `blanc_chaud`, `nuage`, `zinc_clair` · `blanc_chaud` | berline **basse et lisse**, poignées affleurantes (aucune), **toit noir vitré**, jantes pleines ; à confirmer quand G3 aura choisi la « folie » du rival |

Deux-roues (sprites de figurine, pas de `MODELES`) : **vélo de livreur** (figurine sur vélo + **sac cube** 18 × 18 `sarcelle` sur le dos), **trottinette électrique** (plancher 21 × 3 + colonne 2 × 27, figurine debout), **vélo cargo** (caisse à l'avant, un enfant dedans : poussette de 2020) ; Solex et Mobylette disparaissent.

Répartition du trafic (poids) : citadine 4, SUV 3, électrique 1, livraison 2, deux-roues 2 ; R5, 205, 4L absentes (une **4L restaurée**, verte, une fois par an de jeu : clin d'œil au joueur qui a fait 1984).

### 10.4 L'appel du banquier en 2020

Le banquier de 2019 (forme à confirmer par K2 : conseiller en agence joignable par l'application) **appelle encore depuis la banque** : la séquence garde son point de départ (`FENETRE_BANQUIER`) et sa durée. Seul le sprite change :

| | 1984 | 2020 |
|---|---|---|
| Objet | combiné qui sonne, 3 images (gauche, centre, droite) | **smartphone qui vibre** 16 × 16, 3 images (décalé de 1 px à gauche, centre, à droite) |
| Ondes | 3 anneaux pixellisés qui s'agrandissent | 3 **arcs** de part et d'autre du téléphone (ondes de vibration), mêmes durées |
| Portrait | M. Lefranc, cravate bordeaux | banquier de 2019 (nom et portrait par K2 / G3) : chemise sans cravate, badge, **tablette** dans les bras |

Même nombre d'images, même cadence (12 im/s) : seule la planche change (`Edifices.enregistrer_objets`).

### 10.5 Variantes datées du thème 2020 (dans le chapitre 2019-2023)

| Période | Effet | Pourquoi |
|---|---|---|
| 03/2020 (dès le 17) → 05/2020 (jusqu'au 10) | **Rue presque vide** : trafic × 0,1 (`facteur` existant de `ville.gd`), rideaux métalliques baissés sur le café, le barbier et la vitrine « À LOUER » ; seuls la supérette, la boulangerie, le tabac et la pharmacie restent allumés ; affiche « RESTEZ CHEZ VOUS » sur la sucette | C'est la vitrine du chapitre ; la rue raconte le confinement sans un mot. Elle montre le présent : rien n'apparaît avant le 17 mars. |
| 05/2020 → 03/2022 | **Masques** sur ≈ 2 passants sur 3 (4 × 3 px `ciel_clair`, liens d'1 px) ; café fermé de 11/2020 à 05/2021 (rideau baissé) | Le joueur reconnaît l'époque d'un coup d'œil. |
| 30/10/2020 → 14/12/2020 | Deuxième confinement : trafic × 0,4, café et barbier fermés | Cohérent avec la Gazette. |
| 03/2020 → 04/2020 | Camion-régie à parabole devant la Gazette | Signature du média pendant la crise. |
| 02/2020 → 03/2020 ; 03/2022 → 04/2022 | **Panneaux électoraux** numérotés (municipales, présidentielle) devant l'école (à x 1 308) | Équivalent des affiches électorales de 1986 et 1988. |
| 2022 → 2023 | Affiche de **prix du carburant** à la station sur la sucette (sans chiffre lisible) ; un passant de plus à vélo | L'inflation et l'énergie se voient sans être lues (la Gazette donne les chiffres). |

Les dates exactes sont à confirmer par le boursier (B3) et le game designer (G3) ; elles vivent dans les données du thème (`variantes_datees`), pas dans le code.

### 10.6 Format de données proposé (lot 09-V : table `ThemeDecor`)

```
"2020": {
  "palette_ajouts": ["anthracite", "enduit", "enduit_ombre", "bardage", "verre_teinte", "led_blanche"],
  "fenetres": {"style": "pvc", "part_volets_roulants": 0.5, "part_alu": 0.25},
  "usure": 0.5,
  "batiments": {                     # par x gauche de BATIMENTS : remplacements de champs seulement
    "-1380": {"enseigne": "CAFÉ", "terrasse": true},
    "-375":  {"enseigne": "BARBIER", "auvent": null, "lettres": "decoupees"},
    "354":   {"enseigne": "SUPÉRETTE", "auvent": null, "caisson": true, "led": "OUVERT"},
    "546":   {"pub": "fantome", "pharmacie_led": true},
    "-1155": {"rdc": "a_louer"},
    "-990":  {"facade": "enduit"}, "1308": {"facade": "enduit"},
    "1668":  {"facade": "residence"}
  },
  "toits": {"rateaux": 1, "paraboles": 2, "velux": true, "solaire": [1134]},
  "mobilier": [["borne_recharge", 420], ["boite_a_livres", -640], ["arceaux", 1210], ["trottinettes", -260],
               ["sucette", 1000], ["bacs_tri", 40]],
  "sol": {"bande_cyclable": true, "zone_30": 1250, "coussin": 600},
  "lampadaire": "led",
  "vehicules": {"citadine": 4, "suv": 3, "electrique": 1, "livraison": 2, "deux_roues": 2},
  "passants": {"smartphone": 0.5, "ecouteurs": 0.3, "sac_dos": 0.3},
  "media": {"nom": "GAZETTE INFO", "ecran": "led", "vitrine": "studio", "toit": "paraboles"},
  "banque": {"porte": "coulissante", "enseigne": "caisson", "distributeur": "couleur", "appel": "smartphone"},
  "maison": {"porte": "alu", "fenetres": "pvc", "bacs_tri": true, "jardin": "resine"},
  "lointain": {"tours": 2, "grues": 3, "eolienne": true},
  "variantes_datees": [{"debut": "2020-03", "fin": "2020-05", "effet": "confinement"}, ...]
}
```
Les positions x sont indicatives (à caler par dev-ville sur la capture). Le thème « 1980 » est la **table vide** : tout prend la valeur actuelle (non-régression au pixel près, CA du lot 09-V).

## 11. Les autres décennies (esquisse, une ligne chacune)

| Thème | Matériaux, façades, devantures | Véhicules | Mobilier, signes d'époque | Média (nom et allure) | Banque et appel |
|---|---|---|---|---|---|
| **1950** | brique **noircie de suie**, enseignes peintes à la main, crémerie « BOF », quincaillerie, mercerie, charbonnier ; pavés | Traction, 4CV, 2CV grise, 203, camion à tôle ondulée, vélos, triporteur | réverbère à crosse, colonne Morris, borne-fontaine, vespasienne, affiches « ancien franc » ; chapeaux, imperméables, bérets | **« LA GAZETTE », journal du soir** : crieur sur le trottoir, **tableau noir à la craie** sur la façade (pas d'écran), presse à plat en vitrine | guichet à grille, **téléphone mural noir à cadran** |
| **1960** | brique et premiers **néons**, « LIBRE-SERVICE », vitrines de télé et d'électroménager ; HLM et tours dans le lointain | DS, Dauphine, 404, Ami 6, 4L (1961), Vespa | **antennes râteau** sur tous les toits, transistors, premières cabines ; costumes étroits, minijupes après 1965 ; nouveau franc (01/1960, variante datée) | **« LA GAZETTE »** + **haut-parleur et studio radio** au 1er étage (« RADIO GAZETTE »), panneau d'affichage à lettres mobiles | téléphone **gris à cadran**, livret d'épargne tamponné au guichet |
| **1970** | devantures **alu et orange-marron**, papiers peints visibles, premières grandes surfaces dans le lointain | R5 (1972), R16, 304, CX, 2CV orange, Mobylette bleue | **cabine PTT**, feux tricolores ; pattes d'éléphant ; **enseignes éteintes la nuit** après 11/1973 (choc pétrolier, variante datée), « chasse au gaspi » (1979) | **« LA GAZETTE »** enseigne lumineuse, **tableau à volets** (palettes qui claquent) pour l'indice | téléphone à cadran beige, premières cartes bancaires |
| **1980** | **rue actuelle**, inchangée au pixel près | R5, 205, 4L, fourgonnette, Porsche 944 | lampadaire à cloche, 3615, walkman, épaulettes | **« LA GAZETTE »** journal lumineux ambre, néon rose, rotatives ; « INDICE » → « CAC 40 » en 06/1988 | combiné qui sonne, distributeur à écran vert dès 1986 |
| **1990** | **caissons lumineux**, vidéoclub, opticien, banque de réseau à logo ; prix **double affichage F / €** de 1999 à 2001 (variante datée) | Clio I, Twingo (1993), 106, Xantia, Espace | abribus, sanisette, cabine à carte, panneaux publicitaires déroulants ; baladeur CD, premiers portables (1998+), banane | **« LA GAZETTE »** + écran à **LED rouge-ambre** et « 3615 GAZETTE », puis « GAZETTE.FR » (1999) | distributeur gris, porte vitrée, téléphone sans fil |
| **2000** | enseignes en **€**, cybercafé, téléphonie, « ADSL » ; premiers ravalements | Clio II, 206, Scénic, C3, Smart | écrans plats en vitrine, Vélib à Paris (pas dans notre banlieue), radars ; téléphone à clapet, écouteurs blancs | **« GAZETTE.FR »** : écran LCD sur le toit, l'enseigne papier reste | distributeur à écran couleur, banque **en ligne** (ordinateur) |
| **2010** | **LED**, burger, cigarette électronique, « 4G », première vitrine vide ; premiers volets roulants | Clio IV, 208, Duster, Zoé (2012), scooter | arceaux à vélos, première borne de recharge, trottinettes (fin de décennie) ; smartphones, casques audio | **« GAZETTE.FR »** puis **« GAZETTE INFO »** : écran LED couleur, premier plateau vidéo | appli bancaire, notification sur smartphone |
| **2020** | **§10** | §10.3 | §10.1, §10.5 | **« GAZETTE INFO »**, écran géant, vitrine-studio | smartphone qui vibre, porte coulissante |

Constante éditoriale du média : **la Gazette existe à toutes les époques** et change de support (journal → radio → panneau → écran → site → chaîne) ; le joueur garde son repère, et l'évolution du support raconte l'histoire de l'information financière. Nom et support définitifs à confirmer par le boursier (B3 : « nom et support du média en 2019 ») et le client.

## 12. Ordre de réalisation et coût (U2)

| Étape | Contenu | Lot |
|---|---|---|
| 1 | `ThemeDecor` + thème « 1980 » vide (non-régression), `ville.regler_theme`, option de capture `--theme` | 09-V |
| 2 | Thème « 2020 » : palette n° 68-73, menuiseries, devantures, enseignes, mobilier (5 objets), 5 véhicules, accessoires des passants, Gazette (écran, studio), banque (porte, caisson, smartphone), maison | 12-V |
| 3 | Variantes datées 2020 (confinement, masques, panneaux) | 12-V (fin) ou lot suivant |
| 4 | Un thème par chapitre ouvert ensuite (≈ 1/3 du thème 2020 chacun, car les objets se réutilisent : la cabine de 1990 est la boîte à livres de 2020 sans livres) | avec chaque chapitre |

Captures de contrôle : `rue_theme_2020` (jour, nuit, orage, hiver), `rue_theme_1980` identique à `main` au pixel, `rue_2020_confinement`, `media_2020`, `banque_2020_appel` ; ligne `RUE theme=<id> couleurs_hors_palette=0 ancres_identiques=oui`.

## 13. Où des illustrations apporteraient le plus (U1 et U2)

1. **Une vignette par chapitre** (la rue à cette époque, 192 × 108 px d'art) pour la fiche du chapitre : c'est ce que le joueur regarde au moment de choisir. Priorité 1.
2. **Les portraits des 3 profils** de chaque chapitre (48 × 48, 3 expressions) : la fiche de profil vit par le visage.
3. **Le banquier et le visage du média de chaque époque** (48 × 48) : ils incarnent le changement d'époque dans les cartes.
4. Le décor de la rue, lui, reste en code : les thèmes sont des variantes de la rue existante, et une illustration externe casserait la continuité « même rue, huit âges ».

## 14. Questions ouvertes (U2)

| # | Question | Pour qui |
|---|---|---|
| T1 | Nom et support du média en 2019 : « GAZETTE INFO » chaîne d'info, ou garder « LA GAZETTE » avec son site ? | Boursier (B3), client |
| T2 | Forme du banquier en 2019 (conseiller en agence + appli) et son portrait | Banquier (K2), game designer (G3) |
| T3 | Voiture et folie du rival de 2019 (berline électrique proposée) | Game designer (G3) |
| T4 | Variantes datées du Covid (rue vide, masques) : acceptées, ou jugées trop lourdes émotionnellement ? Je les recommande (sobres, sans texte) | Client |
| T5 | `led_blanche` émissive : seule exception à « ajouts non émissifs » de docs/16 §8.2 | Chef de projet |
