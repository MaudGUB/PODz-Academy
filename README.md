# PODz-Academy
Catalogue de formation POD

## Données de dev
En dev, le catalogue ne lit pas les listes SharePoint : il charge `data/catalogue.js`,
généré depuis l'Excel `data/POD_Catalogue_Formations.xlsx` (onglet « Catalogue »).

Après une modification de l'Excel, régénérer les données :

```
powershell -ExecutionPolicy Bypass -File tools\excel-vers-catalogue.ps1
```

L'Excel n'a pas de colonne « Parcours » : chaque formation est rattachée au parcours
de son offre (table `PARCOURS_PAR_OFFRE` dans le script).

## Lancer en local
```
powershell -ExecutionPolicy Bypass -File tools\serveur-dev.ps1
```
puis ouvrir http://localhost:8080/podz-academy.html
