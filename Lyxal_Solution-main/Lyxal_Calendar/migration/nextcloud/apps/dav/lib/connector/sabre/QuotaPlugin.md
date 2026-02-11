# Analyse du Fichier `QuotaPlugin.php` de Nextcloud

## Description

`QuotaPlugin` est un plugin SabreDAV critique qui applique les quotas de stockage des utilisateurs lors des opérations WebDAV. Il empêche la création ou la modification de fichiers si l'espace disque alloué est dépassé.

## Rôle et Responsabilités

### 1. Vérification des Quotas (`checkQuota`)
-   S'active sur plusieurs événements : `beforeCreateFile`, `beforeWriteContent`, `onCreateCollection` (MKCOL), `beforeMove`, `beforeCopy`.
-   Calcule l'espace nécessaire pour l'opération (taille du fichier uploadé ou copié).
-   Compare avec l'espace libre disponible (`getFreeSpace`) sur le stockage cible.
-   Si l'espace est insuffisant, lance une exception `InsufficientStorage` (507).

### 2. Gestion des Uploads Chunkés
-   Pour les uploads par morceaux (chunked), il utilise l'en-tête `OC-Total-Length` pour vérifier le quota global du fichier final dès le début, plutôt que de vérifier chaque morceau individuellement.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `OC\Files\View` : Pour vérifier l'espace libre (`free_space`).
