use crate::core::document::Document;
use crate::core::node::*;
use crate::core::meta::{Metadata, SemanticTag};
use crate::draw::{DrawInterpreter, DrawError};
use crate::draw::layout::{DrawContent, DrawTransform};

#[test]
fn test_draw_compliance_layering_and_transform() {
    let mut doc = Document::new("draw-1".to_string(), "Mon Schéma".to_string());
    
    // Calque 1 (Section)
    let mut layer1 = SectionBlock {
        id: "l1".to_string(),
        meta: Metadata::default(),
        level: 1,
        children: vec![],
    };

    // Forme avec transformation locale
    layer1.children.push(Block::Shape(ShapeBlock {
        id: "rect-1".to_string(),
        meta: Metadata {
            tags: vec![
                SemanticTag { key: "translate_x".to_string(), value: "10".to_string() },
                SemanticTag { key: "rotate".to_string(), value: "45".to_string() },
            ],
            ..Metadata::default()
        },
        shape_type: "rectangle".to_string(),
        properties: std::collections::BTreeMap::from([
            ("points".to_string(), "0,0;100,100".to_string())
        ]),
    }));

    doc.content.push(Block::Section(layer1));

    let mut interpreter = DrawInterpreter::new();
    let layout = interpreter.interpret(&doc).unwrap();

    assert_eq!(layout.canvas.layers.len(), 1);
    let element = &layout.canvas.layers[0].elements[0];
    
    assert_eq!(element.transform.translate_x, 10.0);
    assert_eq!(element.transform.rotate, 45.0);
    
    if let DrawContent::Shape { shape_type, points } = &element.content {
        assert_eq!(shape_type, "rectangle");
        assert_eq!(points.len(), 2);
        assert_eq!(points[0].x, 0.0);
        assert_eq!(points[1].y, 100.0);
    } else {
        panic!("Devrait être une Shape");
    }
}

#[test]
fn test_draw_compliance_group_inheritance() {
    let mut doc = Document::new("draw-2".to_string(), "Groupe Test".to_string());
    
    // Groupe avec translation
    let group = Block::Group(GroupBlock {
        id: "g1".to_string(),
        meta: Metadata {
            tags: vec![SemanticTag { key: "translate_x".to_string(), value: "100".to_string() }],
            ..Metadata::default()
        },
        children: vec![
            Block::Shape(ShapeBlock {
                id: "circle-1".to_string(),
                meta: Metadata {
                    tags: vec![SemanticTag { key: "translate_x".to_string(), value: "50".to_string() }],
                    ..Metadata::default()
                },
                shape_type: "circle".to_string(),
                properties: std::collections::BTreeMap::new(),
            })
        ],
    });

    doc.content.push(group);

    let mut interpreter = DrawInterpreter::new();
    let layout = interpreter.interpret(&doc).unwrap();

    // L'élément dans le groupe devrait avoir une translation cumulée de 150
    let layer = &layout.canvas.layers[0]; // Calque par défaut
    if let DrawContent::Group(children) = &layer.elements[0].content {
        assert_eq!(children[0].transform.translate_x, 150.0);
    } else {
        panic!("Devrait être un Groupe");
    }
}

#[test]
fn test_draw_compliance_stateless_reset() {
    let doc = Document::new("draw-3".to_string(), "Reset Test".to_string());
    let mut interpreter = DrawInterpreter::new();
    
    let _ = interpreter.interpret(&doc).unwrap();
    let layout2 = interpreter.interpret(&doc).unwrap();
    
    assert_eq!(layout2.canvas.layers.len(), 0);
}

