use serde::{Deserialize, Serialize};
use crate::core::NodeId;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum PathSegment {
    /// Cible un bloc par son identifiant unique
    Block(NodeId),
    /// Cible un index dans une liste d'inlines (pour Paragraph, etc.)
    InlineIndex(usize),
    /// Cible un index de cellule ou de ligne (pour Table)
    Index(usize),
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize, Default)]
pub struct Path(pub Vec<PathSegment>);

impl Path {
    pub fn from_block(id: NodeId) -> Self {
        Self(vec![PathSegment::Block(id)])
    }
}

