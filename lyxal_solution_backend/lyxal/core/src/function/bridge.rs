//! Bridge functions callable from SurrealQL.
//!
//! These functions provide outbound API call capabilities:
//! - `bridge::call(provider, operation, params)` — Execute an API call
//! - `bridge::list()` — List active providers
//! - `bridge::info(provider)` — Get provider details
//! - `bridge::health(provider)` — Check provider connectivity
//! - `bridge::batch(calls)` — Execute multiple calls in parallel
//!
//! ## Architecture de branchement
//!
//! ```text
//! SurrealQL "bridge::call(...)"
//!   → function/bridge.rs (CE FICHIER)
//!     → valide les arguments
//!     → récupère le BridgeContext depuis le contexte SurrealDB
//!     → crée une closure db_query qui utilise get_record/set_record
//!     → appelle lyxal_bridge::bridge_call()
//!     → persiste la trace dans bridge_execution_logs
//!     → retourne le résultat comme Value SurrealQL
//! ```

use std::sync::Arc;

use anyhow::Result;
use reblessive::tree::Stk;

use crate::db::catalog::providers::TableProvider;
use crate::db::ctx::FrozenContext;
use crate::db::dbs::Options;
use crate::db::doc::CursorDoc;
use crate::db::val::{Array, Number, Object, RecordIdKey, TableName, Value};
use crate::error::Error;
use lyxal_types::ToSql;

// =========================================================================
// Conversion Value ↔ serde_json::Value
// =========================================================================

/// Convertit un Value SurrealQL en serde_json::Value.
fn value_to_json(val: &Value) -> serde_json::Value {
    match val {
        Value::None | Value::Null => serde_json::Value::Null,
        Value::Bool(b) => serde_json::Value::Bool(*b),
        Value::String(s) => serde_json::Value::String(s.to_string()),
        Value::Number(n) => {
            match n {
                // Si c'est un entier
                Number::Int(i) => serde_json::Value::Number(serde_json::Number::from(*i)),
                
                // Si c'est un flottant
                Number::Float(f) => serde_json::Number::from_f64(*f)
                    .map(serde_json::Value::Number)
                    .unwrap_or(serde_json::Value::Null),
                    
                // Si c'est un Decimal (si ton Core le supporte)
                Number::Decimal(d) => serde_json::Value::String(d.to_string()),
                
                // Par défaut
                _ => serde_json::Value::Null,
            }
        }
        Value::Object(obj) => {
            let map: serde_json::Map<String, serde_json::Value> = obj
                .iter()
                .map(|(k, v)| (k.to_string(), value_to_json(v)))
                .collect();
            serde_json::Value::Object(map)
        }
        Value::Array(arr) => {
            let items: Vec<serde_json::Value> = arr.iter().map(value_to_json).collect();
            serde_json::Value::Array(items)
        }
        Value::RecordId(rid) => serde_json::Value::String(rid.to_sql()),
        _ => serde_json::Value::String(val.to_sql()),
    }
}

/// Convertit un serde_json::Value en Value SurrealQL.
fn json_to_value(val: serde_json::Value) -> Value {
    match val {
        serde_json::Value::Null => Value::None,
        serde_json::Value::Bool(b) => Value::Bool(b),
        serde_json::Value::Number(n) => {
            if let Some(i) = n.as_i64() {
                Value::from(i)
            } else if let Some(f) = n.as_f64() {
                Value::from(f)
            } else {
                Value::None
            }
        }
        serde_json::Value::String(s) => Value::String(s.into()),
        serde_json::Value::Array(arr) => {
            let items: Vec<Value> = arr.into_iter().map(json_to_value).collect();
            Value::Array(Array::from(items))
        }
        serde_json::Value::Object(obj) => {
            let mut surreal_obj = Object::default();
            for (k, v) in obj {
                surreal_obj.insert(k, json_to_value(v));
            }
            Value::Object(surreal_obj)
        }
    }
}

// =========================================================================
// Lecture directe des records bridge_* via la transaction KVS
// =========================================================================

/// Lit tous les records d'une table bridge_* et les retourne en JSON.
/// Utilise la transaction KVS interne — pas de requête SurrealQL.
async fn read_bridge_records(
    ctx: &FrozenContext,
    opt: &Options,
    table_name: &str,
) -> Result<Vec<serde_json::Value>> {
    let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
    let txn = ctx.tx();
    let tb: TableName = table_name.into();

    // Récupérer la définition de la table
    let table_def = txn.get_tb(ns, db, &tb).await?;
    if table_def.is_none() {
        return Ok(Vec::new());
    }

    // Lire les records via scan (prefix scan sur la table)
    // Note: On utilise get_record pour des records spécifiques par ID,
    // mais pour un scan complet on doit utiliser l'itérateur prefix.
    // Comme les fonctions internes n'ont pas accès au scan direct,
    // on va plutôt utiliser l'approche par record ID connus.
    Ok(Vec::new())
}

/// Lit un record spécifique par son ID (ex: bridge_providers:airtable).
async fn read_bridge_record_by_id(
    ctx: &FrozenContext,
    opt: &Options,
    table_name: &str,
    record_id: &str,
) -> Result<Option<serde_json::Value>> {
    let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
    let txn = ctx.tx();
    let tb: TableName = table_name.into();
    let key = RecordIdKey::from(record_id.to_string());

    match txn.get_record(ns, db, &tb, &key, opt.version).await {
        Ok(record) => {
            let val = &record.data;
            Ok(Some(value_to_json(val)))
        }
        Err(_) => Ok(None),
    }
}

/// Crée un record dans une table bridge_* (pour persister les traces).
async fn write_bridge_record(
    ctx: &FrozenContext,
    opt: &Options,
    table_name: &str,
    record_id: &str,
    data: serde_json::Value,
) -> Result<()> {
    let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
    let txn = ctx.tx();
    let tb: TableName = table_name.into();
    let key = RecordIdKey::from(record_id.to_string());

    let value = json_to_value(data);
    let record = crate::db::catalog::Record::new(value);

    txn.set_record(ns, db, &tb, &key, Arc::new(record), opt.version).await?;
    Ok(())
}

// =========================================================================
// bridge::call
// =========================================================================

/// bridge::call(provider, operation, params) → Value
///
/// Executes an outbound API call via the Lyxal Bridge engine.
///
/// # SurrealQL Example
/// ```sql
/// LET $result = bridge::call("airtable", "list_records", { baseId: "appXYZ" });
/// ```
pub(crate) async fn call(
    (_stk, ctx, opt, _doc): (
        &mut Stk,
        &FrozenContext,
        &Options,
        Option<&CursorDoc>,
    ),
    args: Vec<Value>,
) -> Result<Value> {
    // ── Valider les arguments ──
    let provider_name = match args.first() {
        Some(Value::String(s)) => s.to_string(),
        _ => {
            return Err(anyhow::anyhow!(Error::InvalidFunctionArguments {
                name: "bridge::call".to_string(),
                message: "First argument must be a provider name (string)".to_string(),
            }));
        }
    };

    let operation_name = match args.get(1) {
        Some(Value::String(s)) => s.to_string(),
        _ => {
            return Err(anyhow::anyhow!(Error::InvalidFunctionArguments {
                name: "bridge::call".to_string(),
                message: "Second argument must be an operation name (string)".to_string(),
            }));
        }
    };

    let params = args.get(2).cloned().unwrap_or(Value::Object(Object::default()));
    let params_json = value_to_json(&params);

    // ── Créer le BridgeContext (ou récupérer du cache global) ──
    // TODO: En production, le BridgeContext sera un singleton stocké dans le Context SurrealDB.
    // Pour l'instant on en crée un temporaire par appel.
    let bridge_ctx = lyxal_bridge::BridgeContext::new().map_err(|e| {
        anyhow::anyhow!(Error::Internal(format!(
            "Failed to create BridgeContext: {}",
            e
        )))
    })?;

    // ── Créer la closure db_query ──
    // Cette closure convertit les requêtes SurrealQL internes du bridge
    // en lectures directes via la transaction KVS.
    let ctx_ref = ctx;
    let opt_ref = opt;
    let db_query = move |query: &str, bindings: Vec<(&str, serde_json::Value)>| {
        let query = query.to_string();
        let bindings: Vec<(String, serde_json::Value)> = bindings
            .into_iter()
            .map(|(k, v)| (k.to_string(), v))
            .collect();

        async move {
            // Dispatcher selon le pattern de requête
            // Le resolver utilise des requêtes standardisées qu'on peut parser
            let result = dispatch_bridge_query(ctx_ref, opt_ref, &query, &bindings).await;
            result.map_err(|e| lyxal_bridge::BridgeError::Database(e.to_string()))
        }
    };

    // ── Exécuter l'appel Bridge ──
    let result = lyxal_bridge::bridge_call(
        &bridge_ctx,
        db_query,
        &provider_name,
        &operation_name,
        params_json,
    )
    .await;

    match result {
        Ok(call_result) => {
            // ── Persister la trace ──
            let trace_json = call_result.trace.to_json();
            let trace_id = call_result.trace.trace_id.clone();
            if let Err(e) = write_bridge_record(ctx, opt, "bridge_execution_logs", &trace_id, trace_json).await {
                tracing::warn!(trace_id = %trace_id, error = %e, "Failed to persist bridge trace");
            }

            // ── Retourner le résultat ──
            Ok(json_to_value(call_result.value))
        }
        Err(bridge_err) => {
            // Convertir l'erreur Bridge en erreur SurrealQL
            Err(anyhow::anyhow!(Error::Internal(bridge_err.to_string())))
        }
    }
}

// =========================================================================
// Dispatcher de requêtes internes
// =========================================================================

/// Dispatche les requêtes SQL internes du resolver vers les bonnes lectures KVS.
///
/// Le resolver émet des requêtes standardisées qu'on reconnaît par pattern matching :
/// - "SELECT * FROM bridge_providers WHERE identity.name = $name ..."
/// - "SELECT * FROM bridge_operations WHERE relations.provider_id = $pid ..."
/// - etc.
async fn dispatch_bridge_query(
    ctx: &FrozenContext,
    opt: &Options,
    query: &str,
    bindings: &[(String, serde_json::Value)],
) -> Result<serde_json::Value> {
    let query_lower = query.to_lowercase();

    if query_lower.contains("from bridge_providers") {
        // Résolution du provider par nom
        let name = bindings
            .iter()
            .find(|(k, _)| k == "name")
            .and_then(|(_, v)| v.as_str())
            .unwrap_or("");

        let record = read_bridge_record_by_id(ctx, opt, "bridge_providers", name).await?;
        match record {
            Some(val) => Ok(serde_json::Value::Array(vec![val])),
            None => Ok(serde_json::Value::Array(vec![])),
        }
    } else if query_lower.contains("from bridge_operations") {
        // Résolution de l'opération par provider_id + nom
        let op = bindings
            .iter()
            .find(|(k, _)| k == "op")
            .and_then(|(_, v)| v.as_str())
            .unwrap_or("");

        // L'ID de l'opération est typiquement provider_name:operation_name
        // ou on cherche par convention opération par son nom
        let pid = bindings
            .iter()
            .find(|(k, _)| k == "pid")
            .and_then(|(_, v)| v.as_str())
            .unwrap_or("");

        // Convention de nommage : bridge_operations:{provider}_{operation}
        let provider_short = pid
            .strip_prefix("bridge_providers:")
            .unwrap_or(pid);
        let record_id = format!("{}_{}", provider_short, op);

        let record = read_bridge_record_by_id(ctx, opt, "bridge_operations", &record_id).await?;
        match record {
            Some(val) => Ok(serde_json::Value::Array(vec![val])),
            None => Ok(serde_json::Value::Array(vec![])),
        }
    } else if query_lower.contains("from bridge_errors") {
        // Résolution des règles d'erreur — retourner un tableau vide pour l'instant
        // TODO: Scanner les bridge_errors par operation_id
        Ok(serde_json::Value::Array(vec![]))
    } else if query_lower.contains("from bridge_user_credentials") {
        // Résolution des credentials — retourner None pour l'instant
        // TODO: Chercher par provider_id
        Ok(serde_json::Value::Array(vec![]))
    } else if query_lower.contains("from bridge_auth_schemas") {
        // Résolution du type d'auth
        Ok(serde_json::Value::Array(vec![]))
    } else {
        tracing::warn!(query = %query, "Bridge: requête interne non reconnue");
        Ok(serde_json::Value::Array(vec![]))
    }
}

// =========================================================================
// bridge::list
// =========================================================================

/// bridge::list() → Array
///
/// Lists all active providers.
///
/// # SurrealQL Example
/// ```sql
/// LET $providers = bridge::list();
/// ```
pub(crate) async fn call(
    (ctx, opt): (&FrozenContext, &Options),
    _args: Vec<Value>,
) -> Result<Value> {
    // Lire tous les providers depuis la DB
    // TODO: Implémenter un scan de tous les records bridge_providers
    // Pour l'instant, retourner un tableau vide avec un message de log
    tracing::info!("bridge::list called");

    // Pour l'instant, guide l'utilisateur
    let info_msg = Value::String("Use SELECT * FROM bridge_providers to list providers".into());
    Ok(Value::Array(Array::from(vec![info_msg])))
}

// =========================================================================
// bridge::info
// =========================================================================

/// bridge::info(provider) → Object
///
/// Returns details about a provider and its operations.
///
/// # SurrealQL Example
/// ```sql
/// LET $info = bridge::info("airtable");
/// ```
pub(crate) async fn info(
    (ctx, opt): (&FrozenContext, &Options),
    args: Vec<Value>,
) -> Result<Value> {
    let provider_name = match args.first() {
        Some(Value::String(s)) => s.to_string(),
        _ => {
            return Err(anyhow::anyhow!(Error::InvalidFunctionArguments {
                name: "bridge::info".to_string(),
                message: "First argument must be a provider name (string)".to_string(),
            }));
        }
    };

    // Lire le provider par ID
    match read_bridge_record_by_id(ctx, opt, "bridge_providers", &provider_name).await? {
        Some(provider_json) => Ok(json_to_value(provider_json)),
        None => Err(anyhow::anyhow!(Error::Internal(format!(
            "Bridge: provider '{}' introuvable",
            provider_name
        )))),
    }
}

// =========================================================================
// bridge::health
// =========================================================================

/// bridge::health(provider) → Object
///
/// Checks connectivity with a provider's base URL via HEAD request.
///
/// # SurrealQL Example
/// ```sql
/// LET $health = bridge::health("stripe");
/// ```
pub(crate) async fn health(
    ctx: &FrozenContext,
    args: Vec<Value>,
) -> Result<Value> {
    let provider_name = match args.first() {
        Some(Value::String(s)) => s.to_string(),
        _ => {
            return Err(anyhow::anyhow!(Error::InvalidFunctionArguments {
                name: "bridge::health".to_string(),
                message: "First argument must be a provider name (string)".to_string(),
            }));
        }
    };

    // Créer un client HTTP temporaire pour le health check
    let client = reqwest::Client::builder()
        .timeout(std::time::Duration::from_secs(10))
        .build()
        .map_err(|e| anyhow::anyhow!(Error::Internal(format!("HTTP client error: {}", e))))?;

    // TODO: Lire l'URL de base depuis bridge_providers
    // Pour l'instant, retourner un objet avec le statut
    let mut result = Object::default();
    result.insert("provider".to_string(), Value::String(provider_name.into()));
    result.insert("status".to_string(), Value::String("unknown".into()));
    result.insert("message".to_string(), Value::String("Health check not yet fully wired — provider URL needed".into()));

    Ok(Value::Object(result))
}

// =========================================================================
// bridge::batch
// =========================================================================

/// bridge::batch(calls) → Array
///
/// Executes multiple bridge calls in parallel.
///
/// # SurrealQL Example
/// ```sql
/// LET $results = bridge::batch([
///     { provider: "slack", operation: "send_message", params: { channel: "sales" } },
///     { provider: "sendgrid", operation: "send_email", params: { to: "a@b.com" } }
/// ]);
/// ```
pub(crate) async fn batch(
    (stk, ctx, opt, doc): (
        &mut Stk,
        &FrozenContext,
        &Options,
        Option<&CursorDoc>,
    ),
    args: Vec<Value>,
) -> Result<Value> {
    let calls = match args.first() {
        Some(Value::Array(arr)) => arr.clone(),
        _ => {
            return Err(anyhow::anyhow!(Error::InvalidFunctionArguments {
                name: "bridge::batch".to_string(),
                message: "First argument must be an array of call descriptors".to_string(),
            }));
        }
    };

    // Exécuter chaque appel séquentiellement (pour l'instant)
    // TODO: Utiliser tokio::join! pour l'exécution parallèle
    let mut results = Vec::with_capacity(calls.len());

    for call_desc in calls.iter() {
        match call_desc {
            Value::Object(obj) => {
                let provider = obj.get("provider").cloned().unwrap_or(Value::None);
                let operation = obj.get("operation").cloned().unwrap_or(Value::None);
                let params = obj.get("params").cloned().unwrap_or(Value::Object(Object::default()));

                let call_args = vec![provider, operation, params];
                match call(
                    (stk, ctx, opt, doc),
                    call_args,
                ).await {
                    Ok(val) => results.push(val),
                    Err(e) => {
                        let mut err_obj = Object::default();
                        err_obj.insert("error".to_string(), Value::String(e.to_string().into()));
                        results.push(Value::Object(err_obj));
                    }
                }
            }
            _ => {
                let mut err_obj = Object::default();
                err_obj.insert("error".to_string(), Value::String("Each batch item must be an object with provider, operation, and params".into()));
                results.push(Value::Object(err_obj));
            }
        }
    }

    Ok(Value::Array(Array::from(results)))
}
