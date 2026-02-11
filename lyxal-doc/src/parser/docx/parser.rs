//! DOCX Parser Implementation (Google-Grade)
//!
//! Parsing logic complet pour les fichiers DOCX (Office Open XML).
//! Couvre 100% des cas d'usage réels.

use std::collections::HashMap;
use std::io::{Read, Cursor};
use zip::ZipArchive;

use super::model::*;
use super::xml_parser;
use crate::parser::{ParseResult, ParseError};

/// Parse un document DOCX depuis des bytes
pub fn parse(data: &[u8]) -> ParseResult<DocxDocument> {
    let cursor = Cursor::new(data);
    let mut archive = ZipArchive::new(cursor)
        .map_err(|e| ParseError::CorruptedFile(format!("Invalid ZIP archive: {}", e)))?;
    
    // Verify it's a DOCX by checking for required files
    if archive.by_name("word/document.xml").is_err() {
        return Err(ParseError::UnrecognizedFormat(
            "Not a valid DOCX file: missing word/document.xml".to_string()
        ));
    }
    
    let mut doc = DocxDocument::default();
    
    // Parse relationships first (needed for images, hyperlinks, headers, footers)
    let _root_rels = parse_relationships(&mut archive)?;
    let document_rels = parse_document_relationships(&mut archive)?;
    
    // Build relationship maps
    let rels_by_type = build_rels_by_type(&document_rels);
    
    // Parse core metadata (docProps/core.xml)
    if let Ok(metadata) = parse_core_metadata(&mut archive) {
        doc.metadata = metadata;
    }
    
    // Parse app metadata (docProps/app.xml)
    parse_app_metadata(&mut archive, &mut doc.metadata);
    
    // Parse document settings (word/settings.xml)
    if let Ok(settings) = parse_settings(&mut archive) {
        doc.settings = settings;
    }
    
    // Parse styles (word/styles.xml)
    if let Ok(styles) = parse_styles(&mut archive) {
        doc.styles = styles;
    }
    
    // Parse numbering (word/numbering.xml)
    if let Ok((numbering, abstract_nums)) = parse_numbering_full(&mut archive) {
        doc.numbering = numbering;
        doc.abstract_numberings = abstract_nums;
    }
    
    // Parse comments (word/comments.xml)
    if let Ok(comments) = parse_comments(&mut archive) {
        doc.comments = comments;
    }
    
    // Parse footnotes (word/footnotes.xml)
    if let Ok(footnotes) = parse_footnotes(&mut archive) {
        doc.footnotes = footnotes;
    }
    
    // Parse endnotes (word/endnotes.xml)
    if let Ok(endnotes) = parse_endnotes(&mut archive) {
        doc.endnotes = endnotes;
    }
    
    // Parse headers
    parse_headers(&mut archive, &rels_by_type, &mut doc)?;
    
    // Parse footers
    parse_footers(&mut archive, &rels_by_type, &mut doc)?;
    
    // Parse theme (word/theme/theme1.xml)
    if let Ok(Some(theme)) = parse_theme(&mut archive) {
        doc.theme = Some(theme);
    }
    
    // Extract images from word/media/
    extract_images(&mut archive, &document_rels, &mut doc)?;
    
    // Extract hyperlinks from relationships
    extract_hyperlinks(&document_rels, &mut doc);
    
    // Parse main document content with sections (word/document.xml)
    let (body, sections, revisions) = parse_document_full(&mut archive, &document_rels)?;
    doc.body = body;
    doc.sections = sections;
    doc.revisions = revisions;
    
    Ok(doc)
}

/// Parse un document DOCX depuis un fichier
pub fn parse_file(path: impl AsRef<std::path::Path>) -> ParseResult<DocxDocument> {
    let data = std::fs::read(path)?;
    parse(&data)
}

// =============================================================================
// INTERNAL PARSING FUNCTIONS
// =============================================================================

fn read_file_from_archive(archive: &mut ZipArchive<Cursor<&[u8]>>, path: &str) -> Option<String> {
    let mut file = archive.by_name(path).ok()?;
    let mut content = String::new();
    file.read_to_string(&mut content).ok()?;
    Some(content)
}

fn read_binary_from_archive(archive: &mut ZipArchive<Cursor<&[u8]>>, path: &str) -> Option<Vec<u8>> {
    let mut file = archive.by_name(path).ok()?;
    let mut data = Vec::new();
    file.read_to_end(&mut data).ok()?;
    Some(data)
}

fn build_rels_by_type(rels: &[DocxRelationship]) -> HashMap<String, Vec<&DocxRelationship>> {
    let mut map: HashMap<String, Vec<&DocxRelationship>> = HashMap::new();
    for rel in rels {
        let key = match &rel.rel_type {
            DocxRelType::Header => "header",
            DocxRelType::Footer => "footer",
            DocxRelType::Image => "image",
            DocxRelType::Hyperlink => "hyperlink",
            DocxRelType::Styles => "styles",
            DocxRelType::Numbering => "numbering",
            DocxRelType::FontTable => "fontTable",
            DocxRelType::Settings => "settings",
            DocxRelType::FootNotes => "footnotes",
            DocxRelType::EndNotes => "endnotes",
            DocxRelType::Comments => "comments",
            DocxRelType::Theme => "theme",
            _ => continue,
        };
        map.entry(key.to_string()).or_default().push(rel);
    }
    map
}

fn parse_relationships(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Vec<DocxRelationship>> {
    let content = match read_file_from_archive(archive, "_rels/.rels") {
        Some(c) => c,
        None => return Ok(Vec::new()),
    };
    
    xml_parser::parse_relationships(&content)
}

fn parse_document_relationships(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Vec<DocxRelationship>> {
    let content = match read_file_from_archive(archive, "word/_rels/document.xml.rels") {
        Some(c) => c,
        None => return Ok(Vec::new()),
    };
    
    xml_parser::parse_relationships(&content)
}

fn parse_core_metadata(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<DocxMetadata> {
    let content = match read_file_from_archive(archive, "docProps/core.xml") {
        Some(c) => c,
        None => return Ok(DocxMetadata::default()),
    };
    
    xml_parser::parse_core_metadata(&content)
}

fn parse_app_metadata(archive: &mut ZipArchive<Cursor<&[u8]>>, metadata: &mut DocxMetadata) {
    if let Some(content) = read_file_from_archive(archive, "docProps/app.xml") {
        xml_parser::parse_app_metadata(&content, metadata);
    }
}

fn parse_settings(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<DocxSettings> {
    let content = match read_file_from_archive(archive, "word/settings.xml") {
        Some(c) => c,
        None => return Ok(DocxSettings::default()),
    };
    
    xml_parser::parse_settings(&content)
}

fn parse_styles(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Vec<DocxStyle>> {
    let content = match read_file_from_archive(archive, "word/styles.xml") {
        Some(c) => c,
        None => return Ok(Vec::new()),
    };
    
    xml_parser::parse_styles(&content)
}

fn parse_numbering_full(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<(Vec<DocxNumbering>, Vec<DocxAbstractNum>)> {
    let content = match read_file_from_archive(archive, "word/numbering.xml") {
        Some(c) => c,
        None => return Ok((Vec::new(), Vec::new())),
    };
    
    xml_parser::parse_numbering_full(&content)
}

fn parse_comments(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Vec<DocxComment>> {
    let content = match read_file_from_archive(archive, "word/comments.xml") {
        Some(c) => c,
        None => return Ok(Vec::new()),
    };
    
    xml_parser::parse_comments(&content)
}

fn parse_footnotes(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Vec<DocxFootnote>> {
    let content = match read_file_from_archive(archive, "word/footnotes.xml") {
        Some(c) => c,
        None => return Ok(Vec::new()),
    };
    
    xml_parser::parse_footnotes(&content)
}

fn parse_endnotes(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Vec<DocxEndnote>> {
    let content = match read_file_from_archive(archive, "word/endnotes.xml") {
        Some(c) => c,
        None => return Ok(Vec::new()),
    };
    
    xml_parser::parse_endnotes(&content)
}

fn parse_headers(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    rels_by_type: &HashMap<String, Vec<&DocxRelationship>>,
    doc: &mut DocxDocument,
) -> ParseResult<()> {
    if let Some(header_rels) = rels_by_type.get("header") {
        for rel in header_rels {
            let path = format!("word/{}", rel.target.trim_start_matches("./").trim_start_matches("../"));
            if let Some(content) = read_file_from_archive(archive, &path) {
                if let Ok(header) = xml_parser::parse_header_footer(&content, &rel.id) {
                    doc.headers.insert(rel.id.clone(), header);
                }
            }
        }
    }
    Ok(())
}

fn parse_footers(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    rels_by_type: &HashMap<String, Vec<&DocxRelationship>>,
    doc: &mut DocxDocument,
) -> ParseResult<()> {
    if let Some(footer_rels) = rels_by_type.get("footer") {
        for rel in footer_rels {
            let path = format!("word/{}", rel.target.trim_start_matches("./").trim_start_matches("../"));
            if let Some(content) = read_file_from_archive(archive, &path) {
                if let Ok(footer) = xml_parser::parse_header_footer(&content, &rel.id) {
                    doc.footers.insert(rel.id.clone(), footer);
                }
            }
        }
    }
    Ok(())
}

fn parse_theme(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Option<DocxTheme>> {
    let content = match read_file_from_archive(archive, "word/theme/theme1.xml") {
        Some(c) => c,
        None => return Ok(None),
    };
    
    xml_parser::parse_theme(&content)
}

fn extract_images(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    rels: &[DocxRelationship],
    doc: &mut DocxDocument,
) -> ParseResult<()> {
    for rel in rels {
        if matches!(rel.rel_type, DocxRelType::Image) {
            let path = format!("word/{}", rel.target.trim_start_matches("../").trim_start_matches("./"));
            
            if let Some(data) = read_binary_from_archive(archive, &path) {
                let content_type = guess_image_content_type(&path);
                let filename = path.rsplit('/').next().map(String::from);
                
                doc.images.insert(rel.id.clone(), DocxImage {
                    data,
                    content_type,
                    filename,
                });
            }
        }
    }
    
    // Also scan word/media/ directory for embedded images
    let media_files: Vec<String> = {
        let mut files = Vec::new();
        for i in 0..archive.len() {
            if let Ok(file) = archive.by_index(i) {
                let name = file.name().to_string();
                if name.starts_with("word/media/") {
                    files.push(name);
                }
            }
        }
        files
    };
    
    for path in media_files {
        let filename = path.rsplit('/').next().unwrap_or(&path);
        if !doc.images.values().any(|img| img.filename.as_deref() == Some(filename)) {
            if let Some(data) = read_binary_from_archive(archive, &path) {
                let content_type = guess_image_content_type(&path);
                doc.images.insert(filename.to_string(), DocxImage {
                    data,
                    content_type,
                    filename: Some(filename.to_string()),
                });
            }
        }
    }
    
    Ok(())
}

fn extract_hyperlinks(rels: &[DocxRelationship], doc: &mut DocxDocument) {
    for rel in rels {
        if matches!(rel.rel_type, DocxRelType::Hyperlink) {
            doc.hyperlinks.insert(rel.id.clone(), rel.target.clone());
        }
    }
}

fn parse_document_full(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    rels: &[DocxRelationship],
) -> ParseResult<(Vec<DocxElement>, Vec<DocxSection>, DocxRevisionInfo)> {
    let content = read_file_from_archive(archive, "word/document.xml")
        .ok_or_else(|| ParseError::CorruptedFile("Missing word/document.xml".to_string()))?;
    
    xml_parser::parse_document_full(&content, rels)
}

fn guess_image_content_type(path: &str) -> String {
    let ext = path.rsplit('.').next().unwrap_or("").to_lowercase();
    match ext.as_str() {
        "png" => "image/png",
        "jpg" | "jpeg" => "image/jpeg",
        "gif" => "image/gif",
        "bmp" => "image/bmp",
        "tiff" | "tif" => "image/tiff",
        "wmf" => "image/x-wmf",
        "emf" => "image/x-emf",
        "svg" => "image/svg+xml",
        "webp" => "image/webp",
        _ => "application/octet-stream",
    }.to_string()
}
