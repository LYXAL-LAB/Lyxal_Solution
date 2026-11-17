//! Parcours à étapes : étapes typées, surcharges d'un déclenchement, envoi groupé, annulation,
//! envoi de test, attentes confiées au planificateur et aperçu d'une étape
//! (`fn::notification_trigger_bulk`, `_cancel`, `_test_send`, `_wait_schedule`,
//! `_step_preview`).

use lyxal_i18n::ResolvedText;
use lyxal_surreal::{SurrealValue, Value};
use std::collections::BTreeMap;

use super::subscriber::SubscriberInput;
use super::trigger::{TriggerParams, TriggerResult};
use super::types::NotificationRecordId;

/// Unité d'une durée d'étape.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum SpanUnit {
    /// Secondes.
    Seconds,
    /// Minutes.
    Minutes,
    /// Heures.
    Hours,
    /// Jours.
    Days,
    /// Semaines.
    Weeks,
}

/// Durée d'une étape (`{ amount, unit }`) : attente, fenêtre, recul ; `amount` signé pour le
/// décalage d'une attente sur une date des données.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct StepSpan {
    /// Quantité.
    pub amount: i64,
    /// Unité.
    pub unit: SpanUnit,
}

/// Étape d'un parcours (`notification_workflow.steps`), forme contrôlée par
/// `fn::notification_step_check`. `condition` : condition `lyxal_core` sur
/// `{ payload, subscriber, steps }` ; fausse, l'étape est sautée.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
#[surreal(tag = "type", rename_all = "snake_case")]
pub enum WorkflowStep {
    /// Envoi d'un e-mail.
    Email {
        /// Clé de l'étape, unique dans le parcours.
        key: String,
        /// Condition d'exécution.
        condition: Option<serde_json::Value>,
    },
    /// Attente : une durée (`amount` + `unit`), ou une date lue dans les données (`until`),
    /// décalée de `offset`.
    Delay {
        /// Clé de l'étape.
        key: String,
        /// Condition d'exécution.
        condition: Option<serde_json::Value>,
        /// Durée.
        amount: Option<i64>,
        /// Unité de la durée.
        unit: Option<SpanUnit>,
        /// Chemin d'une date RFC 3339 dans les données (ex. `payload.rendez_vous`).
        until: Option<String>,
        /// Décalage de la date (ex. −1 jour).
        offset: Option<StepSpan>,
    },
    /// Regroupement : les déclenchements de même clé pendant la fenêtre partent en un message.
    Digest {
        /// Clé de l'étape.
        key: String,
        /// Condition d'exécution.
        condition: Option<serde_json::Value>,
        /// Fenêtre.
        window: StepSpan,
        /// Chemin de la clé de regroupement dans les données.
        group_by: Option<String>,
        /// Recul : sans arrivée pour la clé depuis cette durée, le message part tout de suite.
        lookback: Option<StepSpan>,
    },
    /// Limitation : au plus `limit` messages par fenêtre fixe.
    Throttle {
        /// Clé de l'étape.
        key: String,
        /// Condition d'exécution.
        condition: Option<serde_json::Value>,
        /// Messages au plus par fenêtre (1 à 1000).
        limit: i64,
        /// Fenêtre.
        window: StepSpan,
        /// Chemin de la clé de limitation dans les données.
        group_by: Option<String>,
    },
}

impl WorkflowStep {
    /// Clé de l'étape.
    pub fn key(&self) -> &str {
        match self {
            Self::Email { key, .. }
            | Self::Delay { key, .. }
            | Self::Digest { key, .. }
            | Self::Throttle { key, .. } => key,
        }
    }
}

/// Surcharge d'une étape pour un déclenchement : la sauter, changer la durée d'une attente ou
/// la fenêtre d'un regroupement.
#[derive(Debug, Clone, Default, PartialEq, Eq, SurrealValue)]
pub struct StepOverride {
    /// Étape sautée.
    pub skip: Option<bool>,
    /// Durée d'une attente.
    pub amount: Option<i64>,
    /// Unité de la durée d'une attente.
    pub unit: Option<SpanUnit>,
    /// Fenêtre d'un regroupement.
    pub window: Option<StepSpan>,
}

/// Surcharges d'un déclenchement, par clé d'étape.
#[derive(Debug, Clone, Default, PartialEq, Eq, SurrealValue)]
pub struct TriggerOverrides {
    /// Surcharges par clé d'étape.
    pub steps: BTreeMap<String, StepOverride>,
}

/// Paramètres de `fn::notification_trigger_bulk` : 1 à 100 déclenchements.
#[derive(Debug, Clone, SurrealValue)]
pub struct TriggerBulkParams {
    /// Déclenchements, chacun comme `fn::notification_trigger`.
    pub events: Vec<TriggerParams>,
}

/// Erreur d'une entrée de l'envoi groupé.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct BulkError {
    /// Code `NOTIFICATION_*`.
    pub code: String,
    /// Détails de l'erreur.
    pub details: Option<serde_json::Value>,
}

/// Issue d'une entrée de l'envoi groupé.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct BulkEntry {
    /// Position dans `events`.
    pub index: i64,
    /// Déclenchement accepté.
    pub ok: bool,
    /// Résultat du déclenchement.
    pub data: Option<TriggerResult>,
    /// Erreur du déclenchement.
    pub error: Option<BulkError>,
}

/// Résultat de `fn::notification_trigger_bulk`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct TriggerBulkResult {
    /// Issue par entrée, dans l'ordre.
    pub results: Vec<BulkEntry>,
}

/// Paramètres de `fn::notification_cancel`.
#[derive(Debug, Clone, SurrealValue)]
pub struct CancelParams {
    /// Organisation (texte), installation si absente.
    pub tenant: Option<String>,
    /// Clé d'idempotence du déclenchement (ses abonnés `<clé>/…` compris).
    pub idempotency_key: String,
}

/// Résultat de `fn::notification_cancel`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct CancelResult {
    /// Déclenchements annulés.
    pub canceled: i64,
    /// Leurs identifiants.
    pub runs: Vec<NotificationRecordId>,
}

/// Paramètres de `fn::notification_test_send`.
#[derive(Debug, Clone, SurrealValue)]
pub struct TestSendParams {
    /// Organisation (texte), installation si absente.
    pub tenant: Option<String>,
    /// Clé du parcours (quel que soit son état).
    pub workflow_key: String,
    /// Abonné destinataire.
    pub to: SubscriberInput,
    /// Données (objet JSON).
    pub payload: serde_json::Value,
}

/// Paramètres de `fn::notification_wait_schedule`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct WaitScheduleParams {
    /// Attentes au plus par passage (1 à 500, 100 par défaut).
    pub limit: Option<i64>,
}

/// Résultat de `fn::notification_wait_schedule`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct WaitScheduleResult {
    /// Attentes confiées au planificateur.
    pub scheduled: i64,
    /// Attentes déjà échues, reprises tout de suite.
    pub resumed: i64,
    /// Attentes refusées par le planificateur (restées en file).
    pub failed: i64,
    /// Codes des refus.
    pub codes: Vec<String>,
    /// Paquet plein : d'autres attentes attendent.
    pub more: bool,
}

/// Regroupement passé au rendu (`digest` des gabarits).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct DigestVars {
    /// Événements regroupés.
    pub count: i64,
    /// Données des événements (100 au plus) : `[{ payload, at }]`.
    pub events: serde_json::Value,
}

/// Paramètres de `fn::notification_step_preview`.
#[derive(Debug, Clone, SurrealValue)]
pub struct StepPreviewParams {
    /// Parcours (texte `notification_workflow:<clé>`).
    pub workflow: String,
    /// Étape de canal.
    pub step_key: String,
    /// Données d'exemple (objet JSON).
    pub payload: serde_json::Value,
    /// Langue demandée (BCP 47).
    pub locale: Option<String>,
    /// Regroupement d'exemple.
    pub digest: Option<DigestVars>,
}

/// Résultat de `fn::notification_step_preview` : données du rendu, sans secret.
#[derive(Debug, Clone, SurrealValue)]
pub struct StepPreviewResult {
    /// Parcours.
    pub workflow: NotificationRecordId,
    /// Étape.
    pub step_key: String,
    /// Langue retenue.
    pub locale: Option<String>,
    /// Langue demandée (région gardée pour les nombres et les dates).
    pub recipient_locale: Option<String>,
    /// Nom de l'organisation (s'il est lisible).
    pub organization_name: Option<String>,
    /// Objet (gabarit).
    pub subject: Option<String>,
    /// Corps HTML (gabarit).
    pub html_body: Option<String>,
    /// Corps texte (gabarit).
    pub text_body: Option<String>,
    /// Textes des clés du gabarit dans la langue retenue.
    pub texts: Vec<ResolvedText>,
    /// Code `I18N_*` si la langue ou les textes n'ont pas pu être lus.
    pub texts_error: Option<String>,
    /// Mise en page HTML.
    pub layout_html: Option<String>,
    /// Mise en page texte.
    pub layout_text: Option<String>,
    /// Données d'exemple.
    pub payload: serde_json::Value,
    /// Regroupement d'exemple.
    pub digest: Option<DigestVars>,
}
