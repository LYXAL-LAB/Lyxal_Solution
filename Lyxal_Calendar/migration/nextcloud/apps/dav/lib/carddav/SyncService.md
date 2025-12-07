# Analyse du Fichier `SyncService.php` de Nextcloud

## Description

`SyncService` est un service hybride qui gère deux types de synchronisation très différents :
1.  **Synchronisation Client CardDAV** : Permet à Nextcloud de se comporter comme un *client* CardDAV pour synchroniser des carnets distants (ex: importer des contacts depuis un autre serveur).
2.  **Synchronisation Système** : Maintient le "Carnet d'adresses système" à jour en reflétant les utilisateurs de l'instance Nextcloud sous forme de fiches contacts.

## Rôle et Responsabilités

### 1. Synchronisation Distante (`syncRemoteAddressBook`)
-   Agit comme un client CardDAV.
-   Effectue un `sync-collection` (RFC 6578) vers une URL distante.
-   Télécharge les VCards modifiées et les applique localement via `CardDavBackend` (Create/Update/Delete).
-   Gère les erreurs d'authentification (supprime le carnet si l'accès est révoqué).

### 2. Synchronisation Système (`syncInstance`, `updateUser`)
-   **But** : Créer automatiquement une fiche contact pour chaque utilisateur Nextcloud, afin qu'ils soient "découvrables" dans le carnet système.
-   **`syncInstance`** : Parcourt *tous* les utilisateurs et appelle `updateUser` pour chacun. Supprime ensuite les fiches orphelines (utilisateurs supprimés).
-   **`updateUser`** :
    -   Utilise `Converter` pour transformer l'objet `IUser` en VCard.
    -   Crée ou met à jour la carte dans le carnet système (`system` principal).
    -   Supprime la carte si l'utilisateur est désactivé.
-   **`ensureLocalSystemAddressBookExists`** : S'assure que le carnet spécial `system` existe bien en base.

## Dépendances Clés
-   `CardDavBackend` : Pour l'écriture en base.
-   `Converter` : Pour transformer `IUser` en VCard.
-   `IUserManager` : Pour lister les utilisateurs locaux.
-   `IClientService` : Pour effectuer les requêtes HTTP vers les serveurs distants.
