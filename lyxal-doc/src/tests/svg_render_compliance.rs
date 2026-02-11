use crate::draw::physical_layout::{DrawPhysicalLayout, PhysicalDrawLayer, PhysicalDrawElement, PhysicalGeometry, PhysicalPoint, BoundingBox, CanvasSettings};
use crate::render::svg::renderer::SvgRenderer;
use crate::styles::model::StyleValue;
use std::collections::BTreeMap;

#[test]
fn test_svg_render_compliance_basic_shape() {
    let layout = DrawPhysicalLayout {
        canvas: crate::draw::physical_layout::PhysicalCanvas {
            layers: vec![
                PhysicalDrawLayer {
                    id: "layer-1".to_string(),
                    name: "Main Layer".to_string(),
                    elements: vec![
                        PhysicalDrawElement {
                            id: "rect-1".to_string(),
                            geometry: PhysicalGeometry::Path {
                                points: vec![
                                    PhysicalPoint { x: 0.0, y: 0.0 },
                                    PhysicalPoint { x: 100.0, y: 0.0 },
                                    PhysicalPoint { x: 100.0, y: 100.0 },
                                    PhysicalPoint { x: 0.0, y: 100.0 },
                                ],
                                is_closed: true,
                            },
                            styles: BTreeMap::from([
                                ("bg_color".to_string(), StyleValue::Color("#FF0000".to_string())),
                                ("border_color".to_string(), StyleValue::Color("#000000".to_string())),
                                ("border_width".to_string(), StyleValue::Number(2.0)),
                            ]),
                            z_order: 1,
                        }
                    ],
                }
            ],
            bounding_box: BoundingBox {
                min_x: 0.0,
                min_y: 0.0,
                max_x: 800.0,
                max_y: 600.0,
            },
        },
        settings: CanvasSettings::default(),
    };

    let renderer = SvgRenderer::new();
    let svg = renderer.render_draw(&layout).expect("SVG render should succeed");

    // Assertions sur le contenu SVG (Utilisation de r## pour éviter le conflit avec # dans le contenu)
    assert!(svg.contains(r##"<svg viewBox="0 0 800 600""##));
    assert!(svg.contains(r##"id="layer-1""##));
    assert!(svg.contains(r##"id="rect-1""##));
    assert!(svg.contains(r##"fill="#FF0000""##));
    assert!(svg.contains(r##"stroke="#000000""##));
    assert!(svg.contains(r##"stroke-width="2""##));
    assert!(svg.contains("M 0 0 L 100 0 L 100 100 L 0 100 Z"));
}

#[test]
fn test_svg_render_compliance_group_hierarchy() {
    let layout = DrawPhysicalLayout {
        canvas: crate::draw::physical_layout::PhysicalCanvas {
            layers: vec![
                PhysicalDrawLayer {
                    id: "layer-1".to_string(),
                    name: "Layer 1".to_string(),
                    elements: vec![
                        PhysicalDrawElement {
                            id: "group-1".to_string(),
                            geometry: PhysicalGeometry::Group {
                                children: vec![
                                    PhysicalDrawElement {
                                        id: "text-1".to_string(),
                                        geometry: PhysicalGeometry::Text {
                                            value: "Hello Lyxal".to_string(),
                                            x: 10.0,
                                            y: 20.0,
                                        },
                                        styles: BTreeMap::new(),
                                        z_order: 1,
                                    }
                                ],
                                bounding_box: BoundingBox::default(),
                            },
                            styles: BTreeMap::new(),
                            z_order: 1,
                        }
                    ],
                }
            ],
            bounding_box: BoundingBox::default(),
        },
        settings: CanvasSettings::default(),
    };

    let renderer = SvgRenderer::new();
    let svg = renderer.render_draw(&layout).expect("SVG render should succeed");

    // Vérifier la hiérarchie des groupes <g>
    assert!(svg.contains(r##"<g id="group-1""##));
    assert!(svg.contains(r##"<text id="text-1""##));
    assert!(svg.contains(">Hello Lyxal</text>"));
}
