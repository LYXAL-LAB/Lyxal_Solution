# Analyse du Fichier `HasPhotoPlugin.php` de Nextcloud

## Description

`HasPhotoPlugin` est un plugin SabreDAV qui ajoute une propriété calculée personnalisée `has-photo` aux fiches contacts (Cards). Cela permet aux clients de savoir rapidement si un contact possède une photo sans avoir à télécharger la VCard complète.

## Rôle et Responsabilités

### 1. Extension de `propFind`
-   S'abonne à l'événement `propFind` du serveur SabreDAV.
-   Définit une nouvelle propriété : `{http://nextcloud.com/ns}has-photo`.

### 2. Calcul de la Propriété
-   Lorsque la propriété est demandée pour un nœud de type `Card` :
    1.  Elle parse le contenu de la VCard (`Reader::read`).
    2.  Elle vérifie si la propriété `PHOTO` existe.
    3.  Elle effectue une validation supplémentaire pour s'assurer que c'est bien une image (soit une URL, soit un mimetype commençant par `image/`).
-   Retourne `true` ou `false`.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base pour les plugins SabreDAV.
-   `Sabre\VObject\Reader` : Pour parser la VCard.
