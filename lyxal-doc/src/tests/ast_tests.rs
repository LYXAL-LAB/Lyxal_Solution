use crate::core::document::Document;
use crate::core::node::{Block, ParagraphBlock, Inline, TextInline};
use crate::core::Metadata;

#[test]
fn test_create_simple_document() {
    let mut doc = Document::new("doc-1".to_string(), "Mon Document".to_string());
    
    let p = Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![
            Inline::Text(TextInline { text: "Hello world".to_string() })
        ],
    });
    
    doc.content.push(p);
    
    assert_eq!(doc.title, "Mon Document");
    assert_eq!(doc.content.len(), 1);
}

