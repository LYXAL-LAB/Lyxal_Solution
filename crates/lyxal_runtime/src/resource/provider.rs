use crate::error::RuntimeError;
use crate::resource::model::ModuleResource;
use async_trait::async_trait;

/// Trait d'abstraction pour la récupération des ressources de modules.
///
/// Permet de découpler le moteur d'exécution du système de fichiers sous-jacent
/// (supporte filesystem local, packages compressés, mocks de tests, storage distribué).
#[async_trait]
pub trait ResourceProvider: Send + Sync {
    /// Liste les chemins logiques de ressources disponibles sous un préfixe donné (ex: `"schema"`, `"migrations"`).
    async fn list_resources(&self, prefix: &str) -> Result<Vec<String>, RuntimeError>;

    /// Lit le contenu et métadonnées d'une ressource à partir de son chemin logique.
    async fn read_resource(&self, logical_path: &str) -> Result<ModuleResource, RuntimeError>;

    /// Vérifie si une ressource existe à l'emplacement logique spécifié.
    async fn exists(&self, logical_path: &str) -> bool;
}
