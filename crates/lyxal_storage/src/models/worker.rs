//! Opérations du worker (`fn::storage_object_quarantine`, `_expire`, `_purge_list`, `_purge`,
//! `fn::storage_reclaim_list`, `fn::storage_reclaim_done`).

use lyxal_surreal::SurrealValue;

use super::types::{StorageDatetime, StorageRecordId};

/// Paramètres de `fn::storage_object_quarantine`.
#[derive(Debug, Clone, SurrealValue)]
pub struct QuarantineParams {
    /// Fiche (`storage_object:<clé>`).
    pub object: String,
    /// Motif (256 caractères au plus).
    pub reason: String,
}

/// Paramètres des fonctions par paquets (`fn::storage_object_expire`,
/// `fn::storage_object_purge_list`, `fn::storage_reclaim_list`).
#[derive(Debug, Clone, Copy, SurrealValue)]
pub struct BatchParams {
    /// Éléments au plus (1 à 1000).
    pub limit: i64,
}

/// Résultat de `fn::storage_object_expire`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct Expired {
    /// Écritures en attente abandonnées.
    pub expired: i64,
}

/// Fichier supprimé dont les octets sont à retirer.
#[derive(Debug, Clone, SurrealValue)]
pub struct PurgeItem {
    /// Fiche.
    pub id: StorageRecordId,
    /// Support qui porte les octets.
    pub backend: String,
    /// Emplacement des octets sur le support.
    pub path: String,
    /// Fin de la conservation.
    pub purge_after: Option<StorageDatetime>,
}

/// Résultat de `fn::storage_object_purge_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct PurgeList {
    /// Fichiers à purger, du plus ancien au plus récent.
    pub items: Vec<PurgeItem>,
}

/// Résultat de `fn::storage_object_purge`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct Purged {
    /// Fiche supprimée.
    pub purged: bool,
}

/// Préfixe d'octets à retirer après la suppression d'un bucket.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReclaimItem {
    /// Ligne.
    pub id: StorageRecordId,
    /// Support.
    pub backend: String,
    /// Préfixe des octets à retirer.
    pub prefix: String,
    /// Suppression du bucket.
    pub created_at: StorageDatetime,
}

/// Résultat de `fn::storage_reclaim_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReclaimList {
    /// Préfixes à retirer, du plus ancien au plus récent.
    pub items: Vec<ReclaimItem>,
}

/// Paramètres de `fn::storage_reclaim_done`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ReclaimDoneParams {
    /// Ligne (`storage_reclaim:<clé>`).
    pub reclaim: String,
}

/// Résultat de `fn::storage_reclaim_done`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct ReclaimDone {
    /// Ligne retirée (faux si elle n'existait plus).
    pub done: bool,
}
