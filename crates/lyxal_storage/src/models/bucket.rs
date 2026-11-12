//! Buckets (`fn::storage_bucket_*`).

use lyxal_surreal::SurrealValue;

use super::types::{StorageDatetime, StorageRecordId};

/// Bucket : ensemble de fichiers et ses règles.
#[derive(Debug, Clone, SurrealValue)]
pub struct Bucket {
    /// Bucket.
    pub id: StorageRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<StorageRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Nom, unique dans sa portée.
    pub name: String,
    /// Usage du bucket.
    pub description: Option<String>,
    /// Taille maximale d'un fichier, en octets (absente : celle des réglages).
    pub max_object_size: Option<i64>,
    /// Types MIME acceptés (vide : tous).
    pub allowed_types: Vec<String>,
    /// Nom du support qui porte les octets.
    pub backend: String,
    /// Lecture seule.
    pub readonly: bool,
    /// Création.
    pub created_at: StorageDatetime,
    /// Dernière modification.
    pub updated_at: StorageDatetime,
}

/// Paramètres de `fn::storage_bucket_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BucketCreateParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Nom (`[a-z0-9-]`, 3 à 63 caractères).
    pub name: String,
    /// Usage du bucket.
    pub description: Option<String>,
    /// Taille maximale d'un fichier, en octets.
    pub max_object_size: Option<i64>,
    /// Types MIME acceptés (vide : tous).
    pub allowed_types: Vec<String>,
    /// Lecture seule.
    pub readonly: bool,
    /// Nom du support, fixé à la création.
    pub backend: String,
}

impl BucketCreateParams {
    /// Bucket de ce nom sur le support `default`, sans restriction.
    pub fn named(tenant: Option<String>, name: impl Into<String>) -> Self {
        Self {
            tenant,
            name: name.into(),
            description: None,
            max_object_size: None,
            allowed_types: Vec::new(),
            readonly: false,
            backend: "default".to_string(),
        }
    }
}

/// Paramètres de `fn::storage_bucket_update` : un champ absent est conservé, un champ nommé dans
/// `clear` (`description`, `max_object_size`) est effacé.
#[derive(Debug, Clone, SurrealValue)]
pub struct BucketUpdateParams {
    /// Bucket (`storage_bucket:<clé>`).
    pub bucket: String,
    /// Usage du bucket.
    pub description: Option<String>,
    /// Taille maximale d'un fichier, en octets.
    pub max_object_size: Option<i64>,
    /// Types MIME acceptés.
    pub allowed_types: Option<Vec<String>>,
    /// Lecture seule.
    pub readonly: Option<bool>,
    /// Champs à effacer.
    pub clear: Vec<String>,
}

/// Paramètres de `fn::storage_bucket_get` et `fn::storage_bucket_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BucketRefParams {
    /// Bucket (`storage_bucket:<clé>`).
    pub bucket: String,
}

/// Volume d'un bucket.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct BucketUsage {
    /// Fichiers disponibles ou en quarantaine.
    pub objects: i64,
    /// Leur volume, en octets.
    pub bytes: i64,
}

/// Résultat de `fn::storage_bucket_get` : le bucket et son volume.
#[derive(Debug, Clone, SurrealValue)]
pub struct BucketDetails {
    /// Bucket.
    pub id: StorageRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<StorageRecordId>,
    /// Nom.
    pub name: String,
    /// Nom du support.
    pub backend: String,
    /// Lecture seule.
    pub readonly: bool,
    /// Taille maximale d'un fichier, en octets.
    pub max_object_size: Option<i64>,
    /// Types MIME acceptés.
    pub allowed_types: Vec<String>,
    /// Volume.
    pub usage: BucketUsage,
}

/// Paramètres de `fn::storage_bucket_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BucketListParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
    /// Buckets au plus (1 à 1000).
    pub limit: i64,
    /// Rang du premier bucket rendu.
    pub start: i64,
}

/// Résultat de `fn::storage_bucket_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct BucketList {
    /// Buckets, triés par nom.
    pub items: Vec<Bucket>,
    /// Nombre total de buckets de la portée.
    pub total: i64,
}

/// Résultat de `fn::storage_bucket_delete`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct BucketDeleted {
    /// Bucket supprimé.
    pub deleted: bool,
}
