// SPDX-License-Identifier: AGPL-3.0-only

//! Modules hébergés par l'hôte : manifestes et fichiers SurrealQL embarqués à la compilation
//! (`build.rs`). Au lot 3 : le socle, `lyxal_event` et `lyxal_mail`, tous sans code Rust propre
//! au runtime (`ManifestModule`) ; les écoutes sont des workers rattachés à `lyxal_mail`.

use crate::error::GroupwareError;
use lyxal_host::modules::{manifest, EmbeddedModule, ManifestModule};
use lyxal_runtime::resource::EmbeddedResourceProvider;
use lyxal_runtime::{FoundationInstallation, HostId, ModulePackage, NodeId};
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

/// Manifeste de l'hôte et ses définitions d'erreurs `GROUPWARE_*`.
const GROUPWARE_MODULE: EmbeddedModule = EmbeddedModule {
    id: HOST_ID,
    manifest: include_str!("../manifest.toml"),
    files: &[(
        "error/groupware.surql",
        include_str!("../error/groupware.surql"),
    )],
};

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
            let implementation = Arc::new(ManifestModule::new(&manifest)?);
            Ok(ModulePackage::new(
                manifest,
                Arc::new(EmbeddedResourceProvider::new(module.files)),
            )
            .with_module_impl(implementation))
        })
        .collect()
}
