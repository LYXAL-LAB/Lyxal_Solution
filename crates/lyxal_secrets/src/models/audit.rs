//! Journal chaîné (`fn::secrets_audit_list`, `fn::secrets_audit_verify`,
//! `fn::secrets_audit_denied`).

use lyxal_surreal::SurrealValue;

use super::types::SecretsDatetime;

/// Paramètres de `fn::secrets_audit_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct AuditListParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Secret (`secrets_secret:<clé>`).
    pub secret: Option<String>,
    /// Action (`secret.read`, `version.created`…).
    pub action: Option<String>,
    /// Entrées postérieures à cette date.
    pub since: Option<SecretsDatetime>,
    /// Taille de page (500 au plus).
    pub limit: Option<i64>,
    /// Début de page.
    pub start: Option<i64>,
}

/// Entrée du journal. `event` porte l'entrée chaînée telle qu'enregistrée (`seq`, `action`,
/// `outcome`, `actor`, `application`, `session`, `session_kind`, `ip`, `secret`, `path`,
/// `version`, `details`, `at`), dont les champs vides valent `null` ; jamais de valeur secrète.
#[derive(Debug, Clone, SurrealValue)]
pub struct AuditItem {
    /// Rang dans la chaîne de la portée.
    pub seq: i64,
    /// Entrée enregistrée.
    pub event: serde_json::Value,
    /// Empreinte de l'entrée.
    pub entry_hash: String,
    /// Enregistrement.
    pub created_at: SecretsDatetime,
}

/// Résultat de `fn::secrets_audit_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AuditList {
    /// Entrées de la page, les plus récentes d'abord.
    pub items: Vec<AuditItem>,
    /// Total.
    pub total: i64,
}

/// Paramètres de `fn::secrets_audit_verify`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct AuditVerifyParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Premier rang vérifié.
    pub from_seq: Option<i64>,
    /// Entrées vérifiées (10000 au plus).
    pub limit: Option<i64>,
}

/// Résultat de `fn::secrets_audit_verify`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AuditReport {
    /// Chaîne intacte.
    pub valid: bool,
    /// Entrées vérifiées.
    pub checked: i64,
    /// Premier rang en défaut.
    pub broken_at: Option<i64>,
    /// Fin de chaîne conforme à la tête.
    pub head_matches: bool,
    /// Plage vérifiée jusqu'au bout.
    pub complete: bool,
}

/// Paramètres de `fn::secrets_audit_denied` : lecture refusée, journalisée par la session
/// système au nom de l'appelant (R6).
#[derive(Debug, Clone, SurrealValue)]
pub struct AuditDeniedParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Code du refus.
    pub code: String,
    /// Type de session de l'appelant (`interactive`, `service`, `api_key`, `system`).
    pub session_kind: String,
    /// Identité de l'appelant (`auth_identity:<clé>`).
    pub actor: Option<String>,
    /// Application de l'appelant (`auth_application:<clé>`).
    pub application: Option<String>,
    /// Session de l'appelant (`auth_session:<clé>`).
    pub session: Option<String>,
    /// Consommateur annoncé.
    pub consumer: Option<String>,
    /// Version demandée.
    pub version: Option<i64>,
}

/// Résultat de `fn::secrets_audit_denied`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AuditDenied {
    /// Rang de l'entrée.
    pub seq: i64,
}
