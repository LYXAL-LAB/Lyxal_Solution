//! Module `lyxal_i18n` pour `lyxal_runtime` et sonde de santé.

use async_trait::async_trait;
use lyxal_runtime::descriptor::{ModuleDescriptor, ModuleDescriptorBuilder};
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{LyxalModule, ModuleContext, RuntimeError};
use std::time::Instant;

use crate::format::{DateStyle, Formatter, Length, ICU_CLDR_VERSION};
use crate::models::LocaleGetParams;
use crate::store::I18nStore;
use crate::MODULE_ID;

/// Module `lyxal_i18n` : ses ressources SurrealQL sont installées par le runtime depuis le
/// manifeste ; la sonde est enregistrée par l'hôte.
pub struct I18nModule {
    descriptor: ModuleDescriptor,
}

impl Default for I18nModule {
    fn default() -> Self {
        Self::new()
    }
}

impl I18nModule {
    /// Descripteur conforme au manifeste.
    pub fn new() -> Self {
        let descriptor = ModuleDescriptorBuilder::new(ModuleId::new(MODULE_ID), "0.1.0")
            .name("Lyxal I18n")
            .description(
                "Langues, traductions et formats régionaux : référentiel CLDR, choix de la langue, clés, traductions et rendu",
            )
            .capability("database")
            .capability("events")
            .capability("i18n")
            .dependency(ModuleId::new("lyxal_core"))
            .dependency(ModuleId::new("lyxal_error"))
            .dependency(ModuleId::new("lyxal_event"))
            .dependency(ModuleId::new("lyxal_auth"))
            .build();
        Self { descriptor }
    }
}

#[async_trait]
impl LyxalModule for I18nModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}

/// Origine de la base des fuseaux horaires : base du système si elle contient des fuseaux,
/// copie embarquée dans le binaire sinon.
pub fn timezone_database_origin() -> &'static str {
    let system = ["/usr/share/zoneinfo", "/usr/lib/zoneinfo", "/etc/zoneinfo"];
    let from_env = std::env::var_os("TZDIR").map(std::path::PathBuf::from);
    let found = from_env
        .into_iter()
        .chain(system.iter().map(std::path::PathBuf::from))
        .any(|dir| dir.join("Europe").join("Paris").is_file());
    if found {
        "système"
    } else {
        "copie embarquée"
    }
}

/// Sonde de santé : réglages lisibles, langue par défaut active et rendue, base des fuseaux
/// horaires utilisable. Le message donne la version CLDR du référentiel et l'origine des fuseaux.
pub struct I18nHealthCheck {
    module_id: ModuleId,
    store: I18nStore,
}

impl I18nHealthCheck {
    /// Sonde sur le store de la session système de l'hôte.
    pub fn new(store: I18nStore) -> Self {
        Self {
            module_id: ModuleId::new(MODULE_ID),
            store,
        }
    }

    async fn inspect(&self) -> Result<String, String> {
        let settings = self
            .store
            .settings_get()
            .await
            .map_err(|error| format!("réglages illisibles : {error}"))?;
        let default = self
            .store
            .locale_get(LocaleGetParams {
                locale: settings.default_locale.clone(),
            })
            .await
            .map_err(|error| format!("langue par défaut illisible : {error}"))?;
        if !default.active {
            return Err(format!("langue par défaut inactive : {}", default.tag));
        }
        let formatter = Formatter::new(&default.tag).map_err(|error| error.to_string())?;
        let instant = "2026-01-01T12:00:00Z"
            .parse()
            .map_err(|_| "instant de contrôle illisible".to_string())?;
        formatter
            .format_date(instant, "Europe/Paris", DateStyle::DateTime(Length::Short))
            .map_err(|error| error.to_string())?;
        Ok(format!(
            "langue par défaut {} ; référentiel CLDR {} (rendu : données CLDR d'ICU4X {}) ; fuseaux horaires : {}",
            default.tag,
            default.cldr_version,
            ICU_CLDR_VERSION,
            timezone_database_origin()
        ))
    }
}

#[async_trait]
impl ModuleHealthCheck for I18nHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        let started = Instant::now();
        let outcome = self.inspect().await;
        let elapsed = u64::try_from(started.elapsed().as_millis()).unwrap_or(u64::MAX);
        Ok(match outcome {
            Ok(message) => {
                HealthCheckResult::healthy(self.module_id.clone(), elapsed, Some(message))
            }
            Err(message) => {
                HealthCheckResult::unhealthy(self.module_id.clone(), Some(elapsed), Some(message))
            }
        })
    }
}
