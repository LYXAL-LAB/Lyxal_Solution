use crate::core::Document;
use crate::core::node::{Block, ParagraphBlock, Inline, TextInline};
use crate::core::Metadata;
use crate::ops::{Operation, Path};
use crate::history::{HistoryLog, HistoryError};

#[test]
fn test_history_commit_and_replay() {
    let base_doc = Document::new("doc-1".to_string(), "Base".to_string());
    let mut history = HistoryLog::new();

    // 1. Première opération : ajout d'un paragraphe
    let p1 = Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![Inline::Text(TextInline { text: "Hello".to_string() })],
    });
    let op1 = Operation::InsertBlock {
        parent_path: Path(vec![]),
        index: 0,
        block: p1,
    };
    let doc1 = history.commit(&base_doc, op1).unwrap();

    // 2. Deuxième opération : ajout de texte
    let op2 = Operation::InsertText {
        path: Path::from_block("p-1".to_string()),
        offset: 5,
        value: " World".to_string(),
    };
    let doc2 = history.commit(&doc1, op2).unwrap();

    assert_eq!(history.len(), 2);
    assert_eq!(history.cursor(), 2);

    // Vérifier l'état final
    if let Block::Paragraph(p) = &doc2.content[0] {
        if let Inline::Text(t) = &p.inlines[0] {
            assert_eq!(t.text, "Hello World");
        }
    }
}

#[test]
fn test_history_undo_redo() {
    let base_doc = Document::new("doc-1".to_string(), "Base".to_string());
    let mut history = HistoryLog::new();

    let p1 = Block::Paragraph(ParagraphBlock {
        id: "p-1".to_string(),
        meta: Metadata::default(),
        inlines: vec![Inline::Text(TextInline { text: "Hello".to_string() })],
    });
    let op1 = Operation::InsertBlock {
        parent_path: Path(vec![]),
        index: 0,
        block: p1,
    };
    let doc1 = history.commit(&base_doc, op1).unwrap();

    // Undo
    let doc_after_undo = history.undo(&base_doc).unwrap();
    assert_eq!(doc_after_undo.content.len(), 0);
    assert_eq!(history.cursor(), 0);

    // Redo
    let doc_after_redo = history.redo(&base_doc).unwrap();
    assert_eq!(doc_after_redo.content.len(), 1);
    assert_eq!(history.cursor(), 1);
    assert_eq!(doc_after_redo, doc1);
}

#[test]
fn test_history_truncation_after_undo() {
    let base_doc = Document::new("doc-1".to_string(), "Base".to_string());
    let mut history = HistoryLog::new();

    // Op 1
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

    // Op 2
    let op2 = Operation::InsertBlock {
        parent_path: Path(vec![]),
        index: 1,
        block: Block::Paragraph(ParagraphBlock {
            id: "p-2".to_string(),
            meta: Metadata::default(),
            inlines: vec![Inline::Text(TextInline { text: "Op2".to_string() })],
        }),
    };
    let _doc2 = history.commit(&doc1, op2).unwrap();

    // Undo Op 2
    history.undo(&base_doc).unwrap();
    assert_eq!(history.len(), 2);
    assert_eq!(history.cursor(), 1);

    // Nouvelle Op 3 -> doit tronquer Op 2
    let op3 = Operation::InsertBlock {
        parent_path: Path(vec![]),
        index: 1,
        block: Block::Paragraph(ParagraphBlock {
            id: "p-3".to_string(),
            meta: Metadata::default(),
            inlines: vec![Inline::Text(TextInline { text: "Op3".to_string() })],
        }),
    };
    let _doc3 = history.commit(&doc1, op3).unwrap();

    assert_eq!(history.len(), 2); // Op 1 et Op 3
    assert_eq!(history.cursor(), 2);
}

#[test]
fn test_history_invalid_op_not_committed() {
    let base_doc = Document::new("doc-1".to_string(), "Base".to_string());
    let mut history = HistoryLog::new();

    // Opération invalide (offset out of bounds)
    let op = Operation::InsertText {
        path: Path::from_block("non-existent".to_string()),
        offset: 0,
        value: "Fail".to_string(),
    };

    let result = history.commit(&base_doc, op);
    assert!(result.is_err());
    assert_eq!(history.len(), 0);
}

