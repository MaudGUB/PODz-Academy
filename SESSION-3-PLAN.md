# Brief — Session 3 : Plan

> À donner tel quel à une **nouvelle session** Claude ouverte sur ce dépôt
> (branche `mathieu/parcours`).

## Avant de commencer
1. Lis `CLAUDE.md` (contraintes non négociables) puis `ARCHITECTURE.md` (dev local /
   prod SharePoint, couche `window.PODZ`).
2. Lis **`SPECS.md`** en entier : c'est la référence validée en session 2.
3. Ouvre les maquettes `maquettes/mon-parcours.html` (cockpit consultant) et
   `maquettes/vue-manager.html` (validation, équipe, détail, assignation) : elles fixent
   la DA et le contenu attendu des écrans.
4. Parcours le vrai `podz-academy.html` (≈ 1 070 lignes, 3 blocs : accueil `.podz-home`,
   catalogue `.podz-cat`, profil `.podz-profile`, et la couche de données
   `window.PODZ` avec `mapItem`, `fetchCatalogue`, `fetchProfils`, `fetchParcours`).
   Lance-le avec `powershell -ExecutionPolicy Bypass -File tools\serveur-dev.ps1`
   → http://localhost:8080/podz-academy.html.

## Livrable de cette session (et rien d'autre)
**`PLAN.md`** : plan d'exécution découpé en **lots courts, testables et commitables
un par un**, chacun avec :
- objectif et user stories / règles couvertes (US*, CA*, RG* de `SPECS.md`) ;
- fichiers touchés et fonctions créées ou modifiées ;
- critères de test en local (ce que l'utilisateur vérifie à l'écran, avec quel
  utilisateur simulé) ;
- dépendances entre lots.

Puis **`SESSION-4-EXECUTION.md`** : brief auto-porteur pour la session d'exécution.

Pas de développement dans `podz-academy.html` pendant cette session.

## Ce qui est décidé (ne pas rouvrir sans l'utilisateur)
- **MVP** : cockpit consultant « Mon parcours », auto-assignation d'un parcours type,
  assignation manager (parcours type adapté ou construit module par module + date
  cible), cycle de statuts avec validation manager et dispense, vue manager (équipe,
  file « À valider », détail), notification **dans l'outil** uniquement.
- **Statuts** : À faire (non stocké) → En cours (auto au 1er clic sur un lien) → À
  valider (déclaré par le consultant avec date de fin) → Terminé (validé ou dispensé par
  le manager). Refus = retour En cours avec commentaire.
- **Progression portée par consultant × module** ; un parcours n'est qu'une liste
  ordonnée d'IDs de modules (copie à l'assignation).
- **Date cible par parcours**, fixée par le manager ; aucune en autonomie.
- **Niveau** = niveau max des modules Terminés, par compétence et par techno.
- **Rôles** consultant / manager / admin, cumulables.
- **V2 / plus tard** : parcours par mots-clés, création de parcours types dans l'outil,
  e-mails/Teams (Power Automate), reprise Planner, vraie liste des équipes.

## Points à traiter dans le plan
- **Données de dev** (`SPECS.md` § 10) : créer `data/dev-utilisateurs.js`,
  `data/dev-assignations.js`, `data/dev-progression.js` (fictifs, format items REST
  SharePoint) + surcouche `localStorage` préfixée `podz.dev.` + bouton de
  réinitialisation. Décider comment le HTML les charge en dev sans les embarquer en prod
  (ex. `<script src>` conditionnels comme `catalogue.js`).
- **Couche `window.PODZ`** (§ 9) : `fetchUtilisateur`, `fetchEquipe`,
  `fetchAssignations`, `fetchProgression`, `saveAssignation`, `saveStatut` + `map*`.
  Prévoir dès maintenant la signature des implémentations SharePoint (REST, digest)
  même si elles ne seront écrites qu'au passage en prod.
- **Sélecteur « Se connecter en tant que… »** (dev uniquement).
- **Navigation** : comment ajouter les vues « Mon parcours » et « Mon équipe » au
  routage existant de la page (regarder comment l'accueil, le catalogue et le profil
  s'enchaînent aujourd'hui).
- **Calculs** : avancement, heures réalisées / restantes (modules partagés comptés une
  fois), retard, niveau, « prochaine étape » — idéalement en fonctions pures testables.
- **Ordre de réalisation suggéré** : données de dev + couche d'accès → cockpit en
  lecture → transitions de statut consultant → vue manager (validation, dispense) →
  assignation (autonomie puis manager) → finitions et recette.
- **Points ouverts de `SPECS.md` § 12** : les reprendre avec l'utilisateur en début de
  session (en particulier PO1 clic sur lien, PO2 affichage dispense, PO3 colonne
  `Techno`, PO5 abandon d'un parcours, PO6 module hors parcours, PO7 modification d'un
  parcours assigné) et consigner les réponses dans `SPECS.md`.
- **Dépendances prod** à lister à part (propriétaire du site) : création des listes
  Assignations, Progression, Équipes (§ 8.2), permissions (§ 8.3), arbitrage
  confidentialité (§ 8.4).

## Contraintes (rappel)
- Jamais la prod (page, listes SharePoint). Pas de licence, pas de service externe,
  pas d'admin SharePoint.
- Un seul fichier HTML, JS vanilla, sans framework / build / CDN, compatible Modern
  Script Editor. Outillage PowerShell uniquement.
- Le code d'affichage ne lit les données que via `window.PODZ.*`.
- Ne jamais éditer `data/catalogue.js` à la main.
- Données de dev **fictives** : dépôt potentiellement public.
- Git : commits locaux sur `mathieu/parcours` ; **pas de push** sans validation
  explicite de l'utilisateur.

## Mode de travail
Propose le découpage en lots, fais-le valider par l'utilisateur, puis rédige
`PLAN.md`. Ne tranche pas seul un point ouvert.
