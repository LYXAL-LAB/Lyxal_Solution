# Analyse de `OCA\DAV\CalDAV\Trashbin\DeletedCalendarObjectsCollection`

## Description

`DeletedCalendarObjectsCollection` est une classe qui représente un "dossier" virtuel dans l'arborescence DAV. Ce dossier, typiquement nommé `objects`, a pour unique but de contenir et d'exposer tous les objets calendrier (événements, tâches) qui ont été supprimés par un utilisateur spécifique.

## Rôle et Responsabilités

1.  **Implémentation d'Interfaces Clés** :
    *   `Sabre\CalDAV\ICalendarObjectContainer`: Signale au serveur SabreDAV que cette collection est un conteneur pour des objets de type `ICalendarObject`. Cela lui permet de répondre à des requêtes spécifiques à CalDAV comme `calendar-query`.
    *   `Sabre\DAVACL\IACL`: Permet de définir une liste de contrôle d'accès (ACL) personnalisée pour le dossier lui-même.

2.  **Comportement de Conteneur en Lecture Seule** :
    *   Ce dossier est une vue en lecture seule sur la corbeille. Il est impossible de modifier sa structure.
    *   Toutes les opérations d'écriture sont explicitement interdites en levant une `Sabre\DAV\Exception\Forbidden`. Cela inclut :
        *   `createFile()`: Impossible d'ajouter un nouvel objet directement dans la corbeille.
        *   `createDirectory()`: Impossible de créer des sous-dossiers.
        *   `delete()`: Impossible de supprimer le dossier `objects` lui-même.
        *   `setName()`: Impossible de le renommer.

3.  **Listage et Recherche d'Objets (`calendarQuery`)** :
    *   C'est la méthode principale pour obtenir le contenu du dossier. Elle est utilisée par les clients CalDAV pour lister les objets.
    *   Elle délègue entièrement le travail au `CalDavBackend` en appelant `getDeletedCalendarObjectsByPrincipal()`, qui retourne un tableau de toutes les entrées de base de données pour les objets supprimés de l'utilisateur.
    *   Elle formate ensuite les résultats en une liste de noms de fichiers relatifs, en utilisant l'ID de l'objet (par exemple, un objet avec `id=123` devient `123.ics`).
    *   Notamment, la méthode `getChildren()` lève une `NotImplemented`, ce qui est une optimisation. Cela force les clients à utiliser la méthode `calendarQuery` qui est plus efficace et permet de filtrer les résultats côté serveur, plutôt que de lister tous les enfants inconditionnellement.

4.  **Récupération d'un Objet Spécifique (`getChild`)** :
    *   Cette méthode est appelée lorsqu'un client demande un objet spécifique par son nom (ex: `GET /.../trashbin/objects/123.ics`).
    *   Elle parse le nom du fichier pour extraire l'ID numérique.
    *   Elle utilise cet ID pour demander l'objet au backend via `caldavBackend->getCalendarObjectById()`.
    *   Elle effectue une vérification de sécurité cruciale : elle s'assure que l'objet retourné est bien marqué comme supprimé (`deleted_at` n'est pas nul).
    *   Si tout est correct, elle instancie et retourne un nouvel objet `DeletedCalendarObject` qui représente l'élément supprimé.

5.  **Permissions (`getACL`)** :
    *   Les permissions sur le dossier sont simples et restrictives :
        *   `{DAV:}read`: Le propriétaire peut lire le contenu du dossier (lister les fichiers).
        *   `{DAV:}unbind`: Le propriétaire a le droit de "délier" un enfant, ce qui est le privilège requis pour effectuer une opération `MOVE` (utilisée pour la restauration).

## Dépendances

-   `OCA\DAV\CalDAV\CalDavBackend`: Le backend est la source de vérité pour toutes les données. La collection ne fait que demander des informations au backend.

En résumé, `DeletedCalendarObjectsCollection` agit comme une façade DAV pour la corbeille d'un utilisateur. Elle expose une collection d'objets en lecture seule, traduit les requêtes DAV en appels au backend de données, et instancie les objets `DeletedCalendarObject` à la demande, tout en appliquant des permissions strictes.
