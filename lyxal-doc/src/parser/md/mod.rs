//! # Markdown Parser - MD → AST Lyxal
//!
//! Parser pour le format Markdown (CommonMark + GFM).

mod parser;
mod model;

pub use model::*;
pub use parser::{parse, parse_file};

use super::{ParseResult, ParseError, ImportMetadata, ImportStats, ImportWarning};
use crate::core::node::Block;

use std::sync::atomic::{AtomicU64, Ordering};

static ID_COUNTER: AtomicU64 = AtomicU64::new(1);

fn new_id() -> String {
    format!("md_{}", ID_COUNTER.fetch_add(1, Ordering::Relaxed))
}

/// Convertit un MdDocument vers l'AST Lyxal unifié
pub fn to_ast(doc: &MdDocument) -> ParseResult<crate::core::document::Document> {
    use crate::core::document::Document;
    use crate::core::node::*;
    use crate::core::meta::Metadata;
    
    let mut blocks = Vec::new();
    
    for md_block in &doc.blocks {
        match md_block {
            MdBlock::Heading { level, content } => {
                blocks.push(Block::Section(SectionBlock {
                    id: new_id(),
                    meta: Metadata::default(),
                    level: *level as u8,
                    children: vec![Block::Paragraph(ParagraphBlock {
                        id: new_id(),
                        meta: Metadata::default(),
                        inlines: convert_inlines(content),
                    })],
                }));
            }
            MdBlock::Paragraph(content) => {
                blocks.push(Block::Paragraph(ParagraphBlock {
                    id: new_id(),
                    meta: Metadata::default(),
                    inlines: convert_inlines(content),
                }));
            }
            MdBlock::CodeBlock { language, code } => {
                blocks.push(Block::CodeBlock(CodeBlockBlock {
                    id: new_id(),
                    meta: Metadata::default(),
                    language: language.clone(),
                    code: code.clone(),
                }));
            }
            _ => {} // Support partiel pour l'instant
        }
    }
    
    Ok(Document {
        id: new_id(),
        title: doc.metadata.get("title").cloned().unwrap_or_else(|| "Markdown Document".to_string()),
        meta: Metadata::default(),
        content: blocks,
    })
}

fn convert_inlines(inlines: &[MdInline]) -> Vec<crate::core::node::Inline> {
    use crate::core::node::*;
    inlines.iter().map(|inline| match inline {
        MdInline::Text(t) => Inline::Text(TextInline { text: t.clone() }),
        MdInline::Strong(content) => Inline::Bold(BoldInline { content: convert_inlines(content) }),
        MdInline::Emphasis(content) => Inline::Italic(ItalicInline { content: convert_inlines(content) }),
        MdInline::Code(t) => Inline::Code(CodeInline { text: t.clone() }),
        _ => Inline::Text(TextInline { text: " ".to_string() }),
    }).collect()
}

/// Crée les métadonnées d'import pour un document Markdown
pub fn create_import_metadata(doc: &MdDocument, filename: Option<&str>) -> ImportMetadata {
    ImportMetadata {
        source: "md".to_string(),
        source_file: filename.map(String::from),
        format_version: Some("CommonMark/GFM".to_string()),
        confidence: 1.0,
        lossy: false,
        imported_at: super::chrono_now(),
        parser_version: env!("CARGO_PKG_VERSION").to_string(),
        warnings: vec![],
        stats: ImportStats {
            pages: 1,
            text_elements: doc.blocks.len(),
            images: 0,
            tables: 0,
            form_fields: 0,
            links: 0,
        },
    }
}
