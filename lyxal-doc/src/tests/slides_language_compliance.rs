use crate::core::document::Document;
use crate::core::node::*;
use crate::core::meta::{Metadata, SemanticTag};
use crate::slides::{SlidesInterpreter, SlidesError};
use crate::slides::layout::{SlideContent};

#[test]
fn test_slides_compliance_spatial_projection() {
    let mut doc = Document::new("slide-1".to_string(), "Ma Présentation".to_string());
    
    // Slide 1
    doc.content.push(Block::Section(SectionBlock {
        id: "s1".to_string(),
        meta: Metadata::default(),
        level: 1,
        children: vec![
            Block::Shape(ShapeBlock {
                id: "rect-1".to_string(),
                meta: Metadata {
                    tags: vec![
                        SemanticTag { key: "pos_x".to_string(), value: "100".to_string() },
                        SemanticTag { key: "pos_y".to_string(), value: "200".to_string() },
                    ],
                    ..Metadata::default()
                },
                shape_type: "rectangle".to_string(),
                properties: std::collections::BTreeMap::new(),
            })
        ],
    }));

    let mut interpreter = SlidesInterpreter::new();
    let layout = interpreter.interpret(&doc).unwrap();

    assert_eq!(layout.slides.len(), 1);
    let element = &layout.slides[0].elements[0];
    assert_eq!(element.spatial.x, 100.0);
    assert_eq!(element.spatial.y, 200.0);
    assert!(matches!(element.content, SlideContent::Shape { .. }));
}

#[test]
fn test_slides_compliance_temporal_order() {
    let mut doc = Document::new("slide-2".to_string(), "Ordre Test".to_string());
    
    doc.content.push(Block::Section(SectionBlock {
        id: "s1".to_string(),
        meta: Metadata::default(),
        level: 1,
        children: vec![
            Block::Paragraph(ParagraphBlock {
                id: "p1".to_string(),
                meta: Metadata {
                    tags: vec![SemanticTag { key: "appearance".to_string(), value: "on_click".to_string() }],
                    ..Metadata::default()
                },
                inlines: vec![Inline::Text(TextInline { text: "Premier".to_string() })],
            }),
            Block::Paragraph(ParagraphBlock {
                id: "p2".to_string(),
                meta: Metadata::default(),
                inlines: vec![Inline::Text(TextInline { text: "Deuxième".to_string() })],
            }),
        ],
    }));

    let mut interpreter = SlidesInterpreter::new();
    let layout = interpreter.interpret(&doc).unwrap();

    let elements = &layout.slides[0].elements;
    assert_eq!(elements[0].appearance_intent, Some("on_click".to_string()));
    assert_eq!(elements[1].appearance_intent, None);
}

#[test]
fn test_slides_compliance_stateless_reset() {
    let doc = Document::new("slide-3".to_string(), "Reset Test".to_string());
    let mut interpreter = SlidesInterpreter::new();
    
    let _ = interpreter.interpret(&doc).unwrap();
    let layout2 = interpreter.interpret(&doc).unwrap();
    
    assert_eq!(layout2.slides.len(), 0);
}

