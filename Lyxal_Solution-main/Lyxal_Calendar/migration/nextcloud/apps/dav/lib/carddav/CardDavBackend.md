# Analyse du Fichier `CardDavBackend.php` de Nextcloud

## Description

`CardDavBackend` est la classe centrale pour la persistance des contacts dans Nextcloud. Elle implémente l'interface `BackendInterface` de SabreDAV, faisant le lien entre le protocole CardDAV et la base de données SQL de Nextcloud.

## Rôle et Responsabilités

### 1. Gestion des Carnets d'Adresses (AddressBooks)
-   **CRUD** : Création (`createAddressBook`), lecture (`getAddressBooksForUser`, `getAddressBookById`), mise à jour (`updateAddressBook`), et suppression (`deleteAddressBook`) des carnets.
-   **Partage** : Gère la récupération des carnets partagés (`getAddressBooksForUser` inclut les partages) et l'application des permissions.

### 2. Gestion des Contacts (Cards)
-   **CRUD** : Création (`createCard`), lecture (`getCard`, `getCards`), mise à jour (`updateCard`), et suppression (`deleteCard`) des fiches contacts (VCards).
-   **Stockage** : Les données VCard brutes sont stockées dans la colonne `carddata` (BLOB).
-   **Métadonnées** : Gère les propriétés essentielles comme `etag` (pour le cache), `lastmodified`, `size`, et `uid`.

### 3. Indexation des Propriétés (`cards_properties`)
-   **Optimisation** : Pour éviter de parser les BLOBs VCard à chaque recherche, la classe extrait et indexe des propriétés clés dans une table dédiée (`cards_properties`).
-   **Propriétés Indexées** : `FN`, `EMAIL`, `TEL`, `ORG`, `CATEGORIES`, `BDAY`, etc. (voir `indexProperties`).
-   **Mise à jour** : À chaque création ou modification de carte (`updateProperties`), l'index est régénéré pour cette carte.

### 4. Synchronisation (`SyncSupport`)
-   **`getChangesForAddressBook`** : Implémente le mécanisme de "Sync-Token" (RFC 6578). Cela permet aux clients (téléphones, Thunderbird) de ne demander que les changements (ajouts, modifs, suppressions) survenus depuis leur dernière connexion, au lieu de tout retélécharger.
-   **Historique** : Les changements sont traqués dans la table `addressbookchanges`.

### 5. Recherche
-   **`search`** : Effectue des recherches rapides en utilisant la table d'index (`cards_properties`). Supporte les jokers et les filtres complexes.

### 6. Gestion des Transactions
-   Utilise le trait `TTransactional` pour garantir que les opérations touchant plusieurs tables (ex: supprimer un carnet + ses contacts + ses propriétés + ses partages) sont atomiques.

## Points Techniques Notables

-   **`readBlob`** : Une méthode d'optimisation qui peut filtrer les données binaires (photos) des VCards pour économiser de la mémoire si nécessaire, bien que le code actuel semble surtout gérer la lecture de flux.
-   **`etagCache`** : Un cache en mémoire pour éviter des écritures inutiles si le contenu d'une carte n'a pas changé.
-   **Événements** : Dispatch de nombreux événements (`AddressBookCreatedEvent`, `CardUpdatedEvent`, etc.) pour permettre à d'autres apps de réagir.

## Dépendances Clés

-   `OCP\IDBConnection` : Accès base de données.
-   `OCA\DAV\DAV\Sharing\Backend` : Gestion de la logique de partage.
-   `Sabre\VObject\Reader` : Parsing des données VCard.
