//! Parsing et normalisation des réponses HTTP.

use std::collections::HashMap;

/// Réponse HTTP reçue d'un endpoint distant.
#[derive(Debug, Clone)]
pub struct BridgeResponse {
    /// Code de status HTTP (200, 404, 500...)
    pub status: u16,

    /// Headers de la réponse
    pub headers: HashMap<String, String>,

    /// Corps de la réponse (JSON parsé ou string brute)
    pub body: serde_json::Value,
}

impl BridgeResponse {
    /// Convertit la réponse en un objet JSON structuré.
    /// Format : `{ status: 200, headers: {...}, body: {...} }`
    pub fn into_full_value(self) -> serde_json::Value {
        let headers_obj: serde_json::Map<String, serde_json::Value> = self
            .headers
            .into_iter()
            .map(|(k, v)| (k, serde_json::Value::String(v)))
            .collect();

        serde_json::json!({
            "status": self.status,
            "headers": headers_obj,
            "body": self.body,
        })
    }

    /// Retourne uniquement le body de la réponse.
    pub fn into_body(self) -> serde_json::Value {
        self.body
    }

    /// Vérifie si la réponse est un succès (2xx).
    pub fn is_success(&self) -> bool {
        (200..300).contains(&self.status)
    }

    /// Vérifie si la réponse est une erreur client (4xx).
    pub fn is_client_error(&self) -> bool {
        (400..500).contains(&self.status)
    }

    /// Vérifie si la réponse est une erreur serveur (5xx).
    pub fn is_server_error(&self) -> bool {
        (500..600).contains(&self.status)
    }
}

/// Construit une `BridgeResponse` depuis une `reqwest::Response`.
pub async fn parse_response(resp: reqwest::Response) -> Result<BridgeResponse, crate::error::BridgeError> {
    let status = resp.status().as_u16();

    let headers: HashMap<String, String> = resp
        .headers()
        .iter()
        .filter_map(|(k, v)| v.to_str().ok().map(|v| (k.to_string(), v.to_string())))
        .collect();

    // Parser le body : JSON si possible, sinon string, sinon null
    let body = match resp.text().await {
        Ok(text) => {
            if text.is_empty() {
                serde_json::Value::Null
            } else {
                match serde_json::from_str::<serde_json::Value>(&text) {
                    Ok(json) => json,
                    Err(_) => serde_json::Value::String(text),
                }
            }
        }
        Err(_) => serde_json::Value::Null,
    };

    Ok(BridgeResponse {
        status,
        headers,
        body,
    })
}
