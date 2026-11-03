use crate::error::RuntimeError;
use crate::resource::provider::ResourceProvider;
use async_trait::async_trait;

/// Fichiers d'un module embarqués dans le binaire (`include_str!`), sous forme de couples
/// `(chemin logique, contenu)`. Permet d'installer un module sans accès à ses sources.
pub struct EmbeddedResourceProvider {
    files: &'static [(&'static str, &'static str)],
}

impl EmbeddedResourceProvider {
    /// Crée un fournisseur à partir des fichiers embarqués d'un module.
    pub fn new(files: &'static [(&'static str, &'static str)]) -> Self {
        Self { files }
    }
}

#[async_trait]
impl ResourceProvider for EmbeddedResourceProvider {
    async fn read(&self, logical_path: &str) -> Result<String, RuntimeError> {
        self.files
            .iter()
            .find(|(path, _)| *path == logical_path)
            .map(|(_, content)| (*content).to_string())
            .ok_or_else(|| RuntimeError::ResourceNotFound {
                path: logical_path.to_string(),
            })
    }
}
