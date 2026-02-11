//! XML Parsing for DOCX files
//!
//! Uses quick-xml to parse the various XML files in a DOCX archive.

use quick_xml::Reader;
use quick_xml::events::{Event, BytesStart};
use std::collections::HashMap;

use super::model::*;
use crate::parser::{ParseResult, ParseError};

// =============================================================================
// NAMESPACES (Office Open XML)
// =============================================================================

const NS_W: &[u8] = b"http://schemas.openxmlformats.org/wordprocessingml/2006/main";
const NS_R: &[u8] = b"http://schemas.openxmlformats.org/officeDocument/2006/relationships";
const NS_A: &[u8] = b"http://schemas.openxmlformats.org/drawingml/2006/main";
const NS_WP: &[u8] = b"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing";
const NS_DC: &[u8] = b"http://purl.org/dc/elements/1.1/";
const NS_CP: &[u8] = b"http://schemas.openxmlformats.org/package/2006/metadata/core-properties";
const NS_DCTERMS: &[u8] = b"http://purl.org/dc/terms/";

// =============================================================================
// RELATIONSHIPS PARSER
// =============================================================================

pub fn parse_relationships(xml: &str) -> ParseResult<Vec<DocxRelationship>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut relationships = Vec::new();
    let mut buf = Vec::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Empty(ref e)) | Ok(Event::Start(ref e)) if e.local_name().as_ref() == b"Relationship" => {
                if let Some(rel) = parse_relationship_element(e) {
                    relationships.push(rel);
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(relationships)
}

fn parse_relationship_element(e: &BytesStart) -> Option<DocxRelationship> {
    let mut id = None;
    let mut rel_type = None;
    let mut target = None;
    let mut target_mode = None;
    
    for attr in e.attributes().flatten() {
        match attr.key.as_ref() {
            b"Id" => id = Some(String::from_utf8_lossy(&attr.value).to_string()),
            b"Type" => rel_type = Some(String::from_utf8_lossy(&attr.value).to_string()),
            b"Target" => target = Some(String::from_utf8_lossy(&attr.value).to_string()),
            b"TargetMode" => target_mode = Some(String::from_utf8_lossy(&attr.value).to_string()),
            _ => {}
        }
    }
    
    Some(DocxRelationship {
        id: id?,
        rel_type: parse_rel_type(&rel_type?),
        target: target?,
        target_mode,
    })
}

fn parse_rel_type(type_uri: &str) -> DocxRelType {
    if type_uri.contains("image") {
        DocxRelType::Image
    } else if type_uri.contains("hyperlink") {
        DocxRelType::Hyperlink
    } else if type_uri.contains("styles") {
        DocxRelType::Styles
    } else if type_uri.contains("numbering") {
        DocxRelType::Numbering
    } else if type_uri.contains("fontTable") {
        DocxRelType::FontTable
    } else if type_uri.contains("settings") {
        DocxRelType::Settings
    } else if type_uri.contains("webSettings") {
        DocxRelType::WebSettings
    } else if type_uri.contains("footnotes") {
        DocxRelType::FootNotes
    } else if type_uri.contains("endnotes") {
        DocxRelType::EndNotes
    } else if type_uri.contains("comments") {
        DocxRelType::Comments
    } else if type_uri.contains("header") {
        DocxRelType::Header
    } else if type_uri.contains("footer") {
        DocxRelType::Footer
    } else if type_uri.contains("theme") {
        DocxRelType::Theme
    } else {
        DocxRelType::Other(type_uri.to_string())
    }
}

// =============================================================================
// CORE METADATA PARSER (docProps/core.xml)
// =============================================================================

pub fn parse_core_metadata(xml: &str) -> ParseResult<DocxMetadata> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut metadata = DocxMetadata::default();
    let mut buf = Vec::new();
    let mut current_element = String::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                current_element = String::from_utf8_lossy(e.local_name().as_ref()).to_string();
            }
            Ok(Event::Text(ref t)) => {
                let text = t.unescape().unwrap_or_default().to_string();
                match current_element.as_str() {
                    "title" => metadata.title = Some(text),
                    "creator" => metadata.author = Some(text),
                    "subject" => metadata.subject = Some(text),
                    "description" => metadata.description = Some(text),
                    "keywords" => {
                        metadata.keywords = text.split(',')
                            .map(|s| s.trim().to_string())
                            .filter(|s| !s.is_empty())
                            .collect();
                    }
                    "category" => metadata.category = Some(text),
                    "created" => metadata.created = Some(text),
                    "modified" => metadata.modified = Some(text),
                    "lastModifiedBy" => metadata.last_modified_by = Some(text),
                    "revision" => metadata.revision = text.parse().ok(),
                    _ => {}
                }
            }
            Ok(Event::End(_)) => {
                current_element.clear();
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(metadata)
}

// =============================================================================
// APP METADATA PARSER (docProps/app.xml)
// =============================================================================

pub fn parse_app_metadata(xml: &str, metadata: &mut DocxMetadata) {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut buf = Vec::new();
    let mut current_element = String::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                current_element = String::from_utf8_lossy(e.local_name().as_ref()).to_string();
            }
            Ok(Event::Text(ref t)) => {
                let text = t.unescape().unwrap_or_default().to_string();
                match current_element.as_str() {
                    "Application" => metadata.application = Some(text),
                    "AppVersion" => metadata.app_version = Some(text),
                    "Pages" => metadata.page_count = text.parse().ok(),
                    "Words" => metadata.word_count = text.parse().ok(),
                    "Characters" => metadata.character_count = text.parse().ok(),
                    _ => {}
                }
            }
            Ok(Event::End(_)) => {
                current_element.clear();
            }
            Ok(Event::Eof) => break,
            _ => {}
        }
        buf.clear();
    }
}

// =============================================================================
// STYLES PARSER (word/styles.xml)
// =============================================================================

pub fn parse_styles(xml: &str) -> ParseResult<Vec<DocxStyle>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut styles = Vec::new();
    let mut buf = Vec::new();
    let mut in_style = false;
    let mut current_style: Option<DocxStyle> = None;
    let mut current_element = String::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                current_element = String::from_utf8_lossy(name.as_ref()).to_string();
                
                if name.as_ref() == b"style" {
                    in_style = true;
                    current_style = Some(parse_style_start(e));
                } else if in_style {
                    if name.as_ref() == b"basedOn" {
                        if let Some(ref mut style) = current_style {
                            style.based_on = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        }
                    } else if name.as_ref() == b"name" {
                        if let Some(ref mut style) = current_style {
                            if let Some(n) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")) {
                                style.name = n;
                            }
                        }
                    }
                }
            }
            Ok(Event::End(ref e)) => {
                if e.local_name().as_ref() == b"style" && in_style {
                    if let Some(style) = current_style.take() {
                        styles.push(style);
                    }
                    in_style = false;
                }
                current_element.clear();
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(styles)
}

fn parse_style_start(e: &BytesStart) -> DocxStyle {
    let mut id = String::new();
    let mut style_type = DocxStyleType::Paragraph;
    let mut is_default = false;
    
    for attr in e.attributes().flatten() {
        match attr.key.as_ref() {
            b"w:styleId" | b"styleId" => {
                id = String::from_utf8_lossy(&attr.value).to_string();
            }
            b"w:type" | b"type" => {
                let t = String::from_utf8_lossy(&attr.value).to_string();
                style_type = match t.as_str() {
                    "paragraph" => DocxStyleType::Paragraph,
                    "character" => DocxStyleType::Character,
                    "table" => DocxStyleType::Table,
                    "numbering" => DocxStyleType::Numbering,
                    _ => DocxStyleType::Paragraph,
                };
            }
            b"w:default" | b"default" => {
                is_default = attr.value.as_ref() == b"1" || attr.value.as_ref() == b"true";
            }
            _ => {}
        }
    }
    
    DocxStyle {
        id,
        name: String::new(),
        style_type,
        based_on: None,
        is_default,
        paragraph_props: None,
        run_props: None,
    }
}

// =============================================================================
// NUMBERING PARSER (word/numbering.xml)
// =============================================================================

pub fn parse_numbering(xml: &str) -> ParseResult<Vec<DocxNumbering>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut numberings = Vec::new();
    let mut buf = Vec::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Empty(ref e)) | Ok(Event::Start(ref e)) if e.local_name().as_ref() == b"num" => {
                if let Some(num) = parse_num_element(e) {
                    numberings.push(num);
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(numberings)
}

fn parse_num_element(e: &BytesStart) -> Option<DocxNumbering> {
    let num_id = get_attr(e, b"w:numId")
        .or_else(|| get_attr(e, b"numId"))
        .and_then(|s| s.parse().ok())?;
    
    // Note: abstract_num_id would be parsed from child elements
    Some(DocxNumbering {
        num_id,
        abstract_num_id: 0, // Default, would need deeper parsing
    })
}

// =============================================================================
// COMMENTS PARSER (word/comments.xml)
// =============================================================================

pub fn parse_comments(xml: &str) -> ParseResult<Vec<DocxComment>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut comments = Vec::new();
    let mut buf = Vec::new();
    let mut in_comment = false;
    let mut current_comment: Option<DocxComment> = None;
    let mut current_text = String::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                if name.as_ref() == b"comment" {
                    in_comment = true;
                    let id = get_attr(e, b"w:id")
                        .or_else(|| get_attr(e, b"id"))
                        .and_then(|s| s.parse().ok())
                        .unwrap_or(0);
                    let author = get_attr(e, b"w:author")
                        .or_else(|| get_attr(e, b"author"))
                        .unwrap_or_default();
                    let date = get_attr(e, b"w:date").or_else(|| get_attr(e, b"date"));
                    let initials = get_attr(e, b"w:initials").or_else(|| get_attr(e, b"initials"));
                    
                    current_comment = Some(DocxComment {
                        id,
                        author,
                        date,
                        initials,
                        content: Vec::new(),
                    });
                }
            }
            Ok(Event::Text(ref t)) if in_comment => {
                current_text.push_str(&t.unescape().unwrap_or_default());
            }
            Ok(Event::End(ref e)) => {
                if e.local_name().as_ref() == b"comment" && in_comment {
                    if let Some(mut comment) = current_comment.take() {
                        if !current_text.trim().is_empty() {
                            comment.content.push(DocxParagraph {
                                runs: vec![DocxRun {
                                    text: current_text.clone(),
                                    ..Default::default()
                                }],
                                ..Default::default()
                            });
                        }
                        comments.push(comment);
                    }
                    in_comment = false;
                    current_text.clear();
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(comments)
}

// =============================================================================
// FOOTNOTES PARSER (word/footnotes.xml)
// =============================================================================

pub fn parse_footnotes(xml: &str) -> ParseResult<Vec<DocxFootnote>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut footnotes = Vec::new();
    let mut buf = Vec::new();
    let mut in_footnote = false;
    let mut current_footnote: Option<DocxFootnote> = None;
    let mut current_text = String::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                if name.as_ref() == b"footnote" {
                    in_footnote = true;
                    let id = get_attr(e, b"w:id")
                        .or_else(|| get_attr(e, b"id"))
                        .and_then(|s| s.parse().ok())
                        .unwrap_or(0);
                    let footnote_type = match get_attr(e, b"w:type").or_else(|| get_attr(e, b"type")).as_deref() {
                        Some("separator") => DocxFootnoteType::Separator,
                        Some("continuationSeparator") => DocxFootnoteType::ContinuationSeparator,
                        _ => DocxFootnoteType::Normal,
                    };
                    
                    current_footnote = Some(DocxFootnote {
                        id,
                        footnote_type,
                        content: Vec::new(),
                    });
                }
            }
            Ok(Event::Text(ref t)) if in_footnote => {
                current_text.push_str(&t.unescape().unwrap_or_default());
            }
            Ok(Event::End(ref e)) => {
                if e.local_name().as_ref() == b"footnote" && in_footnote {
                    if let Some(mut footnote) = current_footnote.take() {
                        if !current_text.trim().is_empty() {
                            footnote.content.push(DocxElement::Paragraph(DocxParagraph {
                                runs: vec![DocxRun {
                                    text: current_text.clone(),
                                    ..Default::default()
                                }],
                                ..Default::default()
                            }));
                        }
                        footnotes.push(footnote);
                    }
                    in_footnote = false;
                    current_text.clear();
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(footnotes)
}

// =============================================================================
// DOCUMENT BODY PARSER (word/document.xml)
// =============================================================================

pub fn parse_document_body(xml: &str, rels: &[DocxRelationship]) -> ParseResult<Vec<DocxElement>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let rels_map: HashMap<String, &DocxRelationship> = rels.iter()
        .map(|r| (r.id.clone(), r))
        .collect();
    
    let mut elements = Vec::new();
    let mut buf = Vec::new();
    
    // Parser state
    let mut in_body = false;
    let mut in_paragraph = false;
    let mut in_run = false;
    let mut in_table = false;
    let mut in_table_row = false;
    let mut in_table_cell = false;
    let mut in_hyperlink = false;
    
    let mut current_paragraph = DocxParagraph::default();
    let mut current_run = DocxRun::default();
    let mut current_table = DocxTable::default();
    let mut current_row = DocxTableRow::default();
    let mut current_cell = DocxTableCell::default();
    let mut current_hyperlink_id: Option<String> = None;
    
    // Nested table/cell handling
    let mut table_stack: Vec<DocxTable> = Vec::new();
    let mut row_stack: Vec<DocxTableRow> = Vec::new();
    let mut cell_stack: Vec<DocxTableCell> = Vec::new();
    let mut cell_paragraphs: Vec<DocxParagraph> = Vec::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"body" => in_body = true,
                    b"p" if in_body => {
                        in_paragraph = true;
                        current_paragraph = DocxParagraph::default();
                        
                        // Parse paragraph properties from attributes and child elements
                    }
                    b"pPr" if in_paragraph => {
                        // Paragraph properties - handled in nested events
                    }
                    b"pStyle" if in_paragraph => {
                        current_paragraph.style_id = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                    }
                    b"numPr" if in_paragraph => {
                        // Start of numbering properties
                    }
                    b"ilvl" if in_paragraph => {
                        if let Some(level) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")).and_then(|s| s.parse().ok()) {
                            if current_paragraph.numbering.is_none() {
                                current_paragraph.numbering = Some(DocxNumRef { num_id: 0, level });
                            } else if let Some(ref mut num) = current_paragraph.numbering {
                                num.level = level;
                            }
                        }
                    }
                    b"numId" if in_paragraph => {
                        if let Some(num_id) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")).and_then(|s| s.parse().ok()) {
                            if current_paragraph.numbering.is_none() {
                                current_paragraph.numbering = Some(DocxNumRef { num_id, level: 0 });
                            } else if let Some(ref mut num) = current_paragraph.numbering {
                                num.num_id = num_id;
                            }
                        }
                    }
                    b"jc" if in_paragraph => {
                        if let Some(val) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")) {
                            current_paragraph.alignment = Some(match val.as_str() {
                                "left" | "start" => DocxAlignment::Left,
                                "center" => DocxAlignment::Center,
                                "right" | "end" => DocxAlignment::Right,
                                "both" | "justify" => DocxAlignment::Justify,
                                "distribute" => DocxAlignment::Distribute,
                                _ => DocxAlignment::Left,
                            });
                        }
                    }
                    b"r" if in_paragraph => {
                        in_run = true;
                        current_run = DocxRun::default();
                        if let Some(ref hl_id) = current_hyperlink_id {
                            current_run.hyperlink_id = Some(hl_id.clone());
                        }
                    }
                    b"hyperlink" if in_paragraph => {
                        in_hyperlink = true;
                        current_hyperlink_id = get_attr(e, b"r:id");
                    }
                    b"rPr" if in_run => {
                        // Run properties - handled in nested events
                    }
                    b"b" if in_run => {
                        // Check if it's not explicitly "false"
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.bold = val.as_deref() != Some("0") && val.as_deref() != Some("false");
                    }
                    b"i" if in_run => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.italic = val.as_deref() != Some("0") && val.as_deref() != Some("false");
                    }
                    b"u" if in_run => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.underline = val.as_deref() != Some("none");
                    }
                    b"strike" if in_run => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.strike = val.as_deref() != Some("0") && val.as_deref() != Some("false");
                    }
                    b"dstrike" if in_run => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.double_strike = val.as_deref() != Some("0") && val.as_deref() != Some("false");
                    }
                    b"vertAlign" if in_run => {
                        if let Some(val) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")) {
                            match val.as_str() {
                                "superscript" => current_run.superscript = true,
                                "subscript" => current_run.subscript = true,
                                _ => {}
                            }
                        }
                    }
                    b"rFonts" if in_run => {
                        current_run.font_name = get_attr(e, b"w:ascii")
                            .or_else(|| get_attr(e, b"ascii"))
                            .or_else(|| get_attr(e, b"w:hAnsi"))
                            .or_else(|| get_attr(e, b"hAnsi"));
                    }
                    b"sz" if in_run => {
                        current_run.font_size = get_attr(e, b"w:val")
                            .or_else(|| get_attr(e, b"val"))
                            .and_then(|s| s.parse().ok());
                    }
                    b"color" if in_run => {
                        current_run.color = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                    }
                    b"highlight" if in_run => {
                        current_run.highlight = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                    }
                    b"rStyle" if in_run => {
                        current_run.style_id = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                    }
                    b"tbl" if in_body => {
                        // Push current table if nested
                        if in_table {
                            table_stack.push(std::mem::take(&mut current_table));
                        }
                        in_table = true;
                        current_table = DocxTable::default();
                    }
                    b"tr" if in_table => {
                        if in_table_row {
                            row_stack.push(std::mem::take(&mut current_row));
                        }
                        in_table_row = true;
                        current_row = DocxTableRow::default();
                        
                        // Check for header row
                        // (would be in child tblHeader element)
                    }
                    b"tc" if in_table_row => {
                        if in_table_cell {
                            cell_stack.push(std::mem::take(&mut current_cell));
                        }
                        in_table_cell = true;
                        current_cell = DocxTableCell::default();
                        current_cell.col_span = 1;
                        current_cell.row_span = 1;
                        cell_paragraphs.clear();
                    }
                    b"gridSpan" if in_table_cell => {
                        if let Some(span) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")).and_then(|s| s.parse().ok()) {
                            current_cell.col_span = span;
                        }
                    }
                    b"vMerge" if in_table_cell => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        if val.as_deref() == Some("restart") {
                            // Start of vertical merge
                            current_cell.row_span = 1; // Will be updated later
                        }
                        // "continue" means this cell is merged with above
                    }
                    b"shd" if in_table_cell => {
                        current_cell.shading = get_attr(e, b"w:fill").or_else(|| get_attr(e, b"fill"));
                    }
                    b"vAlign" if in_table_cell => {
                        if let Some(val) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")) {
                            current_cell.vertical_align = Some(match val.as_str() {
                                "top" => DocxVerticalAlign::Top,
                                "center" => DocxVerticalAlign::Center,
                                "bottom" => DocxVerticalAlign::Bottom,
                                _ => DocxVerticalAlign::Top,
                            });
                        }
                    }
                    b"br" if in_run => {
                        let break_type = match get_attr(e, b"w:type").or_else(|| get_attr(e, b"type")).as_deref() {
                            Some("page") => DocxBreakType::Page,
                            Some("column") => DocxBreakType::Column,
                            Some("textWrapping") => DocxBreakType::TextWrapping,
                            _ => DocxBreakType::Line,
                        };
                        current_run.break_type = Some(break_type);
                    }
                    b"tab" if in_run => {
                        current_run.tab = true;
                    }
                    b"bookmarkStart" if in_paragraph => {
                        if let (Some(id), Some(name)) = (
                            get_attr(e, b"w:id").or_else(|| get_attr(e, b"id")).and_then(|s| s.parse().ok()),
                            get_attr(e, b"w:name").or_else(|| get_attr(e, b"name"))
                        ) {
                            current_paragraph.bookmarks.push(DocxBookmark { id, name });
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"b" if in_run => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.bold = val.as_deref() != Some("0") && val.as_deref() != Some("false");
                    }
                    b"i" if in_run => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.italic = val.as_deref() != Some("0") && val.as_deref() != Some("false");
                    }
                    b"u" if in_run => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.underline = val.as_deref() != Some("none");
                    }
                    b"strike" if in_run => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.strike = val.as_deref() != Some("0") && val.as_deref() != Some("false");
                    }
                    b"pStyle" if in_paragraph => {
                        current_paragraph.style_id = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                    }
                    b"sz" if in_run => {
                        current_run.font_size = get_attr(e, b"w:val")
                            .or_else(|| get_attr(e, b"val"))
                            .and_then(|s| s.parse().ok());
                    }
                    b"color" if in_run => {
                        current_run.color = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                    }
                    b"rFonts" if in_run => {
                        current_run.font_name = get_attr(e, b"w:ascii")
                            .or_else(|| get_attr(e, b"ascii"))
                            .or_else(|| get_attr(e, b"w:hAnsi"))
                            .or_else(|| get_attr(e, b"hAnsi"));
                    }
                    b"br" if in_run => {
                        let break_type = match get_attr(e, b"w:type").or_else(|| get_attr(e, b"type")).as_deref() {
                            Some("page") => DocxBreakType::Page,
                            Some("column") => DocxBreakType::Column,
                            Some("textWrapping") => DocxBreakType::TextWrapping,
                            _ => DocxBreakType::Line,
                        };
                        current_run.break_type = Some(break_type);
                    }
                    b"tab" if in_run => {
                        current_run.tab = true;
                    }
                    b"gridSpan" if in_table_cell => {
                        if let Some(span) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")).and_then(|s| s.parse().ok()) {
                            current_cell.col_span = span;
                        }
                    }
                    b"shd" if in_table_cell => {
                        current_cell.shading = get_attr(e, b"w:fill").or_else(|| get_attr(e, b"fill"));
                    }
                    b"jc" if in_paragraph => {
                        if let Some(val) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")) {
                            current_paragraph.alignment = Some(match val.as_str() {
                                "left" | "start" => DocxAlignment::Left,
                                "center" => DocxAlignment::Center,
                                "right" | "end" => DocxAlignment::Right,
                                "both" | "justify" => DocxAlignment::Justify,
                                "distribute" => DocxAlignment::Distribute,
                                _ => DocxAlignment::Left,
                            });
                        }
                    }
                    b"ilvl" if in_paragraph => {
                        if let Some(level) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")).and_then(|s| s.parse().ok()) {
                            if current_paragraph.numbering.is_none() {
                                current_paragraph.numbering = Some(DocxNumRef { num_id: 0, level });
                            } else if let Some(ref mut num) = current_paragraph.numbering {
                                num.level = level;
                            }
                        }
                    }
                    b"numId" if in_paragraph => {
                        if let Some(num_id) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")).and_then(|s| s.parse().ok()) {
                            if current_paragraph.numbering.is_none() {
                                current_paragraph.numbering = Some(DocxNumRef { num_id, level: 0 });
                            } else if let Some(ref mut num) = current_paragraph.numbering {
                                num.num_id = num_id;
                            }
                        }
                    }
                    b"bookmarkStart" if in_paragraph => {
                        if let (Some(id), Some(name)) = (
                            get_attr(e, b"w:id").or_else(|| get_attr(e, b"id")).and_then(|s| s.parse().ok()),
                            get_attr(e, b"w:name").or_else(|| get_attr(e, b"name"))
                        ) {
                            current_paragraph.bookmarks.push(DocxBookmark { id, name });
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::Text(ref t)) if in_run => {
                current_run.text.push_str(&t.unescape().unwrap_or_default());
            }
            Ok(Event::End(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"body" => in_body = false,
                    b"p" if in_paragraph => {
                        if in_table_cell {
                            cell_paragraphs.push(std::mem::take(&mut current_paragraph));
                        } else {
                            elements.push(DocxElement::Paragraph(std::mem::take(&mut current_paragraph)));
                        }
                        in_paragraph = false;
                    }
                    b"r" if in_run => {
                        // Handle tabs and breaks
                        if current_run.tab {
                            current_run.text.push('\t');
                            current_run.tab = false;
                        }
                        if let Some(break_type) = &current_run.break_type {
                            match break_type {
                                DocxBreakType::Line => current_run.text.push('\n'),
                                DocxBreakType::Page => {
                                    // Could emit a page break element
                                }
                                _ => {}
                            }
                        }
                        
                        if !current_run.text.is_empty() || current_run.break_type.is_some() {
                            current_paragraph.runs.push(std::mem::take(&mut current_run));
                        }
                        current_run = DocxRun::default();
                        if let Some(ref hl_id) = current_hyperlink_id {
                            current_run.hyperlink_id = Some(hl_id.clone());
                        }
                        in_run = false;
                    }
                    b"hyperlink" if in_hyperlink => {
                        in_hyperlink = false;
                        current_hyperlink_id = None;
                    }
                    b"tc" if in_table_cell => {
                        // Add collected paragraphs to cell
                        for p in cell_paragraphs.drain(..) {
                            current_cell.content.push(DocxElement::Paragraph(p));
                        }
                        
                        current_row.cells.push(std::mem::take(&mut current_cell));
                        
                        // Restore from stack if nested
                        if let Some(stacked) = cell_stack.pop() {
                            current_cell = stacked;
                        } else {
                            in_table_cell = false;
                        }
                    }
                    b"tr" if in_table_row => {
                        current_table.rows.push(std::mem::take(&mut current_row));
                        
                        if let Some(stacked) = row_stack.pop() {
                            current_row = stacked;
                        } else {
                            in_table_row = false;
                        }
                    }
                    b"tbl" if in_table => {
                        if in_table_cell {
                            // Nested table - add to cell content
                            current_cell.content.push(DocxElement::Table(std::mem::take(&mut current_table)));
                        } else {
                            elements.push(DocxElement::Table(std::mem::take(&mut current_table)));
                        }
                        
                        if let Some(stacked) = table_stack.pop() {
                            current_table = stacked;
                        } else {
                            in_table = false;
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error at position {}: {}", reader.buffer_position(), e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(elements)
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

fn get_attr(e: &BytesStart, name: &[u8]) -> Option<String> {
    e.attributes()
        .flatten()
        .find(|a| a.key.as_ref() == name)
        .map(|a| String::from_utf8_lossy(&a.value).to_string())
}

// =============================================================================
// SETTINGS PARSER (word/settings.xml)
// =============================================================================

pub fn parse_settings(xml: &str) -> ParseResult<DocxSettings> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut settings = DocxSettings::default();
    let mut buf = Vec::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Empty(ref e)) | Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"zoom" => {
                        settings.zoom = get_attr(e, b"w:percent")
                            .or_else(|| get_attr(e, b"percent"))
                            .and_then(|s| s.parse().ok());
                    }
                    b"displayBackgroundShape" => {
                        settings.display_background_shape = true;
                    }
                    b"embedTrueTypeFonts" => {
                        settings.embed_true_type_fonts = true;
                    }
                    b"embedSystemFonts" => {
                        settings.embed_system_fonts = true;
                    }
                    b"saveSubsetFonts" => {
                        settings.save_subset_fonts = true;
                    }
                    b"defaultTabStop" => {
                        settings.default_tab_stop = get_attr(e, b"w:val")
                            .or_else(|| get_attr(e, b"val"))
                            .and_then(|s| s.parse().ok());
                    }
                    b"autoHyphenation" => {
                        settings.auto_hyphenation = true;
                    }
                    b"consecutiveHyphenLimit" => {
                        settings.consecutive_hyphen_limit = get_attr(e, b"w:val")
                            .or_else(|| get_attr(e, b"val"))
                            .and_then(|s| s.parse().ok());
                    }
                    b"evenAndOddHeaders" => {
                        settings.even_and_odd_headers = true;
                    }
                    b"bookFoldPrinting" => {
                        settings.book_fold_printing = true;
                    }
                    b"trackRevisions" => {
                        settings.track_revisions = true;
                    }
                    _ => {}
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(settings)
}

// =============================================================================
// NUMBERING FULL PARSER (word/numbering.xml)
// =============================================================================

pub fn parse_numbering_full(xml: &str) -> ParseResult<(Vec<DocxNumbering>, Vec<DocxAbstractNum>)> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut numberings = Vec::new();
    let mut abstract_nums = Vec::new();
    let mut buf = Vec::new();
    
    let mut in_abstract_num = false;
    let mut current_abstract: Option<DocxAbstractNum> = None;
    let mut current_level: Option<DocxNumLevel> = None;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"abstractNum" => {
                        in_abstract_num = true;
                        let id = get_attr(e, b"w:abstractNumId")
                            .or_else(|| get_attr(e, b"abstractNumId"))
                            .and_then(|s| s.parse().ok())
                            .unwrap_or(0);
                        current_abstract = Some(DocxAbstractNum {
                            abstract_num_id: id,
                            levels: Vec::new(),
                        });
                    }
                    b"lvl" if in_abstract_num => {
                        let level = get_attr(e, b"w:ilvl")
                            .or_else(|| get_attr(e, b"ilvl"))
                            .and_then(|s| s.parse().ok())
                            .unwrap_or(0);
                        current_level = Some(DocxNumLevel {
                            level,
                            format: DocxNumFormat::Decimal,
                            text: String::new(),
                            start: 1,
                            alignment: None,
                            paragraph_props: None,
                            run_props: None,
                        });
                    }
                    b"num" => {
                        let num_id = get_attr(e, b"w:numId")
                            .or_else(|| get_attr(e, b"numId"))
                            .and_then(|s| s.parse().ok())
                            .unwrap_or(0);
                        numberings.push(DocxNumbering {
                            num_id,
                            abstract_num_id: 0, // Will be filled by abstractNumId element
                        });
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"start" if current_level.is_some() => {
                        if let Some(ref mut level) = current_level {
                            level.start = get_attr(e, b"w:val")
                                .or_else(|| get_attr(e, b"val"))
                                .and_then(|s| s.parse().ok())
                                .unwrap_or(1);
                        }
                    }
                    b"numFmt" if current_level.is_some() => {
                        if let Some(ref mut level) = current_level {
                            let fmt = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")).unwrap_or_default();
                            level.format = match fmt.as_str() {
                                "decimal" => DocxNumFormat::Decimal,
                                "decimalZero" => DocxNumFormat::DecimalZero,
                                "upperRoman" => DocxNumFormat::UpperRoman,
                                "lowerRoman" => DocxNumFormat::LowerRoman,
                                "upperLetter" => DocxNumFormat::UpperLetter,
                                "lowerLetter" => DocxNumFormat::LowerLetter,
                                "bullet" => DocxNumFormat::Bullet,
                                "none" => DocxNumFormat::None,
                                _ => DocxNumFormat::Other(fmt),
                            };
                        }
                    }
                    b"lvlText" if current_level.is_some() => {
                        if let Some(ref mut level) = current_level {
                            level.text = get_attr(e, b"w:val")
                                .or_else(|| get_attr(e, b"val"))
                                .unwrap_or_default();
                        }
                    }
                    b"abstractNumId" => {
                        // For w:num elements
                        if let Some(last) = numberings.last_mut() {
                            last.abstract_num_id = get_attr(e, b"w:val")
                                .or_else(|| get_attr(e, b"val"))
                                .and_then(|s| s.parse().ok())
                                .unwrap_or(0);
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::End(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"lvl" if in_abstract_num => {
                        if let Some(level) = current_level.take() {
                            if let Some(ref mut abs) = current_abstract {
                                abs.levels.push(level);
                            }
                        }
                    }
                    b"abstractNum" => {
                        if let Some(abs) = current_abstract.take() {
                            abstract_nums.push(abs);
                        }
                        in_abstract_num = false;
                    }
                    _ => {}
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok((numberings, abstract_nums))
}

// =============================================================================
// ENDNOTES PARSER (word/endnotes.xml)
// =============================================================================

pub fn parse_endnotes(xml: &str) -> ParseResult<Vec<DocxEndnote>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut endnotes = Vec::new();
    let mut buf = Vec::new();
    let mut in_endnote = false;
    let mut current_endnote: Option<DocxEndnote> = None;
    let mut current_text = String::new();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                if name.as_ref() == b"endnote" {
                    in_endnote = true;
                    let id = get_attr(e, b"w:id")
                        .or_else(|| get_attr(e, b"id"))
                        .and_then(|s| s.parse().ok())
                        .unwrap_or(0);
                    
                    current_endnote = Some(DocxEndnote {
                        id,
                        content: Vec::new(),
                    });
                }
            }
            Ok(Event::Text(ref t)) if in_endnote => {
                current_text.push_str(&t.unescape().unwrap_or_default());
            }
            Ok(Event::End(ref e)) => {
                if e.local_name().as_ref() == b"endnote" && in_endnote {
                    if let Some(mut endnote) = current_endnote.take() {
                        if !current_text.trim().is_empty() {
                            endnote.content.push(DocxElement::Paragraph(DocxParagraph {
                                runs: vec![DocxRun {
                                    text: current_text.clone(),
                                    ..Default::default()
                                }],
                                ..Default::default()
                            }));
                        }
                        // Skip separator endnotes (type="separator" or type="continuationSeparator")
                        if endnote.id > 0 {
                            endnotes.push(endnote);
                        }
                    }
                    in_endnote = false;
                    current_text.clear();
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(endnotes)
}

// =============================================================================
// HEADER/FOOTER PARSER (word/header*.xml, word/footer*.xml)
// =============================================================================

pub fn parse_header_footer(xml: &str, id: &str) -> ParseResult<DocxHeaderFooter> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut content = Vec::new();
    let mut buf = Vec::new();
    let mut in_paragraph = false;
    let mut current_paragraph = DocxParagraph::default();
    let mut current_run = DocxRun::default();
    let mut in_run = false;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"p" => {
                        in_paragraph = true;
                        current_paragraph = DocxParagraph::default();
                    }
                    b"r" if in_paragraph => {
                        in_run = true;
                        current_run = DocxRun::default();
                    }
                    b"pStyle" if in_paragraph => {
                        current_paragraph.style_id = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                    }
                    b"b" if in_run => {
                        current_run.bold = true;
                    }
                    b"i" if in_run => {
                        current_run.italic = true;
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"pStyle" if in_paragraph => {
                        current_paragraph.style_id = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                    }
                    b"b" if in_run => {
                        current_run.bold = true;
                    }
                    b"i" if in_run => {
                        current_run.italic = true;
                    }
                    _ => {}
                }
            }
            Ok(Event::Text(ref t)) if in_run => {
                current_run.text.push_str(&t.unescape().unwrap_or_default());
            }
            Ok(Event::End(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"r" if in_run => {
                        if !current_run.text.is_empty() {
                            current_paragraph.runs.push(std::mem::take(&mut current_run));
                        }
                        in_run = false;
                    }
                    b"p" if in_paragraph => {
                        content.push(DocxElement::Paragraph(std::mem::take(&mut current_paragraph)));
                        in_paragraph = false;
                    }
                    _ => {}
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    Ok(DocxHeaderFooter {
        id: id.to_string(),
        content,
    })
}

// =============================================================================
// THEME PARSER (word/theme/theme1.xml)
// =============================================================================

pub fn parse_theme(xml: &str) -> ParseResult<Option<DocxTheme>> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut theme_name = String::new();
    let mut color_scheme_name = String::new();
    let mut colors: HashMap<String, String> = HashMap::new();
    let mut font_scheme_name = String::new();
    let mut major_latin = String::new();
    let mut minor_latin = String::new();
    let mut buf = Vec::new();
    
    let mut in_clr_scheme = false;
    let mut in_font_scheme = false;
    let mut in_major_font = false;
    let mut in_minor_font = false;
    let mut current_color_name: Option<String> = None;
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"theme" => {
                        theme_name = get_attr(e, b"name").unwrap_or_default();
                    }
                    b"clrScheme" => {
                        in_clr_scheme = true;
                        color_scheme_name = get_attr(e, b"name").unwrap_or_default();
                    }
                    b"fontScheme" => {
                        in_font_scheme = true;
                        font_scheme_name = get_attr(e, b"name").unwrap_or_default();
                    }
                    b"majorFont" if in_font_scheme => {
                        in_major_font = true;
                    }
                    b"minorFont" if in_font_scheme => {
                        in_minor_font = true;
                    }
                    b"dk1" | b"lt1" | b"dk2" | b"lt2" | 
                    b"accent1" | b"accent2" | b"accent3" | b"accent4" | 
                    b"accent5" | b"accent6" | b"hlink" | b"folHlink" if in_clr_scheme => {
                        current_color_name = Some(String::from_utf8_lossy(name.as_ref()).to_string());
                    }
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"srgbClr" if current_color_name.is_some() => {
                        if let Some(color_name) = current_color_name.take() {
                            if let Some(val) = get_attr(e, b"val") {
                                colors.insert(color_name, val);
                            }
                        }
                    }
                    b"latin" => {
                        if let Some(typeface) = get_attr(e, b"typeface") {
                            if in_major_font {
                                major_latin = typeface;
                            } else if in_minor_font {
                                minor_latin = typeface;
                            }
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::End(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"clrScheme" => {
                        in_clr_scheme = false;
                    }
                    b"fontScheme" => {
                        in_font_scheme = false;
                    }
                    b"majorFont" => {
                        in_major_font = false;
                    }
                    b"minorFont" => {
                        in_minor_font = false;
                    }
                    b"dk1" | b"lt1" | b"dk2" | b"lt2" | 
                    b"accent1" | b"accent2" | b"accent3" | b"accent4" | 
                    b"accent5" | b"accent6" | b"hlink" | b"folHlink" => {
                        current_color_name = None;
                    }
                    _ => {}
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    if theme_name.is_empty() && colors.is_empty() {
        return Ok(None);
    }
    
    Ok(Some(DocxTheme {
        name: theme_name,
        color_scheme: DocxColorScheme {
            name: color_scheme_name,
            colors,
        },
        font_scheme: DocxFontScheme {
            name: font_scheme_name,
            major_font: DocxThemeFont {
                latin: major_latin,
                east_asian: None,
                complex_script: None,
            },
            minor_font: DocxThemeFont {
                latin: minor_latin,
                east_asian: None,
                complex_script: None,
            },
        },
    }))
}

// =============================================================================
// DOCUMENT FULL PARSER (with sections, revisions, drawings, SDT, math)
// =============================================================================

pub fn parse_document_full(
    xml: &str, 
    rels: &[DocxRelationship]
) -> ParseResult<(Vec<DocxElement>, Vec<DocxSection>, DocxRevisionInfo)> {
    let mut reader = Reader::from_str(xml);
    reader.config_mut().trim_text(true);
    
    let mut elements = Vec::new();
    let mut sections = Vec::new();
    let mut revisions = DocxRevisionInfo::default();
    let mut buf = Vec::new();
    
    // Current section accumulator
    let mut current_section_elements = Vec::new();
    let mut current_section_props = DocxSectionProperties::default();
    
    // State tracking
    let mut in_body = false;
    let mut in_paragraph = false;
    let mut in_run = false;
    let mut in_table = false;
    let mut in_revision_ins = false;
    let mut in_revision_del = false;
    let mut in_sdt = false;
    let mut in_drawing = false;
    let mut in_math = false;
    let mut in_sect_pr = false;
    let mut in_field = false;
    
    let mut current_paragraph = DocxParagraph::default();
    let mut current_run = DocxRun::default();
    let mut current_table = DocxTable::default();
    let mut current_row = DocxTableRow::default();
    let mut current_cell = DocxTableCell::default();
    
    // Revision tracking
    let mut current_revision: Option<DocxRevision> = None;
    let mut revision_content: Vec<DocxElement> = Vec::new();
    
    // Field tracking
    let mut field_instruction = String::new();
    
    // Build rels map for hyperlinks
    let rels_map: HashMap<String, &DocxRelationship> = rels.iter()
        .map(|r| (r.id.clone(), r))
        .collect();
    
    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"body" => in_body = true,
                    
                    // Sections
                    b"sectPr" if in_body => {
                        in_sect_pr = true;
                    }
                    b"pgSz" if in_sect_pr => {
                        current_section_props.page_size = Some(DocxPageSize {
                            width: get_attr(e, b"w:w").or_else(|| get_attr(e, b"w"))
                                .and_then(|s| s.parse().ok()).unwrap_or(12240),
                            height: get_attr(e, b"w:h").or_else(|| get_attr(e, b"h"))
                                .and_then(|s| s.parse().ok()).unwrap_or(15840),
                            code: get_attr(e, b"w:code").and_then(|s| s.parse().ok()),
                        });
                        let orient = get_attr(e, b"w:orient").or_else(|| get_attr(e, b"orient"));
                        current_section_props.orientation = match orient.as_deref() {
                            Some("landscape") => DocxOrientation::Landscape,
                            _ => DocxOrientation::Portrait,
                        };
                    }
                    b"pgMar" if in_sect_pr => {
                        current_section_props.page_margins = Some(DocxPageMargins {
                            top: get_attr(e, b"w:top").and_then(|s| s.parse().ok()).unwrap_or(1440),
                            bottom: get_attr(e, b"w:bottom").and_then(|s| s.parse().ok()).unwrap_or(1440),
                            left: get_attr(e, b"w:left").and_then(|s| s.parse().ok()).unwrap_or(1440),
                            right: get_attr(e, b"w:right").and_then(|s| s.parse().ok()).unwrap_or(1440),
                            header: get_attr(e, b"w:header").and_then(|s| s.parse().ok()).unwrap_or(720),
                            footer: get_attr(e, b"w:footer").and_then(|s| s.parse().ok()).unwrap_or(720),
                            gutter: get_attr(e, b"w:gutter").and_then(|s| s.parse().ok()).unwrap_or(0),
                        });
                    }
                    b"cols" if in_sect_pr => {
                        current_section_props.columns = Some(DocxColumns {
                            num: get_attr(e, b"w:num").and_then(|s| s.parse().ok()).unwrap_or(1),
                            space: get_attr(e, b"w:space").and_then(|s| s.parse().ok()),
                            equal_width: get_attr(e, b"w:equalWidth").as_deref() != Some("0"),
                            columns: Vec::new(),
                            separator: get_attr(e, b"w:sep").as_deref() == Some("1"),
                        });
                    }
                    b"type" if in_sect_pr => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_section_props.section_type = Some(match val.as_deref() {
                            Some("continuous") => DocxSectionType::Continuous,
                            Some("evenPage") => DocxSectionType::EvenPage,
                            Some("oddPage") => DocxSectionType::OddPage,
                            Some("nextColumn") => DocxSectionType::NextColumn,
                            _ => DocxSectionType::NextPage,
                        });
                    }
                    b"headerReference" if in_sect_pr => {
                        if let Some(rel_id) = get_attr(e, b"r:id") {
                            let ref_type = match get_attr(e, b"w:type").as_deref() {
                                Some("first") => DocxHeaderFooterType::First,
                                Some("even") => DocxHeaderFooterType::Even,
                                _ => DocxHeaderFooterType::Default,
                            };
                            current_section_props.header_refs.push(DocxHeaderFooterRef { ref_type, rel_id });
                        }
                    }
                    b"footerReference" if in_sect_pr => {
                        if let Some(rel_id) = get_attr(e, b"r:id") {
                            let ref_type = match get_attr(e, b"w:type").as_deref() {
                                Some("first") => DocxHeaderFooterType::First,
                                Some("even") => DocxHeaderFooterType::Even,
                                _ => DocxHeaderFooterType::Default,
                            };
                            current_section_props.footer_refs.push(DocxHeaderFooterRef { ref_type, rel_id });
                        }
                    }
                    
                    // Track Changes - Insertions
                    b"ins" if in_body => {
                        in_revision_ins = true;
                        revisions.tracking_enabled = true;
                        current_revision = Some(DocxRevision {
                            id: get_attr(e, b"w:id").and_then(|s| s.parse().ok()).unwrap_or(0),
                            author: get_attr(e, b"w:author").unwrap_or_default(),
                            date: get_attr(e, b"w:date"),
                            revision_type: DocxRevisionType::Insert,
                            content: Vec::new(),
                        });
                    }
                    
                    // Track Changes - Deletions
                    b"del" if in_body => {
                        in_revision_del = true;
                        revisions.tracking_enabled = true;
                        current_revision = Some(DocxRevision {
                            id: get_attr(e, b"w:id").and_then(|s| s.parse().ok()).unwrap_or(0),
                            author: get_attr(e, b"w:author").unwrap_or_default(),
                            date: get_attr(e, b"w:date"),
                            revision_type: DocxRevisionType::Delete,
                            content: Vec::new(),
                        });
                    }
                    
                    // Content Controls (SDT)
                    b"sdt" if in_body => {
                        in_sdt = true;
                    }
                    
                    // Drawings
                    b"drawing" if in_run => {
                        in_drawing = true;
                    }
                    
                    // Math
                    b"oMath" => {
                        in_math = true;
                    }
                    
                    // Fields
                    b"fldChar" if in_run => {
                        let fld_type = get_attr(e, b"w:fldCharType").or_else(|| get_attr(e, b"fldCharType"));
                        match fld_type.as_deref() {
                            Some("begin") => {
                                in_field = true;
                                field_instruction.clear();
                            }
                            Some("end") => {
                                in_field = false;
                            }
                            _ => {}
                        }
                    }
                    
                    // Paragraphs
                    b"p" if in_body && !in_sect_pr => {
                        in_paragraph = true;
                        current_paragraph = DocxParagraph::default();
                    }
                    b"pStyle" if in_paragraph => {
                        current_paragraph.style_id = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                    }
                    b"jc" if in_paragraph => {
                        if let Some(val) = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val")) {
                            current_paragraph.alignment = Some(match val.as_str() {
                                "center" => DocxAlignment::Center,
                                "right" | "end" => DocxAlignment::Right,
                                "both" | "justify" => DocxAlignment::Justify,
                                "distribute" => DocxAlignment::Distribute,
                                _ => DocxAlignment::Left,
                            });
                        }
                    }
                    b"numPr" if in_paragraph => {}
                    b"ilvl" if in_paragraph => {
                        if let Some(level) = get_attr(e, b"w:val").and_then(|s| s.parse().ok()) {
                            if current_paragraph.numbering.is_none() {
                                current_paragraph.numbering = Some(DocxNumRef { num_id: 0, level });
                            } else if let Some(ref mut num) = current_paragraph.numbering {
                                num.level = level;
                            }
                        }
                    }
                    b"numId" if in_paragraph => {
                        if let Some(num_id) = get_attr(e, b"w:val").and_then(|s| s.parse().ok()) {
                            if current_paragraph.numbering.is_none() {
                                current_paragraph.numbering = Some(DocxNumRef { num_id, level: 0 });
                            } else if let Some(ref mut num) = current_paragraph.numbering {
                                num.num_id = num_id;
                            }
                        }
                    }
                    
                    // Runs
                    b"r" if in_paragraph => {
                        in_run = true;
                        current_run = DocxRun::default();
                    }
                    b"b" if in_run => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.bold = val.as_deref() != Some("0") && val.as_deref() != Some("false");
                    }
                    b"i" if in_run => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.italic = val.as_deref() != Some("0") && val.as_deref() != Some("false");
                    }
                    b"u" if in_run => {
                        let val = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                        current_run.underline = val.as_deref() != Some("none");
                    }
                    b"strike" if in_run => {
                        current_run.strike = true;
                    }
                    b"dstrike" if in_run => {
                        current_run.double_strike = true;
                    }
                    b"vertAlign" if in_run => {
                        match get_attr(e, b"w:val").as_deref() {
                            Some("superscript") => current_run.superscript = true,
                            Some("subscript") => current_run.subscript = true,
                            _ => {}
                        }
                    }
                    b"rFonts" if in_run => {
                        current_run.font_name = get_attr(e, b"w:ascii")
                            .or_else(|| get_attr(e, b"w:hAnsi"))
                            .or_else(|| get_attr(e, b"ascii"));
                    }
                    b"sz" if in_run => {
                        current_run.font_size = get_attr(e, b"w:val").and_then(|s| s.parse().ok());
                    }
                    b"color" if in_run => {
                        current_run.color = get_attr(e, b"w:val");
                    }
                    b"highlight" if in_run => {
                        current_run.highlight = get_attr(e, b"w:val");
                    }
                    
                    // Tables
                    b"tbl" if in_body => {
                        in_table = true;
                        current_table = DocxTable::default();
                    }
                    b"tr" if in_table => {
                        current_row = DocxTableRow::default();
                    }
                    b"tc" if in_table => {
                        current_cell = DocxTableCell::default();
                        current_cell.col_span = 1;
                        current_cell.row_span = 1;
                    }
                    b"gridSpan" if in_table => {
                        if let Some(span) = get_attr(e, b"w:val").and_then(|s| s.parse().ok()) {
                            current_cell.col_span = span;
                        }
                    }
                    b"vMerge" if in_table => {
                        let val = get_attr(e, b"w:val");
                        if val.as_deref() == Some("restart") {
                            current_cell.row_span = 1;
                        }
                    }
                    b"shd" if in_table => {
                        current_cell.shading = get_attr(e, b"w:fill");
                    }
                    
                    // Hyperlinks
                    b"hyperlink" if in_paragraph => {
                        if let Some(rel_id) = get_attr(e, b"r:id") {
                            current_run.hyperlink_id = Some(rel_id);
                        }
                    }
                    
                    _ => {}
                }
            }
            Ok(Event::Empty(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    // Handle empty elements similarly
                    b"pStyle" if in_paragraph => {
                        current_paragraph.style_id = get_attr(e, b"w:val").or_else(|| get_attr(e, b"val"));
                    }
                    b"b" if in_run => {
                        let val = get_attr(e, b"w:val");
                        current_run.bold = val.as_deref() != Some("0");
                    }
                    b"i" if in_run => {
                        let val = get_attr(e, b"w:val");
                        current_run.italic = val.as_deref() != Some("0");
                    }
                    b"u" if in_run => {
                        let val = get_attr(e, b"w:val");
                        current_run.underline = val.as_deref() != Some("none");
                    }
                    b"strike" if in_run => {
                        current_run.strike = true;
                    }
                    b"sz" if in_run => {
                        current_run.font_size = get_attr(e, b"w:val").and_then(|s| s.parse().ok());
                    }
                    b"color" if in_run => {
                        current_run.color = get_attr(e, b"w:val");
                    }
                    b"rFonts" if in_run => {
                        current_run.font_name = get_attr(e, b"w:ascii")
                            .or_else(|| get_attr(e, b"w:hAnsi"));
                    }
                    b"jc" if in_paragraph => {
                        if let Some(val) = get_attr(e, b"w:val") {
                            current_paragraph.alignment = Some(match val.as_str() {
                                "center" => DocxAlignment::Center,
                                "right" | "end" => DocxAlignment::Right,
                                "both" | "justify" => DocxAlignment::Justify,
                                _ => DocxAlignment::Left,
                            });
                        }
                    }
                    b"ilvl" if in_paragraph => {
                        if let Some(level) = get_attr(e, b"w:val").and_then(|s| s.parse().ok()) {
                            if current_paragraph.numbering.is_none() {
                                current_paragraph.numbering = Some(DocxNumRef { num_id: 0, level });
                            } else if let Some(ref mut num) = current_paragraph.numbering {
                                num.level = level;
                            }
                        }
                    }
                    b"numId" if in_paragraph => {
                        if let Some(num_id) = get_attr(e, b"w:val").and_then(|s| s.parse().ok()) {
                            if current_paragraph.numbering.is_none() {
                                current_paragraph.numbering = Some(DocxNumRef { num_id, level: 0 });
                            } else if let Some(ref mut num) = current_paragraph.numbering {
                                num.num_id = num_id;
                            }
                        }
                    }
                    b"gridSpan" if in_table => {
                        if let Some(span) = get_attr(e, b"w:val").and_then(|s| s.parse().ok()) {
                            current_cell.col_span = span;
                        }
                    }
                    b"shd" if in_table => {
                        current_cell.shading = get_attr(e, b"w:fill");
                    }
                    b"pgSz" if in_sect_pr => {
                        current_section_props.page_size = Some(DocxPageSize {
                            width: get_attr(e, b"w:w").and_then(|s| s.parse().ok()).unwrap_or(12240),
                            height: get_attr(e, b"w:h").and_then(|s| s.parse().ok()).unwrap_or(15840),
                            code: get_attr(e, b"w:code").and_then(|s| s.parse().ok()),
                        });
                        let orient = get_attr(e, b"w:orient");
                        current_section_props.orientation = match orient.as_deref() {
                            Some("landscape") => DocxOrientation::Landscape,
                            _ => DocxOrientation::Portrait,
                        };
                    }
                    b"pgMar" if in_sect_pr => {
                        current_section_props.page_margins = Some(DocxPageMargins {
                            top: get_attr(e, b"w:top").and_then(|s| s.parse().ok()).unwrap_or(1440),
                            bottom: get_attr(e, b"w:bottom").and_then(|s| s.parse().ok()).unwrap_or(1440),
                            left: get_attr(e, b"w:left").and_then(|s| s.parse().ok()).unwrap_or(1440),
                            right: get_attr(e, b"w:right").and_then(|s| s.parse().ok()).unwrap_or(1440),
                            header: get_attr(e, b"w:header").and_then(|s| s.parse().ok()).unwrap_or(720),
                            footer: get_attr(e, b"w:footer").and_then(|s| s.parse().ok()).unwrap_or(720),
                            gutter: get_attr(e, b"w:gutter").and_then(|s| s.parse().ok()).unwrap_or(0),
                        });
                    }
                    b"cols" if in_sect_pr => {
                        current_section_props.columns = Some(DocxColumns {
                            num: get_attr(e, b"w:num").and_then(|s| s.parse().ok()).unwrap_or(1),
                            space: get_attr(e, b"w:space").and_then(|s| s.parse().ok()),
                            equal_width: get_attr(e, b"w:equalWidth").as_deref() != Some("0"),
                            columns: Vec::new(),
                            separator: get_attr(e, b"w:sep").as_deref() == Some("1"),
                        });
                    }
                    b"type" if in_sect_pr => {
                        let val = get_attr(e, b"w:val");
                        current_section_props.section_type = Some(match val.as_deref() {
                            Some("continuous") => DocxSectionType::Continuous,
                            Some("evenPage") => DocxSectionType::EvenPage,
                            Some("oddPage") => DocxSectionType::OddPage,
                            _ => DocxSectionType::NextPage,
                        });
                    }
                    b"headerReference" if in_sect_pr => {
                        if let Some(rel_id) = get_attr(e, b"r:id") {
                            let ref_type = match get_attr(e, b"w:type").as_deref() {
                                Some("first") => DocxHeaderFooterType::First,
                                Some("even") => DocxHeaderFooterType::Even,
                                _ => DocxHeaderFooterType::Default,
                            };
                            current_section_props.header_refs.push(DocxHeaderFooterRef { ref_type, rel_id });
                        }
                    }
                    b"footerReference" if in_sect_pr => {
                        if let Some(rel_id) = get_attr(e, b"r:id") {
                            let ref_type = match get_attr(e, b"w:type").as_deref() {
                                Some("first") => DocxHeaderFooterType::First,
                                Some("even") => DocxHeaderFooterType::Even,
                                _ => DocxHeaderFooterType::Default,
                            };
                            current_section_props.footer_refs.push(DocxHeaderFooterRef { ref_type, rel_id });
                        }
                    }
                    b"br" if in_run => {
                        let break_type = match get_attr(e, b"w:type").as_deref() {
                            Some("page") => Some(DocxBreakType::Page),
                            Some("column") => Some(DocxBreakType::Column),
                            _ => Some(DocxBreakType::Line),
                        };
                        current_run.break_type = break_type;
                    }
                    b"tab" if in_run => {
                        current_run.tab = true;
                    }
                    b"bookmarkStart" if in_paragraph => {
                        if let (Some(id), Some(name)) = (
                            get_attr(e, b"w:id").and_then(|s| s.parse().ok()),
                            get_attr(e, b"w:name")
                        ) {
                            current_paragraph.bookmarks.push(DocxBookmark { id, name });
                        }
                    }
                    _ => {}
                }
            }
            Ok(Event::Text(ref t)) => {
                if in_run && !in_drawing && !in_math {
                    current_run.text.push_str(&t.unescape().unwrap_or_default());
                }
                if in_field {
                    // Collect field instruction
                    field_instruction.push_str(&t.unescape().unwrap_or_default());
                }
            }
            Ok(Event::End(ref e)) => {
                let name = e.local_name();
                match name.as_ref() {
                    b"body" => {
                        in_body = false;
                        // Finalize last section
                        if !current_section_elements.is_empty() || current_section_props.page_size.is_some() {
                            sections.push(DocxSection {
                                elements: current_section_elements.drain(..).collect(),
                                properties: std::mem::take(&mut current_section_props),
                            });
                        }
                    }
                    b"sectPr" => {
                        in_sect_pr = false;
                        // Section break - save current section
                        sections.push(DocxSection {
                            elements: current_section_elements.drain(..).collect(),
                            properties: std::mem::take(&mut current_section_props),
                        });
                    }
                    b"ins" => {
                        if let Some(mut rev) = current_revision.take() {
                            rev.content = revision_content.drain(..).collect();
                            revisions.insertions.push(rev);
                        }
                        in_revision_ins = false;
                    }
                    b"del" => {
                        if let Some(mut rev) = current_revision.take() {
                            rev.content = revision_content.drain(..).collect();
                            revisions.deletions.push(rev);
                        }
                        in_revision_del = false;
                    }
                    b"sdt" => {
                        in_sdt = false;
                    }
                    b"drawing" => {
                        in_drawing = false;
                    }
                    b"oMath" => {
                        in_math = false;
                    }
                    b"r" if in_run => {
                        if current_run.tab {
                            current_run.text.push('\t');
                        }
                        if !current_run.text.is_empty() || current_run.break_type.is_some() {
                            current_paragraph.runs.push(std::mem::take(&mut current_run));
                        }
                        current_run = DocxRun::default();
                        in_run = false;
                    }
                    b"p" if in_paragraph => {
                        let para = DocxElement::Paragraph(std::mem::take(&mut current_paragraph));
                        if in_revision_ins || in_revision_del {
                            revision_content.push(para.clone());
                        }
                        current_section_elements.push(para.clone());
                        elements.push(para);
                        in_paragraph = false;
                    }
                    b"tc" if in_table => {
                        current_row.cells.push(std::mem::take(&mut current_cell));
                    }
                    b"tr" if in_table => {
                        current_table.rows.push(std::mem::take(&mut current_row));
                    }
                    b"tbl" if in_table => {
                        let table = DocxElement::Table(std::mem::take(&mut current_table));
                        current_section_elements.push(table.clone());
                        elements.push(table);
                        in_table = false;
                    }
                    b"hyperlink" if in_paragraph => {
                        // Reset hyperlink for next run
                    }
                    _ => {}
                }
            }
            Ok(Event::Eof) => break,
            Err(e) => return Err(ParseError::XmlError(format!("XML error: {}", e))),
            _ => {}
        }
        buf.clear();
    }
    
    // If no sections were created, create one with all elements
    if sections.is_empty() && !elements.is_empty() {
        sections.push(DocxSection {
            elements: elements.clone(),
            properties: DocxSectionProperties::default(),
        });
    }
    
    Ok((elements, sections, revisions))
}
