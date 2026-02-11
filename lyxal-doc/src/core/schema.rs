use crate::core::node::{Block, Inline};

pub trait Schema {
    fn is_allowed_in_document(&self, block: &Block) -> bool;
    fn is_allowed_in_block(&self, parent: &Block, child: &Block) -> bool;
    fn is_allowed_inline(&self, parent: &Block, inline: &Inline) -> bool;
}

pub struct DefaultSchema;

impl Schema for DefaultSchema {
    fn is_allowed_in_document(&self, _block: &Block) -> bool {
        true // Par défaut, tous les blocs sont autorisés à la racine
    }

    fn is_allowed_in_block(&self, parent: &Block, _child: &Block) -> bool {
        match parent {
            Block::Section(_) => true,
            Block::Paragraph(_) => false, // Un paragraphe ne contient pas de blocs
            Block::List(_) => true,
            Block::Table(_) => true,
            Block::Quote(_) => true,
            Block::CodeBlock(_) => false,
            Block::Comment(_) => false, // Un commentaire est feuille pour l'instant
            Block::Footnote(_) => true,
            Block::Header(_) => true,
            Block::Footer(_) => true,
            _ => false,
        }
    }

    fn is_allowed_inline(&self, parent: &Block, _inline: &Inline) -> bool {
        match parent {
            Block::Paragraph(_) => true,
            Block::CodeBlock(_) => false, // CodeBlock contient du texte brut, pas d'Inline AST
            _ => false,
        }
    }
}
