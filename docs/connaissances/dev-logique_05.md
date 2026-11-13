# Notes temporaires de dev-logique-bis (lot 05-L, phase A)

> À reporter dans `dev-logique.md` par dev-logique à la fin de la phase B, puis supprimer ce fichier.

- Modules `Quartier` (Jean-Mi, classement, notifications) et `Krach` (jours, instantané, barres) : statiques, sans état. Montants de `Quartier` en **francs** (l'appelant convertit avec `Format.TAUX_EURO`) ; ceux de `Krach` dans l'unité de l'appelant (euros internes).
- Jean-Mi : le compte de bourse (`equite`) ne passe pas par le compte courant ; après liquidation `equite` = 0 et `dette` est une ligne à part (patrimoine = compte + equite + voiture − credit − dette : dette comptée une fois, docs/27 §2.1). Vente de la Porsche : mouvement = prix − capital restant (écart conservé, pas « négligé » : patrimoine conservé). Crédit restant : 100 833 F en 09/1987, 91 199 F en 02/1988.
- Trajectoire vérifiée (miroir fabriqué 37 500 F, sans salaire) : 09/1987 équité 26 901, patrimoine 49 082 ; 10/1987 perte 52 941, dette 26 040/26 041 ; 12/1988 patrimoine ≈ −47 712.
- Notifications : fonction à appeler CHAQUE mois (y compris en saut) ; priorité rang > ★ > réactive > ordinaire > kiosque ; 1 notification rue/kiosque par mois, aucune un mois de pause.
- GDScript : `R` est un alias PowerShell (Invoke-History) : ne pas nommer ainsi un helper de script ; `var x := <Variant>` interdit (typer `: Array =`, `: Dictionary =`).
