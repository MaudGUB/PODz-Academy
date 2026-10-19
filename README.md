# PODz Academy

L'application de formation interne de POD tient dans **un seul fichier** : `podz-academy.html` (version 10). Il n'y a rien à installer sur l'ordinateur.

## Mise en place (site de test)

1. Sur le site de test, créer une **nouvelle page** (ne jamais tester sur une page existante importante).
2. Cliquer sur **Modifier**, ajouter le web part **Modern Script Editor**, puis **Edit markup**.
3. Ouvrir `podz-academy.html` dans le Bloc-notes, **Ctrl+A**, **Ctrl+C**, coller dans le web part, enregistrer, puis **Publier**.
4. La première fois, une personne qui a le droit **« Gérer les listes »** clique sur **Installer les listes PODz**. Elle peut ajouter des données de démonstration.
5. Remplir la liste **PODz Equipe** : une ligne par personne (voir plus bas).

**Mise à jour :** recoller le nouveau fichier dans le même web part. Les données restent dans les listes.

**Arriver directement sur la page :** dans « Pages du site », cliquer sur « … » à côté de la page, puis sur **Définir comme page d'accueil** (propriétaire du site).

**Démo :** `podz-academy.html` ouvert directement dans un navigateur, hors SharePoint, affiche l'application avec des données d'exemple gardées dans ce navigateur.

## Ce que contient l'application

| Onglet | Pour qui | Contenu |
|---|---|---|
| Ma ruche | tout le monde | progression, ruche, badges, formations en cours, prochaines échéances, demandes en attente |
| Mon plan | tout le monde | toutes ses formations (en cours, à faire, terminées, en retard), ressources à cocher, commentaires, quiz bonus |
| Calendrier | tout le monde | échéances du mois ; un manager peut afficher son équipe ou lui-même |
| Catalogue | tout le monde | toutes les formations ; un consultant peut **demander** une formation à son manager |
| Métiers POD | tout le monde | les métiers et leurs parcours types |
| Mon équipe | managers | demandes à accepter ou refuser, formations à valider, suivi par consultant, parcours, export Excel |
| + Nouveau profil | managers | création d'un consultant à partir de son CV : la personne, son CV, le plan proposé, la création |

Le CV est lu dans le navigateur, il n'est ni envoyé ni enregistré : seul le plan de formation est gardé.

## Listes SharePoint

L'application **lit seulement** les listes POD existantes et ne les modifie jamais :
- le catalogue `Liste_formation_Pod` (ou `Liste_formation_Pod_Test`), sinon `PODz Catalogue`, sinon une copie de `POD_Catalogue_Formations.xlsx` intégrée au fichier ;
- les listes `Profils` et `Parcours`, avec ou sans le suffixe `_Test`, si elles existent.

Le bouton « Installer » crée les listes suivantes, sans toucher aux permissions. Il peut être relancé : ce qui existe déjà est conservé.

| Liste | Contenu | Écrite par |
|---|---|---|
| `PODz Equipe` | une ligne par personne : `Title` (nom), `Email`, `Role` (manager / consultant), `Manager` (nom du manager), `Profil` (métier), `Couleur` | les managers (métier, nouveau profil) |
| `PODz Attributions` | une ligne par formation attribuée ou demandée : échéance, avancement, commentaires, quiz | tout le monde |
| `PODz Parcours` | parcours créés ou modifiés par les managers | les managers |
| `PODz Quiz` | questions des quiz bonus (facultative) | l'installation |
| `PODz Catalogue` | catalogue de secours si `Liste_formation_Pod` est absente | l'installation |

Rien n'est jamais supprimé : une formation annulée ou une demande refusée est seulement marquée comme telle.

## Connexion et rôles

- Il n'y a pas de connexion propre à l'application : elle utilise la session Microsoft déjà ouverte dans SharePoint.
- La personne connectée est retrouvée dans `PODz Equipe` par son e-mail, sinon par son nom. Son rôle vient de la colonne `Role`.
- Pour enregistrer son avancement, un consultant doit être **membre** du site.
- Le droit **« Gérer les listes »** permet d'installer l'application et d'utiliser **« Aperçu en tant que »** (voir la page comme une autre personne de l'équipe).
- Les rôles manager / consultant sont vérifiés par l'interface ; techniquement, un membre du site peut modifier les listes. C'est suffisant pour le test, à revoir avant la production.

## Connexions externes

- **SharePoint** (API du site courant) : toutes les données.
- **cdnjs.cloudflare.com** : lecteurs PDF (`pdf.js`) et Word (`mammoth`), chargés uniquement quand un CV est déposé. S'ils sont bloqués, on peut coller le texte du CV.
- Les liens des formations ouvrent simplement les sites concernés dans un nouvel onglet.

## Pourquoi la page tient après un rafraîchissement

Des versions précédentes s'affichaient une fois, puis devenaient blanches après F5. La v10 respecte trois règles :
- aucun calque plein écran n'est écrit dans la page : fenêtres, confettis et transitions sont créés par le script, puis retirés ;
- dans SharePoint, l'adresse de la page n'est jamais modifiée (l'écran courant est gardé en mémoire) ;
- aucune police ni aucun script externe n'est chargé à l'ouverture.

## Dépannage

- **« Tu n'es pas encore inscrit·e »** : ajouter la personne dans `PODz Equipe` (e-mail exact).
- **Une personne se voit consultante au lieu de manager** : vérifier la colonne `Role` de sa ligne.
- **« Enregistrement SharePoint impossible »** : la personne n'a probablement pas le droit de modifier les listes (elle doit être membre du site).
- **Le bouton « Installer » n'apparaît pas** : il faut le droit « Gérer les listes ».
- **Lecture du CV impossible** : utiliser « Coller le texte du CV ».
