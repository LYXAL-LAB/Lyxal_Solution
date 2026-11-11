//! File d'envoi : réservation, achèvement, échec, purge (`fn::notification_job_*`,
//! `fn::notification_purge`).

use lyxal_i18n::ResolvedText;
use lyxal_surreal::SurrealValue;

use super::trigger::Recipient;
use super::types::{NotificationDatetime, NotificationRecordId};

/// Paramètres de `fn::notification_job_claim`.
#[derive(Debug, Clone, SurrealValue)]
pub struct JobClaimParams {
    /// Identifiant du worker (journalisé sur l'étape).
    pub worker_id: String,
    /// Étapes au plus (1 à 100).
    pub limit: i64,
    /// Durée de la réservation en secondes (10 à 3600).
    pub lease_seconds: i64,
}

/// Étape réservée, avec tout le nécessaire au rendu.
#[derive(Clone, SurrealValue)]
pub struct ClaimedJob {
    /// Étape.
    pub job_id: NotificationRecordId,
    /// Jeton de réservation.
    pub claim_token: String,
    /// Déclenchement.
    pub run_id: NotificationRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<NotificationRecordId>,
    /// Clé de l'organisation (contexte de scellement).
    pub tenant_key: Option<String>,
    /// Nom de l'organisation (variable `organization.name`).
    pub organization_name: Option<String>,
    /// Clé d'idempotence (contexte de scellement).
    pub idempotency_key: String,
    /// Tentative en cours (1 pour la première).
    pub attempt: i64,
    /// Destinataire.
    pub recipient: Recipient,
    /// Langue de l'envoi : celle du destinataire, sinon de son organisation, sinon de
    /// l'installation (absente si elle n'a pas pu être choisie, voir `texts_error`).
    pub locale: Option<String>,
    /// Objet (gabarit) ; absent si l'étape n'a pas de gabarit.
    pub subject: Option<String>,
    /// Corps HTML (gabarit).
    pub html_body: Option<String>,
    /// Corps texte (gabarit).
    pub text_body: Option<String>,
    /// Textes des clés `lyxal_i18n` du gabarit, dans la langue de l'envoi (repli compris).
    pub texts: Vec<ResolvedText>,
    /// Code `I18N_*` si la langue ou les textes n'ont pas pu être lus : rien n'est rendu.
    pub texts_error: Option<String>,
    /// Mise en page HTML.
    pub layout_html: Option<String>,
    /// Mise en page texte.
    pub layout_text: Option<String>,
    /// Variables non sensibles.
    pub payload: serde_json::Value,
    /// Variables sensibles scellées (`enc:v2`, contexte du module).
    pub secret: Option<String>,
    /// Parcours sensible : aucun objet conservé.
    pub sensitive: bool,
    /// Nom d'expéditeur des réglages.
    pub from_name: Option<String>,
    /// Adresse de réponse des réglages.
    pub reply_to: Option<String>,
}

impl std::fmt::Debug for ClaimedJob {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ClaimedJob")
            .field("job_id", &self.job_id)
            .field("run_id", &self.run_id)
            .field("tenant", &self.tenant)
            .field("attempt", &self.attempt)
            .field("locale", &self.locale)
            .field("sensitive", &self.sensitive)
            .field("secret", &self.secret.as_ref().map(|_| "[REDACTED]"))
            .finish_non_exhaustive()
    }
}

/// Paramètres de `fn::notification_job_renew`.
#[derive(Debug, Clone, SurrealValue)]
pub struct JobRenewParams {
    /// Étape (texte `notification_job:<clé>`).
    pub job_id: String,
    /// Jeton de réservation.
    pub claim_token: String,
    /// Nouvelle durée de la réservation en secondes (10 à 3600).
    pub lease_seconds: i64,
}

/// Résultat de `fn::notification_job_renew`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct JobRenewed {
    /// Fin de la réservation.
    pub locked_until: NotificationDatetime,
}

/// Paramètres de `fn::notification_job_release`.
#[derive(Debug, Clone, SurrealValue)]
pub struct JobReleaseParams {
    /// Étape (texte `notification_job:<clé>`).
    pub job_id: String,
    /// Jeton de réservation.
    pub claim_token: String,
}

/// Résultat de `fn::notification_job_release`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct JobReleased {
    /// État de l'étape (`queued`).
    pub status: String,
}

/// Paramètres de `fn::notification_job_complete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct JobCompleteParams {
    /// Étape (texte `notification_job:<clé>`).
    pub job_id: String,
    /// Jeton de réservation.
    pub claim_token: String,
    /// Identifiant du message chez le fournisseur (`Message-ID`).
    pub provider_message_id: Option<String>,
    /// Code de réponse SMTP.
    pub smtp_code: Option<i64>,
    /// Objet rendu (ignoré pour un parcours sensible).
    pub subject: Option<String>,
}

/// Résultat de `fn::notification_job_complete`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct JobCompleted {
    /// Message enregistré.
    pub message: NotificationRecordId,
    /// État de l'étape (`completed`).
    pub status: String,
    /// État du déclenchement s'il est terminé.
    pub run_status: Option<String>,
}

/// Classe d'un échec d'envoi.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FailureClass {
    /// Échec temporaire : nouvelle tentative tant que le plafond n'est pas atteint.
    Transient,
    /// Échec définitif.
    Permanent,
    /// Destinataire refusé : échec définitif et adresse supprimée.
    RecipientRejected,
}

impl FailureClass {
    /// Valeur attendue par `fn::notification_job_fail`.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Transient => "transient",
            Self::Permanent => "permanent",
            Self::RecipientRejected => "recipient_rejected",
        }
    }
}

/// Paramètres de `fn::notification_job_fail`.
#[derive(Debug, Clone, SurrealValue)]
pub struct JobFailParams {
    /// Étape (texte `notification_job:<clé>`).
    pub job_id: String,
    /// Jeton de réservation.
    pub claim_token: String,
    /// Classe (`FailureClass::as_str`).
    pub class: String,
    /// Code (SMTP ou `NOTIFICATION_*`).
    pub code: String,
    /// Détail, jamais de secret ni de contenu.
    pub detail: Option<String>,
    /// Délai avant une nouvelle tentative.
    pub retry_delay_seconds: i64,
}

/// Résultat de `fn::notification_job_fail`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct JobFailed {
    /// État de l'étape (`queued` ou `failed`).
    pub status: String,
    /// Prochaine tentative.
    pub next_retry_at: Option<NotificationDatetime>,
    /// État du déclenchement s'il est terminé.
    pub run_status: Option<String>,
}

/// Paramètres de `fn::notification_purge`.
#[derive(Debug, Clone, SurrealValue)]
pub struct PurgeParams {
    /// Éléments au plus par catégorie (1 à 10 000).
    pub limit: i64,
}

/// Résultat de `fn::notification_purge`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct PurgeResult {
    /// Secrets expirés effacés.
    pub secrets_cleared: i64,
    /// Entrées du journal supprimées.
    pub log_entries: i64,
    /// Déclenchements supprimés (étapes et messages avec eux).
    pub runs: i64,
}

/// Paramètres de `fn::notification_settings_get`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsGetParams {
    /// Organisation (texte), réglages de l'installation si absente.
    pub tenant: Option<String>,
}

/// Réglages effectifs.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct EffectiveSettings {
    /// Nom d'expéditeur.
    pub from_name: Option<String>,
    /// Adresse de réponse.
    pub reply_to: Option<String>,
    /// Tentatives au plus.
    pub max_attempts: i64,
    /// Conservation des déclenchements (jours).
    pub retention_days_runs: i64,
    /// Conservation du journal (jours).
    pub retention_days_log: i64,
}

/// Résultat de `fn::notification_settings_get`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Settings {
    /// Réglages effectifs (organisation sur installation).
    pub effective: EffectiveSettings,
}
