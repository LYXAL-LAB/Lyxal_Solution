// SPDX-License-Identifier: AGPL-3.0-only

//! Certificats des écoutes chiffrées (décision G8) : fichiers PEM lus par l'hôte (`lyxal_crypto`
//! ne lit aucun fichier), un certificat par défaut et des certificats par nom, tous servis par
//! un seul `TlsCertificateStore` partagé par les écoutes.
//!
//! Le worker `mail.tls_reload` relit les fichiers à intervalle fixe ; un couple (chaîne, clé)
//! dont l'empreinte BLAKE3 a changé est rechargé et remplace l'ancien à chaud (les connexions
//! ouvertes gardent l'ancien). Un couple invalide est ignoré : l'ancien reste en service,
//! l'erreur est journalisée (`GROUPWARE_TLS_CERTIFICATE_INVALID`) et la sonde passe à
//! « dégradé » jusqu'au prochain rechargement réussi. Un fichier de clé lisible par le groupe ou
//! les autres comptes est refusé (Unix).
//!
//! Écrit pour Lyxal OS.

use crate::config::{CertificateFiles, TlsConfig};
use crate::error::GroupwareError;
use async_trait::async_trait;
use lyxal_crypto::{blake3, blake3_hex, SecretBytes, TlsCertificateStore, TlsCertifiedKey};
use lyxal_runtime::worker::{
    LyxalWorker, RestartPolicy, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
    WorkerRestartBackoff,
};
use lyxal_runtime::{ModuleId, RuntimeError};
use serde::Serialize;
use std::fs::File;
use std::io::Read;
use std::path::Path;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::{Arc, Mutex};
use std::time::Duration;

/// Code journalisé quand un certificat est refusé.
pub const CERTIFICATE_INVALID_CODE: &str = "GROUPWARE_TLS_CERTIFICATE_INVALID";

/// Plus grande chaîne lue (celle qu'accepte `lyxal_crypto`).
const MAX_CHAIN_BYTES: u64 = 64 * 1024;
/// Plus grande clé lue (celle qu'accepte `lyxal_crypto`).
const MAX_KEY_BYTES: u64 = 16 * 1024;

/// Un couple de fichiers et les noms qu'il sert (aucun : certificat par défaut).
struct Source {
    names: Vec<String>,
    files: CertificateFiles,
    /// Empreintes (chaîne, clé) du couple en service.
    digests: Mutex<Option<([u8; 32], [u8; 32])>>,
}

impl Source {
    fn label(&self) -> String {
        if self.names.is_empty() {
            "défaut".into()
        } else {
            self.names.join(", ")
        }
    }
}

/// Certificats du nœud : magasin partagé par les écoutes, et état du dernier rechargement.
pub struct Certificates {
    store: Arc<TlsCertificateStore>,
    sources: Vec<Source>,
    interval: Duration,
    /// Vrai depuis l'échec d'un rechargement, jusqu'au prochain passage sans erreur.
    degraded: AtomicBool,
    reloaded: AtomicU64,
    failed: AtomicU64,
}

impl Certificates {
    /// Charge les certificats de `config` ; `None` si aucun n'est déclaré. Un certificat
    /// illisible ou invalide arrête le démarrage (`GROUPWARE_TLS_CERTIFICATE_INVALID`).
    pub fn load(config: &TlsConfig) -> Result<Option<Arc<Self>>, GroupwareError> {
        if !config.has_certificates() {
            return Ok(None);
        }
        let sources = config
            .default
            .iter()
            .map(|files| Source {
                names: Vec::new(),
                files: files.clone(),
                digests: Mutex::new(None),
            })
            .chain(config.certificates.iter().map(|named| Source {
                names: named.names.clone(),
                files: named.files(),
                digests: Mutex::new(None),
            }))
            .collect();
        let certificates = Arc::new(Self {
            store: TlsCertificateStore::new(None),
            sources,
            interval: Duration::from_secs(config.reload_interval_seconds),
            degraded: AtomicBool::new(false),
            reloaded: AtomicU64::new(0),
            failed: AtomicU64::new(0),
        });
        for source in &certificates.sources {
            certificates.refresh(source)?;
        }
        Ok(Some(certificates))
    }

    /// Magasin servi aux écoutes.
    pub fn store(&self) -> Arc<TlsCertificateStore> {
        self.store.clone()
    }

    /// Relit tous les couples ; un couple changé et valide remplace l'ancien, un couple invalide
    /// est ignoré (l'ancien reste) et rend l'état « dégradé ». Rend le nombre de couples
    /// remplacés.
    pub fn reload(&self) -> usize {
        let mut replaced = 0;
        let mut failed = false;
        for source in &self.sources {
            match self.refresh(source) {
                Ok(true) => replaced += 1,
                Ok(false) => {}
                Err(error) => {
                    failed = true;
                    self.failed.fetch_add(1, Ordering::Relaxed);
                    tracing::error!(
                        code = CERTIFICATE_INVALID_CODE,
                        certificate = %source.label(),
                        %error,
                        "certificat refusé au rechargement : l'ancien reste en service"
                    );
                }
            }
        }
        self.degraded.store(failed, Ordering::Relaxed);
        replaced
    }

    /// Vrai si le dernier rechargement a refusé un certificat.
    pub fn degraded(&self) -> bool {
        self.degraded.load(Ordering::Relaxed)
    }

    /// Mesures des rechargements.
    pub fn snapshot(&self) -> CertificatesSnapshot {
        CertificatesSnapshot {
            certificates: self.sources.len(),
            reloaded: self.reloaded.load(Ordering::Relaxed),
            failed: self.failed.load(Ordering::Relaxed),
            degraded: self.degraded(),
        }
    }

    /// Worker `lyxal_mail:mail.tls_reload`.
    pub fn worker(self: &Arc<Self>) -> Result<CertificateReloadWorker, RuntimeError> {
        let module = ModuleId::new(lyxal_mail::MODULE_ID);
        let name = "mail.tls_reload".to_string();
        let descriptor = WorkerDescriptor::new(WorkerId::new(&module, &name)?, module, name)
            .with_description(format!(
                "Relecture des certificats TLS toutes les {} s",
                self.interval.as_secs()
            ))
            // Un rechargement en panne laisse les certificats en service : module non malade
            .with_criticality(WorkerCriticality::Optional)
            .with_restart_policy(RestartPolicy::OnFailure {
                max_retries: 5,
                backoff: WorkerRestartBackoff::default(),
            });
        Ok(CertificateReloadWorker {
            descriptor,
            certificates: self.clone(),
        })
    }

    /// Lit le couple `source` et, s'il a changé, le met en service. `Ok(false)` : inchangé.
    fn refresh(&self, source: &Source) -> Result<bool, GroupwareError> {
        let invalid = |message: String| GroupwareError::TlsCertificate {
            source_name: source.label(),
            message,
        };
        let chain = read_limited(&source.files.certificate, MAX_CHAIN_BYTES).map_err(invalid)?;
        check_key_permissions(&source.files.private_key).map_err(invalid)?;
        let key = read_limited(&source.files.private_key, MAX_KEY_BYTES).map_err(invalid)?;
        let key = SecretBytes::new(key).map_err(|error| invalid(error.to_string()))?;
        let digests = (blake3(&chain), blake3(key.expose_secret()));
        let mut current = source
            .digests
            .lock()
            .unwrap_or_else(|poisoned| poisoned.into_inner());
        if *current == Some(digests) {
            return Ok(false);
        }

        let certified = |key: &SecretBytes| {
            let key = SecretBytes::new(key.expose_secret().to_vec())
                .map_err(|error| invalid(error.to_string()))?;
            TlsCertifiedKey::from_pem(&chain, key).map_err(|error| invalid(error.to_string()))
        };
        if source.names.is_empty() {
            self.store.set_default(Some(certified(&key)?));
        } else {
            // Chaque nom est d'abord essayé à part : un nom non couvert laisse tous les noms du
            // couple sur l'ancien certificat
            let probe = TlsCertificateStore::new(None);
            for name in &source.names {
                probe
                    .insert(name, certified(&key)?)
                    .map_err(|error| invalid(format!("nom « {name} » : {error}")))?;
            }
            for name in &source.names {
                self.store
                    .insert(name, certified(&key)?)
                    .map_err(|error| invalid(format!("nom « {name} » : {error}")))?;
            }
        }
        let first = current.is_none();
        *current = Some(digests);
        if !first {
            self.reloaded.fetch_add(1, Ordering::Relaxed);
        }
        tracing::info!(
            certificate = %source.label(),
            fingerprint = %blake3_hex(&chain),
            "certificat TLS {}",
            if first { "chargé" } else { "rechargé" }
        );
        Ok(true)
    }
}

/// Lit `path` (liens symboliques suivis) en refusant plus de `limit` octets.
fn read_limited(path: &Path, limit: u64) -> Result<Vec<u8>, String> {
    let file = File::open(path).map_err(|error| format!("{} : {error}", path.display()))?;
    let mut bytes = Vec::new();
    file.take(limit + 1)
        .read_to_end(&mut bytes)
        .map_err(|error| format!("{} : {error}", path.display()))?;
    if bytes.len() as u64 > limit {
        return Err(format!(
            "{} : fichier de plus de {limit} octets",
            path.display()
        ));
    }
    Ok(bytes)
}

/// Refuse un fichier de clé lisible ou modifiable par le groupe ou les autres comptes (mode
/// `& 0o077`, Unix ; liens symboliques suivis jusqu'au fichier).
#[cfg(unix)]
fn check_key_permissions(path: &Path) -> Result<(), String> {
    use std::os::unix::fs::PermissionsExt;
    let mode = std::fs::metadata(path)
        .map_err(|error| format!("{} : {error}", path.display()))?
        .permissions()
        .mode();
    if mode & 0o077 != 0 {
        return Err(format!(
            "{} : clé privée accessible au groupe ou aux autres comptes (mode {:o}, attendu 600 ou 400)",
            path.display(),
            mode & 0o777
        ));
    }
    Ok(())
}

/// Hors Unix, les droits du fichier de clé relèvent de l'exploitant (listes d'accès).
#[cfg(not(unix))]
fn check_key_permissions(_path: &Path) -> Result<(), String> {
    Ok(())
}

/// Mesures des certificats, pour `/metrics`.
#[derive(Debug, Serialize)]
pub struct CertificatesSnapshot {
    /// Couples déclarés (défaut compris).
    pub certificates: usize,
    /// Rechargements réussis (hors chargement initial).
    pub reloaded: u64,
    /// Rechargements refusés.
    pub failed: u64,
    /// Dernier rechargement en échec.
    pub degraded: bool,
}

/// Worker `lyxal_mail:mail.tls_reload` : relit les certificats à intervalle fixe.
pub struct CertificateReloadWorker {
    descriptor: WorkerDescriptor,
    certificates: Arc<Certificates>,
}

#[async_trait]
impl LyxalWorker for CertificateReloadWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        let mut interval = tokio::time::interval(self.certificates.interval);
        interval.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Delay);
        // Premier tic immédiat : les certificats viennent d'être chargés
        interval.tick().await;
        loop {
            tokio::select! {
                () = ctx.cancellation.cancelled() => return Ok(()),
                _ = interval.tick() => {
                    let certificates = self.certificates.clone();
                    // Lecture de fichiers et analyse des clés hors de la boucle asynchrone
                    tokio::task::spawn_blocking(move || certificates.reload())
                        .await
                        .map_err(|error| RuntimeError::WorkerFailed {
                            worker: self.descriptor.id.to_string(),
                            message: format!("rechargement des certificats interrompu : {error}"),
                        })?;
                }
            }
        }
    }
}
