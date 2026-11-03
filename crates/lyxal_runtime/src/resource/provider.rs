use crate::error::RuntimeError;
use async_trait::async_trait;

/// Source des fichiers d'un module : système de fichiers, fichiers embarqués dans le binaire,
/// ou double de test. Le manifeste dit quels fichiers lire ; le fournisseur les lit.
#[async_trait]
pub trait ResourceProvider: Send + Sync {
    /// Contenu UTF-8 du fichier désigné par son chemin logique (relatif à la racine du module,
    /// séparé par `/`). Un fichier absent donne `RuntimeError::ResourceNotFound`.
    async fn read(&self, logical_path: &str) -> Result<String, RuntimeError>;
}
