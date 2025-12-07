# Analyse du Fichier `ImageExportPlugin.php` de Nextcloud

## Description

`ImageExportPlugin` est un plugin SabreDAV qui permet de télécharger directement la photo d'un contact via une URL HTTP GET spécifique, sans avoir à parser la VCard côté client.

## Rôle et Responsabilités

### 1. Interception HTTP GET
-   S'abonne à l'événement `method:GET` du serveur.
-   Détecte si l'URL se termine par le paramètre `?photo` (ex: `/dav/addressbooks/user/contacts/contact.vcf?photo`).

### 2. Extraction et Cache
-   Si la requête correspond, elle utilise `PhotoCache` pour récupérer l'image du contact.
-   Supporte un paramètre `size` pour demander une taille spécifique (redimensionnement).
-   Gère les en-têtes HTTP de cache (`Cache-Control`, `Etag`) et de téléchargement (`Content-Disposition`, `Content-Type`).

### 3. Sécurité
-   Vérifie les permissions ACL (`{DAV:}read`) avant de servir l'image.

## Dépendances Clés
-   `PhotoCache` : Le service qui extrait, redimensionne et met en cache les photos des VCards.
-   `Sabre\DAV\ServerPlugin` : Classe de base.
