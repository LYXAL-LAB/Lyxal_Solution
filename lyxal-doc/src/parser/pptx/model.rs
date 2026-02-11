//! PPTX Document Model
//!
//! Types représentant la structure complète d'une présentation PPTX (Office Open XML).
//!
//! ## Format PPTX
//!
//! PPTX est basé sur PresentationML (ECMA-376, ISO/IEC 29500).

use std::collections::HashMap;

// =============================================================================
// DOCUMENT PRINCIPAL
// =============================================================================

/// Présentation PPTX parsée
#[derive(Debug, Clone, Default)]
pub struct PptxDocument {
    /// Métadonnées
    pub metadata: PptxMetadata,
    /// Diapositives
    pub slides: Vec<PptxSlide>,
    /// Masters de diapositives
    pub slide_masters: Vec<PptxSlideMaster>,
    /// Layouts de diapositives
    pub slide_layouts: Vec<PptxSlideLayout>,
    /// Thème
    pub theme: Option<PptxTheme>,
    /// Images embarquées (rId -> données)
    pub images: HashMap<String, PptxImage>,
    /// Médias (audio, vidéo)
    pub media: HashMap<String, PptxMedia>,
    /// Notes du présentateur
    pub notes: HashMap<usize, PptxNotes>,
    /// Commentaires
    pub comments: Vec<PptxComment>,
    /// Propriétés de la présentation
    pub properties: PptxPresentationProperties,
    /// Avertissements
    pub warnings: Vec<String>,
}

// =============================================================================
// MÉTADONNÉES
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct PptxMetadata {
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
    pub slide_count: Option<u32>,
    pub paragraph_count: Option<u32>,
    pub word_count: Option<u32>,
    pub notes_count: Option<u32>,
    pub hidden_slide_count: Option<u32>,
    pub presentation_format: Option<String>,
}

// =============================================================================
// PROPRIÉTÉS DE PRÉSENTATION
// =============================================================================

#[derive(Debug, Clone, Default)]
pub struct PptxPresentationProperties {
    /// Largeur de diapositive (EMUs)
    pub slide_width: i64,
    /// Hauteur de diapositive (EMUs)
    pub slide_height: i64,
    /// Premier numéro de diapositive
    pub first_slide_num: u32,
    /// Afficher animation
    pub show_animation: bool,
    /// Enregistrer comme lecture seule
    pub save_read_only_recommended: bool,
    /// Embedded fonts
    pub embed_true_type_fonts: bool,
}

// =============================================================================
// DIAPOSITIVE
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxSlide {
    /// Index (1-based)
    pub index: usize,
    /// ID de relation du layout
    pub layout_rel_id: Option<String>,
    /// Nom de la diapositive
    pub name: Option<String>,
    /// Masquée
    pub hidden: bool,
    /// Arbre de formes
    pub shapes: Vec<PptxShape>,
    /// Arrière-plan
    pub background: Option<PptxBackground>,
    /// Timing (animations)
    pub timing: Option<PptxTiming>,
    /// Transition
    pub transition: Option<PptxTransition>,
}

// =============================================================================
// SHAPES (FORMES)
// =============================================================================

#[derive(Debug, Clone)]
pub enum PptxShape {
    /// Forme avec texte (p:sp)
    Shape(PptxShapeProperties),
    /// Image (p:pic)
    Picture(PptxPicture),
    /// Graphique (p:graphicFrame)
    GraphicFrame(PptxGraphicFrame),
    /// Groupe de formes (p:grpSp)
    Group(PptxGroupShape),
    /// Connecteur (p:cxnSp)
    Connector(PptxConnector),
    /// Contenu OLE
    OleObject(PptxOleObject),
    /// Contenu alternatif
    AlternateContent(Box<PptxShape>),
}

#[derive(Debug, Clone)]
pub struct PptxShapeProperties {
    /// ID
    pub id: u32,
    /// Nom
    pub name: String,
    /// Description (alt text)
    pub description: Option<String>,
    /// Titre
    pub title: Option<String>,
    /// Placeholder
    pub placeholder: Option<PptxPlaceholder>,
    /// Transformation (position, taille, rotation)
    pub transform: PptxTransform2D,
    /// Géométrie preset
    pub preset_geometry: Option<String>,
    /// Géométrie custom
    pub custom_geometry: Option<PptxCustomGeometry>,
    /// Remplissage
    pub fill: Option<PptxFill>,
    /// Contour
    pub outline: Option<PptxOutline>,
    /// Effet
    pub effect: Option<PptxEffect>,
    /// Corps de texte
    pub text_body: Option<PptxTextBody>,
    /// Lien hypertexte
    pub hyperlink: Option<PptxHyperlink>,
    /// Verrouillé
    pub locked: bool,
    /// Visible
    pub visible: bool,
}

#[derive(Debug, Clone)]
pub struct PptxPlaceholder {
    /// Type (title, body, ctrTitle, subTitle, dt, ftr, sldNum, etc.)
    pub placeholder_type: PptxPlaceholderType,
    /// Index
    pub idx: Option<u32>,
    /// Taille (full, half, quarter)
    pub size: Option<String>,
    /// A du contenu
    pub has_custom_prompt: bool,
}

#[derive(Debug, Clone, Default)]
pub enum PptxPlaceholderType {
    #[default]
    Body,
    Title,
    CenteredTitle,
    Subtitle,
    DateAndTime,
    Footer,
    SlideNumber,
    Header,
    Object,
    Chart,
    Table,
    ClipArt,
    Diagram,
    Media,
    SlideImage,
    Picture,
    Other(String),
}

#[derive(Debug, Clone, Default)]
pub struct PptxTransform2D {
    /// Offset X (EMUs)
    pub x: i64,
    /// Offset Y (EMUs)
    pub y: i64,
    /// Largeur (EMUs)
    pub cx: i64,
    /// Hauteur (EMUs)
    pub cy: i64,
    /// Rotation (60000ths of a degree)
    pub rotation: i32,
    /// Flip horizontal
    pub flip_h: bool,
    /// Flip vertical
    pub flip_v: bool,
}

#[derive(Debug, Clone)]
pub struct PptxCustomGeometry {
    pub path_list: Vec<PptxPath>,
}

#[derive(Debug, Clone)]
pub struct PptxPath {
    pub commands: Vec<PptxPathCommand>,
    pub fill_mode: Option<String>,
    pub stroke: bool,
}

#[derive(Debug, Clone)]
pub enum PptxPathCommand {
    MoveTo { x: i64, y: i64 },
    LineTo { x: i64, y: i64 },
    ArcTo { wr: i64, hr: i64, start_ang: i64, swing_ang: i64 },
    QuadBezierTo { x1: i64, y1: i64, x: i64, y: i64 },
    CubicBezierTo { x1: i64, y1: i64, x2: i64, y2: i64, x: i64, y: i64 },
    Close,
}

// =============================================================================
// REMPLISSAGE
// =============================================================================

#[derive(Debug, Clone)]
pub enum PptxFill {
    NoFill,
    Solid(PptxSolidFill),
    Gradient(PptxGradientFill),
    Pattern(PptxPatternFill),
    Picture(PptxPictureFill),
    Group,
}

#[derive(Debug, Clone)]
pub struct PptxSolidFill {
    pub color: PptxColor,
}

#[derive(Debug, Clone)]
pub struct PptxGradientFill {
    pub stops: Vec<PptxGradientStop>,
    pub linear: Option<PptxLinearGradient>,
    pub path: Option<PptxPathGradient>,
    pub tile_rect: Option<PptxRect>,
    pub rotate_with_shape: bool,
}

#[derive(Debug, Clone)]
pub struct PptxGradientStop {
    pub position: u32, // 0-100000
    pub color: PptxColor,
}

#[derive(Debug, Clone)]
pub struct PptxLinearGradient {
    pub angle: i32, // 60000ths of a degree
    pub scaled: bool,
}

#[derive(Debug, Clone)]
pub struct PptxPathGradient {
    pub path: String, // rect, circle, shape
    pub fill_to_rect: Option<PptxRect>,
}

#[derive(Debug, Clone)]
pub struct PptxRect {
    pub l: i32,
    pub t: i32,
    pub r: i32,
    pub b: i32,
}

#[derive(Debug, Clone)]
pub struct PptxPatternFill {
    pub preset: String,
    pub foreground: PptxColor,
    pub background: PptxColor,
}

#[derive(Debug, Clone)]
pub struct PptxPictureFill {
    pub blip_rel_id: String,
    pub source_rect: Option<PptxRect>,
    pub stretch: bool,
    pub tile: Option<PptxTile>,
}

#[derive(Debug, Clone)]
pub struct PptxTile {
    pub tx: i64,
    pub ty: i64,
    pub sx: i32,
    pub sy: i32,
    pub flip: Option<String>,
    pub align: Option<String>,
}

// =============================================================================
// COULEUR
// =============================================================================

#[derive(Debug, Clone)]
pub enum PptxColor {
    Rgb(String),        // RRGGBB
    Theme(PptxThemeColor),
    System(String),
    Preset(String),
    Scheme(String),
}

#[derive(Debug, Clone)]
pub struct PptxThemeColor {
    pub val: String,    // dk1, lt1, dk2, lt2, accent1-6, hlink, folHlink
    pub lum_mod: Option<i32>,
    pub lum_off: Option<i32>,
    pub shade: Option<i32>,
    pub tint: Option<i32>,
    pub sat_mod: Option<i32>,
    pub alpha: Option<i32>,
}

// =============================================================================
// CONTOUR
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxOutline {
    pub width: u32, // EMUs
    pub fill: Option<PptxFill>,
    pub dash: Option<String>,
    pub cap: Option<String>,
    pub compound: Option<String>,
    pub align: Option<String>,
    pub join: Option<PptxLineJoin>,
    pub head_end: Option<PptxLineEnd>,
    pub tail_end: Option<PptxLineEnd>,
}

#[derive(Debug, Clone)]
pub enum PptxLineJoin {
    Round,
    Bevel,
    Miter { lim: Option<i32> },
}

#[derive(Debug, Clone)]
pub struct PptxLineEnd {
    pub end_type: String, // none, triangle, stealth, diamond, oval, arrow
    pub width: Option<String>,
    pub length: Option<String>,
}

// =============================================================================
// EFFETS
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxEffect {
    pub shadow: Option<PptxShadow>,
    pub reflection: Option<PptxReflection>,
    pub glow: Option<PptxGlow>,
    pub soft_edge: Option<PptxSoftEdge>,
    pub preset: Option<String>,
}

#[derive(Debug, Clone)]
pub struct PptxShadow {
    pub shadow_type: String, // outer, inner
    pub blur_rad: Option<i64>,
    pub dist: Option<i64>,
    pub dir: Option<i32>,
    pub sx: Option<i32>,
    pub sy: Option<i32>,
    pub kx: Option<i32>,
    pub ky: Option<i32>,
    pub align: Option<String>,
    pub color: Option<PptxColor>,
}

#[derive(Debug, Clone)]
pub struct PptxReflection {
    pub blur_rad: Option<i64>,
    pub start_opacity: Option<i32>,
    pub end_opacity: Option<i32>,
    pub dist: Option<i64>,
    pub dir: Option<i32>,
    pub fade_dir: Option<i32>,
    pub sx: Option<i32>,
    pub sy: Option<i32>,
    pub align: Option<String>,
}

#[derive(Debug, Clone)]
pub struct PptxGlow {
    pub rad: i64,
    pub color: PptxColor,
}

#[derive(Debug, Clone)]
pub struct PptxSoftEdge {
    pub rad: i64,
}

// =============================================================================
// TEXTE
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxTextBody {
    pub properties: PptxBodyProperties,
    pub paragraphs: Vec<PptxParagraph>,
    pub list_style: Option<PptxListStyle>,
}

#[derive(Debug, Clone, Default)]
pub struct PptxBodyProperties {
    pub anchor: Option<String>, // t, ctr, b
    pub anchor_center: bool,
    pub wrap: Option<String>, // none, square
    pub vertical: Option<String>,
    pub rotation: Option<i32>,
    pub left_inset: Option<i64>,
    pub right_inset: Option<i64>,
    pub top_inset: Option<i64>,
    pub bottom_inset: Option<i64>,
    pub num_columns: Option<u32>,
    pub space_between_columns: Option<i64>,
    pub auto_fit: Option<PptxAutoFit>,
}

#[derive(Debug, Clone)]
pub enum PptxAutoFit {
    None,
    Normal { font_scale: Option<i32>, line_space_reduction: Option<i32> },
    Shape,
}

#[derive(Debug, Clone)]
pub struct PptxParagraph {
    pub properties: PptxParagraphProperties,
    pub runs: Vec<PptxRun>,
    pub end_para_rpr: Option<PptxRunProperties>,
}

#[derive(Debug, Clone, Default)]
pub struct PptxParagraphProperties {
    pub margin_left: Option<i64>,
    pub margin_right: Option<i64>,
    pub indent: Option<i64>,
    pub align: Option<String>, // l, ctr, r, just, justLow, dist, thaiDist
    pub default_tab_size: Option<i64>,
    pub rtl: bool,
    pub font_align: Option<String>,
    pub bullet: Option<PptxBullet>,
    pub line_spacing: Option<PptxSpacing>,
    pub space_before: Option<PptxSpacing>,
    pub space_after: Option<PptxSpacing>,
    pub level: u8,
}

#[derive(Debug, Clone)]
pub enum PptxBullet {
    None,
    Auto,
    Char { char: String, font: Option<PptxFont> },
    Picture { blip_rel_id: String },
    Number { format: String, start_at: Option<i32> },
}

#[derive(Debug, Clone)]
pub struct PptxSpacing {
    pub spacing_type: PptxSpacingType,
    pub value: i32,
}

#[derive(Debug, Clone)]
pub enum PptxSpacingType {
    Points,    // spcPts
    Percent,   // spcPct (1/1000 of percent)
}

#[derive(Debug, Clone)]
pub struct PptxRun {
    pub properties: Option<PptxRunProperties>,
    pub text: String,
}

#[derive(Debug, Clone, Default)]
pub struct PptxRunProperties {
    pub font_size: Option<u32>, // Centièmes de point
    pub bold: Option<bool>,
    pub italic: Option<bool>,
    pub underline: Option<String>,
    pub strike: Option<String>,
    pub cap: Option<String>,
    pub baseline: Option<i32>,
    pub spacing: Option<i32>,
    pub kern: Option<i32>,
    pub font: Option<PptxFont>,
    pub fill: Option<PptxFill>,
    pub outline: Option<PptxOutline>,
    pub effect: Option<PptxEffect>,
    pub highlight: Option<PptxColor>,
    pub hyperlink: Option<PptxHyperlink>,
    pub language: Option<String>,
    pub alternative_language: Option<String>,
}

#[derive(Debug, Clone)]
pub struct PptxFont {
    pub latin: Option<String>,
    pub east_asian: Option<String>,
    pub complex_script: Option<String>,
    pub symbol: Option<String>,
}

#[derive(Debug, Clone)]
pub struct PptxListStyle {
    pub levels: Vec<PptxListLevel>,
}

#[derive(Debug, Clone)]
pub struct PptxListLevel {
    pub level: u8,
    pub paragraph_properties: PptxParagraphProperties,
    pub run_properties: Option<PptxRunProperties>,
}

#[derive(Debug, Clone)]
pub struct PptxHyperlink {
    pub rel_id: Option<String>,
    pub action: Option<String>,
    pub target_frame: Option<String>,
    pub tooltip: Option<String>,
    pub invalid_url: bool,
    pub history: bool,
    pub highlight_click: bool,
    pub end_sound: bool,
}

// =============================================================================
// IMAGES
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxPicture {
    pub id: u32,
    pub name: String,
    pub description: Option<String>,
    pub transform: PptxTransform2D,
    pub blip_rel_id: String,
    pub source_rect: Option<PptxRect>,
    pub fill_rect: Option<PptxRect>,
    pub stretch: bool,
    pub hyperlink: Option<PptxHyperlink>,
}

#[derive(Debug, Clone)]
pub struct PptxImage {
    pub data: Vec<u8>,
    pub content_type: String,
    pub filename: Option<String>,
}

// =============================================================================
// GRAPHIQUES ET TABLEAUX
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxGraphicFrame {
    pub id: u32,
    pub name: String,
    pub transform: PptxTransform2D,
    pub content: PptxGraphicContent,
}

#[derive(Debug, Clone)]
pub enum PptxGraphicContent {
    Table(PptxTable),
    Chart(PptxChart),
    Diagram(PptxDiagram),
    Ole(PptxOleObject),
    Other(String),
}

#[derive(Debug, Clone)]
pub struct PptxTable {
    pub rows: Vec<PptxTableRow>,
    pub grid_cols: Vec<i64>, // Largeur de chaque colonne
    pub properties: Option<PptxTableProperties>,
}

#[derive(Debug, Clone)]
pub struct PptxTableRow {
    pub height: i64,
    pub cells: Vec<PptxTableCell>,
}

#[derive(Debug, Clone)]
pub struct PptxTableCell {
    pub row_span: u32,
    pub grid_span: u32,
    pub h_merge: bool,
    pub v_merge: bool,
    pub text_body: Option<PptxTextBody>,
    pub properties: Option<PptxTableCellProperties>,
}

#[derive(Debug, Clone, Default)]
pub struct PptxTableProperties {
    pub rtl: bool,
    pub first_row: bool,
    pub first_col: bool,
    pub last_row: bool,
    pub last_col: bool,
    pub banding_row: bool,
    pub banding_col: bool,
}

#[derive(Debug, Clone, Default)]
pub struct PptxTableCellProperties {
    pub margin_left: Option<i64>,
    pub margin_right: Option<i64>,
    pub margin_top: Option<i64>,
    pub margin_bottom: Option<i64>,
    pub anchor: Option<String>,
    pub anchor_center: bool,
    pub vertical: Option<String>,
    pub fill: Option<PptxFill>,
    pub borders: Option<PptxCellBorders>,
}

#[derive(Debug, Clone, Default)]
pub struct PptxCellBorders {
    pub left: Option<PptxOutline>,
    pub right: Option<PptxOutline>,
    pub top: Option<PptxOutline>,
    pub bottom: Option<PptxOutline>,
    pub tl_to_br: Option<PptxOutline>,
    pub bl_to_tr: Option<PptxOutline>,
}

#[derive(Debug, Clone)]
pub struct PptxChart {
    pub rel_id: String,
}

#[derive(Debug, Clone)]
pub struct PptxDiagram {
    pub data_rel_id: String,
    pub layout_rel_id: Option<String>,
    pub style_rel_id: Option<String>,
    pub colors_rel_id: Option<String>,
}

#[derive(Debug, Clone)]
pub struct PptxOleObject {
    pub prog_id: Option<String>,
    pub rel_id: Option<String>,
    pub show_as_icon: bool,
    pub img_rel_id: Option<String>,
}

// =============================================================================
// GROUPES ET CONNECTEURS
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxGroupShape {
    pub id: u32,
    pub name: String,
    pub transform: PptxTransform2D,
    pub child_transform: Option<PptxTransform2D>,
    pub shapes: Vec<PptxShape>,
}

#[derive(Debug, Clone)]
pub struct PptxConnector {
    pub id: u32,
    pub name: String,
    pub transform: PptxTransform2D,
    pub preset_geometry: Option<String>,
    pub fill: Option<PptxFill>,
    pub outline: Option<PptxOutline>,
    pub start_connection: Option<PptxConnection>,
    pub end_connection: Option<PptxConnection>,
}

#[derive(Debug, Clone)]
pub struct PptxConnection {
    pub shape_id: u32,
    pub connection_idx: u32,
}

// =============================================================================
// ARRIÈRE-PLAN
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxBackground {
    pub fill: PptxFill,
    pub shade_to_title: bool,
}

// =============================================================================
// ANIMATIONS ET TRANSITIONS
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxTiming {
    pub build_list: Vec<PptxBuildEntry>,
    pub sequences: Vec<PptxTimeSequence>,
}

#[derive(Debug, Clone)]
pub struct PptxBuildEntry {
    pub shape_id: u32,
    pub grp_id: Option<u32>,
    pub build_type: String,
}

#[derive(Debug, Clone)]
pub struct PptxTimeSequence {
    pub concurrent: bool,
    pub next_action: String,
    pub prev_action: String,
    pub nodes: Vec<PptxTimeNode>,
}

#[derive(Debug, Clone)]
pub struct PptxTimeNode {
    pub node_type: String,
    pub preset_id: Option<u32>,
    pub preset_class: Option<String>,
    pub preset_subtype: Option<u32>,
    pub duration: Option<i64>,
    pub target_shape_id: Option<u32>,
}

#[derive(Debug, Clone)]
pub struct PptxTransition {
    pub transition_type: Option<String>,
    pub speed: Option<String>,
    pub advance_on_click: bool,
    pub advance_after_time: Option<u32>,
    pub sound_action: Option<PptxSoundAction>,
}

#[derive(Debug, Clone)]
pub struct PptxSoundAction {
    pub action: String, // stSnd, stopSnd
    pub rel_id: Option<String>,
    pub name: Option<String>,
    pub loop_sound: bool,
}

// =============================================================================
// MASTERS ET LAYOUTS
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxSlideMaster {
    pub rel_id: String,
    pub name: Option<String>,
    pub shapes: Vec<PptxShape>,
    pub color_map: PptxColorMap,
    pub slide_layouts: Vec<String>, // rel_ids
    pub text_styles: PptxTextStyles,
    pub theme_rel_id: Option<String>,
}

#[derive(Debug, Clone)]
pub struct PptxSlideLayout {
    pub rel_id: String,
    pub name: Option<String>,
    pub layout_type: Option<String>,
    pub shapes: Vec<PptxShape>,
    pub master_rel_id: String,
    pub show_master_shapes: bool,
    pub show_master_placeholders: bool,
}

#[derive(Debug, Clone, Default)]
pub struct PptxColorMap {
    pub bg1: Option<String>,
    pub tx1: Option<String>,
    pub bg2: Option<String>,
    pub tx2: Option<String>,
    pub accent1: Option<String>,
    pub accent2: Option<String>,
    pub accent3: Option<String>,
    pub accent4: Option<String>,
    pub accent5: Option<String>,
    pub accent6: Option<String>,
    pub hlink: Option<String>,
    pub fol_hlink: Option<String>,
}

#[derive(Debug, Clone, Default)]
pub struct PptxTextStyles {
    pub title_style: Option<PptxListStyle>,
    pub body_style: Option<PptxListStyle>,
    pub other_style: Option<PptxListStyle>,
}

// =============================================================================
// THÈME
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxTheme {
    pub name: String,
    pub color_scheme: PptxColorScheme,
    pub font_scheme: PptxFontScheme,
    pub format_scheme: Option<PptxFormatScheme>,
}

#[derive(Debug, Clone, Default)]
pub struct PptxColorScheme {
    pub name: String,
    pub colors: HashMap<String, String>, // dk1, lt1, etc. -> RRGGBB
}

#[derive(Debug, Clone, Default)]
pub struct PptxFontScheme {
    pub name: String,
    pub major_font: PptxThemeFont,
    pub minor_font: PptxThemeFont,
}

#[derive(Debug, Clone, Default)]
pub struct PptxThemeFont {
    pub latin: String,
    pub east_asian: Option<String>,
    pub complex_script: Option<String>,
}

#[derive(Debug, Clone)]
pub struct PptxFormatScheme {
    pub name: String,
    pub fill_styles: Vec<PptxFill>,
    pub line_styles: Vec<PptxOutline>,
    pub effect_styles: Vec<PptxEffect>,
    pub bg_fill_styles: Vec<PptxFill>,
}

// =============================================================================
// NOTES ET COMMENTAIRES
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxNotes {
    pub slide_index: usize,
    pub shapes: Vec<PptxShape>,
}

#[derive(Debug, Clone)]
pub struct PptxComment {
    pub id: u32,
    pub author_id: u32,
    pub author_name: String,
    pub date: Option<String>,
    pub text: String,
    pub position: Option<PptxPoint>,
    pub slide_index: Option<usize>,
}

#[derive(Debug, Clone)]
pub struct PptxPoint {
    pub x: i64,
    pub y: i64,
}

// =============================================================================
// MEDIA
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxMedia {
    pub data: Vec<u8>,
    pub content_type: String,
    pub filename: Option<String>,
    pub media_type: PptxMediaType,
}

#[derive(Debug, Clone)]
pub enum PptxMediaType {
    Audio,
    Video,
    Other,
}

// =============================================================================
// RELATIONSHIPS
// =============================================================================

#[derive(Debug, Clone)]
pub struct PptxRelationship {
    pub id: String,
    pub rel_type: PptxRelType,
    pub target: String,
    pub target_mode: Option<String>,
}

#[derive(Debug, Clone)]
pub enum PptxRelType {
    Slide,
    SlideMaster,
    SlideLayout,
    Theme,
    NotesMaster,
    NotesSlide,
    HandoutMaster,
    Image,
    Audio,
    Video,
    Hyperlink,
    Chart,
    OleObject,
    Comments,
    CommentAuthors,
    Other(String),
}
