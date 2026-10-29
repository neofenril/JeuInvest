/* Gabarits des leçons du bilan (03 §7.9). ordre = importance (1 = la plus importante).
   signe : "-" (erreur à corriger) ou "+" (bonne décision à saluer).
   La condition de chaque id et le calcul des {valeurs} sont codés dans js/score.js. */
window.DATA_LECONS = [
  { id: "faillite", ordre: 0, signe: "-",
    texte: "Le découvert a eu raison de vous en {mois}. Un coussin de 3 mois de dépenses sur le Livret A vous aurait laissé le temps de voir venir." },
  { id: "panique", ordre: 1, signe: "-",
    texte: "Vous avez vendu dans la panique en {mois} ({evt}). Douze mois plus tard, l'indice avait fait {v12} ; vingt-quatre mois plus tard, {v24}." },
  { id: "venteForcee", ordre: 2, signe: "-",
    texte: "En {mois}, vous avez dû vendre {produit} à {var} pour payer « {evt} ». Un coussin plus épais vous l'aurait évité." },
  { id: "dort", ordre: 3, signe: "-",
    texte: "En moyenne, {part} de votre argent a dormi sur le compte courant. Pendant ce temps, la baguette est passée de {b0} à {b1} : cet argent a perdu {perte} de pouvoir d'achat." },
  { id: "frais", ordre: 4, signe: "-",
    texte: "Vous avez payé {frais} de frais en tout, soit {bag} baguettes. Acheter et vendre souvent, c'est payer souvent." },
  { id: "panier", ordre: 5, signe: "-",
    texte: "À un moment, {action} pesait {pct} de votre patrimoine. Tous les œufs dans le même panier : si l'entreprise trébuche, tout trébuche." },
  { id: "peaOublie", ordre: 6, signe: "-",
    texte: "Vous avez payé {impot} d'impôt sur un compte-titres alors que le PEA existait. Dans un PEA de plus de 5 ans, l'impôt aurait été bien plus léger." },
  { id: "tenuBon", ordre: 7, signe: "+",
    texte: "Pendant « {evt} » ({mois}), vous avez tenu bon. Douze mois plus tard, l'indice avait fait {v12}." },
  { id: "coussin", ordre: 8, signe: "+",
    texte: "En {mois}, votre coussin a payé « {evt} » sans rien vendre à perte. C'est exactement son rôle." },
  { id: "versement", ordre: 9, signe: "+",
    texte: "Votre versement automatique sur {produit} a tenu {duree}. La régularité fait le gros du travail, krachs compris." },
  { id: "baguettes", ordre: 10, signe: "+",
    texte: "Votre patrimoine vaut {patrBag} baguettes, pour {misBag} baguettes mises de côté : vous avez battu l'inflation." }
];
