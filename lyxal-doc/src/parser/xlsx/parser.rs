//! XLSX Parser Implementation (Google-Grade)
//!
//! Parsing logic complet pour les fichiers XLSX (SpreadsheetML).

use std::collections::HashMap;
use std::io::{Read, Cursor};
use zip::ZipArchive;

use super::model::*;
use super::xml_parser;
use crate::parser::{ParseResult, ParseError};

/// Parse un classeur XLSX depuis des bytes
pub fn parse(data: &[u8]) -> ParseResult<XlsxDocument> {
    let cursor = Cursor::new(data);
    let mut archive = ZipArchive::new(cursor)
        .map_err(|e| ParseError::CorruptedFile(format!("Invalid ZIP archive: {}", e)))?;
    
    // Verify it's an XLSX
    if archive.by_name("xl/workbook.xml").is_err() {
        return Err(ParseError::UnrecognizedFormat(
            "Not a valid XLSX file: missing xl/workbook.xml".to_string()
        ));
    }
    
    let mut doc = XlsxDocument::default();
    
    // Parse relationships
    let workbook_rels = parse_workbook_relationships(&mut archive)?;
    
    // Parse metadata
    if let Ok(metadata) = parse_metadata(&mut archive) {
        doc.metadata = metadata;
    }
    
    // Parse shared strings first (needed for cell values)
    if let Ok(strings) = parse_shared_strings(&mut archive) {
        doc.shared_strings = strings;
    }
    
    // Parse styles
    if let Ok(styles) = parse_styles(&mut archive) {
        doc.styles = styles;
    }
    
    // Parse theme
    if let Ok(Some(theme)) = parse_theme(&mut archive) {
        doc.theme = Some(theme);
    }
    
    // Parse workbook (sheets list)
    let (sheet_info, defined_names) = parse_workbook(&mut archive)?;
    doc.defined_names = defined_names;
    
    // Parse each sheet
    for (name, sheet_id, state, rel_id) in sheet_info {
        if let Some(rel) = workbook_rels.iter().find(|r| r.id == rel_id) {
            let path = format!("xl/{}", rel.target.trim_start_matches("../").trim_start_matches("./"));
            if let Ok(sheet) = parse_sheet(&mut archive, &path, name, sheet_id, state) {
                doc.sheets.push(sheet);
            }
        }
    }
    
    // Extract images
    extract_images(&mut archive, &mut doc)?;
    
    Ok(doc)
}

/// Parse un classeur XLSX depuis un fichier
pub fn parse_file(path: impl AsRef<std::path::Path>) -> ParseResult<XlsxDocument> {
    let data = std::fs::read(path)?;
    parse(&data)
}

// =============================================================================
// INTERNAL FUNCTIONS
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

fn parse_workbook_relationships(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Vec<XlsxRelationship>> {
    let content = match read_file_from_archive(archive, "xl/_rels/workbook.xml.rels") {
        Some(c) => c,
        None => return Ok(Vec::new()),
    };
    
    xml_parser::parse_relationships(&content)
}

fn parse_metadata(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<XlsxMetadata> {
    let mut metadata = XlsxMetadata::default();
    
    // Core properties
    if let Some(content) = read_file_from_archive(archive, "docProps/core.xml") {
        xml_parser::parse_core_metadata(&content, &mut metadata)?;
    }
    
    // App properties
    if let Some(content) = read_file_from_archive(archive, "docProps/app.xml") {
        xml_parser::parse_app_metadata(&content, &mut metadata);
    }
    
    Ok(metadata)
}

fn parse_shared_strings(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Vec<XlsxSharedString>> {
    let content = match read_file_from_archive(archive, "xl/sharedStrings.xml") {
        Some(c) => c,
        None => return Ok(Vec::new()),
    };
    
    xml_parser::parse_shared_strings(&content)
}

fn parse_styles(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<XlsxStyles> {
    let content = match read_file_from_archive(archive, "xl/styles.xml") {
        Some(c) => c,
        None => return Ok(XlsxStyles::default()),
    };
    
    xml_parser::parse_styles(&content)
}

fn parse_theme(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Option<XlsxTheme>> {
    let content = match read_file_from_archive(archive, "xl/theme/theme1.xml") {
        Some(c) => c,
        None => return Ok(None),
    };
    
    xml_parser::parse_theme(&content)
}

fn parse_workbook(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<(Vec<(String, u32, XlsxSheetState, String)>, Vec<XlsxDefinedName>)> {
    let content = read_file_from_archive(archive, "xl/workbook.xml")
        .ok_or_else(|| ParseError::CorruptedFile("Missing xl/workbook.xml".to_string()))?;
    
    xml_parser::parse_workbook(&content)
}

fn parse_sheet(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    path: &str,
    name: String,
    sheet_id: u32,
    state: XlsxSheetState,
) -> ParseResult<XlsxSheet> {
    let content = read_file_from_archive(archive, path)
        .ok_or_else(|| ParseError::CorruptedFile(format!("Missing sheet: {}", path)))?;
    
    // Get sheet relationships for hyperlinks, etc.
    let rels_path = path.replace("worksheets/", "worksheets/_rels/") + ".rels";
    let rels = if let Some(rels_content) = read_file_from_archive(archive, &rels_path) {
        xml_parser::parse_relationships(&rels_content).unwrap_or_default()
    } else {
        Vec::new()
    };
    
    xml_parser::parse_sheet(&content, name, sheet_id, state, &rels)
}

fn extract_images(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    doc: &mut XlsxDocument,
) -> ParseResult<()> {
    // Scan for images in xl/media/
    let image_files: Vec<String> = {
        let mut files = Vec::new();
        for i in 0..archive.len() {
            if let Ok(file) = archive.by_index(i) {
                let name = file.name().to_string();
                if name.starts_with("xl/media/") && !name.ends_with('/') {
                    files.push(name);
                }
            }
        }
        files
    };
    
    for path in image_files {
        if let Some(data) = read_binary_from_archive(archive, &path) {
            let content_type = guess_content_type(&path);
            let filename = path.rsplit('/').next().map(String::from);
            let key = filename.clone().unwrap_or_else(|| path.clone());
            
            doc.images.insert(key, XlsxImage {
                data,
                content_type,
                filename,
            });
        }
    }
    
    Ok(())
}

fn guess_content_type(path: &str) -> String {
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
