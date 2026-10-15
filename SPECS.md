# SPECS — PODz Academy : parcours assignés et suivi de progression

> Livrable de la session 2 (Specs), issu de l'entretien métier avec Mathieu.
> Document de référence pour la session 3 (Plan) puis l'Exécution.
> Maquettes : `maquettes/mon-parcours.html` et `maquettes/vue-manager.html`.

---

## 1. Contexte et objectif

La PODz Academy est aujourd'hui un **catalogue** : 40 modules (33 formations + 7
certifications) issus de l'Excel `data/POD_Catalogue_Formations.xlsx`, 5 profils, 5
parcours types. Elle s'affiche dans un web part Modern Script Editor d'une page
SharePoint et lit des listes SharePoint.

Le suivi individuel des formations se fait aujourd'hui dans **Planner**. L'objectif est
de le remplacer par un **cockpit de formation** dans la PODz Academy :

- chaque consultant voit **ses** parcours, son avancement, son niveau, le temps passé et
  restant ;
- le manager assigne des parcours et suit / valide l'avancement de ses collaborateurs.

Principe structurant (formulé par le métier) : on sépare
- les **modules** (la formation et ses infos ; la réalisation est portée **par
  consultant × module**),
- les **parcours**, qui ne sont qu'une « mise en musique » ordonnée de modules.

Un module réalisé l'est donc une fois pour toutes : il apparaît « Terminé le JJ/MM »
dans tous les parcours qui le contiennent.

## 2. Contraintes (rappel `CLAUDE.md` / `ARCHITECTURE.md`)

- Ne jamais toucher la prod (page SharePoint, listes) pendant le développement.
- Aucune licence payante, aucun service externe (pas d'IA en ligne, pas de Firebase…).
- Pas d'accès admin SharePoint : création de listes et permissions = **dépendance à un
  propriétaire de site**, à décrire (§ 8), pas à contourner.
- Un seul fichier HTML, JS vanilla, sans build ni CDN, compatible Modern Script Editor.
- Outillage local en PowerShell.
- Toute donnée passe par la couche `window.PODZ.*` (§ 9) ; en dev : Excel + fichiers de
  données de dev + `localStorage` + utilisateur simulé.

## 3. Périmètre

| | MVP | V2 / plus tard |
|---|---|---|
| Catalogue filtrable (existant, US1/US3) | ✅ conservé | |
| Cockpit consultant « Mon parcours » | ✅ | |
| Auto-assignation d'un parcours type par le consultant | ✅ | |
| Modules hors parcours (« Mes formations », depuis le catalogue) | ✅ | |
| Colonne `Techno` du catalogue (niveau par techno, certifications) | ✅ | |
| Assignation par le manager (parcours type, adapté ou construit module par module) + date cible | ✅ | |
| Cycle de statuts avec validation manager + dispense | ✅ | |
| Vue manager (équipe, file « À valider », détail d'un consultant) | ✅ | |
| Notification manager **dans l'outil** (compteur + file) | ✅ | |
| Parcours construit par **mots-clés** | | V2 |
| Création / édition des **parcours types** par un administrateur dans l'outil | | V2 (au MVP : Excel → liste) |
| Notification **e-mail / Teams** (Power Automate) | | Option, à voir avec un propriétaire du site |
| Reprise de l'historique **Planner** | | Avec l'attribution des rôles, au passage en prod |
| Liste réelle des équipes (qui est manager de qui) | | Au passage en prod |

## 4. Personas et rôles

| Rôle | Qui | Ce qu'il fait |
|---|---|---|
| **Consultant** | Tout collaborateur POD | Consulte le catalogue, prend un parcours type en autonomie, suit ses modules, déclare un module terminé. |
| **Manager** | Responsable d'un ou plusieurs consultants | Assigne des parcours (avec date cible), valide ou refuse les modules « À valider », dispense un module, suit l'avancement de son équipe. |
| **Administrateur** | Référent formation | Maintient le catalogue et les parcours types (MVP : via l'Excel puis la liste SharePoint ; V2 : dans l'outil). Voit tout le monde. |

- Les rôles sont **cumulables** : un manager est aussi consultant et a son propre cockpit.
- Au MVP de dev, on simule deux profils principaux (consultant, manager) + un cumul
  consultant-manager ; l'attribution réelle des rôles se fera au passage en prod.

## 5. User stories et critères d'acceptation

### US1 — Parcourir le catalogue *(existant, inchangé)*
En tant que consultant, je parcours les formations par offre, compétence et niveau.

### US2 — Suivre un parcours vers un niveau cible
En tant que consultant ou manager, je suis des parcours qui me font progresser sur une
compétence.
- CA2.1 — Chaque parcours affiche ses modules **dans l'ordre**, avec niveau et durée.
- CA2.2 — Le niveau atteint par compétence / techno est visible dans le cockpit (US6).

### US3 — Infos clés d'un module ou d'un parcours *(existant, enrichi)*
- CA3.1 — Un module affiche : titre, type (formation / certification), offre,
  compétence, niveau, durée, liens, plateformes, notes (sachant, format) — comme
  aujourd'hui.
- CA3.2 — Un parcours affiche : nombre de modules, durée totale, durée restante, date
  cible éventuelle, qui l'a assigné.

### US4 — Voir mes parcours
En tant que consultant connecté, je vois **mes** parcours.
- CA4.1 — L'écran « Mon parcours » liste tous mes parcours **actifs** (plusieurs en
  parallèle possibles), chacun avec son origine : « Assigné par *manager* » ou « Choisi
  en autonomie ».
- CA4.2 — Un parcours assigné affiche sa **date cible** ; un parcours en autonomie n'en a
  pas.
- CA4.3 — Un module présent dans plusieurs de mes parcours a le **même statut partout**
  ; s'il est terminé, il apparaît « Terminé le JJ/MM/AAAA » et n'est jamais à refaire.
- CA4.4 — Si je n'ai aucun parcours : message d'accueil + accès aux parcours types et
  au catalogue.

### US4b — Prendre un parcours type en autonomie
- CA4b.1 — Depuis la page d'un parcours type (ou depuis « Mon parcours »), un bouton
  « Suivre ce parcours » me l'ajoute, sans date cible.
- CA4b.2 — Si je suis déjà ce parcours, le bouton est remplacé par « Déjà dans mes
  parcours ».
- CA4b.3 — Sur un parcours pris en autonomie, « Retirer de mes parcours » l'archive
  (après confirmation). La progression de ses modules est conservée. Un parcours
  assigné ne peut pas être retiré par le consultant.

### US4c — Suivre un module hors parcours
- CA4c.1 — Chaque fiche du catalogue propose « Ajouter à mes formations ».
- CA4c.2 — Le module rejoint un parcours libre **« Mes formations »** (un seul par
  consultant, créé au premier ajout, sans échéance), qui suit le même cycle de statuts
  et de validation.
- CA4c.3 — Si le module est déjà dans un de mes parcours, le bouton indique « Déjà
  dans mes parcours ».

### US5 — Faire avancer un module
- CA5.1 — Statut initial : **À faire**.
- CA5.2 — Au **premier clic sur un lien** du module (support de formation), le statut
  passe automatiquement à **En cours** avec la date de début. Déplier la fiche dans
  l'outil ne change rien.
- CA5.2b — Un bouton **« Je commence »** permet aussi de passer En cours (formation en
  présentiel ou sans lien).
- CA5.3 — Bouton « J'ai terminé » sur un module En cours : saisie de la **date de fin**
  (par défaut aujourd'hui) → statut **À valider**.
- CA5.4 — Le consultant ne peut **jamais** passer lui-même un module à Terminé.
- CA5.5 — Un module refusé par le manager revient à **En cours** et affiche le
  commentaire du manager.

### US6 — Voir ma progression globale (cockpit)
- CA6.1 — Par parcours : barre de progression (% de modules Terminés), compteurs par
  statut, heures réalisées / heures totales, heures restantes, date cible et alerte si
  dépassée.
- CA6.2 — Synthèse globale : nombre de modules terminés, heures réalisées, heures
  restantes (tous parcours, modules en double comptés une fois).
- CA6.3 — **Niveau par compétence** et **par techno** : niveau le plus élevé parmi les
  modules Terminés (y compris dispensés) de cette compétence / techno, sur l'échelle
  Fondamentaux < Intermédiaire < Avancé ; « — » si aucun.
  - Par compétence : les certifications (compétence « Certifs ») sont exclues.
  - Par techno : basé sur la colonne `Techno` (annexe A) ; les certifications comptent
    (ex. PL-300 terminée → Power BI : Avancé).
- CA6.3b — Les certifications terminées s'affichent aussi en **badges** (« Certifié
  PL-300 »).
- CA6.4 — Section « Prochaine étape » : le premier module non terminé du parcours le plus
  urgent (date cible la plus proche, sinon le premier parcours).

### US7 — Assigner un parcours
En tant que manager, j'assigne un parcours à un collaborateur de mon équipe.
- CA7.1 — Je choisis un collaborateur de **mon équipe** uniquement.
- CA7.2 — Je pars d'un **parcours type** (liste pré-remplie, modifiable) **ou** d'un
  parcours vide que je construis module par module depuis le catalogue.
- CA7.3 — Je peux ajouter, retirer et réordonner les modules ; je donne un **nom** au
  parcours s'il est personnalisé.
- CA7.4 — Je fixe une **date cible** (obligatoire pour une assignation manager).
- CA7.5 — Les modules déjà Terminés par le collaborateur sont signalés dès la
  construction (« déjà réalisé le … »).
- CA7.6 — À l'enregistrement, le parcours apparaît dans le cockpit du consultant.
- CA7.7 — Sur un parcours **déjà assigné**, le manager peut ajouter, retirer,
  réordonner des modules et changer la date cible ; retirer un module n'efface pas sa
  progression. Il peut aussi **archiver** le parcours.

### US8 — Suivre et valider mon équipe
- CA8.1 — Vue « Mon équipe » : une ligne par collaborateur avec ses parcours actifs, %
  d'avancement, date cible la plus proche, alerte retard, nombre de modules À valider.
- CA8.2 — Compteur global « N validations en attente » visible dès l'accueil pour un
  manager (notification dans l'outil).
- CA8.3 — File « À valider » : pour chaque demande, collaborateur, module, date de fin
  déclarée ; actions **Valider** (→ Terminé, date de validation, validé par) ou
  **Refuser** (→ En cours, commentaire obligatoire).
- CA8.4 — Détail d'un collaborateur : son cockpit en lecture, plus l'action
  **Dispenser** sur tout module non terminé (→ Terminé, marqué « dispense »).
- CA8.5 — Un manager ne voit **que** ses collaborateurs ; l'administrateur voit tout le
  monde.

## 6. Écrans et navigation

```
Accueil (existant)  ─┬─ [Mon parcours]  ───────────── Cockpit consultant
                     │                                   └─ fiche module (accordéon .pod-etape)
                     ├─ [Mon équipe (3)]  (si manager) ─ Vue manager
                     │                                   ├─ File « À valider »
                     │                                   ├─ Détail collaborateur
                     │                                   └─ Assigner un parcours
                     ├─ Profils / parcours types (existant) ─ bouton « Suivre ce parcours »
                     └─ Catalogue (existant)
```

- Deux entrées ajoutées sur l'accueil (zone `.pod-home-quick`) : **Mon parcours**, et
  **Mon équipe** avec badge du nombre de validations en attente (managers seulement).
- En dev uniquement : bandeau « Se connecter en tant que… » (sélecteur d'utilisateur
  simulé), absent en prod.
- DA : celle du catalogue (`--pod-*`, `.pod-hero`, `.pod-etape`, `.pod-chip`,
  `.pod-parcours`…). Couleurs de statut proposées : À faire gris `#F1F3F8`, En cours
  bleu `--pod-bleu`, À valider jaune `--pod-jaune`, Terminé vert `--pod-vert`, retard
  orange `--pod-orange`.

## 7. Règles de gestion

| # | Règle |
|---|---|
| RG1 | La progression est portée par le couple **consultant × module**, jamais par le parcours. |
| RG2 | Statuts : **À faire → En cours → À valider → Terminé**. Retour possible À valider → En cours (refus). |
| RG3 | « À faire » n'est pas stocké : c'est l'état d'un module d'un parcours actif sans ligne de progression. |
| RG4 | Passage à **En cours** automatique au premier clic sur un lien du module, ou via le bouton « Je commence », par le consultant lui-même (pas quand un manager consulte). Déplier la fiche ne change rien. |
| RG5 | Seul le consultant passe un module à **À valider**, avec une date de fin ≤ aujourd'hui. |
| RG6 | Seul le **manager du consultant** (ou un administrateur) passe un module à **Terminé** : par validation d'un « À valider », ou directement par **dispense** depuis n'importe quel statut non terminé. |
| RG7 | Un refus exige un commentaire ; le module repasse En cours. |
| RG8 | Un module Terminé l'est dans tous les parcours du consultant ; on ne peut pas le « dé-terminer » au MVP (correction = action administrateur dans la liste). |
| RG9 | Un consultant peut avoir **plusieurs parcours actifs**. Il ne peut pas prendre deux fois le même parcours type. |
| RG10 | Date cible : **par parcours uniquement**, fixée par le manager à l'assignation ; aucune pour un parcours pris en autonomie. Retard = date cible dépassée et parcours non terminé à 100 %. |
| RG11 | Un parcours assigné est une **copie** de la liste de modules au moment de l'assignation : modifier ensuite un parcours type ne change pas les parcours déjà assignés. |
| RG12 | Avancement d'un parcours = modules Terminés / modules du parcours. Heures = somme de `DureeHeures` (les certifications sans durée comptent 0 h mais comptent dans le %). |
| RG13 | Niveau par compétence / techno = niveau max des modules Terminés (dispenses incluses). |
| RG14 | Confidentialité : le consultant ne voit que sa progression ; le manager que celle de ses collaborateurs ; l'administrateur tout. (Limite technique en prod : § 8.4.) |
| RG15 | Notification au MVP : uniquement dans l'outil (compteur + file « À valider »). |
| RG16 | Une **dispense** compte comme un Terminé partout (avancement, heures réalisées, niveau) ; elle s'affiche « Terminé · dispensé » au lieu de « Terminé le JJ/MM ». |
| RG17 | Niveau par compétence : certifications exclues. Niveau par techno : colonne `Techno`, certifications incluses. Modules sans techno : ignorés pour le niveau par techno. |
| RG18 | Archivage : le consultant archive ses parcours **en autonomie** ; seul le manager archive un parcours **assigné**. L'archivage ne touche jamais à la progression. |
| RG19 | Modules hors parcours : regroupés dans un parcours libre unique « Mes formations » (Source = Autonomie, sans date cible). |
| RG20 | Un parcours assigné n'est modifiable que par le manager (modules, ordre, date cible). |

## 8. Modèle de données (prod) — dépendances propriétaire de site

### 8.1 Listes existantes (lecture seule, inchangées au MVP)
- **Formations** : `Title`, `field_2` (type), `field_3` (offre), `field_4`
  (compétence), `field_5` (niveau), `field_6`/`DureeHeures`, `field_7` (liens),
  `field_8` (tags), `field_9` (plateformes), `Obligatoire`, `field_11` (notes),
  `Parcours` (choix multiples), `Ordre`. Clé : `ID`.
- **Profils**, **Parcours** : comme aujourd'hui. Les 5 parcours types sont confirmés :
  Bien démarrer chez POD, Analyste Power BI, Automatisation des processus, Pilotage de
  projet Data, Acculturation Data. Composition d'un parcours type = formations dont
  `Parcours` contient son titre, triées par `Ordre`.
- **Nouvelle colonne `Techno`** (techno ou méthode) sur Formations : dans l'Excel
  (remplie par le métier, valeurs proposées en annexe A), reprise par
  `tools/excel-vers-catalogue.ps1`, puis ajoutée à la liste Formations en prod
  (Ligne de texte ou Choix, à créer par un propriétaire du site). Vide = module
  transverse.

### 8.2 Nouvelles listes à créer par un propriétaire du site

**Assignations** — une ligne par parcours suivi par un consultant.

| Colonne | Type SharePoint | Obligatoire | Description / exemple |
|---|---|---|---|
| `Title` | Ligne de texte | oui | Nom du parcours : « Analyste Power BI » ou « Montée en compétence Power Platform » |
| `Consultant` | Personne | oui | Le consultant qui suit le parcours |
| `AssignePar` | Personne | non | Le manager ; vide si autonomie |
| `Source` | Choix : `Autonomie`, `Manager` | oui | Origine |
| `ParcoursType` | Ligne de texte | non | Titre du parcours type d'origine, vide si construit de zéro |
| `Modules` | Plusieurs lignes de texte (brut) | oui | IDs de formations **ordonnés**, séparés par `;` : `F025;F003;F002;F004;C005` |
| `DateCible` | Date | non | Échéance (Source = Manager) |
| `Etat` | Choix : `Actif`, `Archivé` | oui | Défaut `Actif` |

**Progression** — une ligne par consultant × module démarré.

| Colonne | Type SharePoint | Obligatoire | Description / exemple |
|---|---|---|---|
| `Title` | Ligne de texte | oui | ID de la formation : `F002` |
| `Consultant` | Personne | oui | |
| `Statut` | Choix : `En cours`, `À valider`, `Terminé` | oui | |
| `DateDebut` | Date | non | Premier clic sur un lien |
| `DateFin` | Date | non | Déclarée par le consultant |
| `DateValidation` | Date | non | Validation ou dispense |
| `ValidePar` | Personne | non | Manager ayant validé / dispensé |
| `Dispense` | Oui/Non | oui | Défaut Non |
| `Commentaire` | Plusieurs lignes de texte | non | Motif de refus |

Unicité attendue (gérée par le code) : un seul item par (`Consultant`, `Title`).

**Équipes** — rattachement consultant → manager (à remplir au passage en prod).

| Colonne | Type SharePoint | Description |
|---|---|---|
| `Title` | Ligne de texte | Libre (nom du consultant) |
| `Consultant` | Personne | |
| `Manager` | Personne | |
| `Admin` | Oui/Non | Rôle administrateur PODz Academy |

### 8.3 Permissions demandées
- Formations / Profils / Parcours : lecture pour tous (inchangé).
- Assignations, Progression : **lecture + ajout + modification** pour tous les
  collaborateurs (le consultant crée ses lignes, le manager modifie celles de son
  équipe). Pas de suppression.
- Équipes : lecture pour tous, modification réservée au référent formation.

### 8.4 Limite de confidentialité (décision : acceptée au MVP)
Sans admin, les permissions SharePoint ne savent pas dire « le manager peut modifier les
lignes de *ses* collaborateurs seulement ». Avec les permissions du § 8.3, la règle RG14
est appliquée **par l'interface** : la page n'affiche à chacun que ce qu'il a le droit de
voir, mais un utilisateur averti pourrait lire les listes Assignations / Progression
directement (statuts, dates, commentaires de refus).

**Décision** : limite acceptée au MVP (pas de données sensibles). Consigne aux
managers : commentaires de refus factuels. L'alternative (permissions par élément via
Power Automate) sera rediscutée avec le propriétaire du site au passage en prod.

## 9. Couche d'accès aux données (`window.PODZ`)

| Fonction | Rôle | Dev | Prod |
|---|---|---|---|
| `fetchCatalogue()` | existant | `data/catalogue.js` | GET Formations |
| `fetchProfils()` / `fetchParcours()` | existant | tableaux du HTML | GET Profils / Parcours |
| `fetchUtilisateur()` | utilisateur connecté + rôles (`estManager`, `estAdmin`) | utilisateur choisi dans le sélecteur | `/_api/web/currentuser` + Équipes |
| `fetchEquipe(manager)` | collaborateurs d'un manager (tous si admin) | `data/dev-utilisateurs.js` | GET Équipes filtrée |
| `fetchAssignations(userIds)` | parcours d'un ou plusieurs consultants | `data/dev-assignations.js` + `localStorage` | GET Assignations filtrée |
| `fetchProgression(userIds)` | lignes de progression | `data/dev-progression.js` + `localStorage` | GET Progression filtrée |
| `saveAssignation(assignation)` | créer, modifier (modules, ordre, date cible) ou archiver un parcours ; ajout à « Mes formations » | `localStorage` | POST/MERGE Assignations |
| `saveStatut(user, formationId, changement)` | démarrer, déclarer terminé, valider, refuser, dispenser | `localStorage` | POST/MERGE Progression (`X-RequestDigest`) |

Les objets échangés gardent le **format des items REST SharePoint** (personnes sous la
forme `ConsultantId` + `Consultant: {Id, Title, EMail}`), convertis par des fonctions
`mapAssignation` / `mapProgression` comme `mapItem` pour les formations.

## 10. Données de dev (jeu de test)

Tout est **fictif** (dépôt potentiellement public) : aucun vrai nom, aucun export Planner.

- `data/dev-utilisateurs.js` — `window.PODZ_DEV_UTILISATEURS` :
  ```js
  [
    {"Id": 11, "Title": "Camille Test",  "EMail": "camille.test@exemple.local",  "ManagerId": 20, "Admin": false},
    {"Id": 12, "Title": "Hugo Test",     "EMail": "hugo.test@exemple.local",     "ManagerId": 20, "Admin": false},
    {"Id": 13, "Title": "Inès Test",     "EMail": "ines.test@exemple.local",     "ManagerId": 20, "Admin": false},
    {"Id": 20, "Title": "Sarah Manager", "EMail": "sarah.manager@exemple.local", "ManagerId": 30, "Admin": false},
    {"Id": 30, "Title": "Alex Admin",    "EMail": "alex.admin@exemple.local",    "ManagerId": null, "Admin": true}
  ]
  ```
  (Sarah est consultante **et** manager.)
- `data/dev-assignations.js` — `window.PODZ_DEV_ASSIGNATIONS`, items au format liste :
  ```js
  {"ID": 1, "Title": "Analyste Power BI", "ConsultantId": 11,
   "Consultant": {"Id": 11, "Title": "Camille Test", "EMail": "camille.test@exemple.local"},
   "AssigneParId": 20, "AssignePar": {"Id": 20, "Title": "Sarah Manager", "EMail": "sarah.manager@exemple.local"},
   "Source": "Manager", "ParcoursType": "Analyste Power BI",
   "Modules": "F025;F003;F002;F004;F026;F012;C005", "DateCible": "2026-12-31T00:00:00Z", "Etat": "Actif"}
  ```
  Couvrir : un parcours type assigné, un parcours personnalisé, un parcours en
  autonomie sans date, un parcours en retard, un module partagé entre deux parcours,
  un parcours libre « Mes formations », un parcours archivé.
- `data/catalogue.js` : après ajout de la colonne `Techno` dans l'Excel, régénéré par
  le script (champ `Techno` au format liste). Tant que l'Excel n'est pas complété, le
  niveau par techno affiche « — ».
- `data/dev-progression.js` — `window.PODZ_DEV_PROGRESSION`, état initial couvrant tous
  les statuts (En cours, À valider, Terminé, Terminé par dispense, refus avec
  commentaire).
- `localStorage` (clés préfixées `podz.dev.`) : écritures faites pendant les tests, qui
  surchargent l'état initial ; un bouton « Réinitialiser les données de dev » les efface.
- Ces fichiers sont écrits à la main (petits, fictifs) ; `catalogue.js` reste généré par
  `tools/excel-vers-catalogue.ps1`.

## 11. Hors périmètre (MVP)

- Parcours par mots-clés (V2 : recherche simple titre / tags / techno / compétence, tri
  par niveau, ajustable par le consultant — pas d'IA).
- Écran administrateur de création des parcours types (V2).
- E-mails / Teams (option Power Automate).
- Reprise du Planner (faite avec l'attribution des rôles, au passage en prod ; prévoir
  alors un script PowerShell export Planner → Progression, export jamais commité).
- Modification de la prod, création de listes par nous-mêmes.
- Statistiques globales, exports, tableaux RH.

## 12. Points ouverts

### 12.1 Tranchés avec le métier (session 2)

| # | Point | Décision | Réf. |
|---|---|---|---|
| PO1 | Ce qui déclenche « En cours » | Premier clic sur un lien du module, ou bouton « Je commence » ; déplier la fiche ne change rien | CA5.2, CA5.2b, RG4 |
| PO2 | Affichage et poids d'une dispense | « Terminé · dispensé » ; compte partout, y compris dans les heures réalisées | RG16 |
| PO3 | Niveau par techno | Nouvelle colonne `Techno` (techno ou méthode) dans l'Excel, remplie par le métier ; proposition en annexe A | § 8.1, RG17 |
| PO4 | Certifications et niveau | Comptent pour leur techno, exclues du niveau par compétence, affichées en badges | CA6.3, CA6.3b, RG17 |
| PO5 | Abandon d'un parcours | Autonomie : le consultant archive ; assigné : le manager seulement ; progression conservée | CA4b.3, RG18 |
| PO6 | Module hors parcours | Oui au MVP : « Ajouter à mes formations » → parcours libre « Mes formations » | US4c, RG19 |
| PO7 | Modifier un parcours assigné | Oui, par le manager (modules, ordre, date cible, archivage) | CA7.7, RG20 |
| PO8 | Confidentialité en prod | Limite acceptée au MVP, à rediscuter avec le propriétaire du site | § 8.4 |
| PO10 | Notification e-mail / Teams | Plus tard (option Power Automate) | § 3 |

### 12.2 Restant ouverts

| # | Point | Qui tranche |
|---|---|---|
| PO9 | Qui crée les listes Assignations / Progression / Équipes et la colonne `Techno` en prod, et leurs URL exactes ? | Propriétaire du site |
| PO11 | Dans l'Excel, `Ordre` est global et chaque formation n'appartient qu'à un parcours type : un module partagé entre deux parcours types demandera un ordre par parcours (V2 admin). OK au MVP. | Session Plan |
| PO12 | Remplir la colonne `Techno` dans l'Excel (à partir de l'annexe A). | Métier |

## Annexe A — Valeurs proposées pour la colonne `Techno`

Validées en session 2 comme point de départ ; le métier les reporte dans l'Excel et
peut les ajuster. « — » = vide (module transverse).

| ID | Module | Techno |
|---|---|---|
| F001 | Intégration POD | — |
| F002 | Power BI | Power BI |
| F003 | Data management | — |
| F004 | Modélisation | — |
| F005 | Data Catalog - DataGalaxy | DataGalaxy |
| F006 | Comprendre le Data Cataloging | — |
| F007 | SharePoint | SharePoint |
| F008 | Adoption / ADKAR | ADKAR |
| F009 | Vidéo / Vyond | Vyond |
| F010 | PowerPoint avancé | PowerPoint |
| F011 | Maquettage / méthode UX | UX |
| F012 | Design / DataViz | DataViz |
| F013 | Gestion des stakeholders | — |
| F014 | Business analyst | — |
| F015 | Suivi de projet | Gestion de projet |
| F016 | Recette (UAT) | — |
| F017 | Agile (SCRUM) | Agile |
| F018 | Schéma Directeur | — |
| F019 | Ways of working / BPM | BPM |
| F020 | Gouvernance | — |
| F021 | Cycle en V | Gestion de projet |
| F022 | Cadrage et gestion de projet | Gestion de projet |
| F023 | Automatisation / Power Automate | Power Platform |
| F024 | Power Apps (formation) | Power Platform |
| F025 | SQL / Requêtage | SQL |
| F026 | Data Quality | — |
| F027 | Copilot / Copilot Studio | Copilot |
| F028 | Agents IA & GenAI | IA générative |
| F029 | Data Literacy | — |
| F030 | IA Générative & Claude — Bases | Claude |
| F031 | Travailler efficacement avec l'IA | IA générative |
| F032 | Claude CoWork — Prise en main | Claude |
| F033 | Agents & Skills IA avec Claude | Claude |
| C001 | Agile - PSM I | Agile |
| C002 | Agile - PSPO I (Complet) | Agile |
| C003 | Agile - PSPO I (Express) | Agile |
| C004 | Change Management - Prosci (ADKAR) | ADKAR |
| C005 | Power BI - PL-300 | Power BI |
| C006 | Power Apps - PL-200 | Power Platform |
| C007 | Gestion de projet - PMP | Gestion de projet |
