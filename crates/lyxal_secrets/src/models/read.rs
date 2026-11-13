//! Lecture d'une valeur (`fn::secrets_read_begin`, `fn::secrets_read_envelope`).

use lyxal_surreal::SurrealValue;
use std::fmt;

use super::types::{SecretsDatetime, SecretsRecordId};

/// Paramètres de `fn::secrets_read_begin` : version par numéro, sinon par étiquette
/// (`current` par défaut).
#[derive(Debug, Clone, SurrealValue)]
pub struct ReadBeginParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Étiquette de version.
    pub label: Option<String>,
    /// Numéro de version.
    pub number: Option<i64>,
    /// Consommateur annoncé (module de l'hôte, pour la session système).
    pub consumer: Option<String>,
}

/// Résultat de `fn::secrets_read_begin` : ticket à usage unique, valable 60 secondes, déjà tracé
/// au journal.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReadTicket {
    /// Ticket (`secrets_read_ticket:<clé>`).
    pub ticket: SecretsRecordId,
    /// Secret.
    pub secret: SecretsRecordId,
    /// Numéro de la version lue.
    pub number: i64,
    /// Clé d'organisation de la version.
    pub key_id: Option<String>,
    /// Échéance du ticket.
    pub expires_at: SecretsDatetime,
}

/// Paramètres de `fn::secrets_read_envelope`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReadTicketRef {
    /// Ticket (`secrets_read_ticket:<clé>`).
    pub ticket: String,
}

/// Contexte de scellement d'une version, tel que la base le calcule
/// (`SecretContext::with_tenant`).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub(crate) struct SealContext {
    pub tenant: String,
    pub module: String,
    pub resource: String,
    pub record_id: String,
    pub field: String,
}

/// Résultat de `fn::secrets_read_envelope` (session système seulement).
#[derive(Clone, SurrealValue)]
pub(crate) struct ReadEnvelope {
    pub envelope: String,
    pub key_id: String,
    pub number: i64,
    pub context: SealContext,
}

impl fmt::Debug for ReadEnvelope {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("ReadEnvelope")
            .field("envelope", &"[REDACTED]")
            .field("key_id", &self.key_id)
            .field("number", &self.number)
            .finish()
    }
}
