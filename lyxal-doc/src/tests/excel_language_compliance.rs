use crate::core::document::Document;
use crate::core::node::*;
use crate::core::meta::Metadata;
use crate::excel::{ExcelInterpreter, ExcelError};
use crate::excel::layout::CalculatedValue;

#[test]
fn test_excel_compliance_basic_grid() {
    let mut doc = Document::new("xls-1".to_string(), "Calcul Budget".to_string());
    
    let table = Block::Table(TableBlock {
        id: "tbl-1".to_string(),
        meta: Metadata::default(),
        rows: vec![
            TableRow {
                id: "row-1".to_string(),
                meta: Metadata::default(),
                cells: vec![
                    TableCell {
                        id: "cell-a1".to_string(),
                        meta: Metadata::default(),
                        content: vec![Block::Paragraph(ParagraphBlock {
                            id: "p-a1".to_string(),
                            meta: Metadata::default(),
                            inlines: vec![Inline::Value(ValueInline {
                                value_type: ValueType::Number,
                                raw_value: "100".to_string(),
                                formatted_value: None,
                            })],
                        })],
                        rowspan: 1, colspan: 1, header: false,
                    },
                    TableCell {
                        id: "cell-b1".to_string(),
                        meta: Metadata::default(),
                        content: vec![Block::Paragraph(ParagraphBlock {
                            id: "p-b1".to_string(),
                            meta: Metadata::default(),
                            inlines: vec![Inline::Value(ValueInline {
                                value_type: ValueType::Number,
                                raw_value: "200".to_string(),
                                formatted_value: None,
                            })],
                        })],
                        rowspan: 1, colspan: 1, header: false,
                    },
                ],
            },
            TableRow {
                id: "row-2".to_string(),
                meta: Metadata::default(),
                cells: vec![
                    TableCell {
                        id: "cell-a2".to_string(),
                        meta: Metadata::default(),
                        content: vec![Block::Paragraph(ParagraphBlock {
                            id: "p-a2".to_string(),
                            meta: Metadata::default(),
                            inlines: vec![Inline::Expression(ExpressionInline {
                                formula: "A1+B1".to_string(),
                            })],
                        })],
                        rowspan: 1, colspan: 1, header: false,
                    },
                    TableCell {
                        id: "cell-b2".to_string(),
                        meta: Metadata::default(),
                        content: vec![],
                        rowspan: 1, colspan: 1, header: false,
                    },
                ],
            },
        ],
    });

    doc.content.push(table);

    let mut interpreter = ExcelInterpreter::new();
    let layout = interpreter.interpret(&doc).unwrap();

    assert_eq!(layout.sheets.len(), 1);
    let grid = &layout.sheets[0].grid;

    assert_eq!(grid.get("A1").unwrap().value, CalculatedValue::Number(100.0));
    assert_eq!(grid.get("B1").unwrap().value, CalculatedValue::Number(200.0));
    assert_eq!(grid.get("A2").unwrap().formula, Some("A1+B1".to_string()));
}

#[test]
fn test_excel_compliance_cycle_detection() {
    let mut doc = Document::new("xls-cycle".to_string(), "Cycle Test".to_string());
    
    let table = Block::Table(TableBlock {
        id: "tbl-1".to_string(),
        meta: Metadata::default(),
        rows: vec![
            TableRow {
                id: "row-1".to_string(),
                meta: Metadata::default(),
                cells: vec![
                    TableCell {
                        id: "cell-a1".to_string(),
                        meta: Metadata::default(),
                        content: vec![Block::Paragraph(ParagraphBlock {
                            id: "p-a1".to_string(),
                            meta: Metadata::default(),
                            inlines: vec![Inline::Expression(ExpressionInline {
                                formula: "A2".to_string(),
                            })],
                        })],
                        rowspan: 1, colspan: 1, header: false,
                    },
                ],
            },
            TableRow {
                id: "row-2".to_string(),
                meta: Metadata::default(),
                cells: vec![
                    TableCell {
                        id: "cell-a2".to_string(),
                        meta: Metadata::default(),
                        content: vec![Block::Paragraph(ParagraphBlock {
                            id: "p-a2".to_string(),
                            meta: Metadata::default(),
                            inlines: vec![Inline::Expression(ExpressionInline {
                                formula: "A1".to_string(),
                            })],
                        })],
                        rowspan: 1, colspan: 1, header: false,
                    },
                ],
            },
        ],
    });

    doc.content.push(table);

    let mut interpreter = ExcelInterpreter::new();
    let result = interpreter.interpret(&doc);

    assert!(result.is_err());
    assert_eq!(result.unwrap_err(), ExcelError::CycleDetected);
}

#[test]
fn test_excel_compliance_stateless_reset() {
    let doc = Document::new("xls-1".to_string(), "Test".to_string());
    let mut interpreter = ExcelInterpreter::new();
    
    let _ = interpreter.interpret(&doc).unwrap();
    let layout2 = interpreter.interpret(&doc).unwrap();
    
    assert_eq!(layout2.sheets.len(), 0);
}
