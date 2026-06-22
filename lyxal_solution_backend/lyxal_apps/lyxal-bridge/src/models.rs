//! Modèles de données Rust mappés sur les tables `bridge_*` de SurrealDB.
//!
//! Ces structs représentent les données lues depuis la base.
//! Ils sont désérialisés automatiquement depuis les résultats de requêtes SurrealQL.

use serde::{Deserialize, Serialize};

// =========================================================================
// bridge_providers
// =========================================================================

/// Un provider externe (Airtable, Slack, Stripe, etc.).
/// Correspond à un enregistrement de la table `bridge_providers`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BridgeProvider {
    /// ID SurrealDB (ex: bridge_providers:airtable)
    pub id: Option<String>,

    /// Identité du provider
    pub identity: ProviderIdentity,

    /// Configuration technique
    pub configuration: ProviderConfiguration,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProviderIdentity {
    /// Nom interne (ex: "airtable", "slack")
    pub name: String,

    /// Description du provider
    #[serde(default)]
    pub description: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProviderConfiguration {
    /// Catégorie (ex: "productivity", "communication")
    #[serde(default)]
    pub category: String,

    /// URL de documentation
    #[serde(default)]
    pub documentation_url: String,

    /// URL racine de l'API (ex: "https://api.airtable.com")
    pub endpoint_base_url: String,
}

// =========================================================================
// bridge_operations
// =========================================================================

/// Une opération/action disponible pour un provider.
/// Correspond à un enregistrement de la table `bridge_operations`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BridgeOperation {
    /// ID SurrealDB
    pub id: Option<String>,

    /// Relations (lien vers le provider)
    pub relations: OperationRelations,

    /// Identité technique
    pub identity: OperationIdentity,

    /// Affichage UI
    #[serde(default)]
    pub affichage: OperationAffichage,

    /// Configuration technique de l'appel API
    pub configuration: OperationConfiguration,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OperationRelations {
    /// Lien vers le provider propriétaire (ex: bridge_providers:airtable)
    pub provider_id: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OperationIdentity {
    /// Nom interne en snake_case (ex: "list_records")
    pub name: String,

    /// UUID unique d'opération
    #[serde(default)]
    pub operation_id: Option<String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct OperationAffichage {
    /// Nom lisible (ex: "Créer un enregistrement")
    #[serde(default)]
    pub display_name: String,

    /// Description de l'action
    #[serde(default)]
    pub description: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OperationConfiguration {
    /// Méthode HTTP (record vers bridge_operations_methods, ex: "bridge_operations_methods:get")
    pub method: String,

    /// Chemin URL (ex: "/v0/{baseId}/{table}")
    pub path: String,

    /// Paramètres de l'opération
    #[serde(default)]
    pub parameters: Vec<OperationParameter>,

    /// Template du body JSON
    #[serde(default)]
    pub body_template: serde_json::Value,

    /// Hooks à appliquer (ex: ["hmac_sign", "auto_paginate_cursor"])
    #[serde(default)]
    pub hooks: Vec<String>,
}

/// Un paramètre d'une opération.
/// Définit ce qui doit être injecté dans la requête et d'où vient la valeur.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OperationParameter {
    /// Nom technique (ex: "baseId", "limit", "Authorization")
    pub name: String,

    /// Où injecter : "query", "header", "path", "cookie", "body"
    #[serde(rename = "in")]
    pub location: String,

    /// Source de la valeur : "static", "user", "auth", "expression"
    #[serde(default = "default_value_type")]
    pub value_type: String,

    /// Valeur par défaut ou valeur fixe
    #[serde(default)]
    pub value: Option<String>,

    /// Est-ce obligatoire ?
    #[serde(default = "default_true")]
    pub required: bool,
}

fn default_value_type() -> String {
    "user".to_string()
}

fn default_true() -> bool {
    true
}

// =========================================================================
// bridge_errors
// =========================================================================

/// Règle d'erreur du moteur de décision.
/// Correspond à un enregistrement de la table `bridge_errors`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BridgeErrorRule {
    /// ID SurrealDB
    pub id: Option<String>,

    /// Déclencheurs
    #[serde(default)]
    pub triggers: ErrorTriggers,

    /// Réaction technique
    pub configuration: ErrorConfiguration,

    /// Stratégie de résilience
    #[serde(default)]
    pub resilience: ErrorResilience,

    /// État de la règle
    #[serde(default)]
    pub status: ErrorStatus,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ErrorTriggers {
    /// Le code HTTP qui déclenche la règle (ex: 429, 500)
    pub http_code: Option<i64>,

    /// Pattern à chercher dans le body de la réponse
    pub body_pattern: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorConfiguration {
    /// Action : "retry", "stop", "ignore", "map", "circuit_break"
    pub action: String,

    /// Message traduit pour l'utilisateur final (pour action "map")
    pub mapped_message: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorResilience {
    /// Nombre max de tentatives
    #[serde(default = "default_max_attempts")]
    pub max_attempts: u32,

    /// Délai d'attente entre les tentatives (ms)
    #[serde(default = "default_backoff_ms")]
    pub backoff_ms: u64,

    /// Augmentation exponentielle du délai
    #[serde(default = "default_true")]
    pub exponential: bool,
}

impl Default for ErrorResilience {
    fn default() -> Self {
        Self {
            max_attempts: 3,
            backoff_ms: 1000,
            exponential: true,
        }
    }
}

fn default_max_attempts() -> u32 {
    3
}

fn default_backoff_ms() -> u64 {
    1000
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorStatus {
    /// Est-ce que la règle est activée ?
    #[serde(default = "default_true")]
    pub is_active: bool,

    /// Sévérité : "info", "warning", "error", "critical"
    #[serde(default = "default_severity")]
    pub severity: String,
}

impl Default for ErrorStatus {
    fn default() -> Self {
        Self {
            is_active: true,
            severity: "error".to_string(),
        }
    }
}

fn default_severity() -> String {
    "error".to_string()
}

// =========================================================================
// bridge_user_credentials
// =========================================================================

/// Credentials chiffrés d'un utilisateur pour un provider.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BridgeCredential {
    /// ID SurrealDB
    pub id: Option<String>,

    /// Lien vers le provider
    pub provider: String,

    /// Données chiffrées (JSON sérialisé et chiffré)
    pub encrypted_data: String,

    /// Label utilisateur (ex: "Mon compte Airtable Pro")
    pub label: String,
}

// =========================================================================
// Données d'auth déchiffrées (en mémoire uniquement)
// =========================================================================

/// Auth résolue et prête à être injectée dans les headers.
/// Jamais persistée — existe uniquement en mémoire pendant l'exécution.
#[derive(Debug, Clone)]
pub struct ResolvedAuth {
    /// Type d'auth : "api_key", "bearer", "basic", "oauth2"
    pub auth_type: String,

    /// Champs déchiffrés (ex: { "api_key": "sk-xxx", "header_name": "Authorization" })
    pub fields: serde_json::Map<String, serde_json::Value>,
}

impl ResolvedAuth {
    /// Récupère un champ déchiffré par nom.
    pub fn get_field(&self, name: &str) -> Option<String> {
        self.fields.get(name).and_then(|v| v.as_str()).map(|s| s.to_string())
    }
}

// =========================================================================
// Helper : extraction du nom de méthode depuis le record ID
// =========================================================================

/// Extrait le nom de la méthode HTTP depuis un record ID SurrealDB.
/// Ex: "bridge_operations_methods:get" → "GET"
///     "bridge_operations_methods:post" → "POST"
pub fn extract_http_method(method_record: &str) -> String {
    method_record
        .split(':')
        .last()
        .unwrap_or("get")
        .to_uppercase()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_http_method() {
        assert_eq!(extract_http_method("bridge_operations_methods:get"), "GET");
        assert_eq!(extract_http_method("bridge_operations_methods:post"), "POST");
        assert_eq!(extract_http_method("bridge_operations_methods:delete"), "DELETE");
        assert_eq!(extract_http_method("get"), "GET");
    }
}
