/* Règles chiffrées (03 §7) : fiscalité, frais, découvert, fonds, objectifs. */
window.DATA_REGLES = {
  /* Fiscalité simplifiée « taux unique » (01 §7.4, arbitrage A6).
     cto = compte-titres (dividendes, coupons, plus-values) ; pea5 = PEA de plus de 5 ans. */
  impots: [
    { de: 1978, cto: 16, pea5: null },
    { de: 1992, cto: 16, pea5: 0 },
    { de: 1998, cto: 26, pea5: 11 },
    { de: 2008, cto: 30, pea5: 13 },
    { de: 2013, cto: 35, pea5: 15.5 },
    { de: 2018, cto: 30, pea5: 17.2 }
  ],

  /* Frais = max(minimum, taux × montant), achats et ventes d'actions et d'ETF (03 §7.5).
     Minimum en euros (50 F = 7,62245 €). */
  frais: [
    { de: "1978-01", taux: 1.3, min: 7.62245 },
    { de: "2000-01", taux: 0.8, min: 10 },
    { de: "2008-01", taux: 0.5, min: 5 },
    { de: "2019-01", taux: 0.1, min: 1 }
  ],
  /* Taxe sur les transactions financières : achats d'actions seulement (pas les ETF) */
  ttf: [
    { de: "2012-08", taux: 0.2 },
    { de: "2017-01", taux: 0.3 },
    { de: "2025-04", taux: 0.4 }
  ],

  /* Découvert (03 §7.6) */
  decouvertTolereM: 1,     // en mois de salaire
  failliteMois: 3,         // mois consécutifs au-delà du découvert toléré
  agios: [
    { de: 1970, taux: 20 },
    { de: 1991, taux: 15 },
    { de: 2009, taux: 16 }
  ],

  /* Fonds (03 §7.3) */
  sicav: { entree: 2, gestion: 1.5 },
  etf: { gestion: 0.25 },
  pea: { ansExoneration: 5 },

  /* Objectifs (03 §7.7) */
  objectifs: {
    inflation: {
      libelle: "Battre l'inflation", court: "battre l'inflation", difficulte: 1, conseille: true,
      description: "Finir plus riche en baguettes qu'au départ."
    },
    maison: {
      libelle: "Acheter sa maison", court: "acheter ma maison", difficulte: 2,
      coefCousin: 0.9, ans: 8
    },
    retraite: {
      libelle: "Une retraite tranquille", court: "une retraite tranquille", difficulte: 3,
      coefCousin: 1.0
    }
  },

  /* Coussin conseillé, en mois de dépenses */
  coussinMois: 3,

  /* Vitesses : durée d'un mois en millisecondes (03 §3.2) */
  vitesses: [0, 4000, 2000, 1000]
};
