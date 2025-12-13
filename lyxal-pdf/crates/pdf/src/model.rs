use crate::PdfMetadata;

/// Représentation minimale d'un document PDF.
pub struct PdfDocument {
    pub metadata: PdfMetadata,
    pub pages: Vec<PdfPage>,
}

/// Représentation minimale d'une page PDF, uniquement du texte brut.
pub struct PdfPage {
    pub index: usize,
    pub text: String,
}

