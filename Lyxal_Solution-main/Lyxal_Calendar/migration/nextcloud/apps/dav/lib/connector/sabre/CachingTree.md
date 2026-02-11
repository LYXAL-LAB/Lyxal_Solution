# Analyse du Fichier `CachingTree.php` de Nextcloud

## Description

`CachingTree` est une extension de la classe `Sabre\DAV\Tree`. Elle ajoute une couche de cache simple pour les nœuds DAV afin d'éviter de les recharger inutilement depuis le backend lors d'une même requête.

## Rôle et Responsabilités

### 1. Mise en Cache des Nœuds (`cacheNode`)
-   Stocke les objets `Node` (Fichiers, Dossiers) dans un tableau associatif interne `$cache`, indexé par leur chemin.

### 2. Invalidation du Cache (`markDirty`)
-   Permet d'invalider le cache pour un chemin donné et tous ses enfants.
-   Utilisé lorsqu'une opération d'écriture (création, modification, suppression) a lieu, pour s'assurer que les lectures suivantes retournent des données fraîches.

## Dépendances Clés
-   `Sabre\DAV\Tree` : Classe parente.
