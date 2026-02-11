# Analyse du Fichier `CopyEtagHeaderPlugin.php` de Nextcloud

## Description

`CopyEtagHeaderPlugin` est un workaround technique. Il duplique l'en-tête standard `ETag` vers un en-tête personnalisé `OC-ETag`.

## Rôle et Responsabilités

### 1. Duplication d'ETag (`afterMethod`)
-   Après chaque requête, il vérifie si un header `ETag` est présent dans la réponse.
-   Si oui, il ajoute `OC-ETag` avec la même valeur.
-   **Raison** : Certains proxy, pare-feux ou serveurs web (comme Apache avec mod_deflate ou IIS) peuvent supprimer ou modifier l'ETag standard (ex: ajouter `-gzip`). `OC-ETag` garantit que le client Nextcloud reçoit toujours l'ETag original et correct pour la synchronisation.

### 2. Gestion du Déplacement (`afterMove`)
-   Lorsqu'un fichier est déplacé, il s'assure que le nouvel ETag est bien renvoyé dans les en-têtes.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
