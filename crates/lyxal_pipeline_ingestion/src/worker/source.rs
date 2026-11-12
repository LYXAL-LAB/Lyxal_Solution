//! Lecture du fichier source d'un lot dans `lyxal_storage`, au fil de l'eau.
//!
//! Les octets arrivent du stockage par un flux asynchrone ; les lecteurs de formats
//! (`lyxal_parsing`) sont synchrones. La lecture tourne donc dans une tâche bloquante, attendue
//! par le worker : elle tire les octets du flux à la demande et rend les éléments de la source,
//! comptés (contrôle de lecture) ou regroupés en blocs envoyés par un canal borné. Rien n'est
//! chargé en entier ; la tâche s'arrête dès que le worker abandonne la lecture.

use bytes::Bytes;
use futures::stream::BoxStream;
use futures::StreamExt;
use lyxal_crypto::hash::Blake3Hasher;
use lyxal_storage::models::ObjectGetParams;
use lyxal_storage::{StorageError, StorageResult, StorageService};
use std::io::Read;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex, MutexGuard};
use tokio::runtime::Handle;
use tokio::sync::mpsc;

use crate::adapters::{AdapterRegistry, SourceItem};
use crate::error::{IngestionError, IngestionResult};
use crate::models::IngestionBatch;

/// Éléments lus entre deux contrôles de l'arrêt pendant le contrôle de lecture.
const STOP_CHECK_EVERY: usize = 256;

/// État de la lecture des octets, partagé entre le lecteur de format et la tâche de lecture.
struct SourceState {
    handle: Handle,
    stream: BoxStream<'static, StorageResult<Bytes>>,
    current: Bytes,
    hasher: Option<Blake3Hasher>,
    size: u64,
    /// Échec du stockage pendant la lecture : cause réelle d'une source devenue illisible.
    failure: Option<StorageError>,
}

/// Octets du fichier source, lus à la demande dans le flux du stockage. À utiliser depuis une
/// tâche bloquante.
#[derive(Clone)]
struct SourceReader(Arc<Mutex<SourceState>>);

impl SourceReader {
    fn state(&self) -> MutexGuard<'_, SourceState> {
        self.0
            .lock()
            .unwrap_or_else(std::sync::PoisonError::into_inner)
    }

    /// Lit le reste du fichier (un lecteur de format peut s'arrêter avant la fin), puis rend sa
    /// taille et son empreinte.
    fn finish(&self) -> IngestionResult<(u64, String)> {
        let mut sink = [0u8; 64 * 1024];
        let mut reader = self.clone();
        loop {
            match reader.read(&mut sink) {
                Ok(0) => break,
                Ok(_) => {}
                Err(error) => return Err(self.failure_or(error.to_string())),
            }
        }
        let mut state = self.state();
        let hash = state
            .hasher
            .take()
            .map(Blake3Hasher::finalize_hex)
            .unwrap_or_default();
        Ok((state.size, hash))
    }

    /// Échec du stockage enregistré pendant la lecture, sinon une source illisible.
    fn failure_or(&self, detail: String) -> IngestionError {
        match self.state().failure.take() {
            Some(error) => unavailable(&error),
            None => IngestionError::SourceInvalid {
                code: "PARSING_IO_ERROR".to_string(),
                detail,
            },
        }
    }
}

impl Read for SourceReader {
    fn read(&mut self, buffer: &mut [u8]) -> std::io::Result<usize> {
        let mut state = self.state();
        while state.current.is_empty() {
            let handle = state.handle.clone();
            match handle.block_on(state.stream.next()) {
                None => return Ok(0),
                Some(Ok(chunk)) => {
                    state.size += chunk.len() as u64;
                    if let Some(hasher) = state.hasher.as_mut() {
                        hasher.update(&chunk);
                    }
                    state.current = chunk;
                }
                Some(Err(error)) => {
                    let message = error.to_string();
                    state.failure = Some(error);
                    return Err(std::io::Error::other(message));
                }
            }
        }
        let count = buffer.len().min(state.current.len());
        let chunk = state.current.split_to(count);
        buffer[..count].copy_from_slice(&chunk);
        Ok(count)
    }
}

fn unavailable(error: &StorageError) -> IngestionError {
    IngestionError::SourceUnavailable {
        code: error.code(),
        detail: error.to_string(),
    }
}

/// Arrêt de la tâche de lecture demandé quand le worker abandonne la lecture (fin, erreur,
/// arrêt du serveur).
pub(super) struct StopOnDrop(Arc<AtomicBool>);

impl Drop for StopOnDrop {
    fn drop(&mut self) {
        self.0.store(true, Ordering::Relaxed);
    }
}

/// Fichier source d'un lot, ouvert dans le stockage.
pub(super) struct BatchSource {
    reader: SourceReader,
    batch: IngestionBatch,
}

impl BatchSource {
    /// Ouvre le fichier source du lot dans `lyxal_storage`.
    pub(super) async fn open(
        storage: &StorageService,
        batch: &IngestionBatch,
    ) -> IngestionResult<Self> {
        let opened = storage
            .open(ObjectGetParams::by_id(batch.source_object.clone()), None)
            .await
            .map_err(|error| unavailable(&error))?;
        Ok(Self {
            reader: SourceReader(Arc::new(Mutex::new(SourceState {
                handle: Handle::current(),
                stream: opened.content,
                current: Bytes::new(),
                hasher: Some(Blake3Hasher::new()),
                size: 0,
                failure: None,
            }))),
            batch: batch.clone(),
        })
    }

    /// Éléments de la source, lus par l'adaptateur du format du lot.
    fn items(
        &self,
    ) -> IngestionResult<impl Iterator<Item = IngestionResult<SourceItem>> + Send + 'static> {
        let adapter = AdapterRegistry::new()
            .get(self.batch.source_type)
            .ok_or_else(|| {
                IngestionError::Adapter(format!(
                    "Aucun adaptateur disponible pour le format {:?}",
                    self.batch.source_type
                ))
            })?;
        let reader = self.reader.clone();
        let failing = self.reader.clone();
        let items = adapter
            .read(Box::new(reader), self.batch.source_encoding)
            .map_err(|error| failing.source_error(error))?;
        let failing = self.reader.clone();
        Ok(items.map(move |item| item.map_err(|error| failing.source_error(error))))
    }

    /// Contrôle de lecture : lit toute la source sans rien garder et rend le nombre de ses
    /// éléments. Une source illisible, ou dont les octets n'ont plus la taille ou l'empreinte
    /// du lot, est refusée avant toute mise en staging. `None` si la lecture a été arrêtée.
    pub(super) async fn count(self, stop: Arc<AtomicBool>) -> IngestionResult<Option<usize>> {
        let task = tokio::task::spawn_blocking(move || {
            let mut total = 0usize;
            for item in self.items()? {
                item?;
                total += 1;
                if total.is_multiple_of(STOP_CHECK_EVERY) && stop.load(Ordering::Relaxed) {
                    return Ok(None);
                }
            }
            let (size, hash) = self.reader.finish()?;
            if size != self.batch.taille_octets as u64 || hash != self.batch.file_hash_blake3 {
                return Err(IngestionError::SourceAltered(format!(
                    "{size} octets relus pour {} enregistrés, ou empreinte différente",
                    self.batch.taille_octets
                )));
            }
            Ok(Some(total))
        });
        joined(task.await)
    }

    /// Lit la source par blocs de `chunk_size` éléments, après en avoir passé `skip` (déjà
    /// traités avant une reprise). Les blocs arrivent par un canal borné : au plus un bloc en
    /// attente et un en cours de lecture. La tâche de lecture est rendue pour être attendue à
    /// la fin.
    pub(super) fn chunks(
        self,
        skip: usize,
        chunk_size: usize,
        stop: Arc<AtomicBool>,
    ) -> (
        mpsc::Receiver<IngestionResult<Vec<SourceItem>>>,
        tokio::task::JoinHandle<()>,
    ) {
        let (sender, receiver) = mpsc::channel(1);
        let task = tokio::task::spawn_blocking(move || {
            let items = match self.items() {
                Ok(items) => items,
                Err(error) => {
                    let _ = sender.blocking_send(Err(error));
                    return;
                }
            };
            let mut chunk = Vec::with_capacity(chunk_size);
            for item in items.skip(skip) {
                if stop.load(Ordering::Relaxed) {
                    return;
                }
                match item {
                    Ok(item) => chunk.push(item),
                    Err(error) => {
                        let _ = sender.blocking_send(Err(error));
                        return;
                    }
                }
                if chunk.len() == chunk_size {
                    let full = std::mem::replace(&mut chunk, Vec::with_capacity(chunk_size));
                    if sender.blocking_send(Ok(full)).is_err() {
                        return;
                    }
                }
            }
            if !chunk.is_empty() {
                let _ = sender.blocking_send(Ok(chunk));
            }
        });
        (receiver, task)
    }
}

impl SourceReader {
    /// Erreur de lecture d'un adaptateur : si le stockage a échoué pendant la lecture, c'est lui
    /// la cause, pas le contenu de la source.
    fn source_error(&self, error: IngestionError) -> IngestionError {
        match self.state().failure.take() {
            Some(failure) => unavailable(&failure),
            None => error,
        }
    }
}

/// Résultat d'une tâche de lecture ; une tâche interrompue est une erreur de traitement.
fn joined<T>(result: Result<IngestionResult<T>, tokio::task::JoinError>) -> IngestionResult<T> {
    match result {
        Ok(result) => result,
        Err(error) => Err(IngestionError::Storage(format!(
            "lecture du fichier source interrompue : {error}"
        ))),
    }
}

/// Indicateur d'arrêt d'une lecture et sa garde : la lecture s'arrête quand la garde est lâchée.
pub(super) fn stop_flag() -> (Arc<AtomicBool>, StopOnDrop) {
    let flag = Arc::new(AtomicBool::new(false));
    (flag.clone(), StopOnDrop(flag))
}
