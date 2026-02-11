# Analyse du Fichier `ZipFolderPlugin.php` de Nextcloud

## Description

`ZipFolderPlugin` permet de télécharger un dossier entier sous forme d'archive (ZIP ou TAR) via une simple requête `GET`. C'est une fonctionnalité non standard de WebDAV (qui ne supporte normalement pas le GET sur les collections) mais très utile pour l'interface web et les liens publics.

## Rôle et Responsabilités

### 1. Interception du GET (`handleDownload`)
-   Écoute les requêtes `GET` sur les dossiers (`Directory`).
-   Vérifie si le client accepte le ZIP ou le TAR (via l'en-tête `Accept` ou le paramètre `accept`).

### 2. Filtrage (`X-NC-Files`)
-   Permet de ne télécharger qu'une sous-partie du dossier en spécifiant une liste de fichiers via l'en-tête `X-NC-Files` ou le paramètre `files`.
-   Vérifie les permissions via l'événement `BeforeZipCreatedEvent`.

### 3. Streaming (`streamNode`)
-   Génère l'archive à la volée (streaming) sans créer de fichier temporaire géant sur le serveur.
-   Utilise `OC\Streamer` pour écrire directement dans la réponse HTTP.
-   Parcourt récursivement le dossier pour ajouter les fichiers et sous-dossiers.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `OC\Streamer` : Utilitaire de streaming d'archive.
