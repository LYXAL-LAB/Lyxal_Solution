//! Fiches de fichiers (`fn::storage_object_*`).

use lyxal_surreal::SurrealValue;

use super::types::{StorageDatetime, StorageRecordId};

/// État d'un fichier.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum ObjectState {
    /// Écriture en cours : jamais servi.
    Pending,
    /// Disponible.
    Available,
    /// En quarantaine : plus servi.
    Quarantined,
    /// Supprimé : octets à retirer par le worker.
    Deleted,
}

impl ObjectState {
    /// Nom de l'état, tel qu'il est enregistré.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Pending => "pending",
            Self::Available => "available",
            Self::Quarantined => "quarantined",
            Self::Deleted => "deleted",
        }
    }
}

/// Fiche d'un fichier.
#[derive(Debug, Clone, SurrealValue)]
pub struct StoredObject {
    /// Fiche.
    pub id: StorageRecordId,
    /// Bucket.
    pub bucket: StorageRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<StorageRecordId>,
    /// Clé dans le bucket.
    pub key: String,
    /// Identité qui a écrit le fichier.
    pub owner: Option<StorageRecordId>,
    /// Nom d'origine.
    pub filename: String,
    /// Type MIME annoncé.
    pub declared_type: Option<String>,
    /// Taille annoncée, en octets.
    pub declared_size: Option<i64>,
    /// Type MIME réel, posé à la fin de l'écriture.
    pub content_type: Option<String>,
    /// Taille réelle en octets, posée à la fin de l'écriture.
    pub size: Option<i64>,
    /// Empreinte BLAKE3 du contenu, posée à la fin de l'écriture.
    pub blake3: Option<String>,
    /// État.
    pub state: ObjectState,
    /// Support qui porte les octets.
    pub backend: String,
    /// Emplacement des octets sur le support.
    pub path: String,
    /// Motif de la quarantaine.
    pub quarantine_reason: Option<String>,
    /// Fin du délai d'une écriture en attente.
    pub pending_expires_at: Option<StorageDatetime>,
    /// Suppression.
    pub deleted_at: Option<StorageDatetime>,
    /// Date à partir de laquelle les octets et la fiche sont retirés.
    pub purge_after: Option<StorageDatetime>,
    /// Création.
    pub created_at: StorageDatetime,
    /// Dernière modification.
    pub updated_at: StorageDatetime,
}

/// Paramètres de `fn::storage_object_begin`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ObjectBeginParams {
    /// Bucket (`storage_bucket:<clé>`).
    pub bucket: String,
    /// Clé dans le bucket (chemin relatif).
    pub key: String,
    /// Nom d'origine du fichier.
    pub filename: String,
    /// Type MIME annoncé.
    pub declared_type: Option<String>,
    /// Taille annoncée, en octets.
    pub declared_size: Option<i64>,
}

/// Résultat de `fn::storage_object_begin` : fiche en attente et ce qu'il faut pour écrire.
#[derive(Debug, Clone, SurrealValue)]
pub struct BegunObject {
    /// Fiche.
    pub id: StorageRecordId,
    /// Support qui porte les octets.
    pub backend: String,
    /// Emplacement des octets sur le support.
    pub path: String,
    /// Taille maximale acceptée, en octets.
    pub max_size: i64,
    /// Type MIME annoncé.
    pub declared_type: Option<String>,
    /// Taille annoncée, en octets.
    pub declared_size: Option<i64>,
    /// Fin du délai de l'écriture.
    pub pending_expires_at: Option<StorageDatetime>,
}

/// Paramètres de `fn::storage_object_commit`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ObjectCommitParams {
    /// Fiche (`storage_object:<clé>`).
    pub object: String,
    /// Taille réelle, en octets.
    pub size: i64,
    /// Type MIME réel.
    pub content_type: String,
    /// Empreinte BLAKE3 du contenu (64 caractères hexadécimaux).
    pub blake3: String,
}

/// Paramètres de `fn::storage_object_get` et `fn::storage_object_open` : la fiche par son
/// identifiant, ou par son adresse (bucket et clé).
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ObjectGetParams {
    /// Fiche (`storage_object:<clé>`).
    pub object: Option<String>,
    /// Bucket (`storage_bucket:<clé>`).
    pub bucket: Option<String>,
    /// Clé dans le bucket.
    pub key: Option<String>,
}

impl ObjectGetParams {
    /// Fiche désignée par son identifiant.
    pub fn by_id(object: impl Into<String>) -> Self {
        Self {
            object: Some(object.into()),
            ..Self::default()
        }
    }

    /// Fiche désignée par son adresse.
    pub fn by_address(bucket: impl Into<String>, key: impl Into<String>) -> Self {
        Self {
            object: None,
            bucket: Some(bucket.into()),
            key: Some(key.into()),
        }
    }
}

/// Paramètres de `fn::storage_object_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ObjectListParams {
    /// Bucket (`storage_bucket:<clé>`).
    pub bucket: String,
    /// Préfixe de clé.
    pub prefix: Option<String>,
    /// État des fichiers listés.
    pub state: ObjectState,
    /// Fichiers au plus (1 à 1000).
    pub limit: i64,
    /// Rang du premier fichier rendu.
    pub start: i64,
}

/// Résultat de `fn::storage_object_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ObjectList {
    /// Fiches, triées par clé.
    pub items: Vec<StoredObject>,
    /// Nombre total de fichiers correspondants.
    pub total: i64,
}

/// Paramètres de `fn::storage_object_delete` et `fn::storage_object_purge`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ObjectRefParams {
    /// Fiche (`storage_object:<clé>`).
    pub object: String,
}

/// Paramètres de `fn::storage_object_usage`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ObjectUsageParams {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub tenant: Option<String>,
}

/// Résultat de `fn::storage_object_usage` : volume d'une portée.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct ScopeUsage {
    /// Fichiers disponibles ou en quarantaine.
    pub objects: i64,
    /// Leur volume, en octets.
    pub bytes: i64,
    /// Tailles annoncées des écritures en attente.
    pub reserved_bytes: i64,
    /// Quota de la portée (absent : sans quota).
    pub quota_bytes: Option<i64>,
}
