use crate::core::document::Document;
use crate::core::node::*;
use crate::core::meta::{Metadata, NodePolicy, Scope};
use crate::word::WordInterpreter;
use crate::word::layout::WordElement;

#[test]
fn test_word_compliance_legal_document() {
    let mut doc = Document::new("law-1".to_string(), "Contrat de Confidentialité".to_string());
    
    let policy = Some(NodePolicy {
        read: Scope::Public,
        write: Scope::Restricted(vec!["admin".to_string()]),
        comment: Scope::Inherit,
    });

    doc.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-lock".to_string(),
        meta: Metadata { policy, ..Metadata::default() },
        inlines: vec![Inline::Text(TextInline { text: "Clause non modifiable.".to_string() })],
    }));

    doc.content.push(Block::Revision(RevisionBlock {
        id: "rev-1".to_string(),
        meta: Metadata::default(),
        change_type: RevisionType::Insertion,
        content: vec![Block::Paragraph(ParagraphBlock {
            id: "p-rev".to_string(),
            meta: Metadata::default(),
            inlines: vec![Inline::Text(TextInline { text: "Ajout légal.".to_string() })],
        })],
    }));

    doc.content.push(Block::SignatureSlot(SignatureSlotBlock {
        id: "sig-1".to_string(),
        meta: Metadata::default(),
        role: "Directeur Général".to_string(),
    }));

    let mut interpreter = WordInterpreter::new();
    let layout = interpreter.interpret(&doc).unwrap();
    let body = &layout.pages[0].body;

    if let WordElement::Paragraph { is_locked, .. } = &body[0] {
        assert!(is_locked, "Le paragraphe devrait être verrouillé selon la policy");
    }

    assert!(matches!(&body[1], WordElement::Revision { change_type, .. } if change_type == "insertion"));
    assert!(matches!(&body[2], WordElement::SignatureSlot { role, .. } if role == "Directeur Général"));
}

#[test]
fn test_word_compliance_dynamic_fields() {
    let mut doc = Document::new("dyn-1".to_string(), "Rapport".to_string());
    
    doc.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![
            Inline::Text(TextInline { text: "Page ".to_string() }),
            Inline::Field(FieldInline { key: "page_number".to_string(), fallback_text: "0".to_string() }),
            Inline::Text(TextInline { text: " sur ".to_string() }),
            Inline::Expression(ExpressionInline { formula: "TOTAL_PAGES".to_string() }),
        ],
    }));

    let mut interpreter = WordInterpreter::new();
    let layout = interpreter.interpret(&doc).unwrap();
    let runs = match &layout.pages[0].body[0] {
        WordElement::Paragraph { text_runs, .. } => text_runs,
        _ => panic!("Pas un paragraphe"),
    };

    assert_eq!(runs[1].text, "1");
    assert_eq!(runs[3].text, "{=TOTAL_PAGES}");
}

#[test]
fn test_word_compliance_intent_and_toc() {
    let mut doc = Document::new("toc-1".to_string(), "Manuel".to_string());
    
    doc.content.push(Block::Intent(IntentBlock {
        id: "intent-1".to_string(),
        meta: Metadata::default(),
        intent: NodeIntent::TableOfContents,
        content: vec![Block::Paragraph(ParagraphBlock {
            id: "p-placeholder".to_string(),
            meta: Metadata::default(),
            inlines: vec![Inline::Text(TextInline { text: "TOC Placeholder".to_string() })],
        })],
    }));

    doc.content.push(Block::Section(SectionBlock {
        id: "sec-1".to_string(),
        meta: Metadata::default(),
        level: 1,
        children: vec![],
    }));

    let mut interpreter = WordInterpreter::new();
    let layout = interpreter.interpret(&doc).unwrap();

    assert!(layout.metadata.table_of_contents_present);
    assert!(matches!(&layout.pages[0].body[0], WordElement::IntentPlaceholder { intent_type, .. } if intent_type == "TableOfContents"));
}

#[test]
fn test_word_compliance_cross_ref_missing() {
    let mut doc = Document::new("ref-1".to_string(), "Test Ref".to_string());
    
    doc.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![
            Inline::Text(TextInline { text: "Voir ".to_string() }),
            Inline::CrossRef(CrossRefInline { target_id: "missing".to_string(), display_intent: "title".to_string() }),
        ],
    }));

    let mut interpreter = WordInterpreter::new();
    let layout = interpreter.interpret(&doc).unwrap();
    let runs = match &layout.pages[0].body[0] {
        WordElement::Paragraph { text_runs, .. } => text_runs,
        _ => panic!("Pas un paragraphe"),
    };

    assert_eq!(runs[1].text, "?");
}
