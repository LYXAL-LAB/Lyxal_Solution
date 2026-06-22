//! Résolution des métadonnées depuis les tables `bridge_*`.
//!
//! Ce module est le cœur de l'approche **data-driven** : il lit
//! provider, opération, auth et règles d'erreur directement
//! depuis SurrealDB, avec mise en cache automatique.
//!
//! ## Différence avec l'ancien système
//!
//! ```text
//! AVANT : kvs.get_connector("airtable")  →  ConnectorDefinition (KVS, statique)
//! APRÈS : resolve_operation(&ctx, ...)    →  SELECT FROM bridge_* (DB, dynamique)
//! ```

use crate::context::{BridgeContext, CachedMetadata};
use crate::error::BridgeError;
use crate::models::{
    BridgeCredential, BridgeErrorRule, BridgeOperation, BridgeProvider, ResolvedAuth,
};

// =========================================================================
// Résolution Provider + Opération
// =========================================================================

/// Résout un provider et son opération depuis la DB (avec cache).
///
/// # Flow
/// 1. Vérifier le cache → si trouvé et non expiré, retourner directement
/// 2. Sinon, requêter SurrealDB
/// 3. Mettre en cache le résultat
///
/// # Arguments
/// * `ctx` — Le contexte Bridge (contient le cache)
/// * `db_query` — Fonction pour exécuter des requêtes DB (injectée pour découplage)
/// * `provider_name` — Nom du provider (ex: "airtable")
/// * `operation_name` — Nom de l'opération (ex: "list_records")
pub async fn resolve_operation<F, Fut>(
    ctx: &BridgeContext,
    db_query: F,
    provider_name: &str,
    operation_name: &str,
) -> Result<(BridgeProvider, BridgeOperation, Vec<BridgeErrorRule>), BridgeError>
where
    F: Fn(&str, Vec<(&str, serde_json::Value)>) -> Fut,
    Fut: std::future::Future<Output = Result<serde_json::Value, BridgeError>>,
{
    // 1. Vérifier le cache
    if let Some(cached) = ctx.cache_get(provider_name, operation_name) {
        tracing::debug!(
            provider = provider_name,
            operation = operation_name,
            "Cache hit pour résolution Bridge"
        );
        return Ok((cached.provider, cached.operation, cached.error_rules));
    }

    tracing::debug!(
        provider = provider_name,
        operation = operation_name,
        "Cache miss — résolution depuis la DB"
    );

    // 2. Résoudre le provider
    let provider_query = r#"
        SELECT * FROM bridge_providers 
        WHERE identity.name = $name 
        AND status.status = bridge_status:active
        LIMIT 1
    "#;
    let provider_result = db_query(
        provider_query,
        vec![("name", serde_json::Value::String(provider_name.to_string()))],
    )
    .await?;

    let provider: BridgeProvider = parse_first_result(provider_result).ok_or_else(|| {
        BridgeError::ProviderNotFound {
            name: provider_name.to_string(),
        }
    })?;

    // 3. Résoudre l'opération
    let provider_id = provider
        .id
        .as_deref()
        .unwrap_or("");
    let operation_query = r#"
        SELECT * FROM bridge_operations 
        WHERE relations.provider_id = $pid 
        AND identity.name = $op 
        AND status.status = bridge_status:active
        LIMIT 1
    "#;
    let operation_result = db_query(
        operation_query,
        vec![
            ("pid", serde_json::Value::String(provider_id.to_string())),
            ("op", serde_json::Value::String(operation_name.to_string())),
        ],
    )
    .await?;

    let operation: BridgeOperation =
        parse_first_result(operation_result).ok_or_else(|| BridgeError::OperationNotFound {
            provider: provider_name.to_string(),
            operation: operation_name.to_string(),
        })?;

    // 4. Résoudre les règles d'erreur associées
    let operation_id = operation.id.as_deref().unwrap_or("");
    let errors_query = r#"
        SELECT * FROM bridge_errors 
        WHERE relations.operation_id = $oid 
        AND status.is_active = true
    "#;
    let errors_result = db_query(
        errors_query,
        vec![("oid", serde_json::Value::String(operation_id.to_string()))],
    )
    .await?;

    let error_rules: Vec<BridgeErrorRule> = parse_all_results(errors_result);

    // 5. Mettre en cache
    let cached = CachedMetadata::new(
        provider.clone(),
        operation.clone(),
        error_rules.clone(),
        ctx.config().cache_ttl,
    );
    ctx.cache_set(provider_name, operation_name, cached);

    Ok((provider, operation, error_rules))
}

// =========================================================================
// Résolution Auth
// =========================================================================

/// Résout l'authentification pour un provider.
///
/// # Flow
/// 1. Récupère les credentials chiffrés depuis `bridge_user_credentials`
/// 2. Déchiffre les données (TODO: implémenter le déchiffrement)
/// 3. Retourne un `ResolvedAuth` prêt à être injecté dans les headers
pub async fn resolve_auth<F, Fut>(
    db_query: F,
    provider: &BridgeProvider,
) -> Result<Option<ResolvedAuth>, BridgeError>
where
    F: Fn(&str, Vec<(&str, serde_json::Value)>) -> Fut,
    Fut: std::future::Future<Output = Result<serde_json::Value, BridgeError>>,
{
    let provider_id = provider.id.as_deref().unwrap_or("");

    let cred_query = r#"
        SELECT * FROM bridge_user_credentials 
        WHERE provider = $pid 
        LIMIT 1
    "#;
    let cred_result = db_query(
        cred_query,
        vec![("pid", serde_json::Value::String(provider_id.to_string()))],
    )
    .await?;

    let credential: Option<BridgeCredential> = parse_first_result(cred_result);

    match credential {
        Some(cred) => {
            // Déchiffrer les données
            // TODO: Intégrer le module lyxal_crypto pour le déchiffrement AES
            let decrypted = decrypt_credential_data(&cred.encrypted_data)?;

            // Récupérer le type d'auth du provider
            let auth_query = r#"
                SELECT out.identity.name AS auth_type 
                FROM bridge_auth_schemas 
                WHERE in = $pid 
                AND configuration.is_default = true
                LIMIT 1
            "#;
            let auth_result = db_query(
                auth_query,
                vec![("pid", serde_json::Value::String(provider_id.to_string()))],
            )
            .await?;

            let auth_type: String = parse_first_result::<serde_json::Value>(auth_result)
                .and_then(|v| v.get("auth_type").and_then(|a| a.as_str()).map(String::from))
                .unwrap_or_else(|| "api_key".to_string());

            Ok(Some(ResolvedAuth {
                auth_type,
                fields: decrypted,
            }))
        }
        None => {
            tracing::debug!(
                provider = provider.identity.name,
                "Aucun credential trouvé — appel sans auth"
            );
            Ok(None)
        }
    }
}

// =========================================================================
// Helpers
// =========================================================================

/// Déchiffre les données de credential.
/// TODO: Intégrer le vrai module de chiffrement lyxal_crypto.
fn decrypt_credential_data(
    encrypted: &str,
) -> Result<serde_json::Map<String, serde_json::Value>, BridgeError> {
    // Pour l'instant, on suppose que les données sont en JSON clair
    // En production, il faudra déchiffrer avec AES-256-GCM
    serde_json::from_str(encrypted).map_err(|e| BridgeError::Internal(format!(
        "Erreur de déchiffrement des credentials: {}",
        e
    )))
}

/// Parse le premier résultat d'une requête SurrealDB.
fn parse_first_result<T: serde::de::DeserializeOwned>(value: serde_json::Value) -> Option<T> {
    match value {
        serde_json::Value::Array(arr) => {
            arr.into_iter().next().and_then(|v| serde_json::from_value(v).ok())
        }
        other => serde_json::from_value(other).ok(),
    }
}

/// Parse tous les résultats d'une requête SurrealDB.
fn parse_all_results<T: serde::de::DeserializeOwned>(value: serde_json::Value) -> Vec<T> {
    match value {
        serde_json::Value::Array(arr) => arr
            .into_iter()
            .filter_map(|v| serde_json::from_value(v).ok())
            .collect(),
        _ => Vec::new(),
    }
}
