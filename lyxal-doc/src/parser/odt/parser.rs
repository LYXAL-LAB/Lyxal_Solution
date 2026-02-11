//! ODT Parser Implementation (Google-Grade)
//!
//! Parsing logic complet pour les fichiers ODT (OpenDocument Text).

use std::collections::HashMap;
use std::io::{Read, Cursor};
use zip::ZipArchive;

use super::model::*;
use super::xml_parser;
use crate::parser::{ParseResult, ParseError};

/// Parse un document ODT depuis des bytes
pub fn parse(data: &[u8]) -> ParseResult<OdtDocument> {
    let cursor = Cursor::new(data);
    let mut archive = ZipArchive::new(cursor)
        .map_err(|e| ParseError::CorruptedFile(format!("Invalid ZIP archive: {}", e)))?;
    
    // Verify it's an ODT by checking for mimetype or content.xml
    let mimetype = read_file_from_archive(&mut archive, "mimetype");
    if let Some(ref mt) = mimetype {
        if !mt.contains("opendocument.text") {
            return Err(ParseError::UnrecognizedFormat(
                format!("Not an ODT file, mimetype: {}", mt)
            ));
        }
    } else if archive.by_name("content.xml").is_err() {
        return Err(ParseError::UnrecognizedFormat(
            "Not a valid ODT file: missing content.xml".to_string()
        ));
    }
    
    let mut doc = OdtDocument::default();
    
    // Parse metadata (meta.xml)
    if let Ok(metadata) = parse_metadata(&mut archive) {
        doc.metadata = metadata;
    }
    
    // Parse styles (styles.xml)
    if let Ok((common, master)) = parse_styles(&mut archive) {
        doc.common_styles = common;
        doc.master_styles = master;
    }
    
    // Parse content with automatic styles (content.xml)
    match parse_content(&mut archive) {
        Ok((body, auto_styles, font_decls)) => {
            doc.body = body;
            doc.automatic_styles = auto_styles;
            doc.font_declarations = font_decls;
        }
        Err(e) => {
            doc.warnings.push(format!("Error parsing content: {}", e));
        }
    }
    
    // Parse settings (settings.xml)
    if let Ok(settings) = parse_settings(&mut archive) {
        doc.settings = settings;
    }
    
    // Extract images from Pictures/
    extract_images(&mut archive, &mut doc)?;
    
    Ok(doc)
}

/// Parse un document ODT depuis un fichier
pub fn parse_file(path: impl AsRef<std::path::Path>) -> ParseResult<OdtDocument> {
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

fn parse_metadata(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<OdtMetadata> {
    let content = match read_file_from_archive(archive, "meta.xml") {
        Some(c) => c,
        None => return Ok(OdtMetadata::default()),
    };
    
    xml_parser::parse_metadata(&content)
}

fn parse_styles(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<(Vec<OdtStyle>, Vec<OdtMasterPage>)> {
    let content = match read_file_from_archive(archive, "styles.xml") {
        Some(c) => c,
        None => return Ok((Vec::new(), Vec::new())),
    };
    
    xml_parser::parse_styles(&content)
}

fn parse_content(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<(Vec<OdtElement>, Vec<OdtStyle>, Vec<OdtFontDecl>)> {
    let content = read_file_from_archive(archive, "content.xml")
        .ok_or_else(|| ParseError::CorruptedFile("Missing content.xml".to_string()))?;
    
    xml_parser::parse_content(&content)
}

fn parse_settings(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<OdtSettings> {
    let content = match read_file_from_archive(archive, "settings.xml") {
        Some(c) => c,
        None => return Ok(OdtSettings::default()),
    };
    
    xml_parser::parse_settings(&content)
}

fn extract_images(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    doc: &mut OdtDocument,
) -> ParseResult<()> {
    // List all files in Pictures/
    let picture_files: Vec<String> = {
        let mut files = Vec::new();
        for i in 0..archive.len() {
            if let Ok(file) = archive.by_index(i) {
                let name = file.name().to_string();
                if name.starts_with("Pictures/") && !name.ends_with('/') {
                    files.push(name);
                }
            }
        }
        files
    };
    
    for path in picture_files {
        if let Some(data) = read_binary_from_archive(archive, &path) {
            let mime_type = guess_mime_type(&path);
            doc.images.insert(path.clone(), OdtImage {
                data,
                mime_type,
                path: path.clone(),
            });
        }
    }
    
    Ok(())
}

fn guess_mime_type(path: &str) -> String {
    let ext = path.rsplit('.').next().unwrap_or("").to_lowercase();
    match ext.as_str() {
        "png" => "image/png",
        "jpg" | "jpeg" => "image/jpeg",
        "gif" => "image/gif",
        "bmp" => "image/bmp",
        "tiff" | "tif" => "image/tiff",
        "svg" => "image/svg+xml",
        "webp" => "image/webp",
        "wmf" => "image/x-wmf",
        "emf" => "image/x-emf",
        _ => "application/octet-stream",
    }.to_string()
}
