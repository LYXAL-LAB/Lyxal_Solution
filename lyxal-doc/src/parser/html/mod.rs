//! # HTML Parser - HTML → AST Lyxal
//!
//! Parser pour le format HTML.

mod parser;
mod model;

pub use model::*;
pub use parser::{parse, parse_file};

use super::{ParseResult, ParseError, ImportMetadata, ImportStats, ImportWarning};
use crate::core::node::Block;

use std::sync::atomic::{AtomicU64, Ordering};

static ID_COUNTER: AtomicU64 = AtomicU64::new(1);

fn new_id() -> String {
    format!("html_{}", ID_COUNTER.fetch_add(1, Ordering::Relaxed))
}

/// Convertit un HtmlDocument vers l'AST Lyxal unifié
pub fn to_ast(doc: &HtmlDocument) -> ParseResult<crate::core::document::Document> {
    use crate::core::document::Document;
    use crate::core::node::*;
    use crate::core::meta::Metadata;
    
    let mut blocks = Vec::new();
    
    for element in &doc.body {
        match element {
            HtmlElement::Heading { level, content } => {
                blocks.push(Block::Section(SectionBlock {
                    id: new_id(),
                    meta: Metadata::default(),
                    level: *level as u8,
                    children: vec![Block::Paragraph(ParagraphBlock {
                        id: new_id(),
                        meta: Metadata::default(),
                        inlines: vec![Inline::Text(TextInline { text: content.clone() })],
                    })],
                }));
            }
            HtmlElement::Paragraph(content) => {
                blocks.push(Block::Paragraph(ParagraphBlock {
                    id: new_id(),
                    meta: Metadata::default(),
                    inlines: vec![Inline::Text(TextInline { text: content.clone() })],
                }));
            }
            _ => {}
        }
    }
    
    Ok(Document {
        id: new_id(),
        title: doc.title.clone().unwrap_or_else(|| "HTML Import".to_string()),
        meta: Metadata::default(),
        content: blocks,
    })
}

/// Crée les métadonnées d'import pour un document HTML
pub fn create_import_metadata(doc: &HtmlDocument, filename: Option<&str>) -> ImportMetadata {
    ImportMetadata {
        source: "html".to_string(),
        source_file: filename.map(String::from),
        format_version: Some("HTML5".to_string()),
        confidence: 0.9,
        lossy: true,
        imported_at: super::chrono_now(),
        parser_version: env!("CARGO_PKG_VERSION").to_string(),
        warnings: vec![],
        stats: ImportStats {
            pages: 1,
            text_elements: doc.body.len(),
            images: 0,
            tables: 0,
            form_fields: 0,
            links: 0,
        },
    }
}
