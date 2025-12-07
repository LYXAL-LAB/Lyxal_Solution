# Analyse du Fichier `FakeLockerPlugin.php` de Nextcloud

## Description

`FakeLockerPlugin` simule le support du verrouillage de fichiers (WebDAV Class 2 Locking) pour satisfaire les clients macOS Finder.

## Rôle et Responsabilités

### 1. Simulation de LOCK/UNLOCK
-   macOS Finder refuse parfois d'écrire sur un partage WebDAV s'il ne supporte pas le verrouillage.
-   Ce plugin intercepte les méthodes `LOCK` et `UNLOCK`.
-   Il retourne toujours une réponse positive (`200 OK` ou `204 No Content`) avec un token de verrouillage factice, sans réellement verrouiller quoi que ce soit côté serveur (le verrouillage réel est géré par le système de fichiers de Nextcloud, pas par WebDAV).

### 2. Propriétés de Verrouillage (`propFind`)
-   Injecte les propriétés `{DAV:}supportedlock` et `{DAV:}lockdiscovery` dans les réponses `PROPFIND` pour annoncer le support (fictif) du verrouillage.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
