//! Clés des fichiers chiffrés et compteurs de volume (`fn::storage_object_key_get`,
//! `fn::storage_object_rekey_list`, `fn::storage_object_rekey`, `fn::storage_usage_verify`). Les
//! clés scellées ne circulent que dans des types internes au crate, au `Debug` masqué.

use lyxal_surreal::SurrealValue;
use std::fmt;

use super::types::{StorageDatetime, StorageRecordId};

/// Résultat de `fn::storage_object_key_get` : clé scellée d'une fiche.
#[derive(Clone, SurrealValue)]
pub(crate) struct ObjectKey {
    pub tenant: Option<StorageRecordId>,
    pub content_key: Option<String>,
}

impl fmt::Debug for ObjectKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("ObjectKey")
            .field("tenant", &self.tenant)
            .field("content_key", &"[REDACTED]")
            .finish()
    }
}

/// Paramètres de `fn::storage_object_rekey_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RekeyListParams {
    /// Clé « fichiers » retirée.
    pub key_id: String,
    /// Organisation de la clé (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Retrait de la clé.
    pub retired_at: StorageDatetime,
    /// Fiches au plus (1 à 1000).
    pub limit: i64,
    /// Fiches en échec à passer.
    pub start: i64,
}

/// Fiche dont la clé de fichier est scellée par une clé retirée.
#[derive(Clone, SurrealValue)]
pub(crate) struct RekeyItem {
    pub id: StorageRecordId,
    pub tenant: Option<StorageRecordId>,
    pub content_key: String,
}

impl fmt::Debug for RekeyItem {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("RekeyItem")
            .field("id", &self.id)
            .field("content_key", &"[REDACTED]")
            .finish()
    }
}

/// Résultat de `fn::storage_object_rekey_list`.
#[derive(Debug, Clone, SurrealValue)]
pub(crate) struct RekeyList {
    pub items: Vec<RekeyItem>,
    /// Écriture d'un bucket chiffré de la portée, ouverte avant le retrait, encore en attente.
    pub pending_writes: bool,
}

/// Paramètres de `fn::storage_object_rekey`.
#[derive(Clone, SurrealValue)]
pub(crate) struct RekeyParams {
    pub object: String,
    pub expected_key_id: String,
    pub content_key: String,
}

impl fmt::Debug for RekeyParams {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("RekeyParams")
            .field("object", &self.object)
            .field("expected_key_id", &self.expected_key_id)
            .field("content_key", &"[REDACTED]")
            .finish()
    }
}

/// Résultat de `fn::storage_object_rekey`.
#[derive(Debug, Clone, SurrealValue)]
pub struct Rekeyed {
    /// Fiche.
    pub object: StorageRecordId,
    /// Clé « fichiers » qui scelle désormais la clé du fichier.
    pub content_key_id: Option<String>,
}

/// Paramètres de `fn::storage_usage_verify`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct UsageVerifyParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
}

/// Compteurs de volume.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct UsageCounts {
    /// Fichiers disponibles ou en quarantaine.
    pub objects: i64,
    /// Leur volume, en octets.
    pub bytes: i64,
    /// Tailles annoncées des écritures en attente.
    pub reserved: i64,
}

/// Écart entre les compteurs tenus et les fiches recomptées.
#[derive(Debug, Clone, SurrealValue)]
pub struct UsageMismatch {
    /// Bucket (absent : ligne de la portée).
    pub bucket: Option<StorageRecordId>,
    /// Recompté depuis les fiches.
    pub counted: UsageCounts,
    /// Tenu à jour.
    pub recorded: UsageCounts,
}

/// Résultat de `fn::storage_usage_verify`.
#[derive(Debug, Clone, SurrealValue)]
pub struct UsageReport {
    /// Aucun écart.
    pub valid: bool,
    /// Lignes contrôlées (la portée et chacun de ses buckets).
    pub checked: i64,
    /// Écarts.
    pub mismatches: Vec<UsageMismatch>,
}
