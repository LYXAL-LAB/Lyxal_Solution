use crate::styles::visual::{VisualLayout, VisualElement};
use crate::styles::model::StyleValue;
use crate::slides::physical_layout::*;
use crate::slides::error::SlidesError;
use std::collections::BTreeMap;

pub struct SlidesLayoutEngine {
    settings: ViewportSettings,
}

impl SlidesLayoutEngine {
    pub fn new(settings: ViewportSettings) -> Self {
        Self { settings }
    }

    pub fn compose(&self, visual_layout: &VisualLayout) -> Result<SlidesPhysicalLayout, SlidesError> {
        let mut slides = Vec::new();

        // Dans Slides, chaque élément racine du VisualLayout qui est une "section" 
        // a été interprété comme une slide par l'Interprète Slides.
        for (i, element) in visual_layout.root_elements.iter().enumerate() {
            let mut steps = Vec::new();
            
            // Step 0: Tous les éléments visibles au chargement
            let mut initial_elements = Vec::new();
            for child in &element.children {
                self.process_element(child, &mut initial_elements, 0.0, 0.0, 0)?;
            }

            steps.push(SlideStep {
                index: 0,
                elements: initial_elements,
            });

            // En v1.0, on pourrait générer d'autres steps si on gérait les intentions d'apparition.
            // Pour l'instant on reste sur un step unique (état final).

            slides.push(PhysicalSlide {
                id: element.id.clone(),
                number: (i + 1) as u32,
                steps,
            });
        }

        Ok(SlidesPhysicalLayout {
            slides,
            settings: self.settings.clone(),
        })
    }

    fn process_element(
        &self,
        element: &VisualElement,
        elements: &mut Vec<PhysicalSlideElement>,
        parent_x: f64,
        parent_y: f64,
        parent_z: i32,
    ) -> Result<(), SlidesError> {
        // Résolution spatiale (X, Y, Z)
        let x = match element.resolved_styles.get("translate_x") {
            Some(StyleValue::Number(n)) => *n,
            _ => 0.0,
        };
        let y = match element.resolved_styles.get("translate_y") {
            Some(StyleValue::Number(n)) => *n,
            _ => 0.0,
        };
        let z = match element.resolved_styles.get("pos_z") {
            Some(StyleValue::Number(n)) => *n as i32,
            _ => 0,
        };
        let width = match element.resolved_styles.get("width") {
            Some(StyleValue::Number(n)) => *n,
            _ => 100.0, // Valeur par défaut
        };
        let height = match element.resolved_styles.get("height") {
            Some(StyleValue::Number(n)) => *n,
            _ => 50.0,
        };

        let abs_x = parent_x + x;
        let abs_y = parent_y + y;
        let abs_z = parent_z + z;

        let content = match element.element_type.as_str() {
            "text" | "paragraph" => {
                let text = match element.resolved_styles.get("text") {
                    Some(StyleValue::String(s)) => s.clone(),
                    _ => String::new(),
                };
                PhysicalSlideContent::Text(text)
            }
            "image" => {
                let src = match element.resolved_styles.get("src") {
                    Some(StyleValue::String(s)) => s.clone(),
                    _ => String::new(),
                };
                PhysicalSlideContent::Image { src }
            }
            "shape" => {
                let shape_type = match element.resolved_styles.get("shape_type") {
                    Some(StyleValue::String(s)) => s.clone(),
                    _ => "rectangle".to_string(),
                };
                PhysicalSlideContent::Shape { shape_type }
            }
            "group" => {
                let mut children = Vec::new();
                for child in &element.children {
                    self.process_element(child, &mut children, abs_x, abs_y, abs_z)?;
                }
                PhysicalSlideContent::Group(children)
            }
            _ => return Ok(()), // Ignorer les éléments non supportés
        };

        elements.push(PhysicalSlideElement {
            id: element.id.clone(),
            x: abs_x,
            y: abs_y,
            z: abs_z,
            width,
            height,
            content,
            styles: element.resolved_styles.clone(),
        });

        Ok(())
    }
}

