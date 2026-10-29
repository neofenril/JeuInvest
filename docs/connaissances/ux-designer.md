# Base de connaissances : UX designer

> À lire au début de chaque mission (après `CLAUDE.md`), à mettre à jour à la fin. Garder entre 100 et 200 lignes : remplacer ce qui est obsolète au lieu d'empiler.
> Documents de référence : `docs/04_ux_design.md` (logique des écrans, V1 web) et `docs/09_direction_artistique_godot.md` (direction artistique, ville, game feel, mise en page Godot). Arbitrages du client : `docs/connaissances/client.md` (A20 à A35).

---

## 1. Principes retenus (valables quel que soit le moteur)

1. **Le temps est le héros** : date, contrôles du temps et frise toujours visibles.
2. **Un lieu par type de message** (depuis la vision « ville ») : maison = vie, banque = banquier, média = news. Le joueur sait d'où vient un événement avant de lire.
3. **Une notion = un moment** : une notion n'apparaît que quand elle sert (inflation avec la baguette, dividende quand il tombe, coussin quand la voiture casse).
4. **Tout chiffre qui bouge se voit** : il roule, il clignote, il porte une flèche ▲/▼ et un signe +/−. Jamais la couleur seule.
5. **Le spectacle ne casse pas le rythme** : animation de bâtiment de 2 s au maximum, passable d'un toucher ; la lecture se fait jeu en pause, jamais chronométrée.
6. **On ne révèle jamais l'avenir** : pas de marqueur d'événement de marché futur sur la frise ; la conséquence d'un choix arrive 12 mois plus tard (carte de rappel).
7. **Le banquier informe, ne conseille jamais** (A33) : pas de « achetez », pas d'annonce de krach.
8. **Une seule vedette à la fois** : les effets majeurs passent par une file.
9. **Tactile d'abord** : rien d'indispensable au survol ; cibles de 80 px virtuels (≈ 49 dp) au minimum.
10. **Lisible avant d'être joli** : les couleurs sémantiques, les boutons et la disposition ne changent jamais avec l'époque ; seuls le décor, l'accent et le journal changent.
11. **Ne pas pousser au clic** : dans une présentation du banquier, « Ouvrir » et « Pas maintenant » ont exactement le même style ; refuser est sans pénalité.
12. **Les frais sans culpabiliser** : « les frais ont coûté », jamais « vous avez perdu » ; couleur cuivre `#C77B4A`, jamais le rouge des pertes ; toujours une option moins chère à côté ; le 7 % est « une hypothèse, pas une promesse ».
13. **Comparer au choix du débutant** : la référence permanente est « tout au Livret A » (Tata Livret), pas l'indice.

---

## 2. Ce qui reste valable de la V1 web (04)

| Section de 04 | Statut |
|---|---|
| §1 Q1 à Q6 (réponses au client) | Valable, sauf la disposition en 3 colonnes (remplacée par la ville et le HUD) |
| §2 Parcours complet | Valable |
| §3.1 Écran titre | **Remplacé** : la ville au crépuscule, logo néon sur le toit du média (09 §5) |
| §3.2 Création de partie (3 cartes et récapitulatif, phrase qui se remplit) | Valable (hors de la tranche minimale) |
| §3.3 Écran principal | Contenu et états valables (vide, gain, perte, krach, pause, découvert) ; **disposition remplacée** par 09 §4 |
| §3.4 Marché | Contenu valable (montant en argent, frais visibles, garde-fou non bloquant, onglet Vendre avec impôt et PEA) ; devient le guichet de la **fenêtre Banque** (13 §2) |
| §3.5 Journal | Grammaire valable (manchette ≤ 8 mots, date, 40 mots, impact personnel, 3 choix) ; précédé de l'animation du média |
| §3.6 Courrier et notifications | Règle modale / notification valable ; précédé de l'animation de la maison |
| §3.7 à §3.10 | Valables ; le banquier porte désormais nouveaux produits, bilan annuel et rappel à 12 mois |
| §3.11 Bilan | Séquence de révélation valable (hors de la tranche minimale) |
| §4 Frise | Règles valables (curseur continu, marqueurs, pas de futur) |
| §5 Onboarding et tutoriel | Valable ; à rejouer à travers les bâtiments plus tard |
| §6 Animations, §7 Direction artistique | **Remplacés** par 09 §2 et §3 |
| §7.5 Accessibilité, §7.6 Graphiques pour débutants | Valables (axe depuis 0 pour le patrimoine, 4 graduations, pas de chandeliers) |

---

## 3. Retours du joueur réel

| Date | Retour | Conséquence |
|---|---|---|
| 2026-10 | « Graphisme insuffisant, la version site ne me plaisait pas ; je veux beaucoup plus poussé. » | Le rendu n'est plus un habillage de fin : il se juge dès la première livraison. Passage à Godot. |
| 2026-10 | « Je veux une version mobile. » | Conception PC et téléphone dès le départ ; tout au toucher. |
| 2026-10-26 | « Une sorte de **ville en fond**, avec la **maison** de mon personnage, un bâtiment **banque** : quand le banquier m'appelle, on voit une animation d'appel depuis ce bâtiment ; un bâtiment **média** avec une animation pour chaque news. » | L'écran principal devient une rue vivante en diorama ; HUD par-dessus ; 3 bâtiments sources d'événements et points d'entrée (A31 à A34). |
| 2026-10-26 | Mobile en **paysage**, comme le PC (A35). | Une seule mise en page, un seul thème ; le portrait est abandonné. |
| 2026-10-26 | Après la 1re démo : aime les pop-ups d'événements et le banquier **didactique** ; temps trop rapide ; veut plus de produits, l'assurance-vie (succession), une introduction progressive comparée à ce qu'il connaît ; clic extérieur pour fermer ; voitures plus rapides en accéléré. | Rythme de 8 s par mois ; banquier seul canal des produits (A37) ; doc 13. |
| 2026-10-27 | Espacer compte et patrimoine ; voir la performance face à « tout au compte courant et au Livret A » ; crash de voiture ; naissance (jumeaux possibles) ; frais avec exemples parlants (10 000 à 2,5 % contre 0,5 % sur 20 ans). Démo 1984-1988 validée ; pas de questionnaire de risque. | Comparateur Tata Livret permanent (R12) ; pédagogie des frais (A44) ; doc 13. |

---

## 4. Direction actuelle (résumé de 09)

- **Intention** : « Ma rue, de 1978 à aujourd'hui. » Ville en aplats (lumière du jour) + HUD sombre et lumineux (ce qui se compte) + papiers au premier plan (ce qui arrive).
- **Style de ville recommandé** : A, diorama de face en aplats, 4 plans de parallaxe, 2 tons par volume, pas de contour noir, lumières sur un calque additif non assombri. Alternatives proposées au joueur (point O9) : B isométrique (coût × 3), C silhouettes néon.
- **Rue** : monde de 2 560 × 1 080 ; zone utile de 1 400 × 700 qui contient maison (gauche), média (centre, le plus haut, écran et bandeau LED sur le toit), banque (droite). Le reste est du décor pour les écrans larges.
- **Vie** : cycle jour et nuit de 60 s réelles, indépendant de la vitesse (évite le clignotement en ×3) ; saisons liées aux mois ; 3 à 5 voitures, 4 à 8 passants ; pause = ville figée, ciel bleui (uniforme `gel`).
- **Époque** : table de variants par année (voitures, kiosque Minitel, cabine, distributeur, écran du toit « CAC 40 » en juin 1988, Grande Arche en 1989).
- **Palette HUD** : panneau `#161E2E`, texte `#EDEAE0`, secondaire `#9AA6BD`, gain `#46E08A`, perte `#FF5C5C`, or `#F2C14E`, gel `#7FD6FF`, accent P1 `#FFB547` / P2 `#3FC3FF` / P3 `#A98BFF`. Daltonisme : gain `#4DA3FF`, perte `#FF9F1C`.
- **Typo** : `SystemFont` (Bahnschrift pour les chiffres, Segoe UI pour l'interface, Consolas pour le bandeau LED, manchettes par décennie), avec replis Android. Texte courant 24 px virtuels, minimum 20.
- **Les 10 effets** : appel du banquier ; news du média et journal qui tournoie (orage, journaux qui jaillissent) ; petite news sans pause ; courrier depuis la maison ; compteurs qui roulent ; pièces volantes ; secousse (caméra plein, HUD 30 %) ; date à volets ; courbe vivante ; boutons, panneaux et bâtiments physiques.
- **Nouvel écran** : carte d'appel du banquier (portrait en formes, texte qui informe, « Voir l'offre » / « Plus tard »).

**Progression par le banquier (13)** :
- **Carte de présentation** à 2 colonnes (tient sans défilement sur téléphone) : texte D ≤ 60 mots ; ticket chiffré avec l'argent du joueur ; comparatif avec le produit détenu le plus proche sur les 4 critères de 12 R8 (rendement, risque, disponibilité, fiscalité), avec pastilles + mot + « plus / moins / pareil », plus une 5e ligne Frais en clair ; 3 boutons. Entrée : la tuile du produit sort de la banque (≤ 2 s) ; sortie : elle y retourne.
- **Fenêtre Banque** = carnet + guichet : album de 3 × 3 cartes (détenue, présentée, nouvelle, silhouette avec un indice de besoin jamais daté), fiche à droite, formulaire d'ordre à la place de la fiche. Jauge « Produits découverts n/9 ». Révélation animée à l'ouverture qui suit une présentation.
- **Frais** : pièces de cuivre vers un compteur « Frais payés depuis le début » ; F01 = confirmation agrandie avec 3 piles de pièces sur 20 ans (sans frais / ce produit / plus chargé) et pièces fantômes ; F03 bandeau au-delà de 2 % avec bouton « Grouper » ; F02 relevé de décembre fusionné avec le bilan annuel ; F06 à la fin.
- **Tata Livret** : pastille « vs tout au Livret A » dans la barre haute (vert ou rouge, flèche et signe) ; dans « Mon argent », sa ligne en tirets et l'écart teinté ; une ligne dans la modale du krach ; écran de fin avec 2 barres, l'écart, les frais et une phrase de synthèse sans reproche.
- **Cadence** : 1 interruption par mois au plus, 2 mois d'écart au minimum (sauf dates historiques et marché), compteur (au-delà de 13, les événements de vie mineurs passent en notification). Calendrier attendu : 11 interruptions scriptées + 1 à 3 aléatoires.

---

## 5. Décisions techniques de présentation (Godot)

- Base **1 920 × 1 080**, étirement `canvas_items`, aspect `expand`, paysage verrouillé sur mobile.
- **Facteur d'échelle** `content_scale_factor` : PC 1,0 ; téléphone 1,7 ; tablette 1,25. Zone effective d'un téléphone 20:9 : ≈ 1 410 × 635, quelle que soit sa définition. La mise en page doit tenir de 1 410 × 635 à 1 920 × 1 200.
- Test sur PC : `F10` = fenêtre de 1 200 × 540 avec facteur 1,7 (identique à un téléphone).
- Ville dans le canevas par défaut avec une `Camera2D` qui cadre la zone utile dans l'espace libre du HUD (recadrage de 0,3 s quand un panneau s'ouvre) ; HUD, effets, modales et transitions en `CanvasLayer` 1, 2, 5 et 10.
- Moteur de rendu Compatibility, `CPUParticles2D`, lueurs dessinées (pas de `WorldEnvironment`).
- Icônes dessinées en `_draw()` (▶, ▲, ▼, combiné, enveloppe), pas en Unicode.
- Un seul `Theme` avec variations de type (`Panneau`, `CartePlacement`, `BoutonPrincipal`, `Journal`, `Courrier`, `CarteAppel`, `EtiquetteBatiment`…) ; valeurs dans 09 §2.8.

---

## 6. Démos

- **Démo 1** (09 §5, livrée et jouée le 2026-10-26) : sept. 1986 → déc. 1988, ville, banquier Saint-Gobain, krach, panne de voiture, CAC 40.
- **Démo V2** (12, 13, en cours) : janv. 1984 → déc. 1988, Gérard (26 ans, avec Sylvie, **non mariés**, A41), naissance en 1985 (jumeaux 1 fois sur 4), héritage de tante Odette en 1988 ; 9 produits présentés un à un par M. Lefranc (D01 à D07) ; banque unique qui ouvre aussi le Livret A (A40) ; 8 s par mois à ×1 ; 15 à 20 minutes.
- État du code constaté le 2026-10-27 : témoin Tata Livret et `ecart_livret()` prêts et testés dans le moteur ; affichage pas encore fait (barre haute, courbe, krach, fin).

---

## 7. Erreurs à ne pas refaire

- **Avoir conçu un tableau de bord d'application** (3 colonnes, fond crème, cartes blanches) : pour ce joueur, le rendu fait partie du plaisir. Toujours partir d'une **scène** et d'un **lieu**, puis poser les chiffres dessus.
- **Avoir traité le mobile en « bonus »** (04 §8 : « tablettes et petits écrans en V2 ») : concevoir pour la zone de 1 410 × 635 dès le départ.
- **Supposer les polices Windows partout** : Bahnschrift, Segoe UI et Rockwell (ce dernier n'est même pas installé par défaut sous Windows) manquent sur Android ; toujours prévoir des replis.
- **Lier un cycle visuel rapide à la vitesse du jeu** : en ×3 (1 s par mois), un jour par mois ferait un stroboscope. Les cycles d'ambiance sont en temps réel.
- **Écrire un document avant d'avoir la vision du joueur** : la première version de 09 (tableau de bord sombre, portrait mobile) a été réécrite le jour même. Demander tôt une image mentale au joueur, ou proposer 2 ou 3 croquis à choisir.

---

## 8. Points ouverts

| # | Question | Pour qui |
|---|---|---|
| O9 | Style de la ville : A (recommandé), B ou C (09 §2.2) | Joueur réel |
| U1 | Sons activés par défaut à 60 % avec bouton muet (au lieu de désactivés, 04 §6.3) | Client |
| U2 | Nom et caractère du banquier (proposition : M. Lefranc) | Client |
| U3 | Demande de ressources : polices OFL, bruitages CC0, puis illustrations (09 §6) | Joueur réel |
| U4 | Comment le tutoriel (04 §5.2) se rejoue à travers les bâtiments | UX, après la tranche |
| U5 | Placement de l'employeur (source du salaire) et de la Bourse comme bâtiments jouables en V2 | UX, client |
| U6 | Paramètres de la 3e pile de F01 (« plus chargé ») pour l'action et l'assurance-vie (13 §3.3) | Banquier |
| U7 | Frais en 5e ligne du comparatif, en plus des 4 critères de R8 (la mission demandait « frais » à la place de « fiscalité ») | Client |

---

## 9. Journal des missions

| Date | Mission | Résultat |
|---|---|---|
| (avant 2026-10, non datée) | Design UX de la V1 web | `docs/04_ux_design.md` : parcours, écrans, frise, onboarding, animations CSS, palette « papier et encre ». |
| 2026-10-26 | Direction artistique pour Godot, PC et mobile | `docs/09_direction_artistique_godot.md`, d'abord en tableau de bord sombre avec portrait mobile, puis **réécrit le même jour** après trois retours : ville en fond avec maison, banque et média (joueur), paysage seul (A35), périmètre de la tranche 1986-1988 (client A31 à A35). Création de cette base de connaissances. |
| 2026-10-27 | Progression par le banquier, frais, comparaison avec le Livret A | `docs/13_ux_progression_banquier.md` : carte de présentation, fenêtre Banque (carnet + guichet), pédagogie des frais, Tata Livret (état du code vérifié), cadence des interruptions, liste priorisée. Aligné sur 12 §7 (A40 à A45). 09 §2.1 corrigé : la banque ouvre la fenêtre Banque. |
