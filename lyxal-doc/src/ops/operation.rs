use serde::{Deserialize, Serialize};
use crate::core::node::{Block, Inline};
use crate::ops::path::Path;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "op", rename_all = "snake_case")]
pub enum Operation {
    // --- Block Operations ---
    
    /// Insère un bloc à une position donnée. 
    /// Le Path cible le parent (ex: Section ou Document root), index spécifie la position.
    InsertBlock {
        parent_path: Path,
        index: usize,
        block: Block,
    },
    
    /// Supprime un bloc par son ID (via le Path).
    RemoveBlock {
        path: Path,
    },
    
    /// Déplace un bloc d'une position à une autre.
    MoveBlock {
        from_path: Path,
        to_parent_path: Path,
        to_index: usize,
    },
    
    /// Met à jour les métadonnées d'un bloc.
    UpdateBlockMeta {
        path: Path,
        author: Option<String>,
        add_tags: Vec<crate::core::meta::SemanticTag>,
        remove_tag_keys: Vec<String>,
        policy: Option<crate::core::meta::NodePolicy>,
    },

    // --- Inline Operations ---
    
    /// Insère du texte à un offset donné dans un bloc de texte.
    InsertText {
        path: Path, // Doit cibler un Paragraph ou un bloc contenant des inlines
        offset: usize,
        value: String,
    },
    
    /// Supprime une plage de texte.
    DeleteTextRange {
        path: Path,
        offset: usize,
        length: usize,
    },

    // --- Structure Operations ---
    
    /// Coupe un paragraphe en deux à un offset donné.
    SplitParagraph {
        path: Path,
        offset: usize,
        new_block_id: String,
    },
    
    /// Fusionne un paragraphe avec le suivant.
    MergeParagraphs {
        path: Path, // Le paragraphe "source" qui sera fusionné dans le précédent ou suivant
        with_previous: bool,
    },
}

