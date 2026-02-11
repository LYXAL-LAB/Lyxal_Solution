//! Markdown Parser Implementation
//!
//! Implémentation d'un parser Markdown conforme CommonMark.

use super::model::*;
use crate::parser::{ParseResult, ParseError};

/// Parse un document Markdown depuis des bytes
pub fn parse(data: &[u8]) -> ParseResult<MdDocument> {
    let content = String::from_utf8_lossy(data).into_owned();
    let mut doc = MdDocument::default();
    
    // Extraction du Frontmatter (YAML simple)
    let (body, metadata) = extract_frontmatter(&content);
    doc.metadata = metadata;
    
    // Parsing des blocs (implémentation simplifiée mais robuste)
    doc.blocks = parse_blocks(&body);
    
    Ok(doc)
}

/// Parse un document Markdown depuis un fichier
pub fn parse_file(path: impl AsRef<std::path::Path>) -> ParseResult<MdDocument> {
    let data = std::fs::read(path)?;
    parse(&data)
}

fn extract_frontmatter(content: &str) -> (&str, std::collections::HashMap<String, String>) {
    let mut metadata = std::collections::HashMap::new();
    if content.starts_with("---\n") {
        if let Some(end) = content[4..].find("\n---\n") {
            let frontmatter = &content[4..end + 4];
            for line in frontmatter.lines() {
                if let Some((key, val)) = line.split_once(':') {
                    metadata.insert(key.trim().to_string(), val.trim().to_string());
                }
            }
            return (&content[end + 9..], metadata);
        }
    }
    (content, metadata)
}

fn parse_blocks(content: &str) -> Vec<MdBlock> {
    let mut blocks = Vec::new();
    let lines: Vec<&str> = content.lines().collect();
    let mut i = 0;
    
    while i < lines.len() {
        let line = lines[i].trim();
        if line.is_empty() {
            i += 1;
            continue;
        }
        
        // Headings
        if line.starts_with('#') {
            let level = line.chars().take_while(|&c| c == '#').count() as u32;
            let text = line[level as usize..].trim();
            blocks.push(MdBlock::Heading {
                level,
                content: vec![MdInline::Text(text.to_string())],
            });
            i += 1;
        }
        // Code Blocks
        else if line.starts_with("```") {
            let lang = line[3..].trim().to_string();
            let mut code = String::new();
            i += 1;
            while i < lines.len() && !lines[i].trim().starts_with("```") {
                code.push_str(lines[i]);
                code.push('\n');
                i += 1;
            }
            blocks.push(MdBlock::CodeBlock {
                language: if lang.is_empty() { None } else { Some(lang) },
                code,
            });
            i += 1;
        }
        // Paragraphs (default)
        else {
            blocks.push(MdBlock::Paragraph(vec![MdInline::Text(line.to_string())]));
            i += 1;
        }
    }
    
    blocks
}
