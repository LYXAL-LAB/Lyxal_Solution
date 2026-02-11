# Architecture Lyxal_Dav

Ce document décrit l'architecture de `Lyxal_Dav`, un serveur WebDAV / CalDAV / CardDAV modulaire écrit en Rust.

## 1. Vue d'ensemble

`Lyxal_Dav` est conçu comme une bibliothèque ("embedded") pouvant être intégrée dans n'importe quelle application Rust, ou exécutée en mode standalone.

L'architecture suit une séparation stricte entre :
1.  **Protocole (Core)** : Gestion des requêtes HTTP, parsing XML, logique métier DAV.
2.  **Stockage (Backend)** : Abstraction du stockage via le trait `DavBackend`.
3.  **Serveur (Server)** : Couche d'intégration (Axum) et implémentation par défaut (SQLite).

```mermaid
graph TD
    Client[Client WebDAV/CalDAV] -->|HTTP/XML| Server[Lyxal Dav Server (Axum)]
    Server -->|DavContext| Core[Lyxal Dav Core]
    Core -->|DavBackend Trait| Backend[Storage Backend]
    
    subgraph "Core Module"
        Methods[WebDAV Methods (GET, PUT, REPORT...)]
        XML[XML Parsing/Generation]
        Models[Data Models (Resource, Principal...)]
    end
    
    subgraph "Backend Implementations"
        SQLite[SqliteBackend]
        Surreal[SurrealBackend (Future)]
        Memory[MemBackend (Test)]
    end
    
    Core --> Methods
    Methods --> Models
    Backend --> SQLite
    Backend --> Surreal
```

## 2. Couches Logicielles

### 2.1. Core (`lyxal-dav-core`)
C'est le cœur du système. Il est pur Rust, sans dépendance à une base de données spécifique.
*   **Trait `DavBackend`** : Le contrat d'interface que tout stockage doit implémenter. C'est l'unique point d'extension pour le stockage.
*   **Structs** : `DavContext`, `Resource`, `Principal`, `DavError`.
*   **Logique** : Implémente la sémantique des verbes WebDAV (héritage ACL, Locking, Sync-Token logic).

### 2.2. Backend (`lyxal-dav-server`)
Fournit l'implémentation de référence.
*   **`SqliteBackend`** : Implémentation robuste sur SQLite.
    *   Supporte WebDAV (fichiers génériques), CalDAV (calendriers, événements), CardDAV (contacts).
    *   Gère les transactions atomiques.
    *   Implémente le filtrage `REPORT` (parfois en mémoire pour CalDAV/CardDAV si SQL trop complexe).

### 2.3. Utilitaires
*   **`lyxal_ical_core`** : Parser/Serialiser iCalendar (RFC 5545).
*   **`lyxal_vcard_core`** : Parser/Serialiser vCard (RFC 6350).

## 3. Modèle de Données Unifié

Depuis la version D5, le serveur utilise un modèle unifié pour tous les types de ressources.

### 3.1. Types de Ressources (`ResourceKind`)
*   `Collection` : Dossier WebDAV générique.
*   `Generic` : Fichier WebDAV générique.
*   `Calendar` : Collection CalDAV.
*   `Object` : Événement/Tâche (iCal).
*   `AddressBook` : Collection CardDAV.
*   `Contact` : Contact (vCard).

### 3.2. Stockage (Schéma SQLite)
Bien que le backend soit abstrait, l'implémentation SQLite utilise ces tables clés :
*   `webcollections` / `webobjects` : Stockage générique.
*   `calendars` / `calendarobjects` : Stockage optimisé CalDAV (indexation temps).
*   `addressbooks` / `addressbookobjects` : Stockage optimisé CardDAV.
*   `principals` : Utilisateurs et homes.
*   `davshares` : Gestion des délégations et ACL.
*   `davlocks` : Verrous WebDAV.
*   `*changes` : Tables de logs pour `sync-collection` (delta sync).

## 4. Sécurité & ACL

Le modèle de sécurité est basé sur l'héritage et la délégation.

*   **Authentication** : Basic ou Bearer (via `DavBackend`).
*   **ACL** :
    *   **Owner** : Le propriétaire du path (ex: `/files/{user}/...`) a tous les droits.
    *   **Shares** : Les droits peuvent être délégués via la table `davshares`.
    *   **Héritage** : Les droits définis sur un dossier parent s'appliquent aux enfants (récursif).
*   **Locking** : Conforme RFC 4918. Un verrou est exclusif et empêche toute modification par autrui (même admin).

## 5. Stabilité de l'API (D6.1)

Les éléments suivants sont **GELÉS** et constituent l'API publique stable :

1.  **Trait `DavBackend`** : Toutes les méthodes (get/put/delete/list/sync/lock/acl...).
2.  **Struct `Resource`** : Champs `kind`, `etag`, `properties`.
3.  **Struct `DavContext`** : Utilisé pour passer l'état (user, request) aux handlers.

Toute modification future doit se faire via des extensions de trait ou de nouvelles méthodes optionnelles, sans casser l'existant.

