use crate::core::node::NodeId;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WordLayout {
    pub pages: Vec<WordPage>,
    pub metadata: WordDocumentMetadata,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WordPage {
    pub header: Option<Vec<WordElement>>,
    pub body: Vec<WordElement>,
    pub footer: Option<Vec<WordElement>>,
    pub footnotes: Vec<WordFootnote>,
    pub number: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WordFootnote {
    pub number: u32,
    pub content: Vec<WordElement>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum WordElement {
    Paragraph {
        id: NodeId,
        text_runs: Vec<WordTextRun>,
        style: Option<String>,
        indent_level: u8,
        numbering: Option<String>,
        is_locked: bool, // Support de NodePolicy
    },
    Table {
        id: NodeId,
        rows: Vec<WordTableRow>,
    },
    Heading {
        id: NodeId,
        level: u8,
        text: String,
        numbering: String,
    },
    PageBreak,
    Image {
        id: NodeId,
        src: String,
        caption: Option<String>,
    },
    Comment {
        id: NodeId,
        author: String,
        text: String,
        target_id: NodeId,
    },
    Revision {
        id: NodeId,
        change_type: String,
        content: Vec<WordElement>,
    },
    SignatureSlot {
        id: NodeId,
        role: String,
    },
    Shape {
        id: NodeId,
        shape_type: String,
        label: String, // Représentation textuelle de la forme dans Word
    },
    IntentPlaceholder {
        id: NodeId,
        intent_type: String,
        label: String,
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WordTableRow {
    pub cells: Vec<WordTableCell>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WordTableCell {
    pub content: Vec<WordElement>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WordTextRun {
    pub text: String,
    pub bold: bool,
    pub italic: bool,
    pub underline: bool,
    pub strike: bool,
    pub style: Option<String>,
    pub field_type: Option<String>,
    pub is_value: bool,
    pub is_ref: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct WordDocumentMetadata {
    pub title: String,
    pub author: String,
    pub table_of_contents_present: bool,
}
