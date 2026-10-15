# Brief — Session 2 : Specs

> À donner tel quel à une **nouvelle session** Claude ouverte sur ce dépôt
> (branche `mathieu/parcours`).

## Avant de commencer
Lis `CLAUDE.md` puis `ARCHITECTURE.md`. Regarde `podz-academy.html` (accueil par
profil, catalogue filtrable, page profil avec ses parcours) en le lançant avec
`tools/serveur-dev.ps1`.

## Livrables de cette session (et rien d'autre)
1. **`SPECS.md`** — cahier des charges complet de l'évolution.
2. **Maquette** de l'écran « Mon parcours » (et de l'écran manager si retenu au MVP),
   en HTML statique dans `maquettes/`, dans la DA existante du catalogue
   (couleurs `--pod-*`, composants `.pod-etape`, `.pod-hero`, `.pod-chip`…).
3. **`SESSION-3-PLAN.md`** — brief auto-porteur pour la session Plan.

Pas de développement dans le vrai `podz-academy.html` pendant cette session.

## Mode de travail
Mène la session comme un **entretien** : je suis le métier. Pose tes questions par
petits groupes, reformule, puis rédige. Ne tranche pas seul un point ouvert.

## User stories de départ
Reprises du use-case de la formation :
- **US1** — En tant que consultant, je parcours facilement les formations par techno,
  compétence et niveau. *(existe déjà : catalogue filtrable)*
- **US2** — En tant que consultant et manager, je suis des parcours permettant
  d'atteindre un niveau cible sur une compétence.
- **US3** — En tant que consultant, je vois rapidement les infos clés d'une formation
  ou d'un parcours (temps, format, sachant…). *(existe en partie)*

Ajoutées par notre objectif (remplacer le Planner) :
- **US4** — En tant que consultant connecté, je vois **mon** parcours assigné
  (formations ordonnées, échéance).
- **US5** — En tant que consultant, je change le statut d'une formation :
  à faire / en cours / fait (+ date).
- **US6** — En tant que consultant, je vois ma progression globale.
- **US7** — En tant que manager, j'assigne un parcours à un consultant.
  *(MVP possible : assignation saisie directement dans la liste SharePoint)*
- **US8** — En tant que manager, je vois l'avancement de mes consultants. *(à confirmer)*

## Contraintes à respecter dans les specs
- Pas de licence payante, pas d'accès admin SharePoint, pas de service externe.
- Un seul fichier HTML, JS vanilla, compatible Modern Script Editor.
- Toute donnée passe par la couche `window.PODZ.fetch*` / `saveStatut` décrite dans
  `ARCHITECTURE.md` ; en dev : Excel + `localStorage` + utilisateur simulé.
- Nouvelles listes SharePoint (Assignations, Progression) = dépendance à un
  propriétaire de site : à décrire précisément (colonnes, types, permissions).

## Questions à me poser (au minimum)
- Qu'est-ce qu'un parcours : liste ordonnée de formations ? niveau cible ? durée ?
- Un consultant peut-il avoir plusieurs parcours en même temps ? des formations hors
  parcours ?
- Statuts exacts, et qui peut les modifier (le consultant seul ? le manager valide ?)
- Échéances : par parcours ou par formation ?
- Écran manager au MVP ou plus tard ? Que voit-il ?
- Confidentialité : qui voit la progression de qui ?
- Que deviennent les données du Planner actuel (reprise ou départ à zéro) ?

## Contenu attendu de `SPECS.md`
Contexte et objectif · personas · user stories avec critères d'acceptation ·
parcours utilisateur (écrans et navigation) · modèle de données (listes, colonnes,
types, exemples) · règles de gestion · données de dev (format du jeu de test) ·
hors périmètre · points ouverts.
