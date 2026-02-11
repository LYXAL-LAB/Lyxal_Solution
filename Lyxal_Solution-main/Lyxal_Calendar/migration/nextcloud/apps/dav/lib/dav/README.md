# Analyse du Répertoire `DAV` de Nextcloud

Ce répertoire contient les backends et plugins génériques WebDAV de Nextcloud.

---

## Fichiers Principaux

### `CustomPropertiesBackend.php`
-   **Fonction** : Stocke et récupère les propriétés WebDAV personnalisées
-   **Types de valeurs** : STRING, XML, OBJECT, HREF
-   **Cache** : Optimise les requêtes PROPFIND en préchargeant les propriétés
-   **Table** : `properties`

### `GroupPrincipalBackend.php`
-   **Fonction** : Backend de principaux pour les groupes
-   Expose les groupes comme principaux WebDAV

### `SystemPrincipalBackend.php`
-   **Fonction** : Backend de principaux système
-   Gère les principaux spéciaux (calendars-resources, calendars-rooms)

### `RemoteUserPrincipalBackend.php`
-   **Fonction** : Backend pour les utilisateurs distants (fédération)

### `PublicAuth.php`
-   **Fonction** : Authentification pour les accès publics génériques

### `ViewOnlyPlugin.php`
-   **Fonction** : Empêche le téléchargement de fichiers en partage "view-only"

---

## Sous-répertoire `Sharing/`

### `Backend.php`
-   Gestion du partage de calendriers/carnets d'adresses

### `Plugin.php`
-   Plugin Sabre pour les opérations de partage

### `SharingMapper.php`
-   Mapper DB pour les partages

### `SharingService.php`
-   Service de haut niveau pour le partage

### `IShareable.php`
-   Interface pour les objets partageables
