//! Chiffrement au repos des fichiers d'un bucket chiffré.
//!
//! ```text
//! clé « fichiers » de l'organisation (lyxal_secrets, FileKeys)
//!    └── clé du fichier (StreamKey, 32 octets tirés par OsRng, une par fichier),
//!        scellée (enc:v2) et rangée dans storage_object.content_key, illisible des utilisateurs
//!           └── octets du fichier : flux chiffré v1 de lyxal_crypto (en-tête de 47 octets,
//!               segments de 64 Kio authentifiés), écrit et lu en flux sur le support
//! ```
//!
//! Contexte de scellement de la clé, qui sert aussi d'identité au flux chiffré :
//! `SecretContext::with_tenant(<organisation> ou "lyxal_installation", "lyxal_storage",
//! "storage_object", <clé de la fiche>, "content_key")`. Un fichier recopié sous une autre fiche
//! ou une autre organisation ne s'ouvre pas.
//!
//! `lyxal_crypto` est synchrone ; ce module en est l'adaptateur asynchrone :
//! [`EncryptingWriter`] chiffre au fil de l'écriture (un segment en attente au plus),
//! [`decrypting_stream`] déchiffre au fil de la lecture les seuls segments d'une plage. Un segment
//! en échec rend une erreur dans le flux (`STORAGE_INTEGRITY_FAILED`), jamais une fin normale :
//! l'appelant interrompt sa réponse.

use bytes::{Bytes, BytesMut};
use futures::stream::BoxStream;
use futures::StreamExt;
use lyxal_crypto::{
    SecretContext, StreamDecryptor, StreamEncryptor, StreamKey, StreamSpan, STREAM_SEGMENT_BYTES,
    STREAM_TAG_BYTES,
};
use lyxal_secrets::{FileKeys, SealedFileKey, SecretsError};
use lyxal_surreal::{RecordId, ToSql};
use surrealdb::types::RecordIdKey;

use crate::error::{StorageError, StorageResult};
use crate::models::ObjectRefParams;
use crate::module::MODULE_ID;
use crate::store::StorageStore;

/// Ressource du contexte de scellement d'une clé de fichier.
const OBJECT_RESOURCE: &str = "storage_object";
/// Champ du contexte de scellement d'une clé de fichier.
const CONTENT_KEY_FIELD: &str = "content_key";

/// Service de clés des buckets chiffrés : clés de fichiers scellées par `lyxal_secrets`, et
/// session système qui lit la clé scellée d'une fiche après le contrôle des droits de
/// l'appelant.
#[derive(Clone)]
pub struct FileEncryption {
    keys: FileKeys,
    system: StorageStore,
}

impl FileEncryption {
    /// Service sur les clés de fichiers du coffre-fort et la session système de l'hôte.
    pub fn new(keys: FileKeys, system: StorageStore) -> Self {
        Self { keys, system }
    }

    /// Vrai si les clés peuvent être scellées et ouvertes (clé maîtresse du coffre-fort
    /// présente).
    pub fn is_available(&self) -> bool {
        self.keys.is_available()
    }

    /// Clés de fichiers du coffre-fort.
    pub fn keys(&self) -> &FileKeys {
        &self.keys
    }

    /// Clé neuve d'un fichier en cours d'écriture, scellée, et son chiffreur.
    pub(crate) async fn writer(
        &self,
        tenant: Option<&RecordId>,
        object: &RecordId,
    ) -> StorageResult<(EncryptingWriter, SealedFileKey)> {
        let context = object_context(tenant, object)?;
        let key = StreamKey::generate().map_err(|error| {
            StorageError::EncryptionUnavailable(format!("clé de fichier non tirée : {error}"))
        })?;
        let sealed = self
            .keys
            .seal(tenant, &key, &context)
            .await
            .map_err(key_error)?;
        Ok((EncryptingWriter::new(&key, &context)?, sealed))
    }

    /// Clé d'un fichier ouverte, et le contexte de son flux chiffré. La clé scellée est lue par
    /// la session système : l'appelant a déjà été contrôlé par la lecture de la fiche.
    pub(crate) async fn open_key(
        &self,
        tenant: Option<&RecordId>,
        object: &RecordId,
    ) -> StorageResult<(StreamKey, SecretContext)> {
        let record = self
            .system
            .object_key_get(ObjectRefParams {
                object: object.to_sql(),
            })
            .await?;
        let envelope = record.content_key.ok_or_else(|| {
            StorageError::IntegrityFailed("clé du fichier absente de sa fiche".to_string())
        })?;
        let sealed = SealedFileKey::parse(&envelope).map_err(key_error)?;
        let context = object_context(tenant, object)?;
        let key = self
            .keys
            .open(tenant, &sealed, &context)
            .await
            .map_err(key_error)?;
        Ok((key, context))
    }
}

/// Erreur du coffre-fort traduite : clé illisible pour ce fichier (altérée, recopiée d'ailleurs)
/// `STORAGE_INTEGRITY_FAILED` ; tout le reste (clé maîtresse absente, clé d'organisation
/// détruite ou illisible, base injoignable) `STORAGE_ENCRYPTION_UNAVAILABLE`, à réessayer.
pub(crate) fn key_error(error: SecretsError) -> StorageError {
    match error {
        SecretsError::ValueCorrupted => {
            StorageError::IntegrityFailed("clé du fichier illisible".to_string())
        }
        other => StorageError::EncryptionUnavailable(other.code()),
    }
}

/// Contexte de scellement de la clé d'un fichier, identité de son flux chiffré.
pub(crate) fn object_context(
    tenant: Option<&RecordId>,
    object: &RecordId,
) -> StorageResult<SecretContext> {
    let organization = FileKeys::context_tenant(tenant).map_err(key_error)?;
    let record = match &object.key {
        RecordIdKey::String(key) => key.clone(),
        RecordIdKey::Number(key) => key.to_string(),
        _ => {
            return Err(StorageError::IntegrityFailed(format!(
                "identifiant de fiche inattendu : {}",
                object.to_sql()
            )))
        }
    };
    SecretContext::with_tenant(
        &organization,
        MODULE_ID,
        OBJECT_RESOURCE,
        &record,
        CONTENT_KEY_FIELD,
    )
    .map_err(|error| StorageError::EncryptionUnavailable(format!("contexte refusé : {error}")))
}

/// Chiffrement d'un fichier au fil de son écriture : l'en-tête d'abord, puis chaque segment
/// complet, puis le dernier à la fin. Un segment de clair au plus reste en mémoire (effacé).
pub(crate) struct EncryptingWriter {
    encryptor: Option<StreamEncryptor>,
    header: Option<Bytes>,
}

impl EncryptingWriter {
    fn new(key: &StreamKey, context: &SecretContext) -> StorageResult<Self> {
        let (encryptor, header) = StreamEncryptor::new(key, context).map_err(|error| {
            StorageError::EncryptionUnavailable(format!("chiffrement non ouvert : {error}"))
        })?;
        Ok(Self {
            encryptor: Some(encryptor),
            header: Some(Bytes::copy_from_slice(&header)),
        })
    }

    /// En-tête du flux chiffré, à écrire en premier (vide après le premier appel).
    pub(crate) fn header(&mut self) -> Bytes {
        self.header.take().unwrap_or_default()
    }

    /// Octets chiffrés des segments complétés par ce morceau de clair (souvent vides).
    pub(crate) fn update(&mut self, plaintext: &[u8]) -> StorageResult<Bytes> {
        let encryptor = self.encryptor.as_mut().ok_or_else(finished)?;
        let mut out = Vec::new();
        encryptor
            .update(plaintext, &mut out)
            .map_err(|error| StorageError::ContentMismatch(format!("chiffrement : {error}")))?;
        Ok(Bytes::from(out))
    }

    /// Dernier segment chiffré.
    pub(crate) fn finish(&mut self) -> StorageResult<Bytes> {
        let encryptor = self.encryptor.take().ok_or_else(finished)?;
        let mut out = Vec::new();
        encryptor
            .finish(&mut out)
            .map_err(|error| StorageError::ContentMismatch(format!("chiffrement : {error}")))?;
        Ok(Bytes::from(out))
    }
}

fn finished() -> StorageError {
    StorageError::ContentMismatch("chiffrement déjà terminé".to_string())
}

/// Lecture d'une plage d'un fichier chiffré : les octets chiffrés des segments de `span`
/// (`ciphertext`) sont déchiffrés un segment à la fois, la plage demandée est rendue. Un segment
/// altéré, déplacé ou manquant met fin au flux par `STORAGE_INTEGRITY_FAILED`.
pub(crate) fn decrypting_stream(
    decryptor: StreamDecryptor,
    span: StreamSpan,
    ciphertext: BoxStream<'static, StorageResult<Bytes>>,
) -> BoxStream<'static, StorageResult<Bytes>> {
    let state = Decrypting {
        ciphertext,
        buffer: BytesMut::new(),
        index: span.first_segment,
        last: span.last_segment,
        skip: span.skip_in_first,
        remaining: span.take,
        decryptor,
        done: false,
    };
    futures::stream::unfold(state, |mut state| async move {
        let item = state.next_chunk().await?;
        Some((item, state))
    })
    .boxed()
}

struct Decrypting {
    ciphertext: BoxStream<'static, StorageResult<Bytes>>,
    buffer: BytesMut,
    decryptor: StreamDecryptor,
    index: u64,
    last: u64,
    skip: usize,
    remaining: u64,
    done: bool,
}

impl Decrypting {
    /// Taille chiffrée d'un segment (clair et étiquette) ; le dernier est plus court.
    fn segment_len(&self, index: u64) -> u64 {
        let segment = STREAM_SEGMENT_BYTES as u64;
        let plaintext = if index + 1 < self.decryptor.segment_count() {
            segment
        } else {
            self.decryptor.plaintext_len() - (self.decryptor.segment_count() - 1) * segment
        };
        plaintext + STREAM_TAG_BYTES as u64
    }

    fn fail(&mut self, message: String) -> Option<StorageResult<Bytes>> {
        self.done = true;
        Some(Err(StorageError::IntegrityFailed(message)))
    }

    /// Morceau suivant de la plage ; `None` à la fin. Après une erreur, plus rien.
    async fn next_chunk(&mut self) -> Option<StorageResult<Bytes>> {
        while !self.done && self.index <= self.last {
            let Ok(need) = usize::try_from(self.segment_len(self.index)) else {
                return self.fail(format!("segment {} trop grand", self.index));
            };
            while self.buffer.len() < need {
                match self.ciphertext.next().await {
                    Some(Ok(bytes)) => self.buffer.extend_from_slice(&bytes),
                    Some(Err(error)) => {
                        self.done = true;
                        return Some(Err(error));
                    }
                    None => return self.fail(format!("fichier tronqué au segment {}", self.index)),
                }
            }
            let segment = self.buffer.split_to(need);
            let plaintext = match self.decryptor.decrypt_segment(self.index, &segment) {
                Ok(plaintext) => plaintext,
                Err(_) => return self.fail(format!("segment {} altéré", self.index)),
            };
            self.index += 1;
            let bytes = plaintext.expose_secret();
            let start = std::mem::take(&mut self.skip).min(bytes.len());
            let available = bytes.len() - start;
            let take =
                usize::try_from(self.remaining).map_or(available, |rest| rest.min(available));
            self.remaining -= take as u64;
            if take > 0 {
                return Some(Ok(Bytes::copy_from_slice(&bytes[start..start + take])));
            }
        }
        None
    }
}
