use printpdf::*;
use crate::word::physical_layout::{WordPageLayout, PhysicalContent as WordContent, PhysicalElement as WordElement};
use crate::slides::physical_layout::{SlidesPhysicalLayout, PhysicalSlideContent as SlidesContent, PhysicalSlideElement as SlidesElement};
use crate::render::pdf::error::PdfRenderError;
use crate::render::pdf::fonts::FontProvider;
use crate::styles::model::StyleValue;
use std::io::BufWriter;
use std::collections::BTreeMap;

pub struct PdfRenderer;

impl PdfRenderer {
    pub fn new() -> Self {
        Self
    }

    /// Rendu PDF pour Word (Flux linéaire)
    pub fn render_word(&self, layout: &WordPageLayout) -> Result<Vec<u8>, PdfRenderError> {
        if layout.pages.is_empty() {
            return Err(PdfRenderError::RenderFailure("Document has no pages".to_string()));
        }

        let page_width = Mm(layout.settings.width as f32 * 0.352778);
        let page_height = Mm(layout.settings.height as f32 * 0.352778);

        let (doc, page1, layer1) = PdfDocument::new("Lyxal Word Document", page_width, page_height, "Layer 1");
        let mut font_provider = FontProvider::new();

        for (i, page_layout) in layout.pages.iter().enumerate() {
            let (current_page, current_layer) = if i == 0 {
                (page1, layer1)
            } else {
                doc.add_page(page_width, page_height, "Layer 1")
            };

            let layer = doc.get_page(current_page).get_layer(current_layer);

            for element in &page_layout.elements {
                self.render_box(&layer, element.x, element.y, element.width, element.height, &element.styles, layout.settings.height)?;

                match &element.content {
                    WordContent::Line { text, .. } => {
                        self.render_text(&layer, &doc, &mut font_provider, text, element.x, element.y, &element.styles, layout.settings.height)?;
                    }
                    _ => {}
                }
            }
        }

        let mut pdf_bytes = Vec::new();
        doc.save(&mut BufWriter::new(&mut pdf_bytes))?;
        Ok(pdf_bytes)
    }

    /// Rendu PDF pour Slides (Espace + Temps)
    pub fn render_slides(&self, layout: &SlidesPhysicalLayout) -> Result<Vec<u8>, PdfRenderError> {
        if layout.slides.is_empty() {
            return Err(PdfRenderError::RenderFailure("Presentation has no slides".to_string()));
        }

        let page_width = Mm(layout.settings.width as f32 * 0.352778);
        let page_height = Mm(layout.settings.height as f32 * 0.352778);

        let (doc, page1, layer1) = PdfDocument::new("Lyxal Slides Document", page_width, page_height, "Main");
        let mut font_provider = FontProvider::new();

        let mut is_first_page = true;

        for slide in &layout.slides {
            for step in &slide.steps {
                let (page_ref, layer_ref) = if is_first_page {
                    is_first_page = false;
                    (page1, layer1)
                } else {
                    doc.add_page(page_width, page_height, "Main")
                };

                let layer = doc.get_page(page_ref).get_layer(layer_ref);

                let mut sorted_elements = step.elements.clone();
                sorted_elements.sort_by_key(|e| e.z);

                for element in &sorted_elements {
                    self.render_slide_element(&layer, &doc, &mut font_provider, element, layout.settings.height)?;
                }
            }
        }

        let mut pdf_bytes = Vec::new();
        doc.save(&mut BufWriter::new(&mut pdf_bytes))?;
        Ok(pdf_bytes)
    }

    fn render_slide_element(
        &self, 
        layer: &PdfLayerReference, 
        doc: &PdfDocumentReference, 
        font_provider: &mut FontProvider, 
        element: &SlidesElement,
        page_height: f64
    ) -> Result<(), PdfRenderError> {
        self.render_box(layer, element.x, element.y, element.width, element.height, &element.styles, page_height)?;

        match &element.content {
            SlidesContent::Text(text) => {
                self.render_text(layer, doc, font_provider, text, element.x, element.y, &element.styles, page_height)?;
            }
            SlidesContent::Group(children) => {
                for child in children {
                    self.render_slide_element(layer, doc, font_provider, child, page_height)?;
                }
            }
            _ => {}
        }
        Ok(())
    }

    fn render_text(
        &self,
        layer: &PdfLayerReference,
        doc: &PdfDocumentReference,
        font_provider: &mut FontProvider,
        text: &str,
        x: f64,
        y: f64,
        styles: &BTreeMap<String, StyleValue>,
        page_height: f64
    ) -> Result<(), PdfRenderError> {
        let font_size = match styles.get("font_size") {
            Some(StyleValue::Number(n)) => *n as f32,
            _ => 12.0,
        };

        if let Some(StyleValue::Color(hex)) = styles.get("text_color") {
            layer.set_fill_color(self.hex_to_color(hex)?);
        } else {
            layer.set_fill_color(Color::Rgb(Rgb::new(0.0, 0.0, 0.0, None)));
        }

        let font = font_provider.get_font(doc, "sans")?;
        let pdf_y = (page_height as f32) - (y as f32) - font_size;

        layer.use_text(
            text,
            font_size,
            Mm(x as f32 * 0.352778),
            Mm(pdf_y * 0.352778),
            &font
        );
        Ok(())
    }

    fn render_box(
        &self, 
        layer: &PdfLayerReference, 
        x: f64, 
        y: f64, 
        w: f64, 
        h: f64, 
        styles: &BTreeMap<String, StyleValue>,
        page_height: f64
    ) -> Result<(), PdfRenderError> {
        let xf = x as f32 * 0.352778;
        let yf = y as f32 * 0.352778;
        let wf = w as f32 * 0.352778;
        let hf = h as f32 * 0.352778;
        let phf = page_height as f32 * 0.352778;

        if let Some(StyleValue::Color(hex)) = styles.get("bg_color") {
            layer.set_fill_color(self.hex_to_color(hex)?);
            layer.add_rect(Rect::new(Mm(xf), Mm(phf - yf - hf), Mm(xf + wf), Mm(phf - yf)));
        }

        if let Some(StyleValue::Number(width)) = styles.get("border_width") {
            if *width > 0.0 {
                layer.set_outline_thickness(*width as f32);
                if let Some(StyleValue::Color(hex)) = styles.get("border_color") {
                    layer.set_outline_color(self.hex_to_color(hex)?);
                }
                layer.add_rect(Rect::new(Mm(xf), Mm(phf - yf - hf), Mm(xf + wf), Mm(phf - yf)));
            }
        }

        Ok(())
    }

    fn hex_to_color(&self, hex: &str) -> Result<Color, PdfRenderError> {
        let hex = hex.trim_start_matches('#');
        if hex.len() != 6 {
            return Ok(Color::Rgb(Rgb::new(0.0, 0.0, 0.0, None)));
        }
        let r = u8::from_str_radix(&hex[0..2], 16).unwrap_or(0) as f32 / 255.0;
        let g = u8::from_str_radix(&hex[2..4], 16).unwrap_or(0) as f32 / 255.0;
        let b = u8::from_str_radix(&hex[4..6], 16).unwrap_or(0) as f32 / 255.0;
        Ok(Color::Rgb(Rgb::new(r, g, b, None)))
    }
}
