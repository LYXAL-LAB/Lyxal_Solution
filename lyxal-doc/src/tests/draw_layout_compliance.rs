use crate::draw::layout_engine::DrawLayoutEngine;
use crate::draw::physical_layout::{CanvasSettings, PhysicalGeometry};
use crate::styles::visual::{VisualLayout, VisualElement};
use crate::styles::model::StyleValue;
use std::collections::BTreeMap;

#[test]
fn test_draw_layout_compliance_geometry_resolution() {
    let settings = CanvasSettings::default();
    let engine = DrawLayoutEngine::new(settings);

    // Un calque contenant un rectangle avec translation
    let rect = VisualElement {
        id: "rect-1".to_string(),
        element_type: "shape".to_string(),
        resolved_styles: BTreeMap::from([
            ("translate_x".to_string(), StyleValue::Number(20.0)),
            ("translate_y".to_string(), StyleValue::Number(30.0)),
        ]),
        children: Vec::new(),
    };

    let layer = VisualElement {
        id: "layer-1".to_string(),
        element_type: "section".to_string(),
        resolved_styles: BTreeMap::new(),
        children: vec![rect],
    };

    let visual_layout = VisualLayout {
        root_elements: vec![layer],
        metadata: BTreeMap::new(),
    };

    let physical_layout = engine.compose(&visual_layout).unwrap();

    assert_eq!(physical_layout.canvas.layers.len(), 1);
    let physical_rect = &physical_layout.canvas.layers[0].elements[0];
    
    if let PhysicalGeometry::Path { points, .. } = &physical_rect.geometry {
        // Le point initial (0,0) avec translation (20,30) devient (20,30)
        assert_eq!(points[0].x, 20.0);
        assert_eq!(points[0].y, 30.0);
    } else {
        panic!("Devrait être un Path");
    }
}

#[test]
fn test_draw_layout_compliance_z_order() {
    let engine = DrawLayoutEngine::new(CanvasSettings::default());

    let el1 = VisualElement {
        id: "el-1".to_string(),
        element_type: "shape".to_string(),
        resolved_styles: BTreeMap::new(),
        children: Vec::new(),
    };
    let el2 = VisualElement {
        id: "el-2".to_string(),
        element_type: "shape".to_string(),
        resolved_styles: BTreeMap::new(),
        children: Vec::new(),
    };

    let layer = VisualElement {
        id: "layer-1".to_string(),
        element_type: "section".to_string(),
        resolved_styles: BTreeMap::new(),
        children: vec![el1, el2],
    };

    let visual_layout = VisualLayout {
        root_elements: vec![layer],
        metadata: BTreeMap::new(),
    };

    let physical_layout = engine.compose(&visual_layout).unwrap();
    let elements = &physical_layout.canvas.layers[0].elements;
    
    assert_eq!(elements[0].z_order, 0);
    assert_eq!(elements[1].z_order, 1);
}

