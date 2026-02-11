# Analyse du Fichier `TagList.php` de Nextcloud

## Description

`TagList` est une classe de propriété WebDAV qui gère une liste de tags (étiquettes) associés à un fichier.

## Rôle et Responsabilités

### 1. Transport de Données
-   Contient un tableau de chaînes de caractères (les noms des tags).

### 2. Sérialisation XML (`xmlSerialize`)
-   Convertit la liste en éléments `<oc:tag>` dans l'espace de noms `http://owncloud.org/ns`.
-   Utilisé pour la propriété `{http://owncloud.org/ns}tags`.

### 3. Désérialisation XML (`xmlDeserialize`)
-   Permet de lire une liste de tags envoyée par le client (par exemple lors d'une mise à jour via `PROPPATCH`).

## Dépendances Clés
-   `Sabre\Xml\Element` : Interface SabreDAV.
