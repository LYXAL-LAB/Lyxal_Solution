//! # XLSX Parser - Excel → AST Lyxal
//!
//! Parser complet pour les classeurs Excel (.xlsx).
//!
//! ## Statut: ✅ Implémenté (10/10)
//!
//! ## Contrat: `XLSX_TO_LYXAL_AST_CONTRACT.md`
//!
//! ## Format XLSX
//!
//! XLSX est un format ZIP contenant des fichiers XML (SpreadsheetML) :
//! ```text
//! workbook.xlsx (ZIP)
//! ├── [Content_Types].xml
//! ├── _rels/.rels
//! ├── docProps/
//! │   ├── core.xml         ← Métadonnées Dublin Core
//! │   └── app.xml          ← Métadonnées application
//! ├── xl/
//! │   ├── workbook.xml     ← Classeur principal
//! │   ├── sharedStrings.xml ← Table de chaînes
//! │   ├── styles.xml       ← Styles
//! │   ├── worksheets/
//! │   │   ├── sheet1.xml
//! │   │   └── sheet2.xml
//! │   ├── theme/
//! │   │   └── theme1.xml
//! │   ├── media/           ← Images
//! │   └── _rels/
//! ```
//!
//! ## Spécification
//!
//! - ECMA-376 5th Edition (Office Open XML)
//! - ISO/IEC 29500:2016

mod parser;
mod model;
mod xml_parser;

pub use model::*;
pub use parser::{parse, parse_file};

use super::{ParseResult, ParseError, ImportMetadata, ImportStats, ImportWarning};
use crate::core::node::Block;

use std::sync::atomic::{AtomicU64, Ordering};

static ID_COUNTER: AtomicU64 = AtomicU64::new(1);

fn new_id() -> String {
    format!("xlsx_{}", ID_COUNTER.fetch_add(1, Ordering::Relaxed))
}

/// Convertit un XlsxDocument vers l'AST Lyxal unifié
pub fn to_ast(doc: &XlsxDocument) -> ParseResult<crate::core::document::Document> {
    use crate::core::document::Document;
    use crate::core::node::*;
    use crate::core::meta::Metadata;
    
    let mut sheets_blocks = Vec::new();
    
    for sheet in &doc.sheets {
        let table = convert_sheet(sheet, doc);
        
        // Each sheet becomes a section with a table
        sheets_blocks.push(Block::Section(SectionBlock {
            id: new_id(),
            meta: Metadata::default(),
            level: 1,
            children: vec![
                Block::Paragraph(ParagraphBlock {
                    id: new_id(),
                    meta: Metadata::default(),
                    inlines: vec![Inline::Text(TextInline { text: sheet.name.clone() })],
                }),
                table,
            ],
        }));
    }
    
    Ok(Document {
        id: new_id(),
        title: doc.metadata.title.clone().unwrap_or_default(),
        meta: Metadata::default(),
        content: sheets_blocks,
    })
}

fn convert_sheet(sheet: &XlsxSheet, doc: &XlsxDocument) -> Block {
    use crate::core::node::*;
    use crate::core::meta::Metadata;
    
    let rows: Vec<TableRow> = sheet.rows.iter().map(|row| {
        let cells: Vec<TableCell> = row.cells.iter().map(|cell| {
            let text = get_cell_text(cell, doc);
            let inlines = if text.is_empty() {
                vec![]
            } else {
                vec![Inline::Text(TextInline { text })]
            };
            
            // Check if this cell is part of a merge
            let (colspan, rowspan) = get_cell_span(&cell.reference, &sheet.merge_cells);
            
            TableCell {
                id: new_id(),
                meta: Metadata::default(),
                content: if inlines.is_empty() {
                    vec![]
                } else {
                    vec![Block::Paragraph(ParagraphBlock {
                        id: new_id(),
                        meta: Metadata::default(),
                        inlines,
                    })]
                },
                colspan,
                rowspan,
                header: row.row_index == 1, // First row as header
            }
        }).collect();
        
        TableRow {
            id: new_id(),
            meta: Metadata::default(),
            cells,
        }
    }).collect();
    
    Block::Table(TableBlock {
        id: new_id(),
        meta: Metadata::default(),
        rows,
    })
}

fn get_cell_text(cell: &XlsxCell, doc: &XlsxDocument) -> String {
    match &cell.value {
        XlsxCellValue::Empty => String::new(),
        XlsxCellValue::Number(n) => format_number(*n, cell.style_index, &doc.styles),
        XlsxCellValue::String(s) => s.clone(),
        XlsxCellValue::SharedString(idx) => {
            doc.shared_strings.get(*idx as usize)
                .map(|ss| {
                    if let Some(ref text) = ss.text {
                        text.clone()
                    } else if let Some(ref rich) = ss.rich_text {
                        rich.iter().map(|r| r.text.as_str()).collect()
                    } else {
                        String::new()
                    }
                })
                .unwrap_or_default()
        }
        XlsxCellValue::Boolean(b) => if *b { "TRUE" } else { "FALSE" }.to_string(),
        XlsxCellValue::Error(e) => e.clone(),
    }
}

fn format_number(num: f64, style_index: Option<u32>, styles: &XlsxStyles) -> String {
    // Check for date format
    if let Some(idx) = style_index {
        if let Some(xf) = styles.cell_xfs.get(idx as usize) {
            if let Some(fmt_id) = xf.num_fmt_id {
                // Built-in date formats: 14-22, 45-47
                if (14..=22).contains(&fmt_id) || (45..=47).contains(&fmt_id) {
                    return excel_serial_to_date(num);
                }
                
                // Check custom formats
                if let Some(nf) = styles.number_formats.iter().find(|f| f.id == fmt_id) {
                    let code = nf.format_code.to_lowercase();
                    if code.contains("yy") || code.contains("mm") || code.contains("dd") {
                        return excel_serial_to_date(num);
                    }
                }
            }
        }
    }
    
    // Regular number
    if num.fract() == 0.0 && num.abs() < 1e15 {
        format!("{}", num as i64)
    } else {
        format!("{}", num)
    }
}

fn excel_serial_to_date(serial: f64) -> String {
    // Excel serial date: days since 1899-12-30 (with leap year bug for 1900)
    // For simplicity, just show the raw number for now
    // A full implementation would convert to a proper date string
    let days = serial.floor() as i64;
    let base_date = 25569; // Days from 1900-01-01 to 1970-01-01
    let unix_days = days - base_date;
    let unix_secs = unix_days * 86400;
    
    // Simple date formatting (year-month-day)
    let secs_per_day = 86400i64;
    let days_since_epoch = unix_secs / secs_per_day;
    
    // Calculate year, month, day (simplified)
    let mut year = 1970;
    let mut remaining_days = days_since_epoch;
    
    loop {
        let days_in_year = if is_leap_year(year) { 366 } else { 365 };
        if remaining_days < days_in_year {
            break;
        }
        remaining_days -= days_in_year;
        year += 1;
    }
    
    let days_in_months: [i64; 12] = if is_leap_year(year) {
        [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    } else {
        [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    };
    
    let mut month = 1;
    for &days_in_month in &days_in_months {
        if remaining_days < days_in_month {
            break;
        }
        remaining_days -= days_in_month;
        month += 1;
    }
    
    let day = remaining_days + 1;
    
    format!("{:04}-{:02}-{:02}", year, month, day)
}

fn is_leap_year(year: i64) -> bool {
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
}

fn get_cell_span(reference: &str, merge_cells: &[XlsxMergeCell]) -> (u8, u8) {
    for merge in merge_cells {
        if let Some((start, end)) = merge.reference.split_once(':') {
            if reference == start {
                let start_coords = parse_cell_reference(start);
                let end_coords = parse_cell_reference(end);
                
                let colspan = (end_coords.0 - start_coords.0 + 1).min(255) as u8;
                let rowspan = (end_coords.1 - start_coords.1 + 1).min(255) as u8;
                
                return (colspan, rowspan);
            }
        }
    }
    (1, 1)
}

fn parse_cell_reference(reference: &str) -> (u32, u32) {
    let mut col = 0u32;
    let mut row = 0u32;
    
    for c in reference.chars() {
        if c.is_ascii_alphabetic() {
            col = col * 26 + (c.to_ascii_uppercase() as u32 - 'A' as u32 + 1);
        } else if c.is_ascii_digit() {
            row = row * 10 + (c as u32 - '0' as u32);
        }
    }
    
    (col, row)
}

/// Crée les métadonnées d'import pour un document XLSX
pub fn create_import_metadata(doc: &XlsxDocument, filename: Option<&str>) -> ImportMetadata {
    let cell_count: usize = doc.sheets.iter()
        .flat_map(|s| s.rows.iter())
        .flat_map(|r| r.cells.iter())
        .filter(|c| !matches!(c.value, XlsxCellValue::Empty))
        .count();
    
    let image_count = doc.images.len();
    
    ImportMetadata {
        source: "xlsx".to_string(),
        source_file: filename.map(String::from),
        format_version: Some("Office Open XML (SpreadsheetML)".to_string()),
        confidence: 0.95,
        lossy: false,
        imported_at: super::chrono_now(),
        parser_version: env!("CARGO_PKG_VERSION").to_string(),
        warnings: doc.warnings.iter().map(|w| ImportWarning {
            warning_type: "xlsx".to_string(),
            message: w.clone(),
            details: None,
        }).collect(),
        stats: ImportStats {
            pages: doc.sheets.len(),
            text_elements: cell_count,
            images: image_count,
            tables: doc.sheets.len(),
            form_fields: 0,
            links: doc.sheets.iter().map(|s| s.hyperlinks.len()).sum(),
        },
    }
}
