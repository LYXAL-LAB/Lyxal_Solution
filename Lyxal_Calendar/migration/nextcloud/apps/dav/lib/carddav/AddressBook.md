# Analyse du Fichier `AddressBook.php` de Nextcloud

## Description

La classe `AddressBook` est la représentation concrète d'un carnet d'adresses utilisateur dans l'architecture SabreDAV de Nextcloud. Elle agit comme une couche d'abstraction (façade) entre le protocole CardDAV et le stockage réel en base de données géré par `CardDavBackend`.

## Rôle et Responsabilités

Elle hérite de `\Sabre\CardDAV\AddressBook` et implémente plusieurs interfaces clés pour s'intégrer dans l'écosystème Nextcloud :
-   **`IShareable`** : Permet le partage du carnet d'adresses avec d'autres utilisateurs ou groupes.
-   **`IMoveTarget`** : Permet de recevoir des contacts déplacés depuis d'autres carnets.

### Fonctionnalités Principales

1.  **Adaptation du Nom d'Affichage** :
    *   Dans le constructeur, elle détecte si c'est le carnet d'adresses par défaut ("contacts") et traduit son nom d'affichage pour l'interface utilisateur (ex: "Contacts" en français).

2.  **Gestion des Partages (`IShareable`)** :
    *   **`updateShares`** : Permet d'ajouter ou supprimer des partages. Elle délègue cette action complexe au `CardDavBackend`.
    *   **`getShares`** : Récupère la liste des utilisateurs avec qui ce carnet est partagé.
    *   **Sécurité** : Elle empêche le partage d'un carnet qui est *déjà* un partage (on ne peut pas re-partager un partage).

3.  **Gestion des Permissions (ACL)** :
    *   **`getACL`** : Définit qui a le droit de faire quoi.
    *   Elle construit une liste de règles (ACL) dynamique :
        *   Le propriétaire a tous les droits (lecture, écriture, modification des propriétés).
        *   Le système (`principals/system/system`) a des droits spécifiques.
        *   Si le carnet est partagé, elle ajoute les permissions pour le bénéficiaire (lecture seule ou lecture-écriture selon le partage).
        *   Elle filtre les règles pour ne retourner que celles pertinentes pour les principaux autorisés.

4.  **Accès aux Contacts (Enfants)** :
    *   **`getChild($name)`** : Récupère une fiche contact spécifique (`Card`).
    *   **`getChildren()`** : Récupère toutes les fiches contacts du carnet.
    *   Pour chaque contact récupéré, elle lui attache les permissions (ACL) du carnet parent.

5.  **Opérations CRUD** :
    *   **`delete()`** : Supprime le carnet. Si c'est un carnet partagé, elle retire simplement le partage (se désabonne) au lieu de supprimer les données réelles.
    *   **`propPatch()`** : Met à jour les propriétés (nom, description). Elle bloque ces modifications si l'utilisateur n'est pas le propriétaire réel (cas d'un partage).

6.  **Déplacement de Contacts (`IMoveTarget`)** :
    *   **`moveInto()`** : Gère l'arrivée d'un contact déplacé depuis un autre carnet. Elle délègue l'opération atomique à `carddavBackend->moveCard(...)`.

## Dépendances Clés

-   `Sabre\CardDAV\Backend\BackendInterface` (ici `CardDavBackend`) : Le service qui effectue toutes les opérations de persistance.
-   `OCP\IL10N` : Pour la traduction du nom par défaut.
