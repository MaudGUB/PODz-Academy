// Donnees de dev FICTIVES : etat initial de la liste Assignations (format des
// items REST SharePoint). Les ecritures de dev vont dans localStorage
// (podz.dev.assignations) et surchargent cet etat. Voir PLAN.md § 2.
(function(){
  var P = {
    camille: {"Id": 11, "Title": "Camille Test",  "EMail": "camille.test@exemple.local"},
    hugo:    {"Id": 12, "Title": "Hugo Test",     "EMail": "hugo.test@exemple.local"},
    ines:    {"Id": 13, "Title": "Inès Test",     "EMail": "ines.test@exemple.local"},
    sarah:   {"Id": 20, "Title": "Sarah Manager", "EMail": "sarah.manager@exemple.local"},
    alex:    {"Id": 30, "Title": "Alex Admin",    "EMail": "alex.admin@exemple.local"}
  };
  function a(id, qui, titre, par, parcoursType, modules, dateCible, etat){
    return {
      "ID": id, "Title": titre,
      "ConsultantId": qui.Id, "Consultant": qui,
      "AssigneParId": par ? par.Id : null, "AssignePar": par || null,
      "Source": par ? "Manager" : "Autonomie",
      "ParcoursType": parcoursType,
      "Modules": modules,
      "DateCible": dateCible ? dateCible + "T00:00:00Z" : null,
      "Etat": etat
    };
  }
  window.PODZ_DEV_ASSIGNATIONS = [
    a(1, P.camille, "Analyste Power BI",            P.sarah, "Analyste Power BI",            "F025;F003;F002;F004;F026;F012;C005", "2026-12-31", "Actif"),
    a(2, P.camille, "Restitution & DataViz",        P.sarah, "",                             "F011;F010;F012",                     "2026-09-30", "Actif"),
    a(3, P.camille, "Automatisation des processus", null,    "Automatisation des processus", "F023;F024;F027;F028;F032;F033;C006", null,         "Actif"),
    a(4, P.hugo,    "Pilotage de projet Data",      P.sarah, "Pilotage de projet Data",      "F017;F018;F021;F022;F013",           "2027-01-15", "Actif"),
    a(5, P.hugo,    "Bien démarrer chez POD",       null,    "Bien démarrer chez POD",       "F001;F009;F010;F030;F031",           null,         "Archivé"),
    a(6, P.ines,    "Acculturation Data",           null,    "Acculturation Data",           "F005;F006;F007;F008;F020;F029;C004", null,         "Actif"),
    a(7, P.ines,    "Mes formations",               null,    "",                             "F031",                               null,         "Actif"),
    a(8, P.sarah,   "Bien démarrer chez POD",       P.alex,  "Bien démarrer chez POD",       "F001;F009;F010;F030;F031",           "2026-11-30", "Actif")
  ];
})();
