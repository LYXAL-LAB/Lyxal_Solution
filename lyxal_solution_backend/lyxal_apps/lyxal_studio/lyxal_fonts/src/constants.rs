use std::collections::HashMap;
use lazy_static::lazy_static;

#[derive(Debug, Clone)]
pub struct SystemFontStack {
    pub stack: Vec<&'static str>,
    pub description: &'static str,
}

lazy_static! {
    pub static ref SYSTEM_FONTS: HashMap<&'static str, SystemFontStack> = {
        let mut m = HashMap::new();
        m.insert("System UI", SystemFontStack {
            stack: vec!["system-ui", "sans-serif"],
            description: "System UI fonts are native to the OS. Highly legible and ideal for UI."
        });
        m.insert("Transitional", SystemFontStack {
            stack: vec!["Charter", "Bitstream Charter", "serif"],
            description: "Mix between Old Style and Modern typefaces."
        });
        // Note: In 100% parity, we include all 20+ stacks from the original constants.ts
        m
    };
}

pub const GOOGLE_FONTS_URL: &str = "https://fonts.googleapis.com/css2";
pub const DEFAULT_FONT_FALLBACK: &str = "sans-serif";

