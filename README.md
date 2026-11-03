# PODz Academy

L'application de formation interne de POD tient dans **un seul fichier** : `podz-academy.html` (version 11.1). Il n'y a rien à installer sur l'ordinateur.

Toutes les données viennent des **listes SharePoint du site** où la page est posée, avec **une seule source par sujet**. Le fichier ne contient plus aucune donnée : ouvert hors SharePoint, il affiche seulement un message.

## Mise en place (site de test)

1. La liste **`PODz Formations`** (le catalogue) doit exister sur le site. Le bouton « Installer » ne la crée pas.
2. Sur le site de test, créer une **nouvelle page** (ne jamais tester sur une page existante importante).
3. Cliquer sur **Modifier**, ajouter le web part **Modern Script Editor**, puis **Edit markup**.
4. Ouvrir `podz-academy.html` dans le Bloc-notes, **Ctrl+A**, **Ctrl+C**, coller dans le web part, enregistrer, puis **Publier**.
5. La première fois, une personne qui a le droit **« Gérer les listes »** clique sur **Installer les listes PODz**. Elle est ajoutée automatiquement comme **manager** dans `PODz Equipe`, et `PODz Metiers` est rempli avec les 5 métiers POD.
6. Ajouter les autres personnes avec **+ Nouveau profil** (managers), ou directement dans `PODz Equipe` (voir plus bas).

**Mise à jour :** recoller le nouveau fichier dans le même web part. Les données restent dans les listes.

**Arriver directement sur la page :** dans « Pages du site », cliquer sur « … » à côté de la page, puis sur **Définir comme page d'accueil** (propriétaire du site).

### Passage de la v10 à la v11

La v11 reconnaît les personnes par leur **e-mail** et les formations par leur ligne dans `PODz Formations`. Les données créées par la v10 (personnes sans e-mail, formations repérées par F001…) ne sont plus reconnues. Pour repartir proprement :

1. Coller la v11 dans le web part.
2. Dans **Contenu du site**, supprimer `PODz Equipe`, `PODz Parcours` et `PODz Attributions` (elles partent dans la corbeille du site). **Garder `PODz Quiz`.**
3. Recharger la page et cliquer sur **Installer les listes PODz**.

Les listes `PODz Catalogue`, `Liste_formation_Pod_Test`, `PODz Academy Data` et `PODz CV` ne sont plus lues par l'application.

## Ce que contient l'application

| Onglet | Pour qui | Contenu |
|---|---|---|
| Ma ruche | tout le monde | progression, ruche, badges, formations en cours, prochaines échéances, demandes en attente |
| Mon plan | tout le monde | toutes ses formations (en cours, à faire, terminées, en retard), ressources à cocher, commentaires, quiz bonus |
| Calendrier | tout le monde | échéances du mois ; un manager peut afficher son équipe ou lui-même |
| Catalogue | tout le monde | les formations ; un consultant peut **demander** une formation à son manager. Un manager peut **ajouter** et **modifier** une formation |
| Métiers POD | tout le monde | les métiers et leurs parcours types |
| Mon équipe | managers | demandes à accepter ou refuser, formations à valider, suivi par consultant, parcours, export Excel |
| + Nouveau profil | managers | création d'un consultant à partir de son CV : la personne (avec son e-mail), son CV, le plan proposé, la création |

Le CV est lu dans le navigateur, il n'est ni envoyé ni enregistré : seul le plan de formation est gardé.

### Ajouter ou modifier une formation (managers)

- **Catalogue → + Nouvelle formation** ouvre un formulaire. L'ID formation est proposé automatiquement (prochain `F…` ou `C…` libre). La date d'ajout est remplie toute seule.
- Sur la fiche d'une formation, **✎ Modifier la formation** ouvre le même formulaire.
- Les listes de choix (Type, Offre, Compétence, Niveau, Format, Portée) sont celles des colonnes de `PODz Formations` : pour ajouter un choix, on modifie la colonne dans SharePoint.
- **Titre**, **Type**, **Offre**, **Niveau** et au moins un **lien** sont obligatoires. Chaque lien devient une ressource à cocher.
- Deux formations ne peuvent pas avoir le même titre. **Attention :** les questions de `PODz Quiz` sont rattachées à une formation par son titre ; si on renomme une formation, il faut aussi corriger la colonne `Formation` de ses questions.
- Une formation ajoutée depuis moins de 30 jours porte le badge **✨ Nouveau**.
- Il n'y a pas de suppression depuis le site.

### Formations propres à une mission

Une formation dont la **Portée** vaut « Spécifique mission » est visible des managers (avec un filtre « Portée » dans le Catalogue) et des seules personnes à qui elle est attribuée. Elle n'est jamais proposée d'office dans le plan d'un nouveau profil.

## Listes SharePoint

**Une seule source par sujet.** Si une liste manque, la page le dit clairement.

| Liste | Contenu | Créée par | Écrite par |
|---|---|---|---|
| `PODz Formations` | le catalogue (voir colonnes ci-dessous) | POD, à la main | les managers (ajout, modification) |
| `PODz Equipe` | une ligne par personne : `Title` (nom), `Email`, `Role` (manager / consultant), `Manager` (**e-mail** du manager), `Profil` (Slug du métier), `ProfilPar`, `ProfilDate` | l'installation | les managers |
| `PODz Metiers` | les métiers : `Title` (nom), `Slug`, `Tag`, `SousTitre`, `Description`, `Couleur` (Orange, Jaune, Vert, Bleu, Rose ou Violet), `PageDepart` (métier « Commence ici »), `Ordre` | l'installation (remplie une fois) | à la main dans la liste |
| `PODz Parcours` | les parcours créés ou modifiés par les managers | l'installation | les managers |
| `PODz Attributions` | une ligne par formation attribuée ou demandée : échéance, avancement, commentaires, quiz | l'installation | tout le monde |
| `PODz Quiz` | questions des quiz bonus : `Title` (question), `Formation` (titre de la formation), `Choix` (un par ligne), `Reponses` (numéros des bonnes réponses, séparés par `;`), `Seuil`, `Ordre` | l'installation (vide) | à la main dans la liste |

Colonnes de `PODz Formations` utilisées (nom interne entre parenthèses) : Titre (`Title`), ID formation (`FormationId`), Type (`TypeFormation`), Offre (`Offre`), Compétence (`Competence`), Niveau (`Niveau`), Durée (`Duree`, ex. « 0,5 j » ou « 2 h »), Format (`Format`), Sachant (`Sachant`), Plateforme (`Plateforme`), Bucket (`Bucket`), Liens, un par ligne (`Liens`), Tags, séparés par des virgules (`Tags`), Notes (`Notes`), Obligatoire (`Obligatoire`), Portée (`Portee`), Contexte (`Contexte`), Date d'ajout (`DateAjout`).

Le **Slug** d'un métier est son identifiant : il est repris dans la colonne `Profil` de `PODz Equipe` et de `PODz Parcours`. Ne pas le changer une fois utilisé.

Rien n'est jamais supprimé : une formation annulée ou une demande refusée est seulement marquée comme telle.

## Connexion et rôles

- Il n'y a pas de connexion propre à l'application : elle utilise la session Microsoft déjà ouverte dans SharePoint.
- La personne connectée est retrouvée dans `PODz Equipe` **uniquement par son e-mail** (majuscules ignorées). Une ligne sans e-mail est ignorée. Son rôle vient de la colonne `Role`, son manager de la colonne `Manager` (e-mail).
- Une personne qui n'est pas dans `PODz Equipe` voit : « Bonjour ! Merci de contacter ton ou ta manager pour qu'il ou elle puisse te créer un profil pour tes formations. Bizzzz 🐝 ». C'est aussi le cas d'un propriétaire du site, à qui la page indique l'e-mail à ajouter.
- Pour enregistrer son avancement, un consultant doit être **membre** du site.
- Pour ajouter ou modifier une formation, un manager doit pouvoir **modifier** la liste `PODz Formations`.
- Le droit **« Gérer les listes »** permet d'installer l'application et d'utiliser **« Aperçu en tant que »** (voir la page comme une autre personne de l'équipe).
- Les rôles manager / consultant sont vérifiés par l'interface ; techniquement, un membre du site peut modifier les listes. C'est suffisant pour le test, à revoir avant la production.

## Connexions externes

- **SharePoint** (API du site courant) : toutes les données.
- **cdnjs.cloudflare.com** : lecteurs PDF (`pdf.js`) et Word (`mammoth`), chargés uniquement quand un CV est déposé. S'ils sont bloqués, on peut coller le texte du CV.
- Les liens des formations ouvrent simplement les sites concernés dans un nouvel onglet.

## Pourquoi la page tient après un rafraîchissement

Des versions précédentes s'affichaient une fois, puis devenaient blanches après F5. L'application respecte trois règles :
- aucun calque plein écran n'est écrit dans la page : fenêtres, confettis et transitions sont créés par le script, puis retirés ;
- dans SharePoint, l'adresse de la page n'est jamais modifiée (l'écran courant est gardé en mémoire) ;
- aucune police ni aucun script externe n'est chargé à l'ouverture.

## Dépannage

- **« Merci de contacter ton ou ta manager… »** : ajouter la personne dans `PODz Equipe` avec son **e-mail Microsoft exact**.
- **« Catalogue introuvable »** : la liste `PODz Formations` n'existe pas sur ce site, ou porte un autre nom.
- **Une personne se voit consultante au lieu de manager** : vérifier la colonne `Role` de sa ligne.
- **Un consultant n'apparaît pas dans « Mon équipe »** : la colonne `Manager` de sa ligne doit contenir l'**e-mail** du manager.
- **« Enregistrement SharePoint impossible »** : la personne n'a probablement pas le droit de modifier les listes (elle doit être membre du site).
- **« SharePoint refuse l'enregistrement… PODz Formations »** : le manager n'a pas le droit de modifier cette liste.
- **La page « Métiers POD » est vide** : remplir la liste `PODz Metiers`.
- **Le bouton « Installer » n'apparaît pas** : il faut le droit « Gérer les listes ».
- **Lecture du CV impossible** : utiliser « Coller le texte du CV ».
