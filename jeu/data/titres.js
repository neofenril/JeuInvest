/* Titres humoristiques du bilan (03 §7.9), évalués dans l'ordre : le premier qui correspond l'emporte.
   La condition de chaque id est codée dans js/score.js (Score.conditionsTitres). */
window.DATA_TITRES = [
  { id: "faillite",   titre: "Hébergé chez belle-maman",           regle: "Faillite." },
  { id: "panique",    titre: "Roi de la panique",                  regle: "Au moins 2 ventes en panique." },
  { id: "escargots",  titre: "Éleveur d'escargots",                regle: "Escargots acceptés… et perdus." },
  { id: "rentier",    titre: "Rentier de la Côte d'Azur",          regle: "Objectif atteint et les 3 témoins battus." },
  { id: "oeufs",      titre: "Tous les œufs dans le même panier",  regle: "Une ligne a dépassé 60 % du patrimoine puis perdu plus de la moitié." },
  { id: "trader",     titre: "Trader du dimanche",                 regle: "Plus de 12 ordres par an en moyenne." },
  { id: "fourmi",     titre: "Fourmi du Livret A",                 regle: "Livret A à 50 % ou plus du patrimoine, en moyenne." },
  { id: "neveu",      titre: "Neveu de Tonton Matelas",            regle: "Compte courant à 30 % ou plus du patrimoine, en moyenne." },
  { id: "metronome",  titre: "Métronome de l'épargne",             regle: "Un versement automatique sur un fonds ou un ETF pendant 10 ans ou plus." },
  { id: "herbe",      titre: "Épargnant en herbe",                 regle: "Les autres titres seront pour la prochaine fois !" }
];

/* Les 3 témoins et leurs répliques selon leur rang au bilan (04 §1 Q4) */
window.DATA_TEMOINS = {
  matelas: {
    nom: "Tonton Matelas", initiale: "M",
    regle: "Garde tout sur son compte courant.",
    devant: "Au moins, mes billets, je peux les toucher !",
    derriere: "Bah… sous le matelas, au moins, je dors tranquille."
  },
  livret: {
    nom: "Tata Livret", initiale: "L",
    regle: "Met tout sur le Livret A, dans la limite du plafond.",
    devant: "Le Livret A, mon petit, ça ne fait jamais de mauvaise surprise.",
    derriere: "Tu as pris des risques… et ça a payé. Bravo !"
  },
  indice: {
    nom: "Cousin Indice", initiale: "C",
    regle: "Garde 3 mois de dépenses sur le livret, puis place tout le reste chaque mois dans un fonds indiciel, sans jamais paniquer.",
    devant: "J'ai tout mis dans l'indice chaque mois, sans jamais regarder les cours. Ennuyeux, mais efficace !",
    derriere: "Chapeau ! Tu as fait mieux que l'indice. Peu de gens y arrivent."
  }
};
