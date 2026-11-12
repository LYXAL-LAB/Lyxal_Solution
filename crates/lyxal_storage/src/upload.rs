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
use lyxal_runtime::worker::CancellationToken;
use lyxal_surreal::ToSql;
use object_store::path::Path;
use object_store::{ObjectStore, ObjectStoreExt};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

use crate::backend::location;
use crate::error::{StorageError, StorageResult};
use crate::models::{
    ClaimedUpload, ObjectBeginParams, ObjectRefParams, ObjectState, PartName, StoredObject,
    UploadClaimParams, UploadPartAddParams, UploadRefParams, UploadReleaseParams, UploadStatus,
};
use crate::service::{StorageService, WriteTarget, PART_SIZE};
use crate::store::StorageStore;

/// Durée de la réservation de l'assemblage, en secondes : au-delà, un assemblage interrompu
/// brutalement est repris par le worker.
const CLAIM_SECONDS: i64 = 1800;
/// Délai après lequel un assemblage en cours prolonge sa réservation.
const RENEW_AFTER: Duration = Duration::from_secs(300);

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

/// Lecture des parties pendant un assemblage : avant chaque partie, l'arrêt du serveur est
/// vérifié et la réservation est prolongée si une part notable de sa durée est écoulée.
#[derive(Clone)]
struct PartReader {
    store: StorageStore,
    backend: Arc<dyn ObjectStore>,
    object: String,
    claim: PartName,
    cancellation: CancellationToken,
    renewed: Arc<Mutex<Instant>>,
}

impl PartReader {
    /// Octets d'une partie, lus en flux sur le support.
    async fn read(self, path: Path) -> StorageResult<BoxStream<'static, StorageResult<Bytes>>> {
        if self.cancellation.is_cancelled() {
            return Err(StorageError::Cancelled);
        }
        let due = self
            .renewed
            .lock()
            .map(|renewed| renewed.elapsed() >= RENEW_AFTER)
            .unwrap_or(true);
        if due {
            // Refus : la réservation a été reprise par un autre assembleur, celui-ci s'arrête
            self.store
                .upload_claim(UploadClaimParams {
                    object: self.object.clone(),
                    seconds: CLAIM_SECONDS,
                    claim: Some(self.claim),
                })
                .await?;
            if let Ok(mut renewed) = self.renewed.lock() {
                *renewed = Instant::now();
            }
        }
        let part = self.backend.get(&path).await?;
        Ok(part.into_stream().map_err(StorageError::from).boxed())
    }
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
    /// refusée par la base (position prise par une autre requête, envoi terminé) est retirée ;
    /// après une panne de la base, on vérifie si elle a été inscrite.
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
        let error = match added.map_err(StorageError::from) {
            Ok(status) => return Ok(position(status.offset)),
            Err(error) => error,
        };
        // Refus de la base : la partie n'est pas inscrite. Panne (connexion coupée, réponse
        // illisible, conflit de transaction) : la base a pu l'inscrire ; on le lui demande
        let registered = if error.is_business() {
            Some(false)
        } else {
            self.store
                .upload_part_list(UploadRefParams {
                    object: status.id.to_sql(),
                })
                .await
                .ok()
                .map(|parts| parts.items.iter().any(|part| part.name == name))
        };
        match registered {
            // Inscrite malgré la panne : la position a avancé
            Some(true) => Ok(offset + size),
            // Non inscrite : ses octets sont retirés
            Some(false) => {
                if let Err(removal) = backend.remove(&path).await {
                    tracing::warn!(object = %status.id.to_sql(), code = %removal.code(), "octets d'une partie refusée non retirés");
                }
                Err(error)
            }
            // Base toujours injoignable : les octets restent sur le support ; s'ils ne sont pas
            // inscrits, ils partent avec le dossier des parties quand l'envoi n'est plus en cours
            None => Err(error),
        }
    }

    /// Assemble un envoi complet : les parties sont relues dans l'ordre et écrites comme un
    /// envoi simple (taille, empreinte, type réel, antivirus), puis le fichier est rendu
    /// disponible. Un seul assembleur à la fois. Un contenu refusé abandonne l'envoi ; un échec
    /// passager (support, antivirus ou base indisponible) le laisse complet : le worker
    /// l'assemblera.
    pub async fn upload_complete(&self, upload: &str) -> StorageResult<StoredObject> {
        self.upload_complete_until(upload, &CancellationToken::new())
            .await
    }

    /// Comme [`Self::upload_complete`], interrompu proprement par `cancellation` (arrêt du
    /// serveur) entre deux parties : l'écriture en cours est abandonnée sur le support, la
    /// réservation est rendue, l'envoi reste complet (`StorageError::Cancelled`).
    ///
    /// La réservation porte un jeton : elle est prolongée pendant un assemblage long, et un
    /// assembleur dont la réservation a été reprise par un autre (après un blocage plus long
    /// qu'elle) ne termine ni n'abandonne plus rien.
    pub async fn upload_complete_until(
        &self,
        upload: &str,
        cancellation: &CancellationToken,
    ) -> StorageResult<StoredObject> {
        let claimed = self
            .store
            .upload_claim(UploadClaimParams {
                object: upload.to_string(),
                seconds: CLAIM_SECONDS,
                claim: None,
            })
            .await?;
        let target = WriteTarget {
            id: &claimed.id,
            backend: &claimed.backend,
            path: &claimed.path,
            max_size: claimed.max_size,
            declared_type: claimed.declared_type.as_deref(),
        };
        let assembled = self.assemble(&claimed, &target, cancellation).await;
        let Err(error) = &assembled else {
            return assembled;
        };
        // Contenu refusé : l'envoi est abandonné. Échec passager : il reste complet. Dans les
        // deux cas seulement si cette réservation est toujours celle en cours
        let abandon = !error.is_retryable() && error.code() != "STORAGE_UPLOAD_BUSY";
        let released = self
            .store
            .upload_release(UploadReleaseParams {
                object: upload.to_string(),
                claim: claimed.claim,
                abandon,
            })
            .await;
        match released {
            Ok(_) if abandon => self.remove_written(&target).await,
            Ok(_) => {}
            Err(release) => {
                tracing::warn!(object = %claimed.id.to_sql(), error = %release, "réservation d'un assemblage en échec non rendue");
            }
        }
        assembled
    }

    async fn assemble(
        &self,
        claimed: &ClaimedUpload,
        target: &WriteTarget<'_>,
        cancellation: &CancellationToken,
    ) -> StorageResult<StoredObject> {
        let parts = self
            .store
            .upload_part_list(UploadRefParams {
                object: claimed.id.to_sql(),
            })
            .await?
            .items;
        let backend = self.backends.get(&claimed.backend)?.store().clone();
        let mut locations = Vec::with_capacity(parts.len());
        for part in &parts {
            locations.push(part_location(&claimed.path, &part.name)?);
        }
        let reader = PartReader {
            store: self.store.clone(),
            backend,
            object: claimed.id.to_sql(),
            claim: claimed.claim,
            cancellation: cancellation.clone(),
            renewed: Arc::new(Mutex::new(Instant::now())),
        };
        let content = futures::stream::iter(locations)
            .then(move |path| reader.clone().read(path))
            .try_flatten()
            .boxed();
        self.write_and_commit(
            target,
            Some(position(claimed.length)),
            Some(claimed.claim),
            content,
        )
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
