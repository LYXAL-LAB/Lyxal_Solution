# Analyse du Fichier `ContactsManager.php` de Nextcloud

## Description

`ContactsManager` est une classe de configuration qui fait le lien entre le module DAV et le gestionnaire de contacts global de Nextcloud (`OCP\Contacts\IManager`).

## Rôle et Responsabilités

### 1. Enregistrement des Carnets d'Adresses
-   **`setupContactsProvider`** : C'est la méthode principale appelée au démarrage. Elle récupère tous les carnets d'adresses de l'utilisateur via `CardDavBackend` et les enregistre auprès du `IManager`.
-   Cela permet aux autres applications Nextcloud (ex: Mail, Partage) d'accéder aux contacts de l'utilisateur pour l'autocomplétion.

### 2. Gestion du Carnet Système
-   **`setupSystemContactsProvider`** : Si l'option `system_addressbook_exposed` est activée, elle enregistre également le carnet d'adresses système (qui contient tous les utilisateurs de l'instance) comme une source de contacts disponible pour l'utilisateur.

### 3. Instanciation
-   Elle transforme les données brutes des carnets (tableaux) en objets `AddressBookImpl` (qui implémentent `IAddressBookEnabled`) avant de les passer au `IManager`.

## Dépendances Clés
-   `OCP\Contacts\IManager` : Le registre central des contacts de Nextcloud.
-   `CardDavBackend` : Pour récupérer la liste des carnets.
-   `AddressBookImpl` : La classe wrapper utilisée pour l'intégration.
