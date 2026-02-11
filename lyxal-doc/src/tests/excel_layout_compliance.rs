use crate::excel::layout_engine::ExcelLayoutEngine;
use crate::excel::physical_layout::GridSettings;
use crate::excel::layout::{ExcelLayout, ExcelSheet, ExcelCell, CalculatedValue};
use std::collections::BTreeMap;

#[test]
fn test_excel_layout_compliance_mapping() {
    let settings = GridSettings {
        default_column_width: 100.0,
        default_row_height: 30.0,
        ..GridSettings::default()
    };
    let engine = ExcelLayoutEngine::new(settings);

    let mut grid = BTreeMap::new();
    grid.insert("A1".to_string(), ExcelCell {
        id: "c1".to_string(),
        address: "A1".to_string(),
        value: CalculatedValue::Number(10.0),
        formula: None,
        is_locked: false,
    });
    grid.insert("B2".to_string(), ExcelCell {
        id: "c2".to_string(),
        address: "B2".to_string(),
        value: CalculatedValue::Number(20.0),
        formula: None,
        is_locked: false,
    });

    let visual_layout = ExcelLayout {
        sheets: vec![ExcelSheet {
            name: "Sheet 1".to_string(),
            grid,
        }],
        metadata: crate::excel::layout::ExcelDocumentMetadata::default(),
    };

    let physical_layout = engine.compose(&visual_layout).unwrap();

    let sheet = &physical_layout.sheets[0];
    let cell_a1 = sheet.grid.get("A1").unwrap();
    let cell_b2 = sheet.grid.get("B2").unwrap();

    // A1 est à (0,0)
    assert_eq!(cell_a1.x, 0.0);
    assert_eq!(cell_a1.y, 0.0);

    // B2 est après une colonne de 100pt et une ligne de 30pt
    assert_eq!(cell_b2.x, 100.0);
    assert_eq!(cell_b2.y, 30.0);
}

#[test]
fn test_excel_layout_compliance_stateless_reset() {
    let engine = ExcelLayoutEngine::new(GridSettings::default());
    let visual_layout = ExcelLayout {
        sheets: vec![],
        metadata: crate::excel::layout::ExcelDocumentMetadata::default(),
    };

    let _ = engine.compose(&visual_layout).unwrap();
    let physical_layout2 = engine.compose(&visual_layout).unwrap();

    assert_eq!(physical_layout2.sheets.len(), 0);
}

