# Analyse du Fichier `PropFindPreloadNotifyPlugin.php` de Nextcloud

## Description

`PropFindPreloadNotifyPlugin` est un mécanisme d'optimisation qui signale aux autres plugins qu'une collection va être parcourue, leur permettant de précharger des données en masse.

## Rôle et Responsabilités

### 1. Notification de Préchargement (`collectionPreloadNotifier`)
-   Intercepte les requêtes `PROPFIND`.
-   Si la requête cible une collection (`ICollection`) avec une profondeur > 0 (`DEPTH_INFINITY` ou `1`), cela signifie que les enfants vont être listés.
-   Émet alors un événement interne `preloadCollection` avec le nœud et l'objet `PropFind`.

### 2. Utilité
-   D'autres plugins (comme `CommentPropertiesPlugin` ou `TagsPlugin`) peuvent écouter cet événement pour charger toutes les métadonnées nécessaires (commentaires, tags) pour tous les fichiers du dossier en une seule requête SQL, au lieu d'une requête par fichier.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
