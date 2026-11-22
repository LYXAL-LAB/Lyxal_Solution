//! Sections de configuration et construction des services communs aux hôtes : clé maîtresse du
//! coffre-fort (`[secrets]`, `lyxal_secrets`), supports des fichiers et antivirus (`[storage]`,
//! `lyxal_storage`).
//!
//! Les deux hôtes (`lyxal-server`, `lyxal-groupware`) partagent la même base : ces sections
//! reçoivent les mêmes valeurs dans les deux (même clé maîtresse, mêmes supports nommés), sans
//! quoi un hôte ne lit pas les fichiers écrits par l'autre. Seul le préfixe des variables
//! d'environnement change (`LYXAL__`, `LYXAL_GROUPWARE__`).

use crate::config::SecretPassword;
use crate::HostError;
use lyxal_crypto::{EnvironmentKeyProvider, KeyId, ResolvedKey};
use lyxal_secrets::MasterKeys;
use lyxal_storage::{BackendConfig, Backends, ClamAvScanner, ContentScanner, ScannerConfig};
use serde::Deserialize;
use std::collections::BTreeMap;
use std::path::PathBuf;
use std::sync::Arc;
use std::time::Duration;

/// Nom du support disque (celui d'un bucket créé sans support précisé).
pub const DEFAULT_BACKEND: &str = "default";

/// Clés de `[secrets]` et `[storage]` refusées dans les fichiers de configuration (variables
/// d'environnement seulement), à passer à [`crate::config::load_layered`].
pub const SECRET_KEYS: &[&str] = &[
    "storage.s3.*.secret_access_key",
    "secrets.master_key",
    "secrets.previous_master_key",
];

/// Clé maîtresse du coffre-fort (`lyxal_secrets`), la même pour tous les hôtes d'une base :
/// clé AES-256 de 32 octets en Base64 canonique (44 caractères), jamais dans les fichiers de
/// configuration, uniquement par la variable `<préfixe>__SECRETS__MASTER_KEY` (lue par
/// `lyxal_crypto::EnvironmentKeyProvider`), avec son identifiant `master_key_id`. Pendant une
/// rotation, l'ancienne clé est fournie à côté, en lecture seule
/// (`<préfixe>__SECRETS__PREVIOUS_MASTER_KEY`, `previous_master_key_id`). Sans clé, aucune
/// valeur du coffre-fort ni aucun fichier chiffré n'est écrit ni lu (sondes « dégradé »).
#[derive(Clone, Debug, Default, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct SecretsConfig {
    #[serde(default)]
    pub master_key: Option<SecretPassword>,
    #[serde(default)]
    pub master_key_id: Option<String>,
    #[serde(default)]
    pub previous_master_key: Option<SecretPassword>,
    #[serde(default)]
    pub previous_master_key_id: Option<String>,
}

/// Supports des fichiers (`lyxal_storage`), les mêmes pour tous les hôtes d'une base : support
/// `default` sur un dossier (`disk.root`, partagé entre les hôtes), services S3 nommés
/// (`s3.<nom>`), antivirus facultatif. Sans support, aucun fichier n'est écrit ni lu (sonde
/// « dégradé »).
#[derive(Clone, Debug, Default, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct StorageConfig {
    #[serde(default)]
    pub disk: Option<DiskStorageConfig>,
    /// Supports S3 ou compatibles, par nom de support (`<préfixe>__STORAGE__S3__<NOM>__*`).
    #[serde(default)]
    pub s3: BTreeMap<String, S3StorageConfig>,
    /// Antivirus qui analyse tout fichier écrit (facultatif).
    #[serde(default)]
    pub antivirus: Option<AntivirusConfig>,
}

/// Support disque : `<préfixe>__STORAGE__DISK__ROOT`, dossier créé s'il n'existe pas ; tous les
/// fichiers sont écrits dessous.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct DiskStorageConfig {
    pub root: PathBuf,
}

/// Support S3 ou compatible (Bunny Storage, par exemple) : `<préfixe>__STORAGE__S3__<NOM>__ENDPOINT`,
/// `__REGION`, `__BUCKET`, `__ACCESS_KEY_ID`, `__SECRET_ACCESS_KEY` (variable d'environnement
/// seulement), `__PATH_STYLE` (vrai par défaut : adresses `/<bucket>/<clé>`), `__ALLOW_HTTP`
/// (faux par défaut). `<NOM>` est le nom du support, celui du champ `backend` d'un bucket.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct S3StorageConfig {
    pub endpoint: String,
    pub region: String,
    pub bucket: String,
    pub access_key_id: String,
    pub secret_access_key: SecretPassword,
    #[serde(default = "default_true")]
    pub path_style: bool,
    #[serde(default)]
    pub allow_http: bool,
}

fn default_true() -> bool {
    true
}

/// Antivirus ClamAV (service `clamd` séparé) : `address` (`hôte:port`) ou `socket` (chemin d'une
/// socket Unix), l'un des deux ; `timeout_seconds` (attente maximale du service, 1 à 300, 30 par
/// défaut). Configuré mais injoignable : les écritures sont refusées.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct AntivirusConfig {
    #[serde(default)]
    pub address: Option<String>,
    #[serde(default)]
    pub socket: Option<PathBuf>,
    #[serde(default = "default_antivirus_timeout")]
    pub timeout_seconds: u64,
}

fn default_antivirus_timeout() -> u64 {
    30
}

fn configuration_error(field: &str, error: impl std::fmt::Display) -> HostError {
    HostError::Configuration {
        message: format!("{field} : {error}"),
    }
}

/// Vrai si `name` est un nom de support valide : celui que porte le champ `backend` d'un bucket
/// (minuscules, chiffres et `_`, commence par une lettre, 64 caractères au plus).
pub fn is_backend_name(name: &str) -> bool {
    name.len() <= 64
        && name.starts_with(|c: char| c.is_ascii_lowercase())
        && name
            .chars()
            .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '_')
}

impl StorageConfig {
    /// Vrai si un support de ce nom est déclaré.
    pub fn has_backend(&self, name: &str) -> bool {
        (self.disk.is_some() && name == DEFAULT_BACKEND) || self.s3.contains_key(name)
    }

    /// Vrai si au moins un support est déclaré.
    pub fn has_any_backend(&self) -> bool {
        self.disk.is_some() || !self.s3.is_empty()
    }
}

/// Contrôle `[storage]` : noms des supports S3, support `default` déclaré deux fois, antivirus
/// (une adresse ou une socket, délai de 1 à 300 s). Le message dit quel réglage corriger.
pub fn validate_storage(config: &StorageConfig) -> Result<(), HostError> {
    let invalid = |message: String| Err(HostError::Configuration { message });
    for name in config.s3.keys() {
        if !is_backend_name(name) {
            return invalid(format!(
                "storage.s3.{name} : nom de support invalide (minuscules, chiffres et _, 64 caractères au plus)"
            ));
        }
        if config.disk.is_some() && name == DEFAULT_BACKEND {
            return invalid(format!(
                "storage.s3.{name} : le support `{DEFAULT_BACKEND}` est déjà le dossier storage.disk.root"
            ));
        }
    }
    if let Some(antivirus) = &config.antivirus {
        if antivirus.address.is_some() == antivirus.socket.is_some() {
            return invalid("storage.antivirus : address ou socket, l'un des deux".into());
        }
        if !(1..=300).contains(&antivirus.timeout_seconds) {
            return invalid(
                "storage.antivirus.timeout_seconds doit être compris entre 1 et 300".into(),
            );
        }
    }
    Ok(())
}

/// Une clé lue par `EnvironmentKeyProvider` ; une clé sans identifiant ou invalide arrête le
/// démarrage.
fn load_key(
    var: &str,
    field: &str,
    id_field: &str,
    id: Option<&str>,
) -> Result<ResolvedKey, HostError> {
    let id = id
        .ok_or_else(|| configuration_error(id_field, "obligatoire avec la clé"))
        .and_then(|id| KeyId::parse(id).map_err(|e| configuration_error(id_field, e)))?;
    EnvironmentKeyProvider::load(var, id).map_err(|e| configuration_error(field, e))
}

/// Trousseau maître du coffre-fort : clé active (`<env_prefix>__SECRETS__MASTER_KEY`) et,
/// pendant une rotation, l'ancienne en lecture seule (`<env_prefix>__SECRETS__PREVIOUS_MASTER_KEY`).
/// `None` sans clé. Une ancienne clé sans clé active, une clé sans identifiant ou une clé
/// invalide arrête le démarrage.
pub fn master_keys(
    config: &SecretsConfig,
    env_prefix: &str,
) -> Result<Option<MasterKeys>, HostError> {
    if config.master_key.is_none() {
        if config.previous_master_key.is_some() {
            return Err(configuration_error(
                "secrets.previous_master_key",
                "fournie sans clé maîtresse active (secrets.master_key)",
            ));
        }
        return Ok(None);
    }
    let active = load_key(
        &format!("{env_prefix}__SECRETS__MASTER_KEY"),
        "secrets.master_key",
        "secrets.master_key_id",
        config.master_key_id.as_deref(),
    )?;
    let previous = match &config.previous_master_key {
        None => None,
        Some(_) => Some(load_key(
            &format!("{env_prefix}__SECRETS__PREVIOUS_MASTER_KEY"),
            "secrets.previous_master_key",
            "secrets.previous_master_key_id",
            config.previous_master_key_id.as_deref(),
        )?),
    };
    MasterKeys::from_keys(active, previous)
        .map(Some)
        .map_err(|e| configuration_error("secrets.master_key", e))
}

/// Supports de l'installation : le dossier disque (`default`) et les services S3 nommés. Vide
/// si aucun n'est déclaré (l'hôte le signale). `config` doit avoir été validée
/// ([`validate_storage`]).
pub fn storage_backends(config: &StorageConfig) -> Result<Backends, HostError> {
    let mut backends = Backends::new();
    if let Some(disk) = &config.disk {
        backends = backends
            .with(
                DEFAULT_BACKEND,
                BackendConfig::Disk {
                    root: disk.root.clone(),
                },
            )
            .map_err(|error| configuration_error("storage.disk.root", error))?;
    }
    for (name, s3) in &config.s3 {
        let secret_access_key = s3.secret_access_key.to_secret().map_err(|_| {
            configuration_error(
                &format!("storage.s3.{name}.secret_access_key"),
                "valeur refusée",
            )
        })?;
        backends = backends
            .with(
                name,
                BackendConfig::S3 {
                    endpoint: s3.endpoint.clone(),
                    region: s3.region.clone(),
                    bucket: s3.bucket.clone(),
                    access_key_id: s3.access_key_id.clone(),
                    secret_access_key,
                    path_style: s3.path_style,
                    allow_http: s3.allow_http,
                },
            )
            .map_err(|error| configuration_error(&format!("storage.s3.{name}"), error))?;
    }
    Ok(backends)
}

/// Antivirus de l'installation, s'il est configuré. `config` doit avoir été validée
/// ([`validate_storage`]) : une section sans adresse ni socket ne donne aucun antivirus.
pub fn storage_scanner(config: &StorageConfig) -> Option<Arc<dyn ContentScanner>> {
    let antivirus = config.antivirus.as_ref()?;
    let address = match (&antivirus.address, &antivirus.socket) {
        (Some(address), _) => ScannerConfig::Tcp {
            address: address.clone(),
        },
        (None, Some(path)) => ScannerConfig::Socket { path: path.clone() },
        (None, None) => return None,
    };
    Some(Arc::new(ClamAvScanner::new(
        address,
        Duration::from_secs(antivirus.timeout_seconds),
    )))
}

#[cfg(test)]
#[allow(clippy::expect_used, clippy::unwrap_used)]
mod tests {
    use super::*;

    fn storage(text: &str) -> StorageConfig {
        #[derive(Deserialize)]
        struct Wrapper {
            storage: StorageConfig,
        }
        let directory = tempfile::tempdir().expect("tempdir");
        std::fs::write(directory.path().join("default.toml"), text).expect("default.toml");
        crate::config::load_layered::<Wrapper>(
            directory.path(),
            "ESSAI",
            SECRET_KEYS,
            &[],
            Some(config::Map::new()),
        )
        .expect("configuration")
        .storage
    }

    #[test]
    fn backend_names_follow_the_bucket_rule() {
        assert!(is_backend_name("default"));
        assert!(is_backend_name("bunny_2"));
        assert!(!is_backend_name("Bunny"));
        assert!(!is_backend_name("2bunny"));
        assert!(!is_backend_name("bunny-cdn"));
        assert!(!is_backend_name(&"a".repeat(65)));
    }

    #[test]
    fn storage_is_validated() {
        let valid = storage("[storage.antivirus]\naddress = \"127.0.0.1:3310\"\n");
        assert!(validate_storage(&valid).is_ok());
        assert!(storage_scanner(&valid).is_some());

        let both = storage(
            "[storage.antivirus]\naddress = \"127.0.0.1:3310\"\nsocket = \"/run/clamd.sock\"\n",
        );
        assert_eq!(
            validate_storage(&both)
                .expect_err("deux adresses")
                .to_string(),
            "configuration invalide : storage.antivirus : address ou socket, l'un des deux"
        );
        let slow =
            storage("[storage.antivirus]\naddress = \"127.0.0.1:3310\"\ntimeout_seconds = 0\n");
        assert!(validate_storage(&slow).is_err());

        let default_twice = StorageConfig {
            disk: Some(DiskStorageConfig {
                root: PathBuf::from("/srv"),
            }),
            s3: BTreeMap::from([(
                DEFAULT_BACKEND.to_string(),
                S3StorageConfig {
                    endpoint: "https://s3.test".into(),
                    region: "eu".into(),
                    bucket: "b".into(),
                    access_key_id: "id".into(),
                    secret_access_key: SecretPassword::new("secret".into()).expect("secret"),
                    path_style: true,
                    allow_http: false,
                },
            )]),
            antivirus: None,
        };
        assert!(validate_storage(&default_twice)
            .expect_err("default deux fois")
            .to_string()
            .contains("storage.s3.default"));
    }

    #[test]
    fn s3_secret_is_refused_in_files() {
        let directory = tempfile::tempdir().expect("tempdir");
        std::fs::write(
            directory.path().join("default.toml"),
            "[storage.s3.bunny]\nendpoint = \"https://s3.test\"\nregion = \"eu\"\nbucket = \"b\"\naccess_key_id = \"id\"\nsecret_access_key = \"secret\"\n",
        )
        .expect("default.toml");
        let error = crate::config::load_layered::<StorageConfig>(
            directory.path(),
            "ESSAI",
            SECRET_KEYS,
            &[],
            Some(config::Map::new()),
        )
        .expect_err("secret dans un fichier");
        assert!(error
            .to_string()
            .contains("ESSAI__STORAGE__S3__BUNNY__SECRET_ACCESS_KEY seulement"));
    }

    #[test]
    fn backends_are_built_from_the_configuration() {
        let root = tempfile::tempdir().expect("tempdir");
        let config = StorageConfig {
            disk: Some(DiskStorageConfig {
                root: root.path().join("fichiers"),
            }),
            ..StorageConfig::default()
        };
        assert!(config.has_backend("default"));
        assert!(!config.has_backend("bunny"));
        let backends = storage_backends(&config).expect("supports");
        assert!(!backends.is_empty());
        assert!(root.path().join("fichiers").is_dir());
        assert!(storage_backends(&StorageConfig::default())
            .expect("aucun support")
            .is_empty());
        assert!(storage_scanner(&StorageConfig::default()).is_none());
    }

    #[test]
    fn master_keys_need_an_identifier_and_an_active_key() {
        assert!(master_keys(&SecretsConfig::default(), "ESSAI")
            .expect("sans clé")
            .is_none());
        let previous_only = SecretsConfig {
            previous_master_key: Some(SecretPassword::new("AAAA".into()).expect("secret")),
            previous_master_key_id: Some("vault-0".into()),
            ..SecretsConfig::default()
        };
        assert!(master_keys(&previous_only, "ESSAI")
            .expect_err("clé active obligatoire")
            .to_string()
            .contains("secrets.previous_master_key"));
        let without_id = SecretsConfig {
            master_key: Some(SecretPassword::new("AAAA".into()).expect("secret")),
            ..SecretsConfig::default()
        };
        assert!(master_keys(&without_id, "ESSAI")
            .expect_err("identifiant obligatoire")
            .to_string()
            .contains("secrets.master_key_id"));
    }
}
