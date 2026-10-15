# PLAN — PODz Academy : parcours assignés et suivi de progression

> Livrable de la session 3 (Plan). Découpage validé avec l'utilisateur le 15/10/2026.
> Référence fonctionnelle : `SPECS.md` (US*, CA*, RG*). Maquettes :
> `maquettes/mon-parcours.html`, `maquettes/vue-manager.html`.
> Brief de la session suivante : `SESSION-4-EXECUTION.md`.

---

## 0. Décisions prises en session 3

| # | Sujet | Décision |
|---|---|---|
| D-P1 | Découpage | 12 lots (§ 3), un commit local par lot après validation à l'écran. |
| D-P2 | **PO11** — ordre des modules d'un parcours type | Au MVP, `Ordre` **global** du catalogue. La copie faite à l'assignation (RG11) est ensuite réordonnable par le manager. Un ordre propre à chaque parcours type est renvoyé à la V2 (écran admin). |
| D-P3 | Réordonner les modules (CA7.3) | Boutons **↑ / ↓** (pas de glisser-déposer). |
| D-P4 | Reprendre un parcours type archivé | La ligne archivée est **réactivée** (`Etat` = `Actif`), pas de doublon (RG9). |
| D-P5 | Reconnaître « Mes formations » | `Source = Autonomie` **et** `ParcoursType` vide (pas de nouvelle colonne). `Title` = « Mes formations ». |
| D-P6 | **PO12** — colonne `Techno` | On **attend le métier** : le script tolère l'absence de colonne (`Techno` = `""`), le niveau par techno affiche « — » en dev. Les fonctions de calcul sont testées avec des données de test qui ont une techno. |
| D-P7 | Certifications dans un parcours type copié | Si le parcours type a **une seule** certification, elle est copiée en fin de liste. S'il en a **plusieurs** (« au choix », ex. Pilotage de projet Data : PSM I, PSPO ×2, PMP), **aucune** n'est copiée. On affiche alors « Certification au choix : ajoute-la… » (manager : depuis le formulaire ; consultant : via « Ajouter à mes formations »). |
| D-P8 | Clic sur un lien hors cockpit | Un clic du consultant connecté sur un lien d'un module de **ses parcours actifs** le passe « En cours », quel que soit l'écran (cockpit, catalogue, page profil). |
| D-P9 | Chargement des données de dev | Les fichiers `data/*.js` sont **injectés dynamiquement** seulement si `location.hostname` vaut `localhost` ou `127.0.0.1` (promesse `PODZ.pret`). Aucune balise `<script src="data/…">` dans le HTML. Hors localhost, les fonctions sans implémentation SharePoint **rejettent** avec un message explicite : la page ne peut jamais écrire en prod par accident. |
| D-P10 | Tests des calculs | Fonctions pures `window.PODZ.calc.*`, testées par une page `tests/tests-calculs.html` (assertions JS vanilla, servie par `serveur-dev.ps1`, sans Node). |

**Interprétations à confirmer pendant la recette** (pas des points ouverts, mais à
montrer à l'utilisateur au lot concerné) :
- CA6.4 « Prochaine étape » : premier module **À faire ou En cours** du parcours le plus
  urgent. Un module À valider est sauté, car le consultant n'a rien à y faire (lot L6).
- Refus (RG7) : stocké sur la ligne Progression avec `Statut = En cours`,
  `Commentaire` = motif, `ValidePar` = manager, `DateValidation` = date du refus. Un
  module est affiché « refusé » si `Statut = En cours` et `Commentaire` non vide. À la
  nouvelle déclaration, le commentaire est conservé ; il n'est plus affiché une fois le
  module Terminé (lots L4, L7).

---

## 1. Architecture cible dans `podz-academy.html`

Tout reste dans **un seul fichier**, en JS ES5 vanilla (même style que l'existant : IIFE,
`var`, concaténation de chaînes, `esc()`), avec un CSS scopé par bloc.

### 1.1 Nouveaux blocs (dans l'ordre du fichier)

| Bloc | Rôle | Lot |
|---|---|---|
| `<script>` **config + chargeur** (placé **avant** tous les autres scripts) | `window.PODZ_CONFIG` (env, listes SharePoint), `PODZ.pret` (promesse de chargement des `data/*.js` en dev), `PODZ.aujourdhui()` | L2 |
| `<script>` **couche de données** (bloc existant `mapItem` / `fetchCatalogue`, étendu) | `mapItem.techno`, `map*` / `toItem*`, `fetch*`, `save*`, surcouche `localStorage`, squelettes SharePoint | L1, L3, L4 |
| `<script>` **calculs** | `window.PODZ.calc.*` (fonctions pures, aucun accès DOM ni données) | L5 (+ L4 pour les transitions) |
| `<style>` + `<script>` **bandeau dev** `.podz-dev` | « Se connecter en tant que… », « Réinitialiser les données de dev » ; injecté seulement en dev, au-dessus des vues | L3, L4 |
| `<style>` `.podz-mp` + vue `#view-mon-parcours` + `<script>` | Cockpit consultant ; `PODZ.renderCockpit(el, consultantId, mode)` réutilisé par le détail manager | L6, L7 |
| `<style>` `.podz-mgr` + vue `#view-mon-equipe` + `<script>` | Vue manager : KPIs, onglets File / Équipe / Assigner, détail collaborateur | L8, L9 |
| vue `#view-assigner` (dans `.podz-mgr`) + `<script>` | Formulaire d'assignation et de modification | L11, L12 |
| `<script>` **suivi des clics** | Écouteur délégué sur `a[data-formation]` → démarrage du module (D-P8) | L7 |
| `<script>` **navigation** (existant, étendu) | Nouvelles routes | L6, L8, L11 |

### 1.2 Routes (hash)

| Hash | Vue | Qui |
|---|---|---|
| `#accueil` (défaut) | accueil existant + entrées « Mon parcours » / « Mon équipe (N) » | tous |
| `#catalogue` | catalogue existant + « Ajouter à mes formations » | tous |
| `#profil=<slug>` | profil existant + « Suivre ce parcours » | tous |
| `#mon-parcours` | cockpit consultant | tous |
| `#mon-equipe` | vue manager (onglet File « À valider » par défaut) | manager, admin |
| `#mon-equipe/c=<id>` | détail d'un collaborateur | manager du collaborateur, admin |
| `#assigner` / `#assigner=c<consultantId>` / `#assigner=a<assignationId>` | création / modification d'une assignation | manager, admin |

Le routeur `show()` passe d'une comparaison en dur à une table `{prefixe → vue, rendu}`.
Une route manager ouverte par un non-manager renvoie vers `#accueil`.

### 1.3 Modèle d'objets côté affichage (après `map*`)

```js
// mapUtilisateur(raw)
{ id: 11, nom: "Camille Test", email: "…", managerId: 20, estAdmin: false,
  estManager: true|false /* calculé : au moins un collaborateur */ }

// mapAssignation(raw)
{ id: 1, titre: "Analyste Power BI",
  consultant: {id, nom, email}, assignePar: {id, nom, email} | null,
  source: "Manager"|"Autonomie", parcoursType: "Analyste Power BI" | "",
  modules: ["F025","F003", …], dateCible: "2026-12-31" | null,
  etat: "Actif"|"Archivé", estMesFormations: bool /* D-P5 */ }

// mapProgression(raw)
{ id: 7, formationId: "F002", consultantId: 11,
  statut: "en-cours"|"a-valider"|"termine",
  dateDebut, dateFin, dateValidation /* "YYYY-MM-DD" | null */,
  validePar: {id, nom} | null, dispense: bool, commentaire: "" }
```

`toItemAssignation` / `toItemProgression` font l'inverse (vers le format REST
SharePoint, personnes en `ConsultantId` + `Consultant: {Id, Title, EMail}`). Les dates
sont échangées au format `YYYY-MM-DDT00:00:00Z` et comparées en chaînes `YYYY-MM-DD`.
Statut affiché « À faire » = calculé (RG3), jamais stocké.

### 1.4 Contrat de la couche `window.PODZ` (toutes les fonctions renvoient une Promise)

| Fonction | Dev | Prod (signature à implémenter au passage en prod) |
|---|---|---|
| `fetchCatalogue()` | `PODZ.pret` puis `PODZ_CATALOGUE.map(mapItem)` | `GET {site}/_api/web/lists/getbytitle('{listes.formations}')/items?$top=500` |
| `fetchUtilisateur()` | utilisateur `podz.dev.utilisateur` (défaut : 11) dans `PODZ_DEV_UTILISATEURS` | `GET /_api/web/currentuser` + `GET Équipes?$filter=ManagerId eq {id}` (estManager) et `ConsultantId eq {id}` (Admin) |
| `fetchUtilisateurs()` | tous (pour le sélecteur dev et les noms) | `GET Équipes?$select=Consultant/Id,Consultant/Title,Consultant/EMail,ManagerId,Admin&$expand=Consultant` |
| `fetchEquipe(managerId)` | utilisateurs dont `ManagerId == managerId` ; tous sauf soi si admin | `GET Équipes?$filter=ManagerId eq {id}` (tout si admin) |
| `fetchAssignations(userIds)` | fichier de dev + surcouche `podz.dev.assignations`, filtré | `GET Assignations?$filter=(ConsultantId eq a or ConsultantId eq b…)&$expand=Consultant,AssignePar` |
| `fetchProgression(userIds)` | fichier de dev + surcouche `podz.dev.progression`, filtré | `GET Progression?$filter=…&$expand=Consultant,ValidePar` |
| `saveAssignation(a)` | contrôle des droits, écrit `toItemAssignation(a)` dans la surcouche, ID ≥ 1000 via `podz.dev.seq` | `POST` (création) / `POST` + `X-HTTP-Method: MERGE` + `IF-MATCH` (modification), avec `X-RequestDigest` |
| `saveStatut(consultantId, formationId, changement)` | `changement = {action: "demarrer"|"declarer"|"valider"|"refuser"|"dispenser", dateFin?, commentaire?}` ; l'acteur = utilisateur courant ; contrôle par `calc.transition` ; crée ou met à jour l'unique ligne (consultant, module) | idem sur Progression ; unicité vérifiée par un `GET` avant le `POST` |
| `resetDev()` | supprime toutes les clés `podz.dev.*` (sauf l'utilisateur courant) | n'existe pas |

Les helpers SharePoint (`sp.get(liste, requete)`, `sp.digest()`, `sp.creer(liste,
item)`, `sp.modifier(liste, id, item, etag)`, `sp.typeEntite(liste)` pour
`ListItemEntityTypeFullName`) sont **déclarés avec leur signature et un commentaire
REST**. En L3, leur corps rejette avec « Implémentation SharePoint à écrire au passage en
prod » ; ils ne sont pas écrits avant le passage en prod.

`window.PODZ_CONFIG = { env: "dev"|"prod", siteUrl: "", listes: { formations: "?",
profils: "?", parcours: "?", assignations: "Assignations", progression: "Progression",
equipes: "Equipes" } }`. Les noms marqués `?` sont à récupérer (PO9).

### 1.5 Fonctions de calcul `window.PODZ.calc` (pures)

| Fonction | Entrées → sortie | Règles |
|---|---|---|
| `indexer(liste, cle)` | tableau → objet clé → élément | — |
| `statutModule(progIdx, formationId)` | → `{code: "a-faire"|"en-cours"|"refuse"|"a-valider"|"termine"|"dispense", prog}` | RG3, RG7, RG16 |
| `syntheseParcours(assignation, catIdx, progIdx, today)` | → `{lignes:[{formation, statut}], nb, nbTermines, parStatut, pct, heuresTotal, heuresRealisees, heuresRestantes, enRetard, introuvables:[]}` | RG10, RG12, RG16 ; certification sans durée = 0 h |
| `syntheseGlobale(assignationsActives, catIdx, progIdx)` | → `{nbModules, nbTermines, heuresRealisees, heuresRestantes, nbAValider}` sur les modules **dédoublonnés** | CA6.2 |
| `niveaux(progIdx, catIdx)` | → `{parCompetence: [{nom, niveau|null}], parTechno: [{nom, niveau}], technoRenseignee: bool, badges: [titre]}` | RG13, RG17, CA6.3b ; compétences = buckets du catalogue sauf « Certifs » |
| `prochaineEtape(assignationsActives, catIdx, progIdx, today)` | → `{assignation, formation, statut}` ou `null` | CA6.4 (+ interprétation § 0) |
| `compositionParcoursType(titre, catalogue)` | → IDs triés par `ordre`, formations puis certification si une seule | D-P2, D-P7 |
| `transition(prog, action, ctx)` | `ctx = {acteur, consultant, today, dateFin, commentaire}` → `{ok, erreur, prog}` (nouvel objet) | RG2, RG4–RG8, RG16 |
| `peutGerer(acteur, consultant)` | → bool (manager direct ou admin) | RG6, RG14, CA8.5 |
| `peutModifierAssignation(acteur, assignation)` | → bool | RG18, RG20 |
| `formatDate(iso)` | → `JJ/MM/AAAA` | — |

---

## 2. Données de dev (fictives)

Tous les fichiers sont écrits à la main, en UTF-8, au format items REST. Les IDs de
formations sont ceux de `catalogue.js`. Date de référence des données : **15/10/2026**.
`PODZ.aujourdhui()` peut être forcée en dev par `localStorage["podz.dev.aujourdhui"] =
"2026-10-15"`, pour que les cas « en retard » restent stables dans le temps.

**`data/dev-utilisateurs.js`** : les 5 utilisateurs du § 10 de `SPECS.md` (Camille 11,
Hugo 12, Inès 13 → manager Sarah 20 → manager Alex 30, admin).

**`data/dev-assignations.js`** :

| ID | Consultant | Titre | Source / par | ParcoursType | Modules | DateCible | Etat | Cas couvert |
|---|---|---|---|---|---|---|---|---|
| 1 | Camille | Analyste Power BI | Manager / Sarah | Analyste Power BI | `F025;F003;F002;F004;F026;F012;C005` | 2026-12-31 | Actif | parcours type assigné, réordonné |
| 2 | Camille | Restitution & DataViz | Manager / Sarah | *(vide)* | `F011;F010;F012` | 2026-09-30 | Actif | personnalisé, **en retard**, F012 **partagé** avec 1 |
| 3 | Camille | Automatisation des processus | Autonomie | Automatisation des processus | `F023;F024;F027;F028;F032;F033;C006` | — | Actif | autonomie sans date |
| 4 | Hugo | Pilotage de projet Data | Manager / Sarah | Pilotage de projet Data | `F017;F018;F021;F022;F013` | 2027-01-15 | Actif | parcours type à plusieurs certifs (aucune copiée, D-P7) |
| 5 | Hugo | Bien démarrer chez POD | Autonomie | Bien démarrer chez POD | `F001;F009;F010;F030;F031` | — | **Archivé** | archivé (réactivable, D-P4) |
| 6 | Inès | Acculturation Data | Autonomie | Acculturation Data | `F005;F006;F007;F008;F020;F029;C004` | — | Actif | autonomie |
| 7 | Inès | Mes formations | Autonomie | *(vide)* | `F031` | — | Actif | parcours libre (D-P5) |
| 8 | Sarah | Bien démarrer chez POD | Manager / Alex | Bien démarrer chez POD | `F001;F009;F010;F030;F031` | 2026-11-30 | Actif | manager qui est aussi consultante |

Alex (30) n'a **aucun** parcours : cas CA4.4.

**`data/dev-progression.js`** :

| ID | Consultant | Module | Statut | Détail | Cas couvert |
|---|---|---|---|---|---|
| 1 | Camille | F025 | Terminé | début 01/09, fin 10/09, validé le 12/09/2026 par Sarah | terminé |
| 2 | Camille | F003 | Terminé | dispense le 15/09/2026 par Sarah | dispense |
| 3 | Camille | F002 | En cours | début 01/10/2026 | en cours |
| 4 | Camille | F004 | À valider | fin 10/10/2026 | à valider |
| 5 | Camille | F011 | Terminé | validé le 20/09/2026 | terminé (parcours 2) |
| 6 | Camille | F010 | En cours | refusé le 08/10/2026 par Sarah, commentaire « Il manque l'exercice final… » | refus |
| 7 | Camille | F032 | Terminé | validé le 02/10/2026 par Sarah | terminé dans un parcours en autonomie |
| 8 | Camille | F027 | En cours | début 05/10/2026 | en cours (autonomie) |
| 9 | Hugo | F017 | À valider | fin 08/10/2026 | à valider |
| 10 | Hugo | F021 | Terminé | validé le 03/06/2026 | « déjà réalisé » (CA7.5) |
| 11 | Inès | F029 | À valider | fin 14/10/2026 | à valider (autonomie) |
| 12 | Sarah | F001 | Terminé | validé le 10/09/2026 par Alex | cockpit de la manager |
| 13 | Sarah | F030 | En cours | début 01/10/2026 | |

Résultat attendu : Sarah a **3** validations en attente (F004 Camille, F017 Hugo, F029
Inès) ; Alex en a **0** pour Sarah et voit les 3 autres en tant qu'admin.

**Surcouche `localStorage`** (préfixe `podz.dev.`) :
`podz.dev.utilisateur` (Id), `podz.dev.assignations` et `podz.dev.progression` (objets
`{ID: item}` qui remplacent ou complètent l'état initial), `podz.dev.seq` (prochain ID,
départ 1000), `podz.dev.aujourdhui` (optionnel).

---

## 3. Lots

Convention : un lot = un commit local `Lot Lx : <titre>` sur `mathieu/parcours`, fait
**après** que l'utilisateur a vérifié les critères de test à l'écran. Serveur :
`powershell -ExecutionPolicy Bypass -File tools\serveur-dev.ps1` →
http://localhost:8080/podz-academy.html. Avant chaque commit, vérifier aussi qu'il n'y a
**aucune régression** : l'accueil, le catalogue (filtres, cartes dépliables) et une page
profil s'affichent comme avant.

### L1 — Colonne `Techno` (script + `mapItem`)
- **Couvre** : § 8.1, RG17 (préparation), PO12 (tolérance).
- **Fichiers** : `tools/excel-vers-catalogue.ps1`, `data/catalogue.js` (régénéré, jamais
  édité), `podz-academy.html` (`mapItem`).
- **Changements** :
  - Le script lit la **ligne d'en-tête** et associe les colonnes par leur **nom** (`ID`,
    `Titre`, `Type`, `Offre POD`, `Bucket`, `Niveau`, `Durée`, `Lien(s)`, `Tags
    Skills`, `Plateforme`, `Obligatoire`, `Notes`, `Techno`), avec un repli sur les
    lettres actuelles si un en-tête est introuvable. Il émet `Techno = ""` si la
    colonne est absente. Le script reste en ASCII (accents via `[char]`).
  - `mapItem` : `techno: raw.Techno || ""`.
- **Test** : relancer le script → « 40 formations écrites ». `git diff data/catalogue.js`
  ne montre **que** l'ajout de `"Techno": ""` sur chaque item. Le catalogue et les
  profils s'affichent à l'identique. En console : `PODZ.fetchCatalogue().then(l =>
  l[0].techno)` → `""`.
- **Dépend de** : —.

### L2 — Données de dev et chargement réservé au dev
- **Couvre** : § 10, D-P9.
- **Fichiers** : nouveaux `data/dev-utilisateurs.js`, `data/dev-assignations.js`,
  `data/dev-progression.js` (contenu § 2) ; `podz-academy.html`.
- **Changements** :
  - Nouveau premier `<script>` : `PODZ_CONFIG` (env détecté par `location.hostname`),
    `PODZ.pret` = Promise qui injecte, en dev seulement, `data/catalogue.js` puis les 3
    `dev-*.js` (création de `<script>`, `onload` / `onerror`). En prod :
    `Promise.resolve()`. `PODZ.aujourdhui()`.
  - Suppression de `<script src="data/catalogue.js">`. `fetchCatalogue` attend
    `PODZ.pret`.
- **Test** : la page s'affiche comme avant. En console : `PODZ_CONFIG.env` → `"dev"`,
  `PODZ_DEV_ASSIGNATIONS.length` → 8, `PODZ_DEV_PROGRESSION.length` → 13. En ouvrant
  `http://127.0.0.1:8080/…`, même résultat. Contrôle prod simulé : forcer
  `PODZ_CONFIG.env = "prod"` (paramètre `?env=prod`, accepté seulement sur localhost)
  → message « Implémentation SharePoint à écrire » à la place du catalogue, aucune
  erreur JS.
- **Dépend de** : — (peut précéder L1).

### L3 — Couche d'accès en lecture + bandeau « Se connecter en tant que… »
- **Couvre** : § 9 (lecture), RG14 (filtrage), maquettes (bandeau dev).
- **Fichiers** : `podz-academy.html`.
- **Changements** : `mapUtilisateur`, `mapAssignation`, `mapProgression`,
  `toItemAssignation`, `toItemProgression`, `fetchUtilisateur`, `fetchUtilisateurs`,
  `fetchEquipe`, `fetchAssignations`, `fetchProgression` (fichier de dev + surcouche, déjà
  lue même si encore vide), squelette `sp.*` et `PODZ_CONFIG.listes`. Bandeau `.podz-dev`
  (style de la maquette) injecté en haut de page en dev seulement : liste des 5
  utilisateurs avec leur rôle ; un changement enregistre `podz.dev.utilisateur` et
  recharge la page.
- **Test** : le bandeau jaune s'affiche, Camille sélectionnée par défaut. Choisir Sarah
  → la page se recharge, Sarah reste sélectionnée. Console :
  `PODZ.fetchUtilisateur()` → Sarah, `estManager: true` ;
  `PODZ.fetchEquipe(20)` → 3 consultants ; `PODZ.fetchEquipe(30)` → 4 (tous sauf
  Alex) ; `PODZ.fetchAssignations([11])` → 3 assignations, `modules` en tableau,
  `dateCible` `"2026-12-31"` ; `PODZ.fetchProgression([11])` → 8 lignes.
- **Dépend de** : L2.

### L4 — Écritures, transitions et surcouche `localStorage`
- **Couvre** : RG1–RG8, RG16, RG18, RG20 (contrôles), § 9 (`save*`).
- **Fichiers** : `podz-academy.html`.
- **Changements** : `calc.transition`, `calc.peutGerer`, `calc.peutModifierAssignation`
  (ce sont les premières fonctions du bloc calculs) ; `saveStatut` et `saveAssignation`
  en dev (contrôle des droits → `toItem*` → `podz.dev.*`) ; `resetDev()` ; lien
  « Réinitialiser les données de dev » dans le bandeau (avec confirmation).
- **Test** (console, en tant que Camille puis Sarah) :
  `PODZ.saveStatut(11, "F026", {action: "demarrer"})` → ligne En cours avec
  `dateDebut` du jour ; recharger → toujours là. `{action: "declarer", dateFin:
  "2099-01-01"}` → rejet « date de fin dans le futur ». En tant que Camille,
  `{action: "valider"}` → rejet (CA5.4). En tant que Sarah, valider F004 de Camille →
  Terminé, `validePar` Sarah ; refuser sans commentaire → rejet. « Réinitialiser » →
  état initial retrouvé.
- **Dépend de** : L3.

### L5 — Calculs purs + page de tests
- **Couvre** : RG10, RG12, RG13, RG16, RG17, CA6.1–CA6.4, D-P2, D-P7.
- **Fichiers** : `podz-academy.html` (bloc `PODZ.calc`), nouveau
  `tests/tests-calculs.html`.
- **Changements** : toutes les fonctions du § 1.5. La page de tests charge
  `../podz-academy.html` dans une `<iframe>` (même origine), attend `PODZ.calc`, puis
  exécute des cas sur des **données de test écrites dans la page de tests** (avec des
  technos renseignées). Elle affiche une ligne verte ou rouge par assertion et un total.
- **Cas de test minimum** : avancement avec dispense ; certification à 0 h comptée dans
  le % ; module partagé compté une fois dans la synthèse globale ; retard (date dépassée
  et < 100 %) ; pas de retard à 100 % ; niveau max par compétence sans les certifs ; niveau
  par techno avec la certif (PL-300 → Power BI Avancé) ; « — » sans module terminé ;
  `technoRenseignee: false` quand toutes les technos sont vides ; prochaine étape (cible
  la plus proche, sinon premier parcours ; module À valider sauté) ;
  `compositionParcoursType("Analyste Power BI")` se termine par C005 ;
  `compositionParcoursType("Pilotage de projet Data")` ne contient aucun C00x ; toutes
  les transitions autorisées et interdites de RG2–RG8.
- **Test** : http://localhost:8080/tests/tests-calculs.html → tout est vert.
- **Dépend de** : L1 (champ `techno`) et L4 (transitions). La partie calculs peut être
  écrite en parallèle de L3.

### L6 — Navigation + cockpit « Mon parcours » en lecture
- **Couvre** : US2, CA3.2, US4 (CA4.1–4.4), US6 (CA6.1–6.4, 6.3b), § 6.
- **Fichiers** : `podz-academy.html`.
- **Changements** :
  - Routeur en table (§ 1.2) ; vue `#view-mon-parcours` ; CSS `.podz-mp` repris de la
    maquette (statuts `.pod-st--*`, barres, KPIs, niveaux) ; entrée « Mon parcours »
    dans `.pod-home-quick`.
  - `PODZ.renderCockpit(el, consultantId, {mode: "consultant"})` : synthèse en tête
    (salutation, phrase de synthèse, 4 KPIs), carte « Prochaine étape », carte « Mon
    niveau » (onglets Par compétence / Par techno, badges certifs, mention « colonne
    Techno pas encore renseignée » si `technoRenseignee` est faux), un bloc par parcours
    actif (origine, date cible, alerte retard, barre en 3 couleurs, compteurs,
    accordéons `.pod-etape` avec statut et « aussi dans « … » »), mention « Certification
    au choix » (D-P7) quand le parcours type en propose plusieurs, encart « Envie d'aller
    plus loin ? ». État vide CA4.4. Les parcours archivés ne s'affichent pas.
  - Les boutons d'action sont affichés **désactivés** à ce stade (branchés en L7).
- **Test** :
  - Camille : 3 parcours. Analyste Power BI à **2/7 terminés**, F003 « Terminé ·
    dispensé », F004 « À valider · fini le 10/10 ». Restitution & DataViz « en retard »
    (orange). F012 marqué « aussi dans… » dans les deux parcours. KPIs cohérents
    (modules dédoublonnés). Prochaine étape = PowerPoint avancé (parcours en retard). Par
    compétence : Analyse Fondamentaux, Adoption Intermédiaire, Process Fondamentaux,
    Pilotage —. Onglet techno : mention « pas encore renseignée ».
  - Hugo : 1 parcours actif (l'archivé n'apparaît pas), mention « Certification au
    choix ». Alex : écran d'accueil vide avec liens vers les parcours types et le
    catalogue.
  - Le fil d'Ariane ramène à l'accueil ; les boutons précédent/suivant du navigateur
    fonctionnent.
- **Dépend de** : L3, L5.

### L7 — Transitions côté consultant
- **Couvre** : US5 (CA5.1–5.5), RG4, RG5, D-P8.
- **Fichiers** : `podz-academy.html`.
- **Changements** :
  - Boutons « Je commence » (À faire), « J'ai terminé… » (En cours, refusé compris) →
    petit formulaire en ligne avec la date de fin (par défaut aujourd'hui, `max` =
    aujourd'hui) → À valider. Encart de refus (`.pod-etape__detail-notes.refus`). Le
    rendu est rafraîchi après chaque écriture.
  - `renderLinks` / `renderDetail` et les cartes du catalogue ajoutent
    `data-formation="<ID>"` sur chaque lien. Un écouteur délégué au niveau du document
    démarre le module si : l'utilisateur courant le consulte pour lui-même, le module
    est dans un de ses parcours actifs et il n'a pas encore de ligne de progression. Le
    lien s'ouvre normalement (pas de `preventDefault`).
  - En mode « manager » (détail d'un collaborateur, L8) : aucun démarrage automatique.
- **Test** (Camille) : « Je commence » sur Data Quality → En cours, depuis le jour même.
  Clic sur le lien de Design / DataViz depuis le **catalogue**, puis retour au cockpit
  → En cours dans les **deux** parcours. « J'ai terminé » sur Power BI avec une date
  future → refusé ; avec la date du jour → À valider. PowerPoint avancé affiche le
  commentaire de refus et propose « J'ai terminé… ». Aucun bouton ne permet de passer à
  Terminé. Clic sur le lien d'un module **hors** de ses parcours → aucun changement.
- **Dépend de** : L4, L6.

### L8 — Vue manager en lecture + compteur sur l'accueil
- **Couvre** : US8 (CA8.1, CA8.2, CA8.4 en lecture, CA8.5), RG14, RG15.
- **Fichiers** : `podz-academy.html`.
- **Changements** : CSS `.podz-mgr` repris de la maquette ; vue `#view-mon-equipe` :
  en-tête « Espace manager » avec KPIs (collaborateurs, à valider, parcours en retard),
  onglets « À valider (N) » / « Équipe » / « Assigner un parcours » (lien vers L11).
  Tableau Équipe (parcours actifs assignés/autonomie, % global, prochaine échéance +
  retard, nb à valider), une ligne → `#mon-equipe/c=<id>`. Détail =
  `renderCockpit(el, id, {mode: "manager"})` + bouton « Assigner un parcours à… ».
  Accueil : entrée « Mon équipe » avec badge du nombre en attente, visible si manager ou
  admin.
- **Test** : Sarah → badge « 3 » sur l'accueil ; tableau avec Camille / Hugo / Inès ;
  Camille 25 % environ et « en retard ». Alex → voit les 4 autres utilisateurs (Sarah
  comprise). Camille → pas d'entrée « Mon équipe » ; `#mon-equipe` saisi à la main →
  retour à l'accueil. Sarah, détail de Camille : son cockpit sans bouton « Je commence »
  ni « J'ai terminé ».
- **Dépend de** : L6.

### L9 — Valider, refuser, dispenser
- **Couvre** : CA8.3, CA8.4 (dispense), RG6, RG7, RG8, RG16.
- **Fichiers** : `podz-academy.html`.
- **Changements** : onglet « À valider » (collaborateur, parcours, module, date de fin
  déclarée, « depuis N j ») avec « ✓ Valider » et « Refuser » ; le refus ouvre une zone
  de commentaire **obligatoire** + « Confirmer le refus ». Dans le détail
  collaborateur : « Valider » sur les À valider, « Dispenser » (avec confirmation) sur
  tout module non terminé. Le badge de l'accueil et les compteurs se mettent à jour.
- **Test** : Sarah valide F004 de Camille → la file passe à 2, le badge de l'accueil à 2.
  Passer en Camille → Modélisation « Terminé le 15/10/2026 » ; niveau Analyse →
  Intermédiaire. Sarah refuse F017 de Hugo sans commentaire → bloqué ; avec commentaire
  → passer en Hugo → Agile (SCRUM) En cours avec le commentaire. Sarah dispense Data
  Quality de Camille → « Terminé · dispensé », % et heures réalisées augmentent. Alex
  peut valider pour Sarah ; Sarah ne voit jamais ses propres modules dans sa file.
- **Dépend de** : L4, L8.

### L10 — Autonomie : suivre un parcours type, « Mes formations », retirer
- **Couvre** : US4b (CA4b.1–4b.3), US4c (CA4c.1–4c.3), RG9, RG18, RG19, D-P4, D-P5,
  D-P7.
- **Fichiers** : `podz-academy.html` (bloc profil, bloc catalogue, cockpit).
- **Changements** :
  - Page profil : dans chaque `.pod-parcours-head`, « Suivre ce parcours » →
    `saveAssignation` (composition `calc.compositionParcoursType`, Source Autonomie,
    pas de date) ou réactivation de la ligne archivée ; « Déjà dans mes parcours » si
    une assignation active porte ce `ParcoursType`.
  - Catalogue : les cartes à un seul lien (aujourd'hui des `<a>`) deviennent un `<div>`
    contenant un lien « Accéder › » **et** un bouton « Ajouter à mes formations ». Ce
    bouton crée « Mes formations » au premier ajout, puis ajoute le module à la fin.
    « Déjà dans mes parcours » si le module est dans une assignation active. Les cartes
    à plusieurs liens reçoivent le bouton dans leur panneau de détail.
  - Cockpit : « Retirer de mes parcours » (avec confirmation) sur les parcours en
    autonomie seulement, y compris « Mes formations » ; aucun bouton sur un parcours
    assigné.
- **Test** : Inès → page profil « Analyste Data » → « Suivre ce parcours » → le parcours
  apparaît dans son cockpit, sans date, avec C005 en dernier ; le bouton devient « Déjà
  dans mes parcours ». Hugo → « Bien démarrer chez POD » → réactivé, pas de doublon.
  Hugo → catalogue → « Ajouter à mes formations » sur Power BI → « Mes formations »
  apparaît ; Agile (SCRUM) affiche « Déjà dans mes parcours ». Inès retire Acculturation
  Data → il disparaît ; F029 reste « À valider » dans la file de Sarah. Camille ne voit
  pas « Retirer » sur Analyste Power BI. Le filtre et la recherche du catalogue
  marchent toujours ; la carte reste cliquable vers la formation.
- **Dépend de** : L6 (et L4).

### L11 — Assignation par le manager (création)
- **Couvre** : US7 (CA7.1–CA7.6), RG10, RG11, D-P2, D-P3, D-P7.
- **Fichiers** : `podz-academy.html`.
- **Changements** : vue `#assigner` (onglet « Assigner un parcours » et bouton du
  détail) :
  - sélecteur Collaborateur (équipe seulement, admin : tous) ; point de départ (parcours
    types + « Parcours vide ») ; Nom (prérempli, obligatoire) ; Date cible
    **obligatoire**, après aujourd'hui ;
  - liste ordonnée : ↑ / ↓ / ✕, mention « Déjà terminé par X le … » ou « En attente de
    ta validation », lien « N modules du parcours type retirés · rétablir » ; mention
    « Certification au choix » (D-P7) ;
  - « Ajouter depuis le catalogue » : recherche par titre + liste avec « + Ajouter » /
    « Déjà ajouté » ;
  - récapitulatif : nb modules, durée, déjà terminés / à valider, reste à faire d'ici la
    date cible ; « Annuler » / « Assigner à X » → `saveAssignation` (Source Manager,
    AssignePar = acteur, `ParcoursType` = titre du type ou vide si le nom a changé ou si
    le parcours est vide).
  - Si le collaborateur suit déjà ce parcours type (actif) : message bloquant, avec
    proposition d'aller le modifier (L12).
- **Test** : Sarah → Assigner → Hugo, « Analyste Power BI », date cible 31/03/2027,
  retirer F026, monter F004 en 1re position, ajouter F028 → Assigner. Passer en Hugo →
  le parcours est dans son cockpit avec ces modules dans cet ordre, « Assigné par Sarah
  Manager », cible 31/03/2027. Sans date cible → bouton désactivé ou message.
  Collaborateur Camille + parcours type Analyste Power BI → message « déjà suivi » (idem
  Hugo + Pilotage de projet Data). Hugo + parcours vide : ajouter Cycle en V (F021) →
  « Déjà terminé par Hugo le 03/06/2026 », Agile (SCRUM) → « En attente de ta
  validation » ; nommer le parcours et l'assigner → OK.
- **Dépend de** : L8 (et L5 pour la composition).

### L12 — Modifier ou archiver un parcours assigné + recette finale
- **Couvre** : CA7.7, RG11, RG18, RG20 ; recette de toutes les US.
- **Fichiers** : `podz-academy.html`, `ARCHITECTURE.md`, `README.md`, nouveau
  `RECETTE.md`.
- **Changements** :
  - Détail collaborateur : « Modifier le parcours » → `#assigner=a<id>` (même formulaire,
    collaborateur figé) ; « Archiver » (avec confirmation) sur les parcours **assignés**.
    Retirer un module ne touche pas à sa progression.
  - Finitions : responsive (≤ 860 px et ≤ 640 px comme les maquettes), messages
    d'erreur des `save*` affichés proprement, aucun style global hors des racines
    `.podz-*`, `document.title` par vue.
  - `ARCHITECTURE.md` : tableau de la couche de données à jour, décisions D-P*,
    chargement dev. `README.md` : bandeau dev, réinitialisation, page de tests.
  - `RECETTE.md` : scénario de bout en bout par persona (Camille, Hugo, Inès, Sarah, Alex),
    coché avec l'utilisateur.
- **Test** : Sarah modifie « Restitution & DataViz » de Camille (ajoute F009, déplace,
  change la date au 31/12/2026) → chez Camille, l'ordre suit et le retard disparaît.
  Retirer F010 (refusé) puis le remettre → le refus et son commentaire sont toujours
  là. Archiver → disparaît du cockpit de Camille, ses modules terminés comptent toujours
  dans le niveau. Camille n'a aucun moyen de modifier un parcours assigné. Dérouler
  `RECETTE.md` en entier ; page de tests toujours verte.
- **Dépend de** : L9, L10, L11.

### Récapitulatif des dépendances

```
L1 ─┐
L2 ─┴─ L3 ─ L4 ─┬─ L5 ─ L6 ─┬─ L7
                │           ├─ L8 ─┬─ L9 ─┐
                │           │      └─ L11 ┼─ L12
                │           └─ L10 ───────┘
```

### Traçabilité US → lots

| US / règles | Lots |
|---|---|
| US1, US3 (existant) | non-régression à chaque lot ; CA3.2 en L6 |
| US2, US4, US6 | L5, L6 |
| US4b, US4c, RG9, RG18, RG19 | L10 (+ L12 pour l'archivage d'un assigné) |
| US5, RG2–RG5 | L4, L7 |
| US7, RG10, RG11, RG20 | L11, L12 |
| US8, RG6, RG7, RG14, RG15 | L8, L9 |
| RG1, RG3, RG8, RG12, RG13, RG16, RG17 | L4, L5 |

---

## 4. Dépendances externes et prod (à porter au propriétaire du site / au métier)

Rien de cette liste n'est fait par nous. Ces points ne bloquent pas l'exécution en local.

| # | Dépendance | Qui | Bloque |
|---|---|---|---|
| PO9 | Créer les listes **Assignations**, **Progression**, **Équipes** (colonnes et types du § 8.2 de `SPECS.md`, noms internes identiques : `Consultant`, `AssignePar`, `Modules`, `DateCible`, `Etat`, `Statut`, `DateDebut`, `DateFin`, `DateValidation`, `ValidePar`, `Dispense`, `Commentaire`, `Manager`, `Admin`) et en donner les URL | Propriétaire du site | passage en prod |
| PO9 | Ajouter la colonne **`Techno`** (nom interne `Techno`) à la liste Formations | Propriétaire du site | niveau par techno en prod |
| PO9 | Noms exacts des listes existantes Formations / Profils / Parcours (lecture seule) → `PODZ_CONFIG.listes` | Propriétaire du site | passage en prod |
| § 8.3 | Permissions : lecture + ajout + modification (sans suppression) sur Assignations et Progression pour tous ; Équipes en lecture, modifiable par le référent formation | Propriétaire du site | passage en prod |
| § 8.4 | Limite de confidentialité acceptée au MVP ; alternative Power Automate à rediscuter | Propriétaire du site | — |
| PO12 | Remplir la colonne `Techno` dans l'Excel (annexe A de `SPECS.md`), puis relancer `tools/excel-vers-catalogue.ps1` | Métier | niveau par techno (affiche « — » d'ici là) |
| — | Remplir la liste Équipes (qui est manager de qui, admins) et reprendre le Planner | Référent formation | passage en prod |
| — | Page SharePoint **de test** pour valider le rendu avant la page de prod | Propriétaire du site | passage en prod |

**Travaux à prévoir au passage en prod** (hors de ce plan, session dédiée) : écrire les
corps de `sp.*` et des `fetch*` / `save*` en mode prod (endpoints du § 1.4) ;
réintégrer les implémentations SharePoint de `fetchCatalogue`, `fetchProfils`,
`fetchParcours` ; **dates** : les champs Date SharePoint renvoient de l'UTC (une date
saisie le 15/10 en France peut revenir `2026-10-14T22:00:00Z`), donc convertir en date
locale dans `map*` ; récupérer `ListItemEntityTypeFullName` de chaque liste ;
`IF-MATCH` / etag pour les modifications concurrentes ; tests sur la page de test.

## 5. Risques et points de vigilance

- **Non-régression du catalogue** au lot L10 (cartes `<a>` transformées en `<div>`) :
  vérifier les filtres, la recherche et l'ouverture des liens.
- **Fichier unique qui grossit** (≈ 1 070 → ≈ 2 500 lignes) : garder des blocs
  `<style>` / `<script>` séparés et commentés par fonctionnalité, pas de CSS global.
- **Dates figées des données de dev** : utiliser `podz.dev.aujourdhui` si une recette a
  lieu longtemps après le 15/10/2026.
- **Modern Script Editor** : pas de modules ES, pas de `fetch` vers des fichiers locaux
  en prod, scripts inline seulement. Le rendu peut différer dans SharePoint (thème,
  largeur) : à valider sur la page de test.
- **Dépôt potentiellement public** : données de dev 100 % fictives (`@exemple.local`),
  aucun export Planner, aucun vrai nom.

---

## 6. Écarts d'exécution (session 4)

| Lot | Écart | Raison |
|---|---|---|
| L2 | `tools/serveur-dev.ps1` écoute aussi `http://127.0.0.1:<port>/` (fichier hors liste du lot). | Sans ce préfixe, `HttpListener` répond « 400 Invalid Hostname » sur 127.0.0.1 : le test du lot était impossible. |
| L2 | Accueil : ajout d'un `.catch` sur le chargement des profils (message d'erreur à la place de la grille). | En mode prod simulé, `fetchCatalogue` rejette : sans `catch`, erreur JS non gérée. |
| L4 | `calc.peutModifierAssignation(acteur, assignation, consultant)` : 3e paramètre optionnel `consultant` (`{id, managerId}`). | L'objet `assignation` ne porte pas le manager du consultant, nécessaire pour RG20. |
| L4 | `calc.peutGerer` refuse toujours d'agir sur soi-même (même un administrateur ne valide pas ses propres modules). | Prolonge CA5.4 ; à confirmer en recette. |
| L4 | `saveAssignation` contrôle aussi RG9 (même parcours type actif deux fois, deuxième « Mes formations ») et la date cible obligatoire d'un parcours assigné (CA7.4). | Garde-fous côté données, en plus des contrôles de l'interface (L10, L11). |
| L5 | Fonction ajoutée `calc.certifsAuChoix(titre, catalogue)` (certifications du parcours type quand il y en a plusieurs) et constante `calc.ECHELLE`. | Pour afficher « Certification au choix » (D-P7) en L6, L10 et L11 sans dupliquer la règle. |
| L5 | `syntheseParcours` : un module introuvable dans le catalogue va dans `introuvables` et n'est pas compté dans `nb`, le % ni les heures. | Il sera affiché comme carte « introuvable » (`missingCard`). |
| L5 | Ordre des compétences de `niveaux` = ordre d'apparition des buckets dans le catalogue (`Ordre`) : Analyse, Adoption, Pilotage, Process. | Non précisé par les specs. |
| L8 | CSS de la maquette manager repris sous la racine `.podz-mgr` (la maquette utilisait `.podz-mg`) ; les règles du constructeur d'assignation sont restreintes à `.pod-build .pod-etape` et `.pod-catpick .pod-mini`. Bloc placé avant `.podz-mp`. | Le cockpit du collaborateur est imbriqué dans `.podz-mgr` : ses `.pod-etape` ne doivent pas hériter du style du constructeur. |
| L8 | Onglet « Assigner un parcours » et bouton « Assigner un parcours à… » affichés désactivés. | Branchés au lot L11. |
| L8 | La file « À valider » liste toutes les lignes À valider de l'équipe, même si le module n'est plus dans un parcours actif (libellé « Hors parcours actif »). | Test du lot L10 : F029 d'Inès reste dans la file après le retrait de son parcours. |
