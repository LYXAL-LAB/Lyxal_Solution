//! Construction dynamique des requêtes HTTP.
//!
//! Ce module transforme les métadonnées de `bridge_operations.configuration`
//! en une requête HTTP concrète prête à être envoyée par reqwest.
//!
//! ## Logique d'injection des paramètres
//!
//! Chaque paramètre dans `configuration.parameters[]` a un champ `in` qui
//! détermine **où** la valeur est injectée dans la requête :
//!
//! | `in`     | Injection                                    |
//! |:---------|:---------------------------------------------|
//! | `path`   | Interpolation dans l'URL : `/v0/{baseId}/...`|
//! | `query`  | Query string : `?limit=10&offset=0`          |
//! | `header` | Header HTTP : `X-API-Version: v1`            |
//! | `body`   | Champ dans le corps JSON                     |
//! | `cookie` | Cookie HTTP                                  |

use std::collections::HashMap;

use crate::error::BridgeError;
use crate::models::{
    extract_http_method, BridgeOperation, BridgeProvider, OperationParameter, ResolvedAuth,
};

// =========================================================================
// BridgeRequest
// =========================================================================

/// Requête HTTP construite dynamiquement, prête à être exécutée.
#[derive(Debug, Clone)]
pub struct BridgeRequest {
    /// URL complète (base_url + path interpolé + query params)
    pub url: String,

    /// Méthode HTTP (GET, POST, PUT, etc.)
    pub method: String,

    /// Headers HTTP (auth + custom)
    pub headers: HashMap<String, String>,

    /// Body JSON optionnel
    pub body: Option<serde_json::Value>,

    /// Timeout en millisecondes
    pub timeout_ms: Option<u64>,

    /// Nom du provider (pour le logging)
    pub provider_name: String,

    /// Nom de l'opération (pour le logging)
    pub operation_name: String,
}

// =========================================================================
// Construction
// =========================================================================

/// Construit une `BridgeRequest` à partir des métadonnées DB + paramètres utilisateur.
///
/// # Arguments
/// * `provider` — Le provider résolu depuis `bridge_providers`
/// * `operation` — L'opération résolue depuis `bridge_operations`
/// * `auth` — L'auth résolue (optionnelle, certains endpoints publics n'en ont pas)
/// * `params` — Paramètres fournis par l'utilisateur dans `bridge::call()`
pub fn build_request(
    provider: &BridgeProvider,
    operation: &BridgeOperation,
    auth: &Option<ResolvedAuth>,
    params: &serde_json::Value,
) -> Result<BridgeRequest, BridgeError> {
    let base_url = &provider.configuration.endpoint_base_url;
    let mut path = operation.configuration.path.clone();
    let mut query_params: Vec<(String, String)> = Vec::new();
    let mut headers: HashMap<String, String> = HashMap::new();
    let mut body_fields: serde_json::Map<String, serde_json::Value> = serde_json::Map::new();

    // ── Traiter chaque paramètre défini dans bridge_operations ──
    for param_def in &operation.configuration.parameters {
        let value = resolve_param_value(param_def, auth, params);

        let value = match value {
            Some(v) => v,
            None if param_def.required => {
                return Err(BridgeError::MissingParameter {
                    provider: provider.identity.name.clone(),
                    operation: operation.identity.name.clone(),
                    param: param_def.name.clone(),
                });
            }
            None => continue, // paramètre optionnel absent → skip
        };

        // Injecter au bon endroit
        inject_parameter(&param_def.location, &param_def.name, &value, &mut path, &mut query_params, &mut headers, &mut body_fields);
    }

    // ── Vérifier les placeholders non résolus ──
    if let Some(start) = path.find('{') {
        if let Some(end) = path[start..].find('}') {
            let placeholder = &path[start + 1..start + end];
            return Err(BridgeError::UnresolvedPlaceholder {
                provider: provider.identity.name.clone(),
                operation: operation.identity.name.clone(),
                placeholder: placeholder.to_string(),
            });
        }
    }

    // ── Construire l'URL finale ──
    let mut url = format!(
        "{}{}",
        base_url.trim_end_matches('/'),
        path
    );
    if !query_params.is_empty() {
        let qs: String = query_params
            .iter()
            .map(|(k, v)| format!("{}={}", urlencoding::encode(k), urlencoding::encode(v)))
            .collect::<Vec<_>>()
            .join("&");
        url = format!("{}?{}", url, qs);
    }

    // ── Injecter l'auth dans les headers ──
    if let Some(auth) = auth {
        inject_auth_headers(&mut headers, auth);
    }

    // ── Déterminer le body ──
    let method = extract_http_method(&operation.configuration.method);
    let body = determine_body(&method, body_fields, &operation.configuration.body_template, params);

    Ok(BridgeRequest {
        url,
        method,
        headers,
        body,
        timeout_ms: None,
        provider_name: provider.identity.name.clone(),
        operation_name: operation.identity.name.clone(),
    })
}

// =========================================================================
// Résolution des valeurs de paramètres
// =========================================================================

/// Résout la valeur d'un paramètre selon son `value_type`.
fn resolve_param_value(
    param: &OperationParameter,
    auth: &Option<ResolvedAuth>,
    user_params: &serde_json::Value,
) -> Option<String> {
    match param.value_type.as_str() {
        // Valeur fixe définie dans la DB
        "static" => param.value.clone(),

        // Valeur fournie par l'utilisateur
        "user" => user_params
            .get(&param.name)
            .map(|v| match v {
                serde_json::Value::String(s) => s.clone(),
                other => other.to_string(),
            })
            // Fallback sur la valeur par défaut si l'utilisateur n'a rien fourni
            .or_else(|| param.value.clone()),

        // Valeur extraite des credentials d'auth
        "auth" => auth
            .as_ref()
            .and_then(|a| a.get_field(&param.name))
            .or_else(|| param.value.clone()),

        // Expression évaluée dynamiquement
        // TODO: Brancher l'évaluateur SurrealQL pour les expressions
        "expression" => param.value.clone(),

        // Type inconnu → fallback sur la valeur par défaut
        _ => param.value.clone(),
    }
}

// =========================================================================
// Injection des paramètres
// =========================================================================

/// Injecte un paramètre au bon endroit dans la requête.
fn inject_parameter(
    location: &str,
    name: &str,
    value: &str,
    path: &mut String,
    query_params: &mut Vec<(String, String)>,
    headers: &mut HashMap<String, String>,
    body_fields: &mut serde_json::Map<String, serde_json::Value>,
) {
    match location {
        "path" => {
            let placeholder = format!("{{{}}}", name);
            *path = path.replace(&placeholder, value);
        }
        "query" => {
            query_params.push((name.to_string(), value.to_string()));
        }
        "header" => {
            headers.insert(name.to_string(), value.to_string());
        }
        "body" => {
            body_fields.insert(
                name.to_string(),
                serde_json::Value::String(value.to_string()),
            );
        }
        "cookie" => {
            headers
                .entry("Cookie".to_string())
                .and_modify(|c| {
                    c.push_str(&format!("; {}={}", name, value));
                })
                .or_insert_with(|| format!("{}={}", name, value));
        }
        _ => {
            tracing::warn!(
                location = location,
                param = name,
                "Emplacement de paramètre inconnu, ignoré"
            );
        }
    }
}

// =========================================================================
// Injection Auth
// =========================================================================

/// Injecte l'authentification dans les headers HTTP.
fn inject_auth_headers(headers: &mut HashMap<String, String>, auth: &ResolvedAuth) {
    match auth.auth_type.as_str() {
        "bearer" => {
            if let Some(token) = auth.get_field("token")
                .or_else(|| auth.get_field("access_token"))
                .or_else(|| auth.get_field("api_key"))
            {
                headers.insert("Authorization".to_string(), format!("Bearer {}", token));
            }
        }
        "basic" => {
            let user = auth.get_field("username").unwrap_or_default();
            let pass = auth.get_field("password").unwrap_or_default();
            use base64::Engine;
            let encoded = base64::engine::general_purpose::STANDARD
                .encode(format!("{}:{}", user, pass));
            headers.insert("Authorization".to_string(), format!("Basic {}", encoded));
        }
        "api_key" => {
            // L'API key peut être dans un header custom
            let header_name = auth
                .get_field("header_name")
                .unwrap_or_else(|| "Authorization".to_string());
            let key_value = auth
                .get_field("api_key")
                .or_else(|| auth.get_field("key"))
                .or_else(|| auth.get_field("token"))
                .unwrap_or_default();

            let prefix = auth.get_field("prefix").unwrap_or_default();
            if prefix.is_empty() {
                headers.insert(header_name, key_value);
            } else {
                headers.insert(header_name, format!("{} {}", prefix, key_value));
            }
        }
        "oauth2" => {
            // OAuth2 utilise un Bearer token
            if let Some(access_token) = auth.get_field("access_token") {
                headers.insert(
                    "Authorization".to_string(),
                    format!("Bearer {}", access_token),
                );
            }
        }
        _ => {
            tracing::warn!(
                auth_type = auth.auth_type,
                "Type d'auth inconnu, aucun header injecté"
            );
        }
    }
}

// =========================================================================
// Body
// =========================================================================

/// Détermine le body de la requête.
fn determine_body(
    method: &str,
    body_fields: serde_json::Map<String, serde_json::Value>,
    body_template: &serde_json::Value,
    user_params: &serde_json::Value,
) -> Option<serde_json::Value> {
    // Les méthodes GET, HEAD, DELETE n'ont normalement pas de body
    match method {
        "GET" | "HEAD" | "DELETE" | "OPTIONS" => return None,
        _ => {}
    }

    // Si des champs body ont été définis via les paramètres
    if !body_fields.is_empty() {
        return Some(serde_json::Value::Object(body_fields));
    }

    // Si un template de body est défini dans l'opération
    if !body_template.is_null() && body_template != &serde_json::Value::Object(serde_json::Map::new()) {
        return Some(merge_body_template(body_template, user_params));
    }

    // Si l'utilisateur a passé un objet, l'utiliser comme body
    if let serde_json::Value::Object(obj) = user_params {
        if !obj.is_empty() {
            return Some(user_params.clone());
        }
    }

    None
}

/// Fusionne un template de body avec les paramètres utilisateur.
/// Les clés du template servent de structure, les valeurs utilisateur les remplacent.
fn merge_body_template(
    template: &serde_json::Value,
    params: &serde_json::Value,
) -> serde_json::Value {
    match (template, params) {
        (serde_json::Value::Object(tmpl), serde_json::Value::Object(prm)) => {
            let mut result = tmpl.clone();
            for (key, value) in prm {
                result.insert(key.clone(), value.clone());
            }
            serde_json::Value::Object(result)
        }
        _ => template.clone(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_inject_path_parameter() {
        let mut path = "/v0/{baseId}/{table}".to_string();
        let mut query = Vec::new();
        let mut headers = HashMap::new();
        let mut body = serde_json::Map::new();

        inject_parameter("path", "baseId", "appXYZ", &mut path, &mut query, &mut headers, &mut body);
        inject_parameter("path", "table", "Contacts", &mut path, &mut query, &mut headers, &mut body);

        assert_eq!(path, "/v0/appXYZ/Contacts");
    }

    #[test]
    fn test_inject_query_parameter() {
        let mut path = "/records".to_string();
        let mut query = Vec::new();
        let mut headers = HashMap::new();
        let mut body = serde_json::Map::new();

        inject_parameter("query", "limit", "10", &mut path, &mut query, &mut headers, &mut body);
        inject_parameter("query", "offset", "0", &mut path, &mut query, &mut headers, &mut body);

        assert_eq!(query.len(), 2);
        assert_eq!(query[0], ("limit".to_string(), "10".to_string()));
    }

    #[test]
    fn test_inject_header_parameter() {
        let mut path = String::new();
        let mut query = Vec::new();
        let mut headers = HashMap::new();
        let mut body = serde_json::Map::new();

        inject_parameter("header", "X-API-Version", "v1", &mut path, &mut query, &mut headers, &mut body);

        assert_eq!(headers.get("X-API-Version"), Some(&"v1".to_string()));
    }
}
