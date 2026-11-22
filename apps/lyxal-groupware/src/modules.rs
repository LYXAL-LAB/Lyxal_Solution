// SPDX-License-Identifier: AGPL-3.0-only

//! Modules hébergés par l'hôte : manifestes et fichiers SurrealQL embarqués à la compilation
//! (`build.rs`) : le socle, `lyxal_event`, `lyxal_auth`, `lyxal_secrets`, `lyxal_storage`,
//! `lyxal_scheduler` et `lyxal_mail`. Les modules qui ont une implémentation `LyxalModule`
//! (`lyxal_secrets`, `lyxal_storage`, `lyxal_scheduler`, `lyxal_mail`) sont portés par elle, les
//! autres par un `ManifestModule` (leurs hooks `install` n'écrivent rien) ; leurs services sont
//! enregistrés par `services`. Les écoutes sont des workers rattachés à `lyxal_mail`.

use crate::error::GroupwareError;
use lyxal_host::modules::{manifest, EmbeddedModule, ManifestModule};
use lyxal_runtime::resource::EmbeddedResourceProvider;
use lyxal_runtime::{FoundationInstallation, HostId, LyxalModule, ModulePackage, NodeId};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

include!(concat!(env!("OUT_DIR"), "/embedded_modules.rs"));

/// Nom de l'hôte : le rôle de ce binaire, le même pour toutes ses copies, égal à l'`id` de son
/// manifeste. Constante du code, non réglable par configuration.
pub const HOST_ID: &str = "lyxal_groupware";

/// Hôte de ce binaire pour le runtime.
pub fn host_id() -> Result<HostId, GroupwareError> {
    Ok(HostId::new(HOST_ID)?)
}

/// Manifeste de l'hôte, ses définitions d'erreurs `GROUPWARE_*` et son seed (tâche de fond
/// confiée à `lyxal_scheduler`).
const GROUPWARE_MODULE: EmbeddedModule = EmbeddedModule {
    id: HOST_ID,
    manifest: include_str!("../manifest.toml"),
    files: &[
        (
            "error/groupware.surql",
            include_str!("../error/groupware.surql"),
        ),
        (
            "seeds/groupware_tasks.surql",
            include_str!("../seeds/groupware_tasks.surql"),
        ),
    ],
};

/// Installe les seeds de l'hôte (tâche de maintenance du courrier et sa permission), après
/// l'installation des modules hébergés. Rejouable.
pub async fn install_host_seeds(client: &Surreal<Any>) -> Result<(), GroupwareError> {
    Ok(lyxal_host::modules::install_host_seeds(client, &GROUPWARE_MODULE).await?)
}

/// Installe le socle (`lyxal_core`, `lyxal_error`, schéma du runtime) sous le bail d'installation
/// du socle, au nom du nœud `node`, puis les définitions d'erreurs `GROUPWARE_*`. Rejouable.
/// Le socle est le même que celui de `lyxal-server` quand les deux binaires viennent du même
/// commit (même empreinte).
pub async fn install_foundation(
    client: &Surreal<Any>,
    node: &NodeId,
) -> Result<FoundationInstallation, GroupwareError> {
    Ok(lyxal_host::modules::install_foundation(
        client,
        &host_id()?,
        node,
        EMBEDDED_MODULES,
        &GROUPWARE_MODULE,
    )
    .await?)
}

/// Packages de tous les modules hébergés.
pub fn packages() -> Result<Vec<ModulePackage>, GroupwareError> {
    EMBEDDED_MODULES
        .iter()
        .map(|module| {
            let manifest = manifest(module)?;
            let implementation: Arc<dyn LyxalModule> = match module.id {
                lyxal_secrets::MODULE_ID => Arc::new(lyxal_secrets::SecretsModule::new()),
                lyxal_storage::MODULE_ID => Arc::new(lyxal_storage::StorageModule::new()),
                lyxal_scheduler::MODULE_ID => Arc::new(lyxal_scheduler::SchedulerModule::new()),
                lyxal_mail::MODULE_ID => Arc::new(lyxal_mail::MailModule::new()),
                _ => Arc::new(ManifestModule::new(&manifest)?),
            };
            Ok(ModulePackage::new(
                manifest,
                Arc::new(EmbeddedResourceProvider::new(module.files)),
            )
            .with_module_impl(implementation))
        })
        .collect()
}
