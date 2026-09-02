use crate::migration::MigrationChecksum;
use crate::resource::kind::ResourceKind;
use serde::{Deserialize, Serialize};

/// Représentation portable d'une ressource d'un module Lyxal OS.
///
/// Le chemin logique (`logical_path`) est décorrélé de l'OS hôte (ex: `schema/tables.surql`, `migrations/001_initial.surql`).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ModuleResource {
    /// Chemin logique portable (toujours délimité par des `/`).
    pub logical_path: String,
    /// Type de ressource classifié.
    pub kind: ResourceKind,
    /// Contenu brut de la ressource.
    pub content: String,
}

impl ModuleResource {
    /// Crée une nouvelle instance de `ModuleResource`.
    pub fn new(
        logical_path: impl Into<String>,
        kind: ResourceKind,
        content: impl Into<String>,
    ) -> Self {
        Self {
            logical_path: logical_path.into(),
            kind,
            content: content.into(),
        }
    }

    /// Indique si le contenu de la ressource est vide ou composé uniquement d'espaces et commentaires.
    pub fn is_empty_or_whitespace(&self) -> bool {
        let trimmed = self.content.trim();
        if trimmed.is_empty() {
            return true;
        }

        // Vérifier si toutes les lignes non-vides sont des commentaires SurrealQL (-- ou /* */)
        let mut in_block_comment = false;
        for line in trimmed.lines() {
            let l = line.trim();
            if l.is_empty() {
                continue;
            }
            if in_block_comment {
                if l.contains("*/") {
                    in_block_comment = false;
                }
                continue;
            }
            if l.starts_with("/*") {
                if !l.contains("*/") {
                    in_block_comment = true;
                }
                continue;
            }
            if l.starts_with("--") || l.starts_with("//") || l.starts_with('#') {
                continue;
            }
            return false;
        }

        true
    }

    /// Calcule le checksum SHA-256 du contenu de la ressource.
    pub fn checksum(&self) -> MigrationChecksum {
        MigrationChecksum::from_surql(&self.content)
    }

    /// Taille en octets du contenu.
    pub fn size_bytes(&self) -> usize {
        self.content.len()
    }
}
