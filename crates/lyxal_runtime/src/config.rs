use crate::presence::{HostId, PresenceConfig};
use std::time::Duration;

/// Configuration centralisée du moteur d'exécution Lyxal Runtime.
#[derive(Debug, Clone)]
pub struct RuntimeConfig {
    /// Hôte : rôle du binaire qui porte ce runtime, constante de son code.
    pub host: HostId,
    /// Délai maximal alloué pour l'opération d'installation d'un module (par défaut: 30s).
    pub install_timeout: Duration,
    /// Délai maximal alloué pour l'opération de démarrage d'un module (par défaut: 30s).
    pub start_timeout: Duration,
    /// Délai maximal alloué pour l'opération d'arrêt d'un module (par défaut: 30s).
    pub stop_timeout: Duration,
    /// Version courante du Runtime Lyxal (par défaut: 0.1.0).
    pub runtime_version: semver::Version,
    /// Réglages de la présence du nœud dans la base (battement, purge).
    pub presence: PresenceConfig,
}

/// Version du runtime, identique à celle du crate (vérifié par test).
pub const RUNTIME_VERSION: semver::Version = semver::Version::new(0, 1, 0);

impl RuntimeConfig {
    /// Crée la configuration du runtime de l'hôte `host`, avec les valeurs par défaut.
    pub fn new(host: HostId) -> Self {
        Self {
            host,
            install_timeout: Duration::from_secs(30),
            start_timeout: Duration::from_secs(30),
            stop_timeout: Duration::from_secs(30),
            runtime_version: RUNTIME_VERSION,
            presence: PresenceConfig::default(),
        }
    }

    /// Retourne l'hôte de ce runtime.
    pub fn host(&self) -> &HostId {
        &self.host
    }

    /// Modifie les réglages de présence du nœud.
    pub fn with_presence(mut self, presence: PresenceConfig) -> Self {
        self.presence = presence;
        self
    }

    /// Modifie le timeout d'installation.
    pub fn with_install_timeout(mut self, timeout: Duration) -> Self {
        self.install_timeout = timeout;
        self
    }

    /// Modifie le timeout de démarrage.
    pub fn with_start_timeout(mut self, timeout: Duration) -> Self {
        self.start_timeout = timeout;
        self
    }

    /// Modifie le timeout d'arrêt.
    pub fn with_stop_timeout(mut self, timeout: Duration) -> Self {
        self.stop_timeout = timeout;
        self
    }

    /// Modifie la version du runtime.
    pub fn with_runtime_version(mut self, version: semver::Version) -> Self {
        self.runtime_version = version;
        self
    }

    /// Retourne la version configurée du runtime.
    pub fn runtime_version(&self) -> &semver::Version {
        &self.runtime_version
    }
}

#[cfg(test)]
mod tests {
    use super::RUNTIME_VERSION;

    #[test]
    fn runtime_version_matches_crate_version() {
        assert_eq!(RUNTIME_VERSION.to_string(), env!("CARGO_PKG_VERSION"));
    }
}
