//! Partages à usage unique (`fn::secrets_share_*`). La copie scellée, l'empreinte de la clé du
//! lien et le hachage du mot de passe ne circulent que dans des types internes au crate, sans
//! `Serialize` et au `Debug` masqué.

use lyxal_surreal::SurrealValue;
use std::fmt;

use super::types::{SecretsDatetime, SecretsDuration, SecretsRecordId};

/// État d'un partage.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum ShareState {
    /// Ouvrable.
    Active,
    /// Toutes les ouvertures faites ; copie effacée.
    Consumed,
    /// Échu ; copie effacée.
    Expired,
    /// Retiré par son auteur ; copie effacée.
    Revoked,
    /// Détruit après cinq essais faux ; copie effacée.
    Destroyed,
}

impl ShareState {
    /// Nom de l'état, tel que la base l'enregistre.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Active => "active",
            Self::Consumed => "consumed",
            Self::Expired => "expired",
            Self::Revoked => "revoked",
            Self::Destroyed => "destroyed",
        }
    }
}

/// Fiche d'un partage, sans copie scellée, empreinte ni hachage.
#[derive(Debug, Clone, SurrealValue)]
pub struct Share {
    /// Identifiant (`secrets_share:<clé>`).
    pub id: SecretsRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<SecretsRecordId>,
    /// Auteur (identité).
    pub created_identity: Option<SecretsRecordId>,
    /// Auteur (application).
    pub created_application: Option<SecretsRecordId>,
    /// Secret copié (absent : texte saisi).
    pub secret: Option<SecretsRecordId>,
    /// Version copiée.
    pub number: Option<i64>,
    /// Vrai si un mot de passe est demandé à l'ouverture.
    pub protected: bool,
    /// Ouverture réservée à un membre connecté de l'organisation.
    pub members_only: bool,
    /// Note de l'auteur.
    pub note: Option<String>,
    /// Ouvertures permises.
    pub max_views: i64,
    /// Ouvertures faites.
    pub views: i64,
    /// Essais faux.
    pub failed_attempts: i64,
    /// État.
    pub state: ShareState,
    /// Échéance.
    pub expires_at: SecretsDatetime,
    /// Création.
    pub created_at: SecretsDatetime,
    /// Dernière ouverture.
    pub last_opened_at: Option<SecretsDatetime>,
    /// Fin (épuisé, échu, retiré, détruit).
    pub finished_at: Option<SecretsDatetime>,
}

/// Paramètres de `fn::secrets_share_create` (par le service seulement, qui seul scelle).
#[derive(Clone, SurrealValue)]
pub(crate) struct ShareCreateParams {
    pub tenant: Option<String>,
    pub secret: Option<String>,
    pub number: Option<i64>,
    pub envelope: String,
    pub key_fingerprint: String,
    pub passphrase_hash: Option<String>,
    pub max_views: Option<i64>,
    pub ttl: Option<SecretsDuration>,
    pub members_only: bool,
    pub note: Option<String>,
}

impl fmt::Debug for ShareCreateParams {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("ShareCreateParams")
            .field("tenant", &self.tenant)
            .field("secret", &self.secret)
            .field("number", &self.number)
            .field("envelope", &"[REDACTED]")
            .field("key_fingerprint", &"[REDACTED]")
            .field(
                "passphrase_hash",
                &self.passphrase_hash.as_ref().map(|_| "[REDACTED]"),
            )
            .field("max_views", &self.max_views)
            .field("ttl", &self.ttl)
            .field("members_only", &self.members_only)
            .field("note", &self.note)
            .finish()
    }
}

/// Paramètres de `fn::secrets_share_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ShareListParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Partages actifs seulement (vrai par défaut).
    pub active_only: Option<bool>,
    /// Partages rendus au plus (100 au plus).
    pub limit: Option<i64>,
    /// Décalage.
    pub start: Option<i64>,
}

/// Résultat de `fn::secrets_share_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ShareList {
    /// Partages, les plus récents d'abord.
    pub items: Vec<Share>,
    /// Nombre total.
    pub total: i64,
}

/// Partage désigné (`fn::secrets_share_revoke`, `_load`, `_fail`).
#[derive(Debug, Clone, SurrealValue)]
pub struct ShareRefParams {
    /// Partage (`secrets_share:<clé>`).
    pub share: String,
}

/// Résultat de `fn::secrets_share_load` (session système seulement).
#[derive(Clone, SurrealValue)]
pub(crate) struct ShareLoaded {
    pub id: SecretsRecordId,
    pub tenant: Option<SecretsRecordId>,
    pub envelope: String,
    pub key_fingerprint: String,
    pub passphrase_hash: Option<String>,
    pub members_only: bool,
    pub max_views: i64,
    pub views: i64,
    pub expires_at: SecretsDatetime,
}

impl fmt::Debug for ShareLoaded {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("ShareLoaded")
            .field("id", &self.id)
            .field("tenant", &self.tenant)
            .field("envelope", &"[REDACTED]")
            .field("key_fingerprint", &"[REDACTED]")
            .field(
                "passphrase_hash",
                &self.passphrase_hash.as_ref().map(|_| "[REDACTED]"),
            )
            .field("members_only", &self.members_only)
            .field("max_views", &self.max_views)
            .field("views", &self.views)
            .field("expires_at", &self.expires_at)
            .finish()
    }
}

/// Paramètres de `fn::secrets_share_consume` (session système seulement).
#[derive(Debug, Clone, SurrealValue)]
pub struct ShareConsumeParams {
    /// Partage (`secrets_share:<clé>`).
    pub share: String,
    /// Identité connectée qui ouvre (`auth_identity:<clé>`), journalisée.
    pub opener: Option<String>,
}

/// Résultat de `fn::secrets_share_consume`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ShareConsumed {
    /// Ouvertures faites.
    pub views: i64,
    /// Ouvertures restantes.
    pub remaining: i64,
    /// État après l'ouverture (`consumed` à la dernière).
    pub state: ShareState,
}

/// Résultat de `fn::secrets_share_fail`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ShareFailed {
    /// Essais faux.
    pub failed_attempts: i64,
    /// Vrai si le partage vient d'être détruit (cinquième essai faux).
    pub destroyed: bool,
}

/// Paramètres de `fn::secrets_share_due` (worker).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ShareDueParams {
    /// Partages expirés au plus (1000 au plus).
    pub limit: Option<i64>,
}

/// Résultat de `fn::secrets_share_due`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct ShareDueReport {
    /// Partages échus expirés (copie effacée).
    pub shares_expired: i64,
    /// Fiches finies depuis plus de 30 jours, retirées.
    pub shares_removed: i64,
}
