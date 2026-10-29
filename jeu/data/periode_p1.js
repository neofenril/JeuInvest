/* Période 1 « Les années fric » : janvier 1978 -> décembre 1992 (03 §1.3, §4, 02 §7 Q1-Q3).
   ancragesIndice : points mensuels de 02 §4.4 (valeur de fin de mois, ou à défaut dernier point ★ du mois).
   Les points marqués "dev" sont fixés par le développeur pour que le récit des événements tienne
   (voir 05_architecture.md, décisions). Les clôtures annuelles viennent de DATA_SERIES et priment. */
window.DATA_P1 = {
  id: "P1",
  nom: "Les années fric",
  debut: 1978,
  graine: 19780101,
  secousses: 3,
  accroche: "Inflation à deux chiffres, élections à hauts risques, la Bourse se modernise.",
  monnaie: "franc",

  ancragesIndice: [
    ["1978-02", 222, "dev"], ["1978-03", 245, "dev"], ["1978-07", 300, "dev"],
    ["1981-04", 410], ["1981-05", 340, "dev"], ["1981-06", 285], ["1981-09", 320], ["1982-06", 345],
    ["1987-01", 1450], ["1987-03", 1500], ["1987-06", 1400], ["1987-09", 1310],
    ["1987-10", 1033], ["1987-11", 963], ["1988-06", 1300],
    ["1990-04", 2130], ["1990-07", 1950], ["1990-08", 1640], ["1990-09", 1472],
    ["1991-01", 1600], ["1991-03", 1800],
    ["1992-05", 2050, "dev"], ["1992-08", 1850, "dev"], ["1992-09", 1700, "dev"], ["1992-10", 1720, "dev"]
  ],
  /* Mois de crise : volatilité mensuelle de 10 % au lieu de 4,5 % */
  moisCrise: ["1981-05", "1981-06", "1987-10", "1987-11", "1990-08", "1990-09", "1992-09"],

  /* Produits propres à la période (compte courant, Livret A et emprunt d'État sont communs).
     ancrages : prix de fin de mois, dans la devise indiquée. */
  produits: [
    { id: "sicav", type: "sicav", nom: "SICAV actions France", court: "SICAV France",
      vl0: 1000, devise: "F", description: "Un fonds qui achète pour vous les grandes actions françaises." },
    { id: "elf", type: "action", nom: "Elf Aquitaine", court: "Elf", secteur: "Pétrole",
      beta: 0.8, volSpe: 0.22, ecartDiv: 1.5, devise: "F",
      ancrages: [["1977-12", 300], ["1978-12", 400], ["1979-12", 620], ["1980-12", 800], ["1981-12", 600],
        ["1982-12", 560], ["1983-12", 750], ["1984-12", 800], ["1985-12", 900], ["1986-12", 950],
        ["1987-12", 800], ["1988-12", 1150], ["1989-12", 1500], ["1990-12", 1350], ["1991-12", 1450],
        ["1992-12", 1500]] },
    { id: "loreal", type: "action", nom: "L'Oréal", court: "L'Oréal", secteur: "Cosmétiques",
      beta: 0.8, volSpe: 0.18, ecartDiv: -1.5, devise: "F",
      ancrages: [["1977-12", 500], ["1978-12", 700], ["1979-12", 820], ["1980-12", 900], ["1981-12", 850],
        ["1982-12", 900], ["1983-12", 1400], ["1984-12", 1700], ["1985-12", 2500], ["1986-12", 3700],
        ["1987-12", 2900], ["1988-12", 4200], ["1989-12", 5400], ["1990-12", 4600], ["1991-12", 5600],
        ["1992-12", 6000]] },
    { id: "peugeot", type: "action", nom: "Peugeot", court: "Peugeot", secteur: "Automobile",
      beta: 1.3, volSpe: 0.30, ecartDiv: 0, devise: "F",
      ancrages: [["1977-12", 350], ["1978-12", 420], ["1979-12", 450], ["1980-12", 300], ["1981-12", 220],
        ["1982-12", 190], ["1983-12", 210], ["1984-12", 180], ["1985-12", 300], ["1986-12", 600],
        ["1987-12", 450], ["1988-12", 800], ["1989-12", 1000], ["1990-12", 600], ["1991-12", 650],
        ["1992-12", 700]] },
    { id: "saintgobain", type: "action", nom: "Saint-Gobain", court: "Saint-Gobain", secteur: "Matériaux",
      beta: 1.2, volSpe: 0.22, ecartDiv: 0, devise: "F", dispo: "1986-12",
      texteNouveau: "Saint-Gobain est privatisé : l'État vend ses actions au public à 310 F.",
      ancrages: [["1986-12", 310], ["1987-12", 230], ["1988-12", 360], ["1989-12", 480], ["1990-12", 350],
        ["1991-12", 400], ["1992-12", 420]] },
    { id: "pea", type: "pea", nom: "PEA", dispo: "1992-07",
      texteNouveau: "Le PEA vient d'être créé ! Un compte pour placer en actions, avec moins d'impôt si vous le gardez 5 ans." }
  ],

  /* Les 2 « actions de grand-père » de l'héritier */
  heritage: ["elf", "peugeot"],

  /* Événements de marché (02 §7 Q2). type : "-", "+", "+piege", "+opportunite", "-silencieux".
     fenetre : nombre de mois pour calculer l'impact sur le portefeuille du joueur. */
  evenements: [
    { id: "p1e1", d: "1978-03", type: "+", fenetre: 1,
      titre: "Législatives : la majorité sauve son siège, la Bourse exulte",
      texte: "Contre les sondages, la majorité sortante garde le pouvoir. Les nationalisations promises par l'opposition s'éloignent. À la corbeille, les acheteurs se bousculent et les cours bondissent.",
      lecon: "Quand une grande incertitude se lève, la Bourse bondit avant qu'on ait eu le temps de réagir." },
    { id: "p1e2", d: "1979-12", type: "-silencieux",
      titre: "Deuxième choc pétrolier : les prix s'envolent",
      texte: "L'essence et le fioul flambent. Les prix montent de plus de 10 % par an : un placement qui rapporte moins que l'inflation vous appauvrit.",
      lecon: "Gagner 8 % quand les prix montent de 13 %, c'est s'appauvrir : seul le rendement réel compte." },
    { id: "p1e3", d: "1981-05", type: "-", fenetre: 1, gravite: "majeure",
      titre: "Mitterrand élu : vent de panique à la corbeille",
      texte: "François Mitterrand est élu président. Son programme prévoit de nationaliser de grandes entreprises. Les investisseurs prennent peur : les cours plongent et des capitaux fuient vers la Suisse.",
      lecon: "Le risque politique fait chuter le marché d'un coup ; celui qui a vendu en juin 1981 a raté le rebond de 1983." },
    { id: "p1e4", d: "1983-03", type: "+", fenetre: 1,
      titre: "Tournant de la rigueur : le franc tient, la Bourse respire",
      texte: "Le gouvernement choisit la rigueur pour rester dans le système monétaire européen. L'inflation doit reculer, les taux d'intérêt aussi. Les investisseurs reprennent confiance.",
      lecon: "Quand l'inflation et les taux baissent, actions et obligations montent ensemble." },
    { id: "p1e5", d: "1986-12", type: "+opportunite", fenetre: 12, produit: "saintgobain",
      titre: "Saint-Gobain privatisé : les Français font la queue aux guichets",
      texte: "Première grande privatisation : l'État vend Saint-Gobain au public, à 310 F l'action. Publicité à la télévision, files d'attente dans les banques : un million et demi de Français souscrivent.",
      lecon: "L'euphorie collective est agréable… mais « tout le monde achète » n'est pas un argument." },
    { id: "p1e6", d: "1987-10", type: "-", fenetre: 1, gravite: "majeure",
      titre: "Lundi noir : la Bourse de Paris dévisse",
      texte: "Wall Street perd plus de 20 % en une seule séance. Paris suit : les actions françaises fondent jour après jour. Les épargnants se ruent aux guichets pour vendre.",
      lecon: "Un krach est brutal mais rarement définitif : celui qui a tenu a tout récupéré en un peu plus d'un an." },
    { id: "p1e7", d: "1990-08", type: "-", fenetre: 4, gravite: "majeure",
      titre: "L'Irak envahit le Koweït : le pétrole flambe, les actions plongent",
      texte: "Les troupes irakiennes envahissent le Koweït. Le prix du pétrole double, on parle de guerre et de récession. Les Bourses du monde entier décrochent.",
      lecon: "Certaines reprises sont lentes : n'investissez en actions que l'argent dont vous n'aurez pas besoin avant longtemps." },
    { id: "p1e8", d: "1992-09", type: "-", fenetre: 1,
      titre: "Maastricht : oui du bout des lèvres, tempête sur le franc",
      texte: "Les Français approuvent le traité de Maastricht à 51 %. Les spéculateurs attaquent les monnaies européennes : la livre et la lire sortent du système. Le franc vacille, la Bourse aussi.",
      lecon: "La volatilité fait partie du voyage ; au même moment, le PEA récompense ceux qui restent investis longtemps." }
  ],

  /* Notifications de contexte, sans pause (03 §6.1) */
  contexte: [
    { d: "1978-07", titre: "Le saviez-vous ?",
      texte: "La loi Monory permet de déduire de ses impôts des achats d'actions françaises. (Dans le jeu : simple anecdote.)" },
    { d: "1988-06", titre: "L'indice change de nom",
      texte: "L'Indice de la Bourse de Paris devient le CAC 40, calculé en continu par ordinateur." }
  ]
};
