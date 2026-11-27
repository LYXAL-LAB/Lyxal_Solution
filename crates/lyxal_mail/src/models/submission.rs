// SPDX-License-Identifier: AGPL-3.0-only

//! Envoi (`fn::mail_sender_check`, `fn::mail_submission_*`, lot 6 §8 et §12) : droit
//! d'expéditeur, dépôt dans la file d'envoi (dépôt authentifié, contrat public des modules,
//! transfert, avis), clôture, abandon, lecture et annulation d'un envoi.

use lyxal_surreal::SurrealValue;

use super::types::{MailDatetime, MailRecordId};

/// Paramètres de `fn::mail_sender_check`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SenderCheckParams {
    /// Adresses à contrôler (1 à 10 ; `""` : expéditeur vide).
    pub addresses: Vec<String>,
}

/// Résultat de `fn::mail_sender_check`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct SenderCheck {
    /// Toutes les adresses sont permises au compte de la session.
    pub allowed: bool,
    /// Rangs des adresses refusées (aucune adresse rendue).
    pub refused: Vec<i64>,
}

/// Origine d'un envoi.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum SubmissionOrigin {
    /// Dépôt authentifié d'un compte (ports 587 et 465).
    Submission,
    /// Contrat public de dépôt d'un autre module (`lyxal_notification`, `lyxal_calendar`).
    Module,
    /// Transfert d'un alias vers l'extérieur.
    Forward,
    /// Avis de non-remise envoyé à l'extérieur.
    Dsn,
}

/// Mot de `NOTIFY` (RFC 3461 §4.1).
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum DsnNotify {
    /// Jamais d'avis (seul).
    Never,
    /// Avis de remise.
    Success,
    /// Avis d'échec.
    Failure,
    /// Avis de retard.
    Delay,
}

/// Partie du message rendue dans un avis (`RET`, RFC 3461 §4.3).
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum DsnReturn {
    /// En-têtes seulement (défaut).
    Hdrs,
    /// Message entier.
    Full,
}

/// Demande d'avis d'un envoi (`RET`, `ENVID`).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct DsnRequest {
    /// Partie du message rendue (`hdrs` par défaut).
    pub ret: Option<DsnReturn>,
    /// Identifiant de l'envoi donné par l'expéditeur (`ENVID`, xtext décodé, 100 caractères).
    pub envid: Option<String>,
}

/// Demande d'avis rangée sur un envoi.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct DsnSettings {
    /// Partie du message rendue.
    pub ret: DsnReturn,
    /// Identifiant de l'envoi donné par l'expéditeur.
    pub envid: Option<String>,
}

/// Destinataire annoncé d'un dépôt.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct SubmissionRecipient {
    /// Adresse (`RCPT TO`).
    pub address: String,
    /// `NOTIFY` (absent : défaut `failure`, `delay`).
    pub notify: Option<Vec<DsnNotify>>,
    /// `ORCPT` (destinataire d'origine).
    pub orcpt: Option<String>,
}

/// Réception d'origine d'un transfert, pour l'avis à son expéditeur (§10.2).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ForwardReception {
    /// Adresse d'enveloppe d'origine (absente : expéditeur vide).
    pub envelope_from: Option<String>,
    /// SPF de la réception d'origine (mot de la RFC 8601).
    pub spf: String,
    /// Une signature DKIM valide porte le domaine de l'adresse d'enveloppe d'origine ou son
    /// domaine d'organisation.
    pub envelope_dkim: bool,
}

/// Paramètres de `fn::mail_submission_begin`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SubmissionBeginParams {
    /// Origine (`submission` par défaut).
    pub origin: Option<SubmissionOrigin>,
    /// Adresse d'enveloppe annoncée (`""` : expéditeur vide, exigé d'un avis).
    pub from: String,
    /// Adresses des champs `From`, `Sender`, `Resent-*` (1 à 10).
    pub header_from: Vec<String>,
    /// Destinataires (1 à 1 000).
    pub recipients: Vec<SubmissionRecipient>,
    /// Taille du message, en octets.
    pub size: i64,
    /// L'envoi exige `SMTPUTF8`.
    pub smtputf8: Option<bool>,
    /// Le contenu a des octets 8 bits.
    pub eight_bit: Option<bool>,
    /// Demande d'avis.
    pub dsn: Option<DsnRequest>,
    /// Module : référence opaque de l'appelant (identifiant de 1 à 128 caractères).
    pub client_reference: Option<String>,
    /// Transfert : jeton de l'adresse de retour (compte de service).
    pub return_token: Option<String>,
    /// Transfert ou avis : en-têtes ajoutés devant le fichier (compte de service).
    pub prefix: Option<String>,
    /// Transfert : réception d'origine.
    pub forward: Option<ForwardReception>,
    /// Avis : organisation (`auth_organization:<clé>`).
    pub tenant: Option<String>,
    /// Transfert ou avis (exigée) : clé d'idempotence (64 chiffres hexadécimaux), empreinte de
    /// l'alias ou du destinataire, de l'expéditeur et des octets ; un envoi déjà mis en file sous
    /// cette clé est rendu tel quel (`queued`).
    pub idempotency_key: Option<String>,
}

/// Résultat de `fn::mail_submission_begin` : où écrire le fichier du message.
#[derive(Debug, Clone, SurrealValue)]
pub struct SubmissionReservation {
    /// Envoi (`pending`).
    pub submission: MailRecordId,
    /// Organisation de l'envoi.
    pub tenant: MailRecordId,
    /// Bucket chiffré de l'organisation (`lyxal-mail`).
    pub bucket_name: String,
    /// Clé du fichier (`queue/<clé de l'envoi>.eml`).
    pub key: String,
    /// Taille maximale d'un message de l'organisation.
    pub max_size: i64,
    /// Adresse de retour (transfert seulement ; ailleurs posée par le worker).
    pub return_address: Option<String>,
    /// Fin du délai de clôture.
    pub expires_at: MailDatetime,
    /// Transfert ou avis déjà mis en file sous la même clé d'idempotence : rien à écrire ni à
    /// clore.
    pub queued: Option<SubmissionQueued>,
}

/// Paramètres de `fn::mail_submission_commit`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SubmissionCommitParams {
    /// Envoi (`mail_submission:<clé>`).
    pub submission: String,
    /// Fichier écrit par `lyxal_storage` (`storage_object:<clé>`).
    pub object: String,
}

/// Résultat de `fn::mail_submission_commit`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SubmissionQueued {
    /// Envoi mis en file.
    pub submission: MailRecordId,
    /// Destinataires mis en file.
    pub recipients: i64,
    /// Mise en file.
    pub queued_at: MailDatetime,
}

/// Paramètres de `fn::mail_submission_abort`, `_get` et `_cancel`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SubmissionRefParams {
    /// Envoi (`mail_submission:<clé>`).
    pub submission: String,
}

/// Résultat de `fn::mail_submission_abort`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct SubmissionReleased {
    /// Compteurs d'envoi rendus.
    pub released: bool,
}

/// Résultat de `fn::mail_submission_cancel`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct SubmissionCanceled {
    /// Destinataires en attente annulés.
    pub canceled: i64,
}

/// État d'un envoi.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum SubmissionState {
    /// Fichier en écriture.
    Pending,
    /// Destinataires en file.
    Queued,
    /// Tous les destinataires dans un état final.
    Done,
}

/// État d'un destinataire en file.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum RecipientState {
    /// En attente de son échéance.
    Scheduled,
    /// Réservé sous bail.
    Running,
    /// Accepté par le serveur final, ou remis par la route locale.
    Delivered,
    /// Accepté par un serveur sans `DSN` avec `NOTIFY=SUCCESS`.
    Relayed,
    /// Refus définitif.
    Failed,
    /// Fin de vie de l'envoi.
    Expired,
    /// Annulé par l'expéditeur.
    Canceled,
    /// Avis reçu après acceptation.
    Bounced,
}

/// Étape d'un résultat.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum AttemptStage {
    /// Résolution DNS.
    Dns,
    /// Connexion.
    Connect,
    /// Poignée de main TLS.
    Tls,
    /// Accueil du serveur.
    Greeting,
    /// `MAIL FROM`.
    Mail,
    /// `RCPT TO`.
    Rcpt,
    /// `DATA` et fin des données.
    Data,
    /// Route locale.
    Local,
    /// Contenu illisible.
    Content,
    /// Fin de vie de l'envoi.
    Expired,
    /// Annulation.
    Canceled,
    /// Avis reçu après acceptation.
    Bounce,
}

/// TLS d'une connexion.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct TlsInfo {
    /// Version négociée.
    pub version: Option<String>,
    /// Certificat vérifié.
    pub verified: bool,
}

/// Dernier résultat d'un destinataire.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct AttemptResult {
    /// Étape.
    pub stage: Option<AttemptStage>,
    /// Code de réponse SMTP.
    pub code: Option<i64>,
    /// Code étendu (RFC 3463).
    pub enhanced: Option<String>,
    /// Texte du serveur distant, assaini (jamais rendu à un module).
    pub text: Option<String>,
    /// Serveur distant.
    pub host: Option<String>,
    /// TLS de la connexion.
    pub tls: Option<TlsInfo>,
    /// Date du résultat.
    pub at: Option<MailDatetime>,
}

/// Destinataire d'un envoi lu par `fn::mail_submission_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QueuedRecipient {
    /// Destinataire en file.
    pub recipient: MailRecordId,
    /// Rang dans l'envoi.
    pub rank: i64,
    /// Adresse.
    pub address: String,
    /// État.
    pub state: RecipientState,
    /// Essais comptés.
    pub attempts: i64,
    /// Échéance du prochain essai.
    pub next_attempt_at: MailDatetime,
    /// Dernier résultat.
    pub last_result: Option<AttemptResult>,
    /// Premier passage du délai d'avis de retard.
    pub delayed_at: Option<MailDatetime>,
    /// Entrée dans un état final.
    pub final_at: Option<MailDatetime>,
}

/// Envoi lu par `fn::mail_submission_get` (sans préfixe, jeton ni contenu).
#[derive(Debug, Clone, SurrealValue)]
pub struct Submission {
    /// Fiche.
    pub id: MailRecordId,
    /// Organisation.
    pub tenant: MailRecordId,
    /// Origine.
    pub origin: SubmissionOrigin,
    /// Compte expéditeur d'un dépôt authentifié.
    pub account: Option<MailRecordId>,
    /// Adresse d'enveloppe annoncée (absente : expéditeur vide).
    pub sender: Option<String>,
    /// Adresses des champs d'en-tête contrôlées.
    pub header_from: Vec<String>,
    /// Adresse d'enveloppe utilisée à l'envoi (adresse de retour).
    pub envelope_from: Option<String>,
    /// Référence d'un module appelant.
    pub client_reference: Option<String>,
    /// Taille du message, en octets.
    pub size: i64,
    /// L'envoi exige `SMTPUTF8`.
    pub smtputf8: bool,
    /// Le contenu a des octets 8 bits.
    pub eight_bit: bool,
    /// Demande d'avis.
    pub dsn: DsnSettings,
    /// Transfert : réception d'origine (avis à son expéditeur, §10.2).
    pub forward: Option<ForwardReception>,
    /// État.
    pub state: SubmissionState,
    /// Destinataires.
    pub recipient_count: i64,
    /// Destinataires non finis.
    pub open_count: i64,
    /// Abandon avant la clôture.
    pub aborted_at: Option<MailDatetime>,
    /// Dépôt.
    pub created_at: MailDatetime,
    /// Mise en file.
    pub queued_at: Option<MailDatetime>,
    /// Fin.
    pub done_at: Option<MailDatetime>,
    /// Fin de vie en file.
    pub expires_at: MailDatetime,
    /// Destinataires, par rang.
    pub recipients: Vec<QueuedRecipient>,
}
