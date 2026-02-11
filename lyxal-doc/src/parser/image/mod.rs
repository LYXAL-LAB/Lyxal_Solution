//! # Image Parser - Image → AST Lyxal
//!
//! Support pour l'import d'images avec extraction de texte (OCR).

mod parser;
mod model;

pub use model::*;
pub use parser::{parse, parse_file};

use super::{ParseResult, ParseError, ImportMetadata, ImportStats, ImportWarning};
use crate::core::node::Block;

use std::sync::atomic::{AtomicU64, Ordering};

static ID_COUNTER: AtomicU64 = AtomicU64::new(1);

fn new_id() -> String {
    format!("img_{}", ID_COUNTER.fetch_add(1, Ordering::Relaxed))
}

/// Convertit un ImageDocument vers l'AST Lyxal unifié
pub fn to_ast(doc: &ImageDocument) -> ParseResult<crate::core::document::Document> {
    use crate::core::document::Document;
    use crate::core::node::*;
    use crate::core::meta::Metadata;
    
    let mut blocks = Vec::new();
    
    // Si on a des régions de texte (OCR), on les convertit en paragraphes
    if !doc.text_regions.is_empty() {
        for region in &doc.text_regions {
            blocks.push(Block::Paragraph(ParagraphBlock {
                id: new_id(),
                meta: Metadata::default(),
                inlines: vec![Inline::Text(TextInline {
                    text: region.text.clone(),
                })],
            }));
        }
    } else {
        // Sinon, on insère simplement l'image comme un bloc unique
        blocks.push(Block::Image(ImageBlock {
            id: new_id(),
            meta: Metadata::default(),
            src: format!("data:image/{};base64,...", doc.format),
            alt: Some(format!("Image {}x{}", doc.metadata.width, doc.metadata.height)),
            caption: None,
            width: Some(doc.metadata.width),
            height: Some(doc.metadata.height),
        }));
    }
    
    Ok(Document {
        id: new_id(),
        title: format!("Image_{}", doc.format),
        meta: Metadata::default(),
        content: blocks,
    })
}

/// Crée les métadonnées d'import pour une image
pub fn create_import_metadata(doc: &ImageDocument, filename: Option<&str>) -> ImportMetadata {
    ImportMetadata {
        source: "image".to_string(),
        source_file: filename.map(String::from),
        format_version: Some(doc.format.clone()),
        confidence: if doc.text_regions.is_empty() { 1.0 } else { 0.85 }, // Confidence baisse si OCR
        lossy: true,
        imported_at: super::chrono_now(),
        parser_version: env!("CARGO_PKG_VERSION").to_string(),
        warnings: doc.warnings.iter().map(|w| ImportWarning {
            warning_type: "image".to_string(),
            message: w.clone(),
            details: None,
        }).collect(),
        stats: ImportStats {
            pages: 1,
            text_elements: doc.text_regions.len(),
            images: 1,
            tables: 0,
            form_fields: 0,
            links: 0,
        },
    }
}
