//! Intégrations (fournisseur d'un canal par portée) et retours des fournisseurs
//! (`fn::notification_integration_*`, `fn::notification_provider_event_record`). Aucune valeur
//! secrète : une intégration ne porte que les chemins de ses secrets dans `lyxal_secrets`.

use lyxal_surreal::SurrealValue;

use super::types::{NotificationDatetime, NotificationRecordId};

/// Réglages non secrets d'une intégration.
#[derive(Debug, Clone, Default, PartialEq, Eq, SurrealValue)]
pub struct IntegrationSettings {
    /// E-mail : adresse d'expédition.
    #[surreal(default)]
    pub from_address: Option<String>,
    /// Nom d'expéditeur.
    #[surreal(default)]
    pub from_name: Option<String>,
    /// Adresse de réponse.
    #[surreal(default)]
    pub reply_to: Option<String>,
    /// SMTP : hôte du relais.
    #[surreal(default)]
    pub host: Option<String>,
    /// SMTP : port.
    #[surreal(default)]
    pub port: Option<i64>,
    /// SMTP : `tls`, `starttls` ou `local_plain` (installation, boucle locale).
    #[surreal(default)]
    pub security: Option<String>,
    /// Mailgun : domaine d'envoi.
    #[surreal(default)]
    pub domain: Option<String>,
    /// Mailgun : région de l'API (`us` ou `eu`).
    #[surreal(default)]
    pub region: Option<String>,
    /// SMS : expéditeur (numéro E.164 ou nom court de 11 caractères au plus).
    #[surreal(default)]
    pub sender: Option<String>,
}

/// Intégration remise au worker (étape réservée) ou à l'hôte (essai, retours) : fournisseur,
/// réglages et chemins des secrets dans sa portée.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct ClaimedIntegration {
    /// Intégration.
    pub id: NotificationRecordId,
    /// Organisation (absente pour l'installation) : portée de ses secrets.
    pub tenant: Option<NotificationRecordId>,
    /// Clé dans la portée.
    pub key: String,
    /// Canal (`email`, `sms`, `chat`, `webhook`).
    pub channel: String,
    /// Fournisseur (e-mail : `smtp`, `brevo`, `mailgun`, `postmark`, `resend` ; SMS : `brevo`,
    /// `twilio`, `vonage` ; messagerie : `slack`, `teams`, `discord`, `mattermost`,
    /// `google_chat`, `telegram` ; adresse web : `webhook`).
    pub provider: String,
    /// Réglages non secrets.
    pub settings: IntegrationSettings,
    /// Chemin du secret des identifiants (absent pour une messagerie autre que Telegram et pour
    /// l'adresse web).
    pub credentials_path: Option<String>,
    /// Chemin du secret des retours.
    pub webhook_path: Option<String>,
}

/// Intégration telle que la rendent les fonctions de gestion (jamais de valeur secrète).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Integration {
    /// Intégration.
    pub id: NotificationRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<NotificationRecordId>,
    /// Clé dans la portée.
    pub key: String,
    /// Canal.
    pub channel: String,
    /// Fournisseur.
    pub provider: String,
    /// Nom.
    pub name: String,
    /// Active.
    pub active: bool,
    /// Principale de la portée pour son canal.
    pub primary: bool,
    /// Ordre après la principale (plus petit d'abord).
    pub priority: i64,
    /// Condition `lyxal_core` facultative.
    pub condition: Option<serde_json::Value>,
    /// Réglages non secrets.
    pub settings: IntegrationSettings,
    /// Chemin du secret des identifiants.
    pub credentials_path: Option<String>,
    /// Chemin du secret des retours.
    pub webhook_path: Option<String>,
    /// Dernier essai.
    pub last_test: Option<IntegrationTestResult>,
}

/// Issue du dernier essai d'une intégration.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct IntegrationTestResult {
    /// Date.
    pub at: NotificationDatetime,
    /// Message accepté par le fournisseur.
    pub ok: bool,
    /// Code d'erreur (`NOTIFICATION_*`) d'un essai refusé.
    pub code: Option<String>,
}

/// Paramètres de `fn::notification_integration_create` et `_update` (en modification, seuls
/// les champs fournis changent ; `provider` et `channel` ne sont acceptés qu'à la création).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct IntegrationSaveParams {
    /// Organisation (texte), installation si absente.
    pub tenant: Option<String>,
    /// Clé dans la portée.
    pub key: String,
    /// Fournisseur (création).
    pub provider: Option<String>,
    /// Canal (création, `email` par défaut ; `sms`, `chat`, `webhook`).
    pub channel: Option<String>,
    /// Nom.
    pub name: Option<String>,
    /// Active.
    pub active: Option<bool>,
    /// Principale (création ; ensuite `fn::notification_integration_set_primary`).
    pub primary: Option<bool>,
    /// Ordre après la principale.
    pub priority: Option<i64>,
    /// Condition `lyxal_core`.
    pub condition: Option<serde_json::Value>,
    /// Réglages (remplacés en entier en modification).
    pub settings: Option<IntegrationSettings>,
    /// Chemin du secret des identifiants.
    pub credentials_path: Option<String>,
    /// Chemin du secret des retours.
    pub webhook_path: Option<String>,
    /// Modification : retire la condition (`condition` est alors ignorée).
    pub clear_condition: Option<bool>,
    /// Modification : retire le secret des retours (`webhook_path` est alors ignoré).
    pub clear_webhook: Option<bool>,
}

/// Paramètres de `fn::notification_integration_get` (par identifiant).
#[derive(Debug, Clone, SurrealValue)]
pub struct IntegrationGetParams {
    /// Intégration (texte `notification_integration:<clé>`).
    pub integration: String,
}

/// Paramètres de `fn::notification_integration_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct IntegrationListParams {
    /// Organisation (texte), installation si absente.
    pub tenant: Option<String>,
    /// Canal.
    pub channel: Option<String>,
    /// Actives seulement (ou inactives seulement).
    pub active: Option<bool>,
}

/// Paramètres de `fn::notification_integration_delete` et `_set_primary`.
#[derive(Debug, Clone, SurrealValue)]
pub struct IntegrationRefParams {
    /// Organisation (texte), installation si absente.
    pub tenant: Option<String>,
    /// Clé dans la portée.
    pub key: String,
}

/// Paramètres de `fn::notification_integration_select` (worker).
#[derive(Debug, Clone, SurrealValue)]
pub struct IntegrationSelectParams {
    /// Étape de canal (texte `notification_job:<clé>`).
    pub job_id: String,
}

/// Paramètres de `fn::notification_integration_test` (D6, au nom de l'appelant).
#[derive(Debug, Clone, SurrealValue)]
pub struct IntegrationTestParams {
    /// Intégration (texte `notification_integration:<clé>`).
    pub integration: String,
    /// Destinataire de l'essai : e-mail, numéro E.164 (SMS), ou identifiant d'une adresse de
    /// messagerie ou web du même service.
    pub to: String,
}

/// Résultat de `fn::notification_integration_test` : de quoi envoyer l'essai.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct IntegrationTestTarget {
    /// Intégration.
    pub integration: ClaimedIntegration,
    /// Destinataire normalisé : e-mail, numéro E.164 (SMS), ou identifiant d'une adresse de
    /// messagerie ou web (`notification_endpoint:<clé>`).
    pub to: String,
}

/// Paramètres de `fn::notification_integration_test_record` (hôte).
#[derive(Debug, Clone, SurrealValue)]
pub struct IntegrationTestRecordParams {
    /// Intégration (texte `notification_integration:<clé>`).
    pub integration: String,
    /// Message accepté par le fournisseur.
    pub ok: bool,
    /// Code d'erreur d'un essai refusé.
    pub code: Option<String>,
}

/// Paramètres de `fn::notification_provider_event_record` (hôte, retour vérifié).
#[derive(Debug, Clone, SurrealValue)]
pub struct ProviderEventParams {
    /// Intégration (texte `notification_integration:<clé>`).
    pub integration: String,
    /// Identifiant de l'événement chez le fournisseur (dédoublonnage).
    pub event_id: String,
    /// `delivered`, `bounced`, `soft_bounced` ou `complained`.
    #[surreal(rename = "type")]
    pub kind: String,
    /// Identifiant du message chez le fournisseur.
    pub provider_message_id: Option<String>,
    /// Date de l'événement chez le fournisseur.
    pub occurred_at: Option<NotificationDatetime>,
}

/// Résultat de `fn::notification_provider_event_record`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct ProviderEventRecorded {
    /// Retour enregistré (ou déjà connu).
    pub event: NotificationRecordId,
    /// `recorded`, `duplicate` ou `unmatched` (message inconnu).
    pub status: String,
    /// Message lié.
    pub message: Option<NotificationRecordId>,
}
