# Analyse du Fichier `MaintenancePlugin.php` de Nextcloud

## Description

`MaintenancePlugin` vérifie si le serveur Nextcloud est en mode maintenance ou nécessite une mise à jour, et bloque les requêtes WebDAV si c'est le cas.

## Rôle et Responsabilités

### 1. Vérification de l'État (`checkMaintenanceMode`)
-   S'exécute avant chaque méthode HTTP (`beforeMethod:*`).
-   Vérifie deux conditions :
    1.  Le mode maintenance est activé dans la configuration (`maintenance` => true).
    2.  Une mise à jour est nécessaire (`Util::needUpgrade()`).

### 2. Blocage
-   Si l'une des conditions est vraie, lance une exception `ServerMaintenanceMode` (qui se traduit généralement par une erreur 503 Service Unavailable).
-   Cela empêche les clients de synchronisation de modifier des données pendant une maintenance critique.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `OCP\IConfig` : Accès à la configuration.
