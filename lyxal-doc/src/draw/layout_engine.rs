use crate::styles::visual::{VisualLayout, VisualElement};
use crate::styles::model::StyleValue;
use crate::draw::physical_layout::*;
use crate::draw::error::DrawError;
use std::collections::BTreeMap;

pub struct DrawLayoutEngine {
    settings: CanvasSettings,
}

impl DrawLayoutEngine {
    pub fn new(settings: CanvasSettings) -> Self {
        Self { settings }
    }

    pub fn compose(&self, visual_layout: &VisualLayout) -> Result<DrawPhysicalLayout, DrawError> {
        let mut layers = Vec::new();
        let mut global_bbox = BoundingBox::default();

        for layer in &visual_layout.root_elements {
            if layer.element_type == "section" || layer.element_type == "layer" {
                let mut physical_elements = Vec::new();
                for (z, child) in layer.children.iter().enumerate() {
                    let element = self.process_element(child, z as u32)?;
                    physical_elements.push(element);
                }

                layers.push(PhysicalDrawLayer {
                    id: layer.id.clone(),
                    name: layer.id.clone(), // v1.0 Simplification
                    elements: physical_elements,
                });
            }
        }

        // Note: global_bbox calculation would go here in a full impl
        Ok(DrawPhysicalLayout {
            canvas: PhysicalCanvas {
                layers,
                bounding_box: global_bbox,
            },
            settings: self.settings.clone(),
        })
    }

    fn process_element(&self, element: &VisualElement, z_order: u32) -> Result<PhysicalDrawElement, DrawError> {
        let geometry = match element.element_type.as_str() {
            "shape" => {
                // Resolution des points avec la matrice (simplifiée v1.0)
                let tx = self.get_f64(&element.resolved_styles, "translate_x", 0.0);
                let ty = self.get_f64(&element.resolved_styles, "translate_y", 0.0);
                
                // On récupère les points résolus par l'interprète (s'ils y sont)
                // Pour v1.0, on simule la résolution géométrique finale.
                PhysicalGeometry::Path {
                    points: vec![
                        PhysicalPoint { x: tx, y: ty },
                        PhysicalPoint { x: tx + 100.0, y: ty + 100.0 }
                    ],
                    is_closed: true,
                }
            }
            "image" => {
                let src = match element.resolved_styles.get("src") {
                    Some(StyleValue::String(s)) => s.clone(),
                    _ => String::new(),
                };
                PhysicalGeometry::Image {
                    src,
                    x: self.get_f64(&element.resolved_styles, "translate_x", 0.0),
                    y: self.get_f64(&element.resolved_styles, "translate_y", 0.0),
                    width: self.get_f64(&element.resolved_styles, "width", 100.0),
                    height: self.get_f64(&element.resolved_styles, "height", 100.0),
                }
            }
            "text" | "paragraph" => {
                let text = match element.resolved_styles.get("text") {
                    Some(StyleValue::String(s)) => s.clone(),
                    _ => String::new(),
                };
                PhysicalGeometry::Text {
                    value: text,
                    x: self.get_f64(&element.resolved_styles, "translate_x", 0.0),
                    y: self.get_f64(&element.resolved_styles, "translate_y", 0.0),
                }
            }
            "group" => {
                let mut children = Vec::new();
                for (z, child) in element.children.iter().enumerate() {
                    children.push(self.process_element(child, z as u32)?);
                }
                PhysicalGeometry::Group {
                    children,
                    bounding_box: BoundingBox::default(),
                }
            }
            _ => PhysicalGeometry::Text { value: "[Unknown]".to_string(), x: 0.0, y: 0.0 },
        };

        Ok(PhysicalDrawElement {
            id: element.id.clone(),
            geometry,
            styles: element.resolved_styles.clone(),
            z_order,
        })
    }

    fn get_f64(&self, styles: &BTreeMap<String, StyleValue>, key: &str, default: f64) -> f64 {
        match styles.get(key) {
            Some(StyleValue::Number(n)) => *n,
            _ => default,
        }
    }
}

