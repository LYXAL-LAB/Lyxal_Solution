# Lyxal Bridge — Référence Technique Complète

> **Dernière mise à jour :** 2026-03-30  
> **Version :** 0.1.0  
> **Statut :** Phase 1, 2 & 3 terminées — Traçabilité complète

Ce document est la **référence unique** de tout ce qui a été implémenté dans `lyxal_bridge`.  
Il couvre la crate Rust, le câblage SurrealQL, la traçabilité, et les schémas DB.

---

## Table des Matières

1. [Vue d'ensemble du projet](#1-vue-densemble)
2. [Structure des fichiers](#2-structure-des-fichiers)
3. [Crate Rust — Modules en détail](#3-modules)
4. [Câblage SurrealQL — Les 5 fichiers modifiés](#4-câblage)
5. [Système de traçabilité](#5-traçabilité)
6. [Schéma de base de données](#6-schéma-db)
7. [Flux d'exécution end-to-end](#7-flux)
8. [Phases du projet](#8-phases)

---

## 1. Vue d'ensemble {#1-vue-densemble}

Lyxal Bridge est un **moteur d'intégrations sortantes** data-driven. Contrairement à n8n où les connecteurs sont codés en dur (fichiers TypeScript par provider), Lyxal Bridge lit **toutes ses métadonnées depuis SurrealDB** (`bridge_*` tables) et exécute les appels HTTP dynamiquement.

### Différence fondamentale avec l'ancien système

```
AVANT (DEFINE CONNECTOR)                  APRÈS (bridge::call)
──────────────────────                     ──────────────────────
15 fichiers modifiés dans le parser        5 lignes dans la table PATHS
Nouvel AST → KVS → IAM                    Simple built-in function
Recompilation pour chaque provider         Hot-reload depuis la DB
~2000 lignes de parser/lexer               ~50 lignes de câblage
```

### Appel depuis SurrealQL

```sql
-- Appel simple
LET $result = bridge::call("airtable", "list_records", { baseId: "appXYZ", limit: 10 });

-- Lister les providers
LET $providers = bridge::list();

-- Infos d'un provider
LET $info = bridge::info("stripe");

-- Health check
LET $health = bridge::health("slack");

-- Appels en parallèle
LET $results = bridge::batch([
    { provider: "slack", operation: "send_message", params: { channel: "sales" } },
    { provider: "sendgrid", operation: "send_email", params: { to: "a@b.com" } }
]);
```

---

## 2. Structure des fichiers {#2-structure-des-fichiers}

```
lyxal_apps/lyxal_bridge/
│
├── Cargo.toml                                    ← Dépendances de la crate
│
├── src/                                          ← CODE RUST (moteur)
│   ├── lib.rs                                    ← Point d'entrée, re-exports
│   ├── error.rs                                  ← BridgeError (15 variantes)
│   ├── models.rs                                 ← Structs Rust ↔ tables bridge_*
│   ├── context.rs                                ← BridgeContext (HTTP pool, cache, circuit breakers)
│   ├── resolver.rs                               ← Résolution dynamique depuis SurrealDB
│   ├── request.rs                                ← Construction dynamique des requêtes HTTP
│   ├── response.rs                               ← Parsing des réponses HTTP → JSON
│   ├── executor.rs                               ← bridge_call() + résilience + trace
│   ├── rate_limit.rs                             ← Rate limiter sliding window
│   ├── hooks.rs                                  ← Système de hooks (trait BridgeHook)
│   └── trace.rs                                  ← Traçabilité complète (BridgeTrace)
│
├── database/                                     ← SCHÉMAS SURREALDB
│   ├── bridge_auth_methods.surql                 ← Types d'auth (api_key, bearer, oauth2...)
│   ├── bridge_auth_schemas.surql                 ← Schémas d'auth par provider (edge table)
│   ├── bridge_errors.surql                       ← Règles d'erreur (retry, stop, map...)
│   ├── bridge_execution_logs.surql               ← Traces d'exécution (traçabilité)
│   ├── bridge_operations.surql                   ← Opérations API (endpoints)
│   ├── bridge_operations_methods.surql           ← Méthodes HTTP (GET, POST...)
│   ├── bridge_parameter_locations.surql          ← Emplacements de paramètres (query, header...)
│   ├── bridge_parameter_sources.surql            ← Sources de valeurs (static, user, auth...)
│   ├── bridge_providers.surql                    ← Providers (Airtable, Slack, Stripe...)
│   ├── bridge_status.surql                       ← Statuts (active, inactive, deprecated...)
│   ├── bridge_user_credentials.surql             ← Credentials chiffrés par utilisateur
│   ├── schema.surql                              ← Schéma global
│   └── functions/
│       └── gs_format_output_full.surql           ← Fonctions SurQL utilitaires
│
├── dataseed/                                     ← DONNÉES DE SEED
│   ├── bridge_auth_methods.surql
│   ├── bridge_operations_methods.surql
│   ├── bridge_parameter_locations.surql
│   ├── bridge_parameter_sources.surql
│   ├── bridge_providers.surql
│   └── bridge_status.surql
│
├── docs/                                         ← DOCUMENTATION
│   ├── architecture_bridge_async_fn.md           ← Design architectural (le "pourquoi")
│   ├── guide_ajout_builtin_function.md           ← Guide pour ajouter des fonctions (le "comment")
│   ├── reference_technique.md                    ← CE DOCUMENT (référence complète)
│   ├── complex_logic_patterns.md                 ← Patterns pour logique complexe
│   ├── internal_dependencies.md                  ← Dépendances internes
│   └── lyxal_bridge.md                           ← Vue d'ensemble originale
```

### Fichiers modifiés dans le core Lyxal (câblage SurrealQL)

```
lyxal/core/src/
├── db/syn/parser/builtin.rs                      ← +6 lignes (PATHS)
├── function/mod.rs                               ← +8 lignes (module + routing + dispatch)
├── function/bridge.rs                            ← NOUVEAU (~350 lignes, branchement réel)
├── db/exec/function/builtin/mod.rs               ← +2 lignes (module + register)
├── db/exec/function/builtin/bridge.rs            ← NOUVEAU (~60 lignes, streaming executor)
│
# Cargo.toml modifié :
├── Cargo.toml                                    ← +1 ligne (dep lyxal_bridge)
```

---

## 3. Modules Rust en détail {#3-modules}

### 3.1 `error.rs` — Types d'erreurs

15 variantes couvrant tout le pipeline :

| Variante | Catégorie | Description |
|:---|:---|:---|
| `ProviderNotFound` | Résolution | Provider inexistant ou inactif |
| `OperationNotFound` | Résolution | Opération inexistante pour ce provider |
| `CredentialNotFound` | Résolution | Pas de credentials pour ce provider |
| `MissingParameter` | Requête | Paramètre requis absent |
| `UnresolvedPlaceholder` | Requête | Placeholder `{xxx}` non résolu dans l'URL |
| `InvalidBaseUrl` | Requête | URL de base invalide |
| `HttpRequestFailed` | HTTP | Erreur réseau/DNS/timeout |
| `HttpResponseError` | HTTP | Réponse 4xx ou 5xx |
| `Timeout` | HTTP | Timeout dépassé |
| `RateLimitExceeded` | Résilience | Rate limit atteint |
| `RetriesExhausted` | Résilience | Plus de tentatives disponibles |
| `CircuitBreakerOpen` | Résilience | Provider temporairement bloqué |
| `MappedError` | Error Mapping | Erreur traduite par une règle `bridge_errors` |
| `StoppedByRule` | Error Mapping | Arrêt forcé par une règle |
| `HookFailed` | Hooks | Échec d'un hook pré/post |
| `Internal` | Interne | Catch-all |
| `Database` | Interne | Erreur DB |

### 3.2 `models.rs` — Structs de données

Mapping direct des tables SurrealDB vers des structs Rust :

```rust
BridgeProvider        ← bridge_providers
  ├── .identity.name           // "airtable"
  └── .configuration.endpoint_base_url  // "https://api.airtable.com"

BridgeOperation       ← bridge_operations
  ├── .relations.provider_id   // "bridge_providers:airtable"
  ├── .identity.name           // "list_records"
  └── .configuration
      ├── .method              // "bridge_operations_methods:get"
      ├── .path                // "/v0/{baseId}/{table}"
      ├── .parameters[]        // [{name, in, value_type, value, required}]
      ├── .body_template       // { ... }
      └── .hooks[]             // ["hmac_sign", "auto_paginate"]

BridgeErrorRule       ← bridge_errors
  ├── .triggers.http_code      // 429
  ├── .configuration.action    // "retry"
  └── .resilience
      ├── .max_attempts        // 3
      ├── .backoff_ms          // 1000
      └── .exponential         // true

ResolvedAuth          (mémoire uniquement, jamais persisté)
  ├── .auth_type               // "bearer"
  └── .fields                  // { "token": "sk-xxx" }
```

### 3.3 `context.rs` — BridgeContext

Singleton partagé entre tous les appels `bridge::call()` :

```rust
BridgeContext
 ├── http_client: reqwest::Client        // Pool TCP réutilisable
 ├── cache: DashMap<CachedMetadata>      // Cache provider+operation (TTL 5min)
 ├── circuit_breakers: DashMap<State>    // Circuit breaker par provider
 ├── hooks: HookRegistry                // Hooks enregistrés
 └── config: BridgeConfig               // Timeouts, pool sizes, etc.
```

**Configuration par défaut :**

| Paramètre | Valeur | Description |
|:---|:---|:---|
| `cache_ttl` | 5 min | Durée de vie du cache des métadonnées |
| `default_timeout` | 30 s | Timeout HTTP par défaut |
| `pool_max_idle_per_host` | 10 | Connexions idle par host |
| `pool_idle_timeout` | 90 s | Timeout des connexions idle |

### 3.4 `resolver.rs` — Résolution depuis la DB

Deux fonctions principales :

| Fonction | Ce qu'elle fait | Tables interrogées |
|:---|:---|:---|
| `resolve_operation()` | Résout provider + opération + règles d'erreur | `bridge_providers`, `bridge_operations`, `bridge_errors` |
| `resolve_auth()` | Résout les credentials et le type d'auth | `bridge_user_credentials`, `bridge_auth_schemas` |

**Architecture découplée :** Le resolver prend un paramètre `db_query: F` (closure) au lieu de dépendre directement de SurrealDB. Cela permet :
- Tests unitaires avec des mocks
- Découplage de la version de SurrealDB
- Injection de dépendance propre

### 3.5 `request.rs` — Construction des requêtes HTTP

Transforme les métadonnées DB en une `BridgeRequest` concrète.

**Logique d'injection des paramètres :**

Chaque paramètre dans `bridge_operations.configuration.parameters[]` a deux axes :

1. **Où injecter** (`in` / `location`) :

| Location | Exemple |
|:---|:---|
| `path` | `/v0/{baseId}/records` → `/v0/appXYZ/records` |
| `query` | `?limit=10&offset=0` |
| `header` | `X-API-Version: v1` |
| `body` | `{ "fieldName": "value" }` |
| `cookie` | `Cookie: session_id=abc` |

2. **D'où vient la valeur** (`value_type`) :

| Source | Description |
|:---|:---|
| `static` | Valeur fixe définie dans la DB |
| `user` | Fournie par l'utilisateur dans `bridge::call()` |
| `auth` | Extraite des credentials déchiffrés |
| `expression` | Évaluée dynamiquement (TODO) |

**Auth injection :**

| Type d'auth | Header généré |
|:---|:---|
| `bearer` | `Authorization: Bearer sk-xxx` |
| `basic` | `Authorization: Basic base64(user:pass)` |
| `api_key` | Header custom (ex: `X-API-Key: xxx`) |
| `oauth2` | `Authorization: Bearer {access_token}` |

### 3.6 `response.rs` — Parsing des réponses

Parse la `reqwest::Response` en `BridgeResponse` :
- JSON → `serde_json::Value`
- Texte → `Value::String`
- Vide → `Value::Null`

### 3.7 `executor.rs` — Exécution avec résilience

Point d'entrée : `bridge_call()` → retourne `BridgeCallResult { value, trace }`.

**Résilience piloté par `bridge_errors` :**

| Action | Comportement |
|:---|:---|
| `retry` | Réessayer N fois avec backoff exponentiel |
| `stop` | Arrêter immédiatement, retourner l'erreur mappée |
| `ignore` | Ignorer l'erreur, retourner la réponse telle quelle |
| `map` | Transformer le message d'erreur pour l'utilisateur |
| `circuit_break` | Ouvrir le circuit breaker, bloquer le provider |

**Retry avec backoff :**

```
Tentative 1 → exécution
         └─── 429 (retryable) → attendre 1000ms
Tentative 2 → exécution
         └─── 429 → attendre 2000ms (exponentiel)
Tentative 3 → exécution
         └─── 200 → succès ✅
```

### 3.8 `rate_limit.rs` — Rate Limiter

Rate limiter à **fenêtre glissante** (sliding window) par provider.  
Utilise un `VecDeque<Instant>` pour tracker les timestamps des requêtes.

### 3.9 `hooks.rs` — Système de Hooks

Trait `BridgeHook` avec deux points d'extension :

```rust
trait BridgeHook {
    fn name(&self) -> &str;
    fn pre_request(&self, request: &mut BridgeRequest) -> Result<()>;   // avant l'envoi
    fn post_response(&self, response: &mut BridgeResponse) -> Result<()>; // après réception
}
```

**Hooks built-in actuels :**

| Hook | Type | Description |
|:---|:---|:---|
| `content_type_json` | pré-requête | Ajoute `Content-Type: application/json` si body présent |
| `user_agent` | pré-requête | Ajoute `User-Agent: LyxalBridge/1.0` |

**Hooks à implémenter :**

| Hook | Type | Description |
|:---|:---|:---|
| `hmac_sign` | pré-requête | Signature HMAC (Binance, Stripe) |
| `auto_paginate_cursor` | post-réponse | Pagination cursor-based automatique |
| `auto_paginate_offset` | post-réponse | Pagination offset-based automatique |
| `oauth2_refresh` | pré-requête | Rafraîchissement automatique des tokens |
| `multipart_upload` | pré-requête | Upload de fichiers multipart |
| `xml_conversion` | pré-requête | Conversion JSON → XML |

### 3.10 `trace.rs` — Traçabilité Complète

Chaque appel `bridge::call()` génère un `BridgeTrace` capturant :

```
[brg-195a1f3c-8a4d2b1e] airtable::list_records → ✅ HTTP 200 (47ms, 1 attempts, cache:hit)
```

**Structure de la trace :**

```
BridgeTrace
├── trace_id           "brg-195a1f3c-8a4d2b1e"
├── context
│   ├── provider       "airtable"
│   ├── operation      "list_records"
│   └── source         "surrealql"
├── phases[]
│   ├── [0] resolve_metadata    230μs   ok
│   ├── [1] resolve_auth        120μs   ok
│   ├── [2] build_request       45μs    ok
│   ├── [3] pre_hooks           12μs    ok
│   ├── [4] http_execute        42ms    ok
│   └── [5] post_hooks          8μs     ok
├── request
│   ├── method         "GET"
│   ├── url            "https://api.airtable.com/v0/appXYZ/Contacts"
│   ├── headers        [["Authorization", "Bearer sk-x***key"]]  ← SECRETS MASQUÉS
│   └── body_size      null
├── response
│   ├── status         200
│   ├── body_size      2847
│   └── round_trip_ms  42
├── errors[]           (vide si succès)
├── metrics
│   ├── total_duration_ms       47
│   ├── attempts                1
│   ├── cache_hit               true
│   └── http_round_trip_ms      42
└── outcome            Success { status: 200 }
```

**Masquage des secrets :** Les headers sensibles (`Authorization`, `X-API-Key`, `Cookie`...) sont automatiquement masqués dans la trace :

| Avant | Après |
|:---|:---|
| `Bearer sk-live-12345678abcdef` | `Bearer sk-l***` |
| `Basic dXNlcjpwYXNz` | `Basic ***` |
| `my-super-secret-api-key` | `my-s***-key` |

---

## 4. Câblage SurrealQL {#4-câblage}

Pour que `bridge::call()` soit appelable depuis SurrealQL, 5 fichiers du core Lyxal ont été modifiés :

### 4.1 Parser — `db/syn/parser/builtin.rs`

**+6 lignes** dans la `phf_map!` PATHS (entre `api::*` et `array::*`) :

```rust
UniCase::ascii("bridge::call") => (PathKind::Function, None),
UniCase::ascii("bridge::list") => (PathKind::Function, None),
UniCase::ascii("bridge::info") => (PathKind::Function, None),
UniCase::ascii("bridge::health") => (PathKind::Function, None),
UniCase::ascii("bridge::batch") => (PathKind::Function, None),
```

### 4.2 Routeur — `function/mod.rs`

**3 modifications :**

1. Module : `pub mod bridge;`
2. Async routing : `|| name.starts_with("bridge")`
3. Dispatch : 5 entrées dans `asynchronous()`

### 4.3 Bridge Adapter — `function/bridge.rs` **(NOUVEAU, Phase 3)**

~350 lignes — Branchement complet entre SurrealQL et le moteur `lyxal_bridge` :

- **Conversion `Value` ↔ `serde_json::Value`** — `value_to_json()` et `json_to_value()`
- **Lecture KVS directe** — `read_bridge_record_by_id()` via `ctx.tx().get_record()`
- **Écriture des traces** — `write_bridge_record()` via `ctx.tx().set_record()`
- **Dispatcher de requêtes** — `dispatch_bridge_query()` route les requêtes SQL internes du resolver vers des lectures KVS
- **Persistance des traces** — Chaque appel `bridge::call()` persiste sa `BridgeTrace` dans `bridge_execution_logs`

### 4.6 Dépendance Cargo **(Phase 3)**

`lyxal/core/Cargo.toml` → `lyxal_bridge = { path = "../../lyxal_apps/lyxal_bridge" }`

### 4.4 Streaming Executor — `db/exec/function/builtin/bridge.rs` **(NOUVEAU)**

~60 lignes — Mêmes fonctions avec la macro `define_async_function!`.

### 4.5 Registry — `db/exec/function/builtin/mod.rs`

**+2 lignes :** `mod bridge;` + `bridge::register(registry);`

---

## 5. Système de traçabilité {#5-traçabilité}

### Niveaux de trace

| Niveau | Quand | Émoji | Exemple |
|:---|:---|:---|:---|
| `INFO` | Début/fin d'un appel | 🚀 ✅ | `Bridge call initiated` / `completed` |
| `INFO` | Requête/réponse HTTP | 📤 📥 | `HTTP Request built` / `Response received` |
| `DEBUG` | Détail d'une phase | ▶ ✓ | `Phase started` / `completed` |
| `DEBUG` | Cache hit/miss | 📦 | `Cache HIT` / `Cache MISS` |
| `DEBUG` | Retry backoff | 🔄 | `Retry backoff 2000ms` |
| `WARN` | Erreur HTTP | ⚠ | `HTTP Error response 429` |
| `ERROR` | Échec d'une phase | ✗ ❌ | `Phase failed` / `Bridge call failed` |

### Persistance dans SurrealDB

La table `bridge_execution_logs` stocke chaque `BridgeTrace` avec des index pour :

| Index | Champs | Usage |
|:---|:---|:---|
| `idx_trace_id` | `trace_id` (UNIQUE) | Lookup direct d'une trace |
| `idx_provider_op` | `context.provider, context.operation` | Filtrage par provider/opération |
| `idx_started_at` | `timestamp.started_at` | Tri chronologique |
| `idx_outcome_type` | `outcome.type` | Filtrage succès/erreurs |
| `idx_provider_time` | `context.provider, timestamp.started_at` | Historique par provider |

### Requêtes utiles

```sql
-- Derniers appels
SELECT * FROM bridge_execution_logs ORDER BY timestamp.started_at DESC LIMIT 20;

-- Erreurs des dernières 24h
SELECT * FROM bridge_execution_logs 
WHERE outcome.type != "Success" 
AND timestamp.started_at > time::now() - 24h;

-- Temps moyen par provider
SELECT context.provider, math::mean(metrics.total_duration_ms) AS avg_ms 
FROM bridge_execution_logs 
GROUP BY context.provider;

-- Taux d'erreur par provider
SELECT context.provider,
    count(IF outcome.type = "Success" THEN 1 END) AS success,
    count(IF outcome.type != "Success" THEN 1 END) AS errors
FROM bridge_execution_logs 
GROUP BY context.provider;

-- Trace complète d'un appel spécifique
SELECT * FROM bridge_execution_logs WHERE trace_id = "brg-195a1f3c-8a4d2b1e";

-- Providers avec circuit breaker actif (beaucoup d'erreurs récentes)
SELECT context.provider, count() AS error_count 
FROM bridge_execution_logs 
WHERE outcome.type != "Success" 
AND timestamp.started_at > time::now() - 5m
GROUP BY context.provider
HAVING error_count > 10;
```

---

## 6. Schéma de base de données {#6-schéma-db}

### Tables de référence (données de seed)

| Table | Contenu | Seed |
|:---|:---|:---|
| `bridge_status` | active, inactive, deprecated, maintenance | ✅ |
| `bridge_operations_methods` | GET, POST, PUT, PATCH, DELETE, HEAD... | ✅ |
| `bridge_parameter_locations` | query, header, path, body, cookie | ✅ |
| `bridge_parameter_sources` | static, user, auth, expression | ✅ |
| `bridge_auth_methods` | api_key, bearer, basic, oauth2 | ✅ |

### Tables de configuration (gérées par l'admin)

| Table | Contenu |
|:---|:---|
| `bridge_providers` | Providers (Airtable, Slack, Stripe...) avec URL de base |
| `bridge_operations` | Opérations par provider (list_records, send_message...) |
| `bridge_errors` | Règles d'erreur par opération (retry 429, stop 401...) |
| `bridge_auth_schemas` | Association provider ↔ méthode d'auth (edge table) |

### Tables de données utilisateur

| Table | Contenu |
|:---|:---|
| `bridge_user_credentials` | Credentials chiffrés par utilisateur par provider |

### Tables de monitoring

| Table | Contenu |
|:---|:---|
| `bridge_execution_logs` | Traces d'exécution complètes (**NOUVEAU**) |

---

## 7. Flux d'exécution end-to-end {#7-flux}

```
SurrealQL: bridge::call("airtable", "list_records", { baseId: "appXYZ" })
    │
    ▼
[1] PARSER (builtin.rs)
    PATHS["bridge::call"] → PathKind::Function → parse arguments
    │
    ▼
[2] ROUTEUR (function/mod.rs)
    name.starts_with("bridge") → route vers asynchronous()
    "bridge::call" → bridge::call((stk, ctx, opt, doc)).await
    │
    ▼
[3] ADAPTER (function/bridge.rs)                  ← ✅ Phase 3 FAIT
    ├── Extraire provider, operation, params (Value → String)
    ├── Créer BridgeContext
    ├── Créer closure db_query → dispatch_bridge_query()
    │   └── Dispatche vers ctx.tx().get_record() selon la table
    ├── Appeler lyxal_bridge::bridge_call()
    ├── Persister la trace → bridge_execution_logs
    └── Convertir le résultat (serde_json::Value → Value)
    │
    ▼
[4] EXECUTOR (executor.rs)
    ├── TraceBuilder::new("airtable", "list_records")
    ├── Circuit breaker check
    │   └── BridgeContext::is_provider_allowed()
    │
    ├── [Phase: resolve_metadata]
    │   └── resolver::resolve_operation()
    │       ├── Cache check (DashMap)
    │       ├── SELECT FROM bridge_providers WHERE identity.name = "airtable"
    │       ├── SELECT FROM bridge_operations WHERE identity.name = "list_records"
    │       └── SELECT FROM bridge_errors WHERE relations.operation_id = $oid
    │
    ├── [Phase: resolve_auth]
    │   └── resolver::resolve_auth()
    │       ├── SELECT FROM bridge_user_credentials WHERE provider = $pid
    │       └── Déchiffrement AES-256-GCM → ResolvedAuth
    │
    ├── [Phase: build_request]
    │   └── request::build_request()
    │       ├── Interpolation URL : /v0/{baseId}/{table} → /v0/appXYZ/Contacts
    │       ├── Injection query params : ?limit=10
    │       ├── Injection headers : Authorization: Bearer sk-xxx
    │       └── Détermination body
    │
    ├── [Phase: pre_hooks]
    │   └── HookRegistry::apply_pre_hooks()
    │       ├── content_type_json → Content-Type: application/json
    │       └── user_agent → User-Agent: LyxalBridge/1.0
    │
    ├── [Phase: http_execute]
    │   └── execute_with_resilience()
    │       ├── Rate limit check (sliding window)
    │       ├── reqwest::Client::request(GET, url).send().await
    │       ├── Si 429 → retry avec backoff exponentiel
    │       ├── Si 500 → retry
    │       ├── Si 401 → stop (si règle configurée)
    │       └── response::parse_response() → BridgeResponse
    │
    ├── [Phase: post_hooks]
    │   └── HookRegistry::apply_post_hooks()
    │
    └── Finalisation
        ├── TraceBuilder::finish_success(200) → BridgeTrace
        ├── INSERT INTO bridge_execution_logs (trace serialisée)
        └── return BridgeCallResult { value, trace }
```

---

## 8. Phases du projet {#8-phases}

| Phase | Statut | Description |
|:---|:---|:---|
| **Phase 1** — Crate `lyxal_bridge` | ✅ Fait | 11 fichiers Rust (moteur, cache, retry, hooks, trace) |
| **Phase 2** — Câblage SurrealQL | ✅ Fait | 5 fonctions bridge::* dans parser + dispatcher |
| **Phase 3** — Branchement réel | ✅ Fait | `function/bridge.rs` → `lyxal_bridge::bridge_call()` + traces |
| **Phase 4** — Hooks avancés | 🔲 À faire | HMAC, OAuth2 refresh, auto-pagination |
| **Phase 5** — Tests | 🔲 À faire | Tests unitaires + intégration avec un vrai provider |
| **Phase 6** — Migration | 🔲 À faire | Scripts pour importer des nodes n8n dans bridge_* |

### Phase 3 — Ce qui a été fait

1. ✅ Ajouté `lyxal_bridge` comme dépendance path dans `lyxal/core/Cargo.toml`
2. ✅ Fonctions `value_to_json()` / `json_to_value()` pour conversion SurrealQL ↔ JSON
3. ✅ `read_bridge_record_by_id()` — lecture KVS via `ctx.tx().get_record()`
4. ✅ `write_bridge_record()` — écriture KVS via `ctx.tx().set_record()` pour les traces
5. ✅ `dispatch_bridge_query()` — adaptateur qui route les requêtes SQL internes vers le KVS
6. ✅ `bridge::call()` appelle `lyxal_bridge::bridge_call()` et persiste la trace
7. ✅ `bridge::info()` lit directement un provider par ID via KVS
8. ✅ `bridge::batch()` exécute plusieurs appels séquentiellement

### TODO restants (Phase 3 polish)

- Singleton `BridgeContext` dans le Context SurrealDB (actuellement recréé par appel)
- Scan de table pour `bridge::list()` (nécessite un prefix scan KVS)
- `bridge::health()` — lire l'URL de base depuis le provider puis HEAD request

---

## Documents connexes

| Document | Description |
|:---|:---|
| [architecture_bridge_async_fn.md](./architecture_bridge_async_fn.md) | Design architectural — le "pourquoi" |
| [guide_ajout_builtin_function.md](./guide_ajout_builtin_function.md) | Guide pour ajouter des fonctions — le "comment" |
| [complex_logic_patterns.md](./complex_logic_patterns.md) | Patterns pour logique complexe |
| [internal_dependencies.md](./internal_dependencies.md) | Dépendances internes |
| [lyxal_bridge.md](./lyxal_bridge.md) | Vue d'ensemble originale |

---

*Ce document fait partie de la documentation technique de Lyxal Solution.*
