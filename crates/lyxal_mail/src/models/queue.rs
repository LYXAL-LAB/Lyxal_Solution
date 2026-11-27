// SPDX-License-Identifier: AGPL-3.0-only

//! File d'envoi (`fn::mail_queue_*`, `fn::mail_return_record`, lot 6 §5 et §10.3) : réservation
//! sous bail et jeton, préparation, résultats gardés par la réservation, avis dus, mesures,
//! maintenance, avis reçus.

use lyxal_surreal::SurrealValue;

use super::submission::{
    AttemptStage, DsnNotify, DsnSettings, RecipientState, SubmissionOrigin, TlsInfo,
};
use super::types::{MailDatetime, MailRecordId};

/// Paramètres de `fn::mail_queue_claim`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueClaimParams {
    /// Nœud qui réserve (journal, mesures).
    pub node: String,
    /// Destinataires au plus (100 par défaut, 500 au plus).
    pub limit: Option<i64>,
    /// Durée du bail, en secondes (600 par défaut, 60 à 1 800).
    pub lease_seconds: Option<i64>,
    /// Domaines saturés du nœud, écartés (1 000 au plus).
    pub exclude_domains: Vec<String>,
}

/// Contenu d'un envoi en file.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct QueuedContent {
    /// Clé du fichier dans le bucket `lyxal-mail` de l'organisation.
    pub key: String,
    /// Fiche du fichier (`lyxal_storage`).
    pub object: Option<MailRecordId>,
    /// Taille du message, en octets.
    pub size: i64,
}

/// Destinataire réservé.
#[derive(Debug, Clone, SurrealValue)]
pub struct ClaimedRecipient {
    /// Destinataire en file.
    pub recipient: MailRecordId,
    /// Envoi.
    pub submission: MailRecordId,
    /// Organisation.
    pub tenant: MailRecordId,
    /// Origine de l'envoi.
    pub origin: SubmissionOrigin,
    /// Rang dans l'envoi.
    pub rank: i64,
    /// Adresse.
    pub address: String,
    /// Domaine de routage.
    pub domain: String,
    /// Route locale (domaine de l'installation).
    pub local: bool,
    /// `NOTIFY` (absent : défaut).
    pub notify: Option<Vec<DsnNotify>>,
    /// `ORCPT`.
    pub orcpt: Option<String>,
    /// Essais comptés.
    pub attempts: i64,
    /// Adresse d'enveloppe annoncée.
    pub sender: Option<String>,
    /// Adresses des champs d'en-tête.
    pub header_from: Vec<String>,
    /// Adresse d'enveloppe à utiliser (adresse de retour).
    pub envelope_from: Option<String>,
    /// Envoi préparé (sinon `fn::mail_queue_prepare` avant l'envoi).
    pub prepared: bool,
    /// Contenu.
    pub content: QueuedContent,
    /// En-têtes à placer devant le fichier.
    pub prefix: Option<String>,
    /// L'envoi exige `SMTPUTF8`.
    pub smtputf8: bool,
    /// Le contenu a des octets 8 bits.
    pub eight_bit: bool,
    /// Demande d'avis.
    pub dsn: DsnSettings,
    /// Taille du message, en octets.
    pub size: i64,
    /// Dépôt.
    pub created_at: MailDatetime,
    /// Fin de vie en file.
    pub expires_at: MailDatetime,
}

/// Résultat de `fn::mail_queue_claim`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueClaim {
    /// Jeton de la réservation (absent : rien à faire).
    pub claim: Option<String>,
    /// Fin du bail.
    pub locked_until: Option<MailDatetime>,
    /// Destinataires réservés, dans l'ordre de l'échéancier.
    pub items: Vec<ClaimedRecipient>,
}

/// Paramètres de `fn::mail_queue_renew`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueRenewParams {
    /// Jeton de la réservation.
    pub claim: String,
    /// Destinataires (1 à 500).
    pub recipients: Vec<String>,
    /// Durée du bail, en secondes (600 par défaut).
    pub lease_seconds: Option<i64>,
}

/// Résultat de `fn::mail_queue_renew`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueRenewed {
    /// Baux renouvelés.
    pub renewed: i64,
    /// Nouvelle fin du bail.
    pub locked_until: MailDatetime,
    /// Destinataires que la réservation ne tient plus.
    pub lost: Vec<MailRecordId>,
}

/// Paramètres de `fn::mail_queue_prepare`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueuePrepareParams {
    /// Jeton de la réservation.
    pub claim: String,
    /// Envoi (`mail_submission:<clé>`).
    pub submission: String,
    /// Jeton de l'adresse de retour (exigé sauf pour un expéditeur vide).
    pub return_token: Option<String>,
    /// En-têtes `DKIM-Signature` à placer devant le fichier.
    pub prefix: Option<String>,
    /// Message illisible : ses destinataires échouent (5.6.0).
    pub malformed: Option<bool>,
}

/// Action d'un avis de non-remise.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum DsnAction {
    /// Échec définitif ou expiration.
    Failed,
    /// Retard.
    Delayed,
    /// Remise (route locale).
    Delivered,
    /// Relais vers un serveur sans `DSN`.
    Relayed,
}

/// Avis dû par le worker.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct DsnDue {
    /// Envoi.
    pub submission: MailRecordId,
    /// Action.
    pub action: DsnAction,
    /// Destinataires du même avis.
    pub recipients: Vec<MailRecordId>,
}

/// Résultat de `fn::mail_queue_prepare`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueuePrepared {
    /// Envoi préparé.
    pub prepared: bool,
    /// Adresse d'enveloppe posée (adresse de retour).
    pub envelope_from: Option<String>,
    /// Destinataires en échec (message illisible).
    pub failed: i64,
    /// Avis dus.
    pub dsn: Vec<DsnDue>,
}

/// Issue d'une remise réussie.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum QueueOutcome {
    /// Accepté par le serveur final, ou remis par la route locale.
    Delivered,
    /// Accepté par un serveur sans `DSN`.
    Relayed,
}

/// Remise réussie d'un destinataire.
#[derive(Debug, Clone, SurrealValue)]
pub struct DeliveredItem {
    /// Destinataire (`mail_queue_recipient:<clé>`).
    pub recipient: String,
    /// Issue.
    pub outcome: QueueOutcome,
    /// Serveur distant.
    pub host: Option<String>,
    /// Code de réponse (2xx).
    pub code: Option<i64>,
    /// Code étendu.
    pub enhanced: Option<String>,
    /// TLS de la connexion.
    pub tls: Option<TlsInfo>,
    /// Date du résultat (maintenant par défaut).
    pub at: Option<MailDatetime>,
}

/// Paramètres de `fn::mail_queue_complete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueCompleteParams {
    /// Jeton de la réservation.
    pub claim: String,
    /// Remises (1 à 100).
    pub items: Vec<DeliveredItem>,
}

/// Résultat de `fn::mail_queue_complete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueCompleted {
    /// Avis dus.
    pub dsn: Vec<DsnDue>,
    /// Destinataires que la réservation ne tient plus (rien n'est écrit pour eux).
    pub lost: Vec<MailRecordId>,
}

/// Échec d'un destinataire.
#[derive(Debug, Clone, SurrealValue)]
pub struct FailedItem {
    /// Destinataire (`mail_queue_recipient:<clé>`).
    pub recipient: String,
    /// Refus définitif.
    pub permanent: bool,
    /// Étape.
    pub stage: AttemptStage,
    /// Code de réponse (4xx ou 5xx).
    pub code: Option<i64>,
    /// Code étendu.
    pub enhanced: Option<String>,
    /// Texte du serveur distant, assaini (512 caractères au plus).
    pub text: Option<String>,
    /// Serveur distant.
    pub host: Option<String>,
}

/// Résultat d'une destination dans un échec.
#[derive(Debug, Clone, SurrealValue)]
pub struct DestinationFailure {
    /// Domaine de routage.
    pub domain: String,
    /// Aucun MX ni aucune adresse n'a répondu.
    pub unreachable: bool,
    /// Étape de l'échec de connexion (`connect` par défaut).
    pub stage: Option<AttemptStage>,
}

/// Paramètres de `fn::mail_queue_fail`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueFailParams {
    /// Jeton de la réservation.
    pub claim: String,
    /// Échecs (1 à 100).
    pub items: Vec<FailedItem>,
    /// Résultat de la destination.
    pub destination: Option<DestinationFailure>,
}

/// Nouvel état d'un destinataire après un échec.
#[derive(Debug, Clone, SurrealValue)]
pub struct FailedOutcome {
    /// Destinataire.
    pub recipient: MailRecordId,
    /// État : `scheduled`, `failed` ou `expired`.
    pub state: RecipientState,
    /// Échéance suivante (état `scheduled`).
    pub next_attempt_at: Option<MailDatetime>,
}

/// Résultat de `fn::mail_queue_fail`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueFailed {
    /// Destinataires écrits.
    pub items: Vec<FailedOutcome>,
    /// Avis dus.
    pub dsn: Vec<DsnDue>,
    /// Destinataires que la réservation ne tient plus.
    pub lost: Vec<MailRecordId>,
}

/// Paramètres de `fn::mail_queue_release`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueReleaseParams {
    /// Jeton de la réservation.
    pub claim: String,
    /// Destinataires (1 à 500).
    pub recipients: Vec<String>,
    /// Échéance (maintenant par défaut).
    pub not_before: Option<MailDatetime>,
}

/// Résultat de `fn::mail_queue_release`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueReleased {
    /// Destinataires rendus.
    pub released: i64,
    /// Destinataires que la réservation ne tient plus.
    pub lost: Vec<MailRecordId>,
}

/// Paramètres de `fn::mail_queue_dsn_done`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DsnDoneParams {
    /// Envoi (`mail_submission:<clé>`).
    pub submission: String,
    /// Action de l'avis produit.
    pub action: DsnAction,
    /// Destinataires de l'avis (1 à 1 000).
    pub recipients: Vec<String>,
}

/// Résultat de `fn::mail_queue_dsn_done`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct DsnMarked {
    /// Destinataires notés par cet appel.
    pub marked: i64,
}

/// Paramètres de `fn::mail_queue_stats`.
#[derive(Debug, Clone, Copy, Default, SurrealValue)]
pub struct QueueStatsParams {}

/// Résultat de `fn::mail_queue_stats`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueueStats {
    /// Destinataires en attente.
    pub scheduled: i64,
    /// Destinataires réservés.
    pub running: i64,
    /// Échus ou baux expirés (comptés jusqu'à 10 000).
    pub due: i64,
    /// Plus ancienne échéance passée.
    pub oldest_due_at: Option<MailDatetime>,
    /// Destinations suspendues.
    pub suspended_destinations: i64,
}

/// Paramètres de `fn::mail_queue_purge`.
#[derive(Debug, Clone, Copy, Default, SurrealValue)]
pub struct QueuePurgeParams {
    /// Éléments au plus par catégorie (100 par défaut, 1 000 au plus).
    pub limit: Option<i64>,
}

/// Résultat de `fn::mail_queue_purge`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct QueuePurged {
    /// Envois retirés.
    pub submissions: i64,
    /// Fichiers supprimés.
    pub contents: i64,
    /// Jetons de retour effacés.
    pub tokens: i64,
    /// Compteurs d'envoi retirés.
    pub counters: i64,
}

/// Action d'un destinataire dans un avis reçu (RFC 3464).
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum ReturnAction {
    /// Échec.
    Failed,
    /// Retard.
    Delayed,
    /// Remise.
    Delivered,
    /// Relais.
    Relayed,
    /// Développé (liste).
    Expanded,
}

/// Destinataire d'un avis reçu.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReturnItem {
    /// Destinataire de l'envoi (`mail_queue_recipient:<clé>`).
    pub recipient: String,
    /// Action.
    pub action: ReturnAction,
    /// Code étendu (`Status`).
    pub status: Option<String>,
    /// `Diagnostic-Code`, assaini (512 caractères au plus).
    pub diagnostic: Option<String>,
}

/// Paramètres de `fn::mail_return_record`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReturnRecordParams {
    /// Envoi de l'adresse de retour (`mail_submission:<clé>`).
    pub submission: String,
    /// Destinataires de l'avis (1 à 100).
    pub items: Vec<ReturnItem>,
}

/// Résultat de `fn::mail_return_record`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct ReturnRecorded {
    /// Destinataires passés à `bounced`.
    pub bounced: i64,
    /// Éléments seulement comptés.
    pub ignored: i64,
}
