//! XLSX Document Model
//!
//! Types représentant la structure complète d'un classeur Excel (.xlsx).
//!
//! ## Format XLSX
//!
//! XLSX est basé sur SpreadsheetML (ECMA-376, ISO/IEC 29500).

use std::collections::HashMap;

// =============================================================================
// DOCUMENT PRINCIPAL
// =============================================================================

/// Classeur XLSX parsé
#[derive(Debug, Clone, Default)]
pub struct XlsxDocument {
    /// Métadonnées
    pub metadata: XlsxMetadata,
    /// Feuilles de calcul
    pub sheets: Vec<XlsxSheet>,
    /// Chaînes partagées
    pub shared_strings: Vec<XlsxSharedString>,
    /// Styles
    pub styles: XlsxStyles,
    /// Thème
    pub theme: Option<XlsxTheme>,
    /// Noms définis
    pub defined_names: Vec<XlsxDefinedName>,
    /// Images embarquées (path -> data)
    pub images: HashMap<String, XlsxImage>,
    /// Propriétés du classeur
    pub properties: XlsxWorkbookProperties,
    /// Avertissements
    pub warnings: Vec<String>,
}

// =============================================================================
// MÉTADONNÉES
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct XlsxMetadata {
    pub title: Option<String>,
    pub subject: Option<String>,
    pub author: Option<String>,
    pub description: Option<String>,
    pub keywords: Vec<String>,
    pub category: Option<String>,
    pub created: Option<String>,
    pub modified: Option<String>,
    pub last_modified_by: Option<String>,
    pub revision: Option<u32>,
    pub application: Option<String>,
    pub app_version: Option<String>,
}

// =============================================================================
// PROPRIÉTÉS DU CLASSEUR
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct XlsxWorkbookProperties {
    /// Date système 1904 (Mac) vs 1900 (Windows)
    pub date_1904: bool,
    /// Vue par défaut (workbook, sheet tabs, etc.)
    pub default_theme_version: Option<u32>,
    /// Protégé
    pub protected: bool,
}

// =============================================================================
// FEUILLE DE CALCUL
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxSheet {
    /// Nom de la feuille
    pub name: String,
    /// ID de la feuille
    pub sheet_id: u32,
    /// État (visible, hidden, veryHidden)
    pub state: XlsxSheetState,
    /// Lignes
    pub rows: Vec<XlsxRow>,
    /// Fusions de cellules
    pub merge_cells: Vec<XlsxMergeCell>,
    /// Colonnes définies
    pub columns: Vec<XlsxColumn>,
    /// Propriétés de la feuille
    pub properties: XlsxSheetProperties,
    /// Vue de la feuille
    pub views: Vec<XlsxSheetView>,
    /// Protection de la feuille
    pub protection: Option<XlsxSheetProtection>,
    /// Validation des données
    pub data_validations: Vec<XlsxDataValidation>,
    /// Filtres automatiques
    pub auto_filter: Option<XlsxAutoFilter>,
    /// Liens hypertexte
    pub hyperlinks: Vec<XlsxHyperlink>,
    /// Tableaux (ListObjects)
    pub tables: Vec<XlsxTable>,
    /// Graphiques
    pub charts: Vec<XlsxChart>,
    /// Images
    pub drawings: Vec<XlsxDrawing>,
    /// Commentaires
    pub comments: Vec<XlsxComment>,
    /// Mise en page
    pub page_setup: Option<XlsxPageSetup>,
    /// Marges
    pub page_margins: Option<XlsxPageMargins>,
    /// En-tête/pied de page
    pub header_footer: Option<XlsxHeaderFooter>,
    /// Impression (zones, titres)
    pub print_options: Option<XlsxPrintOptions>,
}

#[derive(Debug, Clone, Default)]
pub enum XlsxSheetState {
    #[default]
    Visible,
    Hidden,
    VeryHidden,
}

#[derive(Debug, Clone, Default)]
pub struct XlsxSheetProperties {
    /// Nom de l'onglet
    pub tab_color: Option<String>,
    /// Afficher le quadrillage
    pub show_grid_lines: bool,
    /// Afficher les en-têtes de ligne/colonne
    pub show_row_col_headers: bool,
    /// Afficher les formules
    pub show_formulas: bool,
    /// Direction de droite à gauche
    pub right_to_left: bool,
    /// Afficher les zéros
    pub show_zeros: bool,
    /// Ajuster à la page
    pub fit_to_page: bool,
}

#[derive(Debug, Clone)]
pub struct XlsxSheetView {
    /// Vue par défaut
    pub default_grid_color: bool,
    /// Zoom
    pub zoom_scale: u32,
    /// Zoom en aperçu normal
    pub zoom_scale_normal: Option<u32>,
    /// Zoom en aperçu page
    pub zoom_scale_page_layout_view: Option<u32>,
    /// Cellule active
    pub active_cell: Option<String>,
    /// Panes (volets figés)
    pub pane: Option<XlsxPane>,
    /// Sélections
    pub selections: Vec<XlsxSelection>,
}

#[derive(Debug, Clone)]
pub struct XlsxPane {
    /// Colonne de split
    pub x_split: f64,
    /// Ligne de split
    pub y_split: f64,
    /// Cellule haut-gauche
    pub top_left_cell: Option<String>,
    /// État (frozen, split)
    pub state: XlsxPaneState,
    /// Volet actif
    pub active_pane: String,
}

#[derive(Debug, Clone, Default)]
pub enum XlsxPaneState {
    #[default]
    Frozen,
    FrozenSplit,
    Split,
}

#[derive(Debug, Clone)]
pub struct XlsxSelection {
    pub pane: Option<String>,
    pub active_cell: Option<String>,
    pub sqref: Option<String>,
}

#[derive(Debug, Clone)]
pub struct XlsxSheetProtection {
    pub password_hash: Option<String>,
    pub sheet: bool,
    pub objects: bool,
    pub scenarios: bool,
    pub format_cells: bool,
    pub format_columns: bool,
    pub format_rows: bool,
    pub insert_columns: bool,
    pub insert_rows: bool,
    pub insert_hyperlinks: bool,
    pub delete_columns: bool,
    pub delete_rows: bool,
    pub select_locked_cells: bool,
    pub sort: bool,
    pub auto_filter: bool,
    pub pivot_tables: bool,
    pub select_unlocked_cells: bool,
}

// =============================================================================
// LIGNES ET CELLULES
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxRow {
    /// Index de la ligne (1-based)
    pub row_index: u32,
    /// Cellules
    pub cells: Vec<XlsxCell>,
    /// Hauteur personnalisée
    pub height: Option<f64>,
    /// Hauteur personnalisée activée
    pub custom_height: bool,
    /// Masquée
    pub hidden: bool,
    /// Niveau de plan
    pub outline_level: u8,
    /// Réduit (collapsed)
    pub collapsed: bool,
    /// Style de ligne
    pub style_index: Option<u32>,
}

#[derive(Debug, Clone)]
pub struct XlsxCell {
    /// Référence (ex: "A1", "B2")
    pub reference: String,
    /// Type de cellule
    pub cell_type: XlsxCellType,
    /// Valeur
    pub value: XlsxCellValue,
    /// Formule
    pub formula: Option<XlsxFormula>,
    /// Index du style
    pub style_index: Option<u32>,
    /// Métadonnées
    pub metadata: Option<u32>,
}

#[derive(Debug, Clone, Default)]
pub enum XlsxCellType {
    #[default]
    Number,
    String,
    SharedString,
    InlineString,
    Boolean,
    Error,
    Date,
}

#[derive(Debug, Clone, Default)]
pub enum XlsxCellValue {
    #[default]
    Empty,
    Number(f64),
    String(String),
    SharedString(u32),
    Boolean(bool),
    Error(String),
}

#[derive(Debug, Clone)]
pub struct XlsxFormula {
    /// Formule
    pub formula: String,
    /// Type de formule
    pub formula_type: XlsxFormulaType,
    /// Référence partagée
    pub shared_index: Option<u32>,
    /// Cellule de référence (pour array/shared)
    pub ref_cell: Option<String>,
    /// Calculé
    pub calculated: bool,
}

#[derive(Debug, Clone, Default)]
pub enum XlsxFormulaType {
    #[default]
    Normal,
    Shared,
    Array,
    DataTable,
}

// =============================================================================
// COLONNES
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxColumn {
    /// Colonne min
    pub min: u32,
    /// Colonne max
    pub max: u32,
    /// Largeur
    pub width: f64,
    /// Style
    pub style_index: Option<u32>,
    /// Masquée
    pub hidden: bool,
    /// Ajustement automatique
    pub best_fit: bool,
    /// Niveau de plan
    pub outline_level: u8,
    /// Réduit
    pub collapsed: bool,
}

// =============================================================================
// FUSIONS
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxMergeCell {
    /// Référence (ex: "A1:C3")
    pub reference: String,
}

// =============================================================================
// CHAÎNES PARTAGÉES
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxSharedString {
    /// Texte simple
    pub text: Option<String>,
    /// Rich text (si formaté)
    pub rich_text: Option<Vec<XlsxRichTextRun>>,
}

#[derive(Debug, Clone)]
pub struct XlsxRichTextRun {
    pub text: String,
    pub properties: Option<XlsxRunProperties>,
}

#[derive(Debug, Clone, Default)]
pub struct XlsxRunProperties {
    pub bold: Option<bool>,
    pub italic: Option<bool>,
    pub underline: Option<String>,
    pub strike: Option<bool>,
    pub font_size: Option<f64>,
    pub font_name: Option<String>,
    pub font_family: Option<u32>,
    pub color: Option<XlsxColor>,
    pub vertical_align: Option<String>,
}

// =============================================================================
// STYLES
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct XlsxStyles {
    /// Formats de nombre
    pub number_formats: Vec<XlsxNumberFormat>,
    /// Polices
    pub fonts: Vec<XlsxFont>,
    /// Remplissages
    pub fills: Vec<XlsxFill>,
    /// Bordures
    pub borders: Vec<XlsxBorder>,
    /// Styles de cellule (xf)
    pub cell_xfs: Vec<XlsxCellXf>,
    /// Styles de cellule par défaut (cellStyleXfs)
    pub cell_style_xfs: Vec<XlsxCellXf>,
    /// Styles nommés
    pub cell_styles: Vec<XlsxCellStyle>,
}

#[derive(Debug, Clone)]
pub struct XlsxNumberFormat {
    pub id: u32,
    pub format_code: String,
}

#[derive(Debug, Clone, Default)]
pub struct XlsxFont {
    pub name: Option<String>,
    pub size: Option<f64>,
    pub bold: bool,
    pub italic: bool,
    pub underline: Option<String>,
    pub strike: bool,
    pub color: Option<XlsxColor>,
    pub family: Option<u32>,
    pub scheme: Option<String>,
    pub charset: Option<u32>,
    pub condense: bool,
    pub extend: bool,
    pub outline: bool,
    pub shadow: bool,
    pub vertical_align: Option<String>,
}

#[derive(Debug, Clone)]
pub struct XlsxFill {
    pub pattern_type: Option<String>,
    pub foreground_color: Option<XlsxColor>,
    pub background_color: Option<XlsxColor>,
    pub gradient: Option<XlsxGradientFill>,
}

#[derive(Debug, Clone)]
pub struct XlsxGradientFill {
    pub gradient_type: String,
    pub degree: Option<f64>,
    pub stops: Vec<XlsxGradientStop>,
}

#[derive(Debug, Clone)]
pub struct XlsxGradientStop {
    pub position: f64,
    pub color: XlsxColor,
}

#[derive(Debug, Clone, Default)]
pub struct XlsxBorder {
    pub left: Option<XlsxBorderSide>,
    pub right: Option<XlsxBorderSide>,
    pub top: Option<XlsxBorderSide>,
    pub bottom: Option<XlsxBorderSide>,
    pub diagonal: Option<XlsxBorderSide>,
    pub diagonal_up: bool,
    pub diagonal_down: bool,
}

#[derive(Debug, Clone)]
pub struct XlsxBorderSide {
    pub style: Option<String>,
    pub color: Option<XlsxColor>,
}

#[derive(Debug, Clone, Default)]
pub struct XlsxCellXf {
    pub num_fmt_id: Option<u32>,
    pub font_id: Option<u32>,
    pub fill_id: Option<u32>,
    pub border_id: Option<u32>,
    pub xf_id: Option<u32>,
    pub apply_number_format: bool,
    pub apply_font: bool,
    pub apply_fill: bool,
    pub apply_border: bool,
    pub apply_alignment: bool,
    pub apply_protection: bool,
    pub alignment: Option<XlsxAlignment>,
    pub protection: Option<XlsxCellProtection>,
}

#[derive(Debug, Clone, Default)]
pub struct XlsxAlignment {
    pub horizontal: Option<String>,
    pub vertical: Option<String>,
    pub text_rotation: Option<i32>,
    pub wrap_text: bool,
    pub shrink_to_fit: bool,
    pub indent: Option<u32>,
    pub reading_order: Option<u32>,
}

#[derive(Debug, Clone, Default)]
pub struct XlsxCellProtection {
    pub locked: bool,
    pub hidden: bool,
}

#[derive(Debug, Clone)]
pub struct XlsxCellStyle {
    pub name: String,
    pub xf_id: u32,
    pub builtin_id: Option<u32>,
    pub custom_builtin: bool,
}

#[derive(Debug, Clone)]
pub struct XlsxColor {
    pub rgb: Option<String>,
    pub theme: Option<u32>,
    pub tint: Option<f64>,
    pub indexed: Option<u32>,
    pub auto: bool,
}

// =============================================================================
// THÈME
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct XlsxTheme {
    pub name: String,
    pub color_scheme: HashMap<String, String>,
    pub font_scheme_major: String,
    pub font_scheme_minor: String,
}

// =============================================================================
// NOMS DÉFINIS
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxDefinedName {
    pub name: String,
    pub value: String,
    pub sheet_id: Option<u32>,
    pub hidden: bool,
    pub comment: Option<String>,
    pub function: bool,
    pub vb_procedure: bool,
}

// =============================================================================
// VALIDATION DES DONNÉES
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxDataValidation {
    pub sqref: String,
    pub validation_type: XlsxValidationType,
    pub operator: Option<String>,
    pub formula1: Option<String>,
    pub formula2: Option<String>,
    pub allow_blank: bool,
    pub show_input_message: bool,
    pub show_error_message: bool,
    pub prompt_title: Option<String>,
    pub prompt: Option<String>,
    pub error_title: Option<String>,
    pub error: Option<String>,
    pub error_style: Option<String>,
}

#[derive(Debug, Clone, Default)]
pub enum XlsxValidationType {
    #[default]
    None,
    Whole,
    Decimal,
    List,
    Date,
    Time,
    TextLength,
    Custom,
}

// =============================================================================
// FILTRE AUTOMATIQUE
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxAutoFilter {
    pub reference: String,
    pub filter_columns: Vec<XlsxFilterColumn>,
}

#[derive(Debug, Clone)]
pub struct XlsxFilterColumn {
    pub col_id: u32,
    pub filters: Vec<String>,
    pub custom_filters: Option<XlsxCustomFilters>,
    pub dynamic_filter: Option<XlsxDynamicFilter>,
    pub color_filter: Option<XlsxColorFilter>,
    pub top10: Option<XlsxTop10Filter>,
}

#[derive(Debug, Clone)]
pub struct XlsxCustomFilters {
    pub and_filter: bool,
    pub filters: Vec<XlsxCustomFilter>,
}

#[derive(Debug, Clone)]
pub struct XlsxCustomFilter {
    pub operator: String,
    pub value: String,
}

#[derive(Debug, Clone)]
pub struct XlsxDynamicFilter {
    pub filter_type: String,
    pub value: Option<f64>,
}

#[derive(Debug, Clone)]
pub struct XlsxColorFilter {
    pub dxf_id: Option<u32>,
    pub cell_color: bool,
}

#[derive(Debug, Clone)]
pub struct XlsxTop10Filter {
    pub top: bool,
    pub percent: bool,
    pub value: f64,
}

// =============================================================================
// LIENS HYPERTEXTE
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxHyperlink {
    pub reference: String,
    pub rel_id: Option<String>,
    pub location: Option<String>,
    pub display: Option<String>,
    pub tooltip: Option<String>,
}

// =============================================================================
// TABLEAUX
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxTable {
    pub id: u32,
    pub name: String,
    pub display_name: String,
    pub reference: String,
    pub totals_row_shown: bool,
    pub columns: Vec<XlsxTableColumn>,
    pub style: Option<XlsxTableStyle>,
    pub auto_filter: Option<XlsxAutoFilter>,
}

#[derive(Debug, Clone)]
pub struct XlsxTableColumn {
    pub id: u32,
    pub name: String,
    pub totals_row_function: Option<String>,
    pub totals_row_formula: Option<String>,
    pub totals_row_label: Option<String>,
}

#[derive(Debug, Clone)]
pub struct XlsxTableStyle {
    pub name: Option<String>,
    pub show_first_column: bool,
    pub show_last_column: bool,
    pub show_row_stripes: bool,
    pub show_col_stripes: bool,
}

// =============================================================================
// GRAPHIQUES
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxChart {
    pub chart_type: XlsxChartType,
    pub title: Option<String>,
    pub anchor: XlsxDrawingAnchor,
}

#[derive(Debug, Clone, Default)]
pub enum XlsxChartType {
    #[default]
    Column,
    Bar,
    Line,
    Pie,
    Area,
    Scatter,
    Doughnut,
    Radar,
    Stock,
    Surface,
    Bubble,
    Combo,
}

// =============================================================================
// DRAWINGS
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxDrawing {
    pub drawing_type: XlsxDrawingType,
    pub anchor: XlsxDrawingAnchor,
}

#[derive(Debug, Clone)]
pub enum XlsxDrawingType {
    Picture { blip_rel_id: String, description: Option<String> },
    Shape { shape_type: String, text: Option<String> },
    Chart { rel_id: String },
}

#[derive(Debug, Clone)]
pub struct XlsxDrawingAnchor {
    pub anchor_type: XlsxAnchorType,
    pub from_col: u32,
    pub from_row: u32,
    pub from_col_off: i64,
    pub from_row_off: i64,
    pub to_col: Option<u32>,
    pub to_row: Option<u32>,
    pub to_col_off: Option<i64>,
    pub to_row_off: Option<i64>,
    pub cx: Option<i64>,
    pub cy: Option<i64>,
}

#[derive(Debug, Clone, Default)]
pub enum XlsxAnchorType {
    #[default]
    TwoCell,
    OneCell,
    Absolute,
}

// =============================================================================
// COMMENTAIRES
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxComment {
    pub reference: String,
    pub author: String,
    pub text: XlsxRichText,
}

#[derive(Debug, Clone, Default)]
pub struct XlsxRichText {
    pub runs: Vec<XlsxRichTextRun>,
}

// =============================================================================
// MISE EN PAGE
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct XlsxPageSetup {
    pub paper_size: Option<u32>,
    pub scale: Option<u32>,
    pub fit_to_width: Option<u32>,
    pub fit_to_height: Option<u32>,
    pub orientation: Option<String>,
    pub use_first_page_number: bool,
    pub first_page_number: Option<u32>,
    pub horizontal_dpi: Option<u32>,
    pub vertical_dpi: Option<u32>,
    pub black_and_white: bool,
    pub draft: bool,
    pub cell_comments: Option<String>,
    pub page_order: Option<String>,
}

#[derive(Debug, Clone, Default)]
pub struct XlsxPageMargins {
    pub left: f64,
    pub right: f64,
    pub top: f64,
    pub bottom: f64,
    pub header: f64,
    pub footer: f64,
}

#[derive(Debug, Clone, Default)]
pub struct XlsxHeaderFooter {
    pub odd_header: Option<String>,
    pub odd_footer: Option<String>,
    pub even_header: Option<String>,
    pub even_footer: Option<String>,
    pub first_header: Option<String>,
    pub first_footer: Option<String>,
    pub different_odd_even: bool,
    pub different_first: bool,
}

#[derive(Debug, Clone, Default)]
pub struct XlsxPrintOptions {
    pub horizontal_centered: bool,
    pub vertical_centered: bool,
    pub headings: bool,
    pub grid_lines: bool,
}

// =============================================================================
// IMAGES
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxImage {
    pub data: Vec<u8>,
    pub content_type: String,
    pub filename: Option<String>,
}

// =============================================================================
// RELATIONSHIPS
// =============================================================================

#[derive(Debug, Clone)]
pub struct XlsxRelationship {
    pub id: String,
    pub rel_type: XlsxRelType,
    pub target: String,
    pub target_mode: Option<String>,
}

#[derive(Debug, Clone)]
pub enum XlsxRelType {
    Worksheet,
    SharedStrings,
    Styles,
    Theme,
    Drawing,
    Chart,
    Image,
    Hyperlink,
    Comments,
    Table,
    VmlDrawing,
    Other(String),
}
