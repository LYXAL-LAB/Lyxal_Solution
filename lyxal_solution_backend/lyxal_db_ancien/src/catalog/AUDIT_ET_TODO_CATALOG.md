# 🛡️ Rapport d'Audit et Roadmap : Lyxal_Core / Catalog

Ce document présente l'audit technique du module `catalog` (basé sur SurrealDB v3.0.0-beta.2) et définit les étapes nécessaires pour sa transformation en cœur de système pour **Lyxal Solution**.

---

## 1. 🔍 Résultats de l'Audit

### 🔒 Sécurité & Accès (`access.rs`, `schema/access.rs`)
*   **Constat** : Le système de `GrantBearer` avec hachage Sha256 est solide. La redaction automatique des secrets (`redacted()`) protège les fuites dans les logs.
*   **Axe d'amélioration** : Les types de permissions (`Select, Create, Update, Delete`) sont trop orientés "Données".
*   **Risque Lyxal** : Pour les modules DAV et Email, nous avons besoin de permissions de type "Service" (ex: `Connect`, `Relay`, `Sync`).

### 🏗️ Architecture & Multi-tenancy (`namespace.rs`, `database.rs`)
*   **Constat** : L'isolation est purement logique (via `NamespaceId`). Le système ne connaît pas la localisation physique des données.
*   **Axe d'amélioration** : Manque total de la notion de **Realm** (Isolation physique par dossier/serveur).
*   **Besoin Lyxal** : Le Kernel doit pouvoir aiguiller une requête vers un `realm_id` spécifique avant d'atteindre le Namespace.

### ⚡ Performance & Stockage (`record.rs`, `table.rs`)
*   **Constat** : Les données sont stockées sous forme de `Value` générique. C'est flexible mais peut devenir lourd pour les gros objets.
*   **Axe d'amélioration** : Risque de pollution du LSM-Tree (`lyxalkv`) si des fichiers binaires lourds (DAV) sont stockés directement dans le catalogue.

---

## 2. 📝 TODO List : Transformation vers Lyxal_Core

### 🟦 Priorité 1 : Intégration Native des Realms (Isolation Physique)
- [ ] **Modifier `namespace.rs`** : Ajouter un champ `realm_id: Option<u128>` dans `NamespaceDefinition` pour lier l'entité logique à son instance physique.
- [ ] **Étendre `access.rs`** : Créer un `GrantRealm` permettant d'autoriser un utilisateur au niveau de l'instance OS avant le niveau base de données.
- [ ] **Implémenter l'Auto-Mapping** : Modifier les providers pour que le `realm_id` soit injecté automatiquement lors du `SIGNIN`.

### 🟨 Priorité 2 : Unification de l'Identité (Identity Native)
- [ ] **Migration `lyxal_identity`** : Porter les structures de `lyxal_iam` (Applications, Tenants) comme des objets natifs dans le dossier `catalog/schema/`.
- [ ] **Définir `DEFINE REALM`** : Ajouter le support syntaxique dans le catalogue pour créer un environnement isolé (Dossier + NS + DB) en une commande.
- [ ] **Scopes Etendus** : Ajouter `DavAccess` et `EmailAccess` dans l'énumération des permissions système.

### 🟩 Priorité 3 : Optimisation du Stockage (Hybrid Storage)
- [ ] **Refactoring `record.rs`** : Implémenter un mécanisme de "External Pointer" pour les records. Si une donnée dépasse 64KB, le catalogue ne stocke qu'une référence vers `lyxal_bucket`.
- [ ] **Aiguillage LyxalKV** : Dans `providers.rs`, permettre au `Datastore` d'ouvrir un `lyxalkv::Tree` spécifique au `realm_id` plutôt qu'un chemin global unique.

---

## 3. 🏁 Conclusion de l'Audit

Le code actuel est une excellente base de "Base de données distribuée". Pour devenir un **"Cloud OS"**, le catalogue doit cesser d'être un simple index de tables pour devenir un **Annuaire de Ressources Physiques et Logiques**.

**Statut Global** : 🟡 **En attente de modularisation**

---
*Généré par Goose pour le projet Lyxal Solution.*
