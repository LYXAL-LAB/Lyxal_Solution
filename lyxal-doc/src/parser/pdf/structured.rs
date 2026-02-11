//! Structured PDF model - separates text, graphics, and images

use super::model::{PdfElement, PdfImage, PdfPage, PdfPath, PdfTextLine, PdfDocument};

/// A structured page separating text, graphics and images
#[derive(Debug, Clone, PartialEq)]
pub struct PdfStructuredPage {
    pub index: usize,
    pub text_lines: Vec<PdfTextLine>,
    pub graphics: Vec<PdfPath>,
    pub images: Vec<PdfImage>,
}

/// Complete structured model (multi-page)
#[derive(Debug, Clone, PartialEq)]
pub struct PdfStructuredModel {
    pub pages: Vec<PdfStructuredPage>,
}

/// Builds a structured page from a PdfPage
pub fn build_structured_page(page: &PdfPage) -> PdfStructuredPage {
    let mut graphics = Vec::new();
    let mut images = Vec::new();

    for elem in &page.elements {
        match elem {
            PdfElement::Path(p) => graphics.push(p.clone()),
            PdfElement::Image(i) => images.push(i.clone()),
            PdfElement::Text(_) => {}
        }
    }

    PdfStructuredPage {
        index: page.index,
        text_lines: page.lines.clone(),
        graphics,
        images,
    }
}

/// Builds the complete structured model
pub fn build_structured_model(doc: &PdfDocument) -> PdfStructuredModel {
    let pages = doc.pages.iter().map(build_structured_page).collect();
    PdfStructuredModel { pages }
}
