//! Versions et étiquettes (`fn::secrets_version_*`). Les enveloppes scellées ne circulent que
//! dans des types internes au crate, sans `Serialize` et au `Debug` masqué.

use lyxal_surreal::SurrealValue;
use std::collections::BTreeMap;
use std::fmt;

use super::types::{SecretsDatetime, SecretsRecordId};

/// État d'une version.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum VersionState {
    /// Lisible.
    Enabled,
    /// Lecture refusée, réversible.
    Disabled,
    /// Enveloppe effacée, irréversible.
    Destroyed,
}

/// Étiquette posée sur une nouvelle version.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum Stage {
    /// Devient la version lue par défaut (l'ancienne `current` devient `previous`).
    #[default]
    Current,
    /// Version en attente (rotation), lue seulement par son étiquette ou son numéro.
    Pending,
}

/// Version d'un secret, sans enveloppe (liste et fiche).
#[derive(Debug, Clone, SurrealValue)]
pub struct VersionSummary {
    /// Numéro.
    pub number: i64,
    /// État.
    pub state: VersionState,
    /// Identifiant de la clé d'organisation qui la scelle (absent après destruction).
    pub key_id: Option<String>,
    /// Noms des clés d'une valeur JSON (jamais les valeurs).
    pub keys: Option<Vec<String>>,
    /// Identité autrice.
    pub created_by: Option<SecretsRecordId>,
    /// Application autrice.
    pub created_by_application: Option<SecretsRecordId>,
    /// Création.
    pub created_at: SecretsDatetime,
    /// Destruction.
    pub destroyed_at: Option<SecretsDatetime>,
    /// Dernier rescellement.
    pub resealed_at: Option<SecretsDatetime>,
}

/// Version d'un secret, sans enveloppe.
#[derive(Debug, Clone, SurrealValue)]
pub struct SecretVersion {
    /// Identifiant (`secrets_version:<clé>`).
    pub id: SecretsRecordId,
    /// Secret.
    pub secret: SecretsRecordId,
    /// Numéro.
    pub number: i64,
    /// État.
    pub state: VersionState,
    /// Identifiant de la clé d'organisation qui la scelle.
    pub key_id: Option<String>,
    /// Noms des clés d'une valeur JSON.
    pub keys: Option<Vec<String>>,
    /// Identité autrice.
    pub created_by: Option<SecretsRecordId>,
    /// Application autrice.
    pub created_by_application: Option<SecretsRecordId>,
    /// Création.
    pub created_at: SecretsDatetime,
    /// Destruction.
    pub destroyed_at: Option<SecretsDatetime>,
    /// Dernier rescellement.
    pub resealed_at: Option<SecretsDatetime>,
}

/// Paramètres de `fn::secrets_version_add` (enveloppe scellée par le service).
#[derive(Clone, SurrealValue)]
pub(crate) struct VersionAddParams {
    pub secret: String,
    pub number: i64,
    pub envelope: String,
    pub key_id: String,
    pub keys: Option<Vec<String>>,
    pub stage: Stage,
}

impl fmt::Debug for VersionAddParams {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("VersionAddParams")
            .field("secret", &self.secret)
            .field("number", &self.number)
            .field("envelope", &"[REDACTED]")
            .field("key_id", &self.key_id)
            .field("stage", &self.stage)
            .finish()
    }
}

/// Résultat de `fn::secrets_version_add`.
#[derive(Debug, Clone, SurrealValue)]
pub struct VersionAdded {
    /// Version créée.
    pub version: SecretVersion,
    /// Étiquettes du secret après l'ajout.
    pub labels: BTreeMap<String, i64>,
    /// Numéros des versions détruites au-delà du nombre de versions conservées.
    pub destroyed: Vec<i64>,
}

/// Paramètres de `fn::secrets_version_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct VersionListParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// État.
    pub state: Option<VersionState>,
    /// Taille de page (100 au plus).
    pub limit: Option<i64>,
    /// Début de page.
    pub start: Option<i64>,
}

/// Résultat de `fn::secrets_version_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct VersionList {
    /// Versions de la page, les plus récentes d'abord.
    pub items: Vec<VersionSummary>,
    /// Total.
    pub total: i64,
}

/// Paramètres de `fn::secrets_version_label`.
#[derive(Debug, Clone, SurrealValue)]
pub struct VersionLabelParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Étiquette.
    pub label: String,
    /// Version étiquetée (obligatoire sauf retrait).
    pub number: Option<i64>,
    /// Retrait de l'étiquette.
    pub remove: bool,
}

/// Résultat de `fn::secrets_version_label`.
#[derive(Debug, Clone, SurrealValue)]
pub struct LabelsResult {
    /// Étiquettes du secret.
    pub labels: BTreeMap<String, i64>,
}

/// Paramètres de `fn::secrets_version_disable`, `_enable`, `_destroy`.
#[derive(Debug, Clone, SurrealValue)]
pub struct VersionRefParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Numéro de version.
    pub number: i64,
}

/// Paramètres de `fn::secrets_version_reseal` (nouvelle enveloppe scellée par le worker).
#[derive(Clone, SurrealValue)]
pub(crate) struct VersionResealParams {
    pub secret: String,
    pub number: i64,
    pub expected_key_id: String,
    pub envelope: String,
    pub key_id: String,
}

impl fmt::Debug for VersionResealParams {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("VersionResealParams")
            .field("secret", &self.secret)
            .field("number", &self.number)
            .field("expected_key_id", &self.expected_key_id)
            .field("envelope", &"[REDACTED]")
            .field("key_id", &self.key_id)
            .finish()
    }
}

/// Résultat de `fn::secrets_version_reseal`.
#[derive(Debug, Clone, SurrealValue)]
pub struct Resealed {
    /// Rescellement effectué.
    pub resealed: bool,
    /// Numéro de version.
    pub number: i64,
    /// Nouvelle clé d'organisation.
    pub key_id: String,
}
