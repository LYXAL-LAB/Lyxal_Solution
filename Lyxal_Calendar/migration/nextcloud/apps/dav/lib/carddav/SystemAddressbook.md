# Analyse du Fichier `SystemAddressbook.php` de Nextcloud

## Description

`SystemAddressbook` est une spécialisation de `AddressBook` qui représente le "Carnet d'adresses système". Ce carnet est virtuel ou semi-virtuel : il expose tous les utilisateurs de l'instance Nextcloud comme des contacts, permettant ainsi l'autocomplétion globale.

## Rôle et Responsabilités

### 1. Visibilité et Filtrage (`getChildren`, `getMultipleChildren`)
-   C'est la responsabilité majeure de cette classe : déterminer **qui peut voir qui**.
-   Elle respecte les configurations de partage de Nextcloud (`shareapi_...`) :
    -   `shareapi_allow_share_dialog_user_enumeration` : Si désactivé, l'utilisateur ne voit que lui-même.
    -   `shareapi_restrict_user_enumeration_to_group` : Si activé, l'utilisateur ne voit que les membres de ses propres groupes.
    -   `shareapi_restrict_user_enumeration_to_phone` : Restriction basée sur le numéro de téléphone (moins courant).
-   Elle filtre dynamiquement les contacts retournés en fonction de ces règles.

### 2. Gestion des Invités (Guests)
-   Elle exclut explicitement les utilisateurs de type "Guests" (`Guests:`) de la liste globale, sauf si l'utilisateur courant est lui-même un invité (logique complexe de visibilité).

### 3. Fédération
-   Si la requête provient d'un serveur fédéré de confiance (`isFederation`), elle permet l'accès aux cartes.
-   **Nettoyage des Données** (`extractCarddata`) : Pour les partages fédérés, elle nettoie les propriétés VCard qui sont marquées comme `SCOPE_LOCAL` (données internes qui ne doivent pas fuiter vers d'autres serveurs).

### 4. Permissions (`getACL`, `delete`)
-   Le carnet système est globalement en **lecture seule** pour les utilisateurs normaux.
-   La méthode `delete()` est désactivée (sauf contexte fédéré spécifique), on ne peut pas supprimer le carnet système.
-   Les ACLs sont filtrées pour retirer tout droit d'écriture (`{DAV:}write`).

## Dépendances Clés
-   `IUserSession` : Pour connaître l'utilisateur courant et appliquer les filtres.
-   `IGroupManager` : Pour résoudre les membres des groupes si la restriction par groupe est active.
-   `TrustedServers` : Pour l'authentification fédérée.
