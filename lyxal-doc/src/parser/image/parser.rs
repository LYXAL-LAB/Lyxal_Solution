//! Image Parser Implementation
//!
//! Utilise la crate 'image' pour le décodage et l'extraction de métadonnées.
//! Prépare les données pour l'OCR Lyxal.

use std::io::Cursor;
use image::{DynamicImage, GenericImageView, ImageFormat};
use super::model::*;
use crate::parser::{ParseResult, ParseError};

/// Parse une image depuis des bytes
pub fn parse(data: &[u8]) -> ParseResult<ImageDocument> {
    let format = image::guess_format(data)
        .map_err(|e| ParseError::UnrecognizedFormat(format!("Image format error: {}", e)))?;
    
    let img = image::load_from_memory(data)
        .map_err(|e| ParseError::CorruptedFile(format!("Failed to load image: {}", e)))?;
    
    let (width, height) = img.dimensions();
    let color_type = format!("{:?}", img.color());
    
    let mut doc = ImageDocument {
        raw_data: data.to_vec(),
        format: format_to_string(format),
        metadata: ImageMetadata {
            width,
            height,
            color_type,
            bit_depth: 8, // Simplified
            ..Default::default()
        },
        ..Default::default()
    };
    
    // Extraction des métadonnées EXIF (si supporté par le format)
    extract_exif(data, &mut doc);
    
    // Ici on lancerait l'OCR Lyxal si activé
    // doc.text_regions = ocr::run(&img);
    
    Ok(doc)
}

/// Parse une image depuis un fichier
pub fn parse_file(path: impl AsRef<std::path::Path>) -> ParseResult<ImageDocument> {
    let data = std::fs::read(path)?;
    parse(&data)
}

fn format_to_string(format: ImageFormat) -> String {
    match format {
        ImageFormat::Png => "png",
        ImageFormat::Jpeg => "jpeg",
        ImageFormat::Gif => "gif",
        ImageFormat::WebP => "webp",
        ImageFormat::Tiff => "tiff",
        ImageFormat::Bmp => "bmp",
        ImageFormat::Ico => "ico",
        _ => "unknown",
    }.to_string()
}

fn extract_exif(_data: &[u8], _doc: &mut ImageDocument) {
    // TODO: Utiliser une crate comme 'exif' pour extraire les données
    // Pour l'instant on laisse vide pour ne pas ajouter de dépendance externe immédiate
}
