# Analyse de `OCA\DAV\CalDAV\ResourceBooking\AbstractPrincipalBackend`

## Description

`AbstractPrincipalBackend` est une classe abstraite qui implémente l'interface `Sabre\DAVACL\PrincipalBackend\BackendInterface`. Elle fournit une base de logique commune pour gérer des "principals" qui représentent des ressources réservables, comme des salles ou des véhicules. Elle est conçue pour être étendue par des classes concrètes (par exemple, `RoomPrincipalBackend` et `ResourcePrincipalBackend`) qui spécifieront les détails comme les préfixes d'URI et les noms de tables de base de données.

Cette classe est responsable de l'interaction avec la base de données pour lister, récupérer et rechercher des ressources en tant que principals DAV.

## Rôle et Responsabilités

1.  **Interaction avec la Base de Données** :
    *   La classe est conçue pour fonctionner avec deux tables de base de données : une table principale pour les ressources (ex: `calendar_rooms`) et une table de métadonnées associée (ex: `calendar_rooms_md`). Les noms de ces tables sont construits dynamiquement dans le constructeur à partir d'un préfixe (`$dbPrefix`).
    *   Elle utilise le Query Builder de Nextcloud (`OCP\IDBConnection`) pour toutes les opérations de base de données.

2.  **Implémentation de `BackendInterface`** :
    *   **`getPrincipalsByPrefix($prefixPath)`**: Retourne une liste de toutes les ressources (principals) correspondant à un préfixe donné (ex: `principals/rooms`). Elle récupère efficacement toutes les ressources et leurs métadonnées en deux requêtes pour les assembler en mémoire.
    *   **`getPrincipalByPath($path)`**: Récupère les informations d'une ressource unique en se basant sur son URI complet (ex: `principals/rooms/local-1`).
    *   **`getPrincipalById($id)`**: Récupère une ressource par son identifiant numérique unique en base de données.
    *   **`searchPrincipals($prefixPath, array $searchProperties, $test)`**: Implémente une logique de recherche puissante. Elle permet de rechercher des ressources par :
        *   Nom d'affichage (`{DAV:}displayname`).
        *   Adresse e-mail (`{http://sabredav.org/ns}email-address`).
        *   Adresse de calendrier (`{urn:ietf:params:xml:ns:caldav}calendar-user-address-set`).
        *   Métadonnées personnalisées (ex: capacité, caractéristiques d'une salle, localisation). Elle gère des recherches spécifiques pour la capacité (`>=`) et les caractéristiques (`LIKE %feature%`).
    *   **`updatePrincipal($path, PropPatch $propPatch)`**: Cette méthode est présente pour satisfaire l'interface mais ne contient aucune logique de mise à jour (elle retourne simplement 0). La modification des ressources n'est pas gérée via ce backend.

3.  **Gestion des Permissions** :
    *   La méthode `isAllowedToAccessResource(array $row, array $userGroups)` est au cœur de la sécurité.
    *   Elle vérifie si une ressource a des restrictions d'accès basées sur des groupes d'utilisateurs. Ces restrictions sont stockées dans un champ `group_restrictions` sous forme de tableau JSON.
    *   Si l'utilisateur connecté appartient à au moins un des groupes autorisés, l'accès est accordé. Si aucune restriction n'est définie, la ressource est considérée comme accessible par tous.
    *   Cette vérification est appliquée systématiquement lors des recherches (`searchPrincipals`) et des récupérations par URI (`findByUri`).

4.  **Formatage des Données** :
    *   La méthode privée `rowToPrincipal(array $row, array $metadata = [])` est une fonction utilitaire centrale.
    *   Elle transforme une ligne de la base de données en un tableau structuré représentant un principal DAV, incluant son URI, son nom d'affichage, son email, son type d'utilisateur de calendrier (`calendar-user-type`), et fusionne toutes les métadonnées associées.

## Trait Utilisé

-   `OCA\DAV\Traits\PrincipalProxyTrait`: Ce trait est inclus mais ses méthodes ne semblent pas être directement utilisées dans la classe abstraite elle-même. Elles sont probablement utilisées par les classes qui étendent `AbstractPrincipalBackend`.

## Dépendances

-   `OCP\IDBConnection`: Pour l'accès à la base de données.
-   `OCP\IUserSession`: Pour obtenir l'utilisateur actuellement connecté et vérifier ses permissions.
-   `OCP\IGroupManager`: Pour récupérer les groupes auxquels l'utilisateur appartient.
-   `Psr\Log\LoggerInterface`: Pour la journalisation des erreurs.
-   `OCA\DAV\CalDAV\Proxy\ProxyMapper`: Injectée mais pas directement utilisée dans cette classe abstraite. Probablement utilisée en conjonction avec le `PrincipalProxyTrait` dans les sous-classes.

En résumé, `AbstractPrincipalBackend` est un socle robuste et sécurisé pour exposer des ressources de calendrier (salles, véhicules, etc.) en tant que principals interrogeables via le protocole DAV. Elle centralise la logique d'accès aux données et la gestion des permissions, laissant aux classes enfants le soin de spécifier les configurations spécifiques à chaque type de ressource.
