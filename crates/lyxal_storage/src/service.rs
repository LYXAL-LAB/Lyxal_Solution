//! Écriture et lecture des fichiers en flux.
//!
//! Écriture en deux temps : `fn::storage_object_begin` crée la fiche en attente, les octets sont
//! écrits par parties sur le support (empreinte BLAKE3 et taille calculées au passage), puis
//! `fn::storage_object_commit` rend le fichier disponible. Aucune transaction ne couvre la base
//! et le support : en cas d'échec, les octets déjà écrits sont retirés et la fiche est supprimée ;
//! une écriture interrompue par l'arrêt du serveur est retirée par le nettoyage à la fin de son délai.
//!
//! Bucket chiffré : le clair passe par la reconnaissance du type réel et l'antivirus, puis par le
//! chiffrement en flux (`encryption`), et l'empreinte est celle du chiffré ; la lecture ne lit et
//! ne déchiffre que les segments de la plage demandée. Sans service de clés, rien n'est écrit ni
//! lu (`STORAGE_ENCRYPTION_UNAVAILABLE`), jamais en clair.

use bytes::Bytes;
use futures::stream::BoxStream;
use futures::{Stream, StreamExt};
use lyxal_crypto::hash::Blake3Hasher;
use lyxal_crypto::{StreamDecryptor, STREAM_HEADER_BYTES};
use lyxal_secrets::SealedFileKey;
use lyxal_surreal::{LyxalSurrealError, ToSql};
use object_store::{GetOptions, GetRange, ObjectStore, ObjectStoreExt, WriteMultipart};
use std::future::Future;
use std::ops::Range;
use std::sync::Arc;
use std::time::{Duration, SystemTime, UNIX_EPOCH};

use crate::backend::{location, Backends};
use crate::content::{detect, HEAD_SIZE};
use crate::encryption::{decrypting_stream, EncryptingWriter, FileEncryption};
use crate::error::{StorageError, StorageResult};
use crate::models::{
    BegunObject, ObjectBeginParams, ObjectCommitParams, ObjectGetParams, ObjectRefParams, PartName,
    StorageRecordId, StoredObject,
};
use crate::scanner::{ContentScanner, ScanVerdict};
use crate::store::StorageStore;

/// Taille d'une partie écrite sur le support : rien n'est gardé en mémoire au-delà.
pub const PART_SIZE: usize = 8 * 1024 * 1024;

/// Essais d'une écriture de fiche refusée pour conflit de transaction : les compteurs de volume
/// d'une portée sont écrits par toutes ses écritures, des écritures simultanées peuvent se
/// heurter.
const CONFLICT_ATTEMPTS: u32 = 6;

/// Attente avant un nouvel essai : croissante, avec une part tirée de l'horloge pour que des
/// écritures heurtées ne se heurtent pas de nouveau au même instant.
fn conflict_pause(attempt: u32) -> Duration {
    let jitter = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_or(0, |elapsed| elapsed.subsec_nanos() % 20_000_000);
    Duration::from_millis(u64::from(attempt) * 10) + Duration::from_nanos(u64::from(jitter))
}

/// Appel rejoué tant qu'il échoue sur un conflit de transaction (annulé par la base, sans
/// effet), six essais au plus ; toute autre erreur est rendue telle quelle.
pub(crate) async fn retry_conflicts<T, F, Fut>(mut call: F) -> Result<T, LyxalSurrealError>
where
    F: FnMut() -> Fut,
    Fut: Future<Output = Result<T, LyxalSurrealError>>,
{
    let mut attempt = 1;
    loop {
        match call().await {
            Err(error) if attempt < CONFLICT_ATTEMPTS && error.is_transient_conflict() => {
                tokio::time::sleep(conflict_pause(attempt)).await;
                attempt += 1;
            }
            other => return other,
        }
    }
}

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

/// Plage d'octets demandée à la lecture (bornes en octets, à partir de 0).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ByteRange {
    /// Du premier au dernier octet inclus ; un dernier octet au-delà du fichier est ramené à sa fin.
    FromTo(u64, u64),
    /// D'un octet à la fin du fichier.
    From(u64),
    /// Les derniers octets du fichier.
    Last(u64),
}

impl ByteRange {
    /// Plage réelle dans un fichier de `size` octets ; refus si elle ne contient aucun octet.
    pub fn resolve(self, size: u64) -> StorageResult<Range<u64>> {
        let range = match self {
            Self::FromTo(first, last) if first <= last && first < size => {
                first..last.saturating_add(1).min(size)
            }
            Self::From(first) if first < size => first..size,
            Self::Last(count) if count > 0 && size > 0 => size.saturating_sub(count)..size,
            _ => return Err(StorageError::RangeNotSatisfiable(size)),
        };
        Ok(range)
    }
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
    pub(crate) store: StorageStore,
    pub(crate) backends: Arc<Backends>,
    pub(crate) scanner: Option<Arc<dyn ContentScanner>>,
    pub(crate) encryption: Option<FileEncryption>,
}

impl StorageService {
    /// Service sur la session du store (elle détermine les droits) et les supports de l'hôte,
    /// sans antivirus ni service de clés (un bucket chiffré n'est alors ni écrit ni lu).
    pub fn new(store: StorageStore, backends: Arc<Backends>) -> Self {
        Self {
            store,
            backends,
            scanner: None,
            encryption: None,
        }
    }

    /// Fait analyser par cet antivirus tout fichier écrit.
    pub fn with_scanner(mut self, scanner: Arc<dyn ContentScanner>) -> Self {
        self.scanner = Some(scanner);
        self
    }

    /// Service de clés des buckets chiffrés : clés de fichiers scellées par le coffre-fort
    /// (`FileKeys`), clé scellée d'une fiche lue par la session système de l'hôte (`system`).
    /// Sans effet sur les buckets en clair.
    pub fn with_file_keys(mut self, keys: lyxal_secrets::FileKeys, system: StorageStore) -> Self {
        self.encryption = Some(FileEncryption::new(keys, system));
        self
    }

    /// Service de clés disponible (clé maîtresse du coffre-fort présente), ou
    /// `STORAGE_ENCRYPTION_UNAVAILABLE`.
    fn encryption(&self) -> StorageResult<&FileEncryption> {
        self.encryption
            .as_ref()
            .filter(|encryption| encryption.is_available())
            .ok_or_else(|| {
                StorageError::EncryptionUnavailable(
                    "service de clés des fichiers absent (clé maîtresse du coffre-fort)"
                        .to_string(),
                )
            })
    }

    /// Vrai si le service de clés des buckets chiffrés est disponible (clé maîtresse du
    /// coffre-fort présente) : sans lui, aucun fichier chiffré n'est écrit ni lu.
    pub fn encryption_available(&self) -> bool {
        self.encryption().is_ok()
    }

    /// Vrai si au moins un support est configuré : sans support, rien ne peut être écrit ni lu.
    pub fn is_configured(&self) -> bool {
        !self.backends.is_empty()
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
        let params = ObjectBeginParams {
            bucket: request.bucket,
            key: request.key,
            filename: request.filename,
            declared_type: request.content_type,
            declared_size,
            resumable: false,
        };
        let begun = retry_conflicts(|| self.store.object_begin(params.clone())).await?;
        let target = WriteTarget {
            id: &begun.id,
            backend: &begun.backend,
            path: &begun.path,
            max_size: begun.max_size,
            declared_type: begun.declared_type.as_deref(),
        };
        let content = content.map(|chunk| {
            chunk.map_err(|error| {
                StorageError::ContentMismatch(format!("flux interrompu : {error}"))
            })
        });
        let committed = match self.encryption_for(&begun).await {
            Ok(encryption) => {
                self.write_and_commit(&target, request.size, None, encryption, content)
                    .await
            }
            Err(error) => Err(error),
        };
        if committed.is_err() {
            self.abandon(&target).await;
        }
        committed
    }

    /// Chiffrement d'un fichier d'un bucket chiffré : clé neuve scellée et chiffreur ; aucun
    /// pour un bucket en clair. Sans service de clés : `STORAGE_ENCRYPTION_UNAVAILABLE`.
    async fn encryption_for(
        &self,
        begun: &BegunObject,
    ) -> StorageResult<Option<(EncryptingWriter, SealedFileKey)>> {
        if !begun.encrypted {
            return Ok(None);
        }
        Ok(Some(
            self.encryption()?
                .writer(begun.tenant.as_ref(), &begun.id)
                .await?,
        ))
    }

    /// Écrit le contenu à l'emplacement du fichier (chiffré si `encryption` est donné), puis
    /// rend le fichier disponible.
    pub(crate) async fn write_and_commit<S>(
        &self,
        target: &WriteTarget<'_>,
        declared_size: Option<u64>,
        claim: Option<PartName>,
        encryption: Option<(EncryptingWriter, SealedFileKey)>,
        content: S,
    ) -> StorageResult<StoredObject>
    where
        S: Stream<Item = StorageResult<Bytes>> + Send,
    {
        let backend = self.backends.get(target.backend)?;
        let (encryptor, content_key) = match encryption {
            Some((encryptor, sealed)) => (Some(encryptor), Some(sealed.as_str().to_string())),
            None => (None, None),
        };
        let written = write(
            backend.store().as_ref(),
            self.scanner.as_deref(),
            target,
            declared_size,
            encryptor,
            content,
        )
        .await?;
        let params = ObjectCommitParams {
            object: target.id.to_sql(),
            size: written.size,
            content_type: written.content_type,
            blake3: written.blake3,
            content_key,
            claim,
        };
        Ok(retry_conflicts(|| self.store.object_commit(params.clone())).await?)
    }

    /// Retire du support les octets d'une écriture en échec ; un échec est journalisé.
    pub(crate) async fn remove_written(&self, target: &WriteTarget<'_>) {
        if let Ok(backend) = self.backends.get(target.backend) {
            let removed = match location(target.path) {
                Ok(path) => backend.remove(&path).await,
                Err(error) => Err(error),
            };
            if let Err(error) = removed {
                tracing::warn!(object = %target.id.to_sql(), code = %error.code(), "octets d'une écriture en échec non retirés");
            }
        }
    }

    /// Écriture en échec : octets retirés du support, fiche supprimée. Un échec de ce nettoyage
    /// est journalisé ; le nettoyage retire alors l'écriture à la fin de son délai.
    async fn abandon(&self, target: &WriteTarget<'_>) {
        self.remove_written(target).await;
        let params = ObjectRefParams {
            object: target.id.to_sql(),
        };
        let deleted = retry_conflicts(|| self.store.object_delete(params.clone())).await;
        if let Err(error) = deleted {
            tracing::warn!(object = %target.id.to_sql(), error = %error, "fiche d'une écriture en échec non supprimée");
        }
    }

    /// Fiche d'un fichier à servir (disponible seulement), sans ouvrir ses octets.
    pub async fn stat(&self, params: ObjectGetParams) -> StorageResult<StoredObject> {
        Ok(self.store.object_open(params).await?)
    }

    /// Ouvre un fichier disponible en lecture, en entier ou sur une plage d'octets. Fichier
    /// chiffré : seuls les segments de la plage sont lus et déchiffrés ; un segment en échec met
    /// fin au flux par une erreur (`STORAGE_INTEGRITY_FAILED`), que l'appelant ne doit jamais
    /// présenter comme une fin normale.
    pub async fn open(
        &self,
        params: ObjectGetParams,
        range: Option<ByteRange>,
    ) -> StorageResult<OpenedObject> {
        let object = self.store.object_open(params).await?;
        if object.content_key_id.is_some() {
            return self.open_encrypted(object, range).await;
        }
        let size = object.size.and_then(|size| u64::try_from(size).ok());
        let range = match (range, size) {
            (Some(range), Some(size)) => Some(range.resolve(size)?),
            _ => None,
        };
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

    /// Fichier chiffré ouvert : clé ouverte par le coffre-fort, en-tête lu, plage traduite en
    /// segments, segments lus en flux et déchiffrés.
    async fn open_encrypted(
        &self,
        object: StoredObject,
        range: Option<ByteRange>,
    ) -> StorageResult<OpenedObject> {
        let encryption = self.encryption()?;
        let integrity = |message: &str| StorageError::IntegrityFailed(message.to_string());
        let size = object
            .size
            .and_then(|size| u64::try_from(size).ok())
            .ok_or_else(|| integrity("taille absente de la fiche"))?;
        let stored = object
            .stored_size
            .and_then(|size| u64::try_from(size).ok())
            .ok_or_else(|| integrity("taille stockée absente de la fiche"))?;
        let (key, context) = encryption
            .open_key(object.tenant.as_ref(), &object.id)
            .await?;
        let backend = self.backends.get(&object.backend)?.store();
        let path = location(&object.path)?;
        let header = backend
            .get_opts(
                &path,
                GetOptions {
                    range: Some(GetRange::Bounded(0..STREAM_HEADER_BYTES as u64)),
                    ..GetOptions::default()
                },
            )
            .await?
            .bytes()
            .await?;
        let decryptor = StreamDecryptor::new(&key, &context, &header, stored)
            .map_err(|_| integrity("en-tête du fichier chiffré illisible"))?;
        drop(key);
        if decryptor.plaintext_len() != size {
            return Err(integrity(
                "taille du fichier chiffré différente de sa fiche",
            ));
        }
        let range = match range {
            Some(range) => range.resolve(size)?,
            None => 0..size,
        };
        let span = decryptor
            .plan_range(range.clone())
            .map_err(|_| StorageError::RangeNotSatisfiable(size))?;
        let ciphertext = backend
            .get_opts(
                &path,
                GetOptions {
                    range: Some(GetRange::Bounded(span.ciphertext.clone())),
                    ..GetOptions::default()
                },
            )
            .await?
            .into_stream()
            .map(|chunk| chunk.map_err(StorageError::from))
            .boxed();
        Ok(OpenedObject {
            object,
            range,
            content: decrypting_stream(decryptor, span, ciphertext),
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

    /// Relit les octets stockés d'un fichier et compare leur taille et leur empreinte à sa fiche
    /// (le chiffré d'un fichier chiffré, sans le déchiffrer).
    pub async fn verify(&self, object: &str) -> StorageResult<StoredObject> {
        let object = self
            .store
            .object_get(ObjectGetParams::by_id(object))
            .await?;
        let (Some(expected_size), Some(expected_hash)) =
            (object.stored_size, object.blake3.as_deref())
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

/// Fichier en cours d'écriture : sa fiche en attente et l'emplacement de ses octets.
pub(crate) struct WriteTarget<'a> {
    /// Fiche.
    pub id: &'a StorageRecordId,
    /// Support qui porte les octets.
    pub backend: &'a str,
    /// Emplacement des octets sur le support.
    pub path: &'a str,
    /// Taille maximale acceptée, en octets.
    pub max_size: i64,
    /// Type MIME annoncé.
    pub declared_type: Option<&'a str>,
}

/// Contenu écrit : taille réelle, empreinte des octets stockés et type réel.
struct Written {
    size: i64,
    blake3: String,
    content_type: String,
}

/// Octets à ranger sur le support : comptés dans l'empreinte, puis confiés à l'écriture par
/// parties (rien pour un morceau vide).
fn store_bytes(hasher: &mut Blake3Hasher, writer: &mut WriteMultipart, bytes: Bytes) {
    if !bytes.is_empty() {
        hasher.update(&bytes);
        writer.put(bytes);
    }
}

/// Écrit le flux par parties ; chaque morceau est compté, examiné (type réel) et, si un
/// antivirus est branché, transmis à son analyse, sur le clair, dans le même passage ; puis
/// chiffré si `encryptor` est donné ; l'empreinte est celle des octets rangés. Rend la taille
/// réelle, l'empreinte et le type réel du contenu. En cas d'échec ou de menace reconnue,
/// l'écriture est abandonnée sur le support.
async fn write<S>(
    backend: &dyn ObjectStore,
    scanner: Option<&dyn ContentScanner>,
    target: &WriteTarget<'_>,
    declared_size: Option<u64>,
    mut encryptor: Option<EncryptingWriter>,
    content: S,
) -> StorageResult<Written>
where
    S: Stream<Item = StorageResult<Bytes>> + Send,
{
    let max_size = u64::try_from(target.max_size).unwrap_or(0);
    let mut scan = match scanner {
        Some(scanner) => Some(scanner.begin().await?),
        None => None,
    };
    let upload = backend.put_multipart(&location(target.path)?).await?;
    let mut writer = WriteMultipart::new_with_chunk_size(upload, PART_SIZE);
    let mut hasher = Blake3Hasher::new();
    let mut head: Vec<u8> = Vec::new();
    let mut size: u64 = 0;
    let mut content = std::pin::pin!(content);
    if let Some(encryptor) = encryptor.as_mut() {
        store_bytes(&mut hasher, &mut writer, encryptor.header());
    }
    let failure = loop {
        let chunk = match content.next().await {
            None => break None,
            Some(Ok(chunk)) => chunk,
            Some(Err(error)) => break Some(error),
        };
        size += chunk.len() as u64;
        if size > max_size || declared_size.is_some_and(|declared| size > declared) {
            break Some(StorageError::ContentMismatch(format!(
                "contenu plus grand que la taille acceptée ({} octets)",
                declared_size.map_or(max_size, |declared| declared.min(max_size))
            )));
        }
        if head.len() < HEAD_SIZE {
            let wanted = (HEAD_SIZE - head.len()).min(chunk.len());
            head.extend_from_slice(&chunk[..wanted]);
        }
        if let Some(scan) = &mut scan {
            if let Err(error) = scan.feed(&chunk).await {
                break Some(error);
            }
        }
        let stored = match encryptor.as_mut() {
            Some(encryptor) => match encryptor.update(&chunk) {
                Ok(encrypted) => encrypted,
                Err(error) => break Some(error),
            },
            None => chunk,
        };
        // Une seule partie en cours d'envoi : la mémoire reste bornée à deux parties
        if let Err(error) = writer.wait_for_capacity(1).await {
            break Some(error.into());
        }
        store_bytes(&mut hasher, &mut writer, stored);
    };
    let failure = failure.or_else(|| {
        declared_size
            .filter(|declared| *declared != size)
            .map(|declared| {
                StorageError::ContentMismatch(format!("{size} octets reçus, {declared} annoncés"))
            })
    });
    // Verdict de l'antivirus avant de terminer l'écriture : un fichier infecté n'est jamais
    // présent en entier sur le support
    let failure = match (failure, scan) {
        (Some(error), _) => Some(error),
        (None, Some(scan)) => match scan.finish().await {
            Ok(ScanVerdict::Clean) => None,
            Ok(ScanVerdict::Infected(name)) => {
                tracing::warn!(object = %target.id.to_sql(), signature = %name, "fichier refusé par l'antivirus");
                Some(StorageError::Infected(name))
            }
            Err(error) => Some(error),
        },
        (None, None) => None,
    };
    // Dernier segment chiffré, après le verdict de l'antivirus
    let failure = match (failure, encryptor.as_mut()) {
        (None, Some(encryptor)) => match encryptor.finish() {
            Ok(last) => {
                store_bytes(&mut hasher, &mut writer, last);
                None
            }
            Err(error) => Some(error),
        },
        (failure, _) => failure,
    };
    if let Some(error) = failure {
        if let Err(abort) = writer.abort().await {
            tracing::warn!(object = %target.id.to_sql(), error = %abort, "écriture non abandonnée sur le support");
        }
        return Err(error);
    }
    writer.finish().await?;
    let size = i64::try_from(size)
        .map_err(|_| StorageError::ContentMismatch("contenu trop grand".to_string()))?;
    Ok(Written {
        size,
        blake3: hasher.finalize_hex(),
        content_type: detect(&head, target.declared_type),
    })
}
