use crate::slides::layout_engine::SlidesLayoutEngine;
use crate::slides::physical_layout::ViewportSettings;
use crate::styles::visual::{VisualLayout, VisualElement};
use crate::styles::model::StyleValue;
use crate::slides::physical_layout::PhysicalSlideContent;
use std::collections::BTreeMap;

#[test]
fn test_slides_layout_compliance_spatial_resolution() {
    let settings = ViewportSettings::default(); // 720x405
    let engine = SlidesLayoutEngine::new(settings);

    // Créer un groupe avec une translation, contenant un rectangle
    let child = VisualElement {
        id: "rect-1".to_string(),
        element_type: "shape".to_string(),
        resolved_styles: BTreeMap::from([
            ("shape_type".to_string(), StyleValue::String("rectangle".to_string())),
            ("translate_x".to_string(), StyleValue::Number(50.0)),
            ("translate_y".to_string(), StyleValue::Number(50.0)),
            ("width".to_string(), StyleValue::Number(100.0)),
            ("height".to_string(), StyleValue::Number(100.0)),
        ]),
        children: Vec::new(),
    };

    let group = VisualElement {
        id: "group-1".to_string(),
        element_type: "group".to_string(),
        resolved_styles: BTreeMap::from([
            ("translate_x".to_string(), StyleValue::Number(100.0)),
            ("translate_y".to_string(), StyleValue::Number(100.0)),
        ]),
        children: vec![child],
    };

    let slide_section = VisualElement {
        id: "slide-1".to_string(),
        element_type: "section".to_string(),
        resolved_styles: BTreeMap::new(),
        children: vec![group],
    };

    let visual_layout = VisualLayout {
        root_elements: vec![slide_section],
        metadata: BTreeMap::new(),
    };

    let physical_layout = engine.compose(&visual_layout).unwrap();

    assert_eq!(physical_layout.slides.len(), 1);
    let step0 = &physical_layout.slides[0].steps[0];
    
    // Le groupe doit être à (100, 100)
    let physical_group = &step0.elements[0];
    assert_eq!(physical_group.x, 100.0);
    assert_eq!(physical_group.y, 100.0);

    // L'enfant dans le groupe doit être à (150, 150) en coordonnées absolues
    if let PhysicalSlideContent::Group(children) = &physical_group.content {
        assert_eq!(children[0].x, 150.0);
        assert_eq!(children[0].y, 150.0);
        assert_eq!(children[0].width, 100.0);
    } else {
        panic!("Devrait être un groupe");
    }
}

#[test]
fn test_slides_layout_compliance_z_order() {
    let engine = SlidesLayoutEngine::new(ViewportSettings::default());

    let el1 = VisualElement {
        id: "el-1".to_string(),
        element_type: "shape".to_string(),
        resolved_styles: BTreeMap::from([("pos_z".to_string(), StyleValue::Number(10.0))]),
        children: Vec::new(),
    };

    let slide_section = VisualElement {
        id: "slide-1".to_string(),
        element_type: "section".to_string(),
        resolved_styles: BTreeMap::new(),
        children: vec![el1],
    };

    let visual_layout = VisualLayout {
        root_elements: vec![slide_section],
        metadata: BTreeMap::new(),
    };

    let physical_layout = engine.compose(&visual_layout).unwrap();
    let physical_el = &physical_layout.slides[0].steps[0].elements[0];
    
    assert_eq!(physical_el.z, 10);
}

