use crate::core::document::Document;
use crate::core::node::{Block, ParagraphBlock, Inline, TextInline, SectionBlock};
use crate::core::Metadata;
use crate::word::WordInterpreter;

#[test]
fn test_word_interpretation_basic() {
    let mut doc = Document::new("doc-1".to_string(), "Mon Contrat".to_string());
    doc.meta.author = Some("Jean Dupont".to_string());

    // Section 1
    doc.content.push(Block::Section(SectionBlock {
        id: "sec-1".to_string(),
        meta: Metadata::default(),
        level: 1,
        children: vec![
            Block::Paragraph(ParagraphBlock {
                id: "p-1".to_string(),
                meta: Metadata::default(),
                inlines: vec![Inline::Text(TextInline { text: "Introduction".to_string() })],
            })
        ],
    }));

    let mut interpreter = WordInterpreter::new();
    let layout = interpreter.interpret(&doc).expect("Interpretation should succeed");

    assert_eq!(layout.metadata.title, "Mon Contrat");
    assert_eq!(layout.metadata.author, "Jean Dupont");
    assert_eq!(layout.pages.len(), 1);
    
    // Vérifier le titre de section interprété
    let page = &layout.pages[0];
    assert!(matches!(page.body[0], crate::word::layout::WordElement::Heading { .. }));
}

