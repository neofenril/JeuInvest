/* Salaires, dépenses et profils (01 §7.3, 03 §5).
   Montants mensuels nets dans la monnaie de l'époque ; interpolation géométrique entre les lignes. */
window.DATA_SALAIRES = {
  table: [
    { annee: 1975, devise: "F", smn: 2500,  jeune: 1300, cadre: 5700,  heritier: 2250, capital: 45000 },
    { annee: 1980, devise: "F", smn: 4300,  jeune: 2200, cadre: 9500,  heritier: 3900, capital: 80000 },
    { annee: 1985, devise: "F", smn: 7200,  jeune: 4000, cadre: 15000, heritier: 6500, capital: 130000 },
    { annee: 1990, devise: "F", smn: 8800,  jeune: 4800, cadre: 17000, heritier: 8000, capital: 160000 },
    { annee: 1995, devise: "F", smn: 10000, jeune: 5500, cadre: 19000, heritier: 9000, capital: 180000 },
    { annee: 2000, devise: "€", smn: 1700,  jeune: 950,  cadre: 3200,  heritier: 1550, capital: 30000 },
    { annee: 2005, devise: "€", smn: 1900,  jeune: 1050, cadre: 3500,  heritier: 1700, capital: 34000 },
    { annee: 2010, devise: "€", smn: 2080,  jeune: 1150, cadre: 3800,  heritier: 1900, capital: 37000 },
    { annee: 2015, devise: "€", smn: 2250,  jeune: 1250, cadre: 4000,  heritier: 2000, capital: 40000 },
    { annee: 2020, devise: "€", smn: 2500,  jeune: 1350, cadre: 4300,  heritier: 2250, capital: 45000 },
    { annee: 2025, devise: "€", smn: 2750,  jeune: 1550, cadre: 4700,  heritier: 2500, capital: 50000 }
  ],

  /* Par décennie : part du loyer (% du salaire) et épargne possible (% du salaire) par profil */
  depenses: [
    { de: 1970, loyer: 14, epargne: { jeune: 10, cadre: 18, heritier: 12 } },
    { de: 1980, loyer: 17, epargne: { jeune: 8,  cadre: 15, heritier: 12 } },
    { de: 1990, loyer: 20, epargne: { jeune: 8,  cadre: 15, heritier: 12 } },
    { de: 2000, loyer: 23, epargne: { jeune: 8,  cadre: 15, heritier: 12 } },
    { de: 2010, loyer: 26, epargne: { jeune: 6,  cadre: 15, heritier: 12 } }
  ],
  /* Points de loyer ajoutés selon le profil (studio, grande ville) */
  ajustLoyer: { jeune: 3, cadre: 5, heritier: 0 },

  profils: {
    jeune: {
      libelle: "Le jeune salarié", court: "jeune salarié", age: 22, feminin: false,
      prenoms: { P1: "Gérard", P2: "Sébastien", P3: "Kevin" },
      accroche: "« Tout à construire. »"
    },
    cadre: {
      libelle: "La cadre pressée", court: "cadre pressée", age: 30, feminin: true,
      prenoms: { P1: "Martine", P2: "Nathalie", P3: "Julie" },
      accroche: "« Gagne bien, dépense autant. »"
    },
    heritier: {
      libelle: "L'héritier", court: "héritier", age: 25, feminin: false,
      prenoms: { P1: "Bernard", P2: "Christophe", P3: "Thomas" },
      accroche: "« Un coup de pouce de mamie. »"
    }
  }
};
