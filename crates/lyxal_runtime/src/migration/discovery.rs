use crate::error::RuntimeError;
use crate::migration::definition::{validate_migration_definitions, MigrationDefinition};
use crate::migration::id::MigrationId;
use crate::resource::discovery::ResourceDiscovery;
use crate::resource::provider::ResourceProvider;
use crate::types::ModuleId;
use semver::Version;

/// Moteur de découverte et de parsing des définitions de migrations.
pub struct MigrationDiscovery;

impl MigrationDiscovery {
    /// Parse un nom de fichier de migration selon la convention canonique `NNN_description.surql`.
    ///
    /// Exemples valides :
    /// - `001_initial_schema.surql` -> order: 1, id: `001_initial_schema`
    /// - `002_add_indexes.surql` -> order: 2, id: `002_add_indexes`
    /// - `010_update_cron.surql` -> order: 10, id: `010_update_cron`
    pub fn parse_migration_filename(filename: &str) -> Result<(u64, MigrationId), RuntimeError> {
        let name = filename.trim();
        if !name.ends_with(".surql") {
            return Err(RuntimeError::InvalidMigrationId {
                id: name.to_string(),
                reason: "Migration file must have '.surql' extension".to_string(),
            });
        }

        let base_name = &name[..name.len() - 6]; // enlève '.surql'

        let parts: Vec<&str> = base_name.splitn(2, '_').collect();
        if parts.len() < 2 || parts[0].is_empty() || parts[1].is_empty() {
            return Err(RuntimeError::InvalidMigrationId {
                id: base_name.to_string(),
                reason: "Migration filename must match 'NNN_description.surql' format".to_string(),
            });
        }

        let order = parts[0]
            .parse::<u64>()
            .map_err(|_| RuntimeError::InvalidMigrationId {
                id: base_name.to_string(),
                reason: format!(
                    "Migration order prefix '{}' is not a valid unsigned integer",
                    parts[0]
                ),
            })?;

        let migration_id = MigrationId::new(base_name)?;

        Ok((order, migration_id))
    }

    /// Découvre l'ensemble des migrations d'un module, calcule leurs checksums,
    /// valide l'absence de doublons (ordre et ID) et les trie par `order` croissant.
    pub async fn discover_migrations(
        module_id: &ModuleId,
        module_version: &str,
        provider: &dyn ResourceProvider,
    ) -> Result<Vec<MigrationDefinition>, RuntimeError> {
        let parsed_version =
            Version::parse(module_version).map_err(|err| RuntimeError::InvalidModuleVersion {
                version: module_version.to_string(),
                message: err.to_string(),
            })?;

        let resources = ResourceDiscovery::discover_migration_resources(provider).await?;
        let mut definitions = Vec::new();

        for res in resources {
            let filename = res
                .logical_path
                .rsplit('/')
                .next()
                .unwrap_or(&res.logical_path);

            let (order, migration_id) = Self::parse_migration_filename(filename)?;
            let checksum = res.checksum();

            let def = MigrationDefinition::new(
                migration_id,
                module_id.clone(),
                parsed_version.clone(),
                checksum,
                order,
            )
            .with_resource_path(res.logical_path);

            definitions.push(def);
        }

        // Validation stricte anti-doublons (ordre et ID)
        validate_migration_definitions(&definitions)?;

        // Tri canonique par order
        definitions.sort();

        Ok(definitions)
    }
}
