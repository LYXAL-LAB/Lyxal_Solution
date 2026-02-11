//! HTML Document Model
//!
//! Types représentant la structure simplifiée d'un document HTML.

/// Document HTML parsé
#[derive(Debug, Clone, Default)]
pub struct HtmlDocument {
    /// Titre du document (<title>)
    pub title: Option<String>,
    /// Corps du document (éléments simplifiés)
    pub body: Vec<HtmlElement>,
    /// Métadonnées
    pub metadata: std::collections::HashMap<String, String>,
}

#[derive(Debug, Clone)]
pub enum HtmlElement {
    Heading { level: u32, content: String },
    Paragraph(String),
    List { items: Vec<String>, ordered: bool },
    Table { rows: Vec<Vec<String>> },
    Link { url: String, text: String },
    Image { src: String, alt: Option<String> },
    Raw(String),
}
