use crate::word::layout_engine::WordLayoutEngine;
use crate::word::physical_layout::PageSettings;
use crate::styles::visual::{VisualLayout, VisualElement};
use crate::styles::model::StyleValue;
use std::collections::BTreeMap;

#[test]
fn test_layout_compliance_pagination() {
    let settings = PageSettings {
        width: 500.0,
        height: 200.0, // Très petite hauteur pour forcer la pagination
        margins: [20.0, 20.0, 20.0, 20.0],
    };
    let engine = WordLayoutEngine::new(settings);

    // Créer un layout visuel avec plusieurs paragraphes
    let mut root_elements = Vec::new();
    for i in 0..10 {
        let mut props = BTreeMap::new();
        props.insert("font_size".to_string(), StyleValue::Number(12.0));
        
        let child = VisualElement {
            id: format!("p-{}-text", i),
            element_type: "text".to_string(),
            resolved_styles: BTreeMap::from([("text".to_string(), StyleValue::String("Un long texte pour tester la pagination.".to_string()))]),
            children: Vec::new(),
        };

        root_elements.push(VisualElement {
            id: format!("p-{}", i),
            element_type: "paragraph".to_string(),
            resolved_styles: props,
            children: vec![child],
        });
    }

    let visual_layout = VisualLayout {
        root_elements,
        metadata: BTreeMap::new(),
    };

    let page_layout = engine.compose(&visual_layout).unwrap();

    // Doit avoir généré plusieurs pages car la hauteur est limitée
    assert!(page_layout.pages.len() > 1);
    assert_eq!(page_layout.pages[0].number, 1);
    assert_eq!(page_layout.pages[1].number, 2);
}

#[test]
fn test_layout_compliance_forced_page_break() {
    let engine = WordLayoutEngine::new(PageSettings::default());

    let mut root_elements = Vec::new();
    root_elements.push(VisualElement {
        id: "p-1".to_string(),
        element_type: "paragraph".to_string(),
        resolved_styles: BTreeMap::new(),
        children: Vec::new(),
    });
    root_elements.push(VisualElement {
        id: "pb-1".to_string(),
        element_type: "page_break".to_string(),
        resolved_styles: BTreeMap::new(),
        children: Vec::new(),
    });
    root_elements.push(VisualElement {
        id: "p-2".to_string(),
        element_type: "paragraph".to_string(),
        resolved_styles: BTreeMap::new(),
        children: Vec::new(),
    });

    let visual_layout = VisualLayout {
        root_elements,
        metadata: BTreeMap::new(),
    };

    let page_layout = engine.compose(&visual_layout).unwrap();

    assert_eq!(page_layout.pages.len(), 2);
}

