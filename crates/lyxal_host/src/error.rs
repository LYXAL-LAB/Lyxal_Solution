//! Erreurs du code commun des hôtes, sans code d'erreur : chaque hôte les traduit dans ses
//! propres codes (`SERVER_*` pour `lyxal-server`). Une erreur du runtime garde la sienne.

use thiserror::Error;

/// Erreur du code commun des hôtes.
#[derive(Debug, Error)]
pub enum HostError {
    /// Configuration illisible ou refusée.
    #[error("configuration invalide : {message}")]
    Configuration { message: String },

    /// Base injoignable ou sonde en échec.
    #[error("base de données indisponible : {message}")]
    Database { message: String },

    /// Manifeste d'un module embarqué illisible.
    #[error("installation du module `{module}` impossible : {message}")]
    ModuleInstall { module: String, message: String },

    /// Adresse d'écoute indisponible.
    #[error("adresse d'écoute `{address}` indisponible : {message}")]
    Bind { address: String, message: String },

    /// Attente du signal d'arrêt impossible.
    #[error("signal d'arrêt indisponible : {message}")]
    ShutdownSignal { message: String },

    /// Journal non initialisé.
    #[error("journalisation non initialisée : {message}")]
    Telemetry { message: String },

    /// Erreur du runtime (code `RUNTIME_*`).
    #[error("erreur du runtime : {0}")]
    Runtime(#[from] lyxal_runtime::RuntimeError),
}
