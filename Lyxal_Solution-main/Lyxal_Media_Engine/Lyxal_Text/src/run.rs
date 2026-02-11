use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum FontStyle {
    Normal,
    Italic,
    Oblique,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct TextStyle {
    pub font_family: String,
    pub font_size: f32,
    #[serde(default = "default_weight")]
    pub font_weight: u16, // 400 = Normal, 700 = Bold
    #[serde(default = "default_style")]
    pub font_style: FontStyle,
    pub color: String, // Hex #RRGGBB
    pub letter_spacing: Option<f32>,
}

fn default_weight() -> u16 { 400 }
fn default_style() -> FontStyle { FontStyle::Normal }

impl Default for TextStyle {
    fn default() -> Self {
        Self {
            font_family: "Sans Serif".to_string(),
            font_size: 24.0,
            font_weight: 400,
            font_style: FontStyle::Normal,
            color: "#000000".to_string(),
            letter_spacing: None,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TextRun {
    pub text: String,
    pub style: TextStyle,
}

impl TextRun {
    pub fn new(text: &str, style: TextStyle) -> Self {
        Self {
            text: text.to_string(),
            style,
        }
    }
}
