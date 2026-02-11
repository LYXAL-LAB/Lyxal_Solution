use crate::draw::physical_layout::{DrawPhysicalLayout, PhysicalDrawElement, PhysicalGeometry, BoundingBox};
use crate::styles::model::StyleValue;
use crate::render::svg::error::SvgRenderError;
use std::collections::BTreeMap;

pub struct SvgRenderer;

impl SvgRenderer {
    pub fn new() -> Self {
        Self
    }

    pub fn render_draw(&self, layout: &DrawPhysicalLayout) -> Result<String, SvgRenderError> {
        let bbox = &layout.canvas.bounding_box;
        
        // v1.0 Simplification : On utilise le contenu réel pour le viewBox si bbox est vide
        let view_box = format!("{} {} {} {}", 
            bbox.min_x, bbox.min_y, 
            (bbox.max_x - bbox.min_x).max(800.0), 
            (bbox.max_y - bbox.min_y).max(600.0)
        );

        let mut svg = format!(
            r#"<svg viewBox="{}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">"#,
            view_box
        );

        for layer in &layout.canvas.layers {
            svg.push_str(&format!(r#"<g id="{}" name="{}">"#, layer.id, layer.name));
            
            // Les éléments sont déjà triés par Z-order par le Layout Engine
            for element in &layer.elements {
                svg.push_str(&self.render_element(element)?);
            }
            
            svg.push_str("</g>");
        }

        svg.push_str("</svg>");
        Ok(svg)
    }

    fn render_element(&self, element: &PhysicalDrawElement) -> Result<String, SvgRenderError> {
        let style_attr = self.resolve_style_attributes(&element.styles);
        
        let content = match &element.geometry {
            PhysicalGeometry::Path { points, is_closed } => {
                if points.is_empty() { return Ok(String::new()); }
                
                let mut d = format!("M {} {}", points[0].x, points[0].y);
                for i in 1..points.len() {
                    d.push_str(&format!(" L {} {}", points[i].x, points[i].y));
                }
                if *is_closed {
                    d.push_str(" Z");
                }
                format!(r#"<path id="{}" d="{}" {} />"#, element.id, d, style_attr)
            }
            PhysicalGeometry::Image { src, x, y, width, height } => {
                format!(r#"<image id="{}" xlink:href="{}" x="{}" y="{}" width="{}" height="{}" {} />"#, 
                    element.id, src, x, y, width, height, style_attr)
            }
            PhysicalGeometry::Text { value, x, y } => {
                // Pour SVG, y est la ligne de base (baseline), on ajuste selon la spec
                format!(r#"<text id="{}" x="{}" y="{}" {} >{}</text>"#, 
                    element.id, x, y, style_attr, value)
            }
            PhysicalGeometry::Group { children, .. } => {
                let mut group_svg = format!(r#"<g id="{}" {}>"#, element.id, style_attr);
                for child in children {
                    group_svg.push_str(&self.render_element(child)?);
                }
                group_svg.push_str("</g>");
                group_svg
            }
        };

        Ok(content)
    }

    fn resolve_style_attributes(&self, styles: &BTreeMap<String, StyleValue>) -> String {
        let mut attrs = Vec::new();

        if let Some(StyleValue::Color(c)) = styles.get("bg_color") {
            attrs.push(format!(r#"fill="{}""#, c));
        } else {
            attrs.push(r#"fill="none""#.to_string());
        }

        if let Some(StyleValue::Color(c)) = styles.get("border_color") {
            attrs.push(format!(r#"stroke="{}""#, c));
        }

        if let Some(StyleValue::Number(w)) = styles.get("border_width") {
            attrs.push(format!(r#"stroke-width="{}""#, w));
        }

        if let Some(StyleValue::Number(o)) = styles.get("opacity") {
            attrs.push(format!(r#"opacity="{}""#, o));
        }

        // Font styles pour le texte
        if let Some(StyleValue::Number(s)) = styles.get("font_size") {
            attrs.push(format!(r#"font-size="{}""#, s));
        }
        if let Some(StyleValue::String(f)) = styles.get("font_family") {
            attrs.push(format!(r#"font-family="{}""#, f));
        }

        attrs.join(" ")
    }
}

