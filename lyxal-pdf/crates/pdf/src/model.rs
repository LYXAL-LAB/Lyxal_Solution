use crate::PdfMetadata;

/// Représentation minimale d'un document PDF.
pub struct PdfDocument {
    pub metadata: PdfMetadata,
    pub pages: Vec<PdfPage>,
}

/// Éléments textuels positionnés (x, y) simplifiés.
pub struct PdfTextElement {
    pub content: String,
    pub x: f32,
    pub y: f32,
    pub font_size: f32,
}

/// Eléments d'une page (pour extension future).
pub enum PdfElement {
    Text(PdfTextElement),
}

/// Représentation minimale d'une page PDF, texte brut + éléments positionnés.
pub struct PdfPage {
    pub index: usize,
    pub text: String,
    pub elements: Vec<PdfElement>,
}

