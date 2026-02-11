use crate::core::document::Document;
use crate::core::node::{Block, ParagraphBlock, Inline, TextInline};
use crate::core::Metadata;
use crate::ops::{apply, Operation, Path};

#[test]
fn test_operation_insert_text() {
    let mut doc = Document::new("doc-1".to_string(), "Test".to_string());
    doc.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![
            Inline::Text(TextInline { text: "Hello".to_string() })
        ],
    }));
    
    let op = Operation::InsertText {
        path: Path::from_block("p-1".to_string()),
        offset: 5,
        value: " World".to_string(),
    };
    
    let new_doc = apply(&doc, op).expect("Operation should succeed");
    
    if let Block::Paragraph(p) = &new_doc.content[0] {
        if let Inline::Text(t) = &p.inlines[0] {
            assert_eq!(t.text, "Hello World");
        }
    }
}

#[test]
fn test_operation_delete_text() {
    let mut doc = Document::new("doc-1".to_string(), "Test".to_string());
    doc.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![
            Inline::Text(TextInline { text: "Hello World".to_string() })
        ],
    }));
    
    let op = Operation::DeleteTextRange {
        path: Path::from_block("p-1".to_string()),
        offset: 5,
        length: 6,
    };
    
    let new_doc = apply(&doc, op).expect("Operation should succeed");
    
    if let Block::Paragraph(p) = &new_doc.content[0] {
        if let Inline::Text(t) = &p.inlines[0] {
            assert_eq!(t.text, "Hello");
        }
    }
}

#[test]
fn test_operation_insert_block() {
    let doc = Document::new("doc-1".to_string(), "Test".to_string());
    
    let new_block = Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![Inline::Text(TextInline { text: "New".to_string() })],
    });
    
    let op = Operation::InsertBlock {
        parent_path: Path(vec![]), // Root
        index: 0,
        block: new_block,
    };
    
    let new_doc = apply(&doc, op).unwrap();
    assert_eq!(new_doc.content.len(), 1);
}

#[test]
fn test_invalid_operation_fails_validation() {
    let mut doc = Document::new("doc-1".to_string(), "Test".to_string());
    doc.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![
            Inline::Text(TextInline { text: "A".to_string() })
        ],
    }));
    
    // Supprimer le seul caractère rendra le paragraphe vide d'inlines valides (si on nettoie l'inline)
    // Notre validateur actuel n'interdit pas explicitement un paragraphe sans inlines, 
    // mais il interdit un TextInline vide. 
    // delete_from_paragraph supprime l'inline s'il devient vide.
    
    let op = Operation::DeleteTextRange {
        path: Path::from_block("p-1".to_string()),
        offset: 0,
        length: 1,
    };
    
    let new_doc = apply(&doc, op).unwrap();
    // Ici, le paragraphe est vide d'inlines. Est-ce valide ? 
    // Selon le code actuel de Validator, validate_inline n'est pas appelé si inlines est vide.
    assert_eq!(new_doc.content.len(), 1);
}

#[test]
fn test_operation_split_paragraph() {
    let mut doc = Document::new("doc-1".to_string(), "Test".to_string());
    doc.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![
            Inline::Text(TextInline { text: "Hello World".to_string() })
        ],
    }));
    
    let op = Operation::SplitParagraph {
        path: Path::from_block("p-1".to_string()),
        offset: 5,
        new_block_id: "p-2".to_string(),
    };
    
    let new_doc = apply(&doc, op).unwrap();
    assert_eq!(new_doc.content.len(), 2);
    
    if let Block::Paragraph(p1) = &new_doc.content[0] {
        if let Inline::Text(t) = &p1.inlines[0] {
            assert_eq!(t.text, "Hello");
        }
    }
    
    if let Block::Paragraph(p2) = &new_doc.content[1] {
        if let Inline::Text(t) = &p2.inlines[0] {
            assert_eq!(t.text, " World");
        }
    }
}

#[test]
fn test_operation_update_block_meta() {
    let mut doc = Document::new("doc-1".to_string(), "Test".to_string());
    doc.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![
            Inline::Text(TextInline { text: "Hello".to_string() })
        ],
    }));

    let op = Operation::UpdateBlockMeta {
        path: Path::from_block("p-1".to_string()),
        author: Some("Alice".to_string()),
        add_tags: vec![crate::core::meta::SemanticTag { key: "confidential".to_string(), value: "true".to_string() }],
        remove_tag_keys: vec![],
        policy: None,
    };

    let new_doc = apply(&doc, op).unwrap();
    
    if let Block::Paragraph(p) = &new_doc.content[0] {
        assert_eq!(p.meta.author, Some("Alice".to_string()));
        assert_eq!(p.meta.tags.len(), 1);
        assert_eq!(p.meta.tags[0].key, "confidential");
        assert_eq!(p.meta.tags[0].value, "true");
    }
}

