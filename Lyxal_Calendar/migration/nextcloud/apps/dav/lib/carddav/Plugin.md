# Analyse du Fichier `Plugin.php` de Nextcloud

## Description

`Plugin` est l'extension principale CardDAV pour Nextcloud. Elle hérite de `\Sabre\CardDAV\Plugin` et l'étend pour ajouter des fonctionnalités spécifiques à Nextcloud, notamment la gestion des groupes de contacts et la résolution des chemins "home".

## Rôle et Responsabilités

### 1. Initialisation
-   S'enregistre auprès du serveur SabreDAV.
-   S'abonne à l'événement `propFind` pour injecter des propriétés personnalisées.

### 2. Résolution des Chemins (`getAddressbookHomeForPrincipal`)
-   Définit où se trouvent les carnets d'adresses pour différents types de principaux (utilisateurs, groupes, système).
-   Structure standard : `addressbooks/users/ID`, `addressbooks/groups/ID`, `addressbooks/system/ID`.

### 3. Propriétés Personnalisées (`propFind`)
-   Injecte la propriété `{http://owncloud.org/ns}groups` sur les nœuds `AddressBook`.
-   Cela permet de retourner la liste des groupes de contacts (catégories) disponibles dans un carnet via une requête WebDAV `PROPFIND`.

## Dépendances Clés
-   `Sabre\CardDAV\Plugin` : Classe parente standard.
-   `OCA\DAV\CardDAV\Xml\Groups` : Classe XML pour sérialiser la liste des groupes.
