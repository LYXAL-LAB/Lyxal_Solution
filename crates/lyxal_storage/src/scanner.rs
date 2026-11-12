//! Antivirus : analyse du contenu d'un fichier pendant son écriture.
//!
//! Le contenu est transmis au service `clamd` de ClamAV (protocole `INSTREAM`, bibliothèque
//! `clamav-client`) au fil de l'écriture : un seul passage, mémoire bornée. ClamAV reste un
//! service séparé, joint par le réseau ou par une socket Unix.

use async_trait::async_trait;
use bytes::Bytes;
use clamav_client::tokio::{Socket, Tcp};
use futures::future::BoxFuture;
use futures::stream;
use std::path::PathBuf;
use std::time::Duration;
use tokio::sync::mpsc;

use crate::error::{StorageError, StorageResult};

/// Morceaux en attente de transmission à l'antivirus.
const PENDING_CHUNKS: usize = 4;

/// Verdict de l'antivirus.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ScanVerdict {
    /// Aucune menace reconnue.
    Clean,
    /// Menace reconnue (nom de la signature).
    Infected(String),
}

/// Antivirus branché sur l'écriture des fichiers.
#[async_trait]
pub trait ContentScanner: Send + Sync {
    /// Ouvre l'analyse d'un fichier.
    async fn begin(&self) -> StorageResult<Box<dyn ScanSession>>;

    /// Vérifie que l'antivirus répond.
    async fn ping(&self) -> StorageResult<()>;
}

/// Analyse d'un fichier en cours : ses morceaux, dans l'ordre, puis le verdict.
#[async_trait]
pub trait ScanSession: Send {
    /// Transmet un morceau du fichier.
    async fn feed(&mut self, chunk: &Bytes) -> StorageResult<()>;

    /// Fin du fichier : verdict de l'antivirus.
    async fn finish(self: Box<Self>) -> StorageResult<ScanVerdict>;
}

/// Adresse du service `clamd`.
#[derive(Debug, Clone)]
pub enum ScannerConfig {
    /// Connexion TCP (`hôte:port`).
    Tcp {
        /// Adresse du service.
        address: String,
    },
    /// Socket Unix.
    Socket {
        /// Chemin de la socket.
        path: PathBuf,
    },
}

/// Antivirus ClamAV (service `clamd`).
#[derive(Debug, Clone)]
pub struct ClamAvScanner {
    config: ScannerConfig,
    timeout: Duration,
}

impl ClamAvScanner {
    /// Antivirus à cette adresse ; `timeout` borne chaque attente du service (transmission d'un
    /// morceau, verdict, sonde).
    pub fn new(config: ScannerConfig, timeout: Duration) -> Self {
        Self { config, timeout }
    }
}

fn unavailable(detail: impl std::fmt::Display) -> StorageError {
    StorageError::ScannerUnavailable(detail.to_string())
}

/// Verdict lu dans la réponse de `clamd` (`stream: OK`, `stream: <signature> FOUND`, ou une
/// erreur telle que le dépassement de sa limite de taille).
fn verdict(response: &[u8]) -> StorageResult<ScanVerdict> {
    let text = String::from_utf8_lossy(response);
    let text = text.trim_matches(|c: char| c == '\0' || c.is_whitespace());
    if let Some(found) = text.strip_suffix(" FOUND") {
        let name = found.rsplit(": ").next().unwrap_or(found);
        return Ok(ScanVerdict::Infected(name.to_string()));
    }
    if text.ends_with("OK") {
        return Ok(ScanVerdict::Clean);
    }
    Err(unavailable(format!("réponse de l'antivirus : {text}")))
}

#[async_trait]
impl ContentScanner for ClamAvScanner {
    async fn begin(&self) -> StorageResult<Box<dyn ScanSession>> {
        let (sender, receiver) = mpsc::channel::<Result<Bytes, std::io::Error>>(PENDING_CHUNKS);
        let content = stream::unfold(receiver, |mut receiver| async move {
            receiver.recv().await.map(|chunk| (chunk, receiver))
        });
        let scan: BoxFuture<'static, clamav_client::IoResult> = match self.config.clone() {
            ScannerConfig::Tcp { address } => Box::pin(clamav_client::tokio::scan_stream(
                content,
                Tcp {
                    host_address: address,
                },
                None,
            )),
            ScannerConfig::Socket { path } => Box::pin(clamav_client::tokio::scan_stream(
                content,
                Socket { socket_path: path },
                None,
            )),
        };
        Ok(Box::new(ClamAvSession {
            sender: Some(sender),
            scan,
            answer: None,
            timeout: self.timeout,
        }))
    }

    async fn ping(&self) -> StorageResult<()> {
        let ping = async {
            match self.config.clone() {
                ScannerConfig::Tcp { address } => {
                    clamav_client::tokio::ping(Tcp {
                        host_address: address,
                    })
                    .await
                }
                ScannerConfig::Socket { path } => {
                    clamav_client::tokio::ping(Socket { socket_path: path }).await
                }
            }
        };
        let response = tokio::time::timeout(self.timeout, ping)
            .await
            .map_err(|_| unavailable("délai dépassé"))?
            .map_err(unavailable)?;
        if response.starts_with(b"PONG") {
            Ok(())
        } else {
            Err(unavailable("réponse inattendue à la sonde"))
        }
    }
}

/// Analyse en cours : les morceaux passent par un canal borné ; la transmission à `clamd`
/// n'avance que pendant `feed` et `finish`, sans tâche de fond.
struct ClamAvSession {
    sender: Option<mpsc::Sender<Result<Bytes, std::io::Error>>>,
    scan: BoxFuture<'static, clamav_client::IoResult>,
    /// Réponse reçue avant la fin du fichier (limite de taille dépassée, connexion perdue).
    answer: Option<clamav_client::IoResult>,
    timeout: Duration,
}

#[async_trait]
impl ScanSession for ClamAvSession {
    async fn feed(&mut self, chunk: &Bytes) -> StorageResult<()> {
        let Some(sender) = &self.sender else {
            return Ok(());
        };
        if self.answer.is_some() {
            return Ok(());
        }
        tokio::select! {
            answer = &mut self.scan => {
                self.answer = Some(answer);
                Ok(())
            }
            sent = tokio::time::timeout(self.timeout, sender.send(Ok(chunk.clone()))) => match sent {
                Err(_) => Err(unavailable("délai dépassé pendant la transmission")),
                // Canal fermé : l'antivirus a déjà répondu, sa réponse est lue à la fin
                Ok(_) => Ok(()),
            },
        }
    }

    async fn finish(mut self: Box<Self>) -> StorageResult<ScanVerdict> {
        // Fin du fichier : le canal fermé termine le flux transmis à l'antivirus
        self.sender = None;
        let answer = match self.answer.take() {
            Some(answer) => answer,
            None => tokio::time::timeout(self.timeout, &mut self.scan)
                .await
                .map_err(|_| unavailable("délai dépassé en attendant le verdict"))?,
        };
        verdict(&answer.map_err(unavailable)?)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn the_answer_of_clamd_is_read() {
        assert_eq!(verdict(b"stream: OK\0").expect("sain"), ScanVerdict::Clean);
        assert_eq!(
            verdict(b"stream: Eicar-Test-Signature FOUND\0").expect("infecté"),
            ScanVerdict::Infected("Eicar-Test-Signature".to_string())
        );
        for refused in [
            &b"INSTREAM size limit exceeded. ERROR\0"[..],
            b"",
            b"stream: lecture impossible ERROR\0",
        ] {
            let error = verdict(refused).expect_err("réponse refusée");
            assert_eq!(error.code(), "STORAGE_SCANNER_UNAVAILABLE");
            assert!(error.is_retryable());
        }
    }
}
