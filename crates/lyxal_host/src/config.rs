//! Sections de configuration communes aux hôtes et chargement en couches : fichiers
//! `<dossier>/default.toml` puis `<dossier>/<LYXAL_ENV>.toml`, puis variables d'environnement
//! `<préfixe>__*`. Les secrets ne se lisent que dans l'environnement.

use crate::HostError;
use lyxal_surreal::SecretString;
use serde::de::DeserializeOwned;
use serde::{Deserialize, Deserializer};
use std::{fmt, num::NonZeroUsize, path::Path, sync::Arc};

/// Connexions ouvertes au plus, par défaut, par la session système d'un hôte.
const DEFAULT_CONNECTIONS_CEILING: NonZeroUsize = match NonZeroUsize::new(16) {
    Some(ceiling) => ceiling,
    None => NonZeroUsize::MIN,
};

/// Base SurrealDB de l'hôte. Identifiants Root : jamais dans les fichiers de configuration,
/// uniquement par les variables `<préfixe>__DATABASE__USERNAME` et `<préfixe>__DATABASE__PASSWORD`.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct DatabaseConfig {
    pub endpoint: String,
    pub namespace: String,
    pub database: String,
    pub username: Option<String>,
    pub password: Option<SecretPassword>,
    pub connect_timeout_seconds: u64,
    /// Connexions de la session système de l'hôte (`lyxal_surreal::SurrealPool`), 1 au moins :
    /// la valeur 0 est refusée à la lecture. Absente : le nombre de cœurs de la machine, 16 au
    /// plus. Sans effet sur une base embarquée (`mem://`), qui n'a qu'un client.
    #[serde(default = "default_connections")]
    pub connections: NonZeroUsize,
}

/// Connexions par défaut : le nombre de cœurs offerts au processus, 16 au plus ; 1 si ce nombre
/// est inconnu.
pub fn default_connections() -> NonZeroUsize {
    std::thread::available_parallelism().map_or(NonZeroUsize::MIN, |cores| {
        cores.min(DEFAULT_CONNECTIONS_CEILING)
    })
}

/// Secret lu dans la configuration (mot de passe de la base, clé de signature) : masqué dans
/// `Debug`, effacé de la mémoire à la libération (`lyxal_crypto::SecretString`).
#[derive(Clone)]
pub struct SecretPassword(Arc<SecretString>);

impl SecretPassword {
    pub fn new(text: String) -> Result<Self, HostError> {
        SecretString::new(text)
            .map(|secret| Self(Arc::new(secret)))
            .map_err(|error| HostError::Configuration {
                message: format!("database.password : {error}"),
            })
    }

    /// Copie protégée du secret, pour une utilisation unique.
    pub fn to_secret(&self) -> Result<SecretString, HostError> {
        SecretString::new(self.0.expose_secret().to_owned()).map_err(|error| {
            HostError::Configuration {
                message: format!("database.password : {error}"),
            }
        })
    }
}

impl fmt::Debug for SecretPassword {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("[REDACTED]")
    }
}

impl<'de> Deserialize<'de> for SecretPassword {
    fn deserialize<D: Deserializer<'de>>(deserializer: D) -> Result<Self, D::Error> {
        let text = String::deserialize(deserializer)?;
        SecretString::new(text)
            .map(|secret| Self(Arc::new(secret)))
            .map_err(serde::de::Error::custom)
    }
}

/// Délais du runtime (section `runtime`) : installation, démarrage et arrêt d'un module.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct RuntimeTimeouts {
    pub module_install_timeout_seconds: u64,
    pub module_start_timeout_seconds: u64,
    pub module_stop_timeout_seconds: u64,
}

/// Journal (section `observability`).
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ObservabilityConfig {
    pub log_filter: String,
    pub json_logs: bool,
    pub include_target: bool,
    pub include_thread_ids: bool,
}

/// Charge la configuration de type `T` : `<directory>/default.toml` (obligatoire), puis
/// `<directory>/<LYXAL_ENV>.toml` (facultatif, `development` par défaut), puis les variables
/// d'environnement `<env_prefix>__<SECTION>__<CLÉ>`.
///
/// `secret_keys` : clés refusées dans les fichiers (lues dans l'environnement seulement), en
/// chemin pointé (`secrets.master_key`) ; un segment `*` désigne toute entrée d'une table
/// (`storage.s3.*.secret_access_key`). Présente dans un fichier, une telle clé arrête le
/// chargement, avec le nom de la variable à utiliser.
///
/// `list_keys` : clés lues comme listes dans l'environnement (valeurs séparées par `,`) ; les
/// autres restent des chaînes.
///
/// `variables` remplace les variables d'environnement du processus (tests).
pub fn load_layered<T: DeserializeOwned>(
    directory: &Path,
    env_prefix: &str,
    secret_keys: &[&str],
    list_keys: &[&str],
    variables: Option<config::Map<String, String>>,
) -> Result<T, HostError> {
    let environment = std::env::var("LYXAL_ENV").unwrap_or_else(|_| "development".into());

    let files = config::Config::builder()
        .add_source(config::File::from(directory.join("default.toml")).required(true))
        .add_source(
            config::File::from(directory.join(format!("{environment}.toml"))).required(false),
        );
    if !secret_keys.is_empty() {
        let built = files
            .clone()
            .build()
            .map_err(|error| HostError::Configuration {
                message: error.to_string(),
            })?;
        for key in secret_keys {
            refuse_secret_in_files(&built, key, env_prefix)?;
        }
    }

    let mut environment_source = config::Environment::with_prefix(env_prefix)
        .source(variables)
        .prefix_separator("__")
        .separator("__")
        .try_parsing(true);
    // Sans clé de liste déclarée, `config` découperait toute valeur en liste : le séparateur
    // n'est posé que pour les clés de `list_keys`, les autres valeurs restent des chaînes.
    if !list_keys.is_empty() {
        environment_source = environment_source.list_separator(",");
    }
    for key in list_keys {
        environment_source = environment_source.with_list_parse_key(key);
    }

    files
        .add_source(environment_source)
        .build()
        .and_then(config::Config::try_deserialize)
        .map_err(|error| HostError::Configuration {
            message: error.to_string(),
        })
}

/// Refuse la clé `pattern` (chemin pointé, un segment `*` au plus avant la dernière clé) si elle
/// figure dans les fichiers de configuration.
fn refuse_secret_in_files(
    files: &config::Config,
    pattern: &str,
    env_prefix: &str,
) -> Result<(), HostError> {
    let (parent, leaf) = pattern.rsplit_once('.').unwrap_or(("", pattern));
    let found = match parent.strip_suffix(".*") {
        // Toute entrée d'une table : `storage.s3.*.secret_access_key`
        Some(table) => {
            let Ok(entries) = files.get_table(table) else {
                return Ok(());
            };
            entries.into_iter().find_map(|(name, entry)| {
                entry
                    .into_table()
                    .is_ok_and(|fields| fields.contains_key(leaf))
                    .then(|| format!("{table}.{name}.{leaf}"))
            })
        }
        None => {
            let Ok(table) = files.get_table(parent) else {
                return Ok(());
            };
            table.contains_key(leaf).then(|| pattern.to_string())
        }
    };
    match found {
        Some(path) => Err(HostError::Configuration {
            message: format!(
                "{path} ne doit pas figurer dans un fichier : {env_prefix}__{} seulement",
                path.replace('.', "__").to_uppercase()
            ),
        }),
        None => Ok(()),
    }
}

#[cfg(test)]
#[allow(clippy::expect_used, clippy::unwrap_used)]
mod tests {
    use super::*;

    #[derive(Debug, Deserialize)]
    struct Sample {
        section: Section,
    }

    #[derive(Debug, Deserialize)]
    struct Section {
        name: String,
        #[serde(default)]
        items: Vec<String>,
    }

    fn config_directory(default: &str) -> tempfile::TempDir {
        let directory = tempfile::tempdir().expect("tempdir");
        std::fs::write(directory.path().join("default.toml"), default).expect("default.toml");
        directory
    }

    fn variables(list: &[(&str, &str)]) -> Option<config::Map<String, String>> {
        Some(
            list.iter()
                .map(|(k, v)| ((*k).to_string(), (*v).to_string()))
                .collect(),
        )
    }

    #[test]
    fn environment_overrides_files_and_lists_are_split() {
        let directory = config_directory("[section]\nname = \"fichier\"\n");
        let sample: Sample = load_layered(
            directory.path(),
            "ESSAI",
            &[],
            &["section.items"],
            variables(&[
                ("ESSAI__SECTION__NAME", "environnement"),
                ("ESSAI__SECTION__ITEMS", "a,b"),
            ]),
        )
        .expect("configuration");
        assert_eq!(sample.section.name, "environnement");
        assert_eq!(sample.section.items, ["a", "b"]);
    }

    #[test]
    fn without_list_keys_environment_values_stay_strings() {
        let directory = config_directory("[section]\nname = \"fichier\"\n");
        let sample: Sample = load_layered(
            directory.path(),
            "ESSAI",
            &[],
            &[],
            variables(&[("ESSAI__SECTION__NAME", "environnement")]),
        )
        .expect("configuration");
        assert_eq!(sample.section.name, "environnement");
    }

    #[test]
    fn secrets_in_files_are_refused_with_the_variable_to_use() {
        let directory =
            config_directory("[section]\nname = \"x\"\n\n[vault]\nmaster_key = \"secret\"\n");
        let error = load_layered::<Sample>(
            directory.path(),
            "ESSAI",
            &["vault.master_key"],
            &[],
            variables(&[]),
        )
        .expect_err("clé dans un fichier");
        assert_eq!(
            error.to_string(),
            "configuration invalide : vault.master_key ne doit pas figurer dans un fichier : \
             ESSAI__VAULT__MASTER_KEY seulement"
        );

        let directory = config_directory(
            "[section]\nname = \"x\"\n\n[store.s3.archive]\nsecret_key = \"secret\"\n",
        );
        let error = load_layered::<Sample>(
            directory.path(),
            "ESSAI",
            &["store.s3.*.secret_key"],
            &[],
            variables(&[]),
        )
        .expect_err("clé d'une entrée dans un fichier");
        assert_eq!(
            error.to_string(),
            "configuration invalide : store.s3.archive.secret_key ne doit pas figurer dans un \
             fichier : ESSAI__STORE__S3__ARCHIVE__SECRET_KEY seulement"
        );
    }

    #[derive(Debug, Deserialize)]
    struct WithDatabase {
        database: DatabaseConfig,
    }

    const DATABASE: &str = "[database]\nendpoint = \"mem://\"\nnamespace = \"n\"\n\
                            database = \"d\"\nconnect_timeout_seconds = 5\n";

    fn database(file: &str, environment: &[(&str, &str)]) -> Result<DatabaseConfig, HostError> {
        let directory = config_directory(file);
        load_layered::<WithDatabase>(directory.path(), "ESSAI", &[], &[], variables(environment))
            .map(|loaded| loaded.database)
    }

    #[test]
    fn database_connections_default_to_the_cores_sixteen_at_most() {
        let connections = database(DATABASE, &[]).expect("configuration").connections;
        assert_eq!(connections, default_connections());
        assert!((1..=16).contains(&connections.get()), "{connections}");
        if let Ok(cores) = std::thread::available_parallelism() {
            assert_eq!(connections.get(), cores.get().min(16));
        }
    }

    #[test]
    fn database_connections_are_read_from_file_and_environment() {
        let file = format!("{DATABASE}connections = 3\n");
        assert_eq!(database(&file, &[]).expect("fichier").connections.get(), 3);
        assert_eq!(
            database(&file, &[("ESSAI__DATABASE__CONNECTIONS", "8")])
                .expect("environnement")
                .connections
                .get(),
            8
        );
    }

    #[test]
    fn zero_database_connections_are_refused() {
        let file = format!("{DATABASE}connections = 0\n");
        for refused in [
            database(&file, &[]),
            database(DATABASE, &[("ESSAI__DATABASE__CONNECTIONS", "0")]),
            database(DATABASE, &[("ESSAI__DATABASE__CONNECTIONS", "-2")]),
        ] {
            let error = refused.expect_err("0 connexion refusée");
            assert!(matches!(error, HostError::Configuration { .. }), "{error}");
        }
    }

    #[test]
    fn missing_default_file_is_refused() {
        let directory = tempfile::tempdir().expect("tempdir");
        assert!(matches!(
            load_layered::<Sample>(directory.path(), "ESSAI", &[], &[], variables(&[])),
            Err(HostError::Configuration { .. })
        ));
    }

    #[test]
    fn secret_password_is_redacted() {
        let password = SecretPassword::new("motdepasse".into()).expect("secret");
        assert_eq!(format!("{password:?}"), "[REDACTED]");
        assert_eq!(
            password.to_secret().expect("copie").expose_secret(),
            "motdepasse"
        );
    }
}
