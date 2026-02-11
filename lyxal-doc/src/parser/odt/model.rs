//! ODT Document Model
//!
//! Types représentant la structure complète d'un document ODT (OpenDocument Text).
//!
//! ## Format ODF (Open Document Format)
//!
//! ODT est basé sur OASIS ODF 1.2/1.3 (ISO/IEC 26300).

use std::collections::HashMap;

// =============================================================================
// DOCUMENT PRINCIPAL
// =============================================================================

/// Document ODT parsé (structure intermédiaire)
#[derive(Debug, Clone, Default)]
pub struct OdtDocument {
    /// Métadonnées du document
    pub metadata: OdtMetadata,
    /// Corps du document
    pub body: Vec<OdtElement>,
    /// Styles automatiques
    pub automatic_styles: Vec<OdtStyle>,
    /// Styles communs
    pub common_styles: Vec<OdtStyle>,
    /// Styles master pages
    pub master_styles: Vec<OdtMasterPage>,
    /// Images embarquées (path -> données)
    pub images: HashMap<String, OdtImage>,
    /// Polices déclarées
    pub font_declarations: Vec<OdtFontDecl>,
    /// Paramètres du document
    pub settings: OdtSettings,
    /// Avertissements
    pub warnings: Vec<String>,
}

// =============================================================================
// MÉTADONNÉES (meta.xml)
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct OdtMetadata {
    /// Titre
    pub title: Option<String>,
    /// Description
    pub description: Option<String>,
    /// Sujet
    pub subject: Option<String>,
    /// Mots-clés
    pub keywords: Vec<String>,
    /// Créateur initial
    pub initial_creator: Option<String>,
    /// Créateur (dernier modificateur)
    pub creator: Option<String>,
    /// Date de création
    pub creation_date: Option<String>,
    /// Date de modification
    pub date: Option<String>,
    /// Langage
    pub language: Option<String>,
    /// Nombre de pages
    pub page_count: Option<u32>,
    /// Nombre de mots
    pub word_count: Option<u32>,
    /// Nombre de caractères
    pub character_count: Option<u32>,
    /// Nombre de paragraphes
    pub paragraph_count: Option<u32>,
    /// Nombre de tables
    pub table_count: Option<u32>,
    /// Nombre d'images
    pub image_count: Option<u32>,
    /// Générateur (application)
    pub generator: Option<String>,
    /// Statistiques d'édition
    pub editing_cycles: Option<u32>,
    /// Durée d'édition
    pub editing_duration: Option<String>,
    /// Propriétés utilisateur
    pub user_defined: HashMap<String, String>,
}

// =============================================================================
// ÉLÉMENTS DE CONTENU
// =============================================================================

/// Élément de contenu ODT
#[derive(Debug, Clone)]
pub enum OdtElement {
    /// Paragraphe (text:p)
    Paragraph(OdtParagraph),
    /// Titre/Heading (text:h)
    Heading(OdtHeading),
    /// Liste (text:list)
    List(OdtList),
    /// Table (table:table)
    Table(OdtTable),
    /// Section (text:section)
    Section(OdtSection),
    /// Cadre (draw:frame)
    Frame(OdtFrame),
    /// Saut de page
    PageBreak,
    /// Changements suivis
    TrackedChange(OdtTrackedChange),
    /// Note de bas de page
    Footnote(OdtFootnote),
    /// Note de fin
    Endnote(OdtEndnote),
    /// Annotation (commentaire)
    Annotation(OdtAnnotation),
    /// Table des matières
    TableOfContent(OdtToc),
    /// Index
    Index(OdtIndex),
}

// =============================================================================
// PARAGRAPHE (text:p)
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct OdtParagraph {
    /// Nom du style
    pub style_name: Option<String>,
    /// Contenu (spans, texte, etc.)
    pub content: Vec<OdtInline>,
}

#[derive(Debug, Clone)]
pub enum OdtInline {
    /// Texte brut
    Text(String),
    /// Span avec style (text:span)
    Span(OdtSpan),
    /// Lien (text:a)
    Link(OdtLink),
    /// Tab (text:tab)
    Tab,
    /// Saut de ligne (text:line-break)
    LineBreak,
    /// Espace (text:s)
    Space(u32),
    /// Champ (text:*)
    Field(OdtField),
    /// Signet (text:bookmark)
    Bookmark(OdtBookmark),
    /// Référence de note
    FootnoteRef(u32),
    EndnoteRef(u32),
    /// Cadre inline
    Frame(OdtFrame),
    /// Référence de marque
    ReferenceMark(String),
    /// Texte conditionnel
    ConditionalText(OdtConditionalText),
}

#[derive(Debug, Clone)]
pub struct OdtSpan {
    /// Nom du style
    pub style_name: Option<String>,
    /// Contenu
    pub content: Vec<OdtInline>,
}

#[derive(Debug, Clone)]
pub struct OdtLink {
    /// URL
    pub href: String,
    /// Type de lien
    pub link_type: Option<String>,
    /// Nom
    pub name: Option<String>,
    /// Target frame
    pub target_frame: Option<String>,
    /// Contenu
    pub content: Vec<OdtInline>,
}

#[derive(Debug, Clone)]
pub struct OdtField {
    pub field_type: OdtFieldType,
    pub value: Option<String>,
}

#[derive(Debug, Clone)]
pub enum OdtFieldType {
    PageNumber,
    PageCount,
    Date,
    Time,
    DateTime,
    Title,
    Subject,
    Author,
    Creator,
    FileName,
    SheetName,
    Chapter,
    PlaceHolder,
    UserField(String),
    Variable(String),
    Sequence(String),
    ConditionalText,
    HiddenText,
    Other(String),
}

#[derive(Debug, Clone)]
pub struct OdtBookmark {
    pub name: String,
    pub is_start: bool,
}

#[derive(Debug, Clone)]
pub struct OdtConditionalText {
    pub condition: String,
    pub true_value: String,
    pub false_value: String,
}

// =============================================================================
// HEADING (text:h)
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtHeading {
    /// Niveau (1-10)
    pub level: u8,
    /// Nom du style
    pub style_name: Option<String>,
    /// Numéro de chapitre
    pub outline_level: Option<u8>,
    /// Contenu
    pub content: Vec<OdtInline>,
}

// =============================================================================
// LISTE (text:list)
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtList {
    /// Nom du style
    pub style_name: Option<String>,
    /// ID de continuation
    pub continue_list: Option<String>,
    /// Éléments
    pub items: Vec<OdtListItem>,
}

#[derive(Debug, Clone)]
pub struct OdtListItem {
    /// Niveau de départ modifié
    pub start_value: Option<u32>,
    /// Contenu (paragraphes ou sous-listes)
    pub content: Vec<OdtListContent>,
}

#[derive(Debug, Clone)]
pub enum OdtListContent {
    Paragraph(OdtParagraph),
    Heading(OdtHeading),
    List(OdtList),
}

// =============================================================================
// TABLE (table:table)
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtTable {
    /// Nom de la table
    pub name: Option<String>,
    /// Nom du style
    pub style_name: Option<String>,
    /// Colonnes
    pub columns: Vec<OdtTableColumn>,
    /// Lignes
    pub rows: Vec<OdtTableRow>,
    /// Lignes d'en-tête
    pub header_rows: Vec<OdtTableRow>,
}

#[derive(Debug, Clone)]
pub struct OdtTableColumn {
    /// Nom du style
    pub style_name: Option<String>,
    /// Nombre de colonnes répétées
    pub number_columns_repeated: u32,
    /// Largeur par défaut pour les cellules
    pub default_cell_style: Option<String>,
}

#[derive(Debug, Clone)]
pub struct OdtTableRow {
    /// Nom du style
    pub style_name: Option<String>,
    /// Cellules
    pub cells: Vec<OdtTableCell>,
    /// Nombre de lignes répétées
    pub number_rows_repeated: u32,
}

#[derive(Debug, Clone)]
pub struct OdtTableCell {
    /// Nom du style
    pub style_name: Option<String>,
    /// Nombre de colonnes fusionnées
    pub number_columns_spanned: u32,
    /// Nombre de lignes fusionnées
    pub number_rows_spanned: u32,
    /// Contenu
    pub content: Vec<OdtElement>,
    /// Cellule couverte (par fusion)
    pub covered: bool,
    /// Valeur (pour formules)
    pub value: Option<OdtCellValue>,
    /// Formule
    pub formula: Option<String>,
}

#[derive(Debug, Clone)]
pub enum OdtCellValue {
    Float(f64),
    Currency(f64, String),
    Date(String),
    Time(String),
    Boolean(bool),
    String(String),
    Percentage(f64),
}

// =============================================================================
// SECTION (text:section)
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtSection {
    /// Nom de la section
    pub name: Option<String>,
    /// Nom du style
    pub style_name: Option<String>,
    /// Protégée
    pub protected: bool,
    /// Mot de passe protection
    pub protection_key: Option<String>,
    /// Contenu
    pub content: Vec<OdtElement>,
    /// Source de section liée
    pub link_source: Option<OdtSectionSource>,
}

#[derive(Debug, Clone)]
pub struct OdtSectionSource {
    pub href: String,
    pub filter_name: Option<String>,
    pub section_name: Option<String>,
}

// =============================================================================
// FRAME (draw:frame)
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtFrame {
    /// Nom
    pub name: Option<String>,
    /// Nom du style
    pub style_name: Option<String>,
    /// Ancrage
    pub anchor_type: OdtAnchorType,
    /// Position X (pour ancrage page/paragraph)
    pub x: Option<String>,
    /// Position Y
    pub y: Option<String>,
    /// Largeur
    pub width: Option<String>,
    /// Hauteur
    pub height: Option<String>,
    /// Z-index
    pub z_index: Option<u32>,
    /// Contenu du frame
    pub content: OdtFrameContent,
}

#[derive(Debug, Clone, Default)]
pub enum OdtAnchorType {
    #[default]
    Paragraph,
    Page,
    Character,
    Frame,
    AsCharacter,
}

#[derive(Debug, Clone)]
pub enum OdtFrameContent {
    /// Image
    Image(OdtImageRef),
    /// Texte
    TextBox(Vec<OdtElement>),
    /// Objet embarqué
    Object(OdtObject),
    /// Plugin
    Plugin(OdtPlugin),
    /// Applet (obsolète)
    Applet,
}

#[derive(Debug, Clone)]
pub struct OdtImageRef {
    /// Chemin vers l'image dans le ZIP
    pub href: String,
    /// Type MIME
    pub mime_type: Option<String>,
    /// Texte alternatif
    pub alt: Option<String>,
    /// Titre
    pub title: Option<String>,
}

#[derive(Debug, Clone)]
pub struct OdtObject {
    pub href: String,
    pub mime_type: Option<String>,
    pub notify_on_update: bool,
}

#[derive(Debug, Clone)]
pub struct OdtPlugin {
    pub href: String,
    pub mime_type: Option<String>,
}

// =============================================================================
// NOTES
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtFootnote {
    pub id: Option<String>,
    pub citation: Option<String>,
    pub content: Vec<OdtElement>,
}

#[derive(Debug, Clone)]
pub struct OdtEndnote {
    pub id: Option<String>,
    pub citation: Option<String>,
    pub content: Vec<OdtElement>,
}

// =============================================================================
// ANNOTATIONS (Commentaires)
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtAnnotation {
    /// Nom
    pub name: Option<String>,
    /// Auteur (dc:creator)
    pub creator: Option<String>,
    /// Date
    pub date: Option<String>,
    /// Contenu
    pub content: Vec<OdtParagraph>,
}

// =============================================================================
// TRACK CHANGES
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtTrackedChange {
    pub id: String,
    pub change_type: OdtChangeType,
    pub creator: Option<String>,
    pub date: Option<String>,
    pub content: Vec<OdtElement>,
}

#[derive(Debug, Clone)]
pub enum OdtChangeType {
    Insertion,
    Deletion,
    FormatChange,
}

// =============================================================================
// TABLE DES MATIÈRES / INDEX
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtToc {
    pub name: Option<String>,
    pub style_name: Option<String>,
    pub outline_level: Option<u8>,
    pub protected: bool,
    pub entries: Vec<OdtTocEntry>,
}

#[derive(Debug, Clone)]
pub struct OdtTocEntry {
    pub text: String,
    pub page_number: Option<String>,
    pub outline_level: u8,
}

#[derive(Debug, Clone)]
pub struct OdtIndex {
    pub name: Option<String>,
    pub index_type: OdtIndexType,
    pub entries: Vec<OdtIndexEntry>,
}

#[derive(Debug, Clone)]
pub enum OdtIndexType {
    Alphabetical,
    Table,
    Illustration,
    ObjectIndex,
    User,
    Bibliography,
}

#[derive(Debug, Clone)]
pub struct OdtIndexEntry {
    pub text: String,
    pub page_number: Option<String>,
}

// =============================================================================
// STYLES
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtStyle {
    /// Nom du style
    pub name: String,
    /// Famille (paragraph, text, table, etc.)
    pub family: OdtStyleFamily,
    /// Style parent
    pub parent_style_name: Option<String>,
    /// Style de liste associé
    pub list_style_name: Option<String>,
    /// Style de page maître
    pub master_page_name: Option<String>,
    /// Niveau de plan
    pub default_outline_level: Option<u8>,
    /// Propriétés de paragraphe
    pub paragraph_properties: Option<OdtParagraphProperties>,
    /// Propriétés de texte
    pub text_properties: Option<OdtTextProperties>,
    /// Propriétés de table
    pub table_properties: Option<OdtTableProperties>,
    /// Propriétés de colonne
    pub table_column_properties: Option<OdtTableColumnProperties>,
    /// Propriétés de ligne
    pub table_row_properties: Option<OdtTableRowProperties>,
    /// Propriétés de cellule
    pub table_cell_properties: Option<OdtTableCellProperties>,
    /// Propriétés graphiques
    pub graphic_properties: Option<OdtGraphicProperties>,
}

#[derive(Debug, Clone, Default)]
pub enum OdtStyleFamily {
    #[default]
    Paragraph,
    Text,
    Section,
    Table,
    TableColumn,
    TableRow,
    TableCell,
    Graphic,
    Drawing,
    Chart,
    Ruby,
}

#[derive(Debug, Clone, Default)]
pub struct OdtParagraphProperties {
    pub text_align: Option<String>,
    pub text_indent: Option<String>,
    pub margin_left: Option<String>,
    pub margin_right: Option<String>,
    pub margin_top: Option<String>,
    pub margin_bottom: Option<String>,
    pub line_height: Option<String>,
    pub background_color: Option<String>,
    pub border: Option<String>,
    pub border_top: Option<String>,
    pub border_bottom: Option<String>,
    pub border_left: Option<String>,
    pub border_right: Option<String>,
    pub padding: Option<String>,
    pub keep_with_next: Option<String>,
    pub keep_together: Option<String>,
    pub break_before: Option<String>,
    pub break_after: Option<String>,
    pub widows: Option<u32>,
    pub orphans: Option<u32>,
    pub tab_stops: Vec<OdtTabStop>,
    pub drop_cap: Option<OdtDropCap>,
}

#[derive(Debug, Clone)]
pub struct OdtTabStop {
    pub position: String,
    pub tab_type: Option<String>,
    pub leader_style: Option<String>,
    pub leader_text: Option<String>,
}

#[derive(Debug, Clone)]
pub struct OdtDropCap {
    pub lines: u32,
    pub length: Option<u32>,
    pub distance: Option<String>,
    pub style_name: Option<String>,
}

#[derive(Debug, Clone, Default)]
pub struct OdtTextProperties {
    pub font_name: Option<String>,
    pub font_family: Option<String>,
    pub font_size: Option<String>,
    pub font_style: Option<String>,
    pub font_weight: Option<String>,
    pub font_variant: Option<String>,
    pub color: Option<String>,
    pub background_color: Option<String>,
    pub text_decoration: Option<String>,
    pub text_underline_style: Option<String>,
    pub text_underline_type: Option<String>,
    pub text_underline_color: Option<String>,
    pub text_line_through_style: Option<String>,
    pub text_line_through_type: Option<String>,
    pub text_position: Option<String>, // superscript/subscript
    pub text_transform: Option<String>,
    pub letter_spacing: Option<String>,
    pub language: Option<String>,
    pub country: Option<String>,
    pub hyphenate: Option<bool>,
    pub text_shadow: Option<String>,
    pub text_outline: Option<bool>,
}

#[derive(Debug, Clone, Default)]
pub struct OdtTableProperties {
    pub width: Option<String>,
    pub rel_width: Option<String>,
    pub align: Option<String>,
    pub margin_left: Option<String>,
    pub margin_right: Option<String>,
    pub margin_top: Option<String>,
    pub margin_bottom: Option<String>,
    pub background_color: Option<String>,
    pub border: Option<String>,
    pub border_model: Option<String>,
    pub display: Option<bool>,
}

#[derive(Debug, Clone, Default)]
pub struct OdtTableColumnProperties {
    pub column_width: Option<String>,
    pub rel_column_width: Option<String>,
    pub use_optimal_width: Option<bool>,
}

#[derive(Debug, Clone, Default)]
pub struct OdtTableRowProperties {
    pub row_height: Option<String>,
    pub min_row_height: Option<String>,
    pub use_optimal_height: Option<bool>,
    pub background_color: Option<String>,
    pub keep_together: Option<String>,
}

#[derive(Debug, Clone, Default)]
pub struct OdtTableCellProperties {
    pub vertical_align: Option<String>,
    pub background_color: Option<String>,
    pub border: Option<String>,
    pub border_top: Option<String>,
    pub border_bottom: Option<String>,
    pub border_left: Option<String>,
    pub border_right: Option<String>,
    pub padding: Option<String>,
    pub wrap_option: Option<String>,
    pub rotation_angle: Option<f64>,
    pub print_content: Option<bool>,
    pub repeat_content: Option<bool>,
    pub shrink_to_fit: Option<bool>,
}

#[derive(Debug, Clone, Default)]
pub struct OdtGraphicProperties {
    pub stroke: Option<String>,
    pub stroke_width: Option<String>,
    pub stroke_color: Option<String>,
    pub fill: Option<String>,
    pub fill_color: Option<String>,
    pub opacity: Option<String>,
    pub shadow: Option<String>,
    pub mirror: Option<String>,
    pub clip: Option<String>,
    pub wrap: Option<String>,
    pub horizontal_pos: Option<String>,
    pub horizontal_rel: Option<String>,
    pub vertical_pos: Option<String>,
    pub vertical_rel: Option<String>,
    pub run_through: Option<String>,
}

// =============================================================================
// MASTER PAGES
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtMasterPage {
    pub name: String,
    pub page_layout_name: Option<String>,
    pub next_style_name: Option<String>,
    pub header: Option<OdtHeaderFooter>,
    pub footer: Option<OdtHeaderFooter>,
    pub header_first: Option<OdtHeaderFooter>,
    pub footer_first: Option<OdtHeaderFooter>,
    pub header_left: Option<OdtHeaderFooter>,
    pub footer_left: Option<OdtHeaderFooter>,
}

#[derive(Debug, Clone)]
pub struct OdtHeaderFooter {
    pub content: Vec<OdtElement>,
    pub display: bool,
}

// =============================================================================
// FONT DECLARATIONS
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtFontDecl {
    pub name: String,
    pub font_family: Option<String>,
    pub font_family_generic: Option<String>,
    pub font_pitch: Option<String>,
    pub font_charset: Option<String>,
}

// =============================================================================
// IMAGES
// =============================================================================

#[derive(Debug, Clone)]
pub struct OdtImage {
    pub data: Vec<u8>,
    pub mime_type: String,
    pub path: String,
}

// =============================================================================
// SETTINGS
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct OdtSettings {
    pub view_settings: HashMap<String, String>,
    pub configuration_settings: HashMap<String, String>,
}
