# Analyse du Fichier `UserAddressBooks.php` de Nextcloud

## Description

`UserAddressBooks` représente la collection "home" des carnets d'adresses pour un utilisateur donné (ex: `addressbooks/users/toto`). C'est le conteneur qui liste tous les carnets (personnels, partagés, système) accessibles par cet utilisateur.

## Rôle et Responsabilités

### 1. Agrégation des Carnets (`getChildren`)
-   Récupère les carnets personnels via `CardDavBackend->getAddressBooksForUser`.
-   **Injection du Carnet Système** : Si l'option `system_addressbook_exposed` est active, elle injecte artificiellement le `SystemAddressbook` dans la liste des carnets retournés.
-   **Plugins** : Récupère également les carnets fournis par d'autres plugins (`pluginManager->getAddressBookPlugins`), ce qui permet l'extensibilité (ex: carnet Deck, carnet Circles, etc.).

### 2. Instanciation des Objets
-   Pour chaque carnet trouvé (tableau de données), elle instancie la classe appropriée : `SystemAddressbook` ou `AddressBook`.

### 3. Création de Carnets (`createExtendedCollection`)
-   Gère la création de nouveaux carnets (via `MKCOL`).
-   Vérifie que le nom n'est pas réservé (`ExternalAddressBook::doesViolateReservedName`).

### 4. Permissions (`getACL`)
-   Si c'est la racine système (`principals/system/system`), elle accorde un droit de lecture `{DAV:}read` à tous les utilisateurs authentifiés `{DAV:}authenticated`.

## Dépendances Clés
-   `CardDavBackend` : Source principale des carnets.
-   `PluginManager` : Pour les sources de carnets tierces.
-   `SystemAddressbook` : La classe qu'elle instancie pour le carnet système.
