# PODz Academy — instructions projet

## Contexte
Catalogue de formation POD. En prod, c'est une page HTML (`podz-academy.html`) collée
dans un web part **Modern Script Editor** d'une page SharePoint, qui lit des **listes
SharePoint** (formations, profils, parcours).

**Objectif du projet** : faire évoluer le catalogue pour que chaque consultant voie
**son** parcours de formation assigné et suive son avancement (à faire / en cours /
fait), en remplacement du Planner. Les managers assignent les parcours.

Méthode : formation Claude POD, multi-sessions — Conception & set-up → Specs → Plan →
Exécution. Une nouvelle session Claude par étape ; chaque étape se termine par un
fichier `.md` auto-porteur pour la suivante.

## Contraintes (non négociables)
- **Ne jamais toucher la prod** : ni la page SharePoint, ni les listes SharePoint.
  Tout se développe et se teste en local (voir `ARCHITECTURE.md`).
- **Pas de licence payante**, aucun service externe (pas de Firebase, Vercel, GitHub
  Pages payant, etc.).
- **Pas d'accès admin** SharePoint : tout ce qui demande un propriétaire de site
  (création de listes, permissions) est une dépendance à signaler, pas à contourner.
- Technos : **HTML + CSS + JavaScript vanilla** dans un seul fichier, compatible
  Modern Script Editor (pas de framework, pas de build, pas de CDN). Outillage local en
  **PowerShell** (pas de Node ni de Python sur les postes).

## Données
- Dev : `data/catalogue.js`, généré depuis `data/POD_Catalogue_Formations.xlsx` par
  `tools/excel-vers-catalogue.ps1`. Ne jamais éditer `catalogue.js` à la main.
- Le HTML n'accède aux données que via les fonctions `window.PODZ.fetch*` (couche
  d'accès aux données) : jamais d'appel direct aux données dans le code d'affichage.
- Les données de dev gardent le **format des items REST SharePoint** (`Title`,
  `field_2`…`field_11`, `DureeHeures`, `Parcours`…) pour que le passage en prod se
  limite à remplacer la source.

## Git
- `main` = référence partagée. On n'y pousse **jamais** directement.
- Une branche par personne (`mathieu/parcours`, `chloe`, `laeticia`).
- Commits locaux librement ; **push uniquement après validation explicite** de
  l'utilisateur (le dépôt `MaudGUB/PODz-Academy` est potentiellement public : pas de
  données sensibles sans accord).
- Fusion vers `main` par pull request relue.

## Lancer en local
```
powershell -ExecutionPolicy Bypass -File tools\serveur-dev.ps1
```
puis http://localhost:8080/podz-academy.html

## Documents du projet
- `ARCHITECTURE.md` — environnements dev / prod, flux de données, décisions.
- `SESSION-2-SPECS.md` — brief de la prochaine session (Specs).
