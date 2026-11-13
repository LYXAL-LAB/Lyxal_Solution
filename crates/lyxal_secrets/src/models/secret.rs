//! Fiches de secrets (`fn::secrets_secret_*`). Une fiche ne contient jamais de valeur.

use lyxal_surreal::SurrealValue;
use std::collections::BTreeMap;

use super::types::{SecretsDatetime, SecretsDuration, SecretsRecordId, SecretsValue};
use super::version::VersionSummary;

/// État d'un secret.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum SecretState {
    /// Lisible et modifiable.
    Active,
    /// Lecture refusée, réversible.
    Disabled,
    /// Supprimé (suppression douce), purgé à la date de purge.
    Deleted,
}

/// Fiche d'un secret, sans valeur.
#[derive(Debug, Clone, SurrealValue)]
pub struct SecretRecord {
    /// Identifiant (`secrets_secret:<clé>`).
    pub id: SecretsRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<SecretsRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Chemin unique dans la portée (`notification/smtp/password`).
    pub path: String,
    /// Type (`api_key`, `password`, `token`…).
    pub kind: String,
    /// Description.
    pub description: Option<String>,
    /// Identité propriétaire.
    pub owner: Option<SecretsRecordId>,
    /// Application propriétaire.
    pub owner_application: Option<SecretsRecordId>,
    /// Contact.
    pub contact: Option<String>,
    /// Consommateurs prévus (applications ou modules de l'hôte).
    pub consumers: Vec<String>,
    /// Étiquettes libres.
    pub tags: Vec<String>,
    /// Métadonnées libres (jamais de valeur secrète).
    pub metadata: SecretsValue,
    /// Visibilité : `restricted` ou `revealable` (lisible par un humain).
    pub visibility: String,
    /// Échéance.
    pub expires_at: Option<SecretsDatetime>,
    /// Période de rotation.
    pub rotation_period: Option<SecretsDuration>,
    /// Prochaine rotation prévue.
    pub next_rotation_at: Option<SecretsDatetime>,
    /// État.
    pub state: SecretState,
    /// État d'avant la suppression.
    pub state_before_delete: Option<String>,
    /// Suppression.
    pub deleted_at: Option<SecretsDatetime>,
    /// Date de purge.
    pub purge_at: Option<SecretsDatetime>,
    /// Étiquettes de version (`current`, `previous`, `pending`, libres) → numéro.
    pub labels: BTreeMap<String, i64>,
    /// Dernier numéro de version.
    pub latest_version: i64,
    /// Création.
    pub created_at: SecretsDatetime,
    /// Dernière modification.
    pub updated_at: SecretsDatetime,
    /// Dernières versions, sans enveloppe (lecture d'une fiche seulement).
    pub versions: Option<Vec<VersionSummary>>,
}

/// Paramètres de `fn::secrets_secret_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SecretCreateParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Chemin unique dans la portée.
    pub path: String,
    /// Type (`api_key`, `password`, `token`, `oauth_client`, `certificate`, `private_key`,
    /// `signing_key`, `connection_string`, `generic`).
    pub kind: String,
    /// Description.
    pub description: Option<String>,
    /// Contact.
    pub contact: Option<String>,
    /// Consommateurs prévus.
    pub consumers: Vec<String>,
    /// Étiquettes libres.
    pub tags: Vec<String>,
    /// Métadonnées libres (objet).
    pub metadata: Option<SecretsValue>,
    /// Visibilité (défaut : celle des réglages).
    pub visibility: Option<String>,
    /// Échéance (future).
    pub expires_at: Option<SecretsDatetime>,
    /// Période de rotation (1 h à 3650 j).
    pub rotation_period: Option<SecretsDuration>,
}

impl SecretCreateParams {
    /// Fiche minimale : portée, chemin et type.
    pub fn new(tenant: Option<String>, path: impl Into<String>, kind: impl Into<String>) -> Self {
        Self {
            tenant,
            path: path.into(),
            kind: kind.into(),
            description: None,
            contact: None,
            consumers: Vec::new(),
            tags: Vec::new(),
            metadata: None,
            visibility: None,
            expires_at: None,
            rotation_period: None,
        }
    }
}

/// Paramètres de `fn::secrets_secret_update` : un champ absent est conservé, un champ nommé
/// dans `clear` (`description`, `contact`, `expires_at`, `rotation_period`) est effacé.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SecretUpdateParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Type.
    pub kind: Option<String>,
    /// Description.
    pub description: Option<String>,
    /// Contact.
    pub contact: Option<String>,
    /// Consommateurs prévus.
    pub consumers: Option<Vec<String>>,
    /// Étiquettes libres.
    pub tags: Option<Vec<String>>,
    /// Métadonnées libres (objet).
    pub metadata: Option<SecretsValue>,
    /// Visibilité.
    pub visibility: Option<String>,
    /// Échéance.
    pub expires_at: Option<SecretsDatetime>,
    /// Période de rotation.
    pub rotation_period: Option<SecretsDuration>,
    /// Champs à effacer.
    pub clear: Vec<String>,
}

/// Paramètres de `fn::secrets_secret_get` : par identifiant, ou par organisation et chemin.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SecretGetParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: Option<String>,
    /// Organisation (avec `path`).
    pub tenant: Option<String>,
    /// Chemin (avec `tenant`).
    pub path: Option<String>,
}

impl SecretGetParams {
    /// Par identifiant.
    pub fn by_id(secret: impl Into<String>) -> Self {
        Self {
            secret: Some(secret.into()),
            ..Self::default()
        }
    }

    /// Par organisation et chemin.
    pub fn by_path(tenant: Option<String>, path: impl Into<String>) -> Self {
        Self {
            secret: None,
            tenant,
            path: Some(path.into()),
        }
    }
}

/// Paramètres des fonctions qui désignent un secret (`_disable`, `_enable`, `_delete`,
/// `_restore`, `_purge`).
#[derive(Debug, Clone, SurrealValue)]
pub struct SecretRefParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
}

/// Paramètres de `fn::secrets_secret_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SecretListParams {
    /// Organisation, absente pour l'installation.
    pub tenant: Option<String>,
    /// Préfixe de chemin.
    pub prefix: Option<String>,
    /// État (défaut : tous sauf supprimés).
    pub state: Option<SecretState>,
    /// Étiquette libre.
    pub tag: Option<String>,
    /// Taille de page (100 au plus).
    pub limit: Option<i64>,
    /// Début de page.
    pub start: Option<i64>,
}

/// Résultat de `fn::secrets_secret_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SecretList {
    /// Fiches de la page.
    pub items: Vec<SecretRecord>,
    /// Total des fiches correspondantes.
    pub total: i64,
}

/// Résultat de `fn::secrets_secret_purge`.
#[derive(Debug, Clone, SurrealValue)]
pub struct SecretPurged {
    /// Purge effectuée.
    pub purged: bool,
    /// Secret purgé (`secrets_secret:<clé>`).
    pub secret: String,
    /// Chemin.
    pub path: String,
}
