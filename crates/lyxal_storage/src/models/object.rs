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
    /// Application qui a écrit le fichier sans identité (compte de service).
    pub owner_application: Option<StorageRecordId>,
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
    /// Taille des octets stockés : la taille réelle, ou celle du flux chiffré dans un bucket
    /// chiffré.
    pub stored_size: Option<i64>,
    /// Empreinte BLAKE3 des octets stockés (le chiffré dans un bucket chiffré), posée à la fin de
    /// l'écriture.
    pub blake3: Option<String>,
    /// Clé « fichiers » de l'organisation qui scelle la clé du fichier (absente : fichier en
    /// clair). La clé scellée elle-même n'est lue que par la session système.
    pub content_key_id: Option<String>,
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
    /// Envoi reprenable.
    pub resumable: bool,
    /// Création.
    pub created_at: StorageDatetime,
    /// Dernière modification.
    pub updated_at: StorageDatetime,
    /// Résumé du bucket du fichier, rendu par `fn::storage_object_get` et
    /// `fn::storage_object_open` quand il est demandé ([`ObjectGetParams::with_bucket`]).
    pub bucket_summary: Option<BucketSummary>,
}

/// Résumé du bucket d'un fichier : ce qu'il faut pour contrôler où le fichier est rangé.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct BucketSummary {
    /// Nom du bucket.
    pub name: String,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<StorageRecordId>,
    /// Bucket chiffré.
    pub encrypted: bool,
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
    /// Envoi reprenable : octets reçus en plusieurs requêtes, taille annoncée obligatoire.
    pub resumable: bool,
}

/// Résultat de `fn::storage_object_begin` : fiche en attente et ce qu'il faut pour écrire.
#[derive(Debug, Clone, SurrealValue)]
pub struct BegunObject {
    /// Fiche.
    pub id: StorageRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<StorageRecordId>,
    /// Bucket chiffré : le contenu doit être chiffré et sa clé scellée remise à la fin.
    pub encrypted: bool,
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
#[derive(Clone, SurrealValue)]
pub struct ObjectCommitParams {
    /// Fiche (`storage_object:<clé>`).
    pub object: String,
    /// Taille réelle, en octets.
    pub size: i64,
    /// Type MIME réel.
    pub content_type: String,
    /// Empreinte BLAKE3 des octets stockés (64 caractères hexadécimaux).
    pub blake3: String,
    /// Bucket chiffré : clé du fichier scellée (`enc:v2`).
    pub content_key: Option<String>,
    /// Envoi reprenable : jeton de la réservation d'assemblage.
    pub claim: Option<super::upload::PartName>,
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
    /// Rendre aussi le résumé du bucket du fichier ([`StoredObject::bucket_summary`]).
    pub with_bucket: bool,
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
            bucket: Some(bucket.into()),
            key: Some(key.into()),
            ..Self::default()
        }
    }

    /// Demande aussi le résumé du bucket du fichier.
    pub fn with_bucket(mut self) -> Self {
        self.with_bucket = true;
        self
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

impl std::fmt::Debug for ObjectCommitParams {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ObjectCommitParams")
            .field("object", &self.object)
            .field("size", &self.size)
            .field("content_type", &self.content_type)
            .field("blake3", &self.blake3)
            .field(
                "content_key",
                &self.content_key.as_ref().map(|_| "[REDACTED]"),
            )
            .field("claim", &self.claim)
            .finish()
    }
}
