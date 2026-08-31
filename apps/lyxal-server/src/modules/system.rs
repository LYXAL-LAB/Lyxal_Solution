use super::{LyxalModule, ModuleDescriptor, ModuleId};
use axum::Router;

pub struct SystemModule {
    descriptor: ModuleDescriptor,
}

impl SystemModule {
    pub fn new() -> Self {
        let id = ModuleId::new("lyxal-system")
            .unwrap_or_else(|error| panic!("identifiant interne invalide : {error}"));
        Self {
            descriptor: ModuleDescriptor {
                id,
                name: "Lyxal System".into(),
                version: env!("CARGO_PKG_VERSION").into(),
                api_version: 1,
                description: "Routes et services système de Lyxal OS".into(),
                dependencies: Vec::new(),
                required: true,
            },
        }
    }
}

impl Default for SystemModule {
    fn default() -> Self {
        Self::new()
    }
}

#[async_trait::async_trait]
impl LyxalModule for SystemModule {
    fn descriptor(&self) -> ModuleDescriptor {
        self.descriptor.clone()
    }

    fn router(&self) -> Router {
        Router::new()
    }
}
