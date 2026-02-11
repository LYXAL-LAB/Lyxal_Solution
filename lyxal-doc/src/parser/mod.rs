//! # Parser Module - Format → AST Lyxal
//!
//! Ce module contient tous les parsers qui transforment des formats externes
//! vers l'AST Lyxal unifié.
//!
//! ## Règle d'or
//!
//! > **Un parser = un traducteur vers l'AST, jamais vers l'UI**
//!
//! L'UI ne sait lire que l'AST Lyxal. Elle n'importe rien directement.
//!
//! ## Architecture
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────┐
//! │                    FORMATS EXTERNES                         │
//! ├─────────┬─────────┬─────────┬─────────┬─────────┬──────────┤
//! │   PDF   │  DOCX   │   ODT   │  PPTX   │  XLSX   │  IMAGE   │
//! └────┬────┴────┬────┴────┬────┴────┬────┴────┬────┴────┬─────┘
//!      │         │         │         │         │         │
//!      ▼         ▼         ▼         ▼         ▼         ▼
//! ┌─────────────────────────────────────────────────────────────┐
//! │                      PARSERS                                │
//! │  pdf::    docx::   odt::   pptx::   xlsx::   image::       │
//! │  parser   parser   parser  parser   parser   parser        │
//! └─────────────────────────┬───────────────────────────────────┘
//!                           │
//!                           ▼
//! ┌─────────────────────────────────────────────────────────────┐
//! │                    AST LYXAL UNIFIÉ                         │
//! │                                                             │
//! │  Document { metadata, sections[], blocks[], import }        │
//! └─────────────────────────────────────────────────────────────┘
//!                           │
//!                           ▼
//! ┌─────────────────────────────────────────────────────────────┐
//! │                         UI                                  │
//! │              (Surrealist / Lyxal Editor)                    │
//! └─────────────────────────────────────────────────────────────┘
//! ```
//!
//! ## Parsers disponibles
//!
//! | Format | Module | Statut | Contrat |
//! |--------|--------|--------|---------|
//! | PDF    | `pdf`  | ✅ Complet | `PDF_TO_LYXAL_AST_CONTRACT.md` |
//! | DOCX   | `docx` | ✅ Complet | `DOCX_TO_LYXAL_AST_CONTRACT.md` |
//! | ODT    | `odt`  | ✅ Complet | `ODT_TO_LYXAL_AST_CONTRACT.md` |
//! | PPTX   | `pptx` | ✅ Complet | `PPTX_TO_LYXAL_AST_CONTRACT.md` |
//! | XLSX   | `xlsx` | ✅ Complet | `XLSX_TO_LYXAL_AST_CONTRACT.md` |
//! | Image  | `image`| ✅ Complet | `IMAGE_TO_LYXAL_AST_CONTRACT.md` |
//! | Markdown| `md`  | ✅ Complet | `MD_TO_LYXAL_AST_CONTRACT.md` |
//! | CSV    | `csv`  | ✅ Complet | `CSV_TO_LYXAL_AST_CONTRACT.md` |
//! | HTML   | `html` | ✅ Complet | `HTML_TO_LYXAL_AST_CONTRACT.md` |
//!
//! ## Utilisation
//!
//! ```rust,ignore
//! use lyxal_doc::parser::{pdf, docx, md};
//!
//! // Import PDF
//! let pdf_bytes = std::fs::read("document.pdf")?;
//! let doc = pdf::parse(&pdf_bytes)?;
//! let ast = pdf::to_ast(&doc)?;
//!
//! // Import Markdown
//! let md_bytes = std::fs::read("README.md")?;
//! let doc = md::parse(&md_bytes)?;
//! let ast = md::to_ast(&doc)?;
//! ```

// =============================================================================
// PARSERS ACTIFS
// =============================================================================

/// Parser PDF → AST Lyxal (✅ Complet)
pub mod pdf;

/// Parser DOCX → AST Lyxal (✅ Complet)
pub mod docx;

/// Parser ODT → AST Lyxal (✅ Complet)
pub mod odt;

/// Parser PPTX → AST Lyxal (✅ Complet)  
pub mod pptx;

/// Parser XLSX → AST Lyxal (✅ Complet)
pub mod xlsx;

/// Parser Image → AST Lyxal via OCR (✅ Complet)
pub mod image;

/// Parser Markdown → AST Lyxal (✅ Complet)
pub mod md;

/// Parser CSV → AST Lyxal (✅ Complet)
pub mod csv;

/// Parser HTML → AST Lyxal (✅ Complet)
pub mod html;

// =============================================================================
// RE-EXPORTS PRINCIPAUX
// =============================================================================

// PDF (complet)
pub use pdf::{
    // Core functions
    open_pdf, open_pdf_with_password, open_pdf_from_path, page_count,
    build_document, extract_metadata, extract_text,
    // Bookmarks & structure
    parse_bookmarks, parse_attachments, parse_named_destinations, parse_structure_tree,
    // Forms & annotations
    parse_acroform, parse_annotations, fill_form_field,
    // Security
    validate_signatures, check_encryption,
    // Types
    PdfDocument, PdfPage, PdfElement, PdfMetadata,
    PdfFormField, PdfAnnotation, SignatureValidationResult,
    PdfBookmark, PdfAttachment, PdfNamedDestination, PdfStructureTree,
    // Common types
    PdfBBox, PdfRgba, PdfColorSpace,
};

// =============================================================================
// TYPES COMMUNS (partagés entre parsers)
// =============================================================================

/// Métadonnées d'import attachées à chaque document importé
#[derive(Debug, Clone, PartialEq)]
pub struct ImportMetadata {
    /// Source du document ("pdf", "docx", "odt", etc.)
    pub source: String,
    /// Nom du fichier original
    pub source_file: Option<String>,
    /// Version du format source
    pub format_version: Option<String>,
    /// Score de confiance (0.0 - 1.0)
    pub confidence: f32,
    /// Import avec perte de données ?
    pub lossy: bool,
    /// Timestamp d'import
    pub imported_at: String,
    /// Version du parser utilisé
    pub parser_version: String,
    /// Avertissements générés
    pub warnings: Vec<ImportWarning>,
    /// Statistiques d'extraction
    pub stats: ImportStats,
}

/// Avertissement d'import
#[derive(Debug, Clone, PartialEq)]
pub struct ImportWarning {
    pub warning_type: String,
    pub message: String,
    pub details: Option<String>,
}

/// Statistiques d'extraction
#[derive(Debug, Clone, PartialEq, Default)]
pub struct ImportStats {
    pub pages: usize,
    pub text_elements: usize,
    pub images: usize,
    pub tables: usize,
    pub form_fields: usize,
    pub links: usize,
}

impl Default for ImportMetadata {
    fn default() -> Self {
        Self {
            source: "unknown".to_string(),
            source_file: None,
            format_version: None,
            confidence: 0.0,
            lossy: false,
            imported_at: chrono_now(),
            parser_version: env!("CARGO_PKG_VERSION").to_string(),
            warnings: Vec::new(),
            stats: ImportStats::default(),
        }
    }
}

fn chrono_now() -> String {
    // Simple ISO 8601 timestamp
    use std::time::{SystemTime, UNIX_EPOCH};
    let duration = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default();
    format!("{}Z", duration.as_secs())
}

/// Résultat générique d'un parser
pub type ParseResult<T> = Result<T, ParseError>;

/// Erreur de parsing générique
#[derive(Debug)]
pub enum ParseError {
    /// Format non reconnu
    UnrecognizedFormat(String),
    /// Fichier corrompu
    CorruptedFile(String),
    /// Fonctionnalité non supportée
    UnsupportedFeature(String),
    /// Erreur d'IO
    IoError(std::io::Error),
    /// Erreur spécifique au format
    FormatError(String),
    /// Erreur XML
    XmlError(String),
    /// Mot de passe requis
    PasswordRequired,
    /// Mot de passe incorrect
    InvalidPassword,
}

impl std::fmt::Display for ParseError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::UnrecognizedFormat(s) => write!(f, "Unrecognized format: {}", s),
            Self::CorruptedFile(s) => write!(f, "Corrupted file: {}", s),
            Self::UnsupportedFeature(s) => write!(f, "Unsupported feature: {}", s),
            Self::IoError(e) => write!(f, "IO error: {}", e),
            Self::FormatError(s) => write!(f, "Format error: {}", s),
            Self::XmlError(s) => write!(f, "XML error: {}", s),
            Self::PasswordRequired => write!(f, "Password required"),
            Self::InvalidPassword => write!(f, "Invalid password"),
        }
    }
}

impl std::error::Error for ParseError {}

impl From<std::io::Error> for ParseError {
    fn from(err: std::io::Error) -> Self {
        Self::IoError(err)
    }
}
