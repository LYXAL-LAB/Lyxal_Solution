use crate::types::ModuleId;
use serde::{Deserialize, Serialize};

/// Description déclarative et contrat immuable d'un module Lyxal OS.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ModuleDescriptor {
    /// Identifiant canonique du module.
    pub id: ModuleId,
    /// Nom lisible du module (ex: "Lyxal Scheduler").
    pub name: String,
    /// Version sémantique (ex: "1.0.0").
    pub version: String,
    /// Description optionnelle du module.
    pub description: Option<String>,
    /// Liste des dépendances obligatoires vers d'autres modules.
    pub dependencies: Vec<ModuleId>,
    /// Capacités déclarées (ex: "database", "workers", "events").
    pub capabilities: Vec<String>,
}

impl ModuleDescriptor {
    /// Crée un descripteur avec les champs obligatoires.
    pub fn new(id: impl Into<ModuleId>, version: impl Into<String>) -> Self {
        let module_id = id.into();
        let name = module_id.as_str().to_string();
        Self {
            id: module_id,
            name,
            version: version.into(),
            description: None,
            dependencies: Vec::new(),
            capabilities: Vec::new(),
        }
    }

    /// Débute la construction via un builder fluide.
    pub fn builder(id: impl Into<ModuleId>, version: impl Into<String>) -> ModuleDescriptorBuilder {
        ModuleDescriptorBuilder::new(id, version)
    }
}

/// Builder fluide pour initialiser un `ModuleDescriptor`.
#[derive(Debug, Clone)]
pub struct ModuleDescriptorBuilder {
    descriptor: ModuleDescriptor,
}

impl ModuleDescriptorBuilder {
    pub fn new(id: impl Into<ModuleId>, version: impl Into<String>) -> Self {
        Self {
            descriptor: ModuleDescriptor::new(id, version),
        }
    }

    pub fn name(mut self, name: impl Into<String>) -> Self {
        self.descriptor.name = name.into();
        self
    }

    pub fn description(mut self, description: impl Into<String>) -> Self {
        self.descriptor.description = Some(description.into());
        self
    }

    pub fn dependency(mut self, dep: impl Into<ModuleId>) -> Self {
        let dep_id = dep.into();
        if !self.descriptor.dependencies.contains(&dep_id) {
            self.descriptor.dependencies.push(dep_id);
        }
        self
    }

    pub fn dependencies(mut self, deps: impl IntoIterator<Item = impl Into<ModuleId>>) -> Self {
        for dep in deps {
            self = self.dependency(dep);
        }
        self
    }

    pub fn capability(mut self, capability: impl Into<String>) -> Self {
        let cap = capability.into();
        if !self.descriptor.capabilities.contains(&cap) {
            self.descriptor.capabilities.push(cap);
        }
        self
    }

    pub fn capabilities(mut self, caps: impl IntoIterator<Item = impl Into<String>>) -> Self {
        for cap in caps {
            self = self.capability(cap);
        }
        self
    }

    pub fn build(self) -> ModuleDescriptor {
        self.descriptor
    }
}
