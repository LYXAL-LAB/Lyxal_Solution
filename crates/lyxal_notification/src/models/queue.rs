//! File d'envoi : réservation, achèvement, échec, purge (`fn::notification_job_*`,
//! `fn::notification_purge`).

use lyxal_i18n::ResolvedText;
use lyxal_surreal::SurrealValue;

use super::endpoint::{ClaimedEndpoint, EndpointOutcome};
use super::feed::TemplateAction;
use super::integration::ClaimedIntegration;
use super::preference::QuietHoursRule;
use super::trigger::Recipient;
use super::types::{NotificationDatetime, NotificationRecordId};
use super::workflow::DigestVars;

/// Paramètres de `fn::notification_job_claim`.
#[derive(Debug, Clone, SurrealValue)]
pub struct JobClaimParams {
    /// Identifiant du worker (journalisé sur l'étape).
    pub worker_id: String,
    /// Canal servi par le worker (`email`, `sms`, `chat`, `webhook`, `in_app`).
    pub channel: String,
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
    /// Canal de l'étape (`email`, `sms`, `chat`, `webhook`, `in_app`).
    pub channel: String,
    /// Étape du parcours.
    pub step_key: String,
    /// Parcours (clé).
    pub workflow_key: String,
    /// Abonné (identifiant de l'application), absent s'il a été supprimé.
    pub subscriber_id: Option<String>,
    /// Destinataire.
    pub recipient: Recipient,
    /// Hôtes autorisés de l'installation pour les adresses web et Mattermost (vide : tout hôte
    /// public, décision E3).
    pub allowed_hosts: Vec<String>,
    /// Messagerie, adresse web : adresses scellées de l'abonné pas encore servies, chacune avec
    /// l'intégration de son service.
    #[surreal(default)]
    pub endpoints: Vec<ClaimedEndpoint>,
    /// Messagerie, adresse web : adresses déjà servies par une tentative précédente.
    #[surreal(default)]
    pub served_endpoints: i64,
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
    /// Fil : avatar (gabarit d'un lien).
    #[surreal(default)]
    pub avatar: Option<String>,
    /// Fil et push : lien de redirection (gabarit).
    #[surreal(default)]
    pub redirect: Option<String>,
    /// Fil : boutons (gabarits du libellé et du lien), deux au plus.
    #[surreal(default)]
    pub actions: Vec<TemplateAction>,
    /// Fil et push : données libres `{ clé : gabarit }`.
    #[surreal(default)]
    pub data_templates: serde_json::Value,
    /// Push : icône (gabarit d'un lien).
    #[surreal(default)]
    pub icon: Option<String>,
    /// Variables non sensibles.
    pub payload: serde_json::Value,
    /// Variables sensibles scellées (`enc:v2`, contexte du module) ; jamais pour le fil.
    pub(crate) secret: Option<String>,
    /// Parcours sensible : aucun objet conservé.
    pub sensitive: bool,
    /// Parcours critique : ni heures calmes ni lien de désabonnement.
    pub critical: bool,
    /// Heures calmes de l'abonné (absentes pour un parcours critique).
    pub quiet_hours: Option<QuietHoursRule>,
    /// Regroupement porté par le déclenchement : nombre et données des événements.
    pub digest: Option<DigestVars>,
    /// Cible du lien de désabonnement (absente pour un parcours critique).
    pub unsubscribe: Option<UnsubscribeTarget>,
    /// Intégration de l'envoi (D1, bascule D3) : fournisseur, réglages, chemin des identifiants ;
    /// absente pour le fil (ni fournisseur ni intégration).
    pub integration: Option<ClaimedIntegration>,
}

/// Cible du lien de désabonnement d'un message : la catégorie du parcours, sinon le parcours.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct UnsubscribeTarget {
    /// Portée (`installation` ou clé de l'organisation).
    pub scope: String,
    /// Abonné.
    pub subscriber: NotificationRecordId,
    /// Catégorie du parcours.
    pub category: Option<NotificationRecordId>,
    /// Parcours (sans catégorie).
    pub workflow: Option<NotificationRecordId>,
    /// Canal.
    pub channel: String,
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
            .field("critical", &self.critical)
            .field("quiet_hours", &self.quiet_hours)
            .field("integration", &self.integration.as_ref().map(|i| &i.id))
            .field("channel", &self.channel)
            .field("endpoints", &self.endpoints)
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
    /// Reprise au plus tôt (fin des heures calmes) ; immédiate si absente.
    pub not_before: Option<NotificationDatetime>,
}

/// Résultat de `fn::notification_job_release`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct JobReleased {
    /// État de l'étape (`queued`).
    pub status: String,
    /// Prochaine exécution possible.
    pub next_retry_at: NotificationDatetime,
}

/// Paramètres de `fn::notification_job_complete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct JobCompleteParams {
    /// Étape (texte `notification_job:<clé>`).
    pub job_id: String,
    /// Jeton de réservation.
    pub claim_token: String,
    /// Intégration qui a envoyé le message.
    pub integration: String,
    /// Identifiant du message chez le fournisseur.
    pub provider_message_id: Option<String>,
    /// Code de réponse du fournisseur (SMTP ou HTTP).
    pub response_code: Option<i64>,
    /// Objet rendu (ignoré pour un parcours sensible).
    pub subject: Option<String>,
    /// SMS : nombre de parties (1 à 10).
    pub parts: Option<i64>,
    /// Messagerie, adresse web : issue de chaque adresse servie.
    pub endpoints: Vec<EndpointOutcome>,
}

/// Résultat de `fn::notification_job_complete`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct JobCompleted {
    /// Messages de l'étape (un par adresse servie pour la messagerie et l'adresse web).
    pub messages: Vec<NotificationRecordId>,
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
    /// Destinataire refusé : échec définitif et adresse supprimée (rejet définitif).
    RecipientRejected,
    /// Destinataire désinscrit chez l'opérateur (SMS : STOP) : échec définitif et numéro
    /// supprimé (plainte).
    RecipientOptedOut,
}

impl FailureClass {
    /// Valeur attendue par `fn::notification_job_fail`.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Transient => "transient",
            Self::Permanent => "permanent",
            Self::RecipientRejected => "recipient_rejected",
            Self::RecipientOptedOut => "recipient_opted_out",
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
    /// Intégration de cette tentative (la suivante passe à la prochaine éligible après un échec
    /// temporaire) ; absente pour le fil.
    pub integration: Option<String>,
    /// Classe (`FailureClass::as_str`).
    pub class: String,
    /// Code (SMTP ou `NOTIFICATION_*`).
    pub code: String,
    /// Détail, jamais de secret ni de contenu.
    pub detail: Option<String>,
    /// Délai avant une nouvelle tentative.
    pub retry_delay_seconds: i64,
    /// Messagerie, adresse web : issue de chaque adresse servie par cette tentative (les
    /// adresses servies ne sont pas rappelées à la suivante).
    pub endpoints: Vec<EndpointOutcome>,
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

/// Arguments de la purge (ceux de la tâche `notification.purge` du planificateur).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct PurgeArgs {
    /// Éléments au plus par catégorie (1 à 10 000, 1 000 par défaut).
    pub limit: Option<i64>,
}

/// Paramètres de `fn::notification_purge`, forme d'appel du planificateur réduite à ses
/// arguments.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct PurgeParams {
    /// Arguments.
    pub args: PurgeArgs,
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
    /// Diffusions terminées supprimées.
    pub broadcasts: i64,
    /// Regroupements fermés supprimés.
    pub digests: i64,
    /// Compteurs de limitation expirés supprimés.
    pub rate_limits: i64,
    /// Retours des fournisseurs supprimés.
    pub provider_events: i64,
    /// Messages du fil supprimés (réglage `retention_days_inbox`).
    pub inbox_items: i64,
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
    /// Fuseau horaire par défaut des abonnés.
    pub timezone: Option<String>,
    /// Tentatives au plus.
    pub max_attempts: i64,
    /// Conservation des déclenchements (jours).
    pub retention_days_runs: i64,
    /// Conservation du journal (jours).
    pub retention_days_log: i64,
    /// Conservation des messages du fil (jours).
    pub retention_days_inbox: i64,
    /// Durée maximale d'une attente ou d'une fenêtre (jours).
    pub max_wait_days: i64,
    /// Hôtes autorisés de l'installation (adresses web et Mattermost ; vide : tout hôte public).
    pub allowed_hosts: Vec<String>,
}

/// Résultat de `fn::notification_settings_get`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Settings {
    /// Réglages effectifs (organisation sur installation).
    pub effective: EffectiveSettings,
}
