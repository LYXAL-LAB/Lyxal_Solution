pub mod importer;
pub mod plan;

pub use importer::{SchemaImportResult, SchemaImporter};
pub use plan::SchemaImportPlan;

use crate::error::RuntimeError;
use crate::lock::node_id::NodeId;
use crate::lock::store::{instant, LeaseKind, LeaseOutcome, LeaseRow, LeaseStore};
use crate::manifest::{ManifestParser, ModuleManifest};
use crate::presence::{HostId, PresenceStore};
use crate::resource::{
    EmbeddedResourceProvider, ModuleResource, ResourceChecksum, ResourceDiscovery, ResourceKind,
    ResourceProvider,
};
use crate::types::ModuleId;
use std::time::{Duration, Instant};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Installe les ressources déclarées dans `[resources]` d'un module (`schemas`, `functions`,
/// `error_definitions`, `events`, `seeds`), dans l'ordre du manifeste. Rejouable : chaque
/// ressource doit être idempotente (`OVERWRITE`, seeds protégés par `record::exists`).
pub async fn install_resources(
    client: &Surreal<Any>,
    manifest: &ModuleManifest,
    provider: &dyn ResourceProvider,
) -> Result<SchemaImportResult, RuntimeError> {
    let plan = SchemaImportPlan::from_manifest(manifest, provider).await?;
    SchemaImporter::new(client.clone())
        .execute_plan(&plan)
        .await
}

/// Installe un module à partir de son manifeste et de ses fichiers embarqués dans le binaire
/// (par exemple `lyxal_event::MANIFEST` et `lyxal_event::EMBEDDED_RESOURCES`).
pub async fn install_embedded(
    client: &Surreal<Any>,
    manifest: &str,
    files: &'static [(&'static str, &'static str)],
) -> Result<SchemaImportResult, RuntimeError> {
    let manifest = ManifestParser::parse_str(manifest)?;
    install_resources(client, &manifest, &EmbeddedResourceProvider::new(files)).await
}

/// Installe plusieurs modules phase par phase : les `schemas` de tous les modules, puis leurs
/// `functions`, leurs `error_definitions`, leurs `events` et leurs `seeds`. Dans chaque phase,
/// les modules suivent l'ordre donné (ordre des dépendances).
///
/// Nécessaire pour installer `lyxal_core` avec `lyxal_error` : les définitions d'erreurs de
/// `lyxal_core` vont dans la table `error_definition` de `lyxal_error`, qui dépend elle-même de
/// `lyxal_core`.
pub async fn install_batch(
    client: &Surreal<Any>,
    modules: &[(&ModuleManifest, &dyn ResourceProvider)],
) -> Result<Vec<SchemaImportResult>, RuntimeError> {
    let plans = batch_resources(modules).await?;
    install_batch_resources(client, &plans).await
}

/// Ressources à installer de chaque module d'un lot, dans l'ordre donné.
async fn batch_resources(
    modules: &[(&ModuleManifest, &dyn ResourceProvider)],
) -> Result<Vec<(ModuleId, Vec<ModuleResource>)>, RuntimeError> {
    let mut plans = Vec::new();
    for (manifest, provider) in modules {
        let resources = ResourceDiscovery::install_resources(manifest, *provider).await?;
        plans.push((manifest.id.clone(), resources));
    }
    Ok(plans)
}

async fn install_batch_resources(
    client: &Surreal<Any>,
    plans: &[(ModuleId, Vec<ModuleResource>)],
) -> Result<Vec<SchemaImportResult>, RuntimeError> {
    let importer = SchemaImporter::new(client.clone());
    let mut results = Vec::new();
    for kind in [
        ResourceKind::Schema,
        ResourceKind::Function,
        ResourceKind::ErrorDefinition,
        ResourceKind::Event,
        ResourceKind::Seed,
    ] {
        for (module_id, resources) in plans {
            let phase: Vec<_> = resources
                .iter()
                .filter(|r| r.kind == kind)
                .cloned()
                .collect();
            if phase.is_empty() {
                continue;
            }
            let plan = SchemaImportPlan::new(module_id.clone(), phase);
            results.push(importer.execute_plan(&plan).await?);
        }
    }
    Ok(results)
}

/// Manifeste du runtime lui-même.
pub const RUNTIME_MANIFEST: &str = include_str!("../../manifest.toml");

/// Fichiers SurrealQL déclarés dans `[resources]` du runtime, embarqués dans le binaire. Un test
/// vérifie que la liste et les contenus sont ceux du manifeste et du disque.
pub const RUNTIME_EMBEDDED_RESOURCES: &[(&str, &str)] = &[
    (
        "schema/tables.surql",
        include_str!("../../schema/tables.surql"),
    ),
    (
        "schema/fields.surql",
        include_str!("../../schema/fields.surql"),
    ),
    (
        "schema/indexes.surql",
        include_str!("../../schema/indexes.surql"),
    ),
    (
        "functions/runtime_module.surql",
        include_str!("../../functions/runtime_module.surql"),
    ),
    (
        "functions/runtime_release.surql",
        include_str!("../../functions/runtime_release.surql"),
    ),
    (
        "functions/runtime_migration.surql",
        include_str!("../../functions/runtime_migration.surql"),
    ),
    (
        "functions/runtime_health.surql",
        include_str!("../../functions/runtime_health.surql"),
    ),
    (
        "functions/runtime_worker.surql",
        include_str!("../../functions/runtime_worker.surql"),
    ),
    (
        "functions/runtime_event_journal.surql",
        include_str!("../../functions/runtime_event_journal.surql"),
    ),
    (
        "functions/runtime_lease.surql",
        include_str!("../../functions/runtime_lease.surql"),
    ),
    (
        "functions/runtime_node.surql",
        include_str!("../../functions/runtime_node.surql"),
    ),
    (
        "functions/runtime_foundation.surql",
        include_str!("../../functions/runtime_foundation.surql"),
    ),
    (
        "error/runtime.surql",
        include_str!("../../error/runtime.surql"),
    ),
];

/// Installe les ressources du runtime (tables `runtime_*`, fonctions `fn::runtime_*`, définitions
/// d'erreurs) depuis son manifeste. Rejouable. `lyxal_core` et `lyxal_error` doivent être installés
/// avant (dépendances du manifeste). Les stores SurrealDB l'appellent dans leur `bootstrap`.
pub async fn install_runtime_schema(client: &Surreal<Any>) -> Result<(), RuntimeError> {
    install_embedded(client, RUNTIME_MANIFEST, RUNTIME_EMBEDDED_RESOURCES)
        .await
        .map(|_| ())
}

/// Clé réservée du bail d'installation du socle (`runtime_lease`, nature `installation`). Les
/// clés des releases ont la forme `module:version` : aucune ne peut valoir `foundation`.
pub const FOUNDATION_LEASE_KEY: &str = "foundation";

/// Durée du bail d'installation du socle.
const FOUNDATION_LEASE_TTL: Duration = Duration::from_secs(120);
/// Attente maximale du bail d'installation du socle détenu par un autre nœud.
const FOUNDATION_LEASE_TIMEOUT: Duration = Duration::from_secs(150);
const FOUNDATION_LEASE_RETRY: Duration = Duration::from_millis(100);

/// Issue de l'installation du socle par un nœud.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FoundationInstallation {
    /// Empreinte du socle embarqué par ce binaire (modules fournis et schéma du runtime).
    pub checksum: String,
    /// Vrai si ce nœud a installé le socle ; faux si la base portait déjà cette empreinte.
    pub installed: bool,
}

/// Installe le socle : les modules fournis (`lyxal_core` puis `lyxal_error`, phase par phase
/// comme `install_batch`), puis le schéma du runtime. `modules` ne contient que ce qui est
/// commun à tous les hôtes : les définitions d'erreurs propres à un hôte s'installent à part.
///
/// L'installation se fait sous le bail d'installation de clé réservée `foundation` : deux nœuds
/// qui démarrent ensemble n'installent pas en même temps. L'empreinte du socle (SHA-256 des
/// fichiers, chemin et contenu, dans l'ordre d'installation) est écrite dans
/// `runtime_foundation:current` avec l'hôte et le nœud. Une base qui porte déjà cette empreinte
/// n'est pas réinstallée ; une base qui en porte une autre l'est, et les nœuds de l'autre
/// binaire le voient à leur battement (`FoundationHealthCheck`).
///
/// Sur une base vierge, les fonctions de bail font elles-mêmes partie du socle : il est alors
/// installé une première fois sans bail, puis enregistré sous bail.
pub async fn install_foundation(
    client: &Surreal<Any>,
    host: &HostId,
    node: &NodeId,
    modules: &[(&ModuleManifest, &dyn ResourceProvider)],
) -> Result<FoundationInstallation, RuntimeError> {
    let plans = batch_resources(modules).await?;
    let runtime_manifest = ManifestParser::parse_str(RUNTIME_MANIFEST)?;
    let runtime_plan = SchemaImportPlan::from_manifest(
        &runtime_manifest,
        &EmbeddedResourceProvider::new(RUNTIME_EMBEDDED_RESOURCES),
    )
    .await?;

    let mut checksum = ResourceChecksum::new();
    for (module_id, resources) in &plans {
        checksum.scope(module_id.as_str());
        for resource in resources {
            checksum.resource(resource);
        }
    }
    checksum.scope(runtime_manifest.id.as_str());
    for resource in runtime_plan.resources() {
        checksum.resource(resource);
    }
    let checksum = checksum.finalize();

    let install = || async {
        install_batch_resources(client, &plans).await?;
        SchemaImporter::new(client.clone())
            .execute_plan(&runtime_plan)
            .await
            .map(|_| ())
    };

    let bootstrapped = !foundation_functions_installed(client).await?;
    if bootstrapped {
        install().await?;
    }

    let leases = LeaseStore::new(client.clone());
    let lease = acquire_foundation_lease(&leases, node, &checksum).await?;
    let generation = instant(lease.generation);
    let presence = PresenceStore::new(client.clone());
    let outcome = async {
        let (reinstall, record) = match presence.foundation().await? {
            Some(current) if current.checksum == checksum => (false, false),
            // Un autre binaire a installé son socle : celui de ce binaire le remplace
            Some(_) => (true, true),
            // Base vierge installée à l'instant par ce nœud : rien à réinstaller
            None => (!bootstrapped, true),
        };
        if reinstall {
            install().await?;
        }
        if record {
            presence
                .record_foundation(&checksum, host, node, generation)
                .await?;
        }
        Ok::<bool, RuntimeError>(bootstrapped || reinstall)
    }
    .await;

    if let Err(error) = leases
        .release(
            LeaseKind::Installation,
            FOUNDATION_LEASE_KEY,
            node,
            generation,
        )
        .await
    {
        tracing::warn!(error = %error, "Libération du bail du socle impossible : il expirera à son échéance");
    }
    Ok(FoundationInstallation {
        checksum,
        installed: outcome?,
    })
}

/// Vrai si la base porte déjà les fonctions de bail et d'enregistrement du socle.
async fn foundation_functions_installed(client: &Surreal<Any>) -> Result<bool, RuntimeError> {
    let failure = |message: String| RuntimeError::StoreFailed {
        operation: "runtime_foundation_probe",
        message,
    };
    let mut response = client
        .query(
            "LET $functions = (INFO FOR DB).functions; \
             RETURN $functions.runtime_lease_acquire != NONE \
                AND $functions.runtime_lease_release != NONE \
                AND $functions.runtime_foundation_get != NONE \
                AND $functions.runtime_foundation_record != NONE;",
        )
        .await
        .map_err(|e| failure(e.to_string()))?;
    let installed: Option<bool> = response.take(1).map_err(|e| failure(e.to_string()))?;
    installed.ok_or_else(|| failure("réponse vide".to_string()))
}

/// Prend le bail d'installation du socle, en attendant celui d'un autre nœud.
async fn acquire_foundation_lease(
    leases: &LeaseStore,
    node: &NodeId,
    checksum: &str,
) -> Result<LeaseRow, RuntimeError> {
    let started = Instant::now();
    loop {
        let outcome = leases
            .acquire(
                LeaseKind::Installation,
                FOUNDATION_LEASE_KEY,
                node,
                FOUNDATION_LEASE_TTL,
            )
            .await
            .map_err(|e| RuntimeError::InstallationLeaseAcquireFailed {
                module: ModuleId::new(FOUNDATION_LEASE_KEY),
                version: checksum.to_string(),
                message: e.to_string(),
            })?;
        match outcome {
            LeaseOutcome::Acquired(lease)
            | LeaseOutcome::Recovered(lease)
            | LeaseOutcome::AlreadyOwned(lease) => return Ok(lease),
            LeaseOutcome::HeldByOther(_) => {
                if started.elapsed() >= FOUNDATION_LEASE_TIMEOUT {
                    return Err(RuntimeError::InstallationLeaseTimeout {
                        module: ModuleId::new(FOUNDATION_LEASE_KEY),
                        version: checksum.to_string(),
                    });
                }
                tokio::time::sleep(FOUNDATION_LEASE_RETRY).await;
            }
        }
    }
}
