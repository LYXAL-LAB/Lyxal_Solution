//! PDF Document Model for reading

use crate::parser::pdf::common::{PdfBBox, PdfRgba, PdfColorSpace};

#[derive(Debug, Clone, PartialEq)]
pub struct PdfMetadata {
    pub title: Option<String>,
    pub author: Option<String>,
    pub creator: Option<String>,
    pub producer: Option<String>,
}

#[derive(Debug, Clone, PartialEq)]
pub enum PdfAnnotationType {
    Link,
    Text,
    Highlight,
    Underline,
}

#[derive(Debug, Clone, PartialEq)]
pub struct PdfAnnotation {
    pub annot_type: PdfAnnotationType,
    pub rect: PdfBBox,
    pub contents: Option<String>,
    pub target: Option<String>,
    pub quads: Option<Vec<PdfBBox>>,
    pub page_index: usize,
}

/// Représentation complète d'un document PDF.
#[derive(Debug, Clone, PartialEq)]
pub struct PdfDocument {
    pub metadata: PdfMetadata,
    pub pages: Vec<PdfPage>,
    pub form_fields: Vec<PdfFormField>,
    pub annotations: Vec<PdfAnnotation>,
    /// Table des matières / Bookmarks
    pub bookmarks: Vec<PdfBookmark>,
    /// Pièces jointes
    pub attachments: Vec<PdfAttachment>,
    /// Destinations nommées pour liens internes
    pub named_destinations: Vec<PdfNamedDestination>,
    /// Structure logique du document (PDF balisé)
    pub structure_tree: Option<PdfStructureTree>,
}

// ============================================================================
// BOOKMARKS / TABLE DES MATIÈRES
// ============================================================================

/// Bookmark (outline item) - élément de la table des matières
#[derive(Debug, Clone, PartialEq)]
pub struct PdfBookmark {
    /// Titre affiché
    pub title: String,
    /// Page cible (0-indexed)
    pub page_index: Option<usize>,
    /// Position Y sur la page cible
    pub y_position: Option<f32>,
    /// Destination nommée (alternative à page_index)
    pub named_dest: Option<String>,
    /// URI externe (si lien web)
    pub uri: Option<String>,
    /// Sous-bookmarks (structure hiérarchique)
    pub children: Vec<PdfBookmark>,
    /// Niveau dans la hiérarchie (0 = racine)
    pub level: usize,
    /// État ouvert/fermé par défaut
    pub is_open: bool,
}

// ============================================================================
// PIÈCES JOINTES
// ============================================================================

/// Pièce jointe embarquée dans le PDF
#[derive(Debug, Clone, PartialEq)]
pub struct PdfAttachment {
    /// Nom du fichier
    pub filename: String,
    /// Description optionnelle
    pub description: Option<String>,
    /// Type MIME
    pub mime_type: Option<String>,
    /// Date de création
    pub creation_date: Option<String>,
    /// Date de modification
    pub modification_date: Option<String>,
    /// Taille en octets
    pub size: usize,
    /// Contenu binaire décompressé
    pub data: Vec<u8>,
    /// Checksum (si disponible)
    pub checksum: Option<String>,
}

// ============================================================================
// DESTINATIONS NOMMÉES
// ============================================================================

/// Destination nommée pour navigation interne
#[derive(Debug, Clone, PartialEq)]
pub struct PdfNamedDestination {
    /// Nom de la destination
    pub name: String,
    /// Page cible (0-indexed)
    pub page_index: usize,
    /// Type de destination
    pub dest_type: PdfDestinationType,
    /// Coordonnées selon le type
    pub left: Option<f32>,
    pub top: Option<f32>,
    pub right: Option<f32>,
    pub bottom: Option<f32>,
    pub zoom: Option<f32>,
}

/// Types de destinations PDF
#[derive(Debug, Clone, PartialEq)]
pub enum PdfDestinationType {
    /// /XYZ left top zoom - position et zoom spécifiques
    XYZ,
    /// /Fit - ajuster la page entière
    Fit,
    /// /FitH top - ajuster horizontalement
    FitH,
    /// /FitV left - ajuster verticalement
    FitV,
    /// /FitR left bottom right top - rectangle spécifique
    FitR,
    /// /FitB - ajuster au bounding box
    FitB,
    /// /FitBH top - bounding box horizontal
    FitBH,
    /// /FitBV left - bounding box vertical
    FitBV,
}

// ============================================================================
// STRUCTURE TREE (PDF BALISÉ / TAGGED PDF)
// ============================================================================

/// Arbre de structure pour PDF balisé
#[derive(Debug, Clone, PartialEq)]
pub struct PdfStructureTree {
    /// Éléments racines de la structure
    pub children: Vec<PdfStructureElement>,
    /// Mapping des rôles personnalisés
    pub role_map: Vec<(String, String)>,
}

/// Élément de structure (tag sémantique)
#[derive(Debug, Clone, PartialEq)]
pub struct PdfStructureElement {
    /// Type de structure (Document, Part, Sect, P, H1-H6, Table, TR, TD, Figure, etc.)
    pub struct_type: PdfStructureType,
    /// Titre optionnel
    pub title: Option<String>,
    /// Texte alternatif (pour accessibilité)
    pub alt_text: Option<String>,
    /// Langue
    pub lang: Option<String>,
    /// ID unique
    pub id: Option<String>,
    /// Contenu textuel associé
    pub actual_text: Option<String>,
    /// Indices des pages concernées
    pub page_indices: Vec<usize>,
    /// Éléments enfants
    pub children: Vec<PdfStructureElement>,
    /// Attributs additionnels
    pub attributes: Vec<(String, String)>,
}

/// Types de structure sémantique PDF
#[derive(Debug, Clone, PartialEq)]
pub enum PdfStructureType {
    // Structure du document
    Document,
    Part,
    Art,
    Sect,
    Div,
    
    // Titres
    H,
    H1,
    H2,
    H3,
    H4,
    H5,
    H6,
    
    // Contenu textuel
    P,
    L,      // Liste
    LI,     // Item de liste
    Lbl,    // Label
    LBody,  // Corps de liste
    
    // Tables
    Table,
    TR,
    TH,
    TD,
    THead,
    TBody,
    TFoot,
    
    // Éléments inline
    Span,
    Quote,
    Note,
    Reference,
    BibEntry,
    Code,
    
    // Éléments spéciaux
    Figure,
    Formula,
    Form,
    
    // Autres
    Link,
    Annot,
    Ruby,
    Warichu,
    
    // Type personnalisé
    Other(String),
}

/// Représentation minimale d'une page (texte brut uniquement).
#[derive(Debug, Clone, PartialEq)]
pub struct PdfPage {
    pub index: usize,
    pub text: String,
    pub elements: Vec<PdfElement>,
    pub lines: Vec<PdfTextLine>,
}

#[derive(Debug, Clone, PartialEq)]
pub enum PdfClipRule {
    NonZero,
    EvenOdd,
}

#[derive(Debug, Clone, PartialEq)]
pub struct PdfClipPath {
    pub path: PdfPath,
    pub rule: PdfClipRule,
}

#[derive(Debug, Clone, PartialEq)]
pub struct PdfClipStack {
    pub clips: Vec<PdfClipPath>,
}

#[derive(Debug, Clone, PartialEq)]
pub enum PdfBlendMode {
    Normal,
    Multiply,
    Screen,
    Overlay,
    Darken,
    Lighten,
    ColorDodge,
    ColorBurn,
    HardLight,
    SoftLight,
    Difference,
    Exclusion,
    Hue,
    Saturation,
    Color,
    Luminosity,
    Other(String),
}

#[derive(Debug, Clone, PartialEq)]
pub struct PdfTransparency {
    pub fill_alpha: f32,
    pub stroke_alpha: f32,
    pub blend_mode: PdfBlendMode,
}

impl Default for PdfTransparency {
    fn default() -> Self {
        Self {
            fill_alpha: 1.0,
            stroke_alpha: 1.0,
            blend_mode: PdfBlendMode::Normal,
        }
    }
}

/// Élément textuel positionné simplement.
#[derive(Debug, Clone, PartialEq)]
pub struct PdfTextElement {
    pub content: String,
    pub x: f32,
    pub y: f32,
    pub font_size: f32,
    pub rendering_mode: PdfTextRenderingMode,
    pub fill_color: PdfRgba,
    pub stroke_color: Option<PdfRgba>,
    pub stroke_width: Option<f32>,
    pub clip: Option<PdfClipStack>,
    pub transparency: PdfTransparency,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum PdfTextRenderingMode {
    Fill = 0,
    Stroke = 1,
    FillStroke = 2,
    Invisible = 3,
    FillClip = 4,
    StrokeClip = 5,
    FillStrokeClip = 6,
    Clip = 7,
}

/// Ligne de texte issue du wrapping simple.
#[derive(Debug, Clone, PartialEq)]
pub struct PdfTextLine {
    pub elements: Vec<PdfTextElement>,
    pub width: f32,
    pub y: f32,
    pub line_height: f32,
}

/// Élément image.
#[derive(Debug, Clone, PartialEq)]
pub struct PdfImage {
    pub width: u32,
    pub height: u32,
    pub data: Vec<u8>,
    pub color_space: PdfColorSpace,
    pub bits_per_component: Option<u8>,
    pub x: f32,
    pub y: f32,
    pub clip: Option<PdfClipStack>,
    pub transparency: PdfTransparency,
}

/// Opération de chemin vectoriel.
#[derive(Debug, Clone, PartialEq)]
pub enum PdfPathOp {
    MoveTo { x: f32, y: f32 },
    LineTo { x: f32, y: f32 },
    CurveTo {
        x1: f32,
        y1: f32,
        x2: f32,
        y2: f32,
        x3: f32,
        y3: f32,
    },
    ClosePath,
    Rectangle { x: f32, y: f32, width: f32, height: f32 },
}

/// Règle de remplissage pour les chemins.
#[derive(Debug, Clone, PartialEq)]
pub enum FillRule {
    NonZero,
    EvenOdd,
}

/// Chemin vectoriel complet.
#[derive(Debug, Clone, PartialEq)]
pub struct PdfPath {
    pub ops: Vec<PdfPathOp>,
    pub stroke_color: PdfRgba,
    pub fill_color: PdfRgba,
    pub line_width: f32,
    pub fill_rule: FillRule,
    pub bbox: PdfBBox,
    pub clip: Option<PdfClipStack>,
    pub transparency: PdfTransparency,
}

/// Élément générique d'une page.
#[derive(Debug, Clone, PartialEq)]
pub enum PdfElement {
    Text(PdfTextElement),
    Image(PdfImage),
    Path(PdfPath),
}

/// Type de champ de formulaire.
#[derive(Debug, Clone, PartialEq)]
pub enum PdfFormFieldType {
    Text,
    Button,
    Choice,
    Signature,
    Other(String),
}

/// État d'un bouton (Checkbox/Radio).
#[derive(Debug, Clone, PartialEq)]
pub enum PdfButtonState {
    Off,
    On(String),
}

/// Champ de formulaire AcroForm.
#[derive(Debug, Clone, PartialEq)]
pub struct PdfFormField {
    pub name: String,
    pub field_type: PdfFormFieldType,
    pub value: Option<String>,
    pub rect: Option<PdfBBox>,
    pub page_index: Option<usize>,
    pub flags: Option<u32>,
    pub button_state: Option<PdfButtonState>,
    pub options: Option<Vec<String>>,
}

/// Valeur à écrire dans un champ de formulaire.
#[derive(Debug, Clone, PartialEq)]
pub enum PdfFormValue {
    Text(String),
    Button(PdfButtonState),
}

/// Erreur spécifique à la manipulation PDF.
#[derive(Debug)]
pub enum PdfError {
    DocumentError(lopdf::Error),
    FieldNotFound(String),
    InvalidValue(String),
    Internal(String),
}

impl std::fmt::Display for PdfError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            PdfError::DocumentError(e) => write!(f, "Document error: {}", e),
            PdfError::FieldNotFound(name) => write!(f, "Field not found: {}", name),
            PdfError::InvalidValue(msg) => write!(f, "Invalid value: {}", msg),
            PdfError::Internal(msg) => write!(f, "Internal error: {}", msg),
        }
    }
}

impl std::error::Error for PdfError {}

impl From<lopdf::Error> for PdfError {
    fn from(err: lopdf::Error) -> Self {
        PdfError::DocumentError(err)
    }
}
