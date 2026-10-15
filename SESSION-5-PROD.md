# Brief — Session 5 : passage en prod

> À donner tel quel à une **nouvelle session** Claude ouverte sur ce dépôt
> (branche `mathieu/parcours`). Livrable de la session 4 (Exécution), 15/10/2026.

## Où on en est
- Les 12 lots de `PLAN.md` sont faits et commités en local sur `mathieu/parcours` (commits
  `Lot L1 : …` à `Lot L12 : …`). La recette `RECETTE.md` a été déroulée avec l'utilisateur :
  aucune anomalie. **Rien de la session 4 n'a été poussé** : demander l'accord de
  l'utilisateur avant tout `git push`.
- En dev (localhost), tout fonctionne : cockpit consultant, vue manager, validation,
  assignation, autonomie. Données fictives `data/dev-*.js` + écritures dans `localStorage`.
- En prod, **rien n'est branché** : hors localhost, `PODZ_CONFIG.env = "prod"`, aucune
  donnée n'est chargée et toutes les fonctions de données rejettent avec « Implémentation
  SharePoint à écrire au passage en prod ». Coller la page telle quelle dans SharePoint
  afficherait des messages d'erreur, sans rien écrire.

## Avant de commencer
1. `git branch --show-current` → `mathieu/parcours`, arbre propre.
2. Lire `CLAUDE.md` (contraintes non négociables : **jamais toucher la prod** sans
   l'utilisateur, pas d'admin, pas de service externe, un seul HTML ES5 vanilla, outillage
   PowerShell), `ARCHITECTURE.md`, puis `PLAN.md` § 1.3 (objets), § 1.4 (contrat de la
   couche de données et endpoints REST), § 4 (dépendances) et § 6 (écarts d'exécution).
3. `SPECS.md` § 8 (colonnes des listes, permissions, limite de confidentialité) reste la
   référence pour les listes à créer.

## 1. Dépendances externes : état au 15/10/2026
Aucune n'est faite. Elles sont **toutes** à porter par l'utilisateur au propriétaire du
site ou au métier (nous n'avons pas les droits et ne devons pas les contourner). Commencer
la session en demandant à l'utilisateur leur état réel.

| # | Dépendance | Qui | État | Bloque |
|---|---|---|---|---|
| PO9 | Créer les listes **Assignations**, **Progression**, **Équipes** (colonnes et types de `SPECS.md` § 8.2, noms internes identiques : `Consultant`, `AssignePar`, `Source`, `ParcoursType`, `Modules`, `DateCible`, `Etat`, `Statut`, `DateDebut`, `DateFin`, `DateValidation`, `ValidePar`, `Dispense`, `Commentaire`, `Manager`, `Admin`) et en donner les URL | Propriétaire du site | À faire | tout le passage en prod |
| PO9 | Ajouter la colonne **`Techno`** (nom interne `Techno`) à la liste Formations | Propriétaire du site | À faire | niveau par techno en prod (sinon « — ») |
| PO9 | Noms exacts des listes existantes Formations / Profils / Parcours (lecture seule) → `PODZ_CONFIG.listes` (aujourd'hui `"?"`) | Propriétaire du site | À faire | passage en prod |
| § 8.3 | Permissions : lecture + ajout + modification (sans suppression) sur Assignations et Progression pour tous ; Équipes en lecture, modifiable par le référent formation | Propriétaire du site | À faire | écritures en prod |
| § 8.4 | Limite de confidentialité acceptée au MVP ; alternative Power Automate (permissions par élément) à rediscuter | Propriétaire du site | Acceptée au MVP, à reconfirmer | — |
| PO12 | Remplir la colonne `Techno` dans l'Excel (proposition : annexe A de `SPECS.md`), puis relancer `tools\excel-vers-catalogue.ps1` | Métier | À faire | niveau par techno |
| — | Remplir la liste Équipes (qui est manager de qui, admins) ; reprendre l'historique Planner (script d'export PowerShell, export **jamais commité**) | Référent formation | À faire | passage en prod |
| — | Page SharePoint **de test** (Modern Script Editor) pour valider le rendu et les appels avant la page de prod | Propriétaire du site | À faire | passage en prod |

## 2. Ce qu'il faut implémenter (mode prod)
Tout est dans `podz-academy.html`, bloc « couche de données » (après `mapItem`). Principe :
**garder l'implémentation de dev** (`enDev(...)`) et ajouter une branche prod derrière
`PODZ.estDev()`, sans toucher au code d'affichage (qui n'appelle que `window.PODZ.*`).

### 2.1 Helpers SharePoint `PODZ.sp.*` (squelettes qui rejettent aujourd'hui)
| Helper | À écrire |
|---|---|
| `sp.get(liste, requete)` | `GET {siteUrl}/_api/web/lists/getbytitle('{liste}')/items{requete}`, en-tête `Accept: application/json;odata=verbose` → `data.d.results` ; gérer la pagination (`d.__next`) si > 5000 / `$top` |
| `sp.digest()` | `POST {siteUrl}/_api/contextinfo` → `d.GetContextWebInformation.FormDigestValue` (à mettre en cache ~25 min) |
| `sp.typeEntite(liste)` | `GET …/getbytitle('{liste}')?$select=ListItemEntityTypeFullName` (à mettre en cache) |
| `sp.creer(liste, item)` | `POST …/items`, corps `{__metadata: {type: typeEntite}, …item}`, en-têtes `X-RequestDigest`, `Content-Type: application/json;odata=verbose` |
| `sp.modifier(liste, id, item, etag)` | `POST …/items({id})` + `X-HTTP-Method: MERGE` + `IF-MATCH: {etag}` (ou `*`) ; gérer le 412 (modification concurrente) par un message clair |

`siteUrl` : `_spPageContextInfo.webAbsoluteUrl` si disponible, sinon `PODZ_CONFIG.siteUrl`.
Utiliser `fetch` + `credentials: "same-origin"` (pas de dépendance externe).

### 2.2 Fonctions `fetch*` / `save*` (contrat : `PLAN.md` § 1.4)
| Fonction | Implémentation prod |
|---|---|
| `fetchCatalogue()` | `sp.get(listes.formations, "?$top=500")` → `mapItem` (réintégrer l'implémentation SharePoint d'origine du web part) |
| `fetchProfils()` / `fetchParcours()` | aujourd'hui tableaux embarqués `PROFILS` / `PARCOURS` (fonctionnent aussi en prod) ; réintégrer les GET des listes Profils / Parcours si l'utilisateur le souhaite |
| `fetchUtilisateur()` | `GET /_api/web/currentuser` + `Équipes?$filter=ManagerId eq {id}` (`estManager`) et `ConsultantId eq {id}` (`Admin`) → `mapUtilisateur`. **Utilisateur absent de la liste Équipes** (nouvel arrivant, liste pas encore à jour) : ne pas échouer ; le traiter comme un simple consultant (`managerId: null`, `estAdmin: false`, `estManager` selon `ManagerId eq {id}`), avec son cockpit normal. Le libellé « ton manager » s'affiche alors à la place d'un nom (déjà géré par l'affichage). En dev, un identifiant inconnu retombe sur Camille : ce repli ne doit **pas** être repris en prod. |
| `renderCockpit` / `saveStatut` pour un consultant sans manager | Personne ne peut valider ses modules hormis un administrateur (RG6) : à signaler au référent formation (compléter Équipes). |
| `fetchUtilisateurs()` | `Équipes?$select=Consultant/Id,Consultant/Title,Consultant/EMail,ManagerId,Admin&$expand=Consultant` (adapter `mapUtilisateur` : en dev les items ont `Id/Title/EMail` à plat) |
| `fetchEquipe(managerId)` | `Équipes?$filter=ManagerId eq {id}` ; tout le monde sauf soi si admin |
| `fetchAssignations(userIds)` | `Assignations?$filter=(ConsultantId eq a or ConsultantId eq b…)&$expand=Consultant,AssignePar&$select=*,Consultant/Id,Consultant/Title,Consultant/EMail,AssignePar/Id,AssignePar/Title,AssignePar/EMail` → `mapAssignation` |
| `fetchProgression(userIds)` | idem sur Progression, `$expand=Consultant,ValidePar` → `mapProgression` |
| `saveStatut(consultantId, formationId, changement)` | garder **tel quel** le contrôle `calc.transition` ; **unicité** : `GET Progression?$filter=ConsultantId eq {id} and Title eq '{formation}'` juste avant d'écrire ; `sp.creer` si absent, sinon `sp.modifier` avec l'etag |
| `saveAssignation(a)` | garder les contrôles de droits / RG9 / date cible ; `sp.creer` (création) ou `sp.modifier` (modification, archivage) |
| `resetDev()` | reste réservé au dev |

Écriture des personnes : champs `ConsultantId`, `AssigneParId`, `ValideParId` (nombres) ;
les objets `Consultant: {…}` produits par `toItem*` sont à retirer du corps envoyé.
`Statut` et `Etat` sont des choix avec accents (`À valider`, `Terminé`, `Archivé`) :
vérifier l'encodage UTF-8 et les valeurs exactes des choix créés par le propriétaire.

### 2.3 Piège des dates UTC
Les champs Date SharePoint sont stockés et renvoyés en **UTC** : une date saisie le 15/10
en France peut revenir `2026-10-14T22:00:00Z`. Aujourd'hui `dateLocale()` (couche de
données) se contente de `substr(0, 10)` : **à corriger** pour convertir en date locale
(`new Date(s)` puis année / mois / jour locaux), et `dateSp()` doit écrire minuit **local**
(`new Date(a, m - 1, j).toISOString()`) plutôt que `T00:00:00Z`. Toutes les comparaisons
restent en chaînes `YYYY-MM-DD` (retard, date de fin ≤ aujourd'hui). À tester sur la page
de test avec une date saisie dans l'interface SharePoint **et** une date écrite par la page.

### 2.4 Autres points à traiter
- `PODZ_CONFIG.listes` : renseigner les noms réels (PO9) ; `siteUrl` si besoin.
- Confidentialité (RG14, § 8.4) : le filtrage reste fait par l'interface ; ne rien
  afficher d'autre que ce que montre le dev.
- Rendu dans SharePoint (thème, largeur du web part, polices) : à vérifier sur la page de
  test ; tout le CSS est scopé sous `.podz-*` (seule exception, déjà présente :
  `.pod-view[hidden]`).
- Le bandeau dev, `data/*.js` et `?env=prod` n'existent qu'en dev : rien à retirer.
- Garder `tests/tests-calculs.html` vert (les calculs ne changent pas).

## 3. Procédure de passage en prod (dans cet ordre)
1. **Dépendances** du § 1 confirmées par l'utilisateur (au minimum : listes créées,
   permissions, noms des listes, page de test, liste Équipes remplie pour quelques testeurs).
2. **Implémentation** du § 2 sur `mathieu/parcours`, un commit par étape, chaque étape
   validée par l'utilisateur. Le dev local doit rester identique (`RECETTE.md` sections 0
   à 6 toujours OK, page de tests verte).
3. **Page SharePoint de test** : l'utilisateur colle `podz-academy.html` dans le Modern
   Script Editor de la page de test (jamais la page de prod à ce stade). Dérouler une
   recette réduite avec de vrais comptes de test : lecture du catalogue, cockpit d'un
   consultant, démarrage / déclaration d'un module, validation par son manager,
   assignation, dates (§ 2.3). Les éventuelles données de test créées dans les listes sont
   à nettoyer par le propriétaire.
4. **Push et pull request** : après accord explicite de l'utilisateur, `git push` de
   `mathieu/parcours` puis PR vers `main`, relue (le dépôt `MaudGUB/PODz-Academy` est
   potentiellement public : vérifier qu'aucune donnée sensible n'est versionnée).
5. **Prod** : après fusion, **l'utilisateur** copie-colle le HTML de `main` dans la page de
   prod. Claude ne touche jamais lui-même à la page ni aux listes de prod.

Si la session s'interrompt : noter l'avancement en tête de ce fichier et écrire un
`SESSION-5-SUITE.md` court pour reprendre au bon endroit.
