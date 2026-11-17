//! Déclenchement d'un parcours (`fn::notification_trigger`).

use lyxal_surreal::SurrealValue;

use super::subscriber::SubscriberInput;
use super::types::{NotificationDatetime, NotificationRecordId};
use super::workflow::TriggerOverrides;

/// Destinataire d'un message, tel que le rendu le voit (`recipient` des gabarits) : adresse
/// copiée de l'abonné au déclenchement.
#[derive(Clone, PartialEq, SurrealValue)]
pub struct Recipient {
    /// Adresse e-mail (normalisée par la base), absente pour un abonné sans e-mail.
    pub email: Option<String>,
    /// Téléphone (E.164), absent pour un abonné sans téléphone.
    pub phone: Option<String>,
    /// Langue préférée (BCP 47).
    pub locale: Option<String>,
    /// Prénom affiché.
    pub name: Option<String>,
}

impl std::fmt::Debug for Recipient {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Recipient")
            .field("locale", &self.locale)
            .finish_non_exhaustive()
    }
}

/// Destinataire(s) d'un déclenchement (`to`).
#[derive(Debug, Clone, SurrealValue)]
#[surreal(untagged)]
pub enum TriggerTarget {
    /// Un abonné, créé ou mis à jour à la volée (un identifiant seul doit exister).
    Subscriber(SubscriberInput),
    /// Une liste de 100 abonnés au plus (un déclenchement par abonné, clé `<clé>/<subscriber_id>`).
    List(Vec<SubscriberInput>),
    /// Diffusion à un sujet (traitée par le worker).
    Topic {
        /// Clé du sujet.
        topic: String,
    },
    /// Diffusion à tous les abonnés de la portée (traitée par le worker) ; `all` vaut `true`.
    All {
        /// Toujours `true`.
        all: bool,
    },
}

/// Paramètres de `fn::notification_trigger`. Les identifiants transmis sont des textes
/// `table:clé` (règle `record` de `lyxal_core`).
#[derive(Clone, SurrealValue)]
pub struct TriggerParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Clé du parcours (ou `trigger_event`).
    pub workflow_key: Option<String>,
    /// Type d'événement déclencheur (ou `workflow_key`).
    pub trigger_event: Option<String>,
    /// Clé d'idempotence (identifiant d'événement ou clé fournie).
    pub idempotency_key: String,
    /// Événement d'origine.
    pub event_id: Option<String>,
    /// Destinataire(s).
    pub to: TriggerTarget,
    /// `subscriber_id` de l'auteur de l'action.
    pub actor: Option<String>,
    /// Auteur exclu (vrai par défaut).
    pub exclude_actor: Option<bool>,
    /// Variables non sensibles (objet JSON).
    pub payload: serde_json::Value,
    /// Surcharges des étapes pour ce déclenchement.
    pub overrides: Option<TriggerOverrides>,
    /// Variables sensibles scellées sous le contexte du module (`enc:v2`) ; un seul abonné.
    pub secret: Option<String>,
    /// Fin de validité du secret.
    pub expires_at: Option<NotificationDatetime>,
}

impl std::fmt::Debug for TriggerParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("TriggerParams")
            .field("tenant", &self.tenant)
            .field("workflow_key", &self.workflow_key)
            .field("trigger_event", &self.trigger_event)
            .field("idempotency_key", &self.idempotency_key)
            .field("event_id", &self.event_id)
            .field("to", &self.to)
            .field("overrides", &self.overrides)
            .field("secret", &self.secret.as_ref().map(|_| "[REDACTED]"))
            .field("expires_at", &self.expires_at)
            .finish_non_exhaustive()
    }
}

/// Forme d'un déclenchement.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum TriggerKind {
    /// Un abonné.
    Subscriber,
    /// Une liste d'abonnés.
    List,
    /// Une diffusion (sujet ou tous).
    Broadcast,
}

/// Issue d'un déclenchement pour un abonné, ou d'une diffusion.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum TriggerStatus {
    /// Déclenchement (ou diffusion) créé.
    Created,
    /// Clé déjà utilisée : déclenchement existant renvoyé.
    Duplicate,
    /// Écarté : adresse supprimée, préférence, auteur de l'action.
    Skipped,
}

/// Issue d'un abonné d'une liste.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct ListRun {
    /// Identifiant de l'abonné.
    pub subscriber_id: String,
    /// `created`, `duplicate`, `skipped`, `no_address` ou `rejected`.
    pub status: String,
    /// Déclenchement.
    pub run_id: Option<NotificationRecordId>,
    /// Motif d'abandon.
    pub skip_reason: Option<String>,
    /// Code d'erreur d'un abonné refusé (`NOTIFICATION_*`).
    pub code: Option<String>,
}

/// Résultat de `fn::notification_trigger`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct TriggerResult {
    /// Forme du déclenchement.
    pub kind: TriggerKind,
    /// Issue (abonné ou diffusion).
    pub status: Option<TriggerStatus>,
    /// Abonné (un abonné).
    pub subscriber: Option<NotificationRecordId>,
    /// Déclenchement (un abonné ; absent si écarté avant sa création).
    pub run_id: Option<NotificationRecordId>,
    /// Motif d'abandon (`suppressed:<motif>`, `preference:<niveau>`, `condition`, `throttled`,
    /// `actor`…).
    pub skip_reason: Option<String>,
    /// Étapes engagées (ou existantes pour un rejeu) : les premières étapes du parcours.
    #[surreal(default)]
    pub job_ids: Vec<NotificationRecordId>,
    /// Issue par abonné (liste).
    #[surreal(default)]
    pub runs: Vec<ListRun>,
    /// Diffusion (sujet ou tous).
    pub broadcast_id: Option<NotificationRecordId>,
}
