# Analyse du Fichier `TagsPlugin.php` de Nextcloud

## Description

`TagsPlugin` permet de lire et modifier les tags et les favoris des fichiers via WebDAV.

## Rôle et Responsabilités

### 1. Gestion des Propriétés (`handleGetProperties`, `handleUpdateProperties`)
-   **Lecture** : Injecte les propriétés `{http://owncloud.org/ns}tags` et `{http://owncloud.org/ns}favorite` dans les réponses `PROPFIND`.
-   **Écriture** : Permet de modifier ces propriétés via `PROPPATCH`. Met à jour les tags via `TagManager` et gère l'ajout/suppression du tag spécial "Favori" (`_$!<Favorite>!$_`).

### 2. Optimisation (`preloadCollection`)
-   Précharge les tags pour tous les fichiers d'un dossier lors d'un listing, afin de réduire le nombre de requêtes SQL.

### 3. Favoris
-   Le concept de "Favori" est implémenté comme un tag système spécial, mais exposé comme une propriété booléenne distincte (`oc:favorite`) pour les clients WebDAV.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `OCP\ITagManager` : Gestionnaire de tags.
