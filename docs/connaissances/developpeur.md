# Base de connaissances du développeur

> À lire au début de chaque mission (après `CLAUDE.md`), à mettre à jour à la fin. Concise : remplacer ce qui est obsolète.
> Dernière mise à jour : 2026-10-27 (export Windows et Android configurés et vérifiés).

---

## 1. État du projet

| Élément | État |
|---|---|
| V1 web `jeu/` | Archivée (A26). Référence de règles et de données ; ne plus modifier. |
| **Démo V2** (`godot/`) | **Faite** : janv. 1984 → déc. 1988, Gérard 26 ans technicien, Sylvie (non mariés). M. Lefranc présente les 9 lignes (D01 → D07), carte à 2 colonnes, carnet 3 × 3, fiches, ordres, frais (F01 3 piles, relevé, F03, compteur cuivre), naissance scriptée 04/1985 (jumeaux 1/4), héritage Odette **un seul pot** (D08 04/1988), baisses du Livret A, plafond, L17, D04 bis, fin de démo. |
| **Historique des pop-ups** | **Fait** (retour joueur) : `EtatPartie.historique`, fenêtre `Modales.historique`, relecture en lecture seule. |
| **Versements automatiques** | **Faits** (11 §8, VP1-VP11) : `scripts/logique/versements.gd`, réglage « CHAQUE MOIS » dans la fiche. VP-D (option, nov. 1987) non fait. |
| Sauvegarde | Automatique, `user://partie_en_cours.sav`, **format 2** (Sauvegarde.VERSION = 2, VERSION_ETAT = 2) : les sauvegardes 1 sont ignorées (nouvelle partie). |
| Tests | `godot/outils/tests.ps1` : **66** (test_logique) + **100** (test_demo) + **8** (test_partie), tous au vert. |
| **Export** | **Fait** (voir §7) : `Exporter_Windows.bat` (exe unique vérifié), `Exporter_Android.bat` (APK debug exporté, non essayé sur téléphone). |
| Reste à faire | P1/P2 partiels (voir §5) ; APK de release (keystore de publication) ; masquer les raccourcis de test (F6-F10) dans l'exe partagé ? |

## 2. Décisions à respecter (utilisateur, client, UX, coordinateur)

- **Paysage uniquement**, base 1920 × 1080, `canvas_items` + `expand`, facteur 1,7 téléphone (zone ≈ 1412 × 635). F10 = téléphone simulé.
- Rythme : `data/rythme.json`. Clic à côté : ferme info, menu, banque, historique, relectures, carte du banquier (= « Pas maintenant »), confirmation (= non) ; **jamais** journal, courrier, fin (décisions).
- Banquier : informe, ne conseille jamais (A33) ; texte ≤ 60 mots ; comparatif 4 critères + ligne Frais.
- Ordre des présentations, cadence (13 §5.3), Gérard, naissance scriptée : inchangés (voir tests `_tests_progression`, `_tests_cadence`).
- **Héritage (coordinateur + banquier, A)** : l'assurance-vie verse 60 000 F en 04/1988 (joueur et témoins) ; **plus de succession ni de D08 bis**. La carte compare la même somme par succession : abattement neveu 10 000 F puis 55 % = 27 500 F de droits, **32 500 F nets** (`banque.json > heritage.comparaison_succession`, calculé par `Banquier.heritage_chiffres()`). Colonne de droite du ticket **hypothétique** : « SI ÇA AVAIT ÉTÉ PAR SUCCESSION », montant gris barré et atténué, « vous auriez attendu 6 mois et payé 27 500 F de droits » ; résumé d'historique « par succession, il ne vous serait resté que 32 500 F ».
- **Événements de vie** : un même événement aléatoire ne revient pas avant `evenements_vie.json > ecartRepetitionMois` (24) mois ; les forcés (coïncidence du krach) sont gardés, l'aléatoire trop proche est retiré (`EtatPartie._espacer_repetitions`, sans tirage en plus). Conséquence : le minimum d'un événement par an n'est plus garanti (CA-12 : ≥ 10 sur 15 ans) ; interruptions de la démo 11 à 13, moyenne 11,3 sur 40 graines.
- **Taux du PEL, partout la même écriture** : « 6,30 % + prime d'État ≈ 8,25 % » (`Banquier.texte_taux_pel(e)`) ; carte du carnet : « ≈ 8,25 % fixe » (`court`). Taux du plan détenu, sinon offre du mois. Les intérêts utilisent le taux prime comprise (`pel.taux`).
- **Versements automatiques (11 §8)** : éligibles Livret A (100 F, 0 %), assurance-vie (300 F, 4 %), SICAV (300 F, 2 %) ; PEL = versement obligatoire existant (300/500/1 000 F, modifiable, 3 600 F/an contrôlés à l'anniversaire : manque prélevé, sinon plan clos) ; emprunt et actions : non (bulle d'explication). Début du mois après salaire et PEL, ordre de création ; tout ou rien si le compte reste ≥ 0 ; 3 refus de suite = suspendu ; Livret A réduit au plafond puis suspendu ; frais sur chaque versement ; VP-A une fois (message persistant) 3 mois après le 1er produit éligible détenu ; VP-B / VP-C à l'activation.
- Frais en **cuivre** `#C77B4A`, jamais en rouge. Couleurs des sources : `Style.SOURCES` (maison orange, banque or, média rose).

## 3. Logique (scripts/logique/, sans nœud)

- `EtatPartie` : moteur. `historique` (du plus ancien au plus récent ; entrée = { m, source, genre appel|journal|courrier|notif, type, titre, resume, choix, montant, a_montant, suffixe, contenu }). Notifications historisées dans `demarrer`/`avancer` (celles de fin de mois avec le mois écoulé) ; modales dans `resoudre_modale` (contenu vu + `choix_fait`). `historique_recent(source)` = antéchronologique avec l'indice `i`. `resume_texte()` = 1re phrase (2 si la 1re < 30 car.), ≤ 110 car. `historiser_evenement(n)` pour les réglages sans pop-up.
- `Banquier` : `titre_historique`, `resume_historique`, `heritage_chiffres`, `texte_taux_pel`, `taux_pel_joueur` ; `releve()` ajoute les versements de l'année (`banque.versements_annee`, remis à zéro).
- `Versements` (statique) : `eligible`, `reglable`, `minimum`, `montants`, `plan`, `actif`, `total_mensuel`, `programmer` / `arreter` / `reactiver` (historisés, effet le mois suivant), `executer` (appelé dans `_entrer_mois` après `Produits.entree_mois`), `_controle_pel`, `messages_du_mois` (VP-A, plafond relevé), `texte_releve`. Plans : `Portefeuille.versements` (sauvegardé) ; PEL : `pel.mensuel`, `pel.verse_annee`.
- `Produits` : PEL (taux figé, mensuel auto, clôture < 4 ans à 2,75 %), emprunt, assurance-vie ; inchangé sauf `verse_annee`.
- `Sauvegarde` : binaire `var_to_bytes` + « JCSV », version, SHA-256 ; fichier temporaire puis renommage.

## 4. Interface (scripts/, scenes/)

- **Historique** : `Modales.historique(e, filtre, defilement)` (genre « historique ») : en-tête, 4 filtres bascule (TOUT / MA MAISON / MA BANQUE / LA GAZETTE avec le nombre, signal `toggled`), ScrollContainer de lignes (pastille ronde de la source avec pictogramme dessiné, date courte, titre, résumé en ellipse, choix en ambre et montant à droite). Ligne = PanelContainer `MOUSE_FILTER_PASS` : toucher bref (< 14 px de déplacement) → `fermer("ouvrir:<i>")`, le glisser fait défiler. `principal._ouvrir_historique` boucle : relecture (`_relire_historique`) puis retour au même filtre et défilement.
- Relectures en lecture seule : `presentation(c, …, lecture=true, bandeau)`, `journal(c, …, lecture_choix)`, `courrier(c, …, e, lecture_choix, ab)` (genre « info », bouton FERMER papier), `releve(n, a)`, `lecture_notification(h, a)`.
- Accès : bouton **HISTORIQUE** à gauche de la frise (barre du bas ; la barre haute est pleine et le panneau « Mon argent » couvre la droite du bas), touche H, menu ≡, bâtiment média (= historique filtré média, « Les nouvelles » de 09 §2.1), « COURRIERS REÇUS › » dans Mon foyer, bouton HISTORIQUE du carnet (remplace « Messages », filtre banque).
- Fenêtre Banque : 3e bouton **CHAQUE MOIS** dans chaque fiche → `_afficher_automatique(pid)` (montants en bascule, ARRÊTER, RÉACTIVER, frais, textes VP-B/VP-C, ou explication si non éligible) ; ligne « Chaque mois, automatiquement : … » dans la fiche ; icône calendrier sur la carte (`CarteProduit.calendrier`). HUD : ligne « Dont versements auto » (masquée à 0) ; Mon foyer : ligne des versements.
- `Piles` : bande réservée en haut (haut_chiffre 100 sur PC, 70 sur téléphone) pour « DANS 20 ANS ».
- Captures (`--etape=`) : nouvelles étapes historique, historique_filtre, historique_entree, historique_journal, historique_courrier, carnet_pel, automatique, automatique_pel (liste complète dans `outils/capture.ps1`). `_strategie_active` vend désormais un placement face à un gros courrier et puise dans le Livret A si le compte est négatif (sinon faillite en 1988 avec un plan SICAV).

## 5. Vérifications faites (2026-10-27) et non faites

- Tests verts (174). Historique : chaque pop-up rangée (modales et notifications comptées), ordre antéchronologique, champs, filtres, entrées Livret A / héritage / krach / relevé, sauvegarde-rechargement identique puis même fin. Héritage : un seul apport hors salaire dans toute la démo (60 000 F en 04/1988). PEL : même taux dans le comparatif, la fiche, la carte, l'ordre et le réglage (test sur la vraie fenêtre Banque dans test_partie). Versements : éligibilité, minimums, plafond, refus et suspension, réactivation, frais 2 %/4 %, VP-B/VP-C, relevé, historique groupé, PEL 3 600 F (régularisé / clos), VP-A unique, sauvegarde.
- Captures relues (v3_*) : historique PC et téléphone, filtre banque, D08 relue (PC, téléphone), journal du krach et courrier relus, carte D08 en jeu, F01 (« DANS 20 ANS » dégagé), carnet avec fiche du PEL (PC, téléphone), versement automatique SICAV (PC, téléphone) et PEL, panneau avec la ligne des versements, rue PC et téléphone, clic à côté.
- **Non vérifié** : défilement tactile de l'historique sur un vrai téléphone (conçu pour : lignes en PASS, seuil de 14 px) ; VP-D (option) non fait ; jauge F03, tuile animée, sons, piles dans le relevé (inchangé) ; relance d'un plan Livret A au relèvement du plafond seulement par message (jamais automatique, conforme VP5).

## 6. Commandes et pièges Godot

- Exe console : `outils\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`. Importer d'abord (`--headless --path godot --import`).
- Tests : lancer les 3 commandes de `godot/outils/tests.ps1` directement (`-ExecutionPolicy Bypass` refusé).
- Capture : sans `--headless`, `--path godot --resolution 1280x720 -- --capture=captures/x.png --etape=y [--telephone]`. Garde-fou 420 s.
- GDScript 4 : `:=` sur une expression Variant = erreur ; pas de lambda multiligne en argument ; `Object.get("CONST")` ne lit pas une constante ; ne pas nommer une méthode statique `reference` ni `notification`.
- `var_to_str` perd parfois 1 ulp : sauvegarde en `var_to_bytes`.
- `"... 16 % d'impôt : %s" % x` : écrire `%%`.
- **PowerShell `Set-Content -Encoding UTF8` ajoute un BOM** : préférer l'outil Edit ou `[IO.File]::WriteAllText` ; retirer le BOM si besoin.
- `BaseButton.button_pressed = true` n'émet pas `pressed` : brancher les filtres bascule sur `toggled`.
- `EtatPartie.m` est un indice absolu dans la période (janv. 1984 = 72) : un arrêt « au mois 30 » s'écrit `m_depart + 30`.
- `Format.montant` affiche les centimes sous 1 000 F : pour des montants ronds (versements, mensualités), utiliser `Format.entier`.
- Label à retour à la ligne : largeur minimale explicite ; ligne tronquée : `clip_text` + `OVERRUN_TRIM_ELLIPSIS` + petite largeur minimale.

## 7. Export (2026-10-27)

- `godot/export_presets.cfg` : « Windows » (release x86_64, `binary_format/embed_pck=true`, icône `assets/icone/icone.ico`, version 0.2.0.0) et « Android » (APK debug, `fr.jeuclaude.demo`, version 0.2 / code 2, arm64 + armv7, immersif, icônes adaptatives `assets/icone/android_avant.png` + `android_fond.png`). Filtres : `include_filter="data/*.json"`, `exclude_filter="tests/*, captures/*, outils/*"` (motif relatif à res://, ne touche pas `scripts/outils/capture.gd`, autoload nécessaire).
- Orientation : `display/window/handheld/orientation=4` (paysage capteur) ; Godot l'écrit `userLandscape` (0xb) dans le manifeste.
- Icônes : SVG source (`icon.svg`, `assets/icone/*.svg`) → `outils/generer_icones.gd` (PNG + ICO à entrées PNG écrit en GDScript). `application/config/windows_native_icon` pointe sur l'ICO.
- Paramètres éditeur : `%APPDATA%\Godot\editor_settings-4.7.tres` (`export/android/java_sdk_path`, `android_sdk_path` vers `outils\`). Godot a généré lui-même le keystore de debug (`%APPDATA%\Godot\keystores\debug.keystore`) dès que le JDK était renseigné ; pas de Gradle (`use_gradle_build=false`) : ni NDK ni cmake requis.
- Vérifier l'exe : `JeuClaude.exe --resolution 1280x720 --log-file <log> -- --capture=<png absolu> --etape=titre|sauver_fermer|reprise` (l'autoload Capture marche dans l'exe ; stdout invisible car exe GUI → `--log-file`). L'exe partage `user://` avec l'éditeur (`%APPDATA%\Godot\app_userdata\JeuClaude`) : ne pas effacer `partie_en_cours.sav`.
- Vérifier l'APK : `build-tools\36.1.0\aapt.exe dump badging|xmltree|list`, `apksigner.bat verify --print-certs`.

## 9. Erreurs à ne pas refaire

- Juger un écran sans le regarder : capturer et relire chaque PNG (bouton HISTORIQUE poussé hors de la barre haute, puis caché par le panneau « Mon argent », bouton FERMER invisible sur le papier du courrier : vus à l'image).
- Sauvegarder automatiquement dès la création de la partie (écran titre « Continuer » au premier lancement).
- Comparer le joueur à un témoin sans tenir compte du décalage de paiement ; passer la même valeur (`ecart_livret`) aux deux affichages.
- Un scénario de joueur peu clair (deux pots d'héritage) se lit comme un bug : une somme, une comparaison.
