//! CSV Parser Implementation
//!
//! Parser CSV robuste avec détection automatique du délimiteur.

use super::model::*;
use crate::parser::{ParseResult, ParseError};

/// Parse un fichier CSV depuis des bytes
pub fn parse(data: &[u8]) -> ParseResult<CsvDocument> {
    let content = String::from_utf8_lossy(data).into_owned();
    let delimiter = detect_delimiter(&content);
    
    let mut rows = Vec::new();
    for line in content.lines() {
        if line.trim().is_empty() { continue; }
        let row: Vec<String> = line.split(delimiter)
            .map(|s| s.trim_matches('"').trim().to_string())
            .collect();
        rows.push(row);
    }
    
    let mut doc = CsvDocument {
        delimiter,
        ..Default::default()
    };
    
    if !rows.is_empty() {
        doc.headers = Some(rows.remove(0));
        doc.rows = rows;
    }
    
    Ok(doc)
}

/// Parse un fichier CSV depuis un fichier
pub fn parse_file(path: impl AsRef<std::path::Path>) -> ParseResult<CsvDocument> {
    let data = std::fs::read(path)?;
    parse(&data)
}

fn detect_delimiter(content: &str) -> char {
    let delimiters = [',', ';', '\t', '|'];
    let mut best_delim = ',';
    let mut max_count = 0;
    
    if let Some(first_line) = content.lines().next() {
        for &delim in &delimiters {
            let count = first_line.chars().filter(|&c| c == delim).count();
            if count > max_count {
                max_count = count;
                best_delim = delim;
            }
        }
    }
    best_delim
}
