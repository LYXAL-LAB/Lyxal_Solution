//! Lyxal Document Engine
//!
//! A unified document processing library supporting:
//! - Document model (AST semantic)
//! - Multiple format interpreters (Word, Excel, Slides, Draw)
//! - Parsing (PDF, future: DOCX, XLSX)
//! - Rendering (PDF, SVG)
//!
//! # Architecture
//! ```text
//! Input File (PDF/DOCX/XLSX)
//!        ↓
//!    [PARSER]  ← parser module
//!        ↓
//!    JSON/AST  ← core model
//!        ↓
//!    [RENDER]  ← render module
//!        ↓
//! Output (PDF/SVG/HTML)
//! ```

pub mod core;
pub mod validate;
pub mod ops;
pub mod serialize;
pub mod history;
pub mod identity;
pub mod word;
pub mod excel;
pub mod slides;
pub mod draw;
pub mod styles;
pub mod parser;
pub mod render;
pub mod vendors;

#[cfg(test)]
mod tests;

// Core document model
pub use crate::core::*;
pub use crate::identity::{Hash, document_hash, DocumentDigest};

// Format interpreters
pub use crate::word::{WordInterpreter, WordLayoutEngine, WordPageLayout, PageSettings, WordError};
pub use crate::excel::{ExcelInterpreter, ExcelLayoutEngine, ExcelPhysicalLayout, GridSettings, ExcelError};
pub use crate::slides::{SlidesInterpreter, SlidesLayoutEngine, SlidesPhysicalLayout, ViewportSettings, SlidesError};
pub use crate::draw::{DrawInterpreter, DrawLayoutEngine, DrawPhysicalLayout, CanvasSettings, DrawError};

// Styling
pub use crate::styles::{StyleEngine, StyleSheet, StyleError, RenderContext};

// Parsing (PDF, future: DOCX, XLSX)
pub use crate::parser::{
    // PDF parser
    open_pdf, open_pdf_with_password, open_pdf_from_path, page_count,
    build_document, extract_metadata, extract_text,
    parse_acroform, parse_annotations, fill_form_field,
    validate_signatures, check_encryption,
    PdfDocument, PdfPage, PdfElement, PdfMetadata,
    PdfFormField, PdfAnnotation, SignatureValidationResult,
    PdfBBox, PdfRgba, PdfColorSpace,
};

// Rendering (PDF + SVG)
pub use crate::render::pdf::{PdfRenderer, PdfRenderError, FontProvider};
pub use crate::render::svg::{SvgRenderer, SvgRenderError};
