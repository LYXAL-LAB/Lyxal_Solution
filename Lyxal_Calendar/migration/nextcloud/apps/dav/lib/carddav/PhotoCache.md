# Analyse du Fichier `PhotoCache.php` de Nextcloud

## Description

`PhotoCache` est un service qui gère la mise en cache des photos de contacts extraites des VCards. L'extraction d'une photo depuis une VCard (souvent encodée en Base64) est coûteuse en CPU et mémoire ; ce cache permet de servir les images rapidement (notamment pour `ImageExportPlugin`).

## Rôle et Responsabilités

### 1. Stockage (`IAppData`)
-   Utilise le dossier `dav-photocache` dans le dossier de données de l'application (`AppData`).
-   Organise le cache par dossiers hashés (`md5($addressBookId . ' ' . $cardUri)`).

### 2. Extraction et Décodage (`getPhoto`)
-   Lit la VCard brute.
-   Extrait la propriété `PHOTO`.
-   Gère les URIs de données (`data:image/...`) et les données binaires.
-   Détecte le type MIME (JPEG, PNG, etc.).

### 3. Mise en Cache (`init`)
-   Si le cache est vide pour un contact, il extrait la photo et la sauvegarde dans un fichier `photo.ext`.
-   Si le contact n'a pas de photo, il crée un fichier marqueur `nophoto` pour éviter de réessayer inutilement.

### 4. Redimensionnement (`getFile`)
-   Supporte la demande d'une taille spécifique (ex: avatar 64x64).
-   Utilise `OCP\Image` pour redimensionner l'image originale mise en cache.
-   Cache également les versions redimensionnées (`photo.SIZE.ext`).
-   Arrondit la taille demandée à la puissance de 2 supérieure pour limiter le nombre de variantes en cache.

### 5. Nettoyage (`delete`)
-   Permet de supprimer le cache d'un contact (appelé lors de la modification/suppression d'une fiche).

## Dépendances Clés
-   `IAppDataFactory` : Pour accéder au stockage de cache.
-   `Sabre\VObject\Reader` : Pour lire les VCards.
-   `OCP\Image` : Pour le traitement d'image.
