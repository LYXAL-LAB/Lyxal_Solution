//! HTML Parser Implementation
//!
//! Utilise quick-xml pour parser le HTML et le transformer en AST Lyxal.

use quick_xml::Reader;
use quick_xml::events::Event;
use super::model::*;
use crate::parser::{ParseResult, ParseError};

/// Parse un document HTML depuis des bytes
pub fn parse(data: &[u8]) -> ParseResult<HtmlDocument> {
    let html = String::from_utf8_lossy(data).into_owned();
    let mut reader = Reader::from_str(&html);
    reader.config_mut().trim_text(true);
    
    let mut doc = HtmlDocument::default();
    let mut buf = Vec::new();
    let mut current_tag = String::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                current_tag = String::from_utf8_lossy(e.local_name().as_ref()).to_string();
            }
            Ok(Event::Text(ref t)) => {
                let text = t.unescape().unwrap_or_default().to_string();
                if text.is_empty() { continue; }
                
                match current_tag.as_str() {
                    "title" => doc.title = Some(text),
                    "h1" | "h2" | "h3" | "h4" | "h5" | "h6" => {
                        let level = current_tag[1..].parse().unwrap_or(1);
                        doc.body.push(HtmlElement::Heading { level, content: text });
                    }
                    "p" => doc.body.push(HtmlElement::Paragraph(text)),
                    _ => {}
                }
            }
            Ok(Event::End(_)) => current_tag.clear(),
            Ok(Event::Eof) => break,
            _ => {}
        }
        buf.clear();
    }
    
    Ok(doc)
}

/// Parse un document HTML depuis un fichier
pub fn parse_file(path: impl AsRef<std::path::Path>) -> ParseResult<HtmlDocument> {
    let data = std::fs::read(path)?;
    parse(&data)
}
