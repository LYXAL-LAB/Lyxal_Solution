use std::time::Duration;

/// Configuration centralisée du moteur d'exécution Lyxal Runtime.
#[derive(Debug, Clone)]
pub struct RuntimeConfig {
    /// Délai maximal alloué pour l'opération d'installation d'un module (par défaut: 30s).
    pub install_timeout: Duration,
    /// Délai maximal alloué pour l'opération de démarrage d'un module (par défaut: 30s).
    pub start_timeout: Duration,
    /// Délai maximal alloué pour l'opération d'arrêt d'un module (par défaut: 30s).
    pub stop_timeout: Duration,
    /// Version courante du Runtime Lyxal (par défaut: 0.1.0).
    pub runtime_version: semver::Version,
}

impl Default for RuntimeConfig {
    fn default() -> Self {
        Self {
            install_timeout: Duration::from_secs(30),
            start_timeout: Duration::from_secs(30),
            stop_timeout: Duration::from_secs(30),
            runtime_version: semver::Version::parse("0.1.0").expect("Static semver"),
        }
    }
}

impl RuntimeConfig {
    /// Crée une configuration avec les valeurs par défaut.
    pub fn new() -> Self {
        Self::default()
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
