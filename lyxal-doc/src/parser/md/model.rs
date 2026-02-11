//! Markdown Document Model
//!
//! Types représentant la structure d'un document Markdown (CommonMark + GFM).

/// Document Markdown parsé
#[derive(Debug, Clone, Default)]
pub struct MdDocument {
    /// Blocs de contenu
    pub blocks: Vec<MdBlock>,
    /// Métadonnées (Frontmatter YAML/TOML)
    pub metadata: std::collections::HashMap<String, String>,
    /// Avertissements
    pub warnings: Vec<String>,
}

/// Blocs Markdown
#[derive(Debug, Clone)]
pub enum MdBlock {
    Heading { level: u32, content: Vec<MdInline> },
    Paragraph(Vec<MdInline>),
    BlockQuote(Vec<MdBlock>),
    CodeBlock { language: Option<String>, code: String },
    List { items: Vec<MdListItem>, ordered: bool, start: Option<u32> },
    Table { header: Vec<MdTableCell>, rows: Vec<Vec<MdTableCell>> },
    ThematicBreak,
    Html(String),
}

/// Éléments Inline Markdown
#[derive(Debug, Clone)]
pub enum MdInline {
    Text(String),
    Emphasis(Vec<MdInline>),
    Strong(Vec<MdInline>),
    Strikethrough(Vec<MdInline>),
    Link { url: String, title: Option<String>, content: Vec<MdInline> },
    Image { url: String, alt: String, title: Option<String> },
    Code(String),
    LineBreak,
    SoftBreak,
    Html(String),
    Task(bool), // GFM Task list [ ] or [x]
}

#[derive(Debug, Clone)]
pub struct MdListItem {
    pub content: Vec<MdBlock>,
    pub checked: Option<bool>, // GFM Task list
}

#[derive(Debug, Clone)]
pub struct MdTableCell {
    pub content: Vec<MdInline>,
    pub alignment: MdAlignment,
}

#[derive(Debug, Clone, Default)]
pub enum MdAlignment {
    #[default]
    None,
    Left,
    Center,
    Right,
}
