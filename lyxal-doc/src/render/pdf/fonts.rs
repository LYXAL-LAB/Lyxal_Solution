use printpdf::*;
use std::collections::HashMap;
use crate::render::pdf::error::PdfRenderError;

pub struct FontProvider {
    fonts: HashMap<String, IndirectFontRef>,
}

impl FontProvider {
    pub fn new() -> Self {
        Self {
            fonts: HashMap::new(),
        }
    }

    pub fn get_font(&mut self, doc: &PdfDocumentReference, name: &str) -> Result<IndirectFontRef, PdfRenderError> {
        if let Some(font) = self.fonts.get(name) {
            return Ok(font.clone());
        }

        let font_ref = match name.to_lowercase().as_str() {
            "serif" | "times" => doc.add_builtin_font(BuiltinFont::TimesRoman)?,
            "sans" | "helvetica" => doc.add_builtin_font(BuiltinFont::Helvetica)?,
            "mono" | "courier" => doc.add_builtin_font(BuiltinFont::Courier)?,
            _ => doc.add_builtin_font(BuiltinFont::Helvetica)?,
        };

        self.fonts.insert(name.to_string(), font_ref.clone());
        Ok(font_ref)
    }
}
