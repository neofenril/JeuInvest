/* Événements de vie retenus pour la V1 (01 §7.6, 03 §6.2).
   M = mois de salaire normal du personnage ; SMN = salaire moyen net de l'année.
   freq : probabilité par an. effet : type de mécanique dans le moteur.
   Dans les textes : {montant}, {duree}, {pct}, {prenom}. */
window.DATA_VIE = {
  parAn: { min: 1, max: 3 },
  ecartChomageMois: 60,      // au plus une perte d'emploi tous les 5 ans
  chomageTaux: 0.65,         // salaire remplacé à 65 %
  naissanceMax: 2,
  naissanceAge: [25, 40],
  naissanceSupp: 0.09,       // vie courante + 9 % du salaire, définitivement
  coincidenceApresMois: 12,  // panne de voiture forcée pendant un krach, après le 12e mois
  primeTutorielMois: 7,      // index de mois (0 = premier mois) : prime scriptée du « mois 8 »
  escargots: { perte: 0.9, gain: 1.5, delai: [6, 12] },

  types: {
    voiture: { freq: 0.15, effet: "cout", coutM: [0.6, 1.2], picto: "voiture",
      titre: "La voiture rend l'âme",
      texte: "Le garagiste est formel : embrayage et courroie. La facture s'élève à {montant}." },
    electromenager: { freq: 0.15, effet: "cout", coutM: [0.3, 0.8], picto: "chaudiere",
      titre: "Panne d'électroménager",
      texte: "Le lave-linge a rendu l'âme en plein essorage. Le réparateur demande {montant}." },
    chomage: { freq: 0.04, effet: "chomage", duree: [6, 12], picto: "valise",
      titre: "Vous perdez votre emploi",
      texte: "Votre entreprise réduit ses effectifs. Pendant {duree} mois, l'assurance chômage vous versera 65 % de votre salaire. Vous réduisez vos dépenses, mais pas votre loyer." },
    medical: { freq: 0.10, effet: "cout", coutM: [0.2, 0.6], picto: "coeur",
      titre: "Frais de dentiste",
      texte: "Une couronne, deux plombages : après la Sécurité sociale et la mutuelle, il reste {montant} à payer." },
    escargots: { freq: 0.05, effet: "escargots", miseM: [1, 6], picto: "enveloppe",
      titre: "Le beau-frère et ses escargots",
      texte: "Votre beau-frère lance un élevage d'escargots « révolutionnaire ». Il promet 30 % par an et vous propose d'investir {montant}." },
    prime: { freq: 0.30, effet: "gain", gainM: [0.5, 1.0], picto: "billet",
      titre: "Prime exceptionnelle",
      texte: "Bonne année pour votre entreprise : une prime de {montant} est versée sur votre compte courant." },
    augmentation: { freq: 0.15, freqCadre: 0.25, effet: "augmentation", pct: [5, 12], picto: "etoile",
      titre: "Augmentation !",
      texte: "Votre travail est reconnu : votre salaire augmente de {pct} %, définitivement." },
    heritage: { freq: 0.03, effet: "gain", gainSMN: [6, 24], picto: "maison",
      titre: "L'héritage de la grand-tante",
      texte: "La grand-tante Simone vous a couché sur son testament. Le notaire vous verse {montant}." },
    jeu: { freq: 0.05, effet: "gain", gainM: [0.1, 0.5], grosLot: { proba: 0.001, gainSMN: [5, 50] }, picto: "etoile",
      titre: "Gagné au jeu !",
      texte: "Votre grille a rapporté {montant}. La chance sourit aux audacieux… parfois." },
    naissance: { freq: 0.08, effet: "naissance", picto: "bebe",
      titre: "Une naissance !",
      texte: "Bienvenue au bébé ! Couches, garde, vêtements : vos dépenses de vie courante augmentent d'environ 9 % de votre salaire, allocations déduites." },
    demenagement: { freq: 0.08, effet: "demenagement", coutM: 0.5, depotLoyers: [1, 2], loyerVar: 0.15, picto: "maison",
      titre: "Déménagement",
      texte: "Il faut déménager. Camion, cartons et dépôt de garantie : {montant} à payer. Votre nouveau loyer est {sens} de 15 %." }
  },

  /* Issue des escargots, annoncée par courrier 6 à 12 mois plus tard */
  escargotsPerdu: { titre: "Des nouvelles des escargots",
    texte: "Le beau-frère a disparu, les escargots aussi. Votre mise de {montant} est perdue." },
  escargotsGagne: { titre: "Des nouvelles des escargots",
    texte: "Incroyable : l'élevage a marché ! Le beau-frère vous rend {montant}." },
  retourEmploi: { titre: "Nouvel emploi",
    texte: "Vous retrouvez un emploi, au même salaire qu'avant (indexé)." }
};
