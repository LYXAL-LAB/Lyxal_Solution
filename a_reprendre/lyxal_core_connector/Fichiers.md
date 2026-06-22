Pour la création de `lyxal_connector`, nous avons implémenté un `DEFINE CONNECTOR` dans `lyxal_core`. Voici la **liste exhaustive** de tous les fichiers impactés ou créés (basée sur une recherche globale du mot-clé `connector`).

## 📁 Nouveaux fichiers créés

### 🏗️ Définition, Schéma et Clés
- **[connector.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/catalog/schema/connector.rs)** : Structure `ConnectorDefinition`, sérialisation et conversion SQL.
- **[cn.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/key/database/cn.rs)** : Logique des clés KVS pour le stockage des connectors.

### ⚡ Statements LyxalQL (Logique Métier)
- **[connector.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/expr/statements/define/connector.rs)** : Exécution de `DEFINE CONNECTOR`.
- **[connector.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/expr/statements/remove/connector.rs)** : Exécution de `REMOVE CONNECTOR`.

### 📝 Représentation SQL
- **[connector.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/sql/statements/define/connector.rs)** : Modèle SQL pour `DEFINE`.
- **[connector.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/sql/statements/remove/connector.rs)** : Modèle SQL pour `REMOVE`.

### 🛠️ Fonctions Intégrées (Built-in)
- **[connector.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/exec/function/builtin/connector.rs)** : Définit la fonction `connector::call()` pour invoquer des endpoints de connecteurs directement en SQL.

### 🧪 Tests
- **[connector.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/tests/connector.rs)** : Tests d'intégration pour les fonctionnalités connector.

### 🚀 Moteur d'Exécution (lyxal_apps_connector/src/)
- **[invocation.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_apps/lyxal_connector/src/invocation.rs)** : **(NOUVEAU)** Logique réelle d'exécution : résolution d'endpoint, interpolation URL, injection auth, retry avec backoff exponentiel, error mapping `ON ERROR`.
- **[request.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_apps/lyxal_connector/src/request.rs)** : **(NOUVEAU)** Structure `ConnectorRequest` (URL, méthode, headers, body, timeout).
- **[response.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_apps/lyxal_connector/src/response.rs)** : **(NOUVEAU)** Structure `ConnectorResponse` avec conversion en `Value` structuré (status, headers, body).
- **[rate_limit.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_apps/lyxal_connector/src/rate_limit.rs)** : **(NOUVEAU)** Rate limiter par connecteur avec fenêtre glissante (sliding window).
- **[err.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_apps/lyxal_connector/src/err.rs)** : Re-export de `ConnectorError` depuis `lyxal_core_error`.
- **[lib.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_apps/lyxal_connector/src/lib.rs)** : Point d'entrée de la crate, déclaration de tous les modules.
- **[Cargo.toml](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_apps/lyxal_connector/Cargo.toml)** : Dépendances de la crate (`reqwest`, `base64`, `tokio`, `serde_json`, etc.).

### 🔗 Branchement fnc::connector (lyxal_core_functions)
- **[connector/mod.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_functions/src/connector/mod.rs)** : **(NOUVEAU)** 5 fonctions connector: `call()` (invocation), `list()` (lister les connecteurs), `info()` (détails d'un connecteur), `health()` (ping base_url), `batch()` (appels en lot).
- **[lib.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_functions/src/lib.rs)** : Ajout de `pub mod connector;`, 5 fonctions `connector::*` dans le dispatch async, et `name.starts_with("connector")` dans le routeur `run()`.

---

## 🛠️ Fichiers modifiés pour l'intégration

### 🔍 Parsing & Lexing (Grammaire LyxalQL)
- **[keywords.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/syn/lexer/keywords.rs)** : Ajout du mot-clé dans le lexer.
- **[keyword.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/syn/token/keyword.rs)** : Définition du token `CONNECTOR`.
- **[define.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/syn/parser/stmt/define.rs)** : Intégration dans le parser `DEFINE`.
- **[remove.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/syn/parser/stmt/remove.rs)** : Intégration dans le parser `REMOVE`.
- **[builtin.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/syn/parser/builtin.rs)** : Ajout de `connector::call` dans la table `PATHS` du parser de fonctions built-in.

### 🧠 Couche Expression (read_only / access_mode)
- **[function.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/expr/function.rs)** : Ajout de `connector::call` dans le check `read_only()` (effets de bord HTTP → non read-only).
- **[builtin.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/exec/physical_expr/function/builtin.rs)** : Ajout de `connector::call` dans `access_mode()` → `ReadWrite` pour le streaming executor.

### 🏛️ Architecture & Catalogue
- **[providers.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/catalog/providers.rs)** : Définition de l'interface `ConnectorProvider` pour le KVS.
- **[aggregation.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/catalog/aggregation.rs)** : Support pour l'agrégation des connectors.
- **[visit.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/expr/visit.rs)** : Logique de visite des expressions.
- **[category.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/key/category.rs)** : Classification de la ressource.

### 🛡️ IAM (Sécurité)
- **[resource.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/iam/entities/resources/resource.rs)** : Ajout de `Connector` dans l'énumération `ResourceKind` pour la gestion des permissions.

### 🚀 Persistence & Mise en Cache (KVS)
- **[tx.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_kvs/src/tx.rs)** : Implémentation réelle de la sauvegarde et du cache (Provider).
- **[entry.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_kvs/src/cache/tx/entry.rs)** : Type d'entrée de cache `Cns`.
- **[key.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_kvs/src/cache/tx/key.rs)** & **[lookup.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_kvs/src/cache/tx/lookup.rs)** : Types de lookup pour le cache.

### ❌ Gestion des Erreurs
- **[connector_err.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_error/src/connector_err.rs)** : **(NOUVEAU)** Définition de toutes les erreurs spécifiques aux connecteurs (`ConnectorNotFound`, `HttpRequestFailed`, `RateLimitExceeded`, `Timeout`, etc.).
- **[lib.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_error/src/lib.rs)** : Ajout du module `connector_err`, export de `ConnectorError`, et ajout du variant `ConnectorError(ConnectorError)` dans l'enum `Error`.
- **[to_types.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_error/src/to_types.rs)** : Ajout de la conversion `ConnectorError` → `TypesError` pour la compatibilité avec l'API publique.

### 📦 Enregistrement des Modules (Fichiers `mod.rs`)
Les fichiers suivants ont été mis à jour pour exporter les nouveaux modules :
- `lyxal_core_db/src/catalog/mod.rs`
- `lyxal_core_db/src/catalog/schema/mod.rs`
- `lyxal_core_db/src/expr/statements/mod.rs`
- `lyxal_core_db/src/expr/statements/define/mod.rs`
- `lyxal_core_db/src/expr/statements/remove/mod.rs`
- `lyxal_core_db/src/sql/statements/mod.rs`
- `lyxal_core_db/src/sql/statements/define/mod.rs`
- `lyxal_core_db/src/sql/statements/remove/mod.rs`
- **[builtin/mod.rs](file:///C:/Users/Admin/Desktop/Lyxal_Solution/lyxal_solution_backend/lyxal_core/core/src/lyxal_core_db/src/exec/function/builtin/mod.rs)** : Enregistrement de la nouvelle fonction `connector::call()`.

---

## ❓ Comparaison avec l'API (pour extension future)
Si vous implémentez des **Modules** sur le même modèle que les **APIs**, voici les points de comparaison déjà analysés :
- `builtin/api.rs` (Fonctions SQL), `lyxal_core_kvs/src/api.rs` (Interface KVS), `lyxal_core_functions/src/api` (Logique métier).