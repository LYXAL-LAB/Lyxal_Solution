//! Accès aux fonctions SurrealQL de `lyxal_storage` : un appel typé d'une ligne par fonction
//! (`LyxalSurrealCall::call_fn`). Les règles restent dans SurrealQL ; la session SurrealDB du
//! client détermine l'appelant (session système de l'hôte, session d'un utilisateur, ou compte
//! du worker).

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::{
    BatchParams, BegunObject, Bucket, BucketCreateParams, BucketDeleted, BucketDetails, BucketList,
    BucketListParams, BucketRefParams, BucketUpdateParams, Expired, ObjectBeginParams,
    ObjectCommitParams, ObjectGetParams, ObjectList, ObjectListParams, ObjectRefParams,
    ObjectUsageParams, PageParams, PurgeList, Purged, QuarantineParams, ReclaimDone,
    ReclaimDoneParams, ReclaimList, ScopeUsage, SettingsGetParams, SettingsSetParams, SettingsView,
    StoredObject, StoredSettings, UploadClaimParams, UploadPartAddParams, UploadPartList,
    UploadReadyList, UploadRefParams, UploadStatus,
};

/// Store de `lyxal_storage` sur un client SurrealDB (`Surreal<Any>`).
#[derive(Clone)]
pub struct StorageStore {
    db: Surreal<Any>,
}

#[async_trait]
impl LyxalSurrealCall for StorageStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

type Call<T> = Result<T, LyxalSurrealError>;

impl StorageStore {
    /// Store sur un client déjà connecté (espace de noms et base choisis).
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db }
    }

    /// `fn::storage_settings_get` : réglages d'une portée.
    pub async fn settings_get(&self, params: SettingsGetParams) -> Call<SettingsView> {
        self.call_fn("storage_settings_get", params).await
    }

    /// `fn::storage_settings_set` : réglages enregistrés.
    pub async fn settings_set(&self, params: SettingsSetParams) -> Call<StoredSettings> {
        self.call_fn("storage_settings_set", params).await
    }

    /// `fn::storage_bucket_create` : bucket créé.
    pub async fn bucket_create(&self, params: BucketCreateParams) -> Call<Bucket> {
        self.call_fn("storage_bucket_create", params).await
    }

    /// `fn::storage_bucket_update` : bucket modifié.
    pub async fn bucket_update(&self, params: BucketUpdateParams) -> Call<Bucket> {
        self.call_fn("storage_bucket_update", params).await
    }

    /// `fn::storage_bucket_get` : bucket et son volume.
    pub async fn bucket_get(&self, params: BucketRefParams) -> Call<BucketDetails> {
        self.call_fn("storage_bucket_get", params).await
    }

    /// `fn::storage_bucket_list` : buckets d'une portée.
    pub async fn bucket_list(&self, params: BucketListParams) -> Call<BucketList> {
        self.call_fn("storage_bucket_list", params).await
    }

    /// `fn::storage_bucket_delete` : bucket vide supprimé.
    pub async fn bucket_delete(&self, params: BucketRefParams) -> Call<BucketDeleted> {
        self.call_fn("storage_bucket_delete", params).await
    }

    /// `fn::storage_object_begin` : écriture ouverte (fiche en attente).
    pub async fn object_begin(&self, params: ObjectBeginParams) -> Call<BegunObject> {
        self.call_fn("storage_object_begin", params).await
    }

    /// `fn::storage_object_commit` : écriture terminée (fichier disponible).
    pub async fn object_commit(&self, params: ObjectCommitParams) -> Call<StoredObject> {
        self.call_fn("storage_object_commit", params).await
    }

    /// `fn::storage_object_get` : fiche d'un fichier, quel que soit son état.
    pub async fn object_get(&self, params: ObjectGetParams) -> Call<StoredObject> {
        self.call_fn("storage_object_get", params).await
    }

    /// `fn::storage_object_open` : fiche d'un fichier à servir (disponible seulement).
    pub async fn object_open(&self, params: ObjectGetParams) -> Call<StoredObject> {
        self.call_fn("storage_object_open", params).await
    }

    /// `fn::storage_object_list` : fichiers d'un bucket.
    pub async fn object_list(&self, params: ObjectListParams) -> Call<ObjectList> {
        self.call_fn("storage_object_list", params).await
    }

    /// `fn::storage_object_delete` : fichier supprimé (octets retirés plus tard par le worker).
    pub async fn object_delete(&self, params: ObjectRefParams) -> Call<StoredObject> {
        self.call_fn("storage_object_delete", params).await
    }

    /// `fn::storage_object_usage` : volume d'une portée.
    pub async fn object_usage(&self, params: ObjectUsageParams) -> Call<ScopeUsage> {
        self.call_fn("storage_object_usage", params).await
    }

    /// `fn::storage_object_quarantine` : fichier mis en quarantaine.
    pub async fn object_quarantine(&self, params: QuarantineParams) -> Call<StoredObject> {
        self.call_fn("storage_object_quarantine", params).await
    }

    /// `fn::storage_object_expire` : écritures en attente hors délai abandonnées.
    pub async fn object_expire(&self, params: BatchParams) -> Call<Expired> {
        self.call_fn("storage_object_expire", params).await
    }

    /// `fn::storage_object_purge_list` : fichiers supprimés dont les octets sont à retirer.
    pub async fn object_purge_list(&self, params: PageParams) -> Call<PurgeList> {
        self.call_fn("storage_object_purge_list", params).await
    }

    /// `fn::storage_object_purge` : fiche retirée après ses octets.
    pub async fn object_purge(&self, params: ObjectRefParams) -> Call<Purged> {
        self.call_fn("storage_object_purge", params).await
    }

    /// `fn::storage_upload_get` : état d'un envoi reprenable.
    pub async fn upload_get(&self, params: UploadRefParams) -> Call<UploadStatus> {
        self.call_fn("storage_upload_get", params).await
    }

    /// `fn::storage_upload_part_add` : partie inscrite, nouvel état de l'envoi.
    pub async fn upload_part_add(&self, params: UploadPartAddParams) -> Call<UploadStatus> {
        self.call_fn("storage_upload_part_add", params).await
    }

    /// `fn::storage_upload_part_list` : parties d'un envoi, dans l'ordre du fichier.
    pub async fn upload_part_list(&self, params: UploadRefParams) -> Call<UploadPartList> {
        self.call_fn("storage_upload_part_list", params).await
    }

    /// `fn::storage_upload_claim` : assemblage d'un envoi complet réservé, ou réservation rendue.
    pub async fn upload_claim(&self, params: UploadClaimParams) -> Call<UploadStatus> {
        self.call_fn("storage_upload_claim", params).await
    }

    /// `fn::storage_upload_ready_list` : envois complets à assembler.
    pub async fn upload_ready_list(&self, params: BatchParams) -> Call<UploadReadyList> {
        self.call_fn("storage_upload_ready_list", params).await
    }

    /// `fn::storage_reclaim_list` : préfixes d'octets à retirer.
    pub async fn reclaim_list(&self, params: PageParams) -> Call<ReclaimList> {
        self.call_fn("storage_reclaim_list", params).await
    }

    /// `fn::storage_reclaim_done` : ligne d'un préfixe retirée après ses octets.
    pub async fn reclaim_done(&self, params: ReclaimDoneParams) -> Call<ReclaimDone> {
        self.call_fn("storage_reclaim_done", params).await
    }
}
