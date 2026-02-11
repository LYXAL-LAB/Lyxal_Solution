# D10 — Spécification des Natives DAV SurrealDB

Ce document définit le contrat applicatif stable pour l'intégration native du protocole DAV (WebDAV, CalDAV, CardDAV) au sein du moteur SurrealDB. Il sert de référence pour l'implémentation future des fonctions `dav::*` en Rust (embedded) ou SurrealQL.

## D10.1 — Spécification des Fonctions Natives DAV

Les fonctions suivantes constituent l'API publique exposée par le module DAV au sein de SurrealDB. Elles sont appelables depuis SurrealQL, les Agents, ou le Scheduler.

### Conventions
- **Path** : Chemin absolu DAV, incluant le tenant si nécessaire (ex: `/dav/acme/calendars/alice/work/`).
- **Principal** : L'utilisateur effectuant l'action (contexte d'exécution).
- **Retour** : Un objet `Result<T, DavError>` standardisé.

### Signatures

#### `dav::get(path: string) -> object`
Récupère une ressource ou une collection.
- **Paramètres** : `path` (string).
- **Retour** : Objet `Resource` (voir D10.2) contenant métadonnées et contenu.
- **Invariants** : Vérifie ACL (read). Si collection, ne retourne pas les enfants (voir `list`).

#### `dav::put(path: string, content: bytes, headers: object?) -> object`
Crée ou met à jour une ressource.
- **Paramètres** : 
  - `path` (string).
  - `content` (bytes/blob).
  - `headers` (map optionnelle : `Content-Type`, `If-Match` pour ETag).
- **Retour** : Objet `{ etag: string, created: bool }`.
- **Invariants** : 
  - Vérifie ACL (write).
  - Vérifie Lock (si verrouillé par autre token -> erreur).
  - Incrémente `sync-token` de la collection parente.
  - Valide le contenu (iCalendar, vCard) si applicable.
  - Déclenche scheduling iTIP si applicable.

#### `dav::delete(path: string) -> bool`
Supprime une ressource ou une collection.
- **Paramètres** : `path` (string).
- **Retour** : `true` si supprimé, `false` si inexistant (ou erreur).
- **Invariants** : 
  - Vérifie ACL (write).
  - Vérifie Lock.
  - Supprime récursivement si collection.
  - Incrémente `sync-token` parent.

#### `dav::list(path: string, depth: int) -> array<object>`
Liste les enfants d'une collection.
- **Paramètres** : 
  - `path` (string).
  - `depth` (int : 0 = self, 1 = children, -1 = infinity).
- **Retour** : Tableau d'objets `Resource`.
- **Invariants** : Vérifie ACL (read). Filtrage partiel si ACL restrictives sur enfants.

#### `dav::mkcol(path: string) -> bool`
Crée une collection WebDAV standard (pas un calendrier/carnet).
- **Paramètres** : `path` (string).
- **Retour** : `true` si succès.
- **Invariants** : ACL (write-content sur parent), Lock.

#### `dav::move(src: string, dst: string, overwrite: bool) -> bool`
Déplace une ressource ou collection.
- **Paramètres** : `src`, `dst`, `overwrite`.
- **Retour** : `true` si succès.
- **Invariants** : ACL (read src, write dst), Lock (src et dst), Atomicité, update sync-token (src et dst).

#### `dav::copy(src: string, dst: string, overwrite: bool) -> bool`
Copie une ressource ou collection.
- **Paramètres** : `src`, `dst`, `overwrite`.
- **Retour** : `true` si succès.
- **Invariants** : ACL (read src, write dst), Lock (dst), Génération nouveaux UID pour CalDAV/CardDAV.

#### `dav::lock(path: string, scope: string, depth: string, timeout: int) -> object`
Pose un verrou.
- **Paramètres** : `scope` ("exclusive"), `depth` ("0", "infinity"), `timeout` (secondes).
- **Retour** : Objet `Lock` avec token.
- **Invariants** : Vérifie conflits de locks existants.

#### `dav::unlock(path: string, token: string) -> bool`
Retire un verrou.
- **Paramètres** : `token` (locktoken).
- **Retour** : `true` si succès.
- **Invariants** : Vérifie que le token correspond au lock.

#### `dav::sync(path: string, token: string, limit: int?) -> object`
Synchronisation incrémentale (RFC 6578).
- **Paramètres** : `token` (sync-token client, vide pour init), `limit` (max items).
- **Retour** : Objet `{ sync_token: string, changes: array, deletions: array, partial: bool }`.
- **Invariants** : Lecture seule, efficace (basé sur log des changements).

---

## D10.2 — Modèle de Données Natif DAV

Ce modèle définit les structures logiques manipulées par les fonctions natives. Il est indépendant du stockage physique sous-jacent.

### Tenant
Concept logique porté par le préfixe du chemin (`/dav/{tenant}/...`).
- Pas d'objet explicite, mais contexte d'isolation strict.

### Resource
Représente tout nœud DAV (Fichier, Dossier, Calendrier, Contact).
- `path`: string (clé primaire logique).
- `kind`: enum (`Collection`, `Calendar`, `AddressBook`, `Object` (Event/Task), `Contact`, `Resource` (File)).
- `etag`: string.
- `last_modified`: timestamp.
- `creation_date`: timestamp.
- `content_type`: string.
- `content`: bytes (lazy loaded).
- `props`: map<string, string> (propriétés mortes WebDAV).
- `sync_token`: string (si collection).

### Principal
Identité agissante.
- `tenant`: string.
- `username`: string.
- `role`: string (optionnel).
- `acl_url`: string.

### Share (ACL)
Définit les droits d'accès.
- `resource_path`: string.
- `principal`: string (user ou group).
- `access`: enum (`read`, `write`, `read-write`, `owner`).
- `inherited_from`: string (optionnel, si hérité du parent).

### Lock
Verrou actif.
- `path`: string.
- `token`: string (uuid).
- `owner`: Principal.
- `expiration`: timestamp.
- `depth`: enum (`0`, `infinity`).
- `scope`: enum (`exclusive`, `shared`).

### SyncChange
Entrée de journal de synchronisation.
- `collection_path`: string.
- `resource_name`: string.
- `operation`: enum (`create`, `update`, `delete`).
- `sync_token`: int/string (séquence).

---

## D10.3 — Modèle d’exécution (Context)

Les natives DAV ne sont pas des fonctions pures ; elles dépendent d'un **Contexte d'Exécution**.

### 1. Obtention du Contexte
Le contexte doit être fourni implicitement par l'environnement d'exécution (SurrealDB) ou passé explicitement.

**Composants du Contexte :**
- **Tenant** : Déduit du chemin (`dav::get("/dav/acme/...")` -> `acme`) ou du contexte de session ($ns/$db).
- **Principal** : L'utilisateur connecté à la session SurrealDB (`$auth`) ou l'identité de l'Agent/Scheduler.
- **Transaction** : Les opérations d'écriture (`put`, `move`, `delete`) doivent s'exécuter dans la transaction courante de SurrealDB.

### 2. Flux d'Exécution Standard
1.  **Resolution** : Parsing du path -> Identification Tenant et Ressource cible.
2.  **Authentication** : Validation du Principal (déjà fait par SurrealDB layer).
3.  **Authorization** : `check_access(principal, resource, action)` basé sur `davshares`.
4.  **Locking** : `check_locked(resource)` -> rejet si verrouillé par tiers.
5.  **Operation** : Exécution logique (CRUD).
6.  **Side Effects** :
    - Mise à jour `sync-token` parent.
    - Écriture dans `*_changes`.
    - Scheduling iTIP (si CalDAV).
7.  **Commit/Rollback** : Géré par le moteur SurrealDB.

### 3. Utilisation Hors-HTTP
- **Agent** : Un agent peut appeler `dav::put` pour générer un rapport PDF et le stocker. Le Principal est l'Agent.
- **Scheduler** : Une tâche cron peut appeler `dav::delete` pour nettoyer les vieux fichiers.
- **SurrealQL** : `SELECT dav::get(path) FROM ...`

---

## D10.4 — Mapping Surreal (Stub)

Proposition de mapping vers les primitives SurrealDB (existantes ou futures).

### Mapping des Tables (Conceptuel)
- `Resource` -> Table `dav_resource` (polymorphe ou tables séparées `dav_calendar`, `dav_file`...).
- `Changes` -> Table `dav_change` (append-only).
- `Locks` -> Table `dav_lock` (avec TTL).

### Hooks & Events Requis
- **Change Feed** : Pour alimenter `dav_change` automatiquement lors d'un INSERT/UPDATE/DELETE sur `dav_resource`.
  - *Actuel* : LIVE QUERIES (côté client) / EVENTS (côté serveur, définissables).
  - *Besoin* : Un trigger synchrone pour garantir l'incrément du `sync-token` et l'insertion dans `changes` de manière atomique.
- **Transactions** : `BEGIN TRANSACTION ... COMMIT`. Supporté par SurrealDB.

### Fonctions Manquantes / Bloquants (État Actuel)
1.  **`DEFINE FUNCTION` (Rust)** : Possibilité de définir des fonctions natives en Rust chargées dynamiquement ou compilées statiquement dans le binaire SurrealDB custom. (En chantier).
2.  **Blob Storage** : Stockage efficace de `content` binaire volumineux. SurrealDB supporte `bytes`, mais la performance pour des gros fichiers (>100MB) via WebSocket/QL reste à valider.
3.  **Context Access** : Accéder à l'utilisateur courant (`$auth`) depuis une fonction native Rust.

### Stratégie d'Intégration
- **Phase 1 (Maintenant)** : Définition des signatures (ce document).
- **Phase 2 (Proto)** : Implémentation des fonctions `dav::*` en Rust (crate `lyxal-dav-native`) qui utilisent le `SurrealBackend` existant ou une variante directe sur le `Datastore` SurrealDB (KVS).
- **Phase 3 (Final)** : Exposition via `DEFINE FUNCTION` dans SurrealQL.

---
**Statut D10** : Spécification figée. Prêt pour implémentation future.

