//! PPTX Parser Implementation (Google-Grade)
//!
//! Parsing logic complet pour les fichiers PPTX (PresentationML).

use std::collections::HashMap;
use std::io::{Read, Cursor};
use zip::ZipArchive;

use super::model::*;
use super::xml_parser;
use crate::parser::{ParseResult, ParseError};

/// Parse une présentation PPTX depuis des bytes
pub fn parse(data: &[u8]) -> ParseResult<PptxDocument> {
    let cursor = Cursor::new(data);
    let mut archive = ZipArchive::new(cursor)
        .map_err(|e| ParseError::CorruptedFile(format!("Invalid ZIP archive: {}", e)))?;
    
    // Verify it's a PPTX
    if archive.by_name("ppt/presentation.xml").is_err() {
        return Err(ParseError::UnrecognizedFormat(
            "Not a valid PPTX file: missing ppt/presentation.xml".to_string()
        ));
    }
    
    let mut doc = PptxDocument::default();
    
    // Parse relationships
    let presentation_rels = parse_presentation_relationships(&mut archive)?;
    
    // Parse metadata
    if let Ok(metadata) = parse_metadata(&mut archive) {
        doc.metadata = metadata;
    }
    
    // Parse presentation properties
    if let Ok(props) = parse_presentation_properties(&mut archive) {
        doc.properties = props;
    }
    
    // Parse theme
    if let Ok(Some(theme)) = parse_theme(&mut archive, &presentation_rels) {
        doc.theme = Some(theme);
    }
    
    // Parse slide masters
    doc.slide_masters = parse_slide_masters(&mut archive, &presentation_rels)?;
    
    // Parse slide layouts
    doc.slide_layouts = parse_slide_layouts(&mut archive, &presentation_rels)?;
    
    // Parse slides
    doc.slides = parse_slides(&mut archive, &presentation_rels)?;
    
    // Extract images
    extract_images(&mut archive, &mut doc)?;
    
    // Extract media
    extract_media(&mut archive, &mut doc)?;
    
    // Parse comments
    if let Ok(comments) = parse_comments(&mut archive) {
        doc.comments = comments;
    }
    
    Ok(doc)
}

/// Parse une présentation PPTX depuis un fichier
pub fn parse_file(path: impl AsRef<std::path::Path>) -> ParseResult<PptxDocument> {
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

fn parse_presentation_relationships(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Vec<PptxRelationship>> {
    let content = match read_file_from_archive(archive, "ppt/_rels/presentation.xml.rels") {
        Some(c) => c,
        None => return Ok(Vec::new()),
    };
    
    xml_parser::parse_relationships(&content)
}

fn parse_metadata(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<PptxMetadata> {
    let mut metadata = PptxMetadata::default();
    
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

fn parse_presentation_properties(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<PptxPresentationProperties> {
    let content = match read_file_from_archive(archive, "ppt/presentation.xml") {
        Some(c) => c,
        None => return Ok(PptxPresentationProperties::default()),
    };
    
    xml_parser::parse_presentation_properties(&content)
}

fn parse_theme(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    rels: &[PptxRelationship],
) -> ParseResult<Option<PptxTheme>> {
    // Find theme relationship
    let theme_rel = rels.iter().find(|r| matches!(r.rel_type, PptxRelType::Theme));
    
    if let Some(rel) = theme_rel {
        let path = format!("ppt/{}", rel.target.trim_start_matches("../").trim_start_matches("./"));
        if let Some(content) = read_file_from_archive(archive, &path) {
            return xml_parser::parse_theme(&content);
        }
    }
    
    // Try default path
    if let Some(content) = read_file_from_archive(archive, "ppt/theme/theme1.xml") {
        return xml_parser::parse_theme(&content);
    }
    
    Ok(None)
}

fn parse_slide_masters(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    rels: &[PptxRelationship],
) -> ParseResult<Vec<PptxSlideMaster>> {
    let mut masters = Vec::new();
    
    for rel in rels.iter().filter(|r| matches!(r.rel_type, PptxRelType::SlideMaster)) {
        let path = format!("ppt/{}", rel.target.trim_start_matches("../").trim_start_matches("./"));
        if let Some(content) = read_file_from_archive(archive, &path) {
            if let Ok(master) = xml_parser::parse_slide_master(&content, &rel.id) {
                masters.push(master);
            }
        }
    }
    
    Ok(masters)
}

fn parse_slide_layouts(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    _rels: &[PptxRelationship],
) -> ParseResult<Vec<PptxSlideLayout>> {
    let mut layouts = Vec::new();
    
    // Scan for slide layouts
    let layout_files: Vec<String> = {
        let mut files = Vec::new();
        for i in 0..archive.len() {
            if let Ok(file) = archive.by_index(i) {
                let name = file.name().to_string();
                if name.starts_with("ppt/slideLayouts/slideLayout") && name.ends_with(".xml") {
                    files.push(name);
                }
            }
        }
        files.sort();
        files
    };
    
    for path in layout_files {
        if let Some(content) = read_file_from_archive(archive, &path) {
            // Extract layout ID from filename
            let rel_id = path.replace("ppt/slideLayouts/", "").replace(".xml", "");
            if let Ok(layout) = xml_parser::parse_slide_layout(&content, &rel_id) {
                layouts.push(layout);
            }
        }
    }
    
    Ok(layouts)
}

fn parse_slides(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    _rels: &[PptxRelationship],
) -> ParseResult<Vec<PptxSlide>> {
    let mut slides = Vec::new();
    
    // Scan for slides
    let slide_files: Vec<(String, usize)> = {
        let mut files = Vec::new();
        for i in 0..archive.len() {
            if let Ok(file) = archive.by_index(i) {
                let name = file.name().to_string();
                if name.starts_with("ppt/slides/slide") && name.ends_with(".xml") && !name.contains("_rels") {
                    // Extract slide number
                    if let Some(num_str) = name
                        .trim_start_matches("ppt/slides/slide")
                        .trim_end_matches(".xml")
                        .parse::<usize>()
                        .ok()
                    {
                        files.push((name, num_str));
                    }
                }
            }
        }
        files.sort_by_key(|(_, n)| *n);
        files
    };
    
    for (path, index) in slide_files {
        if let Some(content) = read_file_from_archive(archive, &path) {
            // Get slide relationships
            let rels_path = path.replace("slides/", "slides/_rels/") + ".rels";
            let slide_rels = if let Some(rels_content) = read_file_from_archive(archive, &rels_path) {
                xml_parser::parse_relationships(&rels_content).unwrap_or_default()
            } else {
                Vec::new()
            };
            
            if let Ok(slide) = xml_parser::parse_slide(&content, index, &slide_rels) {
                slides.push(slide);
            }
        }
    }
    
    Ok(slides)
}

fn extract_images(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    doc: &mut PptxDocument,
) -> ParseResult<()> {
    // Scan for images in ppt/media/
    let image_files: Vec<String> = {
        let mut files = Vec::new();
        for i in 0..archive.len() {
            if let Ok(file) = archive.by_index(i) {
                let name = file.name().to_string();
                if name.starts_with("ppt/media/") && !name.ends_with('/') {
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
            
            // Use filename as key
            let key = filename.clone().unwrap_or_else(|| path.clone());
            
            if content_type.starts_with("image/") {
                doc.images.insert(key, PptxImage {
                    data,
                    content_type,
                    filename,
                });
            }
        }
    }
    
    Ok(())
}

fn extract_media(
    archive: &mut ZipArchive<Cursor<&[u8]>>,
    doc: &mut PptxDocument,
) -> ParseResult<()> {
    // Scan for media files
    let media_files: Vec<String> = {
        let mut files = Vec::new();
        for i in 0..archive.len() {
            if let Ok(file) = archive.by_index(i) {
                let name = file.name().to_string();
                if name.starts_with("ppt/media/") && !name.ends_with('/') {
                    let content_type = guess_content_type(&name);
                    if content_type.starts_with("audio/") || content_type.starts_with("video/") {
                        files.push(name);
                    }
                }
            }
        }
        files
    };
    
    for path in media_files {
        if let Some(data) = read_binary_from_archive(archive, &path) {
            let content_type = guess_content_type(&path);
            let filename = path.rsplit('/').next().map(String::from);
            let key = filename.clone().unwrap_or_else(|| path.clone());
            
            let media_type = if content_type.starts_with("audio/") {
                PptxMediaType::Audio
            } else if content_type.starts_with("video/") {
                PptxMediaType::Video
            } else {
                PptxMediaType::Other
            };
            
            doc.media.insert(key, PptxMedia {
                data,
                content_type,
                filename,
                media_type,
            });
        }
    }
    
    Ok(())
}

fn parse_comments(archive: &mut ZipArchive<Cursor<&[u8]>>) -> ParseResult<Vec<PptxComment>> {
    // Try to find comments file
    if let Some(content) = read_file_from_archive(archive, "ppt/comments/comment1.xml") {
        return xml_parser::parse_comments(&content);
    }
    
    Ok(Vec::new())
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
        "mp3" => "audio/mpeg",
        "wav" => "audio/wav",
        "m4a" => "audio/mp4",
        "mp4" => "video/mp4",
        "avi" => "video/x-msvideo",
        "wmv" => "video/x-ms-wmv",
        "mov" => "video/quicktime",
        _ => "application/octet-stream",
    }.to_string()
}
