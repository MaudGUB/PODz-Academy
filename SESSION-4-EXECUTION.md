# Brief — Session 4 : Exécution

> À donner tel quel à une **nouvelle session** Claude ouverte sur ce dépôt
> (branche `mathieu/parcours`).

## Avant de commencer
1. Vérifie la branche : `git branch --show-current` doit afficher `mathieu/parcours` ;
   sinon `git checkout mathieu/parcours`. L'arbre de travail doit être propre.
2. Lis `CLAUDE.md` (contraintes non négociables) puis `ARCHITECTURE.md`.
3. Lis **`PLAN.md`** en entier. C'est ta feuille de route : décisions D-P1 à D-P10,
   architecture cible (§ 1), données de dev (§ 2), 12 lots (§ 3), dépendances prod
   (§ 4).
4. Garde **`SPECS.md`** sous la main comme référence fonctionnelle (US*, CA*, RG*), et
   les maquettes `maquettes/mon-parcours.html` et `maquettes/vue-manager.html` pour la
   DA (classes `.pod-mp-*`, `.pod-st--*` à reprendre).
5. Lance le serveur local et ouvre la page actuelle pour voir le point de départ :
   `powershell -ExecutionPolicy Bypass -File tools\serveur-dev.ps1` →
   http://localhost:8080/podz-academy.html

## Ce que tu dois faire
Réaliser les lots **L1 à L12** de `PLAN.md`, **dans l'ordre** (ou dans un ordre
compatible avec le graphe de dépendances du § 3), **un lot à la fois** :

1. Annonce le lot (objectif, fichiers touchés).
2. Implémente-le, et seulement lui.
3. Vérifie toi-même dans le navigateur local : le critère de test du lot, la
   non-régression (accueil, catalogue, une page profil) et, à partir de L5, la page
   `tests/tests-calculs.html` tout en vert. Pas d'erreur dans la console.
4. Donne à l'utilisateur la liste des vérifications à faire à l'écran (avec quel
   utilisateur simulé), puis **attends son OK**.
5. Après son OK : commit local `Lot Lx : <titre>` contenant seulement les fichiers du lot.
   **Pas de push.**

Si un lot se révèle trop gros, propose de le couper en deux avant de commencer. Si tu
dois t'écarter du plan (fonction renommée, fichier en plus), dis-le et note-le dans
`PLAN.md` (section « Écarts d'exécution » à créer en fin de fichier).

## Ce qui est décidé (ne pas rouvrir sans l'utilisateur)
- Tout ce qui est dans `SPECS.md` (§ 12.1 : PO1 à PO8 et PO10 tranchés).
- Décisions de la session 3 (`PLAN.md` § 0) : PO11 = `Ordre` global au MVP ; ↑/↓ pour
  réordonner ; réactivation d'un parcours type archivé ; « Mes formations » = Autonomie
  + `ParcoursType` vide ; **Techno : on attend le métier** (« — » en dev, ne pas remplir
  l'Excel nous-mêmes) ; une seule certif → copiée, plusieurs → aucune + « Certification
  au choix » ; un clic sur un lien démarre le module **depuis n'importe quel écran** ;
  données de dev injectées seulement sur localhost ; tests dans
  `tests/tests-calculs.html`.
- Deux interprétations sont à **montrer** à l'utilisateur au moment du lot concerné :
  la « Prochaine étape » saute les modules À valider (L6) ; le stockage du refus sur la
  ligne Progression (L4 / L7).

## Contraintes (rappel)
- **Jamais la prod** : ni la page SharePoint, ni les listes. Aucun appel réseau vers
  SharePoint. Les fonctions `sp.*` restent des squelettes qui rejettent.
- Pas de licence, pas de service externe, pas de CDN, pas de framework, pas de build.
- **Un seul fichier HTML**, JS ES5 vanilla, dans le style de l'existant (IIFE, `var`,
  `esc()` sur toute donnée injectée dans le HTML), CSS scopé par racine `.podz-*`.
- Outillage **PowerShell** seulement (pas de Node, pas de Python). Les `.ps1` restent en
  ASCII (accents via `[char]`).
- Le code d'affichage ne lit et n'écrit les données **que** via `window.PODZ.*`.
- `data/catalogue.js` ne s'édite **jamais** à la main : on le régénère avec
  `tools/excel-vers-catalogue.ps1`. Ne pas modifier l'Excel.
- Données de dev **fictives** uniquement (`@exemple.local`) : le dépôt est
  potentiellement public.
- Git : commits locaux sur `mathieu/parcours` uniquement ; **jamais de push** sans
  validation explicite de l'utilisateur ; jamais de commit sur `main`.

## Livrables de fin de session
- `podz-academy.html` avec le cockpit, la vue manager, l'assignation et l'autonomie.
- `data/dev-utilisateurs.js`, `data/dev-assignations.js`, `data/dev-progression.js`.
- `tools/excel-vers-catalogue.ps1` (colonnes lues par en-tête, `Techno`) et
  `data/catalogue.js` régénéré.
- `tests/tests-calculs.html`.
- `RECETTE.md` déroulé avec l'utilisateur ; `ARCHITECTURE.md` et `README.md` à jour.
- **`SESSION-5-PROD.md`** : brief de la session suivante (passage en prod). Il doit
  contenir les dépendances du § 4 de `PLAN.md` avec leur état, les fonctions `sp.*`
  et les `fetch*` / `save*` à implémenter, le piège des dates UTC et la procédure : page
  de test SharePoint, puis PR vers `main`, puis copier-coller dans la page de prod par
  l'utilisateur.

Si la session s'interrompt avant L12 : mets à jour l'en-tête de `PLAN.md` (lots faits /
restants) et écris un `SESSION-4-SUITE.md` court pour reprendre au bon lot.
