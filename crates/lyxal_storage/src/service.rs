//! Écriture et lecture des fichiers en flux.
//!
//! Écriture en deux temps : `fn::storage_object_begin` crée la fiche en attente, les octets sont
//! écrits par parties sur le support (empreinte BLAKE3 et taille calculées au passage), puis
//! `fn::storage_object_commit` rend le fichier disponible. Aucune transaction ne couvre la base
//! et le support : en cas d'échec, les octets déjà écrits sont retirés et la fiche est supprimée ;
//! une écriture interrompue par l'arrêt du serveur est retirée par le worker à la fin de son délai.

use bytes::Bytes;
use futures::stream::BoxStream;
use futures::{Stream, StreamExt};
use lyxal_crypto::hash::Blake3Hasher;
use lyxal_surreal::ToSql;
use object_store::{GetOptions, GetRange, ObjectStore, ObjectStoreExt, WriteMultipart};
use std::ops::Range;
use std::sync::Arc;

use crate::backend::{location, Backends};
use crate::error::{StorageError, StorageResult};
use crate::models::{
    BegunObject, ObjectBeginParams, ObjectCommitParams, ObjectGetParams, ObjectRefParams,
    StoredObject,
};
use crate::store::StorageStore;

/// Taille d'une partie écrite sur le support : rien n'est gardé en mémoire au-delà.
pub const PART_SIZE: usize = 8 * 1024 * 1024;
/// Type enregistré quand aucun type n'est annoncé.
const DEFAULT_CONTENT_TYPE: &str = "application/octet-stream";

/// Fichier à écrire.
#[derive(Debug, Clone)]
pub struct PutRequest {
    /// Bucket (`storage_bucket:<clé>`).
    pub bucket: String,
    /// Clé dans le bucket (chemin relatif).
    pub key: String,
    /// Nom d'origine du fichier.
    pub filename: String,
    /// Type MIME annoncé.
    pub content_type: Option<String>,
    /// Taille annoncée, en octets : le contenu reçu doit avoir exactement cette taille.
    pub size: Option<u64>,
}

/// Fichier ouvert en lecture : sa fiche et le flux de ses octets.
pub struct OpenedObject {
    /// Fiche.
    pub object: StoredObject,
    /// Plage d'octets servie.
    pub range: Range<u64>,
    /// Octets de la plage.
    pub content: BoxStream<'static, StorageResult<Bytes>>,
}

/// Service d'écriture et de lecture des fichiers, sur une session SurrealDB et des supports.
#[derive(Clone)]
pub struct StorageService {
    store: StorageStore,
    backends: Arc<Backends>,
}

impl StorageService {
    /// Service sur la session du store (elle détermine les droits) et les supports de l'hôte.
    pub fn new(store: StorageStore, backends: Arc<Backends>) -> Self {
        Self { store, backends }
    }

    /// Store sous-jacent.
    pub fn store(&self) -> &StorageStore {
        &self.store
    }

    /// Écrit un fichier depuis un flux d'octets et le rend disponible.
    pub async fn put<S, E>(&self, request: PutRequest, content: S) -> StorageResult<StoredObject>
    where
        S: Stream<Item = Result<Bytes, E>> + Send,
        E: std::fmt::Display,
    {
        if self.backends.is_empty() {
            return Err(StorageError::BackendUnknown(
                "aucun support configuré".to_string(),
            ));
        }
        let declared_size = request.size.map(i64::try_from).transpose().map_err(|_| {
            StorageError::ContentMismatch("taille annoncée trop grande".to_string())
        })?;
        let begun = self
            .store
            .object_begin(ObjectBeginParams {
                bucket: request.bucket,
                key: request.key,
                filename: request.filename,
                declared_type: request.content_type,
                declared_size,
            })
            .await?;
        let written = match self.backends.get(&begun.backend) {
            Ok(backend) => write(backend.store().as_ref(), &begun, request.size, content).await,
            Err(error) => Err(error),
        };
        let committed = match written {
            Ok((size, blake3)) => self
                .store
                .object_commit(ObjectCommitParams {
                    object: begun.id.to_sql(),
                    size,
                    content_type: begun
                        .declared_type
                        .clone()
                        .unwrap_or_else(|| DEFAULT_CONTENT_TYPE.to_string()),
                    blake3,
                })
                .await
                .map_err(StorageError::from),
            Err(error) => Err(error),
        };
        if committed.is_err() {
            self.abandon(&begun).await;
        }
        committed
    }

    /// Écriture en échec : octets retirés du support, fiche supprimée. Un échec de ce nettoyage
    /// est journalisé ; le worker retire alors l'écriture à la fin de son délai.
    async fn abandon(&self, begun: &BegunObject) {
        if let Ok(backend) = self.backends.get(&begun.backend) {
            let removed = match location(&begun.path) {
                Ok(path) => backend.remove(&path).await,
                Err(error) => Err(error),
            };
            if let Err(error) = removed {
                tracing::warn!(object = %begun.id.to_sql(), code = %error.code(), "octets d'une écriture en échec non retirés");
            }
        }
        let deleted = self
            .store
            .object_delete(ObjectRefParams {
                object: begun.id.to_sql(),
            })
            .await;
        if let Err(error) = deleted {
            tracing::warn!(object = %begun.id.to_sql(), error = %error, "fiche d'une écriture en échec non supprimée");
        }
    }

    /// Ouvre un fichier disponible en lecture, en entier ou sur une plage d'octets.
    pub async fn open(
        &self,
        params: ObjectGetParams,
        range: Option<Range<u64>>,
    ) -> StorageResult<OpenedObject> {
        let object = self.store.object_open(params).await?;
        let backend = self.backends.get(&object.backend)?.store();
        let options = GetOptions {
            range: range.map(GetRange::Bounded),
            ..GetOptions::default()
        };
        let result = backend.get_opts(&location(&object.path)?, options).await?;
        let range = result.range.clone();
        let content = result
            .into_stream()
            .map(|chunk| chunk.map_err(StorageError::from))
            .boxed();
        Ok(OpenedObject {
            object,
            range,
            content,
        })
    }

    /// Supprime un fichier : sa fiche passe à l'état supprimé, ses octets sont retirés par le
    /// worker après le délai de conservation.
    pub async fn delete(&self, object: &str) -> StorageResult<StoredObject> {
        Ok(self
            .store
            .object_delete(ObjectRefParams {
                object: object.to_string(),
            })
            .await?)
    }

    /// Relit les octets d'un fichier et compare leur taille et leur empreinte à sa fiche.
    pub async fn verify(&self, object: &str) -> StorageResult<StoredObject> {
        let object = self
            .store
            .object_get(ObjectGetParams::by_id(object))
            .await?;
        let (Some(expected_size), Some(expected_hash)) = (object.size, object.blake3.as_deref())
        else {
            return Err(StorageError::IntegrityFailed(
                "la fiche n'a ni taille ni empreinte (écriture non terminée)".to_string(),
            ));
        };
        let backend = self.backends.get(&object.backend)?.store();
        let mut content = match backend.get(&location(&object.path)?).await {
            Ok(result) => result.into_stream(),
            Err(object_store::Error::NotFound { .. }) => {
                return Err(StorageError::IntegrityFailed(
                    "octets absents du support".to_string(),
                ))
            }
            Err(error) => return Err(error.into()),
        };
        let mut hasher = Blake3Hasher::new();
        let mut size: u64 = 0;
        while let Some(chunk) = content.next().await {
            let chunk = chunk?;
            size += chunk.len() as u64;
            hasher.update(&chunk);
        }
        if i64::try_from(size).ok() != Some(expected_size) {
            return Err(StorageError::IntegrityFailed(format!(
                "taille relue {size}, taille de la fiche {expected_size}"
            )));
        }
        if hasher.finalize_hex() != expected_hash {
            return Err(StorageError::IntegrityFailed(
                "empreinte relue différente de celle de la fiche".to_string(),
            ));
        }
        Ok(object)
    }
}

/// Écrit le flux par parties ; rend la taille et l'empreinte du contenu. En cas d'échec,
/// l'écriture est abandonnée sur le support.
async fn write<S, E>(
    backend: &dyn ObjectStore,
    begun: &BegunObject,
    declared_size: Option<u64>,
    content: S,
) -> StorageResult<(i64, String)>
where
    S: Stream<Item = Result<Bytes, E>> + Send,
    E: std::fmt::Display,
{
    let max_size = u64::try_from(begun.max_size).unwrap_or(0);
    let upload = backend.put_multipart(&location(&begun.path)?).await?;
    let mut writer = WriteMultipart::new_with_chunk_size(upload, PART_SIZE);
    let mut hasher = Blake3Hasher::new();
    let mut size: u64 = 0;
    let mut content = std::pin::pin!(content);
    let failure = loop {
        let chunk = match content.next().await {
            None => break None,
            Some(Ok(chunk)) => chunk,
            Some(Err(error)) => {
                break Some(StorageError::ContentMismatch(format!(
                    "flux interrompu : {error}"
                )))
            }
        };
        size += chunk.len() as u64;
        if size > max_size || declared_size.is_some_and(|declared| size > declared) {
            break Some(StorageError::ContentMismatch(format!(
                "contenu plus grand que la taille acceptée ({} octets)",
                declared_size.map_or(max_size, |declared| declared.min(max_size))
            )));
        }
        hasher.update(&chunk);
        // Une seule partie en cours d'envoi : la mémoire reste bornée à deux parties
        if let Err(error) = writer.wait_for_capacity(1).await {
            break Some(error.into());
        }
        writer.put(chunk);
    };
    let failure = failure.or_else(|| {
        declared_size
            .filter(|declared| *declared != size)
            .map(|declared| {
                StorageError::ContentMismatch(format!("{size} octets reçus, {declared} annoncés"))
            })
    });
    if let Some(error) = failure {
        if let Err(abort) = writer.abort().await {
            tracing::warn!(object = %begun.id.to_sql(), error = %abort, "écriture non abandonnée sur le support");
        }
        return Err(error);
    }
    writer.finish().await?;
    let size = i64::try_from(size)
        .map_err(|_| StorageError::ContentMismatch("contenu trop grand".to_string()))?;
    Ok((size, hasher.finalize_hex()))
}
