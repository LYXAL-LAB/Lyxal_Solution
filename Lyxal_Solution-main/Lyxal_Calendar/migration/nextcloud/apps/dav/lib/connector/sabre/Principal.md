# Analyse du Fichier `Principal.php` de Nextcloud

## Description

`Principal` est un backend de gestion des principaux (utilisateurs, groupes, cercles, partages) pour SabreDAV. Il implémente `Sabre\DAVACL\PrincipalBackend\BackendInterface` et permet à WebDAV de comprendre qui sont les acteurs du système.

## Rôle et Responsabilités

### 1. Résolution des Principaux (`getPrincipalsByPrefix`, `getPrincipalByPath`)
-   Fournit une interface unifiée pour accéder à différents types d'entités Nextcloud via des URIs WebDAV :
    -   **Utilisateurs** : `principals/users/{userId}`.
    -   **Groupes** : `principals/groups/{groupId}`.
    -   **Cercles** : `principals/circles/{circleId}`.
    -   **Système** : `principals/system/{name}`.
    -   **Partages** : `principals/shares/{shareId}`.

### 2. Recherche (`searchPrincipals`)
-   Permet de rechercher des utilisateurs (`searchUserPrincipals`) par nom d'affichage ou email.
-   Respecte les configurations de confidentialité de Nextcloud (ex: autocomplétion restreinte aux membres du même groupe, masquage des emails, etc.).

### 3. Gestion des Groupes (`getGroupMembership`)
-   Retourne la liste des groupes auxquels appartient un principal (utilisateur).
-   Intègre les groupes Nextcloud standards et potentiellement d'autres sources via le trait `PrincipalProxyTrait`.

### 4. Conversion Entité <-> Principal
-   Transforme les objets Nextcloud (`IUser`, `IGroup`, `Circle`) en tableaux de propriétés WebDAV (`{DAV:}displayname`, `{http://sabredav.org/ns}email-address`, etc.).

## Dépendances Clés
-   `Sabre\DAVACL\PrincipalBackend\BackendInterface` : Interface SabreDAV.
-   `OCP\IUserManager`, `OCP\IGroupManager` : Gestion des utilisateurs/groupes.
-   `OCA\Circles\Api\v1\Circles` : Intégration avec l'app Circles.
