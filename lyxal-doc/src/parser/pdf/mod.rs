//! PDF Parser - Parse and extract content from existing PDF files
//!
//! This module provides functionality to:
//! - Open and parse PDF files (including encrypted ones)
//! - Extract text, images, and vector graphics
//! - Parse form fields (AcroForm)
//! - Parse annotations (links, highlights, etc.)
//! - Parse bookmarks / table of contents
//! - Extract embedded file attachments
//! - Parse named destinations for internal navigation
//! - Parse structure tree for tagged PDFs
//! - Validate digital signatures
//! - Handle PDF security (encryption/decryption)

pub mod common;
pub mod model;
pub mod fonts;
pub mod manage;
pub mod forms;
pub mod annotations;
pub mod fill;
pub mod security;
pub mod signatures;
pub mod structured;
pub mod image_filters;
pub mod outlines;

// Re-export main types and functions
pub use model::*;
pub use common::{PdfBBox, PdfRgba, PdfColorSpace};
pub use manage::{build_document, extract_metadata, wrap_text_elements, extract_text, parse_text_elements};
pub use structured::build_structured_model;
pub use fill::fill_form_field;
pub use forms::parse_acroform;
pub use annotations::parse_annotations;
pub use security::{SecurityHandler, check_encryption, EncryptionMethod};
pub use signatures::{validate_signatures, SignatureValidationResult};

// Re-export new outline/structure functions
pub use outlines::{parse_bookmarks, parse_attachments, parse_named_destinations, parse_structure_tree};

use security::SecurityHandler as SecHandler;

/// Opens a PDF document from bytes (no password)
pub fn open_pdf(data: &[u8]) -> Result<lopdf::Document, lopdf::Error> {
    open_pdf_with_password(data, None)
}

/// Opens a PDF document from bytes with optional password
pub fn open_pdf_with_password(data: &[u8], password: Option<&str>) -> Result<lopdf::Document, lopdf::Error> {
    let mut doc = lopdf::Document::load_from(std::io::Cursor::new(data))?;
    
    if check_encryption(&doc).is_err() {
        let pwd = password.unwrap_or("");
        
        let encrypt_dict_obj = if let Ok(r) = doc.trailer.get(b"Encrypt").and_then(|o| o.as_reference()) {
            doc.get_object(r).ok().cloned()
        } else {
            doc.trailer.get(b"Encrypt").ok().cloned()
        };

        if let Some(obj) = encrypt_dict_obj {
            if let Ok(dict) = obj.as_dict() {
                if let Some(mut handler) = SecHandler::from_dictionary(dict, &doc.trailer) {
                    if handler.authenticate(pwd) {
                        handler.decrypt_document(&mut doc);
                        doc.trailer.remove(b"Encrypt");
                    } else {
                        return Err(std::io::Error::new(std::io::ErrorKind::Other, "Invalid password").into());
                    }
                } else {
                     return Err(std::io::Error::new(std::io::ErrorKind::Other, "Unsupported encryption handler").into());
                }
            }
        }
    }
    
    Ok(doc)
}

/// Opens a PDF document from a file path
pub fn open_pdf_from_path(path: impl AsRef<std::path::Path>) -> Result<lopdf::Document, lopdf::Error> {
    lopdf::Document::load(path)
}

/// Returns the number of pages in the document
pub fn page_count(doc: &lopdf::Document) -> usize {
    doc.get_pages().len()
}
