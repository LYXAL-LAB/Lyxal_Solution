//! # CSV Parser - CSV → AST Lyxal
//!
//! Parser pour le format CSV.

mod parser;
mod model;

pub use model::*;
pub use parser::{parse, parse_file};

use super::{ParseResult, ParseError, ImportMetadata, ImportStats, ImportWarning};
use crate::core::node::Block;

use std::sync::atomic::{AtomicU64, Ordering};

static ID_COUNTER: AtomicU64 = AtomicU64::new(1);

fn new_id() -> String {
    format!("csv_{}", ID_COUNTER.fetch_add(1, Ordering::Relaxed))
}

/// Convertit un CsvDocument vers l'AST Lyxal unifié
pub fn to_ast(doc: &CsvDocument) -> ParseResult<crate::core::document::Document> {
    use crate::core::document::Document;
    use crate::core::node::*;
    use crate::core::meta::Metadata;
    
    let mut rows = Vec::new();
    
    // Header
    if let Some(ref headers) = doc.headers {
        rows.push(TableRow {
            id: new_id(),
            meta: Metadata::default(),
            cells: headers.iter().map(|h| TableCell {
                id: new_id(),
                meta: Metadata::default(),
                content: vec![Block::Paragraph(ParagraphBlock {
                    id: new_id(),
                    meta: Metadata::default(),
                    inlines: vec![Inline::Text(TextInline { text: h.clone() })],
                })],
                colspan: 1,
                rowspan: 1,
                header: true,
            }).collect(),
        });
    }
    
    // Data
    for row_data in &doc.rows {
        rows.push(TableRow {
            id: new_id(),
            meta: Metadata::default(),
            cells: row_data.iter().map(|c| TableCell {
                id: new_id(),
                meta: Metadata::default(),
                content: vec![Block::Paragraph(ParagraphBlock {
                    id: new_id(),
                    meta: Metadata::default(),
                    inlines: vec![Inline::Text(TextInline { text: c.clone() })],
                })],
                colspan: 1,
                rowspan: 1,
                header: false,
            }).collect(),
        });
    }
    
    Ok(Document {
        id: new_id(),
        title: "CSV Import".to_string(),
        meta: Metadata::default(),
        content: vec![Block::Table(TableBlock {
            id: new_id(),
            meta: Metadata::default(),
            rows,
        })],
    })
}

/// Crée les métadonnées d'import pour un document CSV
pub fn create_import_metadata(doc: &CsvDocument, filename: Option<&str>) -> ImportMetadata {
    ImportMetadata {
        source: "csv".to_string(),
        source_file: filename.map(String::from),
        format_version: Some("RFC 4180".to_string()),
        confidence: 1.0,
        lossy: false,
        imported_at: super::chrono_now(),
        parser_version: env!("CARGO_PKG_VERSION").to_string(),
        warnings: vec![],
        stats: ImportStats {
            pages: 1,
            text_elements: doc.rows.len(),
            images: 0,
            tables: 1,
            form_fields: 0,
            links: 0,
        },
    }
}
