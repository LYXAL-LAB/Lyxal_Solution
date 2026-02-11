use crate::core::document::Document;
use crate::core::node::{Block, ParagraphBlock, Inline, TextInline};
use crate::core::Metadata;
use crate::serialize::json::to_canonical_json;

#[test]
fn test_canonical_json_stability() {
    let mut doc = Document::new("doc-1".to_string(), "Test".to_string());
    doc.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![
            Inline::Text(TextInline { text: "Hello".to_string() })
        ],
    }));
    
    let json1 = to_canonical_json(&doc).unwrap();
    let json2 = to_canonical_json(&doc).unwrap();
    
    // Le JSON doit être identique à chaque appel
    assert_eq!(json1, json2);
}

