use std::sync::Arc;

use client::{Client, UserStore};
use collections::HashSet;
use gpui::{App, Context, Entity};
use language_model::LanguageModelRegistry;

pub mod extension;
pub mod provider;
mod settings;

pub use crate::extension::init_proxy as init_extension_proxy;

use crate::provider::lyxal::LyxalLanguageModelProvider;
pub use crate::settings::*;

pub fn init(user_store: Entity<UserStore>, client: Arc<Client>, cx: &mut App) {
    let registry = LanguageModelRegistry::global(cx);
    registry.update(cx, |registry, cx| {
        register_language_model_providers(registry, user_store, client.clone(), cx);
    });

    // Subscribe to extension store events to track LLM extension installations
    if let Some(extension_store) = extension_host::ExtensionStore::try_global(cx) {
        cx.subscribe(&extension_store, {
            let registry = registry.clone();
            move |extension_store, event, cx| match event {
                extension_host::Event::ExtensionInstalled(extension_id) => {
                    if let Some(manifest) = extension_store
                        .read(cx)
                        .extension_manifest_for_id(extension_id)
                    {
                        if !manifest.language_model_providers.is_empty() {
                            registry.update(cx, |registry, cx| {
                                registry.extension_installed(extension_id.clone(), cx);
                            });
                        }
                    }
                }
                extension_host::Event::ExtensionUninstalled(extension_id) => {
                    registry.update(cx, |registry, cx| {
                        registry.extension_uninstalled(extension_id, cx);
                    });
                }
                extension_host::Event::ExtensionsUpdated => {
                    let mut new_ids = HashSet::default();
                    for (extension_id, entry) in extension_store.read(cx).installed_extensions() {
                        if !entry.manifest.language_model_providers.is_empty() {
                            new_ids.insert(extension_id.clone());
                        }
                    }
                    registry.update(cx, |registry, cx| {
                        registry.sync_installed_llm_extensions(new_ids, cx);
                    });
                }
                _ => {}
            }
        })
        .detach();

        // Initialize with currently installed extensions
        registry.update(cx, |registry, cx| {
            let mut initial_ids = HashSet::default();
            for (extension_id, entry) in extension_store.read(cx).installed_extensions() {
                if !entry.manifest.language_model_providers.is_empty() {
                    initial_ids.insert(extension_id.clone());
                }
            }
            registry.sync_installed_llm_extensions(initial_ids, cx);
        });
    }

}


fn register_language_model_providers(
    registry: &mut LanguageModelRegistry,
    _user_store: Entity<UserStore>,
    client: Arc<Client>,
    cx: &mut Context<LanguageModelRegistry>,
) {
    registry.register_provider(
        Arc::new(LyxalLanguageModelProvider::new(client.http_client(), cx)),
        cx,
    );
}
