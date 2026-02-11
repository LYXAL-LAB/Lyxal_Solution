//! Image (OCR) Document Model
//!
//! Types représentant le résultat d'une analyse d'image (Métadonnées + OCR).

use std::collections::HashMap;

// =============================================================================
// DOCUMENT PRINCIPAL
// =============================================================================

/// Résultat de l'analyse d'une image
#[derive(Debug, Clone, Default)]
pub struct ImageDocument {
    /// Métadonnées de l'image (EXIF, format, etc.)
    pub metadata: ImageMetadata,
    /// Zones de texte détectées (OCR)
    pub text_regions: Vec<ImageTextRegion>,
    /// Objets détectés (Classification)
    pub objects: Vec<DetectedObject>,
    /// Données binaires de l'image originale
    pub raw_data: Vec<u8>,
    /// Format détecté (png, jpeg, etc.)
    pub format: String,
    /// Avertissements
    pub warnings: Vec<String>,
}

// =============================================================================
// MÉTADONNÉES (EXIF / Image Info)
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct ImageMetadata {
    pub width: u32,
    pub height: u32,
    pub color_type: String,
    pub bit_depth: u8,
    pub dpi: Option<u32>,
    /// Données EXIF
    pub exif: HashMap<String, String>,
    /// Date de prise de vue
    pub date_taken: Option<String>,
    /// Appareil photo
    pub camera_model: Option<String>,
    /// Géolocalisation
    pub gps: Option<ImageGps>,
}

#[derive(Debug, Clone, Default)]
pub struct ImageGps {
    pub latitude: f64,
    pub longitude: f64,
    pub altitude: Option<f64>,
}

// =============================================================================
// OCR (TEXT REGIONS)
// =============================================================================

#[derive(Debug, Clone)]
pub struct ImageTextRegion {
    /// Texte extrait
    pub text: String,
    /// Confiance (0.0 - 1.0)
    pub confidence: f32,
    /// Boîte englobante (Bounding Box) en pixels
    pub bbox: ImageRect,
    /// Lignes de texte individuelles
    pub lines: Vec<ImageTextLine>,
    /// Type de région (Paragraphe, Titre, Légende)
    pub region_type: ImageRegionType,
}

#[derive(Debug, Clone)]
pub struct ImageTextLine {
    pub text: String,
    pub confidence: f32,
    pub bbox: ImageRect,
    pub words: Vec<ImageWord>,
}

#[derive(Debug, Clone)]
pub struct ImageWord {
    pub text: String,
    pub confidence: f32,
    pub bbox: ImageRect,
}

#[derive(Debug, Clone, Default)]
pub enum ImageRegionType {
    #[default]
    Paragraph,
    Heading,
    Caption,
    Table,
    Signature,
    Watermark,
}

// =============================================================================
// DETECTION D'OBJETS
// =============================================================================

#[derive(Debug, Clone)]
pub struct DetectedObject {
    pub label: String,
    pub confidence: f32,
    pub bbox: ImageRect,
}

// =============================================================================
// GÉOMÉTRIE
// =============================================================================

#[derive(Debug, Clone, Copy, Default)]
pub struct ImageRect {
    pub x: u32,
    pub y: u32,
    pub width: u32,
    pub height: u32,
}
