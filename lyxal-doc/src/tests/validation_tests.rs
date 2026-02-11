use crate::core::document::Document;
use crate::core::node::{Block, SectionBlock, Inline, TextInline, ParagraphBlock};
use crate::core::Metadata;
use crate::validate::{Validator, ValidationError};

#[test]
fn test_validate_empty_section_fails() {
    let mut doc = Document::new("doc-1".to_string(), "Test".to_string());
    doc.content.push(Block::Section(SectionBlock {
        id: "sec-1".to_string(),
        meta: Metadata::default(),
        level: 1,
        children: vec![], // Vide, devrait échouer
    }));
    
    let result = Validator::validate_document(&doc);
    assert!(result.is_err());
    assert_eq!(result.unwrap_err(), ValidationError::EmptySection { id: "sec-1".to_string() });
}

#[test]
fn test_validate_empty_text_fails() {
    let mut doc = Document::new("doc-1".to_string(), "Test".to_string());
    doc.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![
            Inline::Text(TextInline { text: "".to_string() }) // Vide, devrait échouer
        ],
    }));
    
    let result = Validator::validate_document(&doc);
    assert!(result.is_err());
    assert_eq!(result.unwrap_err(), ValidationError::EmptyText);
}

#[test]
fn test_validate_valid_doc_passes() {
    let mut doc = Document::new("doc-1".to_string(), "Test".to_string());
    doc.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![
            Inline::Text(TextInline { text: "Contenu valide".to_string() })
        ],
    }));
    
    let result = Validator::validate_document(&doc);
    assert!(result.is_ok());
}

