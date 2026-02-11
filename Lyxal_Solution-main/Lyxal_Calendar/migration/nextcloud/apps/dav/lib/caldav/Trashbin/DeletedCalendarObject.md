# Analyse de `OCA\DAV\CalDAV\Trashbin\DeletedCalendarObject`

## Description

La classe `DeletedCalendarObject` est une représentation DAV d'un objet calendrier (un événement, une tâche, etc.) qui a été placé dans la corbeille. Elle agit comme un "wrapper" autour des données de l'objet supprimé, lui permettant d'exister au sein de l'arborescence de la corbeille DAV avec un comportement et des permissions spécifiques.

## Rôle et Responsabilités

1.  **Implémentation d'Interfaces Multiples** :
    *   `Sabre\CalDAV\ICalendarObject`: Permet à l'objet d'être reconnu et traité comme un objet calendrier standard par le serveur SabreDAV, répondant aux méthodes de base comme `getName`, `get`, `getSize`, `getETag`, etc.
    *   `Sabre\DAVACL\IACL`: Permet de définir une liste de contrôle d'accès (ACL) personnalisée et restreinte pour l'objet.
    *   `OCA\DAV\CalDAV\IRestorable`: Une interface personnalisée de Nextcloud qui signale que l'objet a une capacité de restauration et doit implémenter une méthode `restore()`.

2.  **Comportement en Lecture Seule** :
    *   Une fois dans la corbeille, un objet calendrier ne peut pas être modifié.
    *   Les méthodes `setName($name)` et `put($data)` sont implémentées pour lever systématiquement une `Sabre\DAV\Exception\Forbidden`, empêchant ainsi toute tentative de renommage ou de mise à jour du contenu.

3.  **Gestion du Cycle de Vie dans la Corbeille** :
    *   **`delete()`**: Cette méthode déclenche la **suppression définitive** de l'objet. Elle appelle `calDavBackend->deleteCalendarObject()` avec le dernier argument à `true`, ce qui indique au backend d'effectuer une suppression physique ("hard delete") de la base de données.
    *   **`restore()`**: Cette méthode, requise par l'interface `IRestorable`, délègue la logique de restauration au `CalDavBackend` en appelant `calDavBackend->restoreCalendarObject()`. Le backend se charge de marquer l'objet comme n'étant plus supprimé.

4.  **Permissions Restreintes (`getACL`)** :
    *   L'objet dans la corbeille a des permissions limitées. Le propriétaire (`owner`) a uniquement les privilèges suivants :
        *   `{DAV:}read`: Permet de lire le contenu et les propriétés de l'objet, nécessaire pour l'afficher dans l'interface de la corbeille.
        *   `{DAV:}unbind`: Permet de "délier" l'objet de son parent, ce qui correspond aux actions de suppression définitive (un `DELETE` HTTP) ou de restauration (un `MOVE` HTTP).

5.  **Exposition des Données** :
    *   La classe stocke les données brutes de l'objet supprimé (y compris son contenu iCalendar) dans la propriété privée `$objectData`.
    *   Les méthodes `get()`, `getSize()`, `getETag()`, `getContentType()` servent à exposer ces données au serveur SabreDAV.
    *   Elle expose également des métadonnées spécifiques à la corbeille, comme la date de suppression (`getDeletedAt()`) et l'URI du calendrier d'origine (`getCalendarUri()`).

## Dépendances

-   `OCA\DAV\CalDAV\CalDavBackend`: Le service backend est essentiel pour effectuer les opérations de suppression définitive et de restauration.

En résumé, `DeletedCalendarObject` est une classe qui donne vie aux objets calendrier supprimés au sein de la corbeille DAV. Elle les présente comme des nœuds DAV quasi-standards mais avec un comportement verrouillé (lecture seule) et des actions spécifiques (restaurer, supprimer définitivement), assurant une intégration propre et sécurisée de la fonctionnalité de corbeille dans le protocole CalDAV.
