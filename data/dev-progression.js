// Donnees de dev FICTIVES : etat initial de la liste Progression (une ligne par
// consultant x module demarre, format des items REST SharePoint). "A faire"
// n'est jamais stocke (RG3). Les ecritures de dev vont dans localStorage
// (podz.dev.progression). Date de reference des donnees : 15/10/2026.
(function(){
  var P = {
    camille: {"Id": 11, "Title": "Camille Test",  "EMail": "camille.test@exemple.local"},
    hugo:    {"Id": 12, "Title": "Hugo Test",     "EMail": "hugo.test@exemple.local"},
    ines:    {"Id": 13, "Title": "Inès Test",     "EMail": "ines.test@exemple.local"},
    sarah:   {"Id": 20, "Title": "Sarah Manager", "EMail": "sarah.manager@exemple.local"},
    alex:    {"Id": 30, "Title": "Alex Admin",    "EMail": "alex.admin@exemple.local"}
  };
  function d(s){ return s ? s + "T00:00:00Z" : null; }
  function p(id, qui, module, statut, o){
    o = o || {};
    return {
      "ID": id, "Title": module,
      "ConsultantId": qui.Id, "Consultant": qui,
      "Statut": statut,
      "DateDebut": d(o.debut), "DateFin": d(o.fin), "DateValidation": d(o.validation),
      "ValideParId": o.par ? o.par.Id : null, "ValidePar": o.par || null,
      "Dispense": !!o.dispense,
      "Commentaire": o.commentaire || null
    };
  }
  window.PODZ_DEV_PROGRESSION = [
    p(1,  P.camille, "F025", "Terminé",   {debut: "2026-09-01", fin: "2026-09-10", validation: "2026-09-12", par: P.sarah}),
    p(2,  P.camille, "F003", "Terminé",   {validation: "2026-09-15", par: P.sarah, dispense: true}),
    p(3,  P.camille, "F002", "En cours",  {debut: "2026-10-01"}),
    p(4,  P.camille, "F004", "À valider", {debut: "2026-09-20", fin: "2026-10-10"}),
    p(5,  P.camille, "F011", "Terminé",   {debut: "2026-09-02", fin: "2026-09-18", validation: "2026-09-20", par: P.sarah}),
    p(6,  P.camille, "F010", "En cours",  {debut: "2026-09-22", fin: "2026-10-06", validation: "2026-10-08", par: P.sarah,
                                           commentaire: "Il manque l'exercice final : merci de le joindre avant de redéclarer le module."}),
    p(7,  P.camille, "F032", "Terminé",   {debut: "2026-09-25", fin: "2026-09-30", validation: "2026-10-02", par: P.sarah}),
    p(8,  P.camille, "F027", "En cours",  {debut: "2026-10-05"}),
    p(9,  P.hugo,    "F017", "À valider", {debut: "2026-09-15", fin: "2026-10-08"}),
    p(10, P.hugo,    "F021", "Terminé",   {debut: "2026-05-04", fin: "2026-05-29", validation: "2026-06-03", par: P.sarah}),
    p(11, P.ines,    "F029", "À valider", {debut: "2026-10-01", fin: "2026-10-14"}),
    p(12, P.sarah,   "F001", "Terminé",   {debut: "2026-09-01", fin: "2026-09-05", validation: "2026-09-10", par: P.alex}),
    p(13, P.sarah,   "F030", "En cours",  {debut: "2026-10-01"})
  ];
})();
