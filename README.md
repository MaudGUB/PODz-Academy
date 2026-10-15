# PODz-Academy
Catalogue de formation POD, devenu cockpit de formation : chaque consultant suit
**ses** parcours (à faire / en cours / à valider / terminé), le manager assigne des
parcours et valide les modules. Une seule page HTML (`podz-academy.html`), destinée à un
web part Modern Script Editor SharePoint. Architecture : `ARCHITECTURE.md`.

## Lancer en local
```
powershell -ExecutionPolicy Bypass -File tools\serveur-dev.ps1
```
puis ouvrir http://localhost:8080/podz-academy.html (ou http://127.0.0.1:8080/…).

Les données de dev (`data/*.js`) ne sont chargées que sur localhost : ouverte ailleurs,
la page affiche « Implémentation SharePoint à écrire au passage en prod » et n'écrit
rien. Pour simuler ce mode en local : `…/podz-academy.html?env=prod`.

## Bandeau dev
En dev, un bandeau jaune en haut de page permet de :
- **se connecter en tant que** l'un des 5 utilisateurs fictifs (`data/dev-utilisateurs.js`) :
  Camille, Hugo, Inès (consultants), Sarah (consultante et manager des trois), Alex
  (administrateur) ;
- **réinitialiser les données de dev** : efface les écritures faites pendant les tests
  (clés `podz.dev.*` du `localStorage`) et revient à l'état initial des fichiers
  `data/dev-assignations.js` et `data/dev-progression.js`.

Les données de référence datent du 15/10/2026. Pour figer la date du jour (cas « en
retard » stables), dans la console : `localStorage["podz.dev.aujourdhui"] = "2026-10-15"`.

## Tests des calculs
http://localhost:8080/tests/tests-calculs.html : vérifie les fonctions pures
`PODZ.calc.*` (avancement, niveaux, prochaine étape, transitions de statut, droits).
Tout doit être vert. Recette fonctionnelle de bout en bout : `RECETTE.md`.

## Données du catalogue
En dev, le catalogue ne lit pas les listes SharePoint : il charge `data/catalogue.js`,
généré depuis l'Excel `data/POD_Catalogue_Formations.xlsx` (onglet « Catalogue »). Ne
jamais éditer `catalogue.js` à la main ; après une modification de l'Excel :

```
powershell -ExecutionPolicy Bypass -File tools\excel-vers-catalogue.ps1
```

Les colonnes sont reconnues par leur en-tête (`ID`, `Titre`, `Type`, `Offre POD`,
`Bucket`, `Niveau`, `Durée`, `Lien(s)`, `Tags Skills`, `Plateforme`, `Obligatoire`,
`Notes`, `Techno`). La colonne `Techno` est encore absente (à remplir par le métier) :
le niveau par techno affiche « — » d'ici là.

L'Excel n'a pas de colonne « Parcours » : chaque formation est rattachée au parcours
type de son offre (table `PARCOURS_PAR_OFFRE` dans le script).
