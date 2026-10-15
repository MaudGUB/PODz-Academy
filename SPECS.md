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

### US5 — Faire avancer un module
- CA5.1 — Statut initial : **À faire**.
- CA5.2 — Au **premier clic sur un lien** du module (support de formation), le statut
  passe automatiquement à **En cours** avec la date de début. *(interprétation à
  confirmer, cf. § 12)*
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
| RG4 | Passage à **En cours** automatique au premier clic sur un lien du module, par le consultant lui-même (pas quand un manager consulte). |
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
- Évolution possible (point ouvert § 12) : colonne **`Techno`** sur Formations.

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

### 8.4 Limite de confidentialité (à arbitrer avec le propriétaire du site)
Sans admin, les permissions SharePoint ne savent pas dire « le manager peut modifier les
lignes de *ses* collaborateurs seulement ». Avec les permissions du § 8.3, la règle RG14
est appliquée **par l'interface** : la page n'affiche à chacun que ce qu'il a le droit de
voir, mais un utilisateur averti pourrait lire les listes directement. Options :
(a) accepter cette limite (données peu sensibles) ; (b) permissions par élément posées
par un flux Power Automate (complexe, à étudier avec un propriétaire du site).

## 9. Couche d'accès aux données (`window.PODZ`)

| Fonction | Rôle | Dev | Prod |
|---|---|---|---|
| `fetchCatalogue()` | existant | `data/catalogue.js` | GET Formations |
| `fetchProfils()` / `fetchParcours()` | existant | tableaux du HTML | GET Profils / Parcours |
| `fetchUtilisateur()` | utilisateur connecté + rôles (`estManager`, `estAdmin`) | utilisateur choisi dans le sélecteur | `/_api/web/currentuser` + Équipes |
| `fetchEquipe(manager)` | collaborateurs d'un manager (tous si admin) | `data/dev-utilisateurs.js` | GET Équipes filtrée |
| `fetchAssignations(userIds)` | parcours d'un ou plusieurs consultants | `data/dev-assignations.js` + `localStorage` | GET Assignations filtrée |
| `fetchProgression(userIds)` | lignes de progression | `data/dev-progression.js` + `localStorage` | GET Progression filtrée |
| `saveAssignation(assignation)` | créer un parcours (autonomie ou manager) | `localStorage` | POST Assignations |
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
  autonomie sans date, un parcours en retard, un module partagé entre deux parcours.
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

| # | Point | Proposition par défaut | Qui tranche |
|---|---|---|---|
| PO1 | « Ouvrir la formation » = clic sur un lien du module (compris ainsi) ? | Clic sur un lien ; déplier la fiche ne change rien | Métier |
| PO2 | Distinguer visuellement « Terminé » et « Terminé (dispense) » ? | Oui, mention discrète « dispensé » | Métier |
| PO3 | **Techno** : aucune colonne dédiée dans l'Excel. Ajouter une colonne `Techno` (Excel + liste) ou la déduire des tags ? | Ajouter une colonne `Techno` dans l'Excel | Métier + propriétaire |
| PO4 | Certifications : compétence = « Certifs ». Pour le niveau, les rattacher à la compétence de leur offre ? | Les rattacher via la future colonne `Techno` | Métier |
| PO5 | Le consultant peut-il **abandonner / archiver** un parcours pris en autonomie ? Et un parcours assigné ? | Autonomie : oui ; assigné : non (manager seulement) | Métier |
| PO6 | Le consultant peut-il suivre un **module hors parcours** (depuis le catalogue) ? | Non au MVP | Métier |
| PO7 | Le manager peut-il modifier un parcours **déjà assigné** (ajout / retrait de modules, date cible) ? | Oui | Métier |
| PO8 | Limite de confidentialité en prod (§ 8.4) | Option (a) | Métier + propriétaire |
| PO9 | Qui crée les listes Assignations / Progression / Équipes en prod, et leurs URL exactes ? | — | Propriétaire du site |
| PO10 | Notification e-mail / Teams via Power Automate | Plus tard | Métier + propriétaire |
| PO11 | Dans l'Excel, `Ordre` est global et chaque formation n'appartient qu'à un parcours type : un module partagé entre deux parcours types demandera un ordre par parcours (V2 admin). | OK au MVP | Session Plan |
