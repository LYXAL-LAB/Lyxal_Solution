//! Envoi reprenable : un fichier reçu en plusieurs requêtes.
//!
//! La fiche du fichier est ouverte à l'état en attente (`fn::storage_object_begin`, `resumable`).
//! Chaque requête écrit ses octets sur le support, par parties de [`PART_SIZE`] au plus, sous
//! `<emplacement du fichier>.parts/`, puis inscrit chaque partie dans la base
//! (`fn::storage_upload_part_add`) : la base est la seule vérité sur la position de l'envoi.
//! Quand tous les octets sont là, les parties sont relues dans l'ordre et passent par l'écriture
//! d'un envoi simple (taille, empreinte, type réel, antivirus), puis le fichier est rendu
//! disponible. Les parties sont retirées du support par le worker (`storage_reclaim`).

use bytes::{Bytes, BytesMut};
use futures::stream::BoxStream;
use futures::{Stream, StreamExt, TryStreamExt};
use lyxal_surreal::ToSql;
use object_store::path::Path;
use object_store::{ObjectStore, ObjectStoreExt};
use std::sync::Arc;

use crate::backend::location;
use crate::error::{StorageError, StorageResult};
use crate::models::{
    ObjectBeginParams, ObjectRefParams, ObjectState, PartName, StoredObject, UploadClaimParams,
    UploadPartAddParams, UploadRefParams, UploadStatus,
};
use crate::service::{StorageService, WriteTarget, PART_SIZE};

/// Durée de la réservation de l'assemblage, en secondes : au-delà, un assemblage interrompu est
/// repris par le worker.
const CLAIM_SECONDS: i64 = 1800;

/// Envoi reprenable à ouvrir.
#[derive(Debug, Clone)]
pub struct UploadRequest {
    /// Bucket (`storage_bucket:<clé>`).
    pub bucket: String,
    /// Clé dans le bucket (chemin relatif).
    pub key: String,
    /// Nom d'origine du fichier.
    pub filename: String,
    /// Type MIME annoncé.
    pub content_type: Option<String>,
    /// Taille du fichier, en octets.
    pub size: u64,
}

/// Résultat d'une requête d'envoi : la position atteinte et, si l'envoi est terminé, le fichier.
#[derive(Debug, Clone)]
pub struct Appended {
    /// Octets reçus depuis le début de l'envoi.
    pub offset: u64,
    /// Fichier disponible, quand cette requête a terminé l'envoi.
    pub object: Option<StoredObject>,
}

/// Octets d'une partie, lus en flux sur le support.
async fn read_part(
    backend: Arc<dyn ObjectStore>,
    path: Path,
) -> StorageResult<BoxStream<'static, StorageResult<Bytes>>> {
    let part = backend.get(&path).await?;
    Ok(part.into_stream().map_err(StorageError::from).boxed())
}

/// Emplacement d'une partie : `<emplacement du fichier>.parts/<nom>`.
fn part_location(path: &str, name: &PartName) -> StorageResult<Path> {
    location(&format!("{path}.parts/{name}"))
}

fn position(value: i64) -> u64 {
    u64::try_from(value).unwrap_or(0)
}

impl StorageService {
    /// Ouvre un envoi reprenable : fiche en attente, aucune donnée reçue.
    pub async fn upload_create(&self, request: UploadRequest) -> StorageResult<UploadStatus> {
        if self.backends.is_empty() {
            return Err(StorageError::BackendUnknown(
                "aucun support configuré".to_string(),
            ));
        }
        let declared_size = i64::try_from(request.size).map_err(|_| {
            StorageError::ContentMismatch("taille annoncée trop grande".to_string())
        })?;
        let begun = self
            .store
            .object_begin(ObjectBeginParams {
                bucket: request.bucket,
                key: request.key,
                filename: request.filename,
                declared_type: request.content_type,
                declared_size: Some(declared_size),
                resumable: true,
            })
            .await?;
        self.upload_status(&begun.id.to_sql()).await
    }

    /// État d'un envoi : position, taille, délai. Réservé à son auteur.
    pub async fn upload_status(&self, upload: &str) -> StorageResult<UploadStatus> {
        Ok(self
            .store
            .upload_get(UploadRefParams {
                object: upload.to_string(),
            })
            .await?)
    }

    /// Ajoute des octets à un envoi, à partir de `offset`, qui doit être sa position courante.
    /// Les octets reçus avant une coupure du flux sont conservés. Quand le dernier octet est
    /// reçu, le fichier est assemblé, contrôlé et rendu disponible.
    pub async fn upload_append<S, E>(
        &self,
        upload: &str,
        offset: u64,
        content: S,
    ) -> StorageResult<Appended>
    where
        S: Stream<Item = Result<Bytes, E>> + Send,
        E: std::fmt::Display,
    {
        let status = self.upload_status(upload).await?;
        if status.state != ObjectState::Pending || position(status.offset) != offset {
            return Err(StorageError::UploadOffsetMismatch(position(status.offset)));
        }
        let length = position(status.length);
        let mut received = offset;
        let mut buffer = BytesMut::new();
        let mut content = std::pin::pin!(content);
        let mut failure = None;
        while failure.is_none() {
            let chunk = match content.next().await {
                None => break,
                Some(Ok(chunk)) => chunk,
                Some(Err(error)) => {
                    failure = Some(StorageError::ContentMismatch(format!(
                        "flux interrompu : {error}"
                    )));
                    break;
                }
            };
            if received + (buffer.len() + chunk.len()) as u64 > length {
                failure = Some(StorageError::ContentMismatch(format!(
                    "contenu plus grand que la taille annoncée ({length} octets)"
                )));
                break;
            }
            buffer.extend_from_slice(&chunk);
            while buffer.len() >= PART_SIZE {
                let part = buffer.split_to(PART_SIZE).freeze();
                match self.store_part(&status, received, part).await {
                    Ok(next) => received = next,
                    Err(error) => {
                        failure = Some(error);
                        break;
                    }
                }
            }
        }
        // Ce qui est déjà reçu est conservé, même si le flux s'est interrompu ensuite
        let stored = failure
            .as_ref()
            .is_none_or(|error| matches!(error, StorageError::ContentMismatch(_)));
        if stored && !buffer.is_empty() {
            match self.store_part(&status, received, buffer.freeze()).await {
                Ok(next) => received = next,
                Err(error) => failure = failure.or(Some(error)),
            }
        }
        if let Some(error) = failure {
            return Err(error);
        }
        let object = if received == length {
            Some(self.upload_complete(upload).await?)
        } else {
            None
        };
        Ok(Appended {
            offset: received,
            object,
        })
    }

    /// Écrit une partie sur le support, puis l'inscrit ; rend la nouvelle position. Une partie
    /// refusée par la base (position prise par une autre requête, envoi terminé) est retirée.
    async fn store_part(
        &self,
        status: &UploadStatus,
        offset: u64,
        part: Bytes,
    ) -> StorageResult<u64> {
        let backend = self.backends.get(&status.backend)?;
        let name = PartName::new_v7();
        let path = part_location(&status.path, &name)?;
        let size = part.len() as u64;
        backend.store().put(&path, part.into()).await?;
        let added = self
            .store
            .upload_part_add(UploadPartAddParams {
                object: status.id.to_sql(),
                offset: i64::try_from(offset).unwrap_or(i64::MAX),
                size: i64::try_from(size).unwrap_or(i64::MAX),
                name,
            })
            .await;
        match added {
            Ok(status) => Ok(position(status.offset)),
            Err(error) => {
                if let Err(removal) = backend.remove(&path).await {
                    tracing::warn!(object = %status.id.to_sql(), code = %removal.code(), "octets d'une partie refusée non retirés");
                }
                Err(error.into())
            }
        }
    }

    /// Assemble un envoi complet : les parties sont relues dans l'ordre et écrites comme un
    /// envoi simple (taille, empreinte, type réel, antivirus), puis le fichier est rendu
    /// disponible. Un seul assembleur à la fois. Un contenu refusé abandonne l'envoi ; un échec
    /// passager (support, antivirus ou base indisponible) le laisse complet : le worker
    /// l'assemblera.
    pub async fn upload_complete(&self, upload: &str) -> StorageResult<StoredObject> {
        let status = self
            .store
            .upload_claim(UploadClaimParams {
                object: upload.to_string(),
                seconds: CLAIM_SECONDS,
                release: false,
            })
            .await?;
        let target = WriteTarget {
            id: &status.id,
            backend: &status.backend,
            path: &status.path,
            max_size: status.max_size,
            declared_type: status.declared_type.as_deref(),
        };
        let assembled = self.assemble(&status, &target).await;
        match &assembled {
            Ok(_) => {}
            Err(error) if error.is_retryable() => {
                let released = self
                    .store
                    .upload_claim(UploadClaimParams {
                        object: upload.to_string(),
                        seconds: CLAIM_SECONDS,
                        release: true,
                    })
                    .await;
                if let Err(release) = released {
                    tracing::warn!(object = %status.id.to_sql(), error = %release, "réservation d'un assemblage en échec non rendue");
                }
            }
            Err(_) => self.abandon(&target).await,
        }
        assembled
    }

    async fn assemble(
        &self,
        status: &UploadStatus,
        target: &WriteTarget<'_>,
    ) -> StorageResult<StoredObject> {
        let parts = self
            .store
            .upload_part_list(UploadRefParams {
                object: status.id.to_sql(),
            })
            .await?
            .items;
        let backend = self.backends.get(&status.backend)?.store().clone();
        let mut locations = Vec::with_capacity(parts.len());
        for part in &parts {
            locations.push(part_location(&status.path, &part.name)?);
        }
        let content = futures::stream::iter(locations)
            .then(move |path| read_part(backend.clone(), path))
            .try_flatten()
            .boxed();
        self.write_and_commit(target, Some(position(status.length)), content)
            .await
    }

    /// Abandonne un envoi : sa fiche est supprimée, ses parties sont retirées par le worker.
    pub async fn upload_terminate(&self, upload: &str) -> StorageResult<()> {
        let status = self.upload_status(upload).await?;
        self.store
            .object_delete(ObjectRefParams {
                object: status.id.to_sql(),
            })
            .await?;
        Ok(())
    }
}
