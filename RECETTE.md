# RECETTE — PODz Academy (cockpit consultant et vue manager)

> Recette de bout en bout de la session 4 (Exécution), à dérouler avec l'utilisateur.
> Références : `SPECS.md` (US*, CA*, RG*), `PLAN.md` (lots L1–L12).
> Déroulée avec l'utilisateur le 15/10/2026 : toutes les lignes validées, aucune anomalie.
> Pour une nouvelle recette : décocher, puis cocher chaque ligne une fois vérifiée ; noter tout écart dans la
> section « Anomalies » en bas.

## Préparation
- [x] Serveur lancé : `powershell -ExecutionPolicy Bypass -File tools\serveur-dev.ps1`
- [x] http://localhost:8080/podz-academy.html s'ouvre, bandeau jaune DEV visible
- [x] Bandeau → « Réinitialiser les données de dev » → confirmer (état initial)
- [x] Si la date du jour n'est plus le 15/10/2026 : console →
      `localStorage["podz.dev.aujourdhui"] = "2026-10-15"` puis recharger
- [x] http://localhost:8080/tests/tests-calculs.html → « Tout est vert »

Les scénarios s'enchaînent dans l'ordre : chacun part de l'état laissé par le précédent.

## 0. Non-régression du catalogue (US1, US3)
- [x] Accueil : 5 profils, entrées « Mon profil » et « Explorer tout le catalogue »
- [x] Catalogue : 40 formations, filtres Offres / Buckets / Niveaux / Type, recherche par titre
- [x] Carte à un lien : clic → la formation s'ouvre dans un nouvel onglet
- [x] Carte à plusieurs liens : se déplie, tous les liens sont listés
- [x] Page profil (ex. Chef de Projet) : parcours, étapes dépliables, socle commun
- [x] Fil d'Ariane et boutons précédent / suivant du navigateur

## 1. Camille Test — consultante (US2, US4, US5, US6, US4c)
- [x] Accueil : pas d'entrée « Mon équipe »
- [x] Accueil : « Mon profil » porte le badge « 1 à reprendre » (PowerPoint avancé refusé)
- [x] Mon profil : « Bonjour Camille », 3 parcours en cours, KPIs 4 / 16 · 0 certification · 1 / 13 médailles · 1 à valider
- [x] Encart « Certification visée » en tête d'Analyste Power BI : PL-300 à passer, « Encore 4 formations… » ; aucun encart sur Restitution & DataViz
- [x] Carte « Certifications » : aucune obtenue, PL-300 et PL-200 « en ligne de mire »
- [x] Carte « Médailles » : « Premier pas » en couleur, les 12 autres grisées avec leur critère et leur avancement
- [x] Analyste Power BI : « Assigné par Sarah Manager », cible 31/12/2026, 29 % (2/7)
- [x] SQL « Terminé le 12/09/2026 », Data management « Terminé · dispensé », Modélisation « À valider · fini le 10/10 »
- [x] Restitution & DataViz : « personnalisé », cible 30/09/2026 « en retard » (orange)
- [x] Design / DataViz : « aussi dans « … » » dans les deux parcours
- [x] Automatisation des processus : « Choisi en autonomie », « Pas d'échéance », bouton « Retirer »
- [x] Onglet « Cockpit », carte « Mes formations en cours » : PowerPoint avancé en tête (« Prochaine étape »), puis Power BI, Copilot (en cours), puis Design / DataViz, Data Quality, Automatisation (à commencer), chacun avec ses deux boutons
- [x] « Je commence » depuis le raccourci Automatisation / Power Automate → il passe dans les formations en cours ; message de confirmation
- [x] Onglet « Mes parcours (3) » : le détail des 3 parcours ; après une action dans cet onglet, on y reste
- [x] Barre en haut : « Mon profil » (actif) · « Explorer le catalogue » ; pas de « Mon équipe »
- [x] Niveau par compétence : Analyse Fondamentaux · Adoption Intermédiaire · Pilotage — · Process Fondamentaux
- [x] Onglet « Par techno » : mention « colonne Techno pas encore renseignée »
- [x] PowerPoint avancé déplié : commentaire de refus de Sarah + « J'ai terminé… »
- [x] « Je commence » sur Data Quality → « En cours depuis le 15/10 »
- [x] Catalogue → clic sur la carte Design / DataViz → retour Mon profil : En cours dans les deux parcours
- [x] Catalogue → clic sur Data Catalog - DataGalaxy (hors parcours) → aucun changement
- [x] « J'ai terminé… » sur Power BI avec une date future → message d'erreur
- [x] « J'ai terminé… » sur Power BI avec la date du jour → « À valider · fini le 15/10 »
- [x] Aucun bouton ne permet de passer un module à Terminé
- [x] Aucun bouton « Retirer » ni « Modifier » sur les parcours assignés
- [x] `#mon-equipe` et `#assigner` saisis à la main → retour à l'accueil

## 2. Inès Test — consultante en autonomie (US4b, US4c, RG9, RG18)
- [x] Mon profil : « Acculturation Data » et « Mes formations » (Travailler efficacement avec l'IA)
- [x] Profil « Analyste Data » → « Suivre ce parcours » → bouton « Déjà dans mes parcours »
- [x] Mon profil : « Analyste Power BI » en autonomie, sans échéance, PL-300 en dernier
- [x] « Retirer de mes parcours » sur Acculturation Data → confirmer → le parcours disparaît
- [x] Catalogue : « Ajouter à mes formations » sur un module → il rejoint « Mes formations » (à la fin)
- [x] Le même module affiche ensuite « Déjà dans mes parcours »

## 3. Hugo Test — consultant (D-P4, D-P7, RG9)
- [x] Mon profil : 1 parcours actif (Pilotage de projet Data), l'archivé n'apparaît pas
- [x] Encart « Certifications visées (au choix) » (PSM I · PSPO ×2 · PMP) en tête du parcours
- [x] Formations en cours : Schéma Directeur en « Prochaine étape » (Agile, À valider, est sauté)
- [x] Profil « Nouveau PODz » → « Suivre ce parcours » → « Bien démarrer chez POD » réactivé, sans doublon
- [x] Catalogue → « Ajouter à mes formations » sur Power BI (panneau déplié) → « Mes formations » apparaît
- [x] Agile (SCRUM) affiche « Déjà dans mes parcours »

## 4. Sarah Manager — consultante et manager (US7, US8, RG6, RG7, RG14, RG16, RG20)
- [x] Accueil : entrée « Mon équipe » avec badge **3**
- [x] Mon profil : son propre cockpit (Bien démarrer chez POD, assigné par Alex)
- [x] Barre en haut : « Mon profil » · « Mon équipe (N) » (validations en attente) · « Explorer le catalogue » ; un clic passe d'un espace à l'autre (et retour) sans repasser par l'accueil
- [x] Fiche d'un collaborateur : onglets « Cockpit » et « Parcours », formations en cours sans boutons d'action (« Voir la formation ↗ » seulement)
- [x] Carte « Certifications » : Change Management - Prosci (ADKAR) obtenue le 24/06/2026 ; médaille « Certifié » débloquée
- [x] Mon équipe : KPIs 3 collaborateurs · 3 à valider · 1 parcours en retard
- [x] File : Agile (Hugo), Modélisation (Camille), Data Literacy (Inès), avec « Depuis N j »
- [x] Data Literacy d'Inès toujours présent malgré le retrait de son parcours
- [x] Valider Modélisation (Camille) → la file passe à 2 ; accueil : badge 2
- [x] Refuser Agile (Hugo) sans commentaire → bloqué ; avec commentaire → la file passe à 1
- [x] Onglet Équipe : Camille ~25 % « en retard », Hugo, Inès ; clic sur une ligne → détail
- [x] Détail Camille : son cockpit sans « Je commence » ni « J'ai terminé… »
- [x] Détail Inès : « Refuser » sur Data Literacy (À valider) → motif obligatoire, puis le module repasse En cours avec le commentaire
- [x] Détail Camille : « Dispenser » sur Data Quality → « Terminé · dispensé », % et heures réalisées augmentent
- [x] Assigner → Hugo, « Analyste Power BI », cible 31/03/2027, retirer Data Quality, Modélisation en 1re position, ajouter Agents IA & GenAI → Assigner
- [x] Sans date cible : bouton désactivé avec le motif
- [x] Camille + « Analyste Power BI » → message « suit déjà » + lien « Modifier ce parcours »
- [x] Hugo + parcours vide : Cycle en V « Déjà terminé par Hugo le 03/06/2026 », Agile « en attente de ta validation » ; nommer et assigner → OK
- [x] Détail Camille → « Restitution & DataViz » → « Modifier le parcours » : ajouter Vidéo / Vyond, le monter en tête, date cible 31/12/2026 → Enregistrer
- [x] Retirer PowerPoint avancé → Enregistrer → le rajouter depuis le catalogue → Enregistrer : refus et commentaire toujours là
- [x] « Archiver » Restitution & DataViz → disparaît du détail ; le niveau Adoption reste Intermédiaire
- [x] Sarah ne voit jamais ses propres modules dans sa file

## 5. Retour chez les consultants
- [x] Camille : Modélisation « Terminé le 15/10/2026 », niveau Analyse Intermédiaire
- [x] Camille : Restitution & DataViz n'apparaît plus (archivé) ; Data Quality « Terminé · dispensé »
- [x] Hugo : Agile (SCRUM) En cours avec le commentaire de Sarah ; « Analyste Power BI » (ordre choisi par Sarah, cible 31/03/2027) et le parcours personnalisé

## 6. Alex Admin — administrateur (CA8.5)
- [x] Mon profil : écran vide avec les parcours types et le catalogue
- [x] Mon équipe : 4 collaborateurs (Sarah comprise), « Espace administrateur »
- [x] Peut valider un module de Sarah (Sarah : « J'ai terminé… » sur un module, puis Alex valide)

## 7. Mode prod simulé et finitions
- [x] `…/podz-academy.html?env=prod` : pas de bandeau, message « Implémentation SharePoint à écrire », aucune erreur JS
- [x] Largeur téléphone (≈ 375 px) : accueil, catalogue, cockpit, Mon équipe, Assigner sans défilement horizontal
- [x] Titre de l'onglet du navigateur propre à chaque vue
- [x] Plus aucun « Mon parcours » affiché : l'écran s'appelle « Mon profil » (accueil, fil d'Ariane, titre de l'onglet, barre de navigation)
- [x] Console : aucune erreur pendant toute la recette
- [x] Après chaque action (démarrer, déclarer, valider, refuser, dispenser, assigner, suivre, ajouter, retirer, archiver), un message de confirmation vert s'affiche quelques secondes en bas de l'écran
- [x] Heures : seulement par parcours (« 80,5 h (≈ 11,5 j) restantes sur 108,5 h »), plus de cumul dans le bandeau du cockpit

## Anomalies
| # | Persona / étape | Constat | Suite donnée |
|---|---|---|---|
| — | — | Aucune anomalie constatée | — |
