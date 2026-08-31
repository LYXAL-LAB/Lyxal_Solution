use crate::{
    database::Database,
    error::ServerError,
    health::HealthRegistry,
    metrics::Metrics,
};
use async_trait::async_trait;
use axum::Router;
use serde::Serialize;
use std::{fmt, str::FromStr, sync::Arc};

#[derive(Clone, Debug, Eq, Hash, Ord, PartialEq, PartialOrd, Serialize)]
pub struct ModuleId(String);

impl ModuleId {
    pub fn new(value: impl Into<String>) -> Result<Self, ServerError> {
        let value = value.into();
        let valid = !value.is_empty()
            && value
                .chars()
                .all(|character| character.is_ascii_lowercase()
                    || character.is_ascii_digit()
                    || character == '-');
        if !valid {
            return Err(ServerError::Runtime(format!(
                "identifiant de module invalide : {value}"
            )));
        }
        Ok(Self(value))
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl fmt::Display for ModuleId {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter.write_str(&self.0)
    }
}

impl FromStr for ModuleId {
    type Err = ServerError;

    fn from_str(value: &str) -> Result<Self, Self::Err> {
        Self::new(value)
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum ModuleState {
    Discovered,
    Validated,
    Installing,
    Installed,
    Starting,
    Ready,
    Stopping,
    Stopped,
    Failed,
}

#[derive(Clone, Debug, Serialize)]
pub struct ModuleDescriptor {
    pub id: ModuleId,
    pub name: String,
    pub version: String,
    pub api_version: u32,
    pub description: String,
    pub dependencies: Vec<ModuleId>,
    pub required: bool,
}

#[derive(Clone, Debug)]
pub struct ModuleMigration {
    pub id: String,
    pub checksum: String,
    pub query: String,
}

#[derive(Clone)]
pub struct ModuleContext {
    pub database: Database,
    pub health: HealthRegistry,
    pub metrics: Metrics,
}

#[async_trait]
pub trait LyxalModule: Send + Sync {
    fn descriptor(&self) -> ModuleDescriptor;

    fn migrations(&self) -> Vec<ModuleMigration> {
        Vec::new()
    }

    async fn install(&self, _context: &ModuleContext) -> Result<(), ServerError> {
        Ok(())
    }

    async fn start(&self, _context: &ModuleContext) -> Result<(), ServerError> {
        Ok(())
    }

    async fn stop(&self, _context: &ModuleContext) -> Result<(), ServerError> {
        Ok(())
    }

    async fn health(&self, _context: &ModuleContext) -> Result<(), ServerError> {
        Ok(())
    }

    fn router(&self) -> Router {
        Router::new()
    }
}

pub type SharedModule = Arc<dyn LyxalModule>;
