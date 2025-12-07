# Analyse du Fichier `ChecksumUpdatePlugin.php` de Nextcloud

## Description

`ChecksumUpdatePlugin` permet aux clients de mettre à jour explicitement le checksum d'un fichier via une requête HTTP `PATCH`, sans avoir à ré-uploader tout le contenu.

## Rôle et Responsabilités

### 1. Gestion du PATCH (`httpPatch`)
-   Écoute les requêtes `PATCH`.
-   Vérifie la présence de l'en-tête `X-Recalculate-Hash` (ex: "MD5", "SHA1", "SHA256").
-   Si le nœud ciblé est un `File`, il demande au nœud de recalculer son hash (`$node->hash($type)`).
-   Met à jour le checksum du nœud (`setChecksum`) et retourne le nouveau hash dans l'en-tête `OC-Checksum`.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `OCA\DAV\Connector\Sabre\File` : Le type de nœud attendu.
