//! DOCX Document Model
//!
//! Types représentant la structure complète d'un document DOCX.
//! 
//! ## Couverture OOXML (Office Open XML)
//! 
//! Ce modèle couvre l'intégralité du format DOCX tel que défini par
//! ECMA-376 et ISO/IEC 29500.

use std::collections::HashMap;

// =============================================================================
// DOCUMENT PRINCIPAL
// =============================================================================

/// Document DOCX parsé (structure intermédiaire)
#[derive(Debug, Clone, Default)]
pub struct DocxDocument {
    /// Métadonnées du document
    pub metadata: DocxMetadata,
    /// Corps du document (paragraphes, tables, etc.)
    pub body: Vec<DocxElement>,
    /// Sections du document (avec headers/footers)
    pub sections: Vec<DocxSection>,
    /// Styles définis
    pub styles: Vec<DocxStyle>,
    /// Définitions de numérotation (listes)
    pub numbering: Vec<DocxNumbering>,
    /// Définitions abstraites de numérotation
    pub abstract_numberings: Vec<DocxAbstractNum>,
    /// Commentaires
    pub comments: Vec<DocxComment>,
    /// Notes de bas de page
    pub footnotes: Vec<DocxFootnote>,
    /// Notes de fin
    pub endnotes: Vec<DocxEndnote>,
    /// Headers (headerId -> contenu)
    pub headers: HashMap<String, DocxHeaderFooter>,
    /// Footers (footerId -> contenu)
    pub footers: HashMap<String, DocxHeaderFooter>,
    /// Images embarquées (rId -> données)
    pub images: HashMap<String, DocxImage>,
    /// Hyperliens (rId -> URL)
    pub hyperlinks: HashMap<String, String>,
    /// Révisions (Track Changes)
    pub revisions: DocxRevisionInfo,
    /// Custom XML Parts
    pub custom_xml: Vec<DocxCustomXml>,
    /// Thème du document
    pub theme: Option<DocxTheme>,
    /// Paramètres du document
    pub settings: DocxSettings,
    /// Avertissements lors du parsing
    pub warnings: Vec<String>,
}

// =============================================================================
// SECTIONS (w:sectPr)
// =============================================================================

/// Section du document avec ses propriétés de mise en page
#[derive(Debug, Clone, Default)]
pub struct DocxSection {
    /// Éléments de la section
    pub elements: Vec<DocxElement>,
    /// Propriétés de la section
    pub properties: DocxSectionProperties,
}

/// Propriétés de section (w:sectPr)
#[derive(Debug, Clone, Default)]
pub struct DocxSectionProperties {
    /// Type de section (continuous, nextPage, evenPage, oddPage)
    pub section_type: Option<DocxSectionType>,
    /// Taille de page
    pub page_size: Option<DocxPageSize>,
    /// Marges de page
    pub page_margins: Option<DocxPageMargins>,
    /// Orientation
    pub orientation: DocxOrientation,
    /// Nombre de colonnes
    pub columns: Option<DocxColumns>,
    /// Numérotation de page
    pub page_numbering: Option<DocxPageNumbering>,
    /// Références header (first, default, even)
    pub header_refs: Vec<DocxHeaderFooterRef>,
    /// Références footer (first, default, even)
    pub footer_refs: Vec<DocxHeaderFooterRef>,
    /// Bordures de page
    pub page_borders: Option<DocxPageBorders>,
    /// Numéros de ligne
    pub line_numbers: Option<DocxLineNumbers>,
}

#[derive(Debug, Clone, Default)]
pub enum DocxSectionType {
    #[default]
    NextPage,
    Continuous,
    EvenPage,
    OddPage,
    NextColumn,
}

#[derive(Debug, Clone)]
pub struct DocxPageSize {
    /// Largeur en twips
    pub width: u32,
    /// Hauteur en twips
    pub height: u32,
    /// Code de format (A4, Letter, etc.)
    pub code: Option<u32>,
}

#[derive(Debug, Clone)]
pub struct DocxPageMargins {
    pub top: i32,
    pub bottom: i32,
    pub left: i32,
    pub right: i32,
    pub header: i32,
    pub footer: i32,
    pub gutter: i32,
}

#[derive(Debug, Clone, Default)]
pub enum DocxOrientation {
    #[default]
    Portrait,
    Landscape,
}

#[derive(Debug, Clone)]
pub struct DocxColumns {
    pub num: u32,
    pub space: Option<u32>,
    pub equal_width: bool,
    pub columns: Vec<DocxColumn>,
    pub separator: bool,
}

#[derive(Debug, Clone)]
pub struct DocxColumn {
    pub width: u32,
    pub space: Option<u32>,
}

#[derive(Debug, Clone)]
pub struct DocxPageNumbering {
    pub format: Option<DocxNumberFormat>,
    pub start: Option<u32>,
    pub chapter_style: Option<String>,
    pub chapter_separator: Option<String>,
}

#[derive(Debug, Clone)]
pub struct DocxHeaderFooterRef {
    pub ref_type: DocxHeaderFooterType,
    pub rel_id: String,
}

#[derive(Debug, Clone)]
pub enum DocxHeaderFooterType {
    Default,
    First,
    Even,
}

#[derive(Debug, Clone)]
pub struct DocxPageBorders {
    pub top: Option<DocxBorder>,
    pub bottom: Option<DocxBorder>,
    pub left: Option<DocxBorder>,
    pub right: Option<DocxBorder>,
    pub offset_from: DocxBorderOffsetFrom,
    pub z_order: DocxBorderZOrder,
}

#[derive(Debug, Clone, Default)]
pub enum DocxBorderOffsetFrom {
    #[default]
    Page,
    Text,
}

#[derive(Debug, Clone, Default)]
pub enum DocxBorderZOrder {
    #[default]
    Front,
    Back,
}

#[derive(Debug, Clone)]
pub struct DocxLineNumbers {
    pub count_by: Option<u32>,
    pub start: Option<u32>,
    pub restart: DocxLineNumberRestart,
    pub distance: Option<u32>,
}

#[derive(Debug, Clone, Default)]
pub enum DocxLineNumberRestart {
    #[default]
    NewPage,
    NewSection,
    Continuous,
}

// =============================================================================
// HEADERS / FOOTERS
// =============================================================================

/// Contenu d'un header ou footer
#[derive(Debug, Clone, Default)]
pub struct DocxHeaderFooter {
    /// ID du header/footer
    pub id: String,
    /// Contenu
    pub content: Vec<DocxElement>,
}

// =============================================================================
// TRACK CHANGES (Révisions)
// =============================================================================

/// Informations sur les révisions du document
#[derive(Debug, Clone, Default)]
pub struct DocxRevisionInfo {
    /// Track changes activé
    pub tracking_enabled: bool,
    /// Révisions d'insertion
    pub insertions: Vec<DocxRevision>,
    /// Révisions de suppression
    pub deletions: Vec<DocxRevision>,
    /// Déplacements
    pub moves: Vec<DocxMove>,
    /// Changements de formatage
    pub format_changes: Vec<DocxFormatChange>,
}

/// Révision (insertion ou suppression)
#[derive(Debug, Clone)]
pub struct DocxRevision {
    /// ID unique
    pub id: u32,
    /// Auteur
    pub author: String,
    /// Date
    pub date: Option<String>,
    /// Type de révision
    pub revision_type: DocxRevisionType,
    /// Contenu concerné
    pub content: Vec<DocxElement>,
}

#[derive(Debug, Clone)]
pub enum DocxRevisionType {
    Insert,
    Delete,
    MoveFrom,
    MoveTo,
}

/// Déplacement de contenu
#[derive(Debug, Clone)]
pub struct DocxMove {
    /// ID unique du déplacement
    pub id: u32,
    /// Auteur
    pub author: String,
    /// Date
    pub date: Option<String>,
    /// ID de la source (moveFrom)
    pub from_id: u32,
    /// ID de la destination (moveTo)
    pub to_id: u32,
}

/// Changement de formatage
#[derive(Debug, Clone)]
pub struct DocxFormatChange {
    pub id: u32,
    pub author: String,
    pub date: Option<String>,
    pub property_changed: String,
    pub old_value: Option<String>,
    pub new_value: Option<String>,
}

// =============================================================================
// DRAWING ML (Images et formes)
// =============================================================================

/// Élément graphique (DrawingML)
#[derive(Debug, Clone)]
pub enum DocxDrawing {
    /// Image inline (dans le flux de texte)
    Inline(DocxInlineDrawing),
    /// Image/forme ancrée (flottante)
    Anchor(DocxAnchorDrawing),
}

/// Dessin inline
#[derive(Debug, Clone)]
pub struct DocxInlineDrawing {
    /// Étendue (dimensions)
    pub extent: DocxExtent,
    /// Effet (ombre, etc.)
    pub effect_extent: Option<DocxEffectExtent>,
    /// Identifiant du document drawing
    pub doc_pr: DocxDocProperties,
    /// Graphique ou image
    pub graphic: DocxGraphic,
}

/// Dessin ancré (flottant)
#[derive(Debug, Clone)]
pub struct DocxAnchorDrawing {
    /// Étendue
    pub extent: DocxExtent,
    /// Propriétés du document
    pub doc_pr: DocxDocProperties,
    /// Graphique
    pub graphic: DocxGraphic,
    /// Position horizontale
    pub position_h: DocxPositionH,
    /// Position verticale
    pub position_v: DocxPositionV,
    /// Distance du texte
    pub distance_from_text: DocxDistanceFromText,
    /// Simple position (vs relative)
    pub simple_pos: bool,
    /// Z-order (devant/derrière)
    pub relative_height: u32,
    /// Derrière le document
    pub behind_doc: bool,
    /// Verrouillé
    pub locked: bool,
    /// Layout en cellule
    pub layout_in_cell: bool,
    /// Permettre le chevauchement
    pub allow_overlap: bool,
    /// Habillage du texte
    pub wrap: DocxTextWrap,
}

#[derive(Debug, Clone)]
pub struct DocxExtent {
    /// Largeur en EMUs (English Metric Units, 914400 = 1 inch)
    pub cx: i64,
    /// Hauteur en EMUs
    pub cy: i64,
}

#[derive(Debug, Clone)]
pub struct DocxEffectExtent {
    pub left: i64,
    pub top: i64,
    pub right: i64,
    pub bottom: i64,
}

#[derive(Debug, Clone)]
pub struct DocxDocProperties {
    pub id: u32,
    pub name: String,
    pub description: Option<String>,
    pub title: Option<String>,
}

#[derive(Debug, Clone)]
pub enum DocxGraphic {
    /// Image (picture)
    Picture(DocxPicture),
    /// Forme (shape)
    Shape(DocxShape),
    /// Graphique (chart)
    Chart(DocxChart),
    /// Diagramme (SmartArt)
    Diagram(DocxDiagram),
}

#[derive(Debug, Clone)]
pub struct DocxPicture {
    /// Référence vers l'image (rId)
    pub blip_rel_id: String,
    /// Compression
    pub compression: Option<String>,
    /// Remplissage
    pub fill: Option<DocxFill>,
    /// Transformation
    pub transform: Option<DocxTransform2D>,
}

#[derive(Debug, Clone)]
pub struct DocxShape {
    /// Type de forme preset
    pub preset: Option<String>,
    /// Géométrie custom
    pub custom_geometry: Option<String>,
    /// Remplissage
    pub fill: Option<DocxFill>,
    /// Contour
    pub outline: Option<DocxOutline>,
    /// Texte dans la forme
    pub text_body: Option<DocxTextBody>,
}

#[derive(Debug, Clone)]
pub struct DocxChart {
    /// Référence vers le chart (rId)
    pub rel_id: String,
}

#[derive(Debug, Clone)]
pub struct DocxDiagram {
    /// Référence vers les données
    pub data_rel_id: String,
    /// Référence vers le layout
    pub layout_rel_id: Option<String>,
    /// Référence vers le style
    pub style_rel_id: Option<String>,
    /// Référence vers les couleurs
    pub colors_rel_id: Option<String>,
}

#[derive(Debug, Clone)]
pub enum DocxFill {
    NoFill,
    Solid(DocxSolidFill),
    Gradient(DocxGradientFill),
    Pattern(DocxPatternFill),
    Picture(DocxPictureFill),
}

#[derive(Debug, Clone)]
pub struct DocxSolidFill {
    pub color: DocxColor,
}

#[derive(Debug, Clone)]
pub struct DocxGradientFill {
    pub stops: Vec<DocxGradientStop>,
    pub linear_angle: Option<i32>,
}

#[derive(Debug, Clone)]
pub struct DocxGradientStop {
    pub position: u32, // 0-100000
    pub color: DocxColor,
}

#[derive(Debug, Clone)]
pub struct DocxPatternFill {
    pub preset: String,
    pub foreground: DocxColor,
    pub background: DocxColor,
}

#[derive(Debug, Clone)]
pub struct DocxPictureFill {
    pub blip_rel_id: String,
    pub tile: bool,
}

#[derive(Debug, Clone)]
pub struct DocxOutline {
    pub width: u32, // EMUs
    pub fill: Option<DocxFill>,
    pub dash: Option<String>,
    pub cap: Option<String>,
    pub join: Option<String>,
}

#[derive(Debug, Clone)]
pub struct DocxTextBody {
    pub paragraphs: Vec<DocxParagraph>,
    pub body_properties: Option<DocxBodyProperties>,
}

#[derive(Debug, Clone)]
pub struct DocxBodyProperties {
    pub anchor: Option<String>,
    pub anchor_center: bool,
    pub vertical: Option<String>,
    pub wrap: Option<String>,
    pub rotation: Option<i32>,
}

#[derive(Debug, Clone)]
pub struct DocxTransform2D {
    pub offset_x: i64,
    pub offset_y: i64,
    pub extent_cx: i64,
    pub extent_cy: i64,
    pub rotation: Option<i32>,
    pub flip_h: bool,
    pub flip_v: bool,
}

#[derive(Debug, Clone)]
pub struct DocxPositionH {
    pub relative_from: DocxHorizontalRelative,
    pub position: DocxPositionType,
}

#[derive(Debug, Clone)]
pub struct DocxPositionV {
    pub relative_from: DocxVerticalRelative,
    pub position: DocxPositionType,
}

#[derive(Debug, Clone)]
pub enum DocxPositionType {
    Absolute(i64), // EMUs
    Align(String), // left, center, right, inside, outside
    Percent(i32),
}

#[derive(Debug, Clone)]
pub enum DocxHorizontalRelative {
    Margin,
    Page,
    Column,
    Character,
    LeftMargin,
    RightMargin,
    InsideMargin,
    OutsideMargin,
}

#[derive(Debug, Clone)]
pub enum DocxVerticalRelative {
    Margin,
    Page,
    Paragraph,
    Line,
    TopMargin,
    BottomMargin,
    InsideMargin,
    OutsideMargin,
}

#[derive(Debug, Clone)]
pub struct DocxDistanceFromText {
    pub top: u32,
    pub bottom: u32,
    pub left: u32,
    pub right: u32,
}

#[derive(Debug, Clone)]
pub enum DocxTextWrap {
    None,
    Square(DocxWrapSquare),
    Tight(DocxWrapPolygon),
    Through(DocxWrapPolygon),
    TopAndBottom,
    BehindText,
    InFrontOfText,
}

#[derive(Debug, Clone)]
pub struct DocxWrapSquare {
    pub wrap_text: String, // bothSides, left, right, largest
    pub distance_top: Option<u32>,
    pub distance_bottom: Option<u32>,
    pub distance_left: Option<u32>,
    pub distance_right: Option<u32>,
}

#[derive(Debug, Clone)]
pub struct DocxWrapPolygon {
    pub edited: bool,
    pub points: Vec<DocxWrapPoint>,
}

#[derive(Debug, Clone)]
pub struct DocxWrapPoint {
    pub x: i64,
    pub y: i64,
}

#[derive(Debug, Clone)]
pub enum DocxColor {
    Rgb(String),        // RRGGBB
    Theme(DocxThemeColor),
    System(String),
}

#[derive(Debug, Clone)]
pub struct DocxThemeColor {
    pub val: String,    // accent1, accent2, dk1, lt1, etc.
    pub lum_mod: Option<i32>,
    pub lum_off: Option<i32>,
    pub shade: Option<i32>,
    pub tint: Option<i32>,
}

// =============================================================================
// CHAMPS COMPLEXES (Fields)
// =============================================================================

/// Champ complexe (w:fldChar + w:instrText)
#[derive(Debug, Clone)]
pub struct DocxComplexField {
    /// Type de champ
    pub field_type: DocxComplexFieldType,
    /// Instruction brute
    pub instruction: String,
    /// Résultat calculé
    pub result: Option<String>,
    /// Champ verrouillé
    pub locked: bool,
    /// Sale (nécessite recalcul)
    pub dirty: bool,
}

#[derive(Debug, Clone)]
pub enum DocxComplexFieldType {
    /// Table des matières
    Toc(DocxTocField),
    /// Référence croisée
    Ref(DocxRefField),
    /// Champ de publipostage
    MergeField(DocxMergeField),
    /// Lien hypertexte
    Hyperlink(DocxHyperlinkField),
    /// Numéro de page
    Page,
    /// Nombre de pages
    NumPages,
    /// Date
    Date(DocxDateField),
    /// Heure
    Time(DocxTimeField),
    /// Auteur
    Author,
    /// Titre
    Title,
    /// Nom de fichier
    FileName,
    /// Séquence (numérotation automatique)
    Seq(DocxSeqField),
    /// Formule
    Formula(String),
    /// If conditionnel
    If(DocxIfField),
    /// Autre
    Other(String),
}

#[derive(Debug, Clone)]
pub struct DocxTocField {
    pub heading_levels: Option<String>,  // "1-3"
    pub outline_levels: Option<String>,
    pub use_hyperlinks: bool,
    pub preserve_tabs: bool,
    pub preserve_newlines: bool,
    pub entry_separator: Option<String>,
}

#[derive(Debug, Clone)]
pub struct DocxRefField {
    pub bookmark_name: String,
    pub ref_type: DocxRefType,
    pub hyperlink: bool,
    pub position_relative: bool,
}

#[derive(Debug, Clone)]
pub enum DocxRefType {
    PageRef,      // Numéro de page
    Ref,          // Texte du bookmark
    NoteRef,      // Numéro de note
    BookmarkText, // Texte marqué
}

#[derive(Debug, Clone)]
pub struct DocxMergeField {
    pub field_name: String,
    pub format: Option<String>,
    pub text_before: Option<String>,
    pub text_after: Option<String>,
    pub mapped_name: Option<String>,
    pub vertical_format: bool,
}

#[derive(Debug, Clone)]
pub struct DocxHyperlinkField {
    pub target: String,
    pub bookmark: Option<String>,
    pub screen_tip: Option<String>,
    pub target_frame: Option<String>,
}

#[derive(Debug, Clone)]
pub struct DocxDateField {
    pub format: Option<String>,
    pub calendar: Option<String>,
    pub lunar: bool,
    pub saka_era: bool,
}

#[derive(Debug, Clone)]
pub struct DocxTimeField {
    pub format: Option<String>,
}

#[derive(Debug, Clone)]
pub struct DocxSeqField {
    pub identifier: String,
    pub bookmark: Option<String>,
    pub format: Option<DocxNumberFormat>,
    pub reset: bool,
    pub hide_result: bool,
    pub next: bool,
    pub current: bool,
}

#[derive(Debug, Clone)]
pub struct DocxIfField {
    pub expression1: String,
    pub operator: String,
    pub expression2: String,
    pub true_text: String,
    pub false_text: String,
}

#[derive(Debug, Clone)]
pub enum DocxNumberFormat {
    Decimal,
    DecimalZero,
    UpperRoman,
    LowerRoman,
    UpperLetter,
    LowerLetter,
    Ordinal,
    CardinalText,
    OrdinalText,
    Hex,
    Chicago,
    Ideograph,
    JapaneseCounting,
    Aiueo,
    Iroha,
    Custom(String),
}

// =============================================================================
// CONTENT CONTROLS (SDT - Structured Document Tags)
// =============================================================================

/// Content Control (w:sdt)
#[derive(Debug, Clone)]
pub struct DocxContentControl {
    /// Propriétés du contrôle
    pub properties: DocxSdtProperties,
    /// Contenu
    pub content: Vec<DocxElement>,
}

#[derive(Debug, Clone)]
pub struct DocxSdtProperties {
    /// ID unique
    pub id: Option<u32>,
    /// Tag
    pub tag: Option<String>,
    /// Alias (label)
    pub alias: Option<String>,
    /// Verrouillage
    pub lock: Option<DocxSdtLock>,
    /// Placeholder
    pub placeholder: Option<DocxSdtPlaceholder>,
    /// Type de contrôle
    pub control_type: DocxSdtType,
    /// Lié à un Custom XML
    pub data_binding: Option<DocxDataBinding>,
    /// Apparence
    pub appearance: Option<String>,
    /// Couleur
    pub color: Option<String>,
}

#[derive(Debug, Clone)]
pub enum DocxSdtLock {
    ContentLocked,
    SdtLocked,
    SdtContentLocked,
    Unlocked,
}

#[derive(Debug, Clone)]
pub struct DocxSdtPlaceholder {
    pub doc_part: String,
}

#[derive(Debug, Clone)]
pub enum DocxSdtType {
    RichText,
    PlainText,
    Picture,
    DropDownList(Vec<DocxListItem>),
    ComboBox(Vec<DocxListItem>),
    Date(DocxSdtDate),
    Checkbox(DocxSdtCheckbox),
    Group,
    Bibliography,
    Citation,
    Equation,
    RepeatingSection,
    RepeatingSectionItem,
}

#[derive(Debug, Clone)]
pub struct DocxListItem {
    pub display_text: String,
    pub value: String,
}

#[derive(Debug, Clone)]
pub struct DocxSdtDate {
    pub format: Option<String>,
    pub locale: Option<String>,
    pub calendar: Option<String>,
    pub storage_mapping: Option<String>,
}

#[derive(Debug, Clone)]
pub struct DocxSdtCheckbox {
    pub checked: bool,
    pub checked_state: Option<DocxCheckboxState>,
    pub unchecked_state: Option<DocxCheckboxState>,
}

#[derive(Debug, Clone)]
pub struct DocxCheckboxState {
    pub val: String,
    pub font: Option<String>,
}

#[derive(Debug, Clone)]
pub struct DocxDataBinding {
    pub prefix_mappings: Option<String>,
    pub xpath: String,
    pub store_item_id: Option<String>,
}

// =============================================================================
// MATH (Office Math Markup Language - OMML)
// =============================================================================

/// Équation mathématique (m:oMath)
#[derive(Debug, Clone)]
pub struct DocxMath {
    /// Éléments de l'équation
    pub elements: Vec<DocxMathElement>,
    /// Justification
    pub justification: Option<DocxMathJustification>,
}

#[derive(Debug, Clone)]
pub enum DocxMathElement {
    /// Run de texte mathématique
    Run(DocxMathRun),
    /// Fraction
    Fraction(DocxMathFraction),
    /// Radical (racine)
    Radical(DocxMathRadical),
    /// Fonction (sin, cos, etc.)
    Function(DocxMathFunction),
    /// Délimiteur (parenthèses, crochets)
    Delimiter(DocxMathDelimiter),
    /// Équation linéaire (groupement)
    EquationArray(DocxMathEquationArray),
    /// Matrice
    Matrix(DocxMathMatrix),
    /// N-aire (somme, produit, intégrale)
    Nary(DocxMathNary),
    /// Limite
    LimitLower(DocxMathLimit),
    LimitUpper(DocxMathLimit),
    /// Exposant
    Superscript(DocxMathScript),
    /// Indice
    Subscript(DocxMathScript),
    /// Sous/sur-script
    SubSuperscript(DocxMathSubSup),
    /// Pré-script
    PreSubSuperscript(DocxMathSubSup),
    /// Barre (sur/sous)
    Bar(DocxMathBar),
    /// Accent
    Accent(DocxMathAccent),
    /// Boîte
    Box(DocxMathBox),
    /// Bordure
    BorderBox(DocxMathBorderBox),
    /// Groupe
    GroupChar(DocxMathGroupChar),
    /// Phantom (invisible)
    Phantom(DocxMathPhantom),
}

#[derive(Debug, Clone)]
pub struct DocxMathRun {
    pub text: String,
    pub properties: Option<DocxMathRunProperties>,
}

#[derive(Debug, Clone)]
pub struct DocxMathRunProperties {
    pub literal: bool,
    pub normal_text: bool,
    pub script: Option<DocxMathScript>,
    pub style: Option<DocxMathStyle>,
}

#[derive(Debug, Clone)]
pub enum DocxMathStyle {
    Plain,
    Bold,
    Italic,
    BoldItalic,
}

#[derive(Debug, Clone)]
pub struct DocxMathFraction {
    pub numerator: Vec<DocxMathElement>,
    pub denominator: Vec<DocxMathElement>,
    pub fraction_type: DocxFractionType,
}

#[derive(Debug, Clone)]
pub enum DocxFractionType {
    Bar,     // Standard avec barre
    Skewed,  // Oblique
    Linear,  // En ligne (a/b)
    NoBar,   // Sans barre (binomial)
}

#[derive(Debug, Clone)]
pub struct DocxMathRadical {
    pub degree: Option<Vec<DocxMathElement>>,
    pub base: Vec<DocxMathElement>,
    pub hide_degree: bool,
}

#[derive(Debug, Clone)]
pub struct DocxMathFunction {
    pub function_name: DocxMathFunctionName,
    pub base: Vec<DocxMathElement>,
}

#[derive(Debug, Clone)]
pub struct DocxMathFunctionName {
    pub elements: Vec<DocxMathElement>,
}

#[derive(Debug, Clone)]
pub struct DocxMathDelimiter {
    pub begin_char: Option<String>,
    pub end_char: Option<String>,
    pub separator_char: Option<String>,
    pub grow: bool,
    pub elements: Vec<Vec<DocxMathElement>>,
}

#[derive(Debug, Clone)]
pub struct DocxMathEquationArray {
    pub equations: Vec<Vec<DocxMathElement>>,
    pub max_dist: bool,
    pub obj_dist: bool,
    pub row_spacing: Option<u32>,
}

#[derive(Debug, Clone)]
pub struct DocxMathMatrix {
    pub rows: Vec<DocxMathMatrixRow>,
    pub base_justification: Option<DocxMathJustification>,
    pub column_gap: Option<u32>,
    pub column_spacing: Vec<Option<u32>>,
    pub row_spacing: Option<u32>,
}

#[derive(Debug, Clone)]
pub struct DocxMathMatrixRow {
    pub cells: Vec<Vec<DocxMathElement>>,
}

#[derive(Debug, Clone)]
pub struct DocxMathNary {
    pub chr: Option<String>,  // ∑, ∏, ∫, etc.
    pub lim_loc: DocxMathLimitLocation,
    pub grow: bool,
    pub sub_hide: bool,
    pub sup_hide: bool,
    pub subscript: Option<Vec<DocxMathElement>>,
    pub superscript: Option<Vec<DocxMathElement>>,
    pub base: Vec<DocxMathElement>,
}

#[derive(Debug, Clone)]
pub enum DocxMathLimitLocation {
    SubSup,    // Côté (∑ₐᵇ)
    UnderOver, // Dessus/dessous
}

#[derive(Debug, Clone)]
pub struct DocxMathLimit {
    pub base: Vec<DocxMathElement>,
    pub limit: Vec<DocxMathElement>,
}

#[derive(Debug, Clone)]
pub struct DocxMathScript {
    pub base: Vec<DocxMathElement>,
    pub script: Vec<DocxMathElement>,
}

#[derive(Debug, Clone)]
pub struct DocxMathSubSup {
    pub base: Vec<DocxMathElement>,
    pub subscript: Vec<DocxMathElement>,
    pub superscript: Vec<DocxMathElement>,
    pub align: bool,
}

#[derive(Debug, Clone)]
pub struct DocxMathBar {
    pub base: Vec<DocxMathElement>,
    pub position: DocxMathBarPosition,
}

#[derive(Debug, Clone)]
pub enum DocxMathBarPosition {
    Top,
    Bottom,
}

#[derive(Debug, Clone)]
pub struct DocxMathAccent {
    pub base: Vec<DocxMathElement>,
    pub chr: Option<String>,
}

#[derive(Debug, Clone)]
pub struct DocxMathBox {
    pub base: Vec<DocxMathElement>,
    pub operator_emulator: bool,
    pub no_break: bool,
    pub differential: bool,
    pub break_mode: Option<DocxMathBreakMode>,
    pub alignment: Option<u32>,
}

#[derive(Debug, Clone)]
pub enum DocxMathBreakMode {
    Before,
    After,
    Repeat,
}

#[derive(Debug, Clone)]
pub struct DocxMathBorderBox {
    pub base: Vec<DocxMathElement>,
    pub hide_top: bool,
    pub hide_bottom: bool,
    pub hide_left: bool,
    pub hide_right: bool,
    pub strike_h: bool,
    pub strike_v: bool,
    pub strike_bltr: bool,
    pub strike_tlbr: bool,
}

#[derive(Debug, Clone)]
pub struct DocxMathGroupChar {
    pub base: Vec<DocxMathElement>,
    pub chr: Option<String>,
    pub position: DocxMathGroupCharPosition,
    pub vertical_justification: Option<DocxMathJustification>,
}

#[derive(Debug, Clone)]
pub enum DocxMathGroupCharPosition {
    Top,
    Bottom,
}

#[derive(Debug, Clone)]
pub struct DocxMathPhantom {
    pub base: Vec<DocxMathElement>,
    pub show: bool,
    pub zero_width: bool,
    pub zero_ascent: bool,
    pub zero_descent: bool,
    pub transparent: bool,
}

#[derive(Debug, Clone)]
pub enum DocxMathJustification {
    Left,
    Center,
    Right,
    CenterGroup,
}

// =============================================================================
// CUSTOM XML
// =============================================================================

#[derive(Debug, Clone)]
pub struct DocxCustomXml {
    pub item_id: String,
    pub schema_refs: Vec<String>,
    pub data: String,
}

// =============================================================================
// THEME
// =============================================================================

#[derive(Debug, Clone)]
pub struct DocxTheme {
    pub name: String,
    pub color_scheme: DocxColorScheme,
    pub font_scheme: DocxFontScheme,
}

#[derive(Debug, Clone)]
pub struct DocxColorScheme {
    pub name: String,
    pub colors: HashMap<String, String>, // dk1, lt1, dk2, lt2, accent1-6, hlink, folHlink
}

#[derive(Debug, Clone)]
pub struct DocxFontScheme {
    pub name: String,
    pub major_font: DocxThemeFont,
    pub minor_font: DocxThemeFont,
}

#[derive(Debug, Clone)]
pub struct DocxThemeFont {
    pub latin: String,
    pub east_asian: Option<String>,
    pub complex_script: Option<String>,
}

// =============================================================================
// DOCUMENT SETTINGS
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct DocxSettings {
    pub zoom: Option<u32>,
    pub display_background_shape: bool,
    pub print_fractional_width: bool,
    pub embed_true_type_fonts: bool,
    pub embed_system_fonts: bool,
    pub save_subset_fonts: bool,
    pub default_tab_stop: Option<u32>,
    pub auto_hyphenation: bool,
    pub consecutive_hyphen_limit: Option<u32>,
    pub hyphenation_zone: Option<u32>,
    pub do_not_hyphenate_caps: bool,
    pub even_and_odd_headers: bool,
    pub book_fold_printing: bool,
    pub book_fold_revise: bool,
    pub book_fold_sheets: Option<u32>,
    pub track_revisions: bool,
    pub revision_view: Option<DocxRevisionView>,
    pub document_protection: Option<DocxDocumentProtection>,
    pub compat_settings: Vec<DocxCompatSetting>,
}

#[derive(Debug, Clone)]
pub struct DocxRevisionView {
    pub markup: bool,
    pub comments: bool,
    pub insertions_deletions: bool,
    pub formatting: bool,
    pub ink_annotations: bool,
}

#[derive(Debug, Clone)]
pub struct DocxDocumentProtection {
    pub edit: DocxDocumentProtectionEdit,
    pub formatting: bool,
    pub hash: Option<String>,
    pub salt: Option<String>,
    pub algorithm_name: Option<String>,
    pub spin_count: Option<u32>,
}

#[derive(Debug, Clone)]
pub enum DocxDocumentProtectionEdit {
    None,
    ReadOnly,
    Comments,
    TrackedChanges,
    Forms,
}

#[derive(Debug, Clone)]
pub struct DocxCompatSetting {
    pub name: String,
    pub uri: String,
    pub val: String,
}

/// Métadonnées extraites de docProps/
#[derive(Debug, Clone, Default)]
pub struct DocxMetadata {
    /// Titre du document
    pub title: Option<String>,
    /// Auteur
    pub author: Option<String>,
    /// Sujet
    pub subject: Option<String>,
    /// Description
    pub description: Option<String>,
    /// Mots-clés
    pub keywords: Vec<String>,
    /// Catégorie
    pub category: Option<String>,
    /// Date de création
    pub created: Option<String>,
    /// Date de modification
    pub modified: Option<String>,
    /// Dernier auteur
    pub last_modified_by: Option<String>,
    /// Numéro de révision
    pub revision: Option<u32>,
    /// Nombre de pages
    pub page_count: Option<u32>,
    /// Nombre de mots
    pub word_count: Option<u32>,
    /// Nombre de caractères
    pub character_count: Option<u32>,
    /// Application créatrice
    pub application: Option<String>,
    /// Version de l'application
    pub app_version: Option<String>,
}

/// Élément de contenu DOCX
#[derive(Debug, Clone)]
pub enum DocxElement {
    /// Paragraphe (w:p)
    Paragraph(DocxParagraph),
    /// Table (w:tbl)
    Table(DocxTable),
    /// Saut de section
    SectionBreak,
    /// Saut de page
    PageBreak,
}

/// Paragraphe DOCX (w:p)
#[derive(Debug, Clone, Default)]
pub struct DocxParagraph {
    /// Runs (segments de texte)
    pub runs: Vec<DocxRun>,
    /// ID du style appliqué
    pub style_id: Option<String>,
    /// Référence de numérotation (liste)
    pub numbering: Option<DocxNumRef>,
    /// Alignement
    pub alignment: Option<DocxAlignment>,
    /// Indentation gauche (en twips)
    pub indent_left: Option<i32>,
    /// Indentation droite (en twips)
    pub indent_right: Option<i32>,
    /// Retrait première ligne (en twips)
    pub indent_first_line: Option<i32>,
    /// Espacement avant (en twips)
    pub spacing_before: Option<u32>,
    /// Espacement après (en twips)
    pub spacing_after: Option<u32>,
    /// Interligne
    pub line_spacing: Option<DocxLineSpacing>,
    /// Bookmarks dans ce paragraphe
    pub bookmarks: Vec<DocxBookmark>,
}

/// Run (segment de texte avec style uniforme) (w:r)
#[derive(Debug, Clone, Default)]
pub struct DocxRun {
    /// Texte
    pub text: String,
    /// Gras
    pub bold: bool,
    /// Italique
    pub italic: bool,
    /// Souligné
    pub underline: bool,
    /// Barré
    pub strike: bool,
    /// Double barré
    pub double_strike: bool,
    /// Exposant
    pub superscript: bool,
    /// Indice
    pub subscript: bool,
    /// Police
    pub font_name: Option<String>,
    /// Taille (en demi-points)
    pub font_size: Option<u32>,
    /// Couleur (hex sans #)
    pub color: Option<String>,
    /// Surlignage
    pub highlight: Option<String>,
    /// Espacement des caractères (en twips)
    pub spacing: Option<i32>,
    /// ID du style de caractère
    pub style_id: Option<String>,
    /// Référence vers hyperlien
    pub hyperlink_id: Option<String>,
    /// Image inline
    pub image: Option<DocxInlineImage>,
    /// Champ (numéro de page, date, etc.)
    pub field: Option<DocxField>,
    /// Saut de ligne
    pub break_type: Option<DocxBreakType>,
    /// Tab
    pub tab: bool,
}

/// Image inline dans un run
#[derive(Debug, Clone)]
pub struct DocxInlineImage {
    /// ID de relation vers l'image
    pub rel_id: String,
    /// Largeur en EMUs
    pub width: i64,
    /// Hauteur en EMUs
    pub height: i64,
    /// Texte alternatif
    pub alt_text: Option<String>,
}

/// Champ DOCX (numéro de page, etc.)
#[derive(Debug, Clone)]
pub struct DocxField {
    pub field_type: DocxFieldType,
    pub instruction: String,
}

#[derive(Debug, Clone)]
pub enum DocxFieldType {
    PageNumber,
    PageCount,
    Date,
    Time,
    Author,
    Title,
    FileName,
    Hyperlink,
    TableOfContents,
    Other(String),
}

/// Type de saut
#[derive(Debug, Clone)]
pub enum DocxBreakType {
    Line,
    Page,
    Column,
    TextWrapping,
}

/// Alignement de paragraphe
#[derive(Debug, Clone)]
pub enum DocxAlignment {
    Left,
    Center,
    Right,
    Justify,
    Distribute,
}

/// Interligne
#[derive(Debug, Clone)]
pub struct DocxLineSpacing {
    /// Valeur (en twips ou pourcentage selon rule)
    pub value: u32,
    /// Règle d'espacement
    pub rule: DocxLineRule,
}

#[derive(Debug, Clone)]
pub enum DocxLineRule {
    Auto,
    Exact,
    AtLeast,
}

/// Référence de numérotation
#[derive(Debug, Clone)]
pub struct DocxNumRef {
    /// ID de numérotation
    pub num_id: u32,
    /// Niveau (0-8)
    pub level: u32,
}

/// Bookmark
#[derive(Debug, Clone)]
pub struct DocxBookmark {
    pub id: u32,
    pub name: String,
}

/// Table DOCX (w:tbl)
#[derive(Debug, Clone, Default)]
pub struct DocxTable {
    /// Lignes
    pub rows: Vec<DocxTableRow>,
    /// ID du style de table
    pub style_id: Option<String>,
    /// Largeur totale (en twips)
    pub width: Option<u32>,
    /// Type de largeur
    pub width_type: Option<DocxWidthType>,
    /// Alignement
    pub alignment: Option<DocxAlignment>,
    /// Bordures
    pub borders: Option<DocxTableBorders>,
}

/// Ligne de table (w:tr)
#[derive(Debug, Clone, Default)]
pub struct DocxTableRow {
    /// Cellules
    pub cells: Vec<DocxTableCell>,
    /// Ligne d'en-tête
    pub is_header: bool,
    /// Hauteur (en twips)
    pub height: Option<u32>,
}

/// Cellule de table (w:tc)
#[derive(Debug, Clone, Default)]
pub struct DocxTableCell {
    /// Contenu (paragraphes, tables imbriquées)
    pub content: Vec<DocxElement>,
    /// Fusion horizontale
    pub col_span: u32,
    /// Fusion verticale
    pub row_span: u32,
    /// Largeur (en twips)
    pub width: Option<u32>,
    /// Couleur de fond
    pub shading: Option<String>,
    /// Alignement vertical
    pub vertical_align: Option<DocxVerticalAlign>,
    /// Bordures
    pub borders: Option<DocxCellBorders>,
}

#[derive(Debug, Clone)]
pub enum DocxWidthType {
    Auto,
    Dxa,  // Twips
    Pct,  // Percentage (50ths of a percent)
    Nil,
}

#[derive(Debug, Clone)]
pub enum DocxVerticalAlign {
    Top,
    Center,
    Bottom,
}

/// Bordures de table
#[derive(Debug, Clone, Default)]
pub struct DocxTableBorders {
    pub top: Option<DocxBorder>,
    pub bottom: Option<DocxBorder>,
    pub left: Option<DocxBorder>,
    pub right: Option<DocxBorder>,
    pub inside_h: Option<DocxBorder>,
    pub inside_v: Option<DocxBorder>,
}

/// Bordures de cellule
#[derive(Debug, Clone, Default)]
pub struct DocxCellBorders {
    pub top: Option<DocxBorder>,
    pub bottom: Option<DocxBorder>,
    pub left: Option<DocxBorder>,
    pub right: Option<DocxBorder>,
}

/// Bordure
#[derive(Debug, Clone)]
pub struct DocxBorder {
    pub style: DocxBorderStyle,
    pub color: Option<String>,
    pub size: Option<u32>,  // En eighths of a point
}

#[derive(Debug, Clone)]
pub enum DocxBorderStyle {
    None,
    Single,
    Thick,
    Double,
    Dotted,
    Dashed,
    DotDash,
    DotDotDash,
    Triple,
    Wave,
    Other(String),
}

/// Style DOCX
#[derive(Debug, Clone)]
pub struct DocxStyle {
    /// ID du style
    pub id: String,
    /// Nom affiché
    pub name: String,
    /// Type de style
    pub style_type: DocxStyleType,
    /// Style parent
    pub based_on: Option<String>,
    /// Style par défaut
    pub is_default: bool,
    /// Propriétés de paragraphe
    pub paragraph_props: Option<DocxParagraphProps>,
    /// Propriétés de run
    pub run_props: Option<DocxRunProps>,
}

#[derive(Debug, Clone)]
pub enum DocxStyleType {
    Paragraph,
    Character,
    Table,
    Numbering,
}

/// Propriétés de paragraphe dans un style
#[derive(Debug, Clone, Default)]
pub struct DocxParagraphProps {
    pub alignment: Option<DocxAlignment>,
    pub indent_left: Option<i32>,
    pub indent_right: Option<i32>,
    pub spacing_before: Option<u32>,
    pub spacing_after: Option<u32>,
    pub outline_level: Option<u8>,
}

/// Propriétés de run dans un style
#[derive(Debug, Clone, Default)]
pub struct DocxRunProps {
    pub bold: Option<bool>,
    pub italic: Option<bool>,
    pub underline: Option<bool>,
    pub font_name: Option<String>,
    pub font_size: Option<u32>,
    pub color: Option<String>,
}

/// Définition de numérotation
#[derive(Debug, Clone)]
pub struct DocxNumbering {
    /// ID de numérotation
    pub num_id: u32,
    /// ID de définition abstraite
    pub abstract_num_id: u32,
}

/// Définition de numérotation abstraite
#[derive(Debug, Clone)]
pub struct DocxAbstractNum {
    pub abstract_num_id: u32,
    pub levels: Vec<DocxNumLevel>,
}

/// Niveau de numérotation
#[derive(Debug, Clone)]
pub struct DocxNumLevel {
    /// Niveau (0-8)
    pub level: u32,
    /// Format (decimal, bullet, lowerLetter, etc.)
    pub format: DocxNumFormat,
    /// Texte du numéro (%1., %1), etc.)
    pub text: String,
    /// Valeur de départ
    pub start: u32,
    /// Alignement
    pub alignment: Option<DocxAlignment>,
    /// Propriétés de paragraphe
    pub paragraph_props: Option<DocxParagraphProps>,
    /// Propriétés de run
    pub run_props: Option<DocxRunProps>,
}

#[derive(Debug, Clone)]
pub enum DocxNumFormat {
    Decimal,
    DecimalZero,
    UpperRoman,
    LowerRoman,
    UpperLetter,
    LowerLetter,
    Bullet,
    None,
    Other(String),
}

/// Commentaire
#[derive(Debug, Clone)]
pub struct DocxComment {
    pub id: u32,
    pub author: String,
    pub date: Option<String>,
    pub initials: Option<String>,
    pub content: Vec<DocxParagraph>,
}

/// Note de bas de page
#[derive(Debug, Clone)]
pub struct DocxFootnote {
    pub id: u32,
    pub footnote_type: DocxFootnoteType,
    pub content: Vec<DocxElement>,
}

#[derive(Debug, Clone)]
pub enum DocxFootnoteType {
    Normal,
    Separator,
    ContinuationSeparator,
}

/// Note de fin
#[derive(Debug, Clone)]
pub struct DocxEndnote {
    pub id: u32,
    pub content: Vec<DocxElement>,
}

/// Image embarquée
#[derive(Debug, Clone)]
pub struct DocxImage {
    /// Données binaires
    pub data: Vec<u8>,
    /// Type MIME
    pub content_type: String,
    /// Nom de fichier original
    pub filename: Option<String>,
}

/// Relation (document.xml.rels)
#[derive(Debug, Clone)]
pub struct DocxRelationship {
    pub id: String,
    pub rel_type: DocxRelType,
    pub target: String,
    pub target_mode: Option<String>,
}

#[derive(Debug, Clone)]
pub enum DocxRelType {
    Image,
    Hyperlink,
    Styles,
    Numbering,
    FontTable,
    Settings,
    WebSettings,
    FootNotes,
    EndNotes,
    Comments,
    Header,
    Footer,
    Theme,
    Other(String),
}
