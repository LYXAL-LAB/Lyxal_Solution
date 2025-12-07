# Analyse du Fichier `DavAclPlugin.php` de Nextcloud

## Description

`DavAclPlugin` est un wrapper autour du plugin ACL standard de SabreDAV (`Sabre\DAVACL\Plugin`). Sa principale modification est de retourner une erreur **404 Not Found** au lieu de **403 Forbidden** lorsqu'une ressource est inaccessible.

## Rôle et Responsabilités

### 1. Masquage des Ressources (`checkPrivileges`)
-   Si l'accès à une ressource est refusé (`checkPrivileges` retourne false), le plugin intercepte l'exception.
-   Si l'utilisateur n'est pas le propriétaire de la ressource, il lance une `NotFound` (404) au lieu d'une `Forbidden` (403).
-   **Sécurité** : Cela empêche l'énumération des ressources. Un attaquant ne peut pas savoir si un fichier existe ou non s'il n'a pas les droits dessus.

### 2. Optimisation (`beforeMethod`, `propFind`)
-   Désactive les vérifications ACL coûteuses pour les fichiers standards (`files/`), car le système de fichiers de Nextcloud gère déjà ses propres permissions.
-   Se concentre sur les ressources purement DAV comme les calendriers (`calendars/`) et les carnets d'adresses (`addressbooks/`).

## Dépendances Clés
-   `Sabre\DAVACL\Plugin` : Classe parente.
-   `Sabre\DAV\Exception\NotFound` : Exception levée pour masquer l'existence.
