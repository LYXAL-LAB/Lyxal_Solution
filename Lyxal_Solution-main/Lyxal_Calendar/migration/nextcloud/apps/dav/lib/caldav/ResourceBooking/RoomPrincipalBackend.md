# Analyse de `OCA\DAV\CalDAV\ResourceBooking\RoomPrincipalBackend`

## Description

La classe `RoomPrincipalBackend` est une implémentation concrète de `AbstractPrincipalBackend`. Son unique rôle est de configurer et d'instancier un backend de "principal" spécifiquement pour la gestion des **salles** réservables.

## Rôle et Responsabilités

Cette classe est structurellement identique à `ResourcePrincipalBackend` et n'ajoute aucune nouvelle logique métier. Sa seule responsabilité est d'appeler le constructeur de sa classe parente (`AbstractPrincipalBackend`) avec les valeurs spécifiques aux salles :

1.  **`principalPrefix`**: La valeur `'principals/calendar-rooms'` est fournie. Ce backend gérera donc toutes les requêtes DAV pour les URI commençant par ce chemin, qui est le point d'entrée virtuel pour toutes les salles.

2.  **`dbPrefix`**: La valeur `'room'` est fournie. Cela configure le backend pour interagir avec les tables de base de données suivantes :
    *   Table principale : `oc_calendar_rooms`
    *   Table des métadonnées : `oc_calendar_rooms_md`

3.  **`cuType`**: La valeur `'ROOM'` est fournie. Cette valeur sera utilisée pour la propriété CalDAV `{urn:ietf:params:xml:ns:caldav}calendar-user-type`, permettant aux clients CalDAV de reconnaître ce principal comme étant une salle.

## Héritage et Dépendances

-   **Hérite de** : `OCA\DAV\CalDAV\ResourceBooking\AbstractPrincipalBackend`. Elle bénéficie de toute la logique de recherche, de récupération et de gestion des permissions définie dans la classe parente.
-   **Dépendances** : Elle accepte les mêmes dépendances que son parent (`IDBConnection`, `IUserSession`, `IGroupManager`, `LoggerInterface`, `ProxyMapper`) et les transmet directement au constructeur de la classe de base.

En résumé, `RoomPrincipalBackend` est une classe de configuration qui spécialise la classe abstraite générique `AbstractPrincipalBackend` pour créer un service dédié à la gestion des principals de type "salle".
