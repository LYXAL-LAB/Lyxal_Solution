# Analyse du Fichier `AddressBookImpl.php` de Nextcloud

## Description

`AddressBookImpl` est une implémentation spécifique à Nextcloud qui encapsule un `AddressBook` pour fournir des fonctionnalités de haut niveau, notamment pour l'intégration avec le reste du serveur (API interne). Elle implémente `IAddressBookEnabled` et `ICreateContactFromString`.

## Rôle et Responsabilités

### 1. Wrapper de `AddressBook`
-   Elle prend une instance de `AddressBook` (la classe SabreDAV) dans son constructeur et agit souvent comme un passe-plat ou un enrichisseur.

### 2. Recherche et Conversion (`search`)
-   **Recherche** : Utilise le `CardDavBackend` pour effectuer des recherches de contacts.
-   **Transformation** : Convertit les résultats bruts (VCards) en tableaux PHP structurés (`vCard2Array`) plus faciles à manipuler par le frontend ou d'autres apps.
-   **Gestion des Types** : Peut structurer les champs complexes (EMAIL, TEL) avec leurs types (HOME, WORK) si l'option `types` est activée.

### 3. Création/Mise à jour Simplifiée (`createOrUpdate`)
-   Fournit une méthode unifiée pour créer ou mettre à jour un contact à partir d'un simple tableau de propriétés, sans avoir à manipuler manuellement des objets VCard complexes.
-   Gère la génération automatique d'UID si nécessaire.
-   Gère la sérialisation en VCard avant de passer la main au backend.

### 4. Gestion des Permissions (`getPermissions`)
-   Traduit les ACLs complexes de WebDAV (ex: `{DAV:}write`) en constantes de permission Nextcloud simplifiées (`Constants::PERMISSION_READ`, `PERMISSION_UPDATE`, etc.).

### 5. Intégration Système
-   **`isSystemAddressBook`** : Identifie si c'est le carnet d'adresses système (celui qui contient tous les utilisateurs).
-   **`isEnabled`** : Vérifie si ce carnet est activé pour l'utilisateur courant (via `PropertyMapper`).

### 6. Utilitaires VCard
-   **`vCard2Array`** : Une méthode cruciale qui parse une VCard et la transforme en un tableau JSON-friendly, en gérant notamment les URLs des photos de profil.

## Dépendances Clés
-   `AddressBook` : L'objet SabreDAV sous-jacent.
-   `CardDavBackend` : Pour les recherches et écritures directes.
-   `IURLGenerator` : Pour générer les liens vers les photos de contacts.
