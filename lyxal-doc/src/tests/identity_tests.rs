use crate::core::Document;
use crate::core::node::{Block, ParagraphBlock, Inline, TextInline};
use crate::core::Metadata;
use crate::ops::{Operation, Path};
use crate::history::HistoryLog;
use crate::identity::{document_hash, DocumentDigest};

#[test]
fn test_document_hash_determinism() {
    let mut doc1 = Document::new("doc-1".to_string(), "Title".to_string());
    doc1.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![Inline::Text(TextInline { text: "Hello".to_string() })],
    }));

    let mut doc2 = Document::new("doc-1".to_string(), "Title".to_string());
    doc2.content.push(Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![Inline::Text(TextInline { text: "Hello".to_string() })],
    }));

    let h1 = document_hash(&doc1).unwrap();
    let h2 = document_hash(&doc2).unwrap();

    assert_eq!(h1, h2);
}

#[test]
fn test_history_hash_integrity() {
    let base_doc = Document::new("doc-1".to_string(), "Base".to_string());
    let mut history = HistoryLog::new();

    let op1 = Operation::InsertBlock {
        parent_path: Path(vec![]),
        index: 0,
        block: Block::Paragraph(ParagraphBlock {
            id: "p-1".to_string(),
            meta: Metadata::default(),
            inlines: vec![Inline::Text(TextInline { text: "Op1".to_string() })],
        }),
    };
    let doc1 = history.commit(&base_doc, op1).unwrap();

    let digest1 = DocumentDigest::from_state(&base_doc, &doc1, &history);

    // Undo puis Redo doit redonner le même digest
    history.undo(&base_doc).unwrap();
    let doc_undo = history.replay(&base_doc).unwrap();
    let digest_undo = DocumentDigest::from_state(&base_doc, &doc_undo, &history);
    
    assert_ne!(digest1.history_hash, digest_undo.history_hash);
    assert_eq!(digest_undo.version, 0);

    history.redo(&base_doc).unwrap();
    let doc_redo = history.replay(&base_doc).unwrap();
    let digest_redo = DocumentDigest::from_state(&base_doc, &doc_redo, &history);

    assert_eq!(digest1, digest_redo);
}

#[test]
fn test_different_history_different_hash() {
    let base_doc = Document::new("doc-1".to_string(), "Base".to_string());
    
    // Scénario 1 : Ajout A puis B
    let mut history1 = HistoryLog::new();
    let op_a = Operation::InsertBlock {
        parent_path: Path(vec![]), index: 0,
        block: Block::Paragraph(ParagraphBlock { id: "a".to_string(), meta: Metadata::default(), inlines: vec![Inline::Text(TextInline { text: "A".to_string() })] }),
    };
    let doc_a = history1.commit(&base_doc, op_a.clone()).unwrap();
    let op_b = Operation::InsertBlock {
        parent_path: Path(vec![]), index: 1,
        block: Block::Paragraph(ParagraphBlock { id: "b".to_string(), meta: Metadata::default(), inlines: vec![Inline::Text(TextInline { text: "B".to_string() })] }),
    };
    let doc1_final = history1.commit(&doc_a, op_b.clone()).unwrap();
    let digest1 = DocumentDigest::from_state(&base_doc, &doc1_final, &history1);

    // Scénario 2 : Ajout B puis A
    // Pour que B soit valide en premier, son index doit être 0
    let mut history2 = HistoryLog::new();
    let op_b_first = Operation::InsertBlock {
        parent_path: Path(vec![]), index: 0,
        block: Block::Paragraph(ParagraphBlock { id: "b".to_string(), meta: Metadata::default(), inlines: vec![Inline::Text(TextInline { text: "B".to_string() })] }),
    };
    let op_a_second = Operation::InsertBlock {
        parent_path: Path(vec![]), index: 1,
        block: Block::Paragraph(ParagraphBlock { id: "a".to_string(), meta: Metadata::default(), inlines: vec![Inline::Text(TextInline { text: "A".to_string() })] }),
    };
    let doc_b_init = history2.commit(&base_doc, op_b_first).unwrap();
    let doc2_final = history2.commit(&doc_b_init, op_a_second).unwrap();
    let digest2 = DocumentDigest::from_state(&base_doc, &doc2_final, &history2);

    assert_ne!(digest1.history_hash, digest2.history_hash);
}

