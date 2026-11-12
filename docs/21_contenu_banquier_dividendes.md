# Contenu du banquier : dividendes (lot 03, questions K1 et K2)

> Auteur : banquier. Date : 2026-11-12. Certitude : **A** vérifié, **B** probable, **C** reconstitué ou convention de jeu.
> Réponses à `docs/lots/lot_03.md` §8 (K1, K2). Contenu pédagogique et historique, sans conseil d'investissement.

## K1. Taux sur les dividendes et avoir fiscal (1986-1988)

### 1.1 Verdict sur le « 16 % unique »

**Confirmé comme convention de jeu, pas comme taux réel.** Aucun taux de 16 % n'a existé sur les dividendes d'actions en 1986-1988.

| Point | Valeur | Cert. |
|---|---|---|
| Régime réel des dividendes d'actions françaises, 1965-2004 | Dividende ajouté au revenu imposable au **barème progressif de l'IR**, majoré de l'**avoir fiscal** (crédit d'impôt = **50 % du dividende net**), imputé sur l'impôt et restituable si l'impôt est insuffisant | A (création loi du 12/07/1965, suppression loi de finances 2004 art. 93, effet au 01/01/2005 ; sources 1, 2) |
| Prélèvements sociaux sur dividendes avant 1991 | Aucun (la CSG naît en 1991) | A |
| Abattement forfaitaire annuel sur revenus de capitaux mobiliers, années 1980 | Existait (de l'ordre de quelques milliers de francs par foyer) ; montant exact 1986-1988 non vérifié | C |
| Taux « 16 % » de docs/03 §7.4 et 01 §7.4 (table retenue par le client, A6) | Taux **global simplifié** « tout compris » appliqué au compte-titres 1978-1991 : il condense IR, avoir fiscal et abattements pour un foyer modeste | C (convention de jeu, validée par le client) |
| Écart avec ma proposition initiale 01 §5.2 (10 % pour les dividendes 1978-1990) | Le client a retenu 16 % uniforme (A6) : **le 16 % prime** | A (décision) |

Ordre de grandeur de la réalité, pour un foyer comme Gérard et Sylvie (tranche marginale modeste) : dividende de 100, avoir fiscal de 50, base imposable de 150. Si la tranche marginale est inférieure à environ 33 %, l'impôt sur ces 150 est **inférieur** à l'avoir fiscal : l'impôt net sur le dividende est nul, voire négatif (crédit imputé sur le reste de l'impôt). Le 16 % du jeu est donc plutôt **prudent** (il charge un peu plus le joueur que la réalité pour un petit foyer). Cet ordre de grandeur est du raisonnement de ma part (C), pas un taux publié.

Conséquences pour le jeu :
- Garder 16 %, non modélisé à part, comme prévu en D2 du lot : rien à changer dans le moteur.
- Ne jamais écrire dans le jeu « les dividendes étaient taxés à 16 % » : écrire « le jeu applique 16 % » ou « environ 16 % (simplifié) ».
- La bulle (?) existante du jeu (« Simplifié : à l'époque, les petites ventes étaient souvent exonérées ») concerne les plus-values ; elle ne couvre pas les dividendes.
- Pas de PEA en 1984-1988 (créé le 16/07/1992) : la règle « 0 % dans un PEA » reste non éprouvée dans la démo.

### 1.2 Phrase sur l'avoir fiscal (≤ 25 mots)

Version recommandée (mot à mot, **21 mots**, à placer dans la notification du 1er dividende ou en bulle « Le saviez-vous ? ») :

> « Simplifié : le jeu applique 16 %. En réalité, l'avoir fiscal, un crédit d'impôt de 50 % du dividende, réduisait l'impôt des actionnaires. »

Compte : Simplifié (1) le (2) jeu (3) applique (4) 16 (5) % (6) En (7) réalité (8) l'avoir (9) fiscal (10) un (11) crédit (12) d'impôt (13) de (14) 50 (15) % (16) du (17) dividende (18) réduisait (19) l'impôt (20) des (21) actionnaires (22). **22 mots** en comptant « % » comme un mot, 20 sans les symboles : dans les deux cas ≤ 25.

Variante plus historique, sans mention du jeu (≤ 25 mots, 21 mots) :

> « À l'époque, l'État accordait aux actionnaires un « avoir fiscal » : un crédit d'impôt de 50 % du dividende, déduit de leur impôt. »

Remarques de fond : l'avoir fiscal n'existait que pour les dividendes de sociétés françaises (donc vrai pour Elf, L'Oréal, Peugeot, Saint-Gobain) ; il visait à éviter la double imposition (la société avait déjà payé l'impôt sur les sociétés). Le chiffre « 50 % » est du dividende net perçu (crédit = moitié de la somme perçue), pas du dividende brut : à ne pas détailler dans le jeu. Certitude : **A** pour 1965 et 2004 ; **A** pour le taux de 50 % pour les actions françaises « ordinaires » (taux réduit à 10 % pour certains organismes et à 25 % pour certains titres anciens à d'autres époques : sans objet ici).

## K2. Relecture des quatre textes provisoires de `banque.json > messages`

Constat : les clés `dividendes_titre`, `dividendes_premier`, `dividendes`, `releve_dividendes` n'existent pas encore dans `banque.json` (03-L non écrit à ma lecture). J'ai donc relu les **intentions** du plan (lot_03 D4) et propose les textes corrigés ci-dessous. Placeholders : `{montant}` net total en francs, `{detail}` « Elf, L'Oréal et 1 autre », `{taux}` = 16 (lu dans les règles, ne pas écrire en dur), `{mois}`, `{dividendes}` net de l'année.

Corrections de fond apportées à l'intention du plan :
1. Le **16 %** n'est pas écrit en dur : sinon un changement de règle crée une incohérence.
2. « Dividende » est défini une fois, à la première occurrence (« une notion = un moment »).
3. Rappel que le dividende **n'est pas garanti** et que le **cours ne le compense pas** (le jeu ne détache pas le cours : ne pas suggérer qu'acheter juste avant mai est une astuce).
4. Pas de verbe d'incitation, aucune prévision, aucun rendement futur.

| Clé | Texte proposé | Mots |
|---|---|---|
| `dividendes_titre` | `Vos actions vous versent un dividende` | 6 |
| `dividendes_premier` | `Un dividende, c'est la part des bénéfices que l'entreprise reverse à ses actionnaires, en général une fois par an. Vous touchez {montant} ({detail}), après {taux} % d'impôt. Il n'est pas garanti d'une année sur l'autre, et le cours de l'action continue de bouger.` | 46 |
| `dividendes` (suivants) | `Dividendes de {mois} : {montant} versés ({detail}), après {taux} % d'impôt.` | 12 |
| `releve_dividendes` | `Vos actions vous ont versé {dividendes} de dividendes cette année, après impôt.` | 12 |

Si le client veut la phrase sur l'avoir fiscal dans le relevé (plutôt que dans la notification du 1er dividende), l'ajouter au relevé de décembre **seulement la première année où `dividendes` > 0** : `releve_dividendes` + la phrase de K1 (12 + 22 = 34 mots, ≤ 60).

Points de vigilance (non bloquants) :
- « après impôt » : correct pour la convention de jeu ; la notification d'une année suivante n'a pas besoin de répéter le taux si l'interface le montre ailleurs.
- Pluriel : « Dividendes de mai » fonctionne avec 1 ou plusieurs titres ; la cartouche d'interface (« Elf : + 840 F ») reste inchangée.
- Une année sans dividende (`divNul`, cas de Peugeot si confirmé par le boursier) : prévoir une courte notification neutre, par exemple `Peugeot n'a pas versé de dividende cette année : l'entreprise gardait ses bénéfices pour se redresser.` (17 mots) ; **à ne pas employer avant confirmation du boursier (B2)** pour les années concernées.

## Sources

1. Assemblée nationale, questions écrites de la 12e législature sur l'avoir fiscal (rappel de la loi du 12/07/1965 et du crédit égal à la moitié des sommes perçues) : https://questions.assemblee-nationale.fr/dyn/12/questions/QANR5L12QE30902.pdf
2. Sénat, rapport sur la fiscalité de l'épargne (suppression de l'avoir fiscal par la loi de finances 2004, remplacement par l'abattement de 50 % puis 40 %) : https://www.senat.fr/rap/r04-052/r04-05246.html
3. Sénat, document de 1983-1984 décrivant le crédit d'impôt égal à la moitié des sommes perçues : https://conferenceconsensuslogement.senat.fr/leg/1983-1984/i1983_1984_0475.pdf
4. Internes : `docs/01_enveloppes_france.md` §3.3 et §5.2 (table fiscale), `docs/03_cahier_des_charges.md` §7.4, `docs/connaissances/banquier.md` §1.3 et §2.5.

## Ce que je n'ai pas pu vérifier

- Les barèmes de l'IR et le montant exact de l'abattement sur revenus mobiliers en 1986-1988 (CGI et lois de finances de l'époque) : C. La recherche web ne les restitue pas.
- Le texte exact des quatre clés actuelles de `banque.json` : à relire quand 03-L aura écrit les messages ; mes propositions les remplacent telles quelles.
