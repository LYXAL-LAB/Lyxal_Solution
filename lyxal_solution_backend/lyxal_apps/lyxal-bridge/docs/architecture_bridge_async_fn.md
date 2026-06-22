# Architecture : Lyxal Bridge — Moteur Async Dynamique

> **Date :** 2026-03-30  
> **Statut :** Proposition architecturale  
> **Auteur :** Analyse comparative n8n / lyxal_core_connector / lyxal_bridge

---

## 1. Contexte et Vision

### 1.1 Le Problème avec n8n

n8n est un puissant outil d'automatisation, mais son architecture présente des limitations fondamentales :

| Limitation n8n | Impact |
|:---|:---|
| ~500 fichiers TypeScript (1 par node/provider) | Maintenance cauchemardesque |
| Logique JS hardcodée par node | Impossible d'ajouter un provider sans coder |
| Runtime Node.js lourd | Performance limitée, consommation mémoire élevée |
| Chaque node embarque son propre SDK | Dépendances explosives, conflits de versions |
| Pas de hot-reload | Redéploiement nécessaire pour chaque modification |

### 1.2 La Vision Lyxal Bridge

Remplacer l'approche "1 fichier de code par provider" par un **moteur unique générique en Rust** piloté par des **métadonnées dynamiques stockées en base de données** (SurrealDB).

**Principe fondamental :**
```
n8n  = 500 fichiers de code × 1 runtime   → N logiques hardcodées
Lyxal = 1 moteur Rust      × N données DB → N providers dynamiques
```

---

## 2. Les 3 Pièces du Puzzle

### 2.1 Pièce 1 : n8n (Source d'Inspiration)

**Emplacement :** `n8n-n8n-2.6.0/`

Sert uniquement de **référence** pour identifier :
- La liste exhaustive des providers à supporter
- Les patterns de logique complexe (pagination, auth, signing)
- Les schémas d'opérations par provider

**⚠️ À NE PAS porter tel quel** — on ne traduit pas du TypeScript en Rust, on extrait les métadonnées.

### 2.2 Pièce 2 : Lyxal Bridge (Data Layer — SurrealDB)

**Emplacement :** `lyxal_apps/lyxal_bridge/database/`

Le schéma de base de données qui stocke **toutes les métadonnées** nécessaires pour exécuter n'importe quel appel API sans code custom :

| Table | Rôle | État |
|:---|:---|:---|
| `bridge_providers` | Catalogue des services externes (Airtable, Slack, Stripe...) | ✅ Prêt |
| `bridge_operations` | Actions disponibles par provider (list_records, send_message...) | ✅ Prêt |
| `bridge_auth_methods` | Méthodes d'auth supportées (api_key, oauth2, bearer, basic) | ✅ Prêt |
| `bridge_auth_schemas` | Relation provider ↔ méthode d'auth (graph SurrealDB) | ✅ Prêt |
| `bridge_errors` | Moteur de décision d'erreurs (retry, stop, circuit_break...) | ✅ Prêt |
| `bridge_operations_methods` | Référentiel des méthodes HTTP | ✅ Prêt |
| `bridge_parameter_locations` | Référentiel des emplacements de paramètres | ✅ Prêt |
| `bridge_parameter_sources` | Référentiel des sources de valeurs | ✅ Prêt |
| `bridge_status` | Statuts possibles (active, inactive, deprecated) | ✅ Prêt |
| `bridge_user_credentials` | Credentials chiffrés par utilisateur | ✅ Prêt |
| `bridge_logs` | Historique d'exécution | ✅ Prêt |

### 2.3 Pièce 3 : Lyxal Core Connector (Execution Layer — Rust)

**Emplacement :** `a_reprendre/lyxal_core_connector/src/`

Le code Rust existant qui implémentait l'exécution HTTP via `DEFINE CONNECTOR`. Ce code contient de la **logique réutilisable de haute qualité** :

| Fichier | Contenu | Réutilisable ? |
|:---|:---|:---|
| `invocation.rs` | Interpolation URL, construction requête, retry loop, error mapping | ✅ Oui — cœur du moteur |
| `request.rs` | Structure `ConnectorRequest` (url, method, headers, body, timeout) | ✅ Oui — renommer en `BridgeRequest` |
| `response.rs` | Structure `ConnectorResponse` + conversion en Value | ✅ Oui — renommer en `BridgeResponse` |
| `rate_limit.rs` | Rate limiter sliding window par connector | ✅ Oui — garder tel quel |
| `err.rs` | Re-export des erreurs | ✅ Oui — enrichir avec `bridge_errors` |

---

## 3. Décision Architecturale : Retirer `DEFINE CONNECTOR`

### 3.1 Pourquoi retirer `DEFINE CONNECTOR` ?

L'ancien système `DEFINE CONNECTOR` nécessitait de modifier **~15 fichiers** dans le cœur du parser/KVS de SurrealDB :

```
Fichiers impactés par DEFINE CONNECTOR (à supprimer) :
├── Parser/Lexer
│   ├── syn/lexer/keywords.rs          (mot-clé CONNECTOR)
│   ├── syn/token/keyword.rs           (token CONNECTOR)
│   ├── syn/parser/stmt/define.rs      (parsing DEFINE CONNECTOR)
│   ├── syn/parser/stmt/remove.rs      (parsing REMOVE CONNECTOR)
│   └── syn/parser/builtin.rs          (connector::call dans PATHS)
├── Catalogue/Schéma
│   ├── catalog/schema/connector.rs    (ConnectorDefinition)
│   ├── catalog/providers.rs           (ConnectorProvider)
│   └── catalog/aggregation.rs         (agrégation connectors)
├── Statements
│   ├── expr/statements/define/connector.rs
│   ├── expr/statements/remove/connector.rs
│   ├── sql/statements/define/connector.rs
│   └── sql/statements/remove/connector.rs
├── KVS
│   ├── key/database/cn.rs             (clé KVS cn:)
│   ├── kvs/tx.rs                      (sauvegarde/cache)
│   └── cache/tx/entry.rs             (entrée cache Cns)
└── Sécurité
    └── iam/entities/resources/resource.rs (ResourceKind::Connector)
```

**Le problème** : toute cette complexité existe uniquement pour stocker des métadonnées dans le KVS. Or, ces métadonnées sont **déjà stockées** dans les tables `bridge_*` de SurrealDB, de manière plus riche et plus flexible.

### 3.2 Comparaison directe

| Aspect | `DEFINE CONNECTOR` (ancien) | `async fn` dynamique (nouveau) |
|:---|:---|:---|
| Stockage métadonnées | KVS interne (clé `cn:`) | SurrealDB (tables `bridge_*`) |
| Ajout d'un provider | Modifier le parser + écrire du SQL | Simple `INSERT INTO bridge_providers` |
| Modification runtime | Impossible (compilé dans le binaire) | Hot-reload depuis la DB |
| Complexité parser | ~15 fichiers modifiés dans `lyxal_core_db` | 0 modifications au parser |
| Migration n8n | Manuelle, provider par provider | Scriptable : JSON → `INSERT` en lot |
| Flexibilité auth | Enum Rust fixe (`Bearer`, `Basic`, `ApiKey`) | Dynamique via `bridge_auth_schemas` |
| Gestion erreurs | `ON ERROR` statique dans le DEFINE | `bridge_errors` avec circuit breaker |
| Testabilité | Nécessite le runtime SurrealDB complet | Testable en isolation avec mock DB |

### 3.3 Décision

> **RETIRER `DEFINE CONNECTOR`** du parser/KVS et le remplacer par une **`async fn bridge_call()`** qui résout tout dynamiquement depuis les tables `bridge_*`.

---

## 4. Architecture Cible

### 4.1 Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────┐
│                    SurrealQL (Appel Utilisateur)             │
│                                                              │
│  bridge::call("airtable", "list_records", { baseId: "x" })  │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                 Rust Runtime — lyxal_bridge                  │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ resolve_     │  │ build_       │  │ execute_with_    │   │
│  │ operation()  │──│ request()    │──│ resilience()     │   │
│  │              │  │              │  │                  │   │
│  │ Lit la DB:   │  │ Interpole:   │  │ Retry, backoff,  │   │
│  │ - provider   │  │ - URL path   │  │ rate limit,      │   │
│  │ - opération  │  │ - Auth       │  │ circuit breaker  │   │
│  │ - auth       │  │ - Headers    │  │                  │   │
│  └──────────────┘  │ - Body       │  └──────────────────┘   │
│         │          └──────────────┘           │              │
│         │                                    │              │
│         ▼                                    ▼              │
│  ┌──────────────┐                 ┌──────────────────┐      │
│  │ Cache LRU    │                 │ reqwest::Client   │      │
│  │ (DashMap)    │                 │ (pool connexions) │      │
│  └──────────────┘                 └──────────────────┘      │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Hooks / Middlewares (pour logique complexe)           │   │
│  │ - hmac_sign, auto_paginate, oauth2_refresh, etc.     │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                 SurrealDB — Tables bridge_*                  │
│                                                              │
│  bridge_providers ──→ bridge_operations                      │
│        │                    │                                │
│        ▼                    ▼                                │
│  bridge_auth_schemas   bridge_errors                         │
│        │                                                     │
│        ▼                                                     │
│  bridge_auth_methods                                         │
│                                                              │
│  bridge_user_credentials   bridge_logs                       │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Signature de la Fonction Principale

```rust
/// Point d'entrée unique du Lyxal Bridge.
///
/// Remplace l'ancien `DEFINE CONNECTOR` + `connector::call()`.
/// Tout est résolu dynamiquement depuis les tables bridge_*.
///
/// ## Appel depuis SurrealQL
/// ```sql
/// bridge::call("airtable", "list_records", { baseId: "appXYZ", limit: 10 })
/// ```
///
/// ## Appel depuis un EVENT
/// ```sql
/// DEFINE EVENT order_placed ON TABLE orders WHEN $event = 'CREATE' THEN {
///     bridge::call("slack", "send_message", {
///         channel: "sales",
///         text: "Nouvelle commande: " + $after.id
///     });
/// };
/// ```
pub async fn bridge_call(
    ctx: &BridgeContext,       // connexion DB + client HTTP réutilisable
    provider_name: &str,       // "airtable", "slack", "stripe"...
    operation_name: &str,      // "list_records", "send_message"...
    params: serde_json::Value, // paramètres utilisateur
) -> Result<serde_json::Value, BridgeError> {
    // 1. Résoudre le provider + opération depuis la DB (avec cache)
    let (provider, operation) = resolve_operation(ctx, provider_name, operation_name).await?;

    // 2. Résoudre l'auth (credentials chiffrés de l'utilisateur)
    let auth = resolve_auth(ctx, &provider).await?;

    // 3. Construire la requête HTTP dynamiquement
    let request = build_request(&provider, &operation, &auth, &params)?;

    // 4. Appliquer les hooks pré-requête (HMAC, nonce, token refresh...)
    let request = apply_pre_hooks(ctx, &operation, request).await?;

    // 5. Exécuter avec résilience (retry, rate limit, circuit breaker)
    let error_rules = resolve_error_rules(ctx, &operation).await?;
    let response = execute_with_resilience(ctx, &request, &error_rules).await?;

    // 6. Appliquer les hooks post-réponse (pagination, normalisation...)
    let response = apply_post_hooks(ctx, &operation, response).await?;

    // 7. Logger l'exécution
    log_execution(ctx, &provider, &operation, &response).await;

    Ok(response)
}
```

### 4.3 Structure du BridgeContext

```rust
/// Contexte partagé du Bridge, créé une fois au démarrage du serveur.
pub struct BridgeContext {
    /// Connexion à SurrealDB pour lire les métadonnées
    db: Surreal<Any>,

    /// Client HTTP réutilisable (pool de connexions TCP)
    http_client: reqwest::Client,

    /// Cache LRU des métadonnées providers/opérations
    /// Clé: "provider_name:operation_name"
    /// TTL: configurable (défaut 5 minutes)
    cache: DashMap<String, CachedMetadata>,

    /// Registre des hooks disponibles
    hooks: HookRegistry,

    /// Rate limiters par provider (sliding window)
    rate_limiters: DashMap<String, RateLimiterState>,
}
```

---

## 5. Flux d'Exécution Détaillé

### 5.1 Résolution de l'Opération

```rust
async fn resolve_operation(
    ctx: &BridgeContext,
    provider_name: &str,
    operation_name: &str,
) -> Result<(BridgeProvider, BridgeOperation), BridgeError> {
    // 1. Vérifier le cache
    let cache_key = format!("{}:{}", provider_name, operation_name);
    if let Some(cached) = ctx.cache.get(&cache_key) {
        if !cached.is_expired() {
            return Ok(cached.clone_data());
        }
    }

    // 2. Requête SurrealDB
    let provider: Option<BridgeProvider> = ctx.db.query(
        "SELECT * FROM bridge_providers
         WHERE identity.name = $name
         AND status.status = bridge_status:active"
    ).bind(("name", provider_name)).await?;

    let provider = provider.ok_or(BridgeError::ProviderNotFound {
        name: provider_name.to_string(),
    })?;

    let operation: Option<BridgeOperation> = ctx.db.query(
        "SELECT * FROM bridge_operations
         WHERE relations.provider_id = $pid
         AND identity.name = $op
         AND status.status = bridge_status:active"
    ).bind(("pid", &provider.id))
     .bind(("op", operation_name))
     .await?;

    let operation = operation.ok_or(BridgeError::OperationNotFound {
        provider: provider_name.to_string(),
        operation: operation_name.to_string(),
    })?;

    // 3. Mettre en cache
    ctx.cache.insert(cache_key, CachedMetadata::new(&provider, &operation));

    Ok((provider, operation))
}
```

### 5.2 Construction Dynamique de la Requête

La force de cette architecture réside dans la construction **entièrement dynamique** de la requête HTTP à partir des métadonnées de `bridge_operations.configuration.parameters` :

```rust
fn build_request(
    provider: &BridgeProvider,
    operation: &BridgeOperation,
    auth: &BridgeAuth,
    params: &serde_json::Value,
) -> Result<BridgeRequest, BridgeError> {
    let base_url = &provider.configuration.endpoint_base_url;
    let mut path = operation.configuration.path.clone();
    let mut query_params: Vec<(String, String)> = Vec::new();
    let mut headers: HashMap<String, String> = HashMap::new();
    let mut body_fields: serde_json::Map<String, serde_json::Value> = serde_json::Map::new();

    // Itérer sur chaque paramètre défini dans bridge_operations
    for param_def in &operation.configuration.parameters {
        // Résoudre la valeur selon le value_type
        let value = match param_def.value_type.as_str() {
            "static" => {
                // Valeur fixe définie dans la DB
                param_def.value.clone()
            }
            "user" => {
                // Valeur fournie par l'utilisateur dans params
                params.get(&param_def.name)
                    .map(|v| v.as_str().unwrap_or_default().to_string())
            }
            "auth" => {
                // Valeur extraite des credentials
                auth.get_field(&param_def.name)
            }
            "expression" => {
                // Expression SurrealQL évaluée dynamiquement
                // (future: évaluer via le moteur SurrealQL)
                param_def.value.clone()
            }
            _ => None,
        };

        let value = match value {
            Some(v) => v,
            None if param_def.required => {
                return Err(BridgeError::MissingParameter {
                    provider: provider.identity.name.clone(),
                    operation: operation.identity.name.clone(),
                    param: param_def.name.clone(),
                });
            }
            None => continue, // paramètre optionnel absent, on skip
        };

        // Injecter la valeur au bon endroit selon param_def.in
        match param_def.location.as_str() {
            "path" => {
                // Interpolation dans le chemin URL : /v0/{baseId}/... → /v0/appXYZ/...
                let placeholder = format!("{{{}}}", param_def.name);
                path = path.replace(&placeholder, &value);
            }
            "query" => {
                // Paramètre de query string : ?limit=10&offset=0
                query_params.push((param_def.name.clone(), value));
            }
            "header" => {
                // Header HTTP : X-API-Version: v1
                headers.insert(param_def.name.clone(), value);
            }
            "body" => {
                // Champ dans le corps JSON
                body_fields.insert(
                    param_def.name.clone(),
                    serde_json::Value::String(value),
                );
            }
            "cookie" => {
                // Cookie HTTP (rare mais supporté)
                headers.entry("Cookie".to_string())
                    .and_modify(|c| { c.push_str(&format!("; {}={}", param_def.name, value)); })
                    .or_insert_with(|| format!("{}={}", param_def.name, value));
            }
            _ => {} // location inconnue, ignorer
        }
    }

    // Vérifier les placeholders non résolus dans le path
    if path.contains('{') {
        let start = path.find('{').unwrap();
        let end = path[start..].find('}').unwrap_or(0);
        let missing = &path[start + 1..start + end];
        return Err(BridgeError::MissingParameter {
            provider: provider.identity.name.clone(),
            operation: operation.identity.name.clone(),
            param: missing.to_string(),
        });
    }

    // Construire l'URL finale
    let mut url = format!(
        "{}{}",
        base_url.trim_end_matches('/'),
        path
    );
    if !query_params.is_empty() {
        let qs: String = query_params
            .iter()
            .map(|(k, v)| format!("{}={}", k, v))
            .collect::<Vec<_>>()
            .join("&");
        url = format!("{}?{}", url, qs);
    }

    // Injecter l'auth dans les headers
    inject_auth_headers(&mut headers, auth)?;

    // Déterminer le body
    let body = if body_fields.is_empty() {
        // Si pas de champs body définis, utiliser le body_template
        if !operation.configuration.body_template.is_empty() {
            Some(serde_json::Value::Object(
                merge_template(&operation.configuration.body_template, params)
            ))
        } else {
            None
        }
    } else {
        Some(serde_json::Value::Object(body_fields))
    };

    Ok(BridgeRequest {
        url,
        method: operation.configuration.method.clone(),
        headers,
        body,
        timeout_ms: None, // TODO: configurable par opération
    })
}
```

### 5.3 Exécution avec Résilience

```rust
async fn execute_with_resilience(
    ctx: &BridgeContext,
    request: &BridgeRequest,
    error_rules: &[BridgeErrorRule],
) -> Result<serde_json::Value, BridgeError> {
    // Déterminer la stratégie de retry applicable
    let retry_rule = error_rules.iter()
        .find(|r| r.configuration.action == "retry");

    let max_attempts = retry_rule
        .map(|r| r.resilience.max_attempts)
        .unwrap_or(1);

    let backoff_ms = retry_rule
        .map(|r| r.resilience.backoff_ms)
        .unwrap_or(1000);

    let exponential = retry_rule
        .map(|r| r.resilience.exponential)
        .unwrap_or(true);

    let mut last_error: Option<BridgeError> = None;

    for attempt in 0..max_attempts {
        // Backoff delay (skip premier essai)
        if attempt > 0 && backoff_ms > 0 {
            let delay = if exponential {
                backoff_ms * (1u64 << attempt.saturating_sub(1))
            } else {
                backoff_ms
            };
            tokio::time::sleep(Duration::from_millis(delay as u64)).await;
        }

        // Rate limiting
        check_rate_limit(ctx, &request.provider_name)?;

        // Exécution HTTP
        match execute_http(ctx, request).await {
            Ok(response) => {
                let status = response.status;

                // Chercher une règle d'erreur qui matche ce status code
                if let Some(rule) = error_rules.iter()
                    .find(|r| r.triggers.http_code == Some(status as i64) && r.status.is_active)
                {
                    match rule.configuration.action.as_str() {
                        "retry" if attempt < max_attempts - 1 => {
                            last_error = Some(BridgeError::RetryableError {
                                status,
                                attempt: attempt + 1,
                            });
                            continue;
                        }
                        "stop" => {
                            return Err(BridgeError::StoppedByRule {
                                status,
                                message: rule.configuration.mapped_message.clone()
                                    .unwrap_or_default(),
                            });
                        }
                        "ignore" => {
                            // Continuer comme si c'était un succès
                            return Ok(response.body);
                        }
                        "map" => {
                            return Err(BridgeError::MappedError {
                                message: rule.configuration.mapped_message.clone()
                                    .unwrap_or_else(|| format!("HTTP {}", status)),
                            });
                        }
                        "circuit_break" => {
                            // Marquer le provider comme temporairement bloqué
                            ctx.circuit_breakers.insert(
                                request.provider_name.clone(),
                                CircuitState::Open(Instant::now()),
                            );
                            return Err(BridgeError::CircuitBreakerOpen {
                                provider: request.provider_name.clone(),
                            });
                        }
                        _ => {}
                    }
                }

                // Erreur HTTP standard (pas de règle custom)
                if status >= 400 {
                    return Err(BridgeError::HttpError {
                        status,
                        body: response.body.to_string(),
                    });
                }

                // Succès
                return Ok(response.body);
            }
            Err(e) => {
                last_error = Some(e);
                if attempt >= max_attempts - 1 {
                    break;
                }
            }
        }
    }

    // Tous les retries épuisés
    Err(last_error.unwrap_or(BridgeError::RetriesExhausted {
        attempts: max_attempts,
    }))
}
```

---

## 6. Système de Hooks (Logique Complexe)

### 6.1 Le Problème

Certains providers nécessitent de la logique **au-delà** d'un simple appel HTTP générique :

| Pattern | Description | Providers Concernés |
|:---|:---|:---|
| **HMAC Signing** | Signature du corps avec clé secrète + timestamp | Binance, Stripe, AWS SigV4 |
| **Multipart/Form-Data** | Upload de fichiers + métadonnées JSON | Google Drive, Slack Upload |
| **Auto-Pagination (cursor)** | Boucle automatique avec `next_cursor` | Slack, Stripe, Twitter |
| **Auto-Pagination (offset)** | Incrémentation de l'offset | Airtable, SQL-based APIs |
| **OAuth2 Token Refresh** | Échange refresh_token → access_token si expiré | Google, Microsoft, GitHub |
| **XML/SOAP Conversion** | Conversion JSON → XML | APIs bancaires, legacy |
| **Base64 Encoding** | Encodage binaire dans le JSON | GitHub Content API |
| **Nonce Generation** | Nombre unique anti-replay | APIs crypto |

### 6.2 Solution : Trait BridgeHook

```rust
/// Trait pour les hooks de logique complexe.
///
/// Chaque hook est enregistré par nom dans le HookRegistry et peut être
/// référencé dans bridge_operations.configuration via un champ hooks[].
#[async_trait]
pub trait BridgeHook: Send + Sync {
    /// Nom unique du hook (ex: "hmac_sign", "auto_paginate_cursor")
    fn name(&self) -> &str;

    /// Transformation pré-requête (modifier headers, body, URL...)
    async fn pre_request(
        &self,
        ctx: &BridgeContext,
        operation: &BridgeOperation,
        request: &mut BridgeRequest,
    ) -> Result<(), BridgeError> {
        Ok(()) // par défaut : no-op
    }

    /// Transformation post-réponse (pagination, normalisation, extraction...)
    async fn post_response(
        &self,
        ctx: &BridgeContext,
        operation: &BridgeOperation,
        response: &mut BridgeResponse,
    ) -> Result<(), BridgeError> {
        Ok(()) // par défaut : no-op
    }
}
```

### 6.3 Exemples de Hooks

```rust
/// Hook HMAC pour signer les requêtes (Binance, Stripe...)
struct HmacSignHook;

#[async_trait]
impl BridgeHook for HmacSignHook {
    fn name(&self) -> &str { "hmac_sign" }

    async fn pre_request(
        &self,
        ctx: &BridgeContext,
        operation: &BridgeOperation,
        request: &mut BridgeRequest,
    ) -> Result<(), BridgeError> {
        let secret = ctx.get_auth_field("hmac_secret").await?;
        let timestamp = chrono::Utc::now().timestamp_millis().to_string();
        let payload = format!("{}{}", timestamp, request.body_as_string());

        let signature = hmac_sha256(&secret, &payload);

        request.headers.insert("X-Timestamp".into(), timestamp);
        request.headers.insert("X-Signature".into(), signature);
        Ok(())
    }
}

/// Hook Auto-Pagination (cursor-based)
struct AutoPaginateCursorHook;

#[async_trait]
impl BridgeHook for AutoPaginateCursorHook {
    fn name(&self) -> &str { "auto_paginate_cursor" }

    async fn post_response(
        &self,
        ctx: &BridgeContext,
        operation: &BridgeOperation,
        response: &mut BridgeResponse,
    ) -> Result<(), BridgeError> {
        let mut all_records = Vec::new();
        let mut current_response = response.body.clone();

        loop {
            // Extraire les records de la page courante
            if let Some(records) = current_response.get("records") {
                if let Some(arr) = records.as_array() {
                    all_records.extend(arr.clone());
                }
            }

            // Vérifier s'il y a une page suivante
            let next_cursor = current_response
                .get("next_cursor")
                .or_else(|| current_response.get("offset"))
                .and_then(|v| v.as_str());

            match next_cursor {
                Some(cursor) if !cursor.is_empty() => {
                    // Relancer la requête avec le nouveau cursor
                    let mut next_request = response.original_request.clone();
                    next_request.add_query_param("cursor", cursor);
                    let next_resp = execute_http(ctx, &next_request).await?;
                    current_response = next_resp.body;
                }
                _ => break, // plus de pages
            }
        }

        // Fusionner tous les records
        response.body = serde_json::json!({ "records": all_records });
        Ok(())
    }
}
```

### 6.4 Référencement dans la DB

Les hooks sont référencés dans `bridge_operations.configuration` :

```sql
-- Exemple : opération Binance avec HMAC signing
INSERT INTO bridge_operations {
    relations: { provider_id: bridge_providers:binance },
    identity: { name: "get_account" },
    affichage: { display_name: "Get Account Info" },
    configuration: {
        method: bridge_operations_methods:get,
        path: "/api/v3/account",
        parameters: [
            { name: "timestamp", in: "query", value_type: "expression", value: "time::millis()" },
            { name: "X-MBX-APIKEY", in: "header", value_type: "auth", required: true }
        ],
        hooks: ["hmac_sign"]  -- ← référence au hook Rust
    }
};
```

---

## 7. Gestion de la Performance

### 7.1 Cache des Métadonnées

Le cache évite de requêter SurrealDB à chaque appel `bridge::call()` :

```rust
struct CachedMetadata {
    provider: BridgeProvider,
    operation: BridgeOperation,
    error_rules: Vec<BridgeErrorRule>,
    cached_at: Instant,
    ttl: Duration,
}

impl CachedMetadata {
    fn is_expired(&self) -> bool {
        self.cached_at.elapsed() > self.ttl
    }
}
```

**Stratégie d'invalidation :**
- TTL par défaut : 5 minutes
- Invalidation explicite via : `bridge::cache_clear("airtable")`
- Invalidation automatique via un EVENT SurrealDB sur les tables `bridge_*`

### 7.2 Pool de Connexions HTTP

```rust
// Le reqwest::Client est créé UNE SEULE FOIS et partagé
let http_client = reqwest::Client::builder()
    .pool_max_idle_per_host(10)     // max 10 connexions idle par host
    .pool_idle_timeout(Duration::from_secs(90))
    .timeout(Duration::from_secs(30))
    .build()?;
```

### 7.3 Rate Limiting par Provider

Le rate limiter existant de `lyxal_core_connector` est réutilisé tel quel (sliding window) avec les limites lues depuis la DB :

```rust
// Le rate limit pourrait être défini dans bridge_providers.configuration
// Exemple : { rate_limit: { requests: 100, per_seconds: 60 } }
```

---

## 8. Intégration SurrealQL

### 8.1 Enregistrement comme Built-in Function

La fonction `bridge::call()` sera enregistrée dans `lyxal_core_functions` :

```rust
// Dans lyxal_core_functions/src/bridge/mod.rs

/// bridge::call(provider, operation, params) -> Value
pub(crate) async fn call(args: Vec<Value>) -> Result<Value> {
    let provider_name = args[0].as_str()?;
    let operation_name = args[1].as_str()?;
    let params = value_to_json(&args[2]);

    let ctx = get_bridge_context().await;
    let result = bridge_call(&ctx, provider_name, operation_name, params).await?;

    Ok(json_to_value(result))
}

/// bridge::list() -> Array<Value>
/// Liste tous les providers actifs
pub async fn list(_args: Vec<Value>) -> Result<Value> { ... }

/// bridge::info(provider) -> Value
/// Détails d'un provider et ses opérations
pub async fn info(args: Vec<Value>) -> Result<Value> { ... }

/// bridge::health(provider) -> Value
/// Ping la base_url du provider
pub async fn health(args: Vec<Value>) -> Result<Value> { ... }

/// bridge::batch(calls) -> Array<Value>
/// Exécution en lot de plusieurs appels
pub async fn batch(args: Vec<Value>) -> Result<Value> { ... }
```

### 8.2 Exemples d'Utilisation SurrealQL

```sql
-- Appel simple
LET $records = bridge::call("airtable", "list_records", {
    baseId: "appXYZ",
    table: "Contacts",
    limit: 10
});

-- Dans un EVENT (réaction à un changement en DB)
DEFINE EVENT order_placed ON TABLE orders WHEN $event = 'CREATE' THEN {
    bridge::call("slack", "send_message", {
        channel: "sales-notifications",
        text: "Nouvelle commande ! ID: " + $after.id
    });

    bridge::call("sendgrid", "send_email", {
        to: $after.customer_email,
        subject: "Confirmation de commande",
        body: "Merci pour votre commande #" + $after.id
    });
};

-- Vérifier la santé d'un provider
LET $health = bridge::health("stripe");

-- Lister tous les providers disponibles
LET $providers = bridge::list();
```

---

## 9. Plan de Migration

### Phase 1 : Créer le module Rust `lyxal_bridge` (Execution Layer)

- [ ] Copier et adapter `invocation.rs` → `bridge/executor.rs`
- [ ] Copier et adapter `request.rs` → `bridge/request.rs`
- [ ] Copier et adapter `response.rs` → `bridge/response.rs`
- [ ] Copier `rate_limit.rs` → `bridge/rate_limit.rs`
- [ ] Créer `bridge/context.rs` (BridgeContext avec cache + pool HTTP)
- [ ] Créer `bridge/resolver.rs` (résolution depuis les tables bridge_*)
- [ ] Créer `bridge/error.rs` (BridgeError enrichi)
- [ ] Créer `bridge/hooks/mod.rs` (trait + registre)

### Phase 2 : Enregistrer `bridge::call()` comme built-in

- [ ] Créer `lyxal_core_functions/src/bridge/mod.rs`
- [ ] Ajouter `bridge::call`, `bridge::list`, `bridge::info`, `bridge::health`, `bridge::batch`
- [ ] Mettre à jour la dispatch table dans `lyxal_core_functions/src/lib.rs`
- [ ] **NE PAS** toucher au parser/lexer

### Phase 3 : Retirer `DEFINE CONNECTOR`

- [ ] Supprimer les ~15 fichiers liés au parser CONNECTOR
- [ ] Retirer le préfixe `cn:` du KVS
- [ ] Nettoyer les imports et les modules

### Phase 4 : Implémenter les Hooks prioritaires

- [ ] `oauth2_refresh` — Rafraîchissement automatique des tokens
- [ ] `hmac_sign` — Signature HMAC pour les APIs crypto/fintech
- [ ] `auto_paginate_cursor` — Pagination automatique cursor-based
- [ ] `auto_paginate_offset` — Pagination automatique offset-based
- [ ] `multipart_upload` — Upload de fichiers

### Phase 5 : Migration des Providers n8n

- [ ] Script d'extraction : n8n node metadata → JSON
- [ ] Script d'import : JSON → `INSERT INTO bridge_providers/operations/...`
- [ ] Validation provider par provider

---

## 10. Correspondance n8n → Lyxal

| Concept n8n | Équivalent Lyxal Bridge |
|:---|:---|
| Node (ex: Google Sheets) | `bridge_providers` + `bridge_operations` |
| Credentials (OAuth2, API Key) | `bridge_auth_methods` + `bridge_auth_schemas` + `bridge_user_credentials` |
| Node Execute Function (JS) | `async fn bridge_call()` (Rust, générique) |
| Error Trigger | `bridge_errors` (moteur de décision) |
| Retry Logic | `bridge_errors.resilience` (configurable par erreur) |
| Cron Trigger | `DEFINE EVENT` SurrealQL |
| Webhook Trigger | `lyxal_api` (inbound, module séparé) |
| Workflow (chaîne de nodes) | Séquence de `bridge::call()` dans un EVENT ou une FUNCTION |

---

*Ce document fait partie de la documentation technique de Lyxal Solution — Module Bridge.*
